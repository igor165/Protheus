#INCLUDE "PROTHEUS.CH"
#include "OMSATPR1.CH"

/*/{Protheus.doc} OMSATPR1A
** Processo de envio dos pedidos
@author Equipe OMS
@since 08/09/2021
/*/
Function OMSATPR1A(aErrors,oTTPed,oTTVei,oBrowse, cAliasPED, cMarca, nTipoTela)
	Local oDadosTPR  := Nil
	Local nLatiOri 	 := 0
	Local nLongOri 	 := 0
	Local cJson 	 := ""
	Local cResult 	 := ""
	Local aDoctosDMS := {}
	Local lRet 		 := .T.
	Local cIdentOri  := AllTrim(SM0->M0_CODFIL) +"-"+ AllTrim(SM0->M0_FILIAL) +"-"+ AllTrim(SM0->M0_NOME)
	Local cIdRot     := ""
	Local cMVCriter := MV_PAR01
	Local cMVPlanej := MV_PAR02
	Local cMVQtDias := MV_PAR03
	Local cMVTmpCar := MV_PAR04

	Local nMVFunFil := MV_PAR05 //Funcionamento filial

	Local cMVRetFil := MV_PAR06
	Local cMVQtdCar := MV_PAR07
	Local cMVKmMaxC := MV_PAR08
	Local cMVKmMaxD := MV_PAR09
	Local cMVQtdDes := MV_PAR10
	Local cMVTmpMin := MV_PAR11
	Local cMVTmpMax := MV_PAR12
	Local cMVTmpDes := MV_PAR13
	Local nMVFunEnt := MV_PAR14 //Funcionamento entregas
	Local cMVPed 	:= MV_PAR15
	Local cMVOrdUF 	:= MV_PAR16 //Entrega ordenada por Estado(UF)
	Local cUFOri 	:= ""
	Local aVeicEnv 	:= {} //Array com os veiculos enviados	

	Local cInicioCar := ""
	Local cFimEntreg := ""

	Local cOperOri  := "UNRESTRICTED"
	Local cOperDes  := "UNRESTRICTED"
	Local llogTPR   := SuperGetMV("MV_TPRCLOG",.F.,.T.)

	lRet := OMSTPRVPAR(@aErrors)

	Pergunte("OMSATPR1",.F.)

	If lRet
		lRet := OMSTPRVldE(oTTPed, oBrowse, @aErrors,nTipoTela)
	EndIf
	If lRet
		oDadosTPR := TMSBCATPRNeolog():New()
		If oDadosTPR:Auth()

			//Atualiza coordenadas não cadastradas dos clientes
			lRet := OMSTPRCoor(llogTPR, @oDadosTPR,cIdentOri,@nLatiOri, @nLongOri, oTTPed, oBrowse, @cAliasPED, @cUFOri, @aErrors)

			IF Empty(nLatiOri) .Or. Empty(nLongOri)
				Aadd(aErrors, STR0108) //"Não foi possível geolocalizar a origem das rotas."
				OMSTPRCLOG(llogTPR, "OMSATPR1A", STR0094 + STR0108)//"Não foi possível geolocalizar a origem das rotas."
				lRet := .F.
			EndIf

			If lRet
				//Obtem todos os ids das SC9 dos pedidos
				lRet := OMSTPRItem(@aDoctosDMS,oTTPed,oBrowse,@aErrors,nTipoTela)
				If Empty(aDoctosDMS)
					Aadd(aErrors, STR0077)//"Os pedidos selecionados não estão disponíveis para o planejamento de rotas."
					lRet := .F.
				EndIf

				If lRet

					cInicioCar := OMSTPRDtIn(cMVTmpCar,cMVPlanej)
					cFimEntreg := OMSTPRDtFn(cMVTmpDes,cMVQtDias,cMVPlanej)

					cOperOri  := OMSOperFun(nMVFunFil)
					cOperDes  := OMSOperFun(nMVFunEnt)

						//Veiculos enviados para o objeto de post
						lRet := OMSTPRAddV(@oDadosTPR, oTTVei, cMarca, @aErrors, @aVeicEnv)//Vehicles

					If lRet
						//Pedidos enviados para o objeto de post
						lRet := OMSTPRAddP(llogTPR, @aErrors, @oDadosTPR, oTTPed, oBrowse, nLatiOri, nLongOri, cIdentOri, cUFOri, aDoctosDMS, nTipoTela,;
										 cInicioCar, cFimEntreg, cOperOri, cOperDes, Nil, Nil, aVeicEnv)//Pedidos

						If lRet
							//Restricoes enviados para o objeto de post
							OMSTPRAddR(@oDadosTPR, cMVQtdCar, cMVQtdDes, cMVKmMaxC, cMVKmMaxD, cMVOrdUF)//Restricoes

							//Opcoes enviados para o objeto de post
							OMSTPRAddO(@oDadosTPR, cMVCriter, cMVPlanej, cMVRetFil, cMVTmpMin, cMVTmpMax, cMVPed, "ROUTING")//Options

							//Grava DMR e DMS para bloquear itens e identifica-los no callback
							lRet := OMSGrvRot(@oDadosTPR,aDoctosDMS, @cIdRot, @aErrors)

							If lRet
								//'Enviando pedidos para planejamento de roteirização''Aguarde a confirmação.'
								FwMsgRun( ,{|| lRet	:= oDadosTPR:PostRouting() } ,STR0031, STR0032 , STR0004) //"Aguarde"  //"Realizando o Planejamento de Rotas"

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
								EndIf
							
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		Else
			lRet := .F.
			Aadd(aErrors, oDadosTPR:GetError()) 
		EndIf
	EndIf
	FwFreeObj(oDadosTPR)    
	oDadosTPR:= Nil
Return lRet

/*/{Protheus.doc} OMSTPRCoor
** Verifica se tem coordenadas para atualizar e envia integracao para Neolog
** Se necessário atualizar será chamado o metodo OMSTPRTT para atualizar temporaria
@author Equipe OMS
@since 08/09/2021
/*/
Static Function OMSTPRCoor(llogTPR, oDadosTPR, cIdent, nLatiOri, nLongOri,oTTPed, oBrowse, cAliasPED, cUFOri ,aErrors)
	Local cQuery  		:= ""
	Local cAliasQry  	:= ""
	Local lRet 			:= .F.
	Local cPaisFil		:= "BRA"
	Local cPaisIdent 	:= ""
	Local lIntegGeo 	:= .F.
	Local nLatiDest 	:= 0
	Local nLongDest 	:= 0
	Local aDadosGeo 	:= {}
	Local aCamposSM0 	:= {"M0_ESTENT","M0_CIDENT","M0_CEPENT","M0_ENDENT","M0_BAIRENT"}
	Local aSM0Dados 	:= {}
	Local cEntAnt       := ""
	Local cEndBairro    := ""

	aSM0Dados := FWSM0Util():GetSM0Data(cEmpAnt, cFilAnt, aCamposSM0)
	If !Empty(aSM0Dados)
		lRet :=	OMSValSM0(aSM0Dados[1][2],aSM0Dados[2][2],aSM0Dados[3][2], aSM0Dados[4][2], @aErrors)
	EndIf

	If lRet
		DAR->(DbSetOrder(1))
		If DAR->(!DbSeek(xFilial("DAR")+Space(Len(cFilAnt))+"SM0"+cFilAnt))

			cEndBairro := AllTrim(aSM0Dados[4][2]) + IIF(!Empty(aSM0Dados[5][2]),"," + AllTrim(aSM0Dados[5][2]),"")

			FWMsgRun(,{|| lRet := OMSTPRGeoc(llogTPR, oDadosTPR, cIdent,.T., cPaisFil,aSM0Dados[1][2],AllTrim(aSM0Dados[2][2]),aSM0Dados[3][2], cEndBairro,;
											"","SM0",cFilAnt, @aErrors,@nLatiOri,@nLongOri) }, STR0050 + cFilAnt, STR0004) //"Aguarde" //"Aguarde""Buscando coordenadas para a filial "
			lIntegGeo := .T.
		Else
			nLatiOri  := DAR->DAR_LATITU
			nLongOri := DAR->DAR_LONGIT
		EndIf
		cUFOri := aSM0Dados[1][2]
		lRet := .T.
	EndIf

	If lRet
		cQuery := "SELECT DISTINCT TMP_FILFCL,TMP_CODFCL,TMP_LOJFCL,TMP_PAIS,TMP_EST,TMP_MUN,TMP_CEP,TMP_END,TMP_BAIRRO,TMP_NOMFAN,TMP_ENTIDA"
		cQuery +=  " FROM "+ oTTPed:GetRealName()+" TMP"
		cQuery += " WHERE TMP.TMP_MARK   = '"+oBrowse:Mark()+"' AND (TMP_LATITU = ' ' OR TMP_LONGIT = ' ') "
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
		(cAliasQry)->( dbGoTop() )
		If !(cAliasQry)->( Eof() )
			While !(cAliasQry)->( Eof() ) .And. lRet

				cEntAnt := (cAliasQry)->TMP_FILFCL+(cAliasQry)->TMP_CODFCL+(cAliasQry)->TMP_LOJFCL

				cPaisIdent :=  Iif(Empty((cAliasQry)->TMP_PAIS) .Or. (cAliasQry)->TMP_PAIS== "*","BRA",(cAliasQry)->TMP_PAIS)
				nLatiDest 	:= 0
				nLongDest 	:= 0

				cEndBairro := AllTrim((cAliasQry)->TMP_END)
				If !Empty((cAliasQry)->TMP_BAIRRO) 
					cEndBairro += "," + AllTrim((cAliasQry)->TMP_BAIRRO)
				EndIf

				FWMsgRun(,{|| lRet := OMSTPRGeoc(llogTPR, oDadosTPR, cEntAnt,.T., AllTrim(cPaisIdent),(cAliasQry)->TMP_EST,(cAliasQry)->TMP_MUN, (cAliasQry)->TMP_CEP, cEndBairro,;
												(cAliasQry)->TMP_FILFCL,(cAliasQry)->TMP_ENTIDA,(cAliasQry)->TMP_CODFCL+(cAliasQry)->TMP_LOJFCL, @aErrors,@nLatiDest,@nLongDest) },;
												STR0049 + AllTrim((cAliasQry)->TMP_NOMFAN), STR0004) //"Aguarde""Buscando coordenadas para a entidade "
				If lRet
					lIntegGeo := .T.
					Aadd(aDadosGeo, {(cAliasQry)->TMP_FILFCL+(cAliasQry)->TMP_CODFCL+(cAliasQry)->TMP_LOJFCL,nLatiDest,nLongDest })
				EndIf
				(cAliasQry)->( dbSkip() )
			EndDo
		(cAliasQry)->(DbCloseArea())
		EndIf
	EndIf

	If lRet .And. lIntegGeo
		FWMsgRun(,{|| OMSTPRTT(aDadosGeo, @cAliasPED) }, STR0043, STR0004)//"STR0043 "Atualizando coordenadas das entidades..."
	EndIf
