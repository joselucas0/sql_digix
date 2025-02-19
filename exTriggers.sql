-- Criar tabela de partidas
create table partida (
    id serial primary key,
    time_1 int not null,
    time_2 int not null,
    time_1_gols int not null,
    time_2_gols int not null
);

-- Criar tabela de logs
create table log_partida (
    id serial primary key,
    partida_id int not null,
    acao varchar(50) not null,
    data_hora timestamp default current_timestamp
);

-- Criar a função do trigger
create or replace function log_partida_insert()
returns trigger as $$
begin
    insert into log_partida(partida_id, acao) 
    values (NEW.id, 'INSERT');
    return NEW;
end;
$$ language plpgsql;

-- Criar o trigger para inserir log após inserção na tabela partida
create trigger log_partida_insert
after insert on partida
for each row
execute function log_partida_insert();

-- Testando a inserção
insert into partida(id, time_1, time_2, time_1_gols, time_2_gols) 
values (9, 1, 2, 1, 0);

-- Verificando se o log foi registrado
select * from log_partida;


-- Criar a função do trigger para logar atualizações na tabela partida
create or replace function update_partida()
returns trigger as $$
begin
    insert into log_partida(partida_id, acao) 
    values (NEW.id, 'UPDATE');
    return NEW;
end;
$$ language plpgsql;

-- Criar o trigger para capturar updates na tabela partida
create trigger update_partida
after update on partida
for each row
execute function update_partida();

-- Testar o trigger atualizando uma partida
update partida set time_1_gols = 2 where id = 11;

-- Verificar se o log foi inserido corretamente
select * from log_partida;


-- Função do trigger
CREATE OR REPLACE FUNCTION impedir_update_partida_finalizada()
RETURNS TRIGGER AS $$
DECLARE
    partida_ja_inserida BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM log_partida
        WHERE partida_id = OLD.id AND acao = 'INSERT'
    ) INTO partida_ja_inserida;

    IF partida_ja_inserida THEN
        RAISE EXCEPTION 'Não é possível atualizar uma partida finalizada.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger
CREATE TRIGGER impedir_update_partida_finalizada
BEFORE UPDATE ON partida
FOR EACH ROW
EXECUTE FUNCTION impedir_update_partida_finalizada();


-- Função do trigger
CREATE OR REPLACE FUNCTION delete_partida()
RETURNS TRIGGER AS $$
BEGIN
    -- Impedir a exclusão de partidas
    RAISE EXCEPTION 'Não é permitido deletar partidas';
END;
$$ LANGUAGE plpgsql;

-- Trigger
CREATE TRIGGER delete_partida
BEFORE DELETE ON partida
FOR EACH ROW
EXECUTE FUNCTION delete_partida();
