# =============================================================================
# STAGE 1 — Builder
# Node 22.14.0-alpine pinned by Multi-Arch SHA256 Index
# =============================================================================
FROM --platform=$BUILDPLATFORM node:22.14.0-alpine@sha256:9bef0ef1e268f60627da9ba7d7605e8831d5b56ad07487d24d1aa386336d1944 AS builder

WORKDIR /app

# Manifests first — cached until package.json / package-lock.json changes
COPY package*.json ./

# BuildKit cache mount prevents layer bloat while keeping rebuilds fast
RUN --mount=type=cache,target=/root/.npm \
    npm ci --prefer-offline

# copying files from your computer into the container image
COPY . .

# Compile application assets
RUN npm run build


# =============================================================================
# STAGE 2 — Runtime
# Chainguard Distroless Nginx (Hardened, Zero CVE, No Shell, Non-Root)
# =============================================================================
FROM cgr.dev/chainguard/nginx:latest AS runtime

ARG GIT_SHA=unknown
ARG VERSION=1.0.0
ARG MAINTAINER="bruce@bruceminanga.world"

# OCI Standard Metadata Labels
LABEL org.opencontainers.image.revision="${GIT_SHA}" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.authors="${MAINTAINER}" \
      org.opencontainers.image.base.name="cgr.dev/chainguard/nginx"

# Copy compiled static output from builder to static web root
COPY --from=builder /app/dist /usr/share/nginx/html

# Chainguard Nginx runs as a non-root user listening on port 8080
EXPOSE 8080

CMD ["-g", "daemon off;"]