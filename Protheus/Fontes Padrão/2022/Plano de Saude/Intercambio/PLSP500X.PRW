#include "fileIO.ch"
#include "protheus.ch"
#include "xmlxfun.ch"
#include "totvs.ch"
#include "FWMVCDEF.CH"
#include "PLSMGER.CH"

#define GUIA_CONSULTA 	'01'
#define GUIA_SADT		'02'
#define GUIA_INTERNACAO	'05'
#define GUIA_HONORARIO 	'06'
#define GUIA_REC_GLOSA 	'10'

#define CRLF chr( 13 ) + chr( 10 )
#define K_RetFas   6

static cDirTmp 	:= PLSMUDSIS( "\plsptu\entrada\" )
static cCodInt 	:= ''
static nPLPRZAI := getNewPar("MV_PLPRZAI",30)
static cPLPACPT := getNewPar("MV_PLPACPT","99999998")
static cGenPad 	:= getNewPar("MV_PLCDPXM","01")
static cGenPro 	:= getNewPar("MV_PLPSPXM","99999994")
static cCodLdp 	:= getNewPar("MV_PLSPTUL","0003") 

static cServ 	:= "PPM,HM,HMR,VMT,VMD,REA,VTX,VDI"
static cAux 	:= "AUX,AUR"
static cAnest 	:= "PAP,PA,PAR"
static cCusOpe 	:= "COR,COP,UCO"
static cFilm 	:= "FIL"
static cMesAnoA	:= strzero(month(date()),2) + "/" + cvaltochar(year(date()))
static cMesAnoG	:= ""
static lDepara  := existBlock("DEPARAIMP")
static nTamCPac	:= TamSX3("BD6_CD_PAC")[01]
Static lNUMGOI	:= .F. //Número da guia Tiss na Operadora do intercâmbio
Static lCmpTiss4 := .F.
static lCmpReapr	:= .f.

//-------------------------------------------------------------------
/*/{Protheus.doc} PTUA500IMP
Classe referente a engine de importação do PTU A500

@author    Lucas Nonato
@version   V12
@since     06/08/2020
/*/
class PTUA500IMP

data cOpeExe 	as String 	// Codigo unimed executora
data cPathRaiz 	as String 	// Caminho raiz do arquivo
data cPathG 	as String 	// Caminho da guia corrente sendo processada
data cPath 	    as String 	// Caminho até a guia sem o contador
data cNS 	    as String 	// Namespace
data cAlias 	as String  	// BD5 ou BE4
data aCabec    	as Array 	// BD5/BE4
data aBD6    	as Array 	// BD6
data aBD6Gen   	as Array 	// BD6 genérico que não muda de um para o outro
data aVlr 	    as Array 	// Valores HM/CO/FIL 
data aTpParc    as Array 	// Tipo de participação para criação do BD7 
data aBD7Gen   	as Array 	// BD7 genérico que não muda de um para o outro
data aBX6 	    as Array 	// BX6
data aB43 	    as Array 	// B43
data aBZC	    as Array 	// BZC
data aMsg	    as Array 	// Mensagem de criticas
data nTotGuias  as numeric  // total de guias
data nGuiasProc as numeric  // total de guias processadas
data nQtdX 		as numeric  // controle da barra de progresso
data nX    		as numeric 	// posição do evento
data lAviso		as logical 	// Item avisado ou não
data cCodExcTp	as String	//Tipo de exceção do arquivo

method New() CONSTRUCTOR
method Consulta() 
method SADT() 
method Internacao() 
method Honorario()
method NotaFiscal()
method CabNF()
method Beneficiario() 
method dadosFaturamento() 
method hasNext() 
method hasNextEv() 
method profissionalExecutante()
method Solicitante() 
method contratadoExecutante() 
method procedimentos() 
method Executados()
method dadosGuia()
method equipeProfissional()
method addMsg()
method dePara()
method setPacote()
method valores() 
method logErro() 
method gravaGuia() 
method reapresentacao()
endclass

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSP500X
Importação do PTU A500 XML

@author    Lucas Nonato
@version   V12
@since     06/08/2020
/*/
function PLSP500X
local cGridFilter := ""
local cCampos := ""

BCI->(dbsetorder(1))
B6T->(dbsetorder(1))
B5T->(dbsetorder(1))

cCampos := iif(BCI->(fieldPos("BCI_LOTEDI")) <= 0, "BCI_LOTEDI,", "" )
cCampos := iif(B6T->(fieldPos("B6T_IDUNIC")) <= 0, "B6T_IDUNIC,", "" )
cCampos := iif(B6T->(fieldPos("B6T_VLT500")) <= 0, "B6T_VLT500,", "" )
cCampos := iif(B6T->(fieldPos("B6T_VLRTAX")) <= 0, "B6T_VLRTAX,", "" )
cCampos := iif(B5T->(fieldPos("B5T_VLTXTT")) <= 0, "B5T_VLTXTT,", "" )
cCampos := iif(FWAliasInDic("B6L", .F.), "", "B6L," )

if !empty(cCampos)
	cCampos := substr(cCampos,1,len(cCampos)-1)
	aviso( "Atenção","Para a execução da rotina, é necessária a criação do(s) campo(s): " + cCampos ,{ "Ok" }, 2 )
	return
endIf

// abre a tela de filtro
cGridFilter := PLSP500FIL(.F.)
setKey(VK_F2 ,{|| cGridFilter := PLSP500FIL(.T.) })

oBrwBRJ := FWmBrowse():New()
oBrwBRJ:SetAlias( 'BRJ' )
oBrwBRJ:SetDescription( 'Importação PTU A500' )
oBrwBRJ:SetFilterDefault( cGridFilter )
oBrwBRJ:SetMenuDef( "PLSP500X" )

oBrwBRJ:AddLegend( "BRJ->BRJ_STATUS == '1'",	'BR_VERDE'   ,	 "Importado"  )
oBrwBRJ:AddLegend( "BRJ->BRJ_STATUS == '2'",	'BR_VERMELHO',	 "Importado e Pago"  )

if existBlock("PLS500UNM")
	aRet := execBlock("PLS500UNM",.F.,.F.,{cServ,cAux,cAnest,cCusOpe,cFilm})
	cServ 	:= aRet[1]
	cAux 	:= aRet[2]
	cAnest 	:= aRet[3]
	cCusOpe	:= aRet[4]
	cFilm 	:= aRet[5]
endif 

oBrwBRJ:Activate()

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

Add Option aRotina Title 'Importar Arquivo'		Action 'PLS500IMP()' 		Operation 3 Access 0 // Incluir
Add Option aRotina Title 'Visualizar'  			Action 'VIEWDEF.PLSP500X' 	Operation 2 Access 0 // Visualizar
Add Option aRotina Title 'Analisar'  			Action 'PLSP500ANA(1)' 		Operation 2 Access 0 // Analisar
Add Option aRotina Title 'Gerar Pagamento'		Action 'PLSP500LOT()' 		Operation 2 Access 0 // Gerar Lote
Add Option aRotina Title 'Filtro(F2)'  			Action 'PLSP500FIL(.T.)' 	Operation 1 Access 0 // Filtro
Add Option aRotina Title 'Excluir'				Action 'processa({||PLSP500EXC()},"Exclusao","Processando...",.T.)'		Operation 5 Access 0 // Excluir
Add Option aRotina Title 'Imprimir'   			Action 'VIEWDEF.PLSP500X' 	Operation 8 Access 0 // Imprimir
Add Option aRotina Title 'Visualizar XML'   	Action 'MsDocument( "BRJ", BRJ->( recno() ), 2 )' Operation 2 Access 0 // Imprimir
Add Option aRotina Title 'Dados Adicionais'		Action 'PLSED500VS()' 		Operation 2 Access 0 
return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
definição do modelo de dados
@author pablo alipio
@since 09/2020
@version P12
/*/
//-------------------------------------------------------------------
Static function ModelDef()
local oModel
local oStrBRJ:= FWFormStruct(1,'BRJ',  { |cCampo| PLSEXIBPTU(cCampo) })// cria as estruturas a serem usadas no modelo de dados
local oStrBCI:= FWFormStruct(1,'BCI',  { |cCampo| ALLTRIM(cCampo) $ 'BCI_CODLDP,BCI_CODPEG,BCI_CODRDA,BCI_NOMRDA,BCI_TIPGUI,BCI_FASE,BCI_XTIPO,BCI_TIP550' })
local oStrB2A:= FWFormStruct(1,'B2A')

oModel := MPFormModel():New( 'PLSP500X' , , {||} , , {||} ) // cria o objeto do modelo de dados

oModel:addFields('MasterBRJ',/*cOwner*/, oStrBRJ)  // adiciona ao modelo um componente de formulário
oModel:AddGrid('BCIDetail', 'MasterBRJ', oStrBCI) // adiciona ao modelo uma componente de grid
oModel:AddGrid('B2ADetail', 'MasterBRJ', oStrB2A) // adiciona ao modelo uma componente de grid

oStrBCI:SetProperty('BCI_TIPGUI', MODEL_FIELD_VALUES,  {"01=Consulta;02=SADT;05=Resumo de Internação;06=Honorarios;"})

oModel:SetRelation( 'BCIDetail', { ;
	{ 'BCI_FILIAL'	, 'xFilial("BCI")' },;
	{ 'BCI_LOTEDI'	, "'BRJ|'+"+'BRJ_CODIGO' 		};
	}, 	BCI->( IndexKey(17) ) )

oModel:SetRelation( 'B2ADetail', { ;
	{ 'B2A_FILIAL'	, 'xFilial("BCI")' 	},;
	{ 'B2A_OPEDES'	, 'BRJ_OPEORI' 		},;
	{ 'B2A_ALIAS'	, "'BRJ'" 			},;
	{ 'B2A_LOTE'	, 'BRJ_CODIGO' 		};
	}, 	B2A->( IndexKey(1) ) )

oModel:GetModel('MasterBRJ'):SetDescription("Importação PTU A500") // adiciona a descrição do modelo de dados

// define chave primária do model
oModel:SetPrimaryKey( {"BRJ_FILIAL", "BRJ_CODIGO", "BRJ_REGPRI"} )

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
definição do interface
@author pablo alipio
@since 09/2020
@version P12
/*/
//-------------------------------------------------------------------
Static function ViewDef()
local oView  // interface de visualização construída
local oModel := FWLoadModel( 'PLSP500X' ) // cria as estruturas a serem usadas na View
local oStrBRJ:= FWFormStruct(2, 'BRJ', { |cCampo| PLSEXIBPTU(cCampo) })
local oStrBCI:= FWFormStruct(2, 'BCI', { |cCampo| ALLTRIM(cCampo) $ 'BCI_CODLDP,BCI_CODPEG,BCI_CODRDA,BCI_NOMRDA,BCI_XTIPO,BCI_FASE,BCI_TIP550' })
local oStrB2A:= FWFormStruct(2, 'B2A')

oView := FWFormView():New() // cria o objeto de View

oView:SetModel(oModel)		// define qual Modelo de dados será utilizado

oView:AddField('ViewBRJ' , oStrBRJ,'MasterBRJ' ) // adiciona no nosso View um controle do tipo formulário
oView:AddGrid( 'ViewBCI' , oStrBCI,'BCIDetail' ) // adiciona no nosso view um controle do tipo grid
oView:AddGrid( 'ViewB2A' , oStrB2A,'B2ADetail' ) // adiciona no nosso view um controle do tipo grid

oStrBRJ:SetNoGroups() 

oView:CreateHorizontalBox( 'CABECALHO', 30 ) // cria um "box" horizontal para receber os campos do cabeçalho
oView:CreateHorizontalBox( 'INFERIOR' , 70 ) // cria um "box" horizontal para receber o grid de pegs

oView:EnableTitleView( 'ViewBRJ', 'Importação PTU A500')

oView:CreateFolder( 'PASTA','INFERIOR' )
oView:AddSheet( 'PASTA', 'ABA01', 'Protocolos' )
oView:AddSheet( 'PASTA', 'ABA02', 'Contestações' )

oView:CreateVerticalBox( 'BOXBCI', 100,,, 'PASTA', 'ABA01' )
oView:CreateVerticalBox( 'BOXB2A', 100,,, 'PASTA', 'ABA02' )

oView:SetViewProperty("ViewBCI","GRIDFILTER",{.T.}) // ativa o filtro no grid de procedimentos
oView:SetViewProperty("ViewBCI","GRIDSEEK",{.T.})

oView:SetViewProperty("ViewB2A","GRIDFILTER",{.T.}) // ativa o filtro no grid de procedimentos
oView:SetViewProperty("ViewB2A","GRIDSEEK",{.T.})

oView:SetOwnerView('ViewBRJ','CABECALHO') // relaciona o identificador (ID) da View com o "box" para exibição
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
/*/{Protheus.doc} PLS500IMP
Importação do PTU A500 XML

@author    Lucas Nonato
@version   V12
@since     06/08/2020
/*/
function PLS500IMP(lAviso,lAuto)
local nI        as numeric
local cFileXML  as char
local cError    := ""
local cWarning  := ""
local cDirOri 	:= ""
local cPath		:= "\plsptu\temp\" // diretorio do servidor para arquivo temporario
local cFileLOG  := ""
local aFiles    := {}
local aMsg      := {}
local aRet 		:= {}
local lOk 		:= .f.
local lError 	:= .f.
local lCpy 		:= .f.
Local nH 		:= 0
local cPathXSD  := ""

private oProcess   := nil

default lAviso  := .f.
default lAuto   := .f.

//verifica se os campos de reapresentação existem
lCmpReapr 	:= BX6->(fieldPos("BX6_REAPRE")) > 0 .and. BX6->(fieldPos("BX6_DOC1GL")) > 0 .and. BX6->(fieldPos("BX6_DOC2GL")) > 0

cCodInt     := plsintpad()

BAU->(dbSetOrder(7))
BB0->(dbSetOrder(1))
B5T->(dbSetOrder(1))
BD5->(dbSetOrder(1))
BD6->(dbSetOrder(1))
BD7->(dbSetOrder(1))
BE4->(dbSetOrder(1))
BZC->(dbSetOrder(1))
BE2->(dbSetOrder(1))
BR8->(dbSetOrder(1))

aFiles 	:= P500GetArq(lAuto,iif(lAviso,2,1))
lOk 	:= aFiles[1]
cDirOri	:= aFiles[3]
aFiles 	:= aFiles[2]

if lOk
	for nI := 1 To Len(aFiles)
		cError := ""
		lCpy := .f.
		lError := .f.
		If ( !empty(aFiles[nI][01]) ) .and. ( aFiles[nI][05] )
			cFileXML := cDirOri + aFiles[nI][1]

			if( At( ":\",cFileXML ) <> 0 )	//se for arquivo local, copia para o servidor
				lCpy := .t.
				// se a pasta /temp/ não existir, criamos ela
				if( !existDir( cPath ) )
					MakeDir( cPath )
				endif

				// copia o arquivo para o servidor
				if cpyT2S( cFileXML, cPath)					
					cFileXML := cPath + aFiles[nI][1]					
				else
					aadd(aMsg,{aFiles[nI][1], "", "Não foi possível copiar o arquivo para o servidor."})
					lError := .t.
				endif				
			endif

			If !lError
				//Verifica qual a versão do arquivo
				aArqTmp := fopen(cFileXML , FO_READ) //Abre o Arquivo

				//Se der erro para abrir o arquivo, Vou considerar a versão atual
				cPathXSD :=  iif( aArqTmp <= 0, "\plsptu\schemas\V2_0\ptu_A500.xsd", "")
											
				nTam := fseek(aArqTmp,0,2)
				fseek(aArqTmp,0)
				nBuff := max(5000,nTam) 
				cBuff := space(nBuff)
				nRead := fread(aArqTmp,@cBuff,nBuff) 
				fclose(aArqTmp)
				xChave := alltrim( cBuff )

				IF upper("nrVerTra_PTU>02</") $ UPPER(xChave) .OR. upper("nrVerTra_PTU>2</") $ UPPER(xChave)
					//versão antiga
					cPathXSD:="\plsptu\schemas\V1_1\ptu_A500.xsd"
				else 
					cPathXSD:="\plsptu\schemas\V2_0\ptu_A500.xsd"
				ENDIF 
				
				//validação do schema
				if !xmlFVldSch( cFileXML,cPathXSD,@cError,@cWarning )
					cFileLOG := geraLogErro( cError, aFiles[nI][1], cDirOri )
					aadd(aMsg,{aFiles[nI][1], "", "Falha na estrutura. Verifique o arquivo: " + cFileLOG})
					lError := .t.
				endif
			EndIf

			if !lError
				if !lAviso
					if lAuto
						oProcess 	:= P270fProc():New()
						aRet 		:= processa(iif(lCpy,cPath,cDirOri),aFiles[nI][1], aMsg)
					else
						oProcess := msNewProcess():New( { || aRet := processa(iif(lCpy,cPath,cDirOri),aFiles[nI][1], aMsg)} , "Processando" , "Aguarde..." , .F. )
						oProcess:Activate()
					endif
					if (aRet[1] .and. !empty(aRet[2])) 
						// grava arquivo na base de conhecimento
						PLSINCONH(cFileXML, "BRJ", xFilial("BRJ") + aRet[2] + "1") // FILIAL+CODIGO+REGPRI
					else
						lError := .t.
					endif
				else
					if lAuto
						oProcess 	:= P270fProc():New()
						aRet 		:= P520PROC(iif(lCpy,cPath,cDirOri),aFiles[nI][1], aMsg)
					else
						oProcess := msNewProcess():New( { || aRet := P520PROC(iif(lCpy,cPath,cDirOri),aFiles[nI][1], aMsg)} , "Processando" , "Aguarde..." , .F. )
						oProcess:Activate()
					endif
				endif		
			endif

			if lError .and. lCpy
				nH := ft_fUse(cFileXML)
				ft_fUse()
				If nH > 0
					fclose(nH)
				Endif
				fErase(cFileXML)
			endif
		endif
	next nI

	if len(aMsg) > 0 .and. !lAuto
		PLSCRIGEN(aMsg,{ {"Arquivo","@C",50},{"Unimed","@C",8},{"Mensagem","@C",250} }, "Log de Importação",NIL,NIL,NIL,NIL, NIL,NIL,"G",220)
	endif
endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} processa
Importação do PTU A500 XML

@author    Lucas Nonato
@version   V12
@since     06/08/2020
/*/
static function processa(cDir, cFileXML, aMsg)
local aNS       	:= {}
local oPTU      	:= PTUA500IMP():New()
local cBrjCodigo 	:= ""
local cUniOri 		:= ""
local cTpPag 		:= ""
local cNrComp   	:= ""
local nTpCob    	:= ""
local cNrDoc1   	:= ""
local nVlTotDoc1 	:= 0
local dDtEmiDoc1 	:= ""
local cTpDoc1 	 	:= ""
local cDocFis1 	 	:= ""
local dDtVenDoc1 	:= ""
local cNrDoc2    	:= ""
local nVlTotDoc2 	:= ""
local dDtEmiDoc2 	:= ""
local dDtVenDoc2 	:= ""
local cTpDoc2 	 	:= ""
local cDocFis2 	 	:= ""
local cError 		:= ""
local cWarning 		:= ""
local nHBRJ 		:= 0
local aAreaBA0  	:= {}
local lRet 			:= .t.
local lError		:= .f.
local nI 			:= 0
local aDtaPag		:= {left(cMesAnoG,2), right(cMesAnoG,4) }
local dDtaRef		:= iif( (StrZero(Year(Date()),4) != aDtaPag[2] .and. StrZero(Month(Date()),2) != aDtaPag[2]), ;
							cTod("01/" + aDtaPag[1] + "/" + aDtaPag[2]), date() )

private cNS     := ""
private oXML    := tXmlManager():New()

default aMsg := {}

lNUMGOI := BD5->(FIELDPOS("BD5_NUMGOI")) > 0 .AND. BE4->(FieldPos("BE4_NUMGOI")) > 0
lCmpTiss4 := BD5->(FieldPos("BD5_TMREGA")) > 0 .AND. BD5->(FieldPos("BD5_SAUOCU")) > 0 .AND. BD5->(FieldPos("BD5_COBESP")) > 0

BAU->(dbSetOrder(7))

oPTU:aMsg 	:= aClone(aMsg)

if !oXML:parseFile(cDir+cFileXML, @cError, @cWarning)
	oPTU:addMsg(cFileXML, cBrjCodigo, cError)
	aMsg := aClone(oPTU:aMsg)
	return {lRet, cBrjCodigo}
endif

aNS := oXML:XPathGetRootNsList() 

for nI := 1 to len(aNS)
	oXML:XPathRegisterNs( aNS[nI][1],aNS[nI][2] )
	cNS := aNS[nI][1]
	If oXML:XPathHasNode( addNs("/ptuA500") )
		exit
	EndIf
next nI

oPTU:cPathRaiz   := addNS("/ptuA500")
oPTU:cPath       := oPTU:cPathRaiz + addNS("/cabecalho")

//Novo parse em caso de falha - Excluir quando o frame consertar essa falha
if empty(oXML:XPathGetNodeValue( oPTU:cPath + addNS("/unimed/cd_Uni_Origem")))
	oXML:Parse(removeMeta("ptuA500",cDir+cFileXML))
endif

// unimed
cUniOri 			:= StrZero(Val(oXML:XPathGetNodeValue( oPTU:cPath + addNS("/unimed/cd_Uni_Origem"))),4)

// cobranca
cNrComp 			:= oXML:XPathGetNodeValue( oPTU:cPath + addNS("/dadosAvisoCobranca/Cobranca/nr_Competencia"))
nTpCob				:= val(Subs(oXML:XPathGetNodeValue( oPTU:cPath + addNS("/dadosAvisoCobranca/Cobranca/tp_Cobranca")),1))

// documento1
cNrDoc1  			:= oXML:XPathGetNodeValue( oPTU:cPath + addNS("/dadosAvisoCobranca/Cobranca/documento1/nr_Documento"))
nVlTotDoc1  		:= oXML:XPathGetNodeValue( oPTU:cPath + addNS("/dadosAvisoCobranca/Cobranca/documento1/vl_TotalDoc"))
nVlTotDoc1 			:= val(Subs(nVlTotDoc1,1,12)+"."+Subs(nVlTotDoc1,13,2))
dDtEmiDoc1  		:= StoD(oXML:XPathGetNodeValue( oPTU:cPath + addNS("/dadosAvisoCobranca/Cobranca/documento1/dt_EmissaoDoc")) )
dDtVenDoc1  		:= StoD(oXML:XPathGetNodeValue( oPTU:cPath + addNS("/dadosAvisoCobranca/Cobranca/documento1/dt_VencimentoDoc")) )
cTpDoc1				:= oXML:XPathGetNodeValue( oPTU:cPath + addNS("/dadosAvisoCobranca/Cobranca/documento1/tp_Documento"))
cDocFis1 			:= oXML:XPathGetNodeValue( oPTU:cPath + addNS("/dadosAvisoCobranca/Cobranca/documento1/doc_Fiscal"))

// documento2
cNrDoc2  			:= oXML:XPathGetNodeValue( oPTU:cPath + addNS("/dadosAvisoCobranca/Cobranca/documento2/nr_Documento"))
nVlTotDoc2  		:= oXML:XPathGetNodeValue( oPTU:cPath + addNS("/dadosAvisoCobranca/Cobranca/documento2/vl_TotalDoc"))
nVlTotDoc2 			:= val(Subs(nVlTotDoc2,1,12)+"."+Subs(nVlTotDoc2,13,2))
dDtEmiDoc2  		:= StoD(oXML:XPathGetNodeValue( oPTU:cPath + addNS("/dadosAvisoCobranca/Cobranca/documento2/dt_EmissaoDoc")) )
dDtVenDoc2  		:= StoD(oXML:XPathGetNodeValue( oPTU:cPath + addNS("/dadosAvisoCobranca/Cobranca/documento2/dt_VencimentoDoc")) )
cTpDoc2				:= oXML:XPathGetNodeValue( oPTU:cPath + addNS("/dadosAvisoCobranca/Cobranca/documento2/tp_Documento"))
cDocFis2 			:= oXML:XPathGetNodeValue( oPTU:cPath + addNS("/dadosAvisoCobranca/Cobranca/documento2/doc_Fiscal"))

if empty(cNrDoc1)
	oPTU:addMsg(cFileXML, "", "Arquivo invalido.")
	lError := .t.
endif

if !BAU->(msSeek(xFilial("BAU")+cUniOri))
	oPTU:addMsg(cFileXML, cBrjCodigo, "RDA da operadora [" + cUniOri + "] não localizada.")
	lError := .t.
else
	aRet := PLSDADRDA(cCodInt,BAU->BAU_CODIGO)
	if !aRet[1]
		oPTU:addMsg(cFileXML, cBrjCodigo, "RDA invalida [" + BAU->BAU_CODIGO + "] verifique o cadastro.")
		lError := .t.		
	endif
endif

cSql := " SELECT BRJ_CODIGO FROM " + retSqlName("BRJ") + " BRJ "
cSql += " WHERE BRJ_FILIAL = '" + xFilial("BRJ") + "' "
cSql += " AND BRJ_OPEORI = '"+alltrim(cUniOri)+"' "
cSql += " AND BRJ_NUMFAT = '"+alltrim(cNrDoc1)+"' "
cSql += " AND BRJ.D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TMPBRJ",.F.,.T.)
if !TMPBRJ->(eof())
	oPTU:addMsg(cFileXML, TMPBRJ->BRJ_CODIGO, "Fatura ["+cNrDoc1+"] já importada para esta Unimed ["+cUniOri+"]")
	lError := .t.
