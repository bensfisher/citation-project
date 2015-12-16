#!/bin/sh

value=$(<scholar-scraper/temp.txt)
IFS=","
for v in $value
do
    python scholar-scraper/gscholar-master/gscholar/gscholar.py "$v"
    sleep $[( $RANDOM % 10 )+1]s # pause 1 to 10s between searches
done > scholar-scraper/gscholar_out10.bib
