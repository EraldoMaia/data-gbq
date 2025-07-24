CREATE TABLE IF NOT EXISTS `trusted-zone-466913.kaggle.tb_sample_sales` (
  num_pedido                        INT64,
  qtd_pedido                        INT64,
  valor_unidade_pedido              FLOAT64,
  num_linha_pedido                  INT64,
  valor_total_vendido               FLOAT64,
  dt_pedido                         DATE,
  status_pedido                     STRING,
  num_trimestre                     INT64,
  num_mes                           INT64,
  num_ano                           INT64,
  linha_produto                     STRING,
  valor_preco_sugerido_fabricante   FLOAT64,
  cod_produto                       INT64,
  nome_cliente                      STRING,
  num_telefone_cliente              INT64,
  nome_endereco_1_cliente           STRING,
  nome_endereco_2_cliente           STRING,
  nome_cidade_cliente               STRING,
  nome_estado_cliente               STRING,
  num_cep_cliente                   STRING,
  nome_pais_cliente                 STRING,
  nome_uf                           STRING,
  nome_primeiro_nome_cleinte        STRING,
  nome_sobrenome_cleinte            STRING,
  volume_vendas                     STRING,
  dt_insercao_registro              DATETIME,

  PRIMARY KEY (num_trimestre, num_mes, num_ano) NOT ENFORCED
)
PARTITION BY DATE_TRUNC(dt_pedido, MONTH)
OPTIONS (description = 'Tabela de amostra de vendas do Kaggle.');