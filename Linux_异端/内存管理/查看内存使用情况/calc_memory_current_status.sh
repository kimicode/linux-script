# calc_memory_current_stat.sh

#for_RHEL7="Available"
#for_RHEL6="Free"

str_release=`cat /etc/redhat-release`

#Available_sign="Available"

Available_sign=""

if [[ $str_release =~ 7 ]]
then
  echo "## SYSTEM is Linux 7"
  Available_sign="Available"
elif [[ $str_release =~ 6 ]]
then
  echo "## SYSTEM is Linux 6"
  Available_sign="Free"
else
  echo "## can not identified"
fi
echo "OS Release is:"

echo $str_release

echo ""

echo "Sign is: [$Available_sign]"



mem_total=`cat /proc/meminfo  | grep --color MemTotal | awk '{print $2}'`
mem_available=`cat /proc/meminfo  | grep --color Mem$Available_sign | awk '{print $2}'`

compute_percent_mem_available=`awk 'BEGIN {printf "%.4f\n",(('$mem_available'/'$mem_total')*100)}'`
compute_percent_mem_used=`awk 'BEGIN {printf "%.4f\n",((1-'$mem_available'/'$mem_total')*100)}'`

compute_mem_totlal_mb=`awk 'BEGIN {printf "%.4f\n",('$mem_total'/1024)}'`
compute_mem_totlal_gb=`awk 'BEGIN {printf "%.4f\n",('$mem_total'/1024/1024)}'`

compute_mem_available_mb=`awk 'BEGIN {printf "%.4f\n",('$mem_available'/1024)}'`
compute_mem_available_gb=`awk 'BEGIN {printf "%.4f\n",('$mem_available'/1024/1024)}'`

echo "Memory Status:"
echo "[ Date is: "`date '+|%Y-%m-%d|%H:%M:%S|'`"]"
echo "----------------------------"
echo "MEM TOTAL is: $mem_total [KB], $compute_mem_totlal_mb [MB], $compute_mem_totlal_gb [GB]"
echo "MEM AVAILABLE is: $mem_available [KB], $compute_mem_available_mb [MB], $compute_mem_available_gb [GB]"

echo ""

echo "Percent - Available = $compute_percent_mem_available %"
echo "Percent - Used = $compute_percent_mem_used %"

# finished