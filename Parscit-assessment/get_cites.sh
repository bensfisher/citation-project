#!/bin/sh

for file in Parscit-assessment/test-RIAs/*.txt
do 
    Parscit-assessment/Parscit-master/bin/citeExtract.pl -m extract_citations $file
    tee Parscit-assessment/test-RIAs/${file:28:12}-cites.txt
done
