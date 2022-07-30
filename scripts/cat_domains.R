"

Get category of domains
"

# Load the libs 
library(data.table)
library(rdomains)
library(dplyr)

# general function

gen_cat <- function(file_name = NULL ) {

	domains          <- fread(file_name)
	domains_shalla   <- shalla_cat(domains$x)
	domains_ml1_porn <- adult_ml1_cat(domains$x)

	# Join 
	domains_cat      <- inner_join(domains_shalla, domains_ml1_porn)
	domains_cat
}

# 2002
# ---------------------
cs2002_cat <- gen_cat("cs2002_unique_domains")
write.csv(cs2002_cat, file="cs2002_unique_domains_shalla_ml1_porn.csv", row.names=F)

cs2004_cat <- gen_cat("cs2004_unique_domains")
write.csv(cs2004_cat, file="cs2004_unique_domains_shalla_ml1_porn.csv", row.names=F)

cs2008_cat <- gen_cat("cs2008_unique_domains")
write.csv(cs2008_cat, file="cs2008_unique_domains_shalla_ml1_porn.csv", row.names=F)

cs2009_cat <- gen_cat("cs2009_unique_domains")
write.csv(cs2009_cat, file="cs2009_unique_domains_shalla_ml1_porn.csv", row.names=F)

cs2010_cat <- gen_cat("cs2010_unique_domains")
write.csv(cs2010_cat, file="cs2010_unique_domains_shalla_ml1_porn.csv", row.names=F)

cs2011_cat <- gen_cat("cs2011_unique_domains")
write.csv(cs2011_cat, file="cs2011_unique_domains_shalla_ml1_porn.csv", row.names=F)

cs2012_cat <- gen_cat("cs2012_unique_domains")
write.csv(cs2012_cat, file="cs2012_unique_domains_shalla_ml1_porn.csv", row.names=F)

cs2013_cat <- gen_cat("cs2013_unique_domains")
write.csv(cs2013_cat, file="cs2013_unique_domains_shalla_ml1_porn.csv", row.names=F)