Return lRet



Function OMSTPRGeoc(llogTPR, oDadosTPR, cIdent, lUpdDAR, cPaisPar,cEstPar, cMunPar, cCepPar, cEndPar, cFilEnt,cEntida,cCodEnt, aErrors,nLat,nLong )
	Local lRet
	Local aGeoCode := {}
	Local cMsgLog := ""

	oDadosTPR:AddAddress( cIdent, cPaisPar , cEstPar, Alltrim(cMunPar), cCepPar, Alltrim(cEndPar) )
	lRet := oDadosTPR:PostGeoLoc()				
	If llogTPR
		/* STR0089 - "TOTVS Planejamento de Rotas(TPR) - Integracao de geolocalizacao - Token cadastrado: 
		STR0090 Json enviado : 
		STR0091 Json retornado: 
		STR0092 Erro retornado: 
		STR0101 O atributo oDadosTPR:ACCESS_TOKEN está nulo. 
		STR0102 O atributo oDadosTPR:JSON_POST está nulo. 
		STR0103 O atributo oDadosTPR:RESULT_POST está nulo. 
		STR0104 O atributo oDadosTPR:MESSAGE_ERROR está nulo.*/
		cMsgLog += IIF(!Empty(oDadosTPR:ACCESS_TOKEN), STR0089 + oDadosTPR:ACCESS_TOKEN +  "|",STR0101 + "|")
		cMsgLog += IIF(!Empty(oDadosTPR:JSON_POST),	   STR0090 + oDadosTPR:JSON_POST + 	   "|",STR0102 + "|")
		cMsgLog += IIF(!Empty(oDadosTPR:RESULT_POST),  STR0091 + oDadosTPR:RESULT_POST +   "|",STR0103 + "|")
		cMsgLog += IIF(!Empty(oDadosTPR:MESSAGE_ERROR),STR0092 + oDadosTPR:MESSAGE_ERROR + "|",STR0104)
		OMSTPRCLOG(llogTPR, "OMSATPR1A", STR0094 + cMsgLog )
		If !lRet
			Aadd(aErrors, STR0107)//" Verifique a inconsistência ao solicitar geolocalização: "
			If !Empty(oDadosTPR:MESSAGE_ERROR)
				Aadd(aErrors, cValToChar(Decodeutf8(oDadosTPR:MESSAGE_ERROR)))//" Verifique a inconsistência ao solicitar geolocalização: "
			EndIf
		EndIf
	EndIf
	If lRet
		aGeoCode:= oDadosTPR:GetGeoLoc()
	EndIf

	If lRet
		If Len(aGeoCode) > 0
			nLat  := cValToChar(aGeoCode[1])
			nLong := cValToChar(aGeoCode[2])
			FWMsgRun(,{|| TMSROT015(cFilEnt,cEntida,cCodEnt,nLat,nLong) },,STR0051, STR0004) //"Aguarde"//Atualizando base de dados..."
		EndIf
	EndIf
Return lRet


