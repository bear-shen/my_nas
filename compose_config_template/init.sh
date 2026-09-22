#!/usr/bin/env bash
set -euo pipefail
# 初始化脚本

# 设置 cron.d 目录和文件的权限
mkdir -p /etc/cron.d
chown root:root /etc/cron.d
chmod 0755 /etc/cron.d
find /etc/cron.d -mindepth 1 -maxdepth 1 -type f -exec chown root:root {} +
find /etc/cron.d -mindepth 1 -maxdepth 1 -type f -exec chmod 0644 {} +

# 设置 PostgreSQL 相关目录和文件路径，以及初始化密码的标记文件和密码变量
PG_DIR="/etc/postgresql/16/main"
PG_HBA="$PG_DIR/pg_hba.conf"
PG_MARKER="/var/lib/postgresql/16/main/.postgres_password_initialized"
PG_DATABASE_MARKER="/var/lib/postgresql/16/main/.postgres_database_initialized"
PG_PASSWORD="${POSTGRES_PASSWORD:-Pa55W0rd}"

# set ownership and permissions for web and postgres directories
chown -R www-data:www-data /var/www/html
chown -R postgres:postgres "$PG_DIR"
mkdir -p /var/log/supervisor /var/run/supervisor

# 初始化 PostgreSQL 密码
# 如果尚未初始化，则配置 PostgreSQL 的 pg_hba.conf 文件为引导模式，以便设置密码
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

# 等待 PostgreSQL 准备就绪
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

# 写入数据库初始化标记文件
PGPASSWORD=$POSTGRES_PASSWORD
export PGPASSWORD
if [ ! -f "$PG_DATABASE_MARKER" ]; then
  psql -U postgres -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='toshokan'" | grep -q 1 \
    || psql -U postgres -d postgres -c "CREATE DATABASE toshokan;"
  psql -U postgres -d toshokan -f "/myNas/install.postgres.sql"
  touch "$PG_DATABASE_MARKER"
fi

# npm install
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

cd "/myNas/server"
npm install
npm run build