endif
TMPBRJ->(dbclosearea())

cSql := " SELECT BRJ_CODIGO FROM " + retSqlName("BRJ") + " BRJ "
cSql += " WHERE BRJ_FILIAL = '" + xFilial("BRJ") + "' "
cSql += " AND BRJ_ARQUIV = '"+alltrim(cFileXML)+"' "
cSql += " AND BRJ.D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TMPBRJ",.F.,.T.)
if !TMPBRJ->(eof())
	oPTU:addMsg(cFileXML, TMPBRJ->BRJ_CODIGO, "Arquivo já importado anteriormente.")
	lError := .t.
endif
TMPBRJ->(dbclosearea())

if lError
	aMsg := aClone(oPTU:aMsg)
	return {lRet, cBrjCodigo}
endif

aAreaBA0 := BA0->(GetArea())
BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
If BA0->(DbSeek(xFilial("BA0")+cUniOri))
	cTpPag := IIf(!Empty(BA0->BA0_TPPAG),BA0->BA0_TPPAG,CriaVar("BRJ_TPPAG"))
Else
	cTpPag := CriaVar("BRJ_TPPAG")
EndIf
RestArea(aAreaBA0)

// criacao do brj
nHBRJ := PLSAbreSem("PLSBRJ.SMF")
BRJ->(RecLock("BRJ",.T.))
BRJ->BRJ_FILIAL := xFilial("BRJ")
BRJ->BRJ_CODIGO := GetSx8Num("BRJ","BRJ_CODIGO")
BRJ->BRJ_DATA   := dDataBase
BRJ->BRJ_REGPRI := "1"
BRJ->BRJ_ARQUIV := cFileXML
BRJ->BRJ_OPEORI := cUniOri
BRJ->BRJ_NOMORI := BA0->(Posicione("BA0",1,xFilial("BA0")+cUniOri,"BA0_NOMINT"))
BRJ->BRJ_ANO    := "20"+Subs(cNrComp,1,2)
BRJ->BRJ_TPPAG  := cTpPag
BRJ->BRJ_MES 	:= Subs(cNrComp,3,2)
BRJ->BRJ_NUMFAT := cNrDoc1
BRJ->BRJ_NRNDC  := cNrDoc2
BRJ->BRJ_TPCOB  := cValToChar(nTpCob)

If nTpCob == 1
	BRJ->BRJ_VLRNDC := nVlTotDoc2
	BRJ->BRJ_VALOR  := nVlTotDoc2
ElseIf nTpCob == 2
	BRJ->BRJ_VALOR  := nVlTotDoc1
	BRJ->BRJ_VLRFAT := nVlTotDoc1
ElseIf nTpCob == 3
	BRJ->BRJ_VALOR  := nVlTotDoc1 + nVlTotDoc2
	BRJ->BRJ_VLRNDC := nVlTotDoc2
	BRJ->BRJ_VLRFAT  := nVlTotDoc1
Endif

BRJ->BRJ_DTEMIS := dDtEmiDoc1
BRJ->BRJ_DTVENC := dDtVenDoc1
BRJ->BRJ_DTENDC := dDtEmiDoc2
BRJ->BRJ_DTVNDC := dDtVenDoc2
BRJ->BRJ_STATUS := "1"
BRJ->BRJ_CAMCOM := PLSRTCCOMP(BRJ->BRJ_OPEORI)
BRJ->BRJ_TPDOC1 := cTpDoc1
BRJ->BRJ_TPDOC2 := cTpDoc2
BRJ->BRJ_DOCFI1 := cDocFis1
BRJ->BRJ_DOCFI2 := cDocFis2
if !empty(aDtaPag)
	BRJ->BRJ_MESPAG := aDtaPag[1]
	BRJ->BRJ_ANOPAG := aDtaPag[2]
endif
BRJ->(MsUnLock())
BRJ->(ConfirmSX8())
cBrjCodigo    := BRJ->BRJ_CODIGO

PLSFechaSem(nHBRJ,"PLSBRJ.SMF")

oPTU:cPathRaiz := oPTU:cPathRaiz + addNS("/arquivoA500/Tipoguia")

oPTU:nTotGuias := oXML:XPathChildCount( oPTU:cPathRaiz )

oProcess:SetRegua1( 5 ) //Alimenta a primeira barra de progresso
oProcess:SetRegua2( oPTU:nTotGuias ) //Alimenta a segunda barra de progresso
oProcess:IncRegua1( "Processando Guias de Consulta"  ) 
oPTU:cPath := oPTU:cPathRaiz + addNS("/guiaConsulta")
if oXML:XPathHasNode( oPTU:cPath + "[1]" )
	PLSIPP(cCodInt,cCodLDP,cCodInt,BAU->BAU_CODIGO,aDtaPag[1],aDtaPag[2],date(),GUIA_CONSULTA,"",{},"1",cFileXML,,,,,,dDtaRef,,,"BRJ|"+cBrjCodigo)
    oPTU:Consulta()
	oPTU:addMsg(cFileXML, cBrjCodigo, "Protocolo de Consulta criado: " + BCI->BCI_CODPEG,cUniOri)
	addFilaPLS(BCI->BCI_CODPEG, BCI->BCI_CODLDP, BCI->BCI_TIPGUI)
endif

oProcess:IncRegua1( "Processando Guias de SADT"  ) 
oPTU:cPath := oPTU:cPathRaiz + addNS("/guiaSADT")
if oXML:XPathHasNode( oPTU:cPath + "[1]" )
	PLSIPP(cCodInt,cCodLDP,cCodInt,BAU->BAU_CODIGO,aDtaPag[1],aDtaPag[2],date(),GUIA_SADT,"",{},"1",cFileXML,,,,,,dDtaRef,,,"BRJ|"+cBrjCodigo)
    oPTU:SADT()
	oPTU:addMsg(cFileXML, cBrjCodigo, "Protocolo de SADT criado: " + BCI->BCI_CODPEG,cUniOri)
	addFilaPLS(BCI->BCI_CODPEG, BCI->BCI_CODLDP, BCI->BCI_TIPGUI)
endif

