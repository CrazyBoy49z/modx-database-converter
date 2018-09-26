# MODX Database Upgrader

If you want to try out this script, please backup your database before doing so.

This script attempts to convert your old MODX database to `utf8mb`. If your tables have multiple collations, they will be unified using `utf8mb_general_ci`.

This script does the following:
1. Converts your tables from MyISAM to InnoDB
2. Changes the charset of your database to utf8mb_general_ci
3. utf8mb_general_ci all text-like columns in the table to the new character se
4. Optimises the tables

After running the script, it may report errors such as:
```
Changing charset in modx_content_type
Converting charset in modx_content_type
ERROR 1071 (42000) at line 1: Specified key was too long; max key length is 767 bytes
```
At the moment, these will need to be changed manually, until I find a way of automating the process.

To install this script run:
```
wget -N https://raw.githubusercontent.com/jonleverrier/modx-database-upgrader/master/upgrade.sh
```

Before running the shell, edit the variables in the header of the document:
```
nano upgrade.sh
```

Once you're ready, run the script by typing the following:
```
/bin/bash upgrade.sh
```

Once again, if you want to try out this script, please backup your database before doing so.

Inspired by:
*   https://modx.com/blog/converting-to-innodb-from-myisam-tables-using-the-command-line
*   https://gist.github.com/samuelpismel/f41c3e7ec7861f39bf59
