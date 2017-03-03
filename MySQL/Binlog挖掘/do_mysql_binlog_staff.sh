# do_mysql_binlog_staff.sh
# 深度挖掘MySQL的Binlog

# variable

# 存放BINLOG的路径
str_path_log_bin="/var/lib/mysql/mysql_standalone/binlog_data"

# 确切的BINLOG文件的绝对路径
str_current_log_bin=""
str_file_log_bin=""

# 账户
str_mysql_user="root"
str_mysql_password="xxxx"

# function

function say_hi_and_bye(){
  f_str_hi_or_bye="$1"
  echo ""
  echo "================="
  echo "$f_str_hi_or_bye:: "`date "+|%Y-%m-%d|%H:%M:%S|"`
  echo "================="
  echo ""
}

function do_sql() {
  # variable
  func_str_ip="$1"
  func_str_sql="$2"

  # action
  # 本场景中不涉及到对MySQL某个库的操作，所以没有选择[db]
  # mysql -u $user -p"$password" $db -N -e "$f_sql_str"
  mysql -u $str_mysql_user -h $func_str_ip -p"$str_mysql_password" -N -e "$func_str_sql"
}

function get_binlog_file() {
  if [ "$str_file_log_bin" == "" ]
  then
    str_current_log_bin=`do_sql "localhost" "show master status" | awk '{printf $1}'`
    str_file_log_bin="$str_path_log_bin/$str_current_log_bin"
  fi
}

# running

#begin
say_hi_and_bye "begin"

#--> 获取当前binlog的信息
get_binlog_file
echo "Current Bin Log: $str_file_log_bin"

#end
say_hi_and_bye "end"

# finished
