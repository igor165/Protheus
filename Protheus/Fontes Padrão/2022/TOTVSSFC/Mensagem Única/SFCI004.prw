#Include 'Protheus.ch'
#Include 'fwAdapterEAI.ch'
#Include 'FWMVCDEF.CH'
#Include 'SFCI004.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCI004
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de motivos de parada (CYN/SX5) utilizando o conceito de mensagem unica.

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
Function SFCI004(oXMLEnv, nTypeTrans, cTypeMessage)
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

Funcao de integracao com o adapter EAI para recebimento do cadastro de motivos de parada (CYN/SX5)
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
	
	Local cParada    := ""
	Local cDescricao := ""
	Local lEfici     := .F.
	Local lEmailPlj  := .F.
	Local lSolicit   := .F.
	Local lPrepara   := .F.
	
	Local oModel

	Local lAtuCYN  := .F.

	CYN->(dbSelectArea("CYN"))
	If CYN->(FieldPos("CYN_LGMOD")) > 0
		lAtuCYN := .T.
	EndIf
	
	If !lIntegPPI .And. FindFunction("AdpLogEAI")
		AdpLogEAI(1, "SFCI004", nTypeTrans, cTypeMessage)
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
		
		//Código da parada
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_Code:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_Code:Text)
			cParada := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_Code:Text
			cMotivo := cParada

			If lIntgSFC .Or. lAtuCYN
				If Len(AllTrim(cParada)) > TamSX3("CYN_CDSP")[1] .Or. ;
				   Len(AllTrim(cParada)) > TamSX3("CYX_CDSP")[1] .Or. ;
				   Len(AllTrim(cParada)) > TamSX3("H6_MOTIVO")[1]  
					
					aAdd(aAux, {TamSX3("CYN_CDSP")[1], " CYN_CDSP"})
					aAdd(aAux, {TamSX3("CYX_CDSP")[1], " CYX_CDSP"})
					aAdd(aAux, {TamSX3("H6_MOTIVO")[1]," H6_MOTIVO"})
					
					aSort(aAux,,,{|x, y| x[1] < y[1]})
					
					lRet := .F.
					cXmlRet := STR0006 + aAux[1,2] //"Code informado incorretamente. Tamanho maior do que o campo "
					Return {lRet, cXmlRet}
				EndIf 
			EndIf
		Else
			lRet := .F.
			cXmlRet := "Code " + STR0004 // é obrigatório."
			Return {lRet, cXMLRet}
		EndIf
		
		//Descrição da parada
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_Description:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_Description:Text)
			cDescricao := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_Description:Text
		Else
			lRet := .F.
			cXmlRet := "Description " + STR0004 // é obrigatório."
			Return {lRet, cXMLRet}
		EndIf
		
		//Altera eficiência?
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_IsEfficiency:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_IsEfficiency:Text)
			If Upper(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_IsEfficiency:Text) == "TRUE"
				lEfici := .T.
			Else
				lEfici := .F.
			EndIf
		Else
			If lIntgSFC
				lEfici := .F.
				//lRet := .F.
				//cXmlRet := "IsEfficiency " + STR0004 // é obrigatório."
				//Return {lRet, cXMLRet}
			EndIf
		EndIf
		
		//Email planejador?
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_IsEmailEquipment:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_IsEmailEquipment:Text)
			If Upper(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_IsEmailEquipment:Text) == "TRUE"
				lEmailPlj := .T.
			Else
				lEmailPlj := .F.
			EndIf
		Else
			If lIntgSFC
				//lRet := .F.
				//cXmlRet := "IsEmailEquipment " + STR0004 // é obrigatório."
				//Return {lRet, cXMLRet}
				lEmailPlj := .F.
			EndIf
		EndIf
		
		//Emite solicitação?
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_IsServiceRequest:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_IsServiceRequest:Text)
			If Upper(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_IsServiceRequest:Text) == "TRUE"
				lSolicit := .T.
			Else
				lSolicit := .F.
			EndIf
		Else
			If lIntgSFC
				//lRet := .F.
				//cXmlRet := "IsServiceRequest " + STR0004 // é obrigatório."
				//Return {lRet, cXMLRet}
				lSolicit := .F.
			EndIf
		EndIf
		
		//Preparação
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_IsSetup:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_IsSetup:Text)
			If Upper(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_IsSetup:Text) == "TRUE"
				lPrepara := .T.
			Else
				lPrepara := .F.
			EndIf
		Else
			If lIntgSFC
				//lRet := .F.
				//cXmlRet := "IsSetup " + STR0004 // é obrigatório."
				//Return {lRet, cXMLRet}
				lPrepara := .F.
			EndIf
		EndIf
		
		If lIntgSFC .Or. lAtuCYN
			oModel := FWLoadModel("SFCA004")
			If Upper(cEvent) == "UPSERT"
				dbSelectArea("CYN")
				CYN->(dbSetOrder(1))
				If CYN->(dbSeek(xFilial("CYN")+cParada))
					//Registro já existe, realiza a modificação
					oModel:SetOperation(MODEL_OPERATION_UPDATE)
				Else
					//Novo registro
					oModel:SetOperation(MODEL_OPERATION_INSERT)
				EndIf
			Else
				dbSelectArea("CYN")
				CYN->(dbSetOrder(1))
				If !CYN->(dbSeek(xFilial("CYN")+cParada))
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
			aAdd(aDados,{"CYN_CDSP",cParada})
			aAdd(aDados,{"CYN_DSSP",cDescricao})
			aAdd(aDados,{"CYN_LGEF",lEfici})
			aAdd(aDados,{"CYN_LGSU",lPrepara})
			aAdd(aDados,{"CYN_LGSS",lSolicit})
			aAdd(aDados,{"CYN_LGELEQ",lEmailPlj})
			
			// Obtém a estrutura de dados
			aAux := oModel:GetModel('CYNMASTER'):GetStruct():GetFields()

			If oModel:nOperation != MODEL_OPERATION_DELETE
				For nI := 1 To Len(aDados)
					// Verifica se os campos passados existem na estrutura do modelo
					If aScan(aAux, {|x| AllTrim(x[3]) == AllTrim(aDados[nI][1])}) > 0
						// Não enviar a filial e o código ao alterar
						If oModel:nOperation == MODEL_OPERATION_UPDATE .And. aDados[nI,1] == "CYN_CDSP"
							Loop
						EndIf
						// É feita a atribuição do dado ao campo do Model
						If !oModel:SetValue('CYNMASTER', aDados[nI][1], aDados[nI][2])
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
		AdpLogEAI(5, "SFCI004", cXMLRet, lRet)
	EndIf

Return {lRet, cXmlRet}
