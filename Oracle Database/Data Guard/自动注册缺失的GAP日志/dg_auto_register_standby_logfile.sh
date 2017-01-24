# Script
# file_name is: dg_auto_register_standby_logfile.sh

# keep going call
#while ( true )
#do
#  sh do_alter_system_register.sh
#done

# work on background
#nohup sh call_do_alter_system_register.sh &
#ps -ef | grep do

# variable
file_alert="/oracle/ERN/saptrace/diag/rdbms/standby1/ERN/trace/alert_ERN.log"
current_gap_sequence=`cat $file_alert | grep "Fetching gap sequence in " | tail -n 1`

# 日志文件
log_file="/oracle/ERN/dg_auto_register_standby_logfile.log"
not_exsist_file="/oracle/ERN/dg_auto_register_standby_logfile_not_exsist.log"
sequence_status_file="/oracle/ERN/dg_auto_register_standby_logfile_gap_status.log"

sequence_area=`cat $file_alert | grep "Fetching gap sequence in " | tail -n 1 | rev | cut -d'e' -f1 | rev`
sequence_area_begin=`cat $file_alert | grep "Fetching gap sequence in " | tail -n 1 | rev | cut -d'e' -f1 | rev | cut -d'-' -f1 | cut -d' ' -f2`
sequence_area_end=`cat $file_alert | grep "Fetching gap sequence in " | tail -n 1 | rev | cut -d'e' -f1 | rev | cut -d'-' -f2 | cut -d' ' -f2`

thread_number=`cat $file_alert | grep "Fetching gap sequence in " | tail -n 1 | rev | cut -d'e' -f4 | cut -d',' -f2 | cut -d'd' -f1 | cut -d' ' -f1`

standby_logfile_dir="/oracle/ERN/oraarch/ERNarch"

# About loop
# where is start
loop_cursor_1=$sequence_area_begin

# where is end
#str_loop_stop="34"
str_loop_stop="1076415"

# for loop
#standby_log_file_like_str="$standby_logfile_dir/ERNarch1_"$sequence_area_begin"_838089898.dbf"

# function

# 清理 日志
echo "## clean log: $not_exsist_file"
echo "" > $not_exsist_file

echo "## clean log: $sequence_status_file"
echo "" > $sequence_status_file

# display
  #echo "Current scn is: $current_gap_sequence"
  echo "==========================================="
  echo "Log:"
  echo "Not exsist: $not_exsist_file"
  echo "Gap status: $sequence_status_file"
  echo "**********************"
  echo "Thread num:: $thread_number"
  echo "-------------------"
  echo "SEQUENCE Current: $sequence_area"
  echo "SEQUENCE BEGIN:: $sequence_area_begin"
  echo "SEQUENCE END:: $sequence_area_end"
  echo ""

  echo "==========================================="
  echo "Loop:"
  echo "Loop Cursor:: $loop_cursor_1"

  echo ""

# 写到日志中
  echo "===========================================" >> $sequence_status_file
  echo "Log:" >> $sequence_status_file
  echo "Not exsist: $not_exsist_file" >> $sequence_status_file
  echo "Gap status: $sequence_status_file" >> $sequence_status_file
  echo "**********************" >> $sequence_status_file
  echo "Thread num:: $thread_number" >> $sequence_status_file
  echo "-------------------" >> $sequence_status_file
  echo "SEQUENCE Current: $sequence_area" >> $sequence_status_file
  echo "SEQUENCE BEGIN:: $sequence_area_begin" >> $sequence_status_file
  echo "SEQUENCE END:: $sequence_area_end" >> $sequence_status_file
  echo "" >> $sequence_status_file
  echo "===========================================" >> $sequence_status_file
  echo "Loop:" >> $sequence_status_file
  echo "Loop Cursor:: $loop_cursor_1" >> $sequence_status_file

  echo ""

