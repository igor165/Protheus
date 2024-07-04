#INCLUDE "ctba381.ch"
#Include "PROTHEUS.Ch"

#DEFINE MAX_LINHA		999

// 17/08/2009 -- Filial com mais de 2 caracteres

Static aFormBatch:={} 
Static nQtdEntid

// TRADUÇÃO RELEASE P10 1.2 - 21/07/08
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CTBA381  ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 22.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo da Variacao Monetaria                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBA381(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf. Medrano³01/11/16³SERINN001-465³excluye creacion de tabla temporal ³±±
±±³            ³        ³          ³-y se asigna FWTemporaryTable en Func ³±±
±±³            ³        ³          ³Ct381Proc. Se elimina func AlteraSX1()³±±
±±³LuisEnriquez³17/09/19³DMINA-7388³En func. Ct381Proc se modifican ctas  ³±±
±±³            ³        ³          ³para perdidas/ganacias para ctas deu- ³±±
±±³            ³        ³          ³doras y acreedoras (PER)              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBA381()

Local nOpca := 0
Local aSays := {}
Local aButtons := {}
Local aCols := {}
Local lCC	:= .F.
Local lIT	:= .F.
Local lCL	:= .F.


Private cCadastro := STR0001 //"Calculo da Variacao Monetaria"
Private cSeqCorr  := ""
Private oTmpTable
Private lAutomato := isblind()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta pergunta 04, desabiltando-a para o Chile.		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "CHI"
	AjustaCT5()
EndIf

If cPaisLoc == "BRA"
	AjustaCT5B()
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01 // Data de Apuracao                                 ³
//³ mv_par02 // Numero do Lote			                         ³
//³ mv_par03 // Numero do SubLote		                         ³
//³ mv_par04 // Numero do Documento                              ³
//³ mv_par05 // Cod. Historico Padrao                            ³
//³ mv_par06 // Da Conta  		        				         ³
//³ mv_par07 // Ate a Conta                             		 ³
//³ mv_par08 // Moeda Base                                       ³
//³ mv_par09 // Tipo de Saldo 				                     ³
//³ mv_par10 // Desmembra Lcto    			                     ³
//³ mv_par11 // Considera Criterio - Moeda / Plano de Contas     ³
//³ mv_par12 // Taxa de conversao informada                      ³
//³ mv_par13 // Considera Custo					                 ³
//³ mv_par14 // Considera Item				                     ³
//³ mv_par15 // Considera ClVl				                     ³
//³ mv_par16 // Metodo de Variacao 				                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Pergunte("CT381A",.T.)
    Ct381Moedas(aCols)

	AADD(aSays, STR0002) //"O programa objetiva apurar a diferenca cambial (Variacao Monetaria) das moedas fortes."
	AADD(aSays, STR0003) //"O Criterio de conversao e informado no cadastro da propria moeda, podendo ser"
	AADD(aSays, STR0004) //"confirmado na rotina de acordo com os parametros. Os criterios existentes sao :"
	AADD(aSays, STR0005) //"Medio - a taxa simples entre as cotacoes diarias do periodo."
	AADD(aSays, STR0006) //"Mensal - a taxa do ultimo dia do mes ou do periodo contabil."
	AADD(aSays, STR0007) //"Diario - taxa no dia do efetivo lancamento contabil."
	AADD(aSays, STR0008) //"Informado - taxa a ser utilizada e informada."
	if !lAutomato
		AADD(aButtons, { 5,.T., 	{|| (Pergunte("CT381A",.T. ), .T.) } } )
		AADD(aButtons, { 1,.T., 	{|| nOpca:= 1, If( ConaOk(),FechaBatch(), nOpca:=0 ) }} )
		AADD(aButtons, { 2,.T., 	{|| FechaBatch() }} )

		FormBatch( cCadastro, aSays, aButtons )
	Endif

	lCC	:= IF(MV_PAR13 == 1,.T.,.F.)
	lIT	:= IF(MV_PAR14 == 1,.T.,.F.)
	lCL	:= IF(MV_PAR15 == 1,.T.,.F.)
	nOpca := iif(lAutomato,1,nOpca)
	If nOpca == 1
		If FindFunction("CTBSERIALI")
			If !CTBSerialI("CTBPROC","OFF")
				Return
			Endif
		EndIf
		If !lAutomato
			Processa({|lEnd| Ct381Proc(aCols,lCC,lIT,lCL)})
		Else
			Ct381Proc(aCols,lCC,lIT,lCL)
		Endif
		If FindFunction("CTBSERIALI")
			CtbSerialF("CTBPROC","OFF")
		EndIF
	EndIf
Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ca381Proc ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 22.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Recalculo valor lanc moeda forte                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ca381Proc()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CONA381                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ct381Proc(aCols,lCC,lIT,lCl)
Local lRet        := .F.
Local cHistorico  := ""
Local bHistorico
Local aFormat     := {}
Local cDoc        := MV_PAR04
Local cLinha      := "001"
Local cSeqLan     := "000"
Local nValorLanc  := 0
Local cContaRed   := "", cTipo
Local cCustoDeb   := ""
Local cCustoCrd   := ""
Local cItemDeb    := ""
Local cItemCrd    := ""
Local cTpSald     := ""
Local lAtSldBase  := Iif(GetMv("MV_ATUSAL")== "S",.T.,.F.)
Local cCriter, nTaxa := 0, aMedias := CtbMedias(FirstDay(mv_par01), LastDay(mv_par01))
Local cDebito     := ""
Local cCredito    := ""
Local cEmpOri     := cEmpAnt
Local cFilOri     := cFilAnt
Local nSldMoeda   := 0.00
Local nSldMoedForte := 0.00
Local aCampos     := {}
Local cLote       := CriaVar("CT2_LOTE")
Local cMensagem   := ""
Local nMoeda      := Val(mv_par08)
Local aColsOri
Local nValorAux   := 0
Local cCustoRed   := ""
Local cCustoVM    := ""
Local cItemRed    := ""
Local cItemVM     := ""
Local cClVlRed    := ""
Local cClVLVM     := ""

Local cFilCT1     := ""
Local cFilCTT     := ""
Local cFilCTD     := ""
Local cFilCTH     := ""
Local nVlrLctCT3  := 3
Local nVlrLctCTI  := 1
Local nVlrLctCT4  := 2

Local aVlrLct
Local nX
Local cContaReg   := ""
Local lTrueDoc
Local __lCusto    := .F. //CtbMovSaldo("CTT") .and. mv_par13 == 1 .and. lCC
Local __lItem     := .F. //CtbMovSaldo("CTD") .and. mv_par14 == 1 .and. lIT
Local __lCLVL     := .F. //CtbMovSaldo("CTH") .and. mv_par15 == 1 .and. lCL

Local cMoedaForte := GetMv("MV_CTBMFOR",.F.,"")
Local nMoedPos    := 0

Local nQuantas    := CtbMoedas()
Local cMoedaRef   := ""
Local cMoedaVar   := ""
Local nTaxaVar    := 0.00
Local nTaxaCorr   := 0.00
Local nSldMoedUSD := 0.00
Local aTravas     := {}
Local aOrdem      := {}

Local cClVlDeb    := ""
Local cClVlCrd    := ""
Local nTamDec     := TamSX3("CT2_VALOR")[2]
Local lGrvMFort   := .F.
Local nVlConta    := 0
Local nVlCusto    := 0
Local nVlItem     := 0
Local cConta      := ""
Local cCusto      := ""
Local cItem       := ""
Local aEntid      := Ctb381OEnt()

Private cCorrel   := "" 

DEFAULT lCC	 := .F.
DEFAULT lIT	 := .F.
DEFAULT lCL	 := .F.

//sempre testar depois da chamada ctb381OEnt()
If Empty(aEntid)
	aEntid := NIL
EndIf

mv_par17 := "03"

__lCusto	:= CtbMovSaldo("CTT") .and. lCC
__lItem	  	:= CtbMovSaldo("CTD") .and. lIT
__lCLVL	  	:= CtbMovSaldo("CTH") .and. lCL

aCampos = { { "TRB_DATA"	,"D", TamSX3("CT2_DATA")[1]		,TamSX3("CT2_DATA")[2]		},;
{ "TRB_LOTE" 	,"C", TamSX3("CT2_LOTE")[1]		,TamSX3("CT2_LOTE")[2]		},;
{ "TRB_SBLOTE"	,"C", TamSX3("CT2_SBLOTE")[1]	,TamSX3("CT2_SBLOTE")[2]	},;
{ "TRB_DOC"		,"C", TamSX3("CT2_DOC")[1]		,TamSX3("CT2_DOC")[2]		},;
{ "TRB_LINHA"	,"C", TamSX3("CT2_LINHA")[1]	,TamSX3("CT2_LINHA")[2]		},;
{ "TRB_FILORI"	,"C", TamSX3("CT2_FILORI")[1]	,TamSX3("CT2_FILORI")[2]	},;
{ "TRB_EMPORI"	,"C", TamSX3("CT2_EMPORI")[1]	,TamSX3("CT2_EMPORI")[2]	},;
{ "TRB_DC"		,"C", TamSX3("CT2_DC")[1]		,TamSX3("CT2_DC")[2]		},;
{ "TRB_DEBITO"	,"C", TamSX3("CT2_DEBITO")[1]	,TamSX3("CT2_DEBITO")[2]	},;
{ "TRB_CREDIT"	,"C", TamSX3("CT2_CREDIT")[1]	,TamSX3("CT2_CREDIT")[2]	},;
{ "TRB_MOEDLC"	,"C", TamSX3("CT2_MOEDLC")[1]	,TamSX3("CT2_MOEDLC")[2]	},;
{ "TRB_VALOR"	,"N", TamSX3("CT2_VALOR")[1]	,TamSX3("CT2_VALOR")[2]		},;
{ "TRB_MOEDAS"	,"C", TamSX3("CT2_MOEDAS")[1]	,TamSX3("CT2_MOEDAS")[2]	},;
{ "TRB_HP"		,"C", TamSX3("CT2_HP")[1]		,TamSX3("CT2_HP")[2]		},;
{ "TRB_CCD"		,"C", TamSX3("CT2_CCD")[1]		,TamSX3("CT2_CCD")[2]		},;
{ "TRB_CCC"		,"C", TamSX3("CT2_CCC")[1]		,TamSX3("CT2_CCC")[2]		},;
{ "TRB_ITEMD"	,"C", TamSX3("CT2_ITEMD")[1]	,TamSX3("CT2_ITEMD")[2]		},;
{ "TRB_ITEMC"	,"C", TamSX3("CT2_ITEMC")[1]	,TamSX3("CT2_ITEMC")[2]		},;
{ "TRB_CLVLDB"	,"C", TamSX3("CT2_CLVLDB")[1]	,TamSX3("CT2_CLVLDB")[2]	},;
{ "TRB_CLVLCR"	,"C", TamSX3("CT2_CLVLCR")[1]	,TamSX3("CT2_CLVLCR")[2]	},;
{ "TRB_HIST"	,"C", TamSX3("CT2_HIST")[1]		,TamSX3("CT2_HIST")[2]		},;
{ "TRB_SEQHIS"	,"C", TamSX3("CT2_SEQHIS")[1]	,TamSX3("CT2_SEQHIS")[2]	},;
{ "TRB_TPSALD"	,"C", TamSX3("CT2_TPSALD")[1]	,TamSX3("CT2_TPSALD")[2]	},;
{ "TRB_SEQLAN"	,"C", TamSX3("CT2_SEQLAN")[1]	,TamSX3("CT2_SEQLAN")[2]	},;
{ "TRB_CRITER"	,"C", TamSX3("CT2_CRITER")[1]	,TamSX3("CT2_CRITER")[2]	},;
{ "TRB_ORIGEM"	,"C", TamSX3("CT2_ORIGEM")[1]	,TamSX3("CT2_ORIGEM")[2]	},;
{ "TRB_ROTINA"	,"C", TamSX3("CT2_ROTINA")[1]	,TamSX3("CT2_ROTINA")[2]	},;
{ "TRB_VLR01"	,"N", TamSX3("CT2_VLR01")[1]	,TamSX3("CT2_VLR01")[2]		},;
{ "TRB_VLR02"	,"N", TamSX3("CT2_VLR02")[1]	,TamSX3("CT2_VLR02")[2]		},;
{ "TRB_VLR03"	,"N", TamSX3("CT2_VLR03")[1]	,TamSX3("CT2_VLR03")[2]		},;
{ "TRB_VLR04"	,"N", TamSX3("CT2_VLR04")[1]	,TamSX3("CT2_VLR04")[2]		},;
{ "TRB_VLR05"	,"N", TamSX3("CT2_VLR05")[1]	,TamSX3("CT2_VLR05")[2]		} }

aOrdem := {"TRB_DATA","TRB_LOTE","TRB_SBLOTE","TRB_DOC","TRB_SEQLAN"}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Cierra el TRB si ha quedado abierto (Ariel 09/07/04)
If Select( "TRB" ) != 0
	TRB->( dbCloseArea() )
EndIf

oTmpTable := FWTemporaryTable():New("TRB")
oTmpTable:SetFields( aCampos ) //AMB
oTmpTable:AddIndex("T1ORD", aOrdem)

oTmpTable:Create()
// Sub-Lote somente eh informado se estiver em branco
mv_par03 := If(Empty(GetMV("MV_SUBLOTE")), mv_par03, GetMV("MV_SUBLOTE"))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Antes de iniciar o processamento, verifico os parametros ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case Empty(mv_par01) // Data de referencia nao preenchida.
		Help(" ",1,"NOCTBDTLP")
	Case Empty(mv_par02)	// Lote nao preenchido
		Help(" ",1,"NOCT280LOT")
	Case Empty(mv_par03) // Sub Lote nao preenchido
		Help(" ",1,"NOCTSUBLOT")
	Case Empty(mv_par04) .and. cPaisLoc <> "CHI"	// Documento nao preenchido.
		Help(" ",1,"NOCT280DOC")
	Case Empty(mv_par05) // Historico Padrao nao preenchido
		Help(" ",1,"CTHPVAZIO")
	Case Empty(mv_par06) .And. Empty(mv_par07)// Rateio inicial e final nao preenchidos.
		Help(" ",1,"NOCT280RT")
	Case Empty(mv_par08)	//Se o codigo da moeda base estiver em branco
		Help(" ",1,"NOCTMOEDA")
	Case Empty(mv_par09) // Tipo de saldo nao preenchido
		Help(" ",1,"NO280TPSLD")
	OtherWise
		lRet := .T.
EndCase

If lRet	//Verificar se o calendario esta aberto
	lRet	:= CtbValiDt(1,mv_par01,,mv_par09)
EndIf

If lRet
	//A moeda nao podera ser preenchida com '01', pois nao existem os campos CT1_CVD01 e CT1_CVC01
	If mv_par08 == '01' .and. !(cPaisLoc $ "BOL|URU")
		lRet  := .F.
		cMensagem	:= STR0016	//"Moeda nao podera ser '01', pois os campos CT1_CVD01 e CT1_CVC01 nao existem."
		MsgAlert(cMensagem)
	EndIf
EndIf

If lRet // Parametros validos, posiciona o CT8 (Historico padrao)
	dbSelectArea("CT8")
	dbSetOrder(1)
	If !dbSeek(xFilial("CT8")+mv_par05)
		//Historico Padrao nao existe no cadastro.
		Help(" ",1,"CT280NOHP")
		lRet := .F.
	Else
		cHistorico := ""
		If CT8->CT8_IDENT == 'C'
			cHistorico := CT8->CT8_DESC
			// Bloco para retornar a conta origem no historico
			bHistorico := {	||	Alltrim(cHistorico) + " " + StrZero(Month(mv_par01),2)+"/"+;
			StrZero(Year(mv_par01),4) }
		Else
			aFormat := {}
			While !Eof() .And. CT8->CT8_HIST == mv_par05 .And. CT8->CT8_IDENT == 'I'
				Aadd(aFormat,CT8->CT8_DESC)
				dbSkip()
			Enddo
			cHistorico := MSHGetText(aFormat)
			bHistorico := {||AllTrim(cHistorico)}
		Endif
	Endif
Endif


If lRet .AND. MV_PAR16 == 2 // VARIACAO NA MOEDA FORTE
	//VERIFICA SE O CAMPO CT1_MOEDVM EXISTE E ESTA SENDO USADO
	// TODO CINTIA: TRANSFORMAR TEXTO EM STRxxxx
	If CT1->(FieldPos("CT1_MOEDVM")) == 0
		ApMsgInfo(STR0017,STR0018)
		lRet := .F.
	Elseif ! X3USADO("CT1_MOEDVM")
		ApMsgInfo(STR0019,STR0018)
		lRet := .F.
	Endif
Endif

If ! lRet
	Return
EndIf

////////////////////////////
//  - DAVI - Bops 133395 -//
////////////////////////////
CTP->(DbSetOrder(1))

dbSelectArea("CT1")
dbSetOrder(1)
cFilCT1   := xFilial("CT1")
dbSelectArea("CTT")
dbSetOrder(1)
cFilCTT	  := xFilial("CTT")
dbSelectArea("CTD")
dbSetOrder(1)
cFilCTD   := xFilial("CTD")
dbSelectArea("CTH")
dbSetOrder(1)
cFilCTH	  := xFilial("CTH")

DbSelectArea("CTO")
dbSetOrder(1)

aColsOri := Aclone(aCols)
///////////////////////////////////////////////////////////////////////////////////////
cAlias	:= "QRYTMP"

cQuery := "SELECT CQ1_CONTA CONTA , '' CUSTO , '' ITEM , '' CLVL "
cQuery += " ,'4' ORDEM , 'CQ1' TABELA , CT1_CTAVM CTAVM , CT1_CTARED CTARED , '' CCVM "
cQuery += " ,'' CCRED , '' ITVM , '' ITRED  , '' CLVM ,'' CLRED "

	//Variação Monetaria Negativa
If cPaisLoc == "PER
	cQuery += " ,CT1_NORMAL NORMAL,CT1_CTAVMN CTAVMN , CT1_CTARDN CTARDN , ''  CCVMN , '' CCRDN "
	cQuery += " ,'' ITVMN , '' ITRDN , '' CLVMN , '' CLRDN "
EndIf

If MV_PAR16 == 2
	cQuery += ", CT1.CT1_MOEDVM MOEDVM "
EndIf

cQuery += " FROM "+RetSqlName("CQ1")+" CQ1, "+RetSqlName("CT1")+" CT1 "
cQuery += " WHERE CQ1.CQ1_FILIAL = '"+xFilial("CQ1")+"' "
cQuery += " AND CQ1.CQ1_CONTA BETWEEN '"+mv_par06+"' AND '"+mv_par07+"' "

If MV_PAR16 == 1
	cQuery += " AND CQ1_MOEDA IN ('01','"+mv_par08+"') "
Endif

cQuery += " AND CQ1_DATA <= '"+DTOS(mv_par01)+"' "
cQuery += " AND CQ1_TPSALD = '"+mv_par09+"' "
cQuery += " AND CQ1.D_E_L_E_T_ = '' "
cQuery += " AND CT1.CT1_FILIAL = '"+xFilial("CT1")+"' "
cQuery += " AND CT1.CT1_CONTA = CQ1.CQ1_CONTA "
cQuery += " AND CT1.CT1_CLASSE = '2' AND CT1.CT1_CTAVM <> '' "

If MV_PAR16 == 2
	cQuery += " AND CT1.CT1_MOEDVM = '"+mv_par08+"'"
Endif

cQuery += " AND CT1.D_E_L_E_T_ = '' "
cQuery += " GROUP BY CQ1_CONTA"
cQuery += " ,CT1_CTAVM,CT1_CTARED "

	//Variação Monetaria Negativa
If cPaisLoc == "PER"
	cQuery += " ,CT1_NORMAL,CT1_CTAVM,CT1_CTARED  ,CT1_CTAVMN,CT1_CTARDN "
endIf

If MV_PAR16 == 2
	cQuery += ", CT1_MOEDVM "
EndIf


If __lCusto
	cQuery += " UNION "
	cQuery += " SELECT CQ3_CONTA CONTA ,CQ3_CCUSTO CUSTO,'' ITEM,'' CLVL, '3' ORDEM, 'CQ3' TABELA "
	cQuery += " ,CT1_CTAVM CTAVM,CT1_CTARED CTARED "
	cQuery += " ,CTT_CCVM CCVM, CTT_CCRED CCRED "
	cQuery += " ,'' ITVM,'' ITRED,'' CLVM,'' CLRED"

		//Variação Monetaria Negativa
	If cPaisLoc == "PER"
		cQuery += " ,CT1_NORMAL ,CT1_CTAVMN CTAVMN,CT1_CTARDN CTARDN "
		cQuery += " ,CTT_CCVMN CCVMN, CTT_CCRDN CCRDN "
		cQuery += " ,'' ITVMN , '' ITRDN , '' CLVMN , '' CLRDN"
	endIf

	If MV_PAR16 == 2
		cQuery += ", CT1.CT1_MOEDVM MOEDVM "
	Endif

	cQuery += " FROM "+RetSqlName("CQ3")+" CQ3, "+RetSqlName("CTT")+" CTT, "+RetSqlName("CT1")+" CT1, "+RetSqlName("CQ1")+" CQ1 "
	cQuery += " WHERE CQ3.CQ3_FILIAL = '"+xFilial("CQ3")+"' "
	cQuery += " AND CQ3.CQ3_CONTA BETWEEN '"+mv_par06+"' AND '"+mv_par07+"' "

	If MV_PAR16 == 1
		cQuery += " AND CQ1_MOEDA IN ('01','"+mv_par08+"') "
	Endif

	cQuery += " AND CQ3_DATA <= '"+DTOS(mv_par01)+"' "
	cQuery += " AND CQ3_TPSALD = '"+mv_par09+"' "
	cQuery += " AND CQ3.D_E_L_E_T_ = '' "
	cQuery += " AND CTT.CTT_FILIAL = '"+xFilial("CTT")+"' "
	cQuery += " AND CTT.CTT_CUSTO = CQ3.CQ3_CCUSTO "
	cQuery += " AND CTT.CTT_CLASSE = '2' AND CTT.CTT_CCVM <> '' "
	cQuery += " AND CTT.D_E_L_E_T_ = '' "
	cQuery += " AND CT1.CT1_FILIAL = '"+xFilial("CT1")+"' "
	cQuery += " AND CT1.CT1_CONTA = CQ3.CQ3_CONTA "
	cQuery += " AND CT1.CT1_CLASSE = '2' AND CT1.CT1_CTAVM <> '' "

	If MV_PAR16 == 2
		cQuery += " AND CT1.CT1_MOEDVM = '"+mv_par08+"'"
	Endif

	cQuery += " AND CT1.D_E_L_E_T_ = '' "
	cQuery += " GROUP BY CQ3_CONTA,CQ3_CCUSTO "
	cQuery += " ,CT1_CTAVM,CT1_CTARED "
	cQuery += " ,CTT_CCVM,CTT_CCRED "

		//Variação Monetaria Negativa
	If cPaisLoc == "PER"
		cQuery += " ,CT1_NORMAL,CT1_CTAVMN,CT1_CTARDN "
		cQuery += " ,CTT_CCVMN,CTT_CCRDN "
		cQuery += " ,CTT_CCVMN,CTT_CCRDN "
	endIf
	If MV_PAR16 == 2
		cQuery += ", CT1_MOEDVM "
	EndIf
EndIf


If __lItem
	cQuery += " UNION "
	cQuery += " SELECT CQ5_CONTA CONTA ,CQ5_CCUSTO CUSTO,CQ5_ITEM ITEM,'' CLVL,'2' ORDEM, 'CQ5' TABELA "
	cQuery += " ,CT1_CTAVM CTAVM,CT1_CTARED CTARED "
	cQuery += " ,CTT_CCVM CCVM, CTT_CCRED CCRED "
	cQuery += " ,CTD_ITVM ITVM,CTD_ITRED ITRED "
	cQuery += " ,'' CLVM,'' CLRED "

		//Variação Monetaria Negativa
	If cPaisLoc == "PER"
		cQuery += " ,CT1_NORMAL,CT1_CTAVMN CTAVMN, CT1_CTARDN CTARDN "
		cQuery += " ,CTT_CCVMN CCVMN, CTT_CCRDN CCRDN "
		cQuery += " ,CTD_ITVMN ITVMN,CTD_ITRDN ITRDN "
		cQuery += " , '' CLVMN , '' CLRDN "
	endIf

	If MV_PAR16 == 2
		cQuery += ", CT1.CT1_MOEDVM MOEDVM "
	Endif

	cQuery += " FROM "+RetSqlName("CQ5")+" CQ5, "+RetSqlName("CTD")+" CTD, "+RetSqlName("CTT")+" CTT, "+RetSqlName("CT1")+" CT1, "+RetSqlName("CQ1")+" CQ1 "
	cQuery += " WHERE CQ5.CQ5_FILIAL = '"+xFilial("CQ5")+"' "
	cQuery += " AND CQ5.CQ5_CONTA BETWEEN '"+mv_par06+"' AND '"+mv_par07+"' "

	If MV_PAR16 == 1
		cQuery += " AND CQ1_MOEDA IN ('01','"+mv_par08+"') "
	Endif

	cQuery += " AND CQ5_DATA <= '"+DTOS(mv_par01)+"' "
	cQuery += " AND CQ5_TPSALD = '"+mv_par09+"' "
	cQuery += " AND CQ5.D_E_L_E_T_ = '' "
	cQuery += " AND CTD.CTD_FILIAL = '"+xFilial("CTD")+"' "
	cQuery += " AND CTD.CTD_ITEM = CQ5.CQ5_ITEM "
	cQuery += " AND CTD.CTD_CLASSE = '2' AND CTD.CTD_ITVM <> '' "
	cQuery += " AND CTD.D_E_L_E_T_ = '' "
	cQuery += " AND CTT.CTT_FILIAL = '"+xFilial("CTT")+"' "
	cQuery += " AND CTT.CTT_CUSTO = CQ5.CQ5_CCUSTO "
	cQuery += " AND CTT.CTT_CLASSE = '2' AND CTT.CTT_CCVM <> '' "
	cQuery += " AND CTT.D_E_L_E_T_ = '' "
	cQuery += " AND CT1.CT1_FILIAL = '"+xFilial("CT1")+"' "
	cQuery += " AND CT1.CT1_CONTA = CQ5.CQ5_CONTA "
	cQuery += " AND CT1.CT1_CLASSE = '2' AND CT1.CT1_CTAVM <> '' "

	If MV_PAR16 == 2
		cQuery += " AND CT1.CT1_MOEDVM = '"+mv_par08+"'"
	Endif

	cQuery += " AND CT1.D_E_L_E_T_ = '' "
	cQuery += " GROUP BY CQ5_CONTA,CQ5_CCUSTO,CQ5_ITEM "
	cQuery += " ,CT1_CTAVM,CT1_CTARED "
	cQuery += " ,CTT_CCVM,CTT_CCRED "
	cQuery += " ,CTD_ITVM,CTD_ITRED "
		//Variação Monetaria Negativa
	If cPaisLoc == "PER"
		cQuery += " ,CT1_NORMAL,CT1_CTAVMN,CT1_CTARDN "
		cQuery += " ,CTT_CCVMN,CTT_CCRDN "
		cQuery += " ,CTD_ITVMN,CTD_ITRDN "
	endIf
	If MV_PAR16 == 2
		cQuery += ", CT1_MOEDVM "
	EndIf

	cQuery += " UNION "
	cQuery += " SELECT CQ5_CONTA CONTA ,CQ5_CCUSTO CUSTO,CQ5_ITEM ITEM,'' CLVL,'2' ORDEM, 'CQ5' TABELA "
	cQuery += " ,CT1_CTAVM CTAVM,CT1_CTARED CTARED "
	cQuery += " ,'' CCVM, '' CCRED "
	cQuery += " ,CTD_ITVM ITVM,CTD_ITRED ITRED "
	cQuery += " ,'' CLVM,'' CLRED "

		//Variação Monetaria Negativa
	If cPaisLoc == "PER"
		cQuery += " ,CT1_NORMAL,CT1_CTAVMN CTAVMN, CT1_CTARDN CTARDN "
		cQuery += " ,CTT_CCVMN CCVMN, CTT_CCRDN CCRDN "
		cQuery += " ,CTD_ITVMN ITVMN,CTD_ITRDN ITRDN "
		cQuery += " , '' CLVMN , '' CLRDN "
	endIf

	If MV_PAR16 == 2
		cQuery += ", CT1.CT1_MOEDVM MOEDVM "
	Endif

	cQuery += " FROM "+RetSqlName("CQ5")+" CQ5, "+RetSqlName("CTD")+" CTD, "+RetSqlName("CTT")+" CTT, "+RetSqlName("CT1")+" CT1, "+RetSqlName("CQ1")+" CQ1 "
	cQuery += " WHERE CQ5.CQ5_FILIAL = '"+xFilial("CQ5")+"' "
	cQuery += " AND CQ5.CQ5_CONTA BETWEEN '"+mv_par06+"' AND '"+mv_par07+"' "

	If MV_PAR16 == 1
		cQuery += " AND CQ1_MOEDA IN ('01','"+mv_par08+"') "
	Endif

	cQuery += " AND CQ5_DATA <= '"+DTOS(mv_par01)+"' "
	cQuery += " AND CQ5_TPSALD = '"+mv_par09+"' "
	cQuery += " AND CQ5.D_E_L_E_T_ = '' "
	cQuery += " AND CTD.CTD_FILIAL = '"+xFilial("CTD")+"' "
	cQuery += " AND CTD.CTD_ITEM = CQ5.CQ5_ITEM "
	cQuery += " AND CTD.CTD_CLASSE = '2' AND CTD.CTD_ITVM <> '' "
	cQuery += " AND CTD.D_E_L_E_T_ = '' "
	cQuery += " AND CQ5.CQ5_CCUSTO = '' "
	cQuery += " AND CT1.CT1_FILIAL = '"+xFilial("CT1")+"' "
	cQuery += " AND CT1.CT1_CONTA = CQ5.CQ5_CONTA "
	cQuery += " AND CT1.CT1_CLASSE = '2' AND CT1.CT1_CTAVM <> '' "

	If MV_PAR16 == 2
		cQuery += " AND CT1.CT1_MOEDVM = '"+mv_par08+"'"
	Endif

	cQuery += " AND CT1.D_E_L_E_T_ = '' "
	cQuery += " GROUP BY CQ5_CONTA,CQ5_CCUSTO, CQ5_ITEM "
	cQuery += " ,CT1_CTAVM,CT1_CTARED "
	cQuery += " ,CTD_ITVM,CTD_ITRED "
		//Variação Monetaria Negativa
	If cPaisLoc == "PER"
		cQuery += " ,CT1_NORMAL,CT1_CTAVMN,CT1_CTARDN "
		cQuery += " ,CTT_CCVMN,CTT_CCRDN "
		cQuery += " ,CTD_ITVMN,CTD_ITRDN "
	endIf
	If MV_PAR16 == 2
		cQuery += ", CT1_MOEDVM "
	EndIf


EndIf

If __lClvl
	cQuery += " UNION "
	cQuery += " SELECT CQ7_CONTA CONTA ,CQ7_CCUSTO CUSTO,CQ7_ITEM ITEM,CQ7_CLVL CLVL,'1' ORDEM, 'CQ7' TABELA "
	cQuery += " ,CT1_CTAVM CTAVM,CT1_CTARED CTARED "
	cQuery += " ,CTT_CCVM CCVM, CTT_CCRED CCRED "
	cQuery += " ,CTD_ITVM ITVM,CTD_ITRED ITRED "
	cQuery += " ,CTH_CLVM CLVM,CTH_CLRED CLRED "

		//Variação Monetaria Negativa
	If cPaisLoc == "PER"
		cQuery += " ,CT1_NORMAL,CT1_CTAVMN CTAVMN, CT1_CTARDN CTARDN "
		cQuery += " ,CTT_CCVMN CCVMN, CTT_CCRDN CCRDN "
		cQuery += " ,CTD_ITVMN ITVMN,CTD_ITRDN ITRDN "
		cQuery += " ,CTH_CLVMN CLVMN,CTH_CLRDN CLRDN "
	endIf

	If MV_PAR16 == 2
		cQuery += ", CT1.CT1_MOEDVM MOEDVM "
	Endif

	cQuery += " FROM "+RetSqlName("CQ7")+" CQ7, "+RetSqlName("CTH")+" CTH, "+RetSqlName("CTD")+" CTD, "+RetSqlName("CTT")+" CTT, "+RetSqlName("CT1")+" CT1, "+RetSqlName("CQ1")+" CQ1 "
	cQuery += " WHERE CQ7.CQ7_FILIAL = '"+xFilial("CQ7")+"' "
	cQuery += " AND CQ7.CQ7_CONTA BETWEEN '"+mv_par06+"' AND '"+mv_par07+"' "

	If MV_PAR16 == 1
		cQuery += " AND CQ1_MOEDA IN ('01','"+mv_par08+"') "
	Endif

	cQuery += " AND CQ7_DATA <= '"+DTOS(mv_par01)+"' "
	cQuery += " AND CQ7_TPSALD = '"+mv_par09+"' "
	cQuery += " AND CQ7.D_E_L_E_T_ = '' "
	cQuery += " AND CTH.CTH_FILIAL = '"+xFilial("CTH")+"' "
	cQuery += " AND CTH.CTH_CLVL = CQ7.CQ7_CLVL "
	cQuery += " AND CTH.CTH_CLASSE = '2' AND CTH.CTH_CLVM <> '' "
	cQuery += " AND CTH.D_E_L_E_T_ = '' "
	cQuery += " AND CTD.CTD_FILIAL = '"+xFilial("CTD")+"' "
	cQuery += " AND CTD.CTD_ITEM = CQ7.CQ7_ITEM "
	cQuery += " AND CTD.CTD_CLASSE = '2' AND CTD.CTD_ITVM <> '' "
	cQuery += " AND CTD.D_E_L_E_T_ = ''  "
	cQuery += " AND CTT.CTT_FILIAL = '"+xFilial("CTT")+"' "
	cQuery += " AND CTT.CTT_CUSTO = CQ7.CQ7_CCUSTO "
	cQuery += " AND CTT.CTT_CLASSE = '2' AND CTT.CTT_CCVM <> '' "
	cQuery += " AND CTT.D_E_L_E_T_ = '' "
	cQuery += " AND CT1.CT1_FILIAL = '"+xFilial("CT1")+"' "
	cQuery += " AND CT1.CT1_CONTA = CQ7.CQ7_CONTA "
	cQuery += " AND CT1.CT1_CLASSE = '2' AND CT1.CT1_CTAVM <> '' "

	If MV_PAR16 == 2
		cQuery += " AND CT1.CT1_MOEDVM = '"+mv_par08+"'"
	Endif

	cQuery += " AND CT1.D_E_L_E_T_ = ''  "
	cQuery += " GROUP BY CQ7_CONTA,CQ7_CCUSTO, CQ7_ITEM,CQ7_CLVL "
	cQuery += " ,CT1_CTAVM,CT1_CTARED "
	cQuery += " ,CTT_CCVM,CTT_CCRED "
	cQuery += " ,CTD_ITVM,CTD_ITRED "
	cQuery += " ,CTH_CLVM,CTH_CLRED "
		//Variação Monetaria Negativa
	If cPaisLoc == "PER"
		cQuery += " ,CT1_NORMAL,CT1_CTAVMN,CT1_CTARDN "
		cQuery += " ,CTT_CCVMN,CTT_CCRDN "
		cQuery += " ,CTD_ITVMN,CTD_ITRDN "
		cQuery += " ,CTH_CLVMN,CTH_CLRDN "
	endIf
	If MV_PAR16 == 2
		cQuery += ", CT1_MOEDVM "
	EndIf

	cQuery += " UNION "
	cQuery += " SELECT CQ7_CONTA CONTA ,CQ7_CCUSTO CUSTO,CQ7_ITEM ITEM,CQ7_CLVL CLVL,'1' ORDEM, 'CQ7' TABELA "
	cQuery += " ,CT1_CTAVM CTAVM,CT1_CTARED CTARED "
	cQuery += " ,'' CCVM,'' CCRED "
	cQuery += " ,'' ITVM,'' ITRED "
	cQuery += " ,CTH_CLVM CLVM,CTH_CLRED CLRED "

		//Variação Monetaria Negativa
	If cPaisLoc == "PER"
		cQuery += " ,CT1_NORMAL,CT1_CTAVMN CTAVMN, CT1_CTARDN CTARDN "
		cQuery += " ,CTT_CCVMN CCVMN, CTT_CCRDN CCRDN "
		cQuery += " ,CTD_ITVMN ITVMN,CTD_ITRDN ITRDN "
		cQuery += " ,CTH_CLVMN CLVMN,CTH_CLRDN CLRDN "
	endIf

	If MV_PAR16 == 2
		cQuery += ", CT1.CT1_MOEDVM MOEDVM "
	Endif

	cQuery += " FROM "+RetSqlName("CQ7")+" CQ7, "+RetSqlName("CTH")+" CTH, "+RetSqlName("CTD")+" CTD, "+RetSqlName("CTT")+" CTT, "+RetSqlName("CT1")+" CT1, "+RetSqlName("CQ1")+" CQ1 "
	cQuery += " WHERE CQ7.CQ7_FILIAL = '"+xFilial("CQ7")+"' "
	cQuery += " AND CQ7.CQ7_CONTA BETWEEN '"+mv_par06+"' AND '"+mv_par07+"' "

	If MV_PAR16 == 1
		cQuery += " AND CQ1_MOEDA IN ('01','"+mv_par08+"') "
	Endif

	cQuery += " AND CQ7_DATA <= '"+DTOS(mv_par01)+"' "
	cQuery += " AND CQ7_TPSALD = '"+mv_par09+"' "
	cQuery += " AND CQ7.D_E_L_E_T_ = '' "
	cQuery += " AND CTH.CTH_FILIAL = '"+xFilial("CTH")+"' "
	cQuery += " AND CTH.CTH_CLVL = CQ7.CQ7_CLVL "
	cQuery += " AND CTH.CTH_CLASSE = '2' AND CTH.CTH_CLVM <> '' "
	cQuery += " AND CTH.D_E_L_E_T_ = '' "
	cQuery += " AND CTD.CTD_FILIAL = '"+xFilial("CTD")+"' "
	cQuery += " AND CTD.CTD_ITEM = CQ7.CQ7_ITEM "
	cQuery += " AND CTD.CTD_CLASSE = '2' AND CTD.CTD_ITVM <> '' "
	cQuery += " AND CQ7.CQ7_ITEM = ''  "
	cQuery += " AND CQ7.CQ7_CCUSTO = ''  "
	cQuery += " AND CTD.D_E_L_E_T_ = ''  "

	If MV_PAR16 == 2
		cQuery += " AND CT1.CT1_MOEDVM = '"+mv_par08+"'"
	Endif

	cQuery += " AND CT1.D_E_L_E_T_ = ''  "
	cQuery += " GROUP BY CQ7_CONTA,CQ7_CCUSTO, CQ7_ITEM,CQ7_CLVL "
	cQuery += " ,CT1_CTAVM,CT1_CTARED "
	cQuery += " ,CTH_CLVM,CTH_CLRED "
		//Variação Monetaria Negativa
	If cPaisLoc == "PER"
		cQuery += " ,CT1_NORMAL,CT1_CTAVMN,CT1_CTARDN "
		cQuery += " ,CTT_CCVMN,CTT_CCRDN "
		cQuery += " ,CTD_ITVMN,CTD_ITRDN "
		cQuery += " ,CTH_CLVMN,CTH_CLRDN "
	endIf
	If MV_PAR16 == 2
		cQuery += ", CT1_MOEDVM "
	EndIf

EndIf

cQuery += " ORDER BY  CONTA DESC ,CUSTO DESC ,ITEM DESC,CLVL DESC,ORDEM "


cQuery := ChangeQuery(cQuery)

If Select("QRYTMP") > 0
	dbSelectArea("QRYTMP")
	dbCloseArea()
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRYTMP",.T.,.T.)

dbSelectArea("QRYTMP")

cContaAtu := ""
cCustoAtu := ""
cItemAtu  := ""
cClvlAtu  := ""

//Como padrão a moeda forte é a moeda base definida para calculo da Variacao
//Método: variação pela moeda base (default)
cMoedaForte := IIF(Empty(cMoedaForte),mv_par08,cMoedaForte)

// Adiciono a Moeda 1 pois eh necessario para o laco de gravacao na funcao GravaLanc
// e Depois ordeno a matriz
aVlrLct:={}
DbSelectArea(cAlias)
dbGoTop()
While (cAlias)->(!Eof())

	// Moeda de referência para cálculo da variação, aonde:
	// Método da moeda base --> Considera a moeda de MV_PAR08(Moeda Base) ou MV_CTBMFOR
	// Método da moeda forte --> Considera todas as moedas nas quais a conta possuir saldo
	cConta := (cAlias)->CONTA
	nVlConta :=0
	While (cAlias)->CONTA == cConta .AND.(cAlias)->(!Eof())
		cCusto := (cAlias)->CUSTO
		nVlCusto :=0
		While (cAlias)->CUSTO == cCusto.AND.(cAlias)->CONTA == cConta .AND.(cAlias)->(!Eof())
			cItem := (cAlias)->ITEM
			nVlItem :=0
			While (cAlias)->ITEM == cItem .AND. (cAlias)->CUSTO == cCusto.AND.(cAlias)->CONTA == cConta .AND. (cAlias)->(!Eof())
				If cPaisLoc $ "BOL|URU"
					CT1->(DbSetOrder(1))
					CT1->(DbSeek(xFilial("CT1")+(cAlias)->CONTA))
					cMoedaForte := CT1->CT1_MOEDVM
					If cPaisLoc=="URU" .and. Empty(cMoedaForte) //Usado qdo Empty(CT1_MOEDVM) e considera MV_par08 como moeda forte
						cMoedaForte := mv_par08
						cMoedaForte := Ct381ConvMF(cMoedaForte)
					Endif
				Else
					cMoedaForte := Ct381ConvMF(cMoedaForte)
				EndIf

				If cMoedaForte == "01" .and. cPaisLoc $ "BOL|URU"
					nMoedas := IIF(MV_PAR16 == 1, 2, nQuantas)
				Else
					nMoedas := IIF(MV_PAR16 == 1, 1, nQuantas)
				EndIf
				If Len(aVlrLct)==0
					For nX := 1 to nMoedas
						AaDd(aVlrLct,{0,0,0,0})
					Next
			    Endif
				IF cPaisLoc == "BOL" .and. ( mv_par08 <> CT1->CT1_MOEDVM )
				    (cAlias)->(DbSkip())
					Loop
				ENDIF

				lContinua := .T.
				lGrvMFort := .F.
				For nMoeda := 1 to nMoedas

					cMoedaVar := STRZERO(nMoeda,2)

					//Para a variação por moeda base a moeda de referência é a própria moeda forte
					IF MV_PAR16 == 1
						cMoedaRef := cMoedaForte
					ELSE
						cMoedaRef := (cAlias)->MOEDVM
					ENDIF

					//Para a variacao por moeda forte esta moeda será a referencia de taxa
					//portanto não deve ser avaliada.
					IF MV_PAR16 == 2 .AND. cMoedaVar == cMoedaRef
						lContinua := .F.
						lGrvMFort := .T.
					ELSE
						lContinua := .T.
					ENDIF

					IF ! Empty((cAlias)->TABELA) .and. lContinua
						If cMoedaForte == "01" .and. cPaisLoc == "BOL"

							IF lCC .AND. (cAlias)->TABELA == "CQ3"
								nSldMoeda := SaldoCt3((cAlias)->CONTA,(cAlias)->CUSTO,mv_par01,"01")[1]
							ELSEIF lIT .AND. (cAlias)->TABELA == "CADMINT4"
								nSldMoeda := SaldoCt4((cAlias)->CONTA,(cAlias)->CUSTO,(cAlias)->ITEM,mv_par01,"01")[1]
							ELSEIF lCL .AND. (cAlias)->TABELA == "CQ7"
								nSldMoeda := SaldoCtI((cAlias)->CONTA,(cAlias)->CUSTO,(cAlias)->ITEM,(cAlias)->CLVL,mv_par01,"01")[1]
							ELSE
								nSldMoeda := SaldoCt7((cAlias)->CONTA,mv_par01,"01")[1]
							ENDIF

				        	nSldMoedUSD := 0.00
				        	IF lCC .AND. (cAlias)->TABELA == "CQ3"
								nSldMoedUSD := SaldoCt3((cAlias)->CONTA,(cAlias)->CUSTO,mv_par01,cMoedaVar)[1]
							ELSEIF lIT .AND. (cAlias)->TABELA == "CQ5"
								nSldMoedUSD := SaldoCt4((cAlias)->CONTA,(cAlias)->CUSTO,(cAlias)->ITEM,mv_par01,cMoedaVar)[1]
							ELSEIF lCL .AND. (cAlias)->TABELA == "CQ7"
								nSldMoedUSD := SaldoCtI((cAlias)->CONTA,(cAlias)->CUSTO,(cAlias)->ITEM,(cAlias)->CLVL,mv_par01,cMoedaVar)[1]
							ELSE
								nSldMoedUSD := SaldoCt7((cAlias)->CONTA,mv_par01,cMoedaVar)[1]
							ENDIF

							If nSldMoeda <> 0  .and. nSldMoedUSD <> 0

								If mv_par11 == 2 .AND. nMoeda > 1
									If CT1->CT1_NORMAL == "1"
										cCriter := &("CT1->CT1_CVD" + IIF(MV_PAR16 == 1,cMoedaVar,cMoedaRef))
									Else
											cCriter := &("CT1->CT1_CVC" + IIF(MV_PAR16 == 1,cMoedaVar,cMoedaRef))
									Endif
								Else	//Se utiliza o criterio de conversao da moeda
										CTO->(dbSeek(xFilial()+IIF(MV_PAR16 == 1,cMoedaRef,cMoedaVar),.T.))
										cCriter := 	CTO->CTO_CRITER
								EndIf

								If cCriter == "1" .And. CTP->(DbSeek(xFilial()+DTOS(mv_par01)+IIF(MV_PAR16 == 1,cMoedaVar,cMoedaRef)))
										nTaxa := CTP->CTP_TAXA
									If nTaxa <= 1
										   SM2->( DbSetOrder(1) )
									   If SM2->( DbSeek( DTOS(mv_par01) ) )
										      nTaxa := SM2->M2_MOEDA2
									   EndIf
									EndIf
								ElseIf cCriter == "2"
										nTaxa := aMedias[nMoeda]
								ElseIf cCriter == "3" .And. CTP->(DbSeek(xFilial()+DTOS(LastDay(mv_par01))+IIF(MV_PAR16 == 1,cMoedaVar,cMoedaRef)))
										nTaxa := CTP->CTP_TAXA
								ElseIf cCriter == "4"
										nTaxa := mv_par12
								EndIf

								If nTaxa > 0  .and. nSldMoeda <> nSldMoedUSD

							        		nTaxaCorr := GetUTaxa((cAlias)->CONTA,cMoedaVar)
					        		If nTaxaCorr == 0.00
							        		   	nTaxaCorr := Round(nSldMoeda/nSldMoedUSD,2)
					        		EndIf
									nValorLanc := (nSldMoeda/nTaxa)-(nSldMoeda/nTaxaCorr)

									// CARREGA O ACOLS COM CRITERIO E TAXA DA MOEDA BASE
									nMoedPos := Ascan(aCols,{|X|X[1] == cMoedaVar })

									IF nMoedPos > 0
												aCols[nMoedPos][2] := cCriter
												aCols[nMoedPos][6] := nTaxa
												aCols[nMoedPos][3] := ABS(nValorLanc)
												aCols[nMoedPos][4] := "1"
									ELSE
													nValorLanc := 0
									ENDIF
									If cPaisLoc=="URU"
										IF lCC .AND. (cAlias)->TABELA == "CQ3"
											If(aVlrLct[nMoeda][nVlrLctCT3]<>0,aVlrLct[nMoeda][nVlrLctCT3]+=nValorLanc,aVlrLct[nMoeda][nVlrLctCT3]:=nValorLanc)
											nValorLanc:=nValorLanc-(aVlrLct[nMoeda][nVlrLctCT4])
										ELSEIF lIT .AND. (cAlias)->TABELA == "CQ5"
											If(aVlrLct[nMoeda][nVlrLctCT4]<>0,aVlrLct[nMoeda][nVlrLctCT4]+=nValorLanc,aVlrLct[nMoeda][nVlrLctCT4]:=nValorLanc)
											nValorLanc:=nValorLanc-(aVlrLct[nMoeda][nVlrLctCTI])
										ELSEIF lCL .AND. (cAlias)->TABELA == "CQ7"
											If(aVlrLct[nMoeda][nVlrLctCTI]<>0,aVlrLct[nMoeda][nVlrLctCTI]+=nValorLanc,aVlrLct[nMoeda][nVlrLctCTI]:=nValorLanc)
										ELSE
											nValorLanc:=nValorLanc-(If((aVlrLct[nMoeda][nVlrLctCT3])<>0,(aVlrLct[nMoeda][nVlrLctCT3]),If((aVlrLct[nMoeda][nVlrLctCT4])<>0,(aVlrLct[nMoeda][nVlrLctCT4]),(aVlrLct[nMoeda][nVlrLctCTI]))))
										ENDIF
									Endif
								EndIf
							EndIf
						Elseif cMoedaForte == "01" .and. cPaisLoc == "URU"
			     			nSldMoedUSD := 0.00
				      	If lCC .And. (cAlias)->TABELA == "CQ3"
								nSldMoedUSD := SaldoCt3((cAlias)->CONTA,(cAlias)->CUSTO,mv_par01,cMoedaVar)[1]
							ElseIf lIT .And. (cAlias)->TABELA == "CQ5"
								nSldMoedUSD := SaldoCt4((cAlias)->CONTA,(cAlias)->CUSTO,(cAlias)->ITEM,mv_par01,cMoedaVar)[1]
							ElseIf lCL .And. (cAlias)->TABELA == "CQ7"
								nSldMoedUSD := SaldoCtI((cAlias)->CONTA,(cAlias)->CUSTO,(cAlias)->ITEM,(cAlias)->CLVL,mv_par01,cMoedaVar)[1]
							Else
								nSldMoedUSD := SaldoCt7((cAlias)->CONTA,mv_par01,cMoedaVar)[1]
							EndIf

							If nSldMoeda <> 0  .And. nSldMoedUSD <> 0
								If mv_par11 == 2 .And. nMoeda > 1
									If CT1->CT1_NORMAL == "1"
										cCriter := &("CT1->CT1_CVD" + cMoedaVar)
									Else
										cCriter := &("CT1->CT1_CVC" + cMoedaVar)
									Endif
								Else	//Se utiliza o criterio de conversao da moeda
									CTO->(dbSeek(xFilial("CTO")+cMoedaVar,.T.))
									cCriter := 	CTO->CTO_CRITER
								EndIf

								If cCriter == "1" .And. CTP->(DbSeek(xFilial("CTP")+DTOS(mv_par01)+cMoedaVar))
									nTaxa := CTP->CTP_TAXA
									If nTaxa <= 1
									   SM2->( DbSetOrder(1) )
									   If SM2->( DbSeek( DTOS(mv_par01) ) )
									      nTaxa := SM2->M2_MOEDA2
									   EndIf
									EndIf
								ElseIf cCriter == "2"
									nTaxa := aMedias[nMoeda]
								ElseIf cCriter == "3" .And. CTP->(DbSeek(xFilial("CTP")+DTOS(LastDay(mv_par01))+cMoedaVar))
									nTaxa := CTP->CTP_TAXA
								ElseIf cCriter == "4"
									nTaxa := mv_par12
								EndIf

								If nTaxa > 0  .and. nSldMoeda <> nSldMoedUSD

									nValorLanc := (nSldMoeda/nTaxa) - nSldMoedUSD

									// CARREGA O ACOLS COM CRITERIO E TAXA DA MOEDA BASE
									nMoedPos := Ascan(aCols,{|X|X[1] == cMoedaVar })

									If nMoedPos > 0
										aCols[nMoedPos][2] := "4"//cCriter
										aCols[nMoedPos][6] := nTaxa
										aCols[nMoedPos][3] := ABS(nValorLanc)
										aCols[nMoedPos][4] := "1"
									Else
										nValorLanc := 0
									EndIf
								EndIf
							EndIf
						Else
							If cPaisLoc<>"URU"
								IF lCC .AND. (cAlias)->TABELA == "CQ3"
									nSldMoeda := SaldoCt3((cAlias)->CONTA,(cAlias)->CUSTO,mv_par01,cMoedaVar)[1]
								ELSEIF lIT .AND. (cAlias)->TABELA == "CQ5"
									nSldMoeda := SaldoCt4((cAlias)->CONTA,(cAlias)->CUSTO,(cAlias)->ITEM,mv_par01,cMoedaVar)[1]
								ELSEIF lCL .AND. (cAlias)->TABELA == "CQ7"
									nSldMoeda := SaldoCtI((cAlias)->CONTA,(cAlias)->CUSTO,(cAlias)->ITEM,(cAlias)->CLVL,mv_par01,cMoedaVar)[1]
								ELSE
								nSldMoeda := SaldoCt7((cAlias)->CONTA,mv_par01,cMoedaVar)[1]
								ENDIF
					        	If nSldMoeda == 0 .and. cMoedaForte == '01' .and. cPaisLoc == "BOL"
					        		nSldMoeda  := SaldoCT7((cAlias)->CONTA,mv_par01,"01")[1]
					        		nSldMoeda  := xMoeda( nSldMoeda, 1, Val( cMoedaVar ), mv_par01 )
					        	EndIf
					   		Else
								If lCC .And. (cAlias)->TABELA == "CQ3"
									nSldMoeda := SaldoCt3((cAlias)->CONTA,(cAlias)->CUSTO,mv_par01,"01")[1]
								ElseIf lIT .And. (cAlias)->TABELA == "CQ5"
									nSldMoeda := SaldoCt4((cAlias)->CONTA,(cAlias)->CUSTO,(cAlias)->ITEM,mv_par01,"01")[1]
								ElseIf lCL .And. (cAlias)->TABELA == "CQ7"
									nSldMoeda := SaldoCtI((cAlias)->CONTA,(cAlias)->CUSTO,(cAlias)->ITEM,(cAlias)->CLVL,mv_par01,"01")[1]
								Else
									nSldMoeda := SaldoCt7((cAlias)->CONTA,mv_par01,"01")[1]
								EndIf
							Endif
							If nSldMoeda <> 0
								If cPaisLoc=="URU"
									// Taxa Moeda Forte
									If mv_par11 == 2 .And. nMoeda > 1
										If CT1->CT1_NORMAL == "1"
											cCriter := &("CT1->CT1_CVD" + cMoedaRef)
										Else
											cCriter := &("CT1->CT1_CVC" + cMoedaRef)
										Endif
									Else	//Se utiliza o criterio de conversao da moeda
											CTO->(dbSeek(xFilial()+cMoedaRef,.T.))
											cCriter := 	CTO->CTO_CRITER
									EndIf

									If cMoedaRef = "01"
										nTaxa := 1
									ElseIf cCriter == "1" .And. CTP->(DbSeek(xFilial("CTP")+DTOS(mv_par01)+cMoedaRef))
										nTaxa := CTP->CTP_TAXA
										If nTaxa <= 1
										   SM2->( DbSetOrder(1) )
										   If SM2->( DbSeek( DTOS(mv_par01) ) )
											      nTaxa := SM2->M2_MOEDA2
									   	EndIf
										EndIf
									ElseIf cCriter == "2"
											nTaxa := aMedias[nMoeda]
									ElseIf cCriter == "3" .And. CTP->(DbSeek(xFilial("CTP")+DTOS(LastDay(mv_par01))+cMoedaRef))
											nTaxa := CTP->CTP_TAXA
									ElseIf cCriter == "4"
										nTaxa := mv_par12
									EndIf

									// Taxa Moeda
									If mv_par11 == 2 .And. nMoeda > 1
										If CT1->CT1_NORMAL == "1"
											cCriter := &("CT1->CT1_CVD" + cMoedaVar)
										Else
											cCriter := &("CT1->CT1_CVC" + cMoedaVar)
										Endif
									Else	//Se utiliza o criterio de conversao da moeda
										CTO->(dbSeek(xFilial()+cMoedaVar,.T.))
										cCriter := 	CTO->CTO_CRITER
									EndIf

									If cMoedaVar = "01"
											nTaxaVar := 1
									ElseIf cCriter == "1" .And. CTP->(DbSeek(xFilial("CTP")+DTOS(mv_par01)+cMoedaVar))
											nTaxaVar := CTP->CTP_TAXA
										If nTaxaVar <= 1
											   SM2->( DbSetOrder(1) )
										   If SM2->( DbSeek( DTOS(mv_par01) ) )
											      nTaxaVar := SM2->M2_MOEDA2
										   EndIf
										EndIf
									ElseIf cCriter == "2"
											nTaxaVar := aMedias[nMoeda]
									ElseIf cCriter == "3" .And. CTP->(DbSeek(xFilial("CTP")+DTOS(LastDay(mv_par01))+cMoedaVar))
											nTaxaVar := CTP->CTP_TAXA
									ElseIf cCriter == "4"
											nTaxaVar := mv_par12
									EndIf

									If nTaxaVar > 0

										If lCC .And. (cAlias)->TABELA == "CQ3"
												nSldMoedForte := SaldoCt3((cAlias)->CONTA,(cAlias)->CUSTO,mv_par01,cMoedaRef)[1]
										ElseIf lIT .And. (cAlias)->TABELA == "CQ5"
												nSldMoedForte := SaldoCt4((cAlias)->CONTA,(cAlias)->CUSTO,(cAlias)->ITEM,mv_par01,cMoedaRef)[1]
										ElseIf lCL .And. (cAlias)->TABELA == "CQ7"
												nSldMoedForte := SaldoCtI((cAlias)->CONTA,(cAlias)->CUSTO,(cAlias)->ITEM,(cAlias)->CLVL,mv_par01,cMoedaRef)[1]
										Else
												nSldMoedForte := SaldoCt7((cAlias)->CONTA,mv_par01,cMoedaRef)[1]
										EndIf

										If nSldMoedForte <> 0 .or. cPaisLoc=="URU" .and. nSldMoedForte == 0 .and. nSldMoeda <> 0   //uruguai
												nValorLanc := ( nSldMoeda - (nSldMoedForte * nTaxa) ) / nTaxaVar
											If MV_PAR16 == 2 .And. cMoedaVar <> "01"
												If cPaisLoc $ "BOL|URU"
													cCriter := "4"
												EndIf
							  						// CARREGA O ACOLS COM CRITERIO E TAXA DAA MOEDA BASE
													nMoedPos := Ascan(aCols,{|X|X[1] == STRZERO(nMoeda,2)})
					   						If nMoedPos > 0
														aCols[nMoedPos][2] := cCriter
														aCols[nMoedPos][6] := nTaxa
														aCols[nMoedPos][3] := ABS(nValorLanc)
														aCols[nMoedPos][4] := "1"
												Else
													nValorLanc := 0
												EndIf
											EndIf
										EndIf
									EndIf
									IF lCC .AND. (cAlias)->TABELA == "CQ3"
										If(aVlrLct[nMoeda][nVlrLctCT3]<>0,aVlrLct[nMoeda][nVlrLctCT3]+=nValorLanc,aVlrLct[nMoeda][nVlrLctCT3]:=nValorLanc)
										nValorLanc:=nValorLanc-(aVlrLct[nMoeda][nVlrLctCT4])
									ELSEIF lIT .AND. (cAlias)->TABELA == "CQ5"
										If(aVlrLct[nMoeda][nVlrLctCT4]<>0,aVlrLct[nMoeda][nVlrLctCT4]+=nValorLanc,aVlrLct[nMoeda][nVlrLctCT4]:=nValorLanc)
										nValorLanc:=nValorLanc-(aVlrLct[nMoeda][nVlrLctCTI])
									ELSEIF lCL .AND. (cAlias)->TABELA == "CQ7"
										If(aVlrLct[nMoeda][nVlrLctCTI]<>0,aVlrLct[nMoeda][nVlrLctCTI]+=nValorLanc,aVlrLct[nMoeda][nVlrLctCTI]:=nValorLanc)
									ELSE
										nValorLanc:=nValorLanc-(If((aVlrLct[nMoeda][nVlrLctCT3])<>0,(aVlrLct[nMoeda][nVlrLctCT3]),If((aVlrLct[nMoeda][nVlrLctCT4])<>0,(aVlrLct[nMoeda][nVlrLctCT4]),(aVlrLct[nMoeda][nVlrLctCTI]))))
									ENDIF
						      Else
										// Taxa Moeda Forte
									If mv_par11 == 2 .AND. nMoeda > 1
										If CT1->CT1_NORMAL == "1"
											cCriter := &("CT1->CT1_CVD" + IIF(MV_PAR16 == 1,cMoedaRef,cMoedaVar))
										Else
											cCriter := &("CT1->CT1_CVC" + IIF(MV_PAR16 == 1,cMoedaRef,cMoedaVar))
										Endif
									Else	//Se utiliza o criterio de conversao da moeda
										CTO->(dbSeek(xFilial()+IIF(MV_PAR16 == 1,cMoedaRef,cMoedaVar),.T.))
										cCriter := 	CTO->CTO_CRITER
									EndIf

									If cCriter == "1" .And. CTP->(DbSeek(xFilial()+DTOS(mv_par01)+IIF(MV_PAR16 == 1,cMoedaRef,cMoedaVar)))
										nTaxa := CTP->CTP_TAXA
										If nTaxa <= 1
										   SM2->( DbSetOrder(1) )
										   If SM2->( DbSeek( DTOS(mv_par01) ) )
										      nTaxa := SM2->M2_MOEDA2
										   EndIf
										EndIf
									ElseIf cCriter == "2"
										nTaxa := aMedias[nMoeda]
									ElseIf cCriter == "3" .And. CTP->(DbSeek(xFilial()+DTOS(LastDay(mv_par01))+IIF(MV_PAR16 == 1,cMoedaRef,cMoedaVar)))
										nTaxa := CTP->CTP_TAXA
									ElseIf cCriter == "4"
										nTaxa := mv_par12
									EndIf

									If nTaxa > 0

										IF lCC .AND. (cAlias)->TABELA == "CQ3"
											nSldMoedForte := SaldoCt3((cAlias)->CONTA,(cAlias)->CUSTO,mv_par01,cMoedaRef)[1]
										ELSEIF lIT .AND. (cAlias)->TABELA == "CQ5"
											nSldMoedForte := SaldoCt4((cAlias)->CONTA,(cAlias)->CUSTO,(cAlias)->ITEM,mv_par01,cMoedaRef)[1]
										ELSEIF lCL .AND. (cAlias)->TABELA == "CQ7"
											nSldMoedForte := SaldoCtI((cAlias)->CONTA,(cAlias)->CUSTO,(cAlias)->ITEM,(cAlias)->CLVL,mv_par01,cMoedaRef)[1]
										ELSE
											nSldMoedForte := SaldoCt7((cAlias)->CONTA,mv_par01,cMoedaRef)[1]
										ENDIF

										IF nSldMoedForte <> 0


											IF MV_PAR16 == 1 // Variação pela moeda base
												nValorLanc := nSldMoeda - (nSldMoedForte * nTaxa)
											ELSE

												IF cMoedaVar == "01"
													nValorLanc := nSldMoeda - (nSldMoedForte * nTaxa)
												ELSE
													// NECESSITA CONVERTER PARA A MOEDA 01, POIS AS TAXAS SÃO EM RELAÇÃO A ESTA MOEDA
													nSldMoeda	:= xMoeda( nSldMoeda, Val( cMoedaVar ), 1, mv_par01 )
										    		nValorAux	:= nSldMoeda - ( nSldMoedForte * nTaxa )
										    		nValorLanc	:= xMoeda( nValorAux, 1, Val( cMoedaVar ), mv_par01 )

							  						// CARREGA O ACOLS COM CRITERIO E TAXA DAA MOEDA BASE
													nMoedPos := Ascan(aCols,{|X|X[1] == STRZERO(nMoeda,2)})
				    								IF nMoedPos > 0
														aCols[nMoedPos][2] := cCriter
														aCols[nMoedPos][6] := nTaxa
														aCols[nMoedPos][3] := ABS(nValorLanc)
														aCols[nMoedPos][4] := "1"
													ELSE
														nValorLanc := 0
													ENDIF
												ENDIF
											ENDIF
											IF (cAlias)->TABELA == "CQ3"
												nValorLanc := nValorLanc - nVlCusto
											ELSEIF (cAlias)->TABELA == "CQ5"
												nValorLanc := nValorLanc - nVlItem
											ELSEIF (cAlias)->TABELA == "CQ1"
												nValorLanc := nValorLanc - nVlConta
											ENDIF
										ENDIF
									EndIf
								ENDIF
							EndIf
							//Variação Monetaria Negativa
							If cPaisLoc == "PER"
								If (ABS(nSldMoeda) < (ABS(nSldMoedForte * nTaxa))) //Ganacia
									If (cAlias)->NORMAL == "1" //Deudora
										cContaVar := (cAlias)->CONTA  //Débito (Cargo)
										cContaRed := (cAlias)->CTAVM  //Crédito (Abono)
									Else //Acreedora
										cContaVar := (cAlias)->CTAVMN //Débito (Cargo)
										cContaRed := (cAlias)->CONTA  //Crédito (Abono)								
									EndIf
								Else //Perdida
									If (cAlias)->NORMAL == "1" //Deudora
										cContaVar := (cAlias)->CTAVMN //Débito (Cargo)
										cContaRed := (cAlias)->CONTA  //Crédito (Abono)
									Else //Acreedora
										cContaVar := (cAlias)->CONTA  //Débito (Cargo)
										cContaRed := (cAlias)->CTAVM  //Crédito (Abono)									
									EndIf
								EndIf
							Else
								If !Empty(ALLTRIM((cAlias)->CTARED))
									cContaRed := (cAlias)->CTARED
									cContaVar := (cAlias)->CTAVM
								Else
									cContaRed := (cAlias)->CONTA
									cContaVar := (cAlias)->CTAVM
								endIf
							EndIf

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Qdo critério == 2 Plano de Contas, ajustar somente as contas com CT1_CTAMV preenchido                           ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If mv_par11 == 2
								DbSelectArea("CT1")
								DbSeek(xFilial()+(cAlias)->CONTA)
								nValorLanc := If(!Empty(CT1->CT1_CTAVM),nValorLanc,0)
							EndIf

							   //Variação Monetaria Negativa
							If cPaisLoc == "PER"
								IF __lCusto .and. (cAlias)->TABELA == "CQ3"  .And. (ABS(nSldMoeda) >= (ABS(nSldMoedForte * nTaxa)))
									cCustoRed		:= (cAlias)->CCRED
									cCustoVM		:= (cAlias)->CCVM
								ElseIF __lCusto .and. (cAlias)->TABELA == "CQ3"  .And. (ABS(nSldMoeda) < (ABS(nSldMoedForte * nTaxa)))
									cCustoRed		:= (cAlias)->CCRDN
									cCustoVM		:= (cAlias)->CCVMN
								EndIf
							ElseIF __lCusto .and. (cAlias)->TABELA == "CQ3"
								cCustoRed		:= (cAlias)->CCRED
								cCustoVM		:= (cAlias)->CCVM
								If cPaisLoc=="URU"
									cClVlRed	:= (cAlias)->CLRED
									cClVLVM		:= (cAlias)->CLVM
									CItemRed	:= (cAlias)->ITRED
									cItemVM		:= (cAlias)->ITVM
								Endif
							EndIf
								    //Variação Monetaria Negativa
							If cPaisLoc == "PER"
								IF __lItem .AND. (cAlias)->TABELA == "CQ5" .And. (ABS(nSldMoeda) >= (ABS(nSldMoedForte * nTaxa)))
									cItemRed	:= (cAlias)->ITRED
									cItemVM		:= (cAlias)->ITVM
								ElseIF __lItem .AND. (cAlias)->TABELA == "CQ5" .And. (ABS(nSldMoeda) < (ABS(nSldMoedForte * nTaxa)))
									cItemRed	:= (cAlias)->ITRDN
									cItemVM		:= (cAlias)->ITVMN
								EndIf
							ElseIF __lItem .AND. (cAlias)->TABELA == "CQ5"
								cItemRed	:= (cAlias)->ITRED
								cItemVM		:= (cAlias)->ITVM
								IF cPaisLoc=="COL" .AND. __lCusto
									cCustoRed		:= (cAlias)->CCRED
									cCustoVM		:= (cAlias)->CCVM
								ElseIf cPaisLoc=="URU"
									cClVlRed	:= (cAlias)->CLRED
									cClVLVM		:= (cAlias)->CLVM
									cCustoRed		:= (cAlias)->CCRED
									cCustoVM		:= (cAlias)->CCVM
								Endif
							EndIf

					    //Variação Monetaria Negativa
							If cPaisLoc == "PER"
								IF __lClVl .AND. (cAlias)->TABELA == "CQ7" .And. (ABS(nSldMoeda) >= (ABS(nSldMoedForte * nTaxa)))
									DbSelectArea("CTH")
									DbSeek(xFilial()+(cAlias)->CLVL)
									cClVlRed	:= (cAlias)->CLRED
									cClVLVM		:= (cAlias)->CLVM
								ElseIF __lClVl .AND. (cAlias)->TABELA == "CQ7" .And. (ABS(nSldMoeda) < (ABS(nSldMoedForte * nTaxa)))
									DbSelectArea("CTH")
									DbSeek(xFilial()+(cAlias)->CLVL)
									cClVlRed	:= (cAlias)->CLRDN
									cClVLVM		:= (cAlias)->CLVMN
								EndIf
							ElseIF __lClVl .AND. (cAlias)->TABELA == "CQ7"
								DbSelectArea("CTH")
								DbSeek(xFilial()+(cAlias)->CLVL)
								cClVlRed	:= (cAlias)->CLRED
								cClVLVM		:= (cAlias)->CLVM
 								IF cPaisLoc=="COL" .AND. __lCusto
									cCustoRed		:= (cAlias)->CCRED
									cCustoVM		:= (cAlias)->CCVM
								Endif
 								IF cPaisLoc=="COL" .AND. __lItem
 									cItemRed	:= (cAlias)->ITRED
									cItemVM		:= (cAlias)->ITVM
								Endif
								If cPaisLoc=="URU"
									cCustoRed		:= (cAlias)->CCRED
									cCustoVM		:= (cAlias)->CCVM
									cItemRed	:= (cAlias)->ITRED
									cItemVM		:= (cAlias)->ITVM
								Endif
							EndIf
							If cPaisLoc=="URU" .and. (cAlias)->TABELA == "CQ1"
								cClVlRed	 	:= (cAlias)->CLRED
								cClVLVM	 	:= (cAlias)->CLVM
								cCustoRed	:= (cAlias)->CCRED
								cCustoVM		:= (cAlias)->CCVM
								cItemRed		:= (cAlias)->ITRED
								cItemVM		:= (cAlias)->ITVM
					      Endif

							// Início da proteção de gravação
							If Round(nValorLanc,nTamDec) <> 0.00
								aTravas := {}
								IF !Empty(cContaVar)
								   AADD(aTravas,cContaVar)
								Endif
								IF !Empty(cContaRed)
								   AADD(aTravas,cContaRed)
								Endif

								/// VERIFICA SE O SEMAFORO DE CONTAS PERMITE GRAVAÇÃO DOS LANÇAMENTOS/SALDOS
								If CtbCanGrv(aTravas,@lAtSldBase)
					            CT2->(DbSetOrder(1))
									CT2->(DbGoTop())
					            If CT2->(MsSeek( xFilial("CT2")+Dtos(mv_par01)+mv_par02+mv_par03+cDoc+cLinha+mv_par09+cEmpOri+cFilOri))
						           	lTrueDoc:=.T.
						           	lTrueCT2:=.T.
							         While lTrueDoc
						                 	cChave := xFilial("CT2")+Dtos(mv_par01)+mv_par02+mv_par03+cDoc+cLinha+mv_par09+cEmpOri+cFilOri
											While ! CT2->(Eof()) .and. lTrueCT2
												If CT2->CT2_FILIAL+Dtos(CT2->CT2_DATA)+CT2->CT2_LOTE+CT2->CT2_SBLOTE+CT2->CT2_DOC==xFilial("CT2")+Dtos(mv_par01)+mv_par02+mv_par03+cDoc .and. CT2->CT2_TPSALD+CT2->CT2_EMPORI+CT2->CT2_FILORI == mv_par09+cEmpOri+cFilOri
										  			//cDoc := Soma1(cDoc)
										  			CT2->(DbSkip())
										  		Else
										  			lTrueCT2:=.F.
										  		Endif
											EndDo
						               cDoc := Soma1(cDoc)
						              	If CT2->(MsSeek( xFilial("CT2")+Dtos(mv_par01)+mv_par02+mv_par03+cDoc+cLinha+mv_par09+cEmpOri+cFilOri))
							              	lTrueCT2:=.T.
							               Loop
							            Else
							             	lTrueDoc:=.F.
							            Endif
							         Enddo
									EndIf
									BEGIN TRANSACTION

									If cPaisLoc == "BOL"
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Na Bolivia a Lei BI-Monetario, permite moeda local (Bolivianos) como Moeda Forte e vice versa.   ³
										//³ Obs: Lançamentos zerados para Moeda Forte.                                                       ³
					 					//³ Se nSldMoeda positivo (credor), e nValorLanc (+) --> Lançamento a crédito na conta redutora.     ³
										//³ Se nSldMoeda positivo (credor), e nValorLanc (-) --> Lançamento a débito na conta redutora.      ³
										//³ Se nSldMoeda negativo (devedor), e nValorLanc (+) --> Lançamento a débito na conta redutora.     ³
										//³ Se nSldMoeda negativo (devedor), e nValorLanc (-) --> Lançamento a crédito na conta redutora.    ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										If nValorLanc <> 0 //.And. nMoedPos < 1
											cSeqLan := Soma1(cSeqLan)
											If mv_par10 == 1 	//Separa Laçtos...

												cMoedaLanc := If( cMoedaForte == "01",cMoedaVar,"01")

												If nSldMoeda > 0 .AND. nValorLanc > 0 // Crédito na conta redutora com saldo credor

													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"1",cMoedaLanc,mv_par05,cContaVar,,cCustoVM,"",cItemVM,"",cClVLVM,"",Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

													CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																"1" /*cTipo*/,cMoedaLanc /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,0.00 /*nValor*/,;
																mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"2",cMoedaLanc,mv_par05,,cContaRed,"",cCustoRed,"",cItemRed,"",cClVlRed,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

													CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																"2" /*cTipo*/,cMoedaLanc /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,Abs(nValorLanc) /*nValor*/,;
																mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																	__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																	/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"1",cMoedaForte,mv_par05,cContaVar,,cCustoVM,"",cItemVM,"",cClVLVM,"",0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"2",cMoedaForte,mv_par05,,cContaRed,"",cCustoRed,"",cItemRed,"",cClVlRed,0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")


												ElseIf 	nSldMoeda > 0 .AND. nValorLanc < 0 // Débito na conta redutora com saldo credor

													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"1",cMoedaLanc,mv_par05,cContaRed,,cCustoRed,"",cItemRed,"",cClVlRed,"",Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

													CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
										 							"1" /*cTipo*/,cMoedaLanc /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																	CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																	CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,Abs(nValorLanc) /*nValor*/,;
																	mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																	"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																	0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																	__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																	/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																	/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"2",cMoedaLanc,mv_par05,,cContaVar,"",cCustoVM,"",cItemVM,"",cClVLVM,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

													CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																	"2" /*cTipo*/,cMoedaLanc /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																	CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																	CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,0.00 /*nValor*/,;
																	mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																	"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																	0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																	__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																	/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																	/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"1",cMoedaForte,mv_par05,cContaRed,,cCustoRed,"",cItemRed,"",cClVlRed,"",Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"2",cMoedaForte,mv_par05,,cContaVar,"",cCustoVM,"",cItemVM,"",cClVLVM,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

												ElseIf 	nSldMoeda < 0 .AND. nValorLanc > 0 // Débito na conta redutora com saldo devedor

													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"1",cMoedaLanc,mv_par05,cContaRed,,cCustoRed,"",cItemRed,"",cClVlRed,"",Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

													CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																"1" /*cTipo*/,cMoedaLanc /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,Abs(nValorLanc) /*nValor*/,;
																mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"2",cMoedaLanc,mv_par05,,cContaVar,"",cCustoVM,"",cItemVM,"",cClVLVM,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

													CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																"2" /*cTipo*/,cMoedaLanc /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,0.00 /*nValor*/,;
																mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
															/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"1",cMoedaForte,mv_par05,cContaRed,,cCustoRed,"",cItemRed,"",cClVlRed,"",Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"2",cMoedaForte,mv_par05,,cContaVar,"",cCustoVM,"",cItemVM,"",cClVLVM,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")


												ElseIf 	nSldMoeda < 0 .AND. nValorLanc < 0 // Crédito na conta redutora com saldo devedor

													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"1",cMoedaLanc,mv_par05,cContaVar,,cCustoVM,"",cItemVM,"",cClVLVM,"",Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,,"CTBA381")
													//GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"1","01",mv_par05,cContaVar,,cCustoVM,"",cItemVM,"",cClVLVM,"",Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,,"CTBA381")

													CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																"1" /*cTipo*/,cMoedaLanc /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,0.00 /*nValor*/,;
																mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"2",cMoedaLanc,mv_par05,,cContaRed,"",cCustoRed,"",cItemRed,"",cClVlRed,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

													CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																"2" /*cTipo*/,cMoedaLanc /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,Abs(nValorLanc) /*nValor*/,;
																mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"1",cMoedaForte,mv_par05,cContaVar,,cCustoVM,"",cItemVM,"",cClVLVM,"",Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"2",cMoedaForte,mv_par05,,cContaRed,"",cCustoRed,"",cItemRed,"",cClVlRed,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

												Endif

											ElseIf mv_par10 == 2 //Nao Separa Lactos...

												If  cMoedaForte == "01"

													 If nSldMoedUSD > 0 .AND. nValorLanc > 0 // Crédito na conta redutora com saldo credor

													 	 GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3",cMoedaVar,mv_par05,cContaVar,cContaRed,cCustoVM,cCustoRed,cItemVM,cItemRed,cClVlVM,cClVlRed,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

														 CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																		"3" /*cTipo*/,cMoedaVar /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																		CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																		CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,0.00 /*nValor*/,;
																		mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																		"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																		0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																		__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																		/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																		/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

															GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3",cMoedaForte,mv_par05,cContaVar,cContaRed,cCustoVM,cCustoRed,cItemVM,cItemRed,cClVlVM,cClVlRed,0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

													ElseIf 	nSldMoedUSD > 0 .AND. nValorLanc < 0 // Débito na conta redutora com saldo credor

															GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3",cMoedaVar,mv_par05,cContaVar,cContaRed,cCustoVM,cCustoRed,cItemVM,cItemRed,cClVLVM,cClVLRed,0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

															CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																		"3" /*cTipo*/,cMoedaVar   /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																	CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																	CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,Abs(nValorLanc) /*nValor*/,;
																	mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																	"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																	0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																	__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																	/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																	/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

															GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3",cMoedaForte,mv_par05,cContaVar,cContaRed,cCustoVM,cCustoRed,cItemVM,cItemRed,cClVLVM,cClVLRed,0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")


													ElseIf 	nSldMoedUSD < 0 .AND. nValorLanc > 0 // Débito na conta redutora com saldo devedor

															GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3",cMoedaVar,mv_par05,cContaVar,cContaRed,cCustoVM,cCustoRed,cItemVM,cItemRed,cClVLVM,cClVLRed,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

															CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																		"3" /*cTipo*/,cMoedaVar /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																		CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																		CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,Abs(nValorLanc) /*nValor*/,;
																		mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																		"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																		0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																		__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																		/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																		/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

				 										GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3",cMoedaForte,mv_par05,cContaVar,cContaRed,cCustoVM,cCustoRed,cItemVM,cItemRed,cClVLRed,cClVLRed,0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

													ElseIf 	nSldMoedUSD < 0 .AND. nValorLanc < 0 // Crédito na conta redutora com saldo devedor

														//GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3",cMoedaVar  ,mv_par05,cContaVar,cContaRed,cCustoRed,cCustoVM,cItemRed,cItemVM,cClVlRed,cClVLVM,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
														  GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3",cMoedaVar  ,mv_par05,cContaRed,cContaVar,cCustoVM,cCustoRed,cItemVM,cItemRed,cClVlRed,cClVLVM,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

											   			CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																		"3" /*cTipo*/,cMoedaVar /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																		CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																		CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,Abs(nValorLanc)/*nValor*/,;
																			mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																		"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																		0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																		__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																		/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																		/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

													    //GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3",cMoedaForte,mv_par05,cContaVar,cContaRed,cCustoRed,cCustoVM,cItemRed,cItemVM,cClVlVM,cClVlRed,0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
													   	  GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3",cMoedaForte,mv_par05,cContaRed,cContaVar,cCustoRed,cCustoVM,cItemRed,cItemVM,cClVlRed,cClVlVM,0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

													EndIf
							        	      Else
													If 	nSldMoeda > 0 .AND. nValorLanc > 0 // Crédito na conta redutora com saldo credor

															GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3","01",mv_par05,cContaVar,cContaRed,cCustoVM,cCustoRed,cItemVM,cItemRed,cClVlVM,cClVlRed,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

															CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																		"3" /*cTipo*/,"01" /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																		CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																		CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,Abs(nValorLanc) /*nValor*/,;
																		mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																	"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																	0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																	__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																	/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																	/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

															GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3",cMoedaForte,mv_par05,cContaVar,cContaRed,cCustoVM,cCustoRed,cItemVM,cItemRed,cClVlVM,cClVlRed,0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

													ElseIf 	nSldMoeda > 0 .AND. nValorLanc < 0 // Débito na conta redutora com saldo credor

															GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3","01",mv_par05,cContaVar,cContaRed,cCustoVM,cCustoRed,cItemVM,cItemRed,cClVLVM,cClVLRed,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

															CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
										 								"3" /*cTipo*/,"01" /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																		CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																		CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,Abs(nValorLanc) /*nValor*/,;
																		mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																		"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																		0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																		__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																		/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																		/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

														GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3",cMoedaForte,mv_par05,cContaVar,cContaRed,cCustoVM,cCustoRed,cItemVM,cItemRed,cClVLVM,cClVLRed,0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

													ElseIf 	nSldMoeda < 0 .AND. nValorLanc > 0 // Débito na conta redutora com saldo devedor

														GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3","01",mv_par05,cContaRed,cContaVar,cCustoRed,cCustoVM,cItemRed,cItemVM,cClVlRed,cCLVLVM,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

														CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																		"3" /*cTipo*/,"01" /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																		CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																		CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,Abs(nValorLanc) /*nValor*/,;
																		mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																		"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																		0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																		__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																		/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																		/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

														GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3",cMoedaForte,mv_par05,cContaRed,cContaVar,cCustoRed,cCustoVM,cItemRed,cItemVM,cClVLRed,cClVLVM,0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

													ElseIf 	nSldMoeda < 0 .AND. nValorLanc < 0 // Crédito na conta redutora com ClVdo devedor

				 										GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3","01",mv_par05,cContaVar,cContaRed,cCustoVM,cCustoRed,cItemVM,cItemRed,cCLVLVM,cClVlRed,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

											   			CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																		"3" /*cTipo*/,"01" /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																		CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																		CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,Abs(nValorLanc) /*nValor*/,;
																		mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																		"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																		0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																		__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																		/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																		/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

														GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3",cMoedaForte,mv_par05,cContaVar,cContaRed,cCustoVM,cCustoRed,cItemVM,cItemRed,cClVlVM,cClVlRed,0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

													EndIf
							            	EndIf
							         	EndIf
						            Endif
							      ElseIf cPaisLoc == "URU"

							        	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³  Quando Uruguay, gerar registro lançamento zerado para as moedas <> que 01 ³
										//³  Obs: Laçtos en U$ são gerados zerados em outras rotinas...                ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										If mv_par10 == 1	//Separa Laçtos...

											cMoedaLanc := cMoedaVar

											If nValorLanc > 0 // Crédito na conta redutora

												If lGrvMFort
													If cMoedaForte<>"01"
														GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"1","01",mv_par05,cContaVar,,cCustoVM,"",cItemVM,"",cClVLVM,"",0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
														GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"2","01",mv_par05,,cContaRed,"",cCustoRed,"",cItemRed,"",cClVlRed,0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
													EndIf
													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"1",cMoedaForte,mv_par05,cContaVar,,cCustoVM,"",cItemVM,"",cClVLVM,"",0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"2",cMoedaForte,mv_par05,,cContaRed,"",cCustoRed,"",cItemRed,"",cClVlRed,0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
													lGrvMFort := .F.
												EndIf
												If cMoedaForte=="01"
													nValorLanc := 0
												EndIf

												If cMoedaLanc<>"01"
													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,cLinha,"1","01",mv_par05,cContaVar,,cCustoVM,"",cItemVM,"",cClVLVM,"",0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
												EndIf
												GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"1",cMoedaLanc,mv_par05,cContaVar,,cCustoVM,"",cItemVM,"",cClVLVM,"",Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

												CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																	"1" /*cTipo*/,cMoedaLanc /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																	CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																	CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,0.00 /*nValor*/,;
																	mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																	"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																	0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																	__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																	/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																	/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

												If cMoedaLanc<>"01"
													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,cLinha,"2","01",mv_par05,,cContaRed,"",cCustoRed,"",cItemRed,"",cClVlRed,0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
												EndIf
												GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"2",cMoedaLanc,mv_par05,,cContaRed,"",cCustoRed,"",cItemRed,"",cClVlRed,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

												CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																	"2" /*cTipo*/,cMoedaLanc /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																	CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																	CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,Abs(nValorLanc) /*nValor*/,;
																	mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																	"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																	0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																	__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																	/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																	/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

											ElseIf nValorLanc < 0 // Débito na conta redutora

												If lGrvMFort
													If cMoedaForte<>"01"
														GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"1","01",mv_par05,cContaRed,,cCustoRed,"",cItemRed,"",cClVlRed,"",0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
														GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"2","01",mv_par05,,cContaVar,"",cCustoVM,"",cItemVM,"",cClVLVM,0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
													EndIf
												GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"1",cMoedaForte,mv_par05,cContaRed,,cCustoRed,"",cItemRed,"",cClVlRed,"",0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
												GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"2",cMoedaForte,mv_par05,,cContaVar,"",cCustoVM,"",cItemVM,"",cClVLVM,0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
												lGrvMFort := .F.
												EndIf

												If cMoedaForte=="01"
												nValorLanc := 0
												EndIf

												If cMoedaLanc<>"01"
														GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,cLinha,"1","01",mv_par05,cContaRed,,cCustoRed,"",cItemRed,"",cClVlRed,"",0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
												EndIf
												GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"1",cMoedaLanc,mv_par05,cContaRed,,cCustoRed,"",cItemRed,"",cClVlRed,"",Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

												CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
											 							"1" /*cTipo*/,cMoedaLanc /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																		CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																		CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,Abs(nValorLanc) /*nValor*/,;
																		mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																		"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																		0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																		__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																		/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																		/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

												If cMoedaLanc<>"01"
														GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,cLinha,"2","01",mv_par05,,cContaVar,"",cCustoVM,"",cItemVM,"",cClVLVM,0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
												EndIf
												GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"2",cMoedaLanc,mv_par05,,cContaVar,"",cCustoVM,"",cItemVM,"",cClVLVM,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

												CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																		"2" /*cTipo*/,cMoedaLanc /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																		CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																		CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,0.00 /*nValor*/,;
																		mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																		"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																		0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																		__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																		/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																		/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

											EndIf

										Else
											If nValorLanc > 0 // Crédito na conta redutora

												If lGrvMFort
													If cMoedaForte<>"01"
														GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,cLinha,"3","01",mv_par05,cContaVar,cContaRed,cCustoVM,cCustoRed,cItemVM,cItemRed,cClVlVM,cClVlRed,0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
													EndIf
													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3",cMoedaForte,mv_par05,cContaVar,cContaRed,cCustoVM,cCustoRed,cItemVM,cItemRed,cClVlVM,cClVlRed,0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
													lGrvMFort := .F.
												EndIf

												If cMoedaVar<>"01"
														GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,cLinha,"3","01",mv_par05,cContaVar,cContaRed,cCustoVM,cCustoRed,cItemVM,cItemRed,cClVlVM,cClVlRed,0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
												EndIf
													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3",cMoedaVar,mv_par05,cContaVar,cContaRed,cCustoVM,cCustoRed,cItemVM,cItemRed,cClVlVM,cClVlRed,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

													CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																			"3" /*cTipo*/,cMoedaVar /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																			CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																			CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,0.00 /*nValor*/,;
																			mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																			"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																			0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																			__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																			/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																			/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

											ElseIf 	nValorLanc < 0 // Débito na conta redutora

												If lGrvMFort
													If cMoedaForte<>"01"
															GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,cLinha,"3","01",mv_par05,cContaVar,cContaRed,cCustoVM,cCustoRed,cItemVM,cItemRed,cClVLVM,cClVLRed,0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
													EndIf
													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3",cMoedaForte,mv_par05,cContaVar,cContaRed,cCustoVM,cCustoRed,cItemVM,cItemRed,cClVLVM,cClVLRed,0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
													lGrvMFort := .F.
					                     Endif
												If cMoedaVar<>"01"
													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,cLinha,"3","01",mv_par05,cContaVar,cContaRed,cCustoVM,cCustoRed,cItemVM,cItemRed,cClVLVM,cClVLRed,0.00,Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
												EndIf
												GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3",cMoedaVar,mv_par05,cContaVar,cContaRed,cCustoVM,cCustoRed,cItemVM,cItemRed,cClVLVM,cClVLRed,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

												CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																		"3" /*cTipo*/,cMoedaVar   /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																		CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																		CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,Abs(nValorLanc) /*nValor*/,;
																		mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																		"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																		0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																		__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																		/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																		/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

											Endif
										EndIf
			   	            Else
							        	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³  Para Argentina, Brasil, Chile e demais, Lei não permite moeda Local como  ³
										//³  Moeda Forte. Não é necessario lançamentos zerados para Moeda Forte.       ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										If mv_par10 == 1 	//Separa Laçtos...

											If 	nSldMoeda > 0 .AND. nValorLanc > 0 // Crédito na conta redutora com saldo credor
												GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"1","01",mv_par05,cContaVar,,cCustoVM,"",cItemVM,"",cClVLVM,"",Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

													CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																"1" /*cTipo*/,"01" /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,0.00 /*nValor*/,;
																mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
															/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

												GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"2","01",mv_par05,,cContaRed,"",cCustoRed,"",cItemRed,"",cClVlRed,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

												CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
															"2" /*cTipo*/,"01" /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
															CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
															CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,Abs(nValorLanc) /*nValor*/,;
															mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
															"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
															0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
															__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
															/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
															/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

											ElseIf 	nSldMoeda > 0 .AND. nValorLanc < 0 // Débito na conta redutora com saldo credor

													If cPaisLoc $ "PER|URU|PAR|CHI|ARG"
														GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"1","01",mv_par05,cContaVar,"",cCustoRed,"",cItemRed,"",cClVlRed,"",Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
													Else
														GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"1","01",mv_par05,cContaVar,cContaRed,cCustoRed,"",cItemRed,"",cClVlRed,"",Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
													EndIf													
													
													CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
									 							"1" /*cTipo*/,"01" /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																	CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																	CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,Abs(nValorLanc) /*nValor*/,;
																	mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																	"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																	0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																	__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																	/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																	/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

													If cPaisLoc $ "PER|URU|PAR|CHI|ARG"
														GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"2","01",mv_par05,"",cContaRed,"",cCustoVM,"",cItemVM,"",cClVLVM,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
													Else
														GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"2","01",mv_par05,cContaVar,cContaRed,"",cCustoVM,"",cItemVM,"",cClVLVM,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
													EndIf		
																								
													CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																	"2" /*cTipo*/,"01" /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																	CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																	CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,Abs(nValorLanc) /*nValor*/,;
																	mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																	"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																	0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																	__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																	/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																	/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)				
		
											ElseIf 	nSldMoeda < 0 .AND. nValorLanc > 0 // Débito na conta redutora com saldo devedor

													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"1","01",mv_par05,cContaVar,,cCustoRed,"",cItemRed,"",cClVlRed,"",Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

													CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																"1" /*cTipo*/,"01" /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,Abs(nValorLanc) /*nValor*/,;
																mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"2","01",mv_par05,,cContaRed,"",cCustoVM,"",cItemVM,"",cClVLVM,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

													CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																"2" /*cTipo*/,"01" /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,Abs(nValorLanc) /*nValor*/,;
																mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

											ElseIf 	nSldMoeda < 0 .AND. nValorLanc < 0 // Crédito na conta redutora com saldo devedor

													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"1","01",mv_par05,cContaVar,,cCustoVM,"",cItemVM,"",cClVLVM,"",Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

													CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																"1" /*cTipo*/,"01" /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,Abs(nValorLanc) /*nValor*/,;
																mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																	/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

													GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"2","01",mv_par05,,cContaRed,"",cCustoRed,"",cItemRed,"",cClVlRed,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

													CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																"2" /*cTipo*/,"01" /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,Abs(nValorLanc) /*nValor*/,;
																mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)

											EndIf
										ElseIf mv_par10 == 2 //Nao Separa Lactos...

											If 	nSldMoeda > 0 .AND. nValorLanc > 0 // Crédito na conta redutora com saldo credor
														GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3","01",mv_par05,cContaVar,cContaRed,cCustoVM,cCustoRed,cItemVM,cItemRed,cClVlVM,cClVlRed,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")

														CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																		"3" /*cTipo*/,"01" /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																		CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																		CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,Abs(nValorLanc) /*nValor*/,;
																		mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																		"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																		0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																		__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																		/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																		/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)
											ElseIf nSldMoeda > 0 .AND. nValorLanc < 0 // Débito na conta redutora com saldo credor
													If cPaisLoc $ "PER|URU|PAR|CHI|ARG"
														GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3","01",mv_par05,cContaVar,cContaRed,cCustoRed,cCustoVM,cItemRed,cItemVM,cCLVLRed,cClVLVM,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
													Else
														GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3","01",mv_par05,cContaRed,cContaVar,cCustoRed,cCustoVM,cItemRed,cItemVM,cCLVLRed,cClVLVM,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
													EndIf
													
														CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
										 								"3" /*cTipo*/,"01" /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																		CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																			CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,Abs(nValorLanc) /*nValor*/,;
																		mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																		"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																		0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																		__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																		/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																		/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)
																						
											ElseIf 	nSldMoeda < 0 .AND. nValorLanc > 0 // Débito na conta redutora com saldo devedor
														If cPaisLoc == "PER"															
															GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3","01",mv_par05,cContaVar,cContaRed,cCustoRed,cCustoVM,cItemRed,cItemVM,cClVlRed,cCLVLVM,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
														Else
															GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3","01",mv_par05,cContaRed,cContaVar,cCustoRed,cCustoVM,cItemRed,cItemVM,cClVlRed,cCLVLVM,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
														EndIf

														CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																		"3" /*cTipo*/,"01" /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																		CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																		CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,Abs(nValorLanc) /*nValor*/,;
																		mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																		"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																		0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																		__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																		/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																		/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)
											ElseIf 	nSldMoeda < 0 .AND. nValorLanc < 0 // Crédito na conta redutora com ClVdo devedor
														If cPaisLoc == "PER"
															GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3","01",mv_par05,cContaVar,cContaRed,cCustoVM,cCustoRed,cItemVM,cItemRed,cCLVLVM,cClVlRed,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")			
				 										Else
				 											GravaLanc(mv_par01,mv_par02,mv_par03,cDoc,@cLinha,"3","01",mv_par05,cContaRed,cContaVar,cCustoVM,cCustoRed,cItemVM,cItemRed,cCLVLVM,cClVlRed,Abs(nValorLanc),Eval(bHistorico),mv_par09,@cSeqLan,3,lAtSldBase,aCols,cEmpOri,cFilOri,,,,,,"CTBA381")
				 										EndIf
											   			CtbGravSaldo(	CT2->CT2_LOTE /*cLote*/,CT2->CT2_SBLOTE /*cSubLote*/,CT2->CT2_DOC /*cDoc*/,CT2->CT2_DATA /*dData*/,;
																		"3" /*cTipo*/,"01" /*cMoeda*/,CT2->CT2_DEBITO /*cDebito*/,CT2->CT2_CREDIT /*cCredito*/,;
																	CT2->CT2_CCD /*cCustoDeb*/,CT2->CT2_CCC /*cCustoCrd*/,CT2->CT2_ITEMD /*cItemDeb*/,CT2->CT2_ITEMC/*cItemCrd*/,;
																	CT2->CT2_CLVLDB /*cClVlDeb*/,CT2->CT2_CLVLCR /*cClVlCrd*/,Abs(nValorLanc) /*nValor*/,;
																	mv_par09 /*cTpSald*/,3 /*nOpc*/,"" /*cDebitoAnt*/,"" /*cCreditoAnt*/,"" /*cCustoDAnt*/,;
																	"" /*cCustoCAnt*/,"" /*cItemDAnt*/,"" /*cItemCAnt*/,"" /*cCLVLDAnt*/,"" /*cCLVLCAnt*/,;
																	0 /*nValorAnt*/," " /*cTipoAnt*/," " /*cTpSaldAnt*/, "  " /*cMoedaAnt*/,  __lCusto /*lCusto*/,;
																	__lItem /*lItem*/,__lClVL /*lClVL*/, 0.00 /*nTotInf*/,/*lAtSldBase*/,;
																	/*lReproc*/,/*dDataLP*/,/*lGrvCT7*/,/*lGrvCT3*/,/*lGrvCT4*/,/*lGrvCTI*/,;
																	/*lAtuSldCT7*/,/*lAtuSldCT3*/,/*lAtuSldCT4*/,/*lAtuSldCTI*/,/*lTrbProc*/,/* cOperacao*/,aEntid,/*aEntidAnt*/,/*cHistLote*/,/*cMoedDoc*/,/*cCritDoc*/,/*dDatTaxDoc*/,/*cTipSldDoc*/,/*cLivDia*/,/*cNroDia*/)
											Endif
										EndIf
			  	               EndIf
			  	               END TRANSACTION
			               EndIf
					    	EndIf
						Endif
					EndIf
				    nVlCusto	:= nVlCusto	 + nValorLanc
				    nVlConta	:= nVlConta	 + nValorLanc
				    nVlItem  	:= nVlItem	 + nValorLanc
					nValorLanc:=0
				Next nMoeda
				cContaReg:=(cAlias)->CONTA
				(cAlias)->(DbSkip())
				If cContaReg <> (cAlias)->CONTA
					aVlrLct:={}
			   Endif
			EndDo
		EndDo
	EndDo
