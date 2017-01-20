#!/bin/bash

# Script
# Name: mysql_auto_manage_binlog.sh
# DB vendor: MySQL
# Linux vendor: RHEL / CentOS

# Author: adamhuan
# Blog: d-prototype.com

# variable

# binlog的过滤条件
str_identify_binlog="-bin."

# binlog的清理时长
# 单位，天
how_long_binlog_be_purged="2"

# string
str_mysql_ip=""
str_mysql_user="root"
str_mysql_password="leochen"

# file director name
file_mysql_conf="/etc/my.cnf"

# file path
path_mysql_binlog="/data/mysql/binlog"
#path_mysql_binlog=`cat $file_mysql_conf | grep --color "log-bin =" | cut -d'#' -f1 | cut -d'=' -f2 | rev | cut -d'/' -f2,3,4,5 | rev`

# Notice:
# yum install -y tree
# mkdir -p /backup/{binlog,daily}
# 转储binlog的第一次目录
path_binlog_backup=/backup/binlog
# 打包每日binlog的第二次目录
# 每日维护任务：
# 44 0 * * * find /backup/daily/  -name "*" -cmin +50 -exec rm -f {} \;
# cmin,多少分钟前
# ctime，多少天前
# c，创建
path_binlog_daily=/backup/daily

path_mysql_datafile=""


# function
function say_hello(){
  echo "================="
  echo "auto manage mysql binlog"
  echo "Major: Backup / Clean"
  echo "================="
  echo "Begin:: "`date "+|%Y-%m-%d|%H:%M:%S|"`
  echo ""
}

function say_bye(){
  echo ""
  echo "================="
  echo "Finished:: "`date "+|%Y-%m-%d|%H:%M:%S|"`
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

function get_mysql_binlog_file() {
  # variable
  func_ip="$1"
  func_str_binlog_file=""

  # action
  func_str_binlog_file=`do_sql "$func_ip" "show master status" | awk '{print $1}'`

  # thrown out
  echo $func_str_binlog_file
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

# run for computer
#获取当前的BINLOG
file_mysql_binlog=`get_mysql_binlog_file localhost`
file_mysql_binlog_full=$path_mysql_binlog/$file_mysql_binlog

# function after computer

# 用于传输的方法
# 输入参数：
# $1，当前的binlog
function do_binlog_cp(){
  # variable
  #f_current_binlog="$1"
  f_current_binlog=$file_mysql_binlog

  for binlog_item in `ls $path_mysql_binlog | grep --color "$str_identify_binlog" | grep -v -E "index|$f_current_binlog"`
  do
    echo "Current item is:: $binlog_item"
    echo "Target directory is:: $path_binlog_backup"
    cp -rf $path_mysql_binlog/$binlog_item $path_binlog_backup
    echo ""
  done

}

#打包方法
#参数：当前日期【date "+|%Y-%m-%d|"】
#文件名与路径不能包含空格，当前脚本需要改进后才能支持空格与中文
function do_tar(){
  f_str_current_date=`date "+|%Y-%m-%d_%H:%M:%S|" | cut -d'|' -f2`
  f_str_tar_file_name_full=$path_binlog_daily/"mysql_binlog_$f_str_current_date.tar.gz"

  echo "Do Tar"
  echo "Source direcotry:: $path_binlog_backup"
  echo "Target filename:: $f_str_tar_file_name_full"

  tar -czvf $f_str_tar_file_name_full $path_binlog_backup/

  echo ""

}

#MySQL清理指令
#安全性考虑，Purge为最后操作的指令，在所有备份结束后
#purge
#19日，清理17日，保留18日
#参数：也要活得当前日期以参考
#写灵活一点，跟参数，单位，天数，表示多少天以前的
#当前19号，参数2，表示清理17日最后的一条binlog

#方法拆分开：
#计算时间，返回purge要传入的binlog名称
#真正执行purge
#MySQL的Purge会自动清理文件系统上的对应文件

#参数
# $1,执行运算符
# $2,偏移量（目前单位，天）
function do_mysql_purge() {
  #variable
  f_str_current_date=`date "+|%Y-%m-%d|" | cut -d'|' -f2`
  f_do="$1"
  f_num="$2"

  f_day=`date "+|%Y-%m-%d|" | cut -d'|' -f2 | cut -d'-' -f3`
  f_new_day=""

  let f_new_day=f_day$f_do$f_num

  f_new_date_full=`date "+|%Y-%m-%d|" | cut -d'|' -f2 | cut -d'-' -f1,2`"-$f_new_day"

  f_file_purge_binlog=`ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|" $path_mysql_binlog | grep $f_new_date_full | tail -n 1 | awk '{print $7}'`

  #echo "Current Day:: $f_day"
  #echo "New Day:: $f_new_day"
  #echo "New Date Full:: $f_new_date_full"
  echo "Purge binlog is:: $f_file_purge_binlog"

  echo "!!! do purge !!!"

  do_sql localhost "purge master logs to '$f_file_purge_binlog'"

  echo "!!! Already done !!!"

  echo ""
}

# display

# run

## started
say_hello

### -----------------------
### acture running area

#将原始的binlog传世到第一目录，转储binlog的目录
do_binlog_cp

#将第一幕路，转储的binlog，按照每日，打包到第二目录，daily
do_tar

# 清理MySQL的binlog
# 清理间隔
do_mysql_purge "-" "$how_long_binlog_be_purged"

### -----------------------

## done
say_bye

# finished
