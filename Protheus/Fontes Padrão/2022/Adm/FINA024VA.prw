#Include 'Protheus.ch'
#Include "FWMVCDEF.CH"
#INCLUDE "FINA024VA.CH"

Static cTblBrowse   := "FKU"
Static __nOper      := 0
Static __lConfirmou := .F.
Static __lFirst     := .T.
Static __lAltAll    := .F.
Static __aVAFixo    := Nil 

#DEFINE OPER_COPIAR	  12
//---------------------------------
/*/{Protheus.doc} FINA024VA
Regra de Valores Acess�rios

@author  Sivaldo Oliveira
@since 10/09/2018
@version 12
/*/
//---------------------------------
Function FINA024VA(aRotAut As Array, nOpcAut)
	Local aLegenda As Array
	
	Default aRotAut := {} 
	Default nOpcAut := 0
	
	//Inicializa vari�veis
	aLegenda := {}
	
	DbSelectArea("FOU")
	DbSelectArea(cTblBrowse)
	(cTblBrowse)->(DbSetOrder(2))
	
	If Len(aRotAut) > 0
		FWMVCRotAuto(FWLoadModel("FINA024VA"), cTblBrowse, nOpcAut, {{"FKUMASTER", aRotAut}}, , .T.)
	Else
		FxBrowse(cTblBrowse, 2, STR0001, aLegenda) //Regra de Valores Acess�rios
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
	
	//Inicializa vari�veis
	aTitMenu := {{STR0006, "F24VACOP", OP_COPIA}}
	aActions := { {STR0005, "F24VAVIS"}, {STR0002, "F24VAINC"}, {STR0003, "F24VAALT"}, {STR0004, "F24VAEXC"}}
	aRotina  := FxMenuDef(.T., aTitMenu, aActions)
Return aRotina

