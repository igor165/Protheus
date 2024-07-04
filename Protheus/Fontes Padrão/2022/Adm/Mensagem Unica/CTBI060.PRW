#Include "PROTHEUS.ch"
#Include "FWMVCDEF.CH"
#Include "FWADAPTEREAI.CH"
#include "CTBI060.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBI060
Mensagem unica de envio/recebimento de Classe de Valor - ClassValue

@param cXml       XML passado para a rotina.
@param cTypeTrans Determina se e uma mensagem a ser enviada/recebida ( TRANS_SEND ou TRANS_RECEIVE)
@param cTypeMsg   Tipo de mensagem ( EAI_MESSAGE_WHOIS,EAI_MESSAGE_RESPONSE,EAI_MESSAGE_BUSINESS)

@return lRet indica se a mensagem foi processada com sucesso
@return cXmlRet Xml de retorno da funcao

@author Pedro Pereira Lima
@since 19/03/2014
@version P12
/*/
//-------------------------------------------------------------------
Function CTBI060(cXml, cTypeTrans , cTypeMsg, cVersion, cTransac)

Local cXmlRet			:= ''
Local cErroXml			:= ''
Local cWarnXml			:= ''
Local oXml				:= ''
Local cMarca			:= ''
Local cEvent			:= 'upsert'
Local cAlias			:= 'CTH'
Local cField			:= 'CTH_CLVL'
Local cClasseValor		:= ''
Local cDescricaoClVl	:= ''
Local cClasseClVl		:= ''
Local cSituacaoClVl		:= ''
Local cValExt			:= ''
Local cValInt			:= ''
Local aAutoCab			:= {}
Local aErroAuto			:= {}
Local aDePara			:= {}
Local aRotAuto			:= {}
Local lRet				:= .T.
Local lLog				:= FindFunction("AdpLogEAI")
Local nCount			:= 0
Local nPorta			:= 0
Local nPonto			:= 0
Local nListOfInternalId	:= 0
Private lMsErroAuto		:= .F.
Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile	:= .T.

IIf(lLog, AdpLogEAI(1, "CTBI060", cTypeTrans, cTypeMsg, cXml), ConOut(STR0001))

//Verifico o tipo de mensagem
If cTypeTrans == TRANS_SEND //Mensagem de saída
	// Verica operação realizada
	If lLog
		Do Case
			Case Inclui
				AdpLogEAI(4,3)
			Case Altera
				AdpLogEAI(4,4)
			OtherWise
				AdpLogEAI(4,5)
		EndCase
	Else
		ConOut(STR0001)
	EndIf

	cValInt := cEmpAnt + '|' + XFilial("CTH") + '|' + AllTrim(CTH->CTH_CLVL)

	If !Inclui .And. !Altera
		cEvent := 'delete'

		CFGA070Mnt(,cAlias,cField,,cValInt,.T.)
	EndIf

	cXMLRet := '<BusinessEvent>'
	cXMLRet += ' <Entity>ClassValue</Entity>'
	cXMLRet += ' <Event>' + cEvent + '</Event>'
	cXMLRet += ' <Identification>'
	cXMLRet += '  <key name="InternalId">' + cValInt + '</key>'
	cXMLRet += ' </Identification>'
	cXMLRet += '</BusinessEvent>'
	cXMLRet += '<BusinessContent>'
	cXMLRet += ' <CompanyId>' + cEmpAnt + '</CompanyId>'
	cXMLRet += ' <BranchId>' + cFilAnt + '</BranchId>'
	cXMLRet += ' <CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
	cXMLRet += ' <Code>' + RTrim(CTH->CTH_CLVL) + '</Code>'
	cXMLRet += ' <InternalId>' + cValInt + '</InternalId>'
	cXMLRet += ' <Name>' + RTrim(CTH->CTH_DESC01) + '</Name>'
	cXMLRet += ' <Class>' + RTrim(CTH->CTH_CLASSE) + '</Class>'
	cXMLRet += ' <RegisterSituation>' + If(RTrim(CTH->CTH_BLOQ) == '2', 'Active', 'Inactive') + '</RegisterSituation>'
	cXMLRet += ' <TopCode>' + RTrim(CTH->CTH_CLSUP) + '</TopCode>'
	cXMLRet += '</BusinessContent>'

ElseIf cTypeTrans == TRANS_RECEIVE //Mensagem de entrada
	If cTypeMsg == EAI_MESSAGE_WHOIS
			cXmlRet := '1.000|1.001'

	ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE
		//Faz o parser do XML de retorno em um objeto
		oXML := xmlParser(cXML, "_", @cErroXml, @cWarnXml)

		If oXml != Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
			// Se não houve erros na resposta
			If Upper(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
				// Verifica se a marca foi informada
	            If XmlChildEx(oXML:_TOTVSMessage:_MessageInformation:_Product,"_NAME") <> Nil .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
	               cMarca := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
	            Else
	               lRet := .F.
	               cXmlRet := STR0002 //"Erro no retorno. O Product é obrigatório!"
	               Return {lRet, cXmlRet}
	            EndIf
				If Upper(oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_Event:Text) == "UPSERT"
		            // Se não for array
		            If ValType(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId) != "A"
		               // Transforma em array
		               XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId, "_InternalId")
		            EndIf

		            For nCount := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId)
		               //Array para armazenar os valores de retorno para gravar no de/para onde:
		               //[1] Armazena o Origin
		               //[2] Armazena o Destination
		               aAdd(aDePara, Array(2))

		               //Verifica se o InternalId foi informado
		               If ValType(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nCount]:_Origin:Text) != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nCount]:_Origin:Text)
		                  aDePara[nCount][1] := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nCount]:_Origin:Text
		               Else
		                  lRet := .F.
		                  cXmlRet := STR0003 //"Erro no retorno. O OriginalInternalId é obrigatório!"
		                  IIf(lLog, AdpLogEAI(5, "CTBI060", cXMLRet, lRet), ConOut(STR0001))
		                  Return {lRet, cXmlRet}
		               EndIf

		               //Verifica se o código externo foi informado
		               If ValType(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nCount]:_Destination:Text) != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nCount]:_Destination:Text)
		                  aDePara[nCount][2] := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nCount]:_Destination:Text
		               Else
		                  lRet := .F.
		                  cXmlRet := STR0004 //"Erro no retorno. O DestinationInternalId é obrigatório!"
		                  IIf(lLog, AdpLogEAI(5, "CTBI060", cXMLRet, lRet), ConOut(STR0001))
		                  Return {lRet, cXmlRet}
		               EndIf

		               //Envia os valores de InternalId e ExternalId para o Log
		               If lLog
		                  AdpLogEAI(3, "cValInt" + Str(nCount) + ": ", aDePara[nCount][1]) // InternalId
		                  AdpLogEAI(3, "cValExt" + Str(nCount) + ": ", aDePara[nCount][2]) // ExternalId
		               Else
		                  ConOut(STR0001)
		               EndIf

		               nListOfInternalId++
		            Next nCount

					//Loop para manipular os InternalId no de/para
					For nCount := 1 To nListOfInternalId
						CFGA070Mnt(cMarca, cAlias, cField, aDePara[nCount][2], aDePara[nCount][1], .F.)
					Next nCount
				Endif
			Else
				//Se não for array
				If ValType(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message) != "A"
					//Transforma em array
					XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
				EndIf

				//Percorre o array para obter os erros gerados
				For nCount := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
					cErroXml := oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text + Chr(10)
				Next nCount

				lRet := .F.
				cXmlRet := cErroXml
				IIf(lLog, AdpLogEAI(5, "CTBI060", cXMLRet, lRet),ConOut(STR0001))

			EndIf
		Else
			lRet    := .F.
			cXmlRet := STR0008 //"Erro no parser!"
			Return {lRet, cXmlRet}
		EndIf

	ElseIf cTypeMsg == EAI_MESSAGE_BUSINESS
		oXml := xmlParser(cXml, "_", @cErroXml, @cWarnXml)

		If oXml != Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
			//Verifica se a marca foi informada
			If XmlChildEx(oXML:_TOTVSMessage:_MessageInformation:_Product, "_NAME") <> Nil .And. !Empty(oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
               cMarca := oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text
            Else
               lRet := .F.
               cXmlRet := STR0009 //"Informe a Marca!"
               IIf(lLog, AdpLogEAI(5, "CTBI060", cXMLRet, lRet), ConOut(STR0001))
               Return {lRet, cXmlRet}
            EndIf

            //Verifica se o InternalId foi informado
			If XmlChildEx(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent, "_INTERNALID") <> Nil .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
               cValExt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
            Else
               lRet := .F.
               cXmlRet := STR0010 //"O InternalId é obrigatório!"
               IIf(lLog, AdpLogEAI(5, "CTBI060", cXMLRet, lRet), ConOut(STR0001))
               Return {lRet, cXmlRet}
            EndIf

            //Obtém o valor interno
            aAux := C060GetInt(cValExt, cMarca)

            // Obtém dados utilizado somente no UPSERT
			If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
				// Se o registro existe
				If aAux[1]
					nOpcx := 4 // Update

					cClasseValor := PadR(aAux[2][3], TamSX3("CTH_CLVL")[1])

				Else
					nOpcx := 3 // Insert

					//Verifica se o Código da Classe de Valor foi informado
					If XmlChildEx(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent,"_CODE") <> Nil .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text)
						cClasseValor := PadR(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text, TamSX3("CTH_CLVL")[1])
					Else
						lRet := .F.
						cXmlRet := STR0011 //"Informe o Código da Classe de Valor"
						IIf(lLog, AdpLogEAI(5, "CTBI060", cXMLRet, lRet), ConOut(STR0001))
						Return {lRet, cXmlRet}
					EndIf
				EndIf

				//Verifica se a Descrição da Classe de Valor foi informada
				If XmlChildEx(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent,"_NAME") <> Nil .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Name:Text)
					cDescricaoClVl := AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Name:Text)
				Else
					lRet := .F.
					cXmlRet := STR0012 //"Informe a Descrição da Classe de Valor"
					IIf(lLog, AdpLogEAI(5, "CTBI060", cXMLRet, lRet), ConOut(STR0001))
					Return {lRet, cXmlRet}
				EndIf

				//Verifica se a Classe (Sintética/Analítica) da Classe de Valor  foi informada
				If XmlChildEx(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent,"_CLASS") <> Nil .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Class:Text)
					cClasseClVl := AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Class:Text)
				Else
					lRet := .F.
					cXmlRet := STR0013 //"Informe a Classe Sintética-Analítica da Classe de Valor"
					IIf(lLog, AdpLogEAI(5, "CTBI060", cXMLRet, lRet), ConOut(STR0001))
					Return {lRet, cXmlRet}
				EndIf


				//Verifica se a Situação (Ativa/Inativa) da Classe de Valor foi informada
				If XmlChildEx(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent,"_REGISTERSITUATION") <> Nil .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterSituation:Text)
					If oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterSituation:Text == 'Active'
           			 cSituacaoClVl:=  '2'
       			 Else
           			cSituacaoClVl:= '1'
        			Endif

					//cSituacaoClVl := AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterSituation:Text)
				Else
					lRet := .F.
					cXmlRet := STR0014 //"Informe a Situação Ativa-Inativa da Classe de Valor"
					IIf(lLog, AdpLogEAI(5, "CTBI060", cXMLRet, lRet), ConOut(STR0001))
					Return {lRet, cXmlRet}
				EndIf

            ElseIf Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
				// Se o registro existe
				If aAux[1]
					nOpcx := 5 // Delete

					cClasseValor	:= aAux[2][3]

					cValInt			:= aAux[3]

				Else
					lRet := .F.
					cXmlRet := STR0015 //'A Classe de Valor a ser excluída não foi encontrada na base Protheus'
					Return {lRet, cXmlRet}
				EndIf
			Else
				lRet := .F.
				cXmlRet := STR0016 //"O evento informado é inválido"
				Return {lRet, cXmlRet}
            EndIf

			aAdd(aRotAuto, {"CTH_CLVL"	, PadR(cClasseValor, TamSX3("CTH_CLVL")[1])		, Nil})
			aAdd(aRotAuto, {"CTH_DESC01", PadR(cDescricaoClVl,TamSX3("CTH_DESC01")[1])	, Nil})
			aAdd(aRotAuto, {"CTH_CLASSE", PadR(cClasseClVl, TamSX3("CTH_CLASSE")[1])	, Nil})
			aAdd(aRotAuto, {"CTH_BLOQ"	, PadR(cSituacaoClVl, TamSX3("CTH_BLOQ")[1])	, Nil})

			If XmlChildEx(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent,"_TopCode") <> Nil
				aAdd(aRotAuto, {"CTH_CLSUP", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TopCode:Text, Nil})
			Endif

            //LOG
            If lLog
               AdpLogEAI(3, "aRotAuto"	, aRotAuto)
               AdpLogEAI(3, "cValInt: "	, cValInt)
               AdpLogEAI(3, "cValExt: "	, cValExt)
               AdpLogEAI(4, nOpcx)
            Else
               ConOut(STR0001)
            EndIf

            MSExecAuto({|x,y| CTBA060(x,y)}, aRotAuto, nOpcx)

            // Se houve erros no processamento do MSExecAuto
			If lMsErroAuto
				aErroAuto := GetAutoGRLog()

				cXMLRet := "<![CDATA["
				For nCount := 1 To Len(aErroAuto)
					cXMLRet += aErroAuto[nCount] + Chr(10)
				Next nCount
				cXMLRet += "]]>"

				lRet := .F.
			Else
				If nOpcx != 5 // Se o evento é diferente de delete
					// Grava o registro na tabela XXF (de/para)
					cValInt := C060MntInt(cFilAnt,CTH->CTH_CLVL)
					CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .F.)

					// Monta o XML de retorno
					cXMLRet := "<ListOfInternalId>"
					cXMLRet +=    "<InternalId>"
					cXMLRet +=       "<Name>ClassValue</Name>"
					cXMLRet +=       "<Origin>" + cValExt + "</Origin>"
					cXmlRet +=       "<Destination>" + cValInt + "</Destination>"
					cXMLRet +=    "</InternalId>"
					cXMLRet += "</ListOfInternalId>"
				Else
					// Exclui o registro na tabela XXF (de/para)
					CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .T.)
				EndIf
			EndIf
		Else
			lRet    := .F.
            cXmlRet := STR0008 //"Erro no parser!"
            Return {lRet, cXmlRet}
		EndIf
	Endif
EndIf

cXmlRet := EncodeUTF8(cXmlRet)

Return { lRet, cXmlRet }

//-------------------------------------------------------------------
/*/{Protheus.doc} C060GetInt
Recebe um codigo, busca seu InternalId e faz a quebra da chave