oProcess:IncRegua1( "Processando Guias de Internação"  ) 
oPTU:cPath := oPTU:cPathRaiz + addNS("/guiaInternacao")
if oXML:XPathHasNode( oPTU:cPath + "[1]" )
	PLSIPP(cCodInt,cCodLDP,cCodInt,BAU->BAU_CODIGO,aDtaPag[1],aDtaPag[2],date(),GUIA_INTERNACAO,"",{},"1",cFileXML,,,,,,dDtaRef,,,"BRJ|"+cBrjCodigo)
	oPTU:cAlias := "BE4"
    oPTU:Internacao()
	oPTU:addMsg(cFileXML, cBrjCodigo, "Protocolo de Internação criado: " + BCI->BCI_CODPEG,cUniOri)
	addFilaPLS(BCI->BCI_CODPEG, BCI->BCI_CODLDP, BCI->BCI_TIPGUI)
endif

oProcess:IncRegua1( "Processando Guias de Honorario"  ) 
oPTU:cPath := oPTU:cPathRaiz + addNS("/guiaHonorarios")
if oXML:XPathHasNode( oPTU:cPath + "[1]" )
	PLSIPP(cCodInt,cCodLDP,cCodInt,BAU->BAU_CODIGO,aDtaPag[1],aDtaPag[2],date(),GUIA_HONORARIO,"",{},"1",cFileXML,,,,,,dDtaRef,,,"BRJ|"+cBrjCodigo)
	oPTU:cAlias := "BD5"
    oPTU:Honorario()
	oPTU:addMsg(cFileXML, cBrjCodigo, "Protocolo de Honorário criado: " + BCI->BCI_CODPEG,cUniOri)
	addFilaPLS(BCI->BCI_CODPEG, BCI->BCI_CODLDP, BCI->BCI_TIPGUI)
endif

oProcess:IncRegua1( "Processando Guias de Nota fiscal do Fornecedor"  ) 
oPTU:cPath := oPTU:cPathRaiz + addNS("/notaFiscal_Fornecedor")
if oXML:XPathHasNode( oPTU:cPath + "[1]" )
	PLSIPP(cCodInt,cCodLDP,cCodInt,BAU->BAU_CODIGO,aDtaPag[1],aDtaPag[2],date(),GUIA_SADT,"",{},"1",cFileXML,,,,,,dDtaRef,,,"BRJ|"+cBrjCodigo)
    oPTU:cAlias := "BD5"
    oPTU:NotaFiscal(cBrjCodigo,nTpCob,cUniOri)
	oPTU:addMsg(cFileXML, cBrjCodigo,"Protocolo de nota fiscal do fornecedor (SADT) criado: " + BCI->BCI_CODPEG,cUniOri)
	addFilaPLS(BCI->BCI_CODPEG, BCI->BCI_CODLDP, BCI->BCI_TIPGUI)
endif

aMsg := aClone(oPTU:aMsg)

return {lRet, cBrjCodigo}

//-------------------------------------------------------------------
/*/{Protheus.doc} addNS
Adiciona o namespace dinamicamente nas tags.

@author  Lucas Nonato
@version P12
@since   08/10/2018
/*/
static function addNS(cTag) 

if !empty(cNS)
    cTag := strtran(cTag, "/", "/" + cNS + ":")
endif

return cTag

//-------------------------------------------------------------------
/*/{Protheus.doc} Consulta

@author    Lucas Nonato
@version   V12
@since     06/08/2020
/*/
method Consulta() class PTUA500IMP
local nX := 1

while ::hasNext(nX)
    ::Beneficiario()
    ::contratadoExecutante(GUIA_CONSULTA)
    ::profissionalExecutante()
    ::dadosGuia(GUIA_CONSULTA)
	::gravaGuia()	
    nX++
enddo

return

//-------------------------------------------------------------------
/*/{Protheus.doc} SADT

@author  Lucas Nonato
@version P12
@since   06/08/2020
/*/
method SADT() class PTUA500IMP
local nX 	:= 1
local cTag 	:= ""
while ::hasNext(nX)
    ::Beneficiario()
	::Solicitante()
    ::contratadoExecutante(GUIA_SADT)
    ::dadosGuia(GUIA_SADT)
	cTag 	:= ::cPathG + addNS("/dadosAtendimento")
		aadd(::aCabec, {"BD5_TIPADM",PLSVARVINC('23',, oXML:XPathGetNodeValue( cTag+addNS("/caraterAtendimento" )))})

	if lCmpTiss4
		aadd(::aCabec, {"BD5_COBESP",oXML:XPathGetNodeValue( cTag+addNS("/coberturaEspecial" ))})
		aadd(::aCabec, {"BD5_TMREGA",oXML:XPathGetNodeValue( cTag+addNS("/regimeAtendimento" ))})
		aadd(::aCabec, {"BD5_SAUOCU",oXML:XPathGetNodeValue( cTag+addNS("/saudeOcupacional" ))})
	endif

	aadd(::aCabec, {"BD5_TIPATE",oXML:XPathGetNodeValue( cTag+addNS("/tp_Atendimento" ))})
	aadd(::aCabec, {"BD5_INDACI",oXML:XPathGetNodeValue( cTag+addNS("/tp_IndAcidente" ))})
	aadd(::aCabec, {"BD5_TIPCON",oXML:XPathGetNodeValue( cTag+addNS("/tp_Consulta" ))})
	::gravaGuia()	
    nX++
enddo

return

//-------------------------------------------------------------------
/*/{Protheus.doc} Honorario

@author  Lucas Nonato
@version P12
@since   06/08/2020
/*/
method Honorario() class PTUA500IMP
local nX 		:= 1

while ::hasNext(nX)
	::Beneficiario()
	::contratadoExecutante(GUIA_HONORARIO)
	::dadosGuia(GUIA_HONORARIO)
	
	cTagTmp	:= ::cPathG + addNS("/dataFaturamento")
	//::dadosFaturamento(GUIA_INTERNACAO,cTagTmp)
	::gravaGuia()
	nX++
enddo

return

//-------------------------------------------------------------------
/*/{Protheus.doc} Internacao

@author  Lucas Nonato
@version P12
@since   06/08/2020
/*/
method Internacao() class PTUA500IMP
local nX 		:= 1
local nY 		:= 1
local cNumDoc	:= ""
local cDoc		:= ""
local cTagTmp	:= ""
local cGRPINT   := ""
local cTipInt   := ""

while ::hasNext(nX)
	cTagTmp	:= ::cPathG + addNS("/dadosInternacao")
    ::Beneficiario()
	::Solicitante()
    ::contratadoExecutante(GUIA_INTERNACAO)
	::dadosGuia(GUIA_INTERNACAO)
	::dadosFaturamento(GUIA_INTERNACAO,cTagTmp)  	

	cGRPINT := oXML:XPathGetNodeValue( cTagTmp+addNS("/tp_Internacao" ))
	cTipInt := iif(!Empty(cGRPINT),PLSVARVINC('57', 'BQR', cGrpInt),"") // Vinculo Terminologia de TIPO de Atendimento Tabela 57 TISS

	aadd(::aCabec, {"BE4_GRPINT", cGRPINT})
	aadd(::aCabec, {"BE4_TIPINT", cTipInt}) 

	aadd(::aCabec, {"BE4_PADINT", getTpAco(oXML:XPathGetNodeValue( cTagTmp+addNS("/tp_Acomodacao" )))})
	aadd(::aCabec, {"BE4_REGINT", oXML:XPathGetNodeValue( cTagTmp+addNS("/rg_Internacao" ))})
	aadd(::aCabec, {"BE4_TIPADM", PLSVARVINC('23',, oXML:XPathGetNodeValue( cTagTmp+addNS("/caraterAtendimento" )))})
	cTagTmp := cTagTmp + addNS("/dadosDeclaracoes" )
	if oXML:XPathHasNode( cTagTmp+"[1]" ) 
		aadd(::aCabec, {"BE4_CIDOBT", oXML:XPathGetNodeValue( cTagTmp+"[1]"+addNS("/CID_Obito" ))})
		aadd(::aCabec, {"BE4_ATENRN", PLS0Or1(oXML:XPathGetNodeValue( cTagTmp+"[1]"+addNS("/indicadorDO_RN" )))})
		aadd(::aCabec, {"BE4_NRDCOB", oXML:XPathGetNodeValue( cTagTmp+"[1]"+addNS("/declaracao_Obito" ))})
		while oXML:XPathHasNode( cTagTmp+ "[" + cvaltochar(nY) + "]" ) 
			cDoc := oXML:XPathGetNodeValue( cTagTmp+ "[" + cvaltochar(nY) + "]" +addNS("/declaracao_Nascido" ))
			if !empty(cDoc)
				cNumDoc += iif(empty(cNumDoc),"",",") + cDoc
			endif
			nY++
		enddo
		if !empty(cNumDoc)
			aadd(::aCabec, {"BE4_NRDCNV", cNumDoc})
		endif
	endif
	cTagTmp	:= ::cPathG + addNS("/dadosAuditoria")
	aadd(::aCabec, {"BE4_NMAUDI", oXML:XPathGetNodeValue( cTagTmp+addNS("/nm_MedicoAuditor" ))})
	aadd(::aCabec, {"BE4_RMAUDI", oXML:XPathGetNodeValue( cTagTmp+addNS("/nr_CrmAuditor" ))})
	aadd(::aCabec, {"BE4_UMAUDI", PLSVARVINC('59',, oXML:XPathGetNodeValue( cTagTmp+addNS("/cd_UFCRM" )))})
	aadd(::aCabec, {"BE4_NEAUDI", oXML:XPathGetNodeValue( cTagTmp+addNS("/nm_EnfAuditor" ))})
	aadd(::aCabec, {"BE4_REAUDI", oXML:XPathGetNodeValue( cTagTmp+addNS("/nr_CorenAuditor" ))})
	aadd(::aCabec, {"BE4_UEAUDI", PLSVARVINC('59',, oXML:XPathGetNodeValue( cTagTmp+addNS("/cd_UFCoren" )))})
	cTagTmp	:= ::cPathG + addNS("/dadosSaidaInternacao")
	aadd(::aCabec, {"BE4_INDACI", oXML:XPathGetNodeValue( cTagTmp+addNS("/tp_IndAcidente" ))})
	aadd(::aCabec, {"BE4_TIPALT", PLSVARVINC('39',,oXML:XPathGetNodeValue( cTagTmp+addNS("/mv_Encerramento" )))})	
	cCid := oXML:XPathGetNodeValue( cTagTmp+addNS("/CID" ))
	aadd(::aCabec, {"BE4_CID", cCid})
	aadd(::aCabec, {"BE4_DESCID", BA9->(posicione("BA9",1,xFilial("BA9")+cCid,"BA9_DOENCA"))})
	
	::gravaGuia()
    nX++
enddo

return

//-------------------------------------------------------------------
/*/{Protheus.doc} Beneficiario

@author  Lucas Nonato
@version P12
@since   06/08/2020
/*/
method Beneficiario() class PTUA500IMP
local cTag 		:= ::cPathG + addNS("/dadosBeneficiario")
local cMatric 	:= strzero(val(oXML:XPathGetNodeValue( cTag+addNS("/cd_Unimed"))),4) + oXML:XPathGetNodeValue( cTag+addNS("/id_Benef"))
local cNomUsr 	:= oXML:XPathGetNodeValue( cTag+addNS("/nm_Benef" ) ) 
local cTipGui	:= BCI->BCI_TIPGUI
local cGuiPri	:= oXML:XPathGetNodeValue( self:cPathG + addNS("/dadosGuia/nr_Guias/nr_GuiaTissPrincipal" ))
local cUniInter	:= oXML:XPathGetNodeValue( addNS("/ptuA500/cabecalho/unimed/cd_Uni_Origem") )
local cUniOri 	:= strzero(val(oXML:XPathGetNodeValue( cTag+addNS("/cd_Unimed" ) )),4)

aDadUsr := PGetBenef(::aCabec,::aBD6Gen, cMatric, cNomUsr, cGuiPri, cUniInter, cUniOri  )

if cTipGui == GUIA_INTERNACAO
    cAlias := "BE4"
else 
    cAlias := "BD5"
	aadd(::aCabec, {"BD5_TIPPAC", oXML:XPathGetNodeValue( cTag+addNS("/tp_Paciente" ))})
	aadd(::aCabec, {"BD5_GUIPRI",cGuiPri})
endif

aadd(::aBD6Gen, {"BD6_MATCOB", cMatric})
aadd(::aBD6Gen, {"BD6_NOMCOB", cNomUsr})
aadd(::aBD6Gen, {"BD6_ENVCON", "0"})

aadd(::aCabec, {cAlias + "_ATERNA", PLS0Or1(oXML:XPathGetNodeValue( cTag+addNS("/id_RN" )))})

return

//-------------------------------------------------------------------
/*/{Protheus.doc} dadosFaturamento

@author  Lucas Nonato
@version P12
@since   06/08/2020
/*/
method dadosFaturamento(cTipGui,cTagTmp) class PTUA500IMP
local cTpFat := ""
if cTipGui == GUIA_INTERNACAO
    cTpFat := oXML:XPathGetNodeValue( cTagTmp+addNS("/dadosFaturamento/tp_Faturamento" ))

	//De-Para  Terminologia TISS - Tab 55 - Tipo de Faturamento
	If cTpFat == "1"
		cTpFat := "4" 
	ElseIf cTpFat == "2"
		cTpFat := "1" 
	ElseIf cTpFat == "3"
		cTpFat := "2"
	ElseIf cTpFat == "4"
		cTpFat := "3"
	EndIf
	aadd(::aCabec, {"BE4_TIPFAT", cTpFat})
endif

aRetDt := retData(oXML:XPathGetNodeValue( cTagTmp+addNS("/dadosFaturamento/dt_IniFaturamento" )))	
aadd(::aCabec, {"BE4_DTINIF", aRetDt[1]})
aadd(::aCabec, {"BE4_HRINIF", aRetDt[2]})
aRetDt := retData(oXML:XPathGetNodeValue( cTagTmp+addNS("/dadosFaturamento/dt_FimFaturamento" )))	
aadd(::aCabec, {"BE4_DTFIMF", aRetDt[1]})
aadd(::aCabec, {"BE4_HRFIMF", aRetDt[2]})
aadd(::aCabec, {"BE4_DTALTA", aRetDt[1]})
aadd(::aCabec, {"BE4_HRALTA", aRetDt[2]}) 

return

//-------------------------------------------------------------------
/*/{Protheus.doc} New

@author  Lucas Nonato
@version P12
@since   06/08/2020
/*/
method New() class PTUA500IMP
::cOpeExe       := ""
::cPathRaiz     := ""
::cPath 	    := ""
::cPathG 	    := ""
::cAlias 	    := "BD5"
::aCabec        := {}
::aBD6    	    := {}
::aBD6Gen    	:= {}
::aVlr 	        := {}
::aTpParc 	    := {}
::aBD7Gen    	:= {}
::aBX6 	        := {}
::aB43 	        := {}
::aBZC 	        := {}
::nTotGuias     := 0
::nGuiasProc    := 0
::nQtdX    		:= 0
::nX 			:= 1
::lAviso		:= .f.
::cCodExcTp		:= ""
return self

//-------------------------------------------------------------------
/*/{Protheus.doc} New

@author  Lucas Nonato
@version P12
@since   06/08/2020
/*/
method gravaGuia() class PTUA500IMP
local nY 		:= 1
local lInc		:= .f.
local cChvGui	:= ""
local cSql		:= ""
local aCodUnm 	:= { cServ, cAux, cAnest, cCusOpe, cFilm }

