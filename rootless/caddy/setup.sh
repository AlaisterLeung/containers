#!/bin/bash
set -e

sudo mkdir -p /srv/public
sudo chown pod_user:pod_user /srv/public
sudo chmod 777 /srv/public
