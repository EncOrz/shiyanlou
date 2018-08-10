#!/bin/bash

if [ $# -ne 0 ];then
        echo $* | grep -E '\-f|\-rf|\-fr' &> /dev/null
        if [ $? == 0 ];then
                for v in $*
				do
                        if [[ ! $v =~ '-' ]]
						then
                                mv -f $v /tmp/trash/
                        fi
                done
        else
                /bin/rm $*
        fi
else
        /bin/rm
fi