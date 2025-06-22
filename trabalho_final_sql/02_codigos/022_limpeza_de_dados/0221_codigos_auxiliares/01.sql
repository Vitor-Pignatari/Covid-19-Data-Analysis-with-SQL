-- Verifica as seguintes informacoes de registros de ocupacao de leito com status envio excluido:
	-- quantidade total de registros ocupacao
	-- percentual relativo
SELECT
	COUNT(ro.*) AS total_count,
	(SUM(CASE WHEN se.excluido = true THEN 1 ELSE 0 END))::FLOAT AS excluido_count,
	ROUND(SUM(CASE WHEN se.excluido = true THEN 1 ELSE 0 END)::DECIMAL / COUNT(ro.*), 4) AS excluido_percentual
FROM registro_ocupacao ro
LEFT JOIN status_envio se
	ON ro.id_status = se.id_status;

-- Cria uma visualizacao com todos os registros nao excluidos
DROP VIEW IF EXISTS registro_ocupacao_05_colunas_calculdas_filtradas;
DROP VIEW IF EXISTS registro_ocupacao_04_sem_duplicatas;
DROP VIEW IF EXISTS registro_ocupacao_03_dados_limpos;
DROP VIEW IF EXISTS registro_ocupacao_02_sem_decimais;
DROP VIEW IF EXISTS registro_ocupacao_01_nao_excluido;
CREATE OR REPLACE VIEW registro_ocupacao_01_nao_excluido AS
	SELECT ro.*
	FROM registro_ocupacao ro
	LEFT JOIN status_envio se
		ON ro.id_status = se.id_status
	WHERE excluido = false;

-- Valida a quantidade de registros nao excluidos
SELECT COUNT(*) FROM registro_ocupacao_01_nao_excluido;