"
Produce a file with Unique Domain Names, URLs

"
# Set dir
ifelse(grepl("Gaurav", getwd()), setwd(basedir), setwd("/Users/aguess/Dropbox/"))


# From AG
unique.urls <- unique(wakoopa$url)
unique.urls <- as.data.frame(unique.urls)
unique.domains <- unique(wakoopa$domain)

save(unique.urls, file = "unique_urls.RData")
save(unique.domains, file = "unique_domains.RData")

# Convert Rdata files to one domain/url per line
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Load domain data
load("web analysis/data/yg/unique_domains.RData")

# Output: one domain per line
fileConn<-file("web analysis/data/unique_domains.txt")
writeLines(unique.domains[1:length(unique.domains)], fileConn)
close(fileConn)

# Load url data
load("web analysis/data/yg/unique_urls.RData")

# Output: one url per line
fileConn<-file("web analysis/data/yg/unique_urls.txt")
writeLines(as.name(as.character(unique.urls[,1])), fileConn)
close(fileConn)

# Take large random sample
set.seed(31415)
fileConn<-file("web analysis/data/yg/unique_urls_100k.txt")
temp <- as.character(unique.urls[sample(nrow(unique.urls),100000),1])
writeLines(noquote(temp), fileConn)
close(fileConn)
