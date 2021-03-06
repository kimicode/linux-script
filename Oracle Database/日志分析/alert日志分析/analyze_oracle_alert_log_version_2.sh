# file: analyze_oracle_alert_log.sh

# variable

# --> for while loop
while_cursor_1="1"
while_content_before=""

# while list
error_list_ora_code=""
duplicate_list=""

# --> about oracle
file_alert="/u01/app/oracle/diag/rdbms/enmy/enmy/trace/alert_enmy.log"
string_find="^ORA-"

# --> temporary used
block_data=""
file_temp_block_data="/home/oracle/block_data"

# -->

# -->

# -->


# function

# --> say begin or end
function say_hi_and_bye() {
  # variable
  str_sign=$1

  # logical
  echo "================================="
  echo "$str_sign @ "`date "+|%Y-%m-%d|%H:%M:%S|"`
  echo "----------------"

  echo ""

}

# --> display split part
function display_banner() {
  # variable
  f_str_banner="$1"
  # logical

  echo ""

  echo "--------------"
  echo "Current:: $f_str_banner"
  echo "--------------"

  echo ""

}

# --> put block string data to lines
function analyze_block_str_to_line() {
  f_block_str_total=$*

  #IFS='/'
  for item_line in "$f_block_str_total"
  do
    echo "$item_line"
  done

}

# --> fill data into variable [block_data]
function fill_data_in_variable() {
  if [ "$block_data" == "" ]
  then
    echo "@ put data into variable [block_data]."
    block_data=`cat $file_alert | grep --color $string_find`
  fi

  echo ""

}

# --> Analyze error code like "ORA-"
function analyze_error_ORA() {

	# variable
	f_target_data="$1"

	# --> computer variable
	f_target_data_list=`analyze_block_str_to_line "$f_target_data"`
	f_target_data_list_count=$(echo "$f_target_data_list" | wc -l)

	echo "Target list:"
	echo "***********************"
	echo "$f_target_data_list"
	echo "***********************"
	echo "Total count is: [$f_target_data_list_count]"
	echo "-----------------------"

	# Put data into temp file
	echo "$f_target_data_list" > $file_temp_block_data

	# ---> do while loop
	#echo "$f_target_data_list" | while read item_target
	while read item_target
	do
		# while begin
		#echo "----------- $while_cursor_1"
		#echo "$item_target"
		#echo ""
		# while variable
		while_current_ora_code=`echo "$item_target" | cut -d' ' -f1 | cut -d':' -f1`

		#echo "#--> while loop before is: $while_content_before"
		#echo "#--> while loop current is: $while_current_ora_code"

		#echo ""

		if [[ "$error_list_ora_code" =~ "$while_current_ora_code" ]]
		then
			#echo "### Error code is already in the List."
			#echo "### error list is:"
			#echo "$error_list_ora_code"
      duplicate_list="$duplicate_list $while_current_ora_code"
		else
			error_list_ora_code="$error_list_ora_code $while_current_ora_code"
			#echo "### Error code is [not] in the List."
			#echo "### error list is:"
			#echo "$error_list_ora_code"
		fi

		# for test
		#error_list_ora_code="1 2 3 4" # 为什么这里传参出去，出不去？

		# while end
		while_content_before=$while_current_ora_code
		let "while_cursor_1++"
		#echo ""
	done < $file_temp_block_data

	# for test
	#error_list_ora_code="1 2 3 4" # 在这里传参就没有问题

	#echo "### [out while] error list is:"
	#echo "$error_list_ora_code"

	echo ""

}

function show_list_error_ora_code() {
	for list_item in $error_list_ora_code
	do
    #variable
    error_total_count=`cat $file_alert | grep --color $list_item | wc -l`
    #logical
		echo "--> $list_item , count is: [$error_total_count]"
	done
  echo ""
}

# -->


# running

# begin
say_hi_and_bye "begin"

# put data into variable
display_banner "Put data into variable."
fill_data_in_variable

# display the data
#display_banner "Display Variable [block_data] data"
#echo "$block_data"

# analyze data: error like ora-
display_banner "Analyze: like ORA-"
analyze_error_ORA "$block_data"

# show list data: error like ora-
display_banner "list Errors: like ORA-"
show_list_error_ora_code

# end
say_hi_and_bye "end"

# display

# finished
