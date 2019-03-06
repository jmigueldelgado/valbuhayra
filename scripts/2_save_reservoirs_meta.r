#########################################+
# Get metadata for reservoir validation###
#########################################+

library(dplyr)
library(sf)
library(jsonlite)
library(tidyr)
library(readxl)
library(dplyr)
library(purrr)
library(magrittr)

setwd("C:/Users/dobkowitz/DownloadReservoirData")

# Find out which of our reservoirs can be found in FUNCEME database ####

request='http://api.funceme.br/rest/acude/reservatorio?limit=0'

raw=fromJSON(request)
df=data_frame(cod=raw$list$cod,name=raw$list$nome,height_spillway=raw$list$cota_sangria,height_bathymetry=raw$list$cota_batimetria,height_reference=raw$list$cota_referencia,district=raw$list$municipio,region=raw$list$regiao,capacity=raw$list$capacidade,longitude=raw$list$longitude,latitude=raw$list$latitude,maximum_height=raw$list$altura_maxima,construction=raw$list$ano_construcao)

reservoirs=df %>% drop_na(longitude,latitude) %>% st_as_sf(coords=c("longitude","latitude"))
reservoirs=st_set_crs(reservoirs,4326)
reservoirs=st_transform(reservoirs,32724)

save(reservoirs,file='data/reservoirs.RData')

# Get CAVs of identified reservoirs from FUNCEME API ####

request='http://api.funceme.br/rest/acude/referencia-cav?limit=0'

cav=fromJSON(request)
CAV=bind_cols(cav$list)
CAV %<>% mutate_if(is.character,as.numeric)

save(CAV,file='data/cav.RData')
