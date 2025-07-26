CREATE OR REPLACE PROCEDURE `data_quality.prc_load_tb_log_error`
(
    VAR_PRJ         STRING,
    VAR_DATASET     STRING,
    VAR_TABELA      STRING,
    ERROR_MSG       STRING
)
BEGIN
  -- TRY/CATCH para captura de erro
  BEGIN
    -- STEP 1: INSERE OS DADOS NA TABELA DE LOG DE ERROS
    EXECUTE IMMEDIATE """
        INSERT INTO `data-ops-466417.data_quality.tb_log_error`
        SELECT 
             '""" || VAR_PRJ || """'      AS projeto
            ,'""" || VAR_DATASET || """'  AS dataset
            ,'""" || VAR_TABELA || """'   AS table_name
            ,'""" || ERROR_MSG || """'    AS error_mensage
            ,CURRENT_DATETIME('-03:00')   AS dt_insercao_registro
    """;

  END;
END;
