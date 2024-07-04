#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPXEAI.CH'

/*/{Protheus.doc} GTPI003
Adapter da rotina de Trechos e Tarifas
@author jacomo.fernandes
@since 15/02/2017
@version 12.1.7
@param cXml, characters, O XML recebido pelo EAI Protheus
@param nTypeTrans, numeric, Tipo de transacao
		0	- para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
		1	- para mensagem sendo enviada (DEFINE TRANS_SEND) 
@param cTypeMessage, characters, Tipo da mensagem do EAI
		20	- Business Message (DEFINE EAI_MESSAGE_BUSINESS)
		21	- Response Message (DEFINE EAI_MESSAGE_RESPONSE)
		22	- Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
		23	- WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
@Return aRet, array, Retorna um array contendo as informações do adaper
		aRet[1]	- lRet		- Indica se ocorreu com sucesso
		aRet[2]	- cXMLRet	- String contendo o Xml que serÃ¡ Enviado
		aRet[3]	- cMsgUnica	- Nome do Adapter
@type function
/*/
Function GTPI003(cXml, nTypeTrans, cTypeMessage)
Local lRet      := .T. 
Local cXmlRet	:= ""
Local cMsgUnica := 'StretchFare'
Local aArea		:= GetArea()

If nTypeTrans == TRANS_RECEIVE
	Do Case
		//whois
		Case (cTypeMessage == EAI_MESSAGE_WHOIS) 
			cXmlRet := '1.000'
		
		//resposta da mensagem Ãºnica TOTVS
		Case (cTypeMessage == EAI_MESSAGE_RESPONSE) 
			cXmlRet := GI003Resp(cXml,@lRet)
		
		//chegada de mensagem de negÃ³cios
		Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
			cXmlRet := GI003Receb(cXml,@lRet)
	EndCase
Endif

RestArea(aArea)
GTPDestroy(aArea)
Return {lRet, cXmlRet, cMsgUnica}

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI003Resp
//Função utilizada para receber os valores da integraÃ§Ã£o (EAI_MESSAGE_RESPONSE)
@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela funÃ§Ã£o do IntegDef
@param lRet, logical, Variavel utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI003Resp(cXml,lRet)
Local oXml	:= tXMLManager():New()
Local cXmlRet := ""
Local aMsgUnic := {} 
aAdd(aMsgUnic, {"StretchFare","GI3","GI3_LINHA"})

If oXml:Parse(cXml)
	GxResponse(oXml,aMsgUnic)
Else
	lRet	:= .F.
	cXmlRet := STR0009//"Falha no Parse"
Endif

