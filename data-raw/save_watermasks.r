library(valbuhayra)
library(dplyr)
library(sf)

# wm0=st_read('/home/delgado/webserver/load_to_postgis/latest.geojson',stringsAsFactors=FALSE)
# wm1=st_read('/home/delgado/webserver/load_to_postgis/latest-1-month.geojson',stringsAsFactors=FALSE)
# wm2=st_read('/home/delgado/webserver/load_to_postgis/latest-2-month.geojson',stringsAsFactors=FALSE)
# wm3=st_read('/home/delgado/webserver/load_to_postgis/latest-3-month.geojson',stringsAsFactors=FALSE)

wm0=st_read('/home/delgado/hykli/load_to_postgis/latest.geojson',stringsAsFactors=FALSE)
wm1=st_read('/home/delgado/hykli/load_to_postgis/latest-1-month.geojson',stringsAsFactors=FALSE)
wm2=st_read('/home/delgado/hykli/load_to_postgis/latest-2-month.geojson',stringsAsFactors=FALSE)
wm3=st_read('/home/delgado/hykli/load_to_postgis/latest-3-month.geojson',stringsAsFactors=FALSE)

library(lubridate)
library(purrr)
library(magrittr)

mutate_and_transf = function(wm) {
  if('id_cogerh' %in% colnames(wm))
  {
    wm %<>% mutate(id_funceme=ifelse(is.na(id_funceme),id_cogerh,id_funceme)) %>% mutate_if(is.factor,as.character) %>% select(-id_cogerh)
  }
  wm %<>% st_transform(.,32724)
  wm %<>% mutate(ingestion_time=force_tz(ingestion_time,'UTC'))
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
