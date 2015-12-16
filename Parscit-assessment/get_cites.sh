#!/bin/sh

for file in test-RIAs/*.txt
do 
    Parscit-master/bin/citeExtract.pl -m extract_citations $file \
        | tee test-RIAs/${file:28:12}-cites.txt
done
