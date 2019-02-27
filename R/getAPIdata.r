# #' Get decimal from base 60
# #' @export
# sexagesimal2decimal <- function(string) {
#   if(nchar(string)>4) {
#     degrees = substr(string,nchar(string)-5,nchar(string)-4) %>% as.numeric
#     minutes = substr(string,nchar(string)-3,nchar(string)-2) %>% as.numeric
#     seconds = substr(string,nchar(string)-1,nchar(string)-0) %>% as.numeric
#   } else {
#     degrees = substr(string,nchar(string)-3,nchar(string)-2) %>% as.numeric
#     minutes = substr(string,nchar(string)-1,nchar(string)-0) %>% as.numeric
#     seconds = 0
#   }
#   return(degrees+(minutes+seconds/60)/60)
# }


# library(sf)
# getwd()
#
# library(jsonlite)
# library(lubridate)
# library(dplyr)
#
# requestDate = today()
# Ndays=5

# #' Request list of rainfall gauges from funceme API
# #' @import jsonlite, lubridate, dplyr
# #' @export
# requestGauges <- function(returnN,requestDate) {
#
#     returnN <- 1000*Ndays
#     response_list <- list()
#     for(i in seq(0,Ndays-1)) {
#       request <- paste0('http://api.funceme.br/rest/pluvio/pluviometria-funceme-normalizada?data.date=',
#                         format(requestDate-i,tz="America/Fortaleza",format="%Y-%m-%d"),
#                         '&limit=',
#                         returnN)
#       resp <- fromJSON(request)
#       response_list[[i+1]] <- bind_cols(resp$list$data,select(resp$list,id,codigo,valor)) %>% mutate(date=ymd_hms(date))
#     }
#
#     df <- do.call(rbind, response_list)
#
#     postos_list = list()
#     postos = distinct(df,codigo)
#
#
#
#     for(id in seq(1,nrow(postos_desconhecidos))) {
#       request <- paste0('http://api.funceme.br/rest/pluvio/posto?codigo=',id)
#       resp <- fromJSON(request)
#
#       if(resp$paginator$total!=0) {
#         postos_list[[id]]=bind_cols(select(resp$list,codigo,nome,altit,longit,latit,rua,cep),resp$list$municipio)
#       }
#     }
#
#
#   df_postos <- do.call(rbind, postos_list)
#   df_postos_with_location = df_postos %>%
#     filter(!is.na(latit) & !is.na(longit)) %>%
#     mutate(longit=sexagesimal2decimal(as.character(longit)),latit=sexagesimal2decimal(as.character(latit))) %>%
#     st_as_sf(coords=c('longit','latit'),crs=4326)
#   # plot(df_postos_with_location)
# }

#' Request measured volumes in strategic reservoirs from FUNCEME API. id, requestDate and returnN (number of points that should be returned)
#' @import jsonlite
#' @export
requestVolumes <- function(id,requestDate,returnN) {
  if(missing(requestDate)) {
    requestDate=strftime(Sys.time()-3*60*60*24,format="%Y-%m-%d")
  }
  if(missing(returnN)) {
    returnN=1
  }
  if(missing(id)) {
    id=9
  }

  if(grepl('POSIX',class(requestDate)[1])) {
    requestDateAPI = format(requestDate,tz="America/Fortaleza",format="%Y-%m-%d")
  } else {
    requestDateAPI = requestDate
  }

  request=paste0('http://api.funceme.br/rest/acude/volume?reservatorio.cod=',
    id,
    '&limit=',
    returnN,
    '&dataColeta.GTE=',
    requestDateAPI,
    '&orderBy=dataColeta,cres')

  vols=fromJSON(request)

  value=vols$list$valor

  if(is.null(value)) {
    warning(paste0("No values for id ",id," recorded after requested date ",requestDate))
    value=NA
  }
  dt=strptime(vols$list$dataColeta,format="%Y-%m-%d %H:%M:%S",tz="America/Fortaleza")
  if(length(dt)==0) {
    dt=NA
  }
  volOut=data.frame(returnedDate=dt,requestDate=requestDate,value=value,cod=id)

  # if observation date is more than two weeks apart from our requested date, only NA is returned
  largediff=as.numeric(difftime(volOut$returnedDate,volOut$requestDate,units='days'))>14
  volOut$value[largediff]=NA
  volOut$returnedDate[largediff]=NA
  return(volOut)
}


#
# #' convert volumes from API into areas based on CAV obtained on the API and stored in this package
# #' @import jsonlite,dplyr
# #' @export
# vol2area <- function(voldf,CAV) {
#   filter(CAV,codigo==)
# }
#
#
# #' convert volumes from API into areas based on CAV obtained on the API and stored in this package
# #' @import jsonlite,dplyr
# #' @export
# vol2area <- function(voldf,CAV) {
#   filter(CAV,codigo==)
# }
