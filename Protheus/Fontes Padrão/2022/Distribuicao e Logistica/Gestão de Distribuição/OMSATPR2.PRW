#INCLUDE "PROTHEUS.CH"
#include "OMSATPR2.CH"

CLASS OMSTPRCarga
	DATA aCpoCarga  As Array
	DATA aObjItens  As Array
	DATA aItensSC9  As Array
	DATA aDoctosNOK As Array
	DATA aDoctosOK  As Array
	DATA cCodCarga  As Char
	DATA nSeqRot    As Numeric
	METHOD New()
END CLASS  

METHOD New() CLASS OMSTPRCarga
	Self:aObjItens	:= {}
	Self:aCpoCarga 	:= {}
Return

/*/{Protheus.doc} OMSATPR2
** Programa responsavel pelo processamento do Callback e Montagem da Carga
@author Equipe OMS
@since 25/08/2021
/*/
Function OMSATPR2(cIdent, cResult)
	Local oCallJson 	:= Nil
	Local oQualiJson 	:= Nil
	Local lRet			:= .T.
	Local lProcessa		:= .T.
	Local cErr1 		:= ""
	Local cErr2 		:= ""
	Local oTpr 			:= Nil
	Local llogTPR		:= .F.
	Local cRoutType		:= ""

	OMSTPRCLOG(.T., "OMSATPR2",  STR0001 + cResult) //"TOTVS Planejamento de Rotas(TPR) - "
	oCallJson := JSonObject():New()
	cErr1 := oCallJson:fromJson(cResult)

	IIf(!Empty(cErr1), lRet := .F., lRet := .T.)
	OMSTPRCLOG(llogTPR, "OMSATPR2",  STR0001 + STR0016 + cValToChar(cErr1)) //"OMSATPR2 - Existe erro ao converter o json de entrada? Variável com os erros igual a: "    

	If lRet
		oQualiJson := JSonObject():New()
		cErr2 := oQualiJson:fromJson( oCallJson["qualifiers"])
		IIf(!Empty(cErr2), lRet := .F., lRet := .T.)
		OMSTPRCLOG(llogTPR, "OMSATPR2",  STR0001 + STR0017 + cValToChar(cErr2)) //"OMSATPR2 - Existe erro ao converter o json de qualifers? Variável com os erros igual a: "    

		If lRet
			cRoutType :=  oQualiJson["routingType"]

			llogTPR		:= SuperGetMV("MV_TPRCLOG",.F.,.T.)

			//Grava json de callback
			oTpr    := TMSBCATPRNeolog():New()	
			oTpr:UpdateDLU( FwXFilial("DMR") , "DMR" , cIdent , "Routing", , "OMSATPR2", cResult )

			DMR->(DbSetOrder(1))
			If DMR->(DbSeek(FwXfilial("DMR")+cIdent))
				If DMR->DMR_STATUS == '1'
					OMSTPRCLOG(llogTPR, "OMSATPR2", STR0002 + cIdent )//"TOTVS Planejamento de Rotas(TPR) - Processando a integracao de ID: "
				ElseIf DMR->DMR_STATUS == '2'
					OMSTPRCLOG(llogTPR, "OMSATPR2", STR0003 + cIdent )//"TOTVS Planejamento de Rotas(TPR) - Integracao ja processada de ID: "
					lProcessa := .F.
				Else
					//Caso seja possivel cancelar
				EndIf
			Else
				OMSTPRCLOG(llogTPR, "OMSATPR2", STR0004 + cIdent )//"TOTVS Planejamento de Rotas(TPR) - Integracao excluida de ID: "
				lProcessa := .F.
			EndIf

			If lProcessa
				OMSTPRPROC(llogTPR, oCallJson, cIdent, cRoutType, cResult)
			EndIf
		EndIf
	EndIf

Return lRet



Static Function OMSTPRPROC(llogTPR, oCallJson, cIdent, cRoutType, cJson)
	Local cFilRot		:= ""
	Local cIdRot		:= ""
	Local lRet 			:= .T.

	cFilRot := SubStr(cIdent,1,TamSx3("DMR_FILIAL")[1])
	cIdRot  := SubStr(cIdent,TamSx3("DMR_FILIAL")[1]+1)

	//Altera Status para processado e falha em todos os registros DMS para serem atualizados posteriormente
	TPRStatIni(llogTPR,cFilrot,cIdRot,STR0005,"4","")

	If Empty(cRoutType) .OR. cRoutType = "ROUTING"
		lRet := PrepCarga(llogTPR,oCallJson,cFilrot,cIdRot, cJson)
	ElseIf !Empty(cRoutType) .And. cRoutType = "SEQUENCE"
		OMSATPR6(llogTPR, oCallJson, cFilrot, cIdRot, cJson)
	EndIf

Return lRet


