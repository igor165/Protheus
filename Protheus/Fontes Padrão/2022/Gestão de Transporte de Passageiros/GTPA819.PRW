#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA819.CH"

/*/{Protheus.doc} GTPA819
//TODO Descrição auto-gerada.
@author flavio.martins
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function GTPA819()
Local oBrowse := FwMBrowse():New()

Private lIsLote := .F.
Private lGeraNF := .F.

oBrowse:SetAlias('GIS')
oBrowse:SetDescription(STR0001) //'Faturamento de Contratos - Encomendas'
oBrowse:DisableDetails()

oBrowse:AddLegend('GIS_STATUS == "1"',"YELLOW"	,STR0002) //'Em Aberto'    
oBrowse:AddLegend('GIS_STATUS == "2"',"GREEN"	,STR0003) //'Faturado'   
oBrowse:AddLegend('GIS_STATUS == "3"',"RED"		,STR0004) //'Cancelado'    
oBrowse:AddLegend('GIS_STATUS == "4"',"BLACK"   ,STR0005) //'Devolvido'   

oBrowse:Activate()

Return oBrowse

/*/{Protheus.doc} MenuDef
//TODO Descrição auto-gerada.
@author flavio.martins
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0006	ACTION "VIEWDEF.GTPA819"	OPERATION 2 ACCESS 0 // Visualizar 
ADD OPTION aRotina TITLE STR0007	ACTION "VIEWDEF.GTPA819"	OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE STR0008	ACTION "G819VldAct(4)"		OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE STR0009	ACTION "G819VldAct(5)"		OPERATION 5 ACCESS 0 // Excluir
ADD OPTION aRotina TITLE STR0019	ACTION "G819VldNF()"		OPERATION 2 ACCESS 0 // Faturar
ADD OPTION aRotina TITLE STR0020	ACTION "G819VldCan()"		OPERATION 2 ACCESS 0 // Cancelar faturamento
ADD OPTION aRotina TITLE STR0038	ACTION "G819Perg()"			OPERATION 3 ACCESS 0 // Faturamento em Lote

Return aRotina

/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author flavio.martins
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ModelDef()
Local oModel    := nil
Local oStruGIS  := FwFormStruct(1, 'GIS')
Local oStruGIT  := FwFormStruct(1, 'GIT')
Local oStruGIW  := FwFormStruct(1, 'GIW')
Local bPosValid	:= {|oModel| G819PosVld(oModel)}
Local bCommit	:= {|oModel| G819Commit(oModel)}

SetMdlStru(oStruGIS, oStruGIT, oStruGIW)

oModel := MPFormModel():New("GTPA819",/*bPreVld*/, bPosValid, /*bCommit*/, /*bCancel*/ )

oModel:SetDescription(STR0001) //'Faturamento de Contratos - Encomendas'
oModel:AddFields("GISMASTER",,oStruGIS)

oModel:AddGrid("GITDETAIL", "GISMASTER", oStruGIT, ,/*bPosValid*/ ,,,/*bLoad*/ )
oModel:SetRelation("GITDETAIL", {{"GIT_FILIAL", "xFilial('GIS')"} , { "GIT_CODFAT", "GIS_CODIGO" } } , GIT->(IndexKey(1)))

oModel:AddGrid("GIWDETAIL", "GISMASTER", oStruGIW, ,/*bPosValid*/ ,,,/*bLoad*/ )
oModel:SetRelation("GIWDETAIL", {{"GIW_FILIAL", "xFilial('GIS')"} , { "GIW_CODFAT", "GIS_CODIGO" } } , GIW->(IndexKey(1)))
oModel:GetModel('GIWDETAIL'):SetOptional(.T.)

oModel:GetModel("GITDETAIL"):SetMaxLine(999)
oModel:GetModel("GIWDETAIL"):SetMaxLine(999)

oModel:SetCommit(bCommit)

Return oModel

/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author flavio.martins
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewDef()
Local oView     := nil
Local oModel    := FwLoadModel('GTPA819')
Local oStruGIS  := FwFormStruct(2, 'GIS')
Local oStruGIT  := FwFormStruct(2, 'GIT',)
Local oStruGIW  := FwFormStruct(2, 'GIW',)

oView := FwFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_GIS", oStruGIS, 'GISMASTER')
oView:AddGrid("VIEW_GIT", oStruGIT, 'GITDETAIL') 
oView:AddGrid("VIEW_GIW", oStruGIW, 'GIWDETAIL') 

oView:CreateHorizontalBox("HEADER", 40)
oView:CreateHorizontalBox("GRIDGIT", 35)
oView:CreateHorizontalBox("GRIDGIW", 25)

oView:SetOwnerView("VIEW_GIS","HEADER")
oView:SetOwnerView("VIEW_GIT","GRIDGIT")
oView:SetOwnerView("VIEW_GIW","GRIDGIW")

oView:addIncrementField("VIEW_GIT", "GIT_ITEM")

SetViewStru(oStruGIS, oStruGIT, oStruGIW)

oView:EnableTitleView("VIEW_GIS", STR0010) //"Dados do Faturamento"
oView:EnableTitleView("VIEW_GIT", STR0011) //"Encomendas do Cliente"
oView:EnableTitleView("VIEW_GIW", STR0021) //"Titulos do Faturamento" 

