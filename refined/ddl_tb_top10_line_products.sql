CREATE TABLE IF NOT EXISTS `kaggle.tb_top10_line_products` (
  linha_produto                     STRING   description('Nome da linha do produto.'),
  ano_pedido                        DATE     description('Ano do pedido, extraído da data do pedido.'),
  mes_pedido                        INT64    description('Mês do pedido, extraído da data.'),
  valor_total_vendido               FLOAT64  description('Valor total vendido.'),
  posicao_rank                      INT64    description('Posição do ranking das linhas de produtos mais vendidas por ano e mês.'),
  dt_insercao_registro              DATETIME description('Data de inserção do registro na tabela.'),

  PRIMARY KEY (linha_produto, ano_pedido, mes_pedido) NOT ENFORCED
)
PARTITION BY RANGE_BUCKET(ano_pedido, GENERATE_ARRAY(2000, 2030, 1))
OPTIONS (description = 'Tabela com as 10 principais linhas de produtos mais vendidos por ano e mes.');