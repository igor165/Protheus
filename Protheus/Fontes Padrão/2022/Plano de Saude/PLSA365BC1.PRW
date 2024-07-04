#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PLSA365BC1.CH"
#include "FWEditPanel.CH"

static cTextoCmp	:= ''
static cTextoPrf	:= ''
static oSayCmp		:= nil 
static oSayPrf		:= nil

/*//-------------------------------------------------------------------
{Protheus.doc} ModelDef
ModelDef
@since    05/2020
Thiago Rodrigues
//-------------------------------------------------------------------*/
Static function ModelDef()
local aGatilho	:= {}
Local oModel    := nil     
Local oStrBAU   := FWFormStruct(1,'BAU')
Local oStrBB8   := FWFormStruct(1,'BB8')
Local oStrBAX   := FWFormStruct(1,'BAX')
Local oStrBC1   := FWFormStruct(1,'BC1')
Local oStrBE6   := FWFormStruct(1,'BE6')
private cCodInt := PlsIntPad() //inicializador da BB8

oModel := MPFormModel():New('PLSA365BC1',,{ || PlsCadVld(oModel) })

oModel:addFields('MASTERBAU',,oStrBAU) 
oModel:AddGrid('BB8Detail', 'MASTERBAU', oStrBB8)
oModel:AddGrid('BAXDetail', 'BB8Detail', oStrBAX)
oModel:AddGrid('BC1Detail', 'BAXDetail', oStrBC1)
oModel:AddGrid('BE6Detail', 'BC1Detail', oStrBE6,,{|| VldLinha(oModel)})

oModel:SetRelation( 'BB8Detail', { { "BB8_FILIAL", 'xFilial( "BB8" )' } , ;
								   { "BB8_CODIGO", 'BAU_CODIGO' } }     , ;
								   BB8->( IndexKey( 1 ) ) )

oModel:SetRelation( 'BAXDetail', { { "BAX_FILIAL", 'xFilial("BAX")' }, ; 
								   { "BAX_CODIGO", "BB8_CODIGO" }, ;
 								   { "BAX_CODINT", "BB8_CODINT" }, ;
							       { "BAX_CODLOC", "BB8_CODLOC" } } ,;
								   BAX->( IndexKey( 1 ) ) )

oModel:SetRelation( 'BC1Detail',{   { "BC1_FILIAL", 'xFilial("BC1")'  }, ;
									{ "BC1_CODINT", "BAX_CODINT" }, ;
								    { "BC1_CODIGO", "BAX_CODIGO" }, ;
									{ "BC1_CODLOC", "BAX_CODLOC" }, ;
									{ "BC1_CODESP", "BAX_CODESP" }, ;
									{ "BC1_CODSUB", "BAX_CODSUB" } }, ; 
									BC1->( IndexKey( 7 ) ) )

oModel:SetRelation( 'BE6Detail',{ { "BE6_FILIAL", 'xFilial("BE6")' }, ;
								  { "BE6_CODIGO", "BC1_CODIGO" }, ;
								  { "BE6_CODINT", "BC1_CODINT" }, ;
								  { "BE6_CODLOC", "BC1_CODLOC" }, ;
								  { "BE6_CODESP", "BC1_CODESP" }, ;	
								  { "BE6_CODSUB", "BC1_CODSUB" }, ;
								  { "BE6_CODPRF", "BC1_CODPRF" } },;								
									BE6->( IndexKey( 2 ) ) )

oModel:GetModel('BB8Detail'):setOptional(.T.)
oModel:GetModel('BAXDetail'):setOptional(.T.) 
oModel:GetModel('BC1Detail'):setOptional(.T.) 
oModel:GetModel('BE6Detail'):setOptional(.T.) 

//Gatilhos e SetuniqueLine
oModel:GetModel( 'BC1Detail' ):SetUniqueLine( { 'BC1_CODRDA', 'BC1_CODPRF' } )
oModel:GetModel( 'BE6Detail' ):SetUniqueLine( { 'BE6_CODTAB', 'BE6_CODPRO' } )

