#Include 'PROTHEUS.CH
#Include 'FWADAPTEREAI.CH'   //Include para rotinas de integração com EAI
#Include 'FWMVCDEF.CH'       //Include para rotinas com MVC
#Include 'FISI048.CH'

Function FISI048(cXml, nTypeTrans, cTypeMessage, cVersion)
Local cError   := ""
Local cWarning := ""
Local cVersao  := ""
Local lRet     := .T.
Local cXmlRet  := ""
Local aRet     := {}
Private oXML   := Nil

//Mensagem de Entrada
If nTypeTrans == TRANS_RECEIVE
	If cTypeMessage == EAI_MESSAGE_BUSINESS .Or. cTypeMessage == EAI_MESSAGE_RESPONSE
		oXml := xmlParser(cXml, "_", @cError, @cWarning)
		
		If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
			// Versão da mensagem
			If Type("oXml:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .Or. !Empty(oXml:_TOTVSMessage:_MessageInformation:_version:Text)
				cVersao := StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
			Else
				lRet := .F.
				cXmlRet := STR0001 //"Versão da mensagem não informada!"
				Return {lRet, cXmlRet}
			EndIf
		Else
			lRet := .F.
			cXmlRet := STR0002 //"Erro no parser!"
			Return {lRet, cXmlRet}
		EndIf
		
		If cVersao == "1"
			aRet := v1000(cXml, nTypeTrans, cTypeMessage, oXml)
		Else
			lRet    := .F.
			cXmlRet := STR0003 //"A versão da mensagem informada não foi implementada!"
			Return {lRet, cXmlRet}
		EndIf
	ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
		aRet := v1000(cXml, nTypeTrans, cTypeMessage, oXml)
	Endif
EndIf

lRet    := aRet[1]
cXMLRet := aRet[2]

Return {lRet, cXmlRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} v1000
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de outros documentos (F100 - EFD Contribuicoes) 
utilizando o conceito de mensagem unica.

@param Caracter, cXML, Variavel com conteudo xml para envio/recebimento.
@param Numérico, nTypeTrans, Tipo de transacao. (Envio/Recebimento)
@param Caracter, cTypeMessage, Tipo de mensagem. (Business Type, WhoIs, etc)
@param Objeto, oXml, Objeto xml com a mensagem recebida.

@author Fabio V Santana
@version P11
@since 01/01/2015
@return Array, Array contendo o resultado da execucao e a mensagem Xml de retorno.
aRet[1] - (boolean) Indica o resultado da execução da função
aRet[2] - (caracter) Mensagem Xml para envio

@obs
O método irá retornar um objeto do tipo TOTVSBusinessEvent caso o tipo
da mensagem seja EAI_BUSINESS_EVENT ou um tipo TOTVSBusinessRequest
caso a mensagem seja do tipo TOTVSBusinessRequest.
O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------
Static Function v1000(cXml, nTypeTrans, cTypeMessage, oXml)
Local lRet          := .T.                       // Retorna se a execucao foi bem sucedida ou nao
Local cXmlRet       := ""                        // Xml de retorno da IntegDef
Local aMsgErro      := {}                        // Array com erro na validação do Model
Local nI            := 1                         // Contadores de uso geral
Local nX            := 1                         // Contadores de uso geral
Local cProduct      := ""                        // Marca, Referência (RM, PROTHEUS, DATASUL etc)
Local cValInt       := ""                        // Valor interno no Protheus
Local cValExt       := ""                        // Valor externo
Local cAlias        := "CF8"                     // Alias da tabela no Protheus
Local cField        := "CF8_CODIGO"              // Campo identificador no Protheus
Local oModel        := Nil                       // Model completo do fisa048
Local oModelCF8     := Nil                       // Model com a master apenas
Local oModelCF0     := Nil                       // Model com a master apenas
Local aDoc          := {}                        // Array com os valores recebidos
Local aItens        := {}                        // Posicao do Item
Local nPos          := 0
Local aAux          := {}                        // Array de uso geral
Local aAuxCF0       := {}                        // Array de uso geral
Local nOpcx         := 0                         // Operação realizada
Local cMsg          := ""

//Variaveis de Tags
Local cCode			:= ""
Local cOper     		:= "1"
Local cCliSupp 		:= ""
Local cItemCode 		:= ""
Local dOperDate 		:= CToD ("//")
Local dDataFim 		:= CToD ("//")
Local dDataCF0		:= CToD ("//")
Local cPisTax 		:= ""
Local cCofinsTax  	:= ""
Local cBCCode 		:= ""
Local cLedgerAcc		:= ""
Local cCostCenter 	:= ""
Local cClTable		:= ""
Local cProject		:= ""
Local cCnatre			:=	""
Local cGrpNc			:=	""
Local cDtFim			:= ""
Local cCliExt			:= ""
Local cCliInt			:= ""
Local cIteExt			:= ""
Local cIteInt			:= ""
Local cCenterExt		:= ""
Local cCenterInt		:= ""

//Arrays de Tags
Local aCliSupp		:= {}
Local aLedgerAcc		:= {}
Local aItemCode		:= {}
Local aClTable		:= {}
Local aCenterCode	:= {}

Private lMsErroAuto  := .F.

//Recebimento
If nTypeTrans == TRANS_RECEIVE
	If cTypeMessage == EAI_MESSAGE_BUSINESS
		// Verifica se o InternalId foi informado
		If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
			cValExt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
		Else
			lRet := .F.
			cXmlRet := STR0004 //"O código do InternalId é obrigatório!" 		
			Return {lRet, cXmlRet}
		EndIf
		
		// Verifica se a marca foi informada
		If Type("oXML:_TotvsMessage:_MessageInformation:_Product:_Name:Text") != "U" .And. !Empty(oXML:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
			cProduct := oXML:_TotvsMessage:_MessageInformation:_Product:_Name:Text
		Else
			lRet := .F.
			cXmlRet := STR0005 //"O Produto é obrigatório!"
			Return {lRet, cXmlRet}
		EndIf
		
		// Verifica se a filial atual é a mesma filial de inclusão do cadastro
		If FindFunction("IntChcEmp")
			aAux := IntChcEmp(oXml, cAlias, cProduct)
			If !aAux[1]
				lRet := aAux[1]
				cXmlRet := aAux[2]
				Return {lRet, cXmlRet}
			EndIf
		EndIf
		
		// Posiciona tabela CF8
		dbSelectArea(cAlias)
		CF8->(DbSetOrder(1)) // Filial + Codigo (CF8_FILIAL + CF8_CODIGO)
		
		// Carrega model com estrutura da tabela CF8
		oModel := FwLoadModel("FISA048")
		
		// Obtém o valor interno da tabela XXF (de/para)
		aAux := IntConInt(cValExt, cProduct, /*Versão*/)				
		
		// Se o evento é UPSERT
		If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
			If !aAux[1]
				// Inclusão
				oModel:SetOperation(MODEL_OPERATION_INSERT)
				
				nOpcx := 3
			Else				
				// Posiciona no registro encontrado
				cCode := aAux[2][3]

				If !CF8->(dbSeek(xFilial("CF8") + cCode))
					lRet := .F.
					cXMLRet := (STR0007 + " -> " + cCode) //"Registro não encontrado!"				
					Return {lRet, cXmlRet}
				EndIF
			
				// Alteração
				oModel:SetOperation(MODEL_OPERATION_UPDATE)
				
				nOpcx := 4
			EndIf
		
		ElseIf Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
			
			If aAux[1]
			
				// Posiciona no registro encontrado
				cCode := aAux[2][3]			

				If !CF8->(dbSeek(xFilial("CF8") + cCode))
					lRet := .F.
					cXMLRet := (STR0007 + " -> " + cCode) //"Registro não encontrado!"
					Return {lRet, cXmlRet}
				EndIF
				
				// Exclusão
				oModel:SetOperation(MODEL_OPERATION_DELETE)
				
				nOpcx := 5			
			Else
				
				lRet := .F.
				cXMLRet := (STR0007 + " -> " + cValExt) //"Registro não encontrado!"				
				Return {lRet, cXmlRet}
			
			EndIf
		Else
			lRet := .F.
			cXmlRet := STR0008 //"O evento informado é inválido"  			
			Return {lRet, cXmlRet}
		EndIf

		//-------------------------------------------------------------------
		// Model ativado neste trecho para obter o valor do campo CF8_CODIGO
		//-------------------------------------------------------------------
		oModel:Activate()
		oModelCF8 := oModel:GetModel("MODEL_CF8") // Model parcial da Master (CF8)
		oModelCF0 := oModel:GetModel("MODEL_CF0") // Model parcial da Master (CF0)

		cCode := oModelCF8:GetValue('CF8_CODIGO')

		If oModel:nOperation != MODEL_OPERATION_DELETE
			// Recebimento dos dados
			aAdd(aDoc, {"CF8_FILIAL", xFilial("CF8"), Nil})

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Tipo de Regime   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Regime:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Regime:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Regime:Text) > TamSX3("CF8_TPREG")[1]
					lRet := .F.
					cXmlRet := STR0009 + AllTrim(cValToChar(TamSX3("CF8_TPREG")[1])) + STR0010 //"O campo Tipo de Regime (CF8_TPREG) suporta", " caracteres" 					
					Return {lRet, cXmlRet}
				EndIf
				
				aAdd(aDoc, {"CF8_TPREG", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Regime:Text, Nil})
			Else
				lRet := .F.
				cXmlRet := STR0011 //"Campo obrigatório não informado - Tipo de Regime (CF8_TPREG)"				
				Return {lRet, cXmlRet}
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Indicador de Operacao  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OperIndicator:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OperIndicator:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OperIndicator:Text) > TamSX3("CF8_INDOPE")[1]
					lRet := .F.
					cXmlRet := STR0012 + AllTrim(cValToChar(TamSX3("CF8_INDOPE")[1])) + STR0010 //"O campo Indicador de Operação (CF8_INDOPE) suporta", " caracteres"  
					Return {lRet, cXmlRet}
				EndIf
				
				cOper := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OperIndicator:Text
				
				aAdd(aDoc, {"CF8_INDOPE", cOper , Nil})
			Else
				lRet := .F.
				cXmlRet := STR0013 //"Campo obrigatório não informado - Indicador de Operação (CF8_INDOPE)"				
				Return {lRet, cXmlRet}
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Data de Operacao       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OperDate:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OperDate:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OperDate:Text) > (TamSX3("CF8_DTOPER")[1]) + 2
					lRet := .F.
					cXmlRet := STR0014 + AllTrim(cValToChar(TamSX3("CF8_DTOPER")[1])) + STR0010 //"O campo Data de Operação (CF8_DTOPER) suporta", " caracteres"
					Return {lRet, cXmlRet}
				EndIf
				
				dOperDate := SToD(StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OperDate:Text,"-",""))						
				aAdd(aDoc, {"CF8_DTOPER", dOperDate , Nil})				
			Else
				lRet := .F.
				cXmlRet := STR0015 //"Campo obrigatório não informado - Data de Operação (CF8_DTOPER)"
				Return {lRet, cXmlRet}
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag CST de PIS  		     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PisTax:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PisTax:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PisTax:Text) > TamSX3("CF8_CSTPIS")[1]
					lRet := .F.
					cXmlRet := STR0016 + AllTrim(cValToChar(TamSX3("CF8_CSTPIS")[1])) + STR0010 //"O campo CST Pis (CF8_CSTPIS) suporta", " caracteres"
					Return {lRet, cXmlRet}
				EndIf
				
				cPisTax := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PisTax:Text
				cPisTax := Padr(SubStr(cPisTax,1,TamSx3("CF8_CSTPIS")[1]),TamSx3("CF8_CSTPIS")[1])
												
			 	SX5->(DbSetOrder(1) )
		    	If SX5->(MsSeek(xFilial("SX5") + "SX" + cPisTax ) )
		    		aAdd(aDoc, {"CF8_CSTPIS", cPisTax , Nil})
		    	Else
		    		lRet := .F.
					cXmlRet := STR0017 + cPisTax + STR0018 + " '" + xFilial("SX5") + " '" //"CST de PIS: " //" Não encontrado na base de dados da Filial:"
					Return {lRet, cXmlRet}
		    	EndIf
			Else
				lRet := .F.
				cXmlRet := STR0019 //"Campo obrigatório não informado - CST Pis (CF8_CSTPIS)"
				Return {lRet, cXmlRet}
			EndIf			

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag CST de COFINS ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CofinsTax:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CofinsTax:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CofinsTax:Text) > TamSX3("CF8_CSTCOF")[1]
					lRet := .F.
					cXmlRet := STR0020 + AllTrim(cValToChar(TamSX3("CF8_CSTCOF")[1])) + STR0010 //"O campo CST Cofins (CF8_CSTCOF) suporta", " caracteres"
					Return {lRet, cXmlRet}
				EndIf
																
				cCofinsTax := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CofinsTax:Text
				cCofinsTax := Padr(SubStr(cCofinsTax,1,TamSx3("CF8_CSTPIS")[1]),TamSx3("CF8_CSTPIS")[1])
												
			 	SX5->(DbSetOrder(1) )
		    	If SX5->(MsSeek(xFilial("SX5") + "SX" + cCofinsTax ) )
		    		aAdd(aDoc, {"CF8_CSTCOF", cCofinsTax , Nil})
		    	Else
		    		lRet := .F.
					cXmlRet := STR0021 + cCofinsTax + STR0018 + " '" + xFilial("SX5") + " '" //"CST de Cofins: ", " Não encontrado na base de dados da Filial:"
					Return {lRet, cXmlRet}
		    	EndIf
			Else
				lRet := .F.
				cXmlRet := STR0022 //"Campo obrigatório não informado - CST Cofins (CF8_CSTCOF)"
				Return {lRet, cXmlRet}
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tags nao obrigatorias  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Cliente / Fornecedor   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerVendorInternalID:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerVendorInternalID:Text)

				cCliExt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerVendorInternalID:Text

				If cOper == "0"
					cCliInt := CFGA070INT( cProduct, 'SA2', 'A2_COD', cCliExt )
				Else
					cCliInt := CFGA070INT( cProduct, 'SA1', 'A1_COD', cCliExt )
				EndIf

				If Empty(cCliInt)					
					lRet := .F.
					If cOper == "0"
						cXmlRet := STR0023 //"Fornecedor não encontrado no Protheus."
					Else
						cXmlRet := STR0024 //"Cliente não encontrado no Protheus."
					Endif
					
					Return {lRet, cXmlRet}
				EndIf

				aCliSupp := Separa(cCliInt, '|')

				If Len(AllTrim(aCliSupp[3])) + Len(AllTrim(aCliSupp[4])) > TamSX3("CF8_CLIFOR")[1] + TamSX3("CF8_LOJA")[1]
					lRet := .F.
					cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_CLIFOR")[1]+ TamSX3("CF8_LOJA")[1] )) + STR0010 //"O campo do Protheus suporta", " caracteres"  
					Return {lRet, cXmlRet}
				EndIf				
						
				cCliSupp := 	Padr(SubStr(aCliSupp[3],1,TamSx3("CF8_CLIFOR")[1]),TamSx3("CF8_CLIFOR")[1]) + ;
								Padr(SubStr(aCliSupp[4],1,TamSx3("CF8_LOJA")[1]),TamSx3("CF8_LOJA")[1])
				
				If cOper == "0"
					dbSelectArea("SA2")
					SA2->(dbSetOrder(1))	

					If 	SA2->(MsSeek(xFilial("SA2")+cCliSupp))					
						aAdd(aDoc, {"CF8_CLIFOR", aCliSupp[3], Nil})
						aAdd(aDoc, {"CF8_LOJA", aCliSupp[4], Nil})					
					Else					
						lRet := .F.
						cXmlRet := STR0026 + aCliSupp[3] + STR0018 + aCliSupp[1] + STR0027 //"Fornecedor: ", " não encontrado na base de dados da Filial: ", "Verifique o tipo de operação, ou o conteúdo da Tag CustomerVendor" 						
						Return {lRet, cXmlRet}										
					EndIf												
				Else
					dbSelectArea("SA1")
					SA1->(dbSetOrder(1))
					
					If 	SA1->(MsSeek(xFilial("SA1")+cCliSupp))					
						aAdd(aDoc, {"CF8_CLIFOR", aCliSupp[3], Nil})
						aAdd(aDoc, {"CF8_LOJA", aCliSupp[4], Nil})						
					Else					
						lRet := .F.
						cXmlRet := STR0028 + aCliSupp[3] + STR0018 + aCliSupp[1] + STR0027 //"Cliente ", " não encontrado na base de dados da Filial: ", "Verifique o tipo de operação, ou o conteúdo da Tag CustomerVendor" 						
						Return {lRet, cXmlRet}															
					EndIf																
				EndIf												

			ElseIF Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerVendorCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerVendorCode:Text)

				aCliSupp := Separa(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerVendorCode:Text, '|')

				If Len(aCliSupp[1]) + Len(aCliSupp[2]) > TamSX3("CF8_CLIFOR")[1] + TamSX3("CF8_LOJA")[1]
					lRet := .F.
					cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_CLIFOR")[1]+ TamSX3("CF8_LOJA")[1] )) + STR0010 //"O campo do Protheus suporta", " caracteres" 
					Return {lRet, cXmlRet}
				EndIf				
						
				cCliSupp := 	Padr(SubStr(aCliSupp[1],1,TamSx3("CF8_CLIFOR")[1]),TamSx3("CF8_CLIFOR")[1]) + ;
								Padr(SubStr(aCliSupp[2],1,TamSx3("CF8_LOJA")[1]),TamSx3("CF8_LOJA")[1])
				
				If cOper == "0"
					dbSelectArea("SA2")
					SA2->(dbSetOrder(1))	

					If 	SA2->(MsSeek(xFilial("SA2")+cCliSupp))					
						aAdd(aDoc, {"CF8_CLIFOR", aCliSupp[1], Nil})
						aAdd(aDoc, {"CF8_LOJA", aCliSupp[2], Nil})					
					Else					
						lRet := .F.					
						cXmlRet := STR0026 + aCliSupp[1] + STR0018 + xFilial("SA2") + STR0027 //"Fornecedor: ", " não encontrado na base de dados da Filial: ", "Verifique o tipo de operação, ou o conteúdo da Tag CustomerVendorCode"
						Return {lRet, cXmlRet}										
					EndIf												
				Else
					dbSelectArea("SA1")
					SA1->(dbSetOrder(1))
					
					If 	SA1->(MsSeek(xFilial("SA1")+cCliSupp))					
						aAdd(aDoc, {"CF8_CLIFOR", aCliSupp[1], Nil})
						aAdd(aDoc, {"CF8_LOJA", aCliSupp[2], Nil})						
					Else					
						lRet := .F.						
						cXmlRet := STR0028 + aCliSupp[1] + STR0018 + xFilial("SA1") + STR0027 //"Cliente ", " não encontrado na base de dados da Filial: ", "Verifique o tipo de operação, ou o conteúdo da Tag CustomerVendorCode"
						Return {lRet, cXmlRet}															
					EndIf																
				EndIf												
			EndIf	
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Codigo do Item         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ItemInternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ItemInternalId:Text)
								
				cIteExt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ItemInternalId:Text

				cIteInt := CFGA070INT( cProduct, 'SB1', 'B1_COD', cIteExt )

				If Empty(cIteInt)
					lRet := .F.
					cXmlRet := STR0029 //"Produto não encontrado no Protheus."					
					Return {lRet, cXmlRet}
				EndIf

				aItemCode := Separa(cIteInt, '|')
				
				If Len(AllTrim(aItemCode[3])) > TamSX3("CF8_ITEM")[1]
					lRet := .F.
					cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_ITEM")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres"					
					Return {lRet, cXmlRet}
				EndIf		
								
				cItemCode := 	Padr(SubStr(aItemCode[3],1,TamSx3("CF8_ITEM")[1]),TamSx3("CF8_ITEM")[1])
				
				dbSelectArea("SB1")
				SB1->(dbSetOrder(1))	

				If 	SB1->(MsSeek(xFilial("SB1")+cItemCode))					
					aAdd(aDoc, {"CF8_ITEM", aItemCode[3], Nil})					
				Else					
					lRet := .F.
					cXmlRet := STR0030 + aItemCode[3] + STR0018 + aItemCode[1] + STR0031 //"Item: ", " não encontrado na base de dados da Filial: ", "Verifique o conteúdo da Tag ItemCode" 					
					Return {lRet, cXmlRet}										
				EndIf												

			ElseIF Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text)
								
				aItemCode := Separa(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text, '|')
				
				If Len(aItemCode[1]) > TamSX3("CF8_ITEM")[1]
					lRet := .F.
					cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_ITEM")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres"					
					Return {lRet, cXmlRet}
				EndIf		
								
				cItemCode := 	Padr(SubStr(aItemCode[1],1,TamSx3("CF8_ITEM")[1]),TamSx3("CF8_ITEM")[1])
				
				dbSelectArea("SB1")
				SB1->(dbSetOrder(1))	

				If 	SB1->(MsSeek(xFilial("SB1")+cItemCode))					
					aAdd(aDoc, {"CF8_ITEM", aItemCode[1], Nil})					
				Else					
					lRet := .F.				
					cXmlRet := STR0030 + aItemCode[1] + STR0018 + xFilial("SB1") + STR0031 //"Item: ", " não encontrado na base de dados da Filial: ", "Verifique o conteúdo da Tag ItemCode"
					Return {lRet, cXmlRet}										
				EndIf												

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Valor de Operacao      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OperValue:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OperValue:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OperValue:Text) > TamSX3("CF8_VLOPER")[1]
					lRet := .F.
					cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_VLOPER")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres" 					
					Return {lRet, cXmlRet}
				EndIf
				
				aAdd(aDoc, {"CF8_VLOPER", Val( StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OperValue:Text, ",", "." ) ), Nil})
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Valor do Saldo	      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Balance:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Balance:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Balance:Text) > TamSX3("CF8_SALDO")[1]
					lRet := .F.
					cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_SALDO")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres" 					
					Return {lRet, cXmlRet}
				EndIf
				
				aAdd(aDoc, {"CF8_SALDO", Val( StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Balance:Text, ",", "." ) ), Nil})
			EndIf			

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Base de Pis            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PisBase:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PisBase:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PisBase:Text) > TamSX3("CF8_BASPIS")[1]
					lRet := .F.
					cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_BASPIS")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres" 
					Return {lRet, cXmlRet}
				EndIf
				
				aAdd(aDoc, {"CF8_BASPIS", Val( StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PisBase:Text, ",", ".") ), Nil})
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Base de Cofins         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PisAliquot:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PisAliquot:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PisAliquot:Text) > TamSX3("CF8_ALQPIS")[1]
					lRet := .F.
					cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_ALQPIS")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres" 					
					Return {lRet, cXmlRet}
				EndIf
				
				aAdd(aDoc, {"CF8_ALQPIS", Val( StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PisAliquot:Text, ",", ".") ), Nil})
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Valor de Pis           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PisValue:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PisValue:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PisValue:Text) > TamSX3("CF8_VALPIS")[1]
					lRet := .F.
					cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_VALPIS")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres" 
					Return {lRet, cXmlRet}
				EndIf
				
				aAdd(aDoc, {"CF8_VALPIS", Val( StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PisValue:Text, ",", ".") ), Nil})
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Base de Cofins         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CofinsBase:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CofinsBase:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CofinsBase:Text) > TamSX3("CF8_BASCOF")[1]
					lRet := .F.
					cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_BASCOF")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres" 
					Return {lRet, cXmlRet}
				EndIf
				
				aAdd(aDoc, {"CF8_BASCOF", Val( StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CofinsBase:Text, ",", ".") ), Nil})
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Aliquota de Cofins     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CofinsAliquot:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CofinsAliquot:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CofinsAliquot:Text) > TamSX3("CF8_ALQCOF")[1]
					lRet := .F.
					cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_ALQCOF")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres" 
					Return {lRet, cXmlRet}
				EndIf
				
				aAdd(aDoc, {"CF8_ALQCOF", Val( StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CofinsAliquot:Text, ",", ".") ), Nil})
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Valor de Cofins        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CofinsValue:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CofinsValue:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CofinsValue:Text) > TamSX3("CF8_VALCOF")[1]
					lRet := .F.
					cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_VALCOF")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres"  
					Return {lRet, cXmlRet}
				EndIf
				
				aAdd(aDoc, {"CF8_VALCOF", Val( StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CofinsValue:Text, ",", ".") ), Nil})
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Cod BC Credito         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BCCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BCCode:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BCCode:Text) > TamSX3("CF8_CODBCC")[1]
					lRet := .F.
					cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_CODBCC")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres" 
					Return {lRet, cXmlRet}
				EndIf
								
				cBCCode := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BCCode:Text
				cBCCode := Padr(SubStr(cBCCode,1,TamSx3("CF8_CODBCC")[1]),TamSx3("CF8_CODBCC")[1])											
												
			 	SX5->(DbSetOrder(1) )
		    	If SX5->(MsSeek(xFilial("SX5") + "MZ" + cBCCode ) )
		    		aAdd(aDoc, {"CF8_CODBCC", cBCCode , Nil})	
		    	Else		    	
		    		lRet := .F.
					cXmlRet := STR0032 + cBCCode + STR0018 + " '" + xFilial("SX5") + " '" //"Codigo BC credito: ", " Não encontrado na base de dados da Filial:"  
					Return {lRet, cXmlRet}		    			    	
		    	EndIf					

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Origem do Credito      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CredOrigin:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CredOrigin:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CredOrigin:Text) > TamSX3("CF8_INDORI")[1]
					lRet := .F.
					cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_INDORI")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres"
					Return {lRet, cXmlRet}
				EndIf
				
				aAdd(aDoc, {"CF8_INDORI", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CredOrigin:Text, Nil})
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Conta Contabil         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LedgerAccountInternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LedgerAccountInternalId:Text)
				
				cLedExt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LedgerAccountInternalId:Text
				cLedInt := CFGA070INT( cProduct, 'CT1', 'CT1_CONTA', cLedExt )

				If Empty(cLedInt)
					lRet := .F.
					cXmlRet := STR0055 //"Conta Contábil não encontrada no Protheus."					
					Return {lRet, cXmlRet}
				EndIf

				aLedgerAcc := Separa(cLedInt, '|')

				If Len(AllTrim(aLedgerAcc[3])) > TamSX3("CF8_CODCTA")[1]
					lRet := .F.
					cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_CODCTA")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres"   
					Return {lRet, cXmlRet}
				EndIf
														
				cLedgerAcc := 	Padr(SubStr(aLedgerAcc[3],1,TamSx3("CF8_CODCTA")[1]),TamSx3("CF8_CODCTA")[1])
				
				dbSelectArea("CT1")
				CT1->(dbSetOrder(1))	

				If 	CT1->(MsSeek(xFilial("CT1")+cLedgerAcc))					
					aAdd(aDoc, {"CF8_CODCTA", cLedgerAcc , Nil})				
				Else					
					lRet := .F.
					cXmlRet := STR0033 + aLedgerAcc[3] + STR0018 + aLedgerAcc[1] + STR0034 //"Conta Contábil: ", " não encontrada na base de dados da Filial: ", "Verifique o conteúdo da Tag LedgerAccount" 
					Return {lRet, cXmlRet}										
				EndIf
					
			ElseIf Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LedgerAccount:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LedgerAccount:Text)

				aLedgerAcc := Separa(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LedgerAccount:Text, '|')

				If Len(aLedgerAcc[1]) > TamSX3("CF8_CODCTA")[1]
					lRet := .F.
					cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_CODCTA")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres"  
					Return {lRet, cXmlRet}
				EndIf
														
				cLedgerAcc := 	Padr(SubStr(aLedgerAcc[1],1,TamSx3("CF8_CODCTA")[1]),TamSx3("CF8_CODCTA")[1])
				
				dbSelectArea("CT1")
				CT1->(dbSetOrder(1))	

				If 	CT1->(MsSeek(xFilial("CT1")+cLedgerAcc))					
					aAdd(aDoc, {"CF8_CODCTA", cLedgerAcc , Nil})				
				Else					
					lRet := .F.
					cXmlRet := STR0033 + aLedgerAcc[1] + STR0018 + xFilial("CT1") + STR0034 //"Conta Contábil: ", " não encontrada na base de dados da Filial: ", "Verifique o conteúdo da Tag LedgerAccount" 
					Return {lRet, cXmlRet}										
				EndIf	

			EndIf			

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Centro de Custo        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CostCenterInternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CostCenterInternalId:Text)
								
				cCenterExt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CostCenterInternalId:Text

				cCenterInt := CFGA070INT( cProduct, 'CTT', 'CTT_CUSTO', cCenterExt )

				If Empty(cCenterInt)
					lRet := .F.
					cXmlRet := STR0035 + cCenterExt + STR0018 + xFilial("CTT") + STR0036 //"Centro de Custo: ", " não encontrado na base de dados da Filial: ", "Verifique o conteúdo da Tag CostCenterInternalId" 			
					Return {lRet, cXmlRet}
				EndIf

				aCenterCode := Separa(cCenterInt, '|')
				
				If Len(AllTrim(aCenterCode[3])) > TamSX3("CF8_CODCCS")[1]
					lRet := .F.
					cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_CODCCS")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres"					
					Return {lRet, cXmlRet}
				EndIf		
								
				cCostCenter := 	Padr(SubStr(aCenterCode[3],1,TamSx3("CF8_CODCCS")[1]),TamSx3("CF8_CODCCS")[1])
				
				dbSelectArea("CTT")
				CTT->(dbSetOrder(1))	

				If 	CTT->(MsSeek(xFilial("CTT")+cCostCenter))					
					aAdd(aDoc, {"CF8_CODCCS", aCenterCode[3], Nil})					
				Else					
					lRet := .F.
					cXmlRet := STR0035 + aCenterCode[3] + STR0018 + aCenterCode[1] + STR0036 //"Centro de custo: ", " não encontrado na base de dados da Filial: ", "Verifique o conteúdo da Tag CostCenter" 					
					Return {lRet, cXmlRet}										
				EndIf	

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Centro de Custo        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			ElseIf Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CostCenterCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CostCenterCode:Text)

				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CostCenterCode:Text) > TamSX3("CF8_CODCCS")[1]
					lRet := .F.
					cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_CODCCS")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres"  
					Return {lRet, cXmlRet}
				EndIf

				cCostCenter := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CostCenterCode:Text
				cCostCenter := Padr(SubStr(cCostCenter,1,TamSx3("CF8_CODCCS")[1]),TamSx3("CF8_CODCCS")[1])
				
				dbSelectArea("CTT")
				CTT->(dbSetOrder(1))	

				If 	CTT->(MsSeek(xFilial("CTT")+cCostCenter))					
					aAdd(aDoc, {"CF8_CODCCS", cCostCenter , Nil})				
				Else					
					lRet := .F.
					cXmlRet := STR0035 + cCostCenter + STR0018 + xFilial("CTT") + STR0036 //"Centro de Custo: ", " não encontrado na base de dados da Filial: ", "Verifique o conteúdo da Tag CostCenter" 
					Return {lRet, cXmlRet}										
				EndIf	

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Descricao da Operacao  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OperDescription:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OperDescription:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OperDescription:Text) > TamSX3("CF8_DESCPR")[1]
					lRet := .F.
					cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_DESCPR")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres" 
					Return {lRet, cXmlRet}
				EndIf
				
				aAdd(aDoc, {"CF8_DESCPR", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OperDescription:Text, Nil})
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Tab Natureza de Receita³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ClTable:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ClTable:Text)

				aClTable := Separa(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ClTable:Text, '|')

				If Len(aClTable) >= 1
					If Len(aClTable[1]) > TamSX3("CF8_TNATRE")[1]
						lRet := .F.
						cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_TNATRE")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres"  
						Return {lRet, cXmlRet}
					EndIf
				
					cClTable := Padr(SubStr(aClTable[1],1,TamSx3("CF8_TNATRE")[1]),TamSx3("CF8_TNATRE")[1])
				Else				
					cClTable := Space(TamSx3("CF8_TNATRE")[1])				
				EndIf
				
				If Len(aClTable) >= 2				
					If Len(aClTable[2]) > TamSX3("CF8_CNATRE")[1]
						lRet := .F.
						cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_CNATRE")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres" 
						Return {lRet, cXmlRet}
					EndIf
										
					cCnatre := Padr(SubStr(aClTable[2],1,TamSx3("CF8_CNATRE")[1]),TamSx3("CF8_CNATRE")[1])
				Else
					cCnatre := Space(TamSx3("CF8_CNATRE")[1])
				EndIf

				If Len(aClTable) >= 3	
					If Len(aClTable[3]) > TamSX3("CF8_GRPNC")[1]
						lRet := .F.
						cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_GRPNC")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres"
						Return {lRet, cXmlRet}
					EndIf
	
					cGrpNc := Padr(SubStr(aClTable[3],1,TamSx3("CF8_GRPNC")[1]),TamSx3("CF8_GRPNC")[1])
				Else
					cGrpNc := Space(TamSx3("CF8_GRPNC")[1])
				EndIf

				If Len(aClTable) >= 4	
					If Len(aClTable[4]) > TamSX3("CF8_DTFIMN")[1] + 2
						lRet := .F.
						cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_DTFIMN")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres"  
						Return {lRet, cXmlRet}
					EndIf									
	
					aClTable[4] := CToD(SubStr(aClTable[4], 9, 2) + "-" + SubStr(aClTable[4], 6, 2) + "-" + SubStr(aClTable[4], 1, 4))
					cDtFim := Padr(SubStr(DtoS(aClTable[4]),1,TamSx3("CF8_DTFIMN")[1]),TamSx3("CF8_DTFIMN")[1])

				EndIF
				
				dbSelectArea("CCZ")
				CCZ->(dbSetOrder(1))	

				If 	CCZ->(MsSeek(xFilial("CCZ")+cClTable+cCnatre+cGrpNc+cDtFim))					
					aAdd(aDoc, {"CF8_TNATRE", cClTable , Nil})
					aAdd(aDoc, {"CF8_CNATRE", cCnatre , Nil})
					aAdd(aDoc, {"CF8_GRPNC", cGrpNc , Nil})			
					aAdd(aDoc, {"CF8_DTFIMN", If (Len(aClTable) >= 4 , aClTable[4],CToD ("//")) , Nil})				
				Else					
					lRet := .F.
					cXmlRet := STR0037 + aClTable[1] + STR0018 + xFilial("CCZ") + STR0038 //"Tabela de Natureza de Receitas: ", " não encontrado na base de dados da Filial: ", "Verifique o conteúdo da Tag ClTable"  
					Return {lRet, cXmlRet}										
				EndIf		
	
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Pis Cof Org Publico    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Calculate:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Calculate:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Calculate:Text) > TamSX3("CF8_SCORGP")[1]
					lRet := .F.
					cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_SCORGP")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres" 
					Return {lRet, cXmlRet}
				EndIf
				
				aAdd(aDoc, {"CF8_SCORGP", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Calculate:Text, Nil})
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Projeto                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EfdProject:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EfdProject:Text)

				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EfdProject:Text) > TamSX3("CF8_PROJ")[1]
					lRet := .F.
					cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_PROJ")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres" 
					Return {lRet, cXmlRet}
				EndIf
				
				cProject := 	oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EfdProject:Text
				cProject := 	Padr(SubStr(cProject,1,TamSx3("CF8_PROJ")[1]),TamSx3("CF8_PROJ")[1])
				
				dbSelectArea("AF8")
				AF8->(dbSetOrder(1))	

				If 	AF8->(MsSeek(xFilial("AF8")+cProject))					
					aAdd(aDoc, {"CF8_PROJ", cProject , Nil})				
				Else					
					lRet := .F.
					cXmlRet := STR0039 + cProject + STR0018 + xFilial("AF8") + STR0040 //"Código do projeto: ", " não encontrado na base de dados da Filial: ", "Verifique o conteúdo da Tag ProjectCode" 
					Return {lRet, cXmlRet}										
				EndIf	

			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Cons Receita Bruto     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GrossIncome:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GrossIncome:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GrossIncome:Text) > TamSX3("CF8_RECBRU")[1]
					lRet := .F.
					cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_RECBRU")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres"  
					Return {lRet, cXmlRet}
				EndIf
				
				aAdd(aDoc, {"CF8_RECBRU", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GrossIncome:Text, Nil})
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tag Participante           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Participator:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Participator:Text)
				If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Participator:Text) > TamSX3("CF8_PART")[1]
					lRet := .F.
					cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF8_PART")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres" 
					Return {lRet, cXmlRet}
				EndIf
				aAdd(aDoc, {"CF8_PART", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Participator:Text, Nil})
			EndIf
		EndIf
		
		If oModel:nOperation != MODEL_OPERATION_DELETE

		// Trata os itens recebidos
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Movement") != "U" .And. Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Movement:_ListOfItens") != "U"
	
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Movement:_ListOfItens") != "A"
					XmlNode2Arr(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Movement:_ListOfItens, "_ListOfItens")
				EndIf
				
				For nI := 1 To Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Movement:_ListOfItens)
	
					aAdd(aItens, {})
					nPos	:=	Len (aItens)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Tag Data da Baixa          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	         	
	          	If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Movement:_ListOfItens["+cValToChar(nI)+"]:_Writeoffdate:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Movement:_ListOfItens[nI]:_Writeoffdate:Text)
						If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Movement:_ListOfItens[nI]:_Writeoffdate:Text) > TamSX3("CF0_DATA")[1]+2
							lRet := .F.
							cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF0_DATA")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres"  
							Return {lRet, cXmlRet}
						EndIf
	
						dDataCF0 := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Movement:_ListOfItens[nI]:_Writeoffdate:Text
	            		dDataCF0 := CToD(SubStr(dDataCF0, 9, 2) + "-" + SubStr(dDataCF0, 6, 2) + "-" + SubStr(dDataCF0, 1, 4))
	
						aAdd(aItens[nPos], {"CF0_DATA", dDataCF0 , Nil})
	
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Tag Valor Recebido         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
	          	If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Movement:_ListOfItens["+cValToChar(nI)+"]:_ReceiptValue:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Movement:_ListOfItens[nI]:_ReceiptValue:Text)
						If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Movement:_ListOfItens[nI]:_ReceiptValue:Text) > TamSX3("CF0_RECVLR")[1]
							lRet := .F.
							cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF0_RECVLR")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres" 
							Return {lRet, cXmlRet}
						EndIf
				
						aAdd(aItens[nPos], {"CF0_RECVLR", Val( StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Movement:_ListOfItens[nI]:_ReceiptValue:Text, ",", ".") ), Nil})
	
					EndIf					
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Tag Valor Recebido BC      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	          	If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Movement:_ListOfItens["+cValToChar(nI)+"]:_CBReceiptValue:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Movement:_ListOfItens[nI]:_CBReceiptValue:Text)
						If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Movement:_ListOfItens[nI]:_CBReceiptValue:Text) > TamSX3("CF0_RECBAS")[1]
							lRet := .F.
							cXmlRet := STR0025 + AllTrim(cValToChar(TamSX3("CF0_RECBAS")[1])) + STR0010 //"O campo do Protheus suporta", " caracteres" 
							Return {lRet, cXmlRet}
						EndIf
				
						aAdd(aItens[nPos], {"CF0_RECBAS", Val( StrTran(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Movement:_ListOfItens[nI]:_CBReceiptValue:Text, ",", ".") ), Nil})
	
					EndIf              	
	
					If lRet
						aAdd(aItens[nPos], {"CF0_CODIGO", cCode ,Nil})	
						aAdd(aItens[nPos], {"CF0_SEQ",STRZERO(nI,2),Nil})				
					EndIf
											
				Next nI
				
			EndIf			
		EndIf

		// Obtém a estrutura de dados
		aAux := oModelCF8:GetStruct():GetFields()
		aAuxCF0 := oModelCF0:GetStruct():GetFields()
					
		For nI := 1 To Len(aDoc)
			// Verifica se os campos passados existem na estrutura do modelo
			If aScan(aAux, {|x| AllTrim(x[3]) == AllTrim(aDoc[nI][1])}) > 0
				// É feita a atribuição do dado ao campo do Model
				If ValType(aDoc[nI][2]) == "C"
					If !oModel:SetValue('MODEL_CF8', aDoc[nI][1], AllTrim(aDoc[nI][2])) .And. (oModel:nOperation != MODEL_OPERATION_UPDATE)
						lRet := .F.
						cXmlRet := STR0041 + AllToChar(aDoc[nI][2]) + STR0042 + aDoc[nI][1] + "." //"Não foi possível atribuir o valor ", " ao campo: "
						Return {lRet, cXmlRet}									
					EndIf	
				ElseIf !oModel:SetValue('MODEL_CF8', aDoc[nI][1], aDoc[nI][2])  .And. (oModel:nOperation != MODEL_OPERATION_UPDATE)
					lRet := .F.
					cXmlRet := STR0041 + AllToChar(aDoc[nI][2]) + STR0042 + aDoc[nI][1] + "." //"Não foi possível atribuir o valor ", " ao campo: "
					Return {lRet, cXmlRet}														
				EndIf
			EndIf
		Next nI

		//Deleta as linhas existentes se for alteracao
		If nOpcx == 4 
			For nI := 1 to oModel:GetModel( 'MODEL_CF0' ):Length()
				oModel:GetModel( 'MODEL_CF0' ):GoLine(nI)
				oModel:GetModel( 'MODEL_CF0' ):DeleteLine()
			Next nI
		EndIf

		nI := 0				
		For nI := 1 To Len(aItens)
			
			If nI > 1 .Or. nOpcx == 4 
				oModel:GetModel( "MODEL_CF0" ):AddLine()
			EndIf
						
			For nX := 1 To Len(aItens[nI]) 
				// Verifica se os campos passados existem na estrutura do modelo
				If aScan(aAuxCF0, {|x| AllTrim(x[3]) == AllTrim(aItens[nI][nX][1])}) > 0
					// É feita a atribuição do dado ao campo do Model
					If !oModel:SetValue('MODEL_CF0', aItens[nI][nX][1], aItens[nI][nX][2]) .And. ( oModel:nOperation != MODEL_OPERATION_UPDATE)
						lRet := .F.
						cXmlRet := STR0041 + AllToChar(aItens[nI][nX][2]) + STR0042 + aItens[nI][nX][1] + "." //"Não foi possível atribuir o valor ", " ao campo: "
						Return {lRet, cXmlRet}				
					EndIf
				EndIf
			Next nX	
		Next nI			

		// Se os dados não são válidos
		If !oModel:VldData()
			// Obtém o log de erros
			aMsgErro := oModel:GetErrorMessage()
			
			cXmlRet := STR0043 + AllToChar(aMsgErro[6]) + CRLF //"Mensagem do erro: "
			cXmlRet += STR0044 + AllToChar(aMsgErro[7]) + CRLF //"Mensagem da solução: "
			cXmlRet += STR0045 + AllToChar(aMsgErro[8]) + CRLF //"Valor atribuído: "
			cXmlRet += STR0046 + AllToChar(aMsgErro[9]) + CRLF //"Valor anterior: "
			cXmlRet += STR0047 + AllToChar(aMsgErro[1]) + CRLF //"Id do formulário de origem: "
			cXmlRet += STR0048 + AllToChar(aMsgErro[2]) + CRLF //"Id do campo de origem: "
			cXmlRet += STR0049 + AllToChar(aMsgErro[3]) + CRLF //"Id do formulário de erro: "
			cXmlRet += STR0050 + AllToChar(aMsgErro[4]) + CRLF //"Id do campo de erro: "
			cXmlRet += STR0051 + AllToChar(aMsgErro[5]) //"Id do erro: "
			
			lRet := .F.
			Return {lRet, cXmlRet}
		Else
			// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
			oModel:CommitData()
		EndIf

		// Obtém o InternalId
		cValInt := IntConExt(/*Empresa*/, /*Filial*/, cCode, /*Versão*/)[2]
		
		// Se o evento é diferente de delete
		If oModel:nOperation != MODEL_OPERATION_DELETE
			// Grava o registro na tabela XXF (de/para)
			CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F.)
			ConfirmSX8()
		Else
			// Exclui o registro na tabela XXF (de/para)
			CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T.)
		EndIf
		
		// Monta o XML de retorno
		cXMLRet := "<ListOfInternalId>"
		cXMLRet +=     "<InternalId>"
		cXMLRet +=         "<Name>" + 'OtherDocumentsF100' + "</Name>"
		cXMLRet +=         "<Origin>" + cValExt + "</Origin>"
		cXMLRet +=         "<Destination>" + cValInt + "</Destination>"
		cXMLRet +=     "</InternalId>"
		cXMLRet += "</ListOfInternalId>"

	ElseIf cTypeMessage == EAI_MESSAGE_WHOIS // Recebimento da WhoIs
		cXmlRet := "1.000"
	EndIf
	
