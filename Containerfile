# syntax=docker/dockerfile:1
# copyright 2026 <github.attic@typedef.net>, CC BY 4.0

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# Debian 12 "Bookworm", 2023.  Won't compile niri due to missing
# 'libdisplay-info-dev'; seems doable if need be.
#FROM debian:bookworm-slim AS base

# Debian 13 "Trixie", 2025
FROM debian:trixie-slim AS base

#ARG TZ="Europe/Berlin"
#ENV TZ=${TZ}
#ARG DEBIAN_FRONTEND="noninteractive"

RUN true \
  && echo 'debconf debconf/frontend select Noninteractive' |debconf-set-selections \
  && dpkg-reconfigure --frontend noninteractive debconf \
  && apt-get update && apt-get -y upgrade \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    iproute2 \
    procps

# basic tooling
RUN true \
  && apt-get install -y --no-install-recommends \
    build-essential \
    devscripts \
    lsb-release \
    equivs \
    curl \
    git

# interactive tooling
#RUN true \
#  && apt-get install -y --no-install-recommends \
#    less \
#    rcs \
#    tmux \
#    vim

# cleanup
#RUN true \
#  && apt-get -y remove --purge --auto-remove && apt-get -y clean \
#  && rm -rf /var/lib/apt/lists/*


FROM base AS build

# The rust development environment, either from the distributions
# repository or falling back to manual installation in case the 'rustup'
# package is not available, see https://rust-lang.org/tools/install/.
#
# If installed via apt-get, an empty ${HOME}/.cargo/env file is created
# as a stand-in in order to avoid diverging code below.

RUN true \
  && apt-get install -y --no-install-recommends rustup \
  && install -Dv /dev/null ${HOME}/.cargo/env \
  || curl -sSf https://sh.rustup.rs |sh -s -- -y

# project specific tooling, see
#  https://niri-wm.github.io/niri/Getting-Started.html#building

RUN true \
  && apt-get install -y --no-install-recommends \
    clang \
    libdbus-1-dev \
    libdisplay-info-dev \
    libegl1-mesa-dev \
    libgbm-dev \
    libinput-dev \
    libpango1.0-dev \
    libpipewire-0.3-dev \
    libseat-dev \
    libsystemd-dev \
    libudev-dev \
    libwayland-dev \
    libxkbcommon-dev

# cleanup
#RUN true \
#  && apt-get -y remove --purge --auto-remove && apt-get -y clean \
#  && rm -rf /var/lib/apt/lists/*

WORKDIR /build

RUN \
  --mount=type=cache,target=/usr/local/cargo/registry \
  --mount=type=cache,target=/usr/local/cargo/git \
  true \
  && . ${HOME}/.cargo/env \
  && rustup default stable \
  && cargo install cargo-deb

# this is niri 25.11.0 as of 2026-02-27
#ARG PAYLOAD_REF="2dc6f4482c4eeed75ea8b133d89cad8658d38429"

RUN true \
  && git clone --depth 1 https://github.com/niri-wm/niri
  #&& git clone https://github.com/niri-wm/niri \
  #&& cd niri && git checkout "${PAYLOAD_REF}"

RUN \
  --mount=type=cache,target=/usr/local/cargo/registry \
  --mount=type=cache,target=/usr/local/cargo/git \
  true \
  && . ${HOME}/.cargo/env \
  && cd niri && cargo deb


FROM scratch AS artifacts

COPY --from=build /build/niri/target/debian /

