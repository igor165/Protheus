#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "LOCACAO.CH"
#INCLUDE "TECA740F.CH"
#INCLUDE "XMLXFUN.CH"

#DEFINE _TV7TITULO		1
#DEFINE _TV7IDENT		2
#DEFINE _TV7MODO 		3
#DEFINE _TV7TAM 		4
#DEFINE _TV7DEC 		5
#DEFINE _TV7VALID 		6
#DEFINE _TV7EDICAO 		7
#DEFINE _TV7INIT 		8
#DEFINE _TV7FORM 		9
#DEFINE _TV7ORDEM 		10
#DEFINE _TV7DESC 		11
#DEFINE _TV7ABA			12

#DEFINE _fwTFF		1	// Chave dos Recursos Contidos no Local de Atendimento
#DEFINE _fwOBJ		2	// Objerto FWSheet - Para precificação de Recursos e Impostos
#DEFINE _fwDEL		3	// Linha Marcada para Deleção

STATIC cXmlPrc		:= ''
STATIC aPrcOrc		:= {}
STATIC oMdl740F		:= Nil
STATIC oViw740F		:= Nil
STATIC oFWSheet		:= IIF(SuperGetMV("MV_ORCPRC",,.F.), FWUIWorkSheet():New(,.F.), nil)
STATIC aFWSheet		:= {}
STATIC lMessage		:= .F.
STATIC lCalcular	:= .T.
STATIC cCodViewImp 	:= ""
STATIC lPutLeg		:= .F.

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA740F
	Orçamentos de serviços com o novo modelo de precificação

@sample 	TECA740F()

@since		02/02/2015
@version	P11
/*/
//------------------------------------------------------------------------------
Function TECA740F()

Local oBrw := FwMBrowse():New()

oBrw:SetAlias( "TFJ" )
oBrw:SetMenudef( "TECA740F" )
oBrw:SetDescription( OEmToAnsi( STR0001 ) ) //'Orçamento para Serviços'

If isBlind()
	oBrw := nil
Else
	oBrw:Activate()
EndIf

Return(Nil)


//------------------------------------------------------------------------------
/*/{Protheus.doc} Menudef
	Criacao do MenuDef.

@sample 	Menudef()
@return	 	aMenu, Array, Opção para seleção no Menu
@since		20/00/2013
@version	P11
/*/
//------------------------------------------------------------------------------
Static Function Menudef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 	ACTION 'PesqBrw'          OPERATION 1 ACCESS 0	// "Pesquisar"
ADD OPTION aRotina TITLE STR0003 	ACTION 'VIEWDEF.TECA740F' OPERATION 2 ACCESS 0	// "Visualizar"

Return (aRotina)


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Definição do modelo de Dados

@since 10/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStrTFJ := FWFormStruct(1,'TFJ')
Local oStrTFL := FWFormStruct(1,'TFL')
Local oStrTFF := FWFormStruct(1,'TFF')
Local oStrTFG := FWFormStruct(1,'TFG')
Local oStrTFH := FWFormStruct(1,'TFH')
Local oStrTFI := FWFormStruct(1,'TFI')
Local oStrTFU := FWFormStruct(1,'TFU')
Local oStrTWO := FWFormStruct(1,'TWO')
Local oStrABP := FWFormStruct(1,'ABP')
Local oStrTEV := FWFormStruct(1,'TEV')
Local oStrIMP := Nil
Local cModel	:= ""
Local xAux    := Nil
Local nI 		:= Nil
Local nPosImp := 0
Local lGSRH    := GSGetIns("RH")
Local aTabPrc := At600GetTab()
Local cTabela := If( aTabPrc[1] <> Nil, aTabPrc[1], "" )
Local cRevisa := If( aTabPrc[2] <> Nil, aTabPrc[2], "" )
//referente fonte TECA741 - Habilidades Item RH
Local oStrTGV := FWFormStruct(1,'TGV')
Local oStrTDS := FWFormStruct(1,'TDS')
Local oStrTDT := FWFormStruct(1,'TDT')
Local aModelsId	 := {}
Local lHasOrcSim	:= HasOrcSimp()
Local nDeduc		:= 0
Local oSubModel := Nil
Local aTable := {}
Local lTecItExtOp 	:= IsInCallStack("At190dGrOrc") 

lPutLeg := A740PutLeg()

//-----------------------------------------------------------------------------------------------------
//  Cria os campos que receberão o valor mensal para item de material
//-----------------------------------------------------------------------------------------------------
oStrTFF:AddField(STR0118, STR0118, 'TFF_LOADPRC', 'L', 1, 0, /*valid*/, /*when*/, /*combo*/, .F., {||.F.}/*inipad*/, .F., Nil, .T.) // "Planilha Carregada" ### "Planilha Carregada"
oStrTFG:AddField(STR0057, STR0057, 'TFG_VLRMESMI', 'N', 14, 2, /*valid*/, /*when*/, /*combo*/, .F., /*inipad*/, .F., Nil, .T.) // 'Média Mensal' ### 'Média Mensal'
oStrTFH:AddField(STR0057, STR0057, 'TFH_VLRMESMC', 'N', 14, 2, /*valid*/, /*when*/, /*combo*/, .F., /*inipad*/, .F., Nil, .T.) // 'Média Mensal' ### 'Média Mensal'
//-----------------------------------------------------------------------------------------------------
// Carrega as informaões para a montagem das estruturas
//-----------------------------------------------------------------------------------------------------
aPrcOrc := At740FPrc( cTabela, cRevisa )
//-----------------------------------------------------------------------------------------------------
// Montagem das estruturas para o model
//-----------------------------------------------------------------------------------------------------
At740FStru( @aPrcOrc, .T. )
//-----------------------------------------------------------------------------------------------------
// Adiciona campos totalizadores para o local de atendimento
//-----------------------------------------------------------------------------------------------------
At740FSTLoc( oStrTFL )
//-----------------------------------------------------------------------------------------------------
//  Não cria os gatilhos para não interferir nos totalizadores e gerar valores de cobrança por fora
// combinados a cobrança dentro do contrato
//-----------------------------------------------------------------------------------------------------
If !IsInCallStack("At870GerOrc")
	xAux := FwStruTrigger( 'TFG_TOTGER', 'TFG_TOTGER', 'At740TrgGer( "CALC_TFG", "TOT_MI", "TFL_LOC", "TFL_TOTMI" )', .F. )
		oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFH_TOTGER', 'TFH_TOTGER', 'At740TrgGer( "CALC_TFH", "TOT_MC", "TFL_LOC", "TFL_TOTMC" )', .F. )
		oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_SUBTOT', 'TFF_SUBTOT', 'At740TrgGer( "CALC_TFF", "TOT_RH", "TFL_LOC", "TFL_TOTRH" )', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TEV_VLTOT', 'TEV_VLTOT', 'At740TrgGer( "CALC_TEV", "TOT_ADICIO", "TFI_LE", "TFI_TOTAL", "TFI_DESCON" )', .F. )
		oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFI_TOTAL', 'TFI_TOTAL', 'At740TrgGer( "CALC_TFI", "TOT_LE", "TFL_LOC", "TFL_TOTLE" )', .F. )
		oStrTFI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
EndIf
xAux := FwStruTrigger( 'TFL_TOTRH', 'TFL_TOTRH', 'At740TrgGer( "TOTAIS", "TOT_RH", "TFJ_REFER", "TFJ_TOTRH" )', .F. )
	oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFL_TOTMI', 'TFL_TOTMI', 'At740TrgGer( "TOTAIS", "TOT_MI", "TFJ_REFER", "TFJ_TOTMI" )', .F. )
	oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFL_TOTMC', 'TFL_TOTMC', 'At740TrgGer( "TOTAIS", "TOT_MC", "TFJ_REFER", "TFJ_TOTMC" )', .F. )
	oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFL_TOTLE', 'TFL_TOTLE', 'At740TrgGer( "TOTAIS", "TOT_LE", "TFJ_REFER", "TFJ_TOTLE" )', .F. )
	oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFI_TOTAL', 'TFI_VALDES', 'At740LeTot( "2" )',.F.) // calcula o valor de desconto
	oStrTFI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFI_DESCON', 'TFI_VALDES', 'At740LeTot( "2" )',.F.)  // calcula o valor de desconto
	oStrTFI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFI_DESCON', 'TFI_TOTAL', 'At740LeTot( "1" )',.F.)  // calcula o valor total considerando o desconto
	oStrTFI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

//-----------------------------------------------------------------------------------------------------
// Gatilhos para os totalizadores dos Recursos Humanos
//-----------------------------------------------------------------------------------------------------
xAux := FwStruTrigger( 'TFF_PERINI', 'TFF_TOTMES', 'At740FTGMes( "TFF_RH", "TFF_PERINI", "TFF_PERFIM", "TFF_TOTAL" )', .F. )
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFF_PERFIM', 'TFF_TOTMES', 'At740FTGMes( "TFF_RH", "TFF_PERINI", "TFF_PERFIM", "TFF_TOTAL" )', .F. )
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFF_TOTAL', 'TFF_TOTMES', 'At740FTGMes( "TFF_RH", "TFF_PERINI", "TFF_PERFIM", "TFF_TOTAL" )', .F. )
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFF_TXLUCR', 'TFF_TOTMES', 'At740FTGMes( "TFF_RH", "TFF_PERINI", "TFF_PERFIM", "TFF_TOTAL" )', .F. )
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFF_TXADM', 'TFF_TOTMES', 'At740FTGMes( "TFF_RH", "TFF_PERINI", "TFF_PERFIM", "TFF_TOTAL" )', .F. )
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
If TecVlPrPar()
	xAux := FwStruTrigger( 'TFF_ADM', 'TFF_VLPRPA', 'At740PrxPa("TFF") ',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_LUCRO', 'TFF_VLPRPA', 'At740PrxPa("TFF") ',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStrutrigger( 'TFF_VLPRPA', 'TFF_VLPRPA', 'At740AtTpr()',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
EndIf
//-----------------------------------------------------------------------------------------------------
// gatilho para forçar a atualização do valor mensal no grid dos locais
//-----------------------------------------------------------------------------------------------------
xAux := FwStruTrigger( 'TFF_TOTMES', 'TFF_TOTMES', 'At740TrgGer( "CALC_TFF", "TOT_TFFMES", "TFL_LOC", "TFL_MESRH" )', .F., , , , '!IsInCallStack("At870GerOrc")' )
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
//-----------------------------------------------------------------------------------------------------
// Gatilhos para os totalizadores dos Materiais
// materiais de implantação
//-----------------------------------------------------------------------------------------------------
xAux := FwStruTrigger( 'TFG_VIDMES', 'TFG_DPRMES', 'At740FTGMes( "TFG_MI", Nil, Nil, "TFG_VLATIV", "TFG_VIDMES", .T. )', .F. )
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFG_QTDVEN', 'TFG_DPRMES', 'At740FTGMes( "TFG_MI", Nil, Nil, "TFG_VLATIV", "TFG_VIDMES", .T. )', .F. )
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFG_PRCVEN', 'TFG_DPRMES', 'At740FTGMes( "TFG_MI", Nil, Nil, "TFG_VLATIV", "TFG_VIDMES", .T. )', .F. )
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
//-----------------------------------------------------------------------------------------------------
// gatilhos para a atualização do valor mensal no grid dos locais
//-----------------------------------------------------------------------------------------------------
xAux := FwStruTrigger( 'TFG_QTDVEN', 'TFG_VLRMESMI', 'At740FTGMes( "TFG_MI", "TFG_PERINI", "TFG_PERFIM", "TFG_TOTGER" )', .F. )
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFG_PRCVEN', 'TFG_VLRMESMI', 'At740FTGMes( "TFG_MI", "TFG_PERINI", "TFG_PERFIM", "TFG_TOTGER" )', .F. )
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFG_PERINI', 'TFG_VLRMESMI', 'At740FTGMes( "TFG_MI", "TFG_PERINI", "TFG_PERFIM", "TFG_TOTGER" )', .F. )
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFG_PERFIM', 'TFG_VLRMESMI', 'At740FTGMes( "TFG_MI", "TFG_PERINI", "TFG_PERFIM", "TFG_TOTGER" )', .F. )
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFG_TOTGER', 'TFG_VLRMESMI', 'At740FTGMes( "TFG_MI", "TFG_PERINI", "TFG_PERFIM", "TFG_TOTGER" )', .F. )
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFG_TXLUCR', 'TFG_VLRMESMI', 'At740FTGMes( "TFG_MI", "TFG_PERINI", "TFG_PERFIM", "TFG_TOTGER" )', .F. )
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFG_TXADM', 'TFG_VLRMESMI', 'At740FTGMes( "TFG_MI", "TFG_PERINI", "TFG_PERFIM", "TFG_TOTGER" )', .F. )
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFG_VLRMESMI', 'TFG_VLRMESMI', 'At740TrgGer( "CALC_TFG", "TOT_TFGMES", "TFL_LOC", "TFL_MESMI" )', .F., , , , '!IsInCallStack("At870GerOrc")' )
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
If TecVlPrPar()
	xAux := FwStruTrigger( 'TFG_ADM', 'TFG_VLPRPA', 'At740PrxPa("TFG") ',.F.)
		oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFG_LUCRO', 'TFG_VLPRPA', 'At740PrxPa("TFG") ',.F.)
		oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStrutrigger( 'TFG_VLPRPA', 'TFG_VLPRPA', 'At740AtTpr()',.F.)
		oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
EndIf
//-----------------------------------------------------------------------------------------------------
// materiais de consumo
//-----------------------------------------------------------------------------------------------------
xAux := FwStruTrigger( 'TFH_VIDMES', 'TFH_DPRMES', 'At740FTGMes( "TFH_MC", Nil, Nil, "TFH_TOTGER", "TFH_VIDMES", .T. )', .F. )
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFH_QTDVEN', 'TFH_DPRMES', 'At740FTGMes( "TFH_MC", Nil, Nil, "TFH_TOTGER", "TFH_VIDMES", .T. )', .F. )
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFH_PRCVEN', 'TFH_DPRMES', 'At740FTGMes( "TFH_MC", Nil, Nil, "TFH_TOTGER", "TFH_VIDMES", .T. )', .F. )
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
//-----------------------------------------------------------------------------------------------------
// gatilhos para a atualização do valor mensal no grid dos locais
//-----------------------------------------------------------------------------------------------------
xAux := FwStruTrigger( 'TFH_QTDVEN', 'TFH_VLRMESMC', 'At740FTGMes( "TFH_MC", "TFH_PERINI", "TFH_PERFIM", "TFH_TOTGER" )', .F. )
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFH_PRCVEN', 'TFH_VLRMESMC', 'At740FTGMes( "TFH_MC", "TFH_PERINI", "TFH_PERFIM", "TFH_TOTGER" )', .F. )
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFH_PERINI', 'TFH_VLRMESMC', 'At740FTGMes( "TFH_MC", "TFH_PERINI", "TFH_PERFIM", "TFH_TOTGER" )', .F. )
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFH_PERFIM', 'TFH_VLRMESMC', 'At740FTGMes( "TFH_MC", "TFH_PERINI", "TFH_PERFIM", "TFH_TOTGER" )', .F. )
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFH_TOTGER', 'TFH_VLRMESMC', 'At740FTGMes( "TFH_MC", "TFH_PERINI", "TFH_PERFIM", "TFH_TOTGER" )', .F. )
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFH_TXLUCR', 'TFH_VLRMESMC', 'At740FTGMes( "TFH_MC", "TFH_PERINI", "TFH_PERFIM", "TFH_TOTGER" )', .F. )
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFH_TXADM', 'TFH_VLRMESMC', 'At740FTGMes( "TFH_MC", "TFH_PERINI", "TFH_PERFIM", "TFH_TOTGER" )', .F. )
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFH_VLRMESMC', 'TFH_VLRMESMC', 'At740TrgGer( "CALC_TFH", "TOT_TFHMES", "TFL_LOC", "TFL_MESMC" )', .F., , , , '!IsInCallStack("At870GerOrc")' )
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
If TecVlPrPar()
	xAux := FwStruTrigger( 'TFH_ADM', 'TFH_VLPRPA', 'At740PrxPa("TFH") ',.F.)
		oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFH_LUCRO', 'TFH_VLPRPA', 'At740PrxPa("TFH") ',.F.)
		oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStrutrigger( 'TFH_VLPRPA', 'TFH_VLPRPA', 'At740AtTpr()',.F.)
		oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
EndIf
//-----------------------------------------------------------------------------------------------------
//  Não cria os gatilhos para não interferir nos totalizadores e gerar valores de cobrança por fora
// combinados a cobrança dentro do contrato
//-----------------------------------------------------------------------------------------------------
If !IsInCallStack("At870GerOrc")
	xAux := FwStruTrigger( 'TFF_SUBTOT', 'TFF_TOTAL', 'At740InPad()',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_TXLUCR', 'TFF_SUBTOT', 'At740InSub()',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_TXADM', 'TFF_SUBTOT', 'At740InSub()',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFH_DESCON', 'TFH_TOTGER', 'At740CDesc("TFH_MC","TFH_QTDVEN","TFH_PRCVEN","TFH_DESCON","TFH_TOTGER")',.F.)
		oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])	
	xAux := FwStruTrigger( 'TFG_DESCON', 'TFG_TOTGER', 'At740CDesc("TFG_MI","TFG_QTDVEN","TFG_PRCVEN","TFG_DESCON","TFG_TOTGER")',.F.)
		oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_DESCON', 'TFF_SUBTOT',  'At740CDesc("TFF_RH","TFF_QTDVEN","TFF_PRCVEN","TFF_DESCON","TFF_TOTAL")',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])	
EndIf
If TecABBPRHR()
	xAux := FwStruTrigger( 'TFF_QTDHRS', 'TFF_HRSSAL', 'At740Horas( )', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
EndIf
xAux := FwStruTrigger( 'TFU_CODABN', 'TFU_ABNDES', 'At740TrgABN()',.F.)
	oStrTFU:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'ABP_BENEFI', 'ABP_DESCRI', 'At740DeBenefi()',.F.)
	oStrABP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'ABP_VERBA', 'ABP_DSVERB', 'Posicione("SRV", 1, xFilial("SRV")+M->ABP_VERBA, "RV_DESC" )',.F.)
	oStrABP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'ABP_VERBA', 'ABP_TPVERB', 'At740TpVerb()',.F.)
	oStrABP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TEV_MODCOB', 'TEV_UM', 'At740TrgTEV( "TEV_MODCOB" )',.F.)
	oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TEV_MODCOB', 'TEV_MODCOB', 'At740SmTEV()',.F.)  // atribui zero ao valor unitário sempre que troca o modo de cobrança
	oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TEV_MODCOB', 'TEV_QTDE', 'At740TEVQt()',.F.)
	oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFI_QTDVEN', 'TFI_QTDVEN', 'At740TEVQt(.T.)',.F.)
	oStrTFI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFI_PERINI', 'TFI_PERINI', 'At740TEVQt(.T.)',.F.)
	oStrTFI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFI_PERFIM', 'TFI_PERFIM', 'At740TEVQt(.T.)',.F.)
	oStrTFI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFI_APUMED', 'TFI_APUMED', 'At740TEVQt(.T.)',.F.)
	oStrTFI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFI_PRODUT', 'TFI_PRODUT', 'At740TEVQt(.T.)',.F.)
	oStrTFI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFI_ENTEQP', 'TFI_ENTEQP', 'At740TEVQt(.T.)',.F.)
	oStrTFI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFI_COLEQP', 'TFI_COLEQP', 'At740TEVQt(.T.)',.F.)
	oStrTFI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

//----------------------------------------------------------------------------------------
xAux := FwStruTrigger( 'TFJ_LUCRO', 'TFJ_LUCRO', 'At740LdLuc("1")',.F.)
	oStrTFJ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFJ_ADM', 'TFJ_ADM', 'At740LdLuc("2")',.F.)
	oStrTFJ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
//------------------------------------------------------------------------------------------
// Gatilhos - Recursos Humanos
//------------------------------------------------------------------------------------------
xAux := FwStruTrigger( 'TFF_LUCRO', 'TFF_TXLUCR', 'At740RhVlr("1","TFF_RH","TFF")',.F.)
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFF_ADM', 'TFF_TXADM', 'At740RhVlr("2","TFF_RH","TFF")',.F.)
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFF_QTDVEN', 'TFF_TXLUCR', 'At740RhVlr("1","TFF_RH","TFF")',.F.)
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFF_QTDVEN', 'TFF_TXADM', 'At740RhVlr("2","TFF_RH","TFF")',.F.)
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFF_PRCVEN', 'TFF_TXLUCR', 'At740RhVlr("1","TFF_RH","TFF")',.F.)
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFF_PRCVEN', 'TFF_TXADM', 'At740RhVlr("2","TFF_RH","TFF")',.F.)
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFF_FUNCAO', 'TFF_FUNCAO', 'At740FTrgG( "TFF_RH","TFF_FUNCAO","SAL_FUNCAO" )', .F. )
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
//------------------------------------------------------------------------------------------
// Gatilhos - Cobrança Locação Equipamento
//------------------------------------------------------------------------------------------
xAux := FwStruTrigger( 'TEV_LUCRO', 'TEV_TXLUCR', 'At740VlAcr("1","TEV_ADICIO","TEV")',.F.)
	oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TEV_ADM', 'TEV_TXADM', 'At740VlAcr("2","TEV_ADICIO","TEV")',.F.)
	oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TEV_QTDE', 'TEV_TXLUCR', 'At740VlAcr("1","TEV_ADICIO","TEV")',.F.)
	oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TEV_TXLUCR', 'TEV_VLTOT', 'At740VlTEV("TEV_ADICIO")',.F.)
	oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TEV_VLRUNI', 'TEV_TXLUCR', 'At740VlAcr("1","TEV_ADICIO","TEV")' ,.F.)
	oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TEV_QTDE', 'TEV_TXADM', 'At740VlAcr("2","TEV_ADICIO","TEV")',.F.)
	oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TEV_TXADM', 'TEV_VLTOT', 'At740VlTEV("TEV_ADICIO")',.F.)
	oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TEV_VLRUNI', 'TEV_TXADM', 'At740VlAcr("2","TEV_ADICIO","TEV")',.F.)
	oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
//------------------------------------------------------------------------------------------
// Gatilhos - Materiais de Implantação
//------------------------------------------------------------------------------------------
xAux := FwStrutrigger( 'TFG_LUCRO', 'TFG_TXLUCR', 'At740MatAc("1","TFG_MI","TFG")',.F.)
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFG_LUCRO', 'TFG_TOTGER', 'At740VlTot("TFG_MI","TFG")',.F.)
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFG_TOTAL', 'TFG_TOTGER', 'At740VlTot("TFG_MI","TFG")',.F.)
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFG_PRCVEN', 'TFG_TOTGER', 'At740VlTot("TFG_MI","TFG")',.F.)
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFG_QTDVEN', 'TFG_TOTGER', 'At740VlTot("TFG_MI","TFG")',.F.)
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFG_ADM', 'TFG_TXADM', 'At740MatAc("2","TFG_MI","TFG")',.F.)
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFG_ADM', 'TFG_TOTGER', 'At740VlTot("TFG_MI","TFG")',.F.)
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFG_TOTGER', 'TFG_TXLUCR', 'At740MatAc("1","TFG_MI","TFG")',.F.)
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFG_TOTGER', 'TFG_TXADM', 'At740MatAc("2","TFG_MI","TFG")',.F.)
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
//------------------------------------------------------------------------------------------
// Gatilhos - Materiais de Consumo
//------------------------------------------------------------------------------------------
xAux := FwStrutrigger( 'TFH_LUCRO', 'TFH_TXLUCR', 'At740MatAc("1","TFH_MC","TFH")',.F.)
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFH_LUCRO', 'TFH_TOTGER', 'At740VlTot("TFH_MC","TFH")',.F.)
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFH_TOTAL', 'TFH_TOTGER', 'At740VlTot("TFH_MC","TFH")',.F.)
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFH_PRCVEN', 'TFH_TOTGER', 'At740VlTot("TFH_MC","TFH")',.F.)
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFH_QTDVEN', 'TFH_TOTGER', 'At740VlTot("TFH_MC","TFH")',.F.)
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFH_ADM', 'TFH_TXADM', 'At740MatAc("2","TFH_MC","TFH")',.F.)
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFH_ADM', 'TFH_TOTGER', 'At740VlTot("TFH_MC","TFH")',.F.)
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFH_TOTGER', 'TFH_TXLUCR', 'At740MatAc("1","TFH_MC","TFH")',.F.)
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFH_TOTGER', 'TFH_TXADM', 'At740MatAc("2","TFH_MC","TFH")',.F.)
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
//-----------------------------------------------------------------------------------------------------
// Descrição do calendario
//-----------------------------------------------------------------------------------------------------
xAux := FwStruTrigger('TFF_CALEND','TFF_DSCALE','ALLTRIM( POSICIONE("AC0",1,XFILIAL("AC0")+M->TFF_CALEND,"AC0_DESC") )',.F.,Nil,Nil,Nil)
oStrTFF:AddTrigger(xAux[1],xAux[2],xAux[3],xAux[4])
//-----------------------------------------------------------------------------------------------------
// gatilho para preencher os percentuais de lucro e tx adm quando inserido produto na linha
//-----------------------------------------------------------------------------------------------------
xAux := FwStruTrigger( 'TFF_PRODUT', 'TFF_LUCRO', 'At740LuTxA("TFJ_LUCRO")')
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFF_PRODUT', 'TFF_ADM', 'At740LuTxA("TFJ_ADM")')
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFG_PRODUT', 'TFG_LUCRO', 'At740LuTxA("TFJ_LUCRO")')
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFG_PRODUT', 'TFG_ADM', 'At740LuTxA("TFJ_ADM")')
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFH_PRODUT', 'TFH_LUCRO', 'At740LuTxA("TFJ_LUCRO")')
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFH_PRODUT', 'TFH_ADM', 'At740LuTxA("TFJ_ADM")')
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TEV_MODCOB', 'TEV_LUCRO', 'At740LuTxA("TFJ_LUCRO")')
	oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TEV_MODCOB', 'TEV_ADM', 'At740LuTxA("TFJ_ADM")')
	oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
//------------------------------------------------------------------------------------------
// Gatilhos - Caracteristicas
//------------------------------------------------------------------------------------------
xAux := FwStrutrigger( 'TDS_CODTCZ', 'TDS_DSCTCZ', 'At740fTDS()',.F.)
	oStrTDS:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
//------------------------------------------------------------------------------------------
// Gatilhos - Habilidades
//------------------------------------------------------------------------------------------
xAux := FwStrutrigger( 'TDT_CODHAB', 'TDT_DSCHAB', 'At740fTDT("1")',.F.)
	oStrTDT:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TDT_ESCALA', 'TDT_DSCESC', 'At740fTDT("2")',.F.)
	oStrTDT:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TDT_ITESCA', 'TDT_DSCITE', 'At740fTDT("3")',.F.)
	oStrTDT:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TDT_HABX5' , 'TDT_DHABX5', 'At740fTDT("4")',.F.)
	oStrTDT:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
//------------------------------------------------------------------------------------------
// Gatilhos - Cursos
//------------------------------------------------------------------------------------------
xAux := FwStrutrigger( 'TGV_CURSO', 'TGV_DCURSO', 'At740fTGV()',.F.)
	oStrTGV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
//-----------------------------------------------------------------------------------------------------
//Alterar propriedades de alguns campos
//-----------------------------------------------------------------------------------------------------
oStrTFL:SetProperty( "TFL_CODPAI", MODEL_FIELD_OBRIGAT, .F. )
oStrTFF:SetProperty( "TFF_CODPAI", MODEL_FIELD_OBRIGAT, .F. )
oStrTFF:SetProperty( "TFF_LOCAL", MODEL_FIELD_OBRIGAT, .F. )
oStrTFG:SetProperty( "TFG_CODPAI", MODEL_FIELD_OBRIGAT, .F. )
oStrTFG:SetProperty( "TFG_LOCAL", MODEL_FIELD_OBRIGAT, .F. )
oStrTFH:SetProperty( "TFH_CODPAI", MODEL_FIELD_OBRIGAT, .F. )
oStrTFH:SetProperty( "TFH_LOCAL", MODEL_FIELD_OBRIGAT, .F. )
oStrTFI:SetProperty( "TFI_CODPAI", MODEL_FIELD_OBRIGAT, .F. )
oStrTFI:SetProperty( "TFI_LOCAL", MODEL_FIELD_OBRIGAT, .F. )
oStrTFI:SetProperty( "TFI_TOTAL", MODEL_FIELD_OBRIGAT, .F. )
oStrTFU:SetProperty( "TFU_CODTFF", MODEL_FIELD_OBRIGAT, .F. )
oStrTFU:SetProperty( "TFU_LOCAL", MODEL_FIELD_OBRIGAT, .F. )
oStrTFU:SetProperty( "TFU_VALOR", MODEL_FIELD_OBRIGAT, .F. )
oStrTDS:SetProperty( "TDS_CODTFF", MODEL_FIELD_OBRIGAT, .F. )
oStrTDT:SetProperty( "TDT_CODTFF", MODEL_FIELD_OBRIGAT, .F. )
oStrTGV:SetProperty( "TGV_CODTFF", MODEL_FIELD_OBRIGAT, .F. )
oStrTGV:SetProperty( "TGV_CODTFF", MODEL_FIELD_INIT,{|oMdl| oMdl:GetModel():GetModel("TFF_RH"):GetValue("TFF_COD") } )
oStrTDS:SetProperty( "TDS_CODTFF", MODEL_FIELD_INIT,{|oMdl| oMdl:GetModel():GetModel("TFF_RH"):GetValue("TFF_COD") } )
oStrTDT:SetProperty( "TDT_CODTFF", MODEL_FIELD_INIT,{|oMdl| oMdl:GetModel():GetModel("TFF_RH"):GetValue("TFF_COD") } )
oStrABP:SetProperty( "ABP_ITRH"  , MODEL_FIELD_OBRIGAT, .F. )
oStrTEV:SetProperty( "TEV_CODLOC", MODEL_FIELD_OBRIGAT, .F. )
oStrTFH:SetProperty('TFH_PERINI',MODEL_FIELD_VALID,{|oMdlVld|At740FVlDt("TFH_MC","TFH_PERINI","TFH_PERINI","TFH_PERFIM",oMdlVld:GetModel())})
oStrTFH:SetProperty('TFH_PERFIM',MODEL_FIELD_VALID,{|oMdlVld|At740FVlDt("TFH_MC","TFH_PERFIM","TFH_PERINI","TFH_PERFIM",oMdlVld:GetModel())})
oStrTFG:SetProperty('TFG_PERINI',MODEL_FIELD_VALID,{|oMdlVld|At740FVlDt("TFG_MI","TFG_PERINI","TFG_PERINI","TFG_PERFIM",oMdlVld:GetModel())})
oStrTFG:SetProperty('TFG_PERFIM',MODEL_FIELD_VALID,{|oMdlVld|At740FVlDt("TFG_MI","TFG_PERFIM","TFG_PERINI","TFG_PERFIM",oMdlVld:GetModel())})
oStrTFF:SetProperty('TFF_PERINI',MODEL_FIELD_VALID,{|oMdlVld|At740FVlDt("TFF_RH","TFF_PERINI","TFF_PERINI","TFF_PERFIM",oMdlVld:GetModel())})
oStrTFF:SetProperty('TFF_PERFIM',MODEL_FIELD_VALID,{|oMdlVld|At740FVlDt("TFF_RH","TFF_PERFIM","TFF_PERINI","TFF_PERFIM",oMdlVld:GetModel())})
oStrTFI:SetProperty('TFI_PERINI',MODEL_FIELD_VALID, {|oMdlVld,cCampo,xValueNew,nLine,xValueOld|;
				At740FVlDt("TFI_LE","TFI_PERINI","TFI_PERINI","TFI_PERFIM",oMdlVld:GetModel()) .And. ;  // valida o período selecionado
				At740Reserv(oMdlVld,cCampo,xValueNew,nLine,xValueOld) } )  // verifica se há reserva de equipamento
oStrTFI:SetProperty('TFI_PERFIM',MODEL_FIELD_VALID, {|oMdlVld,cCampo,xValueNew,nLine,xValueOld|;
				At740FVlDt("TFI_LE","TFI_PERFIM","TFI_PERINI","TFI_PERFIM",oMdlVld:GetModel()) .And. ;  // valida o período selecionado
				At740Reserv(oMdlVld,cCampo,xValueNew,nLine,xValueOld) } )  // verifica se há reserva de equipamento
