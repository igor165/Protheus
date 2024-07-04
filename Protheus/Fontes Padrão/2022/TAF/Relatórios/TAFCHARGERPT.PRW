#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE ANALITICO_MATRICULA				1
#DEFINE ANALITICO_CATEGORIA				2
#DEFINE ANALITICO_TIPO_ESTABELECIMENTO	3
#DEFINE ANALITICO_ESTABELECIMENTO		4
#DEFINE ANALITICO_LOTACAO				5
#DEFINE ANALITICO_NATUREZA				6
#DEFINE ANALITICO_TIPO_RUBRICA			7
#DEFINE ANALITICO_INCIDENCIA_CP			8
#DEFINE ANALITICO_INCIDENCIA_IRRF		9
#DEFINE ANALITICO_INCIDENCIA_FGTS		10
#DEFINE ANALITICO_DECIMO_TERCEIRO		11
#DEFINE ANALITICO_TIPO_VALOR			12
#DEFINE ANALITICO_VALOR					13
#DEFINE ANALITICO_RECIBO 				15
#DEFINE	ANALITICO_VALOR_DEP 		    16
 
Static oReport	:=	Nil
Static lLaySimplif	:= TafLayESoc("S_01_00_00")

//---------------------------------------------------------------------
/*/{Protheus.doc} RptCharge
@type			function
@description	Executa a carga na tabela V3N.
@author			Felipe C. Seolin
@since			03/06/2019
@version		1.0
@param			oRunCharge		-	Objeto do FWMsgRun
@param			lCallExternal	-	Indica se a chamada é externa ao menu do TAF
@param			cPeriodo		-	Período de referência das informações
@param			aFilial			-	Filiais disponibilizadas para seleção de processamento
@param			cParamCPF		-	CPF selecionado como filtro de processamento
/*/
//---------------------------------------------------------------------
Function RptCharge( oRunCharge, lCallExternal, cPeriodo, aFilial, cParamCPF )

	Local cFilMatriz 	:= ""
	Local cCNPJRaiz  	:= SubStr( SM0->M0_CGC, 1, 8 )
	Local nI         	:= 0
	Local aFilSel    	:= {}
	Local aFilMV     	:= {}
	Local aFilMatriz 	:= TAFGFilMatriz()
	Local aInfoSM0   	:= FWLoadSM0()
	Local lProtheus  	:= GetNewPar( "MV_RHTAF", .F. )

	Private cST2Alias	:= GetNextAlias()
	Private cFilSel		:= ""
	Private cFilSelMV	:= ""

	For nI := 1 to Len( aFilial )

		If aFilial[nI][1]
			aAdd( aFilSel, aFilial[nI][2] )
		EndIf

	Next nI

	cFilSel := TAFCacheFil(Nil, aFilSel, .T.)

	If !RptFull(cPeriodo, cParamCPF)

		For nI := 1 to Len( aInfoSM0 )

			If SubStr( aInfoSM0[nI,18], 1, 8 ) == cCNPJRaiz .and. aInfoSM0[nI,1] == cEmpAnt
				aAdd( aFilMV, aInfoSM0[nI,2] )
			EndIf

		Next nI

		cFilSelMV	:= TAFCacheFil(Nil, aFilMV, .T.)
		cFilMatriz	:= IIf( !Empty( aFilMatriz ), aFilMatriz[2], "" )

		xTAFCriaTB( ,,"TAFST2", cST2Alias )

		DataS1200( oRunCharge, lCallExternal, cPeriodo, aFilSel, cParamCPF, lProtheus, cFilMatriz, aFilMV )
		DataS2299( oRunCharge, lCallExternal, cPeriodo, aFilSel, cParamCPF, lProtheus, cFilMatriz )
		DataS2399( oRunCharge, lCallExternal, cPeriodo, aFilSel, cParamCPF, lProtheus, cFilMatriz )

		( cST2Alias )->( DBCloseArea() )

	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} DataS1200
