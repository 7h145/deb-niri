# Build [niri](https://github.com/niri-wm/niri) Packages for [Debian](https://www.debian.org/) in a Container

This is a [Containerfile](https://github.com/7h145/deb-niri/blob/main/Containerfile) which builds a debian package of the latest [niri](https://github.com/niri-wm/niri), following [niris build instructions](https://niri-wm.github.io/niri/Getting-Started.html#building).

## Building niri in a Container

Have a look at the very simple [`build.sh` script](https://github.com/7h145/deb-niri/blob/main/build.sh).  To build a fresh niri just

    build.sh

This will build the [Containerfile](https://github.com/7h145/deb-niri/blob/main/Containerfile), downloading the Debian image, configuring the build environment with all dependencies and then build the latest niri cloned from the https://github.com/niri-wm/niri repository.  The `niri_*.deb` Debian package will end up in the `artifacts` directory (on the host).

After the build process, the build layers and cache are kept on the host; subsequent builds will be considerably faster.  If you want to reclaim disk space, use

    podman builder prune
    podman image prune

to remove unused build cache and dangling images (equivalent commands are available for `docker`).

If you want a fully fresh rebuild, use:

    build.sh --no-cache --pull=always

`--no-cache` disables layer reuse, and `--pull=always` refreshes the base image before building.

## Installing niri

After `build.sh`, install the freshly build `niri_*.deb` via `dpkg -i`, then pull missing dependencies afterwards with `apt install -f`.

    dpkg -i artifacts/niri_*.deb
    apt install -f

Remark: As of 2026-02-27, niri-25.11: niri needs `libseat.so.1` but the `libseat1` package is not flagged as a dependency in the `niri_*.deb`.  Just `apt install libseat1`.

## Remarks and Caveats

### Reproducibility or Latest and Greatest

This is not configured for reproducible builds; the build operating system in the container will be updated and the niri source code will get pulled from the latest commit.  For somewhat more reproducible builds, start with:
* fix the base image version,
* remove the `apt-get update && apt-get upgrade`, and
* fix the git checkout to the commit of your choice.

This will still leave the interesting problem of reproducible rust builds.

### Target Distribution to build for

The default base image in the [Containerfile](https://github.com/7h145/deb-niri/blob/main/Containerfile), is `debian:trixie`, but any more or less recent debianesque distribution (e.g. `debian:bookworm`, `ubuntu:jammy`, or `ubuntu:noble`) should work fine.  Convenient if you want to cross build for another distribution, e.g. if not all your systems are on the same distribution or version.

### Container Runtime

My container runtime of choice is [Podman](https://github.com/containers/podman/), but this should work using [Docker](https://github.com/docker) without much hassle (i.e. change `podman` to `docker` in [`build.sh`](https://github.com/7h145/deb-niri/blob/main/build.sh)).

