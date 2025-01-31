-- Seleciona todos os registros da tabela cargos
SELECT * FROM cargos;
-- Seleciona todos os registros da tabela usuarios
SELECT * FROM usuarios;

-- Seleciona apenas a coluna nome da tabela cargo
SELECT cargo.nome FROM cargo;
-- Seleciona apenas a coluna id da tabela cargo
SELECT cargo.id FROM cargo;

-- Usa um alias (abreviação) para a tabela cargo
SELECT c.nome FROM cargo c;
-- Seleciona os nomes das tabelas cargo e usuario sem relação explícita entre elas
SELECT u.nome, c.nome FROM cargo c, usuario u;

-- Seleciona o nome do cargo cujo id é igual a 3
SELECT c.nome FROM cargo c WHERE id = 3;
-- Seleciona o id do usuário cujo nome é "Joao"
SELECT u.id FROM usuario u WHERE u.nome = "Joao";

-- Seleciona os usuários cujo id é 1 ou 2 (utiliza o operador OR)
SELECT u.nome FROM usuario u WHERE u.id = 1 OR u.id = 2;
-- Seleciona os usuários cujo id é 1 e 2 ao mesmo tempo (não retorna resultados pois um id não pode ter dois valores simultaneamente)
SELECT u.nome FROM usuario u WHERE u.id = 1 AND u.id = 2;

-- Seleciona os usuários cujo id está na lista (1,2,3)
SELECT u.nome FROM usuario u WHERE id IN (1,2,3);
-- Seleciona os usuários cujo id NÃO está na lista (1,2,3)
SELECT u.nome FROM usuario u WHERE id NOT IN (1,2,3);

-- Seleciona usuários cujo nome termina com "Jo"
SELECT u.id, u.nome FROM usuario u WHERE nome LIKE '%Jo';
-- Seleciona usuários cujo nome contém "ao" em qualquer posição
SELECT id, nome FROM usuario WHERE nome LIKE '%ao';

-- Seleciona usuários cujo id é maior que 1
SELECT u.id, u.nome FROM usuario u WHERE id > 1;
-- Seleciona usuários cujo id é maior ou igual a 1
SELECT u.id, u.nome FROM usuario u WHERE id >= 1;
-- Seleciona usuários cujo id está entre 2 e 3 (exclusivo)
SELECT u.id, u.nome FROM usuario u WHERE id > 1 AND id < 3;

-- Ordena os usuários pelo id em ordem decrescente (maior para menor)
SELECT u.id, u.nome FROM usuario u ORDER BY id DESC;
-- Ordena os usuários pelo id em ordem crescente (menor para maior)
SELECT u.id, u.nome FROM usuario u ORDER BY id ASC;
-- Ordena os usuários pelo nome em ordem decrescente (Z → A)
SELECT u.id, u.nome FROM usuario u ORDER BY nome DESC;
-- Seleciona apenas o primeiro registro da tabela usuario
SELECT * FROM usuario LIMIT 1;

-- Realiza um INNER JOIN entre as tabelas usuario e cargo, unindo-as pela chave estrangeira fk_usuario.
-- Em seguida, agrupa os resultados pelo nome do cargo e pelo id do usuário.
SELECT c.nome, u.id
FROM usuario u
INNER JOIN cargo c ON u.id = c.fk_usuario
GROUP BY c.nome, u.id;
