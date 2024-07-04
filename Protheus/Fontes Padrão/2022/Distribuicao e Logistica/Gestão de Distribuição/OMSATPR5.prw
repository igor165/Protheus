#include 'TOTVS.ch'
#include 'OMSATPR5.ch'


/*/{Protheus.doc} OMSATPR2
** Programa responsavel pelo envio dos pedidos da carga para sequenciamento no TPR
@author Equipe OMS
@since 13/01/2022
/*/
Function OMSATPR5()
	Local lRet 		:= .T.
	Local aErrors 	:= {}
	Local lRot 		:= .F.
	Local lPergun 	:= .T.
	Local llogTPR	:= SuperGetMV("MV_TPRCLOG",.F.,.T.)

	If DAK->DAK_FEZNF == '2' .And. DAK->DAK_ACECAR == '2'.And. ;
		(DAK->DAK_BLQCAR == '2' .Or. DAK-> DAK_BLQCAR == ' ') .And. ;
		(DAK->DAK_JUNTOU =='MANUAL' .Or. DAK->DAK_JUNTOU == 'ASSOCI' .Or. DAK->DAK_JUNTOU == 'JUNTOU')

		DMS->(DbSetOrder(3))
		If DMS->(DbSeek(FwXFilial("DMS")+"DAK"+DAK->DAK_FILIAL+DAK->DAK_COD))
			lPergun := .F.
			If MsgYesNo(STR0003)//"A carga já possui roteirização TPR. Deseja roteirizar novamente?" 
				lRot := .T.
				FwMsgRun( ,{|| OMSTPRCan(DMS->DMS_FILIAL+DMS->DMS_FILROT+DMS->DMS_IDROT, .F.) } ,STR0001,STR0002)//"Aguarde"  "Excluindo roteirização."
			EndIf
		EndIf

		If lPergun .And. MsgYesNo(STR0004) //"A roteirização TPR pode alterar a ordem das entregas da carga. Confirma?"
			lRot := .T.
		EndIf
		If lRot
			Pergunte("OMSATPR5",.F.)
			lRet := OMSTPR5Pln(@aErrors, llogTPR)
		EndIf
	Else
		Aadd(aErrors, STR0005)//"O status da carga não permite roteirização TPR."
		lRet := .F.
	EndIf

	If !lRet .And. !Empty(aErrors)
		OmsShowWng(aErrors)
	EndIf

Return lRet


/*/{Protheus.doc} OMSTPR5Pln
** Inicio do processamento para envio
@author Equipe OMS
@since 13/01/2022
/*/
Function OMSTPR5Pln(aErrors, llogTPR)
	Local oDadosTPR  := Nil
	Local nLatiOri 	 := 0
	Local nLongOri 	 := 0
	Local cJson 	 := ""
	Local cResult 	 := ""
	Local aDoctosDMS := {}
	Local lRet 		 := .T.
	Local cIdentOri  := AllTrim(SM0->M0_CODFIL) +"-"+ AllTrim(SM0->M0_FILIAL) +"-"+ AllTrim(SM0->M0_NOME)
	Local cIdRot     := ""

	Local cMVCriter := 1 //Criterio
	Local cMVPlanej := MV_PAR01 //Planejamento para
	Local cMVTmpCar := MV_PAR02 //Horario Carregamento
	Local nMVFunFil := MV_PAR03 //Funcionamento filial
	Local cMVRetFil := MV_PAR04 //Considera Retorno
	Local cMVQtdCar := 999 //Qtd Max de Carregamentos
	Local cMVKmMaxC := 9999 //Km Max entre carregamentos
	Local cMVKmMaxD := 9999 //Km Max entre entregas
	Local cMVQtdDes := 999 //Qtd Max Entregas
	Local cMVTmpMin := MV_PAR05 //Tempo Min Servico
	Local cMVTmpMax := MV_PAR06 //Tempo Max Servico
	Local cMVTmpDes := MV_PAR07 //Horario final das entregas
	Local nMVFunEnt := MV_PAR08 //Funcionamento entregas
	Local cMVPed 	:= MV_PAR09 //Calcula Pedagio
	Local cMVOrdUF 	:= MV_PAR10 //Entrega ordenada por estado UF
	Local cMVQtDias := MV_PAR11 //Dias para entrega
	Local cInicioCar := ""
	Local cFimEntreg := ""

	Local cOperOri  := "UNRESTRICTED"
	Local cOperDes  := "UNRESTRICTED"

	Local cAliasTPR := ""
	Local cUFOri 	:= ""
	Local aStrTab   := {}
	Local oTTCar 	:= Nil
	Local oObjTTCar := Nil

	aStrTab 	:= TTItCarg()
	
	lRet := OMSTPRVPA2(@aErrors)
	
	If Empty(DAK->DAK_CAMINH)
		Aadd(aErrors, STR0006)//"É necessário informar o veículo da carga para realizar o planejamento da roteirização."
		lRet := .F.
	ElseIf lRet

		oDadosTPR := TMSBCATPRNeolog():New()
		If oDadosTPR:Auth()
			cAliasTPR := GetNextAlias()
			GeraTTCar(aStrTab, @cAliasTPR, @oTTCar, @oObjTTCar)

			//Dados dos pedidos da carga
			OMSTPR5Dad(@cAliasTPR, llogTPR, @oTTCar)

			//Coordenadas da filial
			lRet := OMSCoorFil(llogTPR, oDadosTPR, cIdentOri,@nLatiOri, @nLongOri, @cUFOri, @aErrors)

			OMSTPRCLOG(llogTPR, "OMSATPR5", STR0011 +  STR0032 + CValToChar(lRet))//"Resultado da busca das coordenadas da filial: "

			IF Empty(nLatiOri) .Or. Empty(nLongOri)
				Aadd(aErrors, STR0044) //"Não foi possível geolocalizar a origem das rotas."
				OMSTPRCLOG(llogTPR, "OMSATPR5", STR0011 + STR0044)//"Não foi possível geolocalizar a origem das rotas."
				lRet := .F.
			EndIf

			If lRet
				//Coordenadas dos clientes
				lRet := OMSCoorCli(llogTPR, oDadosTPR, cAliasTPR, @aErrors)
				
				OMSTPRCLOG(llogTPR, "OMSATPR5", STR0011 +  STR0033 + CValToChar(lRet))//"Resultado da busca das coordenadas dos clientes: "

				If lRet
					//Obtem todos os ids das SC9 dos pedidos
					OMSATPR5It(@aDoctosDMS, llogTPR)
					If Empty(aDoctosDMS)
						Aadd(aErrors, STR0007)//"Os pedidos da carga não estão disponíveis para o planejamento de rotas."
						lRet := .F.
						//OMSTPRCLOG(llogTPR, "OMSATPR5", STR0011 + STR0034)//"Falha da busca dos ids da SC9."
					EndIf
					If lRet
						cOperOri  := OMSOperFun(nMVFunFil)
						cOperDes  := OMSOperFun(nMVFunEnt)

						cInicioCar := OMSTPRDtIn(cMVTmpCar,cMVPlanej)
						cFimEntreg := OMSTPRDtFn(cMVTmpDes,cMVQtDias,cMVPlanej)

						lRet := OMSATPR5En(llogTPR, @aErrors, @oDadosTPR, cAliasTPR, cIdentOri, cUFOri, cPaisLoc, nLatiOri, nLongOri ,;
											 cOperOri, cOperDes,  cInicioCar, cFimEntreg)

						If lRet
							lRet := OMSATPR5Vc(@oDadosTPR)
							If lRet
								//Restricoes enviados para o objeto de post
								OMSTPRAddR(@oDadosTPR, cMVQtdCar, cMVQtdDes, cMVKmMaxC, cMVKmMaxD, cMVOrdUF)//Restricoes

								//Opcoes enviados para o objeto de post
								OMSTPRAddO(@oDadosTPR, cMVCriter, cMVPlanej, cMVRetFil, cMVTmpMin, cMVTmpMax, cMVPed, "SEQUENCE")//Options

								//Grava DMR e DMS para bloquear itens e identifica-los no callback
								lRet := OMSGrvRot(@oDadosTPR,aDoctosDMS, @cIdRot, @aErrors, DAK->DAK_FILIAL+DAK->DAK_COD, "DAK", "1")

								If lRet
									FwMsgRun( ,{|| lRet	:= oDadosTPR:PostRouting() } ,STR0001, STR0010)//Aguarde //"Realizando o Planejamento de Rotas"

									If !lRet   
										cJson   := oDadosTPR:GetJsonEnv()
										cResult  := oDadosTPR:GetError() 
										Aadd(aErrors, oDadosTPR:GetError())
									Else 
										cResult := oDadosTPR:GetResult() 
										cJson   := oDadosTPR:GetJsonEnv()
									EndIf 
									OMSTPRADLU(@oDadosTPR, FWxFilial("DMR") , "DMR", "Routing", cIdRot, cJson, cResult, lRet)
									
									If !lRet
										OMSUpdRot(cIdRot, @aErrors)
									ElseIf DAK->DAK_INTTPR != "1"
										RecLock("DAK",.F.)
											DAK->DAK_INTTPR := "1"
										DAK->(MsUnlock())				
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			DelTabTmp(cAliasTPR,oTTCar)
		EndIf
	EndIf
	If !Empty(cAliasTPR) .And. Select(cAliasTPR) > 0
		(cAliasTPR)->(DbCloseArea())
	EndIf
