# 批量创建删除用户和组

## 简介

小楼是一个系统管理员，需要为一个教室中的服务器添加一个老师和若干学生用户，手动添加太麻烦了，请你为他编写一个bash脚本 `userctr.sh` 实现批量添加和删除用户。老师用户名，学生用户名和学生数量使用参数进行控制。

`userctr.sh` 脚本执行时候包括四个参数：

```shell
bash userctr.sh 操作（add或者del）教师名 学生名前缀 学生数量
```

脚本成功执行后将创建1个教师用户和若干个学生用户，满足下列条件：

1. 学生数量参数，参数范围为1~10，若超过10或不为正整数，则报错打印 `parameter error`
2. 学生名前缀为字符串，只允许包含小写字母，否则报错打印 `parameter error`，前缀后面跟数字序列
3. 每个用户默认使用 `zsh`，教师用户默认具备 sudo 权限
4. 每个用户设置一个随机6位数字密码，在添加命令执行后并将用户名和对应的密码输出
5. 如果某个用户名已经存在，则默认不需要创建该用户，输出时密码显示为6个星号

执行脚本的范例：

```shell
# 添加一个 teacher 用户和 stu1 到 stu6 6个学生用户
$ bash userctr.sh add teacher stu 6
teacher:901231
stu1:271828
stu2:928172
stu3:******
stu4:384712
stu5:098273
stu6:921098

# 删除一个 teacher 用户和 stu1 到 stu6 6个学生用户
$ bash test.sh del teacher stu 6
```

其中 stu3 六个星号代表这个用户先前已经被创建了，所以该命令执行的时候并不清楚该用户的密码。删除命令执行时如果某个用户不存在也不需要报错，直接执行删除其他用户。

## 目标

1. 脚本存放的路径必须在 `home/shiyanlou/userctr.sh`
2. 脚本执行需要满足上述需求
3. 参数不符合要求需要直接在屏幕打印 `parameter error`

## 提示语

- usermod
- chpasswd
- md5sum

## 解题

`vim userctr.sh && chmod 755 userctr.sh`

```shell
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

###exit
###1：参数数量不对
###2：不识别的功能 add|del
###3：数字不对[1-10]
###4：必须为正整数
```

## 关键、注意点

```shell
$(echo $RANDOM | cksum | cut -c 2-7) ##随机获取6位数字
echo $student_n$i:$pw | chpasswd &> /dev/null ##Ubuntu中用chpasswd username:password 代替 passwd --stdin
grep "^$teacher_n:" /etc/passwd &> /dev/null ##判断是否有用户
$？##上一个命令执行后的退出状态 0代表成功
seq 1 10 ##生成1-10的正整数
if [ $4=~^[0-9]*$ ] ##正则判断参数4是否为整数，~ 代表匹配正则模式
```

