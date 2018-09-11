# 工资计算器读写数据文件

## 介绍

重新实现上一个挑战中的计算器，可以支持从配置文件中读取社保的税率，并读取员工工资数据 CSV 文件，同时将输出信息写入员工工资单 CSV 文件中。

计算器执行中包含下面的三个参数：

- `-c` **配置文件**：由于各地的社保比例稍有不同，我们为每个城市提供一个社保比例的配置文件。
- `-d` **员工工资数据文件**（CSV 格式）： 指定员工工资数据文件，文件中包含两列内容，分别为员工工号和工资金额。
- `-o` **员工工资单数据文件**（CSV 格式）： 输出内容，将员工缴纳的社保、税前、税后工资等详细信息输出到文件中。

#### 1. 配置文件说明

配置文件格式示例如下：

```python
JiShuL = 2193.00
JiShuH = 16446.00
YangLao = 0.08
YiLiao = 0.02
ShiYe = 0.005
GongShang = 0
ShengYu = 0
GongJiJin = 0.06
```

配置文件中，各类保险以其汉语拼音命名（养老保险 → YangLao，公积金 → GongJiJin 等）。**特别需要注意的是**：

- `JiShuL` 为社保缴费基数的**下限**，即工资低于 `JiShuL` 的值的时候，需要按照 `JiShuL` 的数值乘以缴费比例来缴纳社保。
- `JiShuH` 为社保缴费基数的**上限**，即工资高于 `JiShuH` 的值的时候，需要按照 `JiShuH` 的数值乘以缴费比例缴纳社保。
- 当工资在 `JiShuL` 和 `JiShuH` 之间的时候，按照你**实际的工资**金额乘以缴费比例计算社保费用。

**例如**：当工资为 20000 时，因为社保基数为 2193（`JiShuL`） ～ 16446（`JiShuH`），所以是按照社保基数上限 16446（而不是用 20000） 去乘以社保的缴费比例计算实际缴纳的社保数额。

#### 2. 员工工资数据文件说明

员工工资数据文件，即本实验中输入的数据文件。每位员工工资数据单独占一行，文件格式为 **工号,税前工资**，举例如下：

```python
101,3500
203,5000
309,15000
```

#### 2. 员工工资单数据文件说明

员工工资单数据文件，即本实验需要输出得到的数据文件。同样，输出的员工工资单数据文件中，每行格式为 `工号,税前工资,社保金额,个税金额,税后工资`，举例如下：

```python
101,3500,577.50,0.00,2922.50
203,5000,825.00,20.25,4154.75
309,15000,2475.00,1251.25,11273.75
```

**需要特别注意的是**：

- 上面只是示例输出（3 行数据），测试时候用的数据文件可能有更多行，输出的文件行数要与测试文件行数相同，但不需要保持相同的顺序。
- 程序的执行过程如下，配置文件 `test.cfg` 和输入的员工数据文件 `user.csv` 需要自己创建并填入数据（可参考上述内容示例）。文件可以放在任何位置，只要参数中指定文件的路径就可以了，示例如下：

```shell
$ ./calculator.py -c /home/shiyanlou/test.cfg -d /home/shiyanlou/user.csv -o /tmp/gongzi.csv
```

执行成功不需要输出信息到屏幕，执行失败或有异常出现则将错误信息输出到屏幕。

## 目标

完成任务需要达成的目标：

1. 程序存放的位置 `/home/shiyanlou/calculator.py`。
2. 程序必须对文件是否存在，以及是否符合格式要求进行判断，如果有错误需要打印错误信息并退出。
3. 程序返回的税后工资、个税及社保数字保留两位小数，如果是整数，仍然需要保存为 `xxx.00` 这种形式。

## 提示语

*下述实现方案仅供参考，会涉及到先前实验中学习到的知识点，如果自己对程序有足够的理解也可以不按照下述提示编写*

- 需要注意社保基数的处理，比如 20000 元工资高于社保基数的上限 JiShuH 的值，就应该用 JiShuH 这个值去乘以比例计算需要缴纳的社保金额。
- 可以实现一个配置类 `Config`，来获取并存储配置文件中的信息，Config 类 `def __init__(self, configfile)` 中定义一个字典 `self._config = {}` 来存储每个配置项和值，从文件中读取的时候需要注意使用 `strip()` 去掉空格，并可以使用字符串的 `split('=')` 将配置项和值切分开。从 Config 对象中获得配置信息的方法可以定义为 `def get_config(self)`，使用类似 `config.get_config('JiShuH')`。
- 可以实现一个员工数据类 `UserData`，来获取并存储员工数据，同样 `def __init__(self, userdatafile)` 中定义一个字典 `self.userdata = {}` 存储文件中读取的用户 ID及工资，并实现相应的金额计算的方法`def calculator(self)`及输出到文件中的方法 `def dumptofile(self, outputfile)`。
- 需要在上述类中实现文件读取和写入等操作，写入的格式需要保证符合上述描述内容。
- 处理命令行参数的方式：
  - 首先使用 `args = sys.argv[1:]` 获得所有的命令行参数列表，即包括 `-c test.cfg -d user.csv -o gongzi.csv` 这些内容。
  - 使用 `index = args.index('-c')` 获得 `-c` 参数的索引，那么配置文件的路径就是 `-c` 后的参数即 `configfile = args[index+1]`，同样，其他的 `-d` 和 `-o` 参数也用这种方法获得。