PLSGRVCONTA(::cAlias,::aCabec,::aBD6,::aBD6Gen,::aBX6,::aB43,::aTpParc, ::aVlr,::aBD7Gen, aCodUnm, cMesAnoG )
if ::lAviso
	cSql := " SELECT R_E_C_N_O_ Recno "
	cSql += " FROM " + retSqlName("B5T") + " B5T "
	cSql += " WHERE B5T_FILIAL = '" + xfilial("B5T") + "'   "
	cSql += " AND B5T_OPEHAB = '" + cCodInt + "'   "
	cSql += " AND B5T_NUMLOT = '" + BD6->BD6_LOTEDI + "'   "
	cSql += " AND B5T_NMGPRE = '" + BD6->BD6_NUMIMP + "' "
	cSql += " AND B5T_OPEORI = '" + BRJ->BRJ_OPEORI + "' "
	cSql += " AND B5T.D_E_L_E_T_ = ' '  "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TrbB5T",.T.,.T.)	
	if !TrbB5T->(eof())
		B5T->(dbgoto(TrbB5T->Recno))	
		B5T->(RecLock("B5T",.f.))
		B5T->B5T_CODLDP := BD6->BD6_CODLDP
		B5T->B5T_CODPEG := BD6->BD6_CODPEG
		B5T->B5T_NUMGUI := BD6->BD6_NUMERO
		B5T->B5T_SEQIMP := BRJ->BRJ_CODIGO
		B5T->(MsUnLock())
	endif
	TrbB5T->(dbCloseArea())
endif

if len(::aBZC) > 0
	cChvGui := xFilial(::cAlias)+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)
	if BZC->(msSeek(xFilial("BZC")+cChvGui))
		lInc := .f.
	else
		lInc := .t.
	endif
	BZC->(reclock("BZC",lInc))	
	BZC->BZC_FILIAL := xfilial("BZC")
	BZC->BZC_ALIAS  := ::cAlias
	BZC->BZC_CHVGUI := cChvGui
	for nY := 1 to len(::aBZC)
		BZC->(&(self:aBZC[nY][1])) := self:aBZC[nY][2]
	next
	BZC->(MsUnlock())
endif
::aCabec        := {}
::aBD6    	    := {}
::aBD6Gen    	:= {}
::aVlr 	        := {}
::aTpParc 	    := {}
::aBD7Gen    	:= {}
::aBX6 	        := {}
::aB43 	        := {}
::aBZC 	        := {}
::nX 	        := 1
::lAviso        := .f.
::cCodExcTp		:= ""

return

//-------------------------------------------------------------------
/*/{Protheus.doc} hasNext

@author  Lucas Nonato
@version P12
@since   06/08/2020
/*/
method hasNext(nX) class PTUA500IMP

::cPathG := ::cPath + "[" + cvaltochar(nX) + "]"
::nGuiasProc++ 

if ::nTotGuias <= 10
	oProcess:incRegua2( "[" + cvaltochar(::nGuiasProc) +  "] de [" + cvaltochar(::nTotGuias) + "]"  )
elseif ::nQtdX == 5 .or. ::nGuiasProc == ::nTotGuias .or. ::nGuiasProc == 1
	oProcess:incRegua2( "[" + cvaltochar(::nGuiasProc) +  "] de [" + cvaltochar(::nTotGuias) + "]"  )
	::nQtdX := 0
endif

::nQtdX++

if !oXML:XPathHasNode( ::cPathG )
	::nQtdX--
	::nGuiasProc--
endif

return oXML:XPathHasNode( ::cPathG )

//-------------------------------------------------------------------
/*/{Protheus.doc} hasNextEv

@author  Lucas Nonato
@version P12
@since   06/08/2020
/*/
method hasNextEv(cTag, cTagOri) class PTUA500IMP
local lRet := .f.
cTag := cTagOri + "[" + cvaltochar(::nX) + "]"

if oXML:XPathHasNode( cTag )
	lRet := .t.
endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} contratadoExecutante

@author  Lucas Nonato
@version P12
@since   06/08/2020
/*/
method contratadoExecutante(cTipGui) class PTUA500IMP
local cTag 		:= ::cPathG 
local cAlias 	:= ::cAlias

if cTipGui == GUIA_CONSULTA
	cTag += addNS("/contratadoExecutante")
else
	cTag += addNS("/dadosExecutante")
endif

if cTipGui <> GUIA_INTERNACAO
	cCgc := ifPls(oXML:XPathGetNodeValue( cTag+addNS("/CPF_CNPJ/cd_cpf")),oXML:XPathGetNodeValue( cTag+addNS("/CPF_CNPJ/cd_cnpj")))
else
	cCgc := oXML:XPathGetNodeValue( cTag+addNS("/cd_cnpj"))
endif

aadd(::aCabec, {cAlias+"_PESEDI", iif(len(alltrim(cCgc))==11,'F','J')})
aadd(::aCabec, {cAlias+"_CGCEDI", cCgc })
aadd(::aCabec, {cAlias+"_CNESED", oXML:XPathGetNodeValue( cTag+addNS("/CNES"))})
aadd(::aCabec, {cAlias+"_MUNEDI", oXML:XPathGetNodeValue( cTag+addNS("/prestador/cd_MunicipioCont"))})

aadd(::aBD6Gen, {"BD6_RDAEDI", oXML:XPathGetNodeValue( cTag+addNS("/UnimedPrestador/cd_Prest" ))})
aadd(::aBD6Gen, {"BD6_NOMEDI", oXML:XPathGetNodeValue( cTag+addNS("/nome"))})
aadd(::aBD6Gen, {"BD6_CNPJED", cCgc})
aadd(::aBD6Gen, {"BD6_TPRDAE", iif(len(alltrim(cCgc))==11,'F','J')})
aadd(::aBD6Gen, {"BD6_TRDAED", oXML:XPathGetNodeValue( cTag+addNS("/prestador/tp_Prestador" ))})
aadd(::aBD6Gen, {"BD6_RPEDI", oXML:XPathGetNodeValue( cTag+addNS("/prestador/id_RecProprio" ))})


return

//-------------------------------------------------------------------
/*/{Protheus.doc} profissionalExecutante

@author  Lucas Nonato
@version P12
@since   06/08/2020
/*/
method profissionalExecutante(oPTU) class PTUA500IMP
local cTag 		:= ::cPathG + addNS("/profissionalExecutante")

cNome 	:= oXML:XPathGetNodeValue( cTag+addNS("/nome"))
cSgCons := oXML:XPathGetNodeValue( cTag+addNS("/dadosConselho/sg_Conselho"))
cNrCons := oXML:XPathGetNodeValue( cTag+addNS("/dadosConselho/nr_Conselho"))
cUFCons := oXML:XPathGetNodeValue( cTag+addNS("/dadosConselho/UF"))
cCbos 	:= oXML:XPathGetNodeValue( cTag+addNS("/CBO"))
cUFCons := PLSVARVINC('59', nil, cUFCons)

PGetExec(::aBD7Gen,cSgCons,cNrCons,cUFCons,cNome,cCbos,::aCabec)

aadd(::aBD6Gen, {"BD6_ESPEDI", cCbos})

return

//-------------------------------------------------------------------
/*/{Protheus.doc} dadosGuia

@author  Lucas Nonato
@version P12
@since    06/08/2020
/*/
method dadosGuia(cTipGui) class PTUA500IMP
local cTag 		:= ::cPathG + addNS("/dadosGuia")
local cAlias 	:= ::cAlias
local cTagTmp	:= ""
local cRegCPL	:= ""
local cDesc1 	:= ""
local cDesc2 	:= ""
local nY 		:= 1
local aRetDt	:= {}
local dDtAten   := cTod("")

aadd(::aCabec, {cAlias+"_TISVER", oXML:XPathGetNodeValue( cTag+addNS("/nr_Ver_TISS" ))})
aadd(::aCabec, {cAlias+"_LOTEDI", oXML:XPathGetNodeValue( cTag+addNS("/nr_LotePrestador" ))})

if cTipGui == GUIA_CONSULTA
	aadd(::aCabec, {cAlias+"_TIPCON", oXML:XPathGetNodeValue( cTag+addNS("/tp_Consulta" ))})
	aadd(::aCabec, {cAlias+"_INDACI", oXML:XPathGetNodeValue( cTag+addNS("/tp_IndAcidente" ))})

	if lCmpTiss4
		aadd(::aCabec, {cAlias+"_COBESP", oXML:XPathGetNodeValue( cTag+addNS("/coberturaEspecial" ))})
		aadd(::aCabec, {cAlias+"_TMREGA", oXML:XPathGetNodeValue( cTag+addNS("/regimeAtendimento" ))})
		aadd(::aCabec, {cAlias+"_SAUOCU", oXML:XPathGetNodeValue( cTag+addNS("/saudeOcupacional" ))})
	endif
endif
aadd(::aCabec, {cAlias+"_GUIJUR", PLS0Or1(oXML:XPathGetNodeValue( cTag+addNS("/id_Liminar" )))})
aadd(::aCabec, {cAlias+"_NUMIMP", oXML:XPathGetNodeValue( cTag+addNS("/nr_Guias/nr_GuiaTissPrestador" ))})
if lNUMGOI
	aadd(::aCabec, {cAlias+"_NUMGOI", oXML:XPathGetNodeValue( cTag+addNS("/nr_Guias/nr_GuiaTissOperadora" ))})
endif
aRetDt := retData(oXML:XPathGetNodeValue( cTag+addNS("/dt_Atendimento" )))	
aadd(::aCabec, {cAlias+"_DATPRO", aRetDt[1]})
aadd(::aCabec, {cAlias+"_HORPRO", aRetDt[2]})
if cTipGui == GUIA_CONSULTA
	aadd(::aBD6Gen, {"BD6_DATPRO", aRetDt[1]})
	aadd(::aBD6Gen, {"BD6_HORPRO", aRetDt[2]})
	dDtAten := aRetDt[1]
endif

if cTipGui == GUIA_INTERNACAO
	aadd(::aCabec, {"BE4_PRVINT", aRetDt[1]})
	aadd(::aCabec, {"BE4_DATVAL", aRetDt[1] + nPLPRZAI})
endif

if cTipGui == GUIA_CONSULTA .AND.  oXML:XPathGetNodeValue(cTag+addNS("/dadosAutorizacao/nr_Autorizacao" )) <> " "
	aadd(::aCabec, {cAlias+"_SENHA", Strzero(Val(oXML:XPathGetNodeValue(cTag+addNS("/dadosAutorizacao/nr_Autorizacao" ))),10)})//Pega a senha para gravar no BD5_SENHA OU BE4_SENHA
endif

if ::cAlias == "BD5" .and. oXML:XPathGetNodeValue(cTag+addNS("/dadosAutorizacao/dt_Solicitacao" )) != " "
	aadd(::aCabec, {cAlias+"_DATSOL", retData(oXML:XPathGetNodeValue(cTag+addNS("/dadosAutorizacao/dt_Solicitacao")))[1]})
endif

if oXML:XPathGetNodeValue( cTag+addNS("/id_Avisado" )) == "S"
	::lAviso := .t.
endif

//reapresentação de arquivo
::cCodExcTp := oXML:XPathGetNodeValue( cTag+addNS("/cd_Excecao" ))
	
if cTipGui == GUIA_CONSULTA	
	::procedimentos(cTipGui,cTag,dDtAten)	
else
	::Executados(cTipGui)
endif

cTag += addNS("/complemento") 

while oXML:XPathHasNode( cTag + "[" + cvaltochar(nY) + "]" )
	cTagTmp := cTag + "[" + cvaltochar(nY) + "]"
	cRegCPL := oXML:XPathGetNodeValue( cTagTmp+addNS("/tp_RegCPL" ))
	cDesc1 	:= alltrim(oXML:XPathGetNodeValue( cTagTmp+addNS("/nm_DescComplemento" )))	
	cDesc2 	:= substr(cDesc1,251,250)
	cDesc1 	:= substr(cDesc1,1,250)	

	do case
		case cRegCPL == '1'
			aadd(::aCabec, {cAlias+"_INDCLI", cDesc1})
			if !empty(cDesc2)
				aadd(::aCabec, {cAlias+"_INDCL2", cDesc2})
			endif
		case cRegCPL == '2'			
			aadd(::aBZC, {"BZC_OBSNO1", cDesc1})
			if !empty(cDesc2)
				aadd(::aBZC, {"BZC_OBSNO2", cDesc2})
			endif
		case cRegCPL == '3'			
			aadd(::aBZC, {"BZC_JUSTE1", cDesc1})
			if !empty(cDesc2)
				aadd(::aBZC, {"BZC_JUSTE2", cDesc2})
			endif
		case cRegCPL == '4'			
			aadd(::aBZC, {"BZC_ESMAT1", cDesc1})
			if !empty(cDesc2)
				aadd(::aBZC, {"BZC_ESMAT2", cDesc2})
			endif
	endcase
	nY++
enddo

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS0Or1

@author  Lucas Nonato
@version P12
@since    06/08/2020
/*/
function PLS0Or1(cRet,lDif)
default lDif := .f.

if cRet == 'S'
	cRet := "1"
elseif lDif
	cRet := "2"
else 
	cRet := "0"
endif

return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} procedimentos

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
method procedimentos(cTipGui,cTagOri,dDtExec) class PTUA500IMP
local cCodPad	:= ""
local cCodPro	:= ""
local cCodPro2  := ""
Local cDespac	:= ""
Local cDes500	:= ""
Default dDtExec := ""

cTag := cTagOri + addNS("/procedimentos")

if cTipGui == GUIA_CONSULTA
	aadd(::aBD6,{})
	aadd(::aBX6,{})
	aadd(::aB43,{})
	aadd(::aVlr,{})
	aadd(::aTpParc,{})
	::valores(cTagOri,GUIA_CONSULTA)
endif

aadd(::aBX6[::nX], {"BX6_SEQPTU", oXML:XPathGetNodeValue( cTag+addNS("/seq_item" ))})
aadd(::aBX6[::nX], {"BX6_IDUNIC", oXML:XPathGetNodeValue( cTag+addNS("/id_itemUnico" ))})

//Verifico se é uma guia de reapresentação. Se sim, gravo os campos na BX6 para os itens.
::reapresentacao()

cCodPad :=  oXML:XPathGetNodeValue( cTag+addNS("/tp_Tabela" ))
cCodPro :=  alltrim(oXML:XPathGetNodeValue( cTag+addNS("/cd_Servico" )))
cCodPro2 := cCodPro

if  cCodPad == "00" .and. len(cCodPro) == 10
	cCodPro := substr(cCodPro,3,8)
endif

cDes500 := oXML:XPathGetNodeValue( cTag+addNS("/ds_Servico" ))

if cCodPad <> "98"
	::dePara(@cCodPad,@cCodPro,,dDtExec,cCodPro2)
	aadd(::aBD6[::nX], {"BD6_CODPAD", cCodPad})
	aadd(::aBD6[::nX], {"BD6_CODPRO", cCodPro})
else
	aadd(::aBD6[::nX], {"BD6_CODPAD", PLSVARVINC('87', nil, cCodPad)})
	aadd(::aBD6[::nX], {"BD6_CODPRO", cPLPACPT})
	aadd(::aBD6[::nX], {"BD6_CD_PAC", padl(cCodPro, nTamCPac, "0")})
	cDespac := oXML:XPathGetNodeValue( cTag+addNS("/ds_Servico" ))
	if empty(cDespac)
		cDespac := "PACOTE GENÉRICO PTU"
	endif
	aadd(::aBD6[::nX], {"BD6_DESPRO", cDespac})
endif

//adiciona a descrição enviada no arquivo, caso exista a tag para gravar no BD6_DES500
if !(empty(cDes500))
	aadd(::aBD6[::nX], {"BD6_DES500", cDes500})
endif

if !empty(oXML:XPathGetNodeValue(cTagOri+addNS("/dadosAutorizacao/nr_Autorizacao" ))) 
	aadd(::aBD6[::nX], {"BD6_NRAOPE", Strzero(Val(oXML:XPathGetNodeValue(cTagOri+addNS("/dadosAutorizacao/nr_Autorizacao" ))),10)}) 
endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} dePara

