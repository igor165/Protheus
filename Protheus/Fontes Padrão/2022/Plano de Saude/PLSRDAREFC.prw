#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "PLSRDAREFC.CH"

static cTextoCmp	:= ''
static cTextoPrf	:= ''
static oSayCmp		:= nil 

/*//-------------------------------------------------------------------
{Protheus.doc} ModelDef
ModelDef
@since    06/2020
Thiago Rodrigues
//-------------------------------------------------------------------*/
Static function ModelDef()
Local oStrBAU   := FWFormStruct(1,'BAU')
Local oStrBB8   := FWFormStruct(1,'BB8')
Local oStrBAX   := FWFormStruct(1,'BAX')

private cCodInt := PlsIntPad() //inicializador da BB8

oModel := MPFormModel():New('PLSRDAREFC')

oModel:addFields('MASTERBAU',,oStrBAU) 
oModel:AddGrid('BB8Detail', 'MASTERBAU', oStrBB8)
oModel:AddGrid('BAXDetail', 'BB8Detail', oStrBAX)


oModel:SetRelation( 'BB8Detail', { { "BB8_FILIAL", 'xFilial( "BB8" )' } , ;
								   { "BB8_CODIGO", 'BAU_CODIGO' } }     , ;
								   BB8->( IndexKey( 1 ) ) )

oModel:SetRelation( 'BAXDetail', { { "BAX_FILIAL", 'xFilial("BAX")' }, ; 
								   { "BAX_CODIGO", "BB8_CODIGO" }, ;
 								   { "BAX_CODINT", "BB8_CODINT" }, ;
							       { "BAX_CODLOC", "BB8_CODLOC" } } ,;
								   BAX->( IndexKey( 1 ) ) )

oModel:GetModel('BB8Detail'):setOptional(.T.)
oModel:GetModel('BAXDetail'):setOptional(.T.) 

oStrBB8:SetProperty( 'BB8_CPFCGC' , MODEL_FIELD_OBRIGAT, .F. )

//Modo de edição BBK
oStrBB8:SetProperty( "*" , MODEL_FIELD_WHEN , { || .f. } )
oStrBAX:SetProperty( "*" , MODEL_FIELD_WHEN , { || .f. } )

oModel:GetModel('BB8Detail'):SetOnlyView( .T. )
oModel:GetModel('BAXDetail'):SetOnlyView( .T. )
oModel:SetOnDemand(.t.) 

return oModel



Static Function ViewDef()
Local oModel    := FWLoadModel('PLSRDAREFC')
Local oViewPad  := FWLoadView('PLSA365BC1')
local oStrBAU   := oViewPad:GetViewStruct('MASTERBAU') // Busca e herda da Estrutura do padrão
local oStrBB8   := oViewPad:GetViewStruct('BB8Detail') // Busca e herda da Estrutura do padrão
local oStrBAX   := oViewPad:GetViewStruct('BAXDetail') // Busca e herda da Estrutura do padrão
Local oView     := Nil
 
oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('ViewBAU' , oStrBAU,'MASTERBAU' )
oView:AddGrid( 'ViewBB8' , oStrBB8,'BB8Detail' )
oView:AddGrid( 'ViewBAX' , oStrBAX,'BAXDetail' )

//Incremento

oView:CreateHorizontalBox( 'SUPERIOR' , 10)
oView:CreateHorizontalBox( 'MEIO'     , 60)
oView:CreateHorizontalBox( 'SUPERPEQ' , 5)
oView:CreateHorizontalBox( 'INFERIOR' , 25)

oView:CreateVerticalBox( 'MEIOESQ', 50, 'MEIO' )
oView:CreateVerticalBox( 'MEIODIR', 50, 'MEIO' )

//Cria as pastas   
oView:SetOwnerView('ViewBAU','SUPERIOR')
oView:SetOwnerView('ViewBB8','MEIOESQ')
oView:SetOwnerView('ViewBAX','MEIODIR')

//Painel com o caminho selecionado pelo usuário, entre Local e Especialidade
oView:AddOtherObject('PANCAM',{|oPanel| PnlCaminho(oPanel, oModel, oView)})
oView:SetOwnerView('PANCAM','SUPERPEQ')
oView:SetAfterViewActivate({|oView| VrfCaminho(oView) })
oView:SetViewProperty("BB8Detail","CHANGELINE",{{|oView| VrfCaminho(oView, "BB8Detail") }})
oView:SetViewProperty("BAXDetail","CHANGELINE",{{|oView| VrfCaminho(oView, "BAXDetail") }})

//Painel com botões
oView:AddOtherObject('PANBTN',{|oPanel| PnlBotao(oPanel, oModel, oView)})
oView:SetOwnerView('PANBTN','INFERIOR')

oView:SetViewProperty("ViewBAX", "GRIDFILTER", {.T.})
oView:SetViewProperty("ViewBAX", "GRIDSEEK", {.T.})
oView:SetViewProperty("ViewBB8", "GRIDFILTER", {.T.})
oView:SetViewProperty("ViewBB8", "GRIDSEEK", {.T.})


