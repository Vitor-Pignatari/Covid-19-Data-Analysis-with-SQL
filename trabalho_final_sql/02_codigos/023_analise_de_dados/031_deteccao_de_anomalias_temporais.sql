-- 03.1: Detecção de Anomalias Temporais

WITH obitos_por_data AS(
	SELECT
		DATE_TRUNC('day', data_notificacao) AS data_notificacao,
		SUM(saida_covid_obitos) AS obitos
	FROM registro_ocupacao_final
	GROUP BY 1
	ORDER BY 1
),
base AS (
  SELECT
    data_notificacao,
    obitos,
    
    -- Média móvel dos últimos 30 dias
    AVG(obitos) OVER (
      ORDER BY data_notificacao
      ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS media_movel_obitos,
    
    -- Desvio padrão móvel dos últimos 30 dias
    STDDEV_POP(obitos) OVER (
      ORDER BY data_notificacao
      ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS desvio_movel_obitos
    
  FROM obitos_por_data
),

anomalias AS(
	SELECT
	  data_notificacao,
	  obitos,
	  media_movel_obitos,
	  desvio_movel_obitos,
	  
	  -- Limites dinâmicos
	  media_movel_obitos + 3 * desvio_movel_obitos AS limite_superior,
	  media_movel_obitos - 3 * desvio_movel_obitos AS limite_inferior,

	  -- Z-score
	  (obitos - media_movel_obitos) / NULLIF(desvio_movel_obitos, 0) AS z_score,
	  
	  -- Verificação de anomalias (picos (1), normalidades (0) ou quedas (-1))
	  CASE 
	    WHEN obitos > media_movel_obitos + 3 * desvio_movel_obitos THEN 1
		WHEN obitos < media_movel_obitos - 3 * desvio_movel_obitos THEN -1
	    ELSE 0
	  END AS anomalia
	
	FROM base
	ORDER BY data_notificacao
)
SELECT 
	data_notificacao,
	obitos,
	ROUND(media_movel_obitos, 2) AS media_movel_obitos,
	ROUND(desvio_movel_obitos, 2) AS desvio_movel_obitos,
	ROUND(limite_inferior, 2) AS limite_inferior,
	ROUND(limite_superior, 2) AS limite_superior,
	ROUND(z_score, 2) AS z_score,
	anomalia
FROM anomalias
-- WHERE anomalia = 1 OR anomalia = -1
ORDER BY data_notificacao;