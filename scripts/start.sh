#!/bin/sh

${HOME}/init-db.sh
cd /tmp
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
