#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWBROWSE.CH'
#Include 'Totvs.CH'
#Include 'topconn.ch'
#include 'PLSBRASIN2.ch'

static cFonte    := iif(IsInCallStack('PLSBRASIN1'),"B",iif(IsInCallStack('PLSSIMPRO'),"S","A"))
static cString   := iif(cFonte=="B",STR0001,iif(cFonte=="S",STR0013,STR0014)) //Bransindice, Simpro ou A900
static cStrFilt  := iif(cFonte=="B","' AND B6G_TPARQ = '1' )",iif(cFonte=="S","' AND B6G_TPARQ = '2' )","' AND B6G_TPARQ = '3' )"))
static cTipArq   := iif(cFonte == "B","1",iif(cFonte == "S","2",iif(cFonte == "A","3",""))) //Tipo de Arquivo

//-------------------------------------------------------------------
/*/ {Protheus.doc} PLSBRASIN2
Tela inicial de Importações da Brasíndice
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
Function PLSBRASIN2(lAutoma)
Local oBrowse   := nil
local cFiltro   := "" 
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )
    
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B6G')

oBrowse:SetDescription(cString) //Configuração de Importação da Brasíndice®
cFiltro:="@(B6G_FILIAL = '" + xFilial("B6G") + "' AND B6G_CODOPE = '" + PlsIntPad() + cStrFilt

oBrowse:SetFilterDefault(cFiltro)
oBrowse:SetMenuDef('PLSBRASIN2')

iif( !lAutoma, oBrowse:Activate(), "")

Return nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menus
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title  STR0002 	Action 'VIEWDEF.PLSBRASIN2'     Operation 3 Access 0  //Incluir
Add Option aRotina Title  STR0003   Action 'VIEWDEF.PLSBRASIN2'     Operation 4 Access 0  //Alterar
Add Option aRotina Title  STR0004	Action 'VIEWDEF.PLSBRASIN2' 	Operation 2 Access 0  //Visualizar
Add Option aRotina Title  STR0005	Action 'VIEWDEF.PLSBRASIN2'     Operation 5 Access 0  //Excluir

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados.
@since 04/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel    := nil
Local oStrB6G	:= FWFormStruct(1,'B6G')
local lTPARQ := .f. 

//fins de automação
private lAutPV  := iif( valtype(lAutPV) <> "L", .f., lAutPV )
lTPARQ := iif(lAutPV,.t.,lAutPV) // automação pode alterar o B6G_TPARQ o usuario nao

oModel := MPFormModel():New( 'PLSBRASIN2', , {||PlsCadOk(oModel)}) 
oModel:AddFields( 'B6GMASTER', /*cOwner*/, oStrB6G )
                                         
oStrB6G:setProperty("B6G_CODOPE" , MODEL_FIELD_INIT , { || PlsIntPad()} )
oStrB6G:setProperty("B6G_CODIGO" , MODEL_FIELD_INIT , { || GetSx8Num('B6G', 'B6G_CODIGO')} )
oStrB6G:setProperty("B6G_TPARQ"  , MODEL_FIELD_INIT , { || cTipArq })//1=Brasindice;2=Simpro;3=A900

oStrB6G:SetProperty("B6G_TIPO"   , MODEL_FIELD_VALID, { || ChkVlrDup("2",oModel)[1] } )
oStrB6G:SetProperty("B6G_TIPPRO" , MODEL_FIELD_WHEN , { || oModel:GetOperation() == MODEL_OPERATION_INSERT} )
oStrB6G:SetProperty("B6G_TIPO"   , MODEL_FIELD_WHEN , { || iif(cFonte == "B", iif( oModel:GetModel("B6GMASTER"):getvalue("B6G_TIPPRO") $ "1/3" .and.;
                                                        oModel:GetModel("B6GMASTER"):getvalue("B6G_TIPO") == "2", .f., .t.),.t.)} )
