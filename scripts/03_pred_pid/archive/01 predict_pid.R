# rm(list=ls(all=TRUE))

"

Predicting PID

1. Limit yourself to political domains + sociodem. categorized in same way as comScore (see data/cs)
2. Aggregate domain level visitation up to person level
3. PID_3 ~ agg_domain + sociodem.

DETAILS:




"

# Set dir
ifelse(grepl("Gaurav", getwd()), setwd(basedir), setwd("/Users/aguess/Dropbox/"))
setwd("web analysis/")

## Load packages
library(dplyr)
library(glmnet) 
library(caret)

## Load indiv-level data -- weights generated in code/yg/raking_weights.R -- raked using age, gender, race, PID, & region
indiv <- read.csv("data/yg/porn_indiv_level_weighted_2016_recode_shalla1.csv", stringsAsFactors = FALSE)
load("data/yg/wakoopa/wakoopa_fullcat.RData")


## Remove URLs for email, FB, porn

# Code for email/FB visits (Is this sufficient?)
wakoopa$mail <- (grepl("hotmail", wakoopa$url, fixed = TRUE) | grepl("mail.yahoo", wakoopa$url, fixed = TRUE) | grepl("gmail", wakoopa$url, fixed = TRUE) | grepl("mail.google", wakoopa$url, fixed = TRUE) | grepl("outlook.com", wakoopa$url, fixed = TRUE) | grepl("email.", wakoopa$url, fixed = TRUE)) * 1
wakoopa$fb <- grepl("facebook.com", wakoopa$url, fixed = TRUE) * 1
#wakoopa$deals <- (grepl("bucks", wakoopa$url, fixed = TRUE) | grepl("deals", wakoopa$url, fixed = TRUE)) * 1

# check URLs
wakoopa$url[which(head(wakoopa$mail, 10000) == 1)]
wakoopa$url[which(head(wakoopa$fb, 10000) == 1)]

# Get news_domains -- predicted political/news domains using both shalla & comScore data
news_domains <- read.csv("data/yg/predict_pid/keep_domains_shalla_cs.csv", stringsAsFactors = FALSE)
news_domains <- news_domains$x

visits <- select(wakoopa, pmxid, pid3, domain, category, subcategory, mail, fb) %>%
            filter(category != "Adult") %>%
            filter(subcategory != "Benefits/Points") %>%
            filter(mail == 0 & fb == 0)  %>% # cuts down 6.3 --> 3 million URLs!
            filter(domain %in% news_domains)

rm(wakoopa)

#visit_domain <- select(visits, pmxid, pid3, domain) %>%
#                  distinct(domain) # 8339 unique domains

visit_domain_id <- select(visits, pmxid, domain) %>%
                  group_by(pmxid, domain) %>%
                  summarize(numvisits = n()) %>%
                  ungroup() %>% group_by(pmxid) %>%
                  mutate(totvisits = sum(numvisits)) %>%  # generate prop_visits = n_visits_to_site/total_visit_to_political_sites
                  ungroup() %>% mutate(prop_visits = numvisits/totvisits)
                  
## Number of visits <= 100
visit_domain_id <- filter(visit_domain_id, numvisits <= 100)

## Save file OR LOAD [*]
setwd("data/yg/predict_pid")
#save(visit_domain_id, file = "visits.RData")
load("visits.RData")

head(visit_domain_id)
table(visit_domain_id$pid3)
table(visit_domain_id$dem, useNA = "always")
length(unique(visit_domain_id$pmxid)) # 1384

## Generate dummies for each URL --> these are the features for prediction

dom_dummies <- dummyVars(~ domain, data = visit_domain_id)
x <- predict(dom_dummies, newdata = visit_domain_id) # matrix
domains <- gsub("domain", "", colnames(x))
dim(x)
x[1,1:10]
head(domains)

## Generate data for each ID --> these are the features for prediction (using proportions)

library(reshape2) # http://seananderson.ca/2013/10/19/reshape.html

visit_melted <- melt(select(visit_domain_id, pmxid, domain, prop_visits), id.vars = c("pmxid", "domain"))
visit_wide <- dcast(visit_melted, pmxid + variable ~ domain, value.var = "value")
visit_wide[is.na(visit_wide)] <- 0
visits_agg <- visit_wide
head(visit_melted); tail(visit_melted)
head(visit_wide); tail(visit_wide)

## aggregate by pmxid

x <- as.data.frame(x)
x$pmxid <- visit_domain_id$pmxid
visits_agg <- sapply(unique(visit_domain_id$pmxid), function(i) colSums(x[which(visit_domain_id$pmxid == i), 1:165])) # 165 5622 5718
visits_agg <- as.data.frame(t(visits_agg))
visits_agg$pmxid <- unique(visit_domain_id$pmxid)

## Merge back PID, demos

