# Kickstart file automatically generated by anaconda.

install

url --url=http://166.100.0.253/cobbler/ks_mirror/RHEL5-8-x86_64

key --skip

lang zh_CN.UTF-8

keyboard us

#network --onboot yes --device eth0 --bootproto dhcp --hostname cobbler-server --gateway 166.100.0.2 --noipv6

network --device eth0 --bootproto dhcp --hostname wgmcht
network --device eth1 --onboot no --bootproto dhcp --hostname wgmcht

reboot

rootpw  --iscrypted $6$b9dzjM3x3yqB4i9L$3y3rNuB6VTYeIyLrysJuoKLA/oDPhwEjzo9XkltII3PX6QawRPrY8kcV3zoZirixeQf4ltADTmdGPTqLtlsqa/

firewall --disabled

authconfig --enableshadow --passalgo=sha512

selinux --disabled

timezone --utc Asia/Shanghai

bootloader --location=mbr --driveorder=sda --append="rhgb quiet"

# The following is the partition information you requested
# Note that any partitions you deleted are not expressed
# here so unless you clear all partitions first, this is
# not guaranteed to work

# -----------------------
zerombr

#autopart

clearpart --linux
part / --fstype ext3 --size=20480
part /oradata --fstype ext3 --size=102400
part /bkmcht --fstype ext3 --size=20480
part /usr --fstype ext3 --size=7168
part /home --fstype ext3 --size=7168
part swap --size=2048

# -----------------------


%packages

@admin-tools
@base
@chinese-support
@core
@dialup
@editors
@gnome-desktop
@graphical-internet
@graphics
@java
@legacy-software-support
@office
@printing
@system-tools
@text-internet
@base-x
kexec-tools
iscsi-initiator-utils
fipscheck
device-mapper-multipath
bogl
bogl-bterm
sgpio
emacs
libsane-hpaio
audit
xorg-x11-utils
xorg-x11-server-Xnest

%post --interpreter=/bin/bash
(

# disable service startup
chkconfig iptables off

# yum repo file
cat <<EOF > /etc/yum.repos.d/rhel5.repo
[Server]
name=Server
baseurl=http://166.100.0.253/cobbler/ks_mirror/RHEL5-8-x86_64/Server
gpgcheck=0

[VT]
name=VT
baseurl=http://166.100.0.253/cobbler/ks_mirror/RHEL5-8-x86_64/VT
gpgcheck=0

[Cluter]
name=Cluster
baseurl=http://166.100.0.253/cobbler/ks_mirror/RHEL5-8-x86_64/Cluster
gpgchech=0

[ClusterStorage]
name=ClusterStorage
baseurl=http://166.100.0.253/cobbler/ks_mirror/RHEL5-8-x86_64/ClusterStorage
gpgcheck=0

EOF

# change /etc/inittab
sed -i 's/id:3:initdefault:/id:5:initdefault:/' /etc/inittab

# set eth0 onboot=yes
sed -i 's/ONBOOT=no/ONBOOT=on/' /etc/sysconfig/network-scripts/ifcfg-eth0

# Download Oracle Database Deploy Automatic Script
mkdir /root/linux-scripts

list_file="main.sh main.conf 1_os_alias_etc 2_dir 3_yum 4_selinux 5_linux_config_file 6_os_account 7_static_network 8_services 9_ora9i_deploy_by_copy"

for file_item in $list_file
do
  echo "=========================================="
  echo "@@@ file: $file_item"
  echo "~~~~~~~~~~~~~~~~~~~~~~"
  wget -P /root/linux-scripts -c "http://166.100.0.253/shell_script/oracle_script/$file_item"
  echo ""
done

chmod -R 775 /root/linux-scripts/*
echo "scripts has been download"

#----------------------------------------------------
/bin/cat <<ONBOOT >> /etc/rc.d/rc.local

# Run script
echo "" >> /var/log/messages
echo "============" >> /var/log/messages
echo "Run Script for Adamhuan" >> /var/log/messages
echo "============" >> /var/log/messages
echo "" >> /var/log/messages
sh /root/linux-scripts/main.sh

# System default
touch /var/lock/subsys/local

ONBOOT

) 2>&1 > /root/kickstart_post_script.log

%end
