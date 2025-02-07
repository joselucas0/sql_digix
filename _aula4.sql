CREATE TABLE instrutor (
    tdinstrutor INT PRIMARY KEY,
    RG INT,
    nome VARCHAR(45),
    nascimento DATE,
    titulacao INT
);

CREATE TABLE telefone_instrutor (
    tetelefone INT PRIMARY KEY,
    numero INT,
    tipo VARCHAR(45),
    instrutor_tdinstrutor INT,
	FOREIGN KEY (instrutor_tdinstrutor) REFERENCES instrutor(tdinstrutor)
    
);

CREATE TABLE aluno (
    codMatricula INT PRIMARY KEY,
    turma_tdturna INT,
    dataMatricula DATE,
    nome VARCHAR(45),
    endereco TEXT,
    telefone INT,
    dataNascimento DATE,
    altura FLOAT,
    peso INT
);

CREATE TABLE atividade (
    tdatividade INT PRIMARY KEY,
    nome VARCHAR(100)
);


-- criando tabela chamada 
CREATE TABLE turma (
    tdturna INT PRIMARY KEY,
    horario TIME,
    duracao INT,
    datainicio DATE,
    dataFilm DATE,
    atividade_tdatividade INT,
    instrutor_tdinstrutor INT,
    FOREIGN KEY (atividade_tdatividade) REFERENCES atividade(tdatividade),
    FOREIGN KEY (instrutor_tdinstrutor) REFERENCES instrutor(tdinstrutor)
);

-- criando tabela chamada matricula
CREATE TABLE matricula (
    aluno_codMatricula INT,
    turma_tdturna INT,
    PRIMARY KEY (aluno_codMatricula, turma_tdturna),
    FOREIGN KEY (aluno_codMatricula) REFERENCES aluno(codMatricula),
    FOREIGN KEY (turma_tdturna) REFERENCES turma(tdturna)
);


-- criando tabela chamada
CREATE TABLE chamada (
    lichamada INT PRIMARY KEY,
    data DATE,
    presente BOOL,
    matricula_aluno_codMatricula INT,
    matricula_turma_tdturna INT,
    FOREIGN KEY (matricula_aluno_codMatricula, matricula_turma_tdturna) REFERENCES matricula(aluno_codMatricula, turma_tdturna)
);

--eliminando redundancia e conectando a tabela chamada com a aluno

ALTER TABLE chamada
ADD COLUMN aluno_codMatricula INT;

UPDATE chamada
SET aluno_codMatricula = matricula_aluno_codMatricula;

ALTER TABLE chamada
DROP COLUMN matricula_aluno_codMatricula,
DROP COLUMN matricula_turma_tdturna;

ALTER TABLE chamada
ADD CONSTRAINT fk_chamada_aluno
FOREIGN KEY (aluno_codMatricula) REFERENCES aluno(codMatricula);

DROP TABLE matricula;




-- inserindo dados na tabela instrutor
INSERT INTO instrutor (tdinstrutor, RG, nome, nascimento, titulacao) VALUES
(7, 123456789, 'João Silva', '1980-05-15', 1),
(8, 987654321, 'Maria Oliveira', '1975-08-22', 2),
(9, 456789123, 'Carlos Souza', '1990-03-10', 1),
(10, 321654987, 'Ana Costa', '1985-11-30', 3),
(11, 654123987, 'Pedro Rocha', '1978-07-25', 2);


-- inserindo dados na tabela telefone_instrutor
INSERT INTO telefone_instrutor (tetelefone, numero, tipo, instrutor_tdinstrutor) VALUES
(1, 999888777, 'Celular', 1),
(2, 888777666, 'Residencial', 2),
(3, 777666555, 'Celular', 3),
(4, 666555444, 'Trabalho', 4),
(5, 555444333, 'Celular', 5);


-- inserindo dados na tabela aluno
INSERT INTO aluno (codMatricula, turma_tdturna, dataMatricula, nome, endereco, telefone, dataNascimento, altura, peso) VALUES
(1, 1, '2023-01-10', 'Lucas Fernandes', 'Rua A, 123', 111222333, '2005-04-12', 1.75, 65),
(2, 2, '2023-02-15', 'Mariana Santos', 'Rua B, 456', 222333444, '2006-07-18', 1.68, 60),
(3, 3, '2023-03-20', 'Gustavo Lima', 'Rua C, 789', 333444555, '2004-09-25', 1.80, 70),
(4, 4, '2023-04-25', 'Camila Alves', 'Rua D, 101', 444555666, '2005-12-30', 1.65, 55),
(5, 5, '2023-05-30', 'Rafael Pereira', 'Rua E, 202', 555666777, '2003-03-05', 1.78, 72);

