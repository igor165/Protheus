#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'ATFI051.CH'

Static cMessage := 'AssetDepreciation' //Nome da Mensagem Única
Static aDados   := {} //Array de Dados


//-------------------------------------------------------------------
/*/{Protheus.doc} ATFI051
Funcao de integracao com o adapter EAI para envio e recebimento do
Calculo Mensal de Depreciação utilizando o conceito de mensagem unica.

@param   cXml          Variável com conteúdo XML para envio/recebimento.
@param   cTypeTrans    Tipo de transação (Envio / Recebimento).
@param   cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param   cVersion      Versão da mensagem.
@param   cTransac      Nome da transação.

@return  aRet   - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio

@author	Wilson Possani de Godoi
@since		14/11/2013
@version	MP11.90
@obs

/*/
//-------------------------------------------------------------------

Function ATFI051(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Local cXmlRet			:= ''
Local cErroXml			:= ''
Local cWarnXml			:= ''
Local lRet				:= .T.
Local aRet              := {} //Array de Retorno

Private lMsErroAuto		:= .F.
Private lMsHelpAuto		:= .T.
Private oXmlATF051		:= Nil

If lRet
	// verificação do tipo de transação recebimento ou envio
	// trata o envio
	If cTypeTrans == TRANS_SEND
		//Verificando a versão
		If cVersion = "1."
			aRet := v1000(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
		ElseIf cVersion = "2."
			aRet := v2000(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
		Else
			lRet := .F.
			cXmlRet := STR0002 //"A versão da mensagem informada não foi implementada!"
			aRet := {lRet, cXmlRet, cMessage}
		EndIf
	ElseIf cTypeTrans == TRANS_RECEIVE

		If   cTypeMsg == EAI_MESSAGE_WHOIS // Informação das versões compatíveis com a mensagem única.
			cXMLRet := '1.000|2.000'
			aRet := {lRet, cXmlRet, cMessage}

		ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE // EAI_MESSAGE_RESPONSE == resposta de uma BUSINESS_MESSAGE
			oXmlATF051 := XmlParser(cXml, "_", @cErroXml, @cWarnXml)
			If ! (oXmlATF051 <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml))
				lRet    := .F.
				cXMLRet :=  STR0001+" " + cErroXml + ' | ' + cWarnXml  //'Erro na leitura do XML |'
				//Colocar resultado num Log e apresentar na tela ao final do Processo todo.
				aRet := {lRet, cXmlRet, cMessage}
			EndIf
		EndIf

	EndIf

EndIf

Return aRet

/*/{Protheus.doc} v1000
Implementação do adapter EAI, versão 1.x

@author  Alison Kaique
@version P12
@since   Sep/2018
/*/
Static Function v1000()
Local cEvent 		:= 'upsert'
Local cXmlRet		:= ''
Local nCount		:= 0
Local dDataIni		:= FirstDay(dDataBase)
Local dDataFim		:= 	LastDay(dDataBase)
Local cDataIni 		:= Substr(DtoS(dDataIni),1,4) + '-' + Substr(DtoS(dDataIni),5,2) + '-' +  Substr(DtoS(dDataIni),7,2)
Local cDataFim      := Substr(DtoS(dDataFim),1,4) + '-' + Substr(DtoS(dDataFim),5,2) + '-' +  Substr(DtoS(dDataFim),7,2)
Local nY			:= 0
Local lRet			:= .T.

//Na Versão 1.x reajustar

For nY := 1 to Len(aDados)

	If nY == 01
		cXmlRet	:= ''
		cXMLRet := '<BusinessEvent>'
		cXMLRet +=     '<Entity>AssetDepreciation</Entity>'
		cXMLRet +=     '<Event>' + cEvent + '</Event>'
		cXMLRet +=     '<Identification>'
		cXMLRet +=         '<key name="InternalId">'	+ cFilAnt + aDados[nY][1] + aDados[nY][2] +	'</key>'
		cXMLRet +=     '</Identification>'
		cXMLRet += '</BusinessEvent>'
		cXMLRet += 	'<BusinessContent>'
	  	cXMLRet +=		'<SelectionInformation>'
		cXMLRet +=		    '<AssetInformation>'
		cXMLRet +=		    	'<AssetIni></AssetIni>'
		cXMLRet +=			 	'<AssetFin></AssetFin>'
		cXMLRet +=			'</AssetInformation>'
		cXMLRet +=			'<CostCenterInformation>'
		cXMLRet +=			   	'<CostCenterIni></CostCenterIni>'
		cXMLRet +=			   	'<CostCenterFin></CostCenterFin>'
		cXMLRet +=			'</CostCenterInformation>'
		cXMLRet +=			'<ListOfRuleInformation>'
		cXMLRet +=			   	'<RuleInformation>'
		cXMLRet +=			    	'<RuleType></RuleType>'
		cXMLRet +=			       	'<InitialValue>0</InitialValue>'
		cXMLRet +=			       	'<FinalValue>0</FinalValue>'
		cXMLRet +=				'</RuleInformation>'
		cXMLRet +=			'</ListOfRuleInformation>'
		cXMLRet +=	 	'</SelectionInformation>'
		cXMLRet +=		'<ParametersInformation>'
		cXMLRet +=			'<PeriodInformation>'
		cXMLRet +=			     '<DateIni>' + cDataIni + '</DateIni>'
		cXMLRet +=			     '<DateFin>' + cDataFim + '</DateFin>'
		cXMLRet +=			'</PeriodInformation>'
		cXMLRet +=			     '<FirstPart>.T.</FirstPart>'
		cXMLRet +=		'</ParametersInformation>'
		cXMLRet +=		'<ListOfAssetDepreciation>'
   	EndIf

	cXMLRet +=			'<AssetDepreciation>
	cXMLRet +=				'<AssetInformation>
	cXMLRet +=			    	'<CompanyId>' + cEmpAnt + '</CompanyId>'
	cXMLRet +=			        '<BranchId>' + cFilAnt + '</BranchId>'
	cXMLRet +=			        '<CompanyInternalId>' + cEmpAnt + "|" + cFilAnt + '</CompanyInternalId>'
	cXMLRet +=			        '<AssetCode>' + _NoTags( AllTrim( aDados[nY][1] ) ) + _NoTags( Alltrim( aDados[nY][2] ) ) + '</AssetCode>'
	cXMLRet +=			        '<CostCenterCode>' + _NoTags( AllTrim( aDados[nY][4] ) ) + '</CostCenterCode>'
	cXMLRet +=			 	'</AssetInformation>'
	cXMLRet +=			  	'<ListOfDepreciation>'
	cXMLRet +=			    	'<Depreciation>'
	cXMLRet +=			        	'<PeriodDepreciationAmount>' + cValToChar( aDados[nY][7] ) + '</PeriodDepreciationAmount>'
	cXMLRet +=			          	'<PeriodAmortizationAmount>0</PeriodAmortizationAmount>'
	cXMLRet +=			        '</Depreciation>'
	cXMLRet +=				'</ListOfDepreciation>'
	cXMLRet +=			'</AssetDepreciation>'

	If ( (nY) >= Len(aDados) )
		cXMLRet +=		'</ListOfAssetDepreciation>'
		cXMLRet +=	'</BusinessContent>'
	Endif

Next nY

Return {lRet, cXMLRet, cMessage}

/*/{Protheus.doc} v2000
Implementação do adapter EAI, versão 2.x

@author  Alison Kaique
@version P12
@since   Sep/2018
/*/
Static Function v2000(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
	Local cEvent 	:= 'upsert'
	Local cXmlRet	:= ''
	Local nCount	:= 0
	Local dDataIni	:= FirstDay(dDataBase)
	Local dDataFim	:= 	LastDay(dDataBase)
	Local cDataIni 	:= Substr(DtoS(dDataIni),1,4) + '-' + Substr(DtoS(dDataIni),5,2) + '-' +  Substr(DtoS(dDataIni),7,2)
	Local cDataFim  := Substr(DtoS(dDataFim),1,4) + '-' + Substr(DtoS(dDataFim),5,2) + '-' +  Substr(DtoS(dDataFim),7,2)
	Local nY        := 0
	Local nZ        := 0
	Local nIDEnt    := 0
	Local lRet		:= .T.

	//Percorrendo Array
	For nY := 01 To Len(aDados)
		//Montando XML para envio
		If nY == 1
			cXmlRet	:= ''
			cXMLRet := '<BusinessEvent>'
			cXMLRet +=     '<Entity>AssetDepreciation</Entity>'
			cXMLRet +=     '<Event>' + cEvent + '</Event>'
			cXMLRet +=     '<Identification>'
			cXMLRet +=         '<key name="InternalId">' + cEmpAnt + '|' + cFilAnt + '|' + _NoTags( AllTrim( aDados[nY, 01] ) ) + _NoTags( Alltrim( aDados[nY, 02] ) ) +	'</key>'
			cXMLRet +=     '</Identification>'
			cXMLRet += '</BusinessEvent>'
			cXMLRet += 	'<BusinessContent>'
			cXMLRet +=		'<SelectionInformation>'
			cXMLRet +=		    '<AssetInformation>'
			cXMLRet +=		    	'<AssetIni/>'
			cXMLRet +=			 	'<AssetFin/>'
			cXMLRet +=			'</AssetInformation>'
			cXMLRet +=			'<CostCenterInformation>'
			cXMLRet +=			   	'<CostCenterIni/>'
			cXMLRet +=			   	'<CostCenterFin/>'
			cXMLRet +=			'</CostCenterInformation>'
			cXMLRet +=			'<ListOfRuleInformation>'
			cXMLRet +=			   	'<RuleInformation>'
			cXMLRet +=			    	'<RuleType/>'
			cXMLRet +=			       	'<InitialValue>0</InitialValue>'
			cXMLRet +=			       	'<FinalValue>0</FinalValue>'
			cXMLRet +=				'</RuleInformation>'
			cXMLRet +=			'</ListOfRuleInformation>'
			cXMLRet +=	 	'</SelectionInformation>'
			cXMLRet +=		'<ParametersInformation>'
			cXMLRet +=			'<PeriodInformation>'
			cXMLRet +=			     '<DateIni>' + cDataIni + '</DateIni>'
			cXMLRet +=			     '<DateFin>' + cDataFim + '</DateFin>'
			cXMLRet +=			'</PeriodInformation>'
			cXMLRet +=			     '<FirstPart>.T.</FirstPart>'
			cXMLRet +=		'</ParametersInformation>'
			cXMLRet +=		'<ListOfAssetDepreciation>'
		EndIf

		cXMLRet +=			'<AssetDepreciation>
		cXMLRet +=				'<AssetInformation>
		cXMLRet +=			    	'<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet +=			        '<BranchId>' + cFilAnt + '</BranchId>'
		cXMLRet +=			        '<CompanyInternalId>' + cEmpAnt + "|" + cFilAnt + '</CompanyInternalId>'
		cXMLRet +=			        '<AssetInternalId>' + cEmpAnt + '|' + cFilAnt + '|' + _NoTags( AllTrim( aDados[nY, 01] ) ) + _NoTags( Alltrim( aDados[nY, 02] ) ) + '</AssetInternalId>'
		cXMLRet +=			        '<AssetCode>' + _NoTags( AllTrim( aDados[nY, 01] ) ) + _NoTags( Alltrim( aDados[nY, 02] ) ) + '</AssetCode>'

		/**Entidades Contábeis**/
		//Contá Contábil
		If !(Empty(aDados[nY, 03]))
			cXMLRet +=			        '<AccountantAccountInternalId>' + cEmpAnt + '|' + cFilAnt + '|' + _NoTags( AllTrim( aDados[nY, 03] ) ) + '</AccountantAccountInternalId>'
			cXMLRet +=			        '<AccountantAccountCode>' + _NoTags( AllTrim( aDados[nY, 03] ) ) + '</AccountantAccountCode>'
		Else
			cXMLRet +=			        '<AccountantAccountInternalId/>'
			cXMLRet +=			        '<AccountantAccountCode/>'
		EndIf
		//Centro de Custo
		If !(Empty(aDados[nY, 04]))
			cXMLRet +=			        '<CostCenterInternalId>' + cEmpAnt + '|' + cFilAnt + '|' + _NoTags( AllTrim( aDados[nY, 04] ) ) + '</CostCenterInternalId>'
			cXMLRet +=			        '<CostCenterCode>' + _NoTags( AllTrim( aDados[nY, 04] ) ) + '</CostCenterCode>'
		Else
			cXMLRet +=			        '<CostCenterInternalId/>'
			cXMLRet +=			        '<CostCenterCode/>'
		EndIf
		//Item Contábil
		If !(Empty(aDados[nY, 05]))
			cXMLRet +=			        '<AccountantItemInternalId>' + cEmpAnt + '|' + cFilAnt + '|' + _NoTags( AllTrim( aDados[nY, 05] ) ) + '</AccountantItemInternalId>'
			cXMLRet +=			        '<AccountantItemCode>' + _NoTags( AllTrim( aDados[nY, 05] ) ) + '</AccountantItemCode>'
		Else
			cXMLRet +=			        '<AccountantItemInternalId/>'
			cXMLRet +=			        '<AccountantItemCode/>'
		EndIf
		//Classe de Valor
		If !(Empty(aDados[nY, 06]))
			cXMLRet +=			        '<ClassValueInternalId>' + cEmpAnt + '|' + cFilAnt + '|' + _NoTags( AllTrim( aDados[nY, 06] ) ) + '</ClassValueInternalId>'
			cXMLRet +=			        '<ClassValueCode>' + _NoTags( AllTrim( aDados[nY, 06] ) ) + '</ClassValueCode>'
		Else
			cXMLRet +=			        '<ClassValueInternalId/>'
			cXMLRet +=			        '<ClassValueCode/>'
		EndIf

		/**Entidades Contábeis Adicionais**/
		nIDEnt := 05
		For nZ := 08 To Len(aDados[nY])
			//Verifica se há conteúdo
			If !(Empty(aDados[nY, nZ]))
				cXMLRet +=			        '<ManagerialAccountingEntity' + StrZero(nIDEnt, 02) + 'InternalId>' + cEmpAnt + '|' + cFilAnt + '|' + _NoTags( AllTrim( aDados[nY, nZ] ) ) + '</ManagerialAccountingEntity' + StrZero(nIDEnt, 02) + 'InternalId>'
				cXMLRet +=			        '<ManagerialAccountingEntity' + StrZero(nIDEnt, 02) + 'Code>' + _NoTags( AllTrim( aDados[nY, nZ] ) ) + '</ManagerialAccountingEntity' + StrZero(nIDEnt, 02) + 'Code>'
			Else
				cXMLRet +=			        '<ManagerialAccountingEntity' + StrZero(nIDEnt, 02) + 'InternalId/>'
				cXMLRet +=			        '<ManagerialAccountingEntity' + StrZero(nIDEnt, 02) + 'Code/>'
			EndIf
			nIDEnt ++
		Next nZ

		cXMLRet +=			 	'</AssetInformation>'
		cXMLRet +=			  	'<ListOfDepreciation>'
		cXMLRet +=			    	'<Depreciation>'
		cXMLRet +=			        	'<PeriodDepreciationAmount>' + cValToChar(aDados[nY, 07]) + '</PeriodDepreciationAmount>'
		cXMLRet +=			          	'<PeriodAmortizationAmount>0</PeriodAmortizationAmount>'
		cXMLRet +=			        '</Depreciation>'
		cXMLRet +=				'</ListOfDepreciation>'
		cXMLRet +=			'</AssetDepreciation>'

		If ( (nY) >= Len(aDados) )
			cXMLRet +=		'</ListOfAssetDepreciation>'
			cXMLRet +=	'</BusinessContent>'
			nCount 	:= 0
		Endif
	Next nY

Return {lRet, cXmlRet, cMessage}

/*/{Protheus.doc} ATFI051Dad
Atribui o Array de Dados para Processamento da Mensagem Única

@param		aDadEAI, Dados EAI

@author 	Alison Kaique
@version 	P12
@since 		Oct/2018
/*/
Function ATFI051Dad(aDadEAI)
	aDados := aDadEAI
Return