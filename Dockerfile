# syntax=docker/dockerfile:1.4

FROM debian:bullseye

SHELL ["bash", "-euxo", "pipefail", "-c"]

ENV WORK_DIR=/workdir
ENV ASSETS_DIR=/assets

RUN <<EOS
mkdir -p "${WORK_DIR}"
mkdir -p "${ASSETS_DIR}"
EOS

COPY ruby-jemalloc "${ASSETS_DIR}/ruby-jemalloc"
COPY libruby-jemalloc "${ASSETS_DIR}/libruby-jemalloc"
COPY ruby-jemalloc-dev "${ASSETS_DIR}/ruby-jemalloc-dev"

COPY scripts "${WORK_DIR}/scripts"

RUN env TRACE=true "${WORK_DIR}/scripts/build-source"
RUN env TRACE=true "${WORK_DIR}/scripts/build-deb"
