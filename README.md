# data-gbq

Repositorio para armazenar os artefatos (DDL e DML) de segunda e terceira camada (trusted e refined)

**Estrutura esperada no Bucket**

```
gs://tf_bigquery_scripts_bucket/
  ├── trusted/
  │    └── tb_name/
  │          ├── ddl_tb_name.sql
  │          └── prc_load_tb_name.sql
  └── refined/
       └──tb_name/
             ├── ddl_tb_name.sql
             └── prc_load_tb_name.sql
```
