#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "TMSI450.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao   ³ TMSI450     º Autor ³ Tiago dos Santos   º Data ³ 13/09/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Funcao de integracao com o adapter EAI para recebimento  e   º±±
±±º          ³ envio do XML de Local de Endereço,usando a entidade(DUL).    º±±
±±º          ³ Conceito de mensagem unica.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Param.   ³ cXML - Variavel com conteudo xml para envio/recebimento.     º±±
±±º          ³ nTypeTrans - Tipo de transacao. (Envio/Recebimento)          º±±
±±º          ³ cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, etc) º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno  ³ aRet - Array contendo o resultado da execucao e a mensagem   º±±
±±º          ³        Xml de retorno.                                       º±±
±±º          ³ aRet[1] - (boolean) Indica o resultado da execução da função º±±
±±º          ³ aRet[2] - (caracter) Mensagem Xml para envio                 º±±
±±º          ³ aRet[3] - (caracter) Nome da Mensagem Transacional que iden- º±±
±±º          ³           tifica a integracao para execução pelo adapter EAI.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ TMSA450                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function TMSI450(cXml,nType,cTypeMsg)
Local aResult           := {}
Private cEntityName    	:= "CUSTOMERSHIPPINGADDRESS"
Private lMsErroAuto		:= .F.	//Armazena o status da execucao da MsExecAuto
Private lAutoErrNoFile	:= .T.
Private cVersion        := "1.000"

//+---------------------------------------------------------------------
//| Mensagem - ENVIO
//+---------------------------------------------------------------------
If nType == TRANS_SEND
	aResult := _FSend()

	//+---------------------------------------------------------------------
	//| Mensagem - Recebimento
	//+---------------------------------------------------------------------
ElseIf nType == TRANS_RECEIVE
	aResult := _FReceive(cXml,cTypeMsg)

EndIf

//- Adiciona o nome da Transação da mensagem no cadastro do Adapter EAI
//- Gatilha o campo XX4_MODEL
AAdd(aResult,cEntityName)

      
Return aResult


/*/
=================================================================================
{Protheus.doc} _FSend

//TODO Descrição : Funcao para tratar o xml de recebimento
@author tiago.dsantos
@since 15/09/2016
@version undefined
@param cXml, characters, descricao
@type function
=================================================================================
/*/
Static Function _FSend()
Local cXmlRet     := ""
Local lResult     := .T.
Local cEvent      := "upsert"
Local cInternalId := ""
Local cDatAtu     := Transform(dToS(dDataBase),"@R 9999-99-99")
Local cCodCli     := ""
Local cLojCli     := ""
        
Local cEnderExId  := "" 
Local cEnderCod   := ""
Local cEndereco   := ""
Local cEnderNum   := ""
Local cCidade     := ""
Local cCep        := ""
Local cBairro     := ""
Local cUF         := ""
Local cUFDescr    := ""
Local cPais       := ""
Local cPaisDescr  := ""
Local cInsEst     := ""
Local cSuframa    := ""
Local cCnpjCPF    := "" 
Local aError      := {}
Local cCXPostal   := ""
Local cRegiao     := ""
Local cEndCompl   := ""
Local cCdrDes     := ""

If !INCLUI .And. !ALTERA
	cEvent	:= "delete"
EndIf

cInternalId := getIntlId()

cCodCli     := DUL->DUL_CODCLI
cLojCli     := DUL->DUL_LOJCLI
cEnderExId  := ""
cEnderCod   := DUL->DUL_SEQEND
cEndereco   := trataEnd(DUL->DUL_END, "L")//| Essa rotina esta localizada no Mati030
cEnderNum   := trataEnd(DUL->DUL_END, "N")//| Iif(At(DUL->DUL_END,",") > 0, SubStr(AllTrim(DUL->DUL_END),At(DUL->DUL_END,",")),"")
cCodCidade  := DUL->DUL_CODMUN
cCidade     := AllTrim(DUL->DUL_MUN)
cCep        := DUL->DUL_CEP
cBairro     := AllTrim(DUL->DUL_BAIRRO)
cUF         := DUL->DUL_EST
cUFDescr    := Tabela("12",cUF,.F.)
cEndCompl   := ""
cCXPostal   := ""
cCdrDes     := DUL->DUL_CDRDES
cPais       := Posicione("DUY",1,xFilial("DUY")+cCdrDes,"DUY_PAIS")

DbSelectArea("SA1")
DbSetOrder(1)
MsSeek(xFILIAL("SA1")+DUL->(DUL_CODCLI+DUL_LOJCLI))