/*/{Protheus.doc} TPRStatIni
** Função para alterar o Status de todos os registros das tabelas DMR e DMS
ante processamento do Json
@author Equipe OMS
@since 24/09/2021
/*/
Static Function TPRStatIni(llogTPR, cFilrot,cIdRot, cMsg,cStatus,cCHVExt)
	Local nX 	:= 0
	Local lRet 	:= .T.

	DMR->(DbSetOrder(1))
	If DMR->(DbSeek(FwXFilial("DMR")+cFilrot+cIdRot))
		oModel := FWLoadModel( 'TMSAC19' )
		oModel:SetOperation( 4 )
		oModel:Activate()

		oMdFldDMR:= oModel:GetModel("MdFieldDMR")
		oMdGrdDMS:= oModel:GetModel("MdGridDMS")
		oMdFldDMR:LoadValue("DMR_STATUS","2")
		
		For nX := 1 To oMdGrdDMS:Length()	
			oMdGrdDMS:Goline(nX)
			If (!Empty(cCHVExt) .And. cCHVExt == AllTrim( oMdGrdDMS:GetValue("DMS_CHVEXT"))) .Or. Empty(cCHVExt)
				oMdGrdDMS:LoadValue("DMS_MSGERR",cMsg)	
			EndIf
			If !Empty(cStatus)
				oMdGrdDMS:LoadValue("DMS_STATUS",cStatus)
			EndIf
			If cStatus = "4"
				oMdGrdDMS:LoadValue("DMS_SEQROT",-1)
			EndIf
		Next nX

		lRet := oModel:VldData()
		If lRet 
			oModel:CommitData()
		Else
			OMSTPRCLOG(llogTPR, "OMSATPR2", STR0006 + cFilrot+cIdRot + " - "+ oModel:GetErrorMessage()[6])//"TOTVS Planejamento de Rotas(TPR) - Inconsistências na DMR de ID: "
		EndIf
		oModel:Destroy()
		oModel:= Nil
	Else
		OMSTPRCLOG(llogTPR, "OMSATPR2", STR0007 + cFilrot+cIdRot)	//"TOTVS Planejamento de Rotas(TPR) - Não foi encontrada a DMR de ID: "
	EndIf
Return

/*/{Protheus.doc} PrepCarga
** Leitura do Json e gravação do dos objtos para montagem da carga.
@author Equipe OMS
@since 25/08/2021
/*/
Static Function PrepCarga(llogTPR,oCallJson,cFilRot,cIdRot, cJson)
	Local nX		:= 1
	Local oCarga 	:= Nil
	Local aCargas 	:= {}
	Local lCommit 	:= .T.
	Local aMsgs 	:= {}
	Local aMsgsRot 	:= {}
	Local aMsgsPed 	:= {}
	Local lRet 		:= .T.
	Local cErro 	:= ""
	Local cErros 	:= ""
	Local lIntGFE	:= SuperGetMv("MV_INTGFE",.F.,.F.)
	Local cIntGFE2	:= SuperGetMv("MV_INTGFE2",.F.,"2")
	Local cIntCarga := SuperGetMv("MV_GFEI12",.F.,"2")
	Local aRomaneios := {}
			
	//Retorna as cargas que podem ser geradas
 	For nX := 1 to Len(oCallJson:GetJSonObject("tripsResults"))
		omsTPRCarga := OMSTPRCarga():New()
		oCarga := oCallJson:GetJSonObject("tripsResults")[nX]
		TprCargas(@omsTPRCarga, oCarga,cFilrot,cIdRot,llogTPR)
		Aadd(aCargas, omsTPRCarga)
	Next nX

	//Realiza a gravacao dos registros rejeitados (mensagens de rejeicoes)
	If Len(oCallJson:GetJSonObject("rejections")) > 0 
		OMSATPRRej(oCallJson:GetJSonObject("rejections"), cFilrot, cIdRot, @aMsgsPed, @aMsgs, llogTPR)
		TPRREJDms(cFilRot,cIdRot,aMsgsPed, aMsgs)
	EndIf

	//Mensagens gerais
	If Len(oCallJson:GetJSonObject("messages")) > 0
		OMSTPRRotM(oCallJson:GetJSonObject("messages"), @aMsgsRot)
		TPRREJDms(cFilRot,cIdRot,,aMsgsRot)
		//Enviar também essas mensagens para o registro da DMS se a carga for gerada.
	EndIf

	//A transacao ficará apenas nas tabelas SC9, DAK e DAI
	If !Empty(lRet) .And. lRet .And. !Empty(aCargas)
		Begin Transaction
			For nX := 1 to Len(aCargas)
				oCarga := aCargas[nX]
				If !Empty(oCarga:cCodCarga) .And. !Empty(oCarga:aDoctosOK)
					OMSTPRADMS(cFilRot, cIdRot, oCarga:aDoctosOK, oCarga:cCodCarga, oCarga:nSeqRot,1,aMsgsRot)
				ElseIf Empty(oCarga:cCodCarga)
					TPRNOKDms(cFilRot, cIdRot, oCarga:aDoctosOK, oCarga:aDoctosNOK, oCarga:cCodCarga)
				EndIf
			Next nX

			lCommit := GeraCargas(llogTPR,aCargas,cFilrot,cIdRot,@aRomaneios)

			If lCommit
				ConfirmSX8()
			EndIf

			If !lCommit
				DisarmTransaction()
				RollBackSX8()
			EndIf
		End Transaction

		If lCommit .And. lIntGFE .And. cIntGFE2 $ "1" .And. cIntCarga == "1"
			// Integração com o GFE - Geração de Romaneio

			For nX := 1 To Len(aRomaneios)
				//"Gerando Romaneio de carga para Carga, Sequencia de Carga e Pedido: "
				OMSTPRCLOG(llogTPR, "OMSATPR2", STR0001 + STR0013 + aRomaneios[nX][1] +", " +aRomaneios[nX][2]+ ","+aRomaneios[nX][3])
				If !OMSA200IPG(3,,,.T.,aRomaneios[nX][1],aRomaneios[nX][2],aRomaneios[nX][3],aRomaneios[nX][4],aRomaneios[nX][5],aRomaneios[nX][6],,,aRomaneios[nX][7],@cErro)
					//Erros GFE
					cErros :=  STR0012 + cErro
					TPRStatIni(llogTPR,cFilrot,cIdRot,cErros,"",FwXFilial("DAK")+aRomaneios[nX][1])
					OMSTPRCLOG(llogTPR, "OMSATPR2", STR0001 + STR0012 + cErro)////"TOTVS Planejamento de Rotas(TPR) - ""Erros ao integrar com o GFE: " 
				EndIf  
			Next nX
		EndIf

	EndIf