oStrB6G:setProperty("B6G_TPARQ"  , MODEL_FIELD_WHEN ,{ ||lTPARQ })
oModel:GetModel( 'B6GMASTER' ):SetDescription( STR0001 )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface.
@since 04/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView 
Local oModel	:= FWLoadModel( 'PLSBRASIN2' )
Local oStrB6G	:= FWFormStruct(2,'B6G', {|cCampo|PlCmpTab(cCampo)})
local aRetComb  := {}

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField( 'ViewB6G', oStrB6G, 'B6GMASTER' ) 
oView:CreateHorizontalBox( 'SUPERIOR', 100 )
oView:SetOwnerView( 'ViewB6G', 'SUPERIOR' )
oStrB6G:SetProperty( 'B6G_CODPAD' , MVC_VIEW_ORDEM, "06" )
oView:SetFieldAction('B6G_TIPPRO', { |oView| AtuCmpVal(oView, "1")}) 
oView:SetFieldAction('B6G_CRITDE', { |oView| AtuCmpVal(oView, "2")})
oView:SetDescription(cString) // Brasindíce, Simpro, ou A900

aRetComb:= PlRetComB()
oStrB6G:SetProperty("B6G_TIPPRO", MVC_VIEW_COMBOBOX, aRetComb[1] )
oStrB6G:SetProperty("B6G_TIPO", MVC_VIEW_COMBOBOX,  aRetComb[2] )
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} PlCmpTab
Campos que devem ser exibidos no form
@since 04/2020
@version P12
/*/
//-------------------------------------------------------------------
static function PlCmpTab(cCampo)
Local lRet := .f.

if !(alltrim(cCampo) $ 'B6G_CODOPE,B6G_DATINC,B6G_CODIGO')
	lRet := .t.
endif

return lRet


//-------------------------------------------------------------------
/*/ {Protheus.doc} ChkVlrDup
Verifica valores repetidos na tabela B6G ou preenche array com os dados da tabela
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function ChkVlrDup(cOrigem, oModel, cOperad,lAutoma)
local lOriSin2  := iif( cOrigem == "2", .t., .f.)
local aDadRet   := {}
local cTipPro	:= iif( lOriSin2, oModel:getModel("B6GMASTER"):getValue("B6G_TIPPRO"), "" )
local cTipo		:= iif( lOriSin2, oModel:getModel("B6GMASTER"):getValue("B6G_TIPO"), "" )
local cCodOpe	:= iif( lOriSin2, oModel:getModel("B6GMASTER"):getValue("B6G_CODOPE"), cOperad )
local cSql		:= ""
local cSqlComp  := ""
local lRet 		:= .t.
default lAutoma := .f.


if lOriSin2
    cSqlComp    := "   AND B6G_TIPPRO = '" + cTipPro + "' "
    cSqlComp    += "   AND B6G_TIPO   = '" + cTipo   + "' "
endif

cSql := " SELECT B6G_CODOPE, B6G_TIPPRO, B6G_TIPO, B6G_REGIMP, R_E_C_N_O_ REC FROM " + RetSqlName("B6G") 
cSql += " WHERE B6G_FILIAL = '"    + xFilial("B6G") + "' "
cSql += "   AND B6G_CODOPE = '"    + cCodOpe        + "' "
cSql += "   AND B6G_TPARQ = '" + cTipArq + "' "
cSql += iif( lOriSin2, cSqlComp, "" ) 
cSql += "   AND D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"VerRep",.f.,.t.)

if ( !VerRep->(eof()) )
    if lOriSin2
        lRet := .f.
        Help(nil, nil , STR0006, nil, STR0007, 1, 0, nil, nil, nil, nil, nil, {STR0008} ) //Atenção / "Já existe cadastro ativo para este Tipo de Procedimento (B6G_TIPPRO) e Tipo de Valor (B6G_TIPO)."
        oModel:getModel("B6GMASTER"):loadValue("B6G_TIPO", "")
    else    
        while !VerRep->(eof())
            aadd(aDadRet, {VerRep->B6G_TIPPRO, VerRep->B6G_TIPO, VerRep->B6G_REGIMP, VerRep->REC, {}, {}})
            VerRep->(dbskip())
        enddo
    endif
elseif !lOriSin2
    lRet := .f.
endif

VerRep->(dbclosearea()) 

return ( {lRet, aDadRet} )


