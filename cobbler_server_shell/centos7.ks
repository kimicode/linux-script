#version=DEVEL

# Use CDROM installation media
#cdrom
url --url=http://192.168.147.254/cobbler/ks_mirror/centos7-x86_64

reboot

# System authorization information
auth --enableshadow --passalgo=sha512
repo --name="Server-HighAvailability" --baseurl=file:///run/install/repo/addons/HighAvailability
repo --name="Server-ResilientStorage" --baseurl=file:///run/install/repo/addons/ResilientStorage

# Use graphical install
graphical

# Run the Setup Agent on first boot
firstboot --disable

ignoredisk --only-use=sda

# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'

# System language
lang en_US.UTF-8 --addsupport=zh_CN.UTF-8

# Network information
#network  --bootproto=static --device=eth0 --gateway=192.168.232.2 --ip=192.168.78.131 --nameserver=114.114.114.114 --netmask=255.255.255.0 --ipv6=auto --activate

network  --onboot yes --bootproto=dhcp --device=eth0 --gateway=192.168.232.2 --nameserver=114.114.114.114 --ipv6=auto --activate
network  --hostname=rhel7

# Root password
rootpw --iscrypted $6$lEixIcmAnF6X4YKy$H9gO9hQH76soukGIpd4.qGbhHpoaZGIkZY7icx9CbXvDbpGpe/oPiLC9eJuf0yp9AADWN.VvKCL1ZgEPs99Ml/

selinux --disabled

# System services
services --disabled="chronyd"

# System timezone
timezone Asia/Shanghai --isUtc --nontp

# X Window System configuration information
xconfig  --startxonboot

# MBR
zerombr

# System bootloader configuration
#bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=sda

autopart --type=lvm

# Partition clearing information
clearpart --all --initlabel --drives=sda

%packages
@^graphical-server-environment
@base
@core
@desktop-debugging
@dial-up
@fonts
@gnome-desktop
@guest-agents
@guest-desktop-agents
@input-methods
@internet-browser
@multimedia
@print-client
@x11
kexec-tools

%end

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%post --interpreter=/bin/bash
(
# disable service
systemctl disable firewalld.service

# disable Gnome initial setup
sed -i '/daemon/aInitialSetupEnable=False' /etc/gdm/custom.conf

# Yum config
cat <<EOF > /etc/yum.repos.d/rhel7.repo
[ISO]
name=ISO
baseurl=http://192.168.147.254/cobbler/ks_mirror/centos7-x86_64/
gpgcheck=0

[HighAvailability]
name=HighAvailability
baseurl=http://192.168.147.254/cobbler/ks_mirror/centos7-x86_64/addons/HighAvailability/
gpgcheck=0
enabled=0

[ResilientStorage]
name=ResilientStorage
baseurl=http://192.168.147.254/cobbler/ks_mirror/centos7-x86_64/addons/ResilientStorage/
gpgcheck=0
enabled=0

EOF

) > /root/kickstart_post.log

%end
