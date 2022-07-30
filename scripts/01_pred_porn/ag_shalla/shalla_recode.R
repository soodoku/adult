ifelse(grepl("Gaurav", getwd()), setwd(basedir), setwd("/Users/aguess/Dropbox/"))
setwd("web analysis/")

porn.indiv <- select(wakoopa, category, pmxid, duration, domain, used_at) %>%
  mutate(porn = ifelse(category == "Adult", 1, 0)) %>%
  group_by(pmxid) %>%
  arrange(pmxid)

# load data -- weights generated in code/yg/raking_weights.R -- raked using age, gender, race, PID, & region
indiv <- read.csv("ind_level_with_weights_2016.csv", stringsAsFactors = FALSE)

# load porn domains from Shallalist
library(readr)
shalla <- read_csv("shallalist_agg.csv")
head(shalla)
head(shalla$shallalist.hostname)

# grab labeled porn domains
shalla <- select(shalla, shallalist.category, shallalist.hostname) %>%
  filter(shallalist.category == "porn")

# DON'T RUN!
#shalla_domains <- as.vector(unlist(sapply(shalla$shallalist.hostname, function(x) strsplit(x, ","))))

# split list into separate unique domains
shalla_domains <- NULL
for(i in 1:nrow(shalla)) {
  
  tmp <- as.vector(unlist(strsplit(shalla$shallalist.hostname[i], ",")))
  shalla_domains <- c(shalla_domains, tmp)
  
}
shalla_domains <- unique(shalla_domains)
head(shalla_domains)

length(which(porn.indiv$porn == 1)) # 79045

table(porn.indiv$porn, useNA = "always")
#   0       1    <NA> 
#   4501651   79045 1738745 


# now recode individual site visits matching shalla domain list
# BEWARE: takes ~3 days to run
for(i in 1:length(shalla_domains)) {
  
  try(porn.indiv[which(porn.indiv$domain %in% shalla_domains[i]),]$porn <- 1, silent = TRUE)
  
}

table(porn.indiv$porn, useNA = "always")
#   0       1    <NA> 
#   4500520  104454 1714467 

length(which(porn.indiv$porn == 1)) # 104454

## NOW REMAKE OUTCOME MEASURES
