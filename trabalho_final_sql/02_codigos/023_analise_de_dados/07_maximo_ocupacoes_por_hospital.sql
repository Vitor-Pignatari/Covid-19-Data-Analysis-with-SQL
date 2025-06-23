-- 7 Máximo de ocupações por hospital
WITH ocup_max AS (
  SELECT 
    id_hospital,
    MAX(ocupacao_covid) AS ocup_c,
    MAX(ocupacao_hospitalar) AS ocup_h,
    MAX(saida_covid_obitos) AS saida_c_obitos,
    MAX(saida_covid_altas) AS saida_c_altas
  FROM registro_ocupacao_final
  GROUP BY id_hospital
)

SELECT * FROM ocup_max
WHERE ocup_c IS NOT NULL AND ocup_h IS NOT NULL
ORDER BY ocup_h DESC, id_hospital;