EndDo
If oTmpTable <> Nil
	oTmpTable:Delete()
	oTmpTable := Nil
Endif
If Select("QRYTMP") > 0
	dbSelectArea("QRYTMP")
	dbCloseArea()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FormBatch³ Autor ³ Juan Jose Pereira	    ³ Data ³ 04/12/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta tela generica para processo batch					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FormBatch( cTitle, aSays, aButtons, lOk, bValid )		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ cTitle = Titulo da janela								  ³±±
±±³			 ³ aSays  = Array com Says 									  ³±±
±±³			 ³ aButtons = Array com bottoes								  ³±±
±±³			 ³ aButtons[i,1] = Tipo de botao 							  ³±±
±±³			 ³ aButtons[i,2] = Tipo de enabled							  ³±±
±±³			 ³ aButtons[i,3] = bAction 									  ³±±
±±³			 ³ aButtons[i,4] = Hint do Botao							  ³±±
±±³			 ³ bValid = Bloco de validacao do Form 						  ³±±
±±³			 ³ nAltura= Altura do Form em Pixel (Default 250)			  ³±±
±±³			 ³ nLargura = Largura do Form em Pixel (Default 520)		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#DEFINE LARGURA_DO_SBUTTON 32

Static Function FormBatch( cTitle, aSays, aButtons, bValid, nAltura, nLargura )