oView:AddUserButton(STR0012, "", {|| GA819Pesq(oModel)},,VK_F5) //"Pesquisar"
//oView:AddUserButton(STR0013, "", {|| G819VldFat()},,VK_F8) //"Faturar"

Return oView

/*/{Protheus.doc} SetMdlStru
//TODO Descrição auto-gerada.
@author flavio.martins
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oStruGIS, object, descricao
@param oStruGIT, object, descricao
@type function
/*/
Static Function SetMdlStru(oStruGIS,oStruGIT,oStruGIW)
Local bTrigger 	:= {|oMdl,cField, uValue| FieldTrig(oMdl,cField, uValue)}
Local bWhen		:= {|oMdl,cField,xVal| FieldWhen(oMdl,cField,xVal)}

If ValType(oStruGIS) == 'O'
	oStruGIS:AddTrigger("GIS_CLIENT", "GIS_CLIENT", {||.T.}, bTrigger)
	oStruGIS:AddTrigger("GIS_LOJA", "GIS_LOJA", {||.T.}, bTrigger)
	oStruGIS:AddTrigger("GIS_CODPRO", "GIS_CODPRO", {||.T.}, bTrigger)

	oStruGIS:SetProperty("GIS_CLIENT", MODEL_FIELD_WHEN, bWhen)
	oStruGIS:SetProperty("GIS_LOJA", MODEL_FIELD_WHEN, bWhen)
	oStruGIS:SetProperty("GIS_CODPRO", MODEL_FIELD_WHEN, bWhen)

	oStruGIS:SetProperty("GIS_SERIE", MODEL_FIELD_INIT, { || GetSerPar()})
	
	oStruGIS:SetProperty("GIS_SERIE", MODEL_FIELD_OBRIGAT,.T.)
Endif

If ValType(oStruGIT) == 'O'
	oStruGIT:AddField("", "", "GIT_MARK", "L", 1, 0,{|| .T.}, {|| .T.},{},.F.,{|| .T.},.F.,.F.,.T.)
	oStruGIT:SetProperty("GIT_DESPRO" , MODEL_FIELD_INIT, { || Posicione('SB1',1,xFilial('SB1')+GIT->GIT_CODPRO,'B1_DESC') })
	oStruGIT:SetProperty("GIT_MARK" , MODEL_FIELD_INIT, { || .T. })
Endif

Return

/*/{Protheus.doc} SetViewStru
//TODO Descrição auto-gerada.
@author flavio.martins
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oStruGIS, object, descricao
@param oStruGIT, object, descricao
@type function
/*/
Static Function SetViewStru(oStruGIS,oStruGIT,oStruGIW)
Local cFields 	:= ''
Local aFields	:= {}
Local nX 		:= 0

cFields := 'GIS_CODIGO|GIS_CLIENT|GIS_LOJA|GIS_NOMCLI|GIS_CODPRO|GIS_DESPRO|GIS_DTINI|GIS_DTFIM|GIS_SERIE|GIS_TOTFAT|'

If GIS->(FieldPos('GIS_PERDES')) > 0 .And. GIS->(FieldPos('GIS_TOTDES')) > 0 .And. GIS->(FieldPos('GIS_TOTLIQ')) > 0
	cFields += 'GIS_PERDES|GIS_TOTDES|GIS_TOTLIQ|'
Endif

cFields += 'GIS_NUMDOC|GIS_DATFAT|GIS_STATUS|GIS_OBSERV'

aFields := StrToKarr(cFields, '|')

If ValType(oStruGIS) == 'O'

	For nX := 1 To Len(aFields)
		oStruGIS:SetProperty(aFields[nX], MVC_VIEW_ORDEM , StrZero(nX, 2))
	Next	

	oStruGIS:SetProperty("GIS_SERIE", MVC_VIEW_LOOKUP, "01")
	
	oStruGIS:SetProperty("GIS_SERIE", MODEL_FIELD_OBRIGAT,.T.)
		
	oStruGIS:RemoveField("GIS_DATINC")
	oStruGIS:RemoveField("GIS_USUINC")
	oStruGIS:RemoveField("GIS_FILORI")
	oStruGIS:RemoveField("GIS_TS")

Endif

If ValType(oStruGIT) == 'O'
	oStruGIT:AddField("GIT_MARK","00","","",{""},"GET","@!",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)
Endif

If ValType(oStruGIW) == 'O'
	oStruGIW:RemoveField("GIW_CODFAT")
	oStruGIW:RemoveField("GIW_CODGQ6")
	oStruGIW:RemoveField("GIW_FILORI")
Endif

Return

/*/{Protheus.doc} FieldTrig
//TODO Descrição auto-gerada.
@author flavio.martins
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oMdl, object, descricao
@param cField, characters, descricao
@param uValue, undefined, descricao
@type function
/*/
Static Function FieldTrig(oMdl,cField, uValue)

If cField == 'GIS_CLIENT' .Or. cField == 'GIS_LOJA'
	oMdl:SetValue('GIS_NOMCLI',Posicione('SA1',1,xFilial('SA1')+oMdl:GetValue('GIS_CLIENT')+oMdl:GetValue('GIS_LOJA'),"A1_NREDUZ" ))
	oMdl:LoadValue('GIS_CODPRO',Posicione('GIL',1,xFilial('GIL')+oMdl:GetValue('GIS_CLIENT')+oMdl:GetValue('GIS_LOJA'),"GIL_PRODUT" ))
	oMdl:LoadValue('GIS_DESPRO',Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('GIS_CODPRO'),"B1_DESC"))

	If GIS->(FieldPos('GIS_PERDES')) > 0 
		oMdl:LoadValue('GIS_PERDES',Posicione('GIL',1,xFilial('GIL')+oMdl:GetValue('GIS_CLIENT')+oMdl:GetValue('GIS_LOJA'),"GIL_PERDES" ))
	Endif

