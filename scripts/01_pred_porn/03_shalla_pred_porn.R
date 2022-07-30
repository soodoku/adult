"

Aim: 
Predict YG Domains using saved model
Author: Gaurav Sood

"

# Load libs 
# devtools::install_github("soodoku/domain_classifier/rdomains")
# devtools::install_github("soodoku/goji")

library(goji)
library(rdomains)

# Set dir
ifelse(grepl("Gaurav", getwd()), setwd(basedir), setwd("/Users/aguess/Dropbox/"))
setwd("web_analysis/")

# YG Dat
# -----------------
# Load YG Data
load("data/yg/unique_domains/unique_domains.Rdata")

# Get ML cat
ml_cat <- name_suffix_cat(unique.domains)
ml_cat$ml_porn <- (ml_cat$category > .5)*1

# Get shalla cat
sh_cat <-  shalla_cat(unique.domains)
sh_cat$shalla_porn <- (sh_cat$shalla_category == "porn")*1
sh_cat$shalla_porn <- nona(sh_cat$shalla_porn)

# Add shalla cat
ml_cat$shalla_porn <- sh_cat$shalla_porn[match(ml_cat$domain_name, sh_cat$domain_name)]

# Subset
ml_cat <- subset(ml_cat, select=c("domains", "ml_porn", "shalla_porn")) 

write.csv(ml_cat, file="data/yg/unique_domains/unique_domains_category_shalla_ml.csv", row.names=F)

# ComScore 2013
# ---------------------

# Load YG Data
load("data/comscore/unique_domains/cs13_unique_domain_names.rda")

# Get ML cat
#ml_cat <- name_suffix_cat(cs13_unique_domain_names)
#ml_cat$ml_porn <- (ml_cat$category > .5)*1

# Get shalla cat
sh_cat <-  shalla_cat(cs13_unique_domain_names)
sh_cat$shalla_porn <- (sh_cat$shalla_category == "porn")*1
sh_cat$shalla_porn <- nona(sh_cat$shalla_porn)

# Add shalla cat
#ml_cat$shalla_porn <- sh_cat$shalla_porn[match(ml_cat$domains, sh_cat$domain_name)]

# Subset
#ml_cat <- subset(ml_cat, select=c("domains", "ml_porn", "shalla_porn")) 

write.csv(sh_cat, file="data/comscore/unique_domains/cs13_unique_domains_category_shalla_ml.csv", row.names=F)

# ComScore 2012
# ---------------------

# Load YG Data
load("data/comscore/unique_domains/cs12_unique_domain_names.rda")

# Get ML cat
#ml_cat <- name_suffix_cat(cs13_unique_domain_names)
#ml_cat$ml_porn <- (ml_cat$category > .5)*1

# Get shalla cat
sh_cat <-  shalla_cat(cs13_unique_domain_names)
sh_cat$shalla_porn <- (sh_cat$shalla_category == "porn")*1
sh_cat$shalla_porn <- nona(sh_cat$shalla_porn)

# Add shalla cat
#ml_cat$shalla_porn <- sh_cat$shalla_porn[match(ml_cat$domains, sh_cat$domain_name)]

# Subset
#ml_cat <- subset(ml_cat, select=c("domains", "ml_porn", "shalla_porn")) 

write.csv(sh_cat, file="data/comscore/unique_domains/cs12_unique_domains_category_shalla_ml.csv", row.names=F)



