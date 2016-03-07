# auto deploy: Cobbler Server
# 执行该脚本，你可能需要修改的两个参数：
# 1. 主机名的设定：cust_machine_hostname
# 2. YUM源的IP地址：var_repo_source_server
# 3. 执行脚本前，挂在光盘介质到/iso，或者修改改脚本中的YUM源的变量
# 4. 软件包的安装方式：离线（offline）、在线（online），默认：在线
#	 该设定在运行时的部分的：do_install_addition_rpm offline，设置。

# -----------------------------
# 函数

# 将路径格式字符串转换成适合sed过滤条件的字符串
func_sed_path(){
  # $1，原始路径
  func_file_path="$1"

  echo "$func_file_path" | sed 's/\//\\\//g'
}

# 替换函数
func_replace(){
  # $1,文件
  # $2,搜索词
  # $3,新值
  # $4,分隔符
  func_file="$1"
  func_search_str="$2"
  func_new_value="$3"
  func_split_str="$4"

  func_old_value=`cat "$func_file" | grep -v "^#" | grep "$func_search_str$func_split_str" | cut -d"$func_split_str" -f2`

  func_new_value_sed=`func_sed_path $func_new_value`
  func_old_value_sed=`func_sed_path $func_old_value`

  # Display
  echo "File: $func_file"
  echo "====================="
  echo "Old value is: $func_old_value"
  echo "New value is: $func_new_value"
  echo ""

  if [[ "$func_old_value" != "" ]]
  then
    sed -i "/$func_search_str/s/$func_old_value_sed/$func_new_value_sed/" "$func_file"
  else
    echo "$func_search_str$func_split_str$func_new_value" >> "$func_file"
  fi

}

# -----------------------------
# 逻辑块

# 禁用SELINUX的启用
do_disable_selinux(){
  entry_selinux=`cat "$file_sys_selinux_config" | grep -v "^#" | grep "SELINUX=" | cut -d"=" -f2`

  #if [ "$entry_selinux" = "enforcing" ] || [ "$entry_selinux" = "permissive" ]
  if [ "$entry_selinux" != "disabled" ]
  then
    func_replace "$file_sys_selinux_config" "SELINUX" "disabled" "="

    # 并且，将SELINUX的状态修改为警告模式，而不是启用

    # 当前状态
    echo ""
    echo "@@@ selinux status - before change:"
    getenforce
    echo ""

    # 开始修改SELINUX，从强制变为警告
    setenforce 0

    # 修改完成后：
    echo ""
    echo "@@@ selinux status - after change:"
    getenforce
    echo ""

  fi
}

# 静态化网络
do_static_network(){
  # 初始化hosts表
  echo "" > $file_sys_hosts

  # 收集当前系统的网络信息
  list_ifconfig=`ifconfig | grep --color "Link encap:" | cut -d' ' -f1`
  list_ifconfig_keys="BOOTPROTO ONBOOT IPADDR NETMASK GATEWAY DNS1"

  for item_ifcfg in $list_ifconfig
  do
    path_ifcfg_item="/etc/sysconfig/network-scripts/ifcfg-$item_ifcfg"

    func_item_ipaddr=`ifconfig $item_ifcfg | grep "inet addr:" | cut -d':' -f2 | cut -d' ' -f1`
    func_item_mask=`ifconfig $item_ifcfg | grep "inet addr:" | cut -d"k" -f2 | cut -d':' -f2`
    func_item_gateway=`/sbin/route -n | grep "^0\.0\.0\.0" | awk '{ print $2 }'`

    func_var_hostname="$cust_machine_hostname"

    case "$item_ifcfg" in
      "eth0" )
      #func_var_hostname="$cust_machine_hostname"
      echo "# network: eth0" >> $file_sys_hosts
      ;;
      "eth1" )
      func_var_hostname+="-priv"
      echo "# network: eth1" >> $file_sys_hosts
      ;;
      "lo" )
      func_var_hostname="localhost"
      echo "# network: lo" >> $file_sys_hosts
      ;;
    esac

    for item_ifcfg_key in $list_ifconfig_keys
    do
      case "$item_ifcfg_key" in
        "BOOTPROTO" )
          func_replace "$path_ifcfg_item" "BOOTPROTO" "static" "="
        ;;
        "ONBOOT" )
          func_replace "$path_ifcfg_item" "ONBOOT" "on" "="
        ;;
        "IPADDR" )
          # 写入ifcfg网卡配置文件
          func_replace "$path_ifcfg_item" "IPADDR" "$func_item_ipaddr" "="
          # 写入hosts表
          echo "$func_item_ipaddr $func_var_hostname" >> $file_sys_hosts
        ;;
        "NETMASK" )
          func_replace "$path_ifcfg_item" "NETMASK" "$func_item_mask" "="
        ;;
        "GATEWAY" )
          func_replace "$path_ifcfg_item" "GATEWAY" "$func_item_gateway" "="
        ;;
        "DNS1" )
          func_replace "$path_ifcfg_item" "DNS1" "114.114.114.114" "="
        ;;

      esac

    done

  done

}

