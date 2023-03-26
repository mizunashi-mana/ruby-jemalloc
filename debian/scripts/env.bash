#!/usr/bin/env bash

RUBY_SOURCE_VERSION="${RUBY_SOURCE_VERSION:-3.2.1}"

WORK_DIR="${WORK_DIR:-"$(pwd)"}"

SOURCE_DIR="${WORK_DIR}/source"
INSTALL_DIR="${WORK_DIR}/install"

SUFFIX="-jemalloc"
