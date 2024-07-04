#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWBROWSE.CH'
#Include 'topconn.ch'
#include 'PLSA165.ch' 
#include 'TOTVS.ch'
//-------------------------------------------------------------------
/*/ {Protheus.doc} PLSA165
Tela de Locais de locais de digitação 
@since 03/2020
@version P12 
/*/
//-------------------------------------------------------------------
Function PLSA165(lAutoma)
Local oBrowse
local cFiltro := ""
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )

cFiltro := "@(BCG_FILIAL = '" + xFilial("BCG") + "') "

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('BCG')
oBrowse:SetFilterDefault(cFiltro)
oBrowse:SetDescription(STR0001) //locais de digitação
if !lAutoma
    oBrowse:Activate()
endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDefAd
Menus
@since 03/2020
@version P12 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title  STR0002	Action 'VIEWDEF.PLSA165' 	Operation 2 Access 0  //Visualizar
Add Option aRotina Title  STR0003 	Action "VIEWDEF.PLSA165" 	Operation 3 Access 0  //Incluir
Add Option aRotina Title  STR0004	Action "VIEWDEF.PLSA165" 	Operation 4 Access 0  //Alterar
Add Option aRotina Title  STR0005	Action "PlsVldExcl()"	Operation 5 Access 0  //Excluir
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados.
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrBCG	:= FWFormStruct(1,'BCG')

oModel := MPFormModel():New( 'PLSA165') 
oModel:AddFields( 'BCGMASTER', /*cOwner*/, oStrBCG )
oStrBCG:SetProperty( 'BCG_CODLDP', MODEL_FIELD_VALID,  { || PLSCADREP(oModel) } )
oModel:GetModel( 'BCGMASTER' ):SetDescription( STR0001 )
oModel:SetPrimaryKey( { "BCG_FILIAL", "BCG_CODOPE","BCG_CODLDP"} ) 
Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface.
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView 
Local oModel	:= FWLoadModel( 'PLSA165' ) // Cria as estruturas a serem usadas na View
Local oStrBCG	:= FWFormStruct(2,'BCG')

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_BCG', oStrBCG, 'BCGMASTER' )
oView:CreateHorizontalBox( 'SUPERIOR', 100 )
oView:SetOwnerView( 'VIEW_BCG', 'SUPERIOR' )
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCADOK
Valida a inclusão do Registro.
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function PLSCADREP(oModel)
Local lRet		:= .T.
local cSql      := ""
local cDadoRep  := oModel:getModel("BCGMASTER"):getValue("BCG_CODLDP")
local cCodope   := oModel:getModel("BCGMASTER"):getValue("BCG_CODOPE")
local lStrLoc   := cDadoRep $ ( getNewPar("MV_PLSLDPAD","0001") + '/' + getNewPar("MV_PLSXMLP","0002") + '/' + getNewPar("MV_PLSPTUL","0003") + '/' + getNewPar("MV_PLSDIGP","8000") + '/' +;
                   getNewPar("MV_PLSPEGE","0000")  + '/' + GetNewPar("MV_PLSLLIB","9999") + '/' + getNewPar("MV_PLSPREM","9000") + '/9999')
if ! lStrLoc 
   cSql := " SELECT BCG_CODLDP FROM " + RetSqlName("BCG") 
   cSql += " WHERE BCG_FILIAL = '"    + xFilial("BCG") + "' "
   cSql += " AND BCG_CODLDP =  '"     + alltrim(cDadoRep) + "' " 
   cSql += " AND BCG_CODOPE = '"      + alltrim(cCodope) + "' "
   cSql += " AND D_E_L_E_T_ = ' ' "   

   dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"VerRep",.f.,.t.)

   if ( !VerRep->(eof()) )
      lRet := .f.
      Help(nil, nil , STR0007, nil, STR0006, 1, 0, nil, nil, nil, nil, nil, {STR0010}) //Atenção / "Este código está ativo na tabela para a mesma operadora. Verifique o código correto."
   endif 

   VerRep->(dbclosearea()) 
   else 
      lRet := .f.
      Help(nil, nil , STR0007, nil,STR0008, 1, 0, nil, nil, nil, nil, nil, {STR0010} ) //Atenção / "O valor informado esta ativo nos parâmetros dos locais de digitação."       
   endif
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsVldExcl
Valida a Exclusão do Registro.
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------

Function PlsVldExcl()
Local lRet := .T.

   BCI->(dbSetOrder(1))
   if  BCI->(Dbseek(xFilial("BCI")+BCG->BCG_CODOPE+BCG->BCG_CODLDP))
      Help(nil, nil , STR0007, nil,STR0009 , 1, 0, nil, nil, nil, nil, nil, {""} ) //"Este código de locais de digitação esta sendo utilizado na tabela de Pegs."
      lRet:=.F.
   else
      FWExecView('Excluir'	,'PLSA165', MODEL_OPERATION_DELETE	,, { || .T. } )
   Endif   
return lret