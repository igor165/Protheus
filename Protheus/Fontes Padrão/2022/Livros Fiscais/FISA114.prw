#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA114

@author Graziele Paro
@since 14/12/2015
@version 11

/*/
//-------------------------------------------------------------------
Function FISA114(cFiltro)
    
    Local   oBrowse := Nil
    
    
    IF  AliasIndic("F0H")
        
        oBrowse := FWMBrowse():New()
        
        oBrowse:SetMenuDef( 'FISA114' )
        oBrowse:DisableDetails()
        oBrowse:ForceQuitButton()
        oBrowse:SetAlias("F0H")
        oBrowse:SetDescription("Log Saldos")
        oBrowse:SetFilterDefault( cFiltro )
        oBrowse:Activate()
    Else
        Help("",1,"Help","Help","Tabela F0H não cadastrada no sistema!",1,0)
    EndIf
    
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Graziele Paro
@since 14/12/2015
@version 11
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
    
    Local aRotina := {}
    
    ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.FISA114' OPERATION 2 ACCESS 0 //"Visualizar"
    
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC


@author Graziele Paro
@since 14/12/2015
@version 11
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
    
    
    Local oModel    := Nil
    Local oStructCab := FWFormStruct(1, "F0H",)
    
    oModel  :=  MPFormModel():New('FISA114MOD',/*bPre*/,/*bPos*/,/*bCommit*/, /*bCancel*/)
    
    oModel:AddFields('FISA114MOD' ,, oStructCab )
    
Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Graziele Paro
@since 14/12/2015
@version 11
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
    
    
    Local oModel     := FWLoadModel( "FISA114" )
    Local oStructCab := FWFormStruct(2, "F0H")
    
    Local oView := Nil
    
    oView := FWFormView():New()
    oView:SetModel( oModel )
    oView:AddField( "VIEW" , oStructCab , 'FISA114MOD')
    
Return oView
