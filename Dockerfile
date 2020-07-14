FROM redmine:3.4.13-passenger

COPY migrate_from_trac.rake /usr/src/redmine/lib/tasks/migrate_from_trac.rake
