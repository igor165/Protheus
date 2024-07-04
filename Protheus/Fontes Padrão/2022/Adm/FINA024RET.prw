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
Regra de Retenção

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
		FxBrowse(cTblBrowse, 2, STR0001, aLegenda)		//"Regra de Retenção"	
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
	aTitMenu := { {STR0002, "F24RETCOP", OP_COPIA} }		//"Copiar"
	aActions := { {STR0003, "F24RETVIS"}, {STR0004, "F24RETINC"}, {STR0005, "F24RETALT"}, {STR0006, "F24RETEXC"}}	//"Visualizar"###"Incluir"###"Alterar"###"Excluir"
	aRotina := FxMenuDef(.T., aTitMenu, aActions)
Return aRotina

//---------------------------------
/*/{Protheus.doc} ModelDef
Modelo dados regra de retenção
@author  Sivaldo Oliveira
@since 21/08/25/08/2018
@version 12
/*/
//---------------------------------
Static Function ModelDef() As Object
	Local oModel  As Object
	Local oFKO    As Object
	Local aRelFKO As Array
	
	//Inicializa variáveis.
	oModel  := Nil
	aRelFKO := {}
	oFKO    := FxStruct(1, cTblBrowse)
	//Instacia o objeto 
	oModel := MPFormModel():New("FINA024RET", Nil, {||F2RETOK()}, Nil, Nil)
	//Adiciona uma um submodel editável/fields
	oModel:AddFields("FKOMASTER", Nil, oFKO, Nil, Nil, Nil)
	//Relacionamento do modelo de dados
	aAdd(aRelFKO, {"FKO_FILIAL", "xFilial('FKO')"})
	//Define a chave primária do modelo
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
Criação da View
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
/*/
//---------------------------------
Static Function ViewDef() As Object
	Local oModel As Object
	Local oView  As Object
	Local oFKO   As Object
	
	//Inicializa as variáveis
	oModel := FWLoadModel("FINA024RET")
	oView  := FWFormView():New()
	oFKO   := FxStruct(2, cTblBrowse, Nil, Nil, {"FKO_IDRET","FKO_IDFKT", "FKO_PARCTO"}, Nil)
	
	//Seta o modelo de dados a ser usado na view
	oView:SetModel(oModel)
	
	//Adiciona na grid um controle de FormFields
	oView:AddField("VIEW_FKO", oFKO, "FKOMASTER")
	oView:SetDescription(STR0001)	////"Regra de Retenção"	
	
	oFKO:SetProperty("FKO_CODFKT", MVC_VIEW_TITULO, "Regra de Cumulatividade")
	oFKO:SetProperty("FKO_CODFKT", MVC_VIEW_LOOKUP, {||F24RETCF3()})
	
	//Faz o refresh da view
	If (__nOper == MODEL_OPERATION_UPDATE .Or. __nOper == OPER_COPIAR)  
		oView:SetAfterViewActivate({|oView|F24RETREF(oView)})
	EndIf
Return oView


//---------------------------------
/*/{Protheus.doc} F24RETVIS
Define a operação de VISUALIZAÇÃO
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
/*/
//---------------------------------
Function F24RETVIS()
	Local oModel   As Object
	Local aButtons As Array

	//Inicializa variáveis
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
Define a operação de inclusão
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
/*/
//---------------------------------
Function F24RETINC()
	Local oModel   As Object
	Local aButtons As Array

	//Inicializa variáveis
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
Define a operação de alteração
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
	
	//Inicializa variáveis
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
Define a operação de exclusão
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
	
	//Verifica permissão de exclusão
	cIdRet  := oModel:GetValue("FKOMASTER", "FKO_IDRET")
	cCodigo := oModel:GetValue("FKOMASTER", "FKO_CODIGO")
	lExclui := FinVldExc("FKK", "FKO", cIdRet, cCodigo)
	
	If lExclui
		FWExecView( STR0006,"FINA024RET", MODEL_OPERATION_DELETE,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel )		//"Excluir"
	Else
		Help(" ", 1, "FA024EXC", Nil, STR0007, 2, 0,,,,,, {STR0008})	//"Exclusão não permitida."###"Verifique se esta regra de retenção não se encontra relacionada a uma regra financeira"
	Endif
	
	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
	FKO->(DbSetOrder(2))
Return Nil

//---------------------------------
/*/{Protheus.doc} F024CODFKO()
Pos Validacao de preenchimento do código do registro de retenção
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

	//Inicializa variáveis
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
		cCab := STR0009 //"Código"
		cDes := STR0010	//"Operação não permitida"
		cSol := STR0011	//"Este campo não pode ser alterado"
	ElseIf !FreeForUse("FKV", "FKV_CODIGO" + xFilial("FKV") + cCodigo)
		cCab := STR0009	//"Código"
		cDes := STR0012	//"O código digitado se encontra em uso"
		cSol := STR0013	//"Código se encontra reservado"
	ElseIf lAchou
		cCab := STR0007 //"Código"
		cDes := STR0014	//"O código já se encontram cadastrados"
		cSol := STR0015	//"Código já cadastrado"
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
	
	//Inicializa variáveis
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
Define operacao de Cópia de 

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
Pós Validação do model 

@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F2RETOK()
	Local lRet As Logical
	
	//Inicializa variáveis
	lRet := .T.
	__lConfirmou := lRet
Return lRet

//---------------------------------------
/*/{Protheus.doc} F24RETREF()
Atualiza a visualização dos dados na view
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
Permissão de edição de campos (When)

@param oGridModel - Model que chamou a validação
@param cCampo - Campo a ser validada permissão de edição

@author Mauricio Pequim Jr
@since 01/09/2017

@return Logico com permissão ou não de edição do campo
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
Valida o código da regra de cumulatividade  

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
	cCodigo := oModel:GetValue("FKOMASTER","FKO_CODFKT")
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
Inicicia padrão campo virtual FKO_DSCRCUM

@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24RETINI()
	Local oModel  As Object
	Local cCodigo As Character
	Local cRet    As Character
	
	//Inicializa variáveis
	oModel  := FWModelActive()
	cCodigo := oModel:GetValue("FKOMASTER", "FKO_CODFKT")
	cRet    := "" 
	
	If !Empty(cCodigo) 
		cRet := AllTrim(Posicione("FKT", 2, xFilial("FKT") + cCodigo, "FKT_DESCR"))
	EndIf

Return cRet