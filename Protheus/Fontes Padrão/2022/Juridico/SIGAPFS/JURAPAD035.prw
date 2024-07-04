#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TopConn.CH"
#INCLUDE "JURAPAD035.CH"

#DEFINE nTamCarac 5.5   // Tamanho de um caractere no relatório
#DEFINE nSalto    10    // Salto de uma linha a outra

#DEFINE cDateFt   cValToChar( Date() ) // Data - Footer
#DEFINE cTimeFt   Time()               // Hora - Footer

Static nPage    := 1    // Contador de páginas
Static cAlsTmp  := ""   // Alias da query de Escritório
Static nSubTot  := 0    // Subtotal por natureza
Static nTot     := 0    // Total Geral
Static nIniV    := 90   // Coordenada vertical inicial
Static __lAuto  := .F.  // Indica se a chamada foi feita via automação

//=======================================================================
/*/{Protheus.doc} JURAPAD035
Relatório de Cash-Flow

@param lAutomato, Indica se a chamada foi feita via automação
@param cNameAuto, Nome do arquivo de relatório usado na automação
@param cDataAuto, Data do dia usada na automação

@author  Nivia Ferreira
@since   28/03/2018
/*/
//=======================================================================
Function JURAPAD035(lAutomato, cNameAuto, cDataAuto)
	Local cDirectory := GetSrvProfString( "StartPath" , "")
	Local bRun       := Nil
	Local lCanc      := .F.
	Local aCashFl    := {}
	Local lPDUserAc  := Iif(FindFunction("JPDUserAc"), JPDUserAc(), .T.) // Indica se o usuário possui acesso a dados sensíveis ou pessoais (LGPD)

	Default lAutomato := .F.
	Default cNameAuto := ""
	Default cDataAuto := ""

	__lAuto := lAutomato

	If lPDUserAc
		While !lCanc
			If __lAuto .Or. JPergunte()
				If __lAuto .Or. JP035TdOk()
					aCashFl := DadosCash(cDataAuto) // Busca dados no banco
					If __lAuto
						PrintReport(cDirectory , aCashFl, cNameAuto)
						lCanc := .T.
					Else
						bRun  := {|| PrintReport(cDirectory , aCashFl, cNameAuto) } // Gera relatórios
						FwMsgRun( , bRun , STR0026 , "" ) // "Gerando relatório, aguarde..."
					EndIf
				EndIf
			Else
				lCanc := .T.
			EndIf
		EndDo
	Else
		MsgInfo(STR0032, STR0033) // "Usuário com restrição de acesso a dados pessoais/sensíveis.", "Acesso restrito"
	EndIf

Return Nil

//=======================================================================
/*/{Protheus.doc} JPergunte
Abre o Pergunte para filtro do relatório

@author Jorge Martins
@since  26/11/2018
@version 1.0
/*/
//=======================================================================
Static Function JPergunte()
Local lRet := .T.

	lRet := Pergunte('JURAPAD035', .T. )

Return lRet

