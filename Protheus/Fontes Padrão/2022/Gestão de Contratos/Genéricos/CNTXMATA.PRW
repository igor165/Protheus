/*******************************************************************************************************************************
* CNTXMATA.PRX
* Arquivo fonte contendo funções integradas nos fontes MATAXXX para funcionalidades de contratos.
*******************************************************************************************************************************/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "GCTXDEF.CH"
#INCLUDE "FWMVCDEF.CH"

//==============================================================================================================================
/*/{Protheus.doc} CnA097Apr()
Função responsável realizar a integração entre a aprovação de documentos MATA097 e a alteração de situação do contrato CNTA100
@param		cScrNum			Numero da SCR aprovada	(SCR->CR_NUM)
			cScrTip			Tipo da SCR aprovada	(SCR->CR_TIPO)
  					
@author		Israel.Escorizza
@since		16/02/2018
@version	P12.1.20
/*/
//==============================================================================================================================
Function CnA097Apr(cScrNum,cScrTip,oModel)
Local aArea		:= GetArea() 
Local aSaveLine	:= FWSaveRows()
Local lRet		:= .T.

Default cScrNum	:= ""
Default cScrTip	:= ""
Default oModel	:= Nil

If ( !Empty(cScrNum) .And. !Empty(cScrTip) )
	DO	CASE 
		CASE cScrTip $ "CT|IC"
			 dbSelectArea("CN9")
			 CN9->(dbSetOrder(1))
			 
			 If CN9->(MsSeek( xFilial("CN9") + Left( SCR->CR_NUM , TAMSX3('CN9_NUMERO')[1] ) ) )
			 	CN100SitCh(CN9->CN9_NUMERO,CN9->CN9_REVISA,DEF_SVIGE,,.F.)
			 EndIf		 
			
		CASE cScrTip $ "RV|IR" .And. oModel != Nil
			 //-- Inicializa lançamento do PCO
			 PcoIniLan("000354")
			 PcoIniLan("000357")
			
			//- Verifica qual tipo de revisão está sendo aprovada.
			If A300GATpRv() ==  "5" //DEF_REV_PARAL - Paralisação
				oModel:LoadValue('CN9MASTER','CN9_SITUAC',DEF_SPARA) //DEF_SPARA - Paralisado
			Else
				oModel:LoadValue('CN9MASTER','CN9_SITUAC',DEF_SVIGE) //DEF_SVIGE - Vigente
			EndIf

			If oModel:VldData()
				CnPimsChgS(oModel,oModel:CommitData())
			Else
				Ret := .F.		
			EndIf
			oModel:DeActivate()

			//-- Finaliza lancamentos do PCO
			PcoFinLan("000357")
			PcoFreeBlq("000357")

			PcoFinLan("000354")
			PcoFreeBlq("000354")
		
		CASE cScrTip $ "MD|IM"
			dbSelectArea("CND")
				dbSetOrder(4)
				If CND->(dbSeek(xFilial("CND")+Left(SCR->CR_NUM,Len(CND->CND_NUMMED))))
					Reclock("CND",.F.)
					CND->CND_ALCAPR := "L"
					CND->CND_SITUAC := "A"
					MsUnlock()
					If ExistBlock("MT097APR")
						ExecBlock("MT097APR",.F.,.F.)
					EndIf
			EndIf
	END DO	

EndIf

FWRestRows( aSaveLine )     
RestArea(aArea)
Return lRet

