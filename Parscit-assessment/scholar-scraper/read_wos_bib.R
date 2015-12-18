setwd('~/citation-project/Parscit-assessment/scholar-scraper/')
library(RefManageR)

bib_cites = ReadBib('savedrecs-2.bib')
df = as.data.frame(bib_cites)

write.csv(df, "wos_bib_frame.csv")
