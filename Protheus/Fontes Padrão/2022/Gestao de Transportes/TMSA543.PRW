#Include "Protheus.ch"
#Include "TMSA543.CH"
#INCLUDE "FWMVCDEF.CH"                 

//===========================================================================================================
/* Cadastro de Responsabilidades
@author  	Katia
@version 	P11 R11.8
@since 	    27/05/2014
@return 	
//===========================================================================================================*/

Function TMSA543(aRotAuto, nOpcAuto)

Local oMBrowse	:= Nil
Local aAutoCab	:= {}
Local l543Auto	:= aRotAuto <> Nil

Private aRotina	:= MenuDef()

Default nOpcAuto:= 3

If l543Auto
	aAutoCab:= Aclone(aRotAuto)
	FwMvcRotAuto( ModelDef(), "DYW", nOpcAuto, {{"MdFieldDYW", aAutoCab}} ) //Chamada da rotina Automatica MVC	
Else                                                                                                            
//===========================================================================================================
// Funcao de BROWSE
//===========================================================================================================
	oMBrowse:= FWMBrowse():New()
	oMBrowse:SetAlias("DYW")
	oMBrowse:SetDescription(OemToAnsi( STR0001 ))
	oMBrowse:Activate()
EndIf 

Return

//===========================================================================================================
/* Retorna o modelo de Dados da rotina Cadastro de Responsabilidades
@author  	Katia
@version 	P11 R11.8
@since 		27/05/2014
@return 	oModel - Modelo de Dados */
//===========================================================================================================

Static Function ModelDef()
Local oModel	:= Nil
Local oStruDYW	:= FwFormStruct( 1,"DYW" )

oModel:= MpFormModel():New("TMSA543", /*bPre*/, /*bPos*/, /*bCommit*/, /*bCancel*/ )

oModel:SetDescription(OemToAnsi( STR0001 ))

oModel:AddFields("MdFieldDYW", Nil, oStruDYW)

oModel:SetPrimaryKey({"DYW_FILIAL", "DYW_CODRSP"})

Return (oModel)
               
//===========================================================================================================
/* Retorna a View (tela) da rotina Cadastro de Responsabilidades
@author  	Katia
@version 	P11 R11.8
@build		
@since 		27/05/2014
@return 	oView -  */
//===========================================================================================================

Static Function ViewDef()

Local oModel	:= FwLoadModel( "TMSA543" )
Local oView		:= Nil
Local oStruDYW	:= FwFormStruct( 2, "DYW" )

oView:= FwFormView():New()

oView:SetModel(oModel)

oView:CreateHorizontalBox( "Field", 100)            

oView:AddField( "VwFieldDYW", oStruDYW, "MdFieldDYW" )

oView:SetOwnerView( "VwFieldDYW", "Field" )

Return (oView)

//===========================================================================================================
/* Retorna as operações disponiveis para o Cadastro de Responsabilidades
@author  	Katia
@version 	P11 R11.8
@build		
@since 		27/05/2014
@return 	aRotina - Array com as opçoes de Menu */
//===========================================================================================================
Static Function MenuDef()

Local aRotina		:= {	{ STR0002		,"AxPesqui"				,0 , 1,,.F. },;  	//"Pesquisar"
							{ STR0003		,"VIEWDEF.TMSA543"		,0 , 2 },;  		//"Visualizar"
							{ STR0004		,"VIEWDEF.TMSA543"		,0 , 3 },;  		//"Incluir"
							{ STR0005		,"VIEWDEF.TMSA543"		,0 , 4 },;  		//"Alterar"
							{ STR0006		,"VIEWDEF.TMSA543"		,0 , 5 } }  		//"Excluir"

Return( aRotina )
