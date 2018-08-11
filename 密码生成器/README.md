# 密码生成器

## 介绍

实验楼为每位用户生成的环境中用户名都是 `shiyanlou`，但密码都是随机的。

请为我们实现一个满足要求的随机密码生成器：

1. 生成的密码字符串长度为12位
2. 密码中必须同时包含数字，大小写字母及至少1个特殊字符
3. 只允许使用这些特殊字符：`><+-{}:.&;`

## 目标

1. 请实现一个 bash 脚本，脚本的存放位置 `/home/shiyanlou/genpass.sh`

2. `genpass.sh` 脚本需要满足介绍中描述的三个条件，并且每次执行产生的密码都不相同
3. 不要使用 `mkpasswd` 等 Linux 上现成的密码生成工具
4. 密码生成脚本每次执行都返回一个满足需求的密码

```shell
$ cd /home/shiyanlou
$ ./genpass.sh
2Dsxw9+xS:27
```

## 知识点

1. Linux 随机数生成器
2. Bash 脚本编程基础

## 解题

```shell
#!/bin/bash

i=1;while true
do
    pw=`head -c 700 /dev/urandom | tr -dc a-zA-Z0-9'[:punct:]' \
       | sed -r 's/[^0-9a-zA-Z><+\-\{\}\:.&;]//g' | sed 's/\\\\//g' \
       | cut -c $1-$((i+12))` 
 #   echo r:$pw
   echo $pw | \
        grep -E '[0-9]+' \
       | grep -E '[a-z]+' \
       | grep -E '[A-Z]+' \
       | grep -E '[><\+\-\{\}\&;]+' > /dev/null
   if [ $? -eq 0 ];then
        break
   fi
done
echo $pw

```