/*/{Protheus.doc} GCTPVCpos
	Retorna os campos que devem ser liberados para pedidos de venda oriundos do SIGAGCT
@author philipe.pompeu
@since 19/05/2021
@return aPedCpo, vetor, contêm os campos que devem ser liberados para edição nos pedidos
/*/
Function GCTPVCpos()
	Local aPedCpo	:= {}
	Local aTabCpos	:= {}
	Local nX		:= 0	
	
	//Adiciona campos padrão
	If cPaisLoc != 'RUS'
		aPedCpo := {{"C5_MENNOTA","C5_TRANSP", "C5_MENPAD", "C5_NATUREZ", "C5_ESTPRES", "C5_MUNPRES","C5_RECISS","C5_CONDPAG","C5_PARC1","C5_DATA1",'C5_INCISS','C5_NFSUBST','C5_SERSUBS'},;
					{"C6_TES","C6_ABATINS","C6_QTDLIB",'C6_CODISS'}}
		If FindFunction("LxActCpos") .And. cPaisLoc $ "COL|MEX|PER|EUA|EQU"	
			LxActCpos(@aPedCpo)
		EndIf

		If (SC5->(ColumnPos('C5_INDPRES') > 0  .And. ColumnPos('C5_CODA1U') > 0)) //Adiciona campos da NT2020.006
			aAdd(aPedCpo[1], 'C5_INDPRES')
			aAdd(aPedCpo[1], 'C5_CODA1U')
		EndIf		
	Else
		aPedCpo := {{"C5_MENNOTA","C5_TRANSP", "C5_MENPAD", "C5_NATUREZ", "C5_ESTPRES", "C5_MUNPRES","C5_RECISS","C5_CONDPAG","C5_PARC1","C5_DATA1","C5_CNORCOD","C5_CNORBR","C5_CNEECLI","C5_CNEECOD","C5_CNEEBR","C5_CNORVEN"},{"C6_TES","C6_ABATINS","C6_QTDLIB","C6_FDESC"}}
	EndIf	

	aTabCpos := FWSX3Util():GetAllFields("SC5")
	for nX := 1 to Len(aTabCpos)
		If (FWSX3Util():GetOwner(aTabCpos[nX]) == "U")			
			aAdd(aPedCpo[1], aTabCpos[nX])//Adiciona campos do usuário do cabeçalho(SC5)
		EndIf		
	next nX
	aSize(aTabCpos, 0)
	
	aTabCpos := FWSX3Util():GetAllFields("SC6")
	for nX := 1 to Len(aTabCpos)
		If (FWSX3Util():GetOwner(aTabCpos[nX]) == "U")			
			aAdd(aPedCpo[2], aTabCpos[nX]) //Adiciona campos do usuário do item(SC6)
		EndIf		
	next nX	
	FwFreeArray(aTabCpos)

Return aPedCpo

/*/{Protheus.doc} GCTPVGrvMD
	Grava uma mediçao oriunda de um Pedido de Venda, nesse processo o PV precede a medição(MV_CNPEDVE=.T.)
@author philipe.pompeu
@since 07/04/2022
@param aCab, vetor, cabeçalho da medicao(CND)
@param aItens, vetor, itens da medicao(CNE)
@return lResult, lógico, se o processamento ocorreu com sucesso
/*/
Function GCTPVGrvMD(aCab as Array, aItens as Array) as Logical
	Local lResult 	:= .T.	
	Local oCabCND	:= Nil
	Local aItensCNE := {}
	Local cChave	:= ""
	Local aCompets	:= {}
	Local nCompet	:= 0
	
	If CN120IsAct()//Se o CNTA120 está ativo
		
		MsExecAuto({|a,b,c|,CNTA120(a,b,c)},aCab,aItens,3)//-- Gera a medicao		
		If !lMsErroAuto
			MsExecAuto({|a,b,c|,CNTA120(a,b,c)},aCab,aItens,6)//-- Encerra a medicao
		EndIf

		lResult := !lMsErroAuto
	Else
		If (lResult := VldPVGrvMD(aCab, aItens)) //Valida dados em <aCab> e <aItens>
			
			oCabCND	:= ArrToJsObj(aCab)
			
			aEval(aItens, {|x| aAdd(aItensCNE, ArrToJsObj(x) ) })

			cChave := xFilial("CN9", oCabCND["CND_FILCTR"] ) + oCabCND["CND_CONTRA"] + oCabCND["CND_REVISA"]

			CN9->(DbSetOrder(1))
			If (lResult := CN9->(DbSeek(cChave)))
				aCompets := CtrCompets()
				
				oCabCND["CND_RCCOMP"] := "1"
				If ((nCompet := aScan(aCompets, {|x| AllTrim(x) == oCabCND["CND_COMPET"] })) > 0)					
					oCabCND["CND_RCCOMP"] := cValToChar(nCompet)
				EndIf

				FwFreeArray(aCompets)

				If (lResult := IncPvGrvMD(oCabCND, aItensCNE))//Inclui a medicao
					lResult := EncPvGrvMD(oCabCND)//Encerra medicao
				EndIf
			EndIf

			FreeObj(oCabCND)
			aEval(aItensCNE, {|x| FreeObj(x) })
		EndIf
	EndIf
Return lResult

