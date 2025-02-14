-- Cria uma tabela temporária chamada temp_time com os dados da tabela time
CREATE TEMP TABLE temp_time AS SELECT * FROM time;

-- Seleciona todos os dados da tabela temporária temp_time
SELECT * FROM temp_time;

CREATE OR REPLACE FUNCTION operacao_funcao() 
RETURNS VOID AS $$
DECLARE 
    -- Declaração de variáveis internas
    v_id INTEGER;
    v_nome VARCHAR(50);
    v_resultado NUMERIC;
BEGIN
    -- Atribuindo valores às variáveis
    v_id := 1;
    v_nome := 'CORINTHIANS';

    -- Exibe uma mensagem com os valores das variáveis
    RAISE NOTICE 'ID: %, Nome: %', v_id, v_nome;

    -- Operações matemáticas básicas
    v_id := v_id + 1;
    RAISE NOTICE 'Soma: %', 1 + 1;
    RAISE NOTICE 'Subtração: %', 1 - 1;
    RAISE NOTICE 'Multiplicação: %', 1 * 1;
    RAISE NOTICE 'Divisão: %', 1 / 1;

    -- Funções adicionais
    -- Exponenciação
    v_resultado := 2^3; -- 2 elevado a 3
    RAISE NOTICE 'Exponenciação: %', v_resultado;

    -- Módulo (resto da divisão)
    v_resultado := 10 % 3; -- Resto da divisão de 10 por 3
    RAISE NOTICE 'Módulo: %', v_resultado;

    -- Valor absoluto
    v_resultado := abs(-5); -- Valor absoluto de -5
    RAISE NOTICE 'Valor absoluto: %', v_resultado;

    -- Raiz quadrada
    v_resultado := sqrt(9); -- Raiz quadrada de 9
    RAISE NOTICE 'Raiz quadrada: %', v_resultado;

    -- Arredondamento
    v_resultado := round(3.14159, 2); -- Arredonda 3.14159 para 2 casas decimais
    RAISE NOTICE 'Arredondamento: %', v_resultado;

    -- Comparações lógicas
    IF 10 > 5 THEN
        RAISE NOTICE '10 é maior que 5';
    END IF;

    IF 'CORINTHIANS' = 'CORINTHIANS' THEN
        RAISE NOTICE 'As strings são iguais';
    END IF;
END;
$$ LANGUAGE plpgsql;


SELECT operacao_funcao();

CREATE OR REPLACE FUNCTION obter_times()
RETURNS SETOF time AS $$
DECLARE
    i INT := 1;  -- Variável de controle do loop
BEGIN
    -- Loop equivalente ao "while"
    LOOP
        EXIT WHEN i > 5;  -- Sai do loop quando i for maior que 5
        RAISE NOTICE 'Valor de i: %', i;  -- Exibe o valor de i
        i := i + 1;  -- Incrementa i
    END LOOP;

    -- Retorna todos os registros da tabela "time"
    RETURN QUERY SELECT * FROM time;
END;
$$ LANGUAGE plpgsql;

SELECT obter_times();


CREATE OR REPLACE FUNCTION obter_times_dados()
RETURNS SETOF time AS $$
DECLARE
    v_time time%ROWTYPE;  -- Declara uma variável do tipo "linha da tabela time"
BEGIN
    -- Percorre todos os registros da tabela "time"
    FOR v_time IN SELECT * FROM time LOOP
        RETURN NEXT v_time;  -- Retorna cada linha da tabela
    END LOOP;

    RETURN;  -- Finaliza a função
END;
$$ LANGUAGE plpgsql;

SELECT FROM gols();


CREATE OR REPLACE FUNCTION gols() RETURNS void AS
$$
DECLARE
    v_gols INTEGER;
BEGIN
    SELECT time_1_gols INTO v_gols FROM partida WHERE id = 1;

    IF v_gols > 2 THEN
        RAISE NOTICE 'Time marcou mais de 2 gols';
    ELSE
        RAISE NOTICE 'Time marcou menos de 2 gols';
    END IF;
END;
$$ LANGUAGE plpgsql;
