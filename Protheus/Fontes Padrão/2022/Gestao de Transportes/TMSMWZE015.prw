#include "TMSMWZE015.CH"
#Include 'Protheus.ch'

Function TMSMWZE015()
Local oMBrowse	:= Nil

oMBrowse	:= FwMBrowse():New()
oMBrowse:SetAlias( 'SA2' )
oMBrowse:SetDescription( OemToAnsi(STR0001) )//"Cadastro de Fornecedores"
oMBrowse:Activate()
	
Return

/*
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.TMSA013" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.TMSA013" OPERATION 3 ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.TMSA013" OPERATION 4 ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.TMSA013" OPERATION 5 ACCESS 0 // "Excluir"
	
Return aRotina
*/

Static Function ModelDef()

Local oModel := Nil
Local oStruSA2 := FwFormStruct( 1, 'SA2' )

oModel := MpFormModel():New( 'TMSMWZE015', /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/ )
oModel:SetDescriptin( STR0002 )//"Cadastro de Fornecedores"
oModel:AddFields( 'MdFieldSA2', Nil, oStruSA2 )
oModel:SetPrimaryKey( { 'A2_FILIAL', 'A2_COD' } )                                                                                                            

Return( oModel )