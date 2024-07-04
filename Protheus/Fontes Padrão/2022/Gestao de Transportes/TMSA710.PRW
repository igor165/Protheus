#INCLUDE "TMSA710.ch"
#INCLUDE "PROTHEUS.CH"

//===========================================================================================================
/* Cadastramento de Distancias
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 		10/01/2013
@return 	*/
//===========================================================================================================
Function TMSA710( nOpcAuto, aRotAuto )

Local oMBrowse	:= Nil
Local l710Auto	:= ( ValType( aRotAuto ) == "A" )
Local aAutoCab	:= {}

Private aRotina	:= MenuDef()

Default nOpcAuto	:= 0

If l710Auto
//===========================================================================================================
// Chamada da rotina automatica através do MVC
//===========================================================================================================
	aAutoCab   := Aclone( aRotAuto )
	FwMvcRotAuto( ModelDef(), 'DVA', nOpcAuto, { { 'MdFieldDVA', aAutoCab } } )  
	
Else
//===========================================================================================================
// Funcao de BROWSE
//===========================================================================================================
	oMBrowse	:= FwMBrowse():New()
	oMBrowse:SetAlias( 'DVA' )
	oMBrowse:SetDescription( OemToAnsi(STR0001) )
	oMBrowse:Activate()

EndIf

Return Nil

//===========================================================================================================
/* Retorna o modelo de Dados da rotina Cadastro de Distancias
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 		10/01/2013
@return 	oModel - Modelo de Dados */
//===========================================================================================================
Static Function ModelDef()

Local oModel := Nil
Local oStruDVA := FwFormStruct( 1, 'DVA' )

oModel := MpFormModel():New( 'TMSA710', /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/ )

oModel:SetDescriptin( STR0001 )

oModel:AddFields( 'MdFieldDVA', Nil, oStruDVA )

oModel:SetPrimaryKey( { 'DVA_FILIAL', 'DVA_CDRORI', 'DVA_CDRDES', 'DVA_TIPTRA' } )

Return( oModel )

//===========================================================================================================
/* Retorna a View (tela) da rotina Cadastro de Distancias
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 		10/01/2013
@return 	oView -  */
//===========================================================================================================
Static Function ViewDef()

Local oModel	:= FwLoadModel( 'TMSA710' )
Local oView		:= Nil
Local oStruDVA	:= FwFormStruct( 2, 'DVA' )

oView := FwFormView():New()

oView:SetModel( oModel )

oView:CreateHorizontalBox( 'Field'	, 100 )

oView:AddField( 'VwFieldDVA', oStruDVA, 'MdFieldDVA'	)

oView:SetOwnerView( 'VwFieldDVA'	, 'Field'	)

Return( oView ) 

//===========================================================================================================
/* Retorna as operações disponiveis para o Cadastro de Distancias
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 		10/01/2013
@return 	aRotina - Array com as opçoes de Menu */
//===========================================================================================================
Static Function MenuDef()

Local aRotina		:= {	{ STR0002		,"AxPesqui"				,0 , 1,,.F. },;  	//"Pesquisar"
							{ STR0003		,"VIEWDEF.TMSA710"		,0 , 2 },;  		//"Visualizar"
							{ STR0004		,"VIEWDEF.TMSA710"		,0 , 3 },;  		//"Incluir"
							{ STR0005		,"VIEWDEF.TMSA710"		,0 , 4 },;  		//"Alterar"
							{ STR0006		,"VIEWDEF.TMSA710"		,0 , 5 } }  		//"Excluir"
Return( aRotina )


