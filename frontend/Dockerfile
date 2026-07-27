# =============================================================================
# STAGE 1 — builder
# Node 22.14.0-alpine pinned by Multi-Arch Index SHA
# --platform=$BUILDPLATFORM compiles static assets natively on host (Fast & no QEMU error)
# =============================================================================
FROM --platform=$BUILDPLATFORM node:22.14.0-alpine@sha256:9bef0ef1e268f60627da9ba7d7605e8831d5b56ad07487d24d1aa386336d1944 AS builder

WORKDIR /app

# Manifests first — cached until package.json or package-lock.json changes
COPY package*.json ./

# npm ci writes nothing to a global cache by default.
RUN npm ci --prefer-offline

# Source arrives after deps — changes here don't bust the install cache
COPY . .

RUN npm run build


# =============================================================================
# STAGE 2 — runtime
# Chainguard Distroless Nginx (Hardened, Zero CVE, No Shell, Non-Root)
# =============================================================================
FROM cgr.dev/chainguard/nginx:latest AS runtime

ARG GIT_SHA=unknown
ARG VERSION=1.0.0
ARG MAINTAINER="bruce@bruceminanga.world"

LABEL org.opencontainers.image.revision="${GIT_SHA}" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.authors="${MAINTAINER}" \
      org.opencontainers.image.base.name="cgr.dev/chainguard/nginx"

# Copy compiled static assets from builder to the default static directory
COPY --from=builder /app/dist /usr/share/nginx/html

# Distroless Nginx runs as a non-root user, which listens on port 8080 by default
EXPOSE 8080

CMD ["-g", "daemon off;"]