/*/{Protheus.doc} OMSTPRItem
** Obtem todas as chaves SC9 dos itens que serao travados no envio
** Esses dados sao importantes para gravar na DMS
@author Equipe OMS
@since 09/09/2021
/*/
Static Function OMSTPRItem(aDoctosDMS, oTTPed, oBrowse, aErrors,nTipoTela)
	Local cQuery := ""
	Local cAliasQry := ""
	Local lRet := .T.
	Local nTamC9Fil := TamSX3('C9_FILIAL')[1]
	Local nTamC9Ped := TamSX3('C9_PEDIDO')[1]
	Local nTamC9Ite := TamSX3('C9_ITEM')[1]
	Local nTamC9Seq := TamSX3('C9_SEQUEN')[1]
	Local nTamC9Prd := TamSX3('C9_PRODUTO')[1]

	If nTipoTela = 1
		cQuery := "SELECT SC9.C9_FILIAL,SC9.C9_PEDIDO,SC9.C9_ITEM,SC9.C9_SEQUEN,SC9.C9_PRODUTO"
		cQuery += 	" FROM  "+ oTTPed:GetRealName()+" TMP"
		cQuery += 		" INNER JOIN " + RetSqlName("SC9") + " SC9 ON (SC9.C9_FILIAL = TMP.TMP_FILIAL"
		cQuery += 			" AND SC9.C9_PEDIDO = TMP.TMP_PEDIDO"
		cQuery += 			" AND SC9.D_E_L_E_T_ = ' ')"
		cQuery += 	" AND NOT EXISTS(SELECT DMS_CHVENT FROM " + RetSqlName("DMS") + " DMS"
		cQuery += 		" INNER JOIN " + RetSqlName("SC9") + " SC92 ON"
		cQuery += 			" DMS.DMS_FILROT = '"+cFilAnt+"'"
		cQuery += 			" AND DMS.DMS_ENTIDA = 'SC9'"
		cQuery += 			" AND SUBSTRING(DMS.DMS_CHVENT,1,"+cValtoChar(nTamC9Fil)+") = SC9.C9_FILIAL"
		cQuery += 			" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+1)+","+cValtoChar(nTamC9Ped)+") = SC9.C9_PEDIDO"		
		cQuery += 			" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+nTamC9Ped+1)+","+cValtoChar(nTamC9Ite)+") = SC9.C9_ITEM"			
		cQuery += 			" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+nTamC9Ped+nTamC9Ite+1)+","+cValtoChar(nTamC9Seq)+") = SC9.C9_SEQUEN"
		cQuery += 			" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+nTamC9Ped+nTamC9Ite+nTamC9Seq+1)+","+cValtoChar(nTamC9Prd)+") = SC9.C9_PRODUTO"
		cQuery += 			" AND DMS.D_E_L_E_T_ = ' '"
		cQuery += 				" WHERE SC92.C9_FILIAL = SC9.C9_FILIAL" 
		cQuery += 					" AND SC92.C9_PEDIDO = SC9.C9_PEDIDO"
		cQuery += 					" AND SC92.C9_ITEM = SC9.C9_ITEM"
		cQuery += 					" AND SC92.C9_SEQUEN = SC9.C9_SEQUEN"
		cQuery += 					" AND SC92.C9_PRODUTO = SC9.C9_PRODUTO"
		cQuery += 					" AND SC92.D_E_L_E_T_ = ' ')"
		cQuery += 	" AND SC9.C9_FILIAL = '" + FwxFilial("SC9") + "'"
		cQuery += 		" WHERE TMP.TMP_MARK   = '"+oBrowse:Mark()+"'"
		cQuery += 				" AND (SC9.C9_BLEST = ' ' AND SC9.C9_BLCRED = ' ' AND SC9.C9_CARGA = ' ')"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
		(cAliasQry)->( dbGoTop() )
		While !(cAliasQry)->( Eof() )
				Aadd(aDoctosDMS, {"SC9",RTrim((cAliasQry)->C9_FILIAL+(cAliasQry)->C9_PEDIDO+(cAliasQry)->C9_ITEM+(cAliasQry)->C9_SEQUEN+(cAliasQry)->C9_PRODUTO),"1"}) 
			(cAliasQry)->( dbSkip() )
		EndDo
		(cAliasQry)->(DbCloseArea())
	else
		cQuery := "SELECT SC9.C9_FILIAL,SC9.C9_PEDIDO,SC9.C9_ITEM,SC9.C9_SEQUEN,SC9.C9_PRODUTO,DMS.DMS_STATUS"
		cQuery += 	" FROM  "+ oTTPed:GetRealName()+" TMP"
		cQuery += 		" INNER JOIN " + RetSqlName("SC9") + " SC9 ON (SC9.C9_FILIAL = TMP.TMP_FILIAL"
		cQuery += 			" AND SC9.C9_PEDIDO = TMP.TMP_PEDIDO"
		cQuery += 			" AND SC9.C9_ITEM = TMP.TMP_ITEM"
		cQuery += 			" AND SC9.C9_SEQUEN = TMP.TMP_SEQUEN"
		cQuery += 			" AND SC9.C9_PRODUTO = TMP.TMP_CODPRO"
		cQuery += 			" AND SC9.D_E_L_E_T_ = ' ')"
		cQuery += 		" LEFT JOIN " + RetSqlName("DMS") + " DMS ON (DMS.DMS_FILIAL = '"+FwxFilial("DMS")+"'"
		cQuery += 			" AND DMS.DMS_FILROT = '"+cFilAnt+"'"
		cQuery += 			" AND DMS.DMS_ENTIDA = 'SC9'"
		cQuery += 			" AND SUBSTRING(DMS.DMS_CHVENT,1,"+cValtoChar(nTamC9Fil)+") = TMP.TMP_FILIAL"
		cQuery += 			" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+1)+","+cValtoChar(nTamC9Ped)+") = TMP.TMP_PEDIDO"		
		cQuery += 			" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+nTamC9Ped+1)+","+cValtoChar(nTamC9Ite)+") = TMP.TMP_ITEM"			
		cQuery += 			" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+nTamC9Ped+nTamC9Ite+1)+","+cValtoChar(nTamC9Seq)+") = TMP.TMP_SEQUEN"
		cQuery += 			" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+nTamC9Ped+nTamC9Ite+nTamC9Seq+1)+","+cValtoChar(nTamC9Prd)+") = TMP.TMP_CODPRO"
		cQuery += 			" AND DMS.D_E_L_E_T_ = ' ')"
		cQuery += 		" WHERE TMP.TMP_MARK   = '"+oBrowse:Mark()+"'"
		cQuery += 				" AND (SC9.C9_BLEST = ' ' AND SC9.C9_BLCRED = ' ' AND SC9.C9_CARGA = ' ')"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
		(cAliasQry)->( dbGoTop() )
		While !(cAliasQry)->( Eof() )
			If Empty((cAliasQry)->DMS_STATUS)
				Aadd(aDoctosDMS, {"SC9",RTrim((cAliasQry)->C9_FILIAL+(cAliasQry)->C9_PEDIDO+(cAliasQry)->C9_ITEM+(cAliasQry)->C9_SEQUEN+(cAliasQry)->C9_PRODUTO),"1"}) 
			Else
				lRet := .F.
				Aadd(aErrors, STR0040 + (cAliasQry)->C9_PEDIDO + STR0052 + (cAliasQry)->C9_ITEM+ STR0053 + (cAliasQry)->C9_SEQUEN+;
						 STR0054 + AllTrim((cAliasQry)->C9_PRODUTO) + STR0044)
						 //"Pedido: "" Item: "" Seq. Liberação: "" Produto: "" já enviado para o Planejamento de Rotas." 
			EndIf
			(cAliasQry)->( dbSkip() )
		EndDo
		(cAliasQry)->(DbCloseArea())
	EndIf
Return lRet


/*/{Protheus.doc} OMSPedInt
** Retorna pedidos integrados ou nao integrados
@author Equipe OMS
@since 09/09/2021
/*/
Function OMSPedInt(cAliasQry,oBrowse,oTTPed, lIntegrado)
	Local cQuery := ""
	Local cOperSQL   := IIf(Upper(TcGetDb())$'ORACLE',.F.,.T.)
	Local nTamC9Fil := TamSX3('C9_FILIAL')[1]
	Local nTamC9Ped := TamSX3('C9_PEDIDO')[1]
	Local nTamC9Ite := TamSX3('C9_ITEM')[1]
	Local nTamC9Seq := TamSX3('C9_SEQUEN')[1]
	Local nTamC9Prd := TamSX3('C9_PRODUTO')[1]

		//A validacao ocorre separada da captura dos ids SC9, porque os dados dos pedidos são agrupados por SC9
		//Se a soma dos valores for diferente, o envio desejado seria diferente do realizado
		cQuery := " SELECT SC9.C9_FILIAL,SC9.C9_PEDIDO,"
		cQuery += " TMP_QTDLIB,TMP_PSLIQ,TMP_PESOBR,TMP_VOL,"
		cQuery += " SUM(C9_QTDLIB) AS SUMSC9LIB,"
		cQuery += " CASE"
		cQuery += 		" WHEN SB5.B5_TIPUNIT = '1' THEN SUM(SB1.B1_PESO)"
		cQuery += 	" ELSE SUM(C9_QTDLIB * SB1.B1_PESO)"
		cQuery += " END AS SUMSC9LIQ,"
		cQuery += " CASE"
		cQuery += 	" WHEN SB5.B5_TIPUNIT = '1' THEN SUM(SB1.B1_PESBRU)"
		cQuery += 	" ELSE SUM(C9_QTDLIB * SB1.B1_PESBRU)"
		cQuery += " END AS SUMSC9BR,"

		If cOperSQL
			cQuery += " SUM((SB5.B5_ALTURLC * SB5.B5_LARGLC * SB5.B5_COMPRLC)*C9_QTDLIB) AS SUMSC9VOL"
		Else
			cQuery += " SUM((NVL(SB5.B5_ALTURLC, 0) * NVL(SB5.B5_LARGLC, 0) * NVL(SB5.B5_COMPRLC, 0))*C9_QTDLIB) AS SUMSC9VOL"
		EndIf

		cQuery += 	" FROM  "+ oTTPed:GetRealName()+" TMP"
		cQuery +=  		" INNER JOIN " + RetSqlName("SC9") + " SC9  ON (SC9.C9_FILIAL = TMP.TMP_FILIAL"
		cQuery +=  			" AND SC9.C9_PEDIDO = TMP.TMP_PEDIDO"
		cQuery +=  			" AND SC9.D_E_L_E_T_ = ' ')"
		cQuery +=  		" INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + FwxFilial("SB1") + "'"
		cQuery +=  			" AND SB1.B1_COD = SC9.C9_PRODUTO"
		cQuery +=  			" AND SB1.D_E_L_E_T_ = ' '"
		cQuery +=  		" LEFT JOIN " + RetSqlName("SB5") + " SB5 ON SB5.B5_FILIAL = '" + FwxFilial("SB5") + "'"
		cQuery +=  			" AND SB5.B5_COD = SB1.B1_COD"
		cQuery +=  			" AND SB5.D_E_L_E_T_ = ' '"
		cQuery += 	" WHERE TMP.TMP_MARK   = '"+oBrowse:Mark()+"'"
		cQuery += 				" AND (SC9.C9_BLEST = ' ' AND SC9.C9_BLCRED = ' ' AND SC9.C9_CARGA = ' ')"
		cQuery += 				" AND SC9.C9_FILIAL = '" + FwxFilial("SC9") + "'"
  		IIF(lIntegrado,cQuery +=" AND EXISTS",cQuery +=" AND NOT EXISTS")
		cQuery += 			" (SELECT DMS_CHVENT"
		cQuery += 				" FROM " + RetSqlName("DMS") + " DMS"
		cQuery += 					" INNER JOIN " + RetSqlName("SC9") + " SC92 ON DMS.DMS_FILROT = SC9.C9_FILIAL"
		cQuery += 						" AND DMS.DMS_ENTIDA = 'SC9'"
		cQuery += 						" AND SUBSTRING(DMS.DMS_CHVENT,1,"+cValtoChar(nTamC9Fil)+") = SC9.C9_FILIAL"
		cQuery += 						" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+1)+","+cValtoChar(nTamC9Ped)+") = SC9.C9_PEDIDO"		
		cQuery += 						" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+nTamC9Ped+1)+","+cValtoChar(nTamC9Ite)+") = SC9.C9_ITEM"			
		cQuery += 						" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+nTamC9Ped+nTamC9Ite+1)+","+cValtoChar(nTamC9Seq)+") = SC9.C9_SEQUEN"
		cQuery += 						" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+nTamC9Ped+nTamC9Ite+nTamC9Seq+1)+","+cValtoChar(nTamC9Prd)+") = SC9.C9_PRODUTO"
		cQuery += 						" AND DMS.D_E_L_E_T_ = ' '"
		cQuery += 							" WHERE SC92.C9_FILIAL = SC9.C9_FILIAL" 
		cQuery += 							" AND SC92.C9_PEDIDO = SC9.C9_PEDIDO"
		cQuery += 							" AND SC92.C9_ITEM = SC9.C9_ITEM"
		cQuery += 							" AND SC92.C9_SEQUEN = SC9.C9_SEQUEN"
		cQuery += 							" AND SC92.C9_PRODUTO = SC9.C9_PRODUTO"
		cQuery += 							" AND SC92.D_E_L_E_T_ = ' ')"
		cQuery += 				" GROUP BY SC9.C9_FILIAL,"
		cQuery += 					"SC9.C9_PEDIDO,"
		cQuery += 					"SB5.B5_TIPUNIT,"
		cQuery += 					"TMP_QTDLIB,"
		cQuery += 					"TMP_PSLIQ,"
		cQuery += 					"TMP_PESOBR,"
		cQuery += 					"TMP_VOL"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)


