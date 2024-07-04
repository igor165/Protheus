////////////////
// Versao 001 //
////////////////

#include "protheus.ch"

Function VEICLSAX()
Return()

/*/{Protheus.doc} VEICLSAX_PMPRO

	@author       Vinicius Gati
	@since        29/05/2015
	@description  Funcao usada para coletar dados gerais do ambiente usado no pmpro

/*/
Function VEICLSAX_PMPRO(cVar)
	DO CASE
		CASE cVar == 'environment'
			return 'Test'
		CASE cVar == 'language'
			return 'pt-BR'
	END CASE
Return ''

/*/{Protheus.doc} DMSXmlHelper

	@author       Vinicius Gati
	@since        29/05/2015
	@description  Classe criada para ajudar a coletar dados em XMls sem que errorlogs sejam exibidos

/*/
CLASS DMS_XmlHelper
	Data oXml

	Method New() CONSTRUCTOR
	METHOD GetValue()
ENDCLASS

/*/{Protheus.doc} DMS_XmlHelper

	@author       Vinicius Gati
	@since        29/05/2015
	@description  Construtor base
	@parameter oXmlObj , Objeto xml criado usando XmlParseFile

/*/
METHOD New(oXmlObj) CLASS DMS_XmlHelper
	::oXml := oXmlObj
Return SELF

/*/{Protheus.doc} GetValue

	@author       Vinicius Gati
	@since        29/05/2015
	@description  Usado para colher os dados de um objeto xml porem Ã© feita checagem de existencia para cada nÃ³
	@parameter    oXmlObj , Objeto xml criado usando XmlParseFile

/*/
Method GetValue(cTagTree, iDefault) CLASS DMS_XmlHelper
	Local   nIdx     := 1
	Local   oXmlAt   := nil
	DEFAULT iDefault := ""
	oXmlAt           := Self:oXml
	aTags            := STRTOKARR(cTagTree, ":")

	for nIdx:= 1 to LEN(aTags)
		cTag := aTags[nIdx]
		if UPPER(cTag) != "TEXT"
			oXmlAt := XmlChildEx(oXmlAt, UPPER(cTag))
			if VALTYPE( oXmlAt ) == "U"
				return iDefault // tag nÃ£o encontrada
			EndIf
		else
			return oXmlAt:Text
		EndIf
	next
Return oXmlAt

/*/{Protheus.doc} DMS_XMLPmpro

	@author       Vinicius Gati
	@since        28/04/2017
	@description  Classe para trabalhar com dados do pmpro recebido via webservice

/*/
CLASS DMS_XMLPmpro
	DATA cErro
	DATA cAviso
	DATA oXmlObj
	DATA oResponse
	DATA lProd
	DATA cXml

	METHOD New() CONSTRUCTOR
	Method getObjectResponse()
	Method getVR9Type()
	Method Ok()
ENDCLASS

/*/{Protheus.doc} New

	@author       Vinicius Gati
	@since        29/05/2015
	@description  Construtor base
	@parameter cXmlObj , Objeto xml da request relacionada ao PMPRO, tudo começa aqui<br/>
	Neste metodo o objeto retornado e convertido para o tipo correto dependendo do XMLRecebido<br/>
	No XML recebido existe uma tag que identifica o que foi pedido ao servidor<br/>
	Dessa forma a resposta é obtida corretamente.

/*/
METHOD New(cXml, lProd) CLASS DMS_XMLPmpro
	Default lProd := .T.
	::lProd := lProd
	::cXml  := cXml
Return SELF

/*/{Protheus.doc} getObjectResponse

	Retorna objeto xml de reposta de acordo com xml recebido
	@author Vinicius Gati
	@since 28/04/2017
	@type function

/*/
METHOD getObjectResponse() CLASS DMS_XMLPmpro
	cErro  := ''
	cAviso := ''

	oObj := XmlParser(self:cXml,"_",@cErro,@cAviso)
	if self:lProd // se estiver em producao usa os empacotamentos padroes soap envelope e body
		if empty(XmlChildEx(oObj, "_SOAP_ENVELOPE"))
			oObj := XmlChildEx(oObj, "_SOAPENV_ENVELOPE")
			oObj := oObj:_SOAPENV_BODY
		else
			oObj := XmlChildEx(oObj, "_SOAP_ENVELOPE")
			oObj := oObj:_SOAP_BODY
		end
	end

	self:oXmlObj := oObj
	self:cErro   := cErro
	self:cAviso  := cAviso

	DO CASE
		CASE ! EMPTY(XmlChildEx(self:oXmlObj, "_GETCUSTOMERSEARCH"))
			self:oResponse := DMS_PMPROGetCustomerSearch():New(self:oXmlObj)
		CASE ! EMPTY(XmlChildEx(self:oXmlObj, "_GETSUPPORTEDCUSTOMERSEARCH"))
			self:oResponse := DMS_PMPROGetSuportedCustomerSearch():New(self:oXmlObj)
		CASE ! EMPTY(XmlChildEx(self:oXmlObj, "_PROCESSPARTSPICKLIST"))
			self:oResponse := DMS_PMPROPartsPickList():New(self:oXmlObj)
		CASE ! EMPTY(XmlChildEx(self:oXmlObj, "_GETSUPPORTEDPROPERTIES"))
			self:oResponse := DMS_PMPROGetSupportedProperties():New(self:oXmlObj)
		CASE ! EMPTY(XmlChildEx(self:oXmlObj, "_GETSUPPORTEDVALUES"))
			self:oResponse := DMS_PMPROGetSupportedValues():New(self:oXmlObj)
		CASE ! EMPTY(XmlChildEx(self:oXmlObj, "_GETPARTPRICINGANDAVAILABILITY"))
			self:oResponse := DMS_PMPROGetPartPricingAndAvailability():New(self:oXmlObj)
		OTHERWISE
			self:cErro := "Nao foi possivel tratar o xml recebido"
	ENDCASE
