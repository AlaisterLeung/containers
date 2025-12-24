#!/bin/bash

podman run --rm -v gluetun:/gluetun docker.io/qmcgaw/gluetun:v3 "$@"
