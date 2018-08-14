# 挑战：Bash 实现网络单位换算器

## 介绍

在 Linux 中系统将很多数据实时更新在 `/proc` 下的一些文件文件中，这些数据并不是很直观，看起来不够人性化，需要实现一个单位转换器，能够帮助我们在满 1024 的时候便转换成较为直观的单位。

我们希望实现的单位转换器 `Conversion.sh` 里面主要是一个单位转换的函数，只要满 1024 就转换单位，直到 GB 单位，若还是满 1024 则可以不用转。

例如转换 1024 时：

```shell
bash /home/shiyanlou/Conversion.sh 1024
1 KB
```

例如转换 1099511627776 时：

```shell
bash /home/shiyanlou/Conversion.sh 1099511627776
1024 GB
```

脚本名称为 `Conversion.sh`，可以使用 source 之后调用其中的 Convert 函数，使用方式及预期输出如下：

```shell
$ source /home/shiyanlou/Conversion.sh 
$ Convert 1024
1 KB
```

## 目标

1. 脚本路径必须放在 `/home/shiyanlou/Conversion.sh`
2. 该函数能够将单位转换成合理的单位，例如 1024 Bytes 转换成 1 KB，3221225472 Bytes 转换成 3 GB。
3. 换算出来的结果中只需要包含 `B KB MB GB` 中的一种，另外输出为整数即可，比如 31.54 GB，那么只需要显示 `31 GB` 即可。
4. 能够在子进程中调用脚本中的核心函数 Convert

## 提示语

1. export 导出函数

## 解题

```shell
#!/bin/bash

unit="B KB MB GB"
unit_c=$(echo $unit | wc -w)
Convert(){
    if [ $# -ne 0 ];then
        if [[ $1 =~ ^[0-9]+$ ]];then
            let dv
            local ut
            for i in $(seq 1 $unit_c)
            do 
                  let n=$i-1
                  dnum=$((1024**n))
                  dv=$(($1/dnum))
                  if [ $dv -lt 1024 ];then
                      ut=$(echo $unit | cut -d " " -f $i) 
                        break
                  else
                        ut=$(echo $unit | cut -d " " -f $i)
                        continue
                  fi
            done
            echo "$dv $ut"
        fi  
    fi
}

Convert $*
export -f Convert

## $1 =~ ^[0-9]+$ 判断正整数
##通过wc -w 来获取单位unit总数
##用cut -d -f的方法取出需要的单位unit="B KB MB GB"
##思路：将传入的数字，以最小单位“B”起点，达到其他单位需要抵消的数，算为1份。如：达到KB需要1024**1，MB 1024**2 ...，用除法算得的份数，如果超1024就继续循环遍历，如果不够，就直接显示。


```
