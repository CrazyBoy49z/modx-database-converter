#!/bin/bash

#+----------------------------------------------------------------------------+
#+ MODX DATABASE CONVERTER
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
DATABASE_NAME='db'
DATABASE_USER='user'
DATABASE_PASS='pass'

# What do you want to convert your database to? Pass these inline, for example:
# /bin/bash modx_convertdb.sh <charset> <collation>
CHARSET=$1
COLLATE=$2

# Check if root user
if [ "${EUID}" != 0 ];
then
    echo ""
    echo "------------------------------------------------------------------------"
    echo ""
    echo "MODX DATABASE CONVERTER"
    echo "Please run this script as the root user and try again."
    echo ""
    echo "------------------------------------------------------------------------"
    echo ""
    exit 1
fi

# Welcome message
echo ""
echo "------------------------------------------------------------------------"
echo ""
echo "MODX DATABASE CONVERTER"
echo "Connecting to ${DATABASE_NAME}..."
echo ""
echo "------------------------------------------------------------------------"
echo ""

# Display warning if no inline variables are set
if [ -z "$1" ]; then
    echo "WARNING: A charset was not defined."
    echo "Example usage: /bin/bash modx_convertdb.sh <your_charset> <your_collation>"
    echo ""
    exit 1
fi

if [ -z "$2" ]; then
    echo "WARNING: A database collation was not defined."
    echo "Example usage: /bin/bash modx_convertdb.sh <your_charset> <your_collation>"
    echo ""
    exit 1
fi

# Convert MyISAM to InnoDB
echo "${COLOUR_CYAN}Converting MyISAM to InnoDB${COLOUR_RESTORE}"
mysql -B --user=${DATABASE_USER} -p${DATABASE_PASS} ${DATABASE_NAME} --disable-column-names --execute "SELECT CONCAT('ALTER TABLE ',TABLE_NAME,' ENGINE=InnoDB;') FROM INFORMATION_SCHEMA.TABLES WHERE ENGINE='MyISAM' AND table_schema='${DATABASE_NAME}';" > schema.sql
mysql --user=${DATABASE_USER} -p${DATABASE_PASS} ${DATABASE_NAME} < schema.sql
rm schema.sql
echo "Complete"
echo ""

# Change CHARSET of database
echo "${COLOUR_CYAN}Changing CHARSET of ${DATABASE_NAME}${COLOUR_RESTORE}"
mysql --user=${DATABASE_USER} --password=${DATABASE_PASS} ${DATABASE_NAME} -s <<MYSQL_INPUT
ALTER DATABASE
    ${DATABASE_NAME}
    CHARACTER SET ${CHARSET}
    COLLATE ${COLLATE};
MYSQL_INPUT
echo "Complete"
echo ""

# Change CHARSET of table
echo "${COLOUR_CYAN}Preparing to change charset in tables...${COLOUR_RESTORE}"
echo ""

for table in $(mysql ${DATABASE_NAME} -s --skip-column-names -e 'show tables')
    do
        echo "Changing charset in $table"
        mysql -u ${DATABASE_USER} -p${DATABASE_PASS} ${DATABASE_NAME} -s <<MYSQL_INPUT
ALTER TABLE
    $table
    CHARACTER SET $CHARSET
    COLLATE $COLLATE;
MYSQL_INPUT

        echo "Converting charset in ${table}"
        mysql -u ${DATABASE_USER} -p${DATABASE_PASS} ${DATABASE_NAME} -s <<MYSQL_INPUT
ALTER TABLE
    $table
    CONVERT TO CHARACTER SET $CHARSET
    COLLATE $COLLATE;
MYSQL_INPUT
        echo ""

done

echo "${COLOUR_CYAN}Optimising tables...${COLOUR_RESTORE}"
echo ""
mysqlcheck -u ${DATABASE_USER} -p${DATABASE_PASS} ${DATABASE_NAME} --auto-repair --optimize

echo ""
echo "------------------------------------------------------------------------"
echo "Upgrade complete."
echo "------------------------------------------------------------------------"
echo ""
