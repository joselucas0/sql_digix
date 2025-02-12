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