Return self:oResponse

/*/{Protheus.doc} Ok

	Verifica se teve erro ao detectar o servico ou outro erro
	@author Vinicius Gati
	@since 28/04/2017
	@type function

/*/
Method Ok() CLASS DMS_XMLPmpro
Return Empty(self:cErro)

/*/{Protheus.doc} getVR9Type

	Retorna o tipo relacionado a pmpro no campo VR9_TIPO
	@author Vinicius Gati
	@since 08/05/2017
	@type function

/*/
Method getVR9Type() Class DMS_XMLPmpro
return "1"

/*/{Protheus.doc} DMS_PMPROGetSuportedCustomerSearch

	@author       Vinicius Gati
	@since        29/05/2015
	@description  Dados da requisição do tipo suported customer search

/*/
CLASS DMS_PMPROGetSuportedCustomerSearch
	DATA oAppArea
	Method New() CONSTRUCTOR
	Method getResponse()
ENDCLASS

Method New(oXml) CLASS DMS_PMPROGetSuportedCustomerSearch
	::oAppArea := DMS_PMPROBODApplicationArea():New(oXml:_GETCUSTOMERSEARCH)
Return SELF

Method getResponse() CLASS DMS_PMPROGetSuportedCustomerSearch
	Local cXmlResp := ""
	cXmlResp += '<?xml version="1.0" encoding="UTF-8"?>'
	cXmlResp += '<ShowSupportedCustomerSearch releaseID="5.0" versionID="4.0"'
	cXmlResp += '    systemEnvironmentCode="'+VEICLSAX_PMPRO('environment')+'" languageCode="'+VEICLSAX_PMPRO('language')+'" xmlns="http://snaponbusinesssolutions.com/4/CustomerSearch.xsd">'
	cXmlResp += self:oAppArea:toXml()
	cXmlResp += '    <ShowSupportedCustomerSearchDataArea>'
	cXmlResp += '        <Show>'
	cXmlResp += self:oAppArea:toXml('OriginalApplicationArea')
	cXmlResp += '        </Show>'

	cXmlResp += '        <SupportedCustomerSearchCriteria>'
	cXmlResp += '            <NameValue name="Nome" mandatory="false">Nome</NameValue>'
	cXmlResp += '            <Description>Nome do Cliente</Description>'
	cXmlResp += '        </SupportedCustomerSearchCriteria>'

	cXmlResp += '        <SupportedCustomerSearchCriteria>'
	cXmlResp += '            <NameValue name="CPF" mandatory="false">CPF</NameValue>'
	cXmlResp += '            <Description>CPF do cliente pessoa física</Description>'
	cXmlResp += '        </SupportedCustomerSearchCriteria>'

	cXmlResp += '        <SupportedCustomerSearchCriteria>'
	cXmlResp += '            <NameValue name="CNPJ" mandatory="false">CNPJ</NameValue>'
	cXmlResp += '            <Description>CNPJ do cliente pessoa jurídica</Description>'
	cXmlResp += '        </SupportedCustomerSearchCriteria>'

	cXmlResp += '        <SupportedCustomerSearchCriteria>'
	cXmlResp += '            <NameValue name="DDDTelefone" mandatory="false">DDD Telefone</NameValue>'
	cXmlResp += '            <Description>DDD do telefone do cliente</Description>'
	cXmlResp += '        </SupportedCustomerSearchCriteria>'

	cXmlResp += '        <SupportedCustomerSearchCriteria>'
	cXmlResp += '            <NameValue name="Telefone" mandatory="false">Telefone</NameValue>'
	cXmlResp += '            <Description>Número de telefone do cliente</Description>'
	cXmlResp += '        </SupportedCustomerSearchCriteria>'

	cXmlResp += '    </ShowSupportedCustomerSearchDataArea>'
	cXmlResp += '</ShowSupportedCustomerSearch>'
Return cXmlResp

/*/{Protheus.doc} DMS_PMPROGetCustomerSearch

	@author       Vinicius Gati
	@since        29/05/2015
	@description  Dados da requisição do tipo customer search

/*/
CLASS DMS_PMPROGetCustomerSearch
	DATA oAppArea
	DATA oDataArea
	DATA oCriterios

	Method New() CONSTRUCTOR
	Method getResponse()
ENDCLASS

Method New(oXml) CLASS DMS_PMPROGetCustomerSearch
	::oAppArea   := DMS_PMPROBODApplicationArea():New(oXml)
	::oCriterios := DMS_PMPROBODCustomSearchCriteria():New(oXml:_GETCUSTOMERSEARCH:_GETCUSTOMERSEARCHDATAAREA)
Return SELF

Method getResponse() CLASS DMS_PMPROGetCustomerSearch
	Local cXmlResp   := ""
	Local aCustomers := {}
	Local nX         := 1
	cXmlResp += '<?xml version="1.0" encoding="UTF-8"?>'
	cXmlResp += '<ShowCustomerSearch releaseID="5.0" versionID="4.0"'
	cXmlResp += '    systemEnvironmentCode="'+VEICLSAX_PMPRO('environment')+'" languageCode="'+VEICLSAX_PMPRO('language')+'" xmlns="http://snaponbusinesssolutions.com/4/CustomerSearch.xsd">'

	cXmlResp += self:oAppArea:toXml()

	cXmlResp += '    <ShowCustomerSearchDataArea>'
	cXmlResp += '        <Show>'
	cXmlResp += self:oAppArea:toXml('OriginalApplicationArea')
	cXmlResp += '        </Show>'
	cXmlResp += '        <CustomerSearchResult>'

	aCustomers := self:oCriterios:getCustomers()
	for nX := 1 to LEN(aCustomers)
		cXmlResp += aCustomers[nX]:toXml()
	next

	cXmlResp += '    </CustomerSearchResult>'
	cXmlResp += '  </ShowCustomerSearchDataArea>'
	cXmlResp += '</ShowCustomerSearch>'
