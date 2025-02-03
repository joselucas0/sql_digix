CREATE Table Empregado(
	CPF CHAR(11) PRIMARY KEY,
	Nome VARCHAR(100) NOT NULL,
	Endereço VARCHAR(255),
	DataNasc DATE,
    Sexo CHAR(1),
    CartTrab VARCHAR(20),
    Salario DECIMAL(10,2),
    NumDep INT,
    CPFsuper CHAR(11),
    FOREIGN KEY (CPFsuper) REFERENCES Empregado(CPF)
);

CREATE TABLE Departamento (
    NumDep INT PRIMARY KEY,
    NomeDep VARCHAR(100) NOT NULL,
	  Localizacao VARCHAR(255),
    CPFGer CHAR(11),  
    DataInicioGer DATE,
    FOREIGN KEY (CPFGer) REFERENCES Empregado(CPF) 
);

CREATE TABLE Projeto (
    NumProj INT PRIMARY KEY,
    NomeProj VARCHAR(100) NOT NULL,
    Localizacao VARCHAR(100),
    NumD INT,
    FOREIGN KEY (NumD) REFERENCES Departamento(NumDep)
);

CREATE TABLE Dependente (
    CPFE CHAR(11),
    NomeDep VARCHAR(100) NOT NULL,
    Sexo CHAR(1),
    Parentesco VARCHAR(50),
    PRIMARY KEY (CPFE, NomeDep),
    FOREIGN KEY (CPFE) REFERENCES Empregado(CPF)
);


CREATE TABLE Trabalha_em (
    CPFE CHAR(11),
    NumProj INT,
    Horas DECIMAL(5,2),
    PRIMARY KEY (CPFE, NumProj),
    FOREIGN KEY (CPFE) REFERENCES Empregado(CPF),
    FOREIGN KEY (NumProj) REFERENCES Projeto(NumProj)
);


-- Inserir empregados

INSERT INTO Empregado (CPF, Nome, Endereço, DataNasc, Sexo, CartTrab, Salario, NumDep, CPFsuper)
VALUES 
('12345678901', 'José da Silva', 'Rua A, 123', '1985-06-15', 'M', 'CT1234', 5000.00, 1, NULL),
('98765432100', 'Maria Souza', 'Av. B, 456', '1990-09-20', 'F', 'CT5678', 6000.00, 1, '12345678901'),
('55544433322', 'Carlos Almeida', 'Rua C, 789', '1988-12-05', 'M', 'CT9999', 4500.00, 2, '12345678901');

-- Inserir departamentos

INSERT INTO Departamento (NumDep, NomeDep, Localizacao, CPFGer, DataInicioGer)
VALUES 
(1, 'TI', 'São Paulo', '12345678901', '2023-01-01'),
(2, 'Financeiro', 'Rio de Janeiro', '98765432100', '2023-05-10');

-- Inserir projetos

INSERT INTO Projeto (NumProj, NomeProj, Localizacao, NumD)
VALUES 
(101, 'Sistema X', 'São Paulo', 1),
(102, 'App Y', 'Rio de Janeiro', 2);


-- Inserir dependentes


INSERT INTO Dependente (CPFE, NomeDep, Sexo, Parentesco)
VALUES 
('12345678901', 'João Silva', 'M', 'Filho'),
('98765432100', 'Ana Souza', 'F', 'Filha');


-- Inserir trabalhos em projetos


INSERT INTO Trabalha_em (CPFE, NumProj, Horas)
VALUES 
('12345678901', 101, 40.0),
('98765432100', 102, 35.0),
('55544433322', 101, 20.0);


--Listar todos os empregados e seus departamentos
SELECT E.Nome, D.NomeDep, E.Salario
FROM Empregado E
JOIN Departamento D ON E.NumDep = D.NumDep;


--Ver projetos e seus respectivos departamentos
SELECT P.NomeProj, D.NomeDep, P.Localizacao
FROM Projeto P
JOIN Departamento D ON P.NumD = D.NumDep;

--Listar empregados e seus supervisores
SELECT E.Nome AS Empregado, S.Nome AS Supervisor
FROM Empregado E
LEFT JOIN Empregado S ON E.CPFsuper = S.CPF;

--Listar dependentes de cada empregado
SELECT E.Nome AS Empregado, D.NomeDep AS Dependente, D.Parentesco
FROM Dependente D
JOIN Empregado E ON D.CPFE = E.CPF;


SELECT Nome as "NomePessoas", 'Empregado' AS Tipo
FROM empregado
UNION
SELECT NomeDep As NomePessoa, 'Dependente' AS TIPO
FROM Dependente;



SELECT t1.CPFE 
FROM Trabalha_em t1
JOIN Trabalha_em t2 
ON t1.NumProj = t2.NumProj AND t1.Horas = t2.Horas
WHERE t2.CPFE = '12345678901';


SELECT E.Nome
FROM empregado E
WHERE E.Salario >(
	SELECT MAX(salario)
	FROM empregado
	WHERE NumDep = 2
);


