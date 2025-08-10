-- Itens das Ordens de Compra de Produtos
WITH ItensProduto AS (
    SELECT  
        NUMOCP AS "Numero da Ordem", 
        SEQIPO AS "Item",
        CODEMP AS "Cod Empresa",
        CODFIL AS "Cod Filial",
        SITIPO AS "Situação",
        CODPRO || '-' || TO_CHAR(CODEMP) AS "Cod Material",
        CODFAM || '-' || TO_CHAR(CODEMP) AS "Familia",
        CTAFIN AS "Conta Financeira",
        DATENT AS "Data Entrega OC", 
        USU_PRVPRO AS "Data Chegada OC",
        QTDPED AS "Quantidade Pedido",
        QTDREC AS "Quantidade Recebida",
        QTDCAN AS "Quantidade Cancelada",
        QTDABE AS "Quantidade Aberto",
        PREUNI AS "Preço Unitário",
        (VLRDSC + VLRDS1 + VLRDS2 + VLRDS3 + VLRDS4 + VLRDS5) AS "Valor Desconto",
        CASE 
            WHEN SITIPO = 4 THEN (PREUNI * QTDREC) 
            ELSE (PREUNI * QTDABE) 
        END AS "Valor Bruto",
        (
            (CASE WHEN SITIPO = 4 THEN (PREUNI * QTDREC) ELSE (PREUNI * QTDABE) END) * (PERIPI / 100) 
            + (CASE WHEN SITIPO = 4 THEN (PREUNI * QTDREC) ELSE (PREUNI * QTDABE) END)
        ) AS "Valor Liquido",
        'Produto' AS "Tipo OC"
    FROM SAPIENS.E420IPO
    WHERE SITIPO <> 5
),
-- Itens das Ordens de Compra de Serviço
ItensServico AS (
    SELECT  
        NUMOCP AS "Numero da Ordem", 
        SEQISO AS "Item",
        CODEMP AS "Cod Empresa",
        CODFIL AS "Cod Filial",
        SITISO AS "Situação",
        CODSER || '-' || TO_CHAR(CODEMP) AS "Cod Material",        
        CODFAM || '-' || TO_CHAR(CODEMP) AS "Familia",
        CTAFIN AS "Conta Financeira",
        DATENT AS "Data Entrega OC", 
        DATENT AS "Data Chegada OC",
        QTDPED AS "Quantidade Pedido",
        QTDREC AS "Quantidade Recebida",
        QTDCAN AS "Quantidade Cancelada",
        QTDABE AS "Quantidade Aberto",
        PREUNI AS "Preço Unitário",
        (VLRDSC + VLRDS1 + VLRDS2 + VLRDS3 + VLRDS4 + VLRDS5) AS "Valor Desconto",
        CASE 
            WHEN SITISO = 4 THEN (PREUNI * QTDREC) 
            ELSE (PREUNI * QTDABE) 
        END AS "Valor Bruto",
        CASE 
            WHEN SITISO = 4 THEN (PREUNI * QTDREC) 
            ELSE (PREUNI * QTDABE) 
        END AS "Valor Liquido",
        'Serviço' AS "Tipo OC"
    FROM SAPIENS.E420ISO
    WHERE SITISO <> 5
),
-- Aprovação Ordem de Compra
AprovacaoOc AS (
    SELECT *
    FROM (
        SELECT 
            NUMAPR, 
            CODEMP,
            SEQAPR, 
            USUAPR,
            DATAPR
        FROM SAPIENS.E614USU 
        WHERE ROTNAP = 12
          AND DATAPR > TO_DATE('2023-10-01', 'YYYY-MM-DD')
    )
    PIVOT (
        MAX(USUAPR) AS "Usuário Aprovação",
        MAX(DATAPR) AS "Data Aprovação"
        FOR SEQAPR IN (1 AS OC1, 2 AS OC2, 3 AS OC3)
    )
),
-- Aprovação Cotação
AprocaçaoCot AS (
    SELECT *
    FROM (
        SELECT 
            NUMAPR, 
            CODEMP,
            SEQAPR, 
            USUAPR,
            DATAPR
        FROM SAPIENS.E614USU 
        WHERE ROTNAP = 9
          AND DATAPR > TO_DATE('2023-10-01', 'YYYY-MM-DD')
    )
    PIVOT (
        MAX(USUAPR) AS "Usuário Aprovação",
        MAX(DATAPR) AS "Data Aprovação"
        FOR SEQAPR IN (1 AS CO1, 2 AS CO2)
    )
),
-- Solicitações
solicitacoes AS (
    SELECT
        CODEMP,
        NUMCOT,
        MAX(CODUSU) AS CODUSU,
        MIN(DATSOL) AS DATSOL,
        MAX(DATAPR) AS DATAPR,
        MAX(DATPRV) AS DATPRV  
    FROM SAPIENS.E405SOL
    GROUP BY CODEMP, NUMCOT
)
-- Consulta Principal: Produtos
SELECT
    OC.CODEMP || OC.CODFIL AS "Chave Empresa|Filial",
    OC.NUMOCP AS "Numero da Ordem de Compra", 
    IP."Tipo OC",
    OC.CODEMP AS "Cod Empresa",
    OC.CODFIL AS "Cod Filial",
    OC.CODUSU AS "Cod Usuário",
    OC.CODFOR AS "Cod Fornecedor",
    IP."Conta Financeira",
    SO.DATSOL AS "Data Solicitação",
    SO.DATAPR AS "Data Aprovação Solicitação",
    SO.DATPRV AS "Data Entrega Solicitação",
    CT.NUMCOT AS "Numero da Cotação",
    CT.DATCOT AS "Data Emissão Cotação",
    CT.VLRCOT AS "Valor da Cotação",
    ACT."CO1_Usuário Aprovação",
    ACT."CO1_Data Aprovação",
    ACT."CO2_Usuário Aprovação",
    ACT."CO2_Data Aprovação",
    CASE 
        WHEN IP."Situação" = '1' THEN 'Aberto Total'
        WHEN IP."Situação" = '2' THEN 'Aberto Parcial'
        WHEN IP."Situação" = '4' THEN 'Liquidado'
        WHEN IP."Situação" = '8' THEN 'Preparação Análise ou NF'
        WHEN IP."Situação" = '9' THEN 'Não Fechado' 
    END AS "Situação OC",
    PG.DESCPG AS "Condição de Pagamento",
    PG.PRZMED AS "Condição de Pagamento Médio",
    OC.DATEMI AS "Data Emissão OC",
    IP."Data Entrega OC", 
    IP."Data Chegada OC",
    AC."OC1_Usuário Aprovação",
    AC."OC1_Data Aprovação",
    AC."OC2_Usuário Aprovação",
    AC."OC2_Data Aprovação",
    AC."OC3_Usuário Aprovação",
    AC."OC3_Data Aprovação",
    IP."Item",
    IP."Cod Material",
    IP."Familia",
    IP."Quantidade Pedido",
    IP."Quantidade Recebida",
    IP."Quantidade Cancelada",
    IP."Quantidade Aberto",
    IP."Valor Desconto",
    IP."Preço Unitário",
    IP."Valor Bruto",
    IP."Valor Liquido"
