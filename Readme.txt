open-linux-script
-------------
说明：

在该项目中，我会依照不同的目的来建立不同的文件夹，存放需要完成目标所需的全部自动化脚本。
这里暂且称之为“脚本组”。

每个脚本组的结构是这样的：
kickstart-cfg，配合PXE Server的脚本调用模板。
scripts，存放所有脚本组的脚本
main.sh，脚本组的起始脚本。用于集中调用所有其他的成员脚本
main.conf，控制是否允许main.sh执行的配置文件
数字_脚本名，成员脚本。其中数字代表了它们被执行的次序。
log_脚本名，成员脚本执行时生成的日志文件。

——————
当前脚本组：

kickstart_oracle_database，全脚本化的部署和配置Oracle数据库。
@@@ 2016年1月1日：
@@@ 自动化已支持到：数据库软件安装完成

@@@ 2016年1月2日：
@@@ 自动化已支持到：自动配置监听器、自动建立数据库实例

Adamhuan_PXE_Server，自动配置PXE Server。
脚本使用的说明：http://d-prototype.com/archives/4335
@@@ 2016年2月16日：
@@@ 自动配置PXE Server。

cobbler_server_shell，自动配置Cobbler Server。
脚本使用说明：
1. http://d-prototype.com/archives/4386
2. http://d-prototype.com/archives/4390
@@@ 2016年2月20日：该脚本需要Linux版本为：RHEL6，或者以上。

——————
Last edit：Adamhuan，2016年1月1日17:57:54