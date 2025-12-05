#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

bin/restic-root.sh init
bin/restic-home-share.sh init
bin/restic-lj-share.sh init
