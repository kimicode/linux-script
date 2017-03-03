# calc_memory_current_stat.sh

#for_RHEL7="Available"
#for_RHEL6="Free"

Available_sign="Free"

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
