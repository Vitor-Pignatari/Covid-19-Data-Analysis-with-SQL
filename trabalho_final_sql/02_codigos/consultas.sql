SELECT * FROM registro_ocupacao_final;

-- Anomalias temporais

WITH estat AS (
SELECT
id_hospital,
avg(ocupacao_covid) AS med_c,
avg(ocupacao_hospitalar) AS med_h,
STDDEV_POP(ocupacao_covid) AS sd_c,
STDDEV_POP(ocupacao_hospitalar) AS sd_h,
FROM registro_ocupacao_final
GROUP BY id_hospital
)

SELECT * FROM estat;

-- Usando partition by

WITH estat AS (
  SELECT
    id_hospital,
    data_notificacao,
    ocupacao_covid,
    ocupacao_hospitalar,
    AVG(ocupacao_covid) OVER (PARTITION BY id_hospital) AS med_c,
    AVG(ocupacao_hospitalar) OVER (PARTITION BY id_hospital) AS med_h,
    STDDEV_POP(ocupacao_covid) OVER (PARTITION BY id_hospital) AS sd_c,
    STDDEV_POP(ocupacao_hospitalar) OVER (PARTITION BY id_hospital) AS sd_h
  FROM registro_ocupacao_final
) 

SELECT 
  id_hospital, 
  data_notificacao,
  ocupacao_covid,
  ocupacao_hospitalar,
  med_c,
  med_h,
  sd_c,
  sd_h
FROM estat
WHERE 
  ocupacao_covid > med_c + 3 * sd_c OR 
  ocupacao_covid < med_c - 3 * sd_c OR
  ocupacao_hospitalar > med_h + 3 * sd_h OR
  ocupacao_hospitalar < med_h - 3 * sd_h

-- Qtde de registros por origem

WITH n_reg AS (
  SELECT id_status,
    COUNT(id_status) AS qtde
  FROM registro_ocupacao
  GROUP BY id_status
),
jun AS (
  SELECT 
    n_reg.id_status,
	n_reg.qtde,
	status_envio.origem
  FROM n_reg
  JOIN status_envio
    ON n_reg.id_status = status_envio.id_status
),
agrupado AS (
  SELECT
    origem,
	SUM(qtde) AS qtde
  FROM jun
  GROUP BY origem
  ORDER BY qtde DESC
)

SELECT * FROM agrupado;

-- Altas x Obitos

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

-- Percentual de ocupação de leitos por dia

SELECT * FROM registro_ocupacao_final

WITH p_ocup AS (
  SELECT 
    data_notificacao,
    id_hospital,
	CASE
	WHEN ocupacao_hospitalar > 0 THEN ocupacao_covid / ocupacao_hospitalar
	ELSE NULL
	END AS p_ocup_covid
	FROM registro_ocupacao_final
)

SELECT * FROM p_ocup


-- Para ver ocupações não nulas:

WITH p_ocup AS (
  SELECT 
    data_notificacao,
    id_hospital,
	CASE
	WHEN ocupacao_hospitalar > 0 THEN ocupacao_covid / ocupacao_hospitalar
	ELSE NULL
	END AS p_ocup_covid
	FROM registro_ocupacao_final
)

SELECT 
  data_notificacao,
  id_hospital,
  p_ocup_covid
FROM p_ocup
WHERE p_ocup_covid IS NOT NULL
ORDER BY id_hospital, data_notificacao

-- Com esta análise, podemos verificar diariamente qual foi o percentual de leitos
-- ocupados por casos de Covid-19





-- máximo de ocupações hospitalares

SELECT 
  id_hospital,
  max(ocupacao_covid) AS ocup_c,
  max(ocupacao_hospitalar) AS ocup_h,
  max(saida_covid_obitos) AS saida_c_obitos,
  max(saida_covid_altas) AS saida_c_altas
FROM registro_ocupacao_final
GROUP BY id_hospital
ORDER BY ocup_h DESC, id_hospital;

-- máximo de ocupações hospitalares retirando valores nulos da ocupação

WITH ocup_max AS (
  SELECT 
    id_hospital,
    max(ocupacao_covid) AS ocup_c,
    max(ocupacao_hospitalar) AS ocup_h,
    max(saida_covid_obitos) AS saida_c_obitos,
    max(saida_covid_altas) AS saida_c_altas
  FROM registro_ocupacao_final
  GROUP BY id_hospital
  ORDER BY ocup_h DESC, id_hospital
)

SELECT * FROM ocup_max
WHERE ocup_c IS NOT NULL AND ocup_c IS NOT NULL