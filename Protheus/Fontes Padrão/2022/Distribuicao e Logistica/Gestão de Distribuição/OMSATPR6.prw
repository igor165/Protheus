#include 'TOTVS.ch'
#include 'OMSATPR6.ch'


/*/{Protheus.doc} OMSATPR6
** Programa responsavel pelo processamento do Callback com a carga montada
Gera apenas o sequenciamento
@author Equipe OMS
@since 25/08/2021
/*/
Function OMSATPR6(llogTPR, oCallJson, cFilrot, cIdRot, cJson)
	Local lRet := .T.
	Local cCarga
	Local cCHVEXT
	Local nI
	Local aDoctosOK  := {}
	Local cDurRot    := 0
	Local cDistRot   := 0
	Local nVlRotPdg  := 0
	Local cNmElement := IIF(FWIsInCallStack("OMSATPR7") ,"tripResults","tripsResults")
	Local aMsgs 	:= {}
	Local aMsgsPed 	:= {}
	Local lRegerar  := .F.
	Local lIntGFE	:= SuperGetMv("MV_INTGFE",.F.,.F.)
	Local cIntGFE2	:= SuperGetMv("MV_INTGFE2",.F.,"2")
	Local cIntCarga := SuperGetMv("MV_GFEI12",.F.,"2")
	Local cErro     := ""

	OMSTPRCLOG(llogTPR, "OMSATPR6", STR0001 + STR0002 ) //"TOTVS Planejamento de Rotas(TPR) - " "Carga recebida no callback para sequenciar."

	DMS->(DbSetOrder(1))
	If DMS->(DbSeek(FwXFilial("DMS")+cFilROT+cIdRot))
		cCHVEXT := DMS->DMS_CHVEXT
		cCarga := RTrim(SubStr( cCHVEXT , TamSX3('DMS_FILIAL')[1]+1 ))
	EndIf

	//Retorna as cargas que podem ser geradas
	For nI := 1 to Len(oCallJson:GetJSonObject(cNmElement))

		oCarga := oCallJson:GetJSonObject(cNmElement)[nI]

		cDurRot := OMSMiliseg( oCarga["duration"], 1)
		cDistRot := Round( oCarga["distance"], TamSX3("DAK_DISROT")[2] )
		nVlRotPdg := oCarga["tollValue"]

		aDoctosOK := OMSUpdDAI(oCarga:GetJSonObject("stops"), cCarga, aDoctosOK)

	Next nI

	//Realiza a gravacao dos registros rejeitados (mensagens de rejeicoes)
	If Len(oCallJson:GetJSonObject("rejections")) > 0 
		OMSATPRRej(oCallJson:GetJSonObject("rejections"), cFilrot, cIdRot, @aMsgsPed, @aMsgs)
		TPRREJDms(cFilRot,cIdRot,aMsgsPed, aMsgs)
	EndIf

	/*Mensagens gerais
	If Len(oCallJson:GetJSonObject("messages")) > 0
		OMSTPRRotM(oCallJson:GetJSonObject("messages"), @aMsgsRot)
		TPRREJDms(cFilRot,cIdRot,,aMsgsRot)
		//Enviar também essas mensagens para o registro da DMS se a carga for gerada.
	EndIf */
	
	If !Empty(aDoctosOK)

		OMSTPRCLOG(llogTPR, "OMSATPR6", STR0001 + STR0004 )//"Atualizando o status das DMR e DMS para processado."

		OMSTPRADMS(cFilRot, cIdRot, aDoctosOK, cCarga, 0, 2)

		DAK->(DbSetOrder(1))
		If DAK->(DbSeek(xFilial("DAK") + RTrim(cCarga)))
			Reclock("DAK",.F.)
			DAK->DAK_DISROT := cDistRot
			DAK->DAK_TIMROT := cDurRot
			DAK->DAK_VALROT := nVlRotPdg
			DAK->DAK_VIAEXT := "1"
			DAK->(MsUnlock())
		EndIf

		If lIntGFE .And. cIntGFE2 $ "1" .And. cIntCarga == "1"
			//"Alterando Romaneio de carga para Carga, Sequencia de Carga: "
			OMSTPRCLOG(llogTPR, "OMSATPR6", STR0001 + STR0006 + DAK->DAK_COD +", " +DAK->DAK_SEQCAR)
			If !OMSA200IPG(4,DAK->DAK_CAMINH,,,lRegerar,DAK->DAK_COD,,,,,,,DAK->DAK_DISROT,@cErro)
				//Erros GFE
				cErro :=  STR0005 + cErro
				OMSTPRCLOG(llogTPR, "OMSATPR6", STR0001 + cErro)////"TOTVS Planejamento de Rotas(TPR) - ""Erros ao integrar com o GFE: " 
			EndIf  
		EndIf
	EndIf

	OMSTPRCLOG(llogTPR, "OMSATPR6", STR0001 + STR0003 ) //"Processo de sequenciamento finalizado."

Return lRet


