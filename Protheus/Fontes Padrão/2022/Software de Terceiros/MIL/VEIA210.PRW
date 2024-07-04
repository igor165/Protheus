#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA210.CH"

/*/{Protheus.doc} VEIA210
	Cadastro/Consulta Grupo de Negocios

	@author Andre Luis Almeida
	@since 11/01/2021
/*/
Function VEIA210()

Local oVEIA210
Local oTPanVJW
Local oTPanVJX
Local aSize     := FWGetDialogSize( oMainWnd )

cCadastro := STR0001 // Grupo de Negocios

oVEIA210 := MSDIALOG() :New(aSize[1],aSize[2],aSize[3],aSize[4],STR0001,,,,128,,,,,.t.) // Grupo de Negocios

	oTPanVJW := TPanel():New(0,0,"",oVEIA210,NIL,.T.,.F.,NIL,NIL,100,(oVEIA210:nClientHeight/4)-10,.F.,.F.)
	oTPanVJW:Align := CONTROL_ALIGN_TOP

	oTPanVJX := TPanel():New(0,0,"",oVEIA210,NIL,.T.,.F.,NIL,NIL,100,(oVEIA210:nClientHeight/4)-10,.F.,.F.)
	oTPanVJX:Align := CONTROL_ALIGN_BOTTOM 

	oBrwVJW := FWMBrowse():New()
	oBrwVJW:SetAlias('VJW')
	oBrwVJW:SetOwner(oTPanVJW)
	oBrwVJW:SetDescription(STR0001) // Grupo de Negocios
	oBrwVJW:DisableDetails()
	oBrwVJW:ForceQuitButton()
	oBrwVJW:Activate()

	oBrwVJX := FWMBrowse():New()
	oBrwVJX:SetAlias('VJX')
	oBrwVJX:SetOwner(oTPanVJX)
	oBrwVJX:SetDescription(STR0002) // Clientes do Grupo de Negocio posicionado
	oBrwVJX:DisableDetails()
	oBrwVJX:SetAmbiente(.F.)
	oBrwVJX:SetWalkthru(.F.)
	oBrwVJX:SetUseFilter()
	oBrwVJX:SetMenuDef("VEIA211")
	oBrwVJX:Activate()

	oRelacVJX:= FWBrwRelation():New() 
	oRelacVJX:AddRelation( oBrwVJW , oBrwVJX , { { "VJX_FILIAL" , "VJW_FILIAL" }, { "VJX_GRUNEG" , "VJW_CODIGO" } }) 
	oRelacVJX:Activate()

oVEIA210:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	aRotina := FWMVCMenu('VEIA210')

	ADD OPTION aRotina TITLE STR0004 ACTION 'VEIC110( VJW->VJW_CODIGO , "" , "" , "" , "" , "" , "" )'	OPERATION 2 ACCESS 0 // Dados dos Clientes/Lojas do Grupo de Negocio
	ADD OPTION aRotina TITLE STR0005 ACTION 'VEIA220( .f. , VJW->VJW_CODIGO , "" , "" , "" , "" , "" )'	OPERATION 2 ACCESS 0 // Prop.Agricolas Individualizadas por Cliente/Loja do Grupo de Negocio
	ADD OPTION aRotina TITLE STR0006 ACTION 'VEIA220( .t. , VJW->VJW_CODIGO , "" , "" , "" , "" , "" )'	OPERATION 2 ACCESS 0 // Prop.Agricolas Agrupadas dos Clientes/Lojas do Grupo de Negocio
	ADD OPTION aRotina TITLE STR0007 ACTION 'VEIC090( .f. , VJW->VJW_CODIGO , "" , "" , "" , "" , "" )'	OPERATION 2 ACCESS 0 // Frota Individualizada por Cliente/Loja do Grupo de Negocio
	ADD OPTION aRotina TITLE STR0008 ACTION 'VEIC090( .t. , VJW->VJW_CODIGO , "" , "" , "" , "" , "" )'	OPERATION 2 ACCESS 0 // Frotas Agrupadas dos Clientes/Lojas do Grupo de Negocio
	ADD OPTION aRotina TITLE STR0009 ACTION 'VEIR000( VJW->VJW_CODIGO , "" , "" , "" , "" , "" , "" )'	OPERATION 8 ACCESS 0 // Relatório por Prop.Agricolas dos Clientes/Lojas do Grupo de Negócio
	ADD OPTION aRotina TITLE STR0010 ACTION 'VEIR001( VJW->VJW_CODIGO , "" , "" , "" , "" , "" , "" )'	OPERATION 8 ACCESS 0 // Relatório Resumido das Prop.Agricolas dos Clientes/Lojas do Grupo de Negócio
	ADD OPTION aRotina TITLE STR0011 ACTION 'VEIR010( VJW->VJW_CODIGO , "" , "" , "" , "" , "" )'		OPERATION 8 ACCESS 0 // Relatório por Frotas dos Clientes/Lojas do Grupo de Negócio
	ADD OPTION aRotina TITLE STR0012 ACTION 'VEIR011( VJW->VJW_CODIGO , "" , "" , "" , "" , "" )'		OPERATION 8 ACCESS 0 // Relatório Resumido das Frotas dos Clientes/Lojas do Grupo de Negócio