@type			function
@description	Função responsável por coletar as informações do Evento S-1200 no TAF.
@author			Felipe C. Seolin
@since			03/06/2019
@version		1.0
@param			oRunCharge		-	Objeto do FWMsgRun
@param			lCallExternal	-	Indica se a chamada é externa ao menu do TAF
@param			cPeriodo		-	Período de referência das informações
@param			aFilial			-	Filiais selecionadas para processamento
@param			lProtheus		-	Indica se a Origem dos dados parte do Protheus
@param			cParamCPF		-	CPF selecionado como filtro de processamento
@param			cFilMatriz		-	Filial Matriz
@param			aFilMV			-	Array de filiais a ser consideradas na cláusula IN do SQL para Múltiplos Vínculos
/*/
//---------------------------------------------------------------------
Static Function DataS1200(oRunCharge, lCallExternal, cPeriodo, aFilial, cParamCPF, lProtheus, cFilMatriz, aFilMV)

	Local aAnalitico  	:= {}
	Local cAliasQry   	:= ""
	Local cQuery      	:= ""
	Local cFilBkp     	:= ""
	Local cFilQry     	:= ""
	Local cID         	:= ""
	Local cVersao     	:= ""
	Local cIDEstab    	:= ""
	Local cMVTpEstab  	:= ""
	Local cMVEstab    	:= ""
	Local cIDLotac    	:= ""
	Local cMVLotac    	:= ""
	Local cIDTrabal   	:= ""
	Local cMVTrabal   	:= ""
	Local cIDCateg    	:= ""
	Local cIndApu     	:= ""
	Local cPerApu     	:= ""
	Local cRecibo     	:= ""
	Local cIdeDmd		:= ""
	Local cTipoEstab  	:= ""
	Local cEstab      	:= ""
	Local cLotacao    	:= ""
	Local cCPF        	:= ""
	Local cNome       	:= ""
	Local cMatric     	:= ""
	Local cCodCat     	:= ""
	Local cNatureza   	:= ""
	Local cTipo       	:= ""
	Local cIncidCP    	:= ""
	Local cIncidIRRF  	:= ""
	Local cIncidFGTS  	:= ""
	Local lMultVinc   	:= .F.
	Local nRecnoQry   	:= 0
	Local nQtdTotal   	:= 0
	Local nQtdProc    	:= 0
	Local nI          	:= 0
	Local nPosValores 	:= 0
	Local oInfoRPT    	:= Nil

	If !Empty( aFilial )

		cAliasQry := GetNextAlias()

		cQuery := "SELECT COUNT(*) QUANTIDADE "
		cQuery += "FROM ( "
		cQuery += "			SELECT C91.C91_FILIAL, C91.C91_ID, C91.C91_VERSAO "
		cQuery += "			FROM " + RetSqlName( "C91" ) + " C91 "
		cQuery += "			WHERE C91.C91_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "

		If Len( AllTrim( cPeriodo ) ) == 4
			cQuery += "			  AND C91.C91_PERAPU = '" + cPeriodo +  "' "
		Else
			cQuery += "			  AND C91.C91_PERAPU = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
		EndIf

		cQuery += "			  AND EXISTS (	SELECT C9M.R_E_C_N_O_ "
		cQuery += "							FROM " + RetSqlName( "C9M" ) + " C9M "
		cQuery += "							WHERE C9M.C9M_FILIAL = C91.C91_FILIAL "
		cQuery += "							  AND C9M.C9M_ID = C91.C91_ID "
		cQuery += "							  AND C9M.C9M_VERSAO = C91.C91_VERSAO "
		cQuery += "							  AND C9M.D_E_L_E_T_ = '' ) "

		//Filtro por CPF
		If !Empty( cParamCPF )

			cQuery += "			  AND EXISTS (	SELECT C9V.R_E_C_N_O_ "
			cQuery += "							FROM " + RetSqlName( "C9V" ) + " C9V "
			cQuery += "							WHERE C9V.C9V_FILIAL = C91.C91_FILIAL "
			cQuery += "							  AND C9V.C9V_ID = C91.C91_TRABAL "
			cQuery += "							  AND C9V.C9V_CPF = '" + AllTrim( cParamCPF ) + "' "
			cQuery += "							  AND C9V.D_E_L_E_T_ = ' ' ) "

		EndIf

		cQuery += "			  AND C91.C91_NOMEVE = 'S1200' "
		cQuery += "			  AND C91.C91_ATIVO = '1' "
		cQuery += "			  AND C91.C91_EVENTO <> 'E' "
		cQuery += "			  AND C91.D_E_L_E_T_ = '' "

		cQuery += "			UNION ALL "

		cQuery += "			SELECT C91.C91_FILIAL, C91.C91_ID, C91.C91_VERSAO "
		cQuery += "			FROM " + RetSqlName( "C91" ) + " C91 "
		cQuery += "			WHERE C91.C91_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "

		If Len( AllTrim( cPeriodo ) ) == 4
			cQuery += "			  AND C91.C91_PERAPU = '" + cPeriodo +  "' "
		Else
			cQuery += "			  AND C91.C91_PERAPU = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
		EndIf

		cQuery += "			  AND EXISTS (	SELECT C9R.R_E_C_N_O_ "
		cQuery += "							FROM " + RetSqlName( "C9R" ) + " C9R "
		cQuery += "							WHERE C9R.C9R_FILIAL = C91.C91_FILIAL "
		cQuery += "							  AND C9R.C9R_ID = C91.C91_ID "
		cQuery += "							  AND C9R.C9R_VERSAO = C91.C91_VERSAO "
		cQuery += "							  AND C9R.D_E_L_E_T_ = '' ) "

		//Filtro por CPF
		If !Empty( cParamCPF )

			cQuery += "			  AND EXISTS (	SELECT C9V.R_E_C_N_O_ "
			cQuery += "							FROM " + RetSqlName( "C9V" ) + " C9V "
			cQuery += "							WHERE C9V.C9V_FILIAL = C91.C91_FILIAL "
			cQuery += "							  AND C9V.C9V_ID = C91.C91_TRABAL "
			cQuery += "							  AND C9V.C9V_CPF = '" + AllTrim( cParamCPF ) + "' "
			cQuery += "							  AND C9V.D_E_L_E_T_ = ' ' ) "

		EndIf

		cQuery += "			  AND C91.C91_NOMEVE = 'S1200' "
		cQuery += "			  AND C91.C91_ATIVO = '1' "
		cQuery += "			  AND C91.C91_EVENTO <> 'E' "
		cQuery += "			  AND C91.D_E_L_E_T_ = '' "
		cQuery += " ) FOLHA "

		cQuery := ChangeQuery( cQuery )

		TCQuery cQuery New Alias (cAliasQry)

		( cAliasQry )->( DBGoTop() )

		If ( cAliasQry )->( !Eof() )
			nQtdTotal := ( cAliasQry )->QUANTIDADE
		EndIf

		( cAliasQry )->( DBCloseArea() )

		If nQtdTotal > 0

			//Tabelas com as informações do Trabalhador
			C9V->( DBSetOrder( 2 ) ) //C9V_FILIAL, C9V_ID, C9V_ATIVO, R_E_C_N_O_, D_E_L_E_T_
			CUP->( DBSetOrder( 4 ) ) //CUP_FILIAL, CUP_ID, CUP_VERSAO, CUP_NOMEVE, CUP_MATRIC, R_E_C_N_O_, D_E_L_E_T_
			C87->( DBSetOrder( 1 ) ) //C87_FILIAL, C87_ID, C87_VALIDA, R_E_C_N_O_, D_E_L_E_T_

			//Tabela com as informações do Estabelecimento
			C92->( DBSetOrder( 5 ) ) //C92_FILIAL, C92_ID, C92_ATIVO, R_E_C_N_O_, D_E_L_E_T_

			//Tabela com as informações da Lotação
			C99->( DBSetOrder( 4 ) ) //C99_FILIAL, C99_ID, C99_ATIVO, R_E_C_N_O_, D_E_L_E_T_

			cFilBkp := cFilAnt

			For nI := 1 to Len( aFilial )

				cFilAnt := aFilial[nI]

				cAliasQry := GetNextAlias()

				cQuery := "SELECT DISTINCT C91.R_E_C_N_O_ C91_RECONHECIMENTO, C91.C91_FILIAL, C91.C91_ID, C91.C91_VERSAO, C91.C91_INDAPU, C91.C91_PERAPU, C91.C91_TRABAL, C91.C91_CPF, C91.C91_NOME, C91.C91_MV, C91.C91_PROTUL "
				cQuery += "     , C9K.C9K_ESTABE ESTABE, C9K.C9K_LOTACA LOTACA, C9K.C9K_TPINSC TPINSC, C9K.C9K_NRINSC NRINSC, C9K.C9K_CODLOT CODLOT "
				cQuery += "     , C9L.C9L_TRABAL TRABAL, C9L.C9L_DTRABA DTRABA "
				cQuery += "     , T14.T14_IDEDMD, T14.T14_CODCAT "
				cQuery += "     , C89.C89_CODIGO, C8R.C8R_INDTRB, C8T.C8T_CODIGO, C8U.C8U_CODIGO, C8R.C8R_CINTFG "
				cQuery += "     , C89MV.C89_CODIGO MVC89_CODIGO, C8RMV.C8R_INDTRB MVC8R_INDTRB, C8TMV.C8T_CODIGO MVC8T_CODIGO, C8UMV.C8U_CODIGO MVC8U_CODIGO, C8RMV.C8R_CINTFG MVC8R_CINTFG "

				cQuery += "     , C9M.C9M_VLRRUB VLRRUB, C9M.R_E_C_N_O_ C9M_RECONHECIMENTO "

				cQuery += "FROM " + RetSqlName( "C91" ) + " C91 "

				cQuery += "INNER JOIN " + RetSqlName( "T14" ) + " T14 "
				cQuery += "   ON T14.T14_FILIAL = C91.C91_FILIAL "
				cQuery += "  AND T14.T14_ID = C91.C91_ID "
				cQuery += "  AND T14.T14_VERSAO = C91.C91_VERSAO "
				cQuery += "  AND T14.D_E_L_E_T_ = '' "

				cQuery += "INNER JOIN " + RetSqlName( "C9K" ) + " C9K "
				cQuery += "   ON C9K.C9K_FILIAL = T14.T14_FILIAL "
				cQuery += "  AND C9K.C9K_ID = T14.T14_ID "
				cQuery += "  AND C9K.C9K_VERSAO = T14.T14_VERSAO "
				cQuery += "  AND C9K.C9K_RECIBO = T14.T14_IDEDMD "
				cQuery += "  AND C9K.D_E_L_E_T_ = '' "

				cQuery += "INNER JOIN " + RetSqlName( "C9L" ) + " C9L "
				cQuery += "   ON C9L.C9L_FILIAL = C9K.C9K_FILIAL "
				cQuery += "  AND C9L.C9L_ID = C9K.C9K_ID "
				cQuery += "  AND C9L.C9L_VERSAO = C9K.C9K_VERSAO "
				cQuery += "  AND C9L.C9L_RECIBO = C9K.C9K_RECIBO "
				cQuery += "  AND C9L.C9L_ESTABE = C9K.C9K_ESTABE "
				cQuery += "  AND C9L.C9L_LOTACA = C9K.C9K_LOTACA "
				cQuery += "  AND C9L.C9L_TPINSC = C9K.C9K_TPINSC "
				cQuery += "  AND C9L.C9L_NRINSC = C9K.C9K_NRINSC "
				cQuery += "  AND C9L.C9L_CODLOT = C9K.C9K_CODLOT "
				cQuery += "  AND C9L.D_E_L_E_T_ = '' "

				cQuery += "INNER JOIN " + RetSqlName( "C9M" ) + " C9M "
				cQuery += "   ON C9M.C9M_FILIAL = C9L.C9L_FILIAL "
				cQuery += "  AND C9M.C9M_ID = C9L.C9L_ID "
				cQuery += "  AND C9M.C9M_VERSAO = C9L.C9L_VERSAO "
				cQuery += "  AND C9M.C9M_RECIBO = C9L.C9L_RECIBO "
				cQuery += "  AND C9M.C9M_ESTABE = C9L.C9L_ESTABE "
				cQuery += "  AND C9M.C9M_LOTACA = C9L.C9L_LOTACA "
				cQuery += "  AND C9M.C9M_TRABAL = C9L.C9L_TRABAL "
				cQuery += "  AND C9M.C9M_TPINSC = C9L.C9L_TPINSC "
				cQuery += "  AND C9M.C9M_NRINSC = C9L.C9L_NRINSC "
				cQuery += "  AND C9M.C9M_CODLOT = C9L.C9L_CODLOT "
				cQuery += "  AND C9M.C9M_DTRABA = C9L.C9L_DTRABA "
				cQuery += "  AND C9M.D_E_L_E_T_ = '' "

				//Filtro por CPF
				If !Empty( cParamCPF )
				
					cQuery += "INNER JOIN " + RetSqlName( "C9V" ) + " C9V "
					cQuery += "   ON C9V.C9V_FILIAL = C91.C91_FILIAL "
					cQuery += "  AND C9V.C9V_ID = C91.C91_TRABAL "
					cQuery += "  AND C9V.C9V_CPF = '" + AllTrim( cParamCPF ) + "' "
					cQuery += "  AND C9V.D_E_L_E_T_ = ' ' "
				
				EndIf

				cQuery += "LEFT JOIN " + RetSqlName( "C8R" ) + " C8R "
				cQuery += "  ON C8R.C8R_FILIAL = '" + xFilial( "C8R" ) + "' "
				cQuery += " AND C8R.C8R_ID = C9M.C9M_CODRUB "
				cQuery += " AND C8R.C8R_ATIVO = '1' "
				cQuery += " AND C8R.D_E_L_E_T_ = '' "

				cQuery += "LEFT JOIN " + RetSqlName( "C89" ) + " C89 "
				cQuery += "  ON C89.C89_FILIAL = '" + xFilial( "C89" ) + "' "
				cQuery += " AND C89.C89_ID = C8R.C8R_NATRUB "
				cQuery += " AND C89.D_E_L_E_T_ = '' "

				cQuery += "LEFT JOIN " + RetSqlName( "C8T" ) + " C8T "
				cQuery += "  ON C8T.C8T_FILIAL = '" + xFilial( "C8T" ) + "' "
				cQuery += " AND C8T.C8T_ID = C8R.C8R_CINTPS "
				cQuery += " AND C8T.D_E_L_E_T_ = '' "

				cQuery += "LEFT JOIN " + RetSqlName( "C8U" ) + " C8U "
				cQuery += "  ON C8U.C8U_FILIAL = '" + xFilial( "C8U" ) + "' "
				cQuery += " AND C8U.C8U_ID = C8R.C8R_CINTIR "
				cQuery += " AND C8U.D_E_L_E_T_ = '' "

				cQuery += "LEFT JOIN " + RetSqlName( "C8R" ) + " C8RMV "
				cQuery += "  ON C8RMV.C8R_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSelMV + " FILIAIS ) "
				cQuery += " AND C8RMV.C8R_CODRUB = C9M.C9M_RUBRIC "
				cQuery += " AND C8RMV.C8R_IDTBRU = C9M.C9M_IDTABR "

				If Len( AllTrim( cPeriodo ) ) == 4
					cQuery += " AND ( ( C8RMV.C8R_DTINI <= '12" + cPeriodo + "' AND C8RMV.C8R_DTFIN = '' ) OR ( C8RMV.C8R_DTINI <= '12" + cPeriodo + "' AND C8RMV.C8R_DTFIN >= '12" + cPeriodo + "' ) ) "
				Else
					cQuery += " AND ( ( C8RMV.C8R_DTINI <= '" + cPeriodo + "' AND C8RMV.C8R_DTFIN = '' ) OR ( C8RMV.C8R_DTINI <= '" + cPeriodo + "' AND C8RMV.C8R_DTFIN >= '" + cPeriodo + "' ) ) "
				EndIf

				cQuery += " AND C8RMV.D_E_L_E_T_ = '' "

				cQuery += "LEFT JOIN " + RetSqlName( "C89" ) + " C89MV "
				cQuery += "  ON C89MV.C89_FILIAL = '" + xFilial( "C89" ) + "' "
				cQuery += " AND C89MV.C89_ID = C8RMV.C8R_NATRUB "
				cQuery += " AND C89MV.D_E_L_E_T_ = '' "

				cQuery += "LEFT JOIN " + RetSqlName( "C8T" ) + " C8TMV "
				cQuery += "  ON C8TMV.C8T_FILIAL = '" + xFilial( "C8T" ) + "' "
				cQuery += " AND C8TMV.C8T_ID = C8RMV.C8R_CINTPS "
				cQuery += " AND C8TMV.D_E_L_E_T_ = '' "

				cQuery += "LEFT JOIN " + RetSqlName( "C8U" ) + " C8UMV "
				cQuery += "  ON C8UMV.C8U_FILIAL = '" + xFilial( "C8U" ) + "' "
				cQuery += " AND C8UMV.C8U_ID = C8RMV.C8R_CINTIR "
				cQuery += " AND C8UMV.D_E_L_E_T_ = '' "

				cQuery += "WHERE C91.C91_FILIAL = '" + xFilial( "C91" ) + "' "

				If Len( AllTrim( cPeriodo ) ) == 4
					cQuery += "  AND C91.C91_PERAPU = '" + cPeriodo +  "' "
				Else
					cQuery += "  AND C91.C91_PERAPU = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
				EndIf

				cQuery += "  AND C91.C91_NOMEVE = 'S1200' "
				cQuery += "  AND C91.C91_ATIVO = '1' "
				cQuery += "  AND C91.C91_EVENTO <> 'E' "
				cQuery += "  AND C91.D_E_L_E_T_ = '' "

				cQuery += "UNION ALL "

				cQuery += " SELECT DISTINCT C91.R_E_C_N_O_, C91.C91_FILIAL, C91.C91_ID, C91.C91_VERSAO, C91.C91_INDAPU, C91.C91_PERAPU, C91.C91_TRABAL, C91.C91_CPF, C91.C91_NOME, C91.C91_MV, C91.C91_PROTUL "
				cQuery += "     , C9P.C9P_ESTABE, C9P.C9P_LOTACA, C9P.C9P_TPINSC, C9P.C9P_NRINSC, C9P.C9P_CODLOT "
				cQuery += "     , C9Q.C9Q_TRABAL, C9Q.C9Q_DTRABA "
				cQuery += "     , T14.T14_IDEDMD, T14.T14_CODCAT "
				cQuery += "     , C89.C89_CODIGO, C8R.C8R_INDTRB, C8T.C8T_CODIGO, C8U.C8U_CODIGO, C8R.C8R_CINTFG "
				cQuery += "     , C89MV.C89_CODIGO, C8RMV.C8R_INDTRB, C8TMV.C8T_CODIGO, C8UMV.C8U_CODIGO, C8RMV.C8R_CINTFG "
				cQuery += "     , C9R.C9R_VLRRUB, C9R.R_E_C_N_O_ C9R_RECONHECIMENTO "

				cQuery += "FROM " + RetSqlName( "C91" ) + " C91 "

				cQuery += " INNER JOIN " + RetSqlName( "T14" ) + " T14 "
				cQuery += "  ON T14.T14_FILIAL = C91.C91_FILIAL "
				cQuery += "  AND T14.T14_ID = C91.C91_ID "
				cQuery += "  AND T14.T14_VERSAO = C91.C91_VERSAO "
				cQuery += "  AND T14.D_E_L_E_T_ = '' "

				cQuery += " INNER JOIN " + RetSqlName( "C9N" ) + " C9N "
				cQuery += "  ON C9N.C9N_FILIAL = T14.T14_FILIAL "
				cQuery += "  AND C9N.C9N_ID = T14.T14_ID "
				cQuery += "  AND C9N.C9N_VERSAO = T14.T14_VERSAO "
				cQuery += "  AND C9N.C9N_RECIBO = T14.T14_IDEDMD "
				cQuery += "  AND C9N.D_E_L_E_T_ = '' "

				cQuery += " INNER JOIN " + RetSqlName( "C9O" ) + " C9O "
				cQuery += "  ON C9O.C9O_FILIAL = C9N.C9N_FILIAL "
				cQuery += "  AND C9O.C9O_ID = C9N.C9N_ID "
				cQuery += "  AND C9O.C9O_VERSAO = C9N.C9N_VERSAO "
				cQuery += "  AND C9O.C9O_RECIBO = C9N.C9N_RECIBO "
				cQuery += "  AND C9O.C9O_DTACOR = C9N.C9N_DTACOR "
				cQuery += "  AND C9O.C9O_TPACOR = C9N.C9N_TPACOR "
				cQuery += "  AND C9O.C9O_COMPAC = C9N.C9N_COMPAC "
				cQuery += "  AND C9O.D_E_L_E_T_ = '' "

				cQuery += " INNER JOIN " + RetSqlName( "C9P" ) + " C9P "
				cQuery += "  ON C9P.C9P_FILIAL = C9O.C9O_FILIAL "
				cQuery += "  AND C9P.C9P_ID = C9O.C9O_ID "
				cQuery += "  AND C9P.C9P_VERSAO = C9O.C9O_VERSAO "
				cQuery += "  AND C9P.C9P_RECIBO = C9O.C9O_RECIBO "
				cQuery += "  AND C9P.C9P_DTACOR = C9O.C9O_DTACOR "
				cQuery += "  AND C9P.C9P_TPACOR = C9O.C9O_TPACOR "
				cQuery += "  AND C9P.C9P_COMPAC = C9O.C9O_COMPAC "
				cQuery += "  AND C9P.C9P_PERREF = C9O.C9O_PERREF "
				cQuery += "  AND C9P.D_E_L_E_T_ = '' "

				cQuery += " INNER JOIN " + RetSqlName( "C9Q" ) + " C9Q "
				cQuery += "  ON C9Q.C9Q_FILIAL = C9P.C9P_FILIAL "
				cQuery += "  AND C9Q.C9Q_ID = C9P.C9P_ID "
				cQuery += "  AND C9Q.C9Q_VERSAO = C9P.C9P_VERSAO "
				cQuery += "  AND C9Q.C9Q_RECIBO = C9P.C9P_RECIBO "
				cQuery += "  AND C9Q.C9Q_DTACOR = C9P.C9P_DTACOR "
				cQuery += "  AND C9Q.C9Q_TPACOR = C9P.C9P_TPACOR "
				cQuery += "  AND C9Q.C9Q_COMPAC = C9P.C9P_COMPAC "
				cQuery += "  AND C9Q.C9Q_PERREF = C9P.C9P_PERREF "
				cQuery += "  AND C9Q.C9Q_ESTABE = C9P.C9P_ESTABE "
				cQuery += "  AND C9Q.C9Q_LOTACA = C9P.C9P_LOTACA "
				cQuery += "  AND C9Q.D_E_L_E_T_ = '' "

				cQuery += " INNER JOIN " + RetSqlName( "C9R" ) + " C9R "
				cQuery += "  ON C9R.C9R_FILIAL = C9Q.C9Q_FILIAL "
				cQuery += "  AND C9R.C9R_ID = C9Q.C9Q_ID "
				cQuery += "  AND C9R.C9R_VERSAO = C9Q.C9Q_VERSAO "
				cQuery += "  AND C9R.C9R_RECIBO = C9Q.C9Q_RECIBO "
				cQuery += "  AND C9R.C9R_DTACOR = C9Q.C9Q_DTACOR "
				cQuery += "  AND C9R.C9R_TPACOR = C9Q.C9Q_TPACOR "
				cQuery += "  AND C9R.C9R_COMPAC = C9Q.C9Q_COMPAC "
				cQuery += "  AND C9R.C9R_PERREF = C9Q.C9Q_PERREF "
				cQuery += "  AND C9R.C9R_ESTABE = C9Q.C9Q_ESTABE "
				cQuery += "  AND C9R.C9R_LOTACA = C9Q.C9Q_LOTACA "
				cQuery += "  AND C9R.C9R_TRABAL = C9Q.C9Q_TRABAL "
				cQuery += "  AND C9R.D_E_L_E_T_ = '' "

				//Filtro por CPF
				If !Empty( cParamCPF )
					cQuery += " INNER JOIN " + RetSqlName( "C9V" ) + " C9V "
					cQuery += "  ON C9V.C9V_FILIAL = C91.C91_FILIAL "
					cQuery += "  AND C9V.C9V_ID = C91.C91_TRABAL "
					cQuery += "  AND C9V.C9V_CPF = '" + AllTrim( cParamCPF ) + "' "
					cQuery += "  AND C9V.D_E_L_E_T_ = ' ' "
				EndIf

				cQuery += " LEFT JOIN " + RetSqlName( "C8R" ) + " C8R "
				cQuery += " ON C8R.C8R_FILIAL = '" + xFilial( "C8R" ) + "' "
				cQuery += " AND C8R.C8R_ID = C9R.C9R_CODRUB "
				cQuery += " AND C8R.C8R_ATIVO = '1' "
				cQuery += " AND C8R.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C89" ) + " C89 "
				cQuery += " ON C89.C89_FILIAL = '" + xFilial( "C89" ) + "' "
				cQuery += " AND C89.C89_ID = C8R.C8R_NATRUB "
				cQuery += " AND C89.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C8T" ) + " C8T "
				cQuery += " ON C8T.C8T_FILIAL = '" + xFilial( "C8T" ) + "' "
				cQuery += " AND C8T.C8T_ID = C8R.C8R_CINTPS "
				cQuery += " AND C8T.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C8U" ) + " C8U "
				cQuery += " ON C8U.C8U_FILIAL = '" + xFilial( "C8U" ) + "' "
				cQuery += " AND C8U.C8U_ID = C8R.C8R_CINTIR "
				cQuery += " AND C8U.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C8R" ) + " C8RMV "
				cQuery += " ON C8RMV.C8R_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSelMV + " FILIAIS ) "
				cQuery += " AND C8RMV.C8R_CODRUB = C9R.C9R_RUBRIC "
				cQuery += " AND C8RMV.C8R_IDTBRU = C9R.C9R_IDTABR "

				If Len( AllTrim( cPeriodo ) ) == 4
					cQuery += " AND ( ( C8RMV.C8R_DTINI <= '12" + cPeriodo + "' AND C8RMV.C8R_DTFIN = '' ) OR ( C8RMV.C8R_DTINI <= '12" + cPeriodo + "' AND C8RMV.C8R_DTFIN >= '12" + cPeriodo + "' ) ) "
				Else
					cQuery += " AND ( ( C8RMV.C8R_DTINI <= '" + cPeriodo + "' AND C8RMV.C8R_DTFIN = '' ) OR ( C8RMV.C8R_DTINI <= '" + cPeriodo + "' AND C8RMV.C8R_DTFIN >= '" + cPeriodo + "' ) ) "
				EndIf

				cQuery += " AND C8RMV.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C89" ) + " C89MV "
				cQuery += " ON C89MV.C89_FILIAL = '" + xFilial( "C89" ) + "' "
				cQuery += " AND C89MV.C89_ID = C8RMV.C8R_NATRUB "
				cQuery += " AND C89MV.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C8T" ) + " C8TMV "
				cQuery += " ON C8TMV.C8T_FILIAL = '" + xFilial( "C8T" ) + "' "
				cQuery += " AND C8TMV.C8T_ID = C8RMV.C8R_CINTPS "
				cQuery += " AND C8TMV.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C8U" ) + " C8UMV "
				cQuery += " ON C8UMV.C8U_FILIAL = '" + xFilial( "C8U" ) + "' "
				cQuery += " AND C8UMV.C8U_ID = C8RMV.C8R_CINTIR "
				cQuery += " AND C8UMV.D_E_L_E_T_ = '' "

				cQuery += " WHERE C91.C91_FILIAL = '" + xFilial( "C91" ) + "' "

				If Len( AllTrim( cPeriodo ) ) == 4
					cQuery += "  AND C91.C91_PERAPU = '" + cPeriodo +  "' "
				Else
					cQuery += "  AND C91.C91_PERAPU = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
				EndIf

				cQuery += "  AND C91.C91_NOMEVE = 'S1200' "
				cQuery += "  AND C91.C91_ATIVO = '1' "
				cQuery += "  AND C91.C91_EVENTO <> 'E' "
				cQuery += "  AND C91.D_E_L_E_T_ = '' "

				cQuery += " ORDER BY C91_FILIAL, C91_ID, C91_VERSAO, C91_INDAPU, C91_PERAPU, ESTABE, LOTACA, TPINSC, NRINSC, CODLOT, TRABAL, DTRABA "

				cQuery := ChangeQuery( cQuery )

				TCQuery cQuery New Alias (cAliasQry)

				( cAliasQry )->( DBGoTop() )

				While ( cAliasQry )->( !Eof() )	

					cFilQry		:= (cAliasQry)->C91_FILIAL
					cID			:= (cAliasQry)->C91_ID
					cVersao		:= (cAliasQry)->C91_VERSAO
					cIDEstab	:= (cAliasQry)->ESTABE
					cMVTpEstab	:= (cAliasQry)->TPINSC
					cMVEstab	:= (cAliasQry)->NRINSC
					cIDLotac	:= (cAliasQry)->LOTACA
					cMVLotac	:= (cAliasQry)->CODLOT
					cIDTrabal	:= (cAliasQry)->TRABAL
					cMVTrabal	:= (cAliasQry)->DTRABA
					cIdeDmd		:= (cAliasQry)->T14_IDEDMD
					cIDCateg	:= (cAliasQry)->T14_CODCAT
					cIndApu		:= (cAliasQry)->C91_INDAPU
					cPerApu		:= (cAliasQry)->C91_PERAPU
					cRecibo		:= (cAliasQry)->C91_PROTUL
					lMultVinc	:= (cAliasQry)->C91_MV == "1"
					nRecnoQry	:= (cAliasQry)->C91_RECONHECIMENTO

					If lMultVinc

						cTipoEstab	:=	( cAliasQry )->TPINSC
						cEstab		:=	( cAliasQry )->NRINSC
						cLotacao	:=	( cAliasQry )->CODLOT
						cCPF		:=	( cAliasQry )->C91_CPF
						cNome		:=	( cAliasQry )->C91_NOME
						cMatric		:=	( cAliasQry )->DTRABA

						C87->( MsSeek( xFilial( "C87" ) + ( cAliasQry )->T14_CODCAT ) )
						cCodCat		:=	C87->C87_CODIGO

					Else

						//A tag matricula não é obrigatória no grupo de Remuneração para S-2300.
						//Desta forma, caso não possua ID do Trabalhador na tabela filha, busco pelo ID da tabela principal.
						If Empty( ( cAliasQry )->TRABAL )
							C9V->( MsSeek( xFilial( "C9V" ) + ( cAliasQry )->C91_TRABAL + "1" ) )
						Else
							C9V->( MsSeek( xFilial( "C9V" ) + ( cAliasQry )->TRABAL + "1" ) )
						EndIf

						If C9V->C9V_NOMEVE == "S2200"

							If Empty( ( cAliasQry )->T14_CODCAT )
								CUP->( MsSeek( xFilial( "CUP" ) + C9V->( C9V_ID + C9V_VERSAO + C9V_NOMEVE ) ) )
								C87->( MsSeek( xFilial( "C87" ) + CUP->CUP_CODCAT ) )

							Else

								C87->( MsSeek( xFilial( "C87" ) + ( cAliasQry )->T14_CODCAT ) )

							EndIf

						ElseIf C9V->C9V_NOMEVE == "S2300"

							If Empty( ( cAliasQry )->T14_CODCAT )

								C87->( MsSeek( xFilial( "C87" ) + C9V->C9V_CATCI ) )

							Else
								C87->( MsSeek( xFilial( "C87" ) + ( cAliasQry )->T14_CODCAT ) )

							EndIf

						ElseIf C9V->C9V_NOMEVE == "TAUTO"

							C87->( MsSeek( xFilial( "C87" ) + ( cAliasQry )->T14_CODCAT ) )

						EndIf

						C92->( MsSeek( xFilial( "C92" ) + ( cAliasQry )->ESTABE + "1" ) )
						C99->( MsSeek( xFilial( "C99" ) + ( cAliasQry )->LOTACA + "1" ) )

						cTipoEstab	:=	C92->C92_TPINSC
						cEstab		:=	C92->C92_NRINSC
						cLotacao	:=	C99->C99_CODIGO
						cCPF		:=	C9V->C9V_CPF
						cNome		:=	C9V->C9V_NOME
						cMatric		:=	IIF(Empty(C9V->C9V_MATRIC),C9V->C9V_MATTSV,C9V->C9V_MATRIC)
						cCodCat		:=	C87->C87_CODIGO

					EndIf

					While ( cAliasQry )->( C91_FILIAL + C91_ID + C91_VERSAO + ESTABE + TPINSC + NRINSC + LOTACA + CODLOT + TRABAL + DTRABA + T14_CODCAT ) == cFilQry + cID + cVersao + cIDEstab + cMVTpEstab + cMVEstab + cIDLotac + cMVLotac + cIDTrabal + cMVTrabal + cIDCateg

						cNatureza	:=	IIf( lMultVinc, AllTrim( ( cAliasQry )->MVC89_CODIGO ), AllTrim( ( cAliasQry )->C89_CODIGO ) )
						cTipo		:=	IIf( lMultVinc, AllTrim( ( cAliasQry )->MVC8R_INDTRB ), AllTrim( ( cAliasQry )->C8R_INDTRB ) )
						cIncidCP	:=	IIf( lMultVinc, AllTrim( ( cAliasQry )->MVC8T_CODIGO ), AllTrim( ( cAliasQry )->C8T_CODIGO ) )
						cIncidIRRF	:=	IIf( lMultVinc, AllTrim( ( cAliasQry )->MVC8U_CODIGO ), AllTrim( ( cAliasQry )->C8U_CODIGO ) )
						cIncidFGTS	:=	IIf( lMultVinc, AllTrim( ( cAliasQry )->MVC8R_CINTFG ), AllTrim( ( cAliasQry )->C8R_CINTFG ) )

						aAdd( aAnalitico, Array( 16 ) )
						nPosValores := Len( aAnalitico )

						aAnalitico[nPosValores][ANALITICO_MATRICULA]			:= AllTrim(cMatric)
						aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:= AllTrim(cCodCat)
						aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:= AllTrim(cTipoEstab)
						aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:= AllTrim(cEstab)
						aAnalitico[nPosValores][ANALITICO_LOTACAO]				:= AllTrim(cLotacao)
						aAnalitico[nPosValores][ANALITICO_NATUREZA]				:= AllTrim(cNatureza)
						aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:= AllTrim(cTipo)
						aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:= AllTrim(cIncidCP)
						aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:= AllTrim(cIncidIRRF)
						aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:= AllTrim(cIncidFGTS)
						aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:= ""
						aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:= ""
						aAnalitico[nPosValores][ANALITICO_VALOR]				:= (cAliasQry)->VLRRUB
						aAnalitico[nPosValores][ANALITICO_RECIBO]				:= AllTrim(cIdeDmd)

						( cAliasQry )->( DBSkip() )

					EndDo

					If ( cAliasQry )->( C91_FILIAL + C91_ID + C91_VERSAO ) <> cFilQry + cID + cVersao
						InfoRPTObj(cIndApu, cPerApu, cCPF, cNome, aAnalitico,, @oInfoRPT)

						oReport:UpSert("S-1200", "2", cFilQry, oInfoRPT)

						If lProtheus
							InfoRPTObj(cIndApu, cPerApu, cCPF, cNome, aAnalitico,, @oInfoRPT)

							oReport:UpSert("S-1200", "1", cFilQry, oInfoRPT)
						Else
							InsOrigC91( cFilQry, nRecnoQry, lMultVinc, aFilMV )
						EndIf

						Insert5003( "S-1200", cFilQry, cPeriodo, cCPF, cRecibo, cFilMatriz )

						nQtdProc ++

						If !lCallExternal
							SetIncPerc( oRunCharge, "S-1200", nQtdTotal, nQtdProc )
						EndIf

						aAnalitico := {}

					EndIf

					cFilQry		:=	""
					cID			:=	""
					cVersao		:=	""
					cIDEstab	:=	""
					cMVTpEstab	:=	""
					cMVEstab	:=	""
					cIDLotac	:=	""
					cMVLotac	:=	""
					cIDTrabal	:=	""
					cMVTrabal	:=	""
					cIDCateg	:=	""
					cIndApu		:=	""
					cPerApu		:=	""
					cRecibo		:=	""
					cTipoEstab	:=	""
					cEstab		:=	""
					cLotacao	:=	""
					cCPF		:=	""
					cNome		:=	""
					cMatric		:=	""
					cCodCat		:=	""
					cNatureza	:=	""
					cTipo		:=	""
					cIncidCP	:=	""
					cIncidIRRF	:=	""
					cIncidFGTS	:=	""
					nRecnoQry	:=	0
					lMultVinc	:=	.F.

				EndDo

				( cAliasQry )->( DBCloseArea() )

			Next nI

			cFilAnt := cFilBkp

		Else

			nQtdProc ++

			If !lCallExternal
				SetIncPerc( oRunCharge, "S-1200", nQtdTotal, nQtdProc )
			EndIf

		EndIf

	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} InsOrigC91
@type			function
@description	Função responsável por coletar as informações do Evento S-1200 no XML de entrada.
@author			Felipe C. Seolin
@since			10/06/2019
@version		1.0
@param			cFilEvt		-	Filial do registro do evento S-1200 no TAF
@param			nRecno		-	Recno do registro do evento S-1200 no TAF
@param			lMultVinc	-	Indica se o evento S-1200 é Múltiplo Vínculo
@param			aFilMV		-	Array de filiais a ser consideradas na cláusula IN do SQL para Múltiplos Vínculos
/*/
//---------------------------------------------------------------------
Static Function InsOrigC91( cFilEvt, nRecno, lMultVinc, aFilMV )

	Local oInfoRPT    := Nil
	Local oXml        := Nil
	Local cAliasQry   := GetNextAlias()
	Local cQuery      := ""
	Local cXml        := ""
	Local cPerApu     := ""
	Local cNome       := ""
	Local cT14Path    := ""
	Local cC9KPath    := ""
	Local cC9LPath    := ""
	Local cC9MPath    := ""
	Local cC9NPath    := ""
	Local cC9OPath    := ""
	Local cC9PPath    := ""
	Local cC9QPath    := ""
	Local cC9RPath    := ""
	Local nT14        := 0
	Local nC9K        := 0
	Local nC9L        := 0
	Local nC9M        := 0
	Local nC9N        := 0
	Local nC9O        := 0
	Local nC9P        := 0
	Local nC9Q        := 0
	Local nC9R        := 0
	Local nPosValores := 0
	Local nTipPer	  := 1
	Local aAnalitico  := {}
	Local aRubrica    := {}
	Local aAreaC1E    := C1E->( GetArea() )
	Local aAreaC9V    := C9V->( GetArea() )
	Local aAreaC8R    := C8R->( GetArea() )

	C1E->( DBSetOrder( 3 ) ) //C1E_FILIAL, C1E_FILTAF, C1E_ATIVO, R_E_C_N_O_, D_E_L_E_T_
	C1E->( MsSeek( xFilial( "C1E" ) + cFilEvt + "1" ) )

	cQuery := " SELECT TAFST2.R_E_C_N_O_ TAFST2_RECONHECIMENTO "
	cQuery += " FROM TAFXERP TAFXERP "
	cQuery += " INNER JOIN TAFST2 TAFST2 "
	cQuery += "   ON TAFST2.TAFTICKET = TAFXERP.TAFTICKET "
	cQuery += "  AND TAFST2.TAFKEY = TAFXERP.TAFKEY "
	cQuery += "  AND TAFST2.TAFFIL = '" + C1E->C1E_CODFIL + "' "
	cQuery += "  AND TAFST2.D_E_L_E_T_ = '' "
	cQuery += " WHERE TAFXERP.TAFALIAS = 'C91' "
	cQuery += "  AND TAFXERP.TAFRECNO = '" + cValToChar( nRecno ) + "' "
	cQuery += "  AND TAFXERP.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY TAFXERP.R_E_C_N_O_ DESC "

	cQuery := ChangeQuery( cQuery )

	TCQuery cQuery New Alias (cAliasQry)

	( cAliasQry )->( DBGoTop() )

	If ( cAliasQry )->( !Eof() )

		C8R->( DBSetOrder( 3 ) ) //C8R_FILIAL, C8R_CODRUB, C8R_ATIVO, R_E_C_N_O_, D_E_L_E_T_
		C89->( DBSetOrder( 1 ) ) //C89_FILIAL, C89_ID, R_E_C_N_O_, D_E_L_E_T_
		C8T->( DBSetOrder( 1 ) ) //C8T_FILIAL, C8T_ID, R_E_C_N_O_, D_E_L_E_T_

		( cST2Alias )->( DBGoTo( ( cAliasQry )->TAFST2_RECONHECIMENTO ) )

		cXml := ( cST2Alias )->TAFMSG

		//Tiro os espaços em branco no início e final do XML e armazeno na variável
		cXml := EncodeUTF8( AllTrim( cXml ) )

		//Instancia objeto em oXml
		oXml := TXmlManager():New()

		If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"

			cXml := StrTran( cXml, Chr( 13 ), "" )
			cXml := StrTran( cXml, Chr( 10 ), "" )

			//Tratamento para integração Oracle onde o XML vem com o último caracter faltando
			If SubStr( AllTrim( cXml ), Len( cXml ), 1 ) <> ">"
				cXml += ">"
			EndIf

		EndIf

		If !Empty( cXml ) .and. oXml:Parse( FTrocaPath( cXml, "eSocial" ) )
			oXml:bDecodeUTF8 := .T.
		EndIf

		cPerApu := StrTran( AllTrim( oXml:xPathGetNodeValue( "/eSocial/evtRemun/ideEvento/perApur" ) ), "-", "" )

		If oXml:xPathHasNode( "/eSocial/evtRemun/ideTrabalhador/infoComplem" )
			cNome := oXml:xPathGetNodeValue( "/eSocial/evtRemun/ideTrabalhador/infoComplem/nmTrab" )
		Else
			cNome := Posicione( "C9V", 3, xFilial( "C9V" ) + AllTrim( oXml:xPathGetNodeValue( "/eSocial/evtRemun/ideTrabalhador/cpfTrab" ) ) + "1", "C9V_NOME" )
		EndIf

		//T14 - Informações do Recibo de Pagamento
		nT14 := 1
		cT14Path := "/eSocial/evtRemun/dmDev[" + cValToChar( nT14 ) + "]"

		While oXml:xPathHasNode( cT14Path )

			//Informações do Período de Apuração
			//C9K - Informações do Estabelecimento/Lotação
			nC9K := 1
			cC9KPath := cT14Path + "/infoPerApur/ideEstabLot[" + cValToChar( nC9K ) + "]"

			While oXml:xPathHasNode( cC9KPath )

				//C9L - Informações da Remuneração do Trabalhador
				nC9L := 1
				cC9LPath := cC9KPath + "/remunPerApur[" + cValToChar( nC9L ) + "]"

				While oXml:xPathHasNode( cC9LPath )

					//C9M - Informações das Rubricas
					nC9M := 1
					cC9MPath := cC9LPath + "/itensRemun[" + cValToChar( nC9M ) + "]"

					While oXml:xPathHasNode( cC9MPath )
					
						aRubrica := oReport:GetRubrica( oXml:xPathGetNodeValue( cC9MPath + "/codRubr" ), TAFIDTabRub( oXml:xPathGetNodeValue( cC9MPath + "/ideTabRubr" ), "T3M", oXml:xPathGetNodeValue( cC9MPath + "/codRubr" )), cPerApu, lMultVinc )

						aAdd( aAnalitico, Array( 16 ) )
						nPosValores := Len( aAnalitico )

						aAnalitico[nPosValores][ANALITICO_MATRICULA]			:= AllTrim(oXml:xPathGetNodeValue(cC9LPath + "/matricula"))
						aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:= AllTrim(oXml:xPathGetNodeValue(cT14Path + "/codCateg"))
						aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:= AllTrim(oXml:xPathGetNodeValue(cC9KPath + "/tpInsc"))
						aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:= AllTrim(oXml:xPathGetNodeValue(cC9KPath + "/nrInsc"))
						aAnalitico[nPosValores][ANALITICO_LOTACAO]				:= AllTrim(oXml:xPathGetNodeValue(cC9KPath + "/codLotacao"))
						aAnalitico[nPosValores][ANALITICO_NATUREZA]				:= AllTrim(aRubrica[1])
						aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:= AllTrim(aRubrica[2])
						aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:= AllTrim(aRubrica[3])
						aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:= AllTrim(aRubrica[4])
						aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:= AllTrim(aRubrica[5])
						aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:= ""
						aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:= ""
						aAnalitico[nPosValores][ANALITICO_VALOR]				:= Val(StrTran(oXml:xPathGetNodeValue(cC9MPath + "/vrRubr"), ",", "."))
						aAnalitico[nPosValores][ANALITICO_RECIBO]				:= AllTrim(oXml:xPathGetNodeValue(cT14Path + "/ideDmDev"))

						nC9M ++
						cC9MPath := cC9LPath + "/itensRemun[" + cValToChar( nC9M ) + "]"

					EndDo

					nC9L ++
					cC9LPath := cC9KPath + "/remunPerApur[" + cValToChar( nC9L ) + "]"

				EndDo

				nC9K ++
				cC9KPath := cT14Path + "/infoPerApur/ideEstabLot[" + cValToChar( nC9K ) + "]"

			EndDo

			//Informações do Período de Apuração Anterior
			//C9N - Informações do Acordo
			nTipPer		:= 2	// 1=Período Atual; 2=Período Anterior
			nC9N 		:= 1
			cC9NPath 	:= cT14Path + "/infoPerAnt/ideADC[" + cValToChar( nC9N ) + "]"

			While oXml:xPathHasNode( cC9NPath )

				//C9O - Identificação do Período de Referência
				nC9O := 1
				cC9OPath := cC9NPath + "/idePeriodo[" + cValToChar( nC9O ) + "]"

				While oXml:xPathHasNode( cC9OPath )

					//C9P - Informações do Estabelecimento/Lotacão
					nC9P := 1
					cC9PPath := cC9OPath + "/ideEstabLot[" + cValToChar( nC9P ) + "]

					While oXml:xPathHasNode( cC9PPath )

						//C9Q - Informações da Remuneração
						nC9Q := 1
						cC9QPath := cC9PPath + "/remunPerAnt[" + cValToChar( nC9Q ) + "]"

						While oXml:xPathHasNode( cC9QPath )

							//C9R - Itens da Remuneração
							nC9R := 1
							cC9RPath := cC9QPath + "/itensRemun[" + cValToChar( nC9R ) + "]"

							While oXml:xPathHasNode( cC9RPath )
								aRubrica := oReport:GetRubrica( oXml:xPathGetNodeValue( cC9RPath + "/codRubr" ), TAFIDTabRub( oXml:xPathGetNodeValue( cC9RPath + "/ideTabRubr" ), "T3M", oXml:xPathGetNodeValue( cC9RPath + "/codRubr" )), cPerApu, lMultVinc, nTipPer )

								aAdd( aAnalitico, Array( 16 ) )
								nPosValores := Len( aAnalitico )

								aAnalitico[nPosValores][ANALITICO_MATRICULA]			:= AllTrim(oXml:xPathGetNodeValue(cC9QPath + "/matricula"))
								aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:= AllTrim(oXml:xPathGetNodeValue(cT14Path + "/codCateg"))
								aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:= AllTrim(oXml:xPathGetNodeValue(cC9PPath + "/tpInsc"))
								aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:= AllTrim(oXml:xPathGetNodeValue(cC9PPath + "/nrInsc"))
								aAnalitico[nPosValores][ANALITICO_LOTACAO]				:= AllTrim(oXml:xPathGetNodeValue(cC9PPath + "/codLotacao"))
								aAnalitico[nPosValores][ANALITICO_NATUREZA]				:= AllTrim(aRubrica[1])
								aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:= AllTrim(aRubrica[2])
								aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:= AllTrim(aRubrica[3])
								aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:= AllTrim(aRubrica[4])
								aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:= AllTrim(aRubrica[5])
								aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:= ""
								aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:= ""
								aAnalitico[nPosValores][ANALITICO_VALOR]				:= Val(StrTran(oXml:xPathGetNodeValue(cC9RPath + "/vrRubr"), ",", "."))
								aAnalitico[nPosValores][ANALITICO_RECIBO]				:= AllTrim(oXml:xPathGetNodeValue(cT14Path + "/ideDmDev"))

								nC9R ++
								cC9RPath := cC9QPath + "/itensRemun[" + cValToChar( nC9R ) + "]"

							EndDo

							nC9Q ++
							cC9QPath := cC9PPath + "/remunPerAnt[" + cValToChar( nC9Q ) + "]"

						EndDo

						nC9P ++
						cC9PPath := cC9OPath + "/ideEstabLot[" + cValToChar( nC9P ) + "]"

					EndDo

					nC9O ++
					cC9OPath := cC9NPath + "/idePeriodo[" + cValToChar( nC9O ) + "]"

				EndDo

				nC9N ++
				cC9NPath := cT14Path + "/infoPerAnt/ideADC[" + cValToChar( nC9N ) + "]"

			EndDo

			nT14 ++
			cT14Path := "/eSocial/evtRemun/dmDev[" + cValToChar( nT14 ) + "]"

		EndDo

		InfoRPTObj(AllTrim(oXml:xPathGetNodeValue("/eSocial/evtRemun/ideEvento/indApuracao")),; 
			AllTrim(cPerApu),;
			AllTrim(oXml:xPathGetNodeValue("/eSocial/evtRemun/ideTrabalhador/cpfTrab")),;
			AllTrim(cNome), aAnalitico,, @oInfoRPT)

		oReport:UpSert("S-1200", "1", cFilEvt, oInfoRPT)

	EndIf

	( cAliasQry )->( DBCloseArea() )

	RestArea( aAreaC1E )
	RestArea( aAreaC9V )
	RestArea( aAreaC8R )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} DataS2299
