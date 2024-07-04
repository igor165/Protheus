#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE "APWIZARD.CH"

#DEFINE CRLF chr( 13 ) + chr( 10 )

//------------------------------------------------
/*/{Protheus.doc} PLSA447
Função voltada para Cadastro de Versões da TISS

@author    Everton M. Fernandes
@version   V11
@since     03/05/2013
/*/
function PLSA447()
local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('BVV')
oBrowse:SetDescription( 'Versões TISS' )
oBrowse:Activate()

Return NIL

//------------------------------------------------
/*/{Protheus.doc} ModelDef
Define o modelo de dados da aplicação  

@author    Bruno Iserhardt
@version   V11
@since     02/08/2013
/*/
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruBVV := FWFormStruct( 1, 'BVV', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruBVP := FWFormStruct( 1, 'BVP' ) //Variaveis TISS
Local oStruBVR := FWFormStruct( 1, 'BVR' ) //Validação das Transações TISS
// Modelo de dados construído
Local oModel   := MPFormModel():New('PLSA447', /*bPreValidacao*/, /*bPosValidacao*/, , /*bCancel*/ ) //
// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'BVVMASTER', /*cOwner*/, oStruBVV, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
// Adiciona ao modelo uma componente de grid
oModel:AddGrid( 'BVPDETAIL', 'BVVMASTER', oStruBVP )

oModel:AddGrid( 'BVRDETAIL', 'BVVMASTER', oStruBVR )

// Faz relacionamento entre os componentes do model
oModel:SetRelation( 'BVPDETAIL', {	{ 'BVP_FILIAL'	, 'xFilial( "BVP" )'	},;
       								{ 'BVP_TISVER'	, 'BVV_TISVER' 		} }, BVP->( IndexKey( 1 ) ) )

oModel:SetRelation( 'BVRDETAIL', {	{ 'BVR_FILIAL'	, 'xFilial( "BVR" )'	},;
       								{ 'BVR_TISVER'	, 'BVV_TISVER' 		} }, BVR->( IndexKey( 1 ) ) )

oModel:SetPrimaryKey( {"BVV_FILIAL", "BVV_TISVER"} )

// Adiciona a descricao do Modelo de Dados
oModel:GetModel( 'BVVMASTER' ):SetDescription( 'Versões TISS' )
oModel:GetModel( 'BVPDETAIL' ):SetDescription( 'Variáveis' )
oModel:GetModel( 'BVRDETAIL' ):SetDescription( 'Validação das Transações' )

//BVP não é obrigatoria
oModel:GetModel('BVPDETAIL'):SetOptional(.T.)
oModel:GetModel('BVRDETAIL'):SetOptional(.T.)
Return oModel

//------------------------------------------------
/*/{Protheus.doc} MenuDef
Define o menu da aplicação 

@author    Everton M. Fernandes
@version   V11
@since     03/05/2013
/*/
static function MenuDef()
Local aRotina := {}
ADD OPTION aRotina Title 'Visualizar'			Action 'VIEWDEF.PLSA447' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Incluir' 				Action 'VIEWDEF.PLSA447' OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar' 				Action 'VIEWDEF.PLSA447' OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir' 				Action 'VIEWDEF.PLSA447' OPERATION 5 ACCESS 0
ADD OPTION aRotina Title 'Imprimir' 			Action 'VIEWDEF.PLSA447' OPERATION 8 ACCESS 0
ADD OPTION aRotina Title 'Atualizar TISS'		Action 'PLSA447ATT' OPERATION 2 ACCESS 0

Return aRotina

//------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicação 

@author    Everton M. Fernandes
@version   V11
@since     03/05/2013
/*/
Static Function ViewDef()
Local oStruBVV 	:= FWFormStruct( 2, 'BVV' )
Local oStruBVP 	:= FWFormStruct( 2, 'BVP' ) 
Local oStruBVR 	:= FWFormStruct( 2, 'BVR' ) 
Local oModel   	:= FWLoadModel( 'PLSA447' )
local lExstAce	:= BVV->(FieldPos("BVV_ACEITA")) > 0
Local oView

oStruBVP:RemoveField('BVP_TISVER')
oStruBVR:RemoveField('BVR_TISVER')

oModel:SetPrimaryKey( {"BVV_FILIAL", "BVV_TISVER"} )

oView := FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_BVV', oStruBVV, 'BVVMASTER' )

oView:AddGrid( 'VIEW_BVP', oStruBVP, 'BVPDETAIL' )
oView:AddGrid( 'VIEW_BVR', oStruBVR, 'BVRDETAIL' )

oModel:GetModel( 'BVPDETAIL' ):SetUniqueLine( { 'BVP_NOMVAR', 'BVP_TISVER'  } )
oModel:GetModel( 'BVRDETAIL' ):SetUniqueLine( { 'BVR_TRANS' , 'BVR_TISVER'  } )

oView:CreateHorizontalBox( 'SUPERIOR', 30 )
oView:CreateHorizontalBox( 'INFERIOR', 70 )

oView:CreateFolder( 'PASTA_INFERIOR' ,'INFERIOR' )

oView:AddSheet( 'PASTA_INFERIOR'    , 'ABA_VARIAVEIS'    , "Variáveis" ) 
oView:AddSheet( 'PASTA_INFERIOR'    , 'ABA_TRANSACOES'    , "Validação das Transações" ) 

oView:CreateVerticalBox( 'BOX_VARIAVEIS',  100,,, 'PASTA_INFERIOR', 'ABA_VARIAVEIS' )
oView:CreateVerticalBox( 'BOX_TRANSACOES', 100,,, 'PASTA_INFERIOR', 'ABA_TRANSACOES' )

oView:SetOwnerView( 'VIEW_BVV', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_BVP', 'BOX_VARIAVEIS' )
oView:SetOwnerView( 'VIEW_BVR', 'BOX_TRANSACOES' )

if lExstAce
	oStruBVV:SetProperty('BVV_ACEITA', MVC_VIEW_TITULO, "Acata XML de Recurso Glosa")
endif

Return oView

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSA447ATT
Wizard de Atualização TISS

@author    Lucas Nonato
@version   V12
@since     20/12/2019
/*/
function PLSA447ATT
local aArea    	:= GetArea()
local cRet		:= ""
local aUrlPath  := Separa(getNewPar("MV_PLURTIS", "https://arte.engpro.totvs.com.br,/public/sigapls/TISS/"), ",")
local cURL    	:= ""
local cPath   	:= ""
local aRetVersao:= {}

private lSel    := .t.
private lTerm	:= .t.
private lBVN 	:= .t.
private lB7B 	:= .t.
private lSchm	:= .t.
private lBA0 	:= .t.
private lBAU 	:= .t.
private aVersao	:= {,,}

if len(aUrlPath) == 2 .and. (!empty(aUrlPath[1]) .and. !empty(aUrlPath[2]))
	cURL	:= aUrlPath[1]
	cPath	:= aUrlPath[2]+"Terminologias/"
else
	MsgInfo("O parâmetro MV_PLURTIS está vazio na base." + CRLF + "Preencha o valor do parâmetro, conforme documentação da rotina.", "Atenção")		
	return
endif

//Busca Versão Atual
aRetVersao	:= PLSGETREST(cURL,cPath+"VersaoComunicacao.txt",,.F.,"")
aVersao[1]	:= aRetVersao[1]
aVersao[2]	:= aRetVersao[2]
aVersao[3]	:= PLSGETREST(cURL,cPath+"VersaoMonitoramento.txt",,.F.,"")[2]

If !aVersao[1] 
	msgInfo(aRetVersao[2],"Erro")
	Return
Endif

oWizard := APWizard():New( "Ferramenta de Atualização da Versão TISS",;
 "Automação de virada de versão TISS",;
 "Ferramenta de Atualização da Versão TISS",;
 "Essa ferramenta irá atualizar o SIGAPLS para a versão "+aVersao[2]+" da TISS.", {||.T.}, {||.T.}, .F., Nil, {|| .T.}, Nil, {00,00,450,600} )

//Painel 2 - Seleção das opções de verificação
oWizard:NewPanel( "Ferramenta de Atualização da Versão TISS"               ,; //"Itens a Validar"
					"Selecione o(s) iten(s) que deseja atualizar"          ,; 
					{||.T.}               ,; //<bBack>
					{| lEnd| fExecuta(@lEnd,@cRet)} ,; //<bNext>
					{||.F.}               ,; //<bFinish>
					.T.                   ,; //<.lPanel.>
					{|| fGetOpcoes()}   )    //<bExecute>		

//Painel 3 - Acompanhamento do Processo
oWizard:NewPanel(	"Ferramenta de Atualização da Versão TISS"     	,; //"Realizando validação na base"
					"Resumo do processamento"           			,; 	//"Após gerar o log clique em finalizar para encerrar a operação."
					{||.F.}                 ,; 	//<bBack>
					{||.F.}                 ,; 	//<bNext>
					{||.T.}                 ,; 	//<bFinish>
					.T.                     ,; 	//<.lPanel.>
					{|| fRet(cRet)}   )			//<bExecute>


oWizard:Activate( .T.,{||.T.},{||.T.},	{||.T.})
RestArea(aArea)
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} fGetOpcoes
Wizard de Atualização TISS

