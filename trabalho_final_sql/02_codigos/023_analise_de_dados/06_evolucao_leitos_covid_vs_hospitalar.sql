-- 6 Evolução da razão entre leitos ocupados por pacientes com COVID e o total de leitos ocupados.
WITH p_ocup AS (
  SELECT 
    data_notificacao,
    id_hospital,
	CASE
  	WHEN ocupacao_hospitalar > 0 THEN (ocupacao_covid / ocupacao_hospitalar)
  	ELSE NULL
	END AS p_ocup_covid
	FROM registro_ocupacao_final
)
SELECT * FROM p_ocup
ORDER BY id_hospital, data_notificacao;