#!/sbin/bash
echo "=============================================="
echo "Summary file or directory by date."
echo "=============================================="

#-----------------------------------------------------------
# Get Data: Dependence by Each File Date
#-----------------------------------------------------------

# All of it

# Total file Count
file_count=`ls -l | wc -l`
echo -e "\033[34;1mTotal\033[0m file count is: \033[34;1m $file_count \033[0m"

#-----------------------------------------------------------
# Get Oldest File Date Variable

# Orig
oldest_file=`ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"| grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g'`
echo -e "All of file: Old-est file is: \033[46;34;1m $oldest_file \033[0m"

#Year
old_year=`ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"| grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | awk -F '|' '{print $2}' | cut -d '-' -f1`
#Month
old_month=` ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"| grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | awk -F '|' '{print $2}' | cut -d '-' -f2`
#Day
old_day=` ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"| grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | awk -F '|' '{print $2}' | cut -d '-' -f3`
#Hour
old_hour=` ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"| grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | awk -F '|' '{print $3}' | cut -d ':' -f1`
#Min
old_min=` ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"| grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | awk -F '|' '{print $3}' | cut -d ':' -f2`
#Second
old_sec=` ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"| grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | awk -F '|' '{print $3}' | cut -d ':' -f3`

#-----------------------------------------------------------
# Get Newest File Date Variable

# Orig
newest_file=` ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"| tac| grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g'`
echo -e "All of file: New-est file is: \033[46;34;1m $newest_file \033[0m"

#Year
new_year=`ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"| tac| grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | awk -F '|' '{print $2}' | cut -d '-' -f1`
#Month
new_month=`ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"| tac| grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | awk -F '|' '{print $2}' | cut -d '-' -f2`
#Day
new_day=`ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"| tac| grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | awk -F '|' '{print $2}' | cut -d '-' -f3`
#Hour
new_hour=`ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"| tac| grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | awk -F '|' '{print $3}' | cut -d ':' -f1`
#Min
new_min=` ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"| tac| grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | awk -F '|' '{print $3}' | cut -d ':' -f2`
#Second
new_sec=`ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"| tac| grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | awk -F '|' '{print $3}' | cut -d ':' -f3`

#-----------------------------------------------------------
# Display Data: Display Old and New data
#-----------------------------------------------------------

# List what you got in Oldest File
#echo "========================================="
#echo "All of file: Old-est File Date"
#echo "========================================="
#echo "OLD Year is: $old_year"
#echo "OLD Month is: $old_month"
#echo "OLD Day is: $old_day"
#echo "OLD Hour is: $old_hour"
#echo "OLD Minus is: $old_min"
#echo "OLD Second is: $old_sec"

# List what you got in Newest File
#echo "========================================="
#echo "All of file: New-est File Date"
#echo "========================================="
#echo "New Year is: $new_year"
#echo "New Month is: $new_month"
#echo "New Day is: $new_day"
#echo "New Hour is: $new_hour"
#echo "New Minus is: $new_min"
#echo "New Second is: $new_sec"

echo "=============================================="

# Analyze

# Loop Year

# Year

for((object_year="$old_year"; object_year<="$new_year"; object_year++))
do
#echo "Year is: $object_year"

file_year_count=`ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"| grep -v "total" | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | grep $object_year | wc -l`

#echo "File Count is: $file_year_count"

if [ $file_year_count -ne 0 ]
then
   echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
   echo -e "Year is: \033[40;33;1m $object_year \033[0m"
   echo "--------------------"

   #echo "###### Message: file count is not 0."
   echo -e "###### File Count is: \033[44;32;1m $file_year_count \033[0m"
   echo "--------------------"

   # Year of file

   # Year of file: Old
   year_oldest_file=`ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"| grep "$object_year" | grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g'`

   echo -e "\033[41;33;1m Year \033[0m of oldest file: \033[46;34;1m $year_oldest_file \033[0m"

   # Analyze oldest_year
   #echo "###### Analyze OLDest file among this year: $object_year"

#******************
#Year
year_old_year=`ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"|   grep "$object_year" | grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | awk -F '|' '{print $2}' | cut -d '-' -f1`
#Month
year_old_month=` ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"| grep "$object_year" | grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | awk -F '|' '{print $2}' | cut -d '-' -f2`
#Day
year_old_day=` ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"|   grep "$object_year" | grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | awk -F '|' '{print $2}' | cut -d '-' -f3`
#Hour
year_old_hour=` ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"|  grep "$object_year" | grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | awk -F '|' '{print $3}' | cut -d ':' -f1`
#Min
year_old_min=` ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"|   grep "$object_year" | grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | awk -F '|' '{print $3}' | cut -d ':' -f2`
#Second
year_old_sec=` ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"|   grep "$object_year" | grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | awk -F '|' '{print $3}' | cut -d ':' -f3`

