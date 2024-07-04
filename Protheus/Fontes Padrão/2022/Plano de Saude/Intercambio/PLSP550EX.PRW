#include "fileIO.ch"
#include "protheus.ch"
#include "xmlxfun.ch"
#include "totvs.ch"
#include "FWMVCDEF.CH"

#define CRLF chr( 13 ) + chr( 10 )

#define GUIA_CONSULTA 	'01'
#define GUIA_SADT		'02'
#define GUIA_INTERNACAO	'05'
#define GUIA_HONORARIO 	'06'

static cCodInt 	:= ''

//nova chamada do menu, criada devido a tabela FK1, que registra as movimentações financeiras
//ter o campo de rotina tamanho 8 e com a chamada com 9 dígitos falhava nas movimentações
// de compensação e estorno
function PLSP550EX()
MsgAlert("A rotina no menu deve ser alterada de PLSP550EX para PLSP550E")
return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSP550EX
Importação do PTU A550 XML Executora

@author    Lucas Nonato
@version   V12
@since     16/11/2020
/*/
function PLSP550E()
local cGridFilter := ""
private oBrwBTO := nil
cCodInt	:= plsintpad()

// abre a tela de filtro
cGridFilter := PTU550FIL(.f.)
setKey(VK_F2 ,{|| cGridFilter := PTU550FIL(.t.) })

oBrwBTO := FWmBrowse():New()
oBrwBTO:SetAlias( 'BTO' )
oBrwBTO:SetDescription( 'Importação PTU A550 Executora' )
oBrwBTO:SetFilterDefault( cGridFilter )
oBrwBTO:SetMenuDef( "PLSP550EX" )
oBrwBTO:addLegend("BTO_ARQPAR == ' '","WHITE",	"Não contestado" )
oBrwBTO:addLegend("BTO_ARQPAR == '1'","BLUE",	"Parcial 1" )
oBrwBTO:addLegend("BTO_ARQPAR == '2'","BLACK",	"Parcial 2" )
oBrwBTO:addLegend("BTO_ARQPAR == '0'","GREEN",	"Encerrado" )
BAU->(dbsetOrder(7))
oBrwBTO:Activate()

return

//-------------------------------------------------------------------
/*/{Protheus.doc} menuDef
função para criar o menu da tela

@author    pablo alipio
@version   V12
@since     09/2020
/*/
static function menuDef()
private aRotina := {}

Add Option aRotina Title 'Importar Arquivo'				Action 'PLS550IMP(.f.,.f.)' Operation 3 Access 0 // Incluir
Add Option aRotina Title 'Visualizar'  					Action 'FwExecView("Visualizar","PLSP550EX")' 	Operation 2 Access 0 // Visualizar
Add Option aRotina Title 'Filtro(F2)'  					Action 'PTU550FIL(.T.)' 	Operation 1 Access 0 // Filtro
Add Option aRotina Title 'Cancelar Ultima Contestação'	Action 'processa({||PLSP550EXC(.f.,.f.)},"Exclusao","Processando...",.T.)'		Operation 5 Access 0 // Excluir
Add Option aRotina Title 'Analisar'  					Action 'PLSP500ANA(3)' 	Operation 2 Access 0 // Analisar
Add Option aRotina Title 'Gerar PTU A560'  					Action 'mArq560()' 	Operation 2 Access 0 // Analisar

return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

@author    Lucas Nonato
@version   V12
@since     18/11/2020
/*/
Static function ModelDef()
local oModel
local oStrBTO:= FWFormStruct(1,'BTO'  ,{ |cCampo| PLSEXIBTO(cCampo) })// cria as estruturas a serem usadas no modelo de dados
local oStrBCI:= FWFormStruct(1,'BCI',  { |cCampo| alltrim(cCampo) $ 'BCI_CODLDP,BCI_CODPEG,BCI_CODRDA,BCI_NOMRDA,BCI_TIPGUI,BCI_FASE,BCI_XTIPO,BCI_TIP550' })
local oStrB2A:= FWFormStruct(1,'B2A')
local l500X := UPPER(Alltrim(FunName())) == "PLSUA500X"
Local cRDA := "' '"

oModel := MPFormModel():New( 'PLSP550EX' , , {||} , , {||} ) // cria o objeto do modelo de dados

oModel:addFields('MasterBTO',/*cOwner*/, oStrBTO)  // adiciona ao modelo um componente de formulário
oModel:AddGrid('BCIDetail', 'MasterBTO', oStrBCI) // adiciona ao modelo uma componente de grid
oModel:AddGrid('B2ADetail', 'MasterBTO', oStrB2A) // adiciona ao modelo uma componente de grid

oStrBCI:SetProperty('BCI_TIPGUI', MODEL_FIELD_VALUES,  {"01=Consulta;02=SADT;05=Resumo de Internação;06=Honorarios;10=Recurso de Glosa"})

if l500X
	oModel:SetRelation( 'BCIDetail', { ; 
		{ 'BCI_FILIAL'	, 'xFilial("BCI")' },;
		{ 'BCI_LOTEDI'	, "'BTO|'+"+'BTO_NUMERO'};
		}, 	BCI->( IndexKey(1) ) )