-- inserindo na tabela turma
INSERT INTO turma (tdturna, horario, duracao, datainicio, dataFilm, atividade_tdatividade, instrutor_tdinstrutor) VALUES
(1, '09:00:00', 60, '2023-06-01', '2023-06-01', 1, 1),
(2, '10:00:00', 90, '2023-06-02', '2023-06-02', 2, 2),
(3, '14:00:00', 60, '2023-06-03', '2023-06-03', 3, 3),
(4, '16:00:00', 90, '2023-06-04', '2023-06-04', 4, 4),
(5, '18:00:00', 60, '2023-06-05', '2023-06-05', 5, 5);

-- inserindo na tabela attividade
INSERT INTO atividade (tdatividade, nome) VALUES
(1, 'Yoga'),
(2, 'Pilates'),
(3, 'Musculação'),
(4, 'Dança'),
(5, 'Natação');

-- inserindo na tabela matricula
INSERT INTO matricula (aluno_codMatricula, turma_tdturna) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

-- inserindo na tabela chamada
INSERT INTO chamada (lichamada, data, presente, matricula_aluno_codMatricula, matricula_turma_tdturna) VALUES
(1, '2023-06-01', TRUE, 1, 1),
(2, '2023-06-02', TRUE, 2, 2),
(3, '2023-06-03', FALSE, 3, 3),
(4, '2023-06-04', TRUE, 4, 4),
(5, '2023-06-05', TRUE, 5, 5);


-- 1. Listar todos os alunos e os nomes das turmas em que estão matriculados

SELECT a.nome AS NomeAluno, t.tdturna AS TurmaID, t.horario AS HorarioTurma
FROM aluno a
JOIN turma t ON a.turma_tdturna = t.tdturna;

SELECT * FROM aluno;


--2. Contar quantos alunos estão matriculados em cada turma

SELECT t.tdturna AS TurmaID, COUNT(c.aluno_codMatricula) AS NumeroDeAlunos
FROM turma t
JOIN chamada c ON t.tdturna = c.turma_tdturna
GROUP BY t.tdturna;


--3. Mostrar a média de idade dos alunos em cada turma
SELECT t.tdturna AS TurmaID, 
       ROUND(AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, a.dataNascimento))), 2) AS MediaIdade
FROM turma t
JOIN aluno a ON t.tdturna = a.turma_tdturna
GROUP BY t.tdturna;
--4. Encontrar as turmas com mais de 3 alunos matriculados

SELECT t.tdturna AS TurmaID, COUNT(c.aluno_codMatricula) AS NumeroDeAlunos
FROM turma t
JOIN chamada c ON t.tdturna = c.turma_tdturna
GROUP BY t.tdturna
HAVING COUNT(c.aluno_codMatricula) > 3;


--5. Exibir os instrutores que orientam turmas e que nao possuem turmas

-- Instrutores que orientam turmas
SELECT i.nome AS NomeInstrutor, t.tdturna AS TurmaID, t.horario AS HorarioTurma
FROM instrutor i
LEFT JOIN turma t ON i.tdinstrutor = t.instrutor_tdinstrutor;

-- instrutores que nao orientam turma

SELECT i.nome AS NomeInstrutor
FROM instrutor i
LEFT JOIN turma t ON i.tdinstrutor = t.instrutor_tdinstrutor
WHERE t.tdturna IS NULL;


--6. Encontrar alunos que frequentaram todas as aulas de sua turma
SELECT a.nome AS NomeAluno, t.tdturna AS TurmaID
FROM aluno a
JOIN chamada c ON a.codMatricula = c.aluno_codMatricula
JOIN turma t ON a.turma_tdturna = t.tdturna
GROUP BY a.codMatricula, t.tdturna
HAVING COUNT(c.presente = TRUE) = (
    SELECT COUNT(*)
    FROM chamada
    WHERE turma_tdturna = t.tdturna
);

--7. Mostrar os instrutores que ministram turmas de "Crossfit" ou "Yoga"
SELECT DISTINCT i.nome AS NomeInstrutor
FROM instrutor i
JOIN turma t ON i.tdinstrutor = t.instrutor_tdinstrutor
JOIN atividade a ON t.atividade_tdatividade = a.tdatividade
WHERE a.nome IN ('Crossfit', 'Yoga');

--8. Alunos matriculados em mais de uma turma

SELECT a.nome AS NomeAluno, COUNT(a.turma_tdturna) AS NumeroDeTurmas
FROM aluno a
GROUP BY a.codMatricula
HAVING COUNT(a.turma_tdturna) > 1;