# 循环执行日志注册，开始了
while (($loop_cursor_1 <= $sequence_area_end))
do
  echo "====================="

  # variable
  # tail -f /oracle/ERN/saptrace/diag/rdbms/standby1/ERN/trace/alert_ERN.log | grep "gap sequence"

  standby_log_file_like_str_ahead_Instance="$standby_logfile_dir/ERNarch"$thread_number"_"$loop_cursor_1"_838089898.dbf"
  standby_log_file_like_str_ahead_standby="$standby_logfile_dir/standby1_"$thread_number"_"$loop_cursor_1"_705619077.arch"

  # 文件是否存在
  # 0存在
  # 1不存在
  isExsist_log_instance="0"
  isExsist_log_standby="0"

  # acture do sth
  echo "#######"
  echo "current:: $loop_cursor_1"
  echo "Standby Log:: "
  echo "DBF: "$standby_log_file_like_str
  echo "ARCH: "$standby_log_file_like_str
  echo ""

  # whether do or not, this is a question.
  echo "!!! loop end signal: $str_loop_stop"
  if [ $loop_cursor_1 -lt $str_loop_stop ]
  then
    echo "** OK, not touch end singal **"
  else
    echo "!!! NOT OK !!!"
    echo "%%% End singal has been TOUCHED."
    exit 0

  fi

  echo ""

  # do Oracle DG standby db, staff
  echo "do_Oracle staff: "
  echo "DBF: alter database register logfile '$standby_log_file_like_str_ahead_Instance'"
  echo "ARCH: alter database register logfile '$standby_log_file_like_str_ahead_standby'"
  echo "Start:: "`date "+|%Y-%m-%d|%H:%M:%S|"`
  echo "++++++++++++++++++++++++++++++++++++++++++++"

  # Version 1
  # ---------------------------------
#sqlplus / as sysdba<<SQLPLUS
#Prompt 'Do Register';
#alter database register logfile '$standby_log_file_like_str_ahead_Instance';
#Prompt 'Command is:';
#list

#Prompt 'Do Register';
#alter database register logfile '$standby_log_file_like_str_ahead_standby';
#Prompt 'Command is:';
#list
#SQLPLUS
  # ---------------------------------

  # Version 2
  # Part one
  if [ ! -f "$standby_log_file_like_str_ahead_Instance" ]
  then
    #echo "" >> $not_exsist_file
    #echo "!!! File: $standby_log_file_like_str_ahead_Instance, is not exsist." >> $not_exsist_file
    isExsist_log_instance=1
  else
    echo ""
    echo "!!! File: $standby_log_file_like_str_ahead_Instance, is exsist."
    echo "Do SQL*Plus Staff:"
sqlplus / as sysdba<<SQLPLUS
Prompt 'Do Register';
alter database register logfile '$standby_log_file_like_str_ahead_Instance';

Prompt 'Command is:';
list
SQLPLUS
  fi

  # Part Two
  if [ ! -f "$standby_log_file_like_str_ahead_standby" ]
  then
    #echo ""
    #echo "!!! File: $standby_log_file_like_str_ahead_standby, is not exsist." >> $not_exsist_file
    isExsist_log_standby=1
  else
    echo ""
    echo "!!! File: $standby_log_file_like_str_ahead_standby, is exsist."
    echo "Do SQL*Plus Staff:"
sqlplus / as sysdba<<SQLPLUS
Prompt 'Do Register';
alter database register logfile '$standby_log_file_like_str_ahead_standby';

Prompt 'Command is:';
list
SQLPLUS
  fi

  echo "++++++++++++++++++++++++++++++++++++++++++++"
  echo "do_Oracle staff: done:: "`date "+|%Y-%m-%d|%H:%M:%S|"`

  # 将两个都不存在的文件，输出到日志中
  if [[ $isExsist_log_instance -eq 1 && $isExsist_log_standby -eq 1 ]]
  then
    echo "Standby LOG #SEQUENCE - $loop_cursor_1, is NOT exsist."
    echo "Standby LOG #SEQUENCE - $loop_cursor_1, is NOT exsist." >> $not_exsist_file
  fi

  echo "" >> $not_exsist_file
  echo ""

  # increase cursor
   loop_cursor_1=$(($loop_cursor_1+1))

done

# run

# finished
