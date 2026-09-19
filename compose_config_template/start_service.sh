#!/usr/bin/env bash
set -euo pipefail

# set ownership and permissions for cron.d directory and files
# cron.d directory must be traversable (x bit), while cron files should be 0644.
mkdir -p /etc/cron.d
chown root:root /etc/cron.d
chmod 0755 /etc/cron.d
find /etc/cron.d -mindepth 1 -maxdepth 1 -type f -exec chown root:root {} +
find /etc/cron.d -mindepth 1 -maxdepth 1 -type f -exec chmod 0644 {} +

# set postgresql password and permissions for initial setup
PG_DIR="/etc/postgresql/16/main"
PG_HBA="$PG_DIR/pg_hba.conf"
PG_MARKER="/var/lib/postgresql/16/main/.postgres_password_initialized"
PG_PASSWORD="${POSTGRES_PASSWORD:-Pa55W0rd}"

# set ownership and permissions for web and postgres directories
chown -R www-data:www-data /var/www/html
chown -R postgres:postgres "$PG_DIR"
mkdir -p /var/log/supervisor /var/run/supervisor

# initialize postgresql password if not already done
if [ ! -f "$PG_MARKER" ]; then
  cat > "$PG_HBA" <<'EOF'
# PostgreSQL Client Authentication Configuration File
# Bootstrap mode: only used for first startup so we can set the password.

local   all             postgres                                peer
local   all             all                                     trust
host    all             all             0.0.0.0/0               trust
host    all             all             ::/0                    trust
local   replication     all                                     peer
host    replication     all             0.0.0.0/0               trust
host    replication     all             ::/0                    trust
EOF
fi

echo "[init] starting postgresql..."
service postgresql start

# wait for postgresql to be ready before setting the password
if [ ! -f "$PG_MARKER" ]; then
  until su - postgres -c "psql -d postgres -tAc 'select 1'" >/dev/null 2>&1; do
    sleep 1
  done

  su - postgres -c "psql -v ON_ERROR_STOP=1 -d postgres -c \"ALTER USER postgres WITH PASSWORD '$PG_PASSWORD';\""

  cat > "$PG_HBA" <<'EOF'
# PostgreSQL Client Authentication Configuration File
# Strict mode: every connection requires password.

local   all             postgres                                scram-sha-256
local   all             all                                     scram-sha-256
host    all             all             0.0.0.0/0               scram-sha-256
host    all             all             ::/0                    scram-sha-256
local   replication     all                                     scram-sha-256
host    replication     all             0.0.0.0/0               scram-sha-256
host    replication     all             ::/0                    scram-sha-256
EOF

  service postgresql reload
  touch "$PG_MARKER"
fi

echo "[init] starting php8.3-fpm..."
service php8.3-fpm start

echo "[init] starting nginx..."
service nginx start

echo "[init] starting cron..."
service cron start

echo "[init] starting supervisord..."
service supervisor start

echo "[init] all services started."
tail -f /dev/null