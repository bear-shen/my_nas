#!/usr/bin/env bash
set -euo pipefail

# 安装目录
# APP_DIR 是脚本所在的目录
APP_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$APP_DIR/config.toml"

echo "== my_nas installer =="

# 默认web端口为20080
read -rp "please input website port (default 20080): " WEBSITE_PORT
WEBSITE_PORT=${WEBSITE_PORT:-20080}

# 默认数据库端口为20081
read -rp "please input database port (default 20081): " DB_PORT
DB_PORT=${DB_PORT:-20081}

# 默认Postgres密码为Pa55W0rd
read -rp "please input postgres password (default Pa55W0rd): " POSTGRES_PASSWORD
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-Pa55W0rd}

# 默认是否集成OnlyOffice为否
read -rp "please confirm if integrate onlyOffice (y/n) (default n): " INTEGRATE_ONLYOFFICE
INTEGRATE_ONLYOFFICE=${INTEGRATE_ONLYOFFICE:-n}
# 强制小写
INTEGRATE_ONLYOFFICE=$(echo "$INTEGRATE_ONLYOFFICE" | tr '[:upper:]' '[:lower:]')

# 如果配置了集成OnlyOffice，则需要配置JWT密钥
ONLYOFFICE_ENABLED="false"
ONLYOFFICE_URL="http://127.0.0.1:8080"
ONLYOFFICE_JWT_SECRET=""
if [[ "$INTEGRATE_ONLYOFFICE" == "y" ]]; then
  ONLYOFFICE_ENABLED="true"
  read -rp "please input OnlyOffice URL (default http://127.0.0.1:8080): " ONLYOFFICE_URL
  ONLYOFFICE_URL=${ONLYOFFICE_URL:-http://127.0.0.1:8080}
  read -rp "please input OnlyOffice JWT secret (default mysecret): " ONLYOFFICE_JWT_SECRET
  ONLYOFFICE_JWT_SECRET=${ONLYOFFICE_JWT_SECRET:-mysecret}
fi

echo "===================="
echo "please confirm your inputs (press enter to continue): "
echo "website port: $WEBSITE_PORT"
echo "database port: $DB_PORT"
echo "postgres password: $POSTGRES_PASSWORD"
echo "integrate onlyOffice: $INTEGRATE_ONLYOFFICE"
if [[ "$INTEGRATE_ONLYOFFICE" == "y" ]]; then
  echo "OnlyOffice URL: $ONLYOFFICE_URL"
  echo "OnlyOffice JWT secret: $ONLYOFFICE_JWT_SECRET"
fi

read -rp "are these correct? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "installation aborted."
  exit 1
fi

# Escape replacement values for sed (delimiter: |)
escape_sed_replacement() {
  printf '%s' "$1" | sed -e 's/[&|]/\\&/g'
}

APP_DIR_ESCAPED="$(escape_sed_replacement "$APP_DIR")"
WEBSITE_PORT_ESCAPED="$(escape_sed_replacement "$WEBSITE_PORT")"
DB_PORT_ESCAPED="$(escape_sed_replacement "$DB_PORT")"
POSTGRES_PASSWORD_ESCAPED="$(escape_sed_replacement "$POSTGRES_PASSWORD")"
ONLYOFFICE_JWT_SECRET_ESCAPED="$(escape_sed_replacement "$ONLYOFFICE_JWT_SECRET")"
ONLYOFFICE_URL_ESCAPED="$(escape_sed_replacement "$ONLYOFFICE_URL")"

echo "===================="
echo "deploy config files"
# 创建 compose_build 目录并克隆 my_docker_aio 仓库
# 如果已经存在，跳过
if [ ! -d "$APP_DIR/compose_build" ]; then
  mkdir -p "$APP_DIR/compose_build"
  git clone --depth 1 --branch main "https://github.com/bear-shen/my_docker_aio.git" "$APP_DIR/compose_build"
fi

# 复制模板文件到 compose_build 目录
# docker-compose.yaml template
cp -r -f "$APP_DIR/compose_config_template/docker-compose.yaml" "$APP_DIR/compose_build/compose/docker-compose.yaml"
sed -i \
  -e "s|{{APP_DIR}}|$APP_DIR_ESCAPED|g" \
  -e "s|{{WEBSITE_PORT}}|$WEBSITE_PORT_ESCAPED|g" \
  -e "s|{{DB_PORT}}|$DB_PORT_ESCAPED|g" \
  -e "s|{{POSTGRES_PASSWORD}}|$POSTGRES_PASSWORD_ESCAPED|g" \
  -e "s|{{ONLYOFFICE_JWT_SECRET}}|$ONLYOFFICE_JWT_SECRET_ESCAPED|g" \
  -e "s|{{ONLYOFFICE_ENABLED}}|$ONLYOFFICE_ENABLED|g" \
  "$APP_DIR/compose_build/compose/docker-compose.yaml"

# nginx template
mkdir -p "$APP_DIR/compose_build/compose/nginx/sites-available"
cp -r -f "$APP_DIR/compose_config_template/nginx/sites-available/default.conf" "$APP_DIR/compose_build/compose/nginx/sites-available/default.conf"
sed -i -e "s|{{ONLYOFFICE_URL}}|$ONLYOFFICE_URL_ESCAPED|g" \
  "$APP_DIR/compose_build/compose/nginx/sites-available/default.conf"

# supervisor template
mkdir -p "$APP_DIR/compose_build/compose/supervisor/conf.d"
cp -r -f "$APP_DIR/compose_config_template/supervisor/conf.d/node.conf" "$APP_DIR/compose_build/compose/supervisor/conf.d/node.conf"
sed -i -e "s|{{APP_DIR}}|$APP_DIR_ESCAPED|g" \
  "$APP_DIR/compose_build/compose/supervisor/conf.d/node.conf"

# config.toml template
cp -r -f "$APP_DIR/config.template.toml" "$APP_DIR/config.toml"
sed -i \
  -e "s|{{POSTGRES_PASSWORD}}|$POSTGRES_PASSWORD_ESCAPED|g" \
  -e "s|{{ONLYOFFICE_JWT_SECRET}}|$ONLYOFFICE_JWT_SECRET_ESCAPED|g" \
  -e "s|{{ONLYOFFICE_ENABLED}}|$ONLYOFFICE_ENABLED|g" \
  "$APP_DIR/config.toml"

cp -f "$APP_DIR/compose_config_template/start.sh" "$APP_DIR/compose_build/compose/start.sh"
cp -f "$APP_DIR/compose_config_template/init.sh" "$APP_DIR/compose_build/compose/init.sh"

echo "===================="
echo "building docker compose"
cd "$APP_DIR/compose_build/compose"
docker compose up -d
echo "docker compose complete"


