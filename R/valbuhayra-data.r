#' Reservoir water extents in Ceará
#'
#' Watermasks from May, June, July and August 2018 in Ceará, Northeast Brazil. The data was derived mainly from Sentinel data from ESA
#' with the package \href{https://github.com/jmigueldelgado/buhayra}{buhayra}. Most processing runs in the
#' computation cluster of the University of Potsdam, Germany.
#'
#' @docType data
#'
#' @usage data(wm)
#'
#' @format An object of class \code{"sf"}.
#'
#' @keywords datasets
#'
#'
#' @source \href{http://scihub.copernicus.eu/}{Sentinel API}
#'
#' @examples
#' data(wm)
#' \donttest{plot(wm)}
"wm"


#' Height-Area-Volume curves for monitored reservoirs in Ceará
#'
#' The data was obtained from the \href{http://api.funceme.br/help}{FUNCEME API}. Areas are given in $km^2$, volumes in $hm^3$ and heights in $m$.
#'
#' @docType data
#'
#' @usage data(CAV)
#'
#' @format A dataframe.
#'
#' @keywords datasets
#'
#'
#' @source \href{http://api.funceme.br/help}{FUNCEME API}
#'
#' @examples
#' data(CAV)
#' \donttest{head(CAV)}
"CAV"


#' Monitored reservoirs in Ceará
#'
#' The data was obtained from the \href{http://api.funceme.br/help}{FUNCEME API} and the IDs were matched with \code{wm}. Column \code{cod} is the ID in the API and column \code{id} is the ID given in the watermask \code{wm}.
#'
#' @docType data
#'
#' @usage data(reservoirs)
#'
#' @format An object of class \code{"sf"}.
#'
#' @keywords datasets
#'
#'
#' @source \href{http://api.funceme.br/help}{FUNCEME API}
#'
#' @examples
#' data(reservoirs)
#' \donttest{plot(reservoirs["capacity"])}
"reservoirs"
