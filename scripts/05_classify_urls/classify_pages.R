# rm(list=ls(all=TRUE))

## Load packages
library(quanteda)
library(dplyr)
library(glmnet) # for lasso/ridge regression

## Load dfm of all texts in Wakoopa data
setwd("~/Dropbox/web analysis/data/yg/urls_text/")
load("urls_dfm_all.RData")

## remove stopwords, single letters as features
urls_dfm <- selectFeatures(urls_dfm, unique(c(stopwords("english"), letters)), "remove")
topfeatures(urls_dfm, 50)
urls_dfm

## take random sample of 10,000 features
urls_dfm <- trim(urls_dfm, minCount = 20, nsample = 10000)

## Load URL list, set ordering, grab labels

#urls <- readLines("../unique_urls.txt")
#urls <- gsub("\"", "", urls)
#head(urls)

wakoopa <- select(wakoopa, domain, url, category, subcategory) %>%
                  distinct(url)
wakoopa <- rbind(c(NA, "url", NA, NA), wakoopa) # to match irrelevant first row of urls which I accidentally "scraped"

text_order <- docnames(urls_dfm[1:100000])
head(text_order, 20)
text_order <- gsub(".txt", "", as.vector(unlist(sapply(strsplit(text_order, "_"), function(x) x[2]))))
text_order <- as.numeric(text_order)
head(text_order[order(text_order)])
head(order(text_order))
#urls[head(order(text_order))]

wakoopa[1:100000,] <- wakoopa[1:100000,][text_order,]
wakoopa[100001:200000,] <- wakoopa[100001:200000,][text_order,]
wakoopa[200001:300000,] <- wakoopa[200001:300000,][text_order,]
wakoopa[300001:400000,] <- wakoopa[300001:400000,][text_order,]
wakoopa[400001:500000,] <- wakoopa[400001:500000,][text_order,]
wakoopa[500001:600000,] <- wakoopa[500001:600000,][text_order,]
wakoopa[600001:700000,] <- wakoopa[600001:700000,][text_order,]
wakoopa[700001:800000,] <- wakoopa[700001:800000,][text_order,]
wakoopa[800001:900000,] <- wakoopa[800001:900000,][text_order,]
wakoopa[900001:1000000,] <- wakoopa[900001:1000000,][text_order,]

wakoopa[1000001:1100000,] <- wakoopa[1000001:1100000,][text_order,]
wakoopa[1100001:1200000,] <- wakoopa[1100001:1200000,][text_order,]
wakoopa[1200001:1300000,] <- wakoopa[1200001:1300000,][text_order,]
wakoopa[1300001:1400000,] <- wakoopa[1300001:1400000,][text_order,]
wakoopa[1400001:1500000,] <- wakoopa[1400001:1500000,][text_order,]
wakoopa[1500001:1600000,] <- wakoopa[1500001:1600000,][text_order,]
wakoopa[1600001:1700000,] <- wakoopa[1600001:1700000,][text_order,]
wakoopa[1700001:1800000,] <- wakoopa[1700001:1800000,][text_order,]
wakoopa[1800001:1900000,] <- wakoopa[1800001:1900000,][text_order,]
wakoopa[1900001:2000000,] <- wakoopa[1900001:2000000,][text_order,]

wakoopa[2000001:2100000,] <- wakoopa[2000001:2100000,][text_order,]
wakoopa[2100001:2200000,] <- wakoopa[2100001:2200000,][text_order,]
wakoopa[2200001:nrow(wakoopa),] <- wakoopa[2200001:nrow(wakoopa),][text_order[1:length(2200001:nrow(wakoopa))],]

head(wakoopa$url)
head(wakoopa)

set.seed(9382)
train_set <- c(rep(1, nrow(wakoopa)/5), rep(0, 4*nrow(wakoopa)/5))
train_set <- sample(train_set)
test_set <- 1 - train_set

train_dfm <- urls_dfm[which(train_set == 1)]

porn <- ifelse(wakoopa$category == "Adult", 1, 0)
porn <- ifelse(is.na(porn), 0, porn)
table(porn, useNA = "always")
head(porn[which(train_set == 1)])
  
## 1. Predict porn vs. non-porn

# training
set.seed(9382)
porn_predict <- cv.glmnet(train_dfm, as.factor(porn[train_set == 1]), family = "binomial", alpha = 0, type.logistic = "modified.Newton") #, standardize = FALSE)
summary(porn_predict)
dim(coef(porn_predict))
head(coef(porn_predict))

