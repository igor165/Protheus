#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCPA139.CH"
#INCLUDE "FWMVCDEF.CH"

Function PCPA139()
	Local aArea   	:= GetArea()
	Local aButtons	:= {{.F., Nil},{.F., Nil},{.F., Nil},{.F., Nil},{.F., Nil},{.F., Nil},{.T., STR0002},{.T.,STR0003},{.F., Nil},{.F., Nil},{.F., Nil},{.F., Nil},{.F., Nil},{.F., Nil}} // STR0002 - Salvar STR0003 - Cancelar
	Local lHwl := FWAliasInDic("HWL",.F.)

	If GetRpoRelease() < "12.1.025"
		HELP(' ',1,"Release" ,,STR0036 ,2,0,,,,,,) //"Rotina disponível a partir do release 12.1.25."
		Return
	EndIf

	//Se a tabela T4R não estiver em modo compartilhado, não permite abertura da tela
	If !FWModeAccess("T4R",1) == "C" .Or. !FWModeAccess("T4R",2) == "C" .Or. !FWModeAccess("T4R",3) == "C"
		HELP(' ', 1, "Help",, STR0027,; //"A rotina não pode ser inciada pois tabela T4R (pendências do MRP) está com modo de compartilhamento incorreto)."
		     2, 0, , , , , , {STR0028}) //"Altere o modo de compartilhamento da tabela T4R para 'Compartilhado'."
		Return
	EndIf

	dbSelectArea("T4P")
	dbGoTop()

	If lHwl
		dbSelectArea("HWL")
		dbGoTop()
	EndIf

	//Executa validações do MRP
	FWMsgRun( , {|oSay| vldMrp(oSay)}, STR0037, STR0038) //"Aguarde" - "Validando Triggers do MRP..."

	If lHwl
		CarregaHWL()
	EndIf
	CarregaT4P()
	FWExecView(STR0006, 'PCPA139', MODEL_OPERATION_UPDATE, , { || .T.}, , ,aButtons ) //ALTERAR

	RestArea(aArea)

Return NIL

/*/{Protheus.doc} vldMrp
Executa as validações do MRP antes de abrir a tela.
@type  Static Function
@author lucas.franca
@since 17/05/2021
@version P12
@param oSay, Object, Objeto SAY para manipular mensagem da tela.
@return Nil
/*/
Static Function vldMrp(oSay)
	Local aAreaTab := GetArea()

	MRPVldTrig(.T.,,.T.) //Valida se a Trigger do MRP está configurada corretamente
	
	oSay:SetText(STR0039) //"Verificando necessidade de sincronização com o MRP..."
	oSay:CtrlRefresh()
	
	MRPVldSync(.T.) //Verifica se é necessário executar a sincronização para alguma API, de acordo com o conteúdo do campo T4P_ALTER.

	RestArea(aAreaTab)
Return Nil

