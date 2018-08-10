## 初始化本地 Git 仓库

### 介绍

对应上一章文档中的内容，来创建我们第一个本地 Git 仓库。我们需要设置个人的 Git 信息，包括 username 和 email。另外需要对本地 Git 仓库进行初始化操作以及增加一些项目文件。

### 目标

1. 设置 Git 信息；
2. 完成本地 Git 仓库的初始化操作；
3. 设置关联到远程仓库；
4. 创建 README.md 文件并进行 commit（不需要 push 到远程仓库）；

### 标准

1. 本地 Git 仓库目录固定为 `/home/shiyanlou/HelloGit/`。
2. 远程仓库地址固定为 [`git@shiyanlou.com](mailto:%60git@shiyanlou.com)/HelloGit.git`，远程版本库名称为`origin`。
3. 需要在本地目录中创建 `README.md` ，文件名为 `README.md`。并在其中增加文本 `Hello World`。

### 步骤

```bash
$ mkdir /home/shiyanlou/HelloGit
$ cd /home/shiyanlou/HelloGit
$ git init
HelloGit/ (master)$ echo Hello World > README.md
HelloGit/ (master)$ git add .
HelloGit/ (master)$ git status -s
	A README.md
	
HelloGit/ (master)$ git config --global user.name "my name"
HelloGit/ (master)$ git config --global user.email "my@gmail.com"
HelloGit/ (master)$ git commit -m 'first commit'
	On branch master
	nothing to commit, working directory clean
	
HelloGit/ (master)$ git remote add origin https://git@shiyanlou.com/HelloGit.git
```

