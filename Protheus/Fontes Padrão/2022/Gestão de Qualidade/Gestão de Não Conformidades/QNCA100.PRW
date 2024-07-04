#Include "PROTHEUS.CH"
#INCLUDE "QNCA100.CH"
#include "DBTREE.CH"
#include "MSGRAPHI.CH"


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QNCA100  ³ Autor ³ Aldo Marini Junior    ³ Data ³ 07/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ FolloW-Up Estatistico                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Eduardo S.  ³17/09/02³ xxxx ³ Incluido o ponto QNCR051, utilizado na   ³±±
±±³            ³        ³      ³ Impressao da Ficha de Nao-Conformidade.  ³±±
±±³Eduardo S.  ³01/11/02³ xxxx ³ Alterado para apresentar prazo das etapas³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCA100

Local oBtn1, oBtn2, oBtn5,  oBtn7, oBtn8
Local cPerg			:= "QNC100"

Private aAnos       := {}
Private nTotFAno    := 0
Private nTotFPerc   := 0
Private nTotPAno    := 0
Private nTotPPerc   := 0
Private nFncTot     := 0
Private nPlnTot     := 0
Private nFncBai     := 0
Private nPlnBai     := 0
Private nFncPen     := 0
Private nPlnPen     := 0
Private oScrollBox, oPendBox, oDlg
Private oFnt, oFnt20, oFnt15, oFntB
Private aSize     := MsAdvSize(.F.)
Private aObjects  := {{ 100, 100, .T., .T., .T. }}
Private aInfo     := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 4, 4 } 
Private aPosObj   := MsObjSize( aInfo, aObjects, .T. , .T. )
Private nTotAnos  := 0

Private oScrollGra, oMenu
Private aDatas :={}
Private oGroup1, oPanel1, oPanel2, oPanel3, oPanel4, oPanel5
Private oGroup2, oPanel6, oPanel7, oPanel8, oPanel9, oPanel10

DEFINE FONT oFnt   NAME "MonoAs" SIZE 05,15
DEFINE FONT oFntB  NAME "MonoAs" SIZE 05,15 BOLD
DEFINE FONT oFnt15 NAME "MonoAs" SIZE 07,15 BOLD
DEFINE FONT oFnt20 NAME "MonoAs" SIZE 10,15 BOLD 

IF !Pergunte(cPerg)
	Return Nil      
Else
	IF MV_PAR01==2 .AND. MV_PAR02==2 .AND. MV_PAR03==2
		Return Nil      	
	Endif
Endif	

CursorWait()
QNCA100TOTAL()

DEFINE MSDIALOG oDlg FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL TITLE OemToAnsi(STR0001)	// "Follow-UP Estatistico"

@ aSize[ 1 ],003 BUTTON oBtn1 PROMPT OemToAnsi(STR0019) SIZE 38,10 OF oDlg PIXEL ACTION (oScrollBox:lVisible:=.T.,IF(oPendBox<>NIL,oPendBox:lVisible:=.F.,""),IF(oScrollGra<>NIL,oScrollGra:lVisible:=.F.,"")) // "Totais"
@ aSize[ 1 ],043 BUTTON oBtn2 PROMPT OemToAnsi(STR0011) SIZE 38,10 OF oDlg PIXEL ACTION (IF(oScrollBox<>NIL,oScrollBox:lVisible:=.F.,""),oPendBox:lVisible:=.T.,IF(oScrollGra<>NIL,oScrollGra:lVisible:=.F.,"")) // "Pendencias"
@ aSize[ 1 ],083 BUTTON oBtn5 PROMPT OemToAnsi(STR0007) SIZE 38,10 OF oDlg PIXEL ACTION (IF(oScrollBox<>NIL,oScrollBox:lVisible:=.F.,""),IF(oPendBox<>NIL,oPendBox:lVisible:=.F.,""),oScrollGra:lVisible:=.T.) // "Graficos"
@ aSize[ 1 ],123 BUTTON oBtn7 PROMPT OemToAnsi(STR0005) SIZE 38,10 OF oDlg PIXEL ACTION oDlg:End() // "Sair"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Tela de Totalizadores                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF MV_PAR01==1
	QNC100OTOT()
Else
	oBtn1:Disable()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para Envio para o excel.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QNC100INT")           
	ExecBlock("QNC100INT",.F., .F.,{oDlg,nFncTot,nPlnTot,nFncBai,nPlnBai,nFncPen,nPlnPen,aAnos,nTotFAno,nTotFPerc,nTotPAno,nTotPPerc})
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Tela de Pendencias                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF MV_PAR02==1
	QNC100OPEN()
	IF MV_PAR01==2 
		oPendBox:lVisible:=.T.
	Endif	
Else
	oBtn2:Disable()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Tela de Graficos                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF MV_PAR03==1
	IF MV_PAR01==2
		QNC100OTOT()
		oScrollBox:lVisible:=.F.	
	Endif
	QNC100GRAF()
	IF MV_PAR01==1 .OR. MV_PAR02==1
		oScrollGra:lVisible:=.F.    
	Endif	
Else
	oBtn5:Disable()
Endif

CursorArrow()

ACTIVATE MSDIALOG oDlg

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QNC100OTOT ³ Autor ³ Aldo Marini Junior  ³ Data ³ 14/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para apresentar os totalizadores da FNC e Planos  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC100OTOT()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC100OTOT()
Local nMes      := 0
Local nAnoAtual := aScan(aAnos,{|x| x[1] == Year(dDataBase) })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona o ano atual no array para demonstracao              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nAnoAtual == 0
	aAdd(aAnos,{Year(dDataBase),{{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0}}})
	nAnoAtual := Len(aAnos)
	nTotAnos++
Endif

