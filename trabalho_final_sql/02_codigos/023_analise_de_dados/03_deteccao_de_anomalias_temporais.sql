-- 03.0: Detecção de Anomalias Temporais

WITH estat AS (
  SELECT
    id_hospital,
    AVG(ocupacao_covid) AS med_c,
    AVG(ocupacao_hospitalar) AS med_h,
    STDDEV_POP(ocupacao_covid) AS sd_c,
    STDDEV_POP(ocupacao_hospitalar) AS sd_h
  FROM registro_ocupacao_final
  GROUP BY id_hospital
)

SELECT * FROM estat;

-- Usando PARTITION BY

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
WHERE ocupacao_covid > 3 * sd_c 
   OR ocupacao_hospitalar > 3 * sd_h;