#!/bin/bash
set -e

podman run --rm -it \
    -v restic-cache:/root/.cache/restic \
    --secret restic_lj_share_repository,type=env,target=RESTIC_REPOSITORY \
    --secret restic_lj_share_password,type=env,target=RESTIC_PASSWORD \
    --secret restic_aws_access_key_id,type=env,target=AWS_ACCESS_KEY_ID \
    --secret restic_aws_secret_access_key,type=env,target=AWS_SECRET_ACCESS_KEY \
    docker.io/restic/restic:latest "$@"
