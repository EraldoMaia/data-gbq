CREATE TABLE IF NOT EXISTS `data_quality.tb_log_exec` (
    projeto              STRING   OPTIONS(description = 'Projeto onde a execução ocorreu.'),
    dataset              STRING   OPTIONS(description = 'Dataset onde a execução ocorreu.'),
    table_name           STRING   OPTIONS(description = 'Tabela processada.'),
    qtd_linhas           INT64    OPTIONS(description = 'Quantidade de linhas inseridas na carga.'),
    dt_insercao_registro DATETIME OPTIONS(description = 'Data de inserção do registro na tabela.')
)
PARTITION BY DATE_TRUNC(dt_insercao_registro, MONTH)
OPTIONS(description = 'Tabela de log de execucao para monitoramento das camadas trusted e refined.');
