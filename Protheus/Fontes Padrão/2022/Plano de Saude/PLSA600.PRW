#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include "PLSA600.ch"
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"
#define LAYOUT_LINEAR_L2R 0 // LEFT TO RIGHT
#define LAYOUT_LINEAR_R2L 1 // RIGHT TO LEFT
#define LAYOUT_LINEAR_T2B 2 // TOP TO BOTTOM
#define LAYOUT_ALIGN_VCENTER 3 // BOTTOM TO TOP

#DEFINE __aCdCri226 {"591","Bloq. em funcao de glosa pagto" }

static lPLSA600 := .f.
static _cSequen 	:= ""
Static afilTrat := {}
STATIC __lOracle := .F.
Static cPegAtu := ""
Static cguiatu := ""
Static aSequen := {}
Static aFilTGlo := {"" /*Filtro Evento*/,"" /*Filtro Tipo Procedimento*/,"" /*Somente itens glosados*/}
static nSaldoStt := 0

//Exibir as labels e atualizar o objeto panel com os valores dos totalizadores
static oSayCmp	:= nil
static oSayAPR	:= nil
static oSayBPR	:= nil
static oSayGLO	:= nil
static oSayPAG	:= nil
static oSayPFT	:= nil
static cTxtAPR	:= ""
static cTxtBPR	:= ""
static cTxtGLO	:= ""
static cTxtPAG	:= ""
static cTxtPFT	:= ""

//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA600
Tela de Análise de Contas.

@author Lucas Nonato.
@since  01/04/2019.
@version P12
/*/
function PLSA600()
lPLSA600 := .t.
PLSA498()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define a model

@author  Lucas Nonato
@since   01/04/2019
@version P12
/*/
static function ModelDef()
local cAlias := PlRetAlias(BCI->BCI_CODOPE,BCI->BCI_TIPGUI)
local oModel // Modelo de dados construído
local oStrCab := FWFormStruct(1, cAlias,/* 	{ |cCampo| PLS600FT(1,cCampo, cAlias, oCab ) } */)
local oStrBD6 := FWFormStruct(1, 'BD6', /*	{ |cCampo| PLS600FT(1,cCampo, 'BD6',  oBD6  ) }*/)
local oStrBD7 := FWFormStruct(1, 'BD7', /*	{ |cCampo| PLS600FT(1,cCampo, 'BD7',  oBD7  ) }*/)
local oStrBDX := FWFormStruct(1, 'BDX', /*	{ |cCampo| PLS600FT(1,cCampo, 'BDX'	 ) }*/)
local cDesc as char
oModel := MPFormModel():New('PLSA600', , , { |oModel| AtuCab( oModel ) })

oModel:addFields('MasterCab',/*cOwner*/,oStrCab)
oModel:AddGrid('BD6Detail', 'MasterCab', oStrBD6, , )
oModel:AddGrid('BD7Detail', 'BD6Detail', oStrBD7, , )
oModel:AddGrid('BDXDetail', 'BD6Detail', oStrBDX, , )

oModel:GetModel( 'BD6Detail' ):SetOptional( .t. )
oModel:GetModel( 'BDXDetail' ):SetOptional( .t. )
oModel:GetModel( 'BD7Detail' ):SetOptional( .t. )
							
oModel:SetRelation( 'BD6Detail', { 	{ 	'BD6_FILIAL', cAlias+'_FILIAL'},;
									{ 	'BD6_CODOPE', cAlias+'_CODOPE' 	},;
									{ 	'BD6_CODLDP', cAlias+'_CODLDP' 	},;
									{ 	'BD6_CODPEG', cAlias+'_CODPEG' 	},;
									{ 	'BD6_NUMERO', cAlias+'_NUMERO'  }},;  
										BD6->( IndexKey( 1 ) ))

oModel:SetRelation( 'BDXDetail', {  {	'BDX_FILIAL', /*'BD6_FILIAL'*/ 'xfilial("BDX")'},;
									{ 	'BDX_CODOPE', 'BD6_CODOPE' 	},;
									{ 	'BDX_CODLDP', 'BD6_CODLDP' 	},;
									{ 	'BDX_CODPEG', 'BD6_CODPEG' 	},;
									{ 	'BDX_NUMERO', 'BD6_NUMERO' 	},;
									{ 	'BDX_ORIMOV', 'BD6_ORIMOV' 	},;
									{ 	'BDX_CODPAD', 'BD6_CODPAD' 	},;
									{ 	'BDX_CODPRO', 'BD6_CODPRO' 	},;
									{ 	'BDX_SEQUEN', 'BD6_SEQUEN' 	},;
									{ 	'BDX_TIPREG', '"1"'  }},;  
										BDX->( IndexKey( 1 ) )) 

oModel:SetRelation( 'BD7Detail', {  { 'BD7_FILIAL', 'BD6_FILIAL'},; 
									{ 	'BD7_CODOPE', 'BD6_CODOPE' 	},;
									{ 	'BD7_CODLDP', 'BD6_CODLDP' 	},;
									{ 	'BD7_CODPEG', 'BD6_CODPEG' 	},;
									{ 	'BD7_NUMERO', 'BD6_NUMERO' 	},;
									{ 	'BD7_ORIMOV', 'BD6_ORIMOV' 	},;
									{ 	'BD7_SEQUEN', 'BD6_SEQUEN'  }},;   
										BD7->( IndexKey( 1 ) ))

oModel:SetPrimaryKey( { cAlias+'_FILIAL',cAlias+'_CODOPE',cAlias+'_CODLDP',cAlias+'_CODPEG',cAlias+'_NUMERO' } )

oModel:GetModel('MasterCab'):SetDescription(STR0001) // Análise de Guias

oModel:AddCalc( 'CALC', 'MasterCab', 'BD6Detail', 'BD6_VLRAPR', 'VLRAPRTOT', 'SUM', ,,STR0002 ) //'Valor Apresentado'
oModel:AddCalc( 'CALC', 'MasterCab', 'BD6Detail', 'BD6_VLRBPR', 'VLRBPRTOT', 'SUM', ,,STR0003 ) //'Valor Contratado' 
oModel:AddCalc( 'CALC', 'MasterCab', 'BD6Detail', 'BD6_VLRGLO', 'VLRGLOTOT', 'SUM', ,,STR0004 ) //'Valor Glosa' )
oModel:AddCalc( 'CALC', 'MasterCab', 'BD6Detail', 'BD6_VLRPAG', 'VLRPAGTOT', 'SUM', ,,STR0005 ) //'Valor Pagamento' )
oModel:AddCalc( 'CALC', 'MasterCab', 'BD6Detail', 'BD6_VLRTPF', 'VLRTPFTOT', 'SUM',{ |oModel| oModel:getModel("BD6Detail"):getvalue("BD6_BLOCPA") <> "1" } ,,STR0006 )  //'Coparticipação' 

oStrBD6:setProperty( "*" , MODEL_FIELD_INIT , 	{ || } )
oStrBDX:SetProperty( 'BDX_CODPAD' , MODEL_FIELD_INIT, {|| oModel:getModel("BD6Detail"):getValue("BD6_CODPAD")})
oStrBDX:SetProperty( 'BDX_CODPRO' , MODEL_FIELD_INIT, {|| oModel:getModel("BD6Detail"):getValue("BD6_CODPRO")})
oStrBDX:SetProperty( 'BDX_VLRAPR' , MODEL_FIELD_INIT, {|| oModel:getModel("BD6Detail"):getValue("BD6_VLRAPR")})

oStrCab:setProperty( "*" , MODEL_FIELD_OBRIGAT , 	.f. )
oStrBD6:setProperty( "*" , MODEL_FIELD_OBRIGAT , 	.f. )
oStrBD7:setProperty( "*" , MODEL_FIELD_OBRIGAT , 	.f. )
oStrBDX:setProperty( "*" , MODEL_FIELD_OBRIGAT , 	.f. )

oStrCab:setProperty( "*" , MODEL_FIELD_WHEN , 	{ || .T. } )
oStrBD6:setProperty( "*" , MODEL_FIELD_WHEN , 	{ || .T. } )
oStrBD7:setProperty( "*" , MODEL_FIELD_WHEN , 	{ || .T. } )
oStrBDX:setProperty( "*" , MODEL_FIELD_WHEN , 	{ || .f. } )//bloqueia todos os campos do grid
oStrBDX:setProperty( "BDX_RESPAL" , MODEL_FIELD_WHEN , 	{ || !empty(oModel:getModel("BDXDetail"):getValue("BDX_CODGLO")) } ) //So libera este caso tenha um BDX

oStrCab:setProperty( "*" , MODEL_FIELD_VALID , 	{ || .T. } )
oStrBD7:setProperty( "*" , MODEL_FIELD_VALID , 	{ || .T. } )
oStrBDX:setProperty( "*" , MODEL_FIELD_VALID , 	{ || .T. } )
oStrBD6:setProperty( "*" , MODEL_FIELD_VALID , 	{ || PnlTotal(nil, oModel, nil, .f.) } )

oModel:GetModel('BD6Detail'):SetNoInsertLine(.t.)
oModel:GetModel('BD6Detail'):SetNoDeleteLine(.t.)
oModel:GetModel('BDXDetail'):SetNoInsertLine(.t.)
oModel:GetModel('BDXDetail'):SetNoDeleteLine(.t.)
oModel:GetModel('BD7Detail'):SetNoInsertLine(.t.)
cDesc := "["+allTrim(BCL->BCL_DESCRI)+"] - PEG:" + BCI->BCI_CODPEG + "- " + STR0076 //"Número: "
if cAlias == "BD5"
	oModel:SetDescription( cDesc + BD5->BD5_NUMERO + "    " )
elseif cAlias == "BE4"
	oModel:SetDescription( cDesc + BE4->BE4_NUMERO + "    " )
endif
//_cSequen := getGlosados()
oStrBD6:AddField( ;                      // Ord. Tipo Desc.
	STR0075                     , ;      // [01]  C   Titulo do campo  //"Status"
	STR0075                     , ;      // [02]  C   ToolTip do campo //"Status"
	"BD6_LEGEND"                , ;      // [03]  C   Id do Field
	'C'                         , ;      // [04]  C   Tipo do campo
	13                          , ;      // [05]  N   Tamanho do campo
	0                           , ;      // [06]  N   Decimal do campo
	NIL                         , ;      // [07]  B   Code-block de validação do campo
	NIL                         , ;      // [08]  B   Code-block de validação When do campo
	NIL                         , ;      // [09]  A   Lista de valores permitido do campo
	NIL                         , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
	{||iif(BD6->BD6_SEQUEN $ getGlosados(.t.) , "BR_VERMELHO", "BR_VERDE")} , ; // [11]  B   Code-block de inicializacao do campo
	NIL                         , ;      // [12]  L   Indica se trata-se de um campo chave
	NIL                         , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.t.                              )   // [14]  L   Indica se o campo é virtual

getTpDB(@__lOracle)
oModel:SetOnDemand(.t.) 

return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a view