@author    Lucas Nonato
@version   V12
@since     06/08/2020
/*/
method dePara(cCodPad,cCodPro,lPacote,dDtExec,cCodPro2) class PTUA500IMP
local cSql 		:= ""
local cOriPad	:= cCodPad
local cOriPro 	:= cCodPro
local lAchou 	:= .f.
local aRetPE    :={}
default lPacote := .f.
default dDtExec := cTod("")

if lDepara
	aRetPE 		:= execBlock("DEPARAIMP",.f., .f. ,{cCodPad,cCodPro2,dDtExec,BCI->BCI_CODRDA})
	lAchou 	  	:= aRetPE[1]
	cCodPad 	:= aRetPE[2]
	cCodPro 	:= aRetPE[3]
endif

if !lDepara .and. !lAchou
	cSql := " SELECT BTU_VLRBUS, BTU_VLRSIS FROM " + retsqlname("BTU")
	cSql += " WHERE BTU_FILIAL = '"+xfilial("BTU")+"' "
	cSql += " AND BTU_CODTAB = '"+cCodPad+"' "
	cSql += " AND BTU_CDTERM = '"+cCodPro+"' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),'TMPBTU',.F.,.T.)
	if !TMPBTU->(eof()) .and. !empty(TMPBTU->BTU_VLRBUS)
		cCodPad := alltrim(strtran(strtran(alltrim(TMPBTU->BTU_VLRSIS),alltrim(TMPBTU->BTU_VLRBUS),""),xfilial("BR8"),""))
		cCodPro := alltrim(TMPBTU->BTU_VLRBUS)
	endif
	TMPBTU->(dbclosearea())

	if !lPacote .and. !BR8->(MsSeek(xFilial("BR8")+cCodPad+cCodPro))	
		cCodPad := cGenPad
		cCodPro := cGenPro
		aadd(::aBD6[::nX],{"BD6_SLVPAD",cOriPad})
		aadd(::aBD6[::nX],{"BD6_SLVPRO",cOriPro})
	endif
endif 

return

//-------------------------------------------------------------------
/*/{Protheus.doc} contratadoExecutante

@author  Lucas Nonato
@version P12
@since   06/08/2020
/*/
method Solicitante(cTipGui) class PTUA500IMP
local cTag 		:= ::cPathG + addNS("/dadosSolicitante/profissional")
local cAlias 	:= ::cAlias
local cCbo      := ""

cNome 	:= oXML:XPathGetNodeValue( cTag+addNS("/nm_Profissional"))
cSgCons := oXML:XPathGetNodeValue( cTag+addNS("/dadosConselho/sg_Conselho"))
cNrCons := oXML:XPathGetNodeValue( cTag+addNS("/dadosConselho/nr_Conselho"))
cUFCons := oXML:XPathGetNodeValue( cTag+addNS("/dadosConselho/UF"))
cUFCons := PLSVARVINC('59', nil, cUFCons)
cCbo    := oXML:XPathGetNodeValue( cTag+addNS("/CBO"))

PGetSolic(cAlias,::aCabec,cSgCons,cNrCons,cUFCons,cNome,cCbo)

return

//-------------------------------------------------------------------
/*/{Protheus.doc} Executados

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
method Executados(cTipGui) class PTUA500IMP
local cTag 		:= ::cPathG + addNS("/dadosGuia/procedimentosExecutados")
local cTagOri 	:= cTag
local cCodVia	:= ""
local nPerVia	:= 0
local cAlias 	:= ::cAlias

while ::hasNextEv(@cTag,cTagOri)
	aadd(::aBD6,{})
	aadd(::aBX6,{})
	aadd(::aB43,{})
	aadd(::aTpParc,{})
	aadd(::aVlr,{})
	
	if oXML:XPathGetNodeValue( cTag+addNS("/id_Pacote")) == "S"
		::setPacote(cTag)
		::nX++
		loop
	endif
	
	aadd(::aBD6[::nX], {"BD6_DATPRO", oXML:XPathGetNodeValue( cTag+addNS("/dt_Execucao"))})
	aadd(::aBD6[::nX], {"BD6_HORPRO", strtran(oXML:XPathGetNodeValue( cTag+addNS("/hr_Inicial")),":","")})
	aadd(::aBD6[::nX], {"BD6_HORFIM", strtran(oXML:XPathGetNodeValue( cTag+addNS("/hr_Final")),":","")})

	cTagTmp := cTag+addNS("/via_Acesso")
	if oXML:XPathHasNode( cTagTmp )
		cTagTmp := oXML:XPathGetNodeValue( cTagTmp )
		BGR->(dbSetOrder(2))
		if BGR->(msSeek(xFilial("BGR")+cCodInt+StrZero(val(cTagTmp),1))) 
			cCodVia	:= BGR->BGR_CODVIA
			nPerVia	:= BGR->BGR_PERC
		else
			BGR->(dbSetOrder(1))
			if BGR->(MsSeek(xFilial("BGR")+cCodInt+StrZero(val(cTagTmp),1))) 
				cCodVia	:= BGR->BGR_CODVIA
				nPerVia	:= BGR->BGR_PERC
			endif
		endif
		if !empty(cCodVia)
			aadd(::aBD6[::nX], {"BD6_VIA"		, cCodVia})
			aadd(::aBD6[::nX], {"BD6_PERVIA"	, nPerVia})
		endif
	endif
	aadd(::aBD6[::nX], {"BD6_TECUTI", oXML:XPathGetNodeValue( cTag+addNS("/tc_Utilizada"))})
	//aadd(::aBD6[::nX], {"BD6_FATMUL", oXML:XPathGetNodeValue( cTag+addNS("/ft_MultiplicadorServico"))})
	aadd(::aBD6[::nX], {"BD6_CODATO", oXML:XPathGetNodeValue( cTag+addNS("/cd_Ato"))})
	if cTipGui <> GUIA_HONORARIO
		aadd(::aBX6[::nX], {"BX6_CODUNM", oXML:XPathGetNodeValue( cTag+addNS("/un_Medida"))})
		if oXML:XPathHasNode(cTag+addNS("/dadosOPME"))
			aadd(::aBX6[::nX], {"BX6_NOMFOR", oXML:XPathGetNodeValue( cTag+addNS("/dadosOPME/Pago_Fornecedor/nm_FornecedorMaterial"))})
			aadd(::aBX6[::nX], {"BX6_CNPJFO", oXML:XPathGetNodeValue( cTag+addNS("/dadosOPME/Pago_Fornecedor/CNPJ_Fornecedor"))})
			aadd(::aBX6[::nX], {"BX6_NNFFOR", oXML:XPathGetNodeValue( cTag+addNS("/dadosOPME/Pago_Fornecedor/nr_NotaFiscalFornecedor"))})
			aadd(::aBX6[::nX], {"BX6_DREANV", oXML:XPathGetNodeValue( cTag+addNS("/dadosOPME/det_RegistroAnvisa"))})
			aadd(::aBX6[::nX], {"BX6_REGANV", oXML:XPathGetNodeValue( cTag+addNS("/dadosOPME/nr_RegistroAnvisa"))})
			aadd(::aBD6[::nX], {"BD6_REFFED", oXML:XPathGetNodeValue( cTag+addNS("/dadosOPME/cd_ReferenciaMat_Fab"))})
		endif
	endif
		
	::valores(cTag,cTipGui)	
	if oXML:XPathHasNode(cTag+addNS("/equipe_Profissional[1]"))
		::equipeProfissional(cTag)
	endif

	::procedimentos(cTipGui,cTag,::aBD6[::nX][1][2])

	if !empty(oXML:XPathGetNodeValue(cTag+addNS("/dadosAutorizacao/nr_Autorizacao" ))) 
		aadd(::aBD6[::nX], {"BD6_NRAOPE", Strzero(Val(oXML:XPathGetNodeValue(cTag+addNS("/dadosAutorizacao/nr_Autorizacao" ))),10)}) //Grava no BD6_NRAOPE pq vem por item e além disso temos que comparar com o campo que o PTU Online preenche, BEA_NRAOPE
		//mantido essa apenas pq já fazia, se não tiver outros usos, remover no futuro.
		aadd(::aCabec, {cAlias+"_SENHA", Strzero(Val(oXML:XPathGetNodeValue(cTag+addNS("/dadosAutorizacao/nr_Autorizacao" ))),10)}) //Grava o  nr_Autorizacao no campo BD5_SENHA ou BE4_SENHA
	endif

	::nX++
enddo

return

//-------------------------------------------------------------------
/*/{Protheus.doc} valores

@author    Lucas Nonato
@version   V12
@since     08/09/2020
/*/
method valores(cTag,cTipGui) class PTUA500IMP
local nValorHm 	:= 0
local nValorCO 	:= 0
local nValorFIL	:= 0
local nValor 	:= 0
local nVlrHmTx 	:= 0
local nVlrCOTx 	:= 0
local nVlrFILTx := 0
local nVlrTx 	:= 0
local nQtd	 	:= 0
local cTagTmp	:= ""
local cTagTmpTx	:= ""

if cTipGui <> GUIA_HONORARIO .and. cTipGui <> GUIA_CONSULTA
	cTagTmp 	:= addNS("/valores")
	cTagTmpTx 	:= addNS("/taxas")
endif

if cTipGui == GUIA_CONSULTA
	cTagTmp 	:= addNS("/procedimentos")
	cTagTmpTx 	:= addNS("/procedimentos")
endif

nValorHm  += val(oXML:XPathGetNodeValue( cTag+cTagTmp+addNS("/vl_ServCobrado" )))
nValorCO  += val(oXML:XPathGetNodeValue( cTag+cTagTmp+addNS("/vl_CO_Cobrado"  )))
nValorFIL += val(oXML:XPathGetNodeValue( cTag+cTagTmp+addNS("/vl_FilmeCobrado")))

nVlrHmTx  += val(oXML:XPathGetNodeValue( cTag+cTagTmpTx+addNS("/tx_AdmServico")))
nVlrCOTx  += val(oXML:XPathGetNodeValue( cTag+cTagTmpTx+addNS("/tx_AdmCO"  	  )))
nVlrFILTx += val(oXML:XPathGetNodeValue( cTag+cTagTmpTx+addNS("/tx_AdmFilme"  )))

aadd(::aVlr[::nX], nValorHm  + nVlrHmTx )
aadd(::aVlr[::nX], nValorCO  + nVlrCOTx )
aadd(::aVlr[::nX], nValorFIL + nVlrFILTx)
aadd(::aVlr[::nX], nVlrHmTx )
aadd(::aVlr[::nX], nVlrCOTx )
aadd(::aVlr[::nX], nVlrFILTx )

nValor := nValorHm + nValorCO + nValorFIL
nVlrTx := nVlrHmTx + nVlrCOTx + nVlrFILTx

if ::lAviso
	cNrLote := oXML:XPathGetNodeValue(::cPathG 	+ addNS("/dadosGuia/nr_LotePrestador"))
	cGuiPre := oXML:XPathGetNodeValue(::cPathG 	+ addNS("/dadosGuia/nr_Guias/nr_GuiaTissPrestador"))
	cIdUnic := oXML:XPathGetNodeValue(cTag	+ addNS("/procedimentos/id_itemUnico"))
	setB6T(cNrLote,cGuiPre,cIdUnic,cTipGui,nValor,nVlrTx)
endif

if cTipGui <> GUIA_CONSULTA
	cTag += addNS("/procedimentos")
	nQtd := val(oXML:XPathGetNodeValue(cTag	+ addNS("/qt_Cobrada")))
else
	nQtd := 1
endif

aadd(::aBD6[::nX], {"BD6_VALORI", nValor})
aadd(::aBD6[::nX], {"BD6_VLRAPR", nValor/nQtd})
aadd(::aBD6[::nX], {"BD6_VLTXAP", nVlrTx})
aadd(::aBD6[::nX], {"BD6_QTDPRO", nQtd})

return

//-------------------------------------------------------------------
/*/{Protheus.doc} equipeProfissional

@author    Lucas Nonato
@version   V12
@since     10/09/2020
/*/
method equipeProfissional(cTagOri) class PTUA500IMP
local cTag 	:= cTagOri+addNS("/equipe_Profissional")
local cDePara	:= ""
local cTpPar	:= ""
local cNmProf	:= ""
local cSgCons	:= ""
local cNrCons	:= ""
local cUFCons	:= ""
local cCbos		:= ""
local nX		:= 1

while oXML:XPathHasNode( cTag + "[" + cvaltochar(nX) + "]" )
	cTagTmp := cTag + "[" + cvaltochar(nX) + "]"
	cTpPar	:= oXML:XPathGetNodeValue(cTagTmp+addNS("/tp_Participacao"))
	cNmProf	:= oXML:XPathGetNodeValue(cTagTmp+addNS("/nm_Profissional"))
	cSgCons	:= oXML:XPathGetNodeValue(cTagTmp+addNS("/dadosConselho/sg_Conselho"))
	cNrCons	:= oXML:XPathGetNodeValue(cTagTmp+addNS("/dadosConselho/nr_Conselho"))
	cUFCons	:= oXML:XPathGetNodeValue(cTagTmp+addNS("/dadosConselho/UF"))
	cUFCons := PLSVARVINC('59', nil, cUFCons)
	cCbos	:= oXML:XPathGetNodeValue(cTagTmp+addNS("/CBO"))	
	cDePara	:= alltrim(PLSVARVINC('35', nil, cTpPar))
	aadd(::aTpParc[::nX],{})
	aadd(::aTpParc[::nX][nX],.f.)
	aadd(::aTpParc[::nX][nX],cDePara)
	aadd(::aTpParc[::nX][nX],cTpPar)
	aadd(::aTpParc[::nX][nX],cCbos)
	PGetEquip(::aTpParc[::nX][nX],cSgCons,cNrCons,cUFCons,cNmProf)
	nX++
enddo

return

//-------------------------------------------------------------------
/*/{Protheus.doc} retData

@author    Lucas Nonato
@version   V12
@since     25/08/2020
/*/
static function retData(cData)
local aRet := array(2)

aRet[1] := stod(strtran(substr(cData,1,10),"/"))
aRet[2] := strtran(substr(cData,11,8),":","")
 
return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc}  getTpAco

@author    Lucas Nonato
@version   V12
@since     04/09/2020
/*/
static function getTpAco(cTpAco)
local cRet := ""
local cSql := ""

if !empty(cTpAco)

	Do Case
		Case cTpAco == "B" // Apartamento(Individual)
			cTpAco := "1"
		Case cTpAco == "A" // Enfermaria(Coletiva) 
			cTpAco := "2"
		Case cTpAco $ "C"// Não se aplica 
			cTpAco := "3"
	endcase
	
	cSql := " SELECT BI4_CODACO FROM " + retsqlname("BI4")
	cSql += " WHERE BI4_FILIAL = '" + xfilial("BI4") + "' "
	cSql += " AND BI4_CODEDI = '" + cTpAco + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),'TMPBI4',.F.,.T.)
	if !TMPBI4->(eof()) 		
		cRet := TMPBI4->BI4_CODACO
	endif
	TMPBI4->(dbclosearea())
endif
 
return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} setPacote

@author    Lucas Nonato
@version   V12
@since     04/09/2020
/*/
method setPacote(cTagOri) class PTUA500IMP
local cCodPac	:= ""
local cTag		:= ""
local nI		:= 0
local nL		:= 0
local nPos		:= 0
local nLen		:= 0
Local lB43Qtd := B43->(FieldPos("B43_QTDPRO")) > 0
Local cCodPro2	:= ''

