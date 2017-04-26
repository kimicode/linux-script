#!/bin/bash

# file_name : analyze_mysql_slow_sql_log.sh
# author: adamhuan
# blog: www.d-prototype.com

# variable

# MySQL
mysql_user='root'
mysql_password='Abcd1@34'
mysql_port='3306'

# DATABASE TABLES

# init sql:
# create database adamhuan;
# create table adamhuan.slow_sql_details(id int(43) not null auto_increment,count longtext,time longtext,lock_time longtext,row_sent longtext,row_examined longtext,database_name longtext,users longtext,query_sample longtext,primary key(id));

schemal_name="adamhuan"
table_name="slow_sql_details"

full_table_address=$schemal_name"."$table_name

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

  #eval echo "current variable is: '$'$loop_var_name, value is: \$$loop_var_name"

  if [ "`eval echo '$'$loop_var_name`" == "$2" ]
  then
          eval $loop_var_name="$3"
          #echo "-----> after change"
          #eval echo "current variable is: '$'$loop_var_name, value is: \$$loop_var_name"
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

# 根据传入的行号，查询最接近的空行（向下查询）
# 针对不同的剥离
# ----------------
# 版本二：应该只是给序列和当前值，来判断最接近的值。
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
    if [[ $func_current_line_number < $num_cursor ]]
    then
      echo "$num_cursor"
      break
    fi
  done

}

# 计算，最近，最大值
function near_bigger_one_1() {
  # variable
  origi_block_data="$1"
  list_data="$2"
  current_index="$3"

  is_in="no"

  for list_item in $list_data
  do
    echo "## current is: $list_item"
    if [[ $current_index < $list_item ]]
    then
      echo "$list_item"
      is_in="yes"
      break
    fi
  done

  if [ "$is_in" == "no" ]
  then
    echo "$origi_block_data" | wc -l
  fi

}

function near_bigger_one_2() {
  # variable
  #origi_block_data="$1"
  list_data="$1"
  line_counts="$2"
  current_index="$3"

  is_in="yes"

  for list_item_biger in $list_data
  do
    #echo "## current is: $list_item"
    if [[ $current_index > $list_item_biger ]]
    then
      is_in="no"
    fi
    if [[ $current_index < $list_item_biger ]]
    then
      echo "$list_item_biger"
      is_in="yes"
      break
    fi
  done

  if [ "$is_in" == "no" ]
  then
    echo "$line_counts"
    is_in="yes"
  fi

}

function near_bigger_one() {
  # variable
  #origi_block_data="$1"
  list_data_near="$1"
  line_counts="$2"
  current_index="$3"

  is_in="no"

  #echo ""
  #echo "******************************"
  #echo "compute whether in the list or not"
  #echo "******************************"
  #echo "List data is: [$list_data_near]"
  #echo "Search cursor is @ [$current_index]"
  #echo "block data length is: [$line_counts]"
  #echo "------------"

  for l_cursor in $list_data_near
  do
    #echo "%%%% $l_cursor %%%%"
    #echo "-------- Current : $current_index"

    #if [[ $current_index < $l_cursor ]]
    if [ $current_index -lt $l_cursor ]
    then
      #echo "Cursor : $l_cursor"
      #echo "Current : $current_index"
      is_in="yes"
      echo "$l_cursor"
      break;
    fi
  done

  if [ "$is_in" == "no" ]
  then
    echo "$line_counts"
    #is_in="yes"
  fi


  #echo "*** ending ***"
  #echo ""

}

function get_block_by_first_index_until_space(){
  block_me="$1"
  begin_index="$2"
  space_list="$3"

  total_line_counts=`echo "$block_me" | wc -l`

  begin_index=$(($begin_index+1))

  #near_bigger_one "$space_list" "$total_line_counts" "$begin_index"
  end_index_me=`near_bigger_one "$space_list" "$total_line_counts" "$begin_index"`

  sed_string=$begin_index","$end_index_me"p"

  echo ""
  echo "--> special block section sed string is: [$sed_string]"
  echo ""

  #echo "@@@@@@@@@@@@@@@@@@@@"

  # 输出内容
  echo "$block_me" | sed -n "$sed_string"

  #echo "@@@@@@@@@@@@@@@@@@@@"
  #echo ""
}