FROM SAPIENS.E420OCP OC
JOIN ItensProduto IP ON OC.NUMOCP = IP."Numero da Ordem" 
                    AND OC.CODEMP = IP."Cod Empresa" 
                    AND OC.CODFIL = IP."Cod Filial"
JOIN SAPIENS.E028CPG PG ON PG.CODCPG = OC.CODCPG 
                        AND PG.CODEMP = OC.CODEMP
LEFT JOIN AprovacaoOc AC ON OC.NUMAPR = AC.NUMAPR 
                         AND OC.CODEMP = AC.CODEMP
LEFT JOIN (
	--Cotações relacionadas a produtos
    SELECT 
        CT.NUMCOT,
        CT.CODEMP,
        CT.FILOCP,
        CT.NUMAPR,
        CT.DATCOT,
        CT.NUMOCP, 
        LC.SEQIPO AS "SEQ",
        CT.VLRCOT
    FROM SAPIENS.E410COT CT 
    LEFT JOIN SAPIENS.E410LCO LC ON LC.NUMCOT = CT.NUMCOT 
                                AND LC.CODEMP = CT.CODEMP 
                                AND LC.NUMOCP = CT.NUMOCP
) CT ON IP."Numero da Ordem" = CT.NUMOCP  
    AND IP."Item" = CT.SEQ 
    AND CT.CODEMP = IP."Cod Empresa" 
    AND CT.FILOCP = IP."Cod Filial"
LEFT JOIN AprocaçaoCot ACT ON ACT.NUMAPR = CT.NUMAPR 
                          AND ACT.CODEMP = CT.CODEMP
LEFT JOIN solicitacoes SO ON SO.NUMCOT = CT.NUMCOT 
    AND SO.CODEMP = CT.CODEMP
