library(valbuhayra)
library(dplyr)
library(sf)
library(jsonlite)

cogerh=1


filter(reservoirs,cod==cogerh)

head(wm)

library(ggplot2)
cogerh

filter(CAV,reservatorio==cogerh) %>%
  ggplot(.) + geom_point(aes(area,volume))
