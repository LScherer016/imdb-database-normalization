import pandas as pd
from sqlalchemy import create_engine

# Conexão com o servidor
motor_mysql = create_engine('mysql+pymysql://root:@localhost/filmes_imdb')


# Carrega a planilha

df_imdb = pd.read_csv('imdb_top_1000.csv')

# Limpando Runtime
# Tira o texto ' min' e converte o que sobrou para número inteiro (int)

df_imdb['Runtime'] = df_imdb['Runtime'].str.replace(' min', '').astype(int)

# Limpando os Títulos

df_imdb['Series_Title'] = df_imdb['Series_Title'].str.replace('"', '').str.replace("'", "")

# Transforma número de votos para int

df_imdb['No_of_Votes'] = df_imdb['No_of_Votes'].astype(int)

# Tira as vírgulas do dinheiro ganho no filme

df_imdb['Gross'] = df_imdb['Gross'].str.replace(',','')

# Força a virar número e transforma em Int64 para podermos ter int com NULL
df_imdb['Gross'] = pd.to_numeric(df_imdb['Gross'], errors='coerce')
df_imdb['Gross'] = df_imdb['Gross'].astype('Int64')

# Transformar o MetaScore em inteiro

df_imdb['Meta_score'] = df_imdb['Meta_score'].astype('Int64')

#print(df_imdb.iloc[48,4])

# Cria o .csv limpo
#df_imdb.to_csv('imdb_top_1000_Brabo.csv', index=False)

# Obs: 'index = false' serve para não colocar a contagem de linhas gerada pelo próprio pandas dentro do nosso .csv  

# Envia para o banco de dados SQL
df_imdb.to_sql('filmes_imdb', motor_mysql, if_exists='replace', index=False)
