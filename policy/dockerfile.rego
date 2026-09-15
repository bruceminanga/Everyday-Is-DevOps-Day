package main

# ---------------------------------------------------------------------------
# Helpers: Hardened Base Image & Exemption Detection
# ---------------------------------------------------------------------------

# Known images that are non-root and distroless by default
hardened_bases := [
    "cgr.dev/chainguard/",
    "gcr.io/distroless/"
]

# Find the final (runtime) FROM base image in multi-stage builds
runtime_base_image := val if {
    froms := [img |
        some i
        input[i].Cmd == "from"
        img := input[i].Value[0]
    ]
    count(froms) > 0
    val := froms[count(froms) - 1]
}

# Check if runtime image comes from a hardened provider
is_hardened_base if {
    some base in hardened_bases
    contains(runtime_base_image, base)
}

# Optional: Allow skipping HEALTHCHECK if an explicit label declares it is handled by Compose/K8s
orchestrator_healthcheck if {
    some i
    input[i].Cmd == "label"
    some val in input[i].Value
    contains(val, "devops.healthcheck")
}

# ---------------------------------------------------------------------------
# Policies
# ---------------------------------------------------------------------------

# 1. Phase 3: Pin base images by SHA256 digest
deny contains msg if {
    some i
    input[i].Cmd == "from"
    val := input[i].Value[0]
    val != "scratch"
    not contains(val, "@sha256:")
    msg := sprintf("[Phase 3] Base image '%v' must be pinned with an immutable SHA256 digest (@sha256:...)", [val])
}

# 2. Phase 3: Never use :latest tag
deny contains msg if {
    some i
    input[i].Cmd == "from"
    val := input[i].Value[0]
    contains(val, ":latest")
    msg := sprintf("[Phase 3 & 7] Base image '%v' must not use the mutable ':latest' tag", [val])
}

# 3. Phase 3: Must run as non-root user (skipped if base is already hardened)
deny contains msg if {
    not is_hardened_base
    users := [val | some i; input[i].Cmd == "user"; val := input[i].Value[0]]
    count(users) == 0
    msg := "[Phase 3] Dockerfile must declare a non-root 'USER' directive"
}

# 4. Phase 4: Must define HEALTHCHECK (skipped if distroless or handled by orchestrator)
deny contains msg if {
    not is_hardened_base
    not orchestrator_healthcheck
    healthchecks := [val | some i; input[i].Cmd == "healthcheck"; val := input[i].Value]
    count(healthchecks) == 0
    msg := "[Phase 4] Dockerfile must declare a 'HEALTHCHECK' directive or 'devops.healthcheck' label"
}

# 5. Phase 3: Must include OCI standard metadata labels
deny contains msg if {
    labels := [val | some i; input[i].Cmd == "label"; val := input[i].Value]
    count(labels) == 0
    msg := "[Phase 3] Dockerfile must define OCI metadata labels (LABEL org.opencontainers.image...)"
}