cInsEst     := AllTrim(SA1->A1_INSCR)
cSuframa    := AllTrim(SA1->A1_SUFRAMA)
cCnpjCPF    := AllTrim(SA1->A1_CGC)

cIEDesp     := AllTrim(DUL->DUL_INSCR)
cSufraDesp  := ""
cCGCDesp    := AllTrim(DUL->DUL_CGC)

If Empty(cPais)
	cPais := SA1->A1_PAIS
EndIf 

cXMLRet := "<BusinessEvent>"
cXMLRet +=     "<Entity>" + cEntityName + "</Entity>"
cXMLRet +=     "<Event>" + cEvent + "</Event>"
cXMLRet +=     "<Identification>"
cXMLRet +=          "<key name='InternalId'>" + cInternalId + "</key>"
cXMLRet +=     "</Identification>"
cXMLRet += "</BusinessEvent>"

cXMLRet += "<BusinessContent>"
cXMLRet +=      "<CompanyId>"         + cEmpAnt                 								+ "</CompanyId>"
cXMLRet +=      "<BranchId>"          + cFilAnt                						 			+ "</BranchId>"
cXMLRet +=      "<CompanyInternalId>" + cEmpAnt                 								+ "</CompanyInternalId>"
cXMLRet +=      "<BranchInternalId>"  + cEmpAnt + "|" + cFilAnt 								+ "</BranchInternalId>"
cXMLRet +=      "<CustomerCode>"      + cCodCli + IIF(FwHasEAI("MATA020B",.T.,,.T.),'',+cLojCli)+ "</CustomerCode>"
cXMLRet +=      "<InternalId>"        + cInternalId             								+ "</InternalId>"

cXMLRet +=      "<GovernmentalInformation>"
cXMLRet +=             "<Id scope='State'   name='INSCRICAO ESTADUAL' issueOn='" + cDatAtu + "' expiresOn=''>" + cInsEst  + "</Id>"
cXMLRet +=             "<Id scope='Federal' name='SUFRAMA'            issueOn='" + cDatAtu + "' expiresOn=''>" + cSuframa + "</Id>"
cXMLRet +=             "<Id scope='Federal' name='CNPJCPF'            issueOn='" + cDatAtu + "' expiresOn=''>" + cCnpjCPF + "</Id>"
cXMLRet +=      "</GovernmentalInformation>"

cXMLRet +=      "<Code>"         + cEnderCod  + "</Code>"
cXMLRet +=      "<ExternalId>"   + cEnderExId + "</ExternalId>"

SA1->(DbSetOrder(1))
If SA1->(dbSeek(xFilial('SA1') + DUL->DUL_CODRED + DUL->DUL_LOJRED))
	cXMLRet +=      "<ShippingAddressInformation>"
	cXMLRet +=             "<Id scope='State'   name='INSCRICAO ESTADUAL' issueOn='" + cDatAtu + "' expiresOn=''>" + AllTrim(SA1->A1_INSCR) + "</Id>"
	cXMLRet +=             "<Id scope='Federal' name='SUFRAMA'            issueOn='" + cDatAtu + "' expiresOn=''>" + cSufraDesp              + "</Id>"
	cXMLRet +=             "<Id scope='Federal' name='CNPJCPF'            issueOn='" + cDatAtu + "' expiresOn=''>" + AllTrim(SA1->A1_CGC)    + "</Id>"
	cXMLRet +=      "</ShippingAddressInformation>"
	cCdrDes     := Iif(!Empty(cCdrDes),cCdrDes,SA1->A1_CDRDES)
	cPais       := SA1->A1_PAIS
ELSE
	cXMLRet +=  "<ShippingAddressInformation></ShippingAddressInformation>"
EndIf

cRegiao     := AllTrim(Posicione("DUY",1,xFilial("DUY")+cCdrDes,"DUY_DESCRI"))
cPaisDescr  := AllTrim(Posicione("SYA",1,xFILIAL("SYA") + PadR(cPais,TamSx3("YA_CODGI")[1]),"YA_DESCR"))

cXMLRet +=      "<ShippingAddress>"
cXMLRet +=            "<Address>"     + cEndereco + "</Address>"
cXMLRet +=            "<Number>"      + cEnderNum + "</Number>"
cXMLRet +=            "<Complement>"  + cEndCompl + "</Complement>"
cXMLRet +=            "<District>"    + cBairro   + "</District>"
cXMLRet +=            "<ZipCode>"     + cCep      + "</ZipCode>"
cXMLRet +=            "<Region>"      + cRegiao   + "</Region>"
cXMLRet +=            "<POBox>"       + cCXPostal + "</POBox>"
cXMLRet +=            "<City>"
cXMLRet +=                   "<CityCode>"         + cCodCidade               + "</CityCode>"
cXMLRet +=                   "<CityInternalId>"   + cFilAnt +"|" + cCodCidade + "</CityInternalId>"
cXMLRet +=                   "<CityDescription>"  + cCidade                  + "</CityDescription>"
cXMLRet +=            "</City>"

