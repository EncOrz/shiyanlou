# 挑战：让实验楼网站恢复访问

## 介绍

小楼这次闯下大祸，不小心把线上的实验楼网站搞挂了。实验楼的网站使用的是 nginx 服务，目前无法启动。

右边给你的是实验楼的服务器，请尝试在最短的时间内让实验楼恢复访问。你所节省的每一分钟，都能挽留上百名实验楼的用户。

**注意**：实验楼网站页面目录为 `/home/shiyanlou/page`。

## 目标

恢复访问的要求如下：

1. nginx 服务处于运行状态
2. 在实验环境中使用 Firefox 浏览器访问本地 `http://localhost` 可以进入实验楼的主页

##步骤

```bash
##首先打开浏览器http://localhost，返回apache2默认页面

##尝试启动nginx服务
$ sudo service nginx start 

##无反映，sudo service nginx status
 * nginx is not running

##查看/etc/nginx/nginx.conf
$ grep 'error_log' /etc/nginx/nginx.conf
	error_log /var/log/nginx/error.log
	
##获得错误日志存放位置后，打开并不存在
$ sudo service rsyslog status		##rsyslog未启动，因此并没产生日志
$ sudo service rsyslog start

##再次尝试启动nginx服务，仍然无法启动，重新打开一个终端，轮询错误日志检查
$ sudo tail -f /var/log/nginx/error.log
2018/08/16 00:47:38 [emerg] 619#0: unexpected "}" in /etc/nginx/sites-enabled/default:36

##按提示检查/etc/nginx/sites-enabled/default的36行位置
```

```nginx
 30         location / {
 31                 # First attempt to serve request as file, then
 32                 # as directory, then fall back to displaying a 404.
 33                 try_files $uri $uri/ =404 
 34                 # Uncomment to enable naxsi on this location
 35                 # include /etc/nginx/naxsi.rules
 36         }

##33行处结尾未加";"，导致36行，无法解析，纠正后保存
##修改完成后校验配置文件
$ sudo nginx -t 
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

```shell
##尝试重启nginx服务仍失败，查看日志，发现80端口被占用，导致无法绑定端口
2018/08/16 00:54:51 [emerg] 678#0: bind() to [::]:80 failed (98: Address already in use)
2018/08/16 00:54:51 [emerg] 678#0: bind() to 0.0.0.0:80 failed (98: Address already in use)
2018/08/16 00:54:51 [emerg] 678#0: bind() to [::]:80 failed (98: Address already in use)
2018/08/16 00:54:51 [emerg] 678#0: still could not bind()

$ sudo netstat -tunlp | grep ":80"
tcp6       0      0 :::80                   :::*                    LISTEN      97/apache2      

##80被apache2占用,杀掉端口并停apache服务
$ sudo service apache2 stop
##如果仍有占用,sudo killall apache2

##此时nginx可以启动，但是网站还无法打开
$ sudo service nginx start && sudo service nginx status  

##核对nginx配置是否正确 /etc/nginx/sites-enabled/default

 20 server {
 21         listen 80 default_server;
 22         listen [::]:80 default_server ipv6only=on;
 23 
 24         root /home/shiyanlou;
 25         index index.html index.htm shiyanlou.htm;
 26 
 27         # Make site accessible from http://localhost/
 28         server_name localhost;

## 24行 root 主目录应该为 /home/shiyanlou/page
## 25行 indx 将 shiyanlou.htm 放在到最前(也可不改)
			index shiyanlou.htm index.html index.htm
			
##修改完成后重新加载配置后，网站访问恢复正常
$ sudo service nginx reload 
```

