#Include "Protheus.ch"
#Include "TMSA039.ch"
#Include "FWMVCDEF.CH"

/*
-----------------------------------------------------------
{Protheus.doc} TMSA039()
Cadastro de Tipo de Operação da Viagem

Uso: SIGATMS

@sample
//TMSA039()

@author Katia Tiemi
@since 19/10/2018
@version 1.0
-----------------------------------------------------------
*/
Function TMSA039()

Local oMBrowse	:= Nil
Private aRotina	:= MenuDef()

oMBrowse	:= FwMBrowse():New()
oMBrowse:SetAlias( "DLO" )
oMBrowse:SetDescription( OemToAnsi(STR0001) )
oMBrowse:Activate()

Return

/*
-----------------------------------------------------------
{Protheus.doc} ModelDef()
Definição do Modelo

Uso: TMSA039

@sample
//ModelDef()

@author Katia
@since 19/10/2018
@version 1.0
-----------------------------------------------------------
*/

Static Function ModelDef()

Local oModel	:= Nil
Local oStruDLO	:= FwFormStruct( 1, "DLO" )

oModel	:= MpFormModel():New( "TMSA039", /*bPre*/, /*bPos*/, { |oModel| CommitMdl( oModel ) }, /*bCancel*/ )

oModel:SetDescription( OemToAnsi(STR0001) )

oModel:AddFields( "MdFieldDLO", Nil, oStruDLO )

oModel:SetPrimaryKey( { "DLO_FILIAL", "DLO_CODIGO" } )

Return( oModel )

/*
-----------------------------------------------------------
{Protheus.doc} ViewDef()
Definição da View

Uso: TMSA039

@sample
//ViewDef()

@author Katia
@since 19/10/2018
@version 1.0
-----------------------------------------------------------
*/
Static Function ViewDef()

Local oModel	:= FwLoadModel( "TMSA039" )
Local oView		:= Nil
Local oStruDLO	:= FwFormStruct( 2, "DLO" )

oView := FwFormView():New()

oView:SetModel( oModel )

oView:CreateHorizontalBox( "Field"	, 100 )

oView:AddField( "VwFieldDLO", oStruDLO, "MdFieldDLO"	)

oView:SetOwnerView( "VwFieldDLO"	, "Field"	)

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} CommitMdl
Gravacao dos dados do Tipo de Operação da Viagem

Uso: TMSA039

@sample
//CommitMdl()

@author Katia
@since 19/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CommitMdl( oMdl )

Local lRet	:= .T.

lRet := FwFormCommit( oMdl )

Return( lRet )

/*
-----------------------------------------------------------
{Protheus.doc} MenuDef()
Utilizacao de menu Funcional  

Uso: TMSA039

@sample
//MenuDef()

@author Katia
@since 19/10/2018
@version 1.0
-----------------------------------------------------------
*/
Static Function MenuDef()

Local aRotina		:= {	{ STR0002		,"AxPesqui"				,0 , 1,,.F. },;  	//"Pesquisar"
							{ STR0003		,"VIEWDEF.TMSA039"		,0 , 2 },;  		//"Visualizar"
							{ STR0004		,"VIEWDEF.TMSA039"		,0 , 3 },;  		//"Incluir"
							{ STR0005		,"VIEWDEF.TMSA039"		,0 , 4 },;  		//"Alterar"
							{ STR0006		,"VIEWDEF.TMSA039"		,0 , 5 } }  		//"Excluir"

Return( aRotina )
