#Include "PROTHEUS.CH"
#Include "FWADAPTEREAI.CH"
#Include "FWMVCDEF.CH"
#Include "MATI035.CH"
#INCLUDE 'TURXEAI.CH'
#INCLUDE 'TURIDEF.CH'


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATI035O   ºAutor  ³Totvs Cascavel     º Data ³  23/04/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de integracao com o adapter EAI para recebimento e  º±±
±±º          ³ envio de informações do cadastro de grupo de produtos (SBM)º±±
±±º          ³ utilizando o conceito de mensagem unica JSON.              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATI035O                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function MATI035Json( oEAIObEt, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj )
Local lRet       := .T.
Local cEvento    := 'upsert'
Local cAdapter   := 'MATA035'
Local cMsgUnica  := 'FAMILY'
Local cMarca     := 'PROTHEUS'
Local cAlias     := 'SBM'
Local cCampo     := 'BM_GRUPO'
Local oModel     := NIL
Local oModelCab  := NIL
Local oModelDet  := NIL
Local aRet       := {}
Local aDetalhe   := {}
Local nX,nCont,nY:= 0
Local nLine      := 0
Local lDelete
Local aIntID	 := {}
Local cModelDef	 := ""
Local nOldModulo := nModulo
Local cItemCod   := ''
Local cFamily    := ''

//Variaveis da Base Interna
Local cIntID     := ''
Local cCodeInt   := ''

//Variaveis da Base Externa
Local cExtID	:= ''
Local cCodeExt	:= ''
Local cFopCode	:= ''
Local aStruct	:= {}
Local aGrupo	:= {}

//Instancia objeto JSON
Local ofwEAIObj	:= FWEAIobj():NEW()
Local oModel 	:= Nil 	

Default oEAIObEt		:= Nil
Default nTypeTrans		:= "3"
Default cTypeMessage	:= ""
Default cVersion		:= ""
Default cTransac		:= ""
Default lEAIObj			:= .F.

