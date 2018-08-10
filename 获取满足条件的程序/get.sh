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