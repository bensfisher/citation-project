### New Impact Factor Rating ###
rm(list=ls())

library(dplyr)
library(reshape2)

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
rm(journals08)
rm(journals09)
rm(journals10)
rm(journals11)
rm(journals12)
journals = select(journals, Full.Journal.Title, Issn, Journal.Impact.Factor, X5.Year.Impact.Factor, Citable.Items, year)
colnames(journals) = c('journal','issn','impact.factor','impact.factor.5', 'articles', 'year')
journals$year = substrRight(journals$year, 2)

riac = read.csv('RIACitations.csv')
riac = filter(riac, Type=='Scholarly Journal')
riam = read.csv('RIAMeta.csv')
riam = select(riam, RIN, Release.Date)
riac = merge(riac, riam, by=c('RIN'), all.x=TRUE)
riac$counter = 1
riac$Release.Date = substrRight(as.character(riac$Release.Date), 2)
riac = select(riac, ISSN, Release.Date, counter)
colnames(riac) = c('issn','year','articles.cited')
am = melt(riac, id.vars=c('issn','year'))
riac = dcast(am, issn+year~variable, fun.aggregate=sum)

journals = merge(journals, riac, by=c('issn','year'), all.x=TRUE)
journals$articles.cited[is.na(journals$articles.cited)] = 0
journals = select(journals, issn, journal, articles, articles.cited)
journals$articles = as.numeric(as.character(journals$articles))
am = melt(journals, id.vars=c('issn','journal'))
journals = dcast(am, issn+journal~variable, fun.aggregate=sum)

journals$new.impact.factor = journals$articles.cited/journals$articles
journals = arrange(journals, desc(new.impact.factor))
journals13 = read.csv('JournalHomeGrid13.csv', skip=1)
journals13 = select(journals13, Issn, X5.Year.Impact.Factor)
colnames(journals13) = c('issn','old.impact.factor')
journals = merge(journals, journals13, by='issn', all.x=TRUE)
journals = filter(journals, old.impact.factor!='Not Available')
journals$old.impact.factor = as.numeric(as.character(journals$old.impact.factor))
journals = unique(journals)

journals = arrange(journals, desc(old.impact.factor))
journals$old.rank = seq(1, nrow(journals), 1)
journals = arrange(journals, desc(new.impact.factor))
journals$new.rank = seq(1, nrow(journals), 1)

png('~/citation-project/citation-extraction/impact_factor_scatter.png')
ggplot(journals, aes(old.impact.factor, new.impact.factor)) +
  geom_point() +
  geom_smooth(method=lm)
dev.off()
rankings = as.data.frame(cbind(journals$old.rank, journals$new.rank))

cor(rankings, method='kendall', use='pairwise')
cor(rankings[1:50,], method='kendall', use='pairwise')
