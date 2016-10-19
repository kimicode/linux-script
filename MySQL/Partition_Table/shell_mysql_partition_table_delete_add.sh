# file: shell_mysql_partition_table_delete_add.sh
#
# author: adamhuan
# web site: d-prototype.com
#
# type: shell
# db: mysql
# object: partition table
# active: 
# 1. drop old partition
# 2. add new partition by tomorrow date
# os: linux

# Balance

echo "=================="
echo "Script: MySQL_PartitionTable_auto_delete_add"
echo "Begin: "`date`
echo "=================="

# Variables

## Conn
ip="localhost"
port="3306"
user="adamhuan"
password=******
db="adamhuan"
table=event_by_day

## Display
echo "IP: $ip"
echo "Port: $port"
echo "User: $user"
echo "Password: $password"
echo "DB: $db"
echo "Table: $table"

# Logical

## Func: do_sql

function do_sql(){
	# variable
	f_sql_str="$1"

	# display
	#echo "------"
	#echo "Func SQL: $f_sql_str"
	#echo "------"

	# do
	mysql -u $user -p"$password" $db -N -e "$f_sql_str"
}

## Func: get_result

## Func: do_delete_min_partition

function do_delete_min_partition(){
	# variable
	f_str_min_partition="$1"
	f_sql_str="alter table $table drop partition $f_str_min_partition"
	
	echo "@@@@@@@@@@@@@@@@@@@@@@"
	echo "SQL: $f_sql_str"
	echo "@@@@@@@@@@@@@@@@@@@@@@"

	# do
	do_sql "$f_sql_str"
}

## Func: scan_partition

function scan_partition(){
	# variable
	sql_str="SELECT table_schema,table_name,partition_name,partition_ordinal_position,create_time FROM information_schema.partitions WHERE table_name='$table';"

	# do
	do_sql "$sql_str"
}

## Func: calc_next_partition_str

function calc_next_partition_str(){
	# variable
	str_current_max_partition="$1"

	# do
	non_number=`echo $str_current_max_partition | tr -d "[0-9]"`
	split_str=`echo ${non_number: -1}`

	#echo "Func: Full: $str_current_max_partition"
	#echo "Func: Non_number: $non_number"
	#echo "Func: Split Str: $split_str"

	number=`echo $str_current_max_partition | cut -d"$split_str" -f2`
	next_number=$((number+1))

	#echo "Func: Number: $number"
	#echo "Func: Next Number: $next_number"

	next_partition_str=$non_number$next_number
	
	#echo "Func: Next Partition Str: $next_partition_str"

	# return
	#return $next_partition_str
	echo "$next_partition_str"
}

## Func: add nxet partition

function do_add_next_partition(){
	# variable
	f_next_partition_str="$1"
	str_tomorrow=`date -d"tomorrow" +"%F"`
	
	# SQL
	f_sql_str="alter table $table add partition (partition $f_next_partition_str values less than (unix_timestamp('$str_tomorrow')));"

	echo "@@@@@@@@@@@@@@@@@@@@@@"
	echo "SQL: $f_sql_str"
	echo "@@@@@@@@@@@@@@@@@@@@@@"

	# do
	do_sql "$f_sql_str"

}

# Do
echo "=================="
echo "Do Action"
echo "=================="

#sql_str="SELECT table_schema,table_name,partition_name,partition_ordinal_position,create_time FROM information_schema.partitions WHERE table_name='$table';"
#echo "-----------------"
#echo "Do SQL: $sql_str"
#echo "-----------------"

# +++++++++++++++++++++++++++++++++
echo ""
echo "@@@@@@@@@@@"
echo "###Scan Partiton Table: Partition"
# +++++++++++++++++++++++++++++++++
scan_partition

# +++++++++++++++++++++++++++++++++
echo ""
echo "@@@@@@@@@@@"
echo "###Scan Partiton Table: Min Partition"
# +++++++++++++++++++++++++++++++++
sql_str="SELECT min(partition_name) FROM information_schema.partitions WHERE table_name='$table' order by partition_name;"
str_min_partition=`do_sql "$sql_str"`

echo "Min Partition is: $str_min_partition"

# +++++++++++++++++++++++++++++++++
echo ""
echo "@@@@@@@@@@@"
echo "###Scan Partiton Table: Max Partition"
# +++++++++++++++++++++++++++++++++
sql_str="SELECT max(partition_name) FROM information_schema.partitions WHERE table_name='$table' order by partition_name;"
str_max_partition=`do_sql "$sql_str"`

echo "Max Partition is: $str_max_partition"

# +++++++++++++++++++++++++++++++++
echo ""
echo "@@@@@@@@@@@"
echo "###Do delete min partition"
# +++++++++++++++++++++++++++++++++
echo "-- do delete"
do_delete_min_partition "$str_min_partition"
echo "-- after delete"
scan_partition

# +++++++++++++++++++++++++++++++++
echo ""
echo "@@@@@@@@@@@"
echo "###Do add tomorrow partition"
# +++++++++++++++++++++++++++++++++

next_partition_name=`calc_next_partition_str "$str_max_partition"`
echo "-- next partition name is: $next_partition_name"

echo "-- do partition add:"
do_add_next_partition "$next_partition_name"

echo "-- after partition add:"
scan_partition

# Finished
echo "=================="
echo "Finished."
echo "End: "`date`
