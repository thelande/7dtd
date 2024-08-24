#!/bin/bash
#
set -eu

PATH=$PATH:/usr/games
DO_VALIDATE="${DO_VALIDATE:-0}"
SKIP_UPDATE="${SKIP_UPDATE:-0}"

mkdir -p "$INSTALL_DIR"
chown -R 7days:7days "$INSTALL_DIR"

echo "Setting timezone to $TIMEZONE"
[[ -f /etc/localtime ]] && rm /etc/localtime
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
echo "$TIMEZONE" > /etc/timezone

if [[ $SKIP_UPDATE -eq 0 ]]; then
    echo "Installing/updating 7 Days to Die Dedicated Server"
    STEAMCMD_OPTS=(+force_install_dir "$INSTALL_DIR" +login anonymous +app_update $APP_ID)
    [[ $DO_VALIDATE -eq 1 ]] && STEAMCMD_OPTS+=(validate)
    STEAMCMD_OPTS+=(+quit)

    chown -R 7days:7days /home/7days
    runuser -l 7days steamcmd "${STEAMCMD_OPTS[@]}"
fi

echo "Starting dedicated server"
cd "$INSTALL_DIR"
runuser -l 7days -w INSTALL_DIR /start-server.sh
