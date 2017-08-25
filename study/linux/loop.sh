#!/bin/bash
set j=2
while true
do
        let "j=j+1"
        echo "----------now is $j--------------"
        ping 127.0.0.1
        sleep 2
done
