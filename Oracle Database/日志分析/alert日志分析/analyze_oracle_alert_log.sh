# file: analyze_alert_log.sh

# variable

#str_file_alert_log="$1"
str_file_alert_log="/u01/app/oracle/diag/rdbms/enmy/enmy/trace/alert_enmy.log"

#check_string
#str_check_string="$2"
str_check_string="^ORA-"

str_data_check_string=""

list_error_ora=""

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

  # --> for loop
  loop_count="1"
  loop_content_before=""
  list_error_code=""

  #IFS=' '
  f_target_data_list=`analyze_block_str_to_line "$f_target_data"`

  echo "target list is"
  echo "*****************************"
  echo "$f_target_data"
  echo "*****************************"

  echo ""

  echo "$f_target_data" | while read error_item
  do
    echo "------ $loop_count"
    echo "$error_item"

    # variable
    current_error=`echo "$error_item" | cut -d' ' -f1 | cut -d':' -f1`

    echo ""

    echo "## loop content before is: $loop_content_before"
    echo "## current error is: $current_error"

    echo ""

    if [[ "$list_error_ora" =~ "$current_error" ]]
    then
      echo "Error already in list."
    else
      list_error_ora="$list_error_ora $current_error"
    fi

    echo ""

    #list_error_ora="$list_error_code"

    echo "## current list is:"
    for list_item in $list_error_ora
    do
      echo "--> $list_item"
    done

    # end loop
    let loop_count=loop_count+1
    loop_content_before=$current_error

    echo ""
  done

  echo "## loop content before is: $loop_content_before"
  echo "## error list is:"
  echo "$list_error_ora"
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

echo "## out --> error list is:"
echo "$list_error_ora"

# end
say_hi_and_bye "end"


#finished
