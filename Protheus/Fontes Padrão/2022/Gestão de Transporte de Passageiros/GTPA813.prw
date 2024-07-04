#Include "Protheus.ch"
#Include "FWMVCDEF.CH"
#Include "GTPA813.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA813
Função responsavel pela definição da view
@type Function
@author jacomo.fernandes
@since 12/11/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Function GTPA813()
Local oBrowse := ''
If(GI9->GI9_STATRA <> "6") 

	oBrowse:= FWLoadBrw('GTPA813')
	SetKey( VK_F5 , {||GTPA813ATU()} ) 
	oBrowse:Activate()
	SetKey( VK_F5 , ) 

Else
	 FwAlertHelp(STR0016)//'Não Existem Eventos para Manifestos Operacionais'
	Return
EndIf

Return oBrowse

//------------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Função responsavel pela definição do browse da Amarração de Recurso x Documento
@type Static Function
@author jacomo.fernandes
@since 09/07/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return oBrowse, retorna o objeto de browse
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse       := FWMBrowse():New()
Local oColumn       := NIL

oBrowse:SetAlias("GIK")
oBrowse:SetMenuDef('GTPA813')

oBrowse:SetDescription(STR0001) //"Cadastro de Eventos"

oBrowse:SetFilterDefault("GIK->GIK_CODIGO = '"+GI9->GI9_CODIGO+"' ")

//Status Encomenda
oBrowse:AddLegend("GIK_STATUS=='0'"    , "WHITE"	, STR0002)//"Não Enviado"       			
oBrowse:AddLegend("GIK_STATUS=='1'"    , "YELLOW"	, STR0003)//"Enviado ao TSS"				
oBrowse:AddLegend("GIK_STATUS=='2'"    , "ORANGE"	, STR0004)//"Assinado no TSS"  			
oBrowse:AddLegend("GIK_STATUS=='3'"    , "GRAY"		, STR0005)//"Falha na Transmissão TSS"      
oBrowse:AddLegend("GIK_STATUS=='4'"    , "BLUE"		, STR0006)//"Transmitido"         		
oBrowse:AddLegend("GIK_STATUS=='5'"    , "RED"		, STR0007)//"Com erro no Sefaz"        	
oBrowse:AddLegend("GIK_STATUS=='6'"    , "GREEN"	, STR0008)//"Registrado e vinculado ao MDFe"


//Tipo CTE
// Adiciona as colunas do Browse
oColumn := FWBrwColumn():New()
oColumn:SetData( {|| RetCboxBrw("GIK_TPEVEN", GIK->GIK_TPEVEN)} )
oColumn:SetTitle(STR0009)//"Tipo Evento"
oColumn:SetSize(1)
oBrowse:SetColumns({oColumn})

Return oBrowse


//------------------------------------------------------------------------------
/*/{Protheus.doc} RetCboxBrw
Função responsavel pela definição do browse da Amarração de Recurso x Documento
@type Static Function
@author jacomo.fernandes
@since 09/07/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return oBrowse, retorna o objeto de browse
/*/
//------------------------------------------------------------------------------
Static Function RetCboxBrw(cField,uVal)
Local uRet  := uVal

Do Case
    Case cField == "GIK_TPEVEN"
        If uVal == "1"
            uRet    := STR0010//"Cancelamento"
        ElseIf uVal == "2"
            uRet    := STR0011//"Encerramento"
        ElseIf uVal == "3"
            uRet    := STR0012//"Inc. Condutor"
        Endif
EndCase

Return uRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função responsavel pela definição do menu
@type Static Function
@author jacomo.fernandes
@since 12/11/2019
@version 1.0
@return aRotina, retorna as opçães do menu
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {} 

	ADD OPTION aRotina TITLE STR0013		 ACTION 'Ga813EnvUn()' 		OPERATION OP_ALTERAR		ACCESS 0 // 'Enviar'			
	ADD OPTION aRotina TITLE STR0014+' <F5>' ACTION 'GTPA813ATU()' 		OPERATION OP_ALTERAR		ACCESS 0 // 'Atualizar'	
	ADD OPTION aRotina TITLE STR0015		 ACTION 'VIEWDEF.GTPA813' 	OPERATION OP_VISUALIZAR		ACCESS 0 // 'Visualizar'		
    
Return aRotina


