#!/usr/bin/env bash
set -Eeuo pipefail

APP_DIR="/opt/lex_penal/app"
SHARED_DIR="/opt/lex_penal/shared"
OPS_DIR="$SHARED_DIR/ops"
EVID_DIR="$OPS_DIR/evidencias"
QUAR_DIR="$OPS_DIR/quarantine"
BACKUP_DIR="$OPS_DIR/backups"
STAMP="$(date +%Y%m%d_%H%M%S)"

mkdir -p "$EVID_DIR" "$QUAR_DIR" "$BACKUP_DIR"

echo "=== FECHA ==="
date -Is

echo
echo "=== PRECHECK ==="
whoami
hostname
test -d "$APP_DIR/.git"
test -f "$SHARED_DIR/.env"

echo
echo "=== RESPALDOS MINIMOS ==="
cp -a /etc/systemd/system/lex-penal.service "$BACKUP_DIR/lex-penal.service.$STAMP.bak"
cp -a /etc/nginx/sites-enabled/00-default-ssl.conf "$BACKUP_DIR/00-default-ssl.conf.$STAMP.bak"
cp -a "$SHARED_DIR/.env" "$BACKUP_DIR/.env.$STAMP.bak"

echo
echo "=== CUARENTENA DE UNTRACKED ==="
cd "$APP_DIR"
if git ls-files --others --exclude-standard | grep -q .; then
  mkdir -p "$QUAR_DIR/$STAMP/files"
  git ls-files --others --exclude-standard -z \
    | tar --null -T - -czf "$QUAR_DIR/$STAMP/untracked_repo_backup.tar.gz"

  while IFS= read -r f; do
    [ -n "$f" ] || continue
    mkdir -p "$QUAR_DIR/$STAMP/files/$(dirname "$f")"
    mv "$f" "$QUAR_DIR/$STAMP/files/$f"
    echo "MOVIDO: $f"
  done < <(git ls-files --others --exclude-standard)
else
  echo "SIN_UNTRACKED"
fi

echo
echo "=== SYNC REPO ==="
git fetch --all --prune
git checkout main
git pull --ff-only origin main
git rev-parse --short HEAD

echo
echo "=== BUILD ==="
npm ci
npm run build

echo
echo "=== RESTART ==="
systemctl daemon-reload
systemctl restart lex-penal.service
sleep 4
systemctl status lex-penal.service --no-pager

echo
echo "=== SMOKE LOCAL LOGIN ==="
curl -sS -i -X POST http://127.0.0.1:3010/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d "{}" || true

echo
echo "=== SMOKE NGINX LOGIN ==="
curl -k -sS -i -X POST https://127.0.0.1/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d "{}" || true

echo
echo "=== COMMIT FINAL ==="
git rev-parse --short HEAD

echo
echo "=== OPS DIR ==="
find "$OPS_DIR" -maxdepth 3 -type f | sort || true
