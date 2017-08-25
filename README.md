# Content of my `~/bin` directory

A small collection of usefull and experimental bash scripts.

## MySQL export

```
$ bin/dump-all.sh /path/to/directory
```

Will export all content databases (excluding system tables like `mysql`, `performance_schema`) to the
given directory. Each database will be stored in a separate `<DATABASE>.sql` file.

See `$ bin/dump-all.sh -h` for more information.

```
$ bin/dump-grants.sh /path/to/mysql_grants.sql
```
Will export all users and their capabilites to the specified file.

See `$ bin/dump-grants -h` for more information

## Resources

https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
