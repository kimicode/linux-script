
# check Oracle DG
# file: check_dg_archive_log_gap.sh

str_thread=$2
str_sequence=$3

str_path_dir="$1"

int_first=`ls -ltr $str_path_dir | grep $str_thread"_" | awk '{print $9}' | head -n 1 | cut -d'_' -f2`
int_last=`ls -ltr $str_path_dir | grep $str_thread"_" | awk '{print $9}' | tail -n 1 | cut -d'_' -f2`

int_cursor=$str_sequence

int_before=""

echo "# dir is: $str_path_dir"
echo "--> thread # is: "$int_thread
echo "--> early-est log sequence# is: $int_first"
echo "--> last-est log sequence# is: $int_last"
echo "------------"
echo "--> user identified start sequence# is: $str_sequence"
echo "--> cursor start sequence# is: $int_cursor"
echo ""


while (($int_cursor<$int_last))
do

exist_str=`ls -l $str_path_dir | cut -d'_' -f2 | grep $int_cursor`

if [ "$exist_str" != "$int_cursor" ]
then
echo "Need be SCP ## $int_cursor"
fi

let "int_cursor++"
done
#finished
