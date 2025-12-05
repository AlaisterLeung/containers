#!/bin/bash
set -e

sudo mkdir /srv/public
sudo chown "$(id -u):$(id -g)" /srv/public
sudo chmod 755 /srv/public
