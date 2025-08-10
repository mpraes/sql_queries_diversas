# Repositório de Queries Diversas SQL
Repositório único de Queries SQL para usos diversos no trabalho.

## Organização por Categorias

### 📁 DDL/ (Data Definition Language)
Comandos para definição e modificação de estruturas de banco de dados:
- `alter_table_ids_diversos.sql` - Comandos ALTER TABLE para modificação de tipos de colunas

### 📁 Data_Validation/ (Validação de Dados)
Queries para validação e verificação da qualidade dos dados:
- `consultas_validacoes_fatos_relacionamento_dimensao.sql` - Validações de relacionamentos entre fatos e dimensões
- `queries_verificacoes_diversas.sql` - Verificações gerais de qualidade de dados
- `validacao_idstask_ids_project_etl.sql` - Validação específica de IDs de tarefas e projetos no ETL
- `validacao_valores_discrepantes_duas_tabelas_projetos.sql` - Validação de valores discrepantes entre tabelas de projetos

### 📁 Duplicate_Detection/ (Detecção de Duplicatas)
Queries especializadas em identificar registros duplicados:
- `verificacao_duplicados_diversas_tabelas.sql` - Detecção de duplicatas em múltiplas tabelas
- `verificacao_duplicados_oracle_sql_tb_requisition.sql` - Detecção de duplicatas específica para tabelas de requisição

### 📁 Business_Analytics/ (Análises de Negócio)
Queries para relatórios e análises de negócio:
- `consulta_project_cost.sql` - Consulta de custos de projetos
- `cte._diversos.sql` - Queries complexas usando CTEs para lógicas de negócio

### 📁 ETL_Validation/ (Validação de ETL)
Queries para validação de processos ETL:
- `verificacao_cte_joins_invoice_spend_oracle.sql` - Verificação de joins CTEs para dados de invoice e spend
