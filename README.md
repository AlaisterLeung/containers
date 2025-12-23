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

Create a new user, and set up user memory limit:
```bash
sudo useradd -m pod_user
sudo systemctl edit --force --full user-$(id -u pod_user).slice
sudo systemctl daemon-reload
```

```ini
[Slice]
MemoryHigh=85%
MemoryMax=90%
```

Login as `pod_user` to complete the installation:
```bash
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

Clone this repository and run the installation script:
```bash
git clone https://github.com/AlaisterLeung/containers.git
cd containers
bin/install.sh
```

**⚠️ Security Notice:** Before starting containers, please review and update placeholder secrets:
- See `SECURITY_GUIDE.md` for detailed instructions
- Update placeholder values in `rootless/invidious/config.yml` and `rootless/privatebin/conf.php.ini`

After editing config files in `$HOME/.config/atxoft` and executing setup scripts `rootless/NAME/setup.sh`, start the containers:
```bash
systemctl --user start NAME.service
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

Clone this repository and run the installation script:
```bash
git clone https://github.com/AlaisterLeung/containers.git
cd containers
bin/install.sh
```

**⚠️ Security Notice:** Before starting containers, please review and update placeholder secrets:
- See `SECURITY_GUIDE.md` for detailed instructions
- Update placeholder values in configuration files as needed

After editing config files in `/etc/atxoft` and executing setup scripts `rootful/NAME/setup.sh`, start the containers:
```bash
systemctl start NAME.service
```

## Updating

Simply `git pull && bin/install.sh` and restart updated containers via systemd

## Volume Backup

### Setup Restic repos

Run as `root`, create local backup directory and copy the config files:
```bash
mkdir -p /var/backup/containers /etc/atxoft/backup
chown -R pod_user:pod_user /var/backup
cp config/backup/*.env /etc/atxoft/backup
```

After editing the config files `/etc/atxoft/backup/*.env`, initialize Restic repos:
```bash
bin/restic.sh local init
bin/restic.sh remote init
```

### Restore backup

Run as `pod_user` and `root` for rootless and rootful container volumes respectively:
```bash
bin/restore.sh <local|remote>
```

## Security

This repository implements secure secret management using Podman secrets. **No actual credentials are stored in this repository.**

### Important Security Notes

1. **Before deployment:** Update placeholder values in configuration files (marked with `TODO: CHANGE`)
   - `rootless/invidious/config.yml` - database password, companion key, HMAC key
   - `rootless/privatebin/conf.php.ini` - Shlink API key

2. **Secret Management:** All secrets are managed through Podman secrets, entered during installation

3. **Documentation:** See `SECURITY_GUIDE.md` for:
   - Complete list of required secrets
   - How to generate strong secrets
   - Secret rotation procedures
   - Emergency response for leaked secrets

4. **Security Audit:** See `SECURITY_AUDIT_REPORT.md` for the latest security audit results

### Preventing Secret Leaks

- A `.gitignore` file is included to prevent accidental commits of sensitive files
- Never commit files containing actual passwords or API keys
- Use the Podman secrets system (already implemented)
- Review `SECURITY_GUIDE.md` for best practices

