#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'QIEI030.CH'
#INCLUDE 'FWMVCDef.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QIEI030O   ºAutor  ³ Totvs Cascavel      º Data ³  02/05/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Funcao de integracao com o adapter EAI para recebimento e    º±±
±±º          ³ envio de informações do cadastro de unidade de medidas (SAH) º±±
±±º          ³ utilizando o conceito de mensagem unica formato JSON.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Param.   ³ oEAIObEt - Objeto JSON para envio/recebimento.				º±±
±±º          ³ nTypeTrans - Tipo de transacao. (Envio/Recebimento)          º±±
±±º          ³ cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, etc) º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno  ³ aRet - Array contendo o resultado da execucao e a mensagem   º±±
±±º          ³        retorno. 		                                        º±±
±±º          ³ aRet[1] - (boolean) Indica o resultado da execução da função º±±
±±º          ³ aRet[2] - (obejto) Objeto JSON para envio 	                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ QIEI030O                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} 

Funcao de integracao com o adapter EAI para envio e recebimento do  cadastro de
Unidade de Medida (SAH) utilizando o conceito de mensagem unica.

@param   oEAIObEt 	   Objeto para envio/recebimento.
@param   nTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Totvs Cascavel
@version P12
@since   02/05/2018
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) 	Indica o resultado da execução da função
         aRet[2] - (objeto) 	Mensagem para envio
		 aRet[3] - (caracter) 	Codigo da mensagem
