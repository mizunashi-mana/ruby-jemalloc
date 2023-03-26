# syntax=docker/dockerfile:1.4

FROM debian:bullseye

SHELL ["bash", "-euxo", "pipefail", "-c"]

ENV WORK_DIR=/workdir
ENV ASSETS_DIR=/assets

RUN <<EOS
mkdir -p "${WORK_DIR}"
mkdir -p "${ASSETS_DIR}"
EOS

COPY scripts/env.bash "${WORK_DIR}/scripts/env.bash"
COPY scripts/build-source "${WORK_DIR}/scripts/build-source"
RUN env TRACE=true "${WORK_DIR}/scripts/build-source"

COPY scripts/build-deb "${WORK_DIR}/scripts/build-deb"
COPY ruby-jemalloc-dev "${ASSETS_DIR}/ruby-jemalloc-dev"
RUN env TRACE=true "${WORK_DIR}/scripts/build-deb"
