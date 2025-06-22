WITH n_reg AS (
  SELECT 
    id_status,
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