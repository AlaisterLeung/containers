#!/bin/bash
set -e

sudo firewall-cmd --add-port=7359/udp --permanent
sudo firewall-cmd --reload
