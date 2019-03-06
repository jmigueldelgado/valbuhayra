# Matching jrc ids with funceme ids ####

library(sf)
library(dplyr)
library(magrittr)

setwd("C:/Users/dobkowitz/DownloadReservoirData")

load("data/reservoirs_hu.RData")
load("data/reservoirs.RData")

id_jrc_funceme <- list()

for(h in 1:12){
hu1 <- hu_tables[[h]]

res_jrc <- st_as_sf(hu1, wkt = c("geom_max"),crs=4326) 
res_jrc <- st_transform(res_jrc, 32724)

id_jrc=array()

for(i in seq(1,nrow(reservoirs))) {
  dsts=st_distance(x=reservoirs[i,],y=res_jrc) %>% as.numeric
  if(min(dsts)<1000) {
    id_jrc[i]= dsts %>% which.min %>% res_jrc$id[.]
  } else {
    id_jrc[i]=NA
  }
}

#length(id_funceme)
#nrow(reservoirs)
#length(which(is.na(id_funceme)))

reservoirs$id_jrc=id_jrc

id_jrc <- data.frame(id_fun = reservoirs$cod, id_jrc = reservoirs$id_jrc)
id_jrc_funceme[[h]] <- subset(id_jrc, !is.na(id_jrc))

print(paste("hu", h, "of 12 done"))
}

save(id_jrc_funceme, file='data/id_jrc_funceme.RData')
