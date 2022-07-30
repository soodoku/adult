# YouGov UK weights Wakoopa data by age, gender, region (by Internet representativeness)
# see: http://sebadaza.com/survey/2012/08/25/raking/

library(dplyr)
library(weights)
library(anesrake)

setwd("~/Dropbox/web analysis/data/yg/wakoopa/")
demos <- read.csv("wakoopa_demos.csv", stringsAsFactors = FALSE)
load("wakoopa_fullcat.RData")
head(wakoopa)

s <- distinct(select(wakoopa, pmxid, birthyr, gender, educ, race5, ideo5, pid3))
s <- merge(s, demos, by = "pmxid", all.x = TRUE)
head(s)

# YouGov codes, direct from Q wording:
state.names <- c("Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "District of Columbia", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina",
                "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming", "American Samoa", "Federated States of Micronesia", "Guam", "Marshall Islands", "Northern Mariana Islands", "Palau", "Puerto Rico", "U.S. Minor Outlying Islands", "Virgin Islands", "Alberta", "British Columbia", "Manitoba", "New Brunswick", "Newfoundland", "Northwest Territories", "Nova Scotia", "Nunavut", "Ontario", "Prince Edward Island", "Quebec", "Saskatchewan", "Yukon Territory", "Not in the U.S. or Canada")
state.codes <- c(1, 2, 4, 5, 6, 8, 9, 10, 11, 12, 13, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 44, 45, 46, 47, 48, 49, 50, 51, 53, 54, 55, 56, 60, 64, 66, 68, 69, 70, 72, 74, 78, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 99)

# These #'s correspond to the state.codes above (NOT vector indices), e.g.: state.names[which(state.codes %in% west)]
northeast <- c(9, 23, 25, 33, 44, 50, 34, 36, 42)
midwest <- c(17, 18, 26, 39, 55, 19, 20, 27, 29, 31, 38, 46)
south <- c(10, 11, 12, 13, 24, 37, 45, 51, 54, 01, 21, 28, 47, 05, 22, 40, 48)
west <- c(04, 08, 16, 30, 32, 35, 49, 56, 02, 06, 15, 41, 53)

# Dave Leip's states in order and Obama 2012 %
leip.states <- c("Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "District of Columbia", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming")
obama.pct <- c(38.36, 40.81, 44.45, 36.88, 60.16, 51.45, 58.06, 90.91, 58.61, 49.90, 45.39, 70.55, 32.40, 57.50, 43.84, 51.99, 38.05, 37.78, 40.58, 56.27, 61.97, 60.67, 54.04, 52.65, 43.79, 44.28, 41.66, 38.03, 52.36, 51.98, 58.25, 52.99, 63.35, 48.35, 38.69, 50.58, 33.23, 54.24, 51.96, 62.70, 44.09, 39.87, 39.04, 41.35, 24.67, 66.57, 51.16, 55.80, 35.45, 52.83, 27.82)

#blue <- as.numeric(obama.pct[match(leip.states, state.names)] >= 50)
#red <- 1 - blue

blue <- as.numeric(obama.pct[match(leip.states, state.names)] >= 55)
red <- as.numeric(obama.pct[match(leip.states, state.names)] <= 45)

# Set up demographic categories to match Census
s <- within(s, {
  
  age <- 2016-birthyr
  age <- as.factor(ifelse((age >=18) & (age <25), "18-24",
                          ifelse((age >=25) & (age <45), "25-44",
                                 ifelse((age >=45) & (age <65), "45-64",
                                        ifelse(age >=65, "65+", NA)))))
  levels(pid3) <- c("dem", "rep", "ind", "oth/dk", "oth/dk") # collapse last 2 categories
  married <- ifelse(marstat == 1, 1, 0)
  region <- as.factor(ifelse(inputstate %in% northeast, "northeast", ifelse(inputstate %in% midwest, "midwest",
                  ifelse(inputstate %in% south, "south", ifelse(inputstate %in% west, "west", NA)))))
  income <- as.factor(ifelse(faminc <= 2, "< $20,000", ifelse(faminc <= 4, "$20,000-39,999", ifelse(faminc <= 6, "$40,000-59,999", ifelse(faminc <= 8, "$60,000-79,999",
                                                              ifelse(faminc == 9, "$80,000-99,999", ifelse(faminc == 10, "$100,000-119,999", ifelse(faminc < 32, ">= $120,000", NA))))))))
  
})

