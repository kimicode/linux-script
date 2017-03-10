# check_oracle_dataguard.sh

# variable
str_command_sql=""
str_temp_output=""

# function

function say_hi_and_bye() {
  # variable
  str_sign=$1

  # logical
  echo "================================="
  echo "$str_sign @ "`date "+|%Y-%m-%d|%H:%M:%S|"`
  echo "----------------"

  echo ""

}

function display_banner() {
  # variable
  f_str_banner="$1"
  # logical
  echo "--------------"
  echo "Current:: $f_str_banner"
  echo "--------------"

  echo ""

}

function do_oracle_sql() {
  # variable
  #这里写SQL的时候注意转义【$】为【\$】
  f_str_command="$1"

  #linesize
  f_str_linesize="$2"

  #pagesize
  f_str_pagesize="$3"

  #col
  f_Str_col="$4"

  # ---> compute variable
  f_str_command_sed=`echo $f_str_command | sed 's/#/\\#/g'`

  f_str_temp_output_1=""

  # logical
sqlplus -S / as sysdba <<SQLPLUS
set heading on feedback off pagesize 500 linesize 400 verify off echo off
col name for a68

$f_str_linesize
$f_str_pagesize
$f_str_col
$f_str_command_sed
SQLPLUS

#echo "$f_str_temp_output_1"

}

function select_instance_basic_info(){

  #str_temp_output=`do_oracle_sql "select instance_name,status from v\$instance;" "set linesize 500;" "set pagesize 400" "col instance_name for a10"`
  #echo "$str_temp_output"

  #str_temp_output=`do_oracle_sql "select name,database_role,open_mode,current_scn from v\$database;" "set linesize 400" "set pagesize 98"`
  #echo "$str_temp_output"

  do_oracle_sql "select instance_name,status from v\$instance;" "set linesize 500;" "set pagesize 400" "col instance_name for a10"
  do_oracle_sql "select name,database_role,open_mode,current_scn from v\$database;" "set linesize 400" "set pagesize 98"

  echo ""
}

function select_dataguard_process_status(){

  do_oracle_sql "select process,pid,client_pid,status,delay_mins,known_agents,active_agents from v\$managed_standby;" "set linesize 500;" "set pagesize 400" "col client_pid for a20"

  echo ""
}

function select_dataguard_archivelog_apply_status_recently(){

  #do_oracle_sql "select name,thread#,sequence#,to_char(first_time,'yyyy-mm-dd hh24:mi:ss') First,to_char(next_time,'yyyy-mm-dd hh24:mi:ss') Next,applied from v\$archived_log,(select max(sequence#) SEQ# from v\$archived_log where applied='YES') b where sequence# between b.seq#-5 and b.seq#+9 order by sequence#;" "set linesize 400;" "set pagesize 400" "col name for a68" | awk '{print $1}'

#sqlplus / as sysdba<<EOF
#  set linesize 400
#  col name for a65
#  select name,thread#,sequence#,to_char(first_time,'yyyy-mm-dd hh24:mi:ss') "First",to_char(next_time,'yyyy-mm-dd hh24:mi:ss') "Next",applied from v\$archived_log,(select max(sequence#) "SEQ#" from v\$archived_log where applied='YES') b where sequence# between b.seq#-5 and b.seq#+9 order by sequence#;
#EOF

  do_oracle_sql "select name,thread#,sequence#,to_char(first_time,'yyyy-mm-dd hh24:mi:ss') First,to_char(next_time,'yyyy-mm-dd hh24:mi:ss') Next,applied from v\$archived_log,(select max(sequence#) SEQ# from v\$archived_log where applied='YES') b where sequence# between b.seq#-5 and b.seq#+9 order by sequence#;"

  echo ""
}

function select_dataguard_max_archivelog_applied(){

  do_oracle_sql "select thread#,max(sequence#) from v\$managed_standby group by thread# order by thread#;" "set linesize 500;" "set pagesize 400" "col thread# for 9999999999"

  echo ""
}

function select_dg_log_pinglv_day_min() {
  do_oracle_sql "select to_char(first_time,'yyyy-mm-dd hh24:mi'),count(*) Count from v\$archived_log group by to_char(first_time,'yyyy-mm-dd hh24:mi');"
}
function select_dg_log_pinglv_day_hour() {
  do_oracle_sql "select to_char(first_time,'yyyy-mm-dd hh24'),count(*) Count from v\$archived_log group by to_char(first_time,'yyyy-mm-dd hh24');"
}
function select_dg_log_pinglv_day() {
  do_oracle_sql "select to_char(first_time,'yyyy-mm-dd'),count(*) Count from v\$archived_log group by to_char(first_time,'yyyy-mm-dd');"
}
function select_dg_log_pinglv_month() {
  do_oracle_sql "select to_char(first_time,'yyyy-mm'),count(*) Count from v\$archived_log group by to_char(first_time,'yyyy-mm');"
}
function select_dg_log_pinglv_year() {
  do_oracle_sql "select to_char(first_time,'yyyy'),count(*) Count from v\$archived_log group by to_char(first_time,'yyyy');"
}

# running

# --> start
say_hi_and_bye "Start"

# --> 当前实例的信息
display_banner "Instance Info"

#echo <<COMMAND > str_command_sql
#set linesize 600;
#set pagesize 30;
#col instance_name for a10;
#select instance_name,status from v\$instance;
#COMMAND

select_instance_basic_info

# --> DG相关进程的状态
display_banner "Data Guard Process Status"

select_dataguard_process_status

# --> DG最近的应用成功的日志的前后状态
display_banner "Data Guard Archive Log recently"
select_dataguard_archivelog_apply_status_recently

# --> DG最大的THREAD#的sequence#编号
display_banner "Data Guard Archive Log max sequence by thread"
select_dataguard_max_archivelog_applied

# --> DG LOG生成频率
display_banner "Data Guard Log How busy?"

echo "By: day in minus"
select_dg_log_pinglv_day_min
echo "------"
echo "By: day in hour"
select_dg_log_pinglv_day_hour
echo "------"
echo "By: day"
select_dg_log_pinglv_day
echo "------"
echo "By: month"
select_dg_log_pinglv_month
echo "------"
echo "By: year"
select_dg_log_pinglv_year
echo "------"


# -->

# --> end
say_hi_and_bye "End"

# finished
