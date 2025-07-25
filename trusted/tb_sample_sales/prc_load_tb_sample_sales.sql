CREATE OR REPLACE PROCEDURE `procs.prc_load_tb_sample_sales`
(
    VAR_PRJ_RAW     STRING,
    VAR_PRJ_TRUSTED STRING,
    VAR_TABELA      STRING,
    VAR_DATASET     STRING
)
BEGIN
  DECLARE ERROR_MSG STRING;
  DECLARE QTD_LINHAS INT64 DEFAULT 0;

  BEGIN
  -- TRY/CATCH para captura de erro
  BEGIN
    -- STEP 1: CRIA A TABELA TEMPORÁRIA tmp_tb_sample_sales
    EXECUTE IMMEDIATE """
        CREATE TEMP TABLE tmp_tb_sample_sales AS (
            SELECT
                 CAST(ordernumber               AS INT64)    AS num_pedido 
                ,CAST(quantityordered           AS INT64)    AS qtd_pedido 
                ,CAST(priceeach                 AS FLOAT64)  AS valor_unidade_pedido 
                ,CAST(orderlinenumber           AS INT64)    AS num_linha_pedido 
                ,CAST(sales                     AS FLOAT64)  AS valor_total_vendido 
                ,PARSE_DATE('%m/%e/%Y', 
                            SPLIT(orderdate, ' ')[OFFSET(0)])  AS dt_pedido 
                ,CASE 
                    WHEN UPPER(status) = 'CANCELLED'  THEN 'CANCELADO'
                    WHEN UPPER(status) = 'DISPUTED'   THEN 'DISPUTADO'
                    WHEN UPPER(status) = 'IN PROCESS' THEN 'EM PROCESSO'
                    WHEN UPPER(status) = 'ON HOLD'    THEN 'EM ESPERA'
                    WHEN UPPER(status) = 'PENDING'    THEN 'PENDENTE'
                    WHEN UPPER(status) = 'RESOLVED'   THEN 'RESOLVIDO'
                    WHEN UPPER(status) = 'SHIPPED'    THEN 'ENVIADO'
                    ELSE UPPER(status)               
                 END                                         AS status_pedido 
                ,CAST(qtr_id                    AS INT64)    AS num_trimestre 
                ,CAST(month_id                  AS INT64)    AS num_mes 
                ,CAST(year_id                   AS INT64)    AS num_ano 
                ,CASE
                    WHEN UPPER(productline) = 'MOTORCYCLES'      THEN 'MOTOCICLETAS'
                    WHEN UPPER(productline) = 'VINTAGE CARS'     THEN 'CARROS ANTIGOS'
                    WHEN UPPER(productline) = 'CLASSIC CARS'     THEN 'CARROS CLASSICOS'
                    WHEN UPPER(productline) = 'TRUCKS AND BUSES' THEN 'CAMINHÕES E ÔNIBUS'
                    WHEN UPPER(productline) = 'TRAINS'           THEN 'TRENS'
                    WHEN UPPER(productline) = 'SHIPS'            THEN 'NAVIOS'
                    WHEN UPPER(productline) = 'PLANES'           THEN 'AVIÕES'
                    ELSE UPPER(productline)
                 END                                         AS linha_produto 
                ,CAST(msrp                      AS FLOAT64)  AS valor_preco_sugerido_fabricante 
                ,CAST(REGEXP_REPLACE(productcode, r"[^0-9]", '' ) AS INT64) AS cod_produto 
                ,INITCAP(customername)                       AS nome_cliente 
                ,CAST(REGEXP_REPLACE(phone, r"[^0-9]", '' )  AS INT64) AS num_telefone_cliente 
                ,CASE 
                    WHEN LOWER(addressline1) = '' THEN 'NAO INFORMADO'
                    ELSE LOWER(addressline1)
                 END                                         AS nome_endereco_1_cliente 
                ,CASE 
                    WHEN LOWER(addressline2) = '' THEN 'NAO INFORMADO'
                    ELSE LOWER(addressline2)
                 END                                         AS nome_endereco_2_cliente 
                ,CASE 
                    WHEN LOWER(city) = '' THEN 'NAO INFORMADO'
                    ELSE LOWER(city)
                 END                                         AS nome_cidade_cliente 
                ,CASE 
                    WHEN LOWER(state) = '' THEN 'NAO INFORMADO'
                    ELSE LOWER(state)
                 END                                         AS nome_estado_cliente 
                ,CASE 
                    WHEN LOWER(postalcode) = '' THEN 'NAO INFORMADO'
                    ELSE LOWER(postalcode)
                 END                                         AS num_cep_cliente 
                ,LOWER(country)                              AS nome_pais_cliente 
                ,CASE
                    WHEN UPPER(territory) = 'NA' THEN 'NAO INFORMADO'      
                    ELSE UPPER(territory)                
                 END                                         AS nome_uf 
                ,INITCAP(contactlastname)                    AS nome_primeiro_nome_cliente 
                ,INITCAP(contactfirstname)                   AS nome_sobrenome_cliente 
                ,CASE
                    WHEN UPPER(dealsize) = 'SMALL'  THEN 'PEQUENO'
                    WHEN UPPER(dealsize) = 'MEDIUM' THEN 'MEDIO'
                    WHEN UPPER(dealsize) = 'LARGE'  THEN 'GRANDE'
                    ELSE 'NAO INFORMADO'
                 END                                         AS volume_vendas 
                ,CURRENT_DATETIME('-03:00')                  AS dt_insercao_registro
            FROM `""" || VAR_PRJ_RAW || """.""" || VAR_DATASET || """.sample_sales`
        )
    """;

    -- STEP 2: TRUNCA A TABELA FINAL
    EXECUTE IMMEDIATE """
        TRUNCATE TABLE `""" || VAR_PRJ_TRUSTED || """.""" || VAR_DATASET || """.""" || VAR_TABELA || """`
    """;

    -- STEP 3: INSERE OS DADOS
    EXECUTE IMMEDIATE """
        INSERT INTO `""" || VAR_PRJ_TRUSTED || """.""" || VAR_DATASET || """.""" || VAR_TABELA || """`
        SELECT * FROM tmp_tb_sample_sales
    """;

    -- STEP 4: ATRIBUI A QUANTIDADE DE LINHAS INSERIDAS A VARIAVEL QTD_LINHAS-- STEP 5: ATRIBUI A QUANTIDADE DE LINHAS INSERIDAS A VARIAVEL QTD_LINHAS
    EXECUTE IMMEDIATE """
        SELECT 
             COUNT(*) AS qtd_linhas
        FROM tmp_tb_sample_sales
    """ INTO QTD_LINHAS;

    -- STEP 5: CHAMA A PROCEDURE DE LOG DE ERROS
      CALL `data-ops-466417.data_quality.prc_load_tb_log_exec`(
          VAR_PRJ_TRUSTED,  -- Projeto de destino do log
          VAR_DATASET,      -- Dataset onde o log será inserido
          VAR_TABELA,       -- Nome da tabela processada
          QTD_LINHAS        -- Quantidade de linhas inseridas
      );

     EXCEPTION WHEN ERROR THEN
      -- CAPTURA O ERRO NO BLOCO PRINCIPAL
      SET ERROR_MSG = @@error.message;

      -- STEP 6: CHAMA A PROCEDURE DE LOG DE ERROS
      CALL `data-ops-466417.data_quality.prc_load_tb_log_error`(
          VAR_PRJ_TRUSTED,      -- Projeto de destino do log
          VAR_DATASET,          -- Dataset onde o log será inserido
          VAR_TABELA,           -- Nome da tabela processada
          ERROR_MSG             -- Mensagem do erro
      );

      -- RELANÇA O ERRO PARA O AIRFLOW 
      RAISE USING MESSAGE = CONCAT("Erro no carregamento da tabela: ", ERROR_MSG);
    END;

  END;
END;
