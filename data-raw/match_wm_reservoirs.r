library(valbuhayra)
library(sf)
library(dplyr)
library(magrittr)
wm_fun = st_read('/home/delgado/proj/buhayra/buhayra/auxdata/funceme.geojson')
wm_fun = st_set_crs(wm_fun,32724)


ressnap=st_snap(reservoirs,wm_fun,tolerance=1000)


head(ressnap)

head(wm_fun)

res_near_wm=st_join(ressnap,wm_fun,join=st_is_within_distance,dist=5)
 # nrow(res_near_wm)
# nrow(reservoirs)

res_near_wm=res_near_wm %>%
  group_by(cod) %>%
  filter(n()==1)

nrow(res_near_wm)

colnames(wm_fun)
colnames(res_near_wm)

id_lookup = select(res_near_wm,cod,id)
st_geometry(id_lookup)=NULL
id_lookup = id_lookup %>% na.omit(cod)
reservoirs=left_join(reservoirs,id_lookup)


## rename id
head(reservoirs)
reservoirs %<>% rename(id_funceme=id)

save(reservoirs,file='data/reservoirs.RData')


library(devtools)
document()

# plot(head(wm[15000,]))
setwd("..")
install("valbuhayra")
