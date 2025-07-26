CREATE OR REPLACE PROCEDURE `procs.prc_load_tb_top10_line_products`
(
    VAR_PRJ_TRUSTED STRING,
    VAR_PRJ_REFINED STRING,
    VAR_TABELA      STRING,
    VAR_DATASET     STRING
)
BEGIN
  -- TRY/CATCH para captura de erro
  BEGIN
    -- STEP 1: CRIA A TABELA TEMPORÁRIA tmp_line_products_agg
    -- ESSA TABELA É CRIADA PARA AGREGAR OS DADOS LINHA DE PRODUTO POR ANO E MES 
    EXECUTE IMMEDIATE """
        CREATE TEMP TABLE tmp_line_products_agg AS (
            SELECT
                 linha_produto                      AS linha_produto
                ,EXTRACT(YEAR  FROM dt_pedido)      AS ano_pedido
                ,EXTRACT(MONTH FROM dt_pedido)      AS mes_pedido
                ,ROUND(SUM(valor_total_vendido),2)  AS valor_total_vendido
            FROM `""" || VAR_PRJ_TRUSTED || """.""" || VAR_DATASET || """.tb_sample_sales`
            GROUP BY ALL
        )
    """;

    -- STEP 2: CRIA A TABELA TEMPORÁRIA tmp_tb_top10_line_products
    -- ESSA TABELA É CRIADA PARA FILTRAR OS DADOS DAS 10 LINHAS DE PRODUTOS MAIS VENDIDOS POR ANO E MES
    -- UTILIZAMOS ROW_NUMBER() PARA RANKING, PARA NAO GERAR EMPATES DE POSICAO
    -- E UTILIZAMOS QUALIFY PARA FILTRAR OS 10 PRIMEIROS RESULTADOS DE CADA CONTEXTO (ANO E MES)
    EXECUTE IMMEDIATE """
        CREATE TEMP TABLE tmp_tb_top10_line_products AS (
            SELECT
                *,
                ROW_NUMBER() OVER (
                                    PARTITION BY ano_pedido, mes_pedido
                                    ORDER BY valor_total_vendido DESC
                                ) AS posicao_rank
            FROM tmp_line_products_agg
            QUALIFY posicao_rank <= 10
        )
    """;

    -- STEP 3: TRUNCA A TABELA FINAL
    EXECUTE IMMEDIATE """
        TRUNCATE TABLE `""" || VAR_PRJ_REFINED || """.""" || VAR_DATASET || """.""" || VAR_TABELA || """`
    """;

    -- STEP 4: INSERE OS DADOS
    EXECUTE IMMEDIATE """
        INSERT INTO `""" || VAR_PRJ_REFINED || """.""" || VAR_DATASET || """.""" || VAR_TABELA || """`
        SELECT 
             *,
             CURRENT_DATETIME('-03:00') AS dt_insercao_registro
        FROM tmp_tb_top10_line_products
        ORDER BY
                ano_pedido   DESC
               ,mes_pedido   ASC
               ,posicao_rank ASC
    """;

  END;
END;
