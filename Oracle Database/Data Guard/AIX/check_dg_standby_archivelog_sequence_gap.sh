#!/usr/bin/env sh
# Check Oracle DG archive sequence
#start_num=$1
#end_num=$2
 
start_num=`ls -l /oracle/NXP/oraarch/NXParch/ | cut -d '_' -f3 | head -n 3 | tail -n 1`
end_num=`ls -l /oracle/NXP/oraarch/NXParch/ | cut -d '_' -f3 | tail -n 1`
 
echo "------------------------"
echo "DG archive: sequence check"
echo "Begin: "`date`
echo "------------------------"
 
echo "Begin SEQUENCE# $start_num"
echo "End SEQUENCE# $end_num"
echo "==========="
 
loop_item=$start_num
 
while(($loop_item<$end_num))
do
 
exsist_str=`ls -l /oracle/NXP/oraarch/NXParch/ | cut -d '_' -f3 | grep $loop_item`
 
if [ "$exsist_str" -ne "$loop_item" ]
then
  echo "Need be Add ## $loop_item"
fi
 
let loop_item=loop_item+1
done

# Finished
echo "==========="
echo "End: "`date`
echo "Done"