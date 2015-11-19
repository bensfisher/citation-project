############################
## ParsCit Assesment ######
## Last updated: 10/20/15 ##
############################

rm(list=ls())
library(caTools)
library(dplyr)
library(reshape2)
library(ROCR)
setwd('~/citation-project/Parscit-assessment/')

matches = read.table('results/matches.txt', header=TRUE, sep=':')
matches$partial = as.numeric(as.character(matches$partial))
matches$jac = as.numeric(as.character(matches$jac))
matches$lev = as.numeric(as.character(matches$lev))
matches$sor = as.numeric(as.character(matches$sor))
matches = na.omit(matches)
gt = filter(matches, source=='gt')
pc = filter(matches, source=='pc')

gt.sample = read.csv('results/gtsample.csv')
gt.sample[is.na(gt.sample)] = 0

pc.sample = read.csv('results/pcsample.csv')
pc.sample[is.na(pc.sample)] = 0

sum(gt.sample$jac_check)
sum(gt.sample$lev_check)
sum(gt.sample$sor_check)
sum(gt.sample$partial_check)

sum(pc.sample$jac_check)
sum(pc.sample$lev_check)
sum(pc.sample$sor_chck)
sum(pc.sample$partial_check)

types = select(gt.sample, partial_check, type)
types$total = 1
types = melt(types, id.vars=c('type'))
types = dcast(types, type~variable, fun.aggregate=sum)

partial.gt.pred = prediction((1-gt.sample$partial), gt.sample$partial_check)
partial.gt.auc = performance(partial.gt.pred, measure='auc')@y.values[[1]]
partial.gt.roc = performance(partial.gt.pred, 'tpr', 'fpr')

jac.gt.pred = prediction((1-gt.sample$jac), gt.sample$jac_check)
jac.gt.auc = performance(jac.gt.pred, measure='auc')@y.values[[1]]
jac.gt.roc = performance(jac.gt.pred, 'tpr', 'fpr')

lev.gt.pred = prediction((1-gt.sample$lev), gt.sample$lev_check)
lev.gt.auc = performance(lev.gt.pred, measure='auc')@y.values[[1]]
lev.gt.roc = performance(lev.gt.pred, 'tpr', 'fpr')

sor.gt.pred = prediction((1-gt.sample$sor), gt.sample$sor_check)
sor.gt.auc = performance(sor.gt.pred, measure='auc')@y.values[[1]]
sor.gt.roc = performance(sor.gt.pred, 'tpr', 'fpr')

png('roc_curves.png')
plot(partial.gt.roc, col=1, lwd=1, ylim=c(0,1))
plot(jac.gt.roc, col=2, lwd=1, add=TRUE)
plot(lev.gt.roc, col=3, lwd=1, add=TRUE)
plot(sor.gt.roc, col=4, lwd=1, add=TRUE)
legend(.4,.5, c(paste('Partial AUC =', round(partial.gt.auc, digits=2)), 
                paste('Jaccard AUC =', round(jac.gt.auc, digits=2)),
                paste('Levenshtein AUC =', round(lev.gt.auc, digits=2)),
                paste('Sorenson AUC =', round(sor.gt.auc, digits=2))), lwd=rep(2,1), col = c(1,2,3,4))
dev.off()


cutoffs = data.frame(cut=lev.gt.roc@alpha.values[[1]], sens=lev.gt.roc@y.values[[1]],
                     spec=(1-lev.gt.roc@x.values[[1]]))
cutoffs$sum = cutoffs$sens + cutoffs$spec
cutoffs = arrange(cutoffs, desc(sum))
best = 1 - cutoffs[1,1]

gt$check = 0
gt$check[gt$lev<=best] = 1
sum(gt$check)/length(gt$check)
gt.types = select(gt, type, check)
gt.types$total = 1
gt.types = melt(gt.types, id.vars='type')
gt.types = dcast(gt.types, type~variable, fun.aggregate=sum)

ria.meta = read.csv('RIAMeta.csv')
ria.meta = select(ria.meta, RIN, Bibliography)
colnames(ria.meta) = c('ria','bibliography')
gt = merge(gt, ria.meta, by='ria',all.x=TRUE)

