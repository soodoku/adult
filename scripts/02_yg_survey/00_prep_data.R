# rm(list=ls(all=TRUE))

library(dplyr)

names(indiv)
names(s)
head(s)

### 1. LOAD INDIVIDUAL-LEVEL DATA WITH WEIGHTS (see raking_weights.R) ###

ifelse(grepl("Gaurav", getwd()), setwd(basedir), setwd("/Users/aguess/Dropbox/"))
setwd("web analysis/")

porn.indiv <- select(wakoopa, category, pmxid, duration, domain, used_at) %>%
  mutate(porn = ifelse(category == "Adult", 1, 0)) %>%
  group_by(pmxid) %>%
  arrange(pmxid)

# load data -- weights generated in code/yg/raking_weights.R -- raked using age, gender, race, PID, & region
indiv <- read.csv("data/yg/indiv_level_weighted_2016.csv", stringsAsFactors = FALSE)

# load porn domains from Shallalist
shalla <- readLines("data/measure_porn/shalla_porn_list/domains.txt")
length(shalla)

#sapply(shalla, function(x) { if(length(which(porn.indiv$domain %in% x)) > 0) { porn.indiv[which(porn.indiv$domain %in% x),]$porn <- 1 }})

### 2. GENERATE DVs ###

# Visited any porn? 1/0
porn.indiv.1 <- as.vector(with(porn.indiv, tapply(porn, pmxid, function(x) max(x, na.rm = TRUE))))
porn.indiv.1 <- ifelse(porn.indiv.1 < 0, 0, porn.indiv.1)

# Number of porn sites visited
porn.indiv.n <- as.vector(with(porn.indiv, tapply(porn, pmxid, function(x) sum(x, na.rm = TRUE))))