Endif

Return 

/*/{Protheus.doc} FieldWhen
//TODO Descrição auto-gerada.
@author flavio.martins
@since 17/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oMdl, object, descricao
@param cField, characters, descricao
@param xVal, , descricao
@type function
/*/
Static Function FieldWhen(oMdl,cField,xVal)
Local oModel := oMdl:GetModel()
Local lRet := .T.

If cField $ 'GIS_CLIENT|GIS_LOJA|'
	lRet := oModel:GetOperation() == MODEL_OPERATION_INSERT
Endif

If cField = 'GIS_CODPRO'
	lRet := .F.
Endif

Return lRet

/*/{Protheus.doc} G819VldAct
//TODO Descrição auto-gerada.
@author flavio.martins
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}
@param nOpc, numeric, descricao
@type function
/*/
Function G819VldAct(nOpc)
Local lRet := .T.

	If nOpc == 4 .And. GIS->GIS_STATUS <> '1'
		FwAlertWarning(STR0015, STR0014) //"Apenas faturamentos com o status 'Em Aberto' podem ser alterados", "Atenção"
		lRet := .F.
	ElseIf nOpc == 5 .And. GIS->GIS_STATUS <> '1'
		FwAlertWarning(STR0016, STR0014) //"Apenas faturamentos com o status 'Em Aberto' podem ser excluídos", "Atenção"
		lRet := .F.
	Else
		FwExecView(Iif(nOpc == 4,STR0008,STR0009),'VIEWDEF.GTPA819', nOpc, , , , , )  //'Alterar','Excluir'
	Endif
	
Return lRet

/*/{Protheus.doc} G819PosVld
//TODO Descrição auto-gerada.
@author flavio.martins
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function G819PosVld(oModel)
Local lRet		:= .T.
Local oMdlGIS	:= oModel:GetModel('GISMASTER')
Local oMdlGIT	:= oModel:GetModel('GITDETAIL')
Local nX		:= 0
Local nTotFat	:= 0

If oModel:GetOperation() == MODEL_OPERATION_UPDATE .Or. oModel:GetOperation() == MODEL_OPERATION_INSERT

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		oMdlGIS:SetValue('GIS_DATINC', dDataBase)
		oMdlGIS:SetValue('GIS_USUINC', AllTrim(RetCodUsr()))
	Endif
	
	If !(oMdlGIT:SeekLine({{"GIT_MARK",.T.}}))
		oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"PosValid", STR0039, STR0040) //"Nenhuma encomenda selecionada", "Selecione ao menos uma encomenda"
		Return .F.
	Endif
	
	For nX := 1 To oMdlGIT:Length()
	
		oMdlGIT:GoLine(nX)
		
		If (oMdlGIT:GetValue('GIT_MARK'))
		
			GIR->(dbSetOrder(1))  
			If GIR->(MsSeek(xFilial('GIR') + oMdlGIT:GetValue('GIT_CODG99')))			
				RecLock('GIR',.F.)	
					GIR->GIR_CODFAT := oMdlGIT:GetValue('GIT_CODFAT')   
	            GIR->(MsUnLock()) 
	            
	            nTotFat += oMdlGIT:GetValue('GIT_VLFATU') 
			EndIf		
			
		Else
			
			If GIR->(MsSeek(xFilial('GIR') + oMdlGIT:GetValue('GIT_CODG99')))			
				RecLock('GIR',.F.)	
					GIR->GIR_CODFAT := ''   
	            GIR->(MsUnLock()) 
	        Endif
		
			oMdlGIT:DeleteLine()
			
		Endif
	
	Next
	
	oMdlGIS:SetValue('GIS_TOTFAT', nTotFat)

	If GIS->(FieldPos('GIS_PERDES')) > 0 .And. GIS->(FieldPos('GIS_TOTDES')) > 0 .And. GIS->(FieldPos('GIS_TOTLIQ')) > 0
		oMdlGIS:SetValue('GIS_TOTDES', nTotFat * (oMdlGIS:GetValue('GIS_PERDES') / 100))
		oMdlGIS:SetValue('GIS_TOTLIQ', nTotFat - oMdlGIS:GetValue('GIS_TOTDES'))
	Endif
	
ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE

	For nX := 1 To oMdlGIT:Length()
	
		oMdlGIT:GoLine(nX)
	
		GIR->(dbSetOrder(1))  
		If GIR->(MsSeek(xFilial('GIR') + oMdlGIT:GetValue('GIT_CODG99')))			
			RecLock('GIR',.F.)	
				GIR->GIR_CODFAT := ''   
            GIR->(MsUnLock()) 
		EndIf		
	
	Next

Endif

Return lRet

/*/{Protheus.doc} GA819Pesq
//TODO Descrição auto-gerada.
@author flavio.martins
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Function GA819Pesq(oModel)
Local cAliasTmp	:= GetNextAlias()
Local oMdlGIS	:= oModel:GetModel('GISMASTER')
Local oMdlGIT	:= oModel:GetModel('GITDETAIL')
Local dDataIni	:= oMdlGIS:GetValue('GIS_DTINI')
Local dDataFim	:= oMdlGIS:GetValue('GIS_DTFIM')
Local cCliente	:= oMdlGIS:GetValue('GIS_CLIENT')
Local cLoja		:= oMdlGIS:GetValue('GIS_LOJA')
Local nItem		:= 0

