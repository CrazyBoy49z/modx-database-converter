# MODX Database Upgrader

_If you want to try out this script, please backup your database before doing so._

This script attempts to convert your old MODX database to `utf8mb4`. If your tables have multiple collations, they will be unified using `utf8mb4_general_ci`.

This script does the following:
1. Converts your tables from MyISAM to InnoDB
2. Changes the charset of your database to `utf8mb4_general_ci`
3. Converts all text-like columns in the table to `utf8mb4_general_ci`
4. Optimises the tables

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
Once you're ready, run the script by typing the following:
```
/bin/bash upgrade.sh utf8mb4 utf8mb4_general_ci
```
The first variable passed sets the charset. The second variable passed sets the collation.

## utf8mb4
If you are trying to convert your database to `utf8mb4`, you might receive an error message on 10% of your tables.

```
Changing charset in modx_content_type
Converting charset in modx_content_type
ERROR 1071 (42000) at line 1: Specified key was too long; max key length is 767 bytes
```
At the moment, these will need to be changed manually, until I find a way of automating the process.

Once again, if you want to try out this script, please backup your database before doing so.

Inspired by:
*   https://modx.com/blog/converting-to-innodb-from-myisam-tables-using-the-command-line
*   https://gist.github.com/samuelpismel/f41c3e7ec7861f39bf59
