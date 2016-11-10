#!/bin/bash

# Script: automatic_install_Zabbix.sh
# Type: shell
# OS: RHEL 7
# Author: adamhuan
# Blog: d-prototype.com
# Network: Need

# Variable
path_zabbix_release="http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm"

# MySQL password
#str_mysql_password="Abcd!234"
str_mysql_password="Abcd!234567890"

str_mysql_db_zabbix="zabbix"

dir_secure=/secure_me
path_percona_client=$dir_secure/percona_client.cnf

# Function

# Display
echo "=================================="
echo "Automatic deploy Zabbix Server"
echo "Author: adamhuan"
echo "=================================="
echo "Start:: "`date`
echo "-----------------"

# YUM: install zabbix release
rpm -ivh $path_zabbix_release

# Prepare: Zabbix Database: MySQL
yum install -y zabbix-server-mysql zabbix-web-mysql

echo "## Zabbix has been [INSTALLED]"

# MySQL, config:

# file system: mkdir
if [ ! -x "$dir_secure" ]
then
  echo "@@ The directory [$dir_secure] is [NOT EXSIST]"
  mkdir "$dir_secure"
else
  echo "@@ The directory [$dir_secure] has been [EXSIST]"
fi

# Percona Config: password
cat <<EOF > $path_percona_client
[client]
password=$str_mysql_password
EOF

# MySQL, Action:
# create Database

# get list of mysql databses
#list_databases=`mysql -uroot -p'Oracle_1234' -e 'show databases'`
#list_databases=`mysql --defaults-extra-file=$path_percona_client -e 'show databases'`
#echo "## The list:: $list_databases"

#echo $list_databases | grep $str_mysql_db_zabbix

# is wantted database exsist?

function isDBExsist() {
  #variable
  #exsist, 0
  #not exsist, 1

  fun_isDBExsist=1

  list_databases=`mysql --defaults-extra-file=$path_percona_client -e 'show databases'`

  #statements
  for func_item in $list_databases
  do
    if [ $func_item == $str_mysql_db_zabbix ]
    then
      # echo "Wantted DB is exsist, return 0"
      fun_isDBExsist=0
    #else
    #  # echo "Wantted DB is not exsist, return 1"
    #  fun_isDBExsist=1
    fi
  done

  echo $fun_isDBExsist

}

#is_zabbix_exsist=`echo $list_databases | grep "$str_mysql_db_zabbix" | echo $?`

is_zabbix_exsist=`isDBExsist`

echo "## is Zabbix exsist? :: $is_zabbix_exsist"
echo ""

#echo "@@ if not exsist do the loop."

#for item_db in $list_databases
# func: isDBExsist != 0 ,means the Wantted DB is not exsist
while [ $is_zabbix_exsist != 0 ]
do
  #for item_db in $list_databases
  #do
  #  echo "-----------------"
  #  echo "MySQL @ Current Database:: $item_db"
  #  if [ $item_db == $str_mysql_db_zabbix ]
  #  then
  #    #echo "@@ MySQL Zabbix DB, has been [CREATED]."
  #    echo "** Item:: $item_db"
  #    echo "** String Zabbix DB:: $str_mysql_db_zabbix"
  #    echo ""
  #    echo "Check: [DONE]"
  #    echo ""
  #  else
  #    echo "** Item:: $item_db"
  #    echo "** String Zabbix DB:: $str_mysql_db_zabbix"
  #    echo ""
  #    echo "@@ MySQL Zabbix DB, is [NOT EXSIST]."
  #
  #    mysql --defaults-extra-file=$path_percona_client -e 'create database zabbix character set utf8 collate utf8_bin'
  #    mysql --defaults-extra-file=$path_percona_client -e "grant all privileges on zabbix.* to zabbix@'%' identified by 'Abcd!234'"

  #    # change databases list
  #    list_databases=`mysql --defaults-extra-file=$path_percona_client -e 'show databases'`

  #  fi
  #  echo ""
  #done

  # ------------------

  # Version 2.2016Äê11ÔÂ10ÈÕ13:08:07
  # create database:: zabbix

  echo "## Create MySQL Percona DB: zabbix, for ZABBIX Server"

  mysql --defaults-extra-file=$path_percona_client -e 'create database zabbix character set utf8 collate utf8_bin'
  mysql --defaults-extra-file=$path_percona_client -e "grant all privileges on zabbix.* to zabbix@'%' identified by 'Abcd!234'"

  # RESET VARIABLE
  is_zabbix_exsist=`isDBExsist`
  echo "## is Zabbix exsist? :: $is_zabbix_exsist"
  echo ""

done

echo "=================================="
echo "Finished:: "`date`
echo "-----------------"
echo "Done."
# End
