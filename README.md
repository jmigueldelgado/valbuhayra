# valbuhayra
a validation and data repository for buhayra

Have a look at the data by typing e.g. `plot(wm["ingestion_time"])` or `plot(reservoirs["capacity"])`.

In order to obtain the current or past measured reservoir level use `getVols(id,date,N)` where `id` should be an integer corresponding to the desired reservoir, `date` might be a string or POSIXct and N is the number of records we wish to obtain since `date`.

The next figure shows the accuracy of the watermask area for 54 reservoirs during 11 acquisition dates and a total of 163 data points. Underestimations by _buhayra_ can be explained by macrophyte extent in many water bodies. Note the improved accuracy can be pbserved for reservoir area < 150 ha.

[[https://github.com/jmigueldelgado/valbuhayra/blob/master/valbuhayra/data-raw/plt_val_small_dams.png|alt=scatter]]

To compare the time-series of individual reservoirs it is possible to check  [http://www.hidro.ce.gov.br/](http://www.hidro.ce.gov.br/) like in the following figure. Field measurements will be integrated into the web-visualization.

[[https://github.com/jmigueldelgado/valbuhayra/blob/master/valbuhayra/data-raw/example_trapiaii.png|alt=trapia]]
