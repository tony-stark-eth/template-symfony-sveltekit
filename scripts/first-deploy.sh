#!/usr/bin/env bash
# ── First-time deployment to a fresh Hetzner server ─────────────────────────
#
# This script automates the entire initial deployment:
#   1. Upload SSH key to Hetzner (if not exists)
#   2. Provision infrastructure via OpenTofu
#   3. Wait for cloud-init (Docker installation)
#   4. Clone repo, generate secrets, configure .env
#   5. Generate JWT keys
#   6. Build + start the production stack
#   7. Fix Caddy volume permissions for TLS
#   8. Deploy GlitchTip, run migrations, create admin + project
#   9. Wire SENTRY_DSN into the app
#  10. Set GitHub Actions secrets for CD pipeline
#
# Prerequisites:
#   - HETZNER_API_KEY in .env.local (project root)
#   - SSH key at ~/.ssh/id_ed25519 (or id_rsa)
#   - OpenTofu installed (tofu --version)
#   - GitHub CLI authenticated (gh auth status)
#   - Domain ready to point to the server IP
#
# Usage:
#   ./scripts/first-deploy.sh <domain> <project-name> [github-repo]
#
# Example:
#   ./scripts/first-deploy.sh smart-habit.tony-stark.xyz smarthabit tony-stark-eth/my-project

set -euo pipefail

# ── Args ─────────────────────────────────────────────────────────────────────
DOMAIN="${1:?Usage: $0 <domain> <project-name> [github-repo]}"
PROJECT_NAME="${2:?Usage: $0 <domain> <project-name> [github-repo]}"
GITHUB_REPO="${3:-$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo '')}"
DEPLOY_DIR="/opt/${PROJECT_NAME}"

# ── Resolve paths ────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── Load Hetzner API key ────────────────────────────────────────────────────
if [[ -f "$ROOT_DIR/.env.local" ]]; then
    HETZNER_API_KEY=$(grep '^HETZNER_API_KEY=' "$ROOT_DIR/.env.local" | cut -d'"' -f2 | head -1)
fi
if [[ -z "${HETZNER_API_KEY:-}" ]]; then
    echo "ERROR: HETZNER_API_KEY not found in .env.local"
    exit 1
fi

# ── Find SSH key ─────────────────────────────────────────────────────────────
SSH_KEY_FILE="${HOME}/.ssh/id_ed25519"
if [[ ! -f "$SSH_KEY_FILE" ]]; then
    SSH_KEY_FILE="${HOME}/.ssh/id_rsa"
fi
if [[ ! -f "$SSH_KEY_FILE" ]]; then
    echo "ERROR: No SSH key found at ~/.ssh/id_ed25519 or ~/.ssh/id_rsa"
    exit 1
fi
SSH_PUB_KEY=$(cat "${SSH_KEY_FILE}.pub")
echo "Using SSH key: ${SSH_KEY_FILE}"

# ── Check prerequisites ─────────────────────────────────────────────────────
command -v tofu >/dev/null 2>&1 || { echo "ERROR: tofu not found. Install OpenTofu first."; exit 1; }
command -v gh >/dev/null 2>&1 || { echo "ERROR: gh not found. Install GitHub CLI first."; exit 1; }
if [[ -z "$GITHUB_REPO" ]]; then
    echo "ERROR: Could not detect GitHub repo. Pass it as 3rd argument."
    exit 1
fi
echo "GitHub repo: $GITHUB_REPO"

# ── Step 1: Upload SSH key to Hetzner ────────────────────────────────────────
echo ""
echo "=== Step 1: SSH Key ==="
SSH_KEY_NAME=$(hostname)
SSH_KEY_ID=$(curl -sf -H "Authorization: Bearer $HETZNER_API_KEY" \
    https://api.hetzner.cloud/v1/ssh_keys \
    | python3 -c "import sys,json; keys=json.load(sys.stdin)['ssh_keys']; matches=[k['id'] for k in keys if k['public_key'].strip()=='''${SSH_PUB_KEY}'''.strip()]; print(matches[0] if matches else '')" 2>/dev/null || echo "")

if [[ -z "$SSH_KEY_ID" ]]; then
    echo "Uploading SSH key to Hetzner..."
    SSH_KEY_ID=$(curl -sf -H "Authorization: Bearer $HETZNER_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"${SSH_KEY_NAME}\",\"public_key\":\"${SSH_PUB_KEY}\"}" \
        https://api.hetzner.cloud/v1/ssh_keys \
        | python3 -c "import sys,json; print(json.load(sys.stdin)['ssh_key']['id'])")
    echo "SSH key uploaded: ID $SSH_KEY_ID"
else
    echo "SSH key already exists: ID $SSH_KEY_ID"
fi

# ── Step 2: Provision infrastructure ─────────────────────────────────────────
echo ""
echo "=== Step 2: Infrastructure ==="
cd "$ROOT_DIR/infrastructure"