Return


/*/{Protheus.doc} OMSTPRAddP
** Preenche o elemento dos pedidos que serão enviados. No envio deve existir um agrupamento
** por pedido, mesmo selecionando por item
@author Equipe OMS
@since 09/09/2021
/*/
Static Function OMSTPRAddP(llogTPR, aErrors, oDadosTPR, oTTPed, oBrowse, nLatiOri, nLongOri, cIdentOri, cUFOri, aDoctosDMS, nTipoTela, cInicioCar, cFimEntreg, cOperOri, cOperDes,cTmpCarPed, cTmpDesPed, aVeicEnv)
	Local cIdentDes := ""
	Local cQuery
	Local cAliasQry
	Local cPaisDest := "BRA"
	Local cOperSQL   := IIf(Upper(TcGetDb())$'ORACLE',.F.,.T.)
	Local lRet 		:= .T.
	Local aJanelaCli := {}
	Local aRestrVeic := {}
	Local aVeicEnApi := {}
	Local oQryJanela := Nil
	Local oQryVeicul := Nil
	Local nX 		:= 1
	Local nPos 		:= 0
	Local cFuncPad  := SuperGetMV("MV_OMSPROT",.F.,"")
	Local cOperPar  := cOperDes

	cQuery := "SELECT TMP_FILIAL, TMP_PEDIDO, TMP_TIPO, TMP_FILFCL, TMP_CODFCL, TMP_LOJFCL, TMP_LATITU,TMP_LONGIT, TMP_PAIS,TMP_NOMFAN,TMP_ENTIDA,TMP_EST,"

	cQuery += " CASE"
	cQuery += 		" WHEN SB5.B5_TIPUNIT = '1' THEN SUM(SB1.B1_PESO)"
	cQuery += 	" ELSE SUM(C9_QTDLIB * SB1.B1_PESO)"
	cQuery += " END AS TMP_PESOLQ,"
	cQuery += " CASE"
	cQuery += 	" WHEN SB5.B5_TIPUNIT = '1' THEN SUM(SB1.B1_PESBRU)"
	cQuery += 	" ELSE SUM(C9_QTDLIB * SB1.B1_PESBRU)"
	cQuery += " END AS TMP_PESOBR,"

	If cOperSQL
		cQuery += 	" CASE WHEN "
		cQuery += 		" SUM ((SB5.B5_ALTURLC * SB5.B5_LARGLC * SB5.B5_COMPRLC)*C9_QTDLIB) IS NULL THEN 0 "
		cQuery += 		" ELSE SUM ((SB5.B5_ALTURLC * SB5.B5_LARGLC * SB5.B5_COMPRLC)*C9_QTDLIB) "
		cQuery += 	" END AS TMP_VOL"
	Else
		cQuery += 	" SUM ((NVL(SB5.B5_ALTURLC, 0) * NVL(SB5.B5_LARGLC, 0) * NVL(SB5.B5_COMPRLC, 0))*C9_QTDLIB) AS TMP_VOL"
	EndIf
	cQuery += " FROM "+ oTTPed:GetRealName()+" TMP"
	cQuery += 	" INNER JOIN " + RetSqlName("SC9") + " SC9 ON (SC9.C9_FILIAL = TMP.TMP_FILIAL"
	cQuery += 		" AND SC9.C9_PEDIDO = TMP.TMP_PEDIDO"

	If nTipoTela = 2
		cQuery += 	" AND SC9.C9_ITEM = TMP.TMP_ITEM"
		cQuery += 	" AND SC9.C9_SEQUEN = TMP.TMP_SEQUEN"
		cQuery += 	" AND SC9.C9_PRODUTO = TMP.TMP_CODPRO"
	EndIf

	cQuery += 		" AND SC9.D_E_L_E_T_ = ' ')"
	cQuery += 	" INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + FwxFilial("SB1") + "'"
	cQuery += 		" AND SB1.B1_COD = SC9.C9_PRODUTO"
	cQuery += 		" AND SB1.D_E_L_E_T_ = ' '"
	cQuery += 	" LEFT JOIN " + RetSqlName("SB5") + " SB5 ON SB5.B5_FILIAL = '" + FwxFilial("SB5") + "'"
	cQuery += 		" AND SB5.B5_COD = SB1.B1_COD"
	cQuery += 		" AND SB5.D_E_L_E_T_ = ' '"
	cQuery += 	" WHERE TMP.TMP_MARK = '"+oBrowse:Mark()+"'"
	cQuery += 		" AND (SC9.C9_BLEST = ' ' AND SC9.C9_BLCRED = ' ' AND SC9.C9_CARGA = ' ')"
	cQuery += " GROUP BY TMP_FILIAL,"
	cQuery += 	" TMP_PEDIDO,"
	cQuery += 	" SB5.B5_TIPUNIT,"
	cQuery += 	" TMP_TIPO,"
	cQuery += 	" TMP_PAIS,"
	cQuery += 	" TMP_ENTIDA,"
	cQuery += 	" TMP_FILFCL,"
	cQuery += 	" TMP_CODFCL,"
	cQuery += 	" TMP_LOJFCL,"
	cQuery += 	" TMP_NOMFAN,"
	cQuery += 	" TMP_EST,"
	cQuery += 	" TMP_LATITU,"
	cQuery += 	" TMP_LONGIT"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	(cAliasQry)->( dbGoTop() )
	While !(cAliasQry)->( Eof() )

		cOperDes := cOperPar
		
		//Dados para SetDestino
		If (cAliasQry)->TMP_TIPO == "B" .Or. (cAliasQry)->TMP_TIPO == "D"
			cIdentDes := (cAliasQry)->TMP_FILFCL+(cAliasQry)->TMP_CODFCL+(cAliasQry)->TMP_LOJFCL
		Else
			cIdentDes := (cAliasQry)->TMP_FILFCL+(cAliasQry)->TMP_CODFCL+(cAliasQry)->TMP_LOJFCL
		Endif

		If Empty((cAliasQry)->TMP_PAIS) .Or. AllTrim((cAliasQry)->TMP_PAIS) == "*"
			cPaisDest := "BRA"
		Else
			cPaisDest := (cAliasQry)->TMP_PAIS
		EndIf

		If Empty((cAliasQry)->TMP_EST)
			lRet := .F.
			Aadd(aErrors, STR0100 + (cAliasQry)->TMP_CODFCL+"-"+(cAliasQry)->TMP_LOJFCL+".")//"Verifique o cadastro do estado(UF) para o cliente: "
		EndIf

		oDadosTPR:SetOrigem( cIdentOri, cPaisLoc, Val(nLatiOri), Val(nLongOri), cOperOri, cIdentOri, cUFOri)

		If cOperDes = "CUSTOMIZED" .And. (cAliasQry)->TMP_ENTIDA = "SA1" //JANELA preencher o atributo customizedOperation do TMSAC18
			aJanelaCli := {}
			OMSTPRJan(llogTPR, @oQryJanela,@aJanelaCli,(cAliasQry)->TMP_FILFCL,(cAliasQry)->TMP_CODFCL,(cAliasQry)->TMP_LOJFCL)
			If Empty(aJanelaCli) .And. !Empty(cFuncPad)
				cOperDes := OMSOperFun(Val(cFuncPad))
			EndIf
		EndIf
		If (cAliasQry)->TMP_ENTIDA = "SA1"
			aRestrVeic := {}
			OMSTPRVei(llogTPR, @oQryVeicul,@aRestrVeic,(cAliasQry)->TMP_FILFCL,(cAliasQry)->TMP_CODFCL,(cAliasQry)->TMP_LOJFCL)
			
			aVeicEnApi := {} //aVeicEnApi = Veiculos que foram selecionados que sao restricao para este cliente
			
			If !Empty(aRestrVeic)
				For nX := 1 to Len(aVeicEnv)
					nPos := aScan(aRestrVeic, {|x| x[1] == aVeicEnv[nX]})
					If nPos > 0
						Aadd(aVeicEnApi, RTRIM(aVeicEnv[nX]))
					EndIf
				Next nX
			EndIf
		EndIf

		oDadosTPR:SetDestino( cIdentDes, AllTrim(cPaisDest), Val((cAliasQry)->TMP_LATITU), Val((cAliasQry)->TMP_LONGIT), cOperDes, AllTrim((cAliasQry)->TMP_NOMFAN), (cAliasQry)->TMP_EST )

		//CARREGA TUDO NA FILIAL ENTAO dDataIni é igual para todos
		oDadosTPR:AddOrders( (cAliasQry)->TMP_FILIAL+(cAliasQry)->TMP_PEDIDO,;
		(cAliasQry)-> TMP_PESOBR, (cAliasQry)->TMP_VOL, cInicioCar, cFimEntreg, cInicioCar, cFimEntreg, Nil, Nil, aJanelaCli, aVeicEnApi )
		//Inicio carregamento, final do carregamento, inicio da entrega, final da entrega, tempo para carregamento(serviceLoadDuration), tempo para entrega(serviceUnloadDuration)
		//tempo para carregamento(serviceLoadDuration), tempo para entrega(serviceUnloadDuration) nao sao enviados pq nao temos esse tempo a nivel de ponto de entrega/cliente

		(cAliasQry)->( dbSkip() )
	EndDo
	(cAliasQry)->(DbCloseArea())
