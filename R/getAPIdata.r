#' Get decimal from base 60. Accepts string and returns decimal
#' @export
sexagesimal2decimal <- function(string) {
  sapply(string, function(string) {
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
}

#' Request list of rainfall gauges from funceme API
#' @importFrom jsonlite fromJSON
#' @importFrom lubridate ymd_hms
#' @importFrom dplyr bind_cols bind_rows select mutate rename distinct arrange anti_join left_join filter
#' @importFrom dplyr "%>%"
#' @importFrom sf st_as_sf
#' @export
requestGauges <- function(requestDate=today(),Ndays=2) {
  returnN <- 1000*Ndays

  response_list <- list()
  for(i in seq(0,Ndays-1)) {
    request <- paste0('http://api.funceme.br/rest/pluvio/pluviometria-funceme-normalizada?data.date=',
                      format(requestDate-i,tz="America/Fortaleza",format="%Y-%m-%d"),
                      '&limit=',
                      returnN)
    resp <- fromJSON(request)
    if(nrow(resp$list)<1)
    {
      next
    } else response_list[[i+1]] <- bind_cols(resp$list$data,select(resp$list,id,codigo,valor)) %>% mutate(date=ymd_hms(date))
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
    mutate(longit=as.character(longit),latit=as.character(latit)) %>%
    mutate(longit = - sexagesimal2decimal(longit),latit= - sexagesimal2decimal(latit)) %>%
    st_as_sf(coords=c('longit','latit'),crs=4326)


  df_postos_with_location$longit[2]

  df_postos_without_location = df_postos %>%
    filter(is.na(latit) | is.na(longit)) %>%
    left_join(.,municipios %>% mutate(codigo1=as.integer(CD_GEOCMU)) %>% select(codigo1,geometry))

  if(nrow(df_postos_without_location)>0) {
    p_gauges_saved = bind_rows(select(df_postos_with_location,codigo,nome,altit,rua,cep,codigo1,nome1,geometry),select(df_postos_without_location,codigo,nome,altit,rua,cep,codigo1,nome1,geometry))
  } else {
    p_gauges_saved = df_postos_with_location
  }
  save(p_gauges_saved,file='data/p_gauges_saved.RData')


  return(df_postos_with_location)

}

#' request reservoir from api by querying
bbox2api



#' Request reservoir id based on jrc_neb table. only works on uni VPN and with password.
#' @importFrom RPostgreSQL dbDriver dbConnect dbGetQuery dbDisconnect
#' @export
latlong2id = function(lon,lat,pw,hostname)
{
  # source("./pw.R")
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname='watermasks', host = hostname, port = 5432, user = "sar2water", password = pw)
  # rm(pw)

  id <- dbGetQuery(con, paste0("SELECT id_jrc FROM jrc_neb WHERE ST_Distance_Sphere(geom, ST_MakePoint(",my_long,",",my_lat,")) <= 500"))
  dbDisconnect(conn = con)
  return(id)
}


#' Request measured volumes in strategic reservoirs from FUNCEME API. id, requestDate and returnN (number of points that should be returned)
#' @importFrom jsonlite fromJSON
#' @importFrom lubridate today force_tz
#' @export
requestVolumes <- function(id,requestDate,returnN) {
  # id=174
  # requestDate=today(tzone="America/Fortaleza")-3
  # returnN=10
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
    requestDateAPI = force_tz(requestDate,tz="America/Fortaleza",roll=TRUE)
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

  # # if observation date is more than two weeks apart from our requested date, only NA is returned
  # largediff=as.numeric(difftime(volOut$returnedDate,volOut$requestDate,units='days'))>14
  # volOut$value[largediff]=NA
  # volOut$returnedDate[largediff]=NA
  return(volOut)
}



# molle <- function(poly_max)
#
# pereira1c <- function(poly_max)
#
# pol2vol(poly,poly_max)
#   hu1$lambda <- hu1$area_max/hu1$peri_max
#   hu1$D <- hu1$peri_max/pi
#   hu1$alpha <- 2.08 + (1.46 * 10)*(hu1$lambda/hu1$peri_max)- (7.41 * 10^-2)*(hu1$lambda^2 / hu1$peri_max) - (1.36 * 10^-8)*(hu1$area_max * hu1$D/hu1$lambda) + (4.07 * 10^-4)*hu1$D
#
#   hu1$K <- 2.55 * 10^3 + (6.45 * 10)* hu1$lambda - (5.38 * 10)*(hu1$D / hu1$lambda)
#
#   V_0 <- 2096
#   A_0 <- 5000
#   hu1$volume <- V_0 + A_0 * (((hu1$area_act - A_0)/(hu1$alpha * hu1$K)))^(1/(hu1$alpha-1)) +
#     hu1$K * (((hu1$area_act - A_0)/(hu1$alpha * hu1$K)))^(hu1$alpha/(hu1$alpha-1))
#
#   # If area_act < 5000 m^2 use old approach (Molle 1994)
#   hu1$volume[hu1$area_act<5000] <- 1500*(hu1$area_act[hu1$area_act<5000]/(2.7*1500))^(2.7/(2.7-1))


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
