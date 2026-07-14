#!/bin/bash
#
# Sends a SIGINT to the server to gracefully stop since Kubernetes only sends
# SIGTERM when a pod is killed.
#
set -e

# Find the PID of the server.
SVRPID="$(pgrep -f 7DaysToDieServer.x86_64)"
if [[ -z "$SVRPID" ]]; then
    echo "warning: failed to find PID of 7DaysToDieServer.x86_64"
    exit 0
fi

# Send SIGINT to the server.
kill -SIGINT $SVRPID
