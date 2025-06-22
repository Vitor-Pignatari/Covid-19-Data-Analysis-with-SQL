DROP VIEW IF EXISTS registro_ocupacao_final CASCADE;

-- 01: Remove registros com status excluidos
CREATE OR REPLACE VIEW registro_ocupacao_01_nao_excluido AS
	SELECT ro.*
	FROM registro_ocupacao ro
	LEFT JOIN status_envio se
		ON ro.id_status = se.id_status
	WHERE excluido = false;

-- 02: Remove valores decimais
CREATE OR REPLACE VIEW registro_ocupacao_02_sem_decimais AS
	SELECT * FROM registro_ocupacao_01_nao_excluido
	EXCEPT
	SELECT * FROM registro_ocupacao_01_nao_excluido
	WHERE ocupacao_covid_cli % 1 != 0
		OR ocupacao_covid_uti % 1 != 0
		OR ocupacao_hospitalar_cli % 1 != 0
		OR ocupacao_hospitalar_uti % 1 != 0
		OR saida_suspeita_obitos % 1 != 0
		OR saida_suspeita_altas % 1 != 0
		OR saida_confirmada_obitos % 1 != 0
		OR saida_confirmada_altas % 1 != 0
		OR ocupacao_suspeito_cli % 1 != 0
		OR ocupacao_confirmado_cli % 1 != 0
		OR ocupacao_suspeito_uti % 1 != 0
		OR ocupacao_confirmado_uti % 1 != 0;

-- 03: valida regras de acordo com interpretacao do dicionario de dados
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

-- 04: Remove notificacoes duplicadas, trazendo aquelas com data de atualizacao mais recente
CREATE OR REPLACE VIEW registro_ocupacao_04_sem_duplicatas AS
WITH ranked AS (
	SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY data_notificacao, id_hospital 
			ORDER BY atualizado_em DESC, criado_em DESC, _id DESC
		) AS rn
	FROM registro_ocupacao_03_dados_limpos
)
SELECT
	_id, id_hospital, data_notificacao, id_local, id_status,
	ocupacao_covid_cli, ocupacao_covid_uti,
	ocupacao_hospitalar_cli, ocupacao_hospitalar_uti,
	saida_suspeita_obitos, saida_suspeita_altas,
	saida_confirmada_obitos, saida_confirmada_altas
FROM ranked
WHERE rn = 1;

-- 05: Cria colunas calculadas saida_obitos, saida_altas, saida_covid, saida_covid_calculada e entrada_covid_calculada
CREATE OR REPLACE VIEW registro_ocupacao_05_colunas_calculadas_filtradas AS
	WITH com_colunas_calculdas AS(
		SELECT
			_id, id_hospital, data_notificacao, id_local, id_status,
			(ocupacao_covid_cli + ocupacao_covid_uti) AS ocupacao_covid,
			(ocupacao_hospitalar_cli + ocupacao_hospitalar_uti) AS ocupacao_hospitalar,
			(COALESCE(saida_suspeita_obitos, 0) + COALESCE(saida_confirmada_obitos, 0)) AS saida_covid_obitos,
			(COALESCE(saida_suspeita_altas, 0) + COALESCE(saida_confirmada_altas, 0)) AS saida_covid_altas,
			(COALESCE(saida_suspeita_obitos, 0) + COALESCE(saida_confirmada_obitos, 0) + COALESCE(saida_suspeita_altas, 0) + COALESCE(saida_confirmada_altas, 0)) AS saida_covid
		FROM registro_ocupacao_04_sem_duplicatas),
		
	com_colunas_calculadas2 AS(
		SELECT *,
			( ocupacao_covid - COALESCE((LAG(ocupacao_covid) OVER(ORDER BY id_hospital, data_notificacao)), 0) + saida_covid ) AS entrada_covid_calculada
		FROM com_colunas_calculdas)
		
	SELECT
		_id, id_hospital, data_notificacao, id_local, id_status,
		ocupacao_covid, ocupacao_hospitalar, saida_covid_obitos, saida_covid_altas,
		CASE WHEN entrada_covid_calculada < 0
				THEN saida_covid + (-1) * entrada_covid_calculada
			ELSE saida_covid
		END AS saida_covid_calculada,
		CASE 
			WHEN entrada_covid_calculada < 0 THEN 0
			ELSE entrada_covid_calculada
		END AS entrada_covid_calculada
	FROM com_colunas_calculadas2;

-- 06: Cria série temporal
CREATE OR REPLACE VIEW registro_ocupacao_06_serie_temporal AS
	WITH calendario AS(
		SELECT GENERATE_SERIES(MIN(data_notificacao), MAX(data_notificacao), '1 day') AS data_notificacao
		FROM registro_ocupacao_05_colunas_calculadas_filtradas),
		
	combinacoes_hospital_local_status AS(
		SELECT DISTINCT id_hospital, id_local, id_status
		FROM registro_ocupacao_05_colunas_calculadas_filtradas
	),

	serie_temporal AS (
		SELECT
			cal.data_notificacao AS data_notificacao,
			hls.id_hospital,
			hls.id_local,
			hls.id_status
		FROM calendario cal
		CROSS JOIN combinacoes_hospital_local_status hls
		ORDER BY 2, 3, 4, 1
	)

	SELECT
		st.data_notificacao AS data_notificacao,
		st.id_hospital,
		st.id_local,
		st.id_status,
		ro.ocupacao_covid,
		ro.ocupacao_hospitalar,
		ro.saida_covid_obitos,
		ro.saida_covid_altas,
		ro.saida_covid_calculada,
		ro.entrada_covid_calculada
	FROM serie_temporal st
	LEFT JOIN registro_ocupacao_05_colunas_calculadas_filtradas ro
		ON st.id_hospital = ro.id_hospital
		AND st.id_local = ro.id_local
		AND st.id_status = ro.id_status
		AND DATE(st.data_notificacao) = DATE(ro.data_notificacao)
	ORDER BY st.id_hospital, st.id_local, st.id_status, st.data_notificacao;

-- 07: Executa 'Last Observation Carried Forward (LOCF)' para tratamento de  valores nulos em séries temporais
CREATE OR REPLACE VIEW registro_ocupacao_07_LOCF AS
	SELECT
		data_notificacao,
		id_hospital,
		id_local,
		id_status,
		CASE
			WHEN ocupacao_covid IS NULL
				THEN LAG(ocupacao_covid) OVER (PARTITION BY id_hospital, id_local, id_status ORDER BY data_notificacao)
			ELSE ocupacao_covid
		END AS ocupacao_covid,
		CASE
			WHEN ocupacao_hospitalar IS NULL
				THEN LAG(ocupacao_hospitalar) OVER (PARTITION BY id_hospital, id_local, id_status ORDER BY data_notificacao)
			ELSE ocupacao_hospitalar
		END AS ocupacao_hospitalar,
		COALESCE(saida_covid_obitos, 0) AS saida_covid_obitos,
		COALESCE(saida_covid_altas, 0) AS saida_covid_altas,
		COALESCE(saida_covid_calculada, 0) AS saida_covid_calculada,
		COALESCE(entrada_covid_calculada, 0) AS entrada_covid_calculada
	FROM registro_ocupacao_06_serie_temporal;

-- 08: Cria tabela final com dados prontos para analise
CREATE OR REPLACE VIEW registro_ocupacao_final AS
	SELECT * FROM registro_ocupacao_07_LOCF
	ORDER BY id_hospital, data_notificacao, id_local, id_status;