cCodPac := oXML:XPathGetNodeValue( cTagOri+addNS("/cd_Pacote"))
for nI := len(self:aBD6) to 1 step -1
	nPos := ascan(self:aBD6[nI],{|x| allTrim(x[2]) == cCodPac})
	if nPos > 0	
		cTag := cTagOri + addNS("/procedimentos")	
		cCodPad	:= oXML:XPathGetNodeValue( cTag+addNS("/tp_Tabela" ))
		cCodPro	:= oXML:XPathGetNodeValue( cTag+addNS("/cd_Servico" ))
		cCodPro2 := cCodPro
		if cCodPad == "00"
			cCodPro := substr(cCodPro,3)
		endif
		::dePara(@cCodPad,@cCodPro,.t.,,cCodPro2)
		for nL := 1 to len(::aB43[nI])
			nPos := ascan(self:aB43[nI][nL],{|x| allTrim(x[2]) == cCodPro})
			if nPos > 0
				aadd(self:aB43[nI][nL],{"B43_SEQPTU",oXML:XPathGetNodeValue( cTag+addNS("/seq_item" ))})
				aadd(self:aB43[nI][nL],{"B43_IDUNIC",oXML:XPathGetNodeValue( cTag+addNS("/id_itemUnico" ))})
				exit
			endif
		next
		exit
	endif	
next
if nI > 0 .and. (nPos == 0 .or. len(::aB43[nI]) == 0)
	aadd(::aB43[nI],{})
	nLen := len(::aB43[nI])
	cTag := cTagOri + addNS("/procedimentos")	
	cCodPad	:= oXML:XPathGetNodeValue( cTag+addNS("/tp_Tabela" ))
	cCodPro	:= oXML:XPathGetNodeValue( cTag+addNS("/cd_Servico" ))
	cCodPro2 := cCodPro
	if cCodPad == "00"
		cCodPro := substr(cCodPro,3)
	endif
	::dePara(@cCodPad,@cCodPro,.t., ,cCodPro2)
	aadd(::aB43[nI][nLen], {"B43_CODPAD", cCodPad})
	aadd(::aB43[nI][nLen], {"B43_CODPRO", cCodPro})
	aadd(::aB43[nI][nLen], {"B43_DESPRO", oXML:XPathGetNodeValue( cTag+addNS("/ds_Servico"))})
	aadd(::aB43[nI][nLen], {"B43_TIPO"  , iif(oXML:XPathHasNode(cTag+addNS("/dadosOPME")),'5','0')})
	aadd(::aB43[nI][nLen], {"B43_SEQPTU", oXML:XPathGetNodeValue( cTag+addNS("/seq_item" ))})
	aadd(::aB43[nI][nLen], {"B43_IDUNIC", oXML:XPathGetNodeValue( cTag+addNS("/id_itemUnico" ))})
	IIF(lB43Qtd,aadd(::aB43[nI][nLen], {"B43_QTDPRO", val(oXML:XPathGetNodeValue( cTag+addNS("/qt_Cobrada" )))}),)
endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} addMsg
Adiciona uma mensagem de processamento ao objeto

@author    Lucas Nonato
@version   1.xx
@since     21/10/2019
/*/
method addMsg(cArquivo, cBrjCodigo, cMsg, cUnimed) class PTUA500IMP
default cUnimed 	:= ""
default cArquivo 	:= ""
default cBrjCodigo 	:= ""

if !(empty(cBrjCodigo)) .and. !empty(cUnimed)
	BRJ->(DBSetOrder(1))
	if ( BRJ->(MsSeek(xFilial("BRJ")+cBrjCodigo)) )
		cUnimed := BRJ->BRJ_OPEORI
	endif
endif

aadd(::aMsg,{cArquivo, cUnimed, cMsg})

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSP500FIL
fitro da tela inicial

@author    pablo alipio
@since     09/2020
/*/
function PLSP500FIL(lF2)
local cStatus	:= space(1)
local cFiltro := ""
local aPergs  := {}
local aFilter := {}

default lF2 := .f.

aadd( aPergs,{ 2, "Status:"		 	, 	cStatus		,{ "0=Todos","1=Importada","2=Importada e Paga"},100,/*'.T.'*/,.f. } )
aAdd( aPergs,{ 1, "A partir de:"	, 	dDataBase	, "", "", ""		, "", 50, .f.})


cFiltro += "@BRJ_FILIAL = '"+ BRJ->(xFilial("BRJ"))+ "' AND BRJ_REGPRI = '1' AND D_E_L_E_T_ = ' ' "

// tela para selecionar os filtros
if (paramBox( aPergs,"Filtro de Tela",aFilter,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSP500X',/*lCanSave*/.T.,/*lUserSave*/.T. ) )
	
	if (!empty(aFilter[1]) .and. aFilter[1] != "0")
		cFiltro += " AND BRJ_STATUS = '" + aFilter[1] + "' "
	endif

	if (!empty(aFilter[2]))
		cFiltro += " AND BRJ_DATA >= '" + DtoS(aFilter[2]) + "' "
	endif

endif

if (lF2)
	If Valtype(oBrwBRJ) == "O"
		oBrwBRJ:SetFilterDefault(cFiltro)
		oBrwBRJ:Refresh(.T.)
	EndIf
endif

return cFiltro

/*/{Protheus.doc} PLSP500EXC
excluir importação
@author pablo alipio
@since 09/2020
@param  lAutoma = para chamada durante automação
/*/
Function PLSP500EXC(lAutoma)
local cChave    	:= BRJ->BRJ_CODIGO
local cSql 			:= ""
local nI 			:= 0
local aChvBD6 		:= {}
local lRes 			:= .f.
local lExc 			:= .t.
local cDirDocs 		:= ""
local cCdPac := GetNewPar("MV_PLPACPT","99999998")
local lExcB6L     	:= iif ( B6L->( FieldPos("B6L_CODLDP") ) > 0 .and. B6L->( FieldPos("B6L_CODPEG") ) > 0 .and. B6L->( FieldPos("B6L_NUMERO") ) > 0 ;
							 .and. B6L->( FieldPos("B6L_ORIMOV") ) > 0, .t., .f.)

default lAutoma		:= .F.

If BRJ->BRJ_STATUS == "2"
	If !lAutoma
		MsgInfo("Esta importacao não poderá ser excluída porque já foi paga.")
	EndIf
	Return
Endif

If !lAutoma
	lExc := MsgYesNo("Confirma a exclusão da importação?" + CRLF +  "[" + BRJ->BRJ_CODIGO + "] " + BRJ->BRJ_NOMORI  , "Exclusão")
endif

if lExc	
	ACB->(dbSetOrder(2))
	AC9->(dbSetOrder(1))
	BCI->(dbSetOrder(1))
	BX6->(dbSetOrder(1)) //BX6_FILIAL+BX6_CODOPE+BX6_CODLDP+BX6_CODPEG+BX6_NUMERO+BX6_ORIMOV+BX6_SEQUEN+BX6_CODPAD+BX6_CODPRO
	BDX->(dbSetOrder(1)) //BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN+BDX_CODGLO
	BZC->(dbSetOrder(1)) //BZC_FILIAL+BZC_CHVGUI
	// veririca se possui guia que já foi cobrada
	cSql := " SELECT COUNT(*) TOTAL FROM "+RetSqlName("BD6")
	cSql += " WHERE BD6_FILIAL = '"+xFilial("BD6")+"' AND"
	cSql += " BD6_SEQIMP = '"+cChave+"' AND "
	cSql += " (BD6_NUMSE1 <> ' ' OR  BD6_NUMTIT <> ' ' OR BD6_PREFIX <> ' ' OR BD6_TIPTIT <> ' ') AND "
	cSql += " D_E_L_E_T_ = ' '"

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),'Trb',.F.,.T.)

	If Trb->TOTAL > 0
		Trb->(DbCloseArea())
		MsgInfo("Não será possível a exclusão. Existem guias nesta importação que já foram cobradas.")
		Return
	Endif

	Trb->(DbCloseArea())

	Begin Transaction

		procRegua(-1)		

		// exclui arquivo da base de conhecimento
		if MsMultDir()
			cDirDocs := MsRetPath( cFile+cExten )
		else
			cDirDocs := MsDocPath() + "\"
		endIf

		if( FErase(lower(cDirDocs+alltrim(BRJ->BRJ_ARQUIV))) == 0 )
			
			while ACB->(MsSeek(xFilial('ACB')+BRJ->BRJ_ARQUIV))
				
				while AC9->(MsSeek(xFilial("AC9")+ACB->ACB_CODOBJ))
					AC9->(RecLock( "AC9", .F. ))
					AC9->(DbDelete())
					AC9->( MsUnlock() )
				enddo
				ACB->(RecLock( "ACB", .F. ))
				ACB->(DbDelete())
				ACB->( MsUnlock() )
			enddo
		endif

		// excluir a importação (BRJ)
		cSql := " SELECT R_E_C_N_O_ RECNO FROM "+RetSqlName("BRJ")
		cSql += " WHERE BRJ_FILIAL = '"+xFilial("BRJ")+"' AND"
		cSql += " BRJ_CODIGO = '"+cChave+"' AND "
		cSql += " D_E_L_E_T_ = ' '"

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),'TrbBRJ',.F.,.T.)
		if ! TrbBRJ->(Eof())
			BRJ->(DbGoTo(TrbBRJ->RECNO))
			BRJ->(RecLock("BRJ",.F.))
			BRJ->(DbDelete())
			BRJ->(MsUnLock())
			lRes := .t.
		endif
		TrbBRJ->(DbCloseArea())

		cSql := " SELECT R_E_C_N_O_ RECNO FROM "+RetSqlName("BD6")
		cSql += " WHERE BD6_FILIAL = '"+xFilial("BD6")+"' AND "
		cSql += " BD6_SEQIMP = '"+cChave+"' AND "
		cSql += " D_E_L_E_T_ = ' '"

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),'TrbBD6',.F.,.T.)
		While ! TrbBD6->(Eof())
			BD6->(DbGoTo(TrbBD6->RECNO))
			// guardo as chaves dos BD6, caso a exclusão da peg/guia estiver ok, sigo com o exclusão dos itens restantes
			aadd(aChvBD6, {BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO),; // chave para a BZC
				BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO),; //chave para a BDX
				BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO)} ) //chave para BX6

				// exclusão B6L
				if alltrim(BD6->BD6_CODPRO) == alltrim(cCdPac)
					if lExcB6L
						cSql := " SELECT R_E_C_N_O_ RECNO FROM " + retSqlName("B6L")
						cSql += " WHERE B6L_FILIAL = '" + xFilial("B6L") + "' "
						cSql += " AND B6L_OPEMOV = '" + BD6->BD6_CODOPE + "' "
						cSql += " AND B6L_CODLDP = '" + BD6->BD6_CODLDP + "' "
						cSql += " AND B6L_CODPEG = '" + BD6->BD6_CODPEG + "' "
						cSql += " AND B6L_NUMERO = '" + BD6->BD6_NUMERO + "' "
						cSql += " AND B6L_ORIMOV = '" + BD6->BD6_ORIMOV + "' "
						cSql += " AND D_E_L_E_T_ = ' ' "

						dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBB6L",.F.,.T.)

						while !TRBB6L->(Eof())
							B6L->(DBGoTo(TRBB6L->RECNO))

							B6L->(RecLock("B6L",.F.))
							B6L->(DbDelete())
							B6L->( MsUnLock() )

							TRBB6L->(DBSkip())
						enddo

						TRBB6L->(DBCloseArea())
					endif
				endif

			TrbBD6->(DbSkip())
		Enddo
		TrbBD6->(DbCloseArea())

		cSql := " SELECT BCI_CODOPE, BCI_CODLDP, BCI_CODPEG, R_E_C_N_O_ Recno FROM " + RetSqlName("BCI")
		cSql += " WHERE BCI_FILIAL = '"+xFilial("BCI")+"' AND "
		cSql += " BCI_LOTEDI = 'BRJ|" + cChave + "' AND "
		cSql += " D_E_L_E_T_ = ' ' "

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),'TrbBCI',.F.,.T.)
		// exclusão do BCI, BD5, BE4, BD6, BD7 e B43
		while ! TrbBCI->(Eof())
			incProc("Excluindo lote:" + "[" + cChave + "] PEG: [" + TrbBCI->BCI_CODPEG + "]" )
			BCI->(dbgoto(TrbBCI->Recno))
			PLSPROCRGR("BCI",TrbBCI->Recno,K_RetFas,"1",.f.)
			if !PLSDELMOV(TrbBCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG),"1")				
				msgInfo("Não foi possível realizar a exclusão da PEG:" + TrbBCI->BCI_CODPEG)
				TrbBCI->(dbCloseArea())
				disarmTransaction()
				return
			endif
			TrbBCI->(DbSkip())
		enddo
		TrbBCI->(dbCloseArea())
		
		// exclusão dos itens restantes BZC, BDX e BX6
		for nI:=1 to len(aChvBD6)			
			
			If BZC->(MsSeek(xFilial("BZC")+aChvBD6[nI][1]))
				BZC->(RecLock("BZC",.F.))
				BZC->(DbDelete())
				BZC->(MsUnLock())
			EndIf
			
			If BDX->(MsSeek(xFilial("BDX")+aChvBD6[nI][2]))
				BDX->(RecLock("BDX",.F.))
				BDX->(dbDelete())
				BDX->(MsUnlock())
			EndIf
			
			If BX6->(MsSeek(xFilial("BX6")+aChvBD6[nI][3]))
				BX6->(RecLock("BX6",.F.))
				BX6->(dbDelete())
				BX6->(MsUnlock())
			EndIf
		next

		// atualiza os avisos
		cSql := " SELECT R_E_C_N_O_ RECNO FROM "+RetSqlName("B5T")
		cSql += " WHERE B5T_FILIAL = '"+xFilial("B5T")+"' AND"
		cSql += " B5T_SEQIMP = '"+cChave+"' AND "
		cSql += " D_E_L_E_T_ = ' '"
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),'TrbB5T',.F.,.T.)
		while ! TrbB5T->(Eof())
			B5T->(DbGoTo(TrbB5T->RECNO))
			B5T->(RecLock("B5T",.F.))
			B5T->B5T_CODLDP := ""
			B5T->B5T_CODPEG := ""
			B5T->B5T_NUMGUI := ""
			B5T->B5T_VLR500 := 0
			B5T->B5T_VLTXTT := 0
			B5T->B5T_SEQIMP := ""
			B5T->(MsUnLock())
			TrbB5T->(DbSkip())
		EndDo
		TrbB5T->(DbCloseArea())
		cSql := " SELECT R_E_C_N_O_ RECNO FROM "+RetSqlName("B6T")
		cSql += " WHERE B6T_FILIAL = '"+xFilial("B6T")+"' AND"
		cSql += " B6T_SEQIMP = '"+cChave+"' AND "
		cSql += " D_E_L_E_T_ = ' '"
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),'TrbB6T',.F.,.T.)
		while ! TrbB6T->(Eof())
			B6T->(DbGoTo(TrbB6T->RECNO))
			B6T->(RecLock("B6T",.F.))
			B6T->B6T_VLR500 := 0
			B6T->B6T_VLT500 := 0
			B6T->B6T_VLRTAX := 0
			B6T->B6T_SEQIMP := ""
			B6T->(MsUnLock())
			TrbB6T->(DbSkip())
		EndDo
		TrbB6T->(DbCloseArea())
	End Transaction

	
	// atualiza o grid
	if Valtype(oBrwBRJ) == "O"
		oBrwBRJ:Refresh(.T.)
		oBrwBRJ:ExecuteFilter()
	endif

	// encerra
	if lRes
		MsgInfo("Lote cancelado com sucesso")
	endif

endif

return


/*/{Protheus.doc} PLSEXIBPTU
oculta campos
@author pablo alipio
@since 09/2020
@param     cAlias = alias da tabela
@param     cCampo = campo que avalia para exibir/ocultar
/*/
function PLSEXIBPTU(cCampo)
local   lRet	:= .f.
default cCampo 	:= ""

cCampo := alltrim(cCampo)