WHERE DATEMI > TO_DATE('2023-10-01', 'YYYY-MM-DD')
  AND LENGTH(OC.TNSPRO) > 1
UNION ALL
-- Consulta Principal: Serviços
SELECT
    OC.CODEMP || OC.CODFIL AS "Chave Empresa|Filial",
    OC.NUMOCP AS "Numero da Ordem de Compra", 
    SE."Tipo OC",
    OC.CODEMP AS "Cod Empresa",
    OC.CODFIL AS "Cod Filial",
    OC.CODUSU AS "Cod Usuário",
    OC.CODFOR AS "Cod Fornecedor",
    SE."Conta Financeira",
    SO.DATSOL AS "Data Solicitação",
    SO.DATAPR AS "Data Aprovação Solicitação",
    SO.DATPRV AS "Data Entrega Solicitação",
    CT.NUMCOT AS "Numero da Cotação",
    CT.DATCOT AS "Data Emissão Cotação",
    CT.VLRCOT AS "Valor da Cotação",
    ACT."CO1_Usuário Aprovação",
    ACT."CO1_Data Aprovação",
    ACT."CO2_Usuário Aprovação",
    ACT."CO2_Data Aprovação",
    CASE 
        WHEN SE."Situação" = 1 THEN 'Aberto Total'
        WHEN SE."Situação" = 2 THEN 'Aberto Parcial'
        WHEN SE."Situação" = 4 THEN 'Liquidado'
        WHEN SE."Situação" = 8 THEN 'Preparação Análise ou NF'
        WHEN SE."Situação" = 9 THEN 'Não Fechado' 
    END AS "Situação OC",
    PG.DESCPG AS "Condição de Pagamento",
    PG.PRZMED AS "Condição de Pagamento Médio",
    OC.DATEMI AS "Data Emissão OC",
    SE."Data Entrega OC", 
    SE."Data Chegada OC",
    AC."OC1_Usuário Aprovação",
    AC."OC1_Data Aprovação",
    AC."OC2_Usuário Aprovação",
    AC."OC2_Data Aprovação",
    AC."OC3_Usuário Aprovação",
    AC."OC3_Data Aprovação",
    SE."Item",
    SE."Cod Material",
    SE."Familia",
    SE."Quantidade Pedido",
    SE."Quantidade Recebida",
    SE."Quantidade Cancelada",
    SE."Quantidade Aberto",
    SE."Valor Desconto",
    SE."Preço Unitário",
    SE."Valor Bruto",
    SE."Valor Liquido"
FROM SAPIENS.E420OCP OC
JOIN ItensServico SE ON OC.NUMOCP = SE."Numero da Ordem" 
                     AND OC.CODEMP = SE."Cod Empresa" 
                     AND OC.CODFIL = SE."Cod Filial"
JOIN SAPIENS.E028CPG PG ON PG.CODCPG = OC.CODCPG 
                        AND PG.CODEMP = OC.CODEMP
LEFT JOIN AprovacaoOc AC ON OC.NUMAPR = AC.NUMAPR 
                         AND OC.CODEMP = AC.CODEMP
LEFT JOIN (
    --Cotações relacionadas a serviços
	SELECT 
        CT.NUMCOT,
        CT.CODEMP,
        CT.FILOCP,
        CT.NUMAPR,
        CT.DATCOT,
        CT.NUMOCP, 
        LC.SEQISO AS "SEQ",
        CT.VLRCOT
    FROM SAPIENS.E410COT CT
    JOIN SAPIENS.E410LCO LC ON LC.NUMCOT = CT.NUMCOT 
                            AND LC.CODEMP = CT.CODEMP 
                            AND LC.NUMOCP = CT.NUMOCP
) CT ON SE."Numero da Ordem" = CT.NUMOCP  
    AND SE."Item" = CT.SEQ 
    AND CT.CODEMP = SE."Cod Empresa"  
    AND CT.FILOCP = SE."Cod Filial"
LEFT JOIN AprocaçaoCot ACT ON ACT.NUMAPR = CT.NUMAPR 
                          AND ACT.CODEMP = CT.CODEMP
LEFT JOIN solicitacoes SO ON SO.NUMCOT = CT.NUMCOT 
    AND SO.CODEMP = CT.CODEMP
WHERE DATEMI > TO_DATE('2023-10-01', 'YYYY-MM-DD')
  AND LENGTH(OC.TNSSER) > 1;
