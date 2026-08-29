# =============================================================================
# GLOBAL ARGS
# =============================================================================
# Matched to Python 3.11 to align with Debian 12 Distroless
ARG BUILDER_BASE=python:3.11-slim@sha256:9c900dea9e8fb7e16277c179b555cc72d29a352dbc33cff48ad5a0412fd5bfc7
ARG RUNTIME_BASE=gcr.io/distroless/python3-debian12:nonroot@sha256:7d1042ce588ab97019fe95c24ffca7bc5a82ccdac572511d5e09bda4435c89c5

# =============================================================================
# STAGE 1 — builder
# =============================================================================
# hadolint ignore=DL3006
FROM ${BUILDER_BASE} AS builder

ARG SOURCE_DATE_EPOCH

WORKDIR /app

ENV PYTHONHASHSEED=0 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONUNBUFFERED=1

COPY requirements.txt .

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --target=/install -r requirements.txt

COPY . /app

RUN find /install /app -exec touch -h --date="@${SOURCE_DATE_EPOCH:-0}" {} +

# =============================================================================
# STAGE 2 — runtime (Distroless)
# =============================================================================
# hadolint ignore=DL3006
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

USER nonroot:nonroot

COPY --chown=nonroot:nonroot --from=builder /install /app/site-packages
COPY --chown=nonroot:nonroot --from=builder /app /app

EXPOSE 8000

ENTRYPOINT ["/usr/bin/python3", "-m", "gunicorn"]

CMD ["myproject.wsgi:application", \
     "--bind", "0.0.0.0:8000", \
     "--workers", "3", \
     "--timeout", "120", \
     "--graceful-timeout", "30"]
