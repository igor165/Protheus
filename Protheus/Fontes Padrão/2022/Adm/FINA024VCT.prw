#Include 'Protheus.ch'
#Include "FWMVCDEF.CH"
#INCLUDE "FINA024VCT.CH"

#DEFINE OPER_ALTERAR		10
#DEFINE OPER_COPIAR			11

Static cTblBrowse   := "FKP"
Static __nOper      := 0		 // Operacao da rotina
Static __lConfirmou := .F.
Static __oPrepFKP	:= NIL
Static __lFirst		:= .F.
Static __lBlind		:= IsBlind()
Static __lAltAll	:= .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA024VCT
Regras de Vencimento

@author  Mauricio Pequim Jr
@since 18/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function FINA024VCT(aRotAut As Array, nOpcAut)
	Local aLegenda As Array
	
	Default aRotAut := {} 
	Default nOpcAut := 0

	//Verifico se as tabelas existem antes de prosseguir
	IF AliasIndic("FKP")

		If Len(aRotAut) > 0
			FWMVCRotAuto(FWLoadModel("FINA024VCT"), cTblBrowse, nOpcAut, {{"FKPMASTER", aRotAut}}, , .T.)
		Else
			FxBrowse(cTblBrowse, 2, STR0001 , aLegenda)		//"Regras de Vencimento"
		EndIf

		If __oPrepFKP != NIL
			__oPrepFKP:Destroy()
			__oPrepFKP := NIL
		Endif
	Else
	    Help("",1,"Help","Help",STR0002 ,1,0)		//'Dicionário desatualizado, verifique as atualizações do motor tributário Financeiro'
	EndIf

Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu
@author  Mauricio Pequim Jr
@since 18/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Static Function MenuDef() As Array
	Local aRotina  As Array
	Local aTitMenu As Array
	Local aActions As Array
	
	//Inicializa variáveis
	aTitMenu := { {STR0003, "F024FKPCOP", OP_COPIA} }
	aActions := { {STR0004, "F024FKPVIS"}, {STR0005, "F024FKPINC"}, {STR0007, "F024FKPALT"}, {STR0006, "F024FKPEXC"} }
	aRotina := FxMenuDef(.T., aTitMenu, aActions)

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados do detalhe de tipo de retenção
@author  Mauricio Pequim Jr
@since 18/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Static Function ModelDef() As Object
	Local oModel  As Object
	Local oStruFKP As Object
	Local aRelFKP As Array
	
	//Inicializa variáveis.
	oModel  := Nil
	aRelFKP := {}
	oStruFKP := FxStruct(1, cTblBrowse)
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("FINA024VCT", /*bPreValidacao*/, {||F024VCTTOK()} /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulario de edicao por campo
	oModel:AddFields( "FKPMASTER", /*cOwner*/, oStruFKP, /*bPreValidacao*/, /*bPosValidacao*/,  /*bLoad*/ )

	//Define a chave primária do modelo
	oModel:SetPrimaryKey({"FKP_FILIAL", "FKP_IDRET"})

	//Complementa as informações da estrutura do model
	oStruFKP:SetProperty('FKP_IDRET'  , MODEL_FIELD_INIT , {|| F024FKPRET() } )
	oStruFKP:SetProperty('FKP_CODIGO' , MODEL_FIELD_WHEN , {|| F024FKPWHE(oModel,'FKP_CODIGO') } )
	oStruFKP:SetProperty('FKP_PRDVCT' , MODEL_FIELD_WHEN , {|| F024FKPWHE(oModel,'FKP_PRDVCT') } )
	oStruFKP:SetProperty('FKP_QTPERI' , MODEL_FIELD_WHEN , {|| F024FKPWHE(oModel,'FKP_QTPERI') } )
	oStruFKP:SetProperty('FKP_DATVCT' , MODEL_FIELD_WHEN , {|| F024FKPWHE(oModel,'FKP_DATVCT') } )

	If __nOper == OPER_ALTERAR
		oStruFKP:SetProperty('FKP_DIAVCT' , MODEL_FIELD_WHEN , {|| __lAltAll } )
		oStruFKP:SetProperty('FKP_TIPVCT' , MODEL_FIELD_WHEN , {|| __lAltAll } )
		oStruFKP:SetProperty('FKP_DTVLVC' , MODEL_FIELD_WHEN , {|| __lAltAll } )
		oStruFKP:SetProperty('FKP_DESCR'  , MODEL_FIELD_WHEN , {|| .T. } )
		oStruFKP:SetProperty('FKP_CODIGO' , MODEL_FIELD_WHEN , {|| .F. } )
	EndIf
	
	//Ativa o modelo
	oModel:SetActivate()

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Criação da View
@author  Mauricio Pequim Jr
@since 18/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Static Function ViewDef() As Object
	Local oModel As Object
	Local oView  As Object
	Local oStruFKP   As Object
	
	//Inicializa as variáveis
	oModel := FWLoadModel("FINA024VCT")
	oView  := FWFormView():New()
	oStruFKP   := FxStruct(2, cTblBrowse, Nil, Nil, /*{"FKP_IDRET"}*/, Nil)
	
	//Seta o modelo de dados a ser usado na view
	oView:SetModel(oModel)
	
	//Adiciona na grid um controle de FormFields
	oView:AddField("VIEW_FKP", oStruFKP, "FKPMASTER")
	oView:SetDescription(STR0001)				//"Regras de Vencimento"

	oStruFKP:SetProperty( 'FKP_BASEVC'	, MVC_VIEW_TITULO    , "Data base p/ vencto. do imposto (Emissão)")

	oStruFKP:RemoveField('FKP_IDRET')
	
	If __nOper == OPER_ALTERAR .OR. __nOper == OPER_COPIAR
		oView:SetAfterViewActivate({|oView| F024FKPAft(oView)})
	EndIf

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKPVIS
Define a operação de VISUALIZAÇÃO
@author  Mauricio Pequim Jr
@since 18/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKPVIS()
	Local oModel   As Object
	Local nOpc	   As Numeric
	Local aButtons As Array

	//Inicializa variáveis
	oModel   := Nil
	nOpc     := MODEL_OPERATION_VIEW
	__nOper  := nOpc

	aButtons := {}
	
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	oModel := FwLoadModel("FINA024VCT")
	oModel:SetOperation(nOpc)
	oModel:Activate()

	FWExecView( STR0004, "FINA024VCT", nOpc,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel ) //'Incluir'

	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
	
	FKP->(DBSETORDER(2))	//"FKP_FILIAL+FKP_CODIGO"
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKPINC
Define a operação de inclusão
@author  Mauricio Pequim Jr
@since 18/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKPINC()
	Local oModel   As Object
	Local nOpc	   As Numeric
	Local aButtons As Array

	//Inicializa variáveis
	oModel   := Nil
	nOpc     := MODEL_OPERATION_INSERT
	__nOper  := nOpc

	aButtons := {}
	
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	oModel := FwLoadModel("FINA024VCT")
	oModel:SetOperation(nOpc)
	oModel:Activate()

	FWExecView( STR0005, "FINA024VCT", nOpc,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel ) //'Incluir'

	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
	
	FKP->(DBSETORDER(2))	//"FKP_FILIAL+FKP_CODIGO"
Return



//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKPALT
Define a operação de alteração
@author  Mauricio Pequim Jr
@since 18/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKPALT()
	Local nOpc     	As Numeric
	Local aButtons 	As Array
	Local nRegAnt  	As Numeric
	Local cIdRet	As Character
	Local cCodigo	As Character
	Local oModel	As Object
	
	//Carrega o modelo de dados
	oModel := FwLoadModel("FINA024VCT")
	oModel:Activate()
	
	cIdRet    := oModel:GetValue("FKPMASTER", "FKP_IDRET")
	cCodigo   := oModel:GetValue("FKPMASTER", "FKP_CODIGO")
	__lAltAll := FinVldExc("FKK", "FKP", cIdRet, cCodigo)
	
	//Inicializa variáveis
	aButtons     := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	nOpc         := MODEL_OPERATION_UPDATE
	nRegAnt      := FKP->(Recno())
	__nOper      := OPER_ALTERAR
	__lConfirmou := .F.
	
	//Somente versões ativas podem ser alteradas/versionadas
	FWExecView(STR0007, "FINA024VCT", nOpc,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, /*oModel*/ ) //'Alterar'
	
	__lConfirmou := .F.
	__nOper      := 0
	__lAltAll := .F.
	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
	
	FKP->(DBSETORDER(2))	//"FKP_FILIAL+FKP_CODIGO"
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKPEXC()
Define operacao de exclusao

@author  Mauricio Pequim Jr
@since 18/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKPEXC()
	Local oModel	As Object
	Local nOpc		As Numeric
	Local cIdRet	As Character
	Local cCodigo	As Character
	Local lExclui	As Logical
	Local aEnableButtons	As Array

	aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"

	nOpc := MODEL_OPERATION_DELETE

	oModel := FwLoadModel("FINA024VCT")
	oModel:SetOperation(nOpc)
	oModel:Activate()

	cIdRet   := oModel:GetValue("FKPMASTER", "FKP_IDRET")
	cCodigo  := oModel:GetValue("FKPMASTER", "FKP_CODIGO")
	
	lExclui		:= FinVldExc("FKK", "FKP", cIdRet, cCodigo)

	If lExclui
		FWExecView( STR0006,"FINA024VCT", nOpc,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aEnableButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel ) //'Excluir'
	Else
		HELP(' ',1,"F024FKPXC" ,,STR0008,2,0,,,,,, {STR0009})	//"Exclusão não permitida."###"Regra de vencimento vinculada a uma Regra de Retenção Financeiras. Neste caso a exclusão não é permitida."
	Endif
	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
	FKP->(DBSETORDER(2))	//"FKP_FILIAL+FKP_CODIGO"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKPCOP()
Define operacao de CÓPIA

@author  Mauricio Pequim Jr
@since 18/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKPCOP()
	Local nOpc		As Numeric
	Local aEnableButtons	As Array

	aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"

	nOpc := OP_COPIA 

	__nOper := OPER_COPIAR
	__lConfirmou := .F.
	__lFirst := .T.

	FWExecView( STR0003, "FINA024VCT", nOpc,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aEnableButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, /*oModel*/ ) //'Copiar'

	__lFirst := .F.
	__lConfirmou := .F.
	__nOper := 0

	FKP->(DBSETORDER(2))	//"FKP_FILIAL+FKP_CODIGO"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F024VCTTOK()
Pós Validacao do model

@author Mauricio Pequim Jr
@since 18/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Static Function F024VCTTOK() As Logical
	Local lRet As Logical
	Local oModel As Object
	Local aAreaFKP As Array

	lRet := .T.
	oModel := FWModelActive()
	nOper := oModel:GetOperation()
	aAreaFKP := FKP->(GetArea())
	lRet	:= .T.

	If nOper == MODEL_OPERATION_INSERT

		DBSelectArea("FKP")
		FKP->( DbSetOrder(2) )

		If FKP->( DbSeek( xFilial("FKP")+oModel:GetValue("FKPMASTER","FKP_CODIGO") ) )
			HELP(" ",1,"FA024DUP",,STR0010,1,0)	//"Regra de vencimento já cadastrada."
			lRet	:= .F.
		EndIf

	EndIf

	If lRet .and. nOper != MODEL_OPERATION_DELETE

		//Vencimento
		If !FIN024DVC()
			lRet := .F.
		ElseIf lRet .and. oModel:GetValue('FKPMASTER','FKP_TIPVCT') == '2' .and. oModel:GetValue('FKPMASTER','FKP_QTPERI') == 0 // Por 2 - Periodico periodo zerado
			HELP(' ',1, 'Qtd.Periodos' ,, STR0013 ,2,0,,,,,, {STR0014} )	//'O Qtd.Periodos na aba Vencimento deve ser preenchido quando o Tipo Vencto. for Periódico. '###'Informe a quantidade de períodos ou altere o Tipo Vencto.'
			lRet := .F.	 
		EndIf	

	Endif

	__lConfirmou := lRet

	FKP->(RestArea(aAreaFKP))

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FIN024DVC()
Pos Validacao de preenchimento do campo Dia do Vencimento

@author Mauricio Pequim Jr
@since	18/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function FIN024DVC() As Logical
	Local lRet As Logical
	Local oModel As Object
	Local nDia As Numeric
	Local cPeriodo As Character	// 1=Mensal;2=Semanal
	Local cTpVcto As Character	// 1=Fixo;2=Periodico

	oModel := FWModelActive()
	cPeriodo := oModel:GetValue('FKPMASTER','FKP_PRDVCT')
	nDia := oModel:GetValue('FKPMASTER','FKP_DIAVCT')
	cTpVcto := oModel:GetValue('FKPMASTER','FKP_TIPVCT')

	If (lRet := POSITIVO(nDia))
		If cTpVcto == '2' //Periodico
			If cPeriodo == '1' .and. nDia > 31
				lRet := .F.
				HELP(' ',1, 'DATA_VENCTO' ,, STR0015 ,2,0,,,,,, {STR0016+'31.'} )	//'Dia do mês Inválido'###'Número máximo que pode ser informado é '
			Elseif cPeriodo == '2' .and. nDia > 7
				lRet := .F.
				HELP(' ',1, 'DATA_VENCTO' ,, STR0017 ,2,0,,,,,, {STR0016+'7.'} )	//'Dia da semana Inválido'###'Número máximo que pode ser informado é '
			EndIf
		Endif
	Endif

Return lRet

//-------------------------------------------------------------------------------------------------------------------------------------------------------
// VALIDAÇÕES
//-------------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} F024CODFKP()
Pos Validacao de preenchimento do código do registro de retenção

@author Mauricio Pequim Jr
@since	14/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F024CODFKP() As Logical
	Local lRet As Logical
	Local oModel As Object
	Local cCodigo As Character
	Local lAchou As Logical
	Local cCab As Character
	Local cDes As Character
	Local cSol As Character
	Local aArea As Array

	lRet 	:= .F.
	lAchou 	:= .F.
	aArea 	:= {}
	cCab	:= ""
	cDes	:= ""
	cSol	:= ""
	
	oModel := FWModelActive()
	cCodigo := oModel:GetValue('FKPMASTER','FKP_CODIGO')

	If !Empty(cCodigo)
		aArea  := FKP->(GetArea())
		FKP->(DbSetOrder(2))	// FKP_FILIAL+FKP_CODIGO
		If FKP->(MSSeek(xFilial('FKP')+cCodigo))
			lAchou := .T.
		Endif
		FKP->(RestArea(aArea))
	EndIf

	If __nOper != MODEL_OPERATION_INSERT .and. __nOper != OPER_COPIAR
		cCab := STR0018		//'Código'
		cDes := STR0019		//'Operação não permitida.'
		cSol := STR0020		//'Este campo não pode ser alterado.'
	ElseIf !FreeForUse('FKP','FKP_CODIGO'+xFilial('FKP')+cCodigo)
		cCab := STR0018		//'Código'
		cDes := STR0021 + ": " + cCodigo + " " + STR0025 		//'O código encontra - se em uso.'
		cSol := STR0022		//'Código se encontra reservado.'
	ElseIf lAchou
		cCab := STR0018		//'Código'
		cDes := STR0021 + ": " + cCodigo + " " + STR0026		//'O código já se encontra cadastrado.'
		cSol := STR0027		//'Digite um novo código'
	Else
		lRet := .T.
	EndIf

	If !Empty(cCab+cDes+cSol)
		HELP(' ',1, cCab ,, cDes ,2,0,,,,,, {cSol} )
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKPRET()
Inicializador padrao do campo FKP_IDRET

@author Mauricio Pequim Jr
@since	25/08/2017
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKPRET(oModel As Object) As Character
	Local cRet As Character
	Local nOper	As Numeric
	Local aAreaFKP As Array
	
	DEFAULT oModel := NIL
	
	cRet	:= ""
	
	aAreaFKP := FKP->(GetArea())	
	
	If __nOper == MODEL_OPERATION_INSERT .OR. __nOper == OPER_COPIAR	
	
		While .T.
			cRet := FWUUIDV4()
			FKP->(DbSetOrder(1))
			If !(FKP->(MsSeek(xFilial("FKP")+cRet))) .and. FreeForUse("FKP",cRet)
				FKP->(RestArea(aAreaFKP))
				Exit	
			Endif
		EndDo
	
		//Em caso de alteração ou cópia, ajusto a versão do imposto
		If __nOper == OPER_COPIAR
			If oModel != NIL
				oModel:LoadValue("FKPMASTER","FKP_IDRET",cRet)
				F024FKPVER(oModel)	
				FKP->(RestArea(aAreaFKP))
			EndIf
		Endif
	Else
		cRet := FKP->FKP_IDRET
	Endif

Return cRet	

//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKPVER()
Inicializador padr?o do campo FKP_VERSAO

@author Mauricio Pequim Jr
@since	25/08/2017
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKPVER(oModel As Object) As Character
	Local cCod As Character
	Local cRet As Character
	Local nOper	As Numeric
	
	DEFAULT oModel := NIL
	
	cCod	:= ""	
	cRet	:= ""	
	
	If __nOper == OPER_COPIAR .and. __lFirst
		If oModel != NIL
			oModel:LoadValue("FKPMASTER","FKP_CODIGO","")
			oModel:LoadValue("FKPMASTER","FKP_DESCR" ,"")
		EndIf
	EndIF

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKPPos()
Pos Validacao de preenchimento do FORM

@author  Mauricio Pequim Jr
@since	25/08/2017
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKPPos() As Logical
	Local lRet As Logical
	Local oModel, oFKP As Object
	Local nOper		As Numeric
	
	oModel		:= FWModelActive()
	nOper		:= oModel:GetOperation()
	oFKP 		:= oModel:GetModel("FKPMASTER")
	lRet		:= .T.
	
	If nOper == MODEL_OPERATION_INSERT
	
		DBSelectArea("FKP")
		FKP->( DbSetOrder(3) )
	
		If FKP->( DbSeek( xFilial("FKP")+oFKP:GetValue("FKP_IDRET") ) )
			HELP(" ",1,"FA024DUP",,STR0010,1,0)	//"Regra de vencimento já cadastrada."
			lRet	:= .F.
		EndIf
	
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/ {Protheus.doc} F024FKPWhe
Permissão de edição de campos (When)

@param oGridModel - Model que chamou a validação
@param cCampo - Campo a ser validada permissão de edição

@author Mauricio Pequim Jr
@since 01/09/2017

@return Logico com permissão ou não de edição do campo
/*/
//-------------------------------------------------------------------
Function F024FKPWhe(oModel As Object, cCampo As Character)
	Local lRet As Logical
	Local cCodigo As Character
	Local cIdRet As Character

	DEFAULT oModel := NIL
	DEFAULT cCampo := ""
	
	lRet := .T.
	cCodigo := ""
	cIdRet := ""

	If cCampo == "FKP_CODIGO" 
		If __nOper == OPER_ALTERAR
			lRet := .F.
		Endif
	
		If lRet .and. __nOper == OPER_COPIAR .and. __lFirst
			F024FKPVER(oModel)
			__lFirst := .F.
		EndIf
	
	Endif
	
	If cCampo $ 'FKP_PRDVCT|FKP_QTPERI|FKP_DATVCT'
		lRet := oModel:GetValue("FKPMASTER","FKP_TIPVCT") == '2'	//Tipo de Vencto = Periodo
		If lRet .And. __nOper == OPER_ALTERAR
			cCodigo := oModel:GetValue("FKPMASTER","FKP_CODIGO") 
			cIdRet := oModel:GetValue("FKPMASTER","FKP_IDRET") 
			lRet	:= FinVldExc("FKK", "FKP", cIdRet, cCodigo)
		EndIf
	Endif	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKPAft()
Refresh da View utilizado para alteração

@author Mauricio Pequim Jr
@since	25/08/2017
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKPAft(oView As Model) As Logical

	oView:Refresh()

Return .T.