@type			function
@description	Função responsável por coletar as informações do Evento S-2299 no TAF.
@author			Felipe C. Seolin
@since			15/07/2019
@version		1.0
@param			oRunCharge		-	Objeto do FWMsgRun
@param			lCallExternal	-	Indica se a chamada é externa ao menu do TAF
@param			cPeriodo		-	Período de referência das informações
@param			aFilial			-	Filiais selecionadas para processamento
@param			cParamCPF		-	CPF selecionado como filtro de processamento
@param			lProtheus		-	Indica se a Origem dos dados parte do Protheus
@param			cFilMatriz		-	Filial Matriz
/*/
//---------------------------------------------------------------------
Static Function DataS2299( oRunCharge, lCallExternal, cPeriodo, aFilial, cParamCPF, lProtheus, cFilMatriz )

	Local oInfoRPT    := Nil
	Local cAliasQry   := ""
	Local cQuery      := ""
	Local cFilBkp     := ""
	Local cFilQry     := ""
	Local cID         := ""
	Local cVersao     := ""
	Local cIDEstab    := ""
	Local cIDLotac    := ""
	Local cIDTrabal   := ""
	Local cPerApu     := ""
	Local cRecibo     := ""
	Local cTipoEstab  := ""
	Local cEstab      := ""
	Local cLotacao    := ""
	Local cCPF        := ""
	Local cNome       := ""
	Local cMatric     := ""
	Local cCodCat     := ""
	Local cNatureza   := ""
	Local cTipo       := ""
	Local cIncidCP    := ""
	Local cIncidIRRF  := ""
	Local cIncidFGTS  := ""
	Local nRecnoQry   := 0
	Local nQtdTotal   := 0
	Local nQtdProc    := 0
	Local nI          := 0
	Local nPosValores := 0
	Local aAnalitico  := {}

	If !Empty( aFilial )

		cAliasQry := GetNextAlias()

		cQuery := "SELECT COUNT(*) QUANTIDADE "
		cQuery += "FROM ( "
		cQuery += "			SELECT CMD.CMD_FILIAL, CMD.CMD_ID, CMD.CMD_VERSAO "
		cQuery += "			FROM " + RetSqlName( "CMD" ) + " CMD "
		cQuery += "			WHERE CMD.CMD_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "

		If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"
			cQuery += "			  AND SUBSTR( CMD.CMD_DTDESL, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
		Else
			cQuery += "			  AND SUBSTRING( CMD.CMD_DTDESL, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
		EndIf

		cQuery += "			  AND EXISTS (	SELECT T05.R_E_C_N_O_ "
		cQuery += "							FROM " + RetSqlName( "T05" ) + " T05 "
		cQuery += "							WHERE T05.T05_FILIAL = CMD.CMD_FILIAL "
		cQuery += "							  AND T05.T05_ID = CMD.CMD_ID "
		cQuery += "							  AND T05.T05_VERSAO = CMD.CMD_VERSAO "
		cQuery += "							  AND T05.D_E_L_E_T_ = '' ) "

		//Filtro por CPF
		If !Empty( cParamCPF )

			cQuery += "			  AND EXISTS (	SELECT C9V.R_E_C_N_O_ "
			cQuery += "							FROM " + RetSqlName( "C9V" ) + " C9V "
			cQuery += "							WHERE C9V.C9V_FILIAL = CMD.CMD_FILIAL "
			cQuery += "							  AND C9V.C9V_ID = CMD.CMD_FUNC "
			cQuery += "							  AND C9V.C9V_CPF = '" + AllTrim( cParamCPF ) + "' "
			cQuery += "							  AND C9V.D_E_L_E_T_ = ' ' ) "

		EndIf

		cQuery += "			  AND CMD.CMD_ATIVO = '1' "
		cQuery += "			  AND CMD.CMD_EVENTO <> 'E' "
		cQuery += "			  AND CMD.D_E_L_E_T_ = '' "

		cQuery += "			UNION ALL "

		cQuery += "			SELECT CMD.CMD_FILIAL, CMD.CMD_ID, CMD.CMD_VERSAO "
		cQuery += "			FROM " + RetSqlName( "CMD" ) + " CMD "
		cQuery += "			WHERE CMD.CMD_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "

		If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"
			cQuery += "			  AND SUBSTR( CMD.CMD_DTDESL, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
		Else
			cQuery += "			  AND SUBSTRING( CMD.CMD_DTDESL, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
		EndIf

		cQuery += "			  AND EXISTS (	SELECT T5S.R_E_C_N_O_ "
		cQuery += "							FROM " + RetSqlName( "T5S" ) + " T5S "
		cQuery += "							WHERE T5S.T5S_FILIAL = CMD.CMD_FILIAL "
		cQuery += "							  AND T5S.T5S_ID = CMD.CMD_ID "
		cQuery += "							  AND T5S.T5S_VERSAO = CMD.CMD_VERSAO "
		cQuery += "							  AND T5S.D_E_L_E_T_ = '' ) "

		//Filtro por CPF
		If !Empty( cParamCPF )

			cQuery += "			  AND EXISTS (	SELECT C9V.R_E_C_N_O_ "
			cQuery += "							FROM " + RetSqlName( "C9V" ) + " C9V "
			cQuery += "							WHERE C9V.C9V_FILIAL = CMD.CMD_FILIAL "
			cQuery += "							  AND C9V.C9V_ID = CMD.CMD_FUNC "
			cQuery += "							  AND C9V.C9V_CPF = '" + AllTrim( cParamCPF ) + "' "
			cQuery += "							  AND C9V.D_E_L_E_T_ = ' ' ) "

		EndIf

		cQuery += "			  AND CMD.CMD_ATIVO = '1' "
		cQuery += "			  AND CMD.CMD_EVENTO <> 'E' "
		cQuery += "			  AND CMD.D_E_L_E_T_ = '' "
		cQuery += " ) DESLIGAMENTO "

		cQuery := ChangeQuery( cQuery )

		TCQuery cQuery New Alias (cAliasQry)

		( cAliasQry )->( DBGoTop() )

		If ( cAliasQry )->( !Eof() )
			nQtdTotal := ( cAliasQry )->QUANTIDADE
		EndIf

		( cAliasQry )->( DBCloseArea() )

		If nQtdTotal > 0

			//Tabelas com as informações do Trabalhador
			C9V->( DBSetOrder( 2 ) ) //C9V_FILIAL, C9V_ID, C9V_ATIVO, R_E_C_N_O_, D_E_L_E_T_
			CUP->( DBSetOrder( 4 ) ) //CUP_FILIAL, CUP_ID, CUP_VERSAO, CUP_NOMEVE, CUP_MATRIC, R_E_C_N_O_, D_E_L_E_T_
			C87->( DBSetOrder( 1 ) ) //C87_FILIAL, C87_ID, C87_VALIDA, R_E_C_N_O_, D_E_L_E_T_

			//Tabela com as informações do Estabelecimento
			C92->( DBSetOrder( 5 ) ) //C92_FILIAL, C92_ID, C92_ATIVO, R_E_C_N_O_, D_E_L_E_T_

			//Tabela com as informações da Lotação
			C99->( DBSetOrder( 4 ) ) //C99_FILIAL, C99_ID, C99_ATIVO, R_E_C_N_O_, D_E_L_E_T_

			cFilBkp := cFilAnt

			For nI := 1 to Len( aFilial )

				cFilAnt := aFilial[nI]

				cAliasQry := GetNextAlias()

				cQuery := " SELECT DISTINCT CMD.R_E_C_N_O_ CMD_RECONHECIMENTO, CMD.CMD_FILIAL, CMD.CMD_ID, CMD.CMD_VERSAO, CMD.CMD_DTDESL, CMD.CMD_FUNC, CMD.CMD_PROTUL "
				cQuery += "     , T3G.T3G_ESTABE ESTABE, T3G.T3G_LOTTRB LOTTRB "
				cQuery += "     , C89.C89_CODIGO, C8R.C8R_INDTRB, C8T.C8T_CODIGO, C8U.C8U_CODIGO, C8R.C8R_CINTFG "
				cQuery += "     , T05.T05_VLRRUB VLRRUB, T05.R_E_C_N_O_ T05_RECONHECIMENTO "

				cQuery += " FROM " + RetSqlName( "CMD" ) + " CMD "

				cQuery += " INNER JOIN " + RetSqlName( "T06" ) + " T06 "
				cQuery += "  ON T06.T06_FILIAL = CMD.CMD_FILIAL "
				cQuery += "  AND T06.T06_ID = CMD.CMD_ID "
				cQuery += "  AND T06.T06_VERSAO = CMD.CMD_VERSAO "
				cQuery += "  AND T06.D_E_L_E_T_ = '' "

				cQuery += " INNER JOIN " + RetSqlName( "T3G" ) + " T3G "
				cQuery += "  ON T3G.T3G_FILIAL = T06.T06_FILIAL "
				cQuery += "  AND T3G.T3G_ID = T06.T06_ID "
				cQuery += "  AND T3G.T3G_VERSAO = T06.T06_VERSAO "
				cQuery += "  AND T3G.T3G_RECPAG = T06.T06_IDEDMD "
				cQuery += "  AND T3G.D_E_L_E_T_ = '' "

				cQuery += " INNER JOIN " + RetSqlName( "T05" ) + " T05 "
				cQuery += "  ON T05.T05_FILIAL = T3G.T3G_FILIAL "
				cQuery += "  AND T05.T05_ID = T3G.T3G_ID "
				cQuery += "  AND T05.T05_VERSAO = T3G.T3G_VERSAO "
				cQuery += "  AND T05.T05_RECPAG = T3G.T3G_RECPAG "
				cQuery += "  AND T05.T05_ESTABE = T3G.T3G_ESTABE "
				cQuery += "  AND T05.T05_LOTTRB = T3G.T3G_LOTTRB "
				cQuery += "  AND T05.D_E_L_E_T_ = '' "

				//Filtro por CPF
				If !Empty( cParamCPF )

					cQuery += " INNER JOIN " + RetSqlName( "C9V" ) + " C9V "
					cQuery += "  ON C9V.C9V_FILIAL = CMD.CMD_FILIAL "
					cQuery += "  AND C9V.C9V_ID = CMD.CMD_FUNC "
					cQuery += "  AND C9V.C9V_CPF = '" + AllTrim( cParamCPF ) + "' "
					cQuery += "  AND C9V.D_E_L_E_T_ = ' ' "

				EndIf

				cQuery += " LEFT JOIN " + RetSqlName( "C8R" ) + " C8R "
				cQuery += " ON C8R.C8R_FILIAL = '" + xFilial( "C8R" ) + "' "
				cQuery += " AND C8R.C8R_ID = T05.T05_CODRUB "
				cQuery += " AND C8R.C8R_ATIVO = '1' "
				cQuery += " AND C8R.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C89" ) + " C89 "
				cQuery += " ON C89.C89_FILIAL = '" + xFilial( "C89" ) + "' "
				cQuery += " AND C89.C89_ID = C8R.C8R_NATRUB "
				cQuery += " AND C89.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C8T" ) + " C8T "
				cQuery += " ON C8T.C8T_FILIAL = '" + xFilial( "C8T" ) + "' "
				cQuery += " AND C8T.C8T_ID = C8R.C8R_CINTPS "
				cQuery += " AND C8T.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C8U" ) + " C8U "
				cQuery += " ON C8U.C8U_FILIAL = '" + xFilial( "C8U" ) + "' "
				cQuery += " AND C8U.C8U_ID = C8R.C8R_CINTPS "
				cQuery += " AND C8U.D_E_L_E_T_ = '' "

				cQuery += " WHERE CMD.CMD_FILIAL = '" + xFilial( "CMD" ) + "' "

				If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"
					cQuery += "  AND SUBSTR( CMD.CMD_DTDESL, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
				Else
					cQuery += "  AND SUBSTRING( CMD.CMD_DTDESL, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
				EndIf

				cQuery += "  AND CMD.CMD_ATIVO = '1' "
				cQuery += "  AND CMD.CMD_EVENTO <> 'E' "
				cQuery += "  AND CMD.D_E_L_E_T_ = '' "

				cQuery += " UNION ALL "

				cQuery += " SELECT DISTINCT CMD.R_E_C_N_O_, CMD.CMD_FILIAL, CMD.CMD_ID, CMD.CMD_VERSAO, CMD.CMD_DTDESL, CMD.CMD_FUNC, CMD.CMD_PROTUL "
				cQuery += "     , T5Q.T5Q_ESTABE, T5Q.T5Q_LOTTRB "
				cQuery += "     , C89.C89_CODIGO, C8R.C8R_INDTRB, C8T.C8T_CODIGO, C8U.C8U_CODIGO, C8R.C8R_CINTFG "
				cQuery += "     , T5S.T5S_VLRRUB, T5S.R_E_C_N_O_ T5S_RECONHECIMENTO "

				cQuery += " FROM " + RetSqlName( "CMD" ) + " CMD "

				cQuery += " INNER JOIN " + RetSqlName( "T06" ) + " T06 "
				cQuery += "  ON T06.T06_FILIAL = CMD.CMD_FILIAL "
				cQuery += "  AND T06.T06_ID = CMD.CMD_ID "
				cQuery += "  AND T06.T06_VERSAO = CMD.CMD_VERSAO "
				cQuery += "  AND T06.D_E_L_E_T_ = '' "

				cQuery += " INNER JOIN " + RetSqlName( "T5I" ) + " T5I "
				cQuery += "  ON T5I.T5I_FILIAL = T06.T06_FILIAL "
				cQuery += "  AND T5I.T5I_ID = T06.T06_ID "
				cQuery += "  AND T5I.T5I_VERSAO = T06.T06_VERSAO "
				cQuery += "  AND T5I.T5I_IDEDMD = T06.T06_IDEDMD "
				cQuery += "  AND T5I.D_E_L_E_T_ = '' "

				cQuery += " INNER JOIN " + RetSqlName( "T5J" ) + " T5J "
				cQuery += "  ON T5J.T5J_FILIAL = T5I.T5I_FILIAL "
				cQuery += "  AND T5J.T5J_ID = T5I.T5I_ID "
				cQuery += "  AND T5J.T5J_VERSAO = T5I.T5I_VERSAO "
				cQuery += "  AND T5J.T5J_IDEDMD = T5I.T5I_IDEDMD "
				cQuery += "  AND T5J.T5J_DTACCO = T5I.T5I_DTACCO "
				cQuery += "  AND T5J.T5J_TPACCO = T5I.T5I_TPACCO "
				cQuery += "  AND T5J.D_E_L_E_T_ = '' "

				cQuery += " INNER JOIN " + RetSqlName( "T5Q" ) + " T5Q "
				cQuery += "  ON T5Q.T5Q_FILIAL = T5J.T5J_FILIAL "
				cQuery += "  AND T5Q.T5Q_ID = T5J.T5J_ID "
				cQuery += "  AND T5Q.T5Q_VERSAO = T5J.T5J_VERSAO "
				cQuery += "  AND T5Q.T5Q_IDEDMD = T5J.T5J_IDEDMD "
				cQuery += "  AND T5Q.T5Q_DTACCO = T5J.T5J_DTACCO "
				cQuery += "  AND T5Q.T5Q_TPACCO = T5J.T5J_TPACCO "
				cQuery += "  AND T5Q.T5Q_PERREF = T5J.T5J_PERREF "
				cQuery += "  AND T5Q.D_E_L_E_T_ = '' "

				cQuery += " INNER JOIN " + RetSqlName( "T5S" ) + " T5S "
				cQuery += "   ON T5S.T5S_FILIAL = T5Q.T5Q_FILIAL "
				cQuery += "  AND T5S.T5S_ID = T5Q.T5Q_ID "
				cQuery += "  AND T5S.T5S_VERSAO = T5Q.T5Q_VERSAO "
				cQuery += "  AND T5S.T5S_IDEDMD = T5Q.T5Q_IDEDMD "
				cQuery += "  AND T5S.T5S_DTACCO = T5Q.T5Q_DTACCO "
				cQuery += "  AND T5S.T5S_TPACCO = T5Q.T5Q_TPACCO "
				cQuery += "  AND T5S.T5S_PERREF = T5Q.T5Q_PERREF "
				cQuery += "  AND T5S.T5S_ESTABE = T5Q.T5Q_ESTABE "
				cQuery += "  AND T5S.T5S_LOTTRB = T5Q.T5Q_LOTTRB "
				cQuery += "  AND T5S.D_E_L_E_T_ = '' "

				//Filtro por CPF
				If !Empty( cParamCPF )

					cQuery += " INNER JOIN " + RetSqlName( "C9V" ) + " C9V "
					cQuery += "   ON C9V.C9V_FILIAL = CMD.CMD_FILIAL "
					cQuery += "  AND C9V.C9V_ID = CMD.CMD_FUNC "
					cQuery += "  AND C9V.C9V_CPF = '" + AllTrim( cParamCPF ) + "' "
					cQuery += "  AND C9V.D_E_L_E_T_ = ' ' "

				EndIf

				cQuery += " LEFT JOIN " + RetSqlName( "C8R" ) + " C8R "
				cQuery += "  ON C8R.C8R_FILIAL = '" + xFilial( "C8R" ) + "' "
				cQuery += " AND C8R.C8R_ID = T5S.T5S_CODRUB "
				cQuery += " AND C8R.C8R_ATIVO = '1' "
				cQuery += " AND C8R.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C89" ) + " C89 "
				cQuery += "  ON C89.C89_FILIAL = '" + xFilial( "C89" ) + "' "
				cQuery += " AND C89.C89_ID = C8R.C8R_NATRUB "
				cQuery += " AND C89.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C8T" ) + " C8T "
				cQuery += "  ON C8T.C8T_FILIAL = '" + xFilial( "C8T" ) + "' "
				cQuery += " AND C8T.C8T_ID = C8R.C8R_CINTPS "
				cQuery += " AND C8T.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C8U" ) + " C8U "
				cQuery += "  ON C8U.C8U_FILIAL = '" + xFilial( "C8U" ) + "' "
				cQuery += " AND C8U.C8U_ID = C8R.C8R_CINTPS "
				cQuery += " AND C8U.D_E_L_E_T_ = '' "

				cQuery += " WHERE CMD.CMD_FILIAL = '" + xFilial( "CMD" ) + "' "

				If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"
					cQuery += "  AND SUBSTR( CMD.CMD_DTDESL, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
				Else
					cQuery += "  AND SUBSTRING( CMD.CMD_DTDESL, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
				EndIf

				cQuery += " AND CMD.CMD_ATIVO = '1' "
				cQuery += " AND CMD.CMD_EVENTO <> 'E' "
				cQuery += " AND CMD.D_E_L_E_T_ = '' "
				cQuery += " ORDER BY CMD_FILIAL, CMD_ID, CMD_VERSAO, CMD_DTDESL, ESTABE, LOTTRB "

				cQuery := ChangeQuery( cQuery )

				TCQuery cQuery New Alias (cAliasQry)

				( cAliasQry )->( DBGoTop() )

				While ( cAliasQry )->( !Eof() )

					cFilQry		:=	( cAliasQry )->CMD_FILIAL
					cID			:=	( cAliasQry )->CMD_ID
					cVersao		:=	( cAliasQry )->CMD_VERSAO
					cIDEstab	:=	( cAliasQry )->ESTABE
					cIDLotac	:=	( cAliasQry )->LOTTRB
					cIDTrabal	:=	( cAliasQry )->CMD_FUNC
					cPerApu		:=	SubStr( StrTran( ( cAliasQry )->CMD_DTDESL, "-", "" ), 1, 4 ) + SubStr( StrTran( ( cAliasQry )->CMD_DTDESL, "-", "" ), 5, 2 )
					cRecibo		:=	( cAliasQry )->CMD_PROTUL
					nRecnoQry	:=	( cAliasQry )->CMD_RECONHECIMENTO

					C9V->( MsSeek( xFilial( "C9V" ) + cIDTrabal + "1" ) )

					cCodCat := GetCodCat( C9V->C9V_NOMEVE, C9V->C9V_FILIAL, C9V->C9V_ID, cPeriodo )

					If C9V->C9V_NOMEVE == "S2200"

						If Empty( cCodCat )
							CUP->( MsSeek( xFilial( "CUP" ) + C9V->( C9V_ID + C9V_VERSAO + C9V_NOMEVE ) ) )
							cCodCat := CUP->CUP_CODCAT
						EndIf

						C87->( MsSeek( xFilial( "C87" ) + cCodCat ) )

					ElseIf C9V->C9V_NOMEVE == "S2300"

						If Empty( cCodCat )
							cCodCat := C9V->C9V_CATCI
						EndIf

						C87->( MsSeek( xFilial( "C87" ) + cCodCat ) )

					EndIf

					C92->( MsSeek( xFilial( "C92" ) + cIDEstab + "1" ) )
					C99->( MsSeek( xFilial( "C99" ) + cIDLotac + "1" ) )

					cTipoEstab	:=	C92->C92_TPINSC
					cEstab		:=	C92->C92_NRINSC
					cLotacao	:=	C99->C99_CODIGO
					cCPF		:=	C9V->C9V_CPF
					cNome		:=	C9V->C9V_NOME
					cMatric		:=	C9V->C9V_MATRIC
					cCodCat		:=	C87->C87_CODIGO

					While ( cAliasQry )->( CMD_FILIAL + CMD_ID + CMD_VERSAO + ESTABE + LOTTRB ) == cFilQry + cID + cVersao + cIDEstab + cIDLotac

						cNatureza	:=	AllTrim( ( cAliasQry )->C89_CODIGO )
						cTipo		:=	AllTrim( ( cAliasQry )->C8R_INDTRB )
						cIncidCP	:=	AllTrim( ( cAliasQry )->C8T_CODIGO )
						cIncidIRRF	:=	AllTrim( ( cAliasQry )->C8U_CODIGO )
						cIncidFGTS	:=	AllTrim( ( cAliasQry )->C8R_CINTFG )

						aAdd( aAnalitico, Array( 16 ) )
						nPosValores := Len( aAnalitico )

						aAnalitico[nPosValores][ANALITICO_MATRICULA]			:=	AllTrim( cMatric )
						aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:=	AllTrim( cCodCat )
						aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:=	AllTrim( cTipoEstab )
						aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:=	AllTrim( cEstab )
						aAnalitico[nPosValores][ANALITICO_LOTACAO]				:=	AllTrim( cLotacao )
						aAnalitico[nPosValores][ANALITICO_NATUREZA]				:=	AllTrim( cNatureza )
						aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:=	AllTrim( cTipo )
						aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:=	AllTrim( cIncidCP )
						aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:=	AllTrim( cIncidIRRF )
						aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:=	AllTrim( cIncidFGTS )
						aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:=	""
						aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:=	""
						aAnalitico[nPosValores][ANALITICO_VALOR]				:=	( cAliasQry )->VLRRUB

						( cAliasQry )->( DBSkip() )

					EndDo

					If ( cAliasQry )->( CMD_FILIAL + CMD_ID + CMD_VERSAO ) <> cFilQry + cID + cVersao
						InfoRPTObj("1", cPerApu, cCPF, cNome, aAnalitico,, @oInfoRPT)

						oReport:UpSert("S-2299", "2", cFilQry, oInfoRPT)

						If lProtheus
							InfoRPTObj("1", cPerApu, cCPF, cNome, aAnalitico,, @oInfoRPT)

							oReport:UpSert("S-2299", "1", cFilQry, oInfoRPT)
						Else
							InsOrigCMD( cFilQry, nRecnoQry )
						EndIf

						Insert5003( "S-2299", cFilQry, cPeriodo, cCPF, cRecibo, cFilMatriz )

						nQtdProc ++

						If !lCallExternal
							SetIncPerc( oRunCharge, "S-2299", nQtdTotal, nQtdProc )
						EndIf

						aAnalitico := {}

					EndIf

					cFilQry		:=	""
					cID			:=	""
					cVersao		:=	""
					cIDEstab	:=	""
					cIDLotac	:=	""
					cIDTrabal	:=	""
					cPerApu		:=	""
					cRecibo		:=	""
					cTipoEstab	:=	""
					cEstab		:=	""
					cLotacao	:=	""
					cCPF		:=	""
					cNome		:=	""
					cMatric		:=	""
					cCodCat		:=	""
					cNatureza	:=	""
					cTipo		:=	""
					cIncidCP	:=	""
					cIncidIRRF	:=	""
					cIncidFGTS	:=	""
					nRecnoQry	:=	0

				EndDo

				( cAliasQry )->( DBCloseArea() )

			Next nI

			cFilAnt := cFilBkp

		Else

			nQtdProc ++

			If !lCallExternal
				SetIncPerc( oRunCharge, "S-2299", nQtdTotal, nQtdProc )
			EndIf

		EndIf
	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} InsOrigCMD
@type			function
@description	Função responsável por coletar as informações do Evento S-2299 no XML de entrada.
@author			Felipe C. Seolin
@since			15/07/2019
@version		1.0
@param			cFilEvt	-	Filial do registro do evento S-2299 no TAF
@param			nRecno	-	Recno do registro do evento S-2299 no TAF
/*/
//---------------------------------------------------------------------
Static Function InsOrigCMD( cFilEvt, nRecno )

	Local oInfoRPT    := Nil
	Local oXml        := Nil
	Local cAliasQry   := GetNextAlias()
	Local cQuery      := ""
	Local cXml        := ""
	Local cPerApu     := ""
	Local cDtDeslig   := ""
	Local cCPF        := ""
	Local cNome       := ""
	Local cMatric     := ""
	Local cCodCat     := ""
	Local cT06Path    := ""
	Local cT3GPath    := ""
	Local cT05Path    := ""
	Local cT5IPath    := ""
	Local cT5JPath    := ""
	Local cT5QPath    := ""
	Local cT5SPath    := ""
	Local nT06        := 0
	Local nT3G        := 0
	Local nT05        := 0
	Local nT5I        := 0
	Local nT5J        := 0
	Local nT5Q        := 0
	Local nT5S        := 0
	Local nC9VCPF     := TamSX3( "C9V_CPF" )[1]
	Local nC9VMATRIC  := TamSX3( "C9V_MATRIC" )[1]
	Local nPosValores := 0
	Local aAnalitico  := {}
	Local aRubrica    := {}
	Local aAreaC1E    := C1E->( GetArea() )
	Local aAreaC9V    := C9V->( GetArea() )
	Local aAreaCUP    := CUP->( GetArea() )
	Local aAreaC87    := C87->( GetArea() )
	Local aAreaC8R    := C8R->( GetArea() )

	C1E->( DBSetOrder( 3 ) ) //C1E_FILIAL, C1E_FILTAF, C1E_ATIVO, R_E_C_N_O_, D_E_L_E_T_
	C1E->( MsSeek( xFilial( "C1E" ) + cFilEvt + "1" ) )

	cQuery := " SELECT TAFST2.R_E_C_N_O_ TAFST2_RECONHECIMENTO "
	cQuery += " FROM TAFXERP TAFXERP "
	cQuery += " INNER JOIN TAFST2 TAFST2 "
	cQuery += "   ON TAFST2.TAFTICKET = TAFXERP.TAFTICKET "
	cQuery += "  AND TAFST2.TAFKEY = TAFXERP.TAFKEY "
	cQuery += "  AND TAFST2.TAFFIL = '" + C1E->C1E_CODFIL + "' "
	cQuery += "  AND TAFST2.D_E_L_E_T_ = '' "
	cQuery += " WHERE TAFXERP.TAFALIAS = 'CMD' "
	cQuery += "  AND TAFXERP.TAFRECNO = '" + cValToChar( nRecno ) + "' "
	cQuery += "  AND TAFXERP.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY TAFXERP.R_E_C_N_O_ DESC "

	cQuery := ChangeQuery( cQuery )

	TCQuery cQuery New Alias (cAliasQry)

	( cAliasQry )->( DBGoTop() )

	If ( cAliasQry )->( !Eof() )

		C9V->( DBSetOrder( 10 ) ) //C9V_FILIAL, C9V_CPF, C9V_MATRIC, C9V_NOMEVE, C9V_ATIVO, R_E_C_N_O_, D_E_L_E_T_
		CUP->( DBSetOrder( 4 ) ) //CUP_FILIAL, CUP_ID, CUP_VERSAO, CUP_NOMEVE, CUP_MATRIC, R_E_C_N_O_, D_E_L_E_T_
		C87->( DBSetOrder( 1 ) ) //C87_FILIAL, C87_ID, C87_VALIDA, R_E_C_N_O_, D_E_L_E_T_

		( cST2Alias )->( DBGoTo( ( cAliasQry )->TAFST2_RECONHECIMENTO ) )

		cXml := ( cST2Alias )->TAFMSG

		//Tiro os espaços em branco no início e final do XML e armazeno na variável
		cXml := EncodeUTF8( AllTrim( cXml ) )

		//Instancia objeto em oXml
		oXml := TXmlManager():New()

		If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"

			cXml := StrTran( cXml, Chr( 13 ), "" )
			cXml := StrTran( cXml, Chr( 10 ), "" )

			//Tratamento para integração Oracle onde o XML vem com o último caracter faltando
			If SubStr( AllTrim( cXml ), Len( cXml ), 1 ) <> ">"
				cXml += ">"
			EndIf

		EndIf

		If !Empty( cXml ) .and. oXml:Parse( FTrocaPath( cXml, "eSocial" ) )
			oXml:bDecodeUTF8 := .T.
		EndIf

		cDtDeslig	:=	oXml:xPathGetNodeValue( "/eSocial/evtDeslig/infoDeslig/dtDeslig" )
		cPerApu		:=	SubStr( StrTran( cDtDeslig, "-", "" ), 1, 4 ) + SubStr( StrTran( cDtDeslig, "-", "" ), 5, 2 )
		cCPF		:=	oXml:xPathGetNodeValue( "/eSocial/evtDeslig/ideVinculo/cpfTrab" )
		cMatric		:=	oXml:xPathGetNodeValue( "/eSocial/evtDeslig/ideVinculo/matricula" )

		If C9V->( MsSeek( xFilial( "C9V" ) + PadR( cCPF, nC9VCPF ) + PadR( cMatric, nC9VMATRIC ) + "S2200" + "1" ) )

			cNome := C9V->C9V_NOME

			If CUP->( MsSeek( xFilial( "CUP" ) + C9V->( C9V_ID + C9V_VERSAO + C9V_NOMEVE ) ) )
				If C87->( MsSeek( xFilial( "C87" ) + CUP->CUP_CODCAT ) )
					cCodCat := C87->C87_CODIGO
				EndIf
			EndIf

		EndIf

		//T06 - Informações do Recibo de Pagamento
		nT06 := 1
		cT06Path := "/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev[" + cValToChar( nT06 ) + "]"

		While oXml:xPathHasNode( cT06Path )

			//Informações do Período de Apuração
			//T3G - Informações do Estabelecimento/Lotação
			nT3G := 1
			cT3GPath := cT06Path + "/infoPerApur/ideEstabLot[" + cValToChar( nT3G ) + "]"

			While oXml:xPathHasNode( cT3GPath )

				//T05 - Informações das Rubricas
				nT05 := 1
				cT05Path := cT3GPath + "/detVerbas[" + cValToChar( nT05 ) + "]"

				While oXml:xPathHasNode( cT05Path )

					aRubrica := oReport:GetRubrica( oXml:xPathGetNodeValue( cT05Path + "/codRubr" ), TAFIDTabRub( oXml:xPathGetNodeValue( cT05Path + "/ideTabRubr" ), "T3M", oXml:xPathGetNodeValue( cT05Path + "/codRubr" )) )

					aAdd( aAnalitico, Array( 16 ) )
					nPosValores := Len( aAnalitico )

					aAnalitico[nPosValores][ANALITICO_MATRICULA]			:=	AllTrim( cMatric )
					aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:=	AllTrim( cCodCat )
					aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:=	AllTrim( oXml:xPathGetNodeValue( cT3GPath + "/tpInsc" ) )
					aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:=	AllTrim( oXml:xPathGetNodeValue( cT3GPath + "/nrInsc" ) )
					aAnalitico[nPosValores][ANALITICO_LOTACAO]				:=	AllTrim( oXml:xPathGetNodeValue( cT3GPath + "/codLotacao" ) )
					aAnalitico[nPosValores][ANALITICO_NATUREZA]				:=	AllTrim( aRubrica[1] ) //Natureza
					aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:=	AllTrim( aRubrica[2] ) //Tipo
					aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:=	AllTrim( aRubrica[3] ) //Incidência CP
					aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:=	AllTrim( aRubrica[4] ) //Incidência IRRF
					aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:=	AllTrim( aRubrica[5] ) //Incidência FGTS
					aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:=	""
					aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:=	""
					aAnalitico[nPosValores][ANALITICO_VALOR]				:=	Val(StrTran(oXml:xPathGetNodeValue(cT05Path + "/vrRubr"), ",", "."))

					nT05 ++
					cT05Path := cT3GPath + "/detVerbas[" + cValToChar( nT05 ) + "]"

				EndDo

				nT3G ++
				cT3GPath := cT06Path + "/infoPerApur/ideEstabLot[" + cValToChar( nT3G ) + "]"

			EndDo

			//Informações do Período de Apuração Anterior
			//T5I - Informações do Acordo
			nT5I := 1
			cT5IPath := cT06Path + "/infoPerAnt/ideADC[" + cValToChar( nT5I ) + "]"

			While oXml:xPathHasNode( cT5IPath )

				//T5J - Identificação do Período de Referência
				nT5J := 1
				cT5JPath := cT5IPath + "/idePeriodo[" + cValToChar( nT5J ) + "]"

				While oXml:xPathHasNode( cT5JPath )

					//T5Q - Informações do Estabelecimento/Lotacão
					nT5Q := 1
					cT5QPath := cT5JPath + "/ideEstabLot[" + cValToChar( nT5Q ) + "]"

					While oXml:xPathHasNode( cT5QPath )

						//T5S - Itens da Remuneração
						nT5S := 1
						cT5SPath := cT5QPath + "/detVerbas[" + cValToChar( nT5S ) + "]"

						While oXml:xPathHasNode( cT5SPath )
							aRubrica := oReport:GetRubrica( oXml:xPathGetNodeValue( cT5SPath + "/codRubr" ), TAFIDTabRub( oXml:xPathGetNodeValue( cT5SPath + "/ideTabRubr" ), "T3M", oXml:xPathGetNodeValue( cT5SPath + "/codRubr" )) )

							aAdd( aAnalitico, Array( 16 ) )
							nPosValores := Len( aAnalitico )

							aAnalitico[nPosValores][ANALITICO_MATRICULA]			:=	AllTrim( cMatric )
							aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:=	AllTrim( cCodCat )
							aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:=	AllTrim( oXml:xPathGetNodeValue( cT5QPath + "/tpInsc" ) )
							aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:=	AllTrim( oXml:xPathGetNodeValue( cT5QPath + "/nrInsc" ) )
							aAnalitico[nPosValores][ANALITICO_LOTACAO]				:=	AllTrim( oXml:xPathGetNodeValue( cT5QPath + "/codLotacao" ) )
							aAnalitico[nPosValores][ANALITICO_NATUREZA]				:=	AllTrim( aRubrica[1] ) //Natureza
							aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:=	AllTrim( aRubrica[2] ) //Tipo
							aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:=	AllTrim( aRubrica[3] ) //Incidência CP
							aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:=	AllTrim( aRubrica[4] ) //Incidência IRRF
							aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:=	AllTrim( aRubrica[5] ) //Incidência FGTS
							aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:=	""
							aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:=	""
							aAnalitico[nPosValores][ANALITICO_VALOR]				:=	Val(StrTran(oXml:xPathGetNodeValue(cT5SPath + "/vrRubr"), ",", "."))

							nT5S ++
							cT5SPath := cT5QPath + "/detVerbas[" + cValToChar( nT5S ) + "]"

						EndDo

						nT5Q ++
						cT5QPath := cT5JPath + "/ideEstabLot[" + cValToChar( nT5Q ) + "]"

					EndDo

					nT5J ++
					cT5JPath := cT5IPath + "/idePeriodo[" + cValToChar( nT5J ) + "]"

				EndDo

				nT5I ++
				cT5IPath := cT06Path + "/infoPerAnt/ideADC[" + cValToChar( nT5I ) + "]"

			EndDo

			nT06 ++
			cT06Path := "/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev[" + cValToChar( nT06 ) + "]"

		EndDo

		InfoRPTObj("1", cPerApu, AllTrim(cCPF),	AllTrim(cNome), aAnalitico,, @oInfoRPT)

		oReport:UpSert("S-2299", "1", cFilEvt, oInfoRPT)
	EndIf

	( cAliasQry )->( DBCloseArea() )

	RestArea( aAreaC1E )
	RestArea( aAreaC9V )
	RestArea( aAreaCUP )
	RestArea( aAreaC87 )
	RestArea( aAreaC8R )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} DataS2399
