library(valbuhayra)
library(sf)

# res_snap=st_snap(reservoirs,wm,tolerance=0.01)
# head(res_snap)

# use st_join https://r-spatial.github.io/sf/reference/st_join.html

reservoirs=st_set_crs(reservoirs,st_crs(wm))

res_on_wm=st_join(reservoirs,wm,join=st_is_within_distance,dist=0.01)
