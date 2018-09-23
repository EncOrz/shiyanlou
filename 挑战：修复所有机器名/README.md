# 挑战：修复所有机器名

## 介绍

通过上一次的检查之后发现不仅仅是新同事添加的机器有忘记修改的 Hostname，就连我们的负责人添加的部分机器都有很多 Hostname 没有修改，这样使得没有修改 Hostname 的机器数量非常大，并且我们只是检查当前生效的 Hostname，没有检查 `/etc/hostname` 中的值是否修改，所以为了保险起见，我们决定将所有添加的机器放在 product 组中，统一修改一次 Hostname 文件。（别忘记 Ansible 的安装）

需要注意的点有：

1.每个机器的 Hostname 不同，我们可以利用 `inventory_hostname` 变量来实现 2.当前机器模拟 `docker1.shiyanlou.com` 机器，所以修改 `/etc/hostname` 为该名，同时我们还需要修改 `/etc/hosts` 的解析(因为环境的原因我们此处将 hosts 文件复制至 `/home/shiyanlou/hosts` 下，修改 `/home/shiyanlou/hosts` 文件) 3.因为环境的缘故，我们不直接使用 Ansible 提供的 `hostname` 模块

## 目标

1. 完成的 playbook 必须放置在 `/home/shiyanlou/modify_hostname.yml` 文件
2. 能够通过 playbook 修改 `/etc/hostname`
3. 能够通过 playbook 修改 `/home/shiyanlou/hosts`

## 提示

- Inventory 中该机器名应该为 `docker1.shiyanlou.com`
- 遇到权限问题使用 `become` 指令
- 提交结果前，须使用 `root` 用户运行一次 `modify_hostname.yml` 文件

## 解题

```bash
## 安装Ansible
$ sudo apt-get update
$ sudo apt-get install software-properties-common
$ sudo apt-get update
$ sudo python3.4 /usr/bin/apt-add-repository ppa:ansible/ansible
$ sudo apt-get install ansible
$ ansible --version ##注意查看是否版本号 >1.9，因为become需要1.9以后才支持

## 添加ssh认证
$ ssh-keygen -t rsa
$ cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys
$ sudo vi /etc/ssh/ssh_config
PubkeyAuthentication yes 
$ sudo service ssh restart
$ ansible test -m ping  ##测试

## 添加inventory hosts
$ sudo vi /etc/ansible/hosts
[test]
localhost ansible_ssh_user=shiyanlou ansible_ssh_private_key_file=/home/shiyanlou/.ssh/id_rsa

## hosts文件复制到/home/shiyanlou下
$ sudo cp /etc/hosts /home/shiyanlou/

$ sudo vi modify_hostnane.yml
```

```yaml
---
- hosts: test
  become_user: root  #指定被授权用户
  vars:     ##变量
      inventory_hostname:  docker1.shiyanlou.com
  tasks:
      - name: "modify hostname"
        shell: echo "{{ inventory_hostname }}" > /etc/hostname
        become: yes  ##启用被授权
      
      - name: "modify hosts file"
        shell: echo 127.0.0.1 "{{ inventory_hostname }}" >> /home/shiyanlou/hosts
        become: yes
...
```

```bash
## 题目要求用root用户执行一次
$ sudo ansible-playbook modify_hostname.yml
PLAY [test] *******************************************************************************

TASK [Gathering Facts] ********************************************************************
ok: [127.0.0.1]

TASK [modify hostname] ********************************************************************
changed: [127.0.0.1]

TASK [modify hosts file] ******************************************************************
changed: [127.0.0.1]

PLAY RECAP ********************************************************************************
127.0.0.1                  : ok=3    changed=2    unreachable=0    failed=0   

```

