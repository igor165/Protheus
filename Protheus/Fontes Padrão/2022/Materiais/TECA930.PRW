#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA930.CH"

#DEFINE _TFLFILIAL	1
#DEFINE _TFLCODIGO 	2
#DEFINE _TFLLOCAL 	3
#DEFINE _TFLDESC	 	4
#DEFINE _TFLUSO	 	5
#DEFINE _TFLDISP		6
#DEFINE _TFLMOB	 	7
#DEFINE _TFLTOTAL		8
#DEFINE _TFLDTINI		9
#DEFINE _TFLDTFIM		10
#DEFINE _TFLCODPAI	11
#DEFINE _TFLPREV	 	11
#DEFINE _TFLPLAN	 	12

#DEFINE _TFIFILIAL 	1
#DEFINE _TFICODIGO 	2
#DEFINE _TFIPRODUT 	3
#DEFINE _TFICODPAI 	4
#DEFINE _TFIUSO 		5
#DEFINE _TFIDISP 		6
#DEFINE _TFIMOB 		7
#DEFINE _TFITOTAL 	8
#DEFINE _TFIPERINI 	9
#DEFINE _TFIPERFIM	10
#DEFINE _TFIDESCON	11
#DEFINE _TFIITCNB		12
#DEFINE _TFIQTDVEN	13
#DEFINE _TFIPREV 		13

#DEFINE _TEVFILIAL 	1
#DEFINE _TEVCODLOC 	2
#DEFINE _TEVITEM 		3
#DEFINE _TEVMODCOB 	4
#DEFINE _TEVTOTAL 	5
#DEFINE _TEVCODTFL 	6
#DEFINE _TEVCODTFI 	7
#DEFINE _TEVQTDE 		8
#DEFINE _TEVQTDEAPU	9
#DEFINE _TEVVLRUNI 	10
#DEFINE _TEVQTDORI 	11
#DEFINE _TEVENCTFI	12
#DEFINE _TEVPREV	 	12

#DEFINE _TW7FILIAL 	1
#DEFINE _TW7TFICOD 	2
#DEFINE _TW7TEVITE 	3
#DEFINE _TW7TPPAI 	4
#DEFINE _TW7TIPOMV 	5
#DEFINE _TW7DESCRI 	6
#DEFINE _TW7VALOR 	7
#DEFINE _TW7MODO 	8
#DEFINE _TW7FLGPED 	9
#DEFINE _TW7_MAX 	9

#DEFINE _KITSEQ		7

STATIC lMedExt
STATIC nLenSX8    := 0
STATIC lat930autG := .F.
STATIC aCloneCab  := {}
STATIC aCompProc  := {}
STATIC IsBlindRb  := .F.
STATIC cMV_PAR04  := ""
STATIC lMsgRpl 	  := .F.
Static lMedExce   := .F.
STATIC lApuraHE   := .F.
Static aHEsProc   := {}

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA930
Apuração / Medição de atendimentos do contrato
@sample 	TECA930()
@param		Nenhum
@return	ExpL	Verdadeiro / Falso
@since		01/11/2013
@author	Serviços
@version	P11.9
/*/
//------------------------------------------------------------------------------
Function TECA930()

Local oMBrowse

cMV_PAR04 := ""
lMedExce  := .F.
lApuraHE   := .F.
aHEsProc   := {}

oMBrowse:= FWmBrowse():New()
oMBrowse:SetAlias("TFV")
oMBrowse:SetDescription(STR0001)   // "Apuração / Medição de Atendimentos"

If FindFunction("TecBHasTpA") .AND. TecBHasTpA()
	oMBrowse:AddLegend("TFV->TFV_TIPO == '1'","BR_VERDE",STR0209) //"Padrão"
	oMBrowse:AddLegend("TFV->TFV_TIPO == '2'","BR_AMARELO",STR0210) //"Item Extra"
	oMBrowse:AddLegend("TFV->TFV_TIPO == '3'","BR_PINK",STR0211) //"Excedente"
	oMBrowse:AddLegend("TFV->TFV_TIPO == '4'","BR_LARANJA",STR0212) //"Hora Extra"
EndIf

oMBrowse:Activate()

If FindFunction("TecBMetrics")
	TecBMetrics()
EndIf

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Define o menu funcional.
@sample 	MenuDef()
@param		Nenhum
@return	ExpA Opções da Rotina.
@since		01/11/2013
@author	Serviços
@version	P11.9
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0076 ACTION "At930GerMed" OPERATION 3 ACCESS 0 	// "Medir/Apurar Contrato"
ADD OPTION aRotina TITLE STR0077 ACTION "At930GerMed(, , , , .F.)" OPERATION 3 ACCESS 0 	// "Medir/Apurar Fora do Contrato"
ADD OPTION aRotina TITLE STR0003 ACTION "AT930Estor" OPERATION 5 ACCESS 0 	// "Estornar"
ADD OPTION aRotina TITLE STR0195 ACTION "At930ApuAg" OPERATION 3 ACCESS 0 	// "Apuração Agil "
ADD OPTION aRotina TITLE STR0197 ACTION "At930MoApu" OPERATION 3 ACCESS 0 	// "Monitor de Apuração"
ADD OPTION aRotina TITLE STR0087 ACTION "AT930View" OPERATION 2 ACCESS 0 	// "Visualizar"
ADD OPTION aRotina TITLE STR0213 ACTION "At930GerMed(, , , , , .T.)" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE STR0216 ACTION "At930GerMed(, , , , , ,.T.)" OPERATION 3 ACCESS 0 // "Apurar HE"

Return(aRotina)
//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Model
@sample 	ModelDef()
@param		Nenhum
@return	ExpO Objeto FwFormModel
@since		01/11/2013
@author	Serviços
@version	P11.9
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStruTFV		:= FWFormStruct( 1, "TFV" )
Local oStruTFW		:= FWFormStruct( 1, "TFW" )							// TFW - Recursos Humanos
Local oStruTFX		:= FWFormStruct( 1, "TFX" )							// TFX - Material de Implantação
Local oStruTFY		:= FWFormStruct( 1, "TFY" )							// TFY - Material de Consumo
Local oStruTFL		:= FWFormStruct( 1, "TFL" )							// TFL - Locação de Equipamentos
Local oStruTFI		:= FWFormStruct( 1, "TFI", {|cCampo| AllTrim(cCampo)$ "TFI_FILIAL#TFI_PRODUT#TFI_COD#TFI_CODPAI#TFI_DESCON#TFI_ITCNB#TFI_QTDVEN#TFI_PERINI#TFI_PERFIM"} )	// TFI - Locação de Equipamentos (PRODUTOS)
Local oStruTFZ		:= FWFormStruct( 1, "TFZ" )							// TFZ - Locação de Equipamentos (DETALHES APURAÇÃO)
Local oStruZZP		:= FWFormModelStruct():New()
Local oStruTIP		:= FWFormStruct( 1, "TIP" )							// TIP - Detalhe da Apuração/Medição
Local oStruTCV		:= FWFormStruct( 1, "TCV" )							// TCV - Pedidos fora do contrato
Local oStrTFWTW6		:= FWFormStruct( 1, "TW6" )							// TFWTW6 - Recursos Humanos - DESCONTOS
Local oStrTFWTW7		:= FWFormStruct( 1, "TW7" )							// TFWTW7 - Recursos Humanos - MULTAS/BONIFICAÇÕES
Local oStrTFXTW6		:= FWFormStruct( 1, "TW6" )							// TFXTW6 - Material de Implantação - DESCONTOS
Local oStrTFXTW7		:= FWFormStruct( 1, "TW7" )							// TFXTW7 - Material de Implantação - MULTAS/BONIFICAÇÕES
Local oStrTFYTW6		:= FWFormStruct( 1, "TW6" )							// TFYTW6 - Material de Consumo - DESCONTOS
Local oStrTFYTW7		:= FWFormStruct( 1, "TW7" )							// TFYTW7 - Material de Consumo - MULTAS/BONIFICAÇÕES
Local oStrTFITW6		:= FWFormStruct( 1, "TW6" )							// TFITW6 - Locação de Equipamentos - DESCONTOS
Local oStrTFITW7		:= FWFormStruct( 1, "TW7" )							// TFITW7 - Locação de Equipamentos - MULTAS/BONIFICAÇÕES
Local oStruTW8		:= FWFormStruct( 1, "TW8" )
Local aAux				:=	{}
Local bCommit			:= {|oModel| At930Commit(oModel) }
Local lOrcPrc			:= SuperGetMv("MV_ORCPRC",,.F.)
Local bPVlMulDes		:= {|oModelGrid, nLine, cAction, cField, xValue, xOldValue| AT930AtuTot(oModelGrid, nLine, cAction, cField, xValue, xOldValue) }
Local bVLnTFITW6		:= {|| A930VLnTFITW6()}
Local oStrTWB			:= FWFormStruct(1,"TWB")
Local bPreLinTFZ		:= {|oModelGrid, nLine, cAction, cField| PreLinTFZ(oModelGrid, nLine, cAction, cField) }
Local lTFVAgrupa		:= TFV->( ColumnPos('TFV_AGRUP') ) > 0 
Local lMedLeg			:= SuperGetMv("MV_GSMDZER",,"2") == "1" //Verifica se vai habilitar a opção da Legenda de alocação na medição

nLenSX8 := GetSX8Len()

oStruZZP:AddTable("ZZP",{},STR0006)	//"Grupo de faturamento"

aAux := FwStruTrigger( "TFW_VLRMED", "TFW_VLRMED", "At930TrgRH( 'TFWDETAIL', 'TFW_VLRMED', 'ZZPDETAIL', 'ZZP_VLRTOT', 1 )", .F. )
oStruTFW:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger( "TFW_VLREXT", "TFW_VLREXT", "At930TrgRH( 'TFWDETAIL', 'TFW_VLREXT', 'ZZPDETAIL', 'ZZP_VLREXT', 1 )", .F. )
oStruTFW:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger( "TFW_TOTMUL", "TFW_TOTMUL", "At930TrgRH( 'TFWDETAIL', 'TFW_TOTMUL', 'ZZPDETAIL', 'ZZP_TOTMUL', 1 )", .F. )
oStruTFW:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger( "TFW_TOTBON", "TFW_TOTBON", "At930TrgRH( 'TFWDETAIL', 'TFW_TOTBON', 'ZZPDETAIL', 'ZZP_TOTBON', 1 )", .F. )
oStruTFW:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger( "TFW_TOTDES", "TFW_TOTDES", "At930TrgRH( 'TFWDETAIL', 'TFW_TOTDES', 'ZZPDETAIL', 'ZZP_TOTDES', 1 )", .F. )
oStruTFW:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger( "TFX_VLRMED", "TFX_VLRMED", "At930TrgGer( 'TFXDETAIL', 'TFX_VLRMED', 'ZZPDETAIL', 'ZZP_VLRTOT', 2 )", .F. )
oStruTFX:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger( "TFX_TOTMUL", "TFX_TOTMUL", "At930TrgGer( 'TFXDETAIL', 'TFX_TOTMUL', 'ZZPDETAIL', 'ZZP_TOTMUL', 2 )", .F. )
oStruTFX:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger( "TFX_TOTBON", "TFX_TOTBON", "At930TrgGer( 'TFXDETAIL', 'TFX_TOTBON', 'ZZPDETAIL', 'ZZP_TOTBON', 2 )", .F. )
oStruTFX:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger( "TFX_TOTDES", "TFX_TOTDES", "At930TrgGer( 'TFXDETAIL', 'TFX_TOTDES', 'ZZPDETAIL', 'ZZP_TOTDES', 2 )", .F. )
oStruTFX:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger( "TFY_VLRMED", "TFY_VLRMED", "At930TrgGer( 'TFYDETAIL', 'TFY_VLRMED', 'ZZPDETAIL', 'ZZP_VLRTOT', 3 )", .F. )
oStruTFY:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger( "TFY_TOTMUL", "TFY_TOTMUL", "At930TrgGer( 'TFYDETAIL', 'TFY_TOTMUL', 'ZZPDETAIL', 'ZZP_TOTMUL', 3 )", .F. )
oStruTFY:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger( "TFY_TOTBON", "TFY_TOTBON", "At930TrgGer( 'TFYDETAIL', 'TFY_TOTBON', 'ZZPDETAIL', 'ZZP_TOTBON', 3 )", .F. )
oStruTFY:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger( "TFY_TOTDES", "TFY_TOTDES", "At930TrgGer( 'TFYDETAIL', 'TFY_TOTDES', 'ZZPDETAIL', 'ZZP_TOTDES', 3 )", .F. )
oStruTFY:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger( "TFI_TOTMUL", "TFI_TOTMUL", "At930TrgGer( 'TFIPRODUT', 'TFI_TOTMUL', 'ZZPDETAIL', 'ZZP_TOTMUL', 4 )", .F. )
oStruTFI:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger( "TFI_TOTBON", "TFI_TOTBON", "At930TrgGer( 'TFIPRODUT', 'TFI_TOTBON', 'ZZPDETAIL', 'ZZP_TOTBON', 4 )", .F. )
oStruTFI:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger( "TFI_TOTDES", "TFI_TOTDES", "At930TrgGer( 'TFIPRODUT', 'TFI_TOTDES', 'ZZPDETAIL', 'ZZP_TOTDES', 4 )", .F. )
oStruTFI:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger("TFZ_QTDAPU","TFZ_QTDAPU","At930GatQdt()",.F.,Nil,Nil,Nil) //Gatilho do material de consumo, preenche produto, descrição do produto e saldo
oStruTFZ:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("TWB_CODABS","TWB_DESABS","Posicione('ABS',1,xFilial('ABS')+FwFldGet('TWB_CODABS'),'ABS_DESCRI')",.F.,Nil,Nil,Nil)
oStrTWB:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

// TWB_TOTMED - gatilhos para preencher o campo com o totalizador da linha
aAux := FwStruTrigger("TWB_IMPMED","TWB_TOTMED","At930TotRL()",.F.,Nil,Nil,Nil)
oStrTWB:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("TWB_VLRRH","TWB_TOTMED","At930TotRL()",.F.,Nil,Nil,Nil)
oStrTWB:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("TWB_VLRMI","TWB_TOTMED","At930TotRL()",.F.,Nil,Nil,Nil)
oStrTWB:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("TWB_VLRMC","TWB_TOTMED","At930TotRL()",.F.,Nil,Nil,Nil)
oStrTWB:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("TWB_VLRLE","TWB_TOTMED","At930TotRL()",.F.,Nil,Nil,Nil)
oStrTWB:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("TWB_VLRMUL","TWB_TOTMED","At930TotRL()",.F.,Nil,Nil,Nil)
oStrTWB:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("TWB_VLRBON","TWB_TOTMED","At930TotRL()",.F.,Nil,Nil,Nil)
oStrTWB:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("TWB_VLRDES","TWB_TOTMED","At930TotRL()",.F.,Nil,Nil,Nil)
oStrTWB:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

// At930TrgLoc( cMdlCalc, cCpoTot, cMdlCDom, cCpoCDOM, cCpoCodTFL )
// adiciona os gatilhos para montar o resumo dos valores por local
aAux := FwStruTrigger("TFW_VLRTOT","TFW_VLRTOT","At930TrgLoc( 'TFWDETAIL', 'TFW_VLRTOT', 'TWBDETAIL', 'TWB_VLRRH', 'TFW_CODTFL' )",.F.,Nil,Nil,Nil)
oStruTFW:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("TWB_CLIENT","TWB_LOJA","At930CliLo()",.F.,Nil,Nil,Nil)
oStrTWB:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("TFX_VLRMED","TFX_VLRMED","At930TrgLoc( 'TFXDETAIL', 'TFX_VLRMED', 'TWBDETAIL', 'TWB_VLRMI', 'TFX_CODTFL' )",.F.,Nil,Nil,Nil)
oStruTFX:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("TFY_VLRMED","TFY_VLRMED","At930TrgLoc( 'TFYDETAIL', 'TFY_VLRMED', 'TWBDETAIL', 'TWB_VLRMC', 'TFY_CODTFL' )",.F.,Nil,Nil,Nil)
oStruTFY:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("TFL_VALTOT","TFL_VALTOT","At930TrgLoc( 'TFLDETAIL', 'TFL_VALTOT', 'TWBDETAIL', 'TWB_VLRLE', 'TFL_CODIGO' )",.F.,Nil,Nil,Nil)
oStruTFL:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

//At930TrgMBD( cIdMdlOrig, nTipo, cCpoCodTFL )
// adiciona os gatilhos para somar os conteúdos de multas, bonificações e descontos
aAux := FwStruTrigger("TFW_TOTMUL","TFW_TOTMUL","At930TrgMBD( 'TFWDETAIL', 1, 'TFW_CODTFL' )",.F.,Nil,Nil,Nil)
oStruTFW:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])
aAux := FwStruTrigger("TFW_TOTBON","TFW_TOTBON","At930TrgMBD( 'TFWDETAIL', 2, 'TFW_CODTFL' )",.F.,Nil,Nil,Nil)
oStruTFW:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])
aAux := FwStruTrigger("TFW_TOTDES","TFW_TOTDES","At930TrgMBD( 'TFWDETAIL', 3, 'TFW_CODTFL' )",.F.,Nil,Nil,Nil)
oStruTFW:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("TFX_TOTMUL","TFX_TOTMUL","At930TrgMBD( 'TFXDETAIL', 1, 'TFX_CODTFL' )",.F.,Nil,Nil,Nil)
oStruTFX:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])
aAux := FwStruTrigger("TFX_TOTBON","TFX_TOTBON","At930TrgMBD( 'TFXDETAIL', 2, 'TFX_CODTFL' )",.F.,Nil,Nil,Nil)
oStruTFX:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])
aAux := FwStruTrigger("TFX_TOTDES","TFX_TOTDES","At930TrgMBD( 'TFXDETAIL', 3, 'TFX_CODTFL' )",.F.,Nil,Nil,Nil)
oStruTFX:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("TFY_TOTMUL","TFY_TOTMUL","At930TrgMBD( 'TFYDETAIL', 1, 'TFY_CODTFL' )",.F.,Nil,Nil,Nil)
oStruTFY:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])
aAux := FwStruTrigger("TFY_TOTBON","TFY_TOTBON","At930TrgMBD( 'TFYDETAIL', 2, 'TFY_CODTFL' )",.F.,Nil,Nil,Nil)
oStruTFY:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])
aAux := FwStruTrigger("TFY_TOTDES","TFY_TOTDES","At930TrgMBD( 'TFYDETAIL', 3, 'TFY_CODTFL' )",.F.,Nil,Nil,Nil)
oStruTFY:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("TFI_TOTMUL","TFI_TOTMUL","At930TrgMBD( 'TFIPRODUT', 1, 'TFI_CODPAI' )",.F.,Nil,Nil,Nil)
oStruTFI:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])
aAux := FwStruTrigger("TFI_TOTBON","TFI_TOTBON","At930TrgMBD( 'TFIPRODUT', 2, 'TFI_CODPAI' )",.F.,Nil,Nil,Nil)
oStruTFI:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])
aAux := FwStruTrigger("TFI_TOTDES","TFI_TOTDES","At930TrgMBD( 'TFIPRODUT', 3, 'TFI_CODPAI' )",.F.,Nil,Nil,Nil)
oStruTFI:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

oStrTWB:SetProperty("TWB_CODTFV", MODEL_FIELD_OBRIGAT, .F.)

//========================================
// TFW - Recursos Humanos
//========================================
If lMedLeg
	oStruTFW:AddField(	STR0219,;								// [01] C Titulo do campo # "Legenda"
						STR0219,;								// [02] C ToolTip do campo # "Legenda"
						"TFW_LEG",;								// [03] C identificador (ID) do Field
						"BT",;									// [04] C Tipo do campo
						1,;										// [05] N Tamanho do campo
						0,;										// [06] N Decimal do campo
						{|| At930Legd() },;						// [07] B Code-block de validação do campo
						Nil,;									// [08] B Code-block de validação When do campo
						Nil,;									// [09] A Lista de valores permitido do campo
						Nil,;									// [10] L Indica se o campo tem preenchimento obrigatório
						{|| At930IniEst(1,"TFW_LEG")},;			// [11] B Code-block de inicializacao do campo
						Nil,;									// [12] L Indica se trata de um campo chave
						.T.,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
						.T. )									// [14] L Indica se o campo é virtual

	oStruTFW:AddField(	STR0223,;							// [01] C Titulo do campo # "Legenda"
						STR0223,;							// [02] C ToolTip do campo # "Legenda"
						"TFW_VGDISP",;							// [03] C identificador (ID) do Field
						"N",;									// [04] C Tipo do campo
						999,;									// [05] N Tamanho do campo
						0,;										// [06] N Decimal do campo
						{|| .T. },;								// [07] B Code-block de validação do campo
						{|| .F. },;								// [08] B Code-block de validação When do campo
						Nil,;									// [09] A Lista de valores permitido do campo
						Nil,;									// [10] L Indica se o campo tem preenchimento obrigatório
						Nil,;					// [11] B Code-block de inicializacao do campo
						Nil,;									// [12] L Indica se trata de um campo chave
						.T.,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
						.T. )									// [14] L Indica se o campo é virtual

	oStruTFW:AddField(	STR0224,;							// [01] C Titulo do campo # "Legenda"
						STR0224,;							// [02] C ToolTip do campo # "Legenda"
						"TFW_VGALOC",;							// [03] C identificador (ID) do Field
						"N",;									// [04] C Tipo do campo
						999,;									// [05] N Tamanho do campo
						0,;										// [06] N Decimal do campo
						{|| .T. },;								// [07] B Code-block de validação do campo
						{|| .F. },;								// [08] B Code-block de validação When do campo
						Nil,;									// [09] A Lista de valores permitido do campo
						Nil,;									// [10] L Indica se o campo tem preenchimento obrigatório
						Nil,;								// [11] B Code-block de inicializacao do campo
						Nil,;									// [12] L Indica se trata de um campo chave
						.T.,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
						.T. )									// [14] L Indica se o campo é virtual									
EndIf
oStruTFW:AddField(	STR0004,;								// [01] C Titulo do campo # Local
					  	STR0004,;								// [02] C ToolTip do campo # Local
     					"TFW_LOCAL",;							// [03] C identificador (ID) do Field
         				"C",;									// [04] C Tipo do campo
            			TamSX3("ABS_LOCAL")[1],;										// [05] N Tamanho do campo
              		0,;										// [06] N Decimal do campo
                		Nil,;									// [07] B Code-block de validação do campo
                 		Nil,;									// [08] B Code-block de validação When do campo
                  	Nil,;									// [09] A Lista de valores permitido do campo
                   	Nil,;									// [10] L Indica se o campo tem preenchimento obrigatório
                    	{|| At930IniEst(1,"TFW_LOCAL")},;	// [11] B Code-block de inicializacao do campo
                    	Nil,;									// [12] L Indica se trata de um campo chave
                    	Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
                    	.T. )									// [14] L Indica se o campo é virtual

oStruTFW:AddField(	STR0005,;								// [01] C Titulo do campo # Descrição
					  	STR0005,;								// [02] C ToolTip do campo # Descrição
     					"TFW_DESCRI",;						// [03] C identificador (ID) do Field
         				"C",;									// [04] C Tipo do campo
            			TamSX3("ABS_DESCRI")[1],;									// [05] N Tamanho do campo
              		0,;										// [06] N Decimal do campo
                		Nil,;									// [07] B Code-block de validação do campo
                 		Nil,;									// [08] B Code-block de validação When do campo
                  	Nil,;									// [09] A Lista de valores permitido do campo
                   	Nil,;									// [10] L Indica se o campo tem preenchimento obrigatório
                    	{|| At930IniEst(1,"TFW_DESCRI")},;	// [11] B Code-block de inicializacao do campo
                    	Nil,;									// [12] L Indica se trata de um campo chave
                    	Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
                    	.T. )									// [14] L Indica se o campo é virtual

oStruTFW:AddField(	STR0063,;								// [01] C Titulo do campo # Total apurado
					  	STR0063,;								// [02] C ToolTip do campo # Total apurado
     					"TFW_TOTHOR",;						// [03] C identificador (ID) do Field
         				"N",;									// [04] C Tipo do campo
            			16,;									// [05] N Tamanho do campo
              		2,;										// [06] N Decimal do campo
                		Nil,;									// [07] B Code-block de validação do campo
                 		Nil,;									// [08] B Code-block de validação When do campo
                  	Nil,;									// [09] A Lista de valores permitido do campo
                   	Nil,;									// [10] L Indica se o campo tem preenchimento obrigatório
                    	{|| At930IniEst(1,"TFW_TOTHOR")},;	// [11] B Code-block de inicializacao do campo
                    	Nil,;									// [12] L Indica se trata de um campo chave
                    	Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
                    	.T. )									// [14] L Indica se o campo é virtual

oStruTFW:AddField(	STR0055,;								// [01] C Titulo do campo # Total
					  	STR0055,;								// [02] C ToolTip do campo # Total
     					"TFW_VLRTOT",;						// [03] C identificador (ID) do Field
         				"N",;									// [04] C Tipo do campo
            			16,;									// [05] N Tamanho do campo
              		2,;										// [06] N Decimal do campo
                		Nil,;									// [07] B Code-block de validação do campo
                 		Nil,;									// [08] B Code-block de validação When do campo
                  	Nil,;									// [09] A Lista de valores permitido do campo
                   	Nil,;									// [10] L Indica se o campo tem preenchimento obrigatório
                    	{|| At930IniEst(1,"TFW_VLRTOT")},;	// [11] B Code-block de inicializacao do campo
                    	Nil,;									// [12] L Indica se trata de um campo chave
                    	Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
                    	.T. )									// [14] L Indica se o campo é virtual

oStruTFW:AddField(	STR0038,;								// [01] C Titulo do campo # Produto
					  	STR0038,;								// [02] C ToolTip do campo # Produto
     					"TFW_PRODUT",;						// [03] C identificador (ID) do Field
         				"C",;									// [04] C Tipo do campo
            			TamSX3("B1_COD")[1],;				// [05] N Tamanho do campo
              		0,;										// [06] N Decimal do campo
                		Nil,;									// [07] B Code-block de validação do campo
                 		Nil,;									// [08] B Code-block de validação When do campo
                  	Nil,;									// [09] A Lista de valores permitido do campo
                   	Nil,;									// [10] L Indica se o campo tem preenchimento obrigatório
                    	{|| At930IniEst(1,"TFW_PRODUT")},;	// [11] B Code-block de inicializacao do campo
                    	Nil,;									// [12] L Indica se trata de um campo chave
                    	Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
                    	.T. )									// [14] L Indica se o campo é virtual

oStruTFW:AddField(	STR0064,;								// [01] C Titulo do campo # Desc. Produto
					  	STR0064,;								// [02] C ToolTip do campo # Desc. Produto
     					"TFW_DSCPRO",;						// [03] C identificador (ID) do Field
         				"C",;									// [04] C Tipo do campo
            			TamSX3("B1_DESC")[1],;				// [05] N Tamanho do campo
              		0,;										// [06] N Decimal do campo
                		Nil,;									// [07] B Code-block de validação do campo
                 		Nil,;									// [08] B Code-block de validação When do campo
                  	Nil,;									// [09] A Lista de valores permitido do campo
                   	Nil,;									// [10] L Indica se o campo tem preenchimento obrigatório
                    	{|| At930IniEst(1,"TFW_DSCPRO")},;	// [11] B Code-block de inicializacao do campo
                    	Nil,;									// [12] L Indica se trata de um campo chave
                    	Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
                    	.T. )									// [14] L Indica se o campo é virtual

oStruTFW:AddField(	STR0105,;								// [01] C Titulo do campo # "Planilha"
					  	STR0105,;								// [02] C ToolTip do campo # "Planilha"
     					"TFW_PLAN",;							// [03] C identificador (ID) do Field
         				"C",;									// [04] C Tipo do campo
            			TamSX3("CNA_NUMERO")[1],;			// [05] N Tamanho do campo
              		0,;										// [06] N Decimal do campo
                		Nil,;									// [07] B Code-block de validação do campo
                 		Nil,;									// [08] B Code-block de validação When do campo
                  	Nil,;									// [09] A Lista de valores permitido do campo
                   	Nil,;									// [10] L Indica se o campo tem preenchimento obrigatório
                    	Nil,;									// [11] B Code-block de inicializacao do campo
                    	Nil,;									// [12] L Indica se trata de um campo chave
                    	Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
                    	.T. )									// [14] L Indica se o campo é virtual

oStruTFW:SetProperty("TFW_VLRAPU", MODEL_FIELD_OBRIGAT, .F.)
oStruTFW:SetProperty("TFW_APURAC", MODEL_FIELD_OBRIGAT, .F.)
oStruTFW:SetProperty("TFW_NUMMED", MODEL_FIELD_OBRIGAT, .F.)
oStruTFW:SetProperty("TFW_ITMED",  MODEL_FIELD_OBRIGAT, .F.)
oStruTFW:SetProperty("TFW_PLAN",   MODEL_FIELD_OBRIGAT, .F.)
oStruTFW:SetProperty("TFW_VLRCON", MODEL_FIELD_OBRIGAT, .F.)

//========================================
// TFX - Material de Implantação
//========================================
If (TecAponts() .And. MV_PAR05 == 1)
	oStruTFX:AddField(		STR0219,;							    // [01] C Titulo do campo # "Legenda"
							STR0219,;								// [02] C ToolTip do campo # "Legenda"
							"TFX_LEG",;								// [03] C identificador (ID) do Field
							"BT",;									// [04] C Tipo do campo
							1,;										// [05] N Tamanho do campo
							0,;										// [06] N Decimal do campo
							{||At930GetLg()},;				        // [07] B Code-block de validação do campo
							Nil,;									// [08] B Code-block de validação When do campo
							Nil,;									// [09] A Lista de valores permitido do campo
							Nil,;									// [10] L Indica se o campo tem preenchimento obrigatório
							{|| At930IniEst(2,"TFX_LEG")},;			// [11] B Code-block de inicializacao do campo
							Nil,;									// [12] L Indica se trata de um campo chave
							.T.,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
							.T. )									// [14] L Indica se o campo é virtual
Endif							


oStruTFX:AddField(	STR0004,;							     	// [01] C Titulo do campo # Local
					  	STR0004,;								// [02] C ToolTip do campo # Local
     					"TFX_LOCAL",;							// [03] C identificador (ID) do Field
         				"C",;									// [04] C Tipo do campo
            			TamSX3("ABS_LOCAL")[1],;				// [05] N Tamanho do campo
              		0,;									    	// [06] N Decimal do campo
                		Nil,;									// [07] B Code-block de validação do campo
                 		Nil,;									// [08] B Code-block de validação When do campo
                  	Nil,;									    // [09] A Lista de valores permitido do campo
                   	Nil,;									    // [10] L Indica se o campo tem preenchimento obrigatório
                    	{|| At930IniEst(2,"TFX_LOCAL")},;	    // [11] B Code-block de inicializacao do campo
                    	Nil,;									// [12] L Indica se trata de um campo chave
                    	Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
                    	.T. )									// [14] L Indica se o campo é virtual

oStruTFX:AddField(	STR0005,;								// [01] C Titulo do campo # Descrição
					  	STR0005,;								// [02] C ToolTip do campo # Descrição
     					"TFX_DESCRI",;						// [03] C identificador (ID) do Field
         				"C",;									// [04] C Tipo do campo
            			TamSX3("ABS_DESCRI")[1],;									// [05] N Tamanho do campo
              		0,;										// [06] N Decimal do campo
                		Nil,;									// [07] B Code-block de validação do campo
                 		Nil,;									// [08] B Code-block de validação When do campo
                  	Nil,;									// [09] A Lista de valores permitido do campo
                   	Nil,;									// [10] L Indica se o campo tem preenchimento obrigatório
                    	{|| At930IniEst(2,"TFX_DESCRI")},;	// [11] B Code-block de inicializacao do campo
                    	Nil,;									// [12] L Indica se trata de um campo chave
                    	Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
                    	.T. )									// [14] L Indica se o campo é virtual

oStruTFX:AddField(	STR0038,;								// [01] C Titulo do campo # Produto
					  	STR0038,;								// [02] C ToolTip do campo # Produto
     					"TFX_PRODUT",;						// [03] C identificador (ID) do Field
         				"C",;									// [04] C Tipo do campo
            			TamSX3("B1_COD")[1],;				// [05] N Tamanho do campo
              		0,;										// [06] N Decimal do campo
                		Nil,;									// [07] B Code-block de validação do campo
                 		Nil,;									// [08] B Code-block de validação When do campo
                  	Nil,;									// [09] A Lista de valores permitido do campo
                   	Nil,;									// [10] L Indica se o campo tem preenchimento obrigatório
                    	{|| At930IniEst(2,"TFW_PRODUT")},;	// [11] B Code-block de inicializacao do campo
                    	Nil,;									// [12] L Indica se trata de um campo chave
                    	Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
                    	.T. )									// [14] L Indica se o campo é virtual

oStruTFX:AddField(	STR0064,;								// [01] C Titulo do campo # Desc. Produto
					  	STR0064,;								// [02] C ToolTip do campo # Desc. Produto
     					"TFX_DSCPRO",;						// [03] C identificador (ID) do Field
         				"C",;									// [04] C Tipo do campo
            			TamSX3("B1_DESC")[1],;				// [05] N Tamanho do campo
              		0 ,;									// [06] N Decimal do campo
                		Nil,;									// [07] B Code-block de validação do campo
                 		Nil,;									// [08] B Code-block de validação When do campo
                  	Nil,;									// [09] A Lista de valores permitido do campo
                   	Nil,;									// [10] L Indica se o campo tem preenchimento obrigatório
                    	{|| At930IniEst(2,"TFX_DSCPRO")},;	// [11] B Code-block de inicializacao do campo
                    	Nil,;									// [12] L Indica se trata de um campo chave
                    	Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
                    	.T. )									// [14] L Indica se o campo é virtual


oStruTFX:AddField(	STR0105,;								// [01] C Titulo do campo # "Planilha"
					  	STR0105,;								// [02] C ToolTip do campo # "Planilha"
     					"TFX_PLAN",;							// [03] C identificador (ID) do Field
         				"C",;									// [04] C Tipo do campo
            			TamSX3("CNA_NUMERO")[1],;			// [05] N Tamanho do campo
              		0 ,;									// [06] N Decimal do campo
                		Nil,;									// [07] B Code-block de validação do campo
                 		Nil,;									// [08] B Code-block de validação When do campo
                  	Nil,;									// [09] A Lista de valores permitido do campo
                   	Nil,;									// [10] L Indica se o campo tem preenchimento obrigatório
                    	Nil,;									// [11] B Code-block de inicializacao do campo
                    	Nil,;									// [12] L Indica se trata de um campo chave
                    	Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
                    	.T. )									// [14] L Indica se o campo é virtual

oStruTFX:SetProperty("TFX_VLRAPU",MODEL_FIELD_OBRIGAT, .F.)
oStruTFX:SetProperty("TFX_VLRMED",MODEL_FIELD_OBRIGAT, .F.)
oStruTFX:SetProperty("TFX_APURAC",MODEL_FIELD_OBRIGAT, .F.)
oStruTFX:SetProperty("TFX_NUMMED",MODEL_FIELD_OBRIGAT, .F.)
oStruTFX:SetProperty("TFX_ITMED", MODEL_FIELD_OBRIGAT, .F.)
oStruTFX:SetProperty("TFX_PLAN", MODEL_FIELD_OBRIGAT, .F.)
oStruTFX:SetProperty("TFX_VLRCON", MODEL_FIELD_OBRIGAT, .F.)
If lOrcPrc
	oStruTFX:SetProperty("TFX_CODTFF", MODEL_FIELD_OBRIGAT, .F.)
EndIf

//========================================
// TFY - Material de Consumo
//========================================
If (TecAponts() .And. MV_PAR05 == 1)
	oStruTFY:AddField(		STR0004,;								// [01] C Titulo do campo # Local
							STR0004,;								// [02] C ToolTip do campo # Local
							"TFY_LEG",;							    // [03] C identificador (ID) do Field
							"BT",;									// [04] C Tipo do campo
							1,;										// [05] N Tamanho do campo
							0,;										// [06] N Decimal do campo
							{||At930GetLg()},;									// [07] B Code-block de validação do campo
							Nil,;									// [08] B Code-block de validação When do campo
							Nil,;									// [09] A Lista de valores permitido do campo
							Nil,;									// [10] L Indica se o campo tem preenchimento obrigatório
							{|| At930IniEst(3,"TFY_LEG")},;	    // [11] B Code-block de inicializacao do campo
							Nil,;									// [12] L Indica se trata de um campo chave
							Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
							.T. )									// [14] L Indica se o campo é virtual
Endif							


oStruTFY:AddField(		STR0004,;								// [01] C Titulo do campo # Local
					  	STR0004,;								// [02] C ToolTip do campo # Local
     					"TFY_LOCAL",;							// [03] C identificador (ID) do Field
         				"C",;									// [04] C Tipo do campo
            			TamSX3("ABS_LOCAL")[1],;				// [05] N Tamanho do campo
              			0,;										// [06] N Decimal do campo
                		Nil,;									// [07] B Code-block de validação do campo
                 		Nil,;									// [08] B Code-block de validação When do campo
                  		Nil,;									// [09] A Lista de valores permitido do campo
                   		Nil,;									// [10] L Indica se o campo tem preenchimento obrigatório
                    	{|| At930IniEst(3,"TFY_LOCAL")},;	    // [11] B Code-block de inicializacao do campo
                    	Nil,;									// [12] L Indica se trata de um campo chave
                    	Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
                    	.T. )									// [14] L Indica se o campo é virtual

oStruTFY:AddField(	STR0005,;								    // [01] C Titulo do campo # Descrição
					  	STR0005,;								// [02] C ToolTip do campo # Descrição
     					"TFY_DESCRI",;					     	// [03] C identificador (ID) do Field
         				"C",;									// [04] C Tipo do campo
            			TamSX3("ABS_DESCRI")[1],;				// [05] N Tamanho do campo
              			0 ,;								    	// [06] N Decimal do campo
                		Nil,;									// [07] B Code-block de validação do campo
                 		Nil,;									// [08] B Code-block de validação When do campo
                  		Nil,;									// [09] A Lista de valores permitido do campo
                	   	Nil,;									// [10] L Indica se o campo tem preenchimento obrigatório
                    	{|| At930IniEst(3,"TFY_DESCRI")},;      // [11] B Code-block de inicializacao do campo
                    	Nil,;									// [12] L Indica se trata de um campo chave
                    	Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
                    	.T. )									// [14] L Indica se o campo é virtual

oStruTFY:AddField(	STR0038,;								// [01] C Titulo do campo # Produto
					  	STR0038,;								// [02] C ToolTip do campo # Produto
     					"TFY_PRODUT",;						// [03] C identificador (ID) do Field
         				"C",;									// [04] C Tipo do campo
            			TamSX3("B1_COD")[1],;				// [05] N Tamanho do campo
              		0,;										// [06] N Decimal do campo
                		Nil,;									// [07] B Code-block de validação do campo
                 		Nil,;									// [08] B Code-block de validação When do campo
                  	Nil,;									// [09] A Lista de valores permitido do campo
                   	Nil,;									// [10] L Indica se o campo tem preenchimento obrigatório
                    	{|| At930IniEst(3,"TFY_PRODUT")},;	// [11] B Code-block de inicializacao do campo
                    	Nil,;									// [12] L Indica se trata de um campo chave
                    	Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
                    	.T. )									// [14] L Indica se o campo é virtual

oStruTFY:AddField(	STR0064,;								// [01] C Titulo do campo # Desc. Produto
					  	STR0064,;								// [02] C ToolTip do campo # Desc. Produto
     					"TFY_DSCPRO",;						// [03] C identificador (ID) do Field
         				"C",;									// [04] C Tipo do campo
            			TamSX3("B1_DESC")[1],;				// [05] N Tamanho do campo
              		0,;										// [06] N Decimal do campo
                		Nil,;									// [07] B Code-block de validação do campo
                 		Nil,;									// [08] B Code-block de validação When do campo
                  	Nil,;									// [09] A Lista de valores permitido do campo
                   	Nil,;									// [10] L Indica se o campo tem preenchimento obrigatório
                    	{|| At930IniEst(3,"TFY_DSCPRO")},;	// [11] B Code-block de inicializacao do campo
                    	Nil,;									// [12] L Indica se trata de um campo chave
                    	Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
                    	.T. )									// [14] L Indica se o campo é virtual

oStruTFY:AddField(	STR0105,;								// [01] C Titulo do campo # "Planilha"
					  	STR0105,;								// [02] C ToolTip do campo # "Planilha"
     					"TFY_PLAN",;							// [03] C identificador (ID) do Field
         				"C",;									// [04] C Tipo do campo
            			TamSX3("CNA_NUMERO")[1],;			// [05] N Tamanho do campo
              		0,;										// [06] N Decimal do campo
                		Nil,;									// [07] B Code-block de validação do campo
                 		Nil,;									// [08] B Code-block de validação When do campo
                  	Nil,;									// [09] A Lista de valores permitido do campo
                   	Nil,;									// [10] L Indica se o campo tem preenchimento obrigatório
                    	Nil,;									// [11] B Code-block de inicializacao do campo
                    	Nil,;									// [12] L Indica se trata de um campo chave
                    	Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
                    	.T. )									// [14] L Indica se o campo é virtual

oStruTFY:SetProperty("TFY_VLRAPU", MODEL_FIELD_OBRIGAT, .F.)
oStruTFY:SetProperty("TFY_APURAC", MODEL_FIELD_OBRIGAT, .F.)
oStruTFY:SetProperty("TFY_NUMMED", MODEL_FIELD_OBRIGAT, .F.)
oStruTFY:SetProperty("TFY_ITMED",  MODEL_FIELD_OBRIGAT, .F.)
oStruTFY:SetProperty("TFY_PLAN",   MODEL_FIELD_OBRIGAT, .F.)
oStruTFY:SetProperty("TFY_VLRCON", MODEL_FIELD_OBRIGAT, .F.)
If lOrcPrc
	oStruTFY:SetProperty("TFY_CODTFF", MODEL_FIELD_OBRIGAT, .F.)
EndIf

//========================================
// TFL - Locais de Prestação do Serviço
//========================================
oStruTFL:SetProperty("*", MODEL_FIELD_VALID, {||.T.})
oStruTFL:SetProperty("*", MODEL_FIELD_OBRIGAT, .F. )

oStruTFL:AddField(	STR0055,;								// [01] C Titulo do campo # "Total"
						STR0055,;								// [02] C ToolTip do campo # "Total"
						'TFL_VALTOT',;						// [03] C identificador (ID) do Field
						'N',;									// [04] C Tipo do campo
						11,;									// [05] N Tamanho do campo
						2,;										// [06] N Decimal do campo
						/* */,;								// [07] B Code-block de validação do campo
						/*bValid*/,;							// [08] B Code-block de validação When do campo
						/*bWhen*/,;							// [09] A Lista de valores permitido do campo
						.F.,;									// [10] L Indica se o campo tem preenchimento obrigatório
						{|| At930IniEst(4,"TFL_VALTOT")},;	// [11] B Code-block de inicializacao do campo
						/*lKey*/,;								// [12] L Indica se trata de um campo chave
						/*lNoUpd*/,;							// [13] L Indica se o campo pode receber valor em uma operação de update.
						.T./*lVirtual*/,;						// [14] L Indica se o campo é virtual
						/*cValid*/ )

oStruTFL:AddField(	STR0056,;								// [01] C Titulo do campo # "Tot.Disp"
						STR0057,;								// [02] C ToolTip do campo # "Tot.Disp"
						'TFL_DISP',;							// [03] C identificador (ID) do Field
						'N',;									// [04] C Tipo do campo
						11,;									// [05] N Tamanho do campo
						2,;										// [06] N Decimal do campo
						/* */,;								// [07] B Code-block de validação do campo
						/*bValid*/,;							// [08] B Code-block de validação When do campo
						/*bWhen*/,;							// [09] A Lista de valores permitido do campo
						.F.,;									// [10] L Indica se o campo tem preenchimento obrigatório
						{|| At930IniEst(4,"TFL_DISP")},;	// [11] B Code-block de inicializacao do campo
						/*lKey*/,;								// [12] L Indica se trata de um campo chave
						/*lNoUpd*/,;							// [13] L Indica se o campo pode receber valor em uma operação de update.
						.T./*lVirtual*/,;						// [14] L Indica se o campo é virtual
						/*cValid*/ )

oStruTFL:AddField(	STR0058,;								// [01] C Titulo do campo # "Tot.Uso"
						STR0058,;								// [02] C ToolTip do campo # "Tot.Uso"
						'TFL_USO',;							// [03] C identificador (ID) do Field
						'N',;									// [04] C Tipo do campo
						11,;									// [05] N Tamanho do campo
						2,;										// [06] N Decimal do campo
						/* */,;								// [07] B Code-block de validação do campo
						/*bValid*/,;							// [08] B Code-block de validação When do campo
						/*bWhen*/,;							// [09] A Lista de valores permitido do campo
						.F.,;									// [10] L Indica se o campo tem preenchimento obrigatório
						{|| At930IniEst(4,"TFL_USO")},;		// [11] B Code-block de inicializacao do campo
						/*lKey*/,;								// [12] L Indica se trata de um campo chave
						/*lNoUpd*/,;							// [13] L Indica se o campo pode receber valor em uma operação de update.
						.T./*lVirtual*/,;						// [14] L Indica se o campo é virtual
						/*cValid*/ )

oStruTFL:AddField(	STR0059,;								// [01] C Titulo do campo # "Tot.Mobi."
						STR0060,;								// [02] C ToolTip do campo # "Tot.Mobilização"
						'TFL_MOBILI',;						// [03] C identificador (ID) do Field
						'N',;									// [04] C Tipo do campo
						11,;									// [05] N Tamanho do campo
						2,;										// [06] N Decimal do campo
						/* */,;								// [07] B Code-block de validação do campo
						/*bValid*/,;							// [08] B Code-block de validação When do campo
						/*bWhen*/,;							// [09] A Lista de valores permitido do campo
						.F.,;									// [10] L Indica se o campo tem preenchimento obrigatório
						{|| At930IniEst(4,"TFL_MOBILI")},;	// [11] B Code-block de inicializacao do campo
						/*lKey*/,;								// [12] L Indica se trata de um campo chave
						/*lNoUpd*/,;							// [13] L Indica se o campo pode receber valor em uma operação de update.
						.T./*lVirtual*/,;						// [14] L Indica se o campo é virtual
						/*cValid*/ )

oStruTFL:SetProperty("TFL_DESLOC", MODEL_FIELD_INIT, {|| If( !Inclui, Posicione("ABS",1,xFilial("ABS")+TFL->TFL_LOCAL,"ABS_DESCRI"), "")})

//========================================
// TFI - Locação de Equipamentos
//========================================
oStruTFI:SetProperty("*", MODEL_FIELD_VALID, {||.T.})
oStruTFI:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)
oStruTFI:AddField(	STR0056,;								// [01] C Titulo do campo # "Tot.Disp"
						STR0057,;								// [02] C ToolTip do campo # "Tot.Disp"
						'TFI_DISP',;							// [03] C identificador (ID) do Field
						'N',;									// [04] C Tipo do campo
						11,;									// [05] N Tamanho do campo
						2,;										// [06] N Decimal do campo
						Nil,;									// [07] B Code-block de validação do campo
						Nil,;									// [08] B Code-block de validação When do campo
						Nil,;									// [09] A Lista de valores permitido do campo
						.F.,;									// [10] L Indica se o campo tem preenchimento obrigatório
						{|| At930IniEst(4,"TFI_DISP")},;	// [11] B Code-block de inicializacao do campo
						Nil,;									// [12] L Indica se trata de um campo chave
						Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
						.T.,;									// [14] L Indica se o campo é virtual
						/*cValid*/)

oStruTFI:AddField(	STR0058,;								// [01] C Titulo do campo # "Tot.Uso"
						STR0058,;								// [02] C ToolTip do campo # "Tot.Uso"
						'TFI_USO',;							// [03] C identificador (ID) do Field
						'N',;									// [04] C Tipo do campo
						11,;									// [05] N Tamanho do campo
						2,;										// [06] N Decimal do campo
						Nil,;									// [07] B Code-block de validação do campo
						Nil,;									// [08] B Code-block de validação When do campo
						Nil,;									// [09] A Lista de valores permitido do campo
						.F.,;									// [10] L Indica se o campo tem preenchimento obrigatório
						{|| At930IniEst(4,"TFI_USO")},;		// [11] B Code-block de inicializacao do campo
						Nil,;									// [12] L Indica se trata de um campo chave
						Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
						.T.,;									// [14] L Indica se o campo é virtual
						/*cValid*/)

oStruTFI:AddField(	STR0059,;								// [01] C Titulo do campo # "Tot.Mobi."
						STR0060,;								// [02] C ToolTip do campo # "Tot.Mobilização"
						'TFI_MOBILI',;						// [03] C identificador (ID) do Field
						'N',;									// [04] C Tipo do campo
						11,;									// [05] N Tamanho do campo
						2,;										// [06] N Decimal do campo
						Nil,;									// [07] B Code-block de validação do campo
						Nil,;									// [08] B Code-block de validação When do campo
						Nil,;									// [09] A Lista de valores permitido do campo
						.F.,;									// [10] L Indica se o campo tem preenchimento obrigatório
						{|| At930IniEst(4,"TFI_MOBILI")},;	// [11] B Code-block de inicializacao do campo
						Nil,;									// [12] L Indica se trata de um campo chave
						Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
						.T.,;									// [14] L Indica se o campo é virtual
						/*cValid*/)

oStruTFI:AddField(	STR0093,;								// [01] C Titulo do campo # "Multas"
						STR0093,;								// [02] C ToolTip do campo # "Multas"
						'TFI_TOTMUL',;						// [03] C identificador (ID) do Field
						'N',;									// [04] C Tipo do campo
						16,;									// [05] N Tamanho do campo
						2,;										// [06] N Decimal do campo
						Nil,;									// [07] B Code-block de validação do campo
						Nil,;									// [08] B Code-block de validação When do campo
						Nil,;									// [09] A Lista de valores permitido do campo
						.F.,;									// [10] L Indica se o campo tem preenchimento obrigatório
						Nil,;									// [11] B Code-block de inicializacao do campo
						Nil,;									// [12] L Indica se trata de um campo chave
						Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
						.T.,;									// [14] L Indica se o campo é virtual
						/*cValid*/)

oStruTFI:AddField(	STR0094,;								// [01] C Titulo do campo # "Bonificações"
						STR0094,;								// [02] C ToolTip do campo # "Bonificações"
						'TFI_TOTBON',;						// [03] C identificador (ID) do Field
						'N',;									// [04] C Tipo do campo
						16,;									// [05] N Tamanho do campo
						2,;										// [06] N Decimal do campo
						Nil,;									// [07] B Code-block de validação do campo
						Nil,;									// [08] B Code-block de validação When do campo
						Nil,;									// [09] A Lista de valores permitido do campo
						.F.,;									// [10] L Indica se o campo tem preenchimento obrigatório
						Nil,;									// [11] B Code-block de inicializacao do campo
						Nil,;									// [12] L Indica se trata de um campo chave
						Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
						.T.,;									// [14] L Indica se o campo é virtual
						/*cValid*/)

oStruTFI:AddField(	STR0092,;								// [01] C Titulo do campo # "Descontos
						STR0092,;								// [02] C ToolTip do campo # "Descontos"
						'TFI_TOTDES',;						// [03] C identificador (ID) do Field
						'N',;									// [04] C Tipo do campo
						16,;									// [05] N Tamanho do campo
						2,;										// [06] N Decimal do campo
						Nil,;									// [07] B Code-block de validação do campo
						Nil,;									// [08] B Code-block de validação When do campo
						Nil,;									// [09] A Lista de valores permitido do campo
						.F.,;									// [10] L Indica se o campo tem preenchimento obrigatório
						Nil,;									// [11] B Code-block de inicializacao do campo
						Nil,;									// [12] L Indica se trata de um campo chave
						Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
						.T.,;									// [14] L Indica se o campo é virtual
						/*cValid*/)

//========================================
// TFZ - Locação de Equipamentos (DETALHES APURAÇÃO)
//========================================
oStruTFZ:AddField(	STR0004,;								// [01] C Titulo do campo # Local
					  	STR0004,;								// [02] C ToolTip do campo # Local
     					"TFZ_LOCAL",;							// [03] C identificador (ID) do Field
         				"C",;									// [04] C Tipo do campo
            			TamSX3("ABS_LOCAL")[1],;										// [05] N Tamanho do campo
              		0,;										// [06] N Decimal do campo
                		Nil,;									// [07] B Code-block de validação do campo
                 		Nil,;									// [08] B Code-block de validação When do campo
                  	Nil,;									// [09] A Lista de valores permitido do campo
                   	Nil,;									// [10] L Indica se o campo tem preenchimento obrigatório
                    	{|| At930IniEst(4,"TFZ_LOCAL")},;	// [11] B Code-block de inicializacao do campo
                    	Nil,;									// [12] L Indica se trata de um campo chave
                    	Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
                    	.T. )									// [14] L Indica se o campo é virtual

oStruTFZ:AddField(	STR0005,;								// [01] C Titulo do campo # Descrição
					  	STR0005,;								// [02] C ToolTip do campo # Descrição
     					"TFZ_DESCRI",;						// [03] C identificador (ID) do Field
         				"C",;									// [04] C Tipo do campo
            			TamSX3("ABS_DESCRI")[1],;									// [05] N Tamanho do campo
              		0,;										// [06] N Decimal do campo
                		Nil,;									// [07] B Code-block de validação do campo
                 		Nil,;									// [08] B Code-block de validação When do campo
                  	Nil,;									// [09] A Lista de valores permitido do campo
                   	Nil,;									// [10] L Indica se o campo tem preenchimento obrigatório
                    	{|| At930IniEst(4,"TFZ_DESCRI")},;	// [11] B Code-block de inicializacao do campo
                    	Nil,;									// [12] L Indica se trata de um campo chave
                    	Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
                    	.T. )									// [14] L Indica se o campo é virtual

oStruTFZ:AddField(	STR0061,;								// [01] C Titulo do campo # Quant.Previs
						STR0061,;								// [02] C ToolTip do campo # Quant.Previs
						'TFZ_QTDE',;							// [03] C identificador (ID) do Field
						'N',;									// [04] C Tipo do campo
						11,;									// [05] N Tamanho do campo
						2,;										// [06] N Decimal do campo
						Nil,;									// [07] B Code-block de validação do campo
						Nil,;									// [08] B Code-block de validação When do campo
						Nil,;									// [09] A Lista de valores permitido do campo
						.F.,;									// [10] L Indica se o campo tem preenchimento obrigatório
						{|| At930IniEst(4,"TFZ_QTDE")},;	// [11] B Code-block de inicializacao do campo
						Nil,;									// [12] L Indica se trata de um campo chave
						Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
						.T.,;									// [14] L Indica se o campo é virtual
						/*cValid*/)

oStruTFZ:SetProperty("TFZ_QTDAPU", MODEL_FIELD_OBRIGAT, .F.)
oStruTFZ:SetProperty("TFZ_TOTAL",  MODEL_FIELD_OBRIGAT, .F.)
oStruTFZ:SetProperty("TFZ_APURAC", MODEL_FIELD_OBRIGAT, .F.)
oStruTFZ:SetProperty("TFZ_NUMMED", MODEL_FIELD_OBRIGAT, .F.)
oStruTFZ:SetProperty("TFZ_ITMED",  MODEL_FIELD_OBRIGAT, .F.)

//========================================
// TW6 - Descontos na apuração
//========================================
oStrTFWTW6:SetProperty("TW6_CODIGO", MODEL_FIELD_OBRIGAT, .F.)
oStrTFWTW6:SetProperty("TW6_TPPAI",  MODEL_FIELD_OBRIGAT, .F.)
oStrTFWTW6:SetProperty("TW6_CODPAI", MODEL_FIELD_OBRIGAT, .F.)

oStrTFXTW6:SetProperty("TW6_CODIGO", MODEL_FIELD_OBRIGAT, .F.)
oStrTFXTW6:SetProperty("TW6_TPPAI",  MODEL_FIELD_OBRIGAT, .F.)
oStrTFXTW6:SetProperty("TW6_CODPAI", MODEL_FIELD_OBRIGAT, .F.)

oStrTFYTW6:SetProperty("TW6_CODIGO", MODEL_FIELD_OBRIGAT, .F.)
oStrTFYTW6:SetProperty("TW6_TPPAI",  MODEL_FIELD_OBRIGAT, .F.)
oStrTFYTW6:SetProperty("TW6_CODPAI", MODEL_FIELD_OBRIGAT, .F.)

oStrTFITW6:SetProperty("TW6_CODIGO", MODEL_FIELD_OBRIGAT, .F.)
oStrTFITW6:SetProperty("TW6_TPPAI",  MODEL_FIELD_OBRIGAT, .F.)
oStrTFITW6:SetProperty("TW6_CODPAI", MODEL_FIELD_OBRIGAT, .F.)

//========================================
// TW7 - Multas / Bonificações na apuração
//========================================
oStrTFWTW7:SetProperty("TW7_CODIGO", MODEL_FIELD_OBRIGAT, .F.)
oStrTFWTW7:SetProperty("TW7_TPPAI",  MODEL_FIELD_OBRIGAT, .F.)
oStrTFWTW7:SetProperty("TW7_CODPAI", MODEL_FIELD_OBRIGAT, .F.)
oStrTFWTW7:SetProperty("TW7_CODMOV", MODEL_FIELD_OBRIGAT, .F.)

oStrTFXTW7:SetProperty("TW7_CODIGO", MODEL_FIELD_OBRIGAT, .F.)
oStrTFXTW7:SetProperty("TW7_TPPAI",  MODEL_FIELD_OBRIGAT, .F.)
oStrTFXTW7:SetProperty("TW7_CODPAI", MODEL_FIELD_OBRIGAT, .F.)
oStrTFXTW7:SetProperty("TW7_CODMOV", MODEL_FIELD_OBRIGAT, .F.)

oStrTFYTW7:SetProperty("TW7_CODIGO", MODEL_FIELD_OBRIGAT, .F.)
oStrTFYTW7:SetProperty("TW7_TPPAI",  MODEL_FIELD_OBRIGAT, .F.)
oStrTFYTW7:SetProperty("TW7_CODPAI", MODEL_FIELD_OBRIGAT, .F.)
oStrTFYTW7:SetProperty("TW7_CODMOV", MODEL_FIELD_OBRIGAT, .F.)

oStrTFITW7:SetProperty("TW7_CODIGO", MODEL_FIELD_OBRIGAT, .F.)
oStrTFITW7:SetProperty("TW7_TPPAI",  MODEL_FIELD_OBRIGAT, .F.)
oStrTFITW7:SetProperty("TW7_CODPAI", MODEL_FIELD_OBRIGAT, .F.)
oStrTFITW7:SetProperty("TW7_CODMOV", MODEL_FIELD_OBRIGAT, .F.)

//========================================
// Outras configurações
//========================================
oStruTIP:SetProperty("TIP_ITAPUR", MODEL_FIELD_OBRIGAT, .F.)

oStruTCV:SetProperty("TCV_NUMAPU", MODEL_FIELD_OBRIGAT, .F.)

If lMedExt
	oStruTFV:SetProperty("TFV_HREXTR", MODEL_FIELD_OBRIGAT, .F.)
	If lTFVAgrupa
		oStruTFV:SetProperty("TFV_AGRUP", MODEL_FIELD_WHEN, {|| .F.})
	EndIf
EndIf

oStruTW8:SetProperty("TW8_OK", MODEL_FIELD_VALID, {||At930VldOs()})

oStruTW8:AddField(STR0100,;								// [01] C Titulo do campo # "Código"
					STR0101,;								// [02] C ToolTip do campo # "Código de desconto"
					'TW8_CODIGO',;						// [03] C identificador (ID) do Field
					'C',;									// [04] C Tipo do campo
					20,;									// [05] N Tamanho do campo
					Nil,;									// [06] N Decimal do campo
					Nil,;									// [07] B Code-block de validação do campo
					Nil,;									// [08] B Code-block de validação When do campo
					Nil,;									// [09] A Lista de valores permitido do campo
					.F.,;									// [10] L Indica se o campo tem preenchimento obrigatório
					Nil,;									// [11] B Code-block de inicializacao do campo
					Nil,;									// [12] L Indica se trata de um campo chave
					Nil,;									// [13] L Indica se o campo pode receber valor em uma operação de update.
					.T.,;									// [14] L Indica se o campo é virtual
					Nil)

// Realiza a criação da estrutura com os campos que receberão as informações dos grupos
LoadStruZZP( oStruZZP )

oStrTWB:AddField(STR0187,; // "Cliente"
				 STR0187,; // "Cliente"
				 'TWB_CLIENT',;
				 'C',;
				TamSX3("CXN_CLIENT")[1],;
				 0,;
				 {|oMdlTWB,cCampo,xValue|At930VlCLo(oMdlTWB,cCampo,xValue)}/*valid*/,;
				 /*when*/,;
				 NIl,; 
				 .T.,;
				 Nil,;
				 .F.,;
				 Nil,;
				 .T.)

oStrTWB:AddField(STR0188,; // "Loja"
				 STR0188,; // "Loja"
				 'TWB_LOJA',;
				 'C',;
				 TamSX3("CXN_LJCLI")[1],;
				 0,;
				 {|oMdlTWB,cCampo,xValue|At930VlCLo(oMdlTWB,cCampo,xValue)}/*valid*/,;
				 /*when*/,;
				 NIl,;
				 .T.,;
				 Nil,;
				 .F.,;
				 Nil,;
				 .T.)

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("TECA930", /* prevalid*/,{|oModel| At930TdOk(oModel) }, bCommit )

oModel:AddFields("TFVMASTER",/*cOwner*/,oStruTFV)

// Cria a lista de grupos de faturamento
oModel:AddGrid( "ZZPDETAIL", "TFVMASTER", oStruZZP,,,,,{|| At930LoadZZP()} )

// Janela Locacao de equipamentos
oModel:AddGrid("TFWDETAIL","TFVMASTER",oStruTFW)
oModel:SetRelation("TFWDETAIL",{{"TFW_FILIAL","xFilial('TFW')"},{"TFW_APURAC" ,"TFV_CODIGO" }},TFW->(IndexKey(1)))

// Detalhes da apuracao/medicao para a gravação
oModel:AddGrid("TIPDETAIL","TFVMASTER",oStruTIP)
oModel:SetRelation("TIPDETAIL",{{"TIP_FILIAL","xFilial('TIP')"},{"TIP_ITAPUR" ,"TFV_CODIGO" }},TIP->(IndexKey(5)))

// Pedidos fora do contrato
oModel:AddGrid("TCVDETAIL","TFVMASTER",oStruTCV)
oModel:SetRelation("TCVDETAIL",{{"TCV_FILIAL","xFilial('TCV')"},{"TCV_NUMAPU" ,"TFV_CODIGO" }},TCV->(IndexKey(1)))

oModel:AddGrid("TFXDETAIL","TFVMASTER",oStruTFX)
oModel:SetRelation("TFXDETAIL",{{"TFX_FILIAL","xFilial('TFX')"},{"TFX_APURAC" ,"TFV_CODIGO" }},TFX->(IndexKey(1)))

oModel:AddGrid("TFYDETAIL","TFVMASTER",oStruTFY)
oModel:SetRelation("TFYDETAIL",{{"TFY_FILIAL","xFilial('TFY')"},{"TFY_APURAC" ,"TFV_CODIGO" }},TFY->(IndexKey(1)))

oModel:AddGrid("TFLDETAIL","TFVMASTER",oStruTFL)
oModel:SetRelation("TFLDETAIL",{{"TFL_FILIAL","xFilial('TFL')"},{"TFL_CONTRT" ,"TFV_CONTRT" },{"TFL_CONREV" ,"TFV_REVISA" }},TFL->(IndexKey(4)))

oModel:AddGrid("TFIPRODUT","TFLDETAIL",oStruTFI)
oModel:SetRelation("TFIPRODUT",{{"TFI_FILIAL","xFilial('TFI')"},{"TFI_CODPAI" ,"TFL_CODIGO" }},TFI->(IndexKey(3)))

oModel:AddGrid("TFZDETAIL","TFIPRODUT",oStruTFZ, bPreLinTFZ)
oModel:SetRelation("TFZDETAIL",{{"TFZ_FILIAL","xFilial('TFZ')"},{"TFZ_APURAC" ,"TFV_CODIGO" }, {"TFZ_CODTFI" ,"TFI_COD" }},TFZ->(IndexKey(1)))

oModel:AddGrid("TFWTW6DETAIL","TFWDETAIL",oStrTFWTW6,bPVlMulDes)
oModel:SetRelation("TFWTW6DETAIL",{{"TW6_FILIAL","xFilial('TW6')"},{"TW6_TPPAI","'RH'"},{"TW6_CODPAI","TFW_CODIGO"}},TW6->(IndexKey(1)))

oModel:AddGrid("TFWTW7DETAIL","TFWDETAIL",oStrTFWTW7,bPVlMulDes)
oModel:SetRelation("TFWTW7DETAIL",{{"TW7_FILIAL","xFilial('TW7')"},{"TW7_TPPAI","'RH'"},{"TW7_CODPAI","TFW_CODIGO"}},TW7->(IndexKey(1)))

oModel:AddGrid("TFXTW6DETAIL","TFXDETAIL",oStrTFWTW6,bPVlMulDes)
oModel:SetRelation("TFXTW6DETAIL",{{"TW6_FILIAL","xFilial('TW6')"},{"TW6_TPPAI","'MI'"},{"TW6_CODPAI","TFX_CODIGO"}},TW6->(IndexKey(1)))

oModel:AddGrid("TFXTW7DETAIL","TFXDETAIL",oStrTFWTW7,bPVlMulDes)
oModel:SetRelation("TFXTW7DETAIL",{{"TW7_FILIAL","xFilial('TW7')"},{"TW7_TPPAI","'MI'"},{"TW7_CODPAI","TFX_CODIGO"}},TW7->(IndexKey(1)))

oModel:AddGrid("TFYTW6DETAIL","TFYDETAIL",oStrTFWTW6,bPVlMulDes)
oModel:SetRelation("TFYTW6DETAIL",{{"TW6_FILIAL","xFilial('TW6')"},{"TW6_TPPAI","'MC'"},{"TW6_CODPAI","TFY_CODIGO"}},TW6->(IndexKey(1)))

oModel:AddGrid("TFYTW7DETAIL","TFYDETAIL",oStrTFWTW7,bPVlMulDes)
oModel:SetRelation("TFYTW7DETAIL",{{"TW7_FILIAL","xFilial('TW7')"},{"TW7_TPPAI","'MC'"},{"TW7_CODPAI","TFY_CODIGO"}},TW7->(IndexKey(1)))

oModel:AddGrid("TFITW6DETAIL","TFIPRODUT",oStrTFWTW6,bPVlMulDes,bVLnTFITW6)
oModel:SetRelation("TFITW6DETAIL",{{"TW6_FILIAL","xFilial('TW6')"},{"TW6_TPPAI","'LE'"},{"TW6_CODPAI","TFI_COD"}},TW6->(IndexKey(1)))

oModel:AddGrid("TFITW7DETAIL","TFIPRODUT",oStrTFWTW7,bPVlMulDes)
oModel:SetRelation("TFITW7DETAIL",{{"TW7_FILIAL","xFilial('TW7')"},{"TW7_TPPAI","'LE'"},{"TW7_CODPAI","TFI_COD"}},TW7->(IndexKey(1)))

oModel:AddGrid("TW8DETAIL","TFIPRODUT",oStruTW8)
oModel:SetRelation("TW8DETAIL",{{"TW8_FILIAL","xFilial('TW8')"},{"TW8_CODTFI","TFI_COD"}},TW8->(IndexKey(1)))
oModel:GetModel("TW8DETAIL"):SetOptional(.T.)		// TW8 - Desconto por OS
oModel:GetModel('TW8DETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('TW8DETAIL'):SetNoDeleteLine(.T.)

oModel:AddGrid("TWBDETAIL","TFVMASTER", oStrTWB ) // TWB - Resumo por local
oModel:SetRelation("TWBDETAIL",{{"TWB_FILIAL","xFilial('TWB')"},{"TWB_CODTFV","TFV_CODIGO"}},TWB->(IndexKey(1)))
oModel:GetModel("TWBDETAIL"):SetOptional(.T.)
oModel:GetModel('TWBDETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('TWBDETAIL'):SetNoDeleteLine(.T.)

oModel:GetModel( "ZZPDETAIL" ):SetDescription( STR0006 ) // "Grupo de faturamento"

oModel:GetModel("TCVDETAIL"):SetOptional(.T.)
oModel:GetModel("TIPDETAIL"):SetOptional(.T.)
oModel:GetModel("TFWDETAIL"):SetOptional(.T.)		// TFW - Recursos Humanos
oModel:GetModel("TFXDETAIL"):SetOptional(.T.)		// TFX - Material de Implantação
oModel:GetModel("TFYDETAIL"):SetOptional(.T.)		// TFY - Material de Consumo
oModel:GetModel("TFLDETAIL"):SetOptional(.T.)		// TFL - Locação de Equipamentos
oModel:GetModel("TFIPRODUT"):SetOptional(.T.)		// TFI - Locação de Equipamentos (PRODUTOS)
oModel:GetModel("TFZDETAIL"):SetOptional(.T.)		// TFZ - Locação de Equipamentos (DETALHES APURAÇÃO)
oModel:GetModel("TFWTW6DETAIL"):SetOptional(.T.)	// TFWTW6 - Recursos Humanos - DESCONTOS
oModel:GetModel("TFWTW7DETAIL"):SetOptional(.T.)	// TFWTW7 - Recursos Humanos - MULTAS/BONIFICAÇÕES
oModel:GetModel("TFXTW6DETAIL"):SetOptional(.T.)	// TFXTW6 - Material de Implantação - DESCONTOS
oModel:GetModel("TFXTW7DETAIL"):SetOptional(.T.)	// TFXTW7 - Material de Implantação - MULTAS/BONIFICAÇÕES
oModel:GetModel("TFYTW6DETAIL"):SetOptional(.T.)	// TFYTW6 - Material de Consumo - DESCONTOS
oModel:GetModel("TFYTW7DETAIL"):SetOptional(.T.)	// TFYTW7 - Material de Consumo - MULTAS/BONIFICAÇÕES
oModel:GetModel("TFITW6DETAIL"):SetOptional(.T.)	// TFITW6 - Locação de Equipamentos (PRODUTOS) - DESCONTOS
oModel:GetModel("TFITW7DETAIL"):SetOptional(.T.)	// TFITW7 - Locação de Equipamentos (PRODUTOS) - MULTAS/BONIFICAÇÕES

oModel:GetModel("ZZPDETAIL"):SetOnlyQuery(.T.)
oModel:GetModel("ZZPDETAIL"):SetNoDeleteLine(.T.)

oModel:GetModel('TFLDETAIL'):SetOnlyQuery()
oModel:GetModel('TFIPRODUT'):SetOnlyQuery()

oModel:SetVldActivate( {|oModel| AT930VldCt(oModel)} )
oModel:SetActivate( {|oModel| InitDados( oModel ) } )

at930CProc()

Return(oModel)


//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definição da View

@sample 	ViewDef()

@param		Nenhum

@return	ExpO Objeto FwFormView
@author	Serviços
@since		01/11/2013
@version	P11.9
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oView			:= Nil										// Interface de visualização construída
Local oModel			:= FWLoadModel("TECA930")				// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado

Local oStruTFV		:= FWFormStruct( 2, "TFV", {|cCpo|   !(Alltrim(cCpo)$"TFV_NUMPED")})				// Cria as estruturas a serem usadas na View
Local oStruTFW		:= FWFormStruct( 2, "TFW", {|cCpo|   !(Alltrim(cCpo)$"TFW_APURAC#TFW_NUMMED#TFW_ITMED#TFW_CODTFL#TFW_CODIGO")})	// TFW - Recursos Humanos
Local oStruTFX		:= FWFormStruct( 2, "TFX", {|cCpo|   !(Alltrim(cCpo)$"TFX_APURAC#TFX_NUMMED#TFX_ITMED#TFX_CODTFL#TFX_CODIGO")})	// TFX - Material de Implantação
Local oStruTFY		:= FWFormStruct( 2, "TFY", {|cCpo|   !(Alltrim(cCpo)$"TFY_APURAC#TFY_NUMMED#TFY_ITMED#TFY_CODTFL#TFY_CODIGO")})	// TFY - Material de Consumo

Local oStruTFL		:= FWFormStruct( 2, "TFL", {|cCpo|   (Alltrim(cCpo)$"TFL_LOCAL#TFL_DESLOC")})											// TFL - Locação de Equipamentos
Local oStruTFI		:= FWFormStruct( 2, "TFI", {|cCampo| AllTrim(cCampo)$"TFI_FILIAL#TFI_PRODUT#TFI_COD#TFI_CODPAI#TFI_TOTMUL#TFI_TOTBON#TFI_TOTDES#TFI_DESCON"})					// TFI - Locação de Equipamentos (PRODUTOS)
Local oStruTFZ		:= FWFormStruct( 2, "TFZ", {|cCpo|   !(Alltrim(cCpo)$"TFZ_CODIGO#TFZ_APURAC#TFZ_NUMMED#TFZ_ITMED#TFZ_CODTFL#TFX_CODIGO#TFZ_CODTEV#TFZ_CODLOC#TFZ_CODTFI")})	// TFZ - Locação de Equipamentos (DETALHES APURAÇÃO)

Local oStrTFWTW6		:= FWFormStruct( 2, "TW6", {|cCampo| !(AllTrim(cCampo)$ "TW6_FILIAL#TW6_CODIGO#TW6_TPPAI#TW6_CODPAI#TW6_OS")})				// TFWTW6 - Recursos Humanos (DESCONTOS)
Local oStrTFWTW7		:= FWFormStruct( 2, "TW7", {|cCampo| !(AllTrim(cCampo)$ "TW7_FILIAL#TW7_CODIGO#TW7_TPPAI#TW7_CODPAI#TW7_CODMOV")})			// TFWTW7 - Recursos Humanos (MULTAS/BONIFICAÇÃO)

Local oStrTFXTW6		:= FWFormStruct( 2, "TW6", {|cCampo| !(AllTrim(cCampo)$ "TW6_FILIAL#TW6_CODIGO#TW6_TPPAI#TW6_CODPAI#TW6_OS")})				// TFXTW6 - Material de Implantação (DESCONTOS)
Local oStrTFXTW7		:= FWFormStruct( 2, "TW7", {|cCampo| !(AllTrim(cCampo)$ "TW7_FILIAL#TW7_CODIGO#TW7_TPPAI#TW7_CODPAI#TW7_CODMOV")})			// TFXTW7 - Material de Implantação (MULTAS/BONIFICAÇÃO)

Local oStrTFYTW6		:= FWFormStruct( 2, "TW6", {|cCampo| !(AllTrim(cCampo)$ "TW6_FILIAL#TW6_CODIGO#TW6_TPPAI#TW6_CODPAI#TW6_OS")})				// TFYTW6 - Material de Consumo (DESCONTOS)
Local oStrTFYTW7		:= FWFormStruct( 2, "TW7", {|cCampo| !(AllTrim(cCampo)$ "TW7_FILIAL#TW7_CODIGO#TW7_TPPAI#TW7_CODPAI#TW7_CODMOV")})			// TFYTW7 - Material de Consumo (MULTAS/BONIFICAÇÃO)

Local oStrTFITW6		:= FWFormStruct( 2, "TW6", {|cCampo| !(AllTrim(cCampo)$ "TW6_FILIAL#TW6_CODIGO#TW6_TPPAI#TW6_CODPAI#TW6_OS")})				// TFITW6 - Locação de Equipamentos (DESCONTOS)
Local oStrTFITW7		:= FWFormStruct( 2, "TW7", {|cCampo| !(AllTrim(cCampo)$ "TW7_FILIAL#TW7_CODIGO#TW7_TPPAI#TW7_CODPAI#TW7_CODMOV")})			// TFITW7 - Locação de Equipamentos (MULTAS/BONIFICAÇÃO)

Local oStruZZP			:= FWFormViewStruct():New()

Local oStruTW8			:= FWFormStruct( 2, "TW8", {|cCampo| !( AllTrim(cCampo)$ "TW8_CODTFI" )} )	// TW8 - Desconto por OS
Local oStrTWB			:= FWFormStruct(2,"TWB")
Local lGSRH 			:= GSGetIns("RH")
Local lGSMIMC  			:= GSGetIns("MI")
Local lGSLE 			:= GSGetIns("LE")
Local lOrcPrc			:= SuperGetMv("MV_ORCPRC",,.F.)
Local lMedLeg			:= SuperGetMv("MV_GSMDZER",,"2") == "1" //Verifica se vai habilitar a opção da Legenda de alocação na medição
Local lApont            := .F.



// TFV - Cabeçalho da Apuração

//========================================
// TFW - Recursos Humanos
//========================================
If lMedLeg
	oStruTFW:AddField( ;									// Ord. Tipo Desc.
							"TFW_LEG",;						// [01] C Nome do Campo
							"01",;							// [02] C Ordem
							STR0219,;				    	// [03] C Titulo do campo # "Legenda"
							STR0219,;					    // [04] C Descrição do campo # "Legenda"
							Nil,;							// [05] A Array com Help
							"BT",;							// [06] C Tipo do campo
							"",;							// [07] C Picture
							NIL,;							// [08] B Bloco de Picture Var
							"",;							// [09] C Consulta F3
							.T.,;							// [10] L Indica se o campo é editável
							NIL,;							// [11] C Pasta do campo
							NIL,;							// [12] C Agrupamento do campo
							NIL,;							// [13] A Lista de valores permitido do campo (Combo)
							NIL,;							// [14] N Tamanho Maximo da maior opção do combo
							NIL,;							// [15] C Inicializador de Browse
							.T.,;							// [16] L Indica se o campo é virtual
							NIL )							// [17] C Picture Variável

	oStruTFW:AddField( ;									// Ord. Tipo Desc.
							"TFW_VGDISP",;						// [01] C Nome do Campo
							"98",;							// [02] C Ordem
							STR0223,;					// [03] C Titulo do campo # "Legenda"
							STR0223,;					// [04] C Descrição do campo # "Legenda"
							Nil,;							// [05] A Array com Help
							"N",;							// [06] C Tipo do campo
							"999",;							// [07] C Picture
							NIL,;							// [08] B Bloco de Picture Var
							"",;							// [09] C Consulta F3
							.T.,;							// [10] L Indica se o campo é editável
							NIL,;							// [11] C Pasta do campo
							NIL,;							// [12] C Agrupamento do campo
							NIL,;							// [13] A Lista de valores permitido do campo (Combo)
							NIL,;							// [14] N Tamanho Maximo da maior opção do combo
							NIL,;							// [15] C Inicializador de Browse
							.T.,;							// [16] L Indica se o campo é virtual
							NIL )							// [17] C Picture Variável

	oStruTFW:AddField( ;									// Ord. Tipo Desc.
							"TFW_VGALOC",;						// [01] C Nome do Campo
							"99",;							// [02] C Ordem
							STR0224,;					// [03] C Titulo do campo # "Legenda"
							STR0224,;					// [04] C Descrição do campo # "Legenda"
							Nil,;							// [05] A Array com Help
							"N",;							// [06] C Tipo do campo
							"999",;							// [07] C Picture
							NIL,;							// [08] B Bloco de Picture Var
							"",;							// [09] C Consulta F3
							.T.,;							// [10] L Indica se o campo é editável
							NIL,;							// [11] C Pasta do campo
							NIL,;							// [12] C Agrupamento do campo
							NIL,;							// [13] A Lista de valores permitido do campo (Combo)
							NIL,;							// [14] N Tamanho Maximo da maior opção do combo
							NIL,;							// [15] C Inicializador de Browse
							.T.,;							// [16] L Indica se o campo é virtual
							NIL )							// [17] C Picture Variável														
EndIf
oStruTFW:AddField( ;									// Ord. Tipo Desc.
						"TFW_LOCAL",;					// [01] C Nome do Campo
						"02",;							// [02] C Ordem
						STR0004,;						// [03] C Titulo do campo # "Local"
						STR0004,;						// [04] C Descrição do campo # "Local"
						Nil,;							// [05] A Array com Help
						"C",;							// [06] C Tipo do campo
						"@!",;							// [07] C Picture
						NIL,;							// [08] B Bloco de Picture Var
						"",;							// [09] C Consulta F3
						.F.,;							// [10] L Indica se o campo é editável
						NIL,;							// [11] C Pasta do campo
						NIL,;							// [12] C Agrupamento do campo
						NIL,;							// [13] A Lista de valores permitido do campo (Combo)
						NIL,;							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;							// [15] C Inicializador de Browse
						.T.,;							// [16] L Indica se o campo é virtual
						NIL )							// [17] C Picture Variável

oStruTFW:AddField( ;									// Ord. Tipo Desc.
						"TFW_DESCRI",;				// [01] C Nome do Campo
						"03",;							// [02] C Ordem
						STR0005,;						// [03] C Titulo do campo # "Descrição"
						STR0005,;						// [04] C Descrição do campo # "Descrição"
						Nil,;							// [05] A Array com Help
						"C",;							// [06] C Tipo do campo
						"@!",;							// [07] C Picture
						NIL,;							// [08] B Bloco de Picture Var
						"" ,;							// [09] C Consulta F3
						.F.,;							// [10] L Indica se o campo é editável
						NIL,;							// [11] C Pasta do campo
						NIL,;							// [12] C Agrupamento do campo
						NIL,;							// [13] A Lista de valores permitido do campo (Combo)
						NIL,;							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;							// [15] C Inicializador de Browse
						.T.,;							// [16] L Indica se o campo é virtual
						NIL )							// [17] C Picture Variável

oStruTFW:AddField( ;									// Ord. Tipo Desc.
						"TFW_PRODUT",;				// [01] C Nome do Campo
						"05",;							// [02] C Ordem
						STR0038,;						// [03] C Titulo do campo # "Produto"
						STR0038,;						// [04] C Descrição do campo # "Produto"
						Nil,;							// [05] A Array com Help
						"C",;							// [06] C Tipo do campo
						"@!",;							// [07] C Picture
						NIL,;							// [08] B Bloco de Picture Var
						"",;							// [09] C Consulta F3
						.F.,;							// [10] L Indica se o campo é editável
						NIL,;							// [11] C Pasta do campo
						NIL,;							// [12] C Agrupamento do campo
						NIL,;							// [13] A Lista de valores permitido do campo (Combo)
						NIL,;							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;							// [15] C Inicializador de Browse
						.T.,;							// [16] L Indica se o campo é virtual
						NIL )							// [17] C Picture Variável

oStruTFW:AddField( ;									// Ord. Tipo Desc.
						"TFW_DSCPRO",;				// [01] C Nome do Campo
						"06",;							// [02] C Ordem
						STR0064,;						// [03] C Titulo do campo # "Desc. Produto"
						STR0064,;						// [04] C Descrição do campo # "Desc. Produto"
						Nil,;							// [05] A Array com Help
						"C",;							// [06] C Tipo do campo
						"@!",;							// [07] C Picture
						NIL,;							// [08] B Bloco de Picture Var
						"" ,;							// [09] C Consulta F3
						.F.,;							// [10] L Indica se o campo é editável
						NIL,;							// [11] C Pasta do campo
						NIL,;							// [12] C Agrupamento do campo
						NIL,;							// [13] A Lista de valores permitido do campo (Combo)
						NIL,;							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;							// [15] C Inicializador de Browse
						.T.,;							// [16] L Indica se o campo é virtual
						NIL )							// [17] C Picture Variável

oStruTFW:AddField( ; 								// Ord. Tipo Desc.
						"TFW_TOTHOR",;				// [01] C Nome do Campo
						"11",;							// [02] C Ordem
						STR0063,;						// [03] C Titulo do campo # "Total apurado"
						STR0063,;						// [04] C Descrição do campo # "Total apurado"
						Nil,;							// [05] A Array com Help
						"N",;							// [06] C Tipo do campo
						"@E 9,999,999,999,999.99",;	// [07] C Picture
						NIL,;							// [08] B Bloco de Picture Var
						"",;							// [09] C Consulta F3
						.F.,;							// [10] L Indica se o campo é editável
						NIL,;							// [11] C Pasta do campo
						NIL,;							// [12] C Agrupamento do campo
						NIL,;							// [13] A Lista de valores permitido do campo (Combo)
						NIL,;							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;							// [15] C Inicializador de Browse
						.T.,;							// [16] L Indica se o campo é virtual
						NIL )							// [17] C Picture Variável

oStruTFW:AddField( ; // Ord. Tipo Desc.
						"TFW_VLRTOT",;				// [01] C Nome do Campo
						"16",;							// [02] C Ordem
						STR0055,;						// [03] C Titulo do campo # "Total"
						STR0055,;						// [04] C Descrição do campo # "Total"
						Nil,;							// [05] A Array com Help
						"N",;							// [06] C Tipo do campo
						"@E 9,999,999,999,999.99",;	// [07] C Picture
						NIL,;							// [08] B Bloco de Picture Var
						"" ,;							// [09] C Consulta F3
						.F.,;							// [10] L Indica se o campo é editável
						NIL,;							// [11] C Pasta do campo
						NIL,;							// [12] C Agrupamento do campo
						NIL,;							// [13] A Lista de valores permitido do campo (Combo)
						NIL,;							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;							// [15] C Inicializador de Browse
						.T.,;							// [16] L Indica se o campo é virtual
						NIL )							// [17] C Picture Variável

oStruTFW:SetProperty("TFW_CODTFF", MVC_VIEW_ORDEM, "04")
oStruTFW:SetProperty("TFW_HORAN" , MVC_VIEW_ORDEM, "07")
oStruTFW:SetProperty("TFW_VLHORN", MVC_VIEW_ORDEM, "08")
oStruTFW:SetProperty("TFW_HORAE" , MVC_VIEW_ORDEM, "09")
If TFW->( ColumnPos("TFW_HREXTN")) > 0
	oStruTFW:SetProperty("TFW_HREXTN", MVC_VIEW_ORDEM, "09")
Endif
oStruTFW:SetProperty("TFW_VLHORE", MVC_VIEW_ORDEM, "10")
oStruTFW:SetProperty("TFW_VLRAPU", MVC_VIEW_ORDEM, "12")
oStruTFW:SetProperty("TFW_VLRCON", MVC_VIEW_ORDEM, "13")
oStruTFW:SetProperty("TFW_VLRMED", MVC_VIEW_ORDEM, "14")
oStruTFW:SetProperty("TFW_VLREXT", MVC_VIEW_ORDEM, "15")

//========================================
// TFX - Material de Implantação
//========================================

If (TecAponts() .And. MV_PAR05 == 1)
	lApont := .T.
	oStruTFX:AddField( ;									    // Ord. Tipo Desc.
								"TFX_LEG",;						// [01] C Nome do Campo
								"01",;			                // [02] C Ordem
								STR0219,;					    // [03] C Titulo do campo # "Legenda"
								STR0219,;					    // [04] C Descrição do campo # "Legenda"
								Nil,;							// [05] A Array com Help
								"BT",;							// [06] C Tipo do campo
								"",;							// [07] C Picture
								NIL,;							// [08] B Bloco de Picture Var
								"",;							// [09] C Consulta F3
								.T.,;							// [10] L Indica se o campo é editável
								NIL,;							// [11] C Pasta do campo
								NIL,;							// [12] C Agrupamento do campo
								NIL,;							// [13] A Lista de valores permitido do campo (Combo)
								NIL,;							// [14] N Tamanho Maximo da maior opção do combo
								NIL,;							// [15] C Inicializador de Browse
								.T.,;							// [16] L Indica se o campo é virtual
								NIL )							// [17] C Picture Variável
Endif								


oStruTFX:AddField( ;									// Ord. Tipo Desc.
						"TFX_LOCAL",;					// [01] C Nome do Campo
						iif(lApont,"02","01"),;							// [02] C Ordem
						STR0004,;						// [03] C Titulo do campo # "Local"
						STR0004,;						// [04] C Descrição do campo # "Local"
						Nil,;							// [05] A Array com Help
						"C",;							// [06] C Tipo do campo
						"@!",;							// [07] C Picture
						NIL,;							// [08] B Bloco de Picture Var
						"" ,;							// [09] C Consulta F3
						.F.,;							// [10] L Indica se o campo é editável
						NIL,;							// [11] C Pasta do campo
						NIL,;							// [12] C Agrupamento do campo
						NIL,;							// [13] A Lista de valores permitido do campo (Combo)
						NIL,;							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;							// [15] C Inicializador de Browse
						.T.,;							// [16] L Indica se o campo é virtual
						NIL )							// [17] C Picture Variável

oStruTFX:AddField( ;									// Ord. Tipo Desc.
						"TFX_DESCRI",;				// [01] C Nome do Campo
						iif(lApont,"03","02"),;								// [02] C Ordem
						STR0005,;						// [03] C Titulo do campo # "Descrição"
						STR0005,;						// [04] C Descrição do campo # "Descrição"
						Nil,;							// [05] A Array com Help
						"C",;							// [06] C Tipo do campo
						"@!",;							// [07] C Picture
						NIL,;							// [08] B Bloco de Picture Var
						"" ,;							// [09] C Consulta F3
						.F.,;							// [10] L Indica se o campo é editável
						NIL,;							// [11] C Pasta do campo
						NIL,;							// [12] C Agrupamento do campo
						NIL,;							// [13] A Lista de valores permitido do campo (Combo)
						NIL,;							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;							// [15] C Inicializador de Browse
						.T.,;							// [16] L Indica se o campo é virtual
						NIL )							// [17] C Picture Variável

oStruTFX:AddField( ; 								// Ord. Tipo Desc.
						"TFX_PRODUT",;				// [01] C Nome do Campo
						iif(lApont,"05","04"),;							// [02] C Ordem
						STR0038,;						// [03] C Titulo do campo # "Produto"
						STR0038,;						// [04] C Descrição do campo # "Produto"
						Nil,;							// [05] A Array com Help
						"C",;							// [06] C Tipo do campo
						"@!",;							// [07] C Picture
						NIL,;							// [08] B Bloco de Picture Var
						"" ,;							// [09] C Consulta F3
						.F.,;							// [10] L Indica se o campo é editável
						NIL,;							// [11] C Pasta do campo
						NIL,;							// [12] C Agrupamento do campo
						NIL,;							// [13] A Lista de valores permitido do campo (Combo)
						NIL,;							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;							// [15] C Inicializador de Browse
						.T.,;							// [16] L Indica se o campo é virtual
						NIL )							// [17] C Picture Variável

oStruTFX:AddField( ; 								// Ord. Tipo Desc.
						"TFX_DSCPRO",;				// [01] C Nome do Campo
						iif(lApont,"06","05"),;								// [02] C Ordem
						STR0064,;						// [03] C Titulo do campo # "Desc. Produto"
						STR0064,;						// [04] C Descrição do campo # "Desc. Produto"
						Nil,;							// [05] A Array com Help
						"C",;							// [06] C Tipo do campo
						"@!",;							// [07] C Picture
						NIL,;							// [08] B Bloco de Picture Var
						"" ,;							// [09] C Consulta F3
						.F.,;							// [10] L Indica se o campo é editável
						NIL,;							// [11] C Pasta do campo
						NIL,;							// [12] C Agrupamento do campo
						NIL,;							// [13] A Lista de valores permitido do campo (Combo)
						NIL,;							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;							// [15] C Inicializador de Browse
						.T.,;							// [16] L Indica se o campo é virtual
						NIL )							// [17] C Picture Variável

oStruTFX:SetProperty("TFX_CODTFF", MVC_VIEW_ORDEM, iif(lApont,"04","03"))

//========================================
// TFY - Material de Consumo
//========================================

If (TecAponts() .And. MV_PAR05 == 1)
    lApont := .T.
	oStruTFY:AddField( ;									// Ord. Tipo Desc.
								"TFY_LEG",;						// [01] C Nome do Campo
								"01",;							// [02] C Ordem
								STR0219,;					// [03] C Titulo do campo # "Legenda"
								STR0219,;					// [04] C Descrição do campo # "Legenda"
								Nil,;							// [05] A Array com Help
								"BT",;							// [06] C Tipo do campo
								"",;							// [07] C Picture
								NIL,;							// [08] B Bloco de Picture Var
								"",;							// [09] C Consulta F3
								.T.,;							// [10] L Indica se o campo é editável
								NIL,;							// [11] C Pasta do campo
								NIL,;							// [12] C Agrupamento do campo
								NIL,;							// [13] A Lista de valores permitido do campo (Combo)
								NIL,;							// [14] N Tamanho Maximo da maior opção do combo
								NIL,;							// [15] C Inicializador de Browse
								.T.,;							// [16] L Indica se o campo é virtual
								NIL )							// [17] C Picture Variável
Endif								

oStruTFY:AddField( ;									// Ord. Tipo Desc.
						"TFY_LOCAL",;					// [01] C Nome do Campo
						iif(lApont,"02","01"),;								// [02] C Ordem
						STR0004,;						// [03] C Titulo do campo # "Local"
						STR0004,;						// [04] C Descrição do campo # "Local"
						Nil,;							// [05] A Array com Help
						"C",;							// [06] C Tipo do campo
						"@!",;							// [07] C Picture
						NIL,;							// [08] B Bloco de Picture Var
						"" ,;							// [09] C Consulta F3
						.F.,;							// [10] L Indica se o campo é editável
						NIL,;							// [11] C Pasta do campo
						NIL,;							// [12] C Agrupamento do campo
						NIL,;							// [13] A Lista de valores permitido do campo (Combo)
						NIL,;							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;							// [15] C Inicializador de Browse
						.T.,;							// [16] L Indica se o campo é virtual
						NIL )							// [17] C Picture Variável

oStruTFY:AddField( ; 								// Ord. Tipo Desc.
						"TFY_DESCRI",;				// [01] C Nome do Campo
						iif(lApont,"03","02"),;							// [02] C Ordem
						STR0005,;						// [03] C Titulo do campo # "Descrição"
						STR0005,;						// [04] C Descrição do campo # "Descrição"
						Nil,;							// [05] A Array com Help
						"C",;							// [06] C Tipo do campo
						"@!",;							// [07] C Picture
						NIL,;							// [08] B Bloco de Picture Var
						"" ,;							// [09] C Consulta F3
						.F.,;							// [10] L Indica se o campo é editável
						NIL,;							// [11] C Pasta do campo
						NIL,;							// [12] C Agrupamento do campo
						NIL,;							// [13] A Lista de valores permitido do campo (Combo)
						NIL,;							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;							// [15] C Inicializador de Browse
						.T.,;							// [16] L Indica se o campo é virtual
						NIL )							// [17] C Picture Variável

oStruTFY:AddField( ;									// Ord. Tipo Desc.
						"TFY_PRODUT",;				// [01] C Nome do Campo
						iif(lApont,"05","04"),;							// [02] C Ordem
						STR0038,;						// [03] C Titulo do campo # "Produto"
						STR0038,;						// [04] C Descrição do campo # "Produto"
						Nil,;							// [05] A Array com Help
						"C",;							// [06] C Tipo do campo
						"@!",;							// [07] C Picture
						NIL,;							// [08] B Bloco de Picture Var
						"" ,;							// [09] C Consulta F3
						.F.,;							// [10] L Indica se o campo é editável
						NIL,;							// [11] C Pasta do campo
						NIL,;							// [12] C Agrupamento do campo
						NIL,;							// [13] A Lista de valores permitido do campo (Combo)
						NIL,;							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;							// [15] C Inicializador de Browse
						.T.,;							// [16] L Indica se o campo é virtual
						NIL )							// [17] C Picture Variável

oStruTFY:AddField( ;									// Ord. Tipo Desc.
						"TFY_DSCPRO",;				// [01] C Nome do Campo
						iif(lApont,"06","05"),;							// [02] C Ordem
						STR0064,;						// [03] C Titulo do campo # "Desc. Produto"
						STR0064,;						// [04] C Descrição do campo # "Desc. Produto"
						Nil,;							// [05] A Array com Help
						"C",;							// [06] C Tipo do campo
						"@!",;							// [07] C Picture
						NIL,;							// [08] B Bloco de Picture Var
						"" ,;							// [09] C Consulta F3
						.F.,;							// [10] L Indica se o campo é editável
						NIL,;							// [11] C Pasta do campo
						NIL,;							// [12] C Agrupamento do campo
						NIL,;							// [13] A Lista de valores permitido do campo (Combo)
						NIL,;							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;							// [15] C Inicializador de Browse
						.T.,;							// [16] L Indica se o campo é virtual
						NIL )							// [17] C Picture Variável

oStruTFY:SetProperty("TFY_CODTFF", MVC_VIEW_ORDEM, iif(lApont,"04","03")	)

//========================================
// TFL - Locação de Equipamentos
//========================================
oStruTFL:AddField( ;									// Ord. Tipo Desc.
						'TFL_VALTOT',;				// [01] C Nome do Campo (cIdField)
       				'05',;							// [02] C Ordem (cOrdem)
                     STR0065,;						// [03] C Titulo do campo (cTitulo) #"Valor Total"
                     STR0065,;						// [04] C Descrição do campo (cDescric) #"Valor Total"
                     {},;							// [05] A Array com Help (aHelp)
                   	'N',;							// [06] C Tipo do campo (cType)
                   	'@E 9,999,999,999.99',;		// [07] C Picture (cPicture)
       				Nil,;							// [08] B Bloco de Picture Var (bPictVar)
                     Nil,;							// [09] C Consulta F3
                     .T.,;							// [10] L Indica se o campo é editável (lCanChange)
                     '',;							// [11] C Pasta do campo (cFolder)
                     Nil,;							// [12] C Agrupamento do campo (cGroup)
                     Nil,;							// [13] A Lista de valores permitido do campo (Combo) (aComboValues)
                     Nil,;							// [14] N Tamanho Maximo da maior opção do combo (nMaxLenCombo)
                     Nil,;							// [15] C Inicializador de Browse (cIniBrow)
                     .T.,;							// [16] L Indica se o campo é virtual (lVirtual)
                     Nil )							// [17] C Picture Variável (cPictVar)

oStruTFL:AddField(	'TFL_DISP',;					// [01] C Nome do Campo (cIdField)
       				'06',;							// [02] C Ordem (cOrdem)
                     STR0066,;						// [03] C Titulo do campo (cTitulo) #"Disponibilização"
                     STR0066,;						// [04] C Descrição do campo (cDescric) #"Disponibilização"
                     {},;							// [05] A Array com Help (aHelp)
                   	'N',;							// [06] C Tipo do campo (cType)
                   	'@E 9,999,999,999.99',;		// [07] C Picture (cPicture)
       				Nil,;							// [08] B Bloco de Picture Var (bPictVar)
                     Nil,;							// [09] C Consulta F3
                     .T.,;							// [10] L Indica se o campo é editável (lCanChange)
                     '',;							// [11] C Pasta do campo (cFolder)
                     Nil,;							// [12] C Agrupamento do campo (cGroup)
                     Nil,;							// [13] A Lista de valores permitido do campo (Combo) (aComboValues)
                     Nil,;							// [14] N Tamanho Maximo da maior opção do combo (nMaxLenCombo)
                     Nil,;							// [15] C Inicializador de Browse (cIniBrow)
                     .T.,;							// [16] L Indica se o campo é virtual (lVirtual)
                     Nil )							// [17] C Picture Variável (cPictVar)

oStruTFL:AddField(	'TFL_USO',;					// [01] C Nome do Campo (cIdField)
       				'07',;							// [02] C Ordem (cOrdem)
                     STR0067,;						// [03] C Titulo do campo (cTitulo) #"Uso"
                     STR0067,;						// [04] C Descrição do campo (cDescric) #"Uso"
                     {},;							// [05] A Array com Help (aHelp)
                   	'N',;							// [06] C Tipo do campo (cType)
                   	'@E 9,999,999,999.99',;		// [07] C Picture (cPicture)
       				Nil,;							// [08] B Bloco de Picture Var (bPictVar)
                     Nil,;							// [09] C Consulta F3
                     .T.,;							// [10] L Indica se o campo é editável (lCanChange)
                     '',;							// [11] C Pasta do campo (cFolder)
                     Nil,;							// [12] C Agrupamento do campo (cGroup)
                     Nil,;							// [13] A Lista de valores permitido do campo (Combo) (aComboValues)
                     Nil,;							// [14] N Tamanho Maximo da maior opção do combo (nMaxLenCombo)
                     Nil,;							// [15] C Inicializador de Browse (cIniBrow)
                     .T.,;							// [16] L Indica se o campo é virtual (lVirtual)
                     Nil )							// [17] C Picture Variável (cPictVar)

oStruTFL:AddField(	'TFL_MOBILI',;				// [01] C Nome do Campo (cIdField)
       				'08',;							// [02] C Ordem (cOrdem)
                     STR0068,;						// [03] C Titulo do campo (cTitulo) #"Mobilização"
                     STR0068,;						// [04] C Descrição do campo (cDescric) #"Mobilização"
                     {},;							// [05] A Array com Help (aHelp)
                   	'N',;							// [06] C Tipo do campo (cType)
                   	'@E 9,999,999,999.99',;		// [07] C Picture (cPicture)
       				Nil,;							// [08] B Bloco de Picture Var (bPictVar)
                     Nil,;							// [09] C Consulta F3
                     .T.,;							// [10] L Indica se o campo é editável (lCanChange)
                     '',;							// [11] C Pasta do campo (cFolder)
                     Nil,;							// [12] C Agrupamento do campo (cGroup)
                     Nil,;							// [13] A Lista de valores permitido do campo (Combo) (aComboValues)
                     Nil,;							// [14] N Tamanho Maximo da maior opção do combo (nMaxLenCombo)
                     Nil,;							// [15] C Inicializador de Browse (cIniBrow)
                     .T.,;							// [16] L Indica se o campo é virtual (lVirtual)
                     Nil )							// [17] C Picture Variável (cPictVar)

oStruTFL:SetProperty("*",MVC_VIEW_CANCHANGE, .F.)

//========================================
// TFI - Locação de Equipamentos (PRODUTOS)
//========================================
oStruTFI:AddField(	'TFI_DISP',;					// [01] C Nome do Campo (cIdField)
       				'06',;							// [02] C Ordem (cOrdem)
                     STR0066,;						// [03] C Titulo do campo (cTitulo) #"Disponibilização"
                     STR0066,;						// [04] C Descrição do campo (cDescric) #"Disponibilização"
                     {},;							// [05] A Array com Help (aHelp)
                   	'N',;							// [06] C Tipo do campo (cType)
                   	'@E 9,999,999,999.99',;		// [07] C Picture (cPicture)
       				Nil,;							// [08] B Bloco de Picture Var (bPictVar)
                     Nil,;							// [09] C Consulta F3
                     .T.,;							// [10] L Indica se o campo é editável (lCanChange)
                     '',;							// [11] C Pasta do campo (cFolder)
                     Nil,;							// [12] C Agrupamento do campo (cGroup)
                     Nil,;							// [13] A Lista de valores permitido do campo (Combo) (aComboValues)
                     Nil,;							// [14] N Tamanho Maximo da maior opção do combo (nMaxLenCombo)
                     Nil,;							// [15] C Inicializador de Browse (cIniBrow)
                     .T.,;							// [16] L Indica se o campo é virtual (lVirtual)
                     Nil )							// [17] C Picture Variável (cPictVar)

oStruTFI:AddField(	'TFI_USO',;					// [01] C Nome do Campo (cIdField)
       				'07',;							// [02] C Ordem (cOrdem)
                     STR0067,;						// [03] C Titulo do campo (cTitulo) #"Uso"
                     STR0067,;						// [04] C Descrição do campo (cDescric) #"Uso"
                     {},;							// [05] A Array com Help (aHelp)
                   	'N',;							// [06] C Tipo do campo (cType)
                   	'@E 9,999,999,999.99',;		// [07] C Picture (cPicture)
       				Nil,;							// [08] B Bloco de Picture Var (bPictVar)
                     Nil,;							// [09] C Consulta F3
                     .T.,;							// [10] L Indica se o campo é editável (lCanChange)
                     '',;							// [11] C Pasta do campo (cFolder)
                     Nil,;							// [12] C Agrupamento do campo (cGroup)
                     Nil,;							// [13] A Lista de valores permitido do campo (Combo) (aComboValues)
                     Nil,;							// [14] N Tamanho Maximo da maior opção do combo (nMaxLenCombo)
                     Nil,;							// [15] C Inicializador de Browse (cIniBrow)
                     .T.,;							// [16] L Indica se o campo é virtual (lVirtual)
                     Nil )							// [17] C Picture Variável (cPictVar)

oStruTFI:AddField(	'TFI_MOBILI',;				// [01] C Nome do Campo (cIdField)
       				'08',;							// [02] C Ordem (cOrdem)
                     STR0068,;						// [03] C Titulo do campo (cTitulo) #"Mobilização"
                     STR0068,;						// [04] C Descrição do campo (cDescric) #"Mobilização"
                     {},;							// [05] A Array com Help (aHelp)
                   	'N',;							// [06] C Tipo do campo (cType)
                   	'@E 9,999,999,999.99',;		// [07] C Picture (cPicture)
       				Nil,;							// [08] B Bloco de Picture Var (bPictVar)
                     Nil,;							// [09] C Consulta F3
                     .T.,;							// [10] L Indica se o campo é editável (lCanChange)
                     '',;							// [11] C Pasta do campo (cFolder)
                     Nil,;							// [12] C Agrupamento do campo (cGroup)
                     Nil,;							// [13] A Lista de valores permitido do campo (Combo) (aComboValues)
                     Nil,;							// [14] N Tamanho Maximo da maior opção do combo (nMaxLenCombo)
                     Nil,;							// [15] C Inicializador de Browse (cIniBrow)
                     .T.,;							// [16] L Indica se o campo é virtual (lVirtual)
                     Nil )							// [17] C Picture Variável (cPictVar)

oStruTFI:AddField(	'TFI_TOTMUL',;				// [01] C Nome do Campo (cIdField)
       				'09',;							// [02] C Ordem (cOrdem)
                     STR0093,;						// [03] C Titulo do campo (cTitulo) #"Mobilização"
                     STR0093,;						// [04] C Descrição do campo (cDescric) #"Mobilização"
                     {},;							// [05] A Array com Help (aHelp)
                   	'N',;							// [06] C Tipo do campo (cType)
                   	'@E 9,999,999,999.99',;		// [07] C Picture (cPicture)
       				Nil,;							// [08] B Bloco de Picture Var (bPictVar)
                     Nil,;							// [09] C Consulta F3
                     .T.,;							// [10] L Indica se o campo é editável (lCanChange)
                     '',;							// [11] C Pasta do campo (cFolder)
                     Nil,;							// [12] C Agrupamento do campo (cGroup)
                     Nil,;							// [13] A Lista de valores permitido do campo (Combo) (aComboValues)
                     Nil,;							// [14] N Tamanho Maximo da maior opção do combo (nMaxLenCombo)
                     Nil,;							// [15] C Inicializador de Browse (cIniBrow)
                     .T.,;							// [16] L Indica se o campo é virtual (lVirtual)
                     Nil )							// [17] C Picture Variável (cPictVar)

oStruTFI:AddField(	'TFI_TOTBON',;				// [01] C Nome do Campo (cIdField)
       				'10',;							// [02] C Ordem (cOrdem)
                     STR0094,;						// [03] C Titulo do campo (cTitulo) #"Mobilização"
                     STR0094,;						// [04] C Descrição do campo (cDescric) #"Mobilização"
                     {},;							// [05] A Array com Help (aHelp)
                   	'N',;							// [06] C Tipo do campo (cType)
                   	'@E 9,999,999,999.99',;		// [07] C Picture (cPicture)
       				Nil,;							// [08] B Bloco de Picture Var (bPictVar)
                     Nil,;							// [09] C Consulta F3
                     .T.,;							// [10] L Indica se o campo é editável (lCanChange)
                     '',;							// [11] C Pasta do campo (cFolder)
                     Nil,;							// [12] C Agrupamento do campo (cGroup)
                     Nil,;							// [13] A Lista de valores permitido do campo (Combo) (aComboValues)
                     Nil,;							// [14] N Tamanho Maximo da maior opção do combo (nMaxLenCombo)
                     Nil,;							// [15] C Inicializador de Browse (cIniBrow)
                     .T.,;							// [16] L Indica se o campo é virtual (lVirtual)
                     Nil )							// [17] C Picture Variável (cPictVar)

oStruTFI:AddField(	'TFI_TOTDES',;				// [01] C Nome do Campo (cIdField)
       				'11',;							// [02] C Ordem (cOrdem)
                     STR0092,;						// [03] C Titulo do campo (cTitulo) #"Mobilização"
                     STR0092,;						// [04] C Descrição do campo (cDescric) #"Mobilização"
                     {},;							// [05] A Array com Help (aHelp)
                   	'N',;							// [06] C Tipo do campo (cType)
                   	'@E 9,999,999,999.99',;		// [07] C Picture (cPicture)
       				Nil,;							// [08] B Bloco de Picture Var (bPictVar)
                     Nil,;							// [09] C Consulta F3
                     .T.,;							// [10] L Indica se o campo é editável (lCanChange)
                     '',;							// [11] C Pasta do campo (cFolder)
                     Nil,;							// [12] C Agrupamento do campo (cGroup)
                     Nil,;							// [13] A Lista de valores permitido do campo (Combo) (aComboValues)
                     Nil,;							// [14] N Tamanho Maximo da maior opção do combo (nMaxLenCombo)
                     Nil,;							// [15] C Inicializador de Browse (cIniBrow)
                     .T.,;							// [16] L Indica se o campo é virtual (lVirtual)
                     Nil )							// [17] C Picture Variável (cPictVar)

oStruTFI:SetProperty("*",MVC_VIEW_CANCHANGE, .F.)

//========================================
// TFZ - Locação de Equipamentos (DETALHES APURAÇÃO)
//========================================
//Campo virtual para atribuir a quantidade a ser apurada.
oStruTFZ:AddField(	'TFZ_QTDE',;					// [01] C Nome do Campo (cIdField)
						'10',;							// [02] C Ordem (cOrdem)
						STR0061,;						// [03] C Titulo do campo (cTitulo) #"Quant.Previs"
						STR0061,;						// [04] C Descrição do campo (cDescric) #"Quant.Previs"
						{},;							// [05] A Array com Help (aHelp)
						'N',;							// [06] C Tipo do campo (cType)
						'@E 9,999,999,999.99',;		// [07] C Picture (cPicture)
						Nil,;							// [08] B Bloco de Picture Var (bPictVar)
						Nil,;							// [09] C Consulta F3
						.T.,;							// [10] L Indica se o campo é editável (lCanChange)
						'',;							// [11] C Pasta do campo (cFolder)
						Nil,;							// [12] C Agrupamento do campo (cGroup)
						Nil,;							// [13] A Lista de valores permitido do campo (Combo) (aComboValues)
						Nil,;							// [14] N Tamanho Maximo da maior opção do combo (nMaxLenCombo)
						Nil,;							// [15] C Inicializador de Browse (cIniBrow)
						.T.,;							// [16] L Indica se o campo é virtual (lVirtual)
						Nil )							// [17] C Picture Variável (cPictVar)

oStrTWB:AddField("TWB_CLIENT",;
				 "17",;
				 STR0187,; //"Cliente"
				 STR0187,; //"Cliente"
				 {STR0189},; // "Cliente utilizado na Medição da planilha"
				 "C",;
				 "@!",;
				 NIL,;
				 'CNC001',;
				 .T.,;
				 NIL,;
				 NIL,;
				 Nil,;
				 Nil,;
				 NIL,;
				 .T.,;
				 NIL )

oStrTWB:AddField("TWB_LOJA",;
				 "18",;
				 STR0188,; // "Loja"
				 STR0188,; // "Loja"
				 {STR0190},; // "Loja utilizado na Medição da planilha"
				 "C",;
				 "@!",;
				 NIL,;
				 "",;
				 .T.,;
				 NIL,;
				 NIL,;
				 Nil,;
				 Nil,;
				 NIL,;
				 .T.,;
				 NIL )

oStruTFZ:SetProperty("*",MVC_VIEW_CANCHANGE, .F.)

oStruTFZ:SetProperty("TFZ_QTDAPU",MVC_VIEW_CANCHANGE, .T.)
oStruTFZ:SetProperty("TFZ_MODCOB" , MVC_VIEW_ORDEM, "01")

oStrTWB:RemoveField("TWB_COD")
oStrTWB:RemoveField("TWB_CODTFV")

If TecMedAgil()
	oStruTFV:RemoveField("TFV_MEDAGI")	 
EndIf
If TecBHasTpA() .AND. !lMedExce
	oStruTFV:RemoveField("TFV_TOTEXC")
EndIf
If lMedExce
	oStruTFV:RemoveField("TFV_ANTECI")
EndIf
If lApuraHE .OR. lMedExce
	oStruTFV:RemoveField("TFV_HREXTR")
EndIf

LoadStruZZP(oStruZZP, .T.)

oView := FWFormView():New()											// Cria o objeto de View
oView:SetModel(oModel)												// Define qual Modelo de dados será utilizado
oView:AddField("VIEW_TFV",       oStruTFV,   "TFVMASTER")		// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:AddGrid("VIEW_ZZP",        oStruZZP,   "ZZPDETAIL")
oView:AddGrid("TECA930_IRH",     oStruTFW,   "TFWDETAIL")		// TFW - Recursos Humanos
oView:AddGrid("TECA930_IRH_TW6", oStrTFWTW6, "TFWTW6DETAIL")	// TFWTW6 - Recursos Humanos - DESCONTOS
oView:AddGrid("TECA930_IRH_TW7", oStrTFWTW7, "TFWTW7DETAIL")	// TFWTW7 - Recursos Humanos - MULTAS/BONIFICAÇÃO
oView:AddGrid("TECA930_IMI",     oStruTFX,   "TFXDETAIL")		// TFX - Material de Implantação
oView:AddGrid("TECA930_IMI_TW6", oStrTFXTW6, "TFXTW6DETAIL")	// TFXTW6 - Material de Implantação - DESCONTOS
oView:AddGrid("TECA930_IMI_TW7", oStrTFXTW7, "TFXTW7DETAIL")	// TFXTW7 - Material de Implantação - MULTAS/BONIFICAÇÃO
oView:AddGrid("TECA930_IMC",     oStruTFY,   "TFYDETAIL")		// TFY - Material de Consumo
oView:AddGrid("TECA930_IMC_TW6", oStrTFYTW6, "TFYTW6DETAIL")	// TFYTW6 - Material de Consumo - DESCONTOS
oView:AddGrid("TECA930_IMC_TW7", oStrTFYTW7, "TFYTW7DETAIL")	// TFYTW7 - Material de Consumo - MULTAS/BONIFICAÇÃO
oView:AddGrid("TECA930_LOC",     oStruTFL,   "TFLDETAIL")		// TFL - Locação de Equipamentos
oView:AddGrid("TECA930_IPR",     oStruTFI,   "TFIPRODUT")		// TFI - Locação de Equipamentos (PRODUTOS)
oView:AddGrid("TECA930_IPR_TW6", oStrTFITW6, "TFITW6DETAIL")	// TFITW6 - Locação de Equipamentos (PRODUTOS) - DESCONTOS
oView:AddGrid("TECA930_IPR_TW7", oStrTFITW7, "TFITW7DETAIL")	// TFITW7 - Locação de Equipamentos (PRODUTOS) - MULTAS/BONIFICAÇÃO
oView:AddGrid("TECA930_ILE",     oStruTFZ,   "TFZDETAIL")		// TFZ - Locação de Equipamentos (DETALHES APURAÇÃO)

oView:AddGrid("TECA930_TW8_OS", oStruTW8, "TW8DETAIL")		// TW8 - Desconto por ordem de Serviço

oView:AddGrid("TECA930_RESLOC", oStrTWB,  "TWBDETAIL")		// TWB - Resumo Local

oView:AddUserButton(STR0084 ,"",{|oView| FMedApu930(oView)})	//'Materiais por valor'
oView:AddUserButton(STR0215 ,"",{|oView| A930ViewCTR()})	//"Visualizar contrato"
If TecBHasCrn() .AND. TecBHasExc()
	oView:AddUserButton(STR0214 ,"",{|oView| TECA930C(oView)}) //"Excedentes"
EndIf

// Adiciona as visões na tela
oView:CreateHorizontalBox( "TOP",  20 )
oView:CreateHorizontalBox( "DOWN", 80 )

// Cria Folder na view
oView:CreateFolder( "ABAS", "DOWN" )
oView:AddSheet("ABAS", "ABA01", STR0007)	//"Recursos Humanos"
oView:AddSheet("ABAS", "ABA02", STR0008)	//'Materiais de Implantação'
oView:AddSheet("ABAS", "ABA03", STR0009)	//'Materiais de Consumo'
oView:AddSheet("ABAS", "ABA04", STR0010)	//"Locação de Equipamentos"
oView:AddSheet("ABAS", "ABA06", STR0095)	//"Resumo dos Locais"
oView:AddSheet("ABAS", "ABA05", STR0090)	//"Resumo da Medição"

oView:CreateHorizontalBox("ID_ABA01_TOP",               065,,, "ABAS", "ABA01")									// Define a área de item de RH (Área superior)
oView:CreateHorizontalBox("ID_ABA01_DOWN",              030,,, "ABAS", "ABA01")									// Define a área de item de RH (Área inferior)
oView:CreateHorizontalBox("ID_ABA01_FOOTER",            005,,, "ABAS", "ABA01")									// Define a área do botão detalhes do item de RH
oView:CreateFolder("ABA01_DOWN_ABAS", "ID_ABA01_DOWN")																// Define a área para a criação das Abas do item de RH
oView:AddSheet("ABA01_DOWN_ABAS", "ABA01_DOWN_ABAS_01", STR0091)													// Define a Aba das Multas e Bonificações do item de RH
oView:AddSheet("ABA01_DOWN_ABAS", "ABA01_DOWN_ABAS_02", STR0092)													// Define a Aba dos Descontos do item de RH
oView:CreateHorizontalBox("ID_ABA01_DOWN_ABAS_01_H1",   100,,, "ABA01_DOWN_ABAS", "ABA01_DOWN_ABAS_01")		// Define a área das Multas e Bonificações do item de RH
oView:CreateHorizontalBox("ID_ABA01_DOWN_ABAS_02_H1",   100,,, "ABA01_DOWN_ABAS", "ABA01_DOWN_ABAS_02")		// Define a área dos Descontos do item de RH

oView:CreateHorizontalBox("ID_ABA02_TOP",               065,,, "ABAS", "ABA02")									// Define a área de Materiais de Implantação (Área superior)
oView:CreateHorizontalBox("ID_ABA02_DOWN",              030,,, "ABAS", "ABA02")									// Define a área de item de Materiais de Implantação (Área inferior)
oView:CreateHorizontalBox("ID_ABA02_FOOTER",            005,,, "ABAS", "ABA02")									// Define a área do botão detalhes de Materiais de Implantação
oView:CreateFolder("ABA02_DOWN_ABAS", "ID_ABA02_DOWN")																// Define a área para a criação das Abas do item de Materiais de Implantação
oView:AddSheet("ABA02_DOWN_ABAS", "ABA02_DOWN_ABAS_01", STR0091)													// Define a Aba das Multas e Bonificações do item de Materiais de Implantação
oView:AddSheet("ABA02_DOWN_ABAS", "ABA02_DOWN_ABAS_02", STR0092)													// Define a Aba dos Descontos do item de Materiais de Implantação
oView:CreateHorizontalBox("ID_ABA02_DOWN_ABAS_01_H1",   100,,, "ABA02_DOWN_ABAS", "ABA02_DOWN_ABAS_01")		// Define a área das Multas e Bonificações do item de Materiais de Implantação
oView:CreateHorizontalBox("ID_ABA02_DOWN_ABAS_02_H1",   100,,, "ABA02_DOWN_ABAS", "ABA02_DOWN_ABAS_02")		// Define a área dos Descontos do item de Materiais de Implantação

oView:CreateHorizontalBox("ID_ABA03_TOP",               065,,, "ABAS", "ABA03")									// Define a área de Materiais de Consumo (Área superior)
oView:CreateHorizontalBox("ID_ABA03_DOWN",              030,,, "ABAS", "ABA03")									// Define a área de item de Materiais de Consumo (Área inferior)
oView:CreateHorizontalBox("ID_ABA03_FOOTER",            005,,, "ABAS", "ABA03")									// Define a área do botão detalhes Materiais de Consumo
oView:CreateFolder("ABA03_DOWN_ABAS", "ID_ABA03_DOWN")																// Define a área para a criação das Abas do item de Materiais de Consumo
oView:AddSheet("ABA03_DOWN_ABAS", "ABA03_DOWN_ABAS_01", STR0091)													// Define a Aba das Multas e Bonificações do item de Materiais de Consumo
oView:AddSheet("ABA03_DOWN_ABAS", "ABA03_DOWN_ABAS_02", STR0092)													// Define a Aba dos Descontos do item de Materiais de Consumo
oView:CreateHorizontalBox("ID_ABA03_DOWN_ABAS_01_H1",   100,,, "ABA03_DOWN_ABAS", "ABA03_DOWN_ABAS_01")		// Define a área das Multas e Bonificações do item de Materiais de Consumo
oView:CreateHorizontalBox("ID_ABA03_DOWN_ABAS_02_H1",   100,,, "ABA03_DOWN_ABAS", "ABA03_DOWN_ABAS_02")		// Define a área dos Descontos do item de Materiais de Consumo

oView:CreateHorizontalBox("ID_ABA04_TOP",               030,,, "ABAS", "ABA04")									// Define a área de Locação de Equipamentos (Área superior)
oView:CreateHorizontalBox("ID_ABA04_MIDDLE",            035,,, "ABAS", "ABA04")									// Define a área de item de Locação de Equipamentos (Área intermediária)
oView:CreateHorizontalBox("ID_ABA04_DOWN",              030,,, "ABAS", "ABA04")									// Define a área de item de Locação de Equipamentos (Área inferior)
oView:CreateHorizontalBox("ID_ABA04_FOOTER",            005,,, "ABAS", "ABA04")									// Define a área do botão detalhes de Locação de Equipamentos

oView:CreateFolder("ABA04_MIDDLE_ABAS", "ID_ABA04_MIDDLE")														 	// Define a área para a criação das Abas dos produtos do item da Locação de Equipamentos
oView:AddSheet("ABA04_MIDDLE_ABAS", "ABA04_MIDDLE_ABAS_01", STR0102)	//"Produtos"								// Define a Aba dos produtos do item da Locação de Equipamentos
oView:CreateHorizontalBox("ID_ABA04_MIDDLE_ABAS_01_H1", 100,,, "ABA04_MIDDLE_ABAS", "ABA04_MIDDLE_ABAS_01")	// Define a área dos produtos do item da Locação de Equipamentos

oView:AddSheet("ABA04_MIDDLE_ABAS", "ABA04_MIDDLE_ABAS_02", STR0103)	//"Ordem Serviço"						// Define a Aba desconto OS
oView:CreateHorizontalBox("ID_ABA04_MIDDLE_ABAS_02_H1", 100,,, "ABA04_MIDDLE_ABAS", "ABA04_MIDDLE_ABAS_02")	// Define a área dos produtos do item da Locação de Equipamentos

oView:CreateFolder("ABA04_DOWN_ABAS", "ID_ABA04_DOWN")																// Define a área para a criação das Abas do item da Locação de Equipamentos
oView:AddSheet("ABA04_DOWN_ABAS", "ABA04_DOWN_ABAS_01", STR0104)	//"Medição"									// Define a Aba das Medições do item da Locação de Equipamentos
oView:AddSheet("ABA04_DOWN_ABAS", "ABA04_DOWN_ABAS_02", STR0091)													// Define a Aba das Multas e Bonificações do item da Locação de Equipamentos
oView:AddSheet("ABA04_DOWN_ABAS", "ABA04_DOWN_ABAS_03", STR0092)													// Define a Aba dos Descontos do item da Locação de Equipamentos
oView:CreateHorizontalBox("ID_ABA04_DOWN_ABAS_01_H1",   100,,, "ABA04_DOWN_ABAS", "ABA04_DOWN_ABAS_01")		// Define a área das Medições do item da Locação de Equipamentos
oView:CreateHorizontalBox("ID_ABA04_DOWN_ABAS_02_H1",   100,,, "ABA04_DOWN_ABAS", "ABA04_DOWN_ABAS_02")		// Define a área das Multas e Bonificações do item da Locação de Equipamentos
oView:CreateHorizontalBox("ID_ABA04_DOWN_ABAS_03_H1",   100,,, "ABA04_DOWN_ABAS", "ABA04_DOWN_ABAS_03")		// Define a área dos Descontos do item da Locação de Equipamentos

oView:CreateHorizontalBox("ID_ABA05", 100,,, "ABAS", "ABA05")	// Define a área do Resumo da Medição

oView:CreateHorizontalBox("ID_ABA06", 100,,, "ABAS", "ABA06")	// Define a área do Resumo dos Locais

// Adiciona os botoes de detalhes do local nas abas
oView:AddOtherObject("DETALHE_IRH", {|oPanel| At930Buttons(oPanel,2)})
oView:AddOtherObject("DETALHE_IMI", {|oPanel| At930Buttons(oPanel,3)})
oView:AddOtherObject("DETALHE_IMC", {|oPanel| At930Buttons(oPanel,4)})
oView:AddOtherObject("DETALHE_ILE", {|oPanel| At930Buttons(oPanel,5)})

// Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView("VIEW_TFV",        "TOP")
oView:SetOwnerView("TECA930_IRH",     "ID_ABA01_TOP")
oView:SetOwnerView("TECA930_IRH_TW7", "ID_ABA01_DOWN_ABAS_01_H1")
oView:SetOwnerView("TECA930_IRH_TW6", "ID_ABA01_DOWN_ABAS_02_H1")
oView:SetOwnerView("DETALHE_IRH",     "ID_ABA01_FOOTER")
oView:SetOwnerView("TECA930_IMI",     "ID_ABA02_TOP")
oView:SetOwnerView("TECA930_IMI_TW7", "ID_ABA02_DOWN_ABAS_01_H1")
oView:SetOwnerView("TECA930_IMI_TW6", "ID_ABA02_DOWN_ABAS_02_H1")
oView:SetOwnerView("DETALHE_IMI",     "ID_ABA02_FOOTER")
oView:SetOwnerView("TECA930_IMC",     "ID_ABA03_TOP")
oView:SetOwnerView("TECA930_IMC_TW7", "ID_ABA03_DOWN_ABAS_01_H1")
oView:SetOwnerView("TECA930_IMC_TW6", "ID_ABA03_DOWN_ABAS_02_H1")
oView:SetOwnerView("DETALHE_IMC",     "ID_ABA03_FOOTER")
oView:SetOwnerView("TECA930_LOC",     "ID_ABA04_TOP")
oView:SetOwnerView("TECA930_IPR",     "ID_ABA04_MIDDLE_ABAS_01_H1")
oView:SetOwnerView("TECA930_ILE",     "ID_ABA04_DOWN_ABAS_01_H1")
oView:SetOwnerView("TECA930_IPR_TW7", "ID_ABA04_DOWN_ABAS_02_H1")
oView:SetOwnerView("TECA930_IPR_TW6", "ID_ABA04_DOWN_ABAS_03_H1")
oView:SetOwnerView("DETALHE_ILE",     "ID_ABA04_FOOTER")
oView:SetOwnerView("VIEW_ZZP",        "ID_ABA05")

oView:SetOwnerView("TECA930_TW8_OS",  "ID_ABA04_MIDDLE_ABAS_02_H1")
oStruTW8:SetProperty('*',	MVC_VIEW_CANCHANGE,.F.)	//Desabilita todos os campos para edição
oStruTW8:SetProperty('TW8_OK',	MVC_VIEW_CANCHANGE,.T.)	//Habilita somente o campo OK para edição

oView:SetOwnerView("TECA930_RESLOC",  "ID_ABA06")

oView:SetDescription( STR0001 ) // "Apuração / Medição de Atendimentos"
oView:SetCloseOnOk({|| .T.} )

If !lGSRH
	oView:HideFolder( "ABAS", STR0007, 2 ) ////"Recursos Humanos"
EndIf

If (!lOrcPrc .AND. !lGSRH) .OR. !lGSMIMC //Se na configuração item de MI/MC estiver subordinado ao RH e o contexto estiver desabilitado, desabilita também
	oView:HideFolder("ABAS", STR0008, 2)	//'Materiais de Implantação'
	oView:HideFolder("ABAS", STR0009, 2)	//'Materiais de Consumo'
EndIf

If !lGSLE .OR. (VALTYPE(lMedExt) == "L" .AND. lMedExt) 
	oView:HideFolder("ABAS", STR0010, 2)	//"Locação de Equipamentos"
EndIf

Return(oView)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At930Buttons
Criação dos botões para detalhes do local nas abas da apuração do contrato
@sample 	At930Buttons(oPanel,nAba)
@param		oPanel - Painel onde deverá ser criado e exibido o botão
@param		nAba   - Numero da aba onde devera ser criado o botão
@return	Nil
@author	Serviços
@since		04/11/2013
@version	P11.9
/*/
//------------------------------------------------------------------------------
Function At930Buttons( oPanel, nAba, lAutomato )

Local oButton

Default oPanel := NIL
Default nAba := 0
Default lAutomato := .F.


If !lAutomato
// Ancoramos os objetos no oPanel passado
	@ 000, 000 Button oButton Prompt STR0011 Of oPanel Size 055, 012 Pixel //"Detalhes do Local"
	oButton:Align := CONTROL_ALIGN_RIGHT // Alinhamento do botao referente ao panel
EndIf

// Define a ação ao clicar no botão atraves da aba selecionada
Do Case
	Case nAba == 2	// Aba de Recursos Humanos
		IIF( !lAutomato, oButton:bAction := { || At930DetRH() },  At930DetRH(lAutomato) )
	Case nAba == 3	// Aba de Materiais de Implantação
		IIF( !lAutomato, oButton:bAction := { || At930DetMat(1) },At930DetMat(1, , lAutomato) )
	Case nAba == 4	// Aba de Materiais de Consumo
		IIF( !lAutomato, oButton:bAction := { || At930DetMat(2) },   At930DetMat(2, , lAutomato))
	Case nAba == 5	// Aba de Locação de Equipamentos
		IIF( !lAutomato, oButton:bAction := { ||  At930DetLoc() },  At930DetLoc(lAutomato)  )
EndCase

Return(Nil)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At930GridZZP
Atualização da lista de grupos de faturamentos
@sample 	At930GridZZP(oPanel)
@param		Nil
@return	Nil
@author	Serviços
@since		04/11/2013
@version	P11.9
/*/
//------------------------------------------------------------------------------
Static Function At930GridZZP(oMdlGer)

Local aSaveRows := {}
Local nVlrTotal := 0
Local nVlrExced := 0
Local nX
Local aRet		  := {}
Local cRevCtr	:= Posicione("CN9",7,xFilial("CN9")+MV_PAR01+"05","CN9_REVISA")

aSaveRows := FwSaveRows()

If !Empty(MV_PAR01)

	dbSelectArea( "TFJ" )
	TFJ->( dbSetOrder( 5 ) )
	TFJ->( DbSeek( xFilial("TFJ") + MV_PAR01 + cRevCtr ) )

	While TFJ->( !Eof() ) .AND. xFilial("TFJ")+TFJ->TFJ_CONTRT+TFJ->TFJ_CONREV == xFilial("TFJ") + MV_PAR01 + cRevCtr

		If TFJ->TFJ_STATUS <> "1"
			TFJ->(dbSkip())
			Loop
		EndIf

		oMdlGer:SetValue( "ZZPDETAIL", "ZZP_APU", STR0007  ) // "Recursos Humanos"
		oMdlGer:SetValue( "ZZPDETAIL", "ZZP_GRPFAT",	 TFJ->TFJ_GRPRH )
		oMdlGer:SetValue( "ZZPDETAIL", "ZZP_DESC", Posicione("SB1",1,xFilial("SB1")+TFJ->TFJ_GRPRH,"B1_DESC") )

		nVlrTotal := 0
		nVlrExced := 0

		For nX := 1 To oMdlGer:GetModel( "TFWDETAIL" ):Length()
        	oMdlGer:GetModel( "TFWDETAIL" ):GoLine(nX)
        	nVlrTotal += FwFldGet("TFW_VLRMED")
			nVlrExced += FwFldGet("TFW_VLREXT")
       Next nX

		oMdlGer:SetValue( "ZZPDETAIL", "ZZP_VLRTOT", nVlrTotal )
		oMdlGer:SetValue( "ZZPDETAIL", "ZZP_VLREXT", nVlrExced )

		oMdlGer:GetModel( "ZZPDETAIL" ):AddLine()

		oMdlGer:SetValue( "ZZPDETAIL", "ZZP_APU", STR0008  ) // "Materiais de Implantação"
		oMdlGer:SetValue( "ZZPDETAIL", "ZZP_GRPFAT",	 TFJ->TFJ_GRPMI )
		oMdlGer:SetValue( "ZZPDETAIL", "ZZP_DESC", Posicione("SB1",1,xFilial("SB1")+TFJ->TFJ_GRPMI,"B1_DESC") )

		nVlrTotal := 0

		For nX := 1 To oMdlGer:GetModel( "TFXDETAIL" ):Length()
        	oMdlGer:GetModel( "TFXDETAIL" ):GoLine(nX)
        	nVlrTotal += FwFldGet("TFX_VLRMED")
       Next nX

		oMdlGer:SetValue( "ZZPDETAIL", "ZZP_VLRTOT", nVlrTotal )
		oMdlGer:SetValue( "ZZPDETAIL", "ZZP_VLREXT", 0  )

		oMdlGer:GetModel( "ZZPDETAIL" ):AddLine()

		oMdlGer:SetValue( "ZZPDETAIL", "ZZP_APU", STR0009  ) // "Materiais de Consumo"
		oMdlGer:SetValue( "ZZPDETAIL", "ZZP_GRPFAT",	 TFJ->TFJ_GRPMC )
		oMdlGer:SetValue( "ZZPDETAIL", "ZZP_DESC", Posicione("SB1",1,xFilial("SB1")+TFJ->TFJ_GRPMC,"B1_DESC") )

		nVlrTotal := 0

		For nX := 1 To oMdlGer:GetModel( "TFYDETAIL" ):Length()
        	oMdlGer:GetModel( "TFYDETAIL" ):GoLine(nX)
        	nVlrTotal += FwFldGet("TFY_VLRMED")
       Next nX

		oMdlGer:SetValue( "ZZPDETAIL", "ZZP_VLRTOT", nVlrTotal )
		oMdlGer:SetValue( "ZZPDETAIL", "ZZP_VLREXT", 0  )

		oMdlGer:GetModel( "ZZPDETAIL" ):AddLine()

		oMdlGer:SetValue( "ZZPDETAIL", "ZZP_APU", STR0010 ) // "Locação de Equipamentos"
		oMdlGer:SetValue( "ZZPDETAIL", "ZZP_GRPFAT",	 TFJ->TFJ_GRPLE )
		oMdlGer:SetValue( "ZZPDETAIL", "ZZP_DESC", Posicione("SB1",1,xFilial("SB1")+TFJ->TFJ_GRPLE,"B1_DESC") )

		nVlrTotal := 0

		For nX := 1 To oMdlGer:GetModel( "TFZDETAIL" ):Length()
        	oMdlGer:GetModel( "TFZDETAIL" ):GoLine(nX)
        	nVlrTotal += FwFldGet("TFZ_TOTAL")
       Next nX

		oMdlGer:SetValue( "ZZPDETAIL", "ZZP_VLRTOT", nVlrTotal )
		oMdlGer:SetValue( "ZZPDETAIL", "ZZP_VLREXT", 0  )


		TFJ->( DbSkip() )
	End

	TFJ->(DbCloseArea())

EndIf

Return(aRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At930LoadZZP
Atualização da lista de grupos de faturamentos
@sample 	At930LoadZZP(oMdlGrid)
@param		Nil
@return	Nil
@author	Serviços
@since		21/11/2013
@version	P11.9
/*/
//------------------------------------------------------------------------------
Static Function At930LoadZZP(oMdlGrid)

Local aSaveRows := {}
Local nVlrTotal := 0
Local nVlrExced := 0
Local nVlrDesc  := 0
Local nVlrMulta  := 0
Local nVlrBoni  := 0
Local aRet		  := {}
Local cCodRev   := ""
Local cCodApu	  := TFV->TFV_CODIGO
Local lFirst	  := .T.
Local cCodPai	  := ""


Local cAliasTFW := GetNextAlias()
Local cAliasTFX := GetNextAlias()
Local cAliasTFY := GetNextAlias()
Local cAliasTFZ := GetNextAlias()

aSaveRows := FwSaveRows()

cCodRev := Posicione("CN9",7,xFilial("CN9")+TFV->TFV_CONTRT+"05","CN9_REVISA")

dbSelectArea( "TFJ" )
TFJ->( dbSetOrder( 5 ) )
TFJ->( DbSeek( xFilial("TFJ") + TFV->TFV_CONTRT + cCodRev ) )

While TFJ->( !Eof() ) .AND. xFilial("TFJ")+TFJ->TFJ_CONTRT+TFJ->TFJ_CONREV == xFilial("TFJ")+TFV->TFV_CONTRT+cCodRev

	If TFJ->TFJ_STATUS <> "1"
		TFJ->(dbSkip())
		Loop
	EndIf

	//=============================================================//
	// Recursos Humanos
	//=============================================================//
	nVlrTotal := 0
	nVlrExced := 0
	nVlrDesc  := 0

	// Verificar a apuração dos itens do RH
	BeginSql Alias cAliasTFW

		SELECT TFW.TFW_VLRMED, TFW.TFW_VLREXT, TFW_CODIGO
		  FROM %table:TFW% TFW
		 WHERE TFW.TFW_FILIAL = %xFilial:TFW%
		   AND TFW.TFW_APURAC = %Exp:cCodApu%
		   AND TFW.%NotDel%

	EndSql

	(cAliasTFW)->( DbGoTop() )
	While (cAliasTFW)->(!Eof())
		nVlrTotal += (cAliasTFW)->TFW_VLRMED
		nVlrExced += (cAliasTFW)->TFW_VLREXT

		If lFirst
			cCodPai := "%('" +  (cAliasTFW)->(TFW_CODIGO) + "'"
			lFirst := .F.
		Else
			cCodPai +=  ", '" + (cAliasTFW)->(TFW_CODIGO) + "'"
		EndIf
		(cAliasTFW)->(dbSkip())
	EndDo
	If !Empty(cCodPai)
		cCodPai +=  ")%"
	EndIf

	nVlrDesc := A930GetDsc(cCodPai,'RH')
	A930GetMB(cCodPai,'RH',@nVlrMulta,@nVlrBoni)

	aAdd(aRet,{ 1, { STR0007,TFJ->TFJ_GRPRH,Posicione("SB1",1,xFilial("SB1")+TFJ->TFJ_GRPRH,"B1_DESC"),nVlrTotal,nVlrExced,nVlrMulta,nVlrBoni,nVlrDesc}} )


	//=============================================================//
	// "Materiais de Implantação"
	//=============================================================//
	nVlrTotal := 0
	nVlrMulta	:= 0
	nVlrBoni := 0
	nVlrDesc := 0
	cCodPai := ""
	lFirst := .T.

	// Verificar a apuração dos materiais de implantação
	BeginSql Alias cAliasTFX

		SELECT TFX.TFX_VLRMED, TFX.TFX_CODIGO
		  FROM %table:TFX% TFX
		 WHERE TFX.TFX_FILIAL = %xFilial:TFX%
		   AND	TFX.TFX_APURAC = %Exp:cCodApu%
		   AND TFX.%NotDel%

	EndSql

	(cAliasTFX)->( DbGoTop() )
	While (cAliasTFX)->(!Eof())
		nVlrTotal += (cAliasTFX)->TFX_VLRMED

		If lFirst
			cCodPai := "%('" +  (cAliasTFX)->(TFX_CODIGO) + "'"
			lFirst := .F.
		Else
			cCodPai +=  ", '" + (cAliasTFX)->(TFX_CODIGO) + "'"
		EndIf

		(cAliasTFX)->(dbSkip())
	EndDo
	If !Empty(cCodPai)
		cCodPai +=  ")%"
	EndIf

	nVlrDesc := A930GetDsc(cCodPai,'MI')
	A930GetMB(cCodPai,'MI',@nVlrMulta,@nVlrBoni)

	aAdd(aRet,{2,{STR0008,TFJ->TFJ_GRPMI,Posicione("SB1",1,xFilial("SB1")+TFJ->TFJ_GRPMI,"B1_DESC"),nVlrTotal,0,nVlrMulta,nVlrBoni,nVlrDesc}} )


	//=============================================================//
	// "Materiais de Consumo"
	//=============================================================//
	nVlrTotal := 0
	nVlrMulta	:= 0
	nVlrBoni := 0
	nVlrDesc := 0
	cCodPai := ""
	lFirst := .T.

	// Verificar a apuração dos materiais de consumo
	BeginSql Alias cAliasTFY

		SELECT TFY.TFY_VLRMED, TFY.TFY_CODIGO
		  FROM %table:TFY% TFY
		 WHERE TFY.TFY_FILIAL = %xFilial:TFY%
		   AND TFY.TFY_APURAC = %Exp:cCodApu%
		   AND TFY.%NotDel%

	EndSql

	(cAliasTFY)->( DbGoTop() )
	While (cAliasTFY)->(!Eof())
		nVlrTotal += (cAliasTFY)->TFY_VLRMED
		If lFirst
			cCodPai := "%('" +  (cAliasTFY)->(TFY_CODIGO) + "'"
			lFirst := .F.
		Else
			cCodPai +=  ", '" + (cAliasTFY)->(TFY_CODIGO) + "'"
		EndIf

		(cAliasTFY)->(dbSkip())
	EndDo
	If !Empty(cCodPai)
		cCodPai += ")%"
	EndIf

	nVlrDesc := A930GetDsc(cCodPai,'MC')
	A930GetMB(cCodPai,'MC',@nVlrMulta,@nVlrBoni)

	aAdd(aRet,{3,{STR0009,TFJ->TFJ_GRPMC,Posicione("SB1",1,xFilial("SB1")+TFJ->TFJ_GRPMC,"B1_DESC"),nVlrTotal,0,nVlrMulta,nVlrBoni,nVlrDesc}} )


	//=============================================================//
	// "Locação de Equipamentos"
	//=============================================================//
	nVlrTotal := 0
	nVlrMulta	:= 0
	nVlrBoni := 0
	nVlrDesc := 0
	cCodPai := ""
	lFirst := .T.

	// Verificar a apuração das alocações de equipamentos
	BeginSql Alias cAliasTFZ

		SELECT TFZ.TFZ_TOTAL, TFZ_CODTFI
		  FROM %table:TFZ% TFZ
		 WHERE TFZ.TFZ_FILIAL = %xFilial:TFZ%
		   AND TFZ.TFZ_APURAC = %Exp:cCodApu%
		   AND TFZ.%NotDel%

	EndSql

	(cAliasTFZ)->( DbGoTop() )
	While (cAliasTFZ)->(!Eof())
		nVlrTotal += (cAliasTFZ)->TFZ_TOTAL
		If lFirst
			cCodPai := "%('" +  (cAliasTFZ)->(TFZ_CODTFI) + "'"
			lFirst := .F.
		Else
			cCodPai +=  ", '" + (cAliasTFZ)->(TFZ_CODTFI) + "'"
		EndIf

		(cAliasTFZ)->(dbSkip())
	EndDo

	If !Empty(cCodPai)
		cCodPai +=  ")%"
	EndIf

	nVlrDesc := A930GetDsc(cCodPai,'LE')
	A930GetMB(cCodPai,'LE',@nVlrMulta,@nVlrBoni)

	aAdd(aRet,{4,{STR0010,TFJ->TFJ_GRPLE,Posicione("SB1",1,xFilial("SB1")+TFJ->TFJ_GRPLE,"B1_DESC"),nVlrTotal,0,nVlrMulta,nVlrBoni,nVlrDesc}} )

	If Select(cAliasTFW) > 0
		(cAliasTFW)->(dbCloseArea())
	EndIf

	If Select(cAliasTFX) > 0
		(cAliasTFX)->(dbCloseArea())
	EndIf

	If Select(cAliasTFY) > 0
		(cAliasTFY)->(dbCloseArea())
	EndIf

	If Select(cAliasTFZ) > 0
		(cAliasTFZ)->(dbCloseArea())
	EndIf

	TFJ->( DbSkip() )

EndDo

TFJ->(DbCloseArea())

Return(aRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At930GerMed
Função para geração das medições do contrato
@sample 	At930GerMed()
@param		nenhum
@return	Nil
@author	Serviços
@since		04/11/2013
@version	P11.9
/*/
//------------------------------------------------------------------------------
Function At930GerMed(cAlias, nReg, nOpc, lAutomato, lMedFora, lExcedente, lApurHE)
Local lPergunte	:= .T.
Local nOperacao := If(nOpc <> 3, MODEL_OPERATION_INSERT, MODEL_OPERATION_DELETE )
Local cCodContrt := ' '
Local cContRevis := ' '
Local lExistPerg := FindFunction("TecHasPerg") .AND. TecHasPerg('MV_PAR01','TEC930HE')

Default lAutomato	:= .F.
Default lMedFora	:= .T.
Default lExcedente := .F.
Default lApurHE := .F.

If lApurHE .AND. !lExistPerg 
	Help(,,'At930GerMed',,STR0217,1,0) // "Para usar esta opção crie o Pergunte TEC930HE, conforme indicado na documentação técnica desta funcionalidade."
	lPergunte:= .F.
EndIf

lMedExt := (nOpc == 2)

If lApurHE 
	lPergunte := lPergunte .AND. (nOpc == 3 .Or. Pergunte("TEC930HE",.T.))	
Else
	lPergunte := lPergunte .AND. (nOpc == 3 .Or. Pergunte("TEC930",.T.))
EndIf

If lPergunte .Or. lAutomato
	cMV_PAR04 := MV_PAR04
	cCodContrt := IIf( nOpc == 3, TFV->TFV_CONTRT, MV_PAR01 )
	cContRevis := Posicione("CN9",7,xFilial("CN9")+cCodContrt+"05","CN9_REVISA")
	// ---------------
	// Devolve a ordem 1 para a tabela CN9
	CN9->( DbSetOrder( 1 ) ) // CN9_FILIAL+CN9_NUMERO+CN9)REVISA

	If At930VldCont( cCodContrt, cContRevis )
		If !lAutomato
			If !lMedFora
				lMedExt := !lMedFora
				At930Fora(nOperacao)
			ElseIf lExcedente
				At930Exce(nOperacao)
			ElseIf lApurHE
				At930ApuHE(nOperacao)
			Else
				MsgRun( STR0074, STR0073, {|| FWExecView(STR0002,"VIEWDEF.TECA930",nOperacao,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/) } ) // 'Processando Apuração  ' #### 'Aguarde...' #### "Geração"
			EndIf
		EndIf
	EndIf
Endif

cMV_PAR04 := ""

Return(Nil)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At930VldCont
Função para geração das medições do contrato
@sample 	At930VldCont(cContrato)
@param		cContrato - Numero do contrato qual deseja validar
@return	Nil
@author	Serviços
@since		04/11/2013
@version	P11.9
/*/
//------------------------------------------------------------------------------
Function At930VldCont( cContrato, cRevisao )
Local aArea 		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet 			:= .T.
Local cAliasTFJ 	:= ""

If (Posicione("CN9",1,xFilial("CN9")+cContrato+cRevisao,"CN9_SITUAC") == "05")

	cAliasTFJ := GetNextAlias()
	//Verifica se o orçamento/contrato esta em processo de revisão

	BeginSQL Alias cAliasTFJ
		SELECT	TFJ.TFJ_CODIGO
		FROM 	%table:TFJ% TFJ
		WHERE 	TFJ.TFJ_FILIAL = %xFilial:TFJ% AND
				TFJ.TFJ_CONTRT = %exp:cContrato% AND
				TFJ.%NotDel% AND
				TFJ.TFJ_STATUS IN ('2','4') // DEF_TFJ_EMREVISAO, DEF_TFJ_AGDAPROVA
	EndSQL

	If (cAliasTFJ)->(!EOF())
		lRet := .F.
		Help( "", 1, "AT930VLDCONT1", , STR0112, 1, 0,,,,,,;  //"O contrato possui revisão em andamento para efetivação ou aprovação."
					{STR0113}) // "Termine o processo de revisão para realizar a apuração."
	EndIf
	(cAliasTFJ)->(dbCloseArea())
Else
	lRet := .F.
	Help(" ", 1, "AT930VLDCONT")
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados
Inicializa as informações de status dos contratos
@sample 	InitDados()
@param  	oMdlGer, Objeto, objeto geral do model que será alterado
@return	Nil
@author 	Serviços
@since		28/10/2013
@version	P11.90
/*/
//------------------------------------------------------------------------------
Static Function InitDados(oMdlGer)

Local oMdlTFV	:= oMdlGer:GetModel("TFVMASTER")
Local oStrTFITW6	:= oMdlGer:GetModel('TFITW6DETAIL'):GetStruct()
Local oStrucTFV		:= oMdlTFV:GetStruct()
Local aSaveRows := {}
Local cRevCtr := ""
Local cTFJ := ""
Local oStrTFX	:= oMdlGer:GetModel('TFXDETAIL'):GetStruct()
Local oStrTFY	:= oMdlGer:GetModel('TFYDETAIL'):GetStruct()
Local oStrTFW	:= oMdlGer:GetModel('TFWDETAIL'):GetStruct()

aSaveRows := FwSaveRows()

If oMdlGer:GetOperation() == 3

	cRevCtr := Posicione("CN9",7,xFilial("CN9")+MV_PAR01+"05","CN9_REVISA")

	oMdlTFV:SetValue( "TFV_CONTRT", MV_PAR01  )
	oMdlTFV:SetValue( "TFV_REVISA", cRevCtr  )
	oMdlTFV:SetValue( "TFV_DTINI" , MV_PAR02  )
	oMdlTFV:SetValue( "TFV_DTFIM" , MV_PAR03  )
	oMdlTFV:SetValue( "TFV_DTAPUR", dDataBase )

	DbSelectArea("TFJ")
	TFJ->( DbSetOrder( 5 ) )  // TFJ_FILIAL + TFJ_CONTRT + TFJ_CONREV
	TFJ->( DbSeek( xFilial("TFJ") + MV_PAR01 + cRevCtr ) )
	cTFJ := TFJ->TFJ_CODIGO
	oMdlTFV:SetValue( "TFV_ANTECI", If( TFJ->TFJ_ANTECI=="1", "1", "2" ) )

	// carrega primeiro os locais
	At930ResLoc( oMdlGer, MV_PAR01, cRevCtr )
	At930LoadMat()
	At930CaRH(MV_PAR01)
	
	If !lMedExt .OR. lMedExce .OR. lApuraHE//Até o momento não existe LE como Item Extra
		At930LoEq(MV_PAR01,oMdlGer)
	EndIf
	At930GridZZP(oMdlGer)
	At930TrgGer( 'TFLDETAIL', 'TFL_VALTOT', 'ZZPDETAIL', 'ZZP_VLRTOT', 4 )
	If TecBHasCrn() .AND. !lMedExt .AND. TecBHasExc() .AND. !At740Recor(MV_PAR01) .AND. lMedExce
		oMdlTFV:LoadValue("TFV_TOTEXC", GetTotExce(cTFJ, MV_PAR04))
	EndIf
	If TecBHasTpA()
		oMdlTFV:LoadValue("TFV_TIPO", "1")
		If isInCallStack("At930Fora")
			oMdlTFV:LoadValue("TFV_TIPO", "2")
		EndIf
		If lMedExce
			oMdlTFV:LoadValue("TFV_TIPO", "3")
		EndIF
		If lApuraHE
			oMdlTFV:LoadValue("TFV_TIPO", "4")
			oMdlTFV:LoadValue("TFV_HREXTR", "2")
		EndIf
	EndIf
Else

	At970SetHm()	// Inicializa os valores de medição/apuração de horimetro

	cRevCtr  := Posicione("CN9",7,xFilial("CN9")+oMdlTFV:GetValue("TFV_CONTRT")+"05","CN9_REVISA")
	MV_PAR01 := oMdlTFV:GetValue("TFV_CONTRT")
	MV_PAR02 := oMdlTFV:GetValue("TFV_DTINI")
	MV_PAR03 := oMdlTFV:GetValue("TFV_DTFIM")

EndIf

// Carrega os dados para a aba de resumo dos locais
If	oMdlGer:GetOperation() == MODEL_OPERATION_VIEW   .OR.;
	oMdlGer:GetOperation() == MODEL_OPERATION_INSERT .OR.;
	oMdlGer:GetOperation() == MODEL_OPERATION_UPDATE

	At930ResView( oMdlGer, MV_PAR01, oMdlTFV:GetValue("TFV_REVISA"), oMdlGer:GetOperation() )
EndIf

FwRestRows( aSaveRows )

oMdlGer:GetModel("ZZPDETAIL"):SetNoInsertLine(.T.)

oMdlGer:GetModel("TFWDETAIL"):SetNoInsertLine(.T.)
oMdlGer:GetModel("TFWDETAIL"):SetNoDeleteLine(.T.)

oMdlGer:GetModel("TFXDETAIL"):SetNoInsertLine(.T.)
oMdlGer:GetModel("TFXDETAIL"):SetNoDeleteLine(.T.)

oMdlGer:GetModel("TFYDETAIL"):SetNoInsertLine(.T.)
oMdlGer:GetModel("TFYDETAIL"):SetNoDeleteLine(.T.)

oMdlGer:GetModel("TFIPRODUT"):SetNoInsertLine(.T.)
oMdlGer:GetModel("TFIPRODUT"):SetNoDeleteLine(.T.)

oMdlGer:GetModel("TFLDETAIL"):SetNoInsertLine(.T.)
oMdlGer:GetModel("TFLDETAIL"):SetNoDeleteLine(.T.)

oMdlGer:GetModel("TFZDETAIL"):SetNoInsertLine(.T.)
oMdlGer:GetModel("TFZDETAIL"):SetNoDeleteLine(.T.)

oStrTFITW6:SetProperty("TW6_VALOR", MODEL_FIELD_OBRIGAT, .F.)

If lMedExce .OR. lApuraHE
	oStrucTFV:SetProperty("TFV_HREXTR", MODEL_FIELD_OBRIGAT, .F.)
	oStrTFX:SetProperty("TFX_VLRMED", MODEL_FIELD_WHEN, {|| .F.})
	oStrTFY:SetProperty("TFY_VLRMED", MODEL_FIELD_WHEN, {|| .F.})
	oStrTFW:SetProperty("TFW_VLRMED", MODEL_FIELD_WHEN, {|| .F.})
	oStrTFW:SetProperty("TFW_VLREXT", MODEL_FIELD_WHEN, {|| .F.})
EndIf

If oMdlGer:GetOperation() == MODEL_OPERATION_VIEW
	oMdlGer:lModify := .F.
EndIf

Return(Nil)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At930DetRH
Tela de detalhes das informações adicionais dos Recursos Humanos utilizados no contrato
@sample 	At930DetRH()
@return	Nil
@author 	Serviços
@since		06/11/2013
@version	P11.90
/*/
//------------------------------------------------------------------------------
Static Function At930DetRH(lAutomato)

Local cTitulo	  := STR0012 // "Detalhe "

Local oOk					//Objeto Confirma
Local oTop 				//Objeto Panel
Local oSup1
Local oInf1
Local oSup2
Local oInf2
Local oBottom
Local oPanel
Local oDlgCmp
Local oFolder
Local aFolder	:= {STR0013,STR0014}  // "Horas" # "Horas Extras"
Local oListBox			//Grid campos Horas
Local oListBox2			//Grid campos Horas Extras
Local oListBox3			//Grid campos Horas Extras totalizador
Local aCmpDet	  := {}
Local aCmpHrE	  := {}
Local aCmpOsE   := {}
Local aRetDet   := {}
Local oModel	  := FWModelActive()
Local oModelTFW := oModel:GetModel("TFWDETAIL")
Local cIdApur   := ""
Local lGsGerOS  := At930GerOs()
Default lAutomato := .F.

If oModelTFW:GetOperation() == MODEL_OPERATION_DELETE .Or. oModelTFW:GetOperation() == MODEL_OPERATION_VIEW // Estorno da apuracao
	cIdApur := FwFldGet("TFV_CODIGO")
EndIf

cTitulo += STR0007 // "Recursos Humanos"

// Processamento de todos os dados do detalhe do recurso humano
aRetDet := At930QDetRH( MV_PAR01, MV_PAR02, MV_PAR03,;
						  FwFldGet("TFW_CODTFF"), FwFldGet("TFW_CODTFL"), cIdApur )

aCmpDet := aRetDet[1][1] // O.S. Horas normais
aCmpOsE := aRetDet[1][2] // O.S. Horas extras
aCmpHrE := aRetDet[1][3] // Total hora extra por motivo

If Len(aCmpHrE) = 0
	aAdd(aCmpHrE, {"","","","",""})
EndIf

If Len(aCmpOsE) = 0
	aAdd(aCmpOsE, {"","","","","","","","","","","","","","","",""})
EndIf

If !Empty(aCmpDet)

	If !lAutomato //se for robô de testes não cria a janela

		//	Cria a tela para a pesquisa dos campos e define a area a ser utilizada na tela
		Define MsDialog oDlgCmp TITLE cTitulo FROM 000, 000 To 600, 1100 Pixel

		// Cria o panel as informaçoes do local e total
		@ 000, 000 MsPanel oTop Of oDlgCmp Size 000, 040 // Coordenada para o panel
		oTop:Align := CONTROL_ALIGN_TOP //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)

		@ 005,005 SAY STR0015 OF oTop PIXEL SIZE 120,9  // "Contrato"
		@ 015,005 MsGet aCmpDet[1][09] OF oTop SIZE 60,10 PIXEL WHEN .F.
		@ 005,075 SAY STR0016 OF oTop PIXEL SIZE 120,9 // "Revisão"
		@ 015,075 MsGet aCmpDet[1][10] OF oTop SIZE 20,10 PIXEL WHEN .F.
		@ 005,105 SAY STR0004 OF oTop PIXEL SIZE 120,9 // "Local"
		@ 015,105 MsGet aCmpDet[1][11] OF oTop SIZE 40,10 PIXEL WHEN .F.
		@ 005,155 SAY STR0005 OF oTop PIXEL SIZE 120,9 // "Descrição"
		@ 015,155 MsGet aCmpDet[1][12] OF oTop SIZE 190,10 PIXEL WHEN .F.

		oFolder	:=	TFolder():New(0,0,aFolder,aFolder,oDlgCmp,,,,.T., , 354, 200)
		oFolder:Align := CONTROL_ALIGN_ALLCLIENT

		@ 000, 000 MsPanel oSub1 Of oFolder:aDialogs[1] Size 000,040
		oSub1:Align := CONTROL_ALIGN_TOP

		@ 005,005 SAY STR0017 OF oSub1 PIXEL SIZE 60,9 // "Horas Normais:"
		@ 015,005 MsGet FWFLDGET("TFW_HORAN") OF oSub1 SIZE 60,10 PIXEL WHEN .F.

		@ 005,075 SAY STR0018 OF oSub1 PIXEL SIZE 60,9 // "Valor Hr Normal:"
		@ 015,075 MsGet FWFLDGET("TFW_VLHORN") OF oSub1 SIZE 60,10 PICTURE "@E 9,999,999,999.99" PIXEL WHEN .F.

		@ 005,145 SAY STR0019 OF oSub1 PIXEL SIZE 60,9 // "Horas Extras:"
		@ 015,145 MsGet FWFLDGET("TFW_HORAE") OF oSub1 SIZE 60,10 PIXEL WHEN .F.

		@ 005,215 SAY STR0020 OF oSub1 PIXEL SIZE 60,9 // "Valor Hr Extra"
		@ 015,215 MsGet FWFLDGET("TFW_VLHORE") OF oSub1 SIZE 60,10 PICTURE "@E 9,999,999,999.99" PIXEL WHEN .F. //FWFLDGET REALMENTE ATENDE?

		@ 050, 000 MsPanel oInf1 Of oFolder:aDialogs[1] Size 000,030
		oInf1:Align := CONTROL_ALIGN_ALLCLIENT
		If lGsGerOS
			// Criação do grid para o panel
			oListBox := TWBrowse():New(000,000,000,000,,{STR0021,STR0022,STR0023,STR0024,STR0025,STR0026,STR0027,STR0028,;
															STR0029,STR0030},,oInf1,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
															// "OS"#"Seq"#"Horas"#"Data Emissão"#"Data Chegada"#"Hora Chegada"#
															//"Data Saída"#"Hora Saída"#"Cód. Atendente"#"Atendente"
		Else
			// Criação do grid para o panel
			oListBox := TWBrowse():New(000,000,000,000,,{STR0023,STR0025,STR0026,STR0027,STR0028,;
															STR0029,STR0030},,oInf1,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
															//"Horas"#"Data Chegada"#"Hora Chegada"#
															//"Data Saída"#"Hora Saída"#"Cód. Atendente"#"Atendente"

		Endif

		oListBox:SetArray(aCmpDet) // Atrela os dados do grid com a matriz
		
		If lGsGerOS
			oListBox:bLine := { ||{aCmpDet[oListBox:nAT][1],;
									aCmpDet[oListBox:nAT][2],;
									aCmpDet[oListBox:nAT][3],;
									aCmpDet[oListBox:nAT][4],;
									aCmpDet[oListBox:nAT][5],;
									aCmpDet[oListBox:nAT][6],;
									aCmpDet[oListBox:nAT][7],;
									aCmpDet[oListBox:nAT][8],;
									aCmpDet[oListBox:nAT][13],;
									aCmpDet[oListBox:nAT][14]}} // Indica as linhas do grid
		Else
			oListBox:bLine := { ||{ aCmpDet[oListBox:nAT][3],;
									aCmpDet[oListBox:nAT][5],;
									aCmpDet[oListBox:nAT][6],;
									aCmpDet[oListBox:nAT][7],;
									aCmpDet[oListBox:nAT][8],;
									aCmpDet[oListBox:nAT][13],;
									aCmpDet[oListBox:nAT][14]}} // Indica as linhas do grid
		Endif
		
		oListBox:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do browse

		@ 000, 000 MsPanel oSub2 Of oFolder:aDialogs[2] Size 000,100
		oSub2:Align := CONTROL_ALIGN_TOP

		// Criação do grid do totalizador de horas extas
		oListBox3 := TWBrowse():New(000,000,000,000,,{STR0031,STR0032,STR0023,STR0054,STR0034},,oSub2,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
													      // "Motivo"#"Descrição"#"Horas"#"Valor Hora"#"Valor"

		oListBox3:SetArray(aCmpHrE) // Atrela os dados do grid com a matriz
		oListBox3:bLine := { ||{aCmpHrE[oListBox3:nAT][1],;
								  aCmpHrE[oListBox3:nAT][2],;
								  aCmpHrE[oListBox3:nAT][3],;
								  aCmpHrE[oListBox3:nAT][4],;
								  aCmpHrE[oListBox3:nAT][5]}} // Indica as linhas do grid
		oListBox3:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do browse

		@ 050, 000 MsPanel oInf2 Of oFolder:aDialogs[2] Size 000,030
		oInf2:Align := CONTROL_ALIGN_ALLCLIENT

		If lGsGerOS
			// Criação do grid para o panel
			oListBox2 := TWBrowse():New(000,000,000,000,,{ STR0021,STR0022,STR0031,STR0032,STR0023,STR0024,STR0025,STR0026,STR0027,STR0028,;
															STR0029,STR0030},,oInf2,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
															// "OS"#"Seq"#"Horas"#"Data Emissão"#"Data Chegada"#"Hora Chegada"#
															//"Data Saída"#"Hora Saída"#"Cód. Atendente"#"Atendente"
		Else
			// Criação do grid para o panel
			oListBox2 := TWBrowse():New(000,000,000,000,,{ STR0031,STR0032,STR0023,STR0025,STR0026,STR0027,STR0028,;
															STR0029,STR0030},,oInf2,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
															// "OS"#"Seq"#"Horas"#"Data Emissão"#"Data Chegada"#"Hora Chegada"#
															//"Data Saída"#"Hora Saída"#"Cód. Atendente"#"Atendente"
		Endif
		oListBox2:SetArray(aCmpOsE) // Atrela os dados do grid com a matriz
		If lGsGerOS
			oListBox2:bLine := { ||{aCmpOsE[oListBox2:nAT][1],;
									aCmpOsE[oListBox2:nAT][2],;
									aCmpOsE[oListBox2:nAT][3],;
									aCmpOsE[oListBox2:nAT][4],;
									aCmpOsE[oListBox2:nAT][5],;
									aCmpOsE[oListBox2:nAT][6],;
									aCmpOsE[oListBox2:nAT][7],;
									aCmpOsE[oListBox2:nAT][8],;
									aCmpOsE[oListBox2:nAT][9],;
									aCmpOsE[oListBox2:nAT][10],;
									aCmpOsE[oListBox2:nAT][15],;
									aCmpOsE[oListBox2:nAT][16]}} // Indica as linhas do grid
		Else
			oListBox2:bLine := { ||{aCmpOsE[oListBox2:nAT][3],;
									aCmpOsE[oListBox2:nAT][4],;
									aCmpOsE[oListBox2:nAT][5],;
									aCmpOsE[oListBox2:nAT][7],;
									aCmpOsE[oListBox2:nAT][8],;
									aCmpOsE[oListBox2:nAT][9],;
									aCmpOsE[oListBox2:nAT][10],;
									aCmpOsE[oListBox2:nAT][15],;
									aCmpOsE[oListBox2:nAT][16]}} // Indica as linhas do grid
		Endif
		oListBox2:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do browse

		// Cria o panel para o botao OK
		@ 000, 000 MsPanel oBottom Of oDlgCmp Size 000, 012 // Corrdenada para o panel dos botoes (size)
		oBottom:Align := CONTROL_ALIGN_BOTTOM //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)

		// Botao de acao OK
		@ 000, 000 Button oOk Prompt STR0035  Of oBottom Size 030, 000 Pixel //"Ok"
		oOk:bAction := { || oDlgCmp:End() }
		oOk:Align   := CONTROL_ALIGN_RIGHT

		// Ativa a tela exibindo conforme a coordenada
		Activate MsDialog oDlgCmp Centered
	EndIf
Else

	Help(" ", 1, "AT930DETRH")

EndIf
Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} At930DetMat
Tela de detalhes das informações adicionais dos materiais utilizados no contrato
@sample 	At930DetMat(nTipo,cCodRel)
@param  	nTipo   - 1 = Materiais de Implantacao / 2 = Materiais de Consumo
@param  	cCodRel - Codigo do relacionamento para levantamentos dos dados adicionais
			dos produtos.
@return	Nil
@author 	Serviços
@since		06/11/2013
@version	P11.90
/*/
//------------------------------------------------------------------------------
Static Function At930DetMat(nTipo,cCodRel, lAutomato)

Local aOldArea	:= GetArea()
Local cAliasMat	:= GetNextAlias()
Local aCmpDet		:= {}
Local oModel		:= FwModelActive()
Local cTitulo		:= STR0012 // "Detalhe "
Local cLocal		:= ""
Local cIdApur		:= ""
Local cCodTFF		:= ""
Local cWhereCob	:= ""
Local nTotalApu
Local oListBox			//Grid campos
Local oOk					//Objeto Confirma
Local oTop 				//Objeto Panel
Local oMiddle
Local oBottom
Local oDlgCmp
Local cRevCtr		:= Posicione("CN9",7,xFilial("CN9")+MV_PAR01+"05","CN9_REVISA")
Local aAreaTFJ		:= TFJ->(GetArea())
Local lCodTab		:= .F.
Local cWhereTab		:= ""
Local cExecJoin := '1'
Default cCodRel := ""
Default lAutomato := .F.

If oModel:GetOperation() == 5 // Estorno da apuracao
	cIdApur := FwFldGet("TFV_CODIGO")
EndIf


TFJ->(DbSetOrder( 5 )) //TFL_FILIAL+TFJ_CONTRT+TFJ_CONREV

lCodTab := TFJ->(DbSeek(xFilial("TFJ")+PadR( MV_PAR01, TamSx3("TFJ_CONTRT")[1]) +cRevCtr) ) .And. ; // posiciona no cabeçalho do orçamento de serviços
					!Empty(TFJ->TFJ_TABXML) .OR. !Empty(TFJ->TFJ_CODTAB)  // verifica se é orçamento com precificação

If nTipo == 1 // Materiais de implantacao

	cLocal    := FwFldGet("TFX_LOCAL")
	nTotalApu := FwFldGet("TFX_VLRAPU")
	cCodTFF   := FwFldGet("TFX_CODTFF")
	cTitulo 	+= STR0008 // "Materiais de implantacao"

	If lMedExt
		cWhereCob := "%TFL.TFL_CONTRT = '" + MV_PAR01 + "' AND "
		cWhereCob += "TFL.TFL_CONREV = '" + cRevCtr + "' AND "
		cWhereCob += "TFG.TFG_COBCTR = '2' AND TFG.TFG_PRCVEN > 0%"
	Else
		cWhereCob := "%TFF.TFF_CONTRT = '" + MV_PAR01 + "' AND "
		cWhereCob += "TFF.TFF_CONREV = '" + cRevCtr + "' AND "
	 	cWhereCob += "TFG.TFG_COBCTR <> '2' %"
	EndIf

	cWhereTab := "%TFF.TFF_COD = TFG.TFG_CODPAI " +;
	             " AND TFF.TFF_COD = '" + cCodTFF + "'%"
	If lCodTab
		cWhereTab := "%TFF.TFF_CODPAI = TFG.TFG_CODPAI%"
		cExecJoin := '2'
		
		cWhereCob := "%TFG.TFG_CONTRT = '" + MV_PAR01 + "' AND "
		cWhereCob += "TFG.TFG_CONREV = '" + cRevCtr + "' AND "
		cWhereCob += "TFG.TFG_LOCAL = '" + cLocal + "' AND "
	 	cWhereCob += "TFG.TFG_COBCTR <> '2' %"
	EndIf

	BeginSql Alias cAliasMat

		SELECT TFF.TFF_CONTRT CONTRT, TFF.TFF_CONREV CONREV, TFF.TFF_LOCAL LOCCONT, ABS.ABS_DESCRI DESCLOC,
		       TFS.TFS_DTAPON DTAPON, TFG.TFG_PRODUT PRODUT, SB1.B1_DESC DESCP,     TFS.TFS_QUANT QUANT,
		       TFG.TFG_PRCVEN PRCVEN, TFG.TFG_CONTRT CONT_MAT, TFG.TFG_CONREV REV_MAT, 
		       ( TFS.TFS_QUANT *
		         ( TFG.TFG_PRCVEN -
		             (((TFG.TFG_PRCVEN * TFG.TFG_DESCON)/100)) +
		             ((TFG.TFG_PRCVEN * TFG.TFG_LUCRO)/100) +
		             ((TFG.TFG_PRCVEN * TFG.TFG_ADM)/100) ) ) VLR_TOTAL
		  FROM %table:TFS% TFS
		       JOIN %table:TFG% TFG ON TFG.TFG_FILIAL = %xFilial:TFG%
		                           AND TFS.TFS_CODTFG = TFG.TFG_COD
		                           AND TFG.%NotDel%
		       LEFT JOIN %table:SB1% SB1 ON SB1.B1_FILIAL = %xFilial:SB1%
		                                AND SB1.B1_COD = TFG.TFG_PRODUT
		                                AND SB1.%NotDel%
		       LEFT JOIN %table:TFF% TFF ON TFF.TFF_FILIAL = %xFilial:TFF%
		                                AND %Exp:cWhereTab%
		                                AND TFF.%NotDel%
		                                AND '1' = %Exp:cExecJoin%
		                                AND TFF.TFF_LOCAL = %Exp:cLocal%
		       LEFT JOIN %table:ABS% ABS ON ABS.ABS_FILIAL = %xFilial:ABS%
		                                AND ABS.ABS_LOCAL = TFF.TFF_LOCAL
		                                AND ABS.%NotDel%
		       LEFT JOIN %table:TFL% TFL ON TFL.TFL_FILIAL = %xFilial:TFL%
		                                AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
		                                AND TFL.TFL_CONTRT = %Exp:MV_PAR01%
		                                AND TFL.TFL_CONREV = %Exp:cRevCtr%
		                                AND TFL.%NotDel%
		 WHERE TFS.TFS_FILIAL = %xFilial:TFS%
		   AND TFS.TFS_ITAPUR = %Exp:cIdApur%
		   AND TFS.TFS_DTAPON >= %Exp:MV_PAR02%
		   AND TFS.TFS_DTAPON <= %Exp:MV_PAR03%
		   AND TFS.%NotDel%
		   AND %Exp:cWhereCob%

	EndSql

ElseIf nTipo == 2 // Materiais de consumo

	cLocal    := FwFldGet("TFY_LOCAL")
	nTotalApu := FwFldGet("TFY_VLRAPU")
	cCodTFF   := FwFldGet("TFY_CODTFF")
	cTitulo 	+= STR0009 // "Materiais de consumo"

	If lMedExt
		cWhereCob := "%TFL.TFL_CONTRT = '" + MV_PAR01 + "' AND "
		cWhereCob += "TFL.TFL_CONREV = '" + cRevCtr + "' AND "
		cWhereCob += "TFH.TFH_COBCTR = '2' AND TFH.TFH_PRCVEN > 0%"
	Else
		cWhereCob := "%TFF.TFF_CONTRT = '" + MV_PAR01 + "' AND "
		cWhereCob += "TFF.TFF_CONREV = '" + cRevCtr + "' AND "
 		cWhereCob += "TFH.TFH_COBCTR <> '2' %"
	EndIf



	cWhereTab := "%TFF.TFF_COD = TFH.TFH_CODPAI " +;
	             " AND TFF.TFF_COD = '" + cCodTFF + "'%"

	If lCodTab
		cWhereTab := "%TFF.TFF_CODPAI = TFH.TFH_CODPAI%"
		cExecJoin := '2'
		
		cWhereCob := "%TFH.TFH_CONTRT = '" + MV_PAR01 + "' AND "
		cWhereCob += "TFH.TFH_CONREV = '" + cRevCtr + "' AND "
		cWhereCob += "TFH.TFH_LOCAL = '" + cLocal + "' AND "
 		cWhereCob += "TFH.TFH_COBCTR <> '2' %"
	EndIf

	BeginSql Alias cAliasMat

		SELECT TFF.TFF_CONTRT CONTRT, TFF.TFF_CONREV CONREV, TFF.TFF_LOCAL LOCCONT, ABS.ABS_DESCRI DESCLOC,
		       TFT.TFT_DTAPON DTAPON, TFH.TFH_PRODUT PRODUT, SB1.B1_DESC DESCP,     TFT.TFT_QUANT QUANT,
		       TFH.TFH_PRCVEN PRCVEN, TFH.TFH_CONTRT CONT_MAT, TFH.TFH_CONREV REV_MAT, 
		       ( TFT.TFT_QUANT *
		         ( TFH.TFH_PRCVEN -
		             (((TFH.TFH_PRCVEN * TFH.TFH_DESCON)/100)) +
		             ((TFH.TFH_PRCVEN * TFH.TFH_LUCRO)/100) +
		             ((TFH.TFH_PRCVEN * TFH.TFH_ADM)/100) ) ) VLR_TOTAL
		  FROM %table:TFT% TFT
		       JOIN %table:TFH% TFH ON TFH.TFH_FILIAL = %xFilial:TFH%
		                           AND TFT.TFT_CODTFH = TFH.TFH_COD
		                           AND TFH.%NotDel%
		       LEFT JOIN %table:SB1% SB1 ON SB1.B1_FILIAL = %xFilial:SB1%
		                                AND SB1.B1_COD = TFH.TFH_PRODUT
		                                AND SB1.%NotDel%
		       LEFT JOIN %table:TFF% TFF ON TFF.TFF_FILIAL = %xFilial:TFF%
		                                AND  %Exp:cWhereTab%
		                                AND TFF.%NotDel%
		                                AND '1' = %Exp:cExecJoin%
		                                AND TFF.TFF_LOCAL = %Exp:cLocal%
		       LEFT JOIN %table:ABS% ABS ON ABS.ABS_FILIAL = %xFilial:ABS%
		                                AND ABS.ABS_LOCAL = TFF.TFF_LOCAL
		                                AND ABS.%NotDel%
		       LEFT JOIN %table:TFL% TFL ON TFL.TFL_FILIAL = %xFilial:TFL%
		                                AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
		                                AND TFL.TFL_CONTRT = %Exp:MV_PAR01%
		                                AND TFL.TFL_CONREV = %Exp:cRevCtr%
		                                AND TFL.%NotDel%
		 WHERE TFT.TFT_FILIAL = %xFilial:TFT%
		   AND TFT.TFT_ITAPUR = %Exp:cIdApur%
		   AND TFT.TFT_DTAPON >= %Exp:MV_PAR02%
		   AND TFT.TFT_DTAPON <= %Exp:MV_PAR03%
		   AND TFT.%NotDel%
		   AND %Exp:cWhereCob%

	EndSql

EndIf

While (cAliasMat)->(!Eof())

	aAdd( aCmpDet, { StoD((cAliasMat)->DTAPON), (cAliasMat)->PRODUT,;
					   (cAliasMat)->DESCP,   (cAliasMat)->QUANT,;
					   (cAliasMat)->PRCVEN,  (cAliasMat)->VLR_TOTAL,;
					   IIF(EMPTY((cAliasMat)->CONTRT),(cAliasMat)->CONT_MAT,(cAliasMat)->CONTRT),;
					   IIF(EMPTY((cAliasMat)->CONTRT),(cAliasMat)->REV_MAT,(cAliasMat)->CONREV),;
					   (cAliasMat)->LOCCONT, (cAliasMat)->DESCLOC  } )

	(cAliasMat)->(dbSkip())

EndDo

If Len(aCmpDet) > 0

	If !lAutomato
		//	Cria a tela para a pesquisa dos campos e define a area a ser utilizada na tela
		Define MsDialog oDlgCmp TITLE cTitulo FROM 000, 000 To 450, 700 Pixel

		// Cria o panel as informaçoes do local e total
		@ 000, 000 MsPanel oTop Of oDlgCmp Size 000, 070 // Coordenada para o panel
		oTop:Align := CONTROL_ALIGN_TOP //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)

		@ 005,005 SAY STR0015 OF oTop PIXEL SIZE 120,9 // "Contrato"
		@ 015,005 MsGet aCmpDet[1][07] OF oTop SIZE 60,10 PIXEL WHEN .F.
		@ 005,075 SAY STR0016 OF oTop PIXEL SIZE 120,9 // "Revisão"
		@ 015,075 MsGet aCmpDet[1][08] OF oTop SIZE 20,10 PIXEL WHEN .F.
		@ 005,105 SAY STR0004 OF oTop PIXEL SIZE 120,9 // "Local"
		@ 015,105 MsGet aCmpDet[1][09] OF oTop SIZE 40,10 PIXEL WHEN .F.
		@ 005,155 SAY STR0005 OF oTop PIXEL SIZE 120,9 // "Descrição"
		@ 015,155 MsGet aCmpDet[1][10] OF oTop SIZE 190,10 PIXEL WHEN .F.

		@ 035,005 SAY STR0036 OF oTop PIXEL SIZE 120,9 // "Total apurado"
		@ 045,005 MsGet nTotalApu OF oTop SIZE 60,10 PICTURE "@E 9,999,999,999.99" PIXEL WHEN .F.

		// Cria o panel o browse dos itens dos materiais
		@ 000, 000 MsPanel oMiddle Of oDlgCmp Size 000, 150 // Coordenada para o panel
		oMiddle:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)

		// Criação do grid para o panel
		oListBox := TWBrowse():New(000,000,000,000,,{STR0037,STR0038,STR0005,STR0039,STR0040,;
														   STR0041},,oMiddle,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
													      //"Data"#"Produto"#"Descrição"#"Quant."#"Vlr.Unitario"#"Vlr.Total"

		oListBox:SetArray(aCmpDet) // Atrela os dados do grid com a matriz
		oListBox:bLine := { ||{aCmpDet[oListBox:nAT][1],;
								  aCmpDet[oListBox:nAT][2],;
								  aCmpDet[oListBox:nAT][3],;
								  aCmpDet[oListBox:nAT][4],;
								  aCmpDet[oListBox:nAT][5],;
								  aCmpDet[oListBox:nAT][6]}} // Indica as linhas do grid
		oListBox:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do browse

		// Cria o panel para o botao OK
		@ 000, 000 MsPanel oBottom Of oDlgCmp Size 000, 012 // Corrdenada para o panel dos botoes (size)
		oBottom:Align := CONTROL_ALIGN_BOTTOM //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)

		// Botao de acao OK
		@ 000, 000 Button oOk Prompt STR0035  Of oBottom Size 030, 000 Pixel //Ok
		oOk:bAction := { || oDlgCmp:End() }
		oOk:Align   := CONTROL_ALIGN_RIGHT

		// Ativa a tela exibindo conforme a coordenada
		Activate MsDialog oDlgCmp Centered
	EndIf

Else

	Help(" ", 1, "AT930DETMAT")

EndIf

(cAliasMat)->(DbCloseArea())
RestArea(aAreaTFJ)
RestArea(aOldArea)
Return(Nil)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At930DetLoc
Load das informações da tela de detalhes Locação de Equipamento
@sample 	At930DetLoc()
@param		Nenhum
@return	ExpL	Nil
@since		22/11/2013
@author	Serviços
@version	P11.9
/*/
//------------------------------------------------------------------------------
Static Function At930DetLoc(lAutomato)

Local aOldArea	:= GetArea()
Local aCmpDet		:= {}
Local cTitulo		:= STR0012 // "Detalhe "
Local cAliasTEW	:= ""
Local cLocalABS	:= ""
Local oListBox			//Grid campos
Local oOk					//Objeto Confirma
Local oTop 				//Objeto Panel
Local oMiddle
Local oBottom
Local oDlgCmp
Local cMotivo		:= ""
Local cQuery		:= ""

Default lAutomato := .F.

cTitulo			+= STR0010 // "Locação de Equipamentos"
DbSelectArea("TEW")
DbsetOrder(1)
cAliasTEW			:= GetNextAlias()

cQuery		:= "SELECT TEW.TEW_MOTIVO, TEW.TEW_CODMV, TEW.TEW_PRODUT, TEW.TEW_DTRINI, TEW.TEW_DTRFIM, TEW.TEW_SUBSTI, TEW.TEW_BAATD,  TEW.TEW_QTDVEN"
cQuery		+= " FROM " + RetSQLName("TEW") + " TEW "
cQuery		+= " WHERE TEW_CODEQU = '"+FWFLDGET("TFI_COD")+"' AND "
cQuery		+= " TEW_FILIAL = '" + xFilial("TEW")+"' AND "
cQuery		+= " TEW.TEW_DTRINI <= '"+DTOS(FWFLDGET("TFV_DTFIM"))+"' AND "
cQuery		+= " ( "
cQuery		+= " (TEW.TEW_DTRFIM = ' ' OR TEW.TEW_DTRFIM >= '"+DTOS(FWFLDGET("TFV_DTINI"))+"') AND "
cQuery		+= " (TEW.TEW_DTAMNT = ' ' OR TEW.TEW_DTAMNT >= '"+DTOS(FWFLDGET("TFV_DTINI"))+"') "
cQuery		+= " ) AND "
cQuery		+= " TEW.D_E_L_E_T_ = ' ' "

cQuery		:= ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN",TcGenQry(,,cQuery), cAliasTEW, .T., .T.)

TcSetField( cAliasTEW, 'TEW_DTRFIM', 'D', 8, 0 )
TcSetField( cAliasTEW, 'TEW_DTRINI', 'D', 8, 0 )

While (cAliasTEW)->(!Eof())
	If (cAliasTEW)->TEW_MOTIVO == "1"
		cMotivo:= STR0088 //"Substituição"
	ElseIf (cAliasTEW)->TEW_MOTIVO == "2"
		cMotivo:= STR0089 //"Cancelamento"
	Else
		cMotivo:=""
	EndIf
	aAdd( aCmpDet, { (cAliasTEW)->TEW_CODMV,;
	                 (cAliasTEW)->TEW_PRODUT,;
	                 Posicione("SB1",1,xFilial("SB1")+(cAliasTEW)->TEW_PRODUT,"B1_DESC"),;
	                 (cAliasTEW)->TEW_BAATD,;
	                 (cAliasTEW)->TEW_DTRINI,;
	                 (cAliasTEW)->TEW_DTRFIM,;
	                 (cAliasTEW)->TEW_SUBSTI,;
	                 cMotivo,;
	                 (cAliasTEW)->TEW_QTDVEN})

	(cAliasTEW)->(DbSkip())
EndDo

If !Empty(aCmpDet)

	If !lAutomato

		//	Cria a tela para a pesquisa dos campos e define a area a ser utilizada na tela
		Define MsDialog oDlgCmp TITLE cTitulo FROM 000, 000 To 450, 700 Pixel

		// Cria o panel as informaçoes do local e total
		@ 000, 000 MsPanel oTop Of oDlgCmp Size 000, 070 // Coordenada para o panel
		oTop:Align := CONTROL_ALIGN_TOP //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)

		@ 005,005 SAY STR0015 OF oTop PIXEL SIZE 120,9 // "Contrato"
		@ 015,005 MsGet FWFLDGET("TFV_CONTRT") OF oTop SIZE 60,10 PIXEL WHEN .F.
		cLocalABS:= Posicione("TFL",1,xFilial("TFL")+FWFLDGET("TFZ_CODTFL"),"TFL_LOCAL")
		@ 005,105 SAY STR0004 OF oTop PIXEL SIZE 120,9 // "Local"
		@ 015,105 MsGet cLocalABS OF oTop SIZE 40,10 PIXEL WHEN .F.
		@ 005,155 SAY STR0005 OF oTop PIXEL SIZE 120,9 // "Descrição"
		@ 015,155 MsGet Posicione("ABS",1,xFilial("ABS")+cLocalABS,"ABS_DESCRI") OF oTop SIZE 190,10 PIXEL WHEN .F.

		// Cria o panel o browse dos itens dos materiais
		@ 000, 000 MsPanel oMiddle Of oDlgCmp Size 000, 150 // Coordenada para o panel
		oMiddle:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)

		// Criação do grid para o panel
		oListBox := TWBrowse():New(000,000,000,000,,{	STR0042,;												//"Movimentações"
															STR0038,;												//"Produto"
															STR0005,;												//"Descrição"
															STR0099,;												//"Base Atend."
															STR0043,;												//"Data Inicial"
															STR0044,;												//"Data Final"
															STR0045,;												//"Substituto"
															STR0046,;
															'Quantidade'},,oMiddle,,,,,,,,,,,,.F.,,.T.,,.F.,,,)	//"Motivo da Substituição"

		oListBox:SetArray(aCmpDet) // Atrela os dados do grid com a matriz
		oListBox:bLine := { ||{aCmpDet[oListBox:nAT][1],;
								  aCmpDet[oListBox:nAT][2],;
								  aCmpDet[oListBox:nAT][3],;
								  aCmpDet[oListBox:nAT][4],;
								  aCmpDet[oListBox:nAT][5],;
								  aCmpDet[oListBox:nAT][6],;
								  aCmpDet[oListBox:nAT][7],;
								  aCmpDet[oListBox:nAT][8],; // Indica as linhas do grid
								  aCmpDet[oListBox:nAT][9]}} // Indica as linhas do grid
		oListBox:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do browse

		// Cria o panel para o botao OK
		@ 000, 000 MsPanel oBottom Of oDlgCmp Size 000, 012 // Corrdenada para o panel dos botoes (size)
		oBottom:Align := CONTROL_ALIGN_BOTTOM //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)

		// Botao de acao OK
		@ 000, 000 Button oOk Prompt STR0035  Of oBottom Size 030, 000 Pixel //Ok
		oOk:bAction := { || oDlgCmp:End() }
		oOk:Align   := CONTROL_ALIGN_RIGHT

		// Ativa a tela exibindo conforme a coordenada
		Activate MsDialog oDlgCmp Centered
	EndIf
Else
	Help(" ", 1, "AT930DETMAT")
EndIf

(cAliasTEW)->(DbCloseArea())
RestArea(aOldArea)
Return(Nil)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At930LoadMat
Carga de dados para os grid de materiais de implantação e consumo
@sample 	At930LoadMat()
@param  	Nenhum
@return	Nil
@author 	Serviços
@since		07/11/2013
@version	P11.90
/*/
//------------------------------------------------------------------------------
Static Function At930LoadMat()

Local aOldArea	:= GetArea()
Local cAliasIMI	:= GetNextAlias()
Local cAliasIMC	:= GetNextAlias()
Local oMdlAtivo	:= FwModelActive()
Local oMdlIMI	:= oMdlAtivo:GetModel("TFXDETAIL")
Local oMdlIMC	:= oMdlAtivo:GetModel("TFYDETAIL")
Local nDifDias	:= 0
Local nDifCalc	:= 0
Local nPerCalc	:= 0
Local nTotalLine:= 0
Local cWhereCob	:= ""
Local cRevCtr	:= Posicione("CN9",7,xFilial("CN9")+MV_PAR01+"05","CN9_REVISA")
Local lOrcPrc	:= SuperGetMv("MV_ORCPRC",,.F.)
Local cTipoOrc	:= If( lOrcPrc, '0', '1' ) // identifica o tipo de orçamento sendo utilizado para condicionar o relacionamento com TFF e TFL
Local cMedExt	:= If( lMedExt, '1', '0' ) // identifica o tipo de orçamento sendo utilizado para condicionar o relacionamento com TFF e TFL
Local lMatEnc	:= .F.
Local cCodPai	:= ""
Local lGSPosto  := SuperGetMv('MV_GSPOSTO',.F.,.F.)
Local lApura	:= !lApuraHE .AND. ((TecHasPerg("MV_PAR05","TEC930")) .AND. MV_PAR05 == 1)
Local lVlPrPar	:= FindFunction("TecVlPrPar") .And. TecVlPrPar()
Local lCrn		:= FindFunction("TecBHasCrn") .AND. TecBHasCrn()
Local lCalcCrn	:= .F.
Local cSlc 		:= ""
Local cGrpBy	:= ""
Local cCodTFJ 	:= ""
Local cQueryTGT := ""
Local cTpItem	:= ""
Local lExcedente := TecBHasCrn() .AND. TecBHasExc()
Local cExprQry := ""
Local cCor     := "BR_BRANCO"
Local nValApu   := 0
Local lCodsA    := .F.
Local cAliasTFT := "TFT"
Local cAliasTFS := "TFS"
Local cCodSATFS    := TFS->( ColumnPos('TFS_CODSA') ) > 0
Local cCodSATFT    := TFT->( ColumnPos('TFT_CODSA') ) > 0
Local cCamTFS       := ""
Local cCamTFT       := ""

iF cCodSATFS 
	cCamTFS := "TFS_CODSA"
Endif

If lVlPrPar
	cSlc 	:= ", TFG_VLPRPA"
	cGrpBy  := ", TFG_VLPRPA"
Endif

cSlc   := "%"+cSlc+"%"
cGrpBy := "%"+cGrpBy+"%"

If lMedExt
	cWhereCob := "%TFL.TFL_CONTRT = '" + MV_PAR01 + "' AND "
	cWhereCob += "TFL.TFL_CONREV = '" + cRevCtr + "' AND "
	cWhereCob += "TFG.TFG_COBCTR = '2' AND TFG.TFG_PRCVEN > 0%"
Else
	cWhereCob := "%TFL.TFL_CONTRT = '" + MV_PAR01 + "' AND "
	cWhereCob += "TFL.TFL_CONREV = '" + cRevCtr + "' AND "
 	cWhereCob += "TFG.TFG_COBCTR <> '2' %"
EndIf


		BeginSql Alias cAliasIMI

			SELECT TFL.TFL_CODIGO, TFL.TFL_LOCAL, ABS.ABS_DESCRI, TFG.TFG_PERINI, TFG.TFG_PERFIM,
				SUM(TFG.TFG_VALDES) VAL_DSC, SUM(TFS.TFS_QUANT) QUANTIDADE, TFG.TFG_COD, TFG.TFG_CODPAI,
				( SELECT SUM( (TFG2.TFG_QTDVEN *
								(TFG2.TFG_PRCVEN - ((TFG2.TFG_PRCVEN * TFG2.TFG_DESCON)/100)
												+ ((TFG2.TFG_PRCVEN * TFG2.TFG_LUCRO)/100)
												+ ((TFG2.TFG_PRCVEN * TFG2.TFG_ADM)/100)) ))
						FROM %table:TFG% TFG2
					WHERE TFG2.TFG_FILIAL = %xFilial:TFG%
						AND TFG2.%NotDel%
						AND TFG2.TFG_COD = TFG.TFG_COD
					GROUP BY TFG2.TFG_FILIAL,TFG2.TFG_LOCAL, TFG2.TFG_CODPAI
				) VLR_CONT,
				SUM( TFS.TFS_QUANT *
						(TFG.TFG_PRCVEN - ((TFG.TFG_PRCVEN * TFG.TFG_DESCON)/100)
										+ ((TFG.TFG_PRCVEN * TFG.TFG_LUCRO)/100)
										+ ((TFG.TFG_PRCVEN * TFG.TFG_ADM)/100) )) VLR_APU,
				( SELECT SUM( (SCP.CP_QUJE *
								(TFG2.TFG_PRCVEN - ((TFG2.TFG_PRCVEN * TFG2.TFG_DESCON)/100)
												+ ((TFG2.TFG_PRCVEN * TFG2.TFG_LUCRO)/100)
												+ ((TFG2.TFG_PRCVEN * TFG2.TFG_ADM)/100)) ))
						FROM %table:TFG% TFG2 
						INNER JOIN %table:TFS% TFS ON TFS.TFS_CODTFG = TFG2.TFG_COD
						INNER JOIN %table:SCP% SCP  ON SCP.CP_NUM  = %Exp:cCamTFS%
						WHERE TFG2.TFG_FILIAL = %xFilial:TFG%
						AND SCP.%NotDel%
						AND TFG2.%NotDel%
						AND TFG2.TFG_COD = TFG.TFG_COD
						AND SCP.CP_FILIAL = %xFilial:SCP%
					GROUP BY TFG2.TFG_FILIAL,TFG2.TFG_LOCAL, TFG2.TFG_CODPAI
				) VLR_APU2,
				( SELECT SUM( (TFG2.TFG_QTDVEN *
								(TFG2.TFG_PRCVEN - ((TFG2.TFG_PRCVEN * TFG2.TFG_DESCON)/100)
												+ ((TFG2.TFG_PRCVEN * TFG2.TFG_LUCRO)/100)
												+ ((TFG2.TFG_PRCVEN * TFG2.TFG_ADM)/100)) ))
						FROM %table:TFG% TFG2
					WHERE TFG2.TFG_FILIAL = %xFilial:TFG%
						AND TFG2.%NotDel%
						AND TFG2.TFG_COD = TFG.TFG_COD
					GROUP BY TFG2.TFG_FILIAL,TFG2.TFG_LOCAL, TFG2.TFG_CODPAI
				) VLR_CONT2,
				TFF.TFF_COD, TFG.TFG_PRODUT, SB1.B1_DESC %Exp:cSlc%
					FROM %table:TFG% TFG
				LEFT JOIN %table:TFS% TFS ON TFS.TFS_FILIAL = %xFilial:TFS%
										AND TFS.TFS_CODTFG = TFG.TFG_COD
										AND TFS.TFS_ITAPUR = ' '
										AND TFS.TFS_DTAPON >= %Exp:MV_PAR02%
										AND TFS.TFS_DTAPON <= %Exp:MV_PAR03%
										AND TFS.%NotDel%
				LEFT JOIN %table:TFF% TFF ON '1' = %exp:cTipoOrc%
										AND TFF.TFF_FILIAL = %xFilial:TFF%
										AND TFF.TFF_COD = TFG.TFG_CODPAI
										AND TFF.%NotDel%
				LEFT JOIN %table:TFL% TFL ON TFL.TFL_FILIAL = %xFilial:TFL%
										AND TFL.%NotDel%
										AND ( ( '1' = %exp:cTipoOrc% AND TFL.TFL_CODIGO = TFF.TFF_CODPAI ) OR
												( '0' = %exp:cTipoOrc% AND TFL.TFL_CODIGO = TFG.TFG_CODPAI ) )
										AND ( TFL.TFL_TOTMI > 0 OR '1' = %exp:cMedExt% )
				LEFT JOIN %table:ABS% ABS ON ABS.ABS_FILIAL = %xFilial:ABS%
										AND ABS.ABS_LOCAL = TFL.TFL_LOCAL
										AND ABS.%NotDel%
				LEFT JOIN %table:SB1% SB1 ON SB1.B1_FILIAL = %xFilial:SB1%
										AND SB1.B1_COD = TFG.TFG_PRODUT
										AND SB1.%NotDel%
			WHERE TFG.TFG_FILIAL = %xFilial:TFG%
			AND TFG.%NotDel%
			AND %Exp:cWhereCob%
			GROUP BY TFL.TFL_CODIGO, TFL.TFL_LOCAL,  ABS.ABS_DESCRI, TFL.TFL_CODIGO, TFG.TFG_COD, TFG.TFG_CODPAI,
					TFG.TFG_PERINI, TFG.TFG_PERFIM, TFF.TFF_COD, TFF.TFF_PRODUT, TFG_PRODUT, SB1.B1_DESC %Exp:cGrpBy%

		EndSql		

If (cAliasIMI)->(!Eof())
	nTotalLine := TotMIItens(MV_PAR01, cRevCtr, lMedExt)

	If oMdlIMI:GetMaxLines() < nTotalLine
		oMdlIMI:SetMaxLine(nTotalLine) 
	EndIf

	While (cAliasIMI)->(!Eof())

		lCalcCrn	:= .F.

		oMdlIMI:SetValue( "TFX_LOCAL" , (cAliasIMI)->TFL_LOCAL  )
		oMdlIMI:SetValue( "TFX_DESCRI", (cAliasIMI)->ABS_DESCRI )
		oMdlIMI:SetValue( "TFX_CODTFL", (cAliasIMI)->TFL_CODIGO )

        If (TecAponts() .And. MV_PAR05 == 1)
			If lCodsA := At890NumMov(cAliasTFS, (cAliasIMI)->TFG_COD) 	
		    	nValApu := At930QtApu(cAliasTFS, (cAliasIMI)->TFG_COD) 
				oMdlIMI:SetValue( "TFX_VLRAPU", nValApu )
			Else
				oMdlIMI:SetValue( "TFX_VLRAPU", (cAliasIMI)->VLR_APU2 )
			Endif
			cCor := At930Legend("TFX",(cAliasIMI)->TFG_COD) 
			oMdlIMI:SetValue( "TFX_LEG"   ,cCor )		
		Else
			oMdlIMI:SetValue( "TFX_VLRAPU", (cAliasIMI)->VLR_APU )
		Endif	
		
		oMdlIMI:SetValue( "TFX_CODTFF", (cAliasIMI)->TFF_COD	    )
		oMdlIMI:SetValue( "TFX_PRODUT", (cAliasIMI)->TFG_PRODUT )
		oMdlIMI:SetValue( "TFX_DSCPRO", (cAliasIMI)->B1_DESC    )
		oMdlIMI:SetValue( "TFX_CODTFG", (cAliasIMI)->TFG_COD    )
		oMdlIMI:SetValue( "TFX_PLAN"  , Posicione("TFL",1,xFilial("TFL")+oMdlIMI:GetValue("TFX_CODTFL"),"TFL_PLAN")  )

		//Diferença de dias para o calculo do valor do contrato
		nDifDias := TecDaysIn(StoD((cAliasIMI)->TFG_PERINI),StoD((cAliasIMI)->TFG_PERFIM),MV_PAR02,MV_PAR03)

		nDifCalc := (StoD((cAliasIMI)->TFG_PERFIM) - StoD((cAliasIMI)->TFG_PERINI)) + 1

		nPerCalc := (nDifDias / nDifCalc) * 100

		//-- Visando ganhar perfomance, somente chama a rotina de verificar se o item esta encerrado quando mudar o CODPAI
		If lGSPosto
			If cCodPai <> (cAliasIMI)->TFG_CODPAI
				cCodPai := (cAliasIMI)->TFG_CODPAI
				lMatEnc := At30MatEnc(cCodPai)
			EndIf
		EndIf

		If nDifCalc > nDifDias .And. At740Recor(MV_PAR01)

			If (TecAponts() .And. MV_PAR05 == 1)
				oMdlIMI:SetValue( "TFX_VLRCON", (((cAliasIMI)->VLR_CONT2 * nPerCalc) / 100) )
			else
				oMdlIMI:SetValue( "TFX_VLRCON", (((cAliasIMI)->VLR_CONT * nPerCalc) / 100) )
			Endif		

			If !lMatEnc 
				If isInCallStack("At930ApuAg")
					oMdlIMI:SetValue( "TFX_VLRMED", 0 )
				Else
				    If (TecAponts() .And. MV_PAR05 == 1)
						If lCodsA 
							oMdlIMI:SetValue( "TFX_VLRMED", nValApu )
						Else
							oMdlIMI:SetValue( "TFX_VLRMED", (cAliasIMI)->VLR_APU2 )
						Endif
					ElseIf lMedExce .OR. lApuraHE
						oMdlIMI:SetValue( "TFX_VLRMED", 0 )
					ElseIf !lApura 
						oMdlIMI:SetValue( "TFX_VLRMED", (((cAliasIMI)->VLR_CONT * nPerCalc) / 100) )
					Else
						oMdlIMI:SetValue( "TFX_VLRMED", (cAliasIMI)->VLR_APU )
					EndIf
				EndIf
			Else	
				oMdlIMI:SetValue( "TFX_VLRMED", 0)
			EndIf
		Else
			If nPerCalc > 0 
				If !lMatEnc
					If lMedExce .OR. lApuraHE
						oMdlIMI:SetValue( "TFX_VLRCON", 0 )
						oMdlIMI:SetValue( "TFX_VLRMED", 0 )
					ElseIf !lApura
						If lCrn
							cCodTFJ := POSICIONE("TFL",1,xFilial("TFL") + (cAliasIMI)->TFL_CODIGO, "TFL_CODPAI")
							cTpItem := "TFG"
							If !EMPTY(Alltrim(STRTRAN(cMV_PAR04,"/"))) .AND. !EMPTY(cCodTFJ)
								cQueryTGT	:= GetNextAlias()
								If lExcedente
									cExprQry := "% AND TGT.TGT_EXCEDT != '1' %"
								Else
									cExprQry := "%%"
								EndIf
								BeginSql Alias cQueryTGT
									SELECT TGT.TGT_VALOR
									FROM %Table:TGT% TGT
									WHERE TGT.TGT_FILIAL	= %exp:xFilial('TGT')%
										AND TGT.TGT_CODTFJ = %exp:cCodTFJ%
										AND TGT.TGT_TPITEM = %exp:cTpItem%
										AND TGT.TGT_CDITEM = %exp:(cAliasIMI)->TFG_COD%
										AND TGT.TGT_COMPET = %exp:cMV_PAR04%
										AND TGT.%NotDel%
										%Exp:cExprQry%
								EndSql

								If !(cQueryTGT)->(EOF())
									oMdlIMI:SetValue( "TFX_VLRCON",  (cQueryTGT)->TGT_VALOR )
									oMdlIMI:SetValue( "TFX_VLRMED",  (cQueryTGT)->TGT_VALOR )
									lCalcCrn := .T.
								EndIf
								(cQueryTGT)->(DbCloseArea())
							EndIf
						EndIf
						If !lCalcCrn
							If lVlPrPar .And. (cAliasIMI)->TFG_VLPRPA <> 0 .And. (cAliasIMI)->TFG_VLPRPA <> (cAliasIMI)->VLR_CONT .AND. !lMedExt
								oMdlIMI:SetValue( "TFX_VLRCON",  (cAliasIMI)->TFG_VLPRPA )
								oMdlIMI:SetValue( "TFX_VLRMED",  (cAliasIMI)->TFG_VLPRPA )
							Else
								oMdlIMI:SetValue( "TFX_VLRCON",  (cAliasIMI)->VLR_CONT )
								oMdlIMI:SetValue( "TFX_VLRMED",  (cAliasIMI)->VLR_CONT )		
							Endif
						EndIf
					Else
					    If (TecAponts() .And. MV_PAR05 == 1)  
							oMdlIMI:SetValue( "TFX_VLRCON",  (cAliasIMI)->VLR_CONT2 )
							If lCodsA 
								oMdlIMI:SetValue( "TFX_VLRMED",   nValApu )
							else
								oMdlIMI:SetValue( "TFX_VLRMED",  (cAliasIMI)->VLR_APU2 )
							Endif	
						else
							oMdlIMI:SetValue( "TFX_VLRCON",  (cAliasIMI)->VLR_CONT )
							oMdlIMI:SetValue( "TFX_VLRMED", (cAliasIMI)->VLR_APU )
						Endif					
					EndIf	
				Else
					If (TecAponts() .And. MV_PAR05 == 1) 	
						oMdlIMI:SetValue( "TFX_VLRCON",  (cAliasIMI)->VLR_CONT2 )
						oMdlIMI:SetValue( "TFX_VLRMED", 0)	
					else 
						oMdlIMI:SetValue( "TFX_VLRCON",  (cAliasIMI)->VLR_CONT )
						oMdlIMI:SetValue( "TFX_VLRMED", 0)	
					Endif		
				EndIf
			Else
				oMdlIMI:SetValue( "TFX_VLRCON", 0 )
				oMdlIMI:SetValue( "TFX_VLRMED", 0 )
			Endif
		EndIf

		(cAliasIMI)->(dbSkip())

		If (cAliasIMI)->(!Eof())
			oMdlIMI:AddLine()
		Endif

	EndDo
EndIf
cSlc 	:= ""
cGrpBy	:= ""

If lVlPrPar
	cSlc 	:= ", TFH_VLPRPA"
	cGrpBy  := ", TFH_VLPRPA"
Endif

cSlc   := "%"+cSlc+"%"
cGrpBy := "%"+cGrpBy+"%"

If lMedExt
	cWhereCob := "%TFL.TFL_CONTRT = '" + MV_PAR01 + "' AND "
	cWhereCob += "TFL.TFL_CONREV = '" + cRevCtr + "' AND "
	cWhereCob += "TFH.TFH_COBCTR = '2' AND TFH.TFH_PRCVEN > 0%"
Else
	cWhereCob := "%TFL.TFL_CONTRT = '" + MV_PAR01 + "' AND "
	cWhereCob += "TFL.TFL_CONREV = '" + cRevCtr + "' AND "
 	cWhereCob += "TFH.TFH_COBCTR <> '2' %"
EndIf

iF cCodSATFT 
	cCamTFT := "TFT_CODSA"
Endif

// Materiais de Consumo

		BeginSql Alias cAliasIMC

			SELECT TFL.TFL_CODIGO, TFL.TFL_LOCAL, ABS.ABS_DESCRI, TFH.TFH_PERINI, TFH.TFH_PERFIM,
				SUM(TFH.TFH_VALDES) VAL_DSC, SUM(TFT.TFT_QUANT) QUANTIDADE, TFH.TFH_COD, TFH_CODPAI,
					( SELECT SUM( (TFH2.TFH_QTDVEN *
								(TFH2.TFH_PRCVEN - ((TFH2.TFH_PRCVEN * TFH2.TFH_DESCON)/100)
												+ ((TFH2.TFH_PRCVEN * TFH2.TFH_LUCRO)/100)
												+ ((TFH2.TFH_PRCVEN * TFH2.TFH_ADM)/100) )))
					FROM %table:TFH% TFH2
					WHERE TFH2.TFH_FILIAL = %xFilial:TFH%
						AND TFH2.%NotDel%
						AND TFH2.TFH_COD = TFH.TFH_COD
					GROUP BY TFH2.TFH_FILIAL, TFH2.TFH_LOCAL, TFH2.TFH_CODPAI
				) VLR_CONT,
				SUM(TFT.TFT_QUANT * (TFH.TFH_PRCVEN - (TFH.TFH_PRCVEN * TFH.TFH_DESCON)/100
													+ (TFH.TFH_PRCVEN * TFH.TFH_LUCRO)/100
													+ (TFH.TFH_PRCVEN * TFH.TFH_ADM)/100	)) VLR_APU,
				( SELECT SUM( (SCP.CP_QUJE *
								(TFH2.TFH_PRCVEN - ((TFH2.TFH_PRCVEN * TFH2.TFH_DESCON)/100)
												+ ((TFH2.TFH_PRCVEN * TFH2.TFH_LUCRO)/100)
												+ ((TFH2.TFH_PRCVEN * TFH2.TFH_ADM)/100) )))
					FROM %table:TFH% TFH2
					INNER JOIN %table:TFT% TFT ON TFT.TFT_CODTFH = TFH2.TFH_COD
					INNER JOIN %table:SCP% SCP  ON SCP.CP_NUM  = %Exp:cCamTFT%
					WHERE TFH2.TFH_FILIAL = %xFilial:TFH%
					AND SCP.%NotDel%
					AND TFH2.%NotDel%
					AND TFH2.TFH_COD = TFH.TFH_COD
					GROUP BY TFH2.TFH_FILIAL, TFH2.TFH_LOCAL, TFH2.TFH_CODPAI ) VLR_APU2,
				( SELECT SUM( (TFH2.TFH_QTDVEN *
								(TFH2.TFH_PRCVEN - ((TFH2.TFH_PRCVEN * TFH2.TFH_DESCON)/100)
												+ ((TFH2.TFH_PRCVEN * TFH2.TFH_LUCRO)/100)
												+ ((TFH2.TFH_PRCVEN * TFH2.TFH_ADM)/100) )))
					FROM %table:TFH% TFH2
					WHERE TFH2.TFH_FILIAL = %xFilial:TFH%
					AND TFH2.%NotDel%
					AND TFH2.TFH_COD = TFH.TFH_COD
					GROUP BY TFH2.TFH_FILIAL, TFH2.TFH_LOCAL, TFH2.TFH_CODPAI
				) VLR_CONT2 ,
				TFF.TFF_COD, TFH.TFH_PRODUT, SB1.B1_DESC %Exp:cSlc%
				FROM %table:TFH% TFH
				LEFT JOIN %table:TFT% TFT ON TFT.TFT_FILIAL = %xFilial:TFT%
											AND TFT.TFT_CODTFH = TFH.TFH_COD
											AND TFT.TFT_ITAPUR = ' '
											AND TFT.TFT_DTAPON >= %Exp:MV_PAR02%
											AND TFT.TFT_DTAPON <= %Exp:MV_PAR03%
											AND TFT.%NotDel%
				LEFT JOIN %table:TFF% TFF ON '1' = %exp:cTipoOrc%
											AND TFF.TFF_FILIAL = %xFilial:TFF%
											AND TFF.TFF_COD = TFH.TFH_CODPAI
											AND TFF.%NotDel%
				LEFT JOIN %table:TFL% TFL ON TFL.TFL_FILIAL = %xFilial:TFL%
											AND TFL.%NotDel%
											AND ( ( '1' = %exp:cTipoOrc% AND TFL.TFL_CODIGO = TFF.TFF_CODPAI ) OR
												( '0' = %exp:cTipoOrc% AND TFL.TFL_CODIGO = TFH.TFH_CODPAI ) )
										AND ( TFL.TFL_TOTMC > 0 OR '1' = %exp:cMedExt% )
				LEFT JOIN %table:ABS% ABS ON ABS.ABS_FILIAL = %xFilial:ABS%
											AND ABS.ABS_LOCAL = TFL.TFL_LOCAL
											AND ABS.%NotDel%
				LEFT JOIN %table:SB1% SB1 ON SB1.B1_FILIAL = %xFilial:SB1%
											AND SB1.B1_COD = TFH.TFH_PRODUT
											AND SB1.%NotDel%
			WHERE TFH.TFH_FILIAL = %xFilial:TFH%
			AND TFH.%NotDel%
			AND %Exp:cWhereCob%
			GROUP BY TFL.TFL_CODIGO, TFL.TFL_LOCAL,  ABS.ABS_DESCRI, TFL.TFL_CODIGO, TFH.TFH_COD, TFH_CODPAI,
					TFH.TFH_PERINI, TFH.TFH_PERFIM, TFF.TFF_COD,    TFF.TFF_PRODUT, TFH.TFH_PRODUT, SB1.B1_DESC %Exp:cGrpBy%

		EndSql


cCodPai := ""
lMatEnc := .F.

If (cAliasIMC)->(!Eof())
	nTotalLine := TotMCItens(MV_PAR01, cRevCtr, lMedExt)

	If oMdlIMC:GetMaxLines() < nTotalLine
		oMdlIMC:SetMaxLine(nTotalLine) 
	EndIf

	While (cAliasIMC)->(!Eof())

		lCalcCrn := .F.

		If (TecAponts() .And. MV_PAR05 == 1)
			cCor := At930Legend("TFY",(cAliasIMC)->TFH_COD) 
			oMdlIMC:SetValue( "TFY_LEG"   ,cCor )
		Endif	

		oMdlIMC:SetValue( "TFY_LOCAL" , (cAliasIMC)->TFL_LOCAL  )
		oMdlIMC:SetValue( "TFY_DESCRI", (cAliasIMC)->ABS_DESCRI )
		oMdlIMC:SetValue( "TFY_CODTFL", (cAliasIMC)->TFL_CODIGO	)
		oMdlIMC:SetValue( "TFY_VLRAPU", (cAliasIMC)->VLR_APU	)

	    If (TecAponts() .And. MV_PAR05 == 1)   					
			If lCodsA := At890NumMov(cAliasTFT, (cAliasIMC)->TFH_COD) 	
		    	nValApu := At930QtApu(cAliasTFT,(cAliasIMC)->TFH_COD) 
				oMdlIMC:SetValue( "TFY_VLRAPU", nValApu )				
			Else
				oMdlIMC:SetValue( "TFY_VLRAPU", (cAliasIMC)->VLR_APU2 )
			Endif
		Else
			oMdlIMC:SetValue( "TFY_VLRAPU", (cAliasIMC)->VLR_APU )
		Endif

		oMdlIMC:SetValue( "TFY_CODTFF", (cAliasIMC)->TFF_COD	    )
		oMdlIMC:SetValue( "TFY_PRODUT", (cAliasIMC)->TFH_PRODUT )
		oMdlIMC:SetValue( "TFY_DSCPRO", (cAliasIMC)->B1_DESC    )
		oMdlIMC:SetValue( "TFY_CODTFH", (cAliasIMC)->TFH_COD    )
		oMdlIMC:SetValue( "TFY_PLAN", Posicione("TFL",1,xFilial("TFL")+oMdlIMC:GetValue("TFY_CODTFL"),"TFL_PLAN")  )

	//Diferença de dias para o calculo do valor do contrato
		nDifDias := TecDaysIn(StoD((cAliasIMC)->TFH_PERINI),StoD((cAliasIMC)->TFH_PERFIM),MV_PAR02,MV_PAR03)

		nDifCalc := StoD((cAliasIMC)->TFH_PERFIM) - StoD((cAliasIMC)->TFH_PERINI) + 1

		nPerCalc := (nDifDias / nDifCalc) * 100

		//-- Visando ganhar perfomance, somente chama a rotina de verificar se o item esta encerrado quando mudar o CODPAI
		If lGSPosto
			If cCodPai <> (cAliasIMC)->TFH_CODPAI
				cCodPai := (cAliasIMC)->TFH_CODPAI
				lMatEnc := At30MatEnc(cCodPai)
			EndIf
		EndIf

		If nDifCalc > nDifDias .And. At740Recor(MV_PAR01)

			If (TecAponts() .And. MV_PAR05 == 1)
				oMdlIMC:SetValue( "TFY_VLRCON", (((cAliasIMC)->VLR_CONT2 * nPerCalc) / 100) )
			else
				oMdlIMC:SetValue( "TFY_VLRCON", (((cAliasIMC)->VLR_CONT * nPerCalc) / 100) )
			Endif	

			If !lMatEnc 
				If isInCallStack("At930ApuAg")
					oMdlIMC:SetValue( "TFY_VLRMED", 0 )
				Else		
					If (TecAponts() .And. MV_PAR05 == 1)
						If lCodsA 
							oMdlIMC:SetValue( "TFY_VLRMED", nValApu )
						Else
							oMdlIMC:SetValue( "TFY_VLRMED", (cAliasIMI)->VLR_APU2 )
						Endif
					ElseIf lMedExce .OR. lApuraHE
						oMdlIMC:SetValue( "TFY_VLRMED", 0)
					ElseIf !lApura
						oMdlIMC:SetValue( "TFY_VLRMED", (((cAliasIMC)->VLR_CONT * nPerCalc) / 100) )
					Else
						oMdlIMC:SetValue( "TFY_VLRMED", (cAliasIMC)->VLR_APU )
					EndIf
				EndIf
			Else		
				oMdlIMC:SetValue( "TFY_VLRMED", 0 )
			EndIf
		Else
			If nPerCalc > 0
				If !lMatEnc
					If lMedExce .OR. lApuraHE
						oMdlIMC:SetValue( "TFY_VLRCON", 0)
						oMdlIMC:SetValue( "TFY_VLRMED", 0)
					ElseIf !lApura
						If lCrn
							cCodTFJ := POSICIONE("TFL",1,xFilial("TFL") + (cAliasIMC)->TFL_CODIGO, "TFL_CODPAI")
							cTpItem := "TFH"
							If !EMPTY(Alltrim(STRTRAN(cMV_PAR04,"/"))) .AND. !EMPTY(cCodTFJ)
								cQueryTGT	:= GetNextAlias()
								If lExcedente
									cExprQry := "% AND TGT.TGT_EXCEDT != '1' %"
								Else
									cExprQry := "%%"
								EndIf
								BeginSql Alias cQueryTGT
									SELECT TGT.TGT_VALOR
									FROM %Table:TGT% TGT
									WHERE TGT.TGT_FILIAL	= %exp:xFilial('TGT')%
										AND TGT.TGT_CODTFJ = %exp:cCodTFJ%
										AND TGT.TGT_TPITEM = %exp:cTpItem%
										AND TGT.TGT_CDITEM = %exp:(cAliasIMC)->TFH_COD%
										AND TGT.TGT_COMPET = %exp:cMV_PAR04%
										AND TGT.%NotDel%
										%Exp:cExprQry%
								EndSql

								If !(cQueryTGT)->(EOF())
									oMdlIMC:SetValue( "TFY_VLRCON",  (cQueryTGT)->TGT_VALOR )
									oMdlIMC:SetValue( "TFY_VLRMED",  (cQueryTGT)->TGT_VALOR )
									lCalcCrn := .T.
								EndIf
								(cQueryTGT)->(DbCloseArea())
							EndIf
						EndIf
						If !lCalcCrn
							If lVlPrPar .And. (cAliasIMC)->TFH_VLPRPA <> 0 .And. (cAliasIMC)->TFH_VLPRPA <> (cAliasIMC)->VLR_CONT .AND. !lMedExt
								oMdlIMC:SetValue( "TFY_VLRCON", (cAliasIMC)->TFH_VLPRPA )
								oMdlIMC:SetValue( "TFY_VLRMED", (cAliasIMC)->TFH_VLPRPA )
							Else
								oMdlIMC:SetValue( "TFY_VLRCON",  (cAliasIMC)->VLR_CONT )
								oMdlIMC:SetValue( "TFY_VLRMED",  (cAliasIMC)->VLR_CONT )
							Endif
						EndIf
					Else
						If (TecAponts() .And. MV_PAR05 == 1)
							oMdlIMC:SetValue( "TFY_VLRCON",  (cAliasIMC)->VLR_CONT2 ) 
							If lCodsA 
								oMdlIMC:SetValue( "TFY_VLRMED",  nValApu )
							else
								oMdlIMC:SetValue( "TFY_VLRMED", (cAliasIMC)->VLR_APU2 )
							Endif
						Else
							oMdlIMC:SetValue( "TFY_VLRCON", (cAliasIMC)->VLR_CONT )
							oMdlIMC:SetValue( "TFY_VLRMED", (cAliasIMC)->VLR_APU)
						EndIf
					EndIf	
				Else
					If (TecAponts() .And. MV_PAR05 == 1)
						oMdlIMC:SetValue( "TFY_VLRCON", (cAliasIMC)->VLR_CONT2 )
						If lCodsA
							oMdlIMC:SetValue( "TFY_VLRMED",nValApu)
						else
							oMdlIMC:SetValue( "TFY_VLRMED",(cAliasIMC)->VLR_APU2)
						Endif	
					Endif	
				EndIf	
			Else
				oMdlIMC:SetValue( "TFY_VLRCON", 0 )
				oMdlIMC:SetValue( "TFY_VLRMED", 0 )
			Endif
		EndIf

		(cAliasIMC)->(dbSkip())

		If (cAliasIMC)->(!Eof())
			oMdlIMC:AddLine()
		Endif

	EndDo
EndIf
(cAliasIMI)->(DbCloseArea())
(cAliasIMC)->(DbCloseArea())
RestArea(aOldArea)
Return(Nil)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At930CaRH
Load das informações da tela de Recursos Humanos
@sample 	At930CaRH()
@param		cContrato - Contrato que será apurado
@return	ExpL	Nil
@since		22/11/2013
@author	Serviços
@version	P11.9
/*/
//------------------------------------------------------------------------------//
Static Function At930CaRH(cContrato)

Local aArea		:= GetArea()
Local cAliasQry	:= GetNextAlias()
Local cOperConc	:= if(Trim(Upper(TcGetDb())) $ "ORACLE,POSTGRES,DB2,INFORMIX","||","+")
Local cIdcABQ		:= ""
Local oModel		:= FWModelActive()
Local oModelTFW	:= oModel:GetModel("TFWDETAIL")
Local aBusca		:= {}
Local lExiste		:= .F.
Local nVlrHor		:= 0
Local nHorTot		:= 0
Local nDifDias	:= 0
Local nDifCalc	:= 0
Local nPerCalc	:= 0
Local nTotHora	:= 0
Local nVlrTot		:= 0
Local cRevCtr		:= Posicione("CN9",7,xFilial("CN9")+MV_PAR01+"05","CN9_REVISA")
Local nHorExt		:= 0
Local nValHorE	:= 0
Local nValTFU	:= 0
Local nLinha		:= 0
Local nTotHrN		:= 0
Local cWhereCob	:= ""
Local nVlrCont	:= 0
Local lEncePosto	:= SuperGetMv('MV_GSPOSTO',.F.,.F.)
Local cMedExt		:= If( lMedExt, '1', '0' ) // identifica o tipo de orçamento sendo utilizado para condicionar o relacionamento com TFF e TFL
Local lApura	:= !lApuraHE .AND. ((TecHasPerg("MV_PAR05","TEC930")) .AND. MV_PAR05 == 1)
Local lCalend	:= !lApuraHE .AND. ((TecHasPerg("MV_PAR06","TEC930")) .AND. MV_PAR06 == 2)
Local cAbtIns	:= ""
Local cCalend	:= ""
Local nAbtIns	:= 0
Local lAbtIns	:= TFF->( ColumnPos('TFF_ABTINS') ) > 0 
Local nTotHorRc	:= 0			// Total de horas para a competência do contrato recorrente
Local lPrHora 	:= TecABBPRHR()
Local lVlPrPar	:= FindFunction("TecVlPrPar") .And. TecVlPrPar()
Local lGsGerOS  := At930GerOs()
Local nTotSemOS	:= 0
Local cWhrJoin	:= "%%"
Local cJoinSub	:= "%%"
Local lHrExtN   := TFW->( ColumnPos("TFW_HREXTN")) > 0
Local nHorTotExN := 0
Local nTotalLine	:= 0
Local cCodTFJ := ""
Local cTpItem := ""
Local lCalcCrn := .F.
Local cQueryTGT := ""
Local aRecorr	:= {}
Local nAux		:= 0
Local lExcedente := TecBHasCrn() .AND. TecBHasExc()
Local cExprQry := ""
Local cExprHE := "%AND 1=1%"
Local cWhereHE := "%AND 1=1%"
Local lABRCodTFV := TecBHasBrT() 
Local lMedLeg	:= SuperGetMv("MV_GSMDZER",,"2") == "1" //Verifica se vai habilitar a opção da Legenda de alocação na medição

If lMedExt
	cWhereCob := "%TFL.TFL_CONTRT = '" + MV_PAR01 + "' AND "
	cWhereCob += "TFL.TFL_CONREV = '" + cRevCtr + "' AND "
	cWhereCob += "TFF.TFF_COBCTR = '2' AND TFF.TFF_PRCVEN > 0%"
Else
	cWhereCob := "%TFF.TFF_CONTRT = '" + MV_PAR01 + "' AND "
	cWhereCob += "TFF.TFF_CONREV = '" + cRevCtr + "' AND "
 	cWhereCob += "TFF.TFF_COBCTR <> '2' AND TFF.TFF_PRCVEN > 0%"
EndIf

If !lGsGerOS
	cWhrJoin := "%AND ABB.ABB_ITAPUR = ' '%"
Else
	cJoinSub := "%INNER JOIN " + RetSqlName('AB9') + " AB92 ON (AB92.AB9_FILIAL = '" + xFilial("AB9") + "' "
	cJoinSub += "       AND AB92.AB9_ATAUT = ABB2.ABB_CODIGO "
	cJoinSub += "       AND AB92.AB9_NUMOS = ABB2.ABB_CHAVE "
	cJoinSub += "       AND AB92.AB9_ITAPUR =' ' "
	cJoinSub += "       AND AB92.D_E_L_E_T_ = ' ')%"
Endif

nDifDias := (MV_PAR03 - MV_PAR02) + 1

cIdcABQ := "%ABQ.ABQ_CONTRT" + cOperConc + "ABQ.ABQ_ITEM" + cOperConc + "ABQ.ABQ_ORIGEM%"

cAbtIns := "%TFL.TFL_CODIGO, TFL.TFL_LOCAL, ABS.ABS_DESCRI, TFF.TFF_COD, TFF.TFF_CALEND , TFF.TFF_PRODUT,"+;
		"SB1.B1_DESC, ABA.ABA_QUANT TOT_HOR, ABQ.ABQ_TOTAL, TFF.TFF_QTDVEN,"+;
		"TFF.TFF_PRCVEN, TFF.TFF_VALDES, TFF.TFF_PERINI, TFF.TFF_PERFIM, TFF.TFF_ESCALA, ABB.ABB_IDCFAL"

If lPrHora
	cAbtIns += ", TFF.TFF_QTDHRS, TFF.TFF_HRSSAL "
EndIf

If lVlPrPar
	cAbtIns += ", TFF.TFF_VLPRPA "
Endif

If lApuraHE
	cAbtIns += ", ABR.R_E_C_N_O_ RECABR"
EndIf

If lAbtIns 
	cAbtIns += ",TFF.TFF_ABTINS%"
Else
	cAbtIns += "%"
EndIf

If lMedExce
	cExprHE := "%AND 1=2%"
EndIf

If lABRCodTFV
	cWhereHE := "%AND ABR2.ABR_CODTFV = '"+Space(TamSx3("ABR_CODTFV")[1])+"'%"
EndIf

//Levanatamento de apontamentos dos apontamentos efetuados
BeginSql Alias cAliasQry

	SELECT %Exp:cAbtIns%,ABR_TEMPO TOT_HOREXT, ABN.ABN_TIPO,
			TFF.TFF_TXLUCR, TFF.TFF_TXADM, TFF.TFF_ENCE,
			COALESCE(TFU.TFU_VALOR, -1) TFU_VALOR, ABB.ABB_CODIGO, TDV.TDV_DTREF
		FROM %table:TFF% TFF
			LEFT JOIN %table:ABQ% ABQ ON ABQ.ABQ_FILIAL = %xFilial:ABQ%
									AND ABQ.ABQ_FILTFF = TFF.TFF_FILIAL
									AND ABQ.ABQ_CODTFF = TFF.TFF_COD
									AND ABQ.%NotDel%
			LEFT JOIN %table:ABB% ABB ON ABB.ABB_FILIAL = %xFilial:ABB%
									AND ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM
									AND ABB.ABB_CHEGOU = 'S' AND ABB.ABB_ATENDE = '1'
									AND ABB.%NotDel%
									%Exp:cWhrJoin%
			LEFT JOIN %table:TDV% TDV ON TDV.TDV_FILIAL = %xFilial:TDV%
									AND TDV.TDV_CODABB = ABB.ABB_CODIGO
									AND TDV.TDV_DTREF BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR03%
									AND TDV.%NotDel%						
			LEFT JOIN %table:AB9% AB9 ON AB9.AB9_FILIAL = %xFilial:AB9%
									AND AB9.AB9_ATAUT = ABB.ABB_CODIGO
									AND AB9.AB9_NUMOS = ABB.ABB_CHAVE
									AND AB9.AB9_ITAPUR =' '
									AND AB9.%NotDel%
			LEFT JOIN %table:ABA% ABA ON ABA.ABA_FILIAL = %xFilial:ABA%
									AND ABA.ABA_NUMOS = AB9.AB9_NUMOS
									AND ABA.ABA_SEQ  =  AB9.AB9_SEQ
									AND ABA.ABA_CODTEC  =  ABB.ABB_CODTEC
									AND ABA.%NotDel%
			LEFT JOIN %table:TFL% TFL ON TFL.TFL_FILIAL = %xFilial:TFL%
									AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
									AND TFL.TFL_CONTRT = %Exp:MV_PAR01%
									AND TFL.TFL_CONREV = %Exp:cRevCtr%
									AND TFL.%NotDel%
									AND (TFL.TFL_TOTRH > 0 OR '1' = %exp:cMedExt% )
			LEFT JOIN %table:ABS% ABS ON ABS.ABS_FILIAL = %xFilial:ABS%
									AND ABS.ABS_LOCAL = TFL.TFL_LOCAL
									AND ABS.%NotDel%
			LEFT JOIN %table:SB1% SB1 ON SB1.B1_FILIAL = %xFilial:SB1%
									AND SB1.B1_COD = TFF.TFF_PRODUT
									AND SB1.%NotDel%
			LEFT JOIN (  SELECT ABR2.R_E_C_N_O_, ABR2.ABR_TEMPO, ABR2.ABR_AGENDA, ABR2.ABR_MOTIVO FROM %table:ABR% ABR2
									INNER JOIN  %table:ABB% ABB2 ON ( ABR2.ABR_AGENDA = ABB2.ABB_CODIGO 
																	 AND ABB2.ABB_FILIAL = %xFilial:ABB%
																	AND ABB2.ABB_CHEGOU = 'S' AND ABB2.ABB_ATENDE = '1'
																	AND ABB2.%NotDel%)
									LEFT JOIN %table:TDV% TDV2 ON TDV2.TDV_FILIAL = %xFilial:TDV%
															AND TDV2.TDV_CODABB = ABB2.ABB_CODIGO
															AND TDV2.TDV_DTREF BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR03%
															AND TDV2.%NotDel%							
															%Exp:cJoinSub%
									WHERE ABR2.ABR_FILIAL = %xFilial:ABR%
									AND ABR2.%NotDel%
									%Exp:cWhereHE% ) ABR  
						  ON  ABR.ABR_AGENDA = ABB.ABB_CODIGO 
			LEFT JOIN %table:ABN% ABN ON ABN.ABN_FILIAL = %xFilial:ABN%
									AND ABN.ABN_CODIGO = ABR.ABR_MOTIVO
									AND ABN.ABN_TIPO = '04'
									AND ABN.%NotDel%
									%Exp:cExprHE%
			LEFT JOIN %table:TFU% TFU ON TFU.TFU_FILIAL = %xFilial:TFU%
									AND TFU.TFU_CODTFF = TFF.TFF_COD
									AND TFU.TFU_CODABN = ABR.ABR_MOTIVO
									AND TFU.%NotDel%
									%Exp:cExprHE%
		WHERE TFF.TFF_FILIAL = %xFilial:TFF%
		AND TFF.%NotDel%
		AND %Exp:cWhereCob%
	ORDER BY TFL_CODIGO, TFF_COD, TDV_DTREF

EndSql

If (cAliasQry)->(!Eof())
	nTotalLine := TotRhItens(MV_PAR01, cRevCtr, lMedExt)
	If oModelTFW:GetMaxLines() < nTotalLine
		oModelTFW:SetMaxLine(nTotalLine) 
	EndIf

	While (cAliasQry)->(!Eof())

		nTotHorRc := 0
		nHorTot := 0 	 
		nHorTotExN := 0  
		nHorExt  := 0
		nValHorE := 0
		nValTFU := 0
		lCalcCrn := .F.
		If lApuraHE
			AADD(aHEsProc, (cAliasQry)->RECABR)
		EndIF
		If !At740Recor(MV_PAR01)
			If EMPTY(aRecorr) .OR. ((nAux := ASCAN(aRecorr, {|a| a[1] == (cAliasQry)->TFF_COD})) == 0)
				If lCalend
					cCalend := (cAliasQry)->TFF_CALEND
				EndIf
				nTotHorRc := TecCalcEsc((cAliasQry)->TFF_ESCALA, MV_PAR02 ,MV_PAR03, cCalend) * (cAliasQry)->TFF_QTDVEN
				AADD(aRecorr, {(cAliasQry)->TFF_COD, nTotHorRc})
			Else
				nTotHorRc := aRecorr[nAux][2]
			EndIf
		EndIf

		aBusca := {}
		AAdd( aBusca, { "TFW_CODTFL", (cAliasQry)->TFL_CODIGO } )
		AAdd( aBusca, { "TFW_CODTFF", (cAliasQry)->TFF_COD    } )

		lExiste := oModelTFW:SeekLine( aBusca )
		If !lMedExce
			If (cAliasQry)->ABN_TIPO == "04"
				If lGsGerOS
					nTotHrN  := (cAliasQry)->TOT_HOR - HoraToInt((cAliasQry)->TOT_HOREXT)
				Else
					nTotSemOS := At930TotHr((cAliasQry)->ABB_CODIGO,.T.)
					nTotHrN  := nTotSemOS - HoraToInt((cAliasQry)->TOT_HOREXT)
				Endif
			Else
				If lGsGerOS
					nTotHrN := (cAliasQry)->TOT_HOR
				Else
					nTotSemOS := At930TotHr((cAliasQry)->ABB_CODIGO,.F.)
					nTotHrN := nTotSemOS
				Endif
			EndIf
		EndIf
		nVlrCont := ((cAliasQry)->TFF_PRCVEN * (cAliasQry)->TFF_QTDVEN ) - (cAliasQry)->TFF_VALDES + (cAliasQry)->TFF_TXLUCR + (cAliasQry)->TFF_TXADM
		
		If !At740Recor(MV_PAR01) .And. (!lApuraHE .And.!lApura) .AND. TecBHasCrn()
		
			cCodTFJ := POSICIONE("TFL",1,xFilial("TFL") + (cAliasQry)->TFL_CODIGO, "TFL_CODPAI")
			cTpItem := "TFF"

			If !EMPTY(Alltrim(STRTRAN(cMV_PAR04,"/"))) .AND. !EMPTY(cCodTFJ)
				cQueryTGT	:= GetNextAlias()
				If lExcedente
					cExprQry := "% AND TGT.TGT_EXCEDT != '1' %"
				Else
					cExprQry := "%%"
				EndIf

				BeginSql Alias cQueryTGT
					SELECT TGT.TGT_VALOR
					FROM %Table:TGT% TGT
					WHERE TGT.TGT_FILIAL	= %exp:xFilial('TGT')%
						AND TGT.TGT_CODTFJ = %exp:cCodTFJ%
						AND TGT.TGT_TPITEM = %exp:cTpItem%
						AND TGT.TGT_CDITEM = %exp:(cAliasQry)->TFF_COD%
						AND TGT.TGT_COMPET = %exp:cMV_PAR04%
						AND TGT.%NotDel%
						%Exp:cExprQry%
				EndSql

				If !(cQueryTGT)->(EOF())
					nVlrCont := (cQueryTGT)->TGT_VALOR
					lCalcCrn := .T.
				EndIf
				(cQueryTGT)->(DbCloseArea())
			EndIf

			If !lCalcCrn .AND. lVlPrPar .And. (cAliasQry)->TFF_VLPRPA <> nVlrCont .AND. !lMedExt
				nVlrCont := (cAliasQry)->TFF_VLPRPA
			EndIf
		Endif
		
		If nTotHorRc >0
			nVlrHor  := nVlrCont / nTotHorRc
		Else
			If lPrHora
				If !Empty((cAliasQry)->TFF_QTDHRS) .OR. TecConvHr((cAliasQry)->TFF_QTDHRS) > 0
					nVlrHor  := nVlrCont / TecConvHr((cAliasQry)->TFF_QTDHRS)
				Else
					nVlrHor  := nVlrCont / (cAliasQry)->ABQ_TOTAL
				EndIf
			Else
				nVlrHor  := nVlrCont / (cAliasQry)->ABQ_TOTAL
			EndIf
		EndIf
		
		nHorTot  := nTotHrN * nVlrHor

		If lAbtIns
			nAbtIns := (cAliasQry)->TFF_ABTINS
		EndIf
		
		If (cAliasQry)->ABN_TIPO == "04" .AND. !lMedExce
			If (cAliasQry)->TFU_VALOR >= 0 // Campos de hora extra
				If (cAliasQry)->TFU_VALOR > 0
					nValHorE := HoraToInt((cAliasQry)->TOT_HOREXT) * (cAliasQry)->TFU_VALOR
					nHorExt  := HoraToInt((cAliasQry)->TOT_HOREXT)	
				Else
					If lHrExtN
						nHorTotExN := HoraToInt((cAliasQry)->TOT_HOREXT)
					Endif
				Endif
			Else
				nValHorE := HoraToInt((cAliasQry)->TOT_HOREXT) * nValTFU
				nHorExt  := HoraToInt((cAliasQry)->TOT_HOREXT)	
			EndIf
		EndIf

		If lGsGerOS
			nTotHora := (cAliasQry)->TOT_HOR - nHorTotExN
		Else
			nTotHora := nTotSemOS - nHorTotExN
		Endif

		nVlrTot  := nValHorE + nHorTot

		If ! lExiste

			If nLinha > 0
				oModelTFW:AddLine()
			Else
				nLinha ++
			EndIf
			
		Else
			If lGsGerOS
				nTotHora := oModelTFW:GetValue( "TFW_TOTHOR" ) + (cAliasQry)->TOT_HOR - nHorTotExN
			Else
				nTotHora := oModelTFW:GetValue( "TFW_TOTHOR" ) + nTotSemOS - nHorTotExN
			Endif
					
			nVlrTot  := oModelTFW:GetValue( "TFW_VLRAPU" ) + nValHorE + nHorTot
			nValHorE := oModelTFW:GetValue( "TFW_VLREXT" ) + nValHorE
			nHorTot  := oModelTFW:GetValue( "TFW_VLHORN" ) + nHorTot
			nTotHrN  := oModelTFW:GetValue( "TFW_HORAN"  ) + nTotHrN
			nHorExt  := oModelTFW:GetValue( "TFW_HORAE"  ) + nHorExt
			If lHrExtN
				nHorTotExN:= oModelTFW:GetValue( "TFW_HREXTN"  ) + nHorTotExN
			Endif
		Endif
		oModelTFW:SetValue( "TFW_CODTFL", (cAliasQry)->TFL_CODIGO )
		oModelTFW:SetValue( "TFW_LOCAL" , (cAliasQry)->TFL_LOCAL  )
		oModelTFW:SetValue( "TFW_DESCRI", (cAliasQry)->ABS_DESCRI )
		If !lApuraHE
			oModelTFW:SetValue( "TFW_HORAN" , nTotHrN 	  		  )
			oModelTFW:SetValue( "TFW_VLHORN", nHorTot  	  		  )
			oModelTFW:SetValue( "TFW_VLRAPU", nVlrTot			  )
		EndIf
		oModelTFW:SetValue( "TFW_TOTHOR", nTotHora				  )
		oModelTFW:SetValue( "TFW_HORAE" , nHorExt 				  )
		oModelTFW:SetValue( "TFW_VLHORE", nValHorE 				  )
		oModelTFW:SetValue( "TFW_VLREXT", nValHorE  			  )
		oModelTFW:SetValue( "TFW_CODTFF", (cAliasQry)->TFF_COD	  )
		oModelTFW:SetValue( "TFW_PRODUT", (cAliasQry)->TFF_PRODUT )
		oModelTFW:SetValue( "TFW_DSCPRO", (cAliasQry)->B1_DESC    )
		oModelTFW:SetValue( "TFW_PLAN",   Posicione("TFL",1,xFilial("TFL")+oModelTFW:GetValue("TFW_CODTFL"),"TFL_PLAN")   )

		If lHrExtN
			oModelTFW:SetValue( "TFW_HREXTN" , nHorTotExN )
		Endif
		
		nDifCalc := StoD((cAliasQry)->TFF_PERFIM) - StoD((cAliasQry)->TFF_PERINI) + 1

		dDtIni := MV_PAR02//Data Inicial da apuração
		dDtFim := MV_PAR03//data Final da apuração

		//Ajusta quantidade de dias para apuração conforme periodo definido no local de atendimento
		If MV_PAR02 < StoD((cAliasQry)->TFF_PERINI)
			dDtIni := StoD((cAliasQry)->TFF_PERINI)
		EndIf
		If MV_PAR03 > StoD((cAliasQry)->TFF_PERFIM)
			dDtFim := StoD((cAliasQry)->TFF_PERFIM)
		EndIf

		nDifDias := (dDtFim - dDtIni) + 1	 //Total de dias a ser apurado

		If nDifCalc > nDifDias .And. At740Recor(MV_PAR01) .And. nDifDias > 0 
			If lPrHora
				If !Empty((cAliasQry)->TFF_QTDHRS) .OR. TecConvHr((cAliasQry)->TFF_QTDHRS) > 0
					nPerCalc :=  (((TecConvHr((cAliasQry)->TFF_QTDHRS) / nDifCalc) * nDifDias) / TecConvHr((cAliasQry)->TFF_QTDHRS)) * 100
				Else
					nPerCalc := (nDifDias / nDifCalc) * 100
				EndIf
			Else
				nPerCalc := (nDifDias / nDifCalc) * 100
			EndIf	
				
			
			oModelTFW:SetValue( "TFW_VLRCON", ((nVlrCont * nPerCalc) / 100) )
			
			If isInCallStack("At930ApuAg")
				oModelTFW:SetValue( "TFW_VLRMED",0 )
			Else
				If lMedExce .OR. lApuraHE
					oModelTFW:SetValue( "TFW_VLRMED", 0 )
				ElseIf !lApura
					oModelTFW:SetValue( "TFW_VLRMED", ((nVlrCont * nPerCalc) / 100) )
				Else
					oModelTFW:SetValue( "TFW_VLRMED", oModelTFW:GetValue( "TFW_VLHORN" )  )
				EndIf	
			EndIF
			oModelTFW:SetValue( "TFW_VLRTOT", oModelTFW:GetValue( "TFW_VLRMED" ) + oModelTFW:GetValue( "TFW_VLHORE" ))
			If lAbtIns
				oModelTFW:SetValue( "TFW_ABTINS", ((nAbtIns * nPerCalc) / 100) )
			EndIf	
		Else
			If nDifDias > 0
				oModelTFW:SetValue( "TFW_VLRCON", nVlrCont )
				
				If isInCallStack("At930ApuAg")
					oModelTFW:SetValue( "TFW_VLRMED",0 )
				Else
					If lMedExce .OR. lApuraHE
						oModelTFW:SetValue( "TFW_VLRMED", 0 )
					ElseIf !lApura
						If lMedExt .And. TecBHasTpA() .And. At930ChkIT((cAliasQry)->TFF_COD,cContrato,MV_PAR02,MV_PAR03)
							oModelTFW:SetValue( "TFW_VLRMED", 0 )
							oModelTFW:SetValue( "TFW_VLHORE", 0 )
						Else
							oModelTFW:SetValue( "TFW_VLRMED", nVlrCont )
						EndIf 	
					Else
						oModelTFW:SetValue( "TFW_VLRMED", oModelTFW:GetValue( "TFW_VLHORN" ) )
					EndIf	
				EndIf
				oModelTFW:SetValue( "TFW_VLRTOT", oModelTFW:GetValue( "TFW_VLRMED" ) + oModelTFW:GetValue( "TFW_VLHORE" ))
				If lAbtINs
					oModelTFW:SetValue( "TFW_ABTINS", nAbtIns )
				EndIf	
			Else
				oModelTFW:SetValue( "TFW_VLRCON",0 )
				oModelTFW:SetValue( "TFW_VLRMED",0 )
				oModelTFW:SetValue( "TFW_VLRTOT",0 )
			EndIf		
		EndIf	

		If lEncePosto .AND. VALTYPE((cAliasQry)->TFF_ENCE) == 'C' .AND. (cAliasQry)->TFF_ENCE  == "1"
			oModelTFW:SetValue( "TFW_VLRMED", 0 )
		EndIf
		If lMedLeg
			oModelTFW:LoadValue("TFW_VGDISP",A930VgDisp(oModelTFW:GetValue("TFW_CODTFF"))) 
			If At930Aloc(oModelTFW:GetValue("TFW_CODTFF"),dDtIni,dDtFim)
				oModelTFW:LoadValue("TFW_LEG","BR_VERDE")
				oModelTFW:LoadValue("TFW_VGALOC",A930VgAloc(oModelTFW:GetValue("TFW_CODTFF"),MV_PAR02,MV_PAR03)) 
			Else
				oModelTFW:LoadValue("TFW_LEG","BR_VERMELHO")
				oModelTFW:LoadValue("TFW_VGALOC",0)
			Endif
		EndIf 

		(cAliasQry)->(dbSkip())

	EndDo
EndIf

(cAliasQry)->(DbCloseArea())
RestArea(aArea)
Return(Nil)

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetVlrProp
Retorna o valor proporcional dentro de um periodo
@sample 	getVlrProp()
@param		dIni - Data inicial para a primeira consistencia
@param		dFim - Data final para a primeira consistencia
@param		nVlr - Valor para a consistencia
@param		dParIni - Data inicial para a segunda consistencia
@param		dParFim - Data final para a segunda consistencia
@return	ExpL	Nil
@since		03/01/2014
@author	Serviços
@version	P11.9
/*/
//------------------------------------------------------------------------------//
Static Function GetVlrProp(dIni, dFim, nVlr, dParIni, dParFim, cApuMed, dEntre, dCole, cCodTFI, nQtdVen, cNumCtr, cModCob)

Local nDifDias	:= (dParFim - dParIni) + 1
Local nDifCalc	:= 0//(dFim - dIni) + 1
Local nRet			:= 0
Local dDtRemes	:= sTod("")
Local nPerCalc	:= 0

Default cApuMed := "1"
Default cNumCtr := ""
Default cModCob := ""

If cApuMed == "1" .or. Empty(cApuMed)
	//Tipo da Apuração -> Inicio Periodo - Fim Periodo
	If valType(dIni) == "C"
		dIni := STOD(dINI)
	EndIf

	If ValType(dFim) == "C"
		dFim := STOD(dFim)
	EndIf

	nDifCalc := (dFim - dIni) + 1

	nDifDias := At930CQtdC(dParIni,dIni,dParFim,dFim)

	If nDifCalc > nDifDias
		nPerCalc := (nDifDias / nDifCalc) * 100
		nRet := (nVlr * nPerCalc)/100
	Else
		nRet := nVlr
	EndIf

ElseIf cApuMed == "2"
	//Tipo da Apuração -> Entrega - Coleta
	If valType(dEntre) == "C"
		dEntre := STOD(dEntre)
	EndIf

	If ValType(dCole) == "C"
		dCole := STOD(dCole)
	EndIf

	nDifCalc := (dCole - dEntre) + 1

	nDifDias := At930CQtdC(dParIni,dEntre,dParFim,dCole)

	If nDifCalc > nDifDias
		nPerCalc := (nDifDias / nDifCalc) * 100
		nRet := (nVlr * nPerCalc)/100
	Else
		nRet := nVlr
	EndIf

ElseIF cApuMed == "3"
	//Tipo da Apuração -> Inicio Periodo - Coleta
	If valType(dIni) == "C"
		dIni := STOD(dINI)
	EndIf

	If ValType(dCole) == "C"
		dCole := STOD(dCole)
	EndIf

	nDifCalc := (dCole - dIni) + 1

	nDifDias := At930CQtdC(dParIni,dIni,dParFim,dCole)

	If nDifCalc > nDifDias
		nPerCalc := (nDifDias / nDifCalc) * 100
		nRet := (nVlr * nPerCalc)/100
	Else
		nRet := nVlr
	EndIf

ElseIF cApuMed == "4"
	//Tipo da Apuração -> Entrega - Fim Periodo
	If valType(dEntre) == "C"
		dEntre := STOD(dEntre)
	EndIf

	If ValType(dFim) == "C"
		dFim := STOD(dFim)
	EndIf

	nDifCalc := (dFim - dEntre) + 1

	nDifDias := At930CQtdC(dParIni,dEntre,dParFim,dFim)

	If nDifCalc > nDifDias
		nPerCalc := (nDifDias / nDifCalc) * 100
		nRet := (nVlr * nPerCalc)/100
	Else
		nRet := nVlr
	EndIf

ElseIF cApuMed == "5" .OR. cApuMed == "6"

	If cApuMed == "5"
		//Tipo da Apuração -> Data Nota de Remessa do Item. - Fim Periodo
		dDtRemes := At930MinDt(cCodTFI, .T.)
	Else
		//Tipo da Apuração -> Data Apuração do Item. - Fim Periodo
		dDtRemes := At930MinDt(cCodTFI, .F.)
	EndIf

	If ValType(dDtRemes) == "C"
		dDtRemes := STOD(dDtRemes)
	EndIf

	If ValType(dFim) == "C"
		dFim := STOD(dFim)
	EndIf

	If dDtRemes <> sTod("")

		nDifCalc := (dFim - dDtRemes) + 1

		nDifDias := At930CQtdC(dParIni,dDtRemes,dParFim,dFim)

		If nDifCalc > nDifDias
			nPerCalc := (nDifDias / nDifCalc) * 100
			nRet := (nVlr * nPerCalc)/100
		Else
			nRet := nVlr
		EndIf
	Else
		nRet := nVlr
	Endif
EndIf

//Quando for contrato recorrente
If !At740Recor(cNumCtr)
	If nDifDias > 0
		If cModCob == "1"
			//Definido que se o tipo de cobrança for "uso", o valor informado no Orçamento é o valor mensal cobrado.
			nRet := nQtdVen
		Else
			nRet := (nQtdVen*30)
		EndIf
	Else
		nRet := 0
	Endif
Endif

Return Round(nRet, 2)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At930LoEq
Load das informações da tela de locação de Equipamentos
@sample 	At930LoEq()
@param		cContrato - Contrato que será apurado
@return	ExpL	Nil
@since		22/11/2013
@author	Serviços
@version	P11.9
/*/
//------------------------------------------------------------------------------//
Static Function At930LoEq(cContrato,oModel)
Local aArea			:= GetArea()
Local cAliasQry	:= GetNextAlias()
Local cCodTfi		:= ""
Local nCont		:= 0
Local nTotal		:= 0
Local nX			:= 0
Local oModelTFL	:= oModel:GetModel("TFLDETAIL")
Local oModelTFI	:= oModel:GetModel("TFIPRODUT")
Local oModelTFZ	:= oModel:GetModel("TFZDETAIL")
Local aTEV			:= {}
Local aTFI			:= {}
Local aTFL			:= {}
Local nPOs			:= 0
Local nI			:= 0
Local nY			:= 0
Local nZ			:= 0
Local nCalcDisp	:= 0
Local nCalcUso	:= 0
Local nCalcMob	:= 0
Local aQtdTFL		:= {}
Local aQtdTFI		:= {}
Local aEquip		:= {}
Local cRevCtr		:= Posicione("CN9",7,xFilial("CN9")+MV_PAR01+"05","CN9_REVISA")
Local nDiasApurados	:= 0
Local nValAddAcres	:= 0
Local nValApuHoras	:= 0
Local aTW7Aresc		:= {}
Local oMdlAcresc		:= Nil
Local lAddline		:= .F.
Local lNotId			:= 0
Local nTotEqupD		:= 0
Local nTotEqupO		:= 0
Local dDataSai		:= Ctod('  /  /    ')
Local dDataRet		:= Ctod('  /  /    ')
Local aDataSai		:= {}
Local aDataRet		:= {}
Local nTotEqupM   	:= 0
Local nQtdApu 		:= 0
Local lRecorre		:= At740Recor(cContrato) //Verifica se o contrato é recorrente
Local lEncePosto		:= SuperGetMv('MV_GSPOSTO',.F.,.F.)
Local nItKit			:= 0
Local aAux				:= {}
Local cMV_TECATF 		:= SuperGetMv('MV_TECATF', .F.,'N') 

BeginSql Alias cAliasQry

	SELECT ABS.ABS_DESCRI, TFL.TFL_FILIAL, TFL.TFL_CODIGO, TFL.TFL_LOCAL,  TFL.TFL_DTINI,  TFL.TFL_DTFIM,
	       TFL.TFL_CODPAI, TFI.TFI_FILIAL, TFI.TFI_COD,    TFI.TFI_PRODUT, TFI.TFI_APUMED, TFI.TFI_ENTEQP,
	       TFI.TFI_PERINI, TFI.TFI_PERFIM, TFI.TFI_TPCOBR, TFI.TFI_SEPSLD, TFL.TFL_PLAN,   TEV.TEV_MODCOB, TEV.TEV_QTDE,
	       TFI.TFI_COLEQP, TEV.TEV_FILIAL, TEV.TEV_CODLOC, TEV.TEV_ITEM,   TFI.TFI_QTDVEN, TFI.TFI_DESCON, TFI.TFI_ITCNB,
	       TEV.TEV_VLRUNI, ((TEV.TEV_VLRUNI * TEV.TEV_QTDE) + TEV.TEV_TXLUCR + TEV.TEV_TXADM - TFI.TFI_VALDES ) TEV_TOTAL,
	       TFI.TFI_ENCE
	  FROM %table:TEV% TEV
	       INNER JOIN %table:TFI% TFI ON TFI.TFI_FILIAL  = %xFilial:TFI%
	                                 AND TFI.%NotDel%
	                                 AND TFI.TFI_COD = TEV.TEV_CODLOC
	       INNER JOIN %table:TFL% TFL ON TFL.TFL_FILIAL = %xFilial:TFL%
	                                 AND TFL.%NotDel%
	                                 AND TFL.TFL_CODIGO = TFI.TFI_CODPAI
	                                 AND TFL.TFL_CONTRT = %Exp:MV_PAR01%
	   									  AND TFL.TFL_CONREV = %Exp:cRevCtr%
	       LEFT JOIN %table:ABS% ABS  ON ABS.ABS_FILIAL = %xFilial:ABS%
	                                 AND ABS.%NotDel%
	                                 AND ABS.ABS_LOCAL = TFL.TFL_LOCAL
	 WHERE TEV.TEV_FILIAL = %xFilial:TEV%
	   AND TEV.%NotDel%
	   AND TFI.TFI_CONTRT = %Exp:MV_PAR01%
	   AND TFI.TFI_CONREV = %Exp:cRevCtr%
	   AND (     ( TFI.TFI_APUMED IN (" ","1","5","6") 	AND TFI.TFI_PERINI <= %Exp:MV_PAR03% AND TFI.TFI_PERFIM >= %Exp:MV_PAR02%)	// 1=Inicio(Locação)/Fim(Locação) , 5=Dt. Nota de Remessa do Item./Fim(Locação) ou 6=Dt. Separação./Fim(Locação)
	          OR ( TFI.TFI_APUMED = "2"            		AND TFI.TFI_ENTEQP <= %Exp:MV_PAR03% AND TFI.TFI_COLEQP >= %Exp:MV_PAR02%)	// 2=Agenda.(Entrega)/Coleta(Equip)
	          OR ( TFI.TFI_APUMED = "3"            		AND TFI.TFI_PERINI <= %Exp:MV_PAR03% AND TFI.TFI_COLEQP >= %Exp:MV_PAR02%)	// 3=Inicio(Locação)/Coleta(Equip)
	          OR ( TFI.TFI_APUMED = "4"            		AND TFI.TFI_ENTEQP <= %Exp:MV_PAR03% AND TFI.TFI_PERFIM >= %Exp:MV_PAR02%)	// 4=Agenda.(Entrega)/Fim(Locação)
	       )
EndSql

nCalcDisp := 0
nCalcUso  := 0
nCalcMob  := 0

At970SetHm()	// Inicializa os valores de medição/apuração de horimetro

aEquip := GetPerDisp(MV_PAR01, cRevCtr, MV_PAR02, MV_PAR03)

While (cAliasQry)->( ! Eof() )

	nPos := aScan(aTFL, {|x| x[_TFLCODIGO] == (cAliasQry)->TFL_CODIGO})
	If nPos == 0
		aAdd(aTFL, Array(_TFLPLAN))
		nPos := Len(aTFL)
		aTfl[nPos][_TFLFILIAL] := (cAliasQry)->TFL_FILIAL
		aTfl[nPos][_TFLCODIGO] := (cAliasQry)->TFL_CODIGO
		aTfl[nPos][_TFLLOCAL]  := (cAliasQry)->TFL_LOCAL
		aTfl[nPos][_TFLDTINI]  := STOD((cAliasQry)->TFL_DTINI)
		aTfl[nPos][_TFLDTFIM]  := STOD((cAliasQry)->TFL_DTFIM)
		aTfl[nPos][_TFLCODPAI] := (cAliasQry)->TFL_CODPAI
		aTfl[nPos][_TFLDESC]   := (cAliasQry)->ABS_DESCRI
		aTfl[nPos][_TFLUSO]    := 0
		aTfl[nPos][_TFLDISP]   := 0
		aTfl[nPos][_TFLMOB]    := 0
		aTfl[nPos][_TFLTOTAL]  := 0
		aTfl[nPos][_TFLTOTAL]  := 0
		aTfl[nPos][_TFLPLAN]   := (cAliasQry)->TFL_PLAN
	EndIf

	nPos := aScan(aTFI, {|x| x[_TFICODIGO] == (cAliasQry)->TFI_COD})
	If nPos == 0
		aAdd(aTFI, Array(_TFIPREV))
		nPos := Len(aTFI)
		aTFI[nPos][_TFIFILIAL] := (cAliasQry)->TFI_FILIAL
		aTFI[nPos][_TFICODIGO] := (cAliasQry)->TFI_COD
		aTFI[nPos][_TFICODPAI] := (cAliasQry)->TFL_CODIGO
		aTFI[nPos][_TFIPRODUT] := (cAliasQry)->TFI_PRODUT
		aTFI[nPos][_TFIDESCON] := (cAliasQry)->TFI_DESCON
		aTFI[nPos][_TFIUSO]    := 0
		aTFI[nPos][_TFIDISP]   := 0
		aTFI[nPos][_TFIMOB]    := 0
		aTFI[nPos][_TFITOTAL]  := 0
		aTFI[nPos][_TFIITCNB]  := (cAliasQry)->TFI_ITCNB
		aTFI[nPos][_TFIQTDVEN]  := (cAliasQry)->TFI_QTDVEN
		aTFI[nPos][_TFIPERINI]  := (cAliasQry)->TFI_PERINI
		aTFI[nPos][_TFIPERFIM]  := (cAliasQry)->TFI_PERFIM
	EndIf

	aAdd(aTEV, Array(_TEVPREV))
	nPos := Len(aTEV)
	aTEV[nPos][_TEVFILIAL]  := (cAliasQry)->TEV_FILIAL
	aTEV[nPos][_TEVCODLOC]  := (cAliasQry)->TEV_CODLOC
	aTEV[nPos][_TEVITEM]    := (cAliasQry)->TEV_ITEM
	aTEV[nPos][_TEVTOTAL]   := (cAliasQry)->TEV_TOTAL
	aTEV[nPos][_TEVMODCOB]  := (cAliasQry)->TEV_MODCOB
	aTEV[nPos][_TEVCODTFI]  := (cAliasQry)->TFI_COD
	aTEV[nPos][_TEVCODTFL]  := (cAliasQry)->TFL_CODIGO
	aTEV[nPos][_TEVQTDORI]  := (cAliasQry)->TEV_QTDE
	aTEV[nPos][_TEVENCTFI]  := (cAliasQry)->TFI_ENCE

	// cálculo da quantidade prevista de locação para o período de locação
	//1=Uso;2=Disponibilidade;3=Mobilizacao;4=Horas;5=Franquia/Excedente
	If aTEV[nPos][_TEVMODCOB] == "4" .Or. aTEV[nPos][_TEVMODCOB] == "5"
		//  Quando for horas ou franquia calcula a quantidade prevista considerando
		// da última atualização do medidor (data mais recente) até a data da última medição ou início de alocação (data mais antiga)
		// Caso não exista lançamento não haverá valor sugerido, nem apurado
		aTEV[nPos][_TEVQTDE]	:= GetVlrHoras( (cAliasQry)->TFI_COD,;
		                                     STOD((cAliasQry)->TFI_PERINI),;
		                                     STOD((cAliasQry)->TFI_PERFIM),;
		                                     (cAliasQry)->TFI_QTDVEN,;
		                                     (cAliasQry)->TEV_QTDE )
	Else
		aTEV[nPos][_TEVQTDE]	:= GetVlrProp((cAliasQry)->TFI_PERINI,;
		                                   (cAliasQry)->TFI_PERFIM,;
		                                   (cAliasQry)->TEV_QTDE,;
		                                   MV_PAR02,;
		                                   MV_PAR03,;
		                                   (cAliasQry)->TFI_APUMED,;
		                                   (cAliasQry)->TFI_ENTEQP,;
		                                   (cAliasQry)->TFI_COLEQP,;
	                                  	   (cAliasQry)->TFI_COD,;
	                                  	   (cAliasQry)->TFI_QTDVEN,;
	                                  	   MV_PAR01,;
	                                  	   aTEV[nPos][_TEVMODCOB])
	EndIf
	aTEV[nPos][_TEVVLRUNI] := (cAliasQry)->TEV_VLRUNI	//TFZ_VLRUNI
	aTEV[nPos][_TEVQTDEAPU] := 0

	// cálculo da quantidade apurada de locação para o período
	If (cAliasQry)->TEV_MODCOB == "2"	//2=Disponibilidade
		aAux	:= {}
		//soma o total de dias alocados de disponibilidade
		nDiasApurados := 0
		nItKit	:= 0

		aEval ( aEquip, {|x| If( x[1] == (cAliasQry)->TFI_COD, (nDiasApurados += x[2]), nil)} )

		For nX := 1 to len (aEquip)
			If !Empty(aEquip[nX][_KITSEQ]) .AND. aEquip[nX][1] == (cAliasQry)->TFI_COD
				nItKit++
				If !ASCAN( aAux, { |x| x[1] == aEquip[nX][_KITSEQ] } ) > 0
					AADD(aAux, { aEquip[nX][_KITSEQ], aEquip[nX][1] })
				EndIf
			Endif
		Next nX

		If len(aAux) > 0
			nDiasApurados := (nDiasApurados / nItKit) * len(aAux)
		EndIf

		//Quando for contrato recorrente
		If !lRecorre .And. nDiasApurados > 30
			aTEV[nPos][_TEVQTDEAPU] :=  aTEV[nPos][_TEVQTDE]
		Else
			aTEV[nPos][_TEVQTDEAPU] :=  nDiasApurados
		EndIf

	ElseIf aTEV[nPos][_TEVQTDE] > 0 .And. ;  // só
		((cAliasQry)->TEV_MODCOB == "4" .Or. (cAliasQry)->TEV_MODCOB == "5")  //4=Horas ou 5=Franquia/Excedente

		//soma as horas lançadas dos equipamentos alocados no item
		nValApuHoras := 0
		aEval( aEquip, {|x| If( x[1] == (cAliasQry)->TFI_COD, nValApuHoras+= x[6], nil) } )

		// quantidade a ser acrescida igual a diferença entre apurada e prevista
		nValAddAcres := nValApuHoras - aTEV[nPos][_TEVQTDE]

		// corrige o valor para ser acrescido quando não há necessidade de acrescentar valor
		nValAddAcres := IIf( nValAddAcres < 0, 0, nValAddAcres )

		// qtde apurada igual a quantidade prevista quando existe valor a ser acrescido
		nValApuHoras := IIf( nValAddAcres > 0, aTEV[nPos][_TEVQTDE], nValApuHoras)

		If nValApuHoras > 0 .And. (cAliasQry)->TEV_MODCOB == "4"
			aTEV[nPos][_TEVQTDEAPU] += nValApuHoras
		EndIf

		If nValAddAcres > 0
			aAdd( aTW7Aresc, Array(_TW7_MAX) )  // cria array para todas as posições
			nI := Len(aTW7Aresc)
			aTW7Aresc[nI,_TW7FILIAL] := (cAliasQry)->TFI_FILIAL
			aTW7Aresc[nI,_TW7TFICOD] := (cAliasQry)->TFI_COD
			aTW7Aresc[nI,_TW7TEVITE] := (cAliasQry)->TEV_ITEM
			aTW7Aresc[nI,_TW7TPPAI]  := "LE"
			aTW7Aresc[nI,_TW7TIPOMV] := "1" // 1=Multa;2=Bonificação
			aTW7Aresc[nI,_TW7DESCRI] := "HORAS EXCEDENTES LOCAÇÃO "
			aTW7Aresc[nI,_TW7VALOR]  := nValAddAcres * (cAliasQry)->TEV_VLRUNI
			aTW7Aresc[nI,_TW7MODO]   := "2" // 1=Automático;2=Manual
			aTW7Aresc[nI,_TW7FLGPED] := "1" // 1=Sim;2=Não
		EndIf
	Else
		aTEV[nPos][_TEVQTDEAPU] += aTEV[nPos][_TEVQTDE]
	EndIf

	(cAliasQry)->(dbSkip())

EndDo

For nI:= 1 To Len(aTFL)
	If nI != 1
		oModelTFL:AddLine()
	EndIf

	oModel:LoadValue("TFLDETAIL", "TFL_FILIAL", aTFL[nI][_TFLFILIAL])
	oModel:LoadValue("TFLDETAIL", "TFL_CODIGO", aTFL[nI][_TFLCODIGO])
	oModel:SetValue("TFLDETAIL",  "TFL_LOCAL",  aTFL[nI][_TFLLOCAL])
	oModel:SetValue("TFLDETAIL",  "TFL_DESLOC", aTFL[nI][_TFLDESC])
	oModel:SetValue("TFLDETAIL",  "TFL_DTINI",  aTFL[nI][_TFLDTINI])
	oModel:LoadValue("TFLDETAIL", "TFL_DTFIM",  aTFL[nI][_TFLDTFIM])
	oModel:LoadValue("TFLDETAIL", "TFL_CODPAI", aTFL[nI][_TFLCODPAI])
	oModel:SetValue("TFLDETAIL",  "TFL_DISP",   aTFL[nI][_TFLDISP])
	oModel:SetValue("TFLDETAIL",  "TFL_USO",    aTFL[nI][_TFLUSO])
	oModel:SetValue("TFLDETAIL",  "TFL_MOBILI", aTFL[nI][_TFLMOB])
	If isInCallStack("At930ApuAg")
		oModel:SetValue("TFLDETAIL",  "TFL_VALTOT", aTFL[nI][_TFLTOTAL])
	EndIf
	oModel:SetValue("TFLDETAIL",  "TFL_PLAN",   aTFL[nI][_TFLPLAN])

	aAdd(aQtdTfl, {aTFL[nI][_TFLCODIGO], .F.})

Next nI

// Ordena pelo código da TFI e fará a adição das linhas em conjunto com a TFI
ASORT(aTW7Aresc, , , { | x,y | x[_TW7TFICOD] > y[_TW7TFICOD] } )
oMdlAcresc := oModel:GetModel("TFITW7DETAIL")

For nY:=1 To Len(aTFI)

	oModelTFL:SeekLine({ {"TFL_CODIGO",aTFI[nY][_TFICODPAI]} })

	nPos := aScan(aQtdTfl, {|x| x[1]==aTFI[nY][_TFICODPAI]})
	If nPos > 0
		If aQtdTfl[nPos][2]
			oModelTFI:AddLine()
		Else
			aQtdTfl[nPos][2] := .T.
		EndIf
	EndIf

	oModel:LoadValue("TFIPRODUT", "TFI_FILIAL", aTFI[nY][_TFIFILIAL])
	oModel:SetValue("TFIPRODUT",  "TFI_PRODUT", aTFI[nY][_TFIPRODUT])
	oModel:LoadValue("TFIPRODUT", "TFI_CODPAI", aTFI[nY][_TFICODPAI])
	oModel:LoadValue("TFIPRODUT", "TFI_COD",    aTFI[nY][_TFICODIGO])
	oModel:SetValue("TFIPRODUT",  "TFI_DISP",   aTFI[nY][_TFIDISP])
	oModel:SetValue("TFIPRODUT",  "TFI_USO",    aTFI[nY][_TFIUSO])
	oModel:SetValue("TFIPRODUT",  "TFI_MOBILI", aTFI[nY][_TFIMOB])
	oModel:SetValue("TFIPRODUT",  "TFI_DESCON", aTFI[nY][_TFIDESCON])
	oModel:SetValue("TFIPRODUT",  "TFI_ITCNB", aTFI[nY][_TFIITCNB])
	oModel:SetValue("TFIPRODUT",  "TFI_QTDVEN", aTFI[nY][_TFIQTDVEN])
	oModel:LoadValue("TFIPRODUT",  "TFI_PERINI", Stod(aTFI[nY][_TFIPERINI]))
	oModel:LoadValue("TFIPRODUT",  "TFI_PERFIM", Stod(aTFI[nY][_TFIPERFIM]))

	aAdd(aQtdTfi, {aTFI[nY][_TFICODIGO], .F.})

	//Realizar a carga da aba de Desconto por OS
	At930LoOs(oModel, aEquip)

	//  avalia se há acréscimos a serem adicionados por causa de uso dos equipamentos com medidores
	// adiciona neste momento para ficar com o vínculo do primeiro item de TFZ depois e não ter problemas na visualização, estorno
	nPos := aScan(aTW7Aresc, {|x| x[_TW7FILIAL]==aTFI[nY,_TFIFILIAL] .And. ;
									x[_TW7TFICOD]==aTFI[nY,_TFICODIGO] })

	If nPos > 0

		nI := Len(aTW7Aresc)
		cCodTfi := aTW7Aresc[nPos,_TW7TFICOD]

		While nPos <= nI .And. aTW7Aresc[nPos,_TW7TFICOD] == cCodTfi

			nI := oMdlAcresc:Length()
			lAddLine := ( nI > 1 .Or. ( nI == 1 .And. !Empty(oMdlAcresc:GetValue("TW7_DESCRI") ) ) )

			If lAddLine
				oMdlAcresc:GoLine(nI)
				oMdlAcresc:AddLine()
				nI := oMdlAcresc:GetLine()
			EndIf

			oMdlAcresc:SetValue("TW7_FILIAL",aTW7Aresc[nPos,_TW7FILIAL])
			oMdlAcresc:SetValue("TW7_TPPAI" ,aTW7Aresc[nPos,_TW7TPPAI])
			oMdlAcresc:SetValue("TW7_TPMOV" ,aTW7Aresc[nPos,_TW7TIPOMV])
			oMdlAcresc:SetValue("TW7_DESCRI",aTW7Aresc[nPos,_TW7DESCRI])
			oMdlAcresc:SetValue("TW7_VALOR" ,aTW7Aresc[nPos,_TW7VALOR])
			oMdlAcresc:SetValue("TW7_MODO"  ,aTW7Aresc[nPos,_TW7MODO])
			oMdlAcresc:SetValue("TW7_FLGPED",aTW7Aresc[nPos,_TW7FLGPED])

			oMdlAcresc:SetValue("TW7_CODPAI",oModel:GetValue("TFZDETAIL", "TFZ_CODIGO"))

			nPos++
		End
	EndIf

Next nY

For nZ:=1 To Len(aTEV)
	If oModelTFL:SeekLine({ {"TFL_CODIGO",aTEV[nZ][_TEVCODTFL]} })
		If oModelTFI:SeekLine({ {"TFI_COD",aTEV[nZ][_TEVCODTFI]},{"TFI_CODPAI",aTEV[nZ][_TEVCODTFL]} })

			nPos := aScan(aQtdTfi, {|x| x[1]==aTEV[nZ][_TEVCODTFI]})
			If nPos > 0
				If aQtdTfi[nPos][2]
					oModelTFZ:AddLine()
				Else
					aQtdTfi[nPos][2] := .T.
				EndIf
			EndIf

	 		  lNotId := cMV_TECATF == 'S' .And. Posicione("SB5",1,xFilial("SB5")+oModelTFI:GetValue('TFI_PRODUT'),'B5_ISIDUNI') == '2'
            If aTEV[nZ][_TEVMODCOB] == '2' .And. lNotId

				//-- Dias da item de locação
				aQtd := At930GetQt(oModelTFI:GetValue('TFI_COD'),oModel:GetModel("TFVMASTER"):GetValue("TFV_DTFIM"))

				aDataSai := {}
				aDataRet 	:= {}
				nDias 	 	 := 0
				nTotEqupO 	 := 0
				nTotEqupD 	 := 0
				nTotEqupM 	 := 0
				nQtdApu 	 := 0
				nTotal 	 := 0


				For nCont := 1 To Len(aQtd)
					aDataSai := {}
					aDataRet := {}

					If !Empty(aQtd[nCont,2])
						Aadd(aDataSai, StoD(aQtd[nCont,2]))
					EndIf

					Aadd(aDataSai, oModel:GetModel("TFVMASTER"):GetValue("TFV_DTINI"))
					Aadd(aDataSai, oModelTFI:GetValue("TFI_PERINI"))

					If !Empty(aQtd[nCont,3])
						Aadd(aDataRet, StoD(aQtd[nCont,3]))
					EndIf

					Aadd(aDataRet, oModel:GetModel("TFVMASTER"):GetValue("TFV_DTFIM"))
					Aadd(aDataRet, oModelTFI:GetValue("TFI_PERFIM"))
                 	dDataSai := GetMax(aDataSai)
                 	dDataRet := GetMin(aDataRet)

					//-- Total do item da locação
					nDias := dDataRet - dDataSai + 1
					If nDias < 0
						nDias := 0
					EndIf
					nTotEqupO   := oModelTFI:GetValue('TFI_QTDVEN') * aTEV[nZ][_TEVQTDORI]
					nTotEqupD   := nDias * aQtd[nCont,1]

					//-- Total da medição
					nTotEqupM   := nTotEqupD / nTotEqupO

					//-- Valor da apuração
					nQtdApu += nTotEqupM * aTEV[nZ][_TEVQTDORI]
				Next nCont
				nTotal := nQtdApu * aTEV[nZ][_TEVVLRUNI] * ( 1 - ( oModelTFI:GetValue('TFI_DESCON') / 100 ) )
			Else
          		nTotal := aTEV[nZ][_TEVQTDEAPU] * aTEV[nZ][_TEVVLRUNI] * ( 1 - ( oModelTFI:GetValue('TFI_DESCON')  / 100 ) )
			EndIf

			oModel:LoadValue("TFZDETAIL", "TFZ_LOCAL",  oModel:GetModel("TFLDETAIL"):GetValue("TFL_LOCAL"))
			oModel:LoadValue("TFZDETAIL", "TFZ_DESCRI", oModel:GetModel("TFLDETAIL"):GetValue("TFL_DESLOC"))
			oModel:LoadValue("TFZDETAIL", "TFZ_CODTFL", oModel:GetModel("TFLDETAIL"):GetValue("TFL_CODIGO"))
			oModel:LoadValue("TFZDETAIL", "TFZ_CODTFI", aTEV[nZ][_TEVCODTFI])
			oModel:LoadValue("TFZDETAIL", "TFZ_CODTEV", aTEV[nZ][_TEVITEM])

			If lEncePosto .AND. VALTYPE(aTEV[nZ][_TEVENCTFI]) == "C" .AND. aTEV[nZ][_TEVENCTFI] == "1"
				oModel:LoadValue("TFZDETAIL", "TFZ_QTDAPU", 0)
			Else
	        	If aTEV[nZ][_TEVMODCOB] == '2' .And. lNotId
	            	oModel:LoadValue("TFZDETAIL", "TFZ_QTDAPU", nQtdApu)
				Else
	            	oModel:LoadValue("TFZDETAIL", "TFZ_QTDAPU", aTEV[nZ][_TEVQTDEAPU])
				EndIf
			EndIf
			oModel:LoadValue("TFZDETAIL", "TFZ_QTDE",   aTEV[nZ][_TEVQTDE])
			oModel:LoadValue("TFZDETAIL", "TFZ_VLRUNI", aTEV[nZ][_TEVVLRUNI])
			oModel:LoadValue("TFZDETAIL", "TFZ_TOTAL",  nTotal)
			oModel:LoadValue("TFZDETAIL", "TFZ_MODCOB", aTEV[nZ][_TEVMODCOB])
			oModel:LoadValue("TFZDETAIL", "TFZ_APURAC", oModel:GetModel("TFVMASTER"):GetValue("TFV_CODIGO"))

			Do Case//Totaliza valores de acordo com o modo de cobrança
				Case aTEV[nZ][_TEVMODCOB] == "1" .OR. aTEV[nZ][_TEVMODCOB] == "4" //Uso ou Horas
					oModel:LoadValue("TFLDETAIL", "TFL_USO", oModel:GetModel("TFLDETAIL"):GetValue("TFL_USO") + nTotal)
					oModel:LoadValue("TFIPRODUT", "TFI_USO", oModel:GetModel("TFIPRODUT"):GetValue("TFI_USO") + nTotal)
				Case aTEV[nZ][_TEVMODCOB] == "2"//Disponibilidade
					oModel:LoadValue("TFLDETAIL", "TFL_DISP", oModel:GetModel( "TFLDETAIL" ):GetValue("TFL_DISP") + nTotal)
					oModel:LoadValue("TFIPRODUT", "TFI_DISP", oModel:GetModel( "TFIPRODUT" ):GetValue("TFI_DISP") + nTotal)
				Case aTEV[nZ][_TEVMODCOB] == "3"//Mobilização
					oModel:LoadValue("TFLDETAIL", "TFL_MOBILI", oModel:GetModel( "TFLDETAIL" ):GetValue("TFL_MOBILI") + nTotal)
					oModel:LoadValue("TFIPRODUT", "TFI_MOBILI", oModel:GetModel( "TFIPRODUT" ):GetValue("TFI_MOBILI") + nTotal)
			EndCase

			oModel:LoadValue("TFLDETAIL", "TFL_VALTOT", oModel:GetModel( "TFLDETAIL" ):GetValue("TFL_VALTOT")+ nTotal )
		EndIf
	EndIf
Next nZ

oModelTFL:GoLine(1)
oModelTFI:GoLine(1)
oModelTFZ:GoLine(1)

(cAliasQry)->(DbCloseArea())
RestArea(aArea)
Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetPerDisp
@since 06/01/2014
@version 11.9
@param        cContrt, character
@param        cRevisa, character
@param        dDtIni, Date
@param        dDtFim, Date
@return       aEquip, Array com equipamento e quantidade de dias utilizados para disponibilidade
@description Recupera estrutura de dados com quantidade de dias dos equipamentos locados
/*/
//------------------------------------------------------------------------------//
Static Function GetPerDisp(cContrt, cRevisa, dDtIni, dDtFim)

Local cAliasTEW	:= GetNextAlias()
Local aArea		:= GetArea()
Local aEquip		:= {}
Local nPos			:= 0
Local dIni			:= STOD("")
Local dFim			:= STOD("")
Local lKit			:= .F.
Local cCodKit		:= ""
Local cKitSeq		:= ""
Local cSpcFilOri	:= SPACE(TamSx3("AA3_FILORI")[1])
Local nHorasApont 	:= 0
Local lOpTri := SuperGetMv('MV_GSOPTRI',.F.,.F.)
Local cSql := ""
Local lAA3Blql := AA3->( ColumnPos('AA3_MSBLQL')) > 0

cSql += "SELECT TFI.TFI_COD, TFI.TFI_APUMED, TEW.TEW_DTRINI, TEW.TEW_DTRFIM, TEW.TEW_DTAMNT, TEW.TEW_CODMV, "
cSql += "       TEW.TEW_BAATD, TEW.TEW_CODKIT, TEW.TEW_KITSEQ, TEW.TEW_DTSEPA ,AA3.AA3_HMEATV, TEW.TEW_MOTIVO "
cSql += "FROM " + RetSqlName('TEW') + " TEW "
cSql += "INNER JOIN " + RetSqlName('TFI') + " TFI ON TFI.TFI_FILIAL = '" + xFilial("TFI") + "' "
cSql += "       AND TFI.TFI_COD = TEW.TEW_CODEQU "
cSql += "       AND TFI.D_E_L_E_T_ = ' ' "
cSql += "INNER JOIN " + RetSqlName('AA3') + " AA3 ON AA3.AA3_NUMSER = TEW.TEW_BAATD "
If !lOpTri
	cSql += "	AND AA3.AA3_FILIAL = '" + xFilial("AA3") + "' "
	cSql += "	AND AA3.AA3_FILORI <> '" + cSpcFilOri + "' "
	cSql += "	AND AA3.AA3_EQALOC = '1' "
Else
	cSql += "	AND AA3.AA3_FILORI = TEW.TEW_FILBAT "
EndIf
If lAA3Blql
	cSql += "	AND AA3.AA3_MSBLQL <> '1' "
EndIf
cSql += "		AND AA3.AA3_CODPRO = TEW.TEW_PRODUT "
cSql += "		AND AA3.D_E_L_E_T_ = ' ' "
cSql += "WHERE TEW.TEW_FILIAL = '" + xFilial("TEW") + "' "
cSql += "		AND TEW.D_E_L_E_T_ = ' ' "
cSql += "		AND TFI.TFI_CONTRT = '" + cContrt + "' "
cSql += "	    AND TFI.TFI_CONREV = '" + cRevisa + "' "
cSql += "		AND TEW.TEW_DTSEPA <> ' ' "
cSql += "		AND ( "
cSql += "	          ( TEW.TEW_DTSEPA BETWEEN '" + DTOS(dDtIni) + "' AND '" + DTOS(dDtFim) + "' ) "
cSql += "	          OR " 
cSql += "	          (     TEW.TEW_MOTIVO <> ' ' "
cSql += "	            AND TEW.TEW_DTAMNT <> ' ' "
cSql += "	            AND TEW.TEW_DTAMNT BETWEEN '" + DTOS(dDtIni) + "' AND '" + DTOS(dDtFim) + "' "
cSql += "	          ) "
cSql += "	          OR "
cSql += "	          (     TEW.TEW_MOTIVO = ' ' "
cSql += "	            AND TEW.TEW_DTRFIM <> ' ' "
cSql += "	            AND TEW.TEW_DTAMNT = ' ' "
cSql += "	            AND TEW.TEW_DTRFIM BETWEEN '" + DTOS(dDtIni) + "' AND '" + DTOS(dDtFim) + "' "
cSql += "	          ) "
cSql += "	          OR "
cSql += "	          (     TEW.TEW_DTSEPA < '" + DTOS(dDtIni) + "' "
cSql += "	            AND ( "
cSql += "	                  ( TEW.TEW_MOTIVO <> ' ' AND (TEW.TEW_DTAMNT = ' ' OR TEW.TEW_DTAMNT > '" + DTOS(dDtFim) + "' ) ) "
cSql += "	                  OR "
cSql += "	                  ( TEW.TEW_MOTIVO = ' ' AND (TEW.TEW_DTRFIM = ' ' OR TEW.TEW_DTRFIM > '" + DTOS(dDtFim) + "' ) ) "
cSql += "	                ) "
cSql += "	          ) "
cSql += "	       ) "
cSql += "	 ORDER BY TFI.TFI_COD "

cSql := ChangeQuery(cSql)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasTEW, .F., .T.)

While (cAliasTEW)->(! Eof())
	If (cAliasTEW)->(TFI_APUMED) == '6' .OR.;
					(!EMPTY((cAliasTEW)->(TEW_DTRINI)) .AND.;
						(;
							((cAliasTEW)->(TEW_DTRINI) >= DTOS(dDtIni) .AND. (cAliasTEW)->(TEW_DTRINI) <= DTOS(dDtFim));
								 .OR.;
							 (;
							 	!EMPTY((cAliasTEW)->(TEW_MOTIVO)) .AND.;
							 	!EMPTY((cAliasTEW)->(TEW_DTAMNT))	.AND.;
							 	(cAliasTEW)->(TEW_DTAMNT) >= DTOS(dDtIni) .AND. (cAliasTEW)->(TEW_DTAMNT) <= DTOS(dDtFim);
							 );
							 	.OR.;
							 (;
							 	EMPTY((cAliasTEW)->(TEW_MOTIVO)) .AND.;
							 	!EMPTY((cAliasTEW)->(TEW_DTRFIM)) .AND.;
							 	EMPTY((cAliasTEW)->(TEW_DTAMNT)) .AND.;
							 	(cAliasTEW)->(TEW_DTRFIM) >= DTOS(dDtIni) .AND. (cAliasTEW)->(TEW_DTRFIM) <= DTOS(dDtFim);
							 );
							 	.OR.;
							 (;
							 	(cAliasTEW)->(TEW_DTRINI) < DTOS(dDtIni);
						 		 .AND.;
						 		  (;
									( !EMPTY((cAliasTEW)->(TEW_MOTIVO)) .AND. ( EMPTY((cAliasTEW)->TEW_DTAMNT) .OR.	(cAliasTEW)->(TEW_DTAMNT) > DTOS(dDtFim) ) );
										.OR.;
									( EMPTY((cAliasTEW)->(TEW_MOTIVO)) .AND. ( EMPTY((cAliasTEW)->TEW_DTRFIM) .OR. (cAliasTEW)->TEW_DTRFIM > DTOS(dDtFim) ) );
						 		  );
							 );
						);
					)
		If (cAliasTEW)->(TFI_APUMED) != '6'
			If (cAliasTEW)->TEW_DTRINI >= DtoS(dDtIni)
				dIni	:= StoD((cAliasTEW)->TEW_DTRINI)
			Else
				dIni	:= dDtIni
			EndIf
		Else
			If (cAliasTEW)->TEW_DTSEPA >= DtoS(dDtIni)
				dIni	:= StoD((cAliasTEW)->TEW_DTSEPA)
			Else
				dIni	:= dDtIni
			EndIf
		EndIf

		If ! Empty((cAliasTEW)->TEW_DTRFIM)
			If (cAliasTEW)->TEW_DTRFIM < DToS(dDtFim)
				dFim	:= StoD((cAliasTEW)->TEW_DTRFIM)
			Else
				dFim	:= dDtFim
			EndIf
		ElseIf ! Empty((cAliasTEW)->TEW_DTAMNT)
			If (cAliasTEW)->TEW_DTAMNT < DToS(dDtFim)
				dFim	:= StoD((cAliasTEW)->TEW_DTAMNT)
			Else
				dFim	:= dDtFim
			EndIf
		Else
			dFim	:= dDtFim
		EndIf

		nPos := aScan(aEquip, {|x| x[1] ==(cAliasTEW)->TFI_COD .And. (cAliasTEW)->TEW_BAATD })
		nHorasApont := 0
		If nPos == 0
			// avalia se tem horímetro ativo no equipamento
			If (cAliasTEW)->AA3_HMEATV == '1'
				// calcula a quantidade de horas lançadas no medidor do equipamento
				At970BldHm((cAliasTEW)->TEW_BAATD, (cAliasTEW)->TEW_CODMV, MV_PAR03)
				nHorasApont := At970TotHm((cAliasTEW)->TEW_BAATD)
			EndIf

			aAdd(aEquip, {(cAliasTEW)->TFI_COD, (dFim-dIni)+1, (cAliasTEW)->TEW_BAATD, dIni, dFim, nHorasApont, (cAliasTEW)->TEW_KITSEQ })
			//Verifica se o produto é de kit, assim soma somente uma vez
			If !Empty((cAliasTEW)->TEW_CODKIT) .And. !Empty((cAliasTEW)->TEW_KITSEQ)
				lKit		:= .T.
				cCodKit	:= (cAliasTEW)->TEW_CODKIT
				cKitSeq	:= (cAliasTEW)->TEW_KITSEQ
			Else
				lKit		:= .F.
				cCodKit	:= (cAliasTEW)->TEW_CODKIT
				cKitSeq	:= (cAliasTEW)->TEW_KITSEQ
			EndIf

		Else

			If lKit .And. cCodKit == (cAliasTEW)->TEW_CODKIT .And. cKitSeq <> (cAliasTEW)->TEW_KITSEQ
				aEquip[nPos][2]	+= (dFim-dIni) + 1
				cCodKit			:= (cAliasTEW)->TEW_CODKIT
				cKitSeq			:= (cAliasTEW)->TEW_KITSEQ
			ElseIf !lKit
				aEquip[nPos][2]	+= (dFim-dIni) + 1
			EndIf

		EndIf
	EndIf
	(cAliasTEW)->(DbSkip())
EndDo

(cAliasTEW)->(dBCloseArea())
RestArea(aArea)
Return aEquip

//------------------------------------------------------------------------------
/*/{Protheus.doc} At930GatQdt
Quatilho para quantidade total da TFZ
@sample 	At930GatQdt()
@param		Nenhum
@return	ExpL	nQntAtu - Quantidade Atual
@since		22/11/2013
@author	Serviços
@version	P11.9
/*/
//------------------------------------------------------------------------------//
Function At930GatQdt()
Local oModel		:= FWModelActive()
Local oModelTFL	:= oModel:GetModel("TFLDETAIL")
Local nVlrAtu	:= 	0
Local nVlrAnt	:=	oModel:GetModel( "TFZDETAIL" ):GetValue( "TFZ_TOTAL" )
Local nVlTot	:=0
Local nVlTotAnt:=0
Local nVlrTFI := 0
Local nVlrTFL := 0

nVlrAtu := oModel:GetValue("TFZDETAIL", "TFZ_QTDAPU") * oModel:GetValue("TFZDETAIL", "TFZ_VLRUNI") * (1 - ( oModel:GetValue("TFIPRODUT", "TFI_DESCON") / 100 ) )
oModel:SetValue("TFZDETAIL", "TFZ_TOTAL", nVlrAtu)

nVlTotAnt := oModel:GetValue("TFLDETAIL", "TFL_USO") + oModel:GetValue("TFLDETAIL", "TFL_DISP") + oModel:GetValue("TFLDETAIL", "TFL_MOBILI")

//Atualiza grid TEV TFI TFL
Do Case//Totaliza valores de acordo com o modo de cobrança
	Case ( oModel:GetValue("TFZDETAIL", "TFZ_MODCOB") == "1" .OR. oModel:GetValue("TFZDETAIL", "TFZ_MODCOB") == "4" )	//Uso ou Horimetro

		nVlrTFI := oModel:GetValue("TFIPRODUT", "TFI_USO") - nVlrAnt + nVlrAtu
		oModel:LoadValue("TFIPRODUT", "TFI_USO", nVlrTFI)

		nVlrTFL := oModel:GetValue("TFLDETAIL", "TFL_USO") - nVlrAnt + nVlrAtu
		oModel:LoadValue("TFLDETAIL", "TFL_USO", nVlrTFL)

	Case oModel:GetValue("TFZDETAIL", "TFZ_MODCOB") == "2"//Disponibilidade

		nVlrTFI := oModel:GetValue("TFIPRODUT", "TFI_DISP") - nVlrAnt + nVlrAtu
		oModel:LoadValue("TFIPRODUT", "TFI_DISP", nVlrTFI)

		nVlrTFL := oModel:GetValue("TFLDETAIL", "TFL_DISP") - nVlrAnt + nVlrAtu
		oModel:LoadValue("TFLDETAIL", "TFL_DISP", nVlrTFL)

	Case oModel:GetValue("TFZDETAIL", "TFZ_MODCOB") == "3"//Mobilização

		nVlrTFI := oModel:GetValue("TFIPRODUT", "TFI_MOBILI") - nVlrAnt + nVlrAtu
		oModel:LoadValue("TFIPRODUT", "TFI_MOBILI", nVlrTFI)

		nVlrTFL := oModel:GetValue("TFLDETAIL", "TFL_MOBILI") - nVlrAnt + nVlrAtu
		oModel:LoadValue("TFLDETAIL", "TFL_MOBILI", nVlrTFL)

EndCase

//Atualiza Total TFL
nVlTot := oModel:GetValue("TFLDETAIL", "TFL_USO") + oModel:GetValue("TFLDETAIL", "TFL_DISP") + oModel:GetValue("TFLDETAIL", "TFL_MOBILI")
oModelTFL:SetValue("TFL_VALTOT", oModel:GetValue("TFLDETAIL", "TFL_VALTOT")-nVlTotAnt + nVlTot)
At930TrgGer( 'TFLDETAIL', 'TFL_VALTOT', 'ZZPDETAIL', 'ZZP_VLRTOT', 4 )
Return (0)


//-------------------------------------------------------------------
/*/{Protheus.doc} LoadStruZZP
Realiza a criação de campos para um model específico para totalizar
Será responsável pelos campos de atualização dos Totalizadores
@author Serviços
@since 19/11/2013
@version P11.9
@params
	oPar1  --> Objeto com a estrutura dos dados para alteração
		a passagem deve ocorrer por parametro
	lPar1  --> indica qual tipo de estrutura carregar
		-----> .T. = Model (Default)
		-----> .F. = View
/*/
//-------------------------------------------------------------------
Static Function LoadStruZZP( oStruct, lView )

Default lView := .F.

If ! lView
	oStruct:AddField( ;
						STR0047,;						// [01] Titulo do campo # "Apuração"
						STR0047,;						// [02] ToolTip do campo # "Apuração"
						"ZZP_APU",;					// [03] Id do Field
						"C",;							// [04] Tipo do campo
						25,;							// [05] Tamanho do campo
						0,;								// [06] Decimal do campo
						/*NIL*/,;						// [07] Code-block de validação do campo
						/*NIL*/,;						// [08] Code-block de validação When do campo
						/*NIL*/,;						// [09] Lista de valores permitido do campo
						/*.F.*/,;						// [10] Indica se o campo tem preenchimento obrigatório
						/*NIL*/,;						// [11] Code-block de inicializacao do campo
						/*.F.*/,;						// [12] Indica se trata-se de um campo chave
						.T.,;							// [13] Indica se o campo pode receber valor em uma operação de update.
						/*.F.*/)						// [14] Indica se o campo é virtual

	oStruct:AddField( ;
						STR0006,;						// [01] Titulo do campo # "Grupo de faturamento"
						STR0006,;						// [02] ToolTip do campo # "Grupo de faturamento"
						"ZZP_GRPFAT",;				// [03] Id do Field
						"C",;							// [04] Tipo do campo
						TamSX3("B1_COD")[1],;		// [05] Tamanho do campo
						0,;								// [06] Decimal do campo
						/*NIL*/,;						// [07] Code-block de validação do campo
						/*NIL*/,;						// [08] Code-block de validação When do campo
						/*NIL*/,;						// [09] Lista de valores permitido do campo
						/*.F.*/,;						// [10] Indica se o campo tem preenchimento obrigatório
						/*NIL*/,;						// [11] Code-block de inicializacao do campo
						/*.F.*/,;						// [12] Indica se trata-se de um campo chave
						.T.,;							// [13] Indica se o campo pode receber valor em uma operação de update.
						/*.F.*/)						// [14] Indica se o campo é virtual

	oStruct:AddField( ;
						STR0005,;						// [01] Titulo do campo # "Descrição"
						STR0005,;						// [02] ToolTip do campo # "Descrição"
						"ZZP_DESC",;					// [03] Id do Field
						"C",;							// [04] Tipo do campo
						TamSX3("B1_DESC")[1],;		// [05] Tamanho do campo
						0,;								// [06] Decimal do campo
						/*NIL*/,;						// [07] Code-block de validação do campo
						/*NIL*/,;						// [08] Code-block de validação When do campo
						/*NIL*/,;						// [09] Lista de valores permitido do campo
						/*.F.*/,;						// [10] Indica se o campo tem preenchimento obrigatório
						/*NIL*/,;						// [11] Code-block de inicializacao do campo
						/*.F.*/,;						// [12] Indica se trata-se de um campo chave
						.T.,;							// [13] Indica se o campo pode receber valor em uma operação de update.
						/*.F.*/)						// [14] Indica se o campo é virtual

	oStruct:AddField( ;
						STR0034,;						// [01] Titulo do campo # "Valor"
						STR0034,;						// [02] ToolTip do campo  # "Valor"
						"ZZP_VLRTOT",;				// [03] Id do Field
						"N",;							// [04] Tipo do campo
						14,;							// [05] Tamanho do campo
						2,;								// [06] Decimal do campo
						/*NIL*/,;						// [07] Code-block de validação do campo
						/*NIL*/,;						// [08] Code-block de validação When do campo
						/*NIL*/,;						// [09] Lista de valores permitido do campo
						/*.F.*/,;						// [10] Indica se o campo tem preenchimento obrigatório
						/*NIL*/,;						// [11] Code-block de inicializacao do campo
						/*.F.*/,;						// [12] Indica se trata-se de um campo chave
						.T.,;							// [13] Indica se o campo pode receber valor em uma operação de update.
						/*.F.*/)						// [14] Indica se o campo é virtual

	oStruct:AddField( ;
						STR0048,;						// [01] Titulo do campo # "Excedente"
						STR0048,;						// [02] ToolTip do campo # "Excedente"
						"ZZP_VLREXT",;				// [03] Id do Field
						"N",;							// [04] Tipo do campo
						14,;							// [05] Tamanho do campo
						2,;								// [06] Decimal do campo
						/*NIL*/,;						// [07] Code-block de validação do campo
						/*NIL*/,;						// [08] Code-block de validação When do campo
						/*NIL*/,;						// [09] Lista de valores permitido do campo
						/*.F.*/,;						// [10] Indica se o campo tem preenchimento obrigatório
						/*NIL*/,;						// [11] Code-block de inicializacao do campo
						/*.F.*/,;						// [12] Indica se trata-se de um campo chave
						.T.,;							// [13] Indica se o campo pode receber valor em uma operação de update.
						/*.F.*/)						// [14] Indica se o campo é virtual

	oStruct:AddField( ;
						STR0093,;						// [01] Titulo do campo # "Multas"
						STR0093,;						// [02] ToolTip do campo # "Multas"
						"ZZP_TOTMUL",;				// [03] Id do Field
						"N",;							// [04] Tipo do campo
						16,;							// [05] Tamanho do campo
						2,;								// [06] Decimal do campo
						/*NIL*/,;						// [07] Code-block de validação do campo
						/*NIL*/,;						// [08] Code-block de validação When do campo
						/*NIL*/,;						// [09] Lista de valores permitido do campo
						/*.F.*/,;						// [10] Indica se o campo tem preenchimento obrigatório
						/*NIL*/,;						// [11] Code-block de inicializacao do campo
						/*.F.*/,;						// [12] Indica se trata-se de um campo chave
						.T.,;							// [13] Indica se o campo pode receber valor em uma operação de update.
						/*.F.*/)						// [14] Indica se o campo é virtual

	oStruct:AddField( ;
						STR0094,;						// [01] Titulo do campo # "Bonificações"
						STR0094,;						// [02] ToolTip do campo # "Bonificações"
						"ZZP_TOTBON",;				// [03] Id do Field
						"N",;							// [04] Tipo do campo
						16,;							// [05] Tamanho do campo
						2,;								// [06] Decimal do campo
						/*NIL*/,;						// [07] Code-block de validação do campo
						/*NIL*/,;						// [08] Code-block de validação When do campo
						/*NIL*/,;						// [09] Lista de valores permitido do campo
						/*.F.*/,;						// [10] Indica se o campo tem preenchimento obrigatório
						/*NIL*/,;						// [11] Code-block de inicializacao do campo
						/*.F.*/,;						// [12] Indica se trata-se de um campo chave
						.T.,;							// [13] Indica se o campo pode receber valor em uma operação de update.
						/*.F.*/)						// [14] Indica se o campo é virtual

	oStruct:AddField( ;
						STR0092,;						// [01] Titulo do campo # "Descontos"
						STR0092,;						// [02] ToolTip do campo # "Descontos"
						"ZZP_TOTDES",;				// [03] Id do Field
						"N",;							// [04] Tipo do campo
						16,;							// [05] Tamanho do campo
						2,;								// [06] Decimal do campo
						/*NIL*/,;						// [07] Code-block de validação do campo
						/*NIL*/,;						// [08] Code-block de validação When do campo
						/*NIL*/,;						// [09] Lista de valores permitido do campo
						/*.F.*/,;						// [10] Indica se o campo tem preenchimento obrigatório
						/*NIL*/,;						// [11] Code-block de inicializacao do campo
						/*.F.*/,;						// [12] Indica se trata-se de um campo chave
						.T.,;							// [13] Indica se o campo pode receber valor em uma operação de update.
						/*.F.*/)						// [14] Indica se o campo é virtual

Else

	oStruct:AddField( ;
						"ZZP_APU",;					// [01] Campo
						"1",;							// [02] Ordem
						STR0047,;						// [03] Titulo # "Apuração"
						STR0047,;						// [04] Descricao # "Apuração"
						/*{}*/,;						// [05] Help
						'C',;							// [06] Tipo do campo   COMBO, Get ou CHECK
						Nil,;							// [07] Picture
						/*''*/,;						// [08] PictVar
						/*NIL*/,;						// [09] F3
						.F.,;							// [10] Editavel
						'',;							// [11] Folder
						/*''*/,;						// [12] Group
						/*{}*/,;						// [13] Lista Combo
						/*10*/,;						// [14] Tam Max CombO
						/*''*/,;						// [15] Inic. Browse
						.F.)							// [16] Virtual

	oStruct:AddField( ;
						"ZZP_GRPFAT",;				// [01] Campo
						"2",;							// [02] Ordem
						STR0006,;						// [03] Titulo # "Grupo de faturamento"
						STR0006,;						// [04] Descricao # "Grupo de faturamento"
						/*{}*/,;						// [05] Help
						'C',;							// [06] Tipo do campo   COMBO, Get ou CHECK
						Nil,;							// [07] Picture
						/*''*/,;						// [08] PictVar
						/*NIL*/,;						// [09] F3
						.F.,;							// [10] Editavel
						'',;							// [11] Folder
						/*''*/,;						// [12] Group
						/*{}*/,;						// [13] Lista Combo
						/*10*/,;						// [14] Tam Max CombO
						/*''*/,;						// [15] Inic. Browse
						.F.)							// [16] Virtual

	oStruct:AddField( ;
						"ZZP_DESC",;					// [01] Campo
						"3",;							// [02] Ordem
						STR0005,;						// [03] Titulo  # "Descrição"
						STR0005,;						// [04] Descricao  # "Descrição"
						/*{}*/,;						// [05] Help
						'C',;							// [06] Tipo do campo   COMBO, Get ou CHECK
						Nil,;							// [07] Picture
						/*''*/,;						// [08] PictVar
						/*NIL*/,;						// [09] F3
						.F.,;							// [10] Editavel
						'',;							// [11] Folder
						/*''*/,;						// [12] Group
						/*{}*/,;						// [13] Lista Combo
						/*10*/,;						// [14] Tam Max CombO
						/*''*/,;						// [15] Inic. Browse
						.F.)							// [16] Virtual

	oStruct:AddField( ;
						"ZZP_VLRTOT",;				// [01] Campo
						"4",;							// [02] Ordem
						STR0034,;						// [03] Titulo # "Valor"
						STR0034,;						// [04] Descricao  # "Valor"
						/*{}*/,;						// [05] Help
						'N',;							// [06] Tipo do campo   COMBO, Get ou CHECK
						"@E 999,999,999,999.99",;	// [07] Picture
						/*''*/,;						// [08] PictVar
						/*NIL*/,;						// [09] F3
						.F.,;							// [10] Editavel
						'',;							// [11] Folder
						/*''*/,;						// [12] Group
						/*{}*/,;						// [13] Lista Combo
						/*10*/,;						// [14] Tam Max CombO
						/*''*/,;						// [15] Inic. Browse
						.F.)							// [16] Virtual

	oStruct:AddField( ;
						"ZZP_VLREXT",;				// [01] Campo
						"5",;							// [02] Ordem
						STR0048,;						// [03] Titulo # "Excedente"
						STR0048,;						// [04] Descricao # "Excedente"
						/*{}*/,;						// [05] Help
						'N',;							// [06] Tipo do campo   COMBO, Get ou CHECK
						"@E 999,999,999,999.99",;	// [07] Picture
						/*''*/,;						// [08] PictVar
						/*NIL*/,;						// [09] F3
						.F.,;							// [10] Editavel
						'',;							// [11] Folder
						/*''*/,;						// [12] Group
						/*{}*/,;						// [13] Lista Combo
						/*10*/,;						// [14] Tam Max CombO
						/*''*/,;						// [15] Inic. Browse
						.F.)							// [16] Virtual

	oStruct:AddField( ;
						"ZZP_TOTMUL",;				// [01] Campo
						"6",;							// [02] Ordem
						STR0093,;						// [03] Titulo # "Multas"
						STR0093,;						// [04] Descricao  # "Multas"
						/*{}*/,;						// [05] Help
						'N',;							// [06] Tipo do campo   COMBO, Get ou CHECK
						"@E 999,999,999,999.99",;	// [07] Picture
						/*''*/,;						// [08] PictVar
						/*NIL*/,;						// [09] F3
						.F.,;							// [10] Editavel
						'',;							// [11] Folder
						/*''*/,;						// [12] Group
						/*{}*/,;						// [13] Lista Combo
						/*10*/,;						// [14] Tam Max CombO
						/*''*/,;						// [15] Inic. Browse
						.F.)							// [16] Virtual

	oStruct:AddField( ;
						"ZZP_TOTBON",;				// [01] Campo
						"7",;							// [02] Ordem
						STR0094,;						// [03] Titulo # "Bonificações"
						STR0094,;						// [04] Descricao  # "Bonificações"
						/*{}*/,;						// [05] Help
						'N',;							// [06] Tipo do campo   COMBO, Get ou CHECK
						"@E 999,999,999,999.99",;	// [07] Picture
						/*''*/,;						// [08] PictVar
						/*NIL*/,;						// [09] F3
						.F.,;							// [10] Editavel
						'',;							// [11] Folder
						/*''*/,;						// [12] Group
						/*{}*/,;						// [13] Lista Combo
						/*10*/,;						// [14] Tam Max CombO
						/*''*/,;						// [15] Inic. Browse
						.F.)							// [16] Virtual

	oStruct:AddField( ;
						"ZZP_TOTDES",;				// [01] Campo
						"8",;							// [02] Ordem
						STR0092,;						// [03] Titulo # "Descontos"
						STR0092,;						// [04] Descricao  # "Descontos"
						/*{}*/,;						// [05] Help
						'N',;							// [06] Tipo do campo   COMBO, Get ou CHECK
						"@E 999,999,999,999.99",;	// [07] Picture
						/*''*/,;						// [08] PictVar
						/*NIL*/,;						// [09] F3
						.F.,;							// [10] Editavel
						'',;							// [11] Folder
						/*''*/,;						// [12] Group
						/*{}*/,;						// [13] Lista Combo
						/*10*/,;						// [14] Tam Max CombO
						/*''*/,;						// [15] Inic. Browse
						.F.)							// [16] Virtual
EndIf
Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} At930TrgGer
@sample 	At930TrgGer( "CALC_TFH", "TOT_MC", "TFF_RH", "TFF_TOTMC" )
@since		19/11/2013
@version	P11.90
/*/
//------------------------------------------------------------------------------
Function At930TrgGer( cMdlCalc, cCpoTot, cMdlCDom, cCpoCDOM, nLine )
Local aSaveLines	:= FWSaveRows()
Local oMdl			:= FwModelActive()
Local oView		:= FwViewActive()
Local nLineAnt	:= oMdl:GetModel( cMdlCalc ):GetLine()
Local nValor		:= 0
Local nX

If	oMdl:GetModel( cMdlCDom ):Length() >= 4
	For	nX := 1 To oMdl:GetModel( cMdlCalc ):Length()
		oMdl:GetModel( cMdlCalc ):GoLine(nX)
		nValor += oMdl:GetModel( cMdlCalc ):GetValue( cCpoTot )
	Next nX

	oMdl:GetModel( cMdlCDom ):GoLine(nLine)
	oMdl:GetModel( cMdlCDom ):SetValue( cCpoCDOM, nValor )
EndIf

oMdl:GetModel( cMdlCalc ):GoLine(nLineAnt)

If	!IsBlind() .And. oMdl:GetId() == "TECA930" .And. oView:IsActive()
	oView:Refresh()
EndIf

FWRestRows( aSaveLines )

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} At930TrgRh
@sample 	At930TrgRh( "CALC_TFH", "TOT_MC", "TFF_RH", "TFF_TOTMC" )
@since		12/12/2013
@version	P11.90
/*/
//------------------------------------------------------------------------------
Function At930TrgRH( cMdlCalc, cCpoTot, cMdlCDom, cCpoCDOM, nLine )
Local aSaveLines	:= FWSaveRows()
Local oMdl			:= FwModelActive()
Local oView		:= FwViewActive()
Local nLinha		:= oMdl:GetModel(cMdlCalc):GetLine()
Local nVlrTotal	:= 0

At930TrgGer( cMdlCalc, cCpoTot, cMdlCDom, cCpoCDOM, nLine )

oMdl:GetModel(cMdlCalc):GoLine(nLinha)

nVlrTotal :=	oMdl:GetModel(cMdlCalc):GetValue("TFW_VLRMED") + oMdl:GetModel(cMdlCalc):GetValue("TFW_VLREXT")

oMdl:GetModel(cMdlCalc):SetValue("TFW_VLRTOT", nVlrTotal )

If	oMdl:GetId() == "TECA930" .And. oView:IsActive()
	oView:Refresh()
EndIf

FWRestRows( aSaveLines )

Return(0)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At930Grv
	Interface para gravação e geração da apuração/medição
@sample 	At930Grv(oMdlGeral)
@author 	Serviços
@since		19/11/2013
@version	P11.90
@param  	oExp, Objeto, objeto do modelo de dados a ser gravado
@return  	lRet, Logico, status da gravação
/*/
//------------------------------------------------------------------------------
Function At930Grv( oModel, aNumMed )

Local cCodTFL		:= ""
Local lRet			:= .T.
Local cAliasTFL	:= GetNextAlias()
Local oTFVMaster := oModel:GetModel('TFVMASTER')
Local cMV_PAR01	:= oTFVMaster:GetValue("TFV_CONTRT")  // Contrato
Local cMV_PAR02	:= oTFVMaster:GetValue("TFV_DTINI")   // Data Inicial
Local cMV_PAR03	:= oTFVMaster:GetValue("TFV_DTFIM")   // Data Final
Local aCabApu		:= {} // Dados para o cabecalho da apuração
Local aIteApu		:= {} // Dados para os dados da medicao normal
Local aItExApu	:= {} // Dados para a medicao dos valores excedentes
Local aCmboCmp	:= {}
Local aCabe		:= {}
Local aItem		:= {}
Local aItemExc	:= {}
Local nPosPlan	:= 0
Local nPosCab		:= 0
Local nPosExt		:= 0
Local nTotMed		:= 0
Local nTotExt		:= 0
Local cOpcApu		:= oTFVMaster:GetValue("TFV_HREXTR")
Local cAliasQry	:= GetNextAlias()
Local cAliasIMI	:= GetNextAlias()
Local cAliasIMC	:= GetNextAlias()
Local cAliasTEW	:= GetNextAlias()
Local cOperConc	:= if(Trim(Upper(TcGetDb())) $ "ORACLE,POSTGRES,DB2,INFORMIX","||","+")
Local nVlrTot		:= 0
Local cRevCtr		:= ''  // inicializa vazio para conseguir carregar o pergunte correto
Local aRateio		:= {}
Local nI			:= 0
Local nJ			:= 0
Local nX			:= 0
Local nY			:= 0
Local nZ        := 0
Local nW        := 0
Local nU        := 0
Local cIdcABQ		:= ''
Local cLocal		:= ''
Local xAux			:= Nil
Local xAuxPed		:= Nil
Local nPosIAP		:= 0
Local aMedGCT		:= {}
Local cNumMed		:= ""
Local cWhereCob	:= ""
Local nPos			:= 0
Local aPedCabec	:= {}
Local aPedItens	:= {}
Local aLocPed		:= {}
Local aItePed		:= {}
Local aAreaSX3	:= {}
Local aArea		:= {}
Local nItePed		:= 0
Local nPosLocal	:= 0
Local aTEVUpdate	:= {}
Local nDecTFW		:= 2
Local nDecTFX		:= 2
Local nDecTFY		:= 2
Local nPosItItens	:= 0
Local nVlrMulta	:= 0
Local nVlrBoni	:= 0
Local nVlrDesc	:= 0
Local lOrcPrc		:= SuperGetMv("MV_ORCPRC",,.F.)
Local lSomaImp	:= SuperGetMv("MV_ATOPIMP",,.T.) // verifica o parâmetro de incorporação do valor do imposto
Local lGsISS	:= SuperGetMv("MV_GSISS",,.F.)
Local nVlrHora	:= 0
Local nPercHre	:= 0
Local aMultas		:= {}
Local cTipoFrete	:= ""
Local cGrpCom		:= ""
Local cNumProp	:= ""
Local cNumCtr		:= ""
Local cChave		:= ""
Local lDsgCN 		:= .F.
Local oTFWDetail := oModel:GetModel("TFWDETAIL")
Local oTFXDetail := oModel:GetModel("TFXDETAIL")
Local oTFYDetail := oModel:GetModel("TFYDETAIL")
Local oTFLDetail := oModel:GetModel("TFLDETAIL")
Local oTFIDetail := oModel:GetModel("TFIPRODUT")
Local oTFZDetail := oModel:GetModel("TFZDETAIL")
Local nTotItem 	:= 0
Local aItnsRef	:= {}
Local cItem		:= ""
Local cPict 		:= PesqPict("CNB","CNB_VLTOT")
Local nRetCNF		:= 0
Local cCodLoc		:= ""
Local aComplSC5	:= {}
Local cTESExced	:= ""
Local lFatAntecip 	:= ( oTFVMaster:GetValue("TFV_ANTECI") == "1" )
Local lAgrupa := SuperGetMv("MV_GSDSGCN",,"2") == "2"
Local nAuxAgrp := 0
Local lAbtInss	 := TFF->( ColumnPos('TFF_ABTINS') ) > 0 
Local aPVS
Local cCodIss := ""
Local cAliasIss
Local cSql := ""
Local cProdTFF
Local nAuxPvs
Local nAuxIts
Local cAuxItemPV
Local nAuxVl
Local nPosLcPed := 0
Local nLastItem := 0
Local nPosIt 	:= 0
Local nK 		:= 0
Local aLocPed2 := {}
Local aItePed2 := {}
Local aIteTCV	:= {}
Local nVlrHre	:= 0
Local nLinha 	:= 1
Local nPosLocTCV := 0
Local aItAux := {}
Local cCodProd := ""
Local cCodCli := ""
Local cLjCli := ""
Local lGsGerOS  := At930GerOs()
Local aPlan		:= {}
Local cAgrup	:= IIF(TFV->( ColumnPos('TFV_AGRUP') ) > 0, oTFVMaster:GetValue("TFV_AGRUP"), "2")
Local lContinu	:= .T.
Local lCliFat	:= .F.
Local lItemTCV	:= At930MeTCV()
Local lAT930PVE	:= ExistBlock("AT930PVE")
Local aDescs	:= {}
Local aRetPe	:= {}
Local lMonitor	:= FwIsInCallStack("ApurJobAux")
Local lMV_GSLOG := Iif(lMonitor,SuperGetMV('MV_GSLOG',,.F.),.F.)
Local oGsLog	:= GsLog():New(lMV_GSLOG)
Local cErro 	:= ""
Local lExcedente := TecBHasCrn() .AND. TecBHasExc() .AND. (oTFVMaster:GetValue("TFV_TOTEXC") > 0)
Local nComp		:= 0

Default aNumMed		   := {}
Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .F.

cRevCtr := Posicione("CN9",7,xFilial("CN9")+oTFVMaster:GetValue("TFV_CONTRT")+"05","CN9_REVISA")
cIdcABQ := "%ABQ.ABQ_CONTRT" + cOperConc + "ABQ.ABQ_ITEM" + cOperConc + "ABQ.ABQ_ORIGEM%"

// Sql para buscar todos os locais e planilha disponiveis no contrato
BeginSql Alias cAliasTFL

	SELECT TFL.TFL_CODIGO, TFL.TFL_LOCAL , TFL.TFL_CONTRT, TFL.TFL_CONREV, TFL.TFL_PLAN  ,
  	       TFL.TFL_ITPLRH, TFL.TFL_ITPLMI, TFL.TFL_ITPLMC, TFL.TFL_ITPLLE, ABS.ABS_CCUSTO,
  	       TFJ.TFJ_CODIGO, TFJ.TFJ_CODENT, TFJ.TFJ_LOJA  , TFJ.TFJ_CONDPG, TFJ.TFJ_TPFRET,
  	       TFJ.TFJ_GRPCOM, TFJ.TFJ_PROPOS, TFJ.TFJ_CONTRT, TFJ.TFJ_CONREV, TFJ.TFJ_DSGCN ,
  	       TFJ.TFJ_GRPRH , TFJ.TFJ_GRPMI , TFJ.TFJ_GRPMC , TFJ.TFJ_GRPLE , ABS.ABS_CLIFAT,
          ABS.ABS_LJFAT
  	  FROM %table:TFL% TFL
	       JOIN %table:ABS% ABS ON ABS.ABS_FILIAL = %xFilial:ABS%
	                           AND ABS.ABS_LOCAL = TFL.TFL_LOCAL
	                           AND ABS.%NotDel%
	       JOIN %table:TFJ% TFJ ON TFJ.TFJ_FILIAL = %xFilial:TFJ%
	                           AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI
	                           AND TFJ.%NotDel%
	 WHERE TFL.TFL_FILIAL = %xFilial:TFL%
	   AND TFL.TFL_CONTRT = %Exp:cMV_PAR01%
	   AND TFL.TFL_CONREV = %Exp:cRevCtr%
	   AND TFL.%NotDel%

EndSql

If (cAliasTFL)->(!Eof())
	lDsgCN := (cAliasTFL)->(TFJ_DSGCN) == '1'
EndIf

cLocal := "%("

While (cAliasTFL)->(!Eof())

	DbSelectArea("TFJ")
	TFJ->(dbSetOrder(1))
	If TFJ->(dbSeek(xFilial("TFJ")+(cAliasTFL)->TFJ_CODIGO))
		lCliFat:= .F.

		If !Empty(Alltrim((cAliasTFL)->ABS_CLIFAT)) .AND. !Empty(Alltrim((cAliasTFL)->ABS_LJFAT))
			cQuery:= " SELECT 1 R_E_C_N_O_ "
			cQuery+= " FROM "+RetSqlName("CNC")+" CNC "
			cQuery+= " WHERE CNC.CNC_FILIAL	= '"+xFilial("CNC")+"' "
			cQuery+= " AND CNC.CNC_NUMERO	= '"+cMV_PAR01+"' "
			cQuery+= " AND CNC.CNC_REVISA	= '"+cRevCtr+"' "
			cQuery+= " AND CNC.CNC_CLIENT	= '"+ABS->ABS_CLIFAT+"' "
			cQuery+= " AND CNC.CNC_LOJACL	= '"+ABS->ABS_LJFAT+"' "
			cQuery+= " AND CNC.D_E_L_E_T_	= '' "
			cQuery:= ChangeQuery(cQuery)
			cAliasCNC := GetNextAlias()

			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCNC,.T.,.T.)
			If (cAliasCNC)->(!EOF())
				lCliFat:= .T.
			EndIf
			(cAliasCNC)->(DbCloseArea())
		EndIf

		If lCliFat
			cCodCli:= (cAliasTFL)->ABS_CLIFAT
			cLjCli:= (cAliasTFL)->ABS_LJFAT
		Else
			At850GetCli( @cCodCli, @cLjCli, (cAliasTFL)->TFL_LOCAL )
		EndIf
	EndIf

	AADD(aPlan, {(cAliasTFL)->TFL_CODIGO,;
				(cAliasTFL)->TFL_PLAN,;
				.T.,;
				0})
	If lExcedente .AND. lMedExce .AND. lRet
		lRet := lRet .AND. GeraPvExce(cCodCli,;
								cLjCli,;
								(cAliasTFL)->TFL_CODIGO,;
								TFJ->TFJ_CODIGO,;
								TecBDt2Cmp(oTFVMaster:GetValue("TFV_DTINI")),;
								TFJ->TFJ_CONDPG,;
								TFJ->TFJ_TPFRET)
	ElseIf lMedExt 
		aAdd( aLocPed, { 	(cAliasTFL)->TFL_CODIGO,; //[ 1]
							(cAliasTFL)->ABS_CCUSTO,; //[ 2]
							cCodCli,;                 //[ 3]
							cLjCli,;                  //[ 4]
							(cAliasTFL)->TFJ_CONDPG,; //[ 5]
							(cAliasTFL)->TFJ_TPFRET,; //[ 6]
							(cAliasTFL)->TFJ_GRPRH,;  //[ 7]
							(cAliasTFL)->TFJ_GRPMI,;  //[ 8]
							(cAliasTFL)->TFJ_GRPMC,;  //[ 9]
							(cAliasTFL)->TFJ_GRPLE} ) //[10]

	Else
		If cOpcApu == "2" //Hora-extra apurar em excedentes
			aAdd( aLocPed2, { 	(cAliasTFL)->TFL_CODIGO,; //[ 1]
								(cAliasTFL)->ABS_CCUSTO,; //[ 2]
								cCodCli,;                 //[ 3]
								cLjCli,;                  //[ 4]
								(cAliasTFL)->TFJ_CONDPG,; //[ 5]
								(cAliasTFL)->TFJ_TPFRET,; //[ 6]
								(cAliasTFL)->TFJ_GRPRH,;  //[ 7]
								(cAliasTFL)->TFJ_GRPMI,;  //[ 8]
								(cAliasTFL)->TFJ_GRPMC,;  //[ 9]
								(cAliasTFL)->TFJ_GRPLE} ) //[10]
		
		EndIf
		// Itens para o cabecalho da apuração
		If cAgrup <> '1'
			aAdd(aCabApu, { 	(cAliasTFL)->TFL_CODIGO/*1*/, (cAliasTFL)->TFL_CONTRT/*2*/,;
								(cAliasTFL)->TFL_CONREV/*3*/, (cAliasTFL)->TFL_PLAN/*4*/,;
								0/*5*/, .T./*6*/, "1"/*7*/,0/*8*/,0/*8*/,0/*10*/,0/*11*/} )//Total da medição
		Else
			If (nPosLocal := aScan(aCabApu, { |x| x[2] == (cAliasTFL)->TFJ_CONTRT } )) == 0
				aAdd(aCabApu, {{},;
								(cAliasTFL)->TFJ_CONTRT,;
								(cAliasTFL)->TFJ_CONREV,;
								Nil,;
								0,;
								.T.,;
								"1",;
								0,;
								0,;
								0,;
								0})
			EndIf
		EndIf
		If !Empty((cAliasTFL)->TFL_ITPLRH) // itens para a planilha do RH
			aAdd(aIteApu, { 1, (cAliasTFL)->TFL_CODIGO, (cAliasTFL)->TFL_PLAN,;
								  (cAliasTFL)->TFL_ITPLRH, 0 } )
		EndIf

	  	If !Empty((cAliasTFL)->TFL_ITPLMI) // itens para a planila do Material de Implantacao
	  		aAdd(aIteApu, { 2, (cAliasTFL)->TFL_CODIGO, (cAliasTFL)->TFL_PLAN,;
	  							  (cAliasTFL)->TFL_ITPLMI, 0 } )
	  	EndIf

	  	If !Empty((cAliasTFL)->TFL_ITPLMC) // itens para a planilha do Material de Consumo
	  		aAdd(aIteApu, { 3, (cAliasTFL)->TFL_CODIGO, (cAliasTFL)->TFL_PLAN,;
	  							  (cAliasTFL)->TFL_ITPLMC, 0 } )
	  	EndIf

	  	If !Empty((cAliasTFL)->TFL_ITPLLE) // itens para a planilha da Locacao de Equipamento
	  		aAdd(aIteApu, { 4, (cAliasTFL)->TFL_CODIGO, (cAliasTFL)->TFL_PLAN,;
	  						    (cAliasTFL)->TFL_ITPLLE, 0 } )
	  	EndIf

	EndIf

	cLocal += "'" + (cAliasTFL)->TFL_LOCAL + "'"

	If !Empty((cAliasTFL)->TFJ_GRPCOM) .AND. Empty(cGrpCom)
		cGrpCom  := (cAliasTFL)->TFJ_GRPCOM
		cNumProp := (cAliasTFL)->TFJ_PROPOS
		cNumCtr  := (cAliasTFL)->TFJ_CONTRT
	Endif
	(cAliasTFL)->(dbSkip())

	If (cAliasTFL)->(!Eof())
		cLocal += ","
	EndIf

EndDo

(cAliasTFL)->(dBCloseArea())

If cAgrup != '1' 
 	lMsgRpl :=  oModel:GetModel("TWBDETAIL"):Length() > 1

EndIf

For nI := 1 To oModel:GetModel("TWBDETAIL"):Length()
	oModel:GetModel("TWBDETAIL"):GoLine(nI)

	nPosCab := aScan( aPlan, { |x| x[1] == oModel:GetModel("TWBDETAIL"):GetValue("TWB_CODTFL") } )
	
	If nPosCab > 0
		AADD( aPlan[nPosCab], oModel:GetModel("TWBDETAIL"):GetValue("TWB_CLIENT") )
		AADD( aPlan[nPosCab], oModel:GetModel("TWBDETAIL"):GetValue("TWB_LOJA") )
	EndIf

Next nI
If cAgrup == '1'
	aCabApu[Len(aCabApu)][1] :=  aPlan	
EndIf
cLocal += ")%"

// Verificar a quantidade de casas decimais dos campos
aAreaSX3  := SX3->(GetArea())
DbSelectArea("SX3")
SX3->(dbSetOrder(2))
If SX3->(DbSeek("TFW_VLRTOT"))
	nDecTFW := SX3->X3_DECIMAL
Endif
If SX3->(DbSeek("TFX_VLRMED"))
	nDecTFX := SX3->X3_DECIMAL
Endif
If SX3->(DbSeek("TFY_VLRMED"))
	nDecTFY := SX3->X3_DECIMAL
Endif
SX3->(RestArea(aAreaSX3))

dbSelectArea( 'TGU' )
TGU->( dbSetOrder( 1 ) )

dbSelectArea( 'TFL' )
TFL->( dbSetOrder( 4 ) )
If !lMedExce .AND. !lApuraHE
	If lMedExt
		for nI:=1 to len( aLocPed )
			cChave := xFilial("TGU")+ aLocPed[nI,1]
			If TGU->(dbSeek(cChave) )
				While TGU->( !Eof() ) .And. TGU->(TGU_FILIAL+TGU_CODTFL)==cChave
					Reclock("TGU",.F.)
					TGU->TGU_APURAC := oTFVMaster:GetValue("TFV_CODIGO")
					TGU->(MsUnlock())
					TGU->( dbSkip() )
				enddo
			endif
		next
	else
		If cAgrup <> '1'
			for nI:=1 to len( aCabApu )
				cChave := xFilial("TGU")+ aCabApu[nI,1]
				If TGU->(dbSeek(cChave ) )
					While TGU->( !Eof() ) .And. TGU->(TGU_FILIAL+TGU_CODTFL)==cChave
						Reclock("TGU",.F.)
						TGU->TGU_APURAC := oTFVMaster:GetValue("TFV_CODIGO")
						TGU->(MsUnlock())
						TGU->( dbSkip() )
					enddo
				endif
			next
		Else
			for nI:=1 to len( aCabApu[1][1] )
				cChave := xFilial("TGU")+ aCabApu[1,1,nI,1]
				If TGU->(dbSeek(cChave ) )
					While TGU->( !Eof() ) .And. TGU->(TGU_FILIAL+TGU_CODTFL)==cChave
						Reclock("TGU",.F.)
						TGU->TGU_APURAC := oTFVMaster:GetValue("TFV_CODIGO")
						TGU->(MsUnlock())
						TGU->( dbSkip() )
					enddo
				endif
			next
		EndIf
	endif
EndIf
// ----- MEDIÇAO RH
//Totalizando itens da apuração do RH
For nI := 1 To oTFWDetail:Length()

	oTFWDetail:GoLine(nI)
	
	If lMedExt .OR. cOpcApu == "2"
		If lItemTCV .AND. oTFWDetail:GetValue("TFW_VLRTOT") > 0
			If (nPosLocTCV := aScan(aIteTCV, { |x| x[1] == oTFWDetail:GetValue("TFW_CODTFL") } )) > 0
				AADD(aIteTCV[nPosLocTCV][2], {"TFF", oTFWDetail:GetValue("TFW_CODTFF"), oTFWDetail:GetValue("TFW_PRODUT")})
			Else
				AADD(aIteTCV, {oTFWDetail:GetValue("TFW_CODTFL") ,{{"TFF", oTFWDetail:GetValue("TFW_CODTFF"), oTFWDetail:GetValue("TFW_PRODUT")}}})
			EndIf
		EndIf
	Endif		

	If lMedExt

		nPosLocal := aScan(aItePed, { |x| x[1] == oTFWDetail:GetValue("TFW_CODTFL") } )
		If nPosLocal == 0

			aAdd( aItePed, { oTFWDetail:GetValue("TFW_CODTFL"),;
						 { { { "C6_ITEM", StrZero( 1, TamSx3('C6_ITEM')[1] ), Nil },;
						  	{ "C6_PRODUTO", IIF(lAgrupa, aLocPed[1][7] ,oTFWDetail:GetValue("TFW_PRODUT")), Nil },;
						  	{ "C6_QTDVEN", 1, Nil },;
						  	{ "C6_PRCVEN", Round(oTFWDetail:GetValue("TFW_VLRTOT"),nDecTFW), Nil },;
						  	{ "C6_PRUNIT", Round(oTFWDetail:GetValue("TFW_VLRTOT"),nDecTFW), Nil },;
						  	{ "C6_VALOR", Round(oTFWDetail:GetValue("TFW_VLRTOT"),nDecTFW), Nil },;
						  	{ "C6_TES", AT930Tes( "TFF", oTFWDetail:GetValue("TFW_CODTFF") ), Nil } } },;
						  	{{"TFW", oTFWDetail:GetValue("TFW_CODTFF")}} } )
						  	
			  	nPosLcPed := ASCAN(aLocPed, {|x| x[1] == oTFWDetail:GetValue("TFW_CODTFL")})
			  	If nPosLcPed > 0
			  		aAdd(aItePed[len(aItePed)][2][len(aItePed[len(aItePed)][2])],{ "C6_CC", aLocPed[nPosLcPed][2], Nil})
			  	EndIf
			  	
			  	If lAbtInss .AND. lDsgCN 
			  		aAdd(aItePed[len(aItePed)][2][len(aItePed[len(aItePed)][2])],{ "C6_ABATINS", oTFWDetail:GetValue("TFW_ABTINS"), Nil})
			  	EndIf
		Else
			
			
			If !lAgrupa .OR. (nAuxAgrp := ASCAN(aItePed[nPosLocal][2],;
			 					{|b| b[2,2] == aLocPed[1][7]})) == 0
				nItePed := Len(aItePed[nPosLocal][2])+1
	
				aAdd( aItePed[nPosLocal][2], { { "C6_ITEM", StrZero( nItePed, TamSx3('C6_ITEM')[1] ), Nil },;
							  	{ "C6_PRODUTO", IIF(lAgrupa, aLocPed[1][7] ,oTFWDetail:GetValue("TFW_PRODUT")), Nil },;
							  	{ "C6_QTDVEN", 1, Nil },;
							  	{ "C6_PRCVEN", Round(oTFWDetail:GetValue("TFW_VLRTOT"),nDecTFW), Nil },;
							  	{ "C6_PRUNIT", Round(oTFWDetail:GetValue("TFW_VLRTOT"),nDecTFW), Nil },;
							  	{ "C6_VALOR",  Round(oTFWDetail:GetValue("TFW_VLRTOT"),nDecTFW), Nil },;
							  	{ "C6_TES", AT930Tes( "TFF", oTFWDetail:GetValue("TFW_CODTFF") ), Nil } } )
				aAdd( aItePed[nPosLocal][3], {"TFW", oTFWDetail:GetValue("TFW_CODTFF")})
				
				nPosLcPed := ASCAN(aLocPed, {|x| x[1] == oTFWDetail:GetValue("TFW_CODTFL")})
			  	If nPosLcPed > 0
			  		aAdd(aItePed[len(aItePed)][2][len(aItePed[len(aItePed)][2])],{ "C6_CC", aLocPed[nPosLcPed][2], Nil})
			  	EndIf
						  	
				If lAbtInss .AND. lDsgCN 
			  		aAdd(aItePed[nPosLocal][2][len(aItePed[nPosLocal][2])],{ "C6_ABATINS", oTFWDetail:GetValue("TFW_ABTINS"), Nil})
			  	EndIf
			
			Else
				aItePed[nPosLocal][2][nAuxAgrp][4][2] += Round(oTFWDetail:GetValue("TFW_VLRTOT"),nDecTFW)
				aItePed[nPosLocal][2][nAuxAgrp][5][2] += Round(oTFWDetail:GetValue("TFW_VLRTOT"),nDecTFW)
				aItePed[nPosLocal][2][nAuxAgrp][6][2] += Round(oTFWDetail:GetValue("TFW_VLRTOT"),nDecTFW)
			EndIf 
		EndIf

	Else

		nPosPlan := aScan( aIteApu, { |x| x[1] == 1 .And. ;
										      x[2] == oTFWDetail:GetValue("TFW_CODTFL") } )

		If cAgrup <> '1'
			nPosCab := aScan( aCabApu, { |x| x[1] == oTFWDetail:GetValue("TFW_CODTFL") } )
		Else
			nPosCab := aScan( aCabApu[1][1], { |x| x[1] == oTFWDetail:GetValue("TFW_CODTFL") } )
		EndIf
		If nPosPlan > 0
			nTotMed := oTFWDetail:GetValue("TFW_VLRMED")
			nTotExt := oTFWDetail:GetValue("TFW_VLREXT")
			cTESExced	:= AT930Tes("TFF",oTFWDetail:GetValue("TFW_CODTFF"),,,.T.)
			

			If cOpcApu == "1"

				aIteApu[nPosPlan][5] += Round(nTotMed + nTotExt,2)
				
				If nPosCab > 0
					If cAgrup <> '1'
						aCabApu[nPosCab][5] += nTotMed + nTotExt
					Else
						aCabApu[1][5] += nTotMed + nTotExt
						aPlan[nPosCab][4] += nTotMed + nTotExt
					EndIf
				EndIf
			Else
			
				// não altera o nTotMed pq ele já estará com o conteúdo certo
				// e o valor de hora extra será cobrado via excedente
				aIteApu[nPosPlan][5] += Round(nTotMed,2)
				
				If nPosCab > 0
					If cAgrup <> '1'
						aCabApu[nPosCab][5] += nTotMed
					Else
						aCabApu[1][5] += nTotMed
						aPlan[nPosCab][4] += nTotMed
					EndIf
				EndIf
				
				//Apuração de Hora-Extra fora do Contrato - Alimenta o Array aItePed2 para geração do Pedido
				If nTotExt > 0
					nVlrHre := Round(oTFWDetail:GetValue("TFW_VLREXT"),nDecTFW)
					nPosLocal := aScan(aItePed2, { |x| x[1] == oTFWDetail:GetValue("TFW_CODTFL") } )
		
					If nPosLocal == 0
						aAdd( aItePed2, { oTFWDetail:GetValue("TFW_CODTFL"),{} , {} })
						nPosLocal := Len(aItePed2)
					EndIf
					
					If lAgrupa
						cCodProd := aLocPed2[1][7]
					Else
						cCodProd := oTFWDetail:GetValue("TFW_PRODUT")
					EndIf
					If !lAgrupa .OR. (nAuxAgrp := ASCAN(aItePed2[nPosLocal][2],;
					 					{|b| b[2,1] == "C6_PRODUTO" .AND.  b[2,2] == cCodProd })) == 0
					 					
						nItePed := Len(aItePed2[nPosLocal][2])+1
						
						aItAux := {}
						aAdd( aItAux, { "C6_ITEM", StrZero( nItePed, TamSx3('C6_ITEM')[1] ), Nil })
						aAdd( aItAux,{ "C6_PRODUTO", cCodProd, Nil })
						aAdd( aItAux,{ "C6_QTDVEN", 1, Nil })
						aAdd( aItAux,{ "C6_PRCVEN", nVlrHre, Nil })
						aAdd( aItAux,{ "C6_PRUNIT", nVlrHre, Nil })
						aAdd( aItAux,{ "C6_VALOR",  nVlrHre, Nil })
						aAdd( aItAux,{ "C6_TES", cTESExced , Nil })
						aAdd( aItAux,{ "C6_CC", aLocPed2[nPosLocal][2], Nil} )
						If lAbtInss .AND. lDsgCN 
					  		aAdd( aItAux, { "C6_ABATINS", oTFWDetail:GetValue("TFW_ABTINS"), Nil})
					  	EndIf
					  	
						aAdd( aItePed2[nPosLocal][2],  aClone(aItAux)   )
						
						aAdd( aItePed2[nPosLocal][3], {"TFW", oTFWDetail:GetValue("TFW_CODTFF")})
						
					Else
						aItePed2[nPosLocal][2][nAuxAgrp][4][2] += nVlrHre
						aItePed2[nPosLocal][2][nAuxAgrp][5][2] += nVlrHre
						aItePed2[nPosLocal][2][nAuxAgrp][6][2] += nVlrHre
					EndIf 
				EndIf

			EndIf

		EndIf

	EndIf

Next nI

// ----- MEDIÇAO MATERIAL DE IMPLANTACAO
//Totalizando itens do Material de Implantaçao
For nI := 1 To oTFXDetail:Length()

	oTFXDetail:GoLine(nI)

	If lMedExt .OR. cOpcApu == "2"
		If lItemTCV .AND. oTFXDetail:GetValue("TFX_VLRMED") > 0
			If (nPosLocTCV := aScan(aIteTCV, { |x| x[1] ==  oTFXDetail:GetValue("TFX_CODTFL") } )) > 0
				AADD(aIteTCV[nPosLocTCV][2], {"TFG", oTFXDetail:GetValue("TFX_CODTFG"), oTFXDetail:GetValue("TFX_PRODUT")})
			Else
				AADD(aIteTCV, { oTFXDetail:GetValue("TFX_CODTFL") ,{{"TFG", oTFXDetail:GetValue("TFX_CODTFG"), oTFXDetail:GetValue("TFX_PRODUT")}}})
			EndIf
		EndIf
	EndIf

	If lMedExt

		nPosLocal := aScan(aItePed, { |x| x[1] == oTFXDetail:GetValue("TFX_CODTFL") } )

		If nPosLocal == 0

			aAdd( aItePed, { oTFXDetail:GetValue("TFX_CODTFL"),;
						 { { { "C6_ITEM", StrZero( 1, TamSx3('C6_ITEM')[1] ), Nil },;
						  	{ "C6_PRODUTO", IIF(lAgrupa, aLocPed[1][8], oTFXDetail:GetValue("TFX_PRODUT")), Nil },;
						  	{ "C6_QTDVEN", 1, Nil },;
						  	{ "C6_PRCVEN", Round(oTFXDetail:GetValue("TFX_VLRMED"),nDecTFX), Nil },;
						  	{ "C6_PRUNIT", Round(oTFXDetail:GetValue("TFX_VLRMED"),nDecTFX), Nil },;
						  	{ "C6_VALOR", Round(oTFXDetail:GetValue("TFX_VLRMED"),nDecTFX), Nil },;
						  	{ "C6_TES", AT930Tes( "TFG", oTFXDetail:GetValue("TFX_CODTFF"), oTFXDetail:GetValue("TFX_CODTFL"), oTFXDetail:GetValue("TFX_CODTFG") ), Nil } } },;
						  	{{"TFX", oTFXDetail:GetValue("TFX_CODTFG")}}  } )

				nPosLcPed := ASCAN(aLocPed, {|x| x[1] == oTFXDetail:GetValue("TFX_CODTFL")})
			  	If nPosLcPed > 0
			  		aAdd(aItePed[len(aItePed)][2][len(aItePed[len(aItePed)][2])],{ "C6_CC", aLocPed[nPosLcPed][2], Nil})
			  	EndIf

		Else
			If !lAgrupa .OR. (nAuxAgrp := ASCAN(aItePed[nPosLocal][2],;
			 					{|b| b[2,2] == aLocPed[1][8]})) == 0
				nItePed := Len(aItePed[nPosLocal][2])+1
	
				aAdd( aItePed[nPosLocal][2], { { "C6_ITEM", StrZero( nItePed, TamSx3('C6_ITEM')[1] ), Nil },;
							  	{ "C6_PRODUTO",  IIF(lAgrupa, aLocPed[1][8], oTFXDetail:GetValue("TFX_PRODUT")), Nil },;
							  	{ "C6_QTDVEN", 1, Nil },;
							  	{ "C6_PRCVEN", Round(oTFXDetail:GetValue("TFX_VLRMED"),nDecTFX), Nil },;
							  	{ "C6_PRUNIT", Round(oTFXDetail:GetValue("TFX_VLRMED"),nDecTFX), Nil },;
							  	{ "C6_VALOR",  Round(oTFXDetail:GetValue("TFX_VLRMED"),nDecTFX), Nil },;
							  	{ "C6_TES", AT930Tes( "TFG", oTFXDetail:GetValue("TFX_CODTFF"), oTFXDetail:GetValue("TFX_CODTFL"), oTFXDetail:GetValue("TFX_CODTFG") ), Nil } } )
							  	
				aAdd( aItePed[nPosLocal][3], {"TFX", oTFXDetail:GetValue("TFX_CODTFG")})
				
				nPosLcPed := ASCAN(aLocPed, {|x| x[1] == oTFXDetail:GetValue("TFX_CODTFL")})
			  	If nPosLcPed > 0
			  		aAdd(aItePed[len(aItePed)][2][len(aItePed[len(aItePed)][2])],{ "C6_CC", aLocPed[nPosLcPed][2], Nil})
			  	EndIf
			Else
				aItePed[nPosLocal][2][nAuxAgrp][4][2] += Round(oTFXDetail:GetValue("TFX_VLRMED"),nDecTFX)
				aItePed[nPosLocal][2][nAuxAgrp][5][2] += Round(oTFXDetail:GetValue("TFX_VLRMED"),nDecTFX)
				aItePed[nPosLocal][2][nAuxAgrp][6][2] += Round(oTFXDetail:GetValue("TFX_VLRMED"),nDecTFX)
			EndIf

		EndIf

	Else

		nPosPlan := aScan( aIteApu, { |x| x[1] == 2 .And. ;
										      x[2] == oTFXDetail:GetValue("TFX_CODTFL") } )
		If cAgrup <> '1'
			nPosCab := aScan( aCabApu, { |x| x[1] == oTFXDetail:GetValue("TFX_CODTFL") } )
		Else
			nPosCab := aScan( aCabApu[1,1], { |x| x[1] == oTFXDetail:GetValue("TFX_CODTFL") } )
		EndIf
		If nPosPlan > 0
			nTotMed := oTFXDetail:GetValue("TFX_VLRMED")
			aIteApu[nPosPlan][5] += Round(nTotMed,2)

			If nPosCab > 0
				If cAgrup <> '1'
					aCabApu[nPosCab][5] += nTotMed
				Else
					aCabApu[1][5] += nTotMed
					aPlan[nPosCab][4] += nTotMed
				EndIf
			EndIf

		EndIf

	EndIf

Next nI

// ----- MEDIÇAO MATERIAL DE CONSUMO
//Totalizando itens do Material de Consumo
For nI := 1 To oTFYDetail:Length()

	oTFYDetail:GoLine(nI)

	If lMedExt .OR. cOpcApu == "2"
		If lItemTCV .AND. oTFYDetail:GetValue("TFY_VLRMED") > 0
			If (nPosLocTCV := aScan(aIteTCV, { |x| x[1] == oTFYDetail:GetValue("TFY_CODTFL") } )) > 0
				AADD(aIteTCV[nPosLocTCV][2], {"TFH", oTFYDetail:GetValue("TFY_CODTFH"), oTFYDetail:GetValue("TFY_PRODUT")})
			Else
				AADD(aIteTCV, {oTFYDetail:GetValue("TFY_CODTFL") ,{{"TFH", oTFYDetail:GetValue("TFY_CODTFH"), oTFYDetail:GetValue("TFY_PRODUT")}}})
			EndIf
		EndIf
	EndIf

	If lMedExt

		nPosLocal := aScan(aItePed, { |x| x[1] == oTFYDetail:GetValue("TFY_CODTFL") } )

		If nPosLocal == 0

			aAdd( aItePed, { oTFYDetail:GetValue("TFY_CODTFL"),;
						 { { { "C6_ITEM", StrZero( 1, TamSx3('C6_ITEM')[1] ), Nil },;
						  	{ "C6_PRODUTO", IIF(lAgrupa,aLocPed[1][9],oTFYDetail:GetValue("TFY_PRODUT")), Nil },;
						  	{ "C6_QTDVEN", 1, Nil },;
						  	{ "C6_PRCVEN", Round(oTFYDetail:GetValue("TFY_VLRMED"),nDecTFY), Nil },;
						  	{ "C6_PRUNIT", Round(oTFYDetail:GetValue("TFY_VLRMED"),nDecTFY), Nil },;
						  	{ "C6_VALOR", Round(oTFYDetail:GetValue("TFY_VLRMED"),nDecTFY), Nil },;
						  	{ "C6_TES", AT930Tes( "TFH", oTFYDetail:GetValue("TFY_CODTFF"), oTFYDetail:GetValue("TFY_CODTFL"), oTFYDetail:GetValue("TFY_CODTFH") ), Nil } } },;
						  	{{"TFY", oTFYDetail:GetValue("TFY_CODTFH")}}  } )
			nPosLcPed := ASCAN(aLocPed, {|x| x[1] == oTFYDetail:GetValue("TFY_CODTFL")})
		  	If nPosLcPed > 0
		  		aAdd(aItePed[len(aItePed)][2][len(aItePed[len(aItePed)][2])],{ "C6_CC", aLocPed[nPosLcPed][2], Nil})
		  	EndIf
		Else
			If !lAgrupa .OR. (nAuxAgrp := ASCAN(aItePed[nPosLocal][2],;
			 					{|b| b[2,2] == aLocPed[1][9]})) == 0
				nItePed := Len(aItePed[nPosLocal][2])+1
	
				aAdd( aItePed[nPosLocal][2], { { "C6_ITEM", StrZero( nItePed, TamSx3('C6_ITEM')[1] ), Nil },;
							  	{ "C6_PRODUTO", IIF(lAgrupa,aLocPed[1][9],oTFYDetail:GetValue("TFY_PRODUT")), Nil },;
							  	{ "C6_QTDVEN", 1, Nil },;
							  	{ "C6_PRCVEN", Round(oTFYDetail:GetValue("TFY_VLRMED"),nDecTFY), Nil },;
							  	{ "C6_PRUNIT", Round(oTFYDetail:GetValue("TFY_VLRMED"),nDecTFY), Nil },;
							  	{ "C6_VALOR",  Round(oTFYDetail:GetValue("TFY_VLRMED"),nDecTFY), Nil },;
							  	{ "C6_TES", AT930Tes( "TFH", oTFYDetail:GetValue("TFY_CODTFF"), oTFYDetail:GetValue("TFY_CODTFL"), oTFYDetail:GetValue("TFY_CODTFH") ), Nil } } )
							  	
				aAdd( aItePed[nPosLocal][3], {"TFY", oTFYDetail:GetValue("TFY_CODTFH")})
				nPosLcPed := ASCAN(aLocPed, {|x| x[1] == oTFYDetail:GetValue("TFY_CODTFL")})
			  	If nPosLcPed > 0
			  		aAdd(aItePed[len(aItePed)][2][len(aItePed[len(aItePed)][2])],{ "C6_CC", aLocPed[nPosLcPed][2], Nil})
			  	EndIf
			Else
				aItePed[nPosLocal][2][nAuxAgrp][4][2] += Round(oTFYDetail:GetValue("TFY_VLRMED"),nDecTFY)
				aItePed[nPosLocal][2][nAuxAgrp][5][2] += Round(oTFYDetail:GetValue("TFY_VLRMED"),nDecTFY)
				aItePed[nPosLocal][2][nAuxAgrp][6][2] += Round(oTFYDetail:GetValue("TFY_VLRMED"),nDecTFY)
			EndIf

		EndIf

	Else

		nPosPlan := aScan( aIteApu, { |x| x[1] == 3 .And. ;
										      x[2] == oTFYDetail:GetValue("TFY_CODTFL") } )
		
		If cAgrup <> '1'
			nPosCab := aScan( aCabApu, { |x| x[1] == oTFYDetail:GetValue("TFY_CODTFL") } )
		Else
			nPosCab := aScan( aCabApu[1,1], { |x| x[1] == oTFYDetail:GetValue("TFY_CODTFL") } )
		EndIf
		If nPosPlan > 0
			nTotMed := oTFYDetail:GetValue("TFY_VLRMED")
			aIteApu[nPosPlan][5] += Round(nTotMed,2)

			If nPosCab > 0
				If cAgrup <> '1'
					aCabApu[nPosCab][5] += nTotMed
				Else
					aCabApu[1][5] += nTotMed
					aPlan[nPosCab][4] += nTotMed
				EndIf
			EndIf
		EndIf

	EndIf

Next nI

// ----- MEDIÇAO LOCACAO DE EQUIPAMENTO
//Totalizando itens de Locacao de Equipamento
For nI := 1 To oModel:GetModel("TFLDETAIL"):Length()

	oModel:GetModel("TFLDETAIL"):GoLine(nI)

	nPosPlan := aScan( aIteApu, { |x| x[1] == 4 .And. ;
									      x[2] == oModel:GetModel("TFLDETAIL"):GetValue("TFL_CODIGO") } )

	
	If cAgrup <> '1'
		nPosCab := aScan( aCabApu, { |x| x[1] == oModel:GetModel("TFLDETAIL"):GetValue("TFL_CODIGO") } )
	Else
		nPosCab := aScan( aCabApu[1,1], { |x| x[1] == oModel:GetModel("TFLDETAIL"):GetValue("TFL_CODIGO") } )
	EndIf

	If nPosPlan > 0
		nTotMed := oModel:GetModel("TFLDETAIL"):GetValue("TFL_VALTOT")
		aIteApu[nPosPlan][5] += Round(nTotMed,2)

		If nPosCab > 0
			If cAgrup <> '1'
				aCabApu[nPosCab][5] += nTotMed
			Else
				aCabApu[1][5] += nTotMed
				aPlan[nPosCab][4] += nTotMed
			EndIf
		EndIf
	EndIf

Next nI

If isInCallStack("At930ApuAg")
	nTotMed := 0
EndIf
// ----- VALOR MEDIÇÃO POR PLANILHA
// Adiciona o valor do imposto ao total
If lOrcPrc .And. lSomaImp
	For nI := 1 To oModel:GetModel("TWBDETAIL"):Length()

		oModel:GetModel("TWBDETAIL"):GoLine(nI)

		If cAgrup <> '1'
			nPosCab := aScan( aCabApu, { |x| x[1] == oModel:GetModel("TWBDETAIL"):GetValue("TWB_CODTFL") } )
		Else
			nPosCab := aScan( aCabApu[1,1], { |x| x[1] == oModel:GetModel("TWBDETAIL"):GetValue("TWB_CODTFL") } )
		EndIf
		nPosPlan := aScan( aIteApu, { |x| x[1] == 1 .And. ;
									      x[2] == oModel:GetModel("TWBDETAIL"):GetValue("TWB_CODTFL") } )

		If nPosCab > 0 .And. nPosPlan > 0
			If cAgrup <> '1'
				aCabApu[nPosCab][5]  += Round(oModel:GetModel("TWBDETAIL"):GetValue("TWB_IMPMED"),2)
			Else
				aCabApu[1][5]  += Round(oModel:GetModel("TWBDETAIL"):GetValue("TWB_IMPMED"),2)
				aPlan[nPosCab][4] += nTotMed
			EndIf
		 	aIteApu[nPosPlan][5] += Round(oModel:GetModel("TWBDETAIL"):GetValue("TWB_IMPMED"),2)
		EndIf
	Next nI
EndIf

If lMedExt .OR. Len(aItePed2) > 0

	//Clona o conteúdo para o LocPed e aItePed que referem-se ao Valor de Hora-Extra Apurada fora do Contrato na Apuração Normal (não medição externa)
	If !lMedExt .AND. Len(aItePed2) > 0
		aLocPed := aClone(aLocPed2)
		aItePed := aClone(aItePed2)
	EndIf

	// GERACAO DO PEDIDO PARA A MEDICAO FORA DO CONTRATO
	For nI:=1 To Len(aLocPed)
		nPosLocal := aScan( aItePed, { |x| x[1] == aLocPed[nI][1] } )

		aPedCabec := {}
		aPedItens := {}
		xAuxPed   := {}
		aRateio   := {}
		aPVS := {}
		
		If lGsISS .AND. !lOrcPrc .AND. nPosLocal > 0
			For nX := 1 to LEN(aItePed[nPosLocal][3])
				aArea := GetArea()
				cAliasISS := GetNextAlias()
				If aItePed[nPosLocal][3][nX][1] $ "TFX|TFY"
					cSQL := " SELECT TFF.TFF_PRODUT "
					cSQL += " FROM " + RetSqlName( "TFF" ) + " TFF "
					cSQL += " INNER JOIN "
					If aItePed[nPosLocal][3][nX][1] == "TFX"
						cSQL += RetSqlName( "TFG" ) + " TFG "
						cSQL += " ON TFG.TFG_FILIAL = '" + xFilial("TFG") + "' "
						cSQL += " AND TFG.D_E_L_E_T_ = ' ' "
						cSQL += " AND TFG.TFG_CODPAI = TFF.TFF_COD "
						cSQL += " AND TFG.TFG_COD = '" + aItePed[nPosLocal][3][nX][2] + "' "
					Else
						cSQL += RetSqlName( "TFH" ) + " TFH "
						cSQL += " ON TFH.TFH_FILIAL = '" + xFilial("TFH") + "' "
						cSQL += " AND TFH.D_E_L_E_T_ = ' ' "
						cSQL += " AND TFH.TFH_CODPAI = TFF.TFF_COD "
						cSQL += " AND TFH.TFH_COD = '" + aItePed[nPosLocal][3][nX][2] + "' "
					EndIf
					cSQL += " WHERE TFF.D_E_L_E_T_ = ' ' AND TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
				Else
					cSQL := " SELECT TFF.TFF_PRODUT "
					cSQL += " FROM " + RetSqlName( "TFF" ) + " TFF "
					cSQL += " WHERE TFF.D_E_L_E_T_ = ' ' AND TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
					cSQL += " AND TFF.TFF_COD = '" + aItePed[nPosLocal][3][nX][2] + "' "
				EndIf
				cSQL := ChangeQuery(cSQL)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasISS, .F., .T.)
				cProdTFF := (cAliasISS)->(TFF_PRODUT)
				cCodIss := TECBGetISS(cProdTFF)
				(cAliasISS)->(DbCloseArea())
				RestArea(aArea)
				
				If EMPTY(cCodIss)
					cCodIss := REPLICATE("Z",TamSx3("B1_CODISS")[1])
				EndIf
				
				If EMPTY(aPVS) .OR. (nAuxPvs := ASCAN(aPVS, {|q| q[1] == cCodIss})) == 0
					AADD(aPVS, {cCodIss, {}})
					nAuxPvs := LEN(aPVs)
				EndIf
				
				If EMPTY(aPVs[nAuxPvs][2]) .OR. (nAuxIts := ASCAN(aPVs[nAuxPvs][2], {|a| a[2][2] == cProdTFF})) == 0
					AADD(aPVs[nAuxPvs][2], aItePed[nPosLocal][2][nX])
					aPVs[nAuxPvs][2][LEN(aPVs[nAuxPvs][2])][2][2] := cProdTFF
				Else
				
					aPVs[nAuxPvs][2][nAuxIts][4][2] += aItePed[nPosLocal][2][nX][4][2]
					aPVs[nAuxPvs][2][nAuxIts][5][2] += aItePed[nPosLocal][2][nX][5][2]
					aPVs[nAuxPvs][2][nAuxIts][6][2] += aItePed[nPosLocal][2][nX][6][2]
					If aItePed[nPosLocal][3][nX][1] == "TFW" .AND. lAbtInss
						aPVs[nAuxPvs][2][nAuxIts][9][2] += aItePed[nPosLocal][2][nX][9][2]
					EndIf
				EndIf
			Next nX
			
			For nX := 1 To LEN(aPVs)
				cAuxItemPV := REPLICATE("0",TAMSX3("C6_ITEM")[1])
				aPedItens := {}
				aPedCabec := {}
				For nY := 1 To LEN(aPvs[nX][2])
					If aPvs[nX][2][nY][6][2] > 0
						cAuxItemPV := Soma1(cAuxItemPV)
						aPvs[nX][2][nY][1][2] := cAuxItemPV 
						AADD(aPedItens, aPvs[nX][2][nY])
					EndIf
				Next nY
				
				If Len(aPedItens) > 0
					aAdd( aPedCabec, { 'C5_TIPO'   , 'N', Nil } )
					aAdd( aPedCabec, { 'C5_CLIENTE', aLocPed[nI][3], Nil } )
					aAdd( aPedCabec, { 'C5_LOJACLI', aLocPed[nI][4], Nil } )
					aAdd( aPedCabec, { 'C5_CONDPAG', aLocPed[nI][5], Nil } )
					
					If !Empty(aLocPed[nI][6])
						cTipoFrete := Iif(aLocPed[nI][6]=="1","C","F")
						aAdd( aPedCabec, { 'C5_TPFRETE', cTipoFrete, Nil } )
					Endif

					aComplSC5 := GetComplSc5(Posicione("TFL",1,xFilial("TFL")+aLocPed[nI][1],"TFL_LOCAL"))

					For nComp := 1 To Len(aComplSC5)
						aAdd( aPedCabec, { aComplSC5[nComp][1], aComplSC5[nComp][2], Nil } )
					Next nComp

					If lAT930PVE
						aRetPe := ExecBlock("AT930PVE",.F.,.F., {aPedCabec, aPedItens} )
						aPedCabec := aRetPe[1]
						aPedItens := aRetPe[2]
					EndIf

					lMsErroAuto := .F.
					MsExecAuto( { |w,x,y,z| MATA410( w, x, y, Nil, Nil, Nil, Nil, z ) }, aPedCabec, aPedItens, 3, {}/*aRateio*/ )
				Else
					lRet := .F.
				EndIf
				
				If lMsErroAuto
					lRet := .F.
					xAuxPed := GetAutoGrLog()
					MostraErro()
				ElseIf lRet
					If lItemTCV
						If (nPosLocTCV := aScan( aIteTCV, { |x| x[1] == aLocPed[nI][1] } )) > 0
							For nY := 1 To Len(aIteTCV[nPosLocTCV][2])
								If !Empty(oModel:GetModel("TCVDETAIL"):GetValue("TCV_NUMAPU")) .OR. !oModel:GetModel("TCVDETAIL"):IsEmpty()
									nLinha := oModel:GetModel("TCVDETAIL"):AddLine()
								EndIf
								oModel:GetModel("TCVDETAIL"):GoLine(nLinha)
								oModel:GetModel("TCVDETAIL"):SetValue("TCV_FILIAL", xFilial("TCV") )
								oModel:GetModel("TCVDETAIL"):SetValue("TCV_NUMAPU" , oTFVMaster:GetValue("TFV_CODIGO") )
								oModel:GetModel("TCVDETAIL"):SetValue("TCV_NUMPED" , SC5->C5_NUM )
								oModel:GetModel("TCVDETAIL"):SetValue("TCV_ALIAS" , aIteTCV[nPosLocTCV][2][nY][1] )
								oModel:GetModel("TCVDETAIL"):SetValue("TCV_CODITE" , aIteTCV[nPosLocTCV][2][nY][2] )
								oModel:GetModel("TCVDETAIL"):SetValue("TCV_PRODPV" , SC6->C6_PRODUTO )
								oModel:GetModel("TCVDETAIL"):SetValue("TCV_ITEMPV" , SC6->C6_ITEM )
							Next nY
						EndIf
					Else
						If !Empty(oModel:GetModel("TCVDETAIL"):GetValue("TCV_NUMAPU"))
							oModel:GetModel("TCVDETAIL"):AddLine()
						EndIf
		
						oModel:GetModel("TCVDETAIL"):SetValue("TCV_FILIAL", xFilial("TCV") )
						oModel:GetModel("TCVDETAIL"):SetValue("TCV_NUMAPU" , oTFVMaster:GetValue("TFV_CODIGO") )
						oModel:GetModel("TCVDETAIL"):SetValue("TCV_NUMPED" , SC5->C5_NUM )
					EndIf
				EndIf					
			Next nX
		Else
			If nPosLocal > 0
	
				For nX:=1 To Len(aItePed[nPosLocal][2])
					nAuxVl := aScan(AiTePed[nPosLocal][2][nX],{|x| x[1] == "C6_VALOR" })
					If nAuxVl > 0 .AND. ValType(aItePed[nPosLocal][2][nX][nAuxVl][2])=="N" .AND. aItePed[nPosLocal][2][nX][nAuxVl][2] > 0
						aAdd( xAuxPed, {} )
						For nY:=1 To Len(aItePed[nPosLocal][2][nX])
							aAdd( xAuxPed[Len(xAuxPed)], aItePed[nPosLocal][2][nX][nY] )
						Next nY
					EndIf
				Next nX
	
				aPedItens := aClone( xAuxPed )
	
			EndIf
	
			If Len(aPedItens) > 0
	
				aAdd( aPedCabec, { 'C5_TIPO'   , 'N', Nil } )
				aAdd( aPedCabec, { 'C5_CLIENTE', aLocPed[nI][3], Nil } )
				aAdd( aPedCabec, { 'C5_LOJACLI', aLocPed[nI][4], Nil } )
				aAdd( aPedCabec, { 'C5_CONDPAG', aLocPed[nI][5], Nil } )
	
				If !Empty(aLocPed[nI][6])
					cTipoFrete := Iif(aLocPed[nI][6]=="1","C","F")
					aAdd( aPedCabec, { 'C5_TPFRETE', cTipoFrete, Nil } )
				Endif

				aComplSC5 := GetComplSc5(Posicione("TFL",1,xFilial("TFL")+aLocPed[nI][1],"TFL_LOCAL"))

				For nComp := 1 To Len(aComplSC5)
					aAdd( aPedCabec, { aComplSC5[nComp][1], aComplSC5[nComp][2], Nil } )
				Next nComp

				aAdd( aRateio, { "01", { { { "AGG_ITEM"  , "01", Nil },;
											 { "AGG_PERC"  , 100, Nil },;
											 { "AGG_CC"    , aLocPed[nI][2], Nil },;
											 { "AGG_CONTA" , "", Nil },;
											 { "AGG_ITEMCT", "", Nil },;
											 { "AGG_CLVL"  , "", Nil } } } } )
				If lAT930PVE
					aRetPe := ExecBlock("AT930PVE",.F.,.F., {aPedCabec, aPedItens} )
					aPedCabec := aRetPe[1]
					aPedItens := aRetPe[2]
				EndIf

				lMsErroAuto := .F.
				MsExecAuto( { |w,x,y,z| MATA410( w, x, y, Nil, Nil, Nil, Nil, z ) }, aPedCabec, aPedItens, 3, {}/*aRateio*/ )
	
				If lMsErroAuto
					lRet := .F.
					xAuxPed := GetAutoGrLog()
					MostraErro()
				Else
					lRet := .T.

					If lItemTCV
						dbSelectArea( 'SC6' )
						SC6->( dbSetOrder( 2 ) )
						If (nPosLocTCV := aScan( aIteTCV, { |x| x[1] == aLocPed[nI][1] } )) > 0
							For nX := 1 To Len(aIteTCV[nPosLocTCV][2])
								If !Empty(oModel:GetModel("TCVDETAIL"):GetValue("TCV_NUMAPU")) .OR. !oModel:GetModel("TCVDETAIL"):IsEmpty()
									nLinha := oModel:GetModel("TCVDETAIL"):AddLine()
								EndIf
								oModel:GetModel("TCVDETAIL"):GoLine(nLinha)
								oModel:GetModel("TCVDETAIL"):SetValue("TCV_FILIAL", xFilial("TCV") )
								oModel:GetModel("TCVDETAIL"):SetValue("TCV_NUMAPU" , oTFVMaster:GetValue("TFV_CODIGO") )
								oModel:GetModel("TCVDETAIL"):SetValue("TCV_NUMPED" , SC5->C5_NUM )
								oModel:GetModel("TCVDETAIL"):SetValue("TCV_ALIAS" , aIteTCV[nPosLocTCV][2][nX][1] )
								oModel:GetModel("TCVDETAIL"):SetValue("TCV_CODITE" , aIteTCV[nPosLocTCV][2][nX][2] )
								If SC6->(MSSeek(xFilial("SC6")+aIteTCV[nPosLocTCV][2][nX][3]+SC5->C5_NUM))
									oModel:GetModel("TCVDETAIL"):SetValue("TCV_PRODPV" , SC6->C6_PRODUTO )
									oModel:GetModel("TCVDETAIL"):SetValue("TCV_ITEMPV" , SC6->C6_ITEM )
								EndIf
							Next nX
						EndIf
					Else
						If !Empty(oModel:GetModel("TCVDETAIL"):GetValue("TCV_NUMAPU"))
							oModel:GetModel("TCVDETAIL"):AddLine()
						EndIf
		
						oModel:GetModel("TCVDETAIL"):SetValue("TCV_FILIAL", xFilial("TCV") )
						oModel:GetModel("TCVDETAIL"):SetValue("TCV_NUMAPU" , oTFVMaster:GetValue("TFV_CODIGO") )
						oModel:GetModel("TCVDETAIL"):SetValue("TCV_NUMPED" , SC5->C5_NUM )
					EndIf
				EndIf
			EndIf
		EndIf
	Next nI

EndIf
If !lMedExt .AND. lRet
	// Quando faturamento antecipado não deixa executar a medição no contrato
	If !lFatAntecip
		// REALIZACAO DA MEDICAO NO GCT, ATRAVES DOS DADOS COLETADOS E TOTALIZADOS
		nPosIAP := 0
		aMedGCT := {}
		cNumMed := ""

		For nI:=1 To Len(aCabApu)

			aCloneCab := ACLONE(aCabApu[nI])
			aItnsRef := {}

			lRet := .T.

			If aCabApu[nI][5] > 0

				// Cria matriz para atualizar os itens dos grids com numero e item da medição
				cNumMed := CriaVar("CND_NUMMED")
				If lAbtInss .AND. lDsgcn
					aAdd(aNumMed, cNumMed)
				EndIf
				If cAgrup == '1'
					For nZ := 1 To Len(aCabApu[1][1])
						aAdd( aMedGCT, { aCabApu[1][1][nZ][1], cNumMed, "", "", "", "" } )
					Next nX
				Else
					aAdd( aMedGCT, { aCabApu[nI][1], cNumMed, "", "", "", "" } )
				EndIf
				CN121ClrAc()
				aCabe	:=	{}
				aItem	:=	{}

				// Cabecalho para envio da medição para o GCT
				aAdd( aCabe, { "CND_FILIAL", xFilial("CND"), NIL } )
				aAdd( aCabe, { "CND_CONTRA", aCabApu[nI][2], NIL } )
				aAdd( aCabe, { "CND_REVISA", aCabApu[nI][3], NIL } )
				aAdd( aCabe, { "CND_NUMERO", aCabApu[nI][4], NIL } )
				aAdd( aCabe, { "CND_COMPET", Space(TamSX3('CND_COMPET')[1]), NIL } )
				aAdd( aCabe, { "CND_PARCEL", Space(TamSX3('CND_PARCEL')[1]), NIL } )
				aAdd( aCabe, { "CND_NUMMED", cNumMed, NIL } )
				aAdd( aCabe, { "CND_VLTOT", aCabApu[nI][5], NIL } )

				//-- Recupera o total de descontos da planilha
				nVlrDesc := AT930TotDe(oModel,aCabApu[nI][4])

				//-- Recupera os descontos em array.
				aDescs := A930Desc(oModel,aCabApu[nI][4])
				//-- Recupera multas e bonificações em array e seu valores nos paramentros de referencia.
				aMultas := A930Multas(oModel,aCabApu[nI][4],@nVlrMulta,@nVlrBoni)

				aAdd( aCabe, { "CND_DESCME", nVlrDesc, NIL } )
				aAdd( aCabe, { "CND_RCCOMP", Space(3), NIL } )

				If ExistBlock("At930Cab") .AND. FindFunction("At930AGMdl")
					aCabe := ExecBlock("At930Cab",.F.,.F., {aCabe, At930AGMdl()} )
				EndIf

				// Itens apurados para o RH
				If !lDsgCN
					If cAgrup <> '1'
						nPosIAP := aScan( aIteApu, { |x| x[1] == 1 .And. x[2] == aCabApu[nI][1] } )
						If nPosIAP > 0
							aAdd( aItem, {} )
							aAdd( aItem[Len(aItem)], { "CNE_ITEM"  , aIteApu[nPosIAP][4], NIL } )
							aAdd( aItem[Len(aItem)], { "CNE_VLTOT", aIteApu[nPosIAP][5], NIL } )
							aMedGCT[Len(aMedGCT)][3] := aIteApu[nPosIAP][4] // Item da Medição
							aAdd( aItem[Len(aItem)], { "PLAN"  , aCabApu[nI][4], NIL } )
						EndIf
					Else
						For nZ := 1 To Len(aCabApu[1,1])
							nPosIAP := aScan( aIteApu, { |x| x[1] == 1 .And. x[2] == aCabApu[1][1][nZ][1] } )//lContinu := (nPosPlan := ASCAN(aCabApu[1,1], { |x| x[1] == oTFWDetail:GetValue('TFW_PLAN') }) )> 0//oTFWDetail:GetValue('TFW_PLAN') ==  aCabApu[1,1,nZ,2]
							If nPosIAP > 0
								aAdd( aItem, {} )
								aAdd( aItem[Len(aItem)], { "CNE_ITEM"  , aIteApu[nPosIAP][4], NIL } )
								aAdd( aItem[Len(aItem)], { "CNE_VLTOT", aIteApu[nPosIAP][5], NIL } )
								aMedGCT[Len(aMedGCT)][3] := aIteApu[nPosIAP][4] // Item da Medição
								aAdd( aItem[Len(aItem)], { "PLAN"  , aCabApu[nI][1][nZ][2], NIL } )
							EndIf
						NExt nZ
					EndIf
				Else
					For nZ := 1 To oTFWDetail:Length()
						oTFWDetail:GoLine(nZ)
						If cAgrup <> '1'
							lContinu := oTFWDetail:GetValue('TFW_PLAN') ==  aCabApu[nI][4]
						Else
							lContinu := (nPosPlan := ASCAN(aCabApu[1,1], { |x| x[2] == oTFWDetail:GetValue('TFW_PLAN') }) )> 0//oTFWDetail:GetValue('TFW_PLAN') ==  aCabApu[1,1,nZ,2]
						EndIf
						If lContinu //.And. oTFWDetail:GetValue('TFW_VLRMED') > 0
							cItem := Posicione("TFF",1,xFilial("TFF")+oTFWDetail:GetValue("TFW_CODTFF"),"TFF_ITCNB")
							aAdd( aItem, {} )
							aAdd( aItem[Len(aItem)], { "CNE_ITEM"  , cItem, NIL } )
							aAdd( aItem[Len(aItem)], { "CNE_VLTOT", oTFWDetail:GetValue('TFW_VLRMED')+ IIF(cOpcApu <> "2",oTFWDetail:GetValue('TFW_VLREXT') , 0), NIL } )
							If lAbtInss .AND. lDsgCN
								aAdd( aItem[len(aItem)], { "CNE_ABTINS", oTFWDetail:GetValue('TFW_ABTINS'), NIL } )
							EndIf
							Aadd( aItnsRef,{cItem,'Recursos Humanos'})
							If cAgrup == '1'
								aAdd( aItem[Len(aItem)], { "PLAN"  , aCabApu[1,1,nPosPlan,2], NIL } )
							Else
								aAdd( aItem[Len(aItem)], { "PLAN"  , aCabApu[nI][4], NIL } )
							EndIf

							oTFWDetail:SetValue('TFW_NUMMED',cNumMed)
							oTFWDetail:SetValue('TFW_ITMED',cItem)
						EndIf
					Next nZ
				EndIf

				// Itens apurados para os materiais de implantação
				If !lDsgCN
					If cAgrup <> '1'
						nPosIAP := aScan( aIteApu, { |x| x[1] == 2 .And. x[2] == aCabApu[nI][1] } )
						If nPosIAP > 0
							// verifica se o item da planilha já foi adicionado a medição e caso já tenha, só soma o valor
							If ( nPosItItens := aScan( aItem, {|x| x[1][2] == aIteApu[nPosIAP][4] } ) ) > 0
								aItem[nPosItItens][2][2] += aIteApu[nPosIAP][5]
							Else
								aAdd( aItem, {} )
								aAdd( aItem[Len(aItem)], { "CNE_ITEM"  , aIteApu[nPosIAP][4], NIL } )
								aAdd( aItem[Len(aItem)], { "CNE_VLTOT", aIteApu[nPosIAP][5], NIL } )
								aAdd( aItem[Len(aItem)], { "PLAN"  , aCabApu[nI][4], NIL } )
							EndIf
							aMedGCT[Len(aMedGCT)][4] := aIteApu[nPosIAP][4] // Item da Medição
						EndIf
					Else
						For nZ := 1 To Len(aCabApu[1][1])
							nPosIAP := aScan( aIteApu, { |x| x[1] == 2 .And. x[2] == aCabApu[1][1][nZ][1] } )
							If nPosIAP > 0
								// verifica se o item da planilha já foi adicionado a medição e caso já tenha, só soma o valor
								If ( nPosItItens := aScan( aItem, {|x| x[1][2] == aIteApu[nPosIAP][4] .AND. x[3][2] == aIteApu[nPosIAP][3]} ) ) > 0
									aItem[nPosItItens][2][2] += aIteApu[nPosIAP][5]
								Else
									aAdd( aItem, {} )
									aAdd( aItem[Len(aItem)], { "CNE_ITEM"  , aIteApu[nPosIAP][4], NIL } )
									aAdd( aItem[Len(aItem)], { "CNE_VLTOT", aIteApu[nPosIAP][5], NIL } )
									aAdd( aItem[Len(aItem)], { "PLAN"  , aCabApu[nI][1][nZ][2], NIL } )
								EndIf
								aMedGCT[Len(aMedGCT)][4] := aIteApu[nPosIAP][4] // Item da Medição
							EndIf
						Next nZ
					EndIf
				Else
					For nZ := 1 To oTFXDetail:Length()
						oTFXDetail:GoLine(nZ)
						If cAgrup <> '1'
							lContinu := oTFXDetail:GetValue('TFX_PLAN') ==  aCabApu[nI][4]
						Else
							lContinu := (nPosPlan := ASCAN(aCabApu[1,1], { |x| x[2] == oTFXDetail:GetValue('TFX_PLAN') }) )> 0
						EndIf
						If lContinu 
							cItem := Posicione("TFG",1,xFilial("TFG")+oTFXDetail:GetValue("TFX_CODTFG"),"TFG_ITCNB")
							aAdd( aItem, {} )
							aAdd( aItem[Len(aItem)], { "CNE_ITEM"  , cItem, NIL } )
							aAdd( aItem[Len(aItem)], { "CNE_VLTOT", oTFXDetail:GetValue('TFX_VLRMED'), NIL } )
							Aadd( aItnsRef,{cItem,'Materiais de implantação'})

							If cAgrup == '1'
								aAdd( aItem[Len(aItem)], { "PLAN"  , aCabApu[1,1,nPosPlan,2], NIL } )
							Else
								aAdd( aItem[Len(aItem)], { "PLAN"  , aCabApu[nI][4], NIL } )
							EndIf

							oTFXDetail:SetValue('TFX_NUMMED',cNumMed)
							oTFXDetail:SetValue('TFX_ITMED',cItem)

						EndIf
					Next nZ
				EndIf


				// Itens apurados para os materiais de consumo
				If !lDsgCN
					If cAgrup <> '1'
						nPosIAP := aScan( aIteApu, { |x| x[1] == 3 .And. x[2] == aCabApu[nI][1] } )

						If nPosIAP > 0
							// verifica se o item da planilha já foi adicionado a medição e caso já tenha, só soma o valor
							If ( nPosItItens := aScan( aItem, {|x| x[1][2] == aIteApu[nPosIAP][4] } ) ) > 0
								aItem[nPosItItens][2][2] += aIteApu[nPosIAP][5]
							Else
								aAdd( aItem, {} )
								aAdd( aItem[Len(aItem)], { "CNE_ITEM"  , aIteApu[nPosIAP][4], NIL } )
								aAdd( aItem[Len(aItem)], { "CNE_VLTOT", aIteApu[nPosIAP][5], NIL } )
								aAdd( aItem[Len(aItem)], { "PLAN"  , aCabApu[nI][4], NIL } )
							EndIf
							aMedGCT[Len(aMedGCT)][5] := aIteApu[nPosIAP][4] // Item da Medição
						EndIf
					Else
						For nZ := 1 To Len(aCabApu[1][1])
							nPosIAP := aScan( aIteApu, { |x| x[1] == 3 .And. x[2] == aCabApu[1][1][nZ][1] } )

							If nPosIAP > 0
								// verifica se o item da planilha já foi adicionado a medição e caso já tenha, só soma o valor
								If ( nPosItItens := aScan( aItem, {|x| x[1][2] == aIteApu[nPosIAP][4] .AND. x[3][2] == aIteApu[nPosIAP][3] } ) ) > 0
									aItem[nPosItItens][2][2] += aIteApu[nPosIAP][5]
								Else
									aAdd( aItem, {} )
									aAdd( aItem[Len(aItem)], { "CNE_ITEM"  , aIteApu[nPosIAP][4], NIL } )
									aAdd( aItem[Len(aItem)], { "CNE_VLTOT", aIteApu[nPosIAP][5], NIL } )
									aAdd( aItem[Len(aItem)], { "PLAN"  , aCabApu[nI][1][nZ][2], NIL } )
								EndIf
								aMedGCT[Len(aMedGCT)][5] := aIteApu[nPosIAP][4] // Item da Medição
							EndIf
						Next nZ
					EndIf
				Else
					For nZ := 1 To oTFYDetail:Length()
						oTFYDetail:GoLine(nZ)
						If cAgrup <> '1'
							lContinu := oTFYDetail:GetValue('TFY_PLAN') ==  aCabApu[nI][4]
						Else
							lContinu := (nPosPlan := ASCAN(aCabApu[1,1], { |x| x[2] == oTFYDetail:GetValue('TFY_PLAN') }) )> 0
						EndIf
						If  lContinu //.And. oTFYDetail:GetValue('TFY_VLRMED') > 0
							cItem := Posicione("TFH",1,xFilial("TFH")+oTFYDetail:GetValue("TFY_CODTFH"),"TFH_ITCNB")
							aAdd( aItem, {} )
							aAdd( aItem[Len(aItem)], { "CNE_ITEM"  , Posicione("TFH",1,xFilial("TFH")+oTFYDetail:GetValue("TFY_CODTFH"),"TFH_ITCNB"), NIL } )
							aAdd( aItem[Len(aItem)], { "CNE_VLTOT", oTFYDetail:GetValue('TFY_VLRMED'), NIL } )
							Aadd( aItnsRef,{cItem,'Materiais de consumo'})

							If cAgrup == '1'
								aAdd( aItem[Len(aItem)], { "PLAN"  , aCabApu[1,1,nPosPlan,2], NIL } )
							Else
								aAdd( aItem[Len(aItem)], { "PLAN"  , aCabApu[nI][4], NIL } )
							EndIf

							oTFYDetail:SetValue('TFY_NUMMED',cNumMed)
							oTFYDetail:SetValue('TFY_ITMED',cItem)

						EndIf
					Next nZ

				EndIf

				//Obtem o local de atendimento
				For nZ := 1 To oTFLDetail:Length()
					oTFLDetail:GoLine(nZ)
					If cAgrup <> '1'
						lContinu := oTFLDetail:GetValue('TFL_PLAN') ==  aCabApu[nI][4]
					Else
						lContinu := (nPosPlan := ASCAN(aCabApu[1,1], { |x| x[2] == oTFLDetail:GetValue('TFL_PLAN') }) )> 0
					EndIf
					If lContinu
						cCodLoc := oTFLDetail:GetValue('TFL_LOCAL')
					EndIf
				Next


				// Itens apurados para os equipamentos de locacao
				If !lDsgCN
					If cAgrup <> '1'
						nPosIAP := aScan( aIteApu, { |x| x[1] == 4 .And. x[2] == aCabApu[nI][1] } )
						If nPosIAP > 0

							// verifica se o item da planilha já foi adicionado a medição e caso já tenha, só soma o valor
							If ( nPosItItens := aScan( aItem, {|x| x[1][2] == aIteApu[nPosIAP][4] } ) ) > 0
								aItem[nPosItItens][2][2] += aIteApu[nPosIAP][5]
							Else
								aAdd( aItem, {} )
								aAdd( aItem[Len(aItem)], { "CNE_ITEM"  , aIteApu[nPosIAP][4], NIL } )
								aAdd( aItem[Len(aItem)], { "CNE_VLTOT", aIteApu[nPosIAP][5], NIL } )
								aAdd( aItem[Len(aItem)], { "PLAN"  , aCabApu[nI][4], NIL } )
							EndIf
							aMedGCT[Len(aMedGCT)][6] := aIteApu[nPosIAP][4] // Item da Medição
						EndIf
					Else
						For nZ :=  1 To Len(aCabApu[1][1])
							nPosIAP := aScan( aIteApu, { |x| x[1] == 4 .And. x[2] == aCabApu[1][1][nZ][1] } )
							If nPosIAP > 0

								// verifica se o item da planilha já foi adicionado a medição e caso já tenha, só soma o valor
								If ( nPosItItens := aScan( aItem, {|x| x[1][2] == aIteApu[nPosIAP][4] } ) ) > 0
									aItem[nPosItItens][2][2] += aIteApu[nPosIAP][5]
								Else
									aAdd( aItem, {} )
									aAdd( aItem[Len(aItem)], { "CNE_ITEM"  , aIteApu[nPosIAP][4], NIL } )
									aAdd( aItem[Len(aItem)], { "CNE_VLTOT", aIteApu[nPosIAP][5], NIL } )
									aAdd( aItem[Len(aItem)], { "PLAN"  , aCabApu[nI][1][nZ][2], NIL } )
								EndIf
								aMedGCT[Len(aMedGCT)][6] := aIteApu[nPosIAP][4] // Item da Medição
							EndIf
						Next nZ
					EndIf
				Else

					For nZ := 1 To oTFLDetail:Length()
						oTFLDetail:GoLine(nZ)
						If cAgrup <> '1'
							lContinu := oTFLDetail:GetValue('TFL_PLAN') ==  aCabApu[nI][4]
						Else
							lContinu := (nPosPlan := ASCAN(aCabApu[1,1], { |x| x[2] == oTFLDetail:GetValue('TFL_PLAN') }) )> 0
						EndIf
						If  lContinu

							For nW := 1 To oTFIDetail:Length()
								oTFIDetail:GoLine(nW)
								nTotItem := 0

								For nU := 1 To oTFZDetail:Length()
									oTFZDetail:GoLine(nU)
									If oTFZDetail:GetValue('TFZ_TOTAL') > 0
										nTotItem += oTFZDetail:GetValue('TFZ_TOTAL')
										oTFZDetail:SetValue('TFZ_NUMMED',cNumMed)
										oTFZDetail:SetValue('TFZ_ITMED',oTFIDetail:GetValue('TFI_ITCNB'))
									EndIf

								Next nU

								aAdd( aItem, {} )
								aAdd( aItem[Len(aItem)], { "CNE_ITEM"  , oTFIDetail:GetValue('TFI_ITCNB'), NIL } )
								aAdd( aItem[Len(aItem)], { "CNE_VLTOT", nTotItem, NIL } )
								Aadd( aItnsRef,{oTFIDetail:GetValue('TFI_ITCNB'),'Locação de equipamentos'})
								If cAgrup == '1'
									aAdd( aItem[Len(aItem)], { "PLAN"  , aCabApu[1,1,nPosPlan,2], NIL } )
								Else
									aAdd( aItem[Len(aItem)], { "PLAN"  , aCabApu[nI][4], NIL } )
								EndIf

							Next nW
						EndIf
					Next nZ
				EndIf
				//-- Valida o saldo do item da CNB e elimina itens que não devem ser levados para a medição
				If cAgrup <> '1'
					If lRet .And. lDsgCN .And. !At930VldCNB(@aItem,aItemExc,aItnsRef,aCabApu[nI][1],aCabApu[nI][2],aCabApu[nI][3],aCabApu[nI][4])
						lRet := .F.
						Exit
					EndIf
				Else
					For nZ := 1 To Len(aCabApu[nI][1])
						If lRet .And. lDsgCN .And. !At930VldCNB(@aItem,aItemExc,aItnsRef,aCabApu[nI][1][nZ][1],aCabApu[nI][2],aCabApu[nI][3],aCabApu[nI][1][nZ][2], .T.)
							lRet := .F.
							aPlan[nZ][3] := .F.
							Exit
						EndIf
					Next nZ
				EndIf
				
				
				// função At930VldSld = [valor da parcela na CNF maior que o valor da medição?]
				aCabApu[nI][6] := At740Recor(aCabe[2][2])
				aCabApu[nI][7] := cOpcApu
				aCabApu[nI][8] := 0 //Incorporação do Valor da Hora-extra, conforme a medição já está sendo realizado no valor da medição
				aCabApu[nI][9] := nVlrDesc
				aCabApu[nI][10] := nVlrMulta
				aCabApu[nI][11] := nVlrBoni

				aCloneCab := ACLONE(aCabApu[nI])
				If cAgrup <> '1'
					If Len(aCabe) > 0 .And. Len(aItem) > 0 .And. lRet
						lMsErroAuto:= .F.

						//ExecAuto para inclusão da medição/apuração.

						TEC930autG(.T.)
						MsExecAuto({|a,b,c,d|, TecXMedicao(a,b,c,Nil,Nil,Nil,d,aMultas,aDescs,@lRet, aPlan, .F.) },aCabe,aItem, MODEL_OPERATION_INSERT )
						TEC930autG(.F.)

						aMultas := {}
						aDescs  := {}
						If !lMsErroAuto
							lMsErroAuto := .F.

							//Coleta o codigo do local de atendimento
							aComplSC5 := GetComplSc5(cCodLoc)

							//ExecAuto para a finalização da medição/apuração.
							MsExecAuto({|a,b,c,d|, TecXMedicao(a,b,c,Nil,Nil,Nil,d,Nil,aComplSC5,@lRet, aPlan, .F.)},aCabe,aItem, MODEL_OPERATION_ONLYUPDATE )

							If lMsErroAuto
								If Empty(NomeAutoLog()) .OR. Empty(MemoRead(NomeAutoLog()))
									Help(,,'AT930ERRMD2',,STR0078,1,0)
								Else
									MostraErro()
								EndIf
								lRet:= .F.
								Exit
							EndIf
						Else
							If Empty(NomeAutoLog()) .OR. Empty(MemoRead(NomeAutoLog()))
								Help(,,'AT930ERRMD1',,STR0079,1,0)
							Else
								MostraErro()
							EndIf
							lRet:= .F.
							Exit
						EndIf
					EndIf 
				EndIf
			Else
				If cAgrup == '1'
					lRet := .F.
				EndIf	
			EndIf
		Next nI
		If lRet .AND. cAgrup == '1'
			If lMonitor
				At930bStatus(cVarThread,aCabe[1][2],cNumMed) 
			EndIf	
			If lMV_GSLOG
				oGsLog:addLog("MonitorApur "+ aCabe[2][2] + " " + cValToChar(cNumMed), STR0198 ) //"parametros recebidos" 
				oGsLog:addLog("MonitorApur "+ aCabe[2][2] + " " + cValToChar(cNumMed), "------------------") 
				oGsLog:addLog("MonitorApur "+ aCabe[2][2] + " " + cValToChar(cNumMed), "CND_CONTRA " + aCabe[2][2] ) 
				oGsLog:addLog("MonitorApur "+ aCabe[2][2] + " " + cValToChar(cNumMed), "CND_NUMMED " + cNumMed ) 
				oGsLog:addLog("MonitorApur "+ aCabe[2][2] + " " + cValToChar(cNumMed), STR0199 + cFilAnt ) //"Filial "
				oGsLog:addLog("MonitorApur "+ aCabe[2][2] + " " + cValToChar(cNumMed), STR0200 ) //"Planilhas Processadas "
				oGsLog:addLog("MonitorApur "+ aCabe[2][2] + " " + cValToChar(cNumMed), "------------------")
				If Len(aPlan) > 0
					For nX := 1 to Len(aPlan)
						If aPlan[nX][4] > 0
							oGsLog:addLog("MonitorApur "+ aCabe[2][2] + " " + cValToChar(cNumMed), STR0202 + aPlan[nX][1] )
						EndIf
					Next nX 
				EndIf	
				oGsLog:addLog("MonitorApur "+ aCabe[2][2] + " " + cValToChar(cNumMed), "------------------")
				oGsLog:addLog("MonitorApur "+ aCabe[2][2] + " " + cValToChar(cNumMed), STR0203 + time() ) //"Inicio do Processamento: "
			EndIf 
			TEC930autG(.T.)
			MsExecAuto({|a,b,c,d|, TecXMedicao(a,b,c,Nil,Nil,Nil,d,aMultas,aDescs,@lRet, aPlan, .T.) },aCabe,aItem, MODEL_OPERATION_INSERT )
			TEC930autG(.F.)
			aMultas := {}
			aDescs  := {}
			If !lMsErroAuto
				lMsErroAuto := .F.

				//Coleta o codigo do local de atendimento
				aComplSC5 := GetComplSc5(cCodLoc)

				//ExecAuto para a finalização da medição/apuração.
				MsExecAuto({|a,b,c,d|, TecXMedicao(a,b,c,Nil,Nil,Nil,d,Nil,aComplSC5,@lRet, aPlan, .T.)},aCabe,aItem, MODEL_OPERATION_ONLYUPDATE )
				If lMsErroAuto
					If !lMonitor
						If Empty(NomeAutoLog()) .OR. Empty(MemoRead(NomeAutoLog()))
							Help(,,'AT930ERRMD2',,STR0078,1,0)
						Else
							MostraErro()
						EndIf
					Else
						If lMV_GSLOG
							aLogErro := GetAutoGRLog()
							cErro := ""
							AEval( aLogErro, { |a| cErro += ( a + CRLF ) } )
							oGsLog:addLog("MonitorApur "+ aCabe[2][2] + " " + cValToChar(cNumMed), STR0204 + time() ) //"Fim do Processamento: "	
							oGsLog:addLog("MonitorApur "+ aCabe[2][2] + " " + cValToChar(cNumMed), STR0205 ) //"Medição com Erro"
							oGsLog:addLog("MonitorApur "+ aCabe[2][2] + " " + cValToChar(cNumMed), STR0206 + cErro ) //"Problema encontrado: "
							oGsLog:addLog("MonitorApur "+ aCabe[2][2] + " " + cValToChar(cNumMed), "------------------") 
							oGsLog:printLog("MonitorApur "+ aCabe[2][2] + " " + cValToChar(cNumMed))
						EndIf	
					EndIf	
					lRet:= .F.
				ElseIf lMV_GSLOG
					oGsLog:addLog("MonitorApur "+ aCabe[2][2] + " " + cValToChar(cNumMed), STR0204 + time() ) //"Fim do Processamento: "
					oGsLog:addLog("MonitorApur "+ aCabe[2][2] + " " + cValToChar(cNumMed), STR0207 ) //"Medição Processada com sucesso"		
					oGsLog:addLog("MonitorApur "+ aCabe[2][2] + " " + cValToChar(cNumMed), "------------------") 
					oGsLog:printLog("MonitorApur "+ aCabe[2][2] + " " + cValToChar(cNumMed))
				EndIf
			Else
				If !lMonitor
					If Empty(NomeAutoLog()) .OR. Empty(MemoRead(NomeAutoLog()))
						Help(,,'AT930ERRMD1',,STR0079,1,0)
					Else
						MostraErro()	
					EndIf
				Else
					If lMV_GSLOG
						aLogErro := GetAutoGRLog()
						cErro := ""
						AEval( aLogErro, { |a| cErro += ( a + CRLF ) } )
						oGsLog:addLog("MonitorApur "+ aCabe[2][2] + " " + cValToChar(cNumMed), STR0204 + time() ) //"Fim do Processamento: "	
						oGsLog:addLog("MonitorApur "+ aCabe[2][2] + " " + cValToChar(cNumMed), STR0205 ) //"Medição com Erro"
						oGsLog:addLog("MonitorApur "+ aCabe[2][2] + " " + cValToChar(cNumMed), STR0206 + cErro ) //"Problema encontrado: "
						oGsLog:addLog("MonitorApur "+ aCabe[2][2] + " " + cValToChar(cNumMed), "------------------") 
						oGsLog:printLog("MonitorApur "+ aCabe[2][2] + " " + cValToChar(cNumMed))
					EndIf	
				EndIf	
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

// Atualiza as tabelas com dados gerados da medições do GCT
If lRet

	FwModelActive(oModel) // restabelece o model da apuração como o ativo
	If !lMedExce .AND. !lApuraHE
		If lMedExt
			cWhereCob := "%TFF.TFF_COBCTR = '2' AND TFF.TFF_PRCVEN > 0%"
		Else
			cWhereCob := "%TFF.TFF_COBCTR <> '2' %"
		EndIf

		If lGsGerOS
			//Populando campos para a apuração do RH
			BeginSql Alias cAliasQry
				SELECT AB9.AB9_FILIAL, AB9.AB9_NUMOS, AB9.AB9_CODTEC, AB9.AB9_SEQ
				FROM %table:ABB% ABB
					JOIN %table:AB9% AB9 ON AB9.AB9_FILIAL = %xFilial:AB9%
										AND AB9.AB9_ATAUT = ABB.ABB_CODIGO
										AND AB9.AB9_NUMOS = ABB.ABB_CHAVE
										AND AB9.AB9_ITAPUR = ' '
										AND AB9.%NotDel%
					JOIN %table:ABA% ABA ON ABA.ABA_FILIAL = %xFilial:ABA%
										AND ABA.ABA_NUMOS = AB9.AB9_NUMOS
										AND ABA.ABA_SEQ  =  AB9.AB9_SEQ
										AND ABA.%NotDel%
					JOIN %table:ABQ% ABQ ON ABQ.ABQ_FILIAL = %xFilial:ABQ%
										AND ABB.ABB_IDCFAL = %Exp:cIdcABQ%
										AND ABQ.%NotDel%
					JOIN %table:TFF% TFF ON TFF.TFF_FILIAL = %xFilial:TFF%
										AND TFF.TFF_FILIAL = ABQ.ABQ_FILTFF
										AND TFF.TFF_COD = ABQ.ABQ_CODTFF
										AND %Exp:cWhereCob%
										AND TFF.%NotDel%
					JOIN %table:TFL% TFL ON TFL.TFL_FILIAL = %xFilial:TFL%
										AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
										AND TFL.TFL_CONTRT = %Exp:cMV_PAR01%
										AND TFL.TFL_CONREV = %Exp:cRevCtr%
										AND TFL.%NotDel%
				WHERE ABB.ABB_FILIAL = %xFilial:ABB%
				AND ABB.ABB_CHEGOU = 'S'
				AND ABB.ABB_ATENDE = '1'
				AND ABB.ABB_DTINI >= %Exp:cMV_PAR02%
				AND ABB.ABB_DTINI <= %Exp:cMV_PAR03%
				AND ABB.ABB_DTFIM >= %Exp:cMV_PAR02%
				AND ABB.ABB_DTFIM <= %Exp:cMV_PAR03%
				AND ABQ.ABQ_CONTRT = %Exp:cMV_PAR01%
				AND ABB.%NotDel%
				GROUP BY AB9.AB9_FILIAL, AB9.AB9_NUMOS, AB9.AB9_CODTEC, AB9.AB9_SEQ
			EndSql
			
			dbSelectArea("AB9")
			AB9->(dbSetOrder(1))

		Else
			//Populando campos para a apuração do RH
			BeginSql Alias cAliasQry
				SELECT ABB.R_E_C_N_O_ ABBREC
				FROM %table:ABB% ABB
					JOIN %table:ABQ% ABQ ON ABQ.ABQ_FILIAL = %xFilial:ABQ%
										AND ABB.ABB_IDCFAL = %Exp:cIdcABQ%
										AND ABQ.%NotDel%
					JOIN %table:TFF% TFF ON TFF.TFF_FILIAL = %xFilial:TFF%
										AND TFF.TFF_FILIAL = ABQ.ABQ_FILTFF
										AND TFF.TFF_COD = ABQ.ABQ_CODTFF
										AND %Exp:cWhereCob%
										AND TFF.%NotDel%
					JOIN %table:TFL% TFL ON TFL.TFL_FILIAL = %xFilial:TFL%
										AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
										AND TFL.TFL_CONTRT = %Exp:cMV_PAR01%
										AND TFL.TFL_CONREV = %Exp:cRevCtr%
										AND TFL.%NotDel%
				WHERE ABB.ABB_FILIAL = %xFilial:ABB%
				AND ABB.ABB_CHEGOU = 'S'
				AND ABB.ABB_ATENDE = '1'
				AND ABB.ABB_DTINI >= %Exp:cMV_PAR02%
				AND ABB.ABB_DTINI <= %Exp:cMV_PAR03%
				AND ABB.ABB_DTFIM >= %Exp:cMV_PAR02%
				AND ABB.ABB_DTFIM <= %Exp:cMV_PAR03%
				AND ABQ.ABQ_CONTRT = %Exp:cMV_PAR01% 
				AND ABB.ABB_ITAPUR = ' '
				AND ABB.%NotDel% 
			EndSql

			dbSelectArea("ABB")
		Endif
		
		While (cAliasQry)->(!Eof())
			If lGsGerOS
				If AB9->(dbSeek(xFilial("AB9")+(cAliasQry)->AB9_NUMOS + ;
								(cAliasQry)->AB9_CODTEC + (cAliasQry)->AB9_SEQ))
					Reclock("AB9",.F.)
					AB9->AB9_ITAPUR := oTFVMaster:GetValue("TFV_CODIGO")
					MsUnlock()
				EndIf
			Else
				ABB->(DbGoTo((cAliasQry)->ABBREC))
				Reclock("ABB",.F.)
				ABB->ABB_ITAPUR := oTFVMaster:GetValue("TFV_CODIGO")
				ABB->(MsUnlock())
			Endif
			(cAliasQry)->(dbSkip())
		EndDo

		(cAliasQry)->(dBCloseArea())

		If lMedExt
			cWhereCob := "%TFG.TFG_COBCTR = '2' AND TFG.TFG_PRCVEN > 0%"
		Else
			cWhereCob := "%TFG.TFG_COBCTR <> '2' %"
		EndIf

		// Populando campos para a apuração dos Materiais de implantação
		BeginSql Alias cAliasIMI

			SELECT TFS.TFS_CODIGO
			FROM %table:TFS% TFS
				JOIN %table:TFG% TFG ON TFG.TFG_FILIAL = %xFilial:TFG%
									AND TFS.TFS_CODTFG = TFG.TFG_COD
									AND %Exp:cWhereCob%
									AND TFG.%NotDel%
				JOIN %table:TFF% TFF ON TFF.TFF_FILIAL = %xFilial:TFF%
									AND TFF.TFF_COD = TFG.TFG_CODPAI
									AND TFF.%NotDel%
				JOIN %table:TFL% TFL ON TFL.TFL_FILIAL = %xFilial:TFL%
									AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
									AND TFL.%NotDel%
			WHERE TFS.TFS_FILIAL = %xFilial:TFS%
			AND TFS.TFS_ITAPUR = ' '
			AND TFS.TFS_DTAPON >= %Exp:cMV_PAR02%
			AND TFS.TFS_DTAPON <= %Exp:cMV_PAR03%
			AND TFL.TFL_CONTRT = %Exp:cMV_PAR01%
			AND TFL.TFL_CONREV = %Exp:cRevCtr%
			AND TFF.TFF_LOCAL IN %Exp:cLocal%
			AND TFS.%NotDel%

		EndSql

		dbSelectArea("TFS")
		TFS->(dbSetOrder(1))

		While (cAliasIMI)->(!Eof())

			If TFS->(dbSeek(xFilial("TFS")+(cAliasIMI)->TFS_CODIGO))
				Reclock("TFS",.F.)
				TFS->TFS_ITAPUR := oTFVMaster:GetValue("TFV_CODIGO")
				MsUnlock()
			EndIf

			(cAliasIMI)->(dbSkip())

		EndDo
		
		(cAliasIMI)->(dBCloseArea())

		If lMedExt
			cWhereCob := "%TFH.TFH_COBCTR = '2' AND TFH.TFH_PRCVEN > 0%"
		Else
			cWhereCob := "%TFH.TFH_COBCTR <> '2' %"
		EndIf

		// Populando campos para a apuração dos Materiais de consumo
		BeginSql Alias cAliasIMC

			SELECT TFT.TFT_CODIGO
			FROM %table:TFT% TFT
				JOIN %table:TFH% TFH ON TFH.TFH_FILIAL = %xFilial:TFH%
									AND TFT.TFT_CODTFH = TFH.TFH_COD
									AND %Exp:cWhereCob%
									AND TFH.%NotDel%
				JOIN %table:TFF% TFF ON TFF.TFF_FILIAL = %xFilial:TFF%
									AND TFF.TFF_COD = TFH.TFH_CODPAI
									AND TFF.%NotDel%
				JOIN %table:TFL% TFL ON TFL.TFL_FILIAL = %xFilial:TFL%
									AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
									AND TFL.%NotDel%
			WHERE TFT.TFT_FILIAL = %xFilial:TFT%
			AND TFT.TFT_ITAPUR = ' '
			AND TFT.TFT_DTAPON >= %Exp:cMV_PAR02%
			AND TFT.TFT_DTAPON <= %Exp:cMV_PAR03%
			AND TFL.TFL_CONTRT = %Exp:cMV_PAR01%
			AND TFL.TFL_CONREV = %Exp:cRevCtr%
			AND TFF.TFF_LOCAL IN %Exp:cLocal%
			AND TFT.%NotDel%

		EndSql

		DbSelectArea("TFT")
		TFT->( DbSetOrder( 1 ) )

		While (cAliasIMC)->(!Eof())

			If TFT->(dbSeek(xFilial("TFT")+(cAliasIMC)->TFT_CODIGO))
				Reclock("TFT",.F.)
				TFT->TFT_ITAPUR := oTFVMaster:GetValue("TFV_CODIGO")
				MsUnlock()
			EndIf

			(cAliasIMC)->(dbSkip())

		EndDo

		(cAliasIMC)->(dBCloseArea())
		// Populando campos para a apuração dos Equipamentos de Locação
		BeginSql Alias cAliasTEW

			SELECT TEW.TEW_FILIAL, TEW.TEW_CODMV, TEW.TEW_BAATD
			FROM %table:TEW% TEW
				JOIN %table:TFI% TFI ON TFI.TFI_FILIAL = %xFilial:TFI%
									AND TFI.TFI_COD = TEW.TEW_CODEQU
									AND TFI.%NotDel%
				JOIN %table:TFL% TFL ON TFL.TFL_FILIAL = %xFilial:TFL%
									AND TFL.TFL_CODIGO = TFI.TFI_CODPAI
									AND TFL.TFL_CONTRT = %Exp:cMV_PAR01%
									AND TFL.TFL_CONREV = %Exp:cRevCtr%
									AND TFL.%NotDel%
			WHERE TEW.TEW_FILIAL = %xFilial:TFT%
			AND TEW.TEW_DTRINI <= %Exp:cMV_PAR03%
			AND ( ( TEW.TEW_DTRFIM = ' ' OR TEW.TEW_DTRFIM >= %Exp:cMV_PAR02%) AND
					( TEW.TEW_DTAMNT = ' ' OR TEW.TEW_DTAMNT >= %Exp:cMV_PAR02%) )
			AND TEW.%NotDel%
		EndSql

		DbSelectArea("TEW")
		TEW->( DbSetOrder( 1 ) )

		While (cAliasTEW)->(!Eof())

			If TEW->(dbSeek(xFilial("TEW")+(cAliasTEW)->TEW_CODMV))
				TEW->(Reclock("TEW",.F.))
				TEW->TEW_ITAPUR := oTFVMaster:GetValue("TFV_CODIGO")
				TEW->(MsUnlock())
			EndIf

			//Atualiza o código da apuração/medição nas marcações do horimetro da base de atendimento (equipamento),
			//caso este tenha sido utilizado em sua apuração/medição.
			At970GvTFV((cAliasTEW)->TEW_BAATD, oTFVMaster:GetValue("TFV_CODIGO"))

			(cAliasTEW)->(dbSkip())

		EndDo

		(cAliasTEW)->(dBCloseArea())
	
	
		// Atualizando os grids com os dados de medição gerada pelo GCT
		//Atualizando itens da apuração do RH
		nVlrHora := 0
		nVlrTot  := 0
		nPercHre := 0

		For nI := 1 To oModel:GetModel("TFWDETAIL"):Length()

			oModel:GetModel("TFWDETAIL"):GoLine(nI)
			If !lDsgCN
				nPosPlan := aScan( aMedGCT, { |x| x[1] == oModel:GetModel("TFWDETAIL"):GetValue("TFW_CODTFL") } )

				If nPosPlan > 0
					oModel:GetModel("TFWDETAIL"):SetValue("TFW_NUMMED", aMedGCT[nPosPlan][2])
					oModel:GetModel("TFWDETAIL"):SetValue("TFW_ITMED", aMedGCT[nPosPlan][3])
				EndIf
			EndIf
			//Atualizando a tabela de detalhes da apuração
			aRetDet := At930QDetRH( oTFVMaster:GetValue("TFV_CONTRT"),;
									oTFVMaster:GetValue("TFV_DTINI"),;
									oTFVMaster:GetValue("TFV_DTFIM"),;
									oModel:GetModel("TFWDETAIL"):GetValue("TFW_CODTFF"),;
									oModel:GetModel("TFWDETAIL"):GetValue("TFW_CODTFL"),;
									oTFVMaster:GetValue("TFV_CODIGO"),;
									.F. )

			For nX:=1 To Len(aRetDet[1])
				For nY:=1 To Len(aRetDet[1][nX])

					If !Empty(oModel:GetModel("TIPDETAIL"):GetValue("TIP_CODEQU")) .And. ;
						!Empty(oModel:GetModel("TIPDETAIL"):GetValue("TIP_CODTEC"))

						oModel:GetModel("TIPDETAIL"):AddLine()
					EndIf

					oModel:GetModel("TIPDETAIL"):SetValue("TIP_FILIAL", xFilial("TIP")		   )
					oModel:GetModel("TIPDETAIL"):SetValue("TIP_CODTEC", aRetDet[1][nX][nY][1])
					oModel:GetModel("TIPDETAIL"):SetValue("TIP_QTDE"  , aRetDet[1][nX][nY][3])
					oModel:GetModel("TIPDETAIL"):SetValue("TIP_VLRAPR", aRetDet[1][nX][nY][4])
					oModel:GetModel("TIPDETAIL"):SetValue("TIP_DTINI" , oTFVMaster:GetValue("TFV_DTINI"))
					oModel:GetModel("TIPDETAIL"):SetValue("TIP_DTFIM" , oTFVMaster:GetValue("TFV_DTFIM"))

					If nX == 2

						oModel:GetModel("TIPDETAIL"):SetValue("TIP_HEMOT", aRetDet[1][nX][nY][5])

						nPercHre := aRetDet[1][nX][nY][4] / oModel:GetModel("TFWDETAIL"):GetValue("TFW_VLHORE")
						nVlrTot := oModel:GetModel("TFWDETAIL"):GetValue("TFW_VLREXT") * nPercHre

						oModel:GetModel("TIPDETAIL"):SetValue("TIP_VLRMED", nVlrTot)

					Else

						nVlrHora :=	oModel:GetModel("TFWDETAIL"):GetValue("TFW_VLRMED") / ;
										oModel:GetModel("TFWDETAIL"):GetValue("TFW_HORAN")

						nVlrTot := aRetDet[1][nX][nY][3] * nVlrHora

						oModel:GetModel("TIPDETAIL"):SetValue("TIP_VLRMED", nVlrTot)
					EndIf

				Next
			Next

		Next nI

		//Atualizando itens do Material de Implantaçao
		For nI := 1 To oModel:GetModel("TFXDETAIL"):Length()

			If !lDsgCN
				oModel:GetModel("TFXDETAIL"):GoLine(nI)
				nPosPlan := aScan( aMedGCT, { |x| x[1] == oModel:GetModel("TFXDETAIL"):GetValue("TFX_CODTFL") } )


				If nPosPlan > 0
					oModel:GetModel("TFXDETAIL"):SetValue("TFX_NUMMED", aMedGCT[nPosPlan][2])
					oModel:GetModel("TFXDETAIL"):SetValue("TFX_ITMED", aMedGCT[nPosPlan][4])
				EndIf
			EndIf

		Next nI

		//Atualizando itens do Material de Consumo
		For nI := 1 To oModel:GetModel("TFYDETAIL"):Length()

			If !lDsgCN
				oModel:GetModel("TFYDETAIL"):GoLine(nI)
				nPosPlan := aScan( aMedGCT, { |x| x[1] == oModel:GetModel("TFYDETAIL"):GetValue("TFY_CODTFL") } )

				If nPosPlan > 0
					oModel:GetModel("TFYDETAIL"):SetValue("TFY_NUMMED", aMedGCT[nPosPlan][2])
					oModel:GetModel("TFYDETAIL"):SetValue("TFY_ITMED", aMedGCT[nPosPlan][5])
				EndIf
			EndIf

		Next nI

		//Atualizando itens de Locacao de Equipamento
		For xAux := 1 To oModel:GetModel("TFLDETAIL"):Length()
			oModel:GetModel("TFLDETAIL"):GoLine(xAux)

			nPosPlan := aScan( aMedGCT, { |x| x[1] == oModel:GetModel("TFLDETAIL"):GetValue("TFL_CODIGO") } )
			If nPosPlan > 0

				For nJ := 1 To oModel:GetModel("TFIPRODUT"):Length()
					oModel:GetModel("TFIPRODUT"):GoLine(nJ)

					aRetDet  := At930QDetLE(oModel:GetModel("TFIPRODUT"):GetValue("TFI_COD"))
					nQtdBase := Len(aRetDet)

					For nI := 1 To oModel:GetModel("TFZDETAIL"):Length()
						oModel:GetModel("TFZDETAIL"):GoLine(nI)
						If !lDsgCN
							oModel:GetModel("TFZDETAIL"):SetValue("TFZ_NUMMED", aMedGCT[nPosPlan][2])
							oModel:GetModel("TFZDETAIL"):SetValue("TFZ_ITMED", aMedGCT[nPosPlan][6])
						EndIf

						aAdd( aTEVUpdate, { oModel:GetModel("TFZDETAIL"):GetValue('TFZ_CODTFI'), ;
											oModel:GetModel("TFZDETAIL"):GetValue('TFZ_CODTEV'), ;
											oModel:GetModel("TFZDETAIL"):GetValue('TFZ_QTDAPU') } )

						If oModel:GetModel("TFZDETAIL"):GetValue("TFZ_MODCOB") == "2"

							For nX := 1 To nQtdBase
								aRetDet[nX][4] := oModel:GetModel("TFZDETAIL"):GetValue("TFZ_VLRUNI") * aRetDet[nX][2]
								aRetDet[nX][5] := oModel:GetModel("TFZDETAIL"):GetValue("TFZ_QTDAPU") * aRetDet[nX][7]
								aRetDet[nX][6] := oModel:GetModel("TFZDETAIL"):GetValue("TFZ_VLRUNI") * aRetDet[nX][5]
							Next

						Else

							For nX := 1 To nQtdBase

								aAdd( aRetDet, { aRetDet[nX][1],; 						    						// Base de atendimento
									oModel:GetModel("TFZDETAIL"):GetValue("TFZ_QTDE")  ,; 						// Qtde prevista na apuracao
									oModel:GetModel("TFZDETAIL"):GetValue("TFZ_MODCOB"),; 			  			// Modo de cobrança
									oModel:GetModel("TFZDETAIL"):GetValue("TFZ_VLRUNI") * ;
									oModel:GetModel("TFZDETAIL"):GetValue("TFZ_QTDE"),;   			  			// Valor apurado
									oModel:GetModel("TFZDETAIL"):GetValue("TFZ_QTDAPU") * aRetDet[nX][7],; 	// Qtde medida
									oModel:GetModel("TFZDETAIL"):GetValue("TFZ_VLRUNI") * ;
									(oModel:GetModel("TFZDETAIL"):GetValue("TFZ_QTDAPU") * aRetDet[nX][7]),; 	// Valor medido
									aRetDet[nX][7] } )																// Percentual do item equivalente a locação

							Next

						EndIf

					Next nI

					For nX:=1 To Len(aRetDet)

						If !Empty(oModel:GetModel("TIPDETAIL"):GetValue("TIP_CODEQU")) .Or. ;
							!Empty(oModel:GetModel("TIPDETAIL"):GetValue("TIP_CODTEC"))

							oModel:GetModel("TIPDETAIL"):AddLine()
						EndIf

						oModel:GetModel("TIPDETAIL"):SetValue("TIP_FILIAL", xFilial("TIP")		   )
						oModel:GetModel("TIPDETAIL"):SetValue("TIP_DTINI" , oTFVMaster:GetValue("TFV_DTINI")  )
						oModel:GetModel("TIPDETAIL"):SetValue("TIP_DTFIM" , oTFVMaster:GetValue("TFV_DTFIM")  )
						oModel:GetModel("TIPDETAIL"):SetValue("TIP_CODEQU", aRetDet[nX][1]			)
						oModel:GetModel("TIPDETAIL"):SetValue("TIP_QTDE"  , aRetDet[nX][2]			)
						oModel:GetModel("TIPDETAIL"):SetValue("TIP_HEMOT" , aRetDet[nX][3]			)
						oModel:GetModel("TIPDETAIL"):SetValue("TIP_VLRAPR", aRetDet[nX][4]			)
						oModel:GetModel("TIPDETAIL"):SetValue("TIP_QTDMED", aRetDet[nX][5]			)
						oModel:GetModel("TIPDETAIL"):SetValue("TIP_VLRMED", aRetDet[nX][6]			)

					Next

				Next nJ

			EndIf

		Next xAux

		//Atualiza o saldo dos registros da TEV
		DbSelectArea('TEV')
		TEV->(DbSetOrder(1))  // TEV_FILIAL+TEV_CODLOC+TEV_ITEM
		For nI := 1 To Len(aTEVUpdate)

			If TEV->(DbSeek(xFilial('TEV')+aTEVUpdate[nI,1]+aTEVUpdate[nI,2]))

				nJ := TEV->TEV_SLD - aTEVUpdate[nI,3]
				Reclock('TEV', .F.)
				TEV->TEV_SLD := nJ
				TEV->(MsUnlock())

			EndIf

		Next nI
	EndIf
EndIf

If lRet .AND. lExcedente .AND. lMedExce
	DbSelectArea("TFJ")
	TFJ->( DbSetOrder( 5 ) )  // TFJ_FILIAL + TFJ_CONTRT + TFJ_CONREV
	TFJ->( DbSeek( xFilial("TFJ") + oTFVMaster:GetValue("TFV_CONTRT") + Posicione("CN9",7,xFilial("CN9")+oTFVMaster:GetValue("TFV_CONTRT")+"05","CN9_REVISA")))

	UpdateTGT(TFJ->TFJ_CODIGO, TecBDt2Cmp(oTFVMaster:GetValue("TFV_DTINI")), oTFVMaster:GetValue("TFV_CODIGO"), oModel:GetOperation() == MODEL_OPERATION_DELETE )
EndIf

If lRet .AND. lApuraHE .AND. TecBHasBrT()
	UpdateHE(oTFVMaster:GetValue("TFV_CODIGO"), .T.)
EndIf

If lRet .AND. !Empty(cGrpCom)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³SIGATEC WorkFlow # ME - Inclusão da Medição de Contrato 	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	At774Mail("TFJ",cGrpCom,"ME","<b>"+STR0096+"</b> "+cNumProp+"<b> "+STR0097+"</b>"+cNumCtr) //"Num. Proposta: " # "Nr. Contrato: "
Endif
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} At930Est
	Estorno da medicao/apuracao dos itens gravados
@sample 	At930Est(oModel)
@author 	Serviços
@since		19/11/2013
@version	P11.90
@param  	oExp, Objeto, objeto do modelo de dados a ser gravado
@return  	lRet, Logico, status da gravação
/*/
//------------------------------------------------------------------------------
Function At930Est(oModel)

Local aOldArea	:= GetArea()
Local lRet			:= .T.
Local lExtMed		:= .F.
Local nCont
Local cCodRev		:= ""
Local cCodPln		:= ""
Local cCodTFJ		:= ""
Local cGrpCom		:= ""
Local nI
Local nJ
Local nK
Local nPos
Local cCodContrt 	:= ""
Local aCabMed		:= {}
Local aCabTot		:= {}
Local aIteMed		:= {}
Local aItem		:= {}
Local aPedApu		:= {}

Local cAliasQry	:= GetNextAlias()
Local cAliasIMI	:= GetNextAlias()
Local cAliasIMC	:= GetNextAlias()
Local cAliasTEW	:= GetNextAlias()
Local cAliasTGU	:= GetNextAlias()
Local oModelTFV := oModel:GetModel("TFVMASTER")
Local oModelTFW	:= oModel:GetModel("TFWDETAIL")
Local oModelTFX	:= oModel:GetModel("TFXDETAIL")
Local oModelTFY	:= oModel:GetModel("TFYDETAIL")
Local oModelTFZ	:= oModel:GetModel("TFZDETAIL")
Local lFatAntecip := oModelTFV:GetValue("TFV_ANTECI")=="1"
Local aTEVUpdate	:= {}
Local cCodApu		:= oModelTFV:GetValue("TFV_CODIGO")
Local lVlrHE		:= .F. //Valores de hora-extra
Local lHEMdEx		:= oModelTFV:GetValue("TFV_HREXTR") == "2"
Local lGsGerOS  	:= At930GerOs()
Local lExcedente := TecBHasCrn() .AND. TecBHasExc() .AND. (oModelTFV:GetValue("TFV_TOTEXC") > 0)
Local cContra
Local cCompet
Private lMsErroAuto		:= .F.
Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile	:= .F.

If !lExcedente
	dbSelectArea("TCV")
	TCV->(dbSetOrder(1))
	TCV->(dbSeek(xFilial("TCV")+cCodApu))

	While TCV->(!Eof()) .And. TCV->TCV_FILIAL == xFilial("TCV") .AND. TCV->TCV_NUMAPU == cCodApu
		If Empty(aPedApu) .OR. ASCAN( aPedApu, {|x| x == TCV->TCV_NUMPED }) == 0
			aAdd( aPedApu, TCV->TCV_NUMPED )
		EndIf
		TCV->(dbSkip())
	EndDo
EndIf
lExtMed := (Len(aPedApu) > 0)

If !lExcedente
	If lGsGerOS

		// Estorno para a tabela de recursos humanos
		BeginSql Alias cAliasQry

			SELECT AB9.AB9_FILIAL, AB9.AB9_NUMOS, AB9.AB9_CODTEC, AB9.AB9_SEQ
			FROM %table:AB9% AB9
			WHERE AB9.AB9_FILIAL = %xFilial:AB9%
				AND AB9.AB9_ITAPUR = %Exp:cCodApu%
				AND AB9.%NotDel%

		EndSql

		DbSelectArea("AB9")
		AB9->( DbSetOrder( 1 ) )

		While (cAliasQry)->(!Eof())
			If AB9->(dbSeek(xFilial("AB9")+(cAliasQry)->AB9_NUMOS+(cAliasQry)->AB9_CODTEC+(cAliasQry)->AB9_SEQ))
				Reclock("AB9",.F.)
				AB9->AB9_ITAPUR := ""
				MsUnlock()
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
	Else	
		// Estorno para a tabela de recursos humanos
		BeginSql Alias cAliasQry

			SELECT ABB.R_E_C_N_O_ ABBREC
			FROM %table:ABB% ABB
			WHERE ABB.ABB_FILIAL = %xFilial:ABB%
				AND ABB.ABB_ITAPUR = %Exp:cCodApu%
				AND ABB.%NotDel%

		EndSql

		DbSelectArea("ABB")
		While (cAliasQry)->(!Eof())
			ABB->(DbGoTo((cAliasQry)->ABBREC))
			Reclock("ABB",.F.)
			ABB->ABB_ITAPUR := ""
			ABB->(MsUnlock())
			(cAliasQry)->(dbSkip())
		EndDo
	Endif

	// Estorno para a tabela de materiais de implantação
	BeginSql Alias cAliasIMI

		SELECT TFS.TFS_FILIAL, TFS.TFS_CODIGO
		FROM %table:TFS% TFS
		WHERE TFS.TFS_FILIAL = %xFilial:TFS%
		AND TFS.TFS_ITAPUR = %Exp:cCodApu%
		AND TFS.%NotDel%

	EndSql

	DbSelectArea("TFS")
	TFS->( DbSetOrder( 1 ) )

	While (cAliasIMI)->(!Eof())
		If TFS->(dbSeek(xFilial("TFS")+(cAliasIMI)->TFS_CODIGO))
			Reclock("TFS",.F.)
			TFS->TFS_ITAPUR := ""
			MsUnlock()
		EndIf
		(cAliasIMI)->(dbSkip())
	EndDo

	// Estorno para a tabela de materiais de consumo
	BeginSql Alias cAliasIMC

		SELECT TFT.TFT_FILIAL, TFT.TFT_CODIGO
		FROM %table:TFT% TFT
		WHERE TFT.TFT_FILIAL = %xFilial:TFT%
		AND TFT.TFT_ITAPUR = %Exp:cCodApu%
		AND TFT.%NotDel%

	EndSql

	DbSelectArea("TFT")
	TFT->( DbSetOrder( 1 ) )

	While (cAliasIMC)->(!Eof())
		If TFT->(dbSeek(xFilial("TFT")+(cAliasIMC)->TFT_CODIGO))
			Reclock("TFT",.F.)
			TFT->TFT_ITAPUR := ""
			MsUnlock()
		EndIf
		(cAliasIMC)->(dbSkip())
	EndDo

	// Estorno para a tabela de alocação de recursos
	BeginSql Alias cAliasTEW

		SELECT TEW.TEW_FILIAL, TEW.TEW_CODMV, TEW.TEW_BAATD
		FROM %table:TEW% TEW
		WHERE TEW.TEW_FILIAL = %xFilial:TEW%
		AND TEW.TEW_ITAPUR = %Exp:cCodApu%
		AND TEW.%NotDel%

	EndSql

	DbSelectArea("TEW")
	TEW->( DbSetOrder( 1 ) )

	While (cAliasTEW)->(! Eof())
		If TEW->(dbSeek(xFilial("TEW")+(cAliasTEW)->TEW_CODMV))
			Reclock("TEW",.F.)
			TEW->TEW_ITAPUR := ""
			MsUnlock()
		EndIf
		At970DlTFV((cAliasTEW)->TEW_BAATD, cCodApu)	// Estorna a efetivação da apuração das marcações do horimetro da base de atendimento, caso esta exista.
		(cAliasTEW)->(dbSkip())
	EndDo

	// Estorno para o apontamento de materiais
	BeginSql Alias cAliasTGU

		SELECT TGU.TGU_COD, TGU.TGU_APURAC
		FROM %table:TGU% TGU
		WHERE TGU.TGU_FILIAL = %xFilial:TGU%
		AND TGU.TGU_APURAC = %Exp:cCodApu%
		AND TGU.%NotDel%

	EndSql

	DbSelectArea("TGU")
	TGU->( DbSetOrder( 2 ) )
	While (cAliasTGU)->(!Eof())
		If TGU->(dbSeek(xFilial("TGU")+(cAliasTGU)->TGU_COD))
			Reclock("TGU",.F.)
			TGU->TGU_APURAC := ""
			MsUnlock()
		EndIf
		(cAliasTGU)->(dbSkip())
	EndDo
EndIf

If lExtMed // Verifica se a medição fora do contrato
	//Verifica se existem itens de H.E lançados como pedido-extra em apuração normal
	If lHEMdEx
		// Verificar a apuração dos itens do RH
		For nI := 1 To oModelTFW:Length()
			oModelTFW:GoLine(nI)
			If !Empty(oModelTFW:GetValue("TFW_NUMMED")) .AND. oModelTFW:GetValue("TFW_VLREXT") > 0
				lVlrHE := .T.
				Exit
			EndIf
		Next nI
	EndIf

	For nI:=1 To Len(aPedApu)

		lMsErroAuto := .F.
		MSExecAuto({|x,y,z| Mata410(x,y,z)},{{"C5_NUM",aPedApu[nI],NIL}},{},5)

		If lMsErroAuto
			lRet := .F.
			If Empty(NomeAutoLog()) .OR. Empty(MemoRead(NomeAutoLog()))
				Help(,,'AT930ERRMD3',,STR0080,1,0)   //"Ocorreu erro na exclusão do pedido de cobrança"
			Else
				MostraErro()
			EndIf
			Exit
		Endif

	Next nI

EndIf

If (!lExtMed .or. (lHEMdEx .AND. lVlrHE)) .AND. !lExcedente

	// Verificar a apuração dos itens do RH
	For nI := 1 To oModelTFW:Length()

		oModelTFW:GoLine(nI)

		nPos		:= aScan(aCabMed, {|x| x[2] == oModelTFW:GetValue("TFW_NUMMED") })
		cCodTFJ	:= Posicione("TFL",1,xFilial("TFL")+oModelTFW:GetValue("TFW_CODTFL"),"TFL_CODPAI")
		If nPos == 0 .And. !Empty(oModelTFW:GetValue("TFW_NUMMED"))

			cCodPln	:= Posicione("TFL",1,xFilial("TFL")+oModelTFW:GetValue("TFW_CODTFL"),"TFL_PLAN")
			aAdd( aCabMed, { "CND_NUMMED", oModelTFW:GetValue("TFW_NUMMED"), cCodPln } )

			nPos := aScan(aIteMed,{ |x| x[1] == oModelTFW:GetValue("TFW_NUMMED") } )
			If nPos == 0
				aAdd( aIteMed, { oModelTFW:GetValue("TFW_NUMMED"), oModelTFW:GetValue("TFW_ITMED") } )
			EndIf

		EndIf

	Next nI

	// Verificar a apuração dos materiais de implantação
	For nI := 1 To oModelTFX:Length()

		oModelTFX:GoLine(nI)

		nPos		:= aScan(aCabMed, {|x| x[2] == oModelTFX:GetValue("TFX_NUMMED") })
		cCodTFJ	:= Posicione("TFL",1,xFilial("TFL")+oModelTFX:GetValue("TFX_CODTFL"),"TFL_CODPAI")
		If nPos == 0 .And. !Empty(oModelTFX:GetValue("TFX_NUMMED"))

			cCodPln	:= Posicione("TFL",1,xFilial("TFL")+oModelTFX:GetValue("TFX_CODTFL"),"TFL_PLAN")
			aAdd( aCabMed, { "CND_NUMMED", oModelTFX:GetValue("TFX_NUMMED"), cCodPln } )

			nPos := aScan(aIteMed,{ |x| x[1] == oModelTFX:GetValue("TFX_NUMMED") } )
			If nPos == 0
				aAdd( aIteMed, { oModelTFX:GetValue("TFX_NUMMED"), oModelTFX:GetValue("TFX_ITMED") } )
			EndIf

		EndIf

	Next nI

	// Verificar a apuração dos materiais de consumo
	For nI := 1 To oModelTFY:Length()

		oModelTFY:GoLine(nI)

		nPos		:= aScan(aCabMed, {|x| x[2] == oModelTFY:GetValue("TFY_NUMMED") })
		cCodTFJ	:= Posicione("TFL",1,xFilial("TFL")+oModelTFY:GetValue("TFY_CODTFL"),"TFL_CODPAI")
		If nPos == 0 .And. !Empty(oModelTFY:GetValue("TFY_NUMMED"))

			cCodPln := Posicione("TFL",1,xFilial("TFL")+oModelTFY:GetValue("TFY_CODTFL"),"TFL_PLAN")
			aAdd( aCabMed, { "CND_NUMMED", oModelTFY:GetValue("TFY_NUMMED"), cCodPln } )

			nPos := aScan(aIteMed,{ |x| x[1] == oModelTFY:GetValue("TFY_NUMMED") } )
			If nPos == 0
				aAdd( aIteMed, { oModelTFY:GetValue("TFY_NUMMED"), oModelTFY:GetValue("TFY_ITMED") } )
			EndIf

		EndIf
	Next nI

	// Verificar a apuração das alocações de equipamentos
	For nK := 1 To oModel:GetModel('TFLDETAIL'):Length()
		oModel:GetModel('TFLDETAIL'):GoLine(nK)

		For nJ := 1 To oModel:GetModel('TFIPRODUT'):Length()
			oModel:GetModel('TFIPRODUT'):GoLine(nJ)

			For nI := 1 To oModelTFZ:Length()
				oModelTFZ:GoLine(nI)

				aAdd( aTEVUpdate, { oModelTFZ:GetValue('TFZ_CODTFI'),oModelTFZ:GetValue('TFZ_CODTEV'), oModelTFZ:GetValue('TFZ_QTDAPU') } )
				nPos		:= aScan(aCabMed, {|x| x[2] == oModelTFZ:GetValue("TFZ_NUMMED") })
				cCodTFJ	:= Posicione("TFL",1,xFilial("TFL")+oModelTFZ:GetValue("TFZ_CODTFL"),"TFL_CODPAI")
				If nPos == 0 .And. !Empty(oModelTFZ:GetValue("TFZ_NUMMED"))

					cCodPln	:= Posicione("TFL",1,xFilial("TFL")+oModelTFZ:GetValue("TFZ_CODTFL"),"TFL_PLAN")
					aAdd( aCabMed, { "CND_NUMMED", oModelTFZ:GetValue("TFZ_NUMMED"), cCodPln } )

					nPos := aScan(aIteMed,{ |x| x[1] == oModelTFZ:GetValue("TFZ_NUMMED") } )
					If nPos == 0
						aAdd( aIteMed, { oModelTFZ:GetValue("TFZ_NUMMED"), oModelTFZ:GetValue("TFZ_ITMED") } )
					EndIf

				EndIf

			Next nI

		Next nJ

	Next nK

	//Atualiza o saldo da tabela TEV (cobrança da locação de equipamentos)
	DbSelectArea('TEV')
	TEV->(DbSetOrder(1))  // TEV_FILIAL+TEV_CODLOC+TEV_ITEM
	For nI := 1 To Len(aTEVUpdate)
		If TEV->(DbSeek(xFilial('TEV')+aTEVUpdate[nI,1]+aTEVUpdate[nI,2]))
			nJ := TEV->TEV_SLD + aTEVUpdate[nI,3]
			Reclock('TEV', .F.)
			TEV->TEV_SLD := nJ
			TEV->(MsUnlock())
		EndIf
	Next nI

	// Estorno para o GCT
	If !lFatAntecip .And. Len(aCabMed) > 0

		cCodContrt := oModelTFV:GetValue("TFV_CONTRT")

		For nI:=1 To Len(aCabMed)

			aCabTot := {}
			aItem   := {}

			aAdd( aCabTot, { aCabMed[nI][1], aCabMed[nI][2], NIL } )

			cCodRev := Posicione("CN9",7,xFilial("CN9")+cCodContrt+"05","CN9_REVISA")

			aAdd( aCabTot, { "CND_CONTRA", cCodContrt 		, NIL } )
			aAdd( aCabTot, { "CND_REVISA", cCodRev			, NIL } )
			aAdd( aCabTot, { "CND_NUMERO", aCabMed[nI][3]	, NIL } )

			nPos := aScan(aIteMed,{ |x| x[1] == aCabMed[nI][2] } )
			If nPos > 0
				aAdd( aItem, {} )
				aAdd( aItem[Len(aItem)], { "CNE_ITEM", Alltrim(aIteMed[nPos][2]), Nil } )
			EndIf
			// posiciona no cabeçalho da medição para garantir a execução da execauto para o registro certo
			CND->(DbSetOrder(1))	//CND_FILIAL+CND_CONTRA+CND_REVISA+CND_NUMERO+CND_NUMMED
			CND->(DbSeek(xFilial("CND")+cCodContrt+cCodRev+aCabMed[nI][3]+aCabMed[nI][2]))

			// Estorno da medição/apuração
			MsExecAuto({|a,b,c|, TecXMedicao(a,b,c) },aCabTot,aItem, 7 )
			If !LMsErroAuto
				lMsErroAuto:= .F.
				// Exclusão da medição/apuração
				MsExecAuto({|a,b,c|, TecXMedicao(a,b,c) },aCabTot,aItem, 5 )
				If lMsErroAuto
					lRet := .F.
					If Empty(NomeAutoLog()) .OR. Empty(MemoRead(NomeAutoLog()))
						Help(,,'AT930ERRMD5',, STR0081,1,0) //'Ocorreu erro na exclusão da medição.'
					Else
						MostraErro()
					EndIf
				EndIf
			Else
				lRet:= .F.
				If Empty(NomeAutoLog()) .OR. Empty(MemoRead(NomeAutoLog()))
					Help(,,'AT930ERRMD4',, STR0082,1,0) //'Ocorreu erro no estorno da medição.'
				Else
					MostraErro()
				EndIf
			EndIf

		Next nI
	EndIf
EndIf

If lRet .AND. lExcedente .AND. oModelTFV:GetValue("TFV_TIPO") == '3'

	cContra := oModelTFV:GetValue("TFV_CONTRT")
	cCompet := TecBDt2Cmp(oModelTFV:GetValue("TFV_DTINI"))

	DbSelectArea("TFJ")
	TFJ->( DbSetOrder( 5 ) )  // TFJ_FILIAL + TFJ_CONTRT + TFJ_CONREV
	TFJ->( DbSeek( xFilial("TFJ") + cContra + Posicione("CN9",7,xFilial("CN9")+cContra+"05","CN9_REVISA") ) )

	If (lRet := DelPvExce(TFJ->TFJ_CODIGO, cCompet, oModelTFV:GetValue("TFV_CODIGO")))
		UpdateTGT(TFJ->TFJ_CODIGO, cCompet, oModelTFV:GetValue("TFV_CODIGO"), oModel:GetOperation() == MODEL_OPERATION_DELETE )
	EndIf
EndIf

If lRet .AND. TecBHasBrT() .AND. oModelTFV:GetValue("TFV_TIPO") == '4'
	UpdateHE(oModelTFV:GetValue("TFV_CODIGO"), .F.)
EndIf

If lRet .AND. !Empty(cCodTFJ)
	cGrpCom := Posicione("TFJ",1,xFilial("TFJ")+cCodTFJ,"TFJ_GRPCOM")
	If !Empty(cGrpCom)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³SIGATEC WorkFlow # ME - Estorno da Medição de Contrato 	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		At774Mail("TFJ",cGrpCom,"ME","<b>"+STR0096+"</b> "+TFJ->TFJ_PROPOS+"<b> "+STR0097+"</b>"+TFJ->TFJ_CONTRT,"RED",STR0098) //"Num. Proposta: " # "Nr. Contrato: " # "Estorno"
	Endif
Endif

If !lExcedente
	(cAliasQry)->(DbCloseArea())
	(cAliasIMI)->(DbCloseArea())
	(cAliasIMC)->(DbCloseArea())
	(cAliasTEW)->(DbCloseArea())
	(cAliasTGU)->(DbCloseArea())
EndIf

RestArea(aOldArea)
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At930Commit()
Realiza a Gravação dos Dados utilizando o Model
@param ExpO:Modelo de Dados da Tela de cadastro
@return ExpL: Retorna .T. quando houve sucesso na Gravação
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930Commit(oModel)

Local lRetorno	:= .T.
Local lConfirm
Local lAuto			:= IsBlind()
Local nOperation	:= oModel:GetOperation()
Local lAt930Grv	:= .F.
Local oModTFL		:= oModel:GetModel('TFLDETAIL')
Local oModTFI		:= oModel:GetModel('TFIPRODUT')
Local oModTW6		:= oModel:GetModel('TFITW6DETAIL')
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 0
Local oView 		:= FwViewActive()
Local lTelas 		:= !lAuto .And. oView:IsActive() .And. oView:GetModel():GetId()=="TECA930"
Local aNumMed		:= {}
Local cAliasC6		:= ""
Local nK			:= 1
Local aAuxC6 		:= {}
Local nPosC6		:= 0
Local aAuxTFW		:= {}
Local nW			:= 1

IsBlindRb := lTelas

If FindFunction("CTB105MVC")
	CTB105MVC(.T.) //Altera variavel STATIC no CTBA105
EndIf

If nOperation == MODEL_OPERATION_DELETE	// Quando a operação for de estorno, questionará se realmente deseja realizar o estorno da apuração.

	If !lAuto .And. lTelas
		lConfirm:= MsgYesNo(STR0053) // "Deseja realmente estornar a Apuração?"
	Else
		lConfirm	:= .T.
	EndIf

	If lConfirm == .T.

		Begin Transaction

			If  lAuto .Or. !lTelas 
				lRetorno := At930Est(oModel)
			Else
				MsgRun( STR0184, STR0073, {|| lRetorno := At930Est(oModel) } ) //'Processando Estorno  ' #### 'Aguarde...'
			EndIf		

			If !lRetorno
				DisarmTransacation()
			Else
				FWModelActive(oModel)
				FWFormCommit(oModel)
			EndIf

		End Transaction
	EndIf
Else //Senão for exclusão, não haverá questionamento.

	//Verifica ponto de entrada para continuar a gravação
	If ExistBlock("AT930GRV")
		lAt930Grv := ExecBlock("AT930GRV",.F.,.F.,{oModel})
	EndIf

	If !lAt930Grv
		Begin Transaction

			If lRetorno
				For nZ := 1 To oModTFL:Length()
					oModTFL:GoLine(nZ)
					For nY := 1 To oModTFI:Length()
						oModTFI:GoLine(nY)
						If !EMPTY(oModTFI:GetValue("TFI_PRODUT"))
							For nX := 1 To oModTW6:Length()
								oModTW6:GoLine(nX)
								If oModTW6:GetValue('TW6_VALOR') == 0
									oModTW6:DeleteLine()
								EndIf
							Next
						EndIf
					Next
				Next
			Endif

			If lRetorno .And. ( lAuto .Or. !lTelas )
				lRetorno := At930Grv(oModel)
			Else
				MsgRun( STR0074, STR0073, {|| lRetorno := At930Grv(oModel,@aNumMed) } ) // 'Processando Apuração  ' #### 'Aguarde...'
			EndIf

			If (!lRetorno)
				DisarmTransacation()
			Else
				FWModelActive( oModel )
				If !lAuto .And. lTelas
					MsgRun( STR0075, STR0073, {|| lRetorno := FWFormCommit( oModel ) } ) // 'Gerando Medição' #### 'Aguarde...'
					MsgInfo(STR0049) // "Apuração/Medição efetuada com sucesso."
				Else
					lRetorno := FWFormCommit( oModel )
				EndIf
			EndIf

			If lRetorno
				While GetSX8Len() > nLenSX8
					RollBackSX8()
				End
			Else
				While GetSX8Len() > nLenSX8
					ConfirmSX8()
				End
			EndIf

		End Transaction
		// Atualização dos campos do pedido, em caso de utilização do recurso de abatimento do INSS
		If lRetorno .AND. len(aNumMed) > 0 .AND. !lMedExce
			For nK := 1 to len(aNumMed)
				cAliasC6 := getNextAlias()
				aAuxC6 := {}
				aAuxTFW := {}
				BeginSql Alias cAliasC6
					SELECT C6.C6_ITEMED as ITEM, C6.R_E_C_N_O_ as REC, 'SC6' AS Tabela, C6_ABATINS AS ABTINS FROM %table:SC5% C5
						INNER JOIN %table:SC6% C6 ON C5.C5_NUM = C6.C6_NUM
						INNER JOIN %table:SB5% B5 ON B5.B5_COD = C6.C6_PRODUTO
					WHERE C5_MDNUMED = %Exp:aNumMed[nK]% AND B5.B5_TPISERV = '4'
					 	AND C5.C5_FILIAL = %xFilial:SC5%
					 	AND C6.C6_FILIAL = %xFilial:SC6%
						AND C5.%NotDel% AND B5.%NotDel% AND C6.%NotDel%
					UNION
					SELECT TFW.TFW_ITMED as ITEM,TFW.R_E_C_N_O_ AS REC, 'TFW' AS Tabela, TFW_ABTINS AS ABTINS FROM %table:TFW% TFW 
						WHERE  TFW.TFW_FILIAL = %xFilial:TFW% AND TFW_NUMMED = %Exp:aNumMed[nK]% AND TFW.%NotDel%
							
				EndSql
				
				While (cAliasC6)->(!Eof())
					If (cAliasC6)->Tabela = 'TFW'
						aAdd(aAuxTFW,{(cAliasC6)->ITEM, (cAliasC6)->REC, (cAliasC6)->ABTINS}  )
					EndIf
					If (cAliasC6)->Tabela = 'SC6'
						aAdd(aAuxC6,{(cAliasC6)->ITEM, (cAliasC6)->REC, (cAliasC6)->ABTINS} )
					EndIf
					(cAliasC6)->(dbSkip())
				EndDo
				aSort( aAuxC6,,, { |x,y| x[2] < y[2] } )
				For nW := 1 to len(aAuxC6)
					SC6->(DbGoTo(aAuxC6[nW][2]))
					Reclock("SC6",.F.)
					SC6->C6_ABATINS := aAuxTFW[nW][3]
					SC6->( MsUnlock() )
				Next nW
			Next nK 
			(cAliasC6)->(DbCloseArea())
			
		EndIf
		
	EndIf
EndIf
at930CProc()
IsBlindRb := .F.
Return( lRetorno )


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At930IniEst()
Atualiza as informações das listas, quando for executado o estorno.
@param 		ExpN:Numero da aba qual deseja carregar os dados
@param 		ExpC:Campo qual deseja atribuir o valor
@author 	Serviços
@since  	16/12/2013
@version	P11.9
@return 	Nil
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930IniEst(nAba, cCampo)

Local uRet		  := ""
Local cCodTFF   := ""
Local cCodTFG	:= ""
Local cCodTFH	:= ""
Local cCodTFL   := ""
Local cCodTFI   := ""
Local cAliasTFZ := GetNextAlias()
Local cCodApu   := ""
Local nVlrTot   := 0
Local lMedLeg	:= SuperGetMv("MV_GSMDZER",,"2") == "1" //Verifica se vai habilitar a opção da Legenda de alocação na medição


Do Case
	Case nAba == 1 ; cCodTFF := TFW->TFW_CODTFF ; cCodTFL := TFW->TFW_CODTFL
	Case nAba == 2 ; cCodTFG := TFX->TFX_CODTFG ; cCodTFL := TFX->TFX_CODTFL
	Case nAba == 3 ; cCodTFH := TFY->TFY_CODTFH ; cCodTFL := TFY->TFY_CODTFL
EndCase

If ! INCLUI

	If Right(cCampo,6) == "PRODUT" .Or. Right(cCampo,6) == "DSCPRO"
		If nAba == 1
			dbSelectArea("TFF")
			TFF->(dbSetOrder(1)) // TFF_FILIAL + TFF_COD

			If TFF->(dbSeek(xFilial("TFF")+cCodTFF))
				If Right(cCampo,6) == "PRODUT"
					uRet := TFF->TFF_PRODUT
				Else
					uRet := Posicione("SB1",1,xFilial("SB1")+TFF->TFF_PRODUT,"B1_DESC")
				EndIf
			EndIf
		Elseif nAba == 2
			dbSelectArea("TFG")
			TFG->(dbSetOrder(1)) // TFG_FILIAL + TFG_COD

			If TFG->(dbSeek(xFilial("TFG")+cCodTFG))
				If Right(cCampo,6) == "PRODUT"
					uRet := TFG->TFG_PRODUT
				Else
					uRet := Posicione("SB1",1,xFilial("SB1")+TFG->TFG_PRODUT,"B1_DESC")
				EndIf
			EndIf
		Elseif nAba == 3
			dbSelectArea("TFH")
			TFH->(dbSetOrder(1)) // TFH_FILIAL + TFH_COD

			If TFH->(dbSeek(xFilial("TFH")+cCodTFH))
				If Right(cCampo,6) == "PRODUT"
					uRet := TFH->TFH_PRODUT
				Else
					uRet := Posicione("SB1",1,xFilial("SB1")+TFH->TFH_PRODUT,"B1_DESC")
				EndIf
			EndIf
		Endif
	ElseIf Right(cCampo,5) == "LOCAL" .Or. Right(cCampo,6) == "DESCRI" .Or. (lMedLeg .And. cCampo == "TFW_LEG")

		dbSelectArea("TFL")
		TFL->(dbSetOrder(1))

		If TFL->(dbSeek(xFilial("TFL")+cCodTFL))
			If Right(cCampo,5) == "LOCAL"
				uRet := TFL->TFL_LOCAL
			Elseif lMedLeg .And. cCampo == "TFW_LEG"
				If At930Aloc(cCodTFF,TFV->TFV_DTINI,TFV->TFV_DTFIM)
					uRet := "BR_VERDE"
				Else
					uRet := "BR_VERMELHO"
				Endif
			Else
				uRet := Posicione("ABS",1,xFilial("ABS")+TFL->TFL_LOCAL,"ABS_DESCRI")
			EndIf
		EndIf

	ElseIf cCampo == "TFZ_QTDE"

		dbSelectArea("TFI")
		TFI->(dbSetOrder(1))

		If TFI->(dbSeek(xFilial("TFI")+TFZ->TFZ_CODTFI))
			dbSelectArea("TEV")
			TEV->(dbSetOrder(1))
			If TEV->(dbSeek(xFilial("TEV")+TFZ->TFZ_CODTFI+TFZ->TFZ_CODTEV))
				If	TEV->TEV_MODCOB == "4"	//1=Uso;2=Disponibilidade;3=Mobilizacao;4=Horas;5=Franquia/Excedente
					uRet := 0
				Else
  					uRet := getVlrProp(	TFI->TFI_PERINI, TFI->TFI_PERFIM,;
									   	TEV->TEV_QTDE, TFV->TFV_DTINI, TFV->TFV_DTFIM , , , , , TFI->TFI_QTDVEN, TFV->TFV_CONTRT )
  				EndIf
  			EndIf
		EndIf

	ElseIf cCampo == "TFL_DISP" .Or. cCampo == "TFL_USO" .Or. ;
			cCampo == "TFL_MOBILI" .Or. cCampo == "TFL_VALTOT" .OR. ;
			cCampo == "TFI_DISP" .Or. cCampo == "TFI_USO" .Or. cCampo == "TFI_MOBILI"

		cCodApu := TFV->TFV_CODIGO

		If Left(cCampo,3) == "TFI"
			cCodTFL := TFI->TFI_CODPAI
			If !Empty(TFI->TFI_CODPAI)
				cCodTFI := "%TFZ.TFZ_CODTFI = '" + TFI->TFI_COD + "' AND %"
			Else
				cCodTFI := "% %"
			EndIf
		Else
			cCodTFL := TFL->TFL_CODIGO
			cCodTFI := "% %"
		EndIf

		BeginSql Alias cAliasTFZ

			SELECT TFZ.TFZ_APURAC, TFZ.TFZ_CODTFL, TFZ.TFZ_MODCOB, SUM(TFZ.TFZ_TOTAL) AS TOTAL
			  FROM %table:TFZ% TFZ
			 WHERE TFZ.TFZ_FILIAL = %xFilial:TFZ%
			   AND TFZ.TFZ_APURAC = %Exp:cCodApu%
			   AND TFZ.TFZ_CODTFL = %Exp:cCodTFL%
			   AND %Exp:cCodTFI%
			       TFZ.%NotDel%
			 GROUP BY TFZ.TFZ_APURAC, TFZ.TFZ_CODTFL, TFZ.TFZ_MODCOB

		EndSql

		While (cAliasTFZ)->(!Eof())

			If cCampo <> "TFL_VALTOT"
				If ( (cAliasTFZ)->TFZ_MODCOB == "1" .OR. (cAliasTFZ)->TFZ_MODCOB == "4" ) .And. Right(cCampo,3) == "USO"		//1=Uso;2=Disponibilidade;3=Mobilizacao;4=Horimetro
					uRet := (cAliasTFZ)->TOTAL
				ElseIf (cAliasTFZ)->TFZ_MODCOB == "2" .And. Right(cCampo,4) == "DISP"		//1=Uso;2=Disponibilidade;3=Mobilizacao;4=Horimetro
					uRet := (cAliasTFZ)->TOTAL
				ElseIf (cAliasTFZ)->TFZ_MODCOB == "3" .And. Right(cCampo,6) == "MOBILI"		//1=Uso;2=Disponibilidade;3=Mobilizacao;4=Horimetro
					uRet := (cAliasTFZ)->TOTAL
				EndIf

				If ! Empty(uRet)
					Exit
				EndIf
			Else
				nVlrTot += (cAliasTFZ)->TOTAL
			EndIf

			(cAliasTFZ)->(dbSkip())

		End

		(cAliasTFZ)->(dbCloseArea())

		If cCampo == "TFL_VALTOT"
			uRet := nVlrTot
		EndIf

	ElseIf cCampo == "TFW_TOTHOR" // Total apurado RH
		uRet := TFW->TFW_HORAN + TFW->TFW_HORAE
	ElseIf cCampo == "TFW_VLRTOT" // Total RH
		uRet := TFW->TFW_VLRMED + TFW->TFW_VLREXT
	EndIf

Endif

Return(uRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  HasMedEven()
	Pesquisa se um determinado contrato possui configuração para receber medição eventual
@param 		ExpC:Código do contrato
@param 		ExpC:Sequência da Revisão
@author 	Serviços
@since  	07/01/2014
@version	P11.9
@return 	ExpL:possui(.T.) ou não (.F.) medição eventual configurada
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function HasMedEven( cCtr, cRev )

Local lRet			:= .F.
Local aSave		:= GetArea()
Local aSaveCN9	:= CN9->(GetArea())
Local aSaveCN1	:= CN1->(GetArea())

DbSelectArea('CN9')
CN9->( DbSetOrder( 1 ) ) // CN9_FILIAL+CN9_NUMERO+CN9_REVISA

DbSelectArea('CN1')
CN1->( DbSetOrder( 1 ) ) // CN1_FILIAL+CN1_CODIGO+CN1_ESPCTR

If CN9->( DbSeek( xFilial('CN9')+cCtr+cRev ) ) .And. ;  // procura contrato
	CN1->( DbSeek( xFilial('CN1')+CN9->CN9_TPCTO + '2' ) ) .And. ;  // procura o tipo do contrato
	CN1->CN1_MEDEVE == '1' // possui medição eventual configurada

	lRet := .T.

EndIf

RestArea(aSaveCN1)
RestArea(aSaveCN9)
RestArea(aSave)

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At930VldSld()
Verifica se o saldo da medição do contrato, esta dentro do limite do cronograma financeiro.
@param 		ExpC:Contrato a ser utilzado na medicao
@param 		ExpC:Revisão do contrato a ser utilzado na medicao
@param 		ExpC:Cronograma financeiro do contrato a ser utilzado na medicao
@param 		ExpC:Competencia do contrato a ser utilzado na medicao
@param 		ExpN:Valor total da medição a ser consistido
@param 		ExpC:Indica o tipo de geração de excedentes selecionado pelo usuário na medição
@param 		ExpN:Valor total das horas extras
@author 	Serviços
@since  	07/01/2014
@version	P11.9
@return 	Nil
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At930VldSld(cContrato, cRevisao, cCronog,;
 		cComp, nValMed, cOpcHE, nVlrTotHE,  nVlrDesc,;
 		nVlrMulta,  nVlrBoni, cParcela, nRet, nSlimit, aPlan)

Local lRet    := .F.
Local nLimMed := 0
Local cSeek   := ''
Local aArea   := GetArea()
Local lAgrup	:= .F.
Local nPosPlan	:= 0

Default cOpcHE 	:= "1" // por padrão considera normal+hora extra dentro do limite do contrato
Default nVlrTotHE 	:= 0
Default cParcela   := ''
Default nRet		:= 0
Default nSlimit     := 0
Default aPlan		:= {}

CN9->(dbSetOrder(1))

If CN9->(MsSeek(xFilial("CN9")+cContrato+cRevisao))
	lAgrup := !Empty(aPlan)
	dbSelectArea("CN1")
	CN1->(dbSetOrder(1))

	If CN1->(MsSeek(xFilial("CN1")+CN9->CN9_TPCTO))

		nLimMed := CN1->CN1_LMTMED

		dbSelectArea("CNF")
		CNF->(dbSetOrder(2))
		CNF->(MsSeek(cSeek := xFilial("CNF") + cContrato + cRevisao + cCronog + cComp))
		Do While CNF->(! Eof()) .And. cSeek == CNF->(CNF_FILIAL + CNF_CONTRA + CNF_REVISA + CNF_NUMERO + CNF_COMPET)
			If AllTrim(CNF_PARCEL) == AllTrim(cParcela) //Pesquisa a parcela Selecionada para Medicao
				If lAgrup
					If (nPosPlan := ASCAN( aPlan, { |x| x[2] == CNF->CNF_NUMPLA })) > 0
						nValMed := aPlan[nPosPlan][4]
						lRet := ((CNF->CNF_SALDO + ((CNF->CNF_VLPREV * nLimMed)/100)) >= nValMed - nVlrDesc +  nVlrMulta - nVlrBoni)
					Else
						lRet := .F.
					EndIf
				Else
					lRet := ((CNF->CNF_SALDO + ((CNF->CNF_VLPREV * nLimMed)/100)) >= nValMed - nVlrDesc +  nVlrMulta - nVlrBoni)
				EndIf
				If !lRet
					nRet := (CNF->CNF_SALDO+((CNF->CNF_VLPREV*nLimMed)/100))
					nSlimit := (CNF->CNF_SALDO)
				EndIf
				Exit
			EndIf
			CNF->(dbSkip())
		EndDo

	EndIf

EndIf

RestArea(aArea)

Return(lRet)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At930QDetRH()
Gera as informações do detalhes de horas apuradas do RH.
@param 		ExpC:Contrato a ser utilzado no detalhe
@param 		ExpC:Data Inicial da apuração/medição
@param 		ExpC:Data Final da apuração/medição
@param 		ExpC:Codigo do recurso humano a ser utilizado no detalhe
@param 		ExpC:Codigo do local a ser utilizado no detalhe
@param 		ExpC:Codigo da apuração para a pesquisa no estorno
@param 		ExpL:Para identificar se vai ser retornado dados para a tela ou processamento
@author 	Serviços
@since  	13/02/2014
@version	P12
@return 	ExpA: Array com os dados do detalhe do RH
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At930QDetRH(cContrato, cDataIni, cDataFim, cCodTFF, cCodTFL, cIdApur, lTela)

Local aRet			:= {}
Local aHrNormal	:= {}
Local aTecHrN		:= {}
Local aHrExtra	:= {}
Local aTecHrE		:= {}
Local aHrOsE		:= {}
Local cHora		:= ""
Local cMinutos	:= ""
Local cMod			:= ""
Local cIdcABQ		:= ""
Local cWhereCob	:= ""
Local nPos			:= 0
Local nVlrTot		:= 0
Local nHreTot		:= 0
Local nTecHor		:= 0
Local nValTot		:= 0
Local cAliasQry	:= GetNextAlias()
Local cAliasABR	:= GetNextAlias()
Local cRevCtr		:= Posicione("CN9",7,xFilial("CN9")+cContrato+"05","CN9_REVISA")
Local cOperConc	:= if(Trim(Upper(TcGetDb())) $ "ORACLE,POSTGRES,DB2,INFORMIX","||","+")
Local cOperador	:= "%"+cOperConc+"%"
Local nVlrCont	:= 0
Local nVlrHor		:= 0
Local nHorTot		:= 0
Local lGsGerOS  := At930GerOs()
Local cExprHE
Default cIdApur := ""
Default lTela   := .T.



If Trim(Upper(TcGetDb())) $ "ORACLE,POSTGRES,DB2,INFORMIX"

	//Calculo para horas
	cHora    := "(SUM(CAST(SUBSTR(ABR.ABR_TEMPO,1,2) AS INTEGER)) * 60)"

	//Calculo para minutos
	cMinutos := "SUM(CAST(SUBSTR(ABR.ABR_TEMPO,4,2) AS INTEGER))"

	If Trim(Upper(TcGetDb())) $ "POSTGRES"
		cMod := "%CONCAT(CONCAT(SUBSTR( Concat( '00', Cast((" + cHora + "+" + cMinutos + ") / 60 as VarChar(2))),4,2),':'),"
		cMod += "SUBSTR( Concat( '00', Cast(mod(CAST((" + cHora + "+" + cMinutos + ") AS NUMERIC) , 60) as VarChar(2))),4,2))%"
 	Else
		cMod := "%SUBSTR( Concat( '00', Cast((" + cHora + "+" + cMinutos + ") / 60 as VarChar(2))),4,2)"
		cMod += " || ':' || "
		cMod += "SUBSTR( Concat( '00', Cast(Mod((" + cHora + "+" + cMinutos + "), 60) as VarChar(2))),4,2)%"
	EndIf

Else

	//Calculo para horas
	cHora := "( Sum(datepart(hh,convert(varchar,ABR.ABR_TEMPO,108))) * 60 + "
	cHora += "Sum(datepart(mi,convert(varchar,ABR.ABR_TEMPO,108))) ) / 60"

	//Calculos para os minutos
	cMinutos := "( Sum(datepart(hh,convert(varchar,ABR.ABR_TEMPO,108))) * 60 + "
	cMinutos += "Sum(datepart(mi,convert(varchar,ABR.ABR_TEMPO,108))) ) % 60"

	//Horas formatadas
	cMod := "%Replicate('0', 2 - DataLength(LTrim(RTrim(Convert(Varchar, " + cHora + " ))))) + "
	cMod += "Convert(Varchar," + cHora + ") + ':' + "
 	cMod += "Replicate('0', 2 - DataLength(Ltrim(Rtrim(Convert(Varchar, " + cMinutos + "))))) + "
	cMod += "Convert(Varchar," + cMinutos + ")%"

EndIF

cIdcABQ := "%ABQ.ABQ_CONTRT" + cOperConc + "ABQ.ABQ_ITEM" + cOperConc + "ABQ.ABQ_ORIGEM%"

If lMedExt
	cWhereCob := "%TFF.TFF_COBCTR = '2' AND TFF.TFF_PRCVEN > 0%"
Else
 	cWhereCob := "%TFF.TFF_COBCTR <> '2' %"
EndIf

If lGsGerOS
	// Aba detalhes Recursos Humanos - Horas Normais
	BeginSql Alias cAliasQry

		SELECT AB9.AB9_NUMOS, AB9.AB9_SEQ, AB9.AB9_TOTFAT, AB6.AB6_EMISSA, AB9.AB9_DTCHEG,
				AB9.AB9_HRCHEG, AB9.AB9_DTSAID, AB9.AB9_HRSAID, TFF.TFF_CONTRT, TFF.TFF_CONREV,
				TFF.TFF_LOCAL, ABS.ABS_DESCRI, ABB.ABB_CODTEC, AA1.AA1_NOMTEC, ABQ.ABQ_TOTAL,
				TFF.TFF_PRCVEN, TFF.TFF_VALDES, TFF.TFF_QTDVEN
			FROM %table:ABB% ABB
				JOIN %table:AB9% AB9 ON AB9.AB9_FILIAL = %xFilial:AB9%
									AND AB9.AB9_ATAUT = ABB.ABB_CODIGO
									AND AB9.AB9_NUMOS = ABB.ABB_CHAVE
									AND AB9.AB9_ITAPUR = %Exp:cIdApur%
									AND AB9.%NotDel%
				JOIN %table:AB7% AB7 ON AB7.AB7_FILIAL = %xFilial:AB7%
									AND AB7.AB7_NUMOS %Exp:cOperador% AB7.AB7_ITEM = AB9.AB9_NUMOS
									AND AB7.%NotDel%
				JOIN %table:AB6% AB6 ON AB6.AB6_FILIAL = %xFilial:AB6%
									AND AB6.AB6_NUMOS = AB7.AB7_NUMOS
									AND AB6.%NotDel%
				JOIN %table:ABQ% ABQ ON ABQ.ABQ_FILIAL = %xFilial:ABQ%
									AND ABB.ABB_IDCFAL = %Exp:cIdcABQ%
									AND ABQ.%NotDel%
				JOIN %table:TFF% TFF ON TFF.TFF_FILIAL = %xFilial:TFF%
									AND TFF.TFF_FILIAL = ABQ.ABQ_FILTFF
									AND TFF.TFF_COD = ABQ.ABQ_CODTFF
									AND TFF.TFF_COD = %Exp:cCodTFF%
									AND %Exp:cWhereCob%
									AND TFF.%NotDel%
				JOIN %table:TFL% TFL ON TFL.TFL_FILIAL = %xFilial:TFL%
									AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
									AND TFL.TFL_CODIGO = %Exp:cCodTFL%
									AND TFL.TFL_CONTRT = %Exp:cContrato%
									AND TFL.TFL_CONREV = %Exp:cRevCtr%
									AND TFL.%NotDel%
				LEFT JOIN %table:ABS% ABS ON ABS.ABS_FILIAL = %xFilial:ABS%
										AND ABS.ABS_LOCAL = TFL.TFL_LOCAL
										AND ABS.%NotDel%
				LEFT JOIN %table:AA1% AA1 ON AA1.AA1_FILIAL = %xFilial:AA1%
										AND AA1.AA1_CODTEC = ABB.ABB_CODTEC
										AND AA1.%NotDel%
			WHERE ABB.ABB_FILIAL = %xFilial:ABB%
			AND ABB.ABB_CHEGOU = 'S'
			AND ABB.ABB_ATENDE = '1'
			AND ABB.ABB_DTINI >= %Exp:cDataIni%
			AND ABB.ABB_DTINI <= %Exp:cDataFim%
			AND ABB.ABB_DTFIM >= %Exp:cDataIni%
			AND ABB.ABB_DTFIM <= %Exp:cDataFim%
			AND ABQ.ABQ_CONTRT = %Exp:cContrato%
			AND ABB.%NotDel%
			GROUP BY AB9.AB9_NUMOS, AB9.AB9_SEQ, AB9.AB9_TOTFAT, AB6.AB6_EMISSA, AB9.AB9_DTCHEG,
					AB9.AB9_HRCHEG, AB9.AB9_DTSAID, AB9.AB9_HRSAID, TFF.TFF_CONTRT, TFF.TFF_CONREV,
					TFF.TFF_LOCAL, ABS.ABS_DESCRI, ABB.ABB_CODTEC, AA1.AA1_NOMTEC, ABQ.ABQ_TOTAL,
					TFF.TFF_PRCVEN, TFF.TFF_VALDES, TFF.TFF_QTDVEN
			ORDER BY ABB.ABB_CODTEC, AB9.AB9_DTCHEG,AB9.AB9_HRCHEG,AB9.AB9_DTSAID, AB9.AB9_HRSAID

	EndSql
Else
	// Aba detalhes Recursos Humanos - Horas Normais
	BeginSql Alias cAliasQry

		SELECT ABB.ABB_HRTOT, ABB.ABB_DTINI, ABB.ABB_HRINI, ABB.ABB_HRFIM, ABB.ABB_DTFIM, TFF.TFF_CONTRT, TFF.TFF_CONREV,
				TFF.TFF_LOCAL, ABS.ABS_DESCRI, ABB.ABB_CODTEC, AA1.AA1_NOMTEC, ABQ.ABQ_TOTAL,
				TFF.TFF_PRCVEN, TFF.TFF_VALDES, TFF.TFF_QTDVEN

			FROM %table:ABB% ABB
				JOIN %table:ABQ% ABQ ON ABQ.ABQ_FILIAL = %xFilial:ABQ%
									AND ABB.ABB_IDCFAL = %Exp:cIdcABQ%
									AND ABQ.%NotDel%
				JOIN %table:TFF% TFF ON TFF.TFF_FILIAL = %xFilial:TFF%
									AND TFF.TFF_FILIAL = ABQ.ABQ_FILTFF
									AND TFF.TFF_COD = ABQ.ABQ_CODTFF
									AND TFF.TFF_COD = %Exp:cCodTFF%
									AND %Exp:cWhereCob%
									AND TFF.%NotDel%
				JOIN %table:TFL% TFL ON TFL.TFL_FILIAL = %xFilial:TFL%
									AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
									AND TFL.TFL_CODIGO = %Exp:cCodTFL%
									AND TFL.TFL_CONTRT = %Exp:cContrato%
									AND TFL.TFL_CONREV = %Exp:cRevCtr%
									AND TFL.%NotDel%
				LEFT JOIN %table:ABS% ABS ON ABS.ABS_FILIAL = %xFilial:ABS%
										AND ABS.ABS_LOCAL = TFL.TFL_LOCAL
										AND ABS.%NotDel%
				LEFT JOIN %table:AA1% AA1 ON AA1.AA1_FILIAL = %xFilial:AA1%
										AND AA1.AA1_CODTEC = ABB.ABB_CODTEC
										AND AA1.%NotDel%
			WHERE ABB.ABB_FILIAL = %xFilial:ABB%
			AND ABB.ABB_CHEGOU = 'S'
			AND ABB.ABB_ATENDE = '1'
			AND ABB.ABB_DTINI >= %Exp:cDataIni%
			AND ABB.ABB_DTINI <= %Exp:cDataFim%
			AND ABB.ABB_DTFIM >= %Exp:cDataIni%
			AND ABB.ABB_DTFIM <= %Exp:cDataFim%
			AND ABQ.ABQ_CONTRT = %Exp:cContrato%
			AND ABB.ABB_ITAPUR = %Exp:cIdApur%
			AND ABB.%NotDel%
	EndSql
Endif

While (cAliasQry)->(!Eof())

	IF lTela
		If lGsGerOS
			aAdd( aHrNormal, { (cAliasQry)->AB9_NUMOS	 	 ,	(cAliasQry)->AB9_SEQ,;
								(cAliasQry)->AB9_TOTFAT		 ,	StoD((cAliasQry)->AB6_EMISSA),;
								StoD((cAliasQry)->AB9_DTCHEG),	(cAliasQry)->AB9_HRCHEG,;
								StoD((cAliasQry)->AB9_DTSAID),	(cAliasQry)->AB9_HRSAID,;
								(cAliasQry)->TFF_CONTRT		 ,	(cAliasQry)->TFF_CONREV,;
								(cAliasQry)->TFF_LOCAL		 ,	(cAliasQry)->ABS_DESCRI,;
								(cAliasQry)->ABB_CODTEC		 ,	(cAliasQry)->AA1_NOMTEC })
		Else
			aAdd( aHrNormal, { ""	 	 					 ,	"",;
								SubStr((cAliasQry)->ABB_HRTOT,6,10),	StoD(""),;
								StoD((cAliasQry)->ABB_DTINI),	(cAliasQry)->ABB_HRINI,;
								StoD((cAliasQry)->ABB_DTFIM),	(cAliasQry)->ABB_HRFIM,;
								(cAliasQry)->TFF_CONTRT		 ,	(cAliasQry)->TFF_CONREV,;
								(cAliasQry)->TFF_LOCAL		 ,	(cAliasQry)->ABS_DESCRI,;
								(cAliasQry)->ABB_CODTEC		 ,	(cAliasQry)->AA1_NOMTEC })
		Endif
	Else

		nVlrCont := ((cAliasQry)->TFF_PRCVEN - (cAliasQry)->TFF_VALDES) * (cAliasQry)->TFF_QTDVEN
		nVlrHor  := nVlrCont / (cAliasQry)->ABQ_TOTAL

		If lGsGerOS
			nHorTot  := HoraToInt((cAliasQry)->AB9_TOTFAT) * nVlrHor
		Else
			nHorTot  := Round(HoraToInt(SubStr((cAliasQry)->ABB_HRTOT,6,10)),2) * nVlrHor			
		Endif

		nPos := aScan( aTecHrN, {|x| x[1] == (cAliasQry)->ABB_CODTEC } )

		If nPos == 0

			If lGsGerOS
				aAdd( aTecHrN, { (cAliasQry)->ABB_CODTEC, nVlrHor, HoraToInt((cAliasQry)->AB9_TOTFAT), nHorTot } )
			Else
				aAdd( aTecHrN, { (cAliasQry)->ABB_CODTEC, nVlrHor, Round(HoraToInt(SubStr((cAliasQry)->ABB_HRTOT,6,10)),2), nHorTot } )
			Endif
		Else
			If lGsGerOS
				nTecHor := aTecHrN[nPos][3] + HoraToInt((cAliasQry)->AB9_TOTFAT)
			Else
				nTecHor := aTecHrN[nPos][3] + Round(HoraToInt(SubStr((cAliasQry)->ABB_HRTOT,6,10)),2)
			Endif

			nValTot := aTecHrN[nPos][4] + nHorTot

			aTecHrN[nPos][3] := nTecHor
			aTecHrN[nPos][4] := nValTot

		EndIf

	EndIf

	(cAliasQry)->(dbSkip())

EndDo

If lApuraHE
	cExprHE := "% AND ABR.ABR_DTINI >= '" + STOD(MV_PAR02) + "' AND ABR.ABR_DTFIM <= '" + STOD(MV_PAR03) + "' %"
Else
	cExprHE := "% AND ABR.ABR_DTINI >= '" + IIf(Valtype(cDataIni) == "D",DToS(cDataIni),cDataIni) + "' AND ABR.ABR_DTFIM <= '" + IIf(Valtype(cDataFim) == "D",DToS(cDataFim),cDataFim) + "' %"
EndIf

If lGsGerOS

	// Aba detalhes Recursos Humanos - Horas Extras
	BeginSql Alias cAliasABR

		SELECT AB9.AB9_NUMOS, AB9.AB9_SEQ, AB9.AB9_TOTFAT, AB6.AB6_EMISSA, AB9.AB9_DTCHEG,
				AB9.AB9_HRCHEG, AB9.AB9_DTSAID, AB9.AB9_HRSAID, TFF.TFF_CONTRT, TFF.TFF_CONREV,
				TFF.TFF_LOCAL, ABS.ABS_DESCRI, ABB.ABB_CODTEC, AA1.AA1_NOMTEC, ABQ.ABQ_TOTAL,
				TFF.TFF_PRCVEN, TFF.TFF_VALDES, TFF.TFF_QTDVEN, ABR.ABR_MOTIVO, ABN.ABN_DESC,
				TFU.TFU_CODIGO, TFU.TFU_VALOR, %Exp:cMod% TOT_HOR
		FROM %table:ABB% ABB
			JOIN %table:AB9% AB9 ON AB9.AB9_FILIAL = %xFilial:AB9%
								AND AB9.AB9_ATAUT = ABB.ABB_CODIGO
								AND AB9.AB9_NUMOS = ABB.ABB_CHAVE
								AND AB9.AB9_ITAPUR = %Exp:cIdApur%
								AND AB9.%NotDel%
			JOIN %table:AB7% AB7 ON AB7.AB7_FILIAL = %xFilial:AB7%
								AND AB7.AB7_NUMOS %Exp:cOperador% AB7.AB7_ITEM = AB9.AB9_NUMOS
								AND AB7.%NotDel%
			JOIN %table:AB6% AB6 ON AB6.AB6_FILIAL = %xFilial:AB6%
								AND AB6.AB6_NUMOS = AB7.AB7_NUMOS
								AND AB6.%NotDel%
			JOIN %table:ABQ% ABQ ON ABQ.ABQ_FILIAL = %xFilial:ABQ%
								AND ABB.ABB_IDCFAL = %Exp:cIdcABQ%
								AND ABQ.%NotDel%
			JOIN %table:TFF% TFF ON TFF.TFF_FILIAL = %xFilial:TFF%
								AND TFF.TFF_FILIAL = ABQ.ABQ_FILTFF
								AND TFF.TFF_COD = ABQ.ABQ_CODTFF
								AND TFF.TFF_COD = %Exp:cCodTFF%
								AND %Exp:cWhereCob%
								AND TFF.%NotDel%
			JOIN %table:TFL% TFL ON TFL.TFL_FILIAL = %xFilial:TFL%
								AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
								AND TFL.TFL_CODIGO = %Exp:cCodTFL%
								AND TFL.TFL_CONTRT = %Exp:cContrato%
								AND TFL.TFL_CONREV = %Exp:cRevCtr%
								AND TFL.%NotDel%
			JOIN %table:ABR% ABR ON ABR.ABR_FILIAL = %xFilial:ABR%
								AND ABR.ABR_AGENDA = ABB.ABB_CODIGO
								%Exp:cExprHE%
								AND ABR.%NotDel%
			JOIN %table:ABN% ABN ON ABN.ABN_FILIAL = %xFilial:ABN%
								AND ABN.ABN_CODIGO = ABR.ABR_MOTIVO
								AND ABN.ABN_TIPO = '04'
								AND ABN.%NotDel%
			LEFT JOIN %table:TFU% TFU ON TFU.TFU_FILIAL = %xFilial:TFU%
									AND TFU.TFU_CODTFF = TFF.TFF_COD
									AND TFU.TFU_CODABN = ABR.ABR_MOTIVO
									AND TFU.%NotDel%
			LEFT JOIN %table:ABS% ABS ON ABS.ABS_FILIAL = %xFilial:ABS%
									AND ABS.ABS_LOCAL = TFL.TFL_LOCAL
									AND ABS.%NotDel%
			LEFT JOIN %table:AA1% AA1 ON AA1.AA1_FILIAL = %xFilial:AA1%
									AND AA1.AA1_CODTEC = ABB.ABB_CODTEC
									AND AA1.%NotDel%
		WHERE ABB.ABB_FILIAL = %xFilial:ABB%
			AND ABB.ABB_CHEGOU = 'S'
			AND ABB.ABB_ATENDE = '1'
			AND ABB.ABB_DTINI >= %Exp:cDataIni%
			AND ABB.ABB_DTINI <= %Exp:cDataFim%
			AND ABB.ABB_DTFIM >= %Exp:cDataIni%
			AND ABB.ABB_DTFIM <= %Exp:cDataFim%
			AND ABQ.ABQ_CONTRT = %Exp:cContrato%
			AND ABB.%NotDel%
		GROUP BY AB9.AB9_NUMOS, AB9.AB9_SEQ, AB9.AB9_TOTFAT, AB6.AB6_EMISSA, AB9.AB9_DTCHEG,
				AB9.AB9_HRCHEG, AB9.AB9_DTSAID, AB9.AB9_HRSAID, TFF.TFF_CONTRT, TFF.TFF_CONREV,
				TFF.TFF_LOCAL, ABS.ABS_DESCRI, ABB.ABB_CODTEC, AA1.AA1_NOMTEC, ABQ.ABQ_TOTAL,
				TFF.TFF_PRCVEN, TFF.TFF_VALDES, TFF.TFF_QTDVEN, ABR.ABR_MOTIVO, ABN.ABN_DESC,
				TFU.TFU_CODIGO, TFU.TFU_VALOR
		ORDER BY ABB.ABB_CODTEC, AB9.AB9_DTCHEG,AB9.AB9_HRCHEG,AB9.AB9_DTSAID, AB9.AB9_HRSAID
	EndSql
Else
	// Aba detalhes Recursos Humanos - Horas Extras
	BeginSql Alias cAliasABR

		SELECT ABB.ABB_HRTOT, ABB.ABB_DTINI, ABB.ABB_HRINI, ABB.ABB_DTFIM, ABB.ABB_HRFIM, TFF.TFF_CONTRT, TFF.TFF_CONREV,
				TFF.TFF_LOCAL, ABS.ABS_DESCRI, ABB.ABB_CODTEC, AA1.AA1_NOMTEC, ABQ.ABQ_TOTAL,
				TFF.TFF_PRCVEN, TFF.TFF_VALDES, TFF.TFF_QTDVEN, ABR.ABR_MOTIVO, ABN.ABN_DESC,
				TFU.TFU_CODIGO, TFU.TFU_VALOR, %Exp:cMod% TOT_HOR
		FROM %table:ABB% ABB
			JOIN %table:ABQ% ABQ ON ABQ.ABQ_FILIAL = %xFilial:ABQ%
								AND ABB.ABB_IDCFAL = %Exp:cIdcABQ%
								AND ABQ.%NotDel%
			JOIN %table:TFF% TFF ON TFF.TFF_FILIAL = %xFilial:TFF%
								AND TFF.TFF_FILIAL = ABQ.ABQ_FILTFF
								AND TFF.TFF_COD = ABQ.ABQ_CODTFF
								AND TFF.TFF_COD = %Exp:cCodTFF%
								AND %Exp:cWhereCob%
								AND TFF.%NotDel%
			JOIN %table:TFL% TFL ON TFL.TFL_FILIAL = %xFilial:TFL%
								AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
								AND TFL.TFL_CODIGO = %Exp:cCodTFL%
								AND TFL.TFL_CONTRT = %Exp:cContrato%
								AND TFL.TFL_CONREV = %Exp:cRevCtr%
								AND TFL.%NotDel%
			JOIN %table:ABR% ABR ON ABR.ABR_FILIAL = %xFilial:ABR%
								AND ABR.ABR_AGENDA = ABB.ABB_CODIGO
								%Exp:cExprHE%
								AND ABR.%NotDel%
			JOIN %table:ABN% ABN ON ABN.ABN_FILIAL = %xFilial:ABN%
								AND ABN.ABN_CODIGO = ABR.ABR_MOTIVO
								AND ABN.ABN_TIPO = '04'
								AND ABN.%NotDel%
			LEFT JOIN %table:TFU% TFU ON TFU.TFU_FILIAL = %xFilial:TFU%
									AND TFU.TFU_CODTFF = TFF.TFF_COD
									AND TFU.TFU_CODABN = ABR.ABR_MOTIVO
									AND TFU.%NotDel%
			LEFT JOIN %table:ABS% ABS ON ABS.ABS_FILIAL = %xFilial:ABS%
									AND ABS.ABS_LOCAL = TFL.TFL_LOCAL
									AND ABS.%NotDel%
			LEFT JOIN %table:AA1% AA1 ON AA1.AA1_FILIAL = %xFilial:AA1%
									AND AA1.AA1_CODTEC = ABB.ABB_CODTEC
									AND AA1.%NotDel%
		WHERE ABB.ABB_FILIAL = %xFilial:ABB%
			AND ABB.ABB_CHEGOU = 'S'
			AND ABB.ABB_ATENDE = '1'
			AND ABB.ABB_DTINI >= %Exp:cDataIni%
			AND ABB.ABB_DTINI <= %Exp:cDataFim%
			AND ABB.ABB_DTFIM >= %Exp:cDataIni%
			AND ABB.ABB_DTFIM <= %Exp:cDataFim%
			AND ABQ.ABQ_CONTRT = %Exp:cContrato%
			AND ABB.ABB_ITAPUR = %Exp:cIdApur%
			AND ABB.%NotDel%
		GROUP BY ABB.ABB_HRTOT, ABB.ABB_DTINI, ABB.ABB_HRINI, ABB.ABB_DTFIM, ABB.ABB_HRFIM, TFF.TFF_CONTRT, TFF.TFF_CONREV,
				TFF.TFF_LOCAL, ABS.ABS_DESCRI, ABB.ABB_CODTEC, AA1.AA1_NOMTEC, ABQ.ABQ_TOTAL,
				TFF.TFF_PRCVEN, TFF.TFF_VALDES, TFF.TFF_QTDVEN, ABR.ABR_MOTIVO, ABN.ABN_DESC,
				TFU.TFU_CODIGO, TFU.TFU_VALOR
		ORDER BY ABB.ABB_CODTEC, ABB.ABB_DTINI, ABB.ABB_HRINI, ABB.ABB_DTFIM, ABB.ABB_HRFIM
	EndSql
Endif

While (cAliasABR)->(!Eof())

	If Len(Alltrim((cAliasABR)->TFU_CODIGO)) > 0 // Campos de hora extra
		nVlrHor  := (cAliasABR)->TFU_VALOR
		nHorTot  := HoraToInt((cAliasABR)->TOT_HOR) * nVlrHor
	Else
		nVlrCont := ((cAliasABR)->TFF_PRCVEN - (cAliasABR)->TFF_VALDES) * (cAliasABR)->TFF_QTDVEN
		nVlrHor  := nVlrCont / (cAliasABR)->ABQ_TOTAL
		nHorTot  := HoraToInt((cAliasABR)->TOT_HOR) * nVlrHor
	EndIf

	IF lTela
		If lGsGerOS
			aAdd( aHrOsE, { (cAliasABR)->AB9_NUMOS		,	(cAliasABR)->AB9_SEQ,;
							(cAliasABR)->ABR_MOTIVO	    ,  (cAliasABR)->ABN_DESC,;
							AllTrim((cAliasABR)->TOT_HOR),	StoD((cAliasABR)->AB6_EMISSA),;
							StoD((cAliasABR)->AB9_DTCHEG),	(cAliasABR)->AB9_HRCHEG,  ;
							StoD((cAliasABR)->AB9_DTSAID),	(cAliasABR)->AB9_HRSAID,;
							(cAliasABR)->TFF_CONTRT		,	(cAliasABR)->TFF_CONREV,;
							(cAliasABR)->TFF_LOCAL		,	(cAliasABR)->ABS_DESCRI,;
							(cAliasABR)->ABB_CODTEC		,	(cAliasABR)->AA1_NOMTEC })
		Else
			aAdd( aHrOsE, { ""		,	"",;
							(cAliasABR)->ABR_MOTIVO	    ,  (cAliasABR)->ABN_DESC,;
							AllTrim((cAliasABR)->TOT_HOR),	StoD(""),;
							StoD((cAliasABR)->ABB_DTINI),	(cAliasABR)->ABB_HRINI,;
							StoD((cAliasABR)->ABB_DTFIM),	(cAliasABR)->ABB_HRFIM,;
							(cAliasABR)->TFF_CONTRT		,	(cAliasABR)->TFF_CONREV,;
							(cAliasABR)->TFF_LOCAL		,	(cAliasABR)->ABS_DESCRI,;
							(cAliasABR)->ABB_CODTEC		,	(cAliasABR)->AA1_NOMTEC })

		Endif
		nPos := aScan( aHrExtra, {|x| x[1]== (cAliasABR)->ABR_MOTIVO } )

		If nPos > 0

			nHreTot := HoraToInt(aHrExtra[nPos][3]) + HoraToInt((cAliasABR)->TOT_HOR)
			nVlrTot := aHrExtra[nPos][5] + nHorTot

			aHrExtra[nPos][3] := AllTrim(IntToHora(nHreTot))
			aHrExtra[nPos][5] := Round(nVlrTot,2)

		Else
			aAdd(aHrExtra, {(cAliasABR)->ABR_MOTIVO, (cAliasABR)->ABN_DESC,;
				 			 AllTrim((cAliasABR)->TOT_HOR), Round(nVlrHor,2), Round(nHorTot,2) })
		EndIf

	Else

		nPos := aScan( aTecHrE, {|x| x[1] == (cAliasABR)->ABB_CODTEC .And. x[5] == (cAliasABR)->ABR_MOTIVO } )

		If nPos == 0

			aAdd( aTecHrE, { (cAliasABR)->ABB_CODTEC,;
								nVlrHor,;
								HoraToInt((cAliasABR)->TOT_HOR),;
								nHorTot,;
								(cAliasABR)->ABR_MOTIVO } )

		Else

			nTecHor := aTecHrE[nPos][3] + HoraToInt((cAliasABR)->TOT_HOR)
			nValTot := aTecHrE[nPos][4] + nHorTot

			aTecHrE[nPos][3] := nTecHor
			aTecHrE[nPos][4] := nValTot

		EndIf

		nPos := aScan( aTecHrN, {|x| x[1] == (cAliasABR)->ABB_CODTEC } )

		If nPos > 0

			nTecHor := aTecHrN[nPos][3] - HoraToInt((cAliasABR)->TOT_HOR)
			nValTot := aTecHrN[nPos][2] * nTecHor

			aTecHrN[nPos][3] := nTecHor
			aTecHrN[nPos][4] := nValTot

		EndIf

	Endif

	(cAliasABR)->(dbSkip())

EndDo

(cAliasQry)->(DbCloseArea())
(cAliasABR)->(DbCloseArea())

IF lTela
	aAdd( aRet, { aHrNormal, aHrOsE, aHrExtra } )
Else
	aAdd( aRet, { aTecHrN, aTecHrE } )
Endif

Return(aRet)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At930QDetLE()
Gera as informações do detalhes da Locação de Equipamentos para os equipamentos.
@param 		ExpC:Contrato a ser utilzado no detalhe
@param 		ExpC:Data Inicial da apuração/medição
@param 		ExpC:Data Final da apuração/medição
@param 		ExpC:Codigo do recurso humano a ser utilizado no detalhe
@param 		ExpC:Codigo do local a ser utilizado no detalhe
@param 		ExpC:Codigo da apuração para a pesquisa no estorno
@param 		ExpL:Para identificar se vai ser retornado dados para a tela ou processamento
@author 	Serviços
@since  	13/02/2014
@version	P12
@return 	ExpA: Array com os dados do detalhe do RH
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At930QDetLE(cCodTFI)

Local cAliasTEW := GetNextAlias()
Local cDtInTFV  := FwFldGet("TFV_DTINI")
Local cDtFiTFV  := FwFldGet("TFV_DTFIM")
Local dDataFim
Local dDataIni
Local aRet		  := {}
Local nDifDias  := 0
Local nPosEq	  := 0
Local nTotDias  := 0
Local nLE		  := 0

BeginSql Alias cAliasTEW

	SELECT TEW_MOTIVO, TEW_CODMV, TEW_BAATD, TEW_PRODUT, TEW_DTRINI, TEW_DTRFIM, TEW_DTAMNT, TEW_SUBSTI
	  FROM %table:TEW% TEW
	 WHERE TEW_FILIAL = %xFilial:TEW%
	   AND TEW_CODEQU = %Exp:cCodTFI%
	   AND (
	         ( TEW.TEW_DTRINI BETWEEN %Exp:cDtInTFV% AND %Exp:cDtFiTFV% )
	         OR
	         (     TEW.TEW_MOTIVO <> ' '
	           AND TEW.TEW_DTAMNT <> ' '
	           AND TEW.TEW_DTAMNT BETWEEN %Exp:cDtInTFV% AND %Exp:cDtFiTFV% )
	         OR
	         (     TEW.TEW_MOTIVO = ' '
	           AND TEW.TEW_DTRFIM <> ' '
	           AND TEW.TEW_DTAMNT = ' '
	           AND TEW.TEW_DTRFIM BETWEEN %Exp:cDtInTFV% AND %Exp:cDtFiTFV% )
	         OR
	         (     TEW.TEW_DTRINI < %Exp:cDtInTFV%
	           AND
	               (
	                 ( TEW.TEW_MOTIVO <> ' ' AND ( TEW.TEW_DTAMNT = ' ' OR TEW.TEW_DTAMNT > %Exp:cDtFiTFV% ) )
	                 OR
	                 ( TEW.TEW_MOTIVO = ' ' AND ( TEW.TEW_DTRFIM = ' ' OR TEW.TEW_DTRFIM > %Exp:cDtFiTFV% ) )
	               )
	         )
	       )
	   AND TEW.%NotDel%

EndSql

While (cAliasTEW)->(!EoF())

	//No fim usa sempre a menor data
	If Len(AllTrim((cAliasTEW)->TEW_DTAMNT)) > 0
		If cDtFiTFV < StoD((cAliasTEW)->TEW_DTAMNT)
			dDataFim := cDtFiTFV
		Else
			dDataFim := (cAliasTEW)->TEW_DTAMNT
		EndIf
	ElseIf Len(AllTrim((cAliasTEW)->TEW_DTRFIM)) > 0
		If cDtFiTFV < StoD((cAliasTEW)->TEW_DTRFIM)
			dDataFim := cDtFiTFV
		Else
			dDataFim := (cAliasTEW)->TEW_DTRFIM
		EndIf
	Else
		dDataFim := cDtFiTFV
	EndIf

	If valType(dDataFim) == "C"
		dDataFim := StoD(dDataFim)
	EndIf

	//No inicio usa sempre a maior data
	If Len(AllTrim((cAliasTEW)->TEW_DTRINI)) > 0
		If cDtInTFV > StoD((cAliasTEW)->TEW_DTRINI)
			dDataIni := cDtInTFV
		Else
			dDataIni := (cAliasTEW)->TEW_DTRINI
		EndIf
	Else
		dDataIni := cDtInTFV
	EndIf

	If valType(dDataIni) == "C"
		dDataIni := StoD(dDataIni)
	EndIf

	nDifDias := (dDataFim - dDataIni) + 1

	nPosEq := aScan( aRet, { |x| x[1] == (cAliasTEW)->TEW_BAATD } )

	If nPosEq == 0
		aAdd( aRet, { (cAliasTEW)->TEW_BAATD, nDifDias, "2", 0, 0, 0, 0 } )
	Else
		aRet[nPosEq][2] += nDifDias
	EndIf

	nTotDias += nDifDias

	(cAliasTEW)->(dbSkip())

EndDo

(cAliasTEW)->( DbCloseArea() )

For nLE:=1 To Len(aRet)
	aRet[nLE][7] := aRet[nLE][2] / nTotDias  // Percentual do item equivalente a locação
Next

Return(aRet)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  AT930VldCt()
Valida se o contrato está com medição automatica
@param ExpO:Modelo de Dados da Tela de cadastro
@return ExpL: Retorna .T. quando não estiver com medição automatica
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT930VldCt(oModel)

Local aArea				:= GetArea()
Local lRet				:= .T.
Local cTpCont			:= ""
Local cContrato			:= MV_PAR01
Local lFatAntecip 		:= (TFV->TFV_ANTECI == "1")
Local lRotFatAnteci 	:= ( IsInCallStack( "TECA934" ) )
Local lApuAgil			:= oModel:GetId() == "TECA930A"

If oModel:GetOperation() != MODEL_OPERATION_DELETE
	DbSelectArea("CN9")
	DbSetOrder(1) // CN9_FILIAL + CN9_NUMERO

	DbSelectArea("CN1")
	DbSetOrder(1)  // CN1_FILIAL + CN1_CODIGO

	If lApuAgil
		MV_PAR01 := oModel:GetValue("CNTMASTER","CNT_NUMERO")
		cContrato := MV_PAR01
	Else
		If oModel:GetOperation() == MODEL_OPERATION_VIEW
			MV_PAR01 := TFV->TFV_CONTRT
		EndIf
	EndIF
EndIf

// Valida quando é orçamento de faturamento antecipado
If lRet .And. !lRotFatAnteci
	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		If lFatAntecip
			Help(,,'AT930ANTECIEST',, STR0127,1,0,,,,,,; // "Apuração de faturamento antecipado não pode ser estornada por esta rotina."
						{ STR0128 } ) // "Estorne pela rotina de faturamento antecipado."
			lRet := .F.
		EndIf
	ElseIf oModel:GetOperation() == MODEL_OPERATION_INSERT
		lFatAntecip := At934IsFAnt( cContrato )
		If lFatAntecip
			Help(,,'AT930ANTECIINC',, STR0146,1,0,,,,,,; // "Apuração de faturamento antecipado não pode ser incluída por esta rotina."
						{ STR0147 } ) // "Inclua pela rotina de faturamento antecipado."
			lRet := .F.
		EndIf
	EndIf
EndIf


If !lApuAgil .AND. oModel:GetOperation() == MODEL_OPERATION_VIEW
	MV_PAR01 := cContrato
EndIf

RestArea(aArea)

Return lRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  AT930Tes()
Retorna a TES do orçamento de serviços para a geração do pedido
@param ExpC:Tipo da TES a ser retornada
@param ExpC:Codigo do recurso a ser pesquisado
@author 	Serviços
@since  	25/04/2014
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AT930Tes( cTipo, cCodTFF, cCodTFL, cCodMat, lMdExt )

Local cRet      := ""
Local aArea	  := GetArea()
Local cAliasTES := GetNextAlias()
Local lDesagr	:= SuperGetMv("MV_GSDSGCN",,"2") == "1"

Default cCodTFF := ""
Default cCodTFL := ""
Default cCodMat := ""
Default lMdExt := IIF(ValType(lMedExt)=="L", lMedExt, .F.)

If ValType(lMdExt) == 'L' .AND. lMdExt .AND. lDesagr
	If !EMPTY(cCodMat) .AND. cTipo $ "TFG|TFH"
		cRet := Posicione(cTipo,1,xFilial(cTipo)+cCodMat,(cTipo+"_TESPED"))
	ElseIf cTipo == "TFF" .AND. !EMPTY(cCodTFF)
		cRet := Posicione(cTipo,1,xFilial(cTipo)+cCodTFF,(cTipo+"_TESPED"))
	EndIf
Else
	If !Empty(cCodTFF)
		BeginSql Alias cAliasTES
	
			SELECT TFJ.TFJ_TES, TFJ.TFJ_TESMI, TFJ.TFJ_TESMC
			  FROM %table:TFF% TFF
			       JOIN %table:TFL% TFL ON TFL.TFL_FILIAL = %xFilial:TFL%
			                           AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
			                           AND TFL.%NotDel%
			       JOIN %table:TFJ% TFJ ON TFJ.TFJ_FILIAL = %xFilial:TFJ%
			                           AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI
			                           AND TFJ.%NotDel%
			 WHERE TFF.TFF_FILIAL = %xFilial:TFF%
			   AND TFF.TFF_COD = %Exp:cCodTFF%
			   AND TFF.%NotDel%
	
		EndSql
	Else
		BeginSql Alias cAliasTES
	
			SELECT TFJ.TFJ_TES, TFJ.TFJ_TESMI, TFJ.TFJ_TESMC
			  FROM %Table:TFL% TFL
			       JOIN %Table:TFJ% TFJ ON TFJ_FILIAL = %xFilial:TFJ%
			                           AND TFJ.%NotDel%
			                           AND TFJ_CODIGO = TFL_CODPAI
			 WHERE TFL.%NotDel%
			   AND TFL_CODIGO = %Exp:cCodTFL%
	
		EndSql
	EndIf
	
	If cTipo = "TFF"
		cRet := (cAliasTES)->TFJ_TES
	ElseIf cTipo = "TFG"
		cRet := (cAliasTES)->TFJ_TESMI
	ElseIf cTipo = "TFH"
		cRet := (cAliasTES)->TFJ_TESMC
	EndIf
	
	(cAliasTES)->( DbCloseArea() )
EndIf

RestArea(aArea)

Return(cRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At930HePar()
	Valida a seleção do tipo de geração das horas extras
@author 	Serviços
@since  	04/09/2014
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930HePar()

Return .T.

//==============================================================================================================
/*/{Protheus.doc}  AT930AtuTot(oModelGrid, nLine, cAction, cField, xValue, xOldValue)
Atualiza totalizadores de multas, bonificações e descontos, baseado no campo que está sendo modificado.
@return 	lRet
@author 	israel.escorizza
@since  	04/02/2015
@version	V12.1.6
/*/
//==============================================================================================================

Function AT930AtuTot(oModelGrid, nLine, cAction, cField, xValue, xOldValue)
Local oModel	:= oModelGrid:GetModel()		//- Modelo ativo
Local oModelG	:= NIL							//- Modelo que será utilizano no totalizador

Local cModelG	:= oModelGrid:GetId()		//- Id da Grid-pai utilizada.
Local cVlrFld := ""							//- Campo que contem o valor que será atualizado (TW6_VALOR | TW7_VALOR)

Local nVlrFld	:= 0							//- Valor numérico do campo (TW6_VALOR | TW7_VALOR)
Local nVlrTot := 0							//- Valor total do somatório que será aplicado no aCampos
Local nModo	:= 1							//- Define se é uma multa ou bonificação (TW7_TPMUL)

Local aCampos 	:= {}							//- Array para armazenamento dos campos que serão utilizados
Local aSaveLines	:= FWSaveRows()

Local lOS			:= .F.
Local lRet 		:= .T.

Default cField := ""
Default cAction := ""

If cAction $ "CANSETVALUE|SETVALUE|DELETE|UNDELETE"
	DO	CASE
		CASE cModelG == "TFWTW6DETAIL"
			oModelG := oModel:GetModel("TFWDETAIL")
			aAdd(aCampos,"TFW_TOTDES")

		CASE cModelG == "TFXTW6DETAIL"
			oModelG := oModel:GetModel("TFXDETAIL")
			aAdd(aCampos,"TFX_TOTDES")

		CASE cModelG == "TFYTW6DETAIL"
			oModelG := oModel:GetModel("TFYDETAIL")
			aAdd(aCampos,"TFY_TOTDES")

		CASE cModelG == "TFITW6DETAIL"
			oModelG := oModel:GetModel("TFIPRODUT")
			aAdd(aCampos,"TFI_TOTDES")

			If (TW6->( ColumnPos('TW6_OS')) > 0 )
				lOS	:= oModelGrid:GetValue("TW6_OS")
			Else
				lOS := .F.
			EndIf

		CASE cModelG == "TFWTW7DETAIL"
			oModelG := oModel:GetModel("TFWDETAIL")
			aAdd(aCampos,"TFW_TOTMUL")
			aAdd(aCampos,"TFW_TOTBON")

		CASE cModelG == "TFXTW7DETAIL"
			oModelG := oModel:GetModel("TFXDETAIL")
			aAdd(aCampos,"TFX_TOTMUL")
			aAdd(aCampos,"TFX_TOTBON")

		CASE cModelG == "TFYTW7DETAIL"
			oModelG := oModel:GetModel("TFYDETAIL")
			aAdd(aCampos,"TFY_TOTMUL")
			aAdd(aCampos,"TFY_TOTBON")

		CASE cModelG == "TFITW7DETAIL"
			oModelG := oModel:GetModel("TFIPRODUT")
			aAdd(aCampos,"TFI_TOTMUL")
			aAdd(aCampos,"TFI_TOTBON")
	ENDCASE

	cVlrFld := IIf (SUBSTR(cModelG,4,3)== "TW6", "TW6_VALOR","TW7_VALOR")
	nVlrFld := oModelGrid:GetValue(cVlrFld)
	nVlrTot := oModelG:GetValue(aCampos[1])

	DO CASE
		CASE cAction == 'CANSETVALUE'
			If lOS
				Help(" ",1,"A930ALTOS") //- "Não é possivel alterar valor de desconto vinculado a uma OS."
				lRet := .F.
			EndIf

		CASE cAction == 'SETVALUE' .And. cField $ "TW6_VALOR|TW7_VALOR|TW7_TPMOV" .And. xOldValue != xValue
			If cField == "TW7_TPMOV"
				oModelG:SetValue(aCampos[1],nVlrTot + (nVlrFld * IIf(xValue=="1",1,-1)))
				nVlrTot := oModelG:GetValue(aCampos[2])
				oModelG:SetValue(aCampos[2],nVlrTot - (nVlrFld * IIf(xValue=="1",1,-1)))
			Else
				If cField == "TW7_VALOR"
					nModo := Iif(oModelGrid:GetValue("TW7_TPMOV") == "1",1,2)
				EndIf
				nVlrTot := oModelG:GetValue(aCampos[nModo])
				oModelG:SetValue(aCampos[nModo],nVlrTot + (xValue - xOldValue))
			EndIf

		CASE cAction == 'DELETE'
			If cVlrFld == "TW6_VALOR" //- Desconto
				If lOS
					Help(" ",1,"A930DELOS") //- "Não é possivel excluir um desconto vinculado a uma OS. O desconto será desconsiderado caso a OS não esteja selecionada!"
					lRet := .F.
				Else
					oModelG:SetValue(aCampos[1], nVlrTot - nVlrFld)
				EndIf
			Else
				nModo := Iif(oModelGrid:GetValue("TW7_TPMOV") == "1",1,2)
				nVlrTot := oModelG:GetValue(aCampos[nModo])
				oModelG:SetValue(aCampos[nModo], nVlrTot - nVlrFld)
			EndIf
		CASE cAction == 'UNDELETE'
			If cVlrFld == "TW6_VALOR" //- Desconto
				oModelG:SetValue(aCampos[1], nVlrTot + nVlrFld)
			Else
				nModo := Iif(oModelGrid:GetValue("TW7_TPMOV") == "1",1,2)
				nVlrTot := oModelG:GetValue(aCampos[nModo])
				oModelG:SetValue(aCampos[nModo], nVlrTot + nVlrFld)
			EndIf
	ENDCASE
EndIf

FWRestRows(aSaveLines)

Return lRet

//==============================================================================================================
/*/{Protheus.doc}  AT930TfiMul()
Carga de visualização do campo virtual de Multas e Bonificações da tabela TFI
@Return
@author 	israel.escorizza
@since  	04/02/2015
@version	V12.1.6
/*/
//==============================================================================================================
Function AT930TfiMul()
Local oModel 	  := FwModelActive()
Local oModelTFI := oModel:GetModel("TFIDETAIL")
Local oModelTW7 := oModel:GetModel("TFITW7DETAIL")

Local nTotMul 	:= 0
Local nTotBon		:= 0
Local nX			:= 1
Local nY			:= 1
Local aSaveLines	:= FWSaveRows()

For nX := 1 To oModelTFI:Length()
	nTotMul := 0
	nTotBon := 0
	oModelTFI:GoLine(nX)
	For nY := 1 To oModelTW7:Length()
		oModelTW7:GoLine(nY)
		If(oModelTW7:GetValue("TW7_TPMOV") == "1")
			nTotMul += oModelTW7:GetValue("TW7_VALOR")
		Else
			nTotBon += oModelTW7:GetValue("TW7_VALOR")
		EndIf
	Next nY
	oModelTFI:SetValue("TFI_TOTMUL",nTotMul)
	oModelTFI:SetValue("TFI_TOTBON",nTotBon)
Next nX

FWRestRows(aSaveLines)

Return
//==============================================================================================================
/*/{Protheus.doc}  AT930TfiDes()
Carga de visualização do campo virtual de Descontos da tabela TFI
@Return
@author 	israel.escorizza
@since  	04/02/2015
@version	V12.1.6
/*/
//==============================================================================================================
Function AT930TfiDes()
Local oModel 	  := FwModelActive()
Local oModelTFI := oModel:GetModel("TFIDETAIL")
Local oModelTW6 := oModel:GetModel("TFITW6DETAIL")

Local nTot 	:= 0
Local nX		:= 0
Local nY		:= 0
Local aSaveLines	:= FWSaveRows()

For nX := 1 To oModelTFI:Length()
	nTot := 0
	oModelTFI:GoLine(nX)
	For nY := 1 To oModelTW6:Length()
		oModelTW6:GoLine(nY)
		nTot += oModelTW6:GetValue("TW6_VALOR")
	Next nY
	oModelTFI:SetValue("TFI_TOTDES",nTot)
Next nX

FWRestRows(aSaveLines)

Return

//==============================================================================================================
/*/{Protheus.doc}  At930LoOs(oModel)
Load das informações das ordens de Serviço
@Return
@author 	filipe.goncalves
@since  	17/02/2016
@version	V12.1.12
/*/
//==============================================================================================================
Static Function At930LoOs(oModel, aEquip)
Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oModelOs	:= oModel:GetModel("TW8DETAIL")
Local cAliasSTJ	:= GetNextAlias()
Local cProd		:= oModel:GetValue("TFIPRODUT", "TFI_COD")
Local cCodbem		:= ""
Local dDtIni
Local dDtFim
Local lRet			:= .T.
Local nX			:= 0

For nX := 1 to Len(aEquip)

	If cProd == aEquip[nx][1]

		dDtIni := aEquip[nx][4]
		dDtFim := If(Empty(aEquip[nx][5]), MV_PAR03, aEquip[nx][5])

		BeginSql Alias cAliasSTJ
			SELECT STJ.TJ_ORDEM, AA3.AA3_CODBEM, STJ.TJ_PLANO, STJ.TJ_DTMRINI, STJ.TJ_HOMRINI, STJ.TJ_DTMRFIM, STJ.TJ_HOMRFIM,
			       SUM(STJ.TJ_CUSTMDO + STJ.TJ_CUSTMAT + STJ.TJ_CUSTMAA + STJ.TJ_CUSTMAS + STJ.TJ_CUSTTER) TJ_CUSTO
			  FROM %table:TFI% TFI
			       INNER JOIN %table:TEW% TEW ON TEW.TEW_FILIAL = %xFilial:TEW%
			                                 AND TEW.%NotDel%
			                                 AND TEW.TEW_CODEQU = TFI.TFI_COD
			       INNER JOIN %table:AA3% AA3 ON AA3.AA3_FILIAL = %xFilial:AA3%
			                                 AND AA3.%NotDel%
			                                 AND AA3.AA3_NUMSER = TEW.TEW_BAATD
			       INNER JOIN %table:STJ% STJ ON STJ.TJ_FILIAL = AA3.AA3_CDBMFL
			                                 AND STJ.%NotDel%
			                                 AND STJ.TJ_CODBEM = AA3.AA3_CODBEM
			 WHERE TFI.TFI_FILIAL = %xFilial:TFI%
			   AND TFI.%NotDel%
			   AND TFI.TFI_COD = %Exp:aEquip[nx][1]%
 			   AND (STJ.TJ_DTMRINI >= %Exp:dDtIni% AND STJ.TJ_DTMRFIM <= %Exp:dDtFim%)
 			 GROUP BY STJ.TJ_ORDEM, AA3.AA3_CODBEM, STJ.TJ_PLANO, STJ.TJ_DTMRINI, STJ.TJ_HOMRINI, STJ.TJ_DTMRFIM, STJ.TJ_HOMRFIM
		EndSql

		While (cAliasSTJ)->(! Eof())
			If !(Empty(oModelOs:GetValue('TW8_ORDEM')))
				oModelOs:SetNoInsertLine(.F.)
				oModelOs:AddLine()
				oModelOs:SetNoInsertLine(.T.)
			EndIf

			oModelOs:SetValue('TW8_ORDEM',  (cAliasSTJ)->TJ_ORDEM)
			oModelOs:SetValue('TW8_CODBEM', (cAliasSTJ)->AA3_CODBEM)
			oModelOs:SetValue('TW8_PLANO',  (cAliasSTJ)->TJ_PLANO)
			oModelOs:SetValue('TW8_DTMRIN', StoD((cAliasSTJ)->TJ_DTMRINI))
			oModelOs:SetValue('TW8_HOMINI', (cAliasSTJ)->TJ_HOMRINI)
			oModelOs:SetValue('TW8_DTMFIM', StoD((cAliasSTJ)->TJ_DTMRFIM))
			oModelOs:SetValue('TW8_HOMFIM', (cAliasSTJ)->TJ_HOMRFIM)
			oModelOs:SetValue('TW8_CODTFI', cProd)
			oModelOs:SetValue('TW8_NUMSER', aEquip[nx][3])
			oModelOs:SetValue('TW8_CUSTOT', (cAliasSTJ)->TJ_CUSTO)

			(cAliasSTJ)->(dbSkip())
		EndDo

		(cAliasSTJ)->( DbCloseArea() )
	EndIf

Next nX

RestArea(aArea)
FWRestRows( aSaveLines )
Return lRet

//==============================================================================================================
/*/{Protheus.doc}  At930VldOs()
Valid do campo TW8_OK
@Return 	lRet
@author 	filipe.goncalves
@since  	18/02/2016
@version	V12.1.12
/*/
//==============================================================================================================
Static Function At930VldOs()

Local aSave	:= FWSaveRows()
Local oModel	:= FwModelActive()
Local oView	:= FwViewActive()
Local oModTW6	:= oModel:GetModel('TFITW6DETAIL')
Local nCusto	:= oModel:GetValue('TW8DETAIL','TW8_CUSTOT')
Local cTpDesc	:= CN130DesPV()
Local lRet 	:= .T.

If Empty(oModel:GetValue('TW8DETAIL','TW8_ORDEM'))
	lRet := .F.
ElseIf	Empty(cTpDesc)
	Help(,,"AT930NOREG",,STR0106,1,0)	//"Faça a inclusão de um tipo de desconto para que possa marcar uma OS!"
	lRet := .F.
EndIf

If	lRet
	If	oModel:GetValue("TW8DETAIL", "TW8_OK")

		// Marcando a O.S.
		If	!( oModTW6:SeekLine({{"TW6_TPDESC", cTpDesc}}) )
			// Se não encontrar a linha totalizadora dos descontos conforme o tipo de desconto, adiciona a linha da grid de totalizadores dos descontos
			oModTW6:AddLine()
			oModTW6:SetValue("TW6_TPDESC", cTpDesc)
		EndIf
		oModTW6:SetValue("TW6_OS", .T.)
		oModTW6:SetValue("TW6_VALOR", (oModTW6:GetValue("TW6_VALOR") + nCusto))
		If	Empty(oModel:GetValue("TW8DETAIL", "TW8_CODIGO"))
			oModel:SetValue("TW8DETAIL","TW8_CODIGO", oModTW6:GetValue("TW6_CODIGO"))	//Campo Gravado para controle
		EndIf

	Else

		// Desmarcando a O.S.
		If	( oModTW6:SeekLine({{"TW6_TPDESC", cTpDesc},{"TW6_CODIGO",AllTrim(oModel:GetValue("TW8DETAIL","TW8_CODIGO"))}}) )
			oModTW6:SetValue('TW6_VALOR', (oModTW6:GetValue('TW6_VALOR') - nCusto))
		Else
			Help(,,"AT930MARK",,STR0107,1,0)	//"Não localizado o tipo de desconto associado a esta Ordem de Serviço!"
			lRet := .F.
		EndIf

	EndIf
EndIf

FWRestRows(aSave)
Return lRet

//==============================================================================================================
/*/{Protheus.doc}  AT930TotDe()
Função que retonar o total de descontos
@author 	matheus.raimundo
@since  	12/02/2015
/*/
//==============================================================================================================
Function AT930TotDe(oModel,cPlan)
Local oModelTFW := oModel:GetModel("TFWDETAIL")
Local oModelTFX := oModel:GetModel("TFXDETAIL")
Local oModelTFY := oModel:GetModel("TFYDETAIL")
Local oModelTFL := oModel:GetModel("TFLDETAIL")
Local oModelTFI := oModel:GetModel("TFIPRODUT")

Local oModelTFWDES := oModel:GetModel("TFWTW6DETAIL")
Local oModelTFXDES := oModel:GetModel("TFXTW6DETAIL")
Local oModelTFYDES := oModel:GetModel("TFYTW6DETAIL")
Local oModelTFLDES := oModel:GetModel("TFITW6DETAIL")
Local nTot 	:= 0
Local nX		:= 0
Local nY		:= 0
Local nJ		:= 0
Local aSaveLines	:= FWSaveRows()

For nX := 1 To oModelTFW:Length()
	oModelTFW:GoLine(nX)
	If !oModelTFW:IsDeleted() .And. oModelTFW:GetValue('TFW_PLAN') == cPlan
		For nY := 1 To oModelTFWDES:Length()
			oModelTFWDES:GoLine(nY)
			If !oModelTFWDES:IsDeleted() .And. !Empty(oModelTFWDES:GetValue("TW6_TPDESC"))
				nTot += oModelTFWDES:GetValue("TW6_VALOR")
			EndIf
		Next nY
	EndIf
Next nX

For nX := 1 To oModelTFX:Length()
	oModelTFX:GoLine(nX)
	If !oModelTFX:IsDeleted() .And. oModelTFX:GetValue('TFX_PLAN') == cPlan
		For nY := 1 To oModelTFXDES:Length()
			oModelTFXDES:GoLine(nY)
			If !oModelTFXDES:IsDeleted() .And.  !Empty(oModelTFXDES:GetValue("TW6_TPDESC"))
				nTot += oModelTFXDES:GetValue("TW6_VALOR")
			EndIf
		Next nY
	EndIf
Next nX

For nX := 1 To oModelTFY:Length()
	oModelTFY:GoLine(nX)
	If !oModelTFY:IsDeleted() .And. oModelTFY:GetValue('TFY_PLAN') == cPlan
		For nY := 1 To oModelTFYDES:Length()
			oModelTFYDES:GoLine(nY)
			If !oModelTFYDES:IsDeleted() .And.  !Empty(oModelTFYDES:GetValue("TW6_TPDESC"))
				nTot += oModelTFYDES:GetValue("TW6_VALOR")
			EndIf
		Next nY
	EndIf
Next nX

For nX := 1 To oModelTFL:Length()
	oModelTFL:GoLine(nX)
	If !oModelTFL:IsDeleted() .And. oModelTFL:GetValue('TFL_PLAN') == cPlan
		For nY := 1 To oModelTFI:Length()
			oModelTFI:GoLine(nY)
			If !oModelTFI:IsDeleted()
				For nJ := 1 To oModelTFLDES:Length()
					oModelTFLDES:GoLine(nJ)
					If !oModelTFLDES:IsDeleted() .And.  !Empty(oModelTFLDES:GetValue("TW6_TPDESC"))
						nTot += oModelTFLDES:GetValue("TW6_VALOR")
					EndIf
				Next nJ
			EndIf
		Next nY
	EndIf
Next nX

FWRestRows(aSaveLines)

Return nTot


//==============================================================================================================
/*/{Protheus.doc}  A930Multas()
Função que retonar o total de descontos
@author 	matheus.raimundo
@since  	12/02/2015
/*/
//==============================================================================================================
Function A930Multas(oModel,cPlan,nVlrMulta,nVlrBoni)
Local oModelTFW := oModel:GetModel("TFWDETAIL")
Local oModelTFX := oModel:GetModel("TFXDETAIL")
Local oModelTFY := oModel:GetModel("TFYDETAIL")
Local oModelTFL := oModel:GetModel("TFLDETAIL")
Local oModelTFI := oModel:GetModel("TFIPRODUT")
Local oModelTFWMUL := oModel:GetModel("TFWTW7DETAIL")
Local oModelTFXMUL := oModel:GetModel("TFXTW7DETAIL")
Local oModelTFYMUL := oModel:GetModel("TFYTW7DETAIL")
Local oModelTFLMUL := oModel:GetModel("TFITW7DETAIL")
Local nTot 		:= 0
Local nX		:= 0
Local nY		:= 0
Local nJ		:= 0
Local aMultas	:= {}
Local aSaveLines	:= FWSaveRows()

Default nVlrMulta := 0
Default nVlrBoni  := 0

For nX := 1 To oModelTFW:Length()
	oModelTFW:GoLine(nX)
	If !oModelTFW:IsDeleted() .And. oModelTFW:GetValue('TFW_PLAN') == cPlan
		For nY := 1 To oModelTFWMUL:Length()
			oModelTFWMUL:GoLine(nY)
			If !oModelTFWMUL:IsDeleted() .And. !Empty(oModelTFWMUL:GetValue('TW7_VALOR'))
				aAdd(aMultas,Array(6))

				aTail(aMultas)[1] := oModelTFWMUL:GetValue("TW7_TPMOV")
				aTail(aMultas)[2] := oModelTFWMUL:GetValue("TW7_DESCRI")
				aTail(aMultas)[3] := oModelTFWMUL:GetValue("TW7_VALOR")
				aTail(aMultas)[4] := oModelTFWMUL:GetValue("TW7_MODO")
				aTail(aMultas)[5] := oModelTFWMUL:GetValue("TW7_FLGPED")

				If oModelTFWMUL:GetValue("TW7_TPMOV") == '1'
					nVlrMulta += oModelTFWMUL:GetValue("TW7_VALOR")
				ElseIf oModelTFWMUL:GetValue("TW7_TPMOV") == '2'
					nVlrBoni += oModelTFWMUL:GetValue("TW7_VALOR")
				EndIf

			EndIf
		Next nY
	EndIf
Next nX

For nX := 1 To oModelTFX:Length()
	oModelTFX:GoLine(nX)
	If !oModelTFX:IsDeleted() .And. oModelTFX:GetValue('TFX_PLAN') == cPlan
		For nY := 1 To oModelTFXMUL:Length()
			oModelTFXMUL:GoLine(nY)
			If !oModelTFXMUL:IsDeleted() .And. !Empty(oModelTFXMUL:GetValue('TW7_VALOR'))
				aAdd(aMultas,Array(6))

				aTail(aMultas)[1] := oModelTFXMUL:GetValue("TW7_TPMOV")
				aTail(aMultas)[2] := oModelTFXMUL:GetValue("TW7_DESCRI")
				aTail(aMultas)[3] := oModelTFXMUL:GetValue("TW7_VALOR")
				aTail(aMultas)[4] := oModelTFXMUL:GetValue("TW7_MODO")
				aTail(aMultas)[5] := oModelTFXMUL:GetValue("TW7_FLGPED")

				If oModelTFXMUL:GetValue("TW7_TPMOV") == '1'
					nVlrMulta += oModelTFXMUL:GetValue("TW7_VALOR")
				ElseIf oModelTFXMUL:GetValue("TW7_TPMOV") == '2'
					nVlrBoni += oModelTFXMUL:GetValue("TW7_VALOR")
				EndIf

			EndIf
		Next nY
	EndIf
Next nX

For nX := 1 To oModelTFY:Length()
	oModelTFY:GoLine(nX)
	If !oModelTFY:IsDeleted() .And. oModelTFY:GetValue('TFY_PLAN') == cPlan
		For nY := 1 To oModelTFYMUL:Length()
			oModelTFYMUL:GoLine(nY)
			If !oModelTFYMUL:IsDeleted() .And. !Empty(oModelTFYMUL:GetValue('TW7_VALOR'))
				aAdd(aMultas,Array(6))

				aTail(aMultas)[1] := oModelTFYMUL:GetValue("TW7_TPMOV")
				aTail(aMultas)[2] := oModelTFYMUL:GetValue("TW7_DESCRI")
				aTail(aMultas)[3] := oModelTFYMUL:GetValue("TW7_VALOR")
				aTail(aMultas)[4] := oModelTFYMUL:GetValue("TW7_MODO")
				aTail(aMultas)[5] := oModelTFYMUL:GetValue("TW7_FLGPED")

				If oModelTFYMUL:GetValue("TW7_TPMOV") == '1'
					nVlrMulta += oModelTFYMUL:GetValue("TW7_VALOR")
				ElseIf oModelTFYMUL:GetValue("TW7_TPMOV") == '2'
					nVlrBoni += oModelTFYMUL:GetValue("TW7_VALOR")
				EndIf
			EndIf
		Next nY
	EndIf
Next nX

For nX := 1 To oModelTFL:Length()
	oModelTFL:GoLine(nX)
	If !oModelTFL:IsDeleted() .And. oModelTFL:GetValue('TFL_PLAN') == cPlan
		For nY := 1 To oModelTFI:Length()
			oModelTFI:GoLine(nY)
			If !oModelTFI:IsDeleted()
				For nJ := 1 To oModelTFLMUL:Length()
					oModelTFLMUL:GoLine(nJ)
					If !oModelTFLMUL:IsDeleted() .And. !Empty(oModelTFLMUL:GetValue('TW7_VALOR'))
						aAdd(aMultas,Array(6))
						aTail(aMultas)[1] := oModelTFLMUL:GetValue("TW7_TPMOV")
						aTail(aMultas)[2] := oModelTFLMUL:GetValue("TW7_DESCRI")
						aTail(aMultas)[3] := oModelTFLMUL:GetValue("TW7_VALOR")
						aTail(aMultas)[4] := oModelTFLMUL:GetValue("TW7_MODO")
						aTail(aMultas)[5] := oModelTFLMUL:GetValue("TW7_FLGPED")

						If oModelTFLMUL:GetValue("TW7_TPMOV") == '1'
							nVlrMulta += oModelTFLMUL:GetValue("TW7_VALOR")
						ElseIf oModelTFLMUL:GetValue("TW7_TPMOV") == '2'
							nVlrBoni += oModelTFLMUL:GetValue("TW7_VALOR")
						EndIf

					EndIf
				Next nJ
			EndIf
		Next nY
	EndIf
Next nX

FWRestRows(aSaveLines)
Return aMultas

//==============================================================================================================
/*/{Protheus.doc}  A930Desc()
	Função que retorna o array com os descontos.
@author 	Kaique Schiller Olivero
@since  	12/02/2015
/*/
//==============================================================================================================
Function A930Desc(oModel,cPlan)
Local oModelTFW 	:= oModel:GetModel("TFWDETAIL")
Local oModelTFX 	:= oModel:GetModel("TFXDETAIL")
Local oModelTFY 	:= oModel:GetModel("TFYDETAIL")
Local oModelTFL 	:= oModel:GetModel("TFLDETAIL")
Local oModelTFI 	:= oModel:GetModel("TFIPRODUT")
Local oModelTFWDES 	:= oModel:GetModel("TFWTW6DETAIL")
Local oModelTFXDES 	:= oModel:GetModel("TFXTW6DETAIL")
Local oModelTFYDES 	:= oModel:GetModel("TFYTW6DETAIL")
Local oModelTFLDES 	:= oModel:GetModel("TFITW6DETAIL")
Local nTot 			:= 0
Local nX			:= 0
Local nY			:= 0
Local nJ			:= 0
Local aSaveLines	:= FWSaveRows()
Local aDesconts		:= {}
Local nPos 			:= 0

For nX := 1 To oModelTFW:Length()
	oModelTFW:GoLine(nX)
	If !oModelTFW:IsDeleted() .And. oModelTFW:GetValue('TFW_PLAN') == cPlan
		For nY := 1 To oModelTFWDES:Length()
			oModelTFWDES:GoLine(nY)
			If !oModelTFWDES:IsDeleted() .And. !Empty(oModelTFWDES:GetValue("TW6_TPDESC"))
				nPos := Ascan(aDesconts, {|x| x[4] == oModelTFWDES:GetValue("TW6_TPDESC") })
				If nPos == 0
					aAdd(aDesconts,Array(7))
					aTail(aDesconts)[1] := oModelTFWDES:GetValue("TW6_CODIGO")
					aTail(aDesconts)[2] := oModelTFWDES:GetValue("TW6_TPPAI")
					aTail(aDesconts)[3] := oModelTFWDES:GetValue("TW6_CODPAI")
					aTail(aDesconts)[4] := oModelTFWDES:GetValue("TW6_TPDESC")
					aTail(aDesconts)[5] := oModelTFWDES:GetValue("TW6_DESCRI")
					aTail(aDesconts)[6] := oModelTFWDES:GetValue("TW6_VALOR")
					aTail(aDesconts)[7] := oModelTFWDES:GetValue("TW6_OS")
				Else
					aDesconts[nPos,6] += oModelTFWDES:GetValue("TW6_VALOR")
				EndIf
			EndIf
		Next nY
	EndIf
Next nX

For nX := 1 To oModelTFX:Length()
	oModelTFX:GoLine(nX)
	If !oModelTFX:IsDeleted() .And. oModelTFX:GetValue('TFX_PLAN') == cPlan
		For nY := 1 To oModelTFXDES:Length()
			oModelTFXDES:GoLine(nY)
			If !oModelTFXDES:IsDeleted() .And.  !Empty(oModelTFXDES:GetValue("TW6_TPDESC"))
				nPos := Ascan(aDesconts, {|x| x[4] == oModelTFXDES:GetValue("TW6_TPDESC") })
				If nPos == 0
					aAdd(aDesconts,Array(7))
					aTail(aDesconts)[1] := oModelTFXDES:GetValue("TW6_CODIGO")
					aTail(aDesconts)[2] := oModelTFXDES:GetValue("TW6_TPPAI")
					aTail(aDesconts)[3] := oModelTFXDES:GetValue("TW6_CODPAI")
					aTail(aDesconts)[4] := oModelTFXDES:GetValue("TW6_TPDESC")
					aTail(aDesconts)[5] := oModelTFXDES:GetValue("TW6_DESCRI")
					aTail(aDesconts)[6] := oModelTFXDES:GetValue("TW6_VALOR")
					aTail(aDesconts)[7] := oModelTFXDES:GetValue("TW6_OS")
				Else
					aDesconts[nPos,6] += oModelTFXDES:GetValue("TW6_VALOR")
				EndIf
			EndIf
		Next nY
	EndIf
Next nX

For nX := 1 To oModelTFY:Length()
	oModelTFY:GoLine(nX)
	If !oModelTFY:IsDeleted() .And. oModelTFY:GetValue('TFY_PLAN') == cPlan
		For nY := 1 To oModelTFYDES:Length()
			oModelTFYDES:GoLine(nY)
			If !oModelTFYDES:IsDeleted() .And.  !Empty(oModelTFYDES:GetValue("TW6_TPDESC"))
				nPos := Ascan(aDesconts, {|x| x[4] == oModelTFYDES:GetValue("TW6_TPDESC") })
				If nPos == 0
					aAdd(aDesconts,Array(7))
					aTail(aDesconts)[1] := oModelTFYDES:GetValue("TW6_CODIGO")
					aTail(aDesconts)[2] := oModelTFYDES:GetValue("TW6_TPPAI")
					aTail(aDesconts)[3] := oModelTFYDES:GetValue("TW6_CODPAI")
					aTail(aDesconts)[4] := oModelTFYDES:GetValue("TW6_TPDESC")
					aTail(aDesconts)[5] := oModelTFYDES:GetValue("TW6_DESCRI")
					aTail(aDesconts)[6] := oModelTFYDES:GetValue("TW6_VALOR")
					aTail(aDesconts)[7] := oModelTFYDES:GetValue("TW6_OS")
				Else
					aDesconts[nPos,6] += oModelTFYDES:GetValue("TW6_VALOR")
				EndIf
			EndIf
		Next nY
	EndIf
Next nX

For nX := 1 To oModelTFL:Length()
	oModelTFL:GoLine(nX)
	If !oModelTFL:IsDeleted() .And. oModelTFL:GetValue('TFL_PLAN') == cPlan
		For nY := 1 To oModelTFI:Length()
			oModelTFI:GoLine(nY)
			If !oModelTFI:IsDeleted()
				For nJ := 1 To oModelTFLDES:Length()
					oModelTFLDES:GoLine(nJ)
					If !oModelTFLDES:IsDeleted() .And.  !Empty(oModelTFLDES:GetValue("TW6_TPDESC"))
						nPos := Ascan(aDesconts, {|x| x[4] == oModelTFLDES:GetValue("TW6_TPDESC") })
						If nPos == 0
							aAdd(aDesconts,Array(7))
							aTail(aDesconts)[1] := oModelTFLDES:GetValue("TW6_CODIGO")
							aTail(aDesconts)[2] := oModelTFLDES:GetValue("TW6_TPPAI")
							aTail(aDesconts)[3] := oModelTFLDES:GetValue("TW6_CODPAI")
							aTail(aDesconts)[4] := oModelTFLDES:GetValue("TW6_TPDESC")
							aTail(aDesconts)[5] := oModelTFLDES:GetValue("TW6_DESCRI")
							aTail(aDesconts)[6] := oModelTFLDES:GetValue("TW6_VALOR")
							aTail(aDesconts)[7] := oModelTFLDES:GetValue("TW6_OS")
						Else
							aDesconts[nPos,6] += oModelTFLDES:GetValue("TW6_VALOR")
						EndIf
					EndIf
				Next nJ
			EndIf
		Next nY
	EndIf
Next nX

FWRestRows(aSaveLines)

Return aDesconts

//==============================================================================================================
/*/{Protheus.doc}  A930GetDsc()
Função que retorna o total de descontos.
@author 	matheus.raimundo
@since  	19/02/2015
/*/
//==============================================================================================================
Function A930GetDsc(cCod,cTipo)
Local cAliasTW6 := GetNextAlias()
Local nRet 	  := 0

If !Empty(cCod)
	BeginSql Alias cAliasTW6

		SELECT SUM(TW6.TW6_VALOR) TW6_VALOR
		  FROM %table:TW6% TW6
		 WHERE TW6.TW6_FILIAL = %xFilial:TW6%
		   AND TW6.TW6_CODPAI IN %Exp:cCod%
		   AND TW6.TW6_TPPAI = %Exp:cTipo%
		   AND TW6.%NotDel%

	EndSql

	nRet :=  (cAliasTW6)->(TW6_VALOR)
	(cAliasTW6)->(dbCloseArea())
Else
	nRet := 0
EndIf

Return nRet


//==============================================================================================================
/*/{Protheus.doc}  A930GetMB()
Função que retorna o total de Multas e Bonificações
@author 	matheus.raimundo
@since  	19/02/2015
/*/
//==============================================================================================================
Function A930GetMB(cCod,cTipo,nVlrMulta,nVlrBoni)
Local cAliasTW7 := GetNextAlias()

If !Empty(cCod)
	BeginSql Alias cAliasTW7

		SELECT SUM(TW7.TW7_VALOR) TW7_VALOR, TW7_TPMOV
		  FROM %table:TW7% TW7
		 WHERE TW7.TW7_FILIAL = %xFilial:TW7%
		   AND TW7.TW7_CODPAI IN %Exp:cCod%
		   AND TW7.TW7_TPPAI = %Exp:cTipo%
		   AND TW7.%NotDel%
		 GROUP BY TW7_TPMOV

	EndSql

	While (cAliasTW7)->(!Eof())

		If (cAliasTW7)->(TW7_TPMOV) == '1'
			nVlrMulta := (cAliasTW7)->(TW7_VALOR)
		ElseIf (cAliasTW7)->(TW7_TPMOV) == '2'
			nVlrBoni += (cAliasTW7)->TW7_VALOR
		EndIf

		(cAliasTW7)->(dbSkip())
	EndDo
	(cAliasTW7)->(dbCloseArea())
Else
	nVlrMulta := 0
	nVlrBoni := 0
EndIf

Return

//==============================================================================================================
/*/{Protheus.doc}  A930VLnTFITW6()
Função de validação da linha do modelo TFITW6DETAIL
@return	lRet
@author 	israel.escorizza
@since  	22/02/2015
/*/
//==============================================================================================================
Function A930VLnTFITW6()
Local oModel		:= FwModelActive()
Local oModTFITW6	:= oModel:GetModel('TFITW6DETAIL')
Local lRet 		:= .T.

If Empty(oModTFITW6:GetValue("TW6_TPDESC"))
	Help(" ",1,"A930NOTPO") //- "Campo Tipo Desc não preenchido"
	lRet := .F.
ElseIf oModTFITW6:GetValue("TW6_VALOR") <= 0 .And. !oModTFITW6:GetValue("TW6_OS")
	Help(" ",1,"A930NOVLR") //- "Campo Valor não preenchido"
	lRet := .F.
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  FMedApu930()
	Monta a tela de detalhamento de apontamento por valor
@author 	Serviços
@since  	02/07/2015
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Function FMedApu930(oModel)
Local cAliasPro	:= "AT930QRY"
Local cRotina  	:= 'TECA930'
Local cTitulo  	:= STR0086 //'Detalhes Apontamento por Valor'
Local cQuery   	:= ''
Local aSize	 		:= FWGetDialogSize( oMainWnd ) 	// Array com tamanho da janela.
Local aFields  	:= {}
Local cApuracao	:=oModel:GetModel("TFVMASTER"):GetValue("TFV_CODIGO")


Local oPanel   := Nil
Local oFWLayer := Nil
Local oBrowse  := Nil

oBrowse := FWFormBrowse():New()

aColumns := At930Cols(cAliasPro)

If oModel:GetOperation() == MODEL_OPERATION_DELETE//Estorno
	cQuery   := At930Query(cApuracao)
Else
	cQuery   := At930Query("")
EndIf


DEFINE DIALOG oDlg TITLE cTitulo FROM aSize[1] + 100,aSize[2] + 100 TO aSize[3] - 100, aSize[4] - 100 PIXEL

// Cria um Form Browse
oBrowse := FWFormBrowse():New()

// Atrela o browse ao Dialog form nao abre sozinho
oBrowse:SetOwner(oDlg)

// Indica que vai utilizar query
oBrowse:SetAlias(cAliasPro)
oBrowse:SetDataQuery(.T.)
oBrowse:SetQuery(cQuery)

oBrowse:SetColumns(aColumns)
oBrowse:DisableDetails()

oBrowse:AddButton( STR0085, { || oDlg:End() },,,, .F., 2 )	//'Sair'

oBrowse:SetDescription(cTitulo)

oBrowse:Activate()

ACTIVATE DIALOG oDlg CENTERED

Return ( .T. )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At930Cols()
	Tratamento dos campos que serão exibidos na tela de detalhamento de materiais
@author 	Serviços
@since  	02/07/2015
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At930Cols( cAliasPro )

Local nI		:= 0
Local aArea		:= GetArea()
Local aColumns	:= {}

Local aCampos 	:= { "TGU_DATA", "TFL_LOCAL", "ABS_DESCRI", "TGU_PROD", "B1_DESC", "TGU_QUANT", "TGU_VALOR", "TGU_TOTAL" }

DbSelectArea("SX3")
SX3->(DbSetOrder(2))

For nI:=1 To Len(aCampos)

	if aCampos[nI] == 'TGU_TOTAL'

		cCampo := aCampos[nI]

		AAdd(aColumns,FWBrwColumn():New())
		nLinha := Len(aColumns)
	   	aColumns[nLinha]:SetType("N")
	   	aColumns[nLinha]:SetTitle("Total")
		aColumns[nLinha]:SetSize(14)
		aColumns[nLinha]:SetDecimal(2)
		aColumns[nLinha]:SetPicture(" @E 999,999,999.99" )
		aColumns[nLinha]:SetData(&("{||" + cCampo + "}"))

	else
		If SX3->(dbSeek(aCampos[nI]))

			cCampo := AllTrim(SX3->X3_CAMPO)

			AAdd(aColumns,FWBrwColumn():New())
			nLinha := Len(aColumns)
		   	aColumns[nLinha]:SetType(SX3->X3_TIPO)
		   	aColumns[nLinha]:SetTitle(X3Titulo())
			aColumns[nLinha]:SetSize(SX3->X3_TAMANHO)
			aColumns[nLinha]:SetDecimal(SX3->X3_DECIMAL)
			aColumns[nLinha]:SetPicture(SX3->X3_PICTURE)

			If SX3->X3_TIPO == "D"
				aColumns[nLinha]:SetData(&("{|| sTod(" + cCampo + ")}"))
			Else
				aColumns[nLinha]:SetData(&("{||" + cCampo + "}"))
			EndIf

		EndIf
	endif

Next nI

SX3->(dbCloseArea())

RestArea(aArea)

Return(aColumns)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At930Query()
	Query para filtro dos registros de detalhamento por valor
@author 	Serviços
@since  	02/07/2015
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930Query(cApuracao)
Local cRevCtr := Posicione("CN9",1,xFilial("CN9")+MV_PAR01,"CN9_REVATU")

Default cApuracao := ""

cQuery := " SELECT TGU_DATA, TFL_LOCAL, ABS_DESCRI, TGU_PROD, B1_DESC, TGU_QUANT, TGU_VALOR, ( TGU_QUANT * TGU_VALOR ) TGU_TOTAL "

cQuery += " FROM " + RetSqlName("TGU")

cQuery += " INNER JOIN " + RetSqlName("TFL")
cQuery += " ON TFL_FILIAL = '" + xFilial("TFL") + "' AND"
cQuery += " TFL_CONTRT = '" + MV_PAR01 + "' AND TFL_CONREV = '" + cRevCtr + "' "
cQuery += " AND TGU_CODTFL = TFL_CODIGO "

cQuery += " INNER JOIN " + RetSqlName("SB1")
cQuery += " ON B1_FILIAL = '" + xFilial("SB1") + "' AND"
cQuery += " B1_COD = TGU_PROD "

cQuery += " INNER JOIN " + RetSqlName("ABS")
cQuery += " ON ABS_FILIAL = '"+ xFilial("ABS") + "' AND"
cQuery += " ABS_LOCAL = TFL_LOCAL "

cQuery += " WHERE TGU_APURAC = '"+cApuracao+"'"
cQuery += " AND ( TGU_DATA >= '" + dToS(MV_PAR02) + "' AND TGU_DATA <= '" +  dToS(MV_PAR03) + "' ) "
cQuery += " AND "+RetSqlName("TFL")+".D_E_L_E_T_ = ''"
cQuery += " AND "+RetSqlName("TGU")+".D_E_L_E_T_ = ''"
cQuery += " AND "+RetSqlName("SB1")+".D_E_L_E_T_ = ''"
cQuery += " AND "+RetSqlName("ABS")+".D_E_L_E_T_ = ''"
cQuery += " AND TGU_FILIAL = '" + xFilial("TGU") + "' "
cQuery += " ORDER BY TGU_DATA"

Return ( cQuery )

/*/{Protheus.doc}  At930ResLoc()
	Carrega os dados dos locais do Orçamento na apuração (aba de resumo dos locais)
@since  	01/04/2016
/*/
Function At930ResLoc( oMdl, cNumCtr, cRevCtr )

Local oMdlResumo := oMdl:GetModel("TWBDETAIL")
Local aArea := GetArea()
Local aAreaTFL := TFL->( GetArea() )
Local aArTFL	:= {}
Local lOk := .T.
Local nValImp := 0
Local lValImp := .F.
Local lCliFat	:= .F.
Local cAbsCliFat:= ""
Local cAbsLojfat:= ""

DbSelectArea("TFL")
TFL->(DbSetOrder( 4 )) //TFL_FILIAL+TFL_CONTRT+TFL_CONREV

If TFL->(DbSeek(xFilial("TFL")+cNumCtr+cRevCtr))

	oMdlResumo:SetNoInsertLine(.F.)	
	TFJ->( DbSetOrder(1) ) // TFJ_FILIAL+TFJ_CODIGO

	DbSelectArea("CNA")
	CNA->(DbSetOrder( 1 )) //CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO

	lValImp := TFJ->(DbSeek(xFilial("TFJ")+TFL->TFL_CODPAI)) .And. ; // posiciona no cabeçalho do orçamento de serviços
					!Empty(TFJ->TFJ_TABXML) .OR. !Empty(TFJ->TFJ_CODTAB)  // verifica se é orçamento com precificação


	While TFL->(!EOF()) .And. TFL->TFL_FILIAL == xFilial("TFL") .And. TFL->TFL_CONTRT == cNumCtr .And. TFL->TFL_CONREV == cRevCtr
		aArTFL := TFL->(GetArea())
		lCliFat := .F.
		If !Empty( oMdlResumo:GetValue("TWB_CODTFL") )
			// verifica se foi possível adicionar nova linha, caso não consiga
			// aborta o preenchimento do grid
			If oMdlResumo:Length()+1 <> oMdlResumo:AddLine()
				AtErroMvc(oMdl)
				MostraErro()
				lOk := .F.
				Exit
			EndIf
		EndIf
		// não sei pq mas no ambiente não estava inicializando corretamente com getsxenum na primeira linha
		If Empty( oMdlResumo:GetValue("TWB_COD") )
			lOk := lOk .And. oMdlResumo:SetValue("TWB_COD", CriaVar("TWB_COD"))
		EndIf

		lOk := lOk .And. oMdlResumo:SetValue("TWB_CODTFL", TFL->TFL_CODIGO)
		lOk := lOk .And. oMdlResumo:SetValue("TWB_CODABS", TFL->TFL_LOCAL)

		cAbsCliFat:= Posicione("ABS",1,xFilial("ABS")+TFL->TFL_LOCAL,"ABS_CLIFAT")
		cAbsLojfat:= Posicione("ABS",1,xFilial("ABS")+TFL->TFL_LOCAL,"ABS_LJFAT")

		If !Empty(Alltrim(cAbsCliFat)) .AND. !Empty(Alltrim(cAbsLojfat))
			cQuery := " SELECT 1 R_E_C_N_O_ "
			cQuery += " FROM   "+RetSqlName("CNC")+" CNC "
			cQuery += " WHERE  CNC.CNC_FILIAL = '"+xFilial("CNC")+"' "
			cQuery += " AND    CNC.CNC_NUMERO = '"+cNumCtr+"' "
			cQuery += " AND    CNC.CNC_REVISA = '"+cRevCtr+"' "
			cQuery += " AND    CNC.CNC_CLIENT = '"+cAbsCliFat+"' "
			cQuery += " AND    CNC.CNC_LOJACL = '"+cAbsLojfat+"' "
			cQuery += " AND    CNC.D_E_L_E_T_ = '' "
			cQuery := ChangeQuery(cQuery)
			cAliasCNC := GetNextAlias()
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCNC,.T.,.T.)
			If (cAliasCNC)->(!EOF())
				lCliFat:= .T.
			EndIf
			(cAliasCNC)->(DbCloseArea())
		EndIf

		If lCliFat
			lOk := lOk .And. oMdlResumo:SetValue("TWB_CLIENT", cAbsCliFat)
			lOk := lOk .And. oMdlResumo:SetValue("TWB_LOJA"  , cAbsLojfat)
		Else
			If CNA->(DbSeek(xFilial("CNA")+cNumCtr+cRevCtr+TFL->TFL_PLAN))
				lOk := lOk .And. oMdlResumo:SetValue("TWB_CLIENT", CNA->CNA_CLIENT)
				lOk := lOk .And. oMdlResumo:SetValue("TWB_LOJA"  , CNA->CNA_LOJACL)
			EndIf
		ENdIf
		//-------------------------------------------------------
		//  recarregar o objeto da planilha para capturar o valor de imposto
		If lValImp
			// lê o valor do imposto a partir do campo na TFL
			nValImp := TFL->TFL_TOTIMP

			If nValImp > 0
				lOk := lOk .And. oMdlResumo:SetValue("TWB_VLORIG", nValImp)
				lOk := lOk .And. oMdlResumo:SetValue("TWB_IMPMED", ( nValImp/ At740FDDiff( TFL->TFL_DTINI, TFL->TFL_DTFIM ) ) )
			EndIf
		EndIf

		// aborta o preenchimento na identificação de qlq erro
		If !lOk
			AtErroMvc(oMdl)
			MostraErro()
			Exit
		EndIf
		RestArea(aArTFL)
		TFL->(DbSkip())
	End
	oMdlResumo:SetNoInsertLine(.T.)
EndIf

RestArea(aAreaTFL)
RestArea(aArea)

Return

/*/{Protheus.doc}  At930TrgLoc()
	Função para execução dos gatilho de preenchimento dos campos conforme o conceito de produto RH, MI, MC e LE
@since  	05/04/2016
@sample 	At930TrgLoc( 'TFXDETAIL', 'TFX_VLRMED', 'TWBDETAIL', 'TWB_VLRMI', 'TFX_CODTFL' )
@param  	cMdlCalc, Caracter, modelo de origem das informações
@param  	cCpoTot, Caracter, identificador do campo que deve ter o conteúdo somado
@param  	cMdlCDom, Caracter, modelo de destino do valor somado
@param  	cCpoCDom, Caracter, identificador do campo de destino do valor somado
@param  	cCpoCodTFL, Caracter, identificador do campo que possui o conteúdo com o código da TFL para condicionar a soma
/*/
Function At930TrgLoc( cMdlCalc, cCpoTot, cMdlCDom, cCpoCDOM, cCpoCodTFL )

Local nValor := 0
Local nX := 1
Local oMdl   := FwModelActive()
Local nLineAnt := oMdl:GetModel( cMdlCalc ):GetLine()
Local cCodTFL := oMdl:GetModel( cMdlCalc ):GetValue(cCpoCodTFL)

For nX := 1 To oMdl:GetModel( cMdlCalc ):Length()
    oMdl:GetModel( cMdlCalc ):GoLine(nX)

	If oMdl:GetModel( cMdlCalc ):GetValue(cCpoCodTFL) == cCodTFL
    	nValor += oMdl:GetModel( cMdlCalc ):GetValue( cCpoTot )
	EndIf
Next nX

// posiciona no item do local que deve sofrer a atualização do valor
If oMdl:GetModel( cMdlCDom ):SeekLine( {{ "TWB_CODTFL", cCodTFL }} )
	oMdl:GetModel( cMdlCDom ):SetValue( cCpoCDOM, nValor )
EndIf

oMdl:GetModel( cMdlCalc ):GoLine(nLineAnt)

Return 0

/*/{Protheus.doc}  At930TrgMBD()
	Função para somar os valores de Multa, Bonificações e Descontos conforme o código do local do orçamento vinculado
@since  	05/04/2016
@sample 	At930TrgMBD( 'TFIPRODUT', 1, 'TFI_CODPAI' )
@param  	cIdMdlOrig, Caracter, modelo de origem das informações
@param  	nTipo, Numerico, codigo que indica qual o tipo deve ter o conteúdo somado (1=Multa;2=Bonificação;3=Desconto)
@param  	cCpoCodTFL, Caracter, identificador do campo que possui o conteúdo com o código da TFL para condicionar a soma
/*/
Function At930TrgMBD( cIdMdlOrig, nTipo, cCpoCodTFL )

Local nValor := 0
Local nX := 1
Local nY := 1
Local oMdl   := FwModelActive()
Local nLineAnt := oMdl:GetModel( cIdMdlOrig ):GetLine()
Local cCodTFL := oMdl:GetModel( cIdMdlOrig ):GetValue(cCpoCodTFL)
Local aInfCpos := {{"TFWDETAIL","TFW_CODTFL",{"TFW_TOTMUL","TFW_TOTBON","TFW_TOTDES"}},;
					{"TFXDETAIL","TFX_CODTFL",{"TFX_TOTMUL","TFX_TOTBON","TFX_TOTDES"}},;
					{"TFYDETAIL","TFY_CODTFL",{"TFY_TOTMUL","TFY_TOTBON","TFY_TOTDES"}},;
					{"TFIPRODUT","TFI_CODPAI",{"TFI_TOTMUL","TFI_TOTBON","TFI_TOTDES"}}}
Local aCpoDest := { "TWB_VLRMUL", "TWB_VLRBON", "TWB_VLRDES" }
Local oMdlTmp := Nil
Default nTipo := 0

If nTipo > 0 .And. nTipo <= 3
	For nX := 1 To Len(aInfCpos)

	    oMdlTmp := oMdl:GetModel( aInfCpos[nX,1] )

	    For nY := 1 To oMdlTmp:Length()

	    	oMdlTmp:GoLine(nY)

			If oMdlTmp:GetValue(aInfCpos[nX,2]) == cCodTFL
		    	nValor += oMdlTmp:GetValue( aInfCpos[nX,3,nTipo] )
			EndIf

		Next nY
	Next nX

// posiciona no item do local que deve sofrer a atualização do valor
	If oMdl:GetModel( "TWBDETAIL" ):SeekLine( {{ "TWB_CODTFL", cCodTFL }} )
		oMdl:GetModel( "TWBDETAIL" ):SetValue( aCpoDest[nTipo], nValor )
	EndIf

	oMdl:GetModel( cIdMdlOrig ):GoLine(nLineAnt)

EndIf

Return 0

/*/{Protheus.doc}  At930ResView()
	Função para somar os valores de Multa, Bonificações e Descontos conforme o código do local do orçamento vinculado
@since  	05/04/2016
@sample 	At930ResView( oMdlGer )
@param  	cIdMdlOrig, Caracter, modelo de origem das informações
@param  	nTipo, Numerico, codigo que indica qual o tipo deve ter o conteúdo somado (1=Multa;2=Bonificação;3=Desconto)
@param  	cCpoCodTFL, Caracter, identificador do campo que possui o conteúdo com o código da TFL para condicionar a soma
/*/
Function At930ResView( oMdlGer, cContrato, cRevisa, nOpe )

Local nPosCodLoc 		:= 1
Local nPosRh 			:= 2
Local nPosMi 			:= 3
Local nPosMc 			:= 4
Local nPosLe 			:= 5
Local nPosMul 			:= 6
Local nPosBon 			:= 7
Local nPosDes 			:= 8
Local nPosCodABS 		:= 9
Local nPosDesABS 		:= 10
Local nPosCliente		:= 11
Local nPosLoja			:= 12
Local nQtTotal 			:= 12
Local aDadosLocais 		:= Array(oMdlGer:GetModel("TWBDETAIL"):Length())
Local nI 				:= 1
Local nJ 				:= 1
Local nK 				:= 1
Local nItLocal 			:= 0
Local cFilABS			:= xFilial("ABS")
Local cFilTFL			:= xFilial("TFL")
Local oMdlTemp 			:= Nil
Local lCheck			:= .T.

// Cria a estrutura para copiar os dados dos modelos
For nI := 1 To Len(aDadosLocais)
	aDadosLocais[nI]				:= Array(nQtTotal)
	// inicializa o conteúdo conforme o tipo
	aDadosLocais[nI,nPosCodLoc] := ""
	aDadosLocais[nI,nPosRh]		:= 0
	aDadosLocais[nI,nPosMi]		:= 0
	aDadosLocais[nI,nPosMc]		:= 0
	aDadosLocais[nI,nPosLe]		:= 0
	aDadosLocais[nI,nPosMul]		:= 0
	aDadosLocais[nI,nPosBon]		:= 0
	aDadosLocais[nI,nPosDes]		:= 0
	aDadosLocais[nI,nPosCodABS]	:= 0
	aDadosLocais[nI,nPosDesABS]	:= ""
	aDadosLocais[nI,nPosCliente]:= ""
	aDadosLocais[nI,nPosLoja]	:= ""
Next nI

// Soma os valores conforme os conceitos de produtos: RH, Mat. Imp., Mat. Cons. e Locação
// Recursos Humanos
oMdlTemp := oMdlGer:GetModel("TFWDETAIL")
For nI := 1 To oMdlTemp:Length()
	oMdlTemp:GoLine(nI)

	If ( nItLocal := aScan( aDadosLocais, {|x| x[nPosCodLoc] == oMdlTemp:GetValue("TFW_CODTFL") } ) ) == 0
		nItLocal := aScan( aDadosLocais, {|x| AllTrim(x[nPosCodLoc])== "" } )
	EndIf

	If	nItLocal > 0
		aDadosLocais[nItLocal,nPosCodLoc]	:= oMdlTemp:GetValue("TFW_CODTFL")
		aDadosLocais[nItLocal,nPosRh]		+= oMdlTemp:GetValue("TFW_VLRMED")+oMdlTemp:GetValue("TFW_VLREXT")
		aDadosLocais[nItLocal,nPosMul]		+= oMdlTemp:GetValue("TFW_TOTMUL")
		aDadosLocais[nItLocal,nPosBon]		+= oMdlTemp:GetValue("TFW_TOTBON")
		aDadosLocais[nItLocal,nPosDes]		+= oMdlTemp:GetValue("TFW_TOTDES")
	EndIf
Next nI
oMdlTemp:GoLine(1)

// Material de Implantação
oMdlTemp := oMdlGer:GetModel("TFXDETAIL")
For nI := 1 To oMdlTemp:Length()
	oMdlTemp:GoLine(nI)

	If ( nItLocal := aScan( aDadosLocais, {|x| x[nPosCodLoc]== oMdlTemp:GetValue("TFX_CODTFL") } ) ) == 0
		nItLocal := aScan( aDadosLocais, {|x| AllTrim(x[nPosCodLoc])== "" } )
	EndIf

	If	nItLocal > 0
		aDadosLocais[nItLocal,nPosCodLoc]	:= oMdlTemp:GetValue("TFX_CODTFL")
		aDadosLocais[nItLocal,nPosMi]		+= oMdlTemp:GetValue("TFX_VLRMED")
		aDadosLocais[nItLocal,nPosMul]		+= oMdlTemp:GetValue("TFX_TOTMUL")
		aDadosLocais[nItLocal,nPosBon]		+= oMdlTemp:GetValue("TFX_TOTBON")
		aDadosLocais[nItLocal,nPosDes]		+= oMdlTemp:GetValue("TFX_TOTDES")
	EndIf
Next nI
oMdlTemp:GoLine(1)

// Material de Consumo
oMdlTemp := oMdlGer:GetModel("TFYDETAIL")
For nI := 1 To oMdlTemp:Length()
	oMdlTemp:GoLine(nI)

	If ( nItLocal := aScan( aDadosLocais, {|x| x[nPosCodLoc]== oMdlTemp:GetValue("TFY_CODTFL") } ) ) == 0
		nItLocal := aScan( aDadosLocais, {|x| AllTrim(x[nPosCodLoc])== "" } )
	EndIf

	If	nItLocal > 0
		aDadosLocais[nItLocal,nPosCodLoc]	:= oMdlTemp:GetValue("TFY_CODTFL")
		aDadosLocais[nItLocal,nPosMc]		+= oMdlTemp:GetValue("TFY_VLRMED")
		aDadosLocais[nItLocal,nPosMul]		+= oMdlTemp:GetValue("TFY_TOTMUL")
		aDadosLocais[nItLocal,nPosBon]		+= oMdlTemp:GetValue("TFY_TOTBON")
		aDadosLocais[nItLocal,nPosDes]		+= oMdlTemp:GetValue("TFY_TOTDES")
	EndIf
Next nI
oMdlTemp:GoLine(1)

// Locação de Equipamentos - TFL - TFI - TFZ
oMdlTemp := oMdlGer:GetModel("TFLDETAIL")
For nI := 1 To oMdlTemp:Length()
	oMdlTemp:GoLine(nI)

	If ( nItLocal := aScan( aDadosLocais, {|x| x[nPosCodLoc]== oMdlTemp:GetValue("TFL_CODIGO") } ) ) == 0
		nItLocal := aScan( aDadosLocais, {|x| AllTrim(x[nPosCodLoc])== "" } )
	EndIf

	If	nItLocal > 0
		aDadosLocais[nItLocal,nPosCodLoc]	:= oMdlTemp:GetValue("TFL_CODIGO")
		aDadosLocais[nItLocal,nPosLe]		+= oMdlTemp:GetValue("TFL_VALTOT")

		For nJ := 1 To oMdlGer:GetModel("TFIPRODUT"):Length()
			oMdlGer:GetModel("TFIPRODUT"):GoLine(nJ)

			aDadosLocais[nItLocal,nPosMul]	+= oMdlGer:GetModel("TFIPRODUT"):GetValue("TFI_TOTMUL")
			aDadosLocais[nItLocal,nPosBon]	+= oMdlGer:GetModel("TFIPRODUT"):GetValue("TFI_TOTBON")
			aDadosLocais[nItLocal,nPosDes]	+= oMdlGer:GetModel("TFIPRODUT"):GetValue("TFI_TOTDES")
		Next nJ
	EndIf
Next nI
oMdlTemp:GoLine(1)

If nOpe <> MODEL_OPERATION_INSERT
	DbSelectArea("TFL")
	TFL->(DbSetOrder( 1 )) // TFL_FILIAL+TFL_CODIGO

	DbSelectArea("ABS")
	ABS->(DbSetOrder( 1 )) // ABS_FILIAL+ABS_LOCAL

	DbSelectArea("CXN")
	CXN->(dbSetOrder(2))


	For nItLocal := 1 To Len(aDadosLocais)

		lCheck	:= .F.
		TFL->(DbSeek(cFilTFL+aDadosLocais[nItLocal,nPosCodLoc]))
		aDadosLocais[nItLocal,nPosCodABS] := TFL->TFL_LOCAL

		ABS->(DbSeek(cFilABS+aDadosLocais[nItLocal,nPosCodABS]))
		aDadosLocais[nItLocal,nPosDesABS] := ABS->ABS_DESCRI

		CXN->(MSSeek(xFilial("CXN")+cContrato+cRevisa+TFL->TFL_PLAN))
		While CXN->( !Eof() ) .AND. CXN->CXN_NUMPLA == TFL->TFL_PLAN .AND. !lCheck
			If CXN->CXN_CHECK
				aDadosLocais[nItLocal,nPosCliente] := CXN->CXN_CLIENT
				aDadosLocais[nItLocal,nPosLoja] := CXN->CXN_LJCLI 
				lCheck	:= .T.
			EndIf
			CXN->( DbSkip() )
		EndDo
	Next nItLocal
EndIf
// atribui os valores ao modelo do resumo
oMdlTemp := oMdlGer:GetModel("TWBDETAIL")
For nI := 1 To oMdlTemp:Length()
	oMdlTemp:GoLine(nI)

	nItLocal := aScan( aDadosLocais, {|x| x[nPosCodLoc]== oMdlTemp:GetValue("TWB_CODTFL") } )
	If nItLocal > 0
		oMdlTemp:LoadValue("TWB_VLRRH",aDadosLocais[nItLocal,nPosRh])
		oMdlTemp:LoadValue("TWB_VLRMI",aDadosLocais[nItLocal,nPosMi])
		oMdlTemp:LoadValue("TWB_VLRMC",aDadosLocais[nItLocal,nPosMc])
		oMdlTemp:LoadValue("TWB_VLRLE",aDadosLocais[nItLocal,nPosLe])
		oMdlTemp:LoadValue("TWB_VLRMUL",aDadosLocais[nItLocal,nPosMul])
		oMdlTemp:LoadValue("TWB_VLRBON",aDadosLocais[nItLocal,nPosBon])
		oMdlTemp:LoadValue("TWB_VLRDES",aDadosLocais[nItLocal,nPosDes])
		If nOpe <> MODEL_OPERATION_INSERT
			oMdlTemp:LoadValue("TWB_DESABS", aDadosLocais[nItLocal,nPosDesABS])
			oMdlTemp:LoadValue("TWB_CLIENT", aDadosLocais[nItLocal,nPosCliente] )
			oMdlTemp:LoadValue("TWB_LOJA", aDadosLocais[nItLocal,nPosLoja] )
		EndIf

		oMdlTemp:LoadValue("TWB_TOTMED",At930TotRL(oMdlGer))
	Endif
Next nI
oMdlTemp:GoLine(1)

Return


Function At930TotRL(oModInfo)
Local nValorTot := 0
Local oModResLoc := Nil
Local nValMed := 0
Local nVlrMulta := 0
Local nVlrBoni := 0
Local nVlrDesc := 0

Default oModInfo := FwModelActive()
oModResLoc := oModInfo:GetModel("TWBDETAIL")

If oModInfo:GetId() == "TECA930"

	nValMed := oModResLoc:GetValue("TWB_VLRRH") + oModResLoc:GetValue("TWB_VLRMI") + oModResLoc:GetValue("TWB_VLRMC") + oModResLoc:GetValue("TWB_VLRLE") + oModResLoc:GetValue("TWB_IMPMED")
	nVlrMulta := oModResLoc:GetValue("TWB_VLRMUL")
	nVlrBoni := oModResLoc:GetValue("TWB_VLRBON")
	nVlrDesc := oModResLoc:GetValue("TWB_VLRDES")

	nValorTot := (nValMed - nVlrDesc + nVlrMulta - nVlrBoni)
EndIf

Return nValorTot

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At930MinDt()

@author 	Serviços
@since  	12/05/2016
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At930MinDt(cCodigo, lJoin)
Local cNewAlias	 := GetNextAlias()
Local dDtRemes	 := sTod("")
Default cCodigo := ""
Default lJoin	:= .T.

If !Empty(cCodigo)
	If lJoin
		BeginSql Alias cNewAlias

			SELECT MIN(F2_EMISSAO) EMISSAO
			  FROM %Table:TEW% TEW
			       INNER JOIN %Table:SC5% SC5 ON SC5.C5_FILIAL = %xFilial:SC5%
			                                 AND SC5.C5_NUM = TEW.TEW_NUMPED
			                                 AND SC5.%NotDel%
			       INNER JOIN %Table:SF2% SF2 ON SF2.F2_FILIAL = %xFilial:SF2%
			                                 AND SF2.F2_DOC = SC5.C5_NOTA
			                                 AND SF2.F2_SERIE = SC5.C5_SERIE
			                                 AND SF2.F2_CLIENTE = SC5.C5_CLIENTE
			                                 AND SF2.F2_LOJA = SC5.C5_LOJACLI
			                                 AND SF2.%NotDel%
			 WHERE TEW.TEW_FILIAL = %xFilial:TEW%
			   AND TEW.TEW_CODEQU = %Exp:cCodigo%
			   AND TEW.%NotDel%

		EndSql
	Else
		BeginSql Alias cNewAlias

			SELECT MIN(TEW.TEW_DTSEPA) EMISSAO
			  FROM %Table:TEW% TEW
			 WHERE TEW.TEW_FILIAL = %xFilial:TEW%
			   AND TEW.TEW_CODEQU = %Exp:cCodigo%
			   AND TEW.%NotDel%

		EndSql
	EndIf

	If (cNewAlias)->(!Eof())
		dDtRemes := (cNewAlias)->EMISSAO
	Endif

(cNewAlias)->(dbCloseArea())

Endif

Return dDtRemes

/*/{Protheus.doc}  PreLinTFZ()
	Valida se pode realizar a edição da linha de apuração do modo de cobrança de locação de equipamentos
@author 	Inovação Gestão de Serviços
@since  	16/09/2016
@version	P12
@param 		oModelGrid, Objeto FwFormGridModel, objeto da grid completo em edição
@param 		nLine, Numérico, número da linha sendo editada ou tentando ser editada
@param 		cAction, Caracter, código da ação sendo executada CANSETVALUE, SETVALUE, DELETELINE, UNDELETELINE
@return 	Lógico, determina se pode ou não editar a linha
/*/
Static Function PreLinTFZ(oModelGrid, nLine, cAction, cField)

Local lRet := .T.

If cAction == "CANSETVALUE" .And. oModelGrid:GetValue("TFZ_MODCOB") == "5"
	lRet := .F.
	Help(,,"PRELINTFZ",, STR0114,1,0,,,,,,;  // "Não é permitida a alteração quando o modo de cobrança é 5-Franquia/Excedente."
					{STR0115})  // "Altere o valor inserido como acréscimo/decréscimo na respectiva aba."
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At930CQtdC
Retorna o valor proporcional dentro de um periodo
@sample 	At930CQtdC(dDtParI,dDtContI,dDtParF,dDtContF)
@param		dDtParI  - Data inicial Informada no parametro
@param		dDtContI - Data Inicial do Orçamento
@param		dDtParF  - Data Final Informada no parametro
@param		dDtContF - Data Final do Orçamento
@return		nRet - Numerico
@since		09/09/2016
@author		Serviços
@version	P12
/*/
//------------------------------------------------------------------------------//
Static Function At930CQtdC(dDtParI,dDtContI,dDtParF,dDtContF)

Local nRet := 0
Local dDtIni	:= sTod("")
Local dDtFim	:= sTod("")

If dDtParI < dDtContI
	dDtIni := dDtContI
Else
	dDtIni := dDtParI
EndIf

If dDtParF > dDtContF
	dDtFim := dDtContF
Else
	dDtFim := dDtParF
EndIf

nRet := (dDtFim - dDtIni) + 1

Return nRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetVlrHoras
	Calcula a quantidade prevista para o período considera do último lançamento não apurado até a data final da apuração
@since		23/09/2016
@author	Inovação Gestão de Serviços
@version	P12
@return	nRet - Numerico quantidade prevista para uso pelo equipamento
@param 		cCodTFI, Caracter, código do item de locação sendo calculada a apuração
@param 		dDtIniTFI, Data, dia inicial do item de locação
@param 		dDtFimTFI, Data, dia final do item de locação
@param 		nQtdTFI, Numérico, quantidade de equipamentos para serem alocados no item
@param 		nQtdTEV, Numérico, quantidade de horas para "consumo" pelo itens de locação
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function GetVlrHoras( cCodTFI, dDtIniTFI, dDtFimTFI, nQtdTFI, nQtdTEV )
Local nQtPrevis := 0
Local nDifDiasLanc := 0
Local cAliasQry := GetNextAlias()
Local nTamFilTWT := AtTamFilTab( "TWT" )
Local cUltFilBas := ""
Local cUltBase := ""
Local dIniCalc := CTOD("")
Local dFimCalc := CTOD("")
Local lUltNaoApurado := .F.

BeginSQL Alias cAliasQry

	COLUMN TWT_DTMARC AS DATE

	SELECT TEW_FILIAL
		, TEW_CODEQU
		, TEW_FILBAT
		, TWT_CODAA3
		, TWT_DTMARC
		, TWT_HRMARC
		, TWT_CODMV
		, TWT_CODTFV
	FROM %Table:TEW% TEW
		LEFT JOIN %Table:TWT% TWT ON TWT_FILIAL = SUBSTRING( TEW_FILBAT, 1, %Exp:nTamFilTWT% )
								AND TWT_CODAA3 = TEW_BAATD
								AND TWT_CODMV = TEW_CODMV
								AND TWT.%NotDel%
	WHERE
		TEW_FILIAL = %xFilial:TEW%
		AND TEW_CODEQU = %Exp:cCodTFI%
		AND TEW.%NotDel%
	ORDER BY 2, 3, 4, 5, 6
EndSQL

While (cAliasQry)->(!EOF())

	If cUltFilBas == (cAliasQry)->TEW_FILBAT .And. cUltBase == (cAliasQry)->TWT_CODAA3
		//   caso seja a mesma base e o registro esteja apurado, troca a data inicial para
		// identificação do período não apurado
		If !Empty( (cAliasQry)->TWT_CODTFV )
			dIniCalc := (cAliasQry)->TWT_DTMARC
		EndIf
	Else
		//   calcula a quantidade de dias não apurados da base
		// quando percebe a troca da base ao percorrer o resultado da consulta
		// não soma dias quando só existe um registro para o equipamento (ou seja só existe a marcação da separação)
		If !Empty(cUltBase) .And. lUltNaoApurado .And. dFimCalc <> dIniCalc
			nDifDiasLanc += (dFimCalc - dIniCalc + 1 )
		EndIf
		// troca a base e a data de início
		cUltFilBas := (cAliasQry)->TEW_FILBAT
		cUltBase := (cAliasQry)->TWT_CODAA3
		dIniCalc := (cAliasQry)->TWT_DTMARC
	EndIf
	// sempre pega a data do registro pois pode ser o último
	dFimCalc := (cAliasQry)->TWT_DTMARC
	lUltNaoApurado := Empty((cAliasQry)->TWT_CODTFV)
	(cAliasQry)->(DbSkip())
End

//Calcula o último item que saiu pelo EOF
// não soma dias quando só existe um registro para o equipamento (ou seja só existe a marcação da separação)
If lUltNaoApurado .And. dFimCalc <> dIniCalc
	nDifDiasLanc += (dFimCalc - dIniCalc + 1)
EndIf

(cAliasQry)->(DbCloseArea())

// calcula o percentual que representa a quantidade de dias lançada e sem apuração
//  considerando os valores informados no contrato
nQtPrevis := ( nDifDiasLanc / ( ( dDtFimTFI - dDtIniTFI + 1 ) * nQtdTFI ) ) * nQtdTEV

Return nQtPrevis


//------------------------------------------------------------------------------
/*/{Protheus.doc} A930SldCNB
Retorna o saldo disponivel a ser medido de um item da CNB
autor: Matheus Lando Raimundo
/*/
//------------------------------------------------------------------------------//
Function A930SldCNB(cContra,cRevisa,cPlan,cItem,lRetDados,cProd,cDesc)
Local nRet 	:= 0
Local aArea	:= GetArea()

CNB->(DbSetOrder(1))

If CNB->(DbSeek(xFilial('CN9')+ cContra + cRevisa + cPlan + cItem))
	nRet := CNB->CNB_SLDMED * CNB->CNB_VLUNIT
	If lRetDados
		cProd := CNB->CNB_PRODUT
		cDesc := CNB->CNB_DESCRI
	EndIf
EndIf

RestArea(aArea)
Return nRet



//------------------------------------------------------------------------------
/*/{Protheus.doc} A930ViewCTR
View do Contrato

autor: Matheus Lando Raimundo

/*/
//------------------------------------------------------------------------------//
Function A930ViewCTR(lAutomato)
Local aArea	:= GetArea()
Local oModel	:= FwModelActive()
Local oTFVMaster := oModel:GetModel('TFVMASTER')

Default lAutomato := .F.

CN9->(DbSetOrder(1))
If CN9->(DbSeek(xFilial('CN9')+ oTFVMaster:GetValue('TFV_CONTRT') + oTFVMaster:GetValue('TFV_REVISA')))
	If !lAutomato
		FwExecView(STR0087,'VIEWDEF.CNTA301',MODEL_OPERATION_VIEW)  // 'Visualizar'
	EndIf
EndIf
RestArea(aArea)
Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} At930VldCNB
Valida o valor da CNB para medição e elimina os itens com saldo zerado para medição

@author: Matheus Lando Raimundo

/*/
//------------------------------------------------------------------------------//
Function At930VldCNB(aItem,aItemExc,aItnsRef,cCodTFL,cContra,cRevisa,cPlan, lAgrup)
Local lRet 		:= .T.
Local nI		:= 0
Local cProd		:= ""
Local cDesc		:= ""
Local nSldCNB	:= 0
Local cPict 	:= PesqPict("CNB","CNB_VLTOT")
Local nDecimal	:= X3Decimal("CNB_VLTOT")
Local cLocal	:= ""
Local aArea		:= GetArea()
Local cAviso	:= ""
Local nPos		:= 0
Local nVlrExc 	:= 0
Local aLinDel	:= {}
Local nLmtMed	:= 0
Local lVlPrPar	:= FindFunction("TecVlPrPar") .And. TecVlPrPar()
Local lCrn		:= FindFunction("TecBHasCrn") .AND. TecBHasCrn()
Local nVlrPriPr	:= 0
Local nPosPlan	:= 0
Local lCalcCrn	:= .F.
Local aLoadTGT	:= {}
Local nAux		:= 0
Local nX		:= 0
Default lAgrup	:= .F.

DbSelectArea("CNA")
CNA->(DbSetOrder(1)) //CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO

DbSelectArea("TFL")
TFL->(DbSetOrder(1))
If TFL->(DbSeek(xFilial('TFL')+cCodTFL))
	cLocal := TFL->TFL_LOCAL
	DbSelectArea("TFJ")
	TFJ->(DbSetOrder(1))
	If TFJ->(DbSeek(xFilial('TFJ')+TFL->TFL_CODPAI)) .And. TFJ->TFJ_CNTREC == "1"
		If lCrn
			If !EMPTY(Alltrim(STRTRAN(cMV_PAR04,"/"))) .AND. CNA->(DbSeek(xFilial("CNA") + TFJ->TFJ_CONTRT + TFJ->TFJ_CONREV + TFL->TFL_PLAN))
				aLoadTGT := TecBCrrTGT(CNA->(RECNO()), cMV_PAR04)
				If !EMPTY(aLoadTGT) .AND. (nAux := ASCAN(aLoadTGT, {|a| a[1] == cMV_PAR04})) > 0
					For nX := 1 To LEN(aLoadTGT[nAux][2])
						nVlrPriPr += aLoadTGT[nAux][2][nX][1]
					Next nX
					lCalcCrn := .T.
				EndIf
			EndIf
		EndIf
		If lVlPrPar .AND. !lCalcCrn
			nVlrPriPr := TFL->TFL_VLPRPA
		Endif
	EndIf
Endif
For nI := 1 To Len(aItem)
	nPosPlan := aScan( aItem[nI], {|x| x[1] == "PLAN" } )
	If nPosPlan > 0 .AND. aItem[nI,nPosPlan,2] <> cPlan
		Loop
	EndIf
		nSldCNB := A930SldCNB(cContra,cRevisa,cPlan,aItem[nI,1,2],.T.,@cProd,@cDesc)
		
		If nVlrPriPr <> 0 .And. nSldCNB <> nVlrPriPr
			nSldCNB := nVlrPriPr
		Endif
		
		nLmtMed := Cn121LtMed(nSldCNB,cContra,cRevisa,cPlan)

		If nLmtMed > 0
			nSldCNB := nLmtMed
		Endif

		If Round(aItem[nI,2,2],nDecimal) > Round(nSldCNB,nDecimal)
			lRet := .F.
			nValor := 	aItem[nI,2,2]
			If nPos := Ascan(aItemExc,aItem[nI,1,2]) > 0
				nVlrExc := aItemExc[nPos,2,2]
			EndIf

			cAba := aItnsRef[Ascan(aItnsRef, {|x| x[1] == aItem[nI,1,2]}),2]
			cAviso 	+=  STR0116 + Alltrim(cAba) +  CRLF  ;  // 'Aba: '
					+ STR0117 + Alltrim(cLocal) +  CRLF;  // 'Local: '
					+ STR0118 + Alltrim(cPlan) + CRLF ;  // 'Planilha: '
					+ STR0119 + Alltrim(cProd) + ' - ' + Alltrim(cDesc) +  CRLF;  // 'Produto: '
					+ STR0120 + Alltrim(Transform(aItem[nI,2,2],cPict)) + CRLF ;  // 'Valor item medição: '
					+ STR0121 + Alltrim(Transform(nSldCNB,cPict)) + CRLF;  // 'Saldo item contrato: '
					+ STR0122 + Alltrim(Transform(aItem[nI,2,2] - nSldCNB,cPict)) + CRLF + CRLF  // 'Diferença: '
		ElseIf lRet .And. nSldCNB == 0
			Aadd(aLinDel,nI)
		EndIf

Next nI

If lRet
	aSort( aLinDel, , , {|x,y| x > y })
	For nI := 1 To Len(aLinDel)
		Adel(aItem,aLinDel[nI])
		Asize(aItem,Len(aItem)-1)
	Next nI
EndIf


If !lRet
	AtShowLog(Alltrim(cAviso), STR0123, .T., .T., .T.,.F.)  // 'Valor de medição superior ao saldo do(s) item(ns) do contrato'
EndIf


RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At930GetQt
Retorna a quantidade das movimentações

@author: Matheus Lando Raimundo

/*/
//------------------------------------------------------------------------------//
Function At930GetQt(cCodTFI,dDataFim)
Local cQuery		:= ""
Local cAliasTEW	:= GetNextAlias()
Local aRet			:= {}


cQuery		:= "SELECT TEW_QTDVEN, TWI.TWI_DTSAI, TWP.TWP_DTRET "
cQuery		+= " FROM " + RetSQLName("TEW") + " TEW "
cQuery		+= " INNER JOIN " + RetSQLName("TWI") + " TWI ON "
cQuery		+= " TWI_FILIAL = '" + xFilial("TWI") + "' AND "
cQuery		+= " TWI.D_E_L_E_T_ <> '*' AND "
cQuery		+= " TWI.TWI_IDREG = TEW.TEW_CODMV AND "
cQuery		+= " TWI.TWI_LIBERA = '1' "
cQuery		+= " LEFT JOIN " + RetSQLName("TWP") + " TWP ON "
cQuery		+= " TWP_FILIAL = '" + xFilial("TWP") + "' AND "
cQuery		+= " TWP.D_E_L_E_T_ <> '*' AND "
cQuery		+= " TWP.TWP_IDREG = TEW.TEW_CODMV "
cQuery		+= " WHERE TEW_CODEQU = '" + cCodTFI + "' AND "
cQuery		+= " TEW_FILIAL = '" + xFilial("TEW")+"' AND "
cQuery		+= " TEW_QTDVEN > 0 AND "
cQuery		+= " TEW.TEW_DTRINI <= '"+DTOS(dDataFim)+"' AND "
cQuery		+= " TEW.D_E_L_E_T_ = ' ' "

cQuery		:= ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN",TcGenQry(,,cQuery), cAliasTEW, .T., .T.)

While (cAliasTEW)->(!Eof())
	Aadd(aRet,{(cAliasTEW)->(TEW_QTDVEN),(cAliasTEW)->(TWI_DTSAI),(cAliasTEW)->(TWP_DTRET)})
	(cAliasTEW)->(DbSkip())
EndDo


(cAliasTEW)->(DbCloseArea())

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetComplSc5
Retorna a quantidade das movimentações

autor: Cesar Bianchi

/*/
//------------------------------------------------------------------------------//
Static Function GetComplSc5(cCodLoc)
	Local aDataSC5 := {}
	Local aArea	:= GetArea()

	Default cCodLoc := ""

	//1* A partir do cod do local de atendimento, obtem a informação do C5_RECISS
	If !(Empty(cCodLoc))
		dbSelectArea('ABS')
		ABS->(dbSetOrder(1))
		If ABS->(dbSeek(xFilial('ABS') + Padr(cCodLoc,TamSx3('ABS_LOCAL')[1]) ))
			aAdd(aDataSC5,{"C5_RECISS",ABS->ABS_RECISS})
		EndIf
	EndIf

	//2* A partir do cod do local de atendimento, obtem a informação do C5_ESTPRES E C5_MUNPRES
	If !(Empty(cCodLoc))
		dbSelectArea('ABS')
		ABS->(dbSetOrder(1))
		If ABS->(dbSeek(xFilial('ABS') + Padr(cCodLoc,TamSx3('ABS_LOCAL')[1]) ))
			aAdd(aDataSC5,{"C5_ESTPRES",ABS->ABS_ESTADO})
			aAdd(aDataSC5,{"C5_MUNPRES",ABS->ABS_CODMUN})
		EndIf
	EndIf

	//3* Ponto de entrada para que campos de usuario ABS do cliente sejam direcionados para campos de usuario da SC5


	RestArea(aArea)
Return aDataSC5

//------------------------------------------------------------------------------
/*/{Protheus.doc}  GetMin(aDados)
Retorna a quantidade das movimentações

autor: Matheus Lando Raimundo

/*/
//------------------------------------------------------------------------------//
Function GetMin(aDados)

Asort(aDados)

Return aDados[1]

//------------------------------------------------------------------------------
/*/{Protheus.doc}  GetMax(aDados)

autor: Matheus Lando Raimundo

/*/
//------------------------------------------------------------------------------//
Function GetMax(aDados)

Asort(aDados)

Return aDados[Len(aDados)]
//------------------------------------------------------------------------------
/*/{Protheus.doc}  At930DscTp()
	Inicializador padrão da descrição do tipo de desconto.
Autor: Kaique Schiller Olivero

/*/
//------------------------------------------------------------------------------//
Function At930DscTp()
Local cTpDesc	:= TW6->TW6_TPDESC
Local cDescri 	:= ""

If !Empty(cTpDesc)
	DbSelectArea("CNP")
	CNP->(DbSetOrder(1))
	If !INCLUI .And. CNP->(DbSeek(xFilial("CNP")+cTpDesc))
		cDescri := CNP->CNP_DESCRI
	Endif
	CNP->(DbCloseArea())
Endif

Return cDescri


//------------------------------------------------------------------------------
/*/{Protheus.doc}  At930CntRec()
	Rotina para tratamentos de contrato recorrente ao selecionar o contrato no  TEC930.
@author Kaique Schiller Olivero

/*/
//------------------------------------------------------------------------------//
Function At930CntRec(cAcao)
Local aArea			:= GetArea()
Local lRet 			:= .T.
Local cContr		:= MV_PAR01
Local cRevis 		:= ""

If !Empty(cContr)
	cRevis := Posicione("CN9",7,xFilial("CN9")+cContr+"05","CN9_REVISA")
	DbSelectArea("TFJ")
	TFJ->(DbSetOrder(5)) //TFJ_FILIAL+TFJ_CONTRT+TFJ_CONREV
	If TFJ->(DbSeek(xFilial("TFJ")+cContr+cRevis))
		If TFJ->TFJ_CNTREC == "1" .AND. !(lMedExt)
			If cAcao == "1"
				MV_PAR02 := FirstDate(dDataBase)
				MV_PAR03 := LastDate(dDataBase)
				MV_PAR04 := SubStr(cValTochar(dDataBase),4,2)+"/"+SubStr(cValTochar(dDataBase),7,4)
			Elseif cAcao == "2"
				If !Empty(MV_PAR04)
					MV_PAR02 := FirstDate(Ctod("01/"+MV_PAR04))
					MV_PAR03 := LastDate(Ctod("01/"+MV_PAR04))
				Endif
			Elseif cAcao == "3"
				If !Empty(MV_PAR04)
					If Len(SubStr(cValTochar(MV_PAR04),1,2)) == 2 .And. Len(SubStr(cValTochar(MV_PAR04),4,4)) == 4;
																  .And. Val(SubStr(cValTochar(MV_PAR04),1,2)) >= 1;
																  .And. Val(SubStr(cValTochar(MV_PAR04),1,2)) <= 12
						MV_PAR02 := FirstDate(Ctod("01/"+MV_PAR04))
						MV_PAR03 := LastDate(Ctod("01/"+MV_PAR04))
					Else
						lRet := .F.
						Help( "", 1, "At930CntRec", , STR0131, 1, 0,,,,,,;  //"Vigência inválida."
						{STR0132}) // "Informe a vigência corretamente."
					Endif
				Else
					lRet := .F.
					Help( "", 1, "At930CntRec", , STR0133, 1, 0,,,,,,;  //"É necessário informar uma data de vigência para contrato recorrente."
					{STR0132}) // "Informe a vigência corretamente."
				Endif
			Endif
		Else
			MV_PAR04 := ""
		Endif
	Endif
Endif

RestArea(aArea)

Return lRet

/*/{Protheus.doc} At934IsFAnt
@description 	Verifica se um contrato está indicado como faturamento antecipado.
@author 		josimar.assuncao
@since 			20.04.2017
@param 			cContrato, caracter, número do contrato.
@return 		Lógico, indica se o contrato está indicado como faturamento antecipado.
/*/
Static Function At934IsFAnt( cContrato )
Local lRet 			:= .F.
Local cRevisao 		:= Posicione("CN9",7,xFilial("CN9")+cContrato+"05","CN9_REVISA")

// TFJ_FILIAL+TFJ_CONTRT+TFJ_CONREV
lRet := (Posicione( "TFJ", 5, xFilial("TFJ")+cContrato+cRevisao, "TFJ_ANTECI" ) == "1" )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} TEC930autG
@description 	Altera Static de isInCallStack
@author 		Mateus Boiani
@since 			21/02/2018
/*/
//---------------------------------------------------------------------
Function TEC930autG(lSetValue)
If VALTYPE(lSetValue) == 'L'
	lat930autG := lSetValue
EndIf
Return lat930autG

//---------------------------------------------------------------------
/*/{Protheus.doc} At930SelCp
@description 	Exibe uma janela de seleção de competência
@author 		Mateus Boiani
@since 			14/11/2018
/*/
//---------------------------------------------------------------------
Function At930SelCp(aCmboCmp, oCNDMaster, lAgrup, aPlan)
Local oDlg			:= Nil
Local oOk			:= Nil
Local oCombo		:= Nil
Local aArea		:= GetArea()
Local cCmboCmp	:= ""
Local lRet			:= .T.
Local lOk			:= .F.
Local lAuto		:= isBlind()
Local cLocal		:= ""
Local nRetCNF := 0
Local nSlimit := 0
Local cAliasCnf := GetNextAlias()
Local cCronog := ""
Local cParcela := ""
Local cPict 		:= PesqPict("CNB","CNB_VLTOT")
Local cProxMed := ""
Local cAutoOpc := ""
Local aMedRecorr := {}
Local lReplica	:= .F.
Local cIniMed	:= ""
Local cFimMed	:= ""
Local nX		:= 0
Local aAuxCp	:= {}
Local nPosAux	:= 0
Local aCompPrc	:= at930GProc()
Local cWhere	:= "%%"
Local lApuAgil	:= FWIsInCallStack("At930ApuAg")
Local lMonitor	:= FWIsInCallStack("ApurJobAux")

Default lAgrup	:= .F.

If !HasMedEven( aCloneCab[2], aCloneCab[3] ) .OR. lApuAgil .Or. lMonitor
	If !lAuto .OR. isInCallStack("TECA930") .Or. lMonitor
		If lApuAgil .Or. lMonitor
			cCmboCmp := AllTrim(At930AStaCo())
			lOk	:= .T.
		Else
			If !EMPTY(aCloneCab) .AND. VALTYPE(aCloneCab[1]) == 'C'
				cLocal	:= aCloneCab[1]
			EndIf

			If !aCloneCab[6]
				If lAgrup
					cWhere := "% GROUP BY CNA.CNA_PROMED, CNA.CNA_DTINI, CNA.CNA_DTFIM %"
				Else
					cWhere := "% AND CNA.CNA_NUMERO = '" + aCloneCab[4] + "' %"
				EndIf
				BeginSQL Alias "CNATMP"
					SELECT CNA.CNA_PROMED, CNA.CNA_DTINI, CNA.CNA_DTFIM
					FROM  %Table:CNA% CNA
					WHERE CNA.CNA_FILIAL = %xFilial:CNA% AND CNA.CNA_CONTRA = %Exp:aCloneCab[2]% AND
															CNA.CNA_REVISA = %Exp:aCloneCab[3]% AND
															CNA.CNA_PERIOD <> ' ' AND CNA.%NotDel%
															%exp:cWhere%
				EndSQL

				While !CNATMP->(EOF())
					cProxMed := Dtoc(Stod(CNATMP->CNA_PROMED))
					cProxMed := Substr(cProxMed,4)

					cIniMed := Dtoc(Stod(CNATMP->CNA_DTINI))
					cIniMed := Substr(cIniMed,4)
					
					cFimMed := Dtoc(Stod(CNATMP->CNA_DTFIM))
					cFimMed := Substr(cFimMed,4)

					If ( nPosProMed := aScan(aCmboCmp,{ |x| RIGHT(x,7) == cProxMed }) ) > 0
						cAutoOpc := cValToChar(nPosProMed)
						AADD(aMedRecorr, aCmboCmp[nPosProMed])
					EndIF

					CNATMP->(dbSkip())
				EndDo
				CNATMP->(dbCloseArea())
			EndIf

			If !EMPTY(aMedRecorr)
				aCmboCmp := aCLONE(aMedRecorr)
			Else

			If lAgrup
				cWhere := "%%"
			Else
				cWhere := "% AND CNA.CNA_NUMERO = '" + aCloneCab[4] + "' %"
			EndIf
				BeginSQL Alias "CNATMP"
					SELECT CNA.CNA_DTINI, CNA.CNA_DTFIM
					FROM  %Table:CNA% CNA
					WHERE CNA.CNA_FILIAL = %xFilial:CNA% AND CNA.CNA_CONTRA = %Exp:aCloneCab[2]% AND
																CNA.CNA_REVISA = %Exp:aCloneCab[3]%
																AND CNA.%NotDel% 
																%exp:cWhere%
																
				EndSQL

				If !CNATMP->(EOF())
					cIniMed := Dtoc(Stod(CNATMP->CNA_DTINI))
					cIniMed := Substr(cIniMed,4)
					
					cFimMed := Dtoc(Stod(CNATMP->CNA_DTFIM))
					cFimMed := Substr(cFimMed,4)

					CNATMP->(dbSkip())
					CNATMP->(dbCloseArea())
				EndIf

				If Len(aCmboCmp) > 1
					For nX := 1 to Len(aCmboCmp)
						If RIGHT(aCmboCmp[nX],4) > RIGHT(cIniMed,4) //Verifica o ano da competencia
							aAdd(aAuxCp,aCmboCmp[nX])
						Else	
							If RIGHT(aCmboCmp[nX],7) >= cIniMed
								aAdd(aAuxCp,aCmboCmp[nX])
							EndIf
						EndIf		
					Next nX
					aCmboCmp := aClone(aAuxCp)
				EndIf
			EndIf

			If !Empty(aCompPrc)
				lReplica := aCompPrc[1][1]
				If !EMPTY(aMedRecorr)
					nPosAux := aScan(aCompPrc[1][2],{|x| RIGHT(aMedRecorr[1],7) == x[1] })
				Else
					nPosAux := aScan(aCompPrc[1][2],{|x| cIniMed >= x[1] .AND. cFimMed <= x[2]  })
				EndIf
			EndIf
			If !lReplica .OR. ( !Empty(aCompPrc) .AND. !Empty(aCompPrc[1][2]) .AND. nPosAux == 0 ) 
				Define MsDialog oDlg TITLE STR0050 FROM 000, 000 To 200, 200 Pixel Style 128

					oOk  := LoadBitMap(GetResources(), "LBOK")
					oEsc := LoadBitMap(GetResources(), "LBNO")
					@ 001,020 SAY STR0051 + cLocal OF oDlg PIXEL SIZE 120,9 // "Local x Orçamento:"
					@ 020,020 SAY STR0052 OF oDlg PIXEL SIZE 80,9 // "Selecione a Competência:"
					@ 035,020 COMBOBOX oCombo VAR cCmboCmp ITEMS aCmboCmp OF oDlg SIZE 60,10 PIXEL
					@ 060,020 Button oOk  Prompt STR0035 Of oDlg Size 60, 010 Pixel //"Ok"
					@ 075,020 Button oEsc Prompt STR0191 Of oDlg Size 60, 010 Pixel //"Cancelar"
					oOk:bAction := { || lOk := .T., oDlg:End() }
					oEsc:bAction := { || lRet := .F.,lOk := .F., oDlg:End() }

				Activate MsDialog oDlg Centered
			Else
				lOk := .T.
			EndIf
			
			If EMPTY(aCompPrc)			
				If lMsgRpl 
					lReplica:= lAgrup .OR. MsgYesNo(STR0185)  //"Deseja replicar a sua escolha para todos os locais com as mesmas caracteristicas?"
				EndIf
				aAdd(aCompPrc,{ lReplica,{} })
				If !EMPTY(aMedRecorr)
					aAdd(aCompPrc[1][2],{RIGHT(aMedRecorr[1],7), "", cCmboCmp})
				Else
					aAdd(aCompPrc[1][2],{cIniMed, cFimMed, cCmboCmp})
				EndIf
			Else 
				If nPosAux > 0
					cCmboCmp := aCompPrc[1][2][nPosAux][3]
				Else
					If !EMPTY(aMedRecorr)
						aAdd(aCompPrc[1][2],{RIGHT(aMedRecorr[1],7), "", cCmboCmp})
					Else
						aAdd(aCompPrc[1][2],{cIniMed, cFimMed, cCmboCmp})
					EndIf
				EndIf
			EndIf
			
			If !EMPTY(cAutoOpc) .AND. !lAgrup
				cCmboCmp := cAutoOpc
			EndIf
		EndIf
		If !EMPTY(cCmboCmp) .AND. lOk
			lRet := oCNDMaster:SetValue("CND_RCCOMP",cCmboCmp)
		EndIf
	Else
		lRet := oCNDMaster:SetValue("CND_RCCOMP","1")
	EndIf
EndIf

If lRet

	If lAgrup
		cWhere := "%%"
	Else
		cWhere := "% AND CNF.CNF_NUMPLA = '" + aCloneCab[4] + "' %"
	EndIf

	BeginSql Alias cAliasCnf

		SELECT CNF.CNF_NUMERO , CNF.CNF_PARCEL
		  FROM %table:CNF% CNF
		 WHERE CNF.CNF_FILIAL = %xFilial:CNF%
		   AND CNF.CNF_CONTRA = %Exp:aCloneCab[2]%
		   AND CNF.CNF_REVISA = %Exp:aCloneCab[3]%
		   AND CNF.CNF_COMPET = %Exp:oCNDMaster:GetValue("CND_COMPET")%
		   AND CNF.%NotDel%
		   %exp:cWhere%
	EndSql

	If !(cAliasCnf)->(EOF())
		cCronog := (cAliasCnf)->(CNF_NUMERO)
		cParcela := (cAliasCnf)->(CNF_PARCEL)

		If lRet
			lRet := ChkCNASld(aCloneCab[2],aCloneCab[3],aCloneCab[4],aCloneCab[5], aPlan)
		EndIf

		If lRet .AND. aCloneCab[6] .And. !At930VldSld(aCloneCab[2],;
												aCloneCab[3],;
												cCronog,;
												oCNDMaster:GetValue("CND_COMPET"),;
												aCloneCab[5],;
												aCloneCab[7],;
												aCloneCab[8],;
												aCloneCab[9],;
												aCloneCab[10],;
												aCloneCab[11],;
												cParcela,;
												@nRetCNF,;
												@nSlimit,;
												aPlan)

			Help(,,'AT930At930SelCp',,STR0070 + CRLF + CRLF + STR0071+ CRLF  + CRLF +  ;
						IIF(lAgrup, STR0186, sSTR0182)+" " + IIF(lAgrup, aCloneCab[2],aCloneCab[4]) + CRLF +; //	"Contrato" ##  Planilha
						STR0175+" " + Alltrim(Transform(aCloneCab[5] - aCloneCab[9] +  aCloneCab[10] - aCloneCab[11],cPict))+ CRLF+; //"Valor de medição:"
						STR0176+" " + Alltrim(Transform(nSlimit,cPict)) + CRLF +; //"Saldo da competência:"
						STR0181+" " + Alltrim(Transform(nRetCNF,cPict)) + CRLF +; //"Saldo da competência considerando o limite:"
						STR0177+" " + Alltrim(Transform((aCloneCab[5] - aCloneCab[9] +  aCloneCab[10] - aCloneCab[11]) - nRetCNF,cPict)),1,0) //"Diferença:"
						//"Valor total de medição não previsto no cronograma."+CRLF+"O mesmo deve ser reestruturado."
			lRet:= .F.
		EndIf
	EndIf
	(cAliasCnf)->(DbCloseArea())
Else
	If lOk
		//"Não foi possível selecionar a competência a ser apurada. Por favor, repita a operação utilizando a rotina Nova Medição (CNTA121)"
		Help(,,'AT930At930SelCp',,STR0174,1,0)
	EndIf
EndIf


RestArea(aArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} ChkCNASld
@description 	Verifica se o total apurado supera o saldo da planilha

@return			lRet, bool, .T. se o saldo for maior que o total apurado

@author 		Mateus Boiani
@since 			07/12/2018
/*/
//---------------------------------------------------------------------
Static Function ChkCNASld(cContra, cRev, cPlan, nValMed, aPlan)
Local aArea := GetArea()
Local cAliasQry	:= GetNextAlias()
Local lRet := .T.
Local nPlan := 0
Local cWhere := ""
Local nPosMed := 0

Default cPlan := ""

If Empty(cPlan)
	cWhere := "%%"
Else
	cWhere := "% AND CNA.CNA_NUMERO = '" + cPlan + "' %"
EndIf
BeginSQL Alias cAliasQry
	SELECT  CNA.CNA_SALDO, CNA.CNA_NUMERO
	FROM %Table:CNA% CNA
WHERE
	CNA.CNA_FILIAL = %xFilial:CNA% AND
	CNA.CNA_CONTRA = %Exp:cContra% AND
	CNA.CNA_REVISA = %Exp:cRev% AND
	CNA.%notDel%
	%exp:cWhere%
EndSql

While (cAliasQry)->(!EOF())
	nPlan := (cAliasQry)->CNA_SALDO
	If Empty(cPlan)
		nPosMed := ASCAN( aPlan, {|x|  x[2] == (cAliasQry)->CNA_NUMERO})
		nValMed := aPlan[nPosMed][4]
	EndIf
	lRet := nPlan >= nValMed
	If !lRet
		Exit
	EndIf
	(cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->(DbCloseArea())

RestArea(aArea)

If !lRet
	Help(,,'AT930ChkSld',, STR0178 + "(" + cValtoChar(nValMed) + ")" + STR0179 + "(" + cValtoChar(nPlan) + ")",1,0)
	//"O valor apurado " ## " supera o saldo da planilha "
EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} At30MatEnc
@description 	Retorna se um Local de atendimento ou item de RH esta encerrado
@return			lRet
@author 		Matheus Lando Raimundo
@since 			07/12/2018
/*/
//---------------------------------------------------------------------
Function At30MatEnc(cCod)
Local lRet 		:= .F.
Local lOrcPrc   := SuperGetMv('MV_ORCPRC',.F.,.F.)
Local aArea 	:= Nil

If lOrcPrc
	aArea := TFL->(GetArea())
	lRet := Posicione("TFL",1,xFilial("TFL")+cCod,"TFL_ENCE") == "1"
Else
	aArea := TFF->(GetArea())
	lRet := Posicione("TFF",1,xFilial("TFF")+cCod,"TFF_ENCE") == "1"
EndIf
RestArea(aArea)


Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} at930CProc()
@description 	Limpa a variável estática aCompProc
@author 		Diego Bezerra
@since 			24/06/2020
/*/
//---------------------------------------------------------------------
Function at930CProc()
aCompProc := {}
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} at930GProc()
@description 	Retorna a variável estática aCompProc
@author 		Diego Bezerra
@since 			24/06/2020
/*/
//---------------------------------------------------------------------
Function at930GProc()
Return aCompProc

//---------------------------------------------------------------------
/*/{Protheus.doc} At930TotHr() 
@description 	Total de horas sem OS
@author 		Kaique SChiller
@since 			07/07/2020
/*/
//---------------------------------------------------------------------
Static Function At930TotHr(cCodABB,lHrExtr)
Local cAliasABB := ""
Local nTotRet	:= 0
Local cQuery	:= ""

cQuery := " SELECT ABB.ABB_HRTOT, COALESCE(ABR.ABR_TEMPO,'') ABR_TEMPO "
cQuery += " FROM " + RetSQLName("ABB") + " ABB "
cQuery += " LEFT JOIN " + RetSQLName("ABR") + " ABR ON "
cQuery += " ABR.ABR_FILIAL = '" + xFilial("ABR") + "' "
cQuery += " AND ABR.ABR_AGENDA = ABB.ABB_CODIGO "
cQuery += " AND ABR.D_E_L_E_T_ = ' ' "
cQuery += " WHERE ABB.ABB_CODIGO = '"+cCodABB+"' "
cQuery += " AND ABB.ABB_FILIAL = '" + xFilial("ABB")+"' "
cQuery += " AND ABB.ABB_CHEGOU = 'S' "
cQuery += " AND ABB.ABB_ATENDE = '1' "
cQuery += " AND ABB.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

cAliasABB := GetNextAlias()

DbUseArea(.T., "TOPCONN",TcGenQry(,,cQuery), cAliasABB, .T., .T.)

While (cAliasABB)->(!Eof())
	If lHrExtr
		If !Empty((cAliasABB)->ABR_TEMPO)
			nTotRet += Round(HoraToInt(SubStr((cAliasABB)->ABB_HRTOT,6,10)),2)
		Endif
	Else
		If Empty((cAliasABB)->ABR_TEMPO)
			nTotRet += Round(HoraToInt(SubStr((cAliasABB)->ABB_HRTOT,6,10)),2)
		Else 
			nTotRet += Round(HoraToInt(SubStr((cAliasABB)->ABB_HRTOT,6,10)),2)
		Endif		
	Endif
	(cAliasABB)->(dbSkip())
EndDo

(cAliasABB)->(DbCloseArea())

Return nTotRet

//---------------------------------------------------------------------
/*/{Protheus.doc} At930GerOs()
@description Geração de OS	
@author 		Kaique SChiller
@since 			09/07/2020
/*/
//---------------------------------------------------------------------
Function At930GerOs()

Return SuperGetMV("MV_GSGEROS",.F.,"1") == "1" .Or. ABB->( ColumnPos('ABB_ITAPUR') ) == 0

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930CliLo
@description  Retorna a loja utilizada na CNC
@return cRet
@author Augusto Albuquerque
@since  14/10/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930CliLo()
Local oModel	:= FwModelActive()
Local cContrato	:= oModel:GetValue("TFVMASTER","TFV_CONTRT")
Local cRevisa	:= oModel:GetValue("TFVMASTER","TFV_REVISA")
Local cClient	:= oModel:GetValue("TWBDETAIL","TWB_CLIENT")
Local cRet		:= ""

cRet := Posicione("CNC",3,xFilial("CNC")+cContrato+cRevisa+cClient,"CNC_LOJACL")

Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930VlCLo
@description  Retorna se existe o cliente/loja na CNC
@return lRet
@author Augusto Albuquerque
@since  14/10/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930VlCLo( oMdlTWB, cCampo, xValue )
Local oModel	:= oMdlTWB:GetModel()
Local cContrato	:= oModel:GetValue("TFVMASTER","TFV_CONTRT")
Local cRevisa	:= oModel:GetValue("TFVMASTER","TFV_REVISA")
Local cClient	:= ""
Local lRet		:= .T.

DbSelectArea("CNC")
CNC->(dbSetOrder(3))

If cCampo == 'TWB_LOJA'
	cClient := oMdlTWB:GetValue("TWB_CLIENT")
	lRet := CNC->(MSSeek(xFilial("CNC")+cContrato+cRevisa+cClient+xValue))
Else
	lRet := CNC->(MsSeek(xFilial("CNC")+cContrato+cRevisa+xValue))
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930Fora
@description Chamada para quando Medição\Apuração por fora do contrato
@return Nil
@author Matheus Gonçalves
@since  28/10/2020
/*/
//-------------------------------------------------------------------------------------------------------------------
Function At930Fora(nOperacao)

MsgRun( STR0074, STR0073, {|| FWExecView(STR0002,"VIEWDEF.TECA930",nOperacao,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/) } ) // 'Processando Apuração  ' #### 'Aguarde...' #### "Geração"

Return(Nil)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930Exce
@description Apuração de Excedentes
@return Nil
@author mateus Boiani
@since  11/10/2021
/*/
//-------------------------------------------------------------------------------------------------------------------
Function At930Exce(nOperacao)
lMedExce := .T.
MsgRun( STR0074, STR0073, {|| FWExecView(STR0002,"VIEWDEF.TECA930",nOperacao,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/) } ) // 'Processando Apuração  ' #### 'Aguarde...' #### "Geração"
lMedExce := .F.
Return(Nil)
//---------------------------------------------------------------------
/*/{Protheus.doc} At930GrCnt
@description 	Altera Static de isInCallStack
@author 		Mateus Boiani
@since 			21/02/2018
/*/
//---------------------------------------------------------------------
Function At930GrCnt(aDocs, oMdlCnt121)
Default aDocs := {}
If !EMPTY(aDocs)
 	If ExistBlock("AT930PVG")
		ExecBlock("AT930PVG",.F.,.F.,{aDocs})
	EndIf
EndIf

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930ApuAg
@description Função para saber qual view abrir de acordo com o campo da apuração AGIL, operação Insert
@return Nil
@author Augusto Albuquerque
@since  25/11/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930ApuAg()
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0193},;
			 	   {.T.,STR0192},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Salvar" ## "Fechar"
					
If TecMedAgil()
	FWExecView("","VIEWDEF.TECA930A", MODEL_OPERATION_INSERT,,,,,aButtons)
Else
	Help(,,'At930ApuAg',,STR0196,1,0) //"Para usar a opção por favor crie os campos TFV_MEDAGI e TFV_AGRUP."
EndIf
Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930MoApu
@description Função para saber qual view abrir de acordo com o campo da apuração AGIL, operação Insert
@return Nil
@author Augusto Albuquerque
@since  25/11/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930MoApu()
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
			 	   {.T.,STR0192},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Incluir" ## "Fechar"
					
If TecMedAgil()
	FWExecView("","VIEWDEF.TECA930B", MODEL_OPERATION_INSERT,,,,,aButtons)
Else
	Help(,,'At930MoApu',,STR0196,1,0) //"Para usar a opção por favor crie os campos TFV_MEDAGI e TFV_AGRUP."
EndIf
Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT930View
@description Função para saber qual view abrir de acordo com o campo da apuração AGIL, operação visualizar
@return Nil
@author Augusto Albuquerque
@since  25/11/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT930View()
Local lApuAgil	:= .F. 
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
			 	   {.T.,STR0192},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} // "Fechar"

If TecMedAgil()
	lApuAgil := TFV->TFV_MEDAGI == "1"
EndIf

If lApuAgil
	FWExecView(STR0002,"VIEWDEF.TECA930A",MODEL_OPERATION_INSERT,,,,,aButtons, { |oModel| At930BCanc(oModel)})
Else
	FWExecView(STR0002,"VIEWDEF.TECA930",MODEL_OPERATION_VIEW,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)
EndIf

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT930Estor
@description Função para saber qual view abrir de acordo com o campo da apuração AGIL, operação delete(Estorno)
@return Nil
@author Augusto Albuquerque
@since  25/11/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT930Estor(cAlias, nReg, nOpc, lAutomato)
Local lApuAgil	:= .F. 
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0194},;
			 	   {.T.,STR0192},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirma" ## "Fechar"

If TecMedAgil()
	lApuAgil := TFV->TFV_MEDAGI == "1"
EndIf

If lApuAgil
	FWExecView(STR0002,"VIEWDEF.TECA930A",MODEL_OPERATION_INSERT,,,,,aButtons, { |oModel| At930BCanc(oModel)})
Else
	At930GerMed(cAlias, nReg, nOpc, lAutomato)
EndIf

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930IsBld
@description  Retorna se a tela está ativa.
@return IsBlindRb
@author Kaique Schiller
@since  22/10/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930IsBld()
Return IsBlindRb

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930BCanc
@description Função para mudar a operação de insert para visualização ao clicar no botão "fechar"
@return IsBlindRb
@author Kaique Schiller
@since  22/10/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930BCanc( oMdl930A )
oMdl930A:nOperation := MODEL_OPERATION_VIEW
Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930MeTCV
@description Função que verifica se existe os campos TCV_ALIAS, TCV_PRODPV e TCV_CODITE no dicionario.
@author Augusto Albuquerque
@since  18/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930MeTCV()
Return TCV->( ColumnPos('TCV_ALIAS') ) > 0 .AND. TCV->( ColumnPos('TCV_CODITE') ) > 0 .AND. TCV->( ColumnPos('TCV_PRODPV') ) > 0

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TotRhItens
@description Função que retorna quantidade de itens no contrato
@author Augusto Albuquerque
@since  01/06/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function TotRhItens(cContrato, cRevCtr, lMedExt)
Local cAliasTFF := GetNextAlias()
Local cQuery	:= ""
Local nRet		:= 0

cQuery := ""
cQuery += " SELECT COUNT(TFF.TFF_COD) TOTAL "
cQuery += " FROM " + RetSqlName("TFF") + " TFF "
cQuery += " INNER JOIN " + RetSqlName("TFL") + " TFL "
cQuery += " ON TFL.TFL_CODIGO = TFF.TFF_CODPAI "
cQuery += " AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
cQuery += " AND TFL.D_E_L_E_T_ = ' ' "
cQuery += " WHERE "
cQuery += " TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
cQuery += " AND TFF.D_E_L_E_T_ = ' ' "
If lMedExt
	cQuery += "AND TFL.TFL_CONTRT = '" + MV_PAR01 + "' "
	cQuery += "AND TFL.TFL_CONREV = '" + cRevCtr + "' "
	cQuery += "AND TFF.TFF_COBCTR = '2' AND TFF.TFF_PRCVEN > 0"
Else
	cQuery += "AND TFF.TFF_CONTRT = '" + MV_PAR01 + "' "
	cQuery += "AND TFF.TFF_CONREV = '" + cRevCtr + "' "
 	cQuery += "AND TFF.TFF_COBCTR <> '2' AND TFF.TFF_PRCVEN > 0"
EndIf

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTFF,.T.,.T.)

If (cAliasTFF)->(!Eof())
	nRet := (cAliasTFF)->TOTAL
EndIf

(cAliasTFF)->(dbCloseArea())
Return nRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TotMIItens
@description Função que retorna quantidade de itens no contrato
@author Augusto Albuquerque
@since  01/06/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function TotMIItens(cContrato, cRevCtr, lMedExt)
Local cAliasTFG := GetNextAlias()
Local cQuery	:= ""
Local lTabPre	:= SuperGetMv("MV_ORCPRC",, .F. )
Local nRet		:= 0

cQuery := ""
cQuery += " SELECT COUNT(TFG.TFG_COD) TOTAL "
cQuery += " FROM " + RetSqlName("TFG") + " TFG "
If !lTabPre
	cQuery += " INNER JOIN " + RetSqlName("TFF") + " TFF "
	cQuery += " ON TFF.TFF_COD = TFG.TFG_CODPAI "
	cQuery += " AND TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
	cQuery += " AND TFF.D_E_L_E_T_ = ' ' "
EndIf
cQuery += " INNER JOIN " + RetSqlName("TFL") + " TFL "
If lTabPre
	cQuery += " ON TFL.TFL_CODIGO = TFG.TFG_CODPAI "
Else
	cQuery += " ON TFL.TFL_CODIGO = TFF.TFF_CODPAI "
EndIf
cQuery += " AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
cQuery += " AND TFL.D_E_L_E_T_ = ' ' "
cQuery += " WHERE "
cQuery += " TFG.TFG_FILIAL = '" + xFilial("TFG") + "' "
cQuery += " AND TFG.D_E_L_E_T_ = ' ' "
If lMedExt
	cQuery += "AND TFL.TFL_CONTRT = '" + cContrato + "' "
	cQuery += "AND TFL.TFL_CONREV = '" + cRevCtr + "' "
	cQuery += "AND TFG.TFG_COBCTR = '2' AND TFG.TFG_PRCVEN > 0"
Else
	cQuery += "AND TFL.TFL_CONTRT = '" + cContrato + "' "
	cQuery += "AND TFL.TFL_CONREV = '" + cRevCtr + "' "
 	cQuery += "AND TFG.TFG_COBCTR <> '2' "
EndIf

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTFG,.T.,.T.)

If (cAliasTFG)->(!Eof())
	nRet := (cAliasTFG)->TOTAL
EndIf

(cAliasTFG)->(dbCloseArea())
Return nRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TotMCItens
@description Função que retorna quantidade de itens no contrato
@author Augusto Albuquerque
@since  01/06/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function TotMCItens(cContrato, cRevCtr, lMedExt)
Local cAliasTFH := GetNextAlias()
Local cQuery	:= ""
Local lTabPre	:= SuperGetMv("MV_ORCPRC",, .F. )
Local nRet		:= 0

cQuery := ""
cQuery += " SELECT COUNT(TFH.TFH_COD) TOTAL "
cQuery += " FROM " + RetSqlName("TFH") + " TFH "
If !lTabPre
	cQuery += " INNER JOIN " + RetSqlName("TFF") + " TFF "
	cQuery += " ON TFF.TFF_COD = TFH.TFH_CODPAI "
	cQuery += " AND TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
	cQuery += " AND TFF.D_E_L_E_T_ = ' ' "
EndIf
cQuery += " INNER JOIN " + RetSqlName("TFL") + " TFL "
If lTabPre
	cQuery += " ON TFL.TFL_CODIGO = TFH.TFH_CODPAI "
Else
	cQuery += " ON TFL.TFL_CODIGO = TFF.TFF_CODPAI "
EndIf
cQuery += " AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
cQuery += " AND TFL.D_E_L_E_T_ = ' ' "
cQuery += " WHERE "
cQuery += " TFH.TFH_FILIAL = '" + xFilial("TFH") + "' "
cQuery += " AND TFH.D_E_L_E_T_ = ' ' "
If lMedExt
	cQuery += "AND TFL.TFL_CONTRT = '" + cContrato + "' "
	cQuery += "AND TFL.TFL_CONREV = '" + cRevCtr + "' "
	cQuery += "AND TFH.TFH_COBCTR = '2' AND TFH.TFH_PRCVEN > 0"
Else
	cQuery += "AND TFL.TFL_CONTRT = '" + cContrato + "' "
	cQuery += "AND TFL.TFL_CONREV = '" + cRevCtr + "' "
 	cQuery += "AND TFH.TFH_COBCTR <> '2' "
EndIf

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTFH,.T.,.T.)

If (cAliasTFH)->(!Eof())
	nRet := (cAliasTFH)->TOTAL
EndIf

(cAliasTFH)->(dbCloseArea())
Return nRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT930SPAR4
@description Criada para utilização do MV_PAR04, para substituir oMdlMed:GetValue("CNDMASTER","CND_COMPET") na função TecMedPrRa
@author Natacha Romeiro
@since  26/08/2021 
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT930SPAR4(cCompet)
cMV_PAR04 := cCompet
Return Nil

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT930GPAR4
@description Criada para retonar MV_PAR04
@author Natacha Romeiro
@since  26/08/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT930GPAR4()
Return cMV_PAR04 

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930TdOk
@description  Verifica o valor de apuração, caso esteja em branco não permite salvar apuração.
@author Natacha Romeiro
@since  26/08/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At930TdOk(oModel)
Local oMdlZZP		:= oModel:GetModel("ZZPDETAIL")
Local oMdlTFW		:= oModel:GetModel("TFWDETAIL")
Local lRet 			:= .T.
Local nTotalHE 		:= 0
Local nTotMed		:= 0
Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lMedLeg		:= SuperGetMv("MV_GSMDZER",,"2") == "1" //Verifica se vai habilitar a opção da Legenda de alocação na medição
Local nX 			:= 0
Local nBkp			:= 0

If (!lMedExce .OR. lApuraHE) .AND. oModel:GetOperation() != MODEL_OPERATION_DELETE 
	nBkp := oMdlZZP:GetLine()
	For nX := 1 To oMdlZZP:Length()
		oMdlZZP:GoLine(nX)
		nTotMed += oMdlZZP:GetValue("ZZP_VLRTOT") 
	Next nX
	oMdlZZP:GoLine(nBkp)
	nBkp := oMdlTFW:GetLine()
	For nX := 1 To oMdlTFW:Length()
		oMdlTFW:GoLine(nX)
		nTotalHE  += oMdlTFW:GetValue("TFW_VLHORE")
	Next nX
	oMdlTFW:GoLine(nBkp)
	If (lApuraHE .AND. nTotalHE == 0) .OR. (!lApuraHE .AND. nTotMed == 0)
		If !isBlind()
			Help(,,'At930TdOk',,STR0208,1,0)	// "Não é possivel salvar com valores zerado, verifique e tente novamente."
			lRet := .F.
		EndIf
	endif
EndIf

If lRet .And. lMedLeg .And. oModel:GetOperation() == MODEL_OPERATION_INSERT
	nBkp := oMdlTFW:GetLine()
	For nX := 1 To oMdlTFW:Length()
		oMdlTFW:GoLine(nX)
		If oMdlTFW:GetValue("TFW_LEG") == "BR_VERMELHO" .And. oMdlTFW:GetValue("TFW_VLRMED") > 0 .And. !isBlind()
			If !MsgYesNo(STR0220, STR0221) //"Os postos com a legenda vermelha não possuem alocação e estão com valores a serem cobrados, deseja confirmar a medição ?"##"Medição sem Alocação"
				Help(,,'At930TdOk',,STR0222,1,0) //Operação Cancelada!"
				lRet := .F.
				exit
			Else
				exit
			EndIf
		EndIf
	Next nX
	oMdlTFW:GoLine(nBkp)	
EndIf 

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} GetTotExce
@description 	Retorna o Total Excedente de um determinado contrato
@author 		Mateus Boiani
@since 			08/10/2021
/*/
//---------------------------------------------------------------------
Static Function GetTotExce(cTFJ, cCompet)
Local nRet := 0
Local cSql := ""
Local cAliasAux := GetNextAlias()

cSql += " SELECT SUM(TGT.TGT_VALOR) AS VALOR FROM " + RetSqlName("TGT") + " TGT "
cSql += " WHERE TGT.D_E_L_E_T_ = ' ' AND "
cSql += " TGT.TGT_COMPET = '"+cCompet+"' AND "
cSql += " TGT.TGT_CODTFJ = '"+ cTFJ + "' AND "
cSql += " TGT.TGT_EXCEDT = '1' AND "
cSql += " TGT.TGT_CODTFV = '" + SPACE(TamSX3("TGT_CODTFV")[1]) + "' "

cSql := ChangeQuery(cSql)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasAux, .F., .T.)

If !(cAliasAux)->(EOF())
	nRet := (cAliasAux)->VALOR
EndIf
(cAliasAux)->(DbCloseArea())

Return nRet
//---------------------------------------------------------------------
/*/{Protheus.doc} UpdateTGT
@description 	Atualiza o campo TGT_CODTFV conforme a operação executada
@author 		Mateus Boiani
@since 			08/10/2021
/*/
//---------------------------------------------------------------------
Static Function UpdateTGT(cCodTFJ, cCompet, cCodTFV, lDeleta)
Local cSql := ""
Local cAliasAux := GetNextAlias()
Local cSpace := SPACE(TamSX3("TGT_CODTFV")[1])
Local cSpacPV := SPACE(TamSX3("TGT_NUMPV")[1])
Default lDeleta := .F.

DbSelectArea("TGT")

cSql += " SELECT TGT.R_E_C_N_O_ AS REC FROM " + RetSqlName("TGT") + " TGT "
cSql += " WHERE TGT.D_E_L_E_T_ = ' ' AND "
cSql += " TGT.TGT_COMPET = '"+cCompet+"' AND "
cSql += " TGT.TGT_CODTFJ = '"+ cCodTFJ + "' AND "
cSql += " TGT.TGT_EXCEDT = '1' AND "
If !lDeleta
	cSql += " TGT.TGT_CODTFV = '" + cSpace + "' "
Else
	cSql += " TGT.TGT_CODTFV = '" + cCodTFV + "' "
EndIf

cSql := ChangeQuery(cSql)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasAux, .F., .T.)

While !(cAliasAux)->(EOF())
	TGT->(DbGoTo((cAliasAux)->REC))
	Reclock("TGT",.F.)
		If !lDeleta
			TGT->TGT_CODTFV := cCodTFV
		Else
			TGT->TGT_CODTFV := cSpace
			TGT->TGT_NUMPV := cSpacPV
		EndIf
	TGT->(MsUnlock())
	(cAliasAux)->(DbSkip())
End
(cAliasAux)->(DbCloseArea())

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} GeraPvExce
@description 	Gera o PV na Apuração de Excedentes
@author 		Mateus Boiani
@since 			16/10/2021
/*/
//---------------------------------------------------------------------
Static Function GeraPvExce(cCodCli, cLoja, cCodTFL, cCodTFJ, cCompet, cCondPag, cTpFrente)
Local lRet := .T.
Local cSql := ""
Local cSpace := SPACE(TamSX3("TGT_CODTFV")[1])
Local cSpacPV := SPACE(TamSX3("TGT_NUMPV")[1])
Local aAux := {}
Local aLinha := {}
Local aItens := {}
Local aCabec := {}
Local aRetPe := {}
Local aRECs := {}
Local nAux := 0
Local nX
Local cAliasAux := GetNextAlias()
Local cProduto := ""
Local nVal := 0
Local cTES := ""
Local lAT930EXC	:= ExistBlock("AT930EXC")
Local cCodPai := ""

Default cTpFrente := ""

DbSelectArea("TGT")

cSql := " SELECT TGT.TGT_VALOR, TGT.TGT_PRDRET, TGT.TGT_TPITEM, TGT.TGT_CDITEM, TGT.R_E_C_N_O_ REC "
cSql += " FROM " + RetSqlName("TGT") + " TGT "
cSql += " INNER JOIN " + RetSqlName("TFJ") + " TFJ ON "
cSql += " TFJ.TFJ_CODIGO = '" + cCodTFJ + "' AND "
cSql += " TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND "
cSql += " TFJ.D_E_L_E_T_ = ' ' "
cSql += " INNER JOIN " + RetSqlName("TFL") + " TFL ON "
cSql += " TFL.TFL_CODPAI = TFJ.TFJ_CODIGO AND "
cSql += " TFL.TFL_FILIAL = TFJ.TFJ_FILIAL AND "
cSql += " TFL.D_E_L_E_T_ = ' ' AND "
cSql += " TFL.TFL_CODIGO = '" + cCodTFL + "' "
cSql += " WHERE "
cSql += " TGT.D_E_L_E_T_ = ' ' AND "
cSql += " TGT.TGT_EXCEDT = '1' AND "
cSql += " TGT.TGT_COMPET = '" + cCompet + "' AND "
cSql += " TGT.TGT_CODTFJ = '" + cCodTFJ + "' AND "
cSql += " TGT.TGT_CODTFV = '" + cSpace + "' AND "
cSql += " TGT.TGT_NUMPV = '" + cSpacPV + "' AND "
cSql += " TGT.TGT_FILIAL = '" + xFilial("TGT") + "' "

cSql := ChangeQuery(cSql)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasAux, .F., .T.)

While !(cAliasAux)->(EOF())
	If (cAliasAux)->TGT_TPITEM == 'TFF'
		cCodPai := POSICIONE("TFF",1,xFilial("TFF") + (cAliasAux)->TGT_CDITEM, "TFF_CODPAI")
	Else
		cCodPai := POSICIONE("TFF",1,xFilial("TFF") + POSICIONE((cAliasAux)->TGT_TPITEM , 1 ,;
			xFilial((cAliasAux)->TGT_TPITEM) + (cAliasAux)->TGT_CDITEM ,;
			(cAliasAux)->TGT_TPITEM+"_CODPAI"), "TFF_CODPAI")
	EndIf

	If cCodPai == cCodTFL
		AADD(aRECs, (cAliasAux)->REC)
		If !EMPTY((cAliasAux)->TGT_PRDRET)
			cProduto := (cAliasAux)->TGT_PRDRET
		Else
			cProduto := POSICIONE((cAliasAux)->TGT_TPITEM,;
								1,;
								xFilial((cAliasAux)->TGT_TPITEM) + (cAliasAux)->TGT_CDITEM,;
								((cAliasAux)->TGT_TPITEM+"_PRODUT"))
		EndIf

		nVal := (cAliasAux)->TGT_VALOR
		cTES := POSICIONE((cAliasAux)->TGT_TPITEM,;
								1,;
								xFilial((cAliasAux)->TGT_TPITEM) + (cAliasAux)->TGT_CDITEM,;
								((cAliasAux)->TGT_TPITEM+"_TESPED"))
		If EMPTY(aAux) .OR. (nAux := ASCAN(aAux, {|a| a[1] == cProduto .AND. a[2] == cTES})) == 0
			AADD(aAux, {cProduto, cTES, nVal})
		Else
			aAux[nAux][3] += nVal
		EndIf
	EndIf
	(cAliasAux)->(DbSkip())
End
(cAliasAux)->(DbCloseArea())

For nX := 1 To LEN(aAux)
	aLinha := {}
	aadd(aLinha,{"C6_ITEM",    StrZero(nX,2), Nil})
	aadd(aLinha,{"C6_PRODUTO", aAux[nX][1],   Nil})
	aadd(aLinha,{"C6_QTDVEN",  1,             Nil})
	aadd(aLinha,{"C6_PRCVEN",  aAux[nX][3],   Nil})
	aadd(aLinha,{"C6_PRUNIT",  aAux[nX][3],   Nil})
	aadd(aLinha,{"C6_VALOR",   aAux[nX][3],   Nil})
	aadd(aLinha,{"C6_TES",     aAux[nX][2],   Nil})
	aadd(aItens, aLinha)
Next nX
aadd(aCabec, {"C5_TIPO",    "N",       Nil})
aadd(aCabec, {"C5_CLIENTE", cCodCli,    Nil})
aadd(aCabec, {"C5_LOJACLI", cLoja,   Nil})
aadd(aCabec, {"C5_CONDPAG", cCondPag, Nil})
If !EMPTY(cTpFrente)
	aAdd( aCabec, { 'C5_TPFRETE', IIF(cTpFrente == '1', "C", "F"), Nil } )
EndIf

aComplSC5 := GetComplSc5(Posicione("TFL",1,xFilial("TFL")+cCodTFL,"TFL_LOCAL"))

For nAux := 1 To Len(aComplSC5)
	If !Empty(aComplSC5[nAux][2])
		aAdd( aCabec, { aComplSC5[nAux][1], aComplSC5[nAux][2], Nil } )
	EndIf	
Next nAux

If lAT930EXC
	aRetPe := ExecBlock("AT930EXC",.F.,.F., {aCabec, aItens} )
	aCabec := aRetPe[1]
	aItens := aRetPe[2]
EndIf

If !EMPTY(aItens)
	lMsErroAuto := .F.
	MsExecAuto( { |w,x,y,z| MATA410( w, x, y, Nil, Nil, Nil, Nil, z ) }, aCabec, aItens, 3, {}/*aRateio*/ )
	If lMsErroAuto
		lRet := .F.
		xAuxPed := GetAutoGrLog()
		MostraErro()
	ElseIf lRet
		For nX := 1 to LEN(aRECs)
			TGT->(DbGoTo(aRECs[nX]))
			Reclock("TGT",.F.)
				TGT->TGT_NUMPV := SC5->C5_NUM
			TGT->(MsUnlock())
		Next nX
	EndIf
EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} DelPvExce
@description 	Apaga o PV no Estorno de Excedentes
@author 		Mateus Boiani
@since 			16/10/2021
/*/
//---------------------------------------------------------------------
Static Function DelPvExce(cCodTFJ, cCompet, cCodTFV)
Local lRet := .T.
Local nI
Local cSql := ""
Local cAliasAux := GetNextAlias()
Local aPedApu := {}
Local cSpacPV := SPACE(TamSX3("TGT_NUMPV")[1])

cSql += " SELECT DISTINCT TGT.TGT_NUMPV FROM " + RetSqlName("TGT") + " TGT "
cSql += " INNER JOIN " + RetSqlName("SC5") + " SC5 ON "
cSql += " SC5.C5_FILIAL = '" + xFilial("SC5") + "' AND "
cSql += " SC5.C5_NUM = TGT.TGT_NUMPV AND "
cSql += " SC5.D_E_L_E_T_ = ' ' "
cSql += " WHERE TGT.D_E_L_E_T_ = ' ' AND "
cSql += " TGT.TGT_COMPET = '"+cCompet+"' AND "
cSql += " TGT.TGT_CODTFJ = '"+ cCodTFJ + "' AND "
cSql += " TGT.TGT_EXCEDT = '1' AND "
cSql += " TGT.TGT_NUMPV != '" + cSpacPV + "' AND "
cSql += " TGT.TGT_CODTFV = '" + cCodTFV + "' "

cSql := ChangeQuery(cSql)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasAux, .F., .T.)

While !(cAliasAux)->(EOF())
	AADD(aPedApu, (cAliasAux)->TGT_NUMPV)
	(cAliasAux)->(DbSkip())
End
(cAliasAux)->(DbCloseArea())

For nI:=1 To Len(aPedApu)

	lMsErroAuto := .F.
	MSExecAuto({|x,y,z| Mata410(x,y,z)},{{"C5_NUM",aPedApu[nI],NIL}},{},5)

	If lMsErroAuto
		lRet := .F.
		If Empty(NomeAutoLog()) .OR. Empty(MemoRead(NomeAutoLog()))
			Help(,,'AT930ERRMD6',,STR0080,1,0)   //"Ocorreu erro na exclusão do pedido de cobrança"
		Else
			MostraErro()
		EndIf
		Exit
	Endif

Next nI

Return lRet
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At930ApuHE
@description Apuração (somente) de horas extras 
@author Natacha Romeiro
@since  20/10/2021
/*/
//-------------------------------------------------------------------------------------------------------------------
Function At930ApuHE(nOperacao)
Local lExistPerg := FindFunction("TecHasPerg") .AND. TecHasPerg('MV_PAR01','TEC930HE')
Local lABRCodTFV := TecBHasBrT() 

If lExistPerg 
	If lABRCodTFV
		lApuraHE := .T.
		dDtIniHE   := MV_PAR02
		dDtFimHE   := MV_PAR03
		MsgRun( STR0074, STR0073, {|| FWExecView(STR0002,"VIEWDEF.TECA930",nOperacao,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/) } ) // 'Processando Apuração  ' #### 'Aguarde...' #### "Geração"
		aHEsProc   := {}
		dDtIniHE   := Ctod("")
		dDtFimHE   := Ctod("")
		lApuraHE := .F.
	Else
		Help(,,'At930ApuHE',,STR0218,1,0) // "Para usar esta opção crie o campo ABR_CODTFV, conforme indicado na documentação técnica desta funcionalidade."
	EndIf
Else
	Help(,,'At930ApuHE',,STR0217,1,0) // "Para usar esta opção crie o Pergunte TEC930HE, conforme indicado na documentação técnica desta funcionalidade."
EndIf

Return(Nil)
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} UpdateHE
@description Atualiza registros de inclusão e extorno referente a apuração de horas extras 
@author Natacha Romeiro
@since  22/10/2021
/*/
//-------------------------------------------------------------------------------------------------------------------
Static Function UpdateHE(cCodTFV, lInclui)
Local nX
Local cAliasQry	:= GetNextAlias()
Default lInclui := .T.

DbSelectArea("ABR")
If lInclui
	For nX := 1 To LEN(aHEsProc)
		If aHEsProc[nX] > 0
			ABR->(DbGoTo(aHEsProc[nX]))
			Reclock("ABR",.F.)
				ABR->ABR_CODTFV := cCodTFV
			ABR->(MsUnlock())
		EndIf
	Next nX
Else
	BeginSql Alias cAliasQry
		SELECT	ABR.R_E_C_N_O_	REC
		FROM %table:ABR% ABR
		WHERE ABR.ABR_FILIAL = %xFilial:ABR%
		AND ABR.ABR_CODTFV = %Exp:cCodTFV%
		AND ABR.%NotDel%
	EndSql

	dbSelectArea("ABR")

	ABR->(dbSetOrder(1))
	While (cAliasQry)->(!Eof())
		ABR->(DbGoTo((cAliasQry)->REC))
		Reclock("ABR",.F.)
		ABR->ABR_CODTFV := Space(TamSx3("ABR_CODTFV")[1])
		ABR->(MsUnlock())
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dBCloseArea())
EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} At930ChkIT
@description 	Verifica se o item extra já foi cobrado no mes
@author 		Luiz Gabriel
@since 			26/11/2021
/*/
//---------------------------------------------------------------------
Static Function At930ChkIT(cCodTFF,cContrato,cDtIni,cDtFim)
Local lRet		:= .F.
Local cAliasTFV	:= GetNextAlias()


BeginSql Alias cAliasTFV
	SELECT TFV.TFV_CODIGO
	FROM %table:TFV% TFV
	INNER JOIN %table:TFW% TFW 
	ON TFW.TFW_FILIAL = %xFilial:TFW%
	AND TFW.TFW_APURAC = TFV_CODIGO
	AND TFW.TFW_CODTFF = %Exp:cCodTFF%
	AND TFW.%NotDel%
	WHERE
	TFV.TFV_CONTRT = %Exp:cContrato%
	AND TFV.TFV_TIPO = '2'
	AND TFV.TFV_DTINI = %Exp:cDtIni%
	AND TFV.TFV_DTFIM = %Exp:cDtFim%
	AND TFV.%NotDel%
EndSql

If (cAliasTFV)->(!Eof())
	lRet := .T.
EndIf

(cAliasTFV)->(dBCloseArea())

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} At930Legd
@description 	Adiciona a explicação da legenda
@author 		Kaique Schiller
@since 			15/03/2022
/*/
//---------------------------------------------------------------------
Static Function At930Legd()
Local oLeg 		:= FwLegend():New()

oLeg:Add( "", "BR_VERDE"	, "Com Alocação" ) //"Efetivo"
oLeg:Add( "", "BR_VERMELHO"	, "Sem Alocação" ) //"Excedente"
oLeg:View()
DelClassIntf()

Return(.T.)

//---------------------------------------------------------------------
/*/{Protheus.doc} At930Aloc
@description 	Verificação de alocação no período
@author 		Kaique Schiller
@since 			15/03/2022
/*/
//---------------------------------------------------------------------
Static Function At930Aloc(cCodTFF,dDtIni,dDtFim)
Local lRet		:= .F.
Local cAliasABB	:= ""
Default cCodTFF := ""
Default dDtIni	:= sTod("")
Default dDtFim	:= sTod("")

If !Empty(cCodTFF)
	cAliasABB := GetNextAlias()
	BeginSql Alias cAliasABB
		COLUMN TDV_DTREF AS DATE
		SELECT 1
		FROM %table:ABB% ABB
		INNER JOIN  %table:TDV% TDV ON TDV.TDV_FILIAL = %xFilial:TDV%
			AND TDV.TDV_CODABB = ABB.ABB_CODIGO
			AND TDV.%NotDel%
		INNER JOIN %table:ABQ% ABQ ON ABQ.ABQ_FILIAL = %xFilial:ABQ%
			AND ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL
			AND ABQ.%NotDel%
		WHERE ABB.ABB_FILIAL =  %xFilial:ABB%
			AND ABB.ABB_ATIVO = '1'
			AND TDV.TDV_DTREF BETWEEN %Exp:dDtIni% AND %Exp:dDtFim%
			AND ABQ.ABQ_CODTFF = %Exp:cCodTFF%
			AND ABB.%NotDel%
	EndSql
	If (cAliasABB)->(!Eof())
		lRet := .T.
	EndIf
	(cAliasABB)->(dBCloseArea())
Endif

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} A930VgDisp
@description 	Verificação a qtd de vagas que podem ser alocadas no POSTO
@author 		Luiz Gabriel
@since 			06/05/2022
/*/
//---------------------------------------------------------------------
Static Function A930VgDisp(cCodTFF)
Local aInfo 	:= A930GetTur(cCodTFF)
Local nRet		:= 0
Local aCodTdx	:= {}

aCodTdx := a930GetTDX(aInfo[1])

If Len(aCodTdx) > 0
	nRet := Len(aCodTDX)
	nRet := nRet * aInfo[2]
EndIf

Return nRet

//---------------------------------------------------------------------
/*/{Protheus.doc} A930GetTur
@description 	Retorna a escala e a qtd de venda de um posto
@author 		Luiz Gabriel
@since 			06/05/2022
/*/
//---------------------------------------------------------------------
Static Function A930GetTur(cCodTFF)
Local cEscala	:= ""	
Local nQtdVen	:= 0
Local cAliasTFF	:= GetNextAlias()
Local lEOF		:= .F.

BeginSQL Alias cAliasTFF
	SELECT TFF.TFF_ESCALA,
			TFF.TFF_QTDVEN
		FROM %Table:TFF% TFF
	WHERE TFF.TFF_FILIAL = %xFilial:TFF%
		AND TFF.%NotDel%
		AND TFF.TFF_COD = %Exp:cCodTFF%
EndSQL

lEOF := (cAliasTFF)->(EOF())
If !lEOF
	cEscala := (cAliasTFF)->TFF_ESCALA
	nQtdVen := (cAliasTFF)->TFF_QTDVEN
EndIf

(cAliasTFF)->(DbCloseArea())

Return {cEscala,nQtdVen} 

//---------------------------------------------------------------------
/*/{Protheus.doc} a930GetTDX
@description 	Retorna o codigo das configurações de escala
@author 		Luiz Gabriel
@since 			06/05/2022
/*/
//---------------------------------------------------------------------
Static Function a930GetTDX(cCodTDW)
Local cAliasSPJ	:= GetNextAlias()
Local aRet 		:= {}

BeginSQL Alias cAliasSPJ
	SELECT TDX.TDX_COD
		FROM %Table:TDX% TDX
		INNER JOIN %Table:SPJ% SPJ ON SPJ.PJ_FILIAL = %xFilial:SPJ%
			AND SPJ.%NotDel%
			AND SPJ.PJ_TURNO = TDX.TDX_TURNO
			AND SPJ.PJ_SEMANA = TDX.TDX_SEQTUR
	WHERE TDX.TDX_FILIAL = %xFilial:TDX%
		AND TDX.%NotDel%
		AND TDX.TDX_CODTDW = %Exp:cCodTDW%
	GROUP BY TDX.TDX_COD
	ORDER BY TDX.TDX_COD
EndSQL

While (cAliasSPJ)->(!EOF())
	aAdd(aRet,(cAliasSPJ)->TDX_COD)
	(cAliasSPJ)->(dbSkip())
End

(cAliasSPJ)->(DbCloseArea())

Return aRet

//---------------------------------------------------------------------
/*/{Protheus.doc} A930VgAloc
@description 	Verificação a qtd de vagas que estão alocadas
@author 		Luiz Gabriel
@since 			06/05/2022
/*/
//---------------------------------------------------------------------
Static Function A930VgAloc(cCodTFF,dDatIni,dDataFim)
Local aInfo 	:= A930GetTur(cCodTFF)
Local nRet		:= 0
Local aCodTDX	:= {}
Local nCodTDX	:= 0

aCodTdx := a930GetTDX(aInfo[1])

If Len(aCodTdx) > 0
	For nCodTDX := 1 To Len(aCodTDX)
		nRet += a930CntVg(cCodTFF,aCodTDX[nCodTDX],aInfo[1],aInfo[2],dDatIni,dDataFim)
	Next nCodTDX
EndIf

Return nRet

//---------------------------------------------------------------------
/*/{Protheus.doc} A930VgAloc
@description 	Faz a busca na TGY pela escala e sequencia e o grupo
para determinar quantas vagas estão preenchidas

@author 		Luiz Gabriel
@since 			06/05/2022
/*/
//---------------------------------------------------------------------
Static Function a930CntVg(cCodTFF,cCodTDX,cCodEsc,nQtdTFF,dDataIni,dDataFim)
Local cAliasTGY	:= ""
Local nRet		:= 0
Local nGrupo	:= 1
Local nAtend	:= 0
Local lExistTGY	:= .F.
Local aAtend 	:= {}
Local nX 		:= 0

While nGrupo <= nQtdTFF
	cAliasTGY	:= GetNextAlias()
	BeginSQL Alias cAliasTGY
		SELECT TGY.TGY_CODTDX,
				TGY.TGY_CODTFF,
				TGY.TGY_ESCALA,
				TGY.TGY_DTINI,
				TGY.TGY_ULTALO,
				TGY.TGY_ATEND,
				TGY.TGY_GRUPO,
				TGY.R_E_C_N_O_
			FROM %Table:TGY% TGY
		WHERE TGY.TGY_FILIAL = %xFilial:TGY%
			AND TGY.TGY_CODTFF = %Exp:cCodTFF%
			AND TGY.TGY_ESCALA = %Exp:cCodEsc%
			AND ( (TGY.TGY_DTINI >= %Exp:dDataIni% AND TGY.TGY_ULTALO <= %Exp:dDataFim% OR;
						TGY.TGY_DTINI <= %Exp:dDataIni% AND TGY.TGY_ULTALO >= %Exp:dDataFim%)
					OR (TGY.TGY_DTINI <= %Exp:dDataIni%
       						AND TGY.TGY_ULTALO <= %Exp:dDataFim%)
					OR ( TGY.TGY_DTINI >= %Exp:dDataIni%
       						AND TGY.TGY_ULTALO >= %Exp:dDataFim%))
			AND TGY.TGY_CODTDX = %Exp:cCodTDX%
			AND TGY.TGY_GRUPO = %Exp:nGrupo%
			AND (TGY.TGY_ULTALO != '' AND TGY.TGY_ULTALO >= %Exp:dDataIni% )
			AND TGY.%NotDel%
	EndSQL

	While (cAliasTGY)->(!EOF())
		lExistTGY := .T.
		//Guarda a TGY que será contabilizada
		If !((cAliasTGY)->TGY_DTINI <= DtoS(dDataIni) .And. (cAliasTGY)->TGY_ULTALO >= DtoS(dDataFim))
			nRet := a930QtdVg((cAliasTGY)->TGY_CODTFF,(cAliasTGY)->TGY_ESCALA,(cAliasTGY)->TGY_CODTDX,;
			(cAliasTGY)->TGY_ATEND,(cAliasTGY)->TGY_DTINI,(cAliasTGY)->TGY_ULTALO,(cAliasTGY)->TGY_GRUPO,dDataIni,@aAtend)
			If nRet > 0 .And. aScan(aAtend,{ |x| x[1] == (cAliasTGY)->R_E_C_N_O_ }) == 0
				aAdd(aAtend,{(cAliasTGY)->R_E_C_N_O_,.T.})
			EndIf
		Else 
			If aScan(aAtend,{ |x| x[1] == (cAliasTGY)->R_E_C_N_O_ }) == 0
				aAdd(aAtend,{(cAliasTGY)->R_E_C_N_O_,.T.})
			EndIf
		EndIf 	
		(cAliasTGY)->(dbSkip())
	End

	If lExistTGY
		If Len(aAtend) > 0
			For nX := 1 To Len(aAtend)
				If aAtend[nX][2]
					nAtend ++
				EndIf 
			Next nX
		Else 
			//como tem TGY mais não houve nenhum conflito entre as datas no periodo entende-se que há uma vaga preenchida
			nAtend ++
		EndIf 	 
	EndIf 	

	lExistTGY := .F. //Reinicia Variavel

	(cAliasTGY)->(DbCloseArea())
	nGrupo++
	aAtend := {} //zera variavel
End

Return nAtend

//---------------------------------------------------------------------
/*/{Protheus.doc} A930VgAloc
@description 	Verifica se há alguém mais além do atendente que será verificado
estão alocados no mesmo periodo

@author 		Luiz Gabriel
@since 			06/05/2022
/*/
//---------------------------------------------------------------------
Static Function a930QtdVg(cCodTFF, cCodEsc, cCodTDX, cAtend, dDtIni, dUltAlo, nGrupo, dIniCob,aAtend)
Local cAliasTGY	:= GetNextAlias()
Local nRet		:= 0
	
	BeginSQL Alias cAliasTGY
		SELECT TGY.TGY_CODTDX,
				TGY.TGY_CODTFF,
				TGY.TGY_ESCALA,
				TGY.TGY_DTINI,
				TGY.TGY_ULTALO,
				TGY.TGY_ATEND,
				TGY.TGY_GRUPO,
				TGY.R_E_C_N_O_
			FROM %Table:TGY% TGY
		WHERE TGY.TGY_FILIAL = %xFilial:TGY%
			AND TGY.TGY_CODTFF = %Exp:cCodTFF%
			AND TGY.TGY_ESCALA = %Exp:cCodEsc%
			AND (TGY.TGY_DTINI BETWEEN %Exp:dDtIni% AND %Exp:dUltAlo% OR;
			  TGY.TGY_ULTALO BETWEEN %Exp:dDtIni% AND %Exp:dUltAlo%)			
			AND TGY.TGY_ULTALO >= %Exp:dIniCob%
			AND TGY.TGY_CODTDX = %Exp:cCodTDX%
			AND TGY.TGY_GRUPO = %Exp:nGrupo%
			AND TGY.TGY_ATEND != %Exp:cAtend%
			AND TGY.%NotDel%
	EndSQL

	While (cAliasTGY)->(!EOF())
		//Conta somente TGY´s que não foram avaliadas
		If aScan(aAtend,{ |x| x[1] == (cAliasTGY)->R_E_C_N_O_ }) == 0
			aAdd(aAtend,{(cAliasTGY)->R_E_C_N_O_,.T.})
			nRet ++
		EndIf
		(cAliasTGY)->(dbSkip())
	End

	(cAliasTGY)->(DbCloseArea())

Return nRet



//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  
@description 	Retorna a cor da legenda para o material de implantação

@author 		Vitor kwon
@since 			186/05/2022
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At930Legend(cAliasLG,cCodigo)

Local cCor       
Local cAliasSCP  := ""
local cPreTF    := ""
local cStatus    := ""
Local nQuant     := 0
Local nQtdEnt    := 0
Local nQtdzero   := 0
local cTabela    := cAliasLG
Local cCodSA     := ""
Local lSaldo     := .F.
Local lRegistro  := .F.
local nQtdSld    := 0

If (TecAponts() .And. MV_PAR05 == 1)

	cCor       := 'BR_BRANCO' 
	cAliasSCP  := GetNextAlias()  

	IF cTabela == "TFX"
		cCodSA    := At930CodSA(cCodigo)
		BeginSql Alias cAliasSCP
				SELECT CP_PREREQU, CP_STATSA,CP_STATUS, CP_QUANT, CP_QUJE, TFS_CODTFG ,CP_NUM
				FROM %Table:TFL% TFL
				INNER JOIN %Table:TFS% TFS ON TFS_CODTFL = TFL_CODIGO AND TFS_FILIAL =  %Exp:xFilial("TFS")%
				INNER JOIN %Table:SCP% SCP ON SCP.CP_NUM  = TFS.TFS_CODSA AND  SCP.CP_FILIAL  = %Exp:xFilial("SCP")% 
				WHERE TFS.%NotDel% 
				AND SCP.%NotDel% 
				AND TFL.%NotDel%
				AND TFL_FILIAL = %Exp:xFilial("TFL")%
				AND TFS_CODSA = %Exp:cCodSA%
		EndSQL
	Elseif cTabela == "TFY"
		cCodTFH   := cCodigo
		cCodSA    := At930TFT(cCodTFH) 
        BeginSql Alias cAliasSCP
				SELECT CP_PREREQU, CP_STATSA,CP_STATUS, CP_QUANT, CP_QUJE , CP_NUM, TFT_QUANT
				FROM %Table:TFL% TFL
				INNER JOIN %Table:TFT% TFT ON TFT_CODTFL = TFL_CODIGO AND TFT_FILIAL =  %Exp:xFilial("TFT")%
				INNER JOIN %Table:SCP% SCP ON SCP.CP_NUM  = TFT.TFT_CODSA AND  SCP.CP_FILIAL  = %Exp:xFilial("SCP")% 
				WHERE TFT.%NotDel% 
				AND SCP.%NotDel% 
				AND TFL.%NotDel%
				AND TFL_FILIAL = %Exp:xFilial("TFT")%
				AND TFT_CODSA = %Exp:cCodSA%
		EndSQL
	Endif	

	If cTabela == "TFX"
		lSaldo := At930Sld("TFX",cCodigo) 
		lRegistro := At930reg("TFS",cCodigo) 
		nQtdSld   := Posicione("TFG",1,xFilial("TFG")+cCodigo,"TFG_SLD")
	elseif cTabela == "TFY"
		lSaldo := At930Sld("TFY",cCodigo)
		lRegistro := At930reg("TFT",cCodigo) 
		nQtdSld   := Posicione("TFH",1,xFilial("TFH")+cCodigo,"TFH_SLD")
	Endif

	cPreTF := (cAliasSCP)->CP_PREREQU // Pre-requisição
	cStatus := (cAliasSCP)->CP_STATUS  // Status da SA
	nQuant  := (cAliasSCP)->CP_QUANT   // Quantidade solicitada
	nQtdEnt := (cAliasSCP)->CP_QUJE   // Quantidade atendida

	
	If !lRegistro
		cCor := 'BR_VERMELHO' 
	ElseIf (!Empty(cPreTF)  .And. !Empty(cStatus) .And. nQuant == nQtdEnt .And. nQtdSld == nQtdzero .And. lSaldo ) .or. lSaldo
		cCor := 'BR_VERDE'
	Elseif (!Empty(cPreTF)  .And. Empty(cStatus)  .And. nQtdEnt == nQtdzero .And.  !lSaldo ) .or. (Empty(cPreTF)  .And. Empty(cStatus)  .And. nQtdEnt == nQtdzero .And.  lSaldo )
		cCor := 'BR_BRANCO'
	Elseif (!Empty(cPreTF)  .And. Empty(cStatus)  .And. nQuant != nQtdEnt .And. nQtdEnt > 0 ) .or. !lSaldo
		cCor := 'BR_AMARELO'
	Endif	   

	(cAliasSCP)->(DbCloseArea()) 

Endif		
	
Return cCor

//------------------------------------------------------------------------------
/*/{Protheus.doc} At930TFT
Função para retornar o codigo da solicitacao do armazem 
@author		Vitor kwon
@since		18/05/2022
@param Nil
/*/
//------------------------------------------------------------------------------


Function At930TFT(cCodTFH) 

local cRet := ""
local cAliasTFT  := GetNextAlias()  

		BeginSql Alias cAliasTFT
			SELECT TFT_CODSA CODIGO
				FROM %Table:TFT% TFT
				WHERE TFT.%NotDel% 
				AND TFT_FILIAL = %Exp:xFilial("TFT")%
				AND TFT_CODTFH = %Exp:cCodTFH%
				AND TFT_CODSA <> ''
		EndSQL

	cRet :=  (cAliasTFT)->CODIGO

(cAliasTFT)->(DbCloseArea())

Return cRet



//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At930GetLg

Tela com as legendas disponiveis para a rotina

@author  Serviços
@since 	  31/10/13
@version P11 R9
@return lRet: Retorna .T. quando a criação foi bem sucedida.
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At930GetLg()

Local	oLegenda := FwLegend():New()

    If !IsInCallStack("INITDADOS")   
	   If  (TecAponts() .And. MV_PAR05 == 1) 
	           oLegenda:Add('','BR_BRANCO'     ,STR0225)    // "Solicitação em análise pelo estoque"  
               oLegenda:Add('','BR_AMARELO'    ,STR0226)    // "Atendido Parcialmente"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
               oLegenda:Add('','BR_VERDE'      ,STR0227)    // "Atendido totalmente"               
			   oLegenda:Add('','BR_VERMELHO'   ,STR0228)    // "Sem apontamento"				   		               
               oLegenda:View()
               DelClassIntf()
       EndIf  
	Endif                                                                                                                                    
Return .T.


//------------------------------------------------------------------------------
/*/{Protheus.doc} At930Sld
Função para verificar se existe saldo no apontamento - Utilizada nas legendas 
@author		Vitor kwon
@since		25042022
@param Nil
/*/
//------------------------------------------------------------------------------
Function At930Sld(cAlias,cCodigo) 

local  lOK    	:= .F.
Local  cAliasSA := GetNextAlias()  
Local  cQtdTFS 	:= 0
Local  cQtdTFT 	:= 0
Local  aSA 		:= {}
Local  nX 		:= 0
Local  nQtdAt   := 0
Local  nQtdAtE   := 0

	DbSelectArea("SCP")
	SCP->(DbSetOrder(1))

	IF cAlias == "TFX"

		cQtdTFS := Posicione("TFG",1,xFilial("TFG")+cCodigo,"TFG_QTDVEN")

		BeginSql Alias cAliasSA
			SELECT TFS_CODSA CODSA, TFS_QUANT AS QTDADE
				FROM %Table:TFS% TFS
				WHERE TFS.%NotDel% 
				AND TFS_FILIAL = %Exp:xFilial("TFS")%
				AND TFS_CODTFG = %Exp:cCodigo%
		EndSQL
		
		while (cAliasSA)->(!EOF())
			Aadd(aSA, {(cAliasSA)->CODSA,;
		           	   (cAliasSA)->QTDADE})	
			(cAliasSA)->(DBSKIP())
		Enddo

		for nX := 1 to Len(aSA)
			if SCP->(DbSeek(xFilial("SCP")+aSA[nX][1]))
				If SCP->CP_QUJE > 0
					nQtdAt  += SCP->CP_QUJE
					nQtdAtE +=  nQtdAt
				Else	
					nQtdAt  += 0
				Endif	
			else
				nQtdAtE += 	aSA[nX][2]			
			endif			
		next

		If (cQtdTFS == nQtdAt) .Or. (cQtdTFS ==	nQtdAtE  ) 
		    lOK := .T.
		Endif

	Elseif cAlias == "TFY"
				
		cQtdTFT := Posicione("TFH",1,xFilial("TFH")+cCodigo,"TFH_QTDVEN")

		BeginSql Alias cAliasSA
			SELECT TFT_CODSA CODSA, TFT_QUANT AS QTDADE
				FROM %Table:TFT% TFT
				WHERE TFT.%NotDel% 
				AND TFT_FILIAL = %Exp:xFilial("TFT")%
				AND TFT_CODTFH = %Exp:cCodigo%
		EndSQL

		While (cAliasSA)->(!EOF())
			Aadd(aSA, {(cAliasSA)->CODSA,;
		           	   (cAliasSA)->QTDADE})		
			(cAliasSA)->(DBSKIP())
		EndDo

		for nX := 1 to Len(aSA)
			if SCP->(DbSeek(xFilial("SCP")+aSA[nX][1]))
				If SCP->CP_QUJE > 0
					nQtdAt  += 	SCP->CP_QUJE
					nQtdAtE +=  nQtdAt
				else
					nQtdAt  += 0 	
				Endif	
			else
				nQtdAtE += 	aSA[nX][2]			
			endif			
		next

		If cQtdTFT == nQtdAt .Or. (cQtdTFT == nQtdAtE)
            lOK := .T.
		EndIf	
	Endif
	    
	(cAliasSA)->(DbCloseArea())

Return lOK


//------------------------------------------------------------------------------
/*/{Protheus.doc} At930CodSA
Função para retornar o codigo da solicitacao do armazem 
@author		Vitor kwon
@since		01/06/2022
@param Nil
/*/
//------------------------------------------------------------------------------
Function At930CodSA(cCodigo) 

local cRet   := ""
local cAlias := GetNextAlias()  

		BeginSql Alias cAlias
			SELECT TFS_CODSA CODSA
				FROM %Table:TFS% TFS
				WHERE TFS.%NotDel% 
				AND TFS_FILIAL = %Exp:xFilial("TFS")%
				AND TFS_CODTFG = %Exp:cCodigo%
				AND TFS_CODSA <> ''
		EndSQL

	cRet :=  (cAlias)->CODSA

(cAlias)->(DbCloseArea())

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At930QtApu
Função para retornar o valor apurado no caso de possuir apontamento da forma antiga
@author		Vitor kwon
@since		01/06/2022
@param Nil
/*/
//------------------------------------------------------------------------------
Function At930QtApu(cTabela, cCodigo) 

local cAlias  := GetNextAlias()  
local aRes    := {}
local nX      := 0
Local nValApu := 0

	If cTabela == "TFS"

		BeginSql Alias cAlias
			SELECT  TFS_NUMMOV MUNMOV, TFS_CODSA CODSA , (SCP.CP_QUJE * (TFG_PRCVEN - (TFG_PRCVEN * TFG_DESCON)/100) + ((TFG_PRCVEN * TFG_LUCRO)/100) + ((TFG_PRCVEN * TFG_ADM)/100)) VLRAPU,  
			(TFS.TFS_QUANT * (TFG_PRCVEN - (TFG_PRCVEN * TFG_DESCON)/100) + ((TFG_PRCVEN * TFG_LUCRO)/100) + ((TFG_PRCVEN * TFG_ADM)/100)) VLRAPU2
			FROM %Table:TFS% TFS
			LEFT JOIN %Table:TFG% TFG ON TFG_COD = TFS_CODTFG AND TFG_FILIAL = %Exp:xFilial("TFG")%
			LEFT JOIN %Table:SCP% SCP ON CP_NUM  = TFS_CODSA AND  CP_FILIAL  = %Exp:xFilial("SCP")% AND SCP.%NotDel% 
			WHERE TFS.%NotDel%   
			AND TFG.%NotDel% 
			AND TFS_FILIAL =  %Exp:xFilial("TFS")%
			AND TFS_CODTFG =  %Exp:cCodigo%
		EndSql		

	ElseIf cTabela == "TFT"

		BeginSql Alias cAlias
			SELECT  TFT_NUMMOV MUNMOV, TFT_CODSA CODSA , (SCP.CP_QUJE * (TFH_PRCVEN - (TFH_PRCVEN * TFH_DESCON)/100) + ((TFH_PRCVEN * TFH_LUCRO)/100) + ((TFH_PRCVEN * TFH_ADM)/100)) VLRAPU,  
			(TFT.TFT_QUANT * (TFH_PRCVEN - (TFH_PRCVEN * TFH_DESCON)/100) + ((TFH_PRCVEN * TFH_LUCRO)/100) + ((TFH_PRCVEN * TFH_ADM)/100)) VLRAPU2
			FROM %Table:TFT% TFT
			LEFT JOIN %Table:TFH% TFH ON TFH_COD = TFT_CODTFH AND TFH_FILIAL = %Exp:xFilial("TFH")%
			LEFT JOIN %Table:SCP% SCP ON CP_NUM  = TFT_CODSA AND  CP_FILIAL  = %Exp:xFilial("SCP")% AND SCP.%NotDel% 
			WHERE TFH.%NotDel%   
			AND TFT.%NotDel% 
			AND TFT_FILIAL =  %Exp:xFilial("TFT")%
			AND TFT_CODTFH =  %Exp:cCodigo%
		EndSql

	EndIf

	while (cAlias)->(!EOF())
		Aadd(aRes, {(cAlias)->VLRAPU,;
		            (cAlias)->MUNMOV,;
		            (cAlias)->CODSA,;
					(cAlias)->VLRAPU2})	
		(cAlias)->(DBSKIP())
	Enddo

	DbSelectArea("SCP")
	SCP->(DbSetOrder(1))

	For nX := 1 to len(aRes)
		If DbSeek(xFilial("SCP")+aRes[nX][3])
			iF SCP->CP_QUJE > 0
				nValApu += aRes[nX][1]
			Endif
		Elseif !Empty(aRes[nX][2]) .And. Empty(aRes[nX][3]) .Or. !Empty(aRes[nX][2]) .And. !Empty(aRes[nX][3])
				nValApu += aRes[nX][4]
		Endif		
	Next

(cAlias)->(DbCloseArea())

Return nValApu

//------------------------------------------------------------------------------
/*/{Protheus.doc} At890NumMov
Função para retornar o TFS_NUMMOV para verificar se foi atendido 
@author		Vitor kwon
@since		01/06/2022
@param Nil
/*/
//------------------------------------------------------------------------------
Function At890NumMov(cTabela, cCodigo) 

local lRet   := .F.
local cAlias := GetNextAlias()  

	If cTabela == "TFS"
		BeginSql Alias cAlias
			SELECT TFS.TFS_NUMMOV NUMMOV
				FROM %Table:TFS% TFS
				WHERE TFS.%NotDel% 
				AND TFS_FILIAL = %Exp:xFilial("TFS")%
				AND TFS_CODTFG = %Exp:cCodigo%
		EndSQL		
	ElseIf cTabela == "TFT"
		BeginSql Alias cAlias
			SELECT TFT.TFT_NUMMOV NUMMOV
				FROM %Table:TFT% TFT
				WHERE TFT.%NotDel% 
				AND TFT_FILIAL = %Exp:xFilial("TFT")%
				AND TFT_CODTFH = %Exp:cCodigo%
		EndSQL			
	EndIf

	while (cAlias)->(!EOF())
			If !Empty((cAlias)->NUMMOV)	
				lRet := .T.
				Exit
			Endif	
   	 	(cAlias)->(DBSKIP())     
	Enddo

(cAlias)->(DbCloseArea())

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} At930reg
Função para retornar se tem TFS ou TFT para legendas
@author		Vitor kwon
@since		01/06/2022
@param Nil
/*/
//------------------------------------------------------------------------------
Function At930reg(cTabela, cCodigo) 

local lRet   := .F.
local cAlias := GetNextAlias()  

	If cTabela == "TFS"
		BeginSql Alias cAlias
			SELECT TFS_CODIGO CODIGO
				FROM %Table:TFS% TFS
				WHERE TFS.%NotDel% 
				AND TFS_FILIAL = %Exp:xFilial("TFS")%
				AND TFS_CODTFG = %Exp:cCodigo%
		EndSQL		
	ElseIf cTabela == "TFT"
		BeginSql Alias cAlias
			SELECT TFT_CODIGO CODIGO
				FROM %Table:TFT% TFT
				WHERE TFT.%NotDel% 
				AND TFT_FILIAL = %Exp:xFilial("TFT")%
				AND TFT_CODTFH = %Exp:cCodigo%
		EndSQL			
	EndIf

	iF (cAlias)->(!EOF())
			If !Empty((cAlias)->CODIGO)	
				lRet := .T.
			Endif	  
	EndIF

(cAlias)->(DbCloseArea())

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} TecXMedicao
@description 	Realiza a chamada do CNT121AUTO para realizar medição/estorno
@author 		Luiz Gabriel
@since 			22/09/2022
/*/
//---------------------------------------------------------------------
Function TecXMedicao(xAutoCab,xAutoItens,nOpcAuto,cRotina,xOrigem,xShow,xExcede,aMltsGCT,aDescMed,lRetAut,aPlan,lAgrup)

Local cContra	:= ""
Local cPlan		:= ""
Local nx		:= 0
Local xRet      := NIL
Local lFixo     := .T.

Default xOrigem		:= FUNNAME()
Default xShow   	:= .F.
Default aMltsGCT	:= {}
Default aDescMed	:= {}
Default lRetAut		:= .T.
Default nOpcAuto 	:= 3
Default aPlan		:= {}
Default lAgrup		:= .F.

Private lAuto 		:= (valType(xAutoCab) == "A" .And. valType(xAutoItens) == "A")
Private aAutoCab	:= xAutoCab
Private aAutoItens	:= xAutoItens
Private aAutoExced  := xExcede
Private aMultasGCT  := aMltsGCT

Private cOrigem		:= Alltrim(xOrigem)
Private lShow		:= xShow
Private cFilCTR   	:= cFilAnt

	
If (nPos := aScan(aAutoCab,{|x| x[1]=="CND_CONTRA"})) > 0
	cContra := aAutoCab[nPos,2]
EndIf

If (nPos := aScan(aAutoCab,{|x| x[1]=="CND_NUMERO"})) > 0
	cPlan   := aAutoCab[nPos,2]
EndIf

lFixo  := CN300RetSt("FIXO",0,cPlan,cContra,cFilCTR)

If lFixo
	For nx:=1 to len(aAutoItens)
		aadd(aAutoItens[nx],{"LINPOS","CNE_ITEM",aAutoItens[nx,aScan(aAutoItens[nx],{|x| AllTrim(x[1])=="CNE_ITEM"}),2]})
	Next
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa rotina automatica               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (IsInCallStack("TECA930") .Or. IsInCallStack("ApurJobAux")) .OR. ( FindFunction("TEC930Test") .AND. TEC930Test() )
	lRetAut := CN121Auto(xAutoCab,xAutoItens,nOpcAuto,aAutoExced,aMltsGCT,aDescMed,aPlan,lAgrup)
Endif

aAutoExced := {}
aMultasGCT := {}

Return( xRet )
