#Include 'Protheus.ch'
#Include "FWMVCDEF.CH"
#INCLUDE "FINA024CAL.CH"

Static cTblBrowse   := "FKN"
Static __nOper      := 0
Static __lConfirmou := .F.
Static __oPrepFKN
Static __lFirst		:= .T.
Static __lAltAll	:= .F.

#DEFINE OPER_ALTERAR  10
#DEFINE OPER_COPIAR	  12
#DEFINE OPER_IMPORTAR 13
#DEFINE OPER_EXPORTAR 14

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA024CAL
Regras de Vencimento

@author  Rodrigo Oliveira
@since 19/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function FINA024CAL(aRotAut As Array, nOpcAut)
	Local aLegenda As Array
	
	Default aRotAut := {} 
	Default nOpcAut := 0

	If Len(aRotAut) > 0
		FWMVCRotAuto(FWLoadModel("FINA024CAL"), cTblBrowse, nOpcAut, {{"FKNMASTER", aRotAut}}, , .T.)
	Else
		FxBrowse(cTblBrowse, 2, STR0001, aLegenda)
	EndIf
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu
@author  Rodrigo Oliveira
@since 19/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Static Function MenuDef() As Array
	Local aRotina  As Array
	Local aTitMenu As Array
	Local aActions As Array
	
	//Inicializa variáveis
	aTitMenu := { {STR0002, "F024FKNCOP", OP_COPIA} }
	aActions := { {STR0004, "F024FKNVIS"}, {STR0005, "F024FKNINC"}, {STR0003, "F024FKNALT"}, {STR0006, "F024FKNEXC"} }
	
	aRotina := FxMenuDef(.T., aTitMenu, aActions)
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados do detalhe de tipo de retenção
@author  Rodrigo Oliveira
@since 19/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Static Function ModelDef() As Object
	Local oModel  As Object
	Local oStruFKN As Object
	Local aRelFKN As Array
		
	//Inicializa variáveis.
	oModel  := Nil
	aRelFKN := {}
	
	oStruFKN := FxStruct(1, cTblBrowse)
	//Instacia o objeto 
	oModel := MPFormModel():New("FINA024CAL", Nil, {||F24CALOK()}, Nil, Nil)
	bFormPos	:= {||F024FKNPos()}

	// Adiciona ao modelo uma estrutura de formulario de edicao por campo
	oModel:AddFields( "FKNMASTER", /*cOwner*/, oStruFKN, /*bPreValidacao*/, bFormPos,  /*bLoad*/ )

	aAdd(aRelFKN, {"FKN_FILIAL", "xFilial('FKN')"})

	oModel:SetPrimaryKey( {"FKN_FILIAL","FKN_IDRET"} )

	//Complementa as informações da estrutura do model
	oStruFKN:SetProperty('FKN_IDRET'  , MODEL_FIELD_INIT , {|| F24CALIDR() } )
	oStruFKN:SetProperty('FKN_CODIGO' , MODEL_FIELD_WHEN , {|| F024FKNWHE(oModel,'FKN_CODIGO') } )
	
	If __nOper == OPER_ALTERAR
		oStruFKN:SetProperty('*' , MODEL_FIELD_WHEN , {|| __lAltAll } )
		oStruFKN:SetProperty('FKN_DESCR' , MODEL_FIELD_WHEN , {|| .T. } )
		oStruFKN:SetProperty('FKN_CODIGO' , MODEL_FIELD_WHEN , {|| .F. } )
	EndIf
		
	//Ativa o modelo
	oModel:SetActivate()
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Criação da View
@author  Rodrigo Oliveira
@since 19/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Static Function ViewDef() As Object
	Local oModel As Object
	Local oView  As Object
	Local oStruFKN   As Object
	
	//Inicializa as variáveis
	oModel := FWLoadModel("FINA024CAL")
	oView  := FWFormView():New()
	oStruFKN   := FxStruct(2, cTblBrowse, Nil, Nil, {"FKN_IDRET", "FKN_IDFKS", "FKN_IDFKV"}, Nil)
	
	//Seta o modelo de dados a ser usado na view
	oView:SetModel(oModel)
	
	//Adiciona na grid um controle de FormFields
	oView:AddField("VIEW_FKN", oStruFKN, "FKNMASTER")
	oView:SetDescription(STR0001)
	
	//Desabilita edição do campos
	
	oStruFKN:SetProperty( 'FKN_VLNOTA'	, MVC_VIEW_ORDEM,	'13')
	oStruFKN:SetProperty( 'FKN_CODFOS'	, MVC_VIEW_ORDEM,	'14')
	oStruFKN:SetProperty( 'FKN_DSCTAB'	, MVC_VIEW_ORDEM,	'15')
	oStruFKN:SetProperty( 'FKN_CODFOV'	, MVC_VIEW_ORDEM,	'16')
	oStruFKN:SetProperty( 'FKN_DSCREG'	, MVC_VIEW_ORDEM,	'17')
	
	oStruFKN:SetProperty( 'FKN_PORCEN'	, MVC_VIEW_TITULO    , "% Aliquota" )	
	oStruFKN:SetProperty( 'FKN_CODFOS'	, MVC_VIEW_TITULO    , "Tabela Progressiva" )	
	oStruFKN:SetProperty( 'FKN_CODFOV'	, MVC_VIEW_TITULO    , "Regra Dedução" )	
	
	//Consulta F3
	oStruFKN:SetProperty("FKN_CODFOS", MVC_VIEW_LOOKUP, {||F24CALCF3("FKN_CODFOS")})
	oStruFKN:SetProperty("FKN_CODFOV", MVC_VIEW_LOOKUP, {||F24CALCF3("FKN_CODFOV")})

	//Retira campos que não serao apresentados na View
	oStruFKN:RemoveField('FKN_VLNOTA') 

	If (__nOper == OPER_ALTERAR .Or. __nOper == OPER_COPIAR)  
		oView:SetAfterViewActivate({|oView|F024CALREF(oView)})
	EndIf
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKNVIS
Define a operação de inclusão
@author  Rodrigo Oliveira
@since 19/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKNVIS()
	Local oModel   As Object
	Local aButtons As Array

	//Inicializa variáveis
	oModel   := Nil
	aButtons := {}
	__nOper := MODEL_OPERATION_VIEW
	
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	oModel   := FwLoadModel("FINA024CAL")
	oModel:SetOperation(MODEL_OPERATION_VIEW)
	oModel:Activate()

	FWExecView( STR0004, "FINA024CAL", MODEL_OPERATION_VIEW,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel )

	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
	
	FKN->(DBSETORDER(2))	//"FKN_FILIAL+FKN_CODIGO"
	
