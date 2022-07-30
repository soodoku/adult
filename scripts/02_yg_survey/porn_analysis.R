# rm(list=ls(all=TRUE))
# porn.indiv <- select(wakoopa, category, duration, pmxid) %>%
#   mutate(porn = ifelse(category == "Adult", 1, 0)) %>%
#   group_by(pmxid) %>%
#   arrange(pmxid)
#   #ungroup() %>%
#   #group_by(pmxid) %>%
#   #summarise(numporn = sum())
# 
# porn.indiv.1 <- as.vector(with(porn.indiv, tapply(porn, pmxid, function(x) max(x, na.rm = TRUE))))
# porn.indiv.1 <- ifelse(porn.indiv.1 < 0, 0, porn.indiv.1)
# porn.indiv.n <- as.vector(with(porn.indiv, tapply(porn, pmxid, function(x) sum(x, na.rm = TRUE))))
# pct_visits_on_porn <- round(as.vector(with(porn.indiv, tapply(porn, pmxid, function(x) mean(x, na.rm = TRUE)))), digits = 2)

# 
# head(porn.indiv)
# head(porn.indiv.1)
# head(porn.indiv.n)
# head(s)
# 
# indiv <- cbind(s, porn.indiv.1, porn.indiv.n, pct_visits_on_porn)
# write.csv(indiv, "data/indiv_level_weighted.csv")

### ADDING DURATION MEASURES -ag ###
# 
# porn.indiv$porn <- ifelse(is.na(porn.indiv$porn), 0, porn.indiv$porn)
# 
# porn.duration <- select(porn.indiv, pmxid, porn, duration) %>%
#   group_by(pmxid, porn) %>%
#   summarize(total_duration = sum(duration))
# porn.duration <- filter(porn.duration, porn == 1) # this gives us the total duration of porn visits, if exist
# 
# porn.denom <- select(porn.indiv, pmxid, duration) %>%
#   group_by(pmxid) %>%
#   summarize(denom = sum(duration)) # total duration of ALL visits for each pmxid
# 
# total_time_on_porn <- sapply(indiv$pmxid, function(x) ifelse(x %in% porn.duration$pmxid, porn.duration[which(porn.duration$pmxid %in% x),]$total_duration, 0))
# pct_time_on_porn <- round(total_time_on_porn/porn.denom$denom, digits = 2)
# 
# cor(pct_visits_on_porn[which(!is.na(pct_visits_on_porn))], pct_time_on_porn[which(!is.na(pct_visits_on_porn))])
# 
# indiv <- cbind(indiv, total_time_on_porn, pct_time_on_porn)
# write.csv(indiv, "data/yg/indiv_level_weighted.csv")



"
Analyze Porn Consumption

"

# Set dir
ifelse(grepl("Gaurav", getwd()), setwd(basedir), setwd("/Users/aguess/Dropbox/"))
setwd("web analysis/")

# Load lib
library(dplyr)

# load data -- weights generated in code/yg/raking_weights.R -- raked using age, gender, race, PID, & region
indiv <- read.csv("data/yg/porn_indiv_level_weighted_2016.csv", stringsAsFactors = FALSE)

# relevel as needed:
indiv$ideo5 <- factor(indiv$ideo5) # factorize
indiv$ideo5 <- relevel(indiv$ideo5, "moderate") # moderate = base case
#indiv$ideo5 <- relevel(indiv$ideo5, "liberal")

indiv$pid3 <- factor(indiv$pid3)
indiv$pid3 <- relevel(indiv$pid3, "ind") # independent = base case
#indiv$pid3 <- relevel(indiv$pid3, "dem")
head(indiv)

library(ggplot2)

ggplot(indiv, aes(factor(pid3), porn.indiv.n)) + 
geom_boxplot(outlier.size=0, fatten=0) 

plot(density(indiv$porn.indiv.n[indiv$pid3=="rep" & !is.na(indiv$pid3) & !is.na(indiv$porn.indiv.n)]))
lines(density(indiv$porn.indiv.n[indiv$pid3=="dem" & !is.na(indiv$pid3) & !is.na(indiv$porn.indiv.n)]))


## improve porn classification ##

library(gdata)

porn_list <- read.csv("data/measure_porn/xxxsites_June_2014.csv", stringsAsFactors = FALSE, skip = 9)
porn_list <- porn_list[, 3]
porn_list <- tolower(trim(porn_list))
porn_list <- porn_list[1:1175]

head(porn_list)

length(which(porn.indiv$domain %in% porn_list[1]))
porn.indiv[which(porn.indiv$domain %in% porn_list[33]),]

# 1
for(i in 1:length(porn_list)) {
  
  porn.indiv[which(porn.indiv$domain %in% porn_list[i]),]$porn[which(is.na(porn.indiv[which(porn.indiv$domain %in% porn_list[i]),]$porn))] <- 1
  
}


