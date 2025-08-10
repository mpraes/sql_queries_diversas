--Verificando tabela Schema de Staging
SELECT 
   * 
FROM (
    SELECT 
        SOURCE_RECORD_ID,
        COUNT(*)
    FROM 
        "FUSION".DW_REQUISITION_CF 
    GROUP BY 
        SOURCE_RECORD_ID
    HAVING 
        COUNT(*) > 0
) t

--Verificando tabela Schema final DW
SELECT 
   * 
FROM (
    SELECT 
        NO_SOURCE_RECORD_ID,
        COUNT(*)
    FROM 
        FSSUPRI.PR_REQUISITION 
    GROUP BY 
        NO_SOURCE_RECORD_ID
    HAVING 
        COUNT(*) > 0
) t
--Alguns Ids com mais de 259 registros duplicados
--Source ID é o mesmo que NO_REQUISITION_DISTRIBUTION_ID: 300000023024246, 300000024180781, 300000042721224


--Verificação específica do join da dimensão de Currency com a fato de Requisition
 WITH    DMCUR AS (
        SELECT /*+ MATERIALIZE */
            ID_CURRENCY_DETAILS,
            CD_CURRENCY AS PK_JOIN2
        FROM FSCORP.DM_CURRENCY_DETAILS
    )   
SELECT DISTINCT LINE_CURRENCY_CODE, ID_CURRENCY_DETAILS FROM FUSION.DW_REQUISITION_CF SRC LEFT JOIN DMCUR ON SRC.LINE_CURRENCY_CODE = DMCUR.PK_JOIN2