Return lCommit


/*/{Protheus.doc} GeraCargas
** Validação da gravação da carga.
@author Equipe OMS
@since 25/08/2021
/*/
Function GeraCargas(llogTPR,aCargas,cFilRot,cIdRot,aRomaneios)
	Local nK
	Local nI
	Local nX
	Local nY
	Local nZ
	Local aItem
	Local aCab
	Local oCarga
	Local aItens
	Local aItensSC9
	Local cChaveSC9
	Local cCargaSC9
	Local cSeqCarSC9
	Local cSeqEntSC9
	Local lRet := .T.
	Local cPedido := ""

	For nK := 1 to Len(aCargas)
		oCarga 	:= aCargas[nK]
		If !Empty(oCarga:aDoctosOK)
			aCab 		:= oCarga:aCpoCarga
			aItensSC9 	:= oCarga:aItensSC9
			cPedido 	:= ""

			RecLock("DAK",.T.)
			For nX := 1 to Len(aCab)
				If DAK->(ColumnPos(aCab[nX][1])) > 0 .And. (TamSX3(aCab[nX][1])[3] = ValType(aCab[nX][2]))
					DAK->&(aCab[nX][1]) := aCab[nX][2]
				Else
					OMSTPRCLOG(llogTPR, "OMSATPR2",STR0001 + STR0008 + aCab[nX][1] + STR0009)//"Verifique se o campo "" existe ou possui o tipo de dado informado."
					Return .F.
					Exit
				EndIf
			Next nX
			DAK->(MsUnlock())
			aItens 	:= oCarga:aObjItens

			For nY := 1 to Len(aItens)
				aItem := aItens[nY]
				For nZ := 1 to Len(aItem)
					aCposItem := aItem[nZ]
					RecLock("DAI",.T.)
					For nI := 1 to Len(aCposItem)

						If Empty(cPedido) .And. aCposItem[nI][1] == "DAI_PEDIDO"
							cPedido := aCposItem[nI][2]
						EndIf

						If DAI->(ColumnPos(aCposItem[nI][1])) > 0 .And. (TamSX3(aCposItem[nI][1])[3] = ValType(aCposItem[nI][2]))
							DAI->&(aCposItem[nI][1]) := aCposItem[nI][2]
						Else
							OMSTPRCLOG(llogTPR, "OMSATPR2",STR0001 + STR0008 + aCposItem[nI][1] + STR0009)//"Verifique se o campo "" existe ou possui o tipo de dado informado."
							Return .F.
							Exit
						EndIf
					Next nI
					DAI->(MsUnlock())
				Next nZ
			Next nY

			//Atualização do registro na tabela SC9
			SC9->(DbSetOrder(1))
			For nY := 1 To Len(aItensSC9)
				cChaveSC9  := aItensSC9[nY][1]
				cCargaSC9  := aItensSC9[nY][2]
				cSeqCarSC9 := aItensSC9[nY][3]
				cSeqEntSC9 := aItensSC9[nY][4]
				IF SC9->(DbSeek(cChaveSC9))
					RecLock("SC9",.F.)
					SC9->C9_CARGA   := cCargaSC9
					SC9->C9_SEQCAR  := cSeqCarSC9
					SC9->C9_SEQENT  := cSeqEntSC9
					SC9->(MsUnLock())
				EndIf
			Next nY

			Aadd(aRomaneios, {DAK->DAK_COD,DAK->DAK_SEQCAR,cPedido,DAK->DAK_TRANSP,DAK->DAK_CDTPOP,DAK->DAK_CDCLFR,DAK->DAK_DISROT})
		Else
			lRet := .F.
			Exit
		EndIf
	Next nK

