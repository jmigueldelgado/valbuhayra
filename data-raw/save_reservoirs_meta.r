library(valbuhayra)
library(dplyr)
library(sf)
library(jsonlite)

request='http://api.funceme.br/rest/acude/reservatorio?limit=0'

raw=fromJSON(request)

df=data_frame(cod=raw$list$cod,name=raw$list$nome,height_spillway=raw$list$cota_sangria,height_bathymetry=raw$list$cota_batimetria,height_reference=raw$list$cota_referencia,district=raw$list$municipio,region=raw$list$regiao,capacity=raw$list$capacidade,longitude=raw$list$longitude,latitude=raw$list$latitude,maximum_height=raw$list$altura_maxima,construction=raw$list$ano_construcao)

library(tidyr)

reservoirs=df %>% drop_na(longitude,latitude) %>% st_as_sf(coords=c("longitude","latitude"))

setwd('/home/delgado/proj/valbuhayra')
save(reservoirs,file='data/reservoirs.RData')

library(devtools)
document()

# plot(head(wm[15000,]))
setwd("..")
install("valbuhayra")
library(valbuhayra)