/*/{Protheus.doc} OMSUpdDAI
** Realizada a atualizacao da DAI de acordo com a viagem retornada na integracao
@author Equipe OMS
@since 04/05/2022
/*/
Function OMSUpdDAI(aStops, cCarga, aDoctosOK) 
	Local nX
	Local nJ
	Local nSequen 	 := 0
	Local cAliasQry  := ""
	Local cCliAnt 	 := ""
	Local cSequen 	 := ""
	Local cLojaAnt 	 := ""
	Local aUTCItemCh := {}
	Local cHRItemChe := ""
	Local aUTCItemSd := {}
	Local cTimeSrv 	 := ""
	Local dDTItemSai
	Local cPedido
	Local lHVerao 	:= SuperGetMv("MV_HVERAO",.F.,.F.)
	Local nSeqInc 	:= SuperGetMV("MV_OMSENTR" ,.F.,5)
	Local cCliente
	Local cLoja
	Local cCliLoja := ""
	Default aDoctosOK := {}

	For nX := 1 To Len(aStops)
		If nX > 1
			oStop := aStops[nX]
			If oStop["sequence"] == 0 .Or. oStop["type"] == "FAKE_STOP" //Sequencia 0 é a origem
				Loop
			EndIf
			nSequen +=  nSeqInc
			cCliLoja := oStop["locality"]["identifier"]

			cCliente := SubStr(cCliLoja,TamSX3("DAI_FILIAL")[1]+1,tamSx3("DAI_CLIENT")[1])
			cLoja 	:=  SubStr(cCliLoja,TamSX3("DAI_FILIAL")[1]+TamSX3("DAI_CLIENT")[1]+1)

			For nJ := 1 To Len(oStop:GetJSonObject("unloadedOrders"))
				oDescarreg := oStop:GetJSonObject("unloadedOrders")[nJ]

				cPedido := SubStr( oDescarreg["identifier"] , TamSX3('DAI_FILIAL')[1]+1 )

				aUTCItemCh	:= TPRUTCData(oStop["arrivalTime"], lHVerao)

				dDTItemChe 	:= aUTCItemCh[1]
				cHRItemChe 	:= aUTCItemCh[2]

				aUTCItemSd	:= TPRUTCData(oStop["departureTime"], lHVerao)
				dDTItemSai 	:= aUTCItemSd[1]

				cTimeSrv := OMSTimeSrv( aUTCItemCh, aUTCItemSd )

				cAliasQry   := GetNextAlias()

				BeginSql Alias cAliasQry
				SELECT DAI.R_E_C_N_O_ RECNODAI
					FROM %Table:DAI% DAI
					WHERE DAI.DAI_FILIAL = %xFilial:DAI%
					AND DAI_CLIENT = %Exp:cCliente%
					AND DAI_LOJA = %Exp:cLoja%
					AND DAI_PEDIDO = %Exp:cPedido%
					AND DAI.DAI_COD = %Exp:cCarga%
					AND DAI.%NotDel%
				EndSql

				If !(cCliente == cCliAnt) .Or. !(cLoja == cLojaAnt)
					cCliAnt  := cCliente
					cLojaAnt := cLoja
					cSequen  := StrZero(nSequen,6)
				EndIf

				If (cAliasQry)->(!EoF())
					DAI->(DbGoTo((cAliasQry)->RECNODAI))
					Reclock("DAI",.F.)
					DAI->DAI_SEQUEN := cSequen
					DAI->DAI_PERCUR := "999999"
					DAI->DAI_ROTA   := "999999"
					DAI->DAI_ROTEIR := "999999"
					DAI->DAI_TIMEST := cHRItemChe

					DAI->DAI_DTSAID := dDTItemSai
					DAI->DAI_DTCHEG := dDTItemChe
					DAI->DAI_CHEGAD := cHRItemChe
					DAI->DAI_TMSERV := cTimeSrv

					DAI->(MsUnlock())
				EndIf
				(cAliasQry)->(DbCloseArea())

				cAliasQry   := GetNextAlias()
				BeginSql Alias cAliasQry
				SELECT SC9.R_E_C_N_O_ RECNOSC9
					FROM %Table:SC9% SC9
					WHERE SC9.C9_FILIAL =  %xFilial:SC9%
					AND SC9.C9_PEDIDO = %Exp:cPedido%  //um pedido por cliente
					AND SC9.C9_CARGA = %Exp:cCarga%
					AND SC9.%NotDel%
				EndSql
				While (cAliasQry)->(!EoF())
					SC9->(DbGoTo((cAliasQry)->RECNOSC9))
					Aadd(aDoctosOK, SC9->C9_FILIAL + SC9->C9_PEDIDO + SC9->C9_ITEM + SC9->C9_SEQUEN + SC9->C9_PRODUTO )
					Reclock("SC9",.F.)
					SC9->C9_SEQENT := cSequen
					SC9->(MsUnlock())
					(cAliasQry)->(DbSkip())
				EndDo
				(cAliasQry)->(DbCloseArea())
			Next nJ
		EndIf
	Next nX

Return aDoctosOK