function fill_value_to_variable(){
  func_block_data="$1"
  func_search_string="$2"
  func_variable="$3"

  temp_value=""

  func_fill_begin_index=""
  func_fill_end_index=""

  # 计算空行值
  #block_space_line_list=(`echo "$func_block_data" | grep -n "^$" | cut -d':' -f1`)
  block_space_line_list=`echo "$func_block_data" | grep -n "^$" | awk -F':' '{printf $1" " }'`

  # display
  echo "Current Searching String is: [$func_search_string]"

  if [ "$func_search_string" == "Time" ]
  then
    temp_value=`echo "$func_block_data" | cat -n | grep "$func_search_string" | cut -d':' -f2`
    func_fill_begin_index=`echo "$func_block_data" | cat -n | grep "$func_search_string" | awk '{print $1}'`
  else
    temp_value=`echo "$func_block_data" | cat -n | grep "$func_search_string" | head -n 1  | cut -d':' -f2`
    func_fill_begin_index=`echo "$func_block_data" | cat -n | grep "$func_search_string" | head -n 1 | awk '{print $1}'`
  fi

  echo "temp_value is:"
  echo $temp_value

  if [[ ("$temp_value" == " ") && ("$func_search_string" == "Users") ]]
  then
    echo "temp_value is EMPTY, and current searching is [USERS]"
    echo "Line space is on: [$block_space_line_list]"
    echo "current index is: [$func_fill_begin_index]"
    echo "@@@@@@@@@@@@@@@@@@@@"
    get_block_by_first_index_until_space "$func_block_data" "$func_fill_begin_index" "$block_space_line_list"
    echo "@@@@@@@@@@@@@@@@@@@@"
    echo ""

  fi

  if [[ ("$temp_value" == "") && ("$func_search_string" == "Query sample") ]]
  then
    echo "temp_value is EMPTY, and current searching is [Query sample]"
    echo "Line space is on: [$block_space_line_list]"
    echo "current index is: [$func_fill_begin_index]"
    echo "@@@@@@@@@@@@@@@@@@@@"
    get_block_by_first_index_until_space "$func_block_data" "$func_fill_begin_index" "$block_space_line_list"
    echo "@@@@@@@@@@@@@@@@@@@@"
    echo ""

  fi

  echo "==========================="
  echo ""

}

# 根据单独的BLOCK文本块，抓取数据
# 检索对象，搜索值，存储结果变量
function analyze_block_data() {

  # variables
  func_block_data="$1"

  # mysql sql data

  data_count=""
  data_time=""
  data_lock_time=""
  data_rows_sent=""
  data_rows_examined=""
  data_database=""
  data_users=""
  data_query_sample=""

  # ---------- 第一个版本
  #attr_list_array=("^Count" "^Time" "^Lock Time (s)" "^Rows sent" "^Rows examined" "^Database" "^Users" "^Query sample")
  #attr_list_array_length=`echo ${#attr_list_array[@]}`
  #loop_length=$(($attr_list_array_length-1))

  #echo "Array list length is: [$attr_list_array_length]"
  #echo "Loop length is: [$loop_length]"

  #for((i=0;i<$attr_list_array_length;i++))
  #do
  #  echo "-----"
  #  current_item_name=`echo ${attr_list_array[$i]}`
  #  echo "Analyze Block Data: [$current_item_name]"

  #  echo "-----"
  #  echo ""
  #  done

  # ---------- 第二个版本
  fill_value_to_variable "$func_block_data" "Count" "data_count"
  fill_value_to_variable "$func_block_data" "Time" "data_time"
  fill_value_to_variable "$func_block_data" "Lock Time (s)" "data_lock_time"
  fill_value_to_variable "$func_block_data" "Rows sent" "data_rows_sent"
  fill_value_to_variable "$func_block_data" "Rows examined" "data_rows_examined"
  fill_value_to_variable "$func_block_data" "Database" "data_database"
  fill_value_to_variable "$func_block_data" "Users" "data_users"
  fill_value_to_variable "$func_block_data" "Query sample" "data_query_sample"

}