oScrollBox := TScrollBox():New(oDlg,aPosObj[1,1]+10, aPosObj[1,2], aPosObj[1,4],aPosObj[1,3],.T.,.T.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 
//³ Tela de Totalizadores                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@  1,80  to 60,151  OF oScrollBox PIXEL
@  1,150 to 60,225  OF oScrollBox PIXEL

@  1,01  to 60,300  OF oScrollBox PIXEL
@ 20,01  to 40,300  OF oScrollBox PIXEL

@ 10,2   say OemToAnsi(STR0008) OF oScrollBox FONT oFnt SIZE 80,10 PIXEL	// "Totalizadores/Tipos Lactos"

@ 10,100 say OemToAnsi(STR0009) OF oScrollBox FONT oFnt20 PIXEL					// "Total"
@ 10,170 say OemToAnsi(STR0010) OF oScrollBox FONT oFnt20 PIXEL					// "Baixados"
@ 10,240 say OemToAnsi(STR0011) OF oScrollBox FONT oFnt20 COLOR CLR_HRED PIXEL	// "Pendentes"

@ 30,2 say OemToAnsi(STR0012) OF oScrollBox FONT oFnt20 PIXEL		// "Fichas N.C."
@ 50,2 say OemToAnsi(STR0013) OF oScrollBox FONT oFnt20 PIXEL		// "Plano Acao"

@ 30,105 say Transform(nFncTot,"@e 999999")    OF oScrollBox FONT oFnt20 PIXEL
@ 50,105 say Transform(nPlnTot,"@e 999999")    OF oScrollBox FONT oFnt20 PIXEL

@ 30,175 say Transform(nFncBai,"@e 999999")    OF oScrollBox FONT oFnt20 PIXEL
@ 50,175 say Transform(nPlnBai,"@e 999999")    OF oScrollBox FONT oFnt20 PIXEL

@ 30,245 say Transform(nFncPen,"@e 999999")    OF oScrollBox FONT oFnt20 COLOR CLR_HRED PIXEL
@ 50,245 say Transform(nPlnPen,"@e 999999")    OF oScrollBox FONT oFnt20 COLOR CLR_HRED PIXEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela de Totalizadores de Ficha N.C. do ano corrente          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 73,30  say OemToAnsi(OemToAnsi(STR0014)+" "+StrZero(Year(dDataBase),4)+")") OF oScrollBox FONT oFnt15 PIXEL	// "Totais de Ficha de Ocorrencias/Nao-Conformidades por Mes (Ano"

@ 80,01  to 095,300  OF oScrollBox PIXEL
@ 80,01  to 110,300  OF oScrollBox PIXEL
@ 80,01  to 125,300  OF oScrollBox PIXEL

@ 85,125 say OemToAnsi(OemToAnsi(STR0015)) OF oScrollBox FONT oFnt20 PIXEL	// "M  E  S  E  S"

@095,025  to 125,050  OF oScrollBox PIXEL
@095,075  to 125,100  OF oScrollBox PIXEL
@095,125  to 125,150  OF oScrollBox PIXEL
@095,175  to 125,200  OF oScrollBox PIXEL
@095,225  to 125,250  OF oScrollBox PIXEL
@095,275  to 125,300  OF oScrollBox PIXEL

@070,001  to 135,300  OF oScrollBox PIXEL

@098,010 say OemToAnsi("01") OF oScrollBox PIXEL
@098,035 say OemToAnsi("02") OF oScrollBox PIXEL
@098,060 say OemToAnsi("03") OF oScrollBox PIXEL
@098,085 say OemToAnsi("04") OF oScrollBox PIXEL
@098,110 say OemToAnsi("05") OF oScrollBox PIXEL
@098,135 say OemToAnsi("06") OF oScrollBox PIXEL
@098,160 say OemToAnsi("07") OF oScrollBox PIXEL
@098,185 say OemToAnsi("08") OF oScrollBox PIXEL
@098,210 say OemToAnsi("09") OF oScrollBox PIXEL
@098,235 say OemToAnsi("10") OF oScrollBox PIXEL
@098,260 say OemToAnsi("11") OF oScrollBox PIXEL
@098,285 say OemToAnsi("12") OF oScrollBox PIXEL

@112,005 say Transform(aAnos[nAnoAtual,2,1,1] ,"@e 9999") OF oScrollBox PIXEL
@112,030 say Transform(aAnos[nAnoAtual,2,2,1] ,"@e 9999") OF oScrollBox PIXEL
@112,055 say Transform(aAnos[nAnoAtual,2,3,1] ,"@e 9999") OF oScrollBox PIXEL
@112,080 say Transform(aAnos[nAnoAtual,2,4,1] ,"@e 9999") OF oScrollBox PIXEL
@112,105 say Transform(aAnos[nAnoAtual,2,5,1] ,"@e 9999") OF oScrollBox PIXEL
@112,130 say Transform(aAnos[nAnoAtual,2,6,1] ,"@e 9999") OF oScrollBox PIXEL
@112,155 say Transform(aAnos[nAnoAtual,2,7,1] ,"@e 9999") OF oScrollBox PIXEL
@112,180 say Transform(aAnos[nAnoAtual,2,8,1] ,"@e 9999") OF oScrollBox PIXEL
@112,205 say Transform(aAnos[nAnoAtual,2,9,1] ,"@e 9999") OF oScrollBox PIXEL
@112,230 say Transform(aAnos[nAnoAtual,2,10,1] ,"@e 9999") OF oScrollBox PIXEL
@112,255 say Transform(aAnos[nAnoAtual,2,11,1] ,"@e 9999") OF oScrollBox PIXEL
@112,280 say Transform(aAnos[nAnoAtual,2,12,1] ,"@e 9999") OF oScrollBox PIXEL

For nMes := 1 to 12
	nTotFAno += aAnos[nAnoAtual,2,nMes,1]
Next
nTotFPerc := (nTotFAno/nFncTot)*100

@ 127,025 say OemToAnsi(STR0016+" = "+Transform(nTotFAno,"@e 9999")+Space(15)+STR0017+" "+Transform(nTotFPerc,"@e 999")+"%") OF oScrollBox FONT oFnt20 PIXEL	// "Total Ano" ### "Percentual Total"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela de Totalizadores de Plano de Acao                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

@143,60  say OemToAnsi(OemToAnsi(STR0018)+" "+StrZero(Year(dDataBase),4)+")") OF oScrollBox FONT oFnt15 PIXEL	// "Totais de Plano de Acao por Mes (Ano"

@150,01  to 165,300  OF oScrollBox PIXEL
@150,01  to 180,300  OF oScrollBox PIXEL
@150,01  to 195,300  OF oScrollBox PIXEL

@155,125 say OemToAnsi(OemToAnsi(STR0015)) OF oScrollBox FONT oFnt20 PIXEL	// "M  E  S  E  S"

@165,025  to 195,050  OF oScrollBox PIXEL
@165,075  to 195,100  OF oScrollBox PIXEL
@165,125  to 195,150  OF oScrollBox PIXEL
@165,175  to 195,200  OF oScrollBox PIXEL
@165,225  to 195,250  OF oScrollBox PIXEL
@165,275  to 195,300  OF oScrollBox PIXEL

@140,001  to 205,300  OF oScrollBox PIXEL

@168,010 say OemToAnsi("01") OF oScrollBox PIXEL
@168,035 say OemToAnsi("02") OF oScrollBox PIXEL
@168,060 say OemToAnsi("03") OF oScrollBox PIXEL
@168,085 say OemToAnsi("04") OF oScrollBox PIXEL
@168,110 say OemToAnsi("05") OF oScrollBox PIXEL
@168,135 say OemToAnsi("06") OF oScrollBox PIXEL
@168,160 say OemToAnsi("07") OF oScrollBox PIXEL
@168,185 say OemToAnsi("08") OF oScrollBox PIXEL
@168,210 say OemToAnsi("09") OF oScrollBox PIXEL
@168,235 say OemToAnsi("10") OF oScrollBox PIXEL
@168,260 say OemToAnsi("11") OF oScrollBox PIXEL
@168,285 say OemToAnsi("12") OF oScrollBox PIXEL

@182,005 say Transform(aAnos[nAnoAtual,2,1,2] ,"@e 9999") OF oScrollBox PIXEL
@182,030 say Transform(aAnos[nAnoAtual,2,2,2] ,"@e 9999") OF oScrollBox PIXEL
@182,055 say Transform(aAnos[nAnoAtual,2,3,2] ,"@e 9999") OF oScrollBox PIXEL
@182,080 say Transform(aAnos[nAnoAtual,2,4,2] ,"@e 9999") OF oScrollBox PIXEL
@182,105 say Transform(aAnos[nAnoAtual,2,5,2] ,"@e 9999") OF oScrollBox PIXEL
@182,130 say Transform(aAnos[nAnoAtual,2,6,2] ,"@e 9999") OF oScrollBox PIXEL
@182,155 say Transform(aAnos[nAnoAtual,2,7,2] ,"@e 9999") OF oScrollBox PIXEL
@182,180 say Transform(aAnos[nAnoAtual,2,8,2] ,"@e 9999") OF oScrollBox PIXEL
@182,205 say Transform(aAnos[nAnoAtual,2,9,2] ,"@e 9999") OF oScrollBox PIXEL
@182,230 say Transform(aAnos[nAnoAtual,2,10,2],"@e 9999") OF oScrollBox PIXEL
@182,255 say Transform(aAnos[nAnoAtual,2,11,2],"@e 9999") OF oScrollBox PIXEL
@182,280 say Transform(aAnos[nAnoAtual,2,12,2],"@e 9999") OF oScrollBox PIXEL

For nMes := 1 to 12
	nTotPAno += aAnos[nAnoAtual,2,nMes,2]
Next
nTotPPerc := (nTotPAno/nPlnTot)*100

@ 197,025 say OemToAnsi(STR0016+" = "+Transform(nTotPAno,"@e 9999")+Space(15)+STR0017+" "+Transform(nTotPPerc,"@e 999")+"%") OF oScrollBox FONT oFnt20 PIXEL	// "Total Ano" ### "Percentual Total"

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCA100TOTAL³ Autor ³ Aldo Marini Junior  ³ Data ³ 14/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para totalizar os Lactos de FNC e Planos de Acao  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCA100TOTAL()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNCA100TOTAL()
Local nAnosF := Year(dDatabase)
Local nAnosI := Year(dDataBase)-4
Local nA     := 0

nFncTot := 0
nPlnTot := 0
nFncBai := 0
nPlnBai := 0
nFncPen := 0
nPlnPen := 0

aAnos := {}
dbSelectArea("QI3")
dbSetOrder(1)

dbSelectArea("QI2")
dbSetOrder(1)
For nA := nAnosI to nAnosF
	If QI2->(dbSeek(xFilial("QI2")+StrZero(nA,4)))
		nTotAnos++
		aAdd(aAnos,{nA,{{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0}}})
	Else
		If QI3->(dbSeek(xFilial("QI3")+StrZero(nA,4)))
			nTotAnos++
			aAdd(aAnos,{nA,{{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0}}})
		Endif	
	Endif
Next

dbSelectArea("QI2")
dbSeek(xFilial("QI2"))
While !Eof() .And. xFilial("QI2") == QI2->QI2_FILIAL
	If Empty(QI2->QI2_CONREA)
		nFncPen++
	Else
		nFncBai++
	Endif
	If (nPosAtu := aScan(aAnos,{|x|x[1] == Year(QI2->QI2_OCORRE) } )) > 0
		aAnos[nPosAtu,2,Month(QI2->QI2_OCORRE),1] := aAnos[nPosAtu,2,Month(QI2->QI2_OCORRE),1] + 1
	Endif
	dbSkip()
Enddo

dbSelectArea("QI3")
dbSeek(xFilial("QI3"))
While !Eof() .And. xFilial("QI3") == QI3->QI3_FILIAL
	If Empty(QI3->QI3_ENCREA)
		nPlnPen++
	Else
		nPlnBai++
	Endif
	If (nPosAtu := aScan(aAnos,{|x|x[1] == Year(QI3->QI3_ABERTU) } )) > 0
		aAnos[nPosAtu,2,Month(QI3->QI3_ABERTU),2] := aAnos[nPosAtu,2,Month(QI3->QI3_ABERTU),2] + 1
	Endif
	dbSkip()
Enddo

nFncTot := nFncPen+nFncBai
nPlnTot := nPlnPen+nPlnBai

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QNC100OPEN ³ Autor ³ Aldo Marini Junior  ³ Data ³ 14/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para montar o Tree com os Lactos Pendentes        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC100OPEN()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC100OPEN()

Local nSeqTree  := 0
Local cArqNtx2  := ""
Local cQuery    := ""
Local cIndCond2 := ""
Local cFor2     := ""
Local cArqNtx3  := ""
Local cIndCond3 := ""
Local cFor3     := ""
Local cArqNtx5  := ""
Local cIndCond5 := ""
Local cFor5     := ""
Local lQI2Exist := .F.
Local lQI3Exist := .F.
Local lQI5Exist := .F.
Local lQAAExist := .F.
Local cDias     := ""
Local cStatus	:= ""
Local cTitStat	:= RetTitle("QI5_STATUS") 
Local lAS400 	:= IIf(TCSRVType() == "AS/400",.T.,.F.)

INCLUI := .F.

dbSelectArea("QI2")
cIndCond2 := 'QI2->QI2_FILRES+QI2->QI2_MATRES+QI2->QI2_FNC+QI2->QI2_REV'
If lAS400
	cFor2     := 'DTOS(QI2_CONREA) == ""'
Else
	cFor2     := 'EMPTY(QI2_CONREA)'
EndIf
cFor2     += '.And. QI2_FILIAL == "'+xFilial("QI2")+'"'
cArqNtx2  := CriaTrab(NIL,.F.)
IndRegua("QI2",cArqNtx2,cIndCond2,,cFor2,STR0023)		//"Selecionando Registros..."
DbGoTop()

dbSelectArea("QI3")
cIndCond3 := 'QI3->QI3_FILMAT+QI3->QI3_MAT+QI3->QI3_CODIGO+QI3->QI3_REV'
If lAS400
	cFor3     := 'DTOS(QI3_ENCREA) == ""'
Else
	cFor3     := 'EMPTY(QI3_ENCREA)'
EndIf
cFor3     += '.And. QI3_FILIAL == "'+xFilial("QI3")+'"'
cArqNtx3  := CriaTrab(NIL,.F.)
IndRegua("QI3",cArqNtx3,cIndCond3,,cFor3,STR0023)		//"Selecionando Registros..."
DbGoTop()

dbSelectArea("QI5")
cIndCond5 := 'QI5->QI5_FILMAT+QI5->QI5_MAT+QI5->QI5_CODIGO+QI5->QI5_REV'
cFor5     := 'QI5_STATUS <> "4"'
cFor5     += '.And. QI5_FILIAL == "'+xFilial("QI5")+'"'
cArqNtx5  := CriaTrab(NIL,.F.)
IndRegua("QI5",cArqNtx5,cIndCond5,,cFor5,STR0023)		//"Selecionando Registros..."
DbGoTop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao do objeto do Tree considerando o tamanho da tela     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPendBox := DbTree():New(aPosObj[1,1]+10, aPosObj[1,2], aPosObj[1,4]+10,aPosObj[1,3]+3, oDlg,,,.T.)

cQuery :="SELECT QAA.QAA_FILIAL, QAA.QAA_NOME , QAA.QAA_MAT  FROM "
cQuery += RetSqlName("QAA")+" QAA "
cQuery +=" WHERE QAA_FILIAL = '"+xFilial("QAA")+"' AND"
cQuery +=" (QAA_FILIAL = '"+xFilial("QAA")+"' AND" 
cQuery +=" QAA_STATUS = '1' AND QAA_SITQNC = 2 ) OR" 
cQuery +=" ( QAA_FILIAL = '"+xFilial("QAA")+"' AND" 
cQuery +=" QAA_STATUS = '2' AND QAA_SITQNC = 4) AND"
cQuery +=" D_E_L_E_T_ = ' '"
cQuery +=" ORDER BY QAA_FILIAL, QAA_NOME, QAA_MAT"
cQuery := ChangeQuery(cQuery)

If Select("QAAQNC") > 0
	QAAQNC->(dbCloseArea())
Endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QAAQNC")
QAAQNC->(dbGoTop())
While QAAQNC->(!Eof())
	lQAAExist := .F.
	If QA_SitFolh()
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta as pendencias de Fichas de Ocorrencias/Nao-conformidades ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
		lQI2Exist := .F.
		cQuery := "SELECT * FROM "+RetSqlName("QI2")+" WHERE D_E_L_E_T_ <> '*' AND QI2_CONREA = '' AND QI2_FILIAL = '"+xFilial("QI2")+"'"
		cQuery += " AND QI2_MATRES = '"+QAAQNC->QAA_MAT+"'"
		cQuery += " ORDER BY QI2_FILIAL, QI2_FNC, QI2_ANO, QI2_REV"
		cQuery := ChangeQuery(cQuery)
		If Select("QI2SFOL") > 0
			QI2SFOL->(dbCloseArea())
		Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QI2SFOL")
			
			
		dbSelectArea("QI2")
		dbSetOrder(4)
		If dbSeek(QAAQNC->QAA_FILIAL+QAAQNC->QAA_MAT)
			While QI2SFOL->(!EOF())
					
				If !lQI2Exist
					If !lQAAExist
						oPendBox:AddTree( Padr(QAAQNC->QAA_FILIAL+"-"+QAAQNC->QAA_MAT+" "+QAAQNC->QAA_NOME,190), .F., "BMPUSER",,,, StrZero(nSeqTree++,10) )
						lQAAExist := .T.
					Endif
					oPendBox:AddTree( Padr(OemToAnsi(STR0021),190), .F., "BMPCPO",,,, StrZero(nSeqTree++,10) )	// "Fichas de Ocorrencias/Nao-Conformidades"
					lQI2Exist := .T.
				Endif
						
				dbSelectArea("QI2")
				dbsetOrder(1)
				dbSeek(QI2SFOL->QI2_FILIAL+QI2SFOL->QI2_ANO+QI2SFOL->QI2_FNC+QI2SFOL->QI2_REV)
						
				oPendBox:AddTreeItem(PADR(TransForm(QI2->QI2_FNC,"@R ###########/####")+"-"+QI2->QI2_REV+" - "+QI2->QI2_DESCR,190),"PMSDOC",,"FNC"+StrZero(QI2->(Recno()),7))
				dbSelectArea("QI2SFOL")
				QI2SFOL->(dbskip())
			Enddo
		Endif
			
		If lQI2Exist
			oPendBox:EndTree()
		Endif
			
		QI2SFOL->(DbCloseArea())
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta as pendencias de Plano de Acao                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lQI3Exist := .F.
		cQuery := "SELECT * FROM "+RetSqlName("QI3")+" WHERE D_E_L_E_T_ <> '*' AND QI3_ENCREA = '' AND QI3_FILIAL = '"+xFilial("QI3")+"'"
		cQuery += " AND QI3_MAT = '"+QAAQNC->QAA_MAT+"'"
		cQuery += " ORDER BY QI3_FILIAL, QI3_CODIGO, QI3_ANO, QI3_REV"
		cQuery := ChangeQuery(cQuery)
		If Select("QI3SFOL") > 0
			QI3SFOL->(dbCloseArea())
		Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QI3SFOL")
			
		dbSelectArea("QI3")
		dbsetOrder(3)
		If dbSeek(QAAQNC->QAA_FILIAL+QAAQNC->QAA_MAT)
			While QI3SFOL->(!EOF())
				If !lQI3Exist
					If !lQAAExist
						oPendBox:AddTree( Padr(QAAQNC->QAA_FILIAL+"-"+QAAQNC->QAA_MAT+" "+QAAQNC->QAA_NOME,190), .F., "BMPUSER",,,, StrZero(nSeqTree++,10) )
						lQAAExist := .T.
					Endif
					oPendBox:AddTree( Padr(OemToAnsi(STR0022),190), .F., "NEXT",,,, StrZero(nSeqTree++,10) )	// "Plano de Acao"
					lQI3Exist := .T.
				Endif
						
				dbSelectArea("QI3")
				dbsetOrder(1)
				dbSeek(QI3SFOL->QI3_FILIAL+QI3SFOL->QI3_ANO+QI3SFOL->QI3_CODIGO+QI3SFOL->QI3_REV)
						
				oPendBox:AddTreeItem(PADR(TransForm(QI3->QI3_CODIGO,"@R ###########/####")+"-"+QI3->QI3_REV,190),"PMSDOC",,"PLN"+StrZero(QI3->(Recno()),7))
				dbSelectArea("QI3SFOL")
				QI3SFOL->(dbskip())
			Enddo
		Endif
			
		If lQI3Exist
			oPendBox:EndTree()
		Endif
			
		QI3SFOL->(DbCloseArea())
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta as pendencias de Etapas/Passos do Plano de Acao          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lQI5Exist := .F.
		cQuery := "SELECT * FROM "+RetSqlName("QI5")+" WHERE D_E_L_E_T_ <> '*' AND QI5_STATUS <> '4' AND QI5_FILIAL = '"+xFilial("QI5")+"'"
		cQuery += " AND QI5_MAT = '"+QAAQNC->QAA_MAT+"'"
		cQuery += " ORDER BY QI5_FILIAL, QI5_CODIGO, QI5_REV, QI5_SEQ"
		cQuery := ChangeQuery(cQuery)
		If Select("QI5SFOL") > 0
			QI5SFOL->(dbCloseArea())
		Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QI5SFOL")
			
		dbSelectArea("QI5")
		dbSetOrder(2)
		If dbSeek(QAAQNC->QAA_FILIAL+QAAQNC->QAA_MAT)
			While QI5SFOL->(!EOF())
				If !lQI5Exist
					If !lQAAExist
						oPendBox:AddTree( Padr(QAAQNC->QAA_FILIAL+"-"+QAAQNC->QAA_MAT+" "+QAAQNC->QAA_NOME,190), .F., "BMPUSER",,,, StrZero(nSeqTree++,10) )
						lQAAExist := .T.
					Endif
					oPendBox:AddTree( Padr(OemToAnsi(STR0026),190), .F., "BMPTRG",,,, StrZero(nSeqTree++,10) )	// "Etapas/Passos do Plano de Acao"
					lQI5Exist := .T.
				Endif
						
				dbSelectArea("QI5")
				dbsetOrder(1)
				dbSeek(QI5SFOL->QI5_FILIAL+QI5SFOL->QI5_CODIGO+QI5SFOL->QI5_REV+QI5SFOL->QI5_SEQ)
						
				If !Empty(QI5->QI5_PRAZO)
					If (QI5->QI5_PRAZO - dDatabase) > 0
						cDias:= " - "+OemToAnsi(STR0040)+": "+StrZero((QI5->QI5_PRAZO - dDatabase),4) // "Prazo (Em Dias)"
						cDias+= " "+OemToAnsi(STR0038) // "A Vencer"
					Else
						cDias:= " - "+OemToAnsi(STR0040)+": "+StrZero((dDataBase - QI5->QI5_PRAZO),4) // "Prazo (Em Dias)"
						cDias+=	" "+OemToAnsi(STR0039) // "Vencido"
					EndIf
				EndIf
				
				cStatus := " - " + cTitStat + ": " + QA_CBox("QI5_STATUS",If(Empty(QI5->QI5_STATUS), "0", If(QI5->QI5_STATUS > "4", "4", QI5->QI5_STATUS)))
				oPendBox:AddTreeItem(PADR(OemToAnsi(STR0022)+": "+TransForm(QI5->QI5_CODIGO,"@r ###########/####")+"-"+QI5->QI5_REV+"  "+OemToAnsi(STR0025)+": "+QI5->QI5_TPACAO+"-"+AllTrim(Left(FQNCDSX5("QD",QI5->QI5_TPACAO),50))+If(!Empty(cDias),cDias," ") + cStatus,190),"PMSDOC",,"ETA"+StrZero(QI5->(Recno()),7))	// "Plano de Acao" ### "Etapa"
				cDias:= " "
				dbSelectArea("QI5SFOL")
				QI5SFOL->(dbskip())
			Enddo
		Endif
			
		If lQI5Exist
			oPendBox:EndTree()
		Endif
	
		If lQAAExist
			oPendBox:EndTree()
		Endif










			
		QI5SFOL->(DbCloseArea())
				
	Endif // QA_SitFolh()
	cDias:= " "
	QAAQNC->(dbSkip())
Enddo				

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o menu de opcoes POPUP                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MENU oMenu POPUP
	MENUITEM OemToAnsi(STR0012) Action FActionQNC(1,oPendBox)	// "Fichas N.C."
	MENUITEM OemToAnsi(STR0013) Action FActionQNC(2,oPendBox)	// "Plano Acao"
	MENUITEM OemToAnsi(STR0004) Action FActionQNC(3,oPendBox) 	// "Imprimir"
ENDMENU

oPendBox:bRClicked:= { |o,x,y| FATIVAPOPUP( o, x, y, oMenu ) } // Posicao x,y em relação a Dialog
oPendBox:lVisible:=.F.

dbSelectArea("QI2")
RetIndex("QI2")
dbSetOrder(1)
Set Filter to

dbSelectArea("QI3")
RetIndex("QI3")
dbSetOrder(1)
Set Filter to

dbSelectArea("QI5")
RetIndex("QI5")
dbSetOrder(1)
Set Filter to

fErase( cArqNtx2 + OrdBagExt())
fErase( cArqNtx2 + GetDBExtension() )

fErase( cArqNtx3 + OrdBagExt())
fErase( cArqNtx3 + GetDBExtension() )

fErase( cArqNtx5 + OrdBagExt())
fErase( cArqNtx5 + GetDBExtension() )

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FActionQNC ³ Autor ³ Aldo Marini Junior  ³ Data ³ 29/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para carregar os Cadastros de Fichas,Planos e Imp.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FActionQNC(nOpcao,oTree)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Numerico contendo a opcao(1-FNC/2-Plano/3-Imprime) ³±±
±±³          ³ ExpO1 - Objeto do Tree para poder pegar o numero do recno()³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FActionQNC(nOpcao,oTree)
Local cCargo:=oTree:GetCargo()
Local nReg := 0
Local cAliasOld := Alias()
Local nIndexOrd := IndexOrd()
Private aRotina := { {"","",0,0}, {OemToAnsi(STR0029),"QNC030Alt",0,2}, {"","",0,0}, {"","",0,0}, {"","",0,0}, {"","",0,0} } //"Visualizar"
INCLUI := .F.

If Left( cCargo, 3 ) == "FNC"
	nReg := Val(SubStr(cCargo,4,7))
	dbSelectArea("QI2")
	dbGoTo(nReg)
	If nOpcao == 3 	// Imprime
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime a Ficha de Ocorrencia/Nao-Conformidade formato MsPrint ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("QNCR051")
			ExecBlock( "QNCR051",.f.,.f.,{QI2->(Recno())})
		Else
			QNCR050(QI2->(Recno()))
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Funcao de Visualizacao da Ficha de Ocorrencia/Nao-Conformidade ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QNC040Alt("QI2",QI2->(Recno()),2)
	Endif
	
ElseIf Left( cCargo, 3 ) == "PLN"
	nReg := Val(SubStr(cCargo,4,7))
	dbSelectArea("QI3")
	dbGoTo(nReg)

	If nOpcao == 3 	// Imprime
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime o Plano de Acao no formato MsPrint                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QNCR060(QI3->(Recno()))

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Funcao de Visualizacao do Plano de Acoes do Programa QNCA030 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QNC030Alt("QI3",QI3->(Recno()),2)
	Endif
	
ElseIf Left( cCargo, 3 ) == "ETA"
	nReg := Val(SubStr(cCargo,4,7))
	dbSelectArea("QI5")
	dbGoTo(nReg)

	dbSelectArea("QI3")
	If dbSeek(QI5->QI5_FILIAL+Right(QI5->QI5_CODIGO,4)+QI5->QI5_CODIGO+QI5->QI5_REV)

		If nOpcao == 3 	// Imprime
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime o Plano de Acao no formato MsPrint                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QNCR060(QI3->(Recno()))

		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Funcao de Visualizacao do Plano de Acoes do Programa QNCA030 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QNC030Alt("QI3",QI3->(Recno()),2)
		Endif
    Endif
Endif

dbSelectArea(cAliasOld)
dbSetOrder(nIndexOrd)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FATIVAPOPUP ³ Autor ³ Aldo Marini Junior  ³ Data ³ 29/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para carregar os Cadastros de Fichas,Planos e Imp.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FATIVAPOPUP( oTree, nX, nY, oMenu )                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto do Tree                                     ³±±
±±³          ³ ExpN1 - Numerico contendo as coordenadas da linha          ³±±
±±³          ³ ExpN2 - Numerico contendo as coordenadas da coluna         ³±±
±±³          ³ ExpO2 - Objeto do POPUP - Menu                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FATIVAPOPUP( oTree, nX, nY, oMenu )
Local cCargo := oTree:GetCargo() 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desabilita todos os itens do menu                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AEval( oMenu:aItems, { |x| x:Disable() } ) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Habilita as opcoes de acordo com a entidade do tree          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Left( cCargo, 3 ) == "FNC"
	oMenu:aItems[1]:enable()
	oMenu:aItems[3]:enable()
ElseIf Left( cCargo, 3 ) == "PLN" .Or. Left( cCargo, 3 ) == "ETA"
	oMenu:aItems[2]:enable()
	oMenu:aItems[3]:enable()
EndIf

oMenu:Activate( nX, nY, oTree )

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QNC100GRAF ³ Autor ³ Aldo Marini Junior  ³ Data ³ 14/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para montar e apresentar Graficos dos Totais "Mes"³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC100GRAF()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC100GRAF()

Local oFichas, oPlanos, oLegFichas, oLegPlanos
Local oTitulo1, oTitulo2, oAnoAtual, oGraphic, oGraphicT
Local lAnoAtual  := .T.
Local lFichas    := .T.
Local lPlanos    := .F.
Local nColTitulo := 0

aPosObj[1,1]:=16
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Scroll dos Graficos                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oScrollGra := TScrollBox():new(oDlg,aPosObj[1,1]+10, aPosObj[1,2], aPosObj[1,4],aPosObj[1,3],.T.,.T.,.T.)
nColTitulo := (aPosObj[1,4]/2)-10

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta legenda do Grafico Geral de Fichas e Planos            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ aPosObj[1,1]+35,aPosObj[1,3]-65 GROUP oGroup1 TO aPosObj[1,1]+130,aPosObj[1,3]-40 LABEL OemToAnsi(STR0030) OF oScrollGra PIXEL	// "Fichas"

@ aPosObj[1,1]+43,aPosObj[1,3]-60 MSPANEL oPanel1 PROMPT OemToAnsi(" "+StrZero(Year(dDataBase)-4,4)+" ") COLOR CLR_WHITE,CLR_BLUE  SIZE 14,08 OF oScrollGra
@ aPosObj[1,1]+50,aPosObj[1,3]-60 MSPANEL oPanel2 PROMPT OemToAnsi(" "+StrZero(Year(dDataBase)-3,4)+" ") COLOR CLR_WHITE,CLR_GREEN SIZE 14,08 OF oScrollGra
@ aPosObj[1,1]+57,aPosObj[1,3]-60 MSPANEL oPanel3 PROMPT OemToAnsi(" "+StrZero(Year(dDataBase)-2,4)+" ") COLOR CLR_WHITE,CLR_CYAN  SIZE 14,08 OF oScrollGra
@ aPosObj[1,1]+64,aPosObj[1,3]-60 MSPANEL oPanel4 PROMPT OemToAnsi(" "+StrZero(Year(dDataBase)-1,4)+" ") COLOR CLR_WHITE,CLR_RED   SIZE 14,08 OF oScrollGra
@ aPosObj[1,1]+71,aPosObj[1,3]-60 MSPANEL oPanel5 PROMPT OemToAnsi(" "+StrZero(Year(dDataBase)  ,4)+" ") COLOR CLR_WHITE,CLR_BLACK SIZE 14,08 OF oScrollGra

@ aPosObj[1,1]+82,aPosObj[1,3]-65 GROUP oGroup2 TO aPosObj[1,1]+130,aPosObj[1,3]-40 LABEL OemToAnsi(STR0031) OF oScrollGra PIXEL	// "Planos"

@ aPosObj[1,1]+090,aPosObj[1,3]-60 MSPANEL oPanel6  PROMPT OemToAnsi(" "+StrZero(Year(dDataBase)-4,4)+" ") COLOR CLR_WHITE,CLR_HBLUE  SIZE 14,08 OF oScrollGra
@ aPosObj[1,1]+097,aPosObj[1,3]-60 MSPANEL oPanel7  PROMPT OemToAnsi(" "+StrZero(Year(dDataBase)-3,4)+" ") COLOR CLR_BLACK,CLR_HGREEN SIZE 14,08 OF oScrollGra
@ aPosObj[1,1]+104,aPosObj[1,3]-60 MSPANEL oPanel8  PROMPT OemToAnsi(" "+StrZero(Year(dDataBase)-2,4)+" ") COLOR CLR_BLACK,CLR_HCYAN  SIZE 14,08 OF oScrollGra
@ aPosObj[1,1]+111,aPosObj[1,3]-60 MSPANEL oPanel9  PROMPT OemToAnsi(" "+StrZero(Year(dDataBase)-1,4)+" ") COLOR CLR_WHITE,CLR_HRED   SIZE 14,08 OF oScrollGra
@ aPosObj[1,1]+118,aPosObj[1,3]-60 MSPANEL oPanel10 PROMPT OemToAnsi(" "+StrZero(Year(dDataBase)  ,4)+" ") COLOR CLR_WHITE,CLR_GRAY   SIZE 14,08 OF oScrollGra

FControlPanel(.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Titulo e legenda do Grafico do ano corrente            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 7,nColTitulo say oTitulo1 PROMPT OemToAnsi(STR0027)+" "+StrZero(Year(dDatabase),4) OF oScrollGra FONT oFnt20 COLOR CLR_HRED PIXEL	// "Grafico de Totais do Ano"
@ 7,nColTitulo+20 say oTitulo2 PROMPT OemToAnsi(STR0032) OF oScrollGra FONT oFnt20 COLOR CLR_HRED PIXEL	// "Grafico de Totais"

@ aPosObj[1,1]+5  ,aPosObj[1,3]-62 CHECKBOX oFichas VAR lFichas PROMPT OemToAnsi(STR0012) SIZE 50,09 OF oScrollGra PIXEL	// "Fichas N.C."
oFichas:bChange:={||(oLegFichas:lVisible:=lFichas,QNCA100MGRA(@oGraphic,lFichas,lPlanos,lAnoAtual),If(!lFichas,oPlanos:lReadOnly:=.T.,oPlanos:lReadOnly:=.F.))}
oFichas:lReadOnly:=.T.

@ aPosObj[1,1]+15 ,aPosObj[1,3]-62 CHECKBOX oPlanos VAR lPlanos PROMPT OemToAnsi(STR0022) SIZE 50,09 OF oScrollGra PIXEL	// "Plano de Acao"
oPlanos:bChange:={||(oLegPlanos:lVisible:=lPlanos,QNCA100MGRA(@oGraphic,lFichas,lPlanos,lAnoAtual),If(!lPlanos,oFichas:lReadOnly:=.T.,oFichas:lReadOnly:=.F.))}

@ aPosObj[1,1]+25 ,aPosObj[1,3]-62 CHECKBOX oAnoAtual VAR lAnoAtual PROMPT OemToAnsi(STR0033) SIZE 50,09 OF oScrollGra PIXEL	// "Ano Atual"
oAnoAtual:bChange:={||( QNCA100MGRA(@oGraphic,lFichas,lPlanos,lAnoAtual),;
					If(!lAnoAtual .And. nTotAnos > 1,oLegFichas:lVisible:=.F.,oLegFichas:lVisible:=.T.),;
					If(!lAnoAtual .And. nTotAnos > 1,oLegPlanos:lVisible:=.F.,oLegPlanos:lVisible:=.T.),;
					If(!lAnoAtual .And. nTotAnos > 1,oTitulo1:lVisible:=.F.,oTitulo1:lVisible:=.T.),;
					If(!lAnoAtual .And. nTotAnos > 1,oTitulo2:lVisible:=.T.,oTitulo2:lVisible:=.F.),;
					FControlPanel(If(!lAnoAtual .And. nTotAnos > 1,.T.,.F.)))}
					
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Grafico ano corrente                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QNCA100MGRA(@oGraphic,lFichas,lPlanos,lAnoAtual)

@ 7,5 say oLegFichas PROMPT OemToAnsi(STR0034) OF oScrollGra FONT oFnt COLOR CLR_GREEN PIXEL	// "Total de FNC"
@13,5 say oLegPlanos PROMPT OemToAnsi(STR0035) OF oScrollGra FONT oFnt COLOR CLR_BLUE  PIXEL	// "Total de Planos"

oLegFichas:lVisible:=lFichas
oLegPlanos:lVisible:=lPlanos
oTitulo2:lVisible:=.F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Grafico do total geral                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QNCA100MTGRA(@oGraphicT)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QNCA100MGRA³ Autor ³ Aldo Marini Junior  ³ Data ³ 14/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para montar os campos do Grafico                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCA100MGRA()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNCA100MGRA(oGraphic,lFichas,lPlanos,lAnoAtual)
Local nAnoT   := 0
Local nSerie  := 0
Local nSerie2 := 0
Local oGraphicAux
Local nAnoAtual := aScan(aAnos,{|x| x[1] == Year(dDataBase) })
Local mn

@ aPosObj[1,1]+5,aPosObj[1,2] MSGRAPHIC oGraphicAux SIZE aPosObj[1,3]-80,aPosObj[1,4]-30 OF oScrollGra PIXEL
oGraphicAux:SetMargins( 2, 6, 6, 6 )

If !lAnoAtual .And. nTotAnos > 1

	If lFichas
		For nAnoT := 1 to nTotAnos
			&("nSerie1"+Str(nAnoT,1))  := oGraphicAux:CreateSerie(4)
			If &("nSerie1"+Str(nAnoT,1)) == GRP_CREATE_ERR
				Return Nil
			Endif
		Next
	Endif
	If lPlanos
		For nAnoT := 1 to nTotAnos
			&("nSerie2"+Str(nAnoT,1))  := oGraphicAux:CreateSerie(4)
			If &("nSerie2"+Str(nAnoT,1)) == GRP_CREATE_ERR
				Return Nil
			Endif
		Next
	Endif

	For mn:=1 to 12
		For nAnoT := 1 to Len(aAnos)
			If lFichas
				oGraphicAux:Add(&("nSerie1"+Str(nAnoT,1)),aAnos[nAnoT,2,mn,1],Strzero(mn,2),QNC100COR(1,aAnos[nAnoT,1]))
			Endif
			If lPlanos
				oGraphicAux:Add(&("nSerie2"+Str(nAnoT,1)),aAnos[nAnoT,2,mn,2],Strzero(mn,2),QNC100COR(2,aAnos[nAnoT,1]))
			Endif
		Next
	Next
Else
	If lFichas
		nSerie  := oGraphicAux:CreateSerie(4)
		If nSerie == GRP_CREATE_ERR
			Return Nil
		Endif
	Endif
	If lPlanos
		nSerie2 := oGraphicAux:CreateSerie(4)
		If nSerie2 == GRP_CREATE_ERR
			Return Nil
		Endif
	Endif

	For mn:=1 to 12
		If lFichas
			oGraphicAux:Add(nSerie,aAnos[nAnoAtual,2,mn,1],Strzero(mn,2),CLR_GREEN)
		Endif
		If lPlanos
			oGraphicAux:Add(nSerie2,aAnos[nAnoAtual,2,mn,2],Strzero(mn,2),CLR_BLUE)
		Endif
	Next
Endif

oGraphicAux:SetGradient( GDBOTTOMTOP, CLR_WHITE, CLR_WHITE )
oGraphicAux:SetTitle( OemToAnsi(STR0036) , "", CLR_BLACK, A_CENTER , GRP_FOOT  ) // "Meses"
oGraphicAux:SetMargins( 2, 2, 2, 2 )
oGraphicAux:SetLegenProp( 4, CLR_YELLOW, 4, .F. )
oGraphicAux:l3D:=.F.
oGraphic:=oGraphicAux

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCA100MTGRA³ Autor ³ Aldo Marini Junior  ³ Data ³ 14/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para montar os campos do Grafico                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCA100MTGRA(oGraphicAux)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto do Grafico total                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNCA100MTGRA(oGraphicAux)
Local nAnoT    := 0
Local nSerie   := 0
Local nSerie2  := 0
Local nTotFAno := 0
Local nTotPAno := 0
Local nLinIni := aPosObj[1,4]+15
Local oLegFichas, oLegPlanos, oTitulo
Local nColTitulo := (aPosObj[1,4]/2)-20
Local mn

@   nLinIni,5 say oLegFichas PROMPT OemToAnsi(STR0034) OF oScrollGra FONT oFnt COLOR CLR_GREEN PIXEL	// "Total de FNC"
@ nLinIni+6,5 say oLegPlanos PROMPT OemToAnsi(STR0035) OF oScrollGra FONT oFnt COLOR CLR_BLUE  PIXEL	// "Total de Planos"

@ nLinIni+2,nColTitulo say oTitulo PROMPT OemToAnsi(STR0037) OF oScrollGra FONT oFnt20 COLOR CLR_HRED PIXEL	// "Total Geral de Fichas e Planos"

@ nLinIni+21,aPosObj[1,2] MSGRAPHIC oGraphicAux SIZE aPosObj[1,3]-80,aPosObj[1,4]-30 OF oScrollGra PIXEL
oGraphicAux:SetMargins( 2, 6, 6, 6 )

nSerie  := oGraphicAux:CreateSerie(4)
If nSerie == GRP_CREATE_ERR
	Return Nil
Endif
nSerie2 := oGraphicAux:CreateSerie(4)
If nSerie2 == GRP_CREATE_ERR
	Return Nil
Endif

For mn:=1 to 12
	nTotFAno := 0
	For nAnoT := 1 to nTotAnos
		nTotFAno += aAnos[nAnoT,2,mn,1]
	Next
	oGraphicAux:Add(nSerie,nTotFAno,Strzero(mn,2),CLR_GREEN)

	nTotPAno := 0
	For nAnoT := 1 to nTotAnos
		nTotPAno += aAnos[nAnoT,2,mn,2]
	Next
	oGraphicAux:Add(nSerie2,nTotPAno,Strzero(mn,2),CLR_BLUE)
Next

oGraphicAux:SetGradient( GDBOTTOMTOP, CLR_WHITE, CLR_WHITE )
oGraphicAux:SetTitle( OemToAnsi(STR0036) , "", CLR_BLACK, A_CENTER , GRP_FOOT  )	// "Meses"
oGraphicAux:SetMargins( 2, 2, 2, 2 )
oGraphicAux:SetLegenProp( 4, CLR_YELLOW, 4, .F. )
oGraphicAux:l3D:=.F.
oGraphic:=oGraphicAux

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QNC100COR  ³ Autor ³ Aldo Marini Junior  ³ Data ³ 14/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para trazer as cores das barras do grafico        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC100COR(nTipo,nAnoT)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Numerico contendo o tipo de barra(1-FNC/2-PLANO)   ³±±
±±³          ³ ExpN2 - Numerico contendo o ano da classificacao           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QNC100COR(nTipo,nAnoT)
Local nPos  := 0
Local aCor1 := {{Year(dDataBase)-4,CLR_BLUE},;
				{Year(dDataBase)-3,CLR_GREEN},;
				{Year(dDataBase)-2,CLR_CYAN},;
				{Year(dDataBase)-1,CLR_RED},;
				{Year(dDataBase),CLR_BLACK}}

Local aCor2 := {{Year(dDataBase)-4,CLR_HBLUE},;
				{Year(dDataBase)-3,CLR_HGREEN},;
				{Year(dDataBase)-2,CLR_HCYAN},;
				{Year(dDataBase)-1,CLR_HRED},;
				{Year(dDataBase),CLR_GRAY}}

If nTipo == 1
	nPos := aScan(aCor1,{|X| X[1] == nAnoT })
	cCor := aCor1[nPos,2]
Else
	nPos := aScan(aCor2,{|X| X[1] == nAnoT })
	cCor := aCor2[nPos,2]
Endif

Return cCor

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FControlPanel³ Autor ³ Aldo Marini Junior ³ Data ³ 29/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para habilitar/desabilitar legenda do Grafico     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FControlPanel(lAtiva)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Logico contendo chave de Liga/Desliga              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FControlPanel(lAtiva)

oGroup1:lVisible:=lAtiva
oGroup2:lVisible:=lAtiva
oPanel1:lVisible:=lAtiva
oPanel2:lVisible:=lAtiva
oPanel3:lVisible:=lAtiva
oPanel4:lVisible:=lAtiva
oPanel5:lVisible:=lAtiva
oPanel6:lVisible:=lAtiva
oPanel7:lVisible:=lAtiva
oPanel8:lVisible:=lAtiva
oPanel9:lVisible:=lAtiva
oPanel10:lVisible:=lAtiva

Return Nil  
