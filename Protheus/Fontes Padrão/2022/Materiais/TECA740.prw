#INCLUDE 'TECA740.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOCACAO.CH'
#INCLUDE "FWEVENTVIEWCONSTS.CH"

STATIC oCharge		:= Nil
STATIC lDoCommit	:= .F.
STATIC cXmlDados	:= ''
STATIC cXmlCalculo	:= ''
STATIC aCancReserv	:= {}
STATIC nTLuc		:= 0
STATIC nTAdm		:= 0
STATIC nDeduc		:= 0
STATIC lCalcEnc		:= .T.
STATIC aObriga		:= {}
STATIC lTotLoc		:= .F.
STATIC lDelTWO		:= .F.
STATIC lUnDel		:= .F.
STATIC aPlanData 	:= {}
Static aRevPlaIten	:= {}
STATIC lImpToADZ 	:= .F.
STATIC lTEC740FUn 	:= .F.
STATIC lPutLeg		:= .F.
Static aEnceCpos	:= {}
STATIC lAlterTWO 	:= .F.
Static dPerCron		:= CtoD('')

/*
Array aEnceCpos - Este array é preenchido automáticamente sempre que um campo de um item encerrado é alterado.
Apenas campos que influênciam o valor do orçamento entram nesse array.
Para locação de equipamento, considera-se a grid da TEV

	aEnceCpos[x]
		[1] = Nome da tabela que o campo pertence
		[2] = Código único do campo (Exemplo: TFF_COD)
		[3] = Código único do pai do campo
		[4] = Nome do campo
		[5] = Valor do campo antes da primeira alteração
*/
//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA740
Nova interface para orçamento de serviços

@sample 	TECA740()
@since		20/08/2013
@version	P11
/*/
//------------------------------------------------------------------------------
Function TECA740()

Local oBrw := FwMBrowse():New()

oBrw:SetAlias( 'TFJ' )
oBrw:SetMenudef( 'TECA740' )
oBrw:SetDescription( OEmToAnsi( STR0001 ) ) //'Orçamento para Serviços'
If !(isBlind())
	oBrw:Activate()
Else
	oBrw := nil
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} Menudef
	Criacao do MenuDef.

@sample 	Menudef()
@param		Nenhum
@return	 	aMenu, Array, Opção para seleção no Menu
@since		20/00/2013
@version	P11
/*/
//------------------------------------------------------------------------------
Static Function Menudef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0	// "Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.TECA740' OPERATION 2 ACCESS 0	// "Visualizar"

Return (aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Definição do modelo de Dados

@since 10/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel := Nil
Local oMdlCalc := Nil
Local oStrTFJ := FWFormStruct(1,'TFJ')
Local oStrTFL := FWFormStruct(1,'TFL')
Local oStrTFF := FWFormStruct(1,'TFF')
Local oStrTFG := FWFormStruct(1,'TFG')
Local oStrTFH := FWFormStruct(1,'TFH')
Local oStrTFI := FWFormStruct(1,'TFI')
Local oStrTFU := FWFormStruct(1,'TFU')
Local oStrABP := FWFormStruct(1,'ABP')
Local oStrTEV := FWFormStruct(1,'TEV')
Local oStrTXQ 	 := Nil 
Local oStrTXP 	 := Nil 
Local xAux    := Nil
//referente fonte TECA741 - Habilidades, Características e Cursos para o item de RH
Local oStrTGV := FWFormStruct(1,'TGV')
Local oStrTDS := FWFormStruct(1,'TDS')
Local oStrTDT := FWFormStruct(1,'TDT')
//Referente aos intes do Facilitador
Local oStrTWO	:= FwFormStruct(1,'TWO')
Local nI		:= 1
Local aModelsId := {}
Local lVersion23	:= HasOrcSimp()
Local lTecItExtOp := IsInCallStack("At190dGrOrc") 
Local lGsOrcUnif := FindFunction("TecGsUnif") .And. TecGsUnif()
Local bFormTot	 := {|oModel| oModel:GetValue("TOTAIS","TOT_RH")+oModel:GetValue("TOTAIS","TOT_MI")+oModel:GetValue("TOTAIS","TOT_MC")+oModel:GetValue("TOTAIS","TOT_LE")}
Local bFormTotEn := {|oModel| oModel:GetValue("CALC_TFL_NE","TOT_RH_EN")+oModel:GetValue("CALC_TFL_NE","TOT_MI_EN")+oModel:GetValue("CALC_TFL_NE","TOT_MC_EN")+oModel:GetValue("CALC_TFL_NE","TOT_LE_EN") - nDeduc}
Local lGsOrcArma := FindFunction("TecGsArma") .And. TecGsArma()

If lGsOrcUnif
	oStrTXP := FWFormStruct(1,'TXP')
Endif

If lGsOrcArma
	oStrTXQ := FWFormStruct(1,'TXQ')
Endif

lPutLeg := A740PutLeg()
nDeduc := 0
lCalcEnc := .T.
//------------------------------------------------------------
//  Não cria os gatilhos para não interferir nos totalizadores e gerar valores de cobrança por fora
// combinados a cobrança dentro do contrato
//------------------------------------------------------------
If !IsInCallStack("At870GerOrc")
	xAux := FwStruTrigger( 'TFG_TOTGER', 'TFG_TOTGER', 'At740TrgGer( "CALC_TFG", "TOT_MI", "TFF_RH", "TFF_TOTMI" )', .F. )
		oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFH_TOTGER', 'TFH_TOTGER', 'At740TrgGer( "CALC_TFH", "TOT_MC", "TFF_RH", "TFF_TOTMC" )', .F. )
		oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_SUBTOT', 'TFF_SUBTOT', 'At740TrgGer( "CALC_TFF", "TOT_RH", "TFL_LOC", "TFL_TOTRH" )', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_TOTMI', 'TFF_TOTMI', 'At740TrgGer( "CALC_TFF", "TOT_RHMI", "TFL_LOC", "TFL_TOTMI" )', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_TOTMC', 'TFF_TOTMC', 'At740TrgGer( "CALC_TFF", "TOT_RHMC", "TFL_LOC", "TFL_TOTMC" )', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TEV_VLTOT', 'TEV_VLTOT', 'At740TrgGer( "CALC_TEV", "TOT_ADICIO", "TFI_LE", "TFI_TOTAL", "TFI_DESCON" )', .F. )
		oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFI_TOTAL', 'TFI_TOTAL', 'At740TrgGer( "CALC_TFI", "TOT_LE", "TFL_LOC", "TFL_TOTLE" )', .F. )
		oStrTFI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
EndIf
If TecABBPRHR()
	If IsInCallStack('At870Revis')
		xAux := FwStruTrigger( 'TFF_QTDVEN', 'TFF_QTDHRS', 'At740QTDHr( .T. )', .F. )
			oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	EndIf
	xAux := FwStruTrigger( 'TFF_QTDHRS', 'TFF_HRSSAL', 'At740Horas()', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
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
//------------------------------------------------------------
//  Não cria os gatilhos para não interferir nos totalizadores e gerar valores de cobrança por fora
// combinados a cobrança dentro do contrato
//------------------------------------------------------------
If !IsInCallStack("At870GerOrc")
	xAux := FwStruTrigger( 'TFF_SUBTOT', 'TFF_TOTAL', 'At740InPad()',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_TOTMI', 'TFF_TOTAL', 'At740InPad()',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_TOTMC', 'TFF_TOTAL', 'At740InPad()',.F.)
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

xAux := FwStruTrigger( 'TEV_MODCOB', 'TEV_QTDE', 'At740TEVQt()',.F.,/*Alias*/,/*Ordem*/,/*Chave*/,"M->TEV_MODCOB=='2'")
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
// Gatilhos - Recursos Humano
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
If TecVlPrPar()
	xAux := FwStruTrigger( 'TFF_ADM', 'TFF_VLPRPA', 'At740PrxPa("TFF") ',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_LUCRO', 'TFF_VLPRPA', 'At740PrxPa("TFF") ',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStrutrigger( 'TFF_VLPRPA', 'TFF_VLPRPA', 'At740AtTpr()',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
EndIf
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
If TecVlPrPar()
	xAux := FwStruTrigger( 'TFG_ADM', 'TFG_VLPRPA', 'At740PrxPa("TFG") ',.F.)
		oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFG_LUCRO', 'TFG_VLPRPA', 'At740PrxPa("TFG") ',.F.)
		oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStrutrigger( 'TFG_VLPRPA', 'TFG_VLPRPA', 'At740AtTpr()',.F.)
		oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
EndIf
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
If TecVlPrPar()
	xAux := FwStruTrigger( 'TFH_ADM', 'TFH_VLPRPA', 'At740PrxPa("TFH") ',.F.)
		oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFH_LUCRO', 'TFH_VLPRPA', 'At740PrxPa("TFH") ',.F.)
		oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStrutrigger( 'TFH_VLPRPA', 'TFH_VLPRPA', 'At740AtTpr()',.F.)
		oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
EndIf
//-----------------------------------------------------------------------------------------
// Descrição do calendario
//-----------------------------------------------------------------------------------------
xAux := FwStruTrigger('TFF_CALEND','TFF_DSCALE','ALLTRIM( POSICIONE("AC0",1,XFILIAL("AC0")+M->TFF_CALEND,"AC0_DESC") )',.F.,Nil,Nil,Nil)
oStrTFF:AddTrigger(xAux[1],xAux[2],xAux[3],xAux[4])
//-----------------------------------------------------------------------------------------
// Descrição da escala
//-----------------------------------------------------------------------------------------
xAux := FwStruTrigger('TFF_ESCALA','TFF_NOMESC','ALLTRIM( POSICIONE("TDW",1,XFILIAL("TDW")+M->TFF_ESCALA,"TDW_DESC") )',.F.,Nil,Nil,Nil)
oStrTFF:AddTrigger(xAux[1],xAux[2],xAux[3],xAux[4])
//------------------------------------------------------------------------------------------
// Gatilhos - Caracteristicas
//------------------------------------------------------------------------------------------
xAux := FwStrutrigger( 'TDS_CODTCZ', 'TDS_DSCTCZ', 'At740TDS()',.F.)
	oStrTDS:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
//------------------------------------------------------------------------------------------
// Gatilhos - Habilidades
//------------------------------------------------------------------------------------------
xAux := FwStrutrigger( 'TDT_CODHAB', 'TDT_DSCHAB', 'At740TDT("1")',.F.)
	oStrTDT:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TDT_ESCALA', 'TDT_DSCESC', 'At740TDT("2")',.F.)
	oStrTDT:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TDT_ITESCA', 'TDT_DSCITE', 'At740TDT("3")',.F.)
	oStrTDT:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TDT_HABX5' , 'TDT_DHABX5', 'At740TDT("4")',.F.)
	oStrTDT:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
//------------------------------------------------------------------------------------------
// Gatilhos - Cursos
//------------------------------------------------------------------------------------------
xAux := FwStrutrigger( 'TGV_CURSO', 'TGV_DCURSO', 'At740TGV()',.F.)
	oStrTGV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
//-----------------------------------------------------------------------------------------
// gatilho para preencher os percentuais de lucro e tx adm quando inserido produto na linha
//-----------------------------------------------------------------------------------------
xAux := FwStruTrigger( 'TFF_PRODUT', 'TFF_LUCRO', 'At740LuTxA("TFJ_LUCRO")')
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFF_PRODUT', 'TFF_ADM', 'At740LuTxA("TFJ_ADM")')
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

If (TFF->(ColumnPos('TFF_QTPREV')) > 0)
	xAux := FwStruTrigger( 'TFF_QTDVEN', 'TFF_QTPREV', 'AtCalcPrev()')
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_TURNO', 'TFF_QTPREV', 'AtCalcPrev()')
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_ESCALA', 'TFF_QTPREV','AtCalcPrev()')
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	If (TFF->(ColumnPos('TFF_GERVAG')) > 0)
		xAux := FwStruTrigger( 'TFF_GERVAG', 'TFF_QTPREV','AtCalcPrev()')
			oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])		
	Endif		
	
EndIf		
//-----------------------------------------------------------------

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

If lGsOrcUnif
	xAux := FwStruTrigger('TXP_CODUNI','TXP_DSCUNI','AllTrim( Posicione("SB1", 1, xFilial("SB1")+FwFldGet("TXP_CODUNI"), "B1_DESC") )',.F.)
		oStrTXP:AddTrigger(xAux[1],xAux[2],xAux[3],xAux[4])
	xAux := FwStrutrigger( 'TXP_QTDVEN', 'TXP_TOTAL', 'FwFldGet("TXP_QTDVEN")*FwFldGet("TXP_PRCVEN")',.F.)
		oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXP_PRCVEN', 'TXP_TOTAL', 'FwFldGet("TXP_QTDVEN")*FwFldGet("TXP_PRCVEN")',.F.)
		oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXP_LUCRO', 'TXP_TXLUCR', 'At740MatAc("1","TXPDETAIL","TXP")',.F.)
		oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXP_LUCRO', 'TXP_TOTGER', 'At740VlTot("TXPDETAIL","TXP")',.F.)
		oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXP_TOTAL', 'TXP_TOTGER', 'At740VlTot("TXPDETAIL","TXP")',.F.)
		oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXP_PRCVEN', 'TXP_TOTGER', 'At740VlTot("TXPDETAIL","TXP")',.F.)
		oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXP_QTDVEN', 'TXP_TOTGER', 'At740VlTot("TXPDETAIL","TXP")',.F.)
		oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXP_ADM', 'TXP_TXADM', 'At740MatAc("2","TXPDETAIL","TXP")',.F.)
		oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXP_ADM', 'TXP_TOTGER', 'At740VlTot("TXPDETAIL","TXP")',.F.)
		oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXP_TOTGER', 'TXP_TXLUCR', 'At740MatAc("1","TXPDETAIL","TXP")',.F.)
		oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXP_TOTGER', 'TXP_TXADM', 'At740MatAc("2","TXPDETAIL","TXP")',.F.)
		oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TXP_TOTGER', 'TXP_TOTGER', 'At740TrgGer( "CALC_TXP", "TOT_TXP", "TFF_RH", "TFF_TOTUNI" )', .F. )
		oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_TOTUNI', 'TFF_TOTAL', 'At740InPad()',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_TOTUNI', 'TFF_TOTUNI', 'At740TrgGer( "CALC_TFF", "TOT_RHUNI", "TFL_LOC", "TFL_TOTUNI" )', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	
	xAux := FwStruTrigger( 'TFL_TOTLE', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTUNI")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTMC', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTUNI")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTMI', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTUNI")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTRH', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTUNI")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTUNI', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTUNI")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFL_TOTUNI', 'TFL_TOTUNI', 'At740TrgGer( "TOTAIS", "TOT_TXP", "TFJ_REFER", "TFJ_TOTUNI" )', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	oStrTXP:SetProperty('TXP_TOTGER',MODEL_FIELD_INIT,{|| ATINIPADMVC("TECA740","TXPDETAIL",'TXP_TOTGER',,,,'TXP->(TXP_QTDVEN*TXP_PRCVEN)+(TXP->(TXP_QTDVEN*TXP_PRCVEN)*(TXP->TXP_LUCRO/100))+(TXP->(TXP_QTDVEN*TXP_PRCVEN)*(TXP->TXP_ADM/100))') } )

	bFormTot :=  {|oModel| oModel:GetValue("TOTAIS","TOT_RH")+oModel:GetValue("TOTAIS","TOT_MI")+oModel:GetValue("TOTAIS","TOT_MC")+oModel:GetValue("TOTAIS","TOT_LE")+oModel:GetValue("TOTAIS","TOT_TXP")}
	bFormTotEn := {|oModel| oModel:GetValue("CALC_TFL_NE","TOT_RH_EN")+oModel:GetValue("CALC_TFL_NE","TOT_MI_EN")+oModel:GetValue("CALC_TFL_NE","TOT_MC_EN")+oModel:GetValue("CALC_TFL_NE","TOT_LE_EN")+oModel:GetValue("CALC_TFL_NE","TOT_TXP_EN") - nDeduc}	

Endif

If lGsOrcArma
	xAux := FwStruTrigger('TXQ_ITEARM','TXQ_CODPRD','',.F.)
		oStrTXQ:AddTrigger(xAux[1],xAux[2],xAux[3],xAux[4])
	xAux := FwStruTrigger('TXQ_ITEARM','TXQ_DSCPRD','',.F.)
		oStrTXQ:AddTrigger(xAux[1],xAux[2],xAux[3],xAux[4])
	xAux := FwStruTrigger('TXQ_CODPRD','TXQ_DSCPRD','AllTrim( Posicione("SB1", 1, xFilial("SB1")+FwFldGet("TXQ_CODPRD"), "B1_DESC") )',.F.)
		oStrTXQ:AddTrigger(xAux[1],xAux[2],xAux[3],xAux[4])
	xAux := FwStrutrigger( 'TXQ_QTDVEN', 'TXQ_TOTAL', 'FwFldGet("TXQ_QTDVEN")*FwFldGet("TXQ_PRCVEN")',.F.)
		oStrTXQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXQ_PRCVEN', 'TXQ_TOTAL', 'FwFldGet("TXQ_QTDVEN")*FwFldGet("TXQ_PRCVEN")',.F.)
		oStrTXQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXQ_LUCRO', 'TXQ_TXLUCR', 'At740MatAc("1","TXQDETAIL","TXQ")',.F.)
		oStrTXQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXQ_LUCRO', 'TXQ_TOTGER', 'At740VlTot("TXQDETAIL","TXQ")',.F.)
		oStrTXQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXQ_TOTAL', 'TXQ_TOTGER', 'At740VlTot("TXQDETAIL","TXQ")',.F.)
		oStrTXQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXQ_PRCVEN', 'TXQ_TOTGER', 'At740VlTot("TXQDETAIL","TXQ")',.F.)
		oStrTXQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXQ_QTDVEN', 'TXQ_TOTGER', 'At740VlTot("TXQDETAIL","TXQ")',.F.)
		oStrTXQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXQ_ADM', 'TXQ_TXADM', 'At740MatAc("2","TXQDETAIL","TXQ")',.F.)
		oStrTXQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXQ_ADM', 'TXQ_TOTGER', 'At740VlTot("TXQDETAIL","TXQ")',.F.)
		oStrTXQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXQ_TOTGER', 'TXQ_TXLUCR', 'At740MatAc("1","TXQDETAIL","TXQ")',.F.)
		oStrTXQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXQ_TOTGER', 'TXQ_TXADM', 'At740MatAc("2","TXQDETAIL","TXQ")',.F.)
		oStrTXQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TXQ_TOTGER', 'TXQ_TOTGER', 'At740TrgGer( "CALC_TXQ", "TOT_TXQ", "TFF_RH", "TFF_TOTARM" )', .F. )
		oStrTXQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_TOTARM', 'TFF_TOTAL', 'At740InPad()',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_TOTARM', 'TFF_TOTARM', 'At740TrgGer( "CALC_TFF", "TOT_RHARM", "TFL_LOC", "TFL_TOTARM" )', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFL_TOTLE', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTARM")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTMC', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTARM")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTMI', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTARM")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTRH', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTARM")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTARM', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTARM")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFL_TOTARM', 'TFL_TOTARM', 'At740TrgGer( "TOTAIS", "TOT_TXQ", "TFJ_REFER", "TFJ_TOTARM" )', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	oStrTXQ:SetProperty('TXQ_TOTGER',MODEL_FIELD_INIT,{|| ATINIPADMVC("TECA740","TXQDETAIL",'TXQ_TOTGER',,,,'TXQ->(TXQ_QTDVEN*TXQ_PRCVEN)+(TXQ->(TXQ_QTDVEN*TXQ_PRCVEN)*(TXQ->TXQ_LUCRO/100))+(TXQ->(TXQ_QTDVEN*TXQ_PRCVEN)*(TXQ->TXQ_ADM/100))') } )

	bFormTot :=  {|oModel| oModel:GetValue("TOTAIS","TOT_RH")+oModel:GetValue("TOTAIS","TOT_MI")+oModel:GetValue("TOTAIS","TOT_MC")+oModel:GetValue("TOTAIS","TOT_LE")+oModel:GetValue("TOTAIS","TOT_TXQ")}
	bFormTotEn := {|oModel| oModel:GetValue("CALC_TFL_NE","TOT_RH_EN")+oModel:GetValue("CALC_TFL_NE","TOT_MI_EN")+oModel:GetValue("CALC_TFL_NE","TOT_MC_EN")+oModel:GetValue("CALC_TFL_NE","TOT_LE_EN")+oModel:GetValue("CALC_TFL_NE","TOT_TXQ_EN") - nDeduc}

Endif

If lGsOrcArma .And. lGsOrcUnif
	xAux := FwStruTrigger( 'TFL_TOTLE', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTARM")+FwFldGet("TFL_TOTUNI")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTMC', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTARM")+FwFldGet("TFL_TOTUNI")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTMI', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTARM")+FwFldGet("TFL_TOTUNI")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTRH', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTARM")+FwFldGet("TFL_TOTUNI")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTARM', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTARM")+FwFldGet("TFL_TOTUNI")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTUNI', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTUNI")+FwFldGet("TFL_TOTARM")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	bFormTot :=  {|oModel| oModel:GetValue("TOTAIS","TOT_RH")+oModel:GetValue("TOTAIS","TOT_MI")+oModel:GetValue("TOTAIS","TOT_MC")+oModel:GetValue("TOTAIS","TOT_LE")+oModel:GetValue("TOTAIS","TOT_TXP")+oModel:GetValue("TOTAIS","TOT_TXQ")}
	bFormTotEn := {|oModel| oModel:GetValue("CALC_TFL_NE","TOT_RH_EN")+oModel:GetValue("CALC_TFL_NE","TOT_MI_EN")+oModel:GetValue("CALC_TFL_NE","TOT_MC_EN")+oModel:GetValue("CALC_TFL_NE","TOT_LE_EN")+oModel:GetValue("CALC_TFL_NE","TOT_TXP_EN")+oModel:GetValue("CALC_TFL_NE","TOT_TXQ_EN") - nDeduc}

Endif

If TFF->( ColumnPos('TFF_TOTPLA') ) > 0 .And. TFF->( ColumnPos('TFF_GERPLA') ) > 0 ;
  .And. TFJ->( ColumnPos('TFJ_GERPLA') ) > 0  .And. TFL->( ColumnPos('TFL_GERPLA') ) > 0 

	xAux := FwStruTrigger( 'TFF_TOTPLA', 'TFF_GERPLA', 'FwFldGet("TFF_QTDVEN")*FwFldGet("TFF_TOTPLA")',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_QTDVEN', 'TFF_GERPLA', 'FwFldGet("TFF_QTDVEN")*FwFldGet("TFF_TOTPLA")',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_GERPLA', 'TFF_GERPLA', 'At984aGtTt("TFF_RH","TFF_GERPLA","TFL_LOC","TFL_GERPLA")', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_GERPLA', 'TFL_GERPLA', 'At984aGtTt("TFL_LOC","TFL_GERPLA","TFJ_REFER","TFJ_GERPLA")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
Endif

If TFF->( ColumnPos('TFF_TPCOBR') ) > 0
	xAux := FwStruTrigger( 'TFF_TPCOBR', 'TFF_DSCCOB', 'AllTrim( Posicione("SX5", 1, xFilial("SX5")+"GZ"+FwFldGet("TFF_TPCOBR"), "X5_DESCRI") )', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
Endif

If TFF->( ColumnPos('TFF_TPCOBR') ) > 0 .And. TFF->( ColumnPos('TFF_QTDTIP') ) > 0 .And.;
	TFF->( ColumnPos('TFF_VLRPRP') ) > 0 .And.  TFF->( ColumnPos('TFF_VLRCOB') ) > 0
	
	xAux := FwStruTrigger( 'TFF_PRCVEN', 'TFF_VLRPRP', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_TOTAL"),FwFldGet("TFF_QTDTIP"),FwFldGet("TFF_VLRPRP"),"TFF_VLRPRP",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_PRCVEN', 'TFF_VLRCOB', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_TOTAL"),FwFldGet("TFF_QTDTIP"),FwFldGet("TFF_VLRPRP"),"TFF_VLRCOB",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_ESCALA', 'TFF_VLRPRP', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_TOTAL"),FwFldGet("TFF_QTDTIP"),FwFldGet("TFF_VLRPRP"),"TFF_VLRPRP",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_ESCALA', 'TFF_VLRCOB', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_TOTAL"),FwFldGet("TFF_QTDTIP"),FwFldGet("TFF_VLRPRP"),"TFF_VLRCOB",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_TURNO', 'TFF_VLRPRP', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_TOTAL"),FwFldGet("TFF_QTDTIP"),FwFldGet("TFF_VLRPRP"),"TFF_VLRPRP",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_TURNO', 'TFF_VLRCOB', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_TOTAL"),FwFldGet("TFF_QTDTIP"),FwFldGet("TFF_VLRPRP"),"TFF_VLRCOB",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_TPCOBR', 'TFF_QTDTIP', '0', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_TPCOBR', 'TFF_VLRPRP', '0', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_TPCOBR', 'TFF_VLRCOB', '0', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_TPCOBR', 'TFF_VLRPRP', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_TOTAL"),FwFldGet("TFF_QTDTIP"),FwFldGet("TFF_VLRPRP"),"TFF_VLRPRP",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_TPCOBR', 'TFF_VLRCOB', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_TOTAL"),FwFldGet("TFF_QTDTIP"),FwFldGet("TFF_VLRPRP"),"TFF_VLRCOB",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_QTDTIP', 'TFF_VLRPRP', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_TOTAL"),FwFldGet("TFF_QTDTIP"),FwFldGet("TFF_VLRPRP"),"TFF_VLRPRP",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_QTDTIP', 'TFF_VLRCOB', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_TOTAL"),FwFldGet("TFF_QTDTIP"),FwFldGet("TFF_VLRPRP"),"TFF_VLRCOB",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
		
	If TFF->( ColumnPos('TFF_GERPLA') ) > 0
		xAux := FwStruTrigger( 'TFF_GERPLA', 'TFF_VLRPRP', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_TOTAL"),FwFldGet("TFF_QTDTIP"),FwFldGet("TFF_VLRPRP"),"TFF_VLRPRP",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
			oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

		xAux := FwStruTrigger( 'TFF_GERPLA', 'TFF_VLRCOB', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_TOTAL"),FwFldGet("TFF_QTDTIP"),FwFldGet("TFF_VLRPRP"),"TFF_VLRCOB",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
			oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	Endif

Endif
oStrTFL:SetProperty( "TFL_CODPAI", MODEL_FIELD_OBRIGAT, .F. )
oStrTFF:SetProperty( "TFF_CODPAI", MODEL_FIELD_OBRIGAT, .F. )
oStrTFF:SetProperty( "TFF_LOCAL", MODEL_FIELD_OBRIGAT, .F. )
oStrTFF:SetProperty( "TFF_COBCTR", MODEL_FIELD_WHEN, { || .F.} )
oStrTFG:SetProperty( "TFG_CODPAI", MODEL_FIELD_OBRIGAT, .F. )
oStrTFG:SetProperty( "TFG_LOCAL", MODEL_FIELD_OBRIGAT, .F. )
oStrTFG:SetProperty( "TFG_COBCTR", MODEL_FIELD_WHEN, { || .F. } )
oStrTFH:SetProperty( "TFH_CODPAI", MODEL_FIELD_OBRIGAT, .F. )
oStrTFH:SetProperty( "TFH_LOCAL", MODEL_FIELD_OBRIGAT, .F. )
oStrTFH:SetProperty( "TFH_COBCTR", MODEL_FIELD_WHEN, { || .F. } )
oStrTFI:SetProperty( "TFI_CODPAI", MODEL_FIELD_OBRIGAT, .F. )
oStrTFI:SetProperty( "TFI_LOCAL", MODEL_FIELD_OBRIGAT, .F. )
oStrTFI:SetProperty( "TFI_TOTAL", MODEL_FIELD_OBRIGAT, .F. )
oStrTFU:SetProperty( "TFU_CODTFF", MODEL_FIELD_OBRIGAT, .F. )
oStrTFU:SetProperty( "TFU_LOCAL" , MODEL_FIELD_OBRIGAT, .F. )
oStrTFU:SetProperty( "TFU_VALOR", MODEL_FIELD_OBRIGAT, .F. )
oStrTDS:SetProperty( "TDS_CODTFF", MODEL_FIELD_OBRIGAT, .F. )
oStrTDT:SetProperty( "TDT_CODTFF", MODEL_FIELD_OBRIGAT, .F. )
oStrTGV:SetProperty( "TGV_CODTFF", MODEL_FIELD_OBRIGAT, .F. )
oStrTGV:SetProperty( "TGV_CODTFF", MODEL_FIELD_INIT,{|oMdl| oMdl:GetModel():GetModel("TFF_RH"):GetValue("TFF_COD") } )
oStrTDS:SetProperty( "TDS_CODTFF", MODEL_FIELD_INIT,{|oMdl| oMdl:GetModel():GetModel("TFF_RH"):GetValue("TFF_COD") } )
oStrTDT:SetProperty( "TDT_CODTFF", MODEL_FIELD_INIT,{|oMdl| oMdl:GetModel():GetModel("TFF_RH"):GetValue("TFF_COD") } )

If isInCallStack("At870GerOrc")
	oStrTFF:SetProperty( "TFF_COBCTR", MODEL_FIELD_INIT, {||"2"} )
	oStrTFG:SetProperty( "TFG_COBCTR", MODEL_FIELD_INIT, {||"2"} )
	oStrTFH:SetProperty( "TFH_COBCTR", MODEL_FIELD_INIT, {||"2"} )
EndIf

If TFJ->( ColumnPos('TFJ_DTPLRV') ) > 0 .AND. !isInCallStack("AT870PlaRe")
	oStrTFJ:SetProperty( "TFJ_DTPLRV", MODEL_FIELD_OBRIGAT, .F. )
	If isInCallStack("AplicaRevi")
		oStrTFJ:SetProperty( "TFJ_DTPLRV", MODEL_FIELD_WHEN, {|| .F. } )
	EndIf
EndIf

If TFL->( ColumnPos('TFL_MODPLA') ) > 0 .AND. (isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi")) 
	oStrTFL:SetProperty( "TFL_MODPLA", MODEL_FIELD_INIT, {||"1"} )
EndIf

If TFF->( ColumnPos('TFF_MODPLA') ) > 0 .AND. (isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") )
	oStrTFF:SetProperty( "TFF_MODPLA", MODEL_FIELD_INIT, {||"1"} )
EndIf

If TFG->( ColumnPos('TFG_MODPLA') ) > 0 .AND. (isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") )
	oStrTFG:SetProperty( "TFG_MODPLA", MODEL_FIELD_INIT, {||"1"} )
EndIf

If TFH->( ColumnPos('TFH_MODPLA') ) > 0 .AND. (isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") )
	oStrTFH:SetProperty( "TFH_MODPLA", MODEL_FIELD_INIT, {||"1"} )
EndIf

If TFU->( ColumnPos('TFU_MODPLA') ) > 0 .AND. (isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") )
	oStrTFU:SetProperty( "TFU_MODPLA", MODEL_FIELD_INIT, {||"1"} )
EndIf

IF lTecItExtOp
	oStrTFF:SetProperty( "TFF_ITEXOP", MODEL_FIELD_INIT, {||"1"} )
Endif
oStrABP:SetProperty( "ABP_ITRH"  , MODEL_FIELD_OBRIGAT, .F. )
oStrTEV:SetProperty( "TEV_CODLOC", MODEL_FIELD_OBRIGAT, .F. )

oStrTFH:SetProperty('TFH_PERINI',MODEL_FIELD_VALID,{|oMdlVld|At740VldDt("TFH_MC","TFH_PERINI","TFH_PERINI","TFH_PERFIM")})
oStrTFH:SetProperty('TFH_PERFIM',MODEL_FIELD_VALID,{|oMdlVld|At740VldDt("TFH_MC","TFH_PERFIM","TFH_PERINI","TFH_PERFIM")})

oStrTFG:SetProperty('TFG_PERINI',MODEL_FIELD_VALID,{|oMdlVld|At740VldDt("TFG_MI","TFG_PERINI","TFG_PERINI","TFG_PERFIM")})
oStrTFG:SetProperty('TFG_PERFIM',MODEL_FIELD_VALID,{|oMdlVld|At740VldDt("TFG_MI","TFG_PERFIM","TFG_PERINI","TFG_PERFIM")})

oStrTFF:SetProperty('TFF_PERINI',MODEL_FIELD_VALID,{|oMdlVld|At740VldDt("TFF_RH","TFF_PERINI","TFF_PERINI","TFF_PERFIM")})
oStrTFF:SetProperty('TFF_PERFIM',MODEL_FIELD_VALID,{|oMdlVld|At740VldDt("TFF_RH","TFF_PERFIM","TFF_PERINI","TFF_PERFIM")})

oStrTFI:SetProperty('TFI_PERINI',MODEL_FIELD_VALID, {|oMdlVld,cCampo,xValueNew,nLine,xValueOld|;
				At740VldDt("TFI_LE","TFI_PERINI","TFI_PERINI","TFI_PERFIM") .And. ;  // valida o período selecionado
				At740Reserv(oMdlVld,cCampo,xValueNew,nLine,xValueOld) } )  // verifica se há reserva de equipamento
oStrTFI:SetProperty('TFI_PERFIM',MODEL_FIELD_VALID, {|oMdlVld,cCampo,xValueNew,nLine,xValueOld|;
				At740VldDt("TFI_LE","TFI_PERFIM","TFI_PERINI","TFI_PERFIM") .And. ;  // valida o período selecionado
				At740Reserv(oMdlVld,cCampo,xValueNew,nLine,xValueOld) } )  // verifica se há reserva de equipamento
oStrTFI:SetProperty('TFI_QTDVEN',MODEL_FIELD_VALID, {|oMdlVld,cCampo,xValueNew,nLine,xValueOld|;
				xValueNew >= 0 .And. ;
				At740Reserv(oMdlVld,cCampo,xValueNew,nLine,xValueOld) } )

oStrTFL:SetProperty('TFL_DTFIM',MODEL_FIELD_VALID,{|oModel,cCampo,xValueNew,nLine,xValueOld|At740VlVig(oModel,cCampo,xValueNew,nLine,xValueOld)})

oStrTFL:SetProperty('TFL_DTINI',MODEL_FIELD_VALID,{|oModel,cCampo,xValueNew,nLine,xValueOld|At740VlVig(oModel,cCampo,xValueNew,nLine,xValueOld)})

oStrTFF:SetProperty('TFF_PRCVEN',MODEL_FIELD_OBRIGAT,.F.)

If TecABBPRHR()
	oStrTFF:SetProperty('TFF_HRSSAL',MODEL_FIELD_WHEN, {|| .F. })
EndIf

//Adiciona valid na revisão do contrato e no item extra
If TecBHasGvg() .And. (IsInCallStack("At870Revis") .Or. isInCallStack("At870GerOrc"))
	oStrTFF:SetProperty('TFF_GERVAG',MODEL_FIELD_VALID,{|oModel|At740VldVg(oModel)})
EndIf

oStrTFF:SetProperty('TFF_PRCVEN',MODEL_FIELD_WHEN ,{|oModel|At740BlTot(oModel)})
oStrTFF:SetProperty('TFF_PRCVEN',MODEL_FIELD_VALID,{|oModel|At740VlVlr("TFF_RH","TFF_PRCVEN",oModel)})

oStrABP:SetProperty('ABP_DESCRI',MODEL_FIELD_INIT,{|| At740DscBe()} )
oStrABP:SetProperty('ABP_TPVERB',MODEL_FIELD_INIT,{|| At740ConvTp( ATINIPADMVC("TECA740","ABP_BENEF","RV_TIPO","SRV",1, "xFilial('SRV')+ABP->ABP_VERBA") ) } )

oStrTFG:SetProperty('TFG_PRCVEN',MODEL_FIELD_OBRIGAT,.F.)
oStrTFG:SetProperty('TFG_PRCVEN',MODEL_FIELD_VALID,{|oModel|At740VlVlr("TFG_MI","TFG_PRCVEN",oModel)})
oStrTFG:SetProperty('TFG_TOTGER',MODEL_FIELD_INIT,{|| ATINIPADMVC("TECA740","TFG_MI",'TFG_TOTGER',,,,'TFG->(TFG_QTDVEN*TFG_PRCVEN)+(TFG->(TFG_QTDVEN*TFG_PRCVEN)*(TFG->TFG_LUCRO/100))+(TFG->(TFG_QTDVEN*TFG_PRCVEN)*(TFG->TFG_ADM/100))') } )

oStrTFH:SetProperty('TFH_PRCVEN',MODEL_FIELD_OBRIGAT,.F.)
oStrTFH:SetProperty('TFH_PRCVEN',MODEL_FIELD_VALID,{|oModel|At740VlVlr("TFH_MC","TFH_PRCVEN",oModel)})
oStrTFH:SetProperty('TFH_TOTGER',MODEL_FIELD_INIT,{|| ATINIPADMVC("TECA740","TFH_MC",'TFH_TOTGER',,,,'TFH->(TFH_QTDVEN*TFH_PRCVEN)+(TFH->(TFH_QTDVEN*TFH_PRCVEN)*(TFH->TFH_LUCRO/100))+(TFH->(TFH_QTDVEN*TFH_PRCVEN)*(TFH->TFH_ADM/100))') } )

oStrTEV:SetProperty('TEV_UM',MODEL_FIELD_WHEN,{|| IsInCallStack('RunTrigger') .Or. FwFldGet('TEV_MODCOB') <> '2' } )
oStrTEV:SetProperty('TEV_VLTOT',MODEL_FIELD_INIT,{|| ATINIPADMVC("TECA740", "TEV_ADICIO", "TEV_VLTOT",,,,'TEV->(TEV_VLRUNI*TEV_QTDE)+TEV->(TEV_TXADM+TEV_TXLUCR)')} )

If SuperGetMv("MV_GSITORC",,"2") == "1" .And. FindFunction("TecGsPrecf") .And. TecGsPrecf() .And. FindFunction("Tec984AImp")
	oStrTWO:SetProperty('TWO_CODFAC', MODEL_FIELD_VALID, {|a,b,c,d,e| FWInitCpo(a,b,c,d),lValFac := Vazio() .Or. ExistCpo('TXR',Alltrim(c),1) ,FWCloseCpo(a,b,c,lValFac,.T.),lValFac})
	oStrTWO:SetProperty('TWO_QUANT', MODEL_FIELD_VALID, {|a,b,c,d,e| FWInitCpo(a,b,c,d),lValFac := Positivo() ,FWCloseCpo(a,b,c,lValFac,.T.),lValFac})
	xAux := FwStruTrigger( 'TWO_CODFAC', 'TWO_DESCRI', 'At174TXR()', .F. )
	oStrTWO:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
Else
	oStrTWO:SetProperty('TWO_CODFAC', MODEL_FIELD_VALID, {|a,b,c,d,e| FWInitCpo(a,b,c,d),lValFac := Vazio() .Or. ExistCpo("TWM"),FWCloseCpo(a,b,c,lValFac,.T.),lValFac})
EndIf
oModel := MPFormModel():New('TECA740',,{|oModel| At740TdOk(oModel) },{|oModel| At740Cmt( oModel ) }, {|a,b,c,d| At740Canc( a,b,c,d ) } )
oModel:SetDescription( STR0001 ) // 'Orçamento para Serviços'

oModel:addFields('TFJ_REFER',,oStrTFJ)

If lVersion23
	oModel:SetPrimaryKey({"TFJ_FILIAL","TFJ_CODIGO"})
EndIf

oModel:addGrid('TFL_LOC','TFJ_REFER', oStrTFL, {|oMdlG,nLine,cAcao,cCampo, xValue, xOldValue| PreLinTFL(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue) }, , Nil, Nil, {|oModel|AtLoadTFL(oModel)})

oModel:SetRelation('TFL_LOC', { { 'TFL_FILIAL', 'xFilial("TFJ")' }, { 'TFL_CODPAI', 'TFJ_CODIGO' } }, TFL->(IndexKey(1)) )

If lVersion23
	oModel:GetModel("TFJ_REFER"):SetFldNoCopy( { 'TFJ_CODVIS' } )
EndIf

oModel:addGrid('TFF_RH','TFL_LOC',oStrTFF, {|oMdlG,nLine,cAcao,cCampo, xValue, xOldValue| PreLinTFF(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue) },;
{|oMdlG,nLine,cAcao,cCampo| PosLinTFF(oMdlG, nLine, cAcao, cCampo)},Nil, Nil, {|oModel|AtLoadTFF(oModel)})

oModel:SetRelation('TFF_RH', { { 'TFF_FILIAL', 'xFilial("TFF")' }, { 'TFF_CODPAI', 'TFL_CODIGO' }, { 'TFF_LOCAL', 'TFL_LOCAL' } }, TFF->(IndexKey(1)) )

oModel:addGrid('ABP_BENEF','TFF_RH',oStrABP, {|oMdlG,nLine,cAcao,cCampo| PreLinABP(oMdlG, nLine, cAcao, cCampo) } )
oModel:SetRelation('ABP_BENEF', { { 'ABP_FILIAL', 'xFilial("ABP")' }, { 'ABP_ITRH', 'TFF_COD' }, {'ABP_COD','TFJ_PROPOS'} }, ABP->(IndexKey(1)) )
oModel:GetModel( 'ABP_BENEF' ):SetUniqueLine( { 'ABP_BENEFI' } )

oModel:addGrid('TFG_MI','TFF_RH',oStrTFG, {|oMdlG,nLine,cAcao,cCampo, xValue, xOldValue| PreLinTFG(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue) },{|oMdlG,nLine,cAcao,cCampo| PosLinTFG(oMdlG, nLine, cAcao, cCampo)};
,Nil, Nil, {|oModel|AtLoadTFG(oModel)})
oModel:SetRelation('TFG_MI', { { 'TFG_FILIAL', 'xFilial("TFG")' }, { 'TFG_CODPAI', 'TFF_COD' }, { 'TFG_LOCAL', 'TFL_LOCAL' } }, TFG->(IndexKey(1)) )

oModel:addGrid('TFH_MC','TFF_RH',oStrTFH, {|oMdlG,nLine,cAcao,cCampo, xValue, xOldValue| PreLinTFH(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue) },{|oMdlG,nLine,cAcao,cCampo| PosLinTFH(oMdlG, nLine, cAcao, cCampo)};
 ,Nil, Nil, {|oModel|AtLoadTFH(oModel)})


oModel:SetRelation('TFH_MC', { { 'TFH_FILIAL', 'xFilial("TFH")' }, { 'TFH_CODPAI', 'TFF_COD' }, { 'TFH_LOCAL', 'TFL_LOCAL' } }, TFH->(IndexKey(1)) )

oModel:addGrid('TFU_HE','TFF_RH',oStrTFU,  {|oMdlG,nLine,cAcao,cCampo, xValue, xOldValue| PreLinTFU(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue) }, {|oMdlG,nLine,cAcao,cCampo| PosLinTFU(oMdlG, nLine, cAcao, cCampo)} )
oModel:SetRelation('TFU_HE', { { 'TFU_FILIAL', 'xFilial("TFU")' }, { 'TFU_CODTFF', 'TFF_COD' }, { 'TFU_LOCAL', 'TFL_LOCAL' } }, TFU->(IndexKey(1)) )

oModel:addGrid('TFI_LE','TFL_LOC',oStrTFI, {|oMdlG,nLine,cAcao,cCampo| PreLinTFI(oMdlG, nLine, cAcao, cCampo) },{|oMdlG,nLine,cAcao,cCampo| PosLinTFI(oMdlG, nLine, cAcao, cCampo)},;
	Nil,Nil,{|oModel|AtLoadTFI(oModel)} )
oModel:SetRelation('TFI_LE', { { 'TFI_FILIAL', 'xFilial("TFI")' }, { 'TFI_CODPAI', 'TFL_CODIGO' }, { 'TFI_LOCAL', 'TFL_LOCAL' } }, TFI->(IndexKey(1)) )

oModel:addGrid('TEV_ADICIO','TFI_LE',oStrTEV, {|oMdlG,nLine,cAcao,cCampo,xValue,xOldValue| PreLinTEV(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue) } )
oModel:SetRelation('TEV_ADICIO', { { 'TEV_FILIAL', 'xFilial("TEV")' }, { 'TEV_CODLOC', 'TFI_COD' } }, TEV->(IndexKey(1)) )
oModel:GetModel( 'TEV_ADICIO' ):SetUniqueLine( { 'TEV_MODCOB' } )

//referente fonte TECA741 - Habilidades, Características e Cursos para o item de RH
oModel:AddGrid( "TGV_RH", "TFF_RH", oStrTGV,/*bLinePre*/,/*bLinePos*/,/*bPreVal*/ ,/*bPosVal*/ , /*bLoad*/)
oModel:SetRelation('TGV_RH', { { 'TGV_FILIAL', 'xFilial("TGV")' }, { 'TGV_CODTFF', 'TFF_COD' } }, TGV->(IndexKey(1)) )
oModel:GetModel( 'TGV_RH' ):SetUniqueLine( { 'TGV_CODTFF','TGV_CURSO' } )

oModel:AddGrid( "TDS_RH", "TFF_RH", oStrTDS,/*bLinePre*/,/*bLinePos*/,/*bPreVal*/ ,/*bPosVal*/ , /*bLoad*/)
oModel:SetRelation('TDS_RH', { { 'TDS_FILIAL', 'xFilial("TDS")' }, { 'TDS_CODTFF', 'TFF_COD' } }, TDS->(IndexKey(1)) )
oModel:GetModel( 'TDS_RH' ):SetUniqueLine( { 'TDS_CODTFF','TDS_CODTCZ' } )

oModel:AddGrid( "TDT_RH", "TFF_RH", oStrTDT,/*bLinePre*/,/*bLinePos*/,/*bPreVal*/ ,/*bPosVal*/ , /*bLoad*/)
oModel:SetRelation('TDT_RH', { { 'TDT_FILIAL', 'xFilial("TDT")' }, { 'TDT_CODTFF', 'TFF_COD' } }, TDT->(IndexKey(1)) )

oModel:AddGrid( "TWODETAIL", "TFL_LOC", oStrTWO, {|oModelGrid,  nLine,cAction,  cField, xValue, xOldValue|A740LoadFa(oModelGrid, nLine, cAction, cField, xValue, xOldValue)}/*bLinePre*/,/*bLinePos*/,/*bPreVal*/ ,/*bPosVal*/ , /*bLoad*/)
oModel:SetRelation('TWODETAIL', { { 'TWO_FILIAL', 'xFilial("TWO")' }, {'TWO_CODORC', 'TFJ_CODIGO'}, {'TWO_PROPOS', 'TFJ_PROPOS'}, {'TWO_LOCAL','TFL_CODIGO'} }, TWO->(IndexKey(1)) )

If lGsOrcUnif
	oModel:addGrid('TXPDETAIL','TFF_RH',oStrTXP, {|oMdlG,nLine,cAction| PreLinTXP(oMdlG,nLine,cAction)},{|oMdlG,nLine| PosLinTXP(oMdlG, nLine)},Nil, Nil, {|oModel|AtLoadTXP(oModel)} )
	oModel:SetRelation('TXPDETAIL', { { 'TXP_FILIAL', 'xFilial("TXP")' }, { 'TXP_CODTFF', 'TFF_COD' } }, TXP->(IndexKey(1)) )
Endif

If lGsOrcArma
	oModel:addGrid('TXQDETAIL','TFF_RH',oStrTXQ, {|oMdlG,nLine,cAction| PreLinTXQ(oMdlG,nLine,cAction)},{|oMdlG,nLine| PosLinTXQ(oMdlG, nLine)},Nil, Nil, {|oModel|AtLoadTXQ(oModel)})
	oModel:SetRelation('TXQDETAIL', { { 'TXQ_FILIAL', 'xFilial("TXQ")' }, { 'TXQ_CODTFF', 'TFF_COD' } }, TXQ->(IndexKey(1)) )
Endif

If ExistBlock("a740GrdM")
	For nI := 1 To Len(oModel:GetAllSubModels())
		Aadd(aModelsId, {oModel:aAllSubModels[nI]:GetId(), oModel:aAllSubModels[nI]:GetDescription()})
	Next nI
	ExecBlock("a740GrdM",.F.,.F.,{oModel,aModelsId})
EndIf

oModel:getModel('TFJ_REFER'):SetDescription(STR0004)	// 'Ref. Proposta'
oModel:getModel('TFL_LOC'):SetDescription(STR0005)		// 'Locais'
oModel:getModel('TFF_RH'):SetDescription(STR0006)		// 'Recursos Humanos'
oModel:getModel('TFG_MI'):SetDescription(STR0007)		// 'Materiais de Implantação'
oModel:getModel('TFH_MC'):SetDescription(STR0008)		// 'Material de Consumo'
oModel:getModel('TFU_HE'):SetDescription(STR0031)		// 'Hora Extra'
oModel:getModel('TFI_LE'):SetDescription(STR0009)		// 'Locação de Equipamentos'
oModel:getModel('ABP_BENEF'):SetDescription(STR0010)	// 'Beneficios'
oModel:getModel('TEV_ADICIO'):SetDescription(STR0011)	// 'Cobrança da Locação'
oModel:getModel('TGV_RH'):SetDescription(STR0072)		// 'Cursos'
oModel:getModel('TDS_RH'):SetDescription(STR0073)		// 'Habilidades'
oModel:getModel('TDT_RH'):SetDescription(STR0074)		// 'Caracteristicas'
oModel:getModel('TWODETAIL'):SetDescription(STR0096)	// 'Facilitador'

oModel:getModel('TEV_ADICIO'):SetOptional(.T.)
oModel:getModel('TFI_LE'):SetOptional(.T.)
oModel:getModel('TFH_MC'):SetOptional(.T.)
oModel:getModel('TFG_MI'):SetOptional(.T.)
oModel:getModel('TFU_HE'):SetOptional(.T.)
oModel:getModel('ABP_BENEF'):SetOptional(.T.)
oModel:getModel('TFF_RH'):SetOptional(.T.)
oModel:getModel('TGV_RH'):SetOptional(.T.) //ref. fonte TECA741 - Cursos
oModel:getModel('TDS_RH'):SetOptional(.T.) //ref. fonte TECA741 - Características
oModel:getModel('TDT_RH'):SetOptional(.T.) //ref. fonte TECA741 - Habilidades
oModel:getModel('TWODETAIL'):SetOptional(.T.) //Facilitador

If lGsOrcUnif
	oModel:getModel('TXPDETAIL'):SetDescription(STR0326)	// 'Uniforme'
	oModel:getModel('TXPDETAIL'):SetOptional(.T.) //Uniformes
Endif
If lGsOrcArma
	oModel:getModel('TXQDETAIL'):SetDescription(STR0331) // "Armamento"
	oModel:getModel('TXQDETAIL'):SetOptional(.T.) //Uniformes
Endif

oModel:AddCalc( 'CALC_TFI', 'TFL_LOC', 'TFI_LE', 'TFI_TOTAL' , 'TOT_LE', 'SUM',/*bCondition*/, /*bInitValue*/, STR0012 /*cTitle*/, /*bFormula*/) // 'Tot. Loc. Equipamento'
oModel:AddCalc( 'CALC_TFF', 'TFL_LOC', 'TFF_RH', 'TFF_SUBTOT', 'TOT_RH', 'SUM',{|oModel| oModel:GetValue( "TFF_RH", "TFF_COBCTR" ) <> "2" }/*bCondition*/, /*bInitValue*/,STR0013 /*cTitle*/, /*bFormula*/)  // 'Tot. Rec. Humanos'
oModel:AddCalc( 'CALC_TFF', 'TFL_LOC', 'TFF_RH', 'TFF_TOTMI' , 'TOT_RHMI', 'SUM',/*bCondition*/, /*bInitValue*/,STR0014 /*cTitle*/, /*bFormula*/)  // 'Tot. Mat. Implantação'
oModel:AddCalc( 'CALC_TFF', 'TFL_LOC', 'TFF_RH', 'TFF_TOTMC' , 'TOT_RHMC', 'SUM',/*bCondition*/, /*bInitValue*/,STR0015 /*cTitle*/, /*bFormula*/)  // 'Tot. Mat. Consumo'
If lGsOrcUnif
	oModel:AddCalc( 'CALC_TFF'	 , 'TFL_LOC'	, 'TFF_RH'	 	, 'TFF_TOTUNI', 'TOT_RHUNI'	, 'SUM', /*bCondition*/, /*bInitValue*/,"Tot. Uniforme" /*cTitle*/, /*bFormula*/)  // "Tot. Uniforme"
Endif
If lGsOrcArma
	oModel:AddCalc( 'CALC_TFF'	 , 'TFL_LOC'	, 'TFF_RH'	 	, 'TFF_TOTARM', 'TOT_RHARM'	, 'SUM', /*bCondition*/, /*bInitValue*/,"Tot. Armamento" /*cTitle*/, /*bFormula*/)  // "Tot. Armamento"
Endif

oModel:AddCalc( 'CALC_TFG', 'TFF_RH', 'TFG_MI'	 , 'TFG_TOTGER', 'TOT_MI', 'SUM', {|oModel| oModel:GetValue( "TFG_MI", "TFG_COBCTR" ) <> "2" }/*bCondition*/, /*bInitValue*/,STR0014 /*cTitle*/, /*bFormula*/)  // 'Tot. Mat. Implantação'
oModel:AddCalc( 'CALC_TFH', 'TFF_RH', 'TFH_MC'	 , 'TFH_TOTGER', 'TOT_MC', 'SUM', {|oModel| oModel:GetValue( "TFH_MC", "TFH_COBCTR" ) <> "2" }/*bCondition*/, /*bInitValue*/,STR0015 /*cTitle*/, /*bFormula*/)  // 'Tot. Mat. Consumo'
If lGsOrcUnif
	oModel:AddCalc( 'CALC_TXP'	 , 'TFF_RH'		, 'TXPDETAIL'	, 'TXP_TOTGER', 'TOT_TXP'	, 'SUM', /*bCondition*/, /*bInitValue*/,"Tot. Uniforme" /*cTitle*/, /*bFormula*/)  // "Tot. Uniforme"
Endif
If lGsOrcArma
	oModel:AddCalc( 'CALC_TXQ'	 , 'TFF_RH'		, 'TXQDETAIL'	, 'TXQ_TOTGER', 'TOT_TXQ'	, 'SUM', /*bCondition*/, /*bInitValue*/,"Tot. Armamento" /*cTitle*/, /*bFormula*/)  // "Tot. Armamento"
Endif

oModel:AddCalc( 'CALC_TEV', 'TFI_LE', 'TEV_ADICIO', 'TEV_VLTOT', 'TOT_ADICIO', 'SUM', {|oMdl| At740WhCob( oMdl) }/*bCondition*/, /*bInitValue*/,STR0016 /*cTitle*/, /*bFormula*/)  // 'Tot. Cobrança Loc. Equip.'
oModel:AddCalc( 'CALC_TFL', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTRH', 'TOT_RH', 'SUM',/*bCondition*/, /*bInitValue*/,STR0017 /*cTitle*/, /*bFormula*/)  // 'Geral RH'
oModel:AddCalc( 'CALC_TFL', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTMI', 'TOT_MI', 'SUM', /*bCondition*/, /*bInitValue*/,STR0018 /*cTitle*/, /*bFormula*/)  // 'Geral MI'
oModel:AddCalc( 'CALC_TFL', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTMC', 'TOT_MC', 'SUM', /*bCondition*/, /*bInitValue*/,STR0019 /*cTitle*/, /*bFormula*/)  // 'Geral MC'
oModel:AddCalc( 'CALC_TFL', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTLE', 'TOT_LE', 'SUM', /*bCondition*/, /*bInitValue*/,STR0020 /*cTitle*/, /*bFormula*/)  // 'Geral LE'
If lGsOrcUnif
	oModel:AddCalc( 'CALC_TFL'	 , 'TFJ_REFER' 	, 'TFL_LOC'	 	, 'TFL_TOTUNI', 'TOT_TXP'	, 'SUM', /*bCondition*/, /*bInitValue*/,"Geral Uniforme" /*cTitle*/, /*bFormula*/)  // 'Geral Uniforme'
Endif
If lGsOrcArma
	oModel:AddCalc( 'CALC_TFL'	 , 'TFJ_REFER' 	, 'TFL_LOC'	 	, 'TFL_TOTARM', 'TOT_TXQ'	, 'SUM', /*bCondition*/, /*bInitValue*/,"Geral Armamento" /*cTitle*/, /*bFormula*/)  // "Geral Armamento"
Endif

oModel:AddCalc( 'CALC_TFL', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTAL', 'TOT_GERAL', 'SUM', /*bCondition*/, /*bInitValue*/,STR0021 /*cTitle*/, /*bFormula*/) // 'Geral Proposta'

oModel:AddCalc( 'CALC_TFL_NE', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTRH', 'TOT_RH_EN', 'SUM',{|oMdl|TC740VLCL(oMdl,"TOT_RH", @nDeduc,'TECA740')},,STR0258) // "Tot.RH Real"
oModel:AddCalc( 'CALC_TFL_NE', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTMI', 'TOT_MI_EN', 'SUM',{|oMdl|TC740VLCL(oMdl,"TOT_MI")},, STR0259) //"Tot.MI Real"
oModel:AddCalc( 'CALC_TFL_NE', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTMC', 'TOT_MC_EN', 'SUM',{|oMdl|TC740VLCL(oMdl,"TOT_MC")},, STR0260) //"Tot.MC Real"
oModel:AddCalc( 'CALC_TFL_NE', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTLE', 'TOT_LE_EN', 'SUM',{|oMdl|TC740VLCL(oMdl,"TOT_LE", @nDeduc,'TECA740')},, STR0261) //"Tot.LE Real"
If lGsOrcUnif
	oModel:AddCalc( 'CALC_TFL_NE', 'TFJ_REFER'	, 'TFL_LOC'		, 'TFL_TOTUNI', 'TOT_TXP_EN', 'SUM',/*{|oMdl|TC740VLCL(oMdl,"TOT_TXP", @nDeduc,'TECA740')}*/,, "Tot.Uni. Real") //"Tot.LE Real"
Endif
If lGsOrcArma
	oModel:AddCalc( 'CALC_TFL_NE', 'TFJ_REFER'	, 'TFL_LOC'		, 'TFL_TOTARM', 'TOT_TXQ_EN', 'SUM',/*{|oMdl|TC740VLCL(oMdl,"TOT_TXP", @nDeduc,'TECA740')}*/,, "Tot.Arm. Real") //"Tot.LE Real"
Endif
oModel:AddCalc( 'CALC_TFL_NE', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTAL', 'TOT_GERAL_EN', 'SUM',{|oMdl|TC740VLCL(oMdl," ")},, STR0262) //"Total Ativo"
//--------------------------------------------------------------
//  Totais que são exibidos na interface
//--------------------------------------------------------------
oModel:AddCalc( 'TOTAIS', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTRH' , 'TOT_RH', 'FORMULA',{||.T.} /*bCondition*/, /*bInitValue*/,STR0017 /*cTitle*/,{|oModel| oModel:GetValue("CALC_TFL","TOT_RH")} /*bFormula*/) // 'Geral RH'
oModel:AddCalc( 'TOTAIS', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTMI' , 'TOT_MI', 'FORMULA',{||.T.} /*bCondition*/, /*bInitValue*/,STR0018 /*cTitle*/,{|oModel| oModel:GetValue("CALC_TFL","TOT_MI")} /*bFormula*/)  // 'Geral MI'
oModel:AddCalc( 'TOTAIS', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTMC' , 'TOT_MC', 'FORMULA',{||.T.} /*bCondition*/, /*bInitValue*/,STR0019 /*cTitle*/,{|oModel| oModel:GetValue("CALC_TFL","TOT_MC")} /*bFormula*/)  // 'Geral MC'
oModel:AddCalc( 'TOTAIS', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTLE' , 'TOT_LE', 'FORMULA',{||.T.} /*bCondition*/, /*bInitValue*/,STR0020 /*cTitle*/,{|oModel| oModel:GetValue("CALC_TFL","TOT_LE")} /*bFormula*/)  // 'Geral LE'
If lGsOrcUnif
	oModel:AddCalc( 'TOTAIS'	 , 'TFJ_REFER'	, 'TFL_LOC'		, 'TFL_TOTUNI', 'TOT_TXP'	, 'FORMULA',/*bCondition*/, /*bInitValue*/,"Total Uniforme" /*cTitle*/,{|oModel| oModel:GetValue("CALC_TFL","TOT_TXP")} /*bFormula*/)  // "Total Uniforme"
Endif
If lGsOrcArma
	oModel:AddCalc( 'TOTAIS'	 , 'TFJ_REFER'	, 'TFL_LOC'		, 'TFL_TOTARM', 'TOT_TXQ'	, 'FORMULA',/*bCondition*/, /*bInitValue*/,"Total Armamento" /*cTitle*/,{|oModel| oModel:GetValue("CALC_TFL","TOT_TXQ")} /*bFormula*/)  // "Total Uniforme"
Endif

oModel:AddCalc( 'TOTAIS', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTAL' , 'TOT_GERAL', 'FORMULA',{||.T.} /*bCondition*/, /*bInitValue*/,STR0021 /*cTitle*/, bFormTot /*bFormula*/)  // 'Geral Proposta'
oModel:AddCalc( 'TOTAIS', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTAL', 'TOT_GERAL_EN', 'FORMULA',{|| .T.}  /*bCondition*/, /*bInitValue*/,STR0262 /*cTitle*/, bFormTotEn/*bFormula*/)  // "Total Ativo"

If TFL->( ColumnPos('TFL_GERPLA') )
	oModel:AddCalc( 'TOTAIS', 'TFJ_REFER', 'TFL_LOC', 'TFL_GERPLA', 'TOT_GERPLA', 'SUM',  /*bCondition*/, /*bInitValue*/,"Total Geral Planilha" /*cTitle*/, /*bFormula*/)  // "Total Ativo"
Endif
//--------------------------------------
//fim dos totais exibidos
//--------------------------------------
oMdlCalc := oModel:GetModel("TOTAIS")
oMdlCalc:AddEvents("TOTAIS","TOT_GERAL","",{||.T.})

If lVersion23
	// Altera estrutura do modelo para orçamento simplificado
	At740MdSm(oStrTFJ)
EndIf
If lPutLeg
	At740AddLeg(.T.,{oStrTFL},{oStrTFF},{oStrTFI})
EndIf


oModel:SetActivate( {|oModel| InitDados( oModel ) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} At740GtDes
	Função para cálculo dos valores gerais da proposta

@since   	04/10/2013
@version 	P11.90
/*/
//-------------------------------------------------------------------
Function At740GtDes()

Local oModel := FwModelActive()
Local oMdlCalc := oModel:GetModel("TOTAIS")


oMdlCalc:LoadValue('TOT_RH',(oMdlCalc:GetValue('TOT_RH')),.T.)
oMdlCalc:LoadValue('TOT_MI',(oMdlCalc:GetValue('TOT_MI')),.T.)
oMdlCalc:LoadValue('TOT_MC',(oMdlCalc:GetValue('TOT_MC')),.T.)
oMdlCalc:LoadValue('TOT_LE',(oMdlCalc:GetValue('TOT_LE')),.T.)
oMdlCalc:LoadValue('TOT_GERAL',oMdlCalc:GetValue('TOT_RH')+oMdlCalc:GetValue('TOT_MI')+oMdlCalc:GetValue('TOT_MC')+oMdlCalc:GetValue('TOT_LE'),.T.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da interface

@since   	10/09/2013
@version 	P11.90

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView   		:= Nil
Local oModel  		:= If( oCharge <> NIl, oCharge, ModelDef() )
Local lConExt 		:= IsInCallStack("At870GerOrc")
Local oStrTFJ  		:= Nil
Local oStrTFL  		:= Nil
Local oStrTFF  		:= Nil
Local oStrABP  		:= Nil
Local oStrTFG  		:= Nil
Local oStrTFH  		:= Nil
Local oStrTFI  		:= Nil
Local oStrTFU  		:= Nil
Local oStrTEV  		:= Nil
Local oStrTWO  		:= Nil
Local oStrTXP		:= Nil
Local oStrTXQ		:= Nil
Local oStrCalc 		:= FWCalcStruct( oModel:GetModel('TOTAIS') )
Local lOkSly 		:= AliasInDic('SLY')
Local cGsDsGcn		:= ""
Local lAt870Revi 	:= IsInCallStack("At870Revis")
Local aTFJFields 	:= Nil 
Local lCreateLE 	:= .F. //Cria a pasta RH
Local lGSRH 		:= GSGetIns("RH")
Local lGSMIMC  		:= GSGetIns("MI")
Local lGSLE 		:= GSGetIns("LE")
Local lOrcPrc 		:= SuperGetMv("MV_ORCPRC",,.F.)
Local lVersion23	:= HasOrcSimp()
Local lOrcsim		:= SuperGetMV("MV_ORCSIMP",,'2') == '1' .AND. lVersion23
Local lTecXRh		:= SuperGetMv("MV_TECXRH",,.F.)
Local lTecItExtOp 	:= IsInCallStack("At190dGrOrc") 
Local nI			:= 0
Local aStrTbl		:= {}
Local cNExibCmp		:= "" 
Local lTec855 		:= IsInCallStack("TECA855")
Local lGsOrcUnif 	:= FindFunction("TecGsUnif") .And. TecGsUnif()
Local lGsOrcArma 	:= FindFunction("TecGsArma") .And. TecGsArma()

oStrTFJ  := FWFormStruct(2, 'TFJ', {|cCpo| At740SelFields( 'TFJ', Alltrim(cCpo),lOrcPrc,lVersion23 ) } )
oStrTFL  := FWFormStruct(2, 'TFL', {|cCpo| At740SelFields( 'TFL', Alltrim(cCpo),lOrcPrc,lVersion23 ) } )
oStrTFF  := FWFormStruct(2, 'TFF', {|cCpo| At740SelFields( 'TFF', Alltrim(cCpo),lOrcPrc,lVersion23 ) } )
oStrABP  := FWFormStruct(2, 'ABP', {|cCpo| At740SelFields( 'ABP', Alltrim(cCpo),lOrcPrc,lVersion23 ) } )
oStrTFG  := FWFormStruct(2, 'TFG', {|cCpo| At740SelFields( 'TFG', Alltrim(cCpo),lOrcPrc,lVersion23 ) } )
oStrTFH  := FWFormStruct(2, 'TFH', {|cCpo| At740SelFields( 'TFH', Alltrim(cCpo),lOrcPrc,lVersion23 ) } )
oStrTFI  := FWFormStruct(2, 'TFI', {|cCpo| At740SelFields( 'TFI', Alltrim(cCpo),lOrcPrc,lVersion23 ) } )
oStrTFU  := FWFormStruct(2, 'TFU', {|cCpo| At740SelFields( 'TFU', Alltrim(cCpo),lOrcPrc,lVersion23 ) } )
oStrTEV  := FWFormStruct(2, 'TEV', {|cCpo| At740SelFields( 'TEV', Alltrim(cCpo),lOrcPrc,lVersion23 ) } )
oStrTWO  := FwFormStruct(2, 'TWO', {|cCpo| At740SelFields( 'TWO', Alltrim(cCpo),lOrcPrc,lVersion23 ) } )
If lGsOrcUnif
	oStrTXP  := FwFormStruct(2, 'TXP', {|cCpo| At740SelFields( 'TXP', Alltrim(cCpo),lOrcPrc,lVersion23 ) } )
Endif
If lGsOrcArma
	oStrTXQ  := FwFormStruct(2, 'TXQ', {|cCpo| At740SelFields( 'TXQ', Alltrim(cCpo),lOrcPrc,lVersion23 ) } )
Endif

aTFJFields := oStrTFJ:GetFields()
If lConExt
	oStrTFJ:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
ElseIf lAt870Revi
	At740Habil(aTFJFields, oStrTFJ)
EndIf

//ordena os campos TFI.
oStrTFI:SetProperty( "TFI_ENTEQP", MVC_VIEW_ORDEM, "13" )
oStrTFI:SetProperty( "TFI_COLEQP", MVC_VIEW_ORDEM, "14" )
oStrTFI:SetProperty( "TFI_TOTAL" , MVC_VIEW_ORDEM, "15" )

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_REFER', oStrTFJ, 'TFJ_REFER' )
oView:AddGrid('VIEW_LOC'   , oStrTFL, 'TFL_LOC')
oView:AddGrid('VIEW_RH'    , oStrTFF, 'TFF_RH')
oView:AddGrid('VIEW_MI'    , oStrTFG, 'TFG_MI', , {|| F740LockGrd(oView:GetModel()), oView:Refresh( 'VIEW_MI' ) } )
oView:AddGrid('VIEW_MC'    , oStrTFH, 'TFH_MC', , {|| F740LockGrd(oView:GetModel()), oView:Refresh( 'VIEW_MC' ) })
If !lConExt
	oView:AddGrid('VIEW_BENEF' , oStrABP, 'ABP_BENEF')
	oView:AddGrid('VIEW_HE'    , oStrTFU, 'TFU_HE')
	oView:AddGrid('VIEW_LE'    , oStrTFI, 'TFI_LE')
	oView:AddGrid('VIEW_ADICIO', oStrTEV, 'TEV_ADICIO')
EndIf

If lGsOrcUnif
	oView:AddGrid('VIEW_UNIF'  , oStrTXP, 'TXPDETAIL')
Endif

If lGsOrcArma
	oView:AddGrid('VIEW_ARMA'  , oStrTXQ, 'TXQDETAIL')
Endif

oStrTFL:RemoveField("TFL_TOTIMP")

If TFJ->( ColumnPos('TFJ_DTPLRV') ) > 0 .AND. !((isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") ))
	oStrTFJ:RemoveField("TFJ_DTPLRV")
EndIf

If TFJ->( ColumnPos('TFJ_CODREL') ) > 0
	oStrTFJ:RemoveField("TFJ_CODREL")
EndIf

If TFL->( ColumnPos('TFL_MODPLA') ) > 0
	oStrTFL:RemoveField("TFL_MODPLA")
EndIf

If TFL->( ColumnPos('TFL_CODREL') ) > 0
	oStrTFL:RemoveField("TFL_CODREL")
EndIf

If TFF->( ColumnPos('TFF_MODPLA') ) > 0
	oStrTFF:RemoveField("TFF_MODPLA")
EndIf

If TFF->( ColumnPos('TFF_CODREL') ) > 0
	oStrTFF:RemoveField("TFF_CODREL")
EndIf

If TFG->( ColumnPos('TFG_MODPLA') ) > 0
	oStrTFG:RemoveField("TFG_MODPLA")
EndIf

If TFG->( ColumnPos('TFG_CODREL') ) > 0
	oStrTFG:RemoveField("TFG_CODREL")
EndIf

If TFH->( ColumnPos('TFH_MODPLA') ) > 0
	oStrTFH:RemoveField("TFH_MODPLA")
EndIf

If TFH->( ColumnPos('TFH_CODREL') ) > 0
	oStrTFH:RemoveField("TFH_CODREL")
EndIf

If TFU->( ColumnPos('TFU_MODPLA') ) > 0
	oStrTFU:RemoveField("TFU_MODPLA")
EndIf

If TFU->( ColumnPos('TFU_CODREL') ) > 0
	oStrTFU:RemoveField("TFU_CODREL")
EndIf

If TFL->( ColumnPos('TFL_ATCC') ) > 0 .AND. !(isInCallStack("At870PRev"))
	oStrTFL:RemoveField("TFL_ATCC")
EndIf

If TFF->( ColumnPos('TFF_CODTWO') ) > 0
	oStrTFF:RemoveField("TFF_CODTWO")
EndIf

If TFG->( ColumnPos('TFG_CODTWO') ) > 0
	oStrTFG:RemoveField("TFG_CODTWO")
EndIf

If TFH->( ColumnPos('TFH_CODTWO') ) > 0
	oStrTFH:RemoveField("TFH_CODTWO")
EndIf

If lGsOrcUnif 
	If TXP->( ColumnPos('TXP_CODTWO') ) > 0
		oStrTXP:RemoveField("TXP_CODTWO")
	EndIf 
	If TXP->( ColumnPos('TXP_CHVTWO') ) > 0
		oStrTXP:RemoveField("TXP_CHVTWO")
	EndIf 		
EndIf 

If lGsOrcArma 
	If TXQ->( ColumnPos('TXQ_CODTWO') ) > 0
		oStrTXQ:RemoveField("TXQ_CODTWO")
	EndIf	
	If TXQ->( ColumnPos('TXQ_CHVTWO') ) > 0
		oStrTXQ:RemoveField("TXQ_CHVTWO")
	EndIf	
EndIf 

oStrTFF:RemoveField("TFF_CALCMD")

oStrTFI:RemoveField("TFI_CALCMD")
oStrTFI:RemoveField("TFI_SEPSLD")
oStrTFI:RemoveField("TFI_CONENT")
oStrTFI:RemoveField("TFI_CONCOL")
oStrTFI:RemoveField( "TFI_PLACOD" )
oStrTFI:RemoveField( "TFI_PLAREV" )
oStrTFH:RemoveField( "TFH_TES" )
oStrTFG:RemoveField( "TFG_TES" )

If (oModel:GetOperation() == MODEL_OPERATION_INSERT .AND. !(IsInCallStack("TECA870"))) .OR.;
		 ((IsInCallStack("TECA745") .AND. IsInCallStack("a745IncOrc")) .AND. lVersion23)
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

	//MI
	If !lGSRH .OR. !lGSMIMC
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

If isInCallStack("At870GerOrc")
	oStrTFF:SetProperty('TFF_COBCTR', MVC_VIEW_ORDEM, '02')
	oStrTFG:SetProperty('TFG_COBCTR', MVC_VIEW_ORDEM, '02')
	oStrTFH:SetProperty('TFH_COBCTR', MVC_VIEW_ORDEM, '02')
EndIf

If TFL->( ColumnPos('TFL_ATCC') ) > 0 .AND. isInCallStack("At870PRev")
	oStrTFL:SetProperty('TFL_ATCC', MVC_VIEW_ORDEM, Soma1(oStrTFL:GetProperty('TFL_DTFIM', MVC_VIEW_ORDEM)))
EndIf

If lVersion23
	If !lOrcsim
		oStrTFJ:RemoveField('TFJ_VEND')
	EndIf
EndIf

//Item extra operacional
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
		If (aStrTbl[nI,4] == "N" .And. aStrTbl[nI,3] <> "TFF_QTDVEN") .Or.;
		 	AllTrim(aStrTbl[nI,3]) $ cNExibCmp
			oStrTFF:RemoveField(aStrTbl[nI,3])
		Endif
	Next nI
Endif

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
If (SuperGetMv("MV_ORCPRC",,.F.) .And. SuperGetMv("MV_GSAPROV",,"2") == "1") .Or. SuperGetMv("MV_GSAPROV",,"2") == "2"
	If TFJ->(ColumnPos('TFJ_APRVOP')) > 0 
		oStrTFJ:RemoveField('TFJ_APRVOP')
	Endif
	If TFJ->(ColumnPos('TFJ_USAPRO')) > 0
		oStrTFJ:RemoveField('TFJ_USAPRO')
	Endif
	If TFJ->(ColumnPos('TFJ_DTAPRO')) > 0
		oStrTFJ:RemoveField('TFJ_DTAPRO')	
	Endif
Endif

If TFJ->(ColumnPos("TFJ_RESTEC"))>0
    oStrTFJ:RemoveField("TFJ_RESTEC")
EndIf

// Adiciona as visões na tela
oView:CreateHorizontalBox( 'TOP'   , 30 )
oView:CreateHorizontalBox( 'MIDDLE', 70 )

oView:CreateFolder( 'ABAS', 'MIDDLE')
oView:AddSheet('ABAS','ABA01',STR0022)  // 'Locais de Atendimento'
oView:AddSheet('ABAS','ABA02',STR0006)  // 'Recursos Humanos'

If !lConExt
	oView:AddSheet('ABAS','ABA03',STR0009)  // 'Locação de Equipamentos'
	lCreateLE := .T.
EndIf
oView:AddSheet('ABAS','ABA05',STR0263) // 'Totais'

// cria as abas e sheet para incluir
oView:CreateHorizontalBox( 'ID_ABA01' , 100,,, 'ABAS', 'ABA01' ) // Define a área de Locais
oView:CreateHorizontalBox( 'ID_ABA02' , 060,,, 'ABAS', 'ABA02' ) // Define a área de RH
oView:CreateHorizontalBox( 'ID_ABA02A', 040,,, 'ABAS', 'ABA02' ) // área dos acionais relacionados com RH

// cria folder e sheets para Abas de Material Consumo, Implantação e Benefícios
oView:CreateFolder( 'RH_ABAS', 'ID_ABA02A')
oView:AddSheet('RH_ABAS','RH_ABA02',STR0007) // 'Materiais de Implantação'
oView:AddSheet('RH_ABAS','RH_ABA03',STR0008) // 'Materiais de Consumo'

If !lConExt
	oView:AddSheet('RH_ABAS','RH_ABA01',STR0023) // 'Benefícios RH'
	oView:AddSheet('RH_ABAS','RH_ABA04',STR0031) // 'Hora Extra'
	oView:CreateHorizontalBox( 'ID_RH_01' , 100,,, 'RH_ABAS', 'RH_ABA01' ) // Define a área de Benefícios item de Rh
	oView:CreateHorizontalBox( 'ID_RH_04' , 100,,, 'RH_ABAS', 'RH_ABA04' ) // Define a área da Hora Extra
	oView:CreateHorizontalBox( 'ID_ABA03' , 060,,, 'ABAS', 'ABA03' ) // Define a área de Locação de Equipamentos
	oView:CreateHorizontalBox( 'ID_ABA03A', 040,,, 'ABAS', 'ABA03' ) 
	oView:SetOwnerView( 'VIEW_BENEF', 'ID_RH_01')  // Grid Benefícios
	oView:SetOwnerView( 'VIEW_HE'   , 'ID_RH_04')  // Grid Hora Extra
	oView:SetOwnerView( 'VIEW_LE'  , 'ID_ABA03')  // Grid Locação de Equipamentos
	oView:SetOwnerView( 'VIEW_ADICIO'  , 'ID_ABA03A')	
	oView:EnableTitleView('VIEW_ADICIO', STR0011)  // 'Cobrança da Locação'
	oView:AddIncrementField('VIEW_BENEF' , 'ABP_ITEM' )
	oView:AddIncrementField('VIEW_ADICIO' , 'TEV_ITEM' )
	oView:AddIncrementField('VIEW_LE' , 'TFI_ITEM' )
	oView:SetViewProperty( 'VIEW_LE', "CHANGELINE", {{ |oView, cViewID| a740ChgLine(oView, cViewID) }} )
	If TableInDic( "TX8", .F. )
		oView:AddUserButton(STR0182,"",{|oModel| At740ApP(oModel,oView)},,,) // "Aplica Config Planilha"
	EndIf
	If lGSLE
		oView:AddUserButton(STR0087,"",{|| At740ConEq()},,,) //"Consulta Equipamentos"
	EndIf

	// Somente habilita o menu caso nao for vistoria
	If lOkSly .And. !FT600GETVIS() .AND. !isInCallStatck("AT870PlaRe")
		oView:AddUserButton(STR0068,"",{|oModel| AT352TDX(oModel)},,,) //"Vinculo de Beneficios"
	EndIf
	If FindFunction("TecBHasCrn") .AND. TecBHasCrn() .AND. !isInCallStatck("AT870PlaRe")
		oView:AddUserButton(STR0300,"",{|oView| TECA740I(oView)},,,) //"Cronog. Cobrança"
	EndIf
EndIf

If lGsOrcUnif
	oView:AddSheet('RH_ABAS','RH_ABA06',STR0326) // 'Uniforme'
	oView:CreateHorizontalBox( 'ID_RH_06' , 100,,, 'RH_ABAS', 'RH_ABA06' ) // Define a área da Uniforme
	oView:SetOwnerView( 'VIEW_UNIF'  , 'ID_RH_06')
Endif

If lGsOrcArma
	oView:AddSheet('RH_ABAS','RH_ABA07',STR0331) // 'Armamento'
	oView:CreateHorizontalBox( 'ID_RH_07' , 100,,, 'RH_ABAS', 'RH_ABA07' ) // Define a área da Armamento
	oView:SetOwnerView( 'VIEW_ARMA'  , 'ID_RH_07')
Endif

If SuperGetMv("MV_GSITORC",,"2") == "1" .And. FindFunction("TecGsPrecf") .And. TecGsPrecf() .And. FindFunction("Tec984AImp")
	oView:AddUserButton(STR0096,"",{|oModel,oView| TEC740NFac(oModel)},,,)	// "Facilitador"	
else
	oView:AddUserButton(STR0096,"",{|oModel,oView| TEC740FACI(oModel)},,,)	// "Facilitador"
EndIf 

If lTec855
	oView:AddUserButton(STR0068,"",{|oModel| AT352TDX(oModel)},,,) //"Vinculo de Beneficios"
EndIf

// Inclusão da area de totais
oView:CreateHorizontalBox( "ID_ABA05" , 100,,, "ABAS", "ABA05" ) // Area de totais
oView:CreateVerticalBox( "MES_CONTR", 100, "ID_ABA05",, "ABAS", "ABA05" )
oView:AddField( "VIEW_TOT", oStrCalc, "TOTAIS" )

oView:CreateHorizontalBox( 'ID_RH_02' , 100,,, 'RH_ABAS', 'RH_ABA02' ) // Define a área de Materiais de Implantação
oView:CreateHorizontalBox( 'ID_RH_03' , 100,,, 'RH_ABAS', 'RH_ABA03' ) // Define a área de Materiais de Consumo

// Faz a amarração das VIEWs dos modelos com as divisões na interface
oView:SetOwnerView('VIEW_REFER'	,'TOP')			// Cabeçalho
oView:SetOwnerView('VIEW_LOC'	,'ID_ABA01')	// Grid Locais
oView:SetOwnerView('VIEW_RH'	,'ID_ABA02')	// Grid RH
oView:SetOwnerView( 'VIEW_MI'   ,'ID_RH_02')  // Grid Materiais de Implantação
oView:SetOwnerView( 'VIEW_MC'   ,'ID_RH_03')  // Grid Materiais de Consumo
oView:SetOwnerView( "VIEW_TOT" ,"MES_CONTR" ) 

oView:EnableTitleView( "VIEW_TOT", STR0264) //"Valor Total do Contrato" 
If ExistBlock("a740GrdV")
	ExecBlock("a740GrdV",.F.,.F.,{@oView,oView:aFolders})
EndIf

oView:AddIncrementField('VIEW_MC' , 'TFH_ITEM' )
oView:AddIncrementField('VIEW_MI' , 'TFG_ITEM' )
oView:AddIncrementField('VIEW_RH' , 'TFF_ITEM' )

oView:SetAfterViewActivate({|oView| At740Refre(oView)})

SetKey( VK_F4, { || AT740F4() } )

If !lTecItExtOp
	oView:AddUserButton(STR0032,"",{|oModel| TECA998(oModel,oView)},,,) // "Planilha Preço"
	oView:AddUserButton(STR0033,"",{|oModel| At740CpCal(oModel)},,,) //"Copiar Cálculo"
	oView:AddUserButton(STR0034,"",{|oModel| At740ClCal(oModel)},,,) //"Colar Cálculo"
Endif

// Ativa evento ao mudar de linha
oView:SetViewProperty( 'VIEW_LOC', "CHANGELINE", {{ |oView, cViewID| a740ChgLine(oView, cViewID) }} )
oView:SetViewProperty( 'VIEW_RH', "CHANGELINE", {{ |oView, cViewID| a740ChgLine(oView, cViewID) }} )

If lPutLeg
	At740AddLeg(.F.,{oStrTFL,'VIEW_LOC' },{oStrTFF,'VIEW_RH'},{oStrTFI,'VIEW_LE'},oView)
EndIf

If lVersion23
	If IsInCallStack("TECA745")
		oView:AddUserButton(STR0152,"",{|| At745ImpVs()},,,)
	EndIf
	At740VwSm(oStrTFJ)
EndIf

oView:AddUserButton(STR0223,"",{|oView| At740PosRg(oView)},,,) //"Posicionar"

If !lGSRH
	oView:HideFolder('ABAS',STR0006,  2)// 'Recursos Humanos'
Else
	If (!lGSMIMC .Or. lTecItExtOp) .AND. !lTec855
		oView:HideFolder('RH_ABAS',STR0007 ,2) //'Materiais de Implantação'
		oView:HideFolder('RH_ABAS', STR0008, 2) //'Materiais de Consumo'
	EndIf
EndIf

If (lCreateLE .AND. !lGSLE) .Or. lTecItExtOp
	oView:HideFolder('ABAS',STR0009,2)  // 'Locação de Equipamentos'
EndIf

If lTecItExtOp
	oView:HideFolder('ABAS'	,STR0263,2) //'Totais'
EndIf

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740SelFields
	Filtra os campos de controle da rotina para não serem exibidos na view
@sample 	At740SelFields()
@since		27/11/2013
@version	P11.90
@param   	cTab, Caracter, Código da tabela a ter o campo avaliado
@param   	cCpoAval, Caracter, Código do campo a ser avaliado

@return 	lRet, Logico, define se o campo deve ser apresentado na view
/*/
//------------------------------------------------------------------------------
Function At740SelFields( cTab, cCpoAval, lOrcPrc, lVersion23 )

Local lRet   	 	:= .T.
Local lCpoTWO 		:= TWO->( ColumnPos('TWO_CODIGO') ) > 0

Default lOrcPrc	 	:= SuperGetMv("MV_ORCPRC",,.F.)
Default lVersion23  := HasOrcSimp()

If !Empty( cTab ) .And. !Empty( cCpoAval )
	If cTab == 'TFJ'
		If lVersion23
			lRet := !( cCpoAval $ 'TFJ_PROPOS#TFJ_PREVIS#TFJ_ENTIDA#TFJ_ITEMRH#TFJ_ITEMMI#TFJ_ITEMMI#TFJ_DESCON#TFJ_DSGCN#TFJ_ORCSIM' )
		Else
			lRet := !( cCpoAval $ 'TFJ_PROPOS#TFJ_PREVIS#TFJ_ENTIDA#TFJ_ITEMRH#TFJ_ITEMMI#TFJ_ITEMMI#TFJ_DESCON#TFJ_DSGCN' )
		EndIf
		lRet := lRet .And. !( cCpoAval $ 'TFJ_ITEMMC#TFJ_ITEMLE#TFJ_CONTRT#TFJ_CONREV#TFJ_STATUS#TFJ_TOTRH#TFJ_TOTMI#TFJ_TOTMC#TFJ_TOTLE#TFJ_CODVIS#TFJ_TABXML#TFJ_TOTUNI#TFJ_TOTARM#TFJ_GERPLA' )
		
		If !lOrcPrc // Retirar campos para o modelo antigo de orçamento de serviços
			lRet := lRet .And. !( cCpoAval $ 'TFJ_CODTAB#TFJ_TABREV')
		EndIf
	ElseIf cTab == 'TFL'
		lRet := !( cCpoAval $ 'TFL_CODIGO#TFL_CODPAI#TFL_CONTRT#TFL_CONREV#TFL_CODSUB' )
		lRet := lRet .And. !( cCpoAval $ 'TFL_ITPLRH#TFL_ITPLMI#TFL_ITPLMC#TFL_ITPLLE#TFL_ENCE' )
		If !lOrcPrc // Retirar campos para o modelo antigo de orçamento de serviços
			lRet := lRet .And. !( cCpoAval $ 'TFL_MESRH#TFL_MESMI#TFL_MESMC' )
		EndIf
	ElseIf cTab == 'TFF'
		lRet := !( (cCpoAval +"#") $ 'TFF_LOCAL#TFF_CODPAI#TFF_CONTRT#TFF_CONREV#TFF_CODSUB#TFF_CHVTWO#TFF_ENCE#TFF_PROCES#TFF_ITCNB#TFF_TABXML#TFF_ITEXOP#' )

		If lOrcPrc // Retirar campos para o novo modelo de orçamento de serviços
			lRet := lRet .And. !( cCpoAval $ 'TFF_TOTMI#TFF_TOTMC#TFF_TOTUNI' )
		Else
			lRet := lRet .And. !( cCpoAval $ 'TFF_TOTMES' )
		EndIf
	ElseIf cTab == 'TFI'
		lRet := !( cCpoAval $ 'TFI_COD#TFI_LOCAL#TFI_OK#TFI_SEPARA#TFI_CODPAI#TFI_CONTRT#TFI_CONREV#TFI_CODSUB#TFI_CHVTWO#TFI_ITCNB' )
		lRet := lRet .And. !( cCpoAval $ 'TFI_CODTGQ#TFI_ITTGR#TFI_CODATD#TFI_NOMATD#TFI_CONENT#TFI_CONCOL#TFI_ENCE#TFI_DTPFIM' )
	ElseIf cTab == 'ABP'
		If cCpoAval == "ABP_ITEM"
			lRet := .T.
		Else
			lRet := !( cCpoAval $ 'ABP_COD#ABP_REVISA#ABP_CODPRO#ABP_ENTIDA#ABP_ITRH#ABP_ITEMPR' )
		EndIf
	ElseIf cTab == 'TFG'
		lRet := !( cCpoAval $ 'TFG_COD#TFG_LOCAL#TFG_CODPAI#TFG_SLD#TFG_CODSUB#TFG_CHVTWO#TFG_ITCNB#TFG_CONTRT#TFG_CONREV' )
	ElseIf cTab == 'TFH'
		lRet := !( cCpoAval $ 'TFH_COD#TFH_LOCAL#TFH_CODPAI#TFH_SLD#TFH_CODSUB#TFH_CHVTWO#TFH_ITCNB#TFH_CONTRT#TFH_CONREV' )
	ElseIf cTab == 'TFU'
		lRet := !( cCpoAval $ 'TFU_CODIGO#TFU_CODTFF#TFU_LOCAL' )
	ElseIf cTab == 'TEV'
		lRet := !( cCpoAval $ 'TEV_CODLOC#TEV_SLD' )
	ElseIf cTab == 'TWO'
		If lCpoTWO
			lRet := !( cCpoAval $ 'TWO_CODORC#TWO_PROPOS#TWO_OPORTU#TWO_LOCAL#TWO_CODIGO' )
		Else 
			lRet := !( cCpoAval $ 'TWO_CODORC#TWO_PROPOS#TWO_OPORTU#TWO_LOCAL' )
		EndIf 	
	ElseIf cTab == 'TXP'
		lRet := !( cCpoAval $ 'TXP_CONTRT#TXP_CONREV#TXP_CODSUB#TXP_CODTFF' )
	ElseIf cTab == 'TXQ'
		lRet := !( cCpoAval $ 'TXQ_CONTRT#TXQ_CONREV#TXQ_CODSUB#TXQ_CODTFF' )
	Else
		lRet := .F.
	EndIf
Else
	lRet := .F.
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740SubTot
	Inicializa o subtotal da linha
@sample 	At740SubTot()
@since		12/09/2013
@version	P11.90
@return 	nValor, NUMERIC, valor da multiplicação do preço unitário com a quantidade
/*/
//------------------------------------------------------------------------------
Function At740SubTot()

Local nValor     := 0
Local oMdlAtivo  := FwModelActive()
Local oMdlGrid   := Nil

If oMdlAtivo <> Nil .And. (oMdlAtivo:GetId()=="TECA740" .Or. oMdlAtivo:GetId()=="TECA740F")

	oMdlGrid := oMdlAtivo:GetModel( "TEV_ADICIO" )

	If oMdlGrid:GetLine()<>0

		nValor := oMdlGrid:GetValue("TEV_VLRUNI") * oMdlGrid:GetValue("TEV_QTDE")
	EndIf

EndIf

Return nValor

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740Cmt
	Realizar a gravação dos dados
@sample 	At740Cmt()
@since		20/09/2013
@version	P11.90
@return 	oModel, Object, instância do modelo de dados MpFormModel
/*/
//------------------------------------------------------------------------------
Function At740Cmt( oModel )

Local lRet 				:= .T.
Local aCriaSb2 			:= {}
Local nLocais 			:= 0
Local nRHs    			:= 0
Local nMateriais 		:= 0
Local lOrcPrc			:= !EMPTY( oModel:GetValue('TFJ_REFER','TFJ_CODTAB') )
Local aRows    			:= {}
Local aItemRH  			:= {}
Local lGrvOrc	 		:= At740GCmt()
Local cGsdsgcn 	 		:= oModel:GetValue( 'TFJ_REFER', 'TFJ_DSGCN')
Local cCodOrc			:= ""
Local cContrato			:= oModel:GetValue( 'TFJ_REFER', 'TFJ_CONTRT')
Local cRevisa			:= oModel:GetValue( 'TFJ_REFER', 'TFJ_PREVIS')
Local lOrcSim	 		:= .F.
Local nForcaCalc 		:= 1
Local nMaxRhs 			:= 0
Local lFillPropVist 	:= ( IsInCallStack('FATA600') .Or. IsInCallStack('TECA270') .Or. At740ToADZ() )
Local nLastPosVal := 0 //Guarda ultima linha valida
Local lVersion23	:= HasOrcSimp()
Local lContExt	:= IsInCallStack("At870GerOrc")
Local cTabXML := "" //MXL de gravação do orçamento
Local oMdlTFL    := oModel:GetModel('TFL_LOC')
Local oMdlTFF	:= oModel:GetModel('TFF_RH')
Local oMdlTFI	:= oModel:GetModel('TFI_LE')
Local oMdlTFG	:= oModel:GetModel('TFG_MI')
Local oMdlTFH	:= oModel:GetModel('TFH_MC')
Local oMdlTFU	:= oModel:GetModel('TFU_HE')
Local aOldRec := {}
Local nPosTFL := 0
Local lAtuCod :=  oModel:IsCopy() .OR. (isInCallStack("AT870RvPlC") .AND. !isInCallStack("At870Eftrv"))
Local nI := 1
Local aRecSubCod := {}
Local cNewCod := ""
Local nX	:= 1
Local lRevi := (isInCallStatck("At870Revis") .And. TFJ->TFJ_STATUS == '1') .OR. isInCallStatck("AT870PlaRe")
Local aArea
Local aTFFOrg := {}
Local aAreaTFF := {}
Local lMdtGS 	:= SuperGetMv("MV_NG2GS",.F.,.F.) .And. TableInDic("TN5") .And. TableInDic("TN6") //Parâmetro de integração entre o SIGAMDT x SIGATEC
Local cMensagem := ""
Local cEventID := "062" 
Local cCodLoc  := ""
Local lAprovOp	:= .F.
Local aAreaTFJ	:= {} 
If lVersion23
	lOrcSim 		:= oModel:GetValue( 'TFJ_REFER', 'TFJ_ORCSIM') == '1'
EndIF

// Atualiza as informações dos recursos humanos calculando conforme o preenchimento
If lOrcPrc .And. oModel:GetOperation() <> MODEL_OPERATION_DELETE
	If !lContExt
		//Se não for item extra, habilita o cálculo usando a planilha de precificação do orçamento de serviços
		At740GSC(.T.)
	Else
		At740GSC(.F.)
	EndIf
	For nLocais := 1 To oMdlTFL:Length()
		oMdlTFL:GoLine( nLocais )
		nMaxRhs := oMdlTFF:Length()
		nLastPosVal := 0
		For nX := 1 To oMdlTFG:Length()
			oMdlTFG:GoLine(nX)
			If IsInCallStack("At870GerOrc") .AND. oMdlTFG:GetValue("TFG_COBCTR") == "2" .AND.;
			 		!Empty(oMdlTFG:GetValue('TFG_PRODUT')) .AND. !(oMdlTFG:IsDeleted())
				If oMdlTFG:IsInserted()
					oMdlTFG:LoadValue('TFG_SLD', oMdlTFG:GetValue('TFG_QTDVEN') )
					oMdlTFG:LoadValue("TFG_CONTRT", oMdlTFL:GetValue("TFL_CONTRT"))
					oMdlTFG:LoadValue("TFG_CONREV", oMdlTFL:GetValue("TFL_CONREV"))
				Else
					At870revMt(oModel,"TFG",oMdlTFG:GetValue("TFG_COD"))
				EndIf
			Endif
			If lAtuCod
				If !oMdlTFG:IsDeleted() .And. !Empty(oMdlTFG:GetValue('TFG_PRODUT')) .And. !oMdlTFG:IsInserted()
					//-- Atualiza saldo do item
					If lRevi
						At870revMt(oModel,"TFG",oMdlTFG:GetValue("TFG_COD"))
					Endif
					cNewCod := CriaVar("TFG_COD",.T.)
					Aadd(aRecSubCod, {"TFG",oMdlTFG:GetValue("TFG_COD"),cNewCod})
					oMdlTFG:LoadValue("TFG_COD",cNewCod)
				ElseIf !Empty(oMdlTFG:GetValue('TFG_PRODUT')) .And. oMdlTFG:IsInserted()
					oMdlTFG:LoadValue('TFG_SLD', oMdlTFG:GetValue('TFG_QTDVEN') )
				EndIf
			EndIf
		Next nX
		For nX := 1 To oMdlTFH:Length()
			oMdlTFH:GoLine(nX)
			If IsInCallStack("At870GerOrc") .AND. oMdlTFH:GetValue("TFH_COBCTR") == "2" .AND.;
			 		!Empty(oMdlTFH:GetValue('TFH_PRODUT')) .AND. !(oMdlTFH:IsDeleted())
				If oMdlTFH:IsInserted()
					oMdlTFH:LoadValue("TFH_CONTRT", oMdlTFL:GetValue("TFL_CONTRT"))
					oMdlTFH:LoadValue("TFH_CONREV", oMdlTFL:GetValue("TFL_CONREV"))
					oMdlTFH:LoadValue('TFH_SLD', oMdlTFH:GetValue('TFH_QTDVEN') )
				Else
					At870revMt(oModel,"TFH",oMdlTFH:GetValue("TFH_COD"))
				EndIf
			EndIf
			If lAtuCod
				If !oMdlTFH:IsDeleted() .And. !Empty(oMdlTFH:GetValue('TFH_PRODUT')) .And. !oMdlTFH:IsInserted()
					If lRevi
						At870revMt(oModel,"TFH",oMdlTFH:GetValue("TFH_COD"))
					EndIf
					cNewCod := CriaVar("TFH_COD",.T.)
					Aadd(aRecSubCod, {"TFH",oMdlTFH:GetValue("TFH_COD"),cNewCod})
					oMdlTFH:LoadValue("TFH_COD",cNewCod)
				ElseIf !Empty(oMdlTFH:GetValue('TFH_PRODUT')) .And. oMdlTFH:IsInserted()
					oMdlTFH:LoadValue('TFH_SLD', oMdlTFH:GetValue('TFH_QTDVEN') )
				EndIf
			EndIf
		Next nX
		If lAtuCod .And. !oMdlTFL:IsDeleted() .And. !oMdlTFL:IsInserted()
			cNewCod := CriaVar("TFL_CODIGO",.T.)
			Aadd(aRecSubCod, {"TFL",oMdlTFL:GetValue("TFL_CODIGO"),cNewCod})
			oMdlTFL:LoadValue("TFL_CODIGO",cNewCod)
		EndIf
		For nRHs := 1 To nMaxRhs
			oMdlTFF:GoLine( nRHs )
			If (isInCallStack("At190dGrOrc") .AND. (oMdlTFF:IsUpdated() .OR. oMdlTFF:IsInserted()) .AND. oMdlTFF:GetValue("TFF_COBCTR") == "2" .AND. oMdlTFF:GetValue("TFF_ITEXOP") == "1"  )
				If Empty(cMensagem)
					cMensagem  := STR0270 +  oMdlTFL:GetValue('TFL_CONTRT') + Chr(13) + Chr(10) + "" //Contrato 
					cMensagem  += STR0271 + oMdlTFL:GetValue('TFL_CODPAI') + Chr(13) + Chr(10) + "" //Orçamento
					cMensagem  += STR0272 + oMdlTFL:GetValue('TFL_CODIGO') + Chr(13) + Chr(10) + "" // Local de Atendimento
					cMensagem  += STR0273 + oMdlTFF:GetValue('TFF_COD') +  Chr(13) + Chr(10) + "" // Recursos Humanos
					cMensagem  += STR0274 + oMdlTFF:GetValue('TFF_ITEM') +  Chr(13) + Chr(10) + "" // Item
					cMensagem  += STR0275 + oMdlTFF:GetValue('TFF_PRODUT') +  Chr(13) + Chr(10) + "" // Código do Produto
					cMensagem  += STR0249 + oMdlTFF:GetValue('TFF_DESCRI') +  Chr(13) + Chr(10) + "" //Produto
					cMensagem  += STR0276 + cValToChar(oMdlTFF:GetValue('TFF_QTDVEN')) +  Chr(13) + Chr(10) +  "" //Quantidade
					cMensagem  += STR0277 + dToC(oMdlTFF:GetValue('TFF_PERINI')) +  Chr(13) + Chr(10) + "" //Data Inicial
					cMensagem  += STR0278 + dToC(oMdlTFF:GetValue('TFF_PERFIM')) +  Chr(13) + Chr(10) +  "" // Data Final
					cMensagem  += STR0279 + oMdlTFF:GetValue('TFF_FUNCAO') +  Chr(13) + Chr(10) + "" // Código da Função
					cMensagem  += STR0280 + oMdlTFF:GetValue('TFF_DFUNC') +  Chr(13) + Chr(10) + "" // Função
					cMensagem  += STR0281 + oMdlTFF:GetValue('TFF_TURNO') +  Chr(13) + Chr(10) + "" //Código do Turno
					cMensagem  += STR0282 + oMdlTFF:GetValue('TFF_DTURNO') +  Chr(13) + Chr(10) + "" // Turno
					cMensagem  += STR0283 + oMdlTFF:GetValue('TFF_CARGO') +  Chr(13) + Chr(10) + "" // Código do Cargo
					cMensagem  += STR0284 + oMdlTFF:GetValue('TFF_DCARGO') +  Chr(13) + Chr(10) + "" // Cargo
					cMensagem  += STR0285 + oMdlTFF:GetValue('TFF_ESCALA') +  Chr(13) + Chr(10) + "" // Código da Escala
					cMensagem  += STR0286 + oMdlTFF:GetValue('TFF_NOMESC') +  Chr(13) + Chr(10) + "" // Escala
				Else
					If cCodLoc != oMdlTFL:GetValue('TFL_CODIGO')	
						cMensagem  += STR0272 + oMdlTFL:GetValue('TFL_CODIGO') + Chr(13) + Chr(10) + "" // Local de Atendimento
						cMensagem  += STR0273 + oMdlTFF:GetValue('TFF_COD') +  Chr(13) + Chr(10) + "" // Recursos Humanos
						cMensagem  += STR0274 + oMdlTFF:GetValue('TFF_ITEM') +  Chr(13) + Chr(10) + "" // Item
						cMensagem  += STR0275 + oMdlTFF:GetValue('TFF_PRODUT') +  Chr(13) + Chr(10) + "" // Código do Produto
						cMensagem  += STR0249 + oMdlTFF:GetValue('TFF_DESCRI') +  Chr(13) + Chr(10) + "" //Produto
						cMensagem  += STR0276 + cValToChar(oMdlTFF:GetValue('TFF_QTDVEN')) +  Chr(13) + Chr(10) +  "" //Quantidade
						cMensagem  += STR0277 + dToC(oMdlTFF:GetValue('TFF_PERINI')) +  Chr(13) + Chr(10) + "" //Data Inicial
						cMensagem  += STR0278 + dToC(oMdlTFF:GetValue('TFF_PERFIM')) +  Chr(13) + Chr(10) +  "" // Data Final
						cMensagem  += STR0279 + oMdlTFF:GetValue('TFF_FUNCAO') +  Chr(13) + Chr(10) + "" // Código da Função
						cMensagem  += STR0280 + oMdlTFF:GetValue('TFF_DFUNC') +  Chr(13) + Chr(10) + "" // Função
						cMensagem  += STR0281 + oMdlTFF:GetValue('TFF_TURNO') +  Chr(13) + Chr(10) + "" //Código do Turno
						cMensagem  += STR0282 + oMdlTFF:GetValue('TFF_DTURNO') +  Chr(13) + Chr(10) + "" // Turno
						cMensagem  += STR0283 + oMdlTFF:GetValue('TFF_CARGO') +  Chr(13) + Chr(10) + "" // Código do Cargo
						cMensagem  += STR0284 + oMdlTFF:GetValue('TFF_DCARGO') +  Chr(13) + Chr(10) + "" // Cargo
						cMensagem  += STR0285 + oMdlTFF:GetValue('TFF_ESCALA') +  Chr(13) + Chr(10) + "" // Código da Escala
						cMensagem  += STR0286 + oMdlTFF:GetValue('TFF_NOMESC') +  Chr(13) + Chr(10) + "" // Escala
					Else
						cMensagem  += STR0273 + oMdlTFF:GetValue('TFF_COD') +  Chr(13) + Chr(10) + "" // Recursos Humanos
						cMensagem  += STR0274 + oMdlTFF:GetValue('TFF_ITEM') +  Chr(13) + Chr(10) + "" // Item
						cMensagem  += STR0275 + oMdlTFF:GetValue('TFF_PRODUT') +  Chr(13) + Chr(10) + "" // Código do Produto
						cMensagem  += STR0249 + oMdlTFF:GetValue('TFF_DESCRI') +  Chr(13) + Chr(10) + "" //Produto
						cMensagem  += STR0276 + cValToChar(oMdlTFF:GetValue('TFF_QTDVEN')) +  Chr(13) + Chr(10) +  "" //Quantidade
						cMensagem  += STR0277 + dToC(oMdlTFF:GetValue('TFF_PERINI')) +  Chr(13) + Chr(10) + "" //Data Inicial
						cMensagem  += STR0278 + dToC(oMdlTFF:GetValue('TFF_PERFIM')) +  Chr(13) + Chr(10) +  "" // Data Final
						cMensagem  += STR0279 + oMdlTFF:GetValue('TFF_FUNCAO') +  Chr(13) + Chr(10) + "" // Código da Função
						cMensagem  += STR0280 + oMdlTFF:GetValue('TFF_DFUNC') +  Chr(13) + Chr(10) + "" // Função
						cMensagem  += STR0281 + oMdlTFF:GetValue('TFF_TURNO') +  Chr(13) + Chr(10) + "" //Código do Turno
						cMensagem  += STR0282 + oMdlTFF:GetValue('TFF_DTURNO') +  Chr(13) + Chr(10) + "" // Turno
						cMensagem  += STR0283 + oMdlTFF:GetValue('TFF_CARGO') +  Chr(13) + Chr(10) + "" // Código do Cargo
						cMensagem  += STR0284 + oMdlTFF:GetValue('TFF_DCARGO') +  Chr(13) + Chr(10) + "" // Cargo
						cMensagem  += STR0285 + oMdlTFF:GetValue('TFF_ESCALA') +  Chr(13) + Chr(10) + "" // Código da Escala
						cMensagem  += STR0286 + oMdlTFF:GetValue('TFF_NOMESC') +  Chr(13) + Chr(10) + "" // Escala
					EndIf
				EndIf		
				cCodLoc := oMdlTFL:GetValue('TFL_CODIGO')
			EndIf
			If isInCallStack("At870GerOrc") .AND. oMdlTFF:isDeleted() .AND. oMdlTFF:GetValue("TFF_COBCTR") == "2"
				aArea := GetArea()
				DbSelectArea("ABQ")
				ABQ->(DbSetOrder(3))
				If ABQ->( dbSeek( xFilial("ABQ") + oMdlTFF:GetValue("TFF_COD") + xFilial("TFF") ) )
					RecLock( "ABQ", .F. )
					ABQ->( dbDelete() )
					ABQ->( MsUnlock() )
				EndIf
				RestArea(aArea)
			EndIf
			// Antes de Utilizar qualquer valor da tabela de precificação efetua o calculo
			If !Empty(oMdlTFF:GetValue('TFF_PRODUT'))
				// verifica se é o último item para forçar atualização dos acumuladores base para impostos
				If nRHs == nMaxRhs
					nForcaCalc := 2
				Else
					nForcaCalc := 1
					nLastPosVal := nRHs
				EndIf
				// Identifica o objeto conforme o array com as planilhas / FwWorkSheet
				// Captura as tabela de precificação em uso pelo orçamento de serviços
				// modelo para captura do preenchimento e dados
				If ((oMdlTFF:GetValue('TFF_COBCTR') <> '2' .AND. !(isInCallStack("At870GerOrc"))) .OR.;
						(oMdlTFF:GetValue('TFF_COBCTR') == '2' .AND. isInCallStack("At870GerOrc"))) // pertence ao contrato
					//Colocar If para verificar se a tabela foi carregada ou se é uma linha nova
					If (oMdlTFF:GetValue("TFF_LOADPRC") .And. !oMdlTFF:IsInserted()) .Or. (!oMdlTFF:GetValue("TFF_LOADPRC") .And. oMdlTFF:IsInserted())
					Processa( {|| ( At740EEPC( At740FGSS(oModel), At740FORC(), oModel, , nForcaCalc ) ) }, STR0082, STR0083,.F.) // "Aguarde..." ### "Executando cálculo ..."
					EndIf
				ElseIf oMdlTFF:GetValue('TFF_COBCTR') == '2' .AND. !(isInCallStack("At870GerOrc") .OR. isInCallStack("At870PRev") .OR. isInCallStack("At870AprRv")) 
					If Len(At40GetAFWS()) > 0
                        At40GetAFWS()[nLocais][2][nRHs][1] := oMdlTFF:GetValue('TFF_COD')
                    EndIf
				EndIf
				If lAtuCod .And. !oMdlTFF:IsInserted()
					nPosTFL := Ascan(aOldRec, {|x| x[1] == nLocais })
					If nPosTFL == 0
						Aadd(aOldRec,{nLocais,{oMdlTFF:GetValue("TFF_COD")}})
					Else
						Aadd(aOldRec[nPosTFL,2],oMdlTFF:GetValue("TFF_COD"))
					EndIf
					cNewCod := CriaVar("TFF_COD",.T.)
					Aadd(aRecSubCod, {"TFF",oMdlTFF:GetValue("TFF_COD"),cNewCod})
					oMdlTFF:LoadValue("TFF_COD",cNewCod)
					If lRevi .AND. !(isInCallStatck("AT870PlaRe"))
						At740UpSLY(aRecSubCod[Len(aRecSubCod)][2],aRecSubCod[Len(aRecSubCod)][3])
					EndIf
				EndIf
			EndIf
		Next nRHs
		If nForcaCalc == 1 .AND. nLastPosVal > 0  //Nao recalculou todos os itens de RH, então posiciona no ultimo valido e força atualização dos acumuladores base para impostos
			nForcaCalc := 2
			oMdlTFF:GoLine( nLastPosVal )
			Processa( {|| ( At740EEPC( At740FGSS(oModel), At740FORC(), oModel, , nForcaCalc ) ) }, STR0082, STR0083,.F.) // "Aguarde..." ### "Executando cálculo ..."
 		EndIf
	Next nLocais
	If TFF->( ColumnPos('TFF_TABXML') ) > 0
		At740FMXML(oModel,,aOldRec)
	Else
		cTabXML := At740FMXML(oModel,,aOldRec)
		oModel:GetModel('TFJ_REFER'):LoadValue('TFJ_TABXML',cTabXML)
	EndIf
	// desabilita os cálculos
	At740GSC(.F.)
EndIf
If lGrvOrc
	If lVersion23
		// Seta os valores de referência para os itens agrupadores do orçamento, caso o parâmetro MV_GSDSGCN esteja ativo
		IF lOrcSim .AND. cGsdsgcn <> '1' .AND. oModel:GetOperation() != MODEL_OPERATION_DELETE
			AT745RefProd(oModel)
		EndIf
	EndIf
	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		If lVersion23
			cCodOrc := oModel:GetValue( 'TFJ_REFER', 'TFJ_CODIGO')
		EndIf
		If FindFunction("TecBHasCrn") .AND. TecBHasCrn()
			Tec740IExc(oModel:GetValue( 'TFJ_REFER', 'TFJ_CODIGO'),;
				/*cTFL*/,;
				/*cTFF*/,;
				/*cTFG*/,; 
				/*cTFH*/,;
				oModel:GetOperation())
		EndIf
		If ( lRet := FwFormCommit( oModel ) )
			aEnceCpos := {}
			If lVersion23
				If lRet .AND. lOrcSim
					aArea := GetArea()
					DbSelectArea("AAT")
					DbSetOrder(4) //filial + codorc
					If DbSeek(xFilial("AAT") + cCodOrc)
						RecLock("AAT",.F.)
							AAT->AAT_CODORC := ""
						MsUnlock()
					EndIf
					RestArea(aArea)
				EndIf
			EndIf
		EndIf
	Else
		//----------------------------------------------------------
		//  Identifica os produtos que ainda não estão com o saldo inicial
		// criado
		aRows := FwSaveRows()
		DbSelectArea('SB1')
		SB1->( DbSetOrder( 1 ) ) // B1_FILIAL+B1_COD
		DbSelectArea('SB2')
		SB2->( DbSetOrder( 1 ) ) // B2_FILIAL+B2_COD+B2_LOCAL
		For nLocais := 1 To oMdlTFL:Length()
			oMdlTFL:GoLine( nLocais )
			If !lOrcPrc .And. lAtuCod .And. !oMdlTFL:IsDeleted() .And. !oMdlTFL:IsInserted()
				If isInCallStack("AT870RvPlC")
					cNewCod := oMdlTFL:GetValue("TFL_CODIGO")
				Else
					cNewCod := CriaVar("TFL_CODIGO",.T.)
				EndIf
				If isInCallStack("AT870RvPlC")
					Aadd(aRecSubCod, {"TFL",oMdlTFL:GetValue("TFL_CODREL"),cNewCod})
				Else
					Aadd(aRecSubCod, {"TFL",oMdlTFL:GetValue("TFL_CODIGO"),cNewCod})
				EndIf
				oMdlTFL:LoadValue("TFL_CODIGO",cNewCod)
				If isInCallStack("AT870PlaRe")
					oMdlTFL:LoadValue("TFL_CONTRT", "")
				EndIf
			EndIf
			If lAtuCod
				For nI := 1 To oMdlTFI:Length()
					oMdlTFI:GoLine(nI)
					If !oMdlTFI:IsDeleted() .And. !Empty(oMdlTFI:GetValue('TFI_PRODUT')) .And. !oMdlTFI:IsInserted()
						cNewCod := CriaVar("TFI_COD",.T.)
						Aadd(aRecSubCod, {"TFI",oMdlTFI:GetValue("TFI_COD"),cNewCod})
						oMdlTFI:LoadValue("TFI_COD",cNewCod)
					EndIf
				Next nI
			EndIf
			For nRHs := 1 To oMdlTFF:Length()
				oMdlTFF:GoLine( nRHs )
				If FindFunction("TecBHasCrn") .AND. TecBHasCrn()
					If oMdlTFF:isDeleted() .OR. oMdlTFL:isDeleted()
						Tec740IExc(oModel:GetValue( 'TFJ_REFER', 'TFJ_CODIGO'),;
													/*cTFL*/,;
													oMdlTFF:GetValue("TFF_COD"),;
													/*cTFG*/,;
													/*cTFH*/,;
													oModel:GetOperation())
					EndIf
				EndIf
				If (isInCallStack("At190dGrOrc") .AND. !lOrcPrc .AND. (oMdlTFF:IsUpdated() .OR. oMdlTFF:IsInserted()) .AND. oMdlTFF:GetValue("TFF_COBCTR") == "2" .AND. oMdlTFF:GetValue("TFF_ITEXOP") == "1" )
					If Empty(cMensagem)
						cMensagem  := STR0270 +  oMdlTFL:GetValue('TFL_CONTRT') + Chr(13) + Chr(10) + "" //Contrato 
						cMensagem  += STR0271 + oMdlTFL:GetValue('TFL_CODPAI') + Chr(13) + Chr(10) + "" //Orçamento
						cMensagem  += STR0272 + oMdlTFL:GetValue('TFL_CODIGO') + Chr(13) + Chr(10) + "" // Local de Atendimento
						cMensagem  += STR0273 + oMdlTFF:GetValue('TFF_COD') +  Chr(13) + Chr(10) + "" // Recursos Humanos
						cMensagem  += STR0274 + oMdlTFF:GetValue('TFF_ITEM') +  Chr(13) + Chr(10) + "" // Item
						cMensagem  += STR0275 + oMdlTFF:GetValue('TFF_PRODUT') +  Chr(13) + Chr(10) + "" // Código do Produto
						cMensagem  += STR0249 + oMdlTFF:GetValue('TFF_DESCRI') +  Chr(13) + Chr(10) + "" //Produto
						cMensagem  += STR0276 + cValToChar(oMdlTFF:GetValue('TFF_QTDVEN')) +  Chr(13) + Chr(10) +  "" //Quantidade
						cMensagem  += STR0277 + dToC(oMdlTFF:GetValue('TFF_PERINI')) +  Chr(13) + Chr(10) + "" //Data Inicial
						cMensagem  += STR0278 + dToC(oMdlTFF:GetValue('TFF_PERFIM')) +  Chr(13) + Chr(10) +  "" // Data Final
						cMensagem  += STR0279 + oMdlTFF:GetValue('TFF_FUNCAO') +  Chr(13) + Chr(10) + "" // Código da Função
						cMensagem  += STR0280 + oMdlTFF:GetValue('TFF_DFUNC') +  Chr(13) + Chr(10) + "" // Função
						cMensagem  += STR0281 + oMdlTFF:GetValue('TFF_TURNO') +  Chr(13) + Chr(10) + "" //Código do Turno
						cMensagem  += STR0282 + oMdlTFF:GetValue('TFF_DTURNO') +  Chr(13) + Chr(10) + "" // Turno
						cMensagem  += STR0283 + oMdlTFF:GetValue('TFF_CARGO') +  Chr(13) + Chr(10) + "" // Código do Cargo
						cMensagem  += STR0284 + oMdlTFF:GetValue('TFF_DCARGO') +  Chr(13) + Chr(10) + "" // Cargo
						cMensagem  += STR0285 + oMdlTFF:GetValue('TFF_ESCALA') +  Chr(13) + Chr(10) + "" // Código da Escala
						cMensagem  += STR0286 + oMdlTFF:GetValue('TFF_NOMESC') +  Chr(13) + Chr(10) + "" // Escala
					Else
						If cCodLoc != oMdlTFL:GetValue('TFL_CODIGO')	
							cMensagem  += STR0272 + oMdlTFL:GetValue('TFL_CODIGO') + Chr(13) + Chr(10) + "" // Local de Atendimento
							cMensagem  += STR0273 + oMdlTFF:GetValue('TFF_COD') +  Chr(13) + Chr(10) + "" // Recursos Humanos
							cMensagem  += STR0274 + oMdlTFF:GetValue('TFF_ITEM') +  Chr(13) + Chr(10) + "" // Item
							cMensagem  += STR0275 + oMdlTFF:GetValue('TFF_PRODUT') +  Chr(13) + Chr(10) + "" // Código do Produto
							cMensagem  += STR0249 + oMdlTFF:GetValue('TFF_DESCRI') +  Chr(13) + Chr(10) + "" //Produto
							cMensagem  += STR0276 + cValToChar(oMdlTFF:GetValue('TFF_QTDVEN')) +  Chr(13) + Chr(10) +  "" //Quantidade
							cMensagem  += STR0277 + dToC(oMdlTFF:GetValue('TFF_PERINI')) +  Chr(13) + Chr(10) + "" //Data Inicial
							cMensagem  += STR0278 + dToC(oMdlTFF:GetValue('TFF_PERFIM')) +  Chr(13) + Chr(10) +  "" // Data Final
							cMensagem  += STR0279 + oMdlTFF:GetValue('TFF_FUNCAO') +  Chr(13) + Chr(10) + "" // Código da Função
							cMensagem  += STR0280 + oMdlTFF:GetValue('TFF_DFUNC') +  Chr(13) + Chr(10) + "" // Função
							cMensagem  += STR0281 + oMdlTFF:GetValue('TFF_TURNO') +  Chr(13) + Chr(10) + "" //Código do Turno
							cMensagem  += STR0282 + oMdlTFF:GetValue('TFF_DTURNO') +  Chr(13) + Chr(10) + "" // Turno
							cMensagem  += STR0283 + oMdlTFF:GetValue('TFF_CARGO') +  Chr(13) + Chr(10) + "" // Código do Cargo
							cMensagem  += STR0284 + oMdlTFF:GetValue('TFF_DCARGO') +  Chr(13) + Chr(10) + "" // Cargo
							cMensagem  += STR0285 + oMdlTFF:GetValue('TFF_ESCALA') +  Chr(13) + Chr(10) + "" // Código da Escala
							cMensagem  += STR0286 + oMdlTFF:GetValue('TFF_NOMESC') +  Chr(13) + Chr(10) + "" // Escala
						Else
							cMensagem  += STR0273 + oMdlTFF:GetValue('TFF_COD') +  Chr(13) + Chr(10) + "" // Recursos Humanos
							cMensagem  += STR0274 + oMdlTFF:GetValue('TFF_ITEM') +  Chr(13) + Chr(10) + "" // Item
							cMensagem  += STR0275 + oMdlTFF:GetValue('TFF_PRODUT') +  Chr(13) + Chr(10) + "" // Código do Produto
							cMensagem  += STR0249 + oMdlTFF:GetValue('TFF_DESCRI') +  Chr(13) + Chr(10) + "" //Produto
							cMensagem  += STR0276 + cValToChar(oMdlTFF:GetValue('TFF_QTDVEN')) +  Chr(13) + Chr(10) +  "" //Quantidade
							cMensagem  += STR0277 + dToC(oMdlTFF:GetValue('TFF_PERINI')) +  Chr(13) + Chr(10) + "" //Data Inicial
							cMensagem  += STR0278 + dToC(oMdlTFF:GetValue('TFF_PERFIM')) +  Chr(13) + Chr(10) +  "" // Data Final
							cMensagem  += STR0279 + oMdlTFF:GetValue('TFF_FUNCAO') +  Chr(13) + Chr(10) + "" // Código da Função
							cMensagem  += STR0280 + oMdlTFF:GetValue('TFF_DFUNC') +  Chr(13) + Chr(10) + "" // Função
							cMensagem  += STR0281 + oMdlTFF:GetValue('TFF_TURNO') +  Chr(13) + Chr(10) + "" //Código do Turno
							cMensagem  += STR0282 + oMdlTFF:GetValue('TFF_DTURNO') +  Chr(13) + Chr(10) + "" // Turno
							cMensagem  += STR0283 + oMdlTFF:GetValue('TFF_CARGO') +  Chr(13) + Chr(10) + "" // Código do Cargo
							cMensagem  += STR0284 + oMdlTFF:GetValue('TFF_DCARGO') +  Chr(13) + Chr(10) + "" // Cargo
							cMensagem  += STR0285 + oMdlTFF:GetValue('TFF_ESCALA') +  Chr(13) + Chr(10) + "" // Código da Escala
							cMensagem  += STR0286 + oMdlTFF:GetValue('TFF_NOMESC') +  Chr(13) + Chr(10) + "" // Escala
						EndIf
					EndIf		
					cCodLoc := oMdlTFL:GetValue('TFL_CODIGO')
				EndIf
				If isInCallStack("At870GerOrc") .AND. oMdlTFF:isDeleted() .AND. oMdlTFF:GetValue("TFF_COBCTR") == "2"
					aArea := GetArea()
					DbSelectArea("ABQ")
					ABQ->(DbSetOrder(3))
					If ABQ->( dbSeek( xFilial("ABQ") + oMdlTFF:GetValue("TFF_COD") + xFilial("TFF") ) )
						RecLock( "ABQ", .F. )
						ABQ->( dbDelete() )
						ABQ->( MsUnlock() )
					EndIf
					RestArea(aArea)
				EndIf
				If lAtuCod
					For nI := 1 To oMdlTFU:Length()
						oMdlTFU:GoLine(nI)
						If !oMdlTFU:IsDeleted() .And. !Empty(oMdlTFU:GetValue('TFU_CODABN')) .And. !oMdlTFU:IsInserted()
							If isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi")
								If isInCallStack("AT870RvPlC")
									cNewCod := oMdlTFU:GetValue("TFU_CODIGO")
								Else
									cNewCod := CriaVar("TFU_CODIGO",.T.)
								EndIF
								If isInCallStack("AT870RvPlC")
									Aadd(aRecSubCod, {"TFU",oMdlTFU:GetValue("TFU_CODREL"),cNewCod})
								Else
									Aadd(aRecSubCod, {"TFU",oMdlTFU:GetValue("TFU_CODIGO"),cNewCod})
								EndIf
								oMdlTFU:LoadValue("TFU_CODIGO",cNewCod)
							Else
								oMdlTFU:LoadValue("TFU_CODIGO",CriaVar("TFU_CODIGO",.T.))
							EndIf
						EndIf
					Next nI
				EndIf
				If !lOrcPrc 
					If lAtuCod
						If !oMdlTFF:IsDeleted() .And. !Empty(oMdlTFF:GetValue('TFF_PRODUT')) .And. !oMdlTFF:IsInserted()
							If isInCallStack("AT870RvPlC")
								cNewCod := oMdlTFF:GetValue("TFF_COD")
							Else
								cNewCod := CriaVar("TFF_COD",.T.)
							EndIf
							If isInCallStack("AT870RvPlC")
								Aadd(aRecSubCod, {"TFF",oMdlTFF:GetValue("TFF_CODREL"),cNewCod})
							Else
								Aadd(aRecSubCod, {"TFF",oMdlTFF:GetValue("TFF_COD"),cNewCod})
							EndIf
							oMdlTFF:LoadValue("TFF_COD",cNewCod)
							If isInCallStack("AT870PlaRe")
								oMdlTFF:LoadValue("TFF_CONTRT", "")
							EndIf
							If lRevi .AND. !(isInCallStatck("AT870PlaRe"))
								At740UpSLY(aRecSubCod[Len(aRecSubCod)][2]   ,aRecSubCod[Len(aRecSubCod)][3])
							EndIf
						EndIf
					EndIf
					For nX := 1 To oMdlTFG:Length()
						oMdlTFG:GoLine(nX)
						If FindFunction("TecBHasCrn") .AND. TecBHasCrn()
							If oMdlTFG:isDeleted() .OR. oMdlTFL:isDeleted() .OR. oMdlTFF:isDeleted()
								Tec740IExc(oModel:GetValue( 'TFJ_REFER', 'TFJ_CODIGO'),;
										/*cTFL*/,;
										/*cTFF*/,;
										oMdlTFG:GetValue("TFG_COD"),;
										/*cTFH*/,;
										oModel:GetOperation())
							EndIf
						EndIf
						If IsInCallStack("At870GerOrc") .AND. oMdlTFG:GetValue("TFG_COBCTR") == "2" .AND.;
						 		!Empty(oMdlTFG:GetValue('TFG_PRODUT')) .AND. !(oMdlTFG:IsDeleted())
							If oMdlTFG:IsInserted()
								oMdlTFG:LoadValue('TFG_SLD', oMdlTFG:GetValue('TFG_QTDVEN') )
								oMdlTFG:LoadValue("TFG_CONTRT", oMdlTFL:GetValue("TFL_CONTRT"))
								oMdlTFG:LoadValue("TFG_CONREV", oMdlTFL:GetValue("TFL_CONREV"))
							Else
								At870revMt(oModel,"TFG",oMdlTFG:GetValue("TFG_COD"))
							EndIf
						Endif
						If lAtuCod
							If !oMdlTFG:IsDeleted() .And. !Empty(oMdlTFG:GetValue('TFG_PRODUT')) .And. !oMdlTFG:IsInserted()
								If lRevi
									At870revMt(oModel,"TFG",oMdlTFG:GetValue("TFG_COD"))
								EndIf
								If isInCallStack("AT870RvPlC")
									cNewCod := oMdlTFG:GetValue("TFG_COD")
								Else
									cNewCod := CriaVar("TFG_COD",.T.)
								EndIf
								If isInCallStack("AT870RvPlC")
									Aadd(aRecSubCod, {"TFG",oMdlTFG:GetValue("TFG_CODREL"),cNewCod})
								Else
									Aadd(aRecSubCod, {"TFG",oMdlTFG:GetValue("TFG_COD"),cNewCod})
								EndIf
								oMdlTFG:LoadValue("TFG_COD",cNewCod)
								If isInCallStack("AT870PlaRe")
									oMdlTFG:LoadValue("TFG_CONTRT", "")
								EndIf
							ElseIf !Empty(oMdlTFG:GetValue('TFG_PRODUT')) .And. oMdlTFG:IsInserted()
								oMdlTFG:LoadValue('TFG_SLD', oMdlTFG:GetValue('TFG_QTDVEN') )
							EndIf
						EndIf
					Next nX
					For nX := 1 To oMdlTFH:Length()
						oMdlTFH:GoLine(nX)
						If FindFunction("TecBHasCrn") .AND. TecBHasCrn()
							If oMdlTFH:isDeleted() .OR. oMdlTFL:isDeleted() .OR. oMdlTFF:isDeleted()
								Tec740IExc(oModel:GetValue( 'TFJ_REFER', 'TFJ_CODIGO'),;
										/*cTFL*/,;
										/*cTFF*/,;
										/*cTFG*/,;
										oMdlTFH:GetValue("TFH_COD"),;
										oModel:GetOperation())
							EndIf
						EndIf
						If IsInCallStack("At870GerOrc") .AND. oMdlTFH:GetValue("TFH_COBCTR") == "2" .AND.;
						 		!Empty(oMdlTFH:GetValue('TFH_PRODUT')) .AND. !(oMdlTFH:IsDeleted())
							If oMdlTFH:IsInserted()
								oMdlTFH:LoadValue("TFH_CONTRT", oMdlTFL:GetValue("TFL_CONTRT"))
								oMdlTFH:LoadValue("TFH_CONREV", oMdlTFL:GetValue("TFL_CONREV"))
								oMdlTFH:LoadValue('TFH_SLD', oMdlTFH:GetValue('TFH_QTDVEN') )
							Else
								At870revMt(oModel,"TFH",oMdlTFH:GetValue("TFH_COD"))
							EndIf
						EndIf
						If lAtuCod
							If !oMdlTFH:IsDeleted() .And. !Empty(oMdlTFH:GetValue('TFH_PRODUT')) .And. !oMdlTFH:IsInserted()
								If lRevi
									At870revMt(oModel,"TFH",oMdlTFH:GetValue("TFH_COD"))
								EndIf
								If isInCallStack("AT870RvPlC")
									cNewCod := oMdlTFH:GetValue("TFH_COD")
								Else
									cNewCod := CriaVar("TFH_COD",.T.)
								EndIf
								If isInCallStack("AT870RvPlC")
									Aadd(aRecSubCod, {"TFH",oMdlTFH:GetValue("TFH_CODREL"),cNewCod})
								Else
									Aadd(aRecSubCod, {"TFH",oMdlTFH:GetValue("TFH_COD"),cNewCod})
								EndIf
								oMdlTFH:LoadValue("TFH_COD",cNewCod)
								If isInCallStack("AT870PlaRe")
									oMdlTFH:LoadValue("TFH_CONTRT", "")
								EndIf
							ElseIf !Empty(oMdlTFH:GetValue('TFH_PRODUT')) .And. oMdlTFH:IsInserted()
								oMdlTFH:LoadValue('TFH_SLD', oMdlTFH:GetValue('TFH_QTDVEN') )
							EndIf
						EndIf
					Next nX
				EndIf
				// pesquisa os produtos que não possuem registro criado na tabela SB2
				At740AvSb2(aCriaSb2, oModel)
				If oMdlTFF:GetValue("TFF_COBCTR") == "2" .And. ;
						IsInCallStack("At870GerOrc") // Verifica as operações dos itens extras do contrato
					If oMdlTFF:isInserted() .AND. !(isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") )
						oMdlTFF:LoadValue("TFF_CONTRT", oMdlTFL:GetValue("TFL_CONTRT"))
						oMdlTFF:LoadValue("TFF_CONREV", oMdlTFL:GetValue("TFL_CONREV"))
					EndIf
					lRecLock := At740VldTFF(	oMdlTFL:GetValue("TFL_CONTRT"),;
												oMdlTFF:GetValue("TFF_COD"),;
													xFilial("TFF", cFilAnt))
					If !(oMdlTFF:isDeleted())
						If !lRecLock  .and. !oMdlTFF:isInserted() .AND. oModel:GetModel('TFJ_REFER'):GetValue('TFJ_CNTREC') <> "1" 
							aAreaTFF := TFF->(GetArea())
							TFF->(DbSetOrder(1))
							If TFF->(DbSeek(xFilial("TFF")+ oMdlTFF:GetValue("TFF_COD")))
								aTFFOrg := { 	TFF->TFF_FILIAL, ; //1
												TFF->TFF_COD,  ; //2
												TFF->TFF_CALEND,; //3
												TFF->TFF_TURNO,; //4
												TFF->TFF_ESCALA, ;//5
												IIF(Empty(TFF->TFF_SEQTRN), "01", TFF->TFF_SEQTRN), ;//6
												TFF->TFF_PERINI, ; //7
												TFF->TFF_PERFIM, ;//8
												TFF->TFF_QTDVEN,; //9
												TFF->TFF_CALEND ,; //10
												oMdlTFF:GetValue("TFF_CALEND") ,;//11
												oMdlTFF:GetValue("TFF_ESCALA")  }  //12
							EndIf
							RestArea(aAreaTFF)
						EndIf
						Aadd(aItemRH,{ oMdlTFF:GetValue("TFF_PRODUT"),; //1
										oMdlTFF:GetValue("TFF_CARGO")	,; //2
										oMdlTFF:GetValue("TFF_FUNCAO"),;//3
										oMdlTFF:GetValue("TFF_PERINI"),;//4
										oMdlTFF:GetValue("TFF_PERFIM"),;//5
										oMdlTFF:GetValue("TFF_TURNO")	,;//6
										oMdlTFF:GetValue("TFF_QTDVEN"),;//7
										oMdlTFF:GetValue("TFF_COD"),;//8
										oMdlTFF:GetValue("TFF_SEQTRN"),;//9
										lRecLock,;//10
										xFilial("TFF", cFilAnt),;//11
										aClone(aTFFOrg),; //12
										IIF(TecABBPRHR(), TecConvHr(oMdlTFF:GetValue("TFF_QTDHRS")), 0),;//13
										Iif( (TFF->( ColumnPos("TFF_RISCO")) > 0 ), oModel:GetModel("TFF_RH"):GetValue("TFF_RISCO"), "" ) } ) //14
						aTFFOrg := {}
					EndIf
				EndIf
			Next nRHs
			If Len(aItemRH) > 0 // Cria a configuração de alocação para os itens extras
				At850CnfAlc(	oMdlTFL:GetValue("TFL_CONTRT"),;
								oMdlTFL:GetValue("TFL_LOCAL"), aItemRH, , ,.F., oModel:GetModel('TFJ_REFER'):GetValue('TFJ_CNTREC') == "1"  )
				//Cria a integração para o MDT
				If lMdtGS .And. TFF->( ColumnPos("TFF_RISCO")) > 0
					At740TarEx(oModel:GetModel("TFL_LOC"):GetValue("TFL_LOCAL"),aItemRH)
				EndIf
			Endif
			aItemRH := {}
		Next nLocais
		FwRestRows( aRows )
		// Captura e repassa quando é atualização da vistoria
		aVistoria := N600GetVis()
		// não define a origem como vistoria quando está importando para a proposta comercial
		If aVistoria[1] .And. IsInCallStack("A600IMPVIS")
			aVistoria[1] := .F.
		EndIf
		If lFillPropVist
			SetDadosOrc( aVistoria[1], aVistoria[2], oModel )
		EndIf
		If isInCallStatck("AplicaRevi")
			ATTOrcPla( oModel, cContrato, cRevisa )
		EndIf
		cCodTfj := oModel:GetValue( 'TFJ_REFER', 'TFJ_CODIGO')
		If  TFJ->(ColumnPos('TFJ_APRVOP')) > 0 .And. TFJ->TFJ_APRVOP != "2"
			lAprovOp := .T.
		Endif
		If ( lRet := FwFormCommit( oModel ) )
			If lAtucod
				At740UCdSb(aRecSubCod, cCodTfj)
			EndIf
			aEnceCpos := {}
		EndIf
		//--------------------------------------------
		//  Cria o saldo inicial dos produtos não encontrados na SB2
		For nMateriais := 1 To Len( aCriaSb2 )
			CriaSb2( aCriaSb2[nMateriais,1], aCriaSb2[nMateriais,2] )
		Next nMateriais
		//--------------------------------------------
		//  Chama a rotina para cancelamento das reservas
		If lRet .And. Len(aCancReserv) > 0
			At740FinRes( oModel, .T. )
		EndIf
		//---------------------------------------------
		//  Elimina as informações de controle do orçamento com precificação
		If lOrcPrc
			AT740FGXML(,,.T.)
			At600STabPrc( "", "" )
		EndIf
		If lRet .And. isInCallStatck("At870Revis") .And. !SuperGetMv("MV_ORCPRC",,.F.) .And.;
		 	SuperGetMv("MV_GSAPROV",,"2") == "1" .And. TFJ->(ColumnPos('TFJ_APRVOP')) > 0
			If lAprovOp
				DbSelectArea("TFJ")
				aAreaTFJ := TFJ->(GetArea())
				TFJ->(DbSetOrder(1))
				If TFJ->(DbSeek(xFilial("TFJ")+cCodTfj))
					RecLock('TFJ',.F.)
					If At740AltOp(oModel)
						TFJ->TFJ_APRVOP := "2"
					Else
						TFJ->TFJ_APRVOP := "1"
					Endif
					TFJ->(MsUnlock())
				Endif
				RestArea(aAreaTFJ)
			Endif
		Endif
	EndIf
Else
	cXmlDados := ( oModel:GetXmlData(Nil, Nil, Nil, Nil, Nil, .T. ))
EndIf
If Type('nSaveSx8Len') <> 'U'
	While ( GetSx8Len() > nSaveSx8Len )
		ConfirmSX8()
	End
EndIf
cXmlCalculo  := ''
If lOrcPrc
	at740ClSht()
EndIf
If lRet .AND. isInCallStack("At190dGrOrc") 
	EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventID,FW_EV_LEVEL_INFO,"",STR0269,cMensagem,.F.)
EndIf

Return lRet

/*/{Protheus.doc} At740AvSb2
	Verifica se os produtos indicados nos materiais possuem saldo indicado na tabela SB2
@sample 	At740AvSb2(aCriaSb2, oModel)
@since		20/10/2015
@version	P12
@param aCriaSB2, Array, variável que conterá a lista no formato { codigo produto, código local } que deverá ter o conteúdo gerado
@param oModelGeral, Objeto, modelo do tipo TECA740 ou TECA740F para avaliação dos produtos sem o registro de saldo na tabela SB2
/*/
Static Function At740AvSb2( aCriaSb2, oModelGeral )

Local nMateriais := 0
Local oMdlParte  := Nil

oMdlParte := oModelGeral:GetModel('TFG_MI')
For nMateriais := 1 To oMdlParte:Length()

	oMdlParte:GoLine( nMateriais )

	If !oMdlParte:IsDeleted() .And. ;
		aScan( aCriaSb2, {|pos| pos[1]==oMdlParte:GetValue('TFG_PRODUT') } ) == 0 .And. ;
		SB1->( DbSeek( xFilial('SB1')+oMdlParte:GetValue('TFG_PRODUT') ) ) .And. ;
		SB2->( !DbSeek( xFilial('SB2')+SB1->(B1_COD+B1_LOCPAD) ) )

		aAdd( aCriaSb2, { SB1->B1_COD, SB1->B1_LOCPAD } )
	EndIf

Next nMateriais

oMdlParte := oModelGeral:GetModel('TFH_MC')
For nMateriais := 1 To oMdlParte:Length()
	oMdlParte:GoLine( nMateriais )

	If !oMdlParte:IsDeleted() .And. ;
		aScan( aCriaSb2, {|pos| pos[1]==oMdlParte:GetValue('TFH_PRODUT') } ) == 0 .And. ;
		SB1->( DbSeek( xFilial('SB1')+oMdlParte:GetValue('TFH_PRODUT') ) ) .And. ;
		SB2->( !DbSeek( xFilial('SB2')+SB1->(B1_COD+B1_LOCPAD) ) )


		aAdd( aCriaSb2, { SB1->B1_COD, SB1->B1_LOCPAD } )
	EndIf
Next nMateriais

oMdlParte := oModelGeral:GetModel('TFJ_REFER')
// produto referência de RH
If !Empty(oMdlParte:GetValue('TFJ_GRPRH')) .And. ;
	aScan( aCriaSb2, {|pos| pos[1]==oMdlParte:GetValue('TFJ_GRPRH') } ) == 0 .And. ;
	SB1->( DbSeek( xFilial('SB1')+oMdlParte:GetValue('TFJ_GRPRH') ) ) .And. ;
	SB2->( !DbSeek( xFilial('SB2')+SB1->(B1_COD+B1_LOCPAD) ) )

	aAdd( aCriaSb2, { SB1->B1_COD, SB1->B1_LOCPAD } )
EndIf

// produto referência de MC
If !Empty(oMdlParte:GetValue('TFJ_GRPMC')) .And. ;
	aScan( aCriaSb2, {|pos| pos[1]==oMdlParte:GetValue('TFJ_GRPMC') } ) == 0 .And. ;
	SB1->( DbSeek( xFilial('SB1')+oMdlParte:GetValue('TFJ_GRPMC') ) ) .And. ;
	SB2->( !DbSeek( xFilial('SB2')+SB1->(B1_COD+B1_LOCPAD) ) )

	aAdd( aCriaSb2, { SB1->B1_COD, SB1->B1_LOCPAD } )
EndIf

// produto referência de MI
If !Empty(oMdlParte:GetValue('TFJ_GRPMI')) .And. ;
	aScan( aCriaSb2, {|pos| pos[1]==oMdlParte:GetValue('TFJ_GRPMI') } ) == 0 .And. ;
	SB1->( DbSeek( xFilial('SB1')+oMdlParte:GetValue('TFJ_GRPMI') ) ) .And. ;
	SB2->( !DbSeek( xFilial('SB2')+SB1->(B1_COD+B1_LOCPAD) ) )

	aAdd( aCriaSb2, { SB1->B1_COD, SB1->B1_LOCPAD } )
EndIf

// produto referência de LE
If !Empty(oMdlParte:GetValue('TFJ_GRPLE')) .And. ;
	aScan( aCriaSb2, {|pos| pos[1]==oMdlParte:GetValue('TFJ_GRPLE') } ) == 0 .And. ;
	SB1->( DbSeek( xFilial('SB1')+oMdlParte:GetValue('TFJ_GRPLE') ) ) .And. ;
	SB2->( !DbSeek( xFilial('SB2')+SB1->(B1_COD+B1_LOCPAD) ) )

	aAdd( aCriaSb2, { SB1->B1_COD, SB1->B1_LOCPAD } )
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740Canc
	Bloco no momento de cancelamento dos dados da rotina
@sample 	At740Canc()
@since		03/10/2013
@version	P11.90
@return 	oModel, Object, Classo do modelo de dados MpFormModel
/*/
//------------------------------------------------------------------------------
Function At740Canc( oMdl,b,c,d )

Local lOrcPrc	 := SuperGetMv("MV_ORCPRC",,.F.)

If Type('nSaveSx8Len') <> 'U'
	While ( GetSx8Len() > nSaveSx8Len )
		RollBackSX8()
	End
EndIf

cXmlCalculo  := ''

If Len(aCancReserv) > 0
	At740FinRes( oMdl, .F. )
EndIf
//  Só chama a limpeza das variáveis static do 740F quando não está copiando os dados
// para o objeto sem interface ligado ao modelo da proposta comercial
If lOrcPrc .And. !IsInCallStack('At600SeAtu')
	AT740FGXML(nil,nil,.T.)
EndIf

At740GSC(.F.)

If isInCallStack("a745IncOrc") .OR. (isInCallStack("At870Revis") .AND. oMdl:GetOperation() == MODEL_OPERATION_INSERT) .OR.;
		(oMdl:GetOperation() == MODEL_OPERATION_UPDATE .AND. isInCallStack("AplicaRevi"))
	If FindFunction("TecBHasCrn") .AND. TecBHasCrn()
		Tec740IExc(oMdl:GetValue("TFJ_REFER","TFJ_CODIGO"),;
		/*cTFL*/, /*cTFF*/, /*cTFG*/, /*cTFH*/, /*nOper*/)
	EndIf
EndIf

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} AtIniPadMvc
	Função para inicializador padrão genérico de descrição ou conteúdos relacionados
a uma chave

@sample 	AtIniPadMvc( "TECA740", "TEV_ADICIO", cTab, nInd, cKey, cCampo, cFormula )
@sample 	AtIniPadMvc( "TECA740", "TEV_ADICIO", , , , , 'FWFLDGET("TEV_VLRUNI") * FWFLDGET("TEV_QTDE")' )

@since		23/09/2013
@version	P11.90

@return 	xConteudo, Qualquer, retorna o conteúdo conforme a pesquisa ou tipo do campo

@param  	cIdMdlMain, Objeto, id do objeto do modelo de dados principal
@param  	cIdMdlGrd, Objeto, id do objeto do modelo do grid
@param  	cCampo, Caracter, Conteúdo a ser retornado quando a pesquisa ocorrer com sucesso
				ou o campo alvo para recepção do valor (quando usado fórmula)
@param  	cTab, Caracter, nome da tabela para pesquisa
@param  	nInd, Numerico, índice para ordem na busca do registro
@param  	cKey, Caracter, chave de pesquisa do registro
@param  	cFormula, Caracter, conteúdo para ser macro executado
/*/
//------------------------------------------------------------------------------
Function AtIniPadMvc( cIdMdlMain, cIdMdlGrd, cCampo, cTab, nInd, cKey, cFormula, cTipoDefault )

Local xConteudo := Nil
Local cTipo     := ""
Local oMdlAtivo := FwModelActive()
Local lOrcPrc 	:= SuperGetMv("MV_ORCPRC",,.F.)
Local lOrcServ	:= cIdMdlMain $ "TECA740|TECA740F"
Local lFacilit 	:= cIdMdlMain == "TECA984"
Local lExecuta 	:= .F.
Local lContinua	:= .T.
Local cCodAux 	:= ""

cTipo := If( cCampo<>Nil, GetSx3Cache( PadR( cCampo, 10 ), 'X3_TIPO' ), If( cTipoDefault<>Nil, cTipoDefault, Nil ) )

If !Empty(cTipo)
	If cTipo $ 'C#M'
		xConteudo := ''
	ElseIf cTipo == 'N'
		xConteudo := 0
	ElseIf cTipo == 'D'
		xConteudo := CtoD('')
	ElseIf cTipo == 'L'
		xConteudo := .F.
	EndIf
Else
	xConteudo := ''
EndIf

If !lOrcPrc
	If (!isInCallStack("AtLoadTFH") .AND. cIdMdlGrd == 'TFH_MC') .OR. (!isInCallStack("AtLoadTFG") .AND. cIdMdlGrd == 'TFG_MI')
		lContinua := .F.
	EndIf
EndIf

If lContinua .AND. oMdlAtivo <> Nil .And. ;
	( oMdlAtivo:GetId() == cIdMdlMain .Or. ( lOrcPrc .And. oMdlAtivo:GetId() == "TECA740F" ) ).And. ;
	(oMdlAtivo:GetModel( cIdMdlGrd ) <> Nil .And. (oMdlAtivo:GetModel( cIdMdlGrd ):GetOperation() <> MODEL_OPERATION_INSERT) )

	If oMdlAtivo:GetModel( cIdMdlGrd ):GetLine() == 0 // a linha posicionada do grid
		If lOrcServ
			If (Left( cIdMdlGrd, 3 ) == "TFL" .Or. !oMdlAtivo:GetModel( "TFL_LOC" ):IsInserted())
				If Left( cIdMdlGrd, 3 ) <> "TFL"
					cCodAux := oMdlAtivo:GetModel("TFL_LOC"):GetValue("TFL_CODIGO")
				Else
					cCodAux := ""
				EndIf
				lExecuta := At740IsOrc( cIdMdlGrd, TFJ->TFJ_CODIGO, cCodAux, oMdlAtivo )
			EndIf
		ElseIf lFacilit
			cCodAux := If( lOrcPrc, "", TWN->TWN_ITEMRH )
			lExecuta := At984IsFac(cIdMdlGrd, TWM->TWM_CODIGO, cCodAux)
		Else
			lExecuta := .T.
		EndIf

		If lExecuta
			If !Empty( cFormula )
				If !( 'FWFLDGET' $ Upper( cFormula ) )  // verifica se tem get de conteúdo da linha do model
					xConteudo := &cFormula
				EndIf
			Else
				cKey := &cKey
				xConteudo := GetAdvFVal( cTab, cCampo, cKey, nInd, xConteudo )
			EndIf
		EndIf
	ElseIf !(oMdlAtivo:GetModel( cIdMdlGrd ):IsInserted())
		If !Empty( cFormula )
			xConteudo := &cFormula
		EndIf
	EndIf
EndIf

Return xConteudo

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740TrgGer
	Função para preencher o conteúdo de grids superiores com a somatória

@sample 	At740TrgGer( "CALC_TFH", "TOT_MC", "TFF_RH", "TFF_TOTMC" )

@since		23/09/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740TrgGer( cMdlCalc, cCpoTot, cMdlCDom, cCpoCDOM, cCpoDesc )

Local nValor := 0
Local oMdl   := FwModelActive()

Default cCpoDesc := ''

If oMdl:GetId()=='TECA740' .Or. oMdl:GetId()=='TECA740F'
	nValor := oMdl:GetModel( cMdlCalc ):GetValue( cCpoTot )

	If !Empty( cCpoDesc )
		nValor := ( nValor * ( 1 - ( oMdl:GetModel( cMdlCDom ):GetValue( cCpoDesc ) / 100 ) ) )
	EndIf

	oMdl:GetModel( cMdlCDom ):SetValue( cCpoCDOM, nValor )

EndIf

Return 0


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740TrgABN


@sample 	At740TrgABN()

@since		23/09/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740TrgABN(cCodAbn)

Local cRetABN	 := ""
Local oMdl   	 := FwModelActive()
Local aAreaABN := ABN->(GetArea())
Default cCodAbn  := ""

If EMPTY( cCodAbn )
	If oMdl:GetId()=="TECA740" .Or. oMdl:GetId()=="TECA740F"

		cCodAbn := oMdl:GetModel( "TFU_HE" ):GetValue( "TFU_CODABN" )

		ABN->(dbSetOrder(1))
		If ABN->(dbSeek(xFilial("ABN")+cCodAbn))
			cRetABN := ABN->ABN_DESC
		EndIf

	EndIf
Else
	ABN->(dbSetOrder(1))
	If ABN->(dbSeek(xFilial("ABN")+cCodAbn))
		cRetABN := ABN->ABN_DESC
	EndIf
EndIf

RestArea(aAreaABN)

Return(cRetABN)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740TrgTEV
	Dispara o preenchimento do campo de unidade de medida
@sample 	At740TrgTEV()

@since		23/09/2013
@version	P11.90

@param   	cCpoOrigem, Caracter, Id do campo que disparou o gatilho
@return  	xRet, Qualquer, conteúdo a ser inserido no contra-domínio
/*/
//------------------------------------------------------------------------------
Function At740TrgTEV( cCpoOrigem )

Local xRet := Nil

If cCpoOrigem == 'TEV_MODCOB'

	If M->TEV_MODCOB == '2'  // Modo de Cobrança igual a disponibilidade
		xRet := 'UN'
	ElseIf M->TEV_MODCOB == '4' .Or. M->TEV_MODCOB == '5'  // Modo de Cobrança igual a horimetro
		xRet := 'HR'
	Else
		xRet := '  '
	EndIf

EndIf

Return xRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740DeBenefi
	Função executada no gatilho do código do benefício para captura da descrição

@sample 	At740DeBenefi()

@since		27/11/2013
@version	P11.90
/*/
//------------------------------------------------------------------------------
Function At740DeBenefi()

Local cRet := ' '

DbSelectArea('SX5')
SX5->( DbSetOrder( 1 ) )

If SX5->( DbSeek( xFilial("SX5")+"AZ"+M->ABP_BENEFI) )
	cRet := X5Descri()
EndIf

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados

@sample 	InitDados(  )

@since		23/09/2013
@version	P11.90

@param  	oMdlGer, Objeto, objeto geral do model que será alterado

/*/
//------------------------------------------------------------------------------
Static Function InitDados ( oMdlGer )

Local oMdlRh	:= oMdlGer:GetModel("TFF_RH")
Local oMdlHrExtr := oMdlGer:GetModel("TFU_HE")
Local oMdlMi		:=	oMdlGer:GetModel("TFG_MI")
Local oMdlLe		:=	oMdlGer:GetModel("TFI_LE")
Local oMdlMc		:= 	oMdlGer:GetModel("TFH_MC")
Local oMdlLoc		:= 	oMdlGer:GetModel("TFL_LOC")
Local aSaveRows := {}
Local cGsDsGcn	:= ""
Local oStrTFJ := oMdlGer:GetModel('TFJ_REFER'):GetStruct()
Local oStrTFF := oMdlRh:GetStruct()
Local oStrTFG := oMdlMi:GetStruct()
Local oStrTFH := oMdlMc:GetStruct()
Local oStrTFI := oMdlLE:GetStruct()
Local lTeca270	:= 	IsInCallStack("TECA270")
Local lVersion23	:= HasOrcSimp()
Local lOrcSim	:= SuperGetMv("MV_ORCSIMP",,'2') == '1' .AND. lVersion23
Local lGSRH := GSGetIns("RH")
Local lGSMIMC  :=  GSGetIns("MI")
Local lGSLE :=  GSGetIns("LE")
Local nX
Local nY
Local nZ
Local lGsOrcUnif := FindFunction("TecGsUnif") .And. TecGsUnif()
Local lGsOrcArma := FindFunction("TecGsArma") .And. TecGsArma()

If ExistBlock('AT740INITD')
	ExecBlock('AT740INITD', .F., .F., {oMdlGer} )
EndIf

If oMdlGer:GetOperation() == MODEL_OPERATION_INSERT .And. !IsInCallStack("TECA870")
	cGsDsGcn	:= SuperGetMv("MV_GSDSGCN",,"2")
Else
	cGsDsGcn	:= TFJ->TFJ_DSGCN
EndIf

If lVersion23
	If !IsInCallStack("At270Orc")
		IF lTeca270 .AND. lOrcSim

			oMdlGer:GetModel("TFJ_REFER"):LoadValue("TFJ_CODVIS",M->AAT_CODVIS)

		EndIf
	EndIf
EndIf

oStrTFH:SetProperty('TFH_TES',MODEL_FIELD_OBRIGAT, .F. )
oStrTFG:SetProperty('TFG_TES',MODEL_FIELD_OBRIGAT, .F. )

If cGsDsGcn == "1"
	//Retira a obrigatoriedade dos campos
	oStrTFJ:SetProperty('TFJ_GRPRH',MODEL_FIELD_OBRIGAT,.F.)
	oStrTFJ:SetProperty('TFJ_GRPMI',MODEL_FIELD_OBRIGAT,.F.)
	oStrTFJ:SetProperty('TFJ_GRPMC',MODEL_FIELD_OBRIGAT,.F.)
	oStrTFJ:SetProperty('TFJ_GRPLE',MODEL_FIELD_OBRIGAT,.F.)
	oStrTFJ:SetProperty('TFJ_TES', MODEL_FIELD_OBRIGAT,.F.)
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
	If !lGSRH .Or. !lGSMIMC
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

aSaveRows := FwSaveRows()

nTLuc := oMdlGer:GetModel("TFJ_REFER"):GetValue("TFJ_LUCRO")
nTAdm := oMdlGer:GetModel("TFJ_REFER"):GetValue("TFJ_ADM")

//Muda  valor do TFJ_GESMAT
If oMdlGer:GetModel("TFJ_REFER"):GetValue("TFJ_GESMAT") == "3"
	At740Set(oMdlGer:GetModel("TFJ_REFER"), "TFJ_GESMAT", "2")
EndIf
If oMdlGer:GetOperation() <> MODEL_OPERATION_DELETE
	If  oMdlGer:GetModel('TOTAIS') <> NIL
		At740Set(oMdlGer:GetModel("TFJ_REFER"), 'TFJ_TOTRH', oMdlGer:GetModel('TOTAIS'):GetValue('TOT_RH'))
		At740Set(oMdlGer:GetModel("TFJ_REFER"), 'TFJ_TOTMI', oMdlGer:GetModel('TOTAIS'):GetValue('TOT_MI'))
		At740Set(oMdlGer:GetModel("TFJ_REFER"), 'TFJ_TOTMC', oMdlGer:GetModel('TOTAIS'):GetValue('TOT_MC'))
		At740Set(oMdlGer:GetModel("TFJ_REFER"), 'TFJ_TOTLE', oMdlGer:GetModel('TOTAIS'):GetValue('TOT_LE'))
		If lGsOrcUnif
			At740Set(oMdlGer:GetModel("TFJ_REFER"), 'TFJ_TOTUNI', oMdlGer:GetModel('TOTAIS'):GetValue('TOT_TXP'))
		Endif
		If lGsOrcArma
			At740Set(oMdlGer:GetModel("TFJ_REFER"), 'TFJ_TOTARM', oMdlGer:GetModel('TOTAIS'):GetValue('TOT_TXQ'))		
		Endif
	EndIf
EndIf

If VALTYPE(oMdlHrExtr) == 'O' .AND. oMdlHrExtr:GetOperation() <> MODEL_OPERATION_DELETE
	At740HrEtr(oMdlHrExtr)
EndIf

FwRestRows( aSaveRows )

If IsInCallStack("At870GerOrc") // Verifica as operações dos itens extras do contrato
	oMdlGer:GetModel("TFL_LOC"):SetNoInsertLine(.T.)
	oMdlGer:GetModel("TFL_LOC"):SetNoDeleteLine(.T.)
	oMdlGer:GetModel("TFL_LOC"):SetNoUpdateLine(.T.)
EndIf

If oMdlGer:GetOperation() <> MODEL_OPERATION_INSERT
	oMdlGer:GetModel('TFL_LOC'):GoLine( 1 )
EndIf

If oMdlGer:GetOperation() == MODEL_OPERATION_VIEW
	oMdlGer:lModify := .F.
EndIf

If IsInCallStack("At870Revis") .OR. IsInCallStack("AT870PlaRe") 
	a740ChgLine()
	If IsInCallStack("At870Revis") .And. !IsInCallStack("At870EFTRV") .And. oMdlGer:GetOperation() == MODEL_OPERATION_INSERT
		a740AjDtEnc(oMdlLoc,oMdlRh)
	EndIf	
EndIf

If IsInCallStack("AT870PlaRe") .AND. oMdlGer:GetOperation() == MODEL_OPERATION_INSERT
	For nZ := 1 To oMdlLoc:Length()
		oMdlLoc:GoLine(nZ)
		oMdlLoc:LoadValue("TFL_MODPLA","2")
		For nY := 1 To oMdlRh:Length()
			oMdlRh:GoLine(nY)
			oMdlRh:LoadValue("TFF_MODPLA","2")

			If !EMPTY(oMdlMi:GetValue("TFG_PRODUT"))
				For nX := 1 To oMdlMi:Length()
					oMdlMi:GoLine(nX)
					oMdlMi:LoadValue("TFG_MODPLA","2")
				Next nX
				oMdlMi:GoLine(1)
			EndIf

			If !EMPTY(oMdlMc:GetValue("TFH_PRODUT"))
				For nX := 1 To oMdlMc:Length()
					oMdlMc:GoLine(nX)
					oMdlMc:LoadValue("TFH_MODPLA","2")
				Next nX
				oMdlMc:GoLine(1)
			EndIf

			If !EMPTY(oMdlHrExtr:GetValue("TFU_CODABN"))
				For nX := 1 To oMdlHrExtr:Length()
					oMdlHrExtr:GoLine(nX)
					oMdlHrExtr:LoadValue("TFU_MODPLA","2")
				Next nX
				oMdlHrExtr:GoLine(1)
			EndIf
		Next nY
		oMdlRh:GoLine(1)
	Next nZ
	oMdlLoc:GoLine(1)
EndIf

If oMdlGer:GetOperation() == MODEL_OPERATION_INSERT .Or. oMdlGer:GetOperation() == MODEL_OPERATION_UPDATE
	If SuperGetMv("MV_GSAPROV",,"2") == "1" .And. !SuperGetMv("MV_ORCPRC",,.F.) .And. TFJ->(ColumnPos('TFJ_APRVOP')) > 0 .And.;
		(Empty(oMdlGer:GetModel("TFJ_REFER"):GetValue("TFJ_APRVOP")) .Or. oMdlGer:GetModel("TFJ_REFER"):GetValue("TFJ_APRVOP") == "1")
		oMdlGer:GetModel("TFJ_REFER"):LoadValue("TFJ_APRVOP","2")
		If TFJ->(ColumnPos('TFJ_USAPRO')) > 0 .And. TFJ->(ColumnPos('TFJ_DTAPRO')) > 0 
			oMdlGer:LoadValue( 'TFJ_REFER', 'TFJ_USAPRO', "")
			oMdlGer:LoadValue( 'TFJ_REFER', 'TFJ_DTAPRO', sTod(""))
		Endif
	Endif
Endif
If lVersion23
	At740StSm(oMdlGer:GetModel("TFJ_REFER"))
EndIf

lCalcEnc := .F.

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740Set


@sample 	At740Set( oModel, cField, xValue)

@since		23/09/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740Set(oModel, cField, xValue, lAlwaysLoad)

Local lRet := .T.
Default lAlwaysLoad := .F.

If oModel:GetOperation() == MODEL_OPERATION_VIEW .Or. ;
		oModel:GetOperation() == MODEL_OPERATION_DELETE .Or.;
			lAlwaysLoad
	oModel:LoadValue( cField, xValue )
Else
	lRet := oModel:SetValue( cField, xValue )
EndIf
Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} At600IniTot


@sample 	AT600INITOT( "TFH_MC", "TFH_TOTAL" )

@since		23/09/2013
@version	P11.90

@param cMdlAlvo, Caractere, Id do modelo de dados grid com o campo para soma do conteúdo
@param cCpoSoma, Caractere, Campo alvo para somar o conteúdo
@param oMdlGer, Objeto, objeto do mvc para considerar para realizar a soma do conteúdo, default: FwModelActive()
@return nValor, Numérico, valor correspondente a soma dos valores no campo nas linhas
/*/
//------------------------------------------------------------------------------
Function At600IniTot( cMdlAlvo, cCpoSoma, oMdlGer, lVerCobCTR )

Local nValor    := 0
Local oMdlGrid  := Nil
Local nLinhaMdl := 0
Local aSaveRows := {}
Local lSoma
Default oMdlGer := FwModelActive()
Default lVerCobCTR := .T.
If oMdlGer <> Nil .And. (oMdlGer:GetId()=='TECA740' .Or. oMdlGer:GetId()=='TECA740F')

	aSaveRows := FwSaveRows()

	oMdlGrid := oMdlGer:GetModel(cMdlAlvo)
	If !oMdlGrid:IsEmpty()
		// ----------------------------------------------------
		//   Varre as linhas do grid para capturar o conteúdo dos campos
		For nLinhaMdl := 1 To oMdlGrid:Length()

			oMdlGrid:GoLine( nLinhaMdl )

			If !oMdlGrid:IsDeleted()
				lSoma := .T.

				If cMdlAlvo $ "TFG_MI|TFH_MC|TFF_RH"
					If oMdlGrid:GetValue( LEFT(cMdlAlvo,4)+"COBCTR" ) == '2' .AND. lVerCobCTR
						lSoma := .F.
					EndIf
				EndIf

				If lSoma
					nValor += oMdlGrid:GetValue(cCpoSoma)
				EndIf
			EndIf

		Next nLinhaMdl
	EndIf
	FwRestRows( aSaveRows )

EndIf

Return nValor

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740CpyMdl
	Realiza a cópia dos dados de um modelo para outro
evitando sobrepor conteudo de alguns campos, informados na exceção

@sample 	At740CpyMdl

@since		23/09/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740CpyMdl( oObjFrom, oObjTo )

Local lRet      := .T.
Local lOrcPrecif := SuperGetMv("MV_ORCPRC",,.F.)
Local oStrTFJ := oObjTo:GetModel('TFJ_REFER'):GetStruct()
Local oStrTFF := oObjTo:GetModel('TFF_RH'):GetStruct()
Local oStrTFG := oObjTo:GetModel('TFG_MI'):GetStruct()
Local oStrTFH := oObjTo:GetModel('TFH_MC'):GetStruct()
Local oStrTFI := oObjTo:GetModel('TFI_LE'):GetStruct()

FillModel( @lRet, 'TFJ_REFER', oObjFrom, @oObjTo, lOrcPrecif )

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} FillModel
	Função para preenchimento dos dados do modelo indicado pelos parâmetros e
identifica a necessidade de preenchimento de grid/modelos filhos

@sample 	FillModel

@since		23/09/2013
@version	P11.90

@param 		lRet, Logico, indice/define o status do processamento pela rotina (referência)
@param 		cIdMdl, Caracter, id do model a ser preenchido
@param 		oFrom, Objeto, Modelo de dados para cópia das informações
@param 		oTo, Objeto, Modelo de dados para inclusão das informações

/*/
//------------------------------------------------------------------------------
Static Function FillModel( lRet, cIdModl, oFrom, oTo, lOrcPrecif )

                      // ID_MODEL     CAMPO_CHAVE, LISTA_SUBMODELS
Local aElementos := { }
Local aNoCpos  := {'TFJ_CODIGO', 'TFJ_PREVIS', 'TFL_CODIGO', 'TFL_CODPAI', 'TFF_CODPAI', 'TFF_LOCAL', 'TFF_PROCES', 'TFG_COD', 'TFG_CODPAI', 'TFG_LOCAL', ;
						'TFH_COD', 'TFH_CODPAI', 'TFH_LOCAL','TFI_COD', 'TFI_CODPAI', 'TFI_LOCAL','ABP_ITRH', 'TEV_CODLOC', 'TFU_CODIGO', 'TFU_CODTFF',;
						'TFU_LOCAL','TGV_COD','TDT_COD','TDS_COD','TWO_CODORC','TWO_PROPOS','TWO_LOCAL' }
Local nPosElem := 0
Local nPosSub  := 0
Local oFromAux := 0
Local oToAux   := 0
Local nForTo   := 0
Local nSubMdls  := 0
Local aLocaisMdls := {}
Local aRhMdls 	:= {}

Default lOrcPrecif := .F.

// quando for o orçamento com precificação
// ajusta a estrutura hierárquica dos modelos deixando os materiais abaixo do local
If lOrcPrecif
	aLocaisMdls := { 'TFF_RH', 'TFG_MI', 'TFH_MC', 'TFI_LE', 'TWODETAIL' }
	aRhMdls := { 'ABP_BENEF', 'TFU_HE', 'TGV_RH', 'TDS_RH', 'TDT_RH' }
Else
	aLocaisMdls := { 'TFF_RH', 'TFI_LE', 'TWODETAIL' }
	aRhMdls := { 'ABP_BENEF', 'TFG_MI', 'TFH_MC', 'TFU_HE', 'TGV_RH', 'TDS_RH', 'TDT_RH' }
EndIf

                // ID_MODEL     CAMPO_CHAVE, LISTA_SUBMODELS
aElementos := { { 'TFJ_REFER' , ''         , { 'TFL_LOC' }} , ;
				{'TFL_LOC'   , 'TFL_LOCAL' , aLocaisMdls } , ;
					{'TFF_RH'    , 'TFF_PRODUT', aRhMdls } , ;
					{'ABP_BENEF' , 'ABP_BENEFI', {} }, ;
					{'TFG_MI'    , 'TFG_PRODUT', {} }, ;
					{'TFH_MC'    , 'TFH_PRODUT', {} }, ;
					{'TFU_HE'    , 'TFU_CODABN', {} }, ;
					{'TFI_LE'    , 'TFI_PRODUT', { 'TEV_ADICIO' } },  ;
					{'TEV_ADICIO', 'TEV_MODCOB', {} }, ;
					{'TGV_RH'    , 'TGV_CURSO' , {} }, ;
					{'TDS_RH'    , 'TDS_CODTCZ', {} }, ;
					{'TDT_RH'    , {'TDT_CODHAB','TDT_HABX5'}, {} }, ;
					{'TWODETAIL', 'TWO_CODFAC', {} } ;
					}
/*
	ID_MODEL - identificador do model para cópia dos dados
	CAMPO_CHAVE - campo para verificar se é necessário copiar o conteúdo da linha (somente utilizado quando for grid)
	LISTA_SUBMODELS -
*/

nPosElem := aScan( aElementos, {|x| x[1]==cIdModl} )
nPosSub  := 0

oFromAux := oFrom:GetModel( aElementos[nPosElem,1] )
oToAux   := oTo:GetModel( aElementos[nPosElem,1] )

//  caso os totalizadores estejam habilitados para a rotina
// inibe a cópia dos campos que são totalizados por gatilhos
If oToAux:ClassName()=='FWFORMGRID'

	For nForTo := 1 To oFromAux:Length()

		oFromAux:GoLine( nForTo )

		// verifica se o campo principal do grid está preenchido, ou seja
		// se há necessidade de copiar
		If !oFromAux:IsDeleted() .And. ;
			At740VlEmpty( aElementos[nPosElem,2], oFromAux )

			// testa quando é necessário adicionar uma nova linha
			If At740VlEmpty( aElementos[nPosElem,2], oToAux )
				oToAux:AddLine()
			EndIf

			lRet := AtCpyData( oFromAux, oToAux, aNoCpos )

			If lRet
				For nSubMdls := 1 To Len( aElementos[nPosElem,3] )
					cIdModl := aElementos[nPosElem,3,nSubMdls]

					FillModel( @lRet, cIdModl, oFrom, oTo, lOrcPrecif )

					If !lRet
						Exit
					EndIf

				Next nSubMdls

			EndIf

		EndIf

		If !lRet
			Exit
		EndIf

	Next nForTo

Else

	lRet := AtCpyData( oFromAux, oToAux, aNoCpos )

	If lRet
		For nSubMdls := 1 To Len( aElementos[nPosElem,3] )
			cIdModl := aElementos[nPosElem,3,nSubMdls]

			FillModel( @lRet, cIdModl, oFrom, oTo, lOrcPrecif  )

			If !lRet
				Exit
			EndIf

		Next nSubMdls

	EndIf

EndIf

Return

/*/{Protheus.doc} At740VlEmpty
	Função para verificar se o campo chave de preenchimento do grid está com conteúdo válido
@sample 	At740VlEmpty( aElementos[nPosElem,2], oFromAux )
@since		11/03/2016
@version	P2

@param 		xLista, Caracter ou Array, indica o campo ou a lista de campos a terem o conteúdo verificado
@param 		oMdlAlvo, Objeto FwFormGridModel ou FwFormFieldsModel, modelo de dados a receber a verificação do campo
@return 	lRet, Logico, indica se o campo está com conteúdo (.T.) ou não (.F.)
/*/
Static Function At740VlEmpty( xLista, oMdlAlvo )

Local lPreenchido := .F.
Local nI := 0

Default xLista := ""
// verifica o conteúdo no campo quando é caracter
If ValType(xLista)=="C" .And. !Empty(xLista) .And. !Empty(oMdlAlvo:GetValue(xLista))
	lPreenchido := .T.
// verifica o conteúdo nos campos quando é array
ElseIf ValType(xLista)=="A" .And. !Empty(xLista)

	For nI := 1 To Len(xLista)
		// ao identificar algum campo preenchido (condição OU para o preenchimento dos campos)
		// já encerra o loop
		lPreenchido := !Empty(oMdlAlvo:GetValue(xLista[nI]))
		If lPreenchido
			Exit
		EndIf
	Next nI
EndIf
Return lPreenchido

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740InPad

Função para inicializador padrão do total

@sample 	AtIniPadMvc()

@since		02/10/2013
@version	P11.90

@return 	nRet, retorna o resultado do cálculo

/*/
//------------------------------------------------------------------------------
Function At740InPad(oMdl)

Local aArea	:= GetArea()
Local oModel	:= If( oMdl == nil, FwModelActive(), oMdl)
Local oMdlRh	:= nil
Local nTotRh 	:= 0
Local nTotMI	:= 0
Local nTotMC	:= 0
Local nRet		:= 0
Local lExtra 	:= .F.	//item extra
Local nTotUni	:= 0
Local lGsOrcUnif := FindFunction("TecGsUnif") .And. TecGsUnif()
Local lGsOrcArma := FindFunction("TecGsArma") .And. TecGsArma()
Local nTotArm	 := 0

If oModel <> nil .and. oModel:GetID() $ 'TECA740;TECA740F'
	oMdlRh	:= oModel:GetModel("TFF_RH")
	nTotRh	:= oMdlRh:GetValue("TFF_SUBTOT")
	nTotMI	:= oMdlRh:GetValue("TFF_TOTMI")
	nTotMC	:= oMdlRh:GetValue("TFF_TOTMC")
	If lGsOrcUnif
		nTotUni	:= oMdlRh:GetValue("TFF_TOTUNI")
	Endif
	If lGsOrcArma
		nTotArm := oMdlRh:GetValue("TFF_TOTARM")
	Endif
	lExtra := (oMdlRh:GetValue("TFF_COBCTR") == '2')
EndIf

If !lExtra
	nRet := nTotRh+nTotMI+nTotMC+nTotUni+nTotArm
EndIf

RestArea(aArea)

Return nRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740InSub

Função para calcular SubTotal da Aba Recursos Humanos

@sample 	At740InSub()

@since		02/10/2013
@version	P12

@return 	nRet, retorna o resultado do cálculo

/*/
//------------------------------------------------------------------------------
Function At740InSub()
Local aArea	:= GetArea()
Local oModel	:= FwModelActive()
Local oMdlRh	:= oModel:GetModel("TFF_RH")
Local nQtde	:= 	oMdlRh:GetValue("TFF_QTDVEN")
Local nTotRh 	:= oMdlRh:GetValue("TFF_PRCVEN")
Local nLucro	:= oMdlRh:GetValue("TFF_TXLUCR")
Local nTxAdm	:= oMdlRh:GetValue("TFF_TXADM")
Local nRet		:= 0

//Arredondo valores conforme tamanho do campos campos
nLucro := Round(nLucro,TamSX3("TFF_TXLUCR")[2])
nTxAdm := Round(nTxAdm,TamSX3("TFF_TXADM")[2])

nRet := (nQtde*nTotRh)+nLucro+nTxAdm

RestArea(aArea)

Return nRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740CDesc

Função para cálcular o desconto do produto.

@sample 	At740CDesc(cMdlDom,cCmpQtd,cCmpVlr,cCmpDesc,cCmpAlvo)

@since		02/10/2013
@version	P11.90

@return 	nResp, Númerico, retorna o conteúdo do cálculo.

@param  	cMdlDom, Caracter, nome do modelo de dados principal
@param  	cCmpQtd, Caracter, nome do campo para cálculo
@param  	cCmpVlr, Caracter, nome do campo para cálculo
@param  	cCmpDesc, Caracter, nome do campo para cálculo
@param  	cCmpAlvo, Caracter, nome do campo para receber resultado
/*/
//------------------------------------------------------------------------------
Function At740CDesc(cMdlDom,cCmpQtd,cCmpVlr,cCmpDesc,cCmpAlvo)

Local oModel	:= FwModelActive()
Local oMdlPr	:= oModel:GetModel(cMdlDom)
Local nQtd		:= oMdlPr:GetValue(cCmpQtd)
Local nVlr		:= oMdlPr:GetValue(cCmpVlr)
Local nDesc	:= oMdlPr:GetValue(cCmpDesc)
Local nResp	:= 0

nResp := (nQtd*nVlr)*(1-(nDesc/100))

//Adicionar o valor das taxas de lucro e administrativas ao valor do SubTotal
If cCmpDesc == "TFF_DESCON"
	nResp := nResp+oMdlPr:GetValue("TFF_TXLUCR")+oMdlPr:GetValue("TFF_TXADM")
EndIf

oMdlPr:SetValue( cCmpAlvo, nResp )

Return nResp

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VldDt

Função para validação dos períodos iniciais e finais dos materiais e alocações.

@sample 	At740VldDt(cModelo,cCpoSelec,cCpoDtIn,cCpoDtFm)

@since		02/10/2013
@version	P11.90

@return 	lRet, Lógico, retorna .T. se data for válida.

@param  	cModelo, Caracter, nome do modelo de dados principal.
@param  	cCpoSelec, Caracter, nome do campo da data selecionada para validação.
@param  	cCpoDtIn, Caracter, nome do campo da data inicial.
@param  	cCpoDtFm, Caracter, nome do campo da data final.
/*/
//------------------------------------------------------------------------------
Function At740VldDt(cModelo,cCpoSelec,cCpoDtIn,cCpoDtFm,oModel,lExtra)

Local oMdl			:= nil
Local dDtIniLoc		:= CToD('')
Local dDtFimLoc		:= CToD('')
Local dPrIniRh		:= CToD('')
Local dPrFimRh		:= CToD('')
Local dDtFimRH	 	:= CToD('')
Local lRet			:= .F.
Local cMdlLoc
Local cMdlRH
Local lOrcPrc 		:= SuperGetMv("MV_ORCPRC",,.F.)
Local lNotRH 		:= lExtra .And. lOrcPrc
Local lDTEncTFF 	:= FindFunction("TecEncDtFt") .AND. TecEncDtFt() .AND. !GSGetIns("LE")

Default oModel	:= FwModelActive()
Default lExtra	:= .F.

oMdl		:= oModel:GetModel(cModelo)

If lExtra
	cMdlLoc := 'TFL_CAB'
	cMdlRH  := 'TFF_GRID'
Else
	cMdlLoc := 'TFL_LOC'
	cMdlRH  := 'TFF_RH'
EndIf

dDtIniLoc := oModel:GetModel(cMdlLoc):GetValue('TFL_DTINI')
dDtFimLoc := oModel:GetModel(cMdlLoc):GetValue('TFL_DTFIM')

If !lNotRH
	dPrIniRh := oModel:GetModel(cMdlRH):GetValue('TFF_PERINI')
	dPrFimRh := oModel:GetModel(cMdlRH):GetValue('TFF_PERFIM')
EndIf

If Left(cCpoSelec,3) $ "TFI#TFF" .And. SubStr(cCpoSelec,5) == "PERINI"

	If DTOS(oMdl:GetValue(cCpoDtIn)) >= DTOS(dDtIniLoc) .AND. (DTOS(oMdl:GetValue(cCpoDtIn)) <= DTOS(dDtFimLoc) .OR. Empty(dDtFimLoc) )
		lRet := .T.
	EndIf

ElseIf Left(cCpoSelec,3) $ "TFI#TFF" .And. SubStr(cCpoSelec,5) == "PERFIM"

	If cModelo == "TFF_RH" .AND. lDTEncTFF .AND. oModel:GetModel(cMdlRH):GetValue('TFF_ENCE') == '1' 
	    dDtFimRH := Posicione("TFF",1,oModel:GetModel(cMdlRH):GetValue("TFF_FILIAL")+oModel:GetModel(cMdlRH):GetValue("TFF_COD"),"TFF_PERFIM")
	 	If !Empty(oModel:GetModel(cMdlRH):GetValue('TFF_DTENCE'));
		 	.AND. (oModel:GetModel(cMdlRH):GetValue('TFF_PERFIM') >= oModel:GetModel(cMdlRH):GetValue('TFF_DTENCE');
	 		.AND. oModel:GetModel(cMdlRH):GetValue('TFF_PERFIM') <= dDtFimRH)	

	 		lRet := .T.			
	 	Else
	 		If Empty(oModel:GetModel(cMdlRH):GetValue('TFF_DTENCE')); 
			 	.AND. oModel:GetModel(cMdlRH):GetValue('TFF_PERFIM') <= dDtFimRH			   
	 			lRet := .T.			
	 		EndIf
	 	EndIf 	 	
	ElseIf cModelo == "TFF_RH" .AND. !lDTEncTFF .AND. oModel:GetModel(cMdlRH):GetValue('TFF_ENCE') == '1' 
	    dDtFimRH := Posicione("TFF",1,oModel:GetModel(cMdlRH):GetValue("TFF_FILIAL")+oModel:GetModel(cMdlRH):GetValue("TFF_COD"),"TFF_PERFIM")
		If oModel:GetModel(cMdlRH):GetValue('TFF_PERFIM') <= dDtFimRH 
			lRet := .T.			
	 	EndIf	
	Else
		If !Empty(oMdl:GetValue(cCpoDtIn))
			If DTOS(oMdl:GetValue(cCpoDtFm)) >= DTOS(oMdl:GetValue(cCpoDtIn)) .AND. (DTOS(oMdl:GetValue(cCpoDtFm)) <= DTOS(dDtFimLoc) .OR. Empty(dDtFimLoc) )
				lRet := .T.
			EndIf
		EndIf
	EndIf	
ElseIf SubStr(cCpoSelec,5) == "PERINI"

	If !lNotRH
		If DTOS(oMdl:GetValue(cCpoDtIn)) >= DTOS(dPrIniRh) .AND. ;
		  (DTOS(oMdl:GetValue(cCpoDtIn)) <= DTOS(dPrFimRh) .OR. ;
		  Empty(oModel:GetModel(cMdlRH):GetValue("TFF_PERFIM")) )
			lRet := .T.
		EndIf

	Else
		If DTOS(oMdl:GetValue(cCpoDtIn)) >= DTOS(dDtIniLoc) .AND. ;
		  (DTOS(oMdl:GetValue(cCpoDtIn)) <= DTOS(dDtFimLoc) .OR. ;
		  Empty(oModel:GetModel(cMdlLoc):GetValue("TFL_DTFIM")) )
			lRet := .T.
		EndIf
	EndIf

ElseIf SubStr(cCpoSelec,5) == "PERFIM"
	If !lNotRH
		If !Empty(oMdl:GetValue(cCpoDtIn))
			If DTOS(oMdl:GetValue(cCpoDtFm)) >= DTOS(oMdl:GetValue(cCpoDtIn)) .AND. ;
			  (DTOS(oMdl:GetValue(cCpoDtFm)) <= DTOS(dPrFimRh) .OR. ;
			  Empty(dPrFimRh) )
				lRet := .T.
			EndIf
		EndIf
	Else
		If !Empty(oMdl:GetValue(cCpoDtIn))
			If DTOS(oMdl:GetValue(cCpoDtFm)) >= DTOS(oMdl:GetValue(cCpoDtIn)) .AND. ;
			  (DTOS(oMdl:GetValue(cCpoDtFm)) <= DTOS(dDtFimLoc) .OR. ;
			  Empty(dDtFimLoc) )
				lRet := .T.
			EndIf
		EndIf
	EndIf
EndIf

If lRet .AND. (isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") )
	If !oMdl:IsInserted() .AND. VldLineRvP( cCpoSelec, DTOS(oMdl:GetValue(cCpoSelec)), IIF(Empty(oMdl:GetValue(Left(cCpoSelec,3)+"_CODREL")), oMdl:GetValue(Left(cCpoSelec,3)+"_COD"), oMdl:GetValue(Left(cCpoSelec,3)+"_CODREL")), Left(cCpoSelec,3))
		oMdl:LoadValue(Left(cCpoSelec,3)+"_MODPLA", "2")
	Else
		oMdl:LoadValue(Left(cCpoSelec,3)+"_MODPLA", "1")
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VldHr

Função para validação dos horarios do periodos iniciais e finais dos materiais e alocações.

@sample 	At740VldDt(cModelo,cCpoSelec,cCpoDtIn,cCpoDtFm)

@since		23/10/2013
@version	P11.90

@return 	lRet, Lógico, retorna .T. se o horario for válido.

@param  	cModelo, Caracter, nome do modelo de dados principal.
@param  	cCpoSelec, Caracter, nome do campo da hora selecionada para validação.
@param  	cCpoHrIn, Caracter, nome do campo da hora inicial.
@param  	cCpoHrFm, Caracter, nome do campo da hora final.
/*/
//------------------------------------------------------------------------------
Function At740VldHr(cModelo,cCpoSelec,cCpoHrIn,cCpoHrFm)

Local oModel  := FwModelActive()
Local oMdl		:= oModel:GetModel(cModelo)
Local lRet    := (Len(Alltrim(oMdl:GetValue(cCpoSelec))) == 1)

If !lRet

	If SubStr(cCpoSelec,5) == "HORAIN" .And. ! Empty(FwFldGet("TFF_HORAIN"))

		If oMdl:GetValue(cCpoHrIn) >= FwFldGet("TFF_HORAIN") .And. ;
		   (oMdl:GetValue(cCpoHrIn) <= FwFldGet("TFF_HORAFI") .OR. Empty(FwFldGet("TFF_HORAFI")))
			lRet := .T.
		EndIf

	ElseIf SubStr(cCpoSelec,5) == "HORAFI" .And. ! Empty(FwFldGet("TFF_HORAFI"))

		If !Empty(oMdl:GetValue(cCpoHrIn))
			If oMdl:GetValue(cCpoHrFm) >= oMdl:GetValue(cCpoHrIn) .And. ;
				(oMdl:GetValue(cCpoHrFm) >= FwFldGet("TFF_HORAIN") .Or. Empty(FwFldGet("TFF_HORAIN"))) .And. ;
				(oMdl:GetValue(cCpoHrFm) <= FwFldGet("TFF_HORAFI") .Or. Empty(FwFldGet("TFF_HORAFI")))
				lRet := .T.
			EndIf
		EndIf

	EndIf

EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VlVig
	Valida a fata de vigência em todos os grids dependentes da tabela TFL

@sample 	At740VlVig(oModel)

@since		05/10/2013
@version	P11.90

@return 	lRet, Lógico, retorna .T. se data for válida.

@param  	oModel, Objeto, modelo de dados da tabela TFL
/*/
//------------------------------------------------------------------------------
Function At740VlVig(oModel, cCampo, xValueNew, nLine, xValueOld)

Local oMdlGeral     := oModel:GetModel()
Local oView         := nil
Local oMdlRH        := nil
Local oMdlMI        := nil
Local oMdlMC        := nil
Local oMdlLE        := nil
Local oMdlTFJ       := nil
Local nLinRh        := 0
Local nLinMi        := 0
Local nLinMc        := 0
Local nLinLe        := 0
Local aSaveRows     := {}
Local aItens        := {}
Local aAreaCN9      := {}
Local cDtIniCtr     := CToD('')
Local dDtIniLoc     := CToD('')
Local dDtFimLoc     := CToD('')
Local lRet          := .T.
Local lReplica      := .F. 
Local lDTEncTFF 	:= FindFunction("TecEncDtFt") .AND. TecEncDtFt() .AND. !GSGetIns("LE")

If !IsBlind()
    oView := FwViewActive()
EndIf

If oMdlGeral == nil
    oMdlGeral := FwModelActive()
EndIf

dDtIniLoc   := oMdlGeral:GetModel('TFL_LOC'):GetValue('TFL_DTINI')
dDtFimLoc   := oMdlGeral:GetModel('TFL_LOC'):GetValue('TFL_DTFIM')

oMdlRH  := oMdlGeral:GetModel("TFF_RH")
oMdlMI  := oMdlGeral:GetModel("TFG_MI")
oMdlMC  := oMdlGeral:GetModel("TFH_MC")
oMdlLE  := oMdlGeral:GetModel("TFI_LE")
oMdlTFJ := oMdlGeral:GetModel("TFJ_REFER")

If IsInCallStack("At870Revis") .OR. IsInCallStack("AT870PlaRe") 
    If !GSGetIns('LE') .AND. cCampo == "TFL_DTFIM" .AND. !Empty(xValueOld) .AND. xValueNew <> xValueOld
        If !IsBlind()
            lReplica := MsgYesNo(STR0303) //"Deseja replicar esta data para os demais itens deste contrato? "   
		Else
            lReplica := .F.
        EndIf
    EndIf           
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

For nLinRh := 1 to oMdlRH:Length() // Aba Recursos humanos

    oMdlRH:GoLine( nLinRh )
    If !oMdlRH:IsDeleted() .And. !Empty(oMdlRH:GetValue("TFF_COD")) .And. !Empty(oMdlRH:GetValue("TFF_PERFIM"))
        If lReplica .OR. DTOS(dDtFimLoc) >= DTOS(oMdlRH:GetValue("TFF_PERFIM"))
            If lReplica
                AADD( aItens, { oMdlRH:GetValue("TFF_COD"), nLinRh, oMdlRH:GetValue("TFF_PERFIM"), {}, {}})
                If oMdlRH:GetValue('TFF_COBCTR') == '2' .Or. oMdlRH:GetValue('TFF_ENCE') == '1'
					If oMdlRH:GetValue('TFF_COBCTR') == '2'
						If oMdlRH:GetValue('TFF_PERFIM') > dDtFimLoc 
							lRet := .F.
							oModel:GetModel():SetErrorMessage(oModel:GetId(),"TFF_PERFIM",oModel:GetModel():GetId(), "TFF_PERFIM",'TFF_PERFIM',	STR0308,'' ) // "Não é possivel reduzir a data deste posto, existem itens extra com a data superior a nova data."
							oView:Refresh("VIEW_RH")
						EndIf
					Else
						If lDTEncTFF .And. !Empty(oMdlRH:GetValue('TFF_DTENCE'))
							If oMdlRH:GetValue('TFF_DTENCE') > dDtFimLoc 
								lRet := .F.
								oModel:GetModel():SetErrorMessage(oModel:GetId(),"TFF_PERFIM",oModel:GetModel():GetId(), "TFF_PERFIM",'TFF_PERFIM',	STR0325,'' ) // "Não é possivel reduzir a data deste posto, existem itens encerrados com a data superior a nova data."
								oView:Refresh("VIEW_RH")						
							Else 
								If oMdlRH:GetValue('TFF_DTENCE') <> oMdlRH:GetValue('TFF_PERFIM') .And. oMdlRH:GetValue('TFF_PERFIM') > oMdlRH:GetValue('TFF_DTENCE')
									oMdlRH:LoadValue('TFF_PERFIM', oMdlRH:GetValue('TFF_DTENCE'))
								EndIf
							EndIf 
						Else 
							If oMdlRH:GetValue('TFF_PERFIM') > dDtFimLoc
								lRet := .F.
								oModel:GetModel():SetErrorMessage(oModel:GetId(),"TFF_PERFIM",oModel:GetModel():GetId(), "TFF_PERFIM",'TFF_PERFIM',	STR0325,'' ) // "Não é possivel reduzir a data deste posto, existem itens encerrados com a data superior a nova data."
								oView:Refresh("VIEW_RH")
							EndIf 
						EndIf 
					EndIf 	
				Else
					If !oMdlRH:SetValue('TFF_PERFIM', dDtFimLoc)
                    	lRet := .F. 
                        Exit
                    EndIf
				EndIf
			Else
                If DTOS(dDtFimLoc) < DTOS(oMdlRH:GetValue("TFF_PERFIM"))
                     lRet := .F.
                EndIf
            EndIf
            If lRet
                For nLinMi := 1 to oMdlMI:Length() // Aba Materiais de Implantação
                    oMdlMI:GoLine( nLinMi )
                    If !oMdlMI:IsDeleted() .AND. !Empty(oMdlMI:GetValue("TFG_COD")) .AND. !Empty(oMdlMI:GetValue("TFG_PERFIM"))
                        If lReplica
                            AADD( aItens[nLinRh][4], { oMdlRH:GetValue("TFF_COD"), nLinMi, oMdlMI:GetValue("TFG_PERFIM"), oMdlMI:GetValue("TFG_COD")})
							If oMdlMI:GetValue('TFG_COBCTR') == '2'
								If oMdlMI:GetValue('TFG_PERFIM') > dDtFimLoc
									lRet := .F.
									oModel:GetModel():SetErrorMessage(oModel:GetId(),"TFG_PERFIM",oModel:GetModel():GetId(), "TFG_PERFIM",'TFG_PERFIM',	STR0308,'' ) // "Não é possivel reduzir a data deste posto, existem itens extra com a data superior a nova data."									
									oView:Refresh("VIEW_MI")
								EndIf
							Else
								If lDTEncTFF .And. oMdlRH:GetValue('TFF_ENCE') == '1' .And. (oMdlMI:GetValue('TFG_PERFIM') > oMdlRH:GetValue('TFF_DTENCE') .Or. oMdlMI:GetValue('TFG_PERFIM') > oMdlRH:GetValue('TFF_PERFIM'))
									oMdlMI:LoadValue('TFG_PERFIM', oMdlRH:GetValue('TFF_PERFIM'))
								Else 
									If !oMdlMI:SetValue('TFG_PERFIM', dDtFimLoc)
										lRet := .F. 
										Exit
									EndIf
								EndIf 
							EndIf
                        Else
                            If DTOS(dDtFimLoc) < DTOS(oMdlMI:GetValue("TFG_PERFIM"))
                                lRet := .F.
                            EndIf
                        EndIf
                    EndIf

                Next nLinMi
            Else
                Exit
            EndIf
            If lRet
                For nLinMc := 1 to oMdlMC:Length() // Aba Materiais de Consumo

                    oMdlMC:GoLine( nLinMc )

                    If !oMdlMC:IsDeleted() .AND. !Empty(oMdlMC:GetValue("TFH_COD")) .AND. !Empty(oMdlMC:GetValue("TFH_PERFIM"))
                        If lReplica
                            AADD( aItens[nLinRh][5], { oMdlRH:GetValue("TFF_COD"), nLinMc, oMdlMC:GetValue("TFH_PERFIM"), oMdlMC:GetValue("TFH_COD")})
                            
							If oMdlMC:GetValue('TFH_COBCTR') == '2'
								If oMdlMC:GetValue('TFH_PERFIM') > dDtFimLoc
									lRet := .F.
									oModel:GetModel():SetErrorMessage(oModel:GetId(),"TFH_PERFIM",oModel:GetModel():GetId(), "TFH_PERFIM",'TFH_PERFIM',	STR0308,'' ) // "Não é possivel reduzir a data deste posto, existem itens extra com a data superior a nova data."
								EndIf
							Else
								If lDTEncTFF .And. oMdlRH:GetValue('TFF_ENCE') == '1' .And. (oMdlMC:GetValue('TFH_PERFIM') > oMdlRH:GetValue('TFF_DTENCE') .Or. oMdlMC:GetValue('TFH_PERFIM') > oMdlRH:GetValue('TFF_PERFIM'))
									oMdlMC:LoadValue('TFH_PERFIM', oMdlRH:GetValue('TFF_PERFIM'))
								Else 
									If !oMdlMC:SetValue('TFH_PERFIM', dDtFimLoc)
										lRet := .F. 
										Exit
									EndIf
								EndIf 	
							EndIf
                        Else
                            If DTOS(dDtFimLoc) < DTOS(oMdlMC:GetValue("TFH_PERFIM"))
                                lRet := .F.
                            EndIf
                        EndIf
                    EndIf
                Next nLinMc
            Else
                Exit
            EndIf
        Else
            lRet := .F.
        EndIf
    EndIf
Next nLinRh

If !lReplica
    For nLinLe := 1 to oMdlLE:Length()
        oMdlLE:GoLine( nLinLe )
        If !oMdlLE:IsDeleted()
            If DTOS(dDtFimLoc) < DTOS(oMdlLE:GetValue("TFI_PERFIM"))
                lRet := .F.
            EndIf
        EndIf
    Next nLinLe
Else
    If !lRet
        For nLinRh := 1 to Len(aItens) // Aba Recursos humanos
            oMdlRH:GoLine( aItens[nLinRh][2] )
            oMdlRH:LoadValue('TFF_PERFIM', aItens[nLinRh][3])   
            For nLinMi := 1 to Len(aItens[nLinRh][4]) // Aba Materiais de Implanta??o
                oMdlMI:GoLine( aItens[nLinRh][4][nLinMi][2] )               
                oMdlMI:LoadValue('TFG_PERFIM', aItens[nLinRh][4][nLinMi][3] )
            Next nLinMi
            For nLinMc := 1 to Len(aItens[nLinRh][5]) // Aba Materiais de Consumo
                oMdlMC:GoLine( aItens[nLinRh][5][nLinMc][2] )
                oMdlMC:LoadValue('TFH_PERFIM', aItens[nLinRh][5][nLinMc][3] )
            Next nLinMc
        Next nLinRh
        oMdlGeral:GetModel('TFL_LOC'):LoadValue("TFL_DTFIM",xValueOld)
        If !IsBlind()
            oView:Refresh()
        EndIf

    EndIf
EndIf

FwRestRows( aSaveRows )

If !lRet .AND. !lReplica
    oModel:GetModel():SetErrorMessage(oModel:GetId(),"TFL_DTFIM",oModel:GetModel():GetId(), "TFL_DTFIM",'TFL_DTFIM',;
        STR0025, STR0026 )  // 'Data final de vigência menor que o período final dos recursos, materiais e locação' ### 'Digite uma data maior.'
EndIf

If  lRet .and. !Empty(dDtFimLoc) .and. !Empty(dDtIniLoc) .And. (dDtFimLoc < dDtIniLoc)
    oModel:GetModel():SetErrorMessage(oModel:GetId(),"TFL_DTFIM",oModel:GetModel():GetId(), "TFL_DTFIM",'TFL_DTFIM',;
        STR0026,'' )  // 'Digite uma data maior.'###'Atenção!'
    lRet := .F.
EndIf

If !Empty(cDtIniCtr) .And. !Empty(dDtIniLoc) .And. dDtIniLoc < cDtIniCtr

    oModel:GetModel():SetErrorMessage(oModel:GetId(),"TFL_DTINI",oModel:GetModel():GetId(), "TFL_DTINI",'TFL_DTINI',;
    STR0287, STR0026 )  // 'Data Inicial de vigência menor que o período inicial do contrato' ### 'Digite uma data maior.'
    lRet := .F.
EndIf 

If lReplica .AND. lRet
	MsgInfo(STR0307) //"Itens do local alterados com sucesso!"
EndIf

If !IsBlind() .AND. lReplica
	oView:Refresh()
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740SCmt / At740GCmt
	Altera o conteúdo da variável

@sample 	At740CpyMdl

@since		23/09/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740SCmt( lValor )

lDoCommit := lValor

Return

Function At740GCmt()
Local lVersion23	:= HasOrcSimp()
Return lDoCommit .Or. (IsInCallStack('TECA745') .Or. IsInCallStack('TECA270') .AND. lVersion23)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740SLoad
	Realiza a cópia dos dados de um modelo para outro
evitando sobrepor conteudo de alguns campos, informados na exceção

@sample 	At740CpyMdl

@since		23/09/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740SLoad( oObj )

oCharge := oObj

Return

Function At740GLoad()

Return( oCharge )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740GXML
	Realiza a cópia dos dados de um modelo para outro
evitando sobrepor conteudo de alguns campos, informados na exceção

@sample 	At740GXML

@since		23/09/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740GXML()

Return cXmlDados


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740SLuc / At740GLuc
	Altera o conteúdo da variável

@sample 	At740CpyMdl

@since		26/02/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740SLuc( nValor )

nTLuc := nValor

Return

Function At740GLuc()

Return nTLuc


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740SAdm / At740GAdm
	Altera o conteúdo da variável

@sample 	At740CpyMdl

@since		26/02/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740SAdm( nValor )

nTAdm := nValor

Return

Function At740GAdm()

Return nTAdm


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VldPrd
	Valida o produto selecionado conforme o tipo Rec. Humano, Mat. consumo, etc

@sample  	At740VldPrd

@since   	23/09/2013
@version 	P11.90

@param   	ExpN, Numerico, define qual o tipo do produto para validar sendo:
				1 - Recurso Humano
				2 - Material de Implantação
				3 - Material de Consumo
				4 - Equipamentos para Locação
@param   	ExpC, Caracter, código do produto a ser validado

@return  	ExpL, Logico, indica de se é valido (.T.) ou não (.F.)
/*/
//------------------------------------------------------------------------------
Function At740VldPrd( nTipo, cCodProd )

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet := .F.

DEFAULT nTipo := 0
DEFAULT cCodProd := ''
//--------------------------------------------------------------------
// Posiciona na tabela SB5 para verificar a configuração do produto
// conforme cada tipo exige

DbSelectArea('SB5')
SB5->( DbSetOrder( 1 ) ) //B5_FILIAL+B5_COD

If !Empty(cCodProd) .And. SB5->( DbSeek( xFilial('SB5')+cCodProd ) )
	Do Case

		CASE nTipo == 1 // Recurso Humano
			lRet := SB5->B5_TPISERV == '4'

		CASE nTipo == 2 // Material de Implantação
			lRet := SB5->B5_TPISERV $ '1235' .And. SB5->B5_GSMI == '1'

		CASE nTipo == 3 // Material de Consumo
			lRet := SB5->B5_TPISERV $ '5' .And. SB5->B5_GSMC == '1'

		CASE nTipo == 4 // Locação de Equipamentos
			lRet := SB5->B5_TPISERV $ '5' .And. SB5->B5_GSLE == '1'

	End Case

EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740TdOk
	Validação geral do modelo

@sample 	At740TdOk

@since		23/09/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740TdOk( oMdlGer )

Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local aValidMat		:= {}	//Estrutura com locais e itens de RH com sem valor de materiais
Local oMdlLoc		:= oMdlGer:GetModel('TFL_LOC')
Local oMdlGrid		:= oMdlGer:GetModel('TFI_LE')
Local oMdlCobLoc	:= oMdlGer:GetModel('TEV_ADICIO')
Local oMdlRH		:= oMdlGer:GetModel('TFF_RH')
Local oModMI		:= oMdlGer:GetModel('TFG_MI')
Local oModMC		:= oMdlGer:GetModel('TFH_MC')
Local oModTFJ		:= oMdlGer:GetModel('TFJ_REFER')
Local nLinGrd		:= 0
Local nLinFil		:= 0
Local nLinTev		:= 0
Local nI			:= 0
Local nJ			:= 0
Local nK			:= 0
Local lExit         := .F.
Local nPrcVenda		:= 0
Local lCobrContr	:= .F.
Local lOk			:= .T.
Local lRet			:= .T.
Local lExclusao 	:= oMdlGer:GetOperation() == MODEL_OPERATION_DELETE
Local lOrcPrc 	:= !EMPTY(oModTFJ:GetValue("TFJ_CODTAB"))
Local lPermLocZero 	:= .F. //At680Perm( , __cUserId, '032' )
Local lAlgumTemValor 	:= .F.
Local lNotRhMts 		:= .F.
Local lVldLe		:= .F.

// não realiza validaçaõ alguma quando é exclusão
If lExclusao
	lRet := oMdlGer:GetModel("TFJ_REFER"):GetValue("TFJ_STATUS") == "2" .Or. ; // Só permite a exclusão de orçamentos com status em revisão
				Empty( oMdlGer:GetModel("TFJ_REFER"):GetValue("TFJ_CONTRT") ); // ou que não tenha contrato ainda
			.OR. (isInCallStack("AT870PlaRe") .AND. oMdlGer:GetModel("TFJ_REFER"):GetValue("TFJ_STATUS") == "8" )  
	If !lRet
            oMdlGer:GetModel():SetErrorMessage( oMdlGer:GetId(),"TFJ_STATUS","TFJ_REFER", "TFJ_STATUS",;
			oMdlGer:GetModel("TFJ_REFER"):GetValue("TFJ_STATUS"),;
			STR0125,"" )  // "Não é permitido excluir orçamentos de serviços neste status"
	EndIf
Else
	// verifica se foram inseridos produtos/recursos nos Locais
	If lRet
		For nI := 1 To oMdlLoc:Length()
			oMdlLoc:GoLine( nI )
			If !oMdlLoc:IsDeleted()
				lVldLe := At740VldLe(oMdlGer)
				If ( lRet := lVldLe )
					If oMdlLoc:GetValue("TFL_TOTAL") == 0
						lNotRhMts := ( oMdlRH:IsEmpty() .And. oModMI:IsEmpty() .And. oModMC:IsEmpty() )
						If !lPermLocZero .Or. lNotRhMts
							lRet := .F.
							Help(,, "AT740TDOKRH",, STR0209, 1, 0) // "Não é possivel ter local de atendimento com valor zerado. Por favor verifique os itens."
							Exit
						EndIf
					Else
						lAlgumTemValor := .T.
					EndIf
				Else
					Exit
				EndIf
			EndIf
		Next
		If !lAlgumTemValor .And. lPermLocZero
			lRet := .F.
		EndIf
    EndIf

	If lRet

		If IsInCallStack("At600SeAtu")//Realiza validação somente dentro da tela do TECA740
			If ! (Empty(oMdlGer:GetModel('TFJ_REFER'):GetValue('TFJ_GESMAT')) .OR. (oMdlGer:GetModel('TFJ_REFER'):GetValue('TFJ_GESMAT') = '1'))//Material por valor ou por percentual do recurso
				For nI:=1 To oMdlLoc:Length()
					oMdlLoc:GoLine(nI)

					If !oMdlLoc:IsDeleted()
						For nJ:=1 To oMdlRH:Length()
							oMdlRH:GoLine(nJ)
							If !oMdlRh:IsDeleted() .AND. !Empty(oMdlRh:GetValue("TFF_PRODUT")) .AND. oMdlRh:GetValue("TFF_VLRMAT") == 0
								aAdd(aValidMat, { oMdlLoc:GetValue("TFL_LOCAL"),;
												oMdlLoc:GetValue("TFL_DESLOC"),;
												oMdlRH:GetValue("TFF_ITEM"),;
												oMdlRH:GetValue("TFF_PRODUT"),;
												oMdlRH:GetValue("TFF_DESCRI") })
							EndIf
						Next nJ
					EndIf
				Next nI

				If Len(aValidMat) > 0
					If !At740ExbIt(aValidMat)//Apresenta itens em tela
						lRet := .F.
					EndIf
				EndIf
			EndIf

		EndIf

		If lRet
			For nI := 1 To oMdlLoc:Length()

				oMdlLoc:GoLine(nI)

				If !oMdlLoc:IsDeleted()
					// verifica o preenchimento dos recursos humanos
					For nJ := 1 To oMdlRH:Length()
						oMdlRH:GoLine(nJ)
						If TecVlPrPar() .AND. !oMdlRH:IsDeleted() .AND.;
								!Empty( oMdlRH:GetValue("TFF_PRODUT") ) .AND. oMdlRH:GetValue("TFF_VLPRPA") == 0 .AND.;
									!isInCallStack("At870GerOrc")
							oMdlRH:LoadValue("TFF_VLPRPA", At740PrxPa("TFF") )
						EndIf
						// verifica o preenchimento dos campos de valores
						If !oMdlRH:IsDeleted() .And. !Empty( oMdlRH:GetValue("TFF_PRODUT") )
							lRet := oMdlRH:GetValue("TFF_PRCVEN") >= 0
						EndIf
						If !lRet
							Help(,,"AT740TDOKRH",,STR0126,1,0) // "O valor dos itens de recursos humanos não pode ser zero para itens pertencentes ao contrato."
						EndIf

						If !lOrcPrc
							// verifica o preenchimento dos valores dos materiais
							lRet := lRet .And. At740VlrMts( oModMI, "TFG", lPermLocZero, oMdlLoc:GetValue("TFL_TOTAL") )
							lRet := lRet .And. At740VlrMts( oModMC, "TFH", lPermLocZero, oMdlLoc:GetValue("TFL_TOTAL") )
						EndIf
						For nK := 1 To oModMI:Length()
							oModMI:GoLine(nK)
							If TecVlPrPar() .AND. !oModMI:IsDeleted() .AND.;
									!Empty( oModMI:GetValue("TFG_PRODUT") ) .AND. oModMI:GetValue("TFG_VLPRPA") == 0 .AND.;
										!isInCallStack("At870GerOrc")
								oModMI:LoadValue("TFG_VLPRPA", At740PrxPa("TFG") )
							EndIf
						Next nK
						For nK := 1 To oModMC:Length()
							oModMC:GoLine(nK)
							If TecVlPrPar() .AND. !oModMC:IsDeleted() .AND.;
									!Empty( oModMC:GetValue("TFH_PRODUT") ) .AND. oModMC:GetValue("TFH_VLPRPA") == 0 .AND.;
										!isInCallStack("At870GerOrc")
								oModMC:LoadValue("TFH_VLPRPA", At740PrxPa("TFH") )
							EndIf
						Next nK
						If !lRet
							EXIT
						EndIf
					Next nJ

					If lOrcPrc
						// verifica o preenchimento dos valores dos materiais
						lRet := lRet .And. At740VlrMts( oModMI, "TFG", lPermLocZero, oMdlLoc:GetValue("TFL_TOTAL") )
						lRet := lRet .And. At740VlrMts( oModMC, "TFH", lPermLocZero, oMdlLoc:GetValue("TFL_TOTAL") )
					EndIf

					If TecVlPrPar() .AND. !oMdlLoc:IsDeleted() .AND.;
							!Empty( oMdlLoc:GetValue("TFL_LOCAL") ) .AND. !isInCallStack("At870GerOrc")
						At740AtTpr()
					EndIf

				EndIf

				If !lRet
					EXIT
				EndIf
			Next nI
		EndIf

		If lRet
			//--------------------------------------------------------------------------------
			//  Valida a existência de cobrança para os itens de locação de equipamentos
			For nLinGrd := 1 To oMdlLoc:Length()

			oMdlLoc:GoLine( nLinGrd )

			If !oMdlLoc:IsDeleted()

                If lRet
					For nLinFil := 1 To oMdlGrid:Length()

						oMdlGrid:GoLine( nLinFil )

						If !oMdlGrid:IsDeleted() .And. !Empty( oMdlGrid:GetValue('TFI_PRODUT') )
							If lOk
								//Validação dos campos de Entrega e Coleta
								If lRet
									If (!Empty(oMdlGrid:GetValue('TFI_ENTEQP')) .And. Empty(oMdlGrid:GetValue('TFI_COLEQP')));
										.Or. (Empty(oMdlGrid:GetValue('TFI_ENTEQP')) .And. !Empty(oMdlGrid:GetValue('TFI_COLEQP')))
										lRet := .F.
										Help(,,"AT740OPC1",,STR0095,1,0) //"Não é possivel deixar um dos campos de Entrega/Coleta preenchidos, ou os campos deve estar em branco ou os dois preenchidos! "
										Exit
									Elseif (!Empty(oMdlGrid:GetValue("TFI_ENTEQP")) .AND. !At740VldAg("TFI_ENTEQP",;
												oMdlGrid:GetValue("TFI_PERINI"),;
												oMdlGrid:GetValue("TFI_PERFIM"),;
												oMdlGrid:GetValue("TFI_ENTEQP"),;
												oMdlGrid:GetValue("TFI_COLEQP"))) .OR. (!Empty(oMdlGrid:GetValue("TFI_COLEQP")) .AND. !At740VldAg("TFI_COLEQP",;
												oMdlGrid:GetValue("TFI_PERINI"),;
												oMdlGrid:GetValue("TFI_PERFIM"),;
												oMdlGrid:GetValue("TFI_ENTEQP"),;
												oMdlGrid:GetValue("TFI_COLEQP")))

										lRet := .F.
										Exit
									Elseif Empty(oMdlGrid:GetValue("TFI_TES"))
										Help(,, "At740TdOk",,STR0098,1,0,,,,,,{STR0099}) //"O campo TES do grid de Locação de Equipamentos não pode ser vazio." # "Informe a TES."
										lRet := .F.
										Exit
									ElseIf (!Empty(oMdlGrid:GetValue("TFI_APUMED")) .and. oMdlGrid:GetValue("TFI_APUMED") <> '1') .And. ( Empty(oMdlGrid:GetValue('TFI_ENTEQP')) .or. Empty(oMdlGrid:GetValue('TFI_COLEQP')) )
										Help(,, "At740TdOk",,STR0112,1,0,,,,,,{STR0113})//#"Quando Tipo de Apuração for diferente de Branco ou '1' é necessario fazer o preenchimento dos campos de Entrega e Coleta"#"Favor preencher os campos de Entrega e Coleta para Processeguir"
										lRet := .F.
										Exit
									Endif
								EndIf

								//  quando identifica uma cobrança, vai para a próxima linha
								// dos itens de locação
								Loop
							Else
								//  quando identifica erro, sai com erro e força o preenchimento
								lRet := .F.
								Help(,,'AT740COBLOC',, STR0027 + CRLF + ;  // 'Cobrança da locação não preenchida para o item: '
														STR0028 + STR(nLinGrd) + CRLF + ;  // 'Item Local '
														STR0029 + STR(nLinFil) + CRLF + ;  // 'Item Locação '
														STR0030 ,1,0)  // 'Preencha a cobrança e depois confirme o Orçamento'
								Exit
							EndIf

						EndIf

					Next nLinFil  // itens da locação

					If oMdlGer:GetModel('TFJ_REFER'):GetValue('TFJ_AGRUP') <> "1"
						DbSelectArea("ABS")
						DbSetOrder(1)
						If ABS->(DbSeek(xFilial("ABS")+oMdlLoc:GetValue('TFL_LOCAL')))
							If Empty(ABS->ABS_CLIFAT) .AND. Empty(ABS->ABS_LJFAT) .AND. ABS->ABS_ENTIDA == '1'
								lRet := .F.
								Help(,,'AT740CLIFAT',,STR0045,1,0) // "Os campos ABS_CLIFAT e ABS_LJFAT são necessarios o preenchimento devido o campo TFJ_AGRUP estar como Não"
								Exit
							EndIf
						EndIf
					EndIf

				EndIf
            EndIf
		Next nLinGrd  // locais de atendimento
		EndIf
	EndIf
EndIf


If lRet
	lRet := At870DelIn(oMdlGer)
EndIf

If Valtype(lRet) == "U"
	lRet := .T.
EndIf

If lRet .And. isInCallStack("At870Revis") .OR. IsInCallStack("AT870PlaRe") 
	For nI := 1 To oMdlLoc:Length()
		oMdlLoc:GoLine(nI)

		If !EMPTY(oModTFJ:GetValue("TFJ_GRPMI"))

			If TecSumInMdl(oMdlLoc, oModTFJ, oModTFJ:GetValue("TFJ_GRPMI")) <= 0
				If TecMedPrd(oModTFJ:GetValue("TFJ_CONTRT"),;
								 oModTFJ:GetValue("TFJ_CONREV"),;
								 oMdlLoc:GetValue("TFL_PLAN"),;
								 oModTFJ:GetValue("TFJ_GRPMI")) > 0

					lRet := .F.
					Help(,,'AT740DELMI',,STR0185,1,0) //"A operação de exclusão de Materias de Implantação não pode ser realizada pois já existem medições para o produto relacionado."
					Exit
				EndIf
			EndIf
		EndIf

		If !EMPTY(oModTFJ:GetValue("TFJ_GRPMC"))

			If TecSumInMdl(oMdlLoc, oModTFJ, oModTFJ:GetValue("TFJ_GRPMC")) <= 0
				If TecMedPrd(oModTFJ:GetValue("TFJ_CONTRT"),;
								 oModTFJ:GetValue("TFJ_CONREV"),;
								 oMdlLoc:GetValue("TFL_PLAN"),;
								 oModTFJ:GetValue("TFJ_GRPMC")) > 0

					lRet := .F.
					Help(,,'AT740DELMC',, STR0186,1,0) //"A operação de exclusão de Materias de Consumo não pode ser realizada pois já existem medições para o produto relacionado."
					Exit
				EndIf
			EndIf
		EndIf

	Next
EndIf

If lOrcPrc .and. lRet .and. aScan( At740FORC(), { |x| x[1] == Replicate( " ", 30 ) } ) > 0// verificar se tiver imposto
	For nI := 1 To oMdlLoc:Length()
		oMdlLoc:GoLine( nI )
		If !oMdlLoc:IsDeleted()
		   For nJ:=1 To oMdlRH:Length()
		   		oMdlRH:GoLine(nJ)
		   		If !oMdlRh:IsDeleted() .AND. Empty(oMdlRh:GetValue("TFF_PRODUT"))
		   			lRet := MsgYesNo(STR0207 )// Orçamento gerado sem itens de RH, os impostos serão desconsiderados, deseja continuar?
		   			lExit := .T.
		   			Exit
		   		EndIf
	       Next nJ
	    EndIf
	    If lExit
	    	Exit
	    EndIf
	Next nI
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)

Return lRet

/*/{Protheus.doc} At740VlrMts
	Valida o preenchimento de valores nos grids de materiais
@since 		05/12/2016
@version 	12.15
@param 		oModMat, Objeto FwFormGridModel, modelo de dados de algum dos materiais (implantação ou consumo) do orçamento de serviços
@param 		cTab, caracter, tabela a ser validada e que pertence ao modelo
@return 		Lógico, indica se o processamento aconteceu ou não com sucesso
/*/
Static Function At740VlrMts( oModMat, cTab, lPermLocZero, nTotLocal )
Local lRet := .T.
Local nK := 0

Default lPermLocZero := .F.
Default nTotLocal	:= 0

For nK := 1 To oModMat:Length()
	oModMat:GoLine(nK)
	If ! oModMat:IsDeleted() .And. ! Empty(oModMat:GetValue(cTab+'_PRODUT'))
		nPrcVenda	:= oModMat:GetValue(cTab+"_PRCVEN")
		If nPrcVenda < 0
			Help(,,"At740TdOk",,STR0115,1,0) //"O valor do preço de venda do material de implantação não pode ser negativo."
			lRet := .F.
			EXIT
		EndIf
		lCobrContr := (oModMat:GetValue(cTab+"_COBCTR") <> "2")
		If nPrcVenda == 0 .And. lCobrContr .And. !IsInCallStack("LoadXmlData") .And. !lPermLocZero .AND. nTotLocal == 0
			Help(,,"At740TdOk",,STR0116,1,0) // "O valor do preço de venda do material de implantação deve ser maior do que zeros."
			lRet	:= .F.
			EXIT
		EndIf
	EndIf
Next nK

Return lRet

/*/{Protheus.doc} At740ExbIt
Exibe Itens em tela
@since 17/07/2015
@version 1.0
@param aItens, array, (Descrição do parâmetro)
@return lRet, Indica confirmação ou cancelamento
/*/
Static Function At740ExbIt(aItens)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local aSize	:= FWGetDialogSize( oMainWnd ) 	// Array com tamanho da janela.
Local lRet 	:= .T.
Local cTexto 	:= ""
Local nI 		:= 1
Local cLocOld := ""
Local cTitItem := STR0074//ITEM

//Monta texto a ser apresentado
cTexto := UPPER(STR0072) + CRLF

For nI:=1 To Len(aItens)

	If cLocOld != aItens[nI][1]
		cTexto += CRLF + aItens[nI][1] + " - " + aItens[nI][2] + CRLF//Local de Atendimento
	EndIf
	cTexto += cTitItem+": "+aItens[nI][3]+" - "//Item
	cTexto += aItens[nI][4]+ " - "+aItens[nI][5]+CRLF//Produto

	cLocOld := aItens[nI][1]

Next nI

DEFINE DIALOG oDlg TITLE STR0073 FROM 0,0 TO 285, 540 PIXEL

@ 000, 000 MsPanel oTop Of oDlg Size 000, 200 // Coordenada para o panel
oTop:Align := CONTROL_ALIGN_TOP //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)

@ 5, 5 Get oMemo Var cTexto Memo Size 260, 100  Of oTop Pixel When .F.
oMemo:bRClicked := { || AllwaysTrue() }

Define SButton From 115, 230 Type  1 Action (lRet := .T., oDlg:End()) Enable Of oTop Pixel // OK
Define SButton From 115, 195 Type  2 Action (lRet := .F., oDlg:End()) Enable Of oTop Pixel // Cancelar

ACTIVATE DIALOG oDlg CENTERED

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740BlTot
	Validação da edição do campo preço de venda de recursos humanos

@sample 	At740BlTot

@since		24/10/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740BlTot(oModel)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lBloq := SuperGetMv("MV_ATBLTOT",,.F.)
Local lRet	:= .T.

If lBloq .And. !Empty(oModel:GetValue("TFF_CALCMD"))
	lRet	:= .F.
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet


/*/{Protheus.doc} At740QtdVen

@since 31/10/2013
@version 11.9

@return lRet, regra para when do campo TFI_QTDVEN

@description
Função com regras para WHEN do campo TFI_QTDVEN

/*/
Function At740QtdVen()

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet := .T.

If IsInCallStack("TECA870")
	lRet := .F.
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740CpCal
	Copiar a planilha de preço do item posicionado

@sample 	At740CpCal

@since		11/11/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740CpCal(oModel)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oMdlRh := oModel:GetModel("TFF_RH")
Local lOk := .T.

If isInCallStack("At870GerOrc")
	If oMdlRh:GetValue("TFF_COBCTR") != "2"
		//Manipular Planilha de item cobrado dentro da rotina de Item Extra
		lOk := .F.
		Help(,, "CpCalCOBCTR1",,STR0192,1,0,,,,,,{STR0193})//"Não é possível modificar itens que são cobrados no contrato através da rotina Item Extra" ## "Para alterar este item, realize uma Revisão do Contrato"
	EndIf
Else
	If oMdlRh:GetValue("TFF_COBCTR") == "2"
		//Manipular Planilha de item não-cobrado fora da rotina de Item Extra
		lOk := .F.
		Help(,, "CpCalCOBCTR2",,STR0195,1,0,,,,,,{STR0196})//"Não é possível modificar itens que não são cobrados no contrato nesta rotina" ## "Para alterar este item, acesse a opção Item Extra dentro da Gestão dos Contratos (TECA870)"
	EndIf
EndIf

If lOk
	cXmlCalculo := oMdlRh:GetValue("TFF_CALCMD")
	aPlanData := { oMdlRh:GetValue("TFF_PLACOD"), oMdlRh:GetValue("TFF_PLAREV") }

	FWRestRows( aSaveLines )
	RestArea(aArea)
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ClCal
	Colar a planilha de preço e executar cálculo no item posicionado.

@sample 	At740ClCal

@since		11/11/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740ClCal(oModel)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oMdlRh		:= oModel:GetModel("TFF_RH")
Local cPreco		:= ""
Local lOk 			:= .T.
Local lCpoCustom	:= ExistBlock('A998CPOUSR')
Local lFacilit := SuperGetMv("MV_GSITORC",,"2") == "1"

If isInCallStack("At870GerOrc")
	If oMdlRh:GetValue("TFF_COBCTR") != "2"
		//Manipular Planilha de item cobrado dentro da rotina de Item Extra
		lOk := .F.
		Help(,, "ClCalCOBCTR1",,STR0192,1,0,,,,,,{STR0193})//"Não é possível modificar itens que são cobrados no contrato através da rotina Item Extra" ## "Para alterar este item, realize uma Revisão do Contrato"
	EndIf
Else
	If oMdlRh:GetValue("TFF_COBCTR") == "2"
		//Manipular Planilha de item não-cobrado fora da rotina de Item Extra
		lOk := .F.
		Help(,, "ClCalCOBCTR2",,STR0195,1,0,,,,,,{STR0196})//"Não é possível modificar itens que não são cobrados no contrato nesta rotina" ## "Para alterar este item, acesse a opção Item Extra dentro da Gestão dos Contratos (TECA870)"
	EndIf
EndIf

If lOk
	If !Empty(cXmlCalculo)
		oFWSheet := FWUIWorkSheet():New(,.F. ) //instancia a planilha sem exibição
		
		If MethIsMemberOf(oFWSheet,"ShowAllErr")
			oFWSheet:ShowAllErr(.F.)
		EndIf

		If isBlind()
			oFwSheet:LoadXmlModel(cXmlCalculo)
		Else
			FwMsgRun(Nil,{|| oFwSheet:LoadXmlModel(cXmlCalculo)}, Nil, STR0252) //"Carregando..."
		EndIf
		If lFacilit
			cPreco := oFwSheet:GetCellValue("TOTAL_CUSTOS")
		Else
			cPreco := oFwSheet:GetCellValue("TOTAL_RH")
		Endif
		If oMdlRh:GetOperation() <> MODEL_OPERATION_VIEW
			oMdlRh:SetValue("TFF_PRCVEN",cPreco)
			oMdlRh:SetValue("TFF_CALCMD",cXmlCalculo)

			If Len(aPlanData) >= 2  // caso seja necessário copiar mais dados tvz seja melhor guardar a linha original da cópia
				oMdlRh:SetValue("TFF_PLACOD", aPlanData[1])
				oMdlRh:SetValue("TFF_PLAREV", aPlanData[2])
			EndIf
			If lCpoCustom
				ExecBlock('A998CPOUSR', .F., .F., {oMdlRh,oFwSheet} )
			EndIf
		EndIf
	Else
		Aviso(STR0035, STR0036, {STR0037}, 2)	//"Atenção!"#"Para utilizar o botão Colar Cálculo, necessário posicionar no item de recursos humanos que tenha formação de preço"{"OK"}
	EndIf

	FWRestRows( aSaveLines )
	RestArea(aArea)
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740LeTot
	Função para cálculo do desconto e valor total dos itens da locação

@sample 	At740LeTot( cTipoCalc )

@since		10/12/2013
@version	P11.90

@param 		cTipoCalc, Char, Define o formato do cálculo retornado o valor total ou o valor do desconto
				'1' = deve retornar o valor Total
				'2' = deve retornar o valor de desconto
@return 	nValor, Numeric, valor para atribuição no campo
/*/
//------------------------------------------------------------------------------
Function At740LeTot( cTipoCalc )

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oMdlAtivo := FwModelActive()
Local nValor    := 0

Default cTipoCalc := '1'

If oMdlAtivo <> Nil .And. (oMdlAtivo:GetId()=='TECA740' .Or. oMdlAtivo:GetId()=='TECA740F')

	If oMdlAtivo:GetModel('CALC_TEV') <> Nil
		nValor := oMdlAtivo:GetModel('CALC_TEV'):GetValue('TOT_ADICIO')
	Else
		nValor := IterTev( oMdlAtivo:GetModel('TEV_ADICIO') )
	EndIf

	If cTipoCalc == '2'
		nValor := ( nValor )*(oMdlAtivo:GetModel('TFI_LE'):GetValue('TFI_DESCON')/100)
	Else
		nValor := ( nValor )*(1-(oMdlAtivo:GetModel('TFI_LE'):GetValue('TFI_DESCON')/100))
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return nValor

//------------------------------------------------------------------------------
/*/{Protheus.doc} IterTev
	Soma os valores da TEV na definição de cobrança da locação

@sample 	IterTev( cTipoCalc )

@since		10/12/2013
@version	P11.90

@param 		oMdlTEV, Object, Model com as informações da cobrança da locação

@return 	nValor, Numeric, valor para atribuição no campo
/*/
//------------------------------------------------------------------------------
Function IterTev( oMdlTEV )

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local nValTev := 0
Local nLinhas := 0
Local nLinTev := oMdlTEV:GetLine()

For nLinhas := 1 To oMdlTEV:Length()

	oMdlTEV:GoLine( nLinhas )
	// não considera linhas deletadas e com o modo de cobrança como 5-Franquia/Excedente
	If !oMdlTEV:IsDeleted() .And. oMdlTEV:GetValue('TEV_MODCOB') <> "5"
		nValTev += oMdlTEV:GetValue('TEV_VLTOT')
	EndIf

Next nLinhas

oMdlTev:GoLine( nLinTev )

FWRestRows( aSaveLines )
RestArea(aArea)
Return nValTEV

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLin[Tab]
	Executa a atualização dos valores quando excluída linha de grid que replica informação
a grids superiores

@sample 	PreLinTEV(oMdlG, nLine, cAcao, cCampo)

@since		11/12/2013
@version	P11.90

@param 		oMdlGrid, Objeto, objeto do grid em validação
@param 		nLine, Numerico, linha em ação
@param 		cAcao, Caracter, tipo da ação (DELETE, UNDELETE, etc)
@param 		cCampo, Caracter, campo da ação

@return 	lOk, Logico, permite ou não a atualização
/*/
//------------------------------------------------------------------------------
Function PreLinTEV(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lOk      := .T.
Local oMdlFull := oMdlG:GetModel()
Local nValDel  := 0
Local nTotAtual := 0
Local nTotDesc := 0
Local oMdlUse  := Nil
Local lOrcPrc := SuperGetMv("MV_ORCPRC",,.F.)
Local nAux := 0
Local cLiberados := "TEV_VLRUNI|TEV_QTDE|TEV_SUBTOT|TEV_VLTOT|TEV_TXLUCR|TEV_LUCRO|TEV_ADM|TEV_TXADM"
Local cControle := "TEV_SUBTOT|TEV_VLTOT"

FWModelActive(oMdlG)//seta o model

If oMdlFull <> Nil .And. (oMdlFull:GetId()=='TECA740' .Or. oMdlFull:GetId()=='TECA740F')
	// só realiza a atualização dos valores quando o modo de cobrança for diferente de
	// 5-Franquia/Excedente
	If cAcao == 'SETVALUE' .and. !isInCallStack("at870eftrv")
		If !isInCallStack("FillModel") .AND. !( IsInCallStack("Initdados") .Or. IsInCallStack("AtCpyData") )
			If oMdlFull:GetModel('TFI_LE'):GetValue('TFI_ENCE') == '1' .Or. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1'
				If UPPER(cCampo) $ cLiberados
					If ( nAux := ASCAN(aEnceCpos, {|s|	s[1] == "TEV" .AND.;
															s[2] == (oMdlFull:GetModel('TFI_LE'):GetValue("TFI_COD") + oMdlG:GetValue('TEV_ITEM')) .AND.;
															s[3] == oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_CODIGO') .AND.;
															s[4] == cCampo }) ) > 0
						If aEnceCpos[nAux][5] < xValue
							lOk		 := .F.
							Help( ,, 'PreLinTEV',, STR0180, 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
						EndIf
					ElseIf UPPER(cCampo) $ cControle
						If xValue > xOldValue
							lOk		 := .F.
							Help( ,, 'PreLinTEV',, STR0180, 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
						Else
							AADD(aEnceCpos , {"TEV",(oMdlFull:GetModel('TFI_LE'):GetValue("TFI_COD") + oMdlG:GetValue('TEV_ITEM')),oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_CODIGO'),cCampo,xOldValue} )
						EndIf
					EndIf
				Else
					lOk		 := .F.
					Help( ,, 'PreLinTEV',, STR0149, 1, 0 ) //"Não é possível editar esse registro, pois o item de locação ou o local de atendimento estão finalizados"
				EndIf
			EndIf
		EndIf
	ElseIf cAcao == 'DELETE' .and. !Empty(oMdlG:getValue("TEV_MODCOB"))
		If oMdlFull:GetModel('TFI_LE'):GetValue('TFI_ENCE') == '1' .Or. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1'
			lOk := .F.
			Help( ,, 'PreLinTEV',, STR0149, 1, 0 ) //"Não é possível editar esse registro, pois o item de locação ou o local de atendimento estão finalizados"
		Else
			If oMdlG:GetValue('TEV_MODCOB') <> '5'

				//Valida se a linha pode ser deletada na Revisao de Contrato
				oMdlUse := oMdlFull:GetModel('TFI_LE')
				If IsIncallStack('At870Revis') .OR. IsInCallStack("AT870PlaRe") 
					lOk := !At740ExTEV(oMdlUse:GetValue('TFI_COD'),oMdlG:GetValue('TEV_ITEM'),oMdlG:IsInserted())

					If !lOk
						Help( ,, 'PreLinTEV',, STR0151, 1, 0 ) 	//Não é possível excluir esse item.
					EndIf
				EndIf

				//  Atualiza o item da locação vinculado
				If lOk
					nValDel := oMdlG:GetValue('TEV_VLTOT')
					nTotAtual := ( oMdlUse:GetValue('TFI_TOTAL') + oMdlUse:GetValue('TFI_VALDES') )
					nTotAtual -= nValDel

					nTotDesc := ( nTotAtual * ( oMdlUse:GetValue('TFI_DESCON')/100 ) )
					nTotAtual := ( nTotAtual * ( 1- ( oMdlUse:GetValue('TFI_DESCON')/100 ) ) )

					lOk := oMdlUse:SetValue('TFI_TOTAL', nTotAtual )
					lOk := oMdlUse:SetValue('TFI_VALDES', nTotDesc )
				EndIf
			EndIf
		EndIf
		ElseIf cAcao == 'UNDELETE'
			If oMdlG:GetValue('TEV_MODCOB') <> '5'
				//-----------------------------------------------
				//  Atualiza o item da locação vinculado
				oMdlUse := oMdlFull:GetModel('TFI_LE')

				nValDel := oMdlG:GetValue('TEV_VLTOT')
				nTotAtual := ( oMdlUse:GetValue('TFI_TOTAL') + oMdlUse:GetValue('TFI_VALDES') )
				nTotAtual += nValDel

				nTotDesc := ( nTotAtual * ( oMdlUse:GetValue('TFI_DESCON')/100 ) )
				nTotAtual := ( nTotAtual * ( 1 - ( oMdlUse:GetValue('TFI_DESCON')/100 ) ) )

				lOk := oMdlUse:SetValue('TFI_TOTAL', nTotAtual )
				lOk := oMdlUse:SetValue('TFI_VALDES', nTotDesc )
			EndIf

		EndIf
	EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lOk

//-----------------------------------------------
// atualização de exclusão da TFI
Function PreLinTFI(oMdlG, nLine, cAcao, cCampo)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lOk      := .T.
Local oMdlFull := FwModelActive()
Local nValDel  := 0
Local nTotAtual := 0
Local oMdlUse  := Nil
Local lOrcPrc := SuperGetMv("MV_ORCPRC",,.F.)

If oMdlFull <> Nil .And. (oMdlFull:GetId()=='TECA740' .Or. oMdlFull:GetId()=='TECA740F')

	If cAcao == 'SETVALUE' .and. !isInCallStack("at870eftrv") .And. !( IsInCallStack("Initdados") .Or. IsInCallStack("AtCpyData") )
		If ( oMdlG:GetValue('TFI_ENCE') == '1' .Or. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1' ) .And. !isInCallStack("FillModel") .And.;
			UPPER(cCampo) $ UPPER("tfi_tpcobr|tfi_perini|tfi_perfim|tfi_horain|tfi_horafi|tfi_descon|tfi_tes|tfi_enteqp|tfi_coleqp|tfi_apumed|tfi_osmont")

			lOk := .F.
			Help( ,, 'PreLinTFI',, STR0149, 1, 0 ) //"Não é possível editar esse registro, pois o item de locação ou o local de atendimento estão finalizados"
		EndIf
	ElseIf cAcao == 'DELETE'

		If (oMdlG:GetValue('TFI_ENCE') == '1' .Or. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1')

			lOk := .F.
			Help( ,, 'PreLinTFI',, STR0149, 1, 0 ) //"Não é possível editar esse registro, pois o item de locação ou o local de atendimento estão finalizados"

		Else
			If lOk .And. !Empty(oMdlG:GetValue('TFI_CHVTWO')) .And. !IsInCallStack('A740LoadFa') .And. !Empty(oMdlG:GetValue('TFI_PRODUT'))
				lOk := .F.
				Help(,,'A740TFITWOD',, STR0100,1,0)	//"Item não pode ser desabilitado, pois o mesmo foi adicionado pelo facilitador"
			EndIf

			//Valida se a linha pode ser deletada na Revisao
			If IsIncallStack('At870Revis') 
				lOk := !At740ExtIt('TFI', oMdlG:GetValue('TFI_COD'), 'TFI_CONTRT', oMdlG:IsInserted())

				If !lOk
					Help(,,'A740TFITWOD',, STR0151,1,0) //Não é possível excluir esse item.
				EndIf
			EndIf
			If lOk
				//-----------------------------------------------
				//  Atualiza o item da locação vinculado
				oMdlUse := oMdlFull:GetModel('TFL_LOC')

				nValDel := oMdlG:GetValue('TFI_TOTAL')
				nTotAtual := oMdlUse:GetValue('TFL_TOTLE')
				nTotAtual -= nValDel

				lOk := oMdlUse:SetValue('TFL_TOTLE', nTotAtual )
			EndIf
		EndIf
	ElseIf cAcao == 'UNDELETE'

		//-----------------------------------------------
		//  Atualiza o item da locação vinculado
		oMdlUse := oMdlFull:GetModel('TFL_LOC')

		nValDel := oMdlG:GetValue('TFI_TOTAL')
		nTotAtual := oMdlUse:GetValue('TFL_TOTLE')
		nTotAtual += nValDel

		lOk := oMdlUse:SetValue('TFL_TOTLE', nTotAtual )

		If lOk .And. !Empty(oMdlG:GetValue('TFI_CHVTWO')) .And. !IsInCallStack('A740LoadFa') .And. !Empty(oMdlG:GetValue('TFI_PRODUT'))
			lOk := .F.
			Help(,,'A740TFITWOH',, STR0101,1,0)	//"Item não pode ser habilitado, pois o mesmo foi adicionado pelo facilitador"
		EndIf

	EndIf
EndIf

Return lOk

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTFG
	Função de Prevalidacao da grade de Materiais de Implantação
@sample 	PreLinTFF(oMdlG, nLine, cAcao, cCampo, xValue, xOldValueo)
@param		[oMdlG],objeto,Representando o modelo de dados.
@param		[nLine],numerico,Numero da linha em edição
@param		[cAcao],Caractere,Ação sendo executada.
@param		[cCampo],Caractere,Campo onde o cursor está posicionado.
@param		[xValue],Indefinido,Novo valor inserido no campo.
@param		[xOldValue],Indefinido,Antigo valor do campo.

@since		17/03/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function PreLinTFG(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lOk      := .T.
Local oMdlFull := oMdlG:GetModel()
Local nValDel  := 0
Local nTotAtual := 0
Local oMdlUse  := Nil
Local lOrcPrc 	:= SuperGetMv("MV_ORCPRC",,.F.)
Local lHelp			:= .T.
Local lInclui	:= oMdlFull:GetOperation() == MODEL_OPERATION_INSERT
Local nAux := 0
Local cControle := "TFG_TOTAL|TFG_TOTGER"
Local cLiberados := "TFG_QTDVEN|TFG_TOTAL|TFG_VALDES|TFG_TOTGER|TFG_TXLUCR|TFG_TXADM|TFG_PRCVEN|TFG_DESCON|TFG_ADM|TFG_LUCRO|TFG_VLRMESMI|TFG_DPRMES|TFG_VLPRPA"
Local lDesagrp := oMdlFull:GetValue("TFJ_REFER","TFJ_DSGCN") == '1'
Local lUpdGrid	:= .T. //Indica se o grid pode ser atualizado - CanUpdateLine()
Local lCodTWO 	:= TFG->( ColumnPos('TFG_CODTWO') ) > 0

If oMdlFull <> Nil .And. (oMdlFull:GetId()=='TECA740' .Or. oMdlFull:GetId()=='TECA740F') .AND. !lTEC740FUn
	cModelId	:= oMdlFull:GetId()
	If !('CAN' $ cAcao) .AND. (IsInCallStack('At870Revis') .AND.!(IsInCallStack('AT870PlaRe') .OR. IsInCallStack('AplicaRevi'))) .AND. ;
		!AT870RevPl(TFJ->TFJ_CODIGO) .AND. AT870ItPla( oMdlG:GetValue("TFG_COD"), "TFG" )
		lOk := .F.
		lHelp	:= .F.
		Help(,,'PreLinTFG',, STR0298,1,0) // "Não é possivel alterar itens de uma Manutenção Planejada em uma revisão!."
	EndIf
	If isInCallStack("At870GerOrc")
		If cAcao $ "DELETE|SETVALUE" .AND. oMdlG:GetValue('TFG_COBCTR') != "2"
			lOk := .F.
			lHelp := .F.
			Help(,, "TFGNAOEXTRA",,STR0192,1,0,,,,,,{STR0193})//"Não é possível modificar itens que são cobrados no contrato através da rotina Item Extra" ## "Para alterar este item, realize uma Revisão do Contrato"
		EndIf

		If cAcao == "DELETE" .AND. oMdlG:GetValue("TFG_COBCTR") == "2" .AND. Len(TecGetApnt(oMdlG:GetValue("TFG_COD"),"TFS")) > 0
			lOk := .F.
			lHelp := .F.
			Help( ,, 'DELMIAPT',, STR0194, 1, 0 ) //"Não é possível apagar item com Apontamento de Material registrado"
		EndIf

		If cCampo == "TFG_QTDVEN" .AND. cAcao == "SETVALUE" .AND. xOldValue > xValue .AND. !(oMdlG:isInserted()) .AND.;
		 		(oMdlG:GetValue("TFG_SLD") - (At740getQt(oMdlG:GetValue("TFG_COD"),"TFG") - xValue) < 0)
			lOk := .F.
			lHelp := .F.
			Help(,, "SALDOMI",,STR0197,1,0,,,,,,{STR0198}) //"Operação de decréscimo não permitida pois não há saldo suficiente." ## "Verifique na rotina de Apontamento de Materiais (TECA890) a quantidade já apontada para este recurso"
		EndIf
	Endif

	If lOk
		If cAcao == 'DELETE' .and. !Empty(oMdlG:GetValue("TFG_PRODUT"))
			If oMdlG:GetValue("TFG_COBCTR") <> "2"
				If lDesagrp .AND. !EMPTY(oMdlG:GetValue("TFG_ITCNB"))
					If TecMedPrd(oMdlFull:GetValue("TFJ_REFER","TFJ_CONTRT"),;
										oMdlFull:GetValue("TFJ_REFER","TFJ_CONREV"),;
										oMdlFull:GetValue("TFL_LOC","TFL_PLAN"),;
										oMdlG:GetValue("TFG_PRODUT"),;
										oMdlG:GetValue("TFG_ITCNB")) > 0
						lOk := .F.
						lHelp := .F.
						Help(,,'A740DELMI',, STR0187,1,0) //"Itens com medições não podem ser apagados."
					EndIf
				EndIf
			Else
				lOk := (IsInCallStack("A600GrvOrc") .Or. IsInCallStack("At870GerOrc") )
			EndIf

			If lOk .AND. (isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") .OR. (FindFunction("AT870CtRev") .AND. AT870CtRev( oMdlFull:GetValue("TFJ_REFER", "TFJ_CODIGO") ) ))
				If lInclui .AND. (oMdlG:getValue("TFG_MODPLA") <> "1" .OR. ValidPlane( oMdlG:getValue("TFG_COD") , "TFG"))
					lOk := .F.
					lHelp	:= .F.
					Help(,,'PreLinTFG',, STR0297,1,0) // "Não é possivel excluir itens não planejados."
				ElseIf oMdlG:getValue("TFG_MODPLA") <> "1" .OR. !Empty(oMdlG:getValue("TFG_CODREL"))
					lOk := .F.
					lHelp	:= .F.
					Help(,,'PreLinTFG',, STR0297,1,0) // "Não é possivel excluir itens não planejados."
				EndIf
			EndIf

			If lOk .And. !Empty(oMdlG:GetValue('TFG_CHVTWO')) .And. !IsInCallStack('A740LoadFa') .And. !Empty(oMdlG:GetValue('TFG_PRODUT')) .And. !IsInCallStack('At740VlGMat')
				If !lCodTWO
					lOk := .F.
					Help(,,'A740TFGTWOD',, STR0100,1,0)	//"Item não pode ser desabilitado, pois o mesmo foi adicionado pelo facilitador"
				EndIf
			EndIf
			If (cModelId == 'TECA740' .AND. (oMdlFull:GetModel('TFF_RH'):GetValue('TFF_ENCE') == '1' .OR. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1')) .OR. ;
			   (cModelId == 'TECA740F' .AND. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1' )
			   lOK := .F.
			   lHelp := .F.
			   Help( ,, 'PreLinTFG',, STR0147, 1, 0 ) //"Não é possível editar esse registro, pois o Local de Atendimento ou Item de RH estão finalizados"
		   EndIf

			//Valida se a linha pode ser deletada na Revisao
			If (IsIncallStack('At870Revis') .OR. IsInCallStack("AT870PlaRe") ) .AND. lOk

				lOk := lOk .AND. !At740ExtIt('TFG', oMdlG:GetValue('TFG_COD'), 'TFG_CONTRT', oMdlG:IsInserted())
				
				If !lOk
					Help(,,'A740TFGTWOD',, STR0151,1,0) //Não é possível excluir esse item.
					lHelp := .F.
				EndIf
			EndIf
				
			If lOk .AND. oMdlG:GetValue('TFG_COBCTR') != "2"
				//-----------s------------------------------------
				//  Atualiza o item da locação vinculado
				If oMdlFull:GetId() == 'TECA740F'
					oMdlUse	:= oMdlFull:GetModel('TFL_LOC')

	
					nValDel	:= oMdlG:GetValue('TFG_TOTGER')
					nTotAtual	:= oMdlUse:GetValue('TFL_TOTMI')
					nTotAtual	-= nValDel
	
					lOk		:=  lOk .AND. oMdlUse:SetValue('TFL_TOTMI', nTotAtual ) .Or. IsInCallStack('A740LoadFa')
				Else
					oMdlUse	:= oMdlFull:GetModel('TFF_RH')
	
	
					nValDel	:= oMdlG:GetValue('TFG_TOTGER')
					nTotAtual	:= oMdlUse:GetValue('TFF_TOTMI')
					nTotAtual	-= nValDel
	
					lOk			:= lOk .AND. oMdlUse:SetValue('TFF_TOTMI', nTotAtual ) .Or. (IsInCallStack('A740LoadFa') .Or. IsInCallStack('TEC740NFAC'))
				EndIf
			EndIf
			If lOk .AND. TecVlPrPar()
				oMdlFull:LoadValue("TFL_LOC","TFL_VLPRPA",;
					oMdlFull:GetValue("TFL_LOC","TFL_VLPRPA")-oMdlG:GetValue("TFG_VLPRPA"))
			EndIf
		ElseIf cAcao == 'UNDELETE'
			If oMdlG:GetValue("TFG_COBCTR") <> "2"
				//-----------------------------------------------
				//  Atualiza o item da locação vinculado
				If oMdlFull:GetId() == 'TECA740F'
					oMdlUse := oMdlFull:GetModel('TFL_LOC')


					nValDel := oMdlG:GetValue('TFG_TOTGER')
					nTotAtual := oMdlUse:GetValue('TFL_TOTMI')
					nTotAtual += nValDel

					lOk := oMdlUse:SetValue('TFL_TOTMI', nTotAtual ) .Or. IsInCallStack('A740LoadFa')
				Else
					oMdlUse := oMdlFull:GetModel('TFF_RH')

					nValDel := oMdlG:GetValue('TFG_TOTGER')
					nTotAtual := oMdlUse:GetValue('TFF_TOTMI')
					nTotAtual += nValDel

					lOk := oMdlUse:SetValue('TFF_TOTMI', nTotAtual ) .Or. IsInCallStack('A740LoadFa')
				EndIf
			Else
				lOk := IsInCallStack("At870GerOrc")
			EndIf

			If lOk .And. !Empty(oMdlG:GetValue('TFG_CHVTWO')) .And. !IsInCallStack('A740LoadFa') .And. !Empty(oMdlG:GetValue('TFG_PRODUT'))
				lOk := .F.
				Help(,,'A740TFGTWOH',, STR0101,1,0)	//"Item não pode ser habilitado, pois o mesmo foi adicionado pelo facilitador"
			EndIf
			If lOk .AND. TecVlPrPar()
				oMdlFull:LoadValue("TFL_LOC","TFL_VLPRPA",;
					oMdlFull:GetValue("TFL_LOC","TFL_VLPRPA")+oMdlG:GetValue("TFG_VLPRPA"))
			EndIf
		ElseIf cAcao == "SETVALUE"
			
			If !IsInCallStack("ATCPYDATA") .And.;
				!IsInCallStack("A600GrvOrc") .And. !IsInCallStack("At870GerOrc") .And.;
				!IsInCallStack("LoadXmlData")
				If !(cCampo $ "TFG_VLRMESMI")
					lOk := oMdlG:GetValue("TFG_COBCTR") != "2"
				EndIf
			EndIf
			If !isInCallStack("FillModel") .and. !isInCallStack("at870eftrv") .AND. !( IsInCallStack("Initdados") .Or. IsInCallStack("AtCpyData") ) .AND.;
					!IsInCallStack('At870GerOrc')
				If cModelId == 'TECA740'
					If oMdlFull:GetModel('TFF_RH'):GetValue('TFF_ENCE') == '1' .OR. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1'
						If UPPER(cCampo) $ cLiberados
							If ( nAux := ASCAN(aEnceCpos, {|s|	s[1] == "TFG" .AND.;
																s[2] == oMdlG:GetValue('TFG_COD') .AND.;
																s[3] == oMdlFull:GetModel('TFF_RH'):GetValue('TFF_COD') .AND.;
																s[4] == cCampo }) ) > 0
								If aEnceCpos[nAux][5] < xValue
									lOk		 := .F.
									lHelp 	 := .F.
									Help( ,, 'PreLinTFG',, STR0180, 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
								EndIf
							ElseIf UPPER(cCampo) $ cControle
								If xValue > xOldValue
									lOk		 := .F.
									lHelp 	 := .F.
									Help( ,, 'PreLinTFG',, STR0180, 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
								Else
									AADD(aEnceCpos , {"TFG",oMdlG:GetValue('TFG_COD'),oMdlFull:GetModel('TFF_RH'):GetValue('TFF_COD'),cCampo,xOldValue} )
								EndIf
							ElseIf lDesagrp .And. (cCampo == 'TFG_PRCVEN')  .And. xValue == 0 
								lOk		 := .F.
								lHelp 	 := .F.
								Help( ,, 'PreLinTFG',, STR0290, 1, 0 ) //"Não é possível zerar este item, pois o parâmetro MV_GSDSGCN está desagrupado"                                                                                                                                                                                                                                                                                                                                                                                                                                      
							EndIf
						Else
							lOk := .F.
							lHelp := .F.
							Help( ,, 'PreLinTFG',, STR0147, 1, 0 ) //"Não é possível editar esse registro, pois o Local de Atendimento ou Item de RH estão finalizados"
						EndIf
					EndIf
				ElseIf cModelId == 'TECA740F'
					If oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1'
						If UPPER(cCampo) $ cLiberados
							If ( nAux := ASCAN(aEnceCpos, {|s|	s[1] == "TFG" .AND.;
																s[2] == oMdlG:GetValue('TFG_COD') .AND.;
																s[3] == oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_CODIGO') .AND.;
																s[4] == cCampo }) ) > 0
								If aEnceCpos[nAux][5] < xValue
									lOk		 := .F.
									lHelp 	 := .F.
									Help( ,, 'PreLinTFG',, STR0180, 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
								EndIf
							ElseIf UPPER(cCampo) $ cControle
								If xValue > xOldValue
									lOk		 := .F.
									lHelp 	 := .F.
									Help( ,, 'PreLinTFG',, STR0180, 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
								Else
									AADD(aEnceCpos , {"TFG",oMdlG:GetValue('TFG_COD'),oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_CODIGO'),cCampo,xOldValue} )
								EndIf
							EndIf
						Else
							lOk	:= .F.
							lHelp := .F.
							Help( ,, 'PreLinTFG',, STR0148, 1, 0 ) //"Não é possível editar esse registro, pois o local de atendimento está finalizado"
						EndIf
					EndIf
				EndIf
			EndIf
			If lOk .AND. TecVlPrPar()
				If cCampo == "TFG_VLPRPA" .AND. xValue != 0
					If oMdlG:GetValue('TFG_COBCTR') == '2'
						Help( ' ' , 1 , 'AT740PRPA' , , STR0265, 1 , 0 ) //"Não é possível informar este valor para itens extras."
						lOk 	:= .F.
						lHelp 	:= .F.
					ElseIf oMdlFull:GetValue("TFJ_REFER","TFJ_CNTREC") != '1'
						Help( ' ' , 1 , 'AT740PRPA' , , STR0266, 1 , 0 ) //"Campo disponível apenas para contratos recorrentes."
						lOk 	:= .F.
						lHelp 	:= .F.
					EndIf
				EndIf
			EndIf
			If lOk .AND. (isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") ) .AND. !(cCampo $ "TFG_PERINI|TFG_PERFIM")
				aStruct  := oMdlG:GetStruct():GetFields() 
				nPos := Ascan( aStruct, {|x| x[3] == cCampo })
				If nPos > 0 .AND. !aStruct[nPos][MODEL_FIELD_VIRTUAL]
					If !oMdlG:IsInserted() .AND. VldLineRvP( cCampo, xValue, IIF(Empty(oMdlG:getValue("TFG_CODREL")), oMdlG:getValue("TFG_COD"), oMdlG:getValue("TFG_CODREL")), "TFG", aStruct[nPos][4] == 'D' )
						oMdlG:LoadValue('TFG_MODPLA', "2")
					Else
						oMdlG:LoadValue('TFG_MODPLA', "1")
					EndIf
				EndIf
			EndIf
		EndIf

		If "DELETE"$cAcao .and. !Empty(oMdlG:GetValue("TFG_PRODUT"))
			If oMdlG:GetValue("TFG_COBCTR") <> "2" .AND. lOk .AND. oMdlFull:GetId() == 'TECA740F'
				If cAcao == 'DELETE'

					/*Ao deletar a linha do Grid, atualiza o valor do campo TFG_VLRMESMI para 0, corrigindo os totalizadores*/
					lUpdGrid	:= oMdlG:CanUpdateLine() //Indica se o grid pode ser atualizado - CanUpdateLine()
					If !lUpdGrid
						oMdlG:SetNoUpdateLine(.F.)
					EndIf
					oMdlG:SetValue('TFG_VLRMESMI',0)
					If !lUpdGrid
						oMdlG:SetNoUpdateLine(.T.)
					EndIf
				ElseIf cAcao == 'UNDELETE' .And. oMdlG:isDeleted()
					/*Ao recuperar a linha do Grid, atualiza o valor do campo TFG_VLRMESMI para o seu valor original, corrigindo os totalizadores*/
					lTEC740FUn := .T.
					oMdlG:UnDeleteLine() //Necessário fazer UNDELETE para o SetValue ocorrer. A variavel lTEC740FUn garante que esse UNDELETE não passe pelo PréValid
					oMdlG:SetValue('TFG_VLRMESMI',At740FTGMes( "TFG_MI", "TFG_PERINI", "TFG_PERFIM", "TFG_TOTGER" ))
					oMdlG:DeleteLine() //Volta a linha para o seu estado original, para que a cAcao de UNDELETE ocorra normalmente
					lTEC740FUn := .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If !lOk .AND. lHelp
	Help(,,"AT740OK",,STR0046,1,0) // "Operação não permitida para os itens adicionais!"
EndIf

Return lOk

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTFH
	Função de Prevalidacao da grade de Materiais de Consumo
@sample 	PreLinTFF(oMdlG, nLine, cAcao, cCampo, xValue, xOldValueo)
@param		[oMdlG],objeto,Representando o modelo de dados.
@param		[nLine],numerico,Numero da linha em edição
@param		[cAcao],Caractere,Ação sendo executada.
@param		[cCampo],Caractere,Campo onde o cursor está posicionado.
@param		[xValue],Indefinido,Novo valor inserido no campo.
@param		[xOldValue],Indefinido,Antigo valor do campo.

@since		17/03/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function PreLinTFH(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lOk      := .T.
Local oMdlFull := oMdlG:GetModel()
Local nValDel  := 0
Local nTotAtual := 0
Local oMdlUse  := Nil
Local cTipRev 	:= ''
Local lOrcPrc 	:= SuperGetMv("MV_ORCPRC",,.F.)
Local lInclui	:= oMdlFull:GetOperation() == MODEL_OPERATION_INSERT
Local cModelId
Local lHelp			:= .T.
Local nAux := 0
Local cControle := "TFH_TOTAL|TFH_TOTGER"
Local cLiberados := "TFH_QTDVEN|TFH_TOTAL|TFH_VALDES|TFH_TOTGER|TFH_TXLUCR|TFH_TXADM|TFH_PRCVEN|TFH_DESCON|TFH_ADM|TFH_LUCRO|TFH_VLRMESMC|TFH_DPRMES|TFH_VLPRPA"
Local lDesagrp := oMdlFull:GetValue("TFJ_REFER","TFJ_DSGCN") == '1'
Local lUpdGrid	:= .T. //Grid pode ser atualizado
Local lCodTWO 	:= TFH->( ColumnPos('TFH_CODTWO') ) > 0

If oMdlFull <> Nil .And. (oMdlFull:GetId()=='TECA740' .Or. oMdlFull:GetId()=='TECA740F') .AND. !lTEC740FUn
	cModelId	:= oMdlFull:GetId()

	If !('CAN' $ cAcao) .AND. (IsInCallStack('At870Revis') .AND.!(IsInCallStack('AT870PlaRe') .OR. IsInCallStack('AplicaRevi'))) .AND. ;
		!AT870RevPl(TFJ->TFJ_CODIGO) .AND. AT870ItPla( oMdlG:GetValue("TFH_COD"), "TFH" )
		lOk := .F.
		lHelp	:= .F.
		Help(,,'PreLinTFH',, STR0298,1,0) // "Não é possivel alterar itens de uma Manutenção Planejada em uma revisão!."
	EndIf

	If isInCallStack("At870GerOrc")
		If cAcao $ "DELETE|SETVALUE" .AND. oMdlG:GetValue('TFH_COBCTR') != "2"
			lOk := .F.
			lHelp := .F.
			Help(,, "TFHNAOEXTRA",,STR0192,1,0,,,,,,{STR0193})//"Não é possível modificar itens que são cobrados no contrato através da rotina Item Extra" ## "Para alterar este item, realize uma Revisão do Contrato"
		EndIf

		If cAcao == "DELETE" .AND. oMdlG:GetValue("TFH_COBCTR") == "2" .AND. Len(TecGetApnt(oMdlG:GetValue("TFH_COD"),"TFT")) > 0
			lOk := .F.
			lHelp := .F.
			Help( ,, 'DELMCAPT',, STR0194, 1, 0 ) //"Não é possível apagar item com Apontamento de Material registrado"
		EndIf

		If cCampo == "TFH_QTDVEN" .AND. cAcao == "SETVALUE" .AND. xOldValue > xValue .AND. !(oMdlG:isInserted()) .AND.;
		 		(oMdlG:GetValue("TFH_SLD") - (At740getQt(oMdlG:GetValue("TFH_COD"),"TFH") - xValue) < 0)
			lOk := .F.
			lHelp := .F.
			Help(,, "SALDOMC",,STR0197,1,0,,,,,,{STR0198}) //"Operação de decréscimo não permitida pois não há saldo suficiente." ## "Verifique na rotina de Apontamento de Materiais (TECA890) a quantidade já apontada para este recurso"
		EndIf

	Endif

	If lOk
		If cAcao == 'DELETE'.and. !Empty(oMdlG:GetValue("TFH_PRODUT"))
			If isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") .OR. ( FindFunction("AT870CtRev") .AND. AT870CtRev( oMdlFull:GetValue("TFJ_REFER", "TFJ_CODIGO")) )
				If lInclui .AND. (oMdlG:getValue("TFH_MODPLA") <> "1" .OR. ValidPlane( oMdlG:getValue("TFH_COD") , "TFH"))
					lOk := .F.
					lHelp	:= .F.
					Help(,,'PreLinTFH',, STR0297,1,0) // "Não é possivel excluir itens não planejados."
				ElseIf oMdlG:getValue("TFH_MODPLA") <> "1" .OR. !Empty(oMdlG:getValue("TFH_CODREL"))
					lOk := .F.
					lHelp	:= .F.
					Help(,,'PreLinTFH',, STR0297,1,0) // "Não é possivel excluir itens não planejados."
				EndIf
			EndIf
			
			If oMdlG:GetValue("TFH_COBCTR") <> "2"
				If lDesagrp .AND. !EMPTY(oMdlG:GetValue("TFH_ITCNB"))
					If TecMedPrd(oMdlFull:GetValue("TFJ_REFER","TFJ_CONTRT"),;
										oMdlFull:GetValue("TFJ_REFER","TFJ_CONREV"),;
										oMdlFull:GetValue("TFL_LOC","TFL_PLAN"),;
										oMdlG:GetValue("TFH_PRODUT"),;
										oMdlG:GetValue("TFH_ITCNB")) > 0
						lOk := .F.
						lHelp := .F.
						Help(,,'A740DELMC',, STR0187,1,0) //"Itens com medições não podem ser apagados."
					EndIf
				EndIf
			Else
				lOk := IsInCallStack("A600GrvOrc") .Or.;
				 		IsInCallStack('A740LoadFa') .OR. IsInCallStack("At870GerOrc")
			EndIf

			If lOk .And. !Empty(oMdlG:GetValue('TFH_CHVTWO')) .And. !IsInCallStack('A740LoadFa') .And. !Empty(oMdlG:GetValue('TFH_PRODUT')) .And. !IsInCallStack('At740VlGMat')
				If !lCodTWO
					lOk := .F.
					Help(,,'A740TFHTWOD',, STR0100,1,0)	//"Item não pode ser desabilitado, pois o mesmo foi adicionado pelo facilitador"
				EndIf 
			EndIf

			//Valida se a linha pode ser deletada na Revisao
			If (IsIncallStack('At870Revis') .OR. IsInCallStack("AT870PlaRe") ) .AND. lOk
				lOk := lOk .AND. !At740ExtIt('TFH', oMdlG:GetValue('TFH_COD'), 'TFH_CONTRT', oMdlG:IsInserted())

				If !lOk
					Help(,,'A740TFHTWOD',, STR0151,1,0) //Não é possível excluir esse item.
					lHelp := .F.
				EndIf
			EndIf

			If lOk .AND. oMdlG:GetValue("TFH_COBCTR") <> "2"
				//-----------------------------------------------
				//  Atualiza o item da locação vinculado
				If oMdlFull:GetId() == 'TECA740F'
					oMdlUse	:= oMdlFull:GetModel('TFL_LOC')
	
					nValDel	:= oMdlG:GetValue('TFH_TOTGER')
					nTotAtual	:= oMdlUse:GetValue('TFL_TOTMC')
					nTotAtual	-= nValDel
	
					lOk	:= oMdlUse:SetValue('TFL_TOTMC', nTotAtual ) .Or. IsInCallStack('A740LoadFa')
				Else
					oMdlUse	:= oMdlFull:GetModel('TFF_RH')
	
	
					nValDel	:= oMdlG:GetValue('TFH_TOTGER')
					nTotAtual	:= oMdlUse:GetValue('TFF_TOTMC')
					nTotAtual	-= nValDel
	
					lOk	:= oMdlUse:SetValue('TFF_TOTMC', nTotAtual ) .Or. (IsInCallStack('A740LoadFa') .Or. IsInCallStack('TEC740NFAC'))
				EndIf
			EndIf
			If lOk .AND. TecVlPrPar()
				oMdlFull:LoadValue("TFL_LOC","TFL_VLPRPA",;
					oMdlFull:GetValue("TFL_LOC","TFL_VLPRPA")-oMdlG:GetValue("TFH_VLPRPA"))
			EndIf
		ElseIf cAcao == 'UNDELETE'

			If oMdlG:GetValue("TFH_COBCTR") <> "2"
				//-----------------------------------------------
				//  Atualiza o item da locação vinculado
				If oMdlFull:GetId() == 'TECA740F'
					oMdlUse := oMdlFull:GetModel('TFL_LOC')


					nValDel := oMdlG:GetValue('TFH_TOTGER')
					nTotAtual := oMdlUse:GetValue('TFL_TOTMC')
					nTotAtual += nValDel

					lOk := oMdlUse:SetValue('TFL_TOTMC', nTotAtual )
				Else
					oMdlUse := oMdlFull:GetModel('TFF_RH')


					nValDel := oMdlG:GetValue('TFH_TOTGER')
					nTotAtual := oMdlUse:GetValue('TFF_TOTMC')
					nTotAtual += nValDel

					lOk := oMdlUse:SetValue('TFF_TOTMC', nTotAtual )
				EndIf
			Else
				lOk :=  isInCallStack("At870GerOrc")
			EndIf

			If lOk .And. !Empty(oMdlG:GetValue('TFH_CHVTWO')) .And. !IsInCallStack('A740LoadFa') .And. !Empty(oMdlG:GetValue('TFH_PRODUT'))
				lOk := .F.
				Help(,,'A740TFHTWOH',, STR0101,1,0)	//"Item não pode ser habilitado, pois o mesmo foi adicionado pelo facilitador"
			EndIf
			If lOk .AND. TecVlPrPar()
				oMdlFull:LoadValue("TFL_LOC","TFL_VLPRPA",;
					oMdlFull:GetValue("TFL_LOC","TFL_VLPRPA")+oMdlG:GetValue("TFH_VLPRPA"))
			EndIf
		ElseIf cAcao == "SETVALUE"
			If !IsInCallStack("ATCPYDATA") .And.;
				!IsInCallStack("A600GrvOrc") .And. !IsInCallStack("At870GerOrc") .And.;
				!IsInCallStack("LoadXmlData")
				If !(cCampo $ "TFH_VLRMESMC")
					lOk := oMdlG:GetValue("TFH_COBCTR") != "2"
				EndIf
			EndIf

			If !isInCallStack("FillModel") .and. !isInCallStack("at870eftrv") .AND. !( IsInCallStack("Initdados") .Or. IsInCallStack("AtCpyData") ) .AND.;
					 !IsInCallStack('At870GerOrc')
				If cModelId == 'TECA740'
					If oMdlFull:GetModel('TFF_RH'):GetValue('TFF_ENCE') == '1' .OR. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1'
						If UPPER(cCampo) $ cLiberados
							If ( nAux := ASCAN(aEnceCpos, {|s|	s[1] == "TFH" .AND.;
																s[2] == oMdlG:GetValue('TFH_COD') .AND.;
																s[3] == oMdlFull:GetModel('TFF_RH'):GetValue('TFF_COD') .AND.;
																s[4] == cCampo }) ) > 0
								If aEnceCpos[nAux][5] < xValue
									lOk		 := .F.
									lHelp 	 := .F.
									Help( ,, 'PreLinTFH',, STR0180, 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
								EndIf
							ElseIf UPPER(cCampo) $ cControle
								If xValue > xOldValue
									lOk		 := .F.
									lHelp 	 := .F.
									Help( ,, 'PreLinTFH',, STR0180, 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
								Else
									AADD(aEnceCpos , {"TFH",oMdlG:GetValue('TFH_COD'),oMdlFull:GetModel('TFF_RH'):GetValue('TFF_COD'),cCampo,xOldValue} )
								EndIf
							ElseIf lDesagrp .And. (cCampo == 'TFH_PRCVEN')  .And. xValue == 0 
								lOk		 := .F.
								lHelp 	 := .F.
								Help( ,, 'PreLinTFH',, STR0290, 1, 0 ) //"Não é possível zerar este item, pois o parâmetro MV_GSDSGCN está desagrupado"   
							EndIf
						Else
							lOk := .F.
							lHelp := .F.
							Help( ,, 'PreLinTFH',, STR0147, 1, 0 ) //"Não é possível editar esse registro, pois o Local de Atendimento ou Item de RH estão finalizados"
						EndIf
					EndIf
				ElseIf cModelId == 'TECA740F'
					If  oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1'
						If UPPER(cCampo) $ cLiberados
							If ( nAux := ASCAN(aEnceCpos, {|s|	s[1] == "TFH" .AND.;
																s[2] == oMdlG:GetValue('TFH_COD') .AND.;
																s[3] == oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_CODIGO') .AND.;
																s[4] == cCampo }) ) > 0
								If aEnceCpos[nAux][5] < xValue
									lOk		 := .F.
									lHelp 	 := .F.
									Help( ,, 'PreLinTFH',, STR0180, 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
								EndIf
							ElseIf UPPER(cCampo) $ cControle
								If xValue > xOldValue
									lOk		 := .F.
									lHelp 	 := .F.
									Help( ,, 'PreLinTFH',, STR0180, 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
								Else
									AADD(aEnceCpos , {"TFH",oMdlG:GetValue('TFH_COD'),oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_CODIGO'),cCampo,xOldValue} )
								EndIf
							EndIf
						Else
							lOk		:=  .F.
							lHelp	:=	.F.
							Help( ,, 'PreLinTFH',, STR0148, 1, 0 ) //"Não é possível editar esse registro, pois o local de atendimento está finalizado"
						EndIf
					EndIf
				EndIf
			EndIf
			If lOk .AND. (isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") ) .AND. !(cCampo $ "TFH_PERINI|TFH_PERFIM")
				aStruct  := oMdlG:GetStruct():GetFields() 
				nPos := Ascan( aStruct, {|x| x[3] == cCampo })
				If nPos > 0 .AND. !aStruct[nPos][MODEL_FIELD_VIRTUAL]
					If !oMdlG:IsInserted() .AND. VldLineRvP( cCampo, xValue, IIF(Empty(oMdlG:getValue("TFH_CODREL")), oMdlG:getValue("TFH_COD"), oMdlG:getValue("TFH_CODREL")), "TFH", aStruct[nPos][4] == 'D' )
						oMdlG:LoadValue('TFH_MODPLA', "2")
					Else
						oMdlG:LoadValue('TFH_MODPLA', "1")
					EndIf
				EndIf
			EndIf
			If lOk .AND. TecVlPrPar()
				If cCampo == "TFH_VLPRPA" .AND. xValue != 0
					If oMdlG:GetValue('TFH_COBCTR') == '2'
						Help( ' ' , 1 , 'AT740PRPA' , ,  STR0265, 1 , 0 ) //"Não é possível informar este valor para itens extras."
						lOk 	:= .F.
						lHelp 	:= .F.
					ElseIf oMdlFull:GetValue("TFJ_REFER","TFJ_CNTREC") != '1'
						Help( ' ' , 1 , 'AT740PRPA' , ,  STR0266, 1 , 0 ) //"Campo disponível apenas para contratos recorrentes."
						lOk 	:= .F.
						lHelp 	:= .F.
					EndIf
				EndIf
			EndIF
		EndIf

		If "DELETE"$cAcao .AND. !Empty(oMdlG:getValue("TFH_PRODUT"))
			If (cModelId == 'TECA740' .AND. (oMdlFull:GetModel('TFF_RH'):GetValue('TFF_ENCE') == '1' .OR. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1')) .OR. ;
				   (cModelId == 'TECA740F' .AND. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1' )

			   lOK := .F.
			   lHelp := .F.
			   Help( ,, 'PreLinTFH',, STR0147, 1, 0 ) //"Não é possível editar esse registro, pois o Local de Atendimento ou Item de RH estão finalizados"

			Else
				If oMdlG:GetValue("TFH_COBCTR") <> "2" .AND. lOk .AND. oMdlFull:GetId() == 'TECA740F'
					If cAcao == 'DELETE'
						/*Ao deletar a linha do Grid, atualiza o valor do campo TFH_VLRMESMC para 0, corrigindo os totalizadores*/
						lUpdGrid	:= oMdlG:CanUpdateLine() //Indica se o grid pode ser atualizado - CanUpdateLine()
						If !lUpdGrid
							oMdlG:SetNoUpdateLine(.F.)
						EndIf
						oMdlG:SetValue('TFH_VLRMESMC',0)
						If !lUpdGrid
							oMdlG:SetNoUpdateLine(.T.)
						EndIf

					ElseIf cAcao == 'UNDELETE' .And. oMdlG:isDeleted()
						/*Ao recuperar a linha do Grid, atualiza o valor do campo TFH_VLRMESMC para o seu valor original, corrigindo os totalizadores*/
						lTEC740FUn := .T.
						oMdlG:UnDeleteLine() //Necessário fazer UNDELETE para o SetValue ocorrer. A variavel lTEC740FUn garante que esse UNDELETE não passe pelo PréValid
						oMdlG:SetValue('TFH_VLRMESMC',At740FTGMes( "TFH_MC", "TFH_PERINI", "TFH_PERFIM", "TFH_TOTGER" ))
						oMdlG:DeleteLine() //Volta a linha para o seu estado original, para que a cAcao de UNDELETE ocorra normalmente
						lTEC740FUn := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If !lOk .AND. lHelp
	Help(,,"AT740OK",,STR0046,1,0) // "Operação não permitida para os itens adicionais!"
EndIf

Return lOk

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTFF
	Função de Prevalidacao da grade de Recursos Humanos
@sample 	PreLinTFF(oMdlG, nLine, cAcao, cCampo, xValue, xOldValueo)
@param		[oMdlG],objeto,Representando o modelo de dados.
@param		[nLine],numerico,Numero da linha em edição
@param		[cAcao],Caractere,Ação sendo executada.
@param		[cCampo],Caractere,Campo onde o cursor está posicionado.
@param		[xValue],Indefinido,Novo valor inserido no campo.
@param		[xOldValue],Indefinido,Antigo valor do campo.

@since		17/03/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function PreLinTFF(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local aStruct	:= {}
Local lOk      := .T.
Local oMdlFull := oMdlG:GetModel()
Local oMdlMC
Local oMdlMI
Local nValDel  := 0
Local nTotAtual := 0
Local oMdlUse  := Nil
Local lOkSly 	:= AliasInDic('SLY')
Local dDatIni
Local dDatFim
Local nMesVlr 	:= 0
Local nValMes	:= 0
Local nMatPrPa := 0
Local lOrcPrc 	:= SuperGetMv("MV_ORCPRC",,.F.)		//Verifica se usa a tabela de precificação
Local lAgrupado := SuperGetMv("MV_GSDSGCN",,"2") == '2'
Local lInclui	:= oMdlFull:GetOperation() == MODEL_OPERATION_INSERT
Local lHelp	:= .T.
Local nAux := 0
Local nX := 0
Local cLiberados := "TFF_QTDVEN|TFF_TOTAL|TFF_PRCVEN|TFF_LUCRO|TFF_TXLUCR|TFF_ADM|TFF_TXADM|TFF_SUBTOT|TFF_VALDES|TFF_DESCON|TFF_TOTMI|TFF_TOTMC|TFF_TOTMES|TFF_VLPRPA|TFF_PERFIM"
Local cControle := "TFF_SUBTOT|TFF_TOTAL|TFF_TOTMI|TFF_TOTMC"
Local lPrHora := TecABBPRHR()
Local lTecItExtOp := IsInCallStack("At190dGrOrc") 
Local cCodTFF := ""
Local cCodTFJ := ""
Local cTabTemp := ""
Local lCodTWO 	:= TFF->( ColumnPos('TFF_CODTWO') ) > 0

If oMdlFull <> Nil .And. (oMdlFull:GetId()=='TECA740' .Or. oMdlFull:GetId()=='TECA740F')
	If cCampo == "TFF_PERINI" .Or. cCampo == "TFF_PERFIM"
		dPerCron := xOldValue
	EndIf
	If IsInCallStack("AT870PlaRe") .AND. oMdlFull:GetOperation() == MODEL_OPERATION_UPDATE .AND.;
			cAcao == "SETVALUE" .AND. !EMPTY(oMdlG:GetValue("TFF_CODREL"))
		cCodTFF := oMdlG:GetValue("TFF_CODREL")
	Else
		If oMdlFull:GetOperation() == MODEL_OPERATION_UPDATE .AND. isInCallStack("At870Revis")
			cCodTFF := oMdlG:GetValue("TFF_COD")
			cCodTFJ := TFJ->TFJ_CODIGO

			cTabTemp := GetNextAlias()
			BeginSql Alias cTabTemp
				SELECT TFF_COD, TFF_CODPAI
				FROM %Table:TFF% TFF
				WHERE TFF.TFF_FILIAL = %xFilial:TFF% AND
				TFF.TFF_CODSUB = %Exp:cCodTFF% AND
				TFF.%notDel%
			EndSql
			If !(cTabTemp)->(EOF())
				cCodTFF := (cTabTemp)->TFF_COD
				cCodTFJ := POSICIONE("TFL",1,xFilial("TFL") + (cTabTemp)->TFF_CODPAI,"TFL_CODPAI")
			EndIf
			(cTabTemp)->(DbCloseArea())
		Else
			cCodTFF := oMdlG:GetValue("TFF_COD")
			cCodTFJ := TFJ->TFJ_CODIGO
		EndIf
	EndIf
	If !('CAN' $ cAcao) .AND. (IsInCallStack('At870Revis') .AND. !(IsInCallStack('AT870PlaRe') .OR. IsInCallStack('AplicaRevi'))) .AND. ;
		!AT870RevPl( IIF( isInCallStack("At870Revis") ,cCodTFJ , TFJ->TFJ_CODIGO ) ) .AND.;
				AT870ItPla( IIF( isInCallStack("At870Revis") , cCodTFF , oMdlG:GetValue("TFF_COD")), "TFF" ) .AND. !(cCampo $ cControle+"TFF_CONTRT|TFF_CONREV")
		lOk := .F.
		lHelp	:= .F.
		Help(,,'PreLinTFF',, STR0298,1,0) // "Não é possivel alterar itens de uma Manutenção Planejada em uma revisão!."
	EndIf
	If !IsInCallStack('At870GerOrc')
		If cAcao == 'SETVALUE'

			If oMdlFull:GetId()=='TECA740F'
				If (cCampo == 'TFF_PRCVEN') .And. !IsInCallStack('At740EEPC') .And. oMdlG:HasField('TFF_PROCES')
					oMdlG:LoadValue('TFF_PROCES',.F.)
				EndIf
			EndIf

			If  lOk .AND. !IsInCallStack("ATCPYDATA")  .And. !IsInCallStack("A600GrvOrc") .And. !IsInCallStack("LoadXmlData") .And. !IsInCallStack("InitDados")
				lOk := oMdlG:GetValue("TFF_COBCTR") != "2"
			EndIf

			If !isInCallStack("FillModel") .AND. !isInCallStack("at870eftrv") .AND. !( IsInCallStack("Initdados") .Or. IsInCallStack("AtCpyData") )
				If oMdlG:GetValue('TFF_ENCE') == '1' .OR. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1'
					If UPPER(cCampo) $ cLiberados
						If ( nAux := ASCAN(aEnceCpos, {|s|	s[1] == "TFF" .AND.;
																s[2] == oMdlG:GetValue('TFF_COD') .AND.;
																s[3] == oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_CODIGO') .AND.;
																s[4] == cCampo }) ) > 0
							If aEnceCpos[nAux][5] < xValue
								lOk		 := .F.
								lHelp 	 := .F.
								Help( ,, 'PreLinTFF',, STR0180, 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
							EndIf
						ElseIf UPPER(cCampo) $ cControle
							If xValue > xOldValue
								lOk		 := .F.
								lHelp 	 := .F.
								Help( ,, 'PreLinTFF',, STR0180, 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
							Else
								AADD(aEnceCpos , {"TFF",oMdlG:GetValue('TFF_COD'),oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_CODIGO'),cCampo,xOldValue} )
							EndIf
						ElseIf !lAgrupado .And. (cCampo == 'TFF_PRCVEN')  .And. xValue == 0 
							lOk		 := .F.
							lHelp 	 := .F.
							Help( ,, 'PreLinTFF',, STR0290, 1, 0 ) //"Não é possível zerar este item, pois o parâmetro MV_GSDSGCN está desagrupado"   
						EndIf
					Else
						lOk	  := .F.
						lHelp := .F.
						Help( ,, 'PreLinTFF',, STR0147, 1, 0 ) //Não é possível editar esse registro, pois o Local de Atendimento ou Item de RH estão finalizados"
					EndIf	
				EndIf
			EndIf

			If (oMdlFull:GetId()=='TECA740F')
				If (cCampo == 'TFF_PRCVEN') .And. !IsInCallStack('At740EEPC') .And. oMdlG:HasField('TFF_PROCES')
					oMdlG:LoadValue('TFF_PROCES',.F.)
				EndIf

			ElseIf (IsInCallStack('At870Revis') .OR. IsInCallStack("AT870PlaRe") ) .And. !( IsInCallStack("Initdados") .Or. IsInCallStack("AtCpyData") )

				IF oMdlG:GetValue('TFF_COBCTR') == '2' .AND. oMdlG:IsUpdated()
					Help( ' ' , 1 , 'AT740EXTRA' , ,  STR0064, 1 , 0 ) // "Não é permitida alteração de itens extras"
					lOk 	:= .F.
					lHelp 	:= .F.
				EndIf
			EndIf
		ElseIf cAcao == 'DELETE'
			If (isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") ) .OR. (FindFunction("AT870CtRev") .AND.AT870CtRev( oMdlFull:GetValue("TFJ_REFER", "TFJ_CODIGO")) )
				If lInclui .AND. (oMdlG:getValue("TFF_MODPLA") <> "1" .OR. ValidPlane( oMdlG:getValue("TFF_COD") , "TFF"))
					lOk := .F.
					lHelp	:= .F.
					Help(,,'PreLinTFF',, STR0297,1,0) // "Não é possivel excluir itens não planejados."
				ElseIf oMdlG:getValue("TFF_MODPLA") <> "1" .OR. !Empty(oMdlG:getValue("TFF_CODREL"))
					lOk := .F.
					lHelp	:= .F.
					Help(,,'PreLinTFF',, STR0297,1,0) // "Não é possivel excluir itens não planejados."
				EndIf
			EndIf
			If !isInCallStack("at870eftrv") .and. !Empty(oMdlG:getValue("TFF_PRODUT")) .AND. lOk
				If oMdlG:GetValue('TFF_ENCE') == '1' .OR. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1'
					lOk 	:= .F.
					lHelp	:= .F.
					Help( ,, 'PreLinTFF',, STR0289, 1, 0 ) //"Não é possível excluir esse registro, pois o Local de Atendimento ou Item de RH estão finalizados"
				EndIf

				//Valida se a linha pode ser deletada na Revisao
				If (IsIncallStack('At870Revis') .OR. IsInCallStack("AT870PlaRe") ) .AND. lOk
					lOk := lOk .And. At740ExTFF(oMdlFull)
					//lExiste := At870Find('TFF_RH','TFF_CODSUB',oMdlG:GetValue('TFF_COD'),'TFL_CODSUB',oMdlUse:GetValue('TFL_CODIGO'),'', '',.F.,lOrcPrc)
					
					If !lOk
						Help(,,"PreLinTFF",, STR0151,1,0) //Não é possível excluir esse item.
						lOk 	:= .F.
						lHelp 	:= .F.
					EndIf
				EndIf
				
				If lOk .And. !Empty(oMdlG:GetValue('TFF_CHVTWO')) .And. !IsInCallStack('A740LoadFa')  .And. !Empty(oMdlG:GetValue('TFF_PRODUT'))
					If !lCodTWO
						lOk := .F.
						Help(,,'A740TFFTWOD',, STR0100,1,0)	//"Item não pode ser desabilitado, pois o mesmo foi adicionado pelo facilitador"
					EndIf 
				EndIf
				If lOk
					//-----------------------------------------------
					//  Atualiza o item da locação vinculado
					oMdlUse := oMdlFull:GetModel('TFL_LOC')

					// valor do RH
					nValDel := oMdlG:GetValue('TFF_SUBTOT')
					nTotAtual := oMdlUse:GetValue('TFL_TOTRH')
					nTotAtual -= nValDel
					//nDifer	-= oMdlG:GetValue("TFF_TOTAL")
					
					lOk := oMdlUse:SetValue('TFL_TOTRH', nTotAtual )

					If lOrcPrc
						//valor mensal do RH
						dDatIni	:= oMdlG:GetValue('TFF_PERINI')
						dDatFim	:=  oMdlG:GetValue('TFF_PERFIM')

						nMesVlr := At740FDDiff( dDatIni, dDatFim )

						If nMesVlr > 0
							nValMes := ( nValDel / nMesVlr )
						EndIf

						nTotAtual := oMdlUse:GetValue('TFL_MESRH')
						nTotAtual -= nValMes

						lOk := oMdlUse:SetValue('TFL_MESRH', nTotAtual )
					EndIf

					// valor do Material de Implantação
					nValDel := oMdlG:GetValue('TFF_TOTMI')
					nTotAtual := oMdlUse:GetValue('TFL_TOTMI')
					nTotAtual -= nValDel

					lOk := oMdlUse:SetValue('TFL_TOTMI', nTotAtual )

					// valor do Material de Consumo
					nValDel := oMdlG:GetValue('TFF_TOTMC')
					nTotAtual := oMdlUse:GetValue('TFL_TOTMC')
					nTotAtual -= nValDel

					lOk := oMdlUse:SetValue('TFL_TOTMC', nTotAtual )
					If lOk .And. TFF->( ColumnPos("TFF_GERPLA")) > 0 .And. TFL->( ColumnPos("TFL_GERPLA")) > 0
						At984aGtTt("TFF_RH","TFF_GERPLA","TFL_LOC","TFL_GERPLA",oMdlG:GetValue("TFF_GERPLA"),cAcao)
					Endif
				EndIf
			EndIf

		ElseIf cAcao == 'UNDELETE'
			If lOk .And. !Empty(oMdlG:GetValue('TFF_CHVTWO')) .And. !IsInCallStack('A740LoadFa') .And. !Empty(oMdlG:GetValue('TFF_PRODUT'))
				If !lCodTWO
					lOk := .F.
					Help(,,'A740TFFTWOH',, STR0100,1,0)	//"Item não pode ser desabilitado, pois o mesmo foi adicionado pelo facilitador"
				Endif
			EndIf

			If lOk
				//-----------------------------------------------
				//  Atualiza o item da locação vinculado
				oMdlUse := oMdlFull:GetModel('TFL_LOC')

				// valor do RH
				nValDel := oMdlG:GetValue('TFF_SUBTOT')
				nTotAtual := oMdlUse:GetValue('TFL_TOTRH')
				nTotAtual += nValDel

				lOk := oMdlUse:SetValue('TFL_TOTRH', nTotAtual )

				//valor mensal do RH
				dDatIni	:= oMdlG:GetValue('TFF_PERINI')
				dDatFim	:=  oMdlG:GetValue('TFF_PERFIM')
				//nDifer	+= oMdlG:GetValue("TFF_TOTAL") 

				nMesVlr := At740FDDiff( dDatIni, dDatFim )

				If nMesVlr > 0
					nValMes := ( nValDel / nMesVlr )
				EndIf

				nTotAtual := oMdlUse:GetValue('TFL_MESRH')
				nTotAtual += nValMes

				lOk := oMdlUse:SetValue('TFL_MESRH', nTotAtual ) .And. Empty(oMdlG:GetValue('TFF_CHVTWO'))

				// valor do Material de Implantação
				nValDel := oMdlG:GetValue('TFF_TOTMI')
				nTotAtual := oMdlUse:GetValue('TFL_TOTMI')
				nTotAtual += nValDel

				lOk := oMdlUse:SetValue('TFL_TOTMI', nTotAtual )

				// valor do Material de Consumo
				nValDel := oMdlG:GetValue('TFF_TOTMC')
				nTotAtual := oMdlUse:GetValue('TFL_TOTMC')
				nTotAtual += nValDel

				lOk := oMdlUse:SetValue('TFL_TOTMC', nTotAtual )
				If lOk .And. TFF->( ColumnPos("TFF_GERPLA")) > 0 .And. TFL->( ColumnPos("TFL_GERPLA")) > 0
					At984aGtTt("TFF_RH","TFF_GERPLA","TFL_LOC","TFL_GERPLA",oMdlG:GetValue("TFF_GERPLA"),cAcao)
				Endif
			EndIf
		EndIf

		If lOk .And. lOkSly
			// Durante a revisão do contrato não deverá ser possível realizar alteração do turno ou da escala
			// de um item de recursos humanos caso exista um benefício vinculado sem uma data final definida
			If cAcao == 'SETVALUE' .AND. (IsInCallStack('At870Revis') .OR. IsInCallStack("AT870PlaRe") ) .And. !( IsInCallStack("Initdados") .Or. IsInCallStack("AtCpyData") )
				If cCampo $ "TFF_TURNO|TFF_ESCALA"
					If IsInCallStack("AT870PlaRe") .AND. POSICIONE("ABQ",3,xFilial("ABQ")+cCodTFF+xFilial("TFF"),"ABQ_ORIGEM") == 'CN9'
						lOk := .F.
						lHelp	:= .F.
						Help(,,'PreLinTFF',, STR0299,1,0) //"Não é permitido alterar a Escala de itens efetivos no processo de Revisão Planejada."
					EndIf
					If oMdlG:IsUpdated() .AND. lOk
						lOk := At740VerVB(cCodTFF)

						If !lOk
							lHelp := .F.
							Help(,,"PreLinTFF",, STR0081,1,0) // "Existem Vínculos de Benefícios ativos, não é possível realizar a alteração do turno ou da escala"
						EndIf
						If lOk .And. cCampo $ "TFF_ESCALA" .And. !At740VlEsc(cCodTFF,xOldValue)
							lOk   := .F.
							lHelp := .F.
						Endif
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		If cAcao $ "DELETE|SETVALUE"
			If lTecItExtOp .And. oMdlG:GetValue('TFF_ITEXOP') <> "1" 
				lOk := .F.
				lHelp := .F.
				Help(,, "TFFNAOEXTRA",, STR0268,1,0,,,,,,{STR0193})//"Não é possível modificar itens que não foram gerados pela rotina de Item Extra Operacional." ## "Para alterar este item, realize uma Revisão do Contrato"
			Elseif oMdlG:GetValue('TFF_COBCTR') != "2" 
				lOk := .F.
				lHelp := .F.
				Help(,, "TFFNAOEXTRA",,STR0192,1,0,,,,,,{STR0193})//"Não é possível modificar itens que são cobrados no contrato através da rotina Item Extra" ## "Para alterar este item, realize uma Revisão do Contrato"
			EndIf
		Endif
		
		If cAcao == "DELETE"
			If oMdlG:GetValue('TFF_COBCTR') == "2" .Or. (lTecItExtOp .And. oMdlG:GetValue('TFF_ITEXOP') <> "1" )
				If !(At740VerABB( oMdlG:GetValue("TFF_COD") ))
					lOk := .F.
					lHelp := .F.
					Help(,,STR0035,, STR0062, 1, 0) //'Atenção'#"Não é possivel remover o item extra, pois existe agendamento para o atendente!"
				EndIf
			Endif
		EndIf
	EndIf
	If cAcao == 'SETVALUE'
		If lPrHora
			If (cCampo == "TFF_QTDHRS")
				If LEN(ALLTRIM(xValue)) == 5 .AND. AT(":",xValue) == 0
					lOk := .F.
					lHelp 	 := .F.
					Help( " ", 1, "PreLinTFF", Nil, STR0256, 1 )	//"Horário inválido. Por favor, insira um horário no formato HH:MM"
				EndIf
				If AT(":",xValue) == 0 .AND. AtJustNum(Alltrim(xValue)) == Alltrim(xValue) .AND. lOk
					If LEN(Alltrim(xValue)) == 4
						xValue := LEFT(Alltrim(xValue),2) + ":" + RIGHT(Alltrim(xValue),2)
					ElseIf LEN(Alltrim(xValue)) == 2
						xValue := Alltrim(xValue) + ":00"
					ElseIf LEN(Alltrim(xValue)) == 1
						xValue := "0" + Alltrim(xValue) + ":00"
					EndIf
				EndIf
				If lOk
					If !AtVldHora(Alltrim(xValue), .T.)
						lOK := .F.
						lHelp	:= .F.
						Help( " ", 1, "PreLinTFF", Nil, STR0255, 1 ) // "O valor digitado não corresponde a um horario valido!"
					EndIf
				EndIf
				If TecConvHr(xOldValue) > TecConvHr(xValue)
					If At740APHR(cCodTFF)
						lOk := .F.
						lHelp := .F.
						Help( ,, 'PreLinTFF',, STR0254, 1, 0 ) //"Já existe agenda gerada não é possivel diminuir o tempo de horas."
					EndIf
				EndIf
			EndIf
			If (cCampo == "TFF_QTDVEN") .AND. !Empty(oMdlG:GetValue('TFF_QTDHRS'))
				If !(IsInCallStack('At870Revis') .OR. IsInCallStack("AT870PlaRe") )
					At740QTDHr( .F., xValue, xOldValue )
				EndIf
			EndIf
		EndIf
		If lOk .AND. cCampo == "TFF_VLPRPA" .AND. xValue != 0
			If oMdlG:GetValue('TFF_COBCTR') == '2'
				Help( ' ' , 1 , 'AT740PRPA' , ,  STR0265, 1 , 0 ) //"Não é possível informar este valor para itens extras."
				lOk 	:= .F.
				lHelp 	:= .F.
			ElseIf oMdlFull:GetValue("TFJ_REFER","TFJ_CNTREC") != '1'
				Help( ' ' , 1 , 'AT740PRPA' , , STR0266, 1 , 0 ) //"Campo disponível apenas para contratos recorrentes."
				lOk 	:= .F.
				lHelp 	:= .F.
			EndIf
		EndIf
	ElseIf cAcao $ "DELETE|UNDELETE"
		If lOk .AND. TecVlPrPar() .AND. oMdlFull:GetValue("TFJ_REFER","TFJ_CNTREC") == '1' .And. !lTecItExtOp .AND. !IsInCallStack("At870GerOrc")
			oMdlMC := oMdlFull:GetModel("TFH_MC")
			oMdlMI := oMdlFull:GetModel("TFG_MI")
			If cAcao == "DELETE"
				If !lOrcPrc
					For nX := 1 To oMdlMC:Length()
						If !EMPTY(oMdlMC:GetValue("TFH_PRODUT", nX)) .AND.;
								oMdlMC:GetValue("TFH_COBCTR", nX) != '2' .AND.;
								!oMdlMC:isDeleted(nX)
							nMatPrPa += oMdlMC:GetValue("TFH_VLPRPA", nX)
						EndIf
					Next nX
					For nX := 1 To oMdlMI:Length()
						If !EMPTY(oMdlMI:GetValue("TFG_PRODUT", nX)) .AND.;
								oMdlMI:GetValue("TFG_COBCTR", nX) != '2' .AND.;
								!oMdlMI:isDeleted(nX)
							nMatPrPa += oMdlMI:GetValue("TFG_VLPRPA", nX)
						EndIf
					Next nX
				EndIf
				oMdlFull:LoadValue("TFL_LOC","TFL_VLPRPA",;
					oMdlFull:GetValue("TFL_LOC","TFL_VLPRPA")-(oMdlG:GetValue("TFF_VLPRPA")+nMatPrPa))
			ElseIf cAcao == "UNDELETE"
				If !lOrcPrc
					For nX := 1 To oMdlMC:Length()
						If !EMPTY(oMdlMC:GetValue("TFH_PRODUT", nX)) .AND.;
								oMdlMC:GetValue("TFH_COBCTR", nX) != '2' .AND.;
								!oMdlMC:isDeleted(nX)
							nMatPrPa += oMdlMC:GetValue("TFH_VLPRPA", nX)
						EndIf
					Next nX
					For nX := 1 To oMdlMI:Length()
						If !EMPTY(oMdlMI:GetValue("TFG_PRODUT", nX)) .AND.;
								oMdlMI:GetValue("TFG_COBCTR", nX) != '2' .AND.;
								!oMdlMI:isDeleted(nX)
							nMatPrPa += oMdlMI:GetValue("TFG_VLPRPA", nX)
						EndIf
					Next nX
				EndIf
				oMdlFull:LoadValue("TFL_LOC","TFL_VLPRPA",;
					oMdlFull:GetValue("TFL_LOC","TFL_VLPRPA")+(oMdlG:GetValue("TFF_VLPRPA")+nMatPrPa))
			EndIf
		EndIf
	EndIf
EndIf

If !lOk .AND. lHelp
	Help(,,"AT740OK",,STR0046,1,0) // "Operação não permitida para os itens adicionais!"
EndIf

If !IsInCallStack('At870GerOrc') .AND. lOk .AND.;
		(isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") ) .AND. !(cCampo $ "TFF_PERINI|TFF_PERFIM")
	aStruct  := oMdlG:GetStruct():GetFields() 
	nPos := Ascan( aStruct, {|x| x[3] == cCampo })
	If nPos > 0 .AND. !aStruct[nPos][MODEL_FIELD_VIRTUAL]
		If !oMdlG:IsInserted() .AND. VldLineRvP( cCampo, xValue, IIF(EMPTY(oMdlG:getValue("TFF_CODREL")), oMdlG:getValue("TFF_COD"), oMdlG:getValue("TFF_CODREL")), "TFF", aStruct[nPos][4] == 'D' )
			oMdlG:LoadValue('TFF_MODPLA', "2")
		Else
			oMdlG:LoadValue('TFF_MODPLA', "1")
		EndIf
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lOk

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTFL
	Função de Prevalidacao da grade de locais de atendimento
@sample 	PreLinTFL(oMdlG, nLine, cAcao, cCampo)
@param		[oMdlG],objeto,Representando o modelo de dados.
@param		[nLine],numerico,Numero da linha em edição
@param		[cAcao],Caractere,Ação sendo executada.
@param		[cCampo],Caractere,Campo onde o cursor está posicionado.

@since		17/03/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function PreLinTFL1(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet := .T.
Local oMdlFull := If(oMdlG <> nil, oMdlG:GetModel(), nil)
Local lInclui	:= oMdlFull:GetOperation() == MODEL_OPERATION_INSERT
Local nAux := 0
Local cControle := "TFL_TOTAL"
Local cLiberados := "TFL_TOTRH|TFL_TOTAL|TFL_MESRH|TFL_TOTMI|TFL_TOTMC|TFL_MESMI|TFL_MESMC|TFL_TOTLE|TFL_VLPRPA"
Local lOk := .T.

If lRet .And. oMdlFull <> Nil .And.;
	!IsInCallStack('At870GerOrc')

	If !('CAN' $ cAcao) .AND. (IsInCallStack('At870Revis') .AND.!(IsInCallStack('AT870PlaRe') .OR. IsInCallStack('AplicaRevi'))) .AND. ;
		!AT870RevPl(TFJ->TFJ_CODIGO) .AND. AT870ItPla( oMdlG:GetValue("TFL_CODIGO"), "TFL" )
		If !(UPPER(cCampo) $ cLiberados)
			lRet := .F.
			Help(,,'PreLinTFL',, STR0298,1,0) // "Não é possivel excluir itens não planejados."
		EndIf
	EndIf

	If lRet
		If cAcao == 'SETVALUE'
			If cCampo == 'TFL_DESLOC'
				//  Atualiza o item da locação vinculado
				At740fATFL( oMdlFull:GetModel('TFL_LOC') )
			EndIf

			If  !isInCallStack("FillModel") .and. !isInCallStack("at870eftrv") .and. !isInCallStack("InitDados")

				If oMdlG:GetValue('TFL_ENCE') == '1'
					If UPPER(cCampo) $ cLiberados
						If ( nAux := ASCAN(aEnceCpos, {|s|	s[1] == "TFL" .AND.;
																s[2] == oMdlG:GetValue('TFL_CODIGO') .AND.;
																s[3] == oMdlFull:GetModel("TFJ_REFER"):GetValue("TFJ_CODIGO") .AND.;
																s[4] == cCampo }) ) > 0
							If aEnceCpos[nAux][5] < xValue
								Help(,,"PreLinTFL1",, STR0180, 1, 0) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
								lRet := .F.
							EndIf
						ElseIf UPPER(cCampo) $ cControle
							If xValue > xOldValue
								Help(,,"PreLinTFL1",, STR0180, 1, 0) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
								lRet := .F.
							Else
								AADD(aEnceCpos , {"TFL",oMdlG:GetValue('TFL_CODIGO'),oMdlFull:GetModel("TFJ_REFER"):GetValue("TFJ_CODIGO"),cCampo,xOldValue} )
							EndIf
						EndIf
					Else
						Help(,,"PreLinTFL1",, STR0150, 1, 0)
						lRet := .F.
					EndIf
				EndIf

			EndIf
			If lRet .AND.( (isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") ) .OR. isInCallStack("AplicaRevi") ) .AND. !(cCampo $ "TFH_DTINI|TFH_DTFIM")
				aStruct  := oMdlG:GetStruct():GetFields() 
				nPos := Ascan( aStruct, {|x| x[3] == cCampo })
				If nPos > 0 .AND. !aStruct[nPos][MODEL_FIELD_VIRTUAL]
					If !oMdlG:IsInserted() .AND. VldLineRvP( cCampo, xValue, IIF(Empty(oMdlG:getValue("TFL_CODREL")), oMdlG:getValue("TFL_CODIGO"), oMdlG:getValue("TFL_CODREL")), "TFL", aStruct[nPos][4] == 'D' )
						oMdlG:LoadValue('TFL_MODPLA', "2")
					Else
						oMdlG:LoadValue('TFL_MODPLA', "1")
					EndIf
				EndIf
			EndIf
		ElseIf cAcao == 'DELETE' .And. ((IsInCallStack('At870Revis') .OR. IsInCallStack("AT870PlaRe") ) .OR. (isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") ) .OR. (FindFunction("AT870CtRev") .AND. AT870CtRev( oMdlFull:GetValue("TFJ_REFER", "TFJ_CODIGO") )))
			If isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") 
				If lInclui .AND. (oMdlG:getValue("TFL_MODPLA") <> "1" .OR. ValidPlane( oMdlG:getValue("TFL_CODIGO") , "TFL"))
					lRet := .F.
					Help(,,'PreLinTFL1',, STR0297,1,0) // "Não é possivel excluir itens não planejados."
				ElseIf oMdlG:getValue("TFL_MODPLA") <> "1" .OR. !Empty(oMdlG:getValue("TFL_CODREL"))
					lRet := .F.
					Help(,,'PreLinTFL1',, STR0297,1,0) // "Não é possivel excluir itens não planejados."
				EndIf
			EndIf
			If (IsInCallStack('At870Revis') .OR. IsInCallStack("AT870PlaRe") ) .AND. !Empty(oMdlFull:GetModel('TFL_LOC'):GetValue("TFL_PLAN"))

				lRet := lRet .And. At740VlExl(oMdlFull)

			EndIf
			// Verifica no contrato agrupado se tem medição e o saldo sera menor.
			
			//Verifica quais itens podem ser deletados na Revisão de Contrato		
			lOk := At740ExtIt('TFL',oMdlFull:GetModel('TFL_LOC'):GetValue("TFL_CODIGO"), 'TFL_CONTRT', oMdlFull:GetModel('TFL_LOC'):IsInserted())

			If !lOk
				Help(,,"PreLinTFL1",, STR0151, 1, 0) //Não é possível excluir esse item.
			EndIf
		EndIf
	EndIf
EndIf

If lOk .And. (cAcao == 'UNDELETE' .Or. cAcao == 'DELETE')
 	If TFJ->( ColumnPos("TFJ_GERPLA")) > 0 .And. TFL->( ColumnPos("TFL_GERPLA")) > 0
		At984aGtTt("TFL_LOC","TFL_GERPLA","TFJ_REFER","TFJ_GERPLA",oMdlG:GetValue("TFL_GERPLA"),cAcao)
	Endif
Endif

FWRestRows( aSaveLines )
RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------l
/*/{Protheus.doc} PosLinTFF
	 Permite a inclusão de valores zerados para a cortesia

@sample		PosLinTFF()

@since		15/04/2014
@version	P12

/*/
//------------------------------------------------------------------------------
Function PosLinTFF(oMdlG, nLine, cAcao, cCampo)

Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet      	:= .T.
Local oMdlFull 		:= oMdlG:GetModel()
Local oMdlMI		:= oMdlFull:GetModel("TFG_MI")
Local oMdlMC		:= oMdlFull:GetModel("TFH_MC")
Local lPrHora 		:= TecABBPRHR()
Local lOrcPrc 	    := SuperGetMv("MV_ORCPRC",,.F.)

If oMdlFull <> Nil .And. (oMdlFull:GetId()=='TECA740' .Or. oMdlFull:GetId()=='TECA740F')
	If !cAcao == "DELETE" .And. !IsInCallStack("ATCPYDATA")
		If oMdlG:GetValue("TFF_COBCTR") == "1" .And. cAcao <> Nil
			lRet := At740VlVlr("TFF_RH","TFF_PRCVEN")
		EndIf
	EndIf
EndIf

If lRet
	If oMdlG:GetValue("TFF_INSALU") == "1" .And. oMdlG:GetValue("TFF_GRAUIN") <> "1"
		Help(,,"TFFINSALU1",, STR0066, 1, 0) //'Atenção'#"Itens que não possuem Insalubridade não devem ter Grau preenchido"
		lRet := .F.

	ElseIf oMdlG:GetValue("TFF_INSALU") <> "1" .And. oMdlG:GetValue("TFF_GRAUIN") == "1"
		Help(,,"TFFINSALU2",, STR0067, 1, 0) //'Atenção'#"Existem Itens que possuem Insalubridade sem o Grau preenchido"
		lRet := .F.
	ElseIf !Empty( oMdlG:GetValue("TFF_PRODUT") ) .And. Empty( oMdlG:GetValue("TFF_TURNO") ) .And. Empty( oMdlG:GetValue("TFF_ESCALA") ) .And. !IsInCallStack("A740LoadFa")
		Help(,, "RHTURNO",,STR0133,1,0,,,,,,{STR0134})  // "Campos de Turno e Escala não estão preenchidos." ###  "Preencha algum destes campos para prosseguir."
		lRet := .F.
	ElseIf !Empty(oMdlG:GetValue("TFF_PERFIM")) .AND. oMdlFull:GetValue("TFJ_REFER","TFJ_CNTREC")  == "1" .AND. oMdlG:GetValue('TFF_PERFIM') > oMdlFull:GetModel("TFL_LOC"):GetValue('TFL_DTFIM')
		Help( ,, 'PosLinTFF',, STR0288, 1, 0 ) //"Data de vigência final não está dentro da data do Local de atendimento."
		lRet := .F.
	EndIf
	If lPrHora .AND. !Empty(oMdlG:GetValue("TFF_ESCALA")) .AND. TecConvHr(oMdlG:GetValue("TFF_QTDHRS")) > 0 
		Help( ,, 'PreLinTFF',, STR0257, 1, 0 ) // "O campo TFF_QTDHRS foi preenchido, por favor exclua a a escala."
		lRet := .F.
	EndIf
	If lRet .AND. !lOrcPrc 
		If (( oMdlMI:Length() > 1 .OR. !Empty(oMdlMI:GetValue("TFG_PRODUT")) ) .OR. ( oMdlMC:Length() > 1 .OR. !Empty(oMdlMC:GetValue("TFH_PRODUT")) )) 
			lRet := VldDatas(oMdlFull)
		EndIf	
	EndIf
	If TecBHasGvg() .And. oMdlG:GetValue("TFF_GERVAG") == "2"
		If At740GerVag(oMdlG)
			Help( ,, 'TFF_GERVAG',, STR0309, 1, 0 ) //"Para itens que não vão gerar vaga operacional, os campos de Risco(TFF_RISCO), Qtd de Horas(TFF_QTDHRS),Insalubridade(TFF_INSALU) e Periculosidade(TFF_PERICU) não podem ser preenchidos"
			lRet := .F.
		EndIf	
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)

Return(lRet)


//------------------------------------------------------------------------------l
/*/{Protheus.doc} PosLinTFI
	 Permite a inclusão de valores zerados para a cortesia

@sample		PosLinTFI()

@since		07/12/2020
@version	P12

/*/
//------------------------------------------------------------------------------
Function PosLinTFI(oMdlG, nLine, cAcao, cCampo)

Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet      	:= .T.
Local oMdlFull 		:= oMdlG:GetModel()

If oMdlFull <> Nil .And. (oMdlFull:GetId()=='TECA740' .Or. oMdlFull:GetId()=='TECA740F')
	If !Empty(oMdlG:GetValue("TFI_PERFIM")) .AND. oMdlFull:GetValue("TFJ_REFER","TFJ_CNTREC") == "1" .AND. oMdlG:GetValue('TFI_PERFIM') > oMdlFull:GetModel("TFL_LOC"):GetValue('TFL_DTFIM')
		Help( ,, 'PosLinTFI',, STR0288, 1, 0 ) //"Data de vigência final não está dentro da data do Local de atendimento."
		lRet := .F.
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)

Return(lRet)
//-----------------------------------------------------------------------------
/*/{Protheus.doc} PosLinTFG
	 Permite a inclusão de valores zerados para a cortesia

@sample		PosLinTFG()

@since		16/04/2014
@version	P12

/*/
//------------------------------------------------------------------------------
Function PosLinTFG(oMdlG, nLine, cAcao, cCampo)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet      := .T.
Local oMdlFull := oMdlG:GetModel()
Local lOrcPrc 	:= SuperGetMv("MV_ORCPRC",,.F.)
Local nSld		:= 0
Local cMsgSolu	:= ""

If (IsIncallStack('At870Revis') .OR. IsInCallStack("AT870PlaRe") ) .And. oMdlFull <> Nil .And. (oMdlFull:GetId()=='TECA740' .Or. oMdlFull:GetId()=='TECA740F')
	DbSelectArea("TFG")
	DbSetOrder(1)
	If DbSeek( xFilial('TFG')+ oMdlG:GetValue("TFG_COD")) 
		nSld := oMdlG:GetValue("TFG_QTDVEN") - TFG->TFG_QTDVEN
		If nSld <> 0
			If (TFG->TFG_SLD + nSld) < 0
				cMsgSolu := STR0242 + cValTOChar(oMdlG:GetValue("TFG_QTDVEN")+((TFG->TFG_SLD + nSld)* -1))+STR0243+oMdlG:GetValue("TFG_COD") //"Não é possível reduzir a quantidade desse item, pois isso irá gerar inconsistência entre o apontado x orçado"//"Inclua quantidade igual ou maior que "##" ou estorne apontamentos do material de código: " 
				Help( " ", 1, "AT740TFGTQTD", Nil, STR0244, 1,,,,,,,;
						{cMsgSolu} ) 
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

If lRet .And. oMdlFull <> Nil .And. (oMdlFull:GetId()=='TECA740' .Or. oMdlFull:GetId()=='TECA740F')
	If !cAcao == "DELETE" .And. !IsInCallStack("ATCPYDATA")
		If oMdlG:GetValue("TFG_COBCTR") != "2" .And. cAcao <> Nil
			lRet := At740VlVlr("TFG_MI","TFG_PRCVEN")
		EndIf
	EndIf
EndIf

If lRet 
	lRet := VldDatas(oMdlG)
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)

Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} PosLinTFH
	 Permite a inclusão de valores zerados para a cortesia

@sample		PosLinTFH()

@since		16/04/2014
@version	P12

/*/
//------------------------------------------------------------------------------
Function PosLinTFH(oMdlG, nLine, cAcao, cCampo)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet      := .T.
Local oMdlFull := oMdlG:GetModel()
Local lOrcPrc 	:= SuperGetMv("MV_ORCPRC",,.F.)
Local nSld		:= 0
Local cMsgSolu	:= ""

If (IsIncallStack('At870Revis') .OR. IsInCallStack("AT870PlaRe") ) .And. oMdlFull <> Nil .And. (oMdlFull:GetId()=='TECA740' .Or. oMdlFull:GetId()=='TECA740F')
	DbSelectArea("TFH")
	DbSetOrder(1)
	If DbSeek( xFilial('TFH')+ oMdlG:GetValue("TFH_COD")) 
		nSld := oMdlG:GetValue("TFH_QTDVEN") - TFH->TFH_QTDVEN
		If nSld <> 0
			If (TFH->TFH_SLD + nSld) < 0
				cMsgSolu := STR0242 + cValTOChar(oMdlG:GetValue("TFH_QTDVEN")+((TFH->TFH_SLD + nSld)* -1))+STR0243+oMdlG:GetValue("TFH_COD") //"Não é possível reduzir a quantidade desse item, pois isso irá gerar inconsistência entre o apontado x orçado"//"Inclua quantidade igual ou maior que "##" ou estorne apontamentos do material de código: " 
				Help( " ", 1, "AT740TFHTQTD", Nil, STR0244, 1,,,,,,,;
						{cMsgSolu} ) 
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf
	
If oMdlFull <> Nil .And. (oMdlFull:GetId()=='TECA740' .Or. oMdlFull:GetId()=='TECA740F')
	If !cAcao == "DELETE" .And. !IsInCallStack("ATCPYDATA")
		If oMdlG:GetValue("TFH_COBCTR") != "2" .And. cAcao <> Nil
			lRet := At740VlVlr("TFH_MC","TFH_PRCVEN")
		EndIf
	EndIf
EndIf

If lRet 	
	lRet := VldDatas(oMdlG)
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)

Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} PosLinTFU
	Não permite a inserção de TFU_CODABN duplicado no contrato

@sample		PosLinTFU()

@since		09/08/2021
@version	P12
/*/
//------------------------------------------------------------------------------
Function PosLinTFU(oMdlHE, nLine, cAcao, cCampo)
Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local aCodHe		:= {}
Local lRet 			:= .T.
Local nX

For nX := 1 To oMdlHE:Length()
    oMdlHE:GoLine(nX)
	If !oMdlHE:IsDeleted()
		If EMPTY(aCodHe) .OR. ASCAN(aCodHe, oMdlHE:GetValue("TFU_CODABN")) == 0
			AADD(aCodHe, oMdlHE:GetValue("TFU_CODABN"))
		Else
			Help(,, "PosLinTFU",, "A hora extra de codigo " + oMdlHE:GetValue("TFU_CODABN") + " esta duplicada.", 1, 0) //"A competência " ## " está duplicada."
			lRet := .F.
			Exit
		EndIf
	EndIf
Next nX

FWRestRows( aSaveLines )
RestArea(aArea)

Return (lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VldUM
	 Valida a unidade de medida digitada

@sample		At740VldUM()

@since		19/12/2013
@version	P11.90

@return 	lValido, Logico, define se a unidade de medida é valida (.T.) ou não (.F.)
/*/
//------------------------------------------------------------------------------
Function At740VldUM()

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lValido := .F.

lValido := Empty( M->TEV_UM )

If !lValido
	DbSelectArea('SAH')
	SAH->( DbSetOrder( 1 ) )  // AH_FILIAL+AH_UNIMED

	lValido := SAH->( DbSeek( xFilial('SAH')+M->TEV_UM ) )

EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lValido

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740Reserv
	 Valida a alteração de qtde e as datas nos itens com reserva

@sample		At740Reserv()

@since		24/02/2014
@version	P12

@return 	lRet, Logico, define se prossegue com a alteração ou não
/*/
//------------------------------------------------------------------------------
Function At740Reserv( oMdl, cCampo, xValueNew, nLine, xValueOld )

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet        := .T.

If !IsInCallStack('At740CpyMdl') .And. !Empty( oMdl:GetValue('TFI_RESERV') )

	lRet := MsgNoYes( STR0039 + CRLF + ;  // 'Esta alteração fará com que a reserva seja cancelada'
				STR0040, STR0041 )  // 'Deseja prosseguir?' #### 'Aviso'

	If lRet
		aAdd( aCancReserv, { oMdl:GetValue('TFI_COD'), oMdl:GetValue('TFI_RESERV') } )
		oMdl:SetValue('TFI_RESERV', ' ' ) // remove a relação com a reserva
	EndIf

EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FinRes
	 Executa a finalização quando realiza a gravação do orçamento de serviços

@sample		At740FinRes()

@since		24/02/2014
@version	P12

@param 	oMdlOrcamento, objeto, objeto principal do orçamento de serviços
@param 	lGravação, logico, define se está na gravação ou no cancelamento (fechar sem salvar)
/*/
//------------------------------------------------------------------------------
Function At740FinRes( oOrcamento, lCommit )

Local aSave         := GetArea()
Local aSaveTFI       := TFI->( GetArea() )
Local aSaveTEW       := TEW->( GetArea() )
Local aSaveLines	:= FWSaveRows()
Local nLocais       := 0
Local nItensLE      := 0
Local oReserva      := FwLoadModel('TECA825C')
Local aRows         := FwSaveRows(oOrcamento)
Local oLocais       := oOrcamento:GetModel('TFL_LOC')
Local oItensLE      := oOrcamento:GetModel('TFI_LE')
Local nPosReserv     := 0
Local nTamDados      := 0
Local xAux          := Nil
Local lOk           := .T.

DbSelectArea('TFI')
TFI->( DbSetOrder( 6 ) ) // TFI_FILIAL+TFI_RESERV

For nLocais := 1 To oLocais:Length()

	oLocais:GoLine( nLocais )
	For nItensLE := 1 To oItensLE:Length()

		oItensLE:GoLine( nItensLE )
		nPosReserv := aScan( aCancReserv, {|x| x[1] == oItensLE:GetValue('TFI_COD') } )
		If nPosReserv > 0
			If lCommit .And. TFI->(DbSeek(xFilial('TFI')+aCancReserv[nPosReserv,2]))
				//---------------------------------------
				//   Executa o cancelamento das reservas
				oReserva:SetOperation(MODEL_OPERATION_UPDATE)

				At825CText( STR0042 )  // 'Item da venda de locação alterado'
				At825CTipo( DEF_RES_CANCELADA )

				lOk := oReserva:Activate()  // Ativa o objeto
				lOk := oReserva:VldData()  // Valida os dados
				lOk := oReserva:CommitData()   // realiza o cancelamento

				If !lOk
					oReserva:CancelData()
				EndIf

				oReserva:DeActivate()
			EndIf
			//---------------------------------------
			//   remove do array as informações da reserva
			nTamDados := Len(aCancReserv)
			aDel( aCancReserv, nPosReserv )
			aSize( aCancReserv, nTamDados-1 )
		EndIf

	Next nItensLE

Next nLocais

oReserva:Destroy()

FwRestRows( aRows, oOrcamento )
FWRestRows( aSaveLines )
RestArea( aSaveTEW )
RestArea( aSaveTFI )
RestArea( aSave )

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740LdLuc
	 Atualiza a Taxa de Lucro e administrativa para os demais itens

@sample		At740LdLuc()

@since		21/02/2013
@version	P11.90


/*/
//------------------------------------------------------------------------------
Function At740LdLuc(cTp)

Local oMdl   		:= FwModelActive()
Local oMdlLocal		:= oMdl:GetModel("TFL_LOC")
Local oMdlRH		:= oMdl:GetModel("TFF_RH")
Local oMdlMI		:= oMdl:GetModel("TFG_MI")
Local oMdlMC		:= oMdl:GetModel("TFH_MC")
Local oMdlLE 		:= oMdl:GetModel("TFI_LE")
Local oMdlUni 		:= Nil
Local oMdlArm		:= Nil
Local oMdlCobLe		:= oMdl:GetModel("TEV_ADICIO")
Local nLinLocal		:= 0
Local nLinRh		:= 0
Local nLinMi		:= 0
Local nLinMc		:= 0
Local nLinLe		:= 0
Local nLinCob 		:= 0
Local nPerc			:= 0
Local aSaveRows 	:= {}
Local lValid		:= .F.
Local aValid		:= {}
Local lGsOrcUnif 	:= FindFunction("TecGsUnif") .And. TecGsUnif()
Local nX			:= 0
Local lGsOrcArma 	:= FindFunction("TecGsArma") .And. TecGsArma()

aSaveRows := FwSaveRows()

If cTp == "1"
	nPerc := oMdl:GetModel( "TFJ_REFER" ):GetValue( "TFJ_LUCRO" )
Else
	nPerc := oMdl:GetModel( "TFJ_REFER" ):GetValue( "TFJ_ADM" )
EndIf

aValid := At740Valid(cTp,nPerc)

If Len(aValid) > 0
	If MsgYesNo(STR0043) //"Deseja substituir as taxas de valores já definidas para os itens?"
		lValid := .F.
	Else
		lValid := .T.
	EndIf
EndIf

For nLinLocal := 1 To oMdlLocal:Length()
	oMdlLocal:GoLine( nLinLocal )
	If !oMdlLocal:IsDeleted()
		For nLinRh := 1 to oMdlRH:Length() //Recursos humanos
			oMdlRH:GoLine( nLinRh ) //Posiciona na linha
			If !oMdlRH:IsDeleted() //Se a linha não estiver deletada
				If !Empty(oMdlRH:GetValue("TFF_PRODUT"))
					If cTp == "1" //1 = Taxa de Lucro
						If !lValid
							oMdlRH:SetValue("TFF_LUCRO",nPerc)
						Else
							//Nao substituir
							nPos := Ascan(aValid,{|x| x[2] == "TFF"+Alltrim(STR(nLinRh))+"1"})
							If nPos > 0
								oMdlRH:SetValue("TFF_LUCRO",aValid[nPos,1])
							Else
								oMdlRH:SetValue("TFF_LUCRO",nPerc)
							EndIf
						EndIf
					Else //2 = Taxa Administrativa
						If !lValid
							oMdlRH:SetValue("TFF_ADM",nPerc)
						Else
							//Nao substituir
							nPos := Ascan(aValid,{|x| x[2] == "TFF"+Alltrim(STR(nLinRh))+"2"})
							If nPos > 0
								oMdlRH:SetValue("TFF_ADM",aValid[nPos,1])
							Else
								oMdlRH:SetValue("TFF_ADM",nPerc)
							EndIf
						EndIf
					EndIf
				EndIf
				For nLinMi := 1 to oMdlMI:Length() //Materiais de Implantação
					oMdlMI:GoLine( nLinMi )
					If !oMdlMI:IsDeleted()
						If !Empty(oMdlMI:GetValue("TFG_PRODUT"))
							If cTp == "1" //1 = Taxa de Lucro
								If !lValid
									oMdlMI:SetValue("TFG_LUCRO",nPerc)
								Else
									//Nao substituir
									nPos := Ascan(aValid,{|x| x[2] == "TFG"+Alltrim(STR(nLinMi))+"1"})
									If nPos > 0
										oMdlMI:SetValue("TFG_LUCRO",aValid[nPos,1])
									Else
										oMdlMI:SetValue("TFG_LUCRO",nPerc)
									EndIf
								EndIf
							Else //2 = Taxa Administrativa
								If !lValid
									oMdlMI:SetValue("TFG_ADM",nPerc)
								Else
									//Nao substituir
									nPos := Ascan(aValid,{|x| x[2] == "TFG"+Alltrim(STR(nLinMi))+"2"})
									If nPos > 0
										oMdlMI:SetValue("TFG_ADM",aValid[nPos,1])
									Else
										oMdlMI:SetValue("TFG_ADM",nPerc)
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				Next nLinMi

				For nLinMc := 1 to oMdlMC:Length() //Materiais de Consumo
					oMdlMC:GoLine( nLinMc )
					If !oMdlMC:IsDeleted()
						If !Empty(oMdlMC:GetValue("TFH_PRODUT"))
							If cTp == "1" //1 = Taxa de Lucro
								If !lValid
									oMdlMC:SetValue("TFH_LUCRO",nPerc)
								Else
									//Nao substituir
									nPos := Ascan(aValid,{|x| x[2] == "TFH"+Alltrim(STR(nLinMc))+"1"})
									If nPos > 0
										oMdlMC:SetValue("TFH_LUCRO",aValid[nPos,1])
									Else
										oMdlMC:SetValue("TFH_LUCRO",nPerc)
									EndIf
								EndIf
							Else //2 = Taxa Administrativa
								If !lValid
									oMdlMC:SetValue("TFH_ADM",nPerc)
								Else
									//Nao substituir
									nPos := Ascan(aValid,{|x| x[2] == "TFH"+Alltrim(STR(nLinMc))+"2"})
									If nPos > 0
										oMdlMC:SetValue("TFH_ADM",aValid[nPos,1])
									Else
										oMdlMC:SetValue("TFH_ADM",nPerc)
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				Next nLinMc
				If lGsOrcUnif
					oMdlUni := oMdl:GetModel("TXPDETAIL")
					For nX := 1 to oMdlUni:Length() //Uniformes
						oMdlUni:GoLine( nX )
						If !oMdlUni:IsDeleted()
							If !Empty(oMdlUni:GetValue("TXP_CODUNI"))
								If cTp == "1" //1 = Taxa de Lucro
									If !lValid
										oMdlUni:SetValue("TXP_LUCRO",nPerc)
									Else
										//Nao substituir
										nPos := Ascan(aValid,{|x| x[2] == "TXP"+Alltrim(STR(nX))+"1"})
										If nPos > 0
											oMdlUni:SetValue("TXP_LUCRO",aValid[nPos,1])
										Else
											oMdlUni:SetValue("TXP_LUCRO",nPerc)
										EndIf
									EndIf
								Else //2 = Taxa Administrativa
									If !lValid
										oMdlUni:SetValue("TXP_ADM",nPerc)
									Else
										//Nao substituir
										nPos := Ascan(aValid,{|x| x[2] == "TXP"+Alltrim(STR(nX))+"2"})
										If nPos > 0
											oMdlUni:SetValue("TXP_ADM",aValid[nPos,1])
										Else
											oMdlUni:SetValue("TXP_ADM",nPerc)
										EndIf
									EndIf
								EndIf
							Endif
						Endif
					Next nX
				Endif
				If lGsOrcArma
					oMdlArm := oMdl:GetModel("TXQDETAIL")
					For nX := 1 to oMdlArm:Length() //Uniformes
						oMdlArm:GoLine( nX )
						If !oMdlArm:IsDeleted()
							If !Empty(oMdlArm:GetValue("TXQ_CODPRD"))
								If cTp == "1" //1 = Taxa de Lucro
									If !lValid
										oMdlArm:SetValue("TXQ_LUCRO",nPerc)
									Else
										//Nao substituir
										nPos := Ascan(aValid,{|x| x[2] == "TXQ"+Alltrim(STR(nX))+"1"})
										If nPos > 0
											oMdlArm:SetValue("TXQ_LUCRO",aValid[nPos,1])
										Else
											oMdlArm:SetValue("TXQ_LUCRO",nPerc)
										EndIf
									EndIf
								Else //2 = Taxa Administrativa
									If !lValid
										oMdlArm:SetValue("TXQ_ADM",nPerc)
									Else
										//Nao substituir
										nPos := Ascan(aValid,{|x| x[2] == "TXQ"+Alltrim(STR(nX))+"2"})
										If nPos > 0
											oMdlArm:SetValue("TXQ_ADM",aValid[nPos,1])
										Else
											oMdlArm:SetValue("TXQ_ADM",nPerc)
										EndIf
									EndIf
								EndIf
							Endif
						Endif
					Next nX
				Endif
			EndIf
		Next nLinRh

		For nLinLe := 1 To oMdlLE:Length()
			oMdlLE:GoLine( nLinLe )
			For nLinCob := 1 to oMdlCobLe:Length() //Cobrança de Locação
				oMdlCobLe:GoLine( nLinCob )
				If !oMdlCobLe:IsDeleted()
					If !Empty(oMdlCobLe:GetValue("TEV_MODCOB"))
						If cTp == "1" //1 = Taxa de Lucro
							If !lValid
								oMdlCobLe:SetValue("TEV_LUCRO",nPerc)
							Else
								//Nao substituir
								nPos := Ascan(aValid,{|x| x[2] == "TEV"+Alltrim(STR(nLinCob))+"1"})
								If nPos > 0
									oMdlCobLe:SetValue("TEV_LUCRO",aValid[nPos,1])
								Else
									oMdlCobLe:SetValue("TEV_LUCRO",nPerc)
								EndIf
							EndIf
						Else //2 = Taxa Administrativa
							If !lValid
								oMdlCobLe:SetValue("TEV_ADM",nPerc)
							Else
								//Nao substituir
								nPos := Ascan(aValid,{|x| x[2] == "TEV"+Alltrim(STR(nLinCob))+"2"})
								If nPos > 0
									oMdlCobLe:SetValue("TEV_ADM",aValid[nPos,1])
								Else
									oMdlCobLe:SetValue("TEV_ADM",nPerc)
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			Next nLinCob
		Next nLinLe
	EndIf
Next nLinLocal

FwRestRows( aSaveRows )

nTLuc := oMdl:GetModel("TFJ_REFER"):GetValue("TFJ_LUCRO")
nTAdm := oMdl:GetModel("TFJ_REFER"):GetValue("TFJ_ADM")

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VlAcr
	 Atualiza os valores de Lucro e da taxa administrativa para os demais itens

@sample		At740VlAcr()

@since		24/02/2013
@version	P11.90


/*/
//------------------------------------------------------------------------------
Function At740VlAcr(cTp)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oMdl   	:= FwModelActive()
Local oMdlItm	:= oMdl:GetModel("TEV_ADICIO")
Local nVlAcr	:= 0

If cTp == "1"
	nVlAcr := (oMdlItm:GetValue("TEV_LUCRO")/100)*oMdlItm:GetValue("TEV_SUBTOT")
	If nVlAcr == 0
		oMdlItm:SetValue("TEV_TXLUCR", nVlAcr)
	EndIf
Else
	nVlAcr := (oMdlItm:GetValue("TEV_ADM")/100)*oMdlItm:GetValue("TEV_SUBTOT")
	If nVlAcr == 0
		oMdlItm:SetValue("TEV_TXADM", nVlAcr)
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return nVlAcr

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740LdLuc
	 Atualiza a Taxa de Lucro e administrativa para os demais itens

@sample		At740LdLuc()

@since		21/02/2013
@version	P11.90


/*/
//------------------------------------------------------------------------------
Function At740VlTEV(cModel)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oMdl   		:= FwModelActive()
Local oMdlTEV		:= oMdl:GetModel(cModel)
Local nVlr			:= 0
Local nVlAcrLuc	:= 0
Local nVlAcrAdm	:= 0

nVlAcrLuc := (1+(oMdlTEV:GetValue("TEV_LUCRO")/100))*oMdlTEV:GetValue("TEV_SUBTOT")
nVlAcrAdm := (1+(oMdlTEV:GetValue("TEV_ADM")/100))*oMdlTEV:GetValue("TEV_SUBTOT")

nVlr := (nVlAcrLuc + nVlAcrAdm)-(oMdlTEV:GetValue("TEV_SUBTOT"))

FWRestRows( aSaveLines )
RestArea(aArea)
Return nVlr


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740MatAc
	Gatilho dos valores de Lucro e da taxa administrativa para os itens de materiais

@sample		At740MatAc()

@since		24/02/2013
@version	P11.90


/*/
//------------------------------------------------------------------------------
Function At740MatAc(cTp,cModel,cTab)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oMdl   	:= FwModelActive()
Local oMdlItm	:= oMdl:GetModel(cModel)
Local nPerc	:= 0
Local nVlAcr	:= 0
Local nQtd	:= oMdlItm:GetValue(cTab+"_QTDVEN")
Local nPrcVen := oMdlItm:GetValue(cTab+"_PRCVEN")

If cTp == "1"
	nPerc := oMdlItm:GetValue(cTab+"_LUCRO") / 100
Else
	nPerc := oMdlItm:GetValue(cTab+"_ADM") / 100
EndIf

nVlAcr := ROUND((nPerc * nPrcVen), TamSX3("CNB_VLUNIT")[2]) * nQtd

FWRestRows( aSaveLines )
RestArea(aArea)
Return nVlAcr

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VlTot
	 Gatilho para preencher o campo total geral dos itens de materiais

@sample		At740VlTot()

@since		21/02/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740VlTot(cModel,cTab)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oMdl   	:= FwModelActive()
Local oMdlItm	:= oMdl:GetModel(cModel)
Local nVlr		:= 0
Local nVlrLuc := 0
Local nVlrAdm := 0
Local nPercLucro := (1+(oMdlItm:GetValue(cTab+"_LUCRO")/100))
Local nPercAdm := (1+(oMdlItm:GetValue(cTab+"_ADM")/100))
Local nPrcVen := oMdlItm:GetValue(cTab+"_PRCVEN")
Local nQtdVen := oMdlItm:GetValue(cTab+"_QTDVEN")

nVlrLuc := nQtdVen * ROUND(nPrcVen * nPercLucro, TamSX3("CNB_VLUNIT")[2])
nVlrAdm := nQtdVen * ROUND(nPrcVen * nPercAdm, TamSX3("CNB_VLUNIT")[2])

nVlr := (nVlrLuc + nVlrAdm)-(nQtdVen)*nPrcVen

FWRestRows( aSaveLines )
RestArea(aArea)
Return nVlr

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740RhVlr
	 Gatilho para os itens de recursos humanos

@sample		At740RhVlr()

@since		21/02/2013
@version	P11.90


/*/
//------------------------------------------------------------------------------
Function At740RhVlr(cTp)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oMdl   	:= FwModelActive()
Local oMdlItm	:= oMdl:GetModel("TFF_RH")
Local nQtde	:= oMdlItm:GetValue("TFF_QTDVEN")
Local nPrc		:= oMdlItm:GetValue("TFF_PRCVEN")
Local nVlAcr	:= 0
Local nPercAux:= 0
Local nVlrLucro	:= 0

If cTp == "1"
	nVlrLucro	:= oMdlItm:GetValue("TFF_LUCRO")/100
	nVlAcr 		:= ROUND(nVlrLucro * nPrc, TamSX3("CNB_VLUNIT")[2]) * nQtde
	If nVlAcr == 0
		oMdlItm:SetValue("TFF_TXLUCR", nVlAcr)
	EndIf
Else
	nVlAcr := ROUND(((oMdlItm:GetValue("TFF_ADM")/100) * nPrc), TamSX3("CNB_VLUNIT")[2] ) * nQtde
	If nVlAcr == 0
		oMdlItm:SetValue("TFF_TXADM", nVlAcr)
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return nVlAcr

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740Valid
	 Validação dos campos das Taxas de Lucro e administrativa nos itens

@sample		At740Valid()

@since		21/02/2013
@version	P11.90
/*/
//------------------------------------------------------------------------------
Function At740Valid(cTp,nPerct)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oMdl   		:= FwModelActive()
Local oMdlLocal	:= oMdl:GetModel("TFL_LOC")
Local oMdlRH		:= oMdl:GetModel("TFF_RH")
Local oMdlMI		:= oMdl:GetModel("TFG_MI")
Local oMdlMC		:= oMdl:GetModel("TFH_MC")
Local oMdlLE		:= oMdl:GetModel("TEV_ADICIO")
Local oMdlUni		:= Nil
Local oMdlArm		:= Nil
Local nLinLocal	:= 0
Local nLRh			:= 0
Local nLMi			:= 0
Local nLMc			:= 0
Local nLLe			:= 0
Local aDados		:= {}
Local lGsOrcUnif := FindFunction("TecGsUnif") .And. TecGsUnif()
Local nX			:= 0
Local lGsOrcArma 	:= FindFunction("TecGsArma") .And. TecGsArma()

For nLinLocal := 1 To oMdlLocal:Length()

	oMdlLocal:GoLine( nLinLocal )

	If !oMdlLocal:IsDeleted()

		For nLRh := 1 to oMdlRH:Length() //Recursos humanos

			oMdlRH:GoLine( nLRh )

			If !oMdlRH:IsDeleted()

				If cTp == "1"
					If !Empty(oMdlRH:GetValue("TFF_LUCRO")) .AND. oMdlRH:GetValue("TFF_LUCRO") <> nPerct .AND. oMdlRH:GetValue("TFF_LUCRO") <> nTLuc
						aAdd(aDados,{oMdlRH:GetValue("TFF_LUCRO"),"TFF"+Alltrim(STR(nLRh))+cTp})
					EndIf
				Else
					If !Empty(oMdlRH:GetValue("TFF_ADM")) .AND. oMdlRH:GetValue("TFF_ADM") <> nPerct .AND. oMdlRH:GetValue("TFF_ADM") <> nTAdm
						aAdd(aDados,{oMdlRH:GetValue("TFF_ADM"),"TFF"+Alltrim(STR(nLRh))+cTp})
					EndIf
				EndIf

				For nLMi := 1 to oMdlMI:Length() //Materiais de Implantação

					oMdlMI:GoLine( nLMi )

						If !oMdlMI:IsDeleted()

							If cTp == "1"
								If !Empty(oMdlMI:GetValue("TFG_LUCRO")) .AND. oMdlMI:GetValue("TFG_LUCRO") <> nPerct .AND. oMdlMI:GetValue("TFG_LUCRO") <> nTLuc
									aAdd(aDados,{oMdlMI:GetValue("TFG_LUCRO"),"TFG"+Alltrim(STR(nLMi))+cTp})
								EndIf
							Else
								If !Empty(oMdlMI:GetValue("TFG_ADM")) .AND. oMdlMI:GetValue("TFG_ADM") <> nPerct .AND. oMdlMI:GetValue("TFG_ADM") <> nTAdm
									aAdd(aDados,{oMdlMI:GetValue("TFG_ADM"),"TFG"+Alltrim(STR(nLMi))+cTp})
								EndIf
							EndIf

						EndIf

				Next nLMi

				For nLMc := 1 to oMdlMC:Length() //Materiais de Consumo

					oMdlMC:GoLine( nLMc )

						If !oMdlMC:IsDeleted()

							If cTp == "1"
								If !Empty(oMdlMC:GetValue("TFH_LUCRO")) .AND. oMdlMC:GetValue("TFH_LUCRO") <> nPerct .AND. oMdlMC:GetValue("TFH_LUCRO") <> nTLuc
									aAdd(aDados,{oMdlMC:GetValue("TFH_LUCRO"),"TFH"+Alltrim(STR(nLMc))+cTp})
								EndIf
							Else
								If !Empty(oMdlMC:GetValue("TFH_ADM")) .AND. oMdlMC:GetValue("TFH_ADM") <> nPerct .AND. oMdlMC:GetValue("TFH_ADM") <> nTAdm
									aAdd(aDados,{oMdlMC:GetValue("TFH_ADM"),"TFH"+Alltrim(STR(nLMc))+cTp})
								EndIf
							EndIf

						EndIf

				Next nLMc
			
				If lGsOrcUnif
					oMdlUni	:= oMdl:GetModel("TXPDETAIL")
					For nX := 1 to oMdlUni:Length() //Uniformes
						oMdlUni:GoLine( nX )
						If !oMdlUni:IsDeleted()
							If cTp == "1"
								If !Empty(oMdlUni:GetValue("TXP_LUCRO")) .AND. oMdlUni:GetValue("TXP_LUCRO") <> nPerct .AND. oMdlUni:GetValue("TXP_LUCRO") <> nTLuc
									aAdd(aDados,{oMdlUni:GetValue("TXP_LUCRO"),"TXP"+Alltrim(STR(nX))+cTp})
								EndIf
							Else
								If !Empty(oMdlUni:GetValue("TXP_ADM")) .AND. oMdlUni:GetValue("TXP_ADM") <> nPerct .AND. oMdlUni:GetValue("TXP_ADM") <> nTAdm
									aAdd(aDados,{oMdlUni:GetValue("TXP_ADM"),"TXP"+Alltrim(STR(nX))+cTp})
								EndIf
							EndIf
						EndIf
					Next nX				
				Endif
				If lGsOrcArma
					oMdlArm	:= oMdl:GetModel("TXQDETAIL")
					For nX := 1 to oMdlArm:Length() //Armamento
						oMdlArm:GoLine( nX )
						If !oMdlArm:IsDeleted()
							If cTp == "1"
								If !Empty(oMdlArm:GetValue("TXQ_LUCRO")) .AND. oMdlArm:GetValue("TXQ_LUCRO") <> nPerct .AND. oMdlArm:GetValue("TXQ_LUCRO") <> nTLuc
									aAdd(aDados,{oMdlArm:GetValue("TXQ_LUCRO"),"TXQ"+Alltrim(STR(nX))+cTp})
								EndIf
							Else
								If !Empty(oMdlArm:GetValue("TXQ_ADM")) .AND. oMdlArm:GetValue("TXQ_ADM") <> nPerct .AND. oMdlArm:GetValue("TXQ_ADM") <> nTAdm
									aAdd(aDados,{oMdlArm:GetValue("TXQ_ADM"),"TXQ"+Alltrim(STR(nX))+cTp})
								EndIf
							EndIf
						EndIf
					Next nX				
				Endif

			EndIf

		Next nLRh


		For nLLe := 1 to oMdlLE:Length() //Cobrança de Locação

			oMdlLE:GoLine( nLLe )

			If !oMdlLE:IsDeleted()

				If cTp == "1"
					If !EMpty(oMdlLE:GetValue("TEV_LUCRO")) .AND. oMdlLE:GetValue("TEV_LUCRO") <> nPerct .AND. oMdlLE:GetValue("TEV_LUCRO") <> nTLuc
						aAdd(aDados,{oMdlLE:GetValue("TEV_LUCRO"),"TEV"+Alltrim(STR(nLLe))+cTp})
					EndIf
				Else
					If !Empty(oMdlLE:GetValue("TEV_ADM")) .AND. oMdlLE:GetValue("TEV_ADM") <> nPerct .AND. oMdlLE:GetValue("TEV_ADM") <> nTAdm
						aAdd(aDados,{oMdlLE:GetValue("TEV_ADM"),"TEV"+Alltrim(STR(nLLe))+cTp})
					EndIf
				EndIf

			EndIf

		Next nLLe

	EndIf

Next nLinLocal

FWRestRows( aSaveLines )
RestArea(aArea)
Return aDados
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VlVlr
Função para validação dos valores para os recursos humanos
@sample 	At740VlVlr(oModel,cCpoSelec)
@since		15/04/2014
@version	P12
@return 	lRet, Lógico, retorna .T. se data for válida.
@param  	cModelo, Caracter, nome do modelo de dados principal.
@param  	cCpoSelec, Caracter, nome do campo da data selecionada para validação.
/*/
//------------------------------------------------------------------------------
Function At740VlVlr(cModel,cCpoSelec,oModel)

Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oMdl			:= Nil
Local nPrcVenda		:= 0
Local lCobrContr	:= .F.
Local lRet			:= .T.
Local lPermLocZero 	:= At680Perm( , __cUserId, '032' )

Default oModel		:= FwModelActive()

If oModel != Nil
	If (oModel:GetId() == "TECA740" .Or. oModel:GetId() == "TECA740F")
		oMdl := oModel:GetModel(cModel)
	Else
		oMdl := oModel
	EndIf
	If oMdl != Nil

		nPrcVenda	:= oMdl:GetValue(cCpoSelec)

		If nPrcVenda < 0
			Help(,,"At740VlVlr",,STR0114,1,0) //"O valor do preço de venda não pode ser negativo."
			lRet := .F.
		Else
			If Left(cCpoSelec,3) == "TFF"
				lCobrContr := (oMdl:GetValue("TFF_COBCTR") <> "2")
			ElseIf Left(cCpoSelec,3) == "TFG"
				lCobrContr := (oMdl:GetValue("TFG_COBCTR") <> "2")
			ElseIf Left(cCpoSelec,3) == "TFH"
				lCobrContr := (oMdl:GetValue("TFH_COBCTR") <> "2")
			EndIf

			If nPrcVenda == 0 .And. lCobrContr .And. !IsInCallStack("LoadXmlData") .And.;
				!IsInCallStack("ATCPYDATA") .And.;
				!IsInCallStack("A600GrvOrc") .And. !IsInCallStack("At870GerOrc") .And.;
				!IsInCallStack("At740FTrgG") .And. !lPermLocZero

				Help(,,"At740VlVlr",,STR0054,1,0) // "O valor do preço de venda deve ser maior do que zeros."
				lRet	:= .F.
			EndIf
		EndIf

	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VldTFF

Valida se existe o recurso ja criado na configuração de alocação do atendente

@sample 	At740VldTFF(cContrato,cCodTFF,cFilTFF)

@since		24/04/2014
@version	P12

@return 	lRet, Lógico, retorna .T. se data for válida.

@param  	cContrato, Caracter, Numero do contrato para a consistencia.
@param  	cCodTFF, Caracter, codigo do recurso para a consistencia.
@param  	cFilTFF, Caracter, filial do recurso para a consistencia.

/*/
//------------------------------------------------------------------------------
Function At740VldTFF( cContrato, cCodTFF, cFilTFF )

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet  := .T.

Default cFilTFF := xFilial("TFF", cFilAnt)

dbSelectArea("ABQ")
ABQ->(DbSetOrder(3)) //ABQ_FILIAL + ABQ_CODTFF+ ABQ_FILTFF

		 
lRet := !ABQ->(DbSeek(xFilial("ABQ")+ cCodTFF + cFilTFF))

FWRestRows( aSaveLines )
RestArea(aArea)
Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} AT740F4()
Rotina consulta estoque através do último produto SB1 que está posicionado


@author arthur.colado
@since 07/04/2014
@version 1.0
/*/
//------------------------------------------------------------------------------
Function AT740F4()

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local cFilBkp := cFilAnt
Local cReadVar := ReadVar()
Local cConsulta := ""
Local oMdl := FwModelActive()

Set Key VK_F4 TO

If FWModeAccess("SB1")=="E"
	cFilAnt := SB1->B1_FILIAL
EndIf

If cReadVar == "M->TFG_QTDVEN"
	cConsulta := oMdl:getModel("TFG_MI"):GetValue("TFG_PRODUT")
EndIf

If cReadVar == "M->TFH_QTDVEN"
	cConsulta := oMdl:getModel("TFH_MC"):GetValue("TFH_PRODUT")
EndIf

If !Empty(cConsulta)
	MaViewSB2(cConsulta)
EndIf

cFilAnt := cFilBkp
Set Key VK_F4 TO AT740F4()

FWRestRows( aSaveLines )
RestArea(aArea)
Return Nil

/*/{Protheus.doc} At740Refre
Reposiciona grid do local de atendimento
@since 20/08/2014
@version 11.9
@param oView, objeto, View Orçamento de Serviços

/*/
Function At740Refre(oView)
Local aIdsModels 	:= oView:GetModelsIds()
Local aFolder		:= {}
Local lTecItExtOp 	:= IsInCallStack("At190dGrOrc")
Local cCodLoc 		:= ""
Local aArea			:= GetArea()

If oView:GetOperation() <> MODEL_OPERATION_VIEW
	If lTecItExtOp .And. !Empty(cCodLoc :=  At190dGetLc())
		oView:GetModel("TFL_LOC"):SeekLine({{"TFL_LOCAL",cCodLoc}})
		oView:Refresh("TFL_LOC")
	Else
		oView:GoLine('TFL_LOC',1) 	//VIEW_LOC
	Endif
	If aScan( aIdsModels, {|x| x=='TFF_RH' } ) > 0
		oView:GoLine('TFF_RH',1) 	//VIEW_RH
	EndIf
	If aScan( aIdsModels, {|x| x=='TFI_LE' } ) > 0
		oView:GoLine('TFI_LE',1) 	//VIEW_LE
	EndIf
EndIf

//Controle dos totais do recorrente
If oView:GetModel():GetId() == "TECA740F"
	aFolder := oView:GetFolderActive("ABAS", 2)

	If oView:GetOperation() == MODEL_OPERATION_INSERT
		oView:HideFolder("ABAS", STR0138,2) // "Resumo Geral Recorrente"
	Else
		If TFJ->TFJ_CNTREC == '1'
			oView:HideFolder("ABAS", STR0139,2) // "Resumo Geral
		Else
			oView:HideFolder("ABAS", STR0138,2) // "Resumo Geral Recorrente"
		EndIf
	EndIf

	oView:SelectFolder("ABAS", aFolder[2],2) // "Locais de Atendimento"

Endif

RestArea(aArea)
Return

/*/{Protheus.doc} At740VlSeq
Valida a Sequencia do Turno
@since 20/08/2014
@version 11.9
@param oModel, objeto, MOdel do Orçamento de Serviços
@return lRet, Sequencia do turno existente

/*/
Function At740VlSeq(oModel)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet			:= .T.
Local cFil			:= ""
Local cSeq			:= ""
Local cTno			:= ""
Local oTFF			:= Nil
Local aAreaSPJ	:= SPJ->(GetArea())

Default oModel := FwModelActive()

oTFF := oModel:GetModel("TFF_RH")

If oTFF <> Nil

	cTno := oTFF:GetValue("TFF_TURNO")
	cSeq := oTFF:GetValue("TFF_SEQTRN")

	If !Empty(cSeq)
		cFil	:= xFilial( "SPJ" , xFilial("SRA") )
		lRet := SPJ->( MsSeek( cFil + cTno + cSeq , .F. ) )

		If !( lRet )
			Help( ' ' , 1 , 'SEQTURNINV' , , OemToAnsi( STR0055 ) , 1 , 0 ) //Sequencia Nao Cadastrada Para o Turno
		EndIf
	EndIf
EndIf

RestArea(aAreaSPJ)
FWRestRows( aSaveLines )
RestArea(aArea)
Return( lRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VerVB

Função para validar se existe um vinculo de beneficio que ainda esta ativo, isto é,
com a data final não preenchida - LY_DTFIM para o item do RH.

@sample 	At740VerVB(cCodTFF)

@since		24/06/2015
@version	P12

@return 	lRet, Lógico

@param  	cCodTFF, Caracter, codigo do item do RH

/*/
//------------------------------------------------------------------------------
Function At740VerVB(cCodTFF)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet			:= .T.
Local cAliasSLY	:= GetNextAlias()

IF !Empty(cCodTFF)
	// Filtra os Beneficios
	BeginSql Alias cAliasSLY
		COLUMN LY_DTFIM AS DATE
		SELECT	LY_DTFIM
		FROM %table:SLY% SLY
		WHERE
			SLY.LY_FILIAL = %xFilial:SLY% AND
			SUBSTRING(SLY.LY_CHVENT,1,6) = %Exp:cCodTFF% AND
			SLY.LY_DTFIM = ' ' AND
			SLY.%NotDel%
 	EndSql

	lRet := (cAliasSLY)->(Eof())

	DbSelectArea(cAliasSLY)
	(cAliasSLY)->(DbCloseArea())
ENDIF

FWRestRows( aSaveLines )
RestArea(aArea)
RETURN lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F740LockGrd

Verifica se as Grids filhas poderão ser alteradas ou não de acordo com a escolha do campo
TFJ_GESMAT no cabeçalho

@author Serviços
@since 22/06/2015
@version P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function F740LockGrd(oMdlGer)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local cGesMat := M->TFJ_GESMAT
Local lRet := .T.
Local lMINoIns := .F.
Local lMCNoIns := .F.
Default oMdlGer	:= FWModelActive() //Recuperando o model ativo da interface


//Quando o campo gestão de materiais for Material por valor ou percentual do recurso
//eu não permito manutenções nas Grids de Material de Implantação e Material de Consumo
If !IsInCallStack("At870GerOrc")

	If cGesMat == '2' .Or. cGesMat == '3'

		lMINoIns := .T.
		lMCNoIns := .T.
	ElseIf cGesMat == "4" //MI/Por Item/MC por valor
		lMCNoIns := .T.

	ElseIf cGesMat == "5" //MI por valor / MC por Item

		lMINoIns := .T.

	EndIf

	oMdlGer:GetModel('TFG_MI'):SetNoInsertLine(lMINoIns)
	oMdlGer:GetModel('TFG_MI'):SetNoUpdateLine(lMINoIns)
	oMdlGer:GetModel('TFG_MI'):SetNoDeleteLine(lMINoIns)

	oMdlGer:GetModel('TFH_MC'):SetNoInsertLine(lMCNoIns)
	oMdlGer:GetModel('TFH_MC'):SetNoUpdateLine(lMCNoIns)
	oMdlGer:GetModel('TFH_MC'):SetNoDeleteLine(lMCNoIns)
EndIf

If oMdlGer:GetValue('TFF_RH','TFF_ENCE') == '1'
	oMdlGer:GetModel('TFH_MC'):SetNoInsertLine(.T.)
	oMdlGer:GetModel('TFG_MI'):SetNoInsertLine(.T.)
EndIf



FWRestRows( aSaveLines )
RestArea(aArea)
Return ( lRet )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F740VldCmp

Verifica se o campo pode ser alterado de acordo com o tipo de gestão de material selecionado

@author Serviços
@since 22/06/2015
@version P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At740VlMat()

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet    := .T.
Local cCmp    := Readvar()
Local oModel	:= FWModelActive() //Recuperando o model ativo da interface
Local oMdlVld	:= oModel:GetModel("TFF_RH")
Local cGesMat := oModel:GetModel('TFJ_REFER'):GetValue('TFJ_GESMAT')

Local nVlrAnt := 0
Local nVlrAtu := 0

//Tratamento pois o gatilho executa a validação quando outros campos são alimentados
If 'TFF_VLRMAT' $ cCmp

	nVlrAnt := ( ( oMdlVld:GetValue('TFF_QTDVEN') * oMdlVld:GetValue('TFF_PRCVEN') ) * (oMdlVld:GetValue('TFF_PERMAT')/100 ) )
	nVlrAtu := oMdlVld:GetValue('TFF_VLRMAT')

	If ( Empty( cGesMat ) .Or. cGesMat == '1' .Or. cGesMat == '3' )
		If  nVlrAnt <> nVlrAtu
			Help(,,'At740VlMat',,STR0069,1, 0 ) //"Este campo somente pode ser editado quando a Gestão de Materiais for igual a 'Material Por Valor'"
			lRet := .F.
		EndIf
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return ( lRet )

/*/
At740TDS


@sample 	At740TDS()

@since		20/07/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740TDS()

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local cCodTCZ  := ""
Local cDescTCZ := ""
Local oMdl   	 := FwModelActive()

If oMdl:GetId()=="TECA740" .Or. oMdl:GetId()=="TECA740F"

	cCodTCZ := oMdl:GetModel( "TDS_RH" ):GetValue( "TDS_CODTCZ" )
	cDescTCZ:= Posicione("TCZ",1,xFilial("TCZ") + cCodTCZ ,"TCZ->TCZ_DESC")

EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return(cDescTCZ)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VlGMat

@sample 	At740VlGMat()
@since		20/07/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Function At740VlGMat()

Local aArea		:= {}
Local aSaveLines	:= {}
Local oModel := FwModelActive()
Local oMdlTFJ :=  oModel:GetModel("TFJ_REFER")
Local cGESMat := oMdlTFJ:GetValue('TFJ_GESMAT')
Local lMaterial := (cGESMat  == "1" .Or. Empty(oMdlTFJ:GetValue('TFJ_GESMAT')))
Local nI := 0
Local nJ := 0
Local nX := 0
Local oMdlTFL :=	NIL
Local oMdlTFF :=	NIL
Local oMdlTFG :=	NIL
Local oMdlTFH :=	NIL
Local oView := NIL
Local nOldTFL := NIL
Local nOldTFF := NIL
Local lRet := .T.
Local lZera := .F.

Local lCanDel	:= .F.

If Empty(cGESMat)
	cGESMat := "1"
EndIf

If cGESMat = "3"
	Help(,,"At740VlGMat", , STR0208,1, 0) //"Gestão de Material por percentual desabilitada, selecione a gestão por Valor e informe o campo percentual no item de RH"
	lRet := .F.
Else
	If ExistFunc("At890NGMat") .AND. At890NGMat()
		//Verifica se a nova gestão de materiais está habilitada
		lRet := cGESMat $ "1245"
	Else
		lRet := cGESMat $ "12"
	EndIf
EndIf



If lRet
	aArea		:= GetArea()
	aSaveLines	:= FWSaveRows()
	//Verifica se há valores de materiais
	oMdlTFL :=	oModel:GetModel("TFL_LOC")
	oMdlTFF :=	oModel:GetModel("TFF_RH")
	oMdlTFG :=	oModel:GetModel("TFG_MI")
	oMdlTFH :=	oModel:GetModel("TFH_MC")
	oView := FwViewActive()
	nOldTFL := oMdlTFL:GetLine()
	nOldTFF := oMdlTFF:GetLine()

	For nI:=1 To oMdlTFL:Length()
		oMdlTFL:GoLine(nI)
		For nJ:=1 To oMdlTFF:Length()
			oMdlTFF:GoLine(nJ)

			//Verifica se há valor preenchido ou se possui material informado
			If ( ( lMaterial .AND.  (oMdlTFF:GetValue("TFF_VLRMAT") != 0  .OR.  oMdlTFF:GetValue("TFF_PERMAT") != 0))  .Or. ;
				( (cGESMat $ "24" .AND. !oMdlTFH:IsEmpty()) .OR. (cGESMat $ "25" .AND. !oMdlTFG:IsEmpty()) ) )
				lZera := .T.
				Exit
			EndIf
		Next nJ
		If lZera
			Exit
		EndIf
	Next nI

	//Interação com usuário para zerar valores
	If lZera
		lRet := isBlind() .OR. MsgYesNo(STR0142)//"Os valores e os itens referentes aos materiais serão zerados. Deseja Continuar?"
	EndIf

	//Zera Valores de materiais
	If lRet .AND. lZera
		For nI:=1 To oMdlTFL:Length()
			oMdlTFL:GoLine(nI)
			//Limpa RH
			If lMaterial //Somente gestão por item
				For nJ:=1 To oMdlTFF:Length()
					oMdlTFF:GoLine(nJ)
					oMdlTFF:LoadValue("TFF_VLRMAT", 0)
					oMdlTFF:LoadValue("TFF_PERMAT", 0)
				Next nJ
			EndIf

			If !lMaterial


				If oModel:GetId() == "TECA740"
					For nX:=1 To oMdlTFF:Length()
						oMdlTFF:GoLine(nX)
						//Limpa MI
						If cGESMat $ "2|5|"
							lCanDel := oMdlTFG:CanDeleteLine()
							oMdlTFG:SetNoDeleteLine(.F.)


							For nJ:=1 To oMdlTFG:Length()
								oMdlTFG:GoLine(nJ)
								If !oMdlTFG:IsDeleted() .And. !Empty(oMdlTFG:GetValue('TFG_PRODUT'))
									oMdlTFG:DeleteLine()
								EndIf
							Next nJ
							oMdlTFG:SetNoDeleteLine(!lCanDel)
						EndIf
						//Limpa MC
						If cGESMat $ "2|4|"
							lCanDel := oMdlTFH:CanDeleteLine()
							oMdlTFH:SetNoDeleteLine(.F.)
							For nJ:=1 To oMdlTFH:Length()
								oMdlTFH:GoLine(nJ)
								If !oMdlTFH:IsDeleted() .And. !Empty(oMdlTFH:GetValue('TFH_PRODUT'))
									oMdlTFH:DeleteLine()
								EndIf
							Next nJ
							oMdlTFH:SetNoDeleteLine(!lCanDel)
						EndIf

					Next nX
				Else
					//Limpa MI
					If cGESMat $ "2|5|"
						lCanDel := oMdlTFG:CanDeleteLine()
						oMdlTFG:SetNoDeleteLine(.F.)
						For nJ:=1 To oMdlTFG:Length()
							oMdlTFG:GoLine(nJ)
							If !oMdlTFG:IsDeleted() .And. !Empty(oMdlTFG:GetValue('TFG_PRODUT'))
								oMdlTFG:DeleteLine()
							EndIf
						Next nJ
						oMdlTFG:SetNoDeleteLine(!lCanDel)
					EndIf
					//Limpa MC
					If cGESMat $ "2|4|"
						lCanDel := oMdlTFH:CanDeleteLine()
						oMdlTFH:SetNoDeleteLine(.F.)
						For nJ:=1 To oMdlTFH:Length()
							oMdlTFH:GoLine(nJ)
							If !oMdlTFH:IsDeleted() .And. !Empty(oMdlTFH:GetValue('TFH_PRODUT'))
								oMdlTFH:DeleteLine()
							EndIf
						Next nJ
						oMdlTFH:SetNoDeleteLine(!lCanDel)
					EndIf
				EndIf
			EndIf
			At740AtTpr()
		Next nI

		oMdlTFL:GoLine(nOldTFL)
		oMdlTFF:GoLine(nOldTFF)

		If ValType(oView) == 'O'
			oView:Refresh("VIEW_RH")//Atualiza grid para que seja apresentado os valores alterados
		EndIf
	EndIf

	FWRestRows( aSaveLines )
	RestArea(aArea)

EndIf
Return lRet

//------------------------------------------------------------------------------
/*/
At740TDT
@sample 	At740TDT()
@since		20/07/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Function At740TDT(cSeq)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
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

FWRestRows( aSaveLines )
RestArea(aArea)
Return(cDesc)

//------------------------------------------------------------------------------
/*/
At740TGV


@sample 	At740TGV()

@since		20/07/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740TGV()

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local cCodTGV  := ""
Local cDesc    := ""
Local oMdl   	 := FwModelActive()

If oMdl:GetId()=="TECA740" .Or. oMdl:GetId()=="TECA740F"

		//codigo da curso
		cCodTGV := oMdl:GetModel( "TGV_RH" ):GetValue( "TGV_CURSO" )
		cDesc   := Posicione("RA1",1,xFilial("RA1") + cCodTGV ,"RA1->RA1_DESC")

EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return(cDesc)

/*/{Protheus.doc} At740LuTxA
	Copia o conteúdo preenchido nos campos de percentual de lucro e taxa administrativa
@return 	nValor, Numérico, percentual da tx adm ou do lucro
@param  	cCpoValor, Caracter, campo para ter o conteúdo copiado
/*/
Function At740LuTxA( cCpoValor )

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local nValor := 0
Local oMdlFull := FwModelActive()

If oMdlFull <> Nil .And. ( oMdlFull:GetId()=='TECA740' .Or. oMdlFull:GetId()=='TECA740F' )
	nValor := oMdlFull:GetValue('TFJ_REFER', cCpoValor)
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} At740ConEq
Rotina para consulta de equipamentos

@author filipe.goncalves
@since 27/01/2016
@version P12.1.11
/*/
//-------------------------------------------------------------------
Function At740ConEq()

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oModel	:= FwModelActive()
Local oModConsu := FWLoadModel('TECA742')
Local dDtIni	:= oModel:GetValue('TFI_LE','TFI_PERINI')
Local dDtFim	:= oModel:GetValue('TFI_LE','TFI_PERFIM')
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}

If !(Empty(dDtIni)) .And. !(Empty(dDtFim))
	oModConsu:SetOperation(3)
	oModConsu:Activate()
	FWExecView (STR0087, "TECA742"	,MODEL_OPERATION_INSERT,, {||.T.},,,aButtons,{||.T.},,, AT742LOAD(oModel, oModConsu))
Else
	Help(,,"AT740CON",,STR0088,1,0) //"Digite as datas de periodo do produto para utilizar a consulta de equipamentos"
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} At740ValAM
Função para validar o tipo escolhido da apuração de medição

@author filipe.goncalves
@since 27/01/2016
@version P12.1.11
/*/
//-------------------------------------------------------------------
Function At740ValAM()

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oModel	:= FwModelActive()
Local lRet		:= .T.
Local lIniFim 	:= Empty(oModel:GetValue('TFI_LE','TFI_PERINI')) .And. Empty(oModel:GetValue('TFI_LE','TFI_PERFIM'))
Local lEntCo	:= Empty(oModel:GetValue('TFI_LE','TFI_ENTEQP')) .And. Empty(oModel:GetValue('TFI_LE','TFI_COLEQP'))

If !lIniFim .And. lEntCo
	If oModel:GetValue('TFI_LE','TFI_APUMED') <> "1"
		lRet := .F.
		Help(,,"AT740OPC1",,STR0102,1,0)	//"Quando somente os períodos inicial e final estão preenchidos, é possivel selecionar apenas a opção '1' deste campo."
	Endif
Endif

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At740VldAg
Validação para as dadtas de agendamento de entrega e coleta do equipamento.

@author Kaique Schiller
@since 13/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function At740VldAg(cCampo,dDtIni,dDtFim,dDtEnt,dDtCol)

Local aArea		:= GetArea()
Local aSaveLines:= FWSaveRows()
Local lRet 		:= .F.
Local cVldAgd 	:= SuperGetMv("MV_VLDAGD",,"1")
Local lCont		:= .T.

Default cCampo	:= ""
Default dDtIni	:= sTod("")
Default dDtFim	:= sTod("")
Default dDtEnt	:= sTod("")
Default dDtCol	:= sTod("")

If !Empty(dDtCol) .and. !Empty(dDtEnt)
	lCont := dDtCol >= dDtEnt
	If !lCont
		Help(,, "At740VldAg",,STR0108,1,0,,,,,,{STR0109})//#"Data Entrega/Coleta." #"Data Coleta deve ser maior que a data de entrega"
	EndIf
EndIf

If lCont .and. !Empty(dDtIni) .and. !Empty(dDtFim)
	lCont := dDtFim >= dDtIni
	If !lCont
		Help(,, "At740VldAg",,STR0110,1,0,,,,,,{STR0111})//#"Data Inicio/Fim."#"Data Fim deve ser maior que a Data Inicial"
	EndIf
EndIf

If lCont
	//Quando a data de entrega e coleta estiver igual ou fora do período.
	If cVldAgd == "1"
		If cCampo == "TFI_ENTEQP"
			If dDtEnt <= dDtIni
				lRet := .T.
			Else
				Help(,, "At740VldAg",,STR0089,1,0,,,,,,{STR0090}) //"Data de entrega do equipamento." ## "A data de entrega tem que estar menor ou igual a data de inicio da alocação."
			Endif
		Endif
		If cCampo == "TFI_COLEQP"
			If dDtCol >= dDtFim
				lRet := .T.
			Else
				Help(,, "At740VldAg",,STR0091,1,0,,,,,,{STR0092}) //"Data de coleta do equipamento." ## "A data de coleta tem que estar maior ou igual a data de fim da alocação."
			Endif
		Endif
	//Quando a data de entrega e coleta estiver igual ou dentro do período.
	Elseif cVldAgd == "2"
		If cCampo == "TFI_ENTEQP"
			If dDtEnt >= dDtIni
				lRet := .T.
			Else
				Help(,, "At740VldAg",,STR0089,1,0,,,,,,{STR0093}) //"Data de entrega do equipamento." ## "A data de entrega tem que estar maior ou igual a data de inicio da alocação."
			Endif
		Endif
		If cCampo == "TFI_COLEQP"
			If dDtCol <= dDtFim .And. dDtCol >= dDtEnt
				lRet := .T.
			Else
				Help(,, "At740VldAg",,STR0091,1,0,,,,,,{STR0094}) //"Data de coleta do equipamento." ## "A data de coleta tem que estar menor ou igual a data de fim da alocação."
			Endif
		Endif
	//Quando a data de entrega estiver igual ou maior que a data de inicio / quando a data de coleta estiver igual ou maior que a data final.
	Elseif cVldAgd == "3"
		If cCampo == "TFI_ENTEQP"
			If dDtEnt >= dDtIni
				lRet := .T.
			Else
				Help(,, "At740VldAg",,STR0089,1,0,,,,,,{STR0093}) //"Data de entrega do equipamento." ## "A data de entrega tem que estar maior ou igual a data de inicio da alocação."
			Endif
		Endif
		If cCampo == "TFI_COLEQP"
			If dDtCol >= dDtFim
				lRet := .T.
			Else
				Help(,, "At740VldAg",,STR0091,1,0,,,,,,{STR0092}) //"Data de coleta do equipamento." ## "A data de coleta tem que estar maior ou igual a data de fim da alocação."
			Endif
		Endif
	//Quando a data de entrega estiver igual ou menor que a data de inicio / quando a data de coleta estiver igual ou menor que a data final.
	Elseif cVldAgd == "4"
		If cCampo == "TFI_ENTEQP"
			If dDtEnt <= dDtIni
				lRet := .T.
			Else
				Help(,, "At740VldAg",,STR0089,1,0,,,,,,{STR0090}) //"Data de entrega do equipamento." ## "A data de entrega tem que estar menor ou igual a data de inicio da alocação."
			Endif
		Endif
		If cCampo == "TFI_COLEQP"
			If dDtCol <= dDtFim
				lRet := .T.
			Else
				Help(,, "At740VldAg",,STR0091,1,0,,,,,,{STR0094}) //"Data de coleta do equipamento." ## "A data de coleta tem que estar estar menor ou igual a data de fim da alocação."
			Endif
		Endif
	Endif
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At740CpoOb
Função para pegar os campos obrigatórios de determinados modelos da rotina e retirar o obrigatório deles por conta do facilitador de orçamento.

@author Filipe Gonçalves
@since 07/06/2016
@version P12
/*/
//-------------------------------------------------------------------
Function At740CpoOb(oModel)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local cRet	:= ""
Local aCpos	:= {{"TFF_RH",{}},{"TFG_MI",{}},{"TFH_MC",{}},{"TFI_LE",{}}}
Local nX	:= 0
Local nY	:= 0
Local nPos  := 0

For nX := 1 to len(oModel:GetAllSubModels())
	If  oModel:GetAllSubModels()[nX]:CID $ "TFF_RH|TFG_MI|TFH_MC|TFI_LE"
		cRet   := AllTrim(oModel:GetAllSubModels()[nX]:CID)
		nPos   := aScan(aCpos,{|x| AllTrim(x[1]) == cRet})
		oModNx := oModel:GetModel(cRet)
		aHead  := oModNx:GetStruct():GetFields()
		For nY := 1 To Len(aHead)
			If aHead[nY][MODEL_FIELD_OBRIGAT]
				Aadd(aCpos[nPos,2],aHead[nY][3])
			EndIf
		Next nY
		oModNx:GetStruct():SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
	EndIf
Next nX

FWRestRows( aSaveLines )
RestArea(aArea)
Return aCpos


//-------------------------------------------------------------------
/*/{Protheus.doc} At740Obriga
Função para tornar os campos obrigatórios novamente, após a função At740CpoOb() retirar a obrigatoriedade.

@author Totvs
@since 29/06/2016
@version P12
/*/
//-------------------------------------------------------------------
Function At740Obriga()

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oModel    := FwModelActive()
Local oModNx    := Nil
Local nX        := 0
Local nY        := 0
Local aCposObrg := {}

aCposObrg := aObriga
aObriga   := {}
For nX := 1 To Len(aCposObrg)
	oModNx := oModel:GetModel(aCposObrg[nX,1])
	For nY := 1 To Len(aCposObrg[nX,2])
		oModNx:GetStruct():SetProperty(aCposObrg[nX,2,nY],MODEL_FIELD_OBRIGAT,.T.)
	Next nY
Next nX

FWRestRows( aSaveLines )
RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A740LoadFa
Função de validação para realizar a caraga dos dados nas abas

@author Filipe Gonçalves
@since 01/06/2016
@version P12
@Param
/*
	aDadosTWN[1] = TWN_FILIAL
	aDadosTWN[2] = TWN_ITEM
	aDadosTWN[3] = TWN_CODPRO
	aDadosTWN[4] = TWN_QUANTS
	aDadosTWN[5] = TWN_VLUNIT
	aDadosTWN[6] = TWN_TPITEM
	aDadosTWN[7] = TWN_CODTWM
	aDadosTWN[8] = TWN_ITEMRH
	aDadosTWN[9] = TWN_FUNCAO
	aDadosTWN[10] = TWN_TURNO
	aDadosTWN[11] = TWN_CARGO
	aDadosTWN[12] = TWN_TES
	DadosTWN[13] = TWN_TESPED
*/
//-------------------------------------------------------------------
Function A740LoadFa(oModelGrid, nLine, cAction, cField, xValue, xOldValue,lOkButton)
Local lRet			:= .T.
Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local aValTWNRH 	:= {}
Local aValTWNMC 	:= {}
Local aValTWNMI		:= {}
Local aValTWNLE 	:= {}
Local oModel		:= FwModelActive()
Local oModLC		:= oModel:GetModel('TFL_LOC')
Local oModRH		:= oModel:GetModel('TFF_RH')
Local oModMI		:= oModel:GetModel('TFG_MI')
Local oModMC		:= oModel:GetModel('TFH_MC')
Local oModLE		:= oModel:GetModel('TFI_LE')
Local oModTWO		:= oModel:GetModel('TWODETAIL')
Local cChvItem 		:= ""
Local cCodFac		:= ""
Local cItemFc		:= ""
Local lOrcPrc 		:= SuperGetMv("MV_ORCPRC",.F., .F.)
Local cGsDsGcn		:= oModel:GetValue('TFJ_REFER','TFJ_DSGCN')
Local cItem 		:= Replicate("0", TamSx3("TFF_ITEM")[1]  )
Local nTotal 		:= IF(lTotLoc,oModLC:Length(.T.),1)
Local nValItem 		:= 0
Local nDifItem 		:= 0
Local nMulItem 		:= 0
Local nNumItem 		:= 0
Local nQtdFc		:= 0
Local nX			:= 0
Local nY			:= 0
Local cGesMat		:= ""
Local lSetValue		:= .T.

Default lOkButton	:= .F.

If !lOkButton .or. !lAlterTWO

	//Validação ao atribuir valores na tela do facilitador
	If !IsInCallStack("LoadXmlData")
		If cAction == 'SETVALUE'
			//Tratativa na mudanção do facilitador zerar o campo de quantidade
			If cField == "TWO_CODFAC"
				TWM->(dbSetOrder(1))//TWN_FILIAL+TWN_CODTWM
				If TWM->(dbSeek(xFilial("TWM") + xValue))
					If TWM->TWM_DTVALI <= dDataBase
						lRet := .F.
						Help(,,"AT740VLDLOC",,STR0127,1,0) // "Validade do facilitador foi expirada, selecione outro facilitador"
					EndIf
				EndIf

				If (!Empty(xOldValue) .And. xValue <> xOldValue) .And. lRet
					//Posiciona no primeiro Local
					If lTotLoc
						oModLC:GoLine(1)
					EndIf
					For nX := 1 To nTotal
						If lTotLoc
							oModLC:GoLine(nX)
						EndIf
					oModTWO:LoadValue("TWO_QUANT", 0)
					//Fazer a deleção dos itens quando zerar a quantidade do facilitador
					TWN->(dbSetOrder(2))//TWN_FILIAL+TWN_CODTWM
					TWN->(dbSeek(xFilial("TWN") + xOldValue))
					For nY := 1 To oModRH:Length()
						oModRH:GoLine(nY)
						If !Empty(oModRH:GetValue('TFF_CHVTWO')) .And. TWN->TWN_CODTWM == SubStr(oModRH:GetValue('TFF_CHVTWO'), 1, 15)
							oModRH:DeleteLine()
							If !lOrcPrc
								// chama função para excluir as linhas de materiais
								At740FaExMt(oModMC, oModMI, .T.)
							EndIf
						EndIf
					Next nY
					If lOrcPrc
						// chama função para excluir as linhas de materiais
						At740FaExMt(oModMC, oModMI, .T.)
					EndIf
					//Itens Do LE
					For nY := 1 To oModLE:Length()
						oModLE:GoLine(nY)
						If !Empty(oModLE:GetValue('TFI_CHVTWO')) .And. TWN->TWN_CODTWM == SubStr(oModLE:GetValue('TFI_CHVTWO'), 1, 15)
							oModLE:DeleteLine()
						EndIf
					Next nY
					Next nX
				EndIf
			EndIf

			//Verifica se o código e a quantidade estão preenchidos para fazer a carga do SETVALUE
			If !Empty(oModTWO:GetValue('TWO_CODFAC')) .And. (cField == "TWO_QUANT" .And. xValue > 0 ) .And. lRet
				If !Empty(oModTWO:GetValue('TWO_CODFAC'))
					cCodFac := oModTWO:GetValue('TWO_CODFAC')
				EndIf
				//Posiciona no primeiro Local
				If lTotLoc
					oModLC:GoLine(1)
				EndIf
				For nX := 1 To nTotal
					If lTotLoc
						oModLC:GoLine(nX)

						If !Empty(oModTWO:GetValue('TWO_CODFAC'))
							cItemFc	:= oModTWO:GetValue('TWO_ITEM')
							nQtdFc	:= xValue
						EndIf
					EndIf
					TWN->(dbSetOrder(2))//TWN_FILIAL+TWN_CODTWM
					If TWN->(dbSeek(xFilial("TWN") + cCodFac))
						lAlterTWO := .T.
						
						aValTWNRH := Tec984Val(cCodFac, 'RH')
						aValTWNMC := Tec984Val(cCodFac, 'MC')
						aValTWNMI := Tec984Val(cCodFac, 'MI')
						aValTWNLE := Tec984Val(cCodFac, 'LE')
					
						cGesMat := oModel:GetValue('TFJ_REFER','TFJ_GESMAT')
						If Empty(cGesMat)
							cGesMat := "1"
						EndIf
						//-- Atribui itens de RH
						If !EMPTY(aValTWNRH)

							//Caso o Grid ja possua itens de RH, ajusta o campo ITEM para adicionar os produtos do facilitador
							If !oModRH:IsEmpty()
								oModRH:GoLine(oModRH:Length())
								cItem := oModRH:GetValue('TFF_ITEM')
							EndIf

							For nY := 1 To LEN(aValTWNRH)
								cItem := Soma1(cItem)
								If !Empty( aValTWNRH[nY][3] )
									//Percorrer o modelo para ver se já adicionou aquele facilitador
									If !oModRH:SeekLine( { { 'TFF_CHVTWO', cCodFac + aValTWNRH[nY][2] + oModTWO:GetValue('TWO_ITEM')}})
										If oModRH:Length() > 1 .Or. !Empty( oModRH:GetValue("TFF_PRODUT") )
											If nY <= LEN(aValTWNRH)
												oModRH:AddLine()
											EndIf
										EndIf
									EndIf
								EndIf
								// atribui os conteúdos relacionados ao controle de associação do facilitador
								nValItem	:= xOldValue
								nDifItem	:= xValue - nValItem
								nMulItem	:= nDifItem * aValTWNRH[nY][4]
								nNumItem	:= oModRH:GetValue('TFF_QTDVEN') + nMulItem
								cChvItem	:= cCodFac + aValTWNRH[nY][2] + oModTWO:GetValue('TWO_ITEM')

								lSetValue := oModRH:SetValue('TFF_ITEM', cItem)
								lSetValue := lSetValue .And. oModRH:SetValue('TFF_CHVTWO', cChvItem)
								lSetValue := lSetValue .And. oModRH:SetValue('TFF_QTDVEN', nNumItem)

								// Só atribui quando tem conteúdo
								If !( EMPTY(aValTWNRH[nY][3]) )
									lSetValue := lSetValue .And. oModRH:SetValue('TFF_PRODUT', aValTWNRH[nY][3])
								EndIf
								If aValTWNRH[nY][5] > 0
									lSetValue := lSetValue .And. oModRH:SetValue('TFF_PRCVEN', aValTWNRH[nY][5])
								EndIf
								If !Empty(aValTWNRH[nY][9])
									lSetValue := lSetValue .And. oModRH:SetValue('TFF_FUNCAO', aValTWNRH[nY][9])
								EndIf
								If !Empty(aValTWNRH[nY][10])
									lSetValue := lSetValue .And. oModRH:SetValue('TFF_TURNO'	, aValTWNRH[nY][10])
								EndIf
								If !Empty(aValTWNRH[nY][11])
									lSetValue := lSetValue .And. oModRH:SetValue('TFF_CARGO'	, aValTWNRH[nY][11])
								EndIf
								If cGsDsGcn == "1" .AND. !( EMPTY(aValTWNRH[nY][13]) )
									lSetValue := lSetValue .And. oModRH:SetValue('TFF_TESPED', aValTWNRH[nY][13])
								EndIf

								//-- Atribui os itens de MI e MC - Filhos de RH
								If !lOrcPrc .And. lSetValue
									If cGesMat $ "1|4|" .AND. !EMPTY(aValTWNMI)		// atualiza materia de implantação
										At740FaMat( oModTWO, aValTWNMI, oModMI, xValue, xOldValue, "TFG", cCodFac )
									EndIf
								
									If cGesMat $ "1|5|" .AND. !EMPTY(aValTWNMC)	// atualiza materia de consumo
										At740FaMat( oModTWO, aValTWNMC, oModMC, xValue, xOldValue, "TFH", cCodFac )
									EndIf
								EndIf
							Next nY
							oModRH:GoLine(1)

							If !lSetValue .And. !IsBlind()
								AtErroMvc(oModel)
								MostraErro()
								lRet := .F.
							EndIf

						ElseIf !lOrcPrc 
							If cGesMat $ "1|4|" .AND. !EMPTY(aValTWNMI)	// atualiza materia de implantação
								At740FaMat( oModTWO, aValTWNMI, oModMI, xValue, xOldValue, "TFG", cCodFac )
							EndIf
						
							If cGesMat $ "1|5|" .AND. !EMPTY(aValTWNMC)	// atualiza materia de consumo
								At740FaMat( oModTWO, aValTWNMC, oModMC, xValue, xOldValue, "TFH", cCodFac )
							EndIf
						EndIf

						//-- Atribui os itens de MI e MC - Não tem relacionamento com itens de RH
						If lOrcPrc .And. !(cGesMat $ '2|3')
							// atualiza materia de implantação
							If cGesMat $ "1|4|" .AND. !EMPTY(aValTWNMI)	
								At740FaMat( oModTWO, aValTWNMI, oModMI, xValue, xOldValue, "TFG", cCodFac )
							EndIf
							// atualiza materia de consumo
							If cGesMat $ "1|5|" .AND. !EMPTY(aValTWNMC)
								At740FaMat( oModTWO, aValTWNMC, oModMC, xValue, xOldValue, "TFH", cCodFac )
							EndIf
						EndIf

						//Zera a variável para utilizar na grid de LE
						cItem := Replicate("0", TamSx3("TFI_ITEM")[1]  )

						//-- Atribui os itens de LE
						If !EMPTY(aValTWNLE)
							//Caso o Grid ja possua itens de LE, ajusta o campo ITEM para adicionar os produtos do facilitador
							If !oModLE:IsEmpty()
								oModLE:GoLine(oModLE:Length())
		            			cItem := oModLE:GetValue('TFI_ITEM')
							EndIf

							For nY := 1 To LEN(aValTWNLE)
								cItem := Soma1(cItem)
								If !Empty(aValTWNLE[nY][3])
									If !oModLE:SeekLine( { { 'TFI_CHVTWO',cCodFac + aValTWNLE[nY][2] + oModTWO:GetValue('TWO_ITEM') } } )
										//Verificar se não encontrou o facilitardor adicionar uma linha nova com as informações
										If oModLE:Length() > 1 .Or. !Empty( oModLE:GetValue("TFI_PRODUT") )
											If nY <= LEN(aValTWNLE)
												oModLE:AddLine()
											EndIf
										EndIf
									EndIf
									nValItem	:= xOldValue
									nDifItem	:= xValue - nValItem
									nMulItem	:= nDifItem * aValTWNLE[nY][4]
									nNumItem	:= oModLE:GetValue('TFI_QTDVEN') + nMulItem
									cChvItem :=  cCodFac + aValTWNLE[nY][2] + oModTWO:GetValue('TWO_ITEM')
									oModLE:SetValue('TFI_ITEM', cItem)
									oModLE:SetValue('TFI_CHVTWO', cChvItem)
									oModLE:SetValue('TFI_PRODUT', aValTWNLE[nY][3])
									oModLE:SetValue('TFI_QTDVEN', nNumItem)
									If !Empty(!Empty(aValTWNLE[nY][12]))
										oModLE:SetValue('TFI_TES', aValTWNLE[nY][12])
									EndIf
									If cGsDsGcn == "1"
										oModLE:SetValue('TFI_TESPED', aValTWNLE[nY][13])
									EndIf
								EndIf
							Next nY
							cItem := Replicate("0", TamSx3("TFF_ITEM")[1]  )
						EndIf

						oModLE:GoLine(1)
						FwModelActive( oModTWO:GetModel() )
					EndIf
				Next nX

				//Tratativa para duplicar o registro na TWO para os demais locais
				If lTotLoc
					For nY := 1 To oModLC:Length()
						oModLC:GoLine(nY)
						If Empty(oModTWO:GetValue('TWO_CODFAC'))
							If !(Empty(oModTWO:GetValue('TWO_ITEM')))
								oModLC:AddLine()
							EndIF
							oModTWO:LoadValue('TWO_ITEM'	,cItemFc)
							oModTWO:LoadValue('TWO_CODFAC'	,cCodFac)
							oModTWO:LoadValue('TWO_DESCRI'	,Posicione("TWM",1,xFilial("TWM") + cCodFac ,"TWM_DESCRI"))
							oModTWO:LoadValue('TWO_QUANT'	,nQtdFc)
						EndIf
					Next nY
				EndIf
			EndIf

		//Validação ao deletar a linha do facilitador
		ElseIf cAction == 'DELETE'
			If lTotLoc
				lDelTWO := .T.
			EndIf
			//Itens Do RH
			TWN->(dbSetOrder(2))//TWN_FILIAL+TWN_CODTWM
			TWN->(dbSeek(xFilial("TWN") + oModTWO:GetValue('TWO_CODFAC')))
			For nY := 1 To oModRH:Length()
				oModRH:GoLine(nY)
				cChavTWO := SubStr(oModRH:GetValue('TFF_CHVTWO'), 1, 15) + SubStr(oModRH:GetValue('TFF_CHVTWO'), 19, 3)
				If !Empty(oModRH:GetValue('TFF_CHVTWO')) .And. TWN->TWN_CODTWM + oModTWO:GetValue('TWO_ITEM') == cChavTWO
					oModRH:DeleteLine()
					If !lOrcPrc
						// chama função para excluir as linhas de materiais
						At740FaExMt(oModMC, oModMI, .T., oModTWO)
					EndIf
				EndIf
			Next nY

			If lOrcPrc
				// chama função para excluir as linhas de materiais
				At740FaExMt(oModMC, oModMI, .T., oModTWO)
			EndIf

			//Itens Do LE
			For nY := 1 To oModLE:Length()
				oModLE:GoLine(nY)
				cChavTWO := SubStr(oModLE:GetValue('TFI_CHVTWO'), 1, 15) + SubStr(oModLE:GetValue('TFI_CHVTWO'), 19, 3)
				If !Empty(oModLE:GetValue('TFI_CHVTWO')) .And. TWN->TWN_CODTWM + oModTWO:GetValue('TWO_ITEM') == cChavTWO
					oModLE:DeleteLine()
				EndIf
			Next nY

		//Validação para habilitar a linha deletada
		ElseIf cAction == 'UNDELETE'
			If lTotLoc
				lUnDel := .T.
			EndIf
			//Verifica se existe um registro duplicado ao habilitar a linha
			If lRet
				TWN->(dbSetOrder(2))//TWN_FILIAL+TWN_CODTWM
				TWN->(dbSeek(xFilial("TWN") + oModTWO:GetValue('TWO_CODFAC')))
				For nY := 1 To oModRH:Length()
					oModRH:GoLine(nY)
					cChavTWO := SubStr(oModRH:GetValue('TFF_CHVTWO'), 1, 15) + SubStr(oModRH:GetValue('TFF_CHVTWO'), 19, 3)
					If !Empty(oModRH:GetValue('TFF_CHVTWO')) .And. TWN->TWN_CODTWM + oModTWO:GetValue('TWO_ITEM') == cChavTWO
						oModRH:UnDeleteLine()
						If !lOrcPrc
							// chama função para excluir as linhas de materiais
							At740FaExMt(oModMC, oModMI, .F., oModTWO)
						EndIf
					EndIf
				Next nY
				If lOrcPrc
					// chama função para excluir as linhas de materiais
					At740FaExMt(oModMC, oModMI, .F., oModTWO)
				EndIf
				//Itens Do LE
				For nY := 1 To oModLE:Length()
					oModLE:GoLine(nY)
					cChavTWO := SubStr(oModLE:GetValue('TFI_CHVTWO'), 1, 15) + SubStr(oModLE:GetValue('TFI_CHVTWO'), 19, 3)
					If !Empty(oModLE:GetValue('TFI_CHVTWO')) .And. TWN->TWN_CODTWM + oModTWO:GetValue('TWO_ITEM') == cChavTWO
						oModLE:UnDeleteLine()
					EndIf
				Next nY
			EndIf

		//Validação para habilitar edição na linha quando o Local e as datas de inicio e fim estiverem informadas
		ElseIf cAction == 'CANSETVALUE'
			If !Empty(oModTWO:GetValue('TWO_CODFAC'))
				cCodFac := oModTWO:GetValue('TWO_CODFAC')
			EndIf

			If cField = 'TWO_CODFAC'
				If Empty(oModLC:GetValue('TFL_LOCAL')) .Or.  Empty(oModLC:GetValue('TFL_DTINI')) .Or. Empty(oModLC:GetValue('TFL_DTFIM'))
					lRet := .F.	
				EndIf
			ElseIf cField = 'TWO_QUANT'
				If Empty(cCodFac)
					lRet := .F.
				Else
					lRet := .T.
				EndIf
			EndIf
		EndIf
	EndIf

	FWRestRows( aSaveLines )
	RestArea(aArea)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TEC740FACI
Função de validação para realizar a caraga dos dados nas abas

@author Filipe Gonçalves
@since 01/06/2016
@version P12
/*/
//-------------------------------------------------------------------
Function TEC740FACI(oModLoc)

Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oModel		:= FwModelActive()
Local oStruTWO		:= FwFormStruct(2, 'TWO', {|cCpo| At740SelFields( 'TWO', Alltrim(cCpo) )})
Local oSubView		:= FwFormView():New(oModel)
Local oModelTFL	:= 	oModel:GetModel('TFL_LOC')
Local oModelTWO	:= oModel:GetModel('TWODETAIL')
Local lRet		:= .T.
Local nX		:= 0
Local nY		:= 0

If oModelTFL:Length(.T.) > 1
	lTotLoc := MsgYesNo(STR0128) // "Deseja replicar o facilitador para todos os Locais de atendimento deste orçamento? "
EndIf

If lRet := 	!Empty(oModelTFL:GetValue('TFL_LOCAL'))

	lAlterTWO := .F.
	//Função para pegar os campos obrigatórios de determinados modelos da rotina
	If Len(aObriga) == 0
		aObriga := At740CpoOb(oModel)
	EndIf

	//Cria uma subView para chamar na tela flutuante
	oSubView:SetModel(oModel)
	oSubView:CreateHorizontalBox('POPBOX',100)
	oSubView:AddGrid('VIEW_TWO',oStruTWO,'TWODETAIL')
	oSubView:AddIncrementField('VIEW_TWO', 'TWO_ITEM')
	oSubView:SetOwnerView('VIEW_TWO','POPBOX')

	TECXFPOPUP(oModel,oSubView, STR0096, MODEL_OPERATION_UPDATE, 70,,, IIF(lAlterTWO, {||.T.},{|| A740LoadFa(Nil, 0, "SETVALUE", "TWO_QUANT", oModelTWO:GetValue("TWO_QUANT"), 0,.T.)}))
	
	If lTotLoc .And. lDelTWO
		For nY := 1 To oModelTFL:Length()
			oModelTFL:Goline(nY)
			For nX := 1 to oModelTWO:Length()
				oModelTWO:GoLine(nX)
				If !Empty(oModelTWO:GetValue('TWO_CODFAC')) .And. !oModelTWO:IsDeleted()
					oModelTWO:Deleteline()
				EndIf
			next nX
		Next nY
		lDelTWO := .F.
	ElseIf lTotLoc .And. lUnDel
		For nY := 1 To oModelTFL:Length()
			oModelTFL:Goline(nY)
			For nX := 1 to oModelTWO:Length()
				oModelTWO:GoLine(nX)
				If !Empty(oModelTWO:GetValue('TWO_CODFAC')) .And. oModelTWO:IsDeleted()
					oModelTWO:UnDeleteLine()
				EndIf
			next nX
		Next nY
		lUnDel := .F.
	EndIf
		// Função que torna todos os campos obrigatórios novamente, após ter a obrigatoriedade retirada pela função At740CpoOb().
	At740Obriga()
Else
	Help(,,"AT740VLDLOC",,STR0097,1,0) //- "Para utilizar o facilitador por favor informe um Local de Atendimento e suas datas de vigência."
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)

lAlterTWO := .F.
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TEC740NFac
Função de validação para realizar a carga dos dados nas abas
para o novo facilitador

@author Luiz Gabriel
@since 26/07/2022
@version P12.1.2210
/*/
//-------------------------------------------------------------------
Function TEC740NFac(oModLoc)

Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oModel		:= FwModelActive()
Local oModelTFL		:= oModel:GetModel('TFL_LOC')
Local oStruTWO		:= FwFormStruct(2, 'TWO', {|cCpo| At740SelFields( 'TWO', Alltrim(cCpo) )})
Local oSubView		:= FwFormView():New(oModel)
Local lRet			:= .T.
Local bSetOk 		:= {|oModel| Tec740FacOK(oModel,lTotLoc)}

If oModelTFL:Length(.T.) > 1
	lTotLoc := MsgYesNo(STR0128) // "Deseja replicar o facilitador para todos os Locais de atendimento deste orçamento? "
EndIf

If !Empty(oModelTFL:GetValue('TFL_LOCAL')) 
	lAlterTWO := .F.
	//Função para pegar os campos obrigatórios de determinados modelos da rotina
	If Len(aObriga) == 0
		aObriga := At740CpoOb(oModel)
	EndIf

	//Cria uma subView para chamar na tela flutuante
	oSubView:SetModel(oModel)
	oStruTWO:SetProperty( "TWO_CODFAC", MVC_VIEW_LOOKUP, 'TXRFAC')
	oSubView:CreateHorizontalBox('POPBOX',100)
	oSubView:AddGrid('VIEW_TWO',oStruTWO,'TWODETAIL')
	oSubView:AddIncrementField('VIEW_TWO', 'TWO_ITEM')
	oSubView:SetOwnerView('VIEW_TWO','POPBOX')

	TECXFPOPUP(oModel,oSubView, STR0096, MODEL_OPERATION_UPDATE, 70,,STR0096,,bSetOk) //"Facilitador"
	
	// Função que torna todos os campos obrigatórios novamente, após ter a obrigatoriedade retirada pela função At740CpoOb().
	At740Obriga()
Else
	Help(,,"AT740VLDLOC",,STR0097,1,0) //- "Para utilizar o facilitador por favor informe um Local de Atendimento e suas datas de vigência."
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)

lAlterTWO := .F.
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Tec740FacOK
 chamada para o OK da tela do facilitador

@author Luiz Gabriel
@since 26/07/2022
@version P12.1.2210
/*/
//-------------------------------------------------------------------
Function Tec740FacOK(oModel,lTotLoc)
Local lRet	:= .F.

FwMsgRun(Nil,{|| lRet := Tec740CmtFac(oModel,lTotLoc) }, Nil, STR0337)	//"Carregando dados do facilitador......"

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Tec740CmtFac
função de carregamento do facilitador nos grids do orçamento

@author Luiz Gabriel
@since 26/07/2022
@version P12.1.2210
/*/
//-------------------------------------------------------------------
Static Function Tec740CmtFac(oModel,lTotLoc)
Local nX			:= 0
Local nY			:= 0
Local oModelTFL		:= oModel:GetModel('TFL_LOC')
Local oModelTFF		:= oModel:GetModel('TFF_RH')
Local oModelTWO		:= oModel:GetModel('TWODETAIL')
Local oMdlFac 		:= Nil
Local oMdlTXS 		:= Nil
Local cItem 		:= Replicate("0", TamSx3("TFF_ITEM")[1]  )
Local cCodTWO 		:= ""
Local lCodigo 		:= .F.
Local cCodFacAnt	:= ""

If oModel:GetOperation() ==  MODEL_OPERATION_UPDATE .Or. oModel:GetOperation() ==  MODEL_OPERATION_INSERT
	For nY := 1 To oModelTFL:Length()
		If lTotLoc
			oModelTFL:GoLine(nY)
		EndIf
		For nX := 1 To oModelTWO:Length()
			oModelTWO:GoLine( nX )
			If !Empty(oModelTWO:GetValue('TWO_CODFAC')) .And. (oModelTWO:GetValue('TWO_QUANT') > 0 ) 
				cCodFac := Alltrim(oModelTWO:GetValue('TWO_CODFAC'))
				nQuant := oModelTWO:GetValue('TWO_QUANT')
				cCodTWO := oModelTWO:GetValue('TWO_CODIGO')
				TXR->(dbSetOrder(1))//TXR_FILIAL+TXR_CODIGO
				If TXR->(dbSeek(xFilial("TXR") + cCodFac)) //Necessario posicionar para realizar load da TXR
					TXS->(dbSetOrder(2))
					If TXS->(dbSeek(xFilial("TXS") + cCodFac))
						oMdlFac := FwLoadModel("TECA984A")
						oMdlFac:SetOperation(MODEL_OPERATION_VIEW)
						oMdlFac:Activate()
						oMdlTXS := oMdlFac:GetModel("TXSDETAIL")
						FwModelActive( oModelTWO:GetModel() )

						If !oMdlTXS:IsEmpty()
							If !oModelTFF:IsEmpty()
								cItem := oModelTFF:GetValue('TFF_ITEM')
								//Verifica se há TFF´s carregadas com o mesmo codigo
								lCodigo := oModelTFF:SeekLine( { {'TFF_CODTWO',cCodTWO }})
								If lCodigo
									cCodFacAnt := SUBSTRING( oModelTFF:GetValue('TFF_CHVTWO'),1, TamSx3("TXR_CODIGO")[1])
									//verifica se houve mudança no codigo do facilitador
									lAlterTWO := !Empty(oModelTFF:GetValue('TFF_CHVTWO')) .And. cCodFacAnt <> cCodFac
								EndIf
								oModelTFF:GoLine(oModelTFF:Length())							
							EndIf

							If !oModelTWO:IsDeleted()
								//caso houve alteração, deleta as linhas do facilitador anterior
								If lAlterTWO
									Tec984ADel(oModel,oModelTWO,oModelTFF,oMdlFac,cCodFacAnt,cCodTWO,lAlterTWO) 
								EndIf
								//função para importar os dados do facilitador
								Tec984AImp(oModel,oModelTWO,oModelTFF,oMdlFac,cCodTWO,cCodFac,cItem,nQuant)
							Else 
								//Faz tratamento para deletar os itens do facilitador
								Tec984ADel(oModel,oModelTWO,oModelTFF,oMdlFac,cCodFac,cCodTWO,lAlterTWO) 
							EndIf 
							lAlterTWO := .F.
						EndIf
					EndIf
				EndIf	
			EndIf
		Next nX
		If !lTotLoc
			Exit
		EndIf
	Next nY
EndIf	

Return .T. 

//-------------------------------------------------------------------
/*/{Protheus.doc} At740TEVQt
	Calcula a qtde de dias do item qdo preenchido o campo de modo de cobrança
@return 	nValor, Numérico, qtde de dias a ser utilizado como "diária" para o período e quantidade de itens indicado pelo usuário
@param 		lAtribui, Lógico, indica se deve acontecer a atribuição do conteúdo ao campo (por vir do gatilho de um modelo diferente)
								ou simplesmente retornar o conteúdo
/*/
//-------------------------------------------------------------------
Function At740TEVQt( lAtribui )

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local nQtde := 0
Local nDias := 0
Local oModel := FwModelActive()
Local oMdlTFI := Nil
Local cCodProd := ""
Local lIdUnico := .T.
Local oMdlTEV := Nil
Local oMdlTFJ := Nil
Default lAtribui := .F.

If oModel:GetId() == "TECA740" .Or. oModel:GetId() == "TECA740F"
	oMdlTFJ := oModel:GetModel("TFJ_REFER")
	oMdlTFI := oModel:GetModel("TFI_LE")
	oMdlTEV := oModel:GetModel("TEV_ADICIO")

	If oMdlTFJ:GetValue("TFJ_CNTREC") != "1" //Quando não for contrato reccorente.

		If Alltrim(oMdlTFI:GetValue("TFI_APUMED")) == '2' //Entrega e coleta
			nDias := oMdlTFI:GetValue("TFI_COLEQP") - oMdlTFI:GetValue("TFI_ENTEQP") + 1
		ElseIf Alltrim(oMdlTFI:GetValue("TFI_APUMED")) == '3' //Inicio e Coleta
			nDias := oMdlTFI:GetValue("TFI_COLEQP") - oMdlTFI:GetValue("TFI_PERINI") + 1
		ElseIf Alltrim(oMdlTFI:GetValue("TFI_APUMED")) == '4' //Entrega e Fim
			nDias := oMdlTFI:GetValue("TFI_PERFIM") - oMdlTFI:GetValue("TFI_ENTEQP") + 1
		Else
			// ' ' OR '1' = Início e Fim
			// '5' = Nota remessa(sera usado o Inicio como não temos a Nota nesse momento) e Fim
			nDias := oMdlTFI:GetValue("TFI_PERFIM") - oMdlTFI:GetValue("TFI_PERINI") + 1
		EndIf
	Else
		nDias := 30
	Endif

	cCodProd := oMdlTFI:GetValue("TFI_PRODUT")
	// verifica se o produto é Id Único
	If !Empty( cCodProd )
		lIdUnico :=	Posicione("SB5",1,xFilial("SB5")+cCodProd,"B5_ISIDUNI") $ " |1"
	EndIf

	// quando é Id Único a qtde é só a diferença de dias
	If lIdUnico
		nQtde := nDias * oMdlTFI:GetValue("TFI_QTDVEN")
	Else
		nQtde := nDias
	EndIf

	If lAtribui .And. nQtde > 0 .And. oMdlTEV:SeekLine({{"TEV_MODCOB","2"}})
		oMdlTEV:SetValue("TEV_QTDE", nQtde)
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return nQtde

//-------------------------------------------------------------------
/*/{Protheus.doc} At740TEVMC
	Consiste o tipo de cobrança x modo de cobrança para a locação de um equipamento
@param 		NIL
@return 	.T.=Tipo de cobrança x Modo de cobrança válido // .F.=Tipo de cobrança x Modo de cobrança inválido
@since		15/07/2016
@version	P12
/*/
//-------------------------------------------------------------------
Function At740TEVMC()

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oMdl   	:= FwModelActive()
Local cTpCobr	:= FwFldGet("TFI_TPCOBR")	//1=Dias;2=Horas
Local cMdCobr	:= FwFldGet("TEV_MODCOB")	//1=Uso;2=Disponibilidade;3=Mobilização;4=Horas;5=Franquia/Excedente
Local lRet		:= .T.
Local cMdOposto := ""
Local nI 		:= 0
Local oMdlModCob := Nil

If cTpCobr == "1" .AND. ( cMdCobr == "4" .Or. cMdCobr == "5" )
	lRet	:= .F.
	Help(,,"AT740TEVMC",,STR0129,; // "Não é permitido utilizar o modo de cobrança por horas com o tipo de cobrança na locação igual a 1-Dias."
							1,0,,,,,,{STR0130}) // "Selecione outro modo de cobrança ou altere o tipo da locação para horímetro."

ElseIf cTpCobr == "2" .AND. ( cMdCobr == "4" .Or. cMdCobr == "5" )
	cMdOposto := If( cMdCobr == "4", "5", "4" )

	oMdlModCob := oMdl:GetModel("TEV_ADICIO")

	For nI := 1 To oMdlModCob:Length()
		If oMdlModCob:GetValue("TEV_MODCOB",nI) == cMdOposto
			lRet	:= .F.
			Help(,,"AT740TEVMC",,STR0131,; // "Não é permitido utilizar os dois modos de cobrança por horas."
									1,0,,,,,,{STR0132}) // "Escolha somente uma das opções entre 4-Horas ou 5-Franquia/Excedente."
			Exit
		EndIf
	Next

EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At740GesMa
	Condição do gatilho TFF_SUBTOT	sequencia 002
@param 		NIL
@return 	.T.
@since		15/08/2016
@version	P12
/*/
//-------------------------------------------------------------------
Function At740GesMa()

Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oModel		:= FwModelActive()
Local lRet			:= .T.

lRet := .F.
If oModel:GetModel("TFJ_REFER"):GetValue("TFJ_GESMAT") == "3"
	lRet := .T.
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At740VLRMA
	Condição do When do campo TFF_VLRMAT
@param 		NIL
@return 	.T.
@since		15/08/2016
@version	P12
/*/
//-------------------------------------------------------------------
Function At740VLRMA()

Local oModel		:= FwModelActive()
Local lRet			:= .F.
Local cGesMat		:= oModel:GetModel("TFJ_REFER"):GetValue("TFJ_GESMAT")

lRet := !(Empty(cGesMat) .or. cGesMat == "1")

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At740WhCob
	Verifica se a linha deve ter seu valor atualizado para o total do orçamento/contrato
	Utilizado no bloco bCond do totalizador do MVC do grid de modo de cobrança de locação
@author 	Inovação Gestão de Serviços
@since		14/09/2016
@version	P12
@param 		oModel, Objeto FwFormModel/MpFormModel, objeto principal do cadastro MVC
@return 	Lógico, .T. soma, .F. não soma
/*/
//-------------------------------------------------------------------
Function At740WhCob( oModel )
// não soma os itens do tipo 5-Franquia/Excedente
Local lSoma := ( oModel:GetModel("TEV_ADICIO"):GetValue("TEV_MODCOB") <> '5' )

Return lSoma

//-------------------------------------------------------------------
/*/{Protheus.doc} At740SmTEV
	Zera os valores da linha quando identificar
	Executado a partir de gatilho do campo de modo de cobrança
@author 	Inovação Gestão de Serviços
@since		14/09/2016
@version	P12
/*/
//-------------------------------------------------------------------
Function At740SmTEV()
Local oMdl := FwModelActive()
Local oMdlTEV := Nil
Local cModSelec := ""

If ((cModSelec := FwFldGet("TEV_MODCOB")) == '5') .And. FwFldGet("TEV_VLRUNI") > 0
	oMdlTEV := oMdl:GetModel("TEV_ADICIO")
	oMdlTEV:LoadValue("TEV_VLRUNI",0) // faz por load por causa da validação no campo
	oMdlTEV:SetValue("TEV_SUBTOT",0)  // faz via set para disparar as demais atualizações
	oMdlTEV:SetValue("TEV_VLTOT",0)   // faz via set para disparar as demais atualizações
EndIf

Return cModSelec

//-------------------------------------------------------------------
/*/{Protheus.doc} At740FaMat
	Função para adicionar valores nas Grids de Materiais
@param 		NIL
@return 	.T.
@since		15/08/2016
@version	P12
/*/
//-------------------------------------------------------------------
Static Function At740FaMat( oModTWO, aValTWNnX, oModGridOrc, xValue, xOldValue, cTab, cCodFac)
									
Local nX := 0
Local nY := 0
Local nValItem := 0
Local nDifItem := 0
Local nMulItem := 0
Local nNumItem := 0
Local cChvItem := ""
Local cItem		:= Replicate("0", TamSx3(cTab +"_ITEM")[1]  )
Local cGsDsGcn	:= oModGridOrc:GetModel():GetValue('TFJ_REFER','TFJ_DSGCN')

//Caso o Grid ja possua itens MI / MC, ajusta o campo ITEM para adicionar os produtos do facilitador
If !oModGridOrc:IsEmpty()
	oModGridOrc:GoLine(oModGridOrc:Length())
	cItem := oModGridOrc:GetValue(cTab+'_ITEM')
EndIf

For nY := 1 To LEN(aValTWNnX)

	cItem := Soma1(cItem)
	If !Empty(aValTWNnX[nY][3])
		
		If !oModGridOrc:SeekLine( { { cTab+'_CHVTWO' , ;
				oModTWO:GetValue('TWO_CODFAC') + aValTWNnX[nY][2] + oModTWO:GetValue('TWO_ITEM') } } )
			//Verificar se não encontrou o facilitardor adicionar uma linha nova com as informações
			If oModGridOrc:Length() > 1 .Or. !Empty( oModGridOrc:GetValue(cTab+"_PRODUT") )
				If nY <= LEN(aValTWNnX)
					oModGridOrc:AddLine()
				EndIf
			EndIf
		EndIf
		nMulItem	:= xValue * aValTWNnX[nY][4]
		nNumItem	:= oModGridOrc:GetValue(cTab+'_QTDVEN') + nMulItem
		cChvItem	:= cCodFac + aValTWNnX[nY][2] + oModTWO:GetValue('TWO_ITEM')
		oModGridOrc:SetValue(cTab+'_ITEM', cItem)
		oModGridOrc:SetValue(cTab+'_CHVTWO', cChvItem)
		oModGridOrc:SetValue(cTab+'_PRODUT', aValTWNnX[nY][3])
		oModGridOrc:SetValue(cTab+'_QTDVEN', nNumItem)
		If aValTWNnX[nY][5] > 0
			oModGridOrc:SetValue(cTab+'_PRCVEN', aValTWNnX[nY][5])
		EndIf
		If !Empty(aValTWNnX[nY][12])
			oModGridOrc:SetValue(cTab+'_TES', aValTWNnX[nY][12])
		EndIf
		If cGsDsGcn == "1"
			oModGridOrc:SetValue(cTab+'_TESPED', aValTWNnX[nY][12])
		EndIf
	EndIf
Next nY

oModGridOrc:GoLine(1)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} At740FaExMt
	Função para deletar as informações nas Grids MC e MI
@param 		NIL
@return 	.T.
@since		15/08/2016
@version	P12
/*/
//-------------------------------------------------------------------
Static Function At740FaExMt(oModMC, oModMI, lDelete, oModTWO)

Local nX := 0
Local cChavTWO	:= ""

Default lDelete := .T.

If lDelete
	//Itens Do MC
	For nX := 1 To oModMC:Length()
		oModMC:GoLine(nX)
		cChavTWO := SubStr(oModMC:GetValue('TFH_CHVTWO'), 1, 15) + SubStr(oModMC:GetValue('TFH_CHVTWO'), 19, 3)
		If !Empty(oModMC:GetValue('TFH_CHVTWO')) .And. TWN->TWN_CODTWM + oModTWO:GetValue('TWO_ITEM') == cChavTWO
			oModMC:DeleteLine()
		EndIf
	Next nX
	//Itens Do MI
	For nX := 1 To oModMI:Length()
		oModMI:GoLine(nX)
		cChavTWO := SubStr(oModMI:GetValue('TFG_CHVTWO'), 1, 15) + SubStr(oModMI:GetValue('TFG_CHVTWO'), 19, 3)
		If !Empty(oModMI:GetValue('TFG_CHVTWO')) .And. TWN->TWN_CODTWM + oModTWO:GetValue('TWO_ITEM') == cChavTWO
			oModMI:DeleteLine()
		EndIf
	Next nX

Else
	//Itens Do MC
	For nX := 1 To oModMC:Length()
		oModMC:GoLine(nX)
		cChavTWO := SubStr(oModMC:GetValue('TFH_CHVTWO'), 1, 15) + SubStr(oModMC:GetValue('TFH_CHVTWO'), 19, 3)
		If !Empty(oModMC:GetValue('TFH_CHVTWO')) .And. TWN->TWN_CODTWM + oModTWO:GetValue('TWO_ITEM') == cChavTWO
			oModMC:UnDeleteLine()
		EndIf
	Next nX
	//Itens Do MI
	For nX := 1 To oModMI:Length()
		oModMI:GoLine(nX)
		cChavTWO := SubStr(oModMC:GetValue('TFG_CHVTWO'), 1, 15) + SubStr(oModMC:GetValue('TFG_CHVTWO'), 19, 3)
		If !Empty(oModMI:GetValue('TFG_CHVTWO')) .And. TWN->TWN_CODTWM + oModTWO:GetValue('TWO_ITEM') == cChavTWO
			oModMI:UnDeleteLine()
		EndIf
	Next nX

EndIf

Return

/*/{Protheus.doc} At740Del
	Função para excluir um orçamento de serviços
@param 		nDelTFJ, numérico, indica o recno do cabeçalho do orçamento de serviços
@return 	Lógico, determina se a exclusão aconteceu com sucesso ou não
@since		29/12/16
@version	P12
/*/
Function At740Del( nDelTFJ )
Local lRet := .T.
Local lOrcPrc := SuperGetMV("MV_ORCPRC",,.F.)
Local oModel := If( lOrcPrc, FwLoadModel("TECA740F"), FwLoadModel("TECA740") )

TFJ->( DbGoTo( nDelTFJ ) )
oModel:SetOperation(MODEL_OPERATION_DELETE)

lRet := lRet .And. oModel:Activate()
At740SCmt( .T. )
lRet := lRet .And. oModel:VldData()
lRet := lRet .And. oModel:CommitData()

At740SCmt( .F. )

If !lRet
	AtErroMvc( oModel )
	MostraErro()
EndIf

If lRet .AND. FindFunction("At600ARROS")
	At600ARROS( .F. )
EndIF

Return lRet

/*/{Protheus.doc} At740IsOrc
@description 	Verifica se o registro posicionado é do orçamento de serviços
@param 			cModItem, caracter, modelo de origem do item a ser avaliado
@param 			cCodItemEval, caracter, código do item que precisa ser avaliado
@param 			cCodTFJ, caracter, código do orçamento de serviços a ser avaliado
@return 		Lógico, indica se o item pertence ao orçamento de serviços ou não
@since			19/01/17
@version		P12
/*/
Function At740IsOrc( cModItem, cCodTFJ, cCodTFL, oMdlAtivo )
Local lFound 		:= .F.
Local cTabTemp 		:= ""
Local nOrcPrc 		:= 0
Local cCodItemEval 	:= ""
Local cExpCodTFL 	:= ""

Default cCodTFL 	:= ""

// executa as avaliações conforme o modelo que entrou e a tabela relacionada a entidade | geralmente orçamento de serviços
If cModItem == "TFF_RH" .Or. cModItem == "TGV_RH" .Or. cModItem == "ABP_BENEF"
	If cModItem == "TGV_RH"
		cCodItemEval := TGV->TGV_CODTFF
	ElseIf cModItem == "ABP_BENEF"
		cCodItemEval := ABP->ABP_ITRH
	Else
		cCodItemEval := TFF->TFF_COD
	EndIf

	If Empty(cCodTFL)
		cExpCodTFL := "% TFF_FILIAL = '"+xFilial("TFF")+"' "
		cExpCodTFL += "AND TFF_COD = '"+cCodItemEval+"' "
		cExpCodTFL += "AND TFF.D_E_L_E_T_=' '%"
	Else
		cExpCodTFL := "% TFF_FILIAL = '"+xFilial("TFF")+"' "
		cExpCodTFL += "AND TFF_COD = '"+cCodItemEval+"' "
		cExpCodTFL += "AND TFL_CODIGO = '"+cCodTFL+"' "
		cExpCodTFL += "AND TFF.D_E_L_E_T_=' ' %"
	EndIf

	cTabTemp := GetNextAlias()

	BeginSql Alias cTabTemp
		SELECT TFJ_CODIGO
		FROM %Table:TFF% TFF
			INNER JOIN %Table:TFL% TFL ON TFL_FILIAL = %xFilial:TFL%
									AND TFL_CODIGO = TFF_CODPAI
									AND TFL.%NotDel%
			INNER JOIN %Table:TFJ% TFJ ON TFJ_FILIAL = %xFilial:TFJ%
									AND TFJ_CODIGO = TFL_CODPAI
									AND TFJ.%NotDel%
		WHERE
			%Exp:cExpCodTFL%

	EndSql

	If (cTabTemp)->(!EOF()) .And. (cTabTemp)->TFJ_CODIGO == cCodTFJ
		lFound := .T.
	EndIf

	(cTabTemp)->(DbCloseArea())

ElseIf cModItem == "TFG_MI"
	nOrcPrc := If( SuperGetMV("MV_ORCPRC",,.F.), 1, 0)
	// executa a avaliação quando é orçamento com precificação
	// ou quando o item não é filho de um novo item de Rh
	If nOrcPrc == 1 .Or. ;
		!oMdlAtivo:GetModel("TFF_RH"):IsInserted()

		cCodItemEval := TFG->TFG_COD

		If Empty(cCodTFL)
			cExpCodTFL := "% TFG_FILIAL = '"+xFilial("TFG")+"' "
			cExpCodTFL += "AND TFG_COD = '"+cCodItemEval+"' "
			cExpCodTFL += "AND TFG.D_E_L_E_T_=' '%"
		Else
			cExpCodTFL := "% TFG_FILIAL = '"+xFilial("TFG")+"' "
			cExpCodTFL += "AND TFG_COD = '"+cCodItemEval+"' "
			cExpCodTFL += "AND TFL_CODIGO = '"+cCodTFL+"' "
			cExpCodTFL += "AND TFG.D_E_L_E_T_=' ' %"
		EndIf

		cTabTemp := GetNextAlias()

		BeginSql Alias cTabTemp
			SELECT TFJ_CODIGO
			FROM %Table:TFG% TFG
				LEFT JOIN %Table:TFF% TFF ON 0 = %Exp:nOrcPrc%
										AND TFF_FILIAL = %xFilial:TFF%
										AND TFF_COD = TFG_CODPAI
										AND TFF.%NotDel%
				INNER JOIN %Table:TFL% TFL ON TFL_FILIAL = %xFilial:TFL%
										AND (
												(0 = %Exp:nOrcPrc% AND TFL_CODIGO = TFF_CODPAI)
												OR (1 = %Exp:nOrcPrc% AND TFL_CODIGO = TFG_CODPAI)
											)
										AND TFL.%NotDel%
				INNER JOIN %Table:TFJ% TFJ ON TFJ_FILIAL = %xFilial:TFJ%
										AND TFJ_CODIGO = TFL_CODPAI
										AND TFJ.%NotDel%
			WHERE
				%Exp:cExpCodTFL%
		EndSql

		If (cTabTemp)->(!EOF()) .And. (cTabTemp)->TFJ_CODIGO == cCodTFJ
			lFound := .T.
		EndIf

		(cTabTemp)->(DbCloseArea())
	EndIf
ElseIf cModItem == "TFH_MC"
	nOrcPrc := If( SuperGetMV("MV_ORCPRC",,.F.), 1, 0)
	// executa a avaliação quando é orçamento com precificação
	// ou quando o item não é filho de um novo item de Rh
	If nOrcPrc == 1 .Or. ;
		!oMdlAtivo:GetModel("TFF_RH"):IsInserted()

		cCodItemEval := TFH->TFH_COD

		If Empty(cCodTFL)
			cExpCodTFL := "% TFH_FILIAL = '"+xFilial("TFH")+"' "
			cExpCodTFL += "AND TFH_COD = '"+cCodItemEval+"' "
			cExpCodTFL += "AND TFH.D_E_L_E_T_=' ' %"
		Else
			cExpCodTFL := "% TFH_FILIAL = '"+xFilial("TFH")+"' "
			cExpCodTFL += "AND TFH_COD = '"+cCodItemEval+"' "
			cExpCodTFL += "AND TFL_CODIGO = '"+cCodTFL+"' "
			cExpCodTFL += "AND TFH.D_E_L_E_T_=' ' %"
		EndIf

		cTabTemp := GetNextAlias()

		BeginSql Alias cTabTemp
			SELECT TFJ_CODIGO
			FROM %Table:TFH% TFH
				LEFT JOIN %Table:TFF% TFF ON 0 = %Exp:nOrcPrc%
										AND TFF_FILIAL = %xFilial:TFF%
										AND TFF_COD = TFH_CODPAI
										AND TFF.%NotDel%
				INNER JOIN %Table:TFL% TFL ON TFL_FILIAL = %xFilial:TFL%
										AND (
												(0 = %Exp:nOrcPrc% AND TFL_CODIGO = TFF_CODPAI)
												OR (1 = %Exp:nOrcPrc% AND TFL_CODIGO = TFH_CODPAI)
											)
										AND TFL.%NotDel%
				INNER JOIN %Table:TFJ% TFJ ON TFJ_FILIAL = %xFilial:TFJ%
										AND TFJ_CODIGO = TFL_CODPAI
										AND TFJ.%NotDel%
			WHERE
				%Exp:cExpCodTFL%
		EndSql

		If (cTabTemp)->(!EOF()) .And. (cTabTemp)->TFJ_CODIGO == cCodTFJ
			lFound := .T.
		EndIf

		(cTabTemp)->(DbCloseArea())
	EndIf
ElseIf cModItem == "TFI_LE"
	cCodItemEval := TFI->TFI_COD
	If Empty(cCodTFL)
		cExpCodTFL := "% TFI_FILIAL = '"+xFilial("TFI")+"' "
		cExpCodTFL += "AND TFI_COD = '"+cCodItemEval+"' "
		cExpCodTFL += "AND TFI.D_E_L_E_T_=' ' %"
	Else
		cExpCodTFL := "% TFI_FILIAL = '"+xFilial("TFI")+"' "
		cExpCodTFL += "AND TFI_COD = '"+cCodItemEval+"' "
		cExpCodTFL += "AND TFL_CODIGO = '"+cCodTFL+"' "
		cExpCodTFL += "AND TFI.D_E_L_E_T_=' ' %"
	EndIf
	cTabTemp := GetNextAlias()

	BeginSql Alias cTabTemp
		SELECT TFJ_CODIGO
		FROM %Table:TFI% TFI
			INNER JOIN %Table:TFL% TFL ON TFL_FILIAL = %xFilial:TFL%
									AND TFL_CODIGO = TFI_CODPAI
									AND TFL.%NotDel%
			INNER JOIN %Table:TFJ% TFJ ON TFJ_FILIAL = %xFilial:TFJ%
									AND TFJ_CODIGO = TFL_CODPAI
									AND TFJ.%NotDel%
		WHERE
			%Exp:cExpCodTFL%
	EndSql

	If (cTabTemp)->(!EOF()) .And. (cTabTemp)->TFJ_CODIGO == cCodTFJ
		lFound := .T.
	EndIf

	(cTabTemp)->(DbCloseArea())

Else
	// qlq caso diferente da lista não é avaliado
	lFound := .T.
EndIf

Return lFound

/*/{Protheus.doc} At740VldCC
	Função para validar o centro de custo do local de atendimento

@return 	Lógico, Determina se o centro de custo do local é o mesmo do sitema
@since		13/02/2017
@version	P12
/*/
Function At740VldCC(oMdlTFL)
Local lRet		:= .T.
Local oModel	:= FwModelActive()
Local oMdlTFL 	:= Nil
Local cLocal 	:= ""
Local lIsOrcServ 	:= oModel:GetId() $ "TECA740/TECA740F"
Local aArea		:= GetArea()

//Verifica se o centro de custo do local é o mesmo que está logado
DbSelectArea("ABS")
ABS->(DbSetOrder(1))
If lIsOrcServ
	oMdlTFL	:= oModel:GetModel('TFL_LOC')
	cLocal	:= oMdlTFL:GetValue("TFL_LOCAL")
	If ABS->(MsSeek(xFilial("ABS")+ cLocal)) .And. !Empty(ABS->ABS_FILCC) .And. (cFilAnt <> ABS->ABS_FILCC)
		lRet	:= .F.
		oModel:GetModel():SetErrorMessage(oModel:GetId(),"TFL_LOCAL",oModel:GetModel():GetId(),	"TFL_LOCAL",'TFL_LOCAL',;
			STR0135, STR0136 )//"A filial do centro de custo do local de atendimento selecionado é diferente da filial do sistema"##"Selecione um local de atendimento onde a filial do centro de custo configurado seja o mesmo do sistema"
	EndIf
EndIf

RestArea(aArea)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} At740GatRc
	Gatilho para inserir a data no campo de data fim.
@author 	Kaique Schiller
@param 		NIL
@return 	cCod
@since		04/04/2017
@version	P12.1.16
/*/
//-------------------------------------------------------------------
Function At740GatRc(cCod,cCamp,cDetail,oMdl)
Local dDtFim 		:= SuperGetMv("MV_CNVIGCP",,cTod("31/12/2049"))
Local oModel		:= Nil
Local oDetail		:= Nil
Local oStruct 		:= Nil
Local bWhen			:= {|| .T. }
Local bValid		:= {|| .T. }
Local aDtl			:= {}

Default cCod 		:= ""
Default cCamp 		:= ""
Default cDetail		:= ""
Default oMdl		:= Nil

If !Empty(cCamp) .And. !Empty(cDetail)
	If ValType(oMdl) == "O"
		oModel		:= oMdl
	Else
		oModel		:= FwModelActive()
	Endif

	If oModel:GetId() $ "TECA740|TECA740F|TECA740A|TECA740B"
		aDtl	 	:= Separa(cDetail,"|")

		If oModel:GetId() $ "TECA740|TECA740F"
			cDetail := aDtl[1]
		Elseif oModel:GetId() $ "TECA740A|TECA740B|TECA740C"
			cDetail := aDtl[2]
		Endif

		oDetail		:= oModel:GetModel(cDetail)
		oStruct 	:= oDetail:GetStruct()

		bWhen := oStruct:GetProperty(cCamp,MODEL_FIELD_WHEN)
		oStruct:SetProperty(cCamp,MODEL_FIELD_WHEN,{|| .T. })
		If cCamp $ "TFF_PERFIM|TFH_PERFIM|TFG_PERFIM|TFI_PERFIM"
			bValid := oStruct:GetProperty(cCamp,MODEL_FIELD_VALID)
			oStruct:SetProperty(cCamp,MODEL_FIELD_VALID,{|| .T. })
		Endif
		oDetail:SetValue(cCamp,dDtFim)
		oStruct:SetProperty(cCamp,MODEL_FIELD_WHEN,bWhen)
		If cCamp $ "TFF_PERFIM|TFH_PERFIM|TFG_PERFIM|TFI_PERFIM"
			oStruct:SetProperty(cCamp,MODEL_FIELD_VALID,bValid)
		Endif
	Endif
Endif

Return cCod

//-------------------------------------------------------------------
/*/{Protheus.doc} At740GRec
	Gatilho para inserir as datas nos campos de data fim quando houver registros nas grid's.
@author 	Kaique Schiller
@param 		NIL
@return 	cCod
@since		04/04/2017
@version	P12.1.16
/*/
//------------------------------------------------------------------
Function At740GRec(cCodRec)
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 0
Local nW			:= 0
Local nDias			:= 30
Local aSaveLines	:= {}
Local oModel		:= Nil
Local oView			:= Nil
Local oDtlTFL		:= Nil
Local oDtlTFF		:= Nil
Local oDtlTFG		:= Nil
Local oDtlTFH		:= Nil
Local oDtlTFI		:= Nil

Default cCodRec := "2"

If cCodRec == "1"
	oModel := FwModelActive()
	oView  := FwViewActive()
	If oModel:GetId() $ "TECA740|TECA740F"
		aSaveLines	:= FWSaveRows()
		oDtlTFL		:= oModel:GetModel("TFL_LOC")
		oDtlTFF		:= oModel:GetModel("TFF_RH")
		oDtlTFG		:= oModel:GetModel("TFG_MI")
		oDtlTFH		:= oModel:GetModel("TFH_MC")
		oDtlTFI		:= oModel:GetModel("TFI_LE")
		oDtlTEV		:= oModel:GetModel("TEV_ADICIO")

		For nX := 1 To oDtlTFL:Length()
			If !oDtlTFL:IsEmpty()
				oDtlTFL:GoLine(nX)
				If !(oDtlTFL:IsDeleted())
					At740GatRc(,"TFL_DTFIM","TFL_LOC",oModel)
					For nZ := 1 To oDtlTFF:Length()
						If !oDtlTFF:IsEmpty()
							oDtlTFF:GoLine(nZ)
							At740GatRc(,"TFF_PERFIM","TFF_RH",oModel)

							If TecVlPrPar() .AND. !oDtlTFF:IsDeleted() .AND.;
									!Empty( oDtlTFF:GetValue("TFF_PRODUT") ) .AND. oDtlTFF:GetValue("TFF_VLPRPA") == 0 .AND.;
										!isInCallStack("At870GerOrc")
								oDtlTFF:LoadValue("TFF_VLPRPA", At740PrxPa("TFF") )
							EndIf

							For nY := 1 To oDtlTFG:Length()
								If !oDtlTFG:IsEmpty()
									oDtlTFG:GoLine(nY)
									If !(oDtlTFG:IsDeleted())
										At740GatRc(,"TFG_PERFIM","TFG_MI",oModel)
									Endif
									If TecVlPrPar() .AND. !oDtlTFG:IsDeleted() .AND.;
											!Empty( oDtlTFG:GetValue("TFG_PRODUT") ) .AND. oDtlTFG:GetValue("TFG_VLPRPA") == 0 .AND.;
												!isInCallStack("At870GerOrc")
										oDtlTFG:LoadValue("TFG_VLPRPA", At740PrxPa("TFG") )
									EndIf
								Endif
							Next nY

							For nY := 1 To oDtlTFH:Length()
								If !oDtlTFH:IsEmpty()
									oDtlTFH:GoLine(nY)
									If !(oDtlTFH:IsDeleted())
										At740GatRc(,"TFH_PERFIM","TFH_MC",oModel)
									Endif
									If TecVlPrPar() .AND. !oDtlTFH:IsDeleted() .AND.;
											!Empty( oDtlTFH:GetValue("TFH_PRODUT") ) .AND. oDtlTFH:GetValue("TFH_VLPRPA") == 0 .AND.;
												!isInCallStack("At870GerOrc")
										oDtlTFH:LoadValue("TFH_VLPRPA", At740PrxPa("TFH") )
									EndIf
								Endif
							Next nY
						Endif
					Next nZ
					For nY := 1 To oDtlTFI:Length()
						If !oDtlTFI:IsEmpty()
							oDtlTFI:GoLine(nY)
							nQuant	:= oDtlTFI:GetValue("TFI_QTDVEN")
							At740GatRc(,"TFI_PERFIM","TFI_LE",oModel)
							For nW := 1 To oDtlTEV:Length()
								If !oDtlTEV:IsEmpty()
									oDtlTEV:GoLine(nW)
									If oDtlTEV:GetValue("TEV_MODCOB") == "2" .And. !(oDtlTEV:IsDeleted())
										oDtlTEV:SetValue("TEV_QTDE",(nQuant*nDias))
									Endif
								Endif
							Next nW
						Endif
					Next nY
					If TecVlPrPar() .AND. !oDtlTFL:IsDeleted() .AND.;
							!Empty( oDtlTFL:GetValue("TFL_LOCAL") ) .AND. !isInCallStack("At870GerOrc")
						At740AtTpr()
					EndIf
				Endif
			Endif
		Next nX
		FWRestRows(aSaveLines)
		If ValType(oView) == "O" .And. oView:GetModel():GetId() $ "TECA740|TECA740F"
			oView:Refresh()
		Endif
	Endif
ElseIf cCodRec == "2"
	oModel := FwModelActive()
	oView  := FwViewActive()
	If oModel:GetId() $ "TECA740|TECA740F"
		aSaveLines	:= FWSaveRows()
		oDtlTFL		:= oModel:GetModel("TFL_LOC")
		oDtlTFF		:= oModel:GetModel("TFF_RH")
		oDtlTFG		:= oModel:GetModel("TFG_MI")
		oDtlTFH		:= oModel:GetModel("TFH_MC")

		For nX := 1 To oDtlTFL:Length()
			If !oDtlTFL:IsEmpty()
				oDtlTFL:GoLine(nX)
				If !(oDtlTFL:IsDeleted())
					For nZ := 1 To oDtlTFF:Length()
						If !oDtlTFF:IsEmpty()
							oDtlTFF:GoLine(nZ)

							If TecVlPrPar() .AND. !oDtlTFF:IsDeleted() .AND.;
									!Empty( oDtlTFF:GetValue("TFF_PRODUT") ) .AND. oDtlTFF:GetValue("TFF_VLPRPA") != 0 .AND.;
										!isInCallStack("At870GerOrc")
								oDtlTFF:LoadValue("TFF_VLPRPA", 0 )
							EndIf

							For nY := 1 To oDtlTFG:Length()
								If !oDtlTFG:IsEmpty()
									oDtlTFG:GoLine(nY)
									If TecVlPrPar() .AND. !oDtlTFG:IsDeleted() .AND.;
											!Empty( oDtlTFG:GetValue("TFG_PRODUT") ) .AND. oDtlTFG:GetValue("TFG_VLPRPA") != 0 .AND.;
												!isInCallStack("At870GerOrc")
										oDtlTFG:LoadValue("TFG_VLPRPA", 0 )
									EndIf
								Endif
							Next nY

							For nY := 1 To oDtlTFH:Length()
								If !oDtlTFH:IsEmpty()
									oDtlTFH:GoLine(nY)
									If TecVlPrPar() .AND. !oDtlTFH:IsDeleted() .AND.;
											!Empty( oDtlTFH:GetValue("TFH_PRODUT") ) .AND. oDtlTFH:GetValue("TFH_VLPRPA") != 0 .AND.;
												!isInCallStack("At870GerOrc")
										oDtlTFH:LoadValue("TFH_VLPRPA", 0 )
									EndIf
								Endif
							Next nY
						Endif
					Next nZ
					If TecVlPrPar() .AND. !oDtlTFL:IsDeleted() .AND. oDtlTFL:GetValue("TFL_VLPRPA") != 0 .AND.;
							!Empty( oDtlTFL:GetValue("TFL_LOCAL") ) .AND. !isInCallStack("At870GerOrc")
						oDtlTFL:LoadValue("TFL_VLPRPA", 0 )
					EndIf
				Endif
			Endif
		Next nX
		FWRestRows(aSaveLines)
		If ValType(oView) == "O" .And. oView:GetModel():GetId() $ "TECA740|TECA740F"
			oView:Refresh()
		Endif
	Endif
Endif

Return cCodRec

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740Recor
	Se o contrato não for recorrente retorna .T.

@sample 	At740Recor(cNumCtr)
@param		ExpC1	Codigo do contrato

@author		Kaique Schiller
@since		10/04/2017
@version	P12
/*/
//------------------------------------------------------------------------------
Function At740Recor(cNumCtr)
Local aArea		:= GetArea()
Local lRet		:= .T.
Local cRevis	:= ""
Default cNumCtr := ""

If !Empty(cNumCtr)
	cRevis := Posicione("CN9",7,xFilial("CN9")+cNumCtr+"05","CN9_REVISA")
	DbSelectArea("TFJ")
	TFJ->(DbSetOrder(5)) //TFJ_FILIAL+TFJ_CONTRT+TFJ_CONREV
	If TFJ->(DbSeek(xFilial("TFJ")+cNumCtr+cRevis))
		If TFJ->TFJ_CNTREC == "1"
			lRet := .F.
		Endif
	Endif
Endif

RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740Recor
	Se o contrato for recorrente bloqueia os campos de data fim.

@sample 	At740WhenR()

@author		Kaique Schiller
@since		17/04/2017
@version	P12
/*/
//------------------------------------------------------------------------------
Function At740WhenR()

Return .T.
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740TpVerb
@description 	Função para o gatilho do tipo de verba convertendo entre H, V e D para 1, 2 e 3 respectivamente.
@sample 		At740TpVerb()
@author		josimar.assuncao
@since			30/05/2017
@version		P12
@return 		Caracter, devolve o tipo da verba convertida de H, V e D para 1, 2 e 3.
/*/
//------------------------------------------------------------------------------
Function At740TpVerb()
Local cTpVerba := Posicione("SRV", 1, xFilial("SRV")+M->ABP_VERBA, "RV_TIPO" )
Return At740ConvTp( cTpVerba )
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ConvTp
@description 	Função para conversão do conteúdo de H, V e D dos tipos de verba para 1, 2 e 3.
@sample 		At740ConvTp( "H" ) ==> "1"
@author		josimar.assuncao
@since			02.06.2017
@version		P12
@param 			cTipoLetra, caracter, tipo da verba como H, V ou D.
@return 		Caracter, devolve o tipo da verba convertida de H, V e D para 1, 2 e 3.
/*/
//------------------------------------------------------------------------------
Function At740ConvTp( cTipoLetra )
Local cRetorno := ""

If cTipoLetra == "H"
	cRetorno := "1"
ElseIf cTipoLetra == "V"
	cRetorno := "2"
ElseIf cTipoLetra == "D"
	cRetorno := "3"
EndIf

Return cRetorno
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ToADZ
@description 	Função para indicar que é necessário levar os dados do orçamento para a proposta comercial
@sample 		At740ToADZ( .F. ) // At740ToADZ()
@author		josimar.assuncao
@since			25.07.2017
@version		P12
@param 			lValor, lógico, conteúdo a ser atribuído
@return 		Lógico, devolve o conteúdo inserido
/*/
//------------------------------------------------------------------------------
Function At740ToADZ( lValor )
If ValType(lValor) == "L"
	lImpToADZ := lValor
EndIf
Return lImpToADZ
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740RplFac
@description 	Função para indicar que é necessário replicar o facilitador nos locais
@sample 		At740RplFac( .F. ) // At740RplFac()
@author		josimar.assuncao
@since			25.07.2017
@version		P12
@param 			lValor, lógico, conteúdo a ser atribuído
@return 		Lógico, devolve o conteúdo inserido
/*/
//------------------------------------------------------------------------------
Function At740RplFac( lValor )
If ValType(lValor) == "L"
	lTotLoc := lValor
EndIf
Return lTotLoc
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740HrEtr
@description 	Função que preenche o TFU_ABNDES de acordo com o TFU_CODABN, na grid de Horas Extras
@author		mateus.boiani
@since			28.11.2017
@version		P12
@param 			oModel, objeto, Modelo de dados do grid das Horas Extras
/*/
//------------------------------------------------------------------------------
Function At740HrEtr(oModel)
Local nI
Local cCODABN

For nI := 1 To oModel:Length()
	oModel:GoLine( nI )
	cCODABN := oModel:GetValue("TFU_CODABN")
	If !EMPTY(cCODABN)
		oModel:LoadValue("TFU_ABNDES", At740TrgABN(cCODABN))
	EndIf
Next
oModel:GoLine( 1 )

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740Habil
@description 	Função que desabilita campos na Revisão do Contrato

@param 		aCampos, array, contém o nome dos campos que devem ser bloqueados para edição
@param 		oModel, model, modelo de dados que será editado
@since		30/11/2017
@version	P12
/*/
//------------------------------------------------------------------------------
Function At740Habil(aCampos, oModel)
Local nI
Local cX3_Propri
Local cNotBlock := "TFJ_CONDPG|TFJ_OBSPRC"

If TFJ->( ColumnPos("TFJ_PRDRET")) > 0
	cNotBlock += "|TFJ_PRDRET"
EndIf 

For nI := 1 To LEN(aCampos)
	cX3_Propri := GetSx3Cache(aCampos[nI][1],'X3_PROPRI')
	If oModel:HasField(aCampos[nI][1]) .AND. VALTYPE(cX3_Propri) == 'C' .AND. cX3_Propri != 'U' .AND. !(aCampos[nI][1]$cNotBlock)
		oModel:SetProperty(aCampos[nI][1], MVC_VIEW_CANCHANGE, .F.)
	EndIf
Next

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTFU
@description 	Prevalid validação para a grid de Horas Extras do orçamento

@param 		oMdlG, nLine,cAcao, cCampo Modelo, linha, código da ação e nome do campo
@since		14/05/2018
@version	P12
@author	Diego A. Bezerra
/*/
//------------------------------------------------------------------------------
Function PreLinTFU(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)

Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oMdlFull		:= If(oMdlG <> nil, oMdlG:GetModel(), nil)
Local lFillModel	:= isInCallStack("FillModel")
Local lOk	:=	.T.
Local lOrcPrc 		:= SuperGetMv("MV_ORCPRC",,.F.)		//Verifica se usa a tabela de precificação
Local lExiste 		:= .F.
Local lInclui		:= oMdlFull:GetOperation() == MODEL_OPERATION_INSERT

If oMdlFull <> Nil .And.;
	!IsInCallStack('At870GerOrc')
	If !('CAN' $ cAcao) .AND. (IsInCallStack('At870Revis') .AND.!(IsInCallStack('AT870PlaRe') .OR. IsInCallStack('AplicaRevi'))) .AND. ;
		!AT870RevPl(TFJ->TFJ_CODIGO) .AND. AT870ItPla( oMdlG:GetValue("TFU_CODIGO"), "TFU" )
		lOk := .F.
		Help(,,'PreLinTFU',, STR0298,1,0) // "Não é possivel alterar itens de uma Manutenção Planejada em uma revisão!."
	EndIf

	If lOk .AND. cAcao == 'SETVALUE'
		If !lFillModel
			If oMdlFull:GetId() == 'TECA740'
				If oMdlFull:GetModel('TFF_RH'):GetValue('TFF_ENCE') == '1' .OR. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1'
					lOk := .F.
					Help( ,, 'PreLinTFU',, STR0147, 1, 0 ) //"Não é possível editar esse registro, pois o Local de Atendimento ou Item de RH estão finalizados"
				EndIf
			ElseIf oMdlFull:GetId() == 'TECA740F'
				If  oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1'
					lOk	:= .F.
					Help( ,, 'PreLinABP',, STR0148, 1, 0 ) //"Não é possível editar esse registro, pois o local de atendimento está finalizado"
				EndIf
			EndIf
		EndIf
		If lOk .AND. isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") 
			aStruct  := oMdlG:GetStruct():GetFields() 
			nPos := Ascan( aStruct, {|x| x[3] == cCampo })
			If nPos > 0 .AND. !aStruct[nPos][MODEL_FIELD_VIRTUAL]
				If VldTFULinR( cCampo, xValue, IIF(Empty(oMdlG:getValue("TFU_CODREL")), oMdlG:getValue("TFU_CODIGO"), oMdlG:getValue("TFU_CODREL")), IIF(Empty(oMdlFull:GetModel('TFF_RH'):GetValue('TFF_CODREL')), oMdlFull:GetModel('TFF_RH'):GetValue('TFF_COD'), oMdlFull:GetModel('TFF_RH'):GetValue('TFF_CODREL')), aStruct[nPos][4] == 'D' )
					oMdlG:LoadValue('TFU_MODPLA', "2")
				Else
					oMdlG:LoadValue('TFU_MODPLA', "1")
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If cAcao == 'DELETE'
	If lOk .AND. isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") 
		If lInclui .AND. (oMdlG:getValue("TFU_MODPLA") <> "1" .OR. VldHeContr( oMdlG:getValue("TFU_CODIGO"), oMdlFull:GetModel('TFF_RH'):GetValue('TFF_COD')))
			Help(,,'PreLinTFU',, STR0297,1,0) // "Não é possivel excluir itens não planejados."
			lOk := .F.
		ElseIf oMdlG:getValue("TFU_MODPLA") <> "1" .OR. !Empty(oMdlG:getValue("TFU_CODREL"))
			Help(,,'PreLinTFU',, STR0297,1,0) // "Não é possivel excluir itens não planejados."
			lOk := .F.
		EndIf
	EndIf
EndIf

//Valida se a linha pode ser deletada na Revisao de Contrato
If lOk .AND. (IsIncallStack('At870Revis') .OR. IsInCallStack("AT870PlaRe") ) .AND. cAcao == 'DELETE'
	lExiste := !oMdlG:IsInserted()
	If lExiste
		Help( ,, 'PreLinTFU',, STR0151, 1, 0 ) //Não é possível excluir esse item.
		lOk := .F.
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lOk

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinABP
@description 	Prevalid validação para a grid de Benefícios

@param 		oMdlG, nLine,cAcao, cCampo Modelo, linha, código da ação e nome do campo
@since		14/05/2018
@version	P12
@author	Diego A. Bezerra
/*/
//------------------------------------------------------------------------------
Function PreLinABP(oMdlG, nLine, cAcao, cCampo)

Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oMdlFull		:= If(oMdlG <> nil, oMdlG:GetModel(), nil)
Local lFillModel	:= isInCallStack("FillModel")
Local lOk	:=	.T.
Local lOrcPrc 	:= SuperGetMv("MV_ORCPRC",,.F.)		//Verifica se usa a tabela de precificação

If oMdlFull <> Nil .And. (oMdlFull:GetId() == 'TECA740' .Or. oMdlFull:GetId() == 'TECA740F') .AND. !lTEC740FUn

	If oMdlFull <> Nil .And.;
		!IsInCallStack('At870GerOrc')

		If cAcao == 'SETVALUE'
			If !lFillModel
				If oMdlFull:GetId() == 'TECA740'
					If oMdlFull:GetModel('TFF_RH'):GetValue('TFF_ENCE') == '1' .OR. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1'
						lOk := .F.
						Help( ,, 'PreLinABP',, STR0147, 1, 0 ) //"Não é possível editar esse registro, pois o Local de Atendimento ou Item de RH estão finalizados"
					EndIf
				ElseIf oMdlFull:GetId() == 'TECA740F'
					If  oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1'
						lOk	:= .F.
						Help( ,, 'PreLinABP',, STR0148, 1, 0 ) //"Não é possível editar esse registro, pois o local de atendimento está finalizado"
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lOk


//------------------------------------------------------------------------------
/*/{Protheus.doc} a740ChgLine
@description 	Função para evento de mudança de linha na view

@param 		oView, cViewId
@since		21/05/2018
@version	P12
@author	Diego A. Bezerra
/*/
//------------------------------------------------------------------------------
Function a740ChgLine(oView, cViewId)
Local oModel
Local lEnce
Local lTFFEnce
Local lTFIEnce
Local oTFLDetail := Nil
Local oTFFDetail := Nil
Local oTFIDetail := Nil
Local oTFGDetail := Nil
Local oTFHDetail := Nil
Local oTEVDetail := Nil
Local oTFUDetail := Nil
Local oABPDetail := Nil
Local cGesMat	 := ""
Local lBlqMI	 := .F.
Local lBlqMC 	 := .F.

Local cId := ""
Local lRefresh := .F.

Default oView	:= Nil

If (IsInCallStack("At870Revis") .OR. IsInCallStack("AT870PlaRe") )
	If oView == Nil
		oModel :=  FWModelActive()
		cId := oModel:getId()
		If cId $ 'TECA740|TECA740F'
			oModel:GetModel('TFL_LOC'):GoLine(1)
		EndIf
	Else
		oModel 		:= oView:GetModel()
		cId := oModel:getId()
		
		oTFLDetail := oModel:GetModel('TFL_LOC')
		oTFFDetail := oModel:GetModel('TFF_RH')
		oTFIDetail := oModel:GetModel('TFI_LE')
		oTFGDetail := oModel:GetModel('TFG_MI')
		oTFHDetail := oModel:GetModel('TFH_MC')
		oTEVDetail := oModel:GetModel('TEV_ADICIO')
		oTFUDetail := oModel:GetModel('TFU_HE')
		oABPDetail := oModel:GetModel('ABP_BENEF')

		cGesMat		:= oModel:GetModel("TFJ_REFER"):GetValue("TFJ_GESMAT")
		lEnce 		:= oTFLDetail:GetValue('TFL_ENCE') == '1'
		lTFFEnce 	:= oTFFDetail:GetValue('TFF_ENCE')  == '1'
		lTFIEnce 	:= oTFIDetail:GetValue('TFI_ENCE')  == '1'

		If cGesMat == '2' .Or. cGesMat == '3'
			lBlqMI := .T.
			lBlqMC := .T.
		ElseIf  cGesMat == '4'
			lBlqMC := .T.
		ElseIf  cGesMat == '5'
			lBlqMI := .T.
		EndIf
		
		If oModel:GetOperation() == MODEL_OPERATION_UPDATE .Or. oModel:GetOperation() == MODEL_OPERATION_INSERT
			If cId == 'TECA740'
				If cViewId == 'TFL_LOC'
					oTFFDetail:SetNoInsertLine(lEnce)
					oTFIDetail:SetNoInsertLine(lEnce)
					oTFGDetail:SetNoInsertLine(lEnce)
					oTFHDetail:SetNoInsertLine(lEnce)
					oTEVDetail:SetNoInsertLine(lEnce)
					oTFUDetail:SetNoInsertLine(lEnce)
					oABPDetail:SetNoInsertLine(lEnce)
				ElseIf cViewId == 'TFF_RH'
					oTFFDetail:SetNoInsertLine(lEnce)
					oTFGDetail:SetNoInsertLine(lTFFEnce)
					oTFHDetail:SetNoInsertLine(lTFFEnce)
					oTFUDetail:SetNoInsertLine(lTFFEnce)
					oABPDetail:SetNoInsertLine(lTFFEnce)
				ElseIf cViewId == 'TFI_LE'
					oTFIDetail:SetNoInsertLine(lEnce)
					oTEVDetail:SetNoInsertLine(lTFIEnce)
				EndIf
			ElseIf cId == 'TECA740F'
				If cViewId == 'TFL_LOC'
					oTFFDetail:SetNoInsertLine(lEnce)
					oTFIDetail:SetNoInsertLine(lEnce)
					oTFGDetail:SetNoInsertLine(lEnce)
					oTFHDetail:SetNoInsertLine(lEnce)
					oTEVDetail:SetNoInsertLine(lEnce)
					oTFUDetail:SetNoInsertLine(lEnce)
					oABPDetail:SetNoInsertLine(lEnce)
				ElseIf cViewId == 'TFF_RH'
					oTFFDetail:SetNoInsertLine(lEnce)
					oTFUDetail:SetNoInsertLine(lTFFEnce)
					oABPDetail:SetNoInsertLine(lTFFEnce)
				ElseIf cViewId == 'TFI_LE'
					oTFIDetail:SetNoInsertLine(lEnce)
					oTEVDetail:SetNoInsertLine(lTFIEnce)
				ElseIf cViewId == 'TFH_MC'
					oTFHDetail:SetNoInsertLine(lEnce)
				ElseIf cViewId == 'TFG_MI'
					oTFGDetail:SetNoInsertLine(lEnce)
				EndIf
			EndIf
		EndIf
		If cViewId == 'TFL_LOC'
			If Empty(oTFLDetail:GetValue('TFL_LOCAL'))
				
				lRefresh := at740IniLin(oTFFDetail,'TFF_COD','TFF_LEGEN') .Or. lRefresh
				lRefresh := at740IniLin(oTFIDetail,'TFI_COD','TFI_LEGEN',{'TFI_NOMATD'}) .Or. lRefresh
				If !lBlqMI
					lRefresh := at740IniLin(oTFGDetail,'TFG_COD') .Or. lRefresh
				EndIf
				If !lBlqMC
					lRefresh := at740IniLin(oTFHDetail,'TFH_COD') .Or. lRefresh
				EndIf
			EndIf
		EndIf
		If cViewId == 'TFF_RH' .And. cId == 'TECA740'
			If Empty(oTFFDetail:GetValue('TFF_PRODUT'))
				lRefresh := at740IniLin(oTFGDetail,'TFG_COD') .Or. lRefresh
				lRefresh := at740IniLin(oTFHDetail,'TFH_COD') .Or. lRefresh
			EndIf

		EndIf
		If lRefresh
			oView:Refresh()
		EndIf
	EndIf
EndIf

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VldLe
@description 	Validação dos valores de locação de equipamento, considerando itens zerados

@param 		oModel
@since		01/10/2018
@version	P12
@author	Matheus Lando Raimundo
/*/
//------------------------------------------------------------------------------
Static Function At740VldLe(oModel)
Local lRet := .T.
Local oTFIDetail := oModel:GetModel('TFI_LE')
Local nI := 1
Local nTotLE := 0
Local lLE := .F.


For nI := 1 To oTFIDetail:Length()
	oTFIDetail:GoLine(nI)
    If !oTFIDetail:IsDeleted() .And. !Empty( oTFIDetail:GetValue('TFI_PRODUT') )
    	nTotLE += oTFIDetail:GetValue('TFI_TOTAL')
		lLE := .T.
    	If nTotLE > 0
    		Exit
    	EndIf
  	EndIf
Next nI

If lLE .And. nTotLE == 0
	lRet := .F.
	Help(,,'AT740LEZERO',STR0181,,1,0) //'O valor total de itens de locação de equipamentos não pode ser igual a 0, informe o valor de cobrança em ao menos 1 (um) item.'
EndIf

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ApP
Função de Aplicação de Planilha
@sample 	At740ApP(oModel)
@param		oModel, objeto, modelo MVC
@return	Nenhum
@since		08/10/2018
@author	Serviços
@version	12.1.17
/*/
//------------------------------------------------------------------------------

Static Function At740ApP(oModel)

Default oModel := NIL

If oModel <> NIL
	MsgRun( STR0183, STR0082, { || At740ApG(oModel)} )  //"Aplicando automaticamente a planilha#"Aguarde... #
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ApG
Função de Aplicação Automática da Planilha
@sample 	At740ApG(oModel)
@param		oModel, objeto, modelo MVC
@return	Nenhu,
@since		08/10/2018
@author	Serviços
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Static Function At740ApG(oModel)
Local oMdlRh		:= oModel:GetModel("TFF_RH") //Modelo de Recursos Humanos
Local nY 			:= 0 //Contador de Linhas do Model
Local aPlanilha 	:= {} //Planilha Retornada


For nY := 1 To oMdlRh:Length()
	oMdlRh:GoLine(nY)
	If  Empty(oMdlRh:GetValue('TFF_PLACOD') ) .And. Empty(oMdlRh:GetValue('TFF_PLAREV') )

		aPlanilha := At740AR(oMdlRh:GetValue('TFF_PRODUT'), oMdlRh:GetValue('TFF_FUNCAO'),oMdlRh:GetValue('TFF_TURNO'),oMdlRh:GetValue('TFF_SEQTRN'), oMdlRh:GetValue('TFF_CARGO'), oMdlRh:GetValue('TFF_ESCALA') )
		If Len(aPlanilha) > 1
			At998ExPla(aPlanilha[2],oModel,.F., aPlanilha[1], .T.)
		EndIf
	EndIf
Next nY

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740AR
Função de Seleção de Planilha
@sample 	At740AR(cProduto, cFuncao, cTurno, cSeqTrn, cCargo, cEscala)
@param		cProduto, Caractere, Código do Produto
@param		cFuncao, Caractere, Código da Função
@param		cTurno, Caractere, Código do Turno
@param		cSeqTrn, Caractere, Código da Seq do Turno
@param		cCargo, Caractere, Código do Cargo
@param		cEscala, Caractere, Código da Escala
@return	aRetorno, Array, dados da planilha retornada onde
					[1] - XML da Planilha
					[2] - Código da Planilha + Revisão
@since		08/10/2018
@author	Serviços
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Static Function At740AR(cProduto, 	cFuncao, cTurno, cSeqTrn, ;
						 cCargo, 	cEscala)

Local cPrdVazio 	:= Space(TamSX3("TX8_PRODUT")[1]) //Código do Produto Vazio
Local cFuncVazio 	:= Space(TamSX3("TX8_FUNCAO")[1]) //Código da Função
Local cTurnVazio 	:= Space(TamSX3("TX8_TURNO")[1]) //Turno Vazio
Local cSeqVazio 	:= Space(TamSX3("TX8_SEQTRN")[1]) //Sequencia Vazia
Local cCargVazio 	:= Space(TamSX3("TX8_CARGO")[1]) //Cargo Vazio
Local cEscVazio 	:= Space(TamSX3("TX8_ESCALA")[1]) //Escala Vazia
Local cWhere 		:= "" //Filtros da Query
Local cWhere2 		:= "" //Expressão temporária
Local cAliasQry 	:= GetNextAlias() //Alias da Query
Local aRetorno 		:= {} //Retorno da rotina
Local aAreaABW		:= {}

cWhere2 := "TX8.TX8_PRODUT = '" +cPrdVazio  + "'"
If !Empty(cProduto)
	cWhere := " AND (TX8.TX8_PRODUT = '" +cProduto  + "' OR "  + cWhere2 + " )"
Else
	cWhere := " AND "  + cWhere2
EndIf

cWhere2 := "TX8.TX8_FUNCAO = '" +cFuncVazio  + "'"
If !Empty(cFuncao)
	cWhere += " AND (TX8.TX8_FUNCAO = '" +cFuncao  + "' OR "  + cWhere2 + " )"
Else
	cWhere += " AND " + cWhere2
EndIf

cWhere2 := "TX8.TX8_TURNO = '" +cTurnVazio  + "'"
If !Empty(cTurno)
	cWhere += " AND (TX8.TX8_TURNO = '" +cTurno  + "' OR "  + cWhere2 + " )"
Else
	cWhere += " AND " + cWhere2
EndIf

cWhere2 := "TX8.TX8_SEQTRN = '" +cSeqVazio  + "'"
If !Empty(cSeqTrn)
	cWhere += " AND (TX8.TX8_SEQTRN = '" +cSeqTrn  + "' OR "  + cWhere2 + " )"
Else
	cWhere += " AND " + cWhere2
EndIf

cWhere2 := "TX8.TX8_CARGO = '" +cCargVazio  + "'"
If !Empty(cCargo)
	cWhere += " AND (TX8.TX8_CARGO = '" +cCargo  + "' OR "  + cWhere2 + " )"
Else
	cWhere += " AND " + cWhere2
EndIf

cWhere2 := "TX8.TX8_ESCALA = '" +cEscVazio  + "'"
If !Empty(cEscala)
	cWhere += " AND (TX8.TX8_ESCALA = '" +cEscala  + "' OR "  + cWhere2 + " )"
Else
	cWhere += " AND " + cWhere2
EndIf

cWhere := "%" + cWhere + "%"

BeginSql Alias cAliasQry

	SELECT TX8.TX8_PRODUT, TX8.TX8_FUNCAO, TX8.TX8_TURNO, TX8.TX8_SEQTRN, TX8.TX8_CARGO, TX8.TX8_ESCALA, TX8.TX8_PLANIL, ABW.ABW_REVISA, TX8.TX8_PRIORI
	  FROM %table:TX8% TX8
	       INNER JOIN %table:ABW% ABW ON ABW.ABW_FILIAL  = %xFilial:ABW%
	                                 AND ABW.%NotDel%
	                                 AND ABW.ABW_ULTIMA = '1'
	                                 AND ABW.ABW_CODIGO = TX8.TX8_PLANIL
	 WHERE TX8.TX8_FILIAL = %xFilial:TX8%
	   AND TX8.%NotDel%
	   %exp:cWhere%
	 ORDER BY TX8.TX8_PRIORI ASC
EndSql

If !(cAliasQry)->(Eof())
		aAreaABW := ABW->(GetArea())
		ABW->(DbSetOrder(1)) // ABW_FILIAL+ABW_CODIGO+ABW_REVISA
		If ABW->(DbSeek(xFilial("ABW")+(cAliasQry)->(TX8_PLANIL+ABW_REVISA)))
			aRetorno := {  (cAliasQry)->(TX8_PLANIL+ABW_REVISA), ;
							ABW->ABW_INSTRU }
		EndIf
		RestArea(aAreaABW)
EndIf

(cAliasQry)->(DbCloseArea())

Return aRetorno

//------------------------------------------------------------------------------
/*/{Protheus.doc} at740IniLin
Inicializa linha com os inicilizadores padrão dos campos
@since		07/11/2018
@author	Matheus Lando Raimundo
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Function at740IniLin(oMdlGrid,cKeyField,cFieldLeg,aFldExp)
Local oFields := Nil
Local cField := ""
Local nI := 1
Local lRet := .F.
Default cFieldLeg := ""
Default aFldExp := {}


If Empty(oMdlGrid:GetValue(cKeyField)) //Linha nova
	oFields := oMdlGrid:GetStruct():GetFields()
	For nI := 1 To Len(oFields)
		cField := oFields[nI,MODEL_FIELD_IDFIELD]
		If !Empty(oFields[nI,MODEL_FIELD_INIT]) .And. cField <> cFieldLeg .And. Ascan(aFldExp,cField) == 0
			If oMdlGrid:CanSetValue(cField)
				oMdlGrid:SetValue(cField,CriaVar(cField,.T.))
			Else
				oMdlGrid:LoadValue(cField,CriaVar(cField,.T.))
			EndIf
		EndIf
	Next nI

	If !Empty(cFieldLeg) .And. oMdlGrid:GetStruct():HasField(cFieldLeg)
		oMdlGrid:LoadValue(cFieldLeg, "BR_VERDE")
	EndIf
	oMdlGrid:aDataModel[1,MODEL_GRID_MODIFY] := .F.
	lRet := .T.
EndIf
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740RHNoCalc
verifica se o item possui calculo no item de RH ou linha zerada
@since		10/01/2019
@author	fabianas.silva
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Function At740RHNoCalc(oFWSheet)
Local lRet := .T.

If !Empty(oFWSheet)

	lRet :=  oFWSheet:GetCellValue("TOTAL_RH") = 0
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740AtCod
Carrega valor inicial no campo codigo da TFF
@since		15/03/2019
@author	Matheus Lando Raimundo
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Function At740AtCod(oModel)

oModel:LoadValue('TFF_COD', CriaVar('TFF_COD',.T.))

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740UCdSb
Atualiza o CODSUB dos itens do Orçamento
@since		15/03/2019
@author	Matheus Lando Raimundo
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Function At740UCdSb(aRec, cTFJNew)
Local nI 		:= 1
Local lRevPla	:= (isInCallStatck("AT870PlaRe") .OR. isInCallStatck("AplicaRevi")) .AND. !(isInCallStack("AT870RvPlC"))
Default cTFJNew := ""
For nI := 1 To Len(aRec)
	If aRec[nI, 1] == 'TFL'

		TFL->(DbSetOrder(1))
		If lRevPla 
			TFL->(DbSeek(xFilial('TFL')+ aRec[nI, 3]))
		Else
			TFL->(DbSeek(xFilial('TFL')+ aRec[nI, 2]))
		EndIf
		RecLock('TFL',.F.)
		If lRevPla
			TFL->TFL_CODREL := aRec[nI, 2]
		Else
			TFL->TFL_CODSUB := aRec[nI, 3]
		EndIf
		TFL->(MsUnlock())

	ElseIf 	aRec[nI, 1] == 'TFF'
		TFF->(DbSetOrder(1))
		If lRevPla
			TFF->(DbSeek(xFilial('TFF')+ aRec[nI, 3]))
		Else
			TFF->(DbSeek(xFilial('TFF')+ aRec[nI, 2]))
		EndIf
		If !lRevPla .AND. FindFunction("TecBHasCrn") .AND. TecBHasCrn()
			At740IAtCd("TFF",TFF->TFF_COD, aRec[nI, 3], cTFJNew)
		EndIf
		RecLock('TFF',.F.)
		If lRevPla
			TFF->TFF_CODREL := aRec[nI, 2]
		Else
			TFF->TFF_CODSUB := aRec[nI, 3]
		EndIf
		TFF->(MsUnlock())

	ElseIf 	aRec[nI, 1] == 'TFG'
		TFG->(DbSetOrder(1))
		If lRevPla
			TFG->(DbSeek(xFilial('TFG')+ aRec[nI, 3]))
		Else
			TFG->(DbSeek(xFilial('TFG')+ aRec[nI, 2]))
		EndIf
		If !lRevPla .AND. FindFunction("TecBHasCrn") .AND. TecBHasCrn()
			At740IAtCd("TFG",TFG->TFG_COD, aRec[nI, 3], cTFJNew)
		EndIf
		RecLock('TFG',.F.)
		If lRevPla
			TFG->TFG_CODREL := aRec[nI, 2]
		Else
			TFG->TFG_CODSUB := aRec[nI, 3]
		EndIf
		TFG->(MsUnlock())


	ElseIf 	aRec[nI, 1] == 'TFH'
		TFH->(DbSetOrder(1))
		If lRevPla
			TFH->(DbSeek(xFilial('TFH')+ aRec[nI, 3]))
		Else
			TFH->(DbSeek(xFilial('TFH')+ aRec[nI, 2]))
		EndIf
		If !lRevPla .AND. FindFunction("TecBHasCrn") .AND. TecBHasCrn()
			At740IAtCd("TFH",TFH->TFH_COD, aRec[nI, 3], cTFJNew)
		EndIf
		RecLock('TFH',.F.)
		If lRevPla
			TFH->TFH_CODREL := aRec[nI, 2]
		Else
			TFH->TFH_CODSUB := aRec[nI, 3]
		EndIf
		TFH->(MsUnlock())
	ElseIf 	aRec[nI, 1] == 'TFI'
		TFI->(DbSetOrder(1))
		TFI->(DbSeek(xFilial('TFI')+ aRec[nI, 2]))
		RecLock('TFI',.F.)
		TFI->TFI_CODSUB := aRec[nI, 3]
		TFI->(MsUnlock())
	ElseIf aRec[nI, 1] == 'TFU'
		TFU->(DbSetOrder(1))
		If TFU->(DbSeek(xFilial('TFU')+ aRec[nI, 3]))
			RecLock('TFU',.F.)
				TFU->TFU_CODREL := aRec[nI, 2]
			TFU->(MsUnlock())
		EndIf
	EndIf

Next nI
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740UpSLY
Manipulação dos dados de Vinculo com Beneficios
@since		15/03/2019
@author	Matheus Lando Raimundo
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Function At740UpSLY(cCodOld,cCodNew)
Local aBenefEx	:= {}
Local cAliasSLY := GetNextAlias()
Local cQuerySLY := ""
Local nX

// Replica os Beneficios Vinculados ao item do RH com o novo codigo


	DbSelectArea("SLY")
	SLY->(DbSetOrder(1))//LY_FILIAL, LY_TIPO, LY_AGRUP, LY_ALIAS, LY_FILENT, LY_CHVENT, LY_CODIGO, LY_DTINI

	// Verifica se existe beneficio vinculado
	cQuerySLY := "SELECT SLY.* "
	cQuerySLY += "  FROM " + RetSqlName("SLY")+" SLY"
	cQuerySLY += " WHERE SLY.LY_FILIAL = '" + xFilial("SLY") + "'"
	cQuerySLY += "   AND SUBSTRING(LY_CHVENT,1," + STR(TAMSX3("TFF_COD")[1]) + ") = '" + cCodOld + "'"
	cQuerySLY += "   AND SLY.LY_FILENT = '" + xFilial('TFF') + "'"
	cQuerySLY += "   AND SLY.LY_ALIAS = 'TDX'"
	cQuerySLY += "   AND SLY.D_E_L_E_T_ = ' '"
	If FindFunction("GetABene")
		aBenefEx := GetABene()
		If !Empty(aBenefEx)
			cQuerySLY += " AND SLY.LY_FILIAL||SLY.LY_TIPO||SLY.LY_AGRUP||SLY.LY_ALIAS||SLY.LY_FILENT||SLY.LY_CHVENT||SLY.LY_CODIGO||SLY.LY_DTINI NOT IN ( "
			cQuerySLY += " SELECT SLY2.LY_FILIAL||SLY2.LY_TIPO||SLY2.LY_AGRUP||SLY2.LY_ALIAS||SLY2.LY_FILENT||SLY2.LY_CHVENT||SLY2.LY_CODIGO||SLY2.LY_DTINI FROM " + RetSqlName("SLY") + " SLY2 "
			cQuerySLY += " WHERE "
			cQuerySLY += " SLY2.LY_FILIAL||SLY2.LY_TIPO||SLY2.LY_AGRUP||SLY2.LY_ALIAS||SLY2.LY_FILENT||SLY2.LY_CHVENT||SLY2.LY_CODIGO||SLY2.LY_DTINI IN ( "
			For nX := 1 To Len(aBenefEx)
				cQuerySLY += "'" + aBenefEx[nX][1]
				cQuerySLY += aBenefEx[nX][2]
				cQuerySLY += aBenefEx[nX][3]
				cQuerySLY += aBenefEx[nX][4]
				cQuerySLY += aBenefEx[nX][5]
				cQuerySLY += aBenefEx[nX][6]
				If "'" $aBenefEx[nX][7]
					cQuerySLY += StrTran(aBenefEx[nX][7], "'", "''")	
				Else
					cQuerySLY += aBenefEx[nX][7]
				EndIf
				cQuerySLY += DToS(aBenefEx[nX][8]) + "',"
			Next nX
			cQuerySLY := LEFT(cQuerySLY, LEN(cQuerySLY) - 1) + ")"
			cQuerySLY  := cQuerySLY + ") "
		EndIf
	EndIf
	cQuerySLY += " ORDER BY SLY.LY_FILIAL, SLY.LY_TIPO, SLY.LY_AGRUP, SLY.LY_ALIAS, SLY.LY_FILENT, SLY.LY_CHVENT, SLY.LY_CODIGO, SLY.LY_DTINI"

	cQuerySLY := ChangeQuery(cQuerySLY)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySLY),cAliasSLY,.T.,.T.)

	While (cAliasSLY)->(!Eof())

		If SLY->(DbSeek((cAliasSLY)->(LY_FILIAL+LY_TIPO+LY_AGRUP+LY_ALIAS+LY_FILENT+LY_CHVENT+LY_CODIGO+LY_DTINI)))

			// Inclusao do Beneficio de acordo com o codigo gerado
			RecLock("SLY", .T.)
				SLY->LY_FILIAL	:= (cAliasSLY)->LY_FILIAL
				SLY->LY_TIPO		:= (cAliasSLY)->LY_TIPO
				SLY->LY_AGRUP		:= (cAliasSLY)->LY_AGRUP
				SLY->LY_ALIAS		:= (cAliasSLY)->LY_ALIAS
				SLY->LY_FILENT	:= (cAliasSLY)->LY_FILENT
				SLY->LY_CHVENT	:= cCodNew + Substr((cAliasSLY)->LY_CHVENT, TAMSX3("TFF_COD")[1]+1, TAMSX3("R6_TURNO")[1])
				SLY->LY_CODIGO	:= (cAliasSLY)->LY_CODIGO
				SLY->LY_PGDUT		:= (cAliasSLY)->LY_PGDUT
				SLY->LY_PGSAB		:= (cAliasSLY)->LY_PGSAB
				SLY->LY_PGDOM		:= (cAliasSLY)->LY_PGDOM
				SLY->LY_PGFER		:= (cAliasSLY)->LY_PGFER
				SLY->LY_PGSUBS	:= (cAliasSLY)->LY_PGSUBS
				SLY->LY_PGFALT	:= (cAliasSLY)->LY_PGFALT
				SLY->LY_PGVAC		:= (cAliasSLY)->LY_PGVAC
				SLY->LY_DIAS		:= (cAliasSLY)->LY_DIAS
				SLY->LY_DTINI		:= STOD((cAliasSLY)->LY_DTINI)
				SLY->LY_DTFIM		:= STOD((cAliasSLY)->LY_DTFIM)
				SLY->LY_PGAFAS	:= (cAliasSLY)->LY_PGAFAS
			SLY->(MsUnLock())
		EndIf

		dbSelectArea(cAliasSLY)
		(cAliasSLY)->(dbSkip())
	EndDo

	DbSelectArea(cAliasSLY)
	(cAliasSLY)->(DbCloseArea())
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ExtIt
Verifica se o item existe no orçamento base
@since		15/03/2019
@author	Matheus Lando Raimundo
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Function At740ExtIt(cTabela, cCod, cCmpCont, lInserted)
Local lRet := .T.
Local lFind := .T.
Local aArea := &(cTabela)->(GetArea())
Local cTabApont := ""

If !lInserted
	&(cTabela)->(DbSetOrder(1))

	lFind := &(cTabela)->(DbSeek( xFilial(cTabela) + cCod )) .And. !Empty(  &(cTabela)->(FieldGet(FieldPos(cCmpCont))))

	If lFind .And. cTabela $ 'TFH|TFG'

		If cTabela == "TFH"
			cTabApont := "TFT"
		Else
			cTabApont := "TFS"
		EndIf

		//-- Verifica se existe apontamento de material
		lRet := Len(TecGetApnt(cCod,cTabApont)) > 0
	Else
		lRet := lFind
	EndIf
Else
	lRet := .F.
EndIf

RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ExTEV
Verifica se o item (TEV) existe no orçamento base
@since		15/03/2019
@author	Matheus Lando Raimundo
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Function At740ExTEV(cCodTFI,cItem,lInserted)
Local lRet := .F.
Local cAliasTemp := GetNextAlias()
Local lRevis := isInCallStatck("At870Revis") .And. TFJ->TFJ_STATUS == '1'

If !lInserted
	//-- Primeira revisão
	If lRevis
		lRet := .T.
	Else
		BeginSql Alias cAliasTemp
			SELECT TEV_ITEM
			FROM %Table:TEV% TEV
				INNER JOIN %Table:TFI% TFI ON TFI_FILIAL = %xFilial:TFI%
										AND TFI.TFI_COD = TEV.TEV_CODLOC
										AND TFI_CODSUB = %Exp:cCodTFI%
										AND TFI.%NotDel%
			WHERE
				TEV.TEV_FILIAL = %xFilial:TEV%
				AND TEV.%NotDel%
				AND TEV.TEV_ITEM = %Exp:cItem%
		EndSql

		lRet := (cAliasTemp)->(!Eof())
		(cAliasTemp)->(DbCloseArea())
	EndIf
EndIf


Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740getQt
Retorna o valor do campo QTDVEN salvo no banco de dados
@since		27/03/2019
@author		Mateus Boiani
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Static Function At740getQt(cCod,cTable)
Local aArea := GetArea()
Local nRet := 0
(cTable)->(DbSetOrder(1))

If (cTable)->(MsSeek(xFilial(cTable) + cCod))
	nRet := cTable + "->" + cTable +"_QTDVEN"
	nRet := &(nRet)
EndIf

RestArea(aArea)
Return nRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740PosRg
Posicionamento nos resgistros do orçamento de serviços.

@since	26/06/2019
@author	Kaique Schiller
/*/
//------------------------------------------------------------------------------
Function At740PosRg(oVw)
Local aModelsId := {}
Local aEscolha	:= {}
Local nEscAba   := 0
Local nI		:= 0
Local lConExt 	:= IsInCallStack("At870GerOrc")
Local lTecItExtOp:= IsInCallStack("At190dGrOrc")

//View, SubModel, Descrição, Descrição da Aba
If !lConExt

	aModelsId := { {"VIEW_LOC"	,"TFL_LOC"	, STR0213, STR0022 },; //"Locais de Atendimento"
	 			   {"VIEW_RH"	,"TFF_RH"	, STR0214, STR0006 },; //"Recursos Humanos"
	 			   {"VIEW_LE"	,"TFI_LE"	, STR0215, STR0009 },; //"Locação de Equipamentos"
	 			   {"VIEW_MI"	,"TFG_MI"	, STR0216, STR0007 },; //"Materiais de Implantação"
	 			   {"VIEW_MC"	,"TFH_MC"	, STR0217, STR0008 },; //"Material de Consumo"
	 			   {"VIEW_BENEF","ABP_BENEF", STR0218, STR0023 },; //"Verbas Adicionais"
	 			   {"VIEW_HE"	,"TFU_HE"	, STR0219, STR0031 }}  //"Hora Extra"
Else
	If lTecItExtOp
		aModelsId := {  {"VIEW_LOC"	,"TFL_LOC"	, STR0213, STR0022 },; //"Locais de Atendimento"
						{"VIEW_RH"	,"TFF_RH"	, STR0214, STR0006 }} //"Recursos Humanos"
	Else
		aModelsId := {  {"VIEW_LOC"	,"TFL_LOC"	, STR0213, STR0022 },; //"Locais de Atendimento"
						{"VIEW_RH"	,"TFF_RH"	, STR0214, STR0006 },; //"Recursos Humanos"
						{"VIEW_MI"	,"TFG_MI"	, STR0216, STR0007 },; //"Materiais de Implantação"
						{"VIEW_MC"	,"TFH_MC"	, STR0217, STR0008 }}  //"Material de Consumo"
	
	Endif
Endif

For nI := 1 To Len(aModelsId)
	Aadd(aEscolha , aModelsId[nI,3] )
Next nI

//Escolhe qual aba deseja posicionar
nEscAba := GSEscolha( 	STR0220,;  // "Posicione"
						STR0221,;  // "Selecione em qual grid deseja posicionar."
						aEscolha,;
						1)

//Se confirmou alguma aba
If nEscAba >  0
	MsgRun( STR0222, STR0082, { || At740Posic(nEscAba,oVw,aModelsId,aEscolha)} ) //"Montando a pesquisa do posicione."#"Aguade..."
Endif

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740Posic
Monta a tela de posicionamento via parambox.

@since	26/06/2019
@author	Kaique Schiller
/*/
//------------------------------------------------------------------------------
Static Function At740Posic(nEscAba,oVw,aModelsId,aEscolha)
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
	If !Empty(aPrBox) .And. ParamBox(aPrBox,STR0212+" - "+aModelsId[nEscAba,3],@aRet,,,,,,,,.F.) //Posicione
	
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

			If nEscAba == 4 .Or. nEscAba == 5 .Or. nEscAba == 6 .Or. nEscAba ==  7

				//Se aba de recursos humanos não estiver posicionado, realiza o posicionamento.
				If oVw:GetFolderActive("ABAS", 2)[2] <> STR0006
					oVw:SelectFolder("ABAS", STR0006, 2) // "Aba de Recursos Humanos"
				Endif
				
				oVw:SelectFolder("RH_ABAS", aModelsId[nEscAba,4],2) // "Aba inferior"

			Endif
				
			If !oMdlDtl:SeekLine( aSeekLine )
				If !IsBlind()
					MsgAlert(STR0210) //"Não foi possível posicionar na linha, verifique as informações inseridas."
				Endif
			Endif
		Else
			If !IsBlind()
				MsgAlert(STR0211) //"Não foi possível posicionar na linha, preencha os campos do posicionamento."
			Endif
		Endif
	Endif
Endif

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VlExl
Valida a exclusão do local de atendimento na revisão de contratos.

@since	23/07/2019
@author	Serviços
/*/
//------------------------------------------------------------------------------
Static Function At740VlExl(oMdl)
Local aArea			:= GetArea()
Local oMdlTFL		:= oMdl:GetModel("TFL_LOC")
Local oMdlTFF		:= oMdl:GetModel("TFF_RH")
Local oMdlTFI		:= oMdl:GetModel("TFI_LE")
Local oMdlTFG		:= oMdl:GetModel("TFG_MI")
Local oMdlTFH		:= oMdl:GetModel("TFH_MC")
Local aSaveLines	:= FWSaveRows()
Local lRet			:= .T.
Local lOkTFF		:= .T.
Local lOkTFS		:= .T.
Local lOkTEW		:= .T.
Local lOkCNA		:= .T.
Local aCmpTFS		:= {}
Local cMens			:= ""
Local cMens02		:= ""
Local cTmpCNA		:= ""
Local cTmpTFF		:= ""
Local cTmpTFS		:= ""
Local cTmpTEW		:= ""
Local cTmpCNB		:= ""
Local cTmpTFH		:= ""
Local cTmpTFG		:= ""
Local cProduto		:= ""
Local cTpMov		:= ""
Local cPicTFSQtde	:= PesqPict("TFS","TFS_QUANT")
Local nInd			:= 0
Local nQuant		:= 0
Local nSld			:= 0
Local nLinTFF		:= 0
Local nLinTFI		:= 0
Local lOrcPrc 		:= SuperGetMv("MV_ORCPRC",,.F.)

If !oMdlTFL:IsEmpty()

	cMens	+= If( !Empty(cMens), CRLF + CRLF, "" )
	cMens	+=	STR0224 	+ AllTrim(oMdlTFL:GetValue("TFL_CODIGO")) 	+ " "+; // "Código: "
				STR0225		+ AllTrim(oMdlTFL:GetValue("TFL_LOCAL")) 	+ "-"+; // "Local: "
							  AllTrim(oMdlTFL:GetValue("TFL_DESLOC")) 	


	//Verificar se o algum item do local já foi faturado.
		If !Empty(oMdlTFL:GetValue("TFL_PLAN"))
			
			cTmpCNA	:= GetNextAlias()
		
			BeginSql Alias cTmpCNA
				SELECT CNA.CNA_VLTOT, CNA.CNA_SALDO
				FROM %table:CNA% CNA
				WHERE CNA.CNA_FILIAL = %xFilial:CNA%
					AND CNA.CNA_CONTRA = %exp:oMdlTFL:GetValue("TFL_CONTRT")%
					AND CNA.CNA_REVISA = %exp:oMdlTFL:GetValue("TFL_CONREV")%
					AND CNA.CNA_NUMERO = %exp:oMdlTFL:GetValue("TFL_PLAN")%
					AND CNA.%NotDel%
			EndSql
			
			DbSelectArea(cTmpCNA)
			(cTmpCNA)->(DbGoTop())
		
			If	((cTmpCNA)->(!EOF()) .And. (cTmpCNA)->CNA_VLTOT <> (cTmpCNA)->CNA_SALDO)
				lOkCNA	:= .F.
				cMens	+= If( !Empty(cMens), CRLF + CRLF, "" )
				cMens	+= STR0226  //"Não é possível continuar com a exclusão desse Local de Atendimento, a medição dos itens do Local de Atendimento já foram realizadas."
			EndIf
			(cTmpCNA)->(DbCloseArea())
		EndIf
	If	!(oMdlTFF:IsEmpty())

		//Verificar os itens do RH
		For nLinTFF := 1 to oMdlTFF:Length()
			oMdlTFF:GoLine(nLinTFF)

			//Verificar se existe agenda gerada
			cTmpTFF	:= GetNextAlias()

			BeginSql Alias cTmpTFF
			   SELECT DISTINCT TFF.TFF_CONTRT, ABQ.ABQ_ITEM, TFF.TFF_COD, TFF.TFF_ITEM,
			                   TFF.TFF_PRODUT, (TFF.TFF_CONTRT || ABQ.ABQ_ITEM || 'CN9') AS TFF_IDCFAL,
			                   ABB.ABB_CODTEC, AA1.AA1_NOMTEC, SRJ.RJ_DESC
			     FROM %table:TFF% TFF
			          INNER JOIN %table:ABQ% ABQ ON ABQ.ABQ_FILIAL = %xFilial:ABQ%
			                                    AND ABQ.%NotDel%
			                                    AND ABQ.ABQ_FILTFF = TFF.TFF_FILIAL
			                                    AND ABQ.ABQ_CODTFF = TFF.TFF_COD
			          INNER JOIN %table:ABB% ABB ON ABB.ABB_FILIAL = %xFilial:ABB%
			                                    AND ABB.%NotDel%
			                                    AND ABB.ABB_IDCFAL = (TFF.TFF_CONTRT || ABQ.ABQ_ITEM || 'CN9')
			          INNER JOIN %table:AA1% AA1 ON AA1.AA1_FILIAL = %xFilial:AA1%
			                                    AND AA1.%NotDel%
			                                    AND AA1.AA1_CODTEC = ABB.ABB_CODTEC
			          INNER JOIN %table:SRJ% SRJ ON SRJ.RJ_FILIAL = %xFilial:SRJ%
			                                    AND SRJ.%NotDel%
			                                    AND SRJ.RJ_FUNCAO = TFF.TFF_FUNCAO
			    WHERE TFF.TFF_FILIAL = %xFilial:TFF%
			      AND TFF.%NotDel%
			      AND TFF.TFF_COD 	 = %exp:oMdlTFF:GetValue("TFF_COD")%
			      AND 'S' IN (SELECT DISTINCT 'S' AGENDAATIVA
			                    FROM %table:ABB% ABB
			                   WHERE ABB.ABB_FILIAL = %xFilial:ABB%
			                     AND ABB.%NotDel%
			                     AND ABB.ABB_ATIVO = '1'
			                     AND ABB.ABB_IDCFAL = (TFF.TFF_CONTRT || ABQ.ABQ_ITEM || 'CN9'))
			    ORDER BY TFF.TFF_CONTRT, ABQ.ABQ_ITEM, TFF.TFF_COD, TFF.TFF_ITEM, TFF.TFF_PRODUT
			EndSql

			DbSelectArea(cTmpTFF)
			(cTmpTFF)->(DbGoTop())
			
			If	(cTmpTFF)->(!EOF())
				lOkTFF	:= .F.
				cMens	+= If( !Empty(cMens), CRLF + CRLF, "" )
				cMens	+= STR0227 + CRLF	//"Os atendentes abaixo possuem agenda ativa:"
			EndIf
			
			While (cTmpTFF)->(!EOF())
				
				cMens	+= If( !Empty(cMens), CRLF, "" )
				
				cMens	+=	STR0228  + " [" + AllTrim((cTmpTFF)->TFF_ITEM) 	 + "] " +;	//"RH-Item:"
							STR0229	 + " [" + AllTrim((cTmpTFF)->TFF_PRODUT) + "] " +;	//"Cod. Prod:"
							STR0230	 + " [" + AllTrim((cTmpTFF)->ABB_CODTEC) + "-"  +;  //"Atendente:"
											  AllTrim((cTmpTFF)->AA1_NOMTEC) + "] " +; 	
							STR0231	 + " [" + AllTrim((cTmpTFF)->RJ_DESC) 	 + "] " 	//"Função:"

				(cTmpTFF)->(dBSkip())

			Enddo
			
			(cTmpTFF)->(DbCloseArea())
			
			If !lOrcPrc .And. !(oMdlTFG:IsEmpty())
				//Verificar os materiais de implantação não retornados
				cTmpTFS	:=	GetNextAlias()
				BeginSql Alias cTmpTFS
				   SELECT TFF.TFF_ITEM, TFF.TFF_COD, TFS.TFS_PRODUT, SB1.B1_DESC, SUM(TFS.TFS_QUANT) AS QtTotal, TFS.TFS_MOV, TFG.TFG_RESRET
				     FROM %table:TFS% TFS
				          INNER JOIN %table:TFG% TFG on TFG.TFG_FILIAL = %xFilial:TFG%
				                                    AND TFG.%NotDel%
				                                    AND TFG.TFG_COD = TFS.TFS_CODTFG
				          INNER JOIN %table:TFF% TFF on TFF.TFF_FILIAL = %xFilial:TFF%
				                                    AND TFF.%NotDel%
				                                    AND TFF.TFF_COD = TFG.TFG_CODPAI
				          INNER JOIN %table:SB1% SB1 on SB1.B1_FILIAL = %xFilial:SB1%
				                                    AND SB1.%NotDel%
				                                    AND SB1.B1_COD = TFS.TFS_PRODUT
				    WHERE TFF.TFF_FILIAL = %xFilial:TFF%
				      AND TFF.%NotDel%
				      AND TFF.TFF_COD 	 = %exp:oMdlTFF:GetValue("TFF_COD")%
				    GROUP BY TFF_COD, TFF_ITEM, TFS_PRODUT, SB1.B1_DESC, TFS_QUANT, TFS_MOV, TFG_RESRET
				    ORDER BY TFF_COD, TFF_ITEM, TFS_PRODUT, TFS_MOV
				EndSql
				
				aCmpTFS	:=	{}
				cMens02	:= ""
				nSld	:= 0
	
				DbSelectArea(cTmpTFS)
				(cTmpTFS)->(DbGoTop())
	
				While (cTmpTFS)->(!EOF())
					aAdd(aCmpTFS,{(cTmpTFS)->TFS_PRODUT,;
									(cTmpTFS)->QtTotal,;
									(cTmpTFS)->TFS_MOV,;
									(cTmpTFS)->TFG_RESRET,;
									(cTmpTFS)->TFF_ITEM,;
									(cTmpTFS)->B1_DESC})
					(cTmpTFS)->(dBSkip())
				Enddo
	
				(cTmpTFS)->(DbCloseArea())
	
				//Verificar se existe quantidade (saldo) a retornar
				For nInd := 1 to len(aCmpTFS)
				
					If cProduto == aCmpTFS[nInd][1] .OR. nInd == 1
						nRes	:= aCmpTFS[nInd][4]
						nQuant	:= aCmpTFS[nInd][2]
						cTpMov	:= aCmpTFS[nInd][3]
	
						If cTpMov == "1"
							nSld	+= nQuant
						Elseif cTpMov == "2"
							nSld	-= nQuant
						Endif
	
						//Se for o último registro
						If nInd == len(acmpTFS)
							If nSld - nRes > 0
								cMens02	+= If( !Empty(cMens02), CRLF, "" )
								//Se existir saldo a retornar, avisar o usuário...
								cMens02	+=	STR0232		+ " [" + AllTrim(aCmpTFS[nInd][5]) + "] " +;		//"MI-Item:"
											STR0229 	+ " [" + AllTrim(aCmpTFS[nInd][1]) + "-"  +; 		//"Cod. Prod:"
																 AllTrim(aCmpTFS[nInd][6]) + "] " +;		
											STR0233		+ " [" + AllTrim(Transform(nSld,cPicTFSQtde)) + "]"	//"Quantidade:" 
								lOkTFS	:= .F.
							Endif
						Endif
	
					Elseif cProduto <> aCmpTFS[nInd][1]
						If nSld - nRes > 0
							cMens02	+= If( !Empty(cMens02), CRLF, "" )
							//Se existir saldo a retornar, avisar o usuário...
							cMens02	+=	STR0232		+ " [" + AllTrim(aCmpTFS[nInd][5]) + "] " +;		//"MI-Item:"
										STR0229		+ " [" + AllTrim(aCmpTFS[nInd][1]) + "-"  +;		//"Cod. Prod:" 
										 					 AllTrim(aCmpTFS[nInd][6]) + "] " +;		
										STR0233 	+ " [" + AllTrim(Transform(nSld,cPicTFSQtde)) + "]"	//"Quantidade:" 
	
							lOkTFS	:= .F.
							//zera as quantidades
							nSld	:= 0
							nRes	:= 0
							nQuant	:= 0
						Endif
					Endif
					cProduto	:= aCmpTFS[nInd][1]
				Next nInd
					
				If	!Empty(cMens02)
					cMens	+= If( !Empty(cMens), CRLF + CRLF, "" )
					cMens	+= STR0234 + CRLF + CRLF	//"Os materiais de implantação abaixo estão pendentes de retorno:"
					cMens	+= cMens02 + CRLF
				EndIf
			Endif
		Next nLinTFF
	EndIf

	If lOrcPrc .And. !(oMdlTFG:IsEmpty())
	
		//Verificar os materiais de implantação não retornados
		cTmpTFS	:=	GetNextAlias()
		BeginSql Alias cTmpTFS
		   SELECT TFL.TFL_CODIGO, TFL.TFL_LOCAL, TFS.TFS_PRODUT, SB1.B1_DESC, SUM(TFS.TFS_QUANT) AS QtTotal, TFS.TFS_MOV, TFG.TFG_RESRET
		     FROM %table:TFS% TFS
		          INNER JOIN %table:TFG% TFG on TFG.TFG_FILIAL = %xFilial:TFG%
		                                    AND TFG.%NotDel%
		                                    AND TFG.TFG_COD = TFS.TFS_CODTFG
		          INNER JOIN %table:TFL% TFL on TFL.TFL_FILIAL = %xFilial:TFL%
		                                    AND TFL.%NotDel%
		                                    AND TFL.TFL_CODIGO = TFG.TFG_CODPAI
		                                    AND TFL.TFL_LOCAL  = TFG.TFG_LOCAL
		          INNER JOIN %table:SB1% SB1 on SB1.B1_FILIAL = %xFilial:SB1%
		                                    AND SB1.%NotDel%
		                                    AND SB1.B1_COD = TFS.TFS_PRODUT
		    WHERE TFG.TFG_FILIAL = %xFilial:TFG%
		      AND TFG.%NotDel%
		      AND TFG.TFG_CODPAI 	 = %exp:oMdlTFL:GetValue("TFL_CODIGO")%
		      AND TFG.TFG_LOCAL		 = %exp:oMdlTFL:GetValue("TFL_LOCAL")%
			    GROUP BY TFL_CODIGO, TFL_LOCAL , TFS_PRODUT, SB1.B1_DESC, TFS_QUANT, TFS_MOV, TFG_RESRET
			    ORDER BY TFL_CODIGO, TFL_LOCAL , TFS_PRODUT, TFS_MOV
			EndSql
			
			aCmpTFS	:=	{}
			cMens02	:= ""
		nSld	:= 0

		DbSelectArea(cTmpTFS)
		(cTmpTFS)->(DbGoTop())

		While (cTmpTFS)->(!EOF())
			aAdd(aCmpTFS,{(cTmpTFS)->TFS_PRODUT,;
							(cTmpTFS)->QtTotal,;
							(cTmpTFS)->TFS_MOV,;
							(cTmpTFS)->TFG_RESRET,;
							(cTmpTFS)->TFL_LOCAL,;
							(cTmpTFS)->B1_DESC})
			(cTmpTFS)->(dBSkip())
		Enddo

		(cTmpTFS)->(DbCloseArea())

		//Verificar se existe quantidade (saldo) a retornar
		For nInd := 1 to len(aCmpTFS)
		
			If cProduto == aCmpTFS[nInd][1] .OR. nInd == 1
				nRes	:= aCmpTFS[nInd][4]
				nQuant	:= aCmpTFS[nInd][2]
				cTpMov	:= aCmpTFS[nInd][3]

				If cTpMov == "1"
					nSld	+= nQuant
				Elseif cTpMov == "2"
					nSld	-= nQuant
				Endif

				//Se for o último registro
				If nInd == len(acmpTFS)
					If nSld - nRes > 0
						cMens02	+= If( !Empty(cMens02), CRLF, "" )
						//Se existir saldo a retornar, avisar o usuário...
						cMens02	+=	STR0229		+ " [" + AllTrim(aCmpTFS[nInd][1]) + "-"  +; 		//"Cod. Prod:"
														 AllTrim(aCmpTFS[nInd][6]) + "] " +;		
									STR0233 	+ " [" + AllTrim(Transform(nSld,cPicTFSQtde)) + "]"	//"Quantidade:" 
						lOkTFS	:= .F.
					Endif
				Endif

			Elseif cProduto <> aCmpTFS[nInd][1]
				If nSld - nRes > 0
					cMens02	+= If( !Empty(cMens02), CRLF, "" )
					//Se existir saldo a retornar, avisar o usuário...
					cMens02	+=	STR0229 	+ " [" + AllTrim(aCmpTFS[nInd][1]) + "-"  +;		//"Cod. Prod:" 
								 					 AllTrim(aCmpTFS[nInd][6]) + "] " +;		
								STR0233		+ " [" + AllTrim(Transform(nSld,cPicTFSQtde)) + "]"	//"Quantidade:" 

					lOkTFS	:= .F.
					//zera as quantidades
					nSld	:= 0
					nRes	:= 0
					nQuant	:= 0
				Endif
			Endif
			cProduto	:= aCmpTFS[nInd][1]
		Next nInd
			
		If	!Empty(cMens02)
			cMens	+= If( !Empty(cMens), CRLF + CRLF, "" )
			cMens	+= STR0234 + CRLF + CRLF	//"Os materiais de implantação abaixo estão pendentes de retorno:"
			cMens	+= cMens02 + CRLF
		EndIf

	Endif
	
	If	!(oMdlTFI:IsEmpty())

		//Verificar os itens de locação
		For nLinTFI := 1 to oMdlTFI:Length()
			oMdlTFI:GoLine(nLinTFI)
			//Verificar equipamentos não retornados
			cTmpTEW	:= GetNextAlias()
			BeginSql Alias cTmpTEW
				SELECT TEW.TEW_CODEQU, TEW.TEW_PRODUT, TEW.TEW_BAATD, SB1.B1_DESC, TEW.TEW_DTRFIM, TFI.TFI_COD, TFI.TFI_ITEM
				  FROM %table:TEW% TEW
				       INNER JOIN %table:TFI% TFI on TFI.TFI_FILIAL = %xFilial:TFI%
				                                 AND TFI.%NotDel%
				                                 AND TFI.TFI_COD = TEW.TEW_CODEQU
				       INNER JOIN %table:SB1% SB1 on SB1.B1_FILIAL = %xFilial:SB1%
				                                 AND SB1.%NotDel%
				                                 AND SB1.B1_COD = TEW.TEW_PRODUT
				 WHERE TEW.TEW_FILIAL = %xFilial:TEW%
				   AND TEW.%NotDel%
				   AND TEW.TEW_CODEQU = %exp:oMdlTFI:GetValue("TFI_COD")%
				   AND TEW.TEW_DTSEPA <> ''
			EndSql

			DbSelectArea(cTmpTEW)
			(cTmpTEW)->( DbGoTop() )

			If	(cTmpTEW)->(!EOF())
				lOkTEW	:= .F.
				cMens	+= If( !Empty(cMens), CRLF + CRLF, "" )
				cMens	+= CRLF + STR0235 + CRLF	//"Os equipamentos abaixo estão pendentes de retorno ou encontram-se separados:"
			EndIf

			While (cTmpTEW)->(!EOF())
				cMens	+= If( !Empty(cMens), CRLF, "" )

				cMens	+=	STR0236		+ " [" + AllTrim((cTmpTEW)->TFI_ITEM) 	+ "] " +;	//"LE-Item:"
							STR0237		+ " [" + AllTrim((cTmpTEW)->TFI_COD) 	+ "] " +;	//"Cód. Locação:" 
							STR0229	 	+ " [" + AllTrim((cTmpTEW)->TEW_PRODUT) + "-"  +;
							 					 AllTrim((cTmpTEW)->B1_DESC) 	+ "] " +;	//"Cod. Prod:"
							STR0238 	+ " [" + AllTrim((cTmpTEW)->TEW_BAATD) 	+ "] "		//"Núm. Série:" 

				(cTmpTEW)->(dBSkip())
			Enddo
			(cTmpTEW)->(DbCloseArea())
		Next nLinTFI
	EndIf
Endif

lRet := ( lOkCNA .And. lOkTFF .And. lOkTFS .And. lOkTEW )

If !lRet
	AtShowLog(cMens,STR0239, .T., .T., .F.)  // "Inconsistências."
	Help( , , "At740VlExl", , STR0240, 1, 0,,,,,, {STR0241}) //"Não será possivel realizar a exclusão do Local de Atendimento, pois existem inconsistências que impedem tal procedimento."##"Realize as manutenções necessárias para que sejam atendidas as premissas para a exclusão do Local de Atendimento."
Endif

FWRestRows( aSaveLines )
RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ExTFF

@description Valida se é possivel excluir o item de RH.
@author	Augusto Albuquerque
@since	28/10/2019
/*/
//------------------------------------------------------------------------------
Function At740ExTFF(oMdl)
Local cTmpCNB		:= GetNextAlias()
Local cTmpTFH		:= GetNextAlias()
Local cTmpTFG		:= GetNextAlias()
Local cTmpTFF		:= GetNextAlias()
Local cTmpTFS		:= GetNextAlias()
Local cGsDsGcn		:= SuperGetMv("MV_GSDSGCN",,"2")
Local cMsg			:= ""
Local lOrcPrc 		:= SuperGetMv("MV_ORCPRC",,.F.)
Local lRet			:= .T.
Local lMed			:= .T.
Local nX
Local nLinPosi		:= 1
Local oMdlTFL		:= oMdl:GetModel("TFL_LOC")
Local oMdlTFF		:= oMdl:GetModel("TFF_RH")
Local oMdlTFG		:= oMdl:GetModel("TFG_MI")
Local oMdlTFH		:= oMdl:GetModel("TFH_MC")		

If cGsDsGcn == "1"
	BeginSql Alias cTmpCNB	
		SELECT CNB.CNB_QTDMED, CNB.CNB_VLUNIT
		FROM %table:CNB% CNB
		WHERE CNB.CNB_FILIAL = %xFilial:CNB%
			AND CNB.CNB_CONTRA = %exp:oMdlTFF:GetValue("TFF_CONTRT")%
			AND CNB.CNB_REVISA = %exp:oMdlTFF:GetValue("TFF_CONREV")%
			AND CNB.CNB_NUMERO = %exp:oMdlTFL:GetValue("TFL_PLAN")%
			AND CNB.CNB_PRODUT = %exp:oMdlTFF:GetValue("TFF_PRODUT")%
			AND CNB.CNB_ITEM = %exp:oMdlTFF:GetValue("TFF_ITCNB")%
			AND CNB.%NotDel%
	EndSql
	If	lOrcPrc
		If (cTmpCNB)->CNB_QTDMED > 0
			If (cTmpCNB)->CNB_QTDMED * (cTmpCNB)->CNB_VLUNIT >= oMdlTFF:GetValue("TFF_PRCVEN")
				lRet := .F.
				cMsg	+= STR0245 + CRLF // "Não é possivel excluir o item, pois o item ja foi medido."
				cMsg	+= STR0246 + CValToChar((cTmpCNB)->CNB_QTDMED * (cTmpCNB)->CNB_VLUNIT) + CRLF + CRLF // "Se desejar, reduza o item para valor superior a medição de: "
			EndIf
		EndIf
	Else
		If (cTmpCNB)->CNB_QTDMED > 0
			lRet := .F.
			cMsg	+= STR0245 + CRLF // "Não é possivel excluir o item, pois o item ja foi medido."
			cMsg	+= STR0246 + CValToChar((cTmpCNB)->CNB_QTDMED * (cTmpCNB)->CNB_VLUNIT) + CRLF + CRLF // "Se desejar, reduza o item para valor superior a medição de: "
		Else
			BeginSql Alias cTmpTFH	
				SELECT CNB.CNB_QTDMED
				FROM %table:CNB% CNB
				INNER JOIN %table:TFH% TFH
					ON TFH.TFH_FILIAL = %xFilial:TFH%
					AND TFH.TFH_CODPAI = %exp:oMdlTFF:GetValue("TFF_COD")%
				WHERE CNB.CNB_FILIAL = %xFilial:CNB%
					AND CNB.CNB_CONTRA = TFH.TFH_CONTRT
					AND CNB.CNB_REVISA = TFH.TFH_CONREV
					AND CNB.CNB_NUMERO = %exp:oMdlTFL:GetValue("TFL_PLAN")%
					AND CNB.CNB_PRODUT = TFH.TFH_PRODUT
					AND CNB.CNB_ITEM =	TFH.TFH_ITCNB
					AND CNB.%NotDel%
			EndSql
			While (cTmpTFH)->(!Eof()) 
				If (cTmpTFH)->CNB_QTDMED > 0
					lMed := .F.
				EndIf
				(cTmpTFH)->(DbSkip())
			EndDo
			(cTmpTFH)->(DbCloseArea())
			If lMed
				BeginSql Alias cTmpTFG	
					SELECT CNB.CNB_QTDMED
					FROM %table:CNB% CNB
					INNER JOIN %table:TFG% TFG
						ON TFG.TFG_FILIAL = %xFilial:TFG%
						AND TFG.TFG_CODPAI = %exp:oMdlTFF:GetValue("TFF_COD")%
					WHERE CNB.CNB_FILIAL = %xFilial:CNB%
						AND CNB.CNB_CONTRA = TFG.TFG_CONTRT
						AND CNB.CNB_REVISA = TFG.TFG_CONREV
						AND CNB.CNB_NUMERO = %exp:oMdlTFL:GetValue("TFL_PLAN")%
						AND CNB.CNB_PRODUT = TFG.TFG_PRODUT
						AND CNB.CNB_ITEM =	TFG.TFG_ITCNB
						AND CNB.%NotDel%
				EndSql
				While (cTmpTFG)->(!Eof()) 
					If (cTmpTFG)->CNB_QTDMED > 0
						lMed := .F.
					EndIf
					(cTmpTFG)->(DbSkip())
				EndDo
				(cTmpTFG)->(DbCloseArea())
			EndIf
			If !lMed
				lRet := .F.
				cMsg	+= STR0247 + CRLF + CRLF // "Item de MI/MC com medição, não é possivel excluir o item de RH."
			EndIf
		EndIf
		(cTmpCNB)->(DbCloseArea())
	EndIf
EndIf

//Verifica se existe agenda
If lRet
	BeginSql Alias cTmpTFF
		SELECT 1
		FROM %table:ABB% ABB
		INNER JOIN %table:ABQ% ABQ ON ABQ.ABQ_FILIAL = %xFilial:ABQ%
			AND ABQ.ABQ_CODTFF = %exp:oMdlTFF:GetValue("TFF_COD")%
			AND ABQ.%NotDel%
		WHERE ABB.ABB_FILIAL = %xFilial:ABB%
			AND ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM
			AND ABB.%NotDel%
	EndSql
	
	If	(cTmpTFF)->(!EOF())
		lRet	:= .F.
		cMsg	+= STR0251 + CRLF	// "O item possui alocação. Para maiores informações acesse o gestão de escala ou a mesa operacional."
	EndIf
	
	(cTmpTFF)->(DbCloseArea())

	If !lOrcPrc .AND. !(oMdlTFG:IsEmpty())
		nLinPosi	:= oMdlTFG:GetLine()
		For nX := 1 To oMdlTFG:Length()
			oMdlTFG:GoLine(nX)
			BeginSql Alias cTmpTFS
				SELECT 1 
				FROM %table:TFS% TFS
				WHERE
					TFS.TFS_FILIAL = %xFilial:TFS%
					AND TFS.TFS_CODTFG = %exp:oMdlTFG:GetValue("TFG_COD")%
					AND TFS.%NotDel%
			EndSql
			If (cTmpTFS)->(!EOF())
				lRet	:= .F.
				cMsg	+= STR0248 + CRLF // "O item seguinte possui apontamento. "
				cMsg	+= STR0249 + oMdlTFG:GetValue("TFG_PRODUT") + CRLF // "Produto: "
				cMsg	+= STR0250 + oMdlTFG:GetValue("TFG_COD") + CRLF + CRLF // "Codigo: "
			EndIf
			(cTmpTFS)->(DbCloseArea())
		Next nX
		oMdlTFG:GoLine(nLinPosi)
	EndIf

	If	!lOrcPrc .AND. !(oMdlTFH:IsEmpty())
		nLinPosi	:= oMdlTFH:GetLine()
		For nX := 1 To oMdlTFH:Length()
			oMdlTFH:GoLine(nX)
			BeginSql Alias cTmpTFH
				SELECT 1 
				FROM %table:TFT% TFT
				WHERE
					TFT.TFT_FILIAL = %xFilial:TFT%
					AND TFT.TFT_CODTFH = %exp:oMdlTFH:GetValue("TFH_COD")%
					AND TFT.%NotDel%
			EndSql
			If (cTmpTFH)->(!EOF())
				lRet	:= .F.
				cMsg	+= STR0248 + CRLF // "O item seguinte possui apontamento. "
				cMsg	+= STR0249 + oMdlTFH:GetValue("TFH_PRODUT") + CRLF // "Produto: "
				cMsg	+= STR0250 + oMdlTFH:GetValue("TFH_COD") + CRLF + CRLF // "Codigo: "
			EndIf
			(cTmpTFH)->(DbCloseArea())
		Next nX
		oMdlTFH:GoLine(nLinPosi)
	EndIf
EndIf

If !(isBlind())
	If !lRet
		AtShowLog(cMsg,STR0239, .T., .T., .F.)  // "Inconsistências."
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740AVerABB
	
Verifica se existe agendamento para o recurso do contrato

@sample 	At740AVerABB( cCodTFF )

@param 		cCodTFF - Codigo do recurso humano do contrato
		
@since		02/10/2013       
@version	P11.90

@return 	nRet, retorna o resultado do cálculo

/*/
//------------------------------------------------------------------------------
Static Function At740VerABB( cCodTFF )
Local lRet := .F.
Local cAliasABB := GetNextAlias()

BeginSql Alias cAliasABB

	SELECT 
		ABB.ABB_CODIGO 
	FROM 
		%Table:ABQ% ABQ
	JOIN %Table:ABB% ABB ON 
		ABB.ABB_FILIAL = %xFilial:ABB% AND 
		ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM AND
		ABB.%NotDel%
	WHERE 
		ABQ.ABQ_FILIAL = %xFilial:ABQ% AND 
		ABQ.ABQ_CODTFF = %Exp:cCodTFF% AND 
		ABQ.%NotDel%

EndSql

If ((cAliasABB)->(Eof()) .And. (cAliasABB)->(Bof()))	
	lRet := .T. 
EndIf 

(cAliasABB)->(dbCloseArea())

Return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740TarEx
Analisa recurso humano informado na TFF para serviço extra, caso o mesmo possua risco (1-SIM) cria automaticamente uma tarefa de funcionário (TN5). 
A tarefa será criada com um sequencia automática e será considerado o campo LOCAL e FUNÇÃO informada no contrato.  

@param  cLocal, Caracter, Codigo do Local
@param  aTFF, Array, Array contendo a TFF de cada local

@return Nenhum
@author Luiz Gabriel
@since 14/03/2019
/*/
//------------------------------------------------------------------------------------------	
Static Function At740TarEx(cLocal,aItemRH)
Local aArea		:= {}
Local nCont		:= 0
Local cQueryNum	:= ""
Local cQueryTN5	:= ""
Local cProxTN5	:= ""
Local cFilTN5	:= ""

DbSelectArea("TN5")
TN5->(DbSetOrder(1))
If TN5->( ColumnPos("TN5_LOCAL")) > 0 .And. TN5->( ColumnPos("TN5_POSTO")) > 0 

	aArea		:= GetArea()
	cQueryNum	:= GetNextAlias()

	BeginSql Alias cQueryNum
		SELECT MAX(TN5_CODTAR) ULTTAREFA  	
		FROM %Table:TN5% TN5
		WHERE TN5.TN5_FILIAL = %xFilial:TN5%
			AND TN5.%NotDel%
	EndSql
	
	cProxTN5 := Soma1( (cQueryNum)->ULTTAREFA )
	
	cFilTN5 := xFilial("TN5")
	
	For nCont := 1 To Len(aItemRH)
	
		If	aItemRH[nCont][14] == "1" 
			
			cQueryTN5 := GetNextAlias()
		
			BeginSql Alias cQueryTN5
			
				SELECT TN5.R_E_C_N_O_ TN5RECNO
				FROM %Table:TN5% TN5
				WHERE TN5.TN5_FILIAL	= %exp:xFilial('TN5')%
					AND TN5.TN5_LOCAL	= %exp:cLocal%
					AND TN5.TN5_POSTO	= %exp:aItemRH[nCont][3]%
					AND TN5.%NotDel%
			EndSql
	
			If (cQueryTN5)->(EOF())
				RecLock("TN5",.T.)
					TN5->TN5_FILIAL 	:= cFilTN5
					TN5->TN5_CODTAR 	:= cProxTN5
					TN5->TN5_NOMTAR 	:= cLocal + " - " + aItemRH[nCont][3]
					TN5->TN5_LOCAL		:= cLocal
					TN5->TN5_POSTO		:= aItemRH[nCont][3]
				TN5->(MsUnlock())
			Endif 	
		
			cProxTN5 := Soma1( cProxTN5 )
			
			(cQueryTN5)->(dbCloseArea())
			
		Endif
	
	Next nCont
	
	(cQueryNum)->(dbCloseArea())
	
	RestArea(aArea)

Endif

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740Horas
@description Valor do saldod de horas
@return nQtd
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At740Horas()
Local oModel	:= FwModelActive() 
Local oMdlTFF	:= oModel:GetModel("TFF_RH")
Local cCodTFF	:= oMdlTFF:GetValue("TFF_COD")
Local cAliasTFF	:= GetNextAlias()
Local cRet		:= oMdlTFF:GetValue("TFF_QTDHRS") 
Local cOldValue	:= ""

BeginSQL Alias cAliasTFF
	SELECT TFF.TFF_QTDHRS
		FROM %Table:TFF% TFF
		WHERE TFF.TFF_FILIAL = %xFilial:TFF%
			AND TFF.TFF_COD = %Exp:cCodTFF%
			AND TFF.%NotDel%
EndSQL

If !(cAliasTFF)->(EOF())
	cOldValue := (cAliasTFF)->TFF_QTDHRS
	If IsInCallStack("At870Revis")
		cRet := TecConvHr(SomaHoras(SubHoras(cRet, cOldValue ), oMdlTFF:GetValue("TFF_HRSSAL")))
	EndIf
EndIf
(cAliasTFF)->(DbCloseArea())

Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740APHR
@description Verifica se esxiste agenda gerada para o codigo de TFF
@return lRet
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At740APHR( cCodTFF )
Local lRet	:= .T.
Local cAliasABB := GetNextAlias()

BeginSQL Alias cAliasABB
	SELECT 1 REC
		FROM %Table:ABB% ABB
		INNER JOIN %Table:ABQ% ABQ 
			ON ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL
		WHERE ABB.ABB_FILIAL = %xFilial:ABB%
			AND ABQ.ABQ_FILTFF = %xFilial:TFF%
			AND ABQ.ABQ_CODTFF = %Exp:cCodTFF%
			AND ABQ.%NotDel%
			AND ABB.%NotDel%
EndSQL

lRet := !(cAliasABB)->(EOF())
(cAliasABB)->(DbCloseArea())

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecVldHrTF
@description Valid do Campo TFF_QTDHRS
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecVldHrTF( cCampo, xValue )
Local oModel	:= FwModelActive()
Local oMdlTFF	:= oModel:GetModel("TFF_RH")

If AT(":",xValue) == 0
	If LEN(Alltrim(xValue)) == 4
		xValue := LEFT(Alltrim(xValue),2) + ":" + RIGHT(Alltrim(xValue),2)
		oMdlTFF:LoadValue(cCampo, xValue)
	ElseIf LEN(Alltrim(xValue)) == 2
		xValue := Alltrim(xValue) + ":00"
		oMdlTFF:LoadValue(cCampo, xValue)
	ElseIf LEN(Alltrim(xValue)) == 1
		xValue := "0" + Alltrim(xValue) + ":00"
		oMdlTFF:LoadValue(cCampo, xValue)
	EndIf
EndIf

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecVldHrTF
@description Valid do Campo TFF_QTDHRS
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At740QTDHr( lRevis, nNewValue, nOldValue )
Local oModel	:= FwModelActive() 
Local oMdlTFF	:= oModel:GetModel("TFF_RH")
Local cRet		:= ""
Local cQtdHrs	:= oMdlTFF:GetValue("TFF_QTDHRS")  
Local nQuant	:= oMdlTFF:GetValue("TFF_QTDVEN")
Local cCodTFF	:= oMdlTFF:GetValue("TFF_COD")
Local cConta	:= ""
Local cAliasTFF	:= GetNextAlias()
Local nQtd		:= 0
Local nX

Default lRevis := .F.

If lRevis
	BeginSQL Alias cAliasTFF
		SELECT TFF.TFF_QTDHRS, TFF.TFF_QTDVEN
			FROM %Table:TFF% TFF
			WHERE TFF.TFF_FILIAL = %xFilial:TFF%
				AND TFF.TFF_COD = %Exp:cCodTFF%
				AND TFF.%NotDel%
	EndSQL

	If !(cAliasTFF)->(EOF())
		nQtd := nQuant - (cAliasTFF)->TFF_QTDVEN 
		cConta := TecConvHr(TecConvHr((cAliasTFF)->TFF_QTDHRS) / (cAliasTFF)->TFF_QTDVEN)
		If nQtd > 0
			cRet := cQtdHrs 
			For nX := 1 To nQtd
				cRet := TecConvHr(SomaHoras(cRet, cConta))
			Next nX
		ElseIf nQtd < 0
			For nX := 1 To nQuant
				cRet := TecConvHr(SomaHoras(cRet, cConta))
			Next nX
		Else
			For nX := 1 To nQuant
				cRet := TecConvHr(SomaHoras(cRet, cConta))
			Next nX
		EndIf
	EndIf
	(cAliasTFF)->(DbCloseArea())
Else
	If !Empty(cQtdHrs)
		cQtdHrs := TecConvHr(TecConvHr(cQtdHrs) / nOldValue)
		For nX := 1 To nNewValue
			cRet := TecConvHr(SomaHoras(cRet, cQtdHrs))
		Next nX
	EndIf
	oMdlTFF:LoadValue("TFF_QTDHRS", cRet)
	oMdlTFF:LoadValue("TFF_HRSSAL", cRet)
EndIf

Return cRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TC740VLCL
@description Utilizada na validação dos campos do addCalc para desconsiderar postos encerrados
@author Diego Bezerra
@since  14/05/2020
/*/
//--------------------------------------------------------------------------------------------------------------------

Function TC740VLCL(oModel, cFld, nDeduc, cIdModel)
Local lRet 	:= .T.
Local aArea := {}
Local lPrec	:= .F.
Default cIdModel = ""

lPrec := cIdModel == 'TECA740F'
If lCalcEnc
	IF EMPTY(oModel:GetValue("TFL_LOC","TFL_ENCE")) .OR. oModel:GetValue("TFL_LOC","TFL_ENCE") == "2"
		If cFld == 'TOT_RH' .OR. cFld == 'TOT_MI' .OR. cFld == 'TOT_MC'
			If cFld == 'TOT_RH'
				aArea := GetArea()
				DbSelectArea("TFF")
				TFF->(DbSetOrder(3))
				If TFF->( dbSeek( xFilial("TFF") + oModel:GetValue("TFL_LOC","TFL_CODIGO")  ) )
					While TFF->(!Eof()) .AND. TFF->TFF_CODPAI == oModel:GetValue("TFL_LOC","TFL_CODIGO") .AND. TFF->TFF_FILIAL == xFilial('TFF')
						If TFF->TFF_ENCE == "1" .AND. TFF->TFF_COBCTR == '1' 
							
							nDeduc += TFF->(TFF_QTDVEN*TFF_PRCVEN)+(TFF->(TFF_QTDVEN*TFF_PRCVEN)*(TFF->TFF_LUCRO/100))+(TFF->(TFF_QTDVEN*TFF_PRCVEN)*(TFF->TFF_ADM/100));
										+(TFF->(TFF_QTDVEN*TFF_PRCVEN)*(TFF->TFF_DESCON/100))
							
							If !lPrec
								DbSelectArea("TFG")
								TFG->(DbSetOrder(3))
								IF TFG->( dbSeek( xFilial("TFG") + TFF->TFF_COD))
									While TFG->(!Eof()) .AND. TFG_CODPAI == TFF->TFF_COD .AND. TFG_FILIAL == xFilial('TFG')
										nDeduc += TFG->(TFG_QTDVEN*TFG_PRCVEN)+(TFG->(TFG_QTDVEN*TFG_PRCVEN)*(TFG->TFG_LUCRO/100))+(TFG->(TFG_QTDVEN*TFG_PRCVEN)*(TFG->TFG_ADM/100));
													+(TFG->(TFG_QTDVEN*TFG_PRCVEN)*(TFG->TFG_DESCON/100))

										TFG->(dbSkip())
									EndDo
								EndIf

								DbSelectArea("TFH")
								TFH->(DbSetOrder(3))
								IF TFH->( dbSeek( xFilial("TFH") + TFF->TFF_COD))
									While TFH->(!Eof()) .AND. TFH_CODPAI == TFF->TFF_COD .AND. TFH_FILIAL == xFilial('TFH')
										nDeduc += TFH->(TFH_QTDVEN*TFH_PRCVEN)+(TFH->(TFH_QTDVEN*TFH_PRCVEN)*(TFH->TFH_LUCRO/100))+(TFH->(TFH_QTDVEN*TFH_PRCVEN)*(TFH->TFH_ADM/100));
													+(TFH->(TFH_QTDVEN*TFH_PRCVEN)*(TFH->TFH_DESCON/100))
										TFH->(dbSkip())
									EndDo
								EndIf
							EndIf

						EndIf
						TFF->(dbSkip())
					EndDo
				EndIf
				RestArea(aArea)
			EndIf
		EndIf

		If cFld == 'TOT_LE'
			aArea := GetArea()
			DbSelectArea("TFI")
			TFI->(DbSetOrder(3))
			If TFI->( dbSeek( xFilial("TFI") + oModel:GetValue("TFL_LOC","TFL_CODIGO")  ) )
				While TFI->(!Eof()) .AND. TFI->TFI_CODPAI == oModel:GetValue("TFL_LOC","TFL_CODIGO")
					If TFI->TFI_ENCE == "1"
						nDeduc += IIF(!EMPTY(TFI->TFI_TOTAL) .AND. valtype(TFI->TFI_TOTAL)=="N",TFI->TFI_TOTAL,0)
					EndIf
					TFI->(dbskip())
				EndDo
			EndIf
			RestArea(aArea)
		EndIf
	Else
		lRet := .F.	
	EndIf
EndIf
Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740PrxPa
@description Calcula automaticamente o valor do campo XXX_VLPRPA de acordo
com o model / params

@author Mateus Boiani
@since  17/06/2020
/*/
//------------------------------------------------------------------------------
Function At740PrxPa(cTipo, nQuantidade, nValor, nPercDesc, nValLucro, nValAdm)
Local nRet := 0
Local oModel := FwModelActive()
Local oMdlGrd

Default nQuantidade := 0
Default nValor := 0
Default nPercDesc := 0
Default nValLucro := 0
Default nValAdm := 0
Default cTipo := ""

If !EMPTY(cTipo) .AND. VALTYPE(oModel) == "O" .AND. oModel:Getid() $ "TECA740|TECA740F"
	If oModel:GetValue("TFJ_REFER","TFJ_CNTREC") == '1'
		If cTipo = "TFF"
			oMdlGrd := oModel:GetModel("TFF_RH")
			If oMdlGrd:GetValue("TFF_COBCTR") != '2'
				nQuantidade := oMdlGrd:GetValue("TFF_QTDVEN")
				nValor := oMdlGrd:GetValue("TFF_PRCVEN")
				nPercDesc := oMdlGrd:GetValue("TFF_DESCON")
				nValAdm := oMdlGrd:GetValue("TFF_TXADM")
				nValLucro := oMdlGrd:GetValue("TFF_TXLUCR")
			EndIf
		ElseIf cTipo == "TFH"
			oMdlGrd := oModel:GetModel("TFH_MC")
			If oMdlGrd:GetValue("TFH_COBCTR") != '2'
				nQuantidade := oMdlGrd:GetValue("TFH_QTDVEN")
				nValor := oMdlGrd:GetValue("TFH_PRCVEN")
				nPercDesc := oMdlGrd:GetValue("TFH_DESCON")
				nValAdm := oMdlGrd:GetValue("TFH_TXADM")
				nValLucro := oMdlGrd:GetValue("TFH_TXLUCR")
			EndIf
		ElseIf cTipo == "TFG"
			oMdlGrd := oModel:GetModel("TFG_MI")
			If oMdlGrd:GetValue("TFG_COBCTR") != '2'
				nQuantidade := oMdlGrd:GetValue("TFG_QTDVEN")
				nValor := oMdlGrd:GetValue("TFG_PRCVEN")
				nPercDesc := oMdlGrd:GetValue("TFG_DESCON")
				nValAdm := oMdlGrd:GetValue("TFG_TXADM")
				nValLucro := oMdlGrd:GetValue("TFG_TXLUCR")
			EndIf
		EndIf
	EndIf
EndIf

nRet := (nQuantidade * nValor) + nValLucro + nValAdm
nRet -= ((nQuantidade * nValor) * nPercDesc/100)

Return nRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740AtTpr
@description Atualiza o valor de TFL_VLPRPA de acordo com os dados do modelo

@author Mateus Boiani
@since  17/06/2020
/*/
//------------------------------------------------------------------------------
Function At740AtTpr()
Local oModel := FwModelActive()
Local nX
Local nY
Local oMdlTFF
Local oMdlTFL
Local oMdlTFH
Local oMdlTFG
Local oMdlTFJ
Local nRet := 0
Local aSaveLines
Local lAgrupado := SuperGetMv("MV_GSDSGCN",,"2") == '2'

If VALTYPE(oModel) == "O" .AND. oModel:Getid() $ "TECA740|TECA740F" .AND. TecVlPrPar()
	aSaveLines := FWSaveRows()
	oMdlTFF := oModel:GetModel("TFF_RH")
	oMdlTFL := oModel:GetModel("TFL_LOC")
	oMdlTFH := oModel:GetModel("TFH_MC")
	oMdlTFG := oModel:GetModel("TFG_MI")
	oMdlTFJ := oModel:GetModel("TFJ_REFER")

	If oMdlTFJ:GetValue("TFJ_CNTREC") == '1'
		For nX := 1 To oMdlTFF:Length()
			If oModel:Getid() == "TECA740"
				oMdlTFF:GoLine(nX)
				If !(oMdlTFF:isDeleted(nX)) .AND. !EMPTY( oMdlTFF:GetValue("TFF_PRODUT", nX) ) .AND. oMdlTFF:GetValue("TFF_COBCTR", nX) != "2"
					nRet += oMdlTFF:GetValue("TFF_VLPRPA", nX)
				EndIf
				For nY := 1 To oMdlTFH:Length()
					If !(oMdlTFH:isDeleted(nY)) .AND. !EMPTY( oMdlTFH:GetValue("TFH_PRODUT", nY) ) .AND. oMdlTFH:GetValue("TFH_COBCTR", nY) != "2"
						nRet += oMdlTFH:GetValue("TFH_VLPRPA",nY)
					EndIf
				Next nY
				For nY := 1 To oMdlTFG:Length()
					If !(oMdlTFG:isDeleted(nY)) .AND. !EMPTY( oMdlTFG:GetValue("TFG_PRODUT", nY) ) .AND. oMdlTFG:GetValue("TFG_COBCTR", nY) != "2"
						nRet += oMdlTFG:GetValue("TFG_VLPRPA",nY)
					EndIf
				Next nY
			Else
				If !(oMdlTFF:isDeleted(nX)) .AND. !EMPTY( oMdlTFF:GetValue("TFF_PRODUT", nX) ) .AND. oMdlTFF:GetValue("TFF_COBCTR", nX) != "2"
					nRet += oMdlTFF:GetValue("TFF_VLPRPA", nX)
				EndIf
			EndIf
		Next nX

		If oModel:Getid() == "TECA740F"
			For nY := 1 To oMdlTFH:Length()
				If !(oMdlTFH:isDeleted(nY)) .AND. !EMPTY( oMdlTFH:GetValue("TFH_PRODUT", nY) ) .AND. oMdlTFH:GetValue("TFH_COBCTR", nY) != "2"
					nRet += oMdlTFH:GetValue("TFH_VLPRPA",nY)
				EndIf
			Next nY
			For nY := 1 To oMdlTFG:Length()
				If !(oMdlTFG:isDeleted(nY)) .AND. !EMPTY( oMdlTFG:GetValue("TFG_PRODUT", nY) ) .AND. oMdlTFG:GetValue("TFG_COBCTR", nY) != "2"
					nRet += oMdlTFG:GetValue("TFG_VLPRPA",nY)
				EndIf
			Next nY
		EndIf
		FWRestRows( aSaveLines )
	EndIf
	oMdlTFL:LoadValue("TFL_VLPRPA",nRet)
EndIf

Return nil

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740TFUVa
@description Valid do campo TFU_VALOR
@return Boolean - se o valor é maior ou igual a 0
@author Augusto Albuquerque
@since  04/09/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At740TFUVa(nValor)
Return nValor >= 0
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740VlEsc
@description Validação de alteração da escala quando existe agenda gerada
@return Boolean - Não existe agenda = .T.
@author Kaique Schiller
@since  03/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At740VlEsc(cCodTFF,cEscala)
Local cTmpTFF 	:= GetNextAlias()
Local lRet		:= .T.
Local cExp     	:= "%%"
Local lMponto 	:= (ABB->(ColumnPos('ABB_MPONTO')) > 0 )
Local lTrocaEsc	:= At680Perm( Nil, __cUserID, "066" )

If lMponto
    cExp    := "%  AND ABB.ABB_MPONTO = 'F' AND ABB.ABB_ATIVO = '1' %"
Endif

//Verifica se há agendas iguais e posteriores a database do sistema
If lTrocaEsc .And. hasABBRig(dDataBase, cCodTFF, ,cEscala, .T.)
	lRet := .F.
	Help(,,"At740VlEsc",,STR0315 + dToc(dDataBase),; //"Este posto e escala possuem alocações com datas maiores ou iguais a "
					1,0,,,,,,{STR0316 + dToc(dDataBase) }) // ""Exclua as agendas com datas maiores ou iguais a "
EndIf 

If lRet
	BeginSql Alias cTmpTFF
		SELECT 1 
		FROM %table:ABB% ABB
		INNER JOIN %table:ABQ% ABQ ON ABQ.ABQ_FILIAL = %xFilial:ABQ%
			AND ABQ.ABQ_CODTFF = %exp:cCodTFF%
			AND ABQ.%NotDel%
		INNER JOIN %table:TDV% TDV ON TDV.TDV_FILIAL = %xFilial:TDV%
			AND TDV.TDV_CODABB = ABB.ABB_CODIGO
			AND TDV.%NotDel%
		WHERE ABB.ABB_FILIAL = %xFilial:ABB%
			AND ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM
			AND ABB.%NotDel%
			%exp:cExp%	
	EndSql

	If	(cTmpTFF)->(!EOF()) 
		If !lTrocaEsc
			lRet	:= .F.
			Help(,,"At740VlEsc",,STR0291,; //"Não é possível alterar a escala."
						1,0,,,,,,{STR0292}) // "Esse posto possui alocação para maiores informações acesse a mesa operacional."
		Else
			lRet := MsgYesNo(STR0312, STR0313)//"Já existem alocações relacionadas para esta escala. Alterar a escala não permitirá novas alocações na escala antiga, deseja continuar?"##"Troca de Escala"
			If !lRet
				Help(,,"At740VlEsc",,STR0314,1,0,,,,,,) //"Operação cancelada pelo usuario"					 
			EndIf
		EndIf				
	EndIf
	(cTmpTFF)->(DbCloseArea())
EndIf 

Return lRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} VldDatas
@description Validação das datas de MI e MC
@return Boolean 
@author Junior Geraldo
@since  29/04/2021
/*/
//------------------------------------------------------------------------------
Static Function VldDatas(oMdlG)
Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet      	:= .T.
Local oMdlFull 		:= oMdlG:GetModel()
Local oMdlMI		:= oMdlFull:GetModel("TFG_MI")
Local oMdlMC		:= oMdlFull:GetModel("TFH_MC")
Local lOrcPrc 	    := SuperGetMv("MV_ORCPRC",,.F.)
Local nX            := 1
Local lRecorre      := oMdlFull:GetValue("TFJ_REFER","TFJ_CNTREC")  == "1"
//Não verificar quando está carregando pelo facilitador de orçamento
If !IsInCallStack("At740FaMat")
	If lRecorre
		For nX := 1 to oMdlMI:Length()
			oMdlMI:GoLine(nX)
			If !Empty(oMdlMI:GetValue("TFG_PRODUT")) .AND. !Empty(oMdlMI:GetValue("TFG_PERFIM")) .AND. oMdlMI:GetValue('TFG_PERFIM') > IIF(lOrcPrc,oMdlFull:GetValue("TFL_LOC","TFL_DTFIM"), oMdlFull:GetValue("TFF_RH","TFF_PERFIM"))
				Help( ,, 'PosLinTFG',, STR0288, 1, 0,,,,,,{STR0293} ) //"Data de vigência final não está dentro da data do Local de atendimento." "Verifique as datas dos itens de Materiais de Implantação e Materiais de Consumo."                                                                                                                                                                                                                                                                                                                                                                                                                                  
				lRet := .F.
				Exit
			EndIf 
		Next nX
		If lRet 
			For nX := 1 to oMdlMC:Length()
				oMdlMC:GoLine(nX)
				If !Empty(oMdlMC:GetValue("TFH_PRODUT")) .AND. !Empty(oMdlMC:GetValue("TFH_PERFIM")) .AND. oMdlMC:GetValue('TFH_PERFIM') > IIF(lOrcPrc,oMdlFull:GetValue("TFL_LOC","TFL_DTFIM"), oMdlFull:GetValue("TFF_RH","TFF_PERFIM"))
					Help( ,, 'PosLinTFH',, STR0288, 1, 0,,,,,,{STR0293} ) //"Data de vigência final não está dentro da data do Local de atendimento." "Verifique as datas dos itens de Materiais de Implantação e Materiais de Consumo."
					lRet := .F.
					Exit
				EndIf
			Next nX	
		Endif	
	EndIf	
EndIf


FWRestRows( aSaveLines )
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldSeqABB
Verifica se existe alocão para todas sequencias da escala
@author Matheus.Goncalves
@since  28/05/2021
/*/
//-------------------------------------------------------------------
Static Function VldSeqABB(cCodTFF,nQtdven,cCodEsc, dDataRef)
Local cAliasSEQ	:= GetNextAlias()
Local nQtdEfet := 0
Local nQtdVaga := 0 
Local lRet	:= .F.

Default cCodTFF :=""
Default	nQtdven	:= 0 
Default cCodEsc :=""
Default dDataRef := dDataBase
//Quantidade de sequencias da escala
BeginSQL Alias cAliasSEQ
	SELECT COUNT(TDX.TDX_CODTDW) QTSEQUEN
	FROM %table:TDX% TDX
	WHERE TDX.TDX_FILIAL=%xFilial:TDX%
		AND TDX_CODTDW = %Exp:cCodEsc%
		AND TDX.%NotDel%
EndSql

If !(cAliasSEQ)->(EOF())
	nQtdVaga := nQtdven*(cAliasSEQ)->(QTSEQUEN)
Endif
(cAliasSEQ)->(DbCloseArea())
cAliasSEQ := GetNextAlias()

//Quantidade de alocação no posto
BeginSQL Alias cAliasSEQ
	SELECT COUNT(TGY.TGY_CODTFF) QTATEND
	FROM %table:TGY% TGY
	WHERE TGY.TGY_FILIAL=%xFilial:TGY%
		AND TGY.TGY_CODTFF = %Exp:cCodTFF%
		AND TGY.TGY_ULTALO <> ''
		AND TGY.%NotDel%
        AND TGY.TGY_ULTALO >= %Exp:DTOS(dDataRef)%
EndSql
 
If !(cAliasSEQ)->(EOF())
	nQtdEfet := (cAliasSEQ)->(QTATEND)
Endif
(cAliasSEQ)->(DbCloseArea())

nQtdVaga := nQtdVaga-nQtdEfet

If nQtdVaga < 0
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740VLDTP
@description Valid do Campo TFJ_DTPLRV, para selecionar uma data maior que a data base
@author	augusto.albuquerque
@since	25/06/2021
/*/
//-------------------------------------------------------------------------------------------------------------------
Function At740VLDTP()
Local oModel  	:= FwModelActive()
Local oMdlTFJ	:= oModel:GetModel('TFJ_REFER')
Local dDataTFJ	:= oMdlTFJ:GetValue("TFJ_DTPLRV")
Local lRet		:= .T.

If dDataBase >= dDataTFJ
	lRet := .F.
	Help( ,, 'At740VLDTP',, STR0295, 1, 0,,,,,,{STR0296} ) //"Data não permitida." ## "Por favor Selecione uma data maior que a data base do sistema."
EndIf

Return lRet

//-------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidPlane
@description Verifica se a linha pertence ao contrato original para ser deletado nas Tabelas TFL/TFF/TFG/TFH
@author	augusto.albuquerque
@since	25/06/2021
/*/
//-------------------------------------------------------------------------------------------------------------------
Static Function ValidPlane( cCodAnt, cTabela )
Local cAliasVLD	:= GetNextAlias()
Local cQuery	:= ""
Local cEspcBr 	:= Space(TamSx3(cTabela+"_CODREL")[1])
Local lRet		:= .T.

Default cCodAnt := ""
Default cTabela	:= ""

If !Empty(cCodAnt) .AND. !Empty(cTabela)
	cQuery := ""
	cQuery += " SELECT 1 FROM " + RetSQLName(cTabela) + " " + cTabela 
	cQuery += " WHERE "
	If cTabela == "TFL"
		cQuery += cTabela + "_CODIGO = '" + cCodAnt + "' AND " 
	Else
		cQuery += cTabela + "_COD = '" + cCodAnt + "' AND " 
	EndIf
	cQuery += cTabela + "_FILIAL = '" + xFilial(cTabela) + "' AND "
	cQuery += cTabela + ".D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasVLD,.T.,.T.)
	
	lRet := (cAliasVLD)->(!Eof())

	(cAliasVLD)->(dbCloseArea())
Else
	lRet := .F.
EndIf

Return lRet

//------------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldHeContr
@description Verifica se a linha pertence ao contrato original para ser deletado
@author	augusto.albuquerque
@since	25/06/2021
/*/
//------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function VldHeContr( cCodTFU, cCodTFF )
Local cAliasTFU	:= GetNextAlias()
Local cQuery	:= ""
Local cEspcBr 	:= Space(TamSx3("TFU_CODREL")[1])
Local lRet		:= .T.
Local nX

Default cCodTFU := ""
Default cCodTFF	:= ""

If !Empty(cCodTFU) .AND. !Empty(cCodTFF)
	cQuery := "" 
	cQuery += " SELECT 1 "
	cQuery += " FROM " + RetSQLName("TFU") + " TFU "
	cQuery += " INNER JOIN " + RetSQLName("TFF") + " TFF "
	cQuery += " ON TFF.TFF_COD = TFU.TFU_CODTFF " 
	cQuery += " AND TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
	cQuery += " AND TFF.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE "
	cQuery += " TFU.TFU_FILIAL = '" + xFilial("TFU") + "' "
	cQuery += " AND TFU.TFU_CODTFF = '" + cCodTFF + "' "
	cQuery += " AND TFU.TFU_CODIGO = '" + cCodTFU + "' "
	cQuery += " AND TFU.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTFU,.T.,.T.)
	
	lRet := (cAliasTFU)->(!Eof())

	(cAliasTFU)->(dbCloseArea())
Else
	lRet := .F.
EndIf

Return lRet

//------------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldLineRvP
@description Verifica se os campos voltaram para seu valor original do contrato nas tabelas TFL/TFF/TFG/TFH
@author	augusto.albuquerque
@since	25/06/2021
/*/
//------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function VldLineRvP( cCampo, xValor, cCodAnt, cTabela, lData)
Local aItem		:= {}
Local cAliasVLD	:= GetNextAlias()
Local cQuery	:= ""
Local lRet		:= .T.
Local nX

Default lData := .F.

cQuery := ""
cQuery += " SELECT  "
For nX := 1 To Len(aRevPlaIten)
	If aRevPlaIten[nX][1] == cTabela
		AADD( aItem, {aRevPlaIten[nX][2], aRevPlaIten[nX][3]})
		cQuery += aRevPlaIten[nX][2] + ","
	EndIf
Next nX
If (nPos := Ascan(aRevPlaIten, {|x| x[2] == cCampo})) > 0
	aRevPlaIten[nPos][3] := IIF(lData, DtoS(xValor), xValor)
	If (nPos := Ascan(aItem, {|x| x[1] == aRevPlaIten[nPos][2]})) > 0
		aItem[nPos][2] := IIF(lData, DtoS(xValor), xValor)//AADD( aItem, {cCampo, xValor})
	EndIf
Else
	AADD( aItem, {cCampo, IIF(lData, DtoS(xValor), xValor)})
	AADD( aRevPlaIten, {cTabela, cCampo, IIF(lData, DtoS(xValor), xValor)})
EndIf
cQuery += cCampo
cQuery += " FROM " + RetSQLName(cTabela) + " " + cTabela 
cQuery += " WHERE "
If cTabela == "TFL"
	cQuery += cTabela + "_CODIGO = '" + cCodAnt + "' AND " 
Else
	cQuery += cTabela + "_COD = '" + cCodAnt + "' AND " 
EndIf
cQuery += cTabela + "_FILIAL = '" + xFilial(cTabela) + "' AND "
cQuery += cTabela + ".D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasVLD,.T.,.T.)

If (cAliasVLD)->(!Eof())
	For nX := 1 To Len(aItem)
		If (cAliasVLD)->(&(aItem[nX][1])) <> aItem[nX][2]//(cAliasVLD)->aItem[nX][1] == aItem[nX][2]
			lRet := .F.
			Exit
		EndIf
	Next nX
EndIf

(cAliasVLD)->(dbCloseArea())

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} VldTFULinR
@description Verifica se os campos voltaram para seu valor original do contrato
@author	augusto.albuquerque
@since	25/06/2021
/*/
//------------------------------------------------------------------------------
Static Function VldTFULinR( cCampo, xValor, cCodTFU, cCodTFF, lData )
Local aItem		:= {}
Local cAliasTFU	:= GetNextAlias()
Local cQuery	:= ""
Local lRet		:= .T.
Local nX

Default lData := .F.

If (nPos := Ascan(aRevPlaIten, {|x| x[2] == cCampo})) > 0
	aRevPlaIten[nPos][3] := IIF(lData, DtoS(xValor), xValor)
Else
	AADD( aRevPlaIten, {"TFU", cCampo, IIF(lData, DtoS(xValor), xValor)})
EndIf

cQuery := ""
cQuery += " SELECT  "
For nX := 1 To Len(aRevPlaIten)
	If aRevPlaIten[nX][1] == "TFU"
		AADD( aItem, {aRevPlaIten[nX][2], aRevPlaIten[nX][3]})
		cQuery += aRevPlaIten[nX][2] + ","
	EndIf
Next nX
cQuery += cCampo
cQuery += " FROM " + RetSQLName("TFU") + " TFU "
cQuery += " INNER JOIN " + RetSQLName("TFF") + " TFF "
cQuery += " ON TFF.TFF_COD = TFU.TFU_CODTFF " 
cQuery += " AND TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
cQuery += " AND TFF.D_E_L_E_T_ = ' ' "
cQuery += " WHERE "
cQuery += " TFU.TFU_FILIAL = '" + xFilial("TFU") + "' "
cQuery += " AND TFU.TFU_CODTFF = '" + cCodTFF + "' "
cQuery += " AND TFU.TFU_CODIGO = '" + cCodTFU + "' "
cQuery += " AND TFU.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTFU,.T.,.T.)

If (cAliasTFU)->(!Eof())
	For nX := 1 To Len(aRevPlaIten)
		If aRevPlaIten[nX][1] == "TFU"
			If (cAliasTFU)->(&(aRevPlaIten[nX][2])) <> aRevPlaIten[nX][3]//(cAliasTFU)->aItem[nX][1] == aItem[nX][2]
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nX
EndIf

(cAliasTFU)->(dbCloseArea())

Return lRet

//------------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ATTOrcPla
@description Atualiza os campos de contrato e revisão antes do commit
@author	augusto.albuquerque
@since	25/06/2021
/*/
//------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function ATTOrcPla(oModel, cContrato, cRev)
Local nX
Local nZ
Local nY

oMdlTFL := oModel:GetModel("TFL_LOC")
oMdlTFF := oModel:GetModel("TFF_RH")
oMdlTFG := oModel:GetModel("TFG_MI")
oMdlTFH := oModel:GetModel("TFH_MC")
oModel:LoadValue("TFJ_REFER","TFJ_CONTRT",cContrato)

For nX := 1 To oMdlTFL:Length()
	oMdlTFL:Goline(nX)
	If !oMdlTFL:IsDeleted()
		oMdlTFL:LoadValue("TFL_CONTRT", cContrato)
		oMdlTFL:LoadValue("TFL_CONREV",cRev)
		For nY := 1 To oMdlTFF:Length()
			oMdlTFF:Goline(nY)
			If !oMdlTFF:IsDeleted() .AND. !Empty(oMdlTFF:GetValue('TFF_PRODUT'))
				oMdlTFF:LoadValue("TFF_CONTRT", cContrato)
				oMdlTFF:LoadValue("TFF_CONREV",cRev)
				For nZ := 1 To oMdlTFG:Length()
					oMdlTFG:Goline(nY)
					If !oMdlTFG:IsDeleted() .AND. !Empty(oMdlTFG:GetValue('TFG_PRODUT'))
						oMdlTFG:LoadValue("TFG_CONTRT", cContrato)
						oMdlTFG:LoadValue("TFG_CONREV",cRev)
					EndIf
				Next nZ
				For nZ := 1 To oMdlTFH:Length()
					oMdlTFH:Goline(nY)
					If !oMdlTFH:IsDeleted() .AND. !Empty(oMdlTFH:GetValue('TFH_PRODUT'))
						oMdlTFH:LoadValue("TFH_CONTRT", cContrato)
						oMdlTFH:LoadValue("TFH_CONREV",cRev)
					EndIf
				Next nZ
			EndIf
		Next nY
	EndIf
Next nX

Return .T.

//--------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidTFFs 
@description Criada para permitir que uma das validações na função ValidTFFs do fonte TECA870 faça um desvio para entrar na função VldSeqABB deste fonte.
@since 		06/08/2021
@author		Natacha Romeiro
/*/
//--------------------------------------------------------------------------------------------------------------------------------------------------------
Function At740VldQt(cCodTFF,nQtdven,cCodEsc, dDataRef)
Return  VldSeqABB(cCodTFF,nQtdven,cCodEsc, dDataRef)

//--------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740GtPer 
@description Retorna o valor do campo TFF_PERINI ou TFF_PERFIM antes da modificação

@since 		27/08/2021
@author		Luiz Gabriel
/*/
//--------------------------------------------------------------------------------------------------------------------------------------------------------
Function At740GtPer()
Return dPerCron

//--------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740GtPer 
@description Verifica se os campos de Risco, qtd de horas e Insalubridade estão preenchidos, quando o 
campo Gera Vaga estiver como Sim

@since 		22/10/2021
@author		Luiz Gabriel
/*/
//--------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function At740GerVag(oMdlTFF)
Local lRet:= .F.

If TFF->( ColumnPos("TFF_RISCO")) > 0 .And. oMdlTFF:GetValue("TFF_RISCO") == "1"
	lRet := .T.
EndIf

If TecABBPRHR() .And. (!lRet .And. !Empty(oMdlTFF:GetValue("TFF_QTDHRS")) .And. oMdlTFF:GetValue("TFF_QTDHRS") > "00:00")
	lRet := .T.
EndIf

If !lRet .And. oMdlTFF:GetValue("TFF_INSALU") <> "1"
	lRet := .T.
EndIf

If !lRet .And. oMdlTFF:GetValue("TFF_PERICU") <> "1"
	lRet := .T.
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740VldVg 
@description Verifica se há alocação em um posto que vai ser alterado de Sim para Não no campo TFF_GERVAG, validação somente executada
na revisão.

@since 		22/10/2021
@author		Luiz Gabriel
/*/
//--------------------------------------------------------------------------------------------------------------------------------------------------------
Function At740VldVg(oMdlTFF)
Local lRet			:= .T.
Local cQueryTFF		:= GetNextAlias()
Local cGeraVaga		:= oMdlTFF:GetValue("TFF_GERVAG")
Local cFilBusc		:= oMdlTFF:GetValue("TFF_FILIAL")
Local cPosto		:= oMdlTFF:GetValue("TFF_COD")
Local cDataIni		:= dToS(oMdlTFF:GetValue("TFF_PERINI"))
Local cDataFim		:= dToS(oMdlTFF:GetValue("TFF_PERFIM"))

If cGeraVaga == "2"
	BeginSql Alias cQueryTFF
						
		SELECT ABQ_CONTRT,
			ABQ_ITEM,
			ABQ_ORIGEM,
			ABQ_CODTFF,
			ABQ_FILTFF,
			ABB_CODIGO 
			FROM %Table:ABQ% ABQ
			INNER JOIN %Table:ABB% ABB ON ABQ.ABQ_CONTRT||ABQ.ABQ_ITEM||ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL AND
																		ABB.ABB_FILIAL = %xFilial:ABB% AND
																		ABB_DTINI BETWEEN %exp:cDataIni% AND %exp:cDataFim%
																		AND ABB.%NotDel%	
			WHERE 
				ABQ.ABQ_FILIAL = %xFilial:ABQ% AND	
				ABQ.ABQ_CODTFF = %exp:cPosto% AND 
				ABQ.ABQ_FILTFF = %exp:cFilBusc% AND 
				ABQ.%NotDel%	
	EndSql
				
	If (cQueryTFF)->(!EOF())
		lRet := .F.
		Help( ,, 'At740VLDVg',, STR0310, 1, 0,,,,,,{STR0311} )//"Não é permitido a mudança para um posto que não gera vaga operacional se há agenda ativa"##"Exclua todas as agendas do posto para realizar a mudança"
		
	Endif

	(cQueryTFF)->(DbCloseArea())
EndIf	

Return lRet
//--------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740VGtPd
@description Validação do gatilho TFF_PRODUT seq 003

@since 		16/11/2021
@author		Kaique Schiller
/*/
//--------------------------------------------------------------------------------------------------------------------------------------------------------
Function At740VGtPd()
Return !Empty(M->TFF_PRODUT) .And. Posicione("SB1", 1, xFilial("SB1")+M->TFF_PRODUT, "B1_PRV1") <> 0
//--------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740iniOp
@description Localiza alguma alteração na parte operacional.

@since 		11/02/2022
@author		Kaique Schiller
/*/
//--------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function At740AltOp(oMdl)
Local oMdlTFL 	 := oMdl:GetModel("TFL_LOC")
Local oMdlTFF 	 := oMdl:GetModel("TFF_RH")
Local oMdlTFH 	 := oMdl:GetModel("TFH_MC")
Local oMdlTFG 	 := oMdl:GetModel("TFG_MI")
Local lEditOp	 := .F. 
Local cQueryTFL  := GetNextAlias()
Local cQueryTFF  := ""
Local cQueryTFH  := ""
Local cQueryTFG  := ""
Local aBenRev  	 := {}
Local nX		 := 0
Local nY		 := 0
Local nZ		 := 0
Local cCodAntTFF := ""

//Percorre os locais da revisão
For nX := 1 To oMdlTFL:Length()
	oMdlTFL:Goline(nX)
	If !lEditOp
		//Query para verifcar o local do orçamento antigo
		BeginSql Alias cQueryTFL
			COLUMN TFL_DTINI AS DATE
			COLUMN TFL_DTFIM AS DATE
			SELECT TFL.TFL_DTINI,
				   TFL.TFL_DTFIM
			FROM %Table:TFL% TFL
			WHERE 
				TFL.TFL_FILIAL = %xFilial:TFL% AND
				TFL.TFL_CODSUB = %exp:oMdlTFL:GetValue("TFL_CODIGO")% AND 
				TFL.%NotDel%
		EndSql
		If (cQueryTFL)->(!EOF())
			//Alteração opercional
			If oMdlTFL:GetValue("TFL_DTINI") != (cQueryTFL)->TFL_DTINI .Or.;
				oMdlTFL:GetValue("TFL_DTFIM") != (cQueryTFL)->TFL_DTFIM
				lEditOp := .T.
				Exit
			Endif
		Else
			lEditOp := .T.
			Exit
		Endif
		(cQueryTFL)->(DbCloseArea())
		If !lEditOp
			For nY := 1 To oMdlTFF:Length()
				oMdlTFF:Goline(nY)
				If !lEditOp
					cCodAntTFF:= ""
					cQueryTFF := GetNextAlias()
					BeginSql Alias cQueryTFF					
						COLUMN TFF_PERINI AS DATE
						COLUMN TFF_PERFIM AS DATE
						SELECT TFF_COD,
							TFF_CODSUB,
							TFF_PERINI,
							TFF_PERFIM,
							TFF_QTDVEN,
							TFF_ESCALA		   
						FROM %Table:TFF% TFF
						WHERE 
							TFF.TFF_FILIAL = %xFilial:TFF% AND
							TFF.TFF_CODSUB = %exp:oMdlTFF:GetValue("TFF_COD")% AND
							TFF.%NotDel%	
					EndSql
					If (cQueryTFF)->(!EOF())
						//Alteração opercional
						If oMdlTFF:GetValue("TFF_PERINI") != (cQueryTFF)->TFF_PERINI .Or.;
							oMdlTFF:GetValue("TFF_PERFIM") != (cQueryTFF)->TFF_PERFIM .Or.;
							oMdlTFF:GetValue("TFF_QTDVEN") != (cQueryTFF)->TFF_QTDVEN .Or.;
							oMdlTFF:GetValue("TFF_ESCALA") != (cQueryTFF)->TFF_ESCALA
							lEditOp	:= .T.
							Exit
						Endif
						cCodAntTFF := (cQueryTFF)->TFF_COD
					Else
						lEditOp := .T.
						Exit
					Endif
					(cQueryTFF)->(DbCloseArea())				
					If !lEditOp
						For nZ := 1 To oMdlTFH:Length()							
							oMdlTFH:Goline(nZ)
							cQueryTFH  := GetNextAlias()
							BeginSql Alias cQueryTFH					
								COLUMN TFH_PERINI AS DATE
								COLUMN TFH_PERFIM AS DATE
								SELECT TFH_COD,
									TFH_CODSUB,
									TFH_PERINI,
									TFH_PERFIM,
									TFH_QTDVEN
								FROM %Table:TFH% TFH
								WHERE 
									TFH.TFH_FILIAL = %xFilial:TFH% AND
									TFH.TFH_CODSUB = %exp:oMdlTFH:GetValue("TFH_COD")% AND 
									TFH.%NotDel%	
							EndSql
							If (cQueryTFH)->(!EOF())
								If oMdlTFH:GetValue("TFH_PERINI") != (cQueryTFH)->TFH_PERINI .Or.;
									oMdlTFH:GetValue("TFH_PERFIM") != (cQueryTFH)->TFH_PERFIM .Or.;
									oMdlTFH:GetValue("TFH_QTDVEN") != (cQueryTFH)->TFH_QTDVEN
									lEditOp	:= .T.
									Exit
								Endif
							Else 
								If !Empty(oMdlTFH:GetValue("TFH_PRODUT"))
									lEditOp := .T.
									Exit
								Endif
							Endif					
							(cQueryTFH)->(DbCloseArea())
						Next nZ
					Endif
					If !lEditOp
						For nZ := 1 To oMdlTFG:Length()							
							oMdlTFG:GoLine(nZ)
							cQueryTFG  := GetNextAlias()
							BeginSql Alias cQueryTFG					
								COLUMN TFG_PERINI AS DATE
								COLUMN TFG_PERFIM AS DATE
								SELECT TFG_COD,
									TFG_CODSUB,
									TFG_PERINI,
									TFG_PERFIM,
									TFG_QTDVEN
								FROM %Table:TFG% TFG
								WHERE 
									TFG.TFG_FILIAL = %xFilial:TFG% AND
									TFG.TFG_CODSUB = %exp:oMdlTFG:GetValue("TFG_COD")% AND 
									TFG.%NotDel%	
							EndSql
							If (cQueryTFG)->(!EOF())
								//Alteração opercional
								If oMdlTFG:GetValue("TFG_PERINI") != (cQueryTFG)->TFG_PERINI .Or.;
									oMdlTFG:GetValue("TFG_PERFIM") != (cQueryTFG)->TFG_PERFIM .Or.;
									oMdlTFG:GetValue("TFG_QTDVEN") != (cQueryTFG)->TFG_QTDVEN
									lEditOp	:= .T.
									Exit
								Endif
							Else
								If !Empty(oMdlTFG:GetValue("TFG_PRODUT"))
									lEditOp	:= .T.
									Exit
								Endif
							Endif					
							(cQueryTFG)->(DbCloseArea())
						Next nZ						
						If !lEditOp
							aBenRev := GetABenfs()
							For nZ := 1 to Len(aBenRev)
								If aBenRev[nZ][1]
									lEditOp := .T.
									Exit
								Else
									If SubsTring(aBenRev[nZ][7][1],1,6) == cCodAntTFF
										If aBenRev[nZ][2][1] != aBenRev[nZ][2][2] .Or.;
											aBenRev[nZ][3][1] != aBenRev[nZ][3][2] .Or.;
											aBenRev[nZ][4][1] != aBenRev[nZ][4][2] .Or.;
											aBenRev[nZ][5][1] != aBenRev[nZ][5][2] .Or.;
												aBenRev[nZ][6][1] != aBenRev[nZ][6][2] .Or.;
												aBenRev[nZ][8][1] != aBenRev[nZ][8][2] .Or.;
												aBenRev[nZ][9][1] != aBenRev[nZ][9][2] .Or.;
												aBenRev[nZ][10][1] != aBenRev[nZ][10][2] .Or.;
													aBenRev[nZ][11][1] != aBenRev[nZ][11][2] .Or.;
													aBenRev[nZ][12][1] != aBenRev[nZ][12][2] .Or.;
													aBenRev[nZ][13][1] != aBenRev[nZ][13][2] .Or.;
													aBenRev[nZ][14][1] != aBenRev[nZ][14][2] .Or.;
														aBenRev[nZ][15][1] != aBenRev[nZ][15][2] .Or.;
														aBenRev[nZ][16][1] != aBenRev[nZ][16][2] .Or.;
														aBenRev[nZ][17][1] != aBenRev[nZ][17][2] .Or.;
														aBenRev[nZ][18][1] != aBenRev[nZ][18][2] .Or.;																												   
														aBenRev[nZ][19][1] != aBenRev[nZ][19][2] 
											lEditOp	:= .T.
											Exit
										Endif
									Endif
								Endif
							Next nZ
						Endif
					Endif
				Endif
			Next nY
		Endif
	Endif
Next nX

Return lEditOp

//--------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} a740AjDtEnc
@description Realiza o ajuste na data fim da TFF para itens encerrados que possuem agendas
após a data fim.

@since 		17/05/2022
@author		Luiz Gabriel
/*/
//--------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function a740AjDtEnc(oMdlLoc,oMdlRh)
Local nY		:= 0
Local nZ 		:= 0
Local dDtAgd	:= CToD('')
Local dDtLoc	:= CToD('')
Local lDTEncTFF := FindFunction("TecEncDtFt") .AND. TecEncDtFt() .AND. !GSGetIns("LE")

If lDTEncTFF
	For nZ := 1 To oMdlLoc:Length()
		oMdlLoc:GoLine(nZ)
		dDtLoc := oMdlLoc:GetValue("TFL_DTFIM")
		For nY := 1 To oMdlRh:Length()
			oMdlRh:GoLine(nY)
			If oMdlRh:GetValue('TFF_ENCE') == '1' .And. Empty(oMdlRh:GetValue("TFF_DTENCE"))
				dDtAgd := A871DtEncF( oMdlRh )
				If dDtAgd > dDtLoc
					oMdlLoc:LoadValue('TFL_DTFIM',dDtAgd)
				EndIf 
				If oMdlRh:GetValue('TFF_PERFIM') < dDtAgd 
					oMdlRh:LoadValue('TFF_DTENCE',dDtAgd)
					oMdlRh:LoadValue('TFF_PERFIM',dDtAgd)
				EndIf 
			EndIf 
		Next nY
		oMdlRh:GoLine(1)
	Next nZ 
	oMdlLoc:GoLine(1)
EndIf 

Return 

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} At740VlUni
Validação do código do produto de uniforme
@author Kaique Schiller
@since 07/06/2022
@return lRet, Logico, .T. Existe / .F. Não existe
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/ 
Function At740VlUni(cCodPrd)
Local lRet      := .T.
Local aTpUnif   := StrTokArr(SuperGetMV('MV_TPUNIF',, 'UN;'), ';') 	//-- TIPOS DE PRODUTO CORRESPONDENTE AOS UNIFORMES
Local nPosA     := 0
Local aAreaSB1	:= {}

If !Empty(cCodPrd)
	aAreaSB1  := SB1->(GetArea())
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	If !SB1->(DbSeek(xFilial('SB1')+cCodPrd))
		lRet := .F.
		Help(' ', 1, 'REGNOIS')
	Else
		nPosA := aScan(aTpUnif, {|k| k ==  SB1->B1_TIPO})
		If nPosA == 0
			lRet := .F.
			Help(,, "At894Vld",,STR0327,1,0,,,,,,{STR0328}) //"O produto informado não é um uniforme." # "Informe um produto conforme o tipo indicado no MV_TPUNIF"
		EndIf
	EndIf
	RestArea(aAreaSB1)
Endif

Return lRet

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} PosLinTXP
Validação de pos linha do grid de uniformes.
@author Kaique Schiller
@since 07/06/2022
@return lRet, Logico, .T./.F.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/ 
Function PosLinTXP(oMdl, nLine)
Local lRet := .T.

If Empty(oMdl:GetValue("TXP_CODUNI")) .Or. oMdl:GetValue("TXP_QTDVEN") == 0
	lRet := .F.
	Help(,, "PosLinTXP",,STR0329,1,0,,,,,,{STR0330}) //"O campo código do produto, quantidade ou valor não foram informados."#"Preencha esses campos."
Endif

Return lRet

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} PreLinTXP
Validação de pré linha do grid de uniformes.
@author Kaique Schiller
@since 07/06/2022
@return lRet, Logico, .T./.F.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/ 
Function PreLinTXP(oMdlG,nLine,cAction)
Local lRet      := .T.
Local oMdlFull := oMdlG:GetModel()
Local nValDel  := 0
Local nTotAtual := 0
Local oMdlUse  := Nil

If oMdlFull <> Nil
	If lRet .And. !Empty(oMdlG:GetValue("TXP_CODUNI"))
		oMdlUse	:= oMdlFull:GetModel('TFF_RH')
		nValDel	:= oMdlG:GetValue('TXP_TOTGER')
		nTotAtual := oMdlUse:GetValue('TFF_TOTUNI')
		If cAction == 'DELETE'
			nTotAtual -= nValDel
		ElseIf cAction == 'UNDELETE' 
			nTotAtual += nValDel
		Endif
		lRet := lRet .AND. oMdlUse:SetValue('TFF_TOTUNI', nTotAtual ) .Or. IsInCallStack('TEC740NFAC')
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AtLoadTXP
	Load Data da grid de Uniforme (TXP)
@author		Kaique Schiller Olivero
@since		20/06/2022
/*/
//-------------------------------------------------------------------------------
Function AtLoadTXP(oMdl)
Local aRet := {}
Local cAliasTXP := GetNextAlias()
Local nLenFlds := 0
Local aAux := {}
Local oModel := oMdl:GetModel()
Local oMdlRH := oModel:GetModel('TFF_RH')
Local cCodPai := oMdlRH:GetValue('TFF_COD')
Local oStru   := oMdl:GetStruct()
Local nI := 0
Local aFields := {}
Local aAreaX3 := SX3->(GetArea())

BeginSql Alias cAliasTXP
	SELECT TXP.R_E_C_N_O_
	FROM  %table:TXP% TXP
	WHERE TXP.TXP_FILIAL = %xFilial:TXP%
		AND TXP.TXP_CODTFF = %Exp:cCodPai%
		AND TXP.%notDel%
EndSql

If (cAliasTXP)->(!Eof())
	aFields := oStru:GetFields()
	nLenFlds := Len(aFields)
	SX3->(DbSetOrder(2))
	While (cAliasTXP)->(!Eof())
		aAux := Array(nLenFlds)
		TXP->(DbGoTo((cAliasTXP)->R_E_C_N_O_))
		For nI := 1 To nLenFlds
			cField := aFields[nI, MODEL_FIELD_IDFIELD]

			If !aFields[nI, MODEL_FIELD_VIRTUAL]
				aAux[nI] := TXP->&(cField)
			Else
				If SX3->(DbSeek(cField))
					aAux[nI] :=    CriaVar(cField, .T. )
					If cField == 'TXP_TOTAL'
						aAux[nI] := (TXP->TXP_QTDVEN * TXP->TXP_PRCVEN)
					ElseIf cField == 'TXP_DSCUNI'
						aAux[nI] := Posicione('SB1',1,xFilial('SB1')+TXP->TXP_CODUNI,'B1_DESC')
					ElseIf cField == 'TXP_TOTGER'
						aAux[nI] := (TXP->TXP_QTDVEN * TXP->TXP_PRCVEN) +  TXP->TXP_TXLUCR + TXP->TXP_TXADM
					Else
						If aFields[nI, MODEL_FIELD_TIPO] $ 'C|M'
							aAux[nI] := ""
						Elseif aFields[nI, MODEL_FIELD_TIPO] == 'N'
							aAux[nI] := 0
						Elseif aFields[nI, MODEL_FIELD_TIPO] == 'L'
							aAux[nI] := .T.
						ElseIf aFields[nI, MODEL_FIELD_TIPO] == 'D'
							aAux[nI] := sTod("")
						EndIf
					EndIf
				EndIf
			EndIf
		Next nI
		
		Aadd(aRet,{(cAliasTXP)->R_E_C_N_O_,aAux})

		(cAliasTXP)->(DbSkip())
	EndDo
EndIf
(cAliasTXP)->(DbCloseArea())
RestArea(aAreaX3)
Return aRet

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} PreLinTXQ
Validação de pré linha do grid de armamento.
@author Kaique Schiller
@since 07/06/2022
@return lRet, Logico, .T./.F.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/ 
Function PreLinTXQ(oMdlG,nLine,cAction)
Local lRet      := .T.
Local oMdlFull := oMdlG:GetModel()
Local nValDel  := 0
Local nTotAtual := 0
Local oMdlUse  := Nil

If oMdlFull <> Nil
	If lRet .And. !Empty(oMdlG:GetValue("TXQ_CODPRD"))
		oMdlUse	:= oMdlFull:GetModel('TFF_RH')
		nValDel	:= oMdlG:GetValue('TXQ_TOTGER')
		nTotAtual := oMdlUse:GetValue('TFF_TOTARM')
		If cAction == 'DELETE'
			nTotAtual -= nValDel
		ElseIf cAction == 'UNDELETE' 
			nTotAtual += nValDel
		Endif
		lRet := lRet .AND. oMdlUse:SetValue('TFF_TOTARM', nTotAtual ) .Or. IsInCallStack('TEC740NFAC')
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VlArm
	Valid do campo TXQ_CODARM
@author		Kaique Schiller Olivero
@since		23/06/2022
/*/
//-------------------------------------------------------------------------------
Function At740VlArm(cTip, cCod)
Local lRet 	 := .T.
Local aArea	 := {}
Default cTip := ""
Default cCod := ""

If !Empty(cTip)
	If !Empty(cCod)
		aArea := GetArea()
		DbSelectArea('SB5')
		SB5->( DbSetOrder( 1 ) ) //B5_FILIAL+B5_COD
		If !(SB5->( DbSeek( xFilial('SB5')+cCod ) ) .And. SB5->B5_TPISERV == cTip )
			lRet := .F.
			Help(,, "At740VlArm",,STR0332,1,0,,,,,,{STR0333}) //"Esse produto não está configurado conforme o tipo escolhido."#"Preencha o campo com o produto configurado corretamente."
		EndIf
		RestArea(aArea)
	Endif
Else
	lRet := .F.
	Help(,, "At740VlArm",,STR0334,1,0,,,,,,{STR0335}) //"Não é permitido preencher o campo código de armamento com o campo item armamento em branco."#"Preencha o campo de item do armamento."
Endif

Return lRet

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} PosLinTXP
Validação de pos linha do grid de uniformes.
@author Kaique Schiller
@since 07/06/2022
@return lRet, Logico, .T./.F.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/ 
Function PosLinTXQ(oMdl, nLine)
Local lRet := .T.

If Empty(oMdl:GetValue("TXQ_CODPRD")) .Or. oMdl:GetValue("TXQ_QTDVEN") == 0
	lRet := .F.
	Help(,, "PosLinTXQ",,STR0336,1,0,,,,,,{STR0330}) //"O campo código do produto, quantidade ou valor não foram informados."#"Preencha esses campos."
Endif

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} AtLoadTXQ
	Load Data da grid de Uniforme (TXQ)
@author		Kaique Schiller Olivero
@since		20/06/2022
/*/
//-------------------------------------------------------------------------------
Function AtLoadTXQ(oMdl)
Local aRet := {}
Local cAliasTXQ := GetNextAlias()
Local nLenFlds := 0
Local aAux := {}
Local oModel := oMdl:GetModel()
Local oMdlRH := oModel:GetModel('TFF_RH')
Local cCodPai := oMdlRH:GetValue('TFF_COD')
Local oStru   := oMdl:GetStruct()
Local nI := 0
Local aFields := {}
Local aAreaX3 := SX3->(GetArea())

BeginSql Alias cAliasTXQ
	SELECT TXQ.R_E_C_N_O_
	FROM  %table:TXQ% TXQ
	WHERE TXQ.TXQ_FILIAL = %xFilial:TXQ%
		AND TXQ.TXQ_CODTFF = %Exp:cCodPai%
		AND TXQ.%notDel%
EndSql

If (cAliasTXQ)->(!Eof())
	aFields := oStru:GetFields()
	nLenFlds := Len(aFields)
	SX3->(DbSetOrder(2))
	While (cAliasTXQ)->(!Eof())
		aAux := Array(nLenFlds)
		TXQ->(DbGoTo((cAliasTXQ)->R_E_C_N_O_))
		For nI := 1 To nLenFlds
			cField := aFields[nI, MODEL_FIELD_IDFIELD]

			If !aFields[nI, MODEL_FIELD_VIRTUAL]
				aAux[nI] := TXQ->&(cField)
			Else
				If SX3->(DbSeek(cField))
					aAux[nI] :=    CriaVar(cField, .T. )
					If cField == 'TXQ_TOTAL'
						aAux[nI] := (TXQ->TXQ_QTDVEN * TXQ->TXQ_PRCVEN)
					ElseIf cField == 'TXQ_DSCPRD'
						aAux[nI] := Posicione('SB1',1,xFilial('SB1')+TXQ->TXQ_CODPRD,'B1_DESC') 
					ElseIf cField == 'TXQ_TOTGER'
						aAux[nI] := (TXQ->TXQ_QTDVEN * TXQ->TXQ_PRCVEN) +  TXQ->TXQ_TXLUCR + TXQ->TXQ_TXADM
					Else
						If aFields[nI, MODEL_FIELD_TIPO] $ 'C|M'
							aAux[nI] := ""
						Elseif aFields[nI, MODEL_FIELD_TIPO] == 'N'
							aAux[nI] := 0
						Elseif aFields[nI, MODEL_FIELD_TIPO] == 'L'
							aAux[nI] := .T.
						ElseIf aFields[nI, MODEL_FIELD_TIPO] == 'D'
							aAux[nI] := sTod("")
						EndIf
					EndIf
				EndIf
			EndIf
		Next nI
		
		Aadd(aRet,{(cAliasTXQ)->R_E_C_N_O_,aAux})

		(cAliasTXQ)->(DbSkip())
	EndDo
EndIf
(cAliasTXQ)->(DbCloseArea())
RestArea(aAreaX3)
Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FilArm
	Filtro da consulta padrão TXQ_CODARM, TXW_CODPRD
@author		Kaique Schiller Olivero
@since		20/06/2022
/*/
//-------------------------------------------------------------------------------
Function At740FilArm()
Local cFiltro := "@#"
Local cTip := ""

If IsInCallStack("TECA984A")
	cTip := FwFldGet("TXW_ITEARM")
Else
	cTip := FwFldGet("TXQ_ITEARM")
Endif

cFiltro += '(SB5->B5_FILIAL == "' + xFilial("SB5")  +'" .And. SB5->B5_TPISERV == "' + cTip+ '" )'

Return cFiltro+"@#"

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} 
    @description Retorna o numero da sequencia da escala, de acordo com o codigo da escala
    @author Natacha Romeiro
    @since 28/07/22
    @return 
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/ 
Function At740SeqEsc(cEscala)
Local cAlias 		:= GetNextAlias()
Local nSeqEsc 		:= 0

BeginSql Alias cAlias
	SELECT COUNT(*) SEQUENCIA
	FROM  %table:TDX% TDX 
	WHERE TDX.TDX_FILIAL = %xFilial:TDX%
	  AND TDX.TDX_CODTDW = %exp:cEscala%			
	  AND TDX.%NotDel%
EndSql
	
If (cAlias)->(!EOF())
	nSeqEsc := (cAlias)->SEQUENCIA
EndIf
(cAlias)->(DbCloseArea())

Return nSeqEsc	 

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} 
    @description @description Retorna o numero da sequencia do turno, de acordo com o codigo do turno.
    @author Natacha Romeiro
    @since 28/07/22
    @return 
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/ 
Function At740SeqTurn(cTurno)
Local cAlias 		:= GetNextAlias()
Local nSeqTurn 		:= 0

BeginSql Alias cAlias
	SELECT MAX(SPJ.PJ_SEMANA) SEQUENCIA
		FROM %table:SPJ% SPJ
		INNER JOIN %table:SR6% SR6 ON SR6.R6_TURNO = SPJ.PJ_TURNO
			AND SR6.R6_FILIAL = %xFilial:SR6%
			AND SR6.%NotDel%				
		WHERE SPJ.%NotDel% 			
			AND  SPJ.PJ_TURNO = %exp:cTurno%			
			AND  SPJ.PJ_FILIAL = %xFilial:SPJ%
		EndSql
		
	If (cAlias)->(!EOF())
		nSeqTurn := Val((cAlias)->SEQUENCIA)
	EndIf
	(cAlias)->(DbCloseArea())

Return nSeqTurn

//--------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Função resposavel por calcular e retornar a quantidade prevista de pessoas no posto.
@author Natacha Romeiro		
@since	27/06/22	
/*/
//--------------------------------------------------------------------------------------------------------------------------------------------------------
Function AtCalcPrev()
//Local lGerVag		:= (TFF->(ColumnPos('TFF_GERVAG')) > 0)
Local lGerVag		:= .T.
Local nQtVend 		:= FwFldGet("TFF_QTDVEN")
Local cTurno  		:= FwFldGet("TFF_TURNO")
Local cEscala 		:= FwFldGet("TFF_ESCALA")
Local nSeqEscala	:= 0
Local nRet			:= 0
         
If (TFF->(ColumnPos('TFF_GERVAG')) > 0) 
    If FwFldGet("TFF_GERVAG") == '2'
        lGerVag := .F.
    EndIf
EndIf

If lGerVag .AND. nQtVend > 0
    If !Empty(cEscala)
        nSeqEscala = At740SeqEsc(cEscala)
        nRet := nSeqEscala * nQtVend 
    ElseIf !Empty(cTurno) 
        nSeqEscala = At740SeqTurn(cTurno)
        nRet := nSeqEscala * nQtVend 
    Else
        nRet := nQtVend
    EndIF
EndIF

Return nRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At174TXR
	Função executada no gatilho do código do facilitador para captura da descrição

@sample 	At174TXR()

@since		27/07/2022
@version	P12.1.2210
/*/
//------------------------------------------------------------------------------
Function At174TXR() 
Local cRet 		:= ' '
Local oMdl 		:= FwModelActive()
Local oMdlTWO 	:= oMdl:GetModel("TWODETAIL")
Local aArea		:= GetArea()

DbSelectArea('TXR')
TXR->( DbSetOrder( 1 ) )

If TXR->( DbSeek( xFilial("TXR") +Alltrim(oMdlTWO:GetValue("TWO_CODFAC"))) )
	cRet := TXR->TXR_DESC
EndIf

RestArea(aArea)

Return cRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740WhCb
	Edição do campo TFF_QTDTIP, TFF_VLRCOB
@author Kaique Schiller
@sample 	At740WhCb()
@since		20/09/2022
/*/
//------------------------------------------------------------------------------
Function At740WhCb(cCampo)
Local lRet := .T.
Default cCampo := ""

If cCampo == "TFF_QTDTIP"
	If Val(FwFldGet("TFF_TPCOBR")) <= Val("02")
		lRet := .F.
	Endif
Elseif cCampo == "TFF_VLRCOB"
	If Val(FwFldGet("TFF_TPCOBR")) < Val("02")
		lRet := .F.
	Endif
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ClPrp
	Gatilho do campo do calculo do valor proposto e do calculo de valor cobrado 
@author Kaique Schiller
@sample 	At740ClPrp()
@since		20/09/2022
/*/
//------------------------------------------------------------------------------
Function At740ClPrp(cTipo,nTotal,nQtd,nVlrPrp,cCampo,cEscala,cTurno,nPrcVen)
Local nRet := 0
Local nQtdHrs := 0
Default nTotal := 0
Default nQtd := 0
Default nVlrPrp := 0
Default cEscala := ""
Default cTurno := ""
Default nPrcVen	:= 0

If cTipo == "01" //Contrato
	If cCampo == "TFF_VLRCOB"
		nRet := nTotal	
		If (TFF->(ColumnPos('TFF_GERPLA')) > 0) .And. FwFldGet("TFF_GERPLA") > 0
			nRet := FwFldGet("TFF_GERPLA")
		Endif
	Endif
Elseif cTipo == "02" //Valor
	If cCampo == "TFF_VLRPRP" .Or. cCampo == "TFF_VLRCOB"
		nQtdHrs := At740HrDia(cEscala,cTurno)
		If nQtdHrs > 0
			nRet := (nPrcVen/221)/nQtdHrs
		Endif
	Endif
Else //Outros tipos
	If (cCampo == "TFF_VLRPRP" .Or. cCampo == "TFF_VLRCOB") .And. nQtd > 0
		If (TFF->(ColumnPos('TFF_GERPLA')) > 0) .And. FwFldGet("TFF_GERPLA") > 0
			nTotal := FwFldGet("TFF_GERPLA")
		Endif
		nRet := nTotal/nQtd
	Endif
Endif

Return nRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740HrDia
	Quantidade de horas do dia da escala ou turno
@author Kaique Schiller
@sample 	At740HrDia()
@since		28/09/2022
/*/
//------------------------------------------------------------------------------
Static Function At740HrDia(cEscala,cTurno)
Local cAliasQuery := ""
Local nHrIni	:= 0
Local nHrFim 	:= 0
Local dDataFim	:= sTod("")
Local cDiaSem	:= ""
Local nHrTotDia := 0
Default cEscala := ""
Default cTurno := ""

If !Empty(cEscala)
	cAliasQuery := GetNextAlias()
	BeginSql Alias cAliasQuery
		SELECT 	TGW.TGW_DIASEM,
				TGW.TGW_HORINI,
				TGW.TGW_HORFIM
		FROM %table:TDX% TDX 
		INNER JOIN %table:TGW% TGW ON TGW.TGW_FILIAL = %xFilial:TGW% 
			AND TGW.TGW_EFETDX = TDX.TDX_COD
			AND TGW.TGW_STATUS = '1'
			AND TGW.%NotDel%
		WHERE TDX.TDX_FILIAL = %xFilial:TDX%
		AND TDX.TDX_CODTDW = %exp:cEscala%
		AND TDX.%NotDel%
		ORDER BY TGW.TGW_EFETDX, TGW.TGW_DIASEM
	EndSql
	While (cAliasQuery)->(!EOF())
		If Empty(cDiaSem)
			cDiaSem := (cAliasQuery)->TGW_DIASEM
		Endif

		If cDiaSem <> (cAliasQuery)->TGW_DIASEM
			Exit
		Else
			If dDataFim == sTod("")
				nHrIni := (cAliasQuery)->TGW_HORINI
			Endif
			nHrFim :=  (cAliasQuery)->TGW_HORFIM
			If nHrIni >= nHrFim
				dDataFim := dDataBase+1
			Else
				dDataFim := dDataBase
			Endif
		Endif
		(cAliasQuery)->(dbSkip())
	EndDo
	If dDataFim <> sTod("")
		nHrTotDia := SubtHoras(dDataBase,TecConvhr(nHrIni),dDataFim,TecConvhr(nHrFim))
	Endif
	(cAliasQuery)->(DbCloseArea())
Elseif !Empty(cTurno)
	cAliasQuery := GetNextAlias()
	BeginSql Alias cAliasQuery
		SELECT 	SPJ.PJ_HRTOTAL
		FROM  %table:SPJ% SPJ
		WHERE SPJ.PJ_FILIAL = %xFilial:SPJ%
			AND SPJ.PJ_TURNO = %exp:cTurno%
			AND SPJ.PJ_TPDIA = 'S'
			AND SPJ.%NotDel%
	EndSql
	If (cAliasQuery)->(!EOF())
		nHrTotDia := (cAliasQuery)->PJ_HRTOTAL
	Endif
	(cAliasQuery)->(DbCloseArea())
Endif

Return nHrTotDia
