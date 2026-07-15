FROM docker.io/thelande/steam-base-container:sha-dc98ed4ace7b5bd8740dc42e61e2cb45a6abc62d
# FROM steam-base-container:2026.07.14

ENV APP_ID=294420 \
    APP_NAME="7 Days to Die Dedicated Server"

COPY --chmod=0755 start-server.sh stop-server.sh /

EXPOSE 26900/tcp 26900-26903/udp 8080-8081/tcp
