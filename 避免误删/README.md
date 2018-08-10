# 避免误删

## 介绍

`rm -rf` 很恐怖的操作。在实验环境中无所谓，大不了停止实验再开始一次。但如果在自己的 Linux 服务器上不小心执行了这个操作那必须十分慎重。

为了避免误删除一些重要的文件，需要通过一些设置来实现回收站的功能：

1. `rm -f` 命令删除的文件或文件夹都临时存入 `/tmp/trash` 文件夹，而不删除，例如使用 `rm -f /home/shiyanlou/testfile` 后，文件 `testfile` 会被移动到 `/tmp/trash/testfile`，如果 `/tmp/trash` 目录下已经有 `testfile`重名文件则直接覆盖老的文件。
2. `rm` 命令不加 `-f` 参数的时候执行流程不变，不需要移动到 `/tmp/trash` 文件夹。

## 目标

1. 改变系统自带的 `rm` 命令的 `-f` 参数所表现的行为，将被删除的目标存入 `/tmp/trash` 中
2. 注意 `rm` 命令不含 `-f` 参数的时候行为不变
3. 注意修改后的 `rm -f` 命令需要对 `所有用户` 都有效

## 知识点

1. Linux 文件操作
2. Shell 参数处理

## 解题

```shell
which rm ##获得rm真实路径/bin/rm
sudo vi /etc/profile ##编辑全局shell配置，尾行添加
	alias rm='bash /usr/bin/newrm.sh'
source /etc/profile ##重新加载生效
mkdir /tmp/trash
sudo vi /usr/bin/newrm.sh && sudo chmod 766 /usr/bin/newrm.sh
```

```shell
#!/bin/bash

if [ $# -ne 0 ];then
        echo $* | grep -E '\-f|\-rf|\-fr' &> /dev/null
        if [ $? == 0 ];then
                for v in $*
				do
                        if [[ ! $v =~ '-' ]]
						then
                                mv -f $v /tmp/trash/
                        fi
                done
        else
                /bin/rm $*
        fi
else
        /bin/rm
fi

```

