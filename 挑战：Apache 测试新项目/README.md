#挑战：测试新项目

##介绍

实验楼准备替换新的监控组件，而新的监控组件使用 PHP 写的，官方也推荐使用 Apache 来做 web，我们准备在我们的测试服务器上做一个测试，而原有的 80 端口有项目在使用，我们只能使用 8080 端口，为了做好相关的环境准备所以有这样的需求：

1. 能够通过浏览器访问 8080 端口展示的页面
2. 新项目的配置分别在 test1.conf 与 test2.conf 的配置文件中，不能与默认配置文件混杂
3. 页面的内容分别是：
   - 8080 端口：页面的主目录为 /home/shiyanlou/test1，默认展示页面内容为 “Hello,this is first”，ServerName 为 ops1.shiyanlou.com
   - 8080 端口：页面的主目录为 /home/shiyanlou/test2，默认展示页面内容为 “Hello,this is second"，ServerName 为 ops2.shiyanlou.com

##目标

完成 Apache 的相关配置
创建相关的项目目录，是默认展示内容达到以上要求

##步骤

```bash
##创建主目录test1、test2
sudo mkdir /home/shiyanlou/test1 /home/shiyanlou/test2

##分别创建index.html
echo  “Hello,this is first” | tee /home/shiyanlou/test1/index.html
echo  “Hello,this is second” | tee /home/shiyanlou/test1/index.html

##设置端口8080
sudo vi /etc/apache2/apache2.conf
##添加
Listen 8080

##修改hosts
sudo vi /etc/hosts
##添加两行
127.0.0.1 ops1.shiyanlou.com
127.0.0.1 ops2.shiyanlou.com

```

```shell
##在/etc/apache2/sites-available/下，新建 test1.conf 和test2.conf(参考000-default.conf)
##test1.conf
<VirtualHost *:8080>
    ServerName ops1.shiyanlou.com
    DocumentRoot /home/shiyanlou/test1
</VirtualHost>

<Directory /home/shiyanlou/test1>
         AllowOverride None
         Require all granted
</Directory>

##test2.conf
<VirtualHost *:8080>
    ServerName ops2.shiyanlou.com
    DocumentRoot /home/shiyanlou/test2
</VirtualHost>

<Directory /home/shiyanlou/test2>
         AllowOverride None
         Require all granted
</Directory>

```

```bash
##在创建新的配置文件需要创建一个软连接到 sites-enable 中，Apache 才会读取相关的配置文件
sudo a2ensite test1.conf
sudo a2ensite test2.conf

##重启服务，如果服务已启动，重新装载配置
sudo service apache2 status 
sudo service apache2 start 或 sudo service apache2 reload
```

