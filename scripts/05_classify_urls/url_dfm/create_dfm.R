#devtools::install_github("kbenoit/quanteda")
library(quanteda)

# Create corpus from multiple text files
text1 <- textfile("~/Documents/Columbia/Dissertation/jmp2/scrape_pages/text/u1/*.txt", cache = FALSE,
                  docvarsfrom = "filenames", docvarnames = c("whichdoc", "urlnum"))
summary(corpus(text1), 5)
texts(text1)[1]
# ~ 5 mins x 22 = 110 min = 1 hour 50 mins

# Create document-feature matrix from corpus
urls_dfm <- dfm(corpus(text1), ignoredFeatures = stopwords("english"), stem = TRUE) #[1:99999]
# 66 sec

setwd("/Users/aguess/Dropbox/web analysis/data/yg/urls_text")
#save(urls_dfm, file = "dfm_1.RData")
load("dfm_1.RData")

text2 <- textfile("~/Documents/Columbia/Dissertation/jmp2/scrape_pages/text/u2/*.txt", cache = FALSE,
                  docvarsfrom = "filenames", docvarnames = c("whichdoc", "urlnum"))
urls_dfm2 <- dfm(corpus(text2), ignoredFeatures = stopwords("english"), stem = TRUE) #[1:99999]

corpus_1_2 <- corpus(text1) + corpus(text2) # docvars = data.frame(corpus = rep("Text1", 100000))
summary(corpus_1_2, 5)

paste0("u", seq(1, 22))
