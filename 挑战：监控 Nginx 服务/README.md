# 挑战：监控 Nginx 服务

## 介绍

本次挑战我们将运用前面学习的 Prometheus 知识来完成对 Nginx 服务的监控。

## 目标

通过 Prometheus 的 API 能够获取到 Nginx 服务的度量指标。

```shell
$ curl 'http://localhost:9090/api/v1/query?query=nginx_http_requests_total'
{"status":"success","data":{"resultType":"vector","result":[{"metric":{"__name__":"nginx_http_requests_total","host":"localhost","instance":"localhost:9145","job":"nginx","status":"200"},"value":[1525851831.374,"137"]}]}}
```

## 提示语

在 Nginx 服务里加载导出器来提供 Prometheus 度量指标服务端点，然后配置 Prometheus Server 从该服务端点抓取度量指标。导出器请使用这个 [nginx-lua-prometheus](https://github.com/knyar/nginx-lua-prometheus)。

### 安装支持运行 Lua 脚本的 Nginx

因为导出器是使用 Lua 编写的，需要 Nginx 支持运行 Lua 脚本。大部分发行版里默认安装的 Nginx 都不支持，需要自己编译安装。编译的时候需要指定编译模块 `nginx-lua`。Nginx 源码可以从 [官网](http://nginx.org/en/download.html) 下载，也可以从实验楼下载 [nginx-1.14.0.tar.gz](http://labfile.oss.aliyuncs.com/courses/980/05/assets/nginx-1.14.0.tar.gz)。

可通过 `nginx -V` 命令来查看编译参数，如果输出里包含 nginx-lua 字样则证明支持。

```shell
$ nginx -V | grep lua
.....
	--add-module=/build/nginx-pxKPPR/nginx-1.4.6/debian/modules/nginx-lua --
.....
```

Ubuntu 系统可以安装 `nginx-extras` 包，这个版本的 Nginx 带有许多额外功能，包括运行 Lua 脚本。

```shell
$ sudo apt install nginx-extras
```

### 配置 Nginx 加载导出器

参照导出器官方文档来配置 Nginx，注意 Lua 相关配置需要放在 `http` 配置块下。

### 配置 Prometheus 抓取 Nginx 度量指标

在 Prometheus 的配置里添加一个 job 来抓取 Nginx 度量指标。Prometheus Server 需要在默认的 9090 端口监听，以便检查结果。



## 步骤

```shell
$ nginx -V | grep lua

.....
	--add-module=/build/nginx-pxKPPR/nginx-1.4.6/debian/modules/nginx-lua --
.....

##说明现有Nginx服务支持lua
```

**二进制安装方式安装prometheus**

```shell
wget http://labfile.oss.aliyuncs.com/courses/980/05/assets/prometheus-2.2.1.linux-amd64.tar.gz
##解压
tar xvfz prometheus-2.2.1.linux-amd64.tar.gz
```

下载nginx导出器[nginx-lua-prometheus](https://github.com/knyar/nginx-lua-prometheus)

```shell
##我是用git直接克隆了仓库
$ cd ~
$ git clone https://github.com/knyar/nginx-lua-prometheus
$ ls -l ~/nginx-lua-prometheus
##看到了prometheus.lua文件
-rw-rw-r-- 1 shiyanlou shiyanlou 271  8\u6708 22 13:05 dist.ini
-rw-rw-r-- 1 shiyanlou shiyanlou 535  8\u6708 22 13:05 nginx-lua-prometheus-0.20171117-4.rockspec
-rw-rw-r-- 1 shiyanlou shiyanlou 18K  8\u6708 22 13:05 prometheus.lua
-rw-rw-r-- 1 shiyanlou shiyanlou 14K  8\u6708 22 13:05 prometheus_test.lua
-rw-rw-r-- 1 shiyanlou shiyanlou 11K  8\u6708 22 13:05 README.md

##或者直接直接(不确定，没试过)
wget https://raw.githubusercontent.com/knyar/nginx-lua-prometheus/master/prometheus.lua


```

**以下都是参考 https://github.com/knyar/nginx-lua-prometheus 配置**

修改nginx.conf

```nginx
$ sudo vi /etc/nginx/nginx.conf

##在http配置中添加
在http{
    .....
  		##
  		#Promethous
      	##
        lua_shared_dict prometheus_metrics 10M;
        ##此处改成当前环境prometheus.lua实际路径
        ##lua_package_path "/path/to/nginx-lua-prometheus/?.lua"; 
          lua_package_path "/home/shiyanlou/nginx-lua-prometheus/?.lua"; 
        init_by_lua '
          prometheus = require("prometheus").init("prometheus_metrics")
          metric_requests = prometheus:counter(
            "nginx_http_requests_total", "Number of HTTP requests", {"host", "status"})
          metric_latency = prometheus:histogram(
            "nginx_http_request_duration_seconds", "HTTP request latency", {"host"})
          metric_connections = prometheus:gauge(
            "nginx_http_connections", "Number of HTTP connections", {"state"})
        ';
        log_by_lua '
          metric_requests:inc(1, {ngx.var.server_name, ngx.var.status})
          metric_latency:observe(tonumber(ngx.var.request_time), {ngx.var.server_name})
        ';
        
    .....
    
}
```

**修改nginx网站全局配置**

```shell
$ vi /etc/nginx/sites-available/default
```

```shell
##添加server配置

server {
  listen 9145;
  ##allow 192.168.0.0/16;  实际情况修改
  ##deny all;				实际情况修改
  location /metrics {
    content_by_lua '
      metric_connections:set(ngx.var.connections_reading, {"reading"})
      metric_connections:set(ngx.var.connections_waiting, {"waiting"})
      metric_connections:set(ngx.var.connections_writing, {"writing"})
      prometheus:collect()
    ';
  }
}
```

**Nginx配置部分完成后`nginx -t`校验配置是否正确**

```shell
$ sudo nginx -t 
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful

##nginx重新加载配置
$ sudo service nginx reload
```

> 浏览器打开输入 http://localhost:9145/metrics 能正常返回信息，说明已开放其内部的各项度量指标
>

**配置Prometheus**

```yaml
##进入目录
$ cd ~/prometheus-2.2.1.linux-amd64
$ vi prometheus.yml
```

编辑prometheus配置文件(YAML格式，**注意空格和进位**，参照上面已有的配置来写)
在21行`scrape_configs:` 之后开始添加

```YAML

scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ['localhost:9090']
      
##添加内容      
  - job_name: 'nginx'
    scheme: http   				##默认项可不填，上面有说明
    metrics_path: /metrics		##默认项可不填，上面有说明
    static_configs:
      - targets: ['localhost:9145']
                                    
```

启动**Prometheus Server**在所在目录中`./prometheus`

```shell
$ ./prometheus &
##验证没问题后，命令后加 "&" 让它保持后台运行
```

成功启动后，可通过浏览器 http://localhost:9090，在查询栏中，`nginx_http_requests_total`验证

或者`curl`命令看返回信息

```shell
$ curl 'http://localhost:9090/api/v1/query?query=nginx_http_requests_total'
{"status":"success","data":{"resultType":"vector","result":[{"metric":{"__name__":"nginx_http_requests_total","host":"localhost","instance":"localhost:9145","job":"nginx","status":"200"},"value":[1525851831.374,"137"]}]}}
```

