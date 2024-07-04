#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'PLSDPS3.ch'


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSDPS3
Tela inicial do Lote de DPS.
@since  02/2021
//-------------------------------------------------------------------*/
function PLSDPS3(lAutoma)
local cFiltro   := "@(BQ4_FILIAL = '" + xFilial("BQ4") + "' AND BQ4_CODOPE = '" + BQ2->BQ2_CODOPE + "' AND BQ4_CODSEQ = '" + BQ2->BQ2_CODSEQ + "')"
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )	 

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('BQ4')
oBrowse:SetFilterDefault(cFiltro)
oBrowse:SetMenuDef('PLSDPS3')
oBrowse:SetDescription(STR0001) //DPS - Histórico do Lote
iif(!lAutoma, oBrowse:Activate(), '')

return 


/*//-------------------------------------------------------------------
{Protheus.doc} MenuDef
MenuDef
@since    02/2021
//-------------------------------------------------------------------*/
static function MenuDef()
Local aRotina := {}

Add Option aRotina Title STR0003 Action 'VIEWDEF.PLSDPS3' Operation 2 Access 0 //'Visualizar'
Add Option aRotina Title STR0006 Action 'PlDPS3Base()'    Operation 2 Access 0 //'Base Conhec.'

return aRotina


/*//-------------------------------------------------------------------
{Protheus.doc} ModelDef
ModelDef
@since    02/2021
//-------------------------------------------------------------------*/
Static function ModelDef()
Local oModel    := nil     
Local oStrBQ4   := FWFormStruct(1,'BQ4')

oModel := MPFormModel():New('PLSDPS3')

oModel:addFields('MASTERBQ4',,oStrBQ4) 

oModel:GetModel('MASTERBQ4'):SetDescription(STR0001) //DPS - Histórico do Lote
return oModel


/*//-------------------------------------------------------------------
{Protheus.doc} ViewDef
ViewDef
@since    02/2021
//-------------------------------------------------------------------*/
Static function ViewDef()
Local oView     := nil
Local oModel  	:= FWLoadModel( 'PLSDPS3' )
Local oStrBQ4   := FWFormStruct(2, 'BQ4' )

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('ViewBQ4' , oStrBQ4,'MASTERBQ4' )

oView:CreateHorizontalBox( 'SUPERIOR' , 100 )

oView:SetOwnerView('ViewBQ4','SUPERIOR')

oView:SetCloseOnOK( { || .t. } )

oView:SetDescription(STR0001) //DPS - Histórico do Lote
oView:EnableTitleView('ViewBQ4', STR0002) //Detalhes 

return oView


/*//-------------------------------------------------------------------
{Protheus.doc} PlDPS3Base
ViewDef
@since    02/2021
//-------------------------------------------------------------------*/
Function PlDPS3Base() 
    Private aRotina := {}
        
    If AllTrim(BQ4->BQ4_SEQPRO) <> ""

        aRotina := {{"Conhecimento",'MsDocument',0/*permite exclusao do registro*/,1/*visualizar arquivo*/},{"Inclusão Rápida",'PLSDOcs',0,3}}
        MsDocument( "BQ4", BQ4->( RecNo() ), 2 )
    else
        Help(nil, nil , STR0005 , nil, STR0004, 1, 0, nil, nil, nil, nil, nil,nil)  //"Atenção" ### "Não é possível utilizar o Banco de Conhecimento"
    EndIf

Return .T.