aGatilho := FwStruTrigger('BE6_CODTAB', 'BE6_DESTAB', 'BF8->BF8_DESCM', .f., 'BF8', 1, 'xFilial("BF8") + FwFldGet("BE6_CODINT") + FwFldGet("BE6_CODTAB")','!empty(FwFldGet("BE6_CODTAB"))')                                           
oStrBE6:AddTrigger( aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4] )

aGatilho := FwStruTrigger('BE6_CODPRO', 'BE6_DESPRO', 'BA8->BA8_DESCRI', .f., 'BA8', 1, 'xFilial("BA8") + FwFldGet("BE6_CODINT") + FwFldGet("BE6_CODTAB") + FwFldGet("BE6_CODPAD") + FwFldGet("BE6_CODPRO")','!empty(FwFldGet("BE6_CODPRO"))') 
oStrBE6:AddTrigger( aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4] )

oStrBB8:SetProperty( 'BB8_CPFCGC' , MODEL_FIELD_OBRIGAT, .F. )
oStrBE6:SetProperty( 'BE6_CODTAB' , MODEL_FIELD_OBRIGAT, .F. )
oStrBB8:SetProperty( "*"          , MODEL_FIELD_WHEN , { || .f. } )
oStrBAX:SetProperty( "*"          , MODEL_FIELD_WHEN , { || .f. } )
oStrBC1:SetProperty( "*"          , MODEL_FIELD_WHEN , { || !empty(oModel:getModel('BAXDetail'):getValue("BAX_CODESP")) } )

oStrBC1:SetProperty( 'BC1_CODINT' , MODEL_FIELD_INIT, { || PlsIntPad() } )
oStrBC1:SetProperty( 'BC1_CODLOC' , MODEL_FIELD_INIT, { || oModel:getModel("BB8Detail"):getValue("BB8_CODLOC")} )
oStrBC1:SetProperty( 'BC1_CODESP' , MODEL_FIELD_INIT, { || oModel:getModel("BAXDetail"):getValue("BAX_CODESP")} )
oStrBC1:SetProperty( 'BC1_CODSUB' , MODEL_FIELD_INIT, { || oModel:getModel("BAXDetail"):getValue("BAX_CODSUB")} )
oStrBC1:SetProperty( 'BC1_CODIGO' , MODEL_FIELD_INIT, { || oModel:getModel("MASTERBAU"):getValue("BAU_CODIGO")} )
oStrBC1:SetProperty( 'BC1_NOMRDA' , MODEL_FIELD_TAMANHO, 100 )

oStrBC1:SetProperty( "BC1_CODRDA" , MODEL_FIELD_WHEN, { || oModel:getModel("BC1Detail"):getValue("BC1_TIPLAN") $ "1, " .and. ;
                                                           !empty(oModel:getModel('BAXDetail'):getValue("BAX_CODESP"))} )
oStrBC1:SetProperty( "BC1_CODPRF" , MODEL_FIELD_WHEN, { || oModel:getModel('BC1Detail'):getValue("BC1_TIPLAN") $ "2, " .and.; 
														   !empty(oModel:getModel('BAXDetail'):getValue("BAX_CODESP"))} )
oStrBC1:SetProperty( 'BC1_PERDES' , MODEL_FIELD_WHEN, { || !empty(oModel:getModel('BAXDetail'):getValue("BAX_CODESP"))} )

oStrBC1:SetProperty( "BC1_CODRDA" , MODEL_FIELD_VALID, { || vazio() .or. ExistCpo("BAU",oModel:getModel("BC1Detail"):getValue("BC1_CODRDA"),1) })
oStrBC1:SetProperty( "BC1_CODPRF" , MODEL_FIELD_VALID, { || vazio() .or. PLVLDPFS("BB0",oModel:getModel("BC1Detail"):getValue("BC1_CODPRF"),1,dDataBase) })
oStrBC1:SetProperty( "BC1_CODBLO" , MODEL_FIELD_VALID, { || vazio() .or. ExistCpo("BAP",oModel:getModel("BC1Detail"):getValue("BC1_CODBLO"),1)  })

