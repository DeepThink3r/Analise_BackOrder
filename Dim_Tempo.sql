-- Criação da Dim_Tempo

CREATE TABLE dwh.dim_tempo (
    sk_tempo INT PRIMARY KEY, -- Surrogate Key no formato AAAAMMDD
    data_completa DATE NOT NULL,
    ano INT NOT NULL,
    semestre INT NOT NULL,
    trimestre INT NOT NULL,
    mes INT NOT NULL,
    dia INT NOT NULL,
    ano_mes VARCHAR(7) NOT NULL, -- Formato AAAA-MM
    nome_mes VARCHAR(20) NOT NULL,
    nome_mes_curto CHAR(3) NOT NULL,
    dia_da_semana INT NOT NULL,
    nome_dia_semana VARCHAR(20) NOT NULL,
    nome_dia_semana_curto CHAR(3) NOT NULL,
    dia_do_ano INT NOT NULL,
    semana_do_ano INT NOT NULL,
    flag_fim_de_semana CHAR(1) NOT NULL DEFAULT 'N' -- 'S' para Sim, 'N' para Não
    -- Você pode adicionar outras colunas úteis aqui:
    -- flag_feriado CHAR(1) DEFAULT 'N',
    -- nome_feriado VARCHAR(100),
    -- ano_fiscal INT,
    -- trimestre_fiscal INT
);


DO $$
DECLARE
    data_inicio DATE := '2000-01-01';
    data_fim DATE := '2035-12-31';
    data_atual DATE := data_inicio;
BEGIN
    WHILE data_atual <= data_fim LOOP
        INSERT INTO dwh.dim_tempo (
            sk_tempo,
            data_completa,
            ano,
            semestre,
            trimestre,
            mes,
            dia,
            ano_mes,
            nome_mes,
            nome_mes_curto,
            dia_da_semana,
            nome_dia_semana,
            nome_dia_semana_curto,
            dia_do_ano,
            semana_do_ano,
            flag_fim_de_semana
        ) VALUES (
            -- sk_tempo (AAAAMMDD)
            TO_CHAR(data_atual, 'YYYYMMDD')::INT,
            -- data_completa
            data_atual,
            -- ano
            EXTRACT(YEAR FROM data_atual),
            -- semestre
            CASE WHEN EXTRACT(MONTH FROM data_atual) <= 6 THEN 1 ELSE 2 END,
            -- trimestre
            EXTRACT(QUARTER FROM data_atual),
            -- mes
            EXTRACT(MONTH FROM data_atual),
            -- dia
            EXTRACT(DAY FROM data_atual),
            -- ano_mes (AAAA-MM)
            TO_CHAR(data_atual, 'YYYY-MM'),
            -- nome_mes
            TO_CHAR(data_atual, 'TMMonth'), -- 'TM' remove espaços em branco
            -- nome_mes_curto
            TO_CHAR(data_atual, 'TMMon'),
            -- dia_da_semana (Domingo=1, Sábado=7. Em alguns SGBDs, a semana começa na segunda)
            EXTRACT(ISODOW FROM data_atual), -- ISO standard: Segunda=1, Domingo=7
            -- nome_dia_semana
            TO_CHAR(data_atual, 'TMDay'),
            -- nome_dia_semana_curto
            TO_CHAR(data_atual, 'TMDy'),
            -- dia_do_ano
            EXTRACT(DOY FROM data_atual),
            -- semana_do_ano
            EXTRACT(WEEK FROM data_atual),
            -- flag_fim_de_semana
            CASE WHEN EXTRACT(ISODOW FROM data_atual) IN (6, 7) THEN 'S' ELSE 'N' END
        );

        data_atual := data_atual + INTERVAL '1 day';
    END LOOP;
END $$;