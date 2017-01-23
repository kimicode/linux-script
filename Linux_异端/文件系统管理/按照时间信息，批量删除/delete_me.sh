date=$1
echo "Delete String: $date"
file_list=`ls -ltr --time-style="+%Y-%m-%d %H:%M |" | grep ".trc" | grep "2013" | cut -d'|' -f 2`
for i in $file_list
do
   echo "Delete file: $i"
   rm -rf $i;
   echo "Done!!"
   echo "********************"
done