/*/
//-------------------------------------------------------------------
Function QIEI030Json( oEAIObEt, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj )
Local aRet     		:= {}
Local lRet          := .T.
Local nOpcx         := 0
Local nCount        := 1
Local cLogErro      := ""
Local aUnidMed      := {}
Local aErroAuto     := {}
Local cEvent        := "upsert"
Local cProduct      := ""
Local cValInt       := ""
Local cValExt       := ""
Local cAlias        := "SAH"
Local cField        := "AH_UNIMED" 
Local cCode         := ""
Local lDelete		:= .F.
Local cMsgUnica		:= 'UNITOFMEASURE'
Local cMarca		:= ""
Local oModel		

//Instancia objeto JSON
Local ofwEAIObj	:= FWEAIobj():NEW()

//Private oXmlA030    := oXml
Private lMsErroAuto := .F.

Default oEAIObEt	:= Nil
Default nTypeTrans	:= "3"
Default cTypeMessage:= ""
Default cVersion	:= ""
Default cTransac	:= ""
Default lEAIObj		:= .F.

Do Case
	//--------------------------------------
	//recebimento mensagem
	//--------------------------------------
	Case nTypeTrans == TRANS_RECEIVE .And. ValType( oEAIObEt ) == 'O'
		Do Case
			//--------------------------------------
			//chegada de mensagem de negocios
			//--------------------------------------
			Case cTypeMessage == EAI_MESSAGE_BUSINESS
				
				cEvent := AllTrim(oEAIObEt:getEvent())
				
				If oEAIObEt:getHeaderValue("ProductName") !=  nil
					cProduct := oEAIObEt:getHeaderValue("ProductName")
				Else
					lRet    := .F.
					ofwEAIObj := STR0014 // "A Marca é obrigatória!"
					Return { lRet, ofwEAIObj, cMsgUnica } 
				EndIf
				
				// Verifica se o Código da Unidade de Medida foi informado
				If oEAIObEt:getPropValue("Code") != nil
					cCode := oEAIObEt:getPropValue("Code")
				Else
					lRet     := .F.
					ofwEAIObj := STR0016 // "O código da Unidade de Medida é obrigatório!"
					Return { lRet, ofwEAIObj, cMsgUnica } 
				EndIf		
				
				// Verifica se o InternalId foi informado
				If oEAIObEt:getPropValue("InternalId") != nil
					cValExt := Upper(oEAIObEt:getPropValue("InternalId"))
				Else
					lRet    := .F.
					ofwEAIObj := STR0015 // "O código do InternalId é obrigatório!"
					Return { lRet, ofwEAIObj, cMsgUnica } 
				EndIf			
				
				// Obtém o valor interno da tabela XXF (de/para)
				aAux := IntUndInt(cValExt, cProduct, cVersao)
		
				cCode := FwNoAccent(cCode) //retiara os acentos do codigo
				cCode := IntUndCEsp(cCode) //Tratamento caracter especial
				
				If Upper(cEvent) == 'UPSERT' .Or. Upper(cEvent) == 'REQUEST'
					// Se o registro foi encontrado
					If aAux[1]
						cCode := aAux[2][3]
						nOpcx := 4 // Update
					Else
						If Empty(Posicione("SX3", 2, PadR("AH_UNIMED", 10), "X3_RELACAO"))
							//Valida tamanho do codigo enviado
							If TamSx3("AH_UNIMED")[1] >= Len(AllTrim(cCode))
								SAH->(dbSetOrder(1))
						
								If SAH->(DbSeek(xFilial("SAH") + Padr(cCode, TamSx3("AH_UNIMED")[1])))
									nOpcx := 4 // Update
								Else 	
									nOpcx := 3 // Insert
								EndIf
							Else
								If SuperGetMV("MV_QIEICOD",.F.,.T.)
									lRet := .F.
									ofwEAIObj := STR0032 + AllTrim(cCode) + STR0033 + Chr(10) //"O Codigo da Unidade de Medida "## " possui tamanho maior que o permitido."
									ofwEAIObj += STR0034 + CValToChar(TamSx3("AH_UNIMED")[1]) + Chr(10) // "Maximo:"
									ofwEAIObj += STR0035 + CValToChar(Len(AllTrim(cCode))) // "Enviado:"
									Return { lRet, ofwEAIObj, cMsgUnica }
								Else
									cCode   := geraCod(cCode)
									nOpcx   := 3 // Insert
								Endif
							EndIf
						Else
							cCode := ""
							nOpcx := 3 // Insert
						EndIf
					EndIf					
				ElseIf Upper(cEvent) == 'DELETE'
					// Se o registro existe
					If aAux[1]   
						cCode := aAux[2][3]
						nOpcx := 5 // Delete
						lDelete := .T.
					Else
						lRet := .F.
						ofwEAIObj := STR0017 + " -> " + cValExt // "O registro a ser excluído não existe na base Protheus"
						Return { lRet, ofwEAIObj, cMsgUnica }
					EndIf
				Else
					lRet    := .F.
					ofwEAIObj := STR0018 // "O evento informado é inválido!"
					Return { lRet, ofwEAIObj, cMsgUnica }
				EndIf
				
				cValInt := IntUndExt(,,cCode,)[2]
				
				// Armazena o Código da Unidade de Medida no Array
				aAdd(aUnidMed, {"AH_UNIMED", PadR(cCode, TamSX3("AH_UNIMED")[1]), Nil})
		
				//Filial
				aAdd(aUnidMed, {"AH_FILIAL", xFilial("SAH"), Nil})		
				
				// Se o evento é diferente de Delete
				If nOpcx != 5
					// Verifica se a Descrição da Unidade de Medida foi informada
					If oEAIObEt:getPropValue("Description") != nil
						aAdd(aUnidMed, {"AH_DESCPO", oEAIObEt:getPropValue("Description"), Nil})
					Else
						lRet    := .F.
						ofwEAIObj := STR0019 // "A Descrição da Unidade de Medida é obrigatória"
						Return { lRet, ofwEAIObj, cMsgUnica }
					EndIf
		
					// Descrição resumida 
					If oEAIObEt:getPropValue("ShortName") != nil
						aAdd(aUnidMed, {"AH_UMRES", SubStr(oEAIObEt:getPropValue("ShortName"), 1, TamSX3("AH_UMRES")[1]), Nil})
					EndIf
				EndIf
				
				// Executa comando para insert, update ou delete conforme evento
				MSExecAuto({|x,y| QIEA030(x,y)}, aUnidMed, nOpcx)	
				
				// Se houve erros no processamento do MSExecAuto
				If lMsErroAuto
					aErroAuto := GetAutoGRLog()
					For nCount := 1 To Len(aErroAuto)
						cLogErro += StrTran(StrTran(aErroAuto[nCount],"<",""),"-","") + (" ") 
					Next nCount
					// Monta objeto de Erro de execução da rotina automatica.
					lRet := .F.
					ofwEAIObj := SubStr(EncodeUTF8( cLogErro ),1,750)
				Else
					If oEAIObEt:getHeaderValue("Transaction") !=  nil
						cName := oEAIObEt:getHeaderValue("Transaction")
					Endif
					
					// Monta o JSON de retorno
					ofwEAIObj:Activate()
																			
					ofwEAIObj:setProp("ReturnContent")
										
					ofwEAIObj:getPropValue("ReturnContent"):setProp("ListOfInternalId",{},'InternalId',,.T.)
					ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalId")[1]:setprop("Name",cName,,.T.)
					ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalId")[1]:setprop("Origin",cValExt,,.T.)
					ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalId")[1]:setprop("Destination",cValInt,,.T.)				
							
					CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, lDelete)							
				EndIf		


			//--------------------------------------
			//resposta da mensagem Unica TOTVS
			//--------------------------------------				
			Case cTypeMessage == EAI_MESSAGE_RESPONSE
				//Verifica tipo do evento Inclusao/Alteracao/Exclusao
				If Upper(AllTrim(oEAIObEt:getPropValue("ReceivedMessage"):getPropValue("Event"))) == 'DELETE'
					lDelete := .T.					
				Endif	

				If oEAIObEt:getHeaderValue("Transaction") !=  nil
					cName := oEAIObEt:getHeaderValue("Transaction")
				Endif
				If oEAIObEt:getHeaderValue("ProductName") !=  nil
					cMarca := Upper(oEAIObEt:getHeaderValue("ProductName"))
				Endif
				If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalId")[1]:getPropValue("Origin") != nil
					cValInt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalId")[1]:getPropValue("Origin")
				Endif
				If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalId")[1]:getPropValue("Destination") != nil
					cValExt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalId")[1]:getPropValue("Destination")
				Endif
				If !Empty(cValInt) .And. !Empty(cValExt)
					If Upper(Alltrim(cName)) == Alltrim(cMsgUnica)
						CFGA070MNT(cMarca, cAlias, cField, cValExt, cValInt, lDelete)
					Endif
				Endif
				
				
			//--------------------------------------
			//whois
			//--------------------------------------
			Case cTypeMessage == EAI_MESSAGE_WHOIS
				ofwEAIObj := '2.002'
		Endcase
																
	//--------------------------------------
	//envio mensagem
	//--------------------------------------		
	Case nTypeTrans == TRANS_SEND 

		oModel := FwModelActive()
		oModel:Activate()

		If oModel:GetOperation() == MODEL_OPERATION_DELETE
			cEvent := "delete"
		EndIf	

		oModel:DeActivate()	
		
		cValInt := IntUndExt(cEmpAnt, SAH->AH_FILIAL, SAH->AH_UNIMED, cVersao)[2]
		
		ofwEAIObj:Activate()
		ofwEAIObj:setEvent(cEvent)	
		
		ofwEAIObj:setprop("Code", RTrim(SAH->AH_UNIMED))
		ofwEAIObj:setprop("InternalId", cValInt)
		ofwEAIObj:setprop("Description", RTrim(SAH->AH_DESCPO))
		ofwEAIObj:setprop("ShortName", RTrim(SAH->AH_UMRES))
					
Endcase

Return { lRet, ofwEAIObj, cMsgUnica } 


//-------------------------------------------------------------------
/*/{Protheus.doc} geraCod
Monta codigo para o campo AH_UNIMED

