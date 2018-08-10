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
                  dnum=$((1024**$n))
                  dv=$(($1/$dnum))
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