Return cXmlResp

/*/{Protheus.doc} DMS_PMPROBODApplicationArea

	@author       Vinicius Gati
	@since        29/05/2015
	@description  Cabeçalho dos xml padrão pmpro

/*/
CLASS DMS_PMPROBODApplicationArea from DMS_DataContainer
	Method New() CONSTRUCTOR
	Method toXml()
ENDCLASS

METHOD New(oXml) CLASS DMS_PMPROBODApplicationArea
	oSender := oXml:_APPLICATIONAREA:_SENDER
	if ! Empty( XmlChildEx(oSender, '_TASKID') )
		aData := {;
			{'COMPONENTID'       , oSender:_COMPONENTID:Text     },;
			{'TASKID'            , oSender:_TASKID:Text          },;
			{'AUTHORIZATIONID'   , oSender:_AUTHORIZATIONID:Text },;
			{'CREATORNAMECODE'   , oSender:_CREATORNAMECODE:Text },;
			{'SENDERNAMECODE'    , oSender:_SENDERNAMECODE:Text  },;
			{'REFERENCEID'       , oSender:_REFERENCEID:Text     },;
			{'STORENUMBER'       , oXml:_APPLICATIONAREA:_DESTINATION:_STORENUMBER:Text         },;
			{'DESTINATION'       , oXml:_APPLICATIONAREA:_DESTINATION:_DESTINATIONNAMECODE:Text },;
			{'CREATIONDATETIME'  , oXml:_APPLICATIONAREA:_CREATIONDATETIME:Text                 } ;
		}
	else
		aData := {;
			{'COMPONENTID'       , oSender:_COMPONENT:Text       },;
			{'TASKID'            , oSender:_TASK:Text            },;
			{'AUTHORIZATIONID'   , oSender:_AUTHORIZATIONID:Text },;
			{'CREATORNAMECODE'   , oSender:_CREATORNAMECODE:Text },;
			{'SENDERNAMECODE'    , oSender:_SENDERNAMECODE:Text  },;
			{'DESTINATION'       , oXml:_APPLICATIONAREA:_DESTINATION:_DESTINATIONNAMECODE:Text },;
			{'CREATIONDATETIME'  , oXml:_APPLICATIONAREA:_CREATIONDATETIME:Text                 } ;
		}
	end
	::aData := aData
Return SELF

Method toXml(cTagName) Class DMS_PMPROBODApplicationArea
	Local cXml      := ''
	Local cComId    := 'CustomerSearchService'
	Local cTaskId   := 'ShowCustomerSearch'
	Local cAuth     := 'Protheus'
	Local cCreato   := 'Protheus'
	Local cSender   := 'Protheus'
	Local cStorNum  := xFilial('VS3')
	Local cCreaDate := FWTimeStamp(3)
	Local cDest     := 'Applet'
	Local cRefId    := ''
	Default cTagName := 'ApplicationArea'

	if cTagName == "OriginalApplicationArea" // gerar mesmo recebido
		cComId    := self:getValue('COMPONENTID', '')
		cTaskId   := self:getValue('TASKID', '')
		cAuth     := self:getValue('AUTHORIZATIONID', '')
		cCreato   := self:getValue('CREATORNAMECODE', '')
		cSender   := self:getValue('SENDERNAMECODE', '')
		cStorNum  := self:getValue('STORENUMBER', '')
		cCreaDate := self:getValue('CREATIONDATETIME', '')
		cDest     := self:getValue('DESTINATION', '')
		cRefId    := self:getValue('REFERENCEID', '')
	end

	cXml += '<'+cTagName+'>'
	cXml += '  <Sender>'
	cXml += '    <ComponentID>'+cComId+'</ComponentID>'
	cXml += '    <TaskID>'+cTaskId+'</TaskID>'
	if !Empty(cRefId)
		cXml += '    <ReferenceID>'+cRefId+'</ReferenceID>'
	end
	cXml += '    <AuthorizationID>'+cAuth+'</AuthorizationID>'
	cXml += '    <CreatorNameCode>'+cCreato+'</CreatorNameCode>'
	cXml += '    <SenderNameCode>'+cSender+'</SenderNameCode>'
	cXml += '  </Sender>'
	cXml += '  <CreationDateTime>'+cCreaDate+'</CreationDateTime>'
	cXml += '  <Destination>'
	cXml += '    <DestinationNameCode>'+cDest+'</DestinationNameCode>'
	if !Empty(cStorNum)
		cXml += '    <StoreNumber>'+cStorNum+'</StoreNumber>'
	end
	cXml += '  </Destination>'
	cXml += '</'+cTagName+'>'
Return cXml

/*/{Protheus.doc} DMS_PMPROBODCustomSearchCriteria

	@author       Vinicius Gati
	@since        29/05/2015
	@description  pega os criterios de consulta dom xml conforme custom search criteria definition

/*/
Class DMS_PMPROBODCustomSearchCriteria
	DATA aCriterios
	DATA nMaxResults

	METHOD New() CONSTRUCTOR
	Method GetCustomers()
EndClass

METHOD New(oXml) CLASS DMS_PMPROBODCustomSearchCriteria
	Local nX := 1
	Local aArray := oXml:_CUSTOMERSEARCHCRITERIA

	::nMaxResults := VAL(oXml:_GET:_MAXITEMS:TEXT)
	::aCriterios := {}

	if VALTYPE(aArray) == "A" // para rubens: aqui é necessario, no xml pode ser recebido array caso tenha mais de 1 elemento, e caso venha só 1 ele me passa Objeto
		For nX:= 1 to Len(aArray)
			oCrit := aArray[nX]
			AADD(::aCriterios, DMS_DataContainer():New({;
				{'CAMPO', oCrit:_NAMEVALUE:_NAME:Text },;
				{'VALOR', oCrit:_NAMEVALUE:Text       } ;
			}))
		Next
	else
		AADD(::aCriterios, DMS_DataContainer():New({;
			{'CAMPO', aArray:_NAMEVALUE:_NAME:Text },;
			{'VALOR', aArray:_NAMEVALUE:Text       } ;
		}))
	end
