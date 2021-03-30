ARG ALPINE_VERSION=3.13

ARG SRC_REPO=https://github.com/aldostools/webMAN-MOD.git
ARG SRC_BRANCH=master
ARG SRC_PATH=_Projects_/ps3netsrv

FROM docker.io/library/alpine:${ALPINE_VERSION} AS build
ARG SRC_REPO
ARG SRC_BRANCH
ARG SRC_PATH

WORKDIR /ps3netsrv
RUN set -ex && \
    apk add --update --no-cache \
        git \
        build-base \
        meson \
        mbedtls-dev \
        tar && \
    git clone --depth 1 ${SRC_REPO} src && \
    cd src/${SRC_PATH} && \
    git checkout ${SRC_BRANCH} && \
    meson build --buildtype=release && \
    ninja -C build/

FROM docker.io/library/alpine:${ALPINE_VERSION} AS runtime
ARG SRC_PATH

COPY --from=build /ps3netsrv/src/${SRC_PATH}/build/ps3netsrv /usr/bin/ps3netsrv

RUN set -ex && \
    apk add --no-cache \
        coreutils \
        shadow \
        tzdata \
        libstdc++ \
        mbedtls

VOLUME ["/mnt/PS3"]

EXPOSE 38008

CMD ["/usr/bin/ps3netsrv", "/mnt/PS3"]