Return




//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKNINC
Define a operação de inclusão
@author  Rodrigo Oliveira
@since 19/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKNINC()
	Local oModel   As Object
	Local aButtons As Array

	//Inicializa variáveis
	oModel   := Nil
	aButtons := {}
	__nOper := MODEL_OPERATION_INSERT
	
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	oModel   := FwLoadModel("FINA024CAL")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	FWExecView( OemToAnsi(STR0005), "FINA024CAL", MODEL_OPERATION_INSERT,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel )

	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
	
	FKN->(DBSETORDER(2))	//"FKN_FILIAL+FKN_CODIGO"
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKNALT
Define a operação de alteração
@author  Rodrigo Oliveira
@since 19/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKNALT()
	Local nRecFKN 	As Numeric
	Local nRecAtu 	As Numeric
	Local oModel 	As Object
	Local cCodigo  	As Character
	Local cIdRet   	As Character
	Local aEnableButtons As Array
	
	__nOper := OPER_ALTERAR
	//Carrega o modelo de dados
	oModel := FwLoadModel("FINA024CAL")
	oModel:Activate()
	
	//Inicializa variáveis
	cIdRet    := oModel:GetValue("FKNMASTER", "FKN_IDRET")
	cCodigo   := oModel:GetValue("FKNMASTER", "FKN_CODIGO")
	__lAltAll := FinVldExc("FKK", "FKN", cIdRet, cCodigo)
	aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"

	FWExecView( OemToAnsi(STR0003), "FINA024CAL", MODEL_OPERATION_UPDATE,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aEnableButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, /*oModel*/ ) //'Alterar'

	__nOper := 0
	__lAltAll := .F.
	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil

	FKN->(DBSETORDER(2))	//"FKN_FILIAL+FKN_CODIGO"
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKNEXC()
Define operacao de exclusao