@author    Lucas Nonato
@version   V12
@since     20/12/2019
/*/
static function fGetOpcoes()

local aCoords:= {}
local oPanel    := oWizard:oMPanel[oWizard:nPanel]

aCoords := RetCoords(2,8,150,20,2,,,,{0,0,oPanel:oWnd:nTop*0.92,oPanel:oWnd:nLeft*0.88})

//Marca os itens de validação
TcheckBox():New(aCoords[01][1], aCoords[01][2], "Terminologias"							,{|| lTerm 	},oPanel, 300,10,,{|| lTerm := !lTerm	},,,,,,.T.,,,) 
TcheckBox():New(aCoords[03][1], aCoords[03][2], "Regras de Importação XML"				,{|| lBVN  	},oPanel, 300,10,,{|| lBVN  := !lBVN   	},,,,,,.T.,,,)
TcheckBox():New(aCoords[05][1], aCoords[05][2], "Guias Portal"							,{|| lB7B  	},oPanel, 300,10,,{|| lB7B  := !lB7B   	},,,,,,.T.,,,)
TcheckBox():New(aCoords[07][1], aCoords[07][2], "Schemas"								,{|| lSchm	},oPanel, 300,10,,{|| lSchm := !lSchm 	},,,,,,.T.,,,) 
TcheckBox():New(aCoords[09][1], aCoords[09][2], "Cadastro operadoras"					,{|| lBA0  	},oPanel, 300,10,,{|| lBA0  := !lBA0   	},,,,,,.T.,,,)
TcheckBox():New(aCoords[11][1], aCoords[11][2], "Cadastro prestadores"					,{|| lBAU  	},oPanel, 300,10,,{|| lBAU  := !lBAU   	},,,,,,.T.,,,)

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} fRet
Wizard de Atualização TISS

@author    Lucas Nonato
@version   V12
@since     20/12/2019
/*/
static function fRet(cRet)
local aCoords:= {}
local oPanel    := oWizard:oMPanel[oWizard:nPanel]

