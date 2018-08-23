library(valbuhayra)
library(dplyr)
library(sf)

# wm=st_read('/home/delgado/hykli/load_to_postgis/latest.geojson')
wm0=st_read('/home/delgado/webserver/load_to_postgis/latest.geojson')
wm1=st_read('/home/delgado/webserver/load_to_postgis/latest-1-month.geojson')
wm2=st_read('/home/delgado/webserver/load_to_postgis/latest-2-month.geojson')
wm3=st_read('/home/delgado/webserver/load_to_postgis/latest-3-month.geojson')


library(purrr)
library(magrittr)

mutate_and_transf = function(wm) {
  if('id_cogerh' %in% colnames(wm))
  {
    wm %<>% mutate(id_funceme=ifelse(is.na(id_funceme),id_cogerh,id_funceme)) %>% mutate_if(is.factor,as.character) %>% select(-id_cogerh)
  }
  wm %<>% st_transform(.,32724)
}

wm=list(wm0,wm1,wm2,wm3)
wm %<>% map(mutate_and_transf)
wm %<>% do.call(rbind,.)

setwd('/home/delgado/proj/valbuhayra')
save(wm,file='data/watermasks.RData')

library(devtools)
document()

# plot(head(wm[15000,]))
setwd("..")
install("valbuhayra")
library(valbuhayra)
head(wm)
