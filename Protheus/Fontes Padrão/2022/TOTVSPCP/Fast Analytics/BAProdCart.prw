#INCLUDE "BADEFINITION.CH"

NEW ENTITY PRODCART

//-------------------------------------------------------------------
/*/{Protheus.doc} BAProdCart
Visualiza as informações de Producao em Carteira.

@author  Helio Leal
@since   23/11/2017
/*/
//-------------------------------------------------------------------
ClASs BAProdCart FROM BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClASs

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrão.

@author  Helio Leal
@since   23/11/2017
/*/
//-------------------------------------------------------------------
Method Setup( ) ClASs BAProdCart
	_Super:Setup("ProdCart", FACT, "SC2")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.

@return aQuery, array, Retona AS consultas da entidade por empresa.

@author Helio Leal
@since   23/11/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAProdCart
	Local cQuery := ""
	cQuery := " SELECT" 
	cQuery += " <<KEY_COMPANY>> AS BK_EMPRESA,"
	cQuery += " <<KEY_FILIAL_C2_FILIAL>> AS BK_FILIAl,"
	cQuery += " CASE"
	cQuery += " 	WHEN (SELECT COUNT(*) FROM <<SG1_COMPANY>> SG1 WHERE G1_FILIAL  = <<SUBSTR_SG1_C2_FILIAL>>  AND G1_COD = C2_PRODUTO) = 0 THEN 'Comprado'"
	cQuery += " 	WHEN ((SELECT COUNT(*) FROM <<SG1_COMPANY>> SG1 WHERE G1_FILIAL = <<SUBSTR_SG1_C2_FILIAL>> AND G1_COD = C2_PRODUTO) > 0) AND (B1_TIPO LIKE '%MP%') THEN 'Matéria-Prima'"
	cQuery += " 	WHEN ((SELECT COUNT(*) FROM <<SG1_COMPANY>> SG1 WHERE G1_FILIAL = <<SUBSTR_SG1_C2_FILIAL>> AND G1_COD = C2_PRODUTO) > 0) AND (B1_TIPO not LIKE '%MP%') THEN 'Fabricado'"
	cQuery += " END AS TIPO_PRODUTO,"
	cQuery += " CASE WHEN C2_TPOP = 'F' THEN 'Firme' ELSE 'Prevista' END AS TIPO_PRODUCAO,"
	cQuery += " C2_PEDIDO AS PEDIDO,"
	cQuery += " C2_SEQUEN AS SEQUENCIA_ORDEM,"
	cQuery += " C2_PRIOR AS PRIORIDADE_ORDEM,"
	cQuery += " C2_NUM||C2_ITEM||C2_SEQUEN||C2_ITEMGRD AS ORDEM,"
	cQuery += " <<EXTRACTION_DATE>> AS DATA_EXTRACAO,"
	cQuery += " C2_DATPRI AS DATA_PREVISTA_INICIO_ORDEM,"
	cQuery += " C2_DATPRF AS DATA_PREVISTA_TERMINO_ORDEM,"
	cQuery += " <<KEY_SB1_B1_FILIAL+B1_COD>> AS BK_ITEM,"
	cQuery += " <<KEY_SX5_B1_FILIAL+B1_TIPO>> AS BK_FAMILIA_MATERIAL,"
	cQuery += " '' AS BK_FAMILIA_COMERCIAL,"
	cQuery += " <<KEY_SBM_B1_FILIAL+B1_GRUPO>> AS BK_GRUPO_ESTOQUE,"
	cQuery += " <<KEY_SA1_A1_FILIAL+A1_TIPO>> AS BK_GRUPO_CLIENTE,"
	cQuery += " <<KEY_SB2_C2_FILIAL+C2_LOCAL>> AS BK_DEPOSITO,"
	cQuery += " <<KEY_SA1_A1_FILIAL+A1_COD+A1_LOJA>> AS BK_CLIENTE,"
	cQuery += " CASE WHEN A1_COD_MUN = ' ' THEN <<KEY_CC2_A1_EST>> ELSE <<KEY_CC2_A1_EST+A1_COD_MUN>> END AS BK_REGIAO, "
	cQuery += " C2_QUANT-C2_QUJE AS QTD_PRODUCAO,"
	cQuery += " C2_QUANT * (SELECT B2_CM1 FROM <<SB2_COMPANY>> SB2 WHERE B2_FILIAL = <<SUBSTR_SB2_C2_FILIAL>> AND B2_COD = C2_PRODUTO AND B2_LOCAL = B1_LOCPAD AND SB2.D_E_L_E_T_ = ' ' ) AS VAL_PROGRAMADO," // ,"
	cQuery += " C2_DATPRI AS INICIO_MOVIMENTO_PREVISTO,"
	cQuery += " C2_DATPRF AS FIM_MOVIMENTO_PREVISTO, "
	cQuery += " <<CODE_INSTANCE>> AS INSTANCIA, "
	cQuery += " 1 AS PK_MOEDA, "
	cQuery += " 1 AS TAXA_MOEDA "
	cQuery += " FROM <<SC2_COMPANY>> SC2" 
	cQuery += " INNER JOIN <<SB1_COMPANY>> SB1 ON B1_FILIAL = <<SUBSTR_SB1_C2_FILIAL>>  AND B1_COD = C2_PRODUTO" 
	cQuery += " 	AND SB1.D_E_L_E_T_ = ' '" 
	cQuery += " LEFT JOIN <<SC5_COMPANY>> SC5 ON C5_FILIAL = <<SUBSTR_SC5_C2_FILIAL>> AND C5_NUM = C2_PEDIDO"
	cQuery += " LEFT JOIN <<SA1_COMPANY>> SA1 ON A1_FILIAL = <<SUBSTR_SA1_C5_FILIAL>> AND A1_COD = C5_CLIENTE" 
	cQuery += " 	AND A1_LOJA = C5_LOJACLI"
	cQuery += " WHERE C2_DATRF = ' '" 
	cQuery += " AND SC2.D_E_L_E_T_ = ' '"
	cQuery += " <<AND_XFILIAL_C2_FILIAL>>"
Return cQuery