GTPDestroy(aMsgUnic)
GTPDestroy(oXml)
Return cXMLRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI003Receb
Função utilizada para executar o recebimento da integraÃ§Ã£o e atualizar o registro
@author jacomo.fernandes
@since 15/02/2017
@version undefined
@param cXml, characters, Xml passado pela funÃ§Ã£o do IntegDef
@param lRet, logical, Variavel passada por referncia utilizada para validar o processamento da rotina
@Return cXMLRet, characters, String contendo o xml de envio
@type function
/*/
Static Function GI003Receb(cXml,lRet)
Local oModel		:= Nil //FwLoadModel("GTPA003")
Local oMdlGI3		:= Nil
Local oMdlGI4		:= Nil
Local oMdlGI4b		:= Nil
Local oXml			:= tXMLManager():New()
Local cXmlRet		:= ""
Local cBusiMsg		:= '/TOTVSMessage/BusinessMessage'
Local cBusiCont		:= cBusiMsg+'/BusinessContent'
Local cLstOFItem	:= cBusiCont+'/ListOfStretchFare/StretchFare'
Local cLine			:= ""
Local lDelete		:= .F.
Local cMarca		:= "PROTHEUS"
Local cIntID		:= ""
Local cExtID		:= ""
Local nOpc			:= 0
Local lOk			:= .T.
Local cErro			:= ""
Local aInt			:= {}
Local aCampos		:= {"GI2_FILIAL","GI2_COD",{"GI2_HIST","2"}}
Local aCpoG9U		:= {"G9U_FILIAL","G9U_CODIGO"}//VIAS
Local aCpoGI0		:= {"GI0_FILIAL","GI0_COD"}//orgaos
Local aCpoGI1		:= {"GI1_FILIAL","GI1_COD"}//localidades
Local aDados		:= {}
Local aDadosSeq		:= {}
Local aIntId		:= {}
Local lMsblqlGI3	:= AllTrim(GetSx3Cache("GI3_MSBLQL", "X3_CAMPO")) == "GI3_MSBLQL"
Local lMsblqlGI4	:= AllTrim(GetSx3Cache("GI3_MSBLQL", "X3_CAMPO")) == "GI3_MSBLQL"
Local n1			:= 0
Local n2			:= 0
Local nCont			:= 0
Local cViaExt 		:= ""
Local cOrgaoExt		:= ""
Local cOriLocExt	:= ""
Local cDesLocExt	:= ""
Local cTempo		:= ""


Static cCode		:= ""
Static cViaCode		:= ""
Static cOrgaoCode	:= ""
Static cOriLocCod	:= ""
Static cDesLocCod	:= ""

If oXml:Parse(cXml)
	cMarca	:= AllTrim(oXml:XPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name'))
	lDelete := "DELETE" == UPPER(AllTrim(oXml:XPathGetNodeValue(cBusiMsg+'/BusinessEvent/Event')))
	
	cExtID		:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/LineInternalId'))
	cViaExt		:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/RouteInternalId'))
	cOrgaoExt	:= AllTrim(oXml:XPathGetNodeValue(cBusiCont + '/GrantingAgencyInternalId'))
	
	nCont		:= oXml:xPathChildCount(cBusiCont + '/ListOfStretchFare')
	
	aAdd(aInt,{cExtID		,"cCode"		,"GI2","GI2_COD"		,3,aCampos,4})
	aAdd(aInt,{cViaExt		,"cViaCode"		,"G9U","G9U_CODIGO"		,3,aCpoG9U,1})
	aAdd(aInt,{cOrgaoExt	,"cOrgaoCode"	,"GI0","GI0_COD"		,3,aCpoGI0,1})
	
	
	For n1 := 1 To Len(aInt)
		If !Empty(aInt[n1,1])
			&(aInt[n1,2]):= GTPxRetId(cMarca, aInt[n1,3], aInt[n1,4], aInt[n1,1], aInt[n1,2], aInt[n1,5],@lOk,@cErro,aInt[n1,6],aInt[n1,7])
							
			If !lOk
				lRet := .F.
				cXmlRet := GTPXErro(oModel,cErro)
				Exit
			Endif
		Endif
	Next
	
	If nCont > 1
		oModel := FwLoadModel('GTPA003')
		If lRet
			DbSelectArea("GI3")
			GI3->(DBOrderNickname('GI3HIST'))//GI3_FILIAL+GI3_LINHA+GI3_HIST
			If !lDelete
				If GI3->(DbSeek(xFilial('GI3')+cCode+"2"))
					nOpc := MODEL_OPERATION_UPDATE
				Else
					lRet := .F.
					oModel:SetErrorMessage("","",NIL,"","Gi003Inclui","Não é possivel incluir a linha nessa operação","Favor realizar o cadastro previo da Linha")
				Endif
			Else
				lRet := .F.
				oModel:SetErrorMessage("","",NIL,"","Gi003Delete","Não foi possivel deletar a linha: " + cExtID,"Favor verificar o cadastro de Linhas")
			Endif
		Endif
	
		If lRet
			oModel:SetOperation(nOpc)
			
			If oModel:Activate()
				oMdlGI3:= oModel:GetModel("GI3MASTER")
				If !lDelete
					
					aAdd(aDados,{"GI3_LINHA"	,cCode		,cBusiCont + '/LineInternalId'})
					aAdd(aDados,{"GI3_VIA"		,cViaCode	,cBusiCont + '/RouteInternalId'})
					aAdd(aDados,{"GI3_ORGAO"	,cOrgaoCode,cBusiCont + '/GrantingAgencyInternalId'})
					
					If lMsblqlGI3
						aAdd(aDados,{"GI3_MSBLQL",		,cBusiCont + '/Situation'})
					Endif
					
					For n1 := 1 to Len(aDados)
						If !GxGetNdXml(oMdlGI3,oXml,aDados[n1][1],aDados[n1][2],aDados[n1][3])
							lRet := .F.
							Exit
						Endif
					Next
					
					If lRet .and. nCont > 0
						oMdlGI4 := oModel:GetModel("GI4DETAIL")
						oMdlGI4B:= oModel:GetModel('FIELDGI4B')
						For n2 := 1 to nCont
							cLine	:= cLstOFItem+"["+cValToChar(n2)+"]"
							aSize(aInt,0)
							aSize(aDadosSeq,0)
							
							cOriLocExt	:= AllTrim(oXml:XPathGetNodeValue(cLine + '/OriginLocalityInternalId')) 
							cDesLocExt	:= AllTrim(oXml:XPathGetNodeValue(cLine + '/DestinyLocalityInternalId')) 
							aAdd(aInt,{cOriLocExt	,"cOriLocCod"	,"GI1","GI1_COD",3,aCpoGI1,1})
							aAdd(aInt,{cDesLocExt	,"cDesLocCod"	,"GI1","GI1_COD",3,aCpoGI1,1})
		
							For n1 := 1 To Len(aInt)
								If !Empty(aInt[n1,1])
									&(aInt[n1,2]):= GTPxRetId(cMarca, aInt[n1,3], aInt[n1,4], aInt[n1,1], aInt[n1,2], aInt[n1,5],@lOk,@cErro,aInt[n1,6],aInt[n1,7])
									If !lOk
										lRet := .F.
										cXmlRet := GTPXErro(oModel,cErro)
										Exit
									Endif
								Endif
							Next
							If lRet
								If oMdlGI4:SeekLine({{'GI4_LOCORI',cOriLocCod},{'GI4_LOCDES',cDesLocCod}})
									cTempo:= AllTrim(oXml:XPathGetNodeValue(cLine + '/TravelTime'))
									aAdd(aDadosSeq,{"GI4_KM"		,	,cLine + '/Distance'				})
									aAdd(aDadosSeq,{"GI4_TEMPO"	,GTFormatHour(cTempo,'9999')	,cLine + '/TravelTime'				})
									aAdd(aDadosSeq,{"GI4_CCS"	,	,cLine + '/CCS'						})
									aAdd(aDadosSeq,{"GI4_TARANU",	,cLine + '/AnnualFee'				})
									aAdd(aDadosSeq,{"GI4_VIGTAR",	,cLine + '/DateEffectiveFare'		})
									aAdd(aDadosSeq,{"GI4_TAR"	,	,cLine + '/FareValue'				})
									aAdd(aDadosSeq,{"GI4_VIGTAX",	,cLine + '/DateEffectiveFee'		})
									aAdd(aDadosSeq,{"GI4_TAX"	,	,cLine + '/BoardingFee'				})
									aAdd(aDadosSeq,{"GI4_VIGPED",	,cLine + '/DateEffectiveToll'		})
									aAdd(aDadosSeq,{"GI4_PED"	,	,cLine + '/TollValue'				})
									aAdd(aDadosSeq,{"GI4_VIGSGF",	,cLine + '/DateEffectiveInsurance'	})
									aAdd(aDadosSeq,{"GI4_SGFACU",	,cLine + '/InsuranceValue'			})
									aAdd(aDadosSeq,{"GI4_KMPED"	,	,cLine + '/DistanceToNextToll'		})
									aAdd(aDadosSeq,{"GI4_KMTERR",	,cLine + '/DistanceOfDirtRoad'		})
									aAdd(aDadosSeq,{"GI4_KMASFA",	,cLine + '/DistanceOfAsphaltRoad'	})
									If lMsblqlGI4
										aAdd(aDadosSeq,{"GI4_MSBLQL",	,cLine + '/Situation'	})
									Endif
									For n1 := 1 to Len(aDadosSeq)
										If !GxGetNdXml(oMdlGI4b,oXml,aDadosSeq[n1][1],aDadosSeq[n1][2],aDadosSeq[n1][3])
											lRet := .F.
											Exit
										Endif
									Next
								Else
									lRet := .F.
									oModel:SetErrorMessage("GI4DETAIL","",NIL,"","Gi003SeekLine","Não foi possivel encontrar o trecho de Origem: " + cOriLocExt+ " e Destino: "+cDesLocExt,"Favor verificar o cadastro de Linhas")
									Exit
								Endif
							Endif
							If !lRet .or. !oMdlGI4:VldLineData()
								lRet := .F.
								Exit
							Endif
						Next
						
					Endif
				Endif
				
				If lRet .and. oModel:VldData() 
					If Empty(cIntId)
						cIntId := GTPxMakeId(oMdlGI3:GetValue('GI3_LINHA'), 'GI3')
					Endif
					oModel:CommitData()
					aAdd(aIntId, {"StretchFare",cExtId,cIntId,cMarca,"GI3","GI3_LINHA"})
					cXmlRet := GxListOfId(aIntId,lDelete,.F.)
				Else
					lRet := .F.
					cXmlRet := GTPXErro(oModel,cErro)
				Endif
				oModel:DeActivate()
			Endif
		Else
			cXmlRet := GTPXErro(oModel,cErro)
		Endif
	Else
		oModel := FwLoadModel('GTPI003')
		
		cLine	:= cLstOFItem+"["+cValToChar(1)+"]"
		cOriLocExt	:= AllTrim(oXml:XPathGetNodeValue(cLine + '/OriginLocalityInternalId')) 
		cDesLocExt	:= AllTrim(oXml:XPathGetNodeValue(cLine + '/DestinyLocalityInternalId')) 
		aAdd(aInt,{cOriLocExt	,"cOriLocCod"	,"GI1","GI1_COD",3,aCpoGI1,1})
		aAdd(aInt,{cDesLocExt	,"cDesLocCod"	,"GI1","GI1_COD",3,aCpoGI1,1})

		For n1 := 1 To Len(aInt)
			If !Empty(aInt[n1,1])
				&(aInt[n1,2]):= GTPxRetId(cMarca, aInt[n1,3], aInt[n1,4], aInt[n1,1], aInt[n1,2], aInt[n1,5],@lOk,@cErro,aInt[n1,6],aInt[n1,7])
				If !lOk
					lRet := .F.
					cXmlRet := GTPXErro(oModel,cErro)
					Exit
				Endif
			Endif
		Next
														
		If lRet
			DbSelectArea("GI4")
			GI4->(DbSetOrder(5))//GI4_FILIAL+GI4_LINHA+GI4_LOCORI+GI4_LOCDES+GI4_HIST
			If !lDelete
				If GI4->(DbSeek(xFilial('GI4')+cCode+cOriLocCod+cDesLocCod+"2"))
					nOpc := MODEL_OPERATION_UPDATE
				Else
					lRet := .F.
					oModel:SetErrorMessage("GI4DETAIL","",NIL,"","Gi003SeekLine","Não foi possivel encontrar o trecho de Origem: " + cOriLocExt+ " e Destino: "+cDesLocExt,"Favor verificar o cadastro de Linhas")
				Endif
			Else
				lRet := .F.
				oModel:SetErrorMessage("","",NIL,"","Gi003Delete","Não foi possivel deletar o trecho de Origem: " + cOriLocExt+ " e Destino: "+cDesLocExt,"Favor verificar o cadastro de Linhas")
			Endif
		Endif
	
		
		If lRet
			oModel:SetOperation(nOpc)
			
			If oModel:Activate()
				oMdlGI4:= oModel:GetModel("GI4MASTER")
				
				cTempo:= AllTrim(oXml:XPathGetNodeValue(cLine + '/TravelTime'))
				aAdd(aDadosSeq,{"GI4_KM"	,	,cLine + '/Distance'				})
				aAdd(aDadosSeq,{"GI4_TEMPO"	,GTFormatHour(cTempo,'9999')	,cLine + '/TravelTime'				})
				aAdd(aDadosSeq,{"GI4_CCS"	,	,cLine + '/CCS'						})
				aAdd(aDadosSeq,{"GI4_TARANU",	,cLine + '/AnnualFee'				})
				aAdd(aDadosSeq,{"GI4_VIGTAR",	,cLine + '/DateEffectiveFare'		})
				aAdd(aDadosSeq,{"GI4_TAR"	,	,cLine + '/FareValue'				})
				aAdd(aDadosSeq,{"GI4_VIGTAX",	,cLine + '/DateEffectiveFee'		})
				aAdd(aDadosSeq,{"GI4_TAX"	,	,cLine + '/BoardingFee'				})
				aAdd(aDadosSeq,{"GI4_VIGPED",	,cLine + '/DateEffectiveToll'		})
				aAdd(aDadosSeq,{"GI4_PED"	,	,cLine + '/TollValue'				})
				aAdd(aDadosSeq,{"GI4_VIGSGF",	,cLine + '/DateEffectiveInsurance'	})
				aAdd(aDadosSeq,{"GI4_SGFACU",	,cLine + '/InsuranceValue'			})
				aAdd(aDadosSeq,{"GI4_KMPED"	,	,cLine + '/DistanceToNextToll'		})
				aAdd(aDadosSeq,{"GI4_KMTERR",	,cLine + '/DistanceOfDirtRoad'		})
				aAdd(aDadosSeq,{"GI4_KMASFA",	,cLine + '/DistanceOfAsphaltRoad'	})
				If lMsblqlGI4
					aAdd(aDadosSeq,{"GI4_MSBLQL",	,cLine + '/Situation'	})
				Endif
				For n1 := 1 to Len(aDadosSeq)
					If !GxGetNdXml(oMdlGI4,oXml,aDadosSeq[n1][1],aDadosSeq[n1][2],aDadosSeq[n1][3])
						lRet := .F.
						Exit
					Endif
				Next
			
				If lRet .and. oModel:VldData() 
					//If Empty(cIntId)
					//	cIntId := GTPxMakeId(oMdlGI4:GetValue('GI4_LINHA'), 'GI4')
					//Endif
					oModel:CommitData()
					//aAdd(aIntId, {"StretchFare",cExtId,cIntId,cMarca,"GI3","GI3_LINHA"})
					//cXmlRet := GxListOfId(aIntId,lDelete,.F.)
				Else
					lRet := .F.
					cXmlRet := GTPXErro(oModel,cErro)
				Endif
				oModel:DeActivate()
			Endif
		Else
			lRet := .F.
			cXmlRet := GTPXErro(oModel,cErro)
		Endif
		
	Endif
		
Else
	lRet	:= .F.
	cXmlRet := STR0009//"Falha no Parse"
Endif

oModel:Destroy()

GTPDestroy(oModel)
GTPDestroy(oMdlGI4)
GTPDestroy(oXml)
GTPDestroy(aDados)
GTPDestroy(aIntId)
GTPDestroy(aCampos)
GTPDestroy(aCpoG9U)
GTPDestroy(aCpoGI0)
GTPDestroy(aCpoGI1)
GTPDestroy(aInt)
GTPDestroy(aDadosSeq)
Return cXmlRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados

@sample 	ModelDef()

@return 	oModel  Retorna o Modelo de Dados

@author	Lucas Brustolin -  Inovação
@since		09/10/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel 	:= NIL
	Local oStruGI4	:= FWFormStruct(1,'GI4' )
	Local oStruG5G	:= FWFormStruct(1,'G5G' )
	
	oStruGI4:AddField(	"Linha","Linha","GI4_LINHA","C",TAMSX3('GI4_LINHA')[1],0,Nil,Nil,Nil,.F.,NIL,.T.,.F.,.F.)
	oStruGI4:AddField(	"VIA","VIA","GI4_VIA","C",TAMSX3('GI4_VIA')[1],0,Nil,Nil,Nil,.F.,NIL,.T.,.F.,.F.)
	 
	oStruGI4:SetProperty('GI4_LINHA',MODEL_FIELD_INIT,{|| If(!Inclui,GI4->GI4_LINHA,'')})
	oStruGI4:SetProperty('GI4_VIA',MODEL_FIELD_INIT,{|| If(!Inclui,GI4->GI4_VIA,'')})
	oStruG5G:SetProperty('G5G_VIA',MODEL_FIELD_OBRIGAT,.F.)
	
	oModel 	:= MPFormModel():New('GTPI003', /*bPreValid*/, {|oModel| GI003PosVld(oModel)}/*bPosValid*/, /*bCommit*/, /*bCancel*/ )
	
	oModel:AddFields(	'GI4MASTER', /*cOwner*/,oStruGI4 )
	oModel:AddGrid(		'G5GDETAIL','GI4MASTER',oStruG5G)
	oModel:SetRelation( 'G5GDETAIL', { { 'G5G_FILIAL'	, 'xFilial( "G5G" )' }, { 'G5G_CODLIN'	, 'GI4_LINHA' }, { 'G5G_VIA'	, 'GI4_VIA' }, { 'G5G_LOCORI'	, 'GI4_LOCORI' }, { 'G5G_LOCDES'	, 'GI4_LOCDES' },{ 'G5G_SENTID'	, 'GI4_SENTID' },{ 'G5G_REVISA'	, 'GI4_REVISA' } } , G5G->(IndexKey(3)))
	
	oModel:GetModel("G5GDETAIL"):SetOptional(.T.)
	oModel:SetDescription("Trechos e Tarifas")//Agências
	oModel:SetPrimaryKey({})