@author  Rodrigo Oliveira
@since 19/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKNEXC()
	Local oModel	As Object
	Local nOpc		As Numeric
	Local cIdRet	As Character
	Local cCodigo	As Character
	Local lExclui	As Logical
	Local aEnableButtons	As Array
	
	aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"

	nOpc := MODEL_OPERATION_DELETE

	oModel := FwLoadModel("FINA024CAL")
	oModel:SetOperation(nOpc)
	oModel:Activate()

	cIdRet   := oModel:GetValue("FKNMASTER", "FKN_IDRET")
	cCodigo  := oModel:GetValue("FKNMASTER", "FKN_CODIGO")
		
	lExclui		:= FinVldExc("FKK", "FKN", cIdRet, cCodigo)

	If lExclui
		FWExecView( OemToAnsi(STR0006),"FINA024CAL", nOpc,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aEnableButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel ) //'Excluir'
	Else
		HELP(' ',1,"FA024EXC" ,,STR0007,2,0,,,,,, {STR0008})	//"Exclusão não permitida."###"Regra de Cálculo relacionada a uma Regra Financeira não pode ser excluída."
	Endif
	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
	FKN->(DBSETORDER(2))	//"FKN_FILIAL+FKN_CODIGO"
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKNCOP()
Define operacao de CÓPIA

@author  Rodrigo Oliveira
@since 19/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKNCOP()
	Local nOpc		As Numeric
	Local aEnableButtons	As Array

	aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"

	nOpc := OP_COPIA 

	__nOper := OPER_COPIAR
	__lConfirmou := .F.

	FWExecView( OemToAnsi(STR0002), "FINA024CAL", nOpc,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aEnableButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, /*oModel*/ ) //'Copiar'

	__lConfirmou := .F.
	__nOper := 0

	FKN->(DBSETORDER(2))	//"FKN_FILIAL+FKN_CODIGO"
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKNKPos()
Pos Validacao de preenchimento do FORM

@author Rodrigo Oliveira
@since	19/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKNPos() As Logical
	Local lRet As Logical
	Local oModel, oFKN As Object

	oModel		:= FWModelActive()
	oFKN 		:= oModel:GetModel("FKNMASTER")
	lRet		:= .T.

	If __nOper == MODEL_OPERATION_INSERT

		DBSelectArea("FKN")
		FKN->( DbSetOrder(1) )

		If FKN->( DbSeek( xFilial("FKN")+oFKN:GetValue("FKN_IDRET") ) )
			HELP(" ",1,"FA024DUP",,STR0009,1,0)	//"Regra de cálculo já cadastrada."
			lRet	:= .F.
		EndIf

	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F24CALVLB()
P¢s Validacao de preenchimento do campo Percentual Base

@author Rodrigo Oliveira
@since	19/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function FIN024VLB() As Logical
	Local lRet As Logical
	Local oModel As Object

	oModel := FWModelActive()
	lRet := POSITIVO(oModel:GetValue('FKNMASTER','FKN_PCBASE'))
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F24CALVLP()
Pós Validacao de preenchimento do campo Percentual do Imposto

@author Rodrigo Oliveira
@since	19/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function FIN024VLP() As Logical
	Local lRet As Logical
	Local oModel As Object

	oModel := FWModelActive()
	lRet := POSITIVO(oModel:GetValue('FKNMASTER','FKN_PORCEN'))
Return lRet

//---------------------------------------
/*/{Protheus.doc} ExibeHelp()
Atualiza a visualização dos dados na view
@author Rodrigo Oliveira
@since	19/09/2018
@version 12
/*/
//---------------------------------------
Function F024CALREF(oView As Object)
	oView:Refresh()
Return .T.

//---------------------------------------
/*/{Protheus.doc} F24CALCF3()
Consulta Padrao F3

@author Rodrigo Oliveira
@since	19/09/2018
@version 12
/*/
//---------------------------------------
Static Function F24CALCF3(cCampo As Character) AS Character
	Local oModel    As Object
	Local oFKN      As Object
	Local cF3       As Character
	
	Default cCampo := "" 
	
	//Inicializa variáveis
	oModel    := FWModelActive()
	oFKN      := oModel:GetModel("FKNMASTER")
	cF3       := ""
	
	cCampo := AllTrim(cCampo)
	
	If cCampo == "FKN_CODFOV"
		cF3 := "FKV"
	ElseIf cCampo == "FKN_CODFOS" 
		cF3 := "FKS"  
	EndIf