gt.bib = select(gt, bibliography, check)
gt.bib$total = 1
gt.bib = melt(gt.bib, id.vars='bibliography')
gt.bib = dcast(gt.bib, bibliography~variable, fun.aggregate=sum)
gt.bib

gt.bib = filter(gt, bibliography=='yes' | bibliography=='Yes' | bibliography == 'References Cited')
gt.bib = select(gt.bib, type, check)
gt.bib$total = 1
gt.bib = melt(gt.bib, id.vars='type')
gt.bib = dcast(gt.bib, type~variable, fun.aggregate=sum)
gt.bib

## check over time ##
meta = read.csv('RIAMeta.csv')
meta = select(meta, RIN, Release.Date)
colnames(meta) = c('ria','date')
meta$date = as.character(meta$date)
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}
meta$year = substrRight(meta$date, 2)
meta$date = NULL

gt.year = merge(gt, meta, by=c('ria'), all.x=TRUE)
gt.year = select(gt.year, year, type, check)
gt.year = filter(gt.year, year=='08' | year=='09' | year=='10' | year=='11' | year=='12')
schol = filter(gt.year, type=='Scholarly Journal')

png('scholarly_totals.png')
ggplot(schol, aes(year)) +
  geom_bar()
dev.off()

gt.year$total = 1
gt.year = melt(gt.year, id.vars=c('year','type'))
gt.year = dcast(gt.year, year+type~variable, fun.aggregate=sum)
gt.year$accuracy = gt.year$check/gt.year$total
acc = select(gt.year, year, accuracy)
acc = melt(acc, id.vars=c('year'))
acc = dcast(acc, year~variable, fun.aggregate=mean)

png('yearly_accuracy.png')
qplot(year, accuracy, data=acc) + ylim(0,1)
dev.off()

schol = filter(gt.year, type=="Scholarly Journal")

png('scholarly_accuracy.png')
qplot(year, accuracy, data=schol) + ylim(0,1)
dev.off()

## impact factor ##
impf = read.csv('JournalHomeGrid.csv')
impf = select(impf, Full.Journal.Title, Journal.Impact.Factor)
colnames(impf) = c('journal','impact')
impf$journal = gsub( "[^[:alnum:]]", "", impf$journal)
impf$journal = tolower(impf$journal)
riac = read.csv('RIACitations.csv')
riac = filter(riac, Type=='Scholarly Journal')
riac = select(riac, RIN, Title, Source)
colnames(riac) = c('ria','cite','journal')
riac$cite2 = gsub( "[^[:alnum:]]", "", riac$cite)
riac$cite2 = tolower(riac$cite2)
riac$journal = gsub( "[^[:alnum:]]", "", riac$journal)
riac$journal = tolower(riac$journal)
riac = merge(riac, impf, by=c('journal'), all.x=TRUE)
riac$cite = NULL

gt$cite2 = gsub( "[^[:alnum:]]", "", gt$cite)
gt$cite2 = tolower(gt$cite2)
gt.imp = filter(gt, type=='Scholarly Journal')
gt.imp = merge(gt.imp, riac, by=c('ria','cite2'), all.x=TRUE)

gt.imp$impact = as.numeric(as.character(gt.imp$impact))
summary(gt.imp$impact)
summary(filter(gt.imp, check==1)$impact)
summary(filter(gt.imp, check==0)$impact)
summary(filter(gt.imp, bibliography=='No' | bibliography=='no')$impact)
summary(filter(gt.imp, bibliography!='No' | bibliography!='no')$impact)

impplt.all = select(gt.imp, journal, impact)
impplt.all$count = 1 
impplt.all = melt(impplt.all, id.vars=c('journal','impact'))
impplt.all = dcast(impplt.all, journal+impact~variable, fun.aggregate=sum)
impplt.all = arrange(impplt.all, desc(count))
head(impplt.all, 10)

impplt.pc = filter(gt.imp, check==1)
impplt.pc = select(impplt.pc, journal, impact)
impplt.pc$count = 1 
impplt.pc = melt(impplt.pc, id.vars=c('journal','impact'))
impplt.pc = dcast(impplt.pc, journal+impact~variable, fun.aggregate=sum)
impplt.pc = arrange(impplt.pc, desc(count))
head(impplt.pc, 10)



