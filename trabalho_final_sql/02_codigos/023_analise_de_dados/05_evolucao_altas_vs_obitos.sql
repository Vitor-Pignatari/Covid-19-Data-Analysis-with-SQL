-- 05.1: Evolucao das altas vs. obitos
WITH truncado AS (
  SELECT 
    DATE(DATE_TRUNC('day', data_notificacao)) AS dia,
    DATE(DATE_TRUNC('month', data_notificacao)) AS mes,
    DATE(DATE_TRUNC('quarter', data_notificacao)) AS trimestre,
    DATE(DATE_TRUNC('year', data_notificacao)) AS ano,
    saida_covid_obitos AS obitos,
    saida_covid_altas AS altas
  FROM registro_ocupacao_final
),
axo_dia AS (
  SELECT 
    dia,
    SUM(obitos) AS obitos,
    SUM(altas) AS altas
  FROM truncado
  GROUP BY dia
  ORDER BY dia DESC
),
axo_mes AS (
  SELECT 
    mes,
    SUM(obitos) AS obitos,
    SUM(altas) AS altas
  FROM truncado
  GROUP BY mes
  ORDER BY mes DESC
),
axo_trimestre AS (
  SELECT 
    trimestre,
    SUM(obitos) AS obitos,
    SUM(altas) AS altas
  FROM truncado
  GROUP BY trimestre
  ORDER BY trimestre DESC
),
axo_ano AS (
  SELECT 
    ano,
    SUM(obitos) AS obitos,
    SUM(altas) AS altas
  FROM truncado
  GROUP BY ano
  ORDER BY ano DESC
)

SELECT * FROM axo_trimestre;