Local nButtons:= Len(aButtons),;
nSays:= Len(aSays),;
oSay,;
i,nTop, nType, lEnabled, oFormPai, oFont,;
nLarguraBox, nAlturaBox, nLarguraSay, cTextSay

DEFAULT aSays:={}, aButtons:={}
DEFAULT nAltura:= 250, nLargura:= 520

// Numero maximo de linhas //
If( nSays>7 )
	nSays:=7
EndIf

// Numero maximo de botoes //
If( nButtons>5 )
	nButtons:= 5
EndIf

oFormPai:= Atail(aFormBatch)
If( oFormPai==NIL )
	oFormPai:= oMainWnd
EndIf

DEFINE FONT oFont NAME "Arial" SIZE 0, -11

DEFINE MSDIALOG oDlg TITLE cTitle FROM 0,0 TO nAltura,nLargura OF oFormPai PIXEL

AADD(aFormBatch,oDlg)

nAlturaBox:= (nAltura-60)/2
nLarguraBox:= (nLargura-20)/2
@ 10,10 TO nAlturaBox,nLarguraBox OF oDlg PIXEL

//======================================================//
// monta says (bof)												 //
//======================================================//
nTop:=20

nLarguraSay:= nLarguraBox-30
For i:=1 to nSays
	cTextSay:= "{||'"+aSays[i]+"'}"
	oSay := TSay():New( nTop, 20, MontaBlock(cTextSay),oDlg,, oFont, .F., .F., .F., .T.,,, nLarguraSay, 10, .F., .F., .F., .F., .F. )
	nTop+= 10