EndIf

Return {lRet, cXmlRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} IntConExt
Monta o InternalID da Movimentação de acordo com o código
passado no parâmetro.

@param Caracter, cEmpresa, Código da empresa (Default cEmpAnt)
@param Caracter, cFil, Código da Filial (Default cFilAnt)
@param Caracter, cCodigo, Código da Movimentação
@param Caracter, cVersao, Versão da mensagem única (Default 2.000)

@author Fabio V Santana
@version P11
@since 05/01/2015
@return  Array, Array contendo no primeiro parâmetro uma variável
lógica indicando se o registro foi encontrado.
No segundo parâmetro uma variável string com o InternalID
montado.

@sample
IntConExt(, , '001') irá retornar {.T., '01|01|001'}
/*/
//-------------------------------------------------------------------
Static Function IntConExt(cEmpresa, cFil, cCodigo, cVersao)
   Local   aResult  := {}
   Default cEmpresa := cEmpAnt
   Default cFil     := xFilial('CF8')
   Default cVersao  := '1.000'

   If cVersao == '1.000'
      aAdd(aResult, .T.)
      aAdd(aResult, cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cCodigo))
   Else
      aAdd(aResult, .F.)
      aAdd(aResult, STR0052 + Chr(10) + STR0053 + "1.000" ) //"Versão da rotina não suportada.", "As versões suportadas são: "
   EndIf
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntConInt
Recebe um InternalID e retorna o código da Movimentação.

@param Caracter, cInternalID, InternalID recebido na mensagem.
@param Caracter, cRefer, Produto que enviou a mensagem
@param Caracter, cVersao, Versão da mensagem única (Default 2.000)

@author Fabio V Santana
@version P11
@since 05/01/2015
@return Array, Array contendo no primeiro parâmetro uma variável
lógica indicando se o registro foi encontrado no de/para.
No segundo parâmetro uma variável array com a empresa,
filial e o Código da Movimentação.

@sample
IntConInt('01|01|001') irá retornar {.T., {'01', '01', '001'}}
/*/
//-------------------------------------------------------------------
Static Function IntConInt(cInternalID, cRefer, cVersao)
   Local   aResult  := {}
   Local   aTemp    := {}
   Local   cTemp    := ''
   Local   cAlias   := 'CF8'
   Local   cField   := 'CF8_CODIGO'
   Default cVersao  := '1.000'

   cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)
   
   If Empty(cTemp)
      aAdd(aResult, .F.)
      aAdd(aResult, STR0054 + " -> " + cInternalID) //"Registro não encontrado no de/para!"
   Else
      If cVersao == '1.000'
         aAdd(aResult, .T.)
         aTemp := Separa(cTemp, '|')
         aAdd(aResult, aTemp)
      Else
         aAdd(aResult, .F.)
         aAdd(aResult, STR0052 + Chr(10) + STR0053 + "1.000") //"Versão da rotina não suportada.", "As versões suportadas são: "
      EndIf
   EndIf
Return aResult