如果你阅读完提示之后，依旧没有思路。下面给出了一些示例代码。代码仅供参考，你可以按照自己的想法调整类以及类里面包含的函数。

## 解题

```python
#!/usr/bin/python3
# -*- coding: utf-8 -*-
import sys
import csv # 用于写入 csv 文件


# 处理命令行参数类
class Args(object):
    def __init__(self):
        self.args = sys.argv[1:]
        self.cfg = self.get_cfg()
        self.userdata = self.get_userdata()
        self.outfile = self.get_outfile()

    ##获取各参数对应文件路径     
    def get_cfg(self):
        try:
            index = self.args.index('-c')
            if(self.args[index+1]!=None):
                return self.args[index+1]
        except Exception as e:
            print(e)

    def get_userdata(self):
        try:
            index = self.args.index('-d')
            if(self.args[index+1]!=None):
                return self.args[index+1]
        except Exception as e:
            print(e)

    def get_outfile(self):
        try:
            index = self.args.index('-o')
            if(self.args[index+1]!=None):
                return self.args[index+1]
        except Exception as e:
            print(e)     
   
        
        
    """
    补充代码：
    1. 补充参数读取函数，并返回相应的路径.
    2. 当参数格式出错时，抛出异常.
    """

# 配置文件类
class Config(object):

    def __init__(self):
        self.config = self._read_config()

    # 配置文件读取内部函数
    def _read_config(self):
        config = {}  #创建空字典
        try:
            filename = Args().cfg
            with open(filename) as file:
                for line in file:
                    l = line.split('=')
                    config[l[0].strip()] = float(l[1].strip())  # dic[key]=value 方式添加到字典
            return config
        except Exception as e:
            print(e)
         
        """
        补充代码：
        1. 根据参数指定的配置文件路径，读取配置文件信息，并写入到 config 字典中.
        2. 使用 strip() 和 split() 对读取到的配置文件去掉空格以及切分.
        3. 当格式出错时，抛出异常.
        """

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
                    line = (l.split(",")[0].strip(),l.split(",")[1].strip()) #strip去掉\n和多余空格
                    userdata.append(line)
            return userdata
        except Exception as e:
            print(e)

        """
        补充代码：
        1. 根据参数指定的工资文件路径，读取员工 ID 和工资数据.
        2. 可将员工工号和工资数据设置为元组，并存入 userdata 列表中.
        3. 当格式出错时，抛出异常.
        """

# 税后工资计算类
class IncomeTaxCalculator(object):
    def __init__(self):
        
        self.tax_math = {"0x1500":[0.03,0],"1500x4500":[0.1,105],"4500x9000":[0.2,555],"9000x35000":[0.25,1005],"35000x55000":[0.3,2755],"55000x80000":[0.35,5505],"80000x":[0.45,13505]}

    # 计算个税
    def calc_ptax(self,salary):
        r_salary = float(salary) - self.calc_shebao(salary)
        tax_num = r_salary - 3500
        # <3500不满足征税条件
        if(tax_num<=0):
            return 0.00
        else:
            for k in self.tax_math.keys():
                kk=k.split("x")
                # 超出范围，>=80000的情况
                if(kk[1]==None):
                    ptax = tax_num * self.tax_math[k][0]-self.tax_math[k][1]
                else:
                    # 正常情况
                    if(tax_num > int(kk[0]) and tax_num <= int(kk[1])):
                        ptax = tax_num * self.tax_math[k][0]-self.tax_math[k][1]
                        break
                    else:
                        continue
            return ptax

	# 计算社保
    def calc_shebao(self,salary):
        cfg = Config().config
        # 社保系数
        sbxs = cfg['YangLao']+cfg['YiLiao']+cfg['ShiYe']+cfg['GongShang']+cfg['ShengYu']+cfg['GongJiJin']
        if(float(salary) < cfg['JiShuL']):
            shebao = cfg['JiShuL'] * sbxs
        elif(float(salary) > cfg['JiShuH']):
            shebao = cfg['JiShuH'] * sbxs
        else:
            shebao = float(salary) * sbxs
        return shebao
    

    # 计算每位员工的税后工资函数
    def calc_for_all_userdata(self):
        ud = UserData().userdata
        result =[]
        for u in ud:
            no = int(u[0])
            sal = int(u[1])
            sb = self.calc_shebao(sal)
            pt = self.calc_ptax(sal)
            taxed_sal = ("%.2f" % (float(sal) - sb - pt))  #格式化保留2位小数
            result.append([no,sal,("%.2f" % sb),("%.2f" % pt ),taxed_sal])
        return result
        """
        补充代码：
        1. 计算每位员工的税后工资（扣减个税和社保）.
        2. 注意社保基数的判断.
        3. 将每位员工的税后工资按指定格式返回.
        """

    # 输出 CSV 文件函数
    def export(self, default='csv'):
        result = self.calc_for_all_userdata()
        with open(Args().outfile,"w") as f:   ##注意：open时，开启可写模式 "w"
            writer = csv.writer(f)
            writer.writerows(result)


# 执行
if __name__ == '__main__':
    """
    按实际情况补充代码
    """
    #可先打印结果
    #print(IncomeTaxCalculator().calc_for_all_userdata())  
    IncomeTaxCalculator().export()

```