Return lRet

/*/{Protheus.doc} TprCargas
** Grava o  cabeçalho da carga, tabela DAK
@author Equipe OMS
@since 25/08/2021
/*/
Static Function TprCargas(omsTPRCarga,oCarga,cFilRot,cIdRot,llogTPR)
	Local cCarga 	:= OMSCodCarg()
	Local cSeqCar 	:= "01"
	Local aCab		:= Nil
	Local nTamFil   := FwSizeFilial()
	Local nPesoTrip := oCarga["weight"]
	Local nVolTrip 	:= oCarga["volume"]
	Local aUTCCar  	:= {}
	Local aUTCStart	:= {}
	Local cVeic     := ""
	Local lHVerao 	:= SuperGetMv("MV_HVERAO",.F.,.F.)// Verifica se o local fisico do servidor está em Horário de Verão  .F. Não / .T. Sim 
	Local cCdTpOp   := SuperGetMv("MV_CDTPOP",.F.,"") //Classificação de Frete no GFE
	Local cCdClFr   := SuperGetMv("MV_CDCLFR",.F.,"")//Tipo de Operação de Frete no GFE
	Local cHrStart  := ""
	Local cExtraTrip := "2"
	Local cDurRot   := "0000:00"
	Local cDistRot  := 0
	Local nVlRotPdg := 0

	cDurRot := OMSMiliseg( oCarga["duration"], 0)


	cDistRot := Round( oCarga["distance"], TamSX3("DAK_DISROT")[2] )
	
	nVlRotPdg := oCarga["tollValue"]

	aUTCCar		:= TPRUTCData(oCarga:GetJSonObject("stops")[1]["departureTime"], lHVerao)

	aUTCStart	:= TPRUTCData(oCarga:GetJSonObject("stops")[1]["arrivalTime"], lHVerao)

	IF oCarga["extraTrip"]
		cExtraTrip := "1"
	EndIf

	// Preenchimento do veiculo na carga
	DA3->(DbSetOrder(1))
	If DA3->(DbSeek(oCarga["vehicle"]["identifier"])) 
		cVeic := SubStr(oCarga["vehicle"]["identifier"],nTamFil+1)
	EndIf

	cHrStart 	:= aUTCStart[2]
	aCab := {{"DAK_FILIAL", FwXFilial("DAK")},;
			{"DAK_COD"   , cCarga},;
			{"DAK_SEQCAR", cSeqCar,},;
			{"DAK_ROTEIR", "999999"},;
			{"DAK_PESO"  , nPesoTrip},;
			{"DAK_CAPVOL" , nVolTrip},;
			{"DAK_PTOENT", 1},;
			{"DAK_DATA"  , dDatabase},;
			{"DAK_HORA"  , Time()},;
			{"DAK_VALOR",50},;           
			{"DAK_FEZNF","2"}, ;
			{"DAK_JUNTOU", "MANUAL"},;
			{"DAK_ACECAR", "2"},;
			{"DAK_ACEVAS", "2"},;
			{"DAK_ACEFIN", "2"},;
			{"DAK_FLGUNI", "2"},;
			{"DAK_HRSTAR", cHrStart},;
			{"DAK_CAMINH", cVeic},;
			{"DAK_CDTPOP", cCdTpOp},;
			{"DAK_CDCLFR", cCdClFr},;
			{"DAK_INTTPR", "1"},;
			{"DAK_VIAEXT", cExtraTrip},;
			{"DAK_DISROT", cDistRot},;
			{"DAK_TIMROT", cDurRot },;
			{"DAK_VALROT", nVlRotPdg },;
			{"DAK_BLQCAR",""}}

	omsTPRCarga:aCpoCarga := aCab
	omsTPRCarga:nSeqRot := oCarga["sequential"]

	TPRDAKItem(@omsTPRCarga, oCarga, cCarga, cSeqCar,cFilrot,cIdRot,lHVerao,llogTPR)

Return

