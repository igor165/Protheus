#INCLUDE "Protheus.ch"
#INCLUDE "FwAdapterEAI.ch"
#INCLUDE "FwMvcDef.ch"
#INCLUDE "CTBI800A.ch"

Static cMensagem := "ManagerialAccountingEntity"

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBI800A
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de conta gerencial utilizando o conceito de mensagem unica.
A conta gerencial é um entidade contábil que no protheus será representado por uma entidade adicional, informada
pelo usuário no parâmetro MV_CTBCGER

@param   cXML          Variavel com conteudo xml para envio/recebimento.
@param   cTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Alvaro Camillo Neto
@version P12.1.8
@since   14/09/2015
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execução da função
         aRet[2] - (caracter) Mensagem Xml para envio
/*/
//------------------------------------------------------------------------------------
Function CTBI800A(cXml, cTypeTrans, cTypeMessage, cVersion, cTransac)

Local aRet     := {}
Local lRet     := .T.
Local cXmlRet  := ""

If cTypeMessage == EAI_MESSAGE_WHOIS
	cXmlRet := "1.000|1.001"
Else
	If cVersion = "1."
		aRet    := v1000(cXml, cTypeTrans, cTypeMessage)
		lRet    := aRet[1]
		cXmlRet := aRet[2]
	Else
		lRet    := .F.
		cXmlRet := STR0003 // "A versão da mensagem informada não foi implementada!"
	EndIf
EndIf

Return {lRet, cXmlRet, cMensagem}

//-------------------------------------------------------------------
/*/{Protheus.doc} v1000
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de conta gerencial utilizando o conceito de mensagem unica.
A conta gerencial é um entidade contábil que no protheus será representado por uma entidade adicional, informada
pelo usuário no parâmetro MV_CTBCGER

@param   cXML          Variavel com conteudo xml para envio/recebimento.
@param   cTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Alvaro Camillo Neto
@version P12.1.8
@since   14/09/2015
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execução da função
         aRet[2] - (caracter) Mensagem Xml para envio
