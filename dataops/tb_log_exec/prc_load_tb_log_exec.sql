CREATE OR REPLACE PROCEDURE `data_quality.prc_load_tb_log_exec`
(
    VAR_PRJ         STRING,
    VAR_DATASET     STRING,
    VAR_TABELA      STRING,
    QTD_LINHAS      INT64
)
BEGIN
  -- TRY/CATCH para captura de erro
  BEGIN
    -- STEP 1: INSERE OS DADOS NA TABELA DE LOG DE ERROS
    EXECUTE IMMEDIATE """
        INSERT INTO `data-ops-466417.data_quality.tb_log_exec`
        SELECT 
             '""" || VAR_PRJ || """'      AS projeto
            ,'""" || VAR_DATASET || """'  AS dataset
            ,'""" || VAR_TABELA || """'   AS table_name
            ,""" || QTD_LINHAS || """     AS qtd_linhas
            ,CURRENT_DATETIME('-03:00')   AS dt_insercao_registro
    """;

  END;
END;