Return lRet


/*/{Protheus.doc} OMSTPRAddV
** Preenche o elemento dos veiculos que serão enviados
@author Equipe OMS
@since 09/09/2021
/*/
Static Function OMSTPRAddV(oDadosTPR, oTTVei, cMarca, aErrors, aVeicEnv)
	Local cQuery
	Local cAliasQry
	Local lRet := .T.
	Local nQtdIda := 0
	Local nQtdVolta := 0

	cAliasQry := GetNextAlias()
	cQuery := "SELECT TMP_FILIAL,TMP_COD,TMP_PESO,TMP_VOL,TMP_VELOC,TMP_QTDEIX,TMP_QTEIXV "
	cQuery +=  " FROM "+ oTTVei:GetRealName()+" TMP"
	cQuery += " WHERE TMP.TMP_MARK  = '"+cMarca+"'"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	(cAliasQry)->( dbGoTop() )
	While !(cAliasQry)->( Eof() )

		nQtdIda :=  (cAliasQry)->TMP_QTDEIX
		nQtdVolta := (cAliasQry)->TMP_QTEIXV

		If nQtdVolta = 0
			nQtdVolta := nQtdIda
		EndIf

		oDadosTPR:AddVehicles( RTrim((cAliasQry)->TMP_FILIAL+(cAliasQry)->TMP_COD),(cAliasQry)->TMP_PESO, (cAliasQry)->TMP_VOL, (cAliasQry)->TMP_VELOC, 1, nQtdIda, nQtdVolta)
		Aadd(aVeicEnv, (cAliasQry)->TMP_FILIAL+(cAliasQry)->TMP_COD)

		(cAliasQry)->( dbSkip() )
	EndDo
	(cAliasQry)->(DbCloseArea())
Return lRet


/*/{Protheus.doc} OMSTPRAddR
** Preenche o elemento dos restricoes que serão enviados
@author Equipe OMS
@since 09/09/2021
/*/
Function OMSTPRAddR(oDadosTPR, cMVQtdCar, cMVQtdDes, cMVKmMaxC, cMVKmMaxD, cMVOrdUF)
	Local cQtdCar := IIF(cMVQtdCar > 0, cMVQtdCar, Nil)
	Local cQtdDes := IIF(cMVQtdDes > 0, cMVQtdDes, Nil)
	Local cKmMaxC := IIF(cMVKmMaxC > 0, cMVKmMaxC, Nil)
	Local cKmMaxD := IIF(cMVKmMaxD > 0, cMVKmMaxD, Nil)
	Local lMVOrdUF := .F.

	If cMVOrdUF = 1
		lMVOrdUF := .T.
	Else
		lMVOrdUF := .F.
	EndIf

	oDadosTPR:AddRestriction( cQtdCar, cQtdDes, .F., cKmMaxC, cKmMaxD, lMVOrdUF)
Return


/*/{Protheus.doc} OMSTPRDtIn
** Gera a data/hora de carregamento com base nos parâmetros
@author Equipe OMS
@since 09/09/2021
/*/
Function OMSTPRDtIn(cMVTmpCar,cMVPlanej, dDataCarreg)
	Local cJSData := ""
	Local dDtCarreg := Nil
	Local cTmpCar := IIF(Empty(cMVTmpCar),"00:00",cMVTmpCar)
	Default dDataCarreg := ddatabase
	dDtCarreg := dDataCarreg

	If cMVPlanej = 1
		cJSData :=  FWTimeStamp(5,dDtCarreg,cTmpCar)
	Else
		dDtCarreg := DaySum(dDtCarreg,1)
		cJSData :=  FWTimeStamp(5,dDtCarreg,cTmpCar)
	EndIf
Return cJSData

/*/{Protheus.doc} OMSTPRDtFn
** Gera a data/hora final de entregas com base nos parâmetros
@author Equipe OMS
@since 09/09/2021
/*/
Function OMSTPRDtFn(cMVTmpDes,cMVQtDias,cMVPlanej, dDataCarreg)
	Local cJSData := ""
	Local cTmpDes := IIF(Empty(cMVTmpDes),"23:59",cMVTmpDes)
	Local dDtCarreg := Nil
	Default dDataCarreg := ddatabase
	dDtCarreg := dDataCarreg

	If cMVPlanej = 1
		dDtCarreg := DaySum(dDtCarreg,cMVQtDias)
		cJSData :=  FWTimeStamp(5,dDtCarreg,cTmpDes)
	Else
		dDtCarreg := DaySum(dDtCarreg,1+cMVQtDias)
		cJSData :=  FWTimeStamp(5,dDtCarreg,cTmpDes)
	EndIf

Return cJSData


/*/{Protheus.doc} OMSOperFun
** Converte parametro OMS em parametro Neolog
@author Equipe OMS
@since 09/09/2021
/*/
Function OMSOperFun(nFunPar)
	Local cOperOri  := ""

	Do Case
		Case nFunPar = 1
			cOperOri := "UNRESTRICTED"
		Case nFunPar = 2
			cOperOri := "BUSINESS_DAYS"
		Case nFunPar = 3
			cOperOri := "MORNING"
		Case nFunPar = 4
			cOperOri := "AFTERNOON"
		Case nFunPar = 5 //JANELA
			cOperOri := "CUSTOMIZED"
	EndCase

Return cOperOri


/*/{Protheus.doc} OMSTPRAddO
** Preenche o elemento dos opcoes que serão enviados
@author Equipe OMS
@since 09/09/2021
/*/
Function OMSTPRAddO(oDadosTPR, cMVCriter, cMVPlanej, cMVRetFil, cMVTmpMin, cMVTmpMax, cMVPed, routingType)
	Local lRetorna := .F.
	Local cCapCri  := ''
	Local cCriteri := "NOW"
	Local nTmpMin  := Nil
	Local nTmpMax  := Nil
	Local lPedagio := .F.

	Do Case
		Case cMVCriter = 1
			cCapCri := "WEIGHT"
		Case cMVCriter = 2
			cCapCri := "VOLUME"
		Case cMVCriter = 3
			cCapCri := "BOTH"
	EndCase

	If cMVRetFil = 1
		lRetorna := .T.
	EndIf

	If cMVPlanej = 2
		cCriteri := "D+1"
	EndIf

	If cMVPed = 1
		lPedagio := .T.
	Else
		lPedagio := .F.
	EndIf

	If !Empty(cMVTmpMin) .And. cMVTmpMin != "  :  " .And. cMVTmpMin != "00:00"
		nTmpMin := OMSTPRMili(cMVTmpMin)
	EndIf
	If !Empty(cMVTmpMax) .And. cMVTmpMax != "  :  " .And. cMVTmpMax != "00:00"
		nTmpMax := OMSTPRMili(cMVTmpMax)
	EndIf
	oDadosTPR:AddOption(cCapCri, cCriteri, lRetorna, nTmpMin, nTmpMax, Nil, lPedagio, routingType)