Return ( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} GI003PosVld()
Pos Validacao do modelo de dados

@sample 	GI003PosVld()

@return 	lRet  Retorna se esta tudo certo

@author	jacomo.fernandes
@since		13/07/2018
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function GI003PosVld(oModel)
Local lRet		:= .T.
Local oGI4Field	:= oModel:GetModel('GI4MASTER')
Local oG5GGrid	:= oModel:GetModel('G5GDETAIL')
Local dDtReaj	:= dDataBase
Local cTmReaj	:= Time()

	//Tarifa - Verifica se o campo de valor ou data vigencia foi alterada
	If oGI4Field:IsFieldUpdated('GI4_TAR') .Or. oGI4Field:IsFieldUpdated('GI4_VIGTAR')
		GA003G4GHIS(oG5GGrid,'1',oGI4Field:GetValue('GI4_TAR'),oGI4Field:GetValue('GI4_VIGTAR'),dDtReaj,cTmReaj)
	Endif
	
	//Pedagio- Verifica se o campo de valor ou data vigencia foi alterada
	If oGI4Field:IsFieldUpdated('GI4_PED') .Or. oGI4Field:IsFieldUpdated('GI4_VIGPED')
		GA003G4GHIS(oG5GGrid,'2',oGI4Field:GetValue('GI4_PED'),oGI4Field:GetValue('GI4_VIGPED'),dDtReaj,cTmReaj)
	Endif

	//Taxa- Verifica se o campo de valor ou data vigencia foi alterada
	If oGI4Field:IsFieldUpdated('GI4_TAX') .Or. oGI4Field:IsFieldUpdated('GI4_VIGTAX')
		GA003G4GHIS(oG5GGrid,'3',oGI4Field:GetValue('GI4_TAX'),oGI4Field:GetValue('GI4_VIGTAX'),dDtReaj,cTmReaj)
	Endif
	
	//Seguro- Verifica se o campo de valor ou data vigencia foi alterada
	If oGI4Field:IsFieldUpdated('GI4_SGFACU') .Or. oGI4Field:IsFieldUpdated('GI4_VIGSGF')
		GA003G4GHIS(oG5GGrid,'4',oGI4Field:GetValue('GI4_SGFACU'),oGI4Field:GetValue('GI4_VIGSGF'),dDtReaj,cTmReaj)
	Endif
		

Return lRet
