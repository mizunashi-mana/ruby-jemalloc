# syntax=docker/dockerfile:1.4

FROM debian:bullseye

SHELL ["bash", "-euxo", "pipefail", "-c"]

ENV WORK_DIR=/workdir

RUN <<EOS
mkdir -p "${WORK_DIR}/scripts"
EOS

COPY scripts/env.bash "${WORK_DIR}/scripts/env.bash"
COPY scripts/build-source "${WORK_DIR}/scripts/build-source"
RUN env TRACE=true "${WORK_DIR}/scripts/build-source"

COPY scripts/build-deb "${WORK_DIR}/scripts/build-deb"
COPY ruby-jemalloc-dev "${WORK_DIR}/ruby-jemalloc-dev"
RUN env TRACE=true "${WORK_DIR}/scripts/build-deb"