Return

/*/{Protheus.doc} OMSTPRMili
** Converte hora em milisegundos
@author Equipe OMS
@since 09/09/2021
/*/
Function OMSTPRMili(cHoraMinut)
	Local aHoraMinut := {}
	Local nMiliseg := 0

	aHoraMinut := StrTokArr( cHoraMinut, ":" )
	nMiliseg :=  IIF( Val(aHoraMinut[1]) > 0, Val(aHoraMinut[1]) * 3600000 ,0)
	nMiliseg +=  IIF( Val(aHoraMinut[2]) > 0, Val(aHoraMinut[2]) * 60000  ,0)

Return nMiliseg


/*/{Protheus.doc} OMSTPRTT
** Funcao que é executada quando necessario atualizar coordenadas da temporaria e da DAR
@author Equipe OMS
@since 09/09/2021
/*/
Static Function OMSTPRTT(aDadosGeo, cAliasPED)
	Local nX

	For nX := 1 To Len(aDadosGeo)
		(cAliasPED)->(DbSetOrder(2))  //"TMP_FILFCL+TMP_CODFCL+TMP_LOJFCL"
		If (cAliasPED)->(DbSeek(aDadosGeo[nX][1]))
			While (cAliasPED)->(!Eof()) .And.  (cAliasPED)->TMP_FILFCL + (cAliasPED)->TMP_CODFCL + (cAliasPED)->TMP_LOJFCL == aDadosGeo[nX][1]
				RecLock(cAliasPED,.F.)
					(cAliasPED)->TMP_LATITU := aDadosGeo[nX][2]
					(cAliasPED)->TMP_LONGIT := aDadosGeo[nX][3]
				(cAliasPED)->(MsUnlock())
				(cAliasPED)->(DbSkip())
			EndDo
		EndIf
	Next nX
Return .T.


/*/{Protheus.doc} OMSGrvRot
** Grava o controle dos dados que foram enviados para integracao
** Dados baseados na chave SC9 e (DMR x DMS)
@author Equipe OMS
@since 09/09/2021
/*/
Function OMSGrvRot(oDadosTPR, aDoctosDMS, cIdRot, aErrors, cChvExt, cEntExt, cIndExt)
	Local oModel   := Nil
	Local oMdFldDMR:= Nil
	Local oMdGrdDMS:= Nil
	Local lRet     := .F.
	Local nCount   := 0
	Local cItem    := StrZero(1,Len(DMS->DMS_ITEM))
	Local aArea    := GetArea()
	Default aDoctosDMS  := {}
	Default cChvExt := ""
	Default cEntExt := ""
	Default cIndExt := ""

	oModel := FWLoadModel( 'TMSAC19' )
	oModel:SetOperation( 3 )
	oModel:Activate()

	oMdFldDMR:= oModel:GetModel("MdFieldDMR")
	oMdGrdDMS:= oModel:GetModel("MdGridDMS")

	oMdFldDMR:LoadValue('DMR_FILROT', cFilAnt)
			
	For nCount:= 1 To Len(aDoctosDMS)
		If nCount <> 1
			oMdGrdDMS:AddLine()
		EndIf
		oMdGrdDMS:LoadValue('DMS_ENTIDA', aDoctosDMS[ nCount, 1 ] )
		oMdGrdDMS:LoadValue('DMS_CHVENT', aDoctosDMS[ nCount, 2 ] )
		oMdGrdDMS:LoadValue('DMS_INDENT', cValToChar(aDoctosDMS[ nCount, 3 ]) )    
		oMdGrdDMS:LoadValue('DMS_ITEM'  , cItem )
		If !Empty(cChvExt)
			oMdGrdDMS:LoadValue('DMS_CHVEXT', cChvExt)
		EndIf
		If !Empty(cEntExt)
			oMdGrdDMS:LoadValue('DMS_ENTEXT', cEntExt)
		EndIf
		If !Empty(cIndExt)
			oMdGrdDMS:LoadValue('DMS_INDEXT', cIndExt)
		EndIf
		cItem:= Soma1(cItem)
	Next nCount

	lRet := oModel:VldData()
	If lRet 
		oModel:CommitData()
		cIdRot  := DMR->DMR_FILROT + DMR->DMR_IDROT 
		oDadosTPR:SetRoutID(cIdRot)
	Else
		Aadd(aErrors,  oModel:GetErrorMessage()[6] )
	EndIf
	oModel:Destroy()
	oModel:= Nil	
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} OMSTPRADLU
** Grava o controle da integracao
@author Equipe OMS
@since 09/09/2021
/*/
Function OMSTPRADLU(oDadosTPR, cFilEnt, cEntida, cApi, cIdRot, cJson, cResult, lOk)
	
	oDadosTPR:InsertDLU( cFilEnt , cEntida, cIdRot , cApi ,  , "OMSATPR1" , cResult, cJson , Iif( lOk , "1","2") ) 

Return


/*/{Protheus.doc} OMSUpdRot
** Grava status na DMR
@author Equipe OMS
@since 10/09/2021
/*/
Function OMSUpdRot(cIdRot, aErrors)
	Local oModel   := Nil
	Local lRet     := .F.

	DMR->(DbSetOrder(1))
	If DMR->(DbSeek(FwxFilial("DMR")+cIdRot))

		oModel := FWLoadModel( 'TMSAC19' )
		oModel:SetOperation( 5 )
		oModel:Activate()
		lRet := oModel:VldData()
		If lRet 
			oModel:CommitData()
		Else
			Aadd(aErrors,  oModel:GetErrorMessage()[6] )
		EndIf
		oModel:Destroy()
		oModel:= Nil	
	EndIf

Return lRet

/*/{Protheus.doc} OMSTPRVldE
** Validacoes de envio (Enquanto dois usuarios estão usando os mesmos dados, podem ocorrer problemas
pois os dados da tela estãoem tabela temporaria)
1 - Se for pedido, verifica se os dados foram alterados enquanto a tela está sendo usada e avisa ao usuario
		Na primeira etapa verifica se alguém enviou todos os itens do pedido (ou o proprio pedido)
		Na segunda etapa verifica se algum item deste pedido foi enviado enquanto estava usando a tela