/*/{Protheus.doc} TPRDAKItem
** Grava o item da carga,  tabela DAI
@author Equipe OMS
@since 25/08/2021
/*/
Static Function TPRDAKItem(omsTPRCarga, oCarga, cCodCarga, cCodSeq,cFilRot,cIdRot,lHVerao,llogTPR)
	Local nSeqInc 	:= SuperGetMV("MV_OMSENTR",.F.,5)
	Local nSequen 	:= 0
	Local aItens 	:= {}
	Local aItem 	:= {}
	Local aPedido	:= {}
	Local aDoctosOK := {}
	Local aDoctosNOK := {}
	Local nX 		:= 0
	Local nJ 		:= 0
	Local nI         := 0
	Local cChaveSC9 := ""
	Local oStop
	Local oDescarreg
	Local aUTCItemCh
	Local dDTItemChe
	Local cHRItemChe
	Local aUTCItemSd
	Local dDTItemSai
	Local cHRItemSai
	Local aItensSC9 := {}
	Local cCliLoja := ""
	Local nPos     := 0
	Local cTimeSrv := ""
	Local lDaiFilPv  := DAI->( ColumnPos("DAI_FILPV" ) ) > 0

	
	For nX := 1 To Len(oCarga:GetJSonObject("stops"))
		If nX > 1
			oStop := oCarga:GetJSonObject("stops")[nX]
			If oStop["sequence"] == 0 //Sequencia 0 é a origem
				Loop
			EndIf

			cCliLoja := oStop["locality"]["identifier"]

			For nJ := 1 To Len(oStop:GetJSonObject("unloadedOrders"))
				oDescarreg := oStop:GetJSonObject("unloadedOrders")[nJ]
				aPedido := QueryPed(cFilRot,cIdRot,oDescarreg["identifier"],llogTPR)
				For nI := 1 To Len(aPedido)
							
					
					cChaveSC9 := aPedido[nI]
					SC9->(DbSetOrder(1))
					IF SC9->(DbSeek(cChaveSC9)) .And. TPRvldSC9(cChaveSC9, llogTPR)
						Aadd(aDoctosOK,aPedido[nI])	
						
						nPos := TPRDAIPed(aItens, SC9->C9_PEDIDO)
						If nPos == 0
							nSequen += nSeqInc
							aUTCItemCh	:= TPRUTCData(oStop["arrivalTime"], lHVerao)

							dDTItemChe 	:= aUTCItemCh[1]
							cHRItemChe 	:= aUTCItemCh[2]
							aUTCItemSd	:= TPRUTCData(oStop["departureTime"], lHVerao) 

							dDTItemSai 	:= aUTCItemSd[1]
							cHRItemSai 	:= aUTCItemSd[2]

							cTimeSrv := OMSTimeSrv( aUTCItemCh, aUTCItemSd )

							aItem 		:= {}
							aItemTmp := {{"DAI_FILIAL",FwXFilial("DAI")},;
										{"DAI_COD"   , cCodCarga},;
										{"DAI_SEQCAR", cCodSeq},;
										{"DAI_SEQUEN", StrZero(nSequen,6)},;
										{"DAI_PEDIDO", SC9->C9_PEDIDO},;
										{"DAI_CLIENT", SubStr(cCliLoja,TamSX3("DAI_FILIAL")[1]+1,tamSx3("DAI_CLIENT")[1])},;
										{"DAI_LOJA",   SubStr(cCliLoja,TamSX3("DAI_FILIAL")[1]+TamSX3("DAI_CLIENT")[1]+1)},;
										{"DAI_PESO"  , oDescarreg["weight"]},;
										{"DAI_CAPVOL", oDescarreg["volume"]},;
										{"DAI_PERCUR", "999999"},;
										{"DAI_ROTA",   "999999"},;  
										{"DAI_ROTEIR", "999999"},;
										{"DAI_DATA",   dDTItemChe},;                                
										{"DAI_HORA",   Time()},;
										{"DAI_CARORI", "CARGA"},;
										{"DAI_DTCHEG", dDTItemChe},;
										{"DAI_CHEGAD", cHRItemChe},;
										{"DAI_DTSAID", dDTItemSai},;
										{"DAI_TMSERV", cTimeSrv},;
										{"DAI_TIMEST", CValToChar(OMSTPRMili(cHRItemChe))}}
							If lDaiFilPv
								Aadd(aItemTmp, {"DAI_FILPV", FwXFilial("SC5")})
							EndIf

							Aadd(aItem, aItemTmp)
							Aadd(aItens, aItem) 

						EndIf
						Aadd(aItensSC9, {cChaveSC9, cCodCarga, cCodSeq, StrZero(nSequen,6) })
					Else 
						//Alterar o status desse registro para 4 falha de integração
						Aadd(aDoctosNOK,aPedido[nI])	
					EndIf
				Next nI
			Next nJ
		EndIf
	Next nX

	If !Empty(aDoctosNOK) //Tem negativos e não gerou itens DAI não gera carga
		omsTPRCarga:aObjItens  := {}
		omsTPRCarga:aItensSC9  := {}
		omsTPRCarga:aCpoCarga  := {}
		omsTPRCarga:aDoctosNOK := aDoctosNOK
	Else
		omsTPRCarga:cCodCarga := cCodCarga
		omsTPRCarga:aObjItens := aItens
		omsTPRCarga:aItensSC9 := aItensSC9
		omsTPRCarga:aDoctosOK := aDoctosOK
	EndIf

Return

