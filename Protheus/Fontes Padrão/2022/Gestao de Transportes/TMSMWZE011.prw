#include "TMSMWZE011.ch"
#Include 'Protheus.ch'
#Include "FWMVCDEF.CH"

Function TMSMWZE011()

Local oMBrowse	:= Nil

oMBrowse	:= FwMBrowse():New()
oMBrowse:SetAlias( 'SB1' )
oMBrowse:SetDescription( OemToAnsi(STR0006) )    // "Cadastro de Produtos"
oMBrowse:Activate()
	
Return

Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0001  ACTION "AxPesqui"        OPERATION 1 ACCESS 0  // "Pesquisar"
	ADD OPTION aRotina TITLE STR0002  ACTION "VIEWDEF.TMSZE011" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.TMSZE011" OPERATION 3 ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.TMSZE011" OPERATION 4 ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.TMSZE011" OPERATION 5 ACCESS 0 // "Excluir"
	
Return aRotina

Static Function ModelDef()

Local oModel := Nil
Local oStruSB1 := FwFormStruct( 1, 'SB1' )

oModel := MpFormModel():New( 'TMSMWZE011', /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/ )
oModel:SetDescriptin( STR0006 )  // "Cadastro de Produtos"
oModel:AddFields( 'MdFieldSB1', Nil, oStruSB1 )
oModel:SetPrimaryKey( { 'B1_FILIAL', 'B1_COD' } )


Return( oModel )