//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author jacomo.fernandes
@since 12/11/2019
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= nil
Local oStrGIK	:= FWFormStruct(1,'GIK')
Local bCommit   := {|oMdl| ModelCommit(oMdl) }
Local bActivate := {|oMdl| ModelActivate(oMdl) }

SetModelStruct(oStrGIK)

oModel := MPFormModel():New('GTPA813', /*bPreValidacao*/, /*bPosValid*/, bCommit, /*bCancel*/ )

oModel:AddFields('GIKMASTER',/*cOwner*/,oStrGIK,/*bPre*/,/*bPos*/,/*bLoad*/)

oModel:SetDescription(STR0001)//'Cadastro de Eventos'

oModel:GetModel('GIKMASTER'):SetDescription(STR0001)	//'Cadastro de Eventos' 

oModel:SetPrimaryKey({''})

oModel:SetActivate(bActivate)

Return oModel

//------------------------------------------------------------------------------
/* /{Protheus.doc} ModelActivate()
CRIADO SOMENTE PARA TER ALTERAÇÃO NO MODELO PRINCIPAL
@type Function
@author 
@since 13/11/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
/*/
//------------------------------------------------------------------------------
Static Function ModelActivate(oModel)
Local oMdlGIK   := oModel:GetModel('GIKMASTER')

If oModel:GetOperation() == MODEL_OPERATION_INSERT
	oMdlGIK:SetValue('GIK_USUINC',AllTrim( RetCodUsr() ))
Endif

Return .T.
//------------------------------------------------------------------------------
/* /{Protheus.doc} SetModelStruct()

@type Function
@author 
@since 13/11/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStrGIK)

oStrGIK:SetProperty("GIK_CODIGO",MODEL_FIELD_INIT, {|| GI9->GI9_CODIGO})
oStrGIK:SetProperty("GIK_CHAVE" ,MODEL_FIELD_INIT, {|| GI9->GI9_CHVMDF})
oStrGIK:SetProperty("GIK_STATUS",MODEL_FIELD_INIT, {|| '0'})//"Não Enviado
oStrGIK:SetProperty("GIK_DTENV" ,MODEL_FIELD_INIT, {|| dDataBase })
oStrGIK:SetProperty("GIK_SEQUEN",MODEL_FIELD_INIT, {|oMdl| GetNextSeq(oMdl)})

oStrGIK:SetProperty("GIK_STATUS",MODEL_FIELD_VALUES, RetCboxFld('GIK_STATUS'))
oStrGIK:SetProperty("GIK_TPEVEN",MODEL_FIELD_VALUES, RetCboxFld('GIK_TPEVEN'))

Return 


//------------------------------------------------------------------------------
/* /{Protheus.doc} RetCboxFld

@type Static Function
@author jacomo.fernandes
@since 11/11/2019
@version 1.0
@param cField, character, (Descrição do parâmetro)
@return aRet, return_description
/*/
//------------------------------------------------------------------------------
Static Function RetCboxFld(cField)
Local aRet  := {}
Do Case
	Case cField == "GIK_STATUS"
		aAdd(aRet,"0="+STR0002 )//"Não Enviado"       				
		aAdd(aRet,"1="+STR0003 )//"Enviado ao TSS"					
		aAdd(aRet,"2="+STR0004 )//"Assinado no TSS"  				
		aAdd(aRet,"3="+STR0005 )//"Falha na Transmissão TSS"      
		aAdd(aRet,"4="+STR0006 )//"Transmitido"         			
		aAdd(aRet,"5="+STR0007 )//"Com erro no Sefaz"        		
		aAdd(aRet,"6="+STR0008 )//"Registrado e vinculado ao MDFe"

	Case cField == "GIK_TPEVEN"
		aAdd(aRet,"1="+STR0010	)//"Cancelamento"
		aAdd(aRet,"2="+STR0011	)//"Encerramento"
		aAdd(aRet,"3="+STR0012	)//"Inc. Condutor"
EndCase

Return aRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} GetNextSeq()

