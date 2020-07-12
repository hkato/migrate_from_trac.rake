#!/bin/sh

docker-compose exec redmine rake redmine:migrate_from_trac RAILS_ENV="production"