/*/{Protheus.doc} VldPVGrvMD
	Verifica se as estruturas de <aCab> e <aItens> são válidas 
@author philipe.pompeu
@since 07/04/2022
@param aCab, vetor, cabeçalho da medicao(CND)
@param aItens, vetor, itens da medicao(CNE)
@return lValido, lógico, se os dados são válidos
/*/
Static Function VldPVGrvMD(aCab as Array, aItens as Array) as Logical
	Local aObrgCpos := {}
	Local lValido 	:= .T.
	Local nY := 0		
	
	aObrgCpos := {"CND_FILCTR" , "CND_CONTRA", "CND_REVISA", "CND_COMPET", "NUMPED", "CND_NUMERO", "CND_NUMMED"}	

	If (lValido := VldFldPos(aObrgCpos, aCab))
		aObrgCpos := {"CNE_PRODUT", "CNE_QUANT", "CNE_TS", "CNE_DTENT", "CNE_ITEM"}

		for nY := 1 to Len(aItens)	

			if !(lValido := VldFldPos(aObrgCpos, aItens[nY]))		
				Exit
			endif
		next nY
	Endif

	FwFreeArray(aObrgCpos)
Return lValido

/*/{Protheus.doc} VldFldPos
	Confere se <aObrgCpos> foram informados em <aRegistro>
@author philipe.pompeu
@since 07/04/2022
@param aObrgCpos, vetor, canpos obrigatórios
@param aRegistro, vetor, registro à ser verificado
@return lValido, lógico, se <aRegistro> contêm todos os campos obrigatórios informados
/*/
Static Function VldFldPos(aObrgCpos as Array, aRegistro as Array) as Logical
	Local lValido 	:= .T.
	Local nX		:= 0
	Local nIndex	:= 0
	Local cCampo	:= ""

	for nX := 1 to Len(aObrgCpos) 
		cCampo := aObrgCpos[nX]			
		nIndex := aScan(aRegistro, {|x| AllTrim(x[1]) == cCampo })			
		if !(lValido := (nIndex > 0))				
			Exit
		endif
	next nX	
Return lValido

/*/{Protheus.doc} ArrToJsObj
	Converte <aRegistro> para um JsonObject, <aRegistro> deve seguir o formato de aCols(cada linha contêm campo e valor)
@author philipe.pompeu
@since 07/04/2022
@param aRegistro, vetor, registro à ser convertido
@return oJsObj, objeto, instância de JsonObject
/*/
Static Function ArrToJsObj(aRegistro)
	Local oJsObj := JsonObject():New()
	Local nX := 0
	Local cCampo := ""

	for nX := 1 to Len(aRegistro)
		cCampo 			:= aRegistro[nX,1]
		oJsObj[cCampo]	:= aRegistro[nX,2]
	next nX

Return oJsObj

