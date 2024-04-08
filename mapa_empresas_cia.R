library(tidyverse)
library(leaflet)
library(leaflet.extras)
library(htmlwidgets)

transform_geo <- read_delim("C:\\Users\\jorge.sm\\OneDrive - Sistema FIEB\\Documentos\\Observatorio\\Geo\\Empresas_CIA\\dados\\transform_geo.csv", 
                            delim = ";", escape_double = FALSE, trim_ws = TRUE)

dados_nm_fantasia_google <- transform_geo %>% 
  mutate(nome_fantasia = replace_na(nome_fantasia, ''),
         texto_com_br = str_c(paste0('Razão Social: ', razao_social),
                              paste0('Nome Fantasia: ', nome_fantasia),
                              sep='<br>'),
         texto_sem_br = str_c(paste0('Razão Social: ', razao_social),
                              paste0('Nome Fantasia: ', nome_fantasia),
                              sep=' '))

pandoc::with_pandoc_version(
  version = '3.1.13',
leaflet(dados_nm_fantasia_google) %>% 
  addTiles() %>% 
  addMarkers(~longitude, ~latitude, popup = ~texto_com_br, label = ~texto_sem_br, group='texto') %>% 
  addProviderTiles(providers$Esri.WorldImagery) %>%
  addSearchFeatures(targetGroups = 'texto', 
                    options = searchFeaturesOptions(zoom=13, openPopup=TRUE)) %>% 
  saveWidget(file='C:\\Users\\jorge.sm\\OneDrive - Sistema FIEB\\Documentos\\Observatorio\\Geo\\Empresas_CIA\\mapa_empresas_procia_google.html')
)