oView:SetCloseOnOK( { || .T. } )
//oView:SetProgressBar(.t.)

oView:SetDescription("") //Contatos"
oView:EnableTitleView('ViewBB8',STR0001) //Locais de Atendimento do Prestador
oView:EnableTitleView('ViewBAX',STR0002) //"Especialidades do Prestador"

Return oView


/*//-------------------------------------------------------------------
{Protheus.doc} PnlCaminho
Montagem do TPanel e do Tsay, para exibição do caminho
@since    06/2020
//-------------------------------------------------------------------*/
Static function PnlCaminho(oPanel, oModel, oView )
local oFont := nil
cTextoCmp := ""
oFont := TFont():New('Arial',,-13,,.T.)
oSayCmp  := TSay():New(005,005,{|| STR0009 + cTextoCmp },oPanel,,oFont,,,,.t.,CLR_BLUE,,700,10) //"Caminho selecionado: "
oSayCmp:Refresh()
return


/*//--------------------------------------------------------------
-----
{Protheus.doc} VrfCaminho
Coloca em um TPanel o caminho selecionado pelo usuário - Local e Especialidade, para saber onde está posicionado cada cursor
@since    06/2020
//-------------------------------------------------------------------*/
Static Function VrfCaminho(oView, cId)
local oObjBB8	:= oView:getmodel("BB8Detail")
local oObjBAX	:= oView:getmodel("BAXDetail")

default cId := ''

cTextoCmp := ""
cTextoCmp := alltrim(oObjBB8:getvalue("BB8_CODLOC")) + " - " + alltrim(oObjBB8:getvalue("BB8_DESLOC")) + " - " + alltrim(oObjBB8:getvalue("BB8_END")) + " / " + alltrim(oObjBAX:getvalue("BAX_DESESP"))
oSayCmp:Refresh()
if cId == "BB8Detail"
	oView:Refresh("BAXDetail")
endif

Return


/*//-------------------------------------------------------------------
{Protheus.doc} PnlBotao
Campos que não devem ser exibidos no Grid BBK
@since    07/2020
Thiago Rodrigues
//-------------------------------------------------------------------*/
static function PnlBotao(oPanel, oModel, oView)
Local lRet 			:= .T.
local oObjBB8		:= oView:getmodel("BB8Detail")
local oObjBAX		:= oView:getmodel("BAXDetail")
local oObjBAU		:= oView:getmodel("MASTERBAU")
local oContainer	:= nil

//local oFont 		:= TFont():New('Arial',,-10.5,,.T.)

oContainer := TPanelCss():New( ,,, oPanel,,,,,,,,.t.,.t. )
oContainer:SetCss(" QFrame{ border-style:solid; border-color:#d3d3d3; border-bottom-width:1px; border-top-width:1px; }")
oContainer:Align := CONTROL_ALIGN_ALLCLIENT


TButton():New( 05, 210, STR0003, oContainer, {|| VldBAXItem(oObjBAX) .and. PLS365BC0V(oObjBAU:getvalue("BAU_CODIGO"), oObjBB8:getvalue("BB8_CODINT"),oObjBB8:getvalue("BB8_CODLOC"), oObjBAX:getvalue("BAX_CODESP"), oObjBAX:getvalue("BAX_CODSUB"),cTextoCmp) }, 80,15,,/*oFont*/,.F.,.T.,.F.,,.F.,,,.F. ) //Procedimentos autorizados

TButton():New( 05, 300, STR0004, oContainer, {|| VldBAXItem(oObjBAX) .and. PLSPLANPRO(oObjBAU:getvalue("BAU_CODIGO"), oObjBB8:getvalue("BB8_CODINT"),oObjBB8:getvalue("BB8_CODLOC"), oObjBAX:getvalue("BAX_CODESP"), oObjBAX:getvalue("BAX_CODSUB"),cTextoCmp)}, 80,15,,,.F.,.T.,.F.,,.F.,,,.F. )//Planos x Procedimento

TButton():New( 05, 390, STR0005, oContainer, {|| VldBAXItem(oObjBAX) .and. PLSPRONALT(oObjBAU:getvalue("BAU_CODIGO"), oObjBB8:getvalue("BB8_CODINT"),oObjBB8:getvalue("BB8_CODLOC"), oObjBAX:getvalue("BAX_CODESP"), oObjBAX:getvalue("BAX_CODSUB"),cTextoCmp)}, 80,15,,,.F.,.T.,.F.,,.F.,,,.F. ) //Procedimentos não autorizados


return lRet


static function VldBAXitem(oObjBAX, cOpcao)
local lRet := .t.

if oObjBAX:IsEmpty()
	lRet := .f. 
	Help(nil, nil , STR0006 , nil, STR0007, 1, 0, nil, nil, nil, nil, nil, {STR0008 } ) //Atenção: Não existe Especialidade cadastrada para o local de atendimento selecionado.Cadastre uma especialidade para o local.
endif
return lRet 
