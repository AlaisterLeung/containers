#!/bin/sh
set -e

restic backup --exclude-file=/etc/restic/excludes.txt /host/share
restic forget --keep-daily 7 --keep-weekly 2 --prune
restic check
