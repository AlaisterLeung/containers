#!/bin/sh
set -e

restic backup --exclude-file=/etc/restic/excludes.txt /host/home-share
restic forget --keep-daily 7 --prune
restic check