@type Function
@author 
@since 13/11/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
/*/
//------------------------------------------------------------------------------
Static Function GetNextSeq(oMdl)
Local cRet      := ""
Local cAliasTmp := GetNextAlias()
Local cCodigo   := oMdl:GetValue('GIK_CODIGO')
Local cTpEvent  := oMdl:GetValue('GIK_TPEVEN')

BeginSql Alias cAliasTmp
    Select 
        IsNull(Max(cast(GIK_SEQUEN as int)),0) AS MAX
    From %Table:GIK% GIK
    Where
        GIK.GIK_FILIAL = %xFilial:GIK%
        AND GIK.GIK_CODIGO = %Exp:cCodigo%
        AND GIK.GIK_TPEVEN = %Exp:cTpEvent%
        AND GIK.%NotDel%
EndSql

cRet := StrZero((cAliasTmp)->MAX + 1, TamSx3("GIK_SEQUEN")[1])

(cAliasTmp)->(DbCloseArea())


Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author jacomo.fernandes
@since 12/11/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FwLoadModel('GTPA813')
Local oStrGIK	:= FWFormStruct(2, 'GIK')

SetViewStruct(oStrGIK)

oView:SetModel(oModel)

oView:AddField('VIEW_GIK' ,oStrGIK,'GIKMASTER')

oView:CreateHorizontalBox('TELA', 100)

oView:SetOwnerView('VIEW_GIK','TELA')

oView:SetDescription(STR0001) //'Cadastro de Eventos'

Return oView

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetViewStruct

@type Static Function
@author jacomo.fernandes
@since 21/11/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
/*/
//------------------------------------------------------------------------------
Static Function SetViewStruct(oStrGIK)
If ValType(oStrGIK) == "O"
	oStrGIK:SetProperty("GIK_STATUS",MVC_VIEW_COMBOBOX, RetCboxFld('GIK_STATUS'))
	oStrGIK:SetProperty("GIK_TPEVEN",MVC_VIEW_COMBOBOX, RetCboxFld('GIK_TPEVEN'))
Endif
Return 


//------------------------------------------------------------------------------
/* /{Protheus.doc} ModelCommit(oModel)

@type Function
@author 
@since 13/11/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
/*/
//------------------------------------------------------------------------------

Static Function ModelCommit(oModel)
Local lRet      := .T.
Local oCfgWs	:= GetReqCfg("58")
Local oResp		:= CriaResp()
Local nTime     := GTPGetRules('RETSTAEVEN', .F., Nil, 1000)

GetXmlEnv(oModel,oCfgWs)

If EnvioRemessa(oCfgWs,oResp) 
	//Realiza a consulta apenas se o registro for diferente de inclusão de condutor, devido a rotina realizar por lote
	If oModel:GetModel("GIKMASTER"):GetValue('GIK_TPEVEN') <> '3'
		Sleep(nTime)
		ConsultaEvento(oCfgWs,oResp)
	Endif
	
Endif

If GravaDados(oModel,oResp)
	FwFormCommit(oModel)
	If oModel:GetModel("GIKMASTER"):GetValue('GIK_TPEVEN') == '2'//Encerramento
		GI9->(RecLock('GI9',.F.))
		GI9->GI9_CODENC := oModel:GetModel("GIKMASTER"):GetValue('GI6_CODIGO') //Codigo da Agencia que Encerrou
		GI9->(MsUnlock('GI9',.F.))
	Endif
Else
	lRet	:= .F.	
Endif

GtpDestroy(oCfgWs)
GtpDestroy(oResp)

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} GetReqCfg

@type Static Function
@author jacomo.fernandes
@since 19/11/2019
@version 1.0
@param cModelo, character, (Descrição do parâmetro)
@return oCfgWs, return_description
/*/
//------------------------------------------------------------------------------
Static Function GetReqCfg(cModelo)
Local oCfgWs		:= JsonObject():new()
Local cError    	:= ""
Local cEntidade		:= getCfgEntidade(@cError)
Local cUrl			:= AllTrim(GetNewPar("MV_SPEDURL","http://")) +"/NFeSBRA.apw"
Local cAmbiente		:= Left(getCfgAmbiente(@cError), 1)
Local cVersao		:= getCfgVersao(@cError, cEntidade, cModelo)
Local cModalidade	:= getCfgModalidade(@cError, cEntidade, cModelo)


oCfgWs["userToken"	] := "TOTVS"
oCfgWs["entidade" 	] := cEntidade
oCfgWs["url" 		] := cUrl
oCfgWs["modelo" 	] := cModelo
oCfgWs["ambiente" 	] := cAmbiente
oCfgWs["versao" 	] := cVersao
oCfgWs["modalidade"	] := cModalidade
oCfgWs["codigo"		] := ""
oCfgWs["evento"		] := ""

Return oCfgWs

//------------------------------------------------------------------------------
/* /{Protheus.doc} CriaResp

@type Static Function
@author jacomo.fernandes
@since 21/11/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return oResp, return_description
/*/
//------------------------------------------------------------------------------
Static Function CriaResp()
Local oResp := JsonObject():new()