Return lRet


/*/{Protheus.doc} OMSTPR5Dad
** Insere os dados dos pedidos numa temporaria
@author Equipe OMS
@since 13/01/2022
/*/
Static Function OMSTPR5Dad(cAliasTPR, llogTPR, oTTCar)
	Local cQuery := ""
	Local cOperSQL   := IIf(Upper(TcGetDb())$'ORACLE',.F.,.T.)
	Local lOMSTPR01	 := ExistBlock("OMSTPR01")
	Local nTamA1COD := TamSX3('A1_COD')[1]
	Local nTamA1LOJ := TamSX3('A1_LOJA')[1]
	Local nTamA2COD := TamSX3('A2_COD')[1]
	Local nTamA2LOJ := TamSX3('A2_LOJA')[1]

	cQuery += " SELECT SC9.C9_FILIAL AS TMP_FILIAL,"
	cQuery += 		" SC9.C9_PEDIDO AS TMP_PEDIDO,"
	cQuery += " CASE"
	cQuery +=      " WHEN (SC5.C5_REDESP IS NOT NULL"
	cQuery +=            " AND SC5.C5_REDESP <> ' ') THEN SA4.A4_FILIAL"
	cQuery +=      " WHEN (SC5.C5_REDESP IS NULL"
	cQuery +=            " OR SC5.C5_REDESP = ' ')"
	cQuery +=           " AND SC5.C5_TIPO IN ('B',"
	cQuery +=                               " 'D') THEN SA2.A2_FILIAL"
	cQuery +=      " ELSE SA1.A1_FILIAL" //A filial do cliente do pedido precisa ser a mesma da filial do cliente entrega
	cQuery +=  " END AS TMP_FILFCL,"
	cQuery +=  " CASE"
	cQuery +=      " WHEN (SC5.C5_REDESP IS NOT NULL"
	cQuery +=            " AND SC5.C5_REDESP <> ' ') THEN SC5.C5_REDESP"
	cQuery +=      " WHEN (SC5.C5_REDESP IS NULL"
	cQuery +=            " OR SC5.C5_REDESP = ' ')"
	cQuery +=           " AND SC5.C5_TIPO IN ('B',"
	cQuery +=                               " 'D') THEN SC5.C5_CLIENT"
	cQuery +=      " ELSE SC5.C5_CLIENT"
	cQuery +=  " END AS TMP_CODFCL,"
	cQuery +=  " CASE"
	cQuery +=      " WHEN (SC5.C5_REDESP IS NOT NULL"
	cQuery +=            " AND SC5.C5_REDESP <> ' ') THEN ' '"
	cQuery +=      " WHEN (SC5.C5_REDESP IS NULL"
	cQuery +=            " OR SC5.C5_REDESP = ' ')"
	cQuery +=           " AND SC5.C5_TIPO IN ('B',"
	cQuery +=                               " 'D') THEN SC5.C5_LOJAENT"
	cQuery +=      " ELSE SC5.C5_LOJAENT"
	cQuery +=  " END AS TMP_LOJFCL,"
	cQuery += 	" CASE"
	cQuery += 		" WHEN (SC5.C5_REDESP IS NOT NULL"
	cQuery += 			" AND SC5.C5_REDESP <> ' ') THEN SA4.A4_NREDUZ"
	cQuery += 		" WHEN (SC5.C5_REDESP IS NULL"
	cQuery += 			" OR SC5.C5_REDESP = ' ')"
	cQuery += 			" AND SC5.C5_TIPO IN ('B','D') THEN SA2.A2_NREDUZ"
	cQuery += 		" ELSE SA1.A1_NREDUZ"
	cQuery += 	" END AS TMP_NOMFAN,"
	cQuery += 	" CASE"
	cQuery += 		" WHEN (SC5.C5_REDESP IS NOT NULL"
	cQuery += 			" AND SC5.C5_REDESP <> ' ') THEN SA4.A4_EST"
	cQuery += 		" WHEN (SC5.C5_REDESP IS NULL"
	cQuery += 			" OR SC5.C5_REDESP = ' ')"
	cQuery += 			" AND SC5.C5_TIPO IN ('B',"
	cQuery += 				" 'D') THEN SA2.A2_EST"
	cQuery += 		" ELSE SA1.A1_EST"
	cQuery += 	" END AS TMP_EST,"

	//Manter este trecho comentado. Na regra do Cockpit, quando SB5.B5_TIPUNIT = 1 é granel e envia peso bruto do produto
	//Como no OMSA200 não tem este tratamento no fonte, nao sera implementado no momento
	//Essa regra está no OMSATPR1 - Envio de Pedidos TPR
	// cQuery += 	" CASE"
	// cQuery += 		" WHEN SB5.B5_TIPUNIT = '1' THEN SUM(SB1.B1_PESO)"
	// cQuery += 			" ELSE SUM(C9_QTDLIB * SB1.B1_PESO)"
	// cQuery += 		" END AS TMP_PESOLQ,"
	// cQuery += 	" CASE"
	// cQuery += 		" WHEN SB5.B5_TIPUNIT = '1' THEN SUM(SB1.B1_PESBRU)"
	// cQuery += 		" ELSE SUM(C9_QTDLIB * SB1.B1_PESBRU)"
	// cQuery += 		" END AS TMP_PESOBR,"

	cQuery += 		" SUM(C9_QTDLIB * SB1.B1_PESO) AS TMP_PESOLQ,"
	cQuery += 		" SUM(C9_QTDLIB * SB1.B1_PESBRU) AS TMP_PESOBR,"

	If cOperSQL
		cQuery += 	" CASE WHEN "
		cQuery += 		" SUM((SB5.B5_ALTURLC * SB5.B5_LARGLC * SB5.B5_COMPRLC)*C9_QTDLIB) IS NULL THEN 0 "
		cQuery += 		" ELSE SUM((SB5.B5_ALTURLC * SB5.B5_LARGLC * SB5.B5_COMPRLC)*C9_QTDLIB) END AS TMP_VOL ,
	Else
		cQuery += 	" SUM ((NVL(SB5.B5_ALTURLC, 0) * NVL(SB5.B5_LARGLC, 0) * NVL(SB5.B5_COMPRLC, 0))*C9_QTDLIB) AS TMP_VOL,"
	EndIf

	cQuery += 	" CASE
	cQuery += 		" WHEN (SC5.C5_REDESP IS NOT NULL"
	cQuery += 			" AND SC5.C5_REDESP <> ' ') THEN 'SA4'"
	cQuery += 		" WHEN (SC5.C5_REDESP IS NULL"
	cQuery += 			" OR SC5.C5_REDESP = ' ')"
	cQuery += 		" AND SC5.C5_TIPO IN ('B','D') THEN 'SA2'"
	cQuery += 			" ELSE 'SA1'"
	cQuery += 		" END AS TMP_ENTIDA,"
	cQuery += 	" CASE"
	cQuery += 		" WHEN DAR.DAR_LATITU IS NULL THEN ' '"
	cQuery += 			" ELSE DAR.DAR_LATITU"
	cQuery += 		" END AS TMP_LATITU,"
	cQuery += 	" CASE"
	cQuery += 		" WHEN DAR.DAR_LONGIT IS NULL THEN ' '"
	cQuery += 			" ELSE DAR.DAR_LONGIT"
	cQuery += 		" END AS TMP_LONGIT,"
	cQuery += 	" CASE"
	cQuery += 		" WHEN YA_SIGLA IS NULL THEN 'BRA'"
	cQuery += 			" ELSE YA_SIGLA"
	cQuery += 		" END AS TMP_PAIS"
	cQuery += 		" FROM " + RetSqlName("DAI") + " DAI
	cQuery += 			" INNER JOIN " + RetSqlName("SC9") + " SC9 ON SC9.C9_FILIAL = '"+FwXFilial("SC9")+"'"
	cQuery += 				" AND SC9.C9_CARGA = DAI.DAI_COD"
	cQuery += 				" AND SC9.C9_SEQCAR = DAI.DAI_SEQCAR"
	cQuery += 				" AND SC9.C9_SEQENT = DAI.DAI_SEQUEN"
	cQuery += 				" AND SC9.C9_PEDIDO = DAI.DAI_PEDIDO"
	cQuery += 				" AND SC9.D_E_L_E_T_ = ''"
	cQuery += 			" INNER JOIN " + RetSqlName("SC5") + " SC5 ON SC5.C5_FILIAL = SC9.C9_FILIAL
	cQuery += 				" AND SC5.C5_NUM = SC9.C9_PEDIDO"
	cQuery += 				" AND SC5.D_E_L_E_T_ = ''"
	cQuery += 			" INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '"+FwXFilial("SB1")+"'"
	cQuery += 				" AND SB1.B1_COD = SC9.C9_PRODUTO"
	cQuery += 				" AND SB1.D_E_L_E_T_ = ' '"
	cQuery += 			" LEFT JOIN " + RetSqlName("SB5") + " SB5 ON SB5.B5_FILIAL = '"+FwXFilial("SB5")+"'"
	cQuery += 				" AND SB5.B5_COD = SB1.B1_COD"
	cQuery += 				" AND SB5.D_E_L_E_T_ = ' '"
	cQuery += 			" LEFT JOIN " + RetSqlName("SA2") + " SA2 ON SA2.A2_FILIAL = '"+FwXFilial("SA2")+"'"
	cQuery += 				" AND SA2.A2_COD = SC5.C5_CLIENT"
	cQuery += 				" AND SA2.A2_LOJA = SC5.C5_LOJAENT"
	cQuery += 				" AND SA2.D_E_L_E_T_ = ' '"
	cQuery += 			" LEFT JOIN " + RetSqlName("SA1") + " SA1 ON SA1.A1_FILIAL = '"+FwXFilial("SA1")+"'"
	cQuery += 				" AND SA1.A1_COD = SC5.C5_CLIENT"
	cQuery += 				" AND SA1.A1_LOJA = SC5.C5_LOJAENT"
	cQuery += 				" AND SA1.D_E_L_E_T_ = ' '"
	cQuery += 			" LEFT JOIN " + RetSqlName("SA4") + " SA4 ON SA4.A4_FILIAL = '"+FwXFilial("SA4")+"'"
	cQuery += 				" AND SA4.A4_COD = SC5.C5_REDESP"
	cQuery += 				" AND SA4.D_E_L_E_T_ = ' '"
	cQuery += 			" LEFT JOIN " + RetSqlName("SYA") + " SYA ON (SYA.YA_FILIAL = '"+FwXFilial("SYA")+"'"
	cQuery += 				" AND SYA.YA_CODGI = A1_PAIS"
	cQuery += 				" AND SYA.D_E_L_E_T_ = ' ')"
	cQuery += 				" OR (SYA.YA_FILIAL= ''"
	cQuery += 				" AND SYA.YA_CODGI = A2_PAIS"
	cQuery += 				" AND SYA.D_E_L_E_T_ = ' ')"
	cQuery += 			" LEFT JOIN " + RetSqlName("DAR") + " DAR ON "
	cQuery += 				" (((SC5.C5_REDESP IS NULL OR SC5.C5_REDESP = ' ') AND SC5.C5_TIPO NOT IN ('B','D')) "
	cQuery += 					" AND (DAR.DAR_FILENT = A1_FILIAL"
	cQuery += 					" AND SUBSTRING(DAR.DAR_CODENT,1,"+cValtoChar(nTamA1COD)+") = SA1.A1_COD"
	cQuery += 					" AND SUBSTRING(DAR.DAR_CODENT,"+cValtoChar(nTamA1COD+1)+","+cValtoChar(nTamA1LOJ)+") = SA1.A1_LOJA"
	cQuery += 					" AND DAR.DAR_ENTIDA = 'SA1'"
	cQuery += 					" AND DAR.D_E_L_E_T_ = ' '))"
	cQuery += 				" OR (((SC5.C5_REDESP IS NULL OR SC5.C5_REDESP = ' ') AND SC5.C5_TIPO IN ('B','D'))"
	cQuery += 				" AND (DAR.DAR_FILENT = A2_FILIAL"
	cQuery += 					" AND SUBSTRING(DAR.DAR_CODENT,1,"+cValtoChar(nTamA2COD)+") = SA2.A2_COD"
	cQuery += 					" AND SUBSTRING(DAR.DAR_CODENT,"+cValtoChar(nTamA2COD+1)+","+cValtoChar(nTamA2LOJ)+") = SA2.A2_LOJA"
	cQuery += 					" AND DAR.DAR_ENTIDA = 'SA2'"
	cQuery += 					" AND DAR.D_E_L_E_T_ = ' '))"
	cQuery += 				" OR ((SC5.C5_REDESP IS NOT NULL AND SC5.C5_REDESP <> ' ') "
	cQuery += 					" AND (DAR.DAR_FILENT = A4_FILIAL"
	cQuery += 					" AND DAR.DAR_CODENT = SA4.A4_COD"
	cQuery += 					" AND DAR.DAR_ENTIDA = 'SA4')"	
	cQuery += 					" AND DAR.D_E_L_E_T_ = ' ')"

	cQuery += 					" WHERE DAI.DAI_FILIAL = '"+ DAK->DAK_FILIAL +"'"
	cQuery += 						" AND DAI.DAI_COD = '"+ DAK->DAK_COD +"'"
	cQuery += 						" AND DAI.DAI_SEQCAR = '"+ DAK->DAK_SEQCAR +"'"
	cQuery += 						" AND DAI.D_E_L_E_T_ = ''"
	cQuery += 							" GROUP BY C9_FILIAL,"
	cQuery += 							" C9_PEDIDO, "
	//cQuery += 							" SB5.B5_TIPUNIT,"
	cQuery += 							" SC5.C5_TIPO,"
	cQuery += 							" SA1.A1_FILIAL,"
	cQuery += 							" SA2.A2_FILIAL,"
	cQuery += 							" SA4.A4_FILIAL,"
	cQuery += 							" SA4.A4_COD,"
	cQuery += 							" SC5.C5_CLIENT,"
	cQuery += 							" SC5.C5_LOJAENT,"
	cQuery += 							" SC5.C5_REDESP,"
	cQuery += 							" SA2.A2_NREDUZ,"
	cQuery += 							" SA1.A1_NREDUZ,"
	cQuery += 							" SA4.A4_NREDUZ,"
	cQuery += 							" DAR.DAR_ENTIDA,"
	cQuery += 							" SA1.A1_EST,"
	cQuery += 							" SA2.A2_EST,"
	cQuery += 							" SA4.A4_EST,"
	cQuery += 							" DAR.DAR_LATITU,"
	cQuery += 							" DAR.DAR_LONGIT,"
	cQuery += 							" SYA.YA_SIGLA"

	cQuery := ChangeQuery(cQuery)

	WmsQry2Tmp(cAliasTPR,oTTCar:oStruct:aFields,cQuery,oTTCar,,.T.)
	(cAliasTPR)->( dbGoTop() )

	If lOMSTPR01
		ExecBlock("OMSTPR01",.F.,.F.,{cAliasTPR, oTTCar})
		OMSTPRCLOG(llogTPR, "OMSATPR5", STR0011 + STR0029)//"Ponto de entrada OMSTPR01 ativo e executado."
		(cAliasTPR)->( dbGoTop() )
	EndIf

	OMSTPRCLOG(llogTPR, "OMSATPR5", STR0011 + STR0012 + cQuery ) //"TOTVS Planejamento de Rotas(TPR) - " "Query dos dados para roteirização: " 

