##########################################+
# Reservoirs NEB - PostgreSQL database ####
##########################################+

setwd("C:/Users/dobkowitz/DownloadReservoirData")

library(RPostgreSQL)
library(geojsonR)
library(sf)
library(dplyr)
library(geosphere)
library(lubridate)

# Connect to database ####

#source("pw.R") # oder pw eingeben
pw <- {"eg_BertS101"}
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "watermasks", host = "141.89.96.184", port = 5432, user = "sar2water", password = pw)
rm(pw)

# Query by hydrographic unit ####
regions <- st_read("aggregation_areas.geojson")
wkt <- st_as_text(regions$geometry)

hu_tables <- list()

# Extract per HU and calculate volumes ####
for(h in 1:12){
 hu1 <- dbGetQuery(con, paste0("SELECT neb.id, neb.id_jrc, ingestion_time, neb.threshold as threshold, wmxjrc_area, ST_AsText(neb.geom) as geom_act, area as area_act, ST_AsText(jrc_neb.geom) as geom_max FROM neb  LEFT JOIN jrc_neb ON  neb.id_jrc = jrc_neb.id_jrc WHERE ST_Contains(ST_SetSRID(ST_GeomFromText('", wkt[h], "'), 4326), jrc_neb.geom)"))
 # hu1 <- dbGetQuery(con, paste0("SELECT neb.id, neb.id_jrc, ingestion_time, wmxjrc_area, ST_area(ST_Transform(neb.geom,32724)) as area_act, area as area_act, ST_AsText(jrc_neb.geom) as geom_max FROM neb  LEFT JOIN jrc_neb ON  neb.id_jrc = jrc_neb.id_jrc WHERE ST_Contains(ST_SetSRID(ST_GeomFromText('", wkt[h], "'), 4326), jrc_neb.geom)"))
  
  # calculate perimeter
  st <- st_as_sf(hu1, wkt = c("geom_max"),crs=4326) %>%
    select(id_jrc, ingestion_time, geom_max)
  st <- as(st, "Spatial")
  hu1$peri_max <- perimeter(st)
 
  # Calculate max area from geometry
  st <- st_as_sf(hu1, wkt = c("geom_max"),crs=4326) %>%
    select(id_jrc, ingestion_time, threshold, wmxjrc_area, area_act,geom_max, peri_max) %>%
    mutate(area_max=st_area(geom_max))
  
  hu1 <- st
# hu1$geom_max <- NULL
  hu1$area_max <- as.numeric(hu1$area_max)
  
  
  # Calculate actual volume using approach 1c (Pereira et al 2019)
  hu1$lambda <- hu1$area_max/hu1$peri_max
  hu1$D <- hu1$peri_max/pi
  hu1$alpha <- 2.08 + (1.46 * 10)*(hu1$lambda/hu1$peri_max)- (7.41 * 10^-2)*(hu1$lambda^2 / hu1$peri_max) - (1.36 * 10^-8)*(hu1$area_max * hu1$D/hu1$lambda) + (4.07 * 10^-4)*hu1$D
  
  hu1$K <- 2.55 * 10^3 + (6.45 * 10)* hu1$lambda - (5.38 * 10)*(hu1$D / hu1$lambda) 
    
  V_0 <- 2096
  A_0 <- 5000
  hu1$volume <- V_0 + A_0 * (((hu1$area_act - A_0)/(hu1$alpha * hu1$K)))^(1/(hu1$alpha-1)) + 
    hu1$K * (((hu1$area_act - A_0)/(hu1$alpha * hu1$K)))^(hu1$alpha/(hu1$alpha-1))
  
  # If area_act < 5000 m^2 use old approach (Molle 1994)
  hu1$volume[hu1$area_act<5000] <- 1500*(hu1$area_act[hu1$area_act<5000]/(2.7*1500))^(2.7/(2.7-1))
  
  hu1$max_act <- hu1$area_max - hu1$area_act
  
  hu_tables[[h]] <- hu1
  print(paste("HU", h, "done"))
  }

save(hu_tables, file = "data/reservoirs_hu.RData")

# Plot reservoir number observed per 10 days ####
# nach Volumenberechnung für 10-Tages Abschnitte mitteln + aggregieren
png("reservoirnumber_timeseries_hu.png", height = 20, width = 15, units = "in", res = 500)
par(mfrow = c(12,1), las = 1, mar = c(2,2,2,2), oma = c(2,3,0,0))
for(h in 1:12){
  hu1 <- hu_tables[[h]]
  hu1a <- mutate(hu1,time10=floor_date(ingestion_time,"10 days")) %>% group_by(time10,id_jrc) %>% summarize(volume10=mean(volume))
  hu1a <- count(hu1a)
  plot(hu1a, type = "h", lwd = 4, col = "red", ylim = c(0,3500))
  legend("topright", legend = regions$UHE_NM[h])
}
dev.off()

# Plot reservoir volume time series per hu ####