Do Case
	//--------------------------------------
	//envio mensagem
	//--------------------------------------
	Case nTypeTrans == TRANS_SEND
	
		oModel		:= FwModelActive()
		cModelDef	:= oModel:aModelStruct[1][2]
		aStruct		:= oModel:GetModel(cModelDef):GetStruct():aFields
		
		If lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE
			cEvento := 'delete'
		EndIf
		
		cCodeInt := oModel:GetValue(cModelDef, 'BM_GRUPO')
		cIntID	 := IntFamExt(,,cCodeInt)[2] //TURXMakeId(cCodeInt, 'SBM')
		
		ofwEAIObj:Activate()
	
		ofwEAIObj:setEvent(cEvento)
		
		ofwEAIObj:setprop("CompanyId",cEmpAnt)
		ofwEAIObj:setprop("BranchId",cFilAnt)
		ofwEAIObj:setprop("CompanyInternalId",cEmpAnt + '|' + cFilAnt)
		ofwEAIObj:setprop("Code",cCodeInt)
		ofwEAIObj:setprop("InternalId",cIntID)
		
		IF TxValCpo(aStruct,'BM_DESC') .AND. !Empty(oModel:GetValue(cModelDef, 'BM_DESC'))
			ofwEAIObj:setprop("Description",AllTrim(oModel:GetValue(cModelDef, 'BM_DESC')))
		Endif
		
		IF TxValCpo(aStruct,'BM_TIPGRU') .AND. !Empty(oModel:GetValue(cModelDef, 'BM_TIPGRU'))
			ofwEAIObj:setprop("FamilyType",AllTrim(oModel:GetValue(cModelDef, 'BM_TIPGRU')))
		Endif
		
		IF TxValCpo(aStruct,'BM_CLASGRU') .AND. !Empty(oModel:GetValue(cModelDef, 'BM_CLASGRU'))
			ofwEAIObj:setprop("FamilyClassificationCode",AllTrim(oModel:GetValue(cModelDef, 'BM_CLASGRU')))
		Endif
		
		IF TxValCpo(aStruct,'BM_CODGRT') .AND. !Empty(oModel:GetValue(cModelDef, 'BM_CODGRT'))
			ofwEAIObj:setprop("TourismType",AllTrim(oModel:GetValue(cModelDef, 'BM_CODGRT')))
		Endif
		
		IF TxValCpo(aStruct,'BM_CONC') .AND. !Empty(oModel:GetValue(cModelDef, 'BM_CONC'))
			ofwEAIObj:setprop("Conciliation",AllTrim(oModel:GetValue(cModelDef, 'BM_CONC')))
		Endif
		
		IF TxValCpo(aStruct,'BM_TPSEGP') .AND. !Empty(oModel:GetValue(cModelDef, 'BM_TPSEGP'))
			ofwEAIObj:setprop("SegmentType",AllTrim(oModel:GetValue(cModelDef, 'BM_TPSEGP')))
		Endif
		
		IF TxValCpo(aStruct,'BM_CORP') .AND. !Empty(oModel:GetValue(cModelDef, 'BM_CORP'))
			ofwEAIObj:setprop("Corporate",AllTrim(oModel:GetValue(cModelDef, 'BM_CORP')))
		Endif
		
		IF TxValCpo(aStruct,'BM_EVENTO') .AND. !Empty(oModel:GetValue(cModelDef, 'BM_EVENTO'))
			ofwEAIObj:setprop("Event",AllTrim(oModel:GetValue(cModelDef, 'BM_EVENTO')))
		Endif
		
		IF TxValCpo(aStruct,'BM_LAZER') .AND. !Empty(oModel:GetValue(cModelDef, 'BM_LAZER'))
			ofwEAIObj:setprop("Recreation",AllTrim(oModel:GetValue(cModelDef, 'BM_LAZER')))
		Endif
		
		IF TxValCpo(aStruct,'BM_MSBLQL') .AND. !Empty(oModel:GetValue(cModelDef, 'BM_MSBLQL'))
			ofwEAIObj:setprop("Situation",IIf(AllTrim(oModel:GetValue(cModelDef, 'BM_MSBLQL'))=='1','2','1'))
		Endif
		
		If lDelete //Exclui o De/Para
			CFGA070MNT(NIL, cAlias, cCampo, , cIntID, lDelete)
		Endif	
		
		oModelDet := oModel:GetModel('G3KDETAIL')
		If ValType(oModelDet) == 'O' .and. oModelDet:Length(.t.) > 0
			
			For nX := 1 to oModelDet:Length()
				oModelDet:goline(nX)
				
				cItemCod := oModel:GetValue('G3KDETAIL', 'G3K_CODFOP')
				cDest    := oModel:GetValue('G3KDETAIL', 'G3K_DEST')
				cPerson  := oModel:GetValue('G3KDETAIL', 'G3K_PESSOA')
				cIntID   := TURXMakeId(cItemCod, 'G3N')
				
				//Se Alteração/Inclusão e a linha estiver apagado, não manda Family -- Se for Exclusão manda a linha para controle
				
				If (!oModelDet:IsDeleted() .Or. lDelete ).and. !Empty(cItemCod)

					ofwEAIObj:getPropValue("ListOfPaymentForm"):setProp("PaymentForm",{})
					
					ofwEAIObj:getPropValue("ListOfPaymentForm"):getPropValue("PaymentForm")[nI]:setProp("PaymentFormCode", cItemCod	)
					ofwEAIObj:getPropValue("ListOfPaymentForm"):getPropValue("PaymentForm")[nI]:setProp("PaymentFormInternalId", cIntID	)
					ofwEAIObj:getPropValue("ListOfPaymentForm"):getPropValue("PaymentForm")[nI]:setProp("Destination", cDest	)
					ofwEAIObj:getPropValue("ListOfPaymentForm"):getPropValue("PaymentForm")[nI]:setProp("Person", cPerson	)
					
				Endif
			Next
		Endif
		
	//--------------------------------------
	//recebimento mensagem
	//--------------------------------------
	Case nTypeTrans == TRANS_RECEIVE .And. ValType( oEAIObEt ) == 'O'
		Do Case
			//--------------------------------------
			//whois
			//--------------------------------------
			Case (cTypeMessage == EAI_MESSAGE_WHOIS)
				Return {.T., '2.002', cMsgUnica}
				
			//--------------------------------------
			//resposta da mensagem Unica TOTVS
			//--------------------------------------	
			Case (cTypeMessage == EAI_MESSAGE_RESPONSE)
			
				If oEAIObEt:getHeaderValue("Transaction") !=  nil
					cName := oEAIObEt:getHeaderValue("Transaction")
				Endif
				
				If oEAIObEt:getHeaderValue("ProductName") !=  nil
					cMarca := oEAIObEt:getHeaderValue("ProductName")
				Endif
				
				If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin") != nil
					cIntID := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin")
				Endif

				If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Destination") != nil
					cExtID := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Destination")
				Endif
				
				If !Empty(cIntID) .And. !Empty(cExtID)
					If Upper(Alltrim(cName)) == Alltrim(cMsgUnica)
						CFGA070MNT(cMarca, cAlias, cCampo, cExtID, cIntID)
					Endif
				Endif
				

			//--------------------------------------
			//chegada de mensagem de negocios
			//--------------------------------------
			Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
				
				If oEAIObEt:getHeaderValue("Transaction") != nil
					cName := oEAIObEt:getHeaderValue("Transaction")
				Endif
				
				If oEAIObEt:getHeaderValue("ProductName") != nil
					cMarca := oEAIObEt:getHeaderValue("ProductName")
				Endif
				
				If oEAIObEt:getPropValue("InternalId") != nil
					cExtID := oEAIObEt:getPropValue("InternalId")
				EndIf
				
				If oEAIObEt:getPropValue("Code") != nil
					cCodeExt := oEAIObEt:getPropValue("Code")
				EndIf
				
				//---------------------------------------------------------------------------------------------
				// Procura a Marca, Alias, Codigo na Tabela XXF de De/Para para ver se Existe o Codigo
				// apenas verifica se existe o Registro no XXF para saber se e Inclusao, Alteracao ou Exclusao
				//---------------------------------------------------------------------------------------------
				If (aGrupo := IntFamInt(cExtID, cMarca))[1]
					cCodeInt := PadR(aGrupo[2,3], TamSx3('BM_GRUPO')[1])
				Endif
				
				cEvent := AllTrim(oEAIObEt:getEvent())
				
				If Upper(cEvent) == 'UPSERT' .Or. Upper(cEvent) == 'REQUEST'
					If !Empty(cCodeInt) .And. SBM->(DbSeek(xFilial('SBM') + cCodeInt))
						cEvent   := MODEL_OPERATION_UPDATE
					Else
						cEvent   := MODEL_OPERATION_INSERT
						cCodeInt := cCodeExt
					Endif
					
				ElseIf Upper(cEvent) == 'DELETE'
					If !Empty(cCodeInt) .And. SBM->(DbSeek(xFilial('SBM') + cCodeInt))
						cEvent  := MODEL_OPERATION_DELETE
						lDelete := .T.
					Else
						lRet    := .F.
						ofwEAIObj := STR0001 //'Registro não encontrado no Protheus.'
					Endif
				EndIf
				
				If lRet
					If oEAIObEt:getPropValue("TourismType") != nil 
						nModulo := 89 //Garante que o Model Carregado seja do modulo de Turismo
						cModelDef := "SBMMASTER"
					Else
						nModulo := 05
						cModelDef := "MATA035_SBM"
					Endif
					oModel	:= FwLoadModel(cAdapter)
					
					aStruct := oModel:GetModel(cModelDef):GetStruct():aFields
					
					oModel:SetOperation(cEvent)
					If oModel:Activate()
						oModelCab	:= oModel:GetModel(cModelDef)
						oModelDet	:= oModel:GetModel('G3KDETAIL')
						
						If cEvent <> MODEL_OPERATION_DELETE
							If cEvent == MODEL_OPERATION_INSERT
								oModelCab:SetValue('BM_GRUPO', cCodeInt)
							Endif
							
							If TxValCpo(aStruct,'BM_DESC') .And. oEAIObEt:getPropValue("Description") != nil
								oModelCab:SetValue('BM_DESC', oEAIObEt:getPropValue("Description"))
							Endif
							If TxValCpo(aStruct,'BM_TIPGRU') .And. oEAIObEt:getPropValue("FamilyType") != nil
								oModelCab:SetValue('BM_TIPGRU', oEAIObEt:getPropValue("FamilyType"))
							Endif
							IF TxValCpo(aStruct,'BM_CLASGRU') .And. oEAIObEt:getPropValue("FamilyClassificationCode") != nil
								oModelCab:SetValue('BM_CLASGRU', oEAIObEt:getPropValue("FamilyClassificationCode"))
							Endif
							IF TxValCpo(aStruct,'BM_CODGRT') .And. oEAIObEt:getPropValue("TourismType") != nil 
								oModelCab:SetValue('BM_CODGRT', oEAIObEt:getPropValue("TourismType"))
							Endif
							If TxValCpo(aStruct,'BM_CONC') .And. oEAIObEt:getPropValue("Conciliation") != nil
								oModelCab:SetValue('BM_CONC', oEAIObEt:getPropValue("Conciliation"))
							Endif
							If TxValCpo(aStruct,'BM_TPSEGP') .And. oEAIObEt:getPropValue("SegmentType") != nil
								oModelCab:SetValue('BM_TPSEGP', oEAIObEt:getPropValue("SegmentType"))
							Endif
							If TxValCpo(aStruct,'BM_CORP' ) .And. oEAIObEt:getPropValue("Corporate") != nil
								oModelCab:SetValue('BM_CORP', oEAIObEt:getPropValue("Corporate"))
							Endif
							If TxValCpo(aStruct,'BM_EVENTO') .And. oEAIObEt:getPropValue("Event") != nil
								oModelCab:SetValue('BM_EVENTO', oEAIObEt:getPropValue("Event"))
							Endif
							If TxValCpo(aStruct,'BM_LAZER') .And. oEAIObEt:getPropValue("Recreation") != nil
								oModelCab:SetValue('BM_LAZER', oEAIObEt:getPropValue("Recreation"))
							Endif
							If TxValCpo(aStruct,'BM_MSBLQL') .And. oEAIObEt:getPropValue("Situation") != nil
								oModelCab:SetValue('BM_MSBLQL', IIf(AllTrim(oEAIObEt:getPropValue("Situation"))=='1','2','1'))
							Endif
						Endif
						cIntID := IntFamExt(,,cCodeInt)[2]
						aAdd(aIntID,{cMsgUnica,cExtID,cIntID,cAlias,cCampo})
					Else
						lRet := .F.
					Endif
					
					If oEAIObEt:getPropValue("ListOfPaymentForm") != nil
						If (nCont := oEAIObEt:getPropValue("ListOfPaymentForm"):getPropValue("PaymentForm") ) > 0
							For nX := 1 To nCont
								If lRet
									cFopCode 	:= ofwEAIObj:getPropValue("ListOfPaymentForm"):getPropValue("PaymentForm")[nX]:getPropValue("PaymentFormCode")
									cExtIdDet 	:= ofwEAIObj:getPropValue("ListOfPaymentForm"):getPropValue("PaymentForm")[nX]:getPropValue("PaymentFormInternalId")
									cDest 		:= ofwEAIObj:getPropValue("ListOfPaymentForm"):getPropValue("PaymentForm")[nX]:getPropValue("Destination")
									cPerson 	:= ofwEAIObj:getPropValue("ListOfPaymentForm"):getPropValue("PaymentForm")[nX]:getPropValue("Person")									
									cIntID  	:= ''
									cItemCod  	:= PadR(AllTrim(TURXRetId(cMarca, 'G3N', 'G3N_CODIGO', cExtIdDet, NIL, 3)), TamSx3('G3K_CODFOP')[1])

									If cEvent <> MODEL_OPERATION_DELETE
										// caso seja inserção e não tem DE/PARA da G8R
										// recuperar o código da FORMA DE PAGTO através do DE/PARA da G3N
										If !oModelDet:SeekLine({{'G3K_CODFOP', cItemCod},{'G3K_DEST'  , cDest},{'G3K_PESSOA', cPerson}})
											If !Empty(oModelDet:GetValue( 'G3K_CODFOP'))
												nLine := oModelDet:AddLine()
												oModelDet:GoLine(nLine)
											EndIf
											oModelDet:SetValue('G3K_CODFOP', cItemCod)
										EndIf
										oModelDet:SetValue('G3K_DEST'  , cDest)
										oModelDet:SetValue('G3K_PESSOA', cPerson)
									Endif
									
									If 	!oModelDet:VldLineData()
										lRet := .F.
									Else
										aAdd(aDetalhe, cItemCod+cDest+cPerson)
									EndIf
								Endif
							Next nX
						Endif
						If lRet
							For nX := 1 To oModelDet:Length()
								oModelDet:GoLine(nX)
								If !lDelete .And. aScan(aDetalhe, oModelDet:GetValue('G3K_CODFOP') +oModelDet:GetValue('G3K_DEST') + oModelDet:GetValue('G3K_PESSOA')) == 0
									oModelDet:DeleteLine()
								Endif
							Next
						EndIf	
					Endif
					
					If lRet .And. oModel:VldData() .And. oModel:CommitData() 
						// Monta o JSON de retorno
						ofwEAIObj:Activate()
															
						ofwEAIObj:setProp("ReturnContent")
					
						For nY := 1 To Len(aIntID)
							ofwEAIObj:getPropValue("ReturnContent"):setProp("ListOfInternalID",{},'InternalId',,.T.)
							ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Name",aIntID[nY][1],,.T.)
							ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Origin",aIntID[nY][2],,.T.)
							ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Destination",aIntID[nY][3],,.T.)				
							
							//CFGA070MNT( cMarca, cAlias, cCampo, cExtID, cIntID,lDelete)
							CFGA070MNT( cMarca, aIntID[nY][4], aIntID[nY][5], aIntID[nY][2], aIntID[nY][3],lDelete)
						Next						
					Else
						aErro := oModel:GetErrorMessage()
						If !Empty(aErro)
							cErro := STR0002 		//'A integração não foi bem sucedida.'
							cErro += STR0003 + AllTrim(aErro[5]) + '-' + AllTrim(aErro[6]) //'Foi retornado o seguinte erro: '
							If !Empty(AllTrim(aErro[7]))
								cErro += STR0005 + AllTrim(aErro[7]) //'Solução - '
							Endif
						Else
							cErro := STR0002		// 'A integração não foi bem sucedida. '
							cErro += STR0004		// 'Verifique os dados enviados'
						Endif
						aSize(aErro, 0)
						aErro   := NIL
						lRet    := .F.
						ofwEAIObj := cErro
					Endif
					oModel:Deactivate()
					oModel:Destroy()
				EndIf
		EndCase