# merge red/blue designations
states <- as.data.frame(cbind(state.codes[1:51], blue, red))
names(states)[1] <- "inputstate"
s <- merge(s, states, by = "inputstate", all.x = TRUE)
s <- arrange(s, pmxid)

with(s, wpct(age))
with(s, wpct(gender))
with(s, wpct(race5))
with(s, wpct(pid3))
with(s, wpct(region))
with(s, wpct(income))

# From 2010 Census: https://www.census.gov/popest/data/national/asrh/2014/index.html -- U.S. residents vintage 2014
#age <- c(.131, .350, .347, .172)
age <- round(c(31464158/245273438,
               84029637/245273438,
               83536432/245273438,
               46243211/245273438), digits = 2)
sum(age)
#gender <- round(c(113833952/234559127, 120725175/234559127), digits = 2)
gender <- round(c(119352940/245273438, 125920498/245273438), digits = 2)
sum(gender)
race <- round(c(197314278/308739316, 37921272/308739316, 44617997/308739316, 14661475/308739316, NA), digits = 2) # using "Hispanics" = white Hispanics
race[5] <- 1-sum(race[1:4])
sum(race)
region <- round(c(66927001, 55317240, 114555744, 71945553)/308745538, digits = 2) # 2010 http://factfinder.census.gov/faces/tableservices/jsf/pages/productview.xhtml?src=bkmk
sum(region)
income <- round(c(2266+1976+2743+3272, 3860+3958+3771+3785, 3677+3291+3457+2959, 3099+2601+2773+2360, 2450+2173+2008+1724, 1968+1497+1495+1263, NA)/78633, digits = 2)
income[7] <- 1-sum(income[1:6])
income <- income[c(1, 7, 6, 2:5)]
sum(income)

# From Pew 2014: http://www.people-press.org/2015/04/07/2014-party-identification-detailed-tables/
pid <- c(.32, .23, .39, .06)
sum(pid)

targets <- list(age, gender, race, pid)
names(targets) <- c("age", "gender", "race5", "pid3")
names(targets$age) <- levels(s$age)
names(targets$gender) <- levels(s$gender)
names(targets$race5) <- levels(s$race5)
names(targets$pid3) <- levels(s$pid3)
#targets <- lapply(targets, as.factor)
s$caseid <- 1:length(s$gender)

outsave <- anesrake(targets, s, caseid = s$caseid, verbose = F, 
                    cap = 6, choosemethod = "total", type = "pctlim", pctlim = 0.05, 
                    nlim = 4, iterate = T, force1 = TRUE)

targets.reg <- list(age, gender, race, pid, region)
names(targets.reg) <- c("age", "gender", "race5", "pid3", "region")
names(targets.reg$age) <- levels(s$age)
names(targets.reg$gender) <- levels(s$gender)
names(targets.reg$race5) <- levels(s$race5)
names(targets.reg$pid3) <- levels(s$pid3)
names(targets.reg$region) <- levels(s$region)

outsave.region <- anesrake(targets.reg, s, caseid = s$caseid, verbose = F, 
                    cap = 7, choosemethod = "total", type = "pctlim", pctlim = 0.05, 
                    nlim = 5, iterate = T, force1 = TRUE)

targets.all <- list(age, gender, race, region, income)
names(targets.all) <- c("age", "gender", "race5", "region", "income")
names(targets.all$age) <- levels(s$age)
names(targets.all$gender) <- levels(s$gender)
names(targets.all$race5) <- levels(s$race5)
#names(targets.all$pid3) <- levels(s$pid3)
names(targets.all$region) <- levels(s$region)
names(targets.all$income) <- levels(s$income)

outsave.all <- anesrake(targets.all, s, caseid = s$caseid, verbose = F, 
                           cap = 6, choosemethod = "total", type = "pctlim", pctlim = 0.05, 
                           nlim = 5, iterate = T, force1 = TRUE)

summary(outsave)
summary(outsave.region)
summary(outsave.all)

# add weights to the dataset
s$weights <- outsave$weightvec
s$weights <- outsave.region$weightvec
s$weights <- outsave.all$weightvec
n <- nrow(s)

# check party breakdown
with(s, wpct(pid3, weight = weights))

# weighting loss
((sum(s$weights^2)/(sum(s$weights))^2) * n) - 1

# save
write.csv(s, "ind_level_with_weights_2016.csv")
