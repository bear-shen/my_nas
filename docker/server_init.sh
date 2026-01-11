#!/bin/bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

npm config set registry https://registry.npmmirror.com

cd ${SRC}/server
npm install

# cd ${SRC}/front
# npm install
#cd /myNas

sleep 1

rm -f /etc/nginx/nginx.conf
rm -f /etc/nginx/mime.types
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-available/default

cp ${SRC}/system/nginx.conf /etc/nginx/nginx.conf
cp ${SRC}/system/nginx_mime.types /etc/nginx/mime.types
cp ${SRC}/system/nginx_default.conf /etc/nginx/sites-enabled/default.conf

rm -f /etc/postgresql/16/main/postgresql.conf
rm -f /etc/postgresql/16/main/pg_hba.conf
cp ${SRC}/system/postgresql.conf /etc/postgresql/16/main/postgresql.conf
cp ${SRC}/system/pg_hba.conf /etc/postgresql/16/main/pg_hba.conf

# cp ${SRC}/system/nas_be.service /usr/lib/systemd/system/nas_be.service
# cp ${SRC}/system/nas_job.service /usr/lib/systemd/system/nas_job.service

touch ${SRC}/log/server_verbose.log
touch ${SRC}/log/server_err.log

chown -R www-data:www-data ${SRC}
chmod -R 0755 ${SRC}

chown -R www-data:www-data ${SRC}/*
chmod -R 0755 ${SRC}/*

# deploy pdfjs
mkdir -p ${SRC}/front/dist/pdfjs
wget "https://github.com/mozilla/pdf.js/releases/download/v5.4.530/pdfjs-5.4.530-legacy-dist.zip" -O /tmp/pdfjs_legacy.zip
unzip -o /tmp/pdfjs_legacy.zip -d ${SRC}/front/dist/pdfjs
rm -f /tmp/pdfjs_legacy.zip
chown -R www-data:www-data ${SRC}/front/dist/pdfjs
chmod -R 0755 ${SRC}/front/dist/pdfjs