If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE

	BeginSql Alias cAliasTmp

		SELECT GIR.GIR_VALOR,
		       G99.G99_CODIGO,
		       G99.G99_DTEMIS,
		       G99.G99_CODPRO
		FROM %Table:GIR% GIR
		INNER JOIN %Table:G99% G99 ON G99.G99_FILIAL = %xFilial:G99%
		AND G99.G99_CODIGO = GIR.GIR_CODIGO
		AND G99.%NotDel%
		WHERE GIR.GIR_FILIAL = %xFilial:GIR%
		  AND GIR.GIR_DTPAG BETWEEN %Exp:dDataIni% AND %Exp:dDataFim%
		  AND GIR.GIR_TIPPAG = '3'
		  AND GIR.GIR_CLIPAG = %Exp:cCliente%
		  AND GIR.GIR_LOJPAG = %Exp:cLoja%
		  AND GIR.GIR_CODFAT = ''
		  AND GIR.%NotDel%
	
	EndSql

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		oMdlGIT:ClearData()
	Endif
	
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		nItem := oMdlGIT:Length()
	Endif

	If (cAliasTmp)->(ScopeCount()) == 0
		FwAlertWarning(STR0032, STR0033) //"Não foram encontradas encomendas com estes parâmetros", "Aviso"
		Return
	Endif
	
	(cAliasTmp)->(dbGoTop())
	While !(cAliasTmp)->(Eof())
	
		If !(oMdlGIT:SeekLine({{"GIT_CODG99",(cAliasTmp)->G99_CODIGO}}))
	
			If !(oMdlGIT:IsEmpty())
				oMdlGIT:AddLine()
			Endif
			
			nItem++
						
			oMdlGIT:SetValue('GIT_CODG99', (cAliasTmp)->G99_CODIGO)
			oMdlGIT:SetValue('GIT_ITEM', AllTrim(StrZero(nItem,4)))
			oMdlGIT:SetValue('GIT_DATENC', StoD((cAliasTmp)->G99_DTEMIS))
			oMdlGIT:SetValue('GIT_VLFATU', (cAliasTmp)->GIR_VALOR)
			oMdlGIT:SetValue('GIT_CODFAT', oMdlGIS:GetValue('GIS_CODIGO'))
			oMdlGIT:SetValue('GIT_CODPRO', (cAliasTmp)->G99_CODPRO)
			oMdlGIT:SetValue('GIT_DESPRO', Posicione('SB1',1,xFilial('SB1')+oMdlGIT:GetValue('GIT_CODPRO'),'B1_DESC'))
	
		Endif
		
		(cAliasTmp)->(dbSkip())
		
	End
	
	oMdlGIT:GoLine(1)
	
	(cAliasTmp)->(dbCloseArea())

Endif

Return

/*/{Protheus.doc} G819VldNF
//TODO Descrição auto-gerada.
@author flavio.martins
@since 19/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function G819VldNF()
Local lRet		:= .T.
Local oModel	:= FwLoadModel("GTPA819")
Local cEspecie	:= GTPGetRules('ESPFATCNTR')
Local cMsgErro  := ''
Local cMsgSol   := ''

If Empty(cEspecie) 
	FwAlertWarning(STR0034, STR0014) //"O parâmetro ESPFATCNTR deve estar preenchido para realizar o faturamento", "Atenção"
	Return
Endif

If GIS->GIS_STATUS != '1' 
	FwAlertWarning(STR0022, STR0014) //"Faturamento permitido apenas para registros com o status 'Em Aberto'", "Atenção"
	Return
Else
	oModel:SetOperation(MODEL_OPERATION_VIEW) 
	oModel:Activate()
	FwMsgRun( ,{|| lRet := G819GerNF(oModel, @cMsgErro, @cMsgSol)},, STR0023) //"Gerando faturamento...." 
	oModel:DeActivate()
Endif

If !lIsLote
	If lRet 
		FwAlertSuccess(STR0024, '') //"Faturamento gerado com sucesso"
	Else
    	FwAlertError(cMsgErro, cMsgSol) //'Erro na geração do faturamento','Verifique se o cliente, produto, tipo de saída ou o CFOP estão cadastrados corretamente'
	Endif
Endif

Return

/*/{Protheus.doc} G819VldCan
//TODO Descrição auto-gerada.
@author flavio.martins
@since 18/12/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function G819VldCan()
Local lRet		:= .T.
Local oModel	:= FwLoadModel("GTPA819")
Local cSerDev	:= GTPGetRules('SERDEVCNTR') 

If Empty(cSerDev) 
	FwAlertWarning(STR0035, STR0014) //"O parâmetro SERDEVCNTR deve estar preenchido para realizar o cancelamento", "Atenção"
	Return
Endif

If GIS->GIS_STATUS != '2' 
	FwAlertWarning(STR0027, STR0014) //"Cancelamento válido apenas para registros faturados", "Atenção"
	Return
