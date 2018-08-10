#!/bin/bash
if [ $# -ne 0 ];then
        if [ -f $1 ];then
                sed s/\)/\)\\n/g $1 | grep -o '\[.*\]\(.*\)' | grep -vE '\.jpg|\.png|\.gif' | awk -F '[\[\]\(\)]+' '{print $2" "$3}'
        fi
fi