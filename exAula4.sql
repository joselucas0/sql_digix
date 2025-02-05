-- Criacao das tabelas

-- Tabela funcionario
CREATE TABLE funcionario (
    idfuncionario SERIAL PRIMARY KEY,
    nome VARCHAR(45) NOT NULL,
    carteiraTrabalho INT UNIQUE NOT NULL,
    dataContratacao DATE NOT NULL,
    salario FLOAT NOT NULL
);

-- Tabela funcao
CREATE TABLE funcao (
    idfuncao SERIAL PRIMARY KEY,
    nome VARCHAR(45) NOT NULL
);

-- Tabela horario_trabalho_funcionario
CREATE TABLE horario_trabalho_funcionario (
    horario_idhorario INT NOT NULL,
    funcionario_idfuncionario INT NOT NULL,
    funcao_idfuncao INT NOT NULL,
    PRIMARY KEY (horario_idhorario, funcionario_idfuncionario),
    FOREIGN KEY (funcionario_idfuncionario) REFERENCES funcionario(idfuncionario),
    FOREIGN KEY (funcao_idfuncao) REFERENCES funcao(idfuncao)
);

-- Tabela sala
CREATE TABLE sala (
    idSala SERIAL PRIMARY KEY,
    nome VARCHAR(45) NOT NULL,
    capacidade INT NOT NULL
);

-- Tabela diretor
CREATE TABLE diretor (
    idDiretor SERIAL PRIMARY KEY,
    nome VARCHAR(45) NOT NULL
);

-- Tabela genero
CREATE TABLE genero (
    idgenero SERIAL PRIMARY KEY,
    nome VARCHAR(45) NOT NULL
);

-- Tabela premiacao
CREATE TABLE premiacao (
    idpremiacao SERIAL PRIMARY KEY,
    nome VARCHAR(45) NOT NULL,
    ano INT NOT NULL
);

-- Tabela filme
CREATE TABLE filme (
    idfilme SERIAL PRIMARY KEY,
    nomeBR VARCHAR(45) NOT NULL,
    nomeEN VARCHAR(45),
    anolancamento INT,
    director_idDirector INT,
    sinopse TEXT,
    genero_idgenero INT,
    FOREIGN KEY (director_idDirector) REFERENCES diretor(idDiretor),
    FOREIGN KEY (genero_idgenero) REFERENCES genero(idgenero)
);

-- Tabela filme_exibido_sala
CREATE TABLE filme_exibido_sala (
    filme_idfilme INT NOT NULL,
    sala_idSala INT NOT NULL,
    horario_idhorario INT NOT NULL,
    PRIMARY KEY (filme_idfilme, sala_idSala, horario_idhorario),
    FOREIGN KEY (filme_idfilme) REFERENCES filme(idfilme),
    FOREIGN KEY (sala_idSala) REFERENCES sala(idSala)
);

-- Tabela filme_has_premiacao
CREATE TABLE filme_has_premiacao (
    filme_idfilme INT NOT NULL,
    premiacao_idpremiacao INT NOT NULL,
    ganhou BOOL NOT NULL,
    PRIMARY KEY (filme_idfilme, premiacao_idpremiacao),
    FOREIGN KEY (filme_idfilme) REFERENCES filme(idfilme),
    FOREIGN KEY (premiacao_idpremiacao) REFERENCES premiacao(idpremiacao)
);

-- Consultas SQL

-- 1. Média salarial dos funcionários
SELECT AVG(salario) AS media_salario FROM funcionario;

-- 2. Lista de funcionários e suas respectivas funções
SELECT f.nome, fu.nome AS funcao
FROM funcionario f
LEFT JOIN horario_trabalho_funcionario htf ON f.idfuncionario = htf.funcionario_idfuncionario
LEFT JOIN funcao fu ON htf.funcao_idfuncao = fu.idfuncao;

