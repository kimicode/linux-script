
# make_some_archive_log_gap.sh
#代码还没有写完，目前只写了一个需要自动的刷日志切换的方法

archive_log_dir="/u01/app/oracle/product/11.2.0/dbhome_1/dbs"

str_thread="1"
str_last="_939308144.dbf"

duplicate_dir="/home/oracle/arch_log_dup"

int_s="1"
int_e="$1"

while [ $int_s -lt $int_e ]
do

echo "---------- [$int_s]"
sqlplus / as sysdba<<sqlplus
alter system switch logfile;
exit;
sqlplus

done