oStrTFI:SetProperty('TFI_QTDVEN',MODEL_FIELD_VALID, {|oMdlVld,cCampo,xValueNew,nLine,xValueOld|;
				xValueNew >= 0 .And. ;
				At740Reserv(oMdlVld,cCampo,xValueNew,nLine,xValueOld) } )
oStrTFL:SetProperty('TFL_DTINI',MODEL_FIELD_VALID,{|oMdl740F|At740FVlVg(oMdl740F,'TFL_DTINI')})
oStrTFL:SetProperty('TFL_DTFIM',MODEL_FIELD_VALID,{|oMdl740F|At740FVlVg(oMdl740F,'TFL_DTFIM')})
oStrTFF:SetProperty('TFF_PRCVEN',MODEL_FIELD_OBRIGAT,.F.)
oStrTFF:SetProperty('TFF_PRCVEN',MODEL_FIELD_WHEN ,{|oMdl740F|At740BlTot(oMdl740F)})
oStrTFF:SetProperty('TFF_PRCVEN',MODEL_FIELD_VALID,{|oMdl740F|At740VlVlr("TFF_RH","TFF_PRCVEN",oMdl740F)})
oStrTFF:SetProperty('TFF_PERMAT',MODEL_FIELD_WHEN ,{|oModel|At740FWMat()})
oStrTFF:SetProperty('TFF_COBCTR', MODEL_FIELD_WHEN, { || .F.} )

If TecABBPRHR()
	oStrTFF:SetProperty('TFF_HRSSAL',MODEL_FIELD_WHEN, {|| .F. })
EndIf

If TFJ->( ColumnPos('TFJ_DTPLRV') ) > 0
	oStrTFJ:SetProperty( "TFJ_DTPLRV", MODEL_FIELD_OBRIGAT, .F. )
EndIf

oStrABP:SetProperty('ABP_DESCRI',MODEL_FIELD_INIT,{|| At740DscBe()} )
oStrABP:SetProperty('ABP_TPVERB',MODEL_FIELD_INIT,{|| At740ConvTp( ATINIPADMVC("TECA740","ABP_BENEF","RV_TIPO","SRV",1, "xFilial('SRV')+ABP->ABP_VERBA") ) } )

oStrTFG:SetProperty('TFG_PRCVEN',MODEL_FIELD_OBRIGAT,.F.)
oStrTFG:SetProperty('TFG_PRCVEN',MODEL_FIELD_VALID,{|oMdl740F|At740VlVlr("TFG_MI","TFG_PRCVEN",oMdl740F)})
oStrTFG:SetProperty('TFG_TOTGER',MODEL_FIELD_INIT,{|| ATINIPADMVC("TECA740","TFG_MI",'TFG_TOTGER',,,,'TFG->(TFG_QTDVEN*TFG_PRCVEN)+(TFG->(TFG_QTDVEN*TFG_PRCVEN)*(TFG->TFG_LUCRO/100))+(TFG->(TFG_QTDVEN*TFG_PRCVEN)*(TFG->TFG_ADM/100))') } )
oStrTFG:SetProperty('TFG_COBCTR', MODEL_FIELD_WHEN , { || .F. } )

oStrTFH:SetProperty('TFH_PRCVEN',MODEL_FIELD_OBRIGAT,.F.)
oStrTFH:SetProperty('TFH_PRCVEN',MODEL_FIELD_VALID,{|oMdl740F|At740VlVlr("TFH_MC","TFH_PRCVEN",oMdl740F)})
oStrTFH:SetProperty('TFH_TOTGER',MODEL_FIELD_INIT,{|| ATINIPADMVC("TECA740","TFH_MC",'TFH_TOTGER',,,,'TFH->(TFH_QTDVEN*TFH_PRCVEN)+(TFH->(TFH_QTDVEN*TFH_PRCVEN)*(TFH->TFH_LUCRO/100))+(TFH->(TFH_QTDVEN*TFH_PRCVEN)*(TFH->TFH_ADM/100))') } )
oStrTFH:SetProperty('TFH_COBCTR', MODEL_FIELD_WHEN, { || .F. } )

oStrTEV:SetProperty('TEV_UM',MODEL_FIELD_WHEN,{|| IsInCallStack('RunTrigger') .Or. FwFldGet('TEV_MODCOB') <> '2' } )
oStrTEV:SetProperty('TEV_VLTOT',MODEL_FIELD_INIT,{|| ATINIPADMVC("TECA740", "TEV_ADICIO", "TEV_VLTOT",,,,'TEV->(TEV_VLRUNI*TEV_QTDE)+TEV->(TEV_TXADM+TEV_TXLUCR)')} )

If isInCallStack("At870GerOrc")
	oStrTFF:SetProperty( "TFF_COBCTR", MODEL_FIELD_INIT, {||"2"} )
	oStrTFG:SetProperty( "TFG_COBCTR", MODEL_FIELD_INIT, {||"2"} )
	oStrTFH:SetProperty( "TFH_COBCTR", MODEL_FIELD_INIT, {||"2"} )
EndIf

IF lTecItExtOp
	oStrTFF:SetProperty( "TFF_ITEXOP", MODEL_FIELD_INIT, {||"1"} )
Endif
oStrTWO:SetProperty('TWO_CODFAC', MODEL_FIELD_VALID, {|a,b,c,d,e| FWInitCpo(a,b,c,d),lValFac := Vazio() .Or. ExistCpo("TWM"),FWCloseCpo(a,b,c,lValFac,.T.),lValFac})

oMdl740F := MPFormModel():New("TECA740F",{|oModel| At740GSC(.T.)}, {|oMdl740F| IIf(lGSRH, At740FTTRH(oMdl740F), .t.) .and. At740TdOk(oMdl740F) },{|oMdl740F| At740Cmt( oMdl740F ) }, {|a,b,c,d| At740Canc( a,b,c,d ) } )
oMdl740F:SetDescription( STR0001 ) // 'Orçamento para Serviços'

oMdl740F:addFields('TFJ_REFER',,oStrTFJ)
If lHasOrcSim
	oMdl740F:GetModel("TFJ_REFER"):SetFldNoCopy( { 'TFJ_CODVIS' } )
EndIf

oMdl740F:addGrid('TFL_LOC','TFJ_REFER', oStrTFL, {|oMdlG,nLine,cAcao,cCampo, xValue, xOldValue| PreLinTFL(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue) }, , Nil, Nil, {|oModel|AtLoadTFL(oModel)})

oMdl740F:SetRelation('TFL_LOC', { { 'TFL_FILIAL', 'xFilial("TFJ")' }, { 'TFL_CODPAI', 'TFJ_CODIGO' } }, TFL->(IndexKey(1)) )

oMdl740F:addGrid('TFF_RH','TFL_LOC',oStrTFF, {|oMdlG,nLine,cAcao,cCampo, xValue, xOldValue| PreLinTFF(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue) },{|oMdlG,nLine,cAcao,cCampo| PosLinTFF(oMdlG, nLine, cAcao, cCampo)};
		,Nil, Nil, {|oModel|AtLoadTFF(oModel)})

oMdl740F:SetRelation('TFF_RH', { { 'TFF_FILIAL', 'xFilial("TFF")' }, { 'TFF_CODPAI', 'TFL_CODIGO' }, { 'TFF_LOCAL', 'TFL_LOCAL' } }, TFF->(IndexKey(1)) )

//Criação dos fields dinamicos para o RH
For nI:=1 To Len(aPrcOrc)
	If Empty(AllTrim(aPrcOrc[nI][1]))
		Loop
	EndIf
	// Indica o nome do model a ser criado
	cModel  := aPrcOrc[nI][3][2]
	// Assume a nova estrutura do model
	&("oStrR" + StrZero(nI,3)) := aPrcOrc[nI][3][1]
	oMdl740F:AddFields( cModel, "TFF_RH", &("oStrR" + StrZero(nI,3)),{|oModel,cAcao|A740FPVld(oModel,cAcao)},/*bPost*/,{||})
	oMdl740F:getModel(cModel):SetDescription(cModel)
Next nI

oMdl740F:addGrid('ABP_BENEF','TFF_RH',oStrABP, {|oMdlG,nLine,cAcao,cCampo| PreLinABP(oMdlG, nLine, cAcao, cCampo) } )
oMdl740F:SetRelation('ABP_BENEF', { { 'ABP_FILIAL', 'xFilial("ABP")' }, { 'ABP_ITRH', 'TFF_COD' } }, ABP->(IndexKey(1)) )

oMdl740F:addGrid('TFG_MI','TFL_LOC',oStrTFG, {|oMdlG,nLine,cAcao,cCampo, xValue, xOldValue| PreLinTFG(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue) },{|oMdlG,nLine,cAcao,cCampo| PosLinTFG(oMdlG, nLine, cAcao, cCampo)};
,Nil, Nil, {|oModel|AtLoadTFG(oModel)})

oMdl740F:SetRelation('TFG_MI', { { 'TFG_FILIAL', 'xFilial("TFG")' }, { 'TFG_CODPAI', 'TFL_CODIGO' } , { 'TFG_LOCAL', 'TFL_LOCAL' } }, TFG->(IndexKey(3)) )

oMdl740F:addGrid('TFH_MC','TFL_LOC',oStrTFH, {|oMdlG,nLine,cAcao,cCampo, xValue, xOldValue| PreLinTFH(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue) },{|oMdlG,nLine,cAcao,cCampo| PosLinTFH(oMdlG, nLine, cAcao, cCampo)};
 ,Nil, Nil, {|oModel|AtLoadTFH(oModel)})

oMdl740F:SetRelation('TFH_MC', { { 'TFH_FILIAL', 'xFilial("TFH")' }, { 'TFH_CODPAI', 'TFL_CODIGO' } , { 'TFH_LOCAL', 'TFL_LOCAL' } }, TFH->(IndexKey(3)) )

oMdl740F:addGrid('TFU_HE','TFF_RH',oStrTFU,  {|oMdlG,nLine,cAcao,cCampo| PreLinTFU(oMdlG, nLine, cAcao, cCampo) }, {|oMdlG,nLine,cAcao,cCampo| PosLinTFU(oMdlG, nLine, cAcao, cCampo)} )
oMdl740F:SetRelation('TFU_HE', { { 'TFU_FILIAL', 'xFilial("TFU")' }, { 'TFU_CODTFF', 'TFF_COD' }, { 'TFU_LOCAL', 'TFL_LOCAL' } }, TFU->(IndexKey(1)) )

//Criação do field dinamico para os impostos
nPosImp := aScan( aPrcOrc, { |x| x[1] == Replicate( " ", 30 ) } ) // Verifica a posição do array de impostos

If nPosImp > 0
	// Assume a nova estrutura do model
	oStrIMP := aPrcOrc[nPosImp][3][1]
	cModel  := aPrcOrc[nPosImp][3][2]
	// Cria tabela para a estrutura temporaria
	xAux := FwStrutrigger( "TOT_VIMP", "TOT_VIMP", 'At740FImpTrg( "' + cModel + '", "TOT_VIMP" )',.F.)
	oStrIMP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( "TFL_TOTIMP", "TFL_MESIMP", 'At740FTGMes( "TFL_LOC", "TFL_DTINI", "TFL_DTFIM", "TFL_TOTIMP" )',.F.)
	oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	oMdl740F:AddFields( cModel, "TFL_LOC", oStrIMP,/*bPreValidacao*/,/*bPosValidacao*/,{|oModel|AtLoadImp(oModel)})
	oMdl740F:getModel(cModel):SetDescription( STR0004 )  // "Impostos"
EndIf

oMdl740F:addGrid('TFI_LE','TFL_LOC',oStrTFI, {|oMdlG,nLine,cAcao,cCampo| PreLinTFI(oMdlG, nLine, cAcao, cCampo) },Nil,Nil,Nil,{|oModel|AtLoadTFI(oModel)} )
oMdl740F:SetRelation('TFI_LE', { { 'TFI_FILIAL', 'xFilial("TFI")' }, { 'TFI_CODPAI', 'TFL_CODIGO' }, { 'TFI_LOCAL', 'TFL_LOCAL' } }, TFI->(IndexKey(1)) )

oMdl740F:addGrid('TEV_ADICIO','TFI_LE',oStrTEV, {|oMdlG,nLine,cAcao,cCampo, xValue, xOldValue| PreLinTEV(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue) } )
oMdl740F:SetRelation('TEV_ADICIO', { { 'TEV_FILIAL', 'xFilial("TEV")' }, { 'TEV_CODLOC', 'TFI_COD' } }, TEV->(IndexKey(1)) )
oMdl740F:GetModel( 'TEV_ADICIO' ):SetUniqueLine( { 'TEV_MODCOB' } )
//-----------------------------------------------------------------------------------------------------
//Referente Fonte TECA741 - Habilidades do item RH
//-----------------------------------------------------------------------------------------------------
oMdl740F:AddGrid( "TGV_RH", "TFF_RH", oStrTGV,/*bLinePre*/,/*bLinePos*/,/*bPreVal*/ ,/*bPosVal*/ , /*bLoad*/)
oMdl740F:SetRelation('TGV_RH', { { 'TGV_FILIAL', 'xFilial("TGV")' }, { 'TGV_CODTFF', 'TFF_COD' } }, TGV->(IndexKey(1)) )
oMdl740F:GetModel( 'TGV_RH' ):SetUniqueLine( { 'TGV_CODTFF','TGV_CURSO' } )

oMdl740F:AddGrid( "TDS_RH", "TFF_RH", oStrTDS,/*bLinePre*/,/*bLinePos*/,/*bPreVal*/ ,/*bPosVal*/ , /*bLoad*/)
oMdl740F:SetRelation('TDS_RH', { { 'TDS_FILIAL', 'xFilial("TDS")' }, { 'TDS_CODTFF', 'TFF_COD' } }, TDS->(IndexKey(1)) )
oMdl740F:GetModel( 'TDS_RH' ):SetUniqueLine( { 'TDS_CODTFF','TDS_CODTCZ' } )

oMdl740F:AddGrid( "TDT_RH", "TFF_RH", oStrTDT,/*bLinePre*/,/*bLinePos*/,/*bPreVal*/ ,/*bPosVal*/ , /*bLoad*/)
oMdl740F:SetRelation('TDT_RH', { { 'TDT_FILIAL', 'xFilial("TDT")' }, { 'TDT_CODTFF', 'TFF_COD' } }, TDT->(IndexKey(1)) )
//-----------------------------------------------------------------------------------------------------
//Referente ao Facilitador de Orçamento
//-----------------------------------------------------------------------------------------------------
oMdl740F:AddGrid( "TWODETAIL", "TFL_LOC", oStrTWO,{|oMdl740F,  nLine,cAction,  cField, xValue, xOldValue|A740LoadFa(oMdl740F, nLine, cAction, cField, xValue, xOldValue)}/*bLinePre*/,/*bLinePos*/,/*bPreVal*/ ,/*bPosVal*/ , /*bLoad*/)
oMdl740F:SetRelation('TWODETAIL', {{'TWO_FILIAL','xFilial("TWO")'},{'TWO_CODORC','TFJ_CODIGO'},{'TWO_PROPOS','TFJ_PROPOS'},{'TWO_LOCAL','TFL_CODIGO'}}, TWO->(IndexKey(1)) )

//-- Ponto de entrada para adicionar grid ao modelo de dados
If ExistBlock("a740GrdM")
	For nI := 1 To Len(oMdl740F:GetAllSubModels())
		Aadd(aModelsId, {oMdl740F:aAllSubModels[nI]:GetId(), oMdl740F:aAllSubModels[nI]:GetDescription()})
	Next nI
	ExecBlock("a740GrdM",.F.,.F.,{oMdl740F,aModelsId})
EndIf


//-----------------------------------------------------------------------------------------------------
//Descrições dos modelos
//-----------------------------------------------------------------------------------------------------
oMdl740F:getModel('TFJ_REFER'):SetDescription(STR0005) // 'Ref. Proposta'
oMdl740F:getModel('TFL_LOC'):SetDescription(STR0006) // 'Locais'
oMdl740F:getModel('TFF_RH'):SetDescription(STR0007) // 'Recursos Humanos'
oMdl740F:getModel('TFG_MI'):SetDescription(STR0008) // 'Materiais de Implantação'
oMdl740F:getModel('TFH_MC'):SetDescription(STR0009) // 'Material de Consumo'
oMdl740F:getModel('TFU_HE'):SetDescription(STR0010) // 'Hora Extra'
oMdl740F:getModel('TFI_LE'):SetDescription(STR0011) // 'Locação de Equipamentos'
oMdl740F:getModel('ABP_BENEF'):SetDescription(STR0012)  // "Verbas"
oMdl740F:getModel('TEV_ADICIO'):SetDescription(STR0013)  // 'Cobrança da Locação'
oMdl740F:getModel('TGV_RH'):SetDescription(STR0054)  // 'Cursos'
oMdl740F:getModel('TDS_RH'):SetDescription(STR0055)  // 'Habilidades'
oMdl740F:getModel('TDT_RH'):SetDescription(STR0056)  // 'Caracteristicas'
oMdl740F:getModel('TWODETAIL'):SetDescription(STR0068)  // "Facilitador de Orçamento"

oMdl740F:getModel('TEV_ADICIO'):SetOptional(.T.)
oMdl740F:getModel('TFI_LE'):SetOptional(.T.)
oMdl740F:getModel('TFH_MC'):SetOptional(.T.)
oMdl740F:getModel('TFG_MI'):SetOptional(.T.)
oMdl740F:getModel('TFU_HE'):SetOptional(.T.)
oMdl740F:getModel('ABP_BENEF'):SetOptional(.T.)
oMdl740F:getModel('TFF_RH'):SetOptional(.T.)
oMdl740F:getModel('TGV_RH'):SetOptional(.T.) //ref. fonte TECA741
oMdl740F:getModel('TDS_RH'):SetOptional(.T.) //ref. fonte TECA741
oMdl740F:getModel('TDT_RH'):SetOptional(.T.) //ref. fonte TECA741
oMdl740F:getModel('TWODETAIL'):SetOptional(.T.) //ref. fonte TECA741

