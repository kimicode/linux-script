只有第一个脚本或命令执行成功后，才会执行下一个。
如果调用的一个命令中带有空格，需要用引号包起来。

具体如下：
```
[root@center-linux script]# sh run_1.sh
I am jack.
I ask for rose for some help.
-----
#### Hey rose, can you help me?
[root@center-linux script]#
[root@center-linux script]# sh run_2.sh
I am rose.
@@@ I am here, where are you, jak?
[root@center-linux script]#
[root@center-linux script]# sh run_multi_script_in_sequence.sh run_1.sh run_2.sh
*** running[1]: run_1.sh
I am jack.
I ask for rose for some help.
-----
#### Hey rose, can you help me?
 -- result: well

*** running[2]: run_2.sh
I am rose.
@@@ I am here, where are you, jak?
 -- result: well

[root@center-linux script]#
```
——————————————————————————————————————————
Done。
2017年1月23日09:56:00