cXMLRet +=            "<State>"
cXMLRet +=                   "<StateCode>"         + cUF                  + "</StateCode>"
cXMLRet +=                   "<StateInternalId>"   + cFilAnt + "|" + cUF  + "</StateInternalId>"
cXMLRet +=                   "<StateDescription>"  + cUFDescr             + "</StateDescription>"
cXMLRet +=            "</State>"

If !Empty(cPaisDescr)
	cXMLRet +=        "<Country>"
	cXMLRet +=                 "<CountryCode>"        + cPais                 + "</CountryCode>"
	cXMLRet +=                 "<CountryInternalId>"  + cFilAnt + "|" + cPais + "</CountryInternalId>"
	cXMLRet +=                 "<CountryDescription>" + cPaisDescr            + "</CountryDescription>"
	cXMLRet +=        "</Country>"
EndiF

cXMLRet +=      "</ShippingAddress>"

cXMLRet += "</BusinessContent> "

Return {lResult,cXmlRet}

/*/
=================================================================================
{Protheus.doc} _FReceive(cXml,cTypeMsg)

//TODO Descrição : Funcao para tratar o xml de recebimento
@author tiago.dsantos
@since 15/09/2016
@version undefined
@param cXml, characters, descricao
@type function
=================================================================================
/*/
Static Function _FReceive(cXml,cTypeMsg)
Local cXmlRet     := ""
Local lResult     := .T.
Local cWarning    := ""
Local cError      := ""
Local oXml        := ""
Local aCab        := {}
Local cAction     := ""
Local cCodeExt    := ""  
Local cCodeInt    := ""
Local cCodCli     := ""
Local cLojCli     := ""
Local cCnpjCpf    := ""
Local cInscEst    := ""
Local cIFCnpjCpf  := ""
Local cIFInscEst  := ""
Local cEndereco   := ""
Local cEndNum     := ""
Local cCidade     := ""
Local cCodMunic   := ""
Local cBairro     := ""
Local cCep        := ""
Local cUf         := ""
Local cUFDescr    := ""
Local cCodPais    := ""
Local cDscPais    := ""
Local cCodRedesp  := ""
Local cLojRedesp  := ""
Local cIERedesp   := ""
Local cCGCRedesp  := ""
Local lMatchRed   := .F.
Local cMsg        := ""
Local cMarca      := ""
Local cAlias      := "DUL"
Local cCampo      := "DUL_SEQEND"
Local nx          := 0
Local nOpcx       := 0
Local aGovernAttr := {}
Local aGovernVal  := {}
Local aTmpArr     := {}
Local aErrsList   := {}

