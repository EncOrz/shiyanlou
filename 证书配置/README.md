# 证书配置

## 介绍

实验楼对实验服务器集群进行管理的时候会选择使用证书进行 SSH 登陆，而不使用用户名及密码。

请为 shiyanlou 用户配置一个 SSH 证书，使 shiyanlou 用户 SSH 登陆本地实验环境的时候不需要输入密码。同时设置 SSH 服务禁止所有用户使用密码登陆。

最终实现的操作效果如下：

```shell
# 不需要密码登陆本地 localhost
$ ssh shiyanlou@localhost

# 直接登陆进入一个新的 Shell
```

## 目标

1. 为 shiyanlou 用户配置所需的免密码登陆证书
2. 所有用户都不能够使用密码登陆，只可以使用证书登陆SSH
3. 注意不要忘记 SSH 配置后需要重启 SSH 服务

## 知识点

1. Linux SSH 服务配置
2. 公私钥证书操作

## 解题

```shell
$ ssh-keygen -t rsa ##生成一对公钥私钥
$ ls -la ~/.ssh/ ##id_rsa,id_rsa.pub
$ cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys ##公钥给服务器端，远程用scp shiyanlou@host:~/ 再操作，localhost就直接生成就可以
$ sudo chmod 600 ~/.ssh/authorized_keys
$ sudo vi /etc/ssh/sshd_config

##使用公钥认证
PubkeyAuthentication yes 
##禁用密码方式认证
PasswordAuthentication no

$ sudo service ssh restart ##重启ssh服务生效

```

