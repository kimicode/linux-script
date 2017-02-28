# file: auto_mysql_backup.sh

# 自动备份MySQL数据库

# Variable

# Current Time
bakdate=`date "+%Y%m%d_%H_%M_%S"`

# user account and password
str_mysql_db_user="root"
str_mysql_db_password="Abcd1@34"

# backup

# backup target
str_dir_backup_target="/data/db/backup"

# Databases
list_backup_databases=""

# ---------------------------
# function

function dir_isExsist() {
  # variable
  f_str_dir_path="$1"

  # logical
  if [ ! -x "$f_str_dir_path" ]
  then
    echo "Directory ## [$f_str_dir_path] is not exsist."
    echo "create it."
    mkdir -p "$f_str_dir_path"
    echo "---> done."`date "+|%Y-%m-%d|%H:%M:%S|"`
  else
    echo "Directory ## [$f_str_dir_path] is exsist."
  fi
  echo ""
}

function do_sql() {
  # variable
  func_str_ip="$1"
  func_str_sql="$2"

  # action
  # 本场景中不涉及到对MySQL某个库的操作，所以没有选择[db]
  # mysql -u $user -p"$password" $db -N -e "$f_sql_str"
  mysql -u $str_mysql_db_user -h $func_str_ip -p"$str_mysql_db_password" -N -e "$func_str_sql"
}

function get_backup_db_list() {
  # do logical
  if [ "$list_backup_databases" == "" ]
  then
    echo "fun ## variable: list_backup_databases is null."
    list_backup_databases=`do_sql "localhost" "show databases"`
  fi

  # display
  for item_db in $list_backup_databases
  do
    echo "backup db @ $item_db"
  done

  echo ""
}

function do_mysql_backup_all_non_mysql() {
# -----------------
# MySQL all non-mysql db
# -----------------

echo "# Backup MySQL: all non-mysql db" | tee -a $str_dir_backup_target/MySQL_all_non_mysql_db.$bakdate.log
echo "# Begin: "`date` | tee -a $str_dir_backup_target/MySQL_all_non_mysql_db.$bakdate.log

#mysqldump -u$str_mysql_db_user -p"$str_mysql_db_password" --lock-tables --databases $list_backup_databases > $str_dir_backup_target/MySQL_all_non_mysql_db.$bakdate | tee -a $str_dir_backup_target/MySQL_all_non_mysql_db.$bakdate.log

mysqldump -u$str_mysql_db_user -p"$str_mysql_db_password" --databases $list_backup_databases > $str_dir_backup_target/MySQL_all_non_mysql_db.$bakdate | tee -a $str_dir_backup_target/MySQL_all_non_mysql_db.$bakdate.log

echo "# End: "`date` | tee -a $str_dir_backup_target/MySQL_all_non_mysql_db.$bakdate.log

echo ""
}

function do_mysql_backup_special_db() {

    for item_db in $list_backup_databases
    do
      # -----------------
      # MySQL special db
      # -----------------

      echo "# Backup MySQL: [$item_db] db" | tee -a $str_dir_backup_target/MySQL_$item_db.$bakdate.log
      echo "# Begin: "`date` | tee -a $str_dir_backup_target/MySQL_$item_db.$bakdate.log

      mysqldump -u$str_mysql_db_user -p"$str_mysql_db_password" --lock-tables --databases $item_db > $str_dir_backup_target/MySQL_$item_db.$bakdate | tee -a $str_dir_backup_target/MySQL_$item_db.$bakdate.log

      echo "# End: "`date` | tee -a $str_dir_backup_target/MySQL_$item_db.$bakdate.log
      echo ""
    done
    echo ""
}

# running
get_backup_db_list
dir_isExsist "$str_dir_backup_target"
do_mysql_backup_all_non_mysql
do_mysql_backup_special_db

# finished
