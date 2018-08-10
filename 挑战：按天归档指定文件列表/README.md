# 挑战：按天归档指定文件列表

## 介绍

不管你负责的是商业环境的还是家用环境的 Linux 系统，丢失数据都是一场灾难。为了防止这种倒霉事，最好是定时进行归档。

我们希望实现一个 Bash 脚本 `daily_archive.sh`来按天归档指定的文件，要归档的文件列表保存在 `files-to-backup.txt` 文件里，归档后的文件名类似 `archive-20180416.tar.gz`，其中“20180416”为归档当天的日期。注意，`files-to-backup.txt` 文件需要自己创建并写入需要打包的文件列表。

## 目标

1. 归档脚本、保存文件列表的文件和归档文件都必须放在 `/home/shiyanlou` 目录下
2. 归档文件列表中的文件可为任意有可读权限的文件或目录，使用绝对路径，一行一个
3. 要归档的文件和目录必须是已经存在的，否则无法通过结果检查

## 提示语

1. 使用 `date` 命令来生成日期字符串
2. 从 `files-to-backup.txt` 文件里按行读取并检查要归档的文件或目录是否存在，如果存在则追加到一个文件列表字符串里
3. 使用 `tar` 命令来依次打包文件列表字符串里的所有文件

## 知识点

- `date` 命令用法
- 按行读取文件内容
- `tar` 命令用法

 

```shell
##写归档文件列表
$ vi files-to-backup.txt
/home/shiyanlou/Desktop/brackets.desktop
/home/shiyanlou/Desktop/firefox.desktop
/home/shiyanlou/Desktop/gedit.desktop
/home/shiyanlou/Desktop/gvim.desktop
/home/shiyanlou/Desktop/idle-python3.5.desktop
/home/shiyanlou/Desktop/sublime.desktop
/home/shiyanlou/Desktop/xfce4-terminal.desktop

##创建daily-archive.sh
vi daily-archive.sh $$ chmod 755 daily-archive.sh
```

```shell
#!/bin/bash

f_list=$(grep -v '^$' /home/shiyanlou/files-to-backup.txt)  

arc_list=
for f in $f_list
do
    if [ -e $f ]
    then
        arc_list="$arc_list $f"
    fi
done

tar -czvf /home/shiyanlou/archive-$(date +'%Y%m%d').tar.gz $arc_list

##[-e $f] 判断文件是否存在
```

