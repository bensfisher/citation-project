#!/bin/sh

for file in Parscit-assessment/test-RIAs/*.pdf
do
    java -jar Parscit-assessment/pdfbox-app-1.8.10.jar ExtractText -encoding UTF-8 $file
done

