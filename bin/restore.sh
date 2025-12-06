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

        podman volume create "$volume_name"
        import_backup "$volume_name"

        echo " - done"
    done
}

import_backup() {
    local VOLUME_NAME="$1"

    if ! restic.sh "$BACKUP_TYPE" ls latest --quiet "$VOLUME_NAME.tar" &>/dev/null; then
        echo " - warning: no backup found!"
        return
    fi

    restic.sh "$BACKUP_TYPE" restore latest --target - \
        --include "$VOLUME_NAME.tar" | podman volume import "$VOLUME_NAME" -
}

cd "$(dirname "${BASH_SOURCE[0]}")"

echo "Starting volume restore..."

prepare
restore_volumes

echo "Volume restore completed."
