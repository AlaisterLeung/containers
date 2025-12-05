# My Podman Quadlet Containers

## System Requirements

- Podman 5+

## Setup

First, create a new user:
```bash
sudo useradd -m pod_user
```

### 1. Rootless containers

1.1 Allow rootless containers to listen to ports from 25:
```bash
echo 'net.ipv4.ip_unprivileged_port_start=25' | sudo tee /etc/sysctl.d/99-atxoft.conf
```

1.2 Set up SELinux for DRI devices:
```bash
sudo setsebool -P container_use_dri_devices 1
```

1.3 Login as `pod_user`:
```bash
sudo machinectl shell --uid pod_user
```

1.4 Enable linger:
```bash
loginctl enable-linger pod_user
```

1.5 Enable Podman socket and auto-update timer:
```bash
systemctl --user enable --now podman.socket podman-auto-update.timer
```

1.6 (optional) Log into GitHub Container Registry: (optional)
```bash
podman login --authfile $HOME/.config/containers/auth.json ghcr.io
```

1.7 Clone this repository:
```bash
git clone https://github.com/AlaisterLeung/containers.git
```

1.8 Run the installation script and start the containers:
```bash
cd containers
./install.sh
systemctl --user start CONTAINER_NAME.service
```

1.9 (optional) Set up volume backup:
```bash

```

### 2. Rootful containers

2.1 Login as `root`:
```bash
sudo -i
```

2.2 Enable Podman socket and auto-update timer:
```bash
systemctl enable --now podman.socket podman-auto-update.timer
```

2.3 Clone this repository:
```bash
git clone https://github.com/AlaisterLeung/containers.git
```

2.4 Run the installation script and start the containers:
```bash
cd containers
./install.sh
systemctl start CONTAINER_NAME.service
```

2.5 (optional) Set up volume backup:
```bash

```
