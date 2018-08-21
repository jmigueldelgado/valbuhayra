library(valbuhayra)
library(dplyr)
library(sf)
library(jsonlite)

cogerh=1
head(CAV)

library(ggplot2)
cogerh

xx=filter(CAV,reservatorio==cogerh) 

plot(xx)
ggplot(xx) + geom_point(aes(area,volume))
