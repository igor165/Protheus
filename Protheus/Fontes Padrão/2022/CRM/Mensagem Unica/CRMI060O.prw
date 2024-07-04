#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TURXEAI.CH"
#INCLUDE "TURIDEF.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMI060O

Funcao de integracao com o adapter EAI para recebimento e envio de informações
relacionamento  Contatos x Cliente utilizando o conceito de mensagem unica JSON

@sample		CRMI060O( oEAIObEt, nTypeTrans, cTypeMessage ) 

@param		oEAIObEt 
@param		nTypeTrans 
@param		cTypeMessage

@return		lRet 
@return		ofwEAIObj
@return		cMsgUnica

@author		Totvs Cascavel
@since		11/09/2018
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMI060O( oEAIObEt, nTypeTrans, cTypeMessage )

    Local aCliente  := {}
    Local aMsgErro  := {}
    Local aAreaAC8  := AC8->(GetArea())
    Local cAlias    := "AC8"
    Local cCampo    := "AC8_CODCON"
    Local cCliente  := ""
    Local cCliLoja  := ""
	Local cCode		:= ""	
    Local cEntity	:= ""
    Local cEvento   := "upsert"
    Local cExtID    := ""
    Local cIntID    := ""    
    Local cItemCod  := ""
    Local cLoja     := ""
    Local cMarca    := "PROTHEUS"
    Local cMsgErro  := ""	
	Local cMsgUnica := "ContactRelationship"
    Local lDelete   := .F.
    Local lRet      := .T.
	Local nI		:= 0
    Local nX        := 0		
    Local ofwEAIObj	:= FwEAIobj():New()
    Local oMdlGrid	:= Nil
    Local oModel	:= Nil
	Local oLtOfCon	:= Nil

    Default	oEAIObEt := Nil

    Do Case
        //--------------------------------------
		//envio mensagem
		//--------------------------------------
		Case nTypeTrans == TRANS_SEND
        
            oModel := FwModelActive()
            If lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE
				cEvento := "delete"
			EndIf

            cCliLoja	:= AllTrim(oModel:GetValue('AC8MASTER', 'AC8_CODENT'))
			cCliente	:= Alltrim(SubStr(cCliLoja,1,TamSx3('A1_COD')[1])) 
			cLoja		:= Alltrim(SubStr(cCliLoja,TamSx3('A1_COD')[1]+1))
            cEntity     := IIF(AllTrim(oModel:GetValue('AC8MASTER', 'AC8_ENTIDA')) == 'SA1', "1","")
            cIntID		:= IntCliExt(,,cCliente,cLoja)[2]
            //Montagem da mensagem
			ofwEAIObj:Activate()
			ofwEAIObj:setEvent(cEvento)

            ofwEAIObj:setprop("CompanyId"           , cEmpAnt)
			ofwEAIObj:setprop("BranchId"            , cFilAnt)
			ofwEAIObj:setprop("CompanyInternalId"   , cEmpAnt + '|' + cFilAnt)
			ofwEAIObj:setprop("Code"                , cCliente +'|'+ cLoja +'|C')
			ofwEAIObj:setprop("InternalId"          , cIntID)
			ofwEAIObj:setprop("Entity"              , cEntity)

            oMdlGrid := oModel:GetModel('AC8CONTDET')
            For nX := 1 to oMdlGrid:Length()
				oMdlGrid:GoLine(nX)				
				cItemCod := oModel:GetValue('AC8CONTDET', 'AC8_CODCON')					
				If !oMdlGrid:IsDeleted() .Or. Upper(cEvento) == "DELETE"
					ofwEAIObj:Setprop('ListOfContacts',{},'Contact',,.T.)
					ofwEAIObj:Get("ListOfContacts")[nX]:Setprop("ContactCode", cItemCod,,.T.)
					ofwEAIObj:Get("ListOfContacts")[nX]:Setprop("ContactInternalId",cEmpAnt + '|' + xFilial("SU5") + '|' + RTrim(cItemCod),,.T.)                    			
				Endif
			Next nX

            //Exclui o De/Para 
			If lDelete
				CFGA070MNT(NIL, cAlias, cCampo, NIL, cIntID, lDelete)
			Endif
		
        //--------------------------------------
		//recebimento mensagem
		//--------------------------------------			
		Case nTypeTrans == TRANS_RECEIVE .And. Type("oEAIObEt") != Nil
            Do Case
                //--------------------------------------
	  			//whois
	  			//--------------------------------------
				Case (cTypeMessage == EAI_MESSAGE_WHOIS)
                    ofwEAIObj:Activate()
					ofwEAIObj:SetProp("ReturnContent")					
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Whois", "1.000")
                //--------------------------------------
				//resposta da mensagem Unica TOTVS
				//--------------------------------------
				Case (cTypeMessage == EAI_MESSAGE_RESPONSE)
                    //Verifica tipo do evento Inclusao/Alteracao/Exclusao
					If Upper(AllTrim(oEAIObEt:getPropValue("ReceivedMessage"):getPropValue("Event"))) == 'DELETE'
						lDelete := .T.					
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
						CFGA070MNT(cMarca, cAlias, cCampo, cExtID, cIntID, lDelete)
                    Endif
                //--------------------------------------
				//chegada de mensagem de negocios
				//--------------------------------------
				Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
					cEvento	:= Upper(AllTrim(oEAIObEt:getEvent()))
					cMarca	:= oEAIObEt:GetHeaderValue("ProductName")
					cExtID	:= AllTrim(oEAIObEt:GetPropValue("InternalId"))
					cEntity	:= PadR(IIf(AllTrim(oEAIObEt:GetPropValue("Entity"))=="1","SA1",""), TamSx3('AC8_ENTIDA')[1])
					aCliente  := IntCliInt(cExtID,cMarca)

					If aCliente[1]					
						cCliente	:= PadR(aCliente[2][3], TamSx3('A1_COD')[1])
						cLoja		:= PadR(aCliente[2][4], TamSx3('A1_LOJA')[1])
					Else
						lRet := .F.
						ofwEAIObj:Activate()
						ofwEAIObj:SetProp("ReturnContent")
						cMsgErro := aCliente[2]
						ofwEAIObj:GetPropValue("ReturnContent"):SetProp("Error", cMsgErro)
					EndIf
					//AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT+AC8_CODCON	
					AC8->(DbSetOrder(2))
					If lRet .And. cEvento == "UPSERT" .Or. cEvento == "REQUEST"
						If lRet .And. FWAliasInDic(cEntity)
							If ExistCpo(cEntity, cCliente + cLoja, 1 )
								oModel := FwLoadModel("CRMA060")
								oModel:SetOperation(MODEL_OPERATION_UPDATE)
								oModel:GetModel("AC8MASTER"):bLoad := {|| {xFilial("AC8"),xFilial( cEntity ),cEntity,cCliente + cLoja,""}}
								oModel:Activate()
								If oModel:IsActive()
									oMdlGrid := oModel:GetModel("AC8CONTDET")					
									If oEAIObEt:getPropValue("ListOfContacts") <> Nil
										oLtOfCon := oEAIObEt:getPropValue("ListOfContacts")
										For nX := 1 To Len(oLtOfCon)
											cExtId		:= Alltrim(oLtOfCon[nX]:GetPropValue("ContactInternalId"))							
											cItemCod	:= AllTrim(CFGA070INT(cMarca, "SU5", "U5_CODCONT", cExtId))
											If !Empty(cItemCod)
												cItemCod := Separa(cItemCod,"|")[3]
												If !oMdlGrid:SeekLine({{"AC8_CODCON",cItemCod}})
													If oMdlGrid:AddLine()
														If !oMdlGrid:SetValue("AC8_CODCON",cItemCod)
															lRet := .F.                                        
															aMsgErro	:= oModel:GetErrorMessage()
															Exit
														Endif
													Else
														lRet := .F.
														aMsgErro := oModel:GetErrorMessage()												
														Exit
													EndIf
												Endif
											Else
												lRet := .F.
												cMsgErro := STR0001+ Chr(13) + Chr(10) // "Registro nao encontrado no Protheus." 
												cMsgErro += "Contato: " + cExtId
												ofwEAIObj:Activate()
												ofwEAIObj:setProp("ReturnContent")
												ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cMsgErro)
											Endif
										Next nX
									Endif								
								Endif
							Else
								lRet := .F.
								cMsgErro := STR0001+ Chr(13) + Chr(10) // "Registro nao encontrado no Protheus." 
								cMsgErro += STR0009 + cCliente + cLoja
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cMsgErro)
							Endif
						Else
							lRet := .F.
							cMsgErro := "O Alias informado nao existe nos arquivos de dados"
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cMsgErro)
						Endif
					ElseIf Upper(cEvento) == "DELETE"
						If AC8->(DbSeek(xFilial('AC8') + cEntity + xFilial('SA1') + PadR(cCliente + cLoja,TamSx3('AC8_CODENT')[1])+ cItemCod))
							oModel := FwLoadModel("CRMA060")
							oModel:SetOperation(MODEL_OPERATION_DELETE)
							oModel:Activate()
							If !oModel:IsActive()
								lRet := .F.
								lDelete := .T.
								cMsgErro   := "Nao foi possivel Excluir o Relacionamento"
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cMsgErro)
							Endif
						Else
							lRet := .F.
							cMsgErro := STR0001+ Chr(13) + Chr(10) // "Registro nao encontrado no Protheus." 
							cMsgErro += STR0009 + cCliente + cLoja
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cMsgErro)
						Endif
					Endif

					If lRet
						If oModel:VldData()
							oModel:CommitData()
						Else
							lRet := .F.
							aMsgErro := oModel:GetErrorMessage()
						EndIf
					Endif

					If lRet 
						cMsgErro := "OK"
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")						
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cMsgErro)	
					Elseif Len(aMsgErro) > 0
						For nI := 1 To Len(aMsgErro)
							cMsgErro += FwNoAccent( AllToChar( aMsgErro[nI]))
						Next nI
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cMsgErro)
					Endif
            EndCase
    EndCase

	RestArea(aAreaAC8)

    aSize(aAreaAC8,0)
    aSize(aCliente,0)
    aSize(aMsgErro,0)

Return {lRet, ofwEAIObj, cMsgUnica}