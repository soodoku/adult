#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

library(boilerpipeR)
library(RCurl)

setwd("~/scrape_urls")

a1 <- as.numeric(args[1])
a2 <- as.numeric(args[2])
a3 <- args[3]

urls100 <- readLines("unique_urls.txt") # , stringsAsFactors = FALSE
urls100 <- urls100[a1:a2]
urls100 <- gsub("\"", "", urls100)
#print(dim(urls100))

setwd(a3)
for(i in 1:length(urls100)) { #length(urls100)  11655 23069 33000 34176
  
  page <- ""
  url <- urls100[i]
  try(page <- getURLContent(paste0("http://", url), .opts=curlOptions(followlocation=TRUE, timeout=2, maxredirs=20)), silent = TRUE)
  try(maintext <- ArticleExtractor(page, asText = TRUE), silent = TRUE)
  
  writeLines(maintext, paste0("url_", i, ".txt"))
  
}

print(i)