-- 3. Funcionários que compartilham o mesmo horário
SELECT DISTINCT f1.nome
FROM funcionario f1
JOIN horario_trabalho_funcionario htf1 ON f1.idfuncionario = htf1.funcionario_idfuncionario
JOIN horario_trabalho_funcionario htf2 ON htf1.horario_idhorario = htf2.horario_idhorario
JOIN funcionario f2 ON htf2.funcionario_idfuncionario = f2.idfuncionario
WHERE f1.idfuncionario <> f2.idfuncionario;

-- 4. Filmes exibidos em mais de uma sala
SELECT fil.nomeBR
FROM filme fil
JOIN filme_exibido_sala fes ON fil.idfilme = fes.filme_idfilme
GROUP BY fil.idfilme
HAVING COUNT(DISTINCT fes.sala_idSala) >= 2;

-- 5. Filmes e seus respectivos gêneros
SELECT DISTINCT fil.nomeBR, g.nome AS genero
FROM filme fil
JOIN genero g ON fil.genero_idgenero = g.idgenero;

-- 6. Filmes premiados e exibidos
SELECT DISTINCT fil.nomeBR
FROM filme fil
JOIN filme_has_premiacao fhp ON fil.idfilme = fhp.filme_idfilme
JOIN filme_exibido_sala fes ON fil.idfilme = fes.filme_idfilme
WHERE fhp.ganhou = TRUE;

-- 7. Filmes que nunca ganharam premiação
SELECT fil.nomeBR
FROM filme fil
LEFT JOIN filme_has_premiacao fhp ON fil.idfilme = fhp.filme_idfilme
WHERE fhp.filme_idfilme IS NULL;

-- 8. Diretores que dirigiram dois ou mais filmes
SELECT d.nome
FROM diretor d
JOIN filme fil ON d.idDiretor = fil.director_idDirector
GROUP BY d.idDiretor
HAVING COUNT(fil.idfilme) >= 2;

-- 9. Funcionários ordenados por horário de trabalho
SELECT f.nome, htf.horario_idhorario
FROM funcionario f
JOIN horario_trabalho_funcionario htf ON f.idfuncionario = htf.funcionario_idfuncionario
ORDER BY htf.horario_idhorario ASC;

-- 10. Filmes exibidos em salas diferentes em horários distintos
SELECT DISTINCT fil.nomeBR
FROM filme fil
JOIN filme_exibido_sala fes1 ON fil.idfilme = fes1.filme_idfilme
JOIN filme_exibido_sala fes2 ON fes1.sala_idSala = fes2.sala_idSala
WHERE fes1.horario_idhorario <> fes2.horario_idhorario;

-- 11. Listagem de diretores e funcionários com seus respectivos tipos
SELECT nome, 'Diretor' AS tipo FROM diretor
UNION
SELECT nome, 'Funcionario' AS tipo FROM funcionario;

-- 12. Quantidade de funcionários por função
SELECT fu.nome AS funcao, COUNT(f.idfuncionario) AS quantidade_funcionarios
FROM funcao fu
LEFT JOIN horario_trabalho_funcionario htf ON fu.idfuncao = htf.funcao_idfuncao
LEFT JOIN funcionario f ON htf.funcionario_idfuncionario = f.idfuncionario
GROUP BY fu.nome;

-- 13. Filmes exibidos em salas com capacidade acima da média
SELECT DISTINCT fil.nomeBR
FROM filme fil
JOIN filme_exibido_sala fes ON fil.idfilme = fes.filme_idfilme
JOIN sala s ON fes.sala_idSala = s.idSala
WHERE s.capacidade > (SELECT AVG(capacidade) FROM sala);

-- 14. Listagem de funcionários com seus salários anuais
SELECT nome, salario, (salario * 12) AS salario_anual FROM funcionario;

-- 15. Quantidade de filmes exibidos por capacidade da sala
SELECT s.capacidade, COUNT(fes.filme_idfilme) AS total_filmes_exibidos
FROM sala s
LEFT JOIN filme_exibido_sala fes ON s.idSala = fes.sala_idSala
GROUP BY s.capacidade
ORDER BY s.capacidade;
