#!/bin/sh

value=$(<title_list.txt)
IFS=","
for v in $value
do
    echo $v
    python gscholar-master/gscholar/gscholar.py "$v"
    sleep $[( $RANDOM % 10 )+1]s # pause 1 to 10s between searches
done > gscholar_out.txt