#******************


   # ----------------------------------------------------------------
   # Year of file: new
   year_newest_file=`ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"| grep "$object_year"  | tac| grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g'`

   echo -e "\033[41;33;1m Year \033[0m of newest file: \033[46;34;1m $year_newest_file \033[0m"
   # Analyze newest_year
   #echo "###### Analyze NEWest file among this year: $object_year"

#******************
#Year
year_new_year=`ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"|   grep "$object_year" | tac| grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | awk -F '|' '{print $2}' | cut -d '-' -f1`
#Month
year_new_month=`ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"|  grep "$object_year" | tac| grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | awk -F '|' '{print $2}' | cut -d '-' -f2`
#Day
year_new_day=`ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"|    grep "$object_year" | tac| grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | awk -F '|' '{print $2}' | cut -d '-' -f3`
#Hour
year_new_hour=`ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"|   grep "$object_year" | tac| grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | awk -F '|' '{print $3}' | cut -d ':' -f1`
#Min
year_new_min=` ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"|   grep "$object_year" | tac| grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | awk -F '|' '{print $3}' | cut -d ':' -f2`
#Second
year_new_sec=`ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"|    grep "$object_year" | tac| grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | awk -F '|' '{print $3}' | cut -d ':' -f3`

#******************

# ------------------------------------
#echo "Display OLD and NEW -est file among this year 's metadata."
# ------------------------------------

# List what you got in Oldest File
#echo "========================================="
#echo "Old-est File among this YEAR: $object_year"
#echo "========================================="
#echo "OLD-est amount Year is: $year_old_year"
#echo "OLD-est amount Month is: $year_old_month"
#echo "OLD-est amount Day is: $year_old_day"
#echo "OLD-est amount Hour is: $year_old_hour"
#echo "OLD-est amount Minus is: $year_old_min"
#echo "OLD-est amount Second is: $year_old_sec"

# List what you got in Newest File
#echo "========================================="
#echo "New-est File among this YEAR: $object_year"
#echo "========================================="
#echo "New-est amount Year is: $year_new_year"
#echo "New-est amount Month is: $year_new_month"
#echo "New-est amount Day is: $year_new_day"
#echo "New-est amount Hour is: $year_new_hour"
#echo "New-est amount Minus is: $year_new_min"
#echo "New-est amount Second is: $year_new_sec"

echo "********************************"

   # Month
   for ((object_month="$year_old_month";object_month<="$year_new_month";object_month++))
   do
   search_year_month=$object_year-$object_month

   file_year_month_count=`ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"| grep -v "total" | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g' | grep $search_year_month | wc -l`

   if [ $file_year_month_count -ne 0 ]
   then
   #echo "###### Message: file count is not 0."

   echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

   echo -e "Month is: \033[42;34;1m $search_year_month \033[0m"
   echo -e "###### File Count is: \033[44;32;1m $file_year_month_count \033[0m"
   echo "--------------------"

   if [ $object_month -le 9 ]
   then
   month_num=0$object_month

   search_year_month_file=$object_year-$month_num

   # Month of file: old
   month_old_file=`ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"| grep "$search_year_month_file" | grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g'`

   echo -e "\033[45;36;1m Month \033[0m of OLD-est file: \033[46;34;1m $month_old_file \033[0m"

   # Month of file: new
   month_new_file=`ls -ltr --time-style="+|%Y-%m-%d|%H:%M:%S|"| grep "$search_year_month_file"  | tac| grep -v "total" | head -n 1 | sed 's/|0/|/g' | sed 's/-0/-/g' | sed 's/:0/:/g'`

   echo -e "\033[45;36;1m Month \033[0m of NEW-est file: \033[46;34;1m $month_new_file \033[0m"

   fi


   # elif: In other possible
   #elif [ $file_year_month_count -eq 0]
   #then
   #echo "Month is: $search_year_month"
   #echo "###### Message: file count is not 0."

   fi

   done

# elif: In other possible
#elif [ $file_year_count -eq 0 ]
#then
#   echo "Year is: $object_year"
#   echo "###### Message: file count is 0."
#   echo "###### File Count is: $file_year_counti"
#   echo "###### No need to Display"
#   echo "--------------------"

fi

#echo "********************************"

done
