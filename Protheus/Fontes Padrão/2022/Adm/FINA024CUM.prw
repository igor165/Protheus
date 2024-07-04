#Include 'Protheus.ch'
#Include "FWMVCDEF.CH"
#INCLUDE "FINA024CUM.CH"

Static cTblBrowse   := "FKT"
Static __nOper      := 0
Static __lConfirmou := .F.
Static __lAltAll    := .F.
Static __lFirst     := .F.

#DEFINE OPER_ATIVAR	  11
#DEFINE OPER_COPIAR	  12
//---------------------------------
/*/{Protheus.doc} FINA024CUM
Regra de Cumulatividade

@author  Sivaldo Oliveira
@since 10/09/2018
@version 12
/*/
//---------------------------------
Function FINA024CUM(aRotAut As Array, nOpcAut)
	Local aLegenda As Array
	
	Default aRotAut := {} 
	Default nOpcAut := 0
	
	//Inicializa variáveis
	aLegenda := {}
	
	DbSelectArea("FOT")
	DbSelectArea(cTblBrowse)
	(cTblBrowse)->(DbSetOrder(2))	
	
	If Len(aRotAut) > 0
		FWMVCRotAuto(FWLoadModel("FINA024CUM"), cTblBrowse, nOpcAut, {{"FKTMASTER", aRotAut}}, , .T.)
	Else
		FxBrowse(cTblBrowse, 2, STR0001, aLegenda)		//"Regra de Cumulatividade"
	EndIf
Return
 
//---------------------------------
/*/{Protheus.doc} MenuDef
Menu
@author  Sivaldo Oliveira
@since 21/08/25/08/2018
@version 12
/*/
//---------------------------------
Static Function MenuDef() As Array
	Local aRotina  As Array
	Local aTitMenu As Array
	Local aActions As Array
	
	//Inicializa variáveis
	aTitMenu := { {STR0010, "F24CUMCOP", OP_COPIA} }
	aActions := { {STR0005, "F24CUMVIS"}, {STR0002, "F24CUMINC"}, {STR0003, "F24CUMALT"}, {STR0004, "F24CUMEXC"}}
	aRotina := FxMenuDef(.T., aTitMenu, aActions)
Return aRotina

