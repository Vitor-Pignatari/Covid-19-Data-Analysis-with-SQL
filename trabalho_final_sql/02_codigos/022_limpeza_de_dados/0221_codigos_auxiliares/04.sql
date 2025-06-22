-- Confere a quantidade de registros duplicados por id_hospital e data_notificacao
SELECT id_hospital, data_notificacao, COUNT(*)
FROM registro_ocupacao_03_dados_limpos
GROUP BY id_hospital, data_notificacao
ORDER BY 3 DESC;

-- Cria visualizacao sem registros duplicados de notificacao
-- Obtem a data notificacao com a data de atualizacao mais recente
DROP VIEW IF EXISTS registro_ocupacao_05_colunas_calculdas_filtradas;
DROP VIEW IF EXISTS registro_ocupacao_04_sem_duplicatas;
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

-- Confere a quantidade de registros duplicados por id_hospital e data_notificacao
SELECT id_hospital, data_notificacao, COUNT(*)
FROM registro_ocupacao_04_sem_duplicatas
GROUP BY id_hospital, data_notificacao
ORDER BY 3 DESC;

-- Quantidade de registros com e sem as duplicatas
SELECT 'com' AS duplicados, COUNT(*) FROM registro_ocupacao_03_dados_limpos
UNION ALL
SELECT 'sem' AS duplicados, COUNT(*) FROM registro_ocupacao_04_sem_duplicatas;