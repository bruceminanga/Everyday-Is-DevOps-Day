# =============================================================================
# GLOBAL ARGS
# =============================================================================
ARG BUILDER_BASE=python:3.12-slim@sha256:57cd7c3a7a273101a6485ba99423ee568157882804b1124b4dd04266317710de
ARG RUNTIME_BASE=gcr.io/distroless/python3-debian12:nonroot@sha256:7d1042ce588ab97019fe95c24ffca7bc5a82ccdac572511d5e09bda4435c89c5

# =============================================================================
# STAGE 1 — builder
# Complete build environment: compilers, pip, and shell utilities.
# =============================================================================
FROM ${BUILDER_BASE} AS builder

ARG SOURCE_DATE_EPOCH

WORKDIR /app

ENV PYTHONHASHSEED=0 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONUNBUFFERED=1

# Copy dependencies manifest
COPY requirements.txt .

# Target installation directly into a directory we can easily mount in PYTHONPATH
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --target=/install -r requirements.txt

# Copy application source code into builder
COPY . /app

# Normalize file modification timestamps for reproducibility BEFORE copying to distroless
# (since 'find' and 'touch' do not exist in the distroless runtime stage)
RUN find /install /app -exec touch -h --date="@${SOURCE_DATE_EPOCH:-0}" {} +

# =============================================================================
# STAGE 2 — runtime (Distroless)
# Clean slate containing ONLY the Python runtime, dependencies, and app code.
# =============================================================================
FROM ${RUNTIME_BASE} AS runtime

ARG GIT_SHA=unknown
ARG VERSION=1.0.0
ARG MAINTAINER="bruce@bruceminanga.world"

LABEL org.opencontainers.image.revision="${GIT_SHA}" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.authors="${MAINTAINER}" \
      org.opencontainers.image.base.name="gcr.io/distroless/python3-debian12:nonroot"

WORKDIR /app

ENV PYTHONHASHSEED=0 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app/site-packages

# Distroless images come with a pre-configured non-root user 'nonroot' (UID/GID 65532)
USER nonroot:nonroot

# Copy installed Python packages from builder to the site-packages directory
COPY --chown=nonroot:nonroot --from=builder /install /app/site-packages

# Copy application source code from builder
COPY --chown=nonroot:nonroot --from=builder /app /app

EXPOSE 8000

# Exec-form ENTRYPOINT invoking Gunicorn via Python module (-m)
# Exec-form is strictly required as there is no shell to expand string commands.
ENTRYPOINT ["/usr/bin/python3", "-m", "gunicorn", \
            "myproject.wsgi:application", \
            "--bind", "0.0.0.0:8000", \
            "--workers", "3", \
            "--timeout", "120"]