#Include 'Protheus.ch'
#Include 'fwAdapterEAI.ch'
#Include 'FWMVCDEF.CH'
#Include 'SFCI003.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCI003
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de motivos de refugo (CYO/SX5) utilizando o conceito de mensagem unica.

@param   oXMLEnv       Variavel com conteudo xml para envio/recebimento.
@param   nTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Lucas Konrad França
@version P118
@since   14/04/2016
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execução da função
         aRet[2] - (caracter) Mensagem Xml para envio

@obs     O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
         o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
         TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
         O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------
Function SFCI003(oXMLEnv, nTypeTrans, cTypeMessage)
	Local cVersao     := ""
	Local lRet        := .T.
	Local cXmlRet     := ""

	Private oXML      := oXMLEnv
	Private lIntegPPI := .F.

	//Verifica se está sendo executado para realizar a integração com o PPI.
	//Se a variável lRunPPI estiver definida, e for .T., assume que é para o PPI.
	If Type("lRunPPI") == "L" .And. lRunPPI
		lIntegPPI := .T.
	EndIf

	//Mensagem de Entrada
	If nTypeTrans == TRANS_RECEIVE
		If cTypeMessage == EAI_MESSAGE_BUSINESS
			// Versão da mensagem
			If Type("oXml:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_version:Text)
				cVersao := StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
			Else
				If Type("oXml:_TOTVSMessage:_MessageInformation:_StandardVersion:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_StandardVersion:Text)
					cVersao := StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_StandardVersion:Text, ".")[1]
				Else
					lRet    := .F.
					cXmlRet := STR0001 //"Versão da mensagem não informada!"
					Return {lRet, cXmlRet}
				Endif
			EndIf

			If cVersao == "1"
				Begin Transaction
					aRet := v1000(oXML, nTypeTrans, cTypeMessage)
					If !aRet[1]
						DisarmTransaction()
					EndIf
				End Transaction
			Else
				lRet    := .F.
				cXmlRet := STR0002 //"A versão da mensagem informada não foi implementada!"
				Return {lRet, cXmlRet}
			EndIf
		Endif
	ElseIf nTypeTrans == TRANS_SEND

	EndIf

	lRet    := aRet[1]
	cXMLRet := aRet[2]
Return {lRet, cXMLRet}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} v1000

Funcao de integracao com o adapter EAI para recebimento do cadastro de motivos de refugo (CYO/SX5)
utilizando o conceito de mensagem unica.

@param   oXMLEnv      Variável com conteúdo XML para envio/recebimento.
@param   nTypeTrans   Tipo de transação. (Envio/Recebimento)
@param   cTypeMessage Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Lucas Konrad França
@version P118
@since   14/04/2016
@return  aRet  - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio

@obs    O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
       o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
       TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
       O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------------------------------------
