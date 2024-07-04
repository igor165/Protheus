#include 'TMSMWZE013.ch' 
#Include 'Protheus.ch'

Function TMSMWZE013()
Local oMBrowse	:= Nil

oMBrowse	:= FwMBrowse():New()
oMBrowse:SetAlias( 'SF4' )
oMBrowse:SetDescription( OemToAnsi( STR0001 ) )  // "Cadastro de Tipos de Entrada/Saida" 
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
Local oStruSF4 := FwFormStruct( 1, 'SF4' )

oModel := MpFormModel():New( 'TMSMWZE013', /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/ )
oModel:SetDescriptin( STR0001 ) // "Cadastro de Tipos de Entrada/Saida"
oModel:AddFields( 'MdFieldSF4', Nil, oStruSF4 )
oModel:SetPrimaryKey( { 'F4_FILIAL', 'F4_CODIGO' } )                                                                                                            

Return( oModel )