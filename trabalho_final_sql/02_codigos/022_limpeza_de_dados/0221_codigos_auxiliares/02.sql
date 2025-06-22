-- Conta a quantidade de registros que possuem valores decimais preenchidos
SELECT COUNT(*)
FROM registro_ocupacao_01_nao_excluido
WHERE ocupacao_covid_cli % 1 != 0
	OR ocupacao_covid_uti % 1 != 0
	OR ocupacao_hospitalar_cli % 1 != 0
	OR ocupacao_hospitalar_uti % 1 != 0
	OR saida_suspeita_obitos % 1 != 0
	OR saida_suspeita_altas % 1 != 0
	OR saida_confirmada_obitos % 1 != 0
	OR saida_confirmada_altas % 1 != 0
	OR ocupacao_suspeito_cli % 1 != 0
	OR ocupacao_confirmado_cli % 1 != 0
	OR ocupacao_suspeito_uti % 1 != 0
	OR ocupacao_confirmado_uti % 1 != 0;

-- Filtra a tabela para pegar apenas valores absolutos
DROP VIEW IF EXISTS registro_ocupacao_05_colunas_calculdas_filtradas;
DROP VIEW IF EXISTS registro_ocupacao_04_sem_duplicatas;
DROP VIEW IF EXISTS registro_ocupacao_03_dados_limpos;
DROP VIEW IF EXISTS registro_ocupacao_02_sem_decimais;
CREATE OR REPLACE VIEW registro_ocupacao_02_sem_decimais AS
	SELECT * FROM registro_ocupacao_01_nao_excluido
	EXCEPT
	SELECT * FROM registro_ocupacao_01_nao_excluido
	WHERE ocupacao_covid_cli % 1 != 0
		OR ocupacao_covid_uti % 1 != 0
		OR ocupacao_hospitalar_cli % 1 != 0
		OR ocupacao_hospitalar_uti % 1 != 0
		OR saida_suspeita_obitos % 1 != 0
		OR saida_suspeita_altas % 1 != 0
		OR saida_confirmada_obitos % 1 != 0
		OR saida_confirmada_altas % 1 != 0
		OR ocupacao_suspeito_cli % 1 != 0
		OR ocupacao_confirmado_cli % 1 != 0
		OR ocupacao_suspeito_uti % 1 != 0
		OR ocupacao_confirmado_uti % 1 != 0;

-- Valida que nao temos mais valores decimais
SELECT COUNT(*)
FROM registro_ocupacao_02_sem_decimais
WHERE ocupacao_covid_cli % 1 != 0
	OR ocupacao_covid_uti % 1 != 0
	OR ocupacao_hospitalar_cli % 1 != 0
	OR ocupacao_hospitalar_uti % 1 != 0
	OR saida_suspeita_obitos % 1 != 0
	OR saida_suspeita_altas % 1 != 0
	OR saida_confirmada_obitos % 1 != 0
	OR saida_confirmada_altas % 1 != 0
	OR ocupacao_suspeito_cli % 1 != 0
	OR ocupacao_confirmado_cli % 1 != 0
	OR ocupacao_suspeito_uti % 1 != 0
	OR ocupacao_confirmado_uti % 1 != 0;

-- Quantidade de registros sem decimais
SELECT COUNT(*) FROM registro_ocupacao_02_sem_decimais;