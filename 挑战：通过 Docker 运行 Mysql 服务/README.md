# 挑战：通过 Docker 运行 Mysql 服务

## 介绍

> 注意：由于挑战环境限制，无法验证挑战结果，大家只需按照要求完成挑战即可，无须提交挑战结果。

在之前的课程中学习了容器和镜像的一些基础知识，这里我们将通过 MySQL 镜像 `registry.cn-hangzhou.aliyuncs.com/louplus-linux/mysql:5.5`（实验楼加速地址，官方地址下载比较慢）去运行一个 MySQL 实例。并在创建实例时通过环境变量指定创建一个数据库 `shiyanlou001`，以及一个 `shiyanlou` 用户，该用户的密码也为 `shiyanlou`。并将该 `shiyanlou` 用户授予数据库 `shiyanlou001` 的所有权限。

挑战完成后，能够通过以下方式连接到运行在容器中的 MySQL 服务：

```bash
mysql -ushiyanlou -pshiyanlou --port 3306 -h 127.0.0.1
```

容器启动时用到的环境变量如下所示：

- `MYSQL_ROOT_PASSWORD` 该变量为 root 超级用户的密码，这里将其设置为 root
- `MYSQL_DATABASE` 该变量用于创建一个新的数据库，数据库名为 shiyanlou001
- `MYSQL_USER`, `MYSQL_PASSWORD` 这两个变量用来创建一个新用户，并指定其密码，该用户将被授予 `MYSQL_DATABASE` 数据库的所有权限

## 目标

1. 创建文件 `/home/shiyanlou/env_file` 用来保存 MySQL 容器启动所需要的所有环境变量。该步骤可以参考 DockerHub 上该镜像的文档 <https://hub.docker.com/r/library/mysql/>
2. 创建脚本 `/home/shiyanlou/test_run`，脚本中执行 Docker 命令，读取 `env_file` 中的环境变量，并创建 MySQL 容器，同时将容器的 3306 端口映射到宿主机的 3306 端口



## 步骤

```bash
$ docker version #确认已安装docker
## 拉取镜像并且重新命名(tag)
$ docker pull registry.cn-hangzhou.aliyuncs.com/louplus-linux/mysql:5.5 mysql 

$ docker images  
REPOSITORY                                              TAG                 IMAGE ID            CREATED             SIZE
mysql                                                   5.5                 c43b4117afc4        7 weeks ago         205MB
registry.cn-hangzhou.aliyuncs.com/louplus-linux/mysql   5.5                 c43b4117afc4        7 weeks ago         205MB


```

参考 <https://hub.docker.com/r/library/mysql/>

> ## Environment Variables 这段中解释
>
> ### `MYSQL_ROOT_PASSWORD`
>
> This variable is mandatory and specifies the password that will be set for the MySQL `root` superuser account. In the above example, it was set to `my-secret-pw`.
>
> ### `MYSQL_DATABASE`
>
> This variable is optional and allows you to specify the name of a database to be created on image startup. If a user/password was supplied (see below) then that user will be granted superuser access ([corresponding to `GRANT ALL`](http://dev.mysql.com/doc/en/adding-users.html)) to this database.
>
> ### `MYSQL_USER`, `MYSQL_PASSWORD`
>
> These variables are optional, used in conjunction to create a new user and to set that user's password. This user will be granted superuser permissions (see above) for the database specified by the `MYSQL_DATABASE` variable. Both variables are required for a user to be created.
>
> Do note that there is no need to use this mechanism to create the root superuser, that user gets created by default with the password specified by the `MYSQL_ROOT_PASSWORD` variable.

编写env_file

```shell
## Mysql初始密码root,在镜像启动时创建数据库shiyanlou001,并且为后面mysql_user/password赋予这GRANT ALL)
-e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=shiyanlou001 -e MYSQL_USER=shiyanlou -e MYSQL_PASSWORD=shiyanlou
```

编写脚本`/home/shiyanlou/test_run`

```shell
#!/bin/bash

docker run -i -d -p 3306:3306 --name mysql `cat /home/shiyanlou/env_file` mysql:5.5
```

```bash
$ bash /home/shiyanlou/test_run
e0357203f582bc2c719432637ca43baf602e05ba9e148ff5b0ffa678470d5c6e
$ docker ps 
CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS              PORTS                    NAMES
e0357203f582        mysql:5.5           "docker-entrypoint.s…"   About a minute ago   Up About a minute   0.0.0.0:3306->3306/tcp   mysql

## 本地登录OK
$ mysql -ushiyanlou -pshiyanlou --port 3306 -h 127.0.0.1  -e "show databases;"           
+--------------------+
| Database           |
+--------------------+
| information_schema |
| shiyanlou001       |
+--------------------+
## 权限OK
$ mysql -ushiyanlou -pshiyanlou --port 3306 -h 127.0.0.1  -e "show grants for shiyanlou;"       
+-----------------------------------------------------------------------+
| Grants for shiyanlou@%                                                |
+-----------------------------------------------------------------------+
| GRANT USAGE ON *.* TO 'shiyanlou'@'%' IDENTIFIED BY PASSWORD <secret> |
| GRANT ALL PRIVILEGES ON `shiyanlou001`.* TO 'shiyanlou'@'%'           |
+-----------------------------------------------------------------------+


```

