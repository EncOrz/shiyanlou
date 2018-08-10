#!/bin/bash

if [ $# -ne 0 ];then
        cs=$(sudo service "$1" status 2>/dev/null )
    if [[ $cs =~ "is running" ||  $cs =~ Uptime ]] 
    then
        echo is Running
    else
        if [[ $cs =~ stopped || $cs =~ "not running" ]]
        	then
            	sudo service $1 start &> /dev/null
            	echo Restarting
        else
        		echo Error: Service Not Found
   		fi
    fi
fi

