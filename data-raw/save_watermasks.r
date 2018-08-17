library(valbuhayra)
library(dplyr)
library(sf)

wm=st_read('/home/delgado/hykli/load_to_postgis/latest.geojson')

colnames(wm)



if('id_cogerh' %in% colnames(wm))
{
  wm=wm %>% mutate(id_funceme=ifelse(is.na(id_funceme),id_cogerh,id_funceme)) %>% select(-id_cogerh)
}



setwd('/home/delgado/proj/valbuhayra')
save(wm,file='data/watermasks.RData')

library(devtools)
document()

# plot(head(wm[15000,]))
setwd("..")
install("valbuhayra")
library(valbuhayra)
head(wm)
