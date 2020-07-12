FROM redmine:3.4.13-passenger

# Latest file from repos
#   - r19553 2020-03-03
ENV MIGRATE_FROM_TRAC_LATEST=http://svn.redmine.org/redmine/!svn/bc/19553/trunk/lib/tasks/migrate_from_trac.rake
# Support
#   - Trac 1.0.x
#       - database_version > 22
#       - attachement path 
#   - Redmine 3.4.x
ENV PATCH_MIGRATE_FROM_TRAC_1_0=migrate_from_trac-trac-1.0.patch

RUN apt-get update && apt-get install -y patch

ADD ${MIGRATE_FROM_TRAC_LATEST} /usr/src/redmine/lib/tasks/migrate_from_trac.rake
RUN chown redmine:redmine /usr/src/redmine/lib/tasks/migrate_from_trac.rake && \
    chmod 664 /usr/src/redmine/lib/tasks/migrate_from_trac.rake

COPY ${PATCH_MIGRATE_FROM_TRAC_1_0} /usr/src/redmine/lib/tasks/
RUN cd /usr/src/redmine/lib/tasks/ && \
    patch -u migrate_from_trac.rake < ${PATCH_MIGRATE_FROM_TRAC_1_0}
