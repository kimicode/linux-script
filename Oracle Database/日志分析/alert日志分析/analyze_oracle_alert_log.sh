# file: analyze_alert_log.sh

# variable

#str_file_alert_log="$1"
str_file_alert_log="/u01/app/oracle/diag/rdbms/enmy/enmy/trace/alert_enmy.log"

#check_string
#str_check_string="$2"
str_check_string="^ORA-"

str_data_check_string=

#compute

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

function analyze_block_str_to_line() {
  f_block_str_total=$*

  #IFS='/'
  for item_line in $f_block_str_total
  do
    echo "$item_line"
  done

}

function fill_data_in_variable() {
  if [ "$str_data_check_string" == "" ]
  then
    echo "@ put data into variable [str_data_check_string]."
    str_data_check_string=`cat $str_file_alert_log | grep --color $str_check_string`
  fi

  echo ""

}

# 分析"ORA-"这类错误
function analyze_error_ORA() {
  # variable
  f_target_data="$1"

  #IFS=' '
  f_target_data_list=`analyze_block_str_to_line "$f_target_data"`

  f_ora_diff_list=""

  f_cursor="1"
  f_ora_loop_before=""

  # logical 1
  total_count=$(echo "$f_target_data" | wc -l)

  echo ""

  # display 1
  echo "Total Line count is: [$total_count]"

  echo ""

  # logical 2
  IFS='/n'
  for error_item in $f_target_data_list
  do
    # loop begin
    # logical
    f_ora_loop_current=`echo "$error_item" | cut -d' ' -f1`

    echo "############################"
    echo "variable is [f_ora_loop_current]"
    echo "$f_ora_loop_current"
    echo "############################"

    #if [[ "$f_ora_diff_list" =~ "$f_ora_loop_current" ]]
    #then
    #  echo "# distinct data already exist."
    #else
    #  f_ora_diff_list="$f_ora_diff_list "
    #fi

    # display
    echo "============================="
    echo "Count is: $f_cursor"
    echo "Current error list is:"
    echo "--> $f_ora_diff_list"

    echo "Current error is:"
    echo "$error_item"

    # loop end
    let f_cursor=f_cursor+1
    #f_ora_loop_before=$f_ora_loop_current
    echo ""

  done

  # display 2

}

# running

# begin
say_hi_and_bye "begin"

# put data into variable
display_banner "Put data into variable."
fill_data_in_variable

# display the data
display_banner "Display Variable data"
echo "$str_data_check_string"

# analyze data: error like ora-
display_banner "Analyze: like ORA-"
analyze_error_ORA "$str_data_check_string"

# end
say_hi_and_bye "end"


#finished