@author  Lucas Nonato
@since   01/04/2019
@version P12
/*/
static function ViewDef()
local cAlias := PlRetAlias(BCI->BCI_CODOPE,BCI->BCI_TIPGUI)
local oView    	as object
local oModel   	as object
local oStrCab  	as object
local oStrBD6  	as object
local oStrBD7  	as object
local oStrBDX  	as object
local cDesc 	as char

aSequen := {}

oModel  := FWLoadModel( 'PLSA600' ) // Cria as estruturas a serem usadas na View
oStrCab := FWFormStruct(2, cAlias, 	{ |cCampo| PLS600FT(2, cCampo, cAlias, oCab) })
oStrBD6 := FWFormStruct(2, 'BD6', 	{ |cCampo| PLS600FT(2, cCampo, 'BD6', oBD6 ) })
oStrBD7 := FWFormStruct(2, 'BD7', 	{ |cCampo| PLS600FT(2, cCampo, 'BD7', oBD7  ) })
oStrBDX := FWFormStruct(2, 'BDX', 	{ |cCampo| PLS600FT(2, cCampo, 'BDX') })

oView := FWFormView():New() // Cria o objeto de View

oView:EnableControlBar(.T.)
oView:SetModel(oModel)		// Define qual Modelo de dados será utilizado

oView:AddField('ViewCab' , oStrCab,'MasterCab' ) 
oView:AddGrid( 'ViewBD6' , oStrBD6,'BD6Detail' )
oView:AddGrid( 'ViewBD7' , oStrBD7,'BD7Detail' )
oView:AddGrid( 'ViewBDX' , oStrBDX,'BDXDetail' )
if cAlias == "BD5"
	cDesc := "["+BD5->BD5_OPEUSR +"."+ BD5->BD5_CODEMP +"."+ BD5->BD5_MATRIC +"."+ BD5->BD5_TIPREG +"."+ BD5->BD5_DIGITO + "] " + BD5->BD5_NOMUSR
else
	cDesc := "["+BE4->BE4_OPEUSR +"."+ BE4->BE4_CODEMP +"."+ BE4->BE4_MATRIC +"."+ BE4->BE4_TIPREG +"."+ BE4->BE4_DIGITO + "] " + BE4->BE4_NOMUSR
endif
oView:EnableTitleView( 'ViewCab', "Prestador: ["+BCI->BCI_CODRDA+"]" + alltrim(BCI->BCI_NOMRDA) +"      Beneficiario: "+ cDesc)
oView:EnableTitleView( 'ViewBD6', "Prestador: ["+BCI->BCI_CODRDA+"]" + alltrim(BCI->BCI_NOMRDA) +"      Beneficiario: "+ cDesc)
oModel:GetModel( 'BD6Detail' ):SetOptional( .T. )

oView:AddOtherObject('BOXGLO',{|oPanel| P600BTN(oPanel, oModel, oView, cAlias)})
oView:CreateFolder( 'PASTAS' )
oView:AddSheet( 'PASTAS', 'ABA01', STR0007 ) //'Análise dos Itens' 
oView:AddSheet( 'PASTAS', 'ABA02', STR0008 ) //'Guia'

//1ª Pasta - BD6 / BD7 / BDX
oView:CreateHorizontalBox( 'FILTER', 07,,, 'PASTAS', 'ABA01' )
oView:CreateHorizontalBox( 'BD6OUT', 57,,, 'PASTAS', 'ABA01' )
oView:CreateHorizontalBox( 'BOXVLR', 07,,, 'PASTAS', 'ABA01' )
oView:CreateHorizontalBox( 'BD6ANL', 29,,, 'PASTAS', 'ABA01' )
//2ª Pasta - Guia
oView:CreateHorizontalBox( 'BOXCAB' , 100,,, 'PASTAS', 'ABA02' )

//Na 2ª pasta, preciso criar mais duas pastas, sendo BD7 e BDX
oView:CreateFolder( 'PASTA_ANALISE' ,'BD6ANL' )
oView:AddSheet( 'PASTA_ANALISE'    , 'BDXGLO'    , STR0009 ) //"Glosas" 
oView:AddSheet( 'PASTA_ANALISE'    , 'BD7UNID'   , STR0010 ) //"Unidades"

//Subpastas da aba 2
oView:CreateVerticalBox( 'BD7ANL', 100,,, 'PASTA_ANALISE', 'BD7UNID' )
oView:CreateVerticalBox( 'BDXANL', 90,,, 'PASTA_ANALISE', 'BDXGLO' )
oView:CreateVerticalBox( 'BDXCAB', 10,,, 'PASTA_ANALISE', 'BDXGLO' )

oView:AddOtherObject("OTHER_PANEL", {|oPanel| fPesquisa(oPanel,oView)})
oView:AddOtherObject('PANTOT',{|oPanel| PnlTotal(oPanel, oModel, oView, .t.)})

//Relacionando donos dos ids com a tabelas
oView:SetOwnerView('ViewCab','BOXCAB')
oView:SetOwnerView('ViewBD6','BD6OUT') 
oView:SetOwnerView('ViewBDX','BDXANL')
oView:SetOwnerView('ViewBD7','BD7ANL')
oView:SetOwnerView('BOXGLO','BDXCAB')
oView:SetOwnerView("OTHER_PANEL",'FILTER')
oView:SetOwnerView("PANTOT",'BOXVLR')
oView:SetViewProperty("ViewBDX", "GRIDDOUBLECLICK", {{|oView|Pl600DetBDX(oModel, oView, .f.) }} )

oStrCab:SetNoFolder()
oStrCab:SetProperty( '*', MVC_VIEW_CANCHANGE, .f.)
oStrBD6:SetProperty( '*', MVC_VIEW_CANCHANGE, .f.)
oStrBD7:SetProperty( '*', MVC_VIEW_CANCHANGE, .f.)
oStrBDX:SetProperty( '*', MVC_VIEW_CANCHANGE, .t.) //O bloqueio foi efetuado no when, pois precisava liberar apenas um campo do grid

oStrBD6:AddField( ; 	
	'BD6_LEGEND' , ; 						// [01] C Nome do Campo
	'01' , ; 								// [02] C Ordem
	AllTrim( 'Status' ) , ; 				// [03] C Titulo do campo
	AllTrim( 'Status'  ) , ; 				// [04] C Descrição do campo
	{ STR0011 } , ; 						// [05] A Array com Help  -  'Verde=Não possui glosa; Vermelho=Possui glosa'
	'C' , ; 								// [06] C Tipo do campo
	'@BMP' , ;								// [07] C Picture
	NIL , ; 								// [08] B Bloco de Picture Var
	'' , ;  								// [09] C Consulta F3
	.f. , ; 								// [10] L Indica se o campo é editável
	NIL , ; 								// [11] C Pasta do campo
	NIL , ; 								// [12] C Agrupamento do campo
	NIL , ; 								// [13] A Lista de valores permitido do campo (Combo)
	NIL , ; 								// [14] N Tamanho Maximo da maior opção do combo
	NIL , ;									// [15] C Inicializador de Browse
	.t. , ; 								// [16] L Indica se o campo é virtual
	NIL )   								// [17] C Picture Variável	

setKey(K_CTRL_G,{|| zYuni(oModel, oView) })
setKey(K_CTRL_R,{|| Inari(oModel, oview)})

oView:AddUserButton(STR0012, "", { || Diamond(oModel) } ) //Hist. Tratamento

return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} fPesquisa
Cria o campo de pesquisa

@author  Lucas Nonato
@since   15/08/2019
@version P12
/*/
Static Function fPesquisa( oPanel, oView )

Local cCpoPesq 		:= Space(50)
Local cTpPesq		:= Space(50)
Local cTpProc		:= Space(50)
Local nPesq			:= 1                        
Local lRet			:= .F.
Local aTpPesq		:= {}                    
Local aTpProc		:= {}                         
Local oTFont2 		:= TFont():New("Arial",,-11,.T.,.F.)
Local oTFont3 		:= TFont():New("Arial",,-13,.T.,.F.)
Local oCpoPesq	
local oChckEspL		as object
local lCheck		:= .f.

aadd(aTpPesq, STR0013) //"Evento"
aadd(aTpPesq, STR0014) //"Descrição"
aadd(aTpPesq, STR0015) //"Tabela Padrão"

//0=Procedimento;1=Material;2=Medicamento;3=Taxas;4=Diarias;5=Ortese/Protese;6=Pacote;7=Gases Medicinais;8=Alugueis;9=Outros     
aadd(aTpProc, STR0016) //"Todos Procedimentos"  
aadd(aTpProc, STR0017) //"Procedimento"
aadd(aTpProc, STR0018) //"Material"

aadd(aTpProc, STR0019) //"Medicamento"
aadd(aTpProc, STR0020) //"Taxas"
aadd(aTpProc, STR0021) //"Diárias"
aadd(aTpProc, STR0022) //"Órtese/Prótese"
aadd(aTpProc, STR0023) //"Pacote"
aadd(aTpProc, STR0024) //"Gases Medicinais"
aadd(aTpProc, STR0025) //"Aluguéis"
aadd(aTpProc, STR0026) //"Outros"

@ 03,05 COMBOBOX cTpPesq ITEMS aTpPesq	SIZE 80, 015 VALID fTpPesq(@nPesq, cTpPesq)	FONT oTFont3 OF oPanel PIXEL
@ 03,90	MSGET oCpoPesq VAR cCpoPesq 	SIZE 100,010 FONT oTFont2 PIXEL OF oPanel

TBtnBmp2():New( 000,380,023,040,'BMPVISUAL'  ,,,,{|| Processa({|| lRet:=getEventos(nPesq,alltrim(cCpoPesq),oView)}, STR0027 ) }, oPanel, STR0028,,.T. ) // "Pesquisando..." / "Filtrar"

oChckEspL  := TCheckBox():New(005,250,STR0029,,oPanel,120,220,,,,,,,,.T.,,,) //"Filtrar Itens Glosados"
oChckEspL:bSetGet 	:= {|| lCheck}
oChckEspL:bLClicked := {|| lCheck := !lCheck, FiltraBDX(oView, lCheck) }

@ 03,350 COMBOBOX cTpProc ITEMS aTpProc	SIZE 80, 015 VALID fTpProc(cTpProc,oView)	FONT oTFont3 OF oPanel PIXEL


Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} fTpPesq
Define o tipo de pesquisa

@author  Lucas Nonato
@since   14/08/2019
@version P12
/*/
static function fTpPesq(nPesq, cTpPesq)

do case
	case AllTrim(cTpPesq) == STR0013 // "Evento"
		nPesq := 1		
	case AllTrim(cTpPesq) == STR0014 //"Descrição"
		nPesq := 2
	case AllTrim(cTpPesq) == STR0015 //"Tabela Padrão"
		nPesq := 3		
endcase

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} fTpPesq
Define o tipo de pesquisa

@author  Lucas Nonato
@since   14/08/2019
@version P12
/*/
static function fTpProc(cTpProc,oView)
local cSequen	:= ""
local nPesq 	:= 10	

do case
	case AllTrim(cTpProc) == STR0016 //"Todos Procedimentos"
		nPesq := 10	
	case AllTrim(cTpProc) == STR0017 //"Procedimento"
		nPesq := 0
	case AllTrim(cTpProc) == STR0018 //"Material"
		nPesq := 1
	case AllTrim(cTpProc) == STR0019 //"Medicamento"
		nPesq := 2
	case AllTrim(cTpProc) == STR0020 //"Taxas"
		nPesq := 3	
	case AllTrim(cTpProc) == STR0021 //"Diárias"
		nPesq := 4	
	case AllTrim(cTpProc) == STR0022 //"Órtese/Prótese"
		nPesq := 5	
	case AllTrim(cTpProc) == STR0023 //"Pacote"
		nPesq := 6	
	case AllTrim(cTpProc) == STR0024 //"Gases Medicinais"
		nPesq := 7	
	case AllTrim(cTpProc) == STR0025 //"Alugueis"
		nPesq := 8	
	case AllTrim(cTpProc) == STR0026 //"Outros"
		nPesq := 9		
endcase

if nPesq <> 10
	cSql := " SELECT BD6_SEQUEN FROM " + RetSqlName("BD6") + " BD6 "
	cSql += " INNER JOIN " + RetSqlName("BR8") + " BR8 "
	cSql += " ON BR8_FILIAL = '" + xFilial("BR8") + "' "
	cSql += " AND BR8_CODPAD = BD6_CODPAD "
	cSql += " AND BR8_CODPSA = BD6_CODPRO "
	cSql += " AND BR8_TPPROC = '" + cvaltochar(nPesq) + "' "
	cSql += " AND BR8.D_E_L_E_T_ = ' ' "
	cSql += " WHERE BD6_FILIAL = '" + xFilial("BD6") + "' "
	cSql += " AND BD6_CODOPE = '" + BCI->BCI_CODOPE + "' "
	cSql += " AND BD6_CODLDP = '" + BCI->BCI_CODLDP + "' "
	cSql += " AND BD6_CODPEG = '" + BCI->BCI_CODPEG + "' "
	if _cAlias == "BD5"
		cSql += " AND BD6_NUMERO = '" + BD5->BD5_NUMERO + "' "
		cSql += " AND BD6_ORIMOV = '" + BD5->BD5_ORIMOV + "' "
	else
		cSql += " AND BD6_NUMERO = '" + BE4->BE4_NUMERO + "' "
		cSql += " AND BD6_ORIMOV = '" + BE4->BE4_ORIMOV + "' "
	endif
	cSql += " AND BD6.D_E_L_E_T_ = ' '	"
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbTP",.F.,.T.)
	while !TrbTP->(eof())
		cSequen += TrbTP->BD6_SEQUEN+ "/"
		TrbTP->(dbskip())
	enddo
	TrbTP->(dbclosearea())		
endif

setFilter(nPesq <> 10, cSequen, oView, 'Procedimento', 'TpProc')


Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} getEventos
Efetua a pesquisa das Guias

@author  Lucas Nonato
@since   15/08/2019
@version P12
/*/
static function getEventos(nPesq,cCpoPesq, oView)
local cSql 		as char
local cSequen 	:= ""

if !empty(cCpoPesq)
	cSql := " SELECT BD6_SEQUEN FROM " + RetSqlName("BD6") + " BD6 "
	cSql += " WHERE BD6_FILIAL = '" + xFilial("BD6") + "' "
	cSql += " AND BD6_CODOPE = '" + BCI->BCI_CODOPE + "' "
	cSql += " AND BD6_CODLDP = '" + BCI->BCI_CODLDP + "' "
	cSql += " AND BD6_CODPEG = '" + BCI->BCI_CODPEG + "' "
	if _cAlias == "BD5"
		cSql += " AND BD6_NUMERO = '" + BD5->BD5_NUMERO + "' "
		cSql += " AND BD6_ORIMOV = '" + BD5->BD5_ORIMOV + "' "
	else
		cSql += " AND BD6_NUMERO = '" + BE4->BE4_NUMERO + "' "
		cSql += " AND BD6_ORIMOV = '" + BE4->BE4_ORIMOV + "' "
	endif
	do case
		case nPesq == 1//CODPRO
			cSql += " AND BD6_CODPRO = '" + cCpoPesq + "' "
		case nPesq == 2//DESCRICAO
			cSql += " AND BD6_DESPRO LIKE '%" + upper(cCpoPesq) + "%' "
		case nPesq == 3//CODPAD
			cSql += " AND BD6_CODPAD = '" + cCpoPesq + "' "
	endcase
	cSql += " AND BD6.D_E_L_E_T_ = ' '	"
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbGE",.F.,.T.)
	while !TrbGE->(eof())
		cSequen += TrbGE->BD6_SEQUEN+ "/"
		TrbGE->(dbskip())
	enddo
	TrbGE->(dbclosearea())
endif

setFilter(!empty(cCpoPesq), cSequen, oView, "Eventos","Eventos")

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} P600BTN
Botões do canto direito

@author  Lucas Nonato
@since   01/04/2019
@version P12
/*/
function P600BTN(oPanel, oModel, oView, cAlias)

@ oPanel:nTop , 002  Button STR0030  Size oPanel:nWidth/2, oPanel:nBottom/6  Pixel Action ;  //'Glosar'
	P600BAct(4,oModel, oView, cAlias) of oPanel PIXEL

