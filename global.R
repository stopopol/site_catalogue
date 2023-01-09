library(dplyr)

siteList <- read.csv(file = 'data/lter_europe_sites.csv', sep=';')
socioecoList <- read.csv(file = 'data/socioeco.csv', sep=';')[ ,c('id_suffix', 'socioeco', 'popdensity','avg_tillage')]
fullSiteList <- merge(x = siteList, y = socioecoList, by = "id_suffix", all.x = TRUE)