//---------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados do detalhe de tipo de reten��o
@author  Sivaldo Oliveira
@since 21/08/25/08/2018
@version 12
/*/
//---------------------------------
Static Function ModelDef() As Object
	Local oModel  As Object
	Local oCabeca As Object
	Local oDetail As Object
	Local aRelFKU As Array
	
	//Inicializa vari�veis.
	aRelFKU := {}
	
	//oModel := FWFormModelStruct():New()
	oCabeca := FxStruct(1, cTblBrowse, Nil, Nil, {}, Nil)		
	oDetail := FxStruct(1, "FOU",      Nil, Nil, {}, Nil)
	
	//Instacia o objeto 
	oModel := MPFormModel():New("FINA024VA", Nil, {||F24VAOK()}, Nil, Nil)
	
	//Adiciona uma um submodel edit�vel/fields
	oModel:AddFields("FKUMASTER", Nil, oCabeca, Nil, Nil, Nil)
	oModel:AddGrid("FOUDETAIL",  "FKUMASTER", oDetail, Nil, Nil, Nil, Nil, Nil)
		
	//Relacionamento do model tabelas FKU -> FOU
	aAdd(aRelFKU, {"FOU_FILIAL", "xFilial('FOU')"} )
	aAdd(aRelFKU, {"FOU_IDRET",  "FKU_IDRET"} )
	oModel:SetRelation("FOUDETAIL", aRelFKU, FOU->(IndexKey(1)))
	oModel:GetModel( "FOUDETAIL" ):SetUniqueLine({"FOU_CODIGO"})
	
	//Bloqueia inclus�o de novas linhas na grid
	If __nOper != MODEL_OPERATION_INSERT   
		oModel:GetModel("FOUDETAIL"):SetNoInsertLine(.T.)
	EndIf
	
	//N�o permite deletar a linha da grid
	oModel:GetModel("FOUDETAIL"):SetNoDeleteLine(.T.)
	
	//Define a chave prim�ria do modelo
	oModel:SetPrimaryKey({"FKU_FILIAL", "FKU_IDRET"})
	oModel:SetDescription(STR0001) //Regra de Valores Acess�rios	
	
	//Inicializa os campo IDRET
	If (__nOper != MODEL_OPERATION_UPDATE .And. __nOper != MODEL_OPERATION_DELETE) 
		oCabeca:SetProperty("FKU_IDRET",   MODEL_FIELD_INIT, {||F24VAIDR(oModel)})
	EndIf
	
	If __nOper == MODEL_OPERATION_UPDATE
		oCabeca:SetProperty("FKU_CODIGO", MODEL_FIELD_WHEN,  {||.F.})
		oCabeca:SetProperty("FKU_DESCR",  MODEL_FIELD_WHEN, {||.T.})
		oModel:GetModel("FOUDETAIL"):SetNoUpdateLine(!__lAltAll)
	EndIf	
	
	//Ativa o modelo
	oModel:SetActivate()
Return oModel

//---------------------------------
/*/{Protheus.doc} ViewDef
Cria��o da View
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
	oModel := FWLoadModel("FINA024VA")
	oView  := FWFormView():New()
	
	oCabeca := FxStruct(2, cTblBrowse, Nil, Nil, {"FKU_IDRET"}, Nil)
	oDetail := FxStruct(2, "FOU",      Nil, Nil, {"FOU_IDRET"}, Nil)
	
	//Seta o modelo de dados a ser usado na view
	oView:SetModel(oModel)
	
	oView:createHorizontalBox("CABECA", 20, /*cIdOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
	oView:createHorizontalBox("DETAIL", 80, /*cIdOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)		
	
	//Adiciona na grid um controle de FormFields
	oView:AddField("VIEW_CABECA", oCabeca, "FKUMASTER")
	oView:AddGrid("GRID_DETAIL",  oDetail, "FOUDETAIL" )
	
	oView:SetOwnerView("VIEW_CABECA", "CABECA" )
	oView:SetOwnerView("GRID_DETAIL", "DETAIL" )
	
	//Consulta F3
	oDetail:SetProperty("FOU_CODIGO", MVC_VIEW_LOOKUP, {||F24VACF3()})
	
	oView:SetDescription(STR0001)
	oView:EnableTitleView("GRID_DETAIL", STR0016) //Itens da Regra de Valores Acess�rios	
	
	oDetail:SetProperty("FOU_CODIGO", MVC_VIEW_CANCHANGE, .F.)
	
	//Faz o refresh da view
	If (__nOper == MODEL_OPERATION_UPDATE .Or. __nOper == OPER_COPIAR)  
		oView:SetAfterViewActivate({|oView|F24VAREF(oView)})
	EndIf
Return oView


//---------------------------------
/*/{Protheus.doc} F24VAVIS
Define a opera��o de VISUALIZA��O
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
FIN024CVA()
/*/
//---------------------------------
Function F24VAVIS()

	Local aButtons As Array

	//Inicializa vari�veis
	__nOper := MODEL_OPERATION_VIEW
	
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	
	FWExecView(STR0005, "FINA024VA", MODEL_OPERATION_VIEW,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/ ) //Visualizar

Return Nil

//---------------------------------
/*/{Protheus.doc} F24VAINC
Define a opera��o de inclus�o
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
FIN024CVA()
/*/
//---------------------------------
Function F24VAINC()
	Local oModel   As Object
	Local aButtons As Array

	//Inicializa vari�veis
	oModel  := Nil
	__nOper := MODEL_OPERATION_INSERT
	
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	oModel := FwLoadModel("FINA024VA")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	
	F24VALOAD(oModel)
	oModel:GetModel("FOUDETAIL"):SetNoInsertLine(.T.)
	FWExecView(STR0002, "FINA024VA", MODEL_OPERATION_INSERT,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel ) //Incluir

	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
Return Nil

//---------------------------------
/*/{Protheus.doc} F24VAALT
Define a opera��o de altera��o
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
/*/
//---------------------------------
Function F24VAALT()
	Local aButtons As Array
	Local oModel   As Object
	Local cCodigo  As Character
	Local cIdRet   As Character	
	
	//Carrega o modelo de dados
	__nOper := MODEL_OPERATION_UPDATE
	oModel  := FwLoadModel("FINA024VA")
	oModel:Activate()	
	
	//Inicializa vari�veis
	cIdRet    := oModel:GetValue("FKUMASTER", "FKU_IDRET")
	cCodigo   := oModel:GetValue("FKUMASTER", "FKU_CODIGO")	
	__lAltAll := FinVldExc("FKK", "FKU", cIdRet, cCodigo)
	aButtons  := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	
	FWExecView(STR0003, "FINA024VA", MODEL_OPERATION_UPDATE,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, /*oModel*/ ) //Alterar
	
	__nOper      := 0
	__lAltAll := .F.
	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
