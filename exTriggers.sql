CREATE DATABASE ExercicioTriggerDB;
GO
USE ExercicioTriggerDB;
GO



-- Criação da tabela de Usuários
CREATE TABLE Usuarios (
    ID_Usuario INT PRIMARY KEY NOT NULL,
    Password VARCHAR(255),
    Nome_Usuario VARCHAR(255),
    Ramal INT,
    Especialidade VARCHAR(255)
);
GO

-- Criação da tabela de Máquinas
CREATE TABLE Maquina (
    Id_Maquina INT PRIMARY KEY NOT NULL,
    Tipo VARCHAR(255),
    Velocidade INT,
    HardDisk INT,
    Placa_Rede INT,
    Memoria_Ram INT,
    Fk_Usuario INT,
    FOREIGN KEY(Fk_Usuario) REFERENCES Usuarios(ID_Usuario)
);
GO

-- Criação da tabela de Software
CREATE TABLE Software (
    Id_Software INT PRIMARY KEY NOT NULL,
    Produto VARCHAR(255),
    HardDisk INT,
    Memoria_Ram INT,
    Fk_Maquina INT,
    FOREIGN KEY(Fk_Maquina) REFERENCES Maquina(Id_Maquina)
);
GO


-- Inserindo dados na tabela de Usuários
INSERT INTO Usuarios VALUES (1, '123', 'Joao', 123, 'TI');
INSERT INTO Usuarios VALUES (2, '456', 'Maria', 456, 'RH');
INSERT INTO Usuarios VALUES (3, '789', 'Jose', 789, 'Financeiro');
INSERT INTO Usuarios VALUES (4, '101', 'Ana', 101, 'TI');
GO

-- Inserindo dados na tabela de Máquinas
INSERT INTO Maquina VALUES (1, 'Desktop', 2, 500, 1, 4, 1);
INSERT INTO Maquina VALUES (2, 'Notebook', 1, 250, 1, 2, 2);
INSERT INTO Maquina VALUES (3, 'Desktop', 3, 1000, 1, 8, 3);
INSERT INTO Maquina VALUES (4, 'Notebook', 2, 500, 1, 4, 4);
GO

-- Inserindo dados na tabela de Software
INSERT INTO Software VALUES (1, 'Windows', 100, 2, 1);
INSERT INTO Software VALUES (2, 'Linux', 50, 1, 2);
INSERT INTO Software VALUES (3, 'Windows', 200, 4, 3);
INSERT INTO Software VALUES (4, 'Linux', 100, 2, 4);
GO



--1



CREATE TABLE Log_Exclusao_Maquina (
    Id_Log INT PRIMARY KEY IDENTITY(1,1),
    Id_Maquina INT NOT NULL,
    Tipo_Maquina VARCHAR(255),
    Data_Exclusao DATETIME DEFAULT GETDATE()
);
GO

CREATE TRIGGER trg_Audit_Delete_Maquina
ON Maquina
AFTER DELETE
AS
BEGIN
    INSERT INTO Log_Exclusao_Maquina (Id_Maquina, Tipo_Maquina)
    SELECT Id_Maquina, Tipo
    FROM deleted;
END;
GO

-- Criação das Tabelas Auxiliares

