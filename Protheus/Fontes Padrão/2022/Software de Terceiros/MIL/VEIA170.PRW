#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIA170.CH"

/*/{Protheus.doc} VEIA170()
Cadastro de Relacionamentos entre Tabelas MIL ( VCS )

@author Andre Luis Almeida
@since 12/05/2020
@version 1.0
@return NIL
/*/
Function VEIA170()
Local oBrowse
//
oBrowse := FWMBrowse():New()
oBrowse:SetAlias("VCS")
oBrowse:SetDescription(STR0001) // Relacionamentos entre Tabelas
oBrowse:AddLegend( "VCS_TIPO='1'" , "BR_VERDE" , STR0002 ) // CEV x Oportunidades
oBrowse:DisableDetails()
oBrowse:Activate()
//
Return NIL

/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 12/05/2020
@version 1.0
@return aRotina 
/*/
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.VEIA170' OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.VEIA170' OPERATION 8 ACCESS 0 // Imprimir
Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Andre Luis Almeida
@since 12/05/2020
@version 1.0
@Return oModel
/*/
Static Function ModelDef()
Local oStrVCS := FWFormStruct(1,"VCS")

oModel := MPFormModel():New("VEIA170", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )

oModel:AddFields("VCSMASTER",/*cOwner*/ , oStrVCS)

oModel:SetDescription(STR0001) // Relacionamentos entre Tabelas
//oModel:InstallEvent("VEIA170LOG", /*cOwner*/, MVCLOGEV():New("VEIA170") ) // CONSOLE.LOG para verificar as chamadas dos eventos
//oModel:InstallEvent("VEIA170EVDEF", /*cOwner*/, VEIA170EVDEF():New() )

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 12/05/2020
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVCS:= FWFormStruct(2,"VCS")

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField( 'VIEW_VCS', oStrVCS, 'VCSMASTER' )

oStrVCS:SetProperty( "*" ,MVC_VIEW_CANCHANGE, .f. )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' ,100)
oView:SetOwnerView('VIEW_VCS', 'CABEC' )

oView:SetCloseOnOk({||.T.})

Return oView

/*/{Protheus.doc} VA1700011_Grava_Relacionamento
	Gravação do Relacionamento entre as tabelas ( VCS )

	@author Andre Luis Almeida
	@since 12/05/2020
/*/
Function VA1700011_Grava_Relacionamento( cTipo , cFilPri , cCodPri , cFilRel , cCodRel )
DbSelectArea("VCS")
RecLock("VCS",.t.)
	VCS->VCS_FILIAL := xFilial("VCS")
	VCS->VCS_CODIGO := GetSXENum("VCS","VCS_CODIGO")
	VCS->VCS_TIPO   := cTipo
	VCS->VCS_FILPRI := cFilPri
	VCS->VCS_CODPRI := cCodPri
	VCS->VCS_FILREL := cFilRel
	VCS->VCS_CODREL := cCodRel
	VCS->VCS_DATINC := FGX_Timestamp()
MsUnLock()
ConfirmSX8()
Return