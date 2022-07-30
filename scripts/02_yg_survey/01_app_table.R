library(weights)
library(xtable)

wpct(s$age)
wpct(s$gender)
wpct(s$race5)
wpct(s$pid3)
wpct(s$region)
wpct(s$income)

wpct(s$age, weight = s$weights)
wpct(s$gender, weight = s$weights)
wpct(s$race5, weight = s$weights)
wpct(s$pid3, weight = s$weights)
wpct(s$region, weight = s$weights)
wpct(s$income, weight = s$weights)


round(c(wpct(s$age), wpct(s$gender), wpct(s$race5), wpct(s$pid3), wpct(s$region), wpct(s$income)), digits = 3)

app_table <- as.data.frame(
  cbind(round(c(wpct(s$age), wpct(s$gender), wpct(s$race5), wpct(s$pid3), wpct(s$region), wpct(s$income)), digits = 3),
      round(c(wpct(s$age, weight = s$weights), wpct(s$gender, weight = s$weights), wpct(s$race5, weight = s$weights), 
        wpct(s$pid3, weight = s$weights), wpct(s$region, weight = s$weights), wpct(s$income, weight = s$weights)), digits = 3))
  )

names(app_table) <- c("Unweighted", "Weighted")

setwd("../../figs")
print(xtable(app_table), file = "app_table.tex")

### APP TABLE REVISED ###

## first load indiv from 02_results.R (step 0)

app_table <- as.data.frame(
  cbind(round(c(wpct(indiv$age), wpct(indiv$gender), wpct(indiv$race5), wpct(indiv$pid3), wpct(indiv$region), wpct(indiv$income)), digits = 3),
        round(c(wpct(indiv$age, weight = indiv$weights), wpct(indiv$gender, weight = indiv$weights), wpct(indiv$race5, weight = indiv$weights), 
                wpct(indiv$pid3, weight = indiv$weights), wpct(indiv$region, weight = indiv$weights), wpct(indiv$income, weight = indiv$weights)), digits = 3))
)

names(app_table) <- c("Unweighted", "Weighted")

## now add pop marginals from benchmarks

# From 2010 Census: https://www.census.gov/popest/data/national/asrh/2014/index.html -- U.S. residents vintage 2014
age <- round(c(31464158/245273438,
               84029637/245273438,
               83536432/245273438,
               46243211/245273438), digits = 2)

gender <- round(c(119352940/245273438, 125920498/245273438), digits = 2)

# white black hispanic asian other
race <- round(c(197314278/308739316, 37921272/308739316, 44617997/308739316, 14661475/308739316, NA), digits = 2) # using "Hispanics" = white Hispanics
race[5] <- 1-sum(race[1:4])

region <- round(c(66927001, 55317240, 114555744, 71945553)/308745538, digits = 2) # 2010 http://factfinder.census.gov/faces/tableservices/jsf/pages/productview.xhtml?src=bkmk

income <- round(c(2266+1976+2743+3272, 3860+3958+3771+3785, 3677+3291+3457+2959, 3099+2601+2773+2360, 2450+2173+2008+1724, 1968+1497+1495+1263, NA)/78633, digits = 2)
income[7] <- 1-sum(income[1:6])
income <- income[c(1, 7, 6, 2:5)]

# From Pew 2014: http://www.people-press.org/2015/04/07/2014-party-identification-detailed-tables/
pid <- c(.32, .23, .39, .06)

app_table$Population <- c(age, gender[2:1], race[c(4,2,3,5,1)], pid[c(3,1,4,2)], region, 
                          income[c(1,7,6,2,3,4,5)])

setwd("~/Dropbox/web analysis/scripts/02_yg_survey")
setwd("../../tabs")
print(xtable(app_table), file = "app_table.tex")
