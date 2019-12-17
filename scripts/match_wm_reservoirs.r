library(valbuhayra)
library(sf)
library(dplyr)
library(magrittr)
wm_fun = st_read('/home/delgado/proj/buhayra/buhayra/auxdata/wm_utm_neb.gpkg')
wm_fun = st_set_crs(wm_fun,32724)

head(wm_fun)
head(reservoirs)

id_funceme=array()

for(i in seq(1,nrow(reservoirs))) {
  dsts=st_distance(x=reservoirs[i,],y=wm_fun) %>% as.numeric
  if(min(dsts)<100) {
    id_funceme[i]= dsts %>% which.min %>% wm_fun$id[.]
  } else {
    id_funceme[i]=NA
  }
}
length(id_funceme)
nrow(reservoirs)
reservoirs$id_funceme=id_funceme
filter(reservoirs,cod==130)
# ressnap=st_snap(reservoirs,wm_fun,tolerance=1000)

# st_write(ressnap,'res_snap.gpkg')

# head(ressnap)
#
# head(wm_fun)

# res_near_wm=st_join(ressnap,wm_fun,join=st_is_within_distance,dist=5)
 # nrow(res_near_wm)
# nrow(reservoirs)

# res_near_wm=res_near_wm %>%
#   group_by(cod) %>%
#   filter(n()==1)

nrow(res_near_wm)

colnames(wm_fun)
colnames(res_near_wm)

id_lookup = select(res_near_wm,cod,id)
st_geometry(id_lookup)=NULL
id_lookup = id_lookup %>% na.omit(cod)
reservoirs=left_join(reservoirs,id_lookup)

filter(wm,id_funceme==12542)

## rename id
head(reservoirs)
reservoirs %<>% rename(id_funceme=id)

save(reservoirs,file='data/reservoirs.RData')
# st_write(reservoirs,'reservoirs.gpkg')

library(devtools)
document()

# plot(head(wm[15000,]))
setwd("..")
install("valbuhayra")
