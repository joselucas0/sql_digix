CREATE TABLE Empregado (
    Nome VARCHAR(50),
    Endereco VARCHAR(500),
    CPF INT PRIMARY KEY NOT NULL,
    DataNasc DATE,
    Sexo CHAR(10),
    CartTrab INT,
    Salario FLOAT,
    NumDep INT,
    CPFSup INT,
    FOREIGN KEY (CPFSup) REFERENCES Empregado(CPF) -- Auto-referência para supervisor
);

CREATE TABLE Departamento (
    NomeDep VARCHAR(50),
    NumDep INT PRIMARY KEY NOT NULL,
    CPFGer INT,
    DataInicioGer DATE,
    FOREIGN KEY (CPFGer) REFERENCES Empregado(CPF)
);

CREATE TABLE Projeto (
    NomeProj VARCHAR(50),
    NumProj INT PRIMARY KEY NOT NULL,
    Localizacao VARCHAR(50),
    NumDep INT,
    FOREIGN KEY (NumDep) REFERENCES Departamento(NumDep)
);

CREATE TABLE Dependente (
    idDependente INT PRIMARY KEY NOT NULL,
    CPFE INT,
    NomeDep VARCHAR(50),
    Sexo CHAR(10),
    Parentesco VARCHAR(50),
    FOREIGN KEY (CPFE) REFERENCES Empregado(CPF) -- Correção na referência do CPF
);

CREATE TABLE Trabalha_Em (
    CPF INT,
    NumProj INT,
    HorasSemana INT,
    PRIMARY KEY (CPF, NumProj), -- Garante que um empregado só possa trabalhar em um projeto uma vez
    FOREIGN KEY (CPF) REFERENCES Empregado(CPF),
    FOREIGN KEY (NumProj) REFERENCES Projeto(NumProj)
);

-- Inserir os dados
insert into Departamento values ('Dep1', 1, null, '1990-01-01');
insert into Departamento values ('Dep2', 2, null, '1990-01-01');
insert into Departamento values ('Dep3', 3, null, '1990-01-01');

insert into Empregado values ('Joao', 'Rua 1', 123, '1990-01-01', 'M', 123, 1000, 1, null);
insert into Empregado values ('Maria', 'Rua 2', 456, '1990-01-01', 'F', 456, 2000, 2, null);
insert into Empregado values ('Jose', 'Rua 3', 789, '1990-01-01', 'M', 789, 3000, 3, null);

update Departamento set CPFGer = 123 where NumDep = 1;
update Departamento set CPFGer = 456 where NumDep = 2;
update Departamento set CPFGer = 789 where NumDep = 3;

insert into Projeto values ('Proj1', 1, 'Local1', 1);
insert into Projeto values ('Proj2', 2, 'Local2', 2);
insert into Projeto values ('Proj3', 3, 'Local3', 3);

insert into Dependente values (1, 123, 'Dep1', 'M', 'Filho');
insert into Dependente values (2, 456, 'Dep2', 'F', 'Filha');
insert into Dependente values (3, 789, 'Dep3', 'M', 'Filho');

insert into Trabalha_Em values (123, 1, 40);
insert into Trabalha_Em values (456, 2, 40);
insert into Trabalha_Em values (789, 3, 40);


--1
CREATE OR REPLACE FUNCTION get_salario(cpf_emp INT) 
RETURNS FLOAT AS $$
DECLARE
    salario_emp FLOAT;
BEGIN
    SELECT salario INTO salario_emp FROM Empregado WHERE CPF = cpf_emp;
    RETURN salario_emp;
END;
$$ LANGUAGE plpgsql;


select get_salario(123);

--2

CREATE OR REPLACE FUNCTION get_nome_departamento(cpf_emp INT) 
RETURNS VARCHAR AS $$
DECLARE
    nome_departamento VARCHAR(50);
BEGIN
    SELECT d.NomeDep INTO nome_departamento 
    FROM Empregado e 
    JOIN Departamento d ON e.NumDep = d.NumDep
    WHERE e.CPF = cpf_emp;
    RETURN nome_departamento;
END;
$$ LANGUAGE plpgsql;

SELECT get_nome_departamento(123);


--3

CREATE OR REPLACE FUNCTION get_gerente_departamento(num_dep INT) 
RETURNS VARCHAR AS $$
DECLARE
    nome_gerente VARCHAR(50);
BEGIN
    SELECT e.Nome INTO nome_gerente 
    FROM Departamento d 
    JOIN Empregado e ON d.CPFGer = e.CPF
    WHERE d.NumDep = num_dep;
    RETURN nome_gerente;
END;
$$ LANGUAGE plpgsql;

SELECT get_gerente_departamento(1);


--4

CREATE OR REPLACE FUNCTION get_nome_projeto(cpf_emp INT) 
RETURNS VARCHAR AS $$
DECLARE
    nome_projeto VARCHAR(50);
BEGIN
    SELECT p.NomeProj INTO nome_projeto 
    FROM Trabalha_Em t 
    JOIN Projeto p ON t.NumProj = p.NumProj
    WHERE t.CPF = cpf_emp;
    RETURN nome_projeto;
END;
$$ LANGUAGE plpgsql;

SELECT get_nome_projeto(123);


--5

CREATE OR REPLACE FUNCTION get_nome_dependente(cpf_emp INT) 
RETURNS VARCHAR AS $$
DECLARE
    nome_dependente VARCHAR(50);
BEGIN
    SELECT d.NomeDep INTO nome_dependente 
    FROM Dependente d
    WHERE d.CPFE = cpf_emp;
    RETURN nome_dependente;
END;
$$ LANGUAGE plpgsql;

SELECT get_nome_dependente(123);


--6

CREATE OR REPLACE FUNCTION get_gerente_empregado(cpf_emp INT) 
RETURNS VARCHAR AS $$
DECLARE
    nome_gerente VARCHAR(50);
BEGIN
    SELECT e2.Nome INTO nome_gerente 
    FROM Empregado e1 
    JOIN Empregado e2 ON e1.CPFSup = e2.CPF
    WHERE e1.CPF = cpf_emp;
    RETURN nome_gerente;
END;
$$ LANGUAGE plpgsql;

--7 

CREATE OR REPLACE FUNCTION get_horas_trabalho(cpf_emp INT) 
RETURNS INT AS $$
DECLARE
    horas_trabalho INT;
BEGIN
    SELECT t.HorasSemana INTO horas_trabalho 
    FROM Trabalha_Em t
    WHERE t.CPF = cpf_emp;
    RETURN horas_trabalho;
END;
$$ LANGUAGE plpgsql;


SELECT get_horas_trabalho(123);

--8

CREATE OR REPLACE FUNCTION get_salario_exception(cpf_emp INT) 
RETURNS FLOAT AS $$
DECLARE
    salario_emp FLOAT;
BEGIN
    SELECT salario INTO salario_emp FROM Empregado WHERE CPF = cpf_emp;
    
    IF salario_emp IS NULL THEN
        RAISE EXCEPTION 'CPF não encontrado';
    END IF;

    RETURN salario_emp;
END;
$$ LANGUAGE plpgsql;

SELECT get_salario_exception(123);