@param cCodigo - InternalID recebido na mensagem.
@param cMarca - Produto que enviou a mensagem

@author	Pedro Pereira Lima
@version P12
@since 20/03/14
@return	aRetorno Array contendo os campos da chave primaria da classe de valor e o seu internalid.
@sample	exemplo de retorno - {.T., {'Empresa', 'xFilial', 'Codigo' },InternalId}
/*/										//   01          02         03
//-------------------------------------------------------------------
Function C060GetInt(cCodigo, cMarca)
Local cValInt	:= ''
Local aRetorno	:= {}
Local aAux		:= {}
Local nX		:= 0
Local aCampos	:= {cEmpAnt,'CTH_FILIAL','CTH_CLVL'}

cValInt := CFGA070Int(cMarca, 'CTH', 'CTH_CLVL', AllTrim(cCodigo))
If !Empty(cValInt)
	aAux := Separa(cValInt,'|')

	aAdd(aRetorno, .T. )
	aAdd(aRetorno, aAux )
	aAdd(aRetorno, cValInt )

	aRetorno[2][1] := Padr(aRetorno[2][1],Len(cEmpAnt))

	For nX := 2 To 	Len(aRetorno[2]) //corrigindo  o tamanho dos campos
		aRetorno[2][nX] := Padr(aRetorno[2][nX],TamSX3(aCampos[nx])[1])
	Next nX
Else
	aAdd(aRetorno,.F.)
	aAdd(aRetorno, STR0017 + cCodigo + STR0018) //"Classe de Valor " + " não encontrada no De/Para!"
EndIf

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} C060MntInt
Recebe um registro no Protheus e gera o InternalId deste registro

@param		cFil	Filial do Registro
@param		cCod	Código da Classe de Valor

@author		Pedro Pereira Lima
@version	P12
@since		20/03/14
@return		cRetorno - Retorna o InternalId do registro
@sample		exemplo de retorno - {'Empresa'|'xFilial'|'ClasseValor'}
/*/
//-------------------------------------------------------------------
Function C060MntInt(cIntFil,cCodClVl)
Local cRetCode	:= ''
Default cIntFil	:= xFilial('CT2')

cIntFil	:= xFilial("CT2",cIntFil)

cRetCode := cEmpAnt + '|' + cIntFil + '|' + AllTrim(cCodClVl)

Return cRetCode
