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
matches = filter(matches, cite !='NO PARSCIT CITATIONS')
matches = filter(matches, cite != 'nan')
matches$partial = as.numeric(as.character(matches$partial))
matches$jac = as.numeric(as.character(matches$jac))
matches$lev = as.numeric(as.character(matches$lev))
matches$sor = as.numeric(as.character(matches$sor))
matches = na.omit(matches)
gt = filter(matches, source=='gt')
pc = filter(matches, source=='pc')

set.seed(1989)
gt.sample = gt[sample(nrow(gt), 250),]
pc.sample = pc[sample(nrow(pc), 250),]
write.csv(gt.sample, 'results/gtsample.csv', row.names=FALSE)
write.csv(pc.sample, 'results/pcsample.csv', row.names=FALSE)

gt.sample = read.csv('results/gtsample.csv')
gt.sample = na.omit(gt.sample)
gt.sample[is.na(gt.sample)] = 0

pc.sample = read.csv('results/pcsample.csv')
pc.sample = na.omit(pc.sample)

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

jac.gt.pred = prediction((1-gt.sample$jac), gt.sample$jac_check)
jac.gt.auc = performance(jac.gt.pred, measure='auc')
jac.gt.pr = performance(jac.gt.pred, 'prec', 'rec')
jac.gt.prec = jac.gt.pr@y.values[[1]]
jac.gt.prec[is.na(jac.gt.prec)] = 0
jac.gt.aupr = trapz(jac.gt.pr@x.values[[1]], jac.gt.prec)


https://www.dropbox.com/s/re8kaeywng619fs/RIAMeta.csv?dl=0