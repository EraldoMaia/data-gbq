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


Para poder usar a intragracao entre os projetos é necessario fornecer os acessos (`roles/bigquery.jobUser` e `roles/bigquery.dataEditor`) ao GBQ a conta de servico (`cloud-build-sa`, `cloud-composer-sa` e `cloud-function-sa`) dentro do projeto especifico.

```
gcloud config set project refined-zone-467112

gcloud projects add-iam-policy-binding refined-zone-467112 \
  --member="serviceAccount:cloud-function-sa@data-ops-466417.iam.gserviceaccount.com" \
  --role="roles/bigquery.jobUser"

gcloud projects add-iam-policy-binding refined-zone-467112 \
  --member="serviceAccount:cloud-function-sa@data-ops-466417.iam.gserviceaccount.com" \
  --role="roles/bigquery.dataEditor"
```
