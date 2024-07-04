#Include 'Protheus.ch'
#Include "FWMVCDEF.CH"
#INCLUDE "FINA024RET.CH"

Static cTblBrowse   := "FKO"
Static __nOper      := 0
Static __lConfirmou := .F.
Static __lFirst		:= .F.
Static __lAltAll	:= .F.

#DEFINE OPER_ATIVAR	  11
#DEFINE OPER_COPIAR	  12


//---------------------------------
/*/{Protheus.doc} FINA024RET
Regra de Reten��o

@author  Sivaldo Oliveira
@since 21/08/25/08/2018
@version 12
/*/
//---------------------------------
Function FINA024RET(aRotAut As Array, nOpcAut)
	Local aLegenda As Array
	
	Default aRotAut := {} 
	Default nOpcAut := 0
	
	If Len(aRotAut) > 0
		FWMVCRotAuto(FWLoadModel("FINA024RET"), cTblBrowse, nOpcAut, {{"FKOMASTER", aRotAut}}, , .T.)
	Else
		FxBrowse(cTblBrowse, 2, STR0001, aLegenda)		//"Regra de Reten��o"	
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
	aTitMenu := { {STR0002, "F24RETCOP", OP_COPIA} }		//"Copiar"
	aActions := { {STR0003, "F24RETVIS"}, {STR0004, "F24RETINC"}, {STR0005, "F24RETALT"}, {STR0006, "F24RETEXC"}}	//"Visualizar"###"Incluir"###"Alterar"###"Excluir"
	aRotina := FxMenuDef(.T., aTitMenu, aActions)
Return aRotina

//---------------------------------
/*/{Protheus.doc} ModelDef
Modelo dados regra de reten��o
@author  Sivaldo Oliveira
@since 21/08/25/08/2018
@version 12
/*/
//---------------------------------
Static Function ModelDef() As Object
	Local oModel  As Object
	Local oFKO    As Object
	Local aRelFKO As Array
	
	//Inicializa vari�veis.
	oModel  := Nil
	aRelFKO := {}
	oFKO    := FxStruct(1, cTblBrowse)
	//Instacia o objeto 
	oModel := MPFormModel():New("FINA024RET", Nil, {||F2RETOK()}, Nil, Nil)
	//Adiciona uma um submodel edit�vel/fields
	oModel:AddFields("FKOMASTER", Nil, oFKO, Nil, Nil, Nil)
	//Relacionamento do modelo de dados
	aAdd(aRelFKO, {"FKO_FILIAL", "xFilial('FKO')"})
	//Define a chave prim�ria do modelo
	oModel:SetPrimaryKey({"FKO_FILIAL", "FKO_IDRET"})
	
	//Inicializa os campo IDRET/VERSAO
	oFKO:SetProperty("FKO_IDRET",  MODEL_FIELD_INIT, {||F24RETIDR()})
	oFKO:SetProperty('FKO_CODIGO', MODEL_FIELD_WHEN, {||F24FKOWHE(oModel,'FKO_CODIGO') } )
	
	If __nOper == MODEL_OPERATION_UPDATE
		oFKO:SetProperty('*' , MODEL_FIELD_WHEN , {|| __lAltAll } )
		oFKO:SetProperty('FKO_DESCR' , MODEL_FIELD_WHEN , {|| .T. } )
		oFKO:SetProperty('FKO_CODIGO' , MODEL_FIELD_WHEN , {|| .F. } )
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
	Local oModel As Object
	Local oView  As Object
	Local oFKO   As Object
	
	//Inicializa as vari�veis
	oModel := FWLoadModel("FINA024RET")
	oView  := FWFormView():New()
	oFKO   := FxStruct(2, cTblBrowse, Nil, Nil, {"FKO_IDRET","FKO_IDFKT", "FKO_PARCTO"}, Nil)
	
	//Seta o modelo de dados a ser usado na view
	oView:SetModel(oModel)
	
	//Adiciona na grid um controle de FormFields
	oView:AddField("VIEW_FKO", oFKO, "FKOMASTER")
	oView:SetDescription(STR0001)	////"Regra de Reten��o"	
	
	oFKO:SetProperty("FKO_CODFKT", MVC_VIEW_TITULO, "Regra de Cumulatividade")
	oFKO:SetProperty("FKO_CODFKT", MVC_VIEW_LOOKUP, {||F24RETCF3()})
	
	//Faz o refresh da view
	If (__nOper == MODEL_OPERATION_UPDATE .Or. __nOper == OPER_COPIAR)  
		oView:SetAfterViewActivate({|oView|F24RETREF(oView)})
	EndIf
