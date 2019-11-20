library(readxl)
library(dplyr)
library(purrr)


# get Bruno's sheets
CAVsheets = function(path)
  {
    df=path %>%
      excel_sheets() %>%
      set_names() %>%
      map(range='B8:D25',read_excel, path = path) %>%
      bind_rows(.id='reservoir')
    return(df)
  }


folder='/home/delgado/SESAM/sesam_data/DFG_Erkenntnis_Transfer/tdx/validation_data/CAV_xls'
fls=list.files(folder)
df=data_frame()
paths=paste(folder,fls,sep='/')

df=paths %>%
  set_names() %>%
  map(CAVsheets)
DF=bind_rows(df,.id=NULL)


# get meta data for Bruno's dataset
tb=read_excel('/home/delgado/SESAM/sesam_data/DFG_Erkenntnis_Transfer/tdx/validation_data/reservoir_meta.xlsx') %>%
    select(`Açude`,`Município`,Longitude,Latitude,`Início`,`Conclusão`,Capacidade,Sistema,`Extensão\ndo coroamento`,`Altura do\nmaciço`)
head(tb)
