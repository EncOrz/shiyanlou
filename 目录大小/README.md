# 目录大小

## 介绍

实现一个脚本 `newls.sh`，可以获得指定目录下的所有文件及文件夹的大小。输出的样式与 `ls -lh` 命令相同。

命令执行示例，其中和 `ls -lh` 命令输出的唯一区别是目录的大小：

```shell
$ cd /home/shiyanlou
$ ./newls.sh /home/shiyanlou
drwxrwxr-x 3 shiyanlou shiyanlou 180K  4月 12 13:13 Code
drwxrwxr-x 2 shiyanlou shiyanlou  36K  8月 17  2016 Desktop
```

## 目标

1. 实现满足上述需求的脚本，脚本文件路径为 `/home/shiyanlou/newls.sh`
2. 注意输出的格式需要与 `ls -lh` 完全相同

## 知识点

1. Linux 文件操作
2. Linux 文件夹存储信息获取
3. Bash 脚本编程



##解题

```shell
vi ~/newls.sh && sudo chmod 755 ~/newls.sh
```



```shell
#!/bin/bash

##判断路径是否有参数
if [ $# -ne 0 ]
then
	target_n=$1
else
	target_n=$(pwd)
fi	

##获取文件列表
for a in $(ls $target_n )
do
	file_n=$target_n/$a
	if [ -f $file_n ];then
	##文件
		ls -lh  $file_n | awk '{$9="'$a'";print $0}'
	else
	##文件夹，计算总大小
		dir_size=$(du -sh $file_n | awk '{print $1}')
		ls -lhd  $file_n | awk '{$9="'$a'";$5="'$dir_size'";print $0}'	
	fi
done 


```

##关键、注意点

```shell
target_n=$(pwd) #无参数时的处理

du -s -h #s汇总 h人性化单位显示(K M G)
```

