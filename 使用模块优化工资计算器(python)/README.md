# 使用模块优化工资计算器

## 介绍

优化上一个挑战中完成的计算器，完善下述需求：

1. 使用 `getopt` 模块处理命令行参数
2. 使用 Python3 中的 `configparser` 模块读取配置文件
3. 使用 `datetime` 模块写入工资单生成时间

计算器执行中包含下面的参数：

- ```
  -h
  ```

   

  或

   

  ```
  --help
  ```

  ，打印当前计算器的使用方法，内容为：

  ```
  Usage: calculator.py -C cityname -c configfile -d userdata -o resultdata
  ```

- `-C 城市名称` 指定使用某个城市的社保配置信息，如果没有使用该参数，则使用配置文件中 `[DEFAULT]` 栏目中的数据，城市名称不区分大小写，比如配置文件中写的是 `[CHENGDU]`，这里参数可以写 `-C Chengdu`，仍然可以匹配

- `-c 配置文件` 配置文件，由于各地的社保比例稍有不同，我们将多个城市的不同配置信息写入一个配置文件

- `-d 员工工资数据文件` 指定员工工资数据文件，文件中包含两列内容，分别为员工工号和工资金额

- `-o 员工工资单数据文件` 输出内容，将员工缴纳的社保、税前、税后工资等详细信息输出到文件中

配置文件格式如下，数字不一定非常准确，仅供参考：

```
[DEFAULT]
JiShuL = 2193.00
JiShuH = 16446.00
YangLao = 0.08
YiLiao = 0.02
ShiYe = 0.005
GongShang = 0
ShengYu = 0
GongJiJin = 0.06

[CHENGDU]
JiShuL = 2193.00
JiShuH = 16446.00
YangLao = 0.08
YiLiao = 0.02
ShiYe = 0.005
GongShang = 0
ShengYu = 0
GongJiJin = 0.06

[BEIJING]
JiShuL = 4251.00
JiShuH = 21258.00
YangLao = 0.08
YiLiao = 0.02
ShiYe = 0.002
GongShang = 0
ShengYu = 0
GongJiJin = 0.12
```

员工工资数据文件格式每行为 `工号,税前工资`，举例如下：

```
101,3500
203,5000
309,15000
```

输出的员工工资单数据文件每行格式为 `工号,税前工资,社保金额,个税金额,税后工资,计算时间`如下：

```
101,3500,577.50,0.00,2922.50,2017-09-01 10:02:00
203,5000,825.00,20.25,4154.75,2017-09-01 10:02:00
309,15000,2475.00,1251.25,11273.75,2017-09-01 10:02:00
```

计算时间为上一挑战中实现的多进程代码中的进程2计算的时间，格式为 `年-月-日 小时:分钟:秒`。

程序的执行过程如下，注意配置文件和输入的员工数据文件需要你自己创建并填入数据，可以参考上述的内容示例：

```
$ ./calculator.py -C Chengdu -c test.cfg -d user.csv -o gongzi.csv
```

执行成功不需要输出信息到屏幕，执行失败或有异常出现则将错误信息输出到屏幕。

## 目标

完成任务需要达成的目标：

1. 程序存放的位置 `/home/shiyanlou/calculator.py`
2. 能够正确处理程序的参数，参数不准确需要返回错误信息并打印使用方法

## 提示语

上一节中我们学习了几个常用的模块，但没有讲 `getopt` 及 `configparser` 模块，这两个模块的内容需要你自己阅读官方文档学习并在本次挑战中实践使用，遇到问题欢迎随时与讨论组中的助教交流，助教会引导你去阅读一些内容，帮助你避免走弯路，但不会告诉你最终答案，仍然需要你自己独立完成。

*下述实现方案仅供参考，会涉及到先前实验中学习到的知识点，如果自己对程序有足够的理解也可以不按照下述提示编写*

- 基于 getopt 模块处理程序的参数
- 基于 configparser 实现配置文件的读取
- 基于 datetime 返回数据计算的时间
- 最后，如果你希望保存自己的程序，可以将代码提交到自己的 Github 账号中

## 系统检测说明

后台有多个脚本对程序文件的路径及运行结果进行检测，如果严格按照实验楼楼赛的标准只给出是否准确的反馈则非常不利于新手排错调试，这里将后台使用的部分测试用例提供出来，大家可以在遇到错误的时候先自行进行排错，提供的部分测试用例仅供参考，如果有任何疑问可以在 QQ 讨论组里与同学和助教进行交流。

如果 `/home/shiyanlou/calculator.py` 已经完成，点击 `提交结果` 后遇到报错，那么测试用例的临时文件都会被保留，可以进入到测试文件夹中进行排错。

首先，测试脚本会将 `/home/shiyanlou/calculator.py` 拷贝到 `/tmp/test.py`，然后会下载以下测试需要的文件：

