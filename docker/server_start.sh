#!/bin/bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

service postgresql restart

cd /myNas/server

npm run init

sleep 1
nohup npm run serve 1>>/myNas/log/server_verbose.log 2>>/myNas/log/server_err.log &
sleep 5
nohup npm run job 1>>/myNas/log/server_verbose.log 2>>/myNas/log/server_err.log &
sleep 5
nohup npm run watcher 1>>/myNas/log/server_verbose.log 2>>/myNas/log/server_err.log &
sleep 5

service nginx restart

/usr/bin/tail -f /myNas/log/server_*

