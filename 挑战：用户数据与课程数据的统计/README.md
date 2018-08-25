---
title: 挑战：用户数据与课程数据的统计
tags: MySql
---



# 挑战：用户数据与课程数据的统计

在实验楼的数据库中有大量的用户学习数据，运营同学我们希望统计用户的学习数据与课程的学习人、学习时间的数据。

运营同学可以根据用户统计数据找出学习时间最高的用户，并给予发送奖励，同时可以根据课程的统计数据找出学习时间最高，学习人数最多的课程。

<!--more-->

我们从实验楼的线上数据库中导出部分用户学习的记录，首先我们需要将提供好的数据文件导入数据库中：

```shell
wget http://labfile.oss.aliyuncs.com/courses/980/files/week7/shiyanlou-mysqlone.sql
```

然后将其导入数据库中：

```mysq
mysql -u root -e "create database shiyanlou"
mysql -u root shiyanlou < shiyanlou-mysqlone.sql
```

紧接着我们需要创建一个视图，名为 `user_all_study_time`，通过该视图我们可以统计出有学习记录同学的总学习时间例如：

```mysql
mysql> select * from user_all_study_time;
+---------+------------+----------------+
| user_id | user_name  | all_study_time |
+---------+------------+----------------+
|     679 | LOUef9c1c2 |              1 |
|     962 | LOUd8cc151 |              3 |
|     844 | LOU065c64d |              5 |
|     403 | LOUecf6efb |              6 |
|     616 | LOU486c4b9 |              7 |
.....
.....
+-----+------------+----------------+
```

该视图需求为：

1. 视图名为 `user_all_study_time`
2. 视图有三列：`user_id`（用户 id)、`user_name`（用户名）、`all_study_time`(学习总时间)

同时创建一个课程数据统计的视图，名为 `course_statistics`，通过该视图我们可以统计出学习人数最多与学习时间最长的课程，例如：

```mysql
mysql> select * from course_statistics;
+-------------------------------------------------+------------+----------------+
| course_name                                     | user_count | all_study_time |
+-------------------------------------------------+------------+----------------+
| 由浅入深学网络                                  |         14 |            792 |
| Laravel 项目实战：仿新浪微博Web应用             |         12 |            649 |
| 动手实战学Docker (15个实验+54个视频)            |         13 |            633 |
| Java实现在线协作文档编辑                        |         10 |            622 |
| Spark 大数据动手实验                            |         10 |            559 |
......
......
+-------------------------------------------------+------------+----------------+
```

该视图需求为：

1. 视图名为 `course_statistics`
2. 视图有三列：`course_name`（课程的名字)、`user_count`（学习用户人数统计）、`all_study_time`(学习总时间)
3. 以课程的学习时间降序排列

## 目标

1. 创建视图 `user_all_study_time` 统计用户的总学习时间
2. 创建视图 `course_statistics` 统计课程的数据

## 步骤

检查确认mysql已启动

```shell
$ sudo serivce mysql status || sudo service mysql start
```

按要求做好准备工作

```shell
$ wget http://labfile.oss.aliyuncs.com/courses/980/files/week7/shiyanlou-mysqlone.sql
$ mysql -u root -e "create database shiyanlou"
$ mysql -u root shiyanlou < shiyanlou-mysqlone.sql
```

```
##进入数据库
mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| shiyanlou          |    ##<目标数据库shiyanlou
+--------------------+
4 rows in set (0.00 sec)

##进入shiyanlou数据库
mysql> USE shiyanlou;

mysql> SHOW TABLES;
+---------------------+
| Tables_in_shiyanlou |
+---------------------+
| course              | 
| user                |
| usercourse          |
+---------------------+
3 rows in set (0.00 sec)


```

分别是`course`,`user` ,`usercourse`三张表，分别用`desc`查看表的结构；

