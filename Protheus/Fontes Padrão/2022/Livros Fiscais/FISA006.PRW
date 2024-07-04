#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA006
 
@author Erick G. Dias
@since 26/09/2013
@version 11.90

/*/
//-------------------------------------------------------------------
Function FISA006()
Local	oBrw	:= FWmBrowse():New()

IF AliasIndic('CLG')
	DBSelectArea( "FR0" )
	oBrw:SetDescription('Operações com Retenções no registro F600')
	oBrw:SetAlias( 'CLG' )
	oBrw:SetMenuDef( 'FISA006' )	
	oBrw:Activate()  
Else
	Alert('Tabela CLG não foi criada no dicionário, por favor verifique atualização.')
EndIF

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Erick G. Dias
@since 07/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function MenuDef()		
Return FWMVCMenu ("FISA006")

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Erick G. Dias
@since 07/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCLG 	:= 	FWFormStruct( 1,'CLG')
Local oModel

oModel	:=	MPFormModel():New('FISA006' )

oModel:AddFields( 'MODEL_CLG' ,, oStruCLG )
oStruCLG:SetProperty( 'CLG_DTRET'	 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
oStruCLG:SetProperty( 'CLG_CNPJ'	 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })


Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Erick G. Dias
@since 07/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local	oModel 			:= 	FWLoadModel( 'FISA006' )
Local	oStruCLG 	:= 	Nil
Local	oView 			:= 	FWFormView():New()

oView:SetModel( oModel )
oStruCLG	:= 	FWFormStruct( 2, 'CLG')
oView:AddField( 'VIEW_CLG', oStruCLG, 'MODEL_CLG' )

Return oView 