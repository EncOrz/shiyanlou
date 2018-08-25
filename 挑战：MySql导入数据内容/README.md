# 挑战：导入数据内容

## 介绍

在开发新功能的时候我们需要经过尽量严格的测试才能上线，而严格的测试需要有仿真的数据才能尽可能真是的模拟出线上的情况，为此我们导出了部分的实验楼线上真实数据内容，我们需要将其导入我们的测试数据库中：

1.首先下载为大家准备好的 csv 数据文件：

```shell
http://labfile.oss.aliyuncs.com/courses/980/files/week7/loudatabase.zip
```

2.解压该文件，获取数据集，然后将其导入，其文件意义是：

- shiyanlou_user.csv：1000名实验楼用户数据，包含两列，用户ID和用户名
- shiyanlou_course.csv：10门实验楼课程数据，包含两列，课程ID和课程名
- shiyanlou_usercourse.csv：100条用户课程学习记录，包含三列，用户ID，课程ID和学习时间

## 目标

1. 新的数据库名称为 `shiyanlou-staging`，设置的可查询与更新的管理用户为 `shiyanlou`，密码为 `Xd4a8lKjeL9Z`。
2. `shiyanlou-staging` 数据库包含三个表：shiyanlou_user，shiyanlou_course，shiyanlou_usercourse，每个表包含一个 csv 数据文件中的所有数据。

- shiyanlou_user 表包含两列：id（主键），name。
- shiyanlou_course 表包含两列：id（主键），name。
- shiyanlou_usercourse 表包含四列：id，user_id，course_id，study_time（user_id 为 shiyanlou_user 表中 id 的外键，course_id 为 shiyanlou_course 表中的 id 外键）

注意与其他两个表主键之间的关系。

## 提示

1. 创建数据库是 `shiyanlou-staging` 中的短横线需要用识别符
2. 创建数据库的时候注意字符集的设置
3. shiyanlou_usercourse 的 ID 列为自增（id 列自动填充递增数字序列，如 1，2，3....），不为导入的列
4. load data 的时候需要指定绝对路径

## 步骤

准备

```shell
$ service mysql status || service mysql start
$ wget http://labfile.oss.aliyuncs.com/courses/980/files/week7/loudatabase.zip
$ unzip loudatabase.zip
$ ls looudatabase ##3个需要导入的数据源文件
shiyanlou_course.csv  shiyanlou_usercourse.csv  shiyanlou_user.csv

```

新建数据库以及创建需要导入的表（表结构）

```mysql
$ mysql -uroot
##数据库名中含有“-” 因此需要用 `` 识别符
mysql> CREATE TABLE `shiyanlou-staging`;
mysql> USE shiyanlou-staging

##创建shiyanlou_user,shiyanlou_course,shiyanlou_usercourse
mysql> CREATE TABLE shiyanlou_user(
    > id INT PRIMARY KEY,
    > name VARCHAR(20)
    > );
    
mysql> CREATE TABLE shiyanlou_course(
    > id INT PRIMARY KEY,
    > name VARCHAR(20)
    > );
    
mysql> CREATE TABLE shiyanlou_usercourse(
    > id INT AUTO_INCREMENT PRIMARY KEY,
    > user_id INT,
    > course_id INT,
    > FOREIGN KEY (user_id) REFERENCES shiyanlou_user(id),
    > FOREIGN KEY (course_id) REFERENCES shiyanlou_course(id)
    > );
   
##导入数据
mysql> LOAD DATA INFILE '/home/shiyanlou/loudatabase/shiyanlou_user.csv'  
	 > INTO TABLE shiyanlou_user 
	 > FIELDS TERMINATED BY ',';
mysql> LOAD DATA INFILE '/home/shiyanlou/loudatabase/shiyanlou_course.csv'  
	 > INTO TABLE shiyanlou_course 
	 > FIELDS TERMINATED BY ',';
	 ##usercourse不需要导入id字段，该字段会自增，因此需要指定列
mysql> LOAD DATA INFILE '/home/shiyanlou/loudatabase/shiyanlou_usercourse.csv'  
	 > INTO TABLE shiyanlou_usercourse 
	 > FIELDS (user_id,course_id,study_time) TERMINATED BY ',';
   

##创建用户“shiyanlou”并设置权限
mysql> CREATE USER shiyanlou; 
mysql> GRANT SELECT,UPDATE
	 > ON `shiyanlou-stagin`.*
	 > TO shiyanlou@localhost
	 > INDENTIFIED BY "Xd4a8lKjeL9Z";
mysql> FLUSH PRVILIEGES;


ALL DONE
```