oStrBE6:SetProperty( 'BE6_CODPRF' , MODEL_FIELD_INIT, { || oModel:getModel("BC1Detail"):getValue("BC1_CODPRF")} )
oStrBE6:SetProperty( 'BE6_CODLOC' , MODEL_FIELD_INIT, { || oModel:getModel("BB8Detail"):getValue("BB8_CODLOC")} )
oStrBE6:SetProperty( 'BE6_CODINT' , MODEL_FIELD_INIT, { || PlsIntPad() } )
oStrBE6:SetProperty( 'BE6_CODESP' , MODEL_FIELD_INIT, { || oModel:getModel("BAXDetail"):getValue("BAX_CODESP")} )
oStrBE6:SetProperty( 'BE6_CODSUB' , MODEL_FIELD_INIT, { || oModel:getModel("BAXDetail"):getValue("BAX_CODSUB")} )
oStrBE6:SetProperty( 'BE6_CODIGO' , MODEL_FIELD_INIT, { || oModel:getModel("MASTERBAU"):getValue("BAU_CODIGO")} )
oStrBE6:SetProperty( 'BE6_DESPRO' , MODEL_FIELD_TAMANHO, 100 )
oStrBE6:SetProperty( 'BE6_DESTAB' , MODEL_FIELD_TAMANHO, 100 )
oStrBE6:SetProperty( "BE6_CODPRO" , MODEL_FIELD_WHEN , { || !empty(oModel:getModel('BE6Detail'):getValue("BE6_CODTAB")) } )
oStrBE6:SetProperty( "BE6_CODTAB" , MODEL_FIELD_WHEN , { || !empty(oModel:getModel("BC1Detail"):getValue("BC1_CODPRF")) } )
oStrBE6:SetProperty( "BE6_PGTDIV" , MODEL_FIELD_WHEN , { || !empty(oModel:getModel('BE6Detail'):getValue("BE6_CODTAB")) } )
oStrBE6:SetProperty( 'BE6_CODTAB' , MODEL_FIELD_VALID, { || vazio() .or. ExistCpo("BF8",oModel:getModel("BE6Detail"):getValue("BE6_CODINT") + oModel:getModel("BE6Detail"):getValue("BE6_CODTAB"),1) })
oStrBE6:SetProperty( 'BE6_CODPAD' , MODEL_FIELD_VALID, { || ExistCpo("BR4",oModel:getModel("BE6Detail"):getValue("BE6_CODPAD"),1)} )
oStrBE6:SetProperty( 'BE6_CODPRO' , MODEL_FIELD_VALID, { || vazio() .or. ExistCpo("BA8", oModel:getModel("BE6Detail"):getValue("BE6_CODINT") + oModel:getModel("BE6Detail"):getValue("BE6_CODTAB") +;
															oModel:getModel("BE6Detail"):getValue("BE6_CODPAD") + oModel:getModel("BE6Detail"):getValue("BE6_CODPRO"),1)})
oModel:GetModel('BB8Detail'):SetOnlyView( .T. )
oModel:GetModel('BAXDetail'):SetOnlyView( .T. )
oModel:GetModel('BC1Detail'):SetMaxLine(9999999)
oModel:GetModel('BE6Detail'):SetMaxLine(9999999)
oModel:SetOnDemand(.t.) 

return oModel


/*//-------------------------------------------------------------------
{Protheus.doc} ViewDef
ViewDef
@since    05/2020
Thiago Rodrigues
//-------------------------------------------------------------------*/
Static function ViewDef()
Local oView     := nil
Local oModel  	:= FWLoadModel( 'PLSA365BC1' )
Local oStrBAU   := FWFormStruct(2, 'BAU', { |cCampo| PLSCMPBAU(cCampo) } )
Local oStrBB8   := FWFormStruct(2, 'BB8', { |cCampo| PLSCMPBB8(cCampo) })
Local oStrBAX   := FWFormStruct(2, 'BAX', { |cCampo| PLSCMPBAX(cCampo) } )
Local oStrBC1   := FWFormStruct(2, 'BC1', { |cCampo| PLSCMPBC1(cCampo) } )
Local oStrBE6   := FWFormStruct(2, 'BE6', { |cCampo| PLSCMPBE6(cCampo) } )

