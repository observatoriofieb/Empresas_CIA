from transform_geo import transform_geo
import subprocess

def cria_grafico():
    subprocess.call(['Rscript', 'mapa_empresas_cia.R'])


transform_geo()
cria_grafico()