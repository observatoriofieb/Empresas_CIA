library(tidyverse)
library(leaflet)
library(htmltools)
library(leaflet.extras)


dados_cia_geolocalizados <- read_delim("Observatorio/Geo/Empresas_CIA/dados/dados_cia_geolocalizados_google.csv", 
                                       delim = ";", escape_double = FALSE, col_types = cols(cadastro = col_character(), 
                                                                                            atualizacao = col_character()), trim_ws = TRUE)
dados_geo <- dados_cia_geolocalizados %>% 
  select(latitude, longitude, razao_social)

dados_geo

leaflet(dados_geo) %>% 
  addTiles() %>% 
  addMarkers(~longitude, ~latitude, popup = ~htmlEscape(razao_social))



library(readxl)
dados_cia_teste_nome_fantasia <- read_excel("Observatorio/Geo/Empresas_CIA/dados/dados_cia_teste_nome_fantasia.xlsx")
dados_geo <- dados_cia_geolocalizados %>% 
  select(latitude, longitude, razao_social)

leaflet(dados_cia_teste_nome_fantasia) %>% 
  addTiles() %>% 
  addMarkers(~longitude, ~latitude, popup = ~htmlEscape(razao_social))

dados_google_por_endereco <- dados_cia_geolocalizados %>% 
  select(cnpj, latitude, longitude) %>% 
  rename(latitude_google = latitude,
         longitude_google = longitude)

dados_nm_fantasia_google <- dados_cia_teste_nome_fantasia %>% 
  left_join(dados_google_por_endereco, by = join_by(cnpj)) %>% 
  mutate(latitude = coalesce(latitude, latitude_google),
         longitude = coalesce(longitude, longitude_google),
         nome_fantasia = replace_na(nome_fantasia, ''),
         texto_com_br = str_c(paste0('Razao Social: ', razao_social),
                       paste0('Nome Fantasia: ', nome_fantasia),
                       sep='<br>'),
         texto_sem_br = str_c(paste0('Razao Social: ', razao_social),
                              paste0('Nome Fantasia: ', nome_fantasia),
                              sep=' '))

leaflet(dados_nm_fantasia_google) %>% 
  addTiles() %>% 
  addMarkers(~longitude, ~latitude, popup = ~texto_com_br, label = ~texto_sem_br, group='texto') %>% 
  addProviderTiles(providers$Esri.WorldImagery) %>%
  addSearchFeatures(targetGroups = 'texto', 
                    options = searchFeaturesOptions(zoom=13, openPopup=TRUE)) 

