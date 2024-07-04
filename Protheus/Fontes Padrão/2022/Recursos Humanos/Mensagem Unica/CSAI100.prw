#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "CSAI100.CH"

#INCLUDE "FWMVCDEF.CH"

Static cVerSend         := "1.000|2.001"  // versões disponíveis


//-------------------------------------------------------------------
/*/{Protheus.doc} CSAI100
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de departamentos (SQB) utilizando o conceito de mensagem unica.

@param   cXML          Variavel com conteudo xml para envio/recebimento.
@param   nTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Sidney de Oliveira
@version P11
@since   16/09/2013
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
aRet[1] - (boolean) Indica o resultado da execução da função
aRet[2] - (caracter) Mensagem Xml para envio

@obs     O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------
//
Function CSAI100(cXml, nTypeTrans, cTypeMessage, cVersao)
Local lLog     := FindFunction("AdpLogEAI")
Local lRet     := .T.
Local cXMLRet  := ""
Local oXml
Local cError   := ""
Local cWarning := ""
Local nOpc
Local aDepto   := {}
Local cProduct := ""
Local cValInt  := ""

Local cField   := "QB_DEPTO"
Local cAlias   := "SQB"
Local cValExt
Local nI
Local cEvento	:= "Upsert"

Local lBlqd := IIf(SQB->(ColumnPos('QB_MSBLQD')) > 0,.T.,.F.)
Local lArELin := IIf(SQB->(ColumnPos('QB_ARELIN')) > 0,.T.,.F.)

Default cVersao        := "1.000"

Private lMsErroAuto 	:= .F.
	

cVersao := Alltrim(cVersao)

If lLog
	AdpLogEAI(1, "CSAI100", nTypeTrans, cTypeMessage, cXML)
EndIf

If nTypeTrans == TRANS_RECEIVE
	If cTypeMessage == EAI_MESSAGE_BUSINESS
	
		If cVersao $ cVerSend
			oXml := XmlParser(cXml, "_", @cError, @cWarning)
	
			// Se não houve erros
			If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
	
			    aadd(aDepto, {"QB_FILIAL", xFilial("SQB"), Nil})
			    aadd(aDepto, {"QB_DEPTO", oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text, Nil})
			    aadd(aDepto, {"QB_DESCRIC", oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text, Nil})
			    aadd(aDepto, {"QB_CC", oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CostCenterCode:Text, Nil})
			    
			    If cVersao == '2.001'
			    	If lArELin
			    		aadd(aDepto, {"QB_ARELIN", oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AreaLineBusiness:Text, Nil})
			    	Endif
				    If lBlqd 
				       aadd(aDepto, {"QB_MSBLQD", STOD( StrTran( SubStr( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LockDate:Text, 1, 10 ), "-", "") ), Nil})
				    Endif
			    Endif
	
				// Código do Produto da Integração
				cEvento := oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text
	
				If Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
	
					nOpc := 3 //Inclusão
	
					cProduct := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
					If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Internalid:Text") != "U" .And. ;
							 !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Internalid:Text)
						cValExt := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Internalid:Text
					Else
						cValExt := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text
					Endif
					//Pesquisa o IntenalId do Departamento
					cValInt  := CFGA070Int(cProduct, cAlias, cField, cValExt)
					
					If !( "|" $ cValint)
						cValInt  :=  cEmpAnt + "|" +  xFilial("SQB") + "|" + AllTrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text)
					EndIf

					dbSelectArea("SQB")
					SQB->(dbSetOrder(1))//QB_FILIAL+QB_DEPTO
					If !SQB->(dbSeek(xFilial("SQB")+oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text))
						nOpc := 3
					Else
						nOpc := 4
					EndIf
				ElseIf Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
					nOpc := 5 //Exclusão
				Else
					lRet    := .F.
					cXmlRet := STR0001 //"O Event informado é inválido!"
					Return {lRet, EncodeUTF8(cXMLRet)}
				EndIf
			Else
				lRet    := .F.
				cXmlRet := STR0002 //"Erro ao parsear xml!"
			EndIf
			
			MSExecAuto({|x, y, z, w| CSAA100(x, y, z, w)},,, aDepto, nOpc)
			
			If lMsErroAuto
				aErro := GetAutoGRLog()
				
				cXMLRet := "<![CDATA["
				For nI := 1 To Len(aErro)
					cXMLRet += aErro[nI] + Chr(10)
				Next nI
				cXMLRet += "]]>"
				
				lRet := .F.
			Else
				If(nOpc != 5) // Se o evento é diferente de delete
					// Grava o registro na tabela XXF (de/para)
					CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F., 1)
				Else
					// Exclui o registro na tabela XXF (de/para)
					CFGA070Mnt(, cAlias, cField,, cValInt, .T.)
				EndIf
				
				// Monta o XML de retorno
				cXMLRet := "<ListOfInternalId>"
				cXMLRet +=     "<InternalId>"
				cXMLRet +=         "<Name>Departament</Name>"
				cXMLRet +=         "<Origin>" + oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Internalid:Text + "</Origin>" // Valor recebido na tag
				cXMLRet +=         "<Destination>" + cValInt + "</Destination>" // Valor XXF gerado
				cXMLRet +=     "</InternalId>"
				cXMLRet += "</ListOfInternalId>"
			EndIf	
		Else
			lRet := .F.
			cXmlRet := STR0005 // "Versão não tratada pelo adapter"
		Endif
		
	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
		/////////////////////////////////////////////////////////////////////////////////////
		// Faz o parse do xml em um objeto
		oXml := XmlParser(cXml, "_", @cError, @cWarning)
		
		If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
			
			If(Upper(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK")
				// Verifica se a marca foi informada
				If(Type("oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text))
					cProduct := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
				Else
					lRet    := .F.
					cXmlRet := STR0003 //"Erro no retorno. O Product é obrigatório!"
					If lLog
						AdpLogEAI(5, "CSAI100", cXMLRet, lRet)
					EndIf
					Return {lRet, EncodeUTF8(cXmlRet)}
				EndIf

				If(oXml <> Nil .And. Empty(cError) .And. Empty(cWarning))

				Else
					lRet    := .F.
					cXmlRet := STR0004 //"Erro no parser do retorno!"
					Return {lRet, EncodeUTF8(cXmlRet)}
				EndIf
			Else
				// Se não for array
				If(ValType(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message) != "A")
					// Transforma em array
					XmlNode2Arr(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
				EndIf
				
				// Percorre o array para obter os erros gerados
				For nI := 1 To Len(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
					cError := oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nI]:Text + "\n"
				Next nI
				
				lRet    := .F.
				cXmlRet := cError
			EndIf
		Else
			lRet    := .F.
			cXmlRet := STR0002 //"Erro ao parsear xml!"
		EndIf
	ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := cVerSend
	Endif
ElseIf nTypeTrans == TRANS_SEND
	If !Inclui .And. !Altera
		cEvento := "delete"

		M->QB_FILIAL  := SQB->QB_FILIAL
		M->QB_DEPTO   := SQB->QB_DEPTO
		M->QB_DESCRIC := SQB->QB_DESCRIC
		M->QB_CC       := SQB->QB_CC
		If lArELin
			M->QB_ARELIN  := SQB->QB_ARELIN
		Endif
		If lBlqd
			M->QB_MSBLQD  := SQB->QB_MSBLQD
		Endif
	EndIf

	cXMLRet += '<BusinessEvent>'
	cXMLRet +=    '<Entity>Departament</Entity>'
	cXMLRet += '<Event>' + cEvento + '</Event>'
	cXMLRet +=    '<Identification>'
	cXMLRet +=       '<key name="InternalID">' + cEmpAnt + '|' + xFilial("SQB") + '|' + M->QB_DEPTO + '</key>'
	cXMLRet +=    '</Identification>'
	cXMLRet += '</BusinessEvent>'
	cXMLRet += '<BusinessContent>'
	cXMLRet +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
	//cXMLRet +=    '<BranchId>' + xFilial("SQB") + '</BranchId>'
	cXMLRet +=    '<BranchId>' + cFilAnt + '</BranchId>'
	cXMLRet +=    '<CompanyInternalId>' + cEmpAnt + "|" + xFilial("SQB") + '</CompanyInternalId>'
	cXMLRet +=    '<Code>' + M->QB_DEPTO + '</Code>'
	cXMLRet +=    '<Description>' + M->QB_DESCRIC + '</Description>'
	cXMLRet +=    '<CostCenterCode>' + M->QB_CC + '</CostCenterCode>'
    If cVersao == '2.001'
		cXMLRet +=    '<InternalId>' + cEmpAnt + '|' + xFilial("SQB") + '|' + M->QB_DEPTO + '</InternalId>'
		cXMLRet +=    '<CostCenterInternalId>' + IntCusExt( , xFilial("CTT"), M->QB_CC, '2.000')[2] + '</CostCenterInternalId>'

    	If lArELin
    		cXMLRet +=    '<AreaLineBusiness>' + M->QB_ARELIN + '</AreaLineBusiness>'
    	Endif
    	If lBlqd
    		cXMLRet +=  '<LockDate>' + Transform( DToS( M->QB_MSBLQD ), "@R 9999-99-99") + '</LockDate>'
		Endif   
	Endif
	cXMLRet += '</BusinessContent>'
EndIf

If lLog
	AdpLogEAI(5, "CSAI100", cXMLRet, lRet)
EndIf

Return {lRet, EncodeUTF8(cXMLRet)}