/*/
//------------------------------------------------------------------------------------
Static Function v1000(cXml, cTypeTrans, cTypeMessage)

Local lRet               := .T.
Local cXmlRet            := ""
Local cValInt            := ""
Local cValExt            := ""
Local cProduct           := ""
Local cAlias             := "CV0"
Local cField             := "CV0_CODIGO"
Local cEvent             := "upsert"
Local nCount             := 0
Local aErroAuto          := {}
Local cError             := ""
Local cWarning           := ""
Local xAux               := Nil
Local cXMLOri            := ""
Local cEntGer            := SuperGetMV("MV_CTBCGER",.F.,"")
Local cPlano             := ""
Local cCodigo            := ""

Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T.
Private oXml800A
Private oXMLItem
Private oXMLLista

CT0->(dbSetOrder(1)) // CT0_FILIAL+CT0_ID
CV0->(dbSetOrder(1)) // CV0_FILIAL+CV0_PLANO+CV0_CODIGO

If lRet
	If Empty(cEntGer) .Or. !CT0->(dbSeek(xFilial("CT0") + cEntGer))
		lRet    := .F.
		cXmlRet := STR0006 // "A entidade selecionada no parametro MV_CTBCGER não está cadastrada, verificar cadastro de entidades adicionais"
	Else
		cPlano := cEntGer
	EndIf
EndIf

If lRet
	If cTypeTrans == TRANS_RECEIVE
		oXml800A := xmlParser(cXml, "_", @cError, @cWarning)
		If oXml800A = Nil .or. !Empty(cError) .or. !Empty(cWarning)
			lRet    := .F.
			cXmlRet := STR0002 + CRLF + cError // "Erro no parser!"
		EndIf

		If !lRet
			// Não faz nada.
		ElseIf cTypeMessage == EAI_MESSAGE_BUSINESS
			// Verifica se a marca foi informada
			If Type("oXml800A:_TotvsMessage:_MessageInformation:_Product:_Name:Text") != "U" .And. ;
					!Empty(oXml800A:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
				cProduct :=  oXml800A:_TotvsMessage:_MessageInformation:_Product:_Name:Text
			Else
				lRet    := .F.
				cXmlRet := STR0007 // "O produto é obrigatório!"
			EndIf

			If lRet .and. XmlChildEx( oXml800A:_TOTVSMessage:_BusinessMessage:_BusinessContent, '_LISTOFMANAGERIALACCOUNTINGENTITY') <> Nil .AND. ;
					XmlChildEx( oXml800A:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfManagerialAccountingEntity, '_MANAGERIALACCOUNTINGENTITY') <> Nil

				oXMLLista := oXml800A:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfManagerialAccountingEntity:_ManagerialAccountingEntity

				//Se for mais de um linha de lançamento, então faz um loop no array de objetos de nós
				If Type('oXMLLista') == 'A'
					cXmlRetAux	:= ""
					cXmlRet 	:= ""
					Begin Transaction

						For nCount := 1 To Len(oXMLLista)
							aAux 		:= {}
							oXMLItem	:= oXMLLista[nCount]


							// Verifica se o InternalId foi informado
							If lRet .And. Type("oXMLItem:_InternalId:Text") != "U" .And. !Empty(oXMLItem:_InternalId:Text)
								cValExt := oXMLItem:_InternalId:Text
							Else
								lRet    := .F.
								cXmlRet := STR0008 // "O InternalId é obrigatório!"
							EndIf

							//Pegando o Plano Contábil
							If lRet .And. Type("oXMLItem:_AccountingPlan:Text") != "U" .And. !Empty(oXMLItem:_AccountingPlan:Text)
								cPlano := oXMLItem:_AccountingPlan:Text
							EndIf

							If lRet .And. Type("oXMLItem:_Code:Text") != "U" .And. !Empty(oXMLItem:_Code:Text)
								cCodigo := oXMLItem:_Code:Text
							Else
								lRet    := .F.
								cXmlRet := STR0009 // "O código é obrigatório!"
							EndIf

							// Obtém o valor interno da tabela XXF (de/para)
							xAux := IntGerInt( cValExt, cProduct, "1.000")

							If xAux[1]
								cValInt := xAux[2, 2] + xAux[2, 3] + xAux[2, 4]
							Else
								cValInt := cCodigo
							EndIf

							If lRet
								If Upper(Alltrim(oXml800A:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)) == "UPSERT"
									If !Empty( cValInt )
										If CV0->(dbSeek(cValInt))
											nOpcExec:= 4
										Else
											nOpcExec:= 3
										EndIf
									Else
										nOpcExec:= 3
									EndIf
								Else
									If !Empty( cValInt )
										CV0->(dbSeek(cValInt))
										//Exclui quando vem de outro ERP
										CFGA070Mnt(, "CV0", "CV0_CODIGO",, cValInt, .T. )  // Deleta o XXF
									EndIf
									nOpcExec:= 5
								EndIf

								aCV0proc	:= UPSERTCV0( nOpcExec, cProduct, cPlano, cValExt,cValInt)
								lRet		:= aCV0proc[1]

								If !lRet
									cXmlRet := aCV0proc[2]
								Else
									cXmlRetAux += aCV0proc[2]
								EndIf
							EndIf
							If !lRet
								DisarmTransaction()
								Exit
							EndIf
						Next nCount

					End Transaction

					If lRet
						cXmlRet := "<ListOfInternalId>"
						cXmlRet += cXmlRetAux
						cXmlRet += "</ListOfInternalId>"
					EndIf
				Else
					cXmlRetAux	:= ""
					cXmlRet 	:= ""
					Begin Transaction

						aAux 		:= {}
						oXMLItem	:= oXMLLista

						// Verifica se o InternalId foi informado
						If lRet .And. Type("oXMLItem:_InternalId:Text") != "U" .And. !Empty(oXMLItem:_InternalId:Text)
							cValExt := oXMLItem:_InternalId:Text
						Else
							lRet    := .F.
							cXmlRet := STR0008 // "O InternalId é obrigatório!"
						EndIf

						//Pegando o Plano Contábil
						If lRet .And. Type("oXMLItem:_AccountingPlan:Text") != "U" .And. !Empty(oXMLItem:_AccountingPlan:Text)
							cPlano := oXMLItem:_AccountingPlan:Text
						EndIf

						If lRet .And. Type("oXMLItem:_Code:Text") != "U" .And. !Empty(oXMLItem:_Code:Text)
							cCodigo := oXMLItem:_Code:Text
						Else
							lRet    := .F.
							cXmlRet := STR0009 // "O código é obrigatório!"
						EndIf

						// Obtém o valor interno da tabela XXF (de/para)
						xAux := IntGerInt( cValExt, cProduct, "1.000")

						If xAux[1]
							cValInt := xAux[2, 2] + xAux[2, 3] + xAux[2, 4]
						Else
							cValInt := cCodigo
						EndIf

						If lRet
							If Upper(Alltrim(oXml800A:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)) == "UPSERT"
								If !Empty( cValInt )
									If CV0->(dbSeek(cValInt))
										nOpcExec:= 4
									Else
										nOpcExec:= 3
									EndIf
								Else
									nOpcExec:= 3
								EndIf
							Else
								If !Empty( cValInt )
									CV0->(dbSeek(cValInt))
									//Exclui quando vem de outro ERP
									CFGA070Mnt(, "CV0", "CV0_CODIGO",, cValInt, .T. )  // Deleta o XXF
								EndIf
								nOpcExec:= 5
							EndIf

							aCV0proc	:= UPSERTCV0( nOpcExec, cProduct, cPlano, cValExt,cValInt)
							lRet		:= aCV0proc[1]

							If !lRet
								cXmlRet := aCV0proc[2]
							Else
								cXmlRetAux += aCV0proc[2]
							EndIf
						EndIf
						If !lRet
							DisarmTransaction()
						EndIf
					End Transaction

					If lRet
						cXmlRet := "<ListOfInternalId>"
						cXmlRet	+= cXmlRetAux
						cXmlRet += "</ListOfInternalId>"
					EndIf
				EndIf
			EndIf

		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE

			// Se não houve erros na resposta
			If Upper(oXml800A:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
				// Verifica se a marca foi informada
				If Type("oXml800A:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. ;
						!Empty(oXml800A:_TOTVSMessage:_MessageInformation:_Product:_name:Text)

					cProduct := oXml800A:_TOTVSMessage:_MessageInformation:_Product:_name:Text
				Else
					lRet    := .F.
					cXmlRet := STR0013 + "|" // "Erro no retorno. O Product é obrigatório!"
				EndIf

				// Se não for array e existir, transforma a estrutura em array
				cEvent := Type("oXml800A:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId")
				If lRet .and. cEvent <> "U" .And. cEvent <> "A"
					// Transforma em array
					XmlNode2Arr(oXml800A:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId, "_InternalId")

					// Verifica se o código interno foi informado
					If Type("oXml800A:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Origin:Text") != "U" .And. ;
							!Empty(oXml800A:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Origin:Text)

						cValInt := oXml800A:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Origin:Text
					Else
						lRet    := .F.
						cXmlRet := STR0014 // "Erro no retorno. O OriginalInternalId é obrigatório!"
					EndIf

					// Verifica se o código externo foi informado
					If lRet .and. Type("oXml800A:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Destination:Text") != "U" .And. ;
							!Empty(oXml800A:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Destination:Text)

						cValExt := oXml800A:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Destination:Text
					Else
						lRet    := .F.
						cXmlRet := STR0015 // "Erro no retorno. O DestinationInternalId é obrigatório"
					EndIf

					If lRet
						// Obtém a mensagem original enviada
						If Type("oXml800A:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text") != "U" .And. !Empty(oXml800A:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text)
							cXMLOri := oXml800A:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text
						EndIf

						//Faz o parse do XML em um objeto
						oXml800AOri := XmlParser(cXMLOri, "_", @cError, @cWarning)

						//Se não houve erros no parse
						If oXml800AOri != Nil .And. Empty(cError) .And. Empty(cWarning)
							If !Empty( cProduct ) .And. !Empty( cValInt ) .And. !Empty( cValExt )
								If Upper(oXml800AOri:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
									CFGA070Mnt( cProduct, cAlias, cField, cValExt, cValInt, .F.,1)
								ElseIf Upper(oXml800AOri:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
									CFGA070Mnt( cProduct, cAlias, cField, cValExt, cValInt, .T.,1)
								EndIf
							Endif
						EndIf
					EndIf
				EndIf
			Else
				// Se não for array
				If Type("oXml800A:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message") != "A"
					// Transforma em array
					XmlNode2Arr(oXml800A:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
				EndIf

				// Percorre o array para obter os erros gerados
				For nCount := 1 To Len(oXml800A:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
					cError := oXml800A:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text + "|"
				Next nCount

				lRet    := .F.
				cXmlRet := cError
			EndIf
		EndIf

	ElseIf cTypeTrans == TRANS_SEND

		//Enviar o Plano conforme CV0_PLANO
		cPlano := CV0->CV0_PLANO
		CT0->(dbSetOrder(1)) // CT0_FILIAL+CT0_ID
		CT0->(DbSeek(FWxFilial("CT0") + CV0->CV0_PLANO))

		cValInt := IntGerExt(, CV0->CV0_FILIAL, cPlano, _NoTags( RTrim( CV0->CV0_CODIGO ) ), "1.000")[2]

		If !Inclui .And. !Altera
			cEvent  := 'delete'
			CFGA070MNT( , "CV0", "CV0_CODIGO", , cValInt, .T. )
		EndIf

		cXmlRet := '<BusinessEvent>'
		cXmlRet += ' <Entity>' + cMensagem + '</Entity>'
		cXmlRet += ' <Event>' + cEvent + '</Event>' //variável upsert para atualização ou deleção
		cXmlRet += ' <Identification>'
		cXmlRet += '  <key name="InternalId">' + cValInt + '</key>'
		cXmlRet += ' </Identification>'
		cXmlRet += '</BusinessEvent>'
		cXmlRet += '<BusinessContent>'
		cXmlRet += ' <CompanyId>' + cEmpAnt + '</CompanyId>'
		cXmlRet += ' <BranchId>' + cFilAnt + '</BranchId>'
		cXmlRet += ' <CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
		cXmlRet += ' <ListOfManagerialAccountingEntity>'
		cXmlRet += '  <ManagerialAccountingEntity>'
		cXmlRet += '   <AccountingPlan>' + _NoTags( AllTrim( CV0->CV0_PLANO ) ) + '</AccountingPlan>'
		cXmlRet += '   <Code>' + _NoTags( AllTrim( CV0->CV0_CODIGO ) ) + '</Code>'
		cXmlRet += '   <InternalId>' + cValInt + '</InternalId>'
		cXmlRet += '   <Description>' + _NoTags( AllTrim( CV0->CV0_DESC ) ) + '</Description>'
		cXmlRet += '   <PostingNature>' + _NoTags( AllTrim( CV0->CV0_NORMAL ) ) + '</PostingNature>'
		cXmlRet += '   <AnalyticalOrSynthetic>' + _NoTags( AllTrim( CV0->CV0_CLASSE ) ) + '</AnalyticalOrSynthetic>'
		cXmlRet += '   <ActiveOrInactive>' + If(CV0->CV0_BLOQUE == '1', '2', '1') + '</ActiveOrInactive>'
		cXmlRet += '   <TopCode>' + _NoTags( AllTrim( CV0->CV0_ENTSUP ) ) + '</TopCode>'
		cXmlRet += '  </ManagerialAccountingEntity>'
		cXmlRet += ' </ListOfManagerialAccountingEntity>'
		cXmlRet += '</BusinessContent>'
	EndIf
Endif

Return {lRet, cXmlRet}


//-------------------------------------------------------------------
/*/{Protheus.doc} UPSERTCV0
Chamada da função de inclusao de entidade contábil


