create table cargo (
    id int not null,
    nome varchar(50),
    primary key(id),
    fk_usuario int,
	constraint fk_cargo_usuario foreign key (fk_usuario)
	references usuario(id)
);

CREATE TABLE usuario
(
	id int,
	nome VARCHAR(50),
	email VARCHAR(50),
	PRIMARY KEY(id)
);

alter table cargo add column salario decimal(10,2);
alter table cargo alter column nome type varchar(100);
alter table cargo drop column salario;

-- Inserir os dados
insert into usuario values (1, 'Joao', 'joao@gmail.com');
insert into usuario values (2, 'Maria', 'maria@gmail.com');
insert into usuario values (3, 'jose', 'jose@gmail.com');

alter table cargo add column salario decimal(10,2);
insert into cargo values (1, 'Analista', 1, 5000.00);
insert into cargo values (2, 'Analista', 1, 5000.00);
insert into cargo values (3, 'Analista', 1, 7000.00);


update cargo set salario = 6500.00 where id = 2;

delete from usuario where id = 3;

select * from usuario;
select * from cargo;


select from usuario left join cargo on usuario.id = cargo.fk_cargo_usuario;
select from usuario right join cargo on usuario.id = cargo.fk_cargo_usuario;

----exercicio

CREATE TABLE aluno (
    idt_aluno INTEGER PRIMARY KEY,
    des_nome VARCHAR(255) NOT NULL,
    num_grau INTEGER
);

CREATE TABLE curtida (
    idt_aluno1 INTEGER NOT NULL,
    idt_aluno2 INTEGER NOT NULL,
    FOREIGN KEY (idt_aluno1) REFERENCES aluno(idt_aluno),
    FOREIGN KEY (idt_aluno2) REFERENCES aluno(idt_aluno)
);
INSERT INTO aluno (idt_aluno, des_nome, num_grau)
VALUES
  (1, 'João', 8),
  (2, 'Maria', 9),
  (3, 'Pedro', 7),
  (4, 'Ana', 10),
  (5, 'Luiz', 8),
  (6, 'Carla', 9),
  (7, 'Roberto', 7),
  (8, 'Fernanda', 10),
  (9, 'Gustavo', 8),
  (10, 'Juliana', 9);




INSERT INTO curtida (idt_aluno1, idt_aluno2)
VALUES
  (1, 2),
  (3, 4),
  (5, 6);

INSERT INTO amigo (idt_aluno1, idt_aluno2)
VALUES
  (1, 3),
  (2, 4),
  (5, 7);

SELECT * FROM amigo;


SELECT * FROM aluno a
INNER JOIN amigo am ON a.idt_aluno = am.idt_aluno2
INNER JOIN aluno a2 ON am.idt_aluno1 = a2.idt_aluno
WHERE a2.des_nome = 'João';

