#include "TMSMWZE014.CH"
#Include 'Protheus.ch'
#Include "FWMVCDEF.CH"

Function TMSMWZE014()

Local oMBrowse	:= Nil

oMBrowse	:= FwMBrowse():New()
oMBrowse:SetAlias( 'SED' )
oMBrowse:SetDescription( OemToAnsi(STR0001) ) //"Cadastro de Naturezas"
oMBrowse:Activate()
	
Return

Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002  	ACTION "AxPesqui"        OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.TMSA013" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0004    ACTION "VIEWDEF.TMSA013" OPERATION 3 ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0005    ACTION "VIEWDEF.TMSA013" OPERATION 4 ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE STR0006    ACTION "VIEWDEF.TMSA013" OPERATION 5 ACCESS 0 // "Excluir"
	
Return aRotina

Static Function ModelDef()

Local oModel := Nil
Local oStruSED := FwFormStruct( 1, 'SED' )

oModel := MpFormModel():New( 'TMSMWZE014', /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/ )
oModel:SetDescriptin( STR0007 )//"Cadastro de Naturezas"
oModel:AddFields( 'MdFieldSED', Nil, oStruSED )
oModel:SetPrimaryKey( { 'ED_FILIAL', 'ED_CODIGO' } )                                                                                                            

Return( oModel )