Return SELF

Method GetCustomers() Class DMS_PMPROBODCustomSearchCriteria
	local aDados := {}
	local cAl      := GetNextAlias()
	local cQuery   := ""
	local nX       := 1
	local cCriCam  := '' // campo do criterio
	local oSqlHlp  := DMS_SqlHelper():New()
	local oArrHlp  := DMS_ArrayHelper():New()
	// usado para converter o campo do criterio para campo do protheus
	local oCampos  := DMS_DataContainer():New({;
		{'Nome'       , 'A1_NOME' },;
		{'CPF'        , 'A1_CGC'  },;
		{'CNPJ'       , 'A1_CGC'  },;
		{'DDDTelefone', 'A1_DDD'  },;
		{'Telefone'   , 'A1_TEL'  } ;
	})

	cQuery += "  SELECT A1_FILIAL, A1_COD, A1_LOJA "
	cQuery += "    FROM " + RetSqlName('SA1') + " SA1 "
	cQuery += "   WHERE SA1.A1_FILIAL  = '"+xFilial('SA1')+"' "
	for nX := 1 to LEN(self:aCriterios)
		oCrit := self:aCriterios[nX]
		cCriCam := oCampos:getValue( oCrit:getValue('CAMPO'), '' )
		if cCriCam == 'A1_NOME'
			cQuery += " AND SA1.A1_NOME like '"+oCrit:GetValue("VALOR")+"%' "
		elseif cCriCam == 'A1_CGC'
			cQuery += " AND SA1.A1_CGC like '"+oCrit:GetValue("VALOR")+"' "
			if aCampo:getValue('CAMPO') == 'CPF'
				cQuery += " AND SA1.A1_PESSOA = 'F' "
			else
				cQuery += " AND SA1.A1_PESSOA = 'J' "
			end
		elseif cCriCam == 'A1_DDD'
			cQuery += " AND SA1.A1_DDD = '"+oCrit:GetValue("VALOR")+"' "
		elseif cCriCam == 'A1_TEL'
			cQuery += " AND SA1.A1_TEL = '"+oCrit:GetValue("VALOR")+"' "
		end
	next
	cQuery += " AND SA1.D_E_L_E_T_ = ' ' "

	aDados := oSqlHlp:GetSelectArray(cQuery, 3)
Return oArrHlp:Map(aDados, {|aCli| ;
	DMS_PMPROCustomer():New(aCli[1], aCli[2], aCli[3]) ;
}) // retorna um array com os objetos direto

/*/{Protheus.doc} DMS_PMPROPartsPickList

	@author       Vinicius Gati
	@since        02/05/2017
	@description  Resposavel por coletar o xml da pick list e criar a picklist no sistema

/*/
Class DMS_PMPROPartsPickList
	DATA cCodTecnico
	DATA cNomeLista
	DATA aItens // itens da pick list

	METHOD New() CONSTRUCTOR
	METHOD Processar()
	Method getResponse()
EndClass

/*/{Protheus.doc} New

	@author       Vinicius Gati
	@since        02/05/2017
	@description  Construtor que coleta os itens recebido pela picklist

/*/
Method New(oXml, cVersion) class DMS_PMPROPartsPickList
	Local aPickList
	Local nX := 1
	Default cVersion := '3'

	::cCodTecnico := oXml:_PROCESSPARTSPICKLIST:_APPLICATIONAREA:_SENDER:_AUTHORIZATIONID:Text
	::aItens := {}

	if cVersion == '3'
		::cNomeLista   := oXml:_PROCESSPARTSPICKLIST:_DATAAREA:_PARTSPICKLIST:_HEADER:_DOCUMENTID:Text
		aPickList := oXml:_PROCESSPARTSPICKLIST:_DATAAREA:_PARTSPICKLIST:_LINE
		if VALTYPE(aPickList) == "A"
			For nX:= 1 to Len(aPickList)
				oPickList := aPickList[nX]
				AADD(::aItens, DMS_DataContainer():New({;
					{'QUANT'    , VAL(oPickList:_ITEMQUANTITY:Text)        },;
					{'UM'       , oPickList:_ITEMQUANTITY:_UOM:Text        },;
					{'CODIGO'   , oPickList:_PART:_ITEMID:Text             },;
					{'DESCRICAO', oPickList:_PART:_ITEMIDDESCRIPTION:Text  },;
					{'TIPO'     , oPickList:_PART:_PARTTYPE:Text           },;
					{'MARCA'    , oPickList:_PART:_BRAND:Text              } ;
				}))
			Next
		else//quando manda somente 1 item, nao vem como array e sim como o objeto direto, um saco mas fazer o que
			AADD(::aItens, DMS_DataContainer():New({;
				{'QUANT'    , VAL(aPickList:_ITEMQUANTITY:Text)        },;
				{'UM'       , aPickList:_ITEMQUANTITY:_UOM:Text        },;
				{'CODIGO'   , aPickList:_PART:_ITEMID:Text             },;
				{'DESCRICAO', aPickList:_PART:_ITEMIDDESCRIPTION:Text  },;
				{'TIPO'     , aPickList:_PART:_PARTTYPE:Text           },;
				{'MARCA'    , aPickList:_PART:_BRAND:Text              } ;
			}))
		end
	else
		::cNomeLista   := oXml:_PROCESSPARTSPICKLIST:_PROCESSPARTSPICKLISTDATAAREA:_PARTSPICKLIST:_PARTSPICKLISTHEADERBASE:_DOCUMENTIDENTIFICATIONGROUP:_DOCUMENTIDENTIFICATION:_DOCUMENTID:Text
		aPickList := oXml:_PROCESSPARTSPICKLIST:_PROCESSPARTSPICKLISTDATAAREA:_PARTSPICKLIST:_PARTSPICKLISTLINE
		if VALTYPE(aPickList) == "A"
			For nX:= 1 to Len(aPickList)
				oPickList := aPickList[nX]
				AADD(::aItens, DMS_DataContainer():New({;
					{'QUANT'    , VAL(oPickList:_ITEMQUANTITY:Text)                    },;
					{'UM'       , oPickList:_ITEMQUANTITY:_UNITCODE:Text               },;
					{'CODIGO'   , oPickList:_PARTSPRODUCTITEM:_ITEMID:Text             },;
					{'DESCRICAO', oPickList:_PARTSPRODUCTITEM:_PARTITEMDESCRIPTION:Text},;
					{'TIPO'     , oPickList:_PARTSPRODUCTITEM:_PARTTYPECODE:Text       },;
					{'MARCA'    , oPickList:_PARTSPRODUCTITEM:_BRAND:Text              } ;
				}))
			Next
		else
			AADD(::aItens, DMS_DataContainer():New({;
				{'QUANT'    , VAL(aPickList:_ITEMQUANTITY:Text)                    },;
				{'UM'       , aPickList:_ITEMQUANTITY:_UNITCODE:Text               },;
				{'CODIGO'   , aPickList:_PARTSPRODUCTITEM:_ITEMID:Text             },;
				{'DESCRICAO', aPickList:_PARTSPRODUCTITEM:_PARTITEMDESCRIPTION:Text},;
				{'TIPO'     , aPickList:_PARTSPRODUCTITEM:_PARTTYPECODE:Text       },;
				{'MARCA'    , aPickList:_PARTSPRODUCTITEM:_BRAND:Text              } ;
			}))
		end
	end