//=======================================================================
/*/{Protheus.doc} JURAPAD035
Busca dos dados para montagem do relatório.

@author  Nivia Ferreira
@since   28/03/2018
/*/
//=======================================================================
Static Function DadosCash(cDataAuto)

	Local cQry       := ""
	Local nPrazoB    := SuperGetMv( "MV_JPRAZOB", .F. , 0, ) // PRAZO BOLETO
	Local nPrazoD    := SuperGetMv( "MV_JPRAZOD", .F. , 0, ) // PRAZO DEPOSITO
	Local nPrazo     := 0
	Local cDataPrazo := ""
	Local aCashFl    := {}
	Local cFilialAt  := cFilAnt
	Local cTituloTp  := "'"+MVNOTAFIS+"','"+MVDUPLIC+"','"+MVFATURA+"','"+MVCHEQUE+"'" //NF |DP |FT |CH
	Local cData      := IIf(__lAuto, cDataAuto, DTOS(DATE()))
	
	//Define momento do tratamento da retencao dos impostos 1 = Na Baixa ou 2 = Na Emissao
	Local cTpRetImp  := SuperGetMV( "MV_BX10925" , .F. , "1" ) 

 	If !Empty(MV_PAR03)
		cFilAnt  := JurGetDados("NS7", 1, xFilial("NS7") + MV_PAR03, "NS7_CFILIA")
	EndIf

	cAlsTmp := GetNextAlias() // Variável estática

	// SALDO IMEDIATAMENTE ANTERIOR A DATA DO DIA
	cQry := "SELECT ' ' CONTA, ' ' FAVORECIDO, ' ' DATA_HIST, '" + STR0011 + "' HISTORICO, FIVFILT.FIV_MOEDA, 0 ENTRADAS, 0 SAIDAS, " // SALDO DO DIA ANTERIOR
	cQry +=         " SUM(FIV_VALOR) SALDO, 0 R_E_C_N_O_ , FIV_FILIAL FILESCRI"
	cQry += " FROM ( "
	cQry +=       " SELECT FIV.FIV_FILIAL, FIV.FIV_DATA, (CASE WHEN FIV.FIV_CARTEI = 'R' THEN FIV.FIV_VALOR ELSE -FIV.FIV_VALOR END) FIV_VALOR, FIV.FIV_MOEDA "
	cQry +=       " FROM " + RetSqlName("FIV") + " FIV "
	cQry +=       " INNER JOIN " + RetSqlName("SED") + " SED "
	cQry +=               " ON ( " + JurRelFilia("SED.ED_FILIAL", "FIV.FIV_FILIAL" )
	cQry +=              " AND FIV.FIV_NATUR = SED.ED_CODIGO"
	cQry +=              " AND SED.ED_CFJUR = '1' "
	cQry +=              " AND SED.D_E_L_E_T_ = ' ')"
	cQry +=            " WHERE FIV.FIV_TPSALD = '3'"
	If !Empty(MV_PAR03)
		cQry +=          " AND FIV.FIV_FILIAL = '" + xFilial("FIV") + "' "
	EndIf
	cQry +=             " AND FIV.D_E_L_E_T_ = ' ' "
	cQry +=       " ) FIVFILT "
	cQry += " WHERE FIVFILT.FIV_DATA < '" + cData + "' "
	cQry +=   " AND FIVFILT.FIV_MOEDA = '" + MV_PAR01 + "' "
	cQry += " GROUP BY FIVFILT.FIV_FILIAL, FIVFILT.FIV_MOEDA "

	cQry := ChangeQuery( cQry )
	DbUseArea( .T. , 'TOPCONN' , TcGenQry( ,, cQry ), cAlsTmp, .T., .F. )
	While (cAlsTmp)->( ! Eof() )
		aAdd(aCashFl, { "1", ;                   // 1 - Tipo
		                cData, ;                 // 2 - Data
		                (cAlsTmp)->CONTA, ;      // 3 - Conta
		                (cAlsTmp)->FAVORECIDO, ; // 4 - Favorecido
		                (cAlsTmp)->DATA_HIST, ;  // 5 - Data usada no histórico
		                (cAlsTmp)->HISTORICO, ;  // 6 - Histórico
		                (cAlsTmp)->FIV_MOEDA, ;  // 7 - Moeda
		                (cAlsTmp)->ENTRADAS , ;  // 8 - Valor de Entradas
		                (cAlsTmp)->SAIDAS, ;     // 9 - Valor de Saídas
		                (cAlsTmp)->SALDO, ;      // 10 - Saldo
		                (cAlsTmp)->R_E_C_N_O_, ; // 11 - Recno (Usado para busca de campo MEMO - Histórico)
		                (cAlsTmp)->FILESCRI, ;   // 12 - Filial do Escritório
		                ""                   ;   // 13 - Tabela (Usado para busca de campo MEMO - Histórico)
		              } )
		(cAlsTmp)->( DbSkip() )
	EndDo
	dbSelectArea(cAlsTmp)
	(cAlsTmp)->( DbCloseArea() )

	cAlsTmp := GetNextAlias()
	cQry    := ""

	//ENTRADAS E SAIDAS DO DIA - NECESSÁRIO CALCULAR O SALDO DA MOVIMENTAÇÃO DO DIA ANTERIOR MAIS AS ENTRADAS MENOS AS SAIDAS
	cQry += " SELECT ' ' CONTA, ' ' FAVORECIDO, ' ' DATA_HIST, '" + STR0029 + "' HISTORICO, " // 'MOVIMENTO REALIZADO NO DIA'
	cQry +=          " FIVFILT.FIV_MOEDA, SUM(ENTRADAS) ENTRADAS, SUM(SAIDAS) SAIDAS, 0 SALDO, 0 R_E_C_N_O_, FIVFILT.FIV_FILIAL FILESCRI "
	cQry +=  " FROM ( "
	cQry +=        " SELECT FIV.FIV_FILIAL, FIV.FIV_DATA,(CASE WHEN FIV.FIV_CARTEI = 'R' THEN FIV.FIV_VALOR ELSE 0 END) ENTRADAS, "
	cQry +=            " (CASE WHEN FIV.FIV_CARTEI = 'P' THEN FIV.FIV_VALOR ELSE 0 END) SAIDAS, FIV.FIV_MOEDA "
	cQry +=        " FROM " + RetSqlName("FIV") + " FIV "
	cQry +=  " INNER JOIN  " + RetSqlName("SED") + " SED "
	cQry +=          " ON ( " + JurRelFilia("SED.ED_FILIAL", "FIV.FIV_FILIAL" )
	cQry +=         " AND FIV.FIV_NATUR = SED.ED_CODIGO "
	cQry +=         " AND SED.ED_CFJUR = '1' "
	cQry +=         " AND SED.D_E_L_E_T_ = ' ') "
	cQry +=       " WHERE FIV.FIV_TPSALD = '3' "
	If !Empty(MV_PAR03)
		cQry +=     " AND FIV.FIV_FILIAL = '" + xFilial("FIV") + "' "
	EndIf
	cQry +=        " AND FIV.D_E_L_E_T_ = ' ' "
	cQry +=      " ) FIVFILT "
	cQry +=  " WHERE FIVFILT.FIV_DATA = '" + cData + "' "
	cQry +=    " AND FIVFILT.FIV_MOEDA = '" + MV_PAR01 + "' "
	cQry += " GROUP BY FIVFILT.FIV_FILIAL, FIVFILT.FIV_MOEDA "

	cQry := ChangeQuery( cQry )
	DbUseArea( .T. , 'TOPCONN' , TcGenQry( ,, cQry ), cAlsTmp, .T., .F. )
	While (cAlsTmp)->( ! Eof() )
		aAdd(aCashFl, { "2", ;                   // 1 - Tipo
		                cData, ;                 // 2 - Data
		                (cAlsTmp)->CONTA, ;      // 3 - Conta
		                (cAlsTmp)->FAVORECIDO, ; // 4 - Favorecido
		                (cAlsTmp)->DATA_HIST, ;  // 5 - Data usada no histórico
		                (cAlsTmp)->HISTORICO, ;  // 6 - Histórico
		                (cAlsTmp)->FIV_MOEDA, ;  // 7 - Moeda
		                (cAlsTmp)->ENTRADAS, ;   // 8 - Valor de Entradas
		                (cAlsTmp)->SAIDAS, ;     // 9 - Valor de Saídas
		                (cAlsTmp)->SALDO, ;      // 10 - Saldo
		                (cAlsTmp)->R_E_C_N_O_, ; // 11 - Recno (Usado para busca de campo MEMO - Histórico)
		                (cAlsTmp)->FILESCRI, ;   // 12 - Filial do Escritório
		                "" ;                     // 13 - Tabela (Usado para busca de campo MEMO - Histórico)
		              } )
		(cAlsTmp)->( DbSkip() )
	EndDo
	dbSelectArea(cAlsTmp)
	(cAlsTmp)->( DbCloseArea() )

	cAlsTmp := GetNextAlias()
	cQry    := ""

	// CONTAS A RECEBER PENDENTE E AINDA NÃO VENCIDO
	cQry += " SELECT SE1.E1_VENCTO DATA, SE1.E1_NATUREZ CONTA, ' ' FAVORECIDO, SE1.E1_VENCTO DATA_HIST, "
	cQry +=        " SE1.E1_MOEDA, SE1.E1_SALDO-(E1_IRRF+E1_PIS+E1_COFINS+E1_CSLL+E1_ISS+E1_INSS) ENTRADAS, "
	cQry +=        " 0 SAIDAS, 0 SALDO, SE1.R_E_C_N_O_, SE1.E1_BOLETO BOLETO , SE1.E1_FILIAL FILESCRI "
	cQry +=   " FROM " + RetSqlName("SE1") + " SE1 "
	cQry +=  " WHERE "
	If !Empty(MV_PAR03)
		cQry +=   " SE1.E1_FILIAL = '" + xFilial("SE1") + "' AND "
	EndIf
	cQry +=   IIf(__lAuto,  " SE1.E1_VENCTO = '" + cData + "' ", " SE1.E1_VENCTO >= '" + cData + "' ") // Filtra data específica quando for automação
	cQry +=   " AND SE1.E1_SALDO > 0 "
	cQry +=   " AND SE1.D_E_L_E_T_ = ' '
	cQry +=   " AND SE1.E1_MOEDA = '" + MV_PAR01 + "' "
	cQry +=   " AND SE1.E1_TIPO IN (" + cTituloTp + ") "
	
	cQry += " GROUP BY SE1.E1_FILIAL, SE1.E1_MOEDA, SE1.E1_VENCTO, SE1.E1_NATUREZ, SE1.E1_SALDO, SE1.E1_IRRF, SE1.E1_PIS, "
	cQry +=          " SE1.E1_COFINS, SE1.E1_CSLL, SE1.E1_ISS, SE1.E1_INSS, R_E_C_N_O_, SE1.E1_BOLETO, SE1.E1_HIST "

	cQry := ChangeQuery( cQry )
	DbUseArea( .T. , 'TOPCONN' , TcGenQry( ,, cQry ), cAlsTmp, .T., .F. )
	While (cAlsTmp)->( ! Eof() )
		nPrazo := IIf((cAlsTmp)->BOLETO == "1", nPrazoB, nPrazoD)
		cDataPrazo := JurDtAdd((cAlsTmp)->DATA, "D", nPrazo)

		If STOD(cDataPrazo) <= MV_PAR02
			aAdd(aCashFl, { "3", ;                   // 1 - Tipo
			                cDataPrazo, ;            // 2 - Data
			                (cAlsTmp)->CONTA, ;      // 3 - Conta
			                (cAlsTmp)->FAVORECIDO, ; // 4 - Favorecido
			                (cAlsTmp)->DATA_HIST, ;  // 5 - Data usada no histórico
			                "", ;                    // 6 - Histórico
			                (cAlsTmp)->E1_MOEDA, ;   // 7 - Moeda
			                (cAlsTmp)->ENTRADAS, ;   // 8 - Valor de Entradas
			                (cAlsTmp)->SAIDAS, ;     // 9 - Valor de Saídas
			                (cAlsTmp)->SALDO, ;      // 10 - Saldo
			                (cAlsTmp)->R_E_C_N_O_, ; // 11 - Recno (Usado para busca de campo MEMO - Histórico)
			                (cAlsTmp)->FILESCRI, ;   // 12 - Filial do Escritório
			                "SE1" ;                  // 13 - Tabela (Usado para busca de campo MEMO - Histórico)
			              } )
		EndIf
		(cAlsTmp)->( DbSkip() )
	EndDo
	dbSelectArea(cAlsTmp)
	(cAlsTmp)->( DbCloseArea() )

	cAlsTmp := GetNextAlias()
	cQry    := ""

	// CONTAS A PAGAR PENDENTE E AINDA NÃO VENCIDO
	cQry += " SELECT SE2.E2_VENCTO DATA, SE2.E2_NATUREZ CONTA, ' ' FAVORECIDO, SE2.E2_VENCTO DATA_HIST, "
	cQry +=        " SE2.E2_MOEDA, 0 ENTRADAS, " 
	
	If cTpRetImp == "1" // Considera retenção de impostos na baixa 
		cQry +=    " SE2.E2_SALDO-(E2_IRRF+E2_PIS+E2_COFINS+E2_CSLL+E2_ISS+E2_INSS) SAIDAS, "	
	Else // Considera retenção de impostos na emissão
		cQry +=    " SE2.E2_SALDO SAIDAS, " 
	EndIf
	
	cQry +=        " 0 SALDO, SE2.R_E_C_N_O_, SE2.E2_FILIAL FILESCRI "
	cQry += " FROM " + RetSqlName("SE2") + " SE2 "
	cQry += " WHERE "
	If !Empty(MV_PAR03)
		cQry +=    " SE2.E2_FILIAL = '" + xFilial("SE2") + "' AND "
	EndIf
	cQry +=        IIf(__lAuto, " SE2.E2_VENCTO = '" + cData + "' ", " SE2.E2_VENCTO >= '" + cData + "' ")
	cQry +=        " AND SE2.E2_SALDO > 0
	cQry +=        " AND SE2.D_E_L_E_T_ = ' '
	cQry +=        " AND SE2.E2_MOEDA = '" + MV_PAR01 + "' "
	cQry +=        " AND SE2.E2_TIPO IN (" + cTituloTp + ") "
	cQry += " GROUP BY SE2.E2_FILIAL, SE2.E2_MOEDA, SE2.E2_VENCTO, SE2.E2_NATUREZ, SE2.E2_HIST, SE2.E2_SALDO, SE2.E2_IRRF, SE2.E2_PIS, "
	cQry +=          " SE2.E2_COFINS, SE2.E2_CSLL, SE2.E2_ISS, SE2.E2_INSS, SE2.R_E_C_N_O_ "

	cQry := ChangeQuery( cQry )
	DbUseArea( .T. , 'TOPCONN' , TcGenQry( ,, cQry ), cAlsTmp, .T., .F. )
	While (cAlsTmp)->( ! Eof() )
		If STOD((cAlsTmp)->DATA) <= MV_PAR02
			aAdd(aCashFl, { "3", ;                   // 1 - Tipo
			                (cAlsTmp)->DATA, ;       // 2 - Data
			                (cAlsTmp)->CONTA, ;      // 3 - Conta
			                (cAlsTmp)->FAVORECIDO, ; // 4 - Favorecido
			                (cAlsTmp)->DATA_HIST, ;  // 5 - Data usada no histórico
			                "", ;                    // 6 - Histórico
			                (cAlsTmp)->E2_MOEDA, ;   // 7 - Moeda
			                (cAlsTmp)->ENTRADAS, ;   // 8 - Valor de Entradas
			                (cAlsTmp)->SAIDAS, ;     // 9 - Valor de Saídas
			                (cAlsTmp)->SALDO, ;      // 10 - Saldo
			                (cAlsTmp)->R_E_C_N_O_, ; // 11 - Recno (Usado para busca de campo MEMO - Histórico)
			                (cAlsTmp)->FILESCRI, ;   // 12 - Filial do Escritório
			                "SE2" ;                  // 13 - Tabela (Usado para busca de campo MEMO - Histórico)
			              } )
		EndIf
		(cAlsTmp)->( DbSkip() )
	EndDo
	dbSelectArea(cAlsTmp)
	(cAlsTmp)->( DbCloseArea() )

	cAlsTmp := GetNextAlias()
	cQry    := ""

	// CONTAS A PAGAR PENDENTE E JÁ VENCIDO
	cQry += " SELECT SE2.E2_NATUREZ CONTA, SA2.A2_NOME FAVORECIDO, SE2.E2_VENCTO DATA_HIST, "
	cQry +=        " SE2.E2_MOEDA, 0 ENTRADAS, "
	If cTpRetImp == "1" // Considera retenção de impostos na baixa 
		cQry +=    " SE2.E2_SALDO-(E2_IRRF+E2_PIS+E2_COFINS+E2_CSLL+E2_ISS+E2_INSS) SAIDAS, "	
	Else // Considera retenção de impostos na emissão
		cQry +=    " SE2.E2_SALDO SAIDAS, " 
	EndIf
	cQry +=        " 0 SALDO, SE2.R_E_C_N_O_, SE2.E2_FILIAL FILESCRI "
	cQry += " FROM " + RetSqlName("SE2") + " SE2 "
	cQry += " INNER JOIN " + RetSqlName("SA2") + " SA2 "
	cQry +=    " ON ( " + JurRelFilia("SA2.A2_FILIAL", "SE2.E2_FILIAL" )
	cQry +=    " AND SA2.A2_COD = SE2.E2_FORNECE "
	cQry +=    " AND SA2.A2_LOJA = SE2.E2_LOJA "
	cQry +=    " AND SA2.D_E_L_E_T_ = ' ') "
	cQry += " WHERE "
	If !Empty(MV_PAR03)
		cQry +=    " SE2.E2_FILIAL = '" + xFilial("SE2") + "' AND "
	EndIf
	cQry +=        " SE2.E2_VENCTO < '"+ cData + "' "
	cQry +=    " AND SE2.E2_SALDO > 0"
	cQry +=    " AND SE2.D_E_L_E_T_ = ' '"
	cQry +=    " AND SE2.E2_MOEDA = '" + MV_PAR01 + "' "
	cQry +=    " AND SE2.E2_TIPO IN (" + cTituloTp + ") "
	cQry += " GROUP BY SE2.E2_FILIAL, SE2.E2_MOEDA,  SE2.E2_VENCTO, SE2.E2_NATUREZ, SA2.A2_NOME, SE2.E2_HIST, SE2.E2_SALDO, SE2.E2_IRRF, "
	cQry +=          " SE2.E2_PIS, SE2.E2_COFINS, SE2.E2_CSLL, SE2.E2_ISS, SE2.E2_INSS, SE2.R_E_C_N_O_ "

	cQry := ChangeQuery( cQry )
	DbUseArea( .T. , 'TOPCONN' , TcGenQry( ,, cQry ), cAlsTmp, .T., .F. )
	While (cAlsTmp)->( ! Eof() )
		aAdd(aCashFl, { "3", ;                   // 1 - Tipo
		                cData, ;                 // 2 - Data
		                (cAlsTmp)->CONTA, ;      // 3 - Conta
		                (cAlsTmp)->FAVORECIDO, ; // 4 - Favorecido
		                (cAlsTmp)->DATA_HIST, ;  // 5 - Data usada no histórico
		                "", ;                    // 6 - Histórico
		                (cAlsTmp)->E2_MOEDA, ;   // 7 - Moeda
		                (cAlsTmp)->ENTRADAS, ;   // 8 - Valor de Entradas
		                (cAlsTmp)->SAIDAS, ;     // 9 - Valor de Saídas
		                (cAlsTmp)->SALDO, ;      // 10 - Saldo
		                (cAlsTmp)->R_E_C_N_O_, ; // 11 - Recno (Usado para busca de campo MEMO - Histórico)
		                (cAlsTmp)->FILESCRI, ;   // 12 - Filial do Escritório
		                "SE2" ;                  // 13 - Tabela (Usado para busca de campo MEMO - Histórico)
		              } )

		(cAlsTmp)->( DbSkip() )
	EndDo
	dbSelectArea(cAlsTmp)
	(cAlsTmp)->( DbCloseArea() )

	cAlsTmp := GetNextAlias()
	cQry    := ""

	// VALORES DE CONTAS A RECEBER RECEBIDOS NO DIA
	cQry += " SELECT FK5.FK5_NATURE CONTA, ' ' FAVORECIDO, SE1.E1_VENCTO DATA_HIST,"
	cQry +=          " FK5.FK5_MOEDA MOEDA, FK5.FK5_VALOR ENTRADAS, "
	cQry +=          " 0 SAIDAS, 0 SALDO, FK5.R_E_C_N_O_, SE1.E1_BOLETO, FK5.FK5_FILIAL FILESCRI "
	cQry +=   " FROM " + RetSqlName("FK5") + " FK5 "
	cQry +=  " INNER JOIN " + RetSqlName("FKA") + " FKA1 "
	cQry +=          " ON " + JurRelFilia("FKA1.FKA_FILIAL", "FK5.FK5_FILIAL" )
	cQry +=         " AND FKA1.FKA_IDORIG = FK5.FK5_IDMOV"
	cQry +=         " AND FKA1.FKA_TABORI = 'FK5'"
	cQry +=         " AND FKA1.D_E_L_E_T_ = ' '"
	cQry +=  " INNER JOIN " + RetSqlName("FKA") + " FKA2 "
	cQry +=          " ON " + JurRelFilia("FKA2.FKA_FILIAL", "FKA1.FKA_FILIAL" )
	cQry +=         " AND FKA2.FKA_IDPROC = FKA1.FKA_IDPROC"
	cQry +=         " AND FKA2.FKA_TABORI = 'FK1'"
	cQry +=         " AND FKA2.D_E_L_E_T_ = ' '"
	cQry +=  " INNER JOIN " + RetSqlName("FK1") + " FK1 "
	cQry +=          " ON " + JurRelFilia("FK1.FK1_FILIAL", "FKA2.FKA_FILIAL" )	
	cQry +=         " AND FK1.FK1_IDFK1 = FKA2.FKA_IDORIG"
	cQry +=         " AND FK1.D_E_L_E_T_ = ' '"
	cQry +=  " INNER JOIN " + RetSqlName("FK7") + " FK7 "
	cQry +=          " ON " + JurRelFilia("FK7.FK7_FILIAL", "FK1.FK1_FILIAL" )
	cQry +=         " AND FK7.FK7_IDDOC = FK1.FK1_IDDOC"
	cQry +=         " AND FK7.FK7_ALIAS = 'SE1' "
	cQry +=         " AND FK7.D_E_L_E_T_ = ' '"
	cQry +=  " INNER JOIN " + RetSqlName("SE1") + " SE1 "
	cQry +=          " ON " + JurRelFilia("SE1.E1_FILIAL", "FK5.FK5_FILIAL" )
	cQry +=         " AND SE1.E1_FILIAL ||'|'|| SE1.E1_PREFIXO ||'|'|| SE1.E1_NUM ||'|'|| SE1.E1_PARCELA ||'|'|| SE1.E1_TIPO ||'|'|| SE1.E1_CLIENTE ||'|'|| SE1.E1_LOJA = FK7.FK7_CHAVE"
	cQry +=         " AND FK7.FK7_ALIAS = 'SE1'"
	cQry +=         " AND SE1.D_E_L_E_T_ = ' '"
	cQry +=  " WHERE "
	If !Empty(MV_PAR03)
		cQry +=    " FK5.FK5_FILIAL = '" + xFilial("FK5") + "' AND "
	EndIf
	cQry +=        " FK5.FK5_RECPAG = 'R'"
	cQry +=    " AND FK5.FK5_DATA = '" + cData + "' "
	cQry +=    " AND FK5.D_E_L_E_T_ = ' '"
	cQry +=    " AND FK5.FK5_MOEDA = '" + MV_PAR01 + "' "
	cQry += " GROUP BY FK5.FK5_FILIAL, FK5.FK5_MOEDA, FK5.FK5_NATURE, SE1.E1_VENCTO, SE1.E1_HIST, FK5.FK5_VALOR, FK5.R_E_C_N_O_, SE1.E1_BOLETO "

	cQry := ChangeQuery( cQry )
	DbUseArea( .T. , 'TOPCONN' , TcGenQry( ,, cQry ), cAlsTmp, .T., .F. )
	While (cAlsTmp)->( ! Eof() )
		aAdd(aCashFl, { "3", ;                   // 1 - Tipo
		                cData, ;                 // 2 - Data
		                (cAlsTmp)->CONTA, ;      // 3 - Conta
		                (cAlsTmp)->FAVORECIDO, ; // 4 - Favorecido
		                (cAlsTmp)->DATA_HIST, ;  // 5 - Data usada no histórico
		                "", ;                    // 6 - Histórico
		                (cAlsTmp)->MOEDA, ;      // 7 - Moeda
		                (cAlsTmp)->ENTRADAS, ;   // 8 - Valor de Entradas
		                (cAlsTmp)->SAIDAS, ;     // 9 - Valor de Saídas
		                (cAlsTmp)->SALDO, ;      // 10 - Saldo
		                (cAlsTmp)->R_E_C_N_O_, ; // 11 - Recno (Usado para busca de campo MEMO - Histórico)
		                (cAlsTmp)->FILESCRI, ;   // 12 - Filial do Escritório
		                "FK5" ;                  // 13 - Tabela (Usado para busca de campo MEMO - Histórico)
		              } )

		(cAlsTmp)->( DbSkip() )
	EndDo
	dbSelectArea(cAlsTmp)
	(cAlsTmp)->( DbCloseArea() )

	cAlsTmp := GetNextAlias()
	cQry    := ""

	// VALORES DE CONTAS A PAGAR PAGOS NO DIA
	cQry += " SELECT FK5.FK5_NATURE CONTA, SA2.A2_NOME FAVORECIDO, SE2.E2_VENCTO DATA_HIST, "
	cQry +=          " FK5.FK5_MOEDA MOEDA, 0 ENTRADAS, FK5.FK5_VALOR SAIDAS, "
	cQry +=          " 0 SALDO, FK5.R_E_C_N_O_, FK5.FK5_FILIAL FILESCRI, 'FK5' ALIASTAB "
	cQry +=   " FROM " + RetSqlName("FK5") + " FK5 "
	cQry +=  " INNER JOIN " + RetSqlName("FKA") + " FKA1 "
	cQry +=          " ON " + JurRelFilia("FKA1.FKA_FILIAL", "FK5.FK5_FILIAL" )
	cQry +=         " AND FKA1.FKA_IDORIG = FK5.FK5_IDMOV"
	cQry +=         " AND FKA1.FKA_TABORI = 'FK5'"
	cQry +=         " AND FKA1.D_E_L_E_T_ = ' '"
	cQry +=  " INNER JOIN " + RetSqlName("FKA") + " FKA2 "
	cQry +=          " ON " + JurRelFilia("FKA2.FKA_FILIAL", "FKA1.FKA_FILIAL" )
	cQry +=         " AND FKA2.FKA_IDPROC = FKA1.FKA_IDPROC"
	cQry +=         " AND FKA2.FKA_TABORI = 'FK2'"
	cQry +=         " AND FKA2.D_E_L_E_T_ = ' '"
	cQry +=  " INNER JOIN " + RetSqlName("FK2") + " FK2 "
	cQry +=          " ON " + JurRelFilia("FK2.FK2_FILIAL", "FKA2.FKA_FILIAL" )
	cQry +=         " AND FK2.FK2_IDFK2 = FKA2.FKA_IDORIG"
	cQry +=         " AND FK2.D_E_L_E_T_ = ' '"
	cQry +=  " INNER JOIN " + RetSqlName("FK7") + " FK7 "
	cQry +=          " ON " + JurRelFilia("FK7.FK7_FILIAL", "FK2.FK2_FILIAL" )
	cQry +=         " AND FK7.FK7_IDDOC = FK2.FK2_IDDOC"
	cQry +=         " AND FK7.FK7_ALIAS = 'SE2'"
	cQry +=         " AND FK7.D_E_L_E_T_ = ' '"
	cQry += " INNER JOIN " + RetSqlName("SE2") + " SE2 "
	cQry +=         " ON " + JurRelFilia("SE2.E2_FILIAL", "FK5.FK5_FILIAL" )
	cQry +=        " AND SE2.E2_FILIAL ||'|'|| SE2.E2_PREFIXO ||'|'|| SE2.E2_NUM ||'|'|| SE2.E2_PARCELA ||'|'|| SE2.E2_TIPO ||'|'|| SE2.E2_FORNECE ||'|'|| SE2.E2_LOJA  = FK7.FK7_CHAVE "
	cQry +=        " AND SE2.D_E_L_E_T_ = ' '"
	cQry += " INNER JOIN " + RetSqlName("SA2") + " SA2 "
	cQry +=         " ON " + JurRelFilia("SA2.A2_FILIAL", "FK5.FK5_FILIAL" )
	cQry +=        " AND SA2.A2_COD = SE2.E2_FORNECE"
	cQry +=        " AND SA2.A2_LOJA = SE2.E2_LOJA"
	cQry +=        " AND SA2.D_E_L_E_T_ = ' '"
	cQry += " WHERE "
	If !Empty(MV_PAR03)
		cQry +=    " FK5.FK5_FILIAL = '" + xFilial("FK5") + "' AND "
	EndIf
	cQry +=       " FK5.FK5_RECPAG = 'P'"
	cQry +=   " AND FK5.FK5_DATA = '" + cData + "' "
	cQry +=   " AND FK5.D_E_L_E_T_ = ' '"
	cQry +=   " AND FK5.FK5_MOEDA = '" + MV_PAR01 + "' "
	
	cQry += " UNION ALL "

	// LANÇAMENTOS DE SAÍDAS DAS NATUREZAS DE CASHFLOW
	cQry += " SELECT OHB.OHB_NATDES CONTA , ' ' FAVORECIDO, OHB.OHB_DTLANC DATA_HIST,"
	cQry +=          "CASE WHEN OHB.OHB_CMOEC = '" + MV_PAR01 + "'  THEN OHB.OHB_CMOEC ELSE OHB.OHB_CMOELC END MOEDA,"
    cQry +=          " 0 ENTRADAS, OHB.OHB_VALOR SAIDAS, 0 SALDO, OHB.R_E_C_N_O_, OHB.OHB_FILIAL FILESCRI, 'OHB' ALIASTAB"
	cQry += " FROM " + RetSqlName("OHB") + " OHB "
	cQry += " INNER JOIN " + RetSqlName("SED") + " SED "
	cQry +=         " ON ( " + JurRelFilia("SED.ED_FILIAL", "OHB.OHB_FILIAL" )
	cQry +=        " AND OHB.OHB_NATDES = SED.ED_CODIGO"
	cQry +=        " AND SED.ED_CFJUR = '1'"
	cQry +=        " AND SED.D_E_L_E_T_ = ' ')"
	cQry += " WHERE "
	If !Empty(MV_PAR03)
		cQry +=    " OHB.OHB_FILIAL = '" + xFilial("OHB") + "' AND "
	EndIf
	cQry +=            " OHB.OHB_DTLANC = '" + cData + "'"
	cQry +=        " AND OHB.OHB_ORIGEM NOT IN ('1', '2', '7') " // (1 - CONTAS A PAGAR / 2 - CONTAS A RECEBER / 7 - Extato)
	cQry +=        " AND OHB.D_E_L_E_T_ = ' '"
	cQry +=        " AND (OHB.OHB_CMOELC = '" + MV_PAR01 + "' "
	cQry +=        " OR   OHB.OHB_CMOEC  = '" + MV_PAR01 + "') "

	cQry += " UNION ALL "

	// LANÇAMENTOS DE ENTRADAS DAS NATUREZAS DE CASHFLOW
	cQry += " SELECT OHB.OHB_NATORI CONTA, ' ' FAVORECIDO, OHB.OHB_DTLANC DATA_HIST,"
	cQry +=          "CASE WHEN OHB.OHB_CMOEC = '" + MV_PAR01 + "'  THEN OHB.OHB_CMOEC  ELSE OHB.OHB_CMOELC END MOEDA,"
	cQry +=          " OHB.OHB_VALOR ENTRADAS, 0 SAIDAS, 0 SALDO, OHB.R_E_C_N_O_, OHB.OHB_FILIAL FILESCRI, 'OHB' ALIASTAB"
	cQry += " FROM " + RetSqlName("OHB") + " OHB "
	cQry += " INNER JOIN " + RetSqlName("SED") + " SED "
	cQry +=         " ON ( " + JurRelFilia("SED.ED_FILIAL", "OHB.OHB_FILIAL" )
	cQry +=        " AND OHB.OHB_NATORI = SED.ED_CODIGO "
	cQry +=        " AND SED.ED_CFJUR = '1' "
	cQry +=        " AND SED.D_E_L_E_T_ = ' ') "
	cQry += " WHERE "
	If !Empty(MV_PAR03)
		cQry +=        " OHB.OHB_FILIAL = '" + xFilial("OHB") + "' AND "
	EndIf
 	cQry +=            " OHB.OHB_DTLANC = '" + cData + "' "
	cQry +=        " AND OHB.OHB_ORIGEM NOT IN ('1', '2', '7') " // (1 - CONTAS A PAGAR / 2 - CONTAS A RECEBER / 7 - Extrato)
	cQry +=        " AND OHB.D_E_L_E_T_ = ' '"
	cQry +=        " AND (OHB.OHB_CMOELC = '" + MV_PAR01 + "' "
	cQry +=        " OR   OHB.OHB_CMOEC  = '" + MV_PAR01 + "')"

	cQry := ChangeQuery( cQry )
	DbUseArea( .T. , 'TOPCONN' , TcGenQry( ,, cQry ), cAlsTmp, .T., .F. )
	While (cAlsTmp)->( ! Eof() )
		aAdd(aCashFl, { "3", ;                   // 1 - Tipo
		                cData, ;                 // 2 - Data
		                (cAlsTmp)->CONTA, ;      // 3 - Conta
		                (cAlsTmp)->FAVORECIDO, ; // 4 - Favorecido
		                (cAlsTmp)->DATA_HIST, ;  // 5 - Data usada no histórico
		                "", ;                    // 6 - Histórico
		                (cAlsTmp)->MOEDA, ;      // 7 - Moeda
		                (cAlsTmp)->ENTRADAS, ;   // 8 - Valor de Entradas
		                (cAlsTmp)->SAIDAS, ;     // 9 - Valor de Saídas
		                (cAlsTmp)->SALDO, ;      // 10 - Saldo
		                (cAlsTmp)->R_E_C_N_O_, ; // 11 - Recno (Usado para busca de campo MEMO - Histórico)
		                (cAlsTmp)->FILESCRI, ;   // 12 - Filial do Escritório
		                (cAlsTmp)->ALIASTAB ;    // 13 - Tabela (Usado para busca de campo MEMO - Histórico)
		              } )

		(cAlsTmp)->( DbSkip() )
	EndDo
	dbSelectArea(cAlsTmp)
	(cAlsTmp)->( DbCloseArea() )

	// Ordena por Escritório, Tipo(1, 2 ou 3) e Data
	aSort( aCashFl,,, { |aX,aY| aX[12]+aX[1]+aX[2] < aY[12]+aY[1]+aY[2] } )

	cFilAnt := cFilialAt
