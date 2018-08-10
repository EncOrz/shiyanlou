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