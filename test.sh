#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
QUADLET_UNIT_DIRS="$REPO_DIR" /lib/systemd/user-generators/podman-user-generator -user -dryrun >/dev/null
