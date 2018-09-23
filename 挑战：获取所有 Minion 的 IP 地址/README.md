# 挑战：获取所有 Minion 的 IP 地址

## 介绍

Saltstack 的 minon 都是通过配置文件中 master 的地址来主动与 master 建立链接，而 master 中只需要接收密钥链接即可，现在我们想统计一下当前还处于连接状态的机器还有哪些 IP 地址。（别忘记 Saltstack 的安装）

## 目标

1. 将执行的命令写入 `/home/shiyanlou/get_ip.sh` 脚本中
2. 脚本执行事例：

```bash
shiyanlou:~/ $ ./get_ip.sh
f48f077752dd:
    192.168.42.7
```

## 步骤

```bash
## 配置源
$ wget -O - https://repo.saltstack.com/apt/ubuntu/14.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
$ sudo vim /etc/apt/sources.list.d/saltstack.list
deb http://repo.saltstack.com/apt/ubuntu/14.04/amd64/latest trusty main

## 安装salt-master和salt-minion
$ sudo apt-get update && sudo apt-get install -y salt-master salt-minion

## 配置master，修改/etc/salt/master
$ sudo grep -vE '^#|^$' /etc/salt/master                           [19:50:10]
interface: 127.0.0.1
user: root
auto_accept: False   ## 如果这里加了，下面就要手动接收密钥，因为minion 都是通过配置文件中 master 的地址来主动与 master 建立链接，而 master 中只需要接收密钥链接即可

## 配置minion，修改/etc/salt/master
$ sudo grep -vE '^#|^$' /etc/salt/minion                           [19:53:17]
master: 127.0.0.1

## 启动服务
$  sudo service salt-master start
$  sudo service salt-minion start

## 如果master配置的是auto_accept: False，需要接收密钥
$  sudo salt-key -A
The following keys are going to be accepted:
Unaccepted Keys:
e7e04f912cc6
Proceed? [n/Y] y
Key for minion e7e04f912cc6 accepted.

## 测试连通
	# master端
$ sudo salt '*' test.ping
e7e04f912cc6:
    True
	# minion端
$ sudo salt-call test.ping                                         [20:04:47]
local:
    True
    
## 获取minion所有信息
$ sudo salt '*' grains.items
......
    ip4_interfaces:
        ----------
        eth0:
            - 192.168.42.5
        lo:
            - 127.0.0.1
    ip_interfaces:
        --------
        eth0:
            - 192.168.42.5
            - fe80::42:c0ff:fea8:2a05
        lo:
            - 127.0.0.1
            - ::1
    ipv4:							## 其中ipv4项，是最符合题目要求的
        - 127.0.0.1
        - 192.168.42.5
    ipv6:
        - ::1
        - fe80::42:c0ff:fea8:2a05
.....

##grins中ipv4可以获得ip,grains.item返回键值对，grains.get返回值
$ sudo salt '*' grains.get ipv4                                    [20:05:18]
e7e04f912cc6:
    - 127.0.0.1
    - 192.168.42.5

## 按题目要求将命令保存到/home/shiyanlou/get_ip.sh
$ vi /home/shiyanlou/get_ip.sh && sudo chmod 755 /home/shiyanlou/get_ip.sh
#!/bin/bash
   sudo salt '*' grains.get ipv4   
```

