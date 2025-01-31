-- Tabela Usuários
CREATE TABLE Usuarios (
    id_Usuario INTEGER NOT NULL PRIMARY KEY,
    senha VARCHAR(50) NOT NULL,
    nome_Usuario VARCHAR(100) NOT NULL,
    ramal VARCHAR(20) NOT NULL,
    especialidade VARCHAR(50)
);

-- Tabela Máquinas
CREATE TABLE Maquinas (
    id_Maquina INTEGER NOT NULL PRIMARY KEY,
    tipo VARCHAR(50),
    velocidade DECIMAL(5,2), -- GHz
    hard_disk INTEGER, -- GB
    placa_rede VARCHAR(50), -- Taxa (ex: '100 Mb/s')
    memoria_ram INTEGER -- GB
);

-- Tabela Software
CREATE TABLE Software (
    id_Software INTEGER NOT NULL PRIMARY KEY,
    produto VARCHAR(100),
    hard_disk INTEGER, -- MB
    memoria_ram INTEGER -- MB
);

-- Tabela de Relacionamento Possuem
CREATE TABLE Possuem (
    id_Usuario INTEGER NOT NULL,
    id_Maquina INTEGER NOT NULL,
    PRIMARY KEY (id_Usuario, id_Maquina),
    FOREIGN KEY (id_Usuario) REFERENCES Usuarios(id_Usuario),
    FOREIGN KEY (id_Maquina) REFERENCES Maquinas(id_Maquina)
);

-- Tabela de Relacionamento Contêm
CREATE TABLE Contem (
    id_Maquina INTEGER NOT NULL,
    id_Software INTEGER NOT NULL,
    PRIMARY KEY (id_Maquina, id_Software),
    FOREIGN KEY (id_Maquina) REFERENCES Maquinas(id_Maquina),
    FOREIGN KEY (id_Software) REFERENCES Software(id_Software)
);



-- Usuários
INSERT INTO Usuarios (id_Usuario, senha, nome_Usuario, ramal, especialidade) VALUES
(1, 'abc123', 'João Silva', 'R001', 'técnico'),
(2, 'def456', 'Maria Souza', 'R002', 'analista'),
(3, 'ghi789', 'Carlos Oliveira', 'R003', 'técnico'),
(4, 'jkl012', 'Ana Costa', 'R004', 'gerente'),
(5, 'mno345', 'Pedro Rocha', 'R005', 'técnico');

-- Máquinas
INSERT INTO Maquinas (id_Maquina, tipo, velocidade, hard_disk, placa_rede, memoria_ram) VALUES
(101, 'Core II', 2.4, 500, '100 Mb/s', 8),
(102, 'Pentium', 1.8, 250, '10 Mb/s', 4),
(103, 'Core III', 3.0, 1000, '1 Gb/s', 16),
(104, 'Core V', 4.2, 2000, '2.5 Gb/s', 32),
(105, 'Dual Core', 2.0, 750, '100 Mb/s', 8);

-- Software
INSERT INTO Software (id_Software, produto, hard_disk, memoria_ram) VALUES
(201, 'C++', 500, 2),
(202, 'Word', 300, 1),
(203, 'Lotus', 400, 1),
(204, 'Photoshop', 2000, 8),
(205, 'Python', 100, 1);

-- Relacionamentos
INSERT INTO Possuem (id_Usuario, id_Maquina) VALUES
(1, 101), (1, 103), (2, 102), (3, 104), (5, 105);

INSERT INTO Contem (id_Maquina, id_Software) VALUES
(101, 201), (102, 202), (103, 203), (104, 204), (105, 205);



1. Todos os usuários com especialidade "técnico"

SELECT * FROM Usuarios WHERE especialidade = 'técnico';


2. Combinações de tipo e velocidade das máquinas

SELECT DISTINCT tipo, velocidade FROM Maquinas;


3. Tipo e velocidade das máquinas Core II e Pentium

SELECT tipo, velocidade FROM Maquinas 
WHERE tipo IN ('Core II', 'Pentium');


4. Máquinas com placa de rede < 10 Mb/s

