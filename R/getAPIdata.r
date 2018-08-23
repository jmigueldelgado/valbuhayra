#' get all the IDs of monitored reservoirs from FUNCEME API
#' @import jsonlite
#' @export
getVols <- function(id,input_date,N) {
  if(missing(input_date)) {
    input_date=strftime(Sys.time()-3*60*60*24,format="%Y-%m-%d")
  }
  if(missing(N)) {
    N=1
  }
  if(missing(id)) {
    id=9
  }

  if(grep('POSIX',class(input_date)[1])==1) {
    input_date = strftime(input_date)
  }

  request=paste0('http://api.funceme.br/rest/acude/volume?reservatorio.cod=',
    id,
    '&limit=',
    N,
    '&dataColeta.GTE=',
    input_date,
    '&orderBy=dataColeta,cres')

  vols=fromJSON(request)

  value=vols$list$valor
  value
  if(is.null(value)) {
    warning(paste0("No values for id ",id," recorded after input date ",input_date))
    value=NA
  }
  dt=strptime(vols$list$dataColeta,format="%Y-%m-%d %H:%M:%S",tz="BRT")
  if(length(dt)==0) {
    dt=NA
  }
  volOut=data.frame(dt=dt,input_date=input_date,value=value,cod=id)
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