//-------------------------------------------------------------------
/*/ {Protheus.doc} PlsCadOk
Validação Pós-Model
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function PlsCadOk(oModel)
local lRet      := .t.
local cPropTde  := oModel:getModel("B6GMASTER"):getValue("B6G_CRITDE")
local cCodTde   := oModel:getModel("B6GMASTER"):getValue("B6G_CODTDE")
local cCodPad   := oModel:getModel("B6GMASTER"):getValue("B6G_CODPAD")
local aMsg      := {}

if cPropTde == "0" .and. empty(cCodTde)
    lRet := .f.
    aMsg := {STR0009, STR0010} //"Quando a opção 'Cria TDE' for igual a 'Não', informe para qual TDE os procedimentos devem ser importados."
elseif cPropTde == "1" .and. empty(cCodPad)
    lRet := .f.
    aMsg := {STR0011, STR0012} //"Quando a opção 'Cria TDE' for igual a 'Sim', informe o código Tipo Padrão Saúde." 
endif

if !lRet
    Help(nil, nil , STR0006, nil, aMsg[1], 1, 0, nil, nil, nil, nil, nil, {aMsg[2]} ) 
else
    B6G->(confirmSX8())
endif

return lRet


//-------------------------------------------------------------------
/*/ {Protheus.doc} AtuCmpVal
Atualiza informações dos campos B6G_TIPO e B6G_TIPPRO
@since 07/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function AtuCmpVal(oView, cTipo, oModel,lAutoma)
local oObjB6G   := nil//oView:GetModel("B6GMASTER")
local lRet		:= .t.
default oModel  := nil
default lAutoma := .f.

cFonte:= iif(lAutoma,"B",cFonte)//Fins de automação

oObjB6G := iif( empty(oModel), oView:GetModel("B6GMASTER"), oModel )

if cTipo == "1" .and. cFonte =="B"
    if oObjB6G:getvalue("B6G_TIPPRO") $ "1/3"
        oObjB6G:loadvalue("B6G_TIPO", "")
        lRet := oObjB6G:setvalue("B6G_TIPO", "2")
        if !lRet
            oObjB6G:setvalue("B6G_TIPPRO", " ")
            oObjB6G:loadvalue("B6G_TIPO", " ")
        endif
    else
        lRet := oObjB6G:loadvalue("B6G_TIPO", " ")
    endif   
else
    if oObjB6G:getvalue("B6G_CRITDE") == "1" .and. !empty(oObjB6G:getvalue("B6G_CODTDE"))
        oObjB6G:loadvalue("B6G_CODTDE","")
    elseif oObjB6G:getvalue("B6G_CRITDE") == "0" .and. !empty(oObjB6G:getvalue("B6G_CODPAD"))
        oObjB6G:loadvalue("B6G_CODPAD", "")    
    endif
endif

if empty(oModel)
    oView:refresh()
endif

return lRet 


/*/{Protheus.doc} PlRetComB
    (Usado para controlar os valores do X3_CBOX que irão aparecer em tela
     Para que não apareça valores da brasíndice no simpro e vice versa)
    @type  Static Function
    @author user
    @since 31/08/2021
    @version version
    @param : cTipo (1 =B6G_TIPPRO - Tipo Proced.| 2= B6G_TIPO  -Tipo Preço    )
    @return Valores do combo SX3
/*/
Static Function PlRetComB(cTipo)
local aDados    := separa(getsx3cache("B6G_TIPPRO","X3_CBOX"), ";")
local aDadPre   := separa(getsx3cache("B6G_TIPO","X3_CBOX"), ";")
local aRetcBoxT := {{"1=Materiais/2=Medicamentos/3=Soluções"}, {"1=Materiais/2=Medicamentos/4=Perfumaria/5=Saneantes/6=Reagentes"}} // [1] Brasíndice [2]Símpro 
local aRetcBoxP := {{"1=PMC/2=PFB"}, {"1=PMC/2=PFB/3=PUSU"}} // [1] Brasíndice [2]Símpro 
local nFor      := 0                                                                         
local aRet      := {}
local aRetP     := {}
local nPosArr   := 0
DEFAULT cTipo   := ""

//Controle para não aparecer tipo de preço do Símpro no Brasíndice
if cFonte $ "B/S"
    nPosArr := iif(cFonte == "B", 1, 2)
    for nFor := 1 to len(aDados)
        if (Alltrim(aDados[nFor]) $ aRetcBoxT[nPosArr][1])
            Aadd(aRet, Alltrim(aDados[nFor]))
        endif
    next 

    for nFor := 1 to len(aDadPre)
        if (Alltrim(aDadPre[nFor]) $ aRetcBoxP[nPosArr][1])
          Aadd(aRetP, Alltrim(aDadPre[nFor]))
        endif
    next 
else 
    aDados:= aDados  //A900 se implementar no futuro
endif

//È necessário incluir 1 linha em branco se não da erro na tela
 Aadd(aRet, '')
 Aadd(aRetP,'')
Return {aRet,aRetP}
