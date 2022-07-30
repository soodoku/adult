library(dplyr)

# load wakoopa data
load("wakoopa_fullcat.RData")

channels <- paste0(c("cnn", "msnbc", "foxnews", "abcnews.go", "nbc", "cbs"), ".com")

pct_white <- select(wakoopa, domain, race5, weights) %>%
                filter(domain %in% channels) %>%
                group_by(domain) %>%
                dplyr::summarize(num_white = length(which(race5 == "white")),
                                 avg_white_unweighted = num_white/n(),
                                 avg_white_weighted = weighted.mean(race5 == "white", weights, na.rm = TRUE))

setwd("~/Dropbox/issue_ideology/data/media")
write.csv(pct_white, "pctwhite_channels.csv")
