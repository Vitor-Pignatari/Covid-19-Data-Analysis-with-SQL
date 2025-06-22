-- Consideramos a seguinte logica, baseado nas informacoes do dicionario de dados:
	-- Se ocupacao_hospitalar_cli = 0, entao ocupacao_covid_cli = 0.
	-- Se ocupacao_covid_cli = 0, entao ocupacao_suspeito_cli = 0 e ocupacao_confirmado_cli = 0
	-- Se ocupacao_hospitalar_uti = 0, entao ocupacao_covid_uti = 0.
	-- Se ocupacao_covid_uti = 0, entao ocupacao_suspeito_uti = 0 e ocupacao_confirmado_uti = 0

-- Validacao coluna ocupacao_covid_cli
SELECT 
	COUNT(*)::DECIMAL AS sem_logica_count,
	(SELECT COUNT(*)::DECIMAL FROM registro_ocupacao_02_sem_decimais) AS total_count,
	ROUND(COUNT(*)::DECIMAL / (SELECT COUNT(*)::DECIMAL FROM registro_ocupacao_02_sem_decimais), 4) AS sem_logica_percentual
FROM registro_ocupacao_02_sem_decimais
WHERE (ocupacao_hospitalar_cli = 0 AND ocupacao_covid_cli > 0)
	OR (ocupacao_hospitalar_cli IS NULL AND ocupacao_covid_cli IS NOT NULL);

-- Validacao coluna ocupacao_covid_uti
SELECT 
	COUNT(*)::DECIMAL AS sem_logica_count,
	(SELECT COUNT(*)::DECIMAL FROM registro_ocupacao_02_sem_decimais) AS total_count,
	ROUND(COUNT(*)::DECIMAL / (SELECT COUNT(*)::DECIMAL FROM registro_ocupacao_02_sem_decimais), 4) AS sem_logica_percentual
FROM registro_ocupacao_02_sem_decimais
WHERE (ocupacao_hospitalar_uti = 0 AND ocupacao_covid_uti > 0)
	OR (ocupacao_hospitalar_uti IS NULL AND ocupacao_covid_uti IS NOT NULL);

-- Validacao colunas ocupacao_suspeito_cli e ocupacao_confirmado_cli
SELECT 
	COUNT(*)::DECIMAL AS sem_logica_count,
	(SELECT COUNT(*)::DECIMAL FROM registro_ocupacao_02_sem_decimais) AS total_count,
	ROUND(COUNT(*)::DECIMAL / (SELECT COUNT(*)::DECIMAL FROM registro_ocupacao_02_sem_decimais), 4) AS sem_logica_percentual
FROM registro_ocupacao_02_sem_decimais
WHERE (ocupacao_covid_cli = 0 AND (ocupacao_suspeito_cli > 0 OR ocupacao_confirmado_cli > 0))
	OR (ocupacao_covid_cli IS NULL AND (ocupacao_suspeito_cli IS NOT NULL OR ocupacao_confirmado_cli IS NOT NULL));

-- Validacao colunas ocupacao_suspeito_uti e ocupacao_confirmado_uti
SELECT 
	COUNT(*)::DECIMAL AS sem_logica_count,
	(SELECT COUNT(*)::DECIMAL FROM registro_ocupacao_02_sem_decimais) AS total_count,
	ROUND(COUNT(*)::DECIMAL / (SELECT COUNT(*)::DECIMAL FROM registro_ocupacao_02_sem_decimais), 4) AS sem_logica_percentual
FROM registro_ocupacao_02_sem_decimais
WHERE (ocupacao_covid_uti = 0 AND (ocupacao_suspeito_uti > 0 OR ocupacao_confirmado_uti > 0))
	OR (ocupacao_covid_uti IS NULL AND (ocupacao_suspeito_uti IS NOT NULL OR ocupacao_confirmado_uti IS NOT NULL));