oView := FWFormView():New()
oView:SetModel(oModel)

oStrBAU:SetProperty( '*' , MVC_VIEW_CANCHANGE, .f. ) 

oStrBAU:SetNoFolder()

oView:AddField('ViewBAU' , oStrBAU,'MASTERBAU' )
oView:AddGrid( 'ViewBB8' , oStrBB8,'BB8Detail' )
oView:AddGrid( 'ViewBAX' , oStrBAX,'BAXDetail' )
oView:AddGrid( 'ViewBC1' , oStrBC1,'BC1Detail' )
oView:AddGrid( 'ViewBE6' , oStrBE6,'BE6Detail' )

oView:CreateHorizontalBox( 'SUPERIOR' , 10)
oView:CreateHorizontalBox( 'MEIO'     , 40)
oView:CreateHorizontalBox( 'SUPERPEQ' , 5)
oView:CreateHorizontalBox( 'INFERIOR' , 45)

oView:CreateVerticalBox( 'MEIOESQ', 50, 'MEIO' )
oView:CreateVerticalBox( 'MEIODIR', 50, 'MEIO' )

//Cria as pastas   
oView:CreateFolder( 'FLDNV1' ,'INFERIOR') //folder nível 1
oView:CreateVerticalBox( 'Corpo Clínico', 100,,, 'FLDNV1', 'ABA_RDA' )
oView:CreateVerticalBox( 'Procedimentos', 85,,, 'FLDNV1', 'ABA_PROC' )
oView:CreateVerticalBox( 'PROFSEL', 15,,, 'FLDNV1', 'ABA_PROC'  )
oView:AddSheet( 'FLDNV1'    , 'ABA_RDA'    , 'Corpo Clínico' )
oView:AddSheet( 'FLDNV1'    , 'ABA_PROC'   ,'Procedimentos', {|| AtuAba()} )

oView:SetOwnerView('ViewBAU','SUPERIOR')
oView:SetOwnerView('ViewBB8','MEIOESQ')
oView:SetOwnerView('ViewBAX','MEIODIR')
oView:SetOwnerView('ViewBC1','Corpo Clínico')
oView:SetOwnerView('ViewBE6','Procedimentos')

oView:SetViewProperty("ViewBAX", "GRIDFILTER", {.T.})
oView:SetViewProperty("ViewBAX", "GRIDSEEK", {.T.})
oView:SetViewProperty("ViewBB8", "GRIDFILTER", {.T.})
oView:SetViewProperty("ViewBB8", "GRIDSEEK", {.T.})
oView:SetViewProperty("ViewBC1", "GRIDFILTER", {.T.})
oView:SetViewProperty("ViewBC1", "GRIDSEEK", {.T.})
oView:SetViewProperty("ViewBE6", "GRIDFILTER", {.T.})
oView:SetViewProperty("ViewBE6", "GRIDSEEK", {.T.})

oView:SetCloseOnOK( { || .T. } )
//oView:SetProgressBar(.t.)

//Painel com o caminho selecionado pelo usuário, entre Local e Especialidade
oView:AddOtherObject('PANCAM',{|oPanel| PnlCaminho(oPanel, oModel, oView)})
oView:SetOwnerView('PANCAM','SUPERPEQ')
oView:SetAfterViewActivate({|oView| VrfCaminho(oView) })
oView:SetViewProperty("BB8Detail","CHANGELINE",{{|oView| VrfCaminho(oView, "BB8Detail") }})
oView:SetViewProperty("BAXDetail","CHANGELINE",{{|oView| VrfCaminho(oView, "BAXDetail") }})
oView:SetFieldAction('BE6_CODTAB', { |oView| LmpProc(oModel) } ) 

oView:AddOtherObject('PANPROF',{|oPnl| PnlCmProf(oPnl)})
oView:SetOwnerView('PANPROF','PROFSEL')

