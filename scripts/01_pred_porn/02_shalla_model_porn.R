"

General Aim: Predict Category of Content Hosted by Domain Using Shallalist data
In particular: Calibrated keyword classifier for porn
Author: Gaurav Sood

"
# Global options
options(StringsAsFactors=FALSE)

# Load libs 
library(urltools)
library(goji)
library(glmnet)

# Load the data
shalla <- read.csv("data/shalla/shalla_cat_unique_host.csv")

# Featurize for calibrated porn keywords
knotty_file <- file("data/knotty_words.txt", "r")
knotty      <- readLines(knotty_file, warn=F)
close(knotty_file)
knotty      <- unlist(strsplit(knotty, ", "))

# Let us just initialize new cols for each of the knotty words
shalla[, knotty] <- NA

for (j in knotty) {

	shalla[, j] <- grepl(j, shalla$hostname)
}

# Code for IP
#sum(grepl("^[0-9]*.[0-9]*.[0-9]*.[0-9]", shalla$hostname[shalla$cat==0]))/sum(length(shalla$hostname[shalla$cat==0]))
shalla$num <- grepl("^[0-9]*.[0-9]*.[0-9]*.[0-9]", shalla$hostname)

# Numerics
shalla[,3:length(shalla)] <- shalla[,3:length(shalla)]*1
shalla$porn_cat <- as.numeric(shalla$category=="porn")

# Code for TLDs
split_url <- suffix_extract(shalla$hostname)
shallam   <- merge(shalla, split_url, by.x="hostname", by.y="host", all.x=T, all.y=F)

shallam$subdomain <- nona(shallam$subdomain)
shallam$suffix    <- nona(shallam$suffix)

# Create dummies
unique_cats <- unique(shallam$suffix)

for(t in unique_cats) {
  shallam[, t] <- grepl(t, shallam$suffix)
}

# Take out sparse cols.
col_sums     <- colSums(shallam[, unique_cats])
dispose_cats <- unique_cats[which(unique_cats %in% names(col_sums)[col_sums <= 100])]
shallams     <- shallam[,- which(names(shallam) %in% dispose_cats)]
remain_cats  <- unique_cats[!(unique_cats %in% dispose_cats)]

# Split into train and test 
set.seed(31415)
train_samp   <- sample(nrow(shallams), nrow(shallams)*.9)
shalla_train <- shallam[train_samp, ]
shalla_test  <- shallam[-train_samp,]

# Analyze
glm_shalla <- cv.glmnet(as.matrix(shalla_train[, c(knotty, "num", remain_cats)]), shalla_train$porn_cat, alpha=1, family = "binomial", nfolds=5, type.measure="class")
pred       <- predict(glm_shalla, as.matrix(shalla_train[, c(knotty, "num", remain_cats)]), s = "lambda.min", type="response")

# In sample prediction Accuracy
table(pred > .5, shalla_train$porn_cat)
sum(diag(table(pred > .5, shalla_train$porn_cat)))/nrow(shalla_train)
# [1] 0.7961752

# Predict Out of sample 
pred       <- predict(glm_shalla, as.matrix(shalla_test[, c(knotty, "num", remain_cats)]), s = "lambda.min", type="response")
table(pred > .5, shalla_test$porn_cat)

# Accuracy
sum(diag(table(pred > .5, shalla_test$porn_cat)))/nrow(shalla_test)

