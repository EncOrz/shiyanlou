# 挑战：打包 Python 应用

## 介绍

> 注意：由于挑战环境限制，无法验证挑战结果，大家只需按照要求完成挑战即可，无须提交挑战结果。

本次挑战将使用 Jenkins 来打包一个简单的 Python 计算器应用。应用代码下载地址 [jenkins-python-app](http://labfile.oss.aliyuncs.com/courses/980/09/assets/jenkins-python-app.tar.gz)。

打包出来的可执行程序在 Linux 下的运行效果如下：

```bash
shiyanlou:~/ $ ./add2vals                                                       

You entered 0 value/s.

Usage: 'add2vals X Y' where X and Y are individual values.
       If add2vals is not in your path, usage is './add2vals X Y'.
       If unbundled, usage is 'python add2vals.py X Y'.

shiyanlou:~/ $ ./add2vals hello 2                                               

The result is hello2

shiyanlou:~/ $ ./add2vals 1 2                                                 

The result is 3

```

## 目标

- 创建一个 Jenkins Pipeline，Pipeline 里需包含构建（Build）、测试（Test）和分发（Delivery）三个 stage
- 为了避免 Pipeline 对节点运行环境的依赖，请使用 Docker 容器来运行 Pipeline 的各个 stage
- 运行 Pipeline 来生成工件（打包好的应用程序）

## 提示语

### 创建 GitHub 仓库

在个人 GitHub 账号下新建一个仓库 `jenkins-python-app`，将应用代码提交到该仓库。

### 编写 Jenkinsfile 并提交到仓库

Jenkinsfile 放在仓库根目录下，里面需配置 `agent` 为 Docker 容器。由于每个 stage 使用的镜像不一样，因此需要在每个 stage 下单独配置 agent，同时需要把全局的 `agent` 设为 none。

Build、Test 和 Deliver 三个 stage 使用的 Docker 镜像分别为 `registry.cn-hangzhou.aliyuncs.com/louplus-linux/python:2-alpine`、`registry.cn-hangzhou.aliyuncs.com/louplus-linux/qnib-pytest` 和 `registry.cn-hangzhou.aliyuncs.com/louplus-linux/cdrx-pyinstaller-linux:python2`。每个 stage 下都有一个 `sh` step，执行的命令分别为 `python -m py_compile sources/add2vals.py sources/calc.py`、`py.test --verbose --junit-xml test-reports/results.xml sources/test_calc.py` 和 `pyinstaller --onefile sources/add2vals.py`。

在 Test stage，无论 stage 是否执行成功(`post { always {...} }`)，都使用 JUnit 来检查单元测试结果（`junit 'test-reports/results.xml'`）。

在 Deliver stage，还需要在 stage 执行成功（`post { success {...} }`）时生成工件（`archiveArtifacts 'dist/add2vals'`），也就是打包应用。

> 编写 Jenkinsfile 过程中，如果有不熟悉的指令或 step，可以访问前面实验中提供的官方参考资料页面来查阅。另外需要把 `jenkins` 用户加入到 `docker`组（`sudo usermod -a -G docker jenkins`，加入后需重启 Jenkins 服务），以便 Jenkins 可以访问 Docker 服务。

### 创建 Pipeline 项目

使用“经典 UI”方式即可，不需要通过“Blue Ocean”的可视化编辑器来定义 Pipeline。注意，进行到定义 Pipeline step时，选择“Pipeline script from SCM”方式，以便告诉 Jenkins 从 GitHub 仓库里获取定义。

### 运行 Pipeline

Pipeline 运行成功后，会生成工件（可执行程序 `add2vals`），可下载（在单次构建的详情页）并执行该工件来确认结果是否正确。



## 步骤

~~~bash
## 安装java
$ sudo add-apt-repository ppa:webupd8team/java
$ sudo apt-get update
$ sudo apt-get install oracle-java8-installer
## 验证
$ java -version
java version "1.8.0_181"
Java(TM) SE Runtime Environment (build 1.8.0_181-b13)
Java HotSpot(TM) 64-Bit Server VM (build 25.181-b13, mixed mode)

## 安装jenkins
sudo apt-get install deamon
wget https://pkg.jenkins.io/debian-stable/binary/jenkins_2.138.2_all.deb
sudo dpkg -i jenkins_2.138.2_all.deb

# 把 jenkins 用户加入到 docker 组（sudo usermod -a -G docker jenkins，加入后需重启 Jenkins 服务）
sudo usermod -a -G docker jenkins


## 在github新建仓库jenkins-python-app
## 克隆项目到本地
$ git clone https://github.com/[你的id]/jenkins-python-app.git
$ cd jenkins-python-app
$ gedit Jenkinsfile
~~~


~~~groovy
## 编辑Jenkinsfile
pipeline {
    agent none
    stages {
        stage('Build') {
            agent{
                docker { image 'registry.cn-hangzhou.aliyuncs.com/louplus-linux/python:2-alpine' }
            }
            steps {
                sh 'python -m py_compile sources/add2vals.py sources/calc.py'
            }
        }
        stage('Test') {
            agent{
                docker { image 'registry.cn-hangzhou.aliyuncs.com/louplus-linux/qnib-pytest' }
            }
            steps {
                sh 'py.test --verbose --junit-xml test-reports/results.xml sources/test_calc.py'
            }
            post { always{
                    junit 'test-reports/results.xml'
                }
            }
        }
        stage('Deliver') {
            agent{
                docker { image 'registry.cn-hangzhou.aliyuncs.com/louplus-linux/cdrx-pyinstaller-linux:python2' }
            }
            steps {
                sh 'pyinstaller --onefile sources/add2vals.py'
            }
            post {
                success {
                    archiveArtifacts 'dist/add2vals'
                   }
            }
        } 
    }
}

~~~

~~~bash
## 保存完后，注意提交上传到github
$ git add Jenkinsfile
$ git commit -m 'add Jenkinsfile'
$ git remote add orgin https://github.com/[你的id]/jenkins-python-app.git
$ git push -u orgin master
# 验证github


# 进入jenkins界面，新建项目python-app

1. 流水线(pipeline)中，选择“Pipeline script from SCM”方式，
2. “SCM”选择GIT Repository URL填入之前clone的地址（https://github.com/[你的id]/jenkins-python-app.git）
3. Credentials 点击add，填入github用户名、密码，之后选择这个Credential
4. script path：Jenkinsfile，保存

返回项目，点立刻构建
成功后会返回
Build Artifacts
	add2vals	3.39 MB	 view

## 浏览器下载保存到/home/shiyanlou
$ sudo chmod 755 add2vals
$ ./add2vals hello world

The result is helloworld

$ ./add2vals 20 2

The result is 22
~~~





