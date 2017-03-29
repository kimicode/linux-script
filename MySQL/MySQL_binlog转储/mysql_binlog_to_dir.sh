# Script
# Language: Shell
# Author: adamhuan

# pre-check
# 1. MySQL开binlog
# 2. SSH互通（两两之间：1-2 / 2-3）
# 3. 提前创建好需要的目录

# begin

mysql_ip_1=10.158.1.94

# variable

# ------------
# changed: 2017年3月16日

# 针对不同的节点主机的不同的认证信息

# machine 1
mysql_user_1='root'

mysql_password_1="Abcd1@34"
#mysql_password_1="Abcd!234"

mysql_port_1="3306"
file_mysql_cnf_1="/etc/my.cnf"

# 接下来需要出传送的文件
scp_file_need_to_do_min=""
scp_file_need_to_do_max=""

# 存放，脚本抓取的当前的binlog的名字
str_mysql_binlog=""

# 接下来需要出传送的文件列表
scp_file_need_to_do_list=""

# ---------
#需要传输的日志序列

# 当前的binlog的数字值
int_current_binlog_number=""

# 已经传过的binlog的数字的值
int_alread_binlog_number=""

# SCP 传输：源端
#path_binlog_dir=""
#string_search_binlog=""

identified_binlog="mysql-bin"
identified_binlog_dir="/var/lib/mysql"

# ---------
#与脚本级配置文件有关的变量
# ------------

# 脚本运行的时候会自行创建
script_conf=mysql_auto_binlog.conf

#--> version 2
parameter_scp_already_num=""
parameter_scp_current_num=""

# ---------
# 传输操作
# ---------

#该目录需要，提前创建
scp_local_path="/backup_me/binlog"

# ------------
# Functions define area
# ------------

# 生成脚本开始于结束的时间戳信息
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

# 执行SQL命令
function do_sql() {
  # variable
  func_str_ip="$1"
  func_str_sql="$2"

  # ----------------------
  # changed

  func_str_user="$3"
  func_str_password="$4"
  func_str_port="$5"

  echo

  # action
  # 本场景中不涉及到对MySQL某个库的操作，所以没有选择[db]
  # mysql -u $user -p"$password" $db -N -e "$f_sql_str"
  mysql -h"$func_str_ip" -P$func_str_port -u "$func_str_user" -p"$func_str_password" -N -e "$func_str_sql"
}

# 获得binlog的当前信息
# ---> 在本脚本中，当前的binlog信息，只需要采集【machine 1】
function get_mysql_current_binlog_file() {
  # variable
  func_str_binlog_file=""

  # action
  func_str_binlog_file=`do_sql "$mysql_ip_1" "show master status;" "$mysql_user_1" "$mysql_password_1" "$mysql_port_1" | awk '{print $1}'`

  # thrown out
  echo $func_str_binlog_file
}

# 获得当前BINLOG的数字信息
function get_mysql_current_binlog_file_number() {
  # logical
  #func_result=`echo $str_mysql_binlog | cut -d'.' -f2 | rev  | cut -d'0' -f1 | rev`
  func_result=`echo $str_mysql_binlog | cut -d'.' -f2 | sed 's/^0\+//'`

  # throw out
  echo $func_result
}

function search_mysql_binlog_file() {
    # variable
    func_binlog_search_number="$1"
    func_binlog_dir="$path_binlog_dir"
    func_binlog_search_string="$string_search_binlog"

    # logical
    temp_list=`ls -tr $identified_binlog_dir | grep "$identified_binlog"` #可行的
    #temp_list=`ls -tr $func_binlog_dir | grep "$func_binlog_search_string"` #可行的

    for item_binlog in $temp_list
    do
      #echo "-------- current: $item_binlog"

      func_temp_number=`echo $item_binlog | cut -d'.' -f2`

      func_temp_file_search_count=""

      func_temp_file_source_count=`echo ${#func_temp_number}`
      func_temp_file_search_count=`echo ${#func_binlog_search_number}`

            if [ $func_temp_file_source_count -gt $func_temp_file_search_count ]
            then
              let func_minus=func_temp_file_source_count-func_temp_file_search_count

              for z_c in `seq 1 $func_minus`
              do
                func_binlog_search_number="0"$func_binlog_search_number
              done
            fi

            result=`echo $item_binlog | grep $func_binlog_search_number`

            if [ "$result" != "" ]
            then
              echo $item_binlog
              break
            fi
    done
}

