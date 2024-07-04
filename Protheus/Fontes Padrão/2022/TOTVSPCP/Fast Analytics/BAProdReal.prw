#INCLUDE "BADEFINITION.CH"

NEW ENTITY PRODREAL

//-------------------------------------------------------------------
/*/{Protheus.doc} BAProdReal
Visualiza AS informações de Producao Realizada.

@author  Helio Leal
@since   23/11/2017
/*/
//-------------------------------------------------------------------
ClASs BAProdReal from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrão.

@author  Helio Leal
@since   23/11/2017
/*/
//-------------------------------------------------------------------
Method Setup( ) ClASs BAProdReal
	_Super:Setup("ProdReal", FACT, "SC2")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.

@return aQuery, array, Retona AS consultAS da entidade por empresa.

@author Helio Leal
@since   23/11/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) ClASs BAProdReal
	Local cQuery := ""

	cQuery := " SELECT" 
	cQuery += " <<KEY_COMPANY>> AS BK_EMPRESA,"
	cQuery += " <<KEY_FILIAL_D3_FILIAL>> AS BK_FILIAL," 
	cQuery += " CASE"
	cQuery += " 	WHEN (SELECT COUNT(*) from <<SG1_COMPANY>> SG1 WHERE G1_FILIAL = <<SUBSTR_SG1_C2_FILIAL>> AND G1_COD = C2_PRODUTO) = 0 THEN 'Comprado'"
	cQuery += " 	WHEN ((SELECT COUNT(*) from <<SG1_COMPANY>> SG1 WHERE G1_FILIAL = <<SUBSTR_SG1_C2_FILIAL>> AND G1_COD = C2_PRODUTO) > 0) AND (B1_TIPO LIKE '%MP%') THEN 'Matéria-Prima'"
	cQuery += " 	WHEN ((SELECT COUNT(*) from <<SG1_COMPANY>> SG1 WHERE G1_FILIAL = <<SUBSTR_SG1_C2_FILIAL>> AND G1_COD = C2_PRODUTO) > 0) AND (B1_TIPO not LIKE '%MP%') THEN 'Fabricado'"
	cQuery += " END AS TIPO_PRODUTO,"
	cQuery += " CASE WHEN C2_TPOP = 'F' THEN 'Firme' ELSE 'Prevista' END AS TIPO_PRODUCAO,"
	cQuery += " C2_PEDIDO AS PEDIDO,"
	cQuery += " C2_SEQUEN AS SEQUENCIA_ORDEM,"
	cQuery += " C2_PRIOR AS PRIORIDADE_ORDEM,"
	cQuery += " C2_NUM||C2_ITEM||C2_SEQUEN||C2_ITEMGRD AS ORDEM,"
	cQuery += " <<EXTRACTION_DATE>> AS DATA_EXTRACAO,"
	cQuery += " D3_EMISSAO AS DATA_EMISSAO_ORDEM,"
	cQuery += " C2_DATRF AS DATA_TERMINO_ORDEM,"
	cQuery += " <<KEY_SB1_B1_FILIAL+B1_COD>> AS BK_ITEM,"
	cQuery += " <<KEY_SX5_B1_FILIAL+B1_TIPO>> AS BK_FAMILIA_MATERIAL,"
	cQuery += " '' AS BK_FAMILIA_COMERCIAL,"
	cQuery += " <<KEY_SBM_B1_FILIAL+B1_GRUPO>> AS BK_GRUPO_ESTOQUE,"	
	cQuery += " <<KEY_SA1_A1_FILIAL+A1_TIPO>> AS BK_GRUPO_CLIENTE,"
	cQuery += " <<KEY_SB2_C2_FILIAL+C2_LOCAL>> AS BK_DEPOSITO,"	
	cQuery += " <<KEY_SA1_B1_FILIAL+A1_COD+A1_LOJA>> AS BK_CLIENTE,"
	cQuery += " CASE WHEN A1_COD_MUN = ' ' THEN <<KEY_CC2_A1_EST>> ELSE <<KEY_CC2_A1_EST+A1_COD_MUN>> END AS BK_REGIAO, "
	cQuery += " D3_QUANT AS QTD_PRODUCAO,"
	cQuery += " D3_PERDA AS QTD_REFUGADA,"
	cQuery += " D3_CUSTO1 AS VAL_CUST_PRODUCAO,"
	cQuery += " (C2_QUANT * B2_CM1) AS VAL_PROGRAMADO,"

	cQuery += " (SELECT ISNULL(SUM(SD3B.D3_CUSTO1 / (CASE WHEN SB2B.B2_CM1 = 0 THEN 1 ELSE SB2B.B2_CM1 END)),0) from <<SD3_COMPANY>> SD3B"
	cQuery += " LEFT JOIN <<SB2_COMPANY>> SB2B ON SB2B.B2_FILIAL = <<SUBSTR_SB2_D3_FILIAL>> AND SB2B.B2_COD = SD3B.D3_COD AND SB2B.B2_LOCAL = SD3B.D3_LOCAL"
	cQuery += " WHERE SD3B.D3_OP = SD3.D3_OP AND SD3B.D3_ESTORNO <> 'S' AND SD3B.D3_CF IN ('RE0','RE1') AND" 
	cQuery += " (SUBSTRING(SD3B.D3_COD, 1, 3) <> 'MOD' AND (SELECT SB1B.B1_CCCUSTO from <<SB1_COMPANY>> SB1B WHERE SB1B.B1_FILIAL = <<SUBSTR_SB1_D3_FILIAL>> AND SB1B.B1_COD = SD3B.D3_COD AND SB1B.D_E_L_E_T_ = ' ') = ' ')) AS VAL_MATERIAL_PROGRAMADO,"

	cQuery += " (SELECT ISNULL(SUM(SD3B.D3_CUSTO1 / (CASE WHEN SB2B.B2_CM1 = 0 THEN 1 ELSE SB2B.B2_CM1 END)),0) from <<SD3_COMPANY>> SD3B"
	cQuery += " LEFT JOIN <<SB2_COMPANY>> SB2B ON SB2B.B2_FILIAL = <<SUBSTR_SB2_D3_FILIAL>> AND SB2B.B2_COD = SD3B.D3_COD AND SB2B.B2_LOCAL = SD3B.D3_LOCAL"
	cQuery += " WHERE SD3B.D3_OP = SD3.D3_OP AND SD3B.D3_ESTORNO <> 'S' AND SD3B.D3_CF IN ('RE0','RE1') AND" 
	cQuery += " (SUBSTRING(SD3B.D3_COD, 1, 3) = 'MOD' or (SELECT SB1B.B1_CCCUSTO from <<SB1_COMPANY>> SB1B WHERE SB1B.B1_FILIAL = <<SUBSTR_SB1_D3_FILIAL>> AND SB1B.B1_COD = SD3B.D3_COD AND SB1B.D_E_L_E_T_ = ' ') <> ' ')) AS VAL_MAO_DE_OBRA_PROGRAMADO,"

	cQuery += " CASE "
	cQuery += " 	WHEN D3_PERDA > 0 THEN ((D3_CUSTO1 / (D3_QUANT + D3_PERDA)) * D3_PERDA)"
	cQuery += " END AS VAL_CUSTO_REFUGADO,"
    cQuery += " C2_EMISSAO as INICIO_MOVIMENTO_REAL,"
	cQuery += " C2_DATRF as FIM_MOVIMENTO_REAL,"
	cQuery += " C2_DATPRI as INICIO_MOVIMENTO_PREVISTO,"
	cQuery += " C2_DATPRF as FIM_MOVIMENTO_PREVISTO,"
	cQuery += " CASE"	
	cQuery += " 	WHEN D3_QUANT > 0 THEN ROUND(D3_CUSTO1 / D3_QUANT, 2)"
	cQuery += " END AS VL_UNITARIO_PRODUTO,"
	cQuery += " D3_EMISSAO AS DATA, "
	cQuery += " <<CODE_INSTANCE>> AS INSTANCIA, "
	cQuery += " 1 AS PK_MOEDA, "
	cQuery += " 1 AS TAXA_MOEDA "
	cQuery += " FROM <<SD3_COMPANY>> SD3" 
	cQuery += " INNER JOIN <<SC2_COMPANY>> SC2 ON C2_FILIAL = <<SUBSTR_SC2_D3_FILIAL>> AND" 
	cQuery += " 	C2_NUM||C2_ITEM||C2_SEQUEN||C2_ITEMGRD = D3_OP" 
	cQuery += " 	AND SC2.D_E_L_E_T_= ' '"
	cQuery += " LEFT JOIN <<SC5_COMPANY>> SC5 on C5_FILIAL = <<SUBSTR_SC5_C2_FILIAL>> AND" 
	cQuery += " 	C5_NUM = SC2.C2_PEDIDO"
	cQuery += " LEFT JOIN <<SA1_COMPANY>> SA1 on A1_FILIAL = <<SUBSTR_SA1_C5_FILIAL>> AND" 
	cQuery += " 	A1_COD = SC5.C5_CLIENTE" 
	cQuery += " 	AND A1_LOJA = C5_LOJACLI"
	cQuery += " INNER JOIN <<SB1_COMPANY>> SB1 ON B1_FILIAL = <<SUBSTR_SB1_D3_FILIAL>>	AND" 
	cQuery += " 	B1_COD = D3_COD" 
	cQuery += " 	AND SB1.D_E_L_E_T_ = ' '" 
	cQuery += " LEFT JOIN <<SB2_COMPANY>> SB2 ON B2_FILIAL = <<SUBSTR_SB2_C2_FILIAL>> AND" 
	cQuery += " 	B2_COD = C2_PRODUTO" 
	cQuery += " 	AND B2_LOCAL = SB1.B1_LOCPAD"
	cQuery += " WHERE D3_CF IN ('PR0', 'PR1')" 
	cQuery += " AND SD3.D_E_L_E_T_ = ' '"
	cQuery += " AND SD3.D3_ESTORNO <> 'S'"
	cQuery += " AND SD3.D3_EMISSAO BETWEEN <<START_DATE>> AND <<FINAL_DATE>> "
	cQuery += " <<AND_XFILIAL_D3_FILIAL>>"
Return cQuery