-- Cria colunas calculadas saida_obitos, saida_altas, saida_covid, entrada_covid_calculada
DROP VIEW IF EXISTS registro_ocupacao_05_colunas_calculadas_filtradas;
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

-- Quantidade de valores inconsistentes para a coluna entrada_covid_calculada e consequentemente
-- dos valores das colunas ocupacao_covid  e saida_covid. Isso vai me indicar se vale a pena
-- realizar uma nova coluna (saida_covid_calculada) modelando os dados ou decidir por nao utilizar essa info
SELECT
	COUNT(*)::DECIMAL AS inconsistente,
	(SELECT COUNT(*)::DECIMAL FROM registro_ocupacao_05_colunas_calculadas_filtradas) AS total_count,
	ROUND(COUNT(*)::DECIMAL / (SELECT COUNT(*)::DECIMAL FROM registro_ocupacao_05_colunas_calculadas_filtradas), 4) AS inconsistente_percentual
FROM registro_ocupacao_05_colunas_calculadas_filtradas
WHERE entrada_covid_calculada < 0;

SELECT *
FROM registro_ocupacao_05_colunas_calculadas_filtradas
ORDER BY id_hospital, data_notificacao
LIMIT 1000;