# 在当前的脚本环境中，运行应用binlog生成的sql函数的只可能是【machine 3】
function do_mysql_import_sql() {
  # variable
  # version 1
  #func_ip="$1"
  #func_str_sql_file="$2"

  # version 2
  # 使用该方法的时候，只需要传递需要应用的SQL文件的名称即可（可以参与循环事件）
  func_str_sql_file="$1"

  # action
  do_sql "$mysql_ip_3" "source $func_str_sql_file" "$mysql_user_3" "$mysql_password_3" "$mysql_port_3"
}

function get_script_conf_value() {
  # variable
  func_parameter="$1"
  func_result=`cat $script_conf | grep "$func_parameter" | cut -d'=' -f2`

  # throw out
  echo "$func_result"
}

# 向文件中写值，如果值不存在就追加，如果值存在，就替换
# 默认参数，为配置文件名称，依赖上述写的文件位置的变量【script_conf】
function fill_value_script_conf() {
  # variable
  # 需要修改的值的参数
  func_parameter_name="$1"

  # 需要修改的值
  func_parameter_value="$2"

  # 用于后续替换判断
  func_parameter_value_old=""

  # variable --> 第一次处理：compute 1
  # 改参数也可以用作：判定参数是否存在，如果拿到了值，则存在，否则不存在，拿到的值可以直接做后续判定
  func_parameter_temp_1=`cat $script_conf | grep "$func_parameter_name"`

  # logical
  if [ "$func_parameter_temp_1" == "" ]
  then
    echo "$func_parameter_name=$func_parameter_value" >> $script_conf
  else

    #logical
    func_parameter_value_old=`get_script_conf_value "$func_parameter_name"`

    sed -i "s/$func_parameter_name=$func_parameter_value_old/$func_parameter_name=$func_parameter_value/" $script_conf

    echo "-----------------"
    echo "[after] conf file content is:"
    cat $script_conf
    echo "-----------------"
    echo ""

  fi

}

# 初始化配置文件，写入内容
function check_script_conf_init() {
  # logical
  fill_value_script_conf "scp_already_num" "1"
  fill_value_script_conf "scp_current_num" "2"
}

# 检测是否存在配置文件，不存在就创建，如果存在，则不做进一步的校验。
# 后面，进一步的校验可以包含配置文件中的参数与内容的校验，如果为空，则异常，否则，通过。该方法，在后面的版本中加强
# 脚本级【script_conf】配置文件，只会存放在脚本运行的机器上，并且和脚本位于同一目录路径之内
# 在当前的场景中，脚本只在节点一运行
# 该函数的正确运行依赖于定义的变量：script_conf
function check_script_conf_is_alive() {
  # logical

  #判断文件是否存在
  if [ -f $script_conf ]
  then
    echo "Configure file [$script_conf] is exist."
  else
    echo "Configure file [$script_conf] [is not] exist."

    # 如果不存在，就立刻创建
    echo "Configure file [$script_conf] --> create it"
    touch $script_conf

    # 创建完成后，立即初始化
    check_script_conf_init
  fi

  echo ""
}

# 从配置文件中读取值，并填充变量
# 主要依赖上面设定的变量：
#parameter_scp_already_num=""
#parameter_scp_current_num=""

function fill_value_scp_variable() {
  # logical
  parameter_scp_already_num=`get_script_conf_value "scp_already_num"`
  parameter_scp_current_num=`get_script_conf_value "scp_current_num"` #在后面，增加判断进程是否已经在跑，然后再启用该参数
}

# 然后，可以根据上面所设定的值，制造队列了
# 在这个循环序列中，可以通过【while】来操作，而不是for，因为可以更灵活
# 在SCP的时候，需要在本地也转储一次，转储位置【scp_local_path】

