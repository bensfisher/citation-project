setwd('~/citation-project/Parscit-assessment/scholar-scraper/')
library(RefManageR)

file.list = list.files(path=".", pattern=".bib")

df = data.frame()

for (i in 1:length(file.list)){
  bib_cites = ReadBib(file.list[i])
  bib_dat = as.data.frame(bib_cites)
  df = rbind(df, bib_dat)
}

write.csv(df, "bib_frame.csv")