impplt = as.data.frame(cbind(gt.imp$impact, filter(gt.imp, check==1)$impact, filter(gt.imp, check==0)$impact,
                             filter(gt.imp, bibliography=='No' | bibliography=='no')$impact,
                             filter(gt.imp, bibliography!='No' | bibliography!='no')$impact))
colnames(impplt) = c('All','Found','Not Found','Bibliography','No Bibliography')
impplt = melt(impplt)
colnames(impplt) = c('Sample','Impact.Factor')
png('~/citation-project/citation-extraction/impacts.png')
ggplot(impplt, aes(Sample, Impact.Factor)) +
  geom_boxplot(colour = "#3366FF")
dev.off()

####
riac = read.csv('RIACitations.csv')
riac = filter(riac, Type=='Scholarly Journal')
riam = read.csv('RIAMeta.csv')
riam = select(riam, RIN, Release.Date)
riac = merge(riac, riam, by=c('RIN'), all.x=TRUE)
riac$counter = 1
riac$Release.Date = substrRight(as.character(riac$Release.Date), 2)
riac = select(riac, ISSN, counter)
colnames(riac) = c('issn','articles.cited')
am = melt(riac, id.vars=c('issn'))
riac = dcast(am, issn~variable, fun.aggregate=sum)

riac2 = read.csv('RIACitations.csv')
riac2 = filter(riac2, Type=='Scholarly Journal')
riac2 = select(riac2, RIN, Title, Source, ISSN)
colnames(riac2) = c('ria','cite','journal', 'issn')
riac2$cite2 = gsub( "[^[:alnum:]]", "", riac2$cite)
riac2$cite2 = tolower(riac2$cite2)

gt$cite2 = gsub( "[^[:alnum:]]", "", gt$cite)
gt$cite2 = tolower(gt$cite2)
imp = filter(gt, type=='Scholarly Journal')
imp = merge(imp, riac2, by=c('ria','cite2'), all.x=TRUE)
imp$counter = 1


gt.imp = imp
gt.imp = select(gt.imp, issn, counter)
gt.imp = melt(gt.imp, id.vars='issn')
gt.imp = dcast(gt.imp, issn~variable, fun.aggregate=sum)
colnames(gt.imp) = c('issn','gt.cites')

pc.imp = filter(imp, check==1)
pc.imp = select(pc.imp, issn, counter)
pc.imp = melt(pc.imp, id.vars='issn')
pc.imp = dcast(pc.imp, issn~variable, fun.aggregate=sum)
colnames(pc.imp) = c('issn','pc.cites')

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

journals = rbind(journals08, journals09, journals10, journals11, journals12)
rm(journals08)
rm(journals09)
rm(journals10)
rm(journals11)
rm(journals12)
journals = select(journals, Issn, Citable.Items)
colnames(journals) = c('issn','articles')
journals$articles = as.numeric(as.character(journals$articles))
journals = melt(journals, id.vars='issn')
journals = dcast(journals, issn~variable, fun.aggregate=sum)

journals = merge(journals, gt.imp, by='issn', all.x=TRUE)
journals = merge(journals, pc.imp, by='issn', all.x=TRUE)
journals$gt.cites[is.na(journals$gt.cites)] = 0
journals$pc.cites[is.na(journals$pc.cites)] = 0
journals$gt.imp = journals$gt.cites/journals$articles
journals$pc.imp = journals$pc.cites/journals$articles
journals = filter(journals, gt.imp>0)

journals = arrange(journals, desc(gt.imp))
journals$gt.rank = seq(1, nrow(journals), 1)
journals = arrange(journals, desc(pc.imp))
journals$pc.rank = seq(1, nrow(journals), 1)

png('~/citation-project/citation-extraction/impact_factor_scatter2.png')
ggplot(journals, aes(gt.imp, pc.imp)) +
  geom_point() +
  geom_smooth(method=lm)
dev.off()

png('~/citation-project/citation-extraction/rankings_scatter.png')
ggplot(journals, aes(gt.rank, pc.rank)) +
  geom_point() +
  geom_smooth(method=lm)
dev.off()

rankings = as.data.frame(cbind(journals$gt.rank, journals$pc.rank))

cor(rankings, method='kendall', use='pairwise')