Return (aCashFl)

//=======================================================================
/*/{Protheus.doc} PrintReport
Função para gerar PDF do relatório.

@param   cDirectory, caracter , Caminho da pasta
@param   aCashFl   , array    , Array com os dados para impressão
@param   cNameAuto , caracter , Nome do arquivo de relatório usado na automação

@author  Nivia Ferreira
@since   28/03/2018
/*/
//=======================================================================
Static Function PrintReport(cDirectory , aCashFl, cNameAuto)
	Local oPrinter          := Nil
	Local cNameFile         := STR0001 + FwTimeStamp(1) // "Cash-Flow"
	Local nIniH             := 0
	Local nFimH             := 560
	Local lAdjustToLegacy   := .F.
	Local lDisableSetup     := .T.
	Local cFilEscrAt         := ""

	Default cDirectory  := GetSrvProfString( "StartPath" , "" )

	// Configurações do relatório
	If !__lAuto
		oPrinter := FWMsPrinter():New( cNameFile, IMP_PDF, lAdjustToLegacy, cDirectory, lDisableSetup,,, "PDF" )
	Else
		oPrinter := FWMSPrinter():New( cNameAuto, IMP_SPOOL,,, .T.,,,,.T.) // Inicia o relatório
		// Alterar o nome do arquivo de impressão para o padrão de impressão automatica
		oPrinter:CFILENAME  := cNameAuto
		oPrinter:CFILEPRINT := oPrinter:CPATHPRINT + oPrinter:CFILENAME
	EndIf
	oPrinter:SetPortrait()
	oPrinter:SetPaperSize(DMPAPER_A4)
	oPrinter:SetMargin(60,60,60,60)

	If !Empty(aCashFl) .And. Len(aCashFl) > 0 .And. Len(aCashFl[1]) > 11
		cFilEscrAt := aCashFl[1][12] // Passa o primeiro escritório para gerar a impressão do cabeçalho
	EndIf

	//Gera nova folha
	NewPage( @oPrinter , nIniH , nFimH, cFilEscrAt )

	//Imprime seção de escritório
	//PrintData( @oPrinter , nIniH , nFimH )
	PrintCash( oPrinter , 104 , aCashFl )

	//Gera arquivo relatório
	oPrinter:Print()

