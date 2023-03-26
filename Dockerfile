# syntax=docker/dockerfile:1.4

FROM debian:bullseye

ARG RUBY_SOURCE_VERSION="3.2.1"

SHELL ["bash", "-euxo", "pipefail", "-c"]

ENV PACKAGE="ruby3.2-jemalloc" \
    VERSION="${RUBY_SOURCE_VERSION}" \
    WORK_DIR="/workdir"
ENV SOURCE_DIR="${WORK_DIR}/source" \
    INSTALL_DIR="${WORK_DIR}/install"

# Install dev tools for deb
RUN <<EOS
apt update -y
apt install -y \
    build-essential \
    debhelper \
    dh-make \
    pbuilder \
    devscripts \
    rsync

apt clean
rm -rf /var/lib/apt/lists/*
EOS

RUN <<EOS
apt update -y
apt install -y wget

mkdir -p "${SOURCE_DIR}"
mkdir -p "${INSTALL_DIR}"

RUBY_SOURCE_VERSION_PREFIX="$(echo "$RUBY_SOURCE_VERSION" | sed -E 's/\.[0-9]+$//')"
wget -O- \
    "https://cache.ruby-lang.org/pub/ruby/${RUBY_SOURCE_VERSION_PREFIX}/ruby-${RUBY_SOURCE_VERSION}.tar.gz" \
    | tar xzf - -C "${SOURCE_DIR}" --strip-components 1

apt remove -y wget
apt clean
rm -rf /var/lib/apt/lists/*
EOS

# Install build dependencies
RUN <<EOS
apt update -y
apt install -y \
    bison \
    coreutils \
    debhelper-compat \
    file \
    libffi-dev \
    libgdbm-compat-dev \
    libgdbm-dev \
    libgmp-dev \
    libncurses-dev \
    libedit-dev \
    libssl-dev \
    libyaml-dev \
    libjemalloc-dev \
    netbase \
    openssl \
    pkg-config \
    procps \
    systemtap-sdt-dev \
    tzdata \
    zlib1g-dev

apt clean
rm -rf /var/lib/apt/lists/*
EOS

WORKDIR "${SOURCE_DIR}"

RUN <<EOS
DEB_BUILD_GNU_TYPE="$(dpkg-architecture -qDEB_BUILD_GNU_TYPE)"

./configure \
    "--prefix=${INSTALL_DIR}/usr" \
    --enable-multiarch \
    --program-suffix=3.2-jemalloc \
    --with-soname=ruby3.2-jemalloc \
    --enable-shared \
    --disable-rpath \
    --with-sitedir='/usr/local/lib/site_ruby' \
    --with-sitearchdir="/usr/local/lib/${DEB_BUILD_GNU_TYPE}/site_ruby" \
    --runstatedir=/var/run \
    "--localstatedir=${INSTALL_DIR}/var" \
    --sysconfdir=/etc \
    --enable-ipv6 \
    --with-jemalloc \
    --with-dbm-type=gdbm_compat \
    --with-compress-debug-sections=no \
    AS="${DEB_BUILD_GNU_TYPE}-as" \
    CC="${DEB_BUILD_GNU_TYPE}-gcc" \
    CXX="${DEB_BUILD_GNU_TYPE}-g++" \
    LD="${DEB_BUILD_GNU_TYPE}-ld" \
    EGREP='/bin/grep -E' \
    GREP='/bin/grep' \
    MAKEDIRS='/bin/mkdir -p' \
    MKDIR_P='/bin/mkdir -p' \
    SHELL='/bin/sh'
make install
EOS

COPY ruby3.2-jemalloc "${INSTALL_DIR}/ruby3.2-jemalloc"
WORKDIR "${INSTALL_DIR}"
RUN <<EOS
rsync --recursive --relative \
    usr/bin \
    usr/share/man \
    "${INSTALL_DIR}/ruby3.2-jemalloc/"

dpkg-deb --build "${INSTALL_DIR}/ruby3.2-jemalloc/" .
EOS

COPY libruby3.2-jemalloc "${INSTALL_DIR}/libruby3.2-jemalloc"
WORKDIR "${INSTALL_DIR}"
RUN <<EOS
rsync --recursive --relative \
    usr/lib/*/*.so.* \
    usr/lib/*/ruby \
    usr/lib/ruby \
    "${INSTALL_DIR}/libruby3.2-jemalloc/"

dpkg-deb --build "${INSTALL_DIR}/libruby3.2-jemalloc/" .
EOS

COPY ruby3.2-jemalloc-dev "${INSTALL_DIR}/ruby3.2-jemalloc-dev"
WORKDIR "${INSTALL_DIR}"
RUN <<EOS
rsync --recursive --relative \
    usr/include \
    usr/lib/*/*.so \
    usr/lib/*/pkgconfig \
    "${INSTALL_DIR}/ruby3.2-jemalloc-dev/"

dpkg-deb --build "${INSTALL_DIR}/ruby3.2-jemalloc-dev/" .
EOS
