# MODX Database Upgrader

_If you want to try out this script, please backup your database before doing so._

This script attempts to convert your old MODX database to a new charset and collation. If your tables have multiple collations, they will be unified after running this script.

This script does the following:
1. Converts your tables from MyISAM to InnoDB
2. Changes the charset of your database
3. Converts all text-like columns in the table to a collation of your choosing
4. Optimises and repairs the tables with `mysqlcheck`

Please run the following commands as `root` user.

## Install
To install this script run:
```
wget -N https://raw.githubusercontent.com/jonleverrier/modx-database-upgrader/master/upgrade.sh
```

## Customise
Before running the shell, edit your database settings in the header of the document by running:
```
nano upgrade.sh
```

## Run
The first variable passed sets the charset. The second variable passed sets the collation. Once you're ready, run the script by typing the following:
```
/bin/bash upgrade.sh utf8mb4 utf8mb4_general_ci
```
In this example, this would set the charset of your database to `utf8mb4` and the collation to `utf8mb4_general_ci`.

### utf8mb4
If you are trying to convert your database to `utf8mb4`, you might receive an error message on about 10% of your tables. For example:

```
Changing charset in modx_content_type
Converting charset in modx_content_type
ERROR 1071 (42000) at line 1: Specified key was too long; max key length is 767 bytes
```
At the moment, these will need to be changed manually, until I find a way of automating the process.

Further reading: http://mysql.rjweb.org/doc.php/limits#767_limit_in_innodb_indexes

### Compatibility
This script was tested with a database running MODX 2.6.5pl on Ubuntu 18.04 which is running MariaDB Ver 15.1 Distrib 10.1.34.

*Once again, if you want to try out this script, please backup your database before doing so.*

Inspired by:
*   https://modx.com/blog/converting-to-innodb-from-myisam-tables-using-the-command-line
*   https://gist.github.com/samuelpismel/f41c3e7ec7861f39bf59