Next

//======================================================//
// monta bottoes(bof) 											 //
//======================================================//
nPosIni:= ((nLargura-20)/2) - (nButtons* LARGURA_DO_SBUTTON )
nAlturaButton:= nAlturaBox+10

For i:=1 to nButtons
	nType:= aButtons[i,1]
	lEnabled:= aButtons[i,2]

	DEFAULT lEnabled:= .T.

	If lEnabled
		If Len(aButtons[i]) > 3 .And. ValType(aButtons[i,4]) == "C"
			SButton():New( nAlturaButton, nPosIni, nType,aButtons[i,3],oDlg,.T.,aButtons[i,4])
		Else
			SButton():New( nAlturaButton, nPosIni, nType,aButtons[i,3],oDlg,.T.,,)
		Endif
	Else
		SButton():New( nAlturaButton, nPosIni, nType,,oDlg,.F.,,)
	EndIf

	nPosIni+= LARGURA_DO_SBUTTON
Next
//======================================================//
// monta bottoes(bof) 											 //
//======================================================//
oDlg:Activate( ,,,.T.,bValid,,,, )

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±Fun‡„o	 ³FechaBatch³ Autor ³ Juan Jose Pereira	    ³ Data ³ 04/12/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fecha Ultima tela de batch 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FechaBatch()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FechaBatch()
Local oDlg:= Atail( aFormBatch )

	oDlg:End()
	ASize( aFormBatch,Len(aFormBatch)-1 )

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaCT5    ³Autor ³  Lucas               ³Data³ 07/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajustar o arquivo de lanamentos padronizados para contabilização da rotina de variação monetária.            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaCT5()
Local aArea     := GetArea()
Local aLactoCT5 := {}
Local nI

	// Corregido error de sintaxis en la posicion 8 = If(mv_par11==1  .and. !Empty(TRB->TRB_DEBITO,TRB->TRB_VALOR,0) (Ariel 12/07/04)
	// Corregido error de sintaxis en la posicion 17 = Debe ser character "Asiento XXX Secuencia... (Ariel 12/07/04)
	AADD(aLactoCT5,{ "XXX","001","VARIACIÓN MONETARIA","1","TRB->TRB_DEBITO","                                   ", "123","If(mv_par11==1  .and. !Empty(TRB->TRB_DEBITO),TRB->TRB_VALOR,0)" ,"","","","","TRB->TRB_HIST","","","",'"Asiento XXX Secuencia 001"',"2","","","","","","","1","01","001", ""}) //El campo CT5_DTVENC es Character eliminado CTOD (Ariel 09/07/04)
	AADD(aLactoCT5,{ "XXX","002","VARIACIÓN MONETARIA","2","                                   ","TRB->TRB_CREDIT", "123","If(mv_par11==1  .and. !Empty(TRB->TRB_CREDIT),TRB->TRB_VALOR,0)","","","","","TRB->TRB_HIST","","","",'"Asiento XXX Secuencia 002"',"2","","","","","","","1","01","002", ""}) //El campo CT5_DTVENC es Character eliminado CTOD (Ariel 09/07/04)
	AADD(aLactoCT5,{ "XXX","003","VARIACIÓN MONETARIA","3","TRB->TRB_DEBITO","TRB->TRB_CREDIT", "123","If(mv_par11==2,TRB->TRB_VALOR,0)"                                                             ,"","","","","TRB->TRB_HIST","","","",'"Asiento XXX Secuencia 003"',"2","","","","","","","1","01","003", ""}) //El campo CT5_DTVENC es Character eliminado CTOD (Ariel 09/07/04)

	DbSelectArea("CT5")
	For nI := 1 to Len(aLactoCT5)
		If ! DbSeek(xFilial("CT5")+aLactoCT5[nI][01]+aLactoCT5[nI][02])
			RecLock("CT5",.T.)
				Replace CT5_FILIAL	With	xFilial("CT5")
				Replace CT5_LANPAD	With	aLactoCT5[nI][01]
				Replace CT5_SEQUEN	With	aLactoCT5[nI][02]
				Replace CT5_DESC  	With	aLactoCT5[nI][03]
				Replace CT5_DC    	With	aLactoCT5[nI][04]
				Replace CT5_DEBITO	With	aLactoCT5[nI][05]
				Replace CT5_CREDIT	With	aLactoCT5[nI][06]
				Replace CT5_MOEDAS	With	aLactoCT5[nI][07]
				Replace CT5_VLR01 	With	aLactoCT5[nI][08]
				Replace CT5_VLR02 	With	aLactoCT5[nI][09]
				Replace CT5_VLR03 	With	aLactoCT5[nI][10]
				Replace CT5_VLR04 	With	aLactoCT5[nI][11]
				Replace CT5_VLR05 	With	aLactoCT5[nI][12]
				Replace CT5_HIST  	With	aLactoCT5[nI][13]
				Replace CT5_HAGLUT	With	aLactoCT5[nI][14]
				Replace CT5_CCD  	With	aLactoCT5[nI][15]
				Replace CT5_CCC   	With	aLactoCT5[nI][16]
				Replace CT5_ORIGEM	With	aLactoCT5[nI][17]
				Replace CT5_INTERC	With	aLactoCT5[nI][18]
				Replace CT5_ITEMD	With	aLactoCT5[nI][19]
				Replace CT5_ITEMC	With	aLactoCT5[nI][20]
				Replace CT5_CLVLDB	With	aLactoCT5[nI][21]
				Replace CT5_CLVLCR	With	aLactoCT5[nI][22]
				Replace CT5_ATIVDE	With	aLactoCT5[nI][23]
				Replace CT5_ATIVCR	With	aLactoCT5[nI][24]
				Replace CT5_TPSALD	With	aLactoCT5[nI][25]
				Replace CT5_MOEDLC	With	aLactoCT5[nI][26]
				Replace CT5_SBLOTE	With	aLactoCT5[nI][27]
				Replace CT5_DTVENC	With	aLactoCT5[nI][28]
			MsUnLock()
		EndIf
	Next nI

