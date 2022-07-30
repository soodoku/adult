"
join  unique_domain_cat + 
summarized by machine, domain
	: total_page_views, total_duration, n_unique_days_machine_visited_site

"

# Set dir. 
setwd(basedir)

# Load libs 
library(data.table)
library(dplyr)

# 2002 --- we have data starting July  (20020701 20021231)
# -----------------------------------------------------------

# Read in the data 
cs2002_machine_domain  <- fread("data/media/comScore/views_duration_by_machine_id_domain/cs2002_by_machine_domain.csv")
cs2002_domain_cat      <- fread("data/media/comScore/unique_domain_cat/cs2002_unique_domains_shalla_ml1_porn.csv")
#cs2002_dem <- fread("data/comscore/dem/demographics2002.csv")

cs2002_t <- inner_join(cs2002_machine_domain, cs2002_domain_cat)

cs2002_porn <- 
cs2002_t %>%
group_by(machine_id) %>%
summarise(porn_time = sum(as.numeric(shalla_category=='porn')*as.numeric(total_duration), na.rm=T), porn_views = sum(as.numeric(shalla_category=='porn')*as.numeric(total_pages), na.rm=T))

mean(cs2002_t$shalla_category=='porn', na.rm=T)
#[1] 0.3929881

median(cs2002_porn$porn_time)
median(cs2002_porn$porn_views)


# Read in the data 
cs2008_machine_domain  <- fread("data/media/comScore/views_duration_by_machine_id_domain/cs2008_by_machine_domain.csv")
cs2008_domain_cat      <- fread("data/media/comScore/unique_domain_cat/cs2008_unique_domains_shalla_ml1_porn.csv")
#cs2002_dem <- fread("data/comscore/dem/demographics2002.csv")

cs2008_t <- inner_join(cs2008_machine_domain, cs2008_domain_cat)
mean(cs2008_t$shalla_category=='porn', na.rm=T)

cs2008_porn <- 
cs2008_t %>%
group_by(machine_id) %>%
summarise(porn_time = sum(as.numeric(shalla_category=='porn')*as.numeric(total_duration), na.rm=T), porn_views = sum(as.numeric(shalla_category=='porn')*as.numeric(total_pages), na.rm=T))

median(cs2008_porn$porn_time)
median(cs2008_porn$porn_views)

# Read in the data 
cs2011_machine_domain  <- fread("data/media/comScore/views_duration_by_machine_id_domain/cs2011_by_machine_domain.csv")
cs2011_domain_cat      <- fread("data/media/comScore/unique_domain_cat/cs2011_unique_domains_shalla_ml1_porn.csv")

cs2011_t <- inner_join(cs2011_machine_domain, cs2011_domain_cat)

cs2011_porn <- 
cs2011_t %>%
group_by(machine_id) %>%
summarise(porn_time = sum(as.numeric(shalla_category=='porn')*as.numeric(total_duration), na.rm=T), porn_views = sum(as.numeric(shalla_category=='porn')*as.numeric(total_pages), na.rm=T), year=2011)

median(cs2011_porn$porn_time)
median(cs2011_porn$porn_views)


# Read in the data 
cs2013_machine_domain  <- fread("data/media/comScore/views_duration_by_machine_id_domain/cs2013_by_machine_domain.csv")
cs2013_domain_cat      <- fread("data/media/comScore/unique_domain_cat/cs2013_unique_domains_shalla_ml1_porn.csv")

cs2013_t <- inner_join(cs2013_machine_domain, cs2013_domain_cat)

cs2013_porn <- 
cs2013_t %>%
group_by(machine_id) %>%
summarise(porn_time = sum(as.numeric(shalla_category=='porn')*as.numeric(total_duration), na.rm=T), porn_views = sum(as.numeric(shalla_category=='porn')*as.numeric(total_pages), na.rm=T), year=2013)

median(cs2013_porn$porn_time)
median(cs2013_porn$porn_views)
