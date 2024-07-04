#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWBROWSE.CH'
#Include 'topconn.ch'
#include 'PLSUNISW1.ch'

//-------------------------------------------------------------------
/*/ {Protheus.doc} PLSUNISW1
Tela de cadastro de Serviços de Urgência e Emergência do Software de Redes
@since 09/2019
@version P12 
/*/
//-------------------------------------------------------------------
Function PLSUNISW1(lAutoma)
Local oBrowse
local cFiltro := ""
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )

cFiltro := "@(B5U_FILIAL = '" + xFilial("B5U") + "') "

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B5U')
oBrowse:SetFilterDefault(cFiltro)
oBrowse:SetDescription(STR0001) //Cadastro de Serviços de Urgência e Emergência do Software de Redes - W1
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

Add Option aRotina Title  STR0002	Action 'VIEWDEF.PLSUNISW1' 	Operation 2 Access 0  //Visualizar
Add Option aRotina Title  STR0003 	Action "VIEWDEF.PLSUNISW1" 	Operation 3 Access 0  //Incluir
Add Option aRotina Title  STR0004	Action "VIEWDEF.PLSUNISW1" 	Operation 4 Access 0  //Alterar
Add Option aRotina Title  STR0005	Action "VIEWDEF.PLSUNISW1"	Operation 5 Access 0  //Excluir

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
Local oStrB5U	:= FWFormStruct(1,'B5U')

oModel := MPFormModel():New( 'PLSUNISW1') 
oModel:AddFields( 'B5UMASTER', /*cOwner*/, oStrB5U )
oStrB5U:SetProperty( 'B5U_CODIGO', MODEL_FIELD_VALID,  { || PLSCADREP(oModel) } )
oStrB5U:SetProperty( 'B5U_CODIGO', MODEL_FIELD_OBRIGAT, .t. )
oStrB5U:SetProperty( 'B5U_DESCRI', MODEL_FIELD_OBRIGAT, .t. )
oModel:GetModel( 'B5UMASTER' ):SetDescription( STR0001 )

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
Local oModel	:= FWLoadModel( 'PLSUNISW1' ) // Cria as estruturas a serem usadas na View
Local oStrB5U	:= FWFormStruct(2,'B5U')

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_B5U', oStrB5U, 'B5UMASTER' )
oView:CreateHorizontalBox( 'SUPERIOR', 100 )
oView:SetOwnerView( 'VIEW_B5U', 'SUPERIOR' )

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
local nDadoRep  := oModel:getModel("B5UMASTER"):getValue("B5U_CODIGO")

cSql := " SELECT B5U_FILIAL FROM " + RetSqlName("B5U") 
cSql += " WHERE B5U_FILIAL = '"    + xFilial("B5U") + "' "
cSql += " AND B5U_CODIGO =  '"     + alltrim(str(nDadoRep)) + "' "
cSql += " AND D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"VerRep",.f.,.t.)

if ( !VerRep->(eof()) )
    lRet := .f.
    Help(nil, nil , STR0006, nil, STR0007, 1, 0, nil, nil, nil, nil, nil, {""} ) //Atenção / "Este código está ativo na tabela. Verifique o código correto."
endif 

VerRep->(dbclosearea()) 

Return lRet