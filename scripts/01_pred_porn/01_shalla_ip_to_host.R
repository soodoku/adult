"

Aim: Convert Shalla from IP/Cat to Domain/Cat
Author: Gaurav Sood

"

# Set Global Options
options(stringsAsFactors=FALSE)

# Set working dir.
setwd(basedir)
setwd("domain_classifier/")

# Load shalla data
shalla     <- read.csv("shallalist_agg.csv")

# Create a domain name level dataset
dat <- data.frame(category=NULL, hostname=NULL)

# Loop over shalla
for (i in 1:nrow(shalla)) {
    dat <- rbind(dat, cbind(category=shalla$shallalist.category[i], hostname=unlist(strsplit(shalla$shallalist.hostname[i], ","))))
}

# Only unique domain names
shalla_s  <- subset(dat, !duplicated(hostname))

# Write out the file
write.csv(shalla_s, file="shalla_cat_unique_host.csv", row.names=F)
 