Else
	oModel:SetOperation(MODEL_OPERATION_VIEW) 
	oModel:Activate()
	FwMsgRun( ,{|| lRet := G819GerCan(oModel)},, STR0028) //"Realizando o cancelamento...." 
	oModel:DeActivate()
Endif

If lRet
	FwAlertSuccess(STR0029, STR0030) //'Faturamento cancelado com sucesso','Ok'
Else
    FwAlertError(STR0031, STR0026) //'Erro no cancelamento do faturamento','Verifique se o cliente, produto, tipo de saída ou o CFOP estão cadastrados corretamente'
Endif

Return

/*/{Protheus.doc} G819GerNF
//TODO Descrição auto-gerada.
@author flavio.martins
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function G819GerNF(oModel, cMsgErro, cMsgSol)
Local lRet          := .T.
Local aDadosCab     := {}
Local aItem         := {}
Local aDadosItem    := {}
Local bFiscalSF2    := nil
Local cNumero       := ""
Local oMdlGIS       := oModel:GetModel('GISMASTER')
Local cSerie        := oMdlGIS:GetValue('GIS_SERIE')
Local cEspecie      := GTPGetRules('ESPFATCNTR')
Local cEstDev       := ""
Local cTipoCli      := ""
Local cSitTrib      := ""
Local cCondPag		:= ""
Local nValorDoc		:= 0
 
//-------------------------------------------------------------------------------
//Criação dos Dados de Cabeçalho
//-------------------------------------------------------------------------------
DbSelectArea( "SB0" )

SA1->(DbSetOrder(1))
SF4->(DbSetOrder(1))
SB1->(DbSetOrder(1))
SBZ->(DbSetOrder(1))
SB0->(DbSetOrder(1))
GIL->(DbSetOrder(1))

If GIS->(FieldPos('GIS_TOTLIQ')) > 0
	nValorDoc := oMdlGIS:GetValue('GIS_TOTLIQ')
Else
	nValorDoc := oMdlGIS:GetValue('GIS_TOTFAT')
Endif

aAdd(aDadosCab,{"F2_FILIAL"     ,xFilial("SF2")                 })
aAdd(aDadosCab,{"F2_TIPO"       ,"N"                            })
aAdd(aDadosCab,{"F2_SERIE"      ,cSerie                         })
aAdd(aDadosCab,{"F2_EMISSAO"    , dDataBase /*oMdlGIS:GetValue('GIS_DATFAT')*/ })

SA1->(DbSeek(xFilial('SA1')+oMdlGIS:GetValue('GIS_CLIENT')+oMdlGIS:GetValue('GIS_LOJA')))
GIL->(DbSeek(xFilial('GIL')+oMdlGIS:GetValue('GIS_CLIENT')+oMdlGIS:GetValue('GIS_LOJA')))

aAdd(aDadosCab,{"F2_CLIENTE"    ,SA1->A1_COD })
aAdd(aDadosCab,{"F2_LOJA"       ,SA1->A1_LOJA })

cEstDev     := SA1->A1_EST
cTipoCli    := SA1->A1_TIPO
cCondPag	:= GIL->GIL_CONDPG

aAdd(aDadosCab,{"F2_TIPOCLI"    ,cTipoCli})
aAdd(aDadosCab,{"F2_ESPECIE"    ,cEspecie})
aAdd(aDadosCab,{"F2_COND"       ,cCondPag})
aAdd(aDadosCab,{"F2_DTDIGIT"    ,dDataBase /*oMdlGIS:GetValue('GIS_DATFAT')*/})
aAdd(aDadosCab,{"F2_EST"        ,cEstDev})
aAdd(aDadosCab,{"F2_VALMERC"    ,nValorDoc})
aAdd(aDadosCab,{"F2_MOEDA"      ,CriaVar( 'F2_MOEDA' )})

