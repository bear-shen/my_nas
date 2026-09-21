#!/usr/bin/env bash
set -euo pipefail

#如果根目录不存在.docker_initialized文件，则执行init.sh
if [ ! -f "/.docker_initialized" ]; then
  /usr/bin/env bash /myDocker/init.sh
  touch "/.docker_initialized"
fi

# 启动服务
echo "[init] starting php8.3-fpm..."
service php8.3-fpm start

echo "[init] starting nginx..."
service nginx start

echo "[init] starting cron..."
service cron start

echo "[init] starting supervisord..."
service supervisor start

echo "[init] all services started."
# 保持容器运行
tail -f /dev/null