#devtools::install_github("kbenoit/quanteda")
library(quanteda)
library(methods)
library(parallel)

setwd("~/scrape_urls")

# Calculate the number of cores
no_cores <- detectCores() - 1

# Initiate cluster
cl <- makeCluster(no_cores)
clusterEvalQ(cl, library(quanteda))

u <- parLapply(cl, paste0("u", seq(1, 22)), function(d) {

  # Create corpus from multiple text files
  corpus(textfile(paste0(d, "/*.txt"), cache = FALSE, docvarsfrom = "filenames", docvarnames = c("batch", "url")))

})

stopCluster(cl)

corpus_all <- u[[1]] + u[[2]] + u[[3]] + u[[4]] + u[[5]] + u[[6]] + u[[7]] + u[[8]] + u[[9]] + u[[10]]
corpus_all <- corpus_all + u[[11]] + u[[12]] + u[[13]] + u[[14]] + u[[15]] + u[[16]] + u[[17]] + u[[18]] + u[[19]] + u[[20]]
corpus_all <- corpus_all + u[[21]] + u[[22]]

print("done combining, now dfm")

# Create document-feature matrix from corpus
urls_dfm <- dfm(corpus_all, ignoredFeatures = stopwords("english"), stem = TRUE) #[1:99999]

print("done with dfm!")

save(urls_dfm, file = "urls_dfm_all.RData")

print("SAVED")