Return Nil

//=======================================================================
/*/{Protheus.doc} NewPage
Cria nova página do relatório.

@param oPrinter   , objeto   , Estrutra do relatório
@param nIniH      , numerico , Coordenada horizontal inicial
@param cFilEscrAt , caractere, Filial do Escritório que será impresso

@author  Nivia Ferreira
@since   28/03/2018
/*/
//=======================================================================
Static Function NewPage( oPrinter , nIniH , nFimH, cFilEscrAt )
	//Inicio Página
	oPrinter:StartPage()

	//Monta cabeçalho
	PrintHead( @oPrinter , nIniH , nFimH, cFilEscrAt)

	//Monta títulos das colunas
	PrintTitCol( @oPrinter , nIniH , nFimH , 90 )

	//Imprime Rodapé
	PrintFooter( @oPrinter , nIniH , nFimH )

Return Nil

//=======================================================================
/*/{Protheus.doc} PrintHead
Imprime dados do cabeçalho.

@param Printer    , objeto   , Estrutra do relatório
@param IniH       , numerico , Coordenada horizontal inicial
@param cFilEscrAt , caractere, Filial do Escritório que será impresso

@author  Nivia Ferreira
@since   28/03/2018
/*/
//=======================================================================
Static Function PrintHead( oPrinter , nIniH , nFimH, cFilEscrAt)
	Local oFontHead     := Nil
	Local oFontHead2    := Nil
	Local cSimbMd       := POSICIONE("CTO", 1, xFilial("CTO") + MV_PAR01, "CTO_SIMB" )
	Local cCabec        := STR0001 + ' - ('+ AllTrim(cSimbMd) + ')' // "Cash-Flow"

	Local cTexto        := IIf(!__lAuto, I18N(STR0027, {Date(), cValToChar( MV_PAR02 )} ), "") // "Período: #1 a #2"
	Local cNomeEscr     := Alltrim(JurGetDados("NS7", 4, xFilial("NS7") + cFilEscrAt + cEmpAnt, "NS7_RAZAO"))
	Local cEmpresa      := STR0003 + cNomeEscr // "Empresa: "

	Local nPrazoB       := SuperGetMv( "MV_JPRAZOB" , .F. , 0 ,  ) // PRAZO BOLETO
	Local nPrazoD       := SuperGetMv( "MV_JPRAZOD" , .F. , 0 ,  ) // PRAZO DEPOSITO
	Local cTexPrazo     := STR0002 + Alltrim(Str(nPrazoB)) + '/' + Alltrim(Str(nPrazoD)) + " (" + STR0031 + ") " // #"Prazo de disponibilização de recebimento (Boleto / Depósito):" ###"dias"

	oFontHead   := TFont():New('Arial',,-16,,.T.,,,,,.F.,.F.)
	oFontHead2  := TFont():New('Arial',,-10,,.F.,,,,,.F.,.F.)

	//---------------------
	// Título do relatório
	//---------------------
	oPrinter:Say( 043, nIniH + 231, cCabec, oFontHead, 1200, /*color*/)

	//---------------------------------
	// Detalhes do filtro do relatório
	//---------------------------------
	oPrinter:Line( 060, nIniH, 060, nFimH, 0, "-8")
	oPrinter:Say ( 070, nIniH, cTexto   , oFontHead2, 620 )
	oPrinter:SayAlign ( 068, -60  , cEmpresa , oFontHead2, 620, 200, CLR_BLACK, 1, 1 )
	oPrinter:Say ( 082, nIniH, cTexPrazo, oFontHead2, 620 )
	

