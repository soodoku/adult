library(boilerpipeR)
library(RCurl)

setwd("~/Documents/prn_project/data")
#load("unique_urls.RData")
urls100 <- readLines("unique_urls_100k.txt") # , stringsAsFactors = FALSE
#urls100 <- urls100$us.mg6.mail.yahoo.com.neo.launch..rand.7hej9u1h3rnn2.6463884649
head(urls100)
tail(urls100)

urls100 <- gsub("\"", "", urls100)

setwd("text_try3")
for(i in 1:34175) { #length(urls100)  11655 23069 33000 34176
  
  page <- ""
  url <- urls100[i]
  try(page <- getURLContent(paste0("http://", url), .opts=curlOptions(followlocation=TRUE, timeout=2, maxredirs=20)), silent = TRUE)
  try(maintext <- ArticleExtractor(page, asText = TRUE), silent = TRUE)
  
  writeLines(maintext, paste0("url_", i, ".txt"))
  
}