function analyze_block_data_1() {
  func_block_data="$1"

  data_count=""
  data_time=""
  data_lock_time=""
  data_rows_sent=""
  data_rows_examined=""
  data_database=""
  data_users=""
  data_query_sample=""

  line_count=`echo "$func_block_data" | wc -l`

  echo "Line count about BLOCK data is: [$line_count]"
  echo "###### ---> attribute:"

  #attribute_list="^Count ^Time '^Lock Time (s)' '^Rows send' '^Rows examined' '^Database' '^Users' '^Query sample'"
  #for attribute_item in $attribute_list
  #do
  #  echo "attribute item @ $attribute_item"
  #done

  #attribute_list=("^Count" "^Time" "^Lock Time (s)" "^Rows sent" "^Rows examined" "^Database" "^Users" "^Query sample")
  #attribute_list_length=`echo ${#attribute_list[@]}`

  #for((c=0;c<$attribute_list_length;c++))
  #do
  #  item_index=$c
  #  item_value=`echo ${attribute_list[$item_index]}`

  #  echo "Current index is: [$item_index], value is: [$item_value]"

  #  echo ""

  #done

  # 第二版本
  #fill_value_to_variable "$func_block_data" "Count" "data_count"
  #fill_value_to_variable "$func_block_data" "Time" "data_time"
  #fill_value_to_variable "$func_block_data" "Lock Time (s)" "data_lock_time"
  #fill_value_to_variable "$func_block_data" "Rows sent" "data_rows_sent"
  #fill_value_to_variable "$func_block_data" "Rows examined" "data_rows_examined"
  #fill_value_to_variable "$func_block_data" "Database" "data_database"
  #fill_value_to_variable "$func_block_data" "Users" "data_users"
  #fill_value_to_variable "$func_block_data" "Query sample" "data_query_sample"

  fill_value_to_variable "$func_block_data" "Users" "data_users"
  fill_value_to_variable "$func_block_data" "Query sample" "data_query_sample"

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
    #end_num=$(($end_num-1))
    #end_num=$(($end_num+1))

    if [ "$i" == "$loop_length" ]
    then
      #echo "current loop is: $i"
      #echo "length of ARRAY is: $loop_line_number_array_length"
      #echo "length of loop is: $loop_length"
      #echo "Touch end edge."

      end_num=`cat $file_path | wc -l`

    fi

    # display

    #echo "**********************************"

    #echo "range index is: $begin_index --> $end_index"
    #echo "range is: $begin_num --> $end_num"

    search_string=$begin_num","$end_num"p"
    #echo "Search String is: [$search_string]"

    #echo "-----------"
    #echo "Content is:"
    #echo "-----------"
    first_block_data=`sed -n "$search_string" $file_path`
    #echo "$first_block_data" | cat -n

    # Test
    echo "-----------"
    echo "根据属性取值："
    echo "-----------"

    #show_banner "Count"
    #echo "$first_block_data" | grep --color "^Count"
    #echo ""

    #show_banner "Time"
    #echo "$first_block_data" | grep --color "^Time"
    #echo ""

    #show_banner "Lock Time (s)"
    #echo "$first_block_data" | grep --color "^Lock Time (s)"
    #echo ""

    #show_banner "Rows sent"
    #echo "$first_block_data" | grep --color "^Rows sent"
    #echo ""

    #show_banner "Rows examined"
    #echo "$first_block_data" | grep --color "^Rows examined"
    #echo ""

    #show_banner "Database"
    #echo "$first_block_data" | grep --color "^Database"
    #echo ""

    # 会被空格分割
    #show_banner "Users"
    #echo "$first_block_data" | grep --color "^Users"
    #echo ""

    # 会被空格分割
    #show_banner "Query sample"
    #echo "$first_block_data" | grep --color "^Query sample"
    #echo ""

    # ---------- 第二种方式
    #analyze_block_data
    analyze_block_data_1 "$first_block_data"

    echo ""

  done

}

# running and display

# ---- test
do_sql localhost "show databases"
near_space_line_number " " 8
near_space_line_number "Query sample" 45

catch_big_loop "__"

do_sql localhost "desc $full_table_address"

# finished
