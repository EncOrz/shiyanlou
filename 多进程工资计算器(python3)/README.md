# 多进程工资计算器

## 介绍

优化上一个挑战中的计算器，支持使用多进程的方式对员工工资数据进行处理，以应对文件数据量很大的情况下，提高计算效率。

程序的执行过程如下，注意配置文件和输入的员工数据文件需要你自己创建并填入数据，可以参考上述的内容示例：

```shell
$ ./calculator.py -c test.cfg -d user.csv -o gongzi.csv
```

执行成功不需要输出信息到屏幕，执行失败或有异常出现则将错误信息输出到屏幕。

需要注意的是必须包含下列的处理方式：

1. 启动三个进程，使用进程 1 读取员工工资数据，使用进程 2 计算个税及社保，使用进程 3 将数据写入到输出的工资单数据文件中。
2. 三个进程负责不同的工作，进程之间使用某种机制进行通信。

## 目标

完成任务需要达成的目标：

1. 程序存放的位置 `/home/shiyanlou/calculator.py`
2. 程序必须采用多进程的方式处理员工工资数据，并保证进程间能够同步

## 提示语

*下述实现方案仅供参考，会涉及到先前实验中学习到的知识点，如果自己对程序有足够的理解也可以不按照下述提示编写*

- 基于 multiprocessing 模块实现多进程
- 基于 Queue 实现进程间通信
- 实现完成后，可以考虑是否可以在计算环节的进程2实现为一个进程池？
- 实现方案可以考虑定义 **queue1** 和 **queue2**，实现三个进程如下：
  - **进程 1**：从用户文件中读取数据，然后得到一个列表 data，第一项是用户 ID，第二项是税前工资，然后使用 `queue1.put(data)`。
  - **进程 2**：`queue1.get()` 得到列表 data，第一项是用户 ID，第二项是税前工资，然后计算后生成新的列表。 newdata，包含社保，个税，税后工资等数据，然后使用 `queue2.put(newdata)`。
  - **进程 3**：`queue2.get()` 得到列表 newdata，包含用户 ID，税前工资，社保，个税，税后工资等数据，然后写入文件。

最后，因为后续的挑战将会用到现在写的代码，请使用 `下载代码` 保存到本地或者提交到自己的 Github。

## 系统检测说明

本挑战的测试用例包括两部分，第一部分和挑战3相同，对结果进行检测，第二部分是对多进程下使用 Queue 进行测试，第一部分的测试如果已经通过挑战3的话应该没有问题，附上测试和排错说明如下。

### 第一部分测试：程序结果检测

如果 `/home/shiyanlou/calculator.py` 已经完成，点击 `提交结果` 后遇到报错，那么测试用例的临时文件都会被保留，可以进入到测试文件夹中进行排错。

首先，测试脚本会将 `/home/shiyanlou/calculator.py` 拷贝到 `/tmp/test.py`，然后会下载以下测试需要的文件：

1. `/tmp/c3.cfg` 配置文件
2. `/tmp/c3user.csv` 员工工资数据文件

执行的测试命令：

```
$ python3 /tmp/test.py -c /tmp/c3.cfg -d /tmp/c3user.csv -o /tmp/c3gongzi.csv
```

排错的时候可以进入到 `/tmp` 目录，先检查下输出的文件 `/tmp/c3gongzi.csv`（员工工资单数据文件）是否存在，如果存在，重点检查下里面的工号为 207 的员工税后工资是否为 `13344.81`，这个地方是最容易出错的地方，通常都是由于社保基数计算的问题导致的，可以确认下。

如果挑战 PASS 了，那么 `/tmp` 目录下的测试文件都会被全部删除。

### 第二部分测试：对多进程进行检测

检测的重点是 `multiprocessing` 模块下的 `Queue`的使用，检测过程中最容易出错的地方是程序没有退出，出现卡住的情况。

这种情况出现的原因是由于 `queue.get()` 的时候，队列已经空了，那么 `get()` 操作会卡住，并且一直等待，从而造成程序无法退出。解决的方案是给 `get()`函数增加一个 timeout 的参数，设置的方式可以查询 Queue 的官方文档。

设置 timeout 的目的是，当 `get()` 等待的时间达到 timeout 的时候就会抛出异常退出，使用 try except 进行处理，若抛出的是 `queue.Empty` 异常，表示队列已经为空了，说明程序已经处理完所有的数据，则直接退出进程就可以了。



## 解题