if cCampo $ "BRJ_CODIGO"		;
	.or. cCampo $ "BRJ_DATA"	;
	.or. cCampo $ "BRJ_ARQIMP"	;
	.or. cCampo $ "BRJ_OPEORI"	;
	.or. cCampo $ "BRJ_NOMORI"	;
	.or. cCampo $ "BRJ_ANO"		;
	.or. cCampo $ "BRJ_MES"		;
	.or. cCampo $ "BRJ_NUMFAT"	;
	.or. cCampo $ "BRJ_NRNDC"  	;
	.or. cCampo $ "BRJ_PREFIX" 	;
	.or. cCampo $ "BRJ_NUMTIT" 	;
	.or. cCampo $ "BRJ_PARCEL" 	;
	.or. cCampo $ "BRJ_TIPTIT" 	;
	.or. cCampo $ "BRJ_PRENDC" 	;
	.or. cCampo $ "BRJ_NUMNDC" 	;
	.or. cCampo $ "BRJ_PARNDC" 	;
	.or. cCampo $ "BRJ_TIPNDC" 	;
	.or. cCampo $ "BRJ_FP2PRE" 	;
	.or. cCampo $ "BRJ_FP2TIT" 	;
	.or. cCampo $ "BRJ_FP2PAR" 	;
	.or. cCampo $ "BRJ_FP2TIP" 	;
	.or. cCampo $ "BRJ_NP2PRE" 	;
	.or. cCampo $ "BRJ_NP2TIT" 	;
	.or. cCampo $ "BRJ_NP2PAR" 	;
	.or. cCampo $ "BRJ_NP2TIP" 	;
	.or. cCampo $ "BRJ_CFTPRE" 	;
	.or. cCampo $ "BRJ_CFTTIT" 	;
	.or. cCampo $ "BRJ_CFTPAR" 	;
	.or. cCampo $ "BRJ_CFTTIP" 	;
	.or. cCampo $ "BRJ_CNDPRE" 	;
	.or. cCampo $ "BRJ_CNDTIT" 	;
	.or. cCampo $ "BRJ_CNDPAR" 	;
	.or. cCampo $ "BRJ_CNDTIP" 

	lRet := .t.
endif

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} geraLogErro
grava arquivo de log

@author   pablo alipio
@since    09/2020
@param    cError = erros encontrados
@param    cFileXML = nome do arquivo com erros
@param    cDirOri = diretório onde se encontro o arquivo com erro(salvamos o log nessa pasta)
/*/
static function geraLogErro( cError, cFileXML, cDirOri)
	local cFileLOG	:= "PTU500.log"
	local nArqLog	:= 0

	default cError   := ""
	default cFileXML := ""
	default cDirOri := ""

	if !(empty(cFileXML))
		cFileLOG	:= substr(cFileXML,1, at(".", cFileXML)-1) + ".log"
	endif

	cError := cValToChar(cError)

	nArqLog		:= fCreate( cDirOri+cFileLOG,FC_NORMAL,,.F. )

	fWrite( nArqLog, cError )
	fClose( nArqLog )

return cFileLOG

//-------------------------------------------------------------------
/*/{Protheus.doc} getTipGui

@author    Lucas Nonato
@version   1.xx
@since     21/10/2019
/*/
function getTipGui(cTipGui)
local cRet := ""

do case 
	case cTipGui == GUIA_CONSULTA
		cRet := "Consulta"
	case cTipGui == GUIA_SADT
		cRet := "SADT"
	case cTipGui == GUIA_INTERNACAO
		cRet := "Internação"
	case cTipGui == GUIA_HONORARIO
		cRet := "Honorarios"
	case cTipGui == GUIA_REC_GLOSA
		cRet := "Reapresentação Tipo I"
endcase

return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} P500GetArq

@author    Lucas Nonato
@version   1.xx
@since     03/11/2020
/*/
function P500GetArq(lAuto,nOpc)
local cExtensao	:= "*.*"
local cMascara	:= "Todos os Arquivos|*.*|"
local cTitulo	:= "Selecione o diretório dos arquivos"
local cTitulo2	:= "Selecione o(s) arquivos(s) a serem importados"
local cDesc		:= "Marca e desmarca todos"
local aDir		:= {}
local aFiles	:= {}
local aMatCol	:= {}
local lOk		:= .f.
local nI        as numeric
local cTitPag1	:= "Deseja informar manualmente Mês/Ano de pagamento?" + CRLF + "Se não informado, será considerado o Mês/Ano atual, conforme padrão"
default nOpc 	:= 1
// browse para selecionar o diretório

cMesAnoG := iif( !lAuto .and. MsgYesNo(cTitPag1, "Atenção"), VldDataPag(FWInputBox("Informe Mês/Ano (MM/AAAA)", "")), cMesAnoA )

if !lAuto
	cDirOri	  := cGetFile(cMascara, cTitulo, , "", .T., GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_LOCALHARD + GETF_RETDIRECTORY)
else
	if nOpc == 2
		cDirOri := "\sigapls\plsp520xtestcase\"
	elseif nOpc == 3
		cDirOri := "\sigapls\plsp550extestcase\"
	elseif nOpc == 4
		cDirOri := "\sigapls\plsp550xtestcase\"	
	else
		cDirOri := "\sigapls\plsp500xtestcase\"
	endif
endif

If Empty(cDirOri) // cancelou o browse de selecao do diretorio
	return {.f.,{},cDirOri}
EndIf

// pega os arquivos do diretório
aDir := directory(cDirOri + cExtensao)

for nI := 1 to len(aDir)
	aadd(aFiles,{aDir[nI][1],DtoC(aDir[nI][3]),aDir[nI][4],AllTrim(transform(aDir[nI][2]/1000,"@E 999,999,999.99"))+" KB",iif(lAuto,.t.,.f.)})
next
// colunas do browse
aAdd( aMatCol,{"Arquivo"	,'@!',200} )
aAdd( aMatCol,{"Data"		,'@!',040} )
aAdd( aMatCol,{"Hora"		,'@!',040} )
aAdd( aMatCol,{"Tamanho"	,'@!',040} )

// browse para selecionar os arquivos
if !lAuto
	lOk := PLSSELOPT( cTitulo2, cDesc, aFiles, aMatCol, MODEL_OPERATION_INSERT,.T.,.T.,.F.)
else
	lOk := .t.
endif

if lOk
	// verifica se algum arquivo foi selecionado
	lOk := aScan(aFiles,{|x| x[len(aFiles[1])] == .T.}) > 0
endIf

return {lOk,aFiles,cDirOri}

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSP500ANA
chamada da rotina PLSA498 para analise das PEGs da importacao selecionada

@author    pablo alipio
@since     11/2020
/*/
function PLSP500ANA(nOpc)
local cSql 		:= ""
local cFiltro := ""

cSql := " SELECT Distinct BCI.R_E_C_N_O_ RECNO FROM " + RetSqlName("BCI") + " BCI "
if nOpc == 3
	cSql += " Inner Join " + RetSqlName("BD6") + " BD6 "
	cSql += " On "
	cSql += " BD6_FILIAL = '" + xFilial("BD6") + "' AND "
	cSql += " BD6_CODOPE = BCI_CODOPE AND "
	cSql += " BD6_CODLDP = BCI_CODLDP AND "
	cSql += " BD6_CODPEG = BCI_CODPEG AND "
	cSql += " BD6_OPEORI = '" + BTO->BTO_OPEORI + "' AND "
	cSql += " BD6.D_E_L_E_T_ = ' ' "
endif
cSql += " WHERE "
cSql += " BCI_FILIAL =  '" + xFilial("BCI") + "' AND "
if nOpc == 3
	cSql += " BCI_LOTEDI = 'BTO|" + BTO->BTO_NUMERO + "' AND "
else
	cSql += " BCI_LOTEDI = 'BRJ|" + BRJ->BRJ_CODIGO + "' AND "
endif
cSql += " BCI.D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBCI",.F.,.T.)


if !TRBBCI->(Eof())
	cFiltro := "@R_E_C_N_O_ IN ( "
	while !TRBBCI->(Eof())
		cFiltro += "'"+ cValToChar(TRBBCI->RECNO) + "',"
		TRBBCI->(dbskip())
	enddo
	cFiltro := substr(cFiltro, 1, len(cFiltro) - 1)
	cFiltro += ")"
endif
TRBBCI->(DBCloseArea())

if !empty(cFiltro)
	PLSA498(, cFiltro)
else
	aviso("Atenção","Opção disponivel somente para novas importações.",{ "Ok" }, 2)
endif

if nOpc == 0 //A500 batch
	setKey(VK_F2 ,{|| cFilter :=  "" })
elseif nOpc == 1 // A500 xml
	setKey(VK_F2 ,{|| PLSP500FIL(.T.) })
elseif nOpc == 2 // A550 xml origem
	setKey(VK_F2 ,{|| PLSP550FIL(.T.) })
elseif nOpc == 3 // A550 xml exec
	setKey(VK_F2 ,{|| PTU550FIL(.T.) })
endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} setB6T

@author    Lucas Nonato
@version   1.xx
@since     17/12/2020
/*/
static function setB6T(cNrLote,cGuiPre,cIdUnic,cTipGui,nValor,nVlrTx)
local cSql := ""

//B6T_FILIAL+B6T_OPEHAB+B6T_NUMLOT+B6T_NMGPRE+B6T_SEQUEN
cSql := " SELECT R_E_C_N_O_ Recno "
cSql += " FROM " + retSqlName("B6T") + " B6T "
cSql += " WHERE B6T_FILIAL = '" + xfilial("B6T") + "'   "
cSql += " AND B6T_OPEHAB = '" + cCodInt + "'   "
cSql += " AND B6T_NUMLOT = '" + cNrLote + "'   "
cSql += " AND B6T_NMGPRE = '" + cGuiPre + "' "
cSql += " AND B6T_IDUNIC = '" + cIdUnic + "' "
cSql += " AND B6T_SEQIMP = ' ' "
cSql += " AND B6T.D_E_L_E_T_ = ' '  "
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TrbB6T",.T.,.T.)	
if !TrbB6T->(eof())
	B6T->(dbgoto(TrbB6T->Recno))	
	if B5T->(msseek(xfilial("B5T")+B6T->B6T_OPEHAB+cTipGui+B6T->B6T_SEQLOT+B6T->B6T_NMGPRE))
		B6T->(RecLock("B6T",.f.))
		B6T->B6T_VLR500 += nValor
		B6T->B6T_VLT500 += nVlrTx
		B6T->B6T_SEQIMP := BRJ->BRJ_CODIGO
		B6T->(MsUnLock())

		B5T->(RecLock("B5T",.f.))
		B5T->B5T_VLR500 += nValor
		B5T->B5T_VLTXTT += nVlrTx
		B5T->(MsUnLock())
	endif
endif
TrbB6T->(dbclosearea())

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSP500LOT
gerar lote de pagamento

@author    pablo alipio
@since     12/2020
/*/
function PLSP500LOT()

local nRecBAU		:= 0

local cNomSem		:= ""
local nHdlLock	:= 0
local cSql 			:= ""
local lProcessa := .t.
local cAlias 		:= ""
local aPergAux  := {}
local lContinua := .f.

private lFirst		:= .T.
private cMarca    := GetMark()
private cCadastro := "Lotes de Pagamentos da Rede de Atendimento"

private cPerg      	:= "PLA470"
private dDataPagto 	:= cTod("")
private cCodDC     	:= ""
private lCalcImp   	:= .F.
private nApUsDif   	:= 0
private cExcPeg		:= ""
private cNoExcPeg	:= ""

private cAno       	:= ""
private cMes       	:= ""
private dVencto    	:= ctod("")
private cFiltro    	:= ""
private cHisTit    	:= ""
private dDatMvIni  	:= ctod("")
private dDatMvFin  	:= ctod("")
private cLocDigIn  	:= ""
private cLocDigFi  	:= ""
private cCodPegIn  	:= ""
private cCodPegFi  	:= ""
private cNumMovIn  	:= ""
private cNumMovFi  	:= ""
private cCodOpe    	:= PLSINTPAD()
private cCdEmpDeS  	:= ""
private cCdEmpAteS 	:= ""
private cExcessao  	:= ""
private lGerPagBlo 	:= .F.
private cLoteImp   	:= ""
private cCodDC1    	:= ""
private cCodDC2    	:= ""
private cCodDC3    	:= ""
private cCodDC4    	:= ""
private cCodDC5    	:= ""
private cCodDC6    	:= ""
private cCodNat    	:= ""
private lGuiCob    	:= .F.
private cCopCre    	:= ""
private cRdaDe     	:= ""
private cRdaAte    	:= ""
private cGrpPag    	:= ""
private cProcDe		:= ""
private cProcAte	:= ""
private lAneste	    := .F.
private lRmbPTU	    := .F.

if BRJ->BRJ_STATUS == '2'
	MsgAlert("Este lote já foi gerado.")
endif

cSql := " SELECT BCI_CODOPE, BCI_CODLDP, BCI_CODPEG, BCI_STTISS, BCI_CODRDA, BCI_ANO, BCI_MES, BCI_CODPEG, "
cSql += " BCI_CODRDA, BCI_TIPGUI FROM " + RetSqlName("BCI")
cSql += " WHERE "
cSql += " BCI_FILIAL =  '" + xFilial("BCI") + "' AND "
cSql += " BCI_LOTEDI = 'BRJ|" + BRJ->BRJ_CODIGO + "' AND "
cSql += " D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBPEG",.F.,.T.)

if !TRBPEG->(Eof())
	cNomSem		:= "LiberaPagamento_PEG_" + xFilial("BCI")  + TRBPEG->(BCI_CODOPE + BCI_CODLDP + BCI_CODPEG)

	if TRBPEG->BCI_TIPGUI == GUIA_INTERNACAO
		cAlias := 'BE4'
	else
		cAlias := 'BD5'
	endif

	cSql := " SELECT "+cAlias+"_FASE FROM " + RetSqlName(cAlias) + " "
	cSql += " WHERE "
	cSql += cAlias+"_FILIAL = '" + xFilial(cAlias) + "' AND "
	cSql += cAlias+"_CODOPE = '" + TRBPEG->BCI_CODOPE + "' AND "
	cSql += cAlias+"_CODLDP = '" + TRBPEG->BCI_CODLDP + "' AND "
	cSql += cAlias+"_CODPEG = '" + TRBPEG->BCI_CODPEG + "' AND "
	cSql += cAlias+"_FASE <> '3' AND "
	cSql += " D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBGUI",.F.,.T.)

	if !TRBGUI->(Eof())
		lProcessa := .f.
	endif
	TRBGUI->(DBCloseArea())

	if !lProcessa
		MsgAlert("Todas as guias devem estar na fase pronta.")
		TRBPEG->(DBCloseArea())
		return
	endif
	// marca BAU para ser utilizado na rotina de geração de lote
	BAU->(dbSetOrder(1)) //BAU_FILIAL+BAU_CODIGO
	If BAU->(MsSeek(xFilial("BAU")+TRBPEG->BCI_CODRDA))
		RecLock("BAU",.F.)
		BAU->BAU_OK := cMarca
		BAU->(MsUnlock())

		nRecBAU:= BAU->(Recno())
	EndIf

	nHdlLock := PLSAbreSem(cNomSem, .F.)

	If nHdlLock == -1
		MsgAlert("Existe outro processo de liberação para pagamento para esta mesma PEG.")
		TRBPEG->(DBCloseArea())
		return
	EndIf


	Pergunte(cPerg, .f., /*cTitle*/, /*lOnlyView*/, /*oDlg*/, /*lUseProf*/, @aPergAux)

	// variaveis private utilizadas na rotina padrao
	cLoteImp := BRJ->BRJ_CODIGO
	cRdaDe   := TRBPEG->BCI_CODRDA
	cRdaAte  := TRBPEG->BCI_CODRDA

	mv_par19 := cLoteImp
	mv_par29 := cRdaDe
	mv_par30 := cRdaAte

	__SaveParam(cPerg, aPergAux)

	lContinua := Pergunte(cPerg, .t.)

	if ( lContinua )
		cAno       := mv_par01
		cMes       := mv_par02
		dVencto    := iif( empty(mv_par03), PLSCHKNCAL(), mv_par03)
		cFiltro    := allTrim(mv_par04)
		cHisTit    := mv_par05
		dDatMvIni  := mv_par06
		dDatMvFin  := mv_par07
		cLocDigIn  := mv_par08
		cLocDigFi  := mv_par09
		cCodPegIn  := mv_par10
		cCodPegFi  := mv_par11
		cNumMovIn  := mv_par12
		cNumMovFi  := mv_par13
		cCodOpe    := mv_par14
		cCdEmpDeS  := mv_par15
		cCdEmpAteS := mv_par16
		cExcessao  := mv_par17
		lGerPagBlo := mv_par18==1
		cCodDC1    := mv_par20
		cCodDC2    := mv_par21
		cCodDC3    := mv_par22
		cCodDC4    := mv_par23
		cCodDC5    := mv_par24
		cCodDC6    := mv_par25
		cCodNat    := mv_par26
		lGuiCob    := mv_par27==1
		cCopCre    := fMntPAR24(mv_par28)
		cGrpPag    := AllTrim(mv_par31)
		cProcDe    := mv_par33
		cProcAte   := mv_par34
		//Caso a Operadora não utilize a regra de PTU de reembolso,
		//o preenchimento do Pergunte não irá interferir na rotina.
		If GetNewPar("MV_PLRPTU", .F.)
			lRmbPTU	   := mv_par41==1
		else
			lRmbPTU := .F.
		endIf

		// gerar contas a pagar aos credenciados
		A470TitMar(Nil,.f.)

		// exclui arquivo de semáforo da Thread
		PLSFechaSem(nHdlLock,cNomSem)

		//Desmarca BAU marcado
		If !Empty(nRecBAU)
			BAU->(dbGoto(nRecBAU))

			RecLock("BAU",.F.)
			BAU->BAU_OK := ""
			BAU->(MsUnlock())
		EndIf

		BAU->(dbCloseArea())
	endif
