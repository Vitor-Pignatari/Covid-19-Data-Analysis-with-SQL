-- 05: Evolucao das altas vs. obitos
WITH truncado AS (
  SELECT 
    DATE_TRUNC('day', data_notificacao) AS dia,
    DATE_TRUNC('month', data_notificacao) AS mes,
    DATE_TRUNC('year', data_notificacao) AS ano,
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
  ORDER BY dia
),
axo_mes AS (
  SELECT 
    mes,
    SUM(obitos) AS obitos,
    SUM(altas) AS altas
  FROM truncado
  GROUP BY mes
  ORDER BY mes
),
axo_ano AS (
  SELECT 
    ano,
    SUM(obitos) AS obitos,
    SUM(altas) AS altas
  FROM truncado
  GROUP BY ano
  ORDER BY ano
)

SELECT * FROM axo_mes;