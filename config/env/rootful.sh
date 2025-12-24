#!/bin/bash
set -e

CONTAINERS_REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export CONTAINERS_REPO_DIR
export CONTAINERS_SRC_DIR="$CONTAINERS_REPO_DIR/rootful"
export CONTAINERS_SYSTEMD_DIR="/etc/containers/systemd/atxoft"
export CONTAINERS_CONFIG_DIR="/etc/atxoft"

export CONTAINERS_SECRETS=(
    # Gluetun
    gluetun_wireguard_private_key

    # Restic
    restic_aws_access_key_id restic_aws_secret_access_key
    restic_root_repository restic_root_password
    restic_home_share_repository restic_home_share_password
    restic_lj_share_repository restic_lj_share_password
)
