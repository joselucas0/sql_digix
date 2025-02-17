-- Criar tabela Usuarios primeiro, pois Maquina depende dela
CREATE TABLE Usuarios (
    ID_Usuario INT PRIMARY KEY NOT NULL,
    Password VARCHAR(255),
    Nome_Usuario VARCHAR(255),
    Ramal INT,
    Especialidade VARCHAR(255)
);

-- Criar tabela Maquina que depende de Usuarios
CREATE TABLE Maquina (
    Id_Maquina INT PRIMARY KEY NOT NULL,
    Tipo VARCHAR(255),
    Velocidade INT,
    HardDisk INT,
    Placa_Rede INT,
    Memoria_Ram INT,
    Fk_Usuario INT,
    FOREIGN KEY (Fk_Usuario) REFERENCES Usuarios(ID_Usuario) ON DELETE CASCADE
);

-- Criar tabela Software que depende de Maquina
CREATE TABLE Software (
    Id_Software INT PRIMARY KEY NOT NULL,
    Produto VARCHAR(255),
    HardDisk INT,
    Memoria_Ram INT,
    Fk_Maquina INT,
    FOREIGN KEY (Fk_Maquina) REFERENCES Maquina(Id_Maquina) ON DELETE CASCADE
);

-- Inserir usuários primeiro, pois Maquina depende deles
INSERT INTO Usuarios (ID_Usuario, Password, Nome_Usuario, Ramal, Especialidade) VALUES
(1, '123', 'Joao', 123, 'TI'),
(2, '456', 'Maria', 456, 'RH'),
(3, '789', 'Jose', 789, 'Financeiro'),
(4, '101', 'Ana', 101, 'TI');

-- Inserir máquinas depois, pois Software depende delas
INSERT INTO Maquina (Id_Maquina, Tipo, Velocidade, HardDisk, Placa_Rede, Memoria_Ram, Fk_Usuario) VALUES
(1, 'Desktop', 2, 500, 1, 4, 1),
(2, 'Notebook', 1, 250, 1, 2, 2),
(3, 'Desktop', 3, 1000, 1, 8, 3),
(4, 'Notebook', 2, 500, 1, 4, 4);

-- Inserir softwares por último
INSERT INTO Software (Id_Software, Produto, HardDisk, Memoria_Ram, Fk_Maquina) VALUES
(1, 'Windows', 100, 2, 1),
(2, 'Linux', 50, 1, 2),
(3, 'Windows', 200, 4, 3),
(4, 'Linux', 100, 2, 4);

-- Consultas para verificar se os dados foram inseridos corretamente
SELECT * FROM Usuarios;
SELECT * FROM Maquina;
SELECT * FROM Software;




-- 1. Função para verificar espaço disponível
CREATE OR REPLACE PROCEDURE Verificar_Espaco_Disponivel(
    IN id_maquina INT,
    OUT espaco_suficiente BOOLEAN
) AS $$
DECLARE
    espaco_disponivel INT;
BEGIN
    SELECT m.HardDisk - COALESCE(SUM(s.HardDisk), 0) 
    INTO espaco_disponivel
    FROM Maquina m
    LEFT JOIN Software s ON m.Id_Maquina = s.Fk_Maquina
    WHERE m.Id_Maquina = Verificar_Espaco_Disponivel.id_maquina
    GROUP BY m.HardDisk;

    espaco_suficiente := espaco_disponivel > 0;
END;
$$ LANGUAGE plpgsql;

--2


CREATE OR REPLACE PROCEDURE Instalar_Software(
    IN p_id_software INT,  -- Renomeei o parâmetro para evitar ambiguidade
    IN p_id_maquina INT    -- Renomeei o parâmetro para evitar ambiguidade
) AS $$
DECLARE
    espaco_suficiente BOOLEAN;
BEGIN
    -- Verifica se há espaço disponível na máquina
    CALL Verificar_Espaco_Disponivel(p_id_maquina, espaco_suficiente);
    
    -- Se houver espaço, instala o software
    IF espaco_suficiente THEN
        UPDATE Software 
        SET Fk_Maquina = p_id_maquina 
        WHERE Id_Software = p_id_software;
        RAISE NOTICE 'Software instalado com sucesso.';
    ELSE
        RAISE NOTICE 'Espaço insuficiente para instalação.';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 3. Função para listar máquinas de um usuário
