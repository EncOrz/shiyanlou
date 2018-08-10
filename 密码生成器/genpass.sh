#!/bin/bash
        w=`head -c 100 /dev/urandom | tr -dc a-z0-9A-Z | cut -c 2-11`
        p=`echo '><+-{}:.&;' | cut -c $[$RANDOM%10+1]`
        pp=`echo '><+-{}:.&;' | cut -c $[RANDOM%10+1]`
echo $p$w$pp