oMdl740F:AddCalc( 'CALC_TFI', 'TFL_LOC', 'TFI_LE', 'TFI_TOTAL', 'TOT_LE', 'SUM', /*bCondition*/, /*bInitValue*/, STR0014 /*cTitle*/, /*bFormula*/) // 'Tot. Loc. Equipamento'
oMdl740F:AddCalc( 'CALC_TFF', 'TFL_LOC', 'TFF_RH', 'TFF_SUBTOT', 'TOT_RH', 'SUM', {|oMdl740F| oMdl740F:GetValue( "TFF_RH", "TFF_COBCTR" ) <> "2" }/*bCondition*/, /*bInitValue*/,STR0015 /*cTitle*/, /*bFormula*/)  // 'Tot. Rec. Humanos'
//-----------------------------------------------------------------------------------------------------
// Mensal para os itens de RH
//-----------------------------------------------------------------------------------------------------
oMdl740F:AddCalc( 'CALC_TFF', 'TFL_LOC', 'TFF_RH', 'TFF_TOTMES', 'TOT_TFFMES', 'SUM', {|oMdl740F| oMdl740F:GetValue( "TFF_RH", "TFF_COBCTR" ) <> "2" }/*bCondition*/, /*bInitValue*/,STR0065 /*cTitle*/, /*bFormula*/)  // 'Mensal Rec. Humanos'
oMdl740F:AddCalc( 'CALC_TFG', 'TFL_LOC', 'TFG_MI', 'TFG_TOTGER', 'TOT_MI', 'SUM', {|oMdl740F| oMdl740F:GetValue( "TFG_MI", "TFG_COBCTR" ) <> "2" }/*bCondition*/, /*bInitValue*/,STR0016 /*cTitle*/, /*bFormula*/)  // 'Tot. Mat. Implantação'
//-----------------------------------------------------------------------------------------------------
// Mensal para os itens de Materiais de Implantação
//-----------------------------------------------------------------------------------------------------
oMdl740F:AddCalc( 'CALC_TFG', 'TFL_LOC', 'TFG_MI', 'TFG_VLRMESMI', 'TOT_TFGMES', 'SUM', {|oMdl740F| oMdl740F:GetValue( "TFG_MI", "TFG_COBCTR" ) <> "2" }/*bCondition*/, /*bInitValue*/,STR0066 /*cTitle*/, /*bFormula*/)  // 'Mensal Mat. Implantação'
oMdl740F:AddCalc( 'CALC_TFH', 'TFL_LOC', 'TFH_MC', 'TFH_TOTGER', 'TOT_MC', 'SUM', {|oMdl740F| oMdl740F:GetValue( "TFH_MC", "TFH_COBCTR" ) <> "2" }/*bCondition*/, /*bInitValue*/,STR0017 /*cTitle*/, /*bFormula*/)  // 'Tot. Mat. Consumo'
//-----------------------------------------------------------------------------------------------------
// Mensal para os itens de Materiais de Consumo
//-----------------------------------------------------------------------------------------------------
oMdl740F:AddCalc( 'CALC_TFH', 'TFL_LOC', 'TFH_MC', 'TFH_VLRMESMC', 'TOT_TFHMES', 'SUM', {|oMdl740F| oMdl740F:GetValue( "TFH_MC", "TFH_COBCTR" ) <> "2" }/*bCondition*/, /*bInitValue*/,STR0067 /*cTitle*/, /*bFormula*/)  // 'Mensal Mat. Consumo'
oMdl740F:AddCalc( 'CALC_TEV', 'TFI_LE', 'TEV_ADICIO', 'TEV_VLTOT', 'TOT_ADICIO', 'SUM', {|oMdl| At740WhCob( oMdl ) }/*bCondition*/, /*bInitValue*/,STR0018 /*cTitle*/, /*bFormula*/)  // 'Tot. Cobrança Loc. Equip.'
oMdl740F:AddCalc( 'CALC_TFL', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTRH', 'TOT_RH', 'SUM', /*bCondition*/, /*bInitValue*/,STR0015 /*cTitle*/, /*bFormula*/)  // "Total Recursos Humanos"
oMdl740F:AddCalc( 'CALC_TFL', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTMI', 'TOT_MI', 'SUM', /*bCondition*/, /*bInitValue*/,STR0016 /*cTitle*/, /*bFormula*/)  // "Total Mat. Implantação"
oMdl740F:AddCalc( 'CALC_TFL', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTMC', 'TOT_MC', 'SUM', /*bCondition*/, /*bInitValue*/,STR0017 /*cTitle*/, /*bFormula*/)  // "Total Mat. Consumo"
oMdl740F:AddCalc( 'CALC_TFL', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTLE', 'TOT_LE', 'SUM', /*bCondition*/, /*bInitValue*/,STR0014 /*cTitle*/, /*bFormula*/)  // "Total Loc. Equip."
oMdl740F:AddCalc( 'CALC_TFL', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTAL', 'TOT_GERAL', 'SUM', /*bCondition*/, /*bInitValue*/,STR0019 /*cTitle*/, /*bFormula*/) // "Total Contrato"
//-----------------------------------------------------------------------------------------------------
// Mensal para os itens que não estão encerrados
//-----------------------------------------------------------------------------------------------------
oMdl740F:AddCalc( 'CALC_TFL', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTRH', 'TOT_RH_EN', 'SUM',{|oMdl|TC740VLCL(oMdl,"TOT_RH",@nDeduc,'TECA740F')},, STR0107) //"Tot.RH Real"
oMdl740F:AddCalc( 'CALC_TFL', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTMI', 'TOT_MI_EN', 'SUM',{|oMdl|TC740VLCL(oMdl,"TOT_MI")},, STR0108) //"Tot.MI Real"
oMdl740F:AddCalc( 'CALC_TFL', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTMC', 'TOT_MC_EN', 'SUM',{|oMdl|TC740VLCL(oMdl,"TOT_MC")},, STR0109) //"Tot.MC Real"
oMdl740F:AddCalc( 'CALC_TFL', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTLE', 'TOT_LE_EN', 'SUM',{|oMdl|TC740VLCL(oMdl,"TOT_LE",@nDeduc,'TECA740F')},, STR0110) //"Tot.LE Real"
oMdl740F:AddCalc( 'CALC_TFL', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTAL', 'TOT_GERAL_EN', 'SUM',{|oMdl|TC740VLCL(oMdl," ")},, STR0111) //"Total Ativo"


//-----------------------------------------------------------------------------------------------------
// Totalizadores Mensais
//-----------------------------------------------------------------------------------------------------
oMdl740F:AddCalc( 'CALC_TFL', 'TFJ_REFER', 'TFL_LOC', 'TFL_MESRH', 'TOT_MESRH', 'SUM', /*bCondition*/, /*bInitValue*/,STR0015 /*cTitle*/, /*bFormula*/) // "Total Recursos Humanos"
oMdl740F:AddCalc( 'CALC_TFL', 'TFJ_REFER', 'TFL_LOC', 'TFL_MESMI', 'TOT_MESMI', 'SUM', /*bCondition*/, /*bInitValue*/,STR0016 /*cTitle*/, /*bFormula*/) // "Total Mat. Implantação"
oMdl740F:AddCalc( 'CALC_TFL', 'TFJ_REFER', 'TFL_LOC', 'TFL_MESMC', 'TOT_MESMC', 'SUM', /*bCondition*/, /*bInitValue*/,STR0017 /*cTitle*/, /*bFormula*/) // "Total Mat. Consumo"

//-----------------------------------------------------------------------------------------------------
// Total dos impostos total e mensal
//-----------------------------------------------------------------------------------------------------
If nPosImp > 0
	oMdl740F:AddCalc( 'CALC_TFL', 'TFJ_REFER', 'TFL_LOC', 'TFL_MESIMP', 'TOT_MESIMP', 'SUM', /*bCondition*/, /*bInitValue*/,STR0020 /*cTitle*/, /*bFormula*/)  // "Total Impostos"
	oMdl740F:AddCalc( 'CALC_TFL', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTIMP', 'TOT_TOTIMP', 'SUM', /*bCondition*/, /*bInitValue*/,STR0020 /*cTitle*/, /*bFormula*/)  // "Total Impostos"
EndIf
//-----------------------------------------------------------------------------------------------------
//  Totais mensais que são exibidos na interface
//-----------------------------------------------------------------------------------------------------
oMdl740F:AddCalc( 'MES_TOT', 'TFJ_REFER', 'TFL_LOC', 'TFL_MESRH', 'TOT_MESRH', 'FORMULA',{||.T.} /*bCondition*/, /*bInitValue*/,STR0075 /*cTitle*/,;  // "Média Mensal Recursos Humanos"
		{|oMdl740F| oMdl740F:GetValue("CALC_TFL","TOT_MESRH")} /*bFormula*/)
oMdl740F:AddCalc( 'MES_TOT', 'TFJ_REFER', 'TFL_LOC', 'TFL_MESMI', 'TOT_MESMI', 'FORMULA',{||.T.} /*bCondition*/, /*bInitValue*/,STR0076 /*cTitle*/,; // "Média Mensal Mat. Implantação"
		{|oMdl740F| oMdl740F:GetValue("CALC_TFL","TOT_MESMI")} /*bFormula*/)
oMdl740F:AddCalc( 'MES_TOT', 'TFJ_REFER', 'TFL_LOC', 'TFL_MESMC', 'TOT_MESMC', 'FORMULA',{||.T.} /*bCondition*/, /*bInitValue*/,STR0077 /*cTitle*/,; // "Média Mensal Mat. Consumo"
		{|oMdl740F| oMdl740F:GetValue("CALC_TFL","TOT_MESMC")} /*bFormula*/)
If nPosImp > 0
	oMdl740F:AddCalc( 'MES_TOT', 'TFJ_REFER', 'TFL_LOC', 'TFL_MESIMP', 'TOT_MESIMP', 'FORMULA',{||.T.} /*bCondition*/, /*bInitValue*/,STR0078 /*cTitle*/,; // "Média Mensal Impostos"
		{|oMdl740F| oMdl740F:GetValue("CALC_TFL","TOT_MESIMP")} /*bFormula*/)
EndIf
oMdl740F:AddCalc( 'MES_TOT', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTMES', 'TOT_MES', 'FORMULA',{||.T.} /*bCondition*/, /*bInitValue*/,STR0079 /*cTitle*/, ; // "Média Mensal Geral"
	{|oMdl740F| oMdl740F:GetValue("MES_TOT","TOT_MESRH")+;
				oMdl740F:GetValue("MES_TOT","TOT_MESMI")+;
				oMdl740F:GetValue("MES_TOT","TOT_MESMC")+;
				If( nPosImp > 0, oMdl740F:GetValue("MES_TOT","TOT_MESIMP"), 0 ) } /*bFormula*/)
//-----------------------------------------------------------------------------------------------------
//  Totais que são exibidos na interface
//-----------------------------------------------------------------------------------------------------
oMdl740F:AddCalc( 'TOTAIS', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTRH', 'TOT_RH', 'FORMULA',{||.T.} /*bCondition*/, /*bInitValue*/,STR0015 /*cTitle*/,;
					{|oMdl740F| oMdl740F:GetValue("CALC_TFL","TOT_RH")} /*bFormula*/) // "Total Recursos Humanos"
oMdl740F:AddCalc( 'TOTAIS', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTMI', 'TOT_MI', 'FORMULA',{||.T.} /*bCondition*/, /*bInitValue*/,STR0016 /*cTitle*/,;
					{|oMdl740F| oMdl740F:GetValue("CALC_TFL","TOT_MI")} /*bFormula*/)  // "Total Material Implantação"
oMdl740F:AddCalc( 'TOTAIS', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTMC', 'TOT_MC', 'FORMULA',{||.T.} /*bCondition*/, /*bInitValue*/,STR0017 /*cTitle*/,;
					{|oMdl740F| oMdl740F:GetValue("CALC_TFL","TOT_MC")} /*bFormula*/)  // "Total Material Consumo"
If nPosImp > 0
	oMdl740F:AddCalc( 'TOTAIS', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTIMP', 'TOT_TOTIMP', 'FORMULA',{||.T.} /*bCondition*/, /*bInitValue*/,STR0020 /*cTitle*/,;
					{|oMdl740F| At740TotImp(oMdl740F)} /*bFormula*/)  // "Total Impostos"
EndIf
oMdl740F:AddCalc( 'TOTAIS', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTLE', 'TOT_LE', 'FORMULA',{||.T.} /*bCondition*/, /*bInitValue*/,STR0014 /*cTitle*/,;
					{|oMdl740F| oMdl740F:GetValue("CALC_TFL","TOT_LE")} /*bFormula*/)  // "Total Loc. Equip."
oMdl740F:AddCalc( 'TOTAIS', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTAL', 'TOT_GERAL', 'FORMULA',{||.T.} /*bCondition*/, /*bInitValue*/,STR0019 /*cTitle*/, ;
					{|oMdl740F| oMdl740F:GetValue("TOTAIS","TOT_RH")+;
								oMdl740F:GetValue("TOTAIS","TOT_MI")+;
								oMdl740F:GetValue("TOTAIS","TOT_MC")+;
								oMdl740F:GetValue("TOTAIS","TOT_LE")+;
								If( nPosImp > 0, oMdl740F:GetValue("TOTAIS","TOT_TOTIMP"), 0 ) } /*bFormula*/)  // "Total Contrato"

oMdl740F:AddCalc( 'TOTAIS', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTAL', 'TOT_GERAL_EN', 'FORMULA',{|| .T.}  /*bCondition*/, /*bInitValue*/,STR0111 /*cTitle*/,;
	{|oModel| (oModel:GetValue("CALC_TFL","TOT_RH_EN");
			+oModel:GetValue("CALC_TFL","TOT_MI_EN");
			+oModel:GetValue("CALC_TFL","TOT_MC_EN");
			+oModel:GetValue("CALC_TFL","TOT_LE_EN"))-nDeduc} /*bFormula*/)  // "Total Ativo"


//-----------------------------------------------------------------------------------------------------
//Fim dos totais exibidos
//-----------------------------------------------------------------------------------------------------

oMdlCalc := oMdl740F:GetModel("TOTAIS")
oMdlCalc:AddEvents("TOTAIS","TOT_GERAL","",{||.T.})

If lHasOrcSim
	At740MdSm(oStrTFJ)
EndIf
If lPutLeg
	At740AddLeg(.T.,{oStrTFL},{oStrTFF},{oStrTFI})
EndIf


oMdl740F:SetActivate( {|oMdl740F| InitDados( oMdl740F ) } )

Return oMdl740F


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da interface

@since   	10/09/2013
@version 	P11.90

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oCharge 	:= At740GLoad()
Local oView   	:= Nil
Local oModel  	:= If( oCharge <> NIl, oCharge, ModelDef() )
Local lConExt 	:= IsInCallStack("At870GerOrc")
Local cMenuRH 	:= ""
Local cMenuMI 	:= ""
Local cMenuMC 	:= ""
Local cView   	:= ""
Local cAbaRH  	:= ""
Local cAreaRH 	:= ""
Local nPosImp 	:= 0
Local oStrTFJ  	:= Nil
Local oStrTFL  	:= Nil
Local oStrTFF  	:= Nil
Local oStrABP  	:= Nil
Local oStrTFG  	:= Nil
Local oStrTFH  	:= Nil
Local oStrTFI  	:= Nil
Local oStrTFU  	:= Nil
Local oStrTEV 	:= Nil
Local oStrCalc 	:= FWCalcStruct( oModel:GetModel('TOTAIS') )
Local oStrCMes 	:= FWCalcStruct( oModel:GetModel('MES_TOT') )
Local aTabPrc 	:= At600GetTab()
Local cTabela 	:= If( aTabPrc[1] <> Nil, aTabPrc[1], "" )
Local cRevisa	:= If( aTabPrc[2] <> Nil, aTabPrc[2], "" )
Local nI, oStrIMP
Local cGsDsGcn 		:= ""
Local lHasOrcSim	:= HasOrcSimp()
Local lAt870Revi 	:= IsInCallStack("At870Revis")
Local aTFJFields 	:= Nil
Local lOrcsim		:= SuperGetMV("MV_ORCSIMP",,'2') == '1'
Local lGSRH 		:= GSGetIns("RH")
Local lGSMIMC  		:= GSGetIns("MI")
Local lGSLE 		:= GSGetIns("LE")
Local lTecXRh		:= SuperGetMv("MV_TECXRH",,.F.)

Local lOrcPrc 		:= SuperGetMv("MV_ORCPRC",,.F.)
Local lAbtInss		:= TFF->( ColumnPos('TFF_ABTINS') ) > 0 .AND. SuperGetMv("MV_GSDSGCN",,"2") == "2"
Local lTecItExtOp 	:= IsInCallStack("At190dGrOrc")
Local aStrTbl		:= {}
Local cNExibCmp		:= "" 

oStrTFJ  	:= FWFormStruct(2, 'TFJ', {|cCpo| At740SelFields( 'TFJ', Alltrim(cCpo), lOrcPrc, lHasOrcSim, lAbtInss ) } )
oStrTFL  	:= FWFormStruct(2, 'TFL', {|cCpo| At740SelFields( 'TFL', Alltrim(cCpo), lOrcPrc, lHasOrcSim, lAbtInss ) } )
oStrTFF  	:= FWFormStruct(2, 'TFF', {|cCpo| At740SelFields( 'TFF', Alltrim(cCpo), lOrcPrc, lHasOrcSim, lAbtInss ) } )
oStrABP  	:= FWFormStruct(2, 'ABP', {|cCpo| At740SelFields( 'ABP', Alltrim(cCpo), lOrcPrc, lHasOrcSim, lAbtInss ) } )
oStrTFG  	:= FWFormStruct(2, 'TFG', {|cCpo| At740SelFields( 'TFG', Alltrim(cCpo), lOrcPrc, lHasOrcSim, lAbtInss ) } )
oStrTFH  	:= FWFormStruct(2, 'TFH', {|cCpo| At740SelFields( 'TFH', Alltrim(cCpo), lOrcPrc, lHasOrcSim, lAbtInss ) } )
oStrTFI  	:= FWFormStruct(2, 'TFI', {|cCpo| At740SelFields( 'TFI', Alltrim(cCpo), lOrcPrc, lHasOrcSim, lAbtInss ) } )
oStrTFU  	:= FWFormStruct(2, 'TFU', {|cCpo| At740SelFields( 'TFU', Alltrim(cCpo), lOrcPrc, lHasOrcSim, lAbtInss ) } )
oStrTEV  	:= FWFormStruct(2, 'TEV', {|cCpo| At740SelFields( 'TEV', Alltrim(cCpo), lOrcPrc, lHasOrcSim, lAbtInss ) } )
aTFJFields 	:= oStrTFJ:GetFields()

oStrTFF:AddField( 	"TFF_LOADPRC", "zz", STR0118, STR0118,Nil,"L", /*"@E 99,999,999.99"*/, NIL, "",.F.,NIL,NIL, {},Nil,NIL,.T.,NIL )
oStrTFG:AddField( 	"TFG_VLRMESMI", "zz", STR0051, STR0051,Nil,"N", "@E 99,999,999.99", NIL, "",.F.,NIL,NIL, {},Nil,NIL,.T.,NIL ) // "Total Mês" ### "Total Mês"
oStrTFH:AddField( 	"TFH_VLRMESMC", "zz", STR0051, STR0051,Nil,"N", "@E 99,999,999.99", NIL, "",.F.,NIL,NIL, {},Nil,NIL,.T.,NIL ) // "Total Mês" ### "Total Mês"

// Carrega as informaões para a montagens das estruturas
If Len(aPrcOrc) == 0
	aPrcOrc := At740FPrc( cTabela, cRevisa )
EndIf
At740FStru( @aPrcOrc, .F. )

If TFF->( ColumnPos('TFF_TABXML') ) > 0
	oStrTFF:RemoveField( "TFF_TABXML" )
	oStrTFF:RemoveField( "TFF_LOADPRC" )
EndIf

oStrTFJ:RemoveField( "TFJ_TABXML" )

If TFL->( ColumnPos('TFL_ATCC') ) > 0 .AND. !(isInCallStack("At870PRev"))
	oStrTFL:RemoveField("TFL_ATCC")
EndIf

If oStrTFJ:HasField("TFJ_CODTAB") .AND. oStrTFJ:HasField("TFJ_TABREV")
	oStrTFJ:SetProperty( "TFJ_CODTAB", MVC_VIEW_CANCHANGE, .F. )
	oStrTFJ:SetProperty( "TFJ_TABREV", MVC_VIEW_CANCHANGE, .F. )
EndIf

If lConExt
	oStrTFJ:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
ElseIf lAt870Revi
	If FindFunction("At740Habil")
		At740Habil(aTFJFields, oStrTFJ)
	Else
		oStrTFJ:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
	EndIF
EndIf

If lGSLE .OR. ((TFL->( ColumnPos('TFL_DTENCE') ) > 0 .AND. TFF->( ColumnPos('TFF_DTENCE') ) == 0) .OR. (TFL->( ColumnPos('TFL_DTENCE') ) == 0 .AND. TFF->( ColumnPos('TFF_DTENCE') ) > 0))
	If TFL->( ColumnPos('TFL_DTENCE') ) > 0
		oStrTFL:RemoveField('TFL_DTENCE')
	EndIf

	If TFF->( ColumnPos('TFF_DTENCE') ) > 0
		oStrTFF:RemoveField('TFF_DTENCE')
	EndIf
Else
	If TFL->( ColumnPos('TFL_DTENCE') ) > 0
		oStrTFL:SetProperty("TFL_DTENCE", MVC_VIEW_CANCHANGE, .F.)
	EndIf

	If TFF->( ColumnPos('TFF_DTENCE') ) > 0
		oStrTFF:SetProperty("TFF_DTENCE", MVC_VIEW_CANCHANGE, .F.)
	EndIf
EndIf

oViw740F := FWFormView():New()
oViw740F:SetModel(oModel)
oViw740F:AddField('VIEW_REFER', oStrTFJ, 'TFJ_REFER' )
oViw740F:AddGrid('VIEW_LOC'   , oStrTFL, 'TFL_LOC')
oViw740F:AddGrid('VIEW_RH'    , oStrTFF, 'TFF_RH')

// Criação dos fields dinamicos para o RH
For nI:=1 To Len(aPrcOrc)
	If Empty(AllTrim(aPrcOrc[nI][1]))
		Loop
	EndIf
	cView := aPrcOrc[nI][4][2]	// Indica o nome da view a ser criada
	// Assume a nova estrutura da view
	&("oStrR" + StrZero(nI,3)) := aPrcOrc[nI][4][1]
	oViw740F:AddField( cView, &("oStrR" + StrZero(nI,3)), aPrcOrc[nI][3][2] )
Next nI

//Criação do field dinamico para os impostos
nPosImp := aScan( aPrcOrc, { |x| x[1] == Replicate( " ", 30 ) } ) // Verifica a posição do array de impostos

If nPosImp > 0
	// Assume a nova estrutura da view
	oStrIMP := aPrcOrc[nPosImp][4][1]
	oViw740F:AddField( "VIEW_IMP", oStrIMP, aPrcOrc[nPosImp][3][2] )
	aAdd( aPrcOrc[nPosImp][4], "VIEW_IMP" ) // Adiciona a referencia do model para utilização na view
EndIf

oViw740F:AddGrid('VIEW_MI'    , oStrTFG, 'TFG_MI' )
oViw740F:AddGrid('VIEW_MC'    , oStrTFH, 'TFH_MC' )

oViw740F:SetFieldAction( 'TFJ_GESMAT', { || F740FLockGrd(oViw740F:getModel()), oViw740F:Refresh( 'VIEW_MI' ), oViw740F:Refresh( 'VIEW_MC' ) } )

If !lConExt
	oViw740F:AddGrid('VIEW_BENEF' , oStrABP, 'ABP_BENEF')
	oViw740F:AddGrid('VIEW_HE'    , oStrTFU, 'TFU_HE')
	oViw740F:AddGrid('VIEW_LE'    , oStrTFI, 'TFI_LE')
	oViw740F:AddGrid('VIEW_ADICIO', oStrTEV, 'TEV_ADICIO')
EndIf

oViw740F:AddField( "VIEW_CMES", oStrCMes, "MES_TOT" )
oViw740F:AddField( "VIEW_CALC", oStrCalc, "TOTAIS" )
oViw740F:AddField( "VIEW_CALCR", oStrCalc, "TOTAIS" )
oStrTFF:RemoveField( "TFF_CALCMD" )
oStrTFF:RemoveField( "TFF_PROCES" )
oStrTFF:RemoveField( "TFF_PLACOD" )
oStrTFF:RemoveField( "TFF_PLAREV" )
oStrTFI:RemoveField( "TFI_SEPSLD" )
oStrTFI:RemoveField( "TFI_CALCMD" )
oStrTFI:RemoveField( "TFI_PLACOD" )
oStrTFI:RemoveField( "TFI_PLAREV" )
oStrTFF:SetProperty( "TFF_PRCVEN", MVC_VIEW_CANCHANGE, .F. )
oStrTFH:RemoveField( "TFH_TES")
oStrTFG:RemoveField( "TFG_TES")


If (oModel:GetOperation() == MODEL_OPERATION_INSERT .AND. !(IsInCallStack("TECA870"))) .OR.;
		 (lHasOrcSim .AND. (IsInCallStack("TECA745") .AND. IsInCallStack("a745IncOrc")))
	cGsDsGcn	:= SuperGetMv("MV_GSDSGCN",,"2")
Else
	cGsDsGcn	:= TFJ->TFJ_DSGCN
EndIf

If  cGsDsGcn == "1"
	//Retira os campos da View
	oStrTFJ:RemoveField('TFJ_GRPRH')
	oStrTFJ:RemoveField('TFJ_GRPMI')
	oStrTFJ:RemoveField('TFJ_GRPMC')
	oStrTFJ:RemoveField('TFJ_GRPLE')
	oStrTFJ:RemoveField('TFJ_TES')
	oStrTFJ:RemoveField('TFJ_TESMI')
	oStrTFJ:RemoveField('TFJ_TESMC')
	oStrTFJ:RemoveField('TFJ_TESLE')
	oStrTFJ:RemoveField('TFJ_DSCRH')
	oStrTFJ:RemoveField('TFJ_DSCMI')
	oStrTFJ:RemoveField('TFJ_DSCMC')
	oStrTFJ:RemoveField('TFJ_DSCLE')

	oStrTFF:SetProperty('TFF_TESPED', MVC_VIEW_ORDEM, Soma1(oStrTFF:GetProperty('TFF_PERFIM', MVC_VIEW_ORDEM)))
	oStrTFG:SetProperty('TFG_TESPED', MVC_VIEW_ORDEM, Soma1(oStrTFG:GetProperty('TFG_PERFIM', MVC_VIEW_ORDEM)))
	oStrTFH:SetProperty('TFH_TESPED', MVC_VIEW_ORDEM, Soma1(oStrTFH:GetProperty('TFH_PERFIM', MVC_VIEW_ORDEM)))
	oStrTFI:SetProperty('TFI_TESPED', MVC_VIEW_ORDEM, Soma1(oStrTFI:GetProperty('TFI_PERFIM', MVC_VIEW_ORDEM)))
	If TFF->( ColumnPos('TFF_CODLIM') ) > 0
		oStrTFF:SetProperty('TFF_CODLIM', MVC_VIEW_ORDEM, Soma1(oStrTFF:GetProperty('TFF_NOMESC', MVC_VIEW_ORDEM)))
	EndIf
Else
	oStrTFF:RemoveField('TFF_TESPED')
	oStrTFG:RemoveField('TFG_TESPED')
	oStrTFH:RemoveField('TFH_TESPED')
	oStrTFI:RemoveField('TFI_TESPED')
	//RH
	If !lGSRH
		oStrTFJ:RemoveField('TFJ_GRPRH')
		oStrTFJ:RemoveField('TFJ_DSCRH')
		oStrTFJ:RemoveField('TFJ_TES')
	EndIf
	//MI/MC
	If !lGSMIMC
		oStrTFJ:RemoveField('TFJ_GRPMI')
		oStrTFJ:RemoveField('TFJ_DSCMI')
		oStrTFJ:RemoveField('TFJ_TESMI')
		oStrTFJ:RemoveField('TFJ_GRPMC')
		oStrTFJ:RemoveField('TFJ_DSCMC')
		oStrTFJ:RemoveField('TFJ_TESMC')
	EndIf
	//LE
	If !lGSLE
		oStrTFJ:RemoveField('TFJ_GRPLE')
		oStrTFJ:RemoveField('TFJ_DSCLE')
		oStrTFJ:RemoveField('TFJ_TESLE')
	EndIf
EndIf

If lTecXRh .OR. !lGSLE
	oStrTFJ:RemoveField('TFJ_CLIPED')
EndIf

If TFJ->( ColumnPos('TFJ_DTPLRV') ) > 0
	oStrTFJ:RemoveField("TFJ_DTPLRV")
EndIf

If isInCallStack("At870GerOrc")
	oStrTFF:SetProperty('TFF_COBCTR', MVC_VIEW_ORDEM, '02')
	oStrTFG:SetProperty('TFG_COBCTR', MVC_VIEW_ORDEM, '02')
	oStrTFH:SetProperty('TFH_COBCTR', MVC_VIEW_ORDEM, '02')
EndIf

If TFL->( ColumnPos('TFL_ATCC') ) > 0 .AND. isInCallStack("At870PRev")
	oStrTFL:SetProperty('TFL_ATCC', MVC_VIEW_ORDEM, Soma1(oStrTFL:GetProperty('TFL_DTFIM', MVC_VIEW_ORDEM)))
EndIf

If lHasOrcSim .AND. !lOrcsim
	oStrTFJ:RemoveField('TFJ_VEND')
Endif

If lTecItExtOp
	//Ponto de entrada para não exibir os campos no item extra operacional 
	If ExistBlock("a740NExib")
		cNExibCmp := ExecBlock("a740NExib",.F.,.F.)
	EndIf
	aStrTbl := oModel:Getmodel("TFL_LOC"):GetStruct():GetFields() 
	For nI := 1 To Len(aStrTbl)
		If aStrTbl[nI,4] == "N" .Or. AllTrim(aStrTbl[nI,3]) $ cNExibCmp
			oStrTFL:RemoveField(aStrTbl[nI,3])
		Endif
	Next nI
	aStrTbl := oModel:Getmodel("TFF_RH"):GetStruct():GetFields()
	For nI := 1 To Len(aStrTbl)
		If aStrTbl[nI,4] == "N" .And. aStrTbl[nI,3] <> "TFF_QTDVEN" .Or.;
		    AllTrim(aStrTbl[nI,3]) $ cNExibCmp
			oStrTFF:RemoveField(aStrTbl[nI,3])
		Endif
	Next nI
Endif

If !lTecItExtOp
	// Botão para cálculo
	oViw740F:AddOtherObject("BTN_CLCRH", {|oPanel| At740FBCalc(oPanel, 1)})
	oViw740F:AddOtherObject("BTN_LOAD", {|oPanel| At740FBLoad(oPanel, 1)})
Endif

If nPosImp > 0
	oViw740F:AddOtherObject("BTN_CLCI", {|oPanel| At740FBCalc(oPanel, 2)})
EndIf

// Adiciona as visões na tela
oViw740F:CreateHorizontalBox( "TOP"   , 35 )
oViw740F:CreateHorizontalBox( "MIDDLE", 65 )

// Criação das abas principais
oViw740F:CreateFolder( "ABAS", "MIDDLE" )
oViw740F:AddSheet( "ABAS", "ABA01", STR0022 )  // 'Locais de Atendimento'
oViw740F:AddSheet( "ABAS", "ABA02", STR0007 )  // 'Recursos Humanos'
oViw740F:AddSheet( "ABAS", "ABA04", STR0023 )  // "Materiais"

If nPosImp > 0
	oViw740F:AddSheet( "ABAS", "ABA05", STR0024 )  // "Impostos"
EndIf

If !lConExt
	oViw740F:AddSheet( "ABAS", "ABA03", STR0011 )  // 'Locação de Equipamentos'
EndIf
oViw740F:AddSheet( "ABAS", "ABA06", STR0025 )  // "Resumo Geral"
oViw740F:AddSheet( "ABAS", "ABA07", STR0074 )  // "Resumo Geral Recorrente"

// Criação da area da aba Locais de Atendimento
oViw740F:CreateHorizontalBox( "ID_ABA01", 100,,, "ABAS", "ABA01" )

// Criação das areas da aba Recursos Humanos
oViw740F:CreateHorizontalBox( "ID_ABA02", 047,,, "ABAS", "ABA02" ) // Define a área de RH
oViw740F:CreateHorizontalBox( "ID_A02A", 047,,, "ABAS", "ABA02" ) // área dos acionais relacionados com RH
oViw740F:CreateHorizontalBox( "ID_A02B", 006,,, "ABAS", "ABA02" ) // área do botão de cálculo
oViw740F:CreateVerticalBox( "ID_A02V1", 076,'ID_A02B',, "ABAS", "ABA02" )
oViw740F:CreateVerticalBox( "ID_A02V2", 012,'ID_A02B',, "ABAS", "ABA02" )
oViw740F:CreateVerticalBox( "ID_A02V3", 012,'ID_A02B',, "ABAS", "ABA02" )

// Criação da area da aba Materiais
oViw740F:CreateHorizontalBox( "ID_ABA04" , 100,,, "ABAS", "ABA04" )

If nPosImp > 0
	// Criação da area da aba Impostos
	oViw740F:CreateHorizontalBox( "ID_ABA05", 094,,, "ABAS", "ABA05" )
	oViw740F:CreateHorizontalBox( "ID_A05A", 006,,, "ABAS", "ABA05" ) // área do botão de cálculo
	oViw740F:CreateVerticalBox( "ID_A05V1", 088,'ID_A05A',, "ABAS", "ABA05" )
	oViw740F:CreateVerticalBox( "ID_A05V2", 012,'ID_A05A',, "ABAS", "ABA05" )
EndIf

// Criação da área de Locação de Equipamentos
If !lConExt
	oViw740F:CreateHorizontalBox( "ID_ABA03" , 060,,, "ABAS", "ABA03" )
	oViw740F:CreateHorizontalBox( "ID_ABA03A", 040,,, "ABAS", "ABA03" )
EndIf

// Criação da area de Resumo Geral
oViw740F:CreateHorizontalBox( "ID_ABA06" , 100,,, "ABAS", "ABA06" )
oViw740F:CreateVerticalBox( "MES_CONTR", 045, "ID_ABA06",, "ABAS", "ABA06" ) 	// Valor total do contrato
oViw740F:CreateVerticalBox( "ESP_CONTR", 010, "ID_ABA06",, "ABAS", "ABA06" ) 	// Divisor de tela
oViw740F:CreateVerticalBox( "TOT_CONTR", 045, "ID_ABA06",, "ABAS", "ABA06")		// Valor mensal do contrato

// Criação da area de Resumo Geral Recorrente
oViw740F:CreateHorizontalBox( "ID_ABA07" , 100,,, "ABAS", "ABA07" )
// Criação das abas para Recursos Humanos
oViw740F:CreateFolder( "RH_ABAS", "ID_A02A")

// Criação das abas e areas dinamicas para o RH
For nI:=1 To Len(aPrcOrc)
	If Empty(AllTrim(aPrcOrc[nI][1]))
		Loop
	EndIf
	cAbaRH  := "RH_ABAD" + StrZero(nI,3)
	cAreaRH := "ID_RH_D" + StrZero(nI,3)
	oViw740F:AddSheet( "RH_ABAS", cAbaRH, AllTrim(aPrcOrc[nI][1]) ) 		// Define as abas dinamicas
	oViw740F:CreateHorizontalBox( cAreaRH, 100,,, "RH_ABAS", cAbaRH ) 	// Define a área das abas dinamicas
	oViw740F:SetOwnerView( aPrcOrc[nI][4][2], cAreaRH ) 					// Informa a area a ser colocado o fields
Next nI

If !lConExt
	// Abas de Auxiliares
	oViw740F:AddSheet("RH_ABAS", "RH_ABAAUX01", STR0026 ) // 'Verbas'
	oViw740F:AddSheet("RH_ABAS", "RH_ABAAUX02", STR0027 ) // 'Hora Extra'
	// Area das abas Auxiliares
	oViw740F:CreateHorizontalBox( "ID_RH_A01" , 100,,, "RH_ABAS", "RH_ABAAUX01" ) // Define a área de Benefícios item de Rh
	oViw740F:CreateHorizontalBox( "ID_RH_A02" , 100,,, "RH_ABAS", "RH_ABAAUX02" ) // Define a área da Hora Extra
EndIf

// Criação das abas para Material de Implantação e Material de Consumo
oViw740F:CreateFolder( "MT_ABAS", "ID_ABA04")
oViw740F:AddSheet( "MT_ABAS", "MT_ABAS01", STR0008 ) // 'Materiais de Implantação'
oViw740F:AddSheet( "MT_ABAS", "MT_ABAS02", STR0009 ) // 'Materiais de Consumo'

// Criação das areas para Material de Implantação e Material de Cosumo
oViw740F:CreateHorizontalBox( "ID_MT_01", 100,,, "MT_ABAS", "MT_ABAS01" ) 	// Materiais de Implantação
oViw740F:CreateHorizontalBox( "ID_MT_02", 100,,, "MT_ABAS", "MT_ABAS02" ) 	// Materiais de Consumo

// Faz a amarração das VIEWs dos modelos com as divisões na interface
oViw740F:SetOwnerView( "VIEW_REFER"	, "TOP"   		) // Cabeçalho
oViw740F:SetOwnerView( "VIEW_LOC"  	, "ID_ABA01"  )  // Grid Locais de Atendimento
oViw740F:SetOwnerView( "VIEW_RH"  		, "ID_ABA02"	)  // Grid RH

If !lConExt
	oViw740F:SetOwnerView( "VIEW_BENEF", "ID_RH_A01" )  // Grid Benefícios
	oViw740F:SetOwnerView( "VIEW_HE"   , "ID_RH_A02" )  // Grid Hora Extra
EndIf

If !lTecItExtOp
	// Criação dos Botões de Cálculo
	oViw740F:SetOwnerView( "BTN_LOAD", "ID_A02V2" )
	oViw740F:SetOwnerView( "BTN_CLCRH", "ID_A02V3" )	// Botão de Cálculo - Recursos Humanos
Endif

If nPosImp > 0
	oViw740F:SetOwnerView( "BTN_CLCI", "ID_A05V2" )	// Botão de Cálculo - Impostos
EndIf

oViw740F:SetOwnerView( "VIEW_MI", "ID_MT_01" )  // Grid Materiais de Implantação
oViw740F:SetOwnerView( "VIEW_MC", "ID_MT_02" )  // Grid Materiais de Consumo

// Aba totais do contrato
oViw740F:SetOwnerView( "VIEW_CALC", "TOT_CONTR" ) // Totais
oViw740F:SetOwnerView( "VIEW_CMES", "MES_CONTR" )  // Area de Totais Mensais do Contrato

oViw740F:SetOwnerView( "VIEW_CALCR", "ID_ABA07" ) // Totais
// Criação das telas para impostos

If nPosImp > 0
	oViw740F:SetOwnerView( aPrcOrc[nPosImp][4][2], "ID_ABA05" )
EndIf

If !lConExt
	oViw740F:SetOwnerView( "VIEW_LE"  		, "ID_ABA03"	)  // Grid Locação de Equipamentos
	oViw740F:SetOwnerView( "VIEW_ADICIO"	, "ID_ABA03A"	)	// Grid Cobrança de Alocação
	oViw740F:EnableTitleView( 'VIEW_ADICIO', STR0013 )  // 'Cobrança da Locação'
EndIf

//-- Ponto de entrada para adicionar grid a view
If ExistBlock("a740GrdV")
	ExecBlock("a740GrdV",.F.,.F.,{@oViw740F,oViw740F:aFolders})
EndIf

oViw740F:EnableTitleView( "VIEW_CMES", STR0080 ) 			// "Média Mensal"
oViw740F:EnableTitleView( "VIEW_CALC", STR0029 ) 			// "Valor Total do Contrato"
oViw740F:EnableTitleView( "VIEW_CALCR", STR0028 ) 			// "Valor Total do Contrato Recorrente"
oViw740F:AddIncrementField( 'VIEW_MC', 'TFH_ITEM' )
oViw740F:AddIncrementField( 'VIEW_MI', 'TFG_ITEM' )
oViw740F:AddIncrementField( 'VIEW_RH', 'TFF_ITEM' )

If !lConExt
	oViw740F:AddIncrementField( 'VIEW_BENEF', 'ABP_ITEM' )
	oViw740F:AddIncrementField( 'VIEW_ADICIO', 'TEV_ITEM' )
	oViw740F:AddIncrementField( 'VIEW_LE', 'TFI_ITEM' )
EndIf

oViw740F:SetAfterViewActivate( { |oViw740F| At740Refre(oViw740F) } )
SetKey( VK_F4, { || AT740F4() } )

If !(IsInCallStack("At870GerOrc"))
	If lGSLE
		oViw740F:AddUserButton( STR0069," ", {|| At740ConEq()},,,) //"Consulta Equipamentos"
	EndIF
	oViw740F:AddUserButton(STR0068,"",{|oModel,oViw740F| TEC740FACI(oModel)},,,)	// "Facilitador"

	// Somente habilita o menu caso nao for vistoria
	If !FT600GETVIS()
		oViw740F:AddUserButton(STR0053,"",{|oModel| AT352TDX(oModel)},,,) //"Vinculo de Beneficios"
	EndIf
EndIf

oViw740F:AddUserButton("Posicionar","",{|oViw740F| At740FPosR(oViw740F)},,,)

If lHasOrcSim
	At740VwSm(oStrTFJ)
EndIf
// atribui o modelo da carga ao objeto do modelo do orçamento com precificação
If oCharge <> Nil
	oMdl740F := oCharge
EndIf

If lPutLeg
	At740AddLeg(.F.,{oStrTFL,'VIEW_LOC' },{oStrTFF,'VIEW_RH'},{oStrTFI,'VIEW_LE'},oViw740F)
EndIf

oViw740F:SetViewProperty( 'VIEW_LOC', "CHANGELINE", {{ |oView, cViewID| a740ChgLine(oView, cViewID) }} )
oViw740F:SetViewProperty( 'VIEW_RH', "CHANGELINE", {{ |oView, cViewID| a740ChgLine(oView, cViewID) }} )
If !lConExt
	oViw740F:SetViewProperty( 'VIEW_LE', "CHANGELINE", {{ |oView, cViewID| a740ChgLine(oView, cViewID) }} )
EndIf

oViw740F:SetViewProperty( 'VIEW_MI', "CHANGELINE", {{ |oView, cViewID| a740ChgLine(oView, cViewID) }} )
oViw740F:SetViewProperty( 'VIEW_MC', "CHANGELINE", {{ |oView, cViewID| a740ChgLine(oView, cViewID) }} )

oViw740F:SetAfterViewActivate({ || F740FLockGrd(oViw740F:getModel()), TEC740FRFS(oViw740F) })

If IsInCallStack("TECA745")
	oViw740F:AddUserButton(STR0106,"",{|| At745ImpVs()},,,) // "Incluir Vistoria"
EndIf

If !lGSRH
	oViw740F:HideFolder('ABAS',STR0007,  2)// 'Recursos Humanos'
EndIf

If !lGSMIMC .Or. lTecItExtOp
	oViw740F:HideFolder('ABAS', STR0023, 2) //Materiais
EndIf

If !lGSLE .Or. lTecItExtOp
	oViw740F:HideFolder('ABAS', STR0011, 2)  // 'Locação de Equipamentos'
EndIf

If lTecItExtOp
	oViw740F:HideFolder('ABAS', STR0025, 2) //"Resumo Geral"
	oViw740F:HideFolder('ABAS', STR0074, 2) //"Resumo Geral Recorrente"

	If nPosImp > 0
		oViw740F:HideFolder('ABAS', STR0024, 2) //"Impostos"
	EndIf

	For nI:=1 To Len(aPrcOrc)
		If Empty(AllTrim(aPrcOrc[nI][1]))
			Loop
		EndIf
		oViw740F:HideFolder( "RH_ABAS", AllTrim(aPrcOrc[nI][1]), 2 ) // Define as abas dinamicas
	Next nI
EndIf

Return oViw740F

//------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados


@sample 	InitDados(  )

@since		23/09/2013
@version	P11.90

@param  	oMdlGer, Objeto, objeto geral do model que será alterado

/*/
//------------------------------------------------------------------------------
Static Function InitDados( oMdlGer )

Local oMdlLoc		:= oMdlGer:GetModel("TFL_LOC")
Local oMdlRh		:= oMdlGer:GetModel("TFF_RH")
Local oMdlHrExtr 	:= oMdlGer:GetModel("TFU_HE")
Local oMdlMatImp 	:= oMdlGer:GetModel("TFG_MI")
Local oMdlMatCons 	:= oMdlGer:GetModel("TFH_MC")
Local oMdlLE 		:= oMdlGer:GetModel("TFI_LE")
//
Local oMdlTFJ		:= oMdlGer:GetModel("TFJ_REFER")
Local oMdlTotais	:= oMdlGer:GetModel('TOTAIS')
Local oMdlIMPORC	:= Nil
Local oMdlCTFL		:= oMdlGer:GetModel('CALC_TFL')
Local oMdlMes 		:= oMdlGer:GetModel('MES_TOT')
Local oMdlBen		:=	oMdlGer:GetModel("ABP_BENEF")

Local nLinLoc	:= 0
Local nLinRh	:= 0
Local aSaveRows := {}

Local nTotGerMI := 0
Local nTotGerMC := 0
Local nTotGerLE := 0
Local nTotGerRH := 0
Local nTotGeral := 0
Local nTotMI    := 0
Local nTotMC    := 0
Local nTotal    := 0

Local aTabPrc := At600GetTab()
Local cTabela := If( aTabPrc[1] <> Nil, aTabPrc[1], "" )
Local cRevisa := If( aTabPrc[2] <> Nil, aTabPrc[2], "" )

Local nI		:= 0
Local nJ		:= 0
Local ny		:= 1
Local nx		:= 1
Local nw		:= 1
Local uValor	:= nil
Local nPosNick	:= 0
Local cPicture	:= '@!'
Local nMesVlr 	:= 0
Local dDatIni		:= CToD('')
Local dDatFim		:= CToD('')
Local nVlrImp		:= 0
Local nPosImp		:= aScan( aPrcOrc, { |x| x[1] == Replicate( " ", 30 ) } ) // Verifica a posição do array de impostos
Local nValImpTot 		:= 0
Local nValImpMes  	:= 0

Local nTLuc := oMdlTFJ:GetValue("TFJ_LUCRO")
Local nTAdm := oMdlTFJ:GetValue("TFJ_ADM")
Local cTABXML := ''
Local oStrTFJ := oMdlGer:GetModel('TFJ_REFER'):GetStruct()
Local oStrTFL := oMdlGer:GetModel('TFL_LOC'):GetStruct()

Local oStrTFF := oMdlRh:GetStruct()
Local oStrTFG := oMdlMatImp:GetStruct()
Local oStrTFH := oMdlMatCons:GetStruct()
Local oStrTFI := oMdlLE:GetStruct()


Local cGsDsGcn	:= ""
Local lTFFXML	:= TFF->( ColumnPos('TFF_TABXML') ) > 0
Local lTeca270	:= IsInCallStack("TECA270")
Local lOrcSim	:= SuperGetMv("MV_ORCSIMP",,'2') == '1'
Local lHasOrcSim	:= HasOrcSimp()
Local cItem := "00"

Local lGSRH := GSGetIns("RH")
Local lGSMIMC  :=  GSGetIns("MI")
Local lGSLE :=  GSGetIns("LE")

If ExistBlock('AT740INITD')
	ExecBlock('AT740INITD', .F. , .F. , {oMdlGer} )
EndIf

If lHasOrcSim
	If !IsInCallStack("At270Orc") .And. oMdlGer:GetOperation() <> MODEL_OPERATION_DELETE
		IF lTeca270 .AND. lOrcSim
			oMdlGer:GetModel("TFJ_REFER"):LoadValue("TFJ_CODVIS", M->AAT_CODVIS)
		EndIf
	EndIf
EndIf

If oMdlGer:GetOperation() == MODEL_OPERATION_INSERT .And. !IsInCallStack("TECA870")
	cGsDsGcn	:= SuperGetMv("MV_GSDSGCN",,"2")
Else
	cGsDsGcn	:= TFJ->TFJ_DSGCN
EndIf

oStrTFH:SetProperty('TFH_TES',MODEL_FIELD_OBRIGAT,.F.)
oStrTFG:SetProperty('TFG_TES',MODEL_FIELD_OBRIGAT,.F.)
If cGsDsGcn == "1"
	//Retira a obrigatoriedade dos campos
	oStrTFJ:SetProperty('TFJ_GRPRH',MODEL_FIELD_OBRIGAT,.F.)
	oStrTFJ:SetProperty('TFJ_GRPMI',MODEL_FIELD_OBRIGAT,.F.)
	oStrTFJ:SetProperty('TFJ_GRPMC',MODEL_FIELD_OBRIGAT,.F.)
	oStrTFJ:SetProperty('TFJ_GRPLE',MODEL_FIELD_OBRIGAT,.F.)
	oStrTFJ:SetProperty('TFJ_TES',MODEL_FIELD_OBRIGAT,.F.)
	oStrTFJ:SetProperty('TFJ_TESMI',MODEL_FIELD_OBRIGAT,.F.)
	oStrTFJ:SetProperty('TFJ_TESMC',MODEL_FIELD_OBRIGAT,.F.)
	oStrTFJ:SetProperty('TFJ_TESLE',MODEL_FIELD_OBRIGAT,.F.)
	//Novos campos de TES obrigatórios

	oStrTFF:SetProperty('TFF_TESPED',MODEL_FIELD_OBRIGAT,.T.)
	oStrTFG:SetProperty('TFG_TESPED',MODEL_FIELD_OBRIGAT,.T.)
	oStrTFH:SetProperty('TFH_TESPED',MODEL_FIELD_OBRIGAT,.T.)
	oStrTFI:SetProperty('TFI_TESPED',MODEL_FIELD_OBRIGAT,.T.)
Else
		//Retira a obrigatoriedade dos campos caso o contexto não seja utilizado
	//RH
	If !lGSRH
		oStrTFJ:SetProperty('TFJ_GRPRH',MODEL_FIELD_OBRIGAT,.F.)
		oStrTFJ:SetProperty('TFJ_TES',MODEL_FIELD_OBRIGAT,.F.)
	EndIf

	//MI
	If !lGSMIMC
		oStrTFJ:SetProperty('TFJ_GRPMI',MODEL_FIELD_OBRIGAT,.F.)
		oStrTFJ:SetProperty('TFJ_GRPMC',MODEL_FIELD_OBRIGAT,.F.)
		oStrTFJ:SetProperty('TFJ_TESMI',MODEL_FIELD_OBRIGAT,.F.)
		oStrTFJ:SetProperty('TFJ_TESMC',MODEL_FIELD_OBRIGAT,.F.)
	EndIf

	//LE
	If !lGSLE
		oStrTFJ:SetProperty('TFJ_GRPLE',MODEL_FIELD_OBRIGAT,.F.)
		oStrTFJ:SetProperty('TFJ_TESLE',MODEL_FIELD_OBRIGAT,.F.)
	EndIf
EndIf

If nPosImp > 0
	oMdlIMPORC	:= oMdlGer:GetModel('IMP_ORC')
EndIf

aSaveRows := FwSaveRows()

If Valtype(oFWSheet) <> 'O'
	oFWSheet := FWUIWorkSheet():New(,.F. )
EndIf

// Zera as variaveis de ambiente
If oMdlGer:GetOperation() == MODEL_OPERATION_VIEW
	AT740FCAFW()
EndIf

If oMdlGer:GetModel("TFJ_REFER"):GetValue("TFJ_GESMAT") == "3"
	At740Set(oMdlGer:GetModel("TFJ_REFER"), "TFJ_GESMAT", "2")
EndIf

If oMdlGer:GetOperation() <> MODEL_OPERATION_DELETE
	If  oMdlTotais<>NIL
		At740Set(oMdlTFJ, 'TFJ_TOTRH', oMdlTotais:GetValue('TOT_RH'))
		At740Set(oMdlTFJ, 'TFJ_TOTMI', oMdlTotais:GetValue('TOT_MI'))
		At740Set(oMdlTFJ, 'TFJ_TOTMC', oMdlTotais:GetValue('TOT_MC'))
		At740Set(oMdlTFJ, 'TFJ_TOTLE', oMdlTotais:GetValue('TOT_LE'))
	EndIf

	// Atualiza as informações de tabela e revisão da precificação

	If Empty( oMdlTFJ:GetValue('TFJ_CODTAB') )
		At740Set( oMdlTFJ, "TFJ_CODTAB", cTabela )
		At740Set( oMdlTFJ, "TFJ_TABREV", cRevisa )
	EndIf
EndIf

FwRestRows( aSaveRows )

At740SLuc( oMdlTFJ:GetValue("TFJ_LUCRO") )
At740SAdm( oMdlTFJ:GetValue("TFJ_ADM") )

// acontece antes de reativar as travas nos modelos
If nPosImp > 0 .And. oMdlGer:GetOperation() <> MODEL_OPERATION_DELETE
	// Inicializador dos totalizadores dos impostos.
	For nLinLoc := 1 To oMdlLoc:Length()

		oMdlLoc:GoLine( nLinLoc )

		nVlrImp := oMdlIMPORC:GetValue('TOT_VIMP')

		If !oMdlLoc:IsDeleted()
			dDatIni := oMdlLoc:GetValue("TFL_DTINI")
			dDatFim := oMdlLoc:GetValue("TFL_DTFIM")

			nMesVlr := At740FDDiff( dDatIni, dDatFim )
			At740Set( oMdlLoc, "TFL_MESIMP", (nVlrImp / nMesVlr) )

			nValImpTot += nVlrImp
			nValImpMes += (nVlrImp / nMesVlr)

		EndIf

	Next nLinLoc
	oMdlLoc:GoLine( 1 )

	If oMdlGer:GetOperation() == MODEL_OPERATION_VIEW
		// valores totais para os objetos calc's baseados na TFL
		At740Set( oMdlCTFL, "TOT_MESIMP", nValImpMes )
		At740Set( oMdlCTFL, "TOT_TOTIMP", nValImpTot )

		// valores totais para os objetos calc's exibidos na interface e que utilizam o calc da TFL >> 'CALC_TFL'
		// isso é necessário pois a atribuição está acontecendo via LoadValue e não SetValue, por estar dentro da opção de visualização
		// atualiza só os valores dos impostos mensal e total
		At740Set( oMdlMes, "TOT_MESIMP", oMdlGer:GetValue("CALC_TFL", "TOT_MESIMP") )
		At740Set( oMdlTotais, "TOT_TOTIMP", oMdlGer:GetValue("CALC_TFL", "TOT_TOTIMP") )

		At740Set( oMdlMes, "TOT_MES", oMdlGer:GetValue("MES_TOT","TOT_MESRH") + ;
													oMdlGer:GetValue("MES_TOT","TOT_MESMI") + ;
													oMdlGer:GetValue("MES_TOT","TOT_MESMC") + ;
													oMdlGer:GetValue("MES_TOT","TOT_MESIMP") )
		At740Set( oMdlTotais, "TOT_GERAL", oMdlGer:GetValue("TOTAIS","TOT_RH") + ;
													 oMdlGer:GetValue("TOTAIS","TOT_MI") + ;
													 oMdlGer:GetValue("TOTAIS","TOT_MC") + ;
													 oMdlGer:GetValue("TOTAIS","TOT_LE") + ;
													 oMdlGer:GetValue("TOTAIS","TOT_TOTIMP") )

	EndIf
EndIf

If FindFunction("At740HrEtr") .AND. VALTYPE(oMdlHrExtr) == 'O' .AND. oMdlHrExtr:GetOperation() <> MODEL_OPERATION_DELETE
	At740HrEtr(oMdlHrExtr)
EndIf

If IsInCallStack("At870GerOrc") // Verifica as operações dos itens extras do contrato
	oMdlLoc:SetNoInsertLine(.T.)
	oMdlLoc:SetNoDeleteLine(.T.)
	oMdlLoc:SetNoUpdateLine(.T.)
EndIf

If oMdlGer:GetOperation() <> MODEL_OPERATION_INSERT
	oMdlLoc:GoLine( 1 )
EndIf
If oMdlGer:GetOperation() == MODEL_OPERATION_VIEW
	oMdlGer:lModify := .F.
EndIf

If lHasOrcSim
	At740StSm(oMdlTFJ)
EndIf
If IsInCallStack("At870Revis")
	a740ChgLine()
EndIf

FwRestRows( aSaveRows )

Return(Nil)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FPrc
@sample 	At740FPrc( cTabela, cRevisao )
@since		10/02/2015
@version	P12
@param  	cTabela, String, Codigo da tabela de precificação a ser utilizada
@param  	cRevisao, String, Revisao da tabela de precificação a ser utilizada
/*/
//------------------------------------------------------------------------------
Function At740FPrc( cTabela, cRevisao )

Local aRet 	  		:= {}
Local cAliasPrc 	:= GetNextAlias()
Local cAba		  	:= ""
Local nPosAba	  	:= 0
Local lLinha		:= .T.
Local oFwSht		:= Nil

Default cRevisao 	:= ""

// Verificação das abas a serem criadas
BeginSql Alias cAliasPrc

	SELECT
		TV7.TV7_GRUPO, TV7.TV7_ABA, MIN(TV7.TV7_CODIGO) ORDEM
	FROM
		%Table:TV6% TV6
	JOIN %Table:TV7% TV7 ON
		TV7.TV7_FILIAL = %xFilial:TV7% AND
		TV7.TV7_CODTAB = TV6.TV6_CODIGO AND
		TV7.%NotDel%
	WHERE
		TV6.TV6_FILIAL = %xFilial:TV6% AND
		TV6.TV6_NUMERO = %Exp:cTabela% AND
		TV6.TV6_REVISA = %Exp:cRevisao% AND
		TV6.%NotDel%
 	GROUP BY
 		TV7.TV7_GRUPO, TV7.TV7_ABA
 	ORDER BY
 		ORDEM

EndSql

While (cAliasPrc)->(!Eof())
	// Adicionando os identificadores das abas
	aAdd( aRet, { (cAliasPrc)->TV7_ABA,; 	// Identificação das abas
					{},;						// Campos das abas
					{},;						// Objetos e referencias model
					{},;						// Objetos e referencias view
					(cAliasPrc)->TV7_GRUPO,;	// Grupo Identificador dos campos
					{} } )						// Campos que contém Fórmula
	(cAliasPrc)->(dbSkip())
End

(cAliasPrc)->(DbCloseArea())

// Verificação dos campos das abas a serem carregados na estrutura
BeginSql Alias cAliasPrc

	SELECT
		TV7.TV7_TITULO, TV7.TV7_IDENT, TV7.TV7_MODO, TV7.TV7_TAM,
		TV7.TV7_DEC, TV7.TV7_VALID, TV7.TV7_EDICAO, TV7.TV7_INIT,
		TV7.TV7_FORM, TV7.TV7_ORDEM, TV7.TV7_DESC, TV7.TV7_ABA
	FROM
		%Table:TV6% TV6
	JOIN %Table:TV7% TV7 ON
		TV7.TV7_FILIAL = %xFilial:TV7% AND
		TV7.TV7_CODTAB = TV6.TV6_CODIGO AND
		TV7.%NotDel%
	WHERE
		TV6.TV6_FILIAL = %xFilial:TV6% AND
		TV6.TV6_NUMERO = %Exp:cTabela% AND
		TV6.TV6_REVISA = %Exp:cRevisao% AND
		TV6.%NotDel%

EndSql

If IsInCallStack("TECA870") .OR. IsInCallStack("a745AltOrc") .OR. (IsInCallStack("AT600COrc") .AND. Altera)
	oFwSht := GetStrutTa( TFJ->TFJ_CODIGO )
EndIf

While (cAliasPrc)->(!Eof())
	lLinha := .T.
	If (cAliasPrc)->TV7_ABA <> cAba
		nPosAba := aScan( aRet, { |x| x[1] == (cAliasPrc)->TV7_ABA } )
	EndIf

	If nPosAba > 0
		If oFwSht <> Nil
			If AScan(oFwSht:OFWFORMULA:CELLS,{|o| o:NICKNAME == AllTrim((cAliasPrc)->TV7_IDENT)}) == 0
				lLinha := .F.
			EndIf
		EndIf

		If lLinha
			// Campos da estrutura da tabela
			aAdd( aRet[nPosAba][2], { 	(cAliasPrc)->TV7_TITULO,;
											AllTrim((cAliasPrc)->TV7_IDENT),;
											(cAliasPrc)->TV7_MODO,;
											(cAliasPrc)->TV7_TAM,;
											(cAliasPrc)->TV7_DEC,;
											(cAliasPrc)->TV7_VALID,;
											(cAliasPrc)->TV7_EDICAO,;
											(cAliasPrc)->TV7_INIT,;
											(cAliasPrc)->TV7_FORM,;
											(cAliasPrc)->TV7_ORDEM,;
											(cAliasPrc)->TV7_DESC,;
											(cAliasPrc)->TV7_ABA	} )

			// Adiciona os campos que contém fórmula
			If !Empty((cAliasPrc)->TV7_FORM)
				aAdd( aRet[nPosAba][6], {(cAliasPrc)->TV7_IDENT} )
			EndIf
		EndIf

	EndIf

	cAba := (cAliasPrc)->TV7_ABA

	(cAliasPrc)->(dbSkip())

EndDo

(cAliasPrc)->(DbCloseArea())
Return(aRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FStru


@sample 	At740FStru( @aStruPrc )

@since		10/02/2015
@version	P12

@param  	aStruPrc, Array, Lista de campos a serem criados

/*/
//------------------------------------------------------------------------------
Function At740FStru( aStruPrc, lModel, lTec935A )

Local cTipo 	 := ""
Local cPicture := ""
Local nTamPrc  := 0
Local nDecPrc  := 0
Local cModel   := ""
Local cView    := ""
Local cValInit := ""
Local bWhen    := {|| .T.}

Local aCombo, nI, nJ, bIniPad, bValid

Default lTec935A := .F.  //Variavel utiliza para chamada do fonte TECA935A

//Alteração para carregar o array aPrcOrc quando a chamada é feita pelo Regime de Caixa
If lTec935A
	aPrcOrc := aStruPrc
	bWhen := { || .T. }
EndIf

// Carrega todas as informações de referencia de model e view
For nI:=1 To Len(aStruPrc)

	If Empty(AllTrim(aPrcOrc[nI][1])) // Aba Impostos
		cModel := "IMP_ORC"
		cView := "VIEW_IMP"	// Indica o nome da view a ser criada
	Else
		cModel  := "RH" + StrZero( nI, 3 )	// Indica o nome do model a ser criado
		cView := "VIEW_RH" + StrZero( nI, 3 )	// Indica o nome da view a ser criada
	EndIf

	aAdd( aPrcOrc[nI][3], "" 	 )
	aAdd( aPrcOrc[nI][3], cModel ) // Adiciona a referencia do model para utilização na view
	aAdd( aPrcOrc[nI][4], ""		 )
	aAdd( aPrcOrc[nI][4], cView  ) // Adiciona a referencia da view para utilização na view

Next nI

// Carrega a estrutura para o model
If lModel

	For nI:=1 To Len(aStruPrc)

		&("oStru" + StrZero(nI,3)) := FWFormModelStruct():New()

		For nJ:=1 To Len(aStruPrc[nI][2])

			bIniPad := Nil
			bValid  := Nil

			// Verifica o inicializador padrão
			If !Empty(AllTrim(aStruPrc[nI][2][nJ][_TV7INIT]))
				If aStruPrc[nI][2][nJ][_TV7MODO] == "1" .And. ;
					At(";", AllTrim(aStruPrc[nI][2][nJ][8])) == 0 .And. ;
					Val(AllTrim(StrTran(StrTran(aStruPrc[nI][2][nJ][_TV7INIT],'.',''),',','.'))) > 0
					//Verifica se a expressão do inicializador esta com erro
					If At740FVld( "FwBuildFeature( 3, '" + AllTrim(aStruPrc[nI][2][nJ][_TV7INIT]) + "')",;
							 AllTrim(aStruPrc[nI][2][nJ][_TV7IDENT]),;
							 AllTrim(aStruPrc[nI][2][nJ][_TV7DESC]), .F. )
						If lTec935A
							cValInit := AllTrim(StrTran(StrTran(aStruPrc[nI][2][nJ][_TV7INIT],'.',''),',','.') )
							bIniPad  :=  { |x,y| initPlan935(isInCallStatck("tgridonmove"),cValInit,x,y) }
						Else 
							bIniPad  :=  { |x,y| initPlanFld(x,y) }
						EndIf
					EndIf
				ElseIf aStruPrc[nI][2][nJ][_TV7MODO] == "2"
					//Verifica se a expressão do inicializador esta com erro
					cValInit := '"'+AllTrim(SubStr(aStruPrc[nI][2][nJ][_TV7INIT],1,At('=',aStruPrc[nI][2][nJ][_TV7INIT])-1))+'"'
					If At740FVld( "FwBuildFeature( 3, '" + cValInit + "')",;
							 cValInit,;
							 AllTrim(aStruPrc[nI][2][nJ][_TV7DESC]), .F. )
						bIniPad  := FwBuildFeature( STRUCT_FEATURE_INIPAD, cValInit )
					EndIf
				EndIf
			EndIf

			// Verifica o VALID do campo
			cExpValid := AllTrim(aStruPrc[nI][2][nJ][_TV7VALID])
			If !Empty(cExpValid)
				//Verifica se a expressão do valid não esta com erro
				If At740FVld( "FwBuildFeature( 1, '" + cExpValid + "')",;
						 AllTrim(aStruPrc[nI][2][nJ][_TV7IDENT]),;
						 AllTrim(aStruPrc[nI][2][nJ][_TV7DESC]), .T. )
					// Complementa Montagem do VALID do campo
					cExpValid += ' .and. '
				Else
					cExpValid := ''
				EndIf
			EndIf

			// Atribui chamada para recalculo (Ver Parametro: MV_ATONCLC)
			If AllTrim(aStruPrc[nI][2][nJ][_TV7EDICAO]) == '1' .and. Empty((AllTrim(aStruPrc[nI][2][nJ][_TV7FORM])))
				cExpValid += 'At740FCALC("' + AllTrim(aStruPrc[nI][2][nJ][_TV7IDENT]) + '")'
			EndIf

			If !Empty(cExpValid)
				bValid := FwBuildFeature( STRUCT_FEATURE_VALID, cExpValid )
			EndIf

			If aStruPrc[nI][2][nJ][_TV7MODO] == "1" 	// Definições para o campo do tipo valor
				cTipo    := "N"
				aCombo   := Nil
				nTamPrc  := aStruPrc[nI][2][nJ][_TV7TAM]
				nDecPrc  := aStruPrc[nI][2][nJ][_TV7DEC]
			Else 											// Definições para o campo do tipo combo
				cTipo    := "C"
				aCombo   := StrTokArr( aStruPrc[nI][2][nJ][_TV7INIT], ";" )
				nTamPrc  := 1
				nDecPrc  := 0
			EndIf

			&("oStru" + StrZero(nI,3)):AddField( 	aStruPrc[nI][2][nJ][_TV7TITULO],; 				// [01] C Titulo do campo
														aStruPrc[nI][2][nJ][_TV7TITULO],;				// [02] C ToolTip do campo
														AllTrim(aStruPrc[nI][2][nJ][_TV7IDENT]),;		// [03] C identificador (ID) do Field
														cTipo,;											// [04] C Tipo do campo
														nTamPrc,;											// [05] N Tamanho do campo
														nDecPrc,; 											// [06] N Decimal do campo
														bValid,;											// [07] B Code-block de validação do campo
														bWhen,;					// [08] B Code-block de validação When do campo
														aCombo,;				// [09] A Lista de valores permitido do campo
														Nil,;					// [10] L Indica se o campo tem preenchimento obrigatório
														bIniPad,;					// [11] B Code-block de inicializacao do campo
														Nil,;					// [12] L Indica se trata de um campo chave
														Nil,;					// [13] L Indica se o campo pode receber valor em uma operação de update.
														.T. )					// [14] L Indica se o campo é virtual

		Next nJ

		// Adiciona no array os objetos de estrutura do model
		aStruPrc[nI][3][1] := &("oStru" + StrZero(nI,3))

	Next nI

Else // Carrega a estrutura para a view

	For nI:=1 To Len(aStruPrc)

		&("oStru" + StrZero(nI,3)) := FWFormViewStruct():New()

		For nJ:=1 To Len(aStruPrc[nI,2])

			// Montagem do picture e tipo do campo a ser utilizado
			If aStruPrc[nI][2][nJ][_TV7MODO] == "1"
				cTipo  := "N"
				aCombo := Nil
				If aStruPrc[nI][2][nJ][_TV7DEC] > 0
					cPicture := "@E " + Replicate( "9", (aStruPrc[nI][2][nJ][_TV7TAM]-aStruPrc[nI][2][nJ][_TV7DEC])-1 )
					cPicture += "." + Replicate( "9", aStruPrc[nI][2][nJ][_TV7DEC] )
				Else
					cPicture := "@E " + Replicate( "9", aStruPrc[nI][2][nJ][_TV7TAM] )
				EndIf
			Else
				cTipo    := "C"
				cPicture := "@!"
				aCombo   := StrTokArr( aStruPrc[nI][2][nJ][_TV7INIT], ";" )
			EndIf

			&("oStru" + StrZero(nI,3)):AddField( 	AllTrim(aStruPrc[nI][2][nJ][_TV7IDENT]),;	// [01] C Nome do Campo
								 						aStruPrc[nI][2][nJ][_TV7ORDEM],;				// [02] C Ordem
								 						aStruPrc[nI][2][nJ][_TV7TITULO],;			// [03] C Titulo do campo
								 						aStruPrc[nI][2][nJ][_TV7TITULO],;			// [04] C Descrição do campo
								 						Nil,;				// [05] A Array com Help
								 						cTipo,;				// [06] C Tipo do campo
								 						cPicture,;			// [07] C Picture
								 						NIL,;				// [08] B Bloco de Picture Var
								 						"",;				// [09] C Consulta F3
								 						(aStruPrc[nI][2][nJ][_TV7EDICAO] == "1"),; 				// [10] L Indica se o campo é editável
														NIL	,;				// [11] C Pasta do campo
														NIL,;				// [12] C Agrupamento do campo
														aCombo,;				// [13] A Lista de valores permitido do campo (Combo)
														Nil,;				// [14] N Tamanho Maximo da maior opção do combo
														NIL,;				// [15] C Inicializador de Browse
														.T.,;				// [16] L Indica se o campo é virtual
														NIL )				// [17] C Picture Variável

		Next nJ

		// Adiciona no array os objetos de estrutura do model
		aStruPrc[nI][4][1] := &("oStru" + StrZero(nI,3))

	Next nI

EndIf

Return( Nil )


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FVld


@sample 	At740FVld( xAction )

@since		12/02/2015
@version	P12

@param  	xAction, Ação a ser executada para tratamento do erro

/*/
//------------------------------------------------------------------------------
Function At740FVld( xAction, cCampo, cDesCmp, lValid )

Local lRet    := .T.
Local oError  := ErrorBlock( {|e| At740FErro(e,cCampo,cDesCmp,lValid) .And. (lRet:=.F.) } ) //Bloco de erro

Begin Sequence

&(xAction)

End Sequence

ErrorBlock(oError)

Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FErro


@sample 	At740FErro(e)

@since		12/02/2015
@version	P12

@param  	Error, Erro a ser tratado para o usuario

/*/
//------------------------------------------------------------------------------
Static Function At740FErro( e, cCampo, cDesCmp, lValid )

Local cMsgUsr

cMsgUsr := STR0039 + chr(10) + chr(10) // "PROBLEMAS AO CARREGAR AS CONFIGURAÇÕES DA TABELA DE PRECIFICAÇÃO"

cMsgUsr += STR0040 + cCampo + chr(10) // "Campo : "
cMsgUsr += STR0041 + cDesCmp + chr(10) + chr(10) // "Descrição : "

If lValid
	cMsgUsr += STR0042 + chr(10) + chr(10) // "Conteudo informado invalido para validação do campo!"
Else
	cMsgUsr += STR0043 + chr(10) + chr(10) // "Conteudo informado invalido para o conteudo inicial do campo!"
EndIf

cMsgUsr += STR0044 // "Para a funcionalidade do campo seja executada corretamente, "
cMsgUsr += STR0045 + chr(10) + chr(10) // "corrija as informações na configuração da tabela de precificação!"

cMsgUsr += e:ErrorStack

If lMessage
	AVISO( STR0064, cMsgUsr, {STR0070}, 3 ) // "Atenção!" ### "Fechar"
EndIf

Return(.T.)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FCALC

@sample 	At740FCALC(cIDCampo)
@param		[cIDCampo],caractere,Identificador do campo que foi alterado.
@since		25/02/2015
@version	P12

/*/
//------------------------------------------------------------------------------

Function At740FCALC(cIDCampo)
Local lRet		:= .T.
Local lCalcOn	:= SuperGetMv("MV_ATONCLC",,.F.)	// Recalcula a cada edição de campo do formulário?
Local aLstCpos:= {}
Local nI		:= 0
Local aAux		:= nil

If lCalcOn .and. !Empty(cIDCampo) .and. At740GSC()

	AAdd(aLstCpos, cIDCampo)

	aAux := At740FGTOT(oMdl740F)	// Aplica os totalizadores na base de cálculo dos impostos

	For nI := 1 To Len(aAux)
		AAdd(aLstCpos, aAux[nI])
	Next

	Processa( {|| (cXMLPrc := At740EEPC(At740FGSS(oMdl740F),aPrcOrc,oMdl740F,aLstCpos)) }, STR0046, STR0047,.F.) // "Aguarde..." ### "Executando cálculo ..."

	At740FSRH()	// Atualiza o total de custo do recurso: TOTAL_RH

	For nI := 1 To Len(aPrcOrc)
		If !Empty(oViw740F)
			oViw740F:Refresh(aPrcOrc[nI][4][2])
		EndIf
	Next nI
EndIf

Return( lRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FBCalc

Criação do botão que chama a função de cálculo da precificação.

@sample 	At740FBCalc(oPanel)

@param		[oPanel],object,Painel onde deverá ser criado e exibido o botão.
@return	Nil
@author	Serviços
@since		24/02/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Function At740FBCalc(oPanel, nOrigem, lAuto)
Local oButton		:= nil
Local aBtnSize	:= {065,012}
Local aBtnPos		:= {001,000}
Local cSCSSBtn	:= "QPushButton{margin-top:1px; border-bottom-color:#000000; background-color:#1F739E; color:#ffffff; border-style: solid; border-width:1px; }"

Default lAuto := .F.

If lAuto
	At740fcItem( nOrigem )
Else
// Ancoramos os objetos no oPanel passado
@ aBtnPos[1], aBtnPos[2] Button oButton Prompt STR0048 Of oPanel Size aBtnSize[1], aBtnSize[2] Pixel //Calcular
// Define CSS
oButton:SetCss( cSCSSBtn )
// Alinhamento do botao referente ao panel
oButton:Align		:= CONTROL_ALIGN_CENTER
// Atribuição de ação ao acionamento do botão
oButton:bAction	:= { || At740fcItem( nOrigem ) } // "Aguarde..." ### "Executando cálculo ..."
EndIf

Return(Nil)
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FBCalc

Criação do botão que chama a função de cálculo da precificação.

@sample 	At740FBCalc(oPanel)

@param		[oPanel],object,Painel onde deverá ser criado e exibido o botão.
@return	Nil
@author	Serviços
@since		24/02/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Function At740FBLoad(oPanel, nOrigem, lAuto)
Local oButton		:= nil
Local aBtnSize	:= {065,012}
Local aBtnPos		:= {001,000}

Default lAuto := .F.

If lAuto
	At740Load( nOrigem )
Else
	// Ancoramos os objetos no oPanel passado
	@ aBtnPos[1], aBtnPos[2] Button oButton Prompt STR0119 Of oPanel Size aBtnSize[1], aBtnSize[2] Pixel //"Consultar"
	// Alinhamento do botao referente ao panel
	oButton:Align		:= CONTROL_ALIGN_CENTER
	// Atribuição de ação ao acionamento do botão
	oButton:bAction	:= { || MsgRun( STR0113 , STR0102, { || At740Load( nOrigem ) })} // "Aguarde..." ### "Carregando valores da tabela de preço..."
EndIf

Return(Nil)

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT740FGXML
Inicializa a variável Estática cXMLPrc com a Estrutura da Tabela de Precificação no formato XML

@sample 	AT740FGXML(cTabela, cRevisa)

@param		[cTabela],caractere,Número referente à tabela de precificação.
@param		[cRevisa],caractere,Código de Revisão, se houver, da tabela de precificação
@return	Nil
@author	Serviços
@since		25/02/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Function AT740FGXML(cTabela, cRevisa, lClear)
Local cRet := ''

Default cTabela	:= ''
Default cRevisa	:= ''
Default lClear 	:= .F.

If lClear
	cXMLPrc  := ''
	oMdl740F := Nil
	oViw740F := Nil
	AT740FCAFW()
EndIf

If !Empty(cTabela) .And. Empty(cXMLPrc)
	// Carrega uma tabela nova de precificação especifica no formato XML
	cXMLPrc := At740EGXML(cTabela,cRevisa)
EndIf

cRet := cXMLPrc

Return( cRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FMsg
	Altera o conteudo da variavel de mensagem

@sample 	At740CpyMdl

@since		23/09/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740FMsg( lValor )
lMessage := lValor
Return( Nil )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FTTRH
	Validação de campos obrigatório da planilha
@sample 	At740FTTRH(oModel)
@since		02/03/2015
@version	P11.90
@param		oModel, Object, Classe do modelo de dados MpFormModel
/*/
//------------------------------------------------------------------------------
Function At740FTTRH(oModel)
Local aArea		:= GetArea()
Local oTmpPlan 	:= At740FGPC(.T., oModel)
Local lRet		:= oTmpPlan:CellExists("TOTAL_RH")
Local lTotImp 	:= oTmpPlan:CellExists("TOT_VIMP")
Local lGSRH		:= GsGetIns("RH")
Local lGSMI		:= GsGetIns("MI")
Local lGSLE		:= GsGetIns("LE")

If !IsInCallStack("TECA870")
	If !lRet
		Help( " ", 1, "At740FTTRH", , STR0050, 1 )  //"Não foi definido o apelido TOTAL_RH obrigatório do modelo de planilha"

	ElseIf lTotImp
		// -----------------------------------------
		//  quando existe a totalização por impostos não
		// permite que os produtos sejam diferentes no cabeçalho
		If ( lGSRH .AND. lGSMI .AND. lGSLE ) .AND.;
			(( oModel:GetValue( "TFJ_REFER", "TFJ_GRPRH" ) <> oModel:GetValue( "TFJ_REFER", "TFJ_GRPMI" ) ) .Or. ;
			( oModel:GetValue( "TFJ_REFER", "TFJ_GRPLE" ) <> oModel:GetValue( "TFJ_REFER", "TFJ_GRPMC" ) ) .Or. ;
			( oModel:GetValue( "TFJ_REFER", "TFJ_GRPRH" ) <> oModel:GetValue( "TFJ_REFER", "TFJ_GRPLE" ) ))
			lRet := .F.
			Help( " ", 1, "At740TOTIMP", , STR0059, 1 ) // "Os produtos de referência precisam ser o mesmo para todos os conceitos de produto quando está habilitado o totalizador de impostos"
		Else
			If 	( !lGSRH .AND. lGSMI .AND. lGSLE ) .AND.;
			 	(( oModel:GetValue( "TFJ_REFER", "TFJ_GRPMI" ) <> oModel:GetValue( "TFJ_REFER", "TFJ_GRPLE" )) .OR.;
				( oModel:GetValue( "TFJ_REFER", "TFJ_GRPLE" ) <> oModel:GetValue( "TFJ_REFER", "TFJ_GRPMC" )))
				lRet	:= .F.
				Help( " ", 1, "At740TOTIMP", , STR0059, 1 ) // "Os produtos de referência precisam ser o mesmo para todos os conceitos de produto quando está habilitado o totalizador de impostos"

			ElseIf 	( !lGSMI .AND. lGSRH .AND. lGSLE ) .AND.;
				(( oModel:GetValue( "TFJ_REFER", "TFJ_GRPRH" ) <> oModel:GetValue( "TFJ_REFER", "TFJ_GRPLE" )))
				lRet	:= .F.
				Help( " ", 1, "At740TOTIMP", , STR0059, 1 ) // "Os produtos de referência precisam ser o mesmo para todos os conceitos de produto quando está habilitado o totalizador de impostos"
			ElseIf	( !lGSLE .AND. lGSRH .AND. lGSMI ) .AND.;
					(( oModel:GetValue( "TFJ_REFER", "TFJ_GRPMI" ) <> oModel:GetValue( "TFJ_REFER", "TFJ_GRPRH" )) .OR.;
					( oModel:GetValue( "TFJ_REFER", "TFJ_GRPMC" ) <> oModel:GetValue( "TFJ_REFER", "TFJ_GRPMI" )))
					lRet	:= .F.
					Help( " ", 1, "At740TOTIMP", , STR0059, 1 ) // "Os produtos de referência precisam ser o mesmo para todos os conceitos de produto quando está habilitado o totalizador de impostos"

			ElseIf	( !lGSLE .AND. !lGSRH ) .AND. ;
					(( oModel:GetValue( "TFJ_REFER", "TFJ_GRPMI" ) <> oModel:GetValue( "TFJ_REFER", "TFJ_GRPMC" )))
					lRet	:= .F.
					Help( " ", 1, "At740TOTIMP", , STR0059, 1 ) // "Os produtos de referência precisam ser o mesmo para todos os conceitos de produto quando está habilitado o totalizador de impostos"
			EndIf
		EndIf
	EndIf
EndIf

	RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FTrgG
	Função para preencher o conteúdo de grids superiores com a somatória

@sample 	At740FTrgG( cMdlOri,cCampoOri,cDestino )

@since		23/09/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740FTrgG( cMdlOri,cCampoOri,cDestino )

Local cFuncao		:= ''
Local nSalario	:= 0
Local oMdl			:= FwModelActive()
Local nI			:= 0
Local nJ			:= 0
Local lCpoSalario 	:= .F.

If oMdl:GetId()=='TECA740F'
   cFuncao := oMdl:GetModel(cMdlOri):GetValue(cCampoOri)

   If !Empty( cFuncao )
      nSalario := Posicione('SRJ',1,XFilial('SRJ')+cFuncao,'RJ_SALARIO')
   EndIf

	For nI := 1 To Len(aPrcOrc)
		For nJ := 1 To Len(aPrcOrc[nI][2])
			If AllTrim(aPrcOrc[nI][2][nJ][_TV7INIT]) == 'SAL_FUNCAO'
   				oMdl:GetModel(aPrcOrc[nI][3][2]):SetValue(AllTrim(aPrcOrc[nI][2][nJ][_TV7IDENT]), nSalario )
   				lCpoSalario := .T.
   			EndIf
   		Next nJ
	Next nI

	If lCpoSalario .And. !IsInCallStack("ATCPYDATA") .And. !IsInCallStack("LoadXmlData")
		// só atualiza o valor unitário quando não tem essas funções na pilha
		oMdl:GetModel(cMdlOri):SetValue("TFF_PRCVEN",0)
	EndIf
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FDDiff
	Retorna o numero de meses para um intervalo de datas
@sample 	At740FDDiff( dDataDe, dDataAte )
@param		dDataDe, Date, Data inicial para o calculo
@param 		dDataAte, Date, Data final para o calculo
@since		02/03/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Function At740FDDiff( dDataDe, dDataAte )

Local nRet := 1
Local nDiaAte := dDataAte - dDataDe

If nDiaAte > 30
	nRet := Int( nDiaAte / 30 )
EndIf

Return( nRet )


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FTGMes
	Função para preencher os valores mensais de acordo com o periodo

@sample 	At740FTGMes( "TFL_LOC", "TFL_DTINI", "TFL_DTINI", "TFL_TOTRH" )

@since		02/03/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740FTGMes( cMdlDat, cCpoDTI, cCpoDTF, cCpoTot, cCpoQtd, lQtd, oMdl )

Local nValor  := 0
Local nMesVlr := 0
Local nQtdDpr := 0
Local oMdlDat := Nil
Local dDatIni := CTOD("")
Local dDatFim := CTOD("")

Default cCpoDTI	:= ""
Default cCpoDTF	:= ""
Default cCpoQtd := ""
Default lQtd	:= .F.
Default oMdl    := FwModelActive()

If oMdl != Nil .And. oMdl:isActive()
	oMdlDat := oMdl:GetModel(cMdlDat)
EndIf

If !Empty(oMdl) .and. oMdl:GetId()=='TECA740F'
	oMdlDat := oMdl:GetModel(cMdlDat)

	If lQtd // Calcula a depreciação dos materiais

		nQtdDpr := oMdlDat:GetValue( cCpoQtd )
		If nQtdDpr > 0
			nValor := ( oMdlDat:GetValue( cCpoTot ) / nQtdDpr )
		EndIf

	Else 	// Calcula o valor mensal para local de atedimento e RH

		dDatIni := oMdlDat:GetValue( cCpoDTI )
		dDatFim := oMdlDat:GetValue( cCpoDTF )

		If !Empty(dDatIni) .And. !Empty(dDatFim)

			If oMdl:GetValue("TFJ_REFER","TFJ_CNTREC") == '1'
				nMesVlr := 1 //contrato recorrente
			Else
				nMesVlr := At740FDDiff( dDatIni, dDatFim )
			EndIf

			If nMesVlr > 0
				nValor := ( oMdlDat:GetValue( cCpoTot ) / nMesVlr )
			EndIf

		EndIF

	EndIf

EndIf

Return( nValor )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FTGMes
	Função para preencher os valores mensais de acordo com o periodo

@sample 	At740FTGMes( "TFL_LOC", "TFL_DTINI", "TFL_DTINI", "TFL_TOTRH" )

@since		02/03/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740LDMes( dDatIni ,dDatFim ,nTotal)

Local nValor  := 0
Local nMesVlr := 0

If TFJ->TFJ_CNTREC == '1'
	nMesVlr := 1 //contrato recorrente
Else
	nMesVlr := At740FDDiff( dDatIni, dDatFim )
EndIf

If nMesVlr > 0
	nValor := ( nTotal / nMesVlr )
EndIf

Return( nValor )
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FWMat
	Validação da edição do campo do limite de apontamento de materiais para os
	recursos humanos

@sample 	At740FWMat

@since		02/03/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740FWMat()

Local aArea   := GetArea()
Local oMdlPrc := FwModelActive()
Local lRet	  := !( Empty(oMdlPrc:GetModel("TFJ_REFER"):GetValue("TFJ_GESMAT")) .OR.  oMdlPrc:GetModel("TFJ_REFER"):GetValue("TFJ_GESMAT") == "1")

RestArea(aArea)

Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FSTLoc


@sample 	At740FSTLoc( oStruLoc )

@since		10/02/2015
@version	P12

@param  	oStruLoc, Object, Objeto para serem adicionados os campos do local de atendimento no model

/*/
//------------------------------------------------------------------------------
Function At740FSTLoc( oStrTFL )

Local nPosImp := aScan( aPrcOrc, { |x| x[1] == Replicate( " ", 30 ) } ) // Verifica a posição do array de impostos

oStrTFL:AddField( 	STR0051,; 			// [01] C Titulo do campo # "Total Mes"
					STR0051,;			// [02] C ToolTip do campo # "Total Mes"
					"TFL_TOTMES",;			// [03] C identificador (ID) do Field
					"N",;					// [04] C Tipo do campo
					14,;					// [05] N Tamanho do campo
					2,; 					// [06] N Decimal do campo
					Nil,;					// [07] B Code-block de validação do campo
					Nil,;					// [08] B Code-block de validação When do campo
					Nil,;					// [09] A Lista de valores permitido do campo
					Nil,;					// [10] L Indica se o campo tem preenchimento obrigatório
					Nil,;					// [11] B Code-block de inicializacao do campo
					Nil,;					// [12] L Indica se trata de um campo chave
					Nil,;					// [13] L Indica se o campo pode receber valor em uma operação de update.
					.T. )					// [14] L Indica se o campo é virtual

oStrTFL:AddField( STR0051,; 			// [01] C Titulo do campo  // "Total Mes"
					STR0051,;			// [02] C ToolTip do campo  // "Total Mes"
					"TFL_LUCRH",;			// [03] C identificador (ID) do Field
					"N",;					// [04] C Tipo do campo
					14,;					// [05] N Tamanho do campo
					2,; 					// [06] N Decimal do campo
					Nil,;					// [07] B Code-block de validação do campo
					Nil,;					// [08] B Code-block de validação When do campo
					Nil,;					// [09] A Lista de valores permitido do campo
					Nil,;					// [10] L Indica se o campo tem preenchimento obrigatório
					Nil,;					// [11] B Code-block de inicializacao do campo
					Nil,;					// [12] L Indica se trata de um campo chave
					Nil,;					// [13] L Indica se o campo pode receber valor em uma operação de update.
					.T. )					// [14] L Indica se o campo é virtual

oStrTFL:AddField( STR0051,; 			// [01] C Titulo do campo // "Total Mes"
					STR0051,;			// [02] C ToolTip do campo  // "Total Mes"
					"TFL_LUCMI",;			// [03] C identificador (ID) do Field
					"N",;					// [04] C Tipo do campo
					14,;					// [05] N Tamanho do campo
					2,; 					// [06] N Decimal do campo
					Nil,;					// [07] B Code-block de validação do campo
					Nil,;					// [08] B Code-block de validação When do campo
					Nil,;					// [09] A Lista de valores permitido do campo
					Nil,;					// [10] L Indica se o campo tem preenchimento obrigatório
					Nil,;					// [11] B Code-block de inicializacao do campo
					Nil,;					// [12] L Indica se trata de um campo chave
					Nil,;					// [13] L Indica se o campo pode receber valor em uma operação de update.
					.T. )					// [14] L Indica se o campo é virtual

oStrTFL:AddField( STR0051,; 			// [01] C Titulo do campo // "Total Mes"
					STR0051,;			// [02] C ToolTip do campo // "Total Mes"
					"TFL_LUCMC",;			// [03] C identificador (ID) do Field
					"N",;					// [04] C Tipo do campo
					14,;					// [05] N Tamanho do campo
					2,; 					// [06] N Decimal do campo
					Nil,;					// [07] B Code-block de validação do campo
					Nil,;					// [08] B Code-block de validação When do campo
					Nil,;					// [09] A Lista de valores permitido do campo
					Nil,;					// [10] L Indica se o campo tem preenchimento obrigatório
					Nil,;					// [11] B Code-block de inicializacao do campo
					Nil,;					// [12] L Indica se trata de um campo chave
					Nil,;					// [13] L Indica se o campo pode receber valor em uma operação de update.
					.T. )					// [14] L Indica se o campo é virtual

If nPosImp > 0

	oStrTFL:AddField( 	STR0052,; 			// [01] C Titulo do campo # "Total Impostos"
						STR0052,;			// [02] C ToolTip do campo # "Total Impostos"
						"TFL_MESIMP",;			// [03] C identificador (ID) do Field
						"N",;					// [04] C Tipo do campo
						14,;					// [05] N Tamanho do campo
						2,; 					// [06] N Decimal do campo
						Nil,;					// [07] B Code-block de validação do campo
						Nil,;					// [08] B Code-block de validação When do campo
						Nil,;					// [09] A Lista de valores permitido do campo
						Nil,;					// [10] L Indica se o campo tem preenchimento obrigatório
						Nil,;					// [11] B Code-block de inicializacao do campo
						Nil,;					// [12] L Indica se trata de um campo chave
						Nil,;					// [13] L Indica se o campo pode receber valor em uma operação de update.
						.T. )					// [14] L Indica se o campo é virtual
EndIf

Return( Nil )


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FImpTrg
	Função para preencher o conteúdo de grids superiores com a somatória dos impostos

@sample 	At740FImpTrg( "CALC_TFH", "TOT_MC", "TFF_RH", "TFF_TOTMC" )

@since		03/03/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740FImpTrg( cMdlImp, cCpoImp, oMdlImp )

Local nVlrMes := 0
Local nValor  := 0

Default oMdlImp := FwModelActive()

If oMdlImp:GetId()=='TECA740F'

    nValor  := oMdlImp:GetModel( cMdlImp ):GetValue( cCpoImp )

    oMdlImp:GetModel( "TFL_LOC" ):SetValue( "TFL_TOTIMP", nValor )

    nVlrMes := At740FTGMes( "TFL_LOC", "TFL_DTINI", "TFL_DTFIM", "TFL_TOTIMP" )

    oMdlImp:GetModel( "TFL_LOC" ):SetValue( "TFL_MESIMP", nVlrMes )

EndIf

Return 0


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FGTOT
	Função para atribuição do valor da base de cálculo dos impostos.

@sample 	At740FGTOT(oMdlMain)
@param		[oMdlMain],object,Modelo a qual se deve aplicar a pesquisa da base de cálculo
@return	[aRet],array,Estrutura simples, retornado por valor, contendo a lista de campos identificados com as constantes:
			BLR_FUNCAO; >> valor dos itens com a taxa de lucro ( Rh + Mi + Mc )
			BLP_FUNCAO; >> soma os totais dos locais de ( Rh + Mi + Mc )
			VLTXADM_FUNCAO; >> soma os valor das taxas administrativas dos itens de Rh, Mc, Mi e Le
			VLR_RH_FUNCAO; >> Total dos itens de RH do local sem considerar lucro e tx adm
			VLR_MI_FUNCAO; >> Total dos itens de Mi do local sem considerar lucro e tx adm
			VLR_MC_FUNCAO; >> Total dos itens de Mc do local sem considerar lucro e tx adm
			VLR_LE_FUNCAO; >> Total dos itens de Le do local sem considerar lucro e tx adm
@since		03/03/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Function At740FGTOT(oMdlMain,cMdlTFL,cMdlTFF,cMdlTFG,cMdlTFH,cMdlTFI,cMdlTEV,aPrc,lTeca870b)

Local aRet			:= {}
Local nI			:= 0
Local nJ			:= 0
Local cFuncao		:= ''
Local cIdent		:= ''
Local aSaveLines  := FWSaveRows()
Local nVal 			:= 0

Default cMdlTFL := "TFL_LOC"
Default cMdlTFF := "TFF_RH"
Default cMdlTFG := "TFG_MI"
Default cMdlTFH := "TFH_MC"
Default cMdlTFI := "TFI_LE"
Default cMdlTEV := "TEV_ADICIO"
Default aPrc	:= aPrcOrc
Default lTeca870b := .F.

For nI := 1 To Len(aPrc)
	For nJ := 1 To Len(aPrc[nI][2])
		cFuncao	:= AllTrim(aPrc[nI][2][nJ][_TV7INIT])
		cIdent	:= AllTrim(aPrc[nI][2][nJ][_TV7IDENT])
		If AtIsCalcId( cFuncao )
			// Aplica totais para cálculo do lucro real
			nVal := AtCalcIdent( cFuncao, oMdlMain, cMdlTFL, cMdlTFF, cMdlTFG, cMdlTFH, cMdlTFI, cMdlTEV )

			If !lTeca870b
				oMdlMain:GetModel(aPrc[nI][3][2]):SetValue(nVal)
			Else
				If oMdlMain:GetModel('TV7IDETAIL'):SeekLine({{'TV7_IDENT',cIdent}})
					oMdlMain:GetModel('TV7IDETAIL'):SetValue('TV7_VLRNEW',nVal)
				EndIf
			EndIf

			If AScan(aRet, {|e| e == cIdent}) == 0
				AAdd(aRet, cIdent)
			EndIf
		EndIf
	Next nJ
Next nI

FWRestRows( aSaveLines )

Return AClone(aRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FSRH
	Função para atribuição do valor da remuneração do recurso posicionado.

@sample 	At740FSRH()

@since		03/03/2015
@version	P12

/*/
//------------------------------------------------------------------------------

Function At740FSRH(oMdlAtu)
Local nI			:= 0
Local nJ			:= 0
Local cID			:= 'TOTAL_RH'
Local lRet			:= .T.
Local nVal 			:= 0

Default oMdlAtu := oMdl740F

For nI := 1 To Len(aPrcOrc)
	For nJ := 1 To Len(aPrcOrc[nI][2])
		If AllTrim(aPrcOrc[nI][2][nJ][_TV7IDENT]) == cID
			nVal := Round( oMdlAtu:GetModel(aPrcOrc[nI][3][2]):GetValue(cID), TamSX3("TFF_PRCVEN")[2])
			oMdlAtu:GetModel('TFF_RH'):SetValue('TFF_PRCVEN',nVal)
			Exit
		EndIf
	Next nJ
Next nI

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740GSC
	Função para atribuição do valor da remuneração do recurso posicionado.

@sample 	At740GSC(lValor)

@param		[lValor],logico,Habilita ou desabilita a variavel estática lCalcular
@since		06/03/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740GSC(lValor)

If (ValType(lValor) == 'L')
	lCalcular := lValor
EndIf

Return lCalcular


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FGPC
	Função para retornar a referencia de memoria da planilha de calculo

@sample 	At740FGPC()
@since		06/03/2015
@version	P12
@param lRecharge, Logico, indica se deve recarregar o objeto da planilha
@param oMdl, Objeto, indica em qual objeto do orçamento de serviço tem o modelo de tabela e revisão
/*/
//------------------------------------------------------------------------------
Function At740FGPC( lRecharge, oMdl )
Local oTempSheet := oFWSheet
Local cXmlExemplo := ''
Local cTabPrec := ''
Local cTabRev := ''
Default lRecharge := .F.
Default oMdl := FwModelActive()

If lRecharge .And. oMdl:GetId()=='TECA740F'
	oFWSheet:Reinit() //:= FWUIWorkSheet():New(,.F. )
	// recria um xml padrão da tabela utilizada
	cTabPrec := If( Empty(oMdl:GetValue('TFJ_REFER','TFJ_CODTAB')), At600GetTab()[1], oMdl:GetValue('TFJ_REFER','TFJ_CODTAB'))
	cTabRev := If( Empty(oMdl:GetValue('TFJ_REFER','TFJ_TABREV')), At600GetTab()[2], oMdl:GetValue('TFJ_REFER','TFJ_TABREV'))
	cXmlExemplo := At740EGXML( cTabPrec, cTabRev )
	oFWSheet:LoadXmlModel( cXmlExemplo, .F.)
	oTempSheet := oFWSheet
EndIf

Return oTempSheet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FORC
	Função para retornar a referencia de memoria do array aPrcOrc

@sample 	At740FORC()
@since		06/03/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740FORC()
Return aPrcOrc

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FMDL
	Função para retornar a referencia de memoria do Model oMdl740F

@sample 	At740FMDL()
@since		06/03/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740FMDL( oObjMdl )
Default oObjMdl := Nil
If oObjMdl <> Nil .And. oObjMdl:GetId()=='TECA740F'
	oMdl740F := oObjMdl
EndIf
Return oMdl740F

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FGSS
	Função para Manutenção dos itens da variável estática oMainXML,

@sample 	At740FGSS(xXML)
@param		[cXML],CARACTERE,Representando um arquivo XML para uso do objeto de cálculo FWSheet.
@param		[nItem],NUMERICO,Indice a que se refere a leitura ou gravação
@return	[uRet],INDEFINIDO,Retorna NIL ou uma estrutura XML do tipo aplicado ao objeto de cálculo FWSheet
@since		17/03/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740FGSS(oMdlGer,cAtuXML)
Local uRet		:= Nil
Local oMdlLoc	:= oMdlGer:GetModel("TFL_LOC")
Local oMdlRh	:= oMdlGer:GetModel("TFF_RH")
Local oMdlTFJ	:= oMdlGer:GetModel('TFJ_REFER')
Local aTabRev	:= At600GetTab()
Local lInit		:= isInCallStack("initdados")
Local lTFFXML	:= TFF->( ColumnPos('TFF_TABXML') ) > 0
Local lInsert	:=  oMdlGer:getOperation() == MODEL_OPERATION_INSERT
Local lUpdt	:=  oMdlGer:getOperation() == MODEL_OPERATION_UPDATE
Local nX
Local nBkpLine
Local nLinRH := oMdlRh:GetLine()
Local nPosSht := 0
Default cAtuXML	:= ''

If ((lInit .AND. (!lInsert .OR. lUpdt)) .OR. (lInsert .AND. !lInit) .OR. (lUpdt .AND. !lInit )) .OR.;
		(IsInCallStack("At270Orc") .AND. lInit)
	If !Empty(cAtuXML)
		nPosSht := oMdlLoc:GetLine()
		While Len(aFWSheet[nPosSht][2])    <= nLinRH
			// Adicina uma nova estrutura representando um recurso para o local atual
			AAdd(aFWSheet[nPosSht][2], {nil,nil,.T.})
		End		
		aFWSheet[oMdlLoc:GetLine()][2][nLinRH][_fwOBJ]:LoadXmlModel(cAtuXML)
		// Grava o código do Recurso
		aFWSheet[oMdlLoc:GetLine()][2][nLinRH][_fwTFF] := oMdlRh:GetValue('TFF_COD')
	Else
	// Verifica se o objeto de planilhas tem o mesmo numero de itens dos Recursos Humanos
			nPosSht  := Ascan(aFWSheet,{|x| x[1] == oMdlLoc:GetValue('TFL_CODIGO') })
	         If nPosSht  = 0
				AAdd(aFWSheet, {oMdlLoc:GetValue('TFL_CODIGO'),{},.T.})
				nPosSht := len(aFWSheet)
			EndIf
			While Len(aFWSheet[nPosSht][2]) <= oMdlRh:Length()
						// Adicina uma nova estrutura representando um recurso para o local atual
				AAdd(aFWSheet[nPosSht][2], {nil,nil,.T.})
			End
			//Esta condição verifica os valores do XML da tabela de precificação salvos no BD e carrega-os na var aFWSheet.
			//Isso significa que toda a operação de VISUALIZAÇÃO, ALTERAÇÃO ou EXCLUSÃO precisam passar por aqui
			//	(pois entende-se que, nessas operações, existe um valor de XML já salvo no BD)
			//A função TecActivt é utilizada para evitar o uso de variaveis STATIC
			//Esta condição DEVE FALHAR após o ACTIVATE do modelo (em outras palavras, ela só deve ser executada no momento da ativação do modelo)
			If isInCallStacK("TecActivt") .OR.;
			 	isInCallStacK("At870View") .OR.; //Qualquer visualização na rotina Gestão dos Contratos
					((isInCallStack("At600SeAtu") .OR. isInCallStack("At600OrcView")) .AND.;
					 	lInit .AND.; //Na inicialização do Orçamento que veio de uma PROPOSTA
					 	 (oMdlGer:GetOperation() == MODEL_OPERATION_UPDATE .OR. oMdlGer:GetOperation() == MODEL_OPERATION_VIEW)) .OR.;
					 	 	(isInCallStack("A600COMBORC") .AND. lInit) .OR.; //Importação da Vistoria Técnica
					 	 		(IsInCallStack("TECA745") .AND. lInit .AND.;
					 	 		 	(oMdlGer:GetOperation() == MODEL_OPERATION_UPDATE .OR. oMdlGer:GetOperation() == MODEL_OPERATION_VIEW .OR.;
					 	 		 		oMdlGer:GetOperation() == MODEL_OPERATION_DELETE)) //Orçamento Simplificado
				nBkpLine := oMdlRh:GetLine()
				For nX := 1 to oMdlRh:Length()
					oMdlRh:GoLine(nX)
					If lTFFXML
						cXMLPrc := oMdlRh:GetValue('TFF_TABXML')
					Else
						cXMLPrc := At740FDXML(oMdlTFJ:GetValue('TFJ_TABXML'),aFWSheet[oMdlLoc:GetLine()][1],oMdlRh:GetValue('TFF_COD'))
					EndIf
					aFWSheet[nPosSht][2][oMdlRh:GetLine()][_fwOBJ] := FWUIWorkSheet():New(,.F. )
					aFWSheet[nPosSht][2][oMdlRh:GetLine()][_fwOBJ]:LoadXmlModel(cXMLPrc)
				Next nX
				oMdlRh:GoLine(nBkpLine)
			Else
			  If aFWSheet[nPosSht][2][nLinRH][_fwOBJ] == Nil
				 // Carrega um arquivo XML relativo à Tabela e Revisão - conteúdo padrão sem preenchimento
				 If Empty(cXMLPrc)
					cXMLPrc := At740ELTP(aTabRev[1], aTabRev[2])
				 EndIf

				aFWSheet[nPosSht][2][nLinRH][_fwOBJ]:= FWUIWorkSheet():New(,.F. )

				aFWSheet[nPosSht][2][nLinRH][_fwOBJ]:LoadXmlModel(cXMLPrc)
			  EndIf
			// Grava o código do Recurso
			aFWSheet[nPosSht][2][nLinRH][_fwTFF] := oMdlRh:GetValue('TFF_COD')
		  EndIf
	EndIf
	// Retorna uma referencia ao Objeto relativo às posições Local X RH
	uRet := aFWSheet[nPosSht][2][nLinRH][_fwOBJ]
EndIf

Return uRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FDXML
	Função que efetua o desmembramento de uma string formatada
@sample 	At740FDXML(cMemo,cKey1,cKey2)

@param		[cMemo],caractere,String contendo uma formatação prévia
@param		[cKey1],caractere,Chave representando TFL_CODIGO
@param		[cKey1],caractere,Chave representando TFF_COD

@since		31/03/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Function At740FDXML(cMemo,cKey1,cKey2)
Local aAux	:= {}
Local nPos	:= 0
Local cRet	:= ''

Default cMemo	:= ''
Default cKey1	:= ''
Default cKey2	:= ''

While At(Chr(13),cMemo) > 1

	// Separa e guarda a estrutura XML
	AAdd(aAux,SubStr(cMemo,1,At(CRLF,cMemo)-1))

	// Retira da Variavel o trecho que esta salvo
	cMemo := SubStr(cMemo,At(CRLF,cMemo)+2)

	// Se coincidir com a chave solicitada termina e retorna
	If (nPos := ASCan(aAux,{|e| '|1|'+cKey1+'|2|'+cKey2 $ e })) > 0
		cRet := SubStr(aAux[nPos],At('|3|',aAux[nPos])+3)
		Exit
	EndIf

EndDo

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FMXML
	Função que efetua a montagem de uma string para gravação na TFJ_TABXML
@sample 	At740FMXML(oMdlGer)

@param		[oMdlGer],objeto,Modelo de Dados do Orçamento

@since		31/03/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Function At740FMXML(oMdlGer, lAtuPlan, aOldRec)
Local nI			:= 0
Local nJ			:= 0
Local cMemo		:= ''
Local oMdlTFL		:= nil
Local oMdlTFF		:= nil
Local aSaveRows	:= {}
Local cTempXml 	:= ''
Local nPosTFF := 0
Local nPosSht  := 0
Local oMdlLoc	:= oMdlGer:GetModel("TFL_LOC")
Local nPosOldRec := 0
Default lAtuPlan := .F.
Default aOldRec := {}

// Objetos que serão utilizados na função
oMdlTFL := oMdlGer:GetModel('TFL_LOC')
oMdlTFF := oMdlGer:GetModel('TFF_RH')

// Salvar ponteiros
aSaveRows	:= FwSaveRows()

// Locais de Atendimento
For nI := 1 To oMdlTFL:Length()
	oMdlTFL:GoLine( nI )
	// Não deletados
	If !oMdlTFL:IsDeleted()
	   nPosSht  := Ascan(aFWSheet,{|x| x[1] == oMdlLoc:GetValue('TFL_CODIGO') })
	   If nPosSht  > 0
	   	// Recursos Humanos
	      For nJ := 1 To oMdlTFF:Length()

			oMdlTFF:GoLine( nJ )

			// Não Deletados && Itens de RH Preenchidos && Não Itens Extras
			If !Empty(oMdlTFF:GetValue("TFF_PRODUT"))
				nPosOldRec := Ascan(aOldRec,{|x| x[1] == nI})
				If nPosOldRec == 0  .Or. oMdlTFF:IsInserted()
					nPosTFF := aScan(aFWSheet[nPosSht][2], { |c|  RTrim(TecNvl(c[1],"")) ==  RTrim(oMdlTFF:GetValue('TFF_COD'))})
				Else
					nPosTFF := aScan(aFWSheet[nPosSht][2], { |c|  RTrim(TecNvl(c[1],"")) ==  RTrim(aOldRec[nPosOldRec,2,nJ])})
				EndIf

				If  nPosTFF > 0 .AND. aFWSheet[nPosSht][2][nPosTFF][_fwOBJ] <> NIL
					cTempXml := aFWSheet[nPosSht][2][nPosTFF][_fwOBJ]:GetXMLModel(,,,,.F.,.T.,.F.) + CRLF
				Else
					cTempXml := ""
				EndIf

				If !Empty(cTempXml)
					// Identificador do Local
					cMemo	+= '|1|' + oMdlTFL:GetValue('TFL_CODIGO')
					// Identificador do Recurso Humano
					cMemo	+= '|2|' + oMdlTFF:GetValue('TFF_COD')
					cMemo	+= '|3|' + cTempXml

					If TFF->( ColumnPos('TFF_TABXML') ) > 0 .AND. (((oMdlTFF:GetValue('TFF_COBCTR') <> '2' .AND.;
						!(isInCallStack("At870GerOrc"))) .OR. (oMdlTFF:GetValue('TFF_COBCTR') == '2' .AND. isInCallStack("At870GerOrc"))))
						oMdlTFF:LoadValue('TFF_TABXML',cTempXml)
					EndIf
				EndIf
			EndIf
		Next nJ	// Recursos
	 EndIf
   EndIf
Next nI	// Locais

// Restaurar Ponteiros
FwRestRows( aSaveRows )

// Atribui para que seja gravada pelo Objeto no Banco
cXmlPrc := cMemo

Return cXmlPrc

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT740FCAFW
	Função que limpa/reinicia a variavel aFWSheet (Referencias aos Objetos de Calculo oFWSheet)
@sample 	AT740FCAFW()

@since		31/03/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Function AT740FCAFW()
Local lRet := .T.
aFWSheet := {}
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} AT740FCPY
	Função que inicializa dados de um modelo. (Aqui ela complementa a InitDados)
@sample 	AT740FCPY(oMdlGer,nPosLoc,nPosRH)

@param		[oMdlGer],objeto,Obrigatorio. Modelo de Dados do Orçamento
@param		[nPosLoc],numerico,Opcional. Representa uma posição especifica do modelo de Locais de Atendimento
@param		[nPosRH],numerico,Opcional. Representa uma posição especifica do modelo de Recursos Humanos

@since		31/03/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Function AT740FCPY(oMdlGer,nPosLoc,nPosRH, oLoad,lLoad)
Local nI			:= 0
Local nJ			:= 0
Local nLinLoc		:= 0
Local nLinRH		:= 0
Local cIDCampo	:= ''
Local nPosNick	:= 0
Local cPicture	:= ''
Local aSaveRows	:= {}
Local uValor := Nil
Local nIniLocal 	:= 1
Local nMaxLocal 	:= 0
Local nIniRh 	:= 1
Local nMaxRh 	:= 0
Local bWhen 	:= NIL //When do campo

Default nPosLoc	:= 0  // quando estes parâmetros não forem informados, irá realizar para todos os
Default nPosRH	:= 0  // locais e itens de recursos humanos
Default oLoad 	:= nil
Default lLoad	:= .F.

If !Empty(oMdlGer)
	// Savar Ponteiros
	aSaveRows	:= FwSaveRows()


	// verifica se foi recebida por parâmetro a linha do local que precisa ter o conteúdo copiado
	// caso tenha recebido limita a somente uma iteração e não percorre todas as linhas
	// quando não receber os parâmetros deixa a execução percorrer todas as linhas
	If nPosLoc > 0
		nIniLocal := nPosLoc
		nMaxLocal := nPosLoc
	Else
		nIniLocal := 1
		nMaxLocal := oMdlGer:GetModel('TFL_LOC'):Length()
	EndIf

	// Locais de Atendimento
	For nLinLoc := nIniLocal To nMaxLocal

		oMdlGer:GetModel('TFL_LOC'):GoLine( nLinLoc )

		// verifica se foi recebida por parâmetro a linha do local que precisa ter o conteúdo copiado
		// caso tenha recebido limita a somente uma iteração e não percorre todas as linhas
		// quando não receber os parâmetros deixa a execução percorrer todas as linhas
		If nPosRH > 0
			nIniRh := nPosRH
			nMaxRh := nPosRH
		Else
			nIniRh := 1
			nMaxRh := oMdlGer:GetModel('TFF_RH'):Length()
		EndIf

		// Recursos Humanos
		For nLinRH := nIniRh To nMaxRh

			oMdlGer:GetModel('TFF_RH'):GoLine( nLinRh )
			// verifica se há preenchimento no item de rh
			// só preenche para os itens que não são extras ou cortesia
			If lLoad .Or. (!Empty( oMdlGer:GetValue('TFF_RH','TFF_PRODUT') ) .And. oMdlGer:GetValue('TFF_RH','TFF_COBCTR') <> '2' .AND. (!EMPTY(oLoad) .OR. !EMPTY(aFWSheet[nLinLoc][2])))
				// carrega o objeto da planilha na variável
				If !EMPTY(oLoad)
					oFWSheet := oLoad
				Else
					oFWSheet := aFWSheet[nLinLoc][2][nLinRh][2]
				EndIf

				For nI := 1 To Len(aPrcOrc)

					For nJ	:= 1 To Len(aPrcOrc[nI][2])

						cIDCampo := AllTrim(aPrcOrc[nI][2][nJ][_TV7IDENT])

						nPosNick := AScan(OFWSHEET:OFWFORMULA:CELLS,{|o| o:NICKNAME == cIDCampo})

						If nPosNick > 0

							cPicture := OFWSHEET:OFWFORMULA:CELLS[nPosNick]:CPICTURE

							If aPrcOrc[nI][2][nJ][_TV7MODO] == '1'	// 1-Valor ; 2-Combo
								uValor := oFWSheet:GetCellValue(cIDCampo)
								uValor := If( ValType(uValor) == 'C', Val(uValor), uValor )
							Else
								uValor := Transform(oFWSheet:GetCellValue(cIDCampo), cPicture)
							EndIf

							If oMdlGer:GetOperation() <> MODEL_OPERATION_DELETE
								If cIDCampo == 'TOT_VIMP' .And. oMdlGer:GetOperation() <> MODEL_OPERATION_VIEW

									//Salva o when do campo
									bWhen := oMdlGer:GetModel(aPrcOrc[nI][3][2]):GetStruct():GetProperty( cIDCampo, MODEL_FIELD_WHEN)
									//Configura o when do campo como .T. para não dar problema no setvalue
									oMdlGer:GetModel(aPrcOrc[nI][3][2]):GetStruct():SetProperty(cIDCampo, MODEL_FIELD_WHEN, {|| .T.})
									oMdlGer:GetModel(aPrcOrc[nI][3][2]):SetValue(cIDCampo,uValor)
									//Restaura o when do campo
									oMdlGer:GetModel(aPrcOrc[nI][3][2]):GetStruct():SetProperty(cIDCampo, MODEL_FIELD_WHEN, bWhen)
								Else
									oMdlGer:GetModel(aPrcOrc[nI][3][2]):LoadValue(cIDCampo,uValor)
								EndIf
							EndIf
						EndIf

					Next nJ	// Campos Dinâmicos

				Next nI	// Abas

			EndIf

		Next lLinRh	// Recursos Humanos

	Next nLinLoc	// Locais de Atendimento

	// Restaura Ponteiros
	FwRestRows( aSaveRows )

EndIf

Return nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FVlDt
			Função para validação dos períodos iniciais e finais de: Recursos, Materiais e Alocações.

@sample 	At740FVlDt(cModelo,cCpoSelec,cCpoDtIn,cCpoDtFm)

@since		31/03/2015
@version	P11.90

@return 	lRet, Lógico, retorna .T. se data for válida.

@param  	cModelo, Caracter, nome do modelo de dados principal.
@param  	cCpoSelec, Caracter, nome do campo da data selecionada para validação.
@param  	cCpoDtIn, Caracter, nome do campo da data inicial.
@param  	cCpoDtFm, Caracter, nome do campo da data final.
/*/
//------------------------------------------------------------------------------
Function At740FVlDt(cModelo,cCpoSelec,cCpoDtIn,cCpoDtFm,oModel)

Local oMdl			:= nil
Local dDtIniLoc	:= CToD('')
Local dDtFimLoc	:= CToD('')
Local dDtFimRH  := CToD('')
Local lRet			:= .F.
Local lDTEncTFF 	:= FindFunction("TecEncDtFt") .AND. TecEncDtFt() .AND. !GSGetIns("LE")

Default oModel	:= FwModelActive()

oMdl		:= oModel:GetModel(cModelo)

dDtIniLoc	:= oModel:GetModel('TFL_LOC'):GetValue('TFL_DTINI')
dDtFimLoc	:= oModel:GetModel('TFL_LOC'):GetValue('TFL_DTFIM')

If SubStr(cCpoSelec,5) == "PERINI"

	If DTOS(oMdl:GetValue(cCpoDtIn)) >= DTOS(dDtIniLoc) .AND. (DTOS(oMdl:GetValue(cCpoDtIn)) <= DTOS(dDtFimLoc) .OR. Empty(dDtFimLoc) )
		lRet := .T.
	EndIf

ElseIf SubStr(cCpoSelec,5) == "PERFIM" 
	
	dDtFimRH := Posicione("TFF",1,oModel:GetModel("TFF_RH"):GetValue("TFF_FILIAL")+oModel:GetModel("TFF_RH"):GetValue("TFF_COD"),"TFF_PERFIM")
	
	If cModelo == "TFF_RH" .AND. lDTEncTFF .AND. oModel:GetModel("TFF_RH"):GetValue('TFF_ENCE') == '1' 
	
		If !Empty(oModel:GetModel(cModelo):GetValue('TFF_DTENCE'));
		    .AND. (oModel:GetModel(cModelo):GetValue('TFF_PERFIM') >= oModel:GetModel(cModelo):GetValue('TFF_DTENCE');
			.AND. oModel:GetModel(cModelo):GetValue('TFF_PERFIM') <= dDtFimRH)	
			lRet	:= .T.
		Else
	 		If Empty(oModel:GetModel(cModelo):GetValue('TFF_DTENCE')); 
			 	.AND. oModel:GetModel(cModelo):GetValue('TFF_PERFIM') <= dDtFimRH			   
	 			lRet := .T.			
	 		EndIf
	 	EndIf	
		
	ElseIf !lDTEncTFF .AND. oModel:GetModel("TFF_RH"):GetValue('TFF_ENCE') == '1' 
		If oModel:GetModel(cModelo):GetValue('TFF_PERFIM') <= dDtFimRH 
			lRet := .T.			
		EndIf	 				
	Else
		If !Empty(oMdl:GetValue(cCpoDtIn))
			If DTOS(oMdl:GetValue(cCpoDtFm)) >= DTOS(oMdl:GetValue(cCpoDtIn)) .AND. (DTOS(oMdl:GetValue(cCpoDtFm)) <= DTOS(dDtFimLoc) .OR. Empty(dDtFimLoc) )
				lRet := .T.
			EndIf
		EndIf
	EndIf
EndIf	
Return lRet



//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FVlVg
	Valida a Data de Vigência em todos os grids dependentes da tabela TFL

@sample 	At740FVlVg(oModel,cField)
@param		[oModel],object,Modelo de Dados do Orcamento
@param		[cField],caracter,Nome do campo relativo a data da localização que se pretende validar
@since		05/10/2013
@version	P11.90

@return 	lRet, Lógico, retorna .T. se data for válida.

@param  	oModel, Objeto, modelo de dados da tabela TFL
/*/
//------------------------------------------------------------------------------
Function At740FVlVg(oModel,cField)
Local lRet			:= .T.
Local oMdlGeral	:= oModel:GetModel()
Local aRefs		:= {}
Local aSaveRows	:= {}
Local nLin			:= 0
Local nI			:= 0
Local dDtIniLoc 	:= CToD('')
Local dDtFimLoc 	:= CToD('')
Local aErrorDef	:= {}			// Pode conter 0 ou 1 ocorrência de erro
Local oMdlTFJ := nil
Local aAreaCN9 := {}
Local cDtIniCtr := CToD('')

If oMdlGeral == nil
	oMdlGeral := FwModelActive()
EndIf

dDtIniLoc 	:= oMdlGeral:GetModel('TFL_LOC'):GetValue('TFL_DTINI')
dDtFimLoc 	:= oMdlGeral:GetModel('TFL_LOC'):GetValue('TFL_DTFIM')

// Aba Recursos humanos
AAdd(aRefs, {oMdlGeral:GetModel("TFF_RH"),"TFF_PER..."})
// Aba Materiais de Implantação
AAdd(aRefs, {oMdlGeral:GetModel("TFG_MI"),"TFG_PER..."})
// Aba Materiais de Consumo
AAdd(aRefs, {oMdlGeral:GetModel("TFH_MC"),"TFH_PER..."})
// Aba Locação de Equipamentos
AAdd(aRefs, {oMdlGeral:GetModel("TFI_LE"),"TFI_PER..."})

oMdlTFJ := oMdlGeral:GetModel("TFJ_REFER")

If IsInCallStack("At870Revis") 
	If !Empty(oMdlTFJ:GetValue('TFJ_CONTRT'))
		dbSelectArea("CN9")
		aAreaCN9 := CN9->(GetArea())
		CN9->(dbSetOrder(8))
		If CN9->(DbSeek(XFilial("CN9")+ oMdlTFJ:GetValue('TFJ_CONTRT')+oMdlTFJ:GetValue('TFJ_CONREV')))
			cDtIniCtr := CN9->CN9_DTINIC
		EndIf
		RestArea(aAreaCN9)
	EndIf
EndIf

aSaveRows := FwSaveRows()

For nI := 1 To Len(aRefs)
	For nLin := 1 to aRefs[nI][1]:Length()
		aRefs[nI][1]:GoLine( nLin )
		If !aRefs[nI][1]:IsDeleted()
			If		cField == 'TFL_DTINI' .and. !Empty(aRefs[nI][1]:GetValue(StrTran(aRefs[nI][2],'...','INI'))) .and.;
					DTOS(aRefs[nI][1]:GetValue(StrTran(aRefs[nI][2],'...','INI'))) < DTOS(dDtIniLoc)
				AAdd(aErrorDef,{aRefs[nI][1]:GetID(),STR0060,STR0061})  // 'Data inicial de vigência maior que o período inicial dos recursos, materiais e locação' ### 'Digite uma data menor.'
				lRet := .F.
			ElseIf	cField == 'TFL_DTFIM' .and. !Empty(aRefs[nI][1]:GetValue(StrTran(aRefs[nI][2],'...','FIM'))) .and.;
					DTOS(aRefs[nI][1]:GetValue(StrTran(aRefs[nI][2],'...','FIM'))) > DTOS(dDtFimLoc)
				AAdd(aErrorDef,{aRefs[nI][1]:GetID(),STR0062,STR0063})  // 'Data final de vigência menor que o período final dos recursos, materiais e locação' ### 'Digite uma data maior.'
				lRet := .F.
			EndIf
		EndIf
		If !lRet
			Exit
		EndIf
	Next nLin
	If !lRet
		Exit
	EndIf
Next nI

FwRestRows( aSaveRows )

If !(lRet := Len(aErrorDef) == 0)
	oModel:GetModel():SetErrorMessage(;
	oModel:GetId(),;	//ID DO FORMULáRIO EM VALIDAçãO
	cField,;			//ID DO CAMPO DO FORMULáRIO EM VALIDAçãO
	aErrorDef[1][1],;	//ID DO FORMULáRIO EM QUE OCORREU O ERRO
	cField,;			//ID DO CAMPO DO FORMULáRIO EM QUE OCORREU O ERRO
	cField,;			//ID DA MENSAGEM DE HELP
	aErrorDef[1][2],;	//MENSAGEM DE ERRO
	aErrorDef[1][3] )	//MENSAGEM DE SOLUçãO
EndIf

If 	lRet .and. !Empty(dDtFimLoc) .and. !Empty(dDtIniLoc) .and. (dDtFimLoc < dDtIniLoc)
	oModel:GetModel():SetErrorMessage(oModel:GetId(),"TFL_DTFIM",oModel:GetModel():GetId(),	"TFL_DTFIM",'TFL_DTFIM',;
		STR0063, STR0064 )  // 'Digite uma data maior.'###'Atenção!'
	lRet := .F.
EndIf

If !Empty(cDtIniCtr) .And. !Empty(dDtIniLoc) .And.dDtIniLoc < cDtIniCtr

	oModel:GetModel():SetErrorMessage(oModel:GetId(),"TFL_DTINI",oModel:GetModel():GetId(),	"TFL_DTINI",'TFL_DTINI',;
	STR0112, STR0063 )  // 'Data Inicial de vigência menor que o período inicial do contrato' ### 'Digite uma data maior.'
	lRet := .F.
EndIf 

Return lRet

/*/{Protheus.doc} At740fATFL
	Atualiza o código do local no array com as tabelas/planilhas

@sample 	At740fATFL( oMdlUse )
@param  	oModel, Objeto, modelo de dados da tabela TFL
/*/
Function At740fATFL( oMdlUse )

Default oMdlUse := FwModelActive():GetModel('TFL_LOC')

If Len(aFWSheet) < oMdlUse:GetLine()
	AAdd(aFWSheet, {oMdlUse:GetValue('TFL_CODIGO'),{},.T.})
Else
	aFWSheet[oMdlUse:GetLine()][1] := oMdlUse:GetValue('TFL_CODIGO')
EndIf

Return

/*/{Protheus.doc} PreLinTFL
	As validações foram transportadas para uma função no teca740 onde todas as demais pré validações de grid estão
	foi mantida a chamada original neste fonte para não gerar problemas na hora de compilação pelo robô
/*/
Function PreLinTFL(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)
Return ( PreLinTFL1(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue) )

/*/{Protheus.doc} At740FXmlbyTfl
	Atualiza o código do local no array com as tabelas/planilhas

@sample 	At740FXmlbyTfl( TFL->TFL_CODIGO, cXmlPrec )
@param  	cTflCodigo, Caractere, código da tfl que deverá ser pesquisada
@param 	cTabContent, Caractere, conteúdo gravado no campo TFJ_TABXML para verificação da existência de informações do local na proposta
@return 	aRet, Array de caracteres, lista com os xmls identificados que pertencem ao local formato { { Código TFF, XML }, { Código TFF, XML } }
/*/
Function At740FXmlbyTfl( cTflCodigo, cTabContent )
Local aRet 			:= {}
Local aAux1 			:= {}
Local aAux2 			:= {}
Local aAux3 			:= {}
Local nK 			:= 0

If !Empty( cTabContent ) .And. !Empty( cTflCodigo )

	aAux1 := Separa(cTabContent,'|1|')

	For nK := 1 To Len(aAux1)

		aAux2 := Separa(aAux1[nK],'|2|')

		If Len(aAux2) > 0 .And. aAux2[1]==cTflCodigo
			//------------------------------------------
			// Gera array com o seguinte formato
			// índice 1 = codigo TFL
			// índice 2 = codigo TFF
			// índice 3 = xml do item da TFF
			aAux3 := Separa(aAux2[2],'|3|')
			aAdd( aRet, { aAux3[1], aAux3[2] } ) // { código tff, xml }
		EndIf

	Next nK

EndIf

Return aClone(aRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F740FLockGrd

Verifica se as Grids filhas poderão ser alteradas ou não de acordo com a escolha do campo
TFJ_GESMAT no cabeçalho

@author Serviços
@since 22/06/2015
@version P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function F740FLockGrd( oMdlGer )

Local oView 	:= FWViewActive()	 //Recuperando a view ativa da interface
Local cGesMat := M->TFJ_GESMAT
Local lMINoIns := .F.
Local lMCNoIns := .F.

Default oMdlGer := oView:GetModel()

//Quando o campo gestão de materiais for Material por valor ou percentual do recurso
//eu não permito manutenções nas Grids de Material de Implantação e Material de Consumo
If !(isInCallStack("At870GerOrc"))
	If cGesMat == '2' .Or. cGesMat == '3'

		lMINoIns := .T.
		lMCNoIns := .T.

	ElseIf  cGesMat == '4'

		lMCNoIns := .T.
	ElseIf  cGesMat == '5'
		lMINoIns := .T.
	EndIf
	oMdlGer:GetModel('TFG_MI'):SetNoInsertLine(lMINoIns)
	oMdlGer:GetModel('TFG_MI'):SetNoUpdateLine(lMINoIns)
	oMdlGer:GetModel('TFG_MI'):SetNoDeleteLine(lMINoIns)

	oMdlGer:GetModel('TFH_MC'):SetNoInsertLine(lMCNoIns)
	oMdlGer:GetModel('TFH_MC'):SetNoUpdateLine(lMCNoIns)
	oMdlGer:GetModel('TFH_MC'):SetNoDeleteLine(lMCNoIns)

EndIf


If oMdlGer:GetValue('TFL_LOC', 'TFL_ENCE') == '1'
	oMdlGer:GetModel('TFH_MC'):SetNoInsertLine(.T.)
	oMdlGer:GetModel('TFG_MI'):SetNoInsertLine(.T.)
EndIf

Return ( .T. )
/*/
At740fTDS


@sample 	At740fTDS()

@since		20/07/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740fTDS()

Local cCodTCZ  := ""
Local cDescTCZ := ""
Local oMdl   	 := FwModelActive()

If oMdl:GetId()=="TECA740" .Or. oMdl:GetId()=="TECA740F"

	cCodTCZ := oMdl:GetModel( "TDS_RH" ):GetValue( "TDS_CODTCZ" )
	cDescTCZ:= Posicione("TCZ",1,xFilial("TCZ") + cCodTCZ ,"TCZ->TCZ_DESC")

EndIf

Return(cDescTCZ)

//------------------------------------------------------------------------------
/*/
At740fTDT


@sample 	At740fTDT()

@since		20/07/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740fTDT(cSeq)

Local cCodRBG  := ""
Local cCodEsc  := ""
Local cItEsc   := ""
Local cDesc    := ""
Local oMdl   	 := FwModelActive()

If oMdl:GetId()=="TECA740" .Or. oMdl:GetId()=="TECA740F"

	Do Case

	Case cSeq == '1'
		//codigo da habilidade
		cCodRBG := oMdl:GetModel( "TDT_RH" ):GetValue( "TDT_CODHAB" )
		cDesc   := Posicione("RBG",1,xFilial("RBG") + cCodRBG ,"RBG->RBG_DESC")
	Case cSeq == '2'
		//codigo escala
		cCodEsc := oMdl:GetModel( "TDT_RH" ):GetValue( "TDT_ESCALA" )
		cDesc   := Posicione("RBK",1,xFilial("RBK") + cCodEsc ,"RBK->RBK_DESCRI")
	Case cSeq == '3'
		//codigo item escala
		cCodEsc := oMdl:GetModel( "TDT_RH" ):GetValue( "TDT_ESCALA" )
		cItEsc  := oMdl:GetModel( "TDT_RH" ):GetValue( "TDT_ITESCA" )
		cDesc   := Posicione("RBL",1,xFilial("RBL") + cCodEsc + cItEsc ,"RBL->RBL_DESCRI")
	Case cSeq == '4'
		//codigo da habilidade X5
		cCodX5  := oMdl:GetModel( "TDT_RH" ):GetValue( "TDT_HABX5" )
		cDesc   := Posicione("SX5",1,xFilial("SX5")+"A4"+cCodX5,"X5_DESCRI")
	ENDCASE

EndIf

Return(cDesc)
//------------------------------------------------------------------------------
/*/
At740fTGV


@sample 	At740fTGV()

@since		20/07/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740fTGV()

Local cCodTGV  := ""
Local cDesc    := ""
Local oMdl   	 := FwModelActive()

If oMdl:GetId()=="TECA740" .Or. oMdl:GetId()=="TECA740F"

		//codigo da curso
		cCodTGV := oMdl:GetModel( "TGV_RH" ):GetValue( "TGV_CURSO" )
		cDesc   := Posicione("RA1",1,xFilial("RA1") + cCodTGV ,"RA1->RA1_DESC")

EndIf

Return(cDesc)

//-------------------------------------------------------------------
/*/{Protheus.doc} A740FPVld
	Pre Valid do modelo

@since 10/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function A740FPVld(oModel,cAcao)
Local lRet 	:= .T.
Local oMdl740 := oModel:GetModel()

If cAcao == 'SETVALUE'
	oMdl740:GetModel('TFF_RH'):LoadValue('TFF_PROCES',.F.)
EndIf

Return lRet

Function At40GetAFWS()
Return aFWSheet

/*/{Protheus.doc} At740CalcDpr
	Calcula o valor total a ser cobrado no material de implantação de acordo com o valor
	do ativo dividido pela vida util do equipamento.

@return nRet Valor final a ser preenchido no valor unitario do material de implantação
/*/
Function At740CalcDpr()
	Local nRet := (FwFldGet('TFG_VLATIV')/FwFldGet('TFG_VIDMES')*(At740FDDiff(FwFldGet('TFG_PERINI'),FwFldGet('TFG_PERFIM'))))
Return nRet

/*/{Protheus.doc} At740fchk
	  verificações para permitir ou não o uso da tabela de precificação
@param 		cTabCod, Caracter, código da tabela a ser avaliada
@param 		cTabRev, Caracter, revisão da tabela a ser avaliada
@return 	Lógico, determina se pode ou não utilizar a tabela de precificação
/*/
Function At740fchk( cTabCod, cTabRev )
Local lRet := .T.
Local cTot_VImp := PadR("TOT_VIMP", TamSX3("TV7_IDENT")[1])
Local lAgrupado := SuperGetMv("MV_GSDSGCN",,"2") == "2"
Local lSomaImp := SuperGetMv("MV_ATOPIMP",,.T.)
Local cQry := ""

//Verifica se a geração dos itens no contrato é desagrupada e se há imposto ativo
If !lAgrupado .And. lSomaImp

	If ( At740fTotImp( cTabCod, cTabRev ) )
		lRet := .F.
		Help( "", 1, "At740fchk_1", , STR0071, 1, 0,,,,,,; // "Não pode selecionar tabela de precificação com soma de imposto em contratos a serem gerados desagrupados."
								{STR0072}) // "Desabilite algum dos parâmetros (MV_GSDSGCN ou MV_ATOPIMP) ou selecione uma tabela de precificação que não tenha imposto."
	EndIf

EndIf

Return lRet

/*/{Protheus.doc} At740fTotImp
	  Verifica se a tabela de precificação tem o campo de total de imposto
@param 		cTabCod, Caracter, código da tabela a ser avaliada
@param 		cTabRev, Caracter, revisão da tabela a ser avaliada
@return 	Lógico, determina se existe (.T.) ou não (.F.) o total de imposto (TOT_VIMP) na tabela
/*/
Function At740fTotImp( cTabCod, cTabRev )
Local lRet := .F.
Local cTot_VImp := PadR("TOT_VIMP", TamSX3("TV7_IDENT")[1])
Local cQry := ""
Local aArea := GetArea()
Local aAreaTV6 := TV6->(GetArea())
Local aAreaTV7 := TV7->(GetArea())

cQry := GetNextAlias()

BeginSQL Alias cQry
	SELECT 1
	FROM %Table:TV6% TV6
	WHERE TV6_FILIAL = %xFilial:TV6%
		AND TV6_NUMERO = %Exp:cTabCod%
		AND TV6_REVISA = %Exp:cTabRev%
		AND TV6.%NotDel%
		AND EXISTS (
				SELECT 1
				FROM %Table:TV7% TV7
				WHERE TV7_FILIAL = %xFilial:TV7%
							AND TV7_CODTAB = TV6_CODIGO
							AND TV7_IDENT = %Exp:cTot_VImp%
							AND TV7.%NotDel%
		)
EndSQL

lRet := (cQry)->(!EOF())

(cQry)->(DbCloseArea())

RestArea(aAreaTV7)
RestArea(aAreaTV6)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At740TotImp
	Formula do campo total de impostos do orçamento

@since 10/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function At740TotImp(oModel)
Local nI 		 := 1
Local oMdlLoc	 := oModel:GetModel("TFL_LOC")
Local nVlrImp := 0

For nI := 1 To oMdlLoc:Length()
	If !oMdlLoc:IsDeleted()
		nVlrImp += oMdlLoc:GetValue('TFL_TOTIMP',nI)
	EndIf
Next nI
Return nVlrImp

/*/{Protheus.doc} AtIsCalcId
	Verifica se um conteúdo de inicializador deve disparar processo
para identificação de conteúdo dentro do orçamento de serviços
@author 		josimar.assuncao
/*/
Function AtIsCalcId( cFuncao )
Local cStrFuncoes := 'BLR_FUNCAO;BLP_FUNCAO;VLTXADM_FUNCAO;VLR_RH_FUNCAO;VLR_MI_FUNCAO;VLR_MC_FUNCAO;VLR_LE_FUNCAO'
Local lRet := ( cFuncao $ cStrFuncoes )

Return lRet

/*/{Protheus.doc} AtCalcIdent
	Calcula conforme o id de cálculo de inicializador dos campos da tabela de precificação
@author 		josimar.assuncao
/*/
Function AtCalcIdent( cFuncao, oMdlMain, cMdlTFL, cMdlTFF, cMdlTFG, cMdlTFH, cMdlTFI, cMdlTEV )
Local nK			:= 0
Local nL 			:= 0
Local nTotRH		:= 0
Local nTotMI		:= 0
Local nTotMC		:= 0
Local nTotLe 		:= 0
Local nLinMdl		:= 0
Local nVlrLuc		:= 0

Default cMdlTFL := "TFL_LOC"
Default cMdlTFF := "TFF_RH"
Default cMdlTFG := "TFG_MI"
Default cMdlTFH := "TFH_MC"
Default cMdlTFI := "TFI_LE"
Default cMdlTEV := "TEV_ADICIO"

If cFuncao == 'BLR_FUNCAO' // 'BLR_FUNCAO' - soma o valor da taxa de lucro

	// Levantamento do totalizador para os impostos do RH
	nLinMdl := oMdlMain:GetModel(cMdlTFF):GetLine()
	nVlrLuc := 0

	For nK:=1 To oMdlMain:GetModel(cMdlTFF):Length()
		oMdlMain:GetModel(cMdlTFF):GoLine(nK)
		nVlrLuc += oMdlMain:GetModel(cMdlTFF):GetValue("TFF_TXLUCR")
	Next nK

	nTotRH	:= nVlrLuc
	oMdlMain:GetModel(cMdlTFF):GoLine(nLinMdl)

	// Levantamento do totalizador para os impostos do MI
	nLinMdl := oMdlMain:GetModel(cMdlTFG):GetLine()
	nVlrLuc := 0

	For nK:=1 To oMdlMain:GetModel(cMdlTFG):Length()
		oMdlMain:GetModel(cMdlTFG):GoLine(nK)
		nVlrLuc += oMdlMain:GetModel(cMdlTFG):GetValue("TFG_TXLUCR")
	Next nK

	nTotMI	:= 	nVlrLuc
	oMdlMain:GetModel(cMdlTFG):GoLine(nLinMdl)

	// Levantamento do totalizador para os impostos do MC
	nLinMdl := oMdlMain:GetModel(cMdlTFH):GetLine()
	nVlrLuc := 0

	For nK:=1 To oMdlMain:GetModel(cMdlTFH):Length()
		oMdlMain:GetModel(cMdlTFH):GoLine(nK)
		nVlrLuc += oMdlMain:GetModel(cMdlTFH):GetValue("TFH_TXLUCR")
	Next nK

	nTotMC	:= 	nVlrLuc
	oMdlMain:GetModel(cMdlTFH):GoLine(nLinMdl)

ElseIf cFuncao == 'BLP_FUNCAO'	// 'BLP_FUNCAO' - soma o total dos itens, exceto de locação
	nTotRH	:= oMdlMain:GetModel(cMdlTFL):GetValue("TFL_TOTRH")
	nTotMI	:= oMdlMain:GetModel(cMdlTFL):GetValue("TFL_TOTMI")
	nTotMC	:= oMdlMain:GetModel(cMdlTFL):GetValue("TFL_TOTMC")

ElseIf cFuncao == 'VLTXADM_FUNCAO'	// 'VLTXADM_FUNCAO' - soma os valores dos campos TXADM de todos os conceitos de produtos
	// inicializa as variáveis
	nTotRH := 0
	nTotMI := 0
	nTotMC := 0
	nTotLe := 0

	// soma os valores de rh
	nLinMdl := oMdlMain:GetModel(cMdlTFF):GetLine()
	For nK := 1 To oMdlMain:GetModel(cMdlTFF):Length()
		nTotRH += oMdlMain:GetModel(cMdlTFF):GetValue("TFF_TXADM", nK)
	Next nK
	oMdlMain:GetModel(cMdlTFF):GoLine(nLinMdl)

	// soma os valores de mat. implantação
	nLinMdl := oMdlMain:GetModel(cMdlTFG):GetLine()
	For nK := 1 To oMdlMain:GetModel(cMdlTFG):Length()
		nTotMI += oMdlMain:GetModel(cMdlTFG):GetValue("TFG_TXADM", nK)
	Next nK
	oMdlMain:GetModel(cMdlTFG):GoLine(nLinMdl)

	// soma os valores de mat. consumo
	nLinMdl := oMdlMain:GetModel(cMdlTFH):GetLine()
	For nK := 1 To oMdlMain:GetModel(cMdlTFH):Length()
		nTotMC += oMdlMain:GetModel(cMdlTFH):GetValue("TFH_TXADM", nK)
	Next nK
	oMdlMain:GetModel(cMdlTFH):GoLine(nLinMdl)

	// soma os valores de locação
	nLinMdl := oMdlMain:GetModel(cMdlTFI):GetLine()
	For nL := 1 To oMdlMain:GetModel(cMdlTFI):Length()
		oMdlMain:GetModel(cMdlTFI):GoLine(nL)

		For nK := 1 To oMdlMain:GetModel(cMdlTEV):Length()
			nTotLe += oMdlMain:GetModel(cMdlTEV):GetValue("TEV_TXADM", nK)
		Next nK
	Next nL
	oMdlMain:GetModel(cMdlTFI):GoLine(nLinMdl)

ElseIf cFuncao == 'VLR_RH_FUNCAO' // >> Total dos itens de RH do local sem considerar lucro e tx adm

	// inicializa as variáveis
	nTotRH := 0
	nTotMI := 0
	nTotMC := 0
	nTotLe := 0

	// soma os valores de rh
	nLinMdl := oMdlMain:GetModel(cMdlTFF):GetLine()
	For nK := 1 To oMdlMain:GetModel(cMdlTFF):Length()
		// ( TFF_QTDVEN * TFF_PRCVEN ) - TFF_VALDES
		nTotRH += ( oMdlMain:GetModel(cMdlTFF):GetValue("TFF_QTDVEN", nK) * oMdlMain:GetModel(cMdlTFF):GetValue("TFF_PRCVEN", nK) ) - oMdlMain:GetModel(cMdlTFF):GetValue("TFF_VALDES", nK)
	Next nK
	oMdlMain:GetModel(cMdlTFF):GoLine(nLinMdl)


ElseIf cFuncao == 'VLR_MI_FUNCAO' // >> Total dos itens de Mi do local sem considerar lucro e tx adm

	// inicializa as variáveis
	nTotRH := 0
	nTotMI := 0
	nTotMC := 0
	nTotLe := 0

	// soma os valores de mat. implantação
	nLinMdl := oMdlMain:GetModel(cMdlTFG):GetLine()
	For nK := 1 To oMdlMain:GetModel(cMdlTFG):Length()
		// TFG_TOTAL
		nTotMI += oMdlMain:GetModel(cMdlTFG):GetValue("TFG_TOTAL", nK)
	Next nK
	oMdlMain:GetModel(cMdlTFG):GoLine(nLinMdl)

ElseIf cFuncao == 'VLR_MC_FUNCAO' // >> Total dos itens de Mc do local sem considerar lucro e tx adm

	// inicializa as variáveis
	nTotRH := 0
	nTotMI := 0
	nTotMC := 0
	nTotLe := 0

	// soma os valores de mat. consumo
	nLinMdl := oMdlMain:GetModel(cMdlTFH):GetLine()
	For nK := 1 To oMdlMain:GetModel(cMdlTFH):Length()
		// TFH_TOTAL
		nTotMC += oMdlMain:GetModel(cMdlTFH):GetValue("TFH_TOTAL", nK)
	Next nK
	oMdlMain:GetModel(cMdlTFH):GoLine(nLinMdl)

ElseIf cFuncao == 'VLR_LE_FUNCAO' // >> Total dos itens de Le do local sem considerar lucro e tx adm

	// inicializa as variáveis
	nTotRH := 0
	nTotMI := 0
	nTotMC := 0
	nTotLe := 0

	// soma os valores de locação
	nLinMdl := oMdlMain:GetModel(cMdlTFI):GetLine()
	For nL := 1 To oMdlMain:GetModel(cMdlTFI):Length()
		oMdlMain:GetModel(cMdlTFI):GoLine(nL)
		// SOMA [TEV_SUBTOT] - TFI_VALDES
		For nK := 1 To oMdlMain:GetModel(cMdlTEV):Length()
			nTotLe += oMdlMain:GetModel(cMdlTEV):GetValue("TEV_SUBTOT", nK)
		Next nK
		nTotLe - oMdlMain:GetModel(cMdlTFI):GetValue("TFI_VALDES", nL)
	Next nL
	oMdlMain:GetModel(cMdlTFI):GoLine(nLinMdl)

EndIf

Return (nTotRH+nTotMI+nTotMC+nTotLe)

/*/{Protheus.doc} At740fcItem
	Quebrando a execução do botão calcular da tabela de precificação para facilitar debug
@author 		josimar.assuncao
/*/
Static Function At740fcItem( nOrigem )
If (!oMdl740F:GetValue('TFF_RH',"TFF_LOADPRC") .And. oMdl740F:GetModel('TFF_RH'):IsInserted()) .Or. (oMdl740F:GetValue('TFF_RH',"TFF_LOADPRC") .And. !oMdl740F:GetModel('TFF_RH'):IsInserted())
	// verifica se é item de contrato
	If (oMdl740F:GetValue('TFF_RH','TFF_COBCTR')<>'2' .AND. !(isInCallStack("At870GerOrc")) .OR.;
			(isInCallStack("At870GerOrc")) .AND. oMdl740F:GetValue('TFF_RH','TFF_COBCTR')=='2' )
		If IsBlind()
			At740EEPC(At740FGSS(oMdl740F),aPrcOrc,oMdl740F, /*aCampos*/, nOrigem )
		Else
			Processa({|| At740EEPC(At740FGSS(oMdl740F),aPrcOrc,oMdl740F, /*aCampos*/, nOrigem ) },STR0046, STR0047,.F.)  // executa o cálculo quando item de contrato
			If ValType(oViw740F) == "O"
				oViw740F:Refresh()
			EndIf
		EndIf
	Else
		If oMdl740F:GetValue('TFF_RH','TFF_COBCTR') == '2' .AND. !(isInCallStack("At870GerOrc"))
			Help(,, "CpCalCOBCTR2",,STR0088,1,0,,,,,,{STR0089}) //"Não é possível modificar itens que não são cobrados no contrato nesta rotina" ## "Para alterar este item, acesse a opção Item Extra dentro da Gestão dos Contratos (TECA870)"
		ElseIf oMdl740F:GetValue('TFF_RH','TFF_COBCTR') <> '2' .AND. isInCallStack("At870GerOrc")
			Help(,, "CpCalCOBCTR1",,STR0090,1,0,,,,,,{STR0091}) //"Não é possível modificar itens que são cobrados no contrato através da rotina Item Extra" ## "Para alterar este item, realize uma Revisão do Contrato"
		EndIf
	EndIf
Else
	Help(,, "At740fcItem",,"Valores da tabela de preço não foram carregadas",1,0,,,,,,{"Clique em consultar para o carregamento dos valores da tabela de preço"})//"Valores da tabela de preço não foram carregadas"##"Clique em consultar para o carregamento dos valores da tabela de preço"
EndIf	
Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} HideFolder
	Esconde o objeto

@sample 	HideFolder(oModel,cField,xValue)
@param		ExpC1	Codigo do contrato

@author		Kaique Schiller
@since		10/04/2017
@version	P12
/*/
//------------------------------------------------------------------------------
Function At740FHdFld(oModel,cField,xValue)
Local oView 	:= FwViewActive()
Local aFolder	:= {}
Local nX		:= 0

aFolder := oView:GetFolderActive("ABAS", 2)

//Percorre os folder's para não selecionar um folder invalido.
For nX := 1 To Len(oView:aFolders[1][4])
	If !(oView:aFolders[1][4][nX][2] $ STR0074+"|"+STR0025)
		oView:SelectFolder("ABAS", oView:aFolders[1][4][nX][2],2)
	Endif
Next nX

IF xValue == '1'
	oView:SelectFolder("ABAS", STR0074,2) // "Resumo Geral"
	oView:HideFolder("ABAS", STR0025,2)   // "Resumo Geral Recorrente"
Else
	oView:SelectFolder("ABAS", STR0025,2) // "Resumo Geral"
	oView:HideFolder("ABAS", STR0074,2)   // "Resumo Geral Recorrente"
EndIf

//Se estiver posicionado no foldar que sera escondido, volta para o folder
If aFolder[2] $ STR0074+"|"+STR0025
	oView:SelectFolder("ABAS", STR0022,2) // Local de atendimento
Else
	oView:SelectFolder("ABAS", aFolder[2],2) // Restaura o ultimo folder posicionado.
Endif

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FLXML
Função para preencher os dados da TFF_TABXML.

@sample 	At740FLXML()
@since		08/06/2018
@version	P12
/*/
//------------------------------------------------------------------------------
Function At740FLXML()

Local cCodTFJ	:= ''
Local cCodXML	:= ''
Local cTmpQry	:= ''
Local cXML		:= ''
Local nAnt		:= 1
Local nPos		:= 0

cTmpQry	:= GetNextAlias()
DbSelectArea('TFJ')

BeginSql Alias cTmpQry

	SELECT TFJ_CODIGO
			,TFL_CODPAI
			,TFL_CODIGO
			,TFF_CODPAI
			,TFF_COD
			,TFF.R_E_C_N_O_ RECNOTFF
	FROM %Table:TFJ% TFJ
      INNER JOIN %Table:TFL% TFL ON
        TFL.TFL_FILIAL = %xFilial:TFL%
        AND TFL.TFL_CODPAI = TFJ.TFJ_CODIGO
      INNER JOIN %Table:TFF% TFF ON
        TFF.TFF_FILIAL = %xFilial:TFF%
        AND TFF.TFF_CODPAI = TFL.TFL_CODIGO
      WHERE TFJ.TFJ_FILIAL = %xFilial:TFJ%
        AND TFJ.TFJ_TABXML IS NOT NULL
        AND TFF.TFF_TABXML IS NULL
        AND TFJ.TFJ_CODTAB <> %Exp:' '%
        AND TFJ.%NotDel%
        AND TFL.%NotDel%
        AND TFF.%NotDel%
EndSql

Begin Transaction	//- Inicia Processo

While (cTmpQry)->(!Eof())

	//Captura o XML o campo TFJ_TABXML
	If cCodTFJ <> (cTmpQry)->TFJ_CODIGO
		cXml := GetXmlTFJ((cTmpQry)->TFJ_CODIGO)
	EndIf

	//Realiza a quebra do XML para cada item de RH
	nAnt := At('|1|' +(cTmpQry)->TFL_CODIGO + '|2|' + (cTmpQry)->TFF_COD + '|3|', cXml) +;
															 Len('|1|' +(cTmpQry)->TFL_CODIGO + '|2|' + (cTmpQry)->TFF_COD + '|3|')
	nPos := At( '</FWMODELSHEET>', cXML, nAnt) + 15
	cCodXML := Substr( cXML, nAnt, nPos - nAnt )

	TFF->(DbGoTo((cTmpQry)->RECNOTFF))
	RecLock('TFF', .F.)
	TFF->TFF_TABXML := cCodXML
	TFF->( MsUnlock() )

	cCodXML := ''
	cCodTFJ := (cTmpQry)->TFJ_CODIGO
	(cTmpQry)->(DbSkip())

EndDo

End Transaction
(cTmpQry)->(DbCloseArea())

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetXmlTFJ
Função para capturar XML da TFJ_TABXML.

@sample 	GetXmlTFJ()
@since		20/06/2018
@version	P12
/*/
//------------------------------------------------------------------------------
Function GetXmlTFJ(cCodPai)
Local cXml := ""

DbSelectArea('TFJ')
TFJ->(dbSetOrder(1))

If TFJ->(DbSeek(xFilial("TFJ")+cCodPai))
	cXml  := TFJ->TFJ_TABXML
EndIf

Return cXml

//------------------------------------------------------------------------------
/*/{Protheus.doc} A740PutLeg
Verifica se insere legenda nas grids do orçamento

@sample 	GetXmlTFJ()
@since		20/06/2018
@version	P12
/*/
//------------------------------------------------------------------------------
Function A740PutLeg()

lRet := !IsInCallStack('a745IncOrc') .And. !IsInCallStack('At600SeAtu') .And. !Empty(TFJ->TFJ_CONTRT)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} at740DClck
Duplo clique da legenda no orçamento

@sample 	at740DClck()
@since		20/06/2018
@version	P12
/*/
//------------------------------------------------------------------------------
Function at740DClck(oFormulario,cFieldName)
Local aLeg             := {}

If 'TFL_LEGEN' == cFieldName
	aAdd(aLeg,{"BR_VERDE",STR0081})
	aAdd(aLeg,{"BR_CINZA",STR0082})

	BrwLegenda(STR0083,STR0084,aLeg)
ElseIf cFieldName $ 'TFI_LEGEN|TFF_LEGEN'
	aAdd(aLeg,{"BR_VERDE",STR0085})
	aAdd(aLeg,{"BR_CINZA",STR0086})

	BrwLegenda(STR0083,STR0084,aLeg)
EndIf

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740AddLeg
Adiciona legenda nas estruturas

@sample 	At740AddLeg()
@since		20/06/2018
@version	P12
/*/
//------------------------------------------------------------------------------
Function At740AddLeg(lModel,aEstruTFL,aEstruTFF,aEstruTFI,oView)
Default oView := Nil

If lModel
	aEstruTFL[1]:AddField(" ","","TFL_LEGEN","C",15,0,{||.T.},NIL,{},NIL,FwBuildFeature(STRUCT_FEATURE_INIPAD,"'BR_VERDE'"),NIL,NIL,.T.)
	aEstruTFF[1]:AddField(" ","","TFF_LEGEN","C",15,0,{||.T.},NIL,{},NIL,FwBuildFeature(STRUCT_FEATURE_INIPAD,"'BR_VERDE'"),NIL,NIL,.T.)
	If !(IsInCallStack("At870GerOrc"))
		aEstruTFI[1]:AddField(" ","","TFI_LEGEN","C",15,0,{||.T.},NIL,{},NIL,FwBuildFeature(STRUCT_FEATURE_INIPAD,"'BR_VERDE'"),NIL,NIL,.T.)
	EndIf
Else
	aEstruTFL[1]:AddField('TFL_LEGEN','00',""," ",{},'C','@BMP',NIL,'',.F.,NIL,NIL,{},NIL,Nil,.T.,NIL)
	oView:SetViewProperty(aEstruTFL[2], "GRIDDOUBLECLICK", {{|oFormulario,cFieldName,nLineGrid,nLineModel| at740DClck(oFormulario,cFieldName)}})

	aEstruTFF[1]:AddField('TFF_LEGEN','00',""," ",{},'C','@BMP',NIL,'',.F.,NIL,NIL,{},NIL,Nil,.T.,NIL)
	oView:SetViewProperty(aEstruTFF[2], "GRIDDOUBLECLICK", {{|oFormulario,cFieldName,nLineGrid,nLineModel| at740DClck(oFormulario,cFieldName)}})

	If !(IsInCallStack("At870GerOrc"))
		aEstruTFI[1]:AddField('TFI_LEGEN','00',""," ",{},'C','@BMP',NIL,'',.F.,NIL,NIL,{},NIL,Nil,.T.,NIL)
		oView:SetViewProperty(aEstruTFI[2], "GRIDDOUBLECLICK", {{|oFormulario,cFieldName,nLineGrid,nLineModel| at740DClck(oFormulario,cFieldName)}})
	EndIf

EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740SetLeg

@sample 	At740SetLeg()
@since		20/06/2018
@version	P12
/*/
//------------------------------------------------------------------------------
Function At740SetLeg(cTabela,oMdl)

If oMdl:GetOperation() <> MODEL_OPERATION_VIEW
	If oMdl:GetValue(cTabela + '_ENCE') == '1'
		oMdl:LoadValue( cTabela + '_LEGEN', 'BR_CINZA')
	EndIf
Else
	If oMdl:GetValue(cTabela + '_ENCE') == '1'
		oMdl:LoadValue( cTabela + '_LEGEN', 'BR_CINZA')
	Else
		oMdl:LoadValue( cTabela + '_LEGEN', 'BR_VERDE')
	EndIf
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740fLkGd

@description executa a função static F740FLockGrd
@since		22/10/2018
@version	P12
@author	Mateus Boiani
/*/
//------------------------------------------------------------------------------
Function At740fLkGd(oModel)

Return F740FLockGrd(oModel)

//------------------------------------------------------------------------------
/*/{Protheus.doc} at740ClSht

@description Limpa as variaveis estaticas que controlam os componentes da tabela de precificação
@since		13/12/2018
@version	P12
@author	Matheus Lando Raimundo
/*/
//------------------------------------------------------------------------------
Function at740ClSht()

aFWSheet := {}
TecDestroy(oFWSheet)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VlCli
	Valida cliente

@author		Matheus Lando Raimundo
@since		01/03/2018
@version	P12
/*/
//------------------------------------------------------------------------------
Function At740VlCli(oModel)
Local lRet := .F.
Local aArea := GetArea()
SA1->( DbSetOrder( 1 ) ) // B1_FILIAL+B1_COD

lRet := SA1->(DbSeek(xFilial("SA1")+oModel:GetValue('TFJ_CODENT')+oModel:GetValue('TFJ_LOJA')))

RestArea(aArea)
Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740MdSm
	Altera estrutura do modelo para orçamento simplificado


@author		Matheus Lando Raimundo
@since		01/03/2018
@version	P12
/*/
//------------------------------------------------------------------------------
Function At740MdSm(oStrTFJ)
Local lOrcSimp := SuperGetMV("MV_ORCSIMP",,'2') == '1'

If IsInCallStack('TECA745') .OR. (lOrcSimp .AND. isInCallStack("TECA270"))
	oStrTFJ:SetProperty( "TFJ_CODENT", MODEL_FIELD_OBRIGAT, .T. )
	oStrTFJ:SetProperty( "TFJ_LOJA", MODEL_FIELD_OBRIGAT, .T. )
	oStrTFJ:SetProperty( "TFJ_CODENT", MODEL_FIELD_TITULO , 'Cliente' )
	oStrTFJ:SetProperty( "TFJ_LOJA", MODEL_FIELD_TITULO , 'Loja' )
	oStrTFJ:SetProperty( "TFJ_CODENT", MODEL_FIELD_NOUPD , .F. )
	oStrTFJ:SetProperty( "TFJ_LOJA", MODEL_FIELD_NOUPD , .F. )
	oStrTFJ:SetProperty("TFJ_LOJA" ,MODEL_FIELD_VALID,{|a,b,c,d,e| FWInitCpo(a,b,c,d),lRet := At740VlCli(a),FWCloseCpo(a,b,c,lRet,.T.),lRet})
EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740MdSm
	Altera estrutura da view para orçamento simplificado
@author		Matheus Lando Raimundo
@since		01/03/2018
@version	P12
/*/
//------------------------------------------------------------------------------
Function At740VwSm(oStrTFJ)
Local lOrcSimp := SuperGetMV("MV_ORCSIMP",,'2') == '1'

If IsInCallStack('TECA745') .OR. (lOrcSimp .AND. isInCallStack("TECA270"))
	oStrTFJ:SetProperty( "TFJ_CODENT", MVC_VIEW_LOOKUP  , 'SA1' )
	oStrTFJ:SetProperty( "TFJ_CODENT", MVC_VIEW_CANCHANGE  , .T. )
	oStrTFJ:SetProperty( "TFJ_LOJA", MVC_VIEW_CANCHANGE  , .T. )
	oStrTFJ:SetProperty( "TFJ_CODENT", MVC_VIEW_TITULO   , 'Cliente' )
	oStrTFJ:SetProperty( "TFJ_LOJA", MVC_VIEW_TITULO   , 'Loja' )
EndIf

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740StSm
	Seta valores para orçamento simplificado


@author		Matheus Lando Raimundo
@since		01/03/2018
@version	P12
/*/
//------------------------------------------------------------------------------
Function At740StSm(oMdlTFJ)

If (IsInCallStack('TECA745') .OR. isInCallStack("TECA270")) .And. oMdlTFJ:GetOperation() != MODEL_OPERATION_DELETE
	At740Set(oMdlTFJ, 'TFJ_ENTIDA', '1' )
EndIf

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} GetNextTFI
	Resulta o próximo valor disponível para a TFI


@author		Matheus Lando Raimundo
@since		15/03/2019
@version	P12
/*/
//-------------------------------------------------------------------------------
Function GetNextTFI()
Local cNext := ""

TFI->(DbSetorder(1))
While TFI->(DbSeek( xFilial('TFI') + (cNext := GetSXENUM('TFI', 'TFI_COD'))))
	ConfirmSX8()
	Loop
EndDo

Return cNext
//------------------------------------------------------------------------------
/*/{Protheus.doc} AtLoadTFF
	Load Data da grid de RH (TFF)
@author		Matheus Lando Raimundo
@since		15/03/2019
@version	P12
/*/
//-------------------------------------------------------------------------------
Function AtLoadTFF(oMdl)
Local aRet := {}
Local cAliasTFF := GetNextAlias()
Local cAliasTFH	:= GetNextAlias()
Local cAliasTFG	:= GetNextAlias()
Local nLenFlds := 0
Local aAux := {}
Local oModel := oMdl:GetModel()
Local oMdlLoc := oModel:GetModel('TFL_LOC')
Local nCodLoc := oMdlLoc:GetValue('TFL_CODIGO')
Local cCodTFF	:= ""
Local nTotGerRH := 0
Local lOrcPrc := SuperGetMv("MV_ORCPRC",,.F.)
Local oStru   := oMdl:GetStruct()
Local nI := 1
Local aAreaX3 := SX3->(GetArea())
Local aFields := {}
Local lGsOrcUnif := FindFunction("TecGsUnif") .And. TecGsUnif()
Local lGsOrcArma := FindFunction("TecGsArma") .And. TecGsArma()
Local lTpCobr := TFF->( ColumnPos('TFF_TPCOBR') ) > 0

BeginSql Alias cAliasTFF
	SELECT * FROM  %table:TFF% TFF
			WHERE TFF.TFF_FILIAL = %xFilial:TFF%
				AND TFF.TFF_CODPAI = %Exp:nCodLoc%
				AND TFF.%notDel%
EndSql

If (cAliasTFF)->(!Eof())

	aFields := oStru:GetFields()
	nLenFlds := Len(aFields)
	SX3->(DbSetOrder(2))
	While (cAliasTFF)->(!Eof())
		TFF->(DbGoTo((cAliasTFF)->R_E_C_N_O_))
		aAux := Array(nLenFlds)
		nTotGerRH := (cAliasTFF)->TFF_PRCVEN * (cAliasTFF)->TFF_QTDVEN
		cCodTFF	:= (cAliasTFF)->TFF_COD
		For nI := 1 To nLenFlds
			cField := aFields[nI, MODEL_FIELD_IDFIELD]
			If !aFields[nI, MODEL_FIELD_VIRTUAL]

				If aFields[nI, MODEL_FIELD_TIPO] $ 'C|N|L'
					aAux[nI] := (cAliasTFF)->&(cField)
				ElseIf aFields[nI, MODEL_FIELD_TIPO] == 'M'
					aAux[nI] := TFF->&(cField)
				ElseIf aFields[nI, MODEL_FIELD_TIPO] == 'D'
					aAux[nI] := STOD((cAliasTFF)->&(cField))
				EndIf
			Else
				If cField == "TFF_DESCRI"
					aAux[nI] := Posicione('SB1',1,xFilial('SB1')+(cAliasTFF)->TFF_PRODUT,'B1_DESC')
				ElseIf cField == "TFF_DFUNC
					aAux[nI] := Posicione('SRJ',1,xFilial('SRJ')+(cAliasTFF)->TFF_FUNCAO, 'RJ_DESC')
				ElseIf cField == "TFF_DTURNO"
					aAux[nI] := Posicione('SR6',1,xFilial('SR6')+(cAliasTFF)->TFF_TURNO, 'R6_DESC')
				ElseIf cField == "TFF_DCARGO"
					If !Empty((cAliasTFF)->TFF_CARGO)
						aAux[nI] := Posicione('SQ3',1,xFilial('SQ3')+(cAliasTFF)->TFF_CARGO, 'Q3_DESCSUM')
					Else
						aAux[nI] := ""
					EndIf
				ElseIf cField == "TFF_NOMESC"
					If !Empty((cAliasTFF)->TFF_ESCALA)
						aAux[nI] := Posicione('TDW',1,xFilial('TDW')+(cAliasTFF)->TFF_ESCALA, 'TDW_DESC')
					Else
						aAux[nI] := ""
					EndIf
				ElseIf cField == "TFF_DSCALE"
					If !Empty((cAliasTFF)->TFF_CALEND)
						aAux[nI] := Posicione('AC0',1,xFilial('AC0')+(cAliasTFF)->TFF_CALEND, 'AC0_DESC')
					Else
						aAux[nI] := ""
					EndIf
				ElseIf cField == 'TFF_LEGEN'
					If TFF->TFF_ENCE <> '1'
						aAux[nI] := "BR_VERDE"
					Else
						If FindFunction("TecEncDtFt") .AND. TecEncDtFt()
							If TFF->TFF_DTENCE > dDataBase
								aAux[nI] := "BR_VERDE"
							Else	
								aAux[nI] := "BR_CINZA"	
							EndIf
						Else
							aAux[nI] := "BR_CINZA"
						EndIf
					EndIf
				ElseIf cField == 'TFF_SUBTOT'
					aAux[nI] := nTotGerRH + ( nTotGerRH * ( (cAliasTFF)->TFF_LUCRO/100 ) ) + (cAliasTFF)->TFF_TXADM
				ElseIf cField == 'TFF_TOTAL'
					If lOrcPrc
						aAux[nI] :=  nTotGerRH + ( nTotGerRH * ( (cAliasTFF)->TFF_LUCRO/100 ) ) +  (cAliasTFF)->TFF_TXADM 
					Else
						BeginSql Alias cAliasTFH
							SELECT TFH.TFH_PRCVEN, TFH.TFH_QTDVEN FROM  %table:TFH% TFH
							WHERE TFH.TFH_FILIAL = %xFilial:TFH%
								AND TFH.TFH_CODPAI = %Exp:cCodTFF%
								AND TFH.TFH_COBCTR <> "2"
								AND TFH.%notDel%
						EndSql
						While (cAliasTFH)->(!Eof())
							nTotGerRH += (cAliasTFH)->TFH_PRCVEN * (cAliasTFH)->TFH_QTDVEN
							(cAliasTFH)->(DbSkip())
						EndDo
						(cAliasTFH)->(DbCloseArea())						
						BeginSql Alias cAliasTFG
							SELECT TFG.TFG_PRCVEN, TFG.TFG_QTDVEN FROM  %table:TFG% TFG
							WHERE TFG.TFG_FILIAL = %xFilial:TFG%
								AND TFG.TFG_CODPAI = %Exp:cCodTFF%
								AND TFG.TFG_COBCTR <> "2"
								AND TFG.%notDel%
						EndSql
						(cAliasTFG)->(DbCloseArea())
						aAux[nI] :=  nTotGerRH + ( nTotGerRH * ( (cAliasTFF)->TFF_LUCRO/100 ) ) + (cAliasTFF)->TFF_TXADM
						If lGsOrcUnif
							aAux[nI] += At740fTtUn("TFF",cCodTFF)
						Endif
						If lGsOrcArma
							aAux[nI] += At740fTtAr("TFF",cCodTFF)						
						Endif
					EndIf
				ElseIf cField == 'TFF_PROCES'
					aAux[nI] := .T.
				ElseIf cField == "TFF_DPLAN"
					aAux[nI] := Posicione("ABW", 1, xFilial("ABW")+(cAliasTFF)->TFF_PLACOD + (cAliasTFF)->TFF_PLAREV, "ABW_DESC")
				ElseIf cField == "TFF_LOADPRC"
					aAux[nI] := .F.
				Elseif cField == "TFF_TOTUNI"
					aAux[nI] := 0
					If lGsOrcUnif
						aAux[nI] += At740fTtUn("TFF",cCodTFF)
					Endif
				Elseif cField == "TFF_TOTARM"
					aAux[nI] := 0
					If lGsOrcArma
						aAux[nI] += At740fTtAr("TFF",cCodTFF)						
					Endif
				Elseif cField == "TFF_DSCCOB"
					aAux[nI] := ""
					If lTpCobr
						aAux[nI] += Posicione("SX5", 1, xFilial("SX5")+"GZ"+(cAliasTFF)->TFF_TPCOBR, "X5_DESCRI")
					Endif
				ElseIf SX3->(DbSeek(cField))
					aAux[nI] := CriaVar(cField, .T. )
				EndIf
			EndIf

		Next nI
		If oModel:GetOperation() == MODEL_OPERATION_INSERT
			Aadd(aRet,{0,aAux})
		Else
			Aadd(aRet,{(cAliasTFF)->R_E_C_N_O_,aAux})
		EndIf
		(cAliasTFF)->(DbSkip())
	EndDo
EndIf
RestArea(aAreaX3)
(cAliasTFF)->(DbCloseArea())

Return aRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} AtLoadTFL
	Load Data da grid de Locais (TFL)
@author		Matheus Lando Raimundo
@since		15/03/2019
@version	P12
/*/
//-------------------------------------------------------------------------------
Function AtLoadTFL(oMdl)
Local aRet := {}
Local cAliasTFL := GetNextAlias()
Local nLenFlds := 0
Local aAux := {}
Local oModel := oMdl:GetModel()
Local cCodOrc := TFJ->TFJ_CODIGO
Local oStru   := oMdl:GetStruct()
Local nI := 1
Local aFields := {}
Local aAreaX3 := SX3->(GetArea())
Local lGsOrcUnif := FindFunction("TecGsUnif") .And. TecGsUnif()
Local lGsOrcArma := FindFunction("TecGsArma") .And. TecGsArma()

SX3->(DbSetOrder(2))
BeginSql Alias cAliasTFL
	SELECT * FROM  %table:TFL% TFL
			WHERE TFL.TFL_FILIAL = %xFilial:TFL%
				AND TFL.TFL_CODPAI = %Exp:cCodOrc%
				AND TFL.%notDel%
EndSql

If (cAliasTFL)->(!Eof())
	aFields := oStru:GetFields()
	nLenFlds := Len(aFields)
	SX3->(DbSetOrder(2))

	While (cAliasTFL)->(!Eof())
		TFL->(DbGoTo((cAliasTFL)->R_E_C_N_O_))
		ABS->(DbSetOrder(1))
		ABS->(DbSeek(xFilial('ABS') + TFL->TFL_LOCAL))
		aAux := Array(nLenFlds)
		For nI := 1 To nLenFlds
			cField := aFields[nI, MODEL_FIELD_IDFIELD]
			If !aFields[nI, MODEL_FIELD_VIRTUAL]

				If aFields[nI, MODEL_FIELD_TIPO] $ 'C|N|L'
					aAux[nI] := (cAliasTFL)->&(cField)
				ElseIf aFields[nI, MODEL_FIELD_TIPO] == 'M'
					aAux[nI] := TFL->&(cField)
				ElseIf aFields[nI, MODEL_FIELD_TIPO] == 'D'
					aAux[nI] := STOD((cAliasTFL)->&(cField))
				EndIf
			Else
				If cField <> 'TFL_LEGEN'
					If cField == 'TFL_DESLOC'
						aAux[nI] := ABS->ABS_DESCRI
					ElseIf cField == 'TFL_TOTAL'
						aAux[nI] := TFL->TFL_TOTRH + TFL->TFL_TOTMI + TFL->TFL_TOTMC + TFL->TFL_TOTLE + TFL->TFL_TOTIMP
						If lGsOrcUnif
							aAux[nI] += At740fTtUn("TFL",TFL->TFL_CODIGO)
						Endif
						If lGsOrcArma
							aAux[nI] += At740fTtAr("TFL",TFL->TFL_CODIGO)						
						Endif
					ElseIf cField == 'TFL_DESLOC'
					 	 aAux[nI] := ABS->ABS_CODIGO
					ElseIf cField == 'TFL_ESTADO'
					 	 aAux[nI] := ABS->ABS_ESTADO
					ElseIf cField == 'TFL_MUNIC'
					 	 aAux[nI] := ABS->ABS_MUNIC
					ElseIf cField == 'TFL_MESIMP'
						aAux[nI] := 0
					Elseif cField == 'TFL_TOTUNI'
						aAux[nI] := 0
						If lGsOrcUnif
							aAux[nI] += At740fTtUn("TFL",TFL->TFL_CODIGO)
						Endif
					Elseif cField == 'TFL_TOTARM'
						aAux[nI] := 0
						If lGsOrcArma
							aAux[nI] += At740fTtAr("TFL",TFL->TFL_CODIGO)						
						Endif
					ElseIf SX3->(DbSeek(cField))
						aAux[nI] :=    CriaVar(cField, .T. )
					EndIf
				Else
					If TFL->TFL_ENCE <> '1'
						aAux[nI] := "BR_VERDE"
					Else
						If FindFunction("TecEncDtFt") .AND. TecEncDtFt()
							If TFL->TFL_DTENCE > dDataBase
								aAux[nI] := "BR_VERDE"
							Else
								aAux[nI] := "BR_CINZA"
							EndIf
						Else
							aAux[nI] := "BR_CINZA"
						EndIf
					EndIf
				EndIf
			EndIf

		Next nI

		If oModel:GetOperation() == MODEL_OPERATION_INSERT
			Aadd(aRet,{0,aAux})
		Else
			Aadd(aRet,{(cAliasTFL)->R_E_C_N_O_,aAux})
		EndIf

		(cAliasTFL)->(DbSkip())
	EndDo
EndIf
(cAliasTFL)->(DbCloseArea())
RestArea(aAreaX3)
Return aRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} AtLoadTFL
	Load Data da grid de MI (TFG)
@author		Matheus Lando Raimundo
@since		15/03/2019
@version	P12
/*/
//-------------------------------------------------------------------------------
Function AtLoadTFG(oMdl)
Local aRet := {}
Local aPosFlds := {}
Local cAliasTFG := GetNextAlias()
Local nLenFlds := 0
Local nX := 0
Local aAux := {}
Local oModel := oMdl:GetModel()
Local oMdlLoc := oModel:GetModel('TFL_LOC')
Local oMdlRH := oModel:GetModel('TFF_RH')
Local cCodPai := oMdlLoc:GetValue('TFL_CODIGO')
Local lOrcPrc := SuperGetMv("MV_ORCPRC",,.F.)
Local nTotMI  := 0
Local oStru   := oMdl:GetStruct()
Local nI := 1
Local aFields := {}
Local nTotGer := 0
Local aAreaX3 := SX3->(GetArea())

If lOrcPrc
	cCodPai := oMdlLoc:GetValue('TFL_CODIGO')
Else
	cCodPai := oMdlRH:GetValue('TFF_COD')
EndIf

BeginSql Alias cAliasTFG
	SELECT * FROM  %table:TFG% TFG
			WHERE TFG.TFG_FILIAL = %xFilial:TFG%
				AND TFG.TFG_CODPAI = %Exp:cCodPai%
				AND TFG.%notDel%
EndSql

If (cAliasTFG)->(!Eof())

	aFields := oStru:GetFields()
	nLenFlds := Len(aFields)
	SX3->(DbSetOrder(2))
	While (cAliasTFG)->(!Eof())
		aAux := Array(nLenFlds)
		TFG->(DbGoTo((cAliasTFG)->R_E_C_N_O_))
		nTotGer := 0

		For nI := 1 To nLenFlds

			cField := aFields[nI, MODEL_FIELD_IDFIELD]
			If !aFields[nI, MODEL_FIELD_VIRTUAL]

				If aFields[nI, MODEL_FIELD_TIPO] $ 'C|N|L'
					aAux[nI] := (cAliasTFG)->&(cField)
				ElseIf aFields[nI, MODEL_FIELD_TIPO] == 'M'
					aAux[nI] := TFG->&(cField)
				ElseIf aFields[nI, MODEL_FIELD_TIPO] == 'D'
					aAux[nI] := STOD((cAliasTFG)->&(cField))
				EndIf
			Else
				If SX3->(DbSeek(cField))
					If cField == 'TFG_SUBTOT'
						aAux[nI] := TFG->TFG_QTDVEN * TFG->TFG_PRCVEN
					ElseIf cField == 'TFG_TOTAL'
						aAux[nI] := (TFG->TFG_QTDVEN * TFG->TFG_PRCVEN) + TFG->TFG_TXLUCR + TFG->TFG_TXADM - TFG->TFG_VALDES
						If (cAliasTFG)->TFG_COBCTR <> "2"
							nTotMI += aAux[nI]
						EndIf
						nTotGer := aAux[nI]
					ElseIf cField == 'TFG_DESCRI'
						aAux[nI] := Posicione('SB1',1,xFilial('SB1')+(cAliasTFG)->TFG_PRODUT,'B1_DESC')
					ElseIf cField == 'TFG_TOTGER'
						aAux[nI] := (TFG->TFG_QTDVEN * TFG->TFG_PRCVEN) + TFG->TFG_TXLUCR + TFG->TFG_TXADM - TFG->TFG_VALDES
					Else
						aAux[nI] :=    CriaVar(cField, .T. )
					EndIf
				Else
					If cField == 'TFG_VLRMESMI'
						aAux[nI] := At740LDMes( STOD((cAliasTFG)->TFG_PERINI)  ,STOD((cAliasTFG)->TFG_PERFIM) ,nTotGer)
					EndIf
				EndIf
			EndIf

		Next nI

		If oModel:GetOperation() == MODEL_OPERATION_INSERT
			Aadd(aRet,{0,aAux})
		Else
			Aadd(aRet,{(cAliasTFG)->R_E_C_N_O_,aAux})
		EndIf
		(cAliasTFG)->(DbSkip())
	EndDo
	If !lOrcPrc .And. oModel:GetOperation() <> MODEL_OPERATION_DELETE
		oMdlRH:LoadValue('TFF_TOTMI',nTotMI)
		oModel:LoadValue("CALC_TFF","TOT_RHMI", oModel:GetValue("CALC_TFF","TOT_RHMI") + nTotMI)
	EndIf
EndIf
(cAliasTFG)->(DbCloseArea())
RestArea(aAreaX3)
Return aRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} AtLoadTFH
	Load Data da grid de MC (TFH)
@author		Matheus Lando Raimundo
@since		15/03/2019
@version	P12
/*/
//-------------------------------------------------------------------------------
Function AtLoadTFH(oMdl)
Local aRet := {}
Local aPosFlds := {}
Local cAliasTFH := GetNextAlias()
Local nLenFlds := 0
Local aAux := {}
Local oModel := oMdl:GetModel()
Local oMdlLoc := oModel:GetModel('TFL_LOC')
Local oMdlRH := oModel:GetModel('TFF_RH')
Local cCodPai := oMdlLoc:GetValue('TFL_CODIGO')
Local nTotGerRH := 0
Local nTotMC := 0
Local lOrcPrc := SuperGetMv("MV_ORCPRC",,.F.)
Local oStru   := oMdl:GetStruct()
Local nI := 1
Local aFields := {}
Local nTotGer := 0
Local aAreaX3 := SX3->(GetArea())

If lOrcPrc
	cCodPai := oMdlLoc:GetValue('TFL_CODIGO')
Else
	cCodPai := oMdlRH:GetValue('TFF_COD')
EndIf


BeginSql Alias cAliasTFH
	SELECT * FROM  %table:TFH% TFH
			WHERE TFH.TFH_FILIAL = %xFilial:TFH%
				AND TFH.TFH_CODPAI = %Exp:cCodPai%
				AND TFH.%notDel%
EndSql

If (cAliasTFH)->(!Eof())
	aFields := oStru:GetFields()
	nLenFlds := Len(aFields)
	SX3->(DbSetOrder(2))
	While (cAliasTFH)->(!Eof())
		aAux := Array(nLenFlds)
		TFH->(DbGoTo((cAliasTFH)->R_E_C_N_O_))
		nTotGer := 0
		For nI := 1 To nLenFlds
			cField := aFields[nI, MODEL_FIELD_IDFIELD]

			If !aFields[nI, MODEL_FIELD_VIRTUAL]
				If aFields[nI, MODEL_FIELD_TIPO] $ 'C|N|L'
					aAux[nI] := (cAliasTFH)->&(cField)
				ElseIf aFields[nI, MODEL_FIELD_TIPO] == 'M'
					aAux[nI] := TFH->&(cField)
				ElseIf aFields[nI, MODEL_FIELD_TIPO] == 'D'
					aAux[nI] := STOD((cAliasTFH)->&(cField))
				EndIf
			Else
				If SX3->(DbSeek(cField))
					aAux[nI] :=    CriaVar(cField, .T. )
					If cField == 'TFH_SUBTOT'
						aAux[nI] := TFH->TFH_QTDVEN * TFH->TFH_PRCVEN
					ElseIf cField == 'TFH_TOTAL'
						aAux[nI] := (TFH->TFH_QTDVEN * TFH->TFH_PRCVEN) +  TFH->TFH_TXLUCR + TFH->TFH_TXADM - TFH->TFH_VALDES
						If (cAliasTFH)->TFH_COBCTR <> "2"
							nTotMC += aAux[nI]
						EndIf
						nTotGer := aAux[nI]
					ElseIf cField == 'TFH_DESCRI'
						aAux[nI] := Posicione('SB1',1,xFilial('SB1')+(cAliasTFH)->TFH_PRODUT,'B1_DESC')
					ElseIf cField == 'TFH_TOTGER'
						aAux[nI] := (TFH->TFH_QTDVEN * TFH->TFH_PRCVEN) +  TFH->TFH_TXLUCR + TFH->TFH_TXADM - TFH->TFH_VALDES
					EndIf
				Else
					If cField == 'TFH_VLRMESMC'
						aAux[nI] := At740LDMes( STOD((cAliasTFH)->TFH_PERINI)  ,STOD((cAliasTFH)->TFH_PERFIM) ,nTotGer)
					EndIf
				EndIf

			EndIf

		Next nI

		If oModel:GetOperation() == MODEL_OPERATION_INSERT
			Aadd(aRet,{0,aAux})
		Else
			Aadd(aRet,{(cAliasTFH)->R_E_C_N_O_,aAux})
		EndIf
		(cAliasTFH)->(DbSkip())
	EndDo
	If !lOrcPrc .And. oModel:GetOperation() <> MODEL_OPERATION_DELETE
		oMdlRH:LoadValue('TFF_TOTMC',nTotMC)
		oModel:LoadValue("CALC_TFF","TOT_RHMC", oModel:GetValue("CALC_TFF","TOT_RHMC") + nTotMC)
	EndIf
EndIf
(cAliasTFH)->(DbCloseArea())
RestArea(aAreaX3)
Return aRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} AtLoadTFI
	Load Data da grid de LE (TFI)
@author		Matheus Lando Raimundo
@since		15/03/2019
@version	P12
/*/
//-------------------------------------------------------------------------------
Function AtLoadTFI(oMdl)
Local aRet := {}
Local aPosFlds := {}
Local cAliasTFI := GetNextAlias()
Local nLenFlds := 0
Local aAux := {}
Local oModel := oMdl:GetModel()
Local oMdlLoc := oModel:GetModel('TFL_LOC')
Local nCodLoc := oMdlLoc:GetValue('TFL_CODIGO')
Local nTotGerRH := 0
Local oStru   := oMdl:GetStruct()
Local nI := 1
Local aFields := {}
Local cField := ""
Local aAreaX3 := SX3->(GetArea())

BeginSql Alias cAliasTFI
		SELECT * FROM  %table:TFI% TFI
			WHERE TFI.TFI_FILIAL = %xFilial:TFI%
				AND TFI.TFI_CODPAI = %Exp:nCodLoc%
				AND TFI.%notDel%
	EndSql

If (cAliasTFI)->(!Eof())
	aFields := oStru:GetFields()
	nLenFlds := Len(aFields)
	SX3->(DbSetOrder(2))
	While (cAliasTFI)->(!Eof())
		aAux := Array(nLenFlds)
		TFI->(DbGoTo((cAliasTFI)->R_E_C_N_O_))

		For nI := 1 To nLenFlds
			cField := aFields[nI, MODEL_FIELD_IDFIELD]

			If !aFields[nI, MODEL_FIELD_VIRTUAL]
				If aFields[nI, MODEL_FIELD_TIPO] $ 'C|N|L'
					aAux[nI] := (cAliasTFI)->&(cField)
				ElseIf aFields[nI, MODEL_FIELD_TIPO] == 'M'
					aAux[nI] := TFI->&(cField)
				ElseIf aFields[nI, MODEL_FIELD_TIPO] == 'D'
					aAux[nI] := STOD((cAliasTFI)->&(cField))
				EndIf
			Else
				If SX3->(DbSeek(cField))

					If cField == 'TFI_NOMATD'
						aAux[nI] := ""
					ElseIf cField <> 'TFI_DESCRI' .And. cField <> 'TFI_UM'
						aAux[nI] :=    CriaVar(cField, .T. )
					ElseIf cField == 'TFI_DESCRI'
						aAux[nI] := Posicione('SB1',1,xFilial('SB1')+(cAliasTFI)->TFI_PRODUT,'B1_DESC')
					ElseIf cField == 'TFI_UM'
						aAux[nI] := Posicione('SB1',1,xFilial('SB1')+(cAliasTFI)->TFI_PRODUT,'B1_UM')
					Else
						aAux[nI] :=    CriaVar(cField, .T. )
					EndIf
				ElseIf cField == 'TFI_LEGEN'
					If (cAliasTFI)->TFI_ENCE <> '1'
						aAux[nI] := "BR_VERDE"
					Else
						aAux[nI] := "BR_CINZA"
					EndIf
				EndIf
			EndIf

		Next nI

		If oModel:GetOperation() == MODEL_OPERATION_INSERT
			Aadd(aRet,{0,aAux})
		Else
			Aadd(aRet,{(cAliasTFI)->R_E_C_N_O_,aAux})
		EndIf
		(cAliasTFI)->(DbSkip())
	EndDo
EndIf
(cAliasTFI)->(DbCloseArea())
RestArea(aAreaX3)
Return aRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740DscBe
	Carrega a descrição do Beneficio
@author		Matheus Lando Raimundo
@since		15/03/2019
@version	P12
/*/
//-------------------------------------------------------------------------------
Function At740DscBe()
Local cRet := ""
Local oModel := FwModelActive()

If ValType(oModel) == "O" .And. oModel:IsActive() .AND. oModel:GetOperation() == MODEL_OPERATION_INSERT
	cRet := ""
Else
	cRet := Posicione("SX5",1,xFilial("SX5")+"AZ"+ABP->ABP_BENEFI,"X5_DESCRI")
EndIf

Return cRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} AtLoadImp
	Load dos impostos
@author		Matheus Lando Raimundo
@since		15/03/2019
@version	P12
/*/
//-------------------------------------------------------------------------------
Function AtLoadImp(oMdl)
Local aRet := {}
Local aPosFlds := {}
Local nLenFlds := 0
Local nI := 0
Local nJ := 0
Local nX := 0
Local aAux := {}
Local oModel := oMdl:GetModel()
Local oMdlTFJ := oModel:GetModel('TFJ_REFER')
Local oMdlLoc := oModel:GetModel('TFL_LOC')
Local oMdlRh := oModel:GetModel('TFF_RH')
Local nCodLoc := oMdlLoc:GetValue('TFL_CODIGO')
Local nTotGerRH := 0
Local nPosNick := 0
Local cIDCampo := ""
Local cPicture := ""
Local uValor := Nil
Local oFwSht := Nil
Local cXMLPrc := ""
Local nLinLoc := oMdlLoc:GetLine()
Local nLinRH := oMdlRh:Getline()
Local lTFFXML := TFF->( ColumnPos('TFF_TABXML') ) > 0
Local nAba 	  := 0
Local cIdModel := oMdl:GetId()
Local nPos := 0
Local nLenFlds := 0

If !Empty(oMdlLoc:GetValue('TFL_LOCAL')) .and.!Empty(oMdlRh:GetValue('TFF_PRODUT'))
	If lTFFXML
		cXMLPrc := oMdlRh:GetValue('TFF_TABXML')
	Else
		oMdlRh:GoLine(oMdlRh:Length())
		cXMLPrc := At740FDXML(oMdlTFJ:GetValue('TFJ_TABXML'),oMdlLoc:GetValue('TFL_CODIGO'),oMdlRh:GetValue('TFF_COD'))
	EndIf

	oFwSht := FWUIWorkSheet():New(,.F. )
	oFwSht:LoadXmlModel(cXMLPrc)

	For nI := 1 To Len(aPrcOrc)
		If nI <> 2
			Loop
		EndIf
		For nJ	:= 1 To Len(aPrcOrc[nI][2])

			cIDCampo := AllTrim(aPrcOrc[nI][2][nJ][_TV7IDENT])
			nPosNick := AScan(oFwSht:OFWFORMULA:CELLS,{|o| o:NICKNAME == cIDCampo})
			If nPosNick > 0
				cPicture := oFwSht:OFWFORMULA:CELLS[nPosNick]:CPICTURE
				If aPrcOrc[nI][2][nJ][_TV7MODO] == '1'	// 1-Valor ; 2-Combo
					uValor := oFwSht:GetCellValue(cIDCampo)
					uValor := If( ValType(uValor) == 'C', Val(uValor), uValor )
				Else
					uValor := Transform(oFwSht:GetCellValue(cIDCampo), cPicture)
				EndIf
				Aadd(aAux, uValor)
			EndIf
		Next nJ
		Exit
	Next nI

	aAdd(aRet, aAux)
	aAdd(aRet, 0)

Else
	nLenFlds := Len(oMdl:GetStruct():GetFields())
	aAux := Array(nLenFlds)

	aAdd(aRet, aAux)
	aAdd(aRet, 0)
EndIf

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FPosR
Posicionamento nos resgistros do orçamento de serviços.

@since	26/06/2019
@author	Kaique Schiller
/*/
//------------------------------------------------------------------------------
Function At740FPosR(oVw)
Local aModelsId := {}
Local aEscolha	:= {}
Local nEscAba   := 0
Local nI		:= 0
Local lConExt 	:= IsInCallStack("At870GerOrc")
Local lTecItExtOp := IsInCallStack("At190dGrOrc") 

//View, SubModel, Descrição, Descrição da Aba
If !lConExt

	aModelsId := { {"VIEW_LOC"	,"TFL_LOC"	, STR0092, STR0022 },; //"Locais de Atendimento"
	 			   {"VIEW_RH"	,"TFF_RH"	, STR0093, STR0007 },; //"Recursos Humanos"
	 			   {"VIEW_LE"	,"TFI_LE"	, STR0094, STR0011 },; //"Locação de Equipamentos"
	 			   {"VIEW_MI"	,"TFG_MI"	, STR0095, STR0008 },; //"Materiais de Implantação"
	 			   {"VIEW_MC"	,"TFH_MC"	, STR0096, STR0009 },; //"Material de Consumo"
	 			   {"VIEW_BENEF","ABP_BENEF", STR0097, STR0026 },; //"Verbas Adicionais"
	 			   {"VIEW_HE"	,"TFU_HE"	, STR0098, STR0027 }}  //"Hora Extra"
Else
	If lTecItExtOp
		aModelsId := { 	{"VIEW_LOC"	,"TFL_LOC"	, STR0092, STR0022 },; //"Locais de Atendimento"
						{"VIEW_RH"	,"TFF_RH"	, STR0093, STR0007 }} //"Recursos Humanos"

	Else
		aModelsId := { 	{"VIEW_LOC"	,"TFL_LOC"	, STR0092, STR0022 },; //"Locais de Atendimento"
						{"VIEW_RH"	,"TFF_RH"	, STR0093, STR0007 },; //"Recursos Humanos"
						{"VIEW_MI"	,"TFG_MI"	, STR0095, STR0008 },; //"Materiais de Implantação"
						{"VIEW_MC"	,"TFH_MC"	, STR0096, STR0009 }} //"Material de Consumo"
	Endif
Endif

For nI := 1 To Len(aModelsId)
	Aadd(aEscolha , aModelsId[nI,3] )
Next nI

//Escolhe qual aba deseja posicionar
nEscAba := GSEscolha( 	STR0099,;  // "Posicione"
						STR0100,;  // "Selecione em qual grid deseja posicionar."
						aEscolha,;
						1)

//Se confirmou alguma aba
If nEscAba >  0
	MsgRun( STR0101, STR0102, { || At740FPosi(nEscAba,oVw,aModelsId,aEscolha)} ) //"Montando a pesquisa do posicione."#"Aguade..."
Endif

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740Posic
Monta a tela de posicionamento via parambox.

@since	26/06/2019
@author	Kaique Schiller
/*/
//------------------------------------------------------------------------------
Static Function At740FPosi(nEscAba,oVw,aModelsId,aEscolha)
Local oMdl	  		:= Nil
Local oMdlDtl 		:= Nil
Local oStruct		:= Nil
Local aPrBox  		:= {}
Local aRet	  		:= {}
Local aSeekLine 	:= {}
Local aCmpsSeek		:= {}
Local aRows    		:= {}
Local aStrVw		:= {}
Local aStrMdl 		:= {}
Local cPicture		:= ""
Local cIniPad 		:= ""
Local xConteud		:= ""
Local cConsult		:= ""
Local nTamCmp 		:= 0
Local nPos			:= 0
Local nX	  		:= 0 

If oVw <> Nil
	
	//Struct da view selecionada
	oStruVw := oVw:GetViewStruct(aModelsId[nEscAba,1]) 	

	//Modelo da view
	oMdl := oVw:GetModel()

	//Struct da model selecionada
	oMdlDtl := oMdl:GetModel(aModelsId[nEscAba,2])
		
	If oMdlDtl <> Nil
				
		//Struct do modelo
		oStruMdl := oMdlDtl:GetStruct()
		
		//Campos do modelo e da view		
		aStrMdl  := oStruMdl:GetFields()
		aStrVw	 := oStruVw:GetFields()

		//Percorre a estrutura para pegar os campos a serem exibidos no parambox
		For nX := 1 To Len(aStrVw)
	
			//Realiza o tratamento de alguns campos, e seleciona apenas os campos que aparecem na view.
			If !(aStrVw[nX,1] $ "TFL_LEGEN|TFF_LEGEN|TFI_LEGEN")

				nPos     := 0
				cIniPad  := ""
				cPicture := aStrVw[nX,7]
				cConsult := aStrVw[nX,9]

				nPos := Ascan(aStrMdl, {|x| x[3] == aStrVw[nX,1] })
				
				If nPos > 0 .And. !(aStrMdl[nPos,4] $ "M|L")
					If aStrMdl[nPos,4] == "D"
						cIniPad := cTod("")
					Else
						cIniPad := Space(aStrMdl[nPos,5])
					Endif

					If aStrMdl[nPos,4] $ "N|D|C"
						nTamCmp := 70		
					Else
						nTamCmp := aStrMdl[nPos,5]
					Endif
					
					//Monta os campos do parambox
					aAdd(aPrBox, { 1,aStrMdl[nPos,1],cIniPad,cPicture,,cConsult,,nTamCmp,.F.})
		
					//Armazena os campos do parambox para realizar o seekline
					aAdd(aCmpsSeek, { aStrMdl[nPos,3], aStrMdl[nPos,4] } )
				Endif
			Endif
		Next nX
	Endif
	
	//Se confirmar executa o seekline no modelo corrente.
	If !Empty(aPrBox) .And. ParamBox(aPrBox,STR0103+" - "+aModelsId[nEscAba,3],@aRet,,,,,,,,.F.) //Posicione
	
		For nX := 1 To Len(aRet)
	
			If !Empty(aRet[nX])
				
				If aCmpsSeek[nX,2] == "N"
					xConteud := Val(aRet[nX])
				Else
					xConteud := aRet[nX]
				Endif

				Aadd(aSeekLine, {aCmpsSeek[nX,1],xConteud} )

			Endif
			
		Next nX
		
		If !Empty(aSeekLine)

			If nEscAba == 1 .Or. nEscAba == 2 .Or. nEscAba == 3
				oVw:SelectFolder("ABAS", aModelsId[nEscAba,4],2) // "Aba superior"
			Endif

			If nEscAba == 4 .Or. nEscAba == 5
				
				//Se aba de materiais não estiver posicionado, realiza o posicionamento.
				If oVw:GetFolderActive("ABAS", 2)[2] <> STR0023
					oVw:SelectFolder("ABAS", STR0023, 2) // "Aba de Materiais"
				Endif

				oVw:SelectFolder("MT_ABAS", aModelsId[nEscAba,4],2) // "Aba inferior MC MI"

			Endif

			If nEscAba == 6 .Or. nEscAba ==  7
				
				//Se aba de recursos humanos não estiver posicionado, realiza o posicionamento.
				If oVw:GetFolderActive("ABAS", 2)[2] <> STR0007 
					oVw:SelectFolder("ABAS", STR0007, 2) // "Aba de Recursos Humanos"
				Endif

				oVw:SelectFolder("RH_ABAS", aModelsId[nEscAba,4],2) // "Aba inferior Extra e Beneficio"

			Endif
				
			If !oMdlDtl:SeekLine( aSeekLine )
				If !IsBlind()
					MsgAlert(STR0104) //"Não foi possível posicionar na linha, verifique as informações inseridas."
				Endif
			Endif
		Else
			If !IsBlind()
				MsgAlert(STR0105) //"Não foi possível posicionar na linha, preencha os campos do posicionamento."
			Endif
		Endif
	Endif
Endif

Return .T.


//------------------------------------------------------------------------------
/*/{Protheus.doc} TEC740FRFS
Realiza o refresh da view no setAfterActivate
@since	19/05/2020
@author	Diego Bezerra
/*/
//------------------------------------------------------------------------------
Static function TEC740FRFS(oView740F)

Default oView740F := Nil

If Valtype(oView740F) == 'O'
	oViw740F:Refresh( 'VIEW_MI' )
	oViw740F:Refresh( 'VIEW_MC' )
EndIf

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} initPlanFld
Executa o inicializador padrão da tabela de precificação
@since	02/12/2020
@param lNewLine, lógico, indica se o evento é inclusão de uma nova linha
@param xValInit, valor do inicializador da tabela de precificação
@param cFldName, nome do campo da tabela que está sendo atualizado
@author	Diego Bezerra
/*/
//------------------------------------------------------------------------------
Static function initPlanFld(oFldStruct,cFldName)

Local xRet 			:= ''
Local cIdModel 		:= oFldStruct:GetId()
Local nAba			:= Val(SubStr(cIdModel,Len(cIdModel),1))
Local nAbaImp		:= Iif(nAba == 0,aScan( aPrcOrc, { |x| x[1] == Replicate( " ", 30 ) } ),0)
Local nPosVlInit 	:= 0
Local nAbaPrc		:= 0
Local oModel 		:= FwModelActive()
Local oModelRH 		:= oModel:GetModel("TFF_RH")

If nAba > 0
	 nPosVlInit := aScan(aPrcOrc[nAba][2],{|x| x[2]== cFldName})
	 nAbaPrc := nAba
ElseIf nAbaImp > 0
	 nPosVlInit := aScan(aPrcOrc[nAbaImp][2],{|x| x[2]== cFldName})
	 nAbaPrc := nAbaImp
EndIf

IF Empty(oModelRH:GetValue("TFF_PRODUT"))
	If nPosVlInit > 0 
		xRet := Val(aPrcOrc[nAbaPrc][2][nPosVlInit][8])
	Else
		xRet := ""
	EndIf
EndIf

Return xRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetMdl740f
Retorna o modelo da TECA740F

@since	20/11/2020
@author	Luiz Gabriel
/*/
//------------------------------------------------------------------------------
function GetMdl740f()

Return oMdl740F

//------------------------------------------------------------------------------
/*/{Protheus.doc} initPlan935
Executa o inicializador padrão da tabela de precificação
@since	02/12/2020
@param lNewLine, lógico, indica se o evento é inclusão de uma nova linha
@param xValInit, valor do inicializador da tabela de precificação
@param cFldName, nome do campo da tabela que está sendo atualizado
@author	Diego Bezerra
/*/
//------------------------------------------------------------------------------
Static function initPlan935(lNewLine,xValInit,oFldStruct,cFldName)

Local xRet := ''
Local nPosFld := ASCAN(oFldStruct:OFORMMODELSTRUCT:AFIELDS,{|o| o[3] == cFldName } )
Local cFldType := ""

If nPosFld > 0 
	cFldType := oFldStruct:OFORMMODELSTRUCT:AFIELDS[nPosFld][4]
	If lNewLine
		Do Case 
			Case cFldType == 'N'
				xRet := VAL(xValInit)
			Case cFldType == 'C'
				xRet := xValInit
			OTHERWISE 
				xRet := xValInit
		ENDCASE
	EndIf
Else 
	xRet := ""
EndIf

Return xRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetStrutTa
@description Faz o retorno da tabela para ver se teve mudança na estrutura
@return oRet
@author Augusto Albuquerque
@since  18/08/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function GetStrutTa( cCodTFJ )
Local cQuery 	:= ""
Local cAliasTFF	:= GetNextAlias()
Local oRet		:= Nil

cQuery := ""
cQuery += " SELECT TFF.R_E_C_N_O_ RECNO "
cQuery += " FROM " + RetSqlName("TFF") + " TFF "
cQuery += " INNER JOIN " + RetSqlName("TFL") + " TFL "
cQuery += " ON TFL.TFL_CODIGO = TFF.TFF_CODPAI "
cQuery += " AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
cQuery += " AND TFL.TFL_CODPAI = '" + cCodTFJ + "' "
cQuery += " AND TFL.D_E_L_E_T_ = ' ' "
cQuery += " WHERE "
cQuery += " TFF.TFF_FILIAL = '"  + xFilial("TFL") + "' "
cQuery += " AND TFF.D_E_L_E_T_ = ' ' "
cQuery += " AND TFF.TFF_COBCTR <> '2' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTFF, .F., .T.)

If !((cAliasTFF)->(EOF()))
	TFF->(DbGoTo((cAliasTFF)->RECNO))
	oRet := FWUIWorkSheet():New(,.F. )
	oRet:LoadXmlModel(TFF->TFF_TABXML)
EndIf

(cAliasTFF)->(dbCloseArea())

Return oRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740Load
@description Carregamento da tabela de preço
@return Logico
@author Luiz Gabriel
@since  15/09/21
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At740Load( nOrigem )
Local oModel 	:= GetMdl740f()
Local oMdlRh 	:= oModel:GetModel("TFF_RH")
Local oMdlLoc 	:= oModel:GetModel("TFL_LOC") 
Local cTABXML 	:= oMdlRh:GetValue('TFF_TABXML')
Local nLinRH 	:= oMdlRh:Getline()
Local oFwSht 	:= FWUIWorkSheet():New(,.F. )
Local nI		:= 0
Local cView		:= ""
Local oView 	:= FwViewActive()

If !oMdlRh:GetValue("TFF_LOADPRC") .And. !oMdlRh:IsInserted()
	oFwSht:LoadXmlModel(cTABXML)

	AT740FCPY(oModel,oMdlLoc:GetLine(),nLinRH, oFwSht,.T.)

	For nI:=1 To Len(aPrcOrc)
		If Empty(AllTrim(aPrcOrc[nI][1]))
			Loop
		EndIf
		cView := aPrcOrc[nI][4][2]	// Indica o nome da view a ser criada
		If !isBlind() .AND. VALTYPE(oView) == 'O'
			oView:Refresh(cView)
		EndIf
	Next nI
	oMdlRh:GoLine(nLinRH)
	oMdlRh:LoadValue("TFF_LOADPRC",.T.)
ElseIf !oMdlRh:GetValue("TFF_LOADPRC") .And. oMdlRh:IsInserted()
	Help(,, "At740Load",,STR0114,1,0,,,,,,{STR0115}) //"Tabela de Preços não foi calculado"##"Clique em calcular para o carregamento correto da tabela de preço"
Else
	Help(,, "At740Load",,STR0116,1,0,,,,,,{STR0117}) //"Tabela de Preços já carregada"##"Selecione outra linha e carrega a tabela de preço"
EndIf

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740fTtUn
@description Calcula o total do grid de uniformes
@return nRet
@author Kaique Schiller
@since  21/06/22
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At740fTtUn(cTbl,cCod)
Local nRet := 0
Local cAliasTXP	 := GetNextAlias()
Default cTbl := ""
Default cCod := ""

If cTbl == "TFL"
	BeginSql Alias cAliasTXP
		SELECT TXP.TXP_PRCVEN, TXP.TXP_QTDVEN, TXP.TXP_TXLUCR, TXP.TXP_TXADM
		FROM  %table:TXP% TXP
		INNER JOIN %Table:TFF% TFF ON 
			TFF.TFF_FILIAL = %xFilial:TFF%
			AND TFF.TFF_COD = TXP.TXP_CODTFF
			AND TFF.%notDel%
		WHERE TXP.TXP_FILIAL = %xFilial:TXP%
			AND TFF.TFF_CODPAI = %Exp:cCod%
			AND TXP.%notDel%
	EndSql
ElseIf cTbl == "TFF"
	BeginSql Alias cAliasTXP
		SELECT TXP.TXP_PRCVEN, TXP.TXP_QTDVEN, TXP_TXLUCR, TXP_TXADM
		FROM  %table:TXP% TXP
		WHERE TXP.TXP_FILIAL = %xFilial:TXP%
			AND TXP.TXP_CODTFF = %Exp:cCod%
			AND TXP.%notDel%
	EndSql
Endif

While (cAliasTXP)->(!Eof())
	nRet += ((cAliasTXP)->TXP_QTDVEN * (cAliasTXP)->TXP_PRCVEN) +  (cAliasTXP)->TXP_TXLUCR + (cAliasTXP)->TXP_TXADM
	(cAliasTXP)->(DbSkip())
EndDo
(cAliasTXP)->(DbCloseArea())

Return nRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740fTtAr
@description Calcula o total do grid de armamentos
@return nRet
@author Kaique Schiller
@since  21/06/22
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At740fTtAr(cTbl,cCod)
Local nRet := 0
Local cAliasTXQ	 := GetNextAlias()
Default cTbl := ""
Default cCod := ""

If cTbl == "TFL"
	BeginSql Alias cAliasTXQ
		SELECT TXQ.TXQ_PRCVEN, TXQ.TXQ_QTDVEN, TXQ.TXQ_TXLUCR, TXQ.TXQ_TXADM
		FROM  %table:TXQ% TXQ
		INNER JOIN %Table:TFF% TFF ON 
			TFF.TFF_FILIAL = %xFilial:TFF%
			AND TFF.TFF_COD = TXQ.TXQ_CODTFF
			AND TFF.%notDel%
		WHERE TXQ.TXQ_FILIAL = %xFilial:TXQ%
			AND TFF.TFF_CODPAI = %Exp:cCod%
			AND TXQ.%notDel%
	EndSql
ElseIf cTbl == "TFF"
	BeginSql Alias cAliasTXQ
		SELECT TXQ.TXQ_PRCVEN, TXQ.TXQ_QTDVEN, TXQ_TXLUCR, TXQ_TXADM
		FROM  %table:TXQ% TXQ
		WHERE TXQ.TXQ_FILIAL = %xFilial:TXQ%
			AND TXQ.TXQ_CODTFF = %Exp:cCod%
			AND TXQ.%notDel%
	EndSql
Endif

While (cAliasTXQ)->(!Eof())
	nRet += ((cAliasTXQ)->TXQ_QTDVEN * (cAliasTXQ)->TXQ_PRCVEN) +  (cAliasTXQ)->TXQ_TXLUCR + (cAliasTXQ)->TXQ_TXADM
	(cAliasTXQ)->(DbSkip())
EndDo
(cAliasTXQ)->(DbCloseArea())

Return nRet
