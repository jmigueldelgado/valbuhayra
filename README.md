# valbuhayra
a validation and data repository for buhayra

Have a look at the data by typing e.g. `plot(wm["ingestion_time"])` or `plot(reservoirs["capacity"])`.

In order to obtain the current or past measured reservoir level use `getVols(id,date,N)` where `id` should be an integer corresponding to the desired reservoir, `date` might be a string or POSIXct and N is the number of records we wish to obtain since `date`.


![Example, looking good](valbuhayra/data-raw/example_trapiaii.png)
