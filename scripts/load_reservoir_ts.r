library(valbuhayra)
library(lubridate)
library(assimReservoirs)
requestVolumes(174,ymd("20190101"),3)

contr=contributing_basins_at_res(ID=62958)

plot(contr)