Return cAliasTPR

/*/{Protheus.doc} OMSCoorFil
** Obtem e salva as coordenadas da filial
@author Equipe OMS
@since 13/01/2022
/*/
Static Function OMSCoorFil(llogTPR, oDadosTPR, cIdent, nLatiOri, nLongOri, cUFOri, aErrors)
	Local lRet 			:= .T.
	Local cPaisFil		:= "BRA"
	Local aCamposSM0 	:= {"M0_ESTENT","M0_CIDENT","M0_CEPENT","M0_ENDENT","M0_BAIRENT"}
	Local aSM0Dados 	:= {}
	Local lOMSTPR02 	:= ExistBlock("OMSTPR02")
	Local aRetPE 		:= {}
	Local cEndBairro    := ""

	If lOMSTPR02
		OMSTPRCLOG(llogTPR, "OMSATPR5", STR0011 + STR0030)//"Ponto de entrada OMSTPR02 ativo e executado."
		aRetPE := ExecBlock("OMSTPR02",.F.,.F.,{DAK->DAK_FILIAL,  DAK->DAK_COD, DAK->DAK_SEQCAR })
		If ValType(aRetPE)=="A" .And. Len(aRetPE) > 0
			lRet := aRetPE[1]
			If !lRet .And. !Empty(aRetPE[2])
				Aadd(aErrors, aRetPE[2])
			Else
				nLatiOri := aRetPE[3]
				nLongOri := aRetPE[4]
			EndIf
		EndIf
	Else

		OMSTPRCLOG(llogTPR, "OMSATPR5", STR0011 + STR0035 + CValToChar(cEmpAnt) + STR0036 + CValToChar(cFilAnt))//"Empresa de origem:"e filial de origem: 

		aSM0Dados := FWSM0Util():GetSM0Data(cEmpAnt, cFilAnt, aCamposSM0)
		If !Empty(aSM0Dados)
			lRet :=	OMSValSM0(aSM0Dados[1][2],aSM0Dados[2][2],aSM0Dados[3][2], aSM0Dados[4][2], @aErrors)
			OMSTPRCLOG(llogTPR, "OMSATPR5", STR0011 + STR0037 + CValToChar(lRet))//"Sucesso na busca dos dados da filial de origem: "
		EndIf
		If lRet
			DAR->(DbSetOrder(1))
			If DAR->(!DbSeek(xFilial("DAR")+Space(Len(cFilAnt))+"SM0"+cFilAnt))
				OMSTPRCLOG(llogTPR, "OMSATPR5", STR0011 + STR0038 )//"Buscar coordenadas para filial."

				cEndBairro := AllTrim(aSM0Dados[4][2]) + IIF(!Empty(aSM0Dados[5][2]),"," + AllTrim(aSM0Dados[5][2]),"")

				FWMsgRun(,{|| lRet := OMSTPRGeoc(llogTPR, oDadosTPR, cIdent,.T., cPaisFil,aSM0Dados[1][2],AllTrim(aSM0Dados[2][2]),aSM0Dados[3][2], cEndBairro,;
												"","SM0",cFilAnt, @aErrors,@nLatiOri,@nLongOri) }, STR0008 + cFilAnt, STR0001) //"Aguarde" //"Aguarde""Buscando coordenadas para a filial "
			Else
				OMSTPRCLOG(llogTPR, "OMSATPR5", STR0011 + STR0039 )//"Não é necessário buscar coordenadas para filial."
				nLatiOri  := DAR->DAR_LATITU
				nLongOri := DAR->DAR_LONGIT
			EndIf
			cUFOri := aSM0Dados[1][2]
			lRet := .T.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} OMSCoorCli