oResp["status"]			:= "0"		
oResp["id"]				:= ""		
oResp["xmlRet"]			:= ""		
oResp["statusTSS"]		:= ""
oResp["motivo"]			:= ""		
oResp["protocolo"]		:= ""		
oResp["dataRetorno"]	:= Stod('')
oResp["xmlEnvio"]		:= ""

Return oResp
//------------------------------------------------------------------------------
/* /{Protheus.doc} EnvioRemessa

@type Static Function
@author jacomo.fernandes
@since 19/11/2019
@version 1.0
@param oCfgWs, object, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function EnvioRemessa(oCfgWs,oResp)
Local lRet		:= .T.
Local oWs       := WsNFeSBra():New()

oWs:cUserToken	:= oCfgWs["userToken"]
oWs:cID_ENT		:= oCfgWs["entidade"]
oWS:_URL		:= oCfgWs["url"]
oWS:cModelo     := oCfgWs["modelo"]
oWs:cXML_LOTE	:= oCfgWs["xmlEnvio"]

oResp["xmlEnvio"]		:= oCfgWs["xmlEnvio"]

If oWs:RemessaEvento()
	lRet	:= .T.
	oResp["id"]		:= oWS:oWsRemessaEventoResult:cString[1]
Else
	lRet	:= .F.
	oResp["motivo"] := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
	oResp["status"]	:= "3"
Endif

oWS:Reset()
GtpDestroy(oWs)

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} ConsultaEvento

@type Static Function
@author jacomo.fernandes
@since 19/11/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
/*/
//------------------------------------------------------------------------------
Static Function ConsultaEvento(oCfgWs,oResp)
Local oWS		:= WSNFeSBRA():New()
Local aRetEv	:= nil

oWS:cUSERTOKEN	:= oCfgWs["userToken"]
oWS:cID_ENT		:= oCfgWs["entidade"]
oWS:_URL		:= oCfgWs["url"]
oWS:cID_EVENTO	:= oResp["id"]

If oWS:NFERETORNAEVENTO()
	aRetEv	:= oWS:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento
	oResp["xmlRet"]		:= aRetEv[1]:cXml_Ret
	oResp["statusTSS"]	:= cValToChar(aRetEv[1]:ncStat)
	oResp["motivo"]		:= aRetEv[1]:cxMotivo
	oResp["protocolo"]	:= cValToChar(aRetEv[1]:nProt)
	oResp["status"]		:= cValToChar(aRetEv[1]:nStatus)
	oResp["dataRetorno"]:= dDataBase
Else
	oResp["motivo"] 	:= IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
	oResp["status"]		:= "3"
Endif

oWS:Reset()

GtpDestroy(oWs)

IF oResp["status"] == '6' .and. oCfgWs["evento"] $ '1/2'
	//Atualiza Status do MDFe
	AtualizaMDF(oCfgWs["codigo"],oCfgWs["evento"])
Endif

Return 


//------------------------------------------------------------------------------
/* /{Protheus.doc} GravaDados

@type Static Function
@author jacomo.fernandes
@since 21/11/2019
@version 1.0
@param oModel, object, (Descrição do parâmetro)
@return lRet, retorno Lógico
/*/
//------------------------------------------------------------------------------
Static Function GravaDados(oModel,oResp,lModel)
Local lRet		:= .T.
Local oMdlGIK	:= Nil
Default lModel	:= .T.