-- Verificacao da quantidade total de casos em que a logica acima nao se aplica
SELECT 
	COUNT(*)::DECIMAL AS sem_logica_count,
	(SELECT COUNT(*)::DECIMAL FROM registro_ocupacao_02_sem_decimais) AS total_count,
	ROUND(COUNT(*)::DECIMAL / (SELECT COUNT(*)::DECIMAL FROM registro_ocupacao_02_sem_decimais), 4) AS sem_logica_percentual
FROM registro_ocupacao_02_sem_decimais
WHERE (ocupacao_hospitalar_cli = 0 AND ocupacao_covid_cli > 0)
	OR (ocupacao_hospitalar_cli IS NULL AND ocupacao_covid_cli IS NOT NULL)
	OR (ocupacao_hospitalar_uti = 0 AND ocupacao_covid_uti > 0)
	OR (ocupacao_hospitalar_uti IS NULL AND ocupacao_covid_uti IS NOT NULL)
	OR (ocupacao_covid_cli = 0 AND (ocupacao_suspeito_cli > 0 OR ocupacao_confirmado_cli > 0))
	OR (ocupacao_covid_cli IS NULL AND (ocupacao_suspeito_cli IS NOT NULL OR ocupacao_confirmado_cli IS NOT NULL))
	OR (ocupacao_covid_uti = 0 AND (ocupacao_suspeito_uti > 0 OR ocupacao_confirmado_uti > 0))
	OR (ocupacao_covid_uti IS NULL AND (ocupacao_suspeito_uti IS NOT NULL OR ocupacao_confirmado_uti IS NOT NULL));

-- Como cerca de 62% dos registros para as colunas
-- ocupacao_suspeito_uti, ocupacao_confirmado_uti, ocupacao_suspeito_cli, ocupacao_confirmado_cli
-- apresentam inconsistencias, decidimos por nao utiliza-las nas analises.
-- Ademais, como menos de 1% dos registros para as colunas ocupacao_covid_cli e ocupacao_covid_uti
-- sao inconsistentes, entao criaremos uma visualizacao que filtre os valores consistentes das colunas
-- ocupacao_covid_cli e ocupacao_covid_uti
DROP VIEW IF EXISTS registro_ocupacao_05_colunas_calculdas_filtradas;
DROP VIEW IF EXISTS registro_ocupacao_04_sem_duplicatas;
DROP VIEW IF EXISTS registro_ocupacao_03_dados_limpos;
CREATE OR REPLACE VIEW registro_ocupacao_03_dados_limpos AS
	SELECT
		_id, data_notificacao, criado_em, atualizado_em,
		id_hospital, id_local, id_status,
		ocupacao_covid_cli, ocupacao_covid_uti,
		ocupacao_hospitalar_cli, ocupacao_hospitalar_uti,
		saida_suspeita_obitos, saida_suspeita_altas,
		saida_confirmada_obitos, saida_confirmada_altas
	FROM registro_ocupacao_02_sem_decimais
	EXCEPT
	SELECT
		_id, data_notificacao, criado_em, atualizado_em,
		id_hospital, id_local, id_status,
		ocupacao_covid_cli, ocupacao_covid_uti,
		ocupacao_hospitalar_cli, ocupacao_hospitalar_uti,
		saida_suspeita_obitos, saida_suspeita_altas,
		saida_confirmada_obitos, saida_confirmada_altas
	FROM registro_ocupacao_02_sem_decimais
	WHERE (ocupacao_hospitalar_cli = 0 AND ocupacao_covid_cli > 0)
		OR (ocupacao_hospitalar_cli IS NULL AND ocupacao_covid_cli IS NOT NULL)
		OR (ocupacao_hospitalar_uti = 0 AND ocupacao_covid_uti > 0)
		OR (ocupacao_hospitalar_uti IS NULL AND ocupacao_covid_uti IS NOT NULL);

-- Quantidade de registros que respeitam a logica
SELECT COUNT(*) FROM registro_ocupacao_03_dados_limpos;