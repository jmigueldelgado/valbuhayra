# Plots ####
setwd("D:/DownloadReservoirData")

library(dplyr)
library(lubridate)
library(sf)

load("data/reservoirs_hu.RData")
regions <- st_read("data/aggregation_areas.geojson")
load("data/id_jrc_funceme.RData")

# set locale to english so that dates in timeseries plots are in english
Sys.setlocale("LC_TIME", "English")

# Plot reservoir number observed per 10 days ####
# nach Volumenberechnung für 10-Tages Abschnitte mitteln + aggregieren
png("figures/reservoirnumber_timeseries_hu.png", height = 20, width = 15, units = "in", res = 500)
par(mfrow = c(12,1), las = 1, mar = c(2,2,2,2), oma = c(2,3,0,0))
for(h in 1:12){
  hu1 <- hu_tables[[h]]
  hu1$geom_max <- NULL
  hu1a <- mutate(hu1,time10=floor_date(ingestion_time,"10 days")) %>% group_by(time10,id_jrc) %>% summarize(volume10=mean(volume))
  hu1a <- count(hu1a)
  plot(hu1a, type = "h", lwd = 4, col = "red", ylim = c(0,5500))
  legend("topright", legend = regions$UHE_NM[h])
}
dev.off()

# Plot reservoir volume time series per hu ####

png("figures/volume_timeseries_hu.png", height = 20, width = 15, units = "in", res = 500)
par(mfrow = c(12,1), las = 1, mar = c(2,2,2,2), oma = c(2,3,0,0))
for(h in 1:12){
  hu1 <- hu_tables[[h]]
  hu1$geom_max <- NULL
  hu1a <- mutate(hu1,time10=floor_date(ingestion_time,"10 days")) %>% group_by(time10,id_jrc) %>% summarize(volume10=mean(volume))
  hu1b <- aggregate(hu1a$volume10, by = list(hu1a$time10), FUN = sum, na.rm = T)
  plot(hu1b, type = "h", lwd = 4, col = "blue", ylim = c(0, max(hu1b$x)))
  legend("topright", legend = regions$UHE_NM[h])
}
dev.off()

# plot only Médio Jaguaribe, without FUNCEME monitored reservoirs
h <- 7
  hu1 <- hu_tables[[h]]
  hu1$geom_max <- NULL
  hu1 <- subset(hu1, wmxjrc_area/area_act > 0.9)
  hu1a <- mutate(hu1,time10=floor_date(ingestion_time,"15 days")) %>% group_by(time10,id_jrc) %>% summarize(volume10=mean(volume))
  #hu1a <- mutate(hu1,time10=floor_date(ingestion_time, "month")) %>% group_by(time10,id_jrc) %>% summarize(volume10=mean(volume))
  id1 <- id_jrc_funceme[[h]]
  for(i in 1:nrow(id1)){
  hu1a <- subset(hu1a, id_jrc != id1$id_jrc[i])}
  hu1b <- aggregate(hu1a$volume10, by = list(hu1a$time10), FUN = sum, na.rm = T)
  hu1b$x <- hu1b$x/1000000
  hu1c <- count(hu1a)

png("figures/volume_10days_MedioJag.png", height = 4, width = 10, units = "in", res = 500)
  par(mfrow = c(1,1), las = 1, mar = c(5,5,1,4), oma = c(0,0,1,1))
  
  plot(hu1c, type = "h", lwd = 2, col = "gray37", ylim = c(0,max(hu1c$n)), axes = F, xlab ="", ylab = "")
  axis(side = 4, col = "gray37")
  mtext(side = 4, line = 3, "Number of reservoirs", las = 3)
  par(new = T)
  plot(hu1b, type = "l", lwd = 1, col = "blue", ylim = c(0, max(hu1b$x)), xlab = paste(regions$UHE_NM[h], "2018"), ylab = expression("Reservoir storage [hm"^3*"]"))
  axis(side = 2, col = "blue")
  # legend("topleft", legend = regions$UHE_NM[h])
dev.off()


for(h in 1:12){
  hu1 <- hu_tables[[h]]
  hu1$geom_max <- NULL
  hu_tables[[h]]<- hu1
}
save(hu_tables, file = "reservoirs_hu_nogeom.RData")

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

