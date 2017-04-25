#!/bin/bash

# file_name : analyze_mysql_slow_sql_log.sh
# author: adamhuan
# blog: www.d-prototype.com

# variable

# MySQL
mysql_user='root'
mysql_password='Abcd1@34'
mysql_port='3306'

# File content
# 需要分析的目标日志的绝对地址
file_path="/software/main0101.log"

# function

function say_begin_end() {
  # variable
  func_str_sign="$1"

  # logical
  echo "==============================="
  echo "$func_str_sign @ Time is: "`date "+|%Y-%m-%d|%H:%M:%S|"`
  echo "==============================="

  echo ""

}

# 不同的执行阶段的输出分割
function show_banner() {
  # variable
  func_str_sign="$1"

  # logical
  echo "------------------"
  echo "section @ name is: [$func_str_sign]"
  echo "------------------"

  echo ""

}

# 判断变量是否为空，否则就赋予提供的默认值
function variable_if_null_then() {
  eval loop_var_name="$1"
  #eval $loop_var_name="$2"

  eval echo "current variable is: '$'$loop_var_name, value is: \$$loop_var_name"

  if [ "`eval echo '$'$loop_var_name`" == "$2" ]
  then
          eval $loop_var_name="$3"
          echo "-----> after change"
          eval echo "current variable is: '$'$loop_var_name, value is: \$$loop_var_name"
  fi
  echo ""
}

# 执行SQL命令
function do_sql() {
  # variable
  func_str_ip="$1"
  func_str_sql="$2"

  # ----------------------
  # changed

  func_str_user="$3"
  variable_if_null_then func_str_user "" $mysql_user

  func_str_password="$4"
  variable_if_null_then func_str_password "" $mysql_password

  func_str_port="$5"
  variable_if_null_then func_str_port "" $mysql_port

  # action
  # 本场景中不涉及到对MySQL某个库的操作，所以没有选择[db]
  # mysql -u $user -p"$password" $db -N -e "$f_sql_str"
  mysql -h"$func_str_ip" -P$func_str_port -u "$func_str_user" -p"$func_str_password" -N -e "$func_str_sql"
}

#根据传入的行号，查询最接近的空行（向下查询）
#针对不同的剥离
function near_space_line_number() {
  func_split_string="$2"
  func_current_line_number="$3"
  func_block_data="$1"

  split_list=""

  if [ "$func_split_string" == " " ]
  then
    func_split_string='^$'
    split_list=`grep -n "$func_split_string" $file_path | cut -d':' -f1`
  else
    split_list=`cat -n $file_path | grep "$func_split_string" | awk '{print $1":"$3}' | cut -d':' -f1`
  fi

  #echo "split string is [$func_split_string]"
  #echo "space line list is [$space_line_list]"

  for num_cursor in $split_list
  do
    if [ $func_current_line_number -lt $num_cursor ]
    then
      echo "$num_cursor"
      break
    fi
  done

}

# 抓取日志循环区间
# 两种模式：按照“__”划分的大循环；按照特定的属性名称去过滤抓取的
# 对所有共性的剥离
function catch_big_loop(){
  loop_signal="$1"

  # 与指定过滤字段行号有关的动态数组
  loop_line_number_array=(`cat -n $file_path | grep "$loop_signal" | awk '{print $1}'`)
  loop_line_number_array_length=`echo ${#loop_line_number_array[@]}`

  for((i=0;i<$loop_line_number_array_length;i++))
  do

    echo "**********************************"

    # set variable
    loop_length=$(($loop_line_number_array_length-1))
    begin_index=$i
    end_index=$(($i+1))

    begin_num=`echo ${loop_line_number_array[$begin_index]}`
    end_num=`echo ${loop_line_number_array[$end_index]}`
    end_num=$(($end_num-1))

    if [ "$i" == "$loop_length" ]
    then
      echo "current loop is: $i"
      echo "length of ARRAY is: $loop_line_number_array_length"
      echo "length of loop is: $loop_length"
      echo "Touch end edge."

      end_num=`cat $file_path | wc -l`

    fi

    # display

    #echo "**********************************"

    echo "range index is: $begin_index --> $end_index"
    echo "range is: $begin_num --> $end_num"

    search_string=$begin_num","$end_num"p"
    echo "Search String is: [$search_string]"

    echo "-----------"
    echo "Content is:"
    echo "-----------"
    first_block_data=`sed -n "$search_string" $file_path`
    echo "$first_block_data"

    # Test
    echo "-----------"
    echo "根据属性取值："
    echo "-----------"

    show_banner "Count"
    echo "$first_block_data" | grep --color "^Count"

    show_banner "Time"
    echo "$first_block_data" | grep --color "^Time"

    show_banner "Lock Time (s)"
    echo "$first_block_data" | grep --color "^Lock Time (s)"

    show_banner "Rows sent"
    echo "$first_block_data" | grep --color "^Rows sent"

    show_banner "Rows examined"
    echo "$first_block_data" | grep --color "^Rows examined"

    show_banner "Database"
    echo "$first_block_data" | grep --color "^Database"

    # 会被空格分割
    show_banner "Users"
    echo "$first_block_data" | grep --color "^Users"

    # 会被空格分割
    show_banner "Query sample"
    echo "$first_block_data" | grep --color "^Query sample"

    echo ""

  done

}


# running and display



# ---- test
do_sql localhost "show databases"
near_space_line_number " " 8
near_space_line_number "Query sample" 45

catch_big_loop "__"

# finished
