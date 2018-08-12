# 挑战：Sed 优化 Markdown 文档

## 介绍

你是实验楼的课程文档质量检测员，每天都需要检查课程文档的格式（Markdown），以保证文档的规范性。

下面是需要处理的原始文档，里面有许多不规范的地方。比如缺少空行，多了空行，图片链接前面漏了 ! 号，链接地址没有全部使用 https 等。

```shell
## 介绍
本次挑战内容是...


## 目标

本次挑战目标是...

本次挑战用到资源如下：

[资源图片1](https://www.shiyanlou.com/test1.png)
![资源图片2](http://www.shiyanlou.com/test2.jpg)

[资源数据1](https://www.shiyanlou.com/test1.tar.gz)
![资源数据2](https://www.shiyanlou.com/test2.tar.gz)


## 提示语

1.首先执行...
1.然后执行...
1.最后得到...
```

在 `shiyanlou` 用户家目录下执行如下命令来优化文档，并将优化结果保存到 `test_document_fixed.md` 文件里。

```shell
sed -r -f ./fix_format.sed test_document.md >test_document_fixed.md
```

注意我们使用了 `-r` 选项，以便使用扩展正则表达式语法。`test_document_fixed.md` 文件的内容应该跟下面完全一致。

```shell
## 介绍

本次挑战内容是...

## 目标

本次挑战目标是...

本次挑战用到资源如下：

![资源图片1](https://www.shiyanlou.com/test1.png)

![资源图片2](https://www.shiyanlou.com/test2.jpg)

[资源数据1](https://www.shiyanlou.com/test1.tar.gz)

[资源数据2](https://www.shiyanlou.com/test2.tar.gz)

## 提示语

1. 首先执行...
1. 然后执行...
1. 最后得到...
```

## 目标

1. 相关脚本和文件必须放在用户家目录下，且命名跟要求一致
2. 段落之间需要有空行
3. 连续多个空行只保留一个
4. 所有图片链接前面都要有 ! 号，图片格式仅考虑 jpg 和 png 两种
5. 所有非图片链接前面都不能有 ! 号
6. 所有链接地址都需要使用 https 协议
7. 列表项开头数字跟文字之间需要有空格

## 解题

```bash
wget http://labfile.oss.aliyuncs.com/courses/980/02/assets/test_document.md
vi fix_format.sed
chmod 755 fix_format.sed
```



```shell
#!/bin/sed -f

/^$/d								##删除全部空行

/^[0-9]+\./!G						##除列表项外，每行下增加一行 G 取反 !

s/\(http:/\(https:/g				##替换http为https 全局 g

s/^!\[/\[/g							##删除所有链接行首的感叹号"!"

/http/{/(\.png|\.jpg)/s/^/!/g}      ##找到含有http，带.jpg或.png的行，行首加感叹号"!"

/^[0-9]+\./s/\./\. /				##列表项数字和文字之间加空格
```

