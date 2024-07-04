#include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#INCLUDE 'GPEA942.CH'

/*/{Protheus.doc} GPEA942
Histórico Dados do Funcionário
@author Gustavo Baptista
@since 24/11/2021
@Type     Function
/*/
Function GPEA942()

Local oMBrowse

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias("SRA")
oMBrowse:SetDescription(OemToAnsi(STR0001)) //"Histórico Dados Funcionários"


oMBrowse:SetLocate()
GpLegMVC(@oMBrowse)

oMBrowse:ExecuteFilter(.T.)

oMBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Definição do MenuDef
@author Gustavo Baptista
@since 24/11/2021
@Type     Function
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title OemToAnsi(STR0002)  Action 'PesqBrw'           OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title OemToAnsi(STR0003)  Action 'VIEWDEF.GPEA942'   OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title OemToAnsi(STR0004)  Action 'VIEWDEF.GPEA942'   OPERATION 4 ACCESS 0 //"Alterar"

Return aRotina

/*/{Protheus.doc} ModelDef
Definição e detalhamento do Model
@author Gustavo Baptista
@since 24/11/2021
@Type     Function
/*/
Static Function ModelDef()

Local oMdl
Local bAvalCampo    := {|cCampo| AllTrim(cCampo)+"|" $ "|RA_FILIAL|RA_MAT|RA_NOME|RA_CIC|RA_CODUNIC|"}
Local oStruSRA      := FWFormStruct(1, 'SRA', bAvalCampo,/*lViewUsado*/)
Local oStruSR9      := FWFormStruct(1, 'SR9', /*bAvalCampo*/,/*lViewUsado*/)

oMdl := MPFormModel():New('GPEA942', /*bPreValid */, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oMdl:AddFields('SRAMASTER', /*cOwner*/, oStruSRA, /*bFldPreVal*/, /*bFldPosVal*/, /*bCarga*/)

oMdl:AddGrid( 'SR9DETAIL', 'SRAMASTER', oStruSR9, /*bLinePre*/, /*{ |oMdl| SR9_LinOK(oMdl) }*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oStruSR9:SetProperty("R9_CAMPO",MODEL_FIELD_NOUPD,.T.)
oStruSR9:SetProperty("R9_DESC",MODEL_FIELD_NOUPD,.T.)
oStruSR9:SetProperty("*",MODEL_FIELD_WHEN,{|oMdl|fMdlWhen(oMdl)})

oMdl:SetRelation('SR9DETAIL', {{'R9_FILIAL', 'RA_FILIAL'}, {'R9_MAT', 'RA_MAT'}}, SR9->(IndexKey(1)))

oMdl:GetModel('SR9DETAIL'):SetUniqueLine({'R9_FILIAL', 'R9_MAT', 'R9_CAMPO', 'R9_DATA'})
oMdl:GetModel('SR9DETAIL'):SetMaxLine(99)
oMdl:GetModel('SR9DETAIL'):SetNoInsertLine(.T.)
oMdl:GetModel('SR9DETAIL'):SetNoDeleteLine(.T.)

//Permite grid sem dados
oMdl:GetModel('SR9DETAIL'):SetOptional(.T.)
oMdl:GetModel('SRAMASTER'):SetOnlyView(.T.)
oMdl:GetModel('SRAMASTER'):SetOnlyQuery(.T.)

// Adiciona a descricao do Componente do Modelo de Dados
oMdl:GetModel('SRAMASTER'):SetDescription(OemToAnsi(STR0005)) // "Funcionários"

Return oMdl

/*/{Protheus.doc} ViewDef
Definição da viewdef
@author Gustavo Baptista
@since 24/11/2021
@Type     Function
/*/
Static Function ViewDef()

Local oView
Local bAvalCampo    := {|cCampo| AllTrim(cCampo)+"|" $ "|RA_FILIAL|RA_MAT|RA_NOME|RA_CIC|"}
Local oModel        := FWLoadModel('GPEA942')
Local oStruSRA      := FWFormStruct(2, 'SRA', bAvalCampo)
Local oStruSR9      := FWFormStruct(2, 'SR9')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_SRA', oStruSRA, 'SRAMASTER')
oStruSRA:SetNoFolder()

oView:AddGrid('VIEW_SR9', oStruSR9, 'SR9DETAIL')

oStruSRA:RemoveField("RA_CIC")
oStruSR9:RemoveField("R9_MAT")

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('SUPERIOR', 15)
oView:CreateHorizontalBox('INFERIOR', 85)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_SRA', 'SUPERIOR')
oView:SetOwnerView('VIEW_SR9', 'INFERIOR')

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_SRA', OemToAnsi(STR0006)) // "Funcionário"
oView:EnableTitleView('VIEW_SR9', OemToAnsi(STR0007)) // "Histórico Dados Funcionário"

oView:SetCloseOnOk({ || .T. })	//Desabilita botão "Salvar e Criar Novo"

Return oView


/*/{Protheus.doc} fMdlWhen
	Habilita a edição dos campos ou não.
	@type  Static Function
	@author Gustavo Baptista
	@since 17/12/2021
/*/
Static Function fMdlWhen(oMdl)

	Local lRet := .T.

	IF Empty(oMdl:getValue("R9_DATA")) .AND. Empty(oMdl:getValue("R9_CAMPO")) .AND. Empty(oMdl:getValue("R9_DESC"))
		lRet:= .F.
	ENDIF

	
Return lRet
