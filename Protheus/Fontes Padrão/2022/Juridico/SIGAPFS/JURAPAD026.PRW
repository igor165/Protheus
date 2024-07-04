#INCLUDE "JURAPAD026.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURAPAD026
Rotina de parâmetros do relatório em Crystal/FWMSPrinter de Previsão de Faturamento
Analítico.

@param, lAutomato, lógico   , Se verdadeiro indica execução via automação
@param, cNameAuto, caractere, Nome do arquivo do relatório via a ser gerado através da automação

@author Cristina Cintra
@since 30/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURAPAD026(lAutomato, cNameAuto)
	Local aArea     := GetArea()
	Local lRet      := .F.
	Local cLojaAuto := SuperGetMv( "MV_JLOJAUT" , .F. , "2" ,  ) // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
	Local lPDUserAc := Iif(FindFunction("JPDUserAc"), JPDUserAc(), .T.) // Indica se o usuário possui acesso a dados sensíveis ou pessoais (LGPD)
	
	Private cMoedaNac := SuperGetMv('MV_JMOENAC',,'01')

	Default lAutomato := .F.
	Default cNameAuto := ""

	If lPDUserAc
		If cLojaAuto == "1"
			If lAutomato .Or. Pergunte('JURPAD026B')
				JR026Relat(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, IIF(lAutomato, "", JurGetLjAt()), MV_PAR05, Str(MV_PAR06, 1), lAutomato, cNameAuto)
			EndIf
		Else
			If lAutomato .Or. Pergunte('JURAPAD026')
				JR026Relat(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, Str(MV_PAR07, 1), lAutomato, cNameAuto)
			EndIf
		EndIf
	Else
		MsgInfo(STR0018, STR0019) // "Usuário com restrição de acesso a dados pessoais/sensíveis.", "Acesso restrito"
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JR026VldEsc
Valida o codigo do Escritorio

@author Mauricio Canalle
@since 24/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JR026VldEsc(cEscrit)
	Local lRet := .T.
	Local aArea := GetArea()

	If !Empty(cEscrit)
	   If Empty(Posicione("NS7", 1, xFilial("NS7")+cEscrit, "NS7_COD"))
	      ApMsgAlert(STR0005)  // "Código não encontrado no cadastro!"   
	      lRet := .F.
	   Endif
	EndiF

	Restarea(aArea)

Return lRet	

//-------------------------------------------------------------------
/*/{Protheus.doc} JR026VldCli
Valida o codigo do Cliente

@author Mauricio Canalle
@since 24/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JR026VldCli(cCliente)
	Local lRet      := .T.
	Local aArea     := GetArea()

	If !Empty(cCliente)
		If FindFunction("JurVldCli")
			lRet := JurVldCli(, cCliente, , , ,"CLI", )
		Else
			If Empty(Posicione("NUH", 1, xFilial("NUH")+cCliente, "NUH_COD"))
				ApMsgAlert(STR0005)  // "Código não encontrado no cadastro!"   
				lRet := .F.
			Endif
		EndiF	
	EndIf

	Restarea(aArea)

Return lRet	

//-------------------------------------------------------------------
/*/{Protheus.doc} JR026VldLoja
Valida o codigo do Cliente + Loja

@author Mauricio Canalle
@since 24/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JR026VldLoja(cCliente, cLoja)
	Local lRet := .T.
	Local aArea := GetArea()

	If !Empty(cCliente) .and. Empty(cLoja)
	      ApMsgAlert(STR0005)  // "Informe o código da loja do cliente" 
	      lRet := .F.	
	Endif

	If lRet .AND. !Empty(cCliente) .and. !Empty(cLoja)
		If FindFunction("JurVldCli")
			lRet := JurVldCli(, cCliente, , , ,"LOJ", )
		Else
			If Empty(Posicione("NUH", 1, xFilial("NUH")+cCliente+cLoja, "NUH_COD"))
				ApMsgAlert(STR0005)  // "Código não encontrado no cadastro!"   
				lRet := .F.
			Else
				If Posicione("NUH", 1, xFilial("NUH")+cCliente+cLoja, "NUH->NUH_PERFIL")   <> '1'
					ApMsgAlert(STR0008)  // "Cliente cadastrado como somente pagador!"   
					lRet := .F.
				Endif
			Endif
		EndIf
	EndIf

	Restarea(aArea)

Return lRet	

//-------------------------------------------------------------------
/*/{Protheus.doc} JR026VldGrp
Valida o codigo do Grupo de Cliente

@author Mauricio Canalle
@since 24/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JR026VldGrp(cGrpCli)
	Local lRet := .T.
	Local aArea := GetArea()

	If !Empty(cGrpCli)
	   If Empty(Posicione("ACY", 1, xFilial("ACY")+cGrpCli, "ACY_GRPVEN"))
	      ApMsgAlert(STR0005)  // "Código não encontrado no cadastro!"   
	      lRet := .F.
	   Endif
	EndiF

	Restarea(aArea)

Return lRet	

//-------------------------------------------------------------------
/*/{Protheus.doc} JR026VldCtr
Valida o codigo do Contrato

@author Mauricio Canalle
@since 24/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JR026VldCtr(cContrato)
	Local lRet := .T.
	Local aArea := GetArea()

	If !Empty(cContrato)
	   If Empty(Posicione("NT0", 1, xFilial("NT0")+cContrato, "NT0_COD"))
	      ApMsgAlert(STR0005)  // "Código não encontrado no cadastro!"   
	      lRet := .F.
	   Endif
	EndiF

	Restarea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JR026Relat
Rotina para o processamento do relatório em Crystal - Previsão de Faturamento
Analítico.

@Param cAnoMes  , Ano-mês referência do relatório
@Param cEscri   , Escritório de faturamento desejado para filtro
@Param cGrpCli  , Grupo de Clientes desejado para filtro
@Param cCliente , Cliente desejado para filtro
@Param cLoja    , Loja do Cliente desejado para filtro
@Param cContrat , Contrato desejado para filtro
@Param cResultad, Indica se o relatório será enviado para (1-Tela;2-Impressora)
@Param lAutomato, Se verdadeiro indica execução via automação
@Param cNameAuto, Nome do arquivo do relatório via a ser gerado através da automação

@Return lRet    , Indica se o os parâmetros foram preenchidos corretamente
                  para emissão do relatório. 

@author Cristina Cintra
@since 30/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JR026Relat(cAnoMes, cEscri, cGrpCli, cCliente, cLoja, cContrato, cResultado, lAutomato, cNameAuto)
	Local aRet       := {}
	Local lRet       := .T.
	Local cRelatorio := "JURAPAD026"
	Local cArquivo   := "JURAPAD026"
	Local cSimbolo   := ""
	Local cTipoConv  := SuperGetMv('MV_JTPCONV',,'1' )  // Cotação '1' = Diária / '2' = Mensal
	Local cModRel    := SuperGetMV('MV_JMODREL',,'1')  // TIPO DE RELATORIO 1 CRYSTAL, 2 FWMSPRINT
	Local lJURRPAD026 := ExistBlock('JURRPAD026')

	Begin Sequence
	
		If Empty(cAnoMes) .Or. Empty(cResultado)
			lRet := .F.
			ApMsgAlert(STR0015) // "Alguns dos parâmetros não foram preenchidos! Verifique!"
			Break
		EndIf
		
		/*
			CALLCRYS (rpt , params, options), onde:
			rpt = Nome do relat?rio, sem o caminho.
			params = Par?metros do relat?rio, separados por v?rgula ou ponto e v?rgula. Caso seja marcado este par?metro, ser?o desconsiderados os par?metros marcados no SX1.
			options = Op??es para n?o se mostrar a tela de configura??o de impress?o , no formato x;y;z;w ,onde:
			x = Impress?o em V?deo(1), Impressora(2), Impressora(3), Excel (4), Excel Tabular(5), PDF(6) e?Texto?(7)?.
			y = Atualiza Dados  ou n?o(1)
			z = N?mero de C?pias, para exporta??o este valor sempre ser? 1.
			w =T?tulo do Report, para exporta??o este ser? o nome do arquivo sem extens?o.
		*/
				
		aRet := JR026SQL(cAnoMes, cGrpCli, cCliente, cLoja, cContrato)
			
		If aRet[2]
			cOptions := cResultado + ";0;1;"
		
			cSimbolo := Trim(JurGetDados('CTO',1,xFilial('CTO')+cMoedaNac,  'CTO_SIMB'))
		
			cParams  := cAnoMes + ";" + Trim(cEscri) + ";" + cMoedaNac + ";" + cSimbolo + ";" + __CUSERID + ";" + cTipoConv + ";"
			 
			If cModRel == '1' .And. !lAutomato // CRYSTAL
				JCallCrys( cRelatorio, cParams, cOptions + cArquivo, .T., .T., .F.) 
			Else
				If lJURRPAD026
					ExecBlock('JURRPAD026', .F., .F.)
				Else 
					JURRPAD026(cAnoMes, cEscri, cGrpCli, cCliente, cLoja, cContrato, cRelatorio, lAutomato, cNameAuto)
				EndIf
			EndIf
		Else
			lRet := .F.
			IIF(lAutomato, JurMsgErro(STR0017), ApMsgAlert(STR0017)) // "Não existe movimentação no mês de referência!"
			Break
		EndIf

	End Sequence

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JR026SQL
Rotina para o preenchimento da tabela OH0 que será utilizada no relatório
Analítico.

@Param cAnoMes				Ano-mês referência do relatório
@Param cGrpCli				Grupo para filtro do relatório
@Param cCliente			Cliente para filtro do relatório
@Param cLoja					Loja para filtro do relatório
@Param cContrato		Contrato para filtro do relatório

@Return lRet     		Indica se a inserção obteve êxito. 