Return cF3

//---------------------------------
/*/{Protheus.doc} F024CODFKN()
Pos Validacao de preenchimento do código do registro de retenção

@author Rodrigo Oliveira
@since 19/09/2018
@version 12
/*/
//---------------------------------
Function F024CODFKN() As Logical
	Local lRet    As Logical
	Local oModel  As Object
	Local oFKN    As Object
	Local cCodigo As Character
	Local lAchou  As Logical
	Local cCab    As Character
	Local cDes    As Character
	Local cSol    As Character
	Local aArea	  As Array 
	

	//Inicializa variáveis
	oModel  := FWModelActive()
	oFKN    := oModel:GetModel("FKNMASTER")
	cCodigo := oFKN:GetValue("FKN_CODIGO")
	cCab	:= ""
	cDes	:= ""
	cSol	:= ""

	lRet   := .F.
	lAchou := .F.

	If !Empty(cCodigo)
		aArea  := FKN->(GetArea())		
		FKN->(DbSetOrder(2))
		If FKN->(MSSeek(xFilial("FKN") + cCodigo))
			lAchou := .T.
		Endif
		FKN->(RestArea(aArea))
	EndIf
	
	If __nOper != MODEL_OPERATION_INSERT .And. __nOper != OPER_COPIAR
		cCab := STR0010 //Código
		cDes := STR0011	//Operação não permitida
		cSol := STR0012	//Este campo não pode ser alterado
	ElseIf !FreeForUse("FKN", "FKN_CODIGO" + xFilial("FKN") + cCodigo)
		cCab := STR0010	//Código
		cDes := STR0013	+ ": " + cCodigo + " " + STR0017	//O código encontra - se em uso
		cSol := STR0014	//Código se encontra reservado
	ElseIf lAchou
		cCab := STR0010 //Código
		cDes := STR0013 + ": " + cCodigo + " " + STR0018	//O código já se encontra cadastrado
		cSol := STR0019	//Digite um novo código
	Else
		lRet := .T.
	EndIf

	If !Empty(cCab+cDes+cSol)
		HELP(' ',1, cCab ,, cDes ,2,0,,,,,, {cSol} )
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/ {Protheus.doc} F024FKNWhe
Permissão de edição de campos (When)

@param oGridModel - Model que chamou a validação
@param cCampo - Campo a ser validada permissão de edição

@author Rodrigo Oliveira
@since 19/09/2018

