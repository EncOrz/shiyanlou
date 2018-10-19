# 挑战：搭建实验楼持续集成平台

## 介绍

实验楼目前没有使用持续集成，导致每次迭代版本开发完成之后，需要花费很长时间去测试和上线。为了提升开发效率，需要你来为实验楼搭建一个 Jenkins 的持续集成平台。

## 目标

- 安装和配置 Jenkins，管理员账号和密码均设置为 `shiyanlou`
- 创建一个名为 `shiyanlou` 的 Pipeline 来构建和部署实验楼示例网站
- 可通过调用 Jenkins API 来触发 Pipeline 运行 `curl -X POST 'http://shiyanlou:shiyanlou@localhost:8080/job/shiyanlou/build?token=shiyanlou'`

## 提示语

### 运行实验楼示例网站

```
wget http://labfile.oss.aliyuncs.com/courses/980/09/assets/flask-demo.tar.gz
tar zxvf flask-demo.tar.gz
pip3 install flask
cd flask-demo && FLASK_APP=app.py flask run
```

示例网站使用 Python [Flask](http://flask.pocoo.org/) Web 框架编写，请使用 `pip3` 来安装 flask 包，这样安装的 `flask` 命令自然就会使用 Python 3。

示例网站默认在前台运行，这会导致 Pipeline 一直处于运行中而不会结束。请在 Pipeline 里使用如下的 step 来在后台运行示例网站：

```
withEnv(['JENKINS_NODE_COOKIE=dontKillMe']) {
    sh 'cd flask-demo && LC_ALL=C.UTF-8 LANG=C.UTF-8 FLASK_APP=app.py nohup flask run >/dev/null 2>&1 &'
}
```

> 上面的 `LC_ALL` 和 `LANG` 环境变量设置是为了解决实验环境里运行 Flask 应用时 locale 报错问题，如果没有该错误可以去掉。

## 解题

```bash
## 安装 jenkins
$ wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
$ sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
$ java --version  ## 检查java版本，环境里是1.8所以无需安装升级

$ sudo apt-get update
$ sudo apt-get install jenkins -y
$ sudo service jenkins start
## 安装太慢，换用deb安装方式
$ wget http://labfile.oss.aliyuncs.com/courses/980/09/assets/jenkins_2.121.1_all.deb
$ sudo dpkg -i jenkins_2.121.1_all.deb
$ sudo apt-get install daemon
$ sudo service jenkins start
## 进入UI界面 http://localhost:8080
$  cat /var/lib/jenkins/secrets/initialAdminPassword 
# 选安装推荐插件
# 设置用户名和密码shiyanlou
## 新建流水线、命名shiyanlou，点配置-流水线，定义选pipeline-script,script中填入以下：
```

```groovy
pipeline {
    agent any
    stages {
        stage("Build") {
            steps {
                sh 'wget http://labfile.oss.aliyuncs.com/courses/980/09/assets/flask-demo.tar.gz'
                sh 'tar zxvf flask-demo.tar.gz'
            }
        }
        stage('Deploy') {
            steps {
                withEnv(['JENKINS_NODE_COOKIE=dontKillMe']) {
                    sh 'cd flask-demo && LC_ALL=C.UTF-8 LANG=C.UTF-8 FLASK_APP=app.py nohup flask run >/dev/null 2>&1 &'
                }
            }
        }
    }
}
```

**保存即可。根据题目提示中配置允许远程调用**

```bash
curl -X POST 'http://shiyanlou:shiyanlou@localhost:8080/job/shiyanlou/build?token=shiyanlou'
```

**验证，并且在ui界面可以看到执行结果。**