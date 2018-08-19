# 挑战：模块拆分，请求分发

## 介绍

因为实验楼的量级越来越大，我们将重服务的模块拆分出来，分别运行在单独的机器当中，同时每个单独的服务都做了冗余来实现高可用，当前我们的结构是：

- HA 搭建节点 IP：115.29.233.149
  - 访问 `www.shiyanlou.com` 服务的节点 IP：10.3.1.5
  - 访问 `www.shiyanlou.com`服务的节点 IP：10.3.1.6
  - 访问 `api.shiyanlou.com` 服务的节点 IP：10.210.23.129
  - 访问 `api.shiyanlou.com` 服务的节点 IP：10.230.55.143
  - 访问 `static.shiyanlou.com` 服务的节点 IP：10.123.121.54
  - 访问 `static.shiyanlou.com` 服务的节点 IP：10.167.112.52

## 目标

1. 完成的配置必须放置在 `/etc/haproxy/haproxy.cfg`
2. 创建三个 backend 分别为：`www、api、static`
3. 不符合这样三个域名规则的请求返回 403 状态码

## 步骤

```shell
##安装HAProxy
sudo apt-get update && sudo apt-get install haproxy -y
```



```shell
##编辑配置文件
sudo vi /etc/haproxy/haproxy.cfg

##如下

global
	log /dev/log	local0
	log /dev/log	local1 notice
	chroot /var/lib/haproxy
	user haproxy
	group haproxy
	daemon

defaults
log	global
mode http
    option	httplog
    option	dontlognull
    contimeout 5000
    clitimeout 50000
    srvtimeout 50000
    errorfile 403 /etc/haproxy/errors/403.http

frontend shiyanlou
    bind 115.29.233.149:80
    mode http
    option httplog
    option forwardfor
    option httpclose
    log global
    ##配置acl规则
    acl server_www hdr_reg(host) -i ^(www)
    acl server_api hdr_reg(host) -i ^(api)
    acl server_static hdr_reg(host) -i ^(static)
    acl allow_reg hdr_reg(host) -i ^(www|api|static)
    ##应用acl规则
    use_backend www if server_www
    use_backend api if server_api
    use_backend static if server_static
    http-request deny if !allow_reg
    default_backend www

backend www
    mode http
    balance source
    server nginx-www-1  10.3.1.5:80 weight 1 check inter 2000 rise 3 fall 3
    server nginx-www-2  10.3.1.6:80 weight 1 check inter 2000 rise 3 fall 3 backup

backend api
    mode http
    balance source
    server nginx-api-1  10.210.23.129:80 weight 1 check inter 2000 rise 3 fall 3
    server nginx-api-2  10.230.55.143:80 weight 1 check inter 2000 rise 3 fall 3 backup

backend static
    mode http
    balance source
    server nginx-static-1  10.123.121.54:80 weight 1 check inter 2000 rise 3 fall 3
    server nginx-static-2  10.167.112.52:80 weight 1 check inter 2000 rise 3 fall 3 backup

##以下可不用
listen HAProxy_status    
    bind 0.0.0.0:3000 
    stats uri /haproxy-status 
    stats refresh 30s 
    stats realm welcome \login HAProxy 
    stats auth admin:admin    
    stats hide-version    
    stats admin if TRUE 

```

```shell
##配置完成后校验配置文件
$ sudo haproxy -c -f /etc/haproxy/haproxy.cfg
Configuration file is valid

##开启日志服务
$ sudo service rsyslog start
 * Starting enhanced syslogd rsyslogd                [ OK ]
##开始服务
$ sudo haproxy -d -f /etc/haproxy/haproxy.cfg
Available polling systems :
     sepoll : pref=400,  test result OK
      epoll : pref=300,  test result OK
       poll : pref=200,  test result OK
     select : pref=150,  test result FAILED
Total: 4 (3 usable), will use sepoll.
Using sepoll() as the polling mechanism.
[ALERT] 231/002103 (1044) : Starting frontend shiyanlou: cannot bind socket ##实验环境因此无法绑定，忽略

```