//---------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados do detalhe de tipo de retenção
@author  Sivaldo Oliveira
@since 21/08/25/08/2018
@version 12
/*/
//---------------------------------
Static Function ModelDef() As Object
	Local oModel  As Object
	Local oCabeca As Object
	Local oDetail As Object
	Local aRelFKT As Array
	
	//Inicializa variáveis.
	aRelFKT := {}
	
	oCabeca := FxStruct(1, cTblBrowse, Nil, Nil, {}, Nil)		
	oDetail := FxStruct(1, "FOT",      Nil, Nil, {}, Nil)
	
	//Instancia o objeto 
	oModel := MPFormModel():New("FINA024CUM", Nil, {||F24CUMOK()}, Nil, Nil)
	
	//Adiciona uma um submodel editável/fields
	oModel:AddFields("FKTMASTER", Nil, oCabeca, Nil, Nil, Nil)
	oModel:AddGrid("FOTDETAIL",  "FKTMASTER", oDetail, Nil, Nil, Nil, Nil, Nil)
	
	//Relacionamento do model tabelas FKT -> FOT
	aAdd(aRelFKT, {"FOT_FILIAL", "xFilial('FOT')"} )
	aAdd(aRelFKT, {"FOT_IDRET",  "FKT_IDRET"})
	oModel:SetRelation("FOTDETAIL", aRelFKT, FOT->(IndexKey(1)))
	
	//Define a chave primária do modelo
	oModel:SetPrimaryKey({"FKT_FILIAL", "FKT_IDRET"})
	oModel:SetDescription(STR0001) //Regra de Cumulatividade	
	
	//Inicializa os campo IDRET
	If (__nOper != MODEL_OPERATION_UPDATE .And. __nOper != MODEL_OPERATION_DELETE)
		oCabeca:SetProperty("FKT_IDRET",   MODEL_FIELD_INIT, {||F24CUMIDR(oModel)})
	EndIf
	
	If __nOper == MODEL_OPERATION_UPDATE
		oCabeca:SetProperty("FKT_CODIGO", MODEL_FIELD_WHEN,  {||.F.})
		oCabeca:SetProperty("FKT_DESCR",  MODEL_FIELD_WHEN,  {||.T.})
		oModel:GetModel("FOTDETAIL"):SetNoUpdateLine(!__lAltAll)
	EndIf	
	
	//Ativa o modelo
	oModel:SetActivate()
Return oModel

//---------------------------------
/*/{Protheus.doc} ViewDef
Criação da View
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
/*/
//---------------------------------
Static Function ViewDef() As Object
	Local oModel  As Object
	Local oView   As Object
	Local oCabeca As Object
	Local oDetail As Object
	
	//Instancia os objetos: model e view
	oModel := FWLoadModel("FINA024CUM")
	oView  := FWFormView():New()
	
	oCabeca := FxStruct(2, cTblBrowse, Nil, Nil, {"FKT_IDRET"}, Nil)
	oDetail := FxStruct(2, "FOT",      Nil, Nil, {"FOT_IDRET"}, Nil)
	
	//Seta o modelo de dados a ser usado na view
	oView:SetModel(oModel)

	oView:createHorizontalBox("CABECA", 20, /*cIdOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
	oView:createHorizontalBox("DETAIL", 80, /*cIdOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)		
	
	//Adiciona na grid um controle de FormFields
	oView:AddField("VIEW_CABECA", oCabeca, "FKTMASTER")
	oView:AddGrid( "GRID_DETAIL", oDetail, "FOTDETAIL")
	
	oView:SetOwnerView("VIEW_CABECA", "CABECA" )
	oView:SetOwnerView("GRID_DETAIL", "DETAIL" )
	
	oView:SetDescription(STR0001) //Regra de Cumulatividade
	oView:EnableTitleView("GRID_DETAIL", STR0009) //Cadastre a Regra Financeira de Retenção.
	
	oDetail:SetProperty("FOT_CODIGO", MVC_VIEW_LOOKUP,  {||F24CUMCF3("FOT_CODIGO")})
	
	//Desabilita o campo de item
	oDetail:SetProperty("FOT_ITEM", MVC_VIEW_CANCHANGE, .F.)
	
	oDetail:SetProperty("FOT_ITEM",   MVC_VIEW_ORDEM,   "03")
	oDetail:SetProperty("FOT_CODIGO", MVC_VIEW_ORDEM,	"04")
	
	//Auto Incremento
	oView:AddIncrementField("GRID_DETAIL", "FOT_ITEM")	
	
	//Faz o refresh da view
	If (__nOper == MODEL_OPERATION_UPDATE .Or. __nOper == OPER_COPIAR)  
		oView:SetAfterViewActivate({|oView|F24CUMREF(oView)})
	EndIf
Return oView

//---------------------------------
/*/{Protheus.doc} F24CUMVIS
Define a operação de VISUALIZAÇÃO
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
FIN024CVA()
/*/
//---------------------------------
Function F24CUMVIS()
	Local oModel   As Object
	Local aButtons As Array

	//Inicializa variáveis
	__nOper  := MODEL_OPERATION_VIEW
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	
	oModel := FwLoadModel("FINA024CUM")
	oModel:SetOperation(MODEL_OPERATION_VIEW)
	oModel:Activate()

	FWExecView(STR0005, "FINA024CUM", MODEL_OPERATION_VIEW,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel ) //Incluir

	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
Return Nil


//---------------------------------
/*/{Protheus.doc} F24CUMINC
Define a operação de inclusão
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
FIN024CVA()
/*/
//---------------------------------
Function F24CUMINC()
	Local oModel   As Object
	Local aButtons As Array

	//Inicializa variáveis
	__nOper  := MODEL_OPERATION_INSERT
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	
	oModel := FwLoadModel("FINA024CUM")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	FWExecView(STR0002, "FINA024CUM", MODEL_OPERATION_INSERT,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel ) //Incluir

	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
Return Nil


//---------------------------------
/*/{Protheus.doc} F24CUMALT
Define a operação de alteração
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
/*/
//---------------------------------
Function F24CUMALT()
	Local aButtons As Array
	Local oModel   As Object
	Local cCodigo  As Character
	Local cIdRet   As Character		
	
	//Carrega o modelo de dados
	__nOper := MODEL_OPERATION_UPDATE
	oModel  := FwLoadModel("FINA024CUM")
	oModel:Activate()
	
	//Inicializa variáveis
	cIdRet    := oModel:GetValue("FKTMASTER", "FKT_IDRET")
	cCodigo   := oModel:GetValue("FKTMASTER", "FKT_CODIGO")	
	__lAltAll := .t.//FinVldExc("FKO", "FKT", cIdRet, cCodigo)	
	aButtons  := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	
	FWExecView(STR0003, "FINA024CUM", MODEL_OPERATION_UPDATE,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, /*oModel*/) //Alterar
	
	__nOper      := 0
	__lAltAll := .F.
	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
