# My Podman Quadlet Containers

## System Requirements

- Podman 5+

## Installation

### 1. Rootless containers

Modify system configs, enabling binding to port 25, use of DRI devices, and CPU, CPUSET, and IO limit delegation for all users:
```bash
echo 'net.ipv4.ip_unprivileged_port_start=25' | sudo tee /etc/sysctl.d/99-atxoft.conf

sudo setsebool -P container_use_dri_devices 1

sudo mkdir -p /etc/systemd/system/user@.service.d
cat <<EOF | sudo tee /etc/systemd/system/user@.service.d/delegate.conf
[Service]
Delegate=cpu cpuset io memory pids
EOF
```

Re-log and confirm the change:
```bash
cat /sys/fs/cgroup/user.slice/user-$(id -u).slice/user@$(id -u).service/cgroup.controllers
```

Create a new user and login as `pod_user`:
```bash
sudo useradd -m pod_user
sudo machinectl shell --uid pod_user
```

Enable linger, Podman socket and auto-update timer:
```bash
loginctl enable-linger pod_user
systemctl --user enable --now podman.socket podman-auto-update.timer
```

(Optional) Log into GitHub Container Registry:
```bash
podman login --authfile $HOME/.config/containers/auth.json ghcr.io
```

Clone this repository, run the installation script, and start the containers:
```bash
git clone https://github.com/AlaisterLeung/containers.git
cd containers
bin/install.sh
systemctl --user start CONTAINER_NAME.service
```

### 2. Rootful containers

Login as `root`:
```bash
sudo -i
```

Enable Podman socket and auto-update timer:
```bash
systemctl enable --now podman.socket podman-auto-update.timer
```

Clone this repository, run the installation script, and start the containers:
```bash
git clone https://github.com/AlaisterLeung/containers.git
cd containers
bin/install.sh
systemctl start CONTAINER_NAME.service
```

## Updating

Simply `git pull && bin/install.sh` and restart updated containers via systemd

## Volume Backup

### Setup Restic repos

Create local backup directory and copy the config files:
```bash
sudo mkdir -p /var/backup/containers
sudo chown pod_user /var/backup/containers
sudo cp config/backup/local.env /etc/atxoft/backup/local.env
sudo cp config/backup/remote.env /etc/atxoft/backup/remote.env
```

After editing the configs, initialize Restic repos:
```bash
bin/restic.sh local init
bin/restic.sh remote init
```

### Restore backup

Run as `pod_user` and `root` for rootless and rootful container volumes respectively:
```bash
bin/restore.sh <local|remote>
```
