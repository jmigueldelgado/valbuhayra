#' get all the IDs of monitored reservoirs from FUNCEME API
#' @import jsonlite
#' @export
getVols <- function(id,date_lower,N)
  {

    if(missing(date_lower)) {
      date_lower=strftime(Sys.time()-3*60*60*24,format="%Y-%m-%d")
    }
    if(missing(N)) {
      N=1
    }
    if(missing(id)) {
      id=9
    }

    if(grep('POSIX',class(date_lower)[1])==1) {
      date_lower = strftime(date_lower)
    }

    request=paste0('http://api.funceme.br/rest/acude/volume?reservatorio.cod=',
      id,
      '&limit=',
      N,
      '&dataColeta.GTE=',
      date_lower,
      '&orderBy=dataColeta,cres')

    vols=fromJSON(request)

    value=vols$list$valor
    value
    if(is.null(value)) {
      warning(paste0("No values for id ",id," recorded after input date ",date_lower))
      value=NA
    }
    dt=strptime(vols$list$dataColeta,format="%Y-%m-%d %H:%M:%S",tz="BRT")
    if(length(dt)==0) {
      dt=NA
    }
    volOut=data.frame(dt=dt,value=value,cod=id)
    return(volOut)
  }