Return SELF

Method getResponse() class DMS_PMPROPartsPickList
	self:Processar()
Return ''

/*/{Protheus.doc} Processar

	@author       Vinicius Gati
	@since        02/05/2017
	@description  Gera a lista no banco de dados e relaciona com o tecnico correto ou admin caso exista

/*/
Method Processar() class DMS_PMPROPartsPickList
	Local nRnoTec    := ''
	Local cQuery     := ''
	Local nX         := 1
	Local oPmpro     := DMS_XMLPmpro():New()
	Local oArrHlp    := DMS_ArrayHelper():New()
	Local oSqlHlp    := DMS_SqlHelper():New()
	Local lExiste    := .F.
	Local lRet       := .F.
	Local cBckFil    := cFilAnt
	Local cQToRem    := ""
	Local aRecebidos := {}

	cQuery += " SELECT R_E_C_N_O_ "
	cQuery += "   FROM "+RetSqlName('VAI')
	cQuery += "  WHERE VAI_FABUSR = '"+self:cCodTecnico+"' "
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	nRnoTec := FM_SQL(cQuery)

	if Empty(nRnoTec)//
		cQuery += " SELECT R_E_C_N_O_ "
		cQuery += "   FROM "+RetSqlName('VAI')
		cQuery += "  WHERE VAI_FABUSR != ' ' "
		cQuery += "    AND D_E_L_E_T_ = ' ' "
		nRnoTec := FM_SQL("SELECT R_E_C_N_O_ FROM "+RetSqlName('VAI')+" WHERE VAI_CODUSR = '000000' AND D_E_L_E_T_ = ' '")
	end

	if nRnoTec > 0
		VAI->(DbGoTo(nRnoTec))

		cFilAnt := VAI->VAI_FILPRO
		VR9->(dbSetOrder(2))
		VR9->(dbSeek( xFilial('VR9') + oPmpro:getVR9Type() + self:cNomeLista ))

		lExiste := VR9->(Found())
		if lExiste
			RecLock("VR9", .F.)
			VR9->VR9_DATATU := DATE()
			VR9->(MsUnlock())
		else
			RecLock("VR9", .T.)
			VR9->VR9_FILIAL := xFilial('VR9')
			VR9->VR9_CODIGO := getsxenum('VR9', "VR9_CODIGO")
			VR9->VR9_CODVAI := VAI->VAI_CODTEC
			VR9->VR9_NOME   := ALLTRIM(self:cNomeLista)
			VR9->VR9_TIPO   := oPmpro:getVR9Type()
			VR9->VR9_DATA   := DATE()
			confirmsx8()
			VR9->(MsUnlock())
		end

		For nX:= 1 to Len(self:aItens)
			oItem := self:aItens[nX]

			VB2->(dbSetOrder(2))
			VB2->(dbSeek( xFilial('VB2') + VR9->VR9_CODIGO + oItem:GetValue('CODIGO') ))
			if VB2->(Found())
				RecLock("VB2", .F.)
				VB2->VB2_DATATU := DATE()
			else
				RecLock("VB2", .T.)
				VB2->VB2_FILIAL   := xFilial('VB2')
				VB2->VB2_CODIGO   := GETSXENUM('VB2', 'VB2_CODIGO')
				VB2->VB2_CODVR9 := VR9->VR9_CODIGO
				confirmsx8()
			end

			VB2->VB2_CODPRD := oItem:GetValue('CODIGO')
			VB2->VB2_UM     := oItem:GetValue('UM')
			VB2->VB2_QUANT  := oItem:GetValue('QUANT')

			VB2->(MsUnlock())
		Next

		aRecebidos := oArrHlp:Map(self:aItens, {|oItem| "'" + oItem:GetValue('CODIGO') + "'" })
		cQToRem := " SELECT R_E_C_N_O_ FROM " + RetSqlName('VB2')
		cQToRem += "  WHERE VB2_FILIAL = '"+xFilial('VB2')+"' "
		cQToRem += "    AND VB2_CODVR9 = '"+VR9->VR9_CODIGO+"' "
		cQToRem += "    AND VB2_CODPRD NOT IN (" + oArrHlp:Join(aRecebidos, ',')+ ")"
		cQToRem += "    AND D_E_L_E_T_ = ' ' "
		aToRem := oSqlHlp:GetSelectArray(cQToRem)
		for nX := 1 to LEN(aToRem)
			VB2->(DbGoTo(aToRem[nX]))
			RecLock("VB2", .F., .T.)
			VB2->VB2_DATATU := DATE()
			VB2->(dbdelete())
			VB2->(MsUnlock())
		next

		lRet := .T.
	end

	cFilAnt := cBckFil
