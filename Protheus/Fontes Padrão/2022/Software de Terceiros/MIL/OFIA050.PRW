#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIA050.CH"

/*/{Protheus.doc} OFIA050()
Cadastro de Oportunidades VDL

@author Andre Luis Almeida
@since 14/01/2019
@version 1.0
@return NIL
/*/
Function OFIA050()
Local oBrowse
Private oModel

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("VDL")
oBrowse:SetDescription(STR0001) // Cadastro de Oportunidades
oBrowse:Activate()

Return NIL

/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 14/01/2019
@version 1.0
@return aRotina 
/*/
Static Function MenuDef()
Local aRotina := {}
Local cOrdem  := ""
Local nCntFor := 0
Local lJaOfic := .f.

ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.OFIA050' OPERATION 2 ACCESS 0 // Visualizar
If IsInCallStack('OFIA120') // Oportunidades Agrupadas
	cOrdem := OA1200051_BrowsePermitido() // Retorna a Ordem dos Objetos (Browse) permitidos
	For nCntFor := 1 to len(cOrdem)
		Do Case
			Case substr(cOrdem,nCntFor,1) == "1"
				ADD OPTION aRotina TITLE STR0006 ACTION 'OA0500011_Incluir(1)' OPERATION 3 ACCESS 0 // Incluir com Veículos/Máquinas
				ADD OPTION aRotina TITLE STR0007 ACTION 'VEICC680()' OPERATION 2 ACCESS 0 // Consulta Interesses de Veículos/Máquinas
				ADD OPTION aRotina TITLE STR0008 ACTION 'VCC680FUNIL()' OPERATION 2 ACCESS 0 // Funil de Veículos/Máquinas
			Case substr(cOrdem,nCntFor,1) == "2"
				ADD OPTION aRotina TITLE STR0009 ACTION 'OA0500011_Incluir(2)' OPERATION 3 ACCESS 0 // Incluir com Peças Balcão
				ADD OPTION aRotina TITLE STR0010 ACTION 'OFIC050()' OPERATION 2 ACCESS 0 // Consulta Interesses de Peças Balcão
				ADD OPTION aRotina TITLE STR0011 ACTION 'OC0500141_FUNIL()' OPERATION 2 ACCESS 0 // Funil de Peças Balcão
			Case substr(cOrdem,nCntFor,1) $ "3/4" .and. !lJaOfic
				ADD OPTION aRotina TITLE STR0012 ACTION 'OA0500011_Incluir(3)' OPERATION 3 ACCESS 0 // Incluir com Peças/Serviços Oficina
				ADD OPTION aRotina TITLE STR0013 ACTION 'OFIC060()' OPERATION 2 ACCESS 0 // Consulta Interesses de Peças/Serviços Oficina
				ADD OPTION aRotina TITLE STR0014 ACTION 'OC0600141_FUNIL()' OPERATION 2 ACCESS 0 // Funil de Peças/Serviços Oficina
				lJaOfic := .t. // Ja incluiu o botao de Oficina
		EndCase
	Next
Else
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.OFIA050' OPERATION 3 ACCESS 0 // Incluir
EndIf
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.OFIA050' OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.OFIA050' OPERATION 8 ACCESS 0 // Imprimir

Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Andre Luis Almeida
@since 14/01/2019
@version 1.0
@Return oModel
/*/
Static Function ModelDef()
Local oStrVDL := FWFormStruct(1,"VDL")

oStrVDL:SetProperty( 'VDL_CODOPO' , MODEL_FIELD_INIT,{|| GetSXENum("VDL","VDL_CODOPO") })

oModel := MPFormModel():New("OFIA050", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VDLMASTER",/*cOwner*/ , oStrVDL)

oModel:GetModel("VDLMASTER"):SetDescription(STR0015) // Oportunidades

oModel:SetDescription(STR0015) // Oportunidades

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 14/01/2019
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVDL:= FWFormStruct(2, "VDL")

oView := FWFormView():New()
oView:SetModel(oModel)

oView:SetCloseOnOk({||.T.})

oView:AddField( 'VIEW_VDL', oStrVDL, 'VDLMASTER' )

// definição de como será a tela
oView:CreateHorizontalBox( "VDL", 100)
oView:SetOwnerView("VIEW_VDL","VDL")

Return oView

/*/{Protheus.doc} OA0500011_Incluir
	Incluir com Veiculos / Balcao / Oficina

	@author Andre Luis Almeida
	@since 21/01/2019
/*/
Function OA0500011_Incluir(nTp)
Local cTitulo := ""
Local cPRW    := ""
Local oView
Private oModel
Private lIncVDL := .t.
//
If nTp == 1
	VCM680I() // Inclusao Veiculos ( VEICM680 )
Else
	oView := FWViewExec():New()
	If nTp == 2
		cTitulo := STR0016 // Interesses Balcão Peças
		cPRW    := "OFIA100"
	Else //nTp == 3
		cTitulo := STR0017 // Interesses Oficina Peças/Serviços
		cPRW    := "OFIA110"
	EndIf
	oView:setTitle( STR0003 )
	oView:setSource( cPRW )
	oView:setModal(.F.)               
	oView:setOperation(MODEL_OPERATION_INSERT)
	oView:openView(.F.)
EndIf
//
Return