/*/{Protheus.doc} TPRUTCData
** Grava Data e Hora
@author Equipe OMS
@since 25/08/2021
/*/
Function TPRUTCData(cUTC, lHVerao)
	Local aInfoData := {}
	Default lHVerao := .F.
	aInfoData := FwDateTimeToLocal(cUTC, IIF(lHVerao,1,0))
Return aInfoData


/*/{Protheus.doc} TPRvldSC9
** Funcao para as validacoes da SC9
@author Equipe OMS
@since 30/09/2021
/*/
Static Function TPRvldSC9(cChaveSC9, llogTPR)
	Local lRet := .T.

	If !Empty(SC9->C9_CARGA) .Or. !Empty(SC9->C9_SEQCAR) .Or. !Empty(SC9->C9_SEQENT)
		OMSTPRCLOG(llogTPR, "OMSATPR2", STR0003 + STR0018 + RTrim(cChaveSC9) +; //" A chave SC9 "" está com C9_CARGA: "" e C9_SEQENT: "
			STR0019 + SC9->C9_CARGA + " C9_SEQCAR: " + SC9->C9_SEQCAR + STR0020 + SC9->C9_SEQENT + STR0021)//". Portando a carga não será gerada por falha de estado da SC9 entre o envio e retorno."
		lRet := .F.
	EndIf

Return lRet


/*/{Protheus.doc} QueryPed
** Retorna os itens dos pedidos de venda que sera usado na montagem da carga
@author Equipe OMS
@since 25/08/2021
/*/
Static Function QueryPed(cFilRot,cIdRot,cIdped,llogTPR)
Local cAliasQry := ""
Local cQuery 	:= ""
Local aPedido 	:= {}


	cQuery := "SELECT DMS_CHVENT "
	cQuery +=       " FROM " + RetSqlName("DMS") +  " DMS "
	cQuery +=		" INNER JOIN " + RetSqlName("DMR") +  " DMR ON DMS.DMS_FILIAL  = DMR.DMR_FILIAL "
	cQuery +=		" AND DMS.DMS_FILROT  = DMR.DMR_FILROT" 
	cQuery +=       " AND DMR.DMR_IDROT = DMS.DMS_IDROT" 
 	cQuery +=		" AND DMS.D_E_L_E_T_ = ' '"
 	cQuery +=		" WHERE "
	cQuery +=       " DMR_FILIAL = '" +FwXFilial("DMR")+ "'"
 	cQuery +=		" AND DMR.D_E_L_E_T_ = ' '"
	cQuery +=		" AND DMR.DMR_FILROT = '"+cFilRot+"'"
	cQuery +=		" AND DMS.DMS_IDROT = '" +cIdRot+"'"
	cQuery +=		" AND SUBSTRING(DMS.DMS_CHVENT,1,"+cValtoChar(TamSX3('C9_FILIAL')[1]+TamSX3('C9_PEDIDO')[1])+") = '" +cIdped+ "'"

	cQuery      := ChangeQuery(cQuery)    

	OMSTPRCLOG(llogTPR, "OMSATPR2", STR0001 + STR0022 + cQuery )   //Query da roteirizacao

    cAliasQry   := GetNextAlias()
    dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
    While (cAliasQry)->(!Eof())
		Aadd(aPedido,(cAliasQry)->DMS_CHVENT)
		(cAliasQry)->(Dbskip())	
	EndDo
	(cAliasQry)->(DbCloseArea())
Return aPedido

/*/{Protheus.doc} AllMark
** Atualiza o Status das tabelas DMR e DMS após a geração da carga
@author Equipe OMS
@since 25/08/2021
/*/
Function OMSTPRADMS(cFilRot,cIdRot,aPedido,cCodCarga,nSeqRot,nRoutType,aMsgsRot)
Local nX := 0
Local lRet := .T.
Local cMsgGeral := ""

	If !Empty(aMsgsRot)
		For nX := 1 to Len(aMsgsRot)
			cMsgGeral += aMsgsRot[nX]
		Next nX
	EndIf

	DMR->(DbSetOrder(1))
	If DMR->(DbSeek(FwXFilial("DMR")+cFilROT+cIdRot))
		oModel := FWLoadModel( 'TMSAC19' )
		oModel:SetOperation( 4 )
		oModel:Activate()

		oMdFldDMR:= oModel:GetModel("MdFieldDMR")
		oMdGrdDMS:= oModel:GetModel("MdGridDMS")
		oMdFldDMR:LoadValue("DMR_STATUS","2")

		For nX := 1 to Len(aPedido)
			cCHVENT := aPedido[nX]// Array com as chaves da SC9
			oMdGrdDMS:SeekLine({{"DMS_IDROT",cIdRot},{"DMS_ENTIDA",'SC9'},{"DMS_CHVENT",cCHVENT}})
			oMdGrdDMS:LoadValue("DMS_STATUS","3")					
			oMdGrdDMS:LoadValue("DMS_SEQROT",nSeqRot)
			If nRoutType = 1
				oMdGrdDMS:LoadValue("DMS_MSGERR",STR0014 + cMsgGeral)//"Carga gerada com sucesso!"
				oMdGrdDMS:LoadValue("DMS_CHVEXT" ,FwXFilial("DAK") + cCodCarga)
				oMdGrdDMS:LoadValue("DMS_ENTEXT","DAK")
				oMdGrdDMS:LoadValue("DMS_INDEXT","1")
			ElseIf nRoutType = 2
				oMdGrdDMS:LoadValue("DMS_MSGERR",STR0015)	//"Sequenciamento realizado com sucesso!"
			EndIf
		Next nX
		
		lRet := oModel:VldData()
		If lRet 
			oModel:CommitData()
		EndIf
		oModel:Destroy()
		oModel:= Nil	
	EndIf