oView:SetDescription("") //Corpo Clínico"
oView:EnableTitleView('ViewBB8',STR0009) //Locais de Atendimento do Prestador
oView:EnableTitleView('ViewBAX',STR0010) //"Especialidades do Prestador"

return oView


/*//-------------------------------------------------------------------
{Protheus.doc} PLSCMPBAU
Campos que devem ser exibidos no Cabeçalho BAU
@since    05/2020
Thiago Rodrigues
//-------------------------------------------------------------------*/
static function PLSCMPBAU(cCampo)
Local lRet := .f.

if alltrim(cCampo) $ 'BAU_CODIGO,BAU_NOME,BAU_CPFCGC'
	lRet := .t.
endif
return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} PLSCMPBAX
Campos que não devem ser exibidos no Grid BAX
@since    05/2020
Thiago Rodrigues
//-------------------------------------------------------------------*/
static function PLSCMPBAX(cCampo)
Local lRet := .f.

if alltrim(cCampo) $ ("BAX_CODESP|BAX_DESESP|BAX_CODSUB|BAX_DESSUB|BAX_VIGDE|BAX_DATBLO|BAX_ESPPRI")
	lRet := .T.
endif
return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} PLSCMPBC1
Campos que não devem ser exibidos no Grid BC1
@since    05/2020
Thiago Rodrigues
//-------------------------------------------------------------------*/
static function PLSCMPBC1(cCampo)
Local lRet := .T.

if alltrim(cCampo) $ 'BC1_CODIGO'
	lRet := .f.
endif
return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} PLSCMPBE6
Campos que não devem ser exibidos no Grid BE6
@since    05/2020
Thiago Rodrigues
//-------------------------------------------------------------------*/
static function PLSCMPBE6(cCampo)
Local lRet := .T.

if alltrim(cCampo) $ 'BE6_CODIGO'
	lRet := .f.
endif
return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} PLSCMPBB8
Campos que não devem ser exibidos no Grid BB8
@since    05/2020
Thiago Rodrigues
//-------------------------------------------------------------------*/
static function PLSCMPBB8(cCampo)
Local lRet := .f.

if alltrim(cCampo) $ ("BB8_CODLOC|BB8_DESLOC|BB8_CEP|BB8_END|BB8_NR_END|BB8_COMEND|BB8_MUN|BB8_EST|BB8_BAIRRO|BB8_DATBLO|BB8_CPFCGC")
	lRet := .t.
endif

return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} PLSCMPBB8
retorna a variavel utilizada na pesquisa(BAKPLS) do campo BE6_CODTAB
@since    05/2020
Thiago Rodrigues
//-------------------------------------------------------------------*/
function Plspesq()
oModelx := FwModelActive()
cRet:= oModelx:getModel("BE6Detail"):getValue("BE6_CODTAB")

return cRet


/*//-------------------------------------------------------------------
{Protheus.doc} VldLinha
Se o usuário informa o código da tabela, é obrigatório informar o código do procedimento.
Não podemos ter registro apenas com código da tabela.
@since    06/2020
//-------------------------------------------------------------------*/
static function VldLinha(oModel)
local lRet 		:= .t.
local oObjGrd	:= oModel:getModel("BE6Detail")

if !empty(oObjGrd:getvalue("BE6_CODTAB")) .and. empty(oObjGrd:getvalue("BE6_CODPRO"))
	lRet := .F.
	Help(nil, nil , STR0006, nil, STR0013, 1, 0, nil, nil, nil, nil, nil, {STR0014} )//"O código do procedimento está vazio." / "Informe o código do procedimento!"
endif

return lRet 


/*//-------------------------------------------------------------------
{Protheus.doc} AtuAba
Ao inserir um registro na BC1 e ir direto na aba da BE6, a linha não é atualizada com o código do profissional, devido ao inicializador.
Ao mudar de aba, verificamos se o campo BC1_CODPRF está preenchido, alimentando a linha com o código correto. Se inserir mais uma, o
inicializador funciona corretamente.
@since    06/2020
//-------------------------------------------------------------------*/
static function AtuAba()
local oView     := FWViewActive()
local oGridBC1	:= oView:getmodel("BC1Detail")
local oGridBE6	:= oView:getmodel("BE6Detail")
local oObjBC1	:= oView:getmodel("BC1Detail")

