#!/bin/bash
#
set -eux

cd "$INSTALL_DIR"
export LD_LIBRARY_PATH=.

TS="$(date +%Y-%m-%d__%H-%M-%S)"
LOGFILE="$INSTALL_DIR/7DaysToDieServer_Data/output_log__${TS}.txt"
touch "$LOGFILE"

tail -f "$LOGFILE" &

./7DaysToDieServer.x86_64 \
    -logfile "$LOGFILE" \
    -configfile=serverconfig.xml \
    -quit \
    -batchmode \
    -nographics \
    -dedicated