CREATE TABLE Auditoria_Maquina (
    Id_Maquina INT,
    Tipo VARCHAR(255),
    Data_Hora DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Maquina_Software_Count (
    Id_Maquina INT PRIMARY KEY,
    Quantidade_Softwares INT
);

CREATE TABLE Maquina_Memoria_Total (
    Id_Maquina INT PRIMARY KEY,
    Memoria_Total INT
);

CREATE TABLE Auditoria_Especialidade (
    ID_Usuario INT,
    Especialidade_Antiga VARCHAR(255),
    Especialidade_Nova VARCHAR(255),
    Data_Alteracao DATETIME DEFAULT CURRENT_TIMESTAMP
);

--------------------------------------------------
-- Trigger 1: Auditoria de Exclusão de Máquinas
--------------------------------------------------

GO
CREATE TRIGGER trg_auditoria_exclusao_maquina
ON Maquina
AFTER DELETE
AS
BEGIN
    INSERT INTO Auditoria_Maquina (Id_Maquina, Tipo, Data_Hora)
    SELECT Id_Maquina, Tipo, GETDATE()
    FROM deleted;
END;


--------------------------------------------------
-- Trigger 2: Evitar Senhas Fracas
--------------------------------------------------
-- Utiliza trigger INSTEAD OF INSERT para validar a senha antes da inserção.
GO
CREATE TRIGGER trg_evitar_senha_fraca
ON Usuarios
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE LEN(Password) < 6)
    BEGIN
        RAISERROR('A senha deve ter pelo menos 6 caracteres.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    INSERT INTO Usuarios (ID_Usuario, Password, Nome_Usuario, Ramal, Especialidade)
    SELECT ID_Usuario, Password, Nome_Usuario, Ramal, Especialidade
    FROM inserted;
END;
GO

--------------------------------------------------
-- Trigger 3: Atualizar Contagem de Softwares em Cada Máquina
--------------------------------------------------
CREATE TRIGGER trg_atualiza_count_software
ON Software
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Atualiza a contagem para máquinas já cadastradas
    UPDATE msc
    SET Quantidade_Softwares = msc.Quantidade_Softwares + t.NewCount
    FROM Maquina_Software_Count msc
    INNER JOIN (
         SELECT FK_Maquina, COUNT(*) AS NewCount
         FROM inserted
         GROUP BY FK_Maquina
    ) t ON msc.Id_Maquina = t.FK_Maquina;

    -- Insere novos registros para máquinas que ainda não existem na tabela auxiliar
    INSERT INTO Maquina_Software_Count (Id_Maquina, Quantidade_Softwares)
    SELECT i.FK_Maquina, COUNT(*)
    FROM inserted i
    WHERE NOT EXISTS (
         SELECT 1 FROM Maquina_Software_Count msc WHERE msc.Id_Maquina = i.FK_Maquina
    )
    GROUP BY i.FK_Maquina;
END;
GO

--------------------------------------------------
-- Trigger 4: Evitar Remoção de Usuários do Setor de TI
--------------------------------------------------
CREATE TRIGGER trg_evitar_exclusao_usuarios_ti
ON Usuarios
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT * FROM deleted WHERE Especialidade = 'TI')
    BEGIN
         RAISERROR('Não é permitido excluir usuários do setor de TI.', 16, 1);
         ROLLBACK TRANSACTION;
         RETURN;
    END

    DELETE FROM Usuarios
    WHERE ID_Usuario IN (SELECT ID_Usuario FROM deleted);
END;
GO

--------------------------------------------------
-- Trigger 5a: Calcular Uso Total de Memória por Máquina (Após INSERT)
--------------------------------------------------
CREATE TRIGGER trg_calcula_memoria_total_insert
ON Software
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH MaquinasAfetadas AS (
         SELECT DISTINCT FK_Maquina
         FROM inserted
    )
    -- Atualiza registros já existentes na tabela auxiliar para as máquinas afetadas
    UPDATE mmt
    SET mmt.Memoria_Total = t.total_mem
    FROM Maquina_Memoria_Total mmt
    INNER JOIN (
         SELECT FK_Maquina, SUM(Memoria_Ram) AS total_mem
         FROM Software
         GROUP BY FK_Maquina
    ) t ON mmt.Id_Maquina = t.FK_Maquina
    WHERE mmt.Id_Maquina IN (SELECT FK_Maquina FROM MaquinasAfetadas);

    -- Insere novos registros para as máquinas que não possuem registro na tabela auxiliar
    INSERT INTO Maquina_Memoria_Total (Id_Maquina, Memoria_Total)
    SELECT t.FK_Maquina, t.total_mem
    FROM (
         SELECT FK_Maquina, SUM(Memoria_Ram) AS total_mem
         FROM Software
         GROUP BY FK_Maquina
    ) t
    WHERE NOT EXISTS (
         SELECT 1 FROM Maquina_Memoria_Total mmt WHERE mmt.Id_Maquina = t.FK_Maquina
    );
END;
GO

