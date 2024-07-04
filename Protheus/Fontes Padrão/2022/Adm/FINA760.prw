#Include "Protheus.ch"
#Include "FWMVCDef.ch"
#Include "FINA760.ch"

/*/{Protheus.doc} FINA760
Rotina de cadastro de situações do documento hábil 

@author Pedro Alencar	
@since 14/10/2014	
@version P12.1.2
/*/
Function FINA760()
    Local oBrowse

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias( "FVJ" )
    oBrowse:SetDescription( OemToAnsi(STR0001) ) //"situações do Documento Hï¿½bil"

    oBrowse:SetMenuDef( "FINA760" )
    oBrowse:Activate()
Return Nil

/*/{Protheus.doc} MenuDef
Definição do menu da tela de cadastro de situações do documento hábil

@author Pedro Alencar	
@since 14/10/2014	
@version P12.1.2
/*/
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE OemToAnsi(STR0002) ACTION "VIEWDEF.FINA760" OPERATION 2 ACCESS 0 //"Visualizar"
Return aRotina

/*/{Protheus.doc} ModelDef
Definição do Model da tela de cadastro de situações do documento hábil

@author Pedro Alencar	
@since 14/10/2014	
@version P12.1.2
/*/
Static Function ModelDef()
    Local oStruFVJ := FWFormStruct(1,"FVJ")
    Local oStruFV4      := FWFormStruct(1,"FV4")
    Local oStruFVK      := FWFormStruct(1,"FVK")
    Local oModel
    Local aRelation     := { { "FV4_FILIAL", "FWxFilial('FV4')" } , { "FV4_SITUAC", "FVJ_ID" }  }
    Local aRelation2    := { { "FVK_FILIAL", "FWxFilial('FVK')" } , { "FVK_SITUAC", "FVJ_ID" }  }
    Local nIndFVK       := Iif(FWSIXUtil():ExistIndex('FVK' , '2'), 2,1)

    oModel := MPFormModel():New( "FINA760" )
    oModel:AddFields( "FVJMASTER", , oStruFVJ )
    oModel:AddGrid( "FV4DETAIL", "FVJMASTER", oStruFV4 )
    oModel:AddGrid( "FVKDETAIL", "FVJMASTER", oStruFVK )

    oModel:GetModel("FV4DETAIL"):SetUniqueLine({"FV4_IDCAMP"})
    oModel:SetRelation( "FV4DETAIL", aRelation, FV4->( IndexKey( 1 ) ) )
    oModel:SetRelation( "FVKDETAIL", aRelation2, FVK->( IndexKey( nIndFVK ) ) )
Return oModel

/*/{Protheus.doc} ViewDef
Definição do view da tela de cadastro de situações do documento hábil

@author Pedro Alencar	
@since 14/10/2014	
@version P12.1.2
/*/
Static Function ViewDef()
    Local oModel   := FWLoadModel( "FINA760" )
    Local oStruFVJ := FWFormStruct( 2, "FVJ" )
    Local oStruFV4 := FWFormStruct( 2, "FV4" )
    Local oStruFVK := FWFormStruct( 2, "FVK" )
    Local oView

    oStruFVJ:RemoveField("FVJ_PREDOC")

    oView := FWFormView():New()
    oView:SetModel( oModel )

    oStruFV4:RemoveField( "FV4_IDCAMP" )
    oStruFVK:RemoveField( "FVK_SITUAC" )
    oStruFVK:RemoveField( "FVK_NSITUA" )

    oView:AddField( "ViewField", oStruFVJ, "FVJMASTER" )
    oView:AddGrid( "ViewGridFVK", oStruFVK, "FVKDETAIL" )
    oView:AddGrid( "ViewGridFV4", oStruFV4, "FV4DETAIL" )

    oView:CreateHorizontalBox( "ViewFVJ", 20 )
    oView:CreateHorizontalBox( "GridFVK", 30 )
    oView:CreateHorizontalBox( "GridFV4", 50 )

    oView:SetOwnerView( "ViewField", "ViewFVJ" )
    oView:SetOwnerView( "ViewGridFVK", "GridFVK" )
    oView:SetOwnerView( "ViewGridFV4", "GridFV4" )

    oView:EnableTitleView( "ViewField", OemToAnsi(STR0003) ) //"Informações da Situação"
    oView:EnableTitleView( "ViewGridFV4", OemToAnsi(STR0004) ) //"Campos Variáveis da Situação"
    oView:EnableTitleView( "ViewGridFVK", OemToAnsi(STR0005) ) //"Tipos de Documento e Seções Permitidas"

Return oView