If lModel
	oMdlGIK	:= oModel:GetModel("GIKMASTER")

	lRet := lRet .and. oMdlGIK:SetValue('GIK_STATUS'	,oResp["status"]		)
	lRet := lRet .and. oMdlGIK:SetValue('GIK_ID'		,oResp["id"]			)
	lRet := lRet .and. oMdlGIK:SetValue('GIK_XMLRET'	,oResp["xmlRet"]		)
	lRet := lRet .and. oMdlGIK:SetValue('GIK_CODREF'	,oResp["statusTSS"]		)
	lRet := lRet .and. oMdlGIK:SetValue('GIK_MOTIVO'	,oResp["motivo"]		)
	lRet := lRet .and. oMdlGIK:SetValue('GIK_PROTOC'	,oResp["protocolo"]		)
	lRet := lRet .and. oMdlGIK:SetValue('GIK_DTAUT'		,oResp["dataRetorno"]	)
	lRet := lRet .and. oMdlGIK:SetValue('GIK_XMLENV'	,oResp["xmlEnvio"]		)
else
	GIK->(RecLock('GIK',.F.))
	GIK->GIK_STATUS	:= oResp["status"]		
	GIK->GIK_ID		:= oResp["id"]			
	GIK->GIK_XMLRET	:= oResp["xmlRet"]		
	GIK->GIK_CODREF	:= oResp["statusTSS"]		
	GIK->GIK_MOTIVO	:= oResp["motivo"]		
	GIK->GIK_PROTOC	:= oResp["protocolo"]		
	GIK->GIK_DTAUT	:= oResp["dataRetorno"]	
	GIK->GIK_XMLENV	:= oResp["xmlEnvio"]		
	GIK->(MsUnLock())
Endif

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} GetXmlEnv(oModel,cIdEnt)

@type Function
@author 
@since 13/11/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
/*/
//------------------------------------------------------------------------------
Static Function GetXmlEnv(oModel,oCfgWs)
Local oMdlGIK   := oModel:GetModel("GIKMASTER")
Local cVersao   := oCfgWs["versao"]
Local cXml      := ""
Local cCodEvent := ""
Local cXmlAux   := ""

If oMdlGIK:GetValue('GIK_TPEVEN') == "1" //Cancelamento 
    cCodEvent   := "110111"
	cXmlAux     += 	"<xJust>"+oMdlGIK:GetValue('GI9_OBSERV')+"</xJust>"
	
ElseIf oMdlGIK:GetValue('GIK_TPEVEN') == "2" //Encerramento
    cCodEvent   := "110112"
    cXmlAux     += 	"<dtEnc>"+SubStr(FWTimeStamp(5, oMdlGIK:GetValue("GI9_EMISSA")),1,10)  +"</dtEnc>"
    cXmlAux     += 	"<cUF>"+oMdlGIK:GetValue("GI1_UF")+"</cUF>
    cXmlAux     += 	"<cMun>"+oMdlGIK:GetValue("GI1_CDMUNI")+"</cMun>

ElseIf oMdlGIK:GetValue('GIK_TPEVEN') == "3" //Inclusão de Condutor
    cCodEvent   := "110114"
    cXmlAux     += 	"<nomecondutor>"+NoAcentoCte(oMdlGIK:GetValue('GYG_NOME')) +"</nomecondutor>"
    cXmlAux     += 	"<cpfcondutor>"+NoAcentoCte(oMdlGIK:GetValue('GYG_CPF'))+"</cpfcondutor>
Endif
    
cXml += "<envEvento>"
cXml += 	"<eventos>"
cXml +=         '<detEvento versaoEvento="' + cVersao  + '">'
cXml +=             "<tpEvento>"+cCodEvent+"</tpEvento>"
cXml +=             "<chnfe>"+oMdlGIK:GetValue('GIK_CHAVE')+"</chnfe>"
//cXml += 	        "<ambiente>"+cAmbiente+"</ambiente>"
cXml +=             cXmlAux
cXml +=         "</detEvento>"
cXml += 	"</eventos>"
cXml += "</envEvento>"

oCfgWs["xmlEnvio"	] := cXml
oCfgWs["codigo"		] := oMdlGIK:GetValue('GIK_CODIGO')
oCfgWs["evento"		] := oMdlGIK:GetValue('GIK_TPEVEN')
	
Return


//------------------------------------------------------------------------------
/* /{Protheus.doc} Ga813ConUn

@type Function
@author jacomo.fernandes
@since 21/11/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
/*/
//------------------------------------------------------------------------------
Function Ga813ConUn()
Local oCfgWs	:= nil
Local oResp		:= nil
CursorWait()
If !Empty(GIK->GIK_ID)
	
	oCfgWs				:= GetReqCfg("58")
	oCfgWs["codigo"		] := GIK->GIK_CODIGO
	oCfgWs["evento"		] := GIK->GIK_TPEVEN
	oResp				:= CriaResp()
	oResp["id"]			:= GIK->GIK_ID
	oResp["xmlEnvio"]	:= GIK->GIK_XMLENV

	ConsultaEvento(oCfgWs,oResp)

	GravaDados(,oResp,.F.)
	