png("volume_timeseries_hu.png", height = 20, width = 15, units = "in", res = 500)
par(mfrow = c(12,1), las = 1, mar = c(2,2,2,2), oma = c(2,3,0,0))
for(h in 1:12){
  hu1 <- hu_tables[[h]]
  hu1 <- subset(hu1, K > 0  & alpha > 0)
  hu1a <- mutate(hu1,time10=floor_date(ingestion_time,"10 days")) %>% group_by(time10,id_jrc) %>% summarize(volume10=mean(volume))
  hu1b <- aggregate(hu1a$volume10, by = list(hu1a$time10), FUN = sum, na.rm = T)
  plot(hu1b, type = "h", lwd = 4, col = "blue", ylim = c(0, max(hu1b$x)))
  legend("topright", legend = regions$UHE_NM[h])
}
dev.off()

# Histograms of lambda, K, alpha, threshold ####
png("lambda_hist_hu.png", height = 8, width = 12, units = "in", res = 500)
par(mfrow = c(3,4), las = 1, mar = c(2,2,2,2), oma = c(2,3,0,0))
for(h in 1:12){
hu1 <- hu_tables[[h]]
hist(hu1$lambda, xlab = "", main = paste("HU", regions$UHE_NM[h]))
}
dev.off()

png("K_hist_hu.png", height = 8, width = 12, units = "in", res = 500)
par(mfrow = c(3,4), las = 1, mar = c(2,2,2,2), oma = c(2,3,0,0))
for(h in 1:12){
  hu1 <- hu_tables[[h]]
  hist(hu1$K, xlab = "", main = paste("HU", regions$UHE_NM[h]))
}
dev.off()

png("alpha_hist_hu.png", height = 8, width = 12, units = "in", res = 500)
par(mfrow = c(3,4), las = 1, mar = c(2,2,2,2), oma = c(2,3,0,0))
for(h in 1:12){
  hu1 <- hu_tables[[h]]
  hist(hu1$alpha, xlab = "", main = paste("HU", regions$UHE_NM[h]))
}
dev.off()

png("threshold_hist_hu.png", height = 8, width = 12, units = "in", res = 500)
par(mfrow = c(3,4), las = 1, mar = c(2,2,2,2), oma = c(2,3,0,0))
for(h in 1:12){
  hu1 <- hu_tables[[h]]
  hist(hu1$threshold[hu1$threshold<0], xlab = "", main = paste("HU", regions$UHE_NM[h]), xlim = c(-2000,-1000))
  legend("topleft", inset = 0.03, legend = paste(length(which(hu1$threshold == 0)), "NAs"))
  }
dev.off()

png("wmx_jrc_hist_hu.png", height = 8, width = 12, units = "in", res = 500)
par(mfrow = c(3,4), las = 1, mar = c(2,2,2,2), oma = c(2,3,0,0))
for(h in 1:12){
  hu1 <- hu_tables[[h]]
  hist(hu1$wmxjrc_area/hu1$area_act, xlab = "", main = paste("HU", regions$UHE_NM[h]))
}
dev.off()

png("wmx_jrc_area_act_scatter_hu.png", height = 8, width = 12, units = "in", res = 500)
par(mfrow = c(3,4), las = 1, mar = c(4,3,2,2), oma = c(2,3,0,0))
for(h in 1:12){
  hu1 <- hu_tables[[h]]
  plot(hu1$wmxjrc_area/hu1$area_act ~ hu1$threshold, xlab = "threshold", ylab = "wmxjrc/area_act", main = paste("HU", regions$UHE_NM[h]))
}
dev.off()

# check why NAs and negative volumes ####
# Calculate actual volume using approach 1c (Pereira et al 2019)
hu7 <- hu_tables[[7]]

hu7[hu7$id_jrc == 40445,]

peri_max <- hu7$peri_max[hu7$id_jrc == 37380 & hu7$ingestion_time == "2018-03-29 08:17:22"]
area_max <- hu7$area_max[hu7$id_jrc == 37380 & hu7$ingestion_time == "2018-03-29 08:17:22"]
area_act <- hu7$area_act[hu7$id_jrc == 37380 & hu7$ingestion_time == "2018-03-29 08:17:22"]

lambda <- area_max/peri_max
D <- peri_max/pi
alpha <- 2.08 + (1.46 * 10)*(lambda/peri_max)- (7.41 * 10^-2)*(lambda^2 / peri_max) - (1.36 * 10^-8)*(area_max * D/lambda) + (4.07 * 10^-4)*D

K <- 2.55 * 10^3 + (6.45 * 10)* lambda - (5.38 * 10)*(D / lambda) 

V_0 <- 2096
A_0 <- 5000
volume <- V_0 + A_0 * (((area_act - A_0)/(alpha * K)))^(1/(alpha-1)) + 
  K * (((area_act - A_0)/(alpha * K)))^(alpha/(alpha-1))


