#!/bin/sh

value=$(<test_titles.txt)
IFS=","
for v in $value
do
    python gscholar-master/gscholar/gscholar.py "$v"
    sleep $[( $RANDOM % 10 )+1]s
done > gscholar_out.txt