else
	BAU->(dbsetOrder(7))
	IF BAU->(MsSeek(xFilial("BAU")+BTO->BTO_OPEORI))
		cRDA := "'" + BAU->BAU_CODIGO + "'"
	endif
	oModel:SetRelation( 'BCIDetail', { ; 
		{ 'BCI_FILIAL'	, 'xFilial("BCI")' },;
		{ 'BCI_LOTEDI'	, "'BTO|'+"+'BTO_NUMERO'},;
		{ 'BCI_CODRDA'	, cRDA};
		}, 	BCI->( IndexKey(1) ) )
endif

oModel:SetRelation( 'B2ADetail', { ;
	{ 'B2A_FILIAL'	, 'xFilial("BCI")' 	},;	
	{ 'B2A_OPEDES'	, 'BTO_OPEORI' 		},;
	{ 'B2A_ALIAS'	, "'BTO'" 			},;
	{ 'B2A_LOTE'	, 'BTO_NUMERO' 		};
	}, 	B2A->( IndexKey(1) ) )

if l500X
	oModel:GetModel('MasterBTO'):SetDescription("Importação PTU A500") // adiciona a descrição do modelo de dados
else
	oModel:GetModel('MasterBTO'):SetDescription("Importação PTU A550 Exec") // adiciona a descrição do modelo de dados
endif
// define chave primária do model
oModel:SetPrimaryKey( {"BTO_FILIAL", "BTO_NUMERO", "BTO_REGPRI"} )

oStrBCI:AddField( ;                      // Ord. Tipo Desc.
	"Tipo "                    , ;       // [01]  C   Titulo do campo
	"Tipo "                    , ;       // [02]  C   ToolTip do campo
	"BCI_XTIPO"                , ;       // [03]  C   Id do Field
	'C'                         , ;      // [04]  C   Tipo do campo
	40                          , ;      // [05]  N   Tamanho do campo
	0                           , ;      // [06]  N   Decimal do campo
	NIL                         , ;      // [07]  B   Code-block de validação do campo
	NIL                         , ;      // [08]  B   Code-block de validação When do campo
	NIL                         , ;      // [09]  A   Lista de valores permitido do campo
	NIL                         , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
	{||getTipGui(BCI->BCI_TIPGUI)} , ; 	 // [11]  B   Code-block de inicializacao do campo
	NIL                         , ;      // [12]  L   Indica se trata-se de um campo chave
	NIL                         , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.t.                              )   // [14]  L   Indica se o campo é virtual

Return oModel // Retorna o modelo de dados

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

@author    Lucas Nonato
@version   V12
@since     18/11/2020
/*/
Static function ViewDef()
local oView  // interface de visualização construída
local oModel := FWLoadModel( 'PLSP550EX' ) // cria as estruturas a serem usadas na View
local oStrBTO:= FWFormStruct(2, 'BTO' ,{ |cCampo| PLSEXIBTO(cCampo) })
local oStrBCI:= FWFormStruct(2, 'BCI', { |cCampo| alltrim(cCampo) $ 'BCI_CODLDP,BCI_CODPEG,BCI_CODRDA,BCI_NOMRDA,BCI_XTIPO,BCI_FASE,BCI_TIP550' })
local oStrB2A:= FWFormStruct(2, 'B2A')
local l500X := UPPER(Alltrim(FunName())) == "PLSUA500X"

oView := FWFormView():New() // cria o objeto de View

oView:SetModel(oModel)		// define qual Modelo de dados será utilizado

oView:AddField('ViewBTO' , oStrBTO,'MasterBTO' ) // adiciona no nosso View um controle do tipo formulário
oView:AddGrid( 'ViewBCI' , oStrBCI,'BCIDetail' ) // adiciona no nosso view um controle do tipo grid
oView:AddGrid( 'ViewB2A' , oStrB2A,'B2ADetail' ) // adiciona no nosso view um controle do tipo grid

oStrBTO:SetNoGroups() 

oView:CreateHorizontalBox( 'CABECALHO', 30 ) // cria um "box" horizontal para receber os campos do cabeçalho
oView:CreateHorizontalBox( 'INFERIOR' , 70 ) // cria um "box" horizontal para receber o grid de pegs

if l500X
	oView:EnableTitleView( 'ViewBTO', 'Importação PTU A500')
else
	oView:EnableTitleView( 'ViewBTO', "Importação PTU A550 Exec")
endif

oView:CreateFolder( 'PASTA','INFERIOR' )
oView:AddSheet( 'PASTA', 'ABA01', 'Protocolos' )
oView:AddSheet( 'PASTA', 'ABA02', 'Contestações' )

oView:CreateVerticalBox( 'BOXBCI', 100,,, 'PASTA', 'ABA01' )
oView:CreateVerticalBox( 'BOXB2A', 100,,, 'PASTA', 'ABA02' )

oView:SetViewProperty("ViewBCI","GRIDFILTER",{.T.}) // ativa o filtro no grid de procedimentos
oView:SetViewProperty("ViewBCI","GRIDSEEK",{.T.})

oView:SetViewProperty("ViewB2A","GRIDFILTER",{.T.}) // ativa o filtro no grid de procedimentos
oView:SetViewProperty("ViewB2A","GRIDSEEK",{.T.})

oView:SetOwnerView('ViewBTO','CABECALHO') // relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView('ViewBCI','BOXBCI') // relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView('ViewB2A','BOXB2A') // relaciona o identificador (ID) da View com o "box" para exibição

oStrBCI:AddField( ; 	
	'BCI_XTIPO' , ; 						// [01] C Nome do Campo
	'99' , ; 								// [02] C Ordem
	AllTrim( 'Tipo' ) , ; 					// [03] C Titulo do campo
	AllTrim( 'Tipo'  ) , ; 					// [04] C Descrição do campo
	{ '' } , ; 								// [05] A Array com Help
	'C' , ; 								// [06] C Tipo do campo
	'' , ;									// [07] C Picture
	NIL , ; 								// [08] B Bloco de Picture Var
	'' , ;  								// [09] C Consulta F3
	.t. , ; 								// [10] L Indica se o campo é editável
	NIL , ; 								// [11] C Pasta do campo
	NIL , ; 								// [12] C Agrupamento do campo
	NIL , ; 								// [13] A Lista de valores permitido do campo (Combo)
	NIL , ; 								// [14] N Tamanho Maximo da maior opção do combo
	NIL , ;									// [15] C Inicializador de Browse
	.t. , ; 								// [16] L Indica se o campo é virtual
	NIL )   								// [17] C Picture Variável	

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PTU500FIL
Filtro

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
function PTU550FIL(lF2)

local aPergs	:= {}
local aFilter	:= {}
local cFilter 	:= ""
local cCodOpe	:= space(4)
local cGruOpe	:= space(2)

default lF2  	:= .f.

aAdd( aPergs,{ 1, "Filtrar Unimed" , 	cCodOpe		, "", "", "B39PLS"		, "", 50, .f.})
aadd( aPergs,{ 1, "Filtrar Grupo Operadora"	,	cGruOpe		,"@!",'.T.','BA2PLS',/*'.T.'*/,40,.f. } )
aAdd( aPergs,{ 1, "A partir de:"	, 	dDataBase	, "", "", ""		, "", 50, .f.})