Return Nil

//---------------------------------
/*/{Protheus.doc} F24CUMEXC
Define a operação de exclusão
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
/*/
//---------------------------------
Function F24CUMEXC()
	Local oModel   As Object
	Local aButtons As Array
	Local lExclui  As Logical
	Local cCodigo  As Character
	Local cIdRet   As Character
	
	//Carrega o modelo
	__nOper := MODEL_OPERATION_DELETE	
	oModel   := FwLoadModel("FINA024CUM")
	oModel:SetOperation(MODEL_OPERATION_DELETE)
	oModel:Activate()
	
	//Inicializa variáveis
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	cIdRet   := oModel:GetValue("FKTMASTER", "FKT_IDRET")
	cCodigo  := oModel:GetValue("FKTMASTER", "FKT_CODIGO")	
	lExclui  := .t.//FinVldExc("FKO", "FKT", cIdRet, cCodigo)
	
	If lExclui
		FWExecView(STR0004, "FINA024CUM", MODEL_OPERATION_DELETE,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel ) //Excluir
	Else
		Help(" ", 1, "FA024EXC", Nil, STR0011, 2, 0,,,,,, {}) //Não é permitido excluir regra de cumulatividade que esteja amarrada a uma regra de retenção.
	Endif
	
	__nOper := 0
	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
	FKT->(DbSetOrder(2))
Return Nil

//---------------------------------
/*/{Protheus.doc} F024CODFKT()
Pos Validacao de preenchimento do código do registro de retenção
@author Sivaldo Oliveira
@since 10/09/2018
@version 12
/*/
//---------------------------------
Function F024CODFKT() As Logical
	Local lRet    As Logical
	Local oModel  As Object
	Local cCodigo As Character
	Local lAchou  As Logical
	Local cCab    As Character
	Local cDes    As Character
	Local cSol    As Character
	

	//Inicializa variáveis
	lRet    := .F.
	oModel  := FWModelActive()
	cCodigo := oModel:GetValue("FKTMASTER", "FKT_CODIGO")
	lAchou  := .F.
	cCab    := ""
	cDes    := ""
	cSol    := ""	
	
	If !Empty(cCodigo)
		FKT->(DbSetOrder(2))
		lAchou := FKT->(MSSeek(xFilial("FKT") + cCodigo))
	EndIf
	
	If __nOper != MODEL_OPERATION_INSERT .And. __nOper != OPER_COPIAR
		cCab := STR0012 //Código
		cDes := STR0013	//Operação não permitida
		cSol := STR0014	//Este campo não pode ser alterado
	ElseIf !FreeForUse("FKT", "FKT_CODIGO" + xFilial("FKT") + cCodigo)
		cCab := STR0012	//Código
		cDes := STR0015 + ": " + cCodigo + " " + STR0016 //O código xxx encontra-se em uso
		cSol := STR0017	//Código se encontra reservado
	ElseIf lAchou
		cCab := STR0012 //Código
		cDes := STR0015 + ": " + cCodigo + " " + STR0018//O código já se encontram cadastrados
		cSol := STR0019	//Código já cadastrado
	Else
		lRet := .T.
	EndIf

	If !Empty(cCab+cDes+cSol)
		HELP(' ',1, cCab ,, cDes ,2,0,,,,,, {cSol} )
	EndIf
Return lRet

//---------------------------------------
/*/{Protheus.doc} F24CUMCOP()
Define operacao de Cópia de 

@author  Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24CUMCOP()
	Local aButtons As Array
	
	//Inicializa variáveis
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	__nOper  := OPER_COPIAR
	__lFirst := .T.
	
	FWExecView(STR0010, "FINA024CUM", OP_COPIA,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, /*oModel*/ )
	
	__nOper := 0
	__lFirst := .F.
	FKT->(DbSetOrder(2))
Return