@type			function
@description	Função responsável por coletar as informações do Evento S-2399 no TAF.
@author			Felipe C. Seolin
@since			17/07/2019
@version		1.0
@param			oRunCharge		-	Objeto do FWMsgRun
@param			lCallExternal	-	Indica se a chamada é externa ao menu do TAF
@param			cPeriodo		-	Período de referência das informações
@param			aFilial			-	Filiais selecionadas para processamento
@param			cParamCPF		-	CPF selecionado como filtro de processamento
@param			lProtheus		-	Indica se a Origem dos dados parte do Protheus
@param			cFilMatriz		-	Filial Matriz
/*/
//---------------------------------------------------------------------
Static Function DataS2399( oRunCharge, lCallExternal, cPeriodo, aFilial, cParamCPF, lProtheus, cFilMatriz )

	Local oInfoRPT    := Nil
	Local cAliasQry   := ""
	Local cQuery      := ""
	Local cFilBkp     := ""
	Local cFilQry     := ""
	Local cID         := ""
	Local cVersao     := ""
	Local cIDEstab    := ""
	Local cIDLotac    := ""
	Local cIDTrabal   := ""
	Local cPerApu     := ""
	Local cRecibo     := ""
	Local cTipoEstab  := ""
	Local cEstab      := ""
	Local cLotacao    := ""
	Local cCPF        := ""
	Local cNome       := ""
	Local cMatric     := ""
	Local cCodCat     := ""
	Local cNatureza   := ""
	Local cTipo       := ""
	Local cIncidCP    := ""
	Local cIncidIRRF  := ""
	Local cIncidFGTS  := ""
	Local nRecnoQry   := 0
	Local nQtdTotal   := 0
	Local nQtdProc    := 0
	Local nI          := 0
	Local nPosValores := 0
	Local aAnalitico  := {}

	If !Empty( aFilial )

		cAliasQry := GetNextAlias()

		cQuery := "SELECT COUNT(*) QUANTIDADE "
		cQuery += "FROM " + RetSqlName( "T92" ) + " T92 "
		cQuery += "WHERE T92.T92_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "

		If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"
			cQuery += "  AND SUBSTR( T92.T92_DTERAV, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
		Else
			cQuery += "  AND SUBSTRING( T92.T92_DTERAV, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
		EndIf

		cQuery += "  AND EXISTS (	SELECT CMK.R_E_C_N_O_ "
		cQuery += "					FROM " + RetSqlName( "CMK" ) + " CMK "
		cQuery += "					WHERE CMK.CMK_FILIAL = T92.T92_FILIAL "
		cQuery += "					  AND CMK.CMK_ID = T92.T92_ID "
		cQuery += "					  AND CMK.CMK_VERSAO = T92.T92_VERSAO "
		cQuery += "					  AND CMK.D_E_L_E_T_ = '' ) "

		//Filtro por CPF
		If !Empty( cParamCPF )

			cQuery += "  AND EXISTS (	SELECT C9V.R_E_C_N_O_ "
			cQuery += "					FROM " + RetSqlName( "C9V" ) + " C9V "
			cQuery += "					WHERE C9V.C9V_FILIAL = T92.T92_FILIAL "
			cQuery += "					  AND C9V.C9V_ID = T92.T92_TRABAL "
			cQuery += "					  AND C9V.C9V_CPF = '" + AllTrim( cParamCPF ) + "' "
			cQuery += "					  AND C9V.D_E_L_E_T_ = ' ' ) "

		EndIf

		cQuery += "  AND T92.T92_ATIVO = '1' "
		cQuery += "  AND T92.T92_EVENTO <> 'E' "
		cQuery += "  AND T92.D_E_L_E_T_ = '' "

		cQuery := ChangeQuery( cQuery )

		TCQuery cQuery New Alias (cAliasQry)

		( cAliasQry )->( DBGoTop() )

		If ( cAliasQry )->( !Eof() )
			nQtdTotal := ( cAliasQry )->QUANTIDADE
		EndIf

		( cAliasQry )->( DBCloseArea() )

		If nQtdTotal > 0

			//Tabelas com as informações do Trabalhador
			C9V->( DBSetOrder( 2 ) ) //C9V_FILIAL, C9V_ID, C9V_ATIVO, R_E_C_N_O_, D_E_L_E_T_
			C87->( DBSetOrder( 1 ) ) //C87_FILIAL, C87_ID, C87_VALIDA, R_E_C_N_O_, D_E_L_E_T_

			//Tabela com as informações do Estabelecimento
			C92->( DBSetOrder( 5 ) ) //C92_FILIAL, C92_ID, C92_ATIVO, R_E_C_N_O_, D_E_L_E_T_

			//Tabela com as informações da Lotação
			C99->( DBSetOrder( 4 ) ) //C99_FILIAL, C99_ID, C99_ATIVO, R_E_C_N_O_, D_E_L_E_T_

			cFilBkp := cFilAnt

			For nI := 1 to Len( aFilial )

				cFilAnt := aFilial[nI]

				cAliasQry := GetNextAlias()

				cQuery := " SELECT DISTINCT T92.R_E_C_N_O_ T92_RECONHECIMENTO, T92.T92_FILIAL, T92.T92_ID, T92.T92_VERSAO, T92.T92_DTERAV, T92.T92_TRABAL, T92.T92_PROTUL "
				cQuery += "     , T3J.T3J_ESTABE, T3J.T3J_LOTTRB "
				cQuery += "     , C89.C89_CODIGO, C8R.C8R_INDTRB, C8T.C8T_CODIGO, C8U.C8U_CODIGO, C8R.C8R_CINTFG "
				cQuery += "     , CMK.CMK_VLRRUB, CMK.R_E_C_N_O_ CMK_RECONHECIMENTO "

				cQuery += " FROM " + RetSqlName( "T92" ) + " T92 "

				cQuery += " INNER JOIN " + RetSqlName( "T3I" ) + " T3I "
				cQuery += "   ON T3I.T3I_FILIAL = T92.T92_FILIAL "
				cQuery += "  AND T3I.T3I_ID = T92.T92_ID "
				cQuery += "  AND T3I.T3I_VERSAO = T92.T92_VERSAO "
				cQuery += "  AND T3I.D_E_L_E_T_ = '' "

				cQuery += " INNER JOIN " + RetSqlName( "T3J" ) + " T3J "
				cQuery += "   ON T3J.T3J_FILIAL = T3I.T3I_FILIAL "
				cQuery += "  AND T3J.T3J_ID = T3I.T3I_ID "
				cQuery += "  AND T3J.T3J_VERSAO = T3I.T3I_VERSAO "
				cQuery += "  AND T3J.T3J_IDEDMD = T3I.T3I_IDEDMD "
				cQuery += "  AND T3J.D_E_L_E_T_ = '' "

				cQuery += " INNER JOIN " + RetSqlName( "CMK" ) + " CMK "
				cQuery += "   ON CMK.CMK_FILIAL = T3J.T3J_FILIAL "
				cQuery += "  AND CMK.CMK_ID = T3J.T3J_ID "
				cQuery += "  AND CMK.CMK_VERSAO = T3J.T3J_VERSAO "
				cQuery += "  AND CMK.CMK_IDEDMD = T3J.T3J_IDEDMD "
				cQuery += "  AND CMK.CMK_ESTABE = T3J.T3J_ESTABE "
				cQuery += "  AND CMK.CMK_LOTTRB = T3J.T3J_LOTTRB "
				cQuery += "  AND CMK.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C8R" ) + " C8R "
				cQuery += "  ON C8R.C8R_FILIAL = '" + xFilial( "C8R" ) + "' "
				cQuery += " AND C8R.C8R_ID = CMK.CMK_CODRUB "
				cQuery += " AND C8R.C8R_ATIVO = '1' "
				cQuery += " AND C8R.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C89" ) + " C89 "
				cQuery += "  ON C89.C89_FILIAL = '" + xFilial( "C89" ) + "' "
				cQuery += " AND C89.C89_ID = C8R.C8R_NATRUB "
				cQuery += " AND C89.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C8T" ) + " C8T "
				cQuery += "  ON C8T.C8T_FILIAL = '" + xFilial( "C8T" ) + "' "
				cQuery += " AND C8T.C8T_ID = C8R.C8R_CINTPS "
				cQuery += " AND C8T.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C8U" ) + " C8U "
				cQuery += "  ON C8U.C8U_FILIAL = '" + xFilial( "C8U" ) + "' "
				cQuery += " AND C8U.C8U_ID = C8R.C8R_CINTIR "
				cQuery += " AND C8U.D_E_L_E_T_ = '' "

				cQuery += " WHERE T92.T92_FILIAL = '" + xFilial( "T92" ) + "' "

				If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"
					cQuery += "  AND SUBSTR( T92.T92_DTERAV, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
				Else
					cQuery += "  AND SUBSTRING( T92.T92_DTERAV, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
				EndIf

				cQuery += "  AND T92.T92_ATIVO = '1' "
				cQuery += "  AND T92.T92_EVENTO <> 'E' "
				cQuery += "  AND T92.D_E_L_E_T_ = '' "

				cQuery += " ORDER BY T92.T92_FILIAL, T92.T92_ID, T92.T92_VERSAO, T92.T92_DTERAV, T3J.T3J_ESTABE, T3J.T3J_LOTTRB "

				cQuery := ChangeQuery( cQuery )

				TCQuery cQuery New Alias (cAliasQry)

				( cAliasQry )->( DBGoTop() )

				While ( cAliasQry )->( !Eof() )

					cFilQry		:=	( cAliasQry )->T92_FILIAL
					cID			:=	( cAliasQry )->T92_ID
					cVersao		:=	( cAliasQry )->T92_VERSAO
					cIDEstab	:=	( cAliasQry )->T3J_ESTABE
					cIDLotac	:=	( cAliasQry )->T3J_LOTTRB
					cIDTrabal	:=	( cAliasQry )->T92_TRABAL
					cPerApu		:=	SubStr( StrTran( ( cAliasQry )->T92_DTERAV, "-", "" ), 1, 4 ) + SubStr( StrTran( ( cAliasQry )->T92_DTERAV, "-", "" ), 5, 2 )
					cRecibo		:=	( cAliasQry )->T92_PROTUL
					nRecnoQry	:=	( cAliasQry )->T92_RECONHECIMENTO

					C9V->( MsSeek( xFilial( "C9V" ) + cIDTrabal + "1" ) )

					cCodCat := GetCodCat( C9V->C9V_NOMEVE, C9V->C9V_FILIAL, C9V->C9V_ID, cPeriodo )

					If Empty( cCodCat )
						cCodCat := C9V->C9V_CATCI
					EndIf

					C87->( MsSeek( xFilial( "C87" ) + cCodCat ) )
					C92->( MsSeek( xFilial( "C92" ) + cIDEstab + "1" ) )
					C99->( MsSeek( xFilial( "C99" ) + cIDLotac + "1" ) )

					cTipoEstab	:=	C92->C92_TPINSC
					cEstab		:=	C92->C92_NRINSC
					cLotacao	:=	C99->C99_CODIGO
					cCPF		:=	C9V->C9V_CPF
					cNome		:=	C9V->C9V_NOME
					cMatric		:=	IIF(Empty(C9V->C9V_MATRIC),C9V->C9V_MATTSV,C9V->C9V_MATRIC)
					cCodCat		:=	C87->C87_CODIGO

					While ( cAliasQry )->( T92_FILIAL + T92_ID + T92_VERSAO + T3J_ESTABE + T3J_LOTTRB ) == cFilQry + cID + cVersao + cIDEstab + cIDLotac

						cNatureza	:=	AllTrim( ( cAliasQry )->C89_CODIGO )
						cTipo		:=	AllTrim( ( cAliasQry )->C8R_INDTRB )
						cIncidCP	:=	AllTrim( ( cAliasQry )->C8T_CODIGO )
						cIncidIRRF	:=	AllTrim( ( cAliasQry )->C8U_CODIGO )
						cIncidFGTS	:=	AllTrim( ( cAliasQry )->C8R_CINTFG )

						aAdd( aAnalitico, Array( 16 ) )
						nPosValores := Len( aAnalitico )

						aAnalitico[nPosValores][ANALITICO_MATRICULA]			:=	AllTrim( cMatric )
						aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:=	AllTrim( cCodCat )
						aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:=	AllTrim( cTipoEstab )
						aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:=	AllTrim( cEstab )
						aAnalitico[nPosValores][ANALITICO_LOTACAO]				:=	AllTrim( cLotacao )
						aAnalitico[nPosValores][ANALITICO_NATUREZA]				:=	AllTrim( cNatureza )
						aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:=	AllTrim( cTipo )
						aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:=	AllTrim( cIncidCP )
						aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:=	AllTrim( cIncidIRRF )
						aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:=	AllTrim( cIncidFGTS )
						aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:=	""
						aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:=	""
						aAnalitico[nPosValores][ANALITICO_VALOR]				:=	( cAliasQry )->CMK_VLRRUB

						( cAliasQry )->( DBSkip() )

					EndDo

					If ( cAliasQry )->( T92_FILIAL + T92_ID + T92_VERSAO ) <> cFilQry + cID + cVersao
						InfoRPTObj("1", cPerApu, cCPF, cNome, aAnalitico,, @oInfoRPT)

						oReport:UpSert("S-2399", "2", cFilQry, oInfoRPT)

						If lProtheus
							InfoRPTObj("1", cPerApu, cCPF, cNome, aAnalitico,, @oInfoRPT)

							oReport:UpSert("S-2399", "1", cFilQry, oInfoRPT)
						Else
							InsOrigT92( cFilQry, nRecnoQry )
						EndIf

						Insert5003( "S-2399", cFilQry, cPeriodo, cCPF, cRecibo, cFilMatriz )

						nQtdProc ++

						If !lCallExternal
							SetIncPerc( oRunCharge, "S-2399", nQtdTotal, nQtdProc )
						EndIf

						aAnalitico := {}

					EndIf

					cFilQry		:=	""
					cID			:=	""
					cVersao		:=	""
					cIDEstab	:=	""
					cIDLotac	:=	""
					cIDTrabal	:=	""
					cPerApu		:=	""
					cRecibo		:=	""
					cTipoEstab	:=	""
					cEstab		:=	""
					cLotacao	:=	""
					cCPF		:=	""
					cNome		:=	""
					cMatric		:=	""
					cCodCat		:=	""
					cNatureza	:=	""
					cTipo		:=	""
					cIncidCP	:=	""
					cIncidIRRF	:=	""
					cIncidFGTS	:=	""
					nRecnoQry	:=	0
				EndDo

				( cAliasQry )->( DBCloseArea() )

			Next nI

			cFilAnt := cFilBkp

		Else

			nQtdProc ++

			If !lCallExternal
				SetIncPerc( oRunCharge, "S-2399", nQtdTotal, nQtdProc )
			EndIf

		EndIf

	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} InsOrigT92
@type			function
@description	Função responsável por coletar as informações do Evento S-2399 no XML de entrada.
@author			Felipe C. Seolin
@since			17/07/2019
@version		1.0
@param			cFilEvt	-	Filial do registro do evento S-2399 no TAF
@param			nRecno	-	Recno do registro do evento S-2399 no TAF
/*/
//---------------------------------------------------------------------
Static Function InsOrigT92( cFilEvt, nRecno )

	Local oInfoRPT    := Nil
	Local oXml        := Nil
	Local cAliasQry   := GetNextAlias()
	Local cQuery      := ""
	Local cXml        := ""
	Local cPerApu     := ""
	Local cDtTerm     := ""
	Local cCPF        := ""
	Local cNome       := ""
	Local cCodCat     := ""
	Local cT3IPath    := ""
	Local cT3JPath    := ""
	Local cCMKPath    := ""
	Local nT3I        := 0
	Local nT3J        := 0
	Local nCMK        := 0
	Local nC9VCPF     := TamSX3( "C9V_CPF" )[1]
	Local nC9VCATCI   := TamSX3( "C9V_CATCI" )[1]
	Local nPosValores := 0
	Local aAnalitico  := {}
	Local aRubrica    := {}
	Local aAreaC1E    := C1E->( GetArea() )
	Local aAreaC9V    := C9V->( GetArea() )
	Local aAreaC87    := C87->( GetArea() )
	Local aAreaC8R    := C8R->( GetArea() )

	C1E->( DBSetOrder( 3 ) ) //C1E_FILIAL, C1E_FILTAF, C1E_ATIVO, R_E_C_N_O_, D_E_L_E_T_
	C1E->( MsSeek( xFilial( "C1E" ) + cFilEvt + "1" ) )

	cQuery := " SELECT TAFST2.R_E_C_N_O_ TAFST2_RECONHECIMENTO "
	cQuery += " FROM TAFXERP TAFXERP "
	cQuery += " INNER JOIN TAFST2 TAFST2 "
	cQuery += "   ON TAFST2.TAFTICKET = TAFXERP.TAFTICKET "
	cQuery += "  AND TAFST2.TAFKEY = TAFXERP.TAFKEY "
	cQuery += "  AND TAFST2.TAFFIL = '" + C1E->C1E_CODFIL + "' "
	cQuery += "  AND TAFST2.D_E_L_E_T_ = '' "
	cQuery += " WHERE TAFXERP.TAFALIAS = 'T92' "
	cQuery += "  AND TAFXERP.TAFRECNO = '" + cValToChar( nRecno ) + "' "
	cQuery += "  AND TAFXERP.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY TAFXERP.R_E_C_N_O_ DESC "

	cQuery := ChangeQuery( cQuery )

	TCQuery cQuery New Alias (cAliasQry)

	( cAliasQry )->( DBGoTop() )

	If ( cAliasQry )->( !Eof() )

		C9V->( DBSetOrder( 19 ) ) //C9V_FILIAL, C9V_CPF, C9V_CATCI, C9V_NOMEVE, C9V_ATIVO, R_E_C_N_O_, D_E_L_E_T_

		( cST2Alias )->( DBGoTo( ( cAliasQry )->TAFST2_RECONHECIMENTO ) )

		cXml := ( cST2Alias )->TAFMSG

		//Tiro os espaços em branco no início e final do XML e armazeno na variável
		cXml := EncodeUTF8( AllTrim( cXml ) )

		//Instancia objeto em oXml
		oXml := TXmlManager():New()

		If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"

			cXml := StrTran( cXml, Chr( 13 ), "" )
			cXml := StrTran( cXml, Chr( 10 ), "" )

			//Tratamento para integração Oracle onde o XML vem com o último caracter faltando
			If SubStr( AllTrim( cXml ), Len( cXml ), 1 ) <> ">"
				cXml += ">"
			EndIf

		EndIf

		If !Empty( cXml ) .and. oXml:Parse( FTrocaPath( cXml, "eSocial" ) )
			oXml:bDecodeUTF8 := .T.
		EndIf

		cDtTerm	:=	oXml:xPathGetNodeValue( "/eSocial/evtTSVTermino/infoTSVTermino/dtTerm" )
		cPerApu	:=	SubStr( StrTran( cDtTerm, "-", "" ), 1, 4 ) + SubStr( StrTran( cDtTerm, "-", "" ), 5, 2 )
		cCPF	:=	oXml:xPathGetNodeValue( "/eSocial/evtTSVTermino/ideTrabSemVinculo/cpfTrab" )
		cCodCat :=	oXml:XPathGetNodeValue( "/eSocial/evtTSVTermino/ideTrabSemVinculo/codCateg" )

		If C9V->( MsSeek( xFilial( "C9V" ) + PadR( cCPF, nC9VCPF ) + PadR( Posicione( "C87", 2, xFilial( "C87" ) + cCodCat, "C87_ID" ), nC9VCATCI ) + "S2300" + "1" ) )
			cNome := C9V->C9V_NOME
		EndIf

		//T3I - Informações do Recibo de Pagamento
		nT3I := 1
		cT3IPath := "/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev[" + cValToChar( nT3I ) + "]"

		While oXml:xPathHasNode( cT3IPath )

			//T3J - Informações do Estabelecimento/Lotação
			nT3J := 1
			cT3JPath := cT3IPath + "/ideEstabLot[" + cValToChar( nT3J ) + "]"

			While oXml:xPathHasNode( cT3JPath )

				//CMK - Informações das Rubricas
				nCMK := 1
				cCMKPath := cT3JPath + "/detVerbas[" + cValToChar( nCMK ) + "]"

				While oXml:xPathHasNode( cCMKPath )

					aRubrica := oReport:GetRubrica( oXml:xPathGetNodeValue( cCMKPath + "/codRubr" ), TAFIDTabRub( oXml:xPathGetNodeValue( cCMKPath + "/ideTabRubr" ), "T3M", oXml:xPathGetNodeValue( cCMKPath + "/codRubr" )) )

					aAdd( aAnalitico, Array( 16 ) )
					nPosValores := Len( aAnalitico )

					aAnalitico[nPosValores][ANALITICO_MATRICULA]			:=	Iif( !lLaySimplif, "", AllTrim( oXml:xPathGetNodeValue( "/eSocial/evtTSVTermino/ideTrabSemVinculo/matricula" ) ) ) // Tratamento para a simplificação do e-Social
					aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:=	AllTrim( cCodCat )
					aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:=	AllTrim( oXml:xPathGetNodeValue( cT3JPath + "/tpInsc" ) )
					aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:=	AllTrim( oXml:xPathGetNodeValue( cT3JPath + "/nrInsc" ) )
					aAnalitico[nPosValores][ANALITICO_LOTACAO]				:=	AllTrim( oXml:xPathGetNodeValue( cT3JPath + "/codLotacao" ) )
					aAnalitico[nPosValores][ANALITICO_NATUREZA]				:=	AllTrim( aRubrica[1] ) //Natureza
					aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:=	AllTrim( aRubrica[2] ) //Tipo
					aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:=	AllTrim( aRubrica[3] ) //Incidência CP
					aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:=	AllTrim( aRubrica[4] ) //Incidência IRRF
					aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:=	AllTrim( aRubrica[5] ) //Incidência FGTS
					aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:=	""
					aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:=	""
					aAnalitico[nPosValores][ANALITICO_VALOR]				:=	Val(StrTran(oXml:xPathGetNodeValue(cCMKPath + "/vrRubr"), ",", "."))

					nCMK ++
					cCMKPath := cT3JPath + "/detVerbas[" + cValToChar( nCMK ) + "]"

				EndDo

				nT3J ++
				cT3JPath := cT3IPath + "/ideEstabLot[" + cValToChar( nT3J ) + "]"

			EndDo

			nT3I ++
			cT3IPath := "/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev[" + cValToChar( nT3I ) + "]"

		EndDo

		InfoRPTObj("1", cPerApu, AllTrim(cCPF),	AllTrim(cNome), aAnalitico,, @oInfoRPT)

		oReport:UpSert("S-2399", "1", cFilEvt, oInfoRPT)

	EndIf

	( cAliasQry )->( DBCloseArea() )

	RestArea( aAreaC1E )
	RestArea( aAreaC9V )
	RestArea( aAreaC87 )
	RestArea( aAreaC8R )

