#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'OMSA140.CH'
//----------------------------------------------------------
/*/{Protheus.doc} OMSA140
Cadastro de Conversão de Unidade de Medida para KG
@author  amanda.vieira
@version P12
@since   25/05/2018
/*/
//----------------------------------------------------------
Function OMSA140()
Local oBrowse := Nil
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('DK2')
	oBrowse:SetDescription(STR0001) //Cadastro de Conversão de Unidade de Medida para KG
	oBrowse:SetMenuDef('OMSA140')
	oBrowse:SetAmbiente(.F.)
	oBrowse:SetWalkThru(.F.)
	oBrowse:Activate()
Return
//----------------------------------------------------------
// Função MenuDef
//----------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
	ADD OPTION aRotina TITLE STR0002 ACTION 'AxPesqui'        OPERATION 1 ACCESS 0 // Pesquisar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.OMSA140' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.OMSA140' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.OMSA140' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.OMSA140' OPERATION 5 ACCESS 0 // Excluir	
Return aRotina
//----------------------------------------------------------
// Função ModelDef
//----------------------------------------------------------
Static Function ModelDef()
Local oModel     := MPFormModel():New('OMSA140',,/*{|oModel|ValidMld(oModel)}*/)
Local oStructDK2 := FWFormStruct(1, 'DK2')
	oModel:AddFields('DK2MASTER',/*cOwner*/,oStructDK2)
Return oModel 
//----------------------------------------------------------
// Função ViewDef
//----------------------------------------------------------
Static Function ViewDef()
Local oModel     := FWLoadModel('OMSA140')
Local oView      := FWFormView():New()
Local oStructDK2 := FWFormStruct(2, 'DK2')
	oView:SetModel(oModel)
	oView:AddField('VIEWDK2', oStructDK2, 'DK2MASTER')
Return oView