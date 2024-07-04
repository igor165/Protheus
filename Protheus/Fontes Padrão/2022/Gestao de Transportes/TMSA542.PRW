#Include "Protheus.ch"
#Include "TMSA542.CH"
#INCLUDE "FWMVCDEF.CH"                 

//===========================================================================================================
/* Cadastro de Motivos da Conciliacao
@author  	Katia
@version 	P11 R11.8
@since 	    26/05/2014
@return 	
//===========================================================================================================*/

Function TMSA542(aRotAuto, nOpcAuto)

Local oMBrowse	:= Nil
Local aAutoCab	:= {}
Local l542Auto	:= aRotAuto <> Nil

Private aRotina	:= MenuDef()

Default nOpcAuto:= 3

If l542Auto
	aAutoCab:= Aclone(aRotAuto)
	FwMvcRotAuto( ModelDef(), "DYY", nOpcAuto, {{"MdFieldDYY", aAutoCab}} ) //Chamada da rotina Automatica MVC	
Else                                                                                                            
//===========================================================================================================
// Funcao de BROWSE
//===========================================================================================================
	oMBrowse:= FWMBrowse():New()
	oMBrowse:SetAlias("DYY")
	oMBrowse:SetDescription(OemToAnsi( STR0001 ))
	oMBrowse:Activate()
EndIf 

Return

//===========================================================================================================
/* Retorna o modelo de Dados da rotina Cadastro de Motivos
@author  	Katia
@version 	P11 R11.8
@since 		29/04/2014
@return 	oModel - Modelo de Dados */
//===========================================================================================================

Static Function ModelDef()
Local oModel	:= Nil
Local oStruDYY	:= FwFormStruct( 1,"DYY" )

oModel:= MpFormModel():New("TMSA542", /*bPre*/, /*bPos*/, /*bCommit*/, /*bCancel*/ )

oModel:SetDescription(OemToAnsi( STR0001 ))

oModel:AddFields("MdFieldDYY", Nil, oStruDYY)

oModel:SetPrimaryKey({"DYY_FILIAL", "DYY_CODMTC"})

Return (oModel)
               
//===========================================================================================================
/* Retorna a View (tela) da rotina Cadastro de Motivos
@author  	Katia
@version 	P11 R11.8
@build		
@since 		29/04/2014
@return 	oView -  */
//===========================================================================================================

Static Function ViewDef()

Local oModel	:= FwLoadModel( "TMSA542" )
Local oView		:= Nil
Local oStruDYY	:= FwFormStruct( 2, "DYY" )

oView:= FwFormView():New()

oView:SetModel(oModel)

oView:CreateHorizontalBox( "Field", 100)            

oView:AddField( "VwFieldDYY", oStruDYY, "MdFieldDYY" )

oView:SetOwnerView( "VwFieldDYY", "Field" )

Return (oView)

//===========================================================================================================
/* Retorna as operações disponiveis para o Cadastro de Motivos
@author  	Katia
@version 	P11 R11.8
@build		
@since 		29/04/2014
@return 	aRotina - Array com as opçoes de Menu */
//===========================================================================================================
Static Function MenuDef()

Local aRotina		:= {	{ STR0002		,"AxPesqui"				,0 , 1,,.F. },;  	//"Pesquisar"
							{ STR0003		,"VIEWDEF.TMSA542"		,0 , 2 },;  		//"Visualizar"
							{ STR0004		,"VIEWDEF.TMSA542"		,0 , 3 },;  		//"Incluir"
							{ STR0005		,"VIEWDEF.TMSA542"		,0 , 4 },;  		//"Alterar"
							{ STR0006		,"VIEWDEF.TMSA542"		,0 , 5 } }  		//"Excluir"

Return( aRotina )
