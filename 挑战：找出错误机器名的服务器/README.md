# 挑战：找出错误机器名的服务器

## 介绍

在实验楼的用户服务集群中，所有的服务器必须按照命名要求修改 Hostname，例如：`docker1.shiyanlou.com`。为了让新同事熟悉添加新节点的流程，有几台服务器是新同事添加的，但是该同事较为粗心，忘记修改 Hostname 了，此时我们希望通过 Ansible 快速获取所有机器的 Hostname，从而定位问题机器的所在。（别忘记 Ansible 的安装）

现在需要大家在左边的实验环境中模拟，操作无误之后我们即可将操作直接移植到线上环境中操作，有这样的一些需求：

1.将本机添加至 Invertory 中，并放置在 `product` 组中，同时使用密钥认证的方式登录（不是密码） 2.通过 setup 模块只获取机器的 hostname 信息 3.将执行的命令写入 `/home/shiyanlou/get_hostname.sh` 脚本中

## 目标

1. 完成的代码必须放在 `/home/shiyanlou/get_hostname.sh` 文件中
2. SSH 免密登录的配置与密钥文件放在 `/home/shiyanlou/.ssh` 文件中
3. 执行实例如下：

```json
shiyanlou:~/ $ bash get_hostname.sh
localhost | SUCCESS => {
    "ansible_facts": {
        "ansible_hostname": "73a5e9280de6"
    }, 
    "changed": false
}
```

## 解题

```shell
## 安装ansible
$ sudo apt-get update
$ sudo apt-get install software-properties-common
## 添加ansible官方源
$ sudo python3.4 /usr/bin/add-apt-repository ppa:ansible/ansible
$ sudo apt-get update && sudo apt-get install ansible -y

## 配置ssh免密登录
## ##生成一对公钥私钥
$ ssh-keygen -t rsa 
$ ll ~/.ssh                                                          [4:21:37]
-rw------- 1 shiyanlou shiyanlou 1.7K  9\u6708 16 03:29 id_rsa
-rw-r--r-- 1 shiyanlou shiyanlou  404  9\u6708 16 03:29 id_rsa.pub
-rw-r--r-- 1 shiyanlou shiyanlou  222  9\u6708 16 03:34 known_hosts
$ cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys ##公钥给服务器端，因为是localhost就直接生成就可以
$ sudo chmod 600 ~/.ssh/authorized_keys ## 设置成只读
$ sudo vi /etc/ssh/sshd_config
## 修改成使用公钥认证
PubkeyAuthentication yes 
$ sudo service ssh restart
## 验证
$ ssh shiyanlou@localhost  ## 无需密码
$ logout
Connection to localhost closed.

## ansible配置

## 添加本机到 Inventory
$ sudo vi /etc/ansible/hosts
## 添加
[product]
localhost ansible_ssh_user=shiyanlou ansible_ssh_private_key_file=/home/shiyanlou/.ssh/id_rsa

## get_hostname.sh脚本通过ad-hoc获取hostname
$ vi ~/get_hostname.sh && sudo chmod ~/get_hostname.sh
#!/bin/bash
ansible product -m setup -a 'filter=ansible_hostname'   ## filter过滤出hostname
$ bash get_hostname.sh
localhost | SUCCESS => {
    "ansible_facts": {
        "ansible_hostname": "a207ad903e53"
    }, 
    "changed": false
}

```

