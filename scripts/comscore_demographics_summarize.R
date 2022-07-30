"
Summarize comscore demographic data

"

# Set dir. 
setwd(basedir)
setwd("adult")

# Recode Function
# ---------------
cs_recoder <- function(dat=NULL) {

	dat$hoh_most_education_r <- factor(car::recode(dat$hoh_most_education, 
												  "0='Less than HS'; 1='HS Diploma or Equivalent'; 2='Some college but no degree'; 3='Associate';4='BS';5='Grad. Degree or Above';c(99, '**')=NA"),
												  c('Less than HS', 'HS Diploma or Equivalent', 'Some college but no degree', 'Associate', 'BS', 'Grad. Degree or Above'))
	dat$household_income_r   <- factor(car::recode(dat$household_income,   
													"1='less Than 15k'; 2='15k--25k'; 3='25k--35k';4='35k--50k';5='50k--75k'; 6= '75k--100k';7 = '100k+'"),
													c('less Than 15k', '15k--25k', '25k--35k', '35k--50k', '50k--75k', '75k--100k', '100k+'))

	dat$connection_speed_r   <- factor(car::recode(dat$connection_speed,   "1='Broadband'; 0='Not Broadband'"), c('Broadband', 'Not Broadband'))
	dat$racial_background_r  <- factor(car::recode(dat$racial_background,  "1='White'; 2='Black'; 3='Asian';5='Other';'*'=NA"), c('White', 'Black', 'Asian', 'Other'))

	dat$census_region_r      <- factor(car::recode(dat$census_region,      "'*'=NA; 1='Northeast'; 2='North Central'; 3='South';4='West'"), c('Northeast', 'North Central', 'South', 'West'))
	dat$country_of_origin_r  <- factor(car::recode(dat$country_of_origin,  "1='Hispanic'; 0='Non-Hispanic'"), c('Hispanic', 'Non-Hispanic'))
	dat$hoh_oldest_age_r     <- factor(car::recode(dat$hoh_oldest_age,     "1='18--20'; 2='21--24'; 3='25--29';4='30--34';5='35-39'; 6= '40-44';7 = '45-49'; 8 = '50-54'; 9 ='55-59'; 10 ='60-64'; 11='65+'; 99=NA"))
	dat$census_region_r      <- factor(car::recode(dat$census_region,      "1='Northeast'; 2='North Central'; 3='South';4='West'"), c('Northeast', 'North Central', 'South', 'West'))
	dat
}


# Recoder 
cs2002_dem <- cs_recoder(read.csv("data/comscore/dem/demographics2002.csv"))
cs2004_dem <- cs_recoder(read.csv("data/comscore/dem/demographics2004.csv"))
cs2006_dem <- cs_recoder(read.csv("data/comscore/dem/demographics2006.csv"))
cs2007_dem <- cs_recoder(read.csv("data/comscore/dem/demographics2007.csv"))
cs2008_dem <- cs_recoder(read.csv("data/comscore/dem/demographics2008.csv"))
cs2009_dem <- cs_recoder(read.csv("data/comscore/dem/demographics2009.csv"))
cs2010_dem <- cs_recoder(read.csv("data/comscore/dem/demographics2010.csv"))
cs2011_dem <- cs_recoder(read.csv("data/comscore/dem/demographics2011.csv"))
cs2012_dem <- cs_recoder(read.csv("data/comscore/dem/demographics2012.csv"))
cs2013_dem <- cs_recoder(read.csv("data/comscore/dem/demographics2013.csv"))

# Summarizer

summarizer <- function(dat=NULL){

	educ      <- table(dat$hoh_most_education_r)
	hh_income <- table(dat$household_income_r)
	age       <- table(dat$hoh_oldest_age_r)
	race      <- table(dat$racial_background_r)
	hispanic  <- table(dat$country_of_origin_r)
	census    <- table(dat["census_region_r"])
	speed     <- table(dat$connection_speed_r)

	c(educ, hh_income, age, race, hispanic, census, speed)*100/nrow(dat)
}

# summarizer

cs2002_dem_tab <- summarizer(cs2002_dem)
cs2004_dem_tab <- summarizer(cs2004_dem)
cs2006_dem_tab <- summarizer(cs2006_dem)
cs2007_dem_tab <- summarizer(cs2007_dem)
cs2008_dem_tab <- summarizer(cs2008_dem)
cs2009_dem_tab <- summarizer(cs2009_dem)
cs2010_dem_tab <- summarizer(cs2010_dem)
cs2011_dem_tab <- summarizer(cs2011_dem)
cs2012_dem_tab <- summarizer(cs2012_dem)
cs2013_dem_tab <- summarizer(cs2013_dem)

cs_dem <- as.data.frame(cbind(cs2002_dem_tab, cs2004_dem_tab, cs2006_dem_tab, cs2007_dem_tab, cs2008_dem_tab, cs2009_dem_tab, cs2010_dem_tab, cs2011_dem_tab, cs2012_dem_tab, cs2013_dem_tab))

names(cs_dem) <- c("2002", "2004", "2006", "2007", "2008", "2009", "2010", "2011", "2012", "2013")

library(xtable)
print(
	  xtable(cs_dem, 
	  	caption="comScore Demographics", label="tab:cs_dem"), 
	    include.colnames = TRUE, size="\\tiny", 
	    type = "latex", 
	    sanitize.text.function = function(x){x},
	    caption.placement="top",
	    table.placement="!htb",
	    file="tabs/cs_dem.tex")
