#!/bin/bash

# Script Name: MySQL_MHA_Enhance_shell.sh
# About: auto register in MySQL Replication
# Script Type: Bash Shell
# OS: RHEL6 / CentOS6
# Architecture: MySQL MasterHA

# Auther: adamhuan
# Blog: d-prototype.com

# --------------------------
# variable and file path

# Part:: this script
str_mha_application=$1

# Part:: Linux
# Account info
str_linux_username="root"       #不同的环境，一定要注意的参数

# Part:: MySQL
# Account info
str_mysql_username="root"       #不同的环境，一定要注意的参数
str_mysql_password=Abcd1@34     #不同的环境，一定要注意的参数

str_repl_username="replme"      #不同的环境，一定要注意的参数
str_repl_password=Or@cle123     #不同的环境，一定要注意的参数

# Part:: MHA
# pid
#str_pid_masterha_manager=`ps -ef | grep masterha_manager | grep perl | awk '{print $2}'`

str_pid_masterha_manager=`ps -ef | grep masterha_manager | grep "$str_mha_application" | grep perl | awk '{print $2}'`

# file
file_conf_mha_global="/etc/masterha_default.cnf"

path_conf_mha_application="/etc"    #不同的环境，一定要注意的参数

#file_conf_mha_application="/etc/masterha_application_1.cnf"
file_conf_mha_application="$path_conf_mha_application/$str_mha_application.cnf"   #不同的环境，一定要注意的参数

# file: relation / by computed
file_log_mha_manager=`cat $file_conf_mha_application | grep --color manager_log | cut -d'=' -f2`

# variable: ip info
# 如果MHA中MySQL主库的候选服务器数量超过了两台，也许下面这个list参数，就会排上用场
list_ip_candicate=`cat $file_conf_mha_application | grep -B 2 "^candidate" | grep "hostname" | cut -d'=' -f2`

str_ip_orig_master=`cat $file_log_mha_manager | grep --color "MySQL Master failover" | cut -d'(' -f2 | cut -d':' -f1 | tail -n 1`
str_ip_new_master=`cat $file_log_mha_manager | grep --color "MySQL Master failover" | cut -d'(' -f3 | cut -d':' -f1 | tail -n 1`

str_ip_mha_manager="10.158.1.94"    #不同的环境，一定要注意的参数
str_mysql_port="3306"               #不同的环境，一定要注意的参数

path_file_mha_application_log_dir="/script/log"     #不同的环境，一定要注意的参数
path_file_mha_application_log_file="$path_file_mha_application_log_dir/$str_mha_application.log"

# 为[change master]准备的参数
str_log_file_new_master=""
str_log_pos_new_master=""

# Part:: String SQL
str_sql_mysql_change_master=""

# --------------------------
# function

function do_sql() {
  # variable
  func_str_ip="$1"
  func_str_sql="$2"

  # action
  # 本场景中不涉及到对MySQL某个库的操作，所以没有选择[db]
  # mysql -u $user -p"$password" $db -N -e "$f_sql_str"
  mysql -u $str_mysql_username -h $func_str_ip -p"$str_mysql_password" -P$str_mysql_port -N -e "$func_str_sql"
}

# 获取主库状态信息
#function get_info_mysql_master_new_master() {
  # version ONE
  #str_log_file_new_master=`do_sql "$str_ip_new_master" "show master status" | awk '{print $1}'`
  #str_log_pos_new_master=`do_sql "$str_ip_new_master" "show master status" | awk '{print $2}'`

#}

