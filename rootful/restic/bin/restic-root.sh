#!/bin/bash
set -e

podman run --rm -it \
    -v restic-cache:/root/.cache/restic \
    -s restic_root_repository,type=env,target=RESTIC_REPOSITORY \
    -s restic_root_password,type=env,target=RESTIC_PASSWORD \
    -s restic_aws_access_key_id,type=env,target=AWS_ACCESS_KEY_ID \
    -s restic_aws_secret_access_key,type=env,target=AWS_SECRET_ACCESS_KEY \
    docker.io/restic/restic:latest "$@"
