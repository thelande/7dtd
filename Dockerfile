FROM debian:bookworm-slim

ENV APP_ID=294420 \
    DEBIAN_FRONTEND=noninteractive \
    INSTALL_DIR=/app/7-days-to-die \
    TIMEZONE=America/Los_Angeles

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -eux; \
    dpkg --add-architecture i386; \
    sed -i 's/Components: main/Components: main non-free non-free-firmware/g' \
        /etc/apt/sources.list.d/debian.sources; \
    echo steam steam/question select "I AGREE" | debconf-set-selections; \
    apt-get update; \
    apt-get install -y \
        steamcmd \
        ca-certificates \
        tzdata \
        procps \
    ; \
    apt-get autoclean

RUN set -eux; \
    groupadd -g 1000 7days; \
    useradd -m -u 1000 -g 7days -s /bin/bash 7days

COPY --chmod=0755 entrypoint.sh start-server.sh stop-server.sh /

VOLUME [ "/app/7-days-to-die", "/home/7days/.local/share/Steam" ]
EXPOSE 26900/tcp 26900-26903/udp 8080-8081/tcp

STOPSIGNAL SIGINT
ENTRYPOINT [ "/entrypoint.sh" ]