@ (oPanel:nTop+oPanel:nBottom/6)+1, 002 Button STR0031  Size oPanel:nWidth/2, oPanel:nBottom/6  Pixel Action ; //'Retirar Glosas'
	P600BAct(5,oModel, oView, cAlias) of oPanel PIXEL

@ (oPanel:nTop+oPanel:nBottom/3)+1, 002 Button STR0032  Size oPanel:nWidth/2, oPanel:nBottom/6  Pixel Action ; //'Complemento Críticas'
	Pl600DetBDX(oModel, oView) of oPanel PIXEL	

return

//--------------------------------------------------------------
/*/{Protheus.doc} P600BAct

@author    Lucas Nonato
@version   V12
@since     07/08/2019
/*/
function P600BAct(nTp,oModel, oView, cAlias)
Do Case

	Case nTp == 4
		
		zYuni(oModel, oView)

	case nTp == 5

		Inari(omodel, oView)

endcase

return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS600FT
Tratamento para ajustar os campos a ser utilizados da tabela.
@author Lucas Nonato
@since 01/04/2019
@version P12
/*/
function PLS600FT(nTp, cCampo, cAlias, oHash)
local lRet	:= .f.
default oHash := nil

if nTp == 1
	if "_FILIAL" $ cCampo .or. "_CODOPE" $ cCampo .or. "_CODLDP" $ cCampo .or. "_CODPEG" $ cCampo .or. "_NUMERO" $ cCampo .or. "_ORIMOV" $ cCampo .or. "_SEQUEN" $ cCampo 
		return .t.
	endif
endif

if oHash <> nil .and. HMGet( oHash , cCampo  )
	return .t.
endif

do Case
case cAlias == "BD5"
	if allTrim(cCampo) == "BD5_SENHA" 
		lRet := .t.
	else
		lRet := .f.
	endif
case cAlias == "BD6" 
	if cCampo == "BD6_LEGEND" .or. cCampo == "BD6_VLRTPF" .or. cCampo == "BD6_VLRAPR" .or. cCampo == "BD6_VLRBPR" .or. cCampo == "BD6_VLRGLO" .or. cCampo == "BD6_VLRPAG";
		.or. cCampo == "BD6_CODPAD" .or. cCampo == "BD6_CODPRO" .or. cCampo == "BD6_SEQUEN"
		lRet := .t.
	endif
case cAlias == "BDX" 
	if cCampo == "BDX_IMGSTA" .or. cCampo == "BDX_CODGLO" .or. cCampo == "BDX_DESGLO" .or. cCampo == "BDX_ACAO" ;
		.or. cCampo == "BDX_VLRGLO" .or. cCampo == "BDX_VLRGTX" .OR. cCampo == "BDX_OBS" .OR. cCampo == "BDX_RESPAL"
		lRet := .t.
	endif
endcase

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} setBCM
Carrega os campos dinamicamente 

@author  Lucas Nonato
@since   01/04/2019
@version P12
/*/
static function setBCM(cAlias)
local cSql   as char
local aDados as array
local oHash

aDados := {}

cSql := " SELECT BCM_CAMPO FROM  " + RetSqlName("BCM") + " BCM "
cSql += " WHERE BCM_FILIAL = '" + xFilial("BCM") + "' " 
cSql += " AND BCM_CODOPE = '" + BCI->BCI_CODOPE + "' " 
cSql += " AND BCM_TIPGUI = '" + BCI->BCI_TIPGUI + "' "
cSql += " AND BCM_ALIAS = '" + cAlias + "' "
cSql += " AND D_E_L_E_T_ = ' ' "
cSql += " GROUP BY BCM_CAMPO "

cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbBCM",.F.,.T.)

while TrbBCM->(!eof())
	aadd(aDados, {TrbBCM->BCM_CAMPO, "" } )
	TrbBCM->(dbskip())
enddo
TrbBCM->(dbclosearea())

oHash := aToHM(aDados,1)
limpaArray(aDados)
return oHash

//-------------------------------------------------------------------
/*/{Protheus.doc} limpaArray
Limpa de maneira correta o array para evitar estouro de memória

@author  Lucas Nonato
@version P11
@since   04/11/16
/*/
static function limpaArray(aArray)

while Len(aArray) > 0
	aDel(aArray,len(aArray))
	aSize(aArray, len(aArray)-1)	
enddo

return

//--------------------------------------------------------------
/*/{Protheus.doc} isPLSA600

@author    Lucas Nonato
@version   V12
@since     07/08/2019
/*/
function isPLSA600()
return lPLSA600

//--------------------------------------------------------------
/*/{Protheus.doc} P600GETBCM

@author    Lucas Nonato
@version   V12
@since     07/08/2019
/*/
function P600GETBCM(cAlias)
local cSql   as char
local aDados as array
local oHash  as object

if BCM->(fieldpos("BCM_ANALIC")) > 0
	aDados := {}

	cSql := " SELECT BCM_CAMPO FROM  " + RetSqlName("BCM") + " BCM "
	cSql += " WHERE BCM_FILIAL = '" + xFilial("BCM") + "' " 
	cSql += " AND BCM_CODOPE = '" + BCI->BCI_CODOPE + "' " 
	cSql += " AND BCM_TIPGUI = '" + BCI->BCI_TIPGUI + "' "
	cSql += " AND BCM_ALIAS = '" + cAlias + "' "
	cSql += " AND BCM_ANALIC = 'T' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " GROUP BY BCM_CAMPO "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbBCM",.F.,.T.)

	while TrbBCM->(!eof())
		aadd(aDados, {TrbBCM->BCM_CAMPO, "" } )
		TrbBCM->(dbskip())
	enddo
	TrbBCM->(dbclosearea())

	oHash := aToHM(aDados,1)
	limpaArray(aDados)
endif

return oHash

//--------------------------------------------------------------
/*/{Protheus.doc} getGlosados

@author    Lucas Nonato
@version   V12
@since     07/08/2019
/*/
static function getGlosados(lIniPad)
local cSql as char
local cRet := ""
default lIniPad := .f.

cSql := " SELECT BD6_SEQUEN FROM " + RetSqlName("BD6") + " BD6 "
cSql += " INNER JOIN " + RetSqlName("BDX") + " BDX "
cSql += " ON BDX_FILIAL = '" + xFilial("BDX") + "' "
cSql += " AND BDX_CODOPE = BD6_CODOPE "
cSql += " AND BDX_CODLDP = BD6_CODLDP "
cSql += " AND BDX_CODPEG = BD6_CODPEG "
cSql += " AND BDX_NUMERO = BD6_NUMERO "
cSql += " AND BDX_ORIMOV = BD6_ORIMOV "
cSql += " AND BDX_CODPAD = BD6_CODPAD "
cSql += " AND BDX_CODPRO = BD6_CODPRO "
cSql += " AND BDX_SEQUEN = BD6_SEQUEN "
cSql += " AND BDX.D_E_L_E_T_ = ' ' 
cSql += " WHERE BD6_FILIAL = '" + xFilial("BD6") + "' "
cSql += " AND BD6_CODOPE = '" + BCI->BCI_CODOPE + "' "
cSql += " AND BD6_CODLDP = '" + BCI->BCI_CODLDP + "' "
cSql += " AND BD6_CODPEG = '" + BCI->BCI_CODPEG + "' "
if _cAlias == "BD5"
	cSql += " AND BD6_NUMERO = '" + BD5->BD5_NUMERO + "' "
	cSql += " AND BD6_ORIMOV = '" + BD5->BD5_ORIMOV + "' "
else
	cSql += " AND BD6_NUMERO = '" + BE4->BE4_NUMERO + "' "
	cSql += " AND BD6_ORIMOV = '" + BE4->BE4_ORIMOV + "' "
endif
if lIniPad
	cSql += " AND BD6_SEQUEN = '" + BD6->BD6_SEQUEN + "' "
endif
cSql += " AND BD6.D_E_L_E_T_ = ' '	"
cSql += " GROUP BY BD6_SEQUEN "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbGL",.F.,.T.)
while !TrbGL->(eof())
	cRet += TrbGL->BD6_SEQUEN+ "/"
	TrbGL->(dbskip())
enddo
TrbGL->(dbclosearea())

return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FiltraBDX
Executa filtro no browse

@author  Renan Martins
@version P12
@since   04/2019
/*/
//------------------------------------------------------------------- 
static function FiltraBDX(oView, lCheck)
local cSequen	as char

if lCheck
	cSequen := getGlosados()
endif
setFilter(lCheck, cSequen, oView, "Glosas","ItemBDX")

return

//--------------------------------------------------------------
/*/{Protheus.doc} setFilter

@author    Lucas Nonato
@version   V12
@since     07/08/2019
/*/
static function setFilter(lOk, cSequen, oView, cName, cId)
local oViewBD6 	:= oView:GetViewObj('ViewBD6')[3]
local cFilter	:= ""
local aFilter 	:= { 	{"BD6_SEQUEN", "FIELD", "Contêm Filtro", cFilter, cFilter},;
						{"$","OPERATOR","","",""},;
						{cSequen,"EXPRESSION","","","",.T.} }
if lOk		
	cFilter := "BD6_SEQUEN $ '"+cSequen + "'"
	oViewBD6:oBrowse:CleanFilter()
	oViewBD6:oBrowse:CleanExFilter()
	oViewBD6:oBrowse:DeleteFilter(cId) 
	oViewBD6:oBrowse:AddFilter(	cName, cFilter ,.t.,.t., , , aFilter, cId )
	oViewBD6:oBrowse:ExecuteFilter(.t.)
else
	oViewBD6:oBrowse:CleanFilter()
	oViewBD6:oBrowse:CleanExFilter()
	oViewBD6:oBrowse:DeleteFilter(cId) 
endif

If cId == "TpProc"
	aFilTGlo[1] := cSequen
elseIf cId == "Eventos"
	aFilTGlo[2] := cSequen
elseIf cId == "ItemBDX"
	aFilTGlo[3] := cSequen
endIf

oView:Refresh()

return

//--------------------------------------------------------------
/*/{Protheus.doc} getSeqGlo

