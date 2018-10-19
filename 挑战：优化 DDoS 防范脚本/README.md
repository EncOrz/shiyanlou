# 挑战：优化 DDoS 防范脚本

**注意：**由于实验楼的挑战只能够在容器环境运行，而容器环境又不可以执行 iptables，所以这个脚本在挑战的环境中无法运行，只能在实验环境中调试成功后拷贝到当前挑战环境的 `/home/shiyanlou/ddos.sh`，再点击提交。同样，由于挑战环境的限制，无法真实运行脚本，会存在检测不完全的地方，请在上一节实验中的 CentOS 7 的环境中测试完善。

## 介绍

上一节实验中使用的 DDoS 防范脚本有很多的不足，我们需要对其进行优化。

这是最初的脚本：

```bash
#!/bin/bash
netstat -na | awk '/ESTABLISHED/{split($5,T,":");print T[1]}' | sort | grep -v -E '192.168|127.0' | uniq -c | sort -rn | head -10 | awk '{if ($2!=null && $1>4) {print $2}}' > /var/log/rejectip

for i in $(cat /var/log/rejectip)
do
    rep=$(iptables-save | grep $i)
    if [[ -z $rep ]];then
        /sbin/iptables -A INPUT -s $i -j DROP
        echo “$i kill at `date`”>>/var/log/ddos-ip
    fi
done
```

这个脚本的作用是获得排除了内部 ip 段 192.168|127.0 开头并且状态为 `ESTABLISHED` 的连接数最多的前 10 个 IP 地址并写入 `/var/log/rejectip`，通过 `for` 循环将 `rejectip` 里面的 `IP`通过 `iptables` 全部 drop 掉，然后写到日志文件 `/var/log/ddos-ip`。

需要优化的需求如下：

步骤1. 不要获得 ESTABLISHED 状态连接数最多的前10个，改为获得 ESTABLISHED 状态连接数超过 21 的所有 IP 地址（仍然需要排除内部 IP 段）来进行后续处理 步骤2. 增加一个 IP 地址白名单，白名单的文件自己创建，放在 `/tmp/goodip`，这个文件中每一行都是一个 IP 地址，如果上面那一步骤中发现的 IP 地址在白名单中，则不需要进行后续的处理 步骤3. 不要直接使用 Drop 掉所有来自经过步骤1和步骤2获得的 IP 地址的包，而是添加规则设置限制每个地址每分钟最多允许5个新连接

## 目标

1. 更新后的脚本放置在 `/home/shiyanlou/ddos.sh`
2. 按照上述要求更新脚本 `/home/shiyanlou/ddos.sh`，注意需要手动创建白名单 `/tmp/goodip` 并填入一行 IP 地址 `114.110.100.100`

## 解题

```bash
$ echo 114.110.100.100 > /tmp/goodip
$ vim ddos.sh && sudo chmod 755 ddos.sh
#!/bin/bash
netstat -na | awk '/ESTABLISHED/{split($5,T,":"); print T[1]}' | sort | grep -vE '192.168|127.0' | uniq -c | awk '{if($1 > 21 && $2!=null) print $2}' > /var/log/rejectip


for i in $(cat /var/log/rejectip)
do
    rep=$(iptables-save | grep $i)
    if [[ -z $rep ]];then
        grep $i /tmp/goodip && /sbin/iptables -A INPUT -s $i -m limit --limit 5/minute -j ACCEPT
    fi
done
```

