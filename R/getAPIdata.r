#' get all the IDs of monitored reservoirs from FUNCEME API
#' @import jsonlite
#' @export
getVols <- function(id=9,date_lower=strftime(Sys.time()-7*60*60*24,format="%Y-%m-%d"),N=1)
{
  # date_lower=strftime(Sys.time()-30*60*60*24,format="%Y-%m-%d")
  # date_upper=strftime(Sys.time(),format="%Y-%m-%d")
  # id=9
   # N=1
  request=paste0('http://api.funceme.br/rest/acude/volume?reservatorio.cod=',
        id,
        '&limit=',
        N,
        '&dataColeta.GTE=',
        date_lower,
        '&orderBy=dataColeta,cres')

  vols=fromJSON(request)
  value=vols$list$valor
  dt=strptime(vols$list$dataColeta,format="%Y-%m-%d %H:%M:%S",tz="BRT")
  volOut=data.frame(dt=dt,value=value,cod=id)
  return(volOut)
}
