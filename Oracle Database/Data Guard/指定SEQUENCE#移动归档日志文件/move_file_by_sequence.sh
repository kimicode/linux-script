# file: move_file_by_sequence.sh

str_search="$1"
source_dir="/u01/app/oracle/dg_stdbylog"
target_dir="/home/oracle/arch_log_dup"

echo "search string is: [$str_search]"

for item in $(ls $source_dir | grep "_"$str_search"_")
do
  echo "----> item: $item"
  func_full_path="$source_dir/$item"
  echo "Full path is: [$func_full_path]"
  echo "Target dir is: [$target_dir]"
  echo "@ do move"
  mv $func_full_path $target_dir
  echo ""
done

# finished
