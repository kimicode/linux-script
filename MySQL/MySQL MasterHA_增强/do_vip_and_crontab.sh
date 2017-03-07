# file: do_vip_and_crontab.sh

# 职能：
# --> 1. 启动或停止：虚拟IP
# --> 2. 启用或禁用：crontab策略

# variable

# ---> 信号量
# 对于所有信号而言：
# 0，启用
# 1，禁用

#是否启用：VIP
#sign_vip=0
sign_vip="$1"

# 是否启用：crontab
#sign_crontab=0
sign_crontab="$2"

# 对于VIP而言
str_vip="10.158.1.111"
str_mask="255.255.255.0"
str_nic_name="eth0:0"

# 对于CRONTAB而言

# for RHEL6
# 如果是root用户，就会在：/var/spool/cron/root
file_crontab_dir="/var/spool/cron"
file_crontab_conf="$file_crontab_dir/root"

str_crontab_command="echo 'hello world' > /tmp/me"
str_crontab_date="10 11 * * *"

str_crontab_command_sed=`echo "$str_crontab_command" | sed 's/\//\\\//g'`
str_crontab_date_sed=`echo "$str_crontab_date" | sed 's/*/\\\*/g'`

str_crontab_full="$str_crontab_date $str_crontab_command"
str_crontab_full_sed="$str_crontab_date_sed $str_crontab_command_sed"

str_block_crontab_content=`cat $file_crontab_conf | grep -v '#'`

# disable

echo "Crontab content:"
echo "$str_block_crontab_content"
echo ""

echo "var: str_crontab_date --> $str_crontab_date"
echo "var: str_crontab_command --> $str_crontab_command"
echo "--------------------------------------------"
echo "var: str_crontab_full --> $str_crontab_full"

echo ""

echo "var: str_crontab_date_sed --> $str_crontab_date_sed"
echo "var: str_crontab_command_sed --> $str_crontab_command_sed"
echo "--------------------------------------------"
echo "var: str_crontab_full_sed --> $str_crontab_full_sed"

echo ""

# running

if [ $sign_vip -eq "0" ]
then
  echo "------------"
  echo "VIP:: enable."
  ifconfig $str_nic_name $str_vip netmask $str_mask up
  echo ""
else
  echo "------------"
  echo "VIP:: disable."
  ifconfig $str_nic_name $str_vip netmask $str_mask down
  echo ""
fi

if [ $sign_crontab -eq "0" ]
then
  echo "------------"
  echo "CRONTAB:: enable."

  if [[ $str_block_crontab_content =~ "$str_crontab_full" ]]
  then
    echo "CRONTAB Policy is in [$file_crontab_conf]"

  else
    echo "CRONTAB Policy is not in [$file_crontab_conf]"
    echo "Put it in, ..."
    echo "$str_crontab_full" >> $file_crontab_conf
    echo "Done."
  fi

  echo ""
else
  echo "------------"
  echo "CRONTAB:: disable."

  if [[ $str_block_crontab_content =~ "$str_crontab_full" ]]
  then
    echo "CRONTAB Policy is in [$file_crontab_conf]"
    echo "change it, ..."
    sed -i "s/$str_crontab_full_sed/#$str_crontab_full_sed/g" $file_crontab_conf
    echo "Done."

  else
    echo "CRONTAB Policy is not in [$file_crontab_conf]"

  fi

  echo ""
fi

# Finished