if ( !empty(oGridBC1:getvalue("BC1_CODPRF")) .and. empty(oGridBE6:getvalue("BE6_CODPRF")) )
	oGridBE6:loadvalue("BE6_CODPRF", oGridBC1:getvalue("BC1_CODPRF"))
endif 	
cTextoPrf := ""
cTextoPrf := STR0017 + alltrim(oObjBC1:getvalue("BC1_CODPRF")) + CRLF //"Código : "
cTextoPrf += STR0018 + CRLF + substr(alltrim(oObjBC1:getvalue("BC1_NOMPRF")),1, 50) //"Nome: "
oSayPrf:Refresh()
oView:Refresh("BE6Detail")		
Return .t.


/*//-------------------------------------------------------------------
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
{Protheus.doc} PnlCaminho
Montagem do TPanel e do Tsay, para exibição do caminho
@since    06/2020
//-------------------------------------------------------------------*/
static function PnlCaminho(oPanel, oModel, oView )
local oFont := nil
cTextoCmp := ""
oFont := TFont():New('Arial',,-13,,.T.)
oSayCmp  := TSay():New(005,005,{|| STR0016 + cTextoCmp },oPanel,,oFont,,,,.t.,CLR_BLUE,,700,10) //"Caminho selecionado: "
oSayCmp:Refresh()
return


/*//-------------------------------------------------------------------
{Protheus.doc} PnlCmProf
Montagem do TPanel e do Tsay, para exibição do nome do profissional, na aba BE6
@since    06/2020
//-------------------------------------------------------------------*/
static function PnlCmProf(oPanel)
local oFontP := nil

cTextoPrf := ""
oFontP := TFont():New('Arial',,-13,,.T.)
oSayPrf  := TSay():New(001,005,{|| STR0015 + CRLF + cTextoPrf },oPanel,,oFontP,,,,.t.,CLR_BLUE,,105,400) //Profissional selecionado:
oSayPrf:Refresh()
return


/*//-------------------------------------------------------------------
{Protheus.doc} LmpProc
Caso mude o código da tabela, so campos de procedimento e descrição do procedimento são limpos.
@since    06/2020
//-------------------------------------------------------------------*/
static function LmpProc(oModel)
local aLinha	:= {}
local lRet 		:= .t.
local oObjGrd	:= oModel:getModel("BE6Detail")
local oView     := FWViewActive()

if !empty(oObjGrd:getvalue("BE6_CODPRO"))
	aLinha := FWSaveRows(oModel)
	oObjGrd:loadvalue("BE6_CODPRO", '')
	oObjGrd:loadvalue("BE6_DESPRO", '')
	oView:Refresh("BE6Detail")
	FWRestRows(aLinha)
endif
return lRet 


/*//-------------------------------------------------------------------
{Protheus.doc} PlsCadVld
Pós validação do form. Se existir uma linha na BC1 e BE6 sem dados de relacioanmento, é excluída. 
Ocorre quando o usuário informa um valor e apaga, mas para o model, a linha foi usada. 
@since    06/2020
//-------------------------------------------------------------------*/
static function PlsCadVld(oModel)
local lRet 		:= .t.
local nRet		:= 0
local oObjBE6	:= oModel:getModel("BE6Detail")
local oObjBC1	:= oModel:getModel("BC1Detail")

For nRet := 1 to oObjBC1:Length()
	oObjBC1:GoLine(nRet)
	if ( empty(oObjBC1:getValue("BC1_CODRDA")) .and. empty(oObjBC1:getValue("BC1_CODPRF")) )
		oObjBC1:DeleteLine()
	endif
Next

For nRet := 1 to oObjBE6:Length()
	oObjBE6:GoLine(nRet)
	if ( empty(oObjBE6:getValue("BE6_CODTAB")) .and. empty(oObjBE6:getValue("BE6_CODPRO")) )
		oObjBE6:DeleteLine()
	endif
Next

return lRet
