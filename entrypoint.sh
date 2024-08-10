#!/bin/bash
#
set -eu

PATH=$PATH:/usr/games

mkdir -p "$INSTALL_DIR"
chown 7days:7days "$INSTALL_DIR"

echo "Setting timezone to $TIMEZONE"
[[ -f /etc/localtime ]] && rm /etc/localtime
ln -sf /usr/share/zone/$TIMEZONE /etc/localtime
echo "$TIMEZONE" > /etc/timezone

echo "Installing/updating 7 Days to Die Dedicated Server"
chown -R 7days:7days /home/7days
runuser -l 7days steamcmd +login anonymous \
    +force_install_dir "$INSTALL_DIR" \
    +app_update $APP_ID \
    +quit

echo "Starting dedicated server"
cd "$INSTALL_DIR"
runuser -l 7days -w INSTALL_DIR /start-server.sh
