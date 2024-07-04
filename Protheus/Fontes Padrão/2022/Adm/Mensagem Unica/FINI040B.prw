#include "Protheus.ch"
#Include "FWAdapterEAI.ch"
#Include "FINI040B.CH"

/*
{Protheus.doc} FINI040B
	Atualização da situação bancária do título

@param	cXml       - XML recebido pelo EAI Protheus
		cTypeTrans - Tipo de transação
					"0" = TRANS_RECEIVE
					"1" = TRANS_SEND
		cTypeMsg   - Tipo da mensagem do EAI
					"20" = EAI_MESSAGE_BUSINESS
					"21" = EAI_MESSAGE_RESPONSE
					"22" = EAI_MESSAGE_RECEIPT
					"23" = EAI_MESSAGE_WHOIS
		cVersion   - Versão da Mensagem Única TOTVS
		cTransac   - Nome da mensagem iniciada no adapter.

	@retorno aRet  - Array contendo o resultado da execução e a mensagem Xml de retorno.
				aRet[1]	(boolean) Indica o resultado da execução da função
				aRet[2]	(caracter) Mensagem Xml para envio

	@author	Rodrigo Machado Pontes
	@version	P11
	@since	26/08/2014
*/
Function FINI040B(cXml, cTypeTrans, cTypeMsg, cVersion, cTransaction)

Local lRet     	:= .T.
Local cXMLRet  	:= ""
Local aRet		:= {}
Private lMsErroAuto		:= .F.
Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile	:= .T.

If Empty(cVersion)
	lRet    := .F.
	cXmlRet := OemToAnsi(STR0001)
ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
	cXMLRet := "1.000|1.001"
Else
	If cVersion = "1."
		aRet := v1000(cXml, cTypeTrans, cTypeMsg)
		lRet	:= aRet[1]
		cXmlRet := aRet[2]
	Endif
EndIf

If !lRet
	cXmlRet := EncodeUTF8(cXmlRet)
Endif

Return {lRet, cXMLRet, "UpdateContractStatusParcel"}


/*
{Protheus.doc} v1000
	Atualização da situação bancario do título

	@param	cXML      		Conteudo xml para envio/recebimento
	@param	cTypeTrans		Tipo de transacao. (Envio/Recebimento)
	@param	cTypeMsg		Tipo de mensagem. (Business Type, WhoIs, etc)

	@retorno aRet			Array contendo o resultado da execucao e a mensagem Xml de retorno.
				aRet[1]	(boolean) Indica o resultado da execução da função
				aRet[2]	(caracter) Mensagem Xml para envio

	@author	Rodrigo Machado Pontes
	@version	P11
	@since	26/08/2014
*/
Static Function v1000(cXml, cTypeTrans, cTypeMsg)

Local cXMLRet	:= ""
Local lRet		:= .T.
Local oXml		:= ""
Local cError	:= ""
Local cWarning	:= ""
Local cMarca	:= ""
Local cValExt	:= ""
Local cStatus	:= ""
Local cBanco	:= ""
Local cNumBco	:= ""
Local aRet		:= {}
Local nX		:= 0
Local cTitRet	:= ""
Local nCntErr	:= 0
//Modelo padrão
Local aTitulo	:={}
Local aTit		:={}
Local aBanco	:={}
Local aErroRet	:={}