# 2
porn_terms <- readLines("data/measure_porn/porn_list.txt", warn = FALSE)
porn_terms <- trim(strsplit(porn_terms, ",", fixed = TRUE))[[1]]
porn_terms <- porn_terms[1:(length(porn_terms)-1)]
porn_terms <- porn_terms[c(5:8, 10:15, 19:20, 23, 25:30, 32:39)]
porn_terms <- porn_terms[!1:length(porn_terms) %in% c(8)]
porn_terms <- porn_terms[!1:length(porn_terms) %in% c(23)]
porn_terms <- porn_terms[!1:length(porn_terms) %in% c(23)]

length(grep(porn_terms[1], porn.indiv$domain, fixed = TRUE))
porn.indiv[grep(porn_terms[6], porn.indiv$domain, fixed = TRUE),] # mature, sex

i <- 1
print(porn_terms[i]); porn.indiv[grep(porn_terms[i], porn.indiv$domain, fixed = TRUE),]; i <- i+1

for(i in 1:length(porn_terms)) {
  
  porn.indiv[grep(porn_terms[i], porn.indiv$domain, fixed = TRUE),]$porn <- 1
  
}


## models ##


# test for overdispersion
library(qcc)
qcc.overdispersion.test(indiv$porn.indiv.n) # definitely overdispersed, use quasi-Poisson for count data

# dichotomous DV - ideology
summary(lm(porn.indiv.1 ~ ideo5 + age + gender, data = indiv, weights = weights))
summary(lm(porn.indiv.1 ~ ideo5 + age + gender - 1, data = indiv, weights = weights)) # sans intercept
summary(lm(porn.indiv.1 ~ ideo5 + age + gender + married, data = indiv, weights = weights))
summary(lm(porn.indiv.1 ~ ideo5 + age + gender + married - 1, data = indiv, weights = weights))
summary(glm(porn.indiv.1 ~ ideo5 + age + gender + married, data = indiv, weights = weights, family = "binomial")) # logit

# dichotomous DV - PID
summary(lm(porn.indiv.1 ~ pid3 + age + gender, data = indiv, weights = weights))
summary(lm(porn.indiv.1 ~ pid3 + age + gender + married, data = indiv, weights = weights))
summary(glm(porn.indiv.1 ~ pid3 + age + gender + married, data = indiv, weights = weights, family = "binomial")) # logit

# count DV - ideology
summary(lm(porn.indiv.n ~ ideo5 + age + gender, data = indiv, weights = weights))
summary(lm(porn.indiv.n ~ ideo5 + age + gender + married, data = indiv, weights = weights))
# quasi-Poisson:
summary(glm(porn.indiv.n ~ ideo5 + age + gender + married, data = indiv, weights = weights, family = "quasipoisson"))

# count DV - PID
summary(lm(porn.indiv.n ~ pid3 + age + gender, data = indiv, weights = weights))
summary(lm(porn.indiv.n ~ pid3 + age + gender + married, data = indiv, weights = weights))
# quasi-Poisson:
summary(glm(porn.indiv.n ~ pid3 + age + gender + married, data = indiv, weights = weights, family = "quasipoisson"))

# % visits DV - PID
summary(lm(pct_visits_on_porn ~ pid3 + age + gender, data = indiv, weights = weights))
summary(lm(pct_visits_on_porn ~ pid3 + age + gender + married, data = indiv, weights = weights))
# % visits DV - ideology
summary(lm(pct_visits_on_porn ~ ideo5 + age + gender, data = indiv, weights = weights))
summary(lm(pct_visits_on_porn ~ ideo5 + age + gender + married, data = indiv, weights = weights))

# % time DV - PID
summary(lm(pct_time_on_porn ~ pid3 + age + gender, data = indiv, weights = weights))
summary(lm(pct_time_on_porn ~ pid3 + age + gender + married, data = indiv, weights = weights))
# % time DV - ideology
summary(lm(pct_time_on_porn ~ ideo5 + age + gender, data = indiv, weights = weights))
summary(lm(pct_time_on_porn ~ ideo5 + age + gender + married, data = indiv, weights = weights))

### output ###

model.ideo.dich <- lm(porn.indiv.1 ~ ideo5 + age + gender + married, data = indiv, weights = weights)
model.ideo.dich.nw <- lm(porn.indiv.1 ~ ideo5 + age + gender + married, data = indiv)
model.pid.dich <- lm(porn.indiv.1 ~ pid3 + age + gender + married, data = indiv, weights = weights)
model.pid.dich.nw <- lm(porn.indiv.1 ~ pid3 + age + gender + married, data = indiv)
model.ideo.n <- glm(porn.indiv.n ~ ideo5 + age + gender + married, data = indiv, weights = weights, family = "quasipoisson")
model.ideo.n.nw <- glm(porn.indiv.n ~ ideo5 + age + gender + married, data = indiv, family = "quasipoisson")
model.pid.n <- glm(porn.indiv.n ~ pid3 + age + gender + married, data = indiv, weights = weights, family = "quasipoisson")
model.pid.n.nw <- glm(porn.indiv.n ~ pid3 + age + gender + married, data = indiv, family = "quasipoisson")

