#!/bin/bash
set -e

CONTAINERS_REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export CONTAINERS_REPO_DIR
export CONTAINERS_SRC_DIR="$CONTAINERS_REPO_DIR/rootless"
export CONTAINERS_SYSTEMD_DIR="$HOME/.config/containers/systemd/atxoft"
export CONTAINERS_CONFIG_DIR="$HOME/.config/atxoft"

export CONTAINERS_SECRETS=(
    # @Bookmarks
    atbookmarks_karakeep_api_key atbookmarks_postgres_password

    # Caddy
    caddy_crypto_key_id caddy_crypto_shared_key

    # Cloudflared Tunnel
    cloudflared_tunnel_token

    # ConvertX
    convertx_jwt_secret

    # Hydroxide
    hydroxide_user

    # Immich
    immich_postgres_password

    # Invidious
    invidious_companion_key invidious_postgres_password

    # Karakeep
    karakeep_nextauth_secret karakeep_meili_master_key karakeep_smtp_from

    # n8n
    n8n_smtp_sender

    # pgAdmin
    pgadmin_default_email pgadmin_default_password pgadmin_config_mail_sender

    # Postgres
    postgres_password

    # Pterodactyl
    pterodactyl_service_author pterodactyl_mysql_password pterodactyl_mysql_root_password pterodactyl_mail_from

    # Red Discord Bot
    red_bot_token

    # Shlink
    shlink_postgres_password shlink_geolite_license_key
)
