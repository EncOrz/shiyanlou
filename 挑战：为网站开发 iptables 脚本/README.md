# 挑战：为网站开发 iptables 脚本

**注意：**由于实验楼的挑战只能够在容器环境运行，而容器环境又不可以执行 iptables，所以这个脚本在挑战的环境中无法运行，只能在实验环境中调试成功后拷贝到当前挑战环境的 `/home/shiyanlou/sec.sh`，再点击提交。同样，由于挑战环境的限制，无法真实运行脚本，会存在检测不完全的地方，请在上一节实验中的 CentOS 7 的环境中测试完善。

## 介绍

需要为我们的服务器开发一个 iptables 脚本，脚本的需求如下：

1. 默认策略 INPUT，OUTPUT 都设置为 DROP
2. 允许所有 IP 地址访问服务器的 80 和 443 端口
3. 允许服务器访问外部的 DNS 53 端口
4. 只允许 192.168.42.1 访问 SSH 端口
5. 只允许 192.168.42.0/24 子网访问 VNC 服务



## 解题

```bash
#!/bin/bash

## 清空现有策略
iptables -F
iptables -X
iptables -Z

## 默认策略 INPUT，OUTPUT 都设置为 DROP
iptables -P   INPUT DROP
iptables -P  OUTPUT DROP

## 允许所有 IP 地址访问服务器的 80 和 443 端口
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

## 允许服务器访问外部的 DNS 53 端口
iptables -A OUTPUT -p tcp -dport 53 -j ACCEPT
iptables -A OUTPUT -p udp -dport 53 -j ACCEPT

## 只允许 192.168.42.1 访问 SSH 端口
iptables -A INPUT -s 192.168.42.1 -p --dport 22 ACCEPT

## 只允许 192.168.42.0/24 子网访问 VNC 服务
iptables -A INPUT -s 192.168.42.0/24 -p --dport 5901 ACCEPT

```