//-------------------------------------------------------------------------------
//Criação dos Dados de Item
//-------------------------------------------------------------------------------
aAdd(aItem,{"D2_FILIAL"     ,xFilial("SF2")     })
aAdd(aItem,{"D2_ITEM"       ,StrZero(1,TamSx3("D2_ITEM")[1])     })
aAdd(aItem,{"D2_SERIE"      ,cSerie             })
aAdd(aItem,{"D2_CLIENTE"    ,SA1->A1_COD        })
aAdd(aItem,{"D2_LOJA"       ,SA1->A1_LOJA       })
aAdd(aItem,{"D2_EMISSAO"    , dDataBase /*oMdlGIS:GetValue('GIS_DATFAT')*/ })
aAdd(aItem,{"D2_TIPO"       ,"N"                })
aAdd(aItem,{"D2_UM"         ,"UN"               })
aAdd(aItem,{"D2_QUANT"      ,1                  })
aAdd(aItem,{"D2_PRUNIT"     ,nValorDoc  	    })
aAdd(aItem,{"D2_PRCVEN"     ,nValorDoc  	    })
aAdd(aItem,{"D2_TOTAL"      ,nValorDoc   		})
aAdd(aItem,{"D2_EST"        ,cEstDev            })
aAdd(aItem,{"D2_ESPECIE"    ,cEspecie	        })
If SB1->(DbSeek(xFilial('SB1')+oMdlGIS:GetValue('GIS_CODPRO') ))
            
    aAdd(aItem,{"D2_LOCAL"      ,SB1->B1_LOCPAD     })
    aAdd(aItem,{"D2_COD"        ,SB1->B1_COD        })
    aAdd(aItem,{"D2_TP"         ,SB1->B1_TIPO       })
    aAdd(aItem,{"D2_CONTA"      ,SB1->B1_CONTA      })

    If !Empty( SB1->B1_CODISS )
        aAdd(aItem,{"D2_CODISS"     ,SB1->B1_CODISS     })
    ElseIf SBZ->( dbSeek( xFilial("SBZ") + oMdlGIS:GetValue('GIS_CODPRO') ) ) .And. !Empty( SBZ->BZ_CODISS )
        aAdd(aItem,{"D2_CODISS"     ,SBZ->BZ_CODISS     })
    EndIf

	If !Empty(SB1->B1_TS)
		aAdd(aItem,{"D2_TES"        ,SB1->B1_TS		  })
		aAdd(aItem,{"D2_CF"         ,Posicione('SF4',1,xFilial('SF4')+SB1->B1_TS,'F4_ESTOQUE')  })
		aAdd(aItem,{"D2_ESTOQUE"    ,Posicione('SF4',1,xFilial('SF4')+SB1->B1_TS,'F4_CF')	    })
	Endif

    SB0->(DbSeek(xFilial("SB0")+SB1->B1_COD))
    
    //Executa funções padrões do LOJA para retornar a situação tributária a ser gravada na SD2
    Lj7Strib(@cSitTrib ) 
    Lj7AjustSt(@cSitTrib)

    aAdd(aItem,{"D2_SITTRIB"    ,cSitTrib           })

Endif

aAdd(aDadosItem,aItem)

bFiscalSF2 := {||;
                    MaFisAlt( "NF_ESPECIE"      , cEspecie     , , , , , , .F./*lRecal*/   ),;
                    MaFisAlt( "NF_PNF_TPCLIFOR" , cTipoCli );
                }

cNumero := GTPxNFS(cSerie,aDadosCab,aDadosItem,/*bFiscalSF2*/, , 'GTPA819')

If !Empty(cNumero)

	oModel:DeActivate()
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	oModel:Activate()
	
	oMdlGIS:SetValue('GIS_NUMDOC', cNumero)
	oMdlGIS:SetValue('GIS_STATUS', '2')
	oMdlGIS:SetValue('GIS_DATFAT', dDataBase)
	oMdlGIS:SetValue('GIS_FILORI', cFilAnt)
	
	lRet := FwFormCommit(oModel)
	
Else
    lRet := .F.
	cMsgErro := STR0025 // 'Erro na geração do faturamento'
	cMsgSol  := STR0026 // 'Verifique se o cliente, produto, tipo de saída ou o CFOP estão cadastrados corretamente'
Endif

If lRet
	GrvTitGIW(oModel) //Grava os títulos financeiros gerados na tabela GIW
Endif

Return lRet

