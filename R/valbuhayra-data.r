#' Reservoir water extents in Ceará
#'
#' Watermasks from August 2018 in Ceará, Northeast Brazil. The data was derived mainly from Sentinel data from ESA
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
#' The data was obtained from the \href{http://api.funceme.br/help}{FUNCEME API}.
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