** Obtem e salva as coordenadas dos clientes
@author Equipe OMS
@since 13/01/2022
/*/
Static Function OMSCoorCli(llogTPR, oDadosTPR, cAliasTPR, aErrors)
	Local lRet 			:= .T.
	Local cTMPIdent		:= ""
	Local cPaisIdent 	:= ""
	Local nLatiDest 	:= ""
	Local nLongDest 	:= ""
	Local cEstado 		:= ""
	Local cMunic 		:= ""
	Local cCep 			:= ""
	Local cEndereco		:= ""
	Local cEntAnt       := ""

	(cAliasTPR)->( dbGoTop() )
	While !(cAliasTPR)->( Eof() ) .And. lRet

		If (Empty((cAliasTPR)->TMP_LATITU) .OR. Empty((cAliasTPR)->TMP_LONGIT))

			If cEntAnt = (cAliasTPR)->TMP_ENTIDA+(cAliasTPR)->TMP_FILFCL+(cAliasTPR)->TMP_CODFCL+(cAliasTPR)->TMP_LOJFCL
				RecLock(cAliasTPR,.F.)
					(cAliasTPR)->TMP_LATITU := nLatiDest
					(cAliasTPR)->TMP_LONGIT := nLongDest
				(cAliasTPR)->(MsUnlock())			
				(cAliasTPR)->( dbSkip() )
				Loop
			EndIf

			cEntAnt := (cAliasTPR)->TMP_ENTIDA+(cAliasTPR)->TMP_FILFCL+(cAliasTPR)->TMP_CODFCL+(cAliasTPR)->TMP_LOJFCL

			Do Case
				Case (cAliasTPR)->TMP_ENTIDA == "SA1"
					SA1->(DbSetOrder(1))
					SA1->(DbSeek((cAliasTPR)->TMP_FILFCL+(cAliasTPR)->TMP_CODFCL+(cAliasTPR)->TMP_LOJFCL))
					cEstado 	:= SA1->A1_EST
					cMunic 		:= SA1->A1_MUN
					cCep 		:= SA1->A1_CEP
					cEndereco	:= AllTrim(SA1->A1_END) + IIF(!Empty(SA1->A1_BAIRRO),"," + AllTrim(SA1->A1_BAIRRO),"")
				Case (cAliasTPR)->TMP_ENTIDA == "SA2"
					SA2->(DbSetOrder(1))
					SA2->(DbSeek((cAliasTPR)->TMP_FILFCL+(cAliasTPR)->TMP_CODFCL+(cAliasTPR)->TMP_LOJFCL))
					cEstado 	:= SA2->A2_EST
					cMunic 		:= SA2->A2_MUN
					cCep 		:= SA2->A2_CEP
					cEndereco	:= AllTrim(SA2->A2_END) + IIF(!Empty(SA2->A2_BAIRRO),"," + AllTrim(SA2->A2_BAIRRO),"")

				Case (cAliasTPR)->TMP_ENTIDA == "SA4"
					SA4->(DbSetOrder(1))
					SA4->(DbSeek((cAliasTPR)->TMP_FILFCL+(cAliasTPR)->TMP_CODFCL))
					cEstado 	:= SA4->A4_EST
					cMunic 		:= SA4->A4_MUN
					cCep 		:= SA4->A4_CEP
					cEndereco	:= AllTrim(SA4->A4_END) + IIF(!Empty(SA4->A4_BAIRRO),"," + AllTrim(SA4->A4_BAIRRO),"")
			EndCase

			cTMPIdent := (cAliasTPR)->TMP_FILFCL+(cAliasTPR)->TMP_CODFCL+(cAliasTPR)->TMP_LOJFCL
			cPaisIdent :=  Iif(Empty((cAliasTPR)->TMP_PAIS) .Or. (cAliasTPR)->TMP_PAIS== "*","BRA",(cAliasTPR)->TMP_PAIS)
			nLatiDest 	:= ""
			nLongDest 	:= ""
			FWMsgRun(,{|| lRet := OMSTPRGeoc(llogTPR, oDadosTPR, cTMPIdent,.T., AllTrim(cPaisIdent),cEstado,AllTrim(cMunic), cCep,AllTrim(cEndereco),;
											(cAliasTPR)->TMP_FILFCL,(cAliasTPR)->TMP_ENTIDA,(cAliasTPR)->TMP_CODFCL+(cAliasTPR)->TMP_LOJFCL, @aErrors,@nLatiDest,@nLongDest) },;
											STR0009 + AllTrim((cAliasTPR)->TMP_NOMFAN), STR0001) //"Aguarde""Buscando coordenadas para a entidade "
			RecLock(cAliasTPR,.F.)
				(cAliasTPR)->TMP_LATITU := nLatiDest
				(cAliasTPR)->TMP_LONGIT := nLongDest
			(cAliasTPR)->(MsUnlock())	
		EndIf
		(cAliasTPR)->( dbSkip() )
	EndDo

Return lRet

/*/{Protheus.doc} OMSATPR5It
** Obtem os ids das SC9 para salvar na DMS
@author Equipe OMS
@since 13/01/2022
/*/
Static Function OMSATPR5It(aDoctosDMS, llogTPR)
	Local cQuery := ""
	Local cAliasTmp

	cQuery += " SELECT SC9.C9_FILIAL ,SC9.C9_PEDIDO,SC9.C9_ITEM,SC9.C9_SEQUEN,SC9.C9_PRODUTO"
	cQuery += " FROM " + RetSqlName("SC9") + " SC9"
	cQuery += " INNER JOIN " + RetSqlName("DAI") + " DAI ON SC9.C9_FILIAL = '"+FwXFilial("SC9")+"'"
	cQuery += " AND SC9.C9_CARGA = DAI.DAI_COD"
	cQuery += " AND SC9.C9_SEQCAR = DAI.DAI_SEQCAR"
	cQuery += " AND SC9.C9_SEQENT = DAI.DAI_SEQUEN"
	cQuery += " AND SC9.C9_PEDIDO = DAI.DAI_PEDIDO"
	cQuery += " AND SC9.D_E_L_E_T_ = ''"
	cQuery += 		" WHERE DAI.DAI_FILIAL = '"+ DAK->DAK_FILIAL +"'"
	cQuery += 		" AND DAI.DAI_COD = '"+ DAK->DAK_COD +"'"
	cQuery += 		" AND DAI.DAI_SEQCAR = '"+ DAK->DAK_SEQCAR +"'"
	cQuery += 		" AND DAI.D_E_L_E_T_ = ''"
	cQuery := ChangeQuery(cQuery)
	cAliasTmp := GetNextAlias()

	OMSTPRCLOG(llogTPR, "OMSATPR5", STR0011 + STR0031 + cQuery ) //"OMSATPR5It - Query dos ids SC9: "

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTmp, .F., .T.)
	(cAliasTmp)->( dbGoTop() )
	While !(cAliasTmp)->( Eof() )
			Aadd(aDoctosDMS, {"SC9",RTrim((cAliasTmp)->C9_FILIAL+(cAliasTmp)->C9_PEDIDO+(cAliasTmp)->C9_ITEM+(cAliasTmp)->C9_SEQUEN+(cAliasTmp)->C9_PRODUTO),"1"}) 
		(cAliasTmp)->( dbSkip() )
	EndDo
	(cAliasTmp)->(DbCloseArea())
Return 


/*/{Protheus.doc} OMSATPR5Vc
** Envia os dados do veiculo
@author Equipe OMS
@since 13/01/2022
/*/
Static Function OMSATPR5Vc(oDadosTPR)
	Local nQtdIda := 0
	Local nQtdVolta := 0
	Local lRet := .T.

	DA3->(DbSetOrder(1))
	If DA3->(DbSeek(xFilial("DA3")+DAK->DAK_CAMINH))
		If DAK->DAK_QTEIXI = 0 .Or. DAK->DAK_QTEIXV = 0
			nQtdIda :=   DA3->DA3_QTDEIX
			nQtdVolta :=  DA3->DA3_QTEIXV
			If nQtdVolta = 0
				nQtdVolta := nQtdIda
			Endif
		Else
			nQtdIda :=   DAK->DAK_QTEIXI
			nQtdVolta :=  DAK->DAK_QTEIXV
		EndIf
	EndIf

	oDadosTPR:AddVehicles( RTrim(DA3->DA3_FILIAL+DA3->DA3_COD), DA3->DA3_CAPACM, DA3->DA3_VOLMAX, DA3->DA3_VELOC, 1, nQtdIda, nQtdVolta)
Return lRet


/*/{Protheus.doc} OMSATPR5En
** Envia os dados dos pedidos
@author Equipe OMS
@since 13/01/2022
/*/
Static Function OMSATPR5En(llogTPR, aErrors, oDadosTPR, cAliasTPR, cIdentOri, cUFOri, cPaisLoc, nLatiOri, nLongOri , cOperOri, cOperDes,  cInicioCar, cFimEntreg)
	Local aJanelaCli := {}
	Local aRestrVeic := {}
	Local aVeicEnApi := {}
	Local oQryJanela := Nil
	Local oQryVeicul := Nil
	Local nPos 		:= 0
	Local lRet 		:= .T.
	Local cFuncPad  := SuperGetMV("MV_OMSPROT",.F.,"")
	Local cOperPar  := cOperDes
	
	OMSTPRCLOG(llogTPR, "OMSATPR5", STR0011 + STR0040 ) //"Inicio do processo do planejamento do envio de pedidos."

	(cAliasTPR)->( dbGoTop() )
	While !(cAliasTPR)->( Eof() )
	

		OMSTPRCLOG(llogTPR, "OMSATPR5", STR0011 + STR0041 + cValToChar((cAliasTPR)->TMP_PEDIDO) ) //"Planejando o pedido: "
		cOperDes := cOperPar

		//Dados para SetDestino
		cIdentDes := (cAliasTPR)->TMP_FILFCL+(cAliasTPR)->TMP_CODFCL+(cAliasTPR)->TMP_LOJFCL

		If Empty((cAliasTPR)->TMP_PAIS) .Or. AllTrim((cAliasTPR)->TMP_PAIS) == "*"
			cPaisDest := "BRA"
		Else
			cPaisDest := (cAliasTPR)->TMP_PAIS
		EndIf

		If Empty((cAliasTPR)->TMP_EST)
			lRet := .F.
			Aadd(aErrors, STR0018 + (cAliasTPR)->TMP_CODFCL+"-"+(cAliasTPR)->TMP_LOJFCL+".")//"Verifique o cadastro do estado(UF) para o cliente: "
		EndIf

		oDadosTPR:SetOrigem( cIdentOri, cPaisLoc, Val(nLatiOri), Val(nLongOri), cOperOri, cIdentOri, cUFOri)

		If cOperDes = "CUSTOMIZED" .And. (cAliasTPR)->TMP_ENTIDA = "SA1"
			aJanelaCli := {}
			OMSTPRJan(llogTPR, @oQryJanela,@aJanelaCli,(cAliasTPR)->TMP_FILFCL,(cAliasTPR)->TMP_CODFCL,(cAliasTPR)->TMP_LOJFCL)
			If Empty(aJanelaCli) .And. !Empty(cFuncPad)
				cOperDes := OMSOperFun(Val(cFuncPad))
			EndIf
		EndIf
		aRestrVeic := {}
		OMSTPRVei(llogTPR, @oQryVeicul,@aRestrVeic,(cAliasTPR)->TMP_FILFCL,(cAliasTPR)->TMP_CODFCL,(cAliasTPR)->TMP_LOJFCL)

		aVeicEnApi := {}
		//aVeicEnApi = Veiculos que foram selecionados que sao restricao para este cliente. No OMSA200 é somente um veiculo!
		If !Empty(aRestrVeic)
			nPos := aScan(aRestrVeic, {|x| x[1] == xFilial("DA3")+DAK->DAK_CAMINH})
			If nPos > 0
				lRet := .F. //Nao roteirizar e avisar
				Aadd(aErrors, STR0019 + (cAliasTPR)->TMP_CODFCL+"-"+(cAliasTPR)->TMP_LOJFCL+STR0020 + AllTrim(DAK->DAK_CAMINH)+".")//O cliente" possui uma regra de exceção (OMSA120 - Regras de Entrega) cadastrada para o veículo da carga: "
			EndIf
		EndIf
		oDadosTPR:SetDestino( cIdentDes, AllTrim(cPaisDest), Val((cAliasTPR)->TMP_LATITU), Val((cAliasTPR)->TMP_LONGIT), cOperDes, AllTrim((cAliasTPR)->TMP_NOMFAN),(cAliasTPR)->TMP_EST )


		OMSTPRCLOG(llogTPR, "OMSATPR5", STR0011 + STR0042 ) //"Planejamento finalizado."

		If lRet

			OMSTPRCLOG(llogTPR, "OMSATPR5", STR0011 + STR0043 ) //"Pedido adicionado."
			//CARREGA TUDO NA FILIAL ENTAO dDataIni é igual para todos
			oDadosTPR:AddOrders( (cAliasTPR)->TMP_FILIAL+(cAliasTPR)->TMP_PEDIDO,;
			(cAliasTPR)->TMP_PESOBR, (cAliasTPR)->TMP_VOL, cInicioCar, cFimEntreg, cInicioCar, cFimEntreg, Nil, Nil, aJanelaCli, aVeicEnApi )
			//Inicio carregamento, final do carregamento, inicio da entrega, final da entrega, tempo para carregamento, tempo para entrega
		EndIf
		(cAliasTPR)->( dbSkip() )
	EndDo
Return lRet


/*/{Protheus.doc} OMSTPRVPA2
** Validação dos parâmetros de entrada
@author Equipe OMS
@since 17/01/2022
/*/
Function OMSTPRVPA2(aErrors)
	Local lRet     := .T.
	Local aTemp    := {}

	If Empty(AllTrim(StrTran( MV_PAR02, ":", " " )))
		Aadd(aErrors, STR0014)//"Horário de carregamento não informado."
	EndIf
	If Empty(AllTrim(StrTran( MV_PAR05, ":", " " )))
		Aadd(aErrors, STR0015)//"Tempo mínimo de serviço não informado."
	EndIf
	If Empty(AllTrim(StrTran( MV_PAR06, ":", " " )))
		Aadd(aErrors, STR0016)//"Tempo máximo de serviço não informado."
	EndIf
	If Empty(AllTrim(StrTran( MV_PAR07, ":", " " )))
		Aadd(aErrors, STR0017)//"Horário final das entregas não informada."
	EndIf
	If !Empty(aErrors)
		lRet := .F.
		aTemp := ATail(aErrors)
		Aadd(aErrors, aTemp)
		AIns(aErrors,1)
		aErrors[1] := STR0013 //"Existem parâmetros do planejamento não preenchidos:"
	EndIf

Return lRet


/*/{Protheus.doc} TTItCarg
** Campos da itens da carga
@author Equipe OMS
@since 28/07/2022
/*/
Static Function TTItCarg()
	Local aCpos := {}

	aAdd(aCpos,{ "TMP_FILIAL",TamSX3("C9_FILIAL")[3],TamSX3("C9_FILIAL")[1],TamSX3("C9_FILIAL")[2],OMSTITULO("C9_FILIAL"),PesqPict("SC9", "C9_FILIAL")})
	aAdd(aCpos,{ "TMP_PEDIDO",TamSX3("C9_PEDIDO")[3],TamSX3("C9_PEDIDO")[1],TamSX3("C9_PEDIDO")[2],OMSTITULO("C9_PEDIDO"),PesqPict("SC9", "C9_PEDIDO") })
	aAdd(aCpos,{ "TMP_FILFCL",TamSX3("A1_FILIAL")[3],TamSX3("A1_FILIAL")[1],TamSX3("A1_FILIAL")[2],STR0021 ,              PesqPict("SA1", "A1_FILIAL")})//"Fil Forn/Cli"
	aAdd(aCpos,{ "TMP_CODFCL",TamSX3("A1_COD")[3],   TamSX3("A1_COD")[1],   TamSX3("A1_COD")[2],   STR0022 ,              PesqPict("SB1", "A1_COD")})//"Cod Forn/Cli"
	aAdd(aCpos,{ "TMP_LOJFCL",TamSX3("A1_LOJA")[3],  TamSX3("A1_LOJA")[1],  TamSX3("A1_LOJA")[2],  STR0023 ,              PesqPict("SB1", "A1_LOJA")})//"LJ Forn/Cli"
	aAdd(aCpos,{ "TMP_NOMFAN",TamSX3("A1_NOME")[3],  TamSX3("A1_NOME")[1],  TamSX3("A1_NOME")[2],  STR0024 ,              PesqPict("SB1", "A1_NOME")})//"Nm. Fantasia"
	aAdd(aCpos,{ "TMP_EST",   TamSX3("A1_EST")[3],   TamSX3("A1_EST")[1],   TamSX3("A1_EST")[2],   OMSTITULO("A1_EST") ,  PesqPict("SA1", "A1_EST")})
	aAdd(aCpos,{ "TMP_PSLIQ", TamSX3("B1_PESO")[3],  TamSX3("B1_PESO")[1],  TamSX3("B1_PESO")[2],  STR0025 ,           	  PesqPict("SB1", "B1_PESO")})// "Peso Liq"
	aAdd(aCpos,{ "TMP_PESOBR",TamSX3("B1_PESO")[3],  TamSX3("B1_PESO")[1],  TamSX3("B1_PESO")[2],  STR0026 ,              PesqPict("SB1", "B1_PESO")})//"Peso Bruto"
	aAdd(aCpos,{ "TMP_VOL",   TamSX3("B5_COMPRLC")[3],  TamSX3("B5_COMPRLC")[1],  TamSX3("B5_COMPRLC")[2],  STR0027 ,     PesqPict("SB5", "B5_COMPRLC")})//'Vol. Total'
	aAdd(aCpos,{ "TMP_ENTIDA",TamSX3("DAR_ENTIDA")[3],TamSX3("DAR_ENTIDA")[1],TamSX3("DAR_ENTIDA")[2],OMSTITULO("DAR_ENTIDA"),PesqPict("DAR", "DAR_ENTIDA")})
	aAdd(aCpos,{ "TMP_LATITU",TamSX3("DAR_LATITU")[3],TamSX3("DAR_LATITU")[1],TamSX3("DAR_LATITU")[2],OMSTITULO("DAR_LATITU"),PesqPict("DAR", "DAR_LATITU")})
	aAdd(aCpos,{ "TMP_LONGIT",TamSX3("DAR_LONGIT")[3],TamSX3("DAR_LONGIT")[1],TamSX3("DAR_LONGIT")[2],OMSTITULO("DAR_LONGIT"),PesqPict("DAR", "DAR_LONGIT")})
	aAdd(aCpos,{ "TMP_PAIS",  TamSX3("YA_DESCR")[3], TamSX3("YA_DESCR")[1], TamSX3("YA_DESCR")[2], STR0028 , 			  PesqPict("SYA", "YA_DESCR")})//"País"

Return aCpos


/*/{Protheus.doc} GeraTTCar
** Criacao da TT de Itens da Carga
@author Equipe OMS
@since 28/07/2022
/*/
Static Function GeraTTCar(aStrTab, cAliasTPR, oTTCar, oObjTTCar)
	Local aIndex := {}
	aAdd(aIndex,"TMP_FILIAL+TMP_PEDIDO+TMP_FILFCL+TMP_CODFCL+TMP_LOJFCL")
	oObjTTCar := CriaTabTmp(aStrTab,aIndex,@cAliasTPR,@oTTCar)
Return