@author    Lucas Nonato
@version   V12
@since     07/08/2019
/*/
function getSeqGlo()
return _cSequen


//-------------------------------------------------------------------
/*/ {Protheus.doc} yuni
Tela para informar código e valor à glosar
@since ??/2020
@version P12. 
/*/
//-------------------------------------------------------------------
static function yuni(oModel, lAuto)
Local cTitulo 		:= STR0033 //'Inclusão de glosa'
local cCodGlo 		:= '   '
Local cDesglo 		:= '                    '
Local __nValor		:= omodel:getModel("BD6Detail"):Getvalue("BD6_VLRPAG")
Local lOk 			:= .F.
local bOK      		:= {|| lOk := .T., oDlg:end() }
local bCancel  		:= {|| lOk := .F., oDlg:end() }
LOCAL aRet 			:= {0, ""}
LOCAL nLimiteGlo	:= __nValor

Local cVar1 		:= omodel:getModel("BD6Detail"):Getvalue("BD6_CODPRO")
Local cVar2 		:= AllTrim(omodel:getModel("BD6Detail"):Getvalue("BD6_DESPRO"))
Local nQtdProX 		:= omodel:getModel("BD6Detail"):Getvalue("BD6_QTDPRO")
Local nVlrOriginal 	:= omodel:getModel("BD6Detail"):Getvalue("BD6_VLRBPR")
Local nVlrAprOri 	:= omodel:getModel("BD6Detail"):Getvalue("BD6_VALORI")
Local __nValor 		:= 0 //omodel:getModel("BD6Detail"):Getvalue("BD6_VLRPAG")
Local nVlrJaGlosado := omodel:getModel("BD6Detail"):Getvalue("BD6_VLRGLO")
Local nVlrMan 		:= omodel:getModel("BD6Detail"):Getvalue("BD6_VLRMAN") 
Local nVlrUnit 		:= round( (nVlrMan / nQtdProX), PLGetDec('BD6_VLRAPR'))
Local nVlrUniX 		:= nVlrMan
Local __nQuant 		:= 0 //nQtdProX
Local cObs 			:= " "
Local nVlrSaldo 	:= omodel:getModel("BD6Detail"):GetValue("BD6_VLRPAG")
Local l1 			:= .T.
Local l2 			:= .T.
Default lAuto 		:= .F.

DEFINE FONT oFont1 NAME "Arial" size 0,-15 BOLD
DEFINE FONT oFont  NAME "Arial" size 0,-12 BOLD

If !lAuto
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 60,200 TO 540,800 OF GetWndDefault() Pixel

	@ 032,015 Say oSay Prompt STR0034					Size 220,010 of oDlg Pixel //"Código Procedimento"
	@ 042,015 MsGet oCodGlo Var cVar1					Size 050,010 of oDlg Pixel Picture "@!" WHEN .f.

	@ 032,070 Say oSay Prompt STR0035 	 				Size 220,010 of oDlg Pixel //"Descrição"
	@ 042,070 MsGet oDesGlo Var cVar2					Size 220,010 of oDlg Pixel Picture "@!" WHEN .f.
	
	@ 055,015 Say oSay Prompt STR0036 		 			Size 220,010 of oDlg Pixel //"Código Glosa"
	@ 065,015 MsGet oCodGlo Var cCodGlo				 	Size 050,010 of oDlg Pixel Picture "@!" F3 "BCTPLS" HASBUTTON valid Vldglosa(cCodGlo,@cDesGlo)
	
	@ 055,070 Say oSay Prompt STR0037					Size 220,010 of oDlg Pixel //"Descrição Glosa" 
	@ 065,070 MsGet oDesGlo Var cDesGlo				 	Size 220,010 of oDlg Pixel Picture "@!" WHEN .f.
	
	@ 080,005 Say oSay Prompt STR0038 					Size 220,010 of oDlg Pixel //"Quantidade a Glosar"
	@ 090,005 MsGet oQuant  Var __nQuant				Size 050,010 of oDlg Pixel WHEN l1 .AND. ! empty(cCodGlo) Picture "@E 99999.99" Valid __nQuant >= 0 .AND. AtuValZ(1,@__nQuant,@nQtdProX,@nVlrUnit,@nVlrOriginal,@nVlrAprOri,@__nValor,@nVlrJaGlosado,@nVlrMan,@nVlrUniX,@l1, @l2,@nVlrSaldo) //.and. PLINQTGM(@__nValor, nQtdProX, nVlrSaldo, __nQuant, nVlrOriginal, nVlrJaGlosado, oBrwPro, oBrwGlo) .and. Eval(bAdd,3) .and. atuLbl(oSayZ)

	@ 080,070 Say oSay Prompt STR0039	 	 			Size 50,010 of oDlg Pixel //"Valor Unitário"
	@ 090,070 MsGet oVlrUnit  Var nVlrUnit			 	Size 050,010 of oDlg Pixel WHEN .f. Picture "@E 99,999,999.99"

	@ 080,130 Say oSay Prompt STR0040 					Size 050,010 of oDlg Pixel //"Quantidade Original"
	@ 090,130 MsGet oValor  Var nQtdProX				Size 050,010 of oDlg Pixel WHEN .f. Picture "@E 99,999,999.99" Valid .t.

	@ 080,190 Say oSay Prompt STR0041 	 				Size 50,010 of oDlg Pixel //"Valor Contratado"
	@ 090,190 MsGet oVlrOriginal  Var nVlrOriginal		Size 050,010 of oDlg Pixel WHEN .f. Picture "@E 99,999,999.99"

	@ 080,240 Say oSay Prompt STR0042  					Size 050,010 of oDlg Pixel //"Valor Apresentado"
	@ 090,240 MsGet oValor  Var nVlrAprOri				Size 050,010 of oDlg Pixel WHEN .f. Picture "@E 99,999,999.99" Valid .t.

	@ 105,005 Say oSay Prompt STR0043 		 			Size 050,010 of oDlg Pixel //"Valor da Glosa"
	@ 115,005 MsGet oValor  Var __nValor				Size 050,010 of oDlg Pixel When l2 .AND. ! empty(cCodGlo) Picture "@E 99,999,999.99" Valid __nValor >= 0 .ANd. __nValor <= nLimiteglo .AND. AtuValZ(2,@__nQuant,@nQtdProX,@nVlrUnit,@nVlrOriginal,@nVlrAprOri,@__nValor,@nVlrJaGlosado,@nVlrMan,@nVlrUniX,@l1,@l2,@nVlrSaldo) //.and. PLINGLO(@__nQuant) .and. eval(bAdd,3) .and. atuLbl(oSayZ)
	
	@ 105,80 Say oSay Prompt STR0044 	 				Size 50,010 of oDlg Pixel //"Valor Já glosado"
	@ 115,80 MsGet oVlrGlo  Var nVlrJaGlosado			Size 050,010 of oDlg Pixel WHEN .f. Picture "@E 99,999,999.99" Valid .T.

	@ 105,160 Say oSay Prompt STR0045			  		Size 050,010 of oDlg Pixel //"Valor Base Pgto."
	@ 115,160 MsGet oValor  Var nVlrUniX				Size 050,010 of oDlg Pixel WHEN .f. Picture "@E 99,999,999.99" Valid .t.

	@ 105,240 Say oSay Prompt STR0046		 	 	 	Size 220,010 of oDlg Pixel //"Saldo a Pagar"
	@ 115,240 MsGet oVlrMan  Var nVlrSaldo			 	Size 050,010 of oDlg Pixel WHEN .f. Picture "@E 99,999,999.99" Valid nVlrMan >= 0 .and. StaticCall(PLSA500,PLINVLGM,@__nValor, @__nQuant, nVlrSaldo, nVlrMan, nVlrUniX ) .and. eval(bAdd,3) .and. staticcall(PLSA500,AtuLbl,oSayZ)

	@ 130,005 Say oSay Prompt STR0047 			 		Size 220,010 of oDlg Pixel //"Observação"
	@ 140,005  GET oObs  VAR cObs MEMO 					SIZE 280,70 OF oDlg PIXEL Pixel

	ACTIVATE MSDIALOG oDlg ON INIT (EnChoiceBar(oDlg,bOK,bCancel,.f.,{})) CENTER
else
	//automação
	lOk := .T.
	cCodglo := "002"
	cDesGlo := "teste ok"	
ENDIF

If lOk
	aRet := { __nValor, alltrim(cCodGlo), alltrim(cDesglo), cObs}
endIF

return aRet


//-------------------------------------------------------------------
/*/ {Protheus.doc} Vldglosa
Valid do código da glosa e preenchimento da descrição
@since ??/2020
@version P12. 
/*/
//-------------------------------------------------------------------
static function Vldglosa(cCodGlo,cDesGlo)

Local lRet := .F.

lRet := existCpo('BCT',PLSINTPAD() + cCodGlo,1)
If lRet
	cDesGlo := BCT->(Posicione("BCT",1,xFilial("BCT") + PlsIntPad() + cCodGlo,"BCT_DESCRI"))
endIf

return lRet


//-------------------------------------------------------------------
/*/ {Protheus.doc} Inari
Função do botão retirar glosas.
@since ??/2020
@version P12. 
/*/
//-------------------------------------------------------------------
static function Inari(omodel, oView, lauto, lReplica)
Local lCopPag  		:= BA0->BA0_BASCOP == "1"
local lModCTX  		:= getNewPar("MV_PLSMCTA","1") == "1"
Local nI 			:= 1
Local cChave 		:= ""
Local aarea 		:= BD6->(getArea())
Local nFor 			:= 0
Local nLinhaAtu 	:= 0
Local nSaldoPag 	:= 0
local lZeraglo 		:= .F.
Default lauto 		:= .F.
Default lReplica 	:= .F.
	
	//aSequen -> aqui preenchemos o asequen com os recnos do BD6
	cChave := oModel:Getmodel("BD6Detail"):getvalue("BD6_CODOPE")
	cChave += oModel:Getmodel("BD6Detail"):getvalue("BD6_CODLDP")
	cChave += oModel:Getmodel("BD6Detail"):getvalue("BD6_CODPEG")
	cChave += oModel:Getmodel("BD6Detail"):getvalue("BD6_NUMERO")
	cChave += oModel:Getmodel("BD6Detail"):getvalue("BD6_ORIMOV")
	cChave += oModel:Getmodel("BD6Detail"):getvalue("BD6_SEQUEN")

	BD6->(dbsetOrder(1))
	If BD6->(MsSeek(xFilial("BD6") + cChave))
		aadd(aSequen, BD6->(Recno()))
	endIf
	restArea(aArea)


	for nI := 1 to oModel:GetModel('BDXDetail'):length()
		oModel:GetModel('BDXDetail'):goline(nI)
		if oModel:GetModel("BDXDetail"):getvalue("BDX_CODGLO") == "020" .And. oModel:GetModel("BDXDetail"):getvalue("BDX_TIPGLO") <> "3" 
			lZeraglo := .T.
			exit
		endif
	next	

	//nSaldoPag será o valor retirado da glosa
	nSaldoPag := IIF( !lZeraglo .and. oModel:Getmodel("BD6Detail"):getvalue("BD6_VLRGLO") + oModel:Getmodel("BD6Detail"):getvalue("BD6_VLRPAG") > oModel:Getmodel("BD6Detail"):getvalue("BD6_VLRBPR"), oModel:Getmodel("BD6Detail"):getvalue("BD6_VLRBPR"), oModel:Getmodel("BD6Detail"):getvalue("BD6_VLRGLO") )

	If !lZeraglo .and. nSaldoPag + oModel:Getmodel("BD6Detail"):getvalue("BD6_VLRPAG") > oModel:Getmodel("BD6Detail"):getvalue("BD6_VLRBPR")
		nSaldoPag := 0 //Zera se superar o valor contratado
	endIf

	oModel:Getmodel("BD6Detail"):Setvalue("BD6_VLRPAG",nSaldoPag + oModel:Getmodel("BD6Detail"):getvalue("BD6_VLRPAG")) //Adiciona o saldo ao pagamento
	oModel:Getmodel("BD6Detail"):Setvalue("BD6_VLRGLO", oModel:Getmodel("BD6Detail"):getvalue("BD6_VLRGLO") - nSaldoPag) //Retira o saldo do valor de glosa

	If oModel:Getmodel("BD6Detail"):getvalue("BD6_BLOCPA") == "1" .AND. oModel:Getmodel("BD6Detail"):getvalue("BD6_MOTBPF") == __aCdCri226[1]
		oModel:Getmodel("BD6Detail"):setvalue("BD6_BLOCPA", " ")
		oModel:Getmodel("BD6Detail"):setvalue("BD6_MOTBPF", " ")
		oModel:Getmodel("BD6Detail"):setvalue("BD6_DESBPF", " ")
	endIf

	If oModel:Getmodel("BD6Detail"):getvalue("BD6_PRTXPG") > 0
		omodel:getModel("BD6Detail"):setvalue("BD6_VLTXPG", omodel:Getmodel("BD6Detail"):getValue("BD6_VLRPAG") * oModel:Getmodel("BD6Detail"):getvalue("BD6_PRTXPG") / 100 )
		omodel:getModel("BD6Detail"):setvalue("BD6_VLRGTX", omodel:Getmodel("BD6Detail"):getValue("BD6_VLRGLO") * oModel:Getmodel("BD6Detail"):getvalue("BD6_PRTXPG") / 100 )
	eNDIF

	if nSaldoPag > 0 //Caso não haja efetivamente a retirada de glosa, não deverá executar esses comandos
	//Cobra o que paga somente se for coparticipacao
		if  (oModel:Getmodel("BD6Detail"):Getvalue("BD6_TPPF  ") == '1' .and. lCopPag) .or. (oModel:Getmodel("BD6Detail"):Getvalue("BD6_TPPF  ") == '2' .and. lCopPag .and. getNewPar("MV_PLSGCGP","0") == "1" .and. oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRPAG") == 0) 
			//Para os casos aonde eu glosei integral o item  e parametro ativado não pago coparticipacao

			oModel:Getmodel("BD6Detail"):Loadvalue("BD6_VLRBPF",oModel:Getmodel("BD6Detail"):getvalue("BD6_VLRPAG"))

			if oModel:Getmodel("BD6Detail"):Getvalue("BD6_PERCOP") > 0//(BD6->BD6_PERCOP > 0) //oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRPAG")
				oModel:Getmodel("BD6Detail"):setvalue("BD6_VLRPF",( oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRBPF") * oModel:Getmodel("BD6Detail"):Getvalue("BD6_PERCOP") ) / 100)
			endIf

			oModel:Getmodel("BD6Detail"):setvalue("BD6_VLRTAD",  ( iIf(lModCTX, oModel:Getmodel("BD6Detail"):getvalue("BD6_VLRPF"), oModel:Getmodel("BD6Detail"):getvalue("BD6_VLRBPF")) * oModel:Getmodel("BD6Detail"):getvalue("BD6_PERTAD") ) / 100   )
			oModel:Getmodel("BD6Detail"):setvalue("BD6_VLRTPF",oModel:Getmodel("BD6Detail"):getvalue("BD6_VLRPF") + oModel:Getmodel("BD6Detail"):getvalue("BD6_VLRTAD"))

			//se tem limite de franquia 
			if oModel:Getmodel("BD6Detail"):Getvalue("BD6_F_VFRA") > 0 .AND. oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRTPF") > 0 .AND. oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRTPF") > oModel:Getmodel("BD6Detail"):Getvalue("BD6_F_VFRA")
				//guarda os valores originais
				//nPerda := 100 - ( ( BD6->BD6_F_VFRA / BD6->BD6_VLRTPF ) * 100 ) 
				nPerda := 100 - ( ( oModel:Getmodel("BD6Detail"):Getvalue("BD6_F_VFRA") / oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRTPF") ) * 100 )  
				if oModel:Getmodel("BD6Detail"):Getvalue("BD6_PERCOP") > 0 //BD6->BD6_PERCOP > 0
					//BD6->BD6_F_VLPF := (BD6->BD6_VLRTPF / BD6->BD6_PERCOP) * 100
					oModel:Getmodel("BD6Detail"):setvalue("BD6_F_VLPF", oModel:Getmodel("BD6Detail"):getvalue("BD6_VLRTPF") / oModel:Getmodel("BD6Detail"):getvalue("BD6_PERCOP") * 100 )
				endIf

				oModel:Getmodel("BD6Detail"):setvalue("BD6_F_PPER",nPerda)
				oModel:Getmodel("BD6Detail"):setvalue("BD6_F_VLOR", oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRPF") )
				oModel:Getmodel("BD6Detail"):setvalue("BD6_F_TXOR", oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRTAD") )
				oModel:Getmodel("BD6Detail"):setvalue("BD6_F_TOOR", oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRTPF") )

				//aplica a perda da franquia nos valores de coparticipacao
				oModel:Getmodel("BD6Detail"):setvalue("BD6_VLRPF", oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRPF") - (oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRPF") * nPerda / 100) )

				if oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRTAD") > 0 .AND. getNewPar("MV_PLSFCFR","1") == "1"
					oModel:Getmodel("BD6Detail"):setvalue("BD6_VLRTAD", oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRTAD") - (oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRTAD") * nPerda / 100) )
				endIf	
				
				//ajusta a diferenca de arredondamento 
				oModel:Getmodel("BD6Detail"):setvalue("BD6_VLRTAD", oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRTAD") + oModel:Getmodel("BD6Detail"):Getvalue("BD6_F_VFRA") - oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRPF") - oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRTAD")  )	
				oModel:Getmodel("BD6Detail"):setvalue("BD6_VLRTPF", oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRPF") + oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRTAD") )	
			else

				oModel:Getmodel("BD6Detail"):setvalue("BD6_F_VLPF",0)
				oModel:Getmodel("BD6Detail"):setvalue("BD6_F_PPER",0)
				oModel:Getmodel("BD6Detail"):setvalue("BD6_F_VLOR",0)
				oModel:Getmodel("BD6Detail"):setvalue("BD6_F_TXOR",0)
				oModel:Getmodel("BD6Detail"):setvalue("BD6_F_TOOR",0)
				
			endIf	
		endif
	endIf

	for nI := 1 to oModel:GetModel('BDXDetail'):length()
		oModel:GetModel('BDXDetail'):goline(nI)
		if nSaldoPag > 0
			oModel:getmodel("BDXDetail"):Loadvalue("BDX_VLRGLO", 0) 
			oModel:GetModel("BDXDetail"):Loadvalue("BDX_TIPGLO", "2")
		endif
		oModel:GetModel("BDXDetail"):Loadvalue("BDX_ACAO  ", '2')
		oModel:GetModel("BDXDetail"):Loadvalue("BDX_CRIANA", '1')
		oModel:GetModel("BDXDetail"):Loadvalue("BDX_IMGSTA", "BR_VERDE")
		oModel:GetModel("BDXDetail"):Loadvalue("BDX_OBS   ", "Glosa reconsiderada pelo usuário")
	next
	Liquid(@oModel)

	If !lReplica .AND. oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRGLO") == 0 ;
		.AND. ( !(empty(aFilTGlo[1])) .OR. !(empty(aFilTGlo[2])) .OR. !(empty(aFilTGlo[3])) )
		If !lauto .AND. MsgYesNo("Deseja retirar as glosas de todos os itens atualmente filtrados?")
			nLinhaAtu := oModel:Getmodel("BD6Detail"):getLine()
			For nFor := 1 To oModel:Getmodel("BD6Detail"):length()
				oModel:Getmodel("BD6Detail"):GoLine(nFor)
				If oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRGLO") > 0 .AND. nLinhaAtu <> oModel:Getmodel("BD6Detail"):getLine();
					.AND.    IIF(!(empty(aFilTGlo[1])), oModel:Getmodel("BD6Detail"):Getvalue("BD6_SEQUEN") $ aFilTGlo[1], .T. );
					.AND.    IIF(!(empty(aFilTGlo[2])), oModel:Getmodel("BD6Detail"):Getvalue("BD6_SEQUEN") $ aFilTGlo[2], .T. );
					.AND.    IIF(!(empty(aFilTGlo[3])), oModel:Getmodel("BD6Detail"):Getvalue("BD6_SEQUEN") $ aFilTGlo[3], .T. )

					Inari(@omodel, @oView, lauto, .T.)
				endIf
			next
			oModel:Getmodel("BD6Detail"):GoLine(nLinhaAtu)
		endIF
	endIf

	If !lauto
		oView:Refresh()
	endIf
return


//-------------------------------------------------------------------
/*/ {Protheus.doc} zYuni
Função para o botão de inserir glosas. Faz validações, prepara automação e permite inserir glosas.
@since ??/2020
@version P12. 
/*/
//-------------------------------------------------------------------
static function zYuni(oModel, oView, lAuto, lreplica, aRepGlo)
Local lCopPag 		:= .F. //BA0->BA0_BASCOP == "1"
local lModCTX		:= getNewPar("MV_PLSMCTA","1") == "1"
Local aGloman		:= {0,""}
Local nLinhaAtu 	:= 0
Local nFor 			:= 0
Local aGloRep 		:= {}

Default lauto 		:= .F.
default lReplica 	:= .F.
Default aRepGlo 	:= {}

	If lReplica
		agloman := aclone(aRepGlo)
	else
		If oModel:Getmodel("BD6Detail"):getvalue("BD6_VLRPAG") > 0
			aGloman := yuni(oModel, lauto)
		else
			Msgalert(STR0048) //"Não há valor disponível para glosa"
		endIf
	endIf

	If aGloman[1] > 0
		oModel:GetModel('BDXDetail'):SetNoInsertLine(.F.)
		If oModel:Getmodel("BDXDetail"):Length() > 1 .OR. ( empty(oModel:Getmodel("BDXDetail"):getvalue("BDX_CODGLO")) .AND. oModel:Getmodel("BDXDetail"):Length() > 1 ) .OR. ( !empty(oModel:Getmodel("BDXDetail"):getvalue("BDX_CODGLO")) .AND. oModel:Getmodel("BDXDetail"):Length() == 1 )
			oModel:Getmodel("BDXDetail"):addLine()
		endif
		oModel:Getmodel("BDXDetail"):goline(oModel:Getmodel("BDXDetail"):Length())
		oModel:Getmodel("BDXDetail"):Loadvalue("BDX_FILIAL", xfilial("BDX"))
		oModel:Getmodel("BDXDetail"):Loadvalue("BDX_CODGLO", aGloman[2])
		omodel:Getmodel("BDXDetail"):Loadvalue("BDX_DESGLO", aGloMan[3])
		oModel:getmodel("BDXDetail"):Loadvalue("BDX_VLRGLO", agloman[1])
		oModel:GetModel("BDXDetail"):Loadvalue("BDX_TIPGLO", "2")
		oModel:GetModel("BDXDetail"):Loadvalue("BDX_ACAO  ", '1')
		oModel:GetModel("BDXDetail"):Loadvalue("BDX_CRIANA", '1')
		oModel:GetModel("BDXDetail"):Loadvalue("BDX_IMGSTA", "BR_VERMELHO")
		oModel:GetModel("BDXDetail"):Loadvalue("BDX_OBS   ", agloman[4])
		oModel:GetModel("BDXDetail"):Loadvalue("BDX_NIVEL ", '2')
		oModel:GetModel("BDXDetail"):Loadvalue("BDX_DESPRO", Substr(oModel:Getmodel("BD6Detail"):getValue("BD6_DESPRO"),1,40))

		xxx := aGloman[1]
		yyy := 0
		ttt := 0
		If oModel:Getmodel("BD6Detail"):Getvalue("BD6_PRTXPG") > 0
			ttt := oModel:getmodel("BD6Detail"):Getvalue("BD6_VLRPAG") - oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLTXPG")
			yyy := ttt * oModel:Getmodel("BD6Detail"):Getvalue("BD6_PRTXPG") / 100 * xxx / oModel:getmodel("BD6Detail"):Getvalue("BD6_VLRPAG")
			oModel:getmodel("BD6Detail"):setvalue("BD6_VLTXPG", oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLTXPG") - yyy )
		endIf
		oModel:Getmodel("BD6Detail"):setvalue("BD6_VLRPAG", oModel:Getmodel("BD6Detail"):getvalue("BD6_VLRPAG") - xxx /*- yyy*/)
		oModel:Getmodel("BD6Detail"):setvalue("BD6_VLRGLO",xxx + oModel:Getmodel("BD6Detail"):getvalue("BD6_VLRGLO") /*+ yyy*/)

		lCopPag := MsSeek(xfilial("BA0") + PLSINTPAD()) .AND. BA0->BA0_BASCOP == "1"

		if ! lCopPag .and. getNewPar("MV_PLSGCGP","0") == "1" .and. oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRPAG") == 0  
			PLSPOSGLO(PLSINTPAD(),__aCdCri226[1],__aCdCri226[2],"1")
			oModel:Getmodel("BD6Detail"):setvalue("BD6_BLOCPA", "1")
			oModel:Getmodel("BD6Detail"):setvalue("BD6_MOTBPF", __aCdCri226[1])
			oModel:Getmodel("BD6Detail"):setvalue("BD6_DESBPF", __aCdCri226[2])
		endIf

		//Cobra o que paga somente se for coparticipacao
		if  (oModel:Getmodel("BD6Detail"):Getvalue("BD6_TPPF") == '1' .and. lCopPag) .or. (oModel:Getmodel("BD6Detail"):Getvalue("BD6_TPPF") == '2' .and. lCopPag .and. getNewPar("MV_PLSGCGP","0") == "1" .and. oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRPAG") == 0) 
		//Para os casos aonde eu glosei integral o item  e parametro ativado não pago coparticipacao

			oModel:Getmodel("BD6Detail"):Loadvalue("BD6_VLRBPF",oModel:Getmodel("BD6Detail"):getvalue("BD6_VLRPAG"))

			if oModel:Getmodel("BD6Detail"):Getvalue("BD6_PERCOP") > 0//(BD6->BD6_PERCOP > 0) //oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRPAG")
				oModel:Getmodel("BD6Detail"):setvalue("BD6_VLRPF",( oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRBPF") * oModel:Getmodel("BD6Detail"):Getvalue("BD6_PERCOP") ) / 100)
			endIf

			oModel:Getmodel("BD6Detail"):setvalue("BD6_VLRTAD",  ( iIf(lModCTX, oModel:Getmodel("BD6Detail"):getvalue("BD6_VLRPF"), oModel:Getmodel("BD6Detail"):getvalue("BD6_VLRBPF")) * oModel:Getmodel("BD6Detail"):getvalue("BD6_PERTAD") ) / 100   )
			oModel:Getmodel("BD6Detail"):setvalue("BD6_VLRTPF",oModel:Getmodel("BD6Detail"):getvalue("BD6_VLRPF") + oModel:Getmodel("BD6Detail"):getvalue("BD6_VLRTAD"))

			//se tem limite de franquia 
			if oModel:Getmodel("BD6Detail"):Getvalue("BD6_F_VFRA") > 0 .AND. oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRTPF") > 0 .AND. oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRTPF") > oModel:Getmodel("BD6Detail"):Getvalue("BD6_F_VFRA")
				//guarda os valores originais
				nPerda := 100 - ( ( oModel:Getmodel("BD6Detail"):Getvalue("BD6_F_VFRA") / oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRTPF") ) * 100 )  
				if oModel:Getmodel("BD6Detail"):Getvalue("BD6_PERCOP") > 0 //BD6->BD6_PERCOP > 0
					oModel:Getmodel("BD6Detail"):setvalue("BD6_F_VLPF", oModel:Getmodel("BD6Detail"):getvalue("BD6_VLRTPF") / oModel:Getmodel("BD6Detail"):getvalue("BD6_PERCOP") * 100 )
				endIf

				oModel:Getmodel("BD6Detail"):setvalue("BD6_F_PPER",nPerda)
				oModel:Getmodel("BD6Detail"):setvalue("BD6_F_VLOR", oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRPF") )
				oModel:Getmodel("BD6Detail"):setvalue("BD6_F_TXOR", oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRTAD") )
				oModel:Getmodel("BD6Detail"):setvalue("BD6_F_TOOR", oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRTPF") )

				//aplica a perda da franquia nos valores de coparticipacao
				//BD6->BD6_VLRPF  -= ( BD6->BD6_VLRPF * nPerda ) / 100
				oModel:Getmodel("BD6Detail"):setvalue("BD6_VLRPF", oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRPF") - (oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRPF") * nPerda / 100) )

				//if BD6->BD6_VLRTAD > 0 .and. getNewPar("MV_PLSFCFR","1") == "1"
				if oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRTAD") > 0 .AND. getNewPar("MV_PLSFCFR","1") == "1"
					//BD6->BD6_VLRTAD -= ( BD6->BD6_VLRTAD * nPerda ) / 100
					oModel:Getmodel("BD6Detail"):setvalue("BD6_VLRTAD", oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRTAD") - (oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRTAD") * nPerda / 100) )
				endIf	
				
				//ajusta a diferenca de arredondamento 
				oModel:Getmodel("BD6Detail"):setvalue("BD6_VLRTAD", oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRTAD") + oModel:Getmodel("BD6Detail"):Getvalue("BD6_F_VFRA") - oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRPF") - oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRTAD")  )	
				oModel:Getmodel("BD6Detail"):setvalue("BD6_VLRTPF", oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRPF") + oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRTAD") )	
			else

				oModel:Getmodel("BD6Detail"):setvalue("BD6_F_VLPF",0)
				oModel:Getmodel("BD6Detail"):setvalue("BD6_F_PPER",0)
				oModel:Getmodel("BD6Detail"):setvalue("BD6_F_VLOR",0)
				oModel:Getmodel("BD6Detail"):setvalue("BD6_F_TXOR",0)
				oModel:Getmodel("BD6Detail"):setvalue("BD6_F_TOOR",0)
			endIf
		endIf
		oModel:GetModel('BDXDetail'):SetNoInsertLine(.T.)
	endIf
	Liquid(@oModel)

	If !lReplica .AND. oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRPAG") == 0 ;
		.AND. ( !(empty(aFilTGlo[1])) .OR. !(empty(aFilTGlo[2])) .OR. !(empty(aFilTGlo[3])) )

		If !lauto .AND. MsgYesNo(STR0049) //"Deseja replicar a glosa integral para todos os itens atualmente filtrados?"
			nLinhaAtu := oModel:Getmodel("BD6Detail"):getLine()
			For nFor := 1 To oModel:Getmodel("BD6Detail"):length()
				oModel:Getmodel("BD6Detail"):GoLine(nFor)
				If oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRPAG") > 0 .AND. nLinhaAtu <> oModel:Getmodel("BD6Detail"):getLine();
					.AND.    IIF(!(empty(aFilTGlo[1])), oModel:Getmodel("BD6Detail"):Getvalue("BD6_SEQUEN") $ aFilTGlo[1], .T. );
					.AND.    IIF(!(empty(aFilTGlo[2])), oModel:Getmodel("BD6Detail"):Getvalue("BD6_SEQUEN") $ aFilTGlo[2], .T. );
					.AND.    IIF(!(empty(aFilTGlo[3])), oModel:Getmodel("BD6Detail"):Getvalue("BD6_SEQUEN") $ aFilTGlo[3], .T. )
					aGloRep := aclone(aGloman)
					aGloRep[1] := oModel:Getmodel("BD6Detail"):Getvalue("BD6_VLRPAG")
					zYuni(@oModel, @oView, .F., .T., aGloRep)
				endIf
			next
			oModel:Getmodel("BD6Detail"):GoLine(nLinhaAtu)
		endIF
	endIf

	If !lauto
		oView:Refresh()
	endIF
return


//-------------------------------------------------------------------
/*/ {Protheus.doc} Liquid
Separa os valores novos do evento (BD6) na composição (BD7)
@since ??/2020
@version P12. 
/*/
//-------------------------------------------------------------------
static function Liquid(oModel)
Local nI 		:= 0
LOCAL aTotBD7 	:= {0, 0, 0, 0} //Pag, glo, Tx, PF
Local aPercen 	:= {0,0}
LOCAL nVLRPAG 	:= oModel:getmodel("BD6Detail"):getvalue("BD6_VLRPAG")
Local nVLrGLO 	:= oModel:getmodel("BD6Detail"):getvalue("BD6_VLRGLO")
Local nVLRPF  	:= oModel:getmodel("BD6Detail"):getvalue("BD6_VLRTPF")
Local nVLRTX  	:= oModel:getmodel("BD6Detail"):getvalue("BD6_VLTXPG")
Local nPercen 	:= 0
Local nDif	  	:= 0

for nI := 1 to oModel:Getmodel("BD7Detail"):Length()
	omodel:getmodel("BD7Detail"):GoLine(nI)
	nPercen := oModel:getmodel("BD7Detail"):getvalue("BD7_PERCEN") / 100
	
	If nPercen > aPercen[1]
		aPercen[1] := nPercen
		aPercen[2] := nI
	endIf

	aTotBD7[1] += (nPercen * nVLRPAG)
	oModel:getmodel("BD7Detail"):setvalue("BD7_VLRPAG", nPercen * nVLRPAG)
	aTotBD7[2] += (nPercen * nVLrGLO)
	oModel:getmodel("BD7Detail"):setvalue("BD7_VLRGLO", nPercen * nVLrGLO)
	aTotBD7[3] += (nPercen * nVLRTX)
	oModel:getmodel("BD7Detail"):setvalue("BD7_VLTXPG", nPercen * nVLRTX)
	aTotBD7[4] += (nPercen * nVLRPF)
	oModel:getmodel("BD7Detail"):setvalue("BD7_VLRTPF", nPercen * nVLRPF)
next

If aTotBD7[1] <> nVLRPAG
	nDif := nVLRPAG - aTotBD7[1]
	omodel:getmodel("BD7Detail"):GoLine(aPercen[2])
	oModel:getmodel("BD7Detail"):setvalue("BD7_VLRPAG", oModel:getmodel('BD7Detail'):getValue("BD7_VLRPAG") + nDif )
endIf

IF aTotBD7[2] <> nVLrGLO
	nDif := nVLrGLO - aTotBD7[2]
	omodel:getmodel("BD7Detail"):GoLine(aPercen[2])
	oModel:getmodel("BD7Detail"):setvalue("BD7_VLRGLO", oModel:getmodel('BD7Detail'):getValue("BD7_VLRGLO") + nDif )
ENDIF

If aTotBD7[3] <> nVLRTX
	ndif := nVLRTX - aTotBD7[3]
	omodel:getmodel("BD7Detail"):GoLine(aPercen[2])
	oModel:getmodel("BD7Detail"):setvalue("BD7_VLTXPG", oModel:getmodel('BD7Detail'):getValue("BD7_VLTXPG") + nDif )
endIf

If aTotBD7[4] <> nVLRPF
	nDif := nVLRPF - aTotBD7[4]
	omodel:getmodel("BD7Detail"):GoLine(aPercen[2])
	oModel:getmodel("BD7Detail"):setvalue("BD7_VLRTPF", oModel:getmodel('BD7Detail'):getValue("BD7_VLRTPF") + nDif )
endIf

return


//-------------------------------------------------------------------
/*/ {Protheus.doc} AtuCab
Atualiza o cabeçalho depois de gravar o model
@since ??/2020
@version P12. 
/*/
//-------------------------------------------------------------------
static function AtuCab(oModel)
Local oBD6		:= oModel:GetModel("BD6Detail")
Local oBDX		:= oModel:GetModel("BDXDetail")
Local cchavegui := oBD6:GetValue("BD6_CODOPE",1) + oBD6:GetValue("BD6_CODLDP",1) + oBD6:GetValue("BD6_CODPEG",1);
					+oBD6:GetValue("BD6_NUMERO",1)+oBD6:GetValue("BD6_ORIMOV",1)
local cTipoguia := oBD6:GetValue("BD6_TIPGUI",1)
local nBD6		:= 0
local nBDX		:= 0

FWFormCommit( oModel )
PLCABGTOT(cChaveGui,cTipoGuia)
PLPEGTOT()

//Métrica do PLS - Quantidade de ações por tipo de glosa
if lHabMetric .and. lLibSupFw .and. lVrsAppSw 
	for nBD6:=1 to oBD6:Length()
		oBD6:GoLine( nBD6 ) 
		oBDX := oModel:GetModel("BDXDetail")
		for nBDX:=1 to oBDX:Length()
			oBDX:GoLine( nBDX ) 
			plsTelRecGlo(oBDX:GetValue("BDX_TIPGLO"),oBDX:GetValue("BDX_ACAO"))
		next
	next
endif

return .t.

//-------------------------------------------------------------------
/*/ {Protheus.doc} Diamond
Função principal do histórico de tratamento.
@since ??/2020
@version P12. 
/*/
//-------------------------------------------------------------------
static function Diamond(oModel, lAuto)
Local csql 		:= ""
Local cSql2 	:= ""
Local cSqlBE4 	:= ""
Local cSqlBD5 	:= ""
Local cGuiInt 	:= ""
Local cTipGui 	:= oModel:getModel("BD6Detail"):getValue("BD6_TIPGUI")
Local cGuipri 	:= ""
LOCAL lTemBE4 	:= .F.
Local lTemBD5 	:= .F.
Local cSqlSql 	:= ""
Local oBrowse 	:= nil
//LOCAL cPEgPosi := "" //Descomentar se for tirar a guia atual da query
//Local cNumPosi := ""
Local afields 	:= {}
LOCAL csqlIns 	:= ""
LOCAL acmpbrw 	:= {} 
Local aCoors 	:= FWGetDialogSize( oMainWnd )
Local oBrowseB 	:= nil
local aSeekPesq := {}
local aRotBkp	:= aRotina

Private cCodopez := oModel:getModel("BD6Detail"):getValue("BD6_CODOPE")
default lAuto 	 := .F.

//Local 
cPegAtu := oModel:getModel("BD6Detail"):getValue("BD6_CODPEG")
cguiatu := oModel:getModel("BD6Detail"):getValue("BD6_NUMERO")
If cTipGui == "05"
	cGuiint := oModel:getModel("MasterCab"):Getvalue("BE4_GUIINT")
//	cPEgPosi := oModel:getModel("MasterCab"):Getvalue("BE4_CODPEG")
//	cNumPosi := oModel:getModel("MasterCab"):Getvalue("BE4_NUMERO")
else
	cGuiint := oModel:getModel("MasterCab"):getvalue("BD5_GUIINT")
	cGuipri := oModel:getModel("MasterCab"):getvalue("BD5_GUIPRI") //Verificar o NRLBOR se pá
//	cPEgPosi := oModel:getModel("MasterCab"):Getvalue("BD5_CODPEG")
//	cNumPosi := oModel:getModel("MasterCab"):Getvalue("BD5_NUMERO")
endIf

aadd(afields,{"TIPGUI","C",2 ,0})
aadd(afields,{"BD6_CODPAD","C",tamSX3("BD6_CODPAD")[1] ,0})
aadd(afields,{"BD6_CODPRO", "C", tamSX3("BD6_CODPRO")[1], 0})
aadd(afields,{"BD6_DESPRO","C", tamSX3("BD6_DESPRO")[1], 0})
aadd(afields,{"BD6_DATPRO", "D", 8, 0})
aadd(afields,{"BD6_QTDPRO","N",16,0})
aadd(afields,{"BD6_CODRDA","C", tamSX3("BD6_CODRDA")[1], 0})
aadd(afields,{"BD6_NOMRDA","C", tamSX3("BD6_NOMRDA")[1], 0})
aadd(afields,{"BD6_VLRPAG", "N",16,2})
aadd(afields,{"BD6_VLRGLO", "N",16,2})
aadd(afields,{"BD6_CODPEG","C", tamSX3("BD6_CODPEG")[1], 0})
aadd(afields,{"BD6_NUMERO","C", tamSX3("BD6_NUMERO")[1], 0})
aadd(afields,{"BD6_FASE","C", tamSX3("BD6_FASE")[1], 0})

Private oTempTable := FWTemporaryTable():New( "DELTA", aFields )
oTempTable:AddIndex("indice1", {"BD6_CODPAD", "BD6_CODPRO", "BD6_CODRDA"} )
oTempTable:Create()

csqlIns += " Insert Into " + oTempTable:getrealName() + "( TIPGUI, BD6_CODPAD, BD6_CODPRO, BD6_QTDPRO, BD6_DATPRO, BD6_CODRDA, BD6_VLRPAG, BD6_VLRGLO, BD6_CODPEG, BD6_NUMERO, BD6_FASE, BD6_NOMRDA, BD6_DESPRO ) "//"(BDX_CODGLO, BDX_ACAO, SUMGLO, QTDGLO) " //( "
cSql += " SELECT GUIINT.TIPGUI, BD6.BD6_CODPAD, BD6.BD6_CODPRO, BD6.BD6_QTDPRO, BD6.BD6_DATPRO, BD6.BD6_CODRDA, BD6.BD6_VLRPAG, BD6.BD6_VLRGLO, BD6.BD6_CODPEG, BD6.BD6_NUMERO, BD6.BD6_FASE, BD6.BD6_NOMRDA, BD6.BD6_DESPRO FROM " + RetSqlName("BD6") + " BD6 "
cSql += " INNER JOIN ( "
If !(empty(cguiint))
	cSqlBE4 += " SELECT BE4_TIPGUI TIPGUI, BE4_CODOPE CODOPE, BE4_CODLDP CODLDP, BE4_CODPEG CODPEG, BE4_NUMERO NUMERO, BE4_SITUAC SITUAC, BE4_FASE FASE "
	cSqlBE4 += " FROM " + RetSqlName("BE4") + " BE4 "
	cSqlBE4 += " WHERE BE4_FILIAL = '" + xFilial("BE4") + "' "
	cSqlBE4 += " AND BE4_GUIINT = '" + cguiint + "' "
	cSqlBE4 += " AND BE4_SITUAC <> '2' "
	cSqlBE4 += " AND D_E_L_E_T_ = ' ' "
//	cSqlBE4 += " AND BE4_CODPEG <> '" + cPEgPosi + "' "
//	cSqlBE4 += " AND BE4_NUMERO <> '" + cNumPosi + "' "
	lTemBE4 := .T.
endIf

//" UNION ALL "

If !(empty(cguiint)) .OR. !(EmpTy(cGuipri))
	cSqlBD5 += " SELECT BD5_TIPGUI TIPGUI, BD5_CODOPE CODOPE, BD5_CODLDP CODLDP, BD5_CODPEG CODPEG, BD5_NUMERO NUMERO, BD5_SITUAC SITUAC, BD5_FASE FASE "
	cSqlBD5 += " FROM " + RetSqlName("BD5") + " BD5 " 
	cSqlBD5 += " WHERE BD5_FILIAL = '" + xFilial("BD5") + "' "
	If !(empty(cguiint))
		csqlBD5 += " AND BD5_GUIINT = '" + cguiint + "' "
	elseif !(EmpTy(cGuipri))
		csqlBD5 += " AND BD5_GUIPRI = '" + cGuipri + "' "
	endIf
	cSqlBD5 += " AND BD5_SITUAC <> '2' "
	csqlBD5 += " AND D_E_L_E_T_ = ' '  "
//	cSqlBE4 += " AND BD5_CODPEG <> '" + cPEgPosi + "' "
//	cSqlBE4 += " AND BD5_NUMERO <> '" + cNumPosi + "' "
	lTemBD5 := .T.
endIF
cSql2 += " ) GUIINT "
cSql2 += " ON BD6_FILIAL = '" + xfilial("BD6") +  "' "
cSql2 += " AND BD6_CODOPE = GUIINT.CODOPE "
cSql2 += " AND BD6_CODLDP = GUIINT.CODLDP "
cSql2 += " AND BD6_CODPEG = GUIINT.CODPEG "
cSql2 += " AND BD6_NUMERO = GUIINT.NUMERO "
cSql2 += " AND BD6_SITUAC = GUIINT.SITUAC "
csql2 += " AND BD6_FASE = GUIINT.FASE "
cSql2 += " WHERE BD6.D_E_L_E_T_ = ' ' "

If lTemBD5 .OR. lTemBE4
	
	aadd(acmpbrw,{"BD6_CODPAD","C",tamSX3("BD6_CODPAD")[1] ,0})
	aadd(acmpbrw,{"BD6_CODPRO", "C", tamSX3("BD6_CODPRO")[1], 0})
	aadd(acmpbrw,{"QTDPRO","N",16,0})
	aadd(acmpbrw,{"BD6_DESPRO","C", tamSX3("BD6_DESPRO")[1], 0})
	aadd(acmpbrw,{"BD6_VLRPAG", "N",16,2})
	aadd(acmpbrw,{"BD6_VLRGLO", "N",16,2})

	Private oBrw1Table := FWTemporaryTable():New( "TRATZ", acmpbrw )
	oBrw1Table:AddIndex("indice1", {"BD6_CODPAD", "BD6_CODPRO"} )
	oBrw1Table:Create()

	cSqlSql := cSqlins + cSql + IIF(lTemBE4, cSqlBE4, ' ') + IIF(lTemBD5 .AND. lTemBE4, " UNION ALL ", " ") + IIF(lTemBD5, cSqlBD5, ' ') + cSql2 //+ " ) "
	
	nErr := tcsqlExec(cSqlSql)
	If __lOracle
		TCSQLExec("COMMIT")
	endIf
	DELTA->(DbSelectArea("DELTA"))
	DELTA->(dbgotop())
	
	csqlIns := " Insert Into " + oBrw1Table:getrealName() + "( BD6_CODPAD, BD6_CODPRO, BD6_DESPRO, QTDPRO, BD6_VLRPAG, BD6_VLRGLO ) "
	cSqlSql := " Select BD6_CODPAD, BD6_CODPRO, BD6_DESPRO, SUM(BD6_QTDPRO) QTDPRO, Round(SUM(BD6_VLRPAG), 2) VLRPAG, Round(SUM(BD6_VLRGLO), 2) VLRGLO from " + oTempTable:getrealName()
	cSqlSql += " GRoup By BD6_CODPAD, BD6_CODPRO, BD6_DESPRO "
	
	nErr := tcsqlExec(csqlIns + cSqlSql)
	If __lOracle
		TCSQLExec("COMMIT")
	endIf
	TRATZ->(DbSelectArea("TRATZ"))
	TRATZ->(dbgotop())

	If  TRATZ->(eOf())
		MsgAlert(STR0050) //"Não há histórico de faturamentos desse tratamento"
	else
		TRATZ->(dbgoTop())		

		If !lAuto
			DEFINE MsDialog oDialog Title STR0051 From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel //'Histórico Tratamento'
		
			aRotina := {} //Se clicar em Alterar a guia e depois acessa aqui, dá problema nos menus
			// Cria o conteiner onde serão colocados os browses
			oFWLayer := FWLayer():New()
			oFWLayer:Init( oDialog, .F., .T. )

			// Define Painel Superior
			oFWLayer:AddLine( 'UP', 50, .F. )
			oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
			oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )
			
			// Painel Inferior
			oFWLayer:AddLine( 'DOWN', 50, .F. )
			oFWLayer:AddCollumn( 'TUDO' , 100, .T., 'DOWN' )
			oPanelDown := oFWLayer:GetColPanel( 'TUDO', 'DOWN' ) 
		endIf

		aOrdCmp := {}
		//aadd(aOrdCmp,{"Prestador","BD6_CODRDA"})
		aadd(aOrdCmp,{STR0053, "BD6_CODPAD"}) //"Tabela"
		aadd(aOrdCmp,{STR0013, "BD6_CODPRO"}) //"Evento"
		aadd(aOrdCmp,{STR0014, "BD6_DESPRO"}) //"Descrição"
		//	aadd(aOrdCmp,{"Data do evento" ,"BD6_DATPRO"})
		aadd(aOrdCmp,{STR0054, "QTDPRO"}) //"Quantidade"
		aadd(aOrdCmp,{STR0055, "BD6_VLRPAG"}) //"Valor Pago"
		aadd(aOrdCmp,{STR0056, "BD6_VLRGLO"}) //"Valor Glosado"

		Aadd(aSeekPesq,{STR0078, 	{{"","C",30,0, 	"CodPro" ,"@!"}}, 1, .T. } ) //"Cód. Tabela + Cód. Procedimento"

		If !lAuto
			oBrowse := PlObjFwBrow(oBrowse, 'TRATZ', '', oPanelUp, STR0052, '', .t., .f., .f., .f., .f., .f., aOrdCmp)
			oBrowse:disableReport()
			oBrowse:DisableDetails()
			oBrowse:SetSeek(.t., aSeekPesq)
			oBrowse:Activate()
		endIf
		Private cFilPEG := cpegAtu //O filtro não enxerga variável static
		Private cFilgui := cGuiAtu

		//dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSqlSql),"TRZD",.f.,.t.)
		If !lAuto
		endIf
		aOrdCmp := {}
		aSeekPesq := {}
		aadd(aOrdCmp,{STR0058, "BD6_CODRDA"}) //"Prestador"
		aadd(aOrdCmp,{STR0059, "BD6_NOMRDA"}) //"Nome"
		aadd(aOrdCmp,{STR0060, "BD6_DATPRO"}) //"Data do evento"
		aadd(aOrdCmp,{STR0054, "BD6_QTDPRO"}) //"Quantidade"
		aadd(aOrdCmp,{STR0055, "BD6_VLRPAG"}) //"Valor Pago"
		aadd(aOrdCmp,{STR0056, "BD6_VLRGLO"}) //"Valor Glosado"
		aadd(aOrdCmp,{STR0061, "BD6_CODPEG"}) //"Protocolo"
		aadd(aOrdCmp,{STR0008, "BD6_NUMERO"}) //Guia
		aadd(aOrdCmp,{STR0062, "IIF(BD6_FASE == '4', 'Sim', 'Não')"}) //"Faturado?"
		aadd(aOrdCmp,{STR0063, "Posicione('BCL',1,xFilial('BCL') + cCodopez + TIPGUI,'BCL_DESCRI')"}) //"Tipo de Guia"
		//aadd(aOrdCmp,{"Fase"     , "BD6_FASE"})
		Aadd(aSeekPesq,{STR0078 + "+Cód. RDA", 	{{"","C",30,0, 	"CodPro2" ,"@!"}}, 1, .T. } ) //"Cód. Tabela + Cód. Procedimento"
		if !lAuto
			oBrowseB := PlObjFwBrow(oBrowseB, 'DELTA', '', oPanelDown, STR0057, '', .t., .f., .f., .f., .f., .f., aOrdCmp) ////'Detalhamento do evento em outras guias'
			oBrowseB:disableReport()
			oBrowseB:DisableDetails()
			oBrowseB:SetSeek(.t., aSeekPesq)
			//oBrowseB:SetFilterDefault(" BD6_CODPAD == TRATZ->BD6_CODPAD .AND. BD6_CODPRO == TRATZ->BD6_CODPRO ")
			oBrowseB:AddLegend( " BD6_CODPEG == cFilPEG .AND. BD6_NUMERO == cFilgui "	, "GREEN"	, "Evento na guia atual")
			oBrowseB:AddLegend( " BD6_CODPEG == cFilPEG .AND. BD6_NUMERO <> cFilgui "	, "BLUE"	, "Evento no Protcolo Atual")
			oBrowseB:AddLegend( " BD6_CODPEG <> cFilPEG "	, "GRAY"	, "Evento em outro Protocolo")
			//oBrowseB:AddLegend( " BD6_CODPEG <> cFilPEG .AND. BD6_FASE <> '4' "	, "GRAY"	, "Evento em outro Protocolo - Não faturado")
			//oBrowseB:AddLegend( " BD6_CODPEG <> cFilPEG .AND. BD6_FASE == '4' "	, "RED"	, "Evento em outro Protocolo - Faturado")
			oBrowseB:Activate()

			oRelac:= FWBrwRelation():New()
			oRelac:AddRelation( oBrowse , oBrowseB , { 	{ 'BD6_CODPAD', 'BD6_CODPAD' },;
														{ 'BD6_CODPRO', 'BD6_CODPRO' }	} )
			oRelac:Activate()

			Activate MsDialog oDialog Center
		endIf
	endIf
	TRATZ->(dbcloseArea())
	DELTA->(dbCloseArea())
	oTempTable:Delete()
	oBrw1Table:Delete()
else
	DELTA->(dbCloseArea())
	oTempTable:Delete()
	MsgAlert(STR0050) //"Não há histórico de faturamentos desse tratamento"
endIF
aRotina := aRotBkp
return 


//-------------------------------------------------------------------
/*/ {Protheus.doc} menudef
menudef, deixar aqui pra quando for inserir botões na tela de hisótico de tratamento, ou outra que surgir
@since ??/2020
@version P12. 
/*/
//-------------------------------------------------------------------
static function menudef()
Local aRotina := {}
//Add Option aRotina Title 'Filtrar'  Action 'MsgAlert("Aqui filtra")' Operation 3 Access 0
return arotina


//-------------------------------------------------------------------
/*/ {Protheus.doc} TratFil
Filtro
@since ??/2020
@version P12. 
/*/
//-------------------------------------------------------------------
static function TratFil()
Local aPergs := {}

aAdd( aPergs,{ 1, STR0069, 	afiltro1[1]	, "@", "", ""		, "", 50, .f.}) //"Tabela de: " 
aAdd( aPergs,{ 1, STR0070, 	afiltro1[2]	, "@", "", ""		, "", 50, .f.}) //"Tabela Ate: "
aAdd( aPergs,{ 1, STR0071, 	afiltro1[1]	, "@", "", ""		, "", 50, .f.}) //"Evento de: " 
aAdd( aPergs,{ 1, STR0072, 	afiltro1[2]	, "@", "", ""		, "", 50, .f.}) //"Evento Ate: "
paramBox( aPergs,STR0073,afilTrat,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,/*lCanSave*/,/*lUserSave*/ ) //"Filtro de Tela"

return


//-------------------------------------------------------------------
/*/ {Protheus.doc} AtuValZ
Atualiza Valores
@since ??/2020
@version P12. 
/*/
//-------------------------------------------------------------------
static function AtuValZ(nTipo,__nQuant,nQtdProX,nVlrUnit,nVlrOriginal,nVlrAprOri,__nValor,nVlrJaGlosado,nVlrMan,nVlrUniX,l1,l2,nVlrSaldo)
Local nvlrglo 	:= 0
Local lRet 		:= .T.

nSaldoStt := nVlrSaldo

If nTipo == 1
	nvlrglo := __nQuant * nVlrUnit
	lRet := nvlrglo <= nSaldoStt
	__nValor := nvlrglo
	nVlrSaldo := nSaldoStt - nvlrglo 
	If __nQuant > 0
		l2 := .F.
	else
		l2 := .T.
	endIf
elseIf nTipo == 2
	nVlrSaldo := nVlrUniX - __nValor - nVlrJaGlosado
	If __nValor > 0
		l1 := .F.
	else
		l1 := .T.
	endIf
endIf

return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} midPLSA600
Função média para forçar o carregamento dos dados do número da
guia e beneficiário da guia selecionada

