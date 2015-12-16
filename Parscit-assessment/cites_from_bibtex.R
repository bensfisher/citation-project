# R package to manipulate bibtex entries
library(RefManageR)

# Read in first 500 records (can only export 500 at a time)
bib_cites <- ReadBib("~/Dropbox/professional/Research/Active/SciInRegs_ProjectFolder/SciInRegs/Papers/Non_Scientific_Cites/analysis/WoS_scraped_scholarly_journals.bib")

# Mia:
bib_cites <- ReadBib("~/Dropbox/SciInRegs/Papers/Non_Scientific_Cites/analysis/WoS_scraped_scholarly_journals.bib")


# Convert to dat frame
bib_dat <- as.data.frame(bib_cites)

# Read in second chunk (322)
bib_cites2 <- ReadBib("~/Dropbox/professional/Research/Active/SciInRegs_ProjectFolder/SciInRegs/Papers/Non_Scientific_Cites/analysis/WoS_scraped_scholarly_journals2.bib")

# Mia:
bib_cites2 <- ReadBib("~/Dropbox/SciInRegs/Papers/Non_Scientific_Cites/analysis/WoS_scraped_scholarly_journals2.bib")

# Convert to data frame
bib_dat2 <- as.data.frame(bib_cites2)

# Find shared fields (some fields unique to just a few cites)
keep_cols <- intersect(names(bib_dat),names(bib_dat2))

# Combine datasets
bib_dat <- rbind(bib_dat[,keep_cols],bib_dat2[,keep_cols])

# Remove curly braces from doi
bib_dat$doi <- gsub("\\{|\\}", "",bib_dat$doi)

# Read in citation data
new_cites <- read.csv("~/Dropbox/professional/Research/Active/SciInRegs_ProjectFolder/SciInRegs/Papers/Non_Scientific_Cites/analysis/Citations_CLEAN.csv",stringsAsFactors=F)

# Mia:
new_cites <- read.csv("~/Dropbox/SciInRegs/Papers/Non_Scientific_Cites/analysis/Citations_CLEAN2.csv",stringsAsFactors=F)

# Remove spaces from DOIs
new_cites$DOI <- gsub(" ","",new_cites$DOI)

# Flag citation records that are in the WoS records
new_cites$in_bib_data <- is.element(new_cites$DOI,bib_dat$doi)

# write out as csv with new DOI column
write.csv(new_cites, "Citations_CLEAN2.csv", row.names=F)