if( paramBox( aPergs,"Filtro de Tela",aFilter,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSUX550',/*lCanSave*/.T.,/*lUserSave*/.T. ) )
	cFilter += "@BTO_FILIAL = '" + xfilial("BTO") + "'"	
	cFilter += " AND BTO_CODOPE = '" + cCodInt + "'"	
	
	cFilter += " AND BTO_STATUS = '1' "	

	if !empty(aFilter[1]) 
		cFilter += " AND BTO_OPEORI = '" + aFilter[1] + "'"	
	endif

	cFilter += " AND BTO_ENV500 = '1' "	

	if !empty(aFilter[2]) 
		cFilter += " AND BTO_GRPOPE = '" + aFilter[2] + "'"	
	endif

	if !empty(aFilter[3]) 
		cFilter += " AND BTO_DATGER >= '" + dtos(aFilter[3]) + "'"	
	endif

	cFilter += " AND ( BTO_TPMOV = '2' OR (BTO_TPMOV = '3' AND BTO_TPCOB = '1')) "	

endif

if lF2 	
	oBrwBTO:SetFilterDefault(cFilter)
	oBrwBTO:Refresh()	
endif

return cFilter

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSEXIBTO

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
function PLSEXIBTO(cCampo)
local   lRet	:= .f.
default cCampo 	:= ""

cCampo := alltrim(cCampo)

if cCampo == "BTO_OPEORI"	.or. ;
   cCampo == "BTO_NUMERO"	.or. ;
   cCampo == "BTO_DATGER"	.or. ;
   cCampo == "BTO_USUOPE"	.or. ;
   cCampo == "BTO_HORA" 	.or. ;
   cCampo == "BTO_ANOINI" 	.or. ;
   cCampo == "BTO_MESINI" 	.or. ;
   cCampo == "BTO_QTDEVE" 	.or. ;
   cCampo == "BTO_VLRCOP" 	.or. ;
   cCampo == "BTO_VLRCP2" 	.or. ;
   cCampo == "BTO_VLRCP3" 	.or. ;
   cCampo == "BTO_VLRTAX" 	.or. ;
   cCampo == "BTO_CUSTOT" 	.or. ;
   cCampo == "BTO_PREFIX" 	.or. ;
   cCampo == "BTO_NUMTIT" 	.or. ;
   cCampo == "BTO_PARCEL" 	.or. ;
   cCampo == "BTO_TIPTIT" 	.or. ;
   cCampo == "BTO_STATUS" 	.or. ;
   cCampo == "BTO_SEQUEN" 	.or. ;
   cCampo == "BTO_GRPOPE" 	.or. ;
   cCampo == "BTO_TPCOB" 	.or. ;
   cCampo == "BTO_TPMOV" 	.or. ;
   cCampo == "BTO_NIV550"

	lRet := .t.
EndIf

Return lRet