Return lRet

/*/{Protheus.doc} DMS_PMPROCustomer

	@author       Vinicius Gati
	@since        02/05/2017
	@description  Resposavel por coletar o xml da pick list e criar a picklist no sistema

/*/
Class DMS_PMPROCustomer
	DATA cFilCli
	DATA cCodigo
	DATA cLoja

	METHOD New() CONSTRUCTOR
	METHOD toXml()
EndClass

/*/{Protheus.doc} New

	@author       Vinicius Gati
	@since        05/05/2017
	@description  Construtor simples

/*/
Method New(cFilCli, cCodigo, cLoja) Class DMS_PMPROCustomer
	::cFilCli := cFilCli
	::cCodigo := cCodigo
	::cLoja   := cLoja
Return SELF

/*/{Protheus.doc} toXml

	@author       Vinicius Gati
	@since        02/05/2017
	@description  Gera o xml padrão pmpro

/*/
Method toXml() class DMS_PMPROCustomer
	Local cXml := "<Customer>"
	Local cType := ''

	SA1->(dbSetOrder(1))
	SA1->(dbSeek(self:cFilCli + self:cCodigo + self:cLoja))

	if UPPER(SA1->A1_PESSOA) == 'F'
		cType := 'cpf'
	else
		cType := 'cnpj'
	end

	cXml += '  <CustomerParty>'
	cXml += '    <DealerManagementSystemID>'+ALLTRIM(STR(SA1->(recno())))+'</DealerManagementSystemID>'
	cXml += '    <AlternatePartyDocument>'
	cXml += '      <DocumentID>'+ALLTRIM(SA1->A1_CGC)+'</DocumentID>'
	cXml += '      <DocumentType>'+cType+'</DocumentType>'
	cXml += '    </AlternatePartyDocument>'

	cXml += '    <SpecifiedPerson>'
	cXml += '      <GivenName>'+ALLTRIM(SA1->A1_NOME)+'</GivenName>'
	cXml += '      <FamilyName></FamilyName>'
	cXml += '      <ResidenceAddress>'
	cXml += '        <LineOne>'+ALLTRIM(SA1->A1_END)+'</LineOne>'
	cXml += '        <LineTwo>'+ALLTRIM(SA1->A1_BAIRRO)+'</LineTwo>'
	cXml += '        <CityName>'+ALLTRIM(SA1->A1_IBGE)+'</CityName>'
	cXml += '        <CountryID>'+ALLTRIM(SA1->A1_EST)+'</CountryID>'
	cXml += '        <Postcode>'+ALLTRIM(SA1->A1_CEP)+'</Postcode>'
	cXml += '        <StateOrProvinceCountrySub-DivisionID>'+ALLTRIM(SA1->A1_EST)+'</StateOrProvinceCountrySub-DivisionID>'
	cXml += '      </ResidenceAddress>'

	cXml += '      <TelephoneCommunication>'
	cXml += '        <ChannelCode name="Telefone1">Telefone 1</ChannelCode>'
	cXml += '        <LocalNumber>'+ALLTRIM(SA1->A1_TEL)+'</LocalNumber>'
	cXml += '        <AreaNumberCode>'+ALLTRIM(SA1->A1_DDD)+'</AreaNumberCode>'
	cXml += '      </TelephoneCommunication>'

	cXml += '      <URICommunication>'
	cXml += '        <ChannelCode name="Home Email">Home Email</ChannelCode>'
	cXml += '        <CompleteNumber>'+ALLTRIM(SA1->A1_EMAIL)+'</CompleteNumber>'
	cXml += '      </URICommunication>'
	cXml += '      <ContactMethodTypeCode>Telefone1</ContactMethodTypeCode>'
	cXml += '    </SpecifiedPerson>'
	cXml += '</CustomerParty>'

	VC3->(DbSetOrder(1))
	VC3->(DbSeek(xFilial("VC3") + SA1->A1_COD + SA1->A1_LOJA))
	Do While ! VC3->(Eof()) .And. VC3->VC3_CODCLI == SA1->A1_COD .And. VC3->VC3_LOJA == SA1->A1_LOJA
		if ! Empty(VC3->VC3_CHASSI)
			cXml += '<Vehicle>'
			cXml += '  <Model>'+ALLTRIM(VC3->VC3_MODVEI)+'</Model>'
			cXml += '  <ModelYear>'+ALLTRIM(VC3->VC3_FABMOD)+'</ModelYear>'
			cXml += '  <MakeString>'+ALLTRIM( Posicione("VV2",1,xFilial("VV2")+VC3->VC3_CODMAR+VC3->VC3_MODVEI,"VV2_DESMOD") )+'</MakeString>'
			cXml += '  <VehicleID>'+ALLTRIM(VC3->VC3_CHASSI)+'</VehicleID>'
			cXml += '  <ManufacturerName>'+ALLTRIM( Posicione("VE1",1,xFilial("VE1")+VC3->VC3_CODMAR,"VE1_DESMAR") )+'</ManufacturerName>' // Parei aqiu, marca vai ser virtual tamb[em], pegar do relacao do x3
			cXml += '  <LicenseNumberString>'+ALLTRIM(VC3->VC3_PLAVEI)+'</LicenseNumberString>'
			cXml += '</Vehicle>'
		end
		VC3->(DbSkip())
	EndDo

	// cXml += '<Order>'
	// cXml += '  <DocumentDateTime>2007-10-04T19:40:47.000+05:30</DocumentDateTime>'
	// cXml += '  <OrderTypeCode>EMG</OrderTypeCode>'
	// cXml += '  <OrderReferenceNumberString>RO567</OrderReferenceNumberString>'
	// cXml += '  <OrderComments>Front brake needs to be replaced</OrderComments>'
	// cXml += '</Order>'

	// cXml += '<CustomizedData>'
	// cXml += '  <NameValue name="PreferredCustomer" groupName="CustomerCategory">Yes</NameValue>'
	// cXml += '  <Description>If the customer is preferred. If so, may get extra discount upto 10% more.</Description>'
	// cXml += '</CustomizedData>'

	cXml += '</Customer>'