/*/{Protheus.doc} IncPvGrvMD
	Inclui uma medição oriunda de um pedido de venda, ou seja, o PV precede a inclusão da medição
@author philipe.pompeu
@since 07/04/2022
@param oCabCND, objeto, instância de JsonObject contendo dados da CND
@param aItens, vetor, lista de instâncias de JsonObject contendo dados da CNE
@return lResult, lógico, se a operação ocorreu com sucesso
/*/
Static Function IncPvGrvMD(oCabCND, aItens)
	Local lResult := .T.
	Local aAllProps	:= {}
	Local oModel	:= Nil
	Local oModelCND	:= Nil
	Local oModelCXN	:= Nil
	Local oModelCXJ	:= Nil
	Local oModelCNE	:= Nil
	Local cNumPed	:= ""
	Local nLinha	:= 0
	Local nX		:= 0
	Local cCampo	:= ""
	Local oItemCNE 	:= Nil
	Local cCpoIgnore:= "CND_FILCTR|CND_CONTRA|CND_NUMERO|CND_COMPET|CND_CLIENT|CND_LOJACL|CND_PARCEL|CND_RCCOMP|"
	Local lIsMedSrv	:= .F.

	oModel := FwLoadModel("CNTA121")
	oModel:SetOperation(MODEL_OPERATION_INSERT)

	If (lResult := oModel:Activate())
		oModelCND := oModel:GetModel("CNDMASTER")
		oModelCND:LoadValue("CND_FILCTR", oCabCND["CND_FILCTR"])
		oModelCND:LoadValue("CND_NUMMED", oCabCND["CND_NUMMED"])
		oModelCND:SetValue("CND_CONTRA"	, oCabCND["CND_CONTRA"])
		oModelCND:SetValue("CND_COMPET"	, oCabCND["CND_COMPET"])
		oModelCND:SetValue("CND_RCCOMP"	, oCabCND["CND_RCCOMP"])
		cNumPed := oCabCND["NUMPED"]

		aAllProps := oCabCND:GetNames()
		lIsMedSrv := (CnTpProd("CNTA121", oCabCND["CND_NUMERO"], oCabCND["CND_CONTRA"], oCabCND["CND_REVISA"]) == 2)
		If lIsMedSrv
			CN121MdServ(.T., .T.) //Ativa medicao de servico
		EndIf

		for nX := 1 to Len(aAllProps)
			cCampo := AllTrim(aAllProps[nX])
			If !(cCampo $ cCpoIgnore)								
				If oModelCND:HasField(cCampo)
					oModelCND:LoadValue(cCampo, oCabCND[cCampo])								
				EndIf
			EndIf
		next nX

		oModelCXN 	:= oModel:GetModel("CXNDETAIL")
		nLinha 		:= MTFindMVC(oModelCXN,{{"CXN_NUMPLA", oCabCND["CND_NUMERO"] }})

		If (lResult := nLinha > 0)
			oModelCXN:GoLine(nLinha)
			oModelCXN:SetValue("CXN_CHECK", .T.)
			oModelCNE := oModel:GetModel("CNEDETAIL")
			oModelCXJ := oModel:GetModel("CXJDETAIL")

			for nX := 1 to Len(aItens)
				oItemCNE:= aItens[nX]				
				nLinha 	:= MTFindMVC(oModelCNE,{{"CNE_ITEM", oItemCNE["CNE_ITEM"] }})
				If nLinha == 0
					If !Empty(oModelCNE:GetValue("CNE_PRODUT"))
						oModelCNE:AddLine()
					EndIf
					nLinha := oModelCNE:GetLine()
				EndIf				
				oModelCNE:GoLine(nLinha)
				
				oModelCNE:LoadValue("CNE_PRODUT", oItemCNE["CNE_PRODUT"])
				oModelCNE:LoadValue("CNE_DTENT"	, oItemCNE["CNE_DTENT"])
				oModelCNE:LoadValue("CNE_PEDIDO", cNumPed)
				oModelCNE:SetValue("CNE_QUANT"	, oItemCNE["CNE_QUANT"])
				oModelCNE:SetValue("CNE_TES"	, oItemCNE["CNE_TS"])

				nLinha 	:= MTFindMVC(oModelCXJ,{{"CXJ_ITEMPL", oModelCNE:GetValue("CNE_ITEM") }})
				If nLinha == 0
					If !Empty(oModelCXJ:GetValue("CXJ_NUMPED"))
						oModelCXJ:AddLine()
					EndIf
					nLinha := oModelCXJ:GetLine()
				EndIF
				
				oModelCXJ:GoLine(nLinha)/*Gera a tabela CXJ(Amarração Doc x Medicao), dessa forma ao encerrar o item não será reprocessado*/
				oModelCXJ:SetValue("CXJ_NUMPED", cNumPed)
				oModelCXJ:SetValue("CXJ_ITEMPE", oModelCNE:GetValue("CNE_ITEM"))
				oModelCXJ:SetValue("CXJ_ITEMPL", oModelCNE:GetValue("CNE_ITEM"))
			next nX
		EndIf

		If lResult
			lResult := (oModel:VldData() .And. oModel:CommitData())
		EndIf
		
		If oModel:IsActive()
			oModel:DeActivate()
		EndIf

		If lIsMedSrv
			CN121MdServ(.T., .F.)			
		EndIf
	EndIf
Return lResult

/*/{Protheus.doc} EncPvGrvMD
	Encerra uma medição oriunda de um pedido de venda
@author philipe.pompeu
@since 07/04/2022
@param oCabCND, objeto, instância de JsonObject contendo dados da CND
@return lResult, lógico, se a operação ocorreu com sucesso
/*/
Static Function EncPvGrvMD(oCabCND) as Logical
	Local lResult	:= .T.
	Local cChave	:= ""
	
	CND->(DbSetOrder(7))//CND_FILIAL+CND_CONTRA+CND_REVISA+CND_NUMMED
	cChave := xFilial("CND") + oCabCND["CND_CONTRA"] + oCabCND["CND_REVISA"] + oCabCND["CND_NUMMED"]
	If CND->(DbSeek(cChave))
		CN121Encerr(.T.)//Realiza o encerramento da medição

		lResult := (CND->(AllTrim(CND_SITUAC) == "E"))
	EndIf
	
Return lResult
