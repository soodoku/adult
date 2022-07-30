## Ridge regression -- multiclass dem/rep/ind ##

# run 01 predict_pid.R first
# need x of features and visits_agg from 01 predict_pid.R

library(glmnet) 
library(caret)

setwd("data/yg/predict_pid")
load("web_classify_nofilter.RData")
load("web_classify_filter.RData")
load("web_classify_nofilter_props.RData")
load("web_classify_filter_props.RData")

# y is respondent-level pid
y <- visits_agg$pid3
y <- y[!seq(1, length(y)) %in% as.vector(attr(x, which = "na.action"))]
y <- ifelse(!y %in% c("dem", "ind", "rep"), "ind", y) # set other categories to "ind"

## OUT OF SAMPLE (test set)

train_set <- createDataPartition(y, p = 0.8, list = FALSE)
train_predictors <- x[train_set,]
test_predictors <- x[-train_set,]
train_classes <- y[train_set]
test_classes <- y[-train_set]

set.seed(9382)
glmnet_grid <- expand.grid(alpha = c(0,  .5, 1), # c(0,  .1,  .2, .4, .6, .8, 1)
                           lambda = seq(.01, .2, length = 10))
glmnet_ctrl <- trainControl(method = "cv", number = 10)
glmnet_fit <- train(train_classes ~ ., data = train_predictors,
                    method = "glmnet",
                    #preProcess = c("center", "scale"),
                    tuneGrid = glmnet_grid,
                    trControl = glmnet_ctrl)

glmnet_fit
plot(glmnet_fit)
saveRDS(glmnet_fit, "glmnet_trainmodel_nofilter.rds")
saveRDS(glmnet_fit, "glmnet_trainmodel_filter.rds")
saveRDS(glmnet_fit, "glmnet_trainmodel_nofilter_props.rds")
saveRDS(glmnet_fit, "glmnet_trainmodel_filter_props.rds")
saveRDS(glmnet_fit, "glmnet_trainmodel_justvisits_nofilter_counts.rds")

pred_classes <- predict(glmnet_fit, newdata = test_predictors)
table(pred_classes)
length(which(pred_classes == test_classes))/length(test_classes) # 0.576 out of sample for nofilter, 0.584 for filter
# .567 for filter with proportions
# 0.556 for no filter with props
# 0.407 for just visits







## predicting within sample ##

set.seed(9382)
pid_predict <- cv.glmnet(as.matrix(x), as.factor(y), family = "multinomial", alpha = 0) #, type.logistic = "modified.Newton") #, standardize = FALSE)
summary(pid_predict)
str(coef(pid_predict))
dim(coef(pid_predict)$dem)

# grab coefs, reverse order (dem)
coefs <- cbind(c(domains, demo_names), coef(pid_predict)$dem[-1])
coefs <- coefs[order(as.numeric(coefs[,2]), decreasing = TRUE),]
head(coefs, 50); tail(coefs, 50)

# grab coefs, reverse order (rep)
coefs <- cbind(c(domains, demo_names), coef(pid_predict)$rep[-1])
coefs <- coefs[order(as.numeric(coefs[,2]), decreasing = TRUE),]
head(coefs, 50); tail(coefs, 50)

# make predictions -- use cross-validated lambda
preds <- predict(pid_predict, as.matrix(x), s = "lambda.min", type = "response")
#pid.preds <- predict(pid_predict, x, type = "class")

head(as.data.frame(preds))
preds <- as.data.frame(preds)
names(preds) <- c("dem", "ind", "rep")

pid <- NA
pid <- with(preds, ifelse(dem > ind & dem > rep, "dem", NA))
pid <- with(preds, ifelse(rep > ind & rep > dem, "rep", pid))
pid <- with(preds, ifelse(dem < ind & ind > rep, "ind", pid))

table(pid)
# crosstab
table(y)

# summarize accuracy

length(which(y != pid))
length(which(y == pid))/length(y) # 91.97% accuracy for nofilter, 68.729 for filter, 0.6714 for filter w/ props, 39.11 for nofiler w/ props ?!?
# 70.3 for just visits
table(y[which(y != pid)]) # underpredicting reps



### demo only for comparison ###


train_predictors <- demo_x[train_set,]
test_predictors <- demo_x[-train_set,]
train_classes <- y[train_set]
test_classes <- y[-train_set]


set.seed(9382)
glmnet_grid <- expand.grid(alpha = c(0,  .5, 1), # c(0,  .1,  .2, .4, .6, .8, 1)
                           lambda = seq(.01, .2, length = 10))
glmnet_ctrl <- trainControl(method = "cv", number = 10)
glmnet_fit <- train(train_classes ~ ., data = train_predictors,
                    method = "glmnet",
                    #preProcess = c("center", "scale"),
                    tuneGrid = glmnet_grid,
                    trControl = glmnet_ctrl)

glmnet_fit
plot(glmnet_fit)
setwd("data/yg/predict_pid")
saveRDS(glmnet_fit, "glmnet_trainmodel_demosonly.rds")

pred_classes <- predict(glmnet_fit, newdata = test_predictors)
table(pred_classes)
length(which(pred_classes == test_classes))/length(test_classes) # .601 out of sample



## within sample ##

set.seed(9382)
pid_predict_demo <- cv.glmnet(as.matrix(demo_x), as.factor(y), family = "multinomial", alpha = 0) #, type.logistic = "modified.Newton") #, standardize = FALSE)

# grab coefs, reverse order (dem)
coefs <- cbind(demo_names, coef(pid_predict_demo)$dem[-1])
coefs <- coefs[order(as.numeric(coefs[,2]), decreasing = TRUE),]
head(coefs, 50); tail(coefs, 50)

# make predictions
preds <- predict(pid_predict_demo, as.matrix(demo_x), s = "lambda.min", type = "response") #"lambda.min"
preds <- as.data.frame(preds)
names(preds) <- c("dem", "ind", "rep")

pid <- NA
pid <- with(preds, ifelse(dem > ind & dem > rep, "dem", NA))
pid <- with(preds, ifelse(rep > ind & rep > dem, "rep", pid))
pid <- with(preds, ifelse(dem < ind & ind > rep, "ind", pid))

table(pid)
# crosstab
table(y)

# summarize accuracy

length(which(y != pid))
length(which(y == pid))/length(y) # 61.69% accuracy
table(y[which(y != pid)])