RestArea( aArea )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaCT5B   ³Autor ³  Simone Mie Sato     ³Data³ 23/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajustar o arquivo de lanamentos padronizados para  		  ³±±
±±³			 ³contabilização da rotina de variação monetária.             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaCT5B()
Local aArea     := GetArea()
Local aLactoCT5 :={}
Local nI

	// Corregido error de sintaxis en la posicion 8 = If(mv_par11==1  .and. !Empty(TRB->TRB_DEBITO,TRB->TRB_VALOR,0) (Ariel 12/07/04)
	// Corregido error de sintaxis en la posicion 17 = Debe ser character "Asiento XXX Secuencia... (Ariel 12/07/04)
	AADD(aLactoCT5,{ "XXX","001","VARIACIÓN MONETARIA","1","TRB->TRB_DEBITO","                                   ", "123","If(mv_par10==1  .and. !Empty(TRB->TRB_DEBITO),TRB->TRB_VALOR,0)" ,"","","","","TRB->TRB_HIST","","","",'"CTBA381"',"2","","","","","","","1","01","001", ""}) //El campo CT5_DTVENC es Character eliminado CTOD (Ariel 09/07/04)
	AADD(aLactoCT5,{ "XXX","002","VARIACIÓN MONETARIA","2","                                   ","TRB->TRB_CREDIT", "123","If(mv_par10==1  .and. !Empty(TRB->TRB_CREDIT),TRB->TRB_VALOR,0)","","","","","TRB->TRB_HIST","","","",'"CTBA381"',"2","","","","","","","1","01","002", ""}) //El campo CT5_DTVENC es Character eliminado CTOD (Ariel 09/07/04)
	AADD(aLactoCT5,{ "XXX","003","VARIACIÓN MONETARIA","3","TRB->TRB_DEBITO","TRB->TRB_CREDIT", "123","If(mv_par10==2,TRB->TRB_VALOR,0)"                                                             ,"","","","","TRB->TRB_HIST","","","",'"CTBA381"',"2","","","","","","","1","01","003", ""}) //El campo CT5_DTVENC es Character eliminado CTOD (Ariel 09/07/04)

	DbSelectArea("CT5")
	For nI := 1 to Len(aLactoCT5)
		If ! DbSeek(xFilial("CT5")+aLactoCT5[nI][01]+aLactoCT5[nI][02])
			RecLock("CT5",.T.)
				Replace CT5_FILIAL	With	xFilial("CT5")
				Replace CT5_LANPAD	With	aLactoCT5[nI][01]
				Replace CT5_SEQUEN	With	aLactoCT5[nI][02]
				Replace CT5_DESC  	With	aLactoCT5[nI][03]
				Replace CT5_DC    	With	aLactoCT5[nI][04]
				Replace CT5_DEBITO	With	aLactoCT5[nI][05]
				Replace CT5_CREDIT	With	aLactoCT5[nI][06]
				Replace CT5_MOEDAS	With	aLactoCT5[nI][07]
				Replace CT5_VLR01	With	aLactoCT5[nI][08]
				Replace CT5_VLR02	With	aLactoCT5[nI][09]
				Replace CT5_VLR03	With	aLactoCT5[nI][10]
				Replace CT5_VLR04	With	aLactoCT5[nI][11]
				Replace CT5_VLR05	With	aLactoCT5[nI][12]
				Replace CT5_HIST  	With	aLactoCT5[nI][13]
				Replace CT5_HAGLUT	With	aLactoCT5[nI][14]
				Replace CT5_CCD   	With	aLactoCT5[nI][15]
				Replace CT5_CCC   	With	aLactoCT5[nI][16]
				Replace CT5_ORIGEM	With	aLactoCT5[nI][17]
				Replace CT5_INTERC	With	aLactoCT5[nI][18]
				Replace CT5_ITEMD 	With	aLactoCT5[nI][19]
				Replace CT5_ITEMC 	With	aLactoCT5[nI][20]
				Replace CT5_CLVLDB	With	aLactoCT5[nI][21]
				Replace CT5_CLVLCR	With	aLactoCT5[nI][22]
				Replace CT5_ATIVDE	With	aLactoCT5[nI][23]
				Replace CT5_ATIVCR	With	aLactoCT5[nI][24]
				Replace CT5_TPSALD	With	aLactoCT5[nI][25]
				Replace CT5_MOEDLC	With	aLactoCT5[nI][26]
				Replace CT5_SBLOTE	With	aLactoCT5[nI][27]
				Replace CT5_DTVENC	With	aLactoCT5[nI][28]
			MsUnLock()
		EndIf
	Next nI

