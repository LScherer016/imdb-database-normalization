USE filmes_imdb;

-- Desliga a checagem de chaves estrangeiras temporariamente para podermos apagar as tabelas sem erro
SET FOREIGN_KEY_CHECKS = 0;

-- Apaga as tabelas se elas já existirem
DROP TABLE IF EXISTS Elenco;
DROP TABLE IF EXISTS Filme_Genero;
DROP TABLE IF EXISTS Diretor;
DROP TABLE IF EXISTS Ator;
DROP TABLE IF EXISTS Genero;

-- Religa a checagem de chaves
SET FOREIGN_KEY_CHECKS = 1;

-- Cria a coluna de ID do filme
ALTER TABLE filmes_imdb ADD COLUMN id_filme INT AUTO_INCREMENT PRIMARY KEY FIRST;

-- Cria o espaço para receber o ID do diretor depois
ALTER TABLE filmes_imdb ADD COLUMN id_diretor INT;

-- Tabela de Diretores
CREATE TABLE Diretor (
    id_diretor INT AUTO_INCREMENT PRIMARY KEY,
    nome_diretor VARCHAR(255) UNIQUE NOT NULL
);

-- Tabela de Atores (Stars)
CREATE TABLE Ator (
    id_ator INT AUTO_INCREMENT PRIMARY KEY,
    nome_ator VARCHAR(255) UNIQUE NOT NULL
);

-- Tabela de Gêneros
CREATE TABLE Genero (
    id_genero INT AUTO_INCREMENT PRIMARY KEY,
    nome_genero VARCHAR(255) UNIQUE NOT NULL
);

-- Tabela de Elenco (Ponte)
CREATE TABLE Elenco (
    id_filme INT,
    id_ator INT,
    PRIMARY KEY (id_filme, id_ator),
    FOREIGN KEY (id_filme) REFERENCES filmes_imdb(id_filme),
    FOREIGN KEY (id_ator) REFERENCES Ator(id_ator)
);

-- Tabela Filme_Genero (Ponte)
CREATE TABLE Filme_Genero (
    id_filme INT,
    id_genero INT,
    PRIMARY KEY (id_filme, id_genero),
    FOREIGN KEY (id_filme) REFERENCES filmes_imdb(id_filme),
    FOREIGN KEY (id_genero) REFERENCES Genero(id_genero)
);

-- Conexão da chave estrangeira id_diretor
ALTER TABLE filmes_imdb ADD FOREIGN KEY (id_diretor) REFERENCES Diretor(id_diretor);

-- Preenchendo tabela Diretor
INSERT IGNORE INTO Diretor (nome_diretor)
SELECT DISTINCT Director FROM filmes_imdb WHERE Director IS NOT NULL;

-- Preenchendo os Atores (Juntando os 4)
INSERT IGNORE INTO Ator (nome_ator)
SELECT DISTINCT Star1 FROM filmes_imdb WHERE Star1 IS NOT NULL
UNION SELECT DISTINCT Star2 FROM filmes_imdb WHERE Star2 IS NOT NULL
UNION SELECT DISTINCT Star3 FROM filmes_imdb WHERE Star3 IS NOT NULL
UNION SELECT DISTINCT Star4 FROM filmes_imdb WHERE Star4 IS NOT NULL;

-- Preenchendo os Gêneros
INSERT IGNORE INTO Genero (nome_genero)
SELECT DISTINCT Genre FROM filmes_imdb WHERE Genre IS NOT NULL;

-- Desliga a segurança do SQL pra não dar problema
SET SQL_SAFE_UPDATES = 0;

-- Atualiza a tabela ligando o nome do diretor com o ID numérico
UPDATE filmes_imdb f
JOIN Diretor d ON f.Director = d.nome_diretor
SET f.id_diretor = d.id_diretor;

-- Preenchendo Filme_Genero (Cruzando o filme com o ID do gênero)
INSERT INTO Filme_Genero (id_filme, id_genero)
SELECT f.id_filme, g.id_genero 
FROM filmes_imdb f 
JOIN Genero g ON f.Genre = g.nome_genero;

-- Preenchendo Elenco (Cruzando o filme com os IDs dos atores de 1 a 4)
INSERT IGNORE INTO Elenco (id_filme, id_ator)
SELECT f.id_filme, a.id_ator FROM filmes_imdb f JOIN Ator a ON f.Star1 = a.nome_ator
UNION SELECT f.id_filme, a.id_ator FROM filmes_imdb f JOIN Ator a ON f.Star2 = a.nome_ator
UNION SELECT f.id_filme, a.id_ator FROM filmes_imdb f JOIN Ator a ON f.Star3 = a.nome_ator
UNION SELECT f.id_filme, a.id_ator FROM filmes_imdb f JOIN Ator a ON f.Star4 = a.nome_ator;

-- Liga a segurança
SET SQL_SAFE_UPDATES = 1;

-- Limpeza das colunas desnormalizadas da tabela principal
ALTER TABLE filmes_imdb DROP COLUMN Director;
ALTER TABLE filmes_imdb DROP COLUMN Genre;
ALTER TABLE filmes_imdb DROP COLUMN Star1;
ALTER TABLE filmes_imdb DROP COLUMN Star2;
ALTER TABLE filmes_imdb DROP COLUMN Star3;
ALTER TABLE filmes_imdb DROP COLUMN Star4;
