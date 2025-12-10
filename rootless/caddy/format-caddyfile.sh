#!/bin/bash

podman run --rm -it -v ./conf:/etc/caddy:z docker.io/caddy:2-alpine caddy fmt --overwrite --config /etc/caddy/Caddyfile