--------------------------------------------------
-- Trigger 5b: Calcular Uso Total de Memória por Máquina (Após DELETE)
--------------------------------------------------
CREATE TRIGGER trg_calcula_memoria_total_delete
ON Software
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH MaquinasAfetadas AS (
         SELECT DISTINCT FK_Maquina
         FROM deleted
    )
    -- Atualiza os registros existentes para as máquinas afetadas
    UPDATE mmt
    SET mmt.Memoria_Total = t.total_mem
    FROM Maquina_Memoria_Total mmt
    INNER JOIN (
         SELECT FK_Maquina, COALESCE(SUM(Memoria_Ram), 0) AS total_mem
         FROM Software
         GROUP BY FK_Maquina
    ) t ON mmt.Id_Maquina = t.FK_Maquina
    WHERE mmt.Id_Maquina IN (SELECT FK_Maquina FROM MaquinasAfetadas);

    -- Se não houver nenhum software para a máquina, atualiza o total para zero
    UPDATE mmt
    SET mmt.Memoria_Total = 0
    FROM Maquina_Memoria_Total mmt
    WHERE mmt.Id_Maquina IN (SELECT FK_Maquina FROM deleted)
      AND NOT EXISTS (
          SELECT 1 FROM Software s WHERE s.FK_Maquina = mmt.Id_Maquina
      );
END;
GO

--------------------------------------------------
-- Trigger 6: Registrar Alterações de Especialidade em Usuários
--------------------------------------------------
CREATE TRIGGER trg_auditoria_alteracao_especialidade
ON Usuarios
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Auditoria_Especialidade (ID_Usuario, Especialidade_Antiga, Especialidade_Nova, Data_Alteracao)
    SELECT d.ID_Usuario, d.Especialidade, i.Especialidade, GETDATE()
    FROM deleted d
    INNER JOIN inserted i ON d.ID_Usuario = i.ID_Usuario
    WHERE d.Especialidade <> i.Especialidade;
END;
GO

--------------------------------------------------
-- Trigger 7: Impedir Exclusão de Softwares Essenciais
--------------------------------------------------
CREATE TRIGGER trg_impedir_exclusao_software_essencial
ON Software
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT * FROM deleted WHERE Produto = 'Windows')
    BEGIN
         RAISERROR('Não é permitido excluir software essencial (Windows).', 16, 1);
         ROLLBACK TRANSACTION;
         RETURN;
    END

    DELETE FROM Software
    WHERE Id_Software IN (SELECT Id_Software FROM deleted);
END;

UPDATE Software SET Fk_Maquina = 1 WHERE Fk_Maquina = 2;


-- Exemplo de exclusão:
DELETE FROM Maquina WHERE Id_Maquina = 2;

-- Verificar a auditoria:
SELECT * FROM Auditoria_Maquina;

INSERT INTO Usuarios (ID_Usuario, Password, Nome_Usuario, Ramal, Especialidade)
VALUES (5, '123', 'Teste', 555, 'RH');

-- Inserir novo software:
INSERT INTO Software (Id_Software, Produto, HardDisk, Memoria_Ram, Fk_Maquina)
VALUES (5, 'TesteSoft', 50, 1, 1);

-- Verificar a contagem:
SELECT * FROM Maquina_Software_Count;

-- Tentativa de exclusão de usuário com Especialidade 'TI':
DELETE FROM Usuarios WHERE ID_Usuario = 1;


-- Inserir novo software:
INSERT INTO Software (Id_Software, Produto, HardDisk, Memoria_Ram, Fk_Maquina)
VALUES (6, 'TesteMem', 100, 2, 1);

-- Verificar a memória total:
SELECT * FROM Maquina_Memoria_Total;


-- Excluir o software recém inserido:
DELETE FROM Software WHERE Id_Software = 6;

-- Verificar novamente a memória total:
SELECT * FROM Maquina_Memoria_Total;


-- Atualizar especialidade:
UPDATE Usuarios SET Especialidade = 'Comercial' WHERE ID_Usuario = 2;

-- Verificar a auditoria:
SELECT * FROM Auditoria_Especialidade;


-- Tentativa de exclusão de software essencial:
DELETE FROM Software WHERE Id_Software = 1;
