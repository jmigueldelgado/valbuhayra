# library(devtools)
# setwd("..")
# install('valbuhayra')
library(valbuhayra)
library(dplyr)
library(sf)
library(jsonlite)
library(purrr)
library(lubridate)

test = wm
st_geometry(test) = NULL

areaBUH = left_join(test,reservoirs) %>%
  na.omit(cod) %>%
  select(id_funceme, cod, ingestion_time, area) %>%
  mutate(area=area/10^6) %>%
  split(.$cod)


listOut=list()
for(i in seq(1,length(areaBUH))) {
  cat(i,'\n')
  listOut[[i]]=request_and_lookup(areaBUH[[i]])
}

save(listOut,file='data/list_request.RData')

#########################################################

load(file='data/list_request.RData')

validation=do.call(rbind,listOut)

head(validation)

library(viridis)
library(ggplot2)

validation %>% mutate(requestDate=as.factor(requestDate)) %>% #group_by(cod) %>%
  # filter(!(abs(buhayra-median(buhayra)) > 2*sd(buhayra))) %>%
  # ungroup %>%
  ggplot(.) +
    geom_point(aes(x=api,y=buhayra)) +
    geom_abline(intercept=0) +
    coord_fixed() +
    # scale_color_viridis(discrete=TRUE) +
    labs(title="Estimated area of water bodies (April to August 2018)",
      subtitle=expression(paste("estimated (",italic("github.com/jmigueldelgado/buhayra"),") vs. measured (",italic("api.funceme.br"),")")),
      x=expression("measured by FUNCEME in"~km^2),
      y=expression("estimated by buhayra in"~km^2)) +
    theme_bw()
validation %>% mutate(requestDate=as.factor(requestDate)) %>% filter(api<5) %>% #group_by(cod) %>%
  # filter(!(abs(buhayra-median(buhayra)) > 2*sd(buhayra))) %>%
  # ungroup %>%
  ggplot(.) +
    geom_point(aes(x=api,y=buhayra)) +
    geom_abline(intercept=0) +
    coord_fixed() +
    # scale_color_viridis(discrete=TRUE) +
    labs(title="Estimated area of small water bodies (<500 ha, April to August 2018)",
      subtitle=expression(paste("estimated (",italic("github.com/jmigueldelgado/buhayra"),") vs. measured (",italic("api.funceme.br"),")")),
      x=expression("measured by FUNCEME in"~km^2),
      y=expression("estimated by buhayra in"~km^2)) +
    theme_bw()



request_and_lookup = function(areaBUH) {
  volAPI= areaBUH[[1]] %>%
    split(.$ingestion_time) %>%
    map(~requestVolumes(.$cod[1],.$ingestion_time[1],1)) %>%
    bind_rows

  # areas in CAV are given in km2, volumes in hm3
  cav=filter(CAV,reservatorio==areaBUH$cod[1])

  # interp = spline(cav$volume,cav$area,xout=volAPI$value)
  interp = approx(cav$volume,cav$area,xout=volAPI$value)

  areaAPI = volAPI %>% mutate(value=interp$y)

  api = areaAPI %>% rename(api=value) %>% mutate(requestDate=as.POSIXct(trunc(requestDate,'day'))) %>% select(requestDate,api)
  buhayra = areaBUH %>% rename(buhayra=area,requestDate=ingestion_time) %>% mutate(requestDate=as.POSIXct(trunc(requestDate,'day'))) %>% select(id_funceme,cod,buhayra,requestDate)

  val=left_join(api,buhayra)
  return(val)
}