# grab coefs, reverse order
coefs <- cbind(features(urls_dfm), coef(porn_predict)[-1])
coefs <- coefs[order(as.numeric(coefs[,2]), decreasing = TRUE),]
head(coefs, 50); tail(coefs, 50)

# [1,] "naku"            "13.1135013565062"
# [2,] "ethnicity:whit"  "8.66269938987409"
# [3,] "kiranta"         "8.42310905052922"
# [4,] "kaisou"          "8.37424123303664"
# [5,] "dokubari"        "8.18842363881718"
# [6,] "yakiniku"        "8.11343152180399"
# [7,] "natto"           "7.78707211546016"
# [8,] "drowtal"         "7.40392453689588"
# [9,] "tino"            "7.36740050084627"
# [10,] "dourden"         "7.2116421088945" 
# [11,] "zettai"          "7.19192795121043"
# [12,] "dumbl"           "6.52063820551185"
# [13,] "akaki"           "6.51779408519199"
# [14,] "findersm"        "6.43656252848842"
# [15,] "m-h"             "6.35273145315553"
# [16,] "rivulet"         "6.32738347947966"
# [17,] "re-ignit"        "6.22666688687619"
# [18,] "terran"          "6.17171059305627"
# [19,] "freesex"         "6.13585261082855"
# [20,] "adroit"          "6.07055473557834"
# [21,] "#b1b1b1"         "5.90112029451558"
# [22,] "spoog"           "5.82485813228131"
# [23,] "r@g"             "5.66804346276313"
# [24,] "sheepl"          "5.26336535637718"
# [25,] "shinobu"         "5.23872350258758"
# [26,] "gyaru"           "5.05072692171797"
# [27,] "blue-skin"       "5.04522900513023"
# [28,] "imaginari"       "5.03792919302113"
# [29,] "anikka"          "5.00402039840224"
# [30,] "romina"          "4.81087729779096"
# [31,] "newlin"          "4.77887803346018"
# [32,] "footloverd"      "4.7668125382305" 
# [33,] "unhook"          "4.69645650360803"
# [34,] "kazuhiro"        "4.69287856660258"
# [35,] "undid"           "4.63439561278999"
# [36,] "alem"            "4.59385579862919"
# [37,] "minibus"         "4.59089789383517"
# [38,] "pube"            "4.56455487710148"
# [39,] "quaver"          "4.46266985794227"
# [40,] "wtseticket"      "4.23404959666196"
# [41,] "hiroki"          "4.13942550803609"
# [42,] "htdoc"           "4.04945670187711"
# [43,] "allowfullscreen" "4.02529307404241"
# [44,] "citron"          "4.0200610417848" 
# [45,] "doujin-mo"       "3.97686035573741"
# [46,] "sapient"         "3.93700817734291"
# [47,] "@4tube"          "3.93621640323909"
# [48,] "kawaraya"        "3.76557774962791"
# [49,] "over-us"         "3.75842730255458"
# [50,] "what'd"          "3.73019728461267"

# make predictions
preds <- predict(porn_predict, urls_dfm, s = "lambda.min", type = "response")
preds <- cbind(wakoopa$url, preds)
preds <- preds[order(as.numeric(preds[,2]), decreasing = TRUE),]

#porn.preds <- predict(porn_predict, urls_dfm, type = "class")

head(as.numeric(preds[,2])); tail(preds)
hist(preds); range(preds)
table(porn.preds)

head(preds, 100)
length(which(as.numeric(preds[,2]) > 0.7))
# [1] 4563