@author Jacques Alves Xavier
@since 04/06/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JR026SQL(cAnoMes, cGrpCli, cCliente, cLoja, cContrato)
	Local lExistCont := .F.
	Local cSQL        := ""
	Local aArea       := GetArea()
	Local aAreaOH0    := OH0->( GetArea() )
	local aRet        := { }

	/*
	###########################################################################
	# Legenda para o tipo utilizado na query e dentro do reletório em Crystal # 
	###########################################################################

	FA = Fatura adicional
	EX = Êxito
	FX = Faixa de faturamento
	FC = Final de contrato
	FX = Partido fixo
	LI = Limite geral
	PO = Pré-definido e Ocorrência
	HR = Hora
	PR = Contrato provisório
	MI = Mínimo
	MT = Misto
	LT = Lançamento tabelado
	NC = Não cobrar
	*/	

	// Apaga os registros antigos do usuario atual 
	OH0->( dbSetOrder (2) )
	OH0->( dbSeek( xFilial('OH0') + __CUSERID )  )
	
	While !OH0->( EOF() ) 
		
		If OH0->OH0_DATA <= Date() 
			RecLock("OH0",.F.)
			DbDelete()
			MsUnlock()
		EndIf
		
		OH0->( dbSkip() )
	EndDo
	
	RestArea( aAreaOH0 )
	RestArea(aArea)
	
	// Parcelas de fatura adicional
	cSQL := " SELECT NT0_COD, MOEDA_COND, TIPO, NT0_CESCR, SUM(VALOR_MES) VALOR_MES, SUM(VALOR_ACUM) VALOR_ACUM" + CRLF
	cSQL += " FROM ( " + CRLF    
	cSQL +=    "SELECT NT0.NT0_COD, SUBSTRING(NVV.NVV_DTFIMH,1,6) ANOMES, NVV.NVV_CMOE1 MOEDA_COND, 'FA' TIPO, NT0.NT0_CESCR, " + CRLF
	cSQL +=       " (CASE WHEN SUBSTRING(NVV.NVV_DTFIMH,1,6) = '" + cAnoMes + "' THEN NVV.NVV_VALORH ELSE 0 END) VALOR_MES, " + CRLF
	cSQL +=       " (CASE WHEN SUBSTRING(NVV.NVV_DTFIMH,1,6) < '" + cAnoMes + "' THEN NVV.NVV_VALORH ELSE 0 END) VALOR_ACUM " + CRLF
	cSQL +=    " FROM " + RetSqlName("NVV") + " NVV " + CRLF // FATURA ADICIONAL
	cSQL +=    " INNER JOIN " + RetSqlName("NT0") + " NT0 " + CRLF // CONTRATO
	cSQL +=       " ON NT0.NT0_FILIAL = '" + xFilial("NT0") +"' " + CRLF
	cSQL +=       " AND NT0.NT0_COD = NVV.NVV_CCONTR " + CRLF // CONTRATO x FATURA ADICIONAL
	If !Empty(cGrpCli)
		cSQL += " AND NT0.NT0_CGRPCL = '" + cGrpCli + "' " + CRLF
	EndIf
	If !Empty(cCliente)
		cSQL += " AND NT0.NT0_CCLIEN = '" + cCliente + "' " + CRLF
	EndIf
	If !Empty(cLoja)
		cSQL += " AND NT0.NT0_CLOJA = '" + cLoja + "' " + CRLF
	EndIf
	If !Empty(cContrato)
		cSQL += " AND NT0.NT0_COD = '" + cContrato + "' " + CRLF
	EndIf
	cSQL +=      " AND NT0.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=   " WHERE NVV.NVV_FILIAL = '" + xFilial("NVV") +"' " + CRLF
	cSQL +=     " AND NVV.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=     " AND NVV.NVV_SITUAC = '1' " + CRLF // FATURA ADICIONAL: Situacao (1-Pendente; 2-Concluido)
	cSQL +=     " 	AND SUBSTRING(NVV.NVV_DTFIMH,1,6) <= '" + cAnoMes + "' " + CRLF
	cSQL +=     " ) NVV"
	cSQL += " GROUP BY NT0_COD, MOEDA_COND, TIPO, NT0_CESCR" + CRLF
	cSQL += " ORDER BY NT0_COD " + CRLF
	
	aRet := JR026OH0(cSQL)	
	If aRet[2]
		lExistCont := .T.
	EndIf
	
	// Retorno os contratos que possuem Casos com condições de Êxito, estes serão apenas citados se existem êxito ou não, sem demonstrar valores
	cSQL := " SELECT NT0_COD, MOEDA_COND, TIPO, NT0_CESCR, SUM(VALOR_MES) VALOR_MES, SUM(VALOR_ACUM) VALOR_ACUM" + CRLF
	cSQL += " FROM ( " + CRLF    
	cSQL +=   "SELECT NT0.NT0_COD, '" + cAnoMes + "' ANOMES, '" + cMoedaNac + "' MOEDA_COND, 'EX' TIPO, NT0.NT0_CESCR, " + CRLF  
	cSQL +=   " 1 VALOR_MES, 1 VALOR_ACUM " + CRLF
	cSQL +=   " FROM " + RetSqlName("NT0") + " NT0 " + CRLF // CONTRATO 
	cSQL +=   " INNER JOIN " + RetSqlName("NUT") + " NUT " + CRLF // CONTRATO X CASO
	cSQL +=     " ON NUT.NUT_FILIAL = '" + xFilial("NUT") +"' " + CRLF
	cSQL +=     " AND NT0.NT0_COD    = NUT.NUT_CCONTR " + CRLF 	// CONTRATO x CASOS DO CONTRATO
	cSQL +=     " AND NUT.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=   " INNER JOIN " + RetSqlName("NVE") + " NVE " + CRLF  // CASO
	cSQL +=     " ON NVE.NVE_FILIAL = '" + xFilial("NVE") +"' " + CRLF
	cSQL +=     " AND NUT.NUT_CCLIEN = NVE.NVE_CCLIEN " + CRLF 	// CASOS DO CONTRATO x CASO
	cSQL +=     " AND NUT.NUT_CLOJA  = NVE.NVE_LCLIEN " + CRLF
	cSQL +=     " AND NUT.NUT_CCASO  = NVE.NVE_NUMCAS " + CRLF
	cSQL +=     " AND NVE.NVE_ENCHON = '2' " + CRLF // ENCERRAMENTO DE HONORÁRIOS NO CASO (1-SIM; 2-NÃO)
	cSQL +=     " AND NVE.NVE_EXITO  = '1' " + CRLF // ÊXITO (1-SIM; 2-NÃO)
	cSQL +=     " AND NVE.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=   " WHERE NT0.NT0_FILIAL = '" + xFilial("NT0") +"' " + CRLF
	cSQL +=     " AND NT0.NT0_ENCH   = '2' " + CRLF // ENCERRAR COBRANÇA DE HONORÁRIOS NO CONTRATO (1-SIM; 2-NÃO)
	cSQL +=     " AND NT0.NT0_SIT    = '2' " + CRLF // Situação Contrato (1-PROVISÓRIO; 2-DEFINITIVO)
	
	If !Empty(cGrpCli)
		cSQL += " AND NT0.NT0_CGRPCL = '" + cGrpCli + "' " + CRLF
	EndIf
	If !Empty(cCliente)
		cSQL += " AND NT0.NT0_CCLIEN = '" + cCliente + "' " + CRLF
	EndIf
	If !Empty(cLoja)
		cSQL += " AND NT0.NT0_CLOJA = '" + cLoja + "' " + CRLF
	EndIf
	If !Empty(cContrato)
		cSQL += " AND NT0.NT0_COD = '" + cContrato + "' " + CRLF
	EndIf
	cSQL +=  " AND NT0.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " ) NT0"
	cSQL +=  " GROUP BY NT0_COD, MOEDA_COND, TIPO, NT0_CESCR" + CRLF
	cSQL +=  " ORDER BY NT0_COD " + CRLF

	aRet :=  JR026OH0(cSQL)
	If aRet[2]
		lExistCont := .T.
	EndIf
	
	// Parcelas de Final de Contrato
	cSQL := " SELECT NT0_COD, MOEDA_COND, TIPO, NT0_CESCR, SUM(VALOR_MES) VALOR_MES, SUM(VALOR_ACUM) VALOR_ACUM" + CRLF
	cSQL +=   " FROM ( " + CRLF    
	cSQL += " SELECT NT0.NT0_COD, SUBSTRING(NT1.NT1_DATAFI,1,6) ANOMES, NT1.NT1_CMOEDA MOEDA_COND, 'FC' TIPO, NT0.NT0_CESCR, " + CRLF
	cSQL +=        " (CASE WHEN SUBSTRING(NT1.NT1_DATAFI,1,6) = '" + cAnoMes + "' THEN NT1.NT1_VALORB ELSE 0 END) VALOR_MES, " + CRLF
	cSQL +=        " (CASE WHEN SUBSTRING(NT1.NT1_DATAFI,1,6) < '" + cAnoMes + "' THEN NT1.NT1_VALORB ELSE 0 END) VALOR_ACUM " + CRLF
	cSQL += " FROM " + RetSqlName("NT0") + " NT0 " + CRLF // CONTRATO
	cSQL += " INNER JOIN " + RetSqlName("NRA") + " NRA " + CRLF // TIPO DE HONORÁRIOS
	cSQL +=    " ON NRA.NRA_FILIAL = '" + xFilial("NRA") +"' " + CRLF
	cSQL +=    " AND NT0.NT0_CTPHON = NRA.NRA_COD " + CRLF	 // CONTRATO x TIPO HONORARIOS
	cSQL +=    " AND NRA.NRA_COBRAF = '1' " + CRLF // TIPO HONORARIO: cobrar fixo (1-Sim; 2-Nao)
	cSQL +=    " AND NRA.D_E_L_E_T_ = ' ' " + CRLF
	cSQL += " INNER JOIN " + RetSqlName("NTH") + " NTH " + CRLF
	cSQL +=    " ON NTH.NTH_FILIAL = '" + xFilial("NTH") +"' " + CRLF
	cSQL +=    " AND NRA.NRA_COD    = NTH.NTH_CTPHON " + CRLF
	cSQL +=    " AND NTH.NTH_CAMPO  = 'NT0_FINAJU' " + CRLF
	cSQL +=    " AND NTH.NTH_VLPAD  = '1' " + CRLF  // CONTRATO: Cobrar no fim do caso (1-Sim; 2-Nao)
	cSQL +=    " AND NTH.D_E_L_E_T_ = ' ' " + CRLF
	cSQL += " INNER JOIN " + RetSqlName("NT1") + " NT1 " + CRLF // VENCIMENTOS DO FIXO
	cSQL +=    " ON NT1.NT1_FILIAL = '" + xFilial("NT1") +"' " + CRLF
	cSQL +=    " AND NT0.NT0_COD    = NT1.NT1_CCONTR " + CRLF	// CONTRATO x VENCIMENTOS DO FIXO
	cSQL +=    " AND NT1.NT1_SITUAC = '1' " + CRLF // VENCIMENTOS FIXO: Situacao Faturamento (1-Pendente; 2-Concluido)
	cSQL +=    " AND SUBSTRING(NT1.NT1_DATAFI,1,6) <= '" + cAnoMes + "' " + CRLF
	cSQL +=    " AND NT1.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " WHERE NT0.NT0_FILIAL = '" + xFilial("NT0") +"' " + CRLF
	cSQL +=    " AND NT0.NT0_ENCH   = '2' " + CRLF // CONTRATO: Encerrar cobranca de honorarios (1-Sim; 2-Nao)
	cSQL +=    " AND NT0.NT0_SIT    = '2' " + CRLF // CONTRATO: situacao Contrato (1-Provisorio; 2-Definitivo)
	If !Empty(cGrpCli)
		cSQL +=  " AND NT0.NT0_CGRPCL = '" + cGrpCli + "' " + CRLF
	EndIf
	If !Empty(cCliente)
		cSQL +=  " AND NT0.NT0_CCLIEN = '" + cCliente + "' " + CRLF
	EndIf
	If !Empty(cLoja)
		cSQL +=  " AND NT0.NT0_CLOJA = '" + cLoja + "' " + CRLF
	EndIf
	If !Empty(cContrato)
		cSQL +=  " AND NT0.NT0_COD = '" + cContrato + "' " + CRLF
	EndIf
	cSQL +=  " AND NT0.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " ) NT0"
	cSQL +=  " GROUP BY NT0_COD, MOEDA_COND, TIPO, NT0_CESCR" + CRLF
	cSQL +=  " ORDER BY NT0_COD " + CRLF

	aRet := JR026OH0(cSQL)
	If aRet[2]
		lExistCont := .T.
	EndIf
	
	// Parcelas Fixas (Partido) - junto com a parcela fixa de Faixa de valores - Qtde de Casos
	cSQL := " SELECT NT0_COD, MOEDA_COND, TIPO, NT0_CESCR, SUM(VALOR_MES) VALOR_MES, SUM(VALOR_ACUM) VALOR_ACUM" + CRLF
	cSQL += " FROM ( " + CRLF    
	cSQL += " SELECT NT0.NT0_COD, SUBSTRING(NT1.NT1_DATAFI,1,6) ANOMES, NT1.NT1_CMOEDA MOEDA_COND, 'FX' TIPO, NT0.NT0_CESCR, " + CRLF
	cSQL +=  " (CASE WHEN SUBSTRING(NT1.NT1_DATAFI,1,6) = '" + cAnoMes + "' THEN NT1.NT1_VALORB ELSE 0 END) VALOR_MES, " + CRLF
	cSQL +=  " (CASE WHEN SUBSTRING(NT1.NT1_DATAFI,1,6) < '" + cAnoMes + "' THEN NT1.NT1_VALORB ELSE 0 END) VALOR_ACUM " + CRLF
	cSQL += " FROM " + RetSqlName("NT0") + " NT0 " + CRLF // CONTRATO
	cSQL += " INNER JOIN " + RetSqlName("NRA") + " NRA " + CRLF // TIPO DE HONORÁRIOS
	cSQL +=    " ON NRA.NRA_FILIAL = '" + xFilial("NRA") +"' " + CRLF
	cSQL +=    " AND NT0.NT0_CTPHON = NRA.NRA_COD " + CRLF	// CONTRATO x TIPO HONORARIOS
	cSQL +=    " AND NRA.NRA_COBRAF = '1' " + CRLF // TIPO HONORARIO: cobrar fixo (1-Sim; 2-Nao)
	cSQL +=    " AND NRA.D_E_L_E_T_ = ' ' " + CRLF
	cSQL += " INNER JOIN " + RetSqlName("NTH") + " NTH " + CRLF
	cSQL +=    " ON NTH.NTH_FILIAL = '" + xFilial("NTH") +"' " + CRLF
	cSQL +=    " AND NRA.NRA_COD    = NTH.NTH_CTPHON " + CRLF
	cSQL +=    " AND NTH.NTH_CAMPO  = 'NT0_PARFIX' " + CRLF
	cSQL +=    " AND NTH.NTH_VLPAD  = '1' " + CRLF  // CONTRATO: Partido Fixo (1-Sim; 2-Nao)
	cSQL +=    " AND NTH.D_E_L_E_T_ = ' ' " + CRLF
	cSQL += " INNER JOIN " + RetSqlName("NT1") + " NT1 " + CRLF // VENCIMENTOS DO FIXO
	cSQL +=    " ON NT1.NT1_FILIAL = '" + xFilial("NT1") +"' " + CRLF
	cSQL +=    " AND NT0.NT0_COD    = NT1.NT1_CCONTR " + CRLF	// CONTRATO x VENCIMENTOS DO FIXO
	cSQL +=    " AND NT1.NT1_SITUAC = '1' " + CRLF // VENCIMENTOS FIXO: Situacao Faturamento (1-Pendente; 2-Concluido)
	cSQL +=    " AND SUBSTRING(NT1.NT1_DATAFI,1,6) <= '" + cAnoMes + "' " + CRLF
	cSQL +=    " AND NT1.D_E_L_E_T_ = ' ' " + CRLF
	cSQL += " WHERE NT0.NT0_FILIAL = '" + xFilial("NT0") +"' " + CRLF
	cSQL +=    " AND NT0.NT0_ENCH   = '2' " + CRLF // CONTRATO: Encerrar cobranca de honorarios (1-Sim; 2-Nao)
	cSQL +=    " AND NT0.NT0_SIT    = '2' " + CRLF // CONTRATO: situacao Contrato (1-Provisorio; 2-Definitivo)
	cSQL +=    " AND EXISTS (SELECT NTHMM.NTH_CTPHON " + CRLF
	cSQL +=                " FROM " + RetSqlName("NTH") + " NTHMM " + CRLF // Desconsidera os contratos Mistos
	cSQL +=                 " WHERE NTHMM.NTH_FILIAL = '" + xFilial("NTH") +"' " + CRLF
	cSQL +=                   " AND NTHMM.NTH_CTPHON = NT0.NT0_CTPHON " + CRLF
	cSQL +=                   " AND NTHMM.NTH_CAMPO  = 'NT0_PEREX' " + CRLF // Periodicidade excedente
	cSQL +=                   " AND NTHMM.NTH_VISIV  = '2' " + CRLF // Visível? (1-Sim; 2-Não)
	cSQL +=                   " AND NTHMM.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=               " ) " + CRLF
	cSQL +=    " AND EXISTS (SELECT NTHMM.NTH_CTPHON " + CRLF
	cSQL +=                " FROM " + RetSqlName("NTH") + " NTHMM " + CRLF // Desconsidera os contratos Minimos
	cSQL +=                 " WHERE NTHMM.NTH_FILIAL = '" + xFilial("NTH") +"' " + CRLF
	cSQL +=                   " AND NTHMM.NTH_CTPHON = NT0.NT0_CTPHON " + CRLF
	cSQL +=                   " AND NTHMM.NTH_CAMPO  = 'NT0_FIXEXC' " + CRLF // Periodicidade excedente
	cSQL +=                   " AND NTHMM.NTH_VLPAD  = '2' " + CRLF // Visível? (1-Sim; 2-Não)
	cSQL +=                   " AND NTHMM.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=               " ) " + CRLF
	If !Empty(cGrpCli)
		cSQL +=  " AND NT0.NT0_CGRPCL = '" + cGrpCli + "' " + CRLF
	EndIf
	If !Empty(cCliente)
		cSQL +=  " AND NT0.NT0_CCLIEN = '" + cCliente + "' " + CRLF
	EndIf
	If !Empty(cLoja)
		cSQL +=  " AND NT0.NT0_CLOJA = '" + cLoja + "' " + CRLF
	EndIf
	If !Empty(cContrato)
		cSQL +=  " AND NT0.NT0_COD = '" + cContrato + "' " + CRLF
	EndIf
	cSQL +=  " AND NT0.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " ) NT0"
	cSQL +=  " GROUP BY NT0_COD, MOEDA_COND, TIPO, NT0_CESCR" + CRLF
	cSQL +=  " ORDER BY NT0_COD " + CRLF
	
	aRet := JR026OH0(cSQL)
	If aRet[2]
		lExistCont := .T.
	EndIf
	
	// Contratos por Valor Limite 
	cSQL := " SELECT NT0_COD, MOEDA_COND, TIPO, NT0_CESCR, SUM(VALOR_MES) VALOR_MES, SUM(VALOR_ACUM) VALOR_ACUM" + CRLF
	cSQL +=   " FROM ( " + CRLF    
	cSQL += " SELECT NT0.NT0_COD, NUE.NUE_ANOMES ANOMES, NUE.NUE_CMOEDA MOEDA_COND, 'LI' TIPO, NT0.NT0_CESCR, " + CRLF
	cSQL +=     " (CASE WHEN NUE.NUE_ANOMES = '" + cAnoMes + "' THEN NUE.NUE_VALOR ELSE 0 END) VALOR_MES, " + CRLF
	cSQL +=     " (CASE WHEN NUE.NUE_ANOMES < '" + cAnoMes + "' THEN NUE.NUE_VALOR ELSE 0 END) VALOR_ACUM " + CRLF
	cSQL += " FROM " + RetSqlName("NUE") + " NUE " + CRLF // TIME SHEET
	cSQL += " INNER JOIN " + RetSqlName("NVE") + " NVE " + CRLF  // CASO
	cSQL +=    " ON NVE.NVE_FILIAL = '" + xFilial("NVE") +"' " + CRLF
	cSQL +=    " AND NUE.NUE_CCLIEN = NVE.NVE_CCLIEN " + CRLF	 //TIME SHEET x CASO
	cSQL +=    " AND NUE.NUE_CLOJA  = NVE.NVE_LCLIEN " + CRLF
	cSQL +=    " AND NUE.NUE_CCASO  = NVE.NVE_NUMCAS " + CRLF
	cSQL +=    " AND NVE.NVE_ENCHON = '2' " + CRLF //  ENCERRAMENTO DE HONORÁRIOS NO CASO (1-SIM; 2-NÃO)
	cSQL +=    " AND NVE.D_E_L_E_T_ = ' ' " + CRLF
	cSQL += " INNER JOIN " + RetSqlName("NRC") + " NRC " + CRLF // ATIVIDADE
	cSQL +=    " ON NRC.NRC_FILIAL = '" + xFilial("NRC") +"' " + CRLF
	cSQL +=    " AND NUE.NUE_CATIVI = NRC.NRC_COD	 " + CRLF	// TIME SHEET x ATIVIDADE
	cSQL +=    " AND NRC.NRC_COBRAR = '1' " + CRLF //  TIPO DE ATIVIDADE COBRÁVEL (1-SIM; 2-NÃO)
	cSQL +=    " AND NRC.D_E_L_E_T_ = ' ' " + CRLF
	cSQL += " INNER JOIN " + RetSqlName("NUT") + " NUT " + CRLF // CONTRATO X CASO
	cSQL +=    " ON NUT.NUT_FILIAL = '" + xFilial("NUT") +"' " + CRLF
	cSQL +=    " AND NUE.NUE_CCLIEN = NUT.NUT_CCLIEN " + CRLF //	 TIME SHEET x CASOS DO CONTRATO
	cSQL +=    " AND NUE.NUE_CLOJA  = NUT.NUT_CLOJA " + CRLF
	cSQL +=    " AND NUE.NUE_CCASO  = NUT.NUT_CCASO " + CRLF
	cSQL +=    " AND NUT.D_E_L_E_T_ = ' ' " + CRLF
	cSQL += " INNER JOIN " + RetSqlName("NT0") + " NT0 " + CRLF // CONTRATO
	cSQL +=    " ON NT0.NT0_FILIAL = '" + xFilial("NT0") +"' " + CRLF
	cSQL +=    " AND NUT.NUT_CCONTR = NT0.NT0_COD " + CRLF // CASOS DO CONTRATO x CONTRATO
	cSQL +=    " AND NT0.NT0_ENCH   = '2' " + CRLF // ENCERRAR COBRANÇA DE HONORÁRIOS NO CONTRATO (1-SIM; 2-NÃO)
	cSQL +=    " AND NT0.NT0_SIT    = '2' " + CRLF // SITUAÇÃO DO CONTRATO (1-PROVISÓRIO; 2-DEFINITIVO)
	If !Empty(cGrpCli)
		cSQL +=  " AND NT0.NT0_CGRPCL = '" + cGrpCli + "' " + CRLF
	EndIf
	If !Empty(cCliente)
		cSQL +=  " AND NT0.NT0_CCLIEN = '" + cCliente + "' " + CRLF
	EndIf
	If !Empty(cLoja)
		cSQL +=  " AND NT0.NT0_CLOJA = '" + cLoja + "' " + CRLF
	EndIf
	If !Empty(cContrato)
		cSQL +=  " AND NT0.NT0_COD = '" + cContrato + "' " + CRLF
	EndIf
	cSQL +=    " AND NT0.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " INNER JOIN " + RetSqlName("NRA") + " NRA " + CRLF // TIPO HONORÁRIOS
	cSQL +=    " ON NRA.NRA_FILIAL = '" + xFilial("NRA") +"' " + CRLF
	cSQL +=    " AND NT0.NT0_CTPHON = NRA.NRA_COD " + CRLF	 // CONTRATO x TIPO HONORARIOS
	cSQL +=    " AND NRA.NRA_NCOBRA = '2' " + CRLF // NÃO COBRÁVEL (1-SIM; 2-NÃO)
	cSQL +=    " AND NRA.NRA_COBRAH = '1' " + CRLF // COBRA HORA (1-SIM; 2-NÃO)
	cSQL +=    " AND NRA.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " WHERE NUE.NUE_FILIAL = '" + xFilial("NUE") +"' " + CRLF
	cSQL +=    " AND NUE.NUE_SITUAC = '1' " + CRLF // SITUAÇÃO DO TIME SHEET (1-PENDENTE; 2-CONCLUÍDO)
	cSQL +=    " AND NOT EXISTS ( " + CRLF
	cSQL +=                    " SELECT NTJ.R_E_C_N_O_ " + CRLF
	cSQL +=                    " FROM " + RetSqlName("NTJ") + " NTJ " + CRLF // DESCONSIDERA AS ATIVIDADES NÃO COBRÁVEIS NO CONTRATO
	cSQL +=                     " WHERE NTJ_FILIAL = '" + xFilial("NTJ") +"' " + CRLF
	cSQL +=                       " AND NTJ.NTJ_CCONTR = NT0.NT0_COD " + CRLF
	cSQL +=                       " AND NTJ.NTJ_CTPATV = NUE.NUE_CATIVI " + CRLF 
	cSQL +=                       " AND NTJ.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=                       " AND NUE.NUE_COBRAR = '1' " + CRLF
	cSQL +=                       " ) " + CRLF
	cSQL +=    " AND EXISTS ( " + CRLF
	cSQL +=                " SELECT NRA.NRA_COD " + CRLF
	cSQL +=                  " FROM " + RetSqlName("NRA") + " NRA " + CRLF
	cSQL +=                 " INNER JOIN " + RetSqlName("NTH") + " NTHVL " + CRLF // CONFIGURAÇÕES DO TIPO DE HONORÁRIOS PARA CONSIDERAR CONTRATOS DE LIMITE GERAL
	cSQL +=                    " ON NTHVL.NTH_FILIAL = '" + xFilial("NTH") +"' " + CRLF
	cSQL +=                   " AND NRA.NRA_COD      = NTHVL.NTH_CTPHON " + CRLF
	cSQL +=                   " AND NTHVL.NTH_CAMPO  = 'NT0_VLRLI' " + CRLF
	cSQL +=                   " AND NTHVL.NTH_VISIV  = '1' " + CRLF
	cSQL +=                   " AND NTHVL.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=                 " WHERE NRA.NRA_FILIAL = '" + xFilial("NRA") +"' " + CRLF
	cSQL +=                   " AND NRA.NRA_COD    = NT0.NT0_CTPHON " + CRLF
	cSQL +=                   " AND NRA.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=                   " ) " + CRLF  
	cSQL +=    " AND NUE.NUE_ANOMES <= '" + cAnoMes + "' " + CRLF
	cSQL +=    " AND NUE.D_E_L_E_T_ = ' ' " + CRLF
	cSQL += " UNION ALL " + CRLF
	cSQL += " SELECT NT0.NT0_COD, SUBSTRING(NT1.NT1_DATAFI,1,6) ANOMES, NT1.NT1_CMOEDA MOEDA_COND, 'LI' TIPO, NT0.NT0_CESCR, " + CRLF
	cSQL +=    " (CASE WHEN SUBSTRING(NT1.NT1_DATAFI,1,6) = '" + cAnoMes + "' THEN NT1.NT1_VALORB ELSE 0 END) VALOR_MES, " + CRLF
	cSQL +=    " (CASE WHEN SUBSTRING(NT1.NT1_DATAFI,1,6) < '" + cAnoMes + "' THEN NT1.NT1_VALORB ELSE 0 END) VALOR_ACUM " + CRLF
	cSQL += " FROM " + RetSqlName("NT0") + " NT0 " + CRLF // CONTRATO
	cSQL += " INNER JOIN " + RetSqlName("NRA") + " NRA " + CRLF // TIPO DE HONORÁRIOS
	cSQL +=    " ON NRA.NRA_FILIAL = '" + xFilial("NRA") +"' " + CRLF
	cSQL +=    " AND NT0.NT0_CTPHON = NRA.NRA_COD " + CRLF	// CONTRATO x TIPO HONORARIOS
	cSQL +=    " AND NRA.NRA_COBRAF = '1' " + CRLF //  TIPO HONORARIO: cobrar fixo (1-Sim; 2-Nao)
	cSQL +=    " AND NRA.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " INNER JOIN " + RetSqlName("NTH") + " NTH " + CRLF
	cSQL +=    " ON NTH.NTH_FILIAL = '" + xFilial("NTH") +"' " + CRLF
	cSQL +=    " AND NRA.NRA_COD    = NTH.NTH_CTPHON " + CRLF
	cSQL +=    " AND NTH.NTH_CAMPO  = 'NT0_VLRLI' " + CRLF // CONTRATO DO TIPO VALOR LIMITE
	cSQL +=    " AND NTH.NTH_VISIV  = '1' " + CRLF
	cSQL +=    " AND NTH.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " INNER JOIN " + RetSqlName("NT1") + " NT1 " + CRLF // VENCIMENTOS DO FIXO
	cSQL +=    " ON NT1.NT1_FILIAL = '" + xFilial("NT1") +"' " + CRLF
	cSQL +=    " AND NT0.NT0_COD    = NT1.NT1_CCONTR " + CRLF	// CONTRATO x VENCIMENTOS DO FIXO
	cSQL +=    " AND NT1.NT1_SITUAC = '1' " + CRLF // VENCIMENTOS FIXO: Situacao Faturamento (1-Pendente; 2-Concluido)
	cSQL +=    " AND SUBSTRING(NT1.NT1_DATAFI,1,6) <= '" + cAnoMes + "' " + CRLF
	cSQL +=    " AND NT1.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " WHERE NT0.NT0_FILIAL = '" + xFilial("NT0") +"' " + CRLF
	cSQL +=    " AND NT0.NT0_ENCH   = '2' " + CRLF // CONTRATO: Encerrar cobranca de honorarios (1-Sim; 2-Nao)
	cSQL +=    " AND NT0.NT0_SIT    = '2' " + CRLF // CONTRATO: situacao Contrato (1-Provisorio; 2-Definitivo)
	If !Empty(cGrpCli)
		cSQL +=  " AND NT0.NT0_CGRPCL = '" + cGrpCli + "' " + CRLF
	EndIf
	If !Empty(cCliente)
		cSQL +=  " AND NT0.NT0_CCLIEN = '" + cCliente + "' " + CRLF
	EndIf
	If !Empty(cLoja)
		cSQL +=  " AND NT0.NT0_CLOJA = '" + cLoja + "' " + CRLF
	EndIf
	If !Empty(cContrato)
		cSQL +=  " AND NT0.NT0_COD = '" + cContrato + "' " + CRLF
	EndIf
	cSQL +=  " AND NT0.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " ) NT0"
	cSQL +=  " GROUP BY NT0_COD, MOEDA_COND, TIPO, NT0_CESCR" + CRLF
	cSQL +=  " ORDER BY NT0_COD " + CRLF

	aRet := JR026OH0(cSQL)
	If aRet[2]
		lExistCont := .T.
	EndIf
	
	// Parcelas (Pré-definido e Ocorrência) - junto com a parcelas fixa de Faixa de valores - Qtde de Casos
	cSQL := " SELECT NT0_COD, MOEDA_COND, TIPO, NT0_CESCR, SUM(VALOR_MES) VALOR_MES, SUM(VALOR_ACUM) VALOR_ACUM" + CRLF
	cSQL +=   " FROM ( " + CRLF    
	cSQL += " SELECT NT0.NT0_COD, SUBSTRING(NT1.NT1_DATAFI,1,6) ANOMES, NT1.NT1_CMOEDA MOEDA_COND, 'PO' TIPO, NT0.NT0_CESCR, " + CRLF
	cSQL +=  " (CASE WHEN SUBSTRING(NT1.NT1_DATAFI,1,6) = '" + cAnoMes + "' THEN NT1.NT1_VALORB ELSE 0 END) VALOR_MES, " + CRLF
	cSQL +=  " (CASE WHEN SUBSTRING(NT1.NT1_DATAFI,1,6) < '" + cAnoMes + "' THEN NT1.NT1_VALORB ELSE 0 END) VALOR_ACUM " + CRLF
	cSQL += " FROM " + RetSqlName("NT0") + " NT0 " + CRLF // CONTRATO
	cSQL += " INNER JOIN " + RetSqlName("NRA") + " NRA " + CRLF // TIPO DE HONORÁRIOS
	cSQL +=    " ON NRA.NRA_FILIAL = '" + xFilial("NRA") +"' " + CRLF
	cSQL +=    " AND NT0.NT0_CTPHON = NRA.NRA_COD " + CRLF	// CONTRATO x TIPO HONORARIOS
	cSQL +=    " AND NRA.NRA_COBRAF = '1' " + CRLF // TIPO HONORARIO: cobrar fixo (1-Sim; 2-Nao)
	cSQL +=    " AND NRA.NRA_PARCAT = '2' " + CRLF // NÃO GERA PARCELAS AUTOMATICAMENTE
	cSQL +=    " AND NRA.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " INNER JOIN " + RetSqlName("NT1") + " NT1 " + CRLF // VENCIMENTOS DO FIXO
	cSQL +=    " ON NT1.NT1_FILIAL = '" + xFilial("NT1") +"' " + CRLF
	cSQL +=    " AND NT0.NT0_COD    = NT1.NT1_CCONTR " + CRLF	// CONTRATO x VENCIMENTOS DO FIXO
	cSQL +=    " AND NT1.NT1_SITUAC = '1' " + CRLF // VENCIMENTOS FIXO: Situacao Faturamento (1-Pendente; 2-Concluido)
	cSQL +=    " AND SUBSTRING(NT1.NT1_DATAFI,1,6) <= '" + cAnoMes + "' " + CRLF
	cSQL +=    " AND NT1.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " WHERE NT0.NT0_FILIAL = '" + xFilial("NT0") +"' " + CRLF
	cSQL +=    " AND NT0.NT0_ENCH   = '2' " + CRLF // CONTRATO: Encerrar cobranca de honorarios (1-Sim; 2-Nao)
	cSQL +=    " AND NT0.NT0_SIT    = '2' " + CRLF // CONTRATO: situacao Contrato (1-Provisorio; 2-Definitivo)
	cSQL +=    " AND NOT EXISTS (SELECT NTHMM.NTH_CTPHON " + CRLF
	cSQL +=                      " FROM " + RetSqlName("NTH") + " NTHMM " + CRLF // Desconsidera os contratos de Final de Contrato
	cSQL +=                      " WHERE NTHMM.NTH_FILIAL = '" + xFilial("NTH") +"' " + CRLF
	cSQL +=                       " AND NTHMM.NTH_CTPHON = NT0.NT0_CTPHON " + CRLF
	cSQL +=                       " AND NTHMM.NTH_CAMPO  = 'NT0_FINAJU' " + CRLF // Periodicidade excedente
	cSQL +=                       " AND NTHMM.NTH_VLPAD  = '1' " + CRLF // Visível? (1-Sim; 2-Não)
	cSQL +=                       " AND NTHMM.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=                   " ) " + CRLF
	If !Empty(cGrpCli)
		cSQL +=  " AND NT0.NT0_CGRPCL = '" + cGrpCli + "' " + CRLF
	EndIf
	If !Empty(cCliente)
		cSQL +=  " AND NT0.NT0_CCLIEN = '" + cCliente + "' " + CRLF
	EndIf
	If !Empty(cLoja)
		cSQL +=  " AND NT0.NT0_CLOJA = '" + cLoja + "' " + CRLF
	EndIf
	If !Empty(cContrato)
		cSQL +=  " AND NT0.NT0_COD = '" + cContrato + "' " + CRLF
	EndIf
	cSQL +=  " AND NT0.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " ) NT0"
	cSQL +=  " GROUP BY NT0_COD, MOEDA_COND, TIPO, NT0_CESCR" + CRLF
	cSQL +=  " ORDER BY NT0_COD " + CRLF

	aRet := JR026OH0(cSQL)
	If aRet[2]
		lExistCont := .T.
	EndIf
	
	// Query para contratos definitivos POR HORA (Contratos de limite por fatura (exceto os que possuem combinação com outro tipo) serão contemplados aqui)
	cSQL := " SELECT NT0_COD, MOEDA_COND, TIPO, NT0_CESCR, SUM(VALOR_MES) VALOR_MES, SUM(VALOR_ACUM) VALOR_ACUM" + CRLF
	cSQL += " FROM ( " + CRLF    
	cSQL += " SELECT NT0.NT0_COD, NUE.NUE_ANOMES ANOMES, NUE.NUE_CMOEDA MOEDA_COND, 'HR' TIPO, NT0.NT0_CESCR, " + CRLF
	cSQL +=        " (CASE WHEN NUE.NUE_ANOMES = '" + cAnoMes + "' THEN NUE.NUE_VALOR ELSE 0 END) VALOR_MES, " + CRLF
	cSQL +=        " (CASE WHEN NUE.NUE_ANOMES < '" + cAnoMes + "' THEN NUE.NUE_VALOR ELSE 0 END) VALOR_ACUM " + CRLF      
	cSQL += " FROM " + RetSqlName("NUE") + " NUE " + CRLF // TIME SHEET 
	cSQL += " INNER JOIN " + RetSqlName("NVE") + " NVE " + CRLF // CASO
	cSQL +=    " ON NVE.NVE_FILIAL = '" + xFilial("NVE") +"' " + CRLF
	cSQL +=    " AND NUE.NUE_CCLIEN = NVE.NVE_CCLIEN " + CRLF	// TIME SHEET x CASO
	cSQL +=    " AND NUE.NUE_CLOJA  = NVE.NVE_LCLIEN " + CRLF
	cSQL +=    " AND NUE.NUE_CCASO  = NVE.NVE_NUMCAS " + CRLF
	cSQL +=    " AND NVE.NVE_ENCHON = '2' " + CRLF // ENCERRAMENTO DE HONORÁRIOS NO CASO (1-SIM; 2-NÃO)
	cSQL +=    " AND NVE.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " INNER JOIN " + RetSqlName("NRC") + " NRC " + CRLF // TIPO DE ATIVIDADE 
	cSQL +=    " ON NRC.NRC_FILIAL = '" + xFilial("NRC") +"' " + CRLF
	cSQL +=    " AND NUE.NUE_CATIVI = NRC.NRC_COD " + CRLF		// TIME SHEET x ATIVIDADE
	cSQL +=    " AND NRC.NRC_COBRAR = '1' " + CRLF // TIPO DE ATIVIDADE COBRÁVEL (1-SIM; 2-NÃO)
	cSQL +=    " AND NRC.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " INNER JOIN " + RetSqlName("NUT") + " NUT " + CRLF // CONTRATO X CASO
	cSQL +=    " ON NUT.NUT_FILIAL = '" + xFilial("NUT") +"' " + CRLF
	cSQL +=    " AND NUE.NUE_CCLIEN = NUT.NUT_CCLIEN " + CRLF	// TIME SHEET x CASOS DO CONTRATO
	cSQL +=    " AND NUE.NUE_CLOJA  = NUT.NUT_CLOJA " + CRLF
	cSQL +=    " AND NUE.NUE_CCASO  = NUT.NUT_CCASO " + CRLF
	cSQL +=    " AND NUT.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " INNER JOIN " + RetSqlName("NT0") + " NT0 " + CRLF // CONTRATO
	cSQL +=    " ON NT0.NT0_FILIAL = '" + xFilial("NT0") +"' " + CRLF
	cSQL +=    " AND NUT.NUT_CCONTR = NT0.NT0_COD	" + CRLF	// CASOS DO CONTRATO x CONTRATO
	cSQL +=    " AND NT0.NT0_ENCH   = '2' " + CRLF // ENCERRAR COBRANÇA DE HONORÁRIOS NO CONTRATO (1-SIM; 2-NÃO)
	cSQL +=    " AND NT0.NT0_SIT    = '2' " + CRLF // SITUAÇÃO CONTRATO (1-PROVISÓRIO; 2-DEFINITIVO)
	If !Empty(cGrpCli)
		cSQL +=  " AND NT0.NT0_CGRPCL = '" + cGrpCli + "' " + CRLF
	EndIf
	If !Empty(cCliente)
		cSQL +=  " AND NT0.NT0_CCLIEN = '" + cCliente + "' " + CRLF
	EndIf
	If !Empty(cLoja)
		cSQL +=  " AND NT0.NT0_CLOJA = '" + cLoja + "' " + CRLF
	EndIf
	If !Empty(cContrato)
		cSQL +=  " AND NT0.NT0_COD = '" + cContrato + "' " + CRLF
	EndIf
	cSQL +=    " AND NT0.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " INNER JOIN " + RetSqlName("NRA") + " NRA " + CRLF // TIPO HONORÁRIOS
	cSQL +=     " ON NRA.NRA_FILIAL = '" + xFilial("NRA") +"' " + CRLF 
	cSQL +=    " AND NT0.NT0_CTPHON = NRA.NRA_COD	" + CRLF	// CONTRATO x TIPO HONORARIOS
	cSQL +=    " AND NRA.NRA_NCOBRA = '2' " + CRLF // NÃO COBRÁVEL (1-SIM; 2-NÃO)
	cSQL +=    " AND NRA.NRA_COBRAH = '1' " + CRLF // COBRA HORA (1-SIM; 2-NÃO)
	cSQL +=    " AND NRA.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " WHERE NUE.NUE_FILIAL = '" + xFilial("NUE") +"' " + CRLF 
	cSQL +=    " AND NUE.NUE_SITUAC = '1' " + CRLF // SITUAÇÃO DO TIME SHEET (1-PENDENTE; 2-CONCLUÍDO)
	cSQL +=    " AND NUE.NUE_VALOR > 0 " + CRLF 
	cSQL +=    " AND NOT EXISTS ( " + CRLF
	cSQL +=                      " SELECT NTJ.R_E_C_N_O_ " + CRLF 
	cSQL +=                        " FROM " + RetSqlName("NTJ") + " NTJ " + CRLF // DESCONSIDERA AS ATIVIDADES NÃO COBRÁVEIS NO CONTRATO
	cSQL +=                        " WHERE NTJ_FILIAL = '" + xFilial("NTJ") + "' " + CRLF
	cSQL +=                          " AND NTJ.NTJ_CCONTR = NT0.NT0_COD " + CRLF
	cSQL +=                          " AND NTJ.NTJ_CTPATV = NUE.NUE_CATIVI " + CRLF 
	cSQL +=                          " AND NTJ.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=                          " AND NUE.NUE_COBRAR = '1' " + CRLF
	cSQL +=                          " ) " + CRLF 
	cSQL +=    " AND NOT EXISTS ((" + CRLF
	cSQL +=                     " SELECT NRA.NRA_COD " + CRLF
	cSQL +=                     " FROM " + RetSqlName("NRA") + " NRA " + CRLF
	cSQL +=                      " INNER JOIN " + RetSqlName("NTH") + " NTHVL " + CRLF // CONFIGURAÇÕES DO TIPO DE HONORÁRIOS PARA DESCONSIDERAR CONTRATOS DE LIMITE GERAL
	cSQL +=                        " ON NTHVL.NTH_FILIAL = '" + xFilial("NTH") +"' " + CRLF
	cSQL +=                        " AND NRA.NRA_COD      = NTHVL.NTH_CTPHON " + CRLF
	cSQL +=                        " AND NTHVL.NTH_CAMPO  = 'NT0_VLRLI' " + CRLF
	cSQL +=                        " AND NTHVL.NTH_VISIV  = '1' " + CRLF
	cSQL +=                        " AND NTHVL.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=                     " WHERE NRA.NRA_FILIAL = '" + xFilial("NRA") +"' " + CRLF
	cSQL +=                        " AND NRA.NRA_COD    = NT0.NT0_CTPHON " + CRLF
	cSQL +=                        " AND NRA.D_E_L_E_T_ = ' ') " + CRLF
	cSQL +=                     " UNION " + CRLF
	cSQL +=                     " (SELECT NRA.NRA_COD " + CRLF
	cSQL +=                     " FROM " + RetSqlName("NRA") + " NRA " + CRLF
	cSQL +=                      " INNER JOIN " + RetSqlName("NTH") + " NTHFV " + CRLF // CONFIGURAÇÕES DO TIPO DE HONORÁRIOS PARA DESCONSIDERAR CONTRATOS DE FAIXA DE VALORES
	cSQL +=                        " ON NTHFV.NTH_FILIAL = '" + xFilial("NTH") +"' " + CRLF
	cSQL +=                        " AND NRA.NRA_COD      = NTHFV.NTH_CTPHON " + CRLF
	cSQL +=                        " AND NTHFV.NTH_CAMPO  = 'NT0_TPFX' " + CRLF
	cSQL +=                        " AND NTHFV.NTH_VISIV  = '1' " + CRLF
	cSQL +=                        " AND NTHFV.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=                     " WHERE NRA.NRA_FILIAL = '" + xFilial("NRA") +"' " + CRLF
	cSQL +=                        " AND NRA.NRA_COD    = NT0.NT0_CTPHON " + CRLF
	cSQL +=                        " AND NRA.D_E_L_E_T_ = ' ') " + CRLF
	cSQL +=                     " UNION " + CRLF
	cSQL +=                     " (SELECT NRA.NRA_COD " + CRLF
	cSQL +=                     " FROM " + RetSqlName("NRA") + " NRA " + CRLF
	cSQL +=                      " INNER JOIN " + RetSqlName("NTH") + " NTHMM " + CRLF // CONFIGURAÇÕES DO TIPO DE HONORÁRIOS PARA DESCONSIDERAR CONTRATOS DE MÍNIMO E MISTO
	cSQL +=                        " ON NTHMM.NTH_FILIAL = '" + xFilial("NTH") +"' " + CRLF
	cSQL +=                        " AND NRA.NRA_COD      = NTHMM.NTH_CTPHON " + CRLF
	cSQL +=                        " AND NRA.NRA_COBRAF   = '1' " + CRLF
	cSQL +=                        " AND NTHMM.NTH_CAMPO  = 'NT0_TPCEXC' " + CRLF
	cSQL +=                        " AND NTHMM.NTH_VISIV  = '1' " + CRLF
	cSQL +=                        " AND NTHMM.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=                      " WHERE NRA.NRA_FILIAL = '" + xFilial("NRA") +"' " + CRLF
	cSQL +=                        " AND NRA.NRA_COD    = NT0.NT0_CTPHON " + CRLF
	cSQL +=                        " AND NRA.D_E_L_E_T_ = ' ' " + CRLF  
	cSQL +=                    " )) " + CRLF   
	cSQL +=    " AND NUE.NUE_ANOMES <= '" + cAnoMes + "' " + CRLF
	cSQL +=    " AND NUE.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=    " ) NT0"
	cSQL +=  " GROUP BY NT0_COD, MOEDA_COND, TIPO, NT0_CESCR" + CRLF
	cSQL +=  " ORDER BY NT0_COD " + CRLF

	aRet := JR026OH0(cSQL)
	If aRet[2]
		lExistCont := .T.
	EndIf
	
	// Query para contratos provisórios POR HORA (Contratos de limite por fatura (exceto os que possuem combinação com outro tipo) serão contemplados aqui)
	cSQL := " SELECT NT0_COD, MOEDA_COND, TIPO, NT0_CESCR, SUM(VALOR_MES) VALOR_MES, SUM(VALOR_ACUM) VALOR_ACUM" + CRLF
	cSQL += " FROM ( " + CRLF    
	cSQL += "SELECT NT0.NT0_COD, NUE.NUE_ANOMES ANOMES, NUE.NUE_CMOEDA MOEDA_COND, 'PR' TIPO, NT0.NT0_CESCR, " + CRLF
	cSQL +=       " (CASE WHEN NUE.NUE_ANOMES = '" + cAnoMes + "' THEN NUE.NUE_VALOR ELSE 0 END) VALOR_MES, " + CRLF
	cSQL +=       " (CASE WHEN NUE.NUE_ANOMES < '" + cAnoMes + "' THEN NUE.NUE_VALOR ELSE 0 END) VALOR_ACUM " + CRLF      
	cSQL += " FROM " + RetSqlName("NUE") + " NUE " + CRLF // TIME SHEET 
	cSQL += " INNER JOIN " + RetSqlName("NVE") + " NVE " + CRLF // CASO
	cSQL +=   " ON NVE.NVE_FILIAL = '" + xFilial("NVE") +"' " + CRLF
	cSQL +=   " AND NUE.NUE_CCLIEN = NVE.NVE_CCLIEN " + CRLF	// TIME SHEET x CASO
	cSQL +=   " AND NUE.NUE_CLOJA  = NVE.NVE_LCLIEN " + CRLF
	cSQL +=   " AND NUE.NUE_CCASO  = NVE.NVE_NUMCAS " + CRLF
	cSQL +=   " AND NVE.NVE_ENCHON = '2' " + CRLF // ENCERRAMENTO DE HONORÁRIOS NO CASO (1-SIM; 2-NÃO)
	cSQL +=   " AND NVE.D_E_L_E_T_ = ' ' " + CRLF
	cSQL += " INNER JOIN " + RetSqlName("NRC") + " NRC " + CRLF // TIPO DE ATIVIDADE 
	cSQL +=   " ON NRC.NRC_FILIAL = '" + xFilial("NRC") +"' " + CRLF
	cSQL +=   " AND NUE.NUE_CATIVI = NRC.NRC_COD " + CRLF		// TIME SHEET x ATIVIDADE
	cSQL +=   " AND NRC.NRC_COBRAR = '1' " + CRLF // TIPO DE ATIVIDADE COBRÁVEL (1-SIM; 2-NÃO)
	cSQL +=   " AND NRC.D_E_L_E_T_ = ' ' " + CRLF
	cSQL += " INNER JOIN " + RetSqlName("NUT") + " NUT " + CRLF // CONTRATO X CASO
	cSQL +=   " ON NUT.NUT_FILIAL = '" + xFilial("NUT") +"' " + CRLF
	cSQL +=   " AND NUE.NUE_CCLIEN = NUT.NUT_CCLIEN " + CRLF	// TIME SHEET x CASOS DO CONTRATO
	cSQL +=   " AND NUE.NUE_CLOJA  = NUT.NUT_CLOJA " + CRLF
	cSQL +=   " AND NUE.NUE_CCASO  = NUT.NUT_CCASO " + CRLF
	cSQL +=   " AND NUT.D_E_L_E_T_ = ' ' " + CRLF
	cSQL += " INNER JOIN " + RetSqlName("NT0") + " NT0 " + CRLF // CONTRATO
	cSQL +=   " ON NT0.NT0_FILIAL = '" + xFilial("NT0") +"' " + CRLF
	cSQL +=   " AND NUT.NUT_CCONTR = NT0.NT0_COD	" + CRLF	// CASOS DO CONTRATO x CONTRATO
	cSQL +=   " AND NT0.NT0_ENCH   = '2' " + CRLF // ENCERRAR COBRANÇA DE HONORÁRIOS NO CONTRATO (1-SIM; 2-NÃO)
	cSQL +=   " AND NT0.NT0_SIT    = '1' " + CRLF // SITUAÇÃO CONTRATO (1-PROVISÓRIO; 2-DEFINITIVO)
	If !Empty(cGrpCli)
		cSQL += " AND NT0.NT0_CGRPCL = '" + cGrpCli + "' " + CRLF
	EndIf
	If !Empty(cCliente)
		cSQL += " AND NT0.NT0_CCLIEN = '" + cCliente + "' " + CRLF
	EndIf
	If !Empty(cLoja)
		cSQL += " AND NT0.NT0_CLOJA = '" + cLoja + "' " + CRLF
	EndIf
	If !Empty(cContrato)
		cSQL += " AND NT0.NT0_COD = '" + cContrato + "' " + CRLF
	EndIf
	cSQL +=  " AND NT0.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " INNER JOIN " + RetSqlName("NRA") + " NRA " + CRLF // TIPO HONORÁRIOS
	cSQL +=    " ON NRA.NRA_FILIAL = '" + xFilial("NRA") +"' " + CRLF 
	cSQL +=    " AND NT0.NT0_CTPHON = NRA.NRA_COD	" + CRLF	// CONTRATO x TIPO HONORARIOS
	cSQL +=    " AND NRA.NRA_NCOBRA = '2' " + CRLF // NÃO COBRÁVEL (1-SIM; 2-NÃO)
	cSQL +=    " AND NRA.NRA_COBRAH = '1' " + CRLF // COBRA HORA (1-SIM; 2-NÃO)
	cSQL +=    " AND NRA.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " WHERE NUE.NUE_FILIAL = '" + xFilial("NUE") +"' " + CRLF 
	cSQL +=    " AND NUE.NUE_SITUAC = '1' " + CRLF // SITUAÇÃO DO TIME SHEET (1-PENDENTE; 2-CONCLUÍDO)
	cSQL +=    " AND NUE.NUE_VALOR > 0 " + CRLF 
	cSQL +=    " AND NOT EXISTS ( " + CRLF
	cSQL +=                    " SELECT NTJ.R_E_C_N_O_ " + CRLF 
	cSQL +=                      " FROM " + RetSqlName("NTJ") + " NTJ " + CRLF // DESCONSIDERA AS ATIVIDADES NÃO COBRÁVEIS NO CONTRATO
	cSQL +=                      " WHERE NTJ_FILIAL = '" + xFilial("NTJ") + "' " + CRLF
	cSQL +=                        " AND NTJ.NTJ_CCONTR = NT0.NT0_COD " + CRLF
	cSQL +=                        " AND NTJ.NTJ_CTPATV = NUE.NUE_CATIVI " + CRLF 
	cSQL +=                        " AND NTJ.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=                        " AND NUE.NUE_COBRAR = '1' " + CRLF
	cSQL +=                        " ) " + CRLF 
	cSQL +=   " AND NOT EXISTS ((" + CRLF
	cSQL +=                   " SELECT NRA.NRA_COD " + CRLF
	cSQL +=                   " FROM " + RetSqlName("NRA") + " NRA " + CRLF
	cSQL +=                   " INNER JOIN " + RetSqlName("NTH") + " NTHVL " + CRLF // CONFIGURAÇÕES DO TIPO DE HONORÁRIOS PARA DESCONSIDERAR CONTRATOS DE LIMITE GERAL
	cSQL +=                      " ON NTHVL.NTH_FILIAL = '" + xFilial("NTH") +"' " + CRLF
	cSQL +=                      " AND NRA.NRA_COD      = NTHVL.NTH_CTPHON " + CRLF
	cSQL +=                      " AND NTHVL.NTH_CAMPO  = 'NT0_VLRLI' " + CRLF
	cSQL +=                      " AND NTHVL.NTH_VISIV  = '1' " + CRLF
	cSQL +=                      " AND NTHVL.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=                   " WHERE NRA.NRA_FILIAL = '" + xFilial("NRA") +"' " + CRLF
	cSQL +=                      " AND NRA.NRA_COD    = NT0.NT0_CTPHON " + CRLF
	cSQL +=                      " AND NRA.D_E_L_E_T_ = ' ') " + CRLF
	cSQL +=                   " UNION " + CRLF
	cSQL +=                   " (SELECT NRA.NRA_COD " + CRLF
	cSQL +=                   " FROM " + RetSqlName("NRA") + " NRA " + CRLF
	cSQL +=                    " INNER JOIN " + RetSqlName("NTH") + " NTHFV " + CRLF // CONFIGURAÇÕES DO TIPO DE HONORÁRIOS PARA DESCONSIDERAR CONTRATOS DE FAIXA DE VALORES
	cSQL +=                      " ON NTHFV.NTH_FILIAL = '" + xFilial("NTH") +"' " + CRLF
	cSQL +=                      " AND NRA.NRA_COD      = NTHFV.NTH_CTPHON " + CRLF
	cSQL +=                      " AND NTHFV.NTH_CAMPO  = 'NT0_TPFX' " + CRLF
	cSQL +=                      " AND NTHFV.NTH_VISIV  = '1' " + CRLF
	cSQL +=                      " AND NTHFV.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=                   " WHERE NRA.NRA_FILIAL = '" + xFilial("NRA") +"' " + CRLF
	cSQL +=                      " AND NRA.NRA_COD    = NT0.NT0_CTPHON " + CRLF
	cSQL +=                      " AND NRA.D_E_L_E_T_ = ' ') " + CRLF
	cSQL +=                   " UNION " + CRLF
	cSQL +=                   " (SELECT NRA.NRA_COD " + CRLF
	cSQL +=                   " FROM " + RetSqlName("NRA") + " NRA " + CRLF
	cSQL +=                   " INNER JOIN " + RetSqlName("NTH") + " NTHMM " + CRLF // CONFIGURAÇÕES DO TIPO DE HONORÁRIOS PARA DESCONSIDERAR CONTRATOS DE MÍNIMO E MISTO
	cSQL +=                     " ON NTHMM.NTH_FILIAL = '" + xFilial("NTH") +"' " + CRLF
	cSQL +=                     " AND NRA.NRA_COD      = NTHMM.NTH_CTPHON " + CRLF
	cSQL +=                     " AND NRA.NRA_COBRAF   = '1' " + CRLF
	cSQL +=                     " AND NTHMM.NTH_CAMPO  = 'NT0_TPCEXC' " + CRLF
	cSQL +=                     " AND NTHMM.NTH_VISIV  = '1' " + CRLF
	cSQL +=                     " AND NTHMM.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=                   " WHERE NRA.NRA_FILIAL = '" + xFilial("NRA") +"' " + CRLF
	cSQL +=                     " AND NRA.NRA_COD    = NT0.NT0_CTPHON " + CRLF
	cSQL +=                     " AND NRA.D_E_L_E_T_ = ' ' " + CRLF  
	cSQL +=                     " )) " + CRLF   
	cSQL +=   " AND NUE.NUE_ANOMES <= '" + cAnoMes + "' " + CRLF
	cSQL +=   " AND NUE.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=   " ) NT0"
	cSQL +=   " GROUP BY NT0_COD, MOEDA_COND, TIPO, NT0_CESCR" + CRLF
	cSQL +=   " ORDER BY NT0_COD " + CRLF

	aRet := JR026OH0(cSQL)
	If aRet[2]
		lExistCont := .T.
	EndIf
	
	// Contratos MISTO
	cSQL := " SELECT NT0_COD, MOEDA_COND, TIPO, NT0_CESCR, SUM(VALOR_MES) VALOR_MES, SUM(VALOR_ACUM) VALOR_ACUM" + CRLF
	cSQL += " FROM ( " + CRLF    
	cSQL += " SELECT NT0.NT0_COD, SUBSTRING(NT1.NT1_DATAFI,1,6) ANOMES, NT1.NT1_CMOEDA MOEDA_COND, 'MT' TIPO, NT0.NT0_CESCR, " + CRLF
	cSQL +=        " (CASE WHEN SUBSTRING(NT1.NT1_DATAFI,1,6) = '" + cAnoMes + "' THEN NT1.NT1_VALORB ELSE 0 END) VALOR_MES, " + CRLF
	cSQL +=        " (CASE WHEN SUBSTRING(NT1.NT1_DATAFI,1,6) < '" + cAnoMes + "' THEN NT1.NT1_VALORB ELSE 0 END) VALOR_ACUM " + CRLF
	cSQL += " FROM " + RetSqlName("NT0") + " NT0 " + CRLF // CONTRATO
	cSQL +=  " INNER JOIN " + RetSqlName("NRA") + " NRA " + CRLF // TIPO DE HONORÁRIOS
	cSQL +=    " ON NRA.NRA_FILIAL = '" + xFilial("NRA") +"' " + CRLF
	cSQL +=    " AND NT0.NT0_CTPHON = NRA.NRA_COD " + CRLF	 // CONTRATO x TIPO HONORARIOS
	cSQL +=    " AND NRA.NRA_COBRAF = '1' " + CRLF // TIPO HONORARIO: cobrar fixo (1-Sim; 2-Nao)
	cSQL +=    " AND NRA.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " INNER JOIN " + RetSqlName("NTH") + " NTH " + CRLF
	cSQL +=    " ON NTH.NTH_FILIAL = '" + xFilial("NTH") +"' " + CRLF
	cSQL +=    " AND NRA.NRA_COD    = NTH.NTH_CTPHON " + CRLF
	cSQL +=    " AND NTH.NTH_CAMPO  = 'NT0_PEREX' " + CRLF // Periodicidade excedente
	cSQL +=    " AND NTH.NTH_VISIV  = '1' " + CRLF  // CONTRATO: Misto (1-Sim; 2-Nao)
	cSQL +=    " AND NTH.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " INNER JOIN " + RetSqlName("NT1") + " NT1 " + CRLF // VENCIMENTOS DO FIXO
	cSQL +=     " ON NT1.NT1_FILIAL = '" + xFilial("NT1") +"' " + CRLF
	cSQL +=    " AND NT0.NT0_COD    = NT1.NT1_CCONTR " + CRLF	// CONTRATO x VENCIMENTOS DO FIXO
	cSQL +=    " AND NT1.NT1_SITUAC = '1' " + CRLF // VENCIMENTOS FIXO: Situacao Faturamento (1-Pendente; 2-Concluido)
	cSQL +=    " AND SUBSTRING(NT1.NT1_DATAFI,1,6) <= '" + cAnoMes + "' " + CRLF
	cSQL +=    " AND NT1.D_E_L_E_T_ = ' ' " + CRLF
	cSQL += " WHERE NT0.NT0_FILIAL = '" + xFilial("NT0") +"' " + CRLF
	cSQL +=    " AND NT0.NT0_ENCH   = '2' " + CRLF // CONTRATO: Encerrar cobranca de honorarios (1-Sim; 2-Nao)
	cSQL +=    " AND NT0.NT0_SIT    = '2' " + CRLF // CONTRATO: situacao Contrato (1-Provisorio; 2-Definitivo)
	cSQL +=    " AND NOT EXISTS (SELECT NTHMM.NTH_CTPHON " + CRLF
	cSQL +=                    " FROM " + RetSqlName("NTH") + " NTHMM " + CRLF // Desconsidera os contratos Minimos
	cSQL +=                     " WHERE NTHMM.NTH_FILIAL = '" + xFilial("NTH") +"' " + CRLF
	cSQL +=                       " AND NTHMM.NTH_CTPHON = NT0.NT0_CTPHON " + CRLF
	cSQL +=                       " AND NTHMM.NTH_CAMPO  = 'NT0_FIXEXC' " + CRLF // Periodicidade excedente
	cSQL +=                       " AND NTHMM.NTH_VLPAD  = '1' " + CRLF // Visível? (1-Sim; 2-Não)
	cSQL +=                       " AND NTHMM.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=                   " ) " + CRLF
	If !Empty(cGrpCli)
		cSQL +=  " AND NT0.NT0_CGRPCL = '" + cGrpCli + "' " + CRLF
	EndIf
	If !Empty(cCliente)
		cSQL +=  " AND NT0.NT0_CCLIEN = '" + cCliente + "' " + CRLF
	EndIf
	If !Empty(cLoja)
		cSQL +=  " AND NT0.NT0_CLOJA = '" + cLoja + "' " + CRLF
	EndIf
	If !Empty(cContrato)
		cSQL +=  " AND NT0.NT0_COD = '" + cContrato + "' " + CRLF
	EndIf
	cSQL +=    " AND NT0.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " ) NT0"
	cSQL +=  " GROUP BY NT0_COD, MOEDA_COND, TIPO, NT0_CESCR" + CRLF
	cSQL +=  " ORDER BY NT0_COD " + CRLF

	aRet := JR026OH0(cSQL)
	If aRet[2]
		lExistCont := .T.
	EndIf
	
	// Contratos MÍNIMO
	cSQL := " SELECT NT0_COD, MOEDA_COND, TIPO, NT0_CESCR, SUM(VALOR_MES) VALOR_MES, SUM(VALOR_ACUM) VALOR_ACUM" + CRLF
	cSQL +=   " FROM ( " + CRLF    
	cSQL += " SELECT NT0.NT0_COD, SUBSTRING(NT1.NT1_DATAFI,1,6) ANOMES, NT1.NT1_CMOEDA MOEDA_COND, 'MI' TIPO, NT0.NT0_CESCR, " + CRLF
	cSQL +=        " (CASE WHEN SUBSTRING(NT1.NT1_DATAFI,1,6) = '" + cAnoMes + "' THEN NT1.NT1_VALORB ELSE 0 END) VALOR_MES, " + CRLF
	cSQL +=        " (CASE WHEN SUBSTRING(NT1.NT1_DATAFI,1,6) < '" + cAnoMes + "' THEN NT1.NT1_VALORB ELSE 0 END) VALOR_ACUM " + CRLF
	cSQL +=   " FROM " + RetSqlName("NT0") + " NT0 " + CRLF // CONTRATO
	cSQL +=  " INNER JOIN " + RetSqlName("NRA") + " NRA " + CRLF // TIPO DE HONORÁRIOS
	cSQL +=     " ON NRA.NRA_FILIAL = '" + xFilial("NRA") +"' " + CRLF
	cSQL +=    " AND NT0.NT0_CTPHON = NRA.NRA_COD " + CRLF	// CONTRATO x TIPO HONORARIOS
	cSQL +=    " AND NRA.NRA_COBRAF = '1' " + CRLF // TIPO HONORARIO: cobrar fixo (1-Sim; 2-Nao)
	cSQL +=    " AND NRA.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " INNER JOIN " + RetSqlName("NTH") + " NTH " + CRLF
	cSQL +=     " ON NTH.NTH_FILIAL = '" + xFilial("NTH") +"' " + CRLF
	cSQL +=    " AND NRA.NRA_COD    = NTH.NTH_CTPHON " + CRLF
	cSQL +=    " AND NTH.NTH_CAMPO  = 'NT0_FIXEXC' " + CRLF // Fixo e excedente juntos, o que caracteriza o tipo MÍNIMO
	cSQL +=    " AND NTH.NTH_VLPAD  = '1' " + CRLF // Valor padrão (1-Sim; 2-Não) -> Sim = tipo mínimo
	cSQL +=    " AND NTH.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " INNER JOIN " + RetSqlName("NT1") + " NT1 " + CRLF // VENCIMENTOS DO FIXO
	cSQL +=     " ON NT1.NT1_FILIAL = '" + xFilial("NT1") +"' " + CRLF
	cSQL +=    " AND NT0.NT0_COD    = NT1.NT1_CCONTR " + CRLF // CONTRATO x VENCIMENTOS DO FIXO
	cSQL +=    " AND NT1.NT1_SITUAC = '1' " + CRLF // VENCIMENTOS FIXO: Situacao Faturamento (1-Pendente; 2-Concluido)
	cSQL +=    " AND SUBSTRING(NT1.NT1_DATAFI,1,6) <= '" + cAnoMes + "' " + CRLF
	cSQL +=    " AND NT1.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " WHERE NT0.NT0_FILIAL = '" + xFilial("NT0") +"' " + CRLF
	cSQL +=    " AND NT0.NT0_ENCH   = '2' " + CRLF // CONTRATO: Encerrar cobranca de honorarios (1-Sim; 2-Nao)
	cSQL +=    " AND NT0.NT0_SIT    = '2' " + CRLF // CONTRATO: situacao Contrato (1-Provisorio; 2-Definitivo)
	If !Empty(cGrpCli)
		cSQL +=  " AND NT0.NT0_CGRPCL = '" + cGrpCli + "' " + CRLF
	EndIf
	If !Empty(cCliente)
		cSQL +=  " AND NT0.NT0_CCLIEN = '" + cCliente + "' " + CRLF
	EndIf
	If !Empty(cLoja)
		cSQL +=  " AND NT0.NT0_CLOJA = '" + cLoja + "' " + CRLF
	EndIf
	If !Empty(cContrato)
		cSQL +=  " AND NT0.NT0_COD = '" + cContrato + "' " + CRLF
	EndIf
	cSQL +=    " AND NT0.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " ) NT0"
	cSQL +=  " GROUP BY NT0_COD, MOEDA_COND, TIPO, NT0_CESCR" + CRLF
	cSQL +=  " ORDER BY NT0_COD " + CRLF

	aRet := JR026OH0(cSQL)
	If aRet[2]
		lExistCont := .T.
	EndIf
	
	// Query para contratos NÃO COBRÁVEIS
	cSQL := " SELECT NT0_COD, MOEDA_COND, TIPO, NT0_CESCR, SUM(VALOR_MES) VALOR_MES, SUM(VALOR_ACUM) VALOR_ACUM" + CRLF
	cSQL +=   " FROM ( " + CRLF    
	cSQL += " SELECT NT0.NT0_COD, NUE.NUE_ANOMES ANOMES, NUE.NUE_CMOEDA MOEDA_COND, 'NC' TIPO, NT0.NT0_CESCR, " + CRLF
	cSQL +=  " (CASE WHEN NUE.NUE_ANOMES = '" + cAnoMes + "' THEN NUE.NUE_VALOR ELSE 0 END) VALOR_MES, " + CRLF
	cSQL +=  " (CASE WHEN NUE.NUE_ANOMES < '" + cAnoMes + "' THEN NUE.NUE_VALOR ELSE 0 END) VALOR_ACUM " + CRLF
	cSQL +=  " FROM " + RetSqlName("NUE") + " NUE " + CRLF // TIME SHEET
	cSQL +=  " INNER JOIN " + RetSqlName("NVE") + " NVE " + CRLF  // CASO
	cSQL +=     " ON NVE.NVE_FILIAL = '" + xFilial("NVE") + "' " + CRLF
	cSQL +=     " AND NUE.NUE_CCLIEN = NVE.NVE_CCLIEN " + CRLF	// TIME SHEET x CASO
	cSQL +=     " AND NUE.NUE_CLOJA  = NVE.NVE_LCLIEN " + CRLF
	cSQL +=     " AND NUE.NUE_CCASO  = NVE.NVE_NUMCAS " + CRLF
	cSQL +=     " AND NVE.NVE_ENCHON = '2' " + CRLF // ENCERRAMENTO DE HONORÁRIOS NO CASO (1-SIM; 2-NÃO)
	cSQL +=     " AND NVE.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " INNER JOIN " + RetSqlName("NRC") + " NRC " + CRLF // ATIVIDADE
	cSQL +=     " ON NRC.NRC_FILIAL = '" + xFilial("NRC") + "' " + CRLF
	cSQL +=     " AND NUE.NUE_CATIVI = NRC.NRC_COD " + CRLF		// TIME SHEET x ATIVIDADE
	cSQL +=     " AND NRC.NRC_COBRAR = '1' " + CRLF // TIPO DE ATIVIDADE COBRÁVEL (1-SIM; 2-NÃO)
	cSQL +=     " AND NRC.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " INNER JOIN " + RetSqlName("NUT") + " NUT " + CRLF // CONTRATO X CASO
	cSQL +=     " ON NUT.NUT_FILIAL = '" + xFilial("NUT") + "' " + CRLF
	cSQL +=     " AND NUE.NUE_CCLIEN = NUT.NUT_CCLIEN " + CRLF	// TIME SHEET x CASOS DO CONTRATO
	cSQL +=     " AND NUE.NUE_CLOJA  = NUT.NUT_CLOJA " + CRLF
	cSQL +=     " AND NUE.NUE_CCASO  = NUT.NUT_CCASO " + CRLF
	cSQL +=     " AND NUT.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " INNER JOIN " + RetSqlName("NT0") + " NT0 " + CRLF // CONTRATO
	cSQL +=     " ON NT0.NT0_FILIAL = '" + xFilial("NT0") + "' " + CRLF
	cSQL +=     " AND NUT.NUT_CCONTR = NT0.NT0_COD " + CRLF		// CASOS DO CONTRATO x CONTRATO
	cSQL +=     " AND NT0.NT0_ENCH   = '2' " + CRLF // ENCERRAR COBRANÇA DE HONORÁRIOS NO CONTRATO (1-SIM; 2-NÃO)
	cSQL +=     " AND NT0.NT0_SIT    = '2' " + CRLF // situacao Contrato (1-PROVISÓRIO; 2-DEFINITIVO)
	If !Empty(cGrpCli)
		cSQL +=   " AND NT0.NT0_CGRPCL = '" + cGrpCli + "' " + CRLF
	EndIf
	If !Empty(cCliente)
		cSQL +=   " AND NT0.NT0_CCLIEN = '" + cCliente + "' " + CRLF
	EndIf
	If !Empty(cLoja)
		cSQL +=   " AND NT0.NT0_CLOJA = '" + cLoja + "' " + CRLF
	EndIf
	If !Empty(cContrato)
		cSQL +=   " AND NT0.NT0_COD = '" + cContrato + "' " + CRLF
	EndIf
	cSQL +=     " AND NT0.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=   " INNER JOIN " + RetSqlName("NRA") + " NRA " + CRLF // TIPO HONORÁRIOS
	cSQL +=      " ON NRA.NRA_FILIAL = '" + xFilial("NRA") + "' " + CRLF
	cSQL +=     " AND NT0.NT0_CTPHON = NRA.NRA_COD " + CRLF	// CONTRATO x TIPO HONORARIOS
	cSQL +=     " AND NRA.NRA_NCOBRA = '1' " + CRLF // NÃO COBRÁVEL (1-SIM; 2-NÃO)
	cSQL +=     " AND NRA.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=   " WHERE NUE.NUE_FILIAL = '" + xFilial("NUE") + "' " + CRLF
	cSQL +=     " AND NUE.NUE_SITUAC = '1' " + CRLF // SITUAÇÃO DO TIME SHEET (1-PENDENTE; 2-CONCLUÍDO)
	cSQL +=     " AND NOT EXISTS ( " + CRLF
	cSQL +=                     " SELECT NTJ.R_E_C_N_O_ " + CRLF
	cSQL +=                       " FROM " + RetSqlName("NTJ") + " NTJ " + CRLF // DESCONSIDERA AS ATIVIDADES NÃO COBRÁVEIS NO CONTRATO
	cSQL +=                        " WHERE NTJ_FILIAL = '" + xFilial("NTJ") + "' " + CRLF
	cSQL +=                        " AND NTJ.NTJ_CCONTR = NT0.NT0_COD " + CRLF
	cSQL +=                        " AND NTJ.NTJ_CTPATV = NUE.NUE_CATIVI " + CRLF
	cSQL +=                        " AND NTJ.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=                        " AND NUE.NUE_COBRAR = '1' " + CRLF
	cSQL +=                    " ) " + CRLF
	cSQL +=     " AND NUE.NUE_ANOMES <= '" + cAnoMes + "' " + CRLF
	cSQL +=     " AND NUE.D_E_L_E_T_ = ' ' " + CRLF
	cSQL +=  " ) NT0"
	cSQL +=  " GROUP BY NT0_COD, MOEDA_COND, TIPO, NT0_CESCR" + CRLF
	cSQL +=   " ORDER BY NT0_COD " + CRLF

	aRet := JR026OH0(cSQL)
	If aRet[2]
		lExistCont := .T.
	EndIf
	
	aRet[2] := lExistCont
	
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JR026OH0
Rotina para o preenchimento da tabela OH0 que será utilizada no relatório
Analítico.