//+--------------------------------------------------------------
//| Trata a mensagem de Negocio/BusinessMessage
//+--------------------------------------------------------------
If cTypeMsg == EAI_MESSAGE_BUSINESS

	oXml := TXmlManager():new()
	If !oXml:Parse(cXml)

		lResult:= .F.
		Aadd(aErrsList, {STR0001, 1, "TMSI45001"}) // Description | nType: 1-ERROR;2-WARNING | cCode : Generic Code

		cXmlRet := FWEAILOfMessages(aErrsList)

		Return {lResult,cXmlRet}
	EndIf

	//| Inicio do processamento do XML de Endereço de Entrega.
	cAction    := Upper(oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessEvent/Event"))
	cCodeExt   := oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessEvent/Identification")

	cMarca     := oXml:XPathGetAtt( "/TOTVSMessage/MessageInformation/Product", "name" )

	//| Retorna um array de subarray, contendo o nome e o valor de cada atributo do nó.
	aTmpArr := oXml:XPathGetChildArray("/TOTVSMessage/BusinessMessage/BusinessContent/GovernmentalInformation")

	cCnpjCpf := TMI450Gov(oXML,aTmpArr,"CNPJCPF"           )
	cInscEst := TMI450Gov(oXML,aTmpArr,"INSCRICAO ESTADUAL")

	//| Posiciona no codigo do cliente
	SA1->( dbSetOrder(3) )
	If !Empty(cCnpjCpf) .And. SA1->(MsSeek(xFilial("SA1")+cCnpjCpf))
		cCodCli   := SA1->A1_COD
		cLojCli   := SA1->A1_LOJA
	Else
		cMsg := STR0002 + AllTrim(cCnpjCpf)
		cMsg += STR0003 + AllTrim(cInscEst)
		cMsg +=  "|"    + STR0004

		Aadd(aErrsList, { cMsg, 1, "TMSI45002" }) // Cadastro de Cliente não localizado para o Cnpj/Cpf ?1 e I.E: ?2 . | Realize a Integração de Cadastro de Clientes primeiro. | nType: 1-ERROR;2-WARNING | cCode : Generic Code
		cXmlRet := FWEAILOfMessages(aErrsList)

		Return {.F.,cXmlRet}
	EndIf

	//|Obtém o código interno da tabela de/para através de um código externo
	//|CFGA070Int( cRefer, cAlias, cField, cValExt,cTable )
	cCodeInt := PadR(CFGA070INT( cMarca, cAlias, cCampo, cCodeExt ), TamSX3('DUL_SEQEND')[1])

	If Empty(cCodeInt)
		cCodeInt := cCodeExt
	EndIf

	//| DADOS DO REDESPACHO
	aTmpArr := oXml:XPathGetChildArray("/TOTVSMessage/BusinessMessage/BusinessContent/ShippingAddressInformation")
	cIFCnpjCpf := TMI450Gov(oXml,aTmpArr,"CNPJCPF")
	cIFInscEst := TMI450Gov(oXml,aTmpArr,"INSCRICAO ESTADUAL")

	SA1->(DbSetOrder(3))
	If SA1->(MsSeek(xFilial("SA1")+cIFCnpjCPF))
		cCodRedesp  := SA1->A1_COD
		cLojRedesp  := SA1->A1_LOJA
		lMatchRed   := .T.
	EndIf

	//| INFORMAÇÕES DO ENDEREÇO DO CLIENTE/SOLICITANTE
	cEndereco := oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/ShippingAddress/Address")
	cEndNum   := oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/ShippingAddress/Number")
	cCidade   := oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/ShippingAddress/City/CityDescription")
	cCodMunic := Right(oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/ShippingAddress/City/CityCode"),5)
	cBairro   := oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/ShippingAddress/District")
	cCep      := oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/ShippingAddress/ZIPCode" )
	cUf       := oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/ShippingAddress/State/StateCode")
	cUFDescr  := oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/ShippingAddress/State/StateDescription")
	cCodPais  := oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/ShippingAddress/Country/CountryCode")
	cDscPais  := oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/ShippingAddress/Country/CountryDescription")
	cPOBox    := oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/ShippingAddress/POBox")

	//| Valida a ação sendo: upsert=inclusão/alteração ou delete=exclusão
	If  cAction == "UPSERT"

		DUL->(DbSetOrder(1))   // equiv: DUL_FILIAL+DUL_SEQEND
		If !DUL->(MsSeek(xFilial("DUL") + cCodeInt ))
			nOpcx := 3
		Else
			nOpcx := 4
		EndIf

	ElseIf cAction == "DELETE"
		nOpcx := 5

	Endif

	//| Obrigatórios
	AADD(aCab, {"DUL_FILIAL",xFilial("DUL")        ,NIL})
	AADD(aCab, {"DUL_SEQEND",cCodeInt              ,NIL})

	AADD(aCab, {"DUL_CODCLI",cCodCli               ,NIL})
	AADD(aCab, {"DUL_LOJCLI",cLojCli               ,NIL})

	AADD(aCab, {"DUL_END"   ,cEndereco+","+cEndNum ,NIL})
	AADD(aCab, {"DUL_BAIRRO",cBairro               ,NIL})
	AADD(aCab, {"DUL_MUN"   ,cCidade               ,NIL})

	AADD(aCab, {"DUL_EST"   ,cUF                   ,NIL})
	AADD(aCab, {"DUL_CODMUN",cCodMunic             ,NIL})
	AADD(aCab, {"DUL_CEP"   ,cCep                  ,NIL})
	AADD(aCab, {"DUL_CDRDES",getRegCli(cCidade)    ,NIL})
	AADD(aCab, {"DUL_TDA"   ,"2"                   ,NIL})

	//| Dados do Redespachante...
	If lMatchRed
		AADD(aCab, {"DUL_CODRED",cCodRedesp        ,NIL})
		AADD(aCab, {"DUL_LOJRED",cLojRedesp        ,NIL})
	EndIf

	AADD(aCab, {"DUL_CGC"   ,cIFCnpjCpf            ,NIL})
	AADD(aCab, {"DUL_INSCR" ,cIFInscEst            ,NIL})

	Begin Transaction

		//| Grava o cadastro
		MSExecAuto( { |x,y| TMSA450(x,y) }, aCab, nOpcx )

		//| Se houve problema no cadastro da Sequencia de Endereço pelo ExecAuto()
		//| Trata mensagem de retorno.
		If lMsErroAuto
			aError  := GetAutoGrLog()
			cXmlRet := ""

			For nx:= 1 To Len(aError)
				cXmlRet += _NoTags(aError[nx])
			Next nx
			lResult := .F.
			DisarmTransaction()

		Else
			If !Empty(cCodeExt) .And. !Empty(cCodeInt)
				//| Grava o De-para do EAI
				cCodeInt := DUL->DUL_SEQEND
				If CFGA070Mnt(cMarca , cAlias, "DUL_SEQEND",cCodeExt, cCodeInt, (nOpcx == 5) )
					// Monta xml com status do processamento da rotina automatica OK.
					cXMLRet +=      "<ListOfInternalId>"
					cXMLRet +=            "<InternalId>"
					cXMLRet +=                  "<Name>CodeInternalId</Name>"
					cXMLRet +=                  "<Origin>"      + cCodeExt + "</Origin>"
					cXMLRet +=                  "<Destination>" + cCodeInt + "</Destination>"
					cXMLRet +=            "</InternalId>"
					cXMLRet +=      "</ListOfInternalId>"
				EndIf
				
			EndIf

		EndIf

	End Transaction

	//+--------------------------------------------------------------
	//| Trata a mensagem de Resposta/Devolve Mensagem.
	//+--------------------------------------------------------------
ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE

	//+--------------------------------------------------------------
	//| Mensagem: responde com a Versão
	//+--------------------------------------------------------------
ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
	cXmlRet := "1.000|1.001"

	//+--------------------------------------------------------------
	//| Trata a mensagem de Negocio/BusinessMessage
	//+--------------------------------------------------------------
	//ElseIf cTypeMsg == EAI_MESSAGE_RECEIPT

EndIf

//| Monta a mensagem de erro
If !Empty(aErrsList)
	lResult := .F.
	cXmlRet := FWEAILOfMessages( aErrsList )
EndIf

Return {lResult,cXmlRet}


/*/{Protheus.doc} getIntlId
//TODO Recupera a identificação interna da mensagem trafegada.
@author tiago.dsantos
@since 15/09/2016
@version 1.001

@type function
/*/
Static Function getIntlId()
Local cResult := ""

cResult := xFilial("DUL") + "|" +  DUL->DUL_SEQEND

Return cResult


/*/{Protheus.doc} TMI450Gov
//TODO Obtém o valor da tag GovernmentalInformation com base no valor do atributo name 
@author tiago.dsantos
@since 16/09/2016
@version undefined
@param aNodes, array, retorno de XPathGetAttArray()
@param cAttrName, characters, nome do conteúdo do atributo name do nó retornado por aNodes.
@type function
/*/
Static Function TMI450Gov(oXML,aNodes,cAttrName)
Local cResult   := ""
Local nx        := 0
Local aAttr     := {}
     
If Empty(aNodes)
	Return cResult
EndiF

For nx  := 1 To Len(aNodes)
	aAttr := oXML:XPathGetAttArray(aNodes[nx][2])
	nPos  := AScan(aAttr,{|v| Upper(v[1]) == "NAME" .And. Upper(v[2]) == Upper(cAttrName)})

	If npos > 0
		cResult := aNodes[nx][3]
		Exit
	EndIf
Next nx
     
Return cResult
/*/{Protheus.doc} getRegCli
//TODO Obtém o código do cadastros de região passando a descrição como parametro
@author tiago.dsantos
@since 16/09/2016
@version undefined
@param cRegName, characters, descricao
@type function
/*/
Static Function getRegCli(cRegName)
Local cResult  := ""
Local cQry     := "SELECT DUY_GRPVEN FROM " + RetSqlName("DUY") + " WHERE D_E_L_E_T_ = ' ' AND DUY_FILIAL = '" + xFilial("DUY") + "' AND Upper(DUY_DESCRI) LIKE '" + Upper(cRegName) + "%' "
Local cNxAlias := GETNEXTALIAS()
      
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cNxAlias,.T.,.F.)

If (cNxAlias)->(!EOF())
	cResult := (cNxAlias)->DUY_GRPVEN
EndIf

(cNxAlias)->(dbCloseArea())

Return cResult