function list_do_scp() {
  # variable
  #scp_file_need_to_do_min=`let parameter_scp_already_num+1` #循环的开始点
  scp_file_need_to_do_min=$(($parameter_scp_already_num+1)) #循环的开始点

  func_scp_file_name=""

  # version 1
  #scp_file_need_to_do_max=`let int_current_binlog_number-1` #循环的结束点
  scp_file_need_to_do_max="$int_current_binlog_number" #循环的结束点

  echo ""

  while [ $scp_file_need_to_do_min -lt $scp_file_need_to_do_max ]
  do
    echo "--------- current: $scp_file_need_to_do_min"
    fill_value_script_conf "scp_current_num" "$scp_file_need_to_do_min"

    # version 2
    temp_file_1=`search_mysql_binlog_file "$scp_file_need_to_do_min"`

    #temp_dir="$path_binlog_dir" # 这里用变量有问题，但是直接赋值却没问题？ 也许是上面rev翻转的问题？
    temp_dir="/var/lib/mysql" # 这样就没问题？

    temp_full="$temp_dir/$temp_file_1"

    echo "full path: $temp_full" # 为什么拿不到值？

    echo "Do COPY"
    result_local_cp=`cp -rf "$temp_full" "$scp_local_path"`

    #应用完成，将当前的写入配置文件
    fill_value_script_conf "scp_already_num" "$scp_file_need_to_do_min"

    echo ""
    # incease
    let "scp_file_need_to_do_min++"
  done
  echo ""
}

# call_scp
# if run this script?
function call_scp() {
  # variable
  int_current_purpose=$(($int_current_binlog_number-1))

  echo "-----------------------------------"
  echo "int_alread_binlog_number --> $parameter_scp_already_num"
  echo "int_current_purpose --> $int_current_purpose"

  #statements
  if [ "$int_current_purpose" == "$parameter_scp_already_num" ]
  then
    echo "No need call function:: do_scp"

    echo ""
  fi
}

# ------------
# running area
# ------------

# begin
say_begin_end "begin"

# 脚本运行后，立即检查是否存在配置文件
# 在后面，确认脚本是否要开始执行后续逻辑都需要依赖：
# 1. 配置文件
# 2. 已传队列 与 待传队列 的比较结果
# 所以，脚本级配置文件，必须最优先处理
# FUNCTION: check_script_conf_is_alive --> test
show_banner "FUNC: check_script_conf_is_alive --> test"
check_script_conf_is_alive

# 在上面创建了配置文件后，开始向其中灌值
# FUNCTION: check_script_conf_init --> test
#show_banner "FUNC: check_script_conf_init --> test"
#check_script_conf_init

# 向变量中填值
# FUNCTION: fill_value_scp_variable --> test
show_banner "FUNC: fill_value_scp_variable --> test"
fill_value_scp_variable
echo "[parameter_scp_already_num] is --> $parameter_scp_already_num"
echo "[parameter_scp_current_num] is --> $parameter_scp_current_num"

# FUNCTION: do_sql --> test
#show_banner "FUNC: do_sql --> test"

#echo ""
#do_sql "$mysql_ip_1" "show master status;" "$mysql_user_1" "$mysql_password_1" "$mysql_port_1"
#do_sql "$mysql_ip_2" "show master status;" "$mysql_user_2" "$mysql_password_2" "$mysql_port_2"
#do_sql "$mysql_ip_3" "show master status;" "$mysql_user_3" "$mysql_password_3" "$mysql_port_3"

# FUNCTION: get_mysql_current_binlog_file --> test
show_banner "FUNC: get_mysql_current_binlog_file --> test"
str_mysql_binlog=`get_mysql_current_binlog_file`
int_current_binlog_number=`get_mysql_current_binlog_file_number`
echo "variable: [str_mysql_binlog] is: $str_mysql_binlog"
echo "variable: [int_current_binlog_number] is: $int_current_binlog_number"

# FUNCTION: call_scp --> test
show_banner "FUNC: call_scp --> test"
call_scp

#基础信息都拿到了

# 开始传递BINLOG，从第一台机器到第二台
# FUNCTION: list_do_scp --> test
show_banner "FUNC: list_do_scp --> test"
list_do_scp

# end
say_begin_end "end"

# ------------
# finished