Return()
 
//---------------------------------------------------------------------
/*/{Protheus.doc} Insert5003
@type			function
@description	Função responsável por coletar as informações do Evento S-5003 no retorno do Governo.
@author			Felipe C. Seolin
@since			12/07/2019
@version		1.0
@param			cEvento		-	Evento de Origem do Totalizador
@param			cFilEvt		-	Filial do Registro no TAF
@param			cPeriodo	-	Período de Referência das Informações
@param			cCPF		-	CPF do Registro no TAF
@param			cRecibo		-	Recibo do Registro no TAF
@param			cFilMatriz	-	Filial Matriz
/*/
//---------------------------------------------------------------------
Static Function Insert5003( cEvento, cFilEvt, cPeriodo, cCPF, cRecibo, cFilMatriz )

	Local aAnalitico  	:= {}
	Local cQuery      	:= ""
	Local cFilQry     	:= ""
	Local cIndApu		:= ""
	Local cPerApu		:= ""
	Local cNome			:= ""
	Local cCPFTrab		:= ""
	Local cNrReci		:= ""
	Local cAliasQry   	:= GetNextAlias()
	Local nPosValores 	:= 0
	Local oInfoRPT    	:= Nil

	If Len( AllTrim( cPeriodo ) ) == 4
		cFilQry := IIf( SToD( cPeriodo + "12" + "01" ) >= GetNewPar( "MV_TOTEXDT", SToD( "20991231" ) ), cFilEvt, cFilMatriz )
	Else
		cFilQry := IIf( SToD( SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) + "01" ) >= GetNewPar( "MV_TOTEXDT", SToD( "20991231" ) ), cFilEvt, cFilMatriz )
	EndIf

	cQuery := " SELECT V2P.V2P_CPF, V2P.V2P_NOME, V2P.V2P_PERAPU, V2P.V2P_NRRECI "
	cQuery += "	 , V2Q.V2Q_TPINSC TPINSC, V2Q.V2Q_NRINSC NRINSC, V2Q.V2Q_CODLOT CODLOT "
	cQuery += "	 , V2R.V2R_MATRIC MATRIC, C87.C87_CODIGO CODCAT "
	cQuery += "	 , V26.V26_CODIGO TPVALOR, V2S.V2S_VLFGTS VALOR "
	cQuery += "	 , V2S.V2S_VLDPS DEPVALOR "

	cQuery += " FROM " + RetSqlName( "V2P" ) + " V2P "

	cQuery += " INNER JOIN " + RetSqlName( "V2Q" ) + " V2Q "
	cQuery += "   ON V2Q.V2Q_FILIAL = V2P.V2P_FILIAL "
	cQuery += "  AND V2Q.V2Q_ID = V2P.V2P_ID "
	cQuery += "  AND V2Q.V2Q_VERSAO = V2P.V2P_VERSAO "
	cQuery += "  AND V2Q.D_E_L_E_T_ = '' "

	cQuery += " INNER JOIN " + RetSqlName( "V2R" ) + " V2R "
	cQuery += "   ON V2R.V2R_FILIAL = V2Q.V2Q_FILIAL "
	cQuery += "  AND V2R.V2R_ID = V2Q.V2Q_ID "
	cQuery += "  AND V2R.V2R_VERSAO = V2Q.V2Q_VERSAO "
	cQuery += "  AND V2R.V2R_TPINSC = V2Q.V2Q_TPINSC "
	cQuery += "  AND V2R.V2R_NRINSC = V2Q.V2Q_NRINSC "
	cQuery += "  AND V2R.V2R_CODLOT = V2Q.V2Q_CODLOT "
	cQuery += "  AND V2R.D_E_L_E_T_ = '' "

	cQuery += " LEFT JOIN " + RetSqlName( "V2S" ) + " V2S "
	cQuery += "   ON V2S.V2S_FILIAL = V2R.V2R_FILIAL "
	cQuery += "  AND V2S.V2S_ID = V2R.V2R_ID "
	cQuery += "  AND V2S.V2S_VERSAO = V2R.V2R_VERSAO "
	cQuery += "  AND V2S.V2S_TPINSC = V2R.V2R_TPINSC "
	cQuery += "  AND V2S.V2S_NRINSC = V2R.V2R_NRINSC "
	cQuery += "  AND V2S.V2S_CODLOT = V2R.V2R_CODLOT "
	cQuery += "  AND V2S.V2S_MATRIC = V2R.V2R_MATRIC "
	cQuery += "  AND V2S.V2S_CODCAT = V2R.V2R_CODCAT "
	cQuery += "  AND V2S.D_E_L_E_T_ = '' "

	cQuery += " LEFT JOIN " + RetSqlName( "C87" ) + " C87 "
	cQuery += "  ON C87.C87_FILIAL = '" + xFilial( "C87", cFilQry ) + "' "
	cQuery += " AND C87.C87_ID = V2R.V2R_CODCAT "
	cQuery += " AND C87.D_E_L_E_T_ = '' "

	cQuery += " LEFT JOIN " + RetSqlName( "V26" ) + " V26 "
	cQuery += "  ON V26.V26_FILIAL = '" + xFilial( "V26", cFilQry ) + "' "
	cQuery += " AND V26.V26_ID = V2S.V2S_IDTPVL "
	cQuery += " AND V26.D_E_L_E_T_ = '' "

	cQuery += " WHERE V2P.V2P_FILIAL = '" + cFilQry + "' "
	cQuery += "  AND V2P.V2P_PERAPU = '" + cPeriodo + "' "
	cQuery += "  AND V2P.V2P_CPF = '" + cCPF + "' "
	cQuery += "  AND V2P.V2P_NRRECI = '" + cRecibo + "' "
	cQuery += "  AND V2P.V2P_ATIVO = '1' "
	cQuery += "  AND V2P.D_E_L_E_T_ = '' "

	cQuery += " UNION ALL "

	cQuery += " SELECT V2P.V2P_CPF, V2P.V2P_NOME, V2P.V2P_PERAPU, V2P.V2P_NRRECI "
	cQuery += "	 , V2Q.V2Q_TPINSC, V2Q.V2Q_NRINSC, V2Q.V2Q_CODLOT "
	cQuery += "	 , V2R.V2R_MATRIC, C87.C87_CODIGO "
	cQuery += "	 , V26.V26_CODIGO, V2U.V2U_VLFGTS "
	cQuery += "	 , 0 "

	cQuery += " FROM " + RetSqlName( "V2P" ) + " V2P "

	cQuery += " INNER JOIN " + RetSqlName( "V2Q" ) + " V2Q "
	cQuery += "   ON V2Q.V2Q_FILIAL = V2P.V2P_FILIAL "
	cQuery += "  AND V2Q.V2Q_ID = V2P.V2P_ID "
	cQuery += "  AND V2Q.V2Q_VERSAO = V2P.V2P_VERSAO "
	cQuery += "  AND V2Q.D_E_L_E_T_ = '' "

	cQuery += " INNER JOIN " + RetSqlName( "V2R" ) + " V2R "
	cQuery += "   ON V2R.V2R_FILIAL = V2Q.V2Q_FILIAL "
	cQuery += "  AND V2R.V2R_ID = V2Q.V2Q_ID "
	cQuery += "  AND V2R.V2R_VERSAO = V2Q.V2Q_VERSAO "
	cQuery += "  AND V2R.V2R_TPINSC = V2Q.V2Q_TPINSC "
	cQuery += "  AND V2R.V2R_NRINSC = V2Q.V2Q_NRINSC "
	cQuery += "  AND V2R.V2R_CODLOT = V2Q.V2Q_CODLOT "
	cQuery += "  AND V2R.D_E_L_E_T_ = '' "

	cQuery += " INNER JOIN " + RetSqlName( "V2T" ) + " V2T "
	cQuery += "   ON V2T.V2T_FILIAL = V2R.V2R_FILIAL "
	cQuery += "  AND V2T.V2T_ID = V2R.V2R_ID "
	cQuery += "  AND V2T.V2T_VERSAO = V2R.V2R_VERSAO "
	cQuery += "  AND V2T.V2T_TPINSC = V2R.V2R_TPINSC "
	cQuery += "  AND V2T.V2T_NRINSC = V2R.V2R_NRINSC "
	cQuery += "  AND V2T.V2T_CODLOT = V2R.V2R_CODLOT "
	cQuery += "  AND V2T.V2T_MATRIC = V2R.V2R_MATRIC "
	cQuery += "  AND V2T.V2T_CODCAT = V2R.V2R_CODCAT "
	cQuery += "  AND V2T.D_E_L_E_T_ = '' "

	cQuery += " LEFT JOIN " + RetSqlName( "V2U" ) + " V2U "
	cQuery += "   ON V2U.V2U_FILIAL = V2T.V2T_FILIAL "
	cQuery += "  AND V2U.V2U_ID = V2T.V2T_ID "
	cQuery += "  AND V2U.V2U_VERSAO = V2T.V2T_VERSAO "
	cQuery += "  AND V2U.V2U_TPINSC = V2T.V2T_TPINSC "
	cQuery += "  AND V2U.V2U_NRINSC = V2T.V2T_NRINSC "
	cQuery += "  AND V2U.V2U_CODLOT = V2T.V2T_CODLOT "
	cQuery += "  AND V2U.V2U_MATRIC = V2T.V2T_MATRIC "
	cQuery += "  AND V2U.V2U_CODCAT = V2T.V2T_CODCAT "
	cQuery += "  AND V2U.V2U_PERREF = V2T.V2T_PERREF "
	cQuery += "  AND V2U.D_E_L_E_T_ = '' "

	cQuery += " LEFT JOIN " + RetSqlName( "C87" ) + " C87 "
	cQuery += "  ON C87.C87_FILIAL = '" + xFilial( "C87", cFilQry ) + "' "
	cQuery += " AND C87.C87_ID = V2R.V2R_CODCAT "
	cQuery += " AND C87.D_E_L_E_T_ = '' "

	cQuery += " LEFT JOIN " + RetSqlName( "V26" ) + " V26 "
	cQuery += "  ON V26.V26_FILIAL = '" + xFilial( "V26", cFilQry ) + "' "
	cQuery += " AND V26.V26_ID = V2U.V2U_IDTPVL "
	cQuery += " AND V26.D_E_L_E_T_ = '' "

	cQuery += " WHERE V2P.V2P_FILIAL = '" + cFilQry + "' "
	cQuery += "  AND V2P.V2P_PERAPU = '" + cPeriodo + "' "
	cQuery += "  AND V2P.V2P_CPF = '" + cCPF + "' "
	cQuery += "  AND V2P.V2P_NRRECI = '" + cRecibo + "' "
	cQuery += "  AND V2P.V2P_ATIVO = '1' "
	cQuery += "  AND V2P.D_E_L_E_T_ = '' "

	cQuery += " UNION ALL "

	cQuery += " SELECT V2P.V2P_CPF, V2P.V2P_NOME, V2P.V2P_PERAPU, V2P.V2P_NRRECI "
	cQuery += "	 , '', '', '' "
	cQuery += "	 , V2V.V2V_MATRIC, C87.C87_CODIGO "
	cQuery += "	 , V27.V27_CODIGO, V2W.V2W_VLFGTS "
	cQuery += "	 , 0 "

	cQuery += " FROM " + RetSqlName( "V2P" ) + " V2P "

	cQuery += " INNER JOIN " + RetSqlName( "V2V" ) + " V2V "
	cQuery += "   ON V2V.V2V_FILIAL = V2P.V2P_FILIAL "
	cQuery += "  AND V2V.V2V_ID = V2P.V2P_ID "
	cQuery += "  AND V2V.V2V_VERSAO = V2P.V2P_VERSAO "
	cQuery += "  AND V2V.D_E_L_E_T_ = '' "

	cQuery += " LEFT JOIN " + RetSqlName( "V2W" ) + " V2W "
	cQuery += "   ON V2W.V2W_FILIAL = V2V.V2V_FILIAL "
	cQuery += "  AND V2W.V2W_ID = V2V.V2V_ID "
	cQuery += "  AND V2W.V2W_VERSAO = V2V.V2V_VERSAO "
	cQuery += "  AND V2W.V2W_MATRIC = V2V.V2V_MATRIC "
	cQuery += "  AND V2W.V2W_CODCAT = V2V.V2V_CODCAT "
	cQuery += "  AND V2W.D_E_L_E_T_ = '' "

	cQuery += " LEFT JOIN " + RetSqlName( "C87" ) + " C87 "
	cQuery += "  ON C87.C87_FILIAL = '" + xFilial( "C87", cFilQry ) + "' "
	cQuery += " AND C87.C87_ID = V2V.V2V_CODCAT "
	cQuery += " AND C87.D_E_L_E_T_ = '' "

	cQuery += " LEFT JOIN " + RetSqlName( "V27" ) + " V27 "
	cQuery += "  ON V27.V27_FILIAL = '" + xFilial( "V27", cFilQry ) + "' "
	cQuery += " AND V27.V27_ID = V2W.V2W_IDTPDP "
	cQuery += " AND V27.D_E_L_E_T_ = '' "

	cQuery += " WHERE V2P.V2P_FILIAL = '" + cFilQry + "' "
	cQuery += "  AND V2P.V2P_PERAPU = '" + cPeriodo + "' "
	cQuery += "  AND V2P.V2P_CPF = '" + cCPF + "' "
	cQuery += "  AND V2P.V2P_NRRECI = '" + cRecibo + "' "
	cQuery += "  AND V2P.V2P_ATIVO = '1' "
	cQuery += "  AND V2P.D_E_L_E_T_ = '' "

	cQuery += " UNION ALL "

	cQuery += " SELECT V2P.V2P_CPF, V2P.V2P_NOME, V2P.V2P_PERAPU, V2P.V2P_NRRECI "
	cQuery += "	 , '', '', '' "
	cQuery += "	 , V2V.V2V_MATRIC, C87.C87_CODIGO "
	cQuery += "	 , V27.V27_CODIGO, V2Y.V2Y_VLFGTS "
	cQuery += "	 , 0 "

	cQuery += " FROM " + RetSqlName( "V2P" ) + " V2P "

	cQuery += " INNER JOIN " + RetSqlName( "V2V" ) + " V2V "
	cQuery += "   ON V2V.V2V_FILIAL = V2P.V2P_FILIAL "
	cQuery += "  AND V2V.V2V_ID = V2P.V2P_ID "
	cQuery += "  AND V2V.V2V_VERSAO = V2P.V2P_VERSAO "
	cQuery += "  AND V2V.D_E_L_E_T_ = '' "

	cQuery += " INNER JOIN " + RetSqlName( "V2X" ) + " V2X "
	cQuery += "   ON V2X.V2X_FILIAL = V2V.V2V_FILIAL "
	cQuery += "  AND V2X.V2X_ID = V2V.V2V_ID "
	cQuery += "  AND V2X.V2X_VERSAO = V2V.V2V_VERSAO "
	cQuery += "  AND V2X.V2X_MATRIC = V2V.V2V_MATRIC "
	cQuery += "  AND V2X.V2X_CODCAT = V2V.V2V_CODCAT "
	cQuery += "  AND V2X.D_E_L_E_T_ = '' "

	cQuery += " LEFT JOIN " + RetSqlName( "V2Y" ) + " V2Y "
	cQuery += "   ON V2Y.V2Y_FILIAL = V2X.V2X_FILIAL "
	cQuery += "  AND V2Y.V2Y_ID = V2X.V2X_ID "
	cQuery += "  AND V2Y.V2Y_VERSAO = V2X.V2X_VERSAO "
	cQuery += "  AND V2Y.V2Y_MATRIC = V2X.V2X_MATRIC "
	cQuery += "  AND V2Y.V2Y_CODCAT = V2X.V2X_CODCAT "
	cQuery += "  AND V2Y.V2Y_PERREF = V2X.V2X_PERREF "
	cQuery += "  AND V2Y.D_E_L_E_T_ = '' "

	cQuery += " LEFT JOIN " + RetSqlName( "C87" ) + " C87 "
	cQuery += "  ON C87.C87_FILIAL = '" + xFilial( "C87", cFilQry ) + "' "
	cQuery += " AND C87.C87_ID = V2V.V2V_CODCAT "
	cQuery += " AND C87.D_E_L_E_T_ = '' "

	cQuery += " LEFT JOIN " + RetSqlName( "V27" ) + " V27 "
	cQuery += "  ON V27.V27_FILIAL = '" + xFilial( "V27", cFilQry ) + "' "
	cQuery += " AND V27.V27_ID = V2Y.V2Y_IDTPDP "
	cQuery += " AND V27.D_E_L_E_T_ = '' "

	cQuery += " WHERE V2P.V2P_FILIAL = '" + cFilQry + "' "
	cQuery += "  AND V2P.V2P_PERAPU = '" + cPeriodo + "' "
	cQuery += "  AND V2P.V2P_CPF = '" + cCPF + "' "
	cQuery += "  AND V2P.V2P_NRRECI = '" + cRecibo + "' "
	cQuery += "  AND V2P.V2P_ATIVO = '1' "
	cQuery += "  AND V2P.D_E_L_E_T_ = '' "

	cQuery := ChangeQuery( cQuery )

	TCQuery cQuery New Alias (cAliasQry)

	( cAliasQry )->( DBGoTop() )

	If ( cAliasQry )->( !Eof() )
		While ( cAliasQry )->( !Eof() )
			If Len(AllTrim(cPeriodo)) == 4
				cIndApu := "2"
				cPerApu := AllTrim((cAliasQry)->V2P_PERAPU)
			Else
				cIndApu := "1"
				cPerApu := SubStr((cAliasQry)->V2P_PERAPU, 3, 4) + SubStr((cAliasQry)->V2P_PERAPU, 1, 2)
			EndIf

			cCPFTrab	:= AllTrim((cAliasQry)->V2P_CPF)
			cNome		:= AllTrim((cAliasQry)->V2P_NOME)
			cNrReci 	:= AllTrim((cAliasQry)->V2P_NRRECI) 

			aAdd( aAnalitico, Array( 16 ) )
			nPosValores := Len( aAnalitico )

			aAnalitico[nPosValores][ANALITICO_MATRICULA]			:=	AllTrim( ( cAliasQry )->MATRIC )
			aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:=	AllTrim( ( cAliasQry )->CODCAT )
			aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:=	AllTrim( ( cAliasQry )->TPINSC )
			aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:=	AllTrim( ( cAliasQry )->NRINSC )
			aAnalitico[nPosValores][ANALITICO_LOTACAO]				:=	AllTrim( ( cAliasQry )->CODLOT )
			aAnalitico[nPosValores][ANALITICO_NATUREZA]				:=	""
			aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:=	""
			aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:=	""
			aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:=	""
			aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:=	""
			aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:=	""
			aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:=	AllTrim( ( cAliasQry )->TPVALOR )
			aAnalitico[nPosValores][ANALITICO_VALOR]				:=	( cAliasQry )->VALOR

			If lLaySimplif
				aAnalitico[nPosValores][ANALITICO_VALOR_DEP]		:=	( cAliasQry )->DEPVALOR 
			EndIf

			( cAliasQry )->( DBSkip() )

		EndDo
		
		InfoRPTObj(cIndApu, cPerApu, cCPFTrab, cNome, aAnalitico, cNrReci, @oInfoRPT)

		oReport:UpSert(cEvento, "5", cFilQry, oInfoRPT)

	EndIf

	( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} SetIncPerc