# 生成orig_master作为slave加入new_master的[change master]SQL命令
function gen_sql_mysql_change_master() {
  #if [[ "$str_log_file_new_master" == "" || $str_log_pos_new_master == "" ]]
  #then
  #  get_info_mysql_master_new_master
  #fi
  #str_sql_mysql_change_master="CHANGE MASTER TO MASTER_HOST='$str_ip_new_master',MASTER_USER='$str_repl_username',MASTER_PASSWORD='$str_repl_password',MASTER_LOG_FILE='$str_log_file_new_master',MASTER_LOG_POS=$str_log_pos_new_master;"

  # version TWO
  func_temp_master_host_sed=`cat $file_log_mha_manager | grep --color "All other slaves should start" | tail -n 1 | cut -d',' -f1 | cut -d'=' -f2 | cut -d\' -f2`
  func_temp_repl_password_sed=`cat $file_log_mha_manager | grep --color "All other slaves should start" | tail -n 1 | rev | cut -d\' -f2`

  func_temp_master_binlog_file=`cat $file_log_mha_manager | grep --color "All other slaves should start" | tail -n 1 | cut -d',' -f3 | cut -d'=' -f2 | cut -d\' -f2`
  func_temp_master_binlog_pos=`cat $file_log_mha_manager | grep --color "All other slaves should start" | tail -n 1 | cut -d',' -f4 | cut -d'=' -f2 | cut -d\' -f2`

  echo "======================"
  echo "@@ func variable: func_temp_master_host_sed = $func_temp_master_host_sed"
  echo "@@ func variable: func_temp_repl_password_sed = $func_temp_repl_password_sed"

  echo "@@ func variable: func_temp_master_binlog_file = $func_temp_master_binlog_file"
  echo "@@ func variable: func_temp_master_binlog_pos = $func_temp_master_binlog_pos"
  echo "======================"

  str_log_file_new_master=$func_temp_master_binlog_file
  str_log_pos_new_master=$func_temp_master_binlog_pos

  str_sql_mysql_change_master=`cat $file_log_mha_manager | grep --color "All other slaves should start" | tail -n 1 | sed "s/'$func_temp_repl_password_sed'/'$str_repl_password'/g" | cut -d':' -f4`
  str_sql_mysql_change_master=`echo $str_sql_mysql_change_master | sed "s/'$func_temp_master_host_sed'/'$str_ip_new_master'/g"`
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

# 处理VIP的事宜
function do_part_vip() {
  do_linux_by_ssh "$str_ip_new_master" "root" "service keepalived start"
  do_linux_by_ssh "$str_ip_orig_master" "root" "service keepalived stop"
}

function do_part_orig_master_is_new_slave() {
  do_linux_by_ssh "$str_ip_orig_master" "root" "service mysql start"
  do_sql "$str_ip_orig_master" "set global read_only=1;"
  do_sql "$str_ip_orig_master" "$str_sql_mysql_change_master"
  do_sql "$str_ip_orig_master" "start slave;"
}

function do_part_mha_master_manager_start() {
  echo "func: do_part_mha_master_manager_start --->"
  echo "Special log file is: $path_file_mha_application_log_file"
  do_linux_by_ssh "$str_ip_mha_manager" "root" "nohup masterha_manager --conf=$file_conf_mha_application --ignore_last_failover < /dev/null > $path_file_mha_application_log_file 2>&1 &"
}

function check_repl() {
  # variable
  func_str_block_status=""

  # version 1
  #func_str_block_status=`masterha_check_repl --conf=$file_conf_mha_application`

  # version 2
  #masterha_check_repl --conf=$file_conf_mha_application > $func_str_block_status

  # version 3
  func_str_block_status=$(masterha_check_repl --conf=$file_conf_mha_application)

  repl_status=`echo "$func_str_block_status" | grep --color "(current master)"`

  echo "------------------"
  echo "fun: check_repl"
  echo ""
  echo "$func_str_block_status"
  echo ""
}

# 如果PID不存在，则执行该脚本，否则，退出
function runable_by_mha_manager_pid() {
  echo "-----------------"
  echo "Script for MySQL Master HA"
  echo "-----------------"
  echo "Begin:: "`date "+|%Y-%m-%d|%H:%M:%S|"`

  #echo "========================"
  #echo "current MySQL REPL is::"
  #check_repl
  #echo "========================"

  if [[ "$str_pid_masterha_manager" == "" ]]
  then
    echo "## masterha_manager is [NOT ALIVED]."
  else
    echo "## masterha_manager is [ALIVED]."
    echo "[masterha_manager] PID is:: $str_pid_masterha_manager"

    # do something.
    echo "## Exit Script"
    exit 0
  fi
}

# --------------------------
# action

# 如果PID不存在，则执行该脚本，否则，退出
echo "------------------"
echo "app: runable_by_mha_manager_pid"
runable_by_mha_manager_pid
echo ""

echo "------------------"
echo "app: gen_sql_mysql_change_master"
gen_sql_mysql_change_master
echo ""
#echo "------------------"
#echo "app: do_part_vip"
#do_part_vip
#echo ""

echo "------------------"
echo "app: do_part_orig_master_is_new_slave"
do_part_orig_master_is_new_slave
echo ""

echo "------------------"
echo "app: do_part_mha_master_manager_start"
#do_part_mha_master_manager_start
# version 1
#nohup masterha_manager --conf=$file_conf_mha_application --ignore_last_failover &

# version 2
echo "Special log file is: $path_file_mha_application_log_file"
nohup masterha_manager --conf=$file_conf_mha_application --ignore_last_failover < /dev/null >> $path_file_mha_application_log_file 2>&1 &

echo ""

# --------------------------
# Show time

# ---------
# version one
# ---------
#echo "new master is:: $str_ip_new_master"
#echo "Master log file is:: $str_log_file_new_master"
#echo "Master log POS is:: $str_log_pos_new_master"
#echo "orig master --> new master ## SQL: CHANGE MASTER ## is:: $str_sql_mysql_change_master"

# ---------
# version two
# ---------
echo "================="
echo "MySQL info:"

echo "## Account and Password"
echo "username @ $str_mysql_username"
echo "password @ $str_mysql_password"
echo ""
echo "--- for REPLICATION ---"
echo "repl @ username ## $str_repl_username"
echo "repl @ password ## $str_repl_password"
echo ""
echo "## Master Server info"

#version 1
#echo "log file @ Master ## $str_log_file_new_master"
#echo "log pos  @ Master ## $str_log_pos_new_master"

#version 2
echo "log file @ Master ## $str_log_file_new_master"
echo "log pos  @ Master ## $str_log_pos_new_master"

echo ""

echo "================="
echo "SQL statement:"
echo "[CHANGE MASTER] -->"
echo "$str_sql_mysql_change_master"
echo ""

echo "================="
echo "MasterHA info:"

echo "## File and Path"
echo "MHA Global config file @ $file_conf_mha_global"
echo "MHA Application config file @ $file_conf_mha_application"
echo "MHA Log file:: masterha_manager @ $file_log_mha_manager"
echo ""
echo "## Architecture"
echo "Candicate Server list::"
echo "$list_ip_candicate"
echo ""
echo "## IP"
echo "MHA Manager Server:: $str_ip_mha_manager"
echo "Last:: new master:: $str_ip_new_master"
echo "Last:: orig master:: $str_ip_orig_master"
echo ""

# --------------------------
echo "-----------------"
echo "Finished:: "`date "+|%Y-%m-%d|%H:%M:%S|"`
# Done