cat > terraform.tfvars <<EOF
project_name   = "${PROJECT_NAME}"
server_type    = "cx23"
location       = "fsn1"
ssh_key_ids    = [${SSH_KEY_ID}]
volume_size_gb = 20
EOF

export TF_VAR_hcloud_token="$HETZNER_API_KEY"
tofu init -input=false
tofu apply -auto-approve -input=false

SERVER_IP=$(tofu output -raw server_ipv4)
echo ""
echo "Server IP: $SERVER_IP"
echo "Point your domain '$DOMAIN' A record to $SERVER_IP"

# ── Step 3: Wait for cloud-init ──────────────────────────────────────────────
echo ""
echo "=== Step 3: Waiting for server setup ==="
ssh-keyscan -H "$SERVER_IP" >> ~/.ssh/known_hosts 2>/dev/null

echo "Waiting for cloud-init to finish (Docker installation)..."
# cloud-init may report 'error' due to volume mount race — check Docker instead
for i in $(seq 1 60); do
    if ssh -o ConnectTimeout=5 "root@${SERVER_IP}" "docker --version" >/dev/null 2>&1; then
        echo "Docker is ready."
        break
    fi
    echo "  waiting... ($i/60)"
    sleep 10
done

ssh "root@${SERVER_IP}" "docker --version && docker compose version"

# ── Step 4: Generate secrets ─────────────────────────────────────────────────
echo ""
echo "=== Step 4: Generate secrets ==="
APP_SECRET=$(openssl rand -hex 32)
POSTGRES_PASSWORD=$(openssl rand -base64 24 | tr -dc 'a-zA-Z0-9' | head -c 32)
MERCURE_SECRET=$(openssl rand -hex 32)
JWT_PASSPHRASE=$(openssl rand -hex 16)
O2_ROOT_PASSWORD=$(openssl rand -base64 24 | tr -dc 'a-zA-Z0-9' | head -c 24)

# ── Step 5: Clone and configure ──────────────────────────────────────────────
echo ""
echo "=== Step 5: Clone and configure ==="
ssh "root@${SERVER_IP}" "git clone https://github.com/${GITHUB_REPO}.git ${DEPLOY_DIR}"

# Create .env for compose variable interpolation (POSTGRES_PASSWORD)
ssh "root@${SERVER_IP}" "cat > ${DEPLOY_DIR}/.env << 'EOF'
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
O2_ROOT_EMAIL=admin@${DOMAIN}
O2_ROOT_PASSWORD=${O2_ROOT_PASSWORD}
O2_AUTH_TOKEN=$(echo -n "admin@${DOMAIN}:${O2_ROOT_PASSWORD}" | base64)
EOF"

# Create .env.local for Symfony
ssh "root@${SERVER_IP}" "cat > ${DEPLOY_DIR}/.env.local << 'EOF'
APP_ENV=prod
APP_DEBUG=0
APP_SECRET=${APP_SECRET}
DATABASE_URL=postgresql://app:${POSTGRES_PASSWORD}@pgbouncer:5432/app?serverVersion=17&sslmode=disable&charset=utf8
MESSENGER_TRANSPORT_DSN=doctrine://default?auto_setup=true
MERCURE_URL=https://php/.well-known/mercure
MERCURE_PUBLIC_URL=/.well-known/mercure
MERCURE_JWT_SECRET=${MERCURE_SECRET}
JWT_PASSPHRASE=${JWT_PASSPHRASE}
JWT_TOKEN_TTL=3600
MAILER_DSN=smtp://resend:re_YOUR_API_KEY@smtp.resend.com:465
SERVER_NAME=${DOMAIN}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
VAPID_PUBLIC_KEY=
VAPID_PRIVATE_KEY=
NTFY_SERVER_URL=http://ntfy:80
APNS_TEAM_ID=
APNS_KEY_ID=
APNS_PRIVATE_KEY_PATH=
APNS_BUNDLE_ID=
APNS_ENVIRONMENT=production
EOF"

# Generate JWT keys
echo "Generating JWT keys..."
ssh "root@${SERVER_IP}" "mkdir -p ${DEPLOY_DIR}/backend/config/jwt && \
    openssl genpkey -algorithm RSA -out ${DEPLOY_DIR}/backend/config/jwt/private.pem -aes256 -pass pass:${JWT_PASSPHRASE} 2>/dev/null && \
    openssl rsa -in ${DEPLOY_DIR}/backend/config/jwt/private.pem -pubout -out ${DEPLOY_DIR}/backend/config/jwt/public.pem -passin pass:${JWT_PASSPHRASE} 2>/dev/null && \
    chown -R 1001:1001 ${DEPLOY_DIR}/backend/config/jwt"
echo "JWT keys generated."

