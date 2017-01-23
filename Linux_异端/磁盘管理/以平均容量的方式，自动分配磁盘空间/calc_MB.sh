# $1, number_str
# $2, part_count
# $3, device_name, option conflict with $1

num_str="$1"
part_count="$2"

var_num=`echo $num_str | cut -d' ' -f1`
var_unit=`echo $num_str | cut -d' ' -f2`

var_number_mb=""
var_number_step=""

case "$var_unit" in
"GB" )
  var_number_mb=`echo "scale=3; $var_num*1024" | bc`
;;

"MB" )
  var_number_mb="$var_number"
;;

"TB" )
  var_number_mb=`echo "scale=3; $var_number*1024*1024" | bc`
;;

esac

var_number_step=`echo "scale=3; $var_number_mb/$part_count" | bc`

# Display
echo "String is: $num_str"
echo "number part: $var_num"
echo "unit part: $var_unit"
echo "-----------------------"
echo "Total size (unit:MB): $var_number_mb"
echo "store step (unit:MB): $var_number_step"

var_part_cylinder_begin=""
var_part_cylinder_end=""

echo "============================"

for part_item in `seq $part_count`
do
  echo "Loop id: $part_item"
  echo "************"

  var_part_cylinder_end=`echo "scale=3; $var_number_step*$part_item" | bc`

  case "$part_item" in
  "1" )
    var_part_cylinder_begin=0
  ;;
  "$part_count" )
    var_part_cylinder_end="100%"
  ;;
  esac

  # Display
  echo "@@@ begin: $var_part_cylinder_begin"
  echo "@@@ end: $var_part_cylinder_end"

  echo ""

  # refresh begin cylinder
  var_part_cylinder_begin=$var_part_cylinder_end

done