Return


/*/{Protheus.doc} TPRNOKDms
** Atualiza o Status da DMS após a geração da carga
@author Equipe OMS
@since 30/09/2021
/*/
Static Function TPRNOKDms(cFilRot,cIdRot,aDoctosOK,aDoctosNOK,cCodCarga)
Local nX := 0
Local lRet := .T.

	DMR->(DbSetOrder(1))
	If DMR->(DbSeek(FwXFilial("DMR")+cFilROT+cIdRot))
		oModel := FWLoadModel( 'TMSAC19' )
		oModel:SetOperation( 4 )
		oModel:Activate()

		oMdFldDMR:= oModel:GetModel("MdFieldDMR")
		oMdGrdDMS:= oModel:GetModel("MdGridDMS")
		oMdFldDMR:LoadValue("DMR_STATUS","2")

		If !Empty(aDoctosNOK)
			For nX := 1 to Len(aDoctosNOK)
				cCHVENT := aDoctosNOK[nX]// Array com as chaves da SC9
				oMdGrdDMS:SeekLine({{"DMS_IDROT",cIdRot},{"DMS_ENTIDA",'SC9'},{"DMS_CHVENT",cCHVENT}})
				oMdGrdDMS:LoadValue("DMS_STATUS","4")					
				oMdGrdDMS:LoadValue("DMS_MSGERR",STR0010)
				//"O item de pedido não estava disponível durante a geração da carga via integração. 
				//O pedido que é enviado para planejamento de rotas não pode ser modificado durante a integração (TPR)."
			Next nX
		EndIf

		If !Empty(aDoctosOK)
			For nX := 1 to Len(aDoctosOK)
				cCHVENT := aDoctosOK[nX]// Array com as chaves da SC9
				oMdGrdDMS:SeekLine({{"DMS_IDROT",cIdRot},{"DMS_ENTIDA",'SC9'},{"DMS_CHVENT",cCHVENT}})
				oMdGrdDMS:LoadValue("DMS_STATUS","4")					
				oMdGrdDMS:LoadValue("DMS_MSGERR",STR0011)//"O item de pedido faz parte de um pedido alterado durante a integração (TPR)."
			Next nX
		EndIf
		
		lRet := oModel:VldData()
		If lRet 
			oModel:CommitData()
		EndIf
		oModel:Destroy()
		oModel:= Nil	
	EndIf
Return



/*/{Protheus.doc} OMSATPRRej
** Atualiza o Status da DMS após a geração da carga
@author Equipe OMS
@since 30/09/2021
/*/
Function OMSATPRRej(oRejs, cFilrot, cIdRot,  aMsgsPed, aMsgs, llogTPR)
	Local nX		:= 0
	Local nI		:= 0
	Local nJ		:= 0
	Local oMsg 		:= Nil
	Local oRej 		:= Nil
	Local oOrder	:= Nil
	Local aItensPed := {}
	Local cMsgOrder := ""
	Local cCodeMsg 	:= ""
	Local cDescMsg 	:= ""

	If !Empty(oRejs)
		For nX := 1 to Len(oRejs)
			cMsgOrder := ""
			oRej   := oRejs[nX]
			oOrder := oRej["order"]

			For nJ := 1 to Len(oRej:GetJSonObject("messages"))
				oMsg := oRej:GetJSonObject("messages")[nJ]
				cCodeMsg := oMsg["messageCode"]
				cDescMsg := oMsg["message"]
				cMsgOrder +=  cCodeMsg + " - " + cDescMsg + " "
			Next nJ

			aItensPed := QueryPed(cFilRot, cIdRot, oOrder["identifier"],llogTPR)
			For nI := 1 To Len(aItensPed)
				Aadd(aMsgsPed, {aItensPed[nI], cMsgOrder})
			NEXT nI
		Next nX
	EndIf
Return .T.


/*/{Protheus.doc} OMSTPRRotM
** Obtem todas as mensagens gerais, mensagens na raiz do json
@author Equipe OMS
@since 23/05/2022
/*/
Function OMSTPRRotM(aMsgsViag, aMsgs)
	Local nX		:= 0
	Local oMsg 		:= Nil
	Local cCodeMsg 	:= ""
	Local cDescMsg 	:= ""

	If !Empty(aMsgsViag)
		For nX := 1 to Len(aMsgsViag)
			oMsg := aMsgsViag[nX]
			cCodeMsg := oMsg["messageCode"]
			cDescMsg := oMsg["message"]
			Aadd(aMsgs, cCodeMsg + " - " + cDescMsg + " ")
		Next nX
	EndIf