@author    Eduardo Bento
@version   V12
@since     29/01/2021
/*/
Function midPLSA600()
//A chamada da view pelo botão não carrega novamente a tela, por isso o uso dessa estrutura
FwExecView(STR0074, "PLSA600",4) //"ANALISAR"

Return


//-------------------------------------------------------------------
/*/ {Protheus.doc} Pl600DetBDX
Função que monta e exibe a dialog modal com o complemento das críticas do grid BDX
@since 07/2021
@version P12 
/*/
//-------------------------------------------------------------------
function Pl600DetBDX(oModel, oView, lAuto)
local aAreaBDX		:= BDX->(getarea())
local aTamJan		:= FwGetDialogSize()
local aDados		:= {}
local cFil 			:= ""
local cTxtObs		:= ""
local oMdlBDX		:= oModel:getModel("BDXDetail")
local lInsertNow	:= oMdlBDX:isInserted()
local oPrinWnd		:= nil
local oFwCamada		:= nil
local oLINSUP		:= nil
local oGridCBDX		:= nil
local oLININFR		:= nil
local oGetMemo		:= nil
default lAuto		:= .f.

if !empty(oMdlBDX:getValue("BDX_CODGLO"))
	if lInsertNow 
		Help(nil, nil , STR0064, nil, oMdlBDX:getValue("BDX_OBS"), 1, 0, nil, nil, nil, nil, nil, {} ) //"Observação da Glosa"
	else
		cFil := "@(BDX_FILIAL = '" + xfilial("BDX") + "' AND BDX_CODOPE = '" + oMdlBDX:getValue("BDX_CODOPE") + "' AND "
		cFil += "    BDX_CODLDP = '" + oMdlBDX:getValue("BDX_CODLDP") + "' AND  BDX_CODPEG = '" + oMdlBDX:getValue("BDX_CODPEG") + "' AND "
		cFil += "    BDX_NUMERO = '" + oMdlBDX:getValue("BDX_NUMERO") + "' AND  BDX_ORIMOV = '" + oMdlBDX:getValue("BDX_ORIMOV") + "' AND "
		cFil += "    BDX_CODPAD = '" + oMdlBDX:getValue("BDX_CODPAD") + "' AND  BDX_CODPRO = '" + oMdlBDX:getValue("BDX_CODPRO") + "' AND "
		cFil += "    BDX_SEQUEN = '" + oMdlBDX:getValue("BDX_SEQUEN") + "' AND  BDX_CODGLO = '" + oMdlBDX:getValue("BDX_CODGLO") + "')"

		//Montagem da Modal Dialog
		oPrinWnd := PlObjFwDial(oPrinWnd, .t., {aTamJan[4] * 0.3, aTamJan[3] * 0.3 }, STR0065, .f., .t.)	

		oFwCamada := FwLayer():New()
		oFwCamada:init(oPrinWnd:getPanelMain(), .F.) 
		oFwCamada:AddLine("LINSUP", 80, .f.)
		oFwCamada:AddLine("LININF", 20, .f.)

		oLINSUP  := oFwCamada:GetLinePanel("LINSUP")
		oLININFR := oFwCamada:GetLinePanel("LININF")
		oGetMemo := tMultiget():new(001,001,{ |txt| iif( pCount() > 0, cTxtObs := txt, cTxtObs )},oLININFR,aTamJan[4] * 0.298, aTamJan[3] * 0.057,,,,,,.T.,nil,nil,{||},nil,nil,.T.,{||},nil,nil,.t.,.t.)
	
		aadd(aDados, {STR0067,	{ || BDX->BDX_CODGLO } }) //"Código Glosa"
		aadd(aDados, {STR0014,	{ || BDX->BDX_DESGLO } }) //"Descrição"
		aadd(aDados, {STR0068,	{ || BDX->BDX_INFGLO } }) //"Inf. Adicionais"

		oGridCBDX := PlObjFwBrow(oGridCBDX, "BDX", cFil, oLINSUP, STR0066 + oMdlBDX:getValue("BDX_CODGLO"), '', .t., .f., .f., .f., .f., .f., aDados)
		oGridCBDX:setProfileID('0')
		oGridCBDX:disableDetails()  
		oGridCBDX:disableReport()
		oGridCBDX:SetChange( {|| PlRetObsBDX(@cTxtObs, oGetMemo, oGridCBDX, lAuto)} )
		oGridCBDX:SetOnlyFields( {'BDX_CODGLO', 'BDX_DESGLO', 'BDX_INFGLO'})  //Para exibir apenas essas colunas, não as demais da tabela

		PlRetObsBDX(@cTxtObs, oGetMemo, oGridCBDX, lAuto)

		if !lAuto
			oGridCBDX:activate()
			oPrinWnd:activate() 
		endif
	endif
endif
RestArea(aAreaBDX)
return


//-------------------------------------------------------------------
/*/ {Protheus.doc} PlRetObsBDX
Atualiza campo da observação da glosa - Principlamente quando for glosa manual.
@since 07/2021
@version P12 
/*/
//-------------------------------------------------------------------
static function PlRetObsBDX(cTxtObs, oObj, oGet, lAuto)
if oGet:Logiclen() > 0
	cTxtObs := upper( BDX->BDX_OBS )
	iif( !lAuto, oObj:Refresh(), "")
endIf
return


/*//-------------------------------------------------------------------
{Protheus.doc} PnlTotal
Montagem do TPanel e do Tsay, para exibição dos valores obtidos via classe calc 
@since    06/2020
//-------------------------------------------------------------------*/
static function PnlTotal(oPanel, oModel, oView, lCriacao )
local aObjetos		:= {}
local aTopTit		:= {002/*caption*/, 009 /*valores*/}
local cCorTit		:= CLR_BLUE
local cCorVal		:= CLR_RED
local cPictMk		:= "@E 9,999,999,999,999.99"
local nFor			:= 0
local nLargtxt		:= 064
local nAltutxt		:= 010
local oFont 		:= TFont():New('Arial',,-12,,.T.)
local oFont2 		:= TFont():New('Arial',,-13,,.T.)
local oObjCalc		:= oModel:GetModel('CALC')
default lCriacao	:= .f.
default oView		:= iif(!lCriacao, FwViewActive(), oView)

