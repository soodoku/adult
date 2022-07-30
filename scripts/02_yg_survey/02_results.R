# rm(list=ls(all=TRUE))
library(dplyr)

### THIS FILE: Run models & report tables + graphs.

#############################################
### 0. PREP #################################
#############################################

# Set dir
ifelse(grepl("Gaurav", getwd()), setwd(basedir), setwd("/Users/aguess/Dropbox/"))
setwd("web analysis/")

# load data -- weights generated in code/yg/raking_weights.R -- raked using age, gender, race, PID, & region
# DVs already coded in code/yg/porn_analysis.R
indiv <- read.csv("data/yg/porn_indiv_level_weighted_2016_recode2.csv", stringsAsFactors = FALSE) # latest coding 3/29/16
indiv <- read.csv("data/yg/porn_indiv_level_weighted_2016_recode_shalla1.csv", stringsAsFactors = FALSE) # latest coding 4/4/16 using Shallalist

# relevel as needed:
indiv$ideo5 <- factor(indiv$ideo5) # factorize
indiv$ideo5 <- relevel(indiv$ideo5, "moderate") # moderate = base category
indiv$ideo5 <- relevel(indiv$ideo5, "dk") # "dk" = base category
#indiv$ideo5 <- relevel(indiv$ideo5, "liberal")

indiv$pid3 <- factor(indiv$pid3)
indiv$pid3 <- relevel(indiv$pid3, "ind") # independent = base category
#indiv$pid3 <- relevel(indiv$pid3, "dem")
head(indiv)



#################################################
### 1. MODELS ###################################
#################################################

### Test for overdispersion ###
library(qcc)
qcc.overdispersion.test(indiv$porn.indiv.n) # definitely overdispersed; use quasi-Poisson for count data

### Dichotomous DV (visited porn 1/0) ###

# ideology predictor
summary(lm(porn.indiv.1 ~ ideo5 + age + gender, data = indiv, weights = weights))
summary(lm(porn.indiv.1 ~ ideo5 + age + gender - 1, data = indiv, weights = weights)) # sans intercept
summary(lm(porn.indiv.1 ~ ideo5 + age + gender + married, data = indiv, weights = weights))
summary(lm(porn.indiv.1 ~ ideo5 + age + gender + married - 1, data = indiv, weights = weights))
summary(glm(porn.indiv.1 ~ ideo5 + age + gender + married, data = indiv, weights = weights, family = "binomial")) # logit

# PID predictor
summary(lm(porn.indiv.1 ~ pid3 + age + gender, data = indiv, weights = weights))
summary(lm(porn.indiv.1 ~ pid3 + age + gender + married, data = indiv, weights = weights))
summary(glm(porn.indiv.1 ~ pid3 + age + gender + married, data = indiv, weights = weights, family = "binomial")) # logit

### Count DV (# porn visits) ###

# ideology predictor
summary(lm(porn.indiv.n ~ ideo5 + age + gender, data = indiv, weights = weights))
summary(lm(porn.indiv.n ~ ideo5 + age + gender + married, data = indiv, weights = weights))
# w/ quasi-Poisson:
summary(glm(porn.indiv.n ~ ideo5 + age + gender + married, data = indiv, weights = weights, family = "quasipoisson"))  # **
model_ideo_numvisits <- glm(porn.indiv.n ~ ideo5 + age + gender + married, data = indiv, weights = weights, family = "quasipoisson")

# PID predictor
summary(lm(porn.indiv.n ~ pid3 + age + gender, data = indiv, weights = weights))
summary(lm(porn.indiv.n ~ pid3 + age + gender + married, data = indiv, weights = weights))
# w/ quasi-Poisson:
summary(glm(porn.indiv.n ~ pid3 + age + gender + married, data = indiv, weights = weights, family = "quasipoisson"))

### % visits DV ###

# PID predictor
summary(lm(pct_visits_on_porn ~ pid3 + age + gender, data = indiv, weights = weights))
summary(lm(pct_visits_on_porn ~ pid3 + age + gender + married, data = indiv, weights = weights))

# ideology predictor
summary(lm(pct_visits_on_porn ~ ideo5 + age + gender, data = indiv, weights = weights))
summary(lm(pct_visits_on_porn ~ ideo5 + age + gender + married, data = indiv, weights = weights))  # **
model_ideo_pctvisits <- lm(pct_visits_on_porn ~ ideo5 + age + gender + married, data = indiv, weights = weights)

### Total time DV ###

# PID predictor
summary(lm(total_time_on_porn ~ pid3 + age + gender, data = indiv, weights = weights))
summary(lm(total_time_on_porn ~ pid3 + age + gender + married, data = indiv, weights = weights))

