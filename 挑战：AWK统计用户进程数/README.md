# 挑战：AWK 统计用户进程数

## 介绍

你是实验楼的服务器管理员，需要统计每天运行的进程数与不同用户启动的进程数量。以防止被外来人员创建陌生账户，启动恶意进程。所以我们需要一个简单的统计当前启动了进程的用户以及进程数的 AWK 脚本。

希望输出一列为统计数，一类为用户名的内容，例如：

```shell
$ ps -ef | awk -f count_process.awk
COUNT    USER
   85    root
    6    shiyanl+
    1    systemd+
    1    syslog
    1    message+
    1    daemon
```

## 目标

1. 脚本路径为 `/home/shiyanlou/count_process.awk`
2. 统计时需要排除 ps 命令输出的第一行表头记录
3. COUNT 列宽度为5，右对齐，USER 列左对齐
4. 按用户进程数倒序

## 提示语

1. 通过 ps 命令来获取进程信息
2. 通过 NR 变量来排除第一行
3. 使用数组来统计每个用户的进程数
4. 在 END 里将统计结果通过管道传递给 sort 命令来排序

##解题

```bash
$ vi count_process.awk
```

```shell
BEGIN{ printf "%5s %-s\n","COUNT","USER"} 
	{if(NR>1) user[$1]++}     
END {for( u in user) printf "%5s %-s\n",user[u],u | "sort -r -n -k 1"}

##BEGIN 首行格式输出 printf %s 代表变量 %5s:5 代表5个宽幅 %-s:- 代表左对齐
##NR行号 >1 才累加 user存放key:用户名，value:次数 
##END 结束执行 for循环将之前的user集合以 value,key 形式显示
## | sort 最后管道符给系统的sort命令进行排序
```

```bash
$ ps -ef | awk -f count_process.awk ##验证
```

