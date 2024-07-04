#Include "Protheus.ch"
#Include "TMSA016.CH"
#Include "FWMVCDEF.CH"

//===========================================================================================================
/* Cadastramento de Identificacao de Produto
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		07/02/2013
@return 	*/
//===========================================================================================================
Function TMSA016( aRotAuto, nOpcAuto )

Local oMBrowse	:= Nil
Local l016Auto	:= ( ValType( aRotAuto ) == "A" )
Local aAutoCab	:= {}

Private aRotina	:= MenuDef()

Default nOpcAuto	:= 0

If l016Auto
//===========================================================================================================
// Chamada da rotina automatica através do MVC
//===========================================================================================================
	aAutoCab   := Aclone( aRotAuto )
	FwMvcRotAuto( ModelDef(), "DYL", nOpcAuto, { { "MdFieldDYL", aAutoCab } } )  
	
Else
//===========================================================================================================
// Funcao de BROWSE
//===========================================================================================================
	oMBrowse	:= FwMBrowse():New()
	oMBrowse:SetAlias( "DYL" )
	oMBrowse:SetDescription( OemToAnsi(STR0001) )
	oMBrowse:Activate()

EndIf

Return

//===========================================================================================================
/* Retorna o modelo de Dados da rotina Tipos de Identificacao de Produto
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		07/02/2013
@return 	oModel - Modelo de Dados */
//===========================================================================================================

Static Function ModelDef()

Local oModel		:= Nil
Local oStruDYL	:= FwFormStruct( 1, "DYL" )

oModel	:= MpFormModel():New( "TMSA016", /*bPre*/, , , /*bCancel*/ )

oModel:SetDescription( OemToAnsi(STR0001) )	 

oModel:AddFields( "MdFieldDYL", Nil, oStruDYL )

oModel:SetPrimaryKey( { "DYL_FILIAL", "DYL_TPIDPD" } )

Return( oModel ) 

//===========================================================================================================
/* Retorna a View (tela) da rotina Identificacao de Produto
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		07/02/2013
@return 	oView -  */
//===========================================================================================================
Static Function ViewDef()

Local oModel	:= FwLoadModel( "TMSA016" )
Local oView		:= Nil
Local oStruDYL	:= FwFormStruct( 2, "DYL" )

oView := FwFormView():New()

oView:SetModel( oModel )

oView:CreateHorizontalBox( "Field"	, 100 )

oView:AddField( "VwFieldDYL", oStruDYL, "MdFieldDYL"	)

oView:SetOwnerView( "VwFieldDYL"	, "Field"	)

Return( oView )

//===========================================================================================================
/* Retorna as operações disponiveis para a Identificacao de Produto
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		07/02/2013
@return 	aRotina - Array com as opçoes de Menu */
//===========================================================================================================
Static Function MenuDef()

Local aRotina		:= {	{ STR0002		,"AxPesqui"				,0 , 1,,.F. },;  	//"Pesquisar"
							{ STR0003		,"VIEWDEF.TMSA016"		,0 , 2 },;  		//"Visualizar"
							{ STR0004		,"VIEWDEF.TMSA016"		,0 , 3 },;  		//"Incluir"
							{ STR0005		,"VIEWDEF.TMSA016"		,0 , 4 },;  		//"Alterar"
							{ STR0006		,"VIEWDEF.TMSA016"		,0 , 5 } }  		//"Excluir"
						
Return( aRotina ) 

//===========================================================================================================
/* Validacao de Campo (X3_WHEN) para a Identificacao de Produto
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		07/02/2013
@return 	aRotina - Array com as opçoes de Menu */
//===========================================================================================================
Function TMSA016Whe()       

Local lRet   := .T.   

If !Inclui
	lRet:= .F.
EndIf
	
Return( lRet )