@param   cCode Code vindo no XML de entrada

@author  Leandro Luiz da Cruz
@version P11
@since   25/09/2012
@return  cResult Variavel com o valor gerado
/*/
//-------------------------------------------------------------------
Static Function geraCod(cCode)
Local nX       := 0
Local nY       := 0
Local cResult  := ""
Local cAlias   := "SAH"
Local lEsgotou := .T.

For nX := 1 To Len(cCode)
	For nY := nX + 1 To Len(cCode)
		cResult := Upper(SubStr(cCode, nX, 1) + SubStr(cCode, nY, 1))

		If !SAH->(DbSeek(xFilial(cAlias) + cResult))
			lEsgotou := .F.
			nX := Len(cCode)
			nY := Len(cCode)
		EndIf
	Next nY
Next nX

If lEsgotou
	cResult := geraCod("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
EndIf

Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntUndExt
Monta o InternalID da Unidade de Medida de acordo com o código passado
no parâmetro.

@param   cEmpresa Código da empresa (Default cEmpAnt)
@param   cFil     Código da Filial (Default cFilAnt)
@param   cUnidMed Código da Unidade de Medida

@author  Totvs Cascavel
@version P12
@since   02/05/2018
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado.
         No segundo parâmetro uma variável string com o InternalID
         montado.

@sample  IntUndExt(,,'UN') irá retornar {.T.,'01| |UN'}
/*/
//-------------------------------------------------------------------
Static Function IntUndExt(cEmpresa, cFil, cUnidMed )

Local   aResult  := {}

Default cEmpresa := cEmpAnt
Default cFil     := xFilial('SAH') // Cadastro compartilhado

aAdd(aResult, .T.)
aAdd(aResult, cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cUnidMed))

Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntUndInt
Recebe um InternalID e retorna o código da Unidade de Medida.

@param   cInternalID InternalID recebido na mensagem.
@param   cRefer      Produto que enviou a mensagem

@author  Totvs Cascavel
@version P12
@since   02/05/2018
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado no de/para.
         No segundo parâmetro uma variável array com a empresa,
         filial e o Código da Unidade de Medida.

@sample  IntUndInt('01|01|UN') irá retornar {.T., {'01', '01', 'UN'}}
/*/
//-------------------------------------------------------------------
Static Function IntUndInt(cInternalID, cRefer )
Local   aResult  := {}
Local   aTemp    := {}
Local   cTemp    := ''
Local   cAlias   := 'SAH'
Local   cField   := 'AH_UNIMED'

cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)

If Empty(cTemp)
	aAdd(aResult, .F.)
	aAdd(aResult, STR0030 + AllTrim(cInternalID) + STR0031) //"Unidade de Medida " " não encontrada no de/para!"
Else
	aAdd(aResult, .T.)
	aTemp := Separa(cTemp, '|')
	aAdd(aResult, aTemp)
EndIf

Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntUndCEsp
Trata caracter especial no codigo da unidade de medida

@param   cCode		Codigo da unidade de medida

@author  Rodrigo M. Pontes
@version P11
@since   29/08/2017
@return  Codigo da unidade de medida convertido.

/*/
//-------------------------------------------------------------------

Static Function IntUndCEsp(cCode)

Local cRet		:= ""

cRet	:= StrTran(cCode,"¹","1")
cRet	:= StrTran(cCode,"²","2")
cRet	:= StrTran(cCode,"³","3")
cRet	:= Upper(cRet)

Return cRet