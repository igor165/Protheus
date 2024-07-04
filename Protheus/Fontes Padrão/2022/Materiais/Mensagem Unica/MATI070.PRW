#INCLUDE "MATI070.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
Static lMI070POS := ExistBlock("MI070POS")

/*/{Protheus.doc} MATI070
Adapter da mensagem única TOTVS para o cadastro de bancos.

@param   cXml          Variável com conteúdo XML para envio/recebimento.
@param   cTypeTrans    Tipo de transação (Envio / Recebimento).
@param   cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param   cVersion      Versão da mensagem.
@param   cTransac      Nome da transação.
@param   lEAIObj       Indica se é mensagem XML (.F.) ou JSON (.T.).

@author  Wilson de Godoi
@version P12.1.22
@since   08/03/2012
@return  aRet   - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio
       aRet[3] - (caracter) Nome da mensagem
/*/
Function MATI070(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac, lEAIObj)

Local lRet				:= .T.
Local cXmlRet			:= ''
Local aSave				:= GetArea()
Local aSaveSA6			:= SA6->(GetArea())
Local aRet				:= {}

Private lMsErroAuto		:= .F.
Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile	:= .T.
Private oXmlA070		:= Nil
Private oXmlBusMsg		:= Nil

If (cTypeMsg == EAI_MESSAGE_WHOIS)
	cXmlRet := '1.000|2.000|2.001'

ElseIf (cTypeMsg == EAI_MESSAGE_RECEIPT)
	cXmlRet := '<TAGX>RECEPCAO RECEIPT MESSAGE</TAGX>'

Else
	If cVersion = "1."
		aRet := v1000(cXml, cTypeTrans, cTypeMsg, cVersion)
	ElseIf cVersion = "2."
		aRet := v2000(cXml, cTypeTrans, cTypeMsg, cVersion)
	Else
		lRet    := .F.
		cXmlRet := STR0002  // "A versão da mensagem informada não foi implementada!"
	EndIf
EndIf

If len(aRet) > 1
	lRet    := aRet[1]
	cXmlRet := aRet[2]
Else
	cXmlRet := EncodeUTF8(cXmlRet)
Endif

// Ponto de entrada no final da rotina para tratamento do XML.
If lMI070POS
	aRet := ExecBlock("MI070POS", .F., .F., {lRet, cXmlRet, cTypeTrans, cTypeMsg, cVersion, cTransac, lEAIObj})
	If ValType(aRet) = "A" .and. len(aRet) > 1
		lRet    := aRet[1]
		cXmlRet := aRet[2]
	Endif
Endif

RestArea(aSaveSA6)
RestArea(aSave)

Return {lRet, cXmlRet, "BANK"}

//-------------------------------------------------------------------
/*{Protheus.doc} M70MontInt
Recebe um registro no Protheus e gera o InternalId deste registro

@param		cFil		Filial do registro
@Param		cBanco		Código do banco
@param		cAgencia	Agência
@param		cConta		Conta corrente

@author  Jandir Deodato
@version P11.8
@since   30/04/13
@return  cRetorno - Retorna o InternalId do registro

@sample  exemplo de retorno - 'Empresa|Filial|Banco|Agência|Conta'
*/
//-------------------------------------------------------------------
Function M70MontInt(cFil, cBanco, cAgencia, cConta)
Return cEmpAnt + '|' + RTrim(xFilial("SA6", cFil)) + '|' + RTrim(cBanco) + '|' + RTrim(cAgencia) + '|' + RTrim(cConta)

//-------------------------------------------------------------------
/*{Protheus.doc} M70GetInt
Recebe um codigo, busca seu internalId e faz a quebra da chave

@param   cCode		 InternalID recebido na mensagem.
@param   cMarca      Produto que enviou a mensagem

@author  Jandir Deodato
@version P11.8
@since   30/04/13
@return  aRetorno Array contendo os campos da chave primaria do titulo a receber, a sequência da baixa e o seu InternalId.

@sample  exemplo de retorno - {.T., {'Empresa', 'Filial', 'Banco', 'Agência', 'Conta}, InternalId}
*/
//-------------------------------------------------------------------
Function M70GetInt(cCode, cMarca)

Local cValInt	:= ''
Local aRetorno	:= {}
Local aAux		:= {}
Local aCampos	:= {cEmpAnt, 'A6_FILIAL', 'A6_COD', 'A6_AGENCIA', 'A6_NUMCON'}
Local nX		:= 0

cValInt := CFGA070Int(cMarca, 'SA6', 'A6_COD', cCode)

If !Empty(cValInt)
	aAux := Separa(cValInt, '|')

	// Corrigindo  o tamanho dos campos.
	aAux[1] := Padr(aAux[1], Len(cEmpAnt))
	For nX := 2 To Len(aAux)
		aAux[nX] := Padr(aAux[nX], TamSX3(aCampos[nX])[1])
	Next nX

	aAdd(aRetorno, .T.)
	aAdd(aRetorno, aAux)
	aAdd(aRetorno, cValInt)
Else
	aAdd(aRetorno, .F.)
EndIf

Return aRetorno

/*/{Protheus.doc} v1000
Implementação do adapter EAI, versão 1.x

@author
@version
@since
/*/
Static Function v1000(cXml, cTypeTrans, cTypeMsg, cVersion)
Local lRet				:= .T.
Local cXmlRet			:= ''
Local cEvent			:= 'upsert'
Local cErroXml			:= ""
Local cWarnXml			:= ""
local cError			:= ""
Local cCod				:= ''
Local cAgencia			:= ''
Local cConta			:= ''
Local aValInt			:= {}
Local cLogErro			:= ""
Local nCount			:= 0
Local aCab				:= {}
Local nOpcExec			:= 3
Local cMarca			:= ''
Local cAlias			:= 'SA6'
Local cField			:= 'A6_COD'
Local cValInt			:= ''
Local cValExt			:= ''
Local cWarning			:= ''
Local oModel			:= FwModelActive()

