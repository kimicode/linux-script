# Script: sub-main.sh

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@
# Function

f_reverse_enable(){
  #variable
  #$1, main.conf
  #$2, sub-main.conf

  file_main=$1
  file_sub_main=$2

  main_enable=`cat $file_main | grep -v ^# | grep "enable=" | cut -d'=' -f2`
  sub_main_enable=`cat $file_sub_main | grep -v ^# | grep "enable=" | cut -d'=' -f2`

  case "$main_enable" in
  "0" )
     sed -i "s/enable=$sub_main_enable/enable=1/" $file_sub_main
     echo "@@ update: $file_sub_main, enable=1"
  ;;
  "1" )
     sed -i "s/enable=$sub_main_enable/enable=0/" $file_sub_main
     echo "@@ update: $file_sub_main, enable=0"
  ;;

  esac

}

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@

#file path
execute_path=`dirname $0`
log_file="$execute_path/sub-main.log"

(

echo -e "@@ sub-main.sh, begin: \t"`date`
echo ""

#===============================

# 1. reverse enable
# need var
# conf_file_sub_main
# sub_main_reverse

conf_file_sub_main=$execute_path/sub-main.conf
sub_main_reverse=`cat $conf_file_sub_main | grep -v ^# | grep "reverse=" | cut -d'=' -f2`

conf_file_main=$execute_path/../main.conf

if [ $sub_main_reverse = 0 ]
then
  echo "$conf_file_sub_main, reverse is OFF."
else
  echo "$conf_file_sub_main, reverse is ON."

  f_reverse_enable $conf_file_main $conf_file_sub_main

fi

echo ""

#===============================

# 2. script enable
# need var
# sub_main_enable
sub_main_enable=`cat $conf_file_sub_main | grep -v ^# | grep "enable=" | cut -d'=' -f2`

if [ $sub_main_enable = 0 ]
then
  echo "$conf_file_sub_main, enable is OFF."

  # do exit
  exit;

else
  echo "$conf_file_sub_main, enable is ON."

fi

echo ""

#===============================

# 3. run script list
# support variable
list_script="1_post_execute_root_script 2_post_oracle_listener 3_post_oracle_instance"

script_begin_id=`cat $conf_file_sub_main | grep -v ^# | grep "script_id=" | cut -d'=' -f2`
script_length=`echo $list_script | sed 's/[[:space:]]/\n/g' | wc -l`

#Test
echo "------------"
echo "TEST"
echo "------------"
echo "list_script: $list_script"
echo "script_begin_id: $script_begin_id"
echo "script_length: $script_length"
echo ""


# cursor list
for((current_id=$script_begin_id; current_id<=$script_length; current_id++))
do

  #Test
  echo "---------"
  echo "Test: loop"
  echo "---------"
  echo "current id: $current_id"
  echo ""

  #variable for each loop
  current_script=`echo $list_script | sed 's/[[:space:]]/\n/g' | grep $current_id"_"`
  current_script_path=$execute_path/$current_script
  current_script_log=$execute_path/"log_"$current_script

  echo "@@@ current_script: $current_script"
  echo "@@@ current_script_path: $current_script_path"
  echo "@@@ current_script_log: $current_script_log"
  echo ""

  #show out
  echo "%%%%%%%%%%%%%"
  echo "script:$current_script"
  echo "log file:$current_script_log"
  echo "%%%%%%%%%%%%%"
  echo ""

  #run current script and log the process
  (
    echo -e "$current_script_path, begin: \t"`date`
    echo ""

    sh $current_script_path

    echo ""
    echo -e "$current_script_path, begin: \t"`date`

  ) 2>&1 > $current_script_log

  #output logfile
  cat $current_script_log

  #refresh script_id in sub-main.conf
  
  #refresh variable: script_begin_id
  script_begin_id=`cat $conf_file_sub_main | grep -v ^# | grep "script_id=" | cut -d'=' -f2`

  #do re-write
  sed -i "s/script_id=$script_begin_id/script_id=$current_id/" $conf_file_sub_main
  echo "$conf_file_sub_main,UPDATE: script_id=$current_id"

done

#===============================
# disable reverse,enable in sub-main.conf
sed -i "s/enable=1/enable=0/" $conf_file_sub_main
sed -i "s/reverse=1/reverse=0/" $conf_file_sub_main
echo "$conf_file_sub_main, all DISABLE."

#===============================
echo ""
echo -e "@@ sub-main.sh, end: \t"`date`

) 2>&1 > $log_file