EndCase

nModulo := nOldModulo

Return {lRet, ofwEAIObj, cMsgUnica} 


/*/{Protheus.doc} IntFamExt
Monta o internalId do Family

@since 19/09/14
@version P12

@params	cEmpresa	- Empresa utilizado na integração
@params	cFil		- Filial utilizada na integração
@params	cFamily	- Código do grupo de produto

@return	Posicao 1  - LOGICAL - indica o status do processamento
@return	Posicao 2  - CHAR    - Xml/Conteúdo de retorno do processamento
/*/

Static Function IntFamExt(cEmpresa,cFil,cFamily)

Local   aResult  := {}

Default cEmpresa := cEmpAnt
Default cFil     := xFilial('SBM')

aAdd(aResult, .T.)
aAdd(aResult, cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cFamily))
	
Return aResult


/*/{Protheus.doc} IntFamInt
Busca o internalId do Family

@since 19/09/14
@version P12

@params	cInternalId	- InternalId a ser pesquisado
@params	cRefer			- Marca

@return	Posicao 1  - LOGICAL - indica o status do processamento
@return	Posicao 2  - CHAR    - Xml/Conteúdo de retorno do processamento
/*/

Static Function IntFamInt(cInternalID, cRefer)
Local   aResult  := {}
Local   aTemp    := {}
Local   cTemp    := ''
Local   cAlias   := 'SBM'
Local   cField   := 'BM_GRUPO'

cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)

If Empty(cTemp)
	aAdd(aResult, .F.)
	aAdd(aResult, STR0021 + " -> " + cInternalID) //"Grupo de produto não encontrado no de/para!"
Else
	aAdd(aResult, .T.)
	aTemp := Separa(cTemp, '|')
	aAdd(aResult,aTemp)
EndIf

Return aResult
