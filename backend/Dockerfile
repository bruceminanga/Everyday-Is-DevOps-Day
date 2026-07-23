# =============================================================================
# GLOBAL ARGS
# Declared BEFORE the first FROM so it can be dynamically overridden with:
#   docker build --build-arg BASE=python:3.11-slim .
# =============================================================================
ARG BASE=python:3.12-slim@sha256:ac212230555ffb7ec17c214fb4cf036ced11b30b5b460994376b0725c7f6c151

# =============================================================================
# STAGE 1 — builder
# Install dependencies in isolation. The compiler, pip, and wheel never
# reach the production image.
# =============================================================================
FROM ${BASE} AS builder

# BuildKit passes SOURCE_DATE_EPOCH for reproducible timestamps
ARG SOURCE_DATE_EPOCH

WORKDIR /app

ENV PYTHONHASHSEED=0 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/install/lib/python3.12/site-packages:/install/lib/python3.11/site-packages:/install/lib/python3.10/site-packages \
    PATH=/install/bin:$PATH

# Manifests first — this layer is cached until requirements change
COPY requirements.txt .

# Install into an explicit prefix so we can surgically copy it to runtime.
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --prefix=/install -r requirements.txt

# Normalize file modification timestamps in /install to SOURCE_DATE_EPOCH
RUN find /install -exec touch -h --date="@${SOURCE_DATE_EPOCH:-0}" {} +


# =============================================================================
# STAGE 2 — runtime
# Clean slate. Only installed packages + source land here.
# No pip. No compiler. No build tools.
# =============================================================================
FROM ${BASE} AS runtime

ARG GIT_SHA=unknown
ARG VERSION=1.0.0
ARG MAINTAINER="bruce@bruceminanga.world"
ARG SOURCE_DATE_EPOCH

LABEL org.opencontainers.image.revision="${GIT_SHA}" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.authors="${MAINTAINER}" \
      org.opencontainers.image.base.name="python:3.12-slim"

WORKDIR /app

ENV PYTHONHASHSEED=0 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/install/lib/python3.12/site-packages:/install/lib/python3.11/site-packages:/install/lib/python3.10/site-packages \
    PATH=/install/bin:$PATH

# Pull only the installed packages from the builder stage
COPY --from=builder /install /install

# Non-root user — assigned deterministic UID (10001), cleaned backups, & normalized /etc timestamps
RUN useradd --uid 10001 --no-create-home --shell /bin/false appuser && \
    rm -f /etc/passwd- /etc/shadow- /etc/group- /etc/gshadow- /var/log/lastlog /var/log/faillog && \
    find /etc /var/log -exec touch -h --date="@${SOURCE_DATE_EPOCH:-0}" {} + 2>/dev/null || true

# Source arrives last — changes here don't bust the dependency cache
COPY --chown=appuser:appuser . .

USER appuser

EXPOSE 8000

CMD ["gunicorn", "myproject.wsgi:application", \
     "--bind", "0.0.0.0:8000", \
     "--workers", "3", \
     "--timeout", "120"]