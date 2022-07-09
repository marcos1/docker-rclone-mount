ARG RCLONE_VERSION="v1.58.1"


# Builder
FROM golang:alpine AS builder

ARG RCLONE_VERSION

WORKDIR /go/src/github.com/rclone/rclone/

ENV GOPATH="/go" \
    GO111MODULE="on"

RUN \
    echo "*** Installing packages ***" && \
    apk add --no-cache --update \
        ca-certificates \
        go \
        git \
        gcc

RUN \
    echo "*** Cloning rlcone source ***" && \
    git clone https://github.com/rclone/rclone.git && \
    cd rclone && \
    echo "*** Building Rclone Source ***" && \
    go build && \
    echo "*** Finished building source ***"



## Image
FROM ghcr.io/linuxserver/baseimage-alpine:3.15


ENV DEBUG="false" \
    AccessFolder="/mnt" \
    RemotePath="mediaefs:" \
    MountPoint="/mnt/mediaefs" \
    ConfigDir="/config" \
    ConfigName=".rclone.conf" \
    MountCommands="--allow-other --allow-non-empty" \
    UnmountCommands="-u -z"

COPY --from=builder /go/src/github.com/rclone/rclone/rclone /usr/local/sbin/

RUN \
    apk --no-cache upgrade && \
        apk add --no-cache --update \
            ca-certificates \
            fuse \
            fuse-dev \
            bash \
            curl && \
    rm -rf /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

COPY rootfs/ /

VOLUME ["/mnt"]

ENTRYPOINT ["/init"]

# Use this docker Options in run
# --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined
# -v /path/to/config/.rclone.conf:/config/.rclone.conf
# -v /mnt/mediaefs:/mnt/mediaefs:shared