@type			function
@description	Incrementa o progresso realizado.
@author			Felipe C. Seolin
@since			10/06/2019
@version		1.0
@param			oRunCharge	-	Objeto do FWMsgRun
@param			cEtapa		-	Etapa em curso de execução
@param			nQtdTotal	-	Quantidade total de registros a processar
@param			nQtdProc	-	Quantidade de registros processados
/*/
//---------------------------------------------------------------------
Static Function SetIncPerc( oRunCharge, cEtapa, nQtdTotal, nQtdProc )

	Local cMessage	:=	""
	Local cPercent	:=	cValToChar( Int( ( nQtdProc / nQtdTotal ) * 100 ) )

	If cEtapa == "S-1200"
		cMessage := I18N( "#1 - #2 - #3 #4 - Progresso: #5%", { "Etapa 1/3", "Carregando histórico", "Evento", "Folha", cPercent } )
	ElseIf cEtapa == "S-2299"
		cMessage := I18N( "#1 - #2 - #3 #4 - Progresso: #5%", { "Etapa 2/3", "Carregando histórico", "Evento", "Desligamento", cPercent } )
	ElseIf cEtapa == "S-2399"
		cMessage := I18N( "#1 - #2 - #3 #4 - Progresso: #5%", { "Etapa 3/3", "Carregando histórico", "Evento", "Término TSV", cPercent } )
	EndIf

	oRunCharge:cCaption := cMessage
	ProcessMessages()

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} GetCodCat
@type			function
@description	Busca a categoria do trabalhador se houver alteração de cadastro ( S-2206 / S-2306 ).
@author			Felipe C. Seolin
@since			10/06/2019
@version		1.0
@param			cNomEve		-	Nome do Evento
@param			cFilTrb		-	Filial do Trabalhador posicionado
@param			cID			-	ID do Trabalhador posicionado
@param			cPeriodo	-	Data informada no Pergunte utilizado no programa
@return			cRet		-	Categoria do Trabalhador
/*/
//---------------------------------------------------------------------
Static Function GetCodCat( cNomEve, cFilTrb, cID, cPeriodo )

	Local cAliasQry	:=	GetNextAlias()
	Local cSelect	:=	""
	Local cFrom		:=	""
	Local cWhere	:=	""
	Local cRet		:=	""

	If !Empty( cNomEve ) .and. AllTrim( cNomEve ) <> "TAUTO"

		If cNomEve == "S2200"

			cSelect := "T1V_CODCAT"

			cFrom := RetSqlName( "T1V" ) + " T1V "

			cWhere := "     T1V.T1V_FILIAL = '" + cFilTrb + "' "
			cWhere += " AND T1V.T1V_ID = '" + cID + "' "
			cWhere += " AND T1V.T1V_DTALT LIKE '%" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) + "%' "
			cWhere += " AND T1V.D_E_L_E_T_ = ' ' "

		ElseIf cNomEve == "S2300"

			cSelect := "T0F_CATAV"

			cFrom += RetSqlName( "T0F" ) + " T0F "

			cWhere := "     T0F.T0F_FILIAL = '" + cFilTrb + "' "
			cWhere += " AND T0F.T0F_ID = '" + cID + "' "
			cWhere += " AND T0F.T0F_DTALT LIKE '%" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) + "%' "
			cWhere += " AND T0F.D_E_L_E_T_ = ' ' "

		EndIf

		cSelect	:= "%" + cSelect	+ "%"
		cFrom	:= "%" + cFrom		+ "%"
		cWhere	:= "%" + cWhere		+ "%"

		BeginSql Alias cAliasQry
		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%
		EndSql

		If ( cAliasQry )->( !Eof() )

			If cNomEve == "S2200"
				cRet := ( cAliasQry )->T1V_CODCAT
			ElseIf cNomEve == "S2300"
				cRet := ( cAliasQry )->T0F_CATAV
			EndIf

		EndIf

		( cAliasQry )->( DBCloseArea() )

	EndIf