Return cXml

/*/{Protheus.doc} DMS_PMPROGetSupportedProperties

	@author       Vinicius Gati
	@since        02/05/2017
	@description  Retorna dados para preço das peças

/*/
Class DMS_PMPROGetSupportedProperties
	DATA oAppArea
	Method New() CONSTRUCTOR
	Method getResponse()
EndClass

/*/{Protheus.doc} New

	@author       Vinicius Gati
	@since        10/05/2017
	@description  Construtor simples

/*/
Method New(oXml) Class DMS_PMPROGetSupportedProperties
	::oAppArea   := DMS_PMPROBODApplicationArea():New(oXml:_GETSUPPORTEDPROPERTIES)
Return SELF

Method getResponse() Class DMS_PMPROGetSupportedProperties
	Local cXml := ""

	cXml += '<?xml version="1.0" encoding="UTF-8"?>'
	cXml += '<ShowSupportedProperties releaseID="4.0" versionID="4.0"'
	cXml += '  systemEnvironmentCode="Production" languageCode="en-US" xmlns="http://snaponbusinesssolutions.com/4/PartPricingAndAvailability.xsd">'

	cXml += '  <ApplicationArea>'
	cXml += '    <Sender>'
	cXml += '      <ComponentID>PartPricingAndAvailabilityService</ComponentID>'
	cXml += '      <TaskID>ShowPartPriceAndAvailability</TaskID>'
	cXml += '      <ReferenceID>Protheus</ReferenceID>'
	cXml += '      <AuthorizationID>U123</AuthorizationID>'
	cXml += '      <CreatorNameCode>DMS</CreatorNameCode>'
	cXml += '      <SenderNameCode>DMS</SenderNameCode>'
	cXml += '      <PartyID>P123</PartyID>'
	cXml += '    </Sender>'
	cXml += '    <CreationDateTime>'+FWTimeStamp(3)+'</CreationDateTime>'
	cXml += '    <Destination>'
	cXml += '      <DestinationNameCode>EPC4</DestinationNameCode>'
	cXml += '      <StoreNumber>S123</StoreNumber>'
	cXml += '    </Destination>'
	cXml += '  </ApplicationArea>'

	cXml += '  <SupportedProperties>'
	cXml += '    <Property>'
	cXml += '      <NameValue name="OnOrderFrom" type="String"/>'
	cXml += '      <Description>Em Pedido</Description>'
	cXml += '    </Property>'
	cXml += '    <Property>'
	cXml += '      <NameValue name="AvailableInWarehouse" type="int"/>'
	cXml += '      <Description>Disponível</Description>'
	cXml += '    </Property>'
	cXml += '  </SupportedProperties>'
	cXml += '</ShowSupportedProperties>'
Return cXml


/*/{Protheus.doc} DMS_PMPROGetSupportedValues

	@author       Vinicius Gati
	@since        02/05/2017
	@description  Retorna dados para preço das peças

/*/
Class DMS_PMPROGetSupportedValues
	DATA oAppArea
	Method New() CONSTRUCTOR
	Method getResponse()
EndClass

/*/{Protheus.doc} New

	@author       Vinicius Gati
	@since        02/05/2017
	@description  Construtor simples

/*/
Method New(oXml) Class DMS_PMPROGetSupportedValues
	::oAppArea   := DMS_PMPROBODApplicationArea():New(oXml:_GETSUPPORTEDVALUES)
Return SELF

Method getResponse() Class DMS_PMPROGetSupportedValues
	Local cXml := ""

	cXml += '<?xml version="1.0" encoding="UTF-8"?>'
	cXml += '<ShowSupportedValues releaseID="4.0" versionID="4.0"'
	cXml += '  systemEnvironmentCode="Production" languageCode="en-US" xmlns="http://snaponbusinesssolutions.com/4/PartPricingAndAvailability.xsd">'

	cXml += '<ApplicationArea>'
	cXml += '  <Sender>'
	cXml += '      <ComponentID>PartPricingAndAvailabilityService</ComponentID>'
	cXml += '      <TaskID>ShowPartPriceAndAvailability</TaskID>'
	cXml += '      <ReferenceID>Protheus</ReferenceID>'
	cXml += '      <AuthorizationID>U123</AuthorizationID>'
	cXml += '      <CreatorNameCode>DMS</CreatorNameCode>'
	cXml += '      <SenderNameCode>DMS</SenderNameCode>'
	cXml += '      <PartyID>P123</PartyID>'
	cXml += '  </Sender>'
	cXml += '  <CreationDateTime>'+FWTimeStamp(3)+'</CreationDateTime>'
	cXml += '  <Destination>'
	cXml += '    <DestinationNameCode>EPC4</DestinationNameCode>'
	cXml += '    <StoreNumber>S123</StoreNumber>'
	cXml += '  </Destination>'
	cXml += '</ApplicationArea>'

	cXm += '    <Value>'
	cXm += '      <NameValue name="COST" type="String"/>'
	cXm += '      <Description>Vlr Custo</Description>'
	cXm += '    </Value>'
	cXm += '    <Value>'
	cXm += '      <NameValue name="SalesPrice" type="int"/>'
	cXm += '      <Description>Vlr Venda</Description>'
	cXm += '    </Value>'
	cXm += '  </SupportedValues>'
	cXm += '</ShowSupportedValues>'
Return cXml


