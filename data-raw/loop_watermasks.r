# library(devtools)
# setwd("..")
# install('valbuhayra')
library(valbuhayra)
library(dplyr)
library(sf)
library(jsonlite)
library(ggplot2)
library(purrr)
library(lubridate)

acudei=96

test = wm
st_geometry(test) = NULL

head(test$ingestion_time)

areaBUH = left_join(test,reservoirs) %>%
  na.omit(cod) %>%
  select(id_funceme, cod, ingestion_time, area) %>%
  filter(cod==acudei) %>%
  mutate(area=area/10^6)

volAPI=areaBUH %>%
  split(.$ingestion_time) %>%
  map(~requestVolumes(.$cod,.$ingestion_time,1)) %>%
  bind_rows



# areas in CAV are given in km2, volumes in hm3
cav=filter(CAV,reservatorio==acudei)

# interp = spline(cav$volume,cav$area,xout=volAPI$value)
interp = approx(cav$volume,cav$area,xout=volAPI$value)

areaAPI = volAPI %>% mutate(value=interp$y)

api = areaAPI %>% rename(api=value) %>% mutate(requestDate=as.POSIXct(trunc(requestDate,'day'))) %>% select(requestDate,api)
buhayra = areaBUH %>% rename(buhayra=area,requestDate=ingestion_time) %>% mutate(requestDate=as.POSIXct(trunc(requestDate,'day'))) %>% select(id_funceme,cod,buhayra,requestDate)


api$requestDate
buhayra$requestDate %>% format(.,tz='America/Fortaleza')

left_join(api,buhayra)


filter(wm,id_funceme==12542) %>% plot
