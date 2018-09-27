#!/bin/bash

#+----------------------------------------------------------------------------+
#+ MODX DATABASE UPGRADER
#+----------------------------------------------------------------------------+
#+ Author:      Jon Leverrier (jon@youandme.digital)
#+ Copyright:   2018 You & Me Digital SARL
#+ GitHub:      https://github.com/jonleverrier/modx-database-upgrader
#+ Issues:      https://github.com/jonleverrier/modx-database-upgrader/issues
#+ License:     GPL v3.0
#+ OS:          MODX 2.6.5pl
#+ Release:     0.0.0
#+----------------------------------------------------------------------------+

# Colour options - nothing to change here
COLOUR_RESTORE=$(echo -en '\033[0m')
COLOUR_WHITE=$(echo -en '\033[01;37m')
COLOUR_CYAN=$(echo -en '\033[00;36m')

# Your database details
database_name='db'
database_user='user'
database_pass='pass'

# What do you want to convert your database to? Pass these inline, for example:
# /bin/bash upgrade.sh <charset> <collation>
charset=$1
collate=$2

# Check if root user
if [ "${EUID}" != 0 ];
then
    echo ""
    echo "------------------------------------------------------------------------"
    echo ""
    echo "MODX DATABASE UPGRADER"
    echo "Please run this script as the root user and try again."
    echo ""
    echo "------------------------------------------------------------------------"
    echo ""
    exit
fi

# Welcome message
echo ""
echo "------------------------------------------------------------------------"
echo ""
echo "MODX DATABASE UPGRADER"
echo "Connecting to ${database_name}..."
echo ""
echo "------------------------------------------------------------------------"
echo ""

# Display warning if no inline variables are set
if [ -z "$1" ]; then
    echo "WARNING: A charset was not defined."
    echo "For example: /bin/bash upgrade.sh <your_charset> <your_collation>"
    exit 1
fi

if [ -z "$2" ]; then
    echo "WARNING: A database collation was not defined."
    echo "For example: /bin/bash upgrade.sh <your_charset> <your_collation>"
    exit 1
fi

# Convert MyISAM to InnoDB
echo "${COLOUR_CYAN}Converting MyISAM to InnoDB${COLOUR_RESTORE}"
mysql -B --user=${database_user} -p${database_pass} ${database_name} --disable-column-names --execute "SELECT CONCAT('ALTER TABLE ',TABLE_NAME,' ENGINE=InnoDB;') FROM INFORMATION_SCHEMA.TABLES WHERE ENGINE='MyISAM' AND table_schema='${database_name}';" > schema.sql
mysql --user=${database_user} -p${database_pass} ${database_name} < schema.sql
rm schema.sql
echo "Complete"
echo ""

# Change charset of database
echo "${COLOUR_CYAN}Changing charset of ${database_name}${COLOUR_RESTORE}"
mysql --user=${database_user} --password=${database_pass} ${database_name} -s <<MYSQL_INPUT
ALTER DATABASE
    ${database_name}
    CHARACTER SET ${charset}
    COLLATE ${collate};
MYSQL_INPUT
echo "Complete"
echo ""

# Change charset of table
echo "${COLOUR_CYAN}Preparing to change charset in tables...${COLOUR_RESTORE}"
echo ""

for table in $(mysql ${database_name} -s --skip-column-names -e 'show tables')
    do
        echo "Changing charset in $table"
        mysql -u ${database_user} -p${database_pass} ${database_name} -s <<MYSQL_INPUT
ALTER TABLE
    $table
    CHARACTER SET $charset
    COLLATE $collate;
MYSQL_INPUT

        echo "Converting charset in ${table}"
        mysql -u ${database_user} -p${database_pass} ${database_name} -s <<MYSQL_INPUT
ALTER TABLE
    $table
    CONVERT TO CHARACTER SET $charset
    COLLATE $collate;
MYSQL_INPUT
        echo ""

done

echo "${COLOUR_CYAN}Optimising tables...${COLOUR_RESTORE}"
echo ""
mysqlcheck -u ${database_user} -p${database_pass} ${database_name} --auto-repair --optimize

echo ""
echo "------------------------------------------------------------------------"
echo "Upgrade complete."
echo "------------------------------------------------------------------------"
echo ""