Return aMsgs


/*/{Protheus.doc} TPRREJDms
** Atualiza o Status da DMS de itens rejeitados :'(
@author Equipe OMS
@since 30/09/2021
/*/
Function TPRREJDms(cFilRot,cIdRot,aItensPed,aMsgs)
Local nX    := 0
Local lRet  := .T.
Local cMsgs := ""
Local cChvSC9 := ""
Local cMsgSC9 := ""

	//No momento vamos concatenar todas as msgs
	For nX := 1 to Len(aMsgs)
		cMsgs += aMsgs[nX]
	Next nX

	DMR->(DbSetOrder(1))
	If DMR->(DbSeek(FwXFilial("DMR")+cFilROT+cIdRot))
		oModel := FWLoadModel( 'TMSAC19' )
		oModel:SetOperation( 4 )
		oModel:Activate()

		oMdFldDMR:= oModel:GetModel("MdFieldDMR")
		oMdGrdDMS:= oModel:GetModel("MdGridDMS")
		oMdFldDMR:LoadValue("DMR_STATUS","2")

		If !Empty(aItensPed)
			For nX := 1 to Len(aItensPed)
				cChvSC9 := aItensPed[nX][1]
				cMsgSC9 := aItensPed[nX][2]
				oMdGrdDMS:SeekLine({{"DMS_IDROT",cIdRot},{"DMS_ENTIDA",'SC9'},{"DMS_CHVENT",cChvSC9}})
				oMdGrdDMS:LoadValue("DMS_STATUS", "2")	
				If !Empty(cMsgs)				
					oMdGrdDMS:LoadValue("DMS_MSGERR",cMsgs +" - "+ cMsgSC9)
				Else
					oMdGrdDMS:LoadValue("DMS_MSGERR",cMsgSC9)
				EndIf
			Next nX
		Else
			//Mensagens gerais no json apenas serao adicionadas e nao alterarao status
			For nX := 1 To oMdGrdDMS:Length()	
				oMdGrdDMS:Goline(nX)	
				oMdGrdDMS:LoadValue("DMS_MSGERR", oMdGrdDMS:GetValue("DMS_MSGERR") + cMsgs)
			Next nX
		EndIf
		
		lRet := oModel:VldData()
		If lRet 
			oModel:CommitData()
		EndIf
		oModel:Destroy()
		oModel:= Nil	
	EndIf
Return 


/*/{Protheus.doc} TPRDAIPed
** Indica se o pedido ja foi para a DAI
@author Equipe OMS
@since 28/10/2021
/*/
Static Function TPRDAIPed(aItens, cPedido)
	Local nX
	Local nPos := 0

	For nX := 1 To Len(aItens)

		nPos := AScan(aItens[nX][1], {|x| x[1] == 'DAI_PEDIDO' .And. AllTrim(cValToChar(x[2])) == cPedido})
		If nPos > 0
			exit
		EndIf
	Next nX

Return nPos

/*/{Protheus.doc} OMSTimeSrv
** Recebe duas datas e horas e retorna a diferenca entre elas
@author Equipe OMS
@since 28/10/2021
/*/
Function OMSTimeSrv( aUTCItemCh, aUTCItemSd )
	Local cTimeServ := "0000:00"
	Local nDias := 0
	Local cHoras := ""
	Local nHoras := 0
	Local nMinutos := 0
	Local aDiffHr := {}
	Local cHorasDia1
	Local cHorasDia2
	Local cMiliDia1
	Local cMiliDia2
	
	nDias := DateDiffDay(aUTCItemCh[1],aUTCItemSd[1])
	If nDias = 0
		cHoras := ELAPTIME(  aUTCItemCh[2], aUTCItemSd[2] )
		aDiffHr := StrTokArr( cHoras, ":" )
		nHoras := Val(aDiffHr[1])
		nMinutos := Val(aDiffHr[2])
	Else
		nHoras := (nDias-1) * 24
		cHorasDia1 := ELAPTIME(  aUTCItemCh[2], "23:59:59")
		cHorasDia2 := aUTCItemSd[2] 
		cMiliDia1 := OMSTPRMili(cHorasDia1)
		cMiliDia2 := OMSTPRMili(cHorasDia2)
		cMiliDia1 := cMiliDia1 + cMiliDia2
		cHoras := OMSMiliseg(cMiliDia1, 0)
		aDiffHr := StrTokArr( cHoras, ":" )
		nHoras += Val(aDiffHr[1])
		nMinutos := Val(aDiffHr[2])
	EndIf
	cTimeServ := StrZero( nHoras, 4) + ":" + StrZero( nMinutos, 2)
Return cTimeServ

