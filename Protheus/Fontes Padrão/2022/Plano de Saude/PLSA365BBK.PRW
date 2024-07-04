#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "plsa365BBK.CH"

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
Local oStrBBK   := FWFormStruct(1,'BBK')

private cCodInt := PlsIntPad() //inicializador da BB8

oModel := MPFormModel():New('PLSA365BBK')

oModel:addFields('MASTERBAU',,oStrBAU) 
oModel:AddGrid('BB8Detail', 'MASTERBAU', oStrBB8)
oModel:AddGrid('BAXDetail', 'BB8Detail', oStrBAX)
oModel:AddGrid('BBKDetail', 'BAXDetail', oStrBBK)


oModel:SetRelation( 'BB8Detail', { { "BB8_FILIAL", 'xFilial( "BB8" )' } , ;
								   { "BB8_CODIGO", 'BAU_CODIGO' } }       , ;
								   BB8->( IndexKey( 1 ) ) )

oModel:SetRelation( 'BAXDetail', { { "BAX_FILIAL", 'xFilial("BAX")' }, ; 
								   { "BAX_CODIGO", "BB8_CODIGO" }, ;
 								   { "BAX_CODINT", "BB8_CODINT" }, ;
							       { "BAX_CODLOC", "BB8_CODLOC" } } ,;
								   BAX->( IndexKey( 1 ) ) )

oModel:SetRelation( 'BBKDetail',{   { "BBK_FILIAL", 'xFilial("BBK")'  }, ;
                                    { "BBK_CODIGO", "BAX_CODIGO" }, ;
									{ "BBK_CODINT", "BAX_CODINT" }, ;
									{ "BBK_CODLOC", "BAX_CODLOC" }, ;
									{ "BBK_CODESP", "BAX_CODESP" }, ;
                                    { "BBK_CODSUB", "BAX_CODSUB" }} ,;
									BBK->( IndexKey( 2 ) ) )        

oModel:GetModel('BBKDetail'):setOptional(.T.) //Permitir que o grid abra sem dados
oModel:GetModel('BB8Detail'):setOptional(.T.)
oModel:GetModel('BAXDetail'):setOptional(.T.) 

oStrBB8:SetProperty( 'BB8_CPFCGC' , MODEL_FIELD_OBRIGAT, .F. )

//Gatilhos e SetuniqueLine
oModel:GetModel( 'BBKDetail' ):SetUniqueLine( {'BBK_CODRED'} )

//Modo de edição BBK
oStrBB8:SetProperty( "*"          , MODEL_FIELD_WHEN , { || .f. } )
oStrBAX:SetProperty( "*"          , MODEL_FIELD_WHEN , { || .f. } )
oStrBBK:SetProperty( "*" , MODEL_FIELD_WHEN , { || !empty(oModel:getModel('BAXDetail'):getValue("BAX_CODESP")) } )

//Inicializador padrão BBK
oStrBBK:SetProperty( 'BBK_CODIGO' , MODEL_FIELD_INIT, { || oModel:getModel("MASTERBAU"):getValue("BAU_CODIGO")})
oStrBBK:SetProperty( 'BBK_CODINT' , MODEL_FIELD_INIT, { || PlsIntPad() } )
oStrBBK:SetProperty( 'BBK_CODLOC' , MODEL_FIELD_INIT, { || oModel:getModel("BB8Detail"):getValue("BB8_CODLOC")} )
oStrBBK:SetProperty( 'BBK_CODESP' , MODEL_FIELD_INIT, { || oModel:getModel("BAXDetail"):getValue("BAX_CODESP")} )
oStrBBK:SetProperty( 'BBK_CODSUB' , MODEL_FIELD_INIT, { || oModel:getModel("BAXDetail"):getValue("BAX_CODSUB")} )

//Validações
oStrBBK:SetProperty( "BBK_CODRED" , MODEL_FIELD_VALID , { || VldCodRed(oModel) } )


oModel:GetModel('BB8Detail'):SetOnlyView( .T. )
oModel:GetModel('BAXDetail'):SetOnlyView( .T. )
oModel:GetModel('BBKDetail'):SetMaxLine(9999999)
oModel:SetOnDemand(.t.) 

return oModel

Static Function ViewDef()
Local oModel      := FWLoadModel( 'PLSA365BBK' )
Local oViewPad    := FWLoadView('PLSA365BC1')
local oStrBAU   := oViewPad:GetViewStruct('MASTERBAU') // Busca e herda da Estrutura do padrão
local oStrBB8   := oViewPad:GetViewStruct('BB8Detail') // Busca e herda da Estrutura do padrão
local oStrBAX   := oViewPad:GetViewStruct('BAXDetail') // Busca e herda da Estrutura do padrão
Local oStrBBK   := FWFormStruct(2, 'BBK', { |cCampo| OcultaCmp(cCampo) }) // Novo grid da estrutura
Local oView       := Nil
 
oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('ViewBAU' , oStrBAU,'MASTERBAU' )
oView:AddGrid( 'ViewBB8' , oStrBB8,'BB8Detail' )
oView:AddGrid( 'ViewBAX' , oStrBAX,'BAXDetail' )
oView:AddGrid( 'ViewBBK' , oStrBBK,'BBKDetail' )

//Incremento
oView:AddIncrementField('ViewBBK', 'BBK_SEQUEN')

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
oView:SetOwnerView('ViewBBK','INFERIOR')


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
oView:SetViewProperty("ViewBBK", "GRIDFILTER", {.T.})
oView:SetViewProperty("ViewBBK", "GRIDSEEK", {.T.})

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
local oObjBBK	:= oView:getmodel("BBKDetail")

default cId := ''

cTextoCmp := ""
cTextoCmp := alltrim(oObjBB8:getvalue("BB8_CODLOC")) + " - " + alltrim(oObjBB8:getvalue("BB8_DESLOC")) + " - " + alltrim(oObjBB8:getvalue("BB8_END")) + " / " + alltrim(oObjBAX:getvalue("BAX_DESESP"))
oSayCmp:Refresh()
if cId == "BB8Detail"
	oView:Refresh("BAXDetail")
endif

if cId == "BB8Detail" .And. oObjBAX:isEmpty()
	oObjBBk:SetNoDeleteLine(.t.)
else
	oObjBBk:SetNoDeleteLine(.f.)
Endif

Return

/*//-------------------------------------------------------------------
{Protheus.doc} OcultaCmp
Campos que não devem ser exibidos no Grid BBK
@since    07/2020
Thiago Rodrigues
//-------------------------------------------------------------------*/
static function OcultaCmp(cCampo)
Local lRet := .T.

if alltrim(cCampo) $ 'BBK_CODIGO'
	lRet := .f.
endif
return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} VldCodRed
Campos que não devem ser exibidos no Grid BBK
@since    07/2020
Thiago Rodrigues
//-------------------------------------------------------------------*/

Static Function VldCodRed(oModel)
local oGrid := oModel:getmodel("BBKDetail")
local lRet  :=.F.
local cDescr := " "

If Vazio() .OR. ExistCpo("BI5",oModel:getModel("BBKDetail"):getValue("BBK_CODRED"))

    cDescr := Posicione("BI5",1,xFilial("BI5")+oGrid:getValue("BBK_CODRED"),"BI5_DESCRI")

    if !empty(FwFldGet("BBK_CODRED")) .And. !empty(cDescr) .or. Vazio()
		oGrid:setvalue("BBK_DESRED",cDescr)
	endif

    lret := .T.
endif    
return lRet
