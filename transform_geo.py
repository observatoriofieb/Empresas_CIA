import pandas as pd


def transform_geo():
    # Coloca dados de endereço no lugar dos NAs
    df_google = pd.read_csv(r'dados/extract_geo_google.csv', sep=';', dtype=str)
    df_nm_fantasia = pd.read_excel(r'dados/extract_cia_nome_fantasia.xlsx', dtype=str)

    df_google_merge = df_google[['cnpj', 'latitude', 'longitude']]
    df_google_merge.columns = ['cnpj', 'latitude_google', 'longitude_google']
    df_geo = df_nm_fantasia.merge(df_google_merge, on='cnpj', how='left')

    df_geo['latitude'] = df_geo['latitude'].combine_first(df_geo['latitude_google'])
    df_geo['longitude'] = df_geo['longitude'].combine_first(df_geo['longitude_google'])
    df_geo = df_geo.drop(['latitude_google', 'longitude_google'], axis=1)


    # Corrige com dados do google
    ## Correção 1: Dados com coordenadas erradas

    df_correcao_coord = pd.read_excel(r'dados/empresas_correcao.xlsx', dtype=str)
    df_correcao_coord.columns = ['nome_fantasia', 'nome_corrigido', 'latitude', 'longitude', 'detalhe']
    df_correcao_coord['nome_corrigido'] = df_correcao_coord['nome_corrigido'].fillna('')
    df_correcao_coord['latitude'] = df_correcao_coord['latitude'].fillna('')
    df_correcao_coord['nome_fantasia'] = df_correcao_coord['nome_fantasia'].str.strip()

    df_geo['nome_fantasia_temp'] = df_geo['nome_fantasia'].str.strip().copy()
    df_geo['nome_fantasia_temp'] = df_geo['nome_fantasia_temp'].combine_first(df_geo['razao_social'])

    for index, row in df_correcao_coord.iterrows():
        if row['latitude'] == '':
            continue

        df_geo.loc[df_geo['nome_fantasia_temp'] == row['nome_fantasia'], 'latitude'] = row['latitude']
        df_geo.loc[df_geo['nome_fantasia_temp'] == row['nome_fantasia'], 'longitude'] = row['longitude']
        if row['nome_corrigido'] != '':
            df_geo.loc[df_geo['nome_fantasia_temp'] == row['nome_fantasia'], 'nome_fantasia'] = row['nome_corrigido']
    
    df_nao_encontradas = df_geo[df_geo['nome_fantasia_temp'].isin(df_correcao_coord['nome_fantasia'][df_correcao_coord['latitude'] == ''])]
    df_nao_encontradas = df_nao_encontradas[['cnpj', 'nome_fantasia', 'Endereço', 'mun_descricao', 'telefone1', 'telefone2', 'telefone3', 'e-mail', 'site',
       'principal_executivo', 'cargo', 'cadastro', 'atualizacao']]
    df_nao_encontradas.to_excel('dados/empresas_nao_encontradas_cia.xlsx', index=False)

    df_geo = df_geo.drop(['nome_fantasia_temp'], axis=1)

    ## Correção2: Substitui valor
    df_geo = df_geo[~df_geo['razao_social'].str.contains('Unigel')]

    df_geo[df_geo['razao_social'].str.contains('Unigel')]

    df_geo.to_csv(r'dados/transform_geo.csv', sep=';', index=False)
    