/*/{Protheus.doc} G819GerCan
//TODO Descrição auto-gerada.
@author flavio.martins
@since 18/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function G819GerCan(oModel)
Local oMdlGIS	:= oModel:GetModel('GISMASTER')
Local oMdlGIT	:= oModel:GetModel('GITDETAIL')
Local lRet 		:= .T.
Local cSerieDV	:= GTPGetRules('SERDEVCNTR') 
Local nX        := 0	
Local aCab		:= {}
Local aItens	:= {}
Local aItem		:= {}
Local aRegSD2   := {}
Local aRegSE1   := {}
Local aRegSE2   := {}
Local cNota 	:=  NxtSX5Nota( cSerieDV ) //SEQUENCIAL DA NOTA FISCAL
Local cChvSF2	:= ""
Local cCfop		:= ""
Local cStatus	:= ""
Local cMsgErro	:= ""
Local aLog		:= {}

Private lAutoErrNoFile := .T.
Private lMsErroAuto	:= .F.

cChvSF2	:= oMdlGIS:GetValue('GIS_FILORI')+oMdlGIS:GetValue('GIS_NUMDOC')+;
		   oMdlGIS:GetValue('GIS_SERIE')+oMdlGIS:GetValue('GIS_CLIENT')+;
		   oMdlGIS:GetValue('GIS_LOJA')

SF2->(DbSetOrder(1))

If SF2->(dbSeek(cChvSF2))
    // Exclui a nota
    dDtdigit := IIf(!Empty(SF2->F2_DTDIGIT),SF2->F2_DTDIGIT,SF2->F2_EMISSAO)
    If dDtDigit >= MVUlmes()
        If MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
            SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,.F.,.F.,.T.,.F.))
            cStatus := '3'
        Else
			
    		//Variaveis do Cabecalho da Nota
    		aAdd(aCab,{"F1_TIPO"     	,'D'      			,NIL})
			aAdd(aCab,{"F1_FORMUL"    	,"S"  				,NIL})
			aAdd(aCab,{"F1_DOC"   	 	,cNota  			,NIL})
			aAdd(aCab,{"F1_SERIE"    	,cSerieDV  			,NIL})
			aAdd(aCab,{"F1_EMISSAO"    	,dDataBase			,NIL})
			aAdd(aCab,{"F1_FORNECE"    	,SF2->F2_CLIENTE	,NIL})
			aAdd(aCab,{"F1_LOJA"       	,SF2->F2_LOJA		,NIL})
			aAdd(aCab,{"F1_ESPECIE"    	,SF2->F2_ESPECIE	,NIL})
			
			dbSelectArea('SD2')
			SD2->(dbSetOrder(3)) // D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM, R_E_C_N_O_, D_E_L_E_T_
			
			If SD2->(dbSeek(cChvSF2))
				
				While SD2->(!EOF()) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
				
					cCfop := Posicione('SF4',1,xFilial('SF4')+SD2->D2_TES,'F4_CF')
			 		
					aItem := {}
					aAdd(aItem,{"D1_ITEM"  		,StrZero(Val(SD2->D2_ITEM),TamSx3('D1_ITEM')[1])			,NIL})
					aAdd(aItem,{"D1_COD"   		,AllTrim(SD2->D2_COD)										,NIL})
					aAdd(aItem,{"D1_UM"   		,SD2->D2_UM													,NIL})
					aAdd(aItem,{"D1_QUANT"   	,SD2->D2_QUANT 												,NIL})
					aAdd(aItem,{"D1_VUNIT"  	,SD2->D2_PRCVEN												,NIL})
					aAdd(aItem,{"D1_TOTAL"  	,SD2->D2_TOTAL												,NIL})
					aAdd(aItem,{"D1_TES"  		,Posicione('SF4',1,xFilial('SF4')+SD2->D2_TES,'F4_TESDV')	,NIL})
					aAdd(aItem,{"D1_FORNECE" 	,SF2->F2_CLIENTE											,NIL})
					aAdd(aItem,{"D1_LOJA"  		,SF2->F2_LOJA												,NIL})
					aAdd(aItem,{"D1_LOCAL"  	,SD2->D2_LOCAL												,NIL})
					aAdd(aItem,{"D1_EMISSAO"	,dDataBase													,NIL})
					aAdd(aItem,{"D1_DTDIGIT" 	,dDataBase													,NIL})
					aAdd(aItem,{"D1_GRUPO"   	,SD2->D2_GRUPO												,NIL})
					aAdd(aItem,{"D1_TIPO"  		,"D"														,NIL})
					aAdd(aItem,{"D1_NFORI"		,SF2->F2_DOC												,NIL})
					aAdd(aItem,{"D1_SERIORI"	,SF2->F2_SERIE    											,NIL})
					aAdd(aItem,{"D1_ITEMORI"	,SD2->D2_ITEM	    										,NIL})
								
					AAdd( aItens, aItem )
						
					SD2->(dbSkip())
				End
			EndIf
			
			lMsErroAuto := .F.
			
			MSExecAuto({|x,y,z| MATA103(x,y,z)},aCab,aItens,3)
		
			If lMsErroAuto
			
				lRet := .F.
				aLog := GetAutoGrLog()
				
				For nX := 1 To Len(aLog)
					cMsgErro += aLog[nX]+CHR(13)+CHR(10)			
				Next nX
				
			Else
				cStatus := '4'
			Endif
		
		Endif
		
		If lRet
			oModel:DeActivate()
			oModel:SetOperation(MODEL_OPERATION_UPDATE)
			oModel:Activate()
			
			oMdlGIS:SetValue('GIS_STATUS', cStatus)
			oMdlGIS:ClearField('GIS_NUMDOC')
			oMdlGIS:ClearField('GIS_DATFAT')
			oMdlGIS:ClearField('GIS_FILORI')
			
			GIR->(dbSetOrder(1)) 
			
			For nX := 1 To oMdlGIT:Length()
			
				If GIR->(MsSeek(xFilial('GIR') + oMdlGIT:GetValue('GIT_CODG99', nX)))			
					RecLock('GIR',.F.)	
						GIR->GIR_CODFAT := ''   
		            GIR->(MsUnLock()) 
				Endif
			
			Next
	
			lRet := FwFormCommit(oModel)
			
		EndIf
			            
	EndIf
	    
Endif

Return lRet

/*/{Protheus.doc} GrvTitGIW
//TODO Descrição auto-gerada.
@author flavio.martins
@since 18/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function GrvTitGIW(oModel)
Local lRet 		:= .T.
Local oMdlGIS	:= oModel:GetModel('GISMASTER')
Local oMdlGIW	:= oModel:GetModel('GIWDETAIL')
Local cAliasSE1	:= GetNextAlias()
Local cPrefixo	:= oMdlGIS:GetValue('GIS_SERIE')
Local cNumDoc	:= oMdlGIS:GetValue('GIS_NUMDOC')
Local nSeq		:= 0

BeginSql Alias cAliasSE1

	SELECT SE1.E1_FILIAL,
	       SE1.E1_PREFIXO,
	       SE1.E1_NUM,
	       SE1.E1_PARCELA,
	       SE1.E1_TIPO,
	       SE1.E1_VENCTO,
	       SE1.E1_VALOR
	FROM %Table:SE1% SE1
	WHERE SE1.E1_FILIAL = %xFilial:SE1%
	  AND SE1.E1_PREFIXO = %Exp:cPrefixo%
	  AND SE1.E1_NUM = %Exp:cNumDoc%
	  AND SE1.E1_TIPO = E1_TIPO
	  AND SE1.%NotDel%

EndSql