CREATE OR REPLACE PROCEDURE Listar_Maquinas_Do_Usuario(
    IN id_usuario INT
) AS $$
DECLARE
    maquina RECORD;  -- Variável para armazenar cada linha do resultado
    cur CURSOR FOR   -- Cursor para iterar sobre os resultados
        SELECT m.Id_Maquina, m.Tipo, m.Velocidade
        FROM Maquina m
        WHERE m.Fk_Usuario = Listar_Maquinas_Do_Usuario.id_usuario;
BEGIN
    RAISE NOTICE 'Máquinas do usuário %:', id_usuario;

    -- Abre o cursor
    OPEN cur;

    -- Itera sobre os resultados
    LOOP
        FETCH cur INTO maquina;  -- Busca a próxima linha
        EXIT WHEN NOT FOUND;     -- Sai do loop quando não houver mais linhas

        -- Exibe os dados da máquina
        RAISE NOTICE 'ID: %, Tipo: %, Velocidade: %', maquina.Id_Maquina, maquina.Tipo, maquina.Velocidade;
    END LOOP;

    -- Fecha o cursor
    CLOSE cur;
END;
$$ LANGUAGE plpgsql;

-- 4. Procedure para atualizar recursos da máquina
DROP PROCEDURE atualizar_recursos_maquina(integer,integer,integer);
CREATE OR REPLACE PROCEDURE Atualizar_Recursos_Maquina(
    IN p_id_maquina INT,  -- Renomeei o parâmetro para evitar ambiguidade
    IN nova_ram INT,
    IN novo_hd INT
) AS $$
BEGIN
    UPDATE Maquina 
    SET Memoria_Ram = nova_ram, HardDisk = novo_hd 
    WHERE Id_Maquina = p_id_maquina;  -- Usei o novo nome do parâmetro
    RAISE NOTICE 'Recursos da máquina % atualizados com sucesso.', p_id_maquina;
END;
$$ LANGUAGE plpgsql;

-- 5. Procedure para transferir software entre máquinas
CREATE OR REPLACE PROCEDURE Transferir_Software(
    IN p_id_software INT,  -- Renomeei o parâmetro para evitar ambiguidade
    IN p_id_origem INT,    -- Renomeei o parâmetro para evitar ambiguidade
    IN p_id_destino INT    -- Renomeei o parâmetro para evitar ambiguidade
) AS $$
DECLARE
    espaco_suficiente BOOLEAN;
BEGIN
    -- Verifica se há espaço disponível na máquina de destino
    CALL Verificar_Espaco_Disponivel(p_id_destino, espaco_suficiente);
    
    -- Se houver espaço, transfere o software
    IF espaco_suficiente THEN
        UPDATE Software 
        SET Fk_Maquina = p_id_destino 
        WHERE Id_Software = p_id_software AND Fk_Maquina = p_id_origem;
        RAISE NOTICE 'Software transferido com sucesso.';
    ELSE
        RAISE NOTICE 'Espaço insuficiente na máquina de destino.';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 6. Função para calcular média de recursos das máquinas
CREATE OR REPLACE PROCEDURE Calcular_Media_Recursos(
    OUT p_media_memoria_ram FLOAT,  -- Renomeei o parâmetro para evitar ambiguidade
    OUT p_media_harddisk FLOAT      -- Renomeei o parâmetro para evitar ambiguidade
) AS $$
BEGIN
    -- Calcula a média de memória RAM e HD de todas as máquinas
    SELECT AVG(m.Memoria_Ram), AVG(m.HardDisk) 
    INTO p_media_memoria_ram, p_media_harddisk
    FROM Maquina m;
    
    -- Exibe as médias
    RAISE NOTICE 'Média de Memória RAM: %, Média de HD: %', p_media_memoria_ram, p_media_harddisk;
END;
$$ LANGUAGE plpgsql;

CALL Instalar_Software(2, 1); -- Tenta instalar o software ID 2 na máquina ID 1
SELECT * FROM Software WHERE Id_Software = 2; -- Verifica se o Fk_Maquina foi atualizado


CALL Listar_Maquinas_Do_Usuario(1);
CALL Transferir_Software(2, 1, 3);

CALL Atualizar_Recursos_Maquina(1, 8, 1000);


DO $$
DECLARE
    media_memoria_ram FLOAT;
    media_harddisk FLOAT;
BEGIN
    CALL Calcular_Media_Recursos(media_memoria_ram, media_harddisk);
    RAISE NOTICE 'Média de Memória RAM: %, Média de HD: %', media_memoria_ram, media_harddisk;
END;
$$;