Static Function v1000(oXMLEnv, nTypeTrans, cTypeMessage)
	Local lRet     := .T.
	Local cXmlRet  := ""
	Local cEvent   := ""
	Local cProduct := ""
	Local lIntgSFC := Iif(SuperGetMV("MV_INTSFC",.F.,0)==1,.T.,.F.)
	Local aDados   := {}
	Local aAux     := {}
	Local nI       := 0
	Local cCampo   := ""
	
	Local cRefugo    := ""
	Local cDescricao := ""
	Local lRefMat    := .F.
	Local lRetrab    := .F.
	
	Local oModel
	
	If !lIntegPPI .And. FindFunction("AdpLogEAI")
		AdpLogEAI(1, "SFCI003", nTypeTrans, cTypeMessage)
	EndIf

	If nTypeTrans == TRANS_RECEIVE
		If cTypeMessage == EAI_MESSAGE_BUSINESS
			If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)
				cEvent := Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)
				If Upper(cEvent) != "UPSERT" .And. Upper(cEvent) != "DELETE"
					lRet   := .F.
					cXmlRet := STR0003 // "Event inválido. Informe 'UPSERT' ou 'DELETE'."
					Return {lRet, cXMLRet}
				EndIf
			Else
				lRet   := .F.
				cXmlRet := "Event " + STR0004 // é obrigatório."
				Return {lRet, cXMLRet}
			EndIf
		EndIf

		If Type("oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text") != "U" .And. !Empty(oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
			cProduct := oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text
		Else
			lRet   := .F.
			cXmlRet := "Product:Name " + STR0004 // é obrigatório."
			Return {lRet, cXMLRet}
		EndIf

		If AllTrim(UPPER(cProduct)) == "PPI"
			//Verifica se a integração com o PPI está ativa. Se não estiver, não permite prosseguir com a integração.
			If !PCPIntgPPI()
				lRet := .F.
				cXmlRet := STR0005 //"Integração com o TOTVS MES desativada. Processamento não permitido."
				Return {lRet, cXMLRet}
			EndIf
		EndIf
		
		//Código do refugo
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_Code:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_Code:Text)
			cRefugo := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_Code:Text
			cMotivo := cRefugo
			If lIntgSFC
				If Len(AllTrim(cRefugo)) > TamSX3("CYO_CDRF")[1] .Or. Len(AllTrim(cRefugo)) > TamSX3("CY0_CDRF")[1] .Or. Len(AllTrim(cRefugo)) > TamSX3("BC_MOTIVO")[1] 
					aAdd(aAux, {TamSX3("CYO_CDRF")[1], " CYO_CDRF"})
					aAdd(aAux, {TamSX3("CY0_CDRF")[1], " CY0_CDRF"})
					aAdd(aAux, {TamSX3("BC_MOTIVO")[1]," BC_MOTIVO"})
					
					aSort(aAux,,,{|x, y| x[1] < y[1]})
					
					lRet := .F.
					cXmlRet := STR0006 + aAux[1,2] //"Code informado incorretamente. Tamanho maior do que o campo "
					Return {lRet, cXmlRet}
				EndIf 
			Else
				//Se o cliente possui os campos novos da CYO, então ele está na regra
                //nova que transferiu o  cadastro dos motivos de refugo da SX5 para
                //SFCA003 independente do cliente ter ou não integração com o chão de fábrica
				
				If campoCYO()
					If Len(AllTrim(cRefugo)) > TamSX3("BC_MOTIVO")[1] .Or. Len(AllTrim(cRefugo)) > TamSX3("CYO_DSRF")[1]
						If TamSX3("BC_MOTIVO")[1] >= TamSX3("CYO_DSRF")[1]
							cCampo := "BC_MOTIVO"
						Else
							cCampo := "CYO_DSRF"
						EndIf
						lRet := .F.
						cXmlRet := STR0006 + cCampo //"Code informado incorretamente. Tamanho maior do que o campo "
						Return {lRet, cXmlRet}
					EndIf 
				Else
					If Len(AllTrim(cRefugo)) > TamSX3("BC_MOTIVO")[1] .Or. Len(AllTrim(cRefugo)) > TamSX3("X5_CHAVE")[1]
						If TamSX3("BC_MOTIVO")[1] >= TamSX3("X5_CHAVE")[1]
							cCampo := "BC_MOTIVO"
						Else
							cCampo := "X5_CHAVE"
						EndIf
						lRet := .F.
						cXmlRet := STR0006 + cCampo //"Code informado incorretamente. Tamanho maior do que o campo "
						Return {lRet, cXmlRet}
					EndIf 
				EndIf
			EndIf
		Else
			lRet := .F.
			cXmlRet := "Code " + STR0004 // é obrigatório."
			Return {lRet, cXMLRet}
		EndIf
		
		//Descrição do refugo
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_Description:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_Description:Text)
			cDescricao := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_Description:Text
		Else
			lRet := .F.
			cXmlRet := "Description " + STR0004 // é obrigatório."
			Return {lRet, cXMLRet}
		EndIf
		
		//Retrabalho?
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_IsRework:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_IsRework:Text)
			If Upper(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_IsRework:Text) == "TRUE"
				lRetrab := .T.
			Else
				lRetrab := .F.
			EndIf
		Else
			If lIntgSFC
				lRetrab := Nil
				//lRet := .F.
				//cXmlRet := "IsRework " + STR0004 // é obrigatório."
				//Return {lRet, cXMLRet}
			EndIf
		EndIf
		
		//Refugo material?
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_IsScrapMaterial:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_IsScrapMaterial:Text)
			If Upper(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_IsScrapMaterial:Text) == "TRUE"
				lRefMat := .T.
			Else
				lRefMat := .F.
			EndIf
		Else
			If lIntgSFC
				lRefMat := Nil
				//lRet := .F.
				//cXmlRet := "IsScrapMaterial " + STR0004 // é obrigatório."
				//Return {lRet, cXMLRet}
			EndIf
		EndIf
		
		If lIntgSFC .And. lRefMat == Nil .And. lRetrab == Nil
			lRetrab := .F.
			lRefMat := .T.
		EndIf
		
		If lIntgSFC .Or. campoCYO()
			oModel := FWLoadModel("SFCA003")
			If Upper(cEvent) == "UPSERT"
				dbSelectArea("CYO")
				CYO->(dbSetOrder(1))
				If CYO->(dbSeek(xFilial("CYO")+cRefugo))
					//Registro já existe, realiza a modificação
					oModel:SetOperation(MODEL_OPERATION_UPDATE)
				Else
					//Novo registro
					oModel:SetOperation(MODEL_OPERATION_INSERT)
				EndIf
			Else
				dbSelectArea("CYO")
				CYO->(dbSetOrder(1))
				If !CYO->(dbSeek(xFilial("CYO")+cRefugo))
					//Se o registro não existe, retorna como sucesso.
					lRet := .T.
					cXmlRet := "OK"
					Return {lRet, cXMLRet}
				EndIf
				oModel:SetOperation(MODEL_OPERATION_DELETE)
			EndIf
			
			//Ativa o modelo
			oModel:Activate()
			
			//Alimenta array com os dados
			aAdd(aDados,{"CYO_CDRF",cRefugo})
			aAdd(aDados,{"CYO_DSRF",cDescricao})
			
			If campoCYO()
				aAdd(aDados,{"CYO_LGRFMP",lRefMat})
				aAdd(aDados,{"CYO_LGRT",lRetrab})
			EndIf
			
			// Obtém a estrutura de dados
			aAux := oModel:GetModel('CYOMASTER'):GetStruct():GetFields()

			If oModel:nOperation != MODEL_OPERATION_DELETE
				For nI := 1 To Len(aDados)
					// Verifica se os campos passados existem na estrutura do modelo
					If aScan(aAux, {|x| AllTrim(x[3]) == AllTrim(aDados[nI][1])}) > 0
						// Não enviar a filial e o código ao alterar
						If oModel:nOperation == MODEL_OPERATION_UPDATE .And. aDados[nI,1] == "CYO_CDRF"
							Loop
						EndIf
						// É feita a atribuição do dado ao campo do Model
						If !oModel:SetValue('CYOMASTER', aDados[nI][1], aDados[nI][2])
							lRet := .F.
							cXmlRet := STR0007 + AllToChar(aDados[nI][2]) + STR0008 + aDados[nI][1] + "." // "Não foi possível atribuir o valor " XXX " ao campo " XXX "."
							Return {lRet, cXmlRet}
						EndIf
					EndIf
				Next nI
			EndIf
			// Validação no Model    
			If oModel:VldData()  
				// Caso nao ocorra erros, efetiva os dados no banco
				oModel:CommitData()    
				
				// Retorna OK
				lRet    := .T.
				cXMLRet := "OK"
			Else
				// Cria TAG com o Erro ocorrido para retornar ao EAI
				cXMLRet := oModel:GetErrorMessage()[6]
				lRet    := .F.
			EndIf
			// Desativa o Model
			oModel:DeActivate()
		EndIf		
		
   ElseIf nTypeTrans == TRANS_SEND

   EndIf

	If !lIntegPPI .And. FindFunction("AdpLogEAI")
		AdpLogEAI(5, "SFCI003", cXMLRet, lRet)
	EndIf

Return {lRet, cXmlRet}
