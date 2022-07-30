"

summarize by machine, domain
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
cs2002 <- fread("cs2002_by_machine_date_domain.csv")

# Summarize data > per machine_id > per domain > total_time, total_page_views, n_unique_days 
by_machine_domain <- 
cs2002 %>%
group_by(machine_id, domain_name) %>%
summarise(total_duration=sum(total_duration, na.rm=T), total_pages=sum(total_pages, na.rm=T), site_category_id = mean(site_category_id), n_dates = length(unique(date)))

# Write out
write.csv(by_machine_domain, file="cs2002_by_machine_domain.csv", row.names=F)

# 2004
# -----------

# Read in the data
cs2004 <- fread("cs2004_by_machine_date_domain.csv")

by_machine_domain <- 
cs2004 %>%
group_by(machine_id, domain_name) %>%
summarise(total_duration=sum(total_duration, na.rm=T), total_pages=sum(total_pages, na.rm=T), n_dates = length(unique(event_date)))

# Write out
write.csv(by_machine_domain, file="cs2004_by_machine_domain.csv", row.names=F)

# 2006
# -----------

# Read in the data
cs2006 <- fread("cs2006_by_machine_date_domain.csv")

by_machine_domain <- 
cs2006 %>%
group_by(machine_id, domain_name) %>%
summarise(total_duration=sum(total_duration, na.rm=T), total_pages=sum(total_pages, na.rm=T), n_dates = length(unique(event_date)))

# Write out
write.csv(by_machine_domain, file="cs2006_by_machine_domain.csv", row.names=F)

# 2007
# -----------

# Read in the data
cs2007 <- fread("cs2007_by_machine_date_domain.csv")

by_machine_domain <- 
cs2007 %>%
group_by(machine_id, domain_name) %>%
summarise(total_duration=sum(total_duration, na.rm=T), total_pages=sum(total_pages, na.rm=T), n_dates = length(unique(event_date)))

# Write out
write.csv(by_machine_domain, file="cs2007_by_machine_domain.csv", row.names=F)

# 2008
# -----------

# Read in the data
cs2008 <- fread("cs2008_by_machine_date_domain.csv")

by_machine_domain <- 
cs2008 %>%
group_by(machine_id, domain_name) %>%
summarise(total_duration=sum(total_duration, na.rm=T), total_pages=sum(total_pages, na.rm=T), n_dates = length(unique(event_date)))

# Write out
write.csv(by_machine_domain, file="cs2008_by_machine_domain.csv", row.names=F)

# 2009
# -----------

# Read in the data
cs2009 <- fread("cs2009_by_machine_date_domain.csv")

by_machine_domain <- 
cs2009 %>%
group_by(machine_id, domain_name) %>%
summarise(total_duration=sum(total_duration, na.rm=T), total_pages=sum(total_pages, na.rm=T), n_dates = length(unique(event_date)))

# Write out
write.csv(by_machine_domain, file="cs2009_by_machine_domain.csv", row.names=F)

# 2010
# -----------

# Read in the data
cs2010 <- fread("cs2010_by_machine_date_domain.csv")

by_machine_domain <- 
cs2010 %>%
group_by(machine_id, domain_name) %>%
summarise(total_duration=sum(total_duration, na.rm=T), total_pages=sum(total_pages, na.rm=T), n_dates = length(unique(event_date)))

# Write out
write.csv(by_machine_domain, file="cs2010_by_machine_domain.csv", row.names=F)


# 2011
# -----------

# Read in the data
cs2011 <- fread("cs2011_by_machine_date_domain.csv")

by_machine_domain <- 
cs2011 %>%
group_by(machine_id, domain_name) %>%
summarise(total_duration=sum(total_duration, na.rm=T), total_pages=sum(total_pages, na.rm=T), n_dates = length(unique(event_date)))

# Write out
write.csv(by_machine_domain, file="cs2011_by_machine_domain.csv", row.names=F)

# 2012
# -----------

# Read in the data
cs2012 <- fread("cs2012_by_machine_date_domain.csv")

by_machine_domain <- 
cs2012 %>%
group_by(machine_id, domain_name) %>%
summarise(total_duration=sum(total_duration, na.rm=T), total_pages=sum(total_pages, na.rm=T), n_dates = length(unique(event_date)))

# Write out
write.csv(by_machine_domain, file="cs2012_by_machine_domain.csv", row.names=F)


# 2013
# -----------

# Read in the data
cs2013 <- fread("cs2013_by_machine_date_domain.csv")

by_machine_domain <- 
cs2013 %>%
group_by(machine_id, domain_name) %>%
summarise(total_duration=sum(total_duration, na.rm=T), total_pages=sum(total_pages, na.rm=T), n_dates = length(unique(event_date)))

# Write out
write.csv(by_machine_domain, file="cs2013_by_machine_domain.csv", row.names=F)


