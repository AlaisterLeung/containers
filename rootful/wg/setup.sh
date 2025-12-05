#!/bin/bash

# Load required kernel modules on boot
sudo ln -sf /etc/containers/systemd/atxoft/wg/wg-easy.conf /etc/modules-load.d/wg-easy.conf