Return oView


//---------------------------------
/*/{Protheus.doc} F24RETVIS
Define a opera��o de VISUALIZA��O
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
/*/
//---------------------------------
Function F24RETVIS()
	Local oModel   As Object
	Local aButtons As Array

	//Inicializa vari�veis
	oModel   := Nil
	__nOper  := MODEL_OPERATION_VIEW
	
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	oModel := FwLoadModel("FINA024RET")
	oModel:SetOperation(MODEL_OPERATION_VIEW)
	oModel:Activate()

	FWExecView( STR0003, "FINA024RET", MODEL_OPERATION_VIEW,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel )		//"Incluir"
	
	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
Return



//---------------------------------
/*/{Protheus.doc} F24RETINC
Define a opera��o de inclus�o
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
/*/
//---------------------------------
Function F24RETINC()
	Local oModel   As Object
	Local aButtons As Array

	//Inicializa vari�veis
	oModel   := Nil
	__nOper  := MODEL_OPERATION_INSERT
	
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	oModel := FwLoadModel("FINA024RET")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	FWExecView( STR0004, "FINA024RET", MODEL_OPERATION_INSERT,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel )		//"Incluir"
	
	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
Return

//---------------------------------
/*/{Protheus.doc} F24RETALT
Define a opera��o de altera��o
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
/*/
//---------------------------------
Function F24RETALT()
	Local aButtons As Array
	Local nRegAnt  As Numeric
	Local cCodigo  	As Character
	Local cIdRet   	As Character
	
	__nOper := MODEL_OPERATION_UPDATE
	//Carrega o modelo de dados
	oModel := FwLoadModel("FINA024RET")
	oModel:Activate()	
	
	//Inicializa vari�veis
	aButtons  := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	cIdRet    := oModel:GetValue("FKOMASTER", "FKO_IDRET")
	cCodigo   := oModel:GetValue("FKOMASTER", "FKO_CODIGO")
	__lAltAll := FinVldExc("FKK", "FKO", cIdRet, cCodigo)
	
	FWExecView(STR0005, "FINA024RET", MODEL_OPERATION_UPDATE,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, /*oModel*/ )		//"Alterar"
	
	__nOper      := 0
	__lAltAll := .F.
	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
Return Nil

//---------------------------------
/*/{Protheus.doc} F24RETEXC
Define a opera��o de exclus�o
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
/*/
//---------------------------------
Function F24RETEXC()
	Local oModel   As Object
	Local aButtons As Array
	Local lExclui  As Logical 
	Local cIdRet	As Character
	Local cCodigo	As Character
	
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	oModel   := FwLoadModel("FINA024RET")
	oModel:SetOperation(MODEL_OPERATION_DELETE)
	oModel:Activate()
	
	//Verifica permiss�o de exclus�o
	cIdRet  := oModel:GetValue("FKOMASTER", "FKO_IDRET")
	cCodigo := oModel:GetValue("FKOMASTER", "FKO_CODIGO")
	lExclui := FinVldExc("FKK", "FKO", cIdRet, cCodigo)
	
	If lExclui
		FWExecView( STR0006,"FINA024RET", MODEL_OPERATION_DELETE,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel )		//"Excluir"
	Else
		Help(" ", 1, "FA024EXC", Nil, STR0007, 2, 0,,,,,, {STR0008})	//"Exclus�o n�o permitida."###"Verifique se esta regra de reten��o n�o se encontra relacionada a uma regra financeira"
	Endif
	
	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
	FKO->(DbSetOrder(2))