# batch2_55009.txt   "\"digiday.com/agencies/inside-sapientnitros-india-arm\""                                                                                                                            
# batch4_41597.txt   "\"fictionmania.tv/stories/readxstory.html?storyID=31976766922428115930\""                                                                                                           
# batch4_41602.txt   "\"fictionmania.tv/stories/readtextstory.html?storyID=31976766922428115930\""                                                                                                        
# batch5_78858.txt   "\"google.com/patents/US7774238?dq=7,774,238&hl=en&sa=X&ei=_o33VMylDoHsoATz2ICoDA&ved=0CB4Q6AEwAA\""                                                                                 
# batch5_78928.txt   "\"google.com/patents/US7774238?dq=online+marketplace&hl=en&sa=X&ei=ysD0VJ-QO_PnsATl8oHwAg&ved=0CHkQ6AEwDQ\""                                                                        
# batch5_78930.txt   "\"google.com/patents/US20100280912?dq=online+marketplace&hl=en&sa=X&ei=ysD0VJ-QO_PnsATl8oHwAg&ved=0CL8BEOgBMBc\""                                                                   
# batch5_78998.txt   "\"google.com/patents/US20100280912?dq=20100280912&hl=en&sa=X&ei=SAr5VJG_C4u3yQT7g4H4DA&ved=0CB4Q6AEwAA\""                                                                           
# batch5_79005.txt   "\"google.com/patents/US20100280912?dq=20100280912&hl=en&sa=X&ei=eO_4VKKWKoyvyATptoLoAw&ved=0CB4Q6AEwAA\""                                                                           
# batch6_26577.txt   "\"jezebel.com/disney-dudes-dicks-what-your-favorite-princes-look-lik-1621694437\""                                                                                                  
# batch6_36555.txt   "\"literotica.com/s/a-young-mans-fancy?page=2\""                                                                                                                                     
# batch6_36556.txt   "\"literotica.com/s/a-young-mans-fancy\""                                                                                                                                            
# batch6_36639.txt   "\"literotica.com/s/moms-big-bed-ch-09?page=5\""                                                                                                                                     
# batch6_39131.txt   "\"manhub.com/tags/cub-bareback\""                                                                                                                                                   
# batch6_84294.txt   "\"nifty.org/nifty/gay/interracial/paper-cuts/paper-cuts-5\""                                                                                                                        
# batch6_84348.txt   "\"nifty.org/nifty/gay/incest/lessons-from-my-dad/lessons-from-my-dad-2\""                                                                                                           
# batch8_12389.txt   "\"sexstories.com/story/36204/i_love_my_son_daniel_1-4_\""                                                                                                                           
# batch8_12404.txt   "\"sexstories.com/story/51968/what_lies_beneath\""                                                                                                                                   
# batch8_12410.txt   "\"sexstories.com/themes/47/Incest/p-9\""                                                                                                                                            
# batch9_1153.txt    "\"wn.com/Oral_Gay_Sucking__totally_naked_men_nude_videos_gay_twinks_muscle_galleries_sucking_cocks\""                                                                               
# batch9_93717.txt   "\"aidmymuscle.com/?ref=msmcombo\""                                                                                                                                                  
# batch10_81246.txt  "\"bea.gov/scb/pdf/internat/bpa/meth/bopmp.pdf\""                                                                                                                                    
# batch12_60883.txt  "\"e-cigarettesreviews.com/coupons\""                                                                                                                                                
# batch12_76284.txt  "\"en.wikipedia.org/wiki/Natt%C5%8D\""                                                                                                                                               
# batch12_78425.txt  "\"en.wikipedia.org/wiki/List_of_current_United_States_Senators\""                                                                                                                   
# batch12_78427.txt  "\"en.wikipedia.org/wiki/List_of_current_United_States_Senators#/media/File:114th_United_States_Congress_Senators.svg\""                                                             
# batch12_82039.txt  "\"en.wikipedia.org/wiki/Chavo_Guerrero_Jr.\""                                                                                                                                       
# batch12_82125.txt  "\"en.wikipedia.org/wiki/A.J._Styles#In_wrestling\""                                                                                                                                 
# batch12_82145.txt  "\"en.wikipedia.org/wiki/A.J._Styles\""                                                                                                                                              
# batch12_82992.txt  "\"en.wikipedia.org/wiki/Ages_of_consent_in_North_America\""                                                                                                                         
# batch12_82995.txt  "\"en.wikipedia.org/wiki/Ages_of_consent_in_North_America#/media/File:Age_of_Consent_-_North_America.svg\""                                                                          
# batch12_82997.txt  "\"en.wikipedia.org/wiki/Ages_of_consent_in_Europe\""                                                                                                                                
# batch12_85113.txt  "\"en.wikipedia.org/wiki/Ultima_Online\""                                                                                                                                            
# batch12_85115.txt  "\"en.wikipedia.org/wiki/Ultima_Online#mediaviewer/File:UO-Kingdom_Reborn.jpg\""                                                                                                     
# batch12_92557.txt  "\"etsycontest.com/share.php?dom=16\""                                                                                                                                               
# batch13_12777.txt  "\"forced-sex-change.blogspot.com\""                                                                                                                                                 
# batch13_14916.txt  "\"forum.xda-developers.com/showthread.php?t=3034811\""                                                                                                                              
# batch13_28117.txt  "\"g.e-hentai.org/g/791238/3a15fd5ed8\""                                                                                                                                             
# batch13_28299.txt  "\"g.e-hentai.org/g/791577/cf2df6c7bd\""                                                                                                                                             
# batch13_30563.txt  "\"g.e-hentai.org/g/794125/e083a3d4aa?p=8\""                                                                                                                                         
# batch13_30621.txt  "\"g.e-hentai.org/g/794087/fa57080a96\""                                                                                                                                             
# batch13_31044.txt  "\"g.e-hentai.org/g/794125/e083a3d4aa\""                                                                                                                                             
# batch13_63165.txt  "\"harpseals.org/help/letters_and_emails/index.php\""                                                                                                                                
# batch14_33675.txt  "\"jollychic.com/special-rotarytable20141217-index.html?lcid=&utm_medium=referral&utm_source=cj&utm_campaign=affiliate&affiliateID=2470763\""                                        
# batch14_33699.txt  "\"jollychic.com/special-rotarytable20141217-index.html?lcid=freegift2014\""                                                                                                         
# batch16_17218.txt  "\"marvel.wikia.com/Norrin_Radd_(Earth-616)\""                                                                                                                                       
# batch16_17220.txt  "\"marvel.wikia.com/Norrin_Radd_(Earth-616)#Girl_on_Board\""                                                                                                                         
# batch16_36240.txt  "\"mistressdestiny.com/forums/showthread.php?t=60325\""                                                                                                                              
# batch17_54429.txt  "\"pocketpussyit.com/place.php\""                                                                                                                                                    
# batch17_89942.txt  "\"quizlet.com/10828132/life-span-chapter-23-flash-cards\""                                                                                                                          
# batch19_4318.txt   "\"sims.wikia.com/wiki/Imaginary_Friend\""                                                                                                                                           
# batch20_88358.txt  "\"thehabibshow.com/tour?id=14462967\""                                                                                                                                              
# batch22_110106.txt "\"us-mg6.mail.yahoo.com/neo/launch?.rand=4r25jqv34f47v#972013122\""                                                                                                                 
# batch22_76569.txt  "\"workplaceservices400.fidelity.com/mybenefits/savings2/mixes/landing\""                                                                                                            
# batch22_84734.txt  "\"yougov-us.wkp.io/frontend/device_setups/10107?step=0\""                                                                                                                           
# batch6_36996.txt   "\"literotica.com/s/a-slaves-journey-begins-ch-11\""                                                                                                                                 
# batch9_47126.txt   "\"youtube.com/watch?v=83EzK5hJoj8\""                                                                                                                                                
# batch6_94165.txt   "\"osxdaily.com/2014/10/14/enable-hey-siri-ios-voice-activation\""                                                                                                                   
# batch12_58839.txt  "\"dudetubeonline.com\""                                                                                                                                                             
# batch16_76943.txt  "\"ncbi.nlm.nih.gov/pmc/articles/PMC3537661\""                                                                                                                                       
# batch13_28531.txt  "\"g.e-hentai.org/g/793433/ede3e48cb8\""                                                                                                                                             
# batch13_28375.txt  "\"g.e-hentai.org/g/793194/bc62c0703c\""                                                                                                                                             
# batch18_46712.txt  "\"seakingsfemfight.com/stories2015/storylynnanne001.html\""                                                                                                                         
# batch13_30331.txt  "\"g.e-hentai.org/g/793865/1d909bf9d3\""                                                                                                                                             
# batch8_12405.txt   "\"sexstories.com/themes/47/Incest/p-6\""                                                                                                                                            
# batch9_97853.txt   "\"allthingslawandorder.blogspot.com/2012/04/law-order-svu-street-revenge-recap.html\""                                                                                              
# batch8_12408.txt   "\"sexstories.com/themes/71/Non-consensual+sex/s-rate/p-2\""                                                                                                                         
# batch4_41598.txt   "\"fictionmania.tv/stories/readxstory.html?storyID=3204699877148769\""                                                                                                               
# batch6_36813.txt   "\"literotica.com/s/teresas-change\""                                                                                                                                                
# batch9_93719.txt   "\"aidmyrotatorcuff.com/rotator-cuff/freezie-wrap-rotator-cold-therapy.php?xid=bc3182dcf56e61f335436cf615e89ffc\""                                                                   
# batch8_12422.txt   "\"sexstories.com/themes/36/first+time\""                                                                                                                                            
# batch22_125354.txt "\"us-mg6.mail.yahoo.com/neo/launch?.rand=8njrik9037btf#3136073185\""                                                                                                                
# batch6_36659.txt   "\"literotica.com/s/you-have-to-go-to-mass-ch-02\""                                                                                                                                  
# batch6_37257.txt   "\"literotica.com/s/the-good-wife-alicia-wants-more\""                                                                                                                               
# batch8_12414.txt   "\"sexstories.com/themes/47/Incest/p-4\""                                                                                                                                            
# batch8_12413.txt   "\"sexstories.com/themes/47/Incest/p-8\""                                                                                                                                            
# batch20_92817.txt  "\"thevalkyrie.com/stories/dtm/breta.txt\""                                                                                                                                          
# batch12_84895.txt  "\"en.wikipedia.org/wiki/U.S._history_of_alcohol_minimum_purchase_age_by_state\""                                                                                                    
# batch2_47481.txt   "\"cnet.com/products/cree-connected-led-bulb/2\""                                                                                                                                    
# batch4_41590.txt   "\"fictionmania.tv/stories/readxstory.html?storyID=1424916991346268343\""                                                                                                            
# batch6_84299.txt   "\"nifty.org/nifty/gay/incest/sounds-like-a-plan\""                                                                                                                                  
# batch8_12407.txt   "\"sexstories.com/themes/47/Incest/p-7\""                                                                                                                                            
# batch4_41612.txt   "\"fictionmania.tv/stories/readhtmlstory.html?storyID=14206665461096540511\""                                                                                                        
# batch13_30339.txt  "\"g.e-hentai.org/g/794109/2d9f723429\""                                                                                                                                             
# batch22_124855.txt "\"us-mg6.mail.yahoo.com/neo/launch?.rand=dtavirfmfltp9#8983683938\""                                                                                                                
# batch4_41588.txt   "\"fictionmania.tv/stories/readxstory.html?storyID=142438431113066815\""                                                                                                             
# batch6_39127.txt   "\"manhub.com/tags/raw-baitbus\""                                                                                                                                                    
# batch6_39128.txt   "\"manhub.com/tags/baitbus-raw\""                                                                                                                                                    
# batch6_37066.txt   "\"literotica.com/s/backdoor-sweetheart-ch-02?page=2\""                                                                                                                              
# batch8_12415.txt   "\"sexstories.com/themes/47/Incest/p-5\""                                                                                                                                            
# batch12_83001.txt  "\"en.wikipedia.org/wiki/Age_of_consent#By_country_or_region\""                                                                                                                      
# batch12_83007.txt  "\"en.wikipedia.org/wiki/Age_of_consent\""                                                                                                                                           
# batch10_81189.txt  "\"bdsmlibrary.com/stories/chapter.php?storyid=10598&chapterid=31241\""                                                                                                              
# batch6_36462.txt   "\"literotica.com/s/trinity-5?page=2\""                                                                                                                                              
# batch12_82998.txt  "\"en.wikipedia.org/wiki/Ages_of_consent_in_South_America\""                                                                                                                         
# batch8_12409.txt   "\"sexstories.com/themes/47/Incest\""                                                                                                                                                
# batch12_77323.txt  "\"en.wikipedia.org/wiki/Sexual_dimorphism\""                                                                                                                                        
# batch12_82127.txt  "\"en.wikipedia.org/wiki/Christopher_Daniels\""                                                                                                                                      
# batch10_93088.txt  "\"blogs.disney.com/oh-my-disney/2013/03/29/imaginary-disney-boyfriend-wishlist?cmp=SMC|none|natural|blgomd|OMDMarch|FB|bfwish-MickeyMouse|InHouse|2015-03-14|repost||esocialmedia\""
# batch6_36494.txt   "\"literotica.com/s/the-face-painter-ch-13?page=2\""                                                                                                                                 
# batch1_24399.txt   "\"amazon.com/A-Menu-Loving-Olivia-Gaines-ebook/product-reviews/B00TXYJU8C/ref=rdr_ext_cr_cm_cr_acr_txt?ie=UTF8&showViewpoints=1\""     

# summarize accuracy
rmse <- mean((y - preds)^2)
print(rmse) # 0.2335971



## 2. Predict news vs. non-news

## 3. Predict political news (conditional on news)



### NOTES

# parse domains - suffix
# "naughty words" in measure_porn - query domain names
# 80% out of the box
# random forest - 4/5 = training
# GS has labeled dataset for news - NYT archive, built classifier
## PREDICT PID STUFF -- NEXT
