CREATE TABLE IF NOT EXISTS `data_quality.tb_log_error` (
  projeto              STRING   OPTIONS(description = 'Projeto onde o erro ocorreu.'),
  dataset              STRING   OPTIONS(description = 'Dataset onde o erro ocorreu.'),
  table_name           STRING   OPTIONS(description = 'Tabela onde o erro ocorreu.'),
  error_mensage        STRING   OPTIONS(description = 'Mensagem de erro detalhada.'),
  dt_insercao_registro DATETIME OPTIONS(description = 'Data de inserção do registro na tabela.'),

)
PARTITION BY DATE_TRUNC(dt_insercao_registro, MONTH)
OPTIONS(description = 'Tabela de log de erros para monitoramento e depuração das camadas trusted e refined.');
