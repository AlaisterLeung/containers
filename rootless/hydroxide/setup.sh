#!/bin/bash

podman volume create hydroxide

echo "Run 'hydroxide auth USERNAME' and copy the bridge password"

podman run --rm -it --entrypoint bash -v hydroxide:/root/.config/hydroxide registry.gitlab.com/renner0e/hydroxide-podman:latest

echo "Run 'printf <PASSWORD> | podman secret create hydroxide_password -' to store it as Podman secret"
