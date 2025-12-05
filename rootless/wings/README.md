# Pterodactyl Wings daemon running in rootless Podman container

## Known Issues

- **`Enable OOM Killer`** must be checked during server creation

## Required Setup

### Directory creation

```bash
mkdir -p $HOME/.local/share/pterodactyl
```

### System configuration

Enable CPU, CPUSET, and I/O delegation:
```bash
sudo mkdir -p /etc/systemd/system/user@.service.d
cat <<EOF | sudo tee /etc/systemd/system/user@.service.d/delegate.conf
[Service]
Delegate=cpu cpuset io memory pids
EOF
sudo systemctl daemon-reload
sudo reboot
```

After reboot, confirm the change:
```bash
cat /sys/fs/cgroup/user.slice/user-$(id -u).slice/user@$(id -u).service/cgroup.controllers
```

### Pterodactyl node config.yml

- Set **`Daemon Server File Directory`** to `/home/pod_user/.local/share/pterodactyl`
- Under **`system.user.rootless`**, set:
  - `enabled` to `true`
  - both `container_uid` and `container_gid` to `988`
- Set **`docker.log_config.type`** to `json-file`
