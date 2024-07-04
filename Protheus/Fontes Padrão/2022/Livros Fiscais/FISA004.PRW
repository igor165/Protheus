#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA004
 
@author Erick G. Dias
@since 26/09/2013
@version 11.90

/*/
//-------------------------------------------------------------------
Function FISA004(cAlias,cDescr)
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription(cDescr)
//oBrw:SetAlias( cAlias)
oBrw:SetMenuDef( 'FISA004' )	
oBrw:Activate()  

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

Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.FISA004' OPERATION 2 ACCESS 0 //"Visualizar"
		
Return aRotina

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
Local oStruGener 	:= 	FWFormStruct( 1,AS02XALIAS()[1])
Local oModel
Local aAux := {}
Local cCmpoPK	:= Iif(SubStr(AS02XALIAS()[1],1,1) == 'S',SubStr(AS02XALIAS()[1],2,2),AS02XALIAS()[1])+ '_FILIAL'

oModel	:=	MPFormModel():New('FISA004',,{ |oModel| .T. } , { |oModel| .T. } )

oModel:AddFields( 'MODEL_GEN' ,, oStruGener )
//A passagem de chave primária para o modelo se deve ao fato de existirem tabelas do legado do sistema que não possuem
//chave primária definida X2_UNICO, para estas tabelas exibe erro.
//Por este motivo passo de forma genérica a filial para o modelo para não ficar sem nenhuma chave primária
//e exibir tanto as tabelas que está corretas quanto as tabelas de legado.
oModel:SetPrimaryKey( {  cCmpoPK} )


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
Local	oModel 			:= 	FWLoadModel( 'FISA004' )
Local	oStruGener 	:= 	Nil
Local	oView 			:= 	FWFormView():New()
Local cDescri			:= 'Visualização'

oView:SetModel( oModel )
oStruGener	:= 	FWFormStruct( 2, AS02XALIAS()[1])
oView:AddField( 'VIEW_GEN', oStruGener, 'MODEL_GEN' )

oView:EnableTitleView( 'VIEW_GEN', cDescri )

Return oView 