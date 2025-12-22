#!/bin/bash
set -e

BACKUP_TYPE="$1"

prepare() {
    if [ "$EUID" -eq 0 ]; then
        source ../config/env/rootful.sh
    else
        source ../config/env/rootless.sh
    fi
}

restore_volumes() {
    for volume in "$CONTAINERS_SRC_DIR"/*/*.volume; do
        [ -f "$volume" ] || continue

        volume_name=$(basename "$volume" .volume)

        podman volume exists "$volume_name" && continue

        echo -n "$volume_name"

        podman volume create "$volume_name" &>/dev/null
        import_backup "$volume_name"
    done
}

import_backup() {
    local VOLUME_NAME="$1"

    if ! ./restic.sh "$BACKUP_TYPE" snapshots --path "/$VOLUME_NAME.tar" --latest 1 --quiet | grep -q .; then
        echo " - warning: no backup found!"
        return
    fi

    ./restic.sh "$BACKUP_TYPE" dump latest "/$VOLUME_NAME.tar" --path "/$VOLUME_NAME.tar" |
        podman volume import "$VOLUME_NAME" -

    echo " - done"
}

cd "$(dirname "${BASH_SOURCE[0]}")"

echo "Starting volume restore..."

prepare
restore_volumes

echo "Volume restore completed."
