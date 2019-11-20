library(valbuhayra)
library(dplyr)
library(sf)

mun_pol=st_read('/home/delgado/proj/valbuhayra/data-raw/municipios_pol.geojson')

selected_municipio = mun_pol %>% filter(UF=='CE',NM_MUNICIP=='AIUABA')

wkt=st_as_text(selected_municipio$geometry)
query <- paste0("SELECT neb.id, neb.id_jrc, ingestion_time, neb.threshold as threshold, wmxjrc_area, ST_AsText(neb.geom) as geom_act, area as area_act, ST_AsText(jrc_neb.geom) as geom_max FROM neb  LEFT JOIN jrc_neb ON  neb.id_jrc = jrc_neb.id_jrc WHERE ST_Contains(ST_SetSRID(ST_GeomFromText('", wkt, "'), 4326), jrc_neb.geom)")


source("pw.R") # oder pw eingeben
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "watermasks", host = hostname, port = 5432, user = "sar2water", password = pw)
rm(pw)

dbGetQuery(con, query)
