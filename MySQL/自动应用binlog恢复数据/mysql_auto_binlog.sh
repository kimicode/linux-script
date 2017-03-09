# Script
# Language: Shell
# Author: adamhuan

# begin

ip_major=192.168.19.141
ip_middle=192.168.19.142
ip_apply=192.168.19.143

script_conf=mysql_auto_binlog.conf
temp_path_binlog=/mysql_data/binlog
temp_path_binlog_sql=/mysql_data/input_text

# variable
mysql_user='root'
mysql_password=Oracle1@34

mysql_port="3306"

str_mysql_binlog=""

file_mysql_cnf=/etc/my.cnf

path_mysql_datadir=`cat $file_mysql_cnf | grep --color datadir | cut -d'=' -f2`

# scp file info
scp_file_already_done=`cat $script_conf | grep --color scp_file_already_done | cut -d'=' -f2`
scp_file_need_to_do=""

# function

function hello_world() {
  #statements
  echo "-------------------------"
  echo "MySQL automatic Apply Binlog"
  echo "MySQL：【自动】异机BINLOG同步"
  echo "-------------------------"
  echo "Begin:: "`date "+|%Y-%m-%d|%H:%M:%S|"`
  echo "=========="
}

function bye_world() {
  #statements
  echo "=========="
  echo "End:: "`date "+|%Y-%m-%d|%H:%M:%S|"`
}

function do_sql() {
  # variable
  func_str_ip="$1"
  func_str_sql="$2"

  # action
  # 本场景中不涉及到对MySQL某个库的操作，所以没有选择[db]
  # mysql -u $user -p"$password" $db -N -e "$f_sql_str"
  mysql -u $mysql_user -h $func_str_ip -P$mysql_port -p"$mysql_password" -N -e "$func_str_sql"
}

function get_mysql_binlog_file() {
  # variable
  func_ip="$1"
  func_str_binlog_file=""

  # action
  func_str_binlog_file=`do_sql "$func_ip" "show master status" | awk '{print $1}'`

  # thrown out
  echo $func_str_binlog_file
}

function do_mysql_import_sql() {
  # variable
  func_ip="$1"
  func_str_sql_file="$2"

  # action
  do_sql "$func_ip" "source $func_str_sql_file"
}

# 对binlog字符串进行运算
# $1 binlog字符串
# $2 运算符
# $3 运算量
function compute_mysql_binlog_file() {
  # variable
  f_str_binlog="$1"
  f_str_do="$2"
  f_str_number="$3"

  # compute variable
  part_number_current=`echo $f_str_binlog | cut -d'.' -f2`
  comput_part_number_current=`echo $part_number_current | sed 's/^0*//g'`
  part_number_after=""

  f_str_binlog_after=""

  # Display
  #echo "func:: current number part:: $part_number_current"

  # do compute
  #这里也存在问题，也需要改进
  let part_number_after=comput_part_number_current$f_str_do$f_str_number
  #echo "func:: After number part:: $part_number_after"

  #这里存在问题，需要改进
  #temp_sed_number=`echo $part_number_current | rev | cut -d'0' -f1 | rev`
  temp_sed_number=`echo $part_number_current | sed 's/^0*//g'`
  #echo "func:: temp sed number:: $temp_sed_number"

  f_str_binlog_after=`echo $f_str_binlog | sed "s/$temp_sed_number/$part_number_after/g"`

  echo $f_str_binlog_after
}

# 对指定主机执行Linux命令
# 前提：
# 1. IP可达
# 2. SSH等价关系
function do_linux_by_ssh() {
  # variable
  func_str_ip="$1"
  func_str_user="$2"
  func_str_command="$3"

  # action
  ssh -t $func_str_user@$func_str_ip "$func_str_command"
}

function fill_value_to_need_scp() {
  if [ "$scp_file_need_to_do" == "" ]
    then
      str_mysql_binlog=`get_mysql_binlog_file $ip_major`
      scp_file_need_to_do=`compute_mysql_binlog_file "$str_mysql_binlog" "-" "1"`
  fi
}

function do_scp() {
  #statements
  ip_from=$1
  ip_to=$2

  dir_to=$3

  #action
  fill_value_to_need_scp

  f_full_path_scp_file="$path_mysql_datadir/$scp_file_need_to_do"

  scp -r "$f_full_path_scp_file" $ip_to:$dir_to

  scp_file_already_done=$scp_file_need_to_do
  echo "scp_file_already_done=$scp_file_already_done" > $script_conf
}

function transfer_apply_mysql_binlog() {
  # variable
  f_binlog_file_name_full=$temp_path_binlog/$1
  f_binlog_file_sql_full=$temp_path_binlog_sql/$1.sql

  # action
  do_linux_by_ssh $ip_middle root "mysqlbinlog $f_binlog_file_name_full > $f_binlog_file_sql_full"

  echo "Function:: Import data into MySQL"
  echo "Command is:: "
  echo "mysql -u$mysql_user -h $ip_apply -p'$mysql_password' < $f_binlog_file_sql_full"
  do_linux_by_ssh $ip_middle root "mysql -u$mysql_user -h $ip_apply -p'$mysql_password' < $f_binlog_file_sql_full"
}

# call_scp
# if run this script?
function call_scp() {
  #statements
  if [ "$scp_file_need_to_do" == "" ]
  then
    fill_value_to_need_scp
    echo "Function SCP need:: $scp_file_need_to_do"
  fi

  echo "SCP need:: $scp_file_need_to_do"
  echo "SCP already:: $scp_file_already_done"

  if [ "$scp_file_need_to_do" == "$scp_file_already_done" ]
  then
    echo "No need call function:: do_scp"
  else
    do_scp $ip_major $ip_middle "$temp_path_binlog"
    transfer_apply_mysql_binlog $scp_file_need_to_do
  fi
}

# running

# 开始
hello_world

# GET: binlog info
#echo "MySQL binlog info:"
#echo "###############################################"
#echo "$ip_major:: "
#do_sql $ip_major "show master status;"
#str_mysql_binlog=`get_mysql_binlog_file $ip_major`

#echo "-1:: "
#compute_mysql_binlog_file "$str_mysql_binlog" "-" "1"

#echo "###############################################"
#echo "$ip_middle:: "
#do_sql $ip_middle "show master status;"
#str_mysql_binlog=`get_mysql_binlog_file $ip_middle`

#echo "-1:: "
#compute_mysql_binlog_file "$str_mysql_binlog" "-" "1"

#echo "###############################################"
#echo "$ip_apply:: "
#do_sql $ip_apply "show master status;"
#str_mysql_binlog=`get_mysql_binlog_file $ip_apply`

#echo "-1:: "
#compute_mysql_binlog_file "$str_mysql_binlog" "-" "1"

#echo "###############################################"

# call scp
# running this script??
call_scp

# 结束
bye_world

# dispaly

# finished