Return Nil

//---------------------------------
/*/{Protheus.doc} F024CODFKO()
Pos Validacao de preenchimento do c�digo do registro de reten��o
@author Sivaldo Oliveira
@since 10/09/2018
@version 12
/*/
//---------------------------------
Function F024CODFKO() As Logical
	Local lRet    As Logical
	Local oModel  As Object
	Local oFKO    As Object
	Local cCodigo As Character
	Local lAchou  As Logical
	Local cCab    As Character
	Local cDes    As Character
	Local cSol    As Character
	Local aArea  As Array

	//Inicializa vari�veis
	oModel  := FWModelActive()
	oFKO    := oModel:GetModel("FKOMASTER")
	cCodigo := oFKO:GetValue("FKO_CODIGO")
	cCab	:= ""
	cDes	:= ""
	cSol	:= ""
	lRet   	:= .F.
	lAchou 	:= .F.

	If !Empty(cCodigo)
		aArea  := FKO->(GetArea())
		FKO->(DbSetOrder(2))
		If FKO->(MSSeek(xFilial("FKO") + cCodigo))
			lAchou := .T.
		Endif	
		FKO->(RestArea(aArea))
	EndIf
	
	If __nOper != MODEL_OPERATION_INSERT .And. __nOper != OPER_COPIAR
		cCab := STR0009 //"C�digo"
		cDes := STR0010	//"Opera��o n�o permitida"
		cSol := STR0011	//"Este campo n�o pode ser alterado"
	ElseIf !FreeForUse("FKV", "FKV_CODIGO" + xFilial("FKV") + cCodigo)
		cCab := STR0009	//"C�digo"
		cDes := STR0012	//"O c�digo digitado se encontra em uso"
		cSol := STR0013	//"C�digo se encontra reservado"
	ElseIf lAchou
		cCab := STR0007 //"C�digo"
		cDes := STR0014	//"O c�digo j� se encontram cadastrados"
		cSol := STR0015	//"C�digo j� cadastrado"
	Else
		lRet := .T.
	EndIf

	If !Empty(cCab+cDes+cSol)
		HELP(' ',1, cCab ,, cDes ,2,0,,,,,, {cSol} )
	EndIf
Return lRet

//---------------------------------------
/*/{Protheus.doc} F24RETIDR()
Inicializador do campo FKO_IDRET
@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24RETIDR()
	Local cRet   As Character
	Local aArea  As Array
	Local cChave As Character
	
	//Inicializa vari�veis
	cRet   := ""
	cChave := ""
	
	If (__nOper == MODEL_OPERATION_INSERT .OR. __nOper == MODEL_OPERATION_UPDATE .OR. __nOper == OPER_COPIAR)
		aArea  := FKO->(GetArea())
		
		While .T.
			cRet := FWUUIDV4()
			FKO->(DbSetOrder(2))
			cChave := (xFilial("FKO") + cRet)  
			If !(FKO->(MsSeek(cChave))) .And. FreeForUse("FKO", cRet)
				FKO->(RestArea(aArea))
				Exit	
			Endif
		EndDo

		RestArea(aArea)
	Else
		cRet := FKO->FKO_IDRET
	EndIf

Return cRet


//---------------------------------------
/*/{Protheus.doc} F24RETCOP()
Define operacao de C�pia de 

@author  Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24RETCOP()
	Local aButtons As Array
	
	aButtons     := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	__nOper      := OPER_COPIAR
	__lConfirmou := .F.
	__lFirst := .T.
	
	FWExecView( STR0002, "FINA024RET", OP_COPIA,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, /*oModel*/ )		//"Copiar"

	__lFirst := .F.
	__lConfirmou := .F.
	__nOper      := 0

	FKO->(DbSetOrder(2))