Return aRotina

Static Function ModelDef()

	Local oModel
	Local oStrVJW := FWFormStruct(1, "VJW")
	Local oStrVJX := FWFormStruct(1, "VJX")
	Local aAuxTrigger := {}

	aAuxTrigger := FwStruTrigger("VJX_CODCLI","VJX_NOMCLI","Left(SA1->A1_NOME," + cValToChar(GetSX3Cache("VJX_NOMCLI","X3_TAMANHO")) + ")",.T.,"SA1",1,"xFilial('SA1') + FWFldGet('VJX_CODCLI') + FwFldGet('VJX_LOJCLI')","!Empty(FWFldGet('VJX_CODCLI'))")
	oStrVJX:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])
	aAuxTrigger := FwStruTrigger("VJX_LOJCLI","VJX_NOMCLI","Left(SA1->A1_NOME," + cValToChar(GetSX3Cache("VJX_NOMCLI","X3_TAMANHO")) + ")",.T.,"SA1",1,"xFilial('SA1') + FWFldGet('VJX_CODCLI') + FwFldGet('VJX_LOJCLI')","!Empty(FWFldGet('VJX_LOJCLI'))")
	oStrVJX:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])

	oModel := MPFormModel():New('VEIA210',,,,)

	oModel:AddFields('VJWMASTER',/*cOwner*/ , oStrVJW)
	oModel:SetPrimaryKey( { "VJW_FILIAL", "VJW_CODIGO" } )

	oModel:AddGrid("VJXDETAIL","VJWMASTER",oStrVJX)
	oModel:SetRelation( 'VJXDETAIL', { { 'VJX_FILIAL', 'xFilial( "VJX" )' }, { 'VJX_GRUNEG', 'VJW_CODIGO' } }, VJX->( IndexKey( 1 ) ) )

	oModel:SetDescription(STR0001) // Grupo de Negocios
	oModel:GetModel('VJWMASTER'):SetDescription(STR0001) // Grupo de Negocios
	oModel:GetModel('VJXDETAIL'):SetDescription(STR0003) // Clientes

	oModel:InstallEvent("VEIA210EVDEF", /*cOwner*/, VEIA210EVDEF():New("VEIA210"))

	oModel:AddRules( 'VJXDETAIL', 'VJX_LOJCLI', 'VJXDETAIL', 'VJX_CODCLI', 3)

	oModel:GetModel( 'VJXDETAIL' ):SetUniqueLine( { "VJX_CODCLI" , "VJX_LOJCLI" } )

Return oModel

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVJW:= FWFormStruct(2, "VJW")
	Local oStrVJX:= FWFormStruct(2, "VJX", { |cCampo| !ALLTRIM(cCampo)+"|" $ "VJX_GRUNEG|" })

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:CreateHorizontalBox( 'BOXVJW', 30)
	oView:AddField('VIEW_VJW', oStrVJW, 'VJWMASTER')
	oView:EnableTitleView('VIEW_VJW', STR0001) // Grupo de Negocios
	oView:SetOwnerView('VIEW_VJW','BOXVJW')

	oView:CreateHorizontalBox( 'BOXVJX', 70)
	oView:AddGrid("VIEW_VJX",oStrVJX, 'VJXDETAIL')
	oView:EnableTitleView('VIEW_VJX', STR0003) // Clientes
	oView:SetOwnerView('VIEW_VJX','BOXVJX')

Return oView