library(readxl)
library(dplyr)
library(purrr)
library(magrittr)
# get CAVs from fUNCEME API and save them in data package
library(jsonlite)
request='http://api.funceme.br/rest/acude/referencia-cav?limit=0'
cav=fromJSON(request)
CAV=bind_cols(cav$list)

CAV %<>% mutate_if(is.character,as.numeric)

setwd('/home/delgado/proj/valbuhayra')
save(CAV,file='data/cav.RData')