Return Nil

//---------------------------------
/*/{Protheus.doc} F24VAEXC
Define a opera��o de exclus�o
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
/*/
//---------------------------------
Function F24VAEXC()
	Local oModel   As Object
	Local aButtons As Array
	Local lExclui  As Logical
	Local cCodigo  As Character
	Local cIdRet   As Character	
	
	//Carrega o modelo
	__nOper := MODEL_OPERATION_DELETE
	oModel   := FwLoadModel("FINA024VA")
	oModel:SetOperation(MODEL_OPERATION_DELETE)
	oModel:Activate()
	
	//Inicializa vari�veis
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	cIdRet   := oModel:GetValue("FKUMASTER", "FKU_IDRET")
	cCodigo  := oModel:GetValue("FKUMASTER", "FKU_CODIGO")	
	lExclui  := FinVldExc("FKK", "FKU", cIdRet, cCodigo)
	
	If lExclui
		FWExecView(STR0004,"FINA024VA", MODEL_OPERATION_DELETE,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel) //Excluir
	Else
		Help(" ", 1, "FA024EXC", Nil, STR0007, 2, 0,,,,,, {})
	Endif
	
	__nOper := 0
	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
	FKU->(DbSetOrder(2))
Return Nil

//---------------------------------
/*/{Protheus.doc} F024CODFKU()
Pos Validacao de preenchimento do c�digo do registro de reten��o
@author Sivaldo Oliveira
@since 10/09/2018
@version 12
/*/
//---------------------------------
Function F024CODFKU() As Logical
	Local lRet    As Logical
	Local oModel  As Object
	Local cCodigo As Character
	Local lAchou  As Logical
	Local cCab    As Character
	Local cDes    As Character
	Local cSol    As Character
	
	//Inicializa vari�veis
	lRet    := .F.
	oModel  := FWModelActive()
	cCodigo := oModel:GetValue("FKUMASTER", "FKU_CODIGO")
	lAchou  := .F.
	cCab    := ""
	cDes    := ""
	cSol    := ""
	
	If !Empty(cCodigo)
		FKU->(DbSetOrder(2))
		lAchou := FKU->(MSSeek(xFilial("FKU") + cCodigo))
	EndIf
	
	If __nOper != MODEL_OPERATION_INSERT .And. __nOper != OPER_COPIAR
		cCab := STR0008 //C�digo
		cDes := STR0009	//Opera��o n�o permitida
		cSol := STR0010	//Este campo n�o pode ser alterado
	ElseIf !FreeForUse("FKU", "FKU_CODIGO" + xFilial("FKU") + cCodigo)
		cCab := STR0008	//C�digo
		cDes := STR0011 + ": " + cCodigo + " " + STR0012 //O c�digo xxxx encontra-se em uso
		cSol := STR0013	//C�digo se encontra reservado
	ElseIf lAchou
		cCab := STR0008 //C�digo
		cDes := STR0011 + ": " + cCodigo + " " + STR0014 //O c�digo j� se encontram cadastrados
		cSol := STR0015	//Digite um novo c�digo
	Else
		lRet := .T.
	EndIf

	If !Empty(cCab+cDes+cSol)
		Help(" ", 1, cCab,, cDes ,2,0,,,,,, {cSol} )
	EndIf
Return lRet

//---------------------------------------
/*/{Protheus.doc} F24VACF3()
Consulta Padrao F3

@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24VACF3() As Character
	Local cRet As Character
	
	//Inicializa vari�veis
	cRet := ""
	
	/*
		A consulta s� ser� implementada quando os valores  acess�rios FKC forem contemplados no motor de reten��o
	*/
