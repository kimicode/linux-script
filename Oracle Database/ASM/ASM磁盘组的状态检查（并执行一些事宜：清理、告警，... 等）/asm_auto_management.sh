# file: asm_auto_management.sh

# purpose:
# 1. automatic check Oracle ASM status
# 2. do some jobs

# variable

#--> block string storage
str_block_asm_lsdg=""

list_asm_name=""

#--> command_str
str_command_lsdg="lsdg"

# function

function say_begin_end() {
  # variable
  f_str_begin_or_end="$1"

  echo "-----------------------------"
  echo "## META Info: $f_str_begin_or_end @ "`date "+|%Y-%m-%d|%H:%M:%S|"`
  echo "-----------------------------"
  echo ""

}

function do_command_asmcmd() {
  # variable
  f_str_command="$1"
  #statements
  asmcmd "$f_str_command"
}

function get_block_str_asm_lsdg() {
  #statements
  if [ "$str_block_asm_lsdg" == "" ]
  then
    #echo "fun # variable: str_block_asm_lsdg is null."
    str_block_asm_lsdg=`do_command_asmcmd "$str_command_lsdg"`
  fi
}

function analyze_block_str_to_line() {
  f_block_str_total=$*

  #IFS='/'
  for item_line in $f_block_str_total
  do
    echo "$item_line"
  done

}

function get_asm_diskgroup_name() {
  if [ "$list_asm_name" == "" ]
  then
    IFS='/'
    list_asm_name=`analyze_block_str_to_line "$str_block_asm_lsdg" | grep -v "State" | awk '{printf $13" "}'`
  fi
}

function do_asm_diskgroup() {
  # variable
  f_str_total_mb=""
  f_str_free_mb=""
  f_str_usable_mb=""

  compute_percent_free=""
  compute_percent_used=""

  # do logic
  get_asm_diskgroup_name
  IFS=' '
  for item_asm in $list_asm_name
  do
    echo "##########"
    echo "Current is: [$item_asm]"
    echo "---"

    IFS='/'
    f_str_total_mb=`analyze_block_str_to_line "$str_block_asm_lsdg" | grep -v "State" | grep $item_asm | awk '{printf $7" "}'`

    IFS='/'
    f_str_free_mb=`analyze_block_str_to_line "$str_block_asm_lsdg" | grep -v "State" | grep $item_asm | awk '{printf $8" "}'`

    IFS='/'
    f_str_usable_mb=`analyze_block_str_to_line "$str_block_asm_lsdg" | grep -v "State" | grep $item_asm | awk '{printf $10" "}'`

    compute_percent_free=`echo "scale=4;($f_str_free_mb/$f_str_total_mb)*100" | bc`
    compute_percent_used=`echo "scale=4;(1-$f_str_free_mb/$f_str_total_mb)*100" | bc`

    # display
    #echo "fun ## variable f_str_total_mb:: $f_str_total_mb"
    #echo "fun ## variable f_str_free_mb:: $f_str_free_mb"
    #echo "fun ## variable f_str_usable_mb:: $f_str_usable_mb"

    echo "Available Space: $f_str_usable_mb [MB]， "`echo "scale=4;$f_str_usable_mb/1024" | bc`" [GB]"
    echo "***"

    echo "Percent - Free: $compute_percent_free %, Used: $compute_percent_used %"

    echo ""
  done
}

# running

# start
say_begin_end "begin"

# do: 1
echo "list ASM Disk Groups:"
#version 1
#do_command_asmcmd "$str_command_lsdg"
#version 2
get_block_str_asm_lsdg
echo "$str_block_asm_lsdg"

echo ""

# do: 2
# version 1
#echo "Split into line:"
#IFS='/'
#analyze_block_str_to_line "$str_block_asm_lsdg"

# version 2
#get_asm_diskgroup_name
#IFS=' '
#for item_block_str in $list_asm_name
#do
#  echo "##########"
#  echo $item_block_str
#  echo ""
#done

# version 3
echo "Analyze ASM Disk Groups:"
do_asm_diskgroup

echo ""

# end
say_begin_end "end"

# finished