/*/{Protheus.doc} DMS_PMPROGetPartPricingAndAvailability

	@author       Vinicius Gati
	@since        02/05/2017
	@description  Retorna dados para preço das peças

/*/
Class DMS_PMPROGetPartPricingAndAvailability
	DATA cItemId
	DATA cPartType
	DATA cBrand
	DATA oXml

	Method New() CONSTRUCTOR
	Method getResponse()
EndClass

/*/{Protheus.doc} New

	@author       Vinicius Gati
	@since        02/05/2017
	@description  Construtor simples

/*/
Method New(oXml) Class DMS_PMPROGetPartPricingAndAvailability
	::oAppArea  := DMS_PMPROBODApplicationArea():New(oXml:__GETPARTPRICINGANDAVAILABILITY)
	oNo:= oXml:_GETPARTPRICINGANDAVAILABILITYDATAAREA:_PARTPRICINGANDAVAILABILITY
	::cItemId   := oNo:_ITEMID:Text
	::cPartType := oNo:_PARTTYPE:Text
	::cBrand    := oNo:_BRAND:Text
Return SELF

Method getResponse() Class DMS_PMPROGetPartPricingAndAvailability
	Local cXml := ""
	Local oPeca := DMS_Peca():New(, self:cItemId)
	Local nQtdEst := 0

	cQuery += " SELECT R_E_C_N_O_ "
	cQuery += "   FROM "+RetSqlName('VAI')
	cQuery += "  WHERE VAI_FABUSR = '"+self:cCodTecnico+"' "
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	nRnoTec := FM_SQL(cQuery)

	if Empty(nRnoTec)
		cQuery += " SELECT R_E_C_N_O_ "
		cQuery += "   FROM "+RetSqlName('VAI')
		cQuery += "  WHERE VAI_FABUSR != ' ' "
		cQuery += "    AND D_E_L_E_T_ = ' ' "
		nRnoTec := FM_SQL("SELECT R_E_C_N_O_ FROM "+RetSqlName('VAI')+" WHERE VAI_CODUSR = '000000' AND D_E_L_E_T_ = ' '")
	end

	if nRnoTec > 0
		VAI->(DbGoTo(nRnoTec))
		cFilAnt := VAI->VAI_FILPRO

		SB1->(dbSelectArea('SB1'))
		SB1->(dbSetOrder(1))
		SB1->(dbSeek( xFilial('SB1') + self:cItemId ))

		oPeca   := DMS_Peca():New(SB1->B1_GRUPO, SB1->B1_COD)
		nQtdEst := oPeca:EstoqueSaldo2(SB1->B1_LOCPAD, .F.)
		nValVda := oPeca:ValorVenda()
		nQtdPed := oPeca:PedCompraPendente()
		nValCus := oPeca:ValorCusto()

	endif


	cXml += '<?xml version="1.0" encoding="UTF-8"?>'
	cXml += '<ShowPartPricingAndAvailability releaseID="5.0" versionID="4.0"'
	cXml += '    systemEnvironmentCode="Production" languageCode="en-US" xmlns="http://snaponbusinesssolutions.com/4/PartPricingAndAvailability.xsd">'

	cXmlResp += self:oAppArea:toXml()

	cXml += '<ShowPartPricingAndAvailabilityDataArea>'
	cXml +=   '<PartPricingAndAvailability>'

	cXml +=     '<ItemId>'+SB1->B1_COD+'</ItemId>'
	cXml +=     '<ItemIdDescription>'+SB1->B1_DESC+'</ItemIdDescription>'
	cXml +=     '<PartType>'+SB1->B1_TIPO+'</PartType>'
	cXml +=     '<Brand>'+SB1->B1_MARPEC+'</Brand>'
	cXml +=     '<PartClass>'+SB1->B1_UM+'</PartClass>'
	cXml +=     '<PartManufacturer>'+SB1->B1_MARPEC+'</PartManufacturer>'
	cXml +=     '<OnHand uom="ea">'+ALLTRIM(STR(nQtdEst))+'</OnHand>'
	cXml +=     '<OnOrder uom="ea">'+ALLTRIM(STR(nQtdPed))+'</OnOrder>'
	cXml +=     '<QuantityAvailable uom="ea">'+ALLTRIM(STR(nQtdEst))+'</QuantityAvailable>'
	cXml +=     '<Property>'
	cXml +=     '  <NameValue name="OnOrderFrom" type="String">Warehouse</NameValue>'
	cXml +=     '  <Description>OOF</Description>'
	cXml +=     '</Property>'
	cXml +=     '<Property>'
	cXml +=     '  <NameValue name="SpecialOrdersInStock"/>'
	cXml +=     '  <Description>Special Orders In Stock</Description>'
	cXml +=     '</Property>'

	cXml +=      '<Value>'
	cXml +=      '    <ItemValue>'
	cXml +=      '      <ActualAmount currencyId="BLR">'+ALLTRIM(STR(nValCus))+'</ActualAmount>'
	cXml +=      '      <PerQuantity uom="ea">1</PerQuantity>'
	cXml +=      '    </ItemValue>'
	cXml +=      '    <ValueClass>COST</ValueClass>'
	cXml +=      '    <Description>Valor Custo</Description>'
	cXml +=      '</Value>'

	cXml +=      '<Value>'
	cXml +=      '   <ItemValue>'
	cXml +=      '     <ActualAmount currencyId="BLR">'+ALLTRIM(STR(nValVda))+'</ActualAmount>'
	cXml +=      '     <PerQuantity uom="ea">1</PerQuantity>'
	cXml +=      '   </ItemValue>'
	cXml +=      '   <ValueClass>Sales Price</ValueClass>'
	cXml +=      '   <Description>Preço Venda</Description>'
	cXml +=      '</Value>'

	cXml +=     '</PartPricingAndAvailability>'
	cXml +=   '</ShowPartPricingAndAvailabilityDataArea>'
	cXml += '</ShowPartPricingAndAvailability>'
Return cXml
