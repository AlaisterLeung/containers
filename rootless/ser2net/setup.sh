#!/bin/bash
set -e

sudo firewall-cmd --add-port=2000/tcp --permanent
sudo firewall-cmd --reload