para roteirizar.
@author Equipe OMS
@since 14/09/2021
/*/
Static Function OMSTPRVldE(oTTPed, oBrowse, aErrors,nTipoTela)
	Local lRet     := .T.
	Local cAliasQry
	Local lIntroAvis := .F.

	If nTipoTela = 1
		OMSPedInt(@cAliasQry,oBrowse,oTTPed,.T.)
		(cAliasQry)->( dbGoTop() )
		While !(cAliasQry)->( Eof() )
			If (cAliasQry)->TMP_QTDLIB == (cAliasQry)->SUMSC9LIB .Or. (cAliasQry)->TMP_PSLIQ == (cAliasQry)->SUMSC9LIQ .Or.;
				(cAliasQry)->TMP_PESOBR == (cAliasQry)->SUMSC9BR .Or. (cAliasQry)->TMP_VOL == (cAliasQry)->SUMSC9VOL
				lRet := .F.
				Aadd(aErrors, STR0040 + (cAliasQry)->C9_PEDIDO + STR0045)//"Pedido: "" não possui itens para o Planejamento de Rotas."
			EndIf
			(cAliasQry)->( dbSkip() )
		EndDo
		(cAliasQry)->(DbCloseArea())

		If lRet
			OMSPedInt(@cAliasQry,oBrowse,oTTPed, .F.)
			(cAliasQry)->( dbGoTop() )
			If !(cAliasQry)->( Eof() )
				While !(cAliasQry)->( Eof() )
					If (cAliasQry)->TMP_QTDLIB != (cAliasQry)->SUMSC9LIB .Or. (cAliasQry)->TMP_PSLIQ != (cAliasQry)->SUMSC9LIQ .Or.;
						(cAliasQry)->TMP_PESOBR != (cAliasQry)->SUMSC9BR .Or. (cAliasQry)->TMP_VOL != (cAliasQry)->SUMSC9VOL
						If !lIntroAvis
							//"Existem pedidos que sofreram alterações enquanto estava realizando a operação de seleção:"
							Aadd(aErrors,STR0048)
							lIntroAvis := .T.
						EndIf
						lRet := .F.
						Aadd(aErrors, STR0040 + (cAliasQry)->C9_PEDIDO + " - "+;//"Pedido: "
						STR0046+cValToChar((cAliasQry)->TMP_QTDLIB)+;//" - Qtd. liberada selecionada: "
						STR0047+cValToChar((cAliasQry)->SUMSC9LIB)+".")//" | Qtd. liberada atual: "
					EndIf
					(cAliasQry)->( dbSkip() )
				EndDo
			EndIf
			(cAliasQry)->(DbCloseArea())
		EndIf
	EndIf

Return lRet


/*/{Protheus.doc} OMSTPRVPAR
** Validação dos parâmetros de entrada
@author Equipe OMS
@since 25/10/2021
/*/
Function OMSTPRVPAR(aErrors)
	Local lRet     := .T.
	Local aTemp    := {}

	If Empty(AllTrim(StrTran( MV_PAR04, ":", " " )))
		Aadd(aErrors, STR0079)//"Horário de carregamento não informado."
	EndIf
	If AllTrim(CValToChar(MV_PAR07)) = "0"
		Aadd(aErrors, STR0080)//"Quantidade máxima de carregamentos não informada."
	EndIf
	If AllTrim(CValToChar(MV_PAR08)) = "0"
		Aadd(aErrors, STR0081)//"Quilometragem entre carregamentos não informada."
	EndIf
	If AllTrim(CValToChar(MV_PAR09)) = "0"
		Aadd(aErrors, STR0082)//"Quilometragem entre entregas não informada."
	EndIf
	If AllTrim(CValToChar(MV_PAR10)) = "0"
		Aadd(aErrors, STR0083)//"Quantidade entre entregas não informada."
	EndIf
	If Empty(AllTrim(StrTran( MV_PAR11, ":", " " )))
		Aadd(aErrors, STR0084)//"Tempo mínimo de serviço não informado."
	EndIf
	If Empty(AllTrim(StrTran( MV_PAR12, ":", " " )))
		Aadd(aErrors, STR0085)//"Tempo máximo de serviço não informado."
	EndIf
	If Empty(AllTrim(StrTran( MV_PAR13, ":", " " )))
		Aadd(aErrors, STR0086)//"Horário final das entregas não informada."
	EndIf
	If !Empty(aErrors)
		lRet := .F.
		aTemp := ATail(aErrors)
		Aadd(aErrors, aTemp)
		AIns(aErrors,1)
		aErrors[1] := STR0088 //"Existem parâmetros do planejamento não preenchidos:"
	EndIf

Return lRet


/*/{Protheus.doc} OMSVALHORA
** Validação de hora nos parametros
@author Equipe OMS
@since 25/10/2021
/*/
FUNCTION OMSVALHORA(cHora)
    Local nPos    := At(":",cHora)
    Local nHora   := Val(SubStr(cHora,1,(nPos-1)))
    Local nMinuto := Val(SubStr(cHora,(nPos+1)))
    Local lRet       := nMinuto < 60 .Or. nMinuto < 0
    Local lFim        := .F.

    If "-" $ cHora
        Help(" ",1,"HORAINVALI")
        lRet := .F.
        lFim := .T.
    EndIf

    If !lFim
        //Valida a hora somente quando houver 2 digitos em Hora
        If lRet .And. nPos == 3
            lRet := nHora < 24 .Or. nMinuto < 0
        EndIf

        If Alltrim(cHORA) = ":" .Or. !lRet
            If Alltrim(cHORA) = ":"
                Help(" ",1,"HORAINVA")
            Else
                Help(" ",1,"HORAINVALI")
            EndIf
            lRet := .F.
        EndIf
    EndIf

Return lRet


/*/{Protheus.doc} OMSValSM0
** Valida o cadastro da filial
@author Equipe OMS
@since 27/05/2022
/*/
Function OMSValSM0(cEstado,cCidade,cCEP,cEndereco, aErrors)
	Local lRet := .T.

	If Empty(cEstado)
		Aadd(aErrors, STR0096)//"Favor informar o estado da filial no cadastro das filiais."
	EndIf
	If Empty(cCidade) 
		Aadd(aErrors, STR0097)//"Favor informar a cidade da filial no cadastro das filiais."
	EndIf
	If Empty(cCEP) 
		Aadd(aErrors, STR0098)//"Favor informar o CEP da filial no cadastro das filiais."
	EndIf
	If Empty(cEndereco) 
		Aadd(aErrors, STR0099)//"Favor informar o endereço da filial no cadastro das filiais."
	EndIf

	If !Empty(aErrors)
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} OMSTPRJan
** Query que traz todas as DAE tipo regra do cliente
@author Equipe OMS
@since 27/06/2022
/*/
Function OMSTPRJan(llogTPR, oQryJanela, aJanelaCli, cFilEnt, cCodEnt, cLjEnt)
	Local cQuery 	:= ""
	Local cAliasQry := GetNextAlias()

	If oQryJanela == Nil
		oQryJanela	:= FWPreparedStatement():New()
		cQuery	:= " SELECT DAE_HRINI, DAE_HRFIM, DAE_CODVEI,"
		cQuery += 		" CASE"
		cQuery += 			" WHEN DAB.DAB_FREQUE IS NULL THEN 'X'"
		cQuery += 			" ELSE DAB.DAB_FREQUE"
		cQuery += 		" END AS DAB_FREQUE"
		cQuery	+= " FROM "+ RetSqlName("DAE") + " DAE"
		cQuery	+= 		" INNER JOIN "+ RetSqlName("DAD") + " DAD"
		cQuery	+= 			" ON (DAE.DAE_FILIAL = DAD.DAD_FILIAL"
		cQuery	+= 			" AND DAE.DAE_CODIGO = DAD.DAD_CODIGO"
		cQuery	+= 			" AND DAE.DAE_REGRA = '1')"
		cQuery	+= 		" LEFT JOIN "+ RetSqlName("DAA") + " DAA "
		cQuery	+= 			" ON (DAA.DAA_FILIAL = '"+ FwXFilial("DAA") + "'" 
		cQuery	+= 			" AND DAE.DAE_CODCAL = DAA.DAA_CODIGO "
		cQuery	+= 			" AND DAA.D_E_L_E_T_ = ' ') "
		cQuery	+= 		" LEFT JOIN "+ RetSqlName("DAB") + " DAB "
		cQuery	+= 			" ON (DAB.DAB_FILIAL = '"+ FwXFilial("DAB") + "'" 
		cQuery	+= 			" AND DAA.DAA_CODIGO = DAB.DAB_CODIGO "
		cQuery	+= 			" AND DAB.D_E_L_E_T_ = ' ')"
		cQuery	+= 		" LEFT JOIN "+ RetSqlName("ACY") + " ACY "
		cQuery	+= 			" ON (ACY.ACY_FILIAL = '"+ FwXFilial("ACY") + "'" 
		cQuery	+= 			" AND DAD.DAD_GRPVEN = ACY.ACY_GRPVEN "
		cQuery	+= 			" AND ACY.D_E_L_E_T_ = ' ')"
		cQuery	+= 		" LEFT JOIN "+ RetSqlName("DAC") + " DAC"
		cQuery	+= 			" ON (DAC.DAC_FILIAL = '"+ FwXFilial("DAC") + "'" 
		cQuery	+= 			" AND DAE.DAE_GRUVEI = DAC.DAC_CODGRU"
		cQuery	+= 			" AND DAC.D_E_L_E_T_ = ' ')"
		cQuery	+= 		" LEFT JOIN "+ RetSqlName("SA1") + " SA1"
		cQuery	+= 			" ON (SA1.A1_FILIAL = ? "				//1
		cQuery	+= 			" AND DAD.DAD_CODCLI = SA1.A1_COD"
		cQuery	+= 			" AND DAD.DAD_LOJA = SA1.A1_LOJA"
		cQuery	+= 			" AND SA1.D_E_L_E_T_ = ' ')"
		cQuery	+= 			" OR (SA1.A1_FILIAL = ? "				//2 
		cQuery	+= 			" AND DAD.DAD_GRPVEN <> ' '"
		cQuery	+= 			" AND DAD.DAD_GRPVEN = SA1.A1_GRPVEN"
		cQuery	+= 			" AND SA1.D_E_L_E_T_ = ' ')"
		cQuery	+= 				" WHERE DAD.DAD_FILIAL = '"+ FwXFilial("DAD") + "'" 
		cQuery	+= 				" AND DAE.DAE_FILIAL = '"+ FwXFilial("DAE") + "'" 
		cQuery	+= 				" AND DAD.D_E_L_E_T_ = ' '"
		cQuery	+= 				" AND DAE.D_E_L_E_T_ = ' '"
		cQuery	+= 				" AND SA1.A1_COD = ? " 				//3
		cQuery	+= 				" AND SA1.A1_LOJA = ? " 			//4
		cQuery	:= ChangeQuery(cQuery)
		oQryJanela:SetQuery(cQuery)
	EndIf

	oQryJanela:SetString(1, cFilEnt )
	oQryJanela:SetString(2, cFilEnt )
	oQryJanela:SetString(3, cCodEnt )
	oQryJanela:SetString(4, cLjEnt )

	cQuery	:= oQryJanela:GetFixQuery()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

	OMSTPRCLOG(llogTPR, "OMSATPR1A", STR0094 + STR0105 + cQuery ) //"Query regras de entrega: "

	While (cAliasQry)->( !Eof() )
		If "1" $ (cAliasQry)->DAB_FREQUE .Or. ('X' $ (cAliasQry)->DAB_FREQUE .And. (!Empty((cAliasQry)->DAE_HRINI) .And. !Empty((cAliasQry)->DAE_HRFIM)))
			Aadd(aJanelaCli, {"SUN", (cAliasQry)->DAE_HRINI, (cAliasQry)->DAE_HRFIM})
		EndIf
		If "2" $ (cAliasQry)->DAB_FREQUE .Or. ('X' $ (cAliasQry)->DAB_FREQUE .And. (!Empty((cAliasQry)->DAE_HRINI) .And. !Empty((cAliasQry)->DAE_HRFIM)))
			Aadd(aJanelaCli, {"MON", (cAliasQry)->DAE_HRINI, (cAliasQry)->DAE_HRFIM})
		EndIf
		If "3" $ (cAliasQry)->DAB_FREQUE .Or. ('X' $ (cAliasQry)->DAB_FREQUE .And. (!Empty((cAliasQry)->DAE_HRINI) .And. !Empty((cAliasQry)->DAE_HRFIM)))
			Aadd(aJanelaCli, {"TUE", (cAliasQry)->DAE_HRINI, (cAliasQry)->DAE_HRFIM})
		EndIf
		If "4" $ (cAliasQry)->DAB_FREQUE .Or. ('X' $ (cAliasQry)->DAB_FREQUE .And. (!Empty((cAliasQry)->DAE_HRINI) .And. !Empty((cAliasQry)->DAE_HRFIM)))
			Aadd(aJanelaCli, {"WED", (cAliasQry)->DAE_HRINI, (cAliasQry)->DAE_HRFIM})
		EndIf
		If "5" $ (cAliasQry)->DAB_FREQUE .Or. ('X' $ (cAliasQry)->DAB_FREQUE .And. (!Empty((cAliasQry)->DAE_HRINI) .And. !Empty((cAliasQry)->DAE_HRFIM)))
			Aadd(aJanelaCli, {"THU", (cAliasQry)->DAE_HRINI, (cAliasQry)->DAE_HRFIM})
		EndIf
		If "6" $ (cAliasQry)->DAB_FREQUE .Or. ('X' $ (cAliasQry)->DAB_FREQUE .And. (!Empty((cAliasQry)->DAE_HRINI) .And. !Empty((cAliasQry)->DAE_HRFIM)))
			Aadd(aJanelaCli, {"FRI", (cAliasQry)->DAE_HRINI, (cAliasQry)->DAE_HRFIM})
		EndIf
		If "7" $ (cAliasQry)->DAB_FREQUE .Or. ('X' $ (cAliasQry)->DAB_FREQUE .And. (!Empty((cAliasQry)->DAE_HRINI) .And. !Empty((cAliasQry)->DAE_HRFIM)))
			Aadd(aJanelaCli, {"SAT", (cAliasQry)->DAE_HRINI, (cAliasQry)->DAE_HRFIM})
		EndIf
		(cAliasQry)->( dbSkip() )
	EndDo
	(cAliasQry)->( DbCloseArea() )