@return Logico com permissão ou não de edição do campo
/*/
//-------------------------------------------------------------------
Function F024FKNWhe(oModel As Object, cCampo As Character)

	Local lRet As Logical
	
	DEFAULT oModel := NIL
	DEFAULT cCampo := ""
	
	If oModel == Nil
		oModel   := FWModelActive()
	EndIf
	
	lRet := .T.
	
	If cCampo == "FKN_CODIGO" .AND. __nOper == OPER_ALTERAR
		lRet := .F.
	Endif
	
	If __lFirst .And. __nOper == OPER_COPIAR .And. cCampo == "FKN_CODIGO"
		oModel:LoadValue("FKNMASTER", "FKN_CODIGO", "")
		oModel:LoadValue("FKNMASTER", "FKN_DESCR", "")
		__lFirst	:= .F.
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FIN024FOS()
Validação do campo FKN_CODFOS

@author Rodrigo Oliveira
@since	19/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function FIN024FOS()
	Local lRet As Logical
	Local oModel As Object
	Local cCodigo As Character
	Local aArea As Array
	
	oModel := FWModelActive()
	cCodigo := oModel:GetValue("FKNMASTER","FKN_CODFOS")
	lRet := .F.
	
	If !Empty(cCodigo )
		aArea := GetArea()
		lRet := ExistCpo("FKS", cCodigo, 2)
		If lRet
			oModel:LoadValue('FKNMASTER','FKN_IDFKS', FKS->FKS_IDRET)
		Endif 
		RestArea(aArea)
	Else
		lRet	:= .T.
	Endif
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FIN024FOV()
Validação do campo FKN_CODFOV

@author Rodrigo Oliveira
@since	19/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function FIN024FOV()
	Local lRet As Logical
	Local oModel As Object
	Local cCodigo As Character
	Local aArea As Array
	
	oModel := FWModelActive()
	cCodigo := oModel:GetValue("FKNMASTER","FKN_CODFOV")
	lRet := .F.
	
	If !Empty(cCodigo )
		aArea := GetArea()
		lRet := ExistCpo("FKV", cCodigo, 2)
		If lRet
			oModel:LoadValue('FKNMASTER','FKN_IDFKV', FKV->FKV_IDRET)
		Endif
		RestArea(aArea)
	Else
		lRet	:= .T.
	Endif
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F24CALIDR()
Pos Validacao de preenchimento do código do registro de retenção

@author Rodrigo Oliveira
@since	19/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F24CALIDR(oModel As Object)
	Local cRet   As Character
	Local aArea  As Array
	Local cChave As Character
	//Inicializa variáveis
	cRet   := ""
	cChave := ""
	If (__nOper == MODEL_OPERATION_INSERT .OR. __nOper == OPER_ALTERAR .OR. __nOper == OPER_COPIAR)
		aArea  := FKN->(GetArea())
		While .T.
			cRet := FWUUIDV4()
			FKN->(DbSetOrder(1))
			cChave := (xFilial("FKN") + cRet)  
			If !(FKN->(MsSeek(cChave))) .And. FreeForUse("FKN", cRet)
				FKN->(RestArea(aArea))
				Exit	
			Endif
		EndDo
		RestArea(aArea)
	Else
		cRet := FKN->FKN_IDRET
	EndIf
Return cRet

//---------------------------------------
/*/{Protheus.doc} F24CALINI()

@author Rodrigo Oliveira
@since	19/09/2018
@version 12
/*/
//---------------------------------------
Function F24CALINI(cCampo As Character)
	Local oModel  As Object
	Local oFKN    As Object
	Local nOper   As Numeric
	Local cCodigo As Character
	
	Default cCampo := "" 
	
	//Inicializa variáveis
	oModel  := FWModelActive()
	oFKN    := oModel:GetModel("FKNMASTER")
	nOper   := oModel:GetOperation()
	
	cRet    := ""
	
	If cCampo == 'FKN_DSCTAB'
		cCodigo := oFKN:GetValue("FKN_CODFOS")
		cRet 	:= Posicione("FKS", 2, xFilial("FKS") + cCodigo, "FKS_DESCR")
	Else
		cCodigo := oFKN:GetValue("FKN_CODFOV")
		cRet 	:= Posicione("FKV", 2, xFilial("FKV") + cCodigo, "FKV_DESCR")
	EndIf
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F24CALOK()
Pós Validacao do model

@author Rodrigo Oliveira
@since 19/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Static Function F24CALOK() As Logical
	Local lRet As Logical
	Local oModel As Object
	Local aAreaFKN As Array
	Local nRecFKN As Numeric

	lRet := .T.
	oModel := FWModelActive()
	nOper := oModel:GetOperation()
	aAreaFKN := FKN->(GetArea())
	lRet	:= .T.

	If nOper == MODEL_OPERATION_INSERT

		DBSelectArea("FKN")
		FKN->( DbSetOrder(1) )

		If FKN->( DbSeek( xFilial("FKN")+oModel:GetValue("FKNMASTER","FKN_IDRET") ) )
			HELP(" ",1,"FA024CAL1",,STR0009,1,0)	//"Regra de cálculo já cadastrada."
			lRet	:= .F.
		EndIf

	EndIf

	If lRet
		//verifica se foi preenchida uma regra de cálculo ou tabela progressiva
		If oModel:GetValue("FKNMASTER","FKN_PORCEN") == 0 .and. Empty(oModel:GetValue("FKNMASTER","FKN_IDFKS"))
			HELP(" ",1,"FA024CAL2",,"É necessário que seja informado ou um porcentual ou uma tabela progressiva para que se efetue calculo.",2,0,,,,,, {"Informe valores para os campos %Aliquota ou Tabela Progressiva"})
			lRet	:= .F.
		EndIf
	Endif

	__lConfirmou := lRet

	FKN->(RestArea(aAreaFKN))
Return lRet