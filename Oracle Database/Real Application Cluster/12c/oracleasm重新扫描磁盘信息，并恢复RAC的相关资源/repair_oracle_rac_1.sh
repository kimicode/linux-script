
# 目标：自动刷出oracleasm的磁盘卷，并启动ORACLE RAC的相关资源
# file: repair_oracle_rac_1.sh
# author: adamhuan

# variable

path_oracle_asm_disks=/dev/oracleasm/disks
file_log=/var/log/oracleasm_adamhuan.log

# begin running

if [ ! -f "$$file_log" ]
then
  touch $file_log
fi

status_oracle_asm_disks=`ls -A $path_oracle_asm_disks`

if [ "$status_oracle_asm_disks" = "" ]
then
  echo "" >> $file_log
  echo "-------------------------------" >> $file_log

  echo "## oracle asm disks is null." >> $file_log

  echo "## scan disks" >> $file_log
  oracleasm scandisks

  echo "## oracle rac: start resource" >> $file_log
  /u01/app/12/grid/bin/crsctl start res ora.crsd -init

fi


# finished.
