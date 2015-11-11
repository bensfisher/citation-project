### New Impact Factor Rating ###
rm(list=ls())

library(dplyr)

setwd('~/citation-project/Parscit-assessment/')

journals08 = read.csv('JournalHomeGrid08.csv', skip=1)
journals08$year = 2008
journals09 = read.csv('JournalHomeGrid09.csv', skip=1)
journals09$year = 2009
journals10 = read.csv('JournalHomeGrid10.csv', skip=1)
journals10$year = 2010
journals11 = read.csv('JournalHomeGrid11.csv', skip=1)
journals11$year = 2011
journals12 = read.csv('JournalHomeGrid12.csv', skip=1)
journals12$year = 2012

substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}

journals = rbind(journals08, journals09, journals10, journals11, journals12)
journals = select(journals, Full.Journal.Title, Issn, Journal.Impact.Factor, Citable.Items, year)
colnames(journals) = c('journal','issn','impact.factor', 'articles', 'year')
journals$year = substrRight(journals$year, 2)


riac = read.csv('RIACitations.csv')
riac = filter(riac, Type=='Scholarly Journal')
riac = select(riac, RIN, Title, Source, ISSN)
colnames(riac) = c('ria','cite','journal','issn')
riac$cite2 = gsub( "[^[:alnum:]]", "", riac$cite)
riac$cite2 = tolower(riac$cite2)

riac = merge(riac, journals, by=c(''), all.x=TRUE)
riac$cite = NULL

matches = read.table('results/matches.txt', header=TRUE, sep=':')
matches$partial = as.numeric(as.character(matches$partial))
matches$jac = as.numeric(as.character(matches$jac))
matches$lev = as.numeric(as.character(matches$lev))
matches$sor = as.numeric(as.character(matches$sor))
matches = na.omit(matches)
gt = filter(matches, source=='gt')
