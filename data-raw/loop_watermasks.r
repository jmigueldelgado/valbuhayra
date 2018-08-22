library(valbuhayra)
library(dplyr)
library(sf)
library(jsonlite)

cogerh=1

library(ggplot2)
cogerh

filter(CAV,reservatorio==cogerh) %>%
  ggplot(.) + geom_point(aes(area,volume))
