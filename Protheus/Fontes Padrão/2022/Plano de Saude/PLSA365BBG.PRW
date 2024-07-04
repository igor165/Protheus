#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "plsa365bbg.CH"

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
Local oModel    := nil     
Local oStrBAU   := FWFormStruct(1,'BAU')
Local oStrBB8   := FWFormStruct(1,'BB8')
Local oStrBAX   := FWFormStruct(1,'BAX')
Local oStrBBG   := FWFormStruct(1,'BBG')

//local aGatilho := {}
private cCodInt := PlsIntPad() //inicializador da BB8

oModel := MPFormModel():New('PLSA365BBG')

oModel:addFields('MASTERBAU',,oStrBAU) 
oModel:AddGrid('BB8Detail', 'MASTERBAU', oStrBB8)
oModel:AddGrid('BAXDetail', 'BB8Detail', oStrBAX)
oModel:AddGrid('BBGDetail', 'BAXDetail', oStrBBG)


oModel:SetRelation( 'BB8Detail', { { "BB8_FILIAL", 'xFilial( "BB8" )' } , ;
								   { "BB8_CODIGO", 'BAU_CODIGO' } }     , ;
								   BB8->( IndexKey( 1 ) ) )

oModel:SetRelation( 'BAXDetail', { { "BAX_FILIAL", 'xFilial("BAX")' }, ; 
								   { "BAX_CODIGO", "BB8_CODIGO" }, ;
 								   { "BAX_CODINT", "BB8_CODINT" }, ;
							       { "BAX_CODLOC", "BB8_CODLOC" } } ,;
								   BAX->( IndexKey( 1 ) ) )

oModel:SetRelation( 'BBGDetail',{   { "BBG_FILIAL", 'xFilial("BBG")'  }, ;
                                    { "BBG_CODIGO", "BAX_CODIGO" }, ;
									{ "BBG_CODINT", "BAX_CODINT" }, ;
									{ "BBG_CODLOC", "BAX_CODLOC" }, ;
									{ "BBG_CODESP", "BAX_CODESP" }, ;
									{ "BBG_CODSUB", "BAX_CODSUB" } }, ;
									BBG->( IndexKey( 2 ) ) )        


oModel:GetModel('BBGDetail'):setOptional(.T.) //Permitir que o grid abra sem dados
oModel:GetModel('BB8Detail'):setOptional(.T.)
oModel:GetModel('BAXDetail'):setOptional(.T.) 

oStrBB8:SetProperty( 'BB8_CPFCGC' , MODEL_FIELD_OBRIGAT, .F. )

//Modo de edição BBG
oStrBB8:SetProperty( "*"          , MODEL_FIELD_WHEN , { || .f. } )
oStrBAX:SetProperty( "*"          , MODEL_FIELD_WHEN , { || .f. } )
oStrBBG:SetProperty( "*"          , MODEL_FIELD_WHEN , { || !empty(oModel:getModel('BAXDetail'):getValue("BAX_CODESP")) } )

//Inicializador padrão BBG
oStrBBG:SetProperty( 'BBG_CODIGO' , MODEL_FIELD_INIT, { || oModel:getModel("MASTERBAU"):getValue("BAU_CODIGO")})
oStrBBG:SetProperty( 'BBG_CODINT' , MODEL_FIELD_INIT, { || PlsIntPad() } )
oStrBBG:SetProperty( 'BBG_CODLOC' , MODEL_FIELD_INIT, { || oModel:getModel("BB8Detail"):getValue("BB8_CODLOC")} )
oStrBBG:SetProperty( 'BBG_CODESP' , MODEL_FIELD_INIT, { || oModel:getModel("BAXDetail"):getValue("BAX_CODESP")} )
oStrBBG:SetProperty( 'BBG_CODSUB' , MODEL_FIELD_INIT, { || oModel:getModel("BAXDetail"):getValue("BAX_CODSUB")} )

//Validações BBG
oStrBBG:SetProperty( 'BBG_CODORG',  MODEL_FIELD_VALID ,{ ||VLDORG(oModel) })
oStrBBG:SetProperty( 'BBG_EMAIL',  MODEL_FIELD_VALID ,{ ||Vazio() .Or. IsEMail(AllTrim(oModel:getModel("BBGDetail"):getValue("BBG_EMAIL"))) })

oModel:GetModel('BB8Detail'):SetOnlyView( .T. )
oModel:GetModel('BAXDetail'):SetOnlyView( .T. )
oModel:GetModel('BBGDetail'):SetMaxLine(9999999)
oModel:SetOnDemand(.t.) 

return oModel

Static Function ViewDef()
Local oModel      := FWLoadModel( 'PLSA365BBG' )
Local oViewPad    := FWLoadView('PLSA365BC1')
local oStrBAU   := oViewPad:GetViewStruct('MASTERBAU') // Busca e herda da Estrutura do padrão
local oStrBB8   := oViewPad:GetViewStruct('BB8Detail') // Busca e herda da Estrutura do padrão
local oStrBAX   := oViewPad:GetViewStruct('BAXDetail') // Busca e herda da Estrutura do padrão
Local oStrBBG   := FWFormStruct(2, 'BBG', { |cCampo| OcultaCmp(cCampo) }) // Novo grid da estrutura
Local oView       := Nil
 
oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('ViewBAU' , oStrBAU,'MASTERBAU' )
oView:AddGrid( 'ViewBB8' , oStrBB8,'BB8Detail' )
oView:AddGrid( 'ViewBAX' , oStrBAX,'BAXDetail' )
oView:AddGrid( 'ViewBBG' , oStrBBG,'BBGDetail' )

//Incremento
oView:AddIncrementField('ViewBBG', 'BBG_SEQUEN')

oView:CreateHorizontalBox( 'SUPERIOR' , 10)
oView:CreateHorizontalBox( 'MEIO'     , 40)
oView:CreateHorizontalBox( 'SUPERPEQ' , 5)
oView:CreateHorizontalBox( 'INFERIOR' , 45)

oView:CreateVerticalBox( 'MEIOESQ', 50, 'MEIO' )
oView:CreateVerticalBox( 'MEIODIR', 50, 'MEIO' )

//Cria as pastas   
oView:SetOwnerView('ViewBAU','SUPERIOR')
oView:SetOwnerView('ViewBB8','MEIOESQ')
oView:SetOwnerView('ViewBAX','MEIODIR')
oView:SetOwnerView('ViewBBG','INFERIOR')


//Painel com o caminho selecionado pelo usuário, entre Local e Especialidade
oView:AddOtherObject('PANCAM',{|oPanel| PnlCaminho(oPanel, oModel, oView)})
oView:SetOwnerView('PANCAM','SUPERPEQ')
oView:SetAfterViewActivate({|oView| VrfCaminho(oView) })
oView:SetViewProperty("BB8Detail","CHANGELINE",{{|oView| VrfCaminho(oView, "BB8Detail") }})
oView:SetViewProperty("BAXDetail","CHANGELINE",{{|oView| VrfCaminho(oView, "BAXDetail") }})

oView:SetViewProperty("ViewBAX", "GRIDFILTER", {.T.})
oView:SetViewProperty("ViewBAX", "GRIDSEEK", {.T.})
oView:SetViewProperty("ViewBB8", "GRIDFILTER", {.T.})
oView:SetViewProperty("ViewBB8", "GRIDSEEK", {.T.})
oView:SetViewProperty("ViewBBG", "GRIDFILTER", {.T.})
oView:SetViewProperty("ViewBBG", "GRIDSEEK", {.T.})

oView:SetCloseOnOK( { || .T. } )
//oView:SetProgressBar(.t.)

oView:SetDescription("") //Contatos"
oView:EnableTitleView('ViewBB8',STR0007) //Locais de Atendimento do Prestador
oView:EnableTitleView('ViewBAX',STR0008) //"Especialidades do Prestador"

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
oSayCmp  := TSay():New(005,005,{|| STR0010 + cTextoCmp },oPanel,,oFont,,,,.t.,CLR_BLUE,,700,10) //"Caminho selecionado: "
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
local oObjBBG	:= oView:getmodel("BBGDetail")

default cId := ''

cTextoCmp := ""
cTextoCmp := alltrim(oObjBB8:getvalue("BB8_CODLOC")) + " - " + alltrim(oObjBB8:getvalue("BB8_DESLOC")) + " - " + alltrim(oObjBB8:getvalue("BB8_END")) + " / " + alltrim(oObjBAX:getvalue("BAX_DESESP"))
oSayCmp:Refresh()
if cId == "BB8Detail"
	oView:Refresh("BAXDetail")
endif

if cId == "BB8Detail" .And. oObjBAX:isEmpty()
	oObjBBG:SetNoDeleteLine(.t.)
else
	oObjBBG:SetNoDeleteLine(.f.)
Endif

Return

/*//-------------------------------------------------------------------
{Protheus.doc} VLDORG
Valida se existe o código da organização BBG_CODORG  e faz o load na descrição
@since    07/2020
Thiago Rodrigues
//-------------------------------------------------------------------*/
Static Function VLDORG(oModel)
local oGrid := oModel:getmodel("BBGDetail")
local lRet  :=.F.
local cDescr := " "

if vazio() .OR. ExistCpo("BIG",oGrid:getValue("BBG_CODORG"))

cDescr := Posicione("BIG",1,xFilial("BIG")+oGrid:getValue("BBG_CODORG"),"BIG_DESCRI") 

    if !empty(oGrid:getValue("BBG_CODORG")) .And. !empty(cDescr) .or. Vazio()
        oGrid:setvalue("BBG_DESORG",cDescr)
    endif
    lret := .T.
endif
Return(lRet)

/*//-------------------------------------------------------------------
{Protheus.doc} OcultaCmp
Campos que não devem ser exibidos no Grid BBG
@since    07/2020
Thiago Rodrigues
//-------------------------------------------------------------------*/
static function OcultaCmp(cCampo)
Local lRet := .T.

if alltrim(cCampo) $ 'BBG_CODIGO'
	lRet := .f.
endif
return lRet