If cTypeTrans == TRANS_RECEIVE
   If cTypeMsg == EAI_MESSAGE_BUSINESS		
		
		oXml := XmlParser(cXml, "_", @cError, @cWarning)
		If Empty(oXml) .AND. "UTF-8" $ UPPER(cXml)
			cXML := EncodeUTF8( cXML )
    	   	oXml := XmlParser( cXML, "_", @cError, @cWarning )
		EndIf
		
		If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
		
			//Verifica se a marca foi informada
			If ValType("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
				cMarca := oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text
			Else
				lRet := .F.
				aAdd(aErroRet,STR0002)//"Product é obrigatório!"
			Endif
			
			If ValType("oXML:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountDocumentInternalId:Text") != "U" .And. !Empty(oXML:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountDocumentInternalId:Text)
				cValExt	:= oXML:_TotvsMessage:_BusinessMessage:_BusinessContent:_AccountDocumentInternalId:Text              
			Else
				lRet := .F.
				aAdd(aErroRet,STR0003) //"AccountDocumentInternalId é obrigatório!"
			EndIf
					
			If ValType("oXML:_TotvsMessage:_BusinessMessage:_BusinessContent:_RemmitedBank:Text") != "U" .And. !Empty(oXML:_TotvsMessage:_BusinessMessage:_BusinessContent:_RemmitedBank:Text)
				cStatus := oXML:_TotvsMessage:_BusinessMessage:_BusinessContent:_RemmitedBank:Text				
			Else
				lRet:= .F.
				aAdd(aErroRet,STR0001) ///"RemmitedBank é obrigatório!"
			EndIf		

			If ValType("oXML:_TotvsMessage:_BusinessMessage:_BusinessContent:_OurNumberBanking:Text") != "U" .And. !Empty(oXML:_TotvsMessage:_BusinessMessage:_BusinessContent:_OurNumberBanking:Text)
				cNumBco := oXML:_TotvsMessage:_BusinessMessage:_BusinessContent:_OurNumberBanking:Text				
			EndIf
			
			If ValType("oXML:_TotvsMessage:_BusinessMessage:_BusinessContent:_BankInternalId:Text") != "U" .And. !Empty(oXML:_TotvsMessage:_BusinessMessage:_BusinessContent:_BankInternalId:Text)
				cBanco := oXML:_TotvsMessage:_BusinessMessage:_BusinessContent:_BankInternalId:Text				
			EndIf

			aTitulo := IntTRcInt(cValExt,cMarca)
			If aTitulo[1]
				aAdd(aTit, {"E1_FILIAL"		, PadR(aTitulo[2][2], TamSX3("E1_FILIAL")[1])	,Nil})
				aAdd(aTit, {"E1_PREFIXO"	, PadR(aTitulo[2][3], TamSX3("E1_PREFIXO")[1])	,Nil})
				aAdd(aTit, {"E1_NUM"		, PadR(aTitulo[2][4], TamSX3("E1_NUM")[1])		,Nil})
				aAdd(aTit, {"E1_PARCELA"	, PadR(aTitulo[2][5], TamSX3("E1_PARCELA")[1])	,Nil})
				aAdd(aTit, {"E1_TIPO"		, PadR(aTitulo[2][6], TamSX3("E1_TIPO")[1])		,Nil})
				cTitRet := RTrim(aTitulo[2][1] + "|" + aTitulo[2][2] + "|" + aTitulo[2][3] + "|" + aTitulo[2][4] + "|" + aTitulo[2][5] + "|" + aTitulo[2][6])
			Else
				lRet:= .F.
				aAdd(aErroRet,aTitulo[2] + cValExt)//"Não foi localizado o de/para para o título"
			Endif

			If ALLTRIM(cStatus) <> "0"	//Para o status 0 o título está sendo retirado do banco, nesse caso não temos banco.
				aBanco:= M70GetInt(cBanco, cMarca)
				If aBanco[1]
					aAdd(aTit, {"AUTBANCO"		, PadR(aBanco[2][3],TamSX3("A6_COD")[1])		,Nil})
					aAdd(aTit, {"AUTAGENCIA"	, PadR(aBanco[2][4],TamSX3("A6_AGENCIA")[1])	,Nil})
					aAdd(aTit, {"AUTCONTA"		, PadR(aBanco[2][5],TamSX3("A6_NUMCON")[1])		,Nil})
					aAdd(aTit, {"AUTSITUACA"	, "1"											,Nil})
					aAdd(aTit, {"AUTNUMBCO"		, PadR(cNumBco,TamSX3("E1_NUMBCO")[1])			,Nil})
				Else
					lRet:= .F.
					aAdd(aErroRet,STR0005)	//"Não foi localizado o de/para para o banco "
				Endif
			Else
				aAdd(aTit, {"AUTBANCO"		, ""	,Nil})
				aAdd(aTit, {"AUTAGENCIA"	, ""	,Nil})
				aAdd(aTit, {"AUTCONTA"		, ""	,Nil})
				aAdd(aTit, {"AUTSITUACA"	, "0"	,Nil})
				aAdd(aTit, {"AUTNUMBCO"		, ""	,Nil})			
			EndIf
			
			If lRet
				
				MSExecAuto({|a, b| FINA060(a, b)}, 2, aTit )

				If lMsErroAuto
					aErroAuto := GetAutoGRLog()
					lRet:=.F.
					For nCntErr := 1 To Len(aErroAuto)
						aAdd(aErroRet,StrTran(StrTran(StrTran(aErroAuto[nCntErr],"<"," "),"-"," "),"/"," ")+" ")
					Next
				EndIf 

			EndIf

			If lRet == .T.
				cXmlRet :="<ListInternalId>"
				cXmlRet += "<InternalId>"
				cXMLRet +=  "<DestinationInternalId>"+ cTitRet +"</DestinationInternalId>"  
				cXMLRet +=  "<OriginInternalId>"+ cValExt  +"</OriginInternalId>"
				cXmlRet += "</InternalId>"
			Else
				For nX:=1 to len(aErroRet)
					cXmlRet+='<Message type="ERROR" code="c2">'+aErroRet[nX]+'</Message>'
				Next
			Endif

		Endif
	EndIf

ElseIf cTypeTrans == TRANS_SEND
	cXMLRet :=	"<BusinessContent>"
	cXMLRet +=		"<CompanyInternalId>" + cEmpAnt + "|" + cFilAnt + "</CompanyInternalId>"
	cXMLRet +=		"<BranchId>" + cFilAnt+ "</BranchId>"
	If FindFunction("IntTRcExt")
		cXMLRet +=		"<AccountDocumentInternalId>" + IntTRcExt(,SE1->E1_FILIAL,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO)[2]+ "</AccountDocumentInternalId>"
	Else
		cXMLRet +=		"<AccountDocumentInternalId>" + AllTrim(cEmpAnt) + "|" + AllTrim(SE1->E1_FILIAL) + "|" + AllTrim(SE1->E1_PREFIXO) + "|" + AllTrim(SE1->E1_NUM) + "|" + AllTrim(SE1->E1_PARCELA) + "|" + AllTrim(SE1->E1_TIPO) + "</AccountDocumentInternalId>"
	Endif
	cXMLRet +=		"<RemittedBank>" + SE1->E1_SITUACA+ "</RemittedBank>"
	cXMLRet +=	"</BusinessContent>"
Endif

cXmlret := FwnoAccent(cXmlRet)
cXmlRet := EncodeUTF8(cXmlRet)

Return {lRet, cXmlRet}
