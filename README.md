# MODX Database Converter

**If you want to try out this script, please _backup your database_ before doing so.**

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
wget -N https://raw.githubusercontent.com/jonleverrier/modx-database-upgrader/master/modx_convertdb.sh
```

## Customise
Before running the shell, edit your database settings in the header of the document by running:
```
nano modx_convertdb.sh
```

## Run
The first variable passed sets the charset. The second variable passed sets the collation. Once you're ready, run the script by typing the following:
```
/bin/bash modx_convertdb.sh utf8mb4 utf8mb4_general_ci
```
In this example, this would set the charset of your database to `utf8mb4` and the collation to `utf8mb4_general_ci`.

### A note about utf8mb4
If you are trying to convert your database to `utf8mb4` using `modx_convertdb.sh`, you might receive an error message on about 10% of your tables. For example:

```
Changing charset in modx_content_type
Converting charset in modx_content_type
ERROR 1071 (42000) at line 1: Specified key was too long; max key length is 767 bytes
```
At the moment, you will need to manually change `varchar(255)` to `varchar(191)` in the tables that reported the error, ~until I find a way of automating the process~.

**Solution 1**

If you want to convert your database to `utf8mb4`, one solution is to use [Teleport](https://github.com/modxcms/teleport).

1. Login to your server and create a directory using `mkdir ~/teleport/ && cd ~/teleport/`
2. Download teleport using `wget -N http://modx.s3.amazonaws.com/releases/teleport/teleport.phar`
3. Setup a new MODX Revolution site. Make sure you select `utf8mb4` and `utf8mb4_general_ci` during database creation
4. Profile your new website with Teleport using `php teleport.phar --action=Profile --name="newwebsite" --code=newwebsite --core_path=/home/user/public/newwebsite/core/ --config_key=config`
5. Profile your existing MODX Revolution website (the one with the database your want to convert), using `php teleport.phar --action=Profile --name="oldwebsite" --code=oldwebsite --core_path=/home/user/public/oldwebsite/core/ --config_key=config`
6. Extract a copy of your existing MODX Revolution website using `php teleport.phar --action=Extract --profile=profile/oldwebsite.profile.json --tpl=phar://teleport.phar/tpl/complete.tpl.json`
7. Inject the existing MODX Revolution website into the new installation using `php teleport.phar --action=Inject --profile=profile/newwebsite.profile.json --source=workspace/oldwebsite_complete-120315.1106.30-2.2.1-dev.transport.zip`
8. Check the database tables in your new installation - all looks good so far
9. Run modx_convertdb.sh on your new installation

**Solution 2**

Another option is to enable a larger index for MariaDB in your database configuration file under `[mysqld]`.
```
SET GLOBAL innodb_file_format=Barracuda;
SET GLOBAL innodb_file_per_table=ON;
SET GLOBAL innodb_large_prefix=1;
logout & login (to get the global values);
ALTER TABLE tbl ROW_FORMAT=DYNAMIC;  -- or COMPRESSED
```
After restarting MYSQL, try running `modx_convertdb.sh` on your database again.

Further reading:
* http://mysql.rjweb.org/doc.php/limits#767_limit_in_innodb_indexes
* https://stackoverflow.com/questions/43379717/how-to-enable-large-index-in-mariadb-10

### Compatibility
This script was tested with a database running MODX 2.6.5pl on Ubuntu 18.04 which is running MariaDB Ver 15.1 Distrib 10.1.34.

**Once again, if you want to try out this script, _please backup your database_ before doing so.**

Inspired by:
*   https://modx.com/blog/converting-to-innodb-from-myisam-tables-using-the-command-line
*   https://gist.github.com/samuelpismel/f41c3e7ec7861f39bf59
