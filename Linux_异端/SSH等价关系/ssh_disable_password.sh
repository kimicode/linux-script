#!/bin/bash

# ssh disable password

# variable
str_username=root
str_password=oracle

# command string

#str_command='date "+|%Y-%m-%d|%H:%M:%S|"'

str_command_1='ssh-keygen -t rsa'

# function

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

# running

param_all=$@

echo "Param:: $param_all"

for for_param_item_1 in $param_all
do

echo "--------------"
echo "current: $for_param_item_1"

 # do something
 do_linux_by_ssh $for_param_item_1 $str_username $str_command_1

 for for_param_item_2 in $param_all
 do
  echo "## LOOP ## $for_param_item_2"

  do_linux_by_ssh $for_param_item_1 $str_username "ssh-copy-id -i ~/.ssh/id_rsa.pub $for_param_item_2"

  echo ""
  echo ""

  echo "## Test:: $for_param_item_1 ---> $for_param_item_2"

  do_linux_by_ssh $for_param_item_2 $str_username "hostname; ifconfig | grep 'inet addr' | head -n 1 | cut -d':' -f2 | cut -d' ' -f1; date"

  echo ""

 done

echo ""

done