Do Case
// verificação do tipo de transação recebimento ou envio
// trata o envio
Case ( cTypeTrans == TRANS_SEND )
	//	Tratar o envio inserindo as informações

	If (Type("INCLUI")<>"U" .and. TYPE("ALTERA")<>"U" .and. (!INCLUI .AND. !ALTERA)) .or. Valtype(oModel)=="O" .and. AllTrim(oModel:GetId())=="MATA070" .and. oModel:GetOperation()==MODEL_OPERATION_DELETE
		cEvent := 'delete'
		cValInt := M70MontInt(,SA6->A6_COD,SA6->A6_AGENCIA,SA6->A6_NUMCON)// xFilial('SA6') + SA6->A6_COD + SA6->A6_AGENCIA + SA6->A6_NUMCON
		If FindFunction('CFGA070Mnt')
			If !Empty(cValInt)
				//Exclui quando vem de outro ERP
				CFGA070Mnt(, cAlias, cField,, cValInt, .T. )  // Deleta o XXF
			Endif
		Endif
	EndIf

	cXmlRet := '<BusinessEvent>'
	cXmlRet +=     '<Entity>BANK</Entity>'
	cXmlRet +=     '<Event>' + cEvent + '</Event>'	//variável upsert para atualização ou
	cXmlRet +=		'<Identification>'
	cXmlRet +=         '<key name="InternalId">' +M70MontInt(, SA6->A6_COD,SA6->A6_AGENCIA,SA6->A6_NUMCON)/* xFilial('SA6') + SA6->A6_COD + SA6->A6_AGENCIA + SA6->A6_NUMCON*/ +'</key>'
	cXmlRet +=     '</Identification>'
	cXmlRet += '</BusinessEvent>'
	cXmlRet += '<BusinessContent>'
	cXmlRet +=	  '<Code>'  					+ SA6->A6_COD + '</Code>'
	cXmlRet +=	  '<Febraban>'  				+ SA6->A6_NUMBCO + '</Febraban>'
	cXmlRet +=    '<Name>' 						+ SA6->A6_NOME + '</Name>'
	cXmlRet +=	  '<ShortName>'  				+ SA6->A6_NREDUZ + '</ShortName>'
	cXmlRet +=    '<ListOfAgency>'
	cXmlRet += 		 '<Agency>'
	cXmlRet +=    		'<Number>' 	  			+ SA6->A6_AGENCIA + '</Number>'  	//Número da Agência
	cXmlRet +=    		'<Name>' 				+ SA6->A6_NOMEAGE + '</Name>'		//Nome da Agência
	cXmlRet +=   		'<Address>'
	cXmlRet +=    			'<Address>'  		+ SA6->A6_END + '</Address>'  //Rua/AV.
	cXmlRet +=    			'<Number>' 	 		+ '</Number>'   			//Numero Endereço // Não tem no Protheus
	cXmlRet +=    			'<Complement>' 		+ '</Complement>'  			//complemento Endereço // Não tem no Protheus
	cXmlRet +=   			'<City>'
	cXmlRet +=    				'<Code>'   		+ '</Code>'   					//Código da Cidade
	cXmlRet +=    				'<Description>' + SA6->A6_MUN + '</Description>'  //Cidade Endereço
	cXmlRet +=   			'</City>'
	cXmlRet +=    			'<District>' 		+ SA6->A6_BAIRRO + '</District>'	//Distrito
	cXmlRet +=   			'<State>'
	cXmlRet +=    				'<Code>'   		+ SA6->A6_EST + '</Code>'			//Sigla Estado Endereço
	cXmlRet +=    				'<Description>' + Posicione("SX5",1,xFilial("SX5")+ "12" + Alltrim(SA6->A6_EST),"X5DESCRI()","") + '</Description>'  	//Nome  Estado //SX5
	cXmlRet +=   			'</State>'
	cXmlRet +=   			'<Country>'
	cXmlRet +=    				'<Code>'   		+ '</Code>'   					  //Codigo Pais
	cXmlRet +=    				'<Description>' + SA6->A6_PAISBCO + '</Description>'  //Nome do Pais
	cXmlRet +=   			'</Country>'
	cXmlRet +=    			'<ZIPCode>' 		+ SA6->A6_CEP + '</ZIPCode>'		  //CEP
	cXmlRet +=    			'<Region>' 			+  '</Region>'					  //Região
	cXmlRet +=    			'<POBox>' 			+ SA6->A6_CXPOSTA + '</POBox>'		  //Caixa Postal
	cXmlRet +=   		'</Address>'
	cXmlRet +=   		'<ContactInformation>'
	cXmlRet +=    			'<Code>' 			+  '</Code>'					  //Codigo do Contato
	cXmlRet +=    			'<Title>' 			+  '</Title>'					  //Titulo
	cXmlRet +=    			'<Name>' 			+ SA6->A6_CONTATO + '</Name>'		  //Nome do Contato
	cXmlRet +=    			'<Department>' 		+  '</Department>'				  //Depto. do Contato
	cXmlRet +=   			'<CommunicationInformation>'
	cXmlRet +=    				'<PhoneNumber>' 		+ SA6->A6_TEL + '</PhoneNumber>'	// Numero Telefone
	cXmlRet +=    				'<PhoneExtension>' 		+  '</PhoneExtension>'			// Numero DDD
	cXmlRet +=    				'<FaxNumber>' 	   		+ SA6->A6_FAX + '</FaxNumber>'  	// Numero fax
	cXmlRet +=    				'<FaxNumberExtension>' 	+  '</FaxNumberExtension>'		// Numero DDD fax
	cXmlRet +=    				'<HomePage>' 			+  '</HomePage>'				// Numero HomePage
	cXmlRet +=    				'<Email>' 				+  '</Email>' 					// Numero Email
	cXmlRet +=   			'</CommunicationInformation>'
	cXmlRet +=   			'<Address>'
	cXmlRet +=    				'<Address>'  		+ '</Address>'  	//Rua/AV.
	cXmlRet +=    				'<Number>' 	 		+ '</Number>'   	//Numero Endereço // Não tem no Protheus
	cXmlRet +=    				'<Complement>' 		+ '</Complement>'  	//complemento Endereço // Não tem no Protheus
	cXmlRet +=   				'<City>'
	cXmlRet +=    					'<Code>'   		+ '</Code>'   		//Codigo da Cidade
	cXmlRet +=    					'<Description>' + '</Description>'  //Nome da Cidade
	cXmlRet +=   				'</City>'
	cXmlRet +=    				'<District>' 		+ '</District>'		//Distrito
	cXmlRet +=   				'<State>'
	cXmlRet +=    					'<Code>'   		+ '</Code>'			//Sigla Estado Endereço
	cXmlRet +=    					'<Description>' + '</Description>'  //Nome  Estado //SX5
	cXmlRet +=   				'</State>'
	cXmlRet +=   				'<Country>'
	cXmlRet +=    					'<Code>'   		+ '</Code>'   		//Codigo Pais
	cXmlRet +=    					'<Description>' + '</Description>'  //Nome do Pais
	cXmlRet +=   				'</Country>'
	cXmlRet +=    				'<ZIPCode>' 		+ '</ZIPCode>'		//CEP
	cXmlRet +=    				'<Region>' 			+ '</Region>'					//Região
	cXmlRet +=    				'<POBox>' 			+ '</POBox>'		//Caixa Postal
	cXmlRet +=   			'</Address>'
	cXmlRet +=   		'</ContactInformation>'
	cXmlRet +=    		'<ListOfAccount>'
	cXmlRet += 		 		'<Account>'
	cXmlRet +=					'<CompanyId>'  	   		 + cEmpAnt + '</CompanyId>'
	cXmlRet +=    				'<Number>' 	  			 + SA6->A6_NUMCON + '</Number>'  	//Número da conta
	cXmlRet +=    				'<Name>' 	  			 + '</Name>'   			    	//Nome da Conta
	cXmlRet +=    				'<AccountantAccountCode>'+ SA6->A6_CONTA + '</AccountantAccountCode>'  	//Codigo da Conta Contabil
	cXmlRet +=   	 		'</Account>'
	cXmlRet +=    		'</ListOfAccount>'
	cXmlRet +=   	 '</Agency>'
	cXmlRet +=    '</ListOfAgency>'
	cXmlRet += '</BusinessContent>'

