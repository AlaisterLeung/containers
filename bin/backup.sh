#!/bin/bash
set -e

prepare() {
    if [ "$EUID" -eq 0 ]; then
        source ../config/env/rootful.sh
    else
        source ../config/env/rootless.sh
    fi
}

backup_volumes() {
    for volume in "$CONTAINERS_SRC_DIR"/*/*.volume; do
        [ -f "$volume" ] || continue

        volume_name=$(basename "$volume" .volume)

        podman volume exists "$volume_name" || continue

        echo -n "$volume_name"

        backup_export local "$volume_name"
        backup_export remote "$volume_name"

        echo " - done"
    done
}

post_backup() {
    prune_backups local
    check_repo local

    prune_backups remote
    check_repo remote
}

backup_export() {
    local BACKUP_TYPE="$1"
    local VOLUME_NAME="$2"

    ./restic.sh "$BACKUP_TYPE" backup --stdin-filename "$VOLUME_NAME.tar" --stdin-from-command -- \
        podman volume export "$VOLUME_NAME"
}

prune_backups() {
    ./restic.sh "$1" forget --keep-daily 30 --keep-monthly 6 --prune
}

check_repo() {
    ./restic.sh "$1" check
}

cd "$(dirname "${BASH_SOURCE[0]}")"

echo "Starting volume backup..."

prepare
backup_volumes
post_backup

echo "Volume backup completed."