RestArea( aArea )
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ct381Moedas ³ Autor ³ Davi Torchio        ³ Data ³ 18.01.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Array com as moedas para calculo de variacao       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct381Moedas(aCols,cMoeda)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.					                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Ctba381    			                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array a ser preenchida com moedas para calculo     ³±±
±±³          ³ ExpC1 = Moeda especifica a ser recarregado aCols           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct381Moedas(aCols, cMoeda)
Local aMedias := CtbMedias(mv_par01)
Local nTaxa, lAddCols := Len(aCols) = 0, cCriter
Local cBloq   := ""

	dbSelectArea("CTO")
	dbSetOrder(1)
	If cMoeda = Nil
		dbSeek(xFilial())
	Else
		dbSeek(xFilial()+cMoeda,.T.)
	Endif
	CTP->(DbSetOrder(1))

	While !Eof() .And. xFilial() == CTO->CTO_FILIAL

		If CTO->CTO_MOEDA = "01"
			DbSkip()
			Loop
		Endif

		nTaxa 	:= 0.00
		cCriter := If(lAddCols, CTO->CTO_CRITER, aCols[Val(CTO->CTO_MOEDA) - 1][2])

		If cCriter = "1" .And. CTP->(DbSeek(xFilial()+DTOS(mv_par01)+CTO->CTO_MOEDA))
			nTaxa := CTP->CTP_TAXA
		ElseIf cCriter = "2"
			nTaxa := aMedias[Val(CTO->CTO_MOEDA)]
		ElseIf cCriter = "3"
			aDatas 	:= CTBPeriodos(CTO->CTO_MOEDA,mv_par01,,, .F. )		// Retorna data inicial e final
			dbSelectArea("CTP")
			dbSetOrder(1)
			If MsSeek(xFilial()+DTOS(aDatas[1][2])+CTO->CTO_MOEDA)
				cBloq := If(cBloq = Nil, CTP->CTP_BLOQ, cBloq)
				If  cBloq <> "1"	// Moeda não bloqueada
					nTaxa := CTP->CTP_TAXA
				EndIf
			EndIf
			dbSelectArea("CTO")
		ElseIf cCriter = "4"
			nTaxa := If(lAddCols, CTO->CTO_TXINF, aCols[Val(CTO->CTO_MOEDA) - 1][6])
		Endif

		If lAddCols
			AADD(aCols, { CTO->CTO_MOEDA, CTO->CTO_CRITER, 0.00, "2", CTO->CTO_BLOQ,;
			nTaxa, CTO->CTO_DESC, CTO->CTO_MOEDA <> "01" } )
		Else
			aCols[Val(CTO->CTO_MOEDA) - 1][6] := nTaxa
		Endif

		If cMoeda <> Nil
			Exit
		Endif

		DbSkip()
	EndDo

	If cMoeda = Nil .And. Len(aCols) = 0
		DbSelectArea("CTO")
		dbSeek(xFilial()+"01",.T.)
		AADD(aCols, { "01", " ", 0.00, "2", "1", 0.00, CTO->CTO_DESC, .F. } )
	Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ Ct381ConvMF ³ Autor ³ Lucas        ³ Data ³ 28.01.10       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Array com as moedas para calculo de variacao       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ct381ConvMF(cMoedaForte)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.					                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Ctba381    			                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = cMoedaForte                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ct381ConvMF(cMoedaForte)
	If !Empty(cMoedaForte)
		cMoedaForte := StrZero(Val(cMoedaForte),2)
	EndIf
