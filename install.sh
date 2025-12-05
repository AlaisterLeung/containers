#!/bin/bash
set -e

prepare() {
    if [ "$EUID" -eq 0 ]; then
        IS_ROOT=true
        source config/env/rootful.sh
    else
        IS_ROOT=false
        source config/env/rootless.sh
    fi

    mkdir -p "$CONTAINERS_SYSTEMD_DIR"
}

install() {
    ln -sf "$CONTAINERS_SRC_DIR" "$CONTAINERS_SYSTEMD_DIR"
}

daemon_reload() {
    if [ "$IS_ROOT" = true ]; then
        sudo systemctl daemon-reload
    else
        systemctl --user daemon-reload
    fi
}

install_config() {
    for config_file in "$CONTAINERS_SRC_DIR"/*/config.*; do
        [ -f "$config_file" ] || continue

        name=$(basename "$(dirname "$config_file")")
        dest_dir="$CONTAINERS_CONFIG_DIR/$name"
        dest_file="$dest_dir/$(basename "$config_file")"

        [ -f "$dest_file" ] && continue

        mkdir -p "$dest_dir"
        cp "$config_file" "$dest_dir/"
    done
}

install_crontab() {
    if [ "$IS_ROOT" = true ]; then
        cron_file="config/cron/rootful.cron"
    else
        cron_file="config/cron/rootless.cron"
    fi

    begin_marker="### BEGIN CONTAINERS CRON JOBS ###"
    end_marker="### END CONTAINERS CRON JOBS ###"

    cron_file_content=$(cat "$cron_file")
    current_crontab=$(crontab -l 2>/dev/null || true)

    if echo "$current_crontab" | grep -q "$begin_marker"; then
        updated_crontab=$(echo "$current_crontab" | sed "/$begin_marker/,/$end_marker/d")
        printf "%s\n%s\n" "$updated_crontab" "$cron_file_content" | crontab -
    else
        printf "%s\n%s\n" "$current_crontab" "$cron_file_content" | crontab -
    fi
}

create_secrets() {
    input_secret() {
        unset secret_value
        prompt="$1: "
        while IFS= read -p "$prompt" -r -s -n 1 char; do
            if [[ $char == $'\0' ]]; then
                break
            fi

            prompt='*'
            secret_value+="$char"
        done
        echo
    }

    for secret in "${CONTAINERS_SECRETS[@]}"; do
        podman secret exists "$secret" && continue

        input_secret "$secret"
        printf "%s" "$secret_value" | podman secret create "$secret" - >/dev/null
    done
}

test_installation() {
    if [ "$IS_ROOT" = true ]; then
        sudo /lib/systemd/system-generators/podman-system-generator -dryrun >/dev/null
    else
        /lib/systemd/user-generators/podman-user-generator -user -dryrun >/dev/null
    fi
}

cd "$(dirname "${BASH_SOURCE[0]}")"

echo "Starting installation..."

prepare
install
daemon_reload
install_config
install_crontab
create_secrets
test_installation

echo "Installation complete."
