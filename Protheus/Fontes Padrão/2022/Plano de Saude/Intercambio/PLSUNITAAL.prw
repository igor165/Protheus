#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWBROWSE.CH'
#Include 'topconn.ch'
#include 'PLSUNITAAL.ch'

static oBrowse := nil
//-------------------------------------------------------------------
/*/ {Protheus.doc} PLSUNITAAL
Tela de cadastro das Tabelas De Especialidades (Tabela A) e Áreas de Atuação (Tabela L), com filtro.
@since 12/2019
@version P12 
/*/
//-------------------------------------------------------------------
Function PLSUNITAAL(lAutoma, aParamAut)
local cRespFil      := PlFiltraRes(.f., aParamAut)
default lAutoma     := iif( valtype(lAutoma) <> "L", .f., lAutoma )
default aParamAut   := {}

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B5O')
oBrowse:SetFilterDefault(cRespFil)
oBrowse:SetDescription(STR0001) //Cadastro de Especialidades (Tabela A) / Áreas de Atuação (Tabela L)
if !lAutoma
    oBrowse:Activate()
endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menus
@since 12/2019
@version P12 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title  STR0002	Action 'VIEWDEF.PLSUNITAAL' 	Operation 2 Access 0  //Visualizar
Add Option aRotina Title  STR0003 	Action "VIEWDEF.PLSUNITAAL" 	Operation 3 Access 0  //Incluir
Add Option aRotina Title  STR0004	Action "VIEWDEF.PLSUNITAAL" 	Operation 4 Access 0  //Alterar
Add Option aRotina Title  STR0005	Action "VIEWDEF.PLSUNITAAL"	    Operation 5 Access 0  //Excluir
Add Option aRotina Title  STR0008	Action "staticcall(PLSUNITAAL, PlFiltraRes, .t.)"	    Operation 9 Access 0  //Filtra Tela

Return aRotina



//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados.
@since 12/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrB5O	:= FWFormStruct(1,'B5O')

oModel := MPFormModel():New( 'PLSUNITAAL')

oModel:AddFields( 'B5OMASTER', /*cOwner*/, oStrB5O )
oStrB5O:SetProperty( 'B5O_CODIGO', MODEL_FIELD_VALID,  { || PLSCADREP(oModel) } )
oStrB5O:SetProperty( 'B5O_TPTABE', MODEL_FIELD_VALID,  { || PLSCADREP(oModel) } )
oStrB5O:SetProperty( 'B5O_CODIGO', MODEL_FIELD_OBRIGAT, .t. )
oStrB5O:SetProperty( 'B5O_DESCRI', MODEL_FIELD_OBRIGAT, .t. )
oStrB5O:SetProperty( 'B5O_TPTABE', MODEL_FIELD_OBRIGAT, .t. )
oModel:GetModel( 'B5OMASTER' ):SetDescription( STR0001 )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface.
@since 12/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView 
Local oModel	:= FWLoadModel( 'PLSUNITAAL' ) // Cria as estruturas a serem usadas na View
Local oStrB5O	:= FWFormStruct(2,'B5O')

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_B5O', oStrB5O, 'B5OMASTER' )
oView:CreateHorizontalBox( 'SUPERIOR', 100 )
oView:SetOwnerView( 'VIEW_B5O', 'SUPERIOR' )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCADREP
Valida a inclusão do Registro.
@since 12/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function PLSCADREP(oModel)
Local lRet		:= .T.
local cSql      := ""
local cDadoRep  := oModel:getModel("B5OMASTER"):getValue("B5O_CODIGO")
local cTipTab   := oModel:getModel("B5OMASTER"):getValue("B5O_TPTABE")

cSql := " SELECT B5O_FILIAL FROM " + RetSqlName("B5O") 
cSql += " WHERE B5O_FILIAL = '"    + xFilial("B5O") + "' "
cSql += " AND B5O_CODIGO =  '"     + cDadoRep + "' "
cSql += " AND B5O_TPTABE =  '"     + cTipTab + "' "    
cSql += " AND D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"VerRep",.f.,.t.)

if ( !VerRep->(eof()) )
    lRet := .f.
    Help(nil, nil , STR0006, nil, STR0007, 1, 0, nil, nil, nil, nil, nil, {""} ) //Atenção / "Este código está ativo na tabela. Verifique o código correto."
endif 

VerRep->(dbclosearea()) 

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PlFiltraRes
Filtro da Tela
@since 12/2019
@version P12
/*/
//-------------------------------------------------------------------
static function PlFiltraRes(lFiltMen, aParamAut)
local aPergs        := {}
Local aRetP         := {}
local cResp         := ""
local cFiltro       := ""
default lFiltMen    := .f.
default aParamAut   := {}

//Filtro de Tipo de Tabela
aAdd(aPergs, {2,"Selecione o Filtro: ",1,{"1=Tabela A", "2=Tabela L", "3=Todos"},50,"",.F.})

if ( Len(aParamAut) > 0 )
    cResp := aParamAut[1]
elseif ( paramBox( aPergs,"Filtro de Tela",aRetP,/*bOK*/,/*aButtons*/,.t.,100,100,/*oDlgWizard*/,/*cLoad*/,/*lCanSave*/.F.,/*lUserSave*/.F. ) )
    cResp := iif( valtype(aRetP[1]) != "C", cValtochar(aRetP[1]), aRetP[1]) //Se 1ª opção do combo, retornava númerico
endif

cFiltro := "@(B5O_FILIAL = '" + xFilial("B5O") + "'" + iif(!empty(cResp) .and. cResp != "3", " AND B5O_TPTABE = '" + cResp + "')", ")") 

if lFiltMen
    oBrowse:SetFilterDefault(cFiltro)
    oBrowse:Refresh()
endif

return cFiltro