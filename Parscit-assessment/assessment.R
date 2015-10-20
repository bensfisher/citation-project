############################
## ParsCit Assesment ######
## Last updated: 10/20/15 ##
############################

rm(list=ls())
library(dplyr)
setwd('~/citation-project/Parscit-assessment/')

matches = read.table('results/matches.txt', header=TRUE, sep=':', fill=TRUE)
matches = filter(matches, cite !='NO PARSCIT CITATIONS')
matches = filter(matches, cite != 'nan')
matches$partial = as.numeric(as.character(matches$partial))
matches$jac = as.numeric(as.character(matches$jac))
matches$lev = as.numeric(as.character(matches$lev))
matches$sor = as.numeric(as.character(matches$sor))
matches = na.omit(matches)
gt = filter(matches, type=='gt')
pc = filter(matches, type=='pc')

mean(gt$partial)
mean(gt$lev)
mean(gt$jac)
mean(gt$sor)

mean(pc$partial)
mean(pc$lev)
mean(pc$jac)
mean(pc$sor)

nrow(filter(gt, partial<=.25))
nrow(filter(gt, jac<=.25))
nrow(filter(gt, lev<=.25))
nrow(filter(gt, sor<=.25))

nrow(filter(pc, partial<=.25))
nrow(filter(pc, jac<=.25))
nrow(filter(pc, lev<=.25))
nrow(filter(pc, sor<=.25))
