library(valbuhayra)
library(dplyr)
library(sf)
library(jsonlite)
library(ggplot2)
library(purrr)


# filter(CAV,reservatorio==cogerh) %>%
#   ggplot(.) + geom_point(aes(area,volume))

test = wm

st_geometry(test) = NULL
test = left_join(test,reservoirs) %>% na.omit(cod) %>% select(id_funceme, cod, ingestion_time, area)

test1 = test %>% filter(cod==96)
test1
vols=test1 %>%
  split(.$ingestion_time) %>%
  map(~getVols(.$cod,.$ingestion_time,1)) %>%
  bind_rows

  vols

# areas are given in km2!!!

head(CAV)


cav=filter(CAV,reservatorio==96)
cav
test

test1
vols
vols$value
spline(cav$volume,cav$area,xout=vols$value)
approx(cav$volume,cav$area,xout=vols$value)
test1
filter(wm,id_funceme==12542) %>% plot