1. `/tmp/c5.cfg` 配置文件
2. `/tmp/c5user.csv` 员工工资数据文件

执行的测试命令：

```
$ python3 /tmp/test.py -C chengdu -c /tmp/c5.cfg -d /tmp/c5user.csv -o /tmp/c5gongzi.csv
```

排错的时候可以进入到 `/tmp` 目录，先检查下输出的文件 `/tmp/c5gongzi.csv`（员工工资单数据文件）是否存在，如果存在，重点检查下里面的工号为 207 的员工税后工资是否为 `13344.81`，这个地方是最容易出错的地方，通常都是由于社保基数计算的问题导致的，可以确认下。

另外一个容易出错的地方就是 `-C chengdu` 这个参数，需要注意以下几点：

1. chengdu 大小写都应该支持
2. 可以准确的找到并从配置文件中加载 `[CHENGDU]`这一个 section 的配置信息

如果挑战 PASS 了，那么 `/tmp` 目录下的测试文件都会被全部删除。



## 解题

```python
# -*- coding: utf-8 -*-
import sys,queue,getopt,configparser,time,datetime
import csv # 用于写入 csv 文件
from multiprocessing import Process,Queue

# 处理命令行参数类
class Args(object):
    def __init__(self):
        self.args = sys.argv[1:]       
        self.city=self._get_opts("-C")
        self.userdata=self._get_opts("-d")
        self.cfg=self._get_opts("-c")
        self.outfile=self._get_opts("-o")

    ## getopt读取配置文件,sargs短格式，后跟":"代表必须跟参数，largs长格式
    def _get_opts(self,o):
        try:
            sargs = 'hC:c:d:o:'
            largs = 'help'
            opts,args = getopt.getopt(self.args,sargs,largs)
            for opt,val in opts:
                # 如果选项是-h、--help，打印提示后程序退出
                if(opt in ("-h","--help")):
                    print("Usage: calculator.py -C cityname -c configfile -d userdata -o resultdata")
                    sys.exit()
                # 根据传入选项，返回参数值
                elif(opt == o):
                    return val
            return ""
        except getopt.GetoptError as e:
            print(e,"选项不正确，-h --help查看帮助")
            sys.exit()


# 配置文件类
class Config(object):
    def __init__(self):
        self.config = self._read_config()
        # lambda定义个匿名函数，传入元组(key,value)，如果第二个元素value <1取出,否则返回0
        # map用作映射，把lambda定义的方法，套用到每个self.config列表项，获得新对象(object)
        # 再用list把map返回的object对象转化为列表，通过sum计算求和
        r = list(map(lambda x : float(x[1]) if float(x[1]) <1 else 0.00 ,self.config))
        self.sbxs = sum(r)

    # 配置文件读取内部函数
    def _read_config(self):

        conf = configparser.ConfigParser()
        try:
            conf.read(Args().cfg)
            city = str.upper(Args().city)   # 注意，将city值先转大写
            if(city!=""):
                return conf.items(city)
            else:
                return conf.items("DEFAULT")
        except Exception as e:
            print(e)

# 用户数据类
class UserData(object):
    def __init__(self):
        self.data = self._read_users_data()
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
        if(salary < float(cfg[0][1])):
            shebao = float(cfg[0][1]) * Config().sbxs
        elif(salary > float(cfg[1][1])):
            shebao = float(cfg[1][1]) * Config().sbxs
        else:
            shebao = salary * Config().sbxs
        return shebao
      

def load_userdata_1byone(q):
    usdata = UserData().data
    for ud in usdata:
        no,sal = ud
        q.put([int(no),float(sal)])

def calc_tax(q_get,q_put):
    while True:
        try:
            no,sal = q_get.get(timeout=0.1)
            print("q1 get:",no,sal)
            income = IncomeTaxCalculator()
            sb = income.calc_shebao(sal)
            pt = income.calc_ptax(sal)
            taxed_sal = ("%.2f" % float(sal - sb - pt))
            q_put.put([no,("%.2f" % float(sal)),("%.2f" % float(sb)),("%.2f" % float(pt) ),taxed_sal,get_now()])            
        except queue.Empty:
            return
       
def export_byone(q):
    while True:
        try:
            result = q.get(timeout=0.1)
            print("q2 get:",result)
            with open(Args().outfile,"a") as f:
                writer = csv.writer(f)
                writer.writerow(result)
        except FileNotFoundError as e:    
            print("输出文件未指定，请检查 -o outfile")
            sys.exit()
        except queue.Empty:
            return
def get_now():
    return time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))
        

# 执行
if __name__ == '__main__':

    q1,q2 = Queue(),Queue()
    p1 = Process(target=load_userdata_1byone,args=(q1,))
    p1.start()    
    p2 = Process(target=calc_tax,args=(q1,q2,))
    p2.start()
    p3 = Process(target=export_byone,args=(q2,))
    p3.start()

```