aCoords := RetCoords(2,8,150,20,2,,,,{0,0,oPanel:oWnd:nTop*0.92,oPanel:oWnd:nLeft*0.88})
@ aCoords[01][1], aCoords[01][2] SAY cRet OF oPanel SIZE 150, 150 PIXEL 

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} fExecuta
Wizard de Atualização TISS

@author    Lucas Nonato
@version   V12
@since     20/12/2019
/*/
static function fExecuta(lEnd,cRet,lAuto)
local aUrlPath := Separa(getNewPar("MV_PLURTIS", "https://arte.engpro.totvs.com.br,/public/sigapls/TISS/"), ",")
local cURL    	:= aUrlPath[1]
local cPath   	:= aUrlPath[2]
local cSql   	:= ""
local cDirWiz	:= PLSMUDSIS("\plswizard\")
local cDirRaiz	:= PLSMUDSIS( GetNewPar("MV_TISSDIR","\TISS\") )
local cDirSchm 	:= PLSMUDSIS( cDirRaiz+"SCHEMAS\" )
local aDirW		:= {}
local nX		:= 0
local cVersPto	:= strtran(aVersao[2],"_",".")

default cRet 	:= ""
default lAuto	:= .f.

aDirW := directory( cDirWiz + "*.csv" )
for nX := 1 to len(aDirW)
	fErase(cDirWiz + aDirW[nX][1] )
next

if lTerm
	cErro := "Terminologias: " + PLSA444REC(.t.,cVersPto)	+ CRLF
	logErro("Importação Terminologias: ",cErro,@cRet)
endif

if lBVN
	cErro := PLSGETREST(cURL,cPath+"Wizard/"+"bvn-configuracao_da_validacao_do_xml_tiss.csv"	,,.t.,cDirWiz+"bvn-configuracao_da_validacao_do_xml_tiss.csv")[3]
	logErro("Importação tabelas importação XML: ",cErro,@cRet)
endif

if lB7B
	cErro :=  PLSGETREST(cURL,cPath+"Wizard/"+"b7a-cfg_impressao_guias_tiss.csv"		,,.t.,cDirWiz+"b7a-cfg_impressao_guias_tiss.csv")[3]
	cErro +=  PLSGETREST(cURL,cPath+"Wizard/"+"b7b-estrutura_impressao_guias_tiss.csv"	,,.t.,cDirWiz+"b7b-estrutura_impressao_guias_tiss.csv")[3]
	cErro +=  PLSGETREST(cURL,cPath+"Wizard/"+"b7c-grupos_de_campos.csv"				,,.t.,cDirWiz+"b7c-grupos_de_campos.csv")[3]
	logErro("Importação tabelas portal: ",cErro,@cRet)
endif

if lSchm
	cErro := PLSGETREST(cURL,cPath+"Schemas/"+"tissAssinaturaDigital_v1.01.xsd"							,,.t.,cDirSchm+"tissAssinaturaDigital_v1.01.xsd")[3]
	cErro += PLSGETREST(cURL,cPath+"Schemas/"+"tissCancelaGuiaV"+aVersao[2]+".wsdl"						,,.t.,cDirSchm+"tissCancelaGuiaV"+aVersao[2]+".wsdl")[3]
	cErro += PLSGETREST(cURL,cPath+"Schemas/"+"tissComplexTypesMonitoramentoV"+aVersao[3]+".xsd"		,,.t.,cDirSchm+"tissComplexTypesMonitoramentoV"+aVersao[3]+".xsd")[3]
	cErro += PLSGETREST(cURL,cPath+"Schemas/"+"tissComplexTypesV"+aVersao[2]+".xsd"						,,.t.,cDirSchm+"tissComplexTypesV"+aVersao[2]+".xsd")[3]
	cErro += PLSGETREST(cURL,cPath+"Schemas/"+"tissComunicacaoBeneficiarioV"+aVersao[2]+".wsdl"			,,.t.,cDirSchm+"tissComunicacaoBeneficiarioV"+aVersao[2]+".wsdl")[3]
	cErro += PLSGETREST(cURL,cPath+"Schemas/"+"tissEnvioDocumentosV"+aVersao[2]+".wsdl"					,,.t.,cDirSchm+"tissEnvioDocumentosV"+aVersao[2]+".wsdl")[3]
	cErro += PLSGETREST(cURL,cPath+"Schemas/"+"tissGuiasV"+aVersao[2]+".xsd"							,,.t.,cDirSchm+"tissGuiasV"+aVersao[2]+".xsd")[3]
	cErro += PLSGETREST(cURL,cPath+"Schemas/"+"tissLoteAnexoV"+aVersao[2]+".wsdl"						,,.t.,cDirSchm+"tissLoteAnexoV"+aVersao[2]+".wsdl")[3]
	cErro += PLSGETREST(cURL,cPath+"Schemas/"+"tissLoteGuiasV"+aVersao[2]+".wsdl"						,,.t.,cDirSchm+"tissLoteGuiasV"+aVersao[2]+".wsdl")[3]
	cErro += PLSGETREST(cURL,cPath+"Schemas/"+"tissMonitoramentoV"+aVersao[3]+".xsd"					,,.t.,cDirSchm+"tissMonitoramentoV"+aVersao[3]+".xsd")[3]
	cErro += PLSGETREST(cURL,cPath+"Schemas/"+"tissRecursoGlosaV"+aVersao[2]+".wsdl"					,,.t.,cDirSchm+"tissRecursoGlosaV"+aVersao[2]+".wsdl")[3]
	cErro += PLSGETREST(cURL,cPath+"Schemas/"+"tissSimpleTypesMonitoramentoV"+aVersao[3]+".xsd"			,,.t.,cDirSchm+"tissSimpleTypesMonitoramentoV"+aVersao[3]+".xsd")[3]
	cErro += PLSGETREST(cURL,cPath+"Schemas/"+"tissSimpleTypesV"+aVersao[2]+".xsd"						,,.t.,cDirSchm+"tissSimpleTypesV"+aVersao[2]+".xsd")[3]
	cErro += PLSGETREST(cURL,cPath+"Schemas/"+"tissSolicitacaoDemonstrativoRetornoV"+aVersao[2]+".wsdl"	,,.t.,cDirSchm+"tissSolicitacaoDemonstrativoRetornoV"+aVersao[2]+".wsdl")[3]
	cErro += PLSGETREST(cURL,cPath+"Schemas/"+"tissSolicitacaoProcedimentoV"+aVersao[2]+".wsdl"			,,.t.,cDirSchm+"tissSolicitacaoProcedimentoV"+aVersao[2]+".wsdl")[3]
	cErro += PLSGETREST(cURL,cPath+"Schemas/"+"tissSolicitacaoStatusAutorizacaoV"+aVersao[2]+".wsdl"	,,.t.,cDirSchm+"tissSolicitacaoStatusAutorizacaoV"+aVersao[2]+".wsdl")[3]
	cErro += PLSGETREST(cURL,cPath+"Schemas/"+"tissSolicitacaoStatusProtocoloV"+aVersao[2]+".wsdl"		,,.t.,cDirSchm+"tissSolicitacaoStatusProtocoloV"+aVersao[2]+".wsdl")[3]
	cErro += PLSGETREST(cURL,cPath+"Schemas/"+"tissSolicitacaoStatusRecursoGlosaV"+aVersao[2]+".wsdl"	,,.t.,cDirSchm+"tissSolicitacaoStatusRecursoGlosaV"+aVersao[2]+".wsdl")[3]
	cErro += PLSGETREST(cURL,cPath+"Schemas/"+"tissV"+aVersao[2]+".xsd"									,,.t.,cDirSchm+"tissV"+aVersao[2]+".xsd")[3]
	cErro += PLSGETREST(cURL,cPath+"Schemas/"+"tissVerificaElegibilidadeV"+aVersao[2]+".wsdl"			,,.t.,cDirSchm+"tissVerificaElegibilidadeV"+aVersao[2]+".wsdl")[3]
	cErro += PLSGETREST(cURL,cPath+"Schemas/"+"tissWebServicesV"+aVersao[2]+".xsd"						,,.t.,cDirSchm+"tissWebServicesV"+aVersao[2]+".xsd")[3]
	cErro += PLSGETREST(cURL,cPath+"Schemas/"+"xmldsig-core-schema.xsd"									,,.t.,cDirSchm+"xmldsig-core-schema.xsd")[3]
	logErro("Atualização dos Schemas: ",cErro,@cRet)
endif

if lBA0
	cSql := " UPDATE " +RetSQLName("BA0") +" SET BA0_TISVER = '"+cVersPto+"' "
   	cSql += " WHERE BA0_FILIAL = '" + xfilial("BA0") + "' AND D_E_L_E_T_ = ' ' "   	
   	PLSCOMMIT(cSQL)
	cRet += "Cadastro de Operadoras: OK" + CRLF
endif

if lBAU
	cSql := " UPDATE " +RetSQLName("BAU") +" SET BAU_TISVER = '"+cVersPto+"' "
   	cSql += " WHERE BAU_FILIAL = '" + xfilial("BAU") + "' AND D_E_L_E_T_ = ' ' "   	
   	PLSCOMMIT(cSQL)
	cRet += "Cadastro de Prestadores: OK" + CRLF
endif

cErro := PLSGETREST(cURL,cPath+"Wizard/"+"bvp-configuracao_variaveis_xml_tiss.csv"	,,.t.,cDirWiz+"bvp-configuracao_variaveis_xml_tiss.csv")[3]
cErro += PLSGETREST(cURL,cPath+"Wizard/"+"bcl-tipos_de_guias.csv"					,,.t.,cDirWiz+"bcl-tipos_de_guias.csv")[3]
cErro += PLSGETREST(cURL,cPath+"Wizard/"+"bvr-validacao_das_transacoes_tiss.csv"	,,.t.,cDirWiz+"bvr-validacao_das_transacoes_tiss.csv")[3]
cErro += PLSGETREST(cURL,cPath+"Wizard/"+"bvv-versoes_tiss.csv"						,,.t.,cDirWiz+"bvv-versoes_tiss.csv")[3]
cErro += PLSGETREST(cURL,cPath+"Wizard/"+"btp-cabecalho_terminologias_tiss.csv"		,,.t.,cDirWiz+"btp-cabecalho_terminologias_tiss.csv")[3]
cErro += PLSGETREST(cURL,cPath+"Wizard/"+"bcm-campos_por_tipos_de_guias.csv"		,,.t.,cDirWiz+"bcm-campos_por_tipos_de_guias.csv")[3]
cErro += PLSGETREST(cURL,cPath+"Wizard/"+"bcs-alias_das_guias.csv"					,,.t.,cDirWiz+"bcs-alias_das_guias.csv")[3]
if lAuto
	return .t.
endif
cErro += PLSWIZARD(,.t.)
logErro("Importação tabelas Versão TISS: ",cErro,@cRet)

return .t.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} logErro
Wizard de Atualização TISS

@author    Lucas Nonato
@version   V12
@since     20/12/2019 
/*/
static function logErro(cMsg,cErro,cRet)

if empty(cErro)
	cErro := "OK"
endif

cRet += cMsg + cErro + CRLF

return cRet
