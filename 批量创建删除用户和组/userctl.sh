#!/bin/bash

if [ $# == 4 ]
then
        cmd_ctr=$1
        pass_ran=$(echo $RANDOM | cksum | cut -c 2-7)
        if [ $4=~^[0-9]*$ ];then
                if [ $4 -gt 0 -a $4 -lt 11 ];then
                        teacher_n=$2
                        student_n=$3
                        if [ $cmd_ctr == "add" ];then
                                ##添加teacher##
                                grep "^$teacher_n:" /etc/passwd &> /dev/null 
                                if [ $? -ne 0 ];then
                                        pw=$pass_ran
                                        useradd $teacher_n ; usermod -a -G wheel $teacher_n
                                        ##实验楼环境：sudo组
                                        echo $pw | passwd --stdin $teacher_n &> /dev/null
                                        ##Ubuntu --stdin没有 chpasswd代替
                                        ##echo $teacher:$pw | chpasswd &> /dev/null
                                        echo $teacher_n:$pw
                                else
                                        echo $teacher_n:******
                                fi
                                ##添加student##
                                for i in $(seq 1 $4)
                                do
                                     grep "^$student_n$i:" /etc/passwd &> /dev/null
                                                if [ $? -ne 0 ];then
                                                        pw=$(echo $RANDOM | cksum | cut -c 2-7)
                                                        useradd $student_n$i -s /bin/zsh
                                                        echo $pw | passwd --stdin $student_n$i &> /dev/null
											##Ubuntu --stdin没有 chpasswd代替
                                        	##echo $student_n$i:$pw | chpasswd &> /dev/null
                                                        echo $student_n$i:$pw
                                                else
                                                        echo $student_n$i:******
                                                fi
                                done

                        else
                                if [ $cmd_ctr == "del" ];then
                                ##删除teacher用户
                                        userdel -r $teacher_n
                                ##删除student用户
                                        for i in $(seq 1 $4)
                                        do
                                                userdel -r $student_n$i
                                        done
                                else
                                        echo parameter error
                                        exit 2
                                fi
                        fi
                        else 
                                echo pararmeter error
                                exit 3
                fi
        else
                echo pararmeter error
                exit 4
        fi
else
        echo parameter error
        exit 1
fi