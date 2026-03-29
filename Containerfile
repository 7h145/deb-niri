# syntax=docker/dockerfile:1
# copyright 2026 <github.attic@typedef.net>, CC BY 4.0

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

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

# project specific tooling, see
#  https://niri-wm.github.io/niri/Getting-Started.html#building

RUN true \
  && apt-get install -y --no-install-recommends \
    rustup \
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
  && rustup default stable \
  && cargo install cargo-deb

# this is niri 25.11.0 as of 2026-02-27
#ARG PAYLOAD_REF="2dc6f4482c4eeed75ea8b133d89cad8658d38429"

RUN true \
  && git clone --depth 1 https://github.com/niri-wm/niri
  #&& cd niri && git checkout "${PAYLOAD_REF}"

RUN \
  --mount=type=cache,target=/usr/local/cargo/registry \
  --mount=type=cache,target=/usr/local/cargo/git \
  true \
  && cd niri && cargo deb


FROM scratch AS artifacts

COPY --from=build /build/niri/target/debian /

