#!/bin/bash

# Load required kernel modules on boot
sudo cp -f /etc/containers/systemd/atxoft/wg/wg-easy.conf /etc/modules-load.d/wg-easy.conf