```python
# -*- coding: utf-8 -*-
import sys,queue
import csv # 用于写入 csv 文件
from multiprocessing import Process,Queue


# 处理命令行参数类
class Args(object):
    def __init__(self):
        self.args = sys.argv[1:]
        self.cfg = self._get_cfg()
        self.userdata = self._get_userdata()
        self.outfile = self._get_outfile()
    def _get_cfg(self):
        try:
            index = self.args.index('-c')
            if(self.args[index+1]!=None):
                return self.args[index+1]
        except Exception as e:
            print(e)
    def _get_userdata(self):
        try:
            index = self.args.index('-d')
            if(self.args[index+1]!=None):
                return self.args[index+1]
        except Exception as e:
            print(e)
    def _get_outfile(self):
        try:
            index = self.args.index('-o')
            if(self.args[index+1]!=None):
                return self.args[index+1]
        except Exception as e:
            print(e)     
# 配置文件类
class Config(object):
    def __init__(self):
        self.config = self._read_config()
        self.sbxs = sum([ v for v in self.config.values() if v < 1])

    # 配置文件读取内部函数
    def _read_config(self):
        config = {}
        try:
            filename = Args().cfg
            with open(filename,"r") as file:
                for line in file:
                    l = line.split('=')
                    config[l[0].strip()] = float(l[1].strip())
            return config
        except Exception as e:
            print(e)
# 用户数据类
class UserData(object):
    def __init__(self):
        self.userdata = self._read_users_data()
    # 用户数据读取内部函数
    def _read_users_data(self):
        userdata = []
        try:
            filename = Args().userdata
            with open(filename) as file:
                for l in file:
                    line = (l.split(",")[0].strip(),l.split(",")[1].strip())
                    userdata.append(line)
            return userdata
        except Exception as e:
            print(e)

# 税后工资计算类
class IncomeTaxCalculator(object):
    def __init__(self):        
        self.tax_math = {"0x1500":[0.03,0],"1500x4500":[0.1,105],"4500x9000":[0.2,555],"9000x35000":[0.25,1005],"35000x55000":[0.3,2755],"55000x80000":[0.35,5505],"80000x":[0.45,13505]}
    # 计算个税
    def calc_ptax(self,salary):
        r_salary = salary - self.calc_shebao(salary)
        tax_num = r_salary - 3500
        if(tax_num<=0):
            return 0.00
        else:
            for k in self.tax_math.keys():
                kk=k.split("x")
                if(kk[1]==None):
                    ptax = tax_num * self.tax_math[k][0]-self.tax_math[k][1]
                else:
                    if(tax_num > int(kk[0]) and tax_num <= int(kk[1])):
                        ptax = tax_num * self.tax_math[k][0]-self.tax_math[k][1]
                        break
                    else:
                        continue
            return ptax
    # 计算社保
    def calc_shebao(self,salary):
        cfg = Config().config
        if(salary < cfg['JiShuL']):
            shebao = cfg['JiShuL'] * Config().sbxs
        elif(salary > cfg['JiShuH']):
            shebao = cfg['JiShuH'] * Config().sbxs
        else:
            shebao = salary * Config().sbxs
        return shebao
      
#按题目要求创建方法

#加载工资信息，参数：用于发送的Queue对象
def load_userdata_1byone(q_put):
    userdata = UserData().userdata
    for ud in userdata:
        no,sal = ud
        # 将工号、工资通过queue传送
        q_put.put([int(no),float(sal)])

# 方法:计算个税和社保
# 参数:用于接收的Queue对象q_get，用于发送的Queue对象q_put
def calc_tax(q_get,q_put):
    while True:
        try:
            no,sal = q_get.get(timeout=0.1)
            #print("q1 get:",no,sal)    #打印调试用
            income = IncomeTaxCalculator()
            sb = income.calc_shebao(sal)
            pt = income.calc_ptax(sal)
            taxed_sal = ("%.2f" % float(sal - sb - pt))
            q_put.put([no,("%.2f" % float(sal)),("%.2f" % float(sb)),("%.2f" % float(pt) ),taxed_sal])            
        except queue.Empty:
            return   
        # 这里情况下也可以用break,return直接返回函数None并且退出，break跳出循环后，还会继续执行函数中循环后的语句，这里跳出循环相当于也结束了函数

# 用于输出到指定csv文件
def export_byone(q):
    while True:
        try:
            result = q.get(timeout=0.1)
            #print("q2 get:",result)   #打印调试用
            with open(Args().outfile,"a") as f:    # "a" 附加写方式，不存在会新建
                writer = csv.writer(f)
                writer.writerow(result)
        except queue.Empty:
            return

# 执行
if __name__ == '__main__':
    q1,q2 = Queue(),Queue()   # 定义Queue对象，q1,q2用于子进程p1、p2、p3通讯
    
    # 子进程分别执行三个步骤

    p1 = Process(target=load_userdata_1byone,args=(q1,))
    p1.start()    
    p2 = Process(target=calc_tax,args=(q1,q2,))
    p2.start()
    p3 = Process(target=export_byone,args=(q2,))
    p3.start()
```

**进程1：userdata --> load_userdata_1byone 逐条加载 ---put---> q1 -->进程2： calc_tax (获得 q1 并 计算后 --put--> q2 --> 进程3： export_byone 获得 q2 后输出到 csv 文件**

