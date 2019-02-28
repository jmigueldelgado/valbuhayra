#' Get decimal from base 60. Accepts string and returns decimal
#' @export
sexagesimal2decimal <- function(string) {
  decimal=lapply(string, function(string) {
    if(nchar(string)>4) {
      degrees = substr(string,nchar(string)-5,nchar(string)-4) %>% as.numeric
      minutes = substr(string,nchar(string)-3,nchar(string)-2) %>% as.numeric
      seconds = substr(string,nchar(string)-1,nchar(string)-0) %>% as.numeric
    } else {
      degrees = substr(string,nchar(string)-3,nchar(string)-2) %>% as.numeric
      minutes = substr(string,nchar(string)-1,nchar(string)-0) %>% as.numeric
      seconds = 0
    }
    return(degrees+(minutes+seconds/60)/60)
  })
  return(unlist(decimal))
}


#' Request list of rainfall gauges from funceme API
#' @importFrom jsonlite fromJSON
#' @importFrom lubridate ymd_hms
#' @importFrom dplyr bind_cols bind_rows select mutate rename distinct arrange anti_join left_join filter
#' @importFrom magrittr "%>%"
#' @importFrom sf st_as_sf st_geometry
#' @export
requestGauges <- function(requestDate,Ndays) {
  returnN <- 1000*Ndays

  response_list <- list()
  for(i in seq(0,Ndays-1)) {
    request <- paste0('http://api.funceme.br/rest/pluvio/pluviometria-funceme-normalizada?data.date=',
                      format(requestDate-i,tz="America/Fortaleza",format="%Y-%m-%d"),
                      '&limit=',
                      returnN)
    resp <- fromJSON(request)
    if(!is.null(resp$list$data)) {
      response_list[[i+1]] <- bind_cols(resp$list$data,select(resp$list,id,codigo,valor)) %>% mutate(date=ymd_hms(date))
    }
  }

  df <- do.call(rbind, response_list)

  postos = distinct(df,codigo) %>% arrange(codigo)


  # load('./data/p_gauges_saved.RData')
  postos_unknown = anti_join(postos,p_gauges_saved,by="codigo")

  postos_list = list()
  for(id in postos_unknown$codigo) {
    request <- paste0('http://api.funceme.br/rest/pluvio/posto?codigo=',id)
    resp <- fromJSON(request)

    if(resp$paginator$total!=0) {
      postos_list[[id]]=bind_cols(select(resp$list,codigo,nome,altit,longit,latit,rua,cep),resp$list$municipio)
    }
  }

  df_postos <- do.call(rbind, postos_list) %>%
    mutate(codigo1=as.integer(codigo1))

  df_postos_with_location = df_postos %>%
    filter(!is.na(latit) & !is.na(longit)) %>%
    filter(nchar(latit)>=3 & nchar(longit)>=3) %>%
    mutate(longit=as.character(longit),latit=as.character(latit)) %>%
    mutate(longit = - sexagesimal2decimal(longit),latit= - sexagesimal2decimal(latit)) %>%
    st_as_sf(coords=c('longit','latit'),crs=4326)

  # load('./data/municipios.RData') # load municipios

  df_postos_without_location = anti_join(df_postos,select(df_postos_with_location,codigo)) %>%
    inner_join(.,municipios %>%
      mutate(codigo1=as.integer(as.character(CD_GEOCMU))) %>%
      select(codigo1,geometry))

  st_geometry(df_postos_without_location) <- "geometry"

  if(nrow(df_postos_without_location)>0) {
    p_gauges_saved = rbind(
      select(df_postos_with_location,codigo,nome,altit,rua,cep,codigo1,nome1,geometry),
      select(df_postos_without_location,codigo,nome,altit,rua,cep,codigo1,nome1,geometry))
  } else {
    p_gauges_saved = df_postos_with_location
  }
  # setwd('/home/delgado/proj/valbuhayra')
  # save(p_gauges_saved,file='data/p_gauges_saved.RData')
  return(p_gauges_saved)

}

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