/*/{Protheus.doc} ModelDef
Definição do modelo do cadastro de lista de componentes
@author Douglas Heydt
@since 19/05/2019
@version 1.0
@return oModel - Modelo de dados definido
/*/
Static Function ModelDef()

	Local aFilter   := {}
	Local oStru 	:= FWFormStruct(1, "T4P", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|T4P_API|"})
	Local oStruHWL 	:= FWFormStruct(1, "HWL")
	Local oStruT4P 	:= FWFormStruct( 1, 'T4P' )
	Local oEvent	:= PCPA139EVDEF():New()
	Local oModel
	Local lHwl      := FWAliasInDic("HWL",.F.)

	oModel := MPFormModel():New( 'PCPA139')

	oStruT4P:AddField(	STR0007/*"Descrição API"*/						,;	// [01]  C   Titulo do campo //"Revisão"
	                    STR0007/*"Descrição API"*/						,;	// [02]  C   ToolTip do campo "Revisão"
	                    "DESCAPI"										,;	// [03]  C   Id do Field
	                    "C"												,;	// [04]  C   Tipo do campo
	                    GetSx3Cache("T4P_API","X3_TAMANHO")				,;	// [05]  N   Tamanho do campo
	                    0												,;	// [06]  N   Decimal do campo
	                    {||.T.}											,;	// [07]  B   Code-block de validação do campo
	                    NIL												,;	// [08]  B   Code-block de validação When do campo
	                    NIL												,;	// [09]  A   Lista de valores permitido do campo
	                    .F.												,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	                    FWBuildFeature(STRUCT_FEATURE_INIPAD,"StaticCall(PCPA139,IniDesc)"),;	// [11]  B   Code-block de inicializacao do campo
	                    NIL												,;	// [12]  L   Indica se trata-se de um campo chave
	                    NIL												,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	                    .T.												)	// [14]  L   Indica se o campo é virtual
	oStruT4P:SetProperty("T4P_API", MODEL_FIELD_NOUPD,.T.)

	If lHwl
		oStruHWL:SetProperty( "HWL_ATIVO", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"UpdExec()"))

		oModel:AddFields( 'HWLMASTER', /*cOwner*/, oStruHWL )
		oModel:AddGrid( 'T4PDETAIL','HWLMASTER', oStruT4P )
		oModel:SetRelation("T4PDETAIL"	, {{"T4P_FILIAL","HWL_FILIAL"}}, T4P->(IndexKey(1)))
	Else
		oModel:AddFields( 'T4PMASTER', /*cOwner*/, oStru )
		oModel:AddGrid( 'T4PDETAIL','T4PMASTER', oStruT4P )
		oModel:SetRelation("T4PDETAIL"	, {{"T4P_FILIAL","xFilial('T4P')"}}, T4P->(IndexKey(1)))
	EndIf

	oModel:SetPrimaryKey({"T4P_API"})

	oModel:SetDescription(STR0001) //"Parâmetros de integração MRP"

	oModel:GetModel("T4PDETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("T4PDETAIL"):SetNoDeleteLine(.T.)

	oModel:InstallEvent("PCPA139EVDEF", /*cOwner*/, oEvent)

	aAdd(aFilter,{'T4P_API',"'"+PADR("MRPPRODUCTINDICATOR",60)+"'",MVC_LOADFILTER_NOT_EQUAL})

	If FWAliasInDic( "HW9", .F. )
		aAdd(aFilter,{'T4P_API',"'"+PADR("MRPBOMROUTING",60)+"'",MVC_LOADFILTER_NOT_EQUAL})
	EndIf

	If FWAliasInDic( "HWX", .F. )
		aAdd(aFilter,{'T4P_API',"'"+PADR("MRPREJECTEDINVENTORY",60)+"'",MVC_LOADFILTER_NOT_EQUAL})
	EndIf

	oModel:GetModel('T4PDETAIL'):SetLoadFilter(aFilter)

Return oModel

/*/{Protheus.doc} ViewDef
Definição da view do cadastro de lista de componentes
@author Douglas Heydt
@since 19/05/2019
@version 1.0
@return oView - View definida
/*/
Static Function ViewDef()

	Local oModel 	:= FWLoadModel( 'PCPA139' )
	Local oStruHWL 	:= FWFormStruct( 2, 'HWL',  {|cCampo| ! "|" + AllTrim(cCampo) + "|" $ "|HWL_NETCH|"})
	Local oStruT4P 	:= FWFormStruct( 2, 'T4P' )
	Local oView
	Local lHwl      := FWAliasInDic("HWL",.F.)

	oView := FWFormView():New()
	oView:SetModel( oModel )

	If lHwl
		oView:AddField("VIEW_HWL", oStruHWL, "HWLMASTER" )
		oView:EnableTitleView("VIEW_HWL",STR0032)
		oStruT4P:RemoveField("T4P_ATIVO")
	EndIf

	oStruT4P:AddField("DESCAPI"						,;	// [01]  C   Nome do Campo
	                    "02"						,;	// [02]  C   Ordem
	                    STR0007/*"Descrição API"*/	,;	// [03]  C   Titulo do campo    //"Descrição"
	                    STR0007/*"Descrição API"*/	,;	// [04]  C   Descricao do campo //"Descrição"
	                    NIL							,;	// [05]  A   Array com Help
	                    "C"							,;	// [06]  C   Tipo do campo
	                    "@!"						,;	// [07]  C   Picture
	                    NIL							,;	// [08]  B   Bloco de Picture Var
	                    NIL							,;	// [09]  C   Consulta F3
	                    .F.							,;	// [10]  L   Indica se o campo é alteravel
	                    NIL							,;	// [11]  C   Pasta do campo
	                    NIL							,;	// [12]  C   Agrupamento do campo
	                    NIL							,;	// [13]  A   Lista de valores permitido do campo (Combo)
	                    NIL							,;	// [14]  N   Tamanho maximo da maior opção do combo
	                    NIL							,;	// [15]  C   Inicializador de Browse
	                    .T.							,;	// [16]  L   Indica se o campo é virtual
	                    NIL							,;	// [17]  C   Picture Variavel
	                    NIL							)	// [18]  L   Indica pulo de linha após o campo

	oStruT4P:SetProperty( 'T4P_API'   , MVC_VIEW_ORDEM, "01")
	oStruT4P:SetProperty( 'T4P_TPEXEC', MVC_VIEW_ORDEM, "03")
	If !lHwl
		oStruT4P:SetProperty( 'T4P_ATIVO' , MVC_VIEW_ORDEM, "04")
	EndIf

	oView:AddGrid("VIEW_T4P",oStruT4P,"T4PDETAIL")
	If lHwl
		oView:EnableTitleView("VIEW_T4P",STR0031)

		oView:CreateHorizontalBox( "SUPERIOR", 110, , .T.) //Tamanho em Pixels
		oView:CreateHorizontalBox( "INFERIOR", 100 )

		oView:SetOwnerView( "VIEW_HWL",	"SUPERIOR" )
		oView:SetOwnerView( "VIEW_T4P", "INFERIOR")
	Else
		oView:CreateHorizontalBox("SUPERIOR",100)
		oView:SetOwnerView("VIEW_T4P","SUPERIOR")
		oView:AddUserButton(STR0004	, "", {|| UpdExec(oModel) }, "STR0006", , ,.T.) //"Ativar/Desativar Integrações"
	EndIf

Return oView

/*/{Protheus.doc} UpdExec
Atualiza o valor do campo T4P_ATIVO para todos os registros da tabela
@author Douglas Heydt
@since 19/05/2019
@version 1.0
@return lRet, Logical, Informa se foi executado com sucesso.
/*/
Function UpdExec()
	Local lRet      := .T.
	Local lHwl      := FWAliasInDic("HWL",.F.)
	Local oModel    := FWModelActive()
	Local oView     := FWViewActive()
	Local oModelT4P := oModel:GetModel("T4PDETAIL")
	Local oModelHWL := oModel:GetModel("HWLMASTER")
	Local nX
	Local cOption

	If lHwl
		If oModelT4P:GetValue("T4P_ATIVO") != oModelHWL:GetValue("HWL_ATIVO") .And. !Empty(oModelHWL:GetValue("HWL_ATIVO"))
			For nX := 1 To oModelT4P:Length()
				oModelT4P:GoLine(nX)
				oModelT4P:SetValue("T4P_ATIVO", oModelHWL:GetValue("HWL_ATIVO"))
			Next nX
			oModelT4P:GoLine(1)
			oView:Refresh("VIEW_T4P")
		EndIf
	Else
		If oModelT4P:GetValue("T4P_ATIVO") == "1"
			cOption := "2"
		Else
			cOption := "1"
		EndIf

		For nX := 1 To oModelT4P:Length()
			oModelT4P:GoLine(nX)
			oModelT4P:SetValue("T4P_ATIVO", cOption)
		Next nX
		oModelT4P:GoLine(1)
	EndIf

Return lRet

/*/{Protheus.doc} CarregaT4P
Verifica se a tabela tem todos os registros necessários e, caso não existam faz a inserção.
@author Douglas Heydt
@since 19/05/2019
@version 1.0
@return lRet
/*/
Static Function CarregaT4P()
	Local lRet 		:= .T.
	Local aStrT4P 	:= {}
	Local cAtivo	:= "2"
	Local nI
	Local cAliasQry
	Local cQryCondic

	//API; Tipo execucao padrao
	aAdd(aStrT4P,{"MRPDEMANDS"          , "1"})
	aAdd(aStrT4P,{"MRPPRODUCTIONVERSION", "1"})
	aAdd(aStrT4P,{"MRPBILLOFMATERIAL"   , "1"})

	If FWAliasInDic( "HW9", .F. )
		aAdd(aStrT4P,{"MRPBOMROUTING"   , "1"})
	EndIf

	aAdd(aStrT4P,{"MRPALLOCATIONS"      , "2"})
	aAdd(aStrT4P,{"MRPPRODUCTIONORDERS" , "1"})
	aAdd(aStrT4P,{"MRPPURCHASEORDER"    , "2"})
	aAdd(aStrT4P,{"MRPPURCHASEREQUEST"  , "2"})
	aAdd(aStrT4P,{"MRPSTOCKBALANCE"     , "2"})
	If FWAliasInDic( "HWX", .F. )
		aAdd(aStrT4P,{"MRPREJECTEDINVENTORY", "2"})
	EndIf
	aAdd(aStrT4P,{"MRPCALENDAR"         , "1"})
	aAdd(aStrT4P,{"MRPPRODUCT"          , "1"})
	aAdd(aStrT4P,{"MRPPRODUCTINDICATOR" , "1"})

	If FWAliasInDic( "HWY", .F. )
		aAdd(aStrT4P,{"MRPWAREHOUSE", "2"})
	EndIf

	dbSelectArea('T4P')
	T4P->(dbSetOrder(1))

	IF T4P->(dbSeek(xFilial('T4P')))
		cAtivo := T4P->T4P_ATIVO
	EndIf

	For nI := 1 to len( aStrT4P )
		cAliasQry  := GetNextAlias()
		cQryCondic := "% "+RetSqlName("T4P")+" WHERE T4P_FILIAL = '"+xFilial('T4P')+"' AND T4P_API = '"+aStrT4P[nI][1]+"'%"

		BeginSql Alias cAliasQry
			SELECT  T4P_API	FROM %Exp:cQryCondic%
		EndSql

		If (cAliasQry)->(Eof())
			RecLock('T4P',.T.)
			T4P->T4P_FILIAL := xFilial('T4P')
			T4P->T4P_API    := aStrT4P[nI][1]
			T4P->T4P_TPEXEC := aStrT4P[nI][2]
			T4P->T4P_ATIVO  := cAtivo
			T4P->(MsUnLock())
		EndIf
		(cAliasQry)->(dbCloseArea())
	Next

Return lRet

/*/{Protheus.doc} CarregaHWL
Verifica se a tabela tem todos os registros necessários e, caso não existam faz a inserção.
@author Renan Roeder
@since 13/03/2020
@version 1.0
/*/
Static Function CarregaHWL()
	Local cAtivo	:= "2"
	Local cAliasQry
	Local cQryCondic

	dbSelectArea("T4P")
	T4P->(dbSetOrder(1))

	IF T4P->(dbSeek(xFilial("T4P")))
		cAtivo := T4P->T4P_ATIVO
	EndIf

	cAliasQry  := GetNextAlias()
	cQryCondic := "% "+RetSqlName("HWL")+" %"

	BeginSql Alias cAliasQry
		SELECT HWL_ATIVO FROM %Exp:cQryCondic%
	EndSql

	If (cAliasQry)->(Eof())
		RecLock("HWL",.T.)
		HWL->HWL_FILIAL := xFilial("HWL")
		HWL->HWL_ATIVO  := cAtivo
		HWL->HWL_NETCH  := "2"
		HWL->(MsUnLock())
	EndIf
	(cAliasQry)->(dbCloseArea())

Return Nil

/*/{Protheus.doc} IniDesc
Inicializador padrão do campo de descrição de APIs
@author Douglas Heydt
@since 21/05/2019
@version 1.0
@return lRet
/*/
Static Function IniDesc()

	Local cCodApi := Alltrim(T4P->T4P_API)

Return P139GetAPI(cCodApi)

/*/{Protheus.doc} P139GetAPI
Inicializador padrão do campo de descrição de APIs
@author Douglas Heydt
@since 21/05/2019
@version 1.0
@param 01 cCodAPI, caracter, código da API
@return cDesc  , caracter, descrição da API
/*/
Function P139GetAPI(cCodApi)

	Local cDesc := cCodApi

	Do Case
		Case cCodApi == "MRPDEMANDS"
			cDesc := STR0008//"Demandas MRP"
		Case cCodApi == "MRPPRODUCTIONVERSION"
			cDesc := STR0009//"Versão da Produção MRP"
		Case cCodApi == "MRPBILLOFMATERIAL"
			cDesc := STR0010 //"Estruturas do MRP"
		Case cCodApi == "MRPBOMROUTING"
			cDesc := STR0033 //"Operações por Componente"
		Case cCodApi == "MRPALLOCATIONS"
			cDesc := STR0011 //"Empenhos do MRP"
		Case cCodApi == "MRPPRODUCTIONORDERS"
			cDesc := STR0012 //"Ordens de produção do MRP"
		Case cCodApi == "MRPPURCHASEORDER"
			cDesc := STR0013 //"Solicitações de Compras do MRP"
		Case cCodApi == "MRPPURCHASEREQUEST"
			cDesc := STR0019 //"Pedidos de Compras do MRP"
		Case cCodApi == "MRPSTOCKBALANCE"
			cDesc := STR0020 //"Saldo em Estoque MRP"
		Case cCodApi == "MRPREJECTEDINVENTORY"
			cDesc := STR0034 //"Saldo Rejeitado pelo CQ"
		Case cCodApi == "MRPCALENDAR"
			cDesc := STR0021 //"Calendário do MRP"
		Case cCodApi == "MRPPRODUCT"
			cDesc := STR0029 //"Produtos do MRP"
		Case cCodApi == "MRPPRODUCTINDICATOR"
			cDesc := STR0030 //"Indicadores de Produtos do MRP"
		Case cCodApi == "MRPWAREHOUSE"
			cDesc := STR0035 //"Armazéns
	EndCase

Return cDesc

/*/{Protheus.doc} P139AllAPI
Retorna um objeto JSON com as APIs do programa
@author Marcelo Neumann
@since 24/09/2019
@version 1.0
@return oAPIs, object, JSON com as APIs: oAPIs[CODIGOAPI] := Descrição API
/*/
Function P139AllAPI()

	Local oAPIs := JsonObject():New()

	oAPIs["MRPDEMANDS"          ] := P139GetAPI("MRPDEMANDS"          )
	oAPIs["MRPPRODUCTIONVERSION"] := P139GetAPI("MRPPRODUCTIONVERSION")
	oAPIs["MRPBILLOFMATERIAL"   ] := P139GetAPI("MRPBILLOFMATERIAL"   )
	If FWAliasInDic( "HW9", .F. )
		oAPIs["MRPBOMROUTING"   ] := P139GetAPI("MRPBOMROUTING"       )
	EndIf
	oAPIs["MRPALLOCATIONS"      ] := P139GetAPI("MRPALLOCATIONS"      )
	oAPIs["MRPPRODUCTIONORDERS" ] := P139GetAPI("MRPPRODUCTIONORDERS" )
	oAPIs["MRPPURCHASEORDER"    ] := P139GetAPI("MRPPURCHASEORDER"    )
	oAPIs["MRPPURCHASEREQUEST"  ] := P139GetAPI("MRPPURCHASEREQUEST"  )
	oAPIs["MRPSTOCKBALANCE"     ] := P139GetAPI("MRPSTOCKBALANCE"     )
	If FWAliasInDic( "HWX", .F. )
		oAPIs["MRPREJECTEDINVENTORY"   ] := P139GetAPI("MRPREJECTEDINVENTORY"       )
	EndIf
	oAPIs["MRPCALENDAR"         ] := P139GetAPI("MRPCALENDAR"         )
	oAPIs["MRPPRODUCT"          ] := P139GetAPI("MRPPRODUCT"          )
	oAPIs["MRPPRODUCTINDICATOR" ] := P139GetAPI("MRPPRODUCTINDICATOR" )
	If FWAliasInDic( "HWY", .F. )
		oAPIs["MRPWAREHOUSE"    ] := P139GetAPI("MRPWAREHOUSE"        )
	EndIf

Return oAPIs