Return( cRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} RptFull
@type			function
@description	Verifica a necessidade de carga na tabela V3N.
@author			Felipe C. Seolin
@since			06/08/2019
@version		1.0
@param			cPeriodo	-	Período de referência das informações
@param			cCPF		-	CPF selecionado como filtro de processamento
@return			lRet		-	Indica se a tabela V3N já possui as informações indicadas nos parâmetros
/*/
//---------------------------------------------------------------------
Static Function RptFull(cPeriodo, cCPF)
	
	Local cAliasQry	:= ""
	Local cQuery	:= ""
	Local nQtdMov	:= 0
	Local nQtdRpt	:= 0
	Local lRet		:= .F.

	//---------------------------------------------------------------------
	// Quantidade de verbas do evento S-1200
	//---------------------------------------------------------------------
	cAliasQry := GetNextAlias()

	cQuery := " SELECT COUNT(*) QUANTIDADE "
	cQuery += " FROM ( "
	cQuery += "			SELECT C91.C91_FILIAL, C91.C91_ID, C91.C91_VERSAO "
	cQuery += "			FROM " + RetSqlName( "C91" ) + " C91 "
	cQuery += "			INNER JOIN " + RetSqlName( "C9M" ) + " C9M "
	cQuery += "			   ON C9M.C9M_FILIAL = C91.C91_FILIAL "
	cQuery += "			  AND C9M.C9M_ID = C91.C91_ID "
	cQuery += "			  AND C9M.C9M_VERSAO = C91.C91_VERSAO "
	cQuery += "			  AND C9M.D_E_L_E_T_ = ' ' "

	//Filtro por CPF
	If !Empty( cCPF )

		cQuery += "			INNER JOIN " + RetSqlName( "C9V" ) + " C9V "
		cQuery += "			   ON C9V.C9V_FILIAL = C91.C91_FILIAL "
		cQuery += "			  AND C9V.C9V_ID = C91.C91_TRABAL "
		cQuery += "			  AND C9V.C9V_CPF = '" + AllTrim( cCPF ) + "' "
		cQuery += "			  AND C9V.D_E_L_E_T_ = ' ' "

	EndIf

	cQuery += "			WHERE C91.C91_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "

	If Len( AllTrim( cPeriodo ) ) == 4
		cQuery += "			  AND C91.C91_PERAPU = '" + cPeriodo +  "' "
	Else
		cQuery += "			  AND C91.C91_PERAPU = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
	EndIf

	cQuery += "			  AND C91.C91_NOMEVE = 'S1200' "
	cQuery += "			  AND C91.C91_ATIVO = '1' "
	cQuery += "			  AND C91.C91_EVENTO <> 'E' "
	cQuery += "			  AND C91.D_E_L_E_T_ = ' ' "

	cQuery += "			UNION ALL "

	cQuery += "			SELECT C91.C91_FILIAL, C91.C91_ID, C91.C91_VERSAO "
	cQuery += "			FROM " + RetSqlName( "C91" ) + " C91 "
	cQuery += "			INNER JOIN " + RetSqlName( "C9R" ) + " C9R "
	cQuery += "			   ON C9R.C9R_FILIAL = C91.C91_FILIAL "
	cQuery += "			  AND C9R.C9R_ID = C91.C91_ID "
	cQuery += "			  AND C9R.C9R_VERSAO = C91.C91_VERSAO "
	cQuery += "			  AND C9R.D_E_L_E_T_ = ' ' "

	//Filtro por CPF
	If !Empty( cCPF )

		cQuery += "			INNER JOIN " + RetSqlName( "C9V" ) + " C9V "
		cQuery += "			   ON C9V.C9V_FILIAL = C91.C91_FILIAL "
		cQuery += "			  AND C9V.C9V_ID = C91.C91_TRABAL "
		cQuery += "			  AND C9V.C9V_CPF = '" + AllTrim( cCPF ) + "' "
		cQuery += "			  AND C9V.D_E_L_E_T_ = ' ' "

	EndIf

	cQuery += "			WHERE C91.C91_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "

	If Len( AllTrim( cPeriodo ) ) == 4
		cQuery += "			  AND C91.C91_PERAPU = '" + AllTrim( cPeriodo ) +  "' "
	Else
		cQuery += "			  AND C91.C91_PERAPU = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
	EndIf

	cQuery += "			  AND C91.C91_NOMEVE = 'S1200' "
	cQuery += "			  AND C91.C91_ATIVO = '1' "
	cQuery += "			  AND C91.C91_EVENTO <> 'E' "
	cQuery += "			  AND C91.D_E_L_E_T_ = ' ' "
	cQuery += " ) FOLHA "

	cQuery := ChangeQuery( cQuery )

	TCQuery cQuery New Alias (cAliasQry)

	( cAliasQry )->( DBGoTop() )

	If ( cAliasQry )->( !Eof() )
		nQtdMov += ( cAliasQry )->QUANTIDADE
	EndIf

	( cAliasQry )->( DBCloseArea() )

	//---------------------------------------------------------------------
	// Quantidade de verbas do evento S-2299
	//---------------------------------------------------------------------
	cAliasQry := GetNextAlias()

	cQuery := " SELECT COUNT(*) QUANTIDADE "
	cQuery += " FROM ( "
	cQuery += "			SELECT CMD.CMD_FILIAL, CMD.CMD_ID, CMD.CMD_VERSAO "
	cQuery += "			FROM " + RetSqlName( "CMD" ) + " CMD "
	cQuery += "			INNER JOIN " + RetSqlName( "T05" ) + " T05 "
	cQuery += "			   ON T05.T05_FILIAL = CMD.CMD_FILIAL "
	cQuery += "			  AND T05.T05_ID = CMD.CMD_ID "
	cQuery += "			  AND T05.T05_VERSAO = CMD.CMD_VERSAO "
	cQuery += "			  AND T05.D_E_L_E_T_ = ' ' "

	//Filtro por CPF
	If !Empty( cCPF )

		cQuery += "			INNER JOIN " + RetSqlName( "C9V" ) + " C9V "
		cQuery += "			   ON C9V.C9V_FILIAL = CMD.CMD_FILIAL "
		cQuery += "			  AND C9V.C9V_ID = CMD.CMD_FUNC "
		cQuery += "			  AND C9V.C9V_CPF = '" + AllTrim( cCPF ) + "' "
		cQuery += "			  AND C9V.D_E_L_E_T_ = ' ' "

	EndIf

	cQuery += "			WHERE CMD.CMD_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "

	If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"
		cQuery += "			  AND SUBSTR( CMD.CMD_DTDESL, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
	Else
		cQuery += "			  AND SUBSTRING( CMD.CMD_DTDESL, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
	EndIf

	cQuery += "			  AND CMD.CMD_ATIVO = '1' "
	cQuery += "			  AND CMD.CMD_EVENTO <> 'E' "
	cQuery += "			  AND CMD.D_E_L_E_T_ = ' ' "

	cQuery += "			UNION ALL "

	cQuery += "			SELECT CMD.CMD_FILIAL, CMD.CMD_ID, CMD.CMD_VERSAO "
	cQuery += "			FROM " + RetSqlName( "CMD" ) + " CMD "
	cQuery += "			INNER JOIN " + RetSqlName( "T5S" ) + " T5S "
	cQuery += "			   ON T5S.T5S_FILIAL = CMD.CMD_FILIAL "
	cQuery += "			  AND T5S.T5S_ID = CMD.CMD_ID "
	cQuery += "			  AND T5S.T5S_VERSAO = CMD.CMD_VERSAO "
	cQuery += "			  AND T5S.D_E_L_E_T_ = ' ' "

	//Filtro por CPF
	If !Empty( cCPF )

		cQuery += "			INNER JOIN " + RetSqlName( "C9V" ) + " C9V "
		cQuery += "			   ON C9V.C9V_FILIAL = CMD.CMD_FILIAL "
		cQuery += "			  AND C9V.C9V_ID = CMD.CMD_FUNC "
		cQuery += "			  AND C9V.C9V_CPF = '" + AllTrim( cCPF ) + "' "
		cQuery += "			  AND C9V.D_E_L_E_T_ = ' ' "

	EndIf

	cQuery += "			WHERE CMD.CMD_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "

	If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"
		cQuery += "			  AND SUBSTR( CMD.CMD_DTDESL, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
	Else
		cQuery += "			  AND SUBSTRING( CMD.CMD_DTDESL, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
	EndIf

	cQuery += "			  AND CMD.CMD_ATIVO = '1' "
	cQuery += "			  AND CMD.CMD_EVENTO <> 'E' "
	cQuery += "			  AND CMD.D_E_L_E_T_ = ' ' "
	cQuery += " ) DESLIGAMENTO "

	cQuery := ChangeQuery( cQuery )

	TCQuery cQuery New Alias (cAliasQry)

	( cAliasQry )->( DBGoTop() )

	If ( cAliasQry )->( !Eof() )
		nQtdMov += ( cAliasQry )->QUANTIDADE
	EndIf

	( cAliasQry )->( DBCloseArea() )

	//---------------------------------------------------------------------
	// Quantidade de verbas do evento S-2399
	//---------------------------------------------------------------------
	cAliasQry := GetNextAlias()

	cQuery := " SELECT COUNT(*) QUANTIDADE "
	cQuery += " FROM " + RetSqlName( "T92" ) + " T92 "
	cQuery += " INNER JOIN " + RetSqlName( "CMK" ) + " CMK "
	cQuery += "   ON CMK.CMK_FILIAL = T92.T92_FILIAL "
	cQuery += "  AND CMK.CMK_ID = T92.T92_ID "
	cQuery += "  AND CMK.CMK_VERSAO = T92.T92_VERSAO "
	cQuery += "  AND CMK.D_E_L_E_T_ = ' ' "

	//Filtro por CPF
	If !Empty( cCPF )

		cQuery += " INNER JOIN " + RetSqlName( "C9V" ) + " C9V "
		cQuery += "   ON C9V.C9V_FILIAL = T92.T92_FILIAL "
		cQuery += "  AND C9V.C9V_ID = T92.T92_TRABAL "
		cQuery += "  AND C9V.C9V_CPF = '" + AllTrim( cCPF ) + "' "
		cQuery += "  AND C9V.D_E_L_E_T_ = ' ' "

	EndIf

	cQuery += " WHERE T92.T92_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "

	If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"
		cQuery += "  AND SUBSTR( T92.T92_DTERAV, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
	Else
		cQuery += "  AND SUBSTRING( T92.T92_DTERAV, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
	EndIf

	cQuery += "  AND T92.T92_ATIVO = '1' "
	cQuery += "  AND T92.T92_EVENTO <> 'E' "
	cQuery += "  AND T92.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery )

	TCQuery cQuery New Alias (cAliasQry)

	( cAliasQry )->( DBGoTop() )

	If ( cAliasQry )->( !Eof() )
		nQtdMov += ( cAliasQry )->QUANTIDADE
	EndIf

	( cAliasQry )->( DBCloseArea() )

	//---------------------------------------------------------------------
	// Quantidade de verbas do evento S-5003
	//---------------------------------------------------------------------
	cAliasQry := GetNextAlias()

	cQuery := " SELECT COUNT(*) QUANTIDADE "
	cQuery += " FROM ( "
	cQuery += "			SELECT V2P.V2P_FILIAL, V2P.V2P_ID, V2P.V2P_VERSAO "
	cQuery += "			FROM " + RetSqlName( "V2P" ) + " V2P "
	cQuery += "			INNER JOIN " + RetSqlName( "V2S" ) + " V2S "
	cQuery += "			   ON V2S.V2S_FILIAL = V2P.V2P_FILIAL "
	cQuery += "			  AND V2S.V2S_ID = V2P.V2P_ID "
	cQuery += "			  AND V2S.V2S_VERSAO = V2P.V2P_VERSAO "
	cQuery += "			  AND V2S.D_E_L_E_T_ = ' ' "
	cQuery += "			WHERE V2P.V2P_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "
	cQuery += "			  AND V2P.V2P_PERAPU = '" + AllTrim( cPeriodo ) +  "' "

	If !Empty( cCPF )
		cQuery += "			  AND V2P.V2P_CPF = '" + AllTrim( cCPF ) + "' "
	EndIf

	cQuery += "			  AND V2P.V2P_ATIVO = '1' "
	cQuery += "			  AND V2P.D_E_L_E_T_ = ' ' "

	cQuery += "			UNION ALL "

	cQuery += "			SELECT V2P.V2P_FILIAL, V2P.V2P_ID, V2P.V2P_VERSAO "
	cQuery += "			FROM " + RetSqlName( "V2P" ) + " V2P "
	cQuery += "			INNER JOIN " + RetSqlName( "V2U" ) + " V2U "
	cQuery += "			   ON V2U.V2U_FILIAL = V2P.V2P_FILIAL "
	cQuery += "			  AND V2U.V2U_ID = V2P.V2P_ID "
	cQuery += "			  AND V2U.V2U_VERSAO = V2P.V2P_VERSAO "
	cQuery += "			  AND V2U.D_E_L_E_T_ = ' ' "
	cQuery += "			WHERE V2P.V2P_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "
	cQuery += "			  AND V2P.V2P_PERAPU = '" + AllTrim( cPeriodo ) +  "' "

	If !Empty( cCPF )
		cQuery += "			  AND V2P.V2P_CPF = '" + AllTrim( cCPF ) + "' "
	EndIf

	cQuery += "			  AND V2P.V2P_ATIVO = '1' "
	cQuery += "			  AND V2P.D_E_L_E_T_ = ' ' "

	cQuery += "			UNION ALL "

	cQuery += "			SELECT V2P.V2P_FILIAL, V2P.V2P_ID, V2P.V2P_VERSAO "
	cQuery += "			FROM " + RetSqlName( "V2P" ) + " V2P "
	cQuery += "			INNER JOIN " + RetSqlName( "V2W" ) + " V2W "
	cQuery += "			   ON V2W.V2W_FILIAL = V2P.V2P_FILIAL "
	cQuery += "			  AND V2W.V2W_ID = V2P.V2P_ID "
	cQuery += "			  AND V2W.V2W_VERSAO = V2P.V2P_VERSAO "
	cQuery += "			  AND V2W.D_E_L_E_T_ = ' ' "
	cQuery += "			WHERE V2P.V2P_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "
	cQuery += "			  AND V2P.V2P_PERAPU = '" + AllTrim( cPeriodo ) +  "' "

	If !Empty( cCPF )
		cQuery += "			  AND V2P.V2P_CPF = '" + AllTrim( cCPF ) + "' "
	EndIf

	cQuery += "			  AND V2P.V2P_ATIVO = '1' "
	cQuery += "			  AND V2P.D_E_L_E_T_ = ' ' "

	cQuery += "			UNION ALL "

	cQuery += "			SELECT V2P.V2P_FILIAL, V2P.V2P_ID, V2P.V2P_VERSAO "
	cQuery += "			FROM " + RetSqlName( "V2P" ) + " V2P "
	cQuery += "			INNER JOIN " + RetSqlName( "V2Y" ) + " V2Y "
	cQuery += "			   ON V2Y.V2Y_FILIAL = V2P.V2P_FILIAL "
	cQuery += "			  AND V2Y.V2Y_ID = V2P.V2P_ID "
	cQuery += "			  AND V2Y.V2Y_VERSAO = V2P.V2P_VERSAO "
	cQuery += "			  AND V2Y.D_E_L_E_T_ = ' ' "
	cQuery += "			WHERE V2P.V2P_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "
	cQuery += "			  AND V2P.V2P_PERAPU = '" + AllTrim( cPeriodo ) +  "' "

	If !Empty( cCPF )
		cQuery += "			  AND V2P.V2P_CPF = '" + AllTrim( cCPF ) + "' "
	EndIf

	cQuery += "			  AND V2P.V2P_ATIVO = '1' "
	cQuery += "			  AND V2P.D_E_L_E_T_ = ' ' "

	cQuery += " ) TOTALIZADOR "

	cQuery := ChangeQuery( cQuery )

	TCQuery cQuery New Alias (cAliasQry)

	( cAliasQry )->( DBGoTop() )

	If ( cAliasQry )->( !Eof() )
		nQtdMov += ( cAliasQry )->QUANTIDADE
	EndIf

	( cAliasQry )->( DBCloseArea() )

	//---------------------------------------------------------------------
	// Quantidade de verbas na tabela de Movimentação de Remunerações
	//---------------------------------------------------------------------
	cAliasQry := GetNextAlias()

	cQuery := " SELECT COUNT(*) QUANTIDADE "
	cQuery += " FROM " + RetSqlName( "V3N" ) + " V3N "
	cQuery += " WHERE V3N.V3N_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "

	If Len( AllTrim( cPeriodo ) ) == 4
		cQuery += "  AND V3N.V3N_PERAPU = '" + cPeriodo +  "' "
	Else
		cQuery += "  AND V3N.V3N_PERAPU = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
	EndIf

	If !Empty( cCPF )
		cQuery += "  AND V3N.V3N_CPF = '" + AllTrim( cCPF ) + "' "
	EndIf

	cQuery += "  AND ( V3N.V3N_ORIGEM = '2' OR ( V3N.V3N_ORIGEM = '5' AND V3N.V3N_VALOR > 0 ) ) "
	cQuery += "  AND V3N.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery )

	TCQuery cQuery New Alias (cAliasQry)

	( cAliasQry )->( DBGoTop() )

	If ( cAliasQry )->( !Eof() )
		nQtdRpt += ( cAliasQry )->QUANTIDADE
	EndIf

	( cAliasQry )->( DBCloseArea() )

	//---------------------------------------------------------------------
	// Comparação de movimentação com dados gravados para relatório
	//---------------------------------------------------------------------
	lRet := nQtdMov == nQtdRpt

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} InfoRPTObj
@type			static function
@description	Instancia o objeto oInfoRPT
@author			Melkz Siqueira
@since			16/08/2022
@version		1.0
@param			cIndApu		-	Indicativo de apuração
@param			cPerApu		-	Período de apuração
@param			cCPF		-	CPF do trabalhador
@param			cNome		-	Nome do trabalhador
@param			aAnalitico	-	Array com os dados a serem gravados na V3N
@param			cRecibo		-	Recibo
@param			oInfoRPT	-	Objeto oInfoRPT não instânciado
/*/
//---------------------------------------------------------------------
Static Function InfoRPTObj(cIndApu as character, cPerApu as character, cCPF as character,; 
					cNome as character, aAnalitico as array, cRecibo as character, oInfoRPT as object)

	Default aAnalitico	:= {}
	Default cIndApu		:= ""
	Default cPerApu		:= ""
	Default cCPF		:= ""
	Default cNome		:= ""
	Default cRecibo		:= ""
	Default oInfoRPT	:= Nil

	If oReport == Nil
		oReport := TAFSocialReport():New()
	EndIf

	oInfoRPT := oReport:oVOReport

	oInfoRPT:SetIndApu(AllTrim(cIndApu))
	oInfoRPT:SetPeriodo(AllTrim(cPerApu))
	oInfoRPT:SetCPF(AllTrim(cCPF))
	oInfoRPT:SetNome(AllTrim(cNome))
	oInfoRPT:SetAnalitico(aAnalitico)
	oInfoRPT:SetRecibo(AllTrim(cRecibo))

Return