Return Nil

//=======================================================================
/*/{Protheus.doc} PrintTitCol
Imprimi título das colunas do relatório.

@param   oPrinter, objeto  , Estrutra do relatório
@param   nIniH   , numerico, Coordenada horizontal inicial
@param   nFimH   , numerico, Coordenada horizontal final
@param   nIniV   , numerico, Coordenada vertical inicial

@author  Nivia Ferreira
@since   28/03/2018
/*/
//=======================================================================
Static Function PrintTitCol( oPrinter , nIniH , nFimH , nIniV )
	Local oFontTitCol := Nil

	oFontTitCol := TFont():New('Arial',,-10,,.F.,,,,,.F.,.F.)

	oPrinter:Line( nIniV, nIniH, nIniV, nFimH, CLR_HRED, "-8")
	oPrinter:Say( nIniV += 9, nIniH      , STR0004   , oFontTitCol, 1200,/*color*/) // "Data"
	oPrinter:Say( nIniV     , nIniH + 040, STR0005   , oFontTitCol, 1200,/*color*/) // "Conta"
	oPrinter:Say( nIniV     , nIniH + 095, STR0006   , oFontTitCol, 1200,/*color*/) // "Favorecido"
	oPrinter:Say( nIniV     , nIniH + 210, STR0007   , oFontTitCol, 1200,/*color*/) // "Histórico"

	oPrinter:SayAlign( nIniV - 8, -190   , STR0008   , oFontTitCol, 620, 250, , 1, 1 ) // "Entradas"
	oPrinter:SayAlign( nIniV - 8, -125   , STR0009   , oFontTitCol, 620, 250, , 1, 1 ) // "Saídas"
	oPrinter:SayAlign( nIniV - 8, -060   , STR0010   , oFontTitCol, 620, 250, , 1, 1 ) // "Saldo"

	oPrinter:Line( nIniV += 4, nIniH, nIniV, nFimH, CLR_HRED, "-8")
	nIniV += nSalto

