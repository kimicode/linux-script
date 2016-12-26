# Script
# Name: Oracle automatic manual create database

# INIT

# variable
list_instance_active=""
list_lsnr_active=""

# 新增实例的名字
# 获取这个变量的方法很多：
# 1. 从脚本调用的时候采集需要的新增实例信息？
var_instance_name=$1

# Oracle DB Account Info
var_oracle_db_sys_password="oracle"

# directories
path_oracle_base=`su - oracle -c "env | grep ORACLE_BASE" | cut -d'=' -f2`
path_oracle_home=`su - oracle -c "env | grep ORACLE_HOME" | cut -d'=' -f2`

# dir by compute
path_oracle_base_admin=$path_oracle_base/admin
path_oracle_base_admin_for_instance=$path_oracle_base_admin/$var_instance_name

path_oracle_oradata=$path_oracle_base/oradata
path_oracle_oradata_for_instance=$path_oracle_oradata/$var_instance_name

path_oracle_home_dbs=$path_oracle_home/dbs
file_oracle_passwd_file_for_instance=$path_oracle_home_dbs/orapwd$var_instance_name
file_oracle_pfile_for_instance=$path_oracle_home_dbs/init$var_instance_name.ora

# function

function hello_world() {
  #statements
  echo "————————————"
  echo "Oracle Enhanced SHELL"
  echo "--> manual create database"
  echo "————————————"
  echo "Start @ " `date "+|%Y-%m-%d|%H:%M:%S|"`
  echo "============"
}

function bye_world() {
  #statements
  echo ""
  echo "============"
  echo "Finished @ " `date "+|%Y-%m-%d|%H:%M:%S|"`
}

function currrent_status() {
  list_instance_active=`ps -ef | grep --color pmon | grep -v grep | awk '{print $8}' | cut -d'_' -f3`
  for item_inst in `echo $list_instance_active`
  do
    echo "--- --- ---"
    echo "Instance:: $item_inst is running"

  done
}

function create_path_and_file_for_instance() {
  #statements
  # admin
  mkdir -p $path_oracle_base_admin_for_instance/{adump,dpdump,pfile}
  chown -R oracle.oinstall $path_oracle_base_admin_for_instance
  # oradata
  mkdir -p $path_oracle_oradata_for_instance
  chown -R oracle.oinstall $path_oracle_oradata_for_instance

  # file: orapw
  su - oracle -c "orapwd file=$file_oracle_passwd_file_for_instance password=$var_oracle_db_sys_password"
}

function create_pfile_for_instance() {
  #statements
  cat <<PFILE > $file_oracle_pfile_for_instance
db_name='$var_instance_name'
db_domain=''

control_files=(/u01/app/oracle/oradata/$var_instance_name/control01.ctl,/u01/app/oracle/oradata/$var_instance_name/control02.ctl,/u01/app/oracle/oradata/$var_instance_name/control03.ctl)
diagnostic_dest='$path_oracle_base'

db_recovery_file_dest='$path_oracle_base/fast_recovery_area'
db_recovery_file_dest_size=4G

audit_file_dest='$path_oracle_base_admin_for_instance/adump'
audit_trail='db'

db_block_size=8192

memory_target=800m

open_cursors=300
processes=150

remote_login_passwordfile='EXCLUSIVE'

undo_tablespace='UNDOTBS1'

compatible='11.2.0.4.0'

PFILE
}

function sqlplus_do_action() {
  #statements
  str_command="$1"

  sqlplus / as sysdba<<SQLPLUS
"$str_command"
SQLPLUS
}

function do_oracle() {
  #statements
  su - oracle -c "export ORACLE_SID=$var_instance_name; sqlplus / as sysdba<<SQLPLUS
create spfile from pfile;
startup nomount;
create database $var_instance_name
maxlogfiles 16
maxlogmembers 4
maxdatafiles 1024
maxinstances 1
maxloghistory 680
character set al32utf8
datafile '$path_oracle_oradata_for_instance/system01.dbf' size 500m reuse extent management local
undo tablespace undotbs1 datafile '$path_oracle_oradata_for_instance/undotbs101.dbf' size 800m
sysaux datafile '$path_oracle_oradata_for_instance/sysaux01.dbf' size 500m
default temporary tablespace temp tempfile '/$path_oracle_oradata_for_instance/temp01.dbf' size 500m
default tablespace users datafile '$path_oracle_oradata_for_instance/users01.dbf' size 500m
logfile
group 1
(
'$path_oracle_oradata_for_instance/redo101.log','$path_oracle_oradata_for_instance/redo102.log'
) size 50m,
group 2
(
'$path_oracle_oradata_for_instance/redo201.log','$path_oracle_oradata_for_instance/redo202.log'
) size 50m,
group 3
(
'$path_oracle_oradata_for_instance/redo301.log','$path_oracle_oradata_for_instance/redo302.log'
) size 50m
user sys identified by $var_oracle_db_sys_password
user system identified by $var_oracle_db_sys_password
;
@?/rdbms/admin/catalog.sql;
@?/rdbms/admin/catproc.sql;
conn system/oracle;
@?/rdbms/admin/pupbld.sql;
SQLPLUS"
  #sqlplus_do_action "create spfile from pfile"
}

# run

# 0. hello world
hello_world

# 1. check current running instance
currrent_status

# 2. create path and normal file
create_path_and_file_for_instance

# 3. create pfile for instance
create_pfile_for_instance

# 4. do oracle staff
do_oracle

# display

# Bye world
bye_world

# Finished