Return

//---------------------------------------
/*/{Protheus.doc} F2RETOK()
P�s Valida��o do model 

@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F2RETOK()
	Local lRet As Logical
	
	//Inicializa vari�veis
	lRet := .T.
	__lConfirmou := lRet
Return lRet

//---------------------------------------
/*/{Protheus.doc} F24RETREF()
Atualiza a visualiza��o dos dados na view
@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24RETREF(oView As Object)
	oView:Refresh()
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKOVER()
Inicializador padr?o do campo FKP_VERSAO

@author Mauricio Pequim Jr
@since	25/08/2017
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKOVER(oModel As Object) As Character
	
	DEFAULT oModel := NIL
	
	If __nOper == OPER_COPIAR .and. __lFirst
		If oModel != NIL
			oModel:LoadValue("FKOMASTER","FKO_CODIGO","")
			oModel:LoadValue("FKOMASTER","FKO_DESCR" ,"")
		EndIf
	EndIF

Return 


//-------------------------------------------------------------------
/*/ {Protheus.doc} F24FKOWhe
Permiss�o de edi��o de campos (When)

@param oGridModel - Model que chamou a valida��o
@param cCampo - Campo a ser validada permiss�o de edi��o

@author Mauricio Pequim Jr
@since 01/09/2017

@return Logico com permiss�o ou n�o de edi��o do campo
/*/
//-------------------------------------------------------------------
Function F24FKOWhe(oModel As Object, cCampo As Character)
	Local lRet As Logical
	Local cCodigo As Character
	Local cIdRet As Character

	DEFAULT oModel := NIL
	DEFAULT cCampo := ""
	
	lRet := .T.
	cCodigo := ""
	cIdRet := ""

	If cCampo == "FKO_CODIGO" 
		If __nOper == MODEL_OPERATION_UPDATE
			lRet := .F.
		Endif
	
		If lRet .and. __nOper == OPER_COPIAR .and. __lFirst
			F024FKOVER(oModel)
			__lFirst := .F.
		EndIf
	
	Endif

Return lRet

//---------------------------------------
/*/{Protheus.doc} F24RETCF3()
Consulta F3  

@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24RETCF3()
	Local cF3    As Character
	
	cF3 := "FKT" //Regra de Cumulatividade
Return cF3

//---------------------------------------
/*/{Protheus.doc} FIN024FKT()
Valida o c�digo da regra de cumulatividade  

@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function FIN024FKT()
	Local lRet    As Logical
	Local oModel  As Object
	Local cCodigo As Character
	Local aArea   As Array
	
	oModel := FWModelActive()
	cCodigo�:=�oModel:GetValue("FKOMASTER","FKO_CODFKT")
	lRet := .F.
	
	If !Empty(cCodigo )
		aArea := GetArea()
		lRet := ExistCpo("FKT", cCodigo, 2)
		
		If lRet
			oModel:LoadValue("FKOMASTER", "FKO_IDFKT", FKT->FKT_IDRET)
		Endif 
		
		RestArea(aArea)
	Else
		lRet	:= .T.
	Endif

Return lRet

//---------------------------------------
/*/{Protheus.doc} F24RETINI()
Inicicia padr�o campo virtual FKO_DSCRCUM

@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24RETINI()
	Local oModel  As Object
	Local cCodigo As Character
	Local cRet    As Character
	
	//Inicializa vari�veis
	oModel  := FWModelActive()
	cCodigo := oModel:GetValue("FKOMASTER", "FKO_CODFKT")
	cRet    := "" 
	
	If !Empty(cCodigo) 
		cRet := AllTrim(Posicione("FKT", 2, xFilial("FKT") + cCodigo, "FKT_DESCR"))
	EndIf

Return cRet