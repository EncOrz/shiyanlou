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