```mysql
mysql> DESC course;
+-------+-------------+------+-----+---------+-------+
| Field | Type        | Null | Key | Default | Extra |
+-------+-------------+------+-----+---------+-------+
| id    | int(4)      | NO   | PRI | NULL    |       |
| name  | varchar(50) | YES  |     | NULL    |       |
+-------+-------------+------+-----+---------+-------+
2 rows in set (0.00 sec)

mysql> DESC user;
+-------+----------+------+-----+---------+-------+
| Field | Type     | Null | Key | Default | Extra |
+-------+----------+------+-----+---------+-------+
| id    | int(4)   | NO   | PRI | NULL    |       |
| name  | char(20) | YES  |     | NULL    |       |
+-------+----------+------+-----+---------+-------+
2 rows in set (0.01 sec)

mysql> DESC usercourse;
+------------+---------+------+-----+---------+----------------+
| Field      | Type    | Null | Key | Default | Extra          |
+------------+---------+------+-----+---------+----------------+
| id         | int(11) | NO   | PRI | NULL    | auto_increment |
| user_id    | int(11) | YES  | MUL | NULL    |                |
| course_id  | int(11) | YES  | MUL | NULL    |                |
| study_time | int(11) | YES  |     | NULL    |                |
+------------+---------+------+-----+---------+----------------+
4 rows in set (0.00 sec)

```

从三张表的结构中可以看出之间联系

`user.id = usercourse.user_id`

`usercourse.course_id = course.id`

先通过**内联结**方式以`usercourse`作为主表整理出一张全表（ 只列出头3行 `limit 3`）

```mysql
mysql> SELECT *  FROM  usercourse AS uc  INNER JOIN (user AS u,course AS c)  ON uc.course_id = c.id and uc.user_id = u.id limit 3; 
+----+---------+-----------+------------+-----+------------+----+-------------------+
| id | user_id | course_id | study_time | id  | name       | id | name              |
+----+---------+-----------+------------+-----+------------+----+-------------------+
| 10 |     616 |         1 |          7 | 616 | LOU486c4b9 |  1 | Linux基础入门      |
| 11 |     498 |         1 |         40 | 498 | LOU4b1e597 |  1 | Linux基础入门      |
| 49 |     531 |         1 |         82 | 531 | LOUd0c9bed |  1 | Linux基础入门      |
+----+---------+-----------+------------+-----+------------+----+-------------------+
3 rows in set (0.01 sec)

```

1. 创建视图 `user_all_study_time` 统计用户的总学习时间

```mysql
##以学生为统计汇总对象，因此首先通过GROUP BY把user_id聚合，再通过SUM函数对study_time字段求和
mysql>CREATE VIEW user_all_study_time AS
SELECT user_id,u.name AS user_name,SUM(uc.study_time) AS all_study_time 
FROM  usercourse AS uc 
INNER JOIN (user AS u,course AS c) 
ON uc.course_id = c.id AND uc.user_id = u.id 
GROUP BY user_id ;
```

2. 创建视图 `course_statistics` 统计课程的数据

```mysql
##以课程为统计汇总对象，因此先通过GROUP BY把course_id聚合，再COUNT函数对学生id计数，并对聚合集中的study_time通过SUM函数求和，最后ORDER BY对求和结果(all_study_time)进行降序排序(DESC)

CREATE VIEW course_statistics AS 
select c.name AS course_name,count(u.id) AS user_count,sum(uc.study_time) AS all_study_time 
FROM  usercourse AS uc 
INNER JOIN (user AS u,course AS c) 
ON uc.course_id = c.id and uc.user_id = u.id 
GROUP BY uc.course_id 
ORDER BY all_study_time DESC ;
```

3. 验证，两个VIEW都已建立。

```mysql
mysql> SHOW FULL TABLES IN shiyanlou;
+---------------------+------------+
| Tables_in_shiyanlou | Table_type |
+---------------------+------------+
| course              | BASE TABLE |
| course_statistics   | VIEW       |
| user                | BASE TABLE |
| user_all_study_time | VIEW       |
| usercourse          | BASE TABLE |
+---------------------+------------+
5 rows in set (0.00 sec)

```