Return


/*/{Protheus.doc} OMSTPRVei
** Query que traz todos os veiculos do tipo excecao do cliente
@author Equipe OMS
@since 27/06/2022
/*/
Function OMSTPRVei(llogTPR, oQryVeicul, aRestrVeic,cFilEnt, cCodEnt, cLjEnt)
	Local cQuery 	:= ""
	Local cAliasQry := GetNextAlias()

	If oQryVeicul == Nil
		oQryVeicul	:= FWPreparedStatement():New()
		cQuery	:= " SELECT DAE_CODVEI,DA3_FILIAL,DA3_COD "
		cQuery	+= " FROM "+ RetSqlName("DAE") + " DAE"
		cQuery	+= 		" INNER JOIN "+ RetSqlName("DAD") + " DAD"
		cQuery	+= 			" ON (DAE.DAE_FILIAL = DAD.DAD_FILIAL"
		cQuery	+= 			" AND DAE.DAE_CODIGO = DAD.DAD_CODIGO"
		cQuery	+= 			" AND DAE.DAE_REGRA = '2')" //Linha diferente da query regra
		cQuery	+= 		" LEFT JOIN "+ RetSqlName("DAA") + " DAA "
		cQuery	+= 			" ON (DAA.DAA_FILIAL = '"+ FwXFilial("DAA") + "'" 
		cQuery	+= 			" AND DAE.DAE_CODCAL = DAA.DAA_CODIGO "
		cQuery	+= 			" AND DAA.D_E_L_E_T_ = ' ') "
		cQuery	+= 		" LEFT JOIN "+ RetSqlName("DAB") + " DAB "
		cQuery	+= 			" ON (DAB.DAB_FILIAL = '"+ FwXFilial("DAB") + "'" 
		cQuery	+= 			" AND DAA.DAA_CODIGO = DAB.DAB_CODIGO "
		cQuery	+= 			" AND DAB.D_E_L_E_T_ = ' ')"
		cQuery	+= 		" LEFT JOIN "+ RetSqlName("ACY") + " ACY "
		cQuery	+= 			" ON (ACY.ACY_FILIAL = '"+ FwXFilial("ACY") + "'" 
		cQuery	+= 			" AND DAD.DAD_GRPVEN = ACY.ACY_GRPVEN "
		cQuery	+= 			" AND ACY.D_E_L_E_T_ = ' ')"
		cQuery	+= 		" LEFT JOIN "+ RetSqlName("DAC") + " DAC"
		cQuery	+= 			" ON (DAC.DAC_FILIAL = '"+ FwXFilial("DAC") + "'" 
		cQuery	+= 			" AND DAE.DAE_GRUVEI = DAC.DAC_CODGRU"
		cQuery	+= 			" AND DAC.D_E_L_E_T_ = ' ')"
		cQuery	+= 		" LEFT JOIN "+ RetSqlName("SA1") + " SA1"
		cQuery	+= 			" ON (SA1.A1_FILIAL = ? "				//1
		cQuery	+= 			" AND DAD.DAD_CODCLI = SA1.A1_COD"
		cQuery	+= 			" AND DAD.DAD_LOJA = SA1.A1_LOJA"
		cQuery	+= 			" AND SA1.D_E_L_E_T_ = ' ')"
		cQuery	+= 			" OR (SA1.A1_FILIAL = ? "				//2 
		cQuery	+= 			" AND DAD.DAD_GRPVEN <> ' '"
		cQuery	+= 			" AND DAD.DAD_GRPVEN = SA1.A1_GRPVEN"
		cQuery	+= 			" AND SA1.D_E_L_E_T_ = ' ')"
		cQuery	+= 		" LEFT JOIN "+ RetSqlName("DA3") + " DA3" 				//Linha que a query regra nao possui
		cQuery	+= 			" ON (DA3.DA3_FILIAL = '"+ FwXFilial("DA3") + "'" 	//Linha que a query regra nao possui
		cQuery	+= 			" AND DA3.DA3_CODGRU = DAC.DAC_CODGRU"				//Linha que a query regra nao possui
		cQuery	+= 			" OR DA3.DA3_COD = DAE.DAE_CODVEI"					//Linha que a query regra nao possui
		cQuery	+= 			" AND DA3.D_E_L_E_T_ = ' ')"						//Linha que a query regra nao possui
		cQuery	+= 				" WHERE DAD.DAD_FILIAL = '"+ FwXFilial("DAD") + "'" 
		cQuery	+= 				" AND DAE.DAE_FILIAL = '"+ FwXFilial("DAE") + "'" 
		cQuery	+= 				" AND DAD.D_E_L_E_T_ = ' '"
		cQuery	+= 				" AND DAE.D_E_L_E_T_ = ' '"
		cQuery	+= 				" AND SA1.A1_COD = ? " 				//3
		cQuery	+= 				" AND SA1.A1_LOJA = ? " 			//4
		cQuery	:= ChangeQuery(cQuery)
		oQryVeicul:SetQuery(cQuery)
	EndIf

	oQryVeicul:SetString(1, cFilEnt )
	oQryVeicul:SetString(2, cFilEnt )
	oQryVeicul:SetString(3, cCodEnt )
	oQryVeicul:SetString(4, cLjEnt )

	cQuery	:= oQryVeicul:GetFixQuery()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

	OMSTPRCLOG(llogTPR, "OMSATPR1A", STR0094 + STR0106 + cQuery )//"Query excecao de veiculos: "

	While (cAliasQry)->( !Eof() )
		Aadd(aRestrVeic, {(cAliasQry)->DA3_FILIAL + (cAliasQry)->DA3_COD})
		(cAliasQry)->( dbSkip() )
	EndDo
	(cAliasQry)->( DbCloseArea() )
Return
