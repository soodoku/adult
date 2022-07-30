rm(list=ls(all=TRUE))

library(tidyverse)

setwd("~/Dropbox/MediaChoiceModeration/data")
load("pulse_merged.RData") # full data

domains <- wakoopa %>% select(domain) %>% unique()

# setwd("")
# write_csv(domains, "web_domains.csv")
