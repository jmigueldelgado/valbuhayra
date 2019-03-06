###################################################+
# Calculate reservoir area from volumes and CAV ####
###################################################+

library(dplyr)
library(sf)
library(jsonlite)
library(purrr)
library(lubridate)

setwd("C:/Users/dobkowitz/DownloadReservoirData")

load("data/cav.RData")
load("data/reservoirs_hu.RData")
load("data/id_jrc_funceme.RData")
load("data/volumedf.RData")

val <- NULL

for(h in 1:12){
  hu <- hu_tables[[h]]
  id_jrc_f <- id_jrc_funceme[[h]]
  for(i in 1:nrow(id_jrc_f)){
    merge <- merge(hu, id_jrc_f[i,], by = "id_jrc")
    # areas in CAV are given in km2, volumes in hm3
    c <- id_jrc_f$id_fun[i]
    cav=filter(CAV,reservatorio==c)
    api_h <- api[api$cod ==c,]  
    #delete empty rows of cav or api_h?
    if(nrow(api_h)<1) next
    interp = approx(cav$volume,cav$area, xout = api_h$value)
    api_h$area_funceme <- interp[[2]]
    
    merge$date <- as.Date(merge$ingestion_time, formate = "%Y-%m-%d")
    api_h$date <- as.Date(api_h$returnedDate, formate = "%Y-%m-%d")

    mergeb <- merge(merge, api_h, by = "date")
    val <- rbind(val, mergeb)
  }}

save(val, file = "data/validation_estimated_funceme.RData")
load("data/validation_estimated_funceme.RData")

# Goodness of fit -> wmx/area_act ####
library(hydroGOF)
val$wmx_jrc_area_act <- val$wmxjrc_area/val$area_act
val$wmx_jrc_area_act[is.na(val$wmx_jrc_area_act)] <- 1

error <- NULL
val500 <- subset(val, area_max/10000<500)
for(i in 0:9){
sub <- subset(val500, wmx_jrc_area_act > i/10)
error1 <- data.frame(wmx_act = i/10, 
                    n = nrow(sub),
                    nreservoirs = length(unique(sub$id_jrc)),
                    rmse = rmse(sim = sub$area_act/10000, obs = sub$area_funceme*100),
                    mae = mae(sim = sub$area_act/10000, obs = sub$area_funceme*100))
error <- rbind(error, error1)
}
write.table(error, "val_reservoir_extent_error.txt")
# Plot estimated against measured values ####
i = 4
i = 9

sub <- subset(val500, wmx_jrc_area_act > i/10)
png(paste0("figures/val_0.",i, ".png"), height = 4.5, width = 6, units = "i", res = 500)
par(las = 1)
plot(sub$area_funceme*100, sub$area_act/10000, xlab = "measured by FUNCEME [ha]", ylab = "estimated [ha]", main = paste("wmx_jrc/area_act >", i/10))
abline(0,1)
dev.off()

#plot(sub$area_funceme[sub$area_max<5000000]*100, sub$area_act[sub$area_max<5000000]/10000, xlab = "measured by FUNCEME [ha]", ylab = "estimated [ha]")
#abline(0,1)