@author  Alvaro Camillo Neto
@version P12.1.8
@since   14/09/2015
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execução da função
         aRet[2] - (caracter) Mensagem Xml para envio
/*/
//------------------------------------------------------------------------------------
Static Function UPSERTCV0( nOpcExec, cMarca ,cPlano, cValExt,cValInt )

Local aErroAuto := {}
Local nCount	:= 0
Local lRet		:= .T.
Local aCab		:= {}
Local cXmlRet	:= ' '
Local aArea		:= GetArea()
Local cConta	:= ' '
Local cAlias	:= 'CV0'
Local cField	:= 'CV0_CODIGO'

Private lMsErroAuto 	:= .F.
Private lMsHelpAuto 	:= .T.
Private lAutoErrNoFile 	:= .T.

If nOpcExec == 3
	If Type("oXMLItem:_CODE:TEXT") == "C"
		cConta := SubStr(oXMLItem:_Code:Text,1,TamSX3("CV0_CODIGO")[1])
		cConta := LimpText(cConta) //Retira mascara
		While .T.
			If CV0->(DbSeek(xFilial("CV0")+cPlano+cConta))
				cConta:=GetSXENum("CV0","CV0_CODIGO")
			Else
				Exit
			EndIf
		EndDo
	EndIf
Else
	aChave := STRTOKARR(cValExt,"|")
	cConta := aChave[Len(aChave)]
EndIf

aAdd( aCab, { "CV0_PLANO", cPlano, Nil })
aAdd( aCab, { "CV0_CODIGO", cConta, Nil })

cItem := CtbCV0Item(cPlano,cConta,nOpcExec)
AADD(aCab , {"CV0_ITEM",cItem,NIL})

If Type("oXMLItem:_DESCRIPTION:TEXT") <> "U"
	AADD(aCab , {"CV0_DESC"		,oXMLItem:_Description:Text	,NIL})
EndIf
If Type("oXMLItem:_ANALYTICALORSYNTHETIC:TEXT") <> "U"
	AADD(aCab , {"CV0_CLASSE"	,oXMLItem:_AnalyticalOrSynthetic:Text	,NIL})
EndIf
If Type("oXMLItem:_POSTINGNATURE:TEXT") <> "U"
	AADD(aCab , {"CV0_NORMAL"	,oXMLItem:_PostingNature:Text	,NIL})
EndIf
If Type("oXMLItem:_ACTIVEORINACTIVE:TEXT") <> "U"
	If oXMLItem:_ActiveOrInactive:Text=="1"
		aAdd( aCab, { "CV0_BLOQUE","2", Nil })
	ElseIf oXMLItem:_ActiveOrInactive:Text=="2"
		aAdd( aCab, { "CV0_BLOQUE","1", Nil })
	EndIf
EndIf
If Type("oXMLItem:_TopCode:TEXT") <> "U"
	AADD(aCab , {"CV0_ENTSUP"	,oXMLItem:_TopCode:Text	,NIL})
EndIf

MSExecAuto({|x, y| CTBA800(x, y)}, aCab, nOpcExec)

If lMsErroAuto
	cLogErro := ""
	aErroAuto := GetAutoGRLog()
	For nCount := 1 To Len(aErroAuto)
		cLogErro += '<Message type="ERROR" code="c2">' + _NoTags( AllTrim( aErroAuto[nCount] ) ) + '</Message>'
	Next nCount

	// Monta XML de Erro de execução da rotina automatica.
	lRet := .F.
	cXmlRet := cLogErro
Else
	// Monta xml RETORNO DO DE/PARA
	If nOpcExec # 5

		cValInt:= cEmpAnt + "|" + CV0->CV0_FILIAL + "|" + CV0->CV0_PLANO + "|" + CV0->CV0_CODIGO
	    //Inclui ou Altera quando vem de Outro ERP e devolve para o ERP
		CFGA070Mnt( cMarca, cAlias, cField, cValExt, cValInt ) //Grava na Tabela XXF
		lRet:= .T.
		cXmlRet := "	<InternalId>"
		cXmlRet += "		<Name>" + _NoTags( AllTrim( cMensagem ) ) + "</Name>"
		cXmlRet += "		<Origin>" + _NoTags( AllTrim( cValExt ) ) + "</Origin>"				//-- Valor gerado
		cXmlRet += "		<Destination>" +_NoTags( AllTrim( cValInt ) ) + "</Destination>"	//-- Valor recebido
		cXmlRet += "	</InternalId>"

	EndIf
EndIf

RestArea(aArea)
cXmlRet := EncodeUTF8(cXmlRet)

Return { lRet, cXmlRet }

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LimpText  ³ Autor ³Leandro Drumond        ³ Data ³ 05/02/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retira caracteres estranhos de um palavra.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³LimpText()											      ³±±
±±³Parametros³ExpC1 - Texto para limpeza.							      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LimpText(cTexto)
Local cTmpCar	:= ""
Local cCarac	:= "-.;/\*,:$%&"
Local nItem		:= 1

For nItem := 1 to Len(cCarac)
	cTmpCar	:= Substr(cCarac,nItem,1)
	cTexto	:= StrTran(cTexto,cTmpCar)
Next nItem

Return cTexto

//-------------------------------------------------------------------
/*/{Protheus.doc} IntGerExt
Monta o InternalID do Centro de Custo de acordo com o código passado
no parâmetro.

