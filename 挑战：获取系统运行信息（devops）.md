# 挑战：获取系统运行信息（devops）

## 介绍

实验楼的服务器随时都有可能遇到各种各样的问题，我们需要通过一些系统信息来预测可能出现的问题，通过系统监控命令完成脚本 `/home/shiyanlou/getinfo.sh` 获取当前系统中的信息，并作相应的判断：

- 获取`/`根目录挂载的磁盘使用情况：

  - 当使用量大于 85% 的时候输出 `Disk-Root 90% Alert`，其中 90% 为当前使用量
  - 当使用量小于 85% 的时候输出 `Disk-Root 80% OK`，其中 80% 为当前使用量

- 获取当前内存的使用情况：

  - 当使用量大于 90% 的时候输出 `Memory 95% Alert`，其中 95% 为当前使用量
  - 当使用量小于 90% 的时候输出 `Memory 85% OK`，其中 85% 为当前使用量

- 获取当前机器单核心的 1 分钟平均负载

  - 当负载值大于 0.7 的时候输出 `Loadaverage 1.0 Alert`，其中 1.0 为当前平均负载
  - 当负载值小于 0.7 的时候输出 `Loadaverage 0.4 OK`，其中 0.4 为当前平均负载

## 目标

1. 完成的脚本必须放置在 `/home/shiyanlou/getinfo.sh`，并且可执行
2. 脚本需要符合上述规则

脚本运行实例：

```shell
$ /home/shiyanlou/getinfo.sh
Disk-Root 61%  OK
Memory 57.8% OK
Loadaverage 0.47 OK
```

## 解题

```shell
$ cd /home/shiyanlou
$ vi getinfo.sh && sudo chmod 755 getinfo.sh

getinfo.sh内容如下

#!/bin/bash

## 磁盘使用情况
df_per=`df | awk '{if($6=="/") {gsub(/%/,"",$5);print $5}}'`
## 内存占用 -t 汇总 %.nf 代表小数保留n位
mem_per=`free -t | grep "Total" | awk '{printf("%.1f",($3/$2)*100)}'`
## 获取CPU核心数
core_num=`cat /proc/cpuinfo | grep 'processor' | wc -l`
## 负载情况
load_avg=`cat /proc/loadavg | awk '{printf("%.2f",$1/'$core_num')}'`


if [[ $df_per < 85 ]];then
    echo Disk-Root $df_per% OK
else
    echo Disk-Root $df_per% Alert

fi

if [[ $mem_per < 90 ]];then
    echo Memory $mem_per% OK
else
    echo Memory $mem_per% Alert
fi

if [[ $load_avg < 0.7 ]];then
    echo Loadaverage $load_avg OK
else
    echo Loadaverage $load_avg Alert
fi

```