if lCriacao

	oSayCmp	:= TSay():New(aTopTit[1],005,{|| STR0002 },oPanel,,oFont,,,,.t.,cCorTit,,nLargtxt,nAltutxt) //"Valor Apresentado"
	oSayAPR	:= TSay():New(aTopTit[2],005,{|| cTxtAPR := PFormtVal(oObjCalc:getValue("VLRAPRTOT"), cPictMk) },oPanel,,oFont2,,,,.t.,cCorVal,,nLargtxt,nAltutxt,,,,,,.f.,0,2)
	
	oSayCmp	:= TSay():New(aTopTit[1],080,{|| STR0003 },oPanel,,oFont,,,,.t.,cCorTit,,nLargtxt,nAltutxt) // "Valor Contratado"
	oSayBPR	:= TSay():New(aTopTit[2],080,{|| cTxtBPR := PFormtVal(oObjCalc:getValue("VLRBPRTOT"), cPictMk) },oPanel,,oFont2,,,,.t.,cCorVal,,nLargtxt,nAltutxt,,,,,,.f.,0,2)
	
	oSayCmp	:= TSay():New(aTopTit[1],160,{|| STR0004 },oPanel,,oFont,,,,.t.,cCorTit,,nLargtxt,nAltutxt) //"Valor Glosa"
	oSayGLO	:= TSay():New(aTopTit[2],160,{|| cTxtGLO := PFormtVal(oObjCalc:getValue("VLRGLOTOT"), cPictMk) },oPanel,,oFont2,,,,.t.,cCorVal,,nLargtxt,nAltutxt,,,,,,.f.,0,2)
	
	oSayCmp	:= TSay():New(aTopTit[1],240,{|| STR0005 },oPanel,,oFont,,,,.t.,cCorTit,,nLargtxt,nAltutxt) //"Valor Pagamento"
	oSayPAG	:= TSay():New(aTopTit[2],240,{|| cTxtPAG := PFormtVal(oObjCalc:getValue("VLRPAGTOT"), cPictMk) },oPanel,,oFont2,,,,.t.,cCorVal,,nLargtxt,nAltutxt,,,,,,/*20*/,0,2)
	
	oSayCmp	:= TSay():New(aTopTit[1],320,{|| STR0006 },oPanel,,oFont,,,,.t.,cCorTit,,nLargtxt,nAltutxt) //"Coparticipação"
	oSayPFT	:= TSay():New(aTopTit[2],320,{|| cTxtPFT := PFormtVal(oObjCalc:getValue("VLRTPFTOT"), cPictMk) },oPanel,,oFont2,,,,.t.,cCorVal,,nLargtxt,nAltutxt,,,,,,/*20*/,0,2)