# ideology predictor
summary(lm(total_time_on_porn ~ ideo5 + age + gender, data = indiv, weights = weights))
summary(lm(total_time_on_porn ~ ideo5 + age + gender + married, data = indiv, weights = weights)) # **
model_ideo_totaltime <- lm(total_time_on_porn ~ ideo5 + age + gender + married, data = indiv, weights = weights)

### % time DV ###

# PID predictor
summary(lm(pct_time_on_porn ~ pid3 + age + gender, data = indiv, weights = weights))
summary(lm(pct_time_on_porn ~ pid3 + age + gender + married, data = indiv, weights = weights))

# ideology predictor
summary(lm(pct_time_on_porn ~ ideo5 + age + gender, data = indiv, weights = weights))
summary(lm(pct_time_on_porn ~ ideo5 + age + gender + married, data = indiv, weights = weights)) # **
model_ideo_pcttime <- lm(pct_time_on_porn ~ ideo5 + age + gender + married, data = indiv, weights = weights)




##############################################
### 2. TABLE OUTPUT ##########################
##############################################

library(stargazer)

dvlabs <- c("Number of visits", "Pct. visits", "Total time (seconds)", "Pct. time")
varlabs <- c("Ideology: Conservative", "Ideology: Don't know", "Ideology: Liberal", "Ideology: Very conservative", "Ideology: Very liberal",
             #"Democrat", "Don't know party", "Republican", 
             "Age: 25-44", "Age: 45-64", "Age: 65+",
             "Gender: Male", "Married")

stargazer(model_ideo_numvisits, model_ideo_pctvisits, model_ideo_totaltime, model_ideo_pcttime, column.labels = dvlabs,
          no.space = TRUE, covariate.labels = varlabs, column.separate = c(1,1,1,1), align = TRUE,
          font.size = "small", nobs = TRUE, keep.stat=c("n", "adj.rsq", "null.dev", "res.dev"), digits = 2, dep.var.labels.include = FALSE,
          notes="Model 1: Quasi-Poisson; Models 2-4: OLS. Standard errors in parentheses. The base category for ideological self-placement is ``independent.'' All models use weights raked to population by age, gender, race, party ID, and region.", notes.align="l",
          model.names = FALSE, out = "tabs/models.tex", style = "apsr",
          title = "The effect of ideology on four separate dependent variables measuring pornography consumption.",
          label = "tab:ideomodels")





##############################################
### 3. GRAPH OUTPUT ##########################
##############################################

library(ggplot2)

# prep data for gg
# porn_dat <- select(indiv, ideo5, porn.indiv.n) %>%
#   filter(ideo5 != "dk") %>% # keep out dk's for now
#   group_by(ideo5) %>%
#   summarize(avg_numvisits = n())

# reorder factor levels
indiv$ideo5 <- relevel(indiv$ideo5, ref = "very con")
indiv$ideo5 <- relevel(indiv$ideo5, ref = "conservative")
indiv$ideo5 <- relevel(indiv$ideo5, ref = "moderate")
indiv$ideo5 <- relevel(indiv$ideo5, ref = "liberal")
indiv$ideo5 <- relevel(indiv$ideo5, ref = "very lib")

# boxplot (not weighted)
g1 <- ggplot(filter(indiv, ideo5 != "dk" & !is.na(ideo5)), aes(x = ideo5, y = porn.indiv.n)) + geom_boxplot() + 
  theme_minimal() + ggtitle("Porn visits by ideological self-placement") + 
  labs(x = "", y = "Number of visits") + coord_cartesian(ylim = c(0, 100))
ggsave(filename = "figs/ideo_boxplot_shalla.pdf", g1)

# pointrange (weighted)

library(survey)

indiv_w <- svydesign(ids = ~0, weights = ~weights, data = indiv)
svymean(~porn.indiv.n, indiv_w, na.rm = TRUE)
porn_dat <- svyby(~porn.indiv.n, ~ideo5, indiv_w, svymean, na.rm = TRUE)
porn_dat <- filter(porn_dat, ideo5 != "dk")

g2 <- ggplot(porn_dat, aes(x = ideo5, y = porn.indiv.n, ymin = porn.indiv.n - se*1.96,
                           ymax = porn.indiv.n + se*1.96, color = ideo5)) + geom_pointrange(size = 1) +
  geom_errorbar(width = 0.2) +
  scale_color_manual(values = c("very lib"="darkblue", "liberal"="blue", "moderate"="purple", 
                               "conservative"="red", "very con"="darkred")) +
  ylab("Number of visits") + xlab("") +
  ggtitle("Porn visits by ideological self-placement") + theme_minimal() + theme(legend.position="none") 
g2
ggsave(filename = "figs/ideo_pointrange_shalla.pdf", g2)

# coefplot for total time (weighted)

indiv$ideo5 <- relevel(indiv$ideo5, ref = "dk") # "dk" = base category

