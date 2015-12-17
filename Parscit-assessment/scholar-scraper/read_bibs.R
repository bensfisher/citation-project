setwd('~/citation-project/Parscit-assessment/scholar-scraper/')
library(RefManageR)

file.list = list.files(path=".", pattern="gscholar_out")

df = data.frame()

for (i in 1:length(file.list)){
  bib_cites = ReadBib(file.list[3])
  bib_dat = as.data.frame(bib_cites)
  bib_dat = bib_dat[c(1:9)]
  df = rbind(df, bib_dat)
}

write.csv(df, "bib_frame.csv")
