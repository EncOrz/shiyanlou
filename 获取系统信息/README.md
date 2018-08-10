# 获取系统信息

## 简介

小楼是一个系统管理员，需要编写一个脚本 `getinfo.sh` 获取 Linux 服务器的 CPU、内存等信息。

脚本 `getinfo.sh` 脚本执行时候不需要任何参数，输出的内容包括以下信息：

```shell
$ bash getinfo.sh
cpu num: 2
memory total: 2.8G
memory free: 329M
disk size: 10G
system bit: 32
process: 32
software num: 944
ip: 192.168.1.9
```

注意上述每行内容的冒号后都有一个空格。

其中包括的数据项：

1. CPU数量（cpu num）
2. 总内存（memory total），单位为 G
3. 可用内存（memorty free），单位为 M
4. 挂载到 `/` 根目录的文件系统的总大小（disk size），单位为 G
5. 系统位数（system bit）
6. 当前系统正在运行的进程数（process）
7. 查看已安装的软件包数量（software num）
8. eth0的ip地址（ip）

## 目标

1. 脚本存放的路径必须在 `/home/shiyanlou/getinfo.sh`
2. 输出的信息一共有 8 行，需要按照上面给出的示例的顺序
3. 脚本执行过程及输出信息需要满足上述需求



##解题

```shell
vi ~/getinfo.ch && sudo chmod 755 ~/getinfo.sh

#!/bin/bash

cat /proc/cpuinfo | awk '/^processor/ {s++} END{print "cpu num: "s}'
free -m | awk '/^Mem/ {print "memory total: " ($2/1024.0)"G"}'
free -m | awk '/^Mem/ {print "memory free: "$4"M"}'
df -hT | awk '{if($7~/\/$/){print "disk size: "$3}}'
echo system bit: $(getconf LONG_BIT)
ps aux | awk '{if($8~/R/){++s}} END {print  "process: "s}'
echo software num: $(dpkg -l | wc -l)
ip a s eth0 | awk '{if($1~/inet$/){split($2,s,"/");print "ip: " s[1]}}'


## /proc/cpuinfo CPU信息
## free 内存信息
## getconf 将系统变量值输出 LONG_BIT 类型中的位数，类型为 long int
## pa aux 查看进程 R=RUNNING
```

