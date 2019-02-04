# 挑战：通过 Docker 来运行实验楼网站

## 介绍

> 注意：由于挑战环境限制，无法验证挑战结果，大家只需按照要求完成挑战即可，无须提交挑战结果。

本次挑战我们将运用前面学到的知识来运行实验楼网站，支撑网站的服务包括一个 Python Flask Web 应用和 Nginx 网关。所有外部流量通过 Nginx 网关转发给后端的 Web 应用，网关容器需要配置端口映射使得其可以被外部访问到。

## 目标

在宿主机上运行如下命令能得到正确结果（`shiyanlou.com` 域名请配置 Host 到本地）：

```bash
$ curl http://shiyanlou.com:8080/
Welcome to Shiyanlou!
```

Web 应用代码文件 `app.py` 如下：

```python
from flask import Flask

app = Flask(__name__)


@app.route('/')
def index():
    return 'Welcome to Shiyanlou!'
```

构建 Web 应用镜像的 Dockerfile 如下（Dockerfile 在后面的实验中会细讲）：

```dockerfile
FROM python:3

COPY app.py .

RUN pip install flask

ENV FLASK_APP=app.py
CMD [ "flask", "run", "-h", "0.0.0.0", "-p", "5000" ]
```

## 提示

1. 新建一个目录 `challenge`，在其下放置 Dockerfile 并构建 Web 应用镜像 `shiyanlou`。
2. 创建一个 `bridge` 类型的网络 `shiyanlou`。
3. 使用镜像 `shiyanlou` 启动一个容器 `shiyanlou` 来提供应用服务，并加入到网络 `shiyanlou`。
4. 使用镜像 `registry.cn-hangzhou.aliyuncs.com/louplus-linux/nginx:1.9.1` 启动一个容器 `nginx` 来提供网关服务，并加入到网络 `shiyanlou`。另外还需配置网关代理应用服务，配置端口映射使得在宿主机上通过地址 `http://shiyanlou.com:8080/` 能访问到网关代理的应用服务。

> 构建镜像时会发送 Dockerfile 所在目录的所有文件给 Docker 服务，因此避免在 HOME 这样的包含大量文件的目录下构建，而是创建一个新的目录来在其下构建。



## 解题

```bash
## 创建项目目录challenge
mkdir ~/challenge && cd ~/challenge

## 创建Flask web应用文件
vi app.py 

from flask import Flask

app = Flask(__name__)


@app.route('/')
def index():
    return 'Welcome to Shiyanlou!'


## 构建Dockerfile，之后用来创建shiyanlou镜像
vi Dockerfile

```
```dockerfile
FROM python:3

COPY app.py .

RUN pip install flask

ENV FLASK_APP=app.py
CMD [ "flask", "run", "-h", "0.0.0.0", "-p", "5000" ]
```
```bash
## 创建一个 bridge 类型的网络 shiyanlou
$ docker network create shiyanlou
af4a1b66e6c76f492f2054dbdf2a226c252454507561f3ae60c2ec459724303a

$ docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
34aa41b0a4ac        bridge              bridge              local
04dcaff0d5a4        host                host                local
4ce7c23db6fc        none                null                local
af4a1b66e6c7        shiyanlou           bridge              local    <<---刚创建的shiyanlou

## 用Dockerfile构建镜像shiyanlou
docker build -t shiyanlou .

## 拉取nginx镜像，提供网关代理服务
docker pull registry.cn-hangzhou.aliyuncs.com/louplus-linux/nginx:1.9.1

## 查看镜像
$ docker images
REPOSITORY                                              TAG                 IMAGE ID            CREATED             SIZE
shiyanlou                                               latest              891cc099b7d3        5 minutes ago       933MB
python                                                  3                   a187104266fb        6 days ago          923MB
ubuntu                                                  latest              c69811d4e993        14 months ago       188MB
registry.cn-hangzhou.aliyuncs.com/louplus-linux/nginx   1.9.1               94ec7e53edfc        3 years ago         133MB

## 使用镜像 shiyanlou 启动一个容器 shiyanlou 来提供应用服务，并加入到网络 shiyanlou。
$ docker run -d --name shiyanlou --network shiyanlou shiyanlou
17d96cabe5174e77f018b6fdf92ec95ccfe5e7d07627fd6d8b475eebae549f08


## 配置nginx，用定义好的shiyanlou.conf 替换默认
vi shiyanlou.conf
```
```nginx
server {
	listen 80;
	server_name shiyanlou.com;

	location / {
		proxy_pass http://shiyanlou:5000;
	}
}
```
```bash
## 启动容器
$ docker run -d --name nginx --network shiyanlou -v /home/shiyanlou/challenge/shiyanlou.conf:/etc/nginx/conf.d/shiyanlou.conf -p 8080:80 registry.cn-hangzhou.aliyuncs.com/louplus-linux/nginx:1.9.1
534c5f17485c083345ef334aec0a784f42fdf940f8535212056bbf865ad25e09


## 检查目前启动的容器（如发现容器没有启动，用docker logs [容器name或id]检查）
$ docker ps
CONTAINER ID        IMAGE                                                         COMMAND                  CREATED             STATUS              PORTS                           NAMES
534c5f17485c        registry.cn-hangzhou.aliyuncs.com/louplus-linux/nginx:1.9.1   "nginx -g 'daemon ..."   3 seconds ago       Up 2 seconds        443/tcp, 0.0.0.0:8080->80/tcp   nginx
17d96cabe517        shiyanlou                                                     "flask run -h 0.0...."   6 minutes ago       Up 6 minutes                                        shiyanlou

## 为了实现挑战要求，添加shiyanlou.com到本地的映射
$ sudo vi /etc/hosts
127.0.0.1 shiyanlou.com

$ curl http://shiyanlou.com:8080
Welcome to Shiyanlou!

```