Return cRet

//---------------------------------------
/*/{Protheus.doc} F24VACOP()
Define operacao de C�pia de 

@author  Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F024CODFOU() As Logical
	Local lRet As Logical
	
	//Inicializa vari�veis
	lRet := .T.
	
	/*
		A valida��o do c�digo ser� feita quando os valores acess�rios forem contemplados no motor de reten��o
	*/
Return lRet 
//---------------------------------------
/*/{Protheus.doc} F24VACOP()
Define operacao de C�pia de 

@author  Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24VACOP()
	Local aButtons As Array
	
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	__nOper  := OPER_COPIAR
	__lFirst := .T.
	
	FWExecView(STR0006, "FINA024VA", OP_COPIA,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, /*oModel*/ )
	
	__nOper  := 0
	__lFirst := .F.
	FKU->(DbSetOrder(2))
Return

/*/{Protheus.doc} F24VAIDR()
Inicializador do campo FKU_IDRET
@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24VAIDR(oModel As Object)
	Local cRet   As Character
	Local aArea  As Array
	Local cChave As Character
	
	Default oModel  := FWModelActive() 
	
	//Inicializa vari�veis
	cRet   := ""
	cChave := ""
	
	If (__nOper != MODEL_OPERATION_UPDATE .And. __nOper != MODEL_OPERATION_DELETE)
		aArea  := FKU->(GetArea())
		
		While .T.
			cRet := FWUUIDV4()
			FKU->(DbSetOrder(1))
			cChave := (xFilial("FKU") + cRet)  
			If !(FKU->(MsSeek(cChave))) .And. FreeForUse("FKU", cRet)
				FKU->(RestArea(aArea))
				Exit	
			Endif
		EndDo
		
		RestArea(aArea)
	
		If __nOper == OPER_COPIAR .And. __lFirst
			oModel:LoadValue("FKUMASTER", "FKU_CODIGO", " ")
			oModel:LoadValue("FKUMASTER", "FKU_DESCR",  " ")
			__lFirst := .F.
		EndIf
	Else
		cRet := FKU->FKU_IDRET
	EndIf

Return cRet

//---------------------------------------
/*/{Protheus.doc} F024LoadFOU
Funcao de carregamento das informacoes de baixas

@param oGridModel - Model que chamou o bLoad
@author Mauricio Pequim Jr
@since 01/09/2017
@return Array com informacoes para composicao do grid
/*/
//---------------------------------------
Function F24VALOAD(oModel As Object)
	Local oFOU As Object
	Local nX   As Numeric

	oFOU := oModel:GetModel("FOUDETAIL")
	nX := 0

	If __aVAFixo == Nil
		__aVAFixo	:= {}
		aAdd(__aVAFixo, {"JUROS","Juros","1","1"} )
		aAdd(__aVAFixo, {"MULTA","Multa","1","1"} )
		aAdd(__aVAFixo, {"DESCON","Desconto","1","1"} )
		aAdd(__aVAFixo, {"ACRESC","Acr�scimo","1","1"} )
		aAdd(__aVAFixo, {"DECRES","Decr�scimo","1","1"} )
	Endif
	
	For nX := 1 to Len(__aVAFixo)
		If !oFOU:IsEmpty()
			oFOU:AddLine()		
			oFOU:GoLine( oFOU:Length() )	
		EndIf	
		
		oFOU:LoadValue("FOU_CODIGO", __aVAFixo[nX][1] )
		oFOU:LoadValue("FOU_ACAO",   __aVAFixo[nX][3] )
		oFOU:LoadValue("FOU_APLICA", __aVAFixo[nX][4] )
	Next
Return

//---------------------------------------
/*/{Protheus.doc} F24VAREF()
Atualiza a visualiza��o dos dados na view
@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24VAREF(oView As Object)
	oView:Refresh()
Return .T.

//---------------------------------------
/*/{Protheus.doc} F24VAOK()
P�s Valida��o do model 

@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24VAOK()
	Local lRet As Logical
	
	//Inicializa vari�veis
	lRet := .T.
	__lConfirmou := lRet
Return lRet