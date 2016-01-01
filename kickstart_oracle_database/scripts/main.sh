# Script: main.sh

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# before everything

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# variable

list_script="1_os_alias_etc 2_dir 3_yum 4_selinux 5_linux_config_file 6_os_account 7_static_network 8_services 9_oracle_software_only"

# variable: file path
execute_path=`dirname $0`
log_file="$execute_path/main.log"
config_file="$execute_path/main.conf"

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# function


# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# run
(

echo ""
echo -e "main.sh, Begin: \t"`date`
echo ""
#--------------


# analyze

# -- able to run
script_able_run=`cat $config_file | grep "enable=" | cut -d'=' -f2`

# -- script list

# var type:number
list_script_length=`echo $list_script | sed 's/[[:space:]]/\n/g' | wc -l`
script_begin_id=`cat $config_file | grep "script_begin_id=" | cut -d'=' -f2`

# result and do desired

# -- able to run
case "$script_able_run" in
"0" )
   echo ""
   echo "!!!!!! Runable:: NO  !!!!!!"
   echo ""
   echo "Please check File:: $config_file, and turn runable to enable (VALUE --> 1)."
   echo "----------------------------"
   echo ""
   exit
;;
"1" )
   echo "$config_file, enable=1, means Script: main.sh, ENABLE to run."
;;
esac

# -- script list

for((cur_forloop=$script_begin_id; cur_forloop<=$list_script_length; cur_forloop++))
do

   # analyze
   current_script_file_name=`echo $list_script | sed 's/[[:space:]]/\n/g' | grep $cur_forloop"_"`
   current_script_file_full_path=$execute_path/$current_script_file_name
   current_script_log_full_path=$execute_path/"log_"$current_script_file_name
   
   echo ""
   echo ""
   echo "======================"
   echo "Script: $current_script_file_full_path"
   echo "--- ---"
   echo "Log: $current_script_log_full_path"
   echo "======================"
   echo ""

   # run current script
   # @@@@@@@@@@@@@@@@@@@@@@
   ( 
      echo -e "@@@ $current_script_file_full_path, Begin: \t"`date`
      echo ""

      sh $current_script_file_full_path

      echo ""
      echo -e "@@@ $current_script_file_full_path, End: \t\t"`date`
   ) 2>&1 > $current_script_log_full_path
   # @@@@@@@@@@@@@@@@@@@@@@

   # change current script id to config file
   # refresh variable
   script_begin_id=`cat $config_file | grep "script_begin_id=" | cut -d'=' -f2`

   # do change
   sed -i "s/script_begin_id=$script_begin_id/script_begin_id=$cur_forloop/" $config_file

   # result
   echo ""
   echo "@@@ $config_file, script_begin_id has been CHANGE ---> from $script_begin_id to $cur_forloop, means First run this SCRIPT on next STARTUP"
   echo "-------------------------------------"
   echo ""

done

#--------------


# change able to run status to config file
sed -i "s/enable=1/enable=0/" $config_file
echo "$config_file, enable has been CHANGE ---> 0, means DISABLE"

echo ""
echo -e "main.sh, End: \t\t"`date`

) 2>&1 > $log_file