Return( cMoedaForte )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ GetUTaxa    ³ Autor ³ Lucas        ³ Data ³ 28.01.10       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pegar a taxa do ultimo lancamento de variacao monetaria    ³±±
±±³          ³ para a Conta correspondente e Moeda.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GetUTaxa(cConta,cMoeda)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.					                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Ctba381    			                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = cMoedaForte                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GetUTaxa(cConta,cMoeda)
Local aArea   := GetArea()
Local cQuery  := ""
Local aTaxa   := {}
Local dData   := mv_par01
Local nTaxa   := 0.00

	If Select("QRYTAX") > 0
		QRYTAX->(DbCloseArea())
	EndIf

	cQuery := "SELECT CT2_DATA, CTP_TAXA"
	cQuery += " FROM "
	cQuery += RetSqlName("CT2") + " CT2, "
	cQuery += RetSqlName("CTP") + " CTP  "
	cQuery += " WHERE "
	cQuery += "  CT2.CT2_FILIAL = '" + xFilial("CT2") + "' "
	cQuery += "  AND CTP.CTP_FILIAL = '" + xFilial("CTP") + "' "
	cQuery += "  AND ( CT2.CT2_DEBITO = '" + cConta + "' AND CT2.CT2_ROTINA = 'CTBA381' OR CT2.CT2_CREDIT = '" + cConta + "' AND CT2.CT2_ROTINA = 'CTBA381' ) "
	cQuery += "  AND CT2.CT2_DATA < '" + DTOS(dData) + "' "
	cQuery += "  AND CT2.CT2_MOEDLC = CTP.CTP_MOEDA
	cQuery += "  AND CT2.CT2_DATA = CTP.CTP_DATA
	cQuery += "  AND CTP.CTP_MOEDA = '" + cMoeda + "' "
	cQuery += " ORDER BY CT2_DATA"

	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRYTAX",.T.,.F.)

	TcSetField("QRYTAX","CT2_DATA" ,"D",08,0)
	TcSetField("QRYTAX","CTP_TAXA" ,"N",TamSX3("CTP_TAXA")[1],TamSX3("CTP_TAXA")[2])

	QRYTAX->(DbGotop())

	While ! QRYTAX->(Eof())
		AADD(aTaxa,{QRYTAX->CT2_DATA, QRYTAX->CTP_TAXA})
		QRYTAX->(DbSkip())
	End
	QRYTAX->(DbCloseArea())

	If Len(aTaxa) > 0
		nTaxa := aTaxa[Len(aTaxa)][2]
	EndIf

RestArea(aArea)
Return( nTaxa )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb381OEntºAutor  ³Microsiga           º Data ³  03/25/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna uma array com as demais entidades (cinco em diante) º±±
±±º          ³com conteudo em branco                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb381OEnt()
Local aEntid := {}
Local nEntid

	If nQtdEntid == NIL
		nQtdEntid:= If(FindFunction("CtbQtdEntd"),CtbQtdEntd(),4) //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	EndIf

	aEntid := {}
	For nEntid := 1 TO ( nQtdEntid - 4 ) //quatro entidades sao padrao Conta /CC / Item / Classe de Valor
		aAdd(aEntid, { "", "" } )
	Next
Return( aEntid )