# ── Step 6: Build and start ──────────────────────────────────────────────────
echo ""
echo "=== Step 6: Build and start ==="
ssh "root@${SERVER_IP}" "cd ${DEPLOY_DIR} && docker compose -f compose.yaml -f compose.prod.yaml build php"
ssh "root@${SERVER_IP}" "cd ${DEPLOY_DIR} && docker compose -f compose.yaml -f compose.prod.yaml up -d"

# ── Step 7: Fix Caddy permissions for TLS ────────────────────────────────────
echo ""
echo "=== Step 7: Fix Caddy TLS permissions ==="
echo "Waiting for containers to start..."
sleep 15
ssh "root@${SERVER_IP}" "docker exec -u root ${PROJECT_NAME}-php-1 sh -c 'mkdir -p /data/caddy /config/caddy && chown -R 1001:1001 /data /config'"
ssh "root@${SERVER_IP}" "cd ${DEPLOY_DIR} && docker compose -f compose.yaml -f compose.prod.yaml restart php"

# Wait for health check
echo "Waiting for health check..."
for i in $(seq 1 12); do
    sleep 10
    if ssh "root@${SERVER_IP}" "docker exec ${PROJECT_NAME}-php-1 curl -sf http://localhost:8080/api/v1/health" 2>/dev/null; then
        echo ""
        echo "App is healthy!"
        break
    fi
    echo "  waiting... ($i/12)"
done

# ── Step 8: OpenObserve (observability) ────────────────────────────────────
echo ""
echo "=== Step 8: OpenObserve ==="
echo "OpenObserve starts automatically with the app stack (compose.prod.yaml)."
echo "  Admin:    admin@${DOMAIN}"
echo "  Password: ${O2_ROOT_PASSWORD}"
echo "  UI:       http://${SERVER_IP}:5080"
echo "  Frontend: https://${DOMAIN}/o2/ (browser SDK telemetry)"

# Rebuild image with frontend OpenObserve endpoint baked into the JS bundle
O2_ENDPOINT="https://${DOMAIN}/o2"
echo ""
echo "=== Step 9: Rebuild with frontend telemetry endpoint ==="
ssh "root@${SERVER_IP}" "cd ${DEPLOY_DIR} && docker compose -f compose.yaml -f compose.prod.yaml build --no-cache --build-arg 'VITE_O2_ENDPOINT=${O2_ENDPOINT}' php"
ssh "root@${SERVER_IP}" "cd ${DEPLOY_DIR} && docker compose -f compose.yaml -f compose.prod.yaml up -d --force-recreate"

# Fix Caddy permissions after recreate
sleep 10
ssh "root@${SERVER_IP}" "docker exec -u root ${PROJECT_NAME}-php-1 sh -c 'mkdir -p /data/caddy /config/caddy && chown -R 1001:1001 /data /config' 2>/dev/null || true"
ssh "root@${SERVER_IP}" "cd ${DEPLOY_DIR} && docker compose -f compose.yaml -f compose.prod.yaml restart php"

# Wait for health
echo "Waiting for health check..."
for i in $(seq 1 12); do
    sleep 10
    if ssh "root@${SERVER_IP}" "docker exec ${PROJECT_NAME}-php-1 curl -sf http://localhost:8080/api/v1/health" 2>/dev/null; then
        echo ""
        echo "App is healthy with observability!"
        break
    fi
    echo "  waiting... ($i/12)"
done

# ── Step 10: GitHub secrets ──────────────────────────────────────────────────
echo ""
echo "=== Step 10: GitHub Actions secrets ==="
gh secret set DEPLOY_HOST --body "$SERVER_IP" --repo "$GITHUB_REPO"
gh secret set DEPLOY_USER --body "root" --repo "$GITHUB_REPO"
gh secret set DEPLOY_SSH_KEY < "$SSH_KEY_FILE" --repo "$GITHUB_REPO"
gh secret set VITE_O2_ENDPOINT --body "https://${DOMAIN}/o2" --repo "$GITHUB_REPO"

# Create production environment
gh api "repos/${GITHUB_REPO}/environments/production" -X PUT >/dev/null 2>&1

echo ""
echo "============================================================"
echo "  Deployment complete!"
echo "============================================================"
echo ""
echo "  App:       https://${DOMAIN}"
echo "  GlitchTip: http://${SERVER_IP}:8000"
echo "  GlitchTip: ${ADMIN_EMAIL} / ${ADMIN_PASSWORD}"
echo ""
echo "  Backend DSN:  ${SENTRY_DSN}"
echo "  Frontend DSN: ${FRONTEND_DSN}"
echo ""
echo "  Next steps:"
echo "    1. Point '${DOMAIN}' A record → ${SERVER_IP}"
echo "       (Caddy auto-provisions TLS once DNS resolves)"
echo "    2. Push to main to trigger the CD pipeline"
echo ""