SELECT id_Maquina, tipo, placa_rede 
FROM Maquinas 
WHERE CAST(SUBSTRING(placa_rede FROM '[0-9]+') AS INTEGER) < 10;


5. Usuários que usam Core III ou Core V
  
SELECT DISTINCT u.nome_Usuario 
FROM Usuarios u
JOIN Possuem p ON u.id_Usuario = p.id_Usuario
JOIN Maquinas m ON p.id_Maquina = m.id_Maquina
WHERE m.tipo IN ('Core III', 'Core V');


6. Máquinas com C++ instalado

SELECT m.id_Maquina 
FROM Maquinas m
JOIN Contem c ON m.id_Maquina = c.id_Maquina
JOIN Software s ON c.id_Software = s.id_Software
WHERE s.produto = 'C++';


7. Máquinas onde o software não roda por falta de RAM

SELECT m.id_Maquina, m.memoria_ram AS ram_maquina, s.produto, s.memoria_ram AS ram_necessaria
FROM Maquinas m
JOIN Contem c ON m.id_Maquina = c.id_Maquina
JOIN Software s ON c.id_Software = s.id_Software
WHERE m.memoria_ram < s.memoria_ram;


8. Nome dos usuários e velocidade de suas máquinas

SELECT u.nome_Usuario, m.velocidade 
FROM Usuarios u
JOIN Possuem p ON u.id_Usuario = p.id_Usuario
JOIN Maquinas m ON p.id_Maquina = m.id_Maquina;


9. Usuários com ID menor que o de Maria

SELECT nome_Usuario, id_Usuario 
FROM Usuarios 
WHERE id_Usuario < (SELECT id_Usuario FROM Usuarios WHERE nome_Usuario = 'Maria Souza');


10. Total de máquinas com velocidade > 2.4 GHz

SELECT COUNT(*) AS total_maquinas 
FROM Maquinas 
WHERE velocidade > 2.4;

11. Número de usuários das máquinas

SELECT COUNT(DISTINCT id_Usuario) AS total_usuarios 
FROM Possuem;

12. Usuários agrupados por tipo de máquina

SELECT m.tipo, COUNT(DISTINCT p.id_Usuario) AS total_usuarios
FROM Maquinas m
LEFT JOIN Possuem p ON m.id_Maquina = p.id_Maquina
GROUP BY m.tipo;

13. o número de usuarios de máquinas dual core

SELECT count (Distinct p.id_Usuario) As total_usuarios
FROM Maquinas m
left join Possuem p On m.id_Maquina = p.id_Maquina
Where m.tipo = 'Dual Core';


14. Disco necessário para Word e Lotus juntos


SELECT SUM(hard_disk) AS total_disco 
FROM Software 
WHERE produto IN ('Word', 'Lotus');
15. Disco usado por máquina


SELECT m.id_Maquina, SUM(s.hard_disk) AS disco_total 
FROM Maquinas m
JOIN Contem c ON m.id_Maquina = c.id_Maquina
JOIN Software s ON c.id_Software = s.id_Software
GROUP BY m.id_Maquina;

16. Média de disco por produto


SELECT AVG(hard_disk) AS media_disco 
FROM Software;
17. Total de máquinas por tipo

SELECT tipo, COUNT(*) AS total_maquinas 
FROM Maquinas 
GROUP BY tipo;

18. Produtos com disco entre 90 e 250 MB

SELECT COUNT(*) AS total_produtos 
FROM Software 
WHERE hard_disk BETWEEN 90 AND 250;


19. Produtos com a letra 'O' no nome

SELECT id_Software, produto 
FROM Software 
WHERE produto LIKE '%O%';

20. Produtos que cabem em qualquer máquina


SELECT s.produto, m.hard_disk AS capacidade_maquina
FROM Software s
CROSS JOIN Maquinas m
WHERE s.hard_disk <= m.hard_disk;


21. Produtos instalados em pelo menos uma máquina


SELECT DISTINCT s.produto 
FROM Software s
JOIN Contem c ON s.id_Software = c.id_Software;




