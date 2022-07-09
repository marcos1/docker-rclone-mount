ARG OVERLAY_VERSION="v3.1.1.2"
ARG OVERLAY_ARCH

## Image
FROM alpine:edge

ARG OVERLAY_VERSION
ARG OVERLAY_ARCH
ARG OVERLAY_KEY


ENV DEBUG="false" \
    AccessFolder="/mnt" \
    RemotePath="mediaefs:" \
    MountPoint="/mnt/mediaefs" \
    ConfigDir="/config" \
    ConfigName=".rclone.conf" \
    MountCommands="--allow-other --allow-non-empty" \
    UnmountCommands="-u -z"

RUN set -ex \
      && export OVERLAY_ARCH=$(uname -m) \
      && if [ "${OVERLAY_ARCH}" = "x86_64" ]; then export OVERLAY_ARCH=amd64; fi \
      && if [ "${OVERLAY_ARCH}" = "armv7l" ]; then export OVERLAY_ARCH=arm; fi \
      && if [ "${OVERLAY_ARCH}" = "aarch64" ]; then export OVERLAY_ARCH=arm64; fi

RUN apk --no-cache upgrade && \
    apk add --no-cache --update ca-certificates \
    fuse \
    fuse-dev \
    curl \
    gnupg && \
    echo "Installing S6 Overlay" && \
    curl -o /tmp/s6-overlay.tar.gz -L \
    "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz" && \
    apk del \
    curl \
    gnupg \
    rclone && \
    rm -rf /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

COPY rootfs/ /

VOLUME ["/mnt"]

ENTRYPOINT ["/init"]

# Use this docker Options in run
# --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined
# -v /path/to/config/.rclone.conf:/config/.rclone.conf
# -v /mnt/mediaefs:/mnt/mediaefs:shared
