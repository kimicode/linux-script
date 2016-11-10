# automatic install MySQL Percona
# Script Type: shell
# Author: adamhuan
# Linux OS: RHEL 7
# Network: Need

# Variable

# MySQL:: Percona Server, direct Download Link, from official
download_link_mysql="https://www.percona.com/downloads/Percona-Server-5.7/Percona-Server-5.7.15-9/binary/redhat/7/x86_64/Percona-Server-5.7.15-9-r9f0fd0a-el7-x86_64-bundle.tar"

str_download_soft=`echo $download_link_mysql | cut -d'/' -f11`

dir_software="/software_me" # where we store download media temporay
dir_backup="/backup_me" # where we backup file before we changed it
dir_temp="/temp_me" # where we locate temp file
dir_mnt_iso="/iso_me" # where we mount ISO media, in default

dir_yum_repo="/etc/yum.repos.d/"
file_yum_repo_local_percona="percona_local.repo"

file_mysql_log_error="/var/log/mysqld.log"
#str_mysql_passwd_cust="Abcd!234"
#str_mysql_passwd_cust="Oracle_1234"
str_mysql_passwd_cust="Oracle@1234"

file_percona_config="/etc/percona-server.conf.d/mysqld.cnf"

# Function


# Display & Run
echo "============="
echo "Program name:: auto-Install_MySQL_Percona"
echo "Power By:: Adamhuan"
echo "Blog:: d-prototype.com"
echo "============="
echo "Start:: "`date`
echo "------------------"

# Prepare, Download dir, $dir_software
if [ ! -x "$dir_software" ]
then
  echo "## $dir_software is [NOT] exsist"
  echo "## Action, create dir:: $dir_software"
  mkdir "$dir_software"
  echo ""
else
  echo "## $dir_software is [ALREADY] exsist"
  echo ""
fi

# display, download link
echo "Download Link:: $download_link_mysql"
echo ""

# Do download
echo "@@@ download,[BEGIN]:: "`date "+|%Y-%m-%d|%H:%M:%S|"`
echo ""

wget -c -P $dir_software $download_link_mysql

echo "@@@ download,[DONE]:: "`date "+|%Y-%m-%d|%H:%M:%S|"`
echo ""

# un-tar MySQL media which we downloaded just now
echo "## Un-tar file:: $dir_software/$str_download_soft"
echo ""

echo "## Action, un-tar, [BEGIN]:: "`date`
echo ""

tar -xvf $dir_software/$str_download_soft -C $dir_software

echo ""
echo "## Action, un-tar, [FINISHED]:: "`date`
echo ""

# YUM:: createrepo
yum install -y createrepo

# Action, createrepo for $dir_software
createrepo $dir_software

# YUM config file
str_baseurl="file://$dir_software"
echo "-----------------"
echo "YUM REPO:: $dir_yum_repo/$file_yum_repo_local_percona"
echo "-----------------"
cat <<EOF > $dir_yum_repo/$file_yum_repo_local_percona
[Percona-Local]
name=Percona-Local
baseurl=$str_baseurl
gpgcheck=0
EOF

# YUM: EPEL
yum install -y epel*

# Action: Jemalloc
#yum install -y jemalloc*

# YUM: Percona-Server
# Search
echo "YUM:: Search Percona-Server"
echo ""

yum list | grep --color Percona-Server

echo "YUM:: Install Percona-Server"
echo "@@ YUM, Percona-Server, [BEGIN]:: "`date`
echo ""

yum install -y Percona-Server*

# 退回步骤：
# service mysql stop
# yum remove Percona-Server* -y

echo "@@ YUM, Percona-Server, [Finished]:: "`date`
echo ""

# Percona-Server: enable on boot, running right now
echo "## Start and enable MySQL Service: Percona-Server."
#systemctl enable mysql.service
systemctl start mysql.service

# sleep 3
sleep 3

# Percona-Server: password
str_mysql_passwd_temporary=`cat $file_mysql_log_error | grep --color "A temporary password is generated for" | cut -d':' -f4 | cut -d' ' -f2`

echo "## MySQL Temprary Password for root@localhost is:: $str_mysql_passwd_temporary"
echo ""

# Percona-Server: change config
cat <<EOF >> $file_percona_config
[client]
password=$str_mysql_passwd_temporary
EOF

# change password
echo "## Change MySQL Password. from:: $str_mysql_passwd_temporary | to:: $str_mysql_passwd_cust"
echo ""
#mysql -u'root' -p'$str_mysql_passwd_temporary' -e "<SQL Statement>"

mysqladmin -u root password '$str_mysql_passwd_cust'

#echo "## Password change, has been [DONE]."

# change Percona-Server config file:
sed -i "/password/s/$str_mysql_passwd_temporary/$str_mysql_passwd_cust/" $file_percona_config
echo "## MySQL config file, has been [CHANGED] to current new password."

echo "## Password change, has been [DONE]."
echo ""

echo "============="
echo "Finished:: "`date`