@Param cSQL				Query a ser utilizada para coletar os dados e inserir da tabela OH0


@Return lRet     		Indica se a inserção obteve êxito. 

@author Jacques Alves Xavier
@since 04/06/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JR026OH0(cSQL)
	Local lRet       := .T.
	Local lExistCont := .F.
	Local aRet       := {}
	Local aArea      := GetArea()
	Local aAreaOH0   := OH0->( GetArea() )
	Local cQryRes    := GetNextAlias()
	Local nValMes    := 0
	Local nValAcum   := 0
	Local cContrAtu  := ""
	Local cSQLNW3    := ""
	Local cFiltro    := ""
	Local aResSQL    := {}
	Local cEscr      := ""
	Local nLimite    := 0
	Local nLimGeral  := 0
	Local nSaldoIni  := 0
	Local cMoedaLim  := ''

	// Query será aproveitada abaixo para identificar a junção dos contratos
	cSQLNW3 := " SELECT MAX(NW3_CJCONT) NW3_CJCONT " + CRLF
	cSQLNW3 +=  " FROM " + RetSqlName("NW3") + " NW3 " + CRLF
	cSQLNW3 += " WHERE NW3_FILIAL = '" + xFilial("NW3") + "' " + CRLF
	cSQLNW3 +=  " AND NW3.D_E_L_E_T_ = ' ' " + CRLF

	cSQL := ChangeQuery( cSQL )
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cSQL ), cQryRes, .T., .F. )
	
	While !(cQryRes)->(EOF())
		
		lExistCont := .T.
		
		// Converte os valores na moeda nacional
		nValMes  := JA201FConv(cMoedaNac, (cQryRes)->MOEDA_COND, (cQryRes)->VALOR_MES, '1', Date())[1]
		nValAcum := JA201FConv(cMoedaNac, (cQryRes)->MOEDA_COND, (cQryRes)->VALOR_ACUM, '1', Date())[1] 
		
		If cContrAtu <> (cQryRes)->NT0_COD
			
			cFiltro :=    " AND NW3.NW3_CCONTR = '" + (cQryRes)->NT0_COD + "' "
			
			aResSQL := JurSQL(cSQLNW3 + cFiltro, {"NW3_CJCONT"})
			
			If Empty(aResSQL[1][1])
				cEscr := (cQryRes)->NT0_CESCR
			Else
				cEscr := JurGetDados("NW2", 1, xFilial("NW2") + aResSQL[1][1], "NW2_CESCR")
			EndIf 
			
			If (cQryRes)->TIPO == 'LI'
				nLimGeral := JurGetDados("NT0", 1, xFilial("NT0") + (cQryRes)->NT0_COD, "NT0_VLRLI")
				nSaldoIni := JurGetDados("NT0", 1, xFilial("NT0") + (cQryRes)->NT0_COD, "NT0_SALDOI")
				cMoedaLim := JurGetDados("NT0", 1, xFilial("NT0") + (cQryRes)->NT0_COD, "NT0_CMOELI")
				nLimite := nLimGeral - nSaldoIni
				nLimite := JA201FConv(cMoedaNac, cMoedaLim, nLimite, '1', Date())[1] 
				If (nValMes + nValAcum) > nLimite
					nValMes := nLimite
					nValAcum := 0
				EndIf
			EndIf
			
			cContrAtu := (cQryRes)->NT0_COD
			
		EndIf

		RecLock("OH0", .T.)
		OH0->OH0_FILIAL := xFilial("OH0")
		OH0->OH0_COD    := GetSxEnum("OH0", "OH0_COD")
		OH0->OH0_CUSER 	:= __CUSERID
		OH0->OH0_DATA  	:= Date()
		OH0->OH0_CCONTR	:= (cQryRes)->NT0_COD
		OH0->OH0_TIPO   := (cQryRes)->TIPO
		OH0->OH0_VLAM   := nValMes
		OH0->OH0_VLACUM := nValAcum
		OH0->OH0_CESCR  := cEscr
		OH0->OH0_CJCONT := aResSQL[1][1]
		
		OH0->(MsUnlock())
		OH0->(DbCommit())
		
		(cQryRes)->(dbSkip())
		
	EndDo

	(cQryRes)->( dbcloseArea() )
	
	RestArea( aAreaOH0 )
	RestArea(aArea)
	
	aAdd(aRet , lRet)
	aAdd(aRet , lExistCont)

Return aRet 
 