While (cAliasSE1)->(!Eof())

	If !(oMdlGIW:IsEmpty())
		oMdlGIW:AddLine(.T.)
	Endif

	nSeq++
	
	oMdlGIW:SetValue('GIW_CODFAT',	oMdlGIS:GetValue('GIS_CODIGO'))
	oMdlGIW:LoadValue('GIW_SEQ'	,	AllTrim(StrZero(nSeq,2)))
	oMdlGIW:SetValue('GIW_FILORI',	(cAliasSE1)->E1_FILIAL)
	oMdlGIW:SetValue('GIW_PREFIX',	(cAliasSE1)->E1_PREFIXO)
	oMdlGIW:SetValue('GIW_NUMTIT',	(cAliasSE1)->E1_NUM)
	oMdlGIW:SetValue('GIW_PARCEL',	(cAliasSE1)->E1_PARCELA)
	oMdlGIW:SetValue('GIW_TIPO',	(cAliasSE1)->E1_TIPO)
	oMdlGIW:SetValue('GIW_DTVENC',	StoD((cAliasSE1)->E1_VENCTO))
	oMdlGIW:SetValue('GIW_VALOR',	(cAliasSE1)->E1_VALOR)

	(cAliasSE1)->(dbSkip())

End

FwFormCommit(oModel)

(cAliasSE1)->(dbCloseArea())

Return lRet

/*/{Protheus.doc} GetSerPar
//TODO Descrição auto-gerada.
@author flavio.martins
@since 19/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function GetSerPar()
Local cSerie := ''

If !Empty(GTPGetRules('SERFATCNTR'))
	cSerie := GTPGetRules('SERFATCNTR')
Endif

Return cSerie

/*/{Protheus.doc} G819Commit
//TODO Descrição auto-gerada.
@author flavio.martins
@since 20/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function G819Commit(oModel)
Local lRet	:= .T.

Default lIsLote := .F.
Default lGeraNF := .F.

FwFormCommit(oModel)

If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE

	If (lIsLote .And. lGeraNF) .Or. (!lIsLote .And. FwAlertYesNo(STR0037, STR0036)) //"Deseja gerar o faturamento agora ?","Faturamento"
		G819VldNF()
	Endif

Endif

Return lRet

Function G819Perg()
Local lRet := .T.

If Pergunte('GTPA819', .T.)

	FwMsgRun( ,{|| lRet := G819GerLote()},, STR0023) //"Gerando faturamento...." 

Endif

Return

/*/{Protheus.doc} G819GerLote()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 05/04/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function G819GerLote()
Local cAliasTmp	:= GetNextAlias()
Local oModel	:= FwLoadModel('GTPA819')
Local cEspecie	:= GTPGetRules('ESPFATCNTR')
Local cClieIni	:= ''
Local cClieFim	:= ''
Local cLojaIni	:= ''
Local cLojaFim	:= ''
Local dDataIni	:= ''
Local dDataFim	:= ''
Local cSerie    := ''

cClieIni := MV_PAR01
cLojaIni := MV_PAR02
cClieFim := MV_PAR03
cLojaFim := MV_PAR04
dDataIni := MV_PAR05
dDataFim := MV_PAR06
cSerie	 := MV_PAR08
lGeraNF  := (MV_PAR07 == 1)

BeginSql Alias cAliasTmp

	SELECT GIR_CLIPAG,
			GIR_LOJPAG
	FROM %Table:GIR% GIR
	WHERE GIR_FILIAL = %xFilial:GIR%
		AND GIR_DTPAG BETWEEN %Exp:dDataIni% AND %Exp:dDataFim%
		AND GIR_TIPPAG = '3'
		AND GIR_CLIPAG BETWEEN %Exp:cClieIni% AND %Exp:cClieFim%
		AND GIR_LOJPAG BETWEEN %Exp:cLojaIni% AND %Exp:cLojaFim%
		AND GIR_CODFAT = ''
		AND %NotDel%
	GROUP BY GIR_CLIPAG, GIR_LOJPAG

EndSql

If (cAliasTmp)->(Eof())
	FwAlertWarning(STR0041, STR0014) // "Não foram encontradas encomendas para faturamento com os dados informados.", 'Atenção'
	Return
Endif

If lGeraNF .And. Empty(cEspecie) 
	FwAlertWarning(STR0034, STR0014) //"O parâmetro ESPFATCNTR deve estar preenchido para realizar o faturamento", "Atenção"
	Return
Endif

lIsLote	 := .T.

Begin Transaction

While !(cAliasTmp)->(Eof())

	oModel:DeActivate()
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	oModel:SetValue('GISMASTER', 'GIS_CLIENT'	, (cAliasTmp)->GIR_CLIPAG)
	oModel:SetValue('GISMASTER', 'GIS_LOJA'		, (cAliasTmp)->GIR_LOJPAG)
	oModel:SetValue('GISMASTER', 'GIS_DTINI'	, dDataIni)
	oModel:SetValue('GISMASTER', 'GIS_DTFIM'	, dDataFim)
	oModel:SetValue('GISMASTER', 'GIS_SERIE'	, cSerie)

		GA819Pesq(oModel)

		If oModel:VldData()
		oModel:CommitData()
		Else
		DisarmTransaction()
		JurShowErro(oModel:GetErrorMessage())
		Exit 
		Endif	 

	(cAliasTmp)->(dbSkip())

EndDo

End Transaction

(cAliasTmp)->(dbCloseArea())

lIsLote := .F.

Return