visits_agg <- merge(visits_agg, indiv[, c("pmxid", "pid3", "gender", "educ", "income", "age", "race5", "ideo5")], by = "pmxid", all.x = TRUE)
visits_agg$dem <- as.numeric(visits_agg$pid3 == "dem")
visits_agg$rep <- as.numeric(visits_agg$pid3 == "rep")
visits_agg$ind <- as.numeric(visits_agg$pid3 == "ind")
#visits_agg_all <- visits_agg
#visits_agg <- visits_agg_all

y <- as.numeric(visits_agg$pid3 == "dem")
y <- as.numeric(visits_agg$pid3 == "rep")
y <- as.numeric(visits_agg$pid3 == "ind")
x <- as.matrix(visits_agg[, 2:5623]) # 5719

demos <- visits_agg[, 167:173] # 168:174 167:173 5625:5630 5721:5725
table(demos$educ)
demos$educ <- factor(demos$educ, levels = c("no hs", "hs grad", "some col", "col grad", "post grad"))
table(demos$income)
demos$income <- factor(demos$income, levels = names(table(demos$income))[c(1,4,5,6,7,3,2)])
table(demos$age)
demos$age <- factor(demos$age)
table(demos$race5)
demos$race5 <- factor(demos$race5)
table(demos$gender)
demos$gender <- factor(demos$gender)
table(demos$ideo5)
demos$ideo5 <- factor(demos$ideo5, levels = names(table(demos$ideo5))[c(6,3,4,1,5,2)])

demo_dummies <- dummyVars(~ gender + educ + age + income + race5 + ideo5, data = demos)
x <- predict(demo_dummies, newdata = demos) # matrix
demo_x <- predict(demo_dummies, newdata = demos) # matrix
demo_names <- colnames(x)

dim(visits_agg)
names(visits_agg[, 1:2])
head(names(visits_agg[, 2:5623]))

# combine domains + demos
x <- cbind(visits_agg[, 2:166], x) # 3:167 2:166 2:5623
x <- na.omit(x)
demo_x <- na.omit(demo_x)




## Ridge regression -- 1/0 Dem (test) ## -- skip

# drop cases that had NA's in the feature matrix x
y <- y[!seq(1, length(y)) %in% as.vector(attr(x, which = "na.action"))]

set.seed(9382)
pid_predict <- cv.glmnet(as.matrix(x), as.factor(y), family = "binomial", alpha = 0, type.logistic = "modified.Newton") #, standardize = FALSE)
summary(pid_predict)
dim(coef(pid_predict))
head(coef(pid_predict))

# grab coefs, reverse order
coefs <- cbind(c(domains, demo_names), coef(pid_predict)[-1])
coefs <- coefs[order(as.numeric(coefs[,2]), decreasing = TRUE),]
tail(coef(pid_predict), 30)
head(coefs, 100); tail(coefs, 50)

# make predictions
preds <- predict(pid_predict, as.matrix(x), s = "lambda.min", type = "response")
#pid.preds <- predict(pid_predict, x, type = "class")
head(preds, 10)
indiv[head(as.numeric(rownames(preds)), 10),]
hist(preds); range(preds)

indiv[as.numeric(rownames(preds)),]$pid3[which(preds > 0.8)]

#table(pid.preds)

# summarize accuracy
rmse <- mean((y - preds)^2)
print(rmse) # 0.122





####### SCRATCH/NOTES #########

## GS call 4/18
## Shalla -- good sample of domain space
## 15% porn 2004 (comScore)

# training set
set.seed(9382)
train_ids <- sample(indiv$pmxid, 500)
trainSet <- filter(visit_domain_id, pmxid %in% train_ids)
testSet <- filter(select(visit_domain_id, -pid3), !pmxid %in% train_ids)
head(trainSet); class(trainSet$pid3)
trainSet$pid3 <- as.factor(trainSet$pid3)
trainSet$domain <- as.factor(trainSet$domain)


# F/G: substitute with mean asymmetry score - how well does that predict PID
# HOW BAD IS THE F/G heuristic?


# PID for comscore - idea is to be able to do it as well as we can
# comscore gives us URL stuff + demographics
# triangulate using YG as "training data", predict CS data with that (porn)
# 2nd use of CS: how bad Flaxman/Goel is?



## NOTES from GS
# collapse to person-level data - aggregate up
# only domains
# codebook for comscore (PID)
# features from domains: ideology (we're not exploiting)
# domains for which we have ideology - NYT.com x ideology score
# domains visited by > 100 people, drop (1-2000 domains total)
# limit to political if possible
# demos

# LIFESTYLE sites <-> PID
# ONE AGAINST ALL classifier - 2 logistic (r vs. all, ind vs. all)

# For each political site, it becomes:
# n_visits_to_site/total_visit_to_political_sites
# We can also create a column that tallies: total_visit_to_political_sites/total_visits
# Adding separate column for  total_visit_to_political_sites also makes sense. 
