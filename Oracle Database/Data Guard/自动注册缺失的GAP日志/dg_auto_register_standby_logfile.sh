
# Script
# file_name is: dg_auto_register_standby_logfile.sh

# keep going call
#while ( true )
#do
#  sh do_alter_system_register.sh
#done

# work on background
#nohup sh call_do_alter_system_register.sh &

# variable
file_alert="/oracle/NXP/saptrace/diag/rdbms/standby1/NXP/trace/alert_NXP.log"
current_gap_sequence=`cat $file_alert | grep "Fetching gap sequence in " | tail -n 1`
log_file="/oracle/NXP/auto_register_logfile.log"

sequence_area=`cat $file_alert | grep "Fetching gap sequence in " | tail -n 1 | rev | cut -d'e' -f1 | rev`
sequence_area_begin=`cat $file_alert | grep "Fetching gap sequence in " | tail -n 1 | rev | cut -d'e' -f1 | rev | cut -d'-' -f1 | cut -d' ' -f2`
sequence_area_end=`cat $file_alert | grep "Fetching gap sequence in " | tail -n 1 | rev | cut -d'e' -f1 | rev | cut -d'-' -f2 | cut -d' ' -f2`

thread_number=`cat $file_alert | grep "Fetching gap sequence in " | tail -n 1 | rev | cut -d'e' -f4 | cut -d',' -f2 | cut -d'd' -f1 | cut -d' ' -f1`

standby_logfile_dir="/oracle/NXP/oraarch/NXParch"

str_loop_stop="246999"

# for loop
#standby_log_file_like_str="$standby_logfile_dir/NXParch1_"$sequence_area_begin"_838089898.dbf"

# function

# display

#echo "Current scn is: $current_gap_sequence"
echo "==========================================="
echo "Thread num:: $thread_number"
echo "-------------------"
echo "SEQUENCE Current: $sequence_area"
echo "SEQUENCE BEGIN:: $sequence_area_begin"
echo "SEQUENCE END:: $sequence_area_end"
echo ""

echo "==========================================="
echo "Loop:"

loop_cursor_1=$sequence_area_begin
echo "Loop Cursor:: $loop_cursor_1"

while (($loop_cursor_1 <= $sequence_area_end))
do
  # variable
  standby_log_file_like_str="$standby_logfile_dir/NXParch"$thread_number"_"$loop_cursor_1"_838089898.dbf"

  # acture do sth
  echo "#######"
  echo "current:: $loop_cursor_1"
  echo "Standby Log:: $standby_log_file_like_str"
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
  echo "alter database register logfile '$standby_log_file_like_str'"
  echo "Start:: "`date "+|%Y-%m-%d|%H:%M:%S|"`
  echo "++++++++++++++++++++++++++++++++++++++++++++"
sqlplus / as sysdba<<SQLPLUS
alter database register logfile '$standby_log_file_like_str';
list
SQLPLUS
  echo "++++++++++++++++++++++++++++++++++++++++++++"
  echo "do_Oracle staff: done:: "`date "+|%Y-%m-%d|%H:%M:%S|"`

  echo ""

  # increase cursor
   loop_cursor_1=$(($loop_cursor_1+1))

done

# run

# finished
