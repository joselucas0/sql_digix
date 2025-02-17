-- Criar tabela Time
CREATE TABLE time ( 
    id SERIAL PRIMARY KEY, 
    nome VARCHAR(50) NOT NULL UNIQUE
);

-- Criar tabela Partida
CREATE TABLE partida ( 
    id SERIAL PRIMARY KEY, 
    time_1 INTEGER NOT NULL, 
    time_2 INTEGER NOT NULL, 
    time_1_gols INTEGER DEFAULT 0, 
    time_2_gols INTEGER DEFAULT 0, 
    CONSTRAINT fk_time_1 FOREIGN KEY (time_1) REFERENCES time(id) ON DELETE CASCADE, 
    CONSTRAINT fk_time_2 FOREIGN KEY (time_2) REFERENCES time(id) ON DELETE CASCADE
);

-- Inserir times
INSERT INTO time(nome) VALUES 
('CORINTHIANS'), 
('SÃO PAULO'), 
('CRUZEIRO'), 
('ATLETICO MINEIRO'),
('PALMEIRAS');

-- Inserir partidas (id será gerado automaticamente)
INSERT INTO partida(time_1, time_2, time_1_gols, time_2_gols) 
VALUES 
(4,1,0,4), 
(3,2,0,1), 
(1,3,3,0), 
(3,4,0,1), 
(1,2,0,0), 
(2,4,2,2), 
(1,5,1,2),
(5,2,1,2);

-- Verificar dados inseridos
SELECT * FROM time;
SELECT * FROM partida;

-- Criar Procedure para inserir partidas
CREATE OR REPLACE FUNCTION inserir_partida(
    time_1 INT, 
    time_2 INT, 
    time_1_gols INT, 
    time_2_gols INT
) RETURNS VOID AS $$
BEGIN
    INSERT INTO partida (time_1, time_2, time_1_gols, time_2_gols) 
    VALUES (time_1, time_2, time_1_gols, time_2_gols);
END;
$$ LANGUAGE plpgsql;

-- Testar a função
SELECT inserir_partida(1, 2, 3, 1);

-- Verificar se a nova partida foi inserida corretamente
SELECT * FROM partida;

-- Criar Procedure para atualizar nome do time
CREATE OR REPLACE FUNCTION atualizar_nome_time(
    p_id INT, 
    p_nome VARCHAR(100)
) RETURNS VOID AS $$
BEGIN
    UPDATE time
    SET nome = p_nome
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

-- Testar a função
SELECT atualizar_nome_time(1, 'FLAMENGO');

-- Verificar atualização
SELECT * FROM time;


CREATE OR REPLACE FUNCTION excluir_partida(p_id INT) RETURNS VOID AS $$
BEGIN
    DELETE FROM partida WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;