Endif
CursorArrow()
Return 

//------------------------------------------------------------------------------
/* /{Protheus.doc} Ga813EnvUn

@type Function
@author jacomo.fernandes
@since 21/11/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
/*/
//------------------------------------------------------------------------------
Function Ga813EnvUn()
Local oCfgWs	:= nil
Local oResp		:= nil
CursorWait()
If !Empty(GIK->GIK_XMLENV)
	
	oCfgWs				:= GetReqCfg("58")
	oCfgWs["codigo"		] := GIK->GIK_CODIGO
	oCfgWs["evento"		] := GIK->GIK_TPEVEN
	
	oResp				:= CriaResp()
	oCfgWs["xmlEnvio"]	:= GIK->GIK_XMLENV

	If EnvioRemessa(oCfgWs,oResp) 
		Sleep(5000)
		ConsultaEvento(oCfgWs,oResp)
	Endif

	GravaDados(,oResp,.F.)
	
Endif
CursorArrow()
Return


//------------------------------------------------------------------------------
/* /{Protheus.doc} GTPA813ATU

@type Function
@author jacomo.fernandes
@since 21/11/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
/*/
//------------------------------------------------------------------------------
Function GTPA813ATU()
Local cAliasTmp	:= GetNextAlias()


BeginSql Alias cAliasTmp
	Select GIK.R_E_C_N_O_ AS GIKREC
	From %Table:GIK% GIK
	Where
		GIK.GIK_FILIAL = %xFilial:GIK%
		and GIK.GIK_STATUS NOT IN ('0','3','6')
		AND GIK.%NotDel%
EndSql

DbSelectArea("GIK")

While (cAliasTmp)->(!Eof())
	GIK->(DbGoTo( ((cAliasTmp)->GIKREC) ))
	Ga813ConUn()
	(cAliasTmp)->(DbSkip())
End


(cAliasTmp)->(DbCloseArea())

Return


//------------------------------------------------------------------------------
/* /{Protheus.doc} AtualizaMDF

@type Static Function
@author jacomo.fernandes
@since 27/11/2019
@version 1.0
@param , character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function AtualizaMDF(cCodigo,cEvento)
Local cTmpAlias	:= GetNextAlias()


BeginSql Alias cTmpAlias
	Select 
		G99.G99_CODIGO,
		GI9.R_E_C_N_O_ AS GI9REC
	From %Table:GI9% GI9
		Inner Join %Table:GIF% GIF on
			GIF.GIF_FILIAL = GI9.GI9_FILIAL
			AND GIF.GIF_CODIGO = GI9.GI9_CODIGO
			AND GIF.%NotDel%
		Left Join %Table:G99% G99 on
			G99.G99_FILIAL = GI9.GI9_FILIAL
			AND G99.G99_CODIGO = GIF.GIF_CODG99
			AND G99.G99_STAENC IN ('1','2')
			AND G99.%NotDel%
	Where
		GI9.GI9_FILIAL = %xFilial:GI9%
		AND GI9_CODIGO = %Exp:cCodigo%
		AND GI9.%NotDel%
EndSql


While (cTmpAlias)->(!EoF())
	GI9->(DbGoTo( (cTmpAlias)->GI9REC) )
    
    If !Empty((cTmpAlias)->G99_CODIGO)
	    Gtp801AtuSta((cTmpAlias)->G99_CODIGO,cEvento,GI9->GI9_VIAGEM,GI9->GI9_CODEMI,GI9->GI9_CODENC)
    Endif
    
	GI9->(RecLock('GI9',.F.))
	
	If cEvento == "1" //Cancelamento
		GI9->GI9_STATUS := "2"
	ElseIf  cEvento == "2" //Encerramento
		GI9->GI9_STATUS := "3"
	Endif

	GI9->(MsUnlock())


	(cTmpAlias)->(DbSkip())
End
(cTmpAlias)->(DbCloseArea())

Return 