/*/{Protheus.doc} F24CUMIDR()
Inicializador do campo FKT_IDRET
@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24CUMIDR(oModel As Object)
	Local cRet   As Character
	Local aArea  As Array
	Local cChave As Character
	
	//Inicializa variáveis
	cRet   := ""
	cChave := ""
	
	If (__nOper != MODEL_OPERATION_UPDATE .And. __nOper != MODEL_OPERATION_DELETE)
		aArea  := FKT->(GetArea())
		
		While .T.
			cRet := FWUUIDV4()
			FKT->(DbSetOrder(1))
			cChave := (xFilial("FKT") + cRet)  
			If !(FKT->(MsSeek(cChave))) .And. FreeForUse("FKT", cRet)
				FKT->(RestArea(aArea))
				Exit	
			Endif
		EndDo
		
		RestArea(aArea)
		
		If __nOper == OPER_COPIAR .And. __lFirst
			If oModel == Nil
				oModel  := FWModelActive()
			EndIf
			
			oModel:LoadValue("FKTMASTER", "FKT_CODIGO", " ")
			oModel:LoadValue("FKTMASTER", "FKT_DESCR",  " ")
			__lFirst := .F.
		EndIf	
	Else
		cRet := FKT->FKT_IDRET
	EndIf

Return cRet

//---------------------------------------
/*/{Protheus.doc} F24CUMCF3()
Consulta Padrao F3

@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24CUMCF3(cCampo As Character)
	Local cRet As Character
	
	//Inicializa variáveis
	cRet := "FKK"
Return cRet 

//---------------------------------------
/*/{Protheus.doc} F024CODFOT()
Valida retorno 

@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F024CODFOT() As Logical 
	Local cCodigo As Character
	Local oModel  As Object
	Local lRet    As Logical
	
	//Inicializa variáveis
	lRet  := .T.
	oModel  := FWModelActive()
	cCodigo := oModel:GetValue("FOTDETAIL", "FOT_CODIGO")	
	
	If !Empty(cCodigo)
		FKK->(DbSetOrder(2))
		If !FKK->(DbSeek(xFilial("FKK") + cCodigo))
			Help(" ", 1, "F24REGRAFIN", Nil, STR0007 + ": " + cCodigo + " " + STR0008, 2, 0,,,,,, {STR0009})
			lRet := .F.
		EndIf
	EndIf

Return lRet 

//---------------------------------------
/*/{Protheus.doc} F24CUMINI()
Inicianilizador padrão campo virtual FOT_DSCRFR

@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24CUMINI()
	Local oModel  As Object
	Local oFOT    As Object
	Local cCodigo As Character
	Local cRet    As Character 
	
	//Inicializa variáveis
	cRet    := ""
	oModel  := FWModelActive()
	oFOT    := oModel:GetModel("FOTDETAIL")
	
	If oFOT:NLINE != 0
		cCodigo := oFOT:GetValue("FOT_CODIGO")
		
		If !Empty(cCodigo)
			FKK->(DbSetOrder(2))
			If FKK->(DbSeek(xFilial("FKK") + cCodigo))
				cRet := AllTrim(FKK->FKK_DESCR)
			EndIf
		EndIf	
	EndIf
	
	cRet := AllTrim(cRet)
Return cRet

//---------------------------------------
/*/{Protheus.doc} F24CUMVIR()
Preenche os campos virtuais da Grid
  
@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24CUMVIR()
	Local cRet   As Character
	Local oModel As Object
	Local oFOT   As Object 
	Local nOper	As Numeric
	
	//Inicializa variáveis
	cRet    := ""
	oModel  := FWModelActive()
	oFOT    := oModel:GetModel("FOTDETAIL")
	nOper	:= oModel:GetOperation()

	If nOper != MODEL_OPERATION_INSERT
		cCodigo	:= FOT->FOT_CODIGO
		If !Empty(cCodigo)
			FKK->(DbSetOrder(2))
			If FKK->(DbSeek(xFilial("FKK") + cCodigo))
				cRet := AllTrim(FKK->FKK_DESCR)
			Else
				Help(" ", 1, "F24REGRAFIN", Nil, STR0007 + ": " + cCodigo + " " + STR0008, 2, 0,,,,,, {STR0009})
			EndIf
		Endif
	EndIf

Return cRet 

//---------------------------------------
/*/{Protheus.doc} F24CUMREF()
Atualiza a visualização dos dados na view
@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24CUMREF(oView As Object)
	oView:Refresh()
Return .T.

//---------------------------------------
/*/{Protheus.doc} F24CUMOK()
Pós Validação do model 

@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24CUMOK()
	Local lRet As Logical
	
	//Inicializa variáveis
	lRet := .T.
	__lConfirmou := lRet
Return lRet