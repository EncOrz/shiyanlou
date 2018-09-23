# 挑战：完善 Python 监控脚本

上一节实验中通过 Python 实现了类似 netstat 的简单脚本，在不添加参数的情况下默认只查看了 `tcp` 相关的网络数据，本节挑战优化该脚本，需求如下：

1. 提供 all 参数，当使用该参数时同时读取 tcp、tcp6、udp、udp6 相关的数据
2. 默认不提供参数的情况使用 all 为默认参数

## 目标

1. 完成的脚本必须放置在 `/home/shiyanlou/monitor.py` 文件中
2. 脚本需要符合上述规则

脚本运行实例：

```python
$ python /home/shiyanlou/monitor.py

Proto Local address                  Remote address                 Status        PID    Program name
tcp   0.0.0.0:5901                   -                              LISTEN        -      -
tcp   0.0.0.0:80                     -                              LISTEN        -      -
tcp   0.0.0.0:6001                   -                              LISTEN        -      -
tcp   0.0.0.0:22                     -                              LISTEN        -      -
tcp6  0.0.0.0:5901                   -                              LISTEN        -      -
tcp6  0.0.0.0:6001                   -                              LISTEN        -      -
tcp6  0.0.0.0:22                     -                              LISTEN        -      -
........
```

## 知识点

1. Python 语法
2. 从 `/proc` 获取系统信息

## 解题

上一节实验中最后已经提供了，Python 实现了类似 netstat 的简单脚本代码，可以直接用，但是要满足这挑战要求还需要稍做修改。

```python
if __name__ == '__main__':
    choose = 'tcp'     #<<---这里
    if len(sys.argv) > 1:
        choose = sys.argv[1]
    main(choose)
```

修改默认参数`'tcp'`为`'all'`，这样在无参数情况下默认会显示所有协议。

```python
if __name__ == '__main__':
    choose = 'all'  
```

上一实验已经讲解了如何实现，`RPOC_FILE` 包含了其中的所有协议和`/proc/net`中的路径，只要做到将这个字典遍历读取文件内容到对象`content`中，即可。

```python
def get_content(type):
    ''' 读取文件内容
    '''
    with open(PROC_FILE[type], 'r') as file:
        content = file.readlines()
        content.pop(0)  # 去除文件的第一行抬头
    return content
```

这段代码就是获取文件内容的方法，修改为如下：

```python
def get_content(type):
    ''' 读取文件内容
    '''
    if type == 'all':
    	content = []  ##定义空list
    	for k in PROC_FILE.keys():
            with open(PROC_FILE[k], 'r') as file:
            	c = file.readlines()
            	c.pop(0)
                content.extend(c)  #将两个list合并，实际上就是内容累加
        return content
    else:
        with open(PROC_FILE[type], 'r') as file:
            content = file.readlines()
            content.pop(0)  
        return content
```

后面的方法在调用`get_content("all")`方法后就能等到所有定义的协议内容，保存。测试会发现问题。

```shell
$ python3 monitor.py
Proto Local address                  Remote address                 Status        PID    Program name
all   0.0.0.0:444                    -                              LISTEN        72384  nginx
all   0.0.0.0:10050                  -                              LISTEN        104694 zabbix_agentd
all   192.168.0.4:22                 61.171.109.231:60557           ESTABLISHED   109376 sshd
all   127.0.0.1:9000                 127.0.0.1:46747                ESTABLISHED   72388  nginx
all   127.0.0.1:46747                127.0.0.1:9000                 ESTABLISHED   12805  prometheus
all   192.168.0.4:10050              106.12.115.168:45954           TIME_WAIT     1      init
all   192.168.0.4:10050              106.12.115.168:45948           TIME_WAIT     1      init
```

`Proto`字段（协议）这里全部显示成了`"all"`，没有显示成正确的协议类型。检查后发现问题出在`main`方法

```python
def main(choose):
    '''获取并展示端口连接相关信息
    '''
    templ = "%-5s %-30s %-30s %-13s %-6s %s"
    print(templ % (
        "Proto", "Local address", "Remote address", "Status", "PID",
        "Program name"))
    content = get_content(choose)

    for info in content:
        iterms = info.split()
        proto = choose    #<<----这里直接用传入的参数赋值了。明确协议名时没问题，但是all就会有bug
        local_address = "%s:%s" % convert_ip_port(iterms[1])
        status = STATUS[iterms[3]]
        if status == 'LISTEN':
            remote_address = '-'
        else:
            remote_address = "%s:%s" % convert_ip_port(iterms[2])
        pid = get_pid(iterms[9])
        program_name = ''
        if pid:
            program_name = get_program_name(pid)
        print(templ % (
            proto,
            local_address,
            remote_address,
            status,
            pid or '-',
            program_name or '-',
        ))
```

**我的解决方法是，轮询每个协议对应文件提取内容`get_content(type)`的时候，标记上它的协议所属，在main方法中过滤这个标记，并且复制给`proto`变量。**

修改 `get_content` 方法

```python
def get_content(type):
    if type == "all":
        content = []
        for k in PROC_FILE.keys():
            with open(PROC_FILE[k], 'r') as file:
                content.append(k+"\n")   #<---加协议类型的标记进去
                c = file.readlines()
                c.pop(0)
                content.extend(c)
        return content
    else:
        content = []    
        with open(PROC_FILE[type], 'r') as file:
            c = file.readlines()
            c.pop(0)
            content.append(type+"\n")    #<---加协议类型的标记进去
            content.extend(c)             
        return content
```

相应的修改 `main` 方法

```python
def main(choose):
    templ = "%-5s %-30s %-30s %-13s %-6s %s"
    print(templ % (
        "Proto", "Local address", "Remote address", "Status", "PID",
        "Program name"))
    content = get_content(choose)
    ####修改部分
    proto = ""                     #增加
    for info in content:
        iterms = info.split()
        if len(iterms)==1:			# 劫获标记行(用长度来判断)
            proto = iterms[0]		# 将标记赋值给proto
            continue				 # 赋值好变量后不继续，重新下个循环读取有效的数据部分
    ####修改完
        local_address = "%s:%s" % convert_ip_port(iterms[1])
        status = STATUS[iterms[3]]
        if status == 'LISTEN':
            remote_address = '-'
        else:
            remote_address = "%s:%s" % convert_ip_port(iterms[2])
        pid = get_pid(iterms[9])
        program_name = ''
        if pid:
            program_name = get_program_name(pid)
        print(templ % (
            proto,
            local_address,
            remote_address,
            status,
            pid or '-',
            program_name or '-',
        ))
```

修改完毕，保存。PASS