endif

TRBPEG->(DBCloseArea())

return


//-------------------------------------------------------------------
/*/{Protheus.doc} fMntPAR24

@author    pablo alipio
@since     12/2020
/*/
Static Function fMntPAR24(mv_par24)
Local i := 1
local cNewStr := ""

For i := 1 To Len(AllTrim(mv_par24))
	If SubStr(mv_par24, i, 1) <> "*"
		cNewStr += IIf(Empty(cNewStr), "", ",") + SubStr(mv_par24, i, 1)
	EndIf
Next i

Return cNewStr

//-------------------------------------------------------------------
/*/{Protheus.doc} removeMeta
Remove metadados do XML para evitar erro no Parse em caso de ausência de NS
Quando a falha na classe for resolvido, essa função não será mais necessária
@author    Eduardo Bento
@since     07/2021
/*/
function removeMeta(cNoMain,cArquivo, lLocaliza, cTexto)
Local cBuffer	:= ""
local cRetXml	:= ""
local nHandle	:= 0
local nPos		:= 0
local lAchei	:= .F.
default cNoMain	:= ""
default cTexto 	:= "http"
default lLocaliza	:= .f.

nHandle := FT_FUse(cArquivo)

if nHandle > 0
	while ( !FT_FEof() )
		cBuffer := FT_FREADLN()				//Leio linha a linha
		if cTexto $ cBuffer	.and. !lAchei	//Quando encontro o trecho que da problema, o elimino
			if !lLocaliza
				nPos := At(cNoMain,cBuffer)  
				cBuffer	:= Substr(cBuffer,1,nPos+len(cNoMain)-1) + ">"	
				lAchei := .t.
			else
				lAchei := iif( cNoMain $ cBuffer, .t., .f.)
				exit
			endif 
		endif
		cRetXml += cBuffer
		FT_FSkip()
		if !FT_FEof()
			cRetXml += CRLF					//Constroi arquivo na string para ser parseado
		endIf
	endDo
endif

return iif(!llocaliza, cRetXml, lAchei)


//-------------------------------------------------------------------
/*/ {Protheus.doc} VldDataPag
Valida a data informada pelo usuário no FWInputBox, caso queira que nos campos de data de pagamento tenham
valores diferentes do database, igual ocorria no A500 batch
@since 01/2022
@version P12 
/*/
//-------------------------------------------------------------------
static function VldDataPag(cDataInf)
local lErroDt	:= .t.
local aValorP	:= {}
local nAnoCon	:= year(date())
local nDifAno	:= 5
local cDatTemp	:= ""

if !empty(cDataInf)
	cDatTemp := strtran(cDataInf, "/", "")
	if len(cDatTemp) == 6 .and. isNumeric(cDatTemp)
		aValorP := { left(cDatTemp,2), right(cDatTemp,4) }
		if !( ( val(aValorP[1]) > 12 .or. val(aValorP[1]) < 1) .or. ( val(aValorP[2]) > nAnoCon + nDifAno .or. val(aValorP[2]) < nAnoCon - nDifAno ) )
			lErroDt := .f.
		endif
	endif
endif

cDatainf := iif( lErroDt, cMesAnoA, aValorP[1] + "/" + aValorP[2] )

return cDataInf


//-------------------------------------------------------------------
/*/{Protheus.doc} NotaFiscal

@author  Thiago Rodrigues
@version P12
@since   29/04/2022
/*/
method NotaFiscal(cBrjCodigo,nTpCob,cUniOri) class PTUA500IMP
local nX 	       := 1
local cTagItOri    := ""
local cTagItem     := ""
local cCodPad      := ""
local cCodPro      := ""
local cDes500      := ""
local aRetData     := {}
local cCodPro2     := ""
local nValApr      := 0
local nTxAp        := 0
local nQtd         := 0 

Default cBrjCodigo := BRJ->BRJ_CODIGO
Default nTpCob     := BRJ->BRJ_TPCOB

while ::hasNext(nX) //Quantidade de NF's

	::CabNF(cBrjCodigo,nTpCob,cUniOri) //dados do cabeçalho 

	//Adiciona o namespace para pegar os dados de OPME
	cTagItem  := ::cPathG + addNS("/Infor_OPME")
	cTagItOri := cTagItem

	while ::hasNextEv(@cTagItem,cTagItOri) //Cabeçalho + Eventos 
		aadd(::aBD6,{})
		aadd(::aBX6,{})
		aadd(::aB43,{})
		aadd(::aVlr,{})
		aadd(::aTpParc,{})
		
		//Procedimentos
		aadd(::aBX6[::nX], {"BX6_SEQPTU", oXML:XPathGetNodeValue( cTagItem+addNS("/Procedimentos/seq_item"))})
		aadd(::aBX6[::nX], {"BX6_IDUNIC", oXML:XPathGetNodeValue( cTagItem+addNS("/Procedimentos/id_itemUnico"))})

		cCodPad := oXML:XPathGetNodeValue( cTagItem+addNS("/Procedimentos/tp_Tabela"))
		cCodPro := oXML:XPathGetNodeValue( cTagItem+addNS("/Procedimentos/cd_Servico"))
		cDes500 := oXML:XPathGetNodeValue( cTagItem+addNS("/Procedimentos/ds_Servico"))	
		dDtExec := oXML:XPathGetNodeValue( cTagItem+addNS("/dt_Execucao"))

		aRetData := retData(dDtExec)

		cCodPro2 := cCodPro
		if  cCodPad == "00" .and. len(cCodPro) == 10
			cCodPro := substr(cCodPro,3,8)
		endif

		::dePara(@cCodPad,@cCodPro,,dDtExec,cCodPro2)
		aadd(::aBD6[::nX], {"BD6_CODPAD", cCodPad})
		aadd(::aBD6[::nX], {"BD6_CODPRO", cCodPro})
		aadd(::aBD6[::nX], {"BD6_DATPRO", aRetData[1]})
		aadd(::aBD6[::nX], {"BD6_HORPRO", aRetData[2]})

		aadd(::aCabec, {"BD5_DATPRO", aRetData[1]})
		aadd(::aCabec, {"BD5_HORPRO", aRetData[2]})

		nValApr:= val((oXML:XPathGetNodeValue( cTagItem+addNS("/valores_fornecedor/vl_ServCobrado"))))
		nTxAP  := val((oXML:XPathGetNodeValue( cTagItem+addNS("/valores_fornecedor/tx_AdmServico"))))
		nQtd   := val((oXML:XPathGetNodeValue( cTagItem+addNS("/Procedimentos/qt_Cobrada"))))

		//Os com valores zerados não são usados na "Guia" de nota fiscal
		//Mantido aqui para gravar corretamente o BD7 e para uso na exportação do a550
		aadd(::aVlr[::nX], nValApr + nTxAP )
		aadd(::aVlr[::nX], 0 ) 
		aadd(::aVlr[::nX], 0 )
		aadd(::aVlr[::nX], nTxAP )
		aadd(::aVlr[::nX], 0 )
		aadd(::aVlr[::nX], 0 )

		aadd(::aBD6[::nX], {"BD6_VALORI", nValApr})
		aadd(::aBD6[::nX], {"BD6_VLRAPR", nValApr/nQtd})
		aadd(::aBD6[::nX], {"BD6_VLTXAP", nTxAP})
		aadd(::aBD6[::nX], {"BD6_QTDPRO", nQtd})

		if !(empty(cDes500))
			aadd(::aBD6[::nX], {"BD6_DES500", cDes500})
		endif
		
		::nX++
	enddo
	::gravaGuia()
	nX++
enddo

return


//-------------------------------------------------------------------
/*/{Protheus.doc} CabNF

@author  Thiago Rodrigues
@version P12
@since   29/04/2022
/*/
method CabNF(cBrjCodigo,nTpCob,cUniOri,cNF) class PTUA500IMP
local cAutoriza := oXML:XPathGetNodeValue(self:cPathG+addNS("/nr_Autorizacao"))
local cGuiPri   := oXML:XPathGetNodeValue(self:cPathG+addNS("/nr_GuiaTissPrincipal"))
local cUniInter	:= oXML:XPathGetNodeValue( addNS("/ptuA500/cabecalho/unimed/cd_Uni_Origem") )
local cMatric 	:= strzero(val(oXML:XPathGetNodeValue( ::cPathG + addNS("/dadosBeneficiario/cd_Unimed"))),4) + oXML:XPathGetNodeValue( ::cPathG + addNS("/dadosBeneficiario/id_Benef"))
local cUniOri 	:= strzero(val(oXML:XPathGetNodeValue( ::cPathG + addNS("/dadosBeneficiario/cd_Unimed"))),4)
local cChaveSol := "" //Chave Solicitação de autorização
local cNF       := oXML:XPathGetNodeValue( ::cPathG +addNS("/Pago_Fornecedor/nr_NotaFiscalFornecedor"))

//Busca e grava os dados do beneficiário
aDadUsr := PGetBenef(::aCabec,::aBD6Gen, cMatric, , cGuiPri, cUniInter, cUniOri  )

aadd(::aCabec,  {"BD5_GUIPRI",cGuiPri})
aadd(::aBD6Gen, {"BD6_MATCOB", cMatric})
aadd(::aBD6Gen, {"BD6_NF",cNF})
aadd(::aCabec,  {"BD5_GUIJUR", PLS0Or1(oXML:XPathGetNodeValue(self:cPathG+addNS("/id_Liminar")))})
aadd(::aBD6Gen, {"BD6_NRAOPE",cAutoriza})

//Verifica se existe solicitação de autorização
cChaveSol := PlChvAut(cAutoriza)

//Se achou a autorização, temos mais dados para por na 'guia'
if  !empty(cChaveSol)
	
	BEA->(dbsetorder(1))

	if BEA->( msSeek( xFilial("BEA") + cChaveSol ) )
		//Cabeçalho 
		aadd(::aCabec, {"BD5_TIPPAC",BEA->BEA_TIPPAC})
		aadd(::aCabec, {"BD5_TIPCON",BEA->BEA_TIPCON})
		aadd(::aCabec, {"BD5_TIPADM",BEA->BEA_TIPADM})
		aadd(::aCabec, {"BD5_TIPATE",BEA->BEA_TIPATE})
		aadd(::aCabec, {"BD5_INDACI",BEA->BEA_INDACI})
		aadd(::aCabec, {"BD5_NUMIMP",BEA->BEA_NUMIMP})
		aadd(::aCabec, {"BD5_DATSOL",BEA->BEA_DATSOL})

		if !empty(BEA->BEA_REGSOL)
            aadd(::aCabec, {"BD5_OPESOL",  BEA->BEA_OPESOL}) 
            aadd(::aCabec, {"BD5_ESTSOL",  BEA->BEA_ESTSOL}) 
            aadd(::aCabec, {"BD5_SIGLA",   BEA->BEA_SIGLA}) 
            aadd(::aCabec, {"BD5_REGSOL",  BEA->BEA_REGSOL}) 
            aadd(::aCabec, {"BD5_NOMSOL",  BEA->BEA_NOMSOL}) 
            aadd(::aCabec, {"BD5_CDPFSO",  BEA->BEA_CDPFSO}) 
        endif
        aadd(::aCabec, {"BD5_NRAOPE",  BEA->BEA_NRAOPE}) 
        aadd(::aCabec, {"BD5_SENHA",   BEA->BEA_SENHA})

		//Evento
		aadd(::aBD6Gen, {"BD6_RDAEDI",BEA->BEA_RDAEDI})
		aadd(::aBD6Gen, {"BD6_NOMEDI",BEA->BEA_NOMEDI})

		//participação/Unidade do Evento
		aadd(::aBD7Gen, {"BD7_SIGLA", BEA->BEA_SIGEXE})
		aadd(::aBD7Gen, {"BD7_NOMPRE",BEA->BEA_NOMEXE})
		aadd(::aBD7Gen, {"BD7_ESTPRE",BEA->BEA_ESTEXE})
		aadd(::aBD7Gen, {"BD7_REGPRE",BEA->BEA_REGEXE})
	endif
	BEA->(DbCloseArea())
endif
return


/*/{Protheus.doc} PlChvAut
	(long_description)
	@type  Static Function
	@author user
	@since 22/07/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function PlChvAut(cAutoriza)
local cChave := ""

//Verifica se encontra a autorização
if !Empty(cAutoriza)
	
	cSql := " SELECT BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+BEA_DATPRO+BEA_HORPRO chave"
	cSql += " FROM " + retSqlName("BEA")
	cSql += " WHERE BEA_FILIAL = '" + xFilial("BEA") + "' "
	cSql += " AND BEA_NRAOPE = '" + cAutoriza + "' "
	cSql += " AND BEA_OPESOL <> '" + PLSINTPAD()+  "' "
	cSql += " AND D_E_L_E_T_=' ' "
	
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"AliasBEA",.f.,.t.)

	if !AliasBEA->(eof())
		cChave := AliasBEA->(chave)
	endif
	
	AliasBEA->(dbCloseArea())	
endif

Return cChave


//-------------------------------------------------------------------
/*/ {Protheus.doc} reapresentacao
Método para verificar se o item é de reapreesentação e gravar os campos novos do AJIUS
@since 08/2022
@version P12 
/*/
//-------------------------------------------------------------------
method reapresentacao() class PTUA500IMP
local cTag 		:= ::cPathG + addNS("/reapresentacaoGlosado")

if lCmpReapr
	if oXML:XPathHasNode(cTag)
		aadd(::aBX6[::nX], {"BX6_REAPRE", "1"})
		aadd(::aBX6[::nX], {"BX6_DOC1GL", oXML:XPathGetNodeValue( cTag+addNS("/nr_DOC1Glosado" ))})
		aadd(::aBX6[::nX], {"BX6_DOC2GL", oXML:XPathGetNodeValue( cTag+addNS("/nr_DOC2Glosado" ))})

	elseif upper(::cCodExcTp) == "I"
		aadd(::aBX6[::nX], {"BX6_REAPRE", "1"})	
	endif
endif	

return