library(stargazer)

dvlabs <- "Any visit"
varlabs <- c("Conservative", "Don't know ideology", "Liberal", "Very conservative", "Very liberal",
             "Democrat", "Don't know party", "Republican", "25-44", "45-64", "65+",
             "Male", "Married")

sink(file = "figs/models_dich.tex")
stargazer(model.ideo.dich, model.ideo.dich.nw, model.pid.dich, model.pid.dich.nw, column.labels = dvlabs,
          no.space = TRUE, covariate.labels = varlabs, column.separate = c(4), #, column.labels=dvlabs,
          font.size = "small", nobs = TRUE, keep.stat=c("n", "adj.rsq"), digits = 2, dep.var.labels.include = FALSE,
          notes="OLS, standard errors in parentheses. Models 1 and 3 use weights; 2 and 4 are unweighted.", notes.align="l") # column.separate=c(2,2,2),
sink()

dvlabs <- "Number of visits"

sink(file = "figs/models_count.tex")
stargazer(model.ideo.n, model.ideo.n.nw, model.pid.n, model.pid.n.nw, column.labels = dvlabs,
          no.space = TRUE, covariate.labels = varlabs, column.separate = c(4), # model.names = TRUE,
          font.size = "small", nobs = TRUE, keep.stat=c("n", "adj.rsq"), digits = 2, dep.var.labels.include = FALSE,
          notes="Quasi-Poisson models, standard errors in parentheses. Models 1 and 3 use weights; 2 and 4 are unweighted.", notes.align="l") # column.separate=c(2,2,2),
sink()



### below I'm playing around with state-level stuff, MRP, etc.  -ag ###

# state level

summary(lm(porn.indiv.1 ~ region - 1, data = indiv, weights = weights))
summary(lm(porn.indiv.1 ~ as.factor(inputstate) - 1, data = indiv, weights = weights))
with(indiv, wtd.chi.sq(porn.indiv.1, inputstate, weight = weights))

with(indiv, wtd.chi.sq(porn.indiv.n, blue, weight = weights))
with(subset(indiv, blue == 1), mean(porn.indiv.n))
with(subset(indiv, blue == 0), mean(porn.indiv.n))

with(indiv, wtd.cor(porn.indiv.n, blue, weight = weights))


## red state blue state ##

with(subset(indiv, red == 1), wpct(porn.indiv.1, weight = weights))
with(subset(indiv, red == 0), wpct(porn.indiv.1, weight = weights))

with(subset(indiv, red == 1), wpct(porn.indiv.1))
with(subset(indiv, red == 0), wpct(porn.indiv.1))

## MRP ##

library(mrpdata)
library(mrp)

indiv <- within(indiv, {
  
  age.mrp <- 2016-birthyr
  age.mrp <- as.factor(ifelse((age.mrp >=18) & (age.mrp <30), "18-29",
                          ifelse((age.mrp >=30) & (age.mrp <45), "30-44",
                                 ifelse((age.mrp >=45) & (age.mrp <65), "45-64",
                                        ifelse((age.mrp >=65) & (age.mrp <100), "65+",NA)))))
  
  state <- levels(mrp.census$state)[match(inputstate, state.codes)]
  
  levels(educ) <- levels(mrp.census$education)
  levels(gender) <- levels(mrp.census$sex)
  levels(race5) <- c(levels(mrp.census$race), levels(mrp.census$race)[4])
  
})

mrp.census <- within(mrp.census, {
  
  age.mrp <- factor(age,exclude=NA,labels=c("18-29","30-44","45-64","65+"))
  educ <- factor(education,exclude=NA)
  state <- factor(state,exclude=NA)
  race5 <- factor(race,exclude=NA)
  gender <- factor(sex, exclude=NA)
  
})

mrp.census <- na.omit(mrp.census)

## Ready to run simple mrp with poll and population:
mrp.simple <- mrp(porn.indiv.1 ~ state + age.mrp + educ + race5 + gender, 
                  data = indiv,
                  population = mrp.census,
                  pop.weights = "weighted2008")

ranef(getModel(mrp.simple))
sort(print(100 * poststratify(mrp.simple, ~ state), digits = 3), decreasing = TRUE)
getFormula(mrp.simple)

s.means <- tapply(indiv$porn.indiv.1, indiv$state, mean, na.rm = TRUE) # no pooling

# red vs. blue

round(mean(poststratify(mrp.simple, ~ state)[which(states$red==0)]), digits = 3)
round(mean(poststratify(mrp.simple, ~ state)[which(states$red==1)]), digits = 3)

