#!/bin/bash

SLEEP=1
REDMINE_LANG=ja

docker-compose down
rm -rf srv

docker-compose build redmine

mkdir -p srv/{redmine,redmine/plugins,redmine/public/themes,redmine/log,redmine/files}
mkdir -p srv/trac

cp -pr redmine_home/* srv/redmine/

for f in `find trac \( -name \*.tgz -or -name \*.tar.gz \)`; do
  echo $f
  tar -zxf $f -C srv/trac
done

docker-compose up -d mysql

while :; do
  startup=`docker-compose logs mysql | grep "port: 3306  MySQL"`
  if [ -n "$startup" ]; then
    break
  else
    echo -n "."
    sleep ${SLEEP}
  fi
done

docker-compose up -d redmine

while :; do
  startup=`docker-compose logs redmine | grep "Completed 200 OK"`
  if [ -n "$startup" ]; then
    break
  else
    echo -n "."
    sleep ${SLEEP}
  fi
done

docker-compose run redmine rake redmine:load_default_data RAILS_ENV=production REDMINE_LANG=${REDMINE_LANG}