model_ideo_totaltime <- lm(total_time_on_porn ~ ideo5 + age + gender + married, data = indiv, weights = weights)
porn_dat <- data.frame(coef = factor(rownames(summary(model_ideo_totaltime)$coef), levels = rownames(summary(model_ideo_totaltime)$coef)), 
                       est = summary(model_ideo_totaltime)$coef[,1], se = summary(model_ideo_totaltime)$coef[,2])

g3 <- ggplot(filter(porn_dat, coef != "(Intercept)"), aes(x = coef, y = est, ymin = est - se*1.96,
                           ymax = est + se*1.96, color = coef)) + geom_pointrange() +
  geom_hline(yintercept = 0, colour = gray(1/2), lty = 2) + 
  #geom_errorbar(width = 0.2) + "(Intercept)" = "black", 
  scale_color_manual(values = c("ideo5very lib"="darkblue", "ideo5liberal"="blue", "ideo5moderate"="purple", 
                                "ideo5conservative"="red", "ideo5very con"="darkred", "age25-44" = "black",
                                "age45-64" = "black", "age65+" = "black", "gendermale" = "black", 
                                "married" = "black")) +
  ylab("Amount of time (seconds)") + xlab("") + coord_flip() + #ylim(-10000, 10000) +
  ggtitle("Determinants of porn consumption") + theme_light() + theme(legend.position="none") 
g3
ggsave(filename = "figs/ideo_totaltime_coefplot_shalla.pdf", g3)

# coefplot for % time (weighted)

model_ideo_pcttime <- lm(pct_time_on_porn ~ ideo5 + age + gender + married, data = indiv, weights = weights)
porn_dat <- data.frame(coef = factor(rownames(summary(model_ideo_pcttime)$coef), levels = rownames(summary(model_ideo_pcttime)$coef)), 
                       est = summary(model_ideo_pcttime)$coef[,1], se = summary(model_ideo_pcttime)$coef[,2])

g4 <- ggplot(filter(porn_dat, coef != "(Intercept)"), aes(x = coef, y = est, ymin = est - se*1.96,
                                                          ymax = est + se*1.96, color = coef)) + geom_pointrange() +
  geom_hline(yintercept = 0, colour = gray(1/2), lty = 2) + 
  #geom_errorbar(width = 0.2) + "(Intercept)" = "black", 
  scale_color_manual(values = c("ideo5very lib"="darkblue", "ideo5liberal"="blue", "ideo5moderate"="purple", 
                                "ideo5conservative"="red", "ideo5very con"="darkred", "age25-44" = "black",
                                "age45-64" = "black", "age65+" = "black", "gendermale" = "black", 
                                "married" = "black")) +
  ylab("% of total browsing time") + xlab("") + coord_flip() + #ylim(-10000, 10000) +
  ggtitle("Determinants of porn consumption") + theme_light() + theme(legend.position="none") 
g4
ggsave(filename = "figs/ideo_pcttime_coefplot_shalla.pdf", g4)

# dynamite plot (sorry) (unweighted)

g2 <- ggplot(filter(indiv, ideo5 != "dk" & !is.na(ideo5)), aes(x = ideo5, y = porn.indiv.n, fill=ideo5)) + 
  stat_summary(aes(width = .8), geom = "bar", fun.y = "mean") +
  stat_summary(geom = "errorbar", fun.data = "mean_se", width = .2) +
  theme_minimal() + ggtitle("Porn visits by ideological self-placement") + 
  labs(x = "", y = "Number of visits") + theme(legend.position="none") +
  scale_fill_manual(values = c("very lib"="darkblue", "liberal"="blue", "moderate"="purple", 
                                 "conservative"="red", "very con"="darkred"))
ggsave(filename = "figs/ideo_dynamite.pdf", g2)

# unweighted:
with(indiv, tapply(porn.indiv.n, ideo5, mean))



# boxplot (with weighted means)

porn_dat <- svyby(~porn.indiv.n, ~ideo5, indiv_w, svymean, na.rm = TRUE)
porn_dat <- filter(porn_dat, ideo5 != "dk")

g1 <- ggplot(filter(indiv, ideo5 != "dk" & !is.na(ideo5)), aes(x = ideo5, y = porn.indiv.n)) + geom_boxplot() + 
  theme_minimal() + ggtitle("Porn visits by ideological self-placement") + 
  labs(x = "", y = "Number of visits") + coord_cartesian(ylim = c(0, 500)) +
  geom_point(data = porn_dat, aes(x = ideo5, y = porn.indiv.n), shape = 23, 
           size = 3, fill ="white", inherit.aes = FALSE) # add weighted means
g1

ggsave(filename = "figs/ideo_boxplot_shalla.pdf", g1)
