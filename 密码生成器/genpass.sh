#!/bin/bash

i=1;while true
do

    pw=`head -c 700 /dev/urandom | tr -dc a-zA-Z0-9'[:punct:]' \
       | sed -r 's/[^0-9a-zA-Z><+\-\{\}\:.&;]//g' | sed 's/\\\\//g' \
       | cut -c $1-$((i+12))` 
 #   echo r:$pw
   echo $pw | \
        grep -E '[0-9]+' \
       | grep -E '[a-z]+' \
       | grep -E '[A-Z]+' \
       | grep -E '[><\+\-\{\}\&;]+' > /dev/null
   if [ $? -eq 0 ];then
        break
   fi

done
echo $pw
