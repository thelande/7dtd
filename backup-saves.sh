#!/bin/bash
#
# Backup script for 7 Days to Die dedicated server.
#
set -e

CONFIG_FILE="/app/7-days-to-die/serverconfig.xml"
TMP_BACKUP_DIR=""

function logit {
    local level
    level="$1"
    shift
    printf "%s [%-7s] %s\n" "$(date)" "$level" "$*"
}

function info { logit "info" "$*"; }
function warning { logit "warning" "$*"; }
function error { logit "error" "$*"; exit 1; }

function usage {
    echo "usage: ${0##*/}"
    echo
    echo "Options:"
    echo -e "\t-h\t\tDisplay this help message and exit."
    echo -e "\t-o\t\tRun once and exit."
    echo
    echo "Required environment variables:"
    echo -e "\tSDTD_BACKUP_PATH\tThe base directory into which backups should be stored."
    echo
    echo "Optional environment variables:"
    echo -e "\tSDTD_BACKUP_FREQ\tThe frequency of backups, in minutes [default: 30]."
    echo -e "\tSDTD_MAX_BACKUPS\tThe maximum number of backups to keep [default: 48]."
    echo
}

# Read a configuration value from the configuration file.
# @param field name
function get_config_value {
    local field
    field="$1"
    grep -Po "(?<=<property name=\"$field\" value=\")[^\"]+" "$CONFIG_FILE"
}

# Ensures that the temporary backup directory is removed in the event the script
# exits abnormally.
function cleanup { [[ -n "$TMP_BACKUP_DIR" && -d "$TMP_BACKUP_DIR" ]] && rm -rf "$TMP_BACKUP_DIR"; }
trap cleanup EXIT

RUN_ONCE=0
while getopts "ho" opt; do
    case "$opt" in
        h) usage; exit 0 ;;
        o) RUN_ONCE=1 ;;
        *) usage; exit 2 ;;
    esac
done
shift $((OPTIND - 1))

# Check environment variables
[[ -z "$SDTD_BACKUP_PATH" ]] && { usage; error "SDTD_BACKUP_PATH is not set"; }
SDTD_BACKUP_FREQ="${SDTD_BACKUP_FREQ:-30}"
[[ "$SDTD_BACKUP_FREQ" -gt 0 ]] || { error "SDTD_BACKUP_FREQ must be positive"; }
SDTD_MAX_BACKUPS="${SDTD_MAX_BACKUPS:-48}"
[[ "$SDTD_MAX_BACKUPS" -gt 0 ]] || { error "SDTD_MAX_BACKUPS must be positive"; }

echo "Setting timezone to $TIMEZONE"
[[ -f /etc/localtime ]] && rm /etc/localtime
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
echo "$TIMEZONE" > /etc/timezone

info "SDTD_BACKUP_PATH=$SDTD_BACKUP_PATH"
info "SDTD_BACKUP_FREQ=$SDTD_BACKUP_FREQ"
info "SDTD_MAX_BACKUPS=$SDTD_MAX_BACKUPS"

# Check for required commands
for cmd in rsync tar gzip; do
    command -v $cmd >/dev/null 2>/dev/null || { error "$cmd not installed"; }
done

# Wait for the configuration file to be available.
info "Checking for configuration file: $CONFIG_FILE"
delay=2
while [[ ! -f "$CONFIG_FILE" ]]; do
    warning "Configuration file not found: $CONFIG_FILE"
    warning "Sleeping for $delay seconds."
    sleep $delay
done

USER_DATA_FOLDER="$(get_config_value "UserDataFolder")"
GAME_WORLD="$(get_config_value "GameWorld")"
GAME_NAME="$(get_config_value "GameName")"

GEN_WORLD_PATH="$USER_DATA_FOLDER/GeneratedWorlds/$GAME_WORLD"
SAVE_PATH="$USER_DATA_FOLDER/Saves/$GAME_WORLD/$GAME_NAME"
info "Generated world path: $GEN_WORLD_PATH"
info "Save game path: $SAVE_PATH"

# Check for the number of existing backups and delete the oldest if adding a new
# backup would exceed the maximum.
function cleanup_backups {
    CURR_COUNT="$(find "$SDTD_BACKUP_PATH" -type f | wc -l)"
    info "Number of existing backups: $CURR_COUNT"
    if [[ $CURR_COUNT -lt $SDTD_MAX_BACKUPS ]]; then
        return
    fi

    OLDEST="$(find "$SDTD_BACKUP_PATH" -type f -printf '%T+ %p\n' | sort | head -n 1 | awk '{ print $NF }')"
    warning "Maximum number of backups reached; deleting oldest: $OLDEST"
    rm -f "$OLDEST"
}

function do_backup {
    TMP_BACKUP_DIR="$(mktemp -d)"
    SIZE_OF_WORLD="$(du -sh "$GEN_WORLD_PATH" | awk '{ print $1 }')"
    SIZE_OF_SAVE="$(du -sh "$SAVE_PATH" | awk '{ print $1 }')"

    TS="$(date +"%Y%m%dT%H%M%S")"
    BACKUP_DIRECTORY="$SDTD_BACKUP_PATH/$(date +"%Y/%m/%d")"
    mkdir -p "$BACKUP_DIRECTORY"
    BACKUP_FILE="$BACKUP_DIRECTORY/backup_${TS}.tar.gz"
    BACKUP_PATH="$TMP_BACKUP_DIR/$(basename "$BACKUP_FILE" .tar.gz)"

    info "Generated world size: $SIZE_OF_WORLD"
    info "Save game size: $SIZE_OF_SAVE"
    info "Backup file: $BACKUP_FILE"
    info "Temp backup directory: $BACKUP_PATH"

    info "Starting backup"
    mkdir -p "$BACKUP_PATH/GeneratedWorlds" "$BACKUP_PATH/Saves/$GAME_WORLD"
    rsync -a "$GEN_WORLD_PATH" "$BACKUP_PATH/GeneratedWorlds"
    rsync -a "$SAVE_PATH" "$BACKUP_PATH/Saves/$GAME_WORLD"
    info "Creating archive"
    tar zcf "$BACKUP_PATH.tar.gz" -C "$BACKUP_PATH" .
    cp "$BACKUP_PATH.tar.gz" "$BACKUP_FILE"
    info "Wrote: $BACKUP_FILE"

    rm -rf "$TMP_BACKUP_DIR"
    TMP_BACKUP_DIR=""
}

SLEEP_INTV=$((SDTD_BACKUP_FREQ * 60))
while true; do
    if [[ $RUN_ONCE -eq 0 ]]; then
        info "Sleeping $SLEEP_INTV seconds until next backup."
        sleep $SLEEP_INTV
    fi
    cleanup_backups
    do_backup
    [[ $RUN_ONCE -eq 0 ]] || exit 0
done
