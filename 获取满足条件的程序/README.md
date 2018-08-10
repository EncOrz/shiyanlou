# 获取满足条件的程序

## 介绍

实验楼的实验环境中运行了大量的服务进程，有的时候启动新的服务时会遇到端口已被占用的报错信息。

请实现一个脚本获取指定端口上正在运行的程序，如果没有运行任何程序则打印 `OK` 字符串。

## 目标

1. 完成的脚本必须放置在 `/home/shiyanlou/get.sh`
2. 脚本执行时需要输入一个端口号数字作为参数，例如 `/home/shiyanlou/get.sh 5901`
3. 脚本执行后输出`OK`或者该端口上正在运行的程序完整路径。

脚本执行举例：

```shell
$ cd /home/shiyanlou
$ ./get.sh 5901
/usr/bin/Xvnc
$ ./get.sh 43000
OK
```

##解题

```shell
#!/bin/bash

if [ $# -ne 0 ];then
     cmd_n=$(sudo netstat -tunlp | awk '{if($4~/:'$1'$/) print $7}' | cut -d '/' -f 2 | grep -v '-'  )
        if [ -z "$cmd_n"  ] ;then
                echo OK
        else
                which $cmd_n | uniq
        fi
fi

##cut -d 分割 -f 域
##if [ -z "$cmd_n"  ]  -z判断空
```

