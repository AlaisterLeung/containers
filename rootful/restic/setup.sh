#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

bin/restic-root.sh init
bin/restic-share.sh init
