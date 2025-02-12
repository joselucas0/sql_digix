CREATE TABLE time (
id INTEGER PRIMARY KEY,
nome VARCHAR(50)
);
CREATE TABLE partida (
id INTEGER PRIMARY KEY,
time_1 INTEGER,
time_2 INTEGER,
time_1_gols INTEGER,
time_2_gols INTEGER,
FOREIGN KEY(time_1) REFERENCES time(id),
FOREIGN KEY(time_2) REFERENCES time(id)
);
INSERT INTO time(id, nome) VALUES
(1,'CORINTHIANS'),
(2,'SÃO PAULO'),
(3,'CRUZEIRO'),
(4,'ATLETICO MINEIRO'),
(5,'PALMEIRAS');
INSERT INTO partida(id, time_1, time_2, time_1_gols, time_2_gols)
VALUES
(1,4,1,0,4),
(2,3,2,0,1),
(3,1,3,3,0),
(4,3,4,0,1),
(5,1,2,0,0),
(6,2,4,2,2),
(7,1,5,1,2),
(8,5,2,1,2);

CREATE VIEW nome_da_view AS
SELECT coluna1, coluna2, ...
FROM tabela
WHERE condição;

CREATE VIEW vpartida AS
SELECT p.id as partidaID,
p.time_1,
p.time_2,
t1.nome AS nome_time_1,
t2.nome AS nome_time_2,
p.time_1_gols,
p.time_2_gols
FROM partida as p
	JOIN time t1 ON p.time_1 = t1.id
	JOIN time t2 ON p.time_2 = t2.id
ORDER BY 
	p.id ASC;

SELECT * from vpartida;


SELECT V.nome_time_1, V.nome_time_2, V.time_1_gols, V.time_2_gols
from vpartida AS V
WHERE
     V.nome_time_1 ILIKE 'A%' OR V.nome_time_1 ILIKE 'C%' 
    OR V.nome_time_2 ILIKE 'A%' OR V.nome_time_2 ILIKE 'C%'
ORDER BY
	V.nome_time_1 asc,
	V.nome_time_2 asc;
	
CREATE VIEW vencedor AS
SELECT V.partidaid, V.nome_time_1, V.nome_time_2, 
CASE WHEN V.time_1_gols > V.time_2_gols THEN V.nome_time_1
	WHEN V.time_2_gols > V.time_1_gols THEN V.nome_time_2
	ELSE 'empate'
	END AS vencedor
from vpartida AS V;

SELECT * from vencedor;

SELECT * FROM vtime;

CREATE VIEW vtime AS
SELECT
    t.id,
    t.nome,
    COUNT(p.id) AS partidas,
    SUM(CASE WHEN v.vencedor = t.nome THEN 1 ELSE 0 END) AS vitorias,
    SUM(CASE WHEN v.vencedor != t.nome AND v.vencedor != 'empate' THEN 1 ELSE 0 END) AS derrotas,
    SUM(CASE WHEN v.vencedor = 'empate' THEN 1 ELSE 0 END) AS empates,
    SUM(CASE WHEN v.vencedor = t.nome THEN 3 WHEN v.vencedor = 'empate' THEN 1 ELSE 0 END) AS pontos
FROM
    time t
    LEFT JOIN partida p ON t.id = p.time_1 OR t.id = p.time_2
    LEFT JOIN vencedor v ON p.id = v.partidaid
GROUP BY
    t.id, t.nome
ORDER BY
    pontos DESC;

CREATE VIEW vpartida_classificacao AS
SELECT V.nome
FROM vtime AS V
ORDER BY
V.vitorias ASC;

DROP VIEW vpartida_classificacao;




-- Funções Matemáticas
-- Exemplos:
SELECT ABS(-10); -- Retorna o valor absoluto do número
SELECT ROUND(10.5); -- Arredonda o número para o valor mais próximo
SELECT TRUNC(12.7); -- Retorna apenas a parte inteira do número (somente no PostgreSQL)
SELECT TRUNCATE(12.7, 2); -- Seleciona quantas casas decimais deseja (somente no MySQL)
SELECT POWER(2, 3); -- Retorna o valor exponencial (2 elevado a 3)
SELECT LN(4); -- Retorna o logaritmo natural do número
SELECT COS(30); -- Retorna o cosseno do ângulo em radianos
SELECT ATAN(0.5); -- Retorna o arco da tangente
SELECT ASINH(0.5); -- Retorna o arco do seno hiperbólico (somente no PostgreSQL)
SELECT SIGN(50); -- Retorna o sinal do número (1 para positivo, -1 para negativo, 0 para zero)

-- Funções embutidas de Manipulação de String
SELECT CONCAT('afasf', 'fas'); -- Concatena as duas strings
SELECT LENGTH('afasf'); -- Retorna o comprimento da string
SELECT LOWER('GSD'); -- Converte todos os caracteres para minúsculo
SELECT UPPER('dga'); -- Converte todos os caracteres para maiúsculo
SELECT LTRIM(' egadg'); -- Remove espaços em branco à esquerda da string
SELECT RTRIM('egadg '); -- Remove espaços em branco à direita da string
SELECT LPAD('egadg', 10, '*'); -- Preenche a string à esquerda com os caracteres especificados até atingir o comprimento desejado
SELECT RPAD('egadg', 10, '*'); -- Preenche a string à direita com os caracteres especificados até atingir o comprimento desejado
SELECT REVERSE('fagfas'); -- Inverte a string



-- Funções de Data
SELECT CURRENT_DATE; -- Retorna a data atual
SELECT EXTRACT(DAY FROM CURRENT_DATE); -- Extrai o dia da data atual
SELECT AGE('2025-01-01', '2025-02-02'); -- Mostra a diferença entre as duas datas
SELECT interval '1 day';

CREATE FUNCTION soma(a integer, b integer) RETURNS integer AS $$ -- Declaro, coloco parâmetros e o que retornar
BEGIN -- Começo a função
    -- Corpo da função
    RETURN a + b;
END;
$$ LANGUAGE plpgsql; -- Define a linguagem da função (PL/pgSQL)
SELECT soma(10, 5); -- Retorna 15

-- Função para inserir uma partida
CREATE FUNCTION insere_partida(time_1 INT, time_2 INT, time_1_gols INT, time_2_gols INT) RETURNS VOID AS $$
BEGIN
    INSERT INTO partida(time_1, time_2, time_1_gols, time_2_gols) 
    VALUES (time_1, time_2, time_1_gols, time_2_gols);
END;
$$ LANGUAGE plpgsql;

-- Chamando a função
SELECT insere_partida(1, 2, 1, 2);

-- Função de consulta
CREATE OR REPLACE FUNCTION consulta_time() RETURNS TABLE (id INT, nome VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT * FROM time;
END;
$$ LANGUAGE plpgsql;



-- Função com variável interna
-- PostgreSQL
CREATE OR REPLACE FUNCTION consulta_vencedor_por_time(id_time integer) RETURNS varchar(50) AS $$
DECLARE
    vencedor varchar(50);
BEGIN
    SELECT CASE
        WHEN time_1_gols > time_2_gols THEN (SELECT nome FROM time WHERE id = time_1)
        WHEN time_1_gols < time_2_gols THEN (SELECT nome FROM time WHERE id = time_2)
        ELSE 'Empate'
    END INTO vencedor
    FROM partida
    WHERE time_1 = id_time OR time_2 = id_time;
    RETURN vencedor;
END;
$$ LANGUAGE plpgsql;


