#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWBROWSE.CH'
#Include 'topconn.ch'
#include 'PLSUNISW2.CH'

//-------------------------------------------------------------------
/*/ {Protheus.doc} PLSUNISW2
Tela de cadastro de Serviços para Classificação de Rede - W2
@since 09/2019
@version P12 
/*/
//-------------------------------------------------------------------
Function PLSUNISW2(lAutoma)
Local oBrowse
local cFiltro := ""
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )

cFiltro := "@(B5V_FILIAL = '" + xFilial("B5V") + "') "

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B5V')
oBrowse:SetFilterDefault(cFiltro)
oBrowse:SetDescription(STR0001) //Serviços para Classificação de Rede - W2
if !lAutoma
    oBrowse:Activate()
endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menus
@since 09/2019
@version P12 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title  STR0002	Action 'VIEWDEF.PLSUNISW2' 	Operation 2 Access 0  //Visualizar
Add Option aRotina Title  STR0003 	Action "VIEWDEF.PLSUNISW2" 	Operation 3 Access 0  //Incluir
Add Option aRotina Title  STR0004	Action "VIEWDEF.PLSUNISW2" 	Operation 4 Access 0  //Alterar
Add Option aRotina Title  STR0005	Action "VIEWDEF.PLSUNISW2"	Operation 5 Access 0  //Excluir

Return aRotina



//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados.
@since 09/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrB5V	:= FWFormStruct(1,'B5V')

oModel := MPFormModel():New( 'PLSUNISW2') 
oModel:AddFields( 'B5VMASTER', /*cOwner*/, oStrB5V )
oStrB5V:SetProperty( 'B5V_CODIGO' , MODEL_FIELD_VALID,  { || PLSCADREP(oModel) } )
oStrB5V:SetProperty( 'B5V_CODIGO', MODEL_FIELD_OBRIGAT, .t. )
oStrB5V:SetProperty( 'B5V_DESCRI', MODEL_FIELD_OBRIGAT, .t. )
oModel:GetModel( 'B5VMASTER' ):SetDescription( STR0001 ) //Serviços para Classificação de Rede - W2

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface.
@since 09/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView 
Local oModel	:= FWLoadModel( 'PLSUNISW2' ) // Cria as estruturas a serem usadas na View
Local oStrB5V	:= FWFormStruct(2,'B5V')

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_B5V', oStrB5V, 'B5VMASTER' )
oView:CreateHorizontalBox( 'SUPERIOR', 100 )
oView:SetOwnerView( 'VIEW_B5V', 'SUPERIOR' )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCADOK
Valida a inclusão do Registro.
@since 09/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function PLSCADREP(oModel)
Local lRet		:= .T.
local cSql      := ""
local nDadoRep  := oModel:getModel("B5VMASTER"):getValue("B5V_CODIGO")

cSql := " SELECT B5V_FILIAL FROM " + RetSqlName("B5V") 
cSql += " WHERE B5V_FILIAL = '"    + xFilial("B5V") + "' "
cSql += " AND B5V_CODIGO =  '"     + alltrim(str(nDadoRep)) + "' "
cSql += " AND D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"VerRep",.f.,.t.)\

if ( !VerRep->(eof()) )
    lRet := .f.
    Help(nil, nil , STR0006, nil, STR0007, 1, 0, nil, nil, nil, nil, nil, {""} )
endif 

VerRep->(dbclosearea())
       
Return lRet