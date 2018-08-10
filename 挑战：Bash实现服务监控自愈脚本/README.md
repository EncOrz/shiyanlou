# 挑战：Bash 实现服务监控自愈脚本

## 介绍

在服务器上我们的服务可能因为各种各样的原因挂掉，例如 mongodb Out of memory 了，被系统 kill 了，导致服务不能正常工作了。所以我们需要一个简易的监控脚本 `check_service.sh`，实时查看我们服务的状态，若是服务的状态是停止的话，能够尝试自动重启该服务。

脚本可以接受一个参数，参数是服务的名称，这个服务的名称可以使用 `service` 命令进行状态的查看、启动和停止，举个例子，检查 mysql 服务的状态：

```shell
$ bash /home/shiyanlou/check_service.sh mysql
is Running
```

如果 mysql 服务没有运行，则启动 mysql 服务并打印下面的输出信息：

```shell
$ bash /home/shiyanlou/check_service.sh mysql
Restarting
```

如果服务不存在，则输出错误信息：

```shell
$ bash /home/shiyanlou/check_service.sh notfoundservice
Error: Service Not Found
```

## 目标

1. 脚本名为 `check_service.sh`，路径必须为 `/home/shiyanlou/check_service.sh`
2. 脚本可以接受一个参数，参数是服务的名称，能够通过这样的方式调用 `check_service.sh 服务名称`
3. 若是服务正在运行中输出 “is Running”，若是为停止状态则启动该服务，如果服务不存在则输出错误信息
4. `/home/shiyanlou/check_service.sh mysql` 放入到 crontab，每天执行一次，可以保证 MySQL 服务挂掉的时候能够重启，注意需要手动启动 cron 服务

## 提示语

1. 可以使用 `sudo service xxx start/status/stop` 进行服务管理
2. 命令行位置参数的使用
3. 服务状态信息使用可以使用 grep 进行判断

## 知识点

- Bash 流程控制
- 服务与进程的控制
- Crontab

##解题

```bash
##查看service status状态返回

shiyanlou:~/ $ sudo service mysql status                                        [21:56:21]
 * MySQL is stopped.
shiyanlou:~/ $ sudo service ssh status                                          [21:56:23]
 * sshd is running
shiyanlou:~/ $ sudo service rsyslog status                                      [21:56:31]
 * rsyslogd is not running

##发现status会返回 停止（不在运行）：is stopped.(is not running)
##Mysql 服务在启动后返回有差异，可以用Uptime 关键字来判断

shiyanlou:~/ $ sudo service mysql status                                        [22:03:57]
 * /usr/bin/mysqladmin  Ver 8.42 Distrib 5.5.50, for debian-linux-gnu on x86_64
Copyright (c) 2000, 2016, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Server version		5.5.50-0ubuntu0.14.04.1
Protocol version	10
Connection		Localhost via UNIX socket
UNIX socket		/var/run/mysqld/mysqld.sock
Uptime:			5 sec

Threads: 1  Questions: 110  Slow queries: 0  Opens: 48  Flush tables: 1  Open tables: 41  Queries per second avg: 22.000

```



```shell
$ vi check_service.sh && chmod 755 check_service.sh

#!/bin/bash

if [ $# -ne 0 ];then
        cs=$(sudo service "$1" status 2>/dev/null )
    if [[ $cs =~ "is running" ||  $cs =~ Uptime ]] 
    then
        echo is Running
    else
        if [[ $cs =~ stopped || $cs =~ "not running" ]]
        	then
            	sudo service $1 start &> /dev/null
            	echo Restarting
        else
        		echo Error: Service Not Found
   		fi
    fi
fi

```

```shell
cron -f &
crontab -e ##输入G和O，后添加一行
0 0 * * * 'bash /home/shiyanlou/check_service.sh mysql'  ##保存后退出
```

