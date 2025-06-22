-- Gera série temporal para cada hospital
DROP VIEW IF EXISTS registro_ocupacao_07_LOCF;
DROP VIEW IF EXISTS registro_ocupacao_06_serie_temporal;
CREATE OR REPLACE VIEW registro_ocupacao_06_serie_temporal AS
	WITH calendario AS(
		SELECT GENERATE_SERIES(MIN(DATE(data_notificacao)), MAX(DATE(data_notificacao)), '1 day') AS data_notificacao
		FROM registro_ocupacao_05_colunas_calculadas_filtradas),
		
	combinacoes_hospital_local_status AS(
		SELECT DISTINCT id_hospital, id_local, id_status
		FROM registro_ocupacao_05_colunas_calculadas_filtradas
	),

	serie_temporal AS (
		SELECT
			DATE(cal.data_notificacao) AS data_notificacao,
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

-- Quantidade de linhas da série temporal
SELECT COUNT(*) FROM registro_ocupacao_06_serie_temporal; -- Deve ser 5441 * (365 + 365 + 366)

-- Verifica a tabela resultante para um id_hospital
SELECT * FROM registro_ocupacao_06_serie_temporal
ORDER BY id_hospital, data_notificacao
LIMIT 1096;