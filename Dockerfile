FROM ghcr.io/astral-sh/uv:0.11.19-python3.14-alpine

ARG LUX_VERSION=0.24.1
ARG TARGETARCH

RUN apk add --no-cache ca-certificates coreutils curl deno ffmpeg tar tzdata tini \
    && case "${TARGETARCH}" in \
         amd64) LUX_ARCH=x86_64 ;; \
         arm64) LUX_ARCH=arm64 ;; \
         arm) LUX_ARCH=armv6 ;; \
         386) LUX_ARCH=i386 ;; \
         *) echo "unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
       esac \
    && curl -fsSL "https://github.com/iawia002/lux/releases/download/v${LUX_VERSION}/lux_${LUX_VERSION}_Linux_${LUX_ARCH}.tar.gz" \
        | tar -xz -C /tmp \
    && install -m 0755 /tmp/lux /usr/local/bin/lux \
    && rm -f /tmp/lux

ENV TZ=Asia/Kolkata
ENV PATH="/app/.venv/bin:$PATH"

WORKDIR /app

COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

COPY src/ ./src/
COPY config.toml ./config.toml

ENTRYPOINT ["/sbin/tini", "--", "daphne"]
