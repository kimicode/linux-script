#!/bin/bash
# file: auto_asm_ARCHIVELOG_delete.sh

# variable
str_path_rman_log_dir="$HOME/auto_asm_ARCHIVELOG_delete"
str_path_rman_log_file="$str_path_rman_log_dir/delete_on_`date +_%Y-%m-%d_%H:%M:%S`.log"
int_keep_day="6"

# function

function say_begin_end() {
  # variable
  f_str_begin_or_end="$1"

  echo "-----------------------------"
  echo "## META Info: $f_str_begin_or_end @ "`date "+|%Y-%m-%d|%H:%M:%S|"`
  echo "-----------------------------"
  echo ""

}

say_begin_end "begin"

if [ ! -x "$str_path_rman_log_dir" ]
then
  mkdir -p "$str_path_rman_log_dir"
fi

rman log $str_path_rman_log_file <<EOF
connect target /;
run{
crosscheck archivelog all;
delete noprompt archivelog until time "sysdate-$int_keep_day";
}
EOF

say_begin_end "end"

# finished
