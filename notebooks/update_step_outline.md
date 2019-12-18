Outline of update step
================
JM Delgado
2019-12-19

-   [Funceme data](#funceme-data)
-   [TRMM data](#trmm-data)
-   [buhayra data](#buhayra-data)

Funceme data
============

Reservoir level
---------------

1.  get reservoir metadata from API (restrict query by federal state *uf* i.e. *unidade federal*)
2.  loop on all reservoirs selected to check for monitoring updates
3.  publish alongside buhayra

### Reservoir metadata

Trying to implement the following request `http://api.funceme.br/rest/acude/reservatorio?limit=10&page=3`

``` r

url='http://api.funceme.br'
path='rest/acude/reservatorio'
raw = httr::GET(url = url, path = path, query=list(limit='5',page='2'))

json_content=rawToChar(raw$content) %>%
  jsonlite::fromJSON()
```

Precipitation
-------------

1.  get gauge metadata from API
2.  loop on all gauges
3.  publish alongside buhayra

TRMM data
=========

buhayra data
============