endif

cTxtAPR := PFormtVal(oObjCalc:getValue("VLRAPRTOT"), cPictMk)
cTxtBPR := PFormtVal(oObjCalc:getValue("VLRBPRTOT"), cPictMk) 
cTxtGLO := PFormtVal(oObjCalc:getValue("VLRGLOTOT"), cPictMk)
cTxtPAG := PFormtVal(oObjCalc:getValue("VLRPAGTOT"), cPictMk)
cTxtPFT := PFormtVal(oObjCalc:getValue("VLRTPFTOT"), cPictMk)	

aObjetos := {oSayCmp, oSayAPR, oSayBPR, oSayGLO, oSayPAG, oSayPFT}
for nFor := 1 to len(aObjetos)
	aObjetos[nfor]:Refresh()
next

return .t.


//-------------------------------------------------------------------
/*/ {Protheus.doc} PFormtVal
Função que formata o valor de acordo com a pciture desejada
@since 07/2021
@version P12 
/*/
//-------------------------------------------------------------------
static function PFormtVal(nValor, cPicture)
local cValTrat	:= ""
cValTrat := alltrim(TransForm(nValor, cPicture))
return cValTrat 


//-------------------------------------------------------------------
/*/ {Protheus.doc} PLoteLb600
Função que faz a liberação do lote de pagamento em lote, de acordo com os itens marcados no browse
@since 07/2021
@version P12. 
/*/
//-------------------------------------------------------------------
function PLoteLb600()
local aAreaAll	:= GetArea()
local aAreaBCI	:= BCI->(GetArea()) 
local aDadRet	:= {}
local cAlisMarc	:= staticcall(PLSA498, getChecked)

