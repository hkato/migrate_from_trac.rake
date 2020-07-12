# Redmine: migrate from Trac patch

ref. Official Redmine wiki > [Migrating from other systems > Trac](https://www.redmine.org/projects/redmine/wiki/RedmineMigrate/30#Trac)

- This patch dose not work with Redmine **4.x**. This is due to the difference between Rails/ActiveRecord 4.2 and 5.2.
- Only tested with Trac 1.0.3, not tested with 1.2, 1.4.


## Test environment

- From
    - Trac 1.0.3
        - CentOS 7 + [Trac EPEL package](https://src.fedoraproject.org/rpms/trac) + SQLite3
- To
    - Redmine 3.4.13
        -  [the Docker "Official Image" for redmine](https://hub.docker.com/_/redmine)
            - `redmine:3.4.13-passenger`
            - Docker Desktop for Mac

## Related issues and patches

- [#5764](https://www.redmine.org/issues/5764): migrate_from_trac does not support trac 0.12
- [#14567](https://www.redmine.org/issues/14567): migrate_from_trac.rake does not convert timestamps in Trac database version 23
- [#20943](https://redmine.org/issues/20943): migrate_from_trac.rake dont work
- [github.com/eLvErDe/migrate_from_trac.rake](https://github.com/eLvErDe/migrate_from_trac.rake) - [[Forks]](https://github.com/eLvErDe/migrate_from_trac.rake/network/members)
- Redmine 3.4.2 patch - [Gist](https://gist.github.com/stknohg/0ce7a55675258a5d119528732f70fb3e)/[Blog](https://blog.shibata.tech/entry/2017/09/30/121019) (Japanese)


## Migration test procedure

You can easily test your migration with Docker before you apply your production environment.

### Create tar+gz archive on the Trac host

```sh
[username@trac-host ~]$ cd ${TRAC_ENV_PARENT_DIR}
[username@trac-host /var/lib/trac]$ tar cvfz myproj.tar.gz myproj
```
and put tar+gz archive on Redmine host
```sh
[username@trac-host /var/lib/trac]$ scp myproj.tar.gz redmine-host:/some/where/work/migrate_from_trac.rake/trac/
```

### Create Redmine environment on Docker host

Clone this project

```sh
$ cd /some/where/work/
$ git clone https://github.com/hkato/migrate_from_trac.rake.git
$ cd migrate_from_trac.rake/
```

Edit .env file
```sh
$ cp .env.sample .env
$ vi .env
```

Run the init script (be careful: redmine and mysql containers will be destroyed)

```sh
$ ./init.sh
```

After this, you can access anilla Redmine with this patched.

### Migrate

```sh
$ ./migrate.sh
```
Just exec `rake redmine:migrate_from_trac RAILS_ENV="production"` on the Redmine container.

The Trac data has been deployed on the `/trac` path on the Redmine container. you can set `Trac directory []` as `/trac/myproj`.

```sh
WARNING: a new project will be added to Redmine during this process.
Are you sure you want to continue ? [y/N] y

Trac directory []: /trac/myproj
Trac database adapter (sqlite3, mysql2, postgresql) [sqlite3]: 
Trac database encoding [UTF-8]: 
Target project identifier []: myproj

Trac database version is: 29
Migrating components.........
Migrating milestones..........................................................................
Migrating custom fields...
Migrating tickets.................................................................................................................
Migrating wiki.............................................

Components:      9/9
Milestones:      74/74
Tickets:         1174/1174
Ticket files:    97/97
Custom values:   3522/3522
Wiki edits:      45/45
Wiki files:      0/0
```

### Migrate from Redmine 3.x to 4.x

Stop redmine container

```sh
$ docker-compose stop redmine
```

Update redmine container image

```sh
$ vi docker-compose.yml
```
```diff
 services:
   redmine:
     container_name: ${REDMINE:-redmine}
-    build: .
+    image: redmine:4.1.1-passenger
     restart: always
     ports:
       - 80:3000
```

Maybe you can use these images
- `redmine:4.0.x-passenger`,`redmine:4.0.x` 
- `redmine:4.1.x-passenger`,`redmine:4.1.x`
- `quiw/redmica:1.1.x-passenger`,`quiw/redmica:1.1.x`

Update sqlite3 gem package compatible with Redmine 4.x

```sh
$ vi srv/redmine/Gemfile.local
```
```diff
 gem 'dalli'
-gem 'sqlite3', '~> 1.3.13'
+gem 'sqlite3', '~> 1.4.0'
```

Start new redmine container
```sh
$ docker-compose up -d redmine
```
