#!/bin/sh
set -e

restic backup --exclude-file=/etc/restic/excludes.txt /host/boot /host/etc /host/home /host/opt /host/root /host/srv /host/usr /host/var
restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 3 --prune
restic check
