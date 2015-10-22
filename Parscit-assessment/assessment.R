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
partial.gt.auc = performance(partial.gt.pred, measure='auc')
partial.gt.roc = performance(partial.gt.pred, 'tpr', 'fpr')
partial.gt.pr = performance(partial.gt.pred, 'prec', 'rec')

cutoffs = data.frame(cut=partial.gt.roc@alpha.values[[1]], sens=partial.gt.roc@y.values[[1]],
                     spec=(1-partial.gt.roc@x.values[[1]]))
cutoffs$sum = cutoffs$sens + cutoffs$spec
cutoffs = arrange(cutoffs, desc(sum))
best = 1 - cutoffs[1,1]

gt$check = 0
gt$check[gt$partial<=best] = 1
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
