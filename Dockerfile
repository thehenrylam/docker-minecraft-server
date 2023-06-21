# syntax = docker/dockerfile:1.3

ARG BASE_IMAGE=eclipse-temurin:17-jre-focal
FROM ${BASE_IMAGE}

# hook into docker BuildKit --platform support
# see https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

# CI system should set this to a hash or git revision of the build directory and it's contents to
# ensure consistent cache updates.
ARG BUILD_FILES_REV=1
RUN --mount=target=/build,source=build \
    REV=${BUILD_FILES_REV} TARGET=${TARGETARCH}${TARGETVARIANT} /build/run.sh install-packages

RUN --mount=target=/build,source=build \
    REV=${BUILD_FILES_REV} /build/run.sh setup-user

COPY --chmod=644 files/sudoers* /etc/sudoers.d

EXPOSE 25565

ARG EASY_ADD_VER=0.7.1
ADD https://github.com/itzg/easy-add/releases/download/${EASY_ADD_VER}/easy-add_${TARGETOS}_${TARGETARCH}${TARGETVARIANT} /usr/bin/easy-add
RUN chmod +x /usr/bin/easy-add

RUN easy-add --var os=${TARGETOS} --var arch=${TARGETARCH}${TARGETVARIANT} \
  --var version=1.2.0 --var app=restify --file {{.app}} \
  --from https://github.com/itzg/{{.app}}/releases/download/{{.version}}/{{.app}}_{{.version}}_{{.os}}_{{.arch}}.tar.gz

RUN easy-add --var os=${TARGETOS} --var arch=${TARGETARCH}${TARGETVARIANT} \
  --var version=1.6.1 --var app=rcon-cli --file {{.app}} \
  --from https://github.com/itzg/{{.app}}/releases/download/{{.version}}/{{.app}}_{{.version}}_{{.os}}_{{.arch}}.tar.gz

RUN easy-add --var os=${TARGETOS} --var arch=${TARGETARCH}${TARGETVARIANT} \
  --var version=0.11.0 --var app=mc-monitor --file {{.app}} \
  --from https://github.com/itzg/{{.app}}/releases/download/{{.version}}/{{.app}}_{{.version}}_{{.os}}_{{.arch}}.tar.gz

RUN easy-add --var os=${TARGETOS} --var arch=${TARGETARCH}${TARGETVARIANT} \
  --var version=1.8.3 --var app=mc-server-runner --file {{.app}} \
  --from https://github.com/itzg/{{.app}}/releases/download/{{.version}}/{{.app}}_{{.version}}_{{.os}}_{{.arch}}.tar.gz

RUN easy-add --var os=${TARGETOS} --var arch=${TARGETARCH}${TARGETVARIANT} \
  --var version=0.1.1 --var app=maven-metadata-release --file {{.app}} \
  --from https://github.com/itzg/{{.app}}/releases/download/{{.version}}/{{.app}}_{{.version}}_{{.os}}_{{.arch}}.tar.gz

ARG MC_HELPER_VERSION=1.32.3
ARG MC_HELPER_BASE_URL=https://github.com/itzg/mc-image-helper/releases/download/${MC_HELPER_VERSION}
# used for cache busting local copy of mc-image-helper
ARG MC_HELPER_REV=1
RUN curl -fsSL ${MC_HELPER_BASE_URL}/mc-image-helper-${MC_HELPER_VERSION}.tgz \
  | tar -C /usr/share -zxf - \
  && ln -s /usr/share/mc-image-helper-${MC_HELPER_VERSION}/bin/mc-image-helper /usr/bin

VOLUME ["/data"]
WORKDIR /data

STOPSIGNAL SIGTERM

# End user MUST set EULA and change RCON_PASSWORD
ENV TYPE=VANILLA VERSION=LATEST EULA="TRUE" UID=1000 GID=1000
# ENV TYPE=VANILLA VERSION=LATEST EULA="TRUE" UID=1000 GID=1000 RCON_PASSWORD=680f9d3c8a9da7d84f01e9dff1598200

COPY --chmod=755 scripts/start* /
COPY --chmod=755 bin/ /usr/local/bin/
COPY --chmod=755 bin/mc-health /health.sh
COPY --chmod=644 files/log4j2.xml /image/log4j2.xml
# By default this file gets retrieved from repo, but bundle in image as potential fallback
COPY --chmod=644 files/cf-exclude-include.json /image/cf-exclude-include.json
COPY --chmod=755 files/auto /auto

RUN curl -fsSL -o /image/Log4jPatcher.jar https://github.com/CreeperHost/Log4jPatcher/releases/download/v1.0.1/Log4jPatcher-1.0.1.jar

RUN dos2unix /start* /auto/*

ENTRYPOINT [ "/start" ]
HEALTHCHECK --start-period=1m --interval=5s --retries=24 CMD mc-health

RUN dpkg --add-architecture i386
RUN apt update
RUN apt -y install wine
RUN apt -y install wine32


