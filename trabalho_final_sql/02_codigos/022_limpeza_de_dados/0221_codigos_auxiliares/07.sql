-- Last observation carried forward (LOCF)
-- Tratamento de valores nulos em datas que nao obtiverem registros de notificacao
-- Se uma ocupacao é nula para uma data, entao preenchemos com o valor da ocupacao
-- da data imediatamente mais recente.
-- Isso porque se o valor de uma data é nulo, entao o estado de ocupacao de leitos
-- nao se alterou
DROP VIEW IF EXISTS registro_ocupacao_final;
DROP VIEW IF EXISTS registro_ocupacao_07_LOCF;
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

SELECT * FROM registro_ocupacao_07_LOCF
ORDER BY id_hospital, data_notificacao
LIMIT 1096;