// verificação do tipo de transação recebimento ou envio
// trata o recebimento
Case ( cTypeTrans == TRANS_RECEIVE )
	Do Case

	//-- Quando Recebemos de Fora então fazemos a Gravacao do De/Para Codigo Interno X Codigo Externo
	Case ( cTypeMsg == EAI_MESSAGE_RESPONSE )

  		If FindFunction("CFGA070Mnt")
			oXmlA070 := XmlParser(cXml, "_", @cError, @cWarning)

			If oXmlA070 <> Nil .And. Empty(cError) .And. Empty(cWarning)
				If Type("oXmlA070:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U"
					cMarca :=  oXmlA070:_TotvsMessage:_MessageInformation:_Product:_Name:Text
				EndIf
   				If Type("oXmlA070:_TOTVSMessage:_ResponseMessage:_ReturnContent:_OriginInternalID:Text") <> "U"
   					cValInt := oXmlA070:_TOTVSMessage:_ResponseMessage:_ReturnContent:_OriginInternalID:Text
   				EndIf
   				If Type("oXmlA070:_TOTVSMessage:_ResponseMessage:_ReturnContent:_DestinationInternalID:Text") <> "U"
   	   				cValExt := oXmlA070:_TOTVSMessage:_ResponseMessage:_ReturnContent:_DestinationInternalID:Text
   				EndIf

				If !Empty(cValExt) .And. !Empty(cValInt)
    				//Inclui ou Altera a Devolução do Envio para Outro ERP
    				If !CFGA070Mnt( cMarca, cAlias, cField, cValExt, cValInt )
						lRet    := .F.
					Else
						lRet    := .T.
					Endif
				Else
					lRet    := .F.
				Endif
   			EndIf
    	EndIf

    Case ( cTypeMsg == EAI_MESSAGE_BUSINESS )
		oXmlA070 := XmlParser(cXml, "_", @cErroXml, @cWarnXml)

		// testando a existência de BusinessEvent
		If oXmlA070 <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
			// atalho para acesso aos dados
			If ( XmlChildEx( oXmlA070:_TOTVSMessage, '_BUSINESSMESSAGE' ) <> nil )
				oXmlBusMsg := oXmlA070:_TOTVSMessage:_BusinessMessage

				// Recebe Nome do Produto (ex: RM ou PROTHEUS) e guarda na variavel cMarca
				If Type("oXmlA070:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U"
					cMarca :=  oXmlA070:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
				EndIf

				// Recebe o ID externo e guarda na variavel cValExt
				If Type("oXmla070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") <> "U"
					cValExt := oXmla070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
				EndIf

				//----------------------------------------------------------------------------------------
				//-- procura a Marca,Alias,Codigo na Tabela XXF de De/Para para ver se Existe o Código
				//----------------------------------------------------------------------------------------
   				If FindFunction("CFGA070INT")
					//Apens verifica se existe o Registro no XXF para saber se é Inclusão, Alteração ou Exclusão
   					aValInt := M70GetInt(cValExt, cMarca)//CFGA070INT( cMarca,  cAlias , cField, cValExt )
   					If aValInt[1]
   						cValInt:=aValInt[3]
   					Endif
				Endif

				SA6->(dbSetOrder(1))  // A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON.
   				If Upper(oXmla070:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
					If !Empty( cValInt )
						SA6->(dbSeek(aValint[2][2]+aValint[2][3]+aValint[2][4]+aValint[2][5]))
						nOpcExec := 4
 	   				Else
   						nOpcExec := 3
					Endif
  				Else
  					nOpcExec := 5
   				Endif

				If nOpcExec == 3
					If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text") <> "U"
						cCod:=Padr(oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text,TamSX3("A6_COD")[1])
					Endif

					If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Number:Text") <> "U"
  						cAgencia:=Padr(oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Number:Text,TamSX3("A6_AGENCIA")[1])
   					Endif

					If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ListOfAccount:_Account:_Number:Text") <> "U"
						cConta:=Padr(oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ListOfAccount:_Account:_Number:Text,TamSX3("A6_NUMCON")[1])
					EndIf

					// Se o código já está cadastrado no Protheus, pega o próximo número.
					Do While SA6->(dbSeek(xFilial() + cCod + cAgencia + cConta, .F.))
						cCod := GetSXENum('SA6', 'A6_COD')
						ConfirmSx8()
					EndDo
				ElseIf !Empty(cValInt)
					cCod:=aValint[2][3]
					cAgencia:=aValint[2][4]
					cConta:=aValint[2][5]
				Endif

				Aadd( aCab, { "A6_COD", cCod, Nil })
				Aadd( aCab, { "A6_AGENCIA", cAgencia, Nil })
				Aadd( aCab, { "A6_NUMCON",cConta, Nil })

				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Name:Text") <> "U"
					Aadd( aCab, { "A6_NOME", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Name:Text, Nil })
   				Endif

				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Febraban:Text") <> "U"
					Aadd( aCab, { "A6_NUMBCO", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Febraban:Text, Nil })
   	 			Endif

				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShortName:Text") <> "U"
					Aadd( aCab, { "A6_NREDUZ", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShortName:Text, Nil })
   				Endif

   				//ListOfAgency:_Agency
				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Name:Text") <> "U"
  					Aadd( aCab, { "A6_NOMEAGE", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Name:Text, Nil })
   				Endif

   				//Address
				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_Address:Text") <> "U"
  					Aadd( aCab, { "A6_END", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_Address:Text, Nil })
   				Endif

   				//City
				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_City:_Description:Text") <> "U"
  					Aadd( aCab, { "A6_MUN", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_City:_Description:Text, Nil })
   				Endif

				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_District:Text") <> "U"
  					Aadd( aCab, { "A6_BAIRRO", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_District:Text, Nil })
   				Endif

				//State
				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_State:_Code:Text") <> "U"
  					Aadd( aCab, { "A6_EST", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_State:_Code:Text, Nil })
   				Endif

   				//Country
				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_Country:_Description:Text") <> "U"
  					Aadd( aCab, { "A6_PAISBCO", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_Country:_Description:Text, Nil })
   				Endif


				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_ZIPCode:Text") <> "U"
  					Aadd( aCab, { "A6_CEP", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_ZIPCode:Text, Nil })
   				Endif

				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_POBox:Text") <> "U"
  					Aadd( aCab, { "A6_CXPOSTA", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_POBox:Text, Nil })
   				Endif

				//ContactInformation
				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ContactInformation:_Name:Text") <> "U"
  					Aadd( aCab, { "A6_CONTATO", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ContactInformation:_Name:Text, Nil })
   				Endif

   				//CommunicationInformation
				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ContactInformation:_CommunicationInformation:_PhoneNumber:Text") <> "U"
					Aadd( aCab, { "A6_TEL", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ContactInformation:_CommunicationInformation:_PhoneNumber:Text, Nil })
   				Endif

				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ContactInformation:_CommunicationInformation:_FaxNumber:Text") <> "U"
  					Aadd( aCab, { "A6_FAX", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ContactInformation:_CommunicationInformation:_FaxNumber:Text, Nil })
   				Endif

   				//ListOfAccount:_Account
				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent::_ListOfAgency:_Agency:_ListOfAccount:_Account:_CompanyId:Text") <> "U"
					Aadd( aCab, { "cEmpAnt",oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ListOfAccount:_Account:_CompanyId:Text, Nil })
				EndIf

				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ListOfAccount:_Account:_AccountantAccountCode:Text") <> "U"
					Aadd( aCab, { "A6_CONTA",oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ListOfAccount:_Account:_AccountantAccountCode:Text, Nil })
				EndIf

				MSExecAuto({|x,y| MATA070(x,y)},aCab,nOpcExec)

				If lMsErroAuto
					cLogErro:=""
					aErroAuto := GetAutoGRLog()
					For nCount := 1 To Len(aErroAuto)
						cLogErro += '<Message type="ERROR" code="c2">'+StrTran(StrTran(StrTran(aErroAuto[nCount],"<"," "),"-"," "),"/"," ")+" "+'</Message>'
					Next nCount
					//Monta XML de Erro de execução da rotina automatica.
 					lRet:=.F.
					cXmlRet:=cLogErro
				Else
					If nOpcExec # 5
						If FindFunction('CFGA070Mnt')
							cValInt:=M70MontInt(,cCod,cAgencia,cConta)//+ SA6->A6_COD + SA6->A6_AGENCIA + SA6->A6_NUMCON
	    					//Inclui ou Altera quando vem de Outro ERP e devolve para o ERP
							CFGA070Mnt( cMarca, cAlias, cField, cValExt, cValInt ) //Grava na Tabela XXF
							lRet:= .T.
							cXmlRet := "<DestinationInternalID>"+ cValInt +"</DestinationInternalID>"
							cXmlRet += "<OriginInternalID>"     + cValExt +"</OriginInternalID>"
						Endif
					ElseIf nOpcExec == 5
						If !Empty( cValInt )
	  		    			If FindFunction('CFGA070Mnt')
	    						//Exclui quando vem de outro ERP
	   							CFGA070Mnt(, cAlias, cField,, cValInt, .T. )  // Deleta o XXF
							Endif
	    				Endif
					EndIf
				EndIf
			EndIf
		Else
			lRet := .F.
		EndIf
	End Case
End Case

return {lRet,cXmlRet}


/*/{Protheus.doc} v2000
Implementação do adapter EAI, versão 2.x

@author
@version
@since
/*/
Static Function v2000(cXml, cTypeTrans, cTypeMsg , cVersion)

Local lRet				:= .T.
Local cXmlRet			:= ''
Local cEvent			:= 'upsert'
Local cErroXml			:= ""
Local cWarnXml			:= ""
local cError			:= ""
Local cCod				:= ''
Local cAgencia			:= ''
Local cConta			:= ''
Local aValInt			:= {}
Local cLogErro			:= ""
Local nCount			:= 0
Local aCab				:= {}
Local nOpcExec			:= 3
Local cMarca			:= ''
Local cAlias			:= 'SA6'
Local cField			:= 'A6_COD'
Local cValInt			:= ''
Local cValExt			:= ''
Local cWarning			:= ''
Local oModel			:= FwModelActive()
Local cBookType			:= ''
Local cBookCode			:= ''
Local cChargeType		:= ''
Local cContractNumber	:= ''
Local cTransfNam		:= ''
Local cTransfCod		:= ''
Local lBankParam		:= IsInCallStack('FINA130') .OR. ( FwIsInCallStack("CFG020ASINC") .AND. TYPE("SEE->EE_CODIGO") == 'C' ) // Chamada da rotina Parâmetros de Banco ou carga inicial do FINA130 com SEE posicionada


//Se estiver partindo do FINA130, passo os dados adicionais já gravados na tabela SEE
If lBankParam
	cContractNumber	:= AllTrim(SEE->EE_NUMCTR)
	cBookType		:= AllTrim(SEE->EE_TIPCART)
	cBookCode		:= AllTrim(SEE->EE_CODCART)
	cChargeType		:= AllTrim(SEE->EE_TPCOBRA)
EndIf

//Posiciono o SM0 (SIGAMAT) para obter o nome do cedente
SM0->(DbSetOrder(1))
SM0->(DbSeek(cEmpAnt+cFilAnt))

Do Case
// verificação do tipo de transação recebimento ou envio
// trata o envio
Case ( cTypeTrans == TRANS_SEND )
	//	Tratar o envio inserindo as informações

	If (Type("INCLUI")<>"U" .and. TYPE("ALTERA")<>"U" .and. (!INCLUI .AND. !ALTERA)) .or. (Valtype(oModel)=="O" .and. AllTrim(oModel:GetId())=="MATA070" .and. oModel:GetOperation()==MODEL_OPERATION_DELETE)
		cEvent  := 'delete'
		cValInt := M70MontInt(,SA6->A6_COD,SA6->A6_AGENCIA,SA6->A6_NUMCON)// xFilial('SA6') + SA6->A6_COD + SA6->A6_AGENCIA + SA6->A6_NUMCON
		If FindFunction('CFGA070Mnt')
			If !Empty(cValInt)
				//Exclui quando vem de outro ERP
				CFGA070Mnt(, cAlias, cField,, cValInt, .T. )  // Deleta o XXF
			Endif
		Endif
	EndIf

	If lBankParam .And. (INCLUI .Or. ALTERA .Or. EXCLUI) 	//Mesmo na exclusão do registro na tabela SEE, posiciono a SA6 para ser feito o UPSERT
		DbSelectArea("SA6")									//desta forma, a mensagem será enviada de forma completa, atualizando apenas os dados
		DbSetOrder(1)										//referentes aos parâmetros de banco
		DbSeek(xFilial("SA6")+SEE->(EE_CODIGO+EE_AGENCIA+EE_CONTA))
		RegToMemory("SA6",.F.)
	EndIf

	If lBankParam .And. Type("EXCLUI") <> "U" .AND. !EXCLUI
		cTransfNam	:= SubStr(SM0->M0_NOMECOM,1,40)
		cTransfCod	:= SA6->A6_CODCED
	EndIf

	cXmlRet := '<BusinessEvent>'
	cXmlRet +=   '<Entity>BANK</Entity>'
	cXmlRet +=   '<Event>' + cEvent + '</Event>'
	cXmlRet +=   '<Identification>'
	cXmlRet +=     '<key name="InternalId">' + M70MontInt(, SA6->A6_COD, SA6->A6_AGENCIA, SA6->A6_NUMCON) + '</key>'
	cXmlRet +=   '</Identification>'
	cXmlRet += '</BusinessEvent>'
	cXmlRet += '<BusinessContent>'
	cXmlRet +=   '<CompanyId>'+ cEmpAnt + '</CompanyId>'
	cXmlRet +=   '<BranchId>' + cFilAnt + '</BranchId>'
	cXmlRet +=   '<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
	cXmlRet +=   '<Code>' + _NoTags(RTrim(SA6->A6_COD)) + '</Code>'
	cXmlRet +=   '<InternalId>' + M70MontInt(, SA6->A6_COD, SA6->A6_AGENCIA, SA6->A6_NUMCON) + '</InternalId>'
	cXmlRet +=   '<Febraban>' + _NoTags(RTrim(SA6->A6_NUMBCO)) + '</Febraban>'
	cXmlRet +=   '<Name>' + _NoTags(RTrim(SA6->A6_NOME)) + '</Name>'
	cXmlRet +=   '<ShortName>' + _NoTags(RTrim(SA6->A6_NREDUZ)) + '</ShortName>'
	cXmlRet +=   '<ListOfAgency>'
	cXmlRet +=     '<Agency>'
	cXmlRet +=       '<Number>' + _NoTags(RTrim(SA6->A6_AGENCIA)) + '</Number>'
	cXmlRet +=       '<Name>' + _NoTags(RTrim(SA6->A6_NOMEAGE)) + '</Name>'
	cXmlRet +=       '<Address>'
	cXmlRet +=         '<Address>' + _NoTags(RTrim(SA6->A6_END)) + '</Address>'
	cXmlRet +=         '<Number/>'
	cXmlRet +=         '<Complement/>'
	cXmlRet +=         '<City>'
	cXmlRet +=           '<Code/>'
	cXmlRet +=           '<Description>' + _NoTags(RTrim(SA6->A6_MUN)) + '</Description>'
	cXmlRet +=         '</City>'
	cXmlRet +=         '<District>' + _NoTags(RTrim(SA6->A6_BAIRRO)) + '</District>'
	cXmlRet +=         '<State>'
	cXmlRet +=           '<Code>' + _NoTags(RTrim(SA6->A6_EST)) + '</Code>'
	cXmlRet +=           '<Description>' + _NoTags(RTrim(Posicione("SX5", 1, xFilial("SX5")+ "12" + SA6->A6_EST, "X5DESCRI()"))) + '</Description>'
	cXmlRet +=         '</State>'
	cXmlRet +=         '<Country>'
	cXmlRet +=           '<Code/>'
	cXmlRet +=           '<Description>' + _NoTags(RTrim(SA6->A6_PAISBCO)) + '</Description>'
	cXmlRet +=         '</Country>'
	cXmlRet +=         '<ZIPCode>' + _NoTags(RTrim(SA6->A6_CEP)) + '</ZIPCode>' // CEP
	cXmlRet +=         '<Region/>'
	cXmlRet +=         '<POBox>' + _NoTags(RTrim(SA6->A6_CXPOSTA)) + '</POBox>' // Código postal
	cXmlRet +=       '</Address>'
	cXmlRet +=       '<ContactInformation>'
	cXmlRet +=         '<Code/>'
	cXmlRet +=         '<Title/>'
	cXmlRet +=         '<Name>' + _NoTags(RTrim(SA6->A6_CONTATO)) + '</Name>'
	cXmlRet +=         '<Department/>'
	cXmlRet +=         '<CommunicationInformation>'
	cXmlRet +=           '<PhoneNumber>' + _NoTags(RTrim(SA6->A6_TEL)) + '</PhoneNumber>'
	cXmlRet +=           '<PhoneExtension/>' // DDD
	cXmlRet +=           '<FaxNumber>' + _NoTags(RTrim(SA6->A6_FAX)) + '</FaxNumber>'
	cXmlRet +=           '<FaxNumberExtension/>' // DDD do fax
	cXmlRet +=           '<HomePage/>'
	cXmlRet +=           '<Email/>'
	cXmlRet +=         '</CommunicationInformation>'
	cXmlRet +=         '<Address>'
	cXmlRet +=           '<Address/>'
	cXmlRet +=           '<Number/>'
	cXmlRet +=           '<Complement/>'
	cXmlRet +=           '<City>'
	cXmlRet +=             '<Code/>'
	cXmlRet +=             '<Description/>'
	cXmlRet +=           '</City>'
	cXmlRet +=           '<District/>'
	cXmlRet +=           '<State>'
	cXmlRet +=             '<Code/>'
	cXmlRet +=             '<Description/>'
	cXmlRet +=           '</State>'
	cXmlRet +=           '<Country>'
	cXmlRet +=             '<Code/>'
	cXmlRet +=             '<Description/>'
	cXmlRet +=           '</Country>'
	cXmlRet +=           '<ZIPCode/>'
	cXmlRet +=           '<Region/>'
	cXmlRet +=           '<POBox/>'
	cXmlRet +=         '</Address>'
	cXmlRet +=       '</ContactInformation>'
	cXmlRet +=       '<ListOfAccount>'
	cXmlRet +=         '<Account>'
	cXmlRet +=           '<CompanyId>' + cEmpAnt + '</CompanyId>'
	cXmlRet +=           '<Number>' + _NoTags(RTrim(SA6->A6_NUMCON)) + '</Number>'
	cXmlRet +=           '<Name/>'
	cXmlRet +=           '<AccountantAccountCode>'+ _NoTags(RTrim(SA6->A6_CONTA)) + '</AccountantAccountCode>'
	cXmlRet +=           '<DigitAccount>' + _NoTags(RTrim(SA6->A6_DVCTA)) + '</DigitAccount>'
	cXmlRet +=         '</Account>'
	cXmlRet +=         '<Contract>'
	cXmlRet +=           '<ContractNumber>' + _NoTags(RTrim(cContractNumber)) + '</ContractNumber>'
	cXmlRet +=           '<TransferorName>' + _NoTags(RTrim(cTransfNam)) + '</TransferorName>'
	cXmlRet +=           '<TransferorCode>' + _NoTags(RTrim(cTransfCod)) + '</TransferorCode>'
	cXmlRet +=           '<BookType>' + _NoTags(RTrim(cBooktype)) + '</BookType>'
	cXmlRet +=           '<BookCode>' + _NoTags(RTrim(cBookCode)) + '</BookCode>'
	cXmlRet +=           '<ChargeType>' + _NoTags(RTrim(cChargeType)) + '</ChargeType>'
	cXmlRet +=         '</Contract>'
	cXmlRet +=       '</ListOfAccount>'
	cXmlRet +=     '</Agency>'
	cXmlRet +=   '</ListOfAgency>'
	cXmlRet += '</BusinessContent>'

// verificação do tipo de transação recebimento ou envio
// trata o recebimento
Case ( cTypeTrans == TRANS_RECEIVE )
	Do Case

	//-- Quando Recebemos de Fora então fazemos a Gravacao do De/Para Codigo Interno X Codigo Externo
	Case ( cTypeMsg == EAI_MESSAGE_RESPONSE )
		If FindFunction("CFGA070Mnt")
			oXmlA070 := XmlParser(cXml, "_", @cError, @cWarning)

			If oXmlA070 <> Nil .And. Empty(cError) .And. Empty(cWarning)
				If Type("oXmlA070:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U"
					cMarca :=  oXmlA070:_TotvsMessage:_MessageInformation:_Product:_Name:Text
				EndIf

				cEvent := Type("oXmlA070:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId")
				If cEvent <> "U" .And. cEvent <> "A"
					// Transforma em array
					XmlNode2Arr(oXmlA070:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId, "_InternalId")
            			// Verifica se o código interno foi informado
            			If Type("oXmlA070:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Origin:Text") != "U" .And. ;
            	 			!Empty(oXmlA070:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Origin:Text)
						cValInt := oXmlA070:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Origin:Text
					Else
						lRet    := .F.
						cXmlRet := /*STR0015*/ "Erro no retorno. O OriginalInternalId é obrigatório!"
						//Return {lRet, cXmlRet}
					EndIf

					// Verifica se o código externo foi informado
					If Type("oXmlA070:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Destination:Text") != "U" .And. ;
						!Empty(oXmlA070:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Destination:Text) .and. lRet
						cValExt := oXmlA070:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Destination:Text
					Else
						lRet    := .F.
						cXmlRet := /*STR0016*/ "Erro no retorno. O DestinationInternalId é obrigatório"
						//Return {lRet, cXmlRet}
					EndIf

   	  				If Upper(oXmlA070:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_Event:Text) == "UPSERT"
						If !Empty(cValExt) .And. !Empty(cValInt) .And. lRet
							//Inclui ou Altera a Devolução do Envio para Outro ERP
							If !CFGA070Mnt( cMarca, cAlias, cField, cValExt, cValInt )
								lRet    := .F.
							Else
								lRet    := .T.
							Endif
						Else
							lRet    := .F.
						Endif
					Endif
   				EndIf
   			EndIf
    	EndIf

    Case ( cTypeMsg == EAI_MESSAGE_BUSINESS )
		oXmlA070 := XmlParser(cXml, "_", @cErroXml, @cWarnXml)

		// testando a existência de BusinessEvent
		If oXmlA070 <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
			// atalho para acesso aos dados
			If ( XmlChildEx( oXmlA070:_TOTVSMessage, '_BUSINESSMESSAGE' ) <> nil )
				oXmlBusMsg := oXmlA070:_TOTVSMessage:_BusinessMessage

 				// Recebe Nome do Produto (ex: RM ou PROTHEUS) e guarda na variavel cMarca
				If Type("oXmlA070:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U"
					cMarca :=  oXmlA070:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
				EndIf

				// Recebe o ID externo e guarda na variavel cValExt
				If Type("oXmla070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") <> "U"
					cValExt := oXmla070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
				EndIf

				//----------------------------------------------------------------------------------------
				//-- procura a Marca,Alias,Codigo na Tabela XXF de De/Para para ver se Existe o Código
				//----------------------------------------------------------------------------------------
   				If FindFunction("CFGA070INT")
					//Apens verifica se existe o Registro no XXF para saber se é Inclusão, Alteração ou Exclusão
   					aValInt := M70GetInt(cValExt, cMarca)//CFGA070INT( cMarca,  cAlias , cField, cValExt )
   					If aValInt[1]
   						cValInt:=aValInt[3]
   					Endif
				Endif

				SA6->(dbSetOrder(1))  // A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON.
   				If Upper(oXmla070:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
					If !Empty( cValInt )
						SA6->(dbSeek(aValint[2][2]+aValint[2][3]+aValint[2][4]+aValint[2][5]))
						nOpcExec := 4
 	   				Else
   						nOpcExec := 3
					Endif
  				Else
  					nOpcExec := 5
   				Endif

				If nOpcExec == 3
					If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text") <> "U"
						cCod:=Padr(oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text,TamSX3("A6_COD")[1])
					Endif

					If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Number:Text") <> "U"
  						cAgencia:=Padr(oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Number:Text,TamSX3("A6_AGENCIA")[1])
   					Endif

					If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ListOfAccount:_Account:_Number:Text") <> "U"
						cConta:=Padr(oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ListOfAccount:_Account:_Number:Text,TamSX3("A6_NUMCON")[1])
					EndIf

					// Se o código já está cadastrado no Protheus, pega o próximo número.
					Do While SA6->(dbSeek(xFilial() + cCod + cAgencia + cConta, .F.))
						cCod := GetSXENum('SA6', 'A6_COD')
						ConfirmSx8()
					EndDo
				ElseIf !Empty(cValInt)
					cCod:=aValint[2][3]
					cAgencia:=aValint[2][4]
					cConta:=aValint[2][5]
				Endif

				Aadd( aCab, { "A6_COD", cCod, Nil })
				Aadd( aCab, { "A6_AGENCIA", cAgencia, Nil })
				Aadd( aCab, { "A6_NUMCON",cConta, Nil })

				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Name:Text") <> "U"
					Aadd( aCab, { "A6_NOME", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Name:Text, Nil })
   				Endif

				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Febraban:Text") <> "U"
					Aadd( aCab, { "A6_NUMBCO", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Febraban:Text, Nil })
   	 			Endif

				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShortName:Text") <> "U"
					Aadd( aCab, { "A6_NREDUZ", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShortName:Text, Nil })
   				Endif

   				//ListOfAgency:_Agency
				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Name:Text") <> "U"
  					Aadd( aCab, { "A6_NOMEAGE", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Name:Text, Nil })
   				Endif

   				//Address
				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_Address:Text") <> "U"
  					Aadd( aCab, { "A6_END", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_Address:Text, Nil })
   				Endif

   				//City
				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_City:_Description:Text") <> "U"
  					Aadd( aCab, { "A6_MUN", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_City:_Description:Text, Nil })
   				Endif

				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_District:Text") <> "U"
  					Aadd( aCab, { "A6_BAIRRO", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_District:Text, Nil })
   				Endif

				//State
				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_State:_Code:Text") <> "U"
  					Aadd( aCab, { "A6_EST", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_State:_Code:Text, Nil })
   				Endif

   				//Country
				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_Country:_Description:Text") <> "U"
  					Aadd( aCab, { "A6_PAISBCO", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_Country:_Description:Text, Nil })
   				Endif


				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_ZIPCode:Text") <> "U"
  					Aadd( aCab, { "A6_CEP", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_ZIPCode:Text, Nil })
   				Endif

				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_POBox:Text") <> "U"
  					Aadd( aCab, { "A6_CXPOSTA", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_Address:_POBox:Text, Nil })
   				Endif

				//ContactInformation
				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ContactInformation:_Name:Text") <> "U"
  					Aadd( aCab, { "A6_CONTATO", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ContactInformation:_Name:Text, Nil })
   				Endif

   				//CommunicationInformation
				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ContactInformation:_CommunicationInformation:_PhoneNumber:Text") <> "U"
					Aadd( aCab, { "A6_TEL", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ContactInformation:_CommunicationInformation:_PhoneNumber:Text, Nil })
   				Endif

				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ContactInformation:_CommunicationInformation:_FaxNumber:Text") <> "U"
  					Aadd( aCab, { "A6_FAX", oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ContactInformation:_CommunicationInformation:_FaxNumber:Text, Nil })
   				Endif

   				//ListOfAccount:_Account
				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent::_ListOfAgency:_Agency:_ListOfAccount:_Account:_CompanyId:Text") <> "U"
					Aadd( aCab, { "cEmpAnt",oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ListOfAccount:_Account:_CompanyId:Text, Nil })
				EndIf

				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ListOfAccount:_Account:_AccountantAccountCode:Text") <> "U"
					Aadd( aCab, { "A6_CONTA",oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ListOfAccount:_Account:_AccountantAccountCode:Text, Nil })
				EndIf

				//Novas TAGs
				//Digito da Conta
				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ListOfAccount:_Account:_DigitAccount:Text") <> "U"
					Aadd( aCab, { "A6_DVCTA",oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ListOfAccount:_Account:_DigitAccount:Text, Nil })
				EndIf

   				//Número do Contrato
				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ListOfAccount:_Contract:_ContractNumber:Text") <> "U"
					cContractNumber := oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ListOfAccount:_Contract:_ContractNumber:Text
				EndIf

				//Nome do Cedente
				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ListOfAccount:_Contract:_TransferorName:Text") <> "U"
					cTransfNam := oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ListOfAccount:_Contract:_TransferorName:Text
				EndIf

				//Código do Cedente
				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ListOfAccount:_Contract:_TransferorCode:Text") <> "U"
					Aadd( aCab, { "A6_CODCED",oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ListOfAccount:_Contract:_TransferorCode:Text, Nil })
				EndIf

				//Tipo da Carteira Bancária
				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ListOfAccount:_Contract:_BookType:Text") <> "U"
					cBookType := oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ListOfAccount:_Contract:_BookType:Text
				EndIf

				//Carteira Bancária
				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ListOfAccount:_Contract:_BookCode:Text") <> "U"
					cBookCode := oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ListOfAccount:_Contract:_BookCode:Text
				EndIf

				//Tipo de Cobrança
				If Type("oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ListOfAccount:_Contract:_ChargeType:Text") <> "U"
					cChargeType := oXmlA070:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgency:_Agency:_ListOfAccount:_Contract:_ChargeType:Text
				EndIf
				//Novas TAGs

				//Função para manutenção do cadastro de parâmetros de bancos
				//Caso o registro na SEE não exista, o mesmo será criado
				FA130Receive(IIf(nOpcExec <> 5,'upsert','delete'),cCod,cAgencia,cConta,cContractNumber,;
							{cContractNumber,cBooktype,cBookCode,cChargeType})

				MSExecAuto({|x,y| MATA070(x,y)},aCab,nOpcExec)

				If lMsErroAuto
					cLogErro:=""
					aErroAuto := GetAutoGRLog()
					For nCount := 1 To Len(aErroAuto)
						cLogErro += '<Message type="ERROR" code="c2">'+StrTran(StrTran(StrTran(aErroAuto[nCount],"<"," "),"-"," "),"/"," ")+" "+'</Message>'
					Next nCount
					//Monta XML de Erro de execução da rotina automatica.
 					lRet:=.F.
					cXmlRet:=cLogErro
				Else
					If nOpcExec # 5
						If FindFunction('CFGA070Mnt')
							cValInt:=M70MontInt(,cCod,cAgencia,cConta)//+ SA6->A6_COD + SA6->A6_AGENCIA + SA6->A6_NUMCON
	    					//Inclui ou Altera quando vem de Outro ERP e devolve para o ERP
							CFGA070Mnt( cMarca, cAlias, cField, cValExt, cValInt ) //Grava na Tabela XXF
							lRet:= .T.

				            // Monta o XML de retorno
				            cXmlRet := "<ListOfInternalId>"
				            cXmlRet +=     "<InternalId>"
				            cXmlRet +=         "<Name>Bank</Name>"
				            cXmlRet +=         "<Origin>" + cValExt + "</Origin>" // Valor recebido na tag
				            cXmlRet +=         "<Destination>" + cValInt + "</Destination>" // Valor XXF gerado
				            cXmlRet +=     "</InternalId>"
				            cXmlRet += "</ListOfInternalId>"

						Endif
					ElseIf nOpcExec == 5
						If !Empty( cValInt )
	  		    			If FindFunction('CFGA070Mnt')
	    						//Exclui quando vem de outro ERP
	   							CFGA070Mnt(, cAlias, cField,, cValInt, .T. )  // Deleta o XXF
							Endif
	    				Endif
					EndIf
				EndIf
			EndIf
		Else
			lRet := .F.
		EndIf
	End Case
End Case

Return {lRet,cXmlRet}
