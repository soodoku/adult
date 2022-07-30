"

Predicting PID

1. Limit yourself to political domains + sociodem. categorized in same way as comScore (see data/cs)
2. Aggregate domain level visitation up to person level
3. PID_3 ~ agg_domain + sociodem.

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

visits <- select(wakoopa, pmxid, pid3, domain, category, subcategory, mail, fb) %>%
            filter(category != "Adult") %>%
            filter(subcategory != "Benefits/Points") %>%
            filter(mail == 0 & fb == 0) # cuts down 6.3 --> 3 million URLs!

rm(wakoopa)

#visit_domain <- select(visits, pmxid, pid3, domain) %>%
#                  distinct(domain) # 8339 unique domains

visit_domain_id <- select(visits, pmxid, domain) %>%
                  group_by(pmxid, domain) %>%
                  summarize(numvisits = n())

visit_domain_id <- filter(visit_domain_id, numvisits <= 100)

## Save file OR LOAD [*]
setwd("data/yg/predict_pid")
#save(visit_domain_id, file = "visits.RData")
load("visits.RData")

head(visit_domain_id)
table(visit_domain_id$pid3)
table(visit_domain_id$dem, useNA = "always")
length(unique(visit_domain_id$pmxid)) # 1385

## Generate dummies for each URL --> these are the features for prediction

dom_dummies <- dummyVars(~ domain, data = visit_domain_id)
x <- predict(dom_dummies, newdata = visit_domain_id) # matrix
domains <- gsub("domain", "", colnames(x))
dim(x)
x[1,1:10]
head(domains)

## aggregate by pmxid
x <- as.data.frame(x)
x$pmxid <- visit_domain_id$pmxid
visits_agg <- sapply(unique(visit_domain_id$pmxid), function(i) colSums(x[which(visit_domain_id$pmxid == i), 1:5622])) # 5718
visits_agg <- as.data.frame(t(visits_agg))
visits_agg$pmxid <- unique(visit_domain_id$pmxid)

## Merge back PID
visits_agg <- merge(visits_agg, indiv[, c("pmxid", "pid3", "gender", "educ", "income", "age", "race5")], by = "pmxid", all.x = TRUE)
visits_agg$dem <- as.numeric(visits_agg$pid3 == "dem")
visits_agg$rep <- as.numeric(visits_agg$pid3 == "rep")
visits_agg$ind <- as.numeric(visits_agg$pid3 == "ind")

visits_agg <- na.omit(visits_agg) #na.omit(indiv[, c("pmxid", "pid3", "gender", "educ", "income", "age", "race5")])

y <- as.numeric(visits_agg$pid3 == "dem")
y <- as.numeric(visits_agg$pid3 == "rep")
y <- as.numeric(visits_agg$pid3 == "ind")
x <- as.matrix(visits_agg[, 2:5623]) # 5719

demos <- visits_agg[, 5625:5629] #5721:5725
table(demos$educ)
demos$educ <- as.numeric(factor(demos$educ, levels = c("no hs", "hs grad", "some col", "col grad", "post grad")))
table(demos$income)
demos$income <- as.numeric(factor(demos$income, levels = names(table(demos$income))[c(1,4,5,6,7,3,2)]))
table(demos$age)
demos$age <- as.numeric(factor(demos$age))
x <- cbind(x, as.matrix(demos[, 2:4]))
table(demos$race5)
demos$white <- ifelse(demos$race5 == "white", 1, 0)
demos$black <- ifelse(demos$race5 == "black", 1, 0)
demos$hisp <- ifelse(demos$race5 == "hispanic", 1, 0)
demos$asian <- ifelse(demos$race5 == "asian", 1, 0)
table(demos$gender)
demos$male <- ifelse(demos$gender == "male", 1, 0)
x <- cbind(x, as.matrix(demos[, 6:10]))
dim(x)

## Convert x to sparse matrix (reduces ~6GB -> 6MB!)

# X <- sparse.model.matrix(~ x[,1] - 1)
# for (i in 2:ncol(x)) {
#     X2 <- sparse.model.matrix(~ x[,i] - 1)
#     X <- cBind(X, X2)
# }
# rm(x, X2)

## Ridge regression -- 1/0 Dem

#table(y, useNA = "always")
y <- ifelse(is.na(y), 0, y)
#x <- na.omit(x)

set.seed(9382)
pid_predict <- cv.glmnet(x, as.factor(y), family = "binomial", alpha = 0, type.logistic = "modified.Newton") #, standardize = FALSE)
summary(pid_predict)
dim(coef(pid_predict))
head(coef(pid_predict))

# grab coefs, reverse order
coefs <- cbind(c(domains, "educ", "inc", "age", names(demos)[6:10]), coef(pid_predict)[-1])
coefs <- coefs[order(as.numeric(coefs[,2]), decreasing = TRUE),]
head(coefs, 50); tail(coefs, 50)

# make predictions
preds <- predict(pid_predict, x, s = "lambda.min", type = "response")
#pid.preds <- predict(pid_predict, x, type = "class")
head(preds)
hist(preds); range(preds)
indiv[which(indiv$pmxid %in% visits_agg$pmxid[which(preds > 0.5)]),]$pid3
#table(pid.preds)

# summarize accuracy
rmse <- mean((y - preds)^2)
print(rmse) # 0.146


## Ridge regression -- multiclass
# http://stats.stackexchange.com/questions/21343/extending-2-class-models-to-multi-class-problems

# y is respondent-level pid
y <- indiv[which(indiv$pmxid %in% visits_agg$pmxid),]$pid3
head(y)
#table(y, useNA = "always")
y <- ifelse(!y %in% c("dem", "ind", "rep"), "ind", y) # set other categories to "ind"

set.seed(9382)
#pid_predict <- cv.glmnet(X, as.factor(y), family = "multinomial", alpha = 0) #, type.logistic = "modified.Newton") #, standardize = FALSE)
pid_predict <- cv.glmnet(x, as.factor(y), family = "multinomial", alpha = 0) #, type.logistic = "modified.Newton") #, standardize = FALSE)
summary(pid_predict)
str(coef(pid_predict))
dim(coef(pid_predict)$dem)

# grab coefs, reverse order (dem)
coefs <- cbind(c(domains, "educ", "inc", "age", names(demos)[6:10]), coef(pid_predict)$dem[-1])
coefs <- coefs[order(as.numeric(coefs[,2]), decreasing = TRUE),]
head(coefs, 50); tail(coefs, 50)

# grab coefs, reverse order (rep)
coefs <- cbind(c(domains, "educ", "inc", "age", names(demos)[6:10]), coef(pid_predict)$rep[-1])
coefs <- coefs[order(as.numeric(coefs[,2]), decreasing = TRUE),]
head(coefs, 50); tail(coefs, 50)

# make predictions
preds <- predict(pid_predict, x, s = "lambda.min", type = "response")
#pid.preds <- predict(pid_predict, x, type = "class")
table(preds)

head(as.data.frame(preds))
preds <- as.data.frame(preds)
names(preds) <- c("dem", "ind", "rep")

pid <- NA
pid <- with(preds, ifelse(dem > ind & dem > rep, "dem", NA))
pid <- with(preds, ifelse(rep > ind & rep > dem, "rep", pid))
pid <- with(preds, ifelse(dem < ind & ind > rep, "ind", pid))
table(pid)
table(y)

# summarize accuracy
#rmse <- mean((y - preds)^2)
#print(rmse) # 0.2335971




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
