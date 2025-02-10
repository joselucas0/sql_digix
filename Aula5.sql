CREATE TABLE Pessoa
(
	id_pessoa SERIAL PRIMARY KEY,
	nome VARCHAR(45) NOT NULL,
	cpf VARCHAR(45) UNIQUE NOT NULL
	
);

CREATE TABLE Engenherio(
	crea INT NOT NULL,
	PRIMARY KEY (id_pessoa)
)INHERITS (Pessoa);


CREATE TABLE Edificacao(
	metragemTotal DECIMAL(5,2) NOT NULL,
	endereco VARCHAR(45) NOT NULL,
	id_responsavel INT NOT NULL,
	FOREIGN KEY (id_responsavel) REFERENCES Engenherio(id_pessoa)
)

ALTER TABLE Edificacao
ADD COLUMN id_edificacao SERIAL PRIMARY KEY;

CREATE TABLE Unidade_Residencial(
	id_unidade SERIAL PRIMARY KEY,
    metragem_unidade FLOAT NOT NULL,
    num_quartos INT NOT NULL,
    num_banheiros INT NOT NULL,
	id_proprietario INT NOT NULL,
	id_edificacao INT NOT NULL,
	FOREIGN KEY (id_proprietario) REFERENCES Pessoa (id_pessoa),
	FOREIGN KEY (id_edificacao) REFERENCES Edificacao (id_edificacao)
)

CREATE TABLE Predio (
    nome VARCHAR(45) NOT NULL,  
    numAndares INT NOT NULL,
    apPorAndar INT NOT NULL
) INHERITS (Edificacao);

CREATE TABLE Casa(
	condominio BOOLEAN NOT NULL
) INHERITS (Edificacao);

CREATE TABLE Casa_Terrea(

)INHERITS (Casa);

CREATE TABLE Sobrado(
	numAndares INT NOT NULL
)INHERITS (Casa);

INSERT INTO Pessoa (nome, cpf) VALUES 
  ('João Silva', '11111111111'),
  ('Maria Souza', '22222222222'),
  ('Carlos Oliveira', '33333333333'),
  ('Ana Costa', '44444444444'),
  ('Pedro Santos', '55555555555'),
  ('Lucia Almeida', '66666666666');

 INSERT INTO Engenherio (nome, cpf, crea) VALUES 
  ('Ricardo Lima', '77777777777', 1001),
  ('Fernanda Pereira', '88888888888', 1002),
  ('Roberto Mendes', '99999999999', 1003),
  ('Juliana Castro', '00000000000', 1004);

INSERT INTO Edificacao (metragemTotal, endereco, id_responsavel) VALUES
  (100.50, 'Rua das Flores, 100 - Bairro Jardim', 8),
  (150.75, 'Avenida Brasil, 200 - Centro', 9),
  (200.00, 'Travessa das Acácias, 300 - Zona Industrial', 10);
  

SELECT * from Pessoa;

INSERT INTO Unidade_Residencial (metragem_unidade, num_quartos, num_banheiros, id_proprietario, id_edificacao) VALUES
  (70.5, 3, 2, 1, 4),
  (85.0, 4, 3, 2, 5),
  (90.0, 3, 2, 3, 6);

INSERT INTO Predio (metragemTotal, endereco, id_responsavel, nome, numAndares, apPorAndar) VALUES
  (250.00, 'Rua Central, 10 - Centro', 7, 'Predio Alpha', 10, 2),
  (300.50, 'Avenida das Nações, 20 - Bairro Novo', 8, 'Predio Beta', 12, 3),
  (280.75, 'Travessa do Sol, 30 - Zona Sul', 10, 'Predio Gamma', 8, 1);

INSERT INTO Casa (metragemTotal, endereco, id_responsavel, condominio) VALUES
  (120.00, 'Rua das Oliveiras, 50 - Jardim das Rosas', 3, true),
  (135.00, 'Avenida dos Pássaros, 60 - Bairro das Aves', 2, false),
  (145.00, 'Travessa das Orquídeas, 70 - Centro', 1, true);


INSERT INTO Casa_Terrea (metragemTotal, endereco, id_responsavel, condominio) VALUES
  (110.00, 'Rua dos Pomares, 80 - Subúrbio', 12, false),
  (115.00, 'Avenida das Palmeiras, 90 - Zona Leste', 13, true);

INSERT INTO Sobrado (metragemTotal, endereco, id_responsavel, condominio, numAndares) VALUES
  (130.00, 'Rua dos Cedros, 110 - Centro', 14, true, 2),
  (140.00, 'Avenida dos Pinheiros, 120 - Subúrbio', 15, false, 3);


--nessa ultima inserçao acabei nao diferenciando engenheiro de pessoa, entao é provavel que em sobrado/casa terrea, os id dos responsaveis, nao sejam necessariamente engenheiros, mas no caso de apartamento, a insercao ja tinha sido realizada antes oq nao influenciou, estando do jeito que deveria ser.
INSERT INTO Pessoa (nome, cpf) VALUES 
  ('Mariana Rocha', '12345678901'),
  ('Lucas Fernandes', '23456789012'),
  ('Patrícia Lima', '34567890123'),
  ('Gustavo Alves', '45678901234');

--Exemplos de consultas
--Listar todas as edificações com o nome do engenheiro responsável
SELECT 
    E.id_edificacao,
    E.metragemTotal,
    E.endereco,
    P.nome AS nome_engenheiro
FROM 
    Edificacao E
JOIN 
    Engenherio Eng ON E.id_responsavel = Eng.id_pessoa
JOIN 
    Pessoa P ON Eng.id_pessoa = P.id_pessoa;
-- Listar todas as unidades residenciais com o nome do proprietário e o endereço da edificação
SELECT 
    UR.id_unidade,
    UR.metragem_unidade,
    UR.num_quartos,
    UR.num_banheiros,
    P.nome AS nome_proprietario,
    E.endereco
FROM 
    Unidade_Residencial UR
JOIN 
    Pessoa P ON UR.id_proprietario = P.id_pessoa
JOIN 
    Edificacao E ON UR.id_edificacao = E.id_edificacao;


--  Listar todos os prédios com o nome do engenheiro responsável e o número de andares
SELECT 
    P.nome AS nome_predio,
    P.numAndares,
    P.apPorAndar,
    Pessoa.nome AS nome_engenheiro
FROM 
    Predio P
JOIN 
    Engenherio Eng ON P.id_responsavel = Eng.id_pessoa
JOIN 
    Pessoa ON Eng.id_pessoa = Pessoa.id_pessoa;

-- Listar todas as unidades residenciais com seus proprietários e endereços, ordenando por metragem da unidade
SELECT 
    UR.id_unidade,
    UR.metragem_unidade,
    P.nome AS nome_proprietario,
    E.endereco
FROM 
    Unidade_Residencial UR
JOIN 
    Pessoa P ON UR.id_proprietario = P.id_pessoa  
JOIN 
    Edificacao E ON UR.id_edificacao = E.id_edificacao  
ORDER BY 
    UR.metragem_unidade;  
