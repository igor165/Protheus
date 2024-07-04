#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#Include "FISA300I.ch" 
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA300I

Rotina para visualizações genéricas, como títlos
basta enviar o filtro do browse, alias e descrição.
 
@author Erick G. Dias
@since 01/07/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Function FISA300I(cAlias, cDescr, cFiltro)

Local oBrw := FWmBrowse():New()

PRIVATE c300IAls := cAlias

oBrw:SetDescription(cDescr)
oBrw:SetAlias(cAlias)
oBrw:SetMenuDef('FISA300I')
oBrw:DisableDetails()
oBrw:ForceQuitButton()
oBrw:SetFilterDefault( cFiltro )
oBrw:Activate()  

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Erick G. Dias
@since 01/07/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function MenuDef()   

Local aRotina := {}

ADD OPTION aRotina TITLE STR0001 ACTION 'VIEWDEF.FISA300I' OPERATION 2 ACCESS 0 //"Visualizar"
		
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Erick G. Dias
@since 01/07/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruGener := NIL
Local oModel := NIL
Local cCmpoPK := ""

Default c300IAls := "SE2"

oStruGener := FWFormStruct(1, c300IAls)
cCmpoPK := Iif(SubStr(c300IAls,1,1) == 'S', SubStr(c300IAls,2,2), c300IAls) + '_FILIAL'

oModel	:=	MPFormModel():New('FISA300I',,{ |oModel| .T. } , { |oModel| .T. } )

oModel:AddFields( 'MODEL_GEN' ,, oStruGener )

//A passagem de chave primária para o modelo se deve ao fato de existirem tabelas do legado do sistema que não possuem
//chave primária definida X2_UNICO, para estas tabelas exibe erro.
//Por este motivo passo de forma genérica a filial para o modelo para não ficar sem nenhuma chave primária
//e exibir tanto as tabelas que está corretas quanto as tabelas de legado.
oModel:SetPrimaryKey( {cCmpoPK} )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Erick G. Dias
@since 01/07/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel     := FWLoadModel('FISA300I')
Local oStruGener := Nil
Local oView      := FWFormView():New()
Local cDescri    := STR0002 //'Visualização'

oView:SetModel( oModel )
oStruGener := FWFormStruct( 2, c300IAls)
oView:AddField( 'VIEW_GEN', oStruGener, 'MODEL_GEN' )

oView:EnableTitleView( 'VIEW_GEN', cDescri )

Return oView 

 