Return Nil

//=======================================================================
Static Function PrintSubTot (oPrinter, nIniH, nFimH, nIniV, nTotDEnt, nTotDSai, cData, nSaldo, cFilEscrAt)
	Local oFontSubTot   := Nil
	Local cPicture      := "@E 999,999,999,999.99"

	oFontSubTot := TFont():New('Arial',,-9,,.T.,,,,,.F.,.F.)

	EndPage( @oPrinter , nIniH , nFimH , @nIniV , /*nRegPos*/ , (nSalto), .F., cFilEscrAt)

	oPrinter:SayAlign( nIniV ,  210, STR0030 + " " + IIf(!__lAuto, cData, ""), oFontSubTot, 620, 200, CLR_BLACK, 0, 0 ) // "TOTAL DO DIA"
	oPrinter:SayAlign( nIniV , -190, TRANSFORM(nTotDEnt,cPicture)            , oFontSubTot, 620, 250, CLR_BLACK, 1, 1 )
	oPrinter:SayAlign( nIniV , -125, TRANSFORM(nTotDSai,cPicture)            , oFontSubTot, 620, 250, CLR_BLACK, 1, 1 )
	oPrinter:SayAlign( nIniV , -060, TRANSFORM(nSaldo  ,cPicture)            , oFontSubTot, 620, 250, CLR_BLACK, 1, 1 )

	nIniV += nSalto

Return Nil

//=======================================================================
Static Function PrintTotGer( oPrinter , nIniH, nFimH, nIniV, nTotGEnt, nTotGSai, cFilEscrAt )
	Local oFontTotGer 	:= Nil
	Local cPicture      := "@E 999,999,999,999.99"

	oFontTotGer := TFont():New('Arial',,-10,,.T.,,,,,.F.,.F.)

	EndPage( @oPrinter , nIniH , nFimH , @nIniV , /*nRegPos*/ , (nSalto), .F., cFilEscrAt )

	oPrinter:SayAlign( nIniV,  210, STR0013                      , oFontTotGer, 620, 200, CLR_BLACK, 0, 0 ) // "TOTAL DO PERÍODO"
	oPrinter:SayAlign( nIniV, -190, TRANSFORM(nTotGEnt,cPicture) , oFontTotGer, 620, 250, CLR_BLACK, 1, 1 )
	oPrinter:SayAlign( nIniV, -125, TRANSFORM(nTotGSai,cPicture) , oFontTotGer, 620, 250, CLR_BLACK, 1, 1 )

Return Nil

//=======================================================================
/*/{Protheus.doc} PrintCash
Imprime lançamentos da natureza.

@param   oPrinter, objeto  , Estrutra do relatório
@param   nIniH   , numerico, Coordenada horizontal inicial
@param   nFimH   , numerico, Coordenada horizontal final

@author  Nivia Ferreira
@since   28/03/2018
/*/
//=======================================================================
Static Function PrintCash( oPrinter , nIniV , aCashFl)
	Local oFontReg      := TFont():New('Arial',,-9,,.F.,,,,,.F.,.F.)
	Local oFontTitCol   := TFont():New('Arial',,-10,,.T.,,,,,.F.,.F.)
	Local nSaldoGeral   := 0
	Local nTotGEnt      := 0
	Local nTotGSai      := 0
	Local nTotDEnt      := 0
	Local nTotDSai      := 0
	Local nLinha        := 0
	Local nIniH         := 1
	Local nFimH         := 560
	Local nRegPos       := 1
	Local cAntTipo      := ""
	Local cAntEscrit    := ""
	Local cAntData      := ""
	Local cTipo         := ""
	Local cData         := ""
	Local cConta        := ""
	Local cFavorecido   := ""
	Local cDataHist     := ""
	Local cHistTipo1    := ""
	Local cHistTipo2    := ""
	Local cHistorico    := ""
	Local cMoeda        := ""
	Local cTipoAnt      := ""
	Local nValEntrada   := 0
	Local nValSaida     := 0
	Local nSaldo        := 0
	Local nSaldoTp1     := 0
	Local nValEntra2    := 0
	Local nValSaida2    := 0
	Local nRecno        := 0
	Local cFilEscrit    := ""
	Local cTabela       := ""
	Local cPicture      := "@E 999,999,999,999.99"
	Local lNovoEscrit   := .F.
	Local aFilImpr      := {} // Array para verificar se foi impresso o saldo anterior e o movimento do dia da filial
	Local nPosFilImp    := 0
	Local lForcImp1     := .F. // Se a filial imprimiu o saldo anterior
	Local lForcImp2     := .F. // Se a filial imprimiu o saldo do dia

	For nLinha := 1 to Len(aCashFl)

		cTipo       := aCashFl[nLinha][01]            // 1 - Tipo
		cData       := aCashFl[nLinha][02]            // 2 - Data
		cConta      := aCashFl[nLinha][03]            // 3 - Conta
		cFavorecido := AllTrim( aCashFl[nLinha][04] ) // 4 - Favorecido
		cDataHist   := aCashFl[nLinha][05]            // 5 - Data usada no histórico
		cHistorico  := AllTrim( aCashFl[nLinha][06] ) // 6 - Histórico
		cMoeda      := aCashFl[nLinha][07]            // 7 - Moeda
		nValEntrada := aCashFl[nLinha][08]            // 8 - Valor de Entradas
		nValSaida   := aCashFl[nLinha][09]            // 9 - Valor de Saídas
		nSaldo      := aCashFl[nLinha][10]            // 10 - Saldo
		nRecno      := aCashFl[nLinha][11]            // 11 - Recno (Usado para busca de campo MEMO - Histórico)
		cFilEscrit  := aCashFl[nLinha][12]            // 12 - Filial do Escritório
		cTabela     := aCashFl[nLinha][13]            // 13 - Tabela (Usado para busca de campo MEMO - Histórico)

		cData       := IIf(!__lAuto, Dtoc(StoD(cData)), "")

		//-----------------------
		// Controle para verificar se foi impresso o saldo anterior e o movimento do dia da filial
		//-----------------------.
		nPosFilImp := aScan(aFilImpr, {|aFil| aFil[1] == cFilEscrit} )
		If nPosFilImp == 0
			lForcImp1 := cTipo != '1'
			lForcImp2 := cTipo != '1' .And. cTipo != '2'
			cTipoAnt  := cTipo
			Aadd(aFilImpr, {cFilEscrit, lForcImp1, lForcImp2})
			nPosFilImp := Len(aFilImpr)

		ElseIf cTipo == '3' .and. cTipoAnt == '1'
			cTipoAnt  := ''
			lForcImp2 := .T.

		Else
			lForcImp1 := aFilImpr[nPosFilImp][2]
			lForcImp2 := aFilImpr[nPosFilImp][3]
			cTipoAnt  := ''
		EndIf

		//-----------------------
		// Avalia fim da página
		//-----------------------.
		EndPage( @oPrinter , nIniH , nFimH , @nIniV , @nRegPos, (2 * nSalto), /*lEndForced*/, cAntEscrit )

		//-----------------------------
		// Avalia quebra de linha
		//-----------------------------
		lNovoEscrit := !Empty(cAntEscrit) .And. cFilEscrit != cAntEscrit
		If (cTipo == '3' .And. cAntTipo == '3') .Or. lNovoEscrit
			IsBrokenRep( @oPrinter , nIniH , nFimH , @nIniV , @nRegPos , cFilEscrit, cData, cAntEscrit , cAntData , @nTotGEnt, @nTotGSai, @nTotDEnt, @nTotDSai, @nSaldoGeral )
		EndIf
		
		cAntTipo := cTipo
		cAntData := cData
		
		If cTipo == '1' .Or. lForcImp1 // SALDO DO DIA ANTERIOR
			
			//------------------------------------------------------
			// Avalia se deve pintar linha de SALDO DO DIA ANTERIOR
			//------------------------------------------------------
			If Len(aCashFl) >= nLinha + 1
				If aCashFl[nLinha + 1][01] == '2' // Se o Tipo do próximo registro do array for "2" (MOVIMENTO REALIZADO NO DIA), deverá pintar a linha de SALDO DO DIA ANTERIOR.
					//---------------------
					// Insere cor na linha
					//---------------------
					ColorLine( @oPrinter , nIniH , nFimH , nIniV )
				EndIf
			EndIf

			If lForcImp1
				nSaldoTp1  := 0
				cHistTipo1 := STR0011 // SALDO DO DIA ANTERIOR
			Else
				nSaldoTp1  := nSaldo
				cHistTipo1 := cHistorico
			EndIf

			oPrinter:SayAlign( nIniV,  001, cData                          , oFontTitCol, 620, 200, CLR_BLACK, 0, 0 ) // "Data"
			oPrinter:SayAlign( nIniV,  210, cHistTipo1                     , oFontTitCol, 620, 200, CLR_BLACK, 0, 0 ) // "Histórico"
			oPrinter:SayAlign( nIniV,  -60, TRANSFORM(nSaldoTp1, cPicture) , oFontTitCol, 620, 250, CLR_BLACK, 1, 1 ) // "Saldo"

			nSaldoGeral += nSaldoTp1

			nIniV      += nSalto + 3

			nFavLinha := 1
			aFilImpr[nPosFilImp][2]  := .F.
		EndIf

		If cTipo == '2' .Or. lForcImp2 // MOVIMENTO REALIZADO NO DIA
			If lForcImp2
				nValEntra2 := 0
				nValSaida2 := 0
				cHistTipo2 := STR0029 // MOVIMENTO REALIZADO NO DIA
			Else
				nValEntra2 := nValEntrada
				nValSaida2 := nValSaida
				cHistTipo2 := cHistorico
			EndIf

			nSaldoGeral += nValEntra2 - nValSaida2

			oPrinter:SayAlign( nIniV,  001, cData                            , oFontTitCol, 620, 200, CLR_BLACK, 0, 0 ) // "Data"
			oPrinter:SayAlign( nIniV,  210, cHistTipo2                       , oFontTitCol, 620, 200, CLR_BLACK, 0, 0 ) // "Histórico"
			oPrinter:SayAlign( nIniV, -190, TRANSFORM(nValEntra2, cPicture)  , oFontTitCol, 620, 250, CLR_BLACK, 1, 1 ) // "Entradas"
			oPrinter:SayAlign( nIniV, -125, TRANSFORM(nValSaida2, cPicture)  , oFontTitCol, 620, 250, CLR_BLACK, 1, 1 ) // "Saídas"
			oPrinter:SayAlign( nIniV,  -60, TRANSFORM(nSaldoGeral, cPicture) , oFontTitCol, 620, 250, CLR_BLACK, 1, 1 ) // "Saldo"
			nIniV     += nSalto + 3

			nFavLinha := 1

			nTotGEnt +=  nValEntra2
			nTotGSai +=  nValSaida2
			aFilImpr[nPosFilImp][3]  := .F.
		EndIf

		If cTipo == '3' // Movimentações

			cHistorico  := "(" + DToC(StoD(cDataHist)) + ") " + GetHistLanc( cTabela , nRecno )
			cFavorecido := StrTran( cFavorecido , CHR(13)+CHR(10) , " " , Len( cFavorecido ) - 1 ) // Retira quebra de linha

			If __lAuto // Corta o texto para não haver quebras de linhas na execução da automação
				cFavorecido := SubStr(cFavorecido, 1, 10)
				cHistorico  := SubStr(cHistorico , 1, 10)
				nQtdLine    := 1
			Else
				nQtdLine := QtdLineTxt(oPrinter, cHistorico, cFavorecido, oFontReg)
			EndIf

			//-----------------------
			// Insere cor nas linhas
			//-----------------------
			ColorLine( @oPrinter , nIniH , nFimH , nIniV , nRegPos  , , , nQtdLine )
			
			oPrinter:SayAlign( nIniV,  001, cData                            , oFontReg, 620, 200, CLR_BLACK, 0, 0 ) // "Data"
			oPrinter:SayAlign( nIniV,  040, cConta                           , oFontReg, 620, 200, CLR_BLACK, 0, 0 ) // "Conta"
			oPrinter:SayAlign( nIniV,  095, cFavorecido                      , oFontReg, 110, 200, CLR_BLACK, 0, 0 ) // "Favorecido"
			oPrinter:SayAlign( nIniV,  210, cHistorico                       , oFontReg, 150, 200, CLR_BLACK, 0, 0 ) // "Histórico"
			oPrinter:SayAlign( nIniV, -190, TRANSFORM(nValEntrada, cPicture) , oFontReg, 620, 250, CLR_BLACK, 1, 1 ) // "Entradas"
			oPrinter:SayAlign( nIniV, -125, TRANSFORM(nValSaida  , cPicture) , oFontReg, 620, 250, CLR_BLACK, 1, 1 ) // "Saídas"
			oPrinter:SayAlign( nIniV, -060, ""                               , oFontReg, 620, 250, CLR_BLACK, 1, 1 ) // "Saldo"

			nIniV += nSalto * nQtdLine

			nTotGEnt +=  nValEntrada
			nTotGSai +=  nValSaida

			nTotDEnt +=  nValEntrada
			nTotDSai +=  nValSaida

			nSaldoGeral += nValEntrada - nValSaida // Atualiza o saldo geral com os valores do último registro
		EndIf

		cAntEscrit  := cFilEscrit
	Next nLinha

	PrintSubTot(oPrinter, nIniH , nFimH , @nIniV, nTotDEnt, nTotDSai, cData, nSaldoGeral, cFilEscrit)
	nIniV += 2 * nSalto

	PrintTotGer(oPrinter, nIniH , nFimH , @nIniV, nTotGEnt, nTotGSai, cFilEscrit)

Return Nil

//=======================================================================
/*/{Protheus.doc} EndPage
Avalia quebra de página.

@param oPrinter    , objeto   , Estrutra do relatório
@param nIniH       , numerico , Coordenada horizontal inicial
@param nFimH       , numerico , Coordenada horizontal final
@param nIniV       , numerico , Coordenada vertical inicial
@param nIFimV      , numerico , Coordenada vertical final
@param cFilEscrAt  , caractere, Filial do Escritório que será impresso

@author  Nivia Ferreira
@since   28/03/2018
/*/
//=======================================================================
Static Function EndPage( oPrinter , nIniH , nFimH , nIniV , nRegPos, nNewIniV , lEndForced, cFilEscrAt )
	Local nIFimV := 820  // Coordenada vertical final
	
	Default nNewIniV   := 0
	Default lEndForced := .F.
	
	If lEndForced .Or. ( nIniV + nNewIniV ) >= nIFimV
		nIniV    := 104 // 144
		nPage += 1
		oPrinter:EndPage()
		NewPage( @oPrinter , nIniH , nFimH, cFilEscrAt)
		nRegPos := 1
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JP035VldMd
Valida a moeda

@author  Nivia Ferreira
@since   28/03/2018
/*/
//-------------------------------------------------------------------
Function JP035VldMd(cMoeda)
Local lRet    := .T.
Local cSimb   := ""

If Empty(cMoeda)
	JurMsgErro(STR0014,,STR0016) // "Moeda não informada." - "Informe uma moeda válida."
	lRet := .F.
EndIf

cSimb := POSICIONE("CTO",1, xFilial("CTO") + cMoeda, "CTO_SIMB" )
If Empty(cSimb)
	JurMsgErro(STR0015,,STR0016) // "Moeda não encontrada." - "Informe uma moeda válida."
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JP035VldDt
Valida a data limite.

@author  Nivia Ferreira
@since   28/03/2018
/*/
//-------------------------------------------------------------------
Function JP035VldDt(dLimite)
Local lRet := .T.

If dLimite < Date()
	JurMsgErro(STR0017,,STR0018) // "Data inválida." - "Informe uma data válida."
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JP035VldEs
Valida o escritório.

@param   cEscrt , caractere, Código do escritório

@author  Nivia Ferreira
@since   28/03/2018
/*/
//-------------------------------------------------------------------
Function JP035VldEs(cEscrt)
Local lRet    := .T.
Local cRetNS7 := ""

If !Empty(cEscrt)
	cRetNS7 := JurGetDados( "NS7", 1, xFilial("NS7") + cEscrt, "NS7_COD" )
	If Empty(cRetNS7)
		JurMsgErro(STR0019,,STR0020) // "Escritório não encontrado." - "Informe um escritório válido."
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JP035TdOk
Rotina validar os dados do pergunte

@author  Nivia Ferreira
@since   28/03/2018
/*/
//-------------------------------------------------------------------
Static Function JP035TdOk()
Local lRet := .T.

If Empty(MV_PAR01)
	JurMsgErro(STR0021,,STR0022) // "A moeda é obrigatória." - "Informe uma moeda válida."
	lRet := .F.
EndIf

If lRet .And. MV_PAR02 < date()
	JurMsgErro(STR0023,,STR0024) // "A data limite é obrigatória." - "Informe uma data válida."
	lRet := .F.
EndIf

Return lRet

//=======================================================================
/*/{Protheus.doc} PrintFooter
Imprimide rodapé do cabeçalho.

@param  oPrinter, objeto   , Estrutra do relatório
@param  nIniH   , numerico , Coordenada horizontal inicial
@param  nFimH   , numerico , Coordenada horizontal final

@author Jonatas Martins / Jorge Martins
@since	28/03/2018
/*/
//=======================================================================
Static Function PrintFooter( oPrinter , nIniH , nIniF )
	Local oFontRod := Nil
	Local nLinRod  := 830
	
	oFontRod := TFont():New('Arial',,-10,,.F.,,,,,.F.,.F.)
	
	oPrinter:Line( nLinRod, nIniH, nLinRod, nIniF, CLR_HRED, "-8")
	nLinRod += nSalto
	If !__lAuto
		oPrinter:SayAlign( nLinRod, nIniH, cDateFt + " - " + cTimeFt, oFontRod, nIniF, 200, CLR_BLACK, 2, 1 )
		oPrinter:SayAlign( nLinRod, nIniH, cValToChar( nPage )      , oFontRod, nIniF, 200, CLR_BLACK, 1, 1 )
	EndIf

Return Nil

//=======================================================================
/*/{Protheus.doc} GetHistLanc
Pega histórico do lançamento

@param  nTpLanc   , numerico  , Tipo do lançamento 1=Saldo Anterior; 2=Histórico Atual 
@param  nRecno    , numerico  , Recno do registro

@author Jonatas Martins / Jorge Martins
@since  28/03/2018
/*/
//=======================================================================
Static Function GetHistLanc( cAlias , nRecno )
	Local aArea      := GetArea()
	Local aAreaTab   := (cAlias)->( GetArea() )
	Local cHistorico := ""
	Local nLimite    := 640
	
	If !Empty(cAlias)
	
		&(cAlias)->(dbgoTo(nRecno))
		
		Do Case
			Case cAlias == 'OHB' 
				cHistorico := OHB->OHB_HISTOR

			Case cAlias == 'SE1' 
				cHistorico := SE1->E1_HIST

			Case cAlias == 'SE2' 
				cHistorico := SE2->E2_HIST

			Case cAlias == 'FK5' 
				cHistorico := FK5->FK5_HISTOR
		
		End Case
		
		cHistorico := StrTran( cHistorico , CHR(13)+CHR(10) , " " , Len( cHistorico ) ) //Retira quebra de linha no final do texto
		
		If Len( cHistorico ) > nLimite
			cHistorico := SubStr( cHistorico , 1 , nLimite ) + "..." 
		EndIf
	
	EndIf

	RestArea( aAreaTab )
	RestArea( aArea )
Return ( cHistorico )

//=======================================================================
/*/{Protheus.doc} ColorLine
Muda cor da linha impressa.

@param   oPrinter, objeto   , Estrutra do relatório
@param   nIniH   , numerico , Coordenada horizontal inicial
@param   nFimH   , numerico , Coordenada horizontal final
@param   nIniV   , numerico , Coordenada vertical inicial
@param   nRegPos , numerico , Contador de registros
@param   lForce  , logico   , Força alterar cor da linha
@param   nColor  , numerico , Cor da linha
@param   nQtdLine, numerico , Quantidade necessárias de linhas para impressão do texto

@author  Jonatas Martins / Jorge Martins
@since   28/03/2018
/*/
//=======================================================================
Static Function ColorLine( oPrinter , nIniH , nFimH , nIniV , nRegPos , lForce , nColor, nQtdLine )
	Local aCoords := {}
	Local oBrush  := Nil
	Local cPixel  := ""
	
	Default nRegPos  := 1
	Default lForce   := .F.
	Default nColor   := RGB( 220 , 220 , 220 )
	Default nQtdLine := 1
	
	//-----------------------------
	// Avalia se a linha é impar
	//-----------------------------
	If Mod( nRegPos , 2 ) != 0 .Or. lForce
		oBrush  :=  TBrush():New( Nil , nColor )
		aCoords := { nIniV , nIniH , (nQtdLine * nSalto) + nIniV , nFimH }
		cPixel  := "-2"
		oPrinter:FillRect( aCoords , oBrush , cPixel )
	EndIf

Return Nil

//=======================================================================
/*/{Protheus.doc} IsBrokenRep
Avalia quebra de relatório.

@param  oPrinter   , objeto     , Estrutra do relatório
@param  nIniH      , numerico   , Coordenada horizontal inicial
@param  nFimH      , numerico   , Coordenada horizontal final
@param  nIniV      , numerico   , Coordenada vertical inicial
@param  nRegPos    , numerico   , Contador de registros
@param  cNovoEscrit, caractere  , Código do novo escritório
@param  cNovaData  , caractere  , Nova data
@param  cAntEscrit , caractere  , Código do escritório anterior
@param  cAntData   , caractere  , Data anterior
@param  nTotGEnt   , caractere  , Valor total geral de entrada
@param  nTotGSai   , caractere  , Valor total geral de saída
@param  nTotDEnt   , caractere  , Valor de entrada 
@param  nTotDSai   , caractere  , Valor de saída
@param  nSaldo     , caractere  , Valor do saldo

@author Jonatas Martins / Jorge Martins
@since  28/03/2018
/*/
//=======================================================================
Static Function IsBrokenRep( oPrinter , nIniH , nFimH , nIniV , nRegPos , cNovoEscrit , cNovaData , cAntEscrit , cAntData , nTotGEnt, nTotGSai, nTotDEnt, nTotDSai, nSaldo)

	//-----------------------------------------
	// Avalia quebra de página (Nova natureza)
	//-----------------------------------------
	If !Empty(cAntEscrit) .And. !Empty(cNovoEscrit) .And. (cAntEscrit != cNovoEscrit)

		//------------------
		// Imprime subtotal
		//------------------
		PrintSubTot(oPrinter,  nIniH , nFimH , @nIniV , nTotDEnt, nTotDSai, cAntData, nSaldo, cAntEscrit)
		nIniV += nSalto
		nTotDEnt := 0
		nTotDSai := 0
		nSaldo   := 0

		//------------------
		// Imprime geral
		//------------------
		PrintTotGer(oPrinter,  nIniH , nFimH , @nIniV , nTotGEnt, nTotGSai, cAntEscrit)
		nIniV += nSalto + 5

		// É necessário zerar os valores de totais, pois são totalizadores por natureza e houve mudança de natureza
		nTotGEnt  := 0 // Saldo da natureza
		nTotGSai  := 0 // Subtotal por escritório
		nRegPos   := 1 // Contador de registros

		// Finaliza a página para troca de natureza
		EndPage( @oPrinter , nIniH , nFimH , @nIniV , @nRegPos , /*nNewIniV*/, .T., cNovoEscrit )

	//-------------------------------------------------------------
	// Avalia quebra de sessão (Novo Escritório / Centro de Custo)
	//-------------------------------------------------------------
	ElseIf !Empty(cAntData) .And. !Empty(cNovaData) .And. (cAntData != cNovaData)

		PrintSubTot(oPrinter, nIniH , nFimH , @nIniV , nTotDEnt, nTotDSai, cAntData, nSaldo, cNovoEscrit)
		nIniV += nSalto
		nTotDEnt := 0
		nTotDSai := 0
		nRegPos  := 1 // Contador de registros
		
	Else//If !Empty(cAntEscrit) .And. !Empty(cAntData)
		nRegPos ++      // Incrementa contador de registros
	EndIf
	
Return Nil

//=======================================================================
/*/{Protheus.doc} QtdLineTxt
Avalia quantas linhas serão necessárias para impressão do texto

@param  oPrinter   , objeto     , Estrutra do relatório
@param  cHistorico , caractere, Histórico
@param  cFavorecido, caractere, Favorecido
@param  oFontReg   , objeto   , Fonte para impressão dos dados

@return nQtdLinha  , numerico , Quantidade de linhas necessárias para impressão do texto

@author Jorge Martins
@since  04/04/2018
/*/
//=======================================================================
Static Function QtdLineTxt(oPrinter, cHistorico, cFavorecido, oFontReg)
Local nHisRazao     := 468
Local nFavRazao     := 198
Local nHisLinha     := oPrinter:GetTextWidth( cHistorico , oFontReg ) / nHisRazao
Local nFavLinha     := oPrinter:GetTextWidth( cFavorecido, oFontReg ) / nFavRazao
Local nQtdLinha     := Iif(nHisLinha > nFavLinha, nHisLinha, nFavLinha)

	If Round(nQtdLinha , 2) > 1.20
		nQtdLinha := Ceiling(nQtdLinha)
	Else
		nQtdLinha := Round(nQtdLinha,0)
	EndIf

	If nQtdLinha == 0
		nQtdLinha := 1
	EndIf

Return nQtdLinha
