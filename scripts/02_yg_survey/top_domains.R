names(porn.indiv)
unique_prn <- select(porn.indiv, domain, porn) %>%
  distinct(domain) %>%
  group_by(porn) %>%
  summarise(num_domains = n())
2911/(262485+2911)
# 1.1% unique domains = porn

99415/(99415+6220026)
# 1.57% all visits = porn

top_domains <- select(porn.indiv, domain, porn) %>%
  filter(porn == 1) %>%
  group_by(domain) %>%
  mutate(visits = n()) %>%
  distinct(domain) #%>%
#arrange(desc(visits))

top_domains <- top_domains[order(top_domains$visits, decreasing = TRUE),]

# pmxid                domain porn visits
# 1  46799653        g.e-hentai.org    1  12672
# 2       937           pornhub.com    1   8099
# 3   2061741           xvideos.com    1   5587
# 4   2009176          xhamster.com    1   4974
# 5   2598004        myfreecams.com    1   4147
# 6   2397958 adultfriendfinder.com    1   3733
# 7       937         adam4adam.com    1   3404
# 8       937           manhunt.net    1   3028
# 9   2061741        literotica.com    1   2513
# 10  2412386         streamate.com    1   2297