# 处理服务：开机启动或禁用、运行或停止
do_action_service(){
  # $1, 服务列表
  # $2, 操作类型（chkconfig/service）
  # $3, 操作（on/off/start/stop）
  func_list_service="$1"
  func_action_type="$2"
  func_action_value="$3"

  for item_service in $func_list_service
  do
    #case "$func_action_type" in
    #  "chkconfig" )
    #    chkconfig $item_service $func_action_value
    #  ;;
    #  "service" )
    #    service $item_service $func_action_value
    #  ;;
    #esac

    $func_action_type $item_service $func_action_value

  done
}

# 打开YUM配置文件的本地缓存
do_enable_yum_keepcache(){
  func_replace "$file_sys_yum_conf" "cachedir" "$cust_yum_keepcache_dir" "="
  func_replace "$file_sys_yum_conf" "keepcache" "1" "="
}

# 配置YUM源文件
do_yum_repo(){
  # 清空YUM源文件路径
  rm -rf $file_sys_yum_repo_base/*

  # $1, YUM标记列表（eg：RHEL5-32、RHEL6-64，...etc）
  func_list_repo="$1"

  if [ "$func_list_repo" = "" ]
  then
    func_list_repo="$var_os_release-$var_long_bit"
  fi

  for item_repo in $func_list_repo
  do
    var_func_repo_file="$file_sys_yum_repo_base/$item_repo.repo"

    `do_repo_data "$var_func_repo_file" "$item_repo"`

  done
}

# 配置YUM源文件：生成选择性的数据
do_repo_data() {
  # $1, 写入文件
  # $2, repo信号（一次处理一个，一次运行只输出一次完整记录）
  var_repo_file="$1"
  var_repo_signal="$2"

  case "$var_repo_signal" in
    "RHEL5-64" )
     cat <<RHEL5-64 > $var_repo_file
[Server]
name=Server
baseurl=$cust_yum_repo_source/Server
gpgcheck=0

[VT]
name=VT
baseurl=$cust_yum_repo_source/VT
gpgcheck=0

[Cluter]
name=Cluster
baseurl=$cust_yum_repo_source/Cluster
gpgchech=0

[ClusterStorage]
name=ClusterStorage
baseurl=$cust_yum_repo_source/ClusterStorage
gpgcheck=0
RHEL5-64
    ;;

    "RHEL6-64" )
    cat <<RHEL6-64 > $var_repo_file
[ISO]
name=ISO
baseurl=$cust_yum_repo_source/
gpgcheck=0

[HighAvailability]
name=HighAvailability
baseurl=$cust_yum_repo_source/HighAvailability
gpgcheck=0

[LoadBalancer]
name=LoadBalancer
baseurl=$cust_yum_repo_source/LoadBalancer
gpgchech=0

[ResilientStorage]
name=ResilientStorage
baseurl=$cust_yum_repo_source/ResilientStorage
gpgcheck=0

[ScalableFileSystem]
name=ScalableFileSystem
baseurl=$cust_yum_repo_source/ScalableFileSystem
gpgcheck=0

[Server]
name=Server
baseurl=$cust_yum_repo_source/Server
gpgcheck=0
RHEL6-64
    ;;

    "C6-64" )
    # CentOS 6 64bit
    cat <<C6-64 > $var_repo_file
[ISO]
name=ISO
baseurl=$cust_yum_repo_source/
gpgcheck=0
C6-64
    ;;
  esac
}

# 刷新YUM源库缓存
do_yum_refresh(){
  echo "Yum clean metadata:"
  echo "**********************"
  yum clean metadata
  echo ""
  echo "Yum clean all:"
  echo "**********************"
  yum clean all
  echo ""
  echo "Yum list repo:"
  echo "**********************"
  yum repolist
  echo ""
}

# 文件：/etc/cobbler/settings
do_cobbler_settings(){
  # 实时变量
  var_eth0_ipaddr=`ifconfig eth0 | grep "inet addr:" | cut -d':' -f2 | cut -d' ' -f1`

  # 执行替换
  func_replace "$file_sys_cobbler_settings" "^server" "$var_eth0_ipaddr" ":"
  func_replace "$file_sys_cobbler_settings" "^next_server" "$var_eth0_ipaddr" ":"
  func_replace "$file_sys_cobbler_settings" "^pxe_just_once" "1" ":"
  func_replace "$file_sys_cobbler_settings" "^manage_rsync" "1" ":"
  func_replace "$file_sys_cobbler_settings" "^manage_dhcp" "1" ":"

  var_default_password=`openssl passwd -1 -salt 'random-phrase-here' '$default_password'`
  func_replace "$file_sys_cobbler_settings" "^default_password_crypted" "$var_default_password" ":"
}

# 文件：/etc/cobbler/users.digest
do_cobbler_users_digest(){
  # 设置Cobbler web的登录密码
  # 用户：cobbler

  # 需要人为交互
  #htdigest /etc/cobbler/users.digest "Cobbler" cobbler

  # 非交互，口令：oracle
  echo "cobbler:Cobbler:93806e7cf2fdd3d0981076a186eecb5d" > "$file_sys_cobbler_user_digest"
}

# 文件：/etc/cobbler/dhcp.template
do_cobbler_dhcp_template(){
  var_eth0_ipaddr=`ifconfig eth0 | grep "inet addr:" | cut -d':' -f2 | cut -d' ' -f1`
  var_eth0_ipaddr_top3=`ifconfig eth0 | grep "inet addr:" | cut -d':' -f2 | cut -d' ' -f1 | awk -F'.' '{ print $1"."$2"."$3}'`
  var_eth0_gateway=`/sbin/route -n | grep "^0\.0\.0\.0" | awk '{ print $2 }'`

  sed -i "s/192.168.1/$var_eth0_ipaddr_top3/g" $file_sys_cobbler_dhcp_template
  sed -i "s/$var_eth0_ipaddr_top3.5/$var_eth0_gateway/g" $file_sys_cobbler_dhcp_template

}

do_cobbler_httpd(){
  sed -i "/ServerName www.example.com:80/aServerName Cobbler-Server" $file_sys_httpd_conf
}

# Cobbler配置：集中
do_cobbler(){
  do_cobbler_settings
  do_cobbler_users_digest
  do_cobbler_dhcp_template
  do_cobbler_httpd

}

# Cobbler：启动与检测
do_refresh_cobbler(){
  # get-loaders
  echo "============================="
  echo "@@@ cobbler: get-loaders."
  cobbler get-loaders
  echo ""

  echo "@@@ cobbler: check."
  cobbler check
  echo ""

  echo "@@@ cobbler: sync"
  cobbler sync
  echo ""
}

# 部署额外安装包：离线或者在线
# 主要是两个程序包：EPEL及其相关软件包、PyYAML
do_install_addition_rpm(){
  # $1, 安装方式：online / offline
  install_method="$1"

  case "$install_method" in
    "online" )
      # 7. EPEL and PyYAML
      # EPEL
      rm -rf /tmp/epel*

      wget -P /tmp "$path_epel_rpm"

      rpm -e epel-release
      rpm -ivh /tmp/epel-release*.rpm

      # PyYAML
      rm -rf /tmp/PyYAML*

      wget -P /tmp "$path_pyyaml_rpm"

      rpm --nodeps -e PyYAML
      yum install -y libyaml*
      rpm -ivh /tmp/PyYAML*.rpm

      # 刷新YUM库
      do_yum_refresh
    ;;
    "offline" )
      yum install -y mod_wsgi createrepo python-cheetah python-simplejson syslinux mod_ssl libyaml
      rpm -ivh "$path_offline_rpm/*.rpm"
    ;;
  esac
}

# -----------------------------
# 文件与路径

# Part: Execute script
path_execute_dir=`dirname $0`

# Part: Install
file_sys_network="/etc/sysconfig/network"
file_sys_selinux_config="/etc/selinux/config"
file_sys_resolv="/etc/resolv.conf"
file_sys_hosts="/etc/hosts"
file_sys_yum_conf="/etc/yum.conf"
file_sys_release="/etc/redhat-release"
file_sys_yum_repo_base="/etc/yum.repos.d"

# Part: Configuration
file_sys_tftp="/etc/xinetd.d/tftp"
file_sys_rsync="/etc/xinetd.d/rsync"

file_sys_cobbler_settings="/etc/cobbler/settings"
file_sys_cobbler_user_digest="/etc/cobbler/users.digest"
file_sys_cobbler_dhcp_template="/etc/cobbler/dhcp.template"

file_sys_httpd_conf="/etc/httpd/conf/httpd.conf"

# -----------------------------
# 变量

# Cobbler服务器主机名
cust_machine_hostname="cobbler-master"

# YUM源的地址（cust_yum_repo_source）
#@@ Way One，关键是：cust_yum_repo_source，的赋值
cust_yum_repo_source_dir="/iso"
cust_yum_repo_source="file://$cust_yum_repo_source_dir"

#@@ Way Two，关键是：cust_yum_repo_source，的赋值
var_repo_source_server_protocol="ftp"
var_repo_source_server="192.168.184.132"

var_os_release=`cat $file_sys_release | sed 's/[[:space:]]/\n/g' | awk -v FS="" '{print $1}' | awk '{ for (i=1;i<=NF;i++) if($i != "S" && $i != "r" && $i != "(" ) {printf $i}}END{printf "\n"}'`
var_long_bit=`getconf LONG_BIT`

#cust_yum_repo_source="$var_repo_source_server_protocol://$var_repo_source_server/media_store/os/linux/rhel/$var_os_release/$var_long_bit"

#-- 转化sed处理
#cust_yum_repo_source_sed=`func_sed_path $cust_yum_repo_source`

# YUM的缓存地址
cust_yum_keepcache_dir="/tmp/yum_data"
#cust_yum_keepcache_dir_sed=`func_sed_path $cust_yum_keepcache_dir`

# Cobbler

# Cobbler的默认密码
default_password="oracle"

# 在线安装包

# EPEL的在线安装包
#path_epel_rpm="http://mirrors.ustc.edu.cn/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm"
path_epel_rpm="https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm"

# PyYAML的在线安装包
path_pyyaml_rpm="ftp://ftp.icm.edu.pl/vol/rzm5/linux-oracle-repo/OracleLinux/OL6/openstack10/x86_64/getPackage/PyYAML-3.10-3.el6.x86_64.rpm"

# Cobbler Server部署需要的离线安装包的目录
# 该路径下存放的RPM为：在“在线”安装的时候由脚本自动下载的EPEL和PyYAML的RPM文件，以及YUM安装过程中，缓存本地的软件包
path_offline_rpm="$path_execute_dir/cobbler_server_offline"

# -----------------------------
# 运行时

# 0. 准备
# -- a. 挂载光盘介质，在我的这个脚本中，我默认挂载到：/iso
# -- b. 如果离线安装，需要准备好离线软件包的存放目录；离线的软件包介质，来自于上一次你成功的在线安装时的本地RPM缓存
# -- c. 确认YUM源的获取方式，本地？还是，远端服务器

# 以上几点确认无误后，就可以运行脚本了。

# 1. 主机名
func_replace "$file_sys_network" "HOSTNAME" "$cust_machine_hostname" "="

# 2. SELINUX：禁用
do_disable_selinux

# 3. 静态化网络
do_static_network
do_action_service "network" "service" "restart"
echo "========================"
ping -c 3 baidu.com
echo "========================"

# 4. 禁用服务开机运行
do_action_service "iptables ip6tables" "chkconfig" "off"

# 5. 启用YUM本地缓存
do_enable_yum_keepcache

# 6. 配置YUM源文件
do_yum_repo

# 在线部署需要的软件包
# Version 1
# 开始
# ===============================================
# 7. EPEL and PyYAML
# EPEL
#rm -rf /tmp/epel*

##wget -P /tmp http://mirrors.ustc.edu.cn/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm
#wget -P /tmp https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm

#rpm -e epel-release
#rpm -ivh /tmp/epel-release*.rpm

# PyYAML
#rm -rf /tmp/PyYAML*

#wget -P /tmp ftp://ftp.icm.edu.pl/vol/rzm5/linux-oracle-repo/OracleLinux/OL6/openstack10/x86_64/getPackage/PyYAML-3.10-3.el6.x86_64.rpm

#rpm --nodeps -e PyYAML
#yum install -y libyaml*
#rpm -ivh /tmp/PyYAML*.rpm
# ===============================================
#结束

# Version 2
# 在线安装
do_install_addition_rpm online
# 离线安装
#do_install_addition_rpm offline

# 9. Yum安装Cobbler及其关联的软件包
do_yum_refresh
yum install -y cobbler cobbler-web xinetd pykickstart cman dhcp tftp-server bind

# 10. YUM安装完成后需要启用的服务
do_action_service "httpd dhcpd cobblerd" "chkconfig" "on"
#do_action_service "httpd cobblerd" "service" "restart"

# COBBLER服务器的安装，到这里就完成了。
echo ""
echo "**********************"
echo "Cobbler Server: Install Part - Done."
echo "**********************"
echo ""

# 接下来是Cobbler服务器的配置。
echo "@@@ cobbler server: Configuration Part."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""

# tftp
sed -i '/disable/s/yes/no/' $file_sys_tftp

# rsync
sed -i '/disable/s/yes/no/' $file_sys_rsync

# cobbler:settings
do_cobbler

# 重启服务
do_action_service "xinetd httpd cobblerd" "service" "restart"

# 启动Cobbler
do_refresh_cobbler

# 访问Cobbler web
# http://<cobbler_server_ip>/cobbler-web

# 导入系统镜像
# 1. mount /iso
# 2. cobbler import --path=/mnt --name=CentOS-6.6 --arch=x86_64
#    cobbler profile report/list
#    cobbler distro report/list
# 3. kickstart script
# 4. cobbler profile edit --name=xxxx --kickstart=xxx

# 客户机：以PXE方式启动 --> 选择需要安装的Linux发行版 --> 等待一段时间 --> All Done。

# -----------------------------
# 终结