@param   cEmpresa   Código da empresa (Default cEmpAnt)
@param   cFil       Código da Filial (Default cFilAnt)
@param   cCCusto    Código do Centro de Custo
@param   cVersao    Versão da mensagem única (Default 2.000)

@author  Alvaro Camillo Neto
@version P12.1.8
@since   14/09/2015
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execução da função
         aRet[2] - (caracter) Mensagem Xml para envio

@sample  IntGerExt(, , '40') irá retornar {.T., '01|01|40'}
/*/
//-------------------------------------------------------------------
Function IntGerExt(cEmpresa, cFil, cPlano, cEntGer, cVersao)
Local aResult    := {}
Default cEmpresa := cEmpAnt
Default cFil     := xFilial('CV0')
Default cVersao  := '1.000'

If cVersao == '1.000'
	aAdd(aResult, .T.)
	aAdd(aResult, cEmpresa + '|' + PadR(cFil, TamSX3('CV0_FILIAL')[1]) + '|' + AllTrim(cPlano) + '|' + AllTrim(cEntGer)  )
Else
	aAdd(aResult, .F.)
	aAdd(aResult, STR0012 ) //"Versão da mensagem Centro de Custo não suportada." + "As versões suportadas são: 1.000|2.000"
EndIf

Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntGerInt
Recebe um InternalID e retorna o código da entidade gerencial

@param   cInternalID InternalID recebido na mensagem.
@param   cRefer      Produto que enviou a mensagem
@param   cVersao     Versão da mensagem única (Default 1.000)

@author  Leandro Luiz da Cruz
@version P11
@since   05/02/2013
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado no de/para.
         No segundo parâmetro uma variável array com a empresa,
         filial e o código do centro de custo.

@sample  IntLocInt('01|01|40', 'RM') irá retornar {.T., {'01', '01', '40       '}}
//adicionada para o retorno da versao 1.000 o internalid
//Vesao 1.000 retornará {.T., {xFilial,Centro de Custo},InternalId}
/*/
//-------------------------------------------------------------------
Function IntGerInt(cInternalID, cRefer, cVersao)

Local   aResult  := {}
Local   aTemp    := {}
Local   cTemp    := ''
Local   cAlias   := 'CV0'
Local   cField   := 'CV0_CODIGO'
Default cVersao  := '1.000'

cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)

If Empty(cTemp)
	aAdd(aResult, .F.)
	aAdd(aResult, STR0010 + AllTrim(cInternalID) + STR0011) //"Entidade Gerencial " + " não encontrado no de/para!"
Else
	If cVersao == '1.000'
		aAdd(aResult, .T.)
		aTemp := Separa( cTemp, "|", .T. )
		aAdd(aResult, aTemp)
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, STR0012 ) //"Versão da mensagem Conta Gerencial não suportada."
	EndIf
EndIf

Return aResult
