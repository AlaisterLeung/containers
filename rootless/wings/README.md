# Pterodactyl Wings daemon running in rootless Podman container

## Known Issues

- **`Enable OOM Killer`** must be checked during server creation

## Required Setup

### Directory creation

```bash
mkdir -p $HOME/.local/share/pterodactyl
```

### Pterodactyl node config.yml

- Set **`Daemon Server File Directory`** to `/home/pod_user/.local/share/pterodactyl`
- Under **`system.user.rootless`**, set:
  - `enabled` to `true`
  - both `container_uid` and `container_gid` to `988`
- Set **`docker.log_config.type`** to `json-file`
