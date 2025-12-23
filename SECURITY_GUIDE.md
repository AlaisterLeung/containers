# Security Guide: Managing Secrets in this Repository

## Overview

This repository implements a secure secret management system using **Podman secrets**. No actual credentials should ever be committed to the repository.

## ⚠️ Before Deployment: Configure Placeholder Secrets

Several configuration files contain placeholder values that **MUST** be changed before production use:

### 1. Invidious Configuration

Edit `rootless/invidious/config.yml`:

```bash
# Generate a 16-character random key for Invidious companion
pwgen 16 1  # or use: openssl rand -hex 8

# Generate a 20-character random key for HMAC
pwgen 20 1  # or use: openssl rand -hex 10
```

Update these lines:
- Line 14: `password: ""` - Add your PostgreSQL password
- Line 105: `invidious_companion_key: ""` - Add generated 16-char key
- Line 526: `hmac_key: ""` - Add generated 20-char key

### 2. PrivateBin Configuration

Edit `rootless/privatebin/conf.php.ini`:

- Line 218: `apikey = "your_api_key"` - Replace with your actual Shlink API key

## How Secrets are Managed

### Installation Process

When you run `bin/install.sh`, the script will:

1. Prompt you to enter each required secret
2. Store secrets securely using Podman secrets
3. Secrets are never written to disk in plain text
4. Secrets are only accessible to authorized containers

### Required Secrets

#### Rootless Containers
Defined in `config/env/rootless.sh`:

- **@Bookmarks**: `atbookmarks_karakeep_api_key`, `atbookmarks_postgres_password`
- **Caddy**: `caddy_crypto_key_id`, `caddy_crypto_shared_key`
- **Cloudflared**: `cloudflared_tunnel_token`
- **ConvertX**: `convertx_jwt_secret`
- **Hydroxide**: `hydroxide_user`
- **Immich**: `immich_postgres_password`
- **Invidious**: `invidious_companion_key`, `invidious_postgres_password`
- **Karakeep**: `karakeep_nextauth_secret`, `karakeep_meili_master_key`, `karakeep_smtp_from`
- **n8n**: `n8n_smtp_sender`
- **Postgres**: `postgres_password`
- **Pterodactyl**: `pterodactyl_service_author`, `pterodactyl_mysql_password`, `pterodactyl_mysql_root_password`, `pterodactyl_mail_from`
- **Red Discord Bot**: `red_bot_token`
- **Shlink**: `shlink_postgres_password`, `shlink_geolite_license_key`

#### Rootful Containers
Defined in `config/env/rootful.sh`:

- **Restic**: AWS credentials and repository passwords

## Best Practices

### 1. Never Commit Secrets

- ✅ Use Podman secrets (already implemented)
- ✅ Use environment variables
- ❌ Never hardcode passwords in config files
- ❌ Never commit `.env.local` files

### 2. Generate Strong Secrets

```bash
# Generate random passwords
openssl rand -base64 32

# Generate random keys (Linux)
pwgen 32 1

# Generate UUID for tokens
uuidgen
```

### 3. Rotate Secrets Regularly

To update a secret:

```bash
# For rootless containers
podman secret rm <secret_name>
echo "new_secret_value" | podman secret create <secret_name> -

# For rootful containers
sudo podman secret rm <secret_name>
echo "new_secret_value" | sudo podman secret create <secret_name> -

# Restart affected services
systemctl --user restart <service_name>
# or
sudo systemctl restart <service_name>
```

### 4. Backup Secrets Securely

If you need to backup secrets:

```bash
# Export secrets (be careful with this!)
podman secret inspect <secret_name> > /secure/location/secret.json

# Encrypt the backup
gpg --symmetric --cipher-algo AES256 /secure/location/secret.json

# Store encrypted backup securely
# Delete unencrypted version
rm /secure/location/secret.json
```

### 5. Use .gitignore

A `.gitignore` file is included to prevent accidental commits. It excludes:
- Private keys and certificates
- Local configuration overrides
- Backup files
- Database dumps
- Any files with 'secret' or 'credential' in the name

## Checking for Leaked Secrets

### Manual Check

```bash
# Check for common secret patterns (actual values, not empty strings)
grep -r -E "(password|passwd|api_key|apikey|secret|token)\s*[:=]\s*['\"]?[^'\"[:space:]]{8,}['\"]?" \
  --include="*.env" --include="*.conf" --include="*.yaml" --include="*.yml" --include="*.json"

# Check git history
git log --all -S 'password' --pretty=format:'%H %an %ad %s'
```

### Automated Tools

Install and use secret scanning tools:

```bash
# git-secrets (prevents commits with secrets)
git clone https://github.com/awslabs/git-secrets.git
cd git-secrets
make install
git secrets --install
git secrets --register-aws

# gitleaks (scans for secrets)
docker run -v $(pwd):/path zricethezav/gitleaks:latest \
  detect --source="/path" -v

# TruffleHog (finds secrets in git history)
docker run --rm -v $(pwd):/repo trufflesecurity/trufflehog:latest \
  git file:///repo --json
```

## Emergency: Secret Leaked in Git History

If you accidentally commit a secret:

1. **Immediately rotate the secret** (change passwords, revoke tokens)
2. **Remove from git history:**

```bash
# Use git-filter-repo (recommended)
git filter-repo --path <file-with-secret> --invert-paths

# Or use BFG Repo-Cleaner
bfg --delete-files <file-with-secret>
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Force push (this rewrites history!)
git push --force --all
```

3. **Notify relevant parties** about the compromised secret
4. **Review access logs** for unauthorized access
5. **Update security audit** to prevent future leaks

## Container Access to Secrets

Secrets are mounted into containers via Quadlet configuration:

```ini
[Container]
Secret=secret_name,type=env,target=ENV_VAR_NAME
```

This ensures:
- Secrets are not visible in `podman inspect`
- Secrets are not stored in container layers
- Secrets are only in memory, not on disk

## Monitoring and Auditing

### List All Secrets

```bash
# Rootless
podman secret ls

# Rootful
sudo podman secret ls
```

### Inspect Secret Metadata (not the value)

```bash
podman secret inspect <secret_name>
```

### Check Secret Usage

```bash
# Find which containers use a secret
podman ps -a --format "{{.Names}}" | while read container; do
  podman inspect $container | grep -q "secret_name" && echo $container
done
```

## Additional Resources

- [Podman Secrets Documentation](https://docs.podman.io/en/latest/markdown/podman-secret.1.html)
- [OWASP Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
- [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning/about-secret-scanning)

## Questions?

For security concerns, please:
1. **Do not** create a public GitHub issue
2. Contact the repository maintainer privately
3. Use responsible disclosure practices