ProcRegua(-1)
if (cAlisMarc)->(eof())
	PLRTGUPEG(.t., .t.)
else
	while !(cAlisMarc)->(eof())
		BCI->(dbgoto((cAlisMarc)->RECNO))
			aadd( aDadRet, PLRTGUPEG(.t., .f.) )
		(cAlisMarc)->(dbskip())
	enddo
	PlDialResul(aDadRet, .f.)
endif
(cAlisMarc)->(dbclosearea())
RestArea(aAreaAll)
RestArea(aAreaBCI)
return


//-------------------------------------------------------------------
/*/ {Protheus.doc} PlDialResul
Exibe a Modal com o resultado da Liberação dos lotes marcados
@since 07/2021
@version P12. 
/*/
//-------------------------------------------------------------------
static function PlDialResul(aDados, lAuto)
local aTamJan		:= FwGetDialogSize()
local oDialMod		:= nil
local oFwCamada		:= nil
local oLINSUP		:= nil
local oGridRes		:= nil
default lAuto		:= .f.

oDialMod := PlObjFwDial(oDialMod, .f., {aTamJan[4] * 0.35, aTamJan[3] * 0.35}, "Resultado do processamento de lotes", .f., .f.)	

oFwCamada	:= FwLayer():New()
oFwCamada:init(oDialMod:getPanelMain(), .f.) 
oFwCamada:AddLine("LINSUP", 100, .f.)
oLINSUP  	:= oFwCamada:GetLinePanel("LINSUP")

oGridRes := PlObjFwBrow(oGridRes, '', '', oLINSUP, 'teste', '', .f., .f., .f. )
oGridRes:setDataArray()
oGridRes:setArray(aDados)
oGridRes:addColumn({STR0077, {|| iif( aDados[oGridRes:nAt,1], "Sim", "Não" ) }, "C", "@!", 1, 10, 0 , .f. , , .F., , "CARQ", , .F., .T., , "CARQ" }) //"Lote Gerado?"
oGridRes:addColumn({STR0014, {|| aDados[oGridRes:nAt,2] }, "C", "@!", 1, 150, 0, .t. , , .F., , "CCONFIG" , , .F., .T.,, "CCONFIG" }) //"Descrição"
oGridRes:setProfileID('0')
oGridRes:disableReport()
oGridRes:disableConfig()

if !lAuto
	oGridRes:activate()
	oDialMod:activate() 
endif

return


//-------------------------------------------------------------------
/*/ {Protheus.doc} PlObjFwBrow
Faz a montagem básica e inicial de um FwmBrowse ou FwBrowse, para evitar repetir o código diversas vezes.
oObjMont -> Objeto onde deve ser criado a dialog / cAlias -> Alias do Browse (quando aplicável)
cFiltro -> Filtro do browser, se houver (se sim, usa direto o SetUseFilter) / cOwner -> Dono do browse criado
cDescricao -> Descrição do browse / cMenuDef -> MenuDef dos botões do grid / lFWmBrowse -> Se FWMBROWSE, é true,s e não, false
lEditCell -> Se FWBROWSE, indica se as células são editáveis / lInsLine -> Se FWBROWSE, indica se pode inserir nova linha
lWalThru -> Ativa Walk-Thru browse / lSetAmb -> disponibiliza opção Ambiente / lUseFilt -> Utilização do filtro no Browse
@since 07/2021
@version P12. 
/*/
//-------------------------------------------------------------------
static function PlObjFwBrow(oObjMont, cAlias, cFiltro, cOwner, cDescricao, cMenuDef, lFWmBrowse, lEditCell, lInsLine, lWalThru, lSetAmb, lUseFilt, aCmpFields )
default lFWmBrowse 	:= .t.
default lEditCell	:= .f.
default lInsLine	:= .f.	
default lWalThru	:= .f.	
default lSetAmb 	:= .f. 	
default lUseFilt 	:= .f.

oObjMont := iif( lFWmBrowse, FWmBrowse():New(), FWBrowse():New() )
oObjMont:setOwner(cOwner)
oObjMont:setDescription(cDescricao)
iif( !empty(cAlias), oObjMont:setAlias(cAlias), "") 

if lFWmBrowse
	oObjMont:SetMenuDef(cMenuDef) 
	oObjMont:SetWalkthru(lWalThru)
	oObjMont:SetAmbiente(lSetAmb)
	oObjMont:SetUseFilter(lUseFilt)
	oObjMont:setFields(aCmpFields)
	if !empty(cFiltro)  
		oObjMont:setFilterDefault(cFiltro)
	endif
else
	oObjMont:setEditCell(lEditCell)
	oObjMont:setInsert(lInsLine)
endif
return oObjMont


//-------------------------------------------------------------------
/*/ {Protheus.doc} PlObjFwDial
Faz a montagem básica e inicial de um FwDialogModal, para evitar repetir o código diversas vezes
oObjDial -> Objeto onde deve ser criado a dialog / lEscurece -> se o fundo da modal deve escurecer /
aTamanho -> Indica o tamanho da modal (largura x altura) / cDescricao -> Descrição do topo da Dialog
lFormBar -> Se habilita a FormBar / lFechESC -> Se a dialog pode ser fechada com o botão ESC
@since 07/2021
@version P12
/*/
//-------------------------------------------------------------------
static function PlObjFwDial(oObjDial, lEscurece, aTamanho, cDescricao, lFormBar, lFechESC)
oObjDial := FWDialogModal():New()
oObjDial:SetBackground(lEscurece)
oObjDial:SetTitle(cDescricao)
oObjDial:SetFreeArea(aTamanho[1], aTamanho[2])
oObjDial:EnableFormBar(lFormBar)
oObjDial:SetEscClose(lFechESC)
oObjDial:CreateDialog()
return oObjDial
