setwd("/Users/aguess/Dropbox/web analysis/data/yg")
load("unique_urls.RData")
urls100 <- read.csv("unique_urls_100k.txt", stringsAsFactors = FALSE)
urls100 <- urls100$us.mg6.mail.yahoo.com.neo.launch..rand.7hej9u1h3rnn2.6463884649

writeLines(urls100[1:10,1], "urls_10.txt")

head(urls100)
urls100[1,1]
urls100[10,1]

dim(unique.urls)
head(unique.urls)
unique.urls$unique.urls[2200000]


library(RCurl)
library(rvest)

#page <- readLines(paste0("http://", urls100[1,1]))
page <- getURL(paste0("http://", urls100[1,1]), .opts=curlOptions(followlocation=TRUE))
writeLines(page, "url.txt")

page <- html_session(paste0("http://", urls100[1,1]))
page %>% html_nodes("p") %>% html_text()

download.file()

# https://cran.r-project.org/web/packages/boilerpipeR/index.html
library(boilerpipeR)

url <- "blog.rstudio.org/2014/05/09/reshape2-1-4/"
page <- getURL(paste0("http://", url), .opts=curlOptions(followlocation=TRUE))
maintext <- ArticleExtractor(page, asText = TRUE)

sink()
cat(maintext)
sink()

writeLines(maintext, "text/urltest.txt")

setwd("/Users/aguess/Documents/Columbia/Dissertation/jmp2/scrape_pages/text")
for(i in 44:100) { #length(urls100)
  
  page <- ""
  url <- urls100[i]
  try(page <- getURL(paste0("http://", url), .opts=curlOptions(followlocation=TRUE, timeout=1, maxredirs=20)), silent = TRUE)
  try(maintext <- ArticleExtractor(page, asText = TRUE), silent = TRUE)
  
  writeLines(maintext, paste0("url_", i, ".txt"))
  
}
