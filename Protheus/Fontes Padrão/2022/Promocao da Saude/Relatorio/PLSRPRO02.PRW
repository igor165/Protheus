#include "PLSRPRO02.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PLSRPRO02.CH"
#include "msgraphi.ch"
#include "colors.ch"


#DEFINE RESETLIN nLinha := 550
#DEFINE	IMP_PDF 6
#DEFINE	TAM_A4 9			//A4     	210mm x 297mm  620 x 876

Static __RtStusRo02 := 	""
Static _cArqDest	:=	""
Static _cArqOrig	:=	""

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±±±±±±±±±±±±±
±±³Funcao    ³PLSRPRO02³ Autor ³Relatorio Macro Geral da Promoção 	   ³ Data ³19/09/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±±±±±±±±±±±±±
±±³Descricao ³ 					   										  					   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±±±±±±±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function PLSRPRO02(	)
Local nHeiPag		:= 2200
Local nLin			:= nHeiPag + 1
Local nX1:=0
Local aLinhas		:={}

Private cTamanho	:= "G"
Private cTitulo	:= STR0001 //"Relatorio Macro Geral da Promoção a Saúde"
Private cDesc1		:= STR0002 //"Emissao de Macro Geral da Promocao de acordo com os parametros selecionados."
Private cDesc2		:= ""
Private cDesc3		:= ""
Private cAlias		:= "BOA"
Private cPerg		:= PADR("PLRPRO02", Len(SX1->X1_GRUPO))
Private cRel		:= "PLSRPRO02"
Private nli			:= 80
Private m_pag		:= 1
Private lCompres	:= .F.
Private lDicion		:= .F.
Private lFiltro		:= .T.
Private lCrystal	:= .F.
Private aOrderns	:= {}
Private aReturn		:= { "", 1, "", 1, 1, 1, "",1 }
Private lAbortPrint	:= .F.
Private nTweb		:= 1
Private oPrn
private aHdadoR		:={}
Private cProgDe		:=""
Private cProgAte	:=""
Private cSetorDe	:=""
Private cSetorAte	:=""
Private cDataI		:=""
Private cDataF		:=""
Private cTpRel		:=""
Private cGrafi		:=""
Private nTipo 		:= 1
Private nTipG		:=5
Private cFile		:=""
Private cFileName	:= "PLSRPRO02" + criaTrab(nil,.f.)
Private cPath 		:=GetNewPar("MV_RELPROM", "C:\")  //"C:\TEMP\"//GetSrvProfString("Startpath","")
Private lSucesso	:=.F.
Private cModRel		:=0
Private oExcel		:= nil
Private AVETDES		:={}
Private oExcelApp
Private oGraphic
Private cRaizServer := If(issrvunix(), "/", "\")
Private cBmpName	:=""



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria as Perguntas aTualizadas				                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GeraSX1()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa ambiente do relatorio somente top...                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !PLSRelTop()
	Return .F.
Endif

Pergunte(cPerg,.F.)

cRel := SetPrint(	cAlias ,cRel ,cPerg ,@cTitulo ,cDesc1 ,cDesc2 ,cDesc3 ,lDicion ,aOrderns ,lCompres	,cTamanho ,{} ,lFiltro ,lCrystal)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi cancelada a operacao (padrao)                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nLastKey == 27
	Return .F.
EndIf
oExcel := FWMSEXCEL():New()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         				³
//³ mv_par01 // Programa de?                                      				³
//³ mv_par02 // Programa Ate?                                     				³
//³ mv_par03 // Setor de?                                        				³
//³ mv_par04 // Setor ate?                                        				³
//³ mv_par05 // Data inicial?                                        			³
//³ mv_par06 // Data Final ?                                      				³
//³ mv_par07 // Tipo Relatorio                                           		³
//³ mv_par08 // Grafico                                     					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cProgDe 	:=	 mv_par01
cProgAte 	:=	 mv_par02
cSetorDe 	:= 	 mv_par03
cSetorAte 	:=	 mv_par04
cDataI 		:=	 mv_par05
cDataF 		:=	 mv_par06
cTpRel 		:=	 mv_par07
cGrafi 		:=	 mv_par08  //1-Sim //2-Nao
cModRel	:=	 mv_par09  //1-Analitico/2-Sintetico
nTipo		:=	 mv_par10
cPergEnc	:=   mv_par11

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura impressora (padrao)                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetDefault(aReturn,cAlias)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Emite relat¢rio                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

PRO02Imp(nLin,nHeiPag)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera Excel do relat¢rio                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oExcel:Activate()
oExcel:GetXMLFile(cPath+cFileName + ".XLS")
MsgInfo("Arquivo Excel gerado em "+cPath+cFileName + ".XLS")

MS_FLUSH()             // Libera fila de relatorios em spool

If lSucesso .and. File(cRaizServer + cBmpName)
	Ferase(cRaizServer + cBmpName)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return()





/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ PRO02Imp  ³ Autor ³                      ³ Data ³ 05.12.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime detalhe do relatorio...                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function PRO02Imp(nLin,nHeiPag)
Local lView:=	.T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Cria obj
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

oPrn:=    FwMsPrinter():New(cFileName           ,IMP_PDF     ,.T.                  ,cPath              ,.T.                ,.F.          ,@oPrn            ,              ,.F.         ,.F.           ,.F.      ,lView      ,/*nQtdPags*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Resolução do relatorio.
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oPrn:setResolution(72)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Modo paisagem
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oPrn:setLandscape()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Papel A4
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oPrn:setPaperSize(TAM_A4)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Margem
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oPrn:setMargin(05,05,05,05)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Verifica se as configuracoes de impressora foram definidas para
//³que o objeto possa ser trabalhado.
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If  !(oPrn:IsPrinterActive())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³"Impressora"###"As configurações da impressora não foram encontradas. Por favor, verifique as configurações para utilizar este relatório. "
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	Aviso(STR0004,STR0003,{STR0005})//"As configurações da impressora não foram encontradas. Por favor, verifique as configurações para utilizar este relatório. "//"Impressora"//"OK"
	oPrn:Setup()
	Return (.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Ordena arquivos envolvidos...
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
BOA->(DbSetOrder(01))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta query de acordo com cada Relatorio...                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ("01" $ cTpRel)
	MsgRun( STR0006, '', { || nLin:=PRO02Rel01(nLin,nHeiPag) } )//'Gerando Relatorio 01, aguarde...'
	
Endif

If ("02" $ cTpRel)
	MsgRun( STR0007, '', { || nLin:=PRO02Rel02(nLin,nHeiPag) } )//'Gerando Relatorio 02, aguarde...'
	
Endif

If ("03" $ cTpRel)
	MsgRun( STR0008, '', { || nLin:=PRO02Rel03(nLin,nHeiPag) } )//'Gerando Relatorio 03, aguarde...'
	
Endif

If ("04" $ cTpRel)
	MsgRun( STR0009, '', { || nLin:=PRO02Rel04(nLin,nHeiPag) } )//'Gerando Relatorio 04, aguarde...'
	
Endif

If ("05" $ cTpRel)
	MsgRun( STR0010, '', { || nLin:=PRO02Rel05(nLin,nHeiPag) } )//'Gerando Relatorio 05, aguarde...'
	
Endif

If ("06" $ cTpRel)
	MsgRun( STR0011, '', { || nLin:=PRO02Rel07(nLin,nHeiPag) } )//'Gerando Relatorio 06, aguarde...'
	
Endif

If ("07" $ cTpRel)
	MsgRun( STR0012, '', { || nLin:=PRO02Rel08(nLin,nHeiPag) } )//'Gerando Relatorio 07, aguarde...'
	
Endif

If ("08" $ cTpRel)
	MsgRun( STR0013, '', { || nLin:=PRO02Rel09(nLin,nHeiPag) } )//'Gerando Relatorio 08, aguarde...'
	
Endif

If ("09" $ cTpRel)
	MsgRun( STR0014, '', { || nLin:=PRO02Rel10(nLin,nHeiPag) } )//'Gerando Relatorio 09, aguarde...'
	
Endif

If ("10" $ cTpRel)
	MsgRun( STR0015, '', { || nLin:=PRO02Rel11(nLin,nHeiPag) } )//'Gerando Relatorio 10, aguarde...'
	
Endif

If ("11" $ cTpRel)
	MsgRun( STR0016, '', { || nLin:=PRO02Rel12(nLin,nHeiPag) } )//'Gerando Relatorio 11, aguarde...'
	
Endif

If ("12" $ cTpRel)
	MsgRun( STR0017, '', { || nLin:=PRO02Rel13(nLin,nHeiPag) } )//'Gerando Relatorio 12, aguarde...'
	
Endif

If ("13" $ cTpRel)
	MsgRun( STR0018, '', { || nLin:=PRO02Rel14(nLin,nHeiPag) } )//'Gerando Relatorio 13, aguarde...'
	
Endif

If ("14" $ cTpRel)
	MsgRun( STR0019, '', { || nLin:=PRO02Rel15(nLin,nHeiPag) } )//'Gerando Relatorio 14, aguarde...'
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Finaliza o relatorio
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oPrn:EndPage()

oPrn:Preview()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim do Relat¢rio
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³PRO02Graf01 ³ Autor ³ Saude   ³ Data ³ 08/10/12				 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime os Relatorios		                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Static Function PRO02Graf01(aGuias,aHdadoR,nLin,nHeiPag,lnext,oGraphic,limp,cTitulo2,lCab,lImpG)
Local nCont      	:= 0
Local nLenVetDes 	:= 0
Local nj			:=0
Local cCodProg		:=""
Local cCodSetor		:=""
Local cCodPlan		:=""
Local cCodEmpre		:=""
Local nTotSet		:=1
Local nTotSetAn		:=0
Local nTotProg		:=0
Local nTotProgAn	:=0
Local nTotPlan		:=0
Local nTotPlanAn	:=0
Local nTotEmpre		:=0
Local nTotEmpreAn	:=0
Local lImpr			:=.F.
Local nX1			:=0

Private nEntreLin  	:= 30
Private nPosi		:= 0373
Private lStPag     	:= .T.
Private aVetCir		:= {}
Private oFontBody	:= TFont():New("Courier New", 09, 11,, .F.,,,,,.F.) //cTitulos dos Campos
Private oFontBody1	:= TFont():New("Arial", 15, 15,, .F.,,,,,.T.) //cTitulos dos Campos
Private oFontBody2	:= TFont():New("Arial", 09, 11,, .T.,,,,,.T.) //cTitulos dos Campos
Private oFontBody3	:= TFont():New("Arial", 09, 11,, .T.,,,,,.T.) //cTitulos dos Campos
Private nMargX   	:= 0050
Private nLenPag    	:= 2200
Private nColStart  	:= 0050
Private nColEnd    	:= 3000 - 0050

Default oGraphic	:=NIL
Default limp		:=.F.
Default cTitulo2	:=""
Default lCab		:=.F.                                          
Default	lImpG		:=.T.

ProcRegua(Len(aGuias))


AVETDES :=aclone(aGuias)

IF lnext
	If nLin >= nHeiPag
		oPrn:EndPage()
		oPrn:StartPage()
		lStPag := .F.
		nLin :=  FS_CabGraf(oPrn, nLenPag, "PLSRPRO02", 0800, cTitulo)
		nLin += nEntreLin
		oPrn:Say(nLin, nMargX+500, STR0020 + cTitulo2, oFontBody1, 100)//"Relatorio "
		nLin += nEntreLin
		oPrn:Line(nLin, nColStart, nLin,  nColEnd)
		nLin += nEntreLin
		
	EndIf
	nLin += nEntreLin

	IF lCab .and. lStPag
		nLin += nEntreLin
		oPrn:Say(nLin, nMargX+500, STR0021 + cTitulo2, oFontBody1, 100)//"Relatorio "
		nLin += nEntreLin
		oPrn:Line(nLin, nColStart, nLin,  nColEnd)
		nLin += nEntreLin
		
	Endif
	If cModRel==1
		If nLin >= nHeiPag
			nLin:=ProrCab(nLin,nHeiPag,nLenPag,cTitulo,cTitulo2)
		EndIf
		
		oPrn:Say(nLin, nMargX+0000, aHdadoR[1][3], oFontBody3, 100)
		oPrn:Say(nLin, nMargX+nPosi,aHdadoR[1][4], oFontBody3, 100)
		oPrn:Say(nLin, nMargX+0857, aHdadoR[1][5], oFontBody3, 100)
		oPrn:Say(nLin, nMargX+1070, aHdadoR[1][6], oFontBody3, 100)
		oPrn:Say(nLin, nMargX+1340, aHdadoR[1][7], oFontBody3, 100)
		oPrn:Say(nLin, nMargX+1540, aHdadoR[1][8], oFontBody3, 100)
		oPrn:Say(nLin, nMargX+1740, aHdadoR[1][9], oFontBody3, 100)
		oPrn:Say(nLin, nMargX+1950, aHdadoR[1][12], oFontBody3, 100)
		oPrn:Say(nLin, nMargX+2170, aHdadoR[1][13], oFontBody3, 100)
		oPrn:Say(nLin, nMargX+2570, aHdadoR[1][14], oFontBody3, 100)
		nLin += nEntreLin
		oPrn:Line(nLin, nColStart, nLin,  nColEnd)
	Else
		
		If nLin >= nHeiPag
			nLin:=ProrCab(nLin,nHeiPag,nLenPag,cTitulo,cTitulo2)
		EndIf
		
		oPrn:Say(nLin, nMargX+0000, aHdadoR[1][1], oFontBody3, 100)
		oPrn:Say(nLin, nMargX+nPosi, aHdadoR[1][2], oFontBody3, 100)
		oPrn:Say(nLin, nMargX+0957, aHdadoR[1][3], oFontBody3, 100)
		oPrn:Say(nLin, nMargX+1070, aHdadoR[1][4], oFontBody3, 100)
		oPrn:Say(nLin, nMargX+1440, aHdadoR[1][5], oFontBody3, 100)
		oPrn:Say(nLin, nMargX+1740, aHdadoR[1][6], oFontBody3, 100)
		oPrn:Say(nLin, nMargX+1940, aHdadoR[1][7], oFontBody3, 100)
		nLin += nEntreLin
		oPrn:Line(nLin, nColStart, nLin,  nColEnd)
	Endif
Endif

If nLin >= nHeiPag
	nLin:=ProrCab(nLin,nHeiPag,nLenPag,cTitulo,cTitulo2)
EndIf

nLin += nEntreLin
nLenVetDes := Len(aVetDes)
For nCont := 1 To nLenVetDes
	
	If nLin >= nHeiPag
		If nLin >= nHeiPag
			If !lStPag
				oPrn:EndPage()
			EndIf
			oPrn:StartPage()
			lStPag := .F.
		EndIf
		nLin :=  FS_CabGraf(oPrn, nLenPag, "PLSRPRO02", 0800, cTitulo)
		nLin += nEntreLin
		nLin += nEntreLin
		oPrn:Say(nLin, nMargX+500, STR0022 + cTitulo2, oFontBody1, 100)//"Relatorio "
		
		nLin += nEntreLin
		
		If cModRel==1
			If nLin >= nHeiPag
				nLin:=ProrCab(nLin,nHeiPag,nLenPag,cTitulo,cTitulo2)
			EndIf
			
			oPrn:Say(nLin, nMargX+0000, aHdadoR[1][3], oFontBody3, 100)
			oPrn:Say(nLin, nMargX+nPosi, aHdadoR[1][4], oFontBody3, 100)
			oPrn:Say(nLin, nMargX+0857, aHdadoR[1][5], oFontBody3, 100)
			oPrn:Say(nLin, nMargX+1070, aHdadoR[1][6], oFontBody3, 100)
			oPrn:Say(nLin, nMargX+1340, aHdadoR[1][7], oFontBody3, 100)
			oPrn:Say(nLin, nMargX+1540, aHdadoR[1][8], oFontBody3, 100)
			oPrn:Say(nLin, nMargX+1740, aHdadoR[1][9], oFontBody3, 100)
			oPrn:Say(nLin, nMargX+1950, aHdadoR[1][12], oFontBody3, 100)
			oPrn:Say(nLin, nMargX+2170, aHdadoR[1][13], oFontBody3, 100)
			oPrn:Say(nLin, nMargX+2570, aHdadoR[1][14], oFontBody3, 100)
			nLin += nEntreLin
			oPrn:Line(nLin, nColStart, nLin,  nColEnd)
			
		Else
			If nLin >= nHeiPag
				nLin:=ProrCab(nLin,nHeiPag,nLenPag,cTitulo,cTitulo2)
			EndIf
			
			
			oPrn:Say(nLin, nMargX+0000, aHdadoR[1][1], oFontBody3, 100)
			oPrn:Say(nLin, nMargX+nPosi, aHdadoR[1][2], oFontBody3, 100)
			oPrn:Say(nLin, nMargX+0957, aHdadoR[1][3], oFontBody3, 100)
			oPrn:Say(nLin, nMargX+1070, aHdadoR[1][4], oFontBody3, 100)
			oPrn:Say(nLin, nMargX+1440, aHdadoR[1][5], oFontBody3, 100)
			oPrn:Say(nLin, nMargX+1740, aHdadoR[1][6], oFontBody3, 100)
			oPrn:Say(nLin, nMargX+1940, aHdadoR[1][7], oFontBody3, 100)
			nLin += nEntreLin
			oPrn:Line(nLin, nColStart, nLin,  nColEnd)
			
		Endif
		
	Endif
	
	
	If cModRel==1
		
		If   Empty(cCodProg)
			nLin += nEntreLin
			If nLin >= nHeiPag
				nLin:=ProrCab(nLin,nHeiPag,nLenPag,cTitulo,cTitulo2)
			EndIf
			
			oPrn:Say(nLin, nMargX+0000, aHdadoR[1][1]+" -- "+iif(valtype(aVetDes[nCont, 1])=="N" ,str(aVetDes[nCont, 1]),IIF(valtype(aVetDes[nCont, 1])=="D",DTOC(aVetDes[nCont, 1]),aVetDes[nCont, 1])), oFontBody2, 100)
			nLin += nEntreLin
			oPrn:Line(nLin, nColStart, nLin,  nColEnd)
			nLin += nEntreLin
		Elseif aVetDes[nCont, 1] <> cCodProg
			nTotEmpreAn:=nTotEmpre
			nTotEmpre:=1
			nLin += nEntreLin*2
			If nLin >= nHeiPag
				nLin:=ProrCab(nLin,nHeiPag,nLenPag,cTitulo,cTitulo2)
			EndIf
			
		Endif
		
		
		If   Empty(cCodSetor)
			nLin += nEntreLin
			If nLin >= nHeiPag
				nLin:=ProrCab(nLin,nHeiPag,nLenPag,cTitulo,cTitulo2)
			EndIf
			
			oPrn:Say(nLin, nMargX+0100, aHdadoR[1][2]+" -- "+iif(valtype(aVetDes[nCont, 2])=="N",str(aVetDes[nCont, 2]),IIF(valtype(aVetDes[nCont, 2])=="D",DTOC(aVetDes[nCont, 2]),aVetDes[nCont, 2])) , oFontBody2, 100)
			nLin += nEntreLin
			oPrn:Line(nLin, nColStart, nLin,  nColEnd)
			nLin += nEntreLin
		Elseif aVetDes[nCont, 1] <> cCodProg
			nTotPlanAn:=nTotPlan
			nTotPlan:=1
			nLin += nEntreLin
			If nLin >= nHeiPag
				nLin:=ProrCab(nLin,nHeiPag,nLenPag,cTitulo,cTitulo2)
			EndIf
			
			oPrn:Say(nLin, nMargX+0300,STR0024+alltrim(cCodplan)+ str(nTotPlanAn), oFontBody2, 100)//"Total Plano ==> "
			nLin += nEntreLin
			oPrn:Line(nLin, nColStart, nLin,  nColEnd)
			nLin += nEntreLin
			nTotPlan:=0
			nTotPlanAn:=0
		Endif
		
		
		If   Empty(cCodEmpre)
			nLin += nEntreLin
			If nLin >= nHeiPag
				nLin:=ProrCab(nLin,nHeiPag,nLenPag,cTitulo,cTitulo2)
			EndIf
			
			oPrn:Say(nLin, nMargX+0200, aHdadoR[1][11]+" --  "+iif(valtype(aVetDes[nCont, 11])=="N",str(aVetDes[nCont, 11]),IIF(valtype(aVetDes[nCont, 11])=="D",DTOC(aVetDes[nCont, 11]),aVetDes[nCont, 11])), oFontBody2, 100)
			nLin += nEntreLin
			oPrn:Line(nLin, nColStart, nLin,  nColEnd)
			nLin += nEntreLin
		Elseif aVetDes[nCont, 1] <> cCodProg
			nLin += nEntreLin
			nTotProgAn:=nTotProg
			nTotProg:=1
			If nLin >= nHeiPag
				nLin:=ProrCab(nLin,nHeiPag,nLenPag,cTitulo,cTitulo2)
			EndIf

			oPrn:Say(nLin, nMargX+0200,STR0023+alltrim(cCodEmpre)+ str(nTotEmpreAn), oFontBody2, 100)//"Total Empresa ==> "
			nLin += nEntreLin
			oPrn:Line(nLin, nColStart, nLin,  nColEnd)
			nLin += nEntreLin
			nTotEmpreAn:=0
			nTotEmpre:=0   
			
		Endif
	
		
		If   Empty(cCodplan)
			nLin += nEntreLin
			If nLin >= nHeiPag
				nLin:=ProrCab(nLin,nHeiPag,nLenPag,cTitulo,cTitulo2)
			EndIf
			oPrn:Say(nLin, nMargX+0300, aHdadoR[1][10]+" -- "+iif(valtype(aVetDes[nCont, 10])=="N",str(aVetDes[nCont, 10]),IIF(valtype(aVetDes[nCont, 10])=="D",DTOC(aVetDes[nCont, 10]),aVetDes[nCont, 10])), oFontBody2, 100)
			nLin += nEntreLin
			oPrn:Line(nLin, nColStart, nLin,  nColEnd)
			nLin += nEntreLin
		Elseif aVetDes[nCont, 1] <> cCodProg
			nTotSetAn:=nTotSet
			nTotSet:=1
			nLin += nEntreLin
			If nLin >= nHeiPag
				nLin:=ProrCab(nLin,nHeiPag,nLenPag,cTitulo,cTitulo2)
			EndIf
			
			oPrn:Say(nLin, nMargX+0100,STR0025+alltrim(cCodSetor)+ str(nTotSetAn), oFontBody2, 100)//"Total  Setor ==> "
			nLin += nEntreLin
			oPrn:Line(nLin, nColStart, nLin,  nColEnd)
			nLin += nEntreLin
			nTotSetAn:=0
			nTotSet:=0
		Endif


		If aVetDes[nCont, 1] <> cCodProg .and.  !Empty(cCodProg)
			cCodProg:=aVetDes[nCont, 1]
			lImpr:=.T.
			nTotProg:=0
			cCodSetor:=aVetDes[nCont, 2]
			nTotSet:=0
			cCodPlan:=aVetDes[nCont, 10]
			nTotPlan:=0
			cCodEmpre:=aVetDes[nCont, 11]
			nTotEmpre:=0
			nLin += nEntreLin
			If nLin >= nHeiPag
				nLin:=ProrCab(nLin,nHeiPag,nLenPag,cTitulo,cTitulo2)
			EndIf
			
			oPrn:Say(nLin, nMargX+0000,STR0026+alltrim(cCodProg)+ str(nTotProgAn), oFontBody2, 100)//"Total  Programa ==> "
			nLin += nEntreLin
			oPrn:Line(nLin, nColStart, nLin,  nColEnd)
			nLin += nEntreLin
			nTotProgAn:=0
			
			oPrn:Say(nLin, nMargX+0000, aHdadoR[1][1]+" -- "+iif(valtype(aVetDes[nCont, 1])=="N" ,str(aVetDes[nCont, 1]),IIF(valtype(aVetDes[nCont, 1])=="D",DTOC(aVetDes[nCont, 1]),aVetDes[nCont, 1])), oFontBody2, 100)
			nLin += nEntreLin
			oPrn:Line(nLin, nColStart, nLin,  nColEnd)
			nLin += nEntreLin
			If nLin >= nHeiPag
				nLin:=ProrCab(nLin,nHeiPag,nLenPag,cTitulo,cTitulo2)
			EndIf
			
			oPrn:Say(nLin, nMargX+0100, aHdadoR[1][2]+" -- "+iif(valtype(aVetDes[nCont, 2])=="N",str(aVetDes[nCont, 2]),IIF(valtype(aVetDes[nCont, 2])=="D",DTOC(aVetDes[nCont, 2]),aVetDes[nCont, 2])) , oFontBody2, 100)
			nLin += nEntreLin
			oPrn:Line(nLin, nColStart, nLin,  nColEnd)
			nLin += nEntreLin
			If nLin >= nHeiPag
				nLin:=ProrCab(nLin,nHeiPag,nLenPag,cTitulo,cTitulo2)
			EndIf

			oPrn:Say(nLin, nMargX+0200, aHdadoR[1][11]+" --  "+iif(valtype(aVetDes[nCont, 11])=="N",str(aVetDes[nCont, 11]),IIF(valtype(aVetDes[nCont, 11])=="D",DTOC(aVetDes[nCont, 11]),aVetDes[nCont, 11])), oFontBody2, 100)
			nLin += nEntreLin
			oPrn:Line(nLin, nColStart, nLin,  nColEnd)
			nLin += nEntreLin
			
			If nLin >= nHeiPag
				nLin:=ProrCab(nLin,nHeiPag,nLenPag,cTitulo,cTitulo2)
			EndIf
			oPrn:Say(nLin, nMargX+0300, aHdadoR[1][10]+" -- "+iif(valtype(aVetDes[nCont, 10])=="N",str(aVetDes[nCont, 10]),IIF(valtype(aVetDes[nCont, 10])=="D",DTOC(aVetDes[nCont, 10]),aVetDes[nCont, 10])), oFontBody2, 100)
			nLin += nEntreLin
			oPrn:Line(nLin, nColStart, nLin,  nColEnd)
			nLin += nEntreLin
			
		Endif
		
		IF  (aVetDes[nCont, 1] ==cCodProg .AND. aVetDes[nCont, 10] <>cCodplan ) //.or. aVetDes[nCont, 1] <>cCodProg
			nTotPlanAn:=nTotPlan
			nTotPlan:=1
			
			If !Empty(cCodplan)
				nLin += nEntreLin
				nLin += nEntreLin
				If nLin >= nHeiPag
					nLin:=ProrCab(nLin , nHeiPag,nLenPag,cTitulo,cTitulo2)
				EndIf
				
				oPrn:Say(nLin, nMargX+0300,STR0024+alltrim(cCodplan)+ str(nTotPlanAn), oFontBody2, 100)//"Total Plano ==> "
				nLin += nEntreLin
				oPrn:Line(nLin, nColStart, nLin,  nColEnd)
				nLin += nEntreLin
				
			Endif
		Endif
		
		
		IF aVetDes[nCont, 1] ==cCodProg  .and. aVetDes[nCont, 11] <>cCodEmpre // .or. aVetDes[nCont, 1] <> cCodProg
			nTotEmpreAn:=nTotEmpre
			nTotEmpre:=1
			If !Empty(cCodEmpre)
				nLin += nEntreLin
				nLin += nEntreLin*2
				If nLin >= nHeiPag
					nLin:=ProrCab(nLin,nHeiPag,nLenPag,cTitulo,cTitulo2)
				EndIf
				
				oPrn:Say(nLin, nMargX+0200,STR0023+alltrim(cCodEmpre)+ str(nTotEmpreAn), oFontBody2, 100)//"Total Empresa ==> "
				nLin += nEntreLin
				oPrn:Line(nLin, nColStart, nLin,  nColEnd)
				nLin += nEntreLin
				nTotEmpreAn:=0
			Endif
			
			nLin += nEntreLin
			nLin += nEntreLin
			If nLin >= nHeiPag
				nLin:=ProrCab(nLin,nHeiPag,nLenPag,cTitulo,cTitulo2)
			EndIf

			nLin += nEntreLin
			nLin += nEntreLin
			If nLin >= nHeiPag
				nLin:=ProrCab(nLin,nHeiPag,nLenPag,cTitulo,cTitulo2)
			EndIf
			
			IF  (aVetDes[nCont, 1] ==cCodProg  .AND. aVetDes[nCont, 11] <>cCodEmpre ) 	
			oPrn:Say(nLin, nMargX+0200, aHdadoR[1][11]+" -- "+iif(valtype(aVetDes[nCont, 11])=="N",str(aVetDes[nCont, 11]),IIF(valtype(aVetDes[nCont, 11])=="D",DTOC(aVetDes[nCont, 11]),aVetDes[nCont, 11])), oFontBody2, 100)
			nLin += nEntreLin
			oPrn:Line(nLin, nColStart, nLin,  nColEnd)
			nLin += nEntreLin
			Endif
			
			
			IF  (aVetDes[nCont, 1] ==cCodProg  .AND. aVetDes[nCont, 10] <>cCodPlan)
			oPrn:Say(nLin, nMargX+0300, aHdadoR[1][10]+" -- "+iif(valtype(aVetDes[nCont, 10])=="N",str(aVetDes[nCont, 10]),IIF(valtype(aVetDes[nCont, 10])=="D",DTOC(aVetDes[nCont, 10]),aVetDes[nCont, 10])), oFontBody2, 100)
			nLin += nEntreLin
			oPrn:Line(nLin, nColStart, nLin,  nColEnd)
			nLin += nEntreLin

			Endif
			
		Endif
		
	
		nLin += nEntreLin
		IF  (aVetDes[nCont, 1] ==cCodProg  .AND. aVetDes[nCont, 2] <>cCodSetor )  //.or. aVetDes[nCont, 1] <>cCodProg
			nTotSetAn:=nTotSet
			nTotSet:=1
			If !Empty(cCodSetor)
				nLin += nEntreLin
				nLin += nEntreLin
				If nLin >= nHeiPag
					nLin:=ProrCab(nLin,nHeiPag,nLenPag,cTitulo,cTitulo2)
				EndIf
				
				oPrn:Say(nLin, nMargX+0100,STR0025+alltrim(cCodSetor)+ str(nTotSetAn), oFontBody2, 100)//"Total  Setor ==> "
				nLin += nEntreLin
				oPrn:Line(nLin, nColStart, nLin,  nColEnd)
				nLin += nEntreLin
			Endif
			nLin += nEntreLin
			nLin += nEntreLin
			If nLin >= nHeiPag
				nLin:=ProrCab(nLin,nHeiPag,nLenPag,cTitulo,cTitulo2)
			EndIf
			
			oPrn:Say(nLin, nMargX+0100, aHdadoR[1][2]+" -- "+iif(valtype(aVetDes[nCont, 2])=="N",str(aVetDes[nCont, 2]),IIF(valtype(aVetDes[nCont, 2])=="D",DTOC(aVetDes[nCont, 2]),aVetDes[nCont, 2])) , oFontBody2, 100)
			nLin += nEntreLin
			oPrn:Line(nLin, nColStart, nLin,  nColEnd)
			nLin += nEntreLin
		Endif
		
	Endif
	nLin += nEntreLin
	If cModRel==1
		If nLin >= nHeiPag
			nLin:=ProrCab(nLin , nHeiPag,nLenPag,cTitulo,cTitulo2)
		EndIf
		
		oPrn:Say(nLin, nMargX+0000,iif(valtype(aVetDes[nCont, 3])=="N" ,str(aVetDes[nCont, 3]),IIF(valtype(aVetDes[nCont, 3])=="D",DTOC(aVetDes[nCont, 3]),alltrim(aVetDes[nCont, 3]))),   oFontBody, 100)
		oPrn:Say(nLin, nMargX+nPosi,iif(valtype(aVetDes[nCont, 4])=="N" ,str(aVetDes[nCont, 4]),IIF(valtype(aVetDes[nCont, 4])=="D",DTOC(aVetDes[nCont, 4]),alltrim(aVetDes[nCont, 4]))),   oFontBody, 100)
		oPrn:Say(nLin, nMargX+0857,iif(valtype(aVetDes[nCont, 5])=="N" ,str(aVetDes[nCont, 5]),IIF(valtype(aVetDes[nCont, 5])=="D",DTOC(aVetDes[nCont, 5]),alltrim(aVetDes[nCont, 5]))),   oFontBody, 100)
		oPrn:Say(nLin, nMargX+1070,iif(valtype(aVetDes[nCont, 6])=="N" ,str(aVetDes[nCont, 6]),IIF(valtype(aVetDes[nCont, 6])=="D",DTOC(aVetDes[nCont, 6]),alltrim(aVetDes[nCont, 6]))),   oFontBody, 100)
		oPrn:Say(nLin, nMargX+1340,iif(valtype(aVetDes[nCont, 7])=="N" ,str(aVetDes[nCont, 7]),IIF(valtype(aVetDes[nCont, 7])=="D",DTOC(aVetDes[nCont, 7]),alltrim(aVetDes[nCont, 7]))),   oFontBody, 100)
		oPrn:Say(nLin, nMargX+1540,iif(valtype(aVetDes[nCont, 8])=="N" ,str(aVetDes[nCont, 8]),IIF(valtype(aVetDes[nCont, 8])=="D",DTOC(aVetDes[nCont, 8]),alltrim(aVetDes[nCont, 8]))),   oFontBody, 100)
		oPrn:Say(nLin, nMargX+1740,iif(valtype(aVetDes[nCont, 9])=="N" ,str(aVetDes[nCont, 9]),IIF(valtype(aVetDes[nCont, 9])=="D",DTOC(aVetDes[nCont, 9]),alltrim(aVetDes[nCont, 9]))),   oFontBody, 100)
		oPrn:Say(nLin, nMargX+1950,iif(valtype(aVetDes[nCont, 12])=="N" ,str(aVetDes[nCont, 12]),IIF(valtype(aVetDes[nCont, 12])=="D",DTOC(aVetDes[nCont, 12]),alltrim(aVetDes[nCont, 12]))),   oFontBody, 100)
		oPrn:Say(nLin, nMargX+2170,iif(valtype(aVetDes[nCont, 13])=="N" ,str(aVetDes[nCont, 13]),IIF(valtype(aVetDes[nCont, 13])=="D",DTOC(aVetDes[nCont, 13]),alltrim(aVetDes[nCont, 13]))),   oFontBody, 100)
		oPrn:Say(nLin, nMargX+2570,iif(valtype(aVetDes[nCont, 14])=="N" ,str(aVetDes[nCont, 14]),IIF(valtype(aVetDes[nCont, 14])=="D",DTOC(aVetDes[nCont, 14]),alltrim(aVetDes[nCont, 14]))),   oFontBody, 100)		

	Else
		If nLin >= nHeiPag
			nLin:=ProrCab(nLin , nHeiPag,nLenPag,cTitulo,cTitulo2)
		EndIf
		
		oPrn:Say(nLin, nMargX+0000,iif(valtype(aVetDes[nCont, 1])=="N" ,str(aVetDes[nCont, 1]),IIF(valtype(aVetDes[nCont, 1])=="D",DTOC(aVetDes[nCont, 1]),substr(aVetDes[nCont, 1],1,20))),   oFontBody, 100)
		oPrn:Say(nLin, nMargX+nPosi,iif(valtype(aVetDes[nCont, 2])=="N" ,str(aVetDes[nCont, 2]),IIF(valtype(aVetDes[nCont, 2])=="D",DTOC(aVetDes[nCont, 2]),aVetDes[nCont, 2])),   oFontBody, 100)
		oPrn:Say(nLin, nMargX+0857,iif(valtype(aVetDes[nCont, 3])=="N" ,str(aVetDes[nCont, 3]),IIF(valtype(aVetDes[nCont, 3])=="D",DTOC(aVetDes[nCont, 3]),aVetDes[nCont, 3])),   oFontBody, 100)
		oPrn:Say(nLin, nMargX+1070,iif(valtype(aVetDes[nCont, 4])=="N" ,str(aVetDes[nCont, 4]),IIF(valtype(aVetDes[nCont, 4])=="D",DTOC(aVetDes[nCont, 4]),aVetDes[nCont, 4])),   oFontBody, 100)
		oPrn:Say(nLin, nMargX+1440,iif(valtype(aVetDes[nCont, 5])=="N" ,str(aVetDes[nCont, 5]),IIF(valtype(aVetDes[nCont, 5])=="D",DTOC(aVetDes[nCont, 5]),aVetDes[nCont, 5])),   oFontBody, 100)
		oPrn:Say(nLin, nMargX+1740,iif(valtype(aVetDes[nCont, 6])=="N" ,str(aVetDes[nCont, 6]),IIF(valtype(aVetDes[nCont, 6])=="D",DTOC(aVetDes[nCont, 6]),aVetDes[nCont, 6])),   oFontBody, 100)
		oPrn:Say(nLin, nMargX+1940,iif(valtype(aVetDes[nCont, 7])=="N" ,str(aVetDes[nCont, 7]),IIF(valtype(aVetDes[nCont, 7])=="D",DTOC(aVetDes[nCont, 7]),aVetDes[nCont, 7])),   oFontBody, 100)
		
	Endif
	
	IF aVetDes[nCont, 1] ==cCodProg  .and.  nCont <= nLenVetDes
		nTotProg++
		lImpr:=.F.
	Else
		If   Empty(cCodProg)
			lImpr:=.F.
		Endif
		cCodProg:=aVetDes[nCont, 1]
		lImpr:=.T.
		nTotProg:=1
	
	Endif
	
	IF aVetDes[nCont, 1] ==cCodProg .AND. aVetDes[nCont, 2] ==cCodSetor .and.nCont <= nLenVetDes
		nTotSet++
	Else
		cCodSetor:=aVetDes[nCont, 2]
		nTotSet:=1
	Endif
	
	IF  aVetDes[nCont, 1] ==cCodProg .AND. aVetDes[nCont, 10] ==cCodPlan .and. nCont <= nLenVetDes
		nTotPlan++
	Else
		cCodPlan:=aVetDes[nCont, 10]
		nTotPlan:=1
	Endif
	
	IF aVetDes[nCont, 1] ==cCodProg .AND. aVetDes[nCont, 11] ==cCodEmpre .and. nCont <= nLenVetDes
		nTotEmpre++
	Else
		cCodEmpre:=aVetDes[nCont, 11]
		nTotEmpre:=1
	Endif
	
Next


If cModRel==1

	nLin += nEntreLin
	If nLin >= nHeiPag
		nLin:=ProrCab(nLin , nHeiPag,nLenPag,cTitulo,cTitulo2)
	EndIf
	
	oPrn:Say(nLin, nMargX+0300,STR0024+alltrim(cCodPlan)+ str(nTotPlan), oFontBody2, 100)//"Total do Plano ==> "
	nLin += nEntreLin
	oPrn:Line(nLin, nColStart, nLin,  nColEnd)
	nLin += nEntreLin
	nLin += nEntreLin
	If nLin >= nHeiPag
		nLin:=ProrCab(nLin , nHeiPag,nLenPag,cTitulo,cTitulo2)
	EndIf

	nLin += nEntreLin
	nLin += nEntreLin
	If nLin >= nHeiPag
		nLin:=ProrCab(nLin , nHeiPag,nLenPag,cTitulo,cTitulo2)
	EndIf

	oPrn:Say(nLin, nMargX+0200,STR0023+alltrim(cCodEmpre)+ str(nTotEmpre), oFontBody2, 100)//"Total da Empresa ==> "
	nLin += nEntreLin
	oPrn:Line(nLin, nColStart, nLin,  nColEnd)
	nLin += nEntreLin
	
	
	oPrn:Say(nLin, nMargX+0100,STR0025+alltrim(cCodSetor)+ str(nTotSet), oFontBody2, 100)//"Total do Setor ==> "
	nLin += nEntreLin
	oPrn:Line(nLin, nColStart, nLin,  nColEnd)
	nLin += nEntreLin
	nLin += nEntreLin
	If nLin >= nHeiPag
		nLin:=ProrCab(nLin , nHeiPag,nLenPag,cTitulo,cTitulo2)
	EndIf
	
	oPrn:Say(nLin, nMargX+0000,STR0026+alltrim(cCodProg)+ str(nTotProg), oFontBody2, 100)//"Total do Programa ==> "
	nLin += nEntreLin
	oPrn:Line(nLin, nColStart, nLin,  nColEnd)
	nLin += nEntreLin
	nTotSet:=1
	nTotPlan:=1
	nTotEmpre:=1
	nTotProg:=1
	
	nTotSetAn:=1
	nTotPlanAn:=1
	nTotEmpreAn:=1
	nTotProgAn:=1
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Imprime Grafico...
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If cGrafi ==1 .and. cModRel==2 .and. lImpG
	nLin += nEntreLin*2
	If nLin >= nHeiPag
		If !lStPag
			oPrn:EndPage()
		EndIf
		oPrn:StartPage()
		lStPag := .F.
	EndIf
	//             linha  colu     tam  largura

	nLin += nEntreLin*4
	oPrn:Saybitmap(nLin,0000,cRaizServer + cBmpName,1800,1000)
	nLin += nHeiPag+1
	
Endif

If len(aVetDes) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Define titulo da planilha...
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oExcel:AddworkSheet(cTitulo2)
	oExcel:AddTable (cTitulo2,cTitulo2)
	
	For nX1 := 1 To Len(aHdadoR[1])
		oExcel:AddColumn(cTitulo2,cTitulo2,aHdadoR[1][nX1],1,/*iif(substr(aHdadoR[1][nX1],1,1)==Upper("d"),4,1)*/1,.F.)
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Dados
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	For nX1 := 1 To Len(aVetDes)
		oExcel:AddRow(cTitulo2,cTitulo2,aVetDes[nX1])
	Next
	
EndIf

Return (nLin)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PRO02Rel01 ºAutor  ³Saude           º Data ³  12/17/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ações Consolidadas (Nº Participantes)                       º±±
±±º          ³da Promoção da Saúde por Período                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Static Function PRO02Rel01(nLin,nHeiPag)
Local cFiltro		:=""
Local aDados		:={}
Local n				:=1
Local cArq			:= "PRO02" + CriaTrab(NIL,.F.) + ".JPEG"
Local cTitulo2		:=STR0034//"Ações Consolidadas (Nº Participantes) da Promoção da Saúde por Período"
Local lCab			:=.T.
Local cProgram		:=""
Local nTotal		:=0
Local nAcumul		:=0
Local nMeta		:=""
Local cPrograp		:=""
Local nj,ni		:=0
Local aDados1		:={}
Local cMatvi		:=""
Local cGraf		:="Rel01"


If cModRel==1
	cFiltro := " SELECT DISTINCT BOA.BOA_CODPRO,BOA.BOA_DESPRO, BD1.BD1_CODLOC,BD1.BD1_DESLOC,"
	If AllTrim(TCGetDB()) $  "MSSQL"
		cFiltro += "BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO CARTEIRA,"
	Else
		cFiltro += "BA1_CODINT||BA1_CODEMP||BA1_MATRIC||BA1_TIPREG||BA1_DIGITO CARTEIRA,"
	Endif
	cFiltro += "BOM.BOM_VIDA,BOM.BOM_NOME,BA1.BA1_DATNAS,BOM.BOM_DTELEG,BA1.BA1_CODINT,BA1.BA1_CODEMP,BA1.BA1_CONEMP,BA1.BA1_VERCON,BA1.BA1_SUBCON,BA1.BA1_VERSUB,"
	cFiltro += "BOM.BOM_DTINSC,BOM.BOM_DATALT,BOM.BOM_MEDRSP,BI3.BI3_CODIGO,BI3.BI3_DESCRI,BA1.BA1_CODEMP,BOM_GRARIS  "
Else
	cFiltro := " SELECT BOA.BOA_CODPRO,BOA.BOA_DESPRO, BD1.BD1_CODLOC,BD1.BD1_DESLOC, "
	cFiltro += "  	COUNT(BOM.BOM_VIDA) QTDVIDA ,BOA.BOA_META,(BOA.BOA_META/COUNT(BOM.BOM_VIDA))  PERCET "
Endif

cFiltro += "  FROM "+RetSqlName("BOA")+ " BOA "
cFiltro += "  INNER JOIN "+RetSqlName("BOM")+" BOM ON BOA.BOA_CODPRO = BOM.BOM_CODPRO AND BOM.BOM_FILIAL = '" + xFilial("BOM") + "'   AND BOM.D_E_L_E_T_ = ' ' "
If cModRel==1
	cFiltro +=Rpro02Sql()
Endif

cFiltro += "  LEFT JOIN  "+RetSqlName("BD1")+" BD1 ON BOM.BOM_CODLOC = BD1.BD1_CODLOC  AND BD1.BD1_FILIAL = '" + xFilial("BD1") + "' AND BD1.D_E_L_E_T_ = ' '"
cFiltro +=	" 	WHERE  BOA.BOA_FILIAL = '" + xFilial("BOA") + "'  "
cFiltro +=	" 	AND BOM.BOM_DTINSC >= '"+DTOS(cDataI) +"'	  AND BOM.BOM_DTINSC <= '"+DTOS(cDataF)+"' "

If !Empty(cProgAte)
	cFiltro +=	" 	AND BOA.BOA_CODPRO >= '"+cProgDe+"' AND BOA.BOA_CODPRO <= '"+cProgAte+"'	 "
Endif

If  !Empty(cSetorAte)
	cFiltro +=" 	AND BOM.BOM_CODLOC >= '"+cSetorDe+"' AND BOM.BOM_CODLOC <= '"+cSetorAte+"'	 "
Endif
cFiltro +=	" 	AND BOM.BOM_STATUS  IN  ( '2','1','4','3') "
cFiltro +=	" 	AND BOA.D_E_L_E_T_ = ' '	"
cFiltro +=	" 	AND BOA.BOA_ATIVO = '1' "

If cModRel==2
	cFiltro +=" GROUP BY BOA.BOA_CODPRO,BOA.BOA_DESPRO,  BD1.BD1_CODLOC,BD1.BD1_DESLOC,"
	cFiltro +=" BOA.BOA_META"
	cFiltro +=" ORDER BY BOA.BOA_CODPRO,"
	cFiltro +=" BD1.BD1_CODLOC"
Else
	cFiltro +=" ORDER BY BOM.BOM_VIDA,BOA.BOA_CODPRO,"
	cFiltro += " BD1.BD1_CODLOC,BI3.BI3_CODIGO,BA1.BA1_CODEMP"
Endif

cFiltro	:= ChangeQuery(cFiltro)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cFiltro),"TRB1",.T.,.F.)

DbSelectArea("TRB1")

If Eof()
	TRB1->( dbCloseArea() )
	return(nLin)
endif


TRB1->( dbGotop() )

While !TRB1->(Eof())
	If cModRel ==1 .and. (cMatvi<>TRB1->BOM_VIDA .or. (cMatvi==TRB1->BOM_VIDA .and. cProgram<>TRB1->BOA_CODPRO))
		Aadd(aDados, { TRB1->BOA_CODPRO+"-"+TRB1->BOA_DESPRO, TRB1->BD1_CODLOC+"-"+TRB1->BD1_DESLOC,TRB1->CARTEIRA,TRB1->BOM_VIDA+"-"+Substr(TRB1->BOM_NOME,1,20),HS_A58Age(stod(TRB1->BA1_DATNAS)),IIF(!EMPTY(TRB1->BOM_DTELEG),stod(BOM_DTELEG),""),iiF(!Empty(TRB1->BOM_DTINSC), stod(TRB1->BOM_DTINSC),""),iiF(!Empty(TRB1->BOM_DATALT),stod(TRB1->BOM_DATALT),""),TRB1->BOM_MEDRSP+"-"+Substr(HS_IniPadr('SRA', 11, TRB1->BOM_MEDRSP, 'RA_NOME'),1,15),TRB1->BI3_CODIGO+"-"+TRB1->BI3_DESCRI,TRB1->BA1_CODEMP+"-"+Pro02BusEm("TRB1"),"",TRB1->BOM_GRARIS+'-'+Posicione('BOB',2,xFilial('BOB')+TRB1->BOM_GRARIS+TRB1->BOA_CODPRO,'BOB_RISCO'),""})
	ElseIf cModRel==2
		Aadd(aDados, { TRB1->BOA_CODPRO+'-'+SUBSTR(TRB1->BOA_DESPRO,1,40),TRB1->BD1_CODLOC+'-'+SUBSTR(TRB1->BD1_DESLOC,1,40) ,"",TRB1->QTDVIDA, TRB1->BOA_META, NOROUND(TRB1->PERCET,2),"","","","","","","","" })
		
	Endif
	cProgram:=TRB1->BOA_CODPRO
	
	If cModRel ==1
		cMatvi:=TRB1->BOM_VIDA
	Endif
	
	TRB1->(DbSkip())
	
	
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da Função para montar a Serie do Grafico     ³
//³ aDados : array com as informaçoes do Select 			³
//³	Posicao:Exemplo 5, onde está o Valor a ser exibido	³
//³	na Serie Neste caso a Coluna QTDVIDA					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cModRel==2
	Pro02SetGr(aDados,5,cGraf)
Endif

TRB1->( dbCloseArea() )
aHdador:={}

If cModRel ==1
	Aadd(aHdadoR, { STR0044, STR0045,STR0040,STR0041,STR0039,STR0037,STR0036,STR0035,STR0043,STR0042,STR0038," " ,"Risco","" })//"Dat.Alta."//"Dat.Insc."//"Dt.Elegibilidade."//"Empresa"//"Idade"//"Matricula"//"Nome"//"Plano"//"Prof. Saude"//"Programa"//"Setor"
Else
	
	Aadd(aHdadoR, { STR0048,STR0050 ,"",STR0046, STR0047, STR0049,"","","","","","","",""  }) //"Acumulado"//"Meta"//"Programa"//"Realizado por Meta"//"Setor"
Endif



/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Ordena  pela Programa + Setor                                   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If cModRel==2
	aSort( aDados,,,{ |x,y|  x[01]+x[03]  <  y[01]+y[03] } )
Else
	aSort( aDados,,,{ |x,y|  x[01]+x[02]+ x[11] +x[10]  <  y[01]+y[02]+ y[11]+ y[10] } )
Endif
    
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Chama a Impressão do Relatorio                                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nLin:=PRO02Graf01(aDados,aHdadoR,nLin,nHeiPag,.t.,oGraphic,.F.,cTitulo2,.F.)

Return(nLin)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PRO02Rel02 ºAutor  ³Saude           º Data ³  12/13/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Palestras Promoção da Saúde por Período                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PRO02Rel02(nLin,nHeiPag)

Local cFiltro	:=""
Local aDados	:={}
Local n			:=1
Local cTitulo2	:=STR0051//"Palestras Promoção da Saúde por Período"
Local cProgram	:=""
Local cMatvi	:=""
Local cGraf		:="Rel02"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selects ...             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cFiltro := "SELECT "
If cModRel==1
	cFiltro := " SELECT DISTINCT BOA_CODPRO,BOA_DESPRO, ACD_LOCAL,UW_CODEVE, UW_DESCEVE, "
	
	If AllTrim(TCGetDB()) $  "MSSQL"
		cFiltro += "BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO CARTEIRA,"
	Else
		cFiltro += "BA1_CODINT||BA1_CODEMP||BA1_MATRIC||BA1_TIPREG||BA1_DIGITO CARTEIRA,"
	Endif
	
	cFiltro += "BOM_VIDA,BOM_NOME,BA1_DATNAS,BOM_DTELEG,"
	
	
	cFiltro += "BOM_DTINSC,BOM_DATALT,ACE_DATA,BOM_MEDRSP,BI3_CODIGO,BI3_DESCRI,BA1_CODINT,BA1_CODEMP,BA1_CONEMP,BA1_VERCON,BA1_SUBCON,BA1_VERSUB,BOM_GRARIS  "
	
Else
	
	cFiltro += "BOA_CODPRO,BOA_DESPRO, UW_CODEVE, UW_DESCEVE,  ACD_LOCAL,ACE_DATA,COUNT(DISTINCT(ACE_GRADE)) PALESTRAS,COUNT(DISTINCT(AG5_CODCO)) PARTICIP "
Endif

cFiltro += "	FROM "
cFiltro += 		RetSQLName("AG5")
cFiltro += "			INNER JOIN "+RetSQLName("BA1")+"  ON "
cFiltro += "				BA1_FILIAL = '"+xFilial("BA1")+"' AND "

If AllTrim(TCGetDB()) $  "MSSQL"
	cFiltro += "				BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPUSU+BA1_TIPREG+BA1_DIGITO = AG5_CODEN OR "
	cFiltro += "				BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO = AG5_CODEN AND "
Else
	
	cFiltro += "				BA1_CODINT||BA1_CODEMP||BA1_MATRIC||BA1_TIPUSU||BA1_TIPREG||BA1_DIGITO = AG5_CODEN OR "
	cFiltro += "				BA1_CODINT||BA1_CODEMP||BA1_MATRIC||BA1_TIPREG||BA1_DIGITO = AG5_CODEN AND "
	
Endif
cFiltro += "				BA1_DATBLO = ' ' AND  "
cFiltro +=  				RetSQLName("BA1")+".D_E_L_E_T_ = ' ' "
cFiltro += " 			INNER JOIN "+RetSqlName("BA3")+"   ON BA3_CODINT = BA1_CODINT AND BA3_CODEMP = BA1_CODEMP AND BA3_MATRIC = BA1_MATRIC  AND BA3_FILIAL = '" + xFilial("BA3") + "' AND "
cFiltro +=  				RetSQLName("BA3")+".D_E_L_E_T_ = ' ' "
cFiltro += "  			INNER JOIN "+RetSqlName("BI3")+"   ON BA3_CODINT = BI3_CODINT AND BA3_CODPLA = BI3_CODIGO AND "
cFiltro +="	  		   BI3_FILIAL = '" + xFilial("BI3") + "'    AND "
cFiltro +=  				RetSQLName("BI3")+".D_E_L_E_T_ = ' ' "

cFiltro += "			INNER JOIN "+RetSQLName("ACE")+" ON "
cFiltro += "				ACE_FILIAL = '"+xFilial("ACE")+"' AND "
cFiltro += "				ACE_CODIGO = AG5_EVENT AND "
cFiltro += "				ACE_GRADE  = AG5_GRADE AND "
cFiltro += "				ACE_DATA   >= '"+DTOS(cDataI)+"' AND "
cFiltro += "				ACE_DATA   <= '"+DTOS(cDataF)+"' AND "
cFiltro +=  				RetSQLName("ACE")+".D_E_L_E_T_ = ' ' "
cFiltro += "			INNER JOIN "+RetSQLName("ACD")+" ON "
cFiltro += "				ACD_FILIAL = '"+xFilial("ACD")+"' AND "
cFiltro += "				ACD_CODIGO = ACE_CODIGO AND "
cFiltro += 				RetSQLName("ACD")+".D_E_L_E_T_ = ' ' "
cFiltro += "			INNER JOIN "+RetSQLName("BOM")+"  ON "
cFiltro += "				BOM_FILIAL = '"+xFilial("BOM")+"' AND "
cFiltro += "				BOM_VIDA = BA1_MATVID AND "
cFiltro +=	" 				BOM_STATUS  IN  ( '2','1','4','3') AND  "
cFiltro += 				RetSQLName("BOM")+".D_E_L_E_T_ = ' ' "
cFiltro += "			INNER JOIN "+RetSQLName("BOG")+" ON "
cFiltro += "			 	BOG_FILIAL = '"+xFilial("BOG")+"' AND "
cFiltro += "			 	BOG_CODPRO = BOM_CODPRO AND "
cFiltro += 				RetSQLName("BOG")+".D_E_L_E_T_ = ' '
cFiltro += "			INNER JOIN "+RetSQLName("BOA")+"  ON "
cFiltro += "			 	BOA_FILIAL = '"+xFilial("BOA")+"' AND "
cFiltro += "			 	BOA_CODPRO = BOM_CODPRO AND "
cFiltro += 				RetSQLName("BOA")+".D_E_L_E_T_ = ' '
cFiltro +=	" 				AND BOA_ATIVO = '1' "
cFiltro += "			INNER JOIN "+RetSQLName("SUW")+" ON "
cFiltro += "			 	UW_FILIAL = '"+xFilial("SUW")+"' AND "
cFiltro += "			 	UW_CODCAMP = BOG_CODCAM AND "
cFiltro += 				RetSQLName("BOG")+".D_E_L_E_T_ = ' '
cFiltro += "		WHERE "


IF !Empty(cProgAte)
	cFiltro += " 			BOG_CODPRO >= '"+cProgDe+"'  AND  	BOG_CODPRO <= '"+cProgAte+"'  AND "
Endif

cFiltro +=  			RetSQLName("AG5")+".D_E_L_E_T_ = ' ' "
If cModRel==2
	cFiltro += "	GROUP BY BOA_CODPRO,BOA_DESPRO, UW_CODEVE, UW_DESCEVE,  ACD_LOCAL,ACE_DATA"
	cFiltro += "ORDER BY BOA_CODPRO,BOA_DESPRO, UW_CODEVE, UW_DESCEVE,  ACD_LOCAL,ACE_DATA"
Else
	cFiltro +=" ORDER BY BOA_CODPRO,"
	cFiltro += " ACD_LOCAL,BI3_CODIGO,BA1_CODEMP"
Endif

cFiltro	:= ChangeQuery(cFiltro)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cFiltro),"TRB2",.T.,.F.)

DbSelectArea("TRB2")



If Eof()
	TRB2->( dbCloseArea() )
	return(nLin)
endif


TRB2->( dbGotop() )
While !TRB2->(Eof())
	If cModRel ==1
		IF  (cMatvi<>TRB2->BOM_VIDA .or. (cMatvi==TRB2->BOM_VIDA .and. cProgram<>TRB2->BOA_CODPRO))
			Aadd(aDados, { TRB2->BOA_CODPRO+"-"+TRB2->BOA_DESPRO, TRB2->ACD_LOCAL,TRB2->CARTEIRA,TRB2->BOM_VIDA+"-"+Substr(TRB2->BOM_NOME,1,20),HS_A58Age(stod(TRB2->BA1_DATNAS)),Iif(!Empty(TRB2->BOM_DTELEG),stod(TRB2->BOM_DTELEG),""),Iif(!Empty(TRB2->BOM_DTINSC),stod(TRB2->BOM_DTINSC),""),Iif(!Empty(TRB2->BOM_DATALT),stod(TRB2->BOM_DATALT),"") ,Iif(!Empty(TRB2->ACE_DATA),stod(TRB2->ACE_DATA),"") ,TRB2->BI3_CODIGO+'-'+TRB2->BI3_DESCRI,TRB2->BA1_CODEMP+'-'+Pro02BusEm("TRB2"),TRB2->UW_CODEVE+'-'+ SUBSTR(TRB2->UW_DESCEVE,1,10),"",TRB2->BOM_GRARIS+'-'+Posicione('BOB',2,xFilial('BOB')+TRB2->BOM_GRARIS+TRB2->BOA_CODPRO,'BOB_RISCO')})
		Endif
	Else
		Aadd(aDados, { TRB2->BOA_CODPRO+'-'+SUBSTR(TRB2->BOA_DESPRO,1,40),TRB2->UW_CODEVE +'-'+SUBSTR(TRB2->UW_DESCEVE,1,40), TRB2->ACD_LOCAL, Iif(!Empty(TRB2->ACE_DATA),stod(TRB2->ACE_DATA),"") , TRB2->PALESTRAS , TRB2->PARTICIP,"","","","","","","","" })
	Endif
	
	cProgram	:=TRB2->BOA_CODPRO
	
	If cModRel ==1
		cMatvi:=TRB2->BOM_VIDA
	Endif
	TRB2->(DbSkip())
	
EndDo
TRB2->( dbCloseArea() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da Função para montar a Serie do Grafico     ³
//³ aDados : array com as informaçoes do Select 			³
//³	Posicao:Exemplo 5, onde está o Valor a ser exibido	³
//³	na Serie Neste caso a Coluna QTDVIDA					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cModRel==2
	Pro02SetGr(aDados,5,cGraf)
Endif
aHdadoR:={}

If cModRel==1
	
	Aadd(aHdadoR, { STR0063, STR0059,STR0060,STR0061,STR0058,STR0055,STR0054,STR0053,STR0052,STR0062,STR0056,STR0057,"","Risco"  })//"Dat. Event"//"Dat.Alta."//"Dat.Insc."//"Dt.Elegibilidade."//"Empresa"//"Evento"//"Idade"//"Local"//"Matricula"//"Nome"//"Plano"//"Programa"
Else
	Aadd(aHdadoR, { STR0069,STR0065,STR0066,STR0064,STR0068,STR0067,"","","","" ,"","","",""})//"Data"//"Eventos"//"Local"//"No. Partic."//"Palestras"//"Programa"
Endif


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Chama a Impressão do Relatorio                                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nLin:=PRO02Graf01(aDados,aHdadoR,nLin,nHeiPag,.t.,oGraphic,.t.,cTitulo2,.T.)

Return(nLin)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PRO02Rel03 ºAutor  ³Saude           º Data ³  12/13/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório Nº de Consultas Promoção da Saúde por Período    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PRO02Rel03(nLin,nHeiPag)
Local cFiltro		:=""
Local aDados		:={}
Local n				:=1
Local cTitulo2		:=STR0070//"Nº de Consultas Promoção da Saúde por Período"
Local ntotalCons	:=0
Local cProgram		:=""
Local cMatvi		:=""
Local cGraf		:="Rel03"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selects ...             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cModRel==1
	cFiltro := Rpro02Sele()
	cFiltro +="BD6.BD6_DATPRO,BD6_CODPRO,BD6_DESPRO  "
Else
	cFiltro := " SELECT BOA.BOA_CODPRO,BOA.BOA_DESPRO,BD1.BD1_CODLOC,BD1.BD1_DESLOC,COUNT(BD6.BD6_CODPRO) QTDPROC "
Endif
cFiltro += "  FROM "+RetSqlName("BOA")+ " BOA "
cFiltro += " INNER JOIN "+RetSqlName("BOM")+" BOM ON BOA.BOA_CODPRO = BOM.BOM_CODPRO "
cFiltro += " AND BOM.BOM_FILIAL = '" + xFilial("BOM") + "'  AND BOM.D_E_L_E_T_ = ' ' "
cFiltro +=	" AND BOM.BOM_STATUS  IN  ( '2','1','4','3') "
If cModRel==1
	cFiltro +=Rpro02Sql()
Endif
cFiltro += " INNER JOIN "+RetSqlName("BD6")+" BD6 ON BOM.BOM_VIDA = BD6.BD6_MATVID "
cFiltro += " AND BD6.BD6_DATPRO >= '"+DTOS(cDataI) +"'	  AND BD6.BD6_DATPRO <= '"+DTOS(cDataF)+"' "
cFiltro += " AND BD6.BD6_FILIAL = '" + xFilial("BD6") + "' "
If  !Empty(cSetorAte)
	cFiltro += 	" AND BOM.BOM_CODLOC >= '"+cSetorDe+"' AND BOM.BOM_CODLOC <= '"+cSetorAte+"'	 "
EndIf
cFiltro += " AND BD6.D_E_L_E_T_ = ' ' "
cFiltro += " AND BD6_CODOPE = '"+PlsIntPad()+"' " // Pra ficar um pouco mais rapido
cFiltro += " AND BD6.BD6_CODPRO = BOA_CONPAD "
cFiltro += " INNER JOIN  "+RetSqlName("BD1")+" BD1 ON BD6.BD6_CODOPE = BD1.BD1_CODINT AND BD6.BD6_LOCAL = BD1.BD1_CODLOC "
cFiltro += " AND BD1.BD1_FILIAL = '" + xFilial("BD1") + "' AND BD1.D_E_L_E_T_ = ' '"
cFiltro += 	" WHERE "
IF !Empty(cProgAte)
	cFiltro += 	" BOA_CODPRO >= '"+cProgDe+"'	AND  BOA_CODPRO <= '"+cProgAte+"'	AND "
Endif
cFiltro += " BOA.BOA_FILIAL = '" + xFilial("BOA") + "' AND BOA.D_E_L_E_T_ = ' '   AND "
cFiltro +=	" BOA.BOA_ATIVO = '1' AND  "

cFiltro +=	"   BOM.BOM_DTINSC <= '"+DTOS(cDataF)+"' "//BOM.BOM_DTINSC >= '"+DTOS(cDataI) +"'	  AND
If cModRel==2
	cFiltro +=" GROUP BY BOA.BOA_CODPRO,BOA.BOA_DESPRO,BD1.BD1_CODLOC,BD1.BD1_DESLOC "
	cFiltro += "ORDER BY BOA.BOA_CODPRO,BD1.BD1_CODLOC"
Else
	cFiltro +=" ORDER BY BOA.BOA_CODPRO,"
	cFiltro += " BD1.BD1_CODLOC,BI3.BI3_CODIGO,BA1.BA1_CODEMP"
	
Endif
cFiltro	:= ChangeQuery(cFiltro)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cFiltro),"TRB3",.T.,.F.)

DbSelectArea("TRB3")


If Eof()
	TRB3->( dbCloseArea() )
	return(nLin)
endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Total de Consulta de Todos os Programas            ³
//³Somente Relatorio Sintetico            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

If cModRel==2
	ntotalCons:=Ro02Cons(cDataI,cDataF)
Endif

TRB3->( dbGotop() )
While !TRB3->(Eof())
	If cModRel==2
		Aadd(aDados, { TRB3->BOA_CODPRO+'-'+SUBSTR(TRB3->BOA_DESPRO,1,40) ,TRB3->BD1_CODLOC+'-'+SUBSTR(TRB3->BD1_DESLOC,1,40),"" ,(TRB3->QTDPROC), NOROUND((TRB3->QTDPROC/ntotalCons),2),"","","","","","","","","" })
	ElseIf cModRel ==1 .and. (cMatvi<>TRB3->BOM_VIDA .or. (cMatvi==TRB3->BOM_VIDA .and. cProgram<>TRB3->BOA_CODPRO))
		Aadd(aDados, { TRB3->BOA_CODPRO+"-"+TRB3->BOA_DESPRO, TRB3->BD1_CODLOC+"-"+TRB3->BD1_DESLOC,TRB3->CARTEIRA,TRB3->BOM_VIDA+"-"+Substr(TRB3->BOM_NOME,1,20),HS_A58Age(stod(TRB3->BA1_DATNAS)),Iif(!Empty(TRB3->BOM_DTELEG),stod(TRB3->BOM_DTELEG),""),Iif(!Empty(TRB3->BOM_DTINSC),stod(TRB3->BOM_DTINSC),""),Iif(!Empty(TRB3->BOM_DATALT),stod(TRB3->BOM_DATALT),""),/*TRB3->BOM_MEDRSP+'-'+Substr(HS_IniPadr('SRA', 11, TRB3->BOM_MEDRSP, 'RA_NOME'),1,10)*/"",TRB3->BI3_CODIGO+'-'+TRB3->BI3_DESCRI,TRB3->BA1_CODEMP+'-'+Pro02BusEm("TRB3"),Iif(!Empty(TRB3->BD6_DATPRO),stod(TRB3->BD6_DATPRO),""),alltrim(TRB3->BD6_CODPRO)+'-'+SUBSTR(TRB3->BD6_DESPRO,1,15), TRB3->BOM_GRARIS+Posicione('BOB',2,xFilial('BOB')+TRB3->BOM_GRARIS+TRB3->BOA_CODPRO,'BOB_RISCO')})
	Endif
	
	cProgram	:=TRB3->BOA_CODPRO
	If cModRel ==1
		cMatvi:=TRB3->BOM_VIDA
	Endif
	
	TRB3->(DbSkip())
	
EndDo
TRB3->( dbCloseArea() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da Função para montar a Serie do Grafico     ³
//³ aDados : array com as informaçoes do Select 			³
//³	Posicao:Exemplo 5, onde está o Valor a ser exibido	³
//³	na Serie Neste caso a Coluna QTDVIDA					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cModRel==2
	Pro02SetGr(aDados,4,cGraf)
Endif

aHdadoR:={}
If cModRel==2
	Aadd(aHdadoR, { STR0073,STR0074,"" ,STR0071, STR0072, "" ,"","","","","","","",""})//"Numero consulta"//"Percentual"//"Programa"//"Setor"
Else
	Aadd(aHdadoR, { STR0086, STR0087,STR0081,STR0082,STR0080,STR0078,STR0076,STR0075,/*STR0085*/"",STR0083,STR0079,STR0077,STR0084,"Risco"  })//"Dat.Alta."//"Dat.Insc."//"Dt Proc"//"Dt.Elegibilidade."//"Empresa"//"Idade"//"Matricula"//"Nome"//"Plano"//"Procedimento"//"Prof. Saude"//"Programa"//"Setor"
Endif



/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Chama a Impressão do Relatorio                                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nLin:=PRO02Graf01(aDados,aHdadoR,nLin,nHeiPag,.t.,oGraphic,.t.,cTitulo2,.T.)

Return(nLin) 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PRO02Rel04 ºAutor  ³Saude           º Data ³  12/13/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Nº de Absenteísmo Promoção da Saúde por Período             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PRO02Rel04(nLin,nHeiPag)

Local cFiltro		:=""
Local aDados		:={}
Local n				:=1
Local cTitulo2		:=STR0088//"Nº de Absenteísmo Promoção da Saúde por Período"
Local ntotalCons	:=0
Local cProgram		:=""
Local cMatvi	:=""
Local cGraf		:="Rel04"

If cModRel==1
	cFiltro := Rpro02Sele()
	cFiltro += "GA7.GA7_CODPRO,GA7.GA7_DESC,GM8.GM8_DATAGE  "
	
Else
	cFiltro := " SELECT     BOA.BOA_CODPRO, BOA.BOA_DESPRO,  BD1.BD1_CODLOC,BD1.BD1_DESLOC,  "
	cFiltro += "            COUNT(BOM.BOM_VIDA) QTDVIDA "
Endif

cFiltro += "  FROM      "+RetSqlName("GM8")+" GM8  "
cFiltro += "			INNER JOIN		"+RetSqlName("GBH")+" GBH ON GM8.GM8_REGGER = GBH.GBH_CODPAC  AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ = ' '   "
cFiltro += "			INNER JOIN		"+RetSqlName("BOM")+" BOM ON GBH.GBH_MATVID = BOM.BOM_VIDA    AND BOM.BOM_FILIAL = '" + xFilial("BOM") + "' AND BOM.D_E_L_E_T_ = ' '   "
cFiltro +=	" 			AND BOM.BOM_STATUS  IN  ( '1','2','4') "
cFiltro += "			AND BOM.BOM_DTINSC >= '"+DTOS(cDataI) +"'	  AND BOM.BOM_DTINSC <= '"+DTOS(cDataF)+"' "
If  !Empty(cSetorAte)
	cFiltro += " 		AND BOM.BOM_CODLOC >= '"+cSetorDe+"' AND BOM.BOM_CODLOC <= '"+cSetorAte+"'	 "
EndIf

If cModRel==1
	cFiltro +=Rpro02Sql()
Endif

cFiltro += "  		   INNER JOIN  "+RetSqlName("BD1")+" BD1 ON BOM.BOM_CODLOC = BD1.BD1_CODLOC  AND BD1.BD1_FILIAL = '" + xFilial("BD1") + "' AND BD1.D_E_L_E_T_ = ' '"

cFiltro += "			INNER JOIN		"+RetSqlName("BOA")+" BOA ON BOM.BOM_CODPRO = BOA.BOA_CODPRO  AND BOA.BOA_FILIAL = '" + xFilial("BOA") + "' AND BOA.D_E_L_E_T_ = ' '   "
cFiltro +=	"  			AND BOA.BOA_ATIVO = '1'   "
If !Empty(cProgAte)
	cFiltro += " 		AND BOA.BOA_CODPRO >= '"+cProgDe+"' AND BOA.BOA_CODPRO <= '"+cProgAte+"'	"
Endif
cFiltro += "			INNER JOIN		"+RetSqlName("GA7")+" GA7 ON BOA.BOA_CONPAD = GA7.GA7_PROPLS  AND GM8.GM8_CODPRO = GA7.GA7_CODPRO  AND GA7.D_E_L_E_T_ = ' '   " //AND  GA7.GA7_FILIAL = '" + xFilial("GA7") + "'

cFiltro += "			WHERE  GM8.GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8.D_E_L_E_T_ = ' '  AND  GM8_DATAGE < '"+DTOS(cDataF)+"'"
cFiltro +=	" 			AND GM8.GM8_STATUS  IN  ( '1','3') "
cFiltro +=	" 			AND NOT EXISTS( SELECT 1 FROM "+RetSqlName("BD6")+" BD6 WHERE BD6.BD6_CODPRO = GA7.GA7_PROPLS AND BD6.BD6_DATPRO > GM8.GM8_DATAGE  AND BD6.BD6_FILIAL = '" + xFilial("BD6") + "' AND BD6.D_E_L_E_T_ = ' ')  "

If cModRel==2
	cFiltro +=	"	GROUP BY BOA.BOA_CODPRO, BOA.BOA_DESPRO,  BD1.BD1_CODLOC,BD1.BD1_DESLOC"
	cFiltro += " 	ORDER BY BOA.BOA_CODPRO,BOA.BOA_DESPRO,BD1.BD1_CODLOC,BD1.BD1_DESLOC "
	
Else
	cFiltro +=" 	ORDER BY BOA.BOA_CODPRO,"
	cFiltro +="	BD1.BD1_CODLOC,BI3.BI3_CODIGO,BA1.BA1_CODEMP"
Endif

cFiltro	:= ChangeQuery(cFiltro)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cFiltro),"TRB4",.T.,.F.)

DbSelectArea("TRB4")

If Eof()
	TRB4->( dbCloseArea() )
	return(nLin)
endif

If cModRel==2
	ntotalCons:=Ro02Cons(cDataI,cDataF)
Endif


TRB4->( dbGotop() )
While !TRB4->(Eof())
	If cModRel==2
		Aadd(aDados, { TRB4->BOA_CODPRO+'-'+SUBSTR(TRB4->BOA_DESPRO,1,40) ,TRB4->BD1_CODLOC+'-'+SUBSTR(TRB4->BD1_DESLOC,1,40),"", ntotalCons, TRB4->QTDVIDA,  NOROUND(TRB4->QTDVIDA/ntotalCons),"","","","","","","","" })
		
	ElseIf cModRel ==1 .and. (cMatvi<>TRB4->BOM_VIDA .or. (cMatvi==TRB4->BOM_VIDA .and. cProgram<>TRB4->BOA_CODPRO))
		Aadd(aDados, { TRB4->BOA_CODPRO+"-"+TRB4->BOA_DESPRO, TRB4->BD1_CODLOC+"-"+TRB4->BD1_DESLOC,TRB4->CARTEIRA,TRB4->BOM_VIDA+"-"+Substr(TRB4->BOM_NOME,1,20),HS_A58Age(stod(TRB4->BA1_DATNAS)),Iif(!Empty(TRB4->BOM_DTELEG),stod(TRB4->BOM_DTELEG),""),Iif(!Empty(TRB4->BOM_DTINSC),stod(TRB4->BOM_DTINSC),""),Iif(!Empty(TRB4->BOM_DATALT),stod(TRB4->BOM_DATALT),""),Iif(!Empty(TRB4->GM8_DATAGE),stod(TRB4->GM8_DATAGE),""),TRB4->BI3_CODIGO+'-'+TRB4->BI3_DESCRI,TRB4->BA1_CODEMP+'-'+Pro02BusEm("TRB4"),TRB4->GA7_CODPRO+'-'+SUBSTR(TRB4->GA7_DESC,1,20),"",TRB4->BOM_GRARIS+Posicione('BOB',2,xFilial('BOB')+TRB4->BOM_GRARIS+TRB4->BOA_CODPRO,'BOB_RISCO')})//,TRB4->BOM_MEDRSP+'-'+Substr(HS_IniPadr('SRA', 11, TRB4->BOM_MEDRSP, 'RA_NOME'),1,15)
	Endif
	
	cProgram	:=TRB4->BOA_CODPRO
	
	If cModRel ==1
		cMatvi:=TRB4->BOM_VIDA
	Endif
	
	TRB4->(DbSkip())
EndDo

TRB4->( dbCloseArea() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da Função para montar a Serie do Grafico     ³
//³ aDados : array com as informaçoes do Select 			³
//³	Posicao:Exemplo 5, onde está o Valor a ser exibido	³
//³	na Serie Neste caso a Coluna QTDVIDA					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cModRel==2
	Pro02SetGr(aDados,5,cGraf)
Endif

aHdadoR:={}

If  cModRel==2
	Aadd(aHdadoR, { STR0092,STR0093 ,"", STR0091, STR0090,STR0089,"","","","","","","","" }) //"%Perct"//"Faltas"//"No. Consulta"//"Programa"//"Setor"
Else
	Aadd(aHdadoR, { STR0104, STR0105,STR0100,STR0101,STR0099,STR0097,STR0095,STR0094,STR0096,STR0102,STR0098,STR0103,"","Risco"  })//"Dat.Alta."//"Dat.Insc."//"Dt.Agend"//"Dt.Elegibilidade."//"Empresa"//"Idade"//"Matricula"//"Nome"//"Plano"//"Procedim."//"Programa"//"Setor"
Endif

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Chama a Impressão do Relatorio                                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nLin:=PRO02Graf01(aDados,aHdadoR,nLin,nHeiPag,.t.,oGraphic,.t.,cTitulo2,.T.)

Return(nLin)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PRO02Rel05 ºAutor  ³Saude           º Data ³  12/13/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³4	Relatório Beneficiários Desligados dos Programas de       º±±
±±º          ³Promoção da Saúde por Período                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PRO02Rel05(nLin,nHeiPag)
Local cFiltro		:=""
Local aDados		:={}
Local n				:=1
Local cTitulo2		:=STR0106//"Beneficiários Desligados dos Programas de Promoção da Saúde por Período"
Local cProgram		:=""
Local cMatvi		:=""
Local cGraf		:="Rel05"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selects ...             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


If cModRel==1
	cFiltro := Rpro02Sele()
	cFiltro += "BOM.BOM_MOTALT  "
	
Else
	
	cFiltro := " SELECT BOA.BOA_CODPRO,BOA.BOA_DESPRO,BD1.BD1_CODLOC,BD1.BD1_DESLOC,BOM.BOM_MOTALT,count(BOM.BOM_VIDA) QTDVIDA "
Endif

cFiltro += "  FROM "+RetSqlName("BOA")+ " BOA "
cFiltro += " INNER JOIN "+RetSqlName("BOM")+" BOM ON BOA.BOA_CODPRO = BOM.BOM_CODPRO AND BOM.BOM_FILIAL = '" + xFilial("BOM") + "' AND  BOM.D_E_L_E_T_ = ' '  "
If cModRel==1
	cFiltro +=Rpro02Sql()
Endif
cFiltro += "  INNER JOIN  "+RetSqlName("BD1")+" BD1 ON BOM.BOM_CODLOC = BD1.BD1_CODLOC  AND BD1.BD1_FILIAL = '" + xFilial("BD1") + "' AND BD1.D_E_L_E_T_ = ' '"
cFiltro += 	" WHERE BOA.BOA_FILIAL = '" + xFilial("BOA") + "' AND  BOA.D_E_L_E_T_ = ' ' ""
cFiltro +=		"  AND BOA.BOA_ATIVO = '1'   "
If !Empty(cProgAte)
	cFiltro += 	" AND BOA_CODPRO >= '"+cProgDe+"' AND BOA.BOA_CODPRO <= '"+cProgAte+"'	"
Endif

If !Empty(cSetorAte)
	cFiltro += 	" AND BOM.BOM_CODLOC >= '"+cSetorDe+"' AND BOM.BOM_CODLOC <= '"+cSetorAte+"'	 "
EndIf
cFiltro += 	" AND BOM.BOM_DTINSC >= '"+DTOS(cDataI) +"'	  AND BOM.BOM_DTINSC <= '"+DTOS(cDataF)+"' "
cFiltro += 	" AND BOM.BOM_STATUS = '2' "
If cModRel==2
	cFiltro +=	" GROUP BY BOA.BOA_CODPRO,BOA.BOA_DESPRO,BOA.BOA_META,BD1.BD1_CODLOC,BD1.BD1_DESLOC,BOM.BOM_MOTALT "
	cFiltro += " ORDER BY BOA.BOA_CODPRO,BOA.BOA_DESPRO,BD1.BD1_CODLOC,BD1.BD1_DESLOC "
Else
	cFiltro +=" ORDER BY BOA.BOA_CODPRO,"
	cFiltro += " BD1.BD1_CODLOC,BI3.BI3_CODIGO,BA1.BA1_CODEMP"
	
Endif
cFiltro	:= ChangeQuery(cFiltro)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cFiltro),"TRB5",.T.,.F.)


DbSelectArea("TRB5")


If Eof()
	TRB5->( dbCloseArea() )
	return(nLin)
endif


TRB5->( dbGotop() )
While !TRB5->(Eof())
	
	If  cModRel==2
		Aadd(aDados, { TRB5->BOA_CODPRO+'-'+SUBSTR(TRB5->BOA_DESPRO,1,40) ,TRB5->BD1_CODLOC+'-'+SUBSTR(TRB5->BD1_DESLOC,1,40),"",TRB5->BOM_MOTALT+"-"+Posicione("GF4",1,xFilial("GF4")+TRB5->BOM_MOTALT,"GF4_DSTPAL"), TRB5->QTDVIDA,"","","","","","","","",""})
		
	ElseIf cModRel ==1 .and. (cMatvi<>TRB5->BOM_VIDA .or. (cMatvi==TRB5->BOM_VIDA .and. cProgram<>TRB5->BOA_CODPRO))
		Aadd(aDados, { TRB5->BOA_CODPRO+"-"+TRB5->BOA_DESPRO, TRB5->BD1_CODLOC+"-"+TRB5->BD1_DESLOC,TRB5->CARTEIRA,TRB5->BOM_VIDA+"-"+Substr(TRB5->BOM_NOME,1,20),HS_A58Age(stod(TRB5->BA1_DATNAS)),Iif(!Empty(TRB5->BOM_DTELEG),stod(TRB5->BOM_DTELEG),""),Iif(!Empty(TRB5->BOM_DTINSC),stod(TRB5->BOM_DTINSC),""),Iif(!Empty(TRB5->BOM_DATALT),stod(TRB5->BOM_DATALT),""),TRB5->BOM_MEDRSP+'-'+Substr(HS_IniPadr('SRA', 11, TRB5->BOM_MEDRSP, 'RA_NOME'),1,10),TRB5->BI3_CODIGO+'-'+TRB5->BI3_DESCRI,TRB5->BA1_CODEMP+'-'+Pro02BusEm("TRB5"),"",TRB5->BOM_MOTALT+"-"+Posicione("GF4",1,xFilial("GF4")+TRB5->BOM_MOTALT,"GF4_DSTPAL"),"",TRB5->BOM_GRARIS+Posicione('BOB',2,xFilial('BOB')+TRB5->BOM_GRARIS+TRB5->BOA_CODPRO,'BOB_RISCO')})
		
	Endif
	
	cProgram	:=TRB5->BOA_CODPRO
	If cModRel ==1
		cMatvi:=TRB5->BOM_VIDA
	Endif
	
	TRB5->(DbSkip())
	
EndDo
TRB5->( dbCloseArea() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da Função para montar a Serie do Grafico     ³
//³ aDados : array com as informaçoes do Select 			³
//³	Posicao:Exemplo 5, onde está o Valor a ser exibido	³
//³	na Serie Neste caso a Coluna QTDVIDA					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cModRel==2
	Pro02SetGr(aDados,5,cGraf)
Endif

aHdadoR:={}
If  cModRel==2
	Aadd(aHdadoR, { STR0109,STR0110 ,"",STR0107, STR0108,"","","","","","","","","" })//"Motivo Desligamento"//"Num Desligamentos"//"Programa"//"Setor"
Else
	Aadd(aHdadoR, { STR0121, STR0122,STR0116,STR0118,STR0115,STR0113,STR0112,STR0111,STR0120,STR0119,STR0114,"",STR0117,"","Risco"  })//"Dat.Alta."//"Dat.Insc."//"Dt.Elegibilidade."//"Empresa"//"Idade"//"Matricula"//"Motiv. Alta"//"Nome"//"Plano"//"Prof. Saude"//"Programa"//"Setor"
Endif


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Chama a Impressão do Relatorio                                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nLin:=PRO02Graf01(aDados,aHdadoR,nLin,nHeiPag,.t.,oGraphic,.t.,cTitulo2,.T.)

Return(nLin)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PRO02Rel07 ºAutor  ³Saude           º Data ³  12/17/12   	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Beneficiários Por Empresa                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Static Function PRO02Rel07(nLin,nHeiPag)
Local cFiltro		:=""
Local aDados		:={}
Local n				:=1
Local cArq			:= "PRO02" + CriaTrab(NIL,.F.) + ".JPEG"
Local cBA1Name 		:= RetSQLName("BA1")
Local cBQCName 		:= RetSQLName("BQC")
Local cBOMName 		:= RetSQLName("BOM")
Local cTitulo2		:=STR0123//"Beneficiários Por Empresa"
Local cProgram		:=""
Local cMatvi		:=""
Local nVida			:=0
Local ni,nj			:=0
Local cPrograPos	:=""
Local cGraf			:="Rel06"
Local cCemp			:=""


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selects ...             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cModRel==1
	cFiltro := Rpro02Sele()
	cFiltro += "BA1.BA1_CODINT  "
	
Else
	
	cFiltro +=" SELECT     BOA.BOA_CODPRO,BOA.BOA_DESPRO,BD1.BD1_CODLOC,BD1.BD1_DESLOC,BA1.BA1_CODINT, BA1.BA1_CODEMP, BA1.BA1_CONEMP , BA1.BA1_VERCON, BA1.BA1_SUBCON, BA1.BA1_VERSUB, "
	cFiltro +="            COUNT(BOM.BOM_VIDA) QTDVIDA"
Endif


cFiltro += "  FROM "+RetSqlName("BOM")+ " BOM "
cFiltro += "  LEFT JOIN  "+RetSqlName("BD1")+" BD1 ON BOM.BOM_CODLOC = BD1.BD1_CODLOC  AND BD1.BD1_FILIAL = '" + xFilial("BD1") + "' AND BD1.D_E_L_E_T_ = ' '"

cFiltro +=Rpro02Sql()

cFiltro += "  INNER JOIN "+RetSqlName("BOA")+" BOA ON BOA.BOA_CODPRO = BOM.BOM_CODPRO AND BOA.BOA_FILIAL = '" + xFilial("BOA") + "'   AND BOA.D_E_L_E_T_ = ' ' "
cFiltro +=		"  AND BOA.BOA_ATIVO = '1'  "
cFiltro += 	" WHERE  BOM.BOM_DTINSC >= '"+DTOS(cDataI) +"'	  AND BOM.BOM_DTINSC <= '"+DTOS(cDataF)+"' "
If  !Empty(cProgAte)
	cFiltro +=	" AND BOA.BOA_CODPRO >= '"+cProgDe+"' AND BOA.BOA_CODPRO <= '"+cProgAte+"'	 "
Endif
If  !Empty(cSetorAte)
	cFiltro +=	" AND BOM.BOM_CODLOC >= '"+cSetorDe+"' AND BOM.BOM_CODLOC <= '"+cSetorAte+"'	 "
Endif
cFiltro +=	" 	AND BOM.BOM_STATUS  IN  ( '2','1','4','3') "
cFiltro +=	"   AND BOM.D_E_L_E_T_ = ' '	"
If cModRel==2
	cFiltro +=" GROUP BY BOA.BOA_CODPRO,BOA.BOA_DESPRO,BD1.BD1_CODLOC,BD1.BD1_DESLOC,BA1.BA1_CODINT, BA1.BA1_CODEMP, BA1.BA1_CONEMP , BA1.BA1_VERCON, BA1.BA1_SUBCON, BA1.BA1_VERSUB "
	cFiltro +=" ORDER BY BOA.BOA_CODPRO,BD1.BD1_CODLOC"
Else
	cFiltro +=" ORDER BY BOA.BOA_CODPRO,"
	cFiltro += " BD1.BD1_CODLOC,BI3.BI3_CODIGO,BA1.BA1_CODEMP"
	
Endif


cFiltro	:= ChangeQuery(cFiltro)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cFiltro),"TRBBQC",.T.,.F.)

DbSelectArea("TRBBQC")



If Eof()
	TRBBQC->( dbCloseArea() )
	return(nLin)
endif



TRBBQC->( dbGotop() )


While !TRBBQC->(Eof())
	IF !Empty(TRBBQC->BA1_CONEMP)
		cCemp:=TRBBQC->BA1_CODEMP+"/" + TRBBQC->BA1_CONEMP+ "/" + TRBBQC->BA1_VERCON+ TRBBQC->BA1_SUBCON+ "/" + TRBBQC->BA1_VERSUB
	Else
		cCemp:=TRBBQC->BA1_CODEMP
	Endif
	
	If cModRel==2
		Aadd(aDados, { TRBBQC->BOA_CODPRO+'-'+SUBSTR(TRBBQC->BOA_DESPRO,1,20),TRBBQC->BD1_CODLOC+'-'+SUBSTR(TRBBQC->BD1_DESLOC,1,40),"",cCemp,"",Pro02BusEm("TRBBQC"),TRBBQC->QTDVIDA ,"","","","","","",""})
	ElseIf cModRel ==1 .and. (cMatvi<>TRBBQC->BOM_VIDA .or. (cMatvi==TRBBQC->BOM_VIDA .and. cProgram<>TRBBQC->BOA_CODPRO))
		Aadd(aDados, { TRBBQC->BOA_CODPRO+"-"+TRBBQC->BOA_DESPRO, TRBBQC->BD1_CODLOC+"-"+TRBBQC->BD1_DESLOC,TRBBQC->CARTEIRA,TRBBQC->BOM_VIDA+"-"+Substr(TRBBQC->BOM_NOME,1,20),HS_A58Age(stod(TRBBQC->BA1_DATNAS)),Iif(!Empty(TRBBQC->BOM_DTELEG),stod(TRBBQC->BOM_DTELEG),""),Iif(!Empty(TRBBQC->BOM_DTINSC),stod(TRBBQC->BOM_DTINSC),""),Iif(!Empty(TRBBQC->BOM_DATALT),stod(TRBBQC->BOM_DATALT),""),TRBBQC->BOM_MEDRSP+'-'+Substr(HS_IniPadr('SRA', 11, TRBBQC->BOM_MEDRSP, 'RA_NOME'),1,10),TRBBQC->BI3_CODIGO+'-'+TRBBQC->BI3_DESCRI,TRBBQC->BA1_CODEMP,"",Pro02BusEm("TRBBQC"),TRBBQC->BOM_GRARIS+Posicione('BOB',2,xFilial('BOB')+TRBBQC->BOM_GRARIS+TRBBQC->BOA_CODPRO,'BOB_RISCO')})
	Endif
	
	
	cProgram	:=TRBBQC->BOA_CODPRO
	If cModRel ==1
		cMatvi:=TRBBQC->BOM_VIDA
	Endif
	
	TRBBQC->(DbSkip())
	
EndDo


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da Função para montar a Serie do Grafico     ³
//³ aDados : array com as informaçoes do Select 			³
//³	Posicao:Exemplo 5, onde está o Valor a ser exibido	³
//³	na Serie Neste caso a Coluna QTDVIDA					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cModRel==2
	Pro02SetGr(aDados,7,cGraf)
Endif

aHdador:={}
If cModRel==2
	Aadd(aHdadoR, { STR0126,STR0128 ,"",STR0125,"",STR0124,Space(10)+STR0127,"","","","","","","" }) //"Descricao"//"Empresa/Contrato"//"Programa"//"Qtd.Benef"//"Setor"
Else
	Aadd(aHdadoR, { STR0139, STR0140,STR0135,STR0136,STR0134,STR0132,STR0130,STR0129,STR0138,STR0137,STR0133,"",STR0131,"Risco"  })//"Dat.Alta."//"Dat.Insc."//"Descri"//"Dt.Elegibilidade."//"Empresa"//"Idade"//"Matricula"//"Nome"//"Plano"//"Prof. Saude"//"Programa"//"Setor"
	
Endif



/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Chama a Impressão do Relatorio                                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nLin:=PRO02Graf01(aDados,aHdadoR,nLin,nHeiPag,.t.,oGraphic,.t.,cTitulo2,.T.)

TRBBQC->( dbCloseArea() )
Return(nLin)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PRO02Rel08 ºAutor  ³Saude           º Data ³  12/17/12   	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Beneficiários Por Categoria                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PRO02Rel08(nLin,nHeiPag)
Local cFiltro		:=""
Local aDados		:={}
Local n				:=1
Local cArq			:= "PRO02" + CriaTrab(NIL,.F.) + ".JPEG"
Local cTitulo2		:=STR0141//"Beneficiários Por Categoria"
Local cProgram		:=""
Local cMatvi		:=""
Local cGraf		:="Rel07"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selects ...             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cModRel==1
	cFiltro := Rpro02Sele()
	cFiltro += "BA1.BA1_CODINT  "
Else
	cFiltro +=" SELECT     BOA.BOA_CODPRO,BOA.BOA_DESPRO,BD1.BD1_CODLOC,BD1.BD1_DESLOC,BI3_CODIGO,BI3_DESCRI ,"
	cFiltro +="                       COUNT(BOM.BOM_VIDA) QTDVIDA
Endif

cFiltro += "  FROM "+RetSqlName("BOM")+ " BOM "
cFiltro += "  LEFT JOIN  "+RetSqlName("BD1")+" BD1 ON BOM.BOM_CODLOC = BD1.BD1_CODLOC  AND BD1.BD1_FILIAL = '" + xFilial("BD1") + "' AND BD1.D_E_L_E_T_ = ' '"
cFiltro +=Rpro02Sql()
cFiltro += "  INNER JOIN "+RetSqlName("BOA")+" BOA ON BOA.BOA_CODPRO = BOM.BOM_CODPRO AND BOA.BOA_FILIAL = '" + xFilial("BOA") + "'   AND BOA.D_E_L_E_T_ = ' ' "
cFiltro +=		" AND BOA.BOA_ATIVO = '1'   "
cFiltro += 	" WHERE  BOM.BOM_DTINSC >= '"+DTOS(cDataI) +"'	  AND BOM.BOM_DTINSC <= '"+DTOS(cDataF)+"' "

If !empty(cProgAte)
	cFiltro += 	" AND BOA.BOA_CODPRO >= '"+cProgDe+"'	AND BOA.BOA_CODPRO <= '"+cProgAte+"' "
Endif

If !Empty(cSetorAte)
	cFiltro += 	" AND BOM.BOM_CODLOC >= '"+cSetorDe+"' AND BOM.BOM_CODLOC <= '"+cSetorAte+"'	 "
Endif

cFiltro +=	" 	AND BOM.BOM_STATUS  IN  ( '2','1','4','3') "
cFiltro +=	" AND BOM.D_E_L_E_T_ = ' ' "

If cModRel==2
	cFiltro +=" GROUP BY BOA.BOA_CODPRO,BOA.BOA_DESPRO,BD1.BD1_CODLOC,BD1.BD1_DESLOC,BI3_CODIGO,BI3_DESCRI"
	cFiltro +=" ORDER BY BOA.BOA_CODPRO,BD1.BD1_CODLOC"
Else
	cFiltro +=" ORDER BY BOA.BOA_CODPRO,"
	cFiltro += " BD1.BD1_CODLOC,BI3.BI3_CODIGO,BA1.BA1_CODEMP"
Endif

cFiltro	:= ChangeQuery(cFiltro)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cFiltro),"TRBBI3",.T.,.F.)

DbSelectArea("TRBBI3")


If Eof()
	TRBBI3->( dbCloseArea() )
	return(nLin)
endif


TRBBI3->( dbGotop() )

While !TRBBI3->(Eof())
	If cModRel==2
		Aadd(aDados, { TRBBI3->BOA_CODPRO+'-'+SUBSTR(TRBBI3->BOA_DESPRO,1,40),TRBBI3->BD1_CODLOC+'-'+SUBSTR(TRBBI3->BD1_DESLOC,1,40),"", TRBBI3->BI3_CODIGO+'-'+SUBSTR(TRBBI3->BI3_DESCRI,1,40),"",TRBBI3->QTDVIDA,"","","","","","","","" })
		
	ElseIf cModRel ==1 .and. (cMatvi<>TRBBI3->BOM_VIDA .or. (cMatvi==TRBBI3->BOM_VIDA .and. cProgram<>TRBBI3->BOA_CODPRO))
		Aadd(aDados, { TRBBI3->BOA_CODPRO+"-"+TRBBI3->BOA_DESPRO, TRBBI3->BD1_CODLOC+"-"+TRBBI3->BD1_DESLOC,TRBBI3->CARTEIRA,TRBBI3->BOM_VIDA+"-"+Substr(TRBBI3->BOM_NOME,1,20),HS_A58Age(stod(TRBBI3->BA1_DATNAS)),Iif(!Empty(TRBBI3->BOM_DTELEG),stod(TRBBI3->BOM_DTELEG),""),Iif(!Empty(TRBBI3->BOM_DTINSC),stod(TRBBI3->BOM_DTINSC),""),Iif(!Empty(TRBBI3->BOM_DATALT),stod(TRBBI3->BOM_DATALT),""),TRBBI3->BOM_MEDRSP+'-'+Substr(HS_IniPadr('SRA', 11, TRBBI3->BOM_MEDRSP, 'RA_NOME'),1,15),TRBBI3->BI3_CODIGO+'-'+TRBBI3->BI3_DESCRI,TRBBI3->BA1_CODEMP+'-'+Pro02BusEm("TRBBI3"),"",TRBBI3->BOM_GRARIS+Posicione('BOB',2,xFilial('BOB')+TRBBI3->BOM_GRARIS+TRBBI3->BOA_CODPRO,'BOB_RISCO'),""})
	Endif
	cProgram	:=TRBBI3->BOA_CODPRO
	
	If cModRel ==1
		cMatvi:=TRBBI3->BOM_VIDA
	Endif
	TRBBI3->(DbSkip())
	
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da Função para montar a Serie do Grafico     ³
//³ aDados : array com as informaçoes do Select 			³
//³	Posicao:Exemplo 5, onde está o Valor a ser exibido	³
//³	na Serie Neste caso a Coluna QTDVIDA					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


If cModRel==2
	Pro02SetGr(aDados,6,cGraf)
Endif

aHdador:={}
If cModRel==2
	Aadd(aHdadoR, { STR0143, STR0145,"",STR0142 ,"", STR0144,"","","","","","","","" }) //"Plano"//"Programa"//"Qtd.Benef"//"Setor"
Else
	Aadd(aHdadoR, { STR0156, STR0157,STR0152,STR0153,STR0151,STR0149,STR0147,STR0146,STR0155,STR0154,STR0150,STR0148,"","Risco"  })//"Dat.Alta."//"Dat.Insc."//"Descri"//"Dt.Elegibilidade."//"Empresa"//"Idade"//"Matricula"//"Nome"//"Plano"//"Prof. Saude"//"Programa"//"Setor"
Endif


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Chama a Impressão do Relatorio                                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nLin:=PRO02Graf01(aDados,aHdadoR,nLin,nHeiPag,.t.,oGraphic,.t.,cTitulo2,.T.)

TRBBI3->( dbCloseArea() )
Return(nLin)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PRO02Rel09 ºAutor  ³Saude           º Data ³  12/17/12   	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Beneficiários Por Titularidade                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PRO02Rel09(nLin,nHeiPag)
Local cFiltro		:=""
Local aDados		:={}
Local n				:=1
Local cArq			:= "PRO02" + CriaTrab(NIL,.F.) + ".JPEG"
Local cTitulo2		:=STR0158//"Beneficiários Por Titularidade"
Local cProgram		:=""
Local cMatvi		:=""
Local cGraf		:="Rel08"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selects ...             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cModRel==1
	cFiltro := Rpro02Sele()
	cFiltro += "BA1.BA1_TIPUSU  "
Else
	
	cFiltro +=" SELECT     BOA.BOA_CODPRO,BOA.BOA_DESPRO,BD1.BD1_CODLOC,BD1.BD1_DESLOC,BA1.BA1_TIPUSU ,"
	cFiltro +="                       COUNT(BOM.BOM_VIDA) QTDVIDA
Endif

cFiltro += "  FROM "+RetSqlName("BOM")+ " BOM "
cFiltro +=Rpro02Sql()
cFiltro += "  LEFT JOIN  "+RetSqlName("BD1")+" BD1 ON BOM.BOM_CODLOC = BD1.BD1_CODLOC  AND BD1.BD1_FILIAL = '" + xFilial("BD1") + "' AND BD1.D_E_L_E_T_ = ' '"
cFiltro += "  INNER JOIN "+RetSqlName("BOA")+" BOA ON BOA.BOA_CODPRO = BOM.BOM_CODPRO AND BOA.BOA_FILIAL = '" + xFilial("BOA") + "'   AND BOA.D_E_L_E_T_ = ' ' "
cFiltro +=		" AND  BOA.BOA_ATIVO = '1'   "
cFiltro += 	" WHERE  BOM.BOM_DTINSC >= '"+DTOS(cDataI) +"'	  AND BOM.BOM_DTINSC <= '"+DTOS(cDataF)+"' "
If !EMPTY(cProgAte)
	cFiltro += 	" AND BOA.BOA_CODPRO >= '"+cProgDe+"'	AND BOA.BOA_CODPRO <= '"+cProgAte+"' "
Endif
If  !Empty(cSetorAte)
	cFiltro += 	" AND BOM.BOM_CODLOC >= '"+cSetorDe+"' AND BOM.BOM_CODLOC <= '"+cSetorAte+"'	 "
Endif
cFiltro +=	" 	AND BOM.BOM_STATUS  IN  ( '2','1','4','3') "
cFiltro += 	" AND BOM.D_E_L_E_T_ = ' '	"

If cModRel==2
	cFiltro +=" GROUP BY BOA.BOA_CODPRO,BOA.BOA_DESPRO,BD1.BD1_CODLOC,BD1.BD1_DESLOC,BA1.BA1_TIPUSU"
	cFiltro +=" ORDER BY BOA.BOA_CODPRO,BD1.BD1_CODLOC"
	
Else
	cFiltro +=" ORDER BY BOA.BOA_CODPRO,"
	cFiltro += " BD1.BD1_CODLOC,BI3.BI3_CODIGO,BA1.BA1_CODEMP"
Endif

cFiltro	:= ChangeQuery(cFiltro)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cFiltro),"TRBBA1",.T.,.F.)

DbSelectArea("TRBBA1")


If Eof()
	TRBBA1->( dbCloseArea() )
	return(nLin)
endif


TRBBA1->( dbGotop() )

While !TRBBA1->(Eof())
	
	If cModRel==2
		Aadd(aDados, { TRBBA1->BOA_CODPRO+'-'+SUBSTR(TRBBA1->BOA_DESPRO,1,40),TRBBA1->BD1_CODLOC+'-'+SUBSTR(TRBBA1->BD1_DESLOC,1,40),"",IIF(TRBBA1->BA1_TIPUSU=="T",STR0160,STR0159),"",TRBBA1->QTDVIDA,"","","","","","","","" })//"Dependentes"//"Titulares"
	ElseIf cModRel ==1 .and. (cMatvi<>TRBBA1->BOM_VIDA .or. (cMatvi==TRBBA1->BOM_VIDA .and. cProgram<>TRBBA1->BOA_CODPRO))
		Aadd(aDados, { TRBBA1->BOA_CODPRO+"-"+TRBBA1->BOA_DESPRO, TRBBA1->BD1_CODLOC+"-"+TRBBA1->BD1_DESLOC,TRBBA1->CARTEIRA,TRBBA1->BOM_VIDA+"-"+Substr(TRBBA1->BOM_NOME,1,20),HS_A58Age(stod(TRBBA1->BA1_DATNAS)),Iif(!Empty(TRBBA1->BOM_DTELEG),stod(TRBBA1->BOM_DTELEG),""),Iif(!Empty(TRBBA1->BOM_DTINSC),stod(TRBBA1->BOM_DTINSC),""),Iif(!Empty(TRBBA1->BOM_DATALT),stod(TRBBA1->BOM_DATALT),""),TRBBA1->BOM_MEDRSP+'-'+Substr(HS_IniPadr('SRA', 11, TRBBA1->BOM_MEDRSP, 'RA_NOME'),1,15),TRBBA1->BI3_CODIGO+'-'+TRBBA1->BI3_DESCRI,TRBBA1->BA1_CODEMP+'-'+Pro02BusEm("TRBBA1"),"",Space(5)+IIF(TRBBA1->BA1_TIPUSU=="T",STR0162,STR0161),TRBBA1->BOM_GRARIS+Posicione('BOB',2,xFilial('BOB')+TRBBA1->BOM_GRARIS+TRBBA1->BOA_CODPRO,'BOB_RISCO')})//"Dependentes"//"Titulares"
	Endif
	
	cProgram:=TRBBA1->BOA_CODPRO
	
	If cModRel ==1
		cMatvi:=TRBBA1->BOM_VIDA
	Endif
	
	TRBBA1->(DbSkip())
	
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da Função para montar a Serie do Grafico     ³
//³ aDados : array com as informaçoes do Select 			³
//³	Posicao:Exemplo 5, onde está o Valor a ser exibido	³
//³	na Serie Neste caso a Coluna QTDVIDA					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cModRel==2
	Pro02SetGr(aDados,6,cGraf)
Endif

aHdador:={}
If cModRel==2
	Aadd(aHdadoR, { STR0163,STR0165,"",STR0166,"", STR0164,"","","","","","","","" }) //"Programa"//"Qtd.Benef"//"Setor"//"Titular/Dependente"
Else
	Aadd(aHdadoR, { STR0176, STR0177,STR0172,STR0173,STR0171,STR0169,STR0168,STR0167,STR0175,STR0174,STR0170,"",STR0178,"Risco"  })//"Dat.Alta."//"Dat.Insc."//"Dt.Elegibilidade."//"Empresa"//"Idade"//"Matricula"//"Nome"//"Plano"//"Prof. Saude"//"Programa"//"Setor"//"Tipo"
Endif

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Chama a Impressão do Relatorio                                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nLin:=PRO02Graf01(aDados,aHdadoR,nLin,nHeiPag,.t.,oGraphic,.T.,cTitulo2,.T.)

TRBBA1->( dbCloseArea() )
Return(nLin)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PRO02Rel10 ºAutor  ³Saude           º Data ³  12/17/12   	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Profissional de Acompanhamento	                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PRO02Rel10(nLin,nHeiPag)
Local cFiltro		:=""
Local aDados		:={}
Local n				:=1
Local cArq			:= "PRO02" + CriaTrab(NIL,.F.) + ".JPEG"
Local cTitulo2		:="Profissional de Acompanhamento"
Local cProgram		:=""
Local cMatvi		:=""
Local cGraf		:="Rel09"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selects ...             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cModRel==1
	cFiltro := Rpro02Sele()
	cFiltro += "BOM.BOM_MEDRSP"
	
Else
	cFiltro +=" SELECT     BOA.BOA_CODPRO,BOA.BOA_DESPRO,BD1.BD1_CODLOC,BD1.BD1_DESLOC,BOM.BOM_MEDRSP ,"
	cFiltro +="                       COUNT(BOM.BOM_VIDA) QTDVIDA
Endif

cFiltro += "  FROM "+RetSqlName("BOM")+ " BOM "
cFiltro +=Rpro02Sql()
cFiltro += "  LEFT JOIN  "+RetSqlName("BD1")+" BD1 ON BOM.BOM_CODLOC = BD1.BD1_CODLOC  AND BD1.BD1_FILIAL = '" + xFilial("BD1") + "' AND BD1.D_E_L_E_T_ = ' '"
cFiltro += "  INNER JOIN "+RetSqlName("BOA")+" BOA ON BOA.BOA_CODPRO = BOM.BOM_CODPRO AND BOA.BOA_FILIAL = '" + xFilial("BOA") + "'   AND BOA.D_E_L_E_T_ = ' ' "
cFiltro +=		" AND  BOA.BOA_ATIVO = '1'   "
cFiltro += 	" WHERE  BOM.BOM_DTINSC >= '"+DTOS(cDataI) +"'	  AND BOM.BOM_DTINSC <= '"+DTOS(cDataF)+"' "
If  !EMPTY(cProgAte)
	cFiltro += 	" AND BOA.BOA_CODPRO >= '"+cProgDe+"'	AND BOA.BOA_CODPRO <= '"+cProgAte+"' "
Endif
If !Empty(cSetorAte)
	cFiltro += 	" AND BOM.BOM_CODLOC >= '"+cSetorDe+"' AND BOM.BOM_CODLOC <= '"+cSetorAte+"'	 "
Endif
cFiltro +=	" 	AND BOM.BOM_STATUS  IN  ( '2','1','4','3') "
cFiltro += 	" AND BOM.D_E_L_E_T_ = ' '	"

If cModRel==2
	cFiltro +=" GROUP BY BOA.BOA_CODPRO,BOA.BOA_DESPRO,BD1.BD1_CODLOC,BD1.BD1_DESLOC,BOM.BOM_MEDRSP"
	cFiltro +=" ORDER BY BOA.BOA_CODPRO"
Else
	cFiltro +=" ORDER BY BOA.BOA_CODPRO,"
	cFiltro += " BD1.BD1_CODLOC,BI3.BI3_CODIGO,BA1.BA1_CODEMP"
Endif


cFiltro	:= ChangeQuery(cFiltro)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cFiltro),"TRBCRM",.T.,.F.)

DbSelectArea("TRBCRM")


If Eof()
	TRBCRM->( dbCloseArea() )
	return(nLin)
endif


TRBCRM->( dbGotop() )

While !TRBCRM->(Eof())
	If cModRel==2
		Aadd(aDados, { TRBCRM->BOA_CODPRO+'-'+SUBSTR(TRBCRM->BOA_DESPRO,1,40),TRBCRM->BD1_CODLOC+'-'+SUBSTR(TRBCRM->BD1_DESLOC,1,40),"",TRBCRM->BOM_MEDRSP+'-'+Substr(HS_IniPadr('SRA', 11, TRBCRM->BOM_MEDRSP, 'RA_NOME'),1,15),"",TRBCRM->QTDVIDA,"","","","","","","","","" })
		
	ElseIf cModRel ==1 .and. (cMatvi<>TRBCRM->BOM_VIDA .or. (cMatvi==TRBCRM->BOM_VIDA .and. cProgram<>TRBCRM->BOA_CODPRO))
		Aadd(aDados, { TRBCRM->BOA_CODPRO+"-"+TRBCRM->BOA_DESPRO, TRBCRM->BD1_CODLOC+"-"+TRBCRM->BD1_DESLOC,TRBCRM->CARTEIRA,TRBCRM->BOM_VIDA+"-"+Substr(TRBCRM->BOM_NOME,1,20),HS_A58Age(stod(TRBCRM->BA1_DATNAS)), Iif(!Empty(TRBCRM->BOM_DTELEG),stod(TRBCRM->BOM_DTELEG),""),Iif(!Empty(TRBCRM->BOM_DTINSC),stod(TRBCRM->BOM_DTINSC),""),Iif(!Empty(TRBCRM->BOM_DATALT),stod(TRBCRM->BOM_DATALT),""),TRBCRM->BOM_MEDRSP+'-'+Substr(HS_IniPadr('SRA', 11, TRBCRM->BOM_MEDRSP, 'RA_NOME'),1,15),TRBCRM->BI3_CODIGO+'-'+TRBCRM->BI3_DESCRI,TRBCRM->BA1_CODEMP+'-'+Pro02BusEm("TRBCRM"),"",TRBCRM->BOM_GRARIS+Posicione('BOB',2,xFilial('BOB')+TRBCRM->BOM_GRARIS+TRBCRM->BOA_CODPRO,'BOB_RISCO'),""})
	Endif
	cProgram:=TRBCRM->BOA_CODPRO
	
	If cModRel ==1
		cMatvi:=TRBCRM->BOM_VIDA
	Endif
	
	TRBCRM->(DbSkip())
	
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da Função para montar a Serie do Grafico     ³
//³ aDados : array com as informaçoes do Select 			³
//³	Posicao:Exemplo 5, onde está o Valor a ser exibido	³
//³	na Serie Neste caso a Coluna QTDVIDA					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cModRel==2
	Pro02SetGr(aDados,6,cGraf)
Endif


aHdador:={}
If cModRel==2
	Aadd(aHdadoR, { STR0181,STR0183,"",STR0180,"", STR0182,"","","","","","","","","" }) //"Profissional da Saúde"//"Programa"//"Qtd.Benef"//"Setor"
	
Else
	Aadd(aHdadoR, { STR0193, STR0194,STR0189,STR0190,STR0188,STR0186,STR0185,STR0184,STR0192,STR0191,STR0187,"","Risco",""  })//"Dat.Alta."//"Dat.Insc."//"Dt.Elegibilidade."//"Empresa"//"Idade"//"Matricula"//"Nome"//"Plano"//"Prof. Saude"//"Programa"//"Setor"
	
Endif



/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Chama a Impressão do Relatorio                                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nLin:=PRO02Graf01(aDados,aHdadoR,nLin,nHeiPag,.t.,oGraphic,.T.,cTitulo2,.T.)

TRBCRM->( dbCloseArea() )
Return(nLin)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PRO02Rel11 ºAutor  ³Saude           º Data ³  12/17/12   	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Elegiveis Identificados que foram Inscritos               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PRO02Rel11(nLin,nHeiPag)
Local cFiltro		:=""
Local aDados		:={}
Local n				:=1
Local cArq			:= "PRO02" + CriaTrab(NIL,.F.) + ".JPEG"
Local cTitulo2		:=STR0195//" Elegiveis Identificados que foram Inscritos "
Local cProgram		:=""
Local cMatvi		:=""
Local cGraf		:="Rel10"



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selects ...             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cModRel==1
	cFiltro := Rpro02Sele()
	cFiltro += "BOM.BOM_MEDRSP"
	
Else
	
	cFiltro +=" SELECT     BOA.BOA_CODPRO,BOA.BOA_DESPRO,BD1.BD1_CODLOC,BD1.BD1_DESLOC,"
	cFiltro +="                       COUNT(*) QTDVIDA
Endif


cFiltro += "  FROM "+RetSqlName("BOM")+ " BOM "
If cModRel==1
	cFiltro +=Rpro02Sql()
Endif
cFiltro += "  LEFT JOIN  "+RetSqlName("BD1")+" BD1 ON BOM.BOM_CODLOC = BD1.BD1_CODLOC  AND BD1.BD1_FILIAL = '" + xFilial("BD1") + "' AND BD1.D_E_L_E_T_ = ' '"
cFiltro += "  INNER JOIN "+RetSqlName("BOA")+" BOA ON BOA.BOA_CODPRO = BOM.BOM_CODPRO AND BOA.BOA_FILIAL = '" + xFilial("BOA") + "'   AND BOA.D_E_L_E_T_ = ' ' "
cFiltro += "  INNER JOIN "+RetSqlName("BOS")+" BOS ON BOS.BOS_CODPRO = BOM.BOM_CODPRO AND BOS.BOS_FILIAL = '" + xFilial("BOS") + "'   AND BOS.D_E_L_E_T_ = ' ' AND BOS.BOS_VIDA = BOM.BOM_VIDA "
cFiltro +=		" AND  BOA.BOA_ATIVO = '1'   "
cFiltro += 	" WHERE  BOM.BOM_DTINSC >= '"+DTOS(cDataI) +"'	  AND BOM.BOM_DTINSC <= '"+DTOS(cDataF)+"' "
If  !EMPTY(cProgAte)
	cFiltro += 	" AND BOA.BOA_CODPRO >= '"+cProgDe+"'	AND BOA.BOA_CODPRO <= '"+cProgAte+"' "
Endif
If !Empty(cSetorAte)
	cFiltro += 	" AND BOM.BOM_CODLOC >= '"+cSetorDe+"' AND BOM.BOM_CODLOC <= '"+cSetorAte+"'	 "
Endif
cFiltro += 	" AND BOM.BOM_STATUS = '1' "
cFiltro += 	" AND BOM.D_E_L_E_T_ = ' '	"

If cModRel==2
	cFiltro +=" GROUP BY BOA.BOA_CODPRO,BOA.BOA_DESPRO,BD1.BD1_CODLOC,BD1.BD1_DESLOC"
	cFiltro +=" ORDER BY BOA.BOA_CODPRO"
Else
	cFiltro +=" ORDER BY BOA.BOA_CODPRO,"
	cFiltro += " BD1.BD1_CODLOC,BI3.BI3_CODIGO,BA1.BA1_CODEMP"
Endif


cFiltro	:= ChangeQuery(cFiltro)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cFiltro),"TRBATIV",.T.,.F.)

DbSelectArea("TRBATIV")



If Eof()
	TRBATIV->( dbCloseArea() )
	return(nLin)
endif



TRBATIV->( dbGotop() )
While !TRBATIV->(Eof())
	If cModRel==2
		Aadd(aDados, { TRBATIV->BOA_CODPRO+'-'+SUBSTR(TRBATIV->BOA_DESPRO,1,40),TRBATIV->BD1_CODLOC+'-'+SUBSTR(TRBATIV->BD1_DESLOC,1,40),"",TRBATIV->QTDVIDA,"","","","","","","","","","" })
	ElseIf cModRel ==1 .and. (cMatvi<>TRBATIV->BOM_VIDA .or. (cMatvi==TRBATIV->BOM_VIDA .and. cProgram<>TRBATIV->BOA_CODPRO))
		Aadd(aDados, { TRBATIV->BOA_CODPRO+"-"+TRBATIV->BOA_DESPRO, TRBATIV->BD1_CODLOC+"-"+TRBATIV->BD1_DESLOC,TRBATIV->CARTEIRA,TRBATIV->BOM_VIDA+"-"+Substr(TRBATIV->BOM_NOME,1,20),HS_A58Age(stod(TRBATIV->BA1_DATNAS)),Iif(!Empty(TRBATIV->BOM_DTELEG),stod(TRBATIV->BOM_DTELEG),""),Iif(!Empty(TRBATIV->BOM_DTINSC),stod(TRBATIV->BOM_DTINSC),""),Iif(!Empty(TRBATIV->BOM_DATALT),stod(TRBATIV->BOM_DATALT),""),TRBATIV->BOM_MEDRSP+'-'+Substr(HS_IniPadr('SRA', 11, TRBATIV->BOM_MEDRSP, 'RA_NOME'),1,15),TRBATIV->BI3_CODIGO+'-'+TRBATIV->BI3_DESCRI,TRBATIV->BA1_CODEMP+'-'+Pro02BusEm("TRBATIV"),"",TRBATIV->BOM_GRARIS+Posicione('BOB',2,xFilial('BOB')+TRBATIV->BOM_GRARIS+TRBATIV->BOA_CODPRO,'BOB_RISCO'),""})
	Endif
	
	cProgram:=TRBATIV->BOA_CODPRO
	
	If cModRel ==1
		cMatvi:=TRBATIV->BOM_VIDA
	Endif
	
	TRBATIV->(DbSkip())
	
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da Função para montar a Serie do Grafico     ³
//³ aDados : array com as informaçoes do Select 			³
//³	Posicao:Exemplo 5, onde está o Valor a ser exibido	³
//³	na Serie Neste caso a Coluna QTDVIDA					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cModRel==2
	Pro02SetGr(aDados,4,cGraf)
Endif


aHdador:={}
If  cModRel==2
	Aadd(aHdadoR, { STR0197,STR0198,"",STR0196,"", "","","","","","","","","" }) //"Elegiveis Identificados"//"Programa"//"Setor"
	
Else
	Aadd(aHdadoR, { STR0208, STR0209,STR0204,STR0205,STR0203,STR0201,STR0200,STR0199,STR0207,STR0206,STR0202,"","Risco",""  })//"Dat.Alta."//"Dat.Insc."//"Dt.Elegibilidade."//"Empresa"//"Idade"//"Matricula"//"Nome"//"Plano"//"Prof. Saude"//"Programa"//"Setor"
Endif

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Chama a Impressão do Relatorio                                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nLin:=PRO02Graf01(aDados,aHdadoR,nLin,nHeiPag,.t.,oGraphic,.T.,cTitulo2,.T.)

TRBATIV->( dbCloseArea() )
Return(nLin)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PRO02Rel12 ºAutor  ³Saude           º Data ³  12/17/12   	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Encaminhamento para Equipe                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PRO02Rel12(nLin,nHeiPag)
Local cFiltro		:=""
Local aDados		:={}
Local n				:=1
Local cArq			:= "PRO02" + CriaTrab(NIL,.F.) + ".JPEG"
Local cMotAlt		:= Space(TamSx3("BOM_MOTALT")[1])
Local cTitulo2		:=STR0277//" Encaminhamentos para Equipe "
Local cProgram		:=""
Local cMatvi		:=""
Local cGraf		:="Rel11"
Local nSoma		:=0


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selects ...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cFiltro := Rpro02Sele()
cFiltro += "GCH_DESPER,GFK_CODPER,GFK_RESCAR,	GFK_RESNUM, GFK_RESDAT"
cFiltro += "  FROM "+RetSqlName("BOM")+ " BOM "
cFiltro +=Rpro02Sql()
cFiltro += "  INNER JOIN "+RetSqlName("GBH")+" GBH ON GBH.GBH_MATVID = BOM.BOM_VIDA AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "'   AND GBH.D_E_L_E_T_ = ' ' "
cFiltro += "  LEFT JOIN  "+RetSqlName("BD1")+" BD1 ON BOM.BOM_CODLOC = BD1.BD1_CODLOC  AND BD1.BD1_FILIAL = '" + xFilial("BD1") + "' AND BD1.D_E_L_E_T_ = ' '"
cFiltro += "  INNER JOIN "+RetSqlName("BOA")+" BOA ON BOA.BOA_CODPRO = BOM.BOM_CODPRO AND BOA.BOA_FILIAL = '" + xFilial("BOA") + "'   AND BOA.D_E_L_E_T_ = ' ' "
cFiltro +=		" AND  BOA.BOA_ATIVO = '1'   "
cFiltro += "  INNER JOIN	"+RetSqlName("BOV")+" BOV ON BOA.BOA_CODPRO = BOV.BOV_CODPRO "
cFiltro += " 		AND BOV.BOV_FILIAL = '" + xFilial("BOV") + "' AND  BOV.D_E_L_E_T_ = ' '  "
cFiltro += "  INNER JOIN "+RetSqlName('GCH')+" GCH ON GCH_FILIAL = '" +xFilial('GCH')+ "' AND GCH.GCH_CODPER = BOV.BOV_CODPER AND GCH.D_E_L_E_T_ <> '*' "
cFiltro += "  INNER JOIN "+RetSqlName('GFU')+" GFU ON GFU_FILIAL = '" +xFilial('GFU')+ "' AND GFU_REGGER = GBH_CODPAC AND GFU.D_E_L_E_T_ <> '*' "
cFiltro += "  INNER JOIN "+RetSqlName('GFK')+" GFK ON GFK_FILIAL = '" +xFilial('GFK')+ "' AND GFK_CDANAM = GFU_CDANAM AND GFK.GFK_CODPER = BOV.BOV_CODPER  AND GFK.D_E_L_E_T_ <> '*' "
cFiltro += "   AND GFK_CODPER = '"+cPergEnc+"'"

cFiltro += 	" WHERE  BOM.BOM_DTINSC >= '"+DTOS(cDataI) +"'	  AND BOM.BOM_DTINSC <= '"+DTOS(cDataF)+"' "
If  !EMPTY(cProgAte)
	cFiltro += 	" AND BOA.BOA_CODPRO >= '"+cProgDe+"'	AND BOA.BOA_CODPRO <= '"+cProgAte+"' "
Endif
If !Empty(cSetorAte)
	cFiltro += 	" AND BOM.BOM_CODLOC >= '"+cSetorDe+"' AND BOM.BOM_CODLOC <= '"+cSetorAte+"'	 "
Endif
cFiltro += 	" AND BOM.D_E_L_E_T_ = ' '	"
cFiltro +=	" 	AND BOM.BOM_STATUS  IN  ( '2','1','4','3') "


If cModRel==2
	cFiltro +=" ORDER BY BOA.BOA_CODPRO,BOM.BOM_VIDA"
Else
	cFiltro +=" ORDER BY BOA.BOA_CODPRO,"
	cFiltro += " BD1.BD1_CODLOC,BI3.BI3_CODIGO,BA1.BA1_CODEMP,BOM.BOM_VIDA"
Endif


cFiltro	:= ChangeQuery(cFiltro)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cFiltro),"TRBALTA",.T.,.F.)

DbSelectArea("TRBALTA")

If Eof()
	TRBALTA->( dbCloseArea() )
	return(nLin)
endif

TRBALTA->( dbGotop() )
While !TRBALTA->(Eof())

	IF (cMatvi<>TRBALTA->BOM_VIDA .or. (cMatvi==TRBALTA->BOM_VIDA .and. cProgram<>TRBALTA->BOA_CODPRO))
		If !Empty(TRBALTA->GFK_RESDAT) .or. 	!Empty(TRBALTA->GFK_RESNUM) .or. 		!Empty(TRBALTA->GFK_RESCAR)
			nSoma:=nSoma+1
		Endif
		
		IF cModRel ==1
			Aadd(aDados, { TRBALTA->BOA_CODPRO+"-"+TRBALTA->BOA_DESPRO, TRBALTA->BD1_CODLOC+"-"+TRBALTA->BD1_DESLOC,TRBALTA->CARTEIRA,TRBALTA->BOM_VIDA+"-"+Substr(TRBALTA->BOM_NOME,1,20),HS_A58Age(stod(TRBALTA->BA1_DATNAS)),Iif(!Empty(TRBALTA->BOM_DTELEG),stod(TRBALTA->BOM_DTELEG),""),Iif(!Empty(TRBALTA->BOM_DTINSC),stod(TRBALTA->BOM_DTINSC),""),Iif(!Empty(TRBALTA->BOM_DATALT),stod(TRBALTA->BOM_DATALT),""),Substr(HS_IniPadr('SRA', 11, TRBALTA->BOM_MEDRSP, 'RA_NOME'),1,10),TRBALTA->BI3_CODIGO+'-'+TRBALTA->BI3_DESCRI,TRBALTA->BA1_CODEMP+'-'+Pro02BusEm("TRBALTA"),Substr(alltrim(TRBALTA->GCH_DESPER),1,10),IIf(!Empty(TRBALTA->GFK_RESCAR),alltrim(TRBALTA->GFK_RESCAR),IIF(!EMPTY(TRBALTA->GFK_RESNUM),alltrim(TRBALTA->GFK_RESNUM),(stod(TRBALTA->GFK_RESDAT)))),TRBALTA->BOM_GRARIS+Posicione('BOB',2,xFilial('BOB')+TRBALTA->BOM_GRARIS+TRBALTA->BOA_CODPRO,'BOB_RISCO')})
		Else
			Aadd(aDados, { TRBALTA->BOA_CODPRO+'-'+SUBSTR(TRBALTA->BOA_DESPRO,1,40),TRBALTA->BD1_CODLOC+'-'+SUBSTR(TRBALTA->BD1_DESLOC,1,40),"",TRBALTA->GCH_DESPER,"" ,nSoma,"","","","","","","","" })
			nSoma:=0
		Endif
	Endif
	
	cProgram:=TRBALTA->BOA_CODPRO
	cMatvi:=TRBALTA->BOM_VIDA
	TRBALTA->(DbSkip())
	
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da Função para montar a Serie do Grafico     ³
//³ aDados : array com as informaçoes do Select 			³
//³	Posicao:Exemplo 5, onde está o Valor a ser exibido	³
//³	na Serie Neste caso a Coluna QTDVIDA					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cModRel==2
	Pro02SetGr(aDados,6,cGraf)
Endif

aHdador:={}
If cModRel==2
	Aadd(aHdadoR, { STR0212, STR0214,"",STR0211,"",STR0213,"","","","","","","","" })//"Encaminhamento"//"Programa"//"Qtd.Benef"//"Setor"
	
Else
	Aadd(aHdadoR, { STR0225, STR0227,STR0220,STR0221,STR0219,STR0217,STR0216,STR0215,STR0224,STR0223,STR0218,STR0222,STR0226,"Risco"  })//"Dat.Alta."//"Dat.Insc."//"Dt.Elegibilidade."//"Empresa"//"Idade"//"Matricula"//"Nome"//"Perguntas"//"Plano"//"Prof. Saude"//"Programa"//"Resposta"//"Setor"
Endif

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Chama a Impressão do Relatorio                                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nLin:=PRO02Graf01(aDados,aHdadoR,nLin,nHeiPag,.t.,oGraphic,.T.,cTitulo2,.T.)

TRBALTA->( dbCloseArea() )
Return(nLin)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PRO02Rel13 ºAutor  ³Saude           º Data ³  12/17/12   	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Numero de Beneficiario por Especialidade medica           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PRO02Rel13(nLin,nHeiPag)
Local cFiltro		:=""
Local aDados		:={}
Local n				:=1
Local cArq			:= "PRO02" + CriaTrab(NIL,.F.) + ".JPEG"
Local cTitulo2		:=STR0228//"Numero de Beneficiario por Especialidade Médica"
Local cProgram		:=""
Local cMatvi		:=""
Local cGraf		:="Rel12"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selects ...             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cModRel==1
	cFiltro := Rpro02Sele()
	cFiltro += "GFR.GFR_DSESPE"
Else
	cFiltro +=" SELECT     BOA.BOA_CODPRO,BOA.BOA_DESPRO,BD1.BD1_CODLOC,BD1.BD1_DESLOC,GFR.GFR_DSESPE   ,"
	cFiltro +="                       COUNT(*) QTDVIDA
Endif

cFiltro += "  FROM "+RetSqlName("BOM")+ " BOM "
If cModRel==1
	cFiltro +=Rpro02Sql()
Endif
cFiltro += "  LEFT JOIN  "+RetSqlName("BD1")+" BD1 ON BOM.BOM_CODLOC = BD1.BD1_CODLOC  AND BD1.BD1_FILIAL = '" + xFilial("BD1") + "' AND BD1.D_E_L_E_T_ = ' '"
cFiltro += "  INNER JOIN "+RetSqlName("BOA")+" BOA ON BOA.BOA_CODPRO = BOM.BOM_CODPRO AND BOA.BOA_FILIAL = '" + xFilial("BOA") + "'   AND BOA.D_E_L_E_T_ = ' ' "
cFiltro +=		" AND  BOA.BOA_ATIVO = '1'   "
cFiltro += "  INNER JOIN "+RetSqlName("GBJ")+" GBJ ON GBJ_CRM = BOM_MEDRSP AND GBJ_FILIAL = '"+xFilial("GBJ")+"' AND GBJ.D_E_L_E_T_ =  ' ' "
cFiltro += "  INNER JOIN "+RetSqlName("GFR")+" GFR ON GFR_CDESPE = GBJ_ESPEC1 AND GFR_FILIAL = '"+xFilial("GFR")+"'  AND GFR.D_E_L_E_T_ = ' ' "
cFiltro += 	" WHERE  BOM.BOM_DTINSC >= '"+DTOS(cDataI) +"'	  AND BOM.BOM_DTINSC <= '"+DTOS(cDataF)+"' "
If !EMPTY(cProgAte)
	cFiltro += 	" AND BOA.BOA_CODPRO >= '"+cProgDe+"' AND BOA.BOA_CODPRO <= '"+cProgAte+"'	 "
Endif
If !Empty(cSetorAte)
	cFiltro += 	" AND BOM.BOM_CODLOC >= '"+cSetorDe+"' AND BOM.BOM_CODLOC <= '"+cSetorAte+"'	 "
Endif
cFiltro += 	" AND BOM.D_E_L_E_T_ = ' '	"
cFiltro += 	" AND BOM.BOM_STATUS = '1' "

If cModRel==2
	cFiltro +=" GROUP BY BOA.BOA_CODPRO,BOA.BOA_DESPRO,BD1.BD1_CODLOC,BD1.BD1_DESLOC,GFR.GFR_DSESPE "
	cFiltro +=" ORDER BY BOA.BOA_CODPRO"
Else
	cFiltro +=" ORDER BY BOA.BOA_CODPRO,"
	cFiltro += " BD1.BD1_CODLOC,BI3.BI3_CODIGO,BA1.BA1_CODEMP"
Endif



cFiltro	:= ChangeQuery(cFiltro)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cFiltro),"TRBBAQ",.T.,.F.)

DbSelectArea("TRBBAQ")



If Eof()
	TRBBAQ->( dbCloseArea() )
	return(nLin)
endif



TRBBAQ->( dbGotop() )
While !TRBBAQ->(Eof())
	
	If cModRel==2
		Aadd(aDados, { TRBBAQ->BOA_CODPRO+'-'+SUBSTR(TRBBAQ->BOA_DESPRO,1,20),"",TRBBAQ->BD1_CODLOC+'-'+SUBSTR(TRBBAQ->BD1_DESLOC,1,40),"",TRBBAQ->GFR_DSESPE ,"",TRBBAQ->QTDVIDA,"","","","","","","","" })
	ElseIf cModRel ==1 .and. (cMatvi<>TRBBAQ->BOM_VIDA .or. (cMatvi==TRBBAQ->BOM_VIDA .and. cProgram<>TRBBAQ->BOA_CODPRO))
		Aadd(aDados, { TRBBAQ->BOA_CODPRO+"-"+SUBSTR(TRBBAQ->BOA_DESPRO,1,20), TRBBAQ->BD1_CODLOC+"-"+TRBBAQ->BD1_DESLOC,TRBBAQ->CARTEIRA,TRBBAQ->BOM_VIDA+"-"+Substr(TRBBAQ->BOM_NOME,1,20),HS_A58Age(stod(TRBBAQ->BA1_DATNAS)),Iif(!Empty(TRBBAQ->BOM_DTELEG),stod(TRBBAQ->BOM_DTELEG),""),Iif(!Empty(TRBBAQ->BOM_DTINSC),stod(TRBBAQ->BOM_DTINSC),""),Iif(!Empty(TRBBAQ->BOM_DATALT),stod(TRBBAQ->BOM_DATALT),""),TRBBAQ->BOM_MEDRSP+'-'+Substr(HS_IniPadr('SRA', 11, TRBBAQ->BOM_MEDRSP, 'RA_NOME'),1,10),TRBBAQ->BI3_CODIGO+'-'+TRBBAQ->BI3_DESCRI,TRBBAQ->BA1_CODEMP+'-'+Pro02BusEm("TRBBAQ"),"",substr(TRBBAQ->GFR_DSESPE,1,10),TRBBAQ->BOM_GRARIS+Posicione('BOB',2,xFilial('BOB')+TRBBAQ->BOM_GRARIS+TRBBAQ->BOA_CODPRO,'BOB_RISCO')})
	Endif
	
	cProgram:=TRBBAQ->BOA_CODPRO
	
	If cModRel ==1
		cMatvi:=TRBBAQ->BOM_VIDA
	Endif
	
	TRBBAQ->(DbSkip())
	
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da Função para montar a Serie do Grafico     ³
//³ aDados : array com as informaçoes do Select 			³
//³	Posicao:Exemplo 5, onde está o Valor a ser exibido	³
//³	na Serie Neste caso a Coluna QTDVIDA					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cModRel==2
	Pro02SetGr(aDados,7,cGraf)
Endif

aHdador:={}
If cModRel==2
	Aadd(aHdadoR, { STR0230,"",STR0232,"",STR0229,"", STR0231,"","","","","","","" })//"Especialidade"//"Programa"//"Qtd.Benef"//"Setor"
	
Else
	Aadd(aHdadoR, { STR0243, STR0244,STR0239,STR0240,STR0238,STR0235,STR0234,STR0233,STR0242,STR0241,STR0236,"",STR0237,"Risco"  })//"Dat.Alta."//"Dat.Insc."//"Dt.Elegibilidade."//"Empresa"//"Especialidade"//"Idade"//"Matricula"//"Nome"//"Plano"//"Prof. Saude"//"Programa"//"Setor"
Endif


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Chama a Impressão do Relatorio                                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nLin:=PRO02Graf01(aDados,aHdadoR,nLin,nHeiPag,.t.,oGraphic,.T.,cTitulo2,.T.)

TRBBAQ->( dbCloseArea() )

Return(nLin)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PRO02Rel14 ºAutor  ³Saude           º Data ³  12/17/12   	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  "N° de beneficiários que estão em 2 ou mais programas "   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PRO02Rel14(nLin,nHeiPag)
Local cFiltro			:=""
Local aDados			:={}
Local n					:=1
Local cArq				:= "PRO02" + CriaTrab(NIL,.F.) + ".JPEG"
Local cTitulo2			:=STR0245//"N° de beneficiários que estão em 2 ou mais programas "
Local cProgram			:=""
Local cMatvi			:=""
Local cGraf				:=""

If cModRel==1
	Return(nLin)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selects ...             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cFiltro +=" SELECT     BOM.BOM_VIDA,"
cFiltro +="                       COUNT(*) QTDVIDA "
cFiltro += "  FROM "+RetSqlName("BOM")+ " BOM "
cFiltro += "  LEFT JOIN  "+RetSqlName("BD1")+" BD1 ON BOM.BOM_CODLOC = BD1.BD1_CODLOC  AND BD1.BD1_FILIAL = '" + xFilial("BD1") + "' AND BD1.D_E_L_E_T_ = ' '"
cFiltro += "  INNER JOIN "+RetSqlName("BOA")+" BOA ON BOA.BOA_CODPRO = BOM.BOM_CODPRO AND BOA.BOA_FILIAL = '" + xFilial("BOA") + "'   AND BOA.D_E_L_E_T_ = ' ' "
cFiltro +=		" AND  BOA.BOA_ATIVO = '1'   "
cFiltro += 	" WHERE  BOM.BOM_DTINSC >= '"+DTOS(cDataI) +"'	  AND BOM.BOM_DTINSC <= '"+DTOS(cDataF)+"' "
If !EMPTY(cProgAte)
	cFiltro += 	" AND BOA.BOA_CODPRO >= '"+cProgDe+"' AND BOA.BOA_CODPRO <= '"+cProgAte+"'	 "
Endif
If  !EMPTY(cSetorAte)
	cFiltro += 	" AND BOM.BOM_CODLOC >= '"+cSetorDe+"' AND BOM.BOM_CODLOC <= '"+cSetorAte+"'	 "
Endif
cFiltro += 	" AND BOM.D_E_L_E_T_ = ' '	"
cFiltro += 	" AND BOM.BOM_STATUS = '1' "

cFiltro +=" GROUP BY BOM.BOM_VIDA "
cFiltro +=" HAVING COUNT(*) >1 "
cFiltro +=" ORDER BY BOM.BOM_VIDA"

cFiltro	:= ChangeQuery(cFiltro)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cFiltro),"TRBDUPL",.T.,.F.)

DbSelectArea("TRBDUPL")



If Eof()
	TRBDUPL->( dbCloseArea() )
	return(nLin)
endif

DbSelectArea("BOM")
DbSetOrder(3)

TRBDUPL->( dbGotop() )
If !TRBDUPL->(Eof())
	While !TRBDUPL->(Eof())
		IF BOM->(DbSeek(xFilial("BOM")+TRBDUPL->BOM_VIDA)  )
			While !BOM->(Eof()) .and. TRBDUPL->BOM_VIDA == BOM->BOM_VIDA
				If BOM->BOM_STATUS == '1' .And. BOM->BOM_DTINSC >= cDataI .And. BOM->BOM_DTINSC <= cDataF
					Aadd(aDados, { BOM->BOM_CODPRO+"-"+SUBSTR(Posicione("BOA",1,xFilial("BOA")+BOM->BOM_CODPRO,"BOA_DESPRO"),1,40),"",BOM->BOM_VIDA,BOM->BOM_NOME,"","","","","","","","","" })
				EndIF
				BOM->(DbSkip())
			EndDo
		Endif
		
		
		
		TRBDUPL->(DbSkip())
		
	EndDo
Endif


aHdador:={}

Aadd(aHdadoR, { STR0247,"",STR0249, STR0246,"","","","","","","","","","" }) //"Nome"//"Programa"//"Setor"//"Vida"

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Chama a Impressão do Relatorio                                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nLin:=PRO02Graf01(aDados,aHdadoR,nLin,nHeiPag,.t.,oGraphic,.T.,cTitulo2,.T.,.F.)

TRBDUPL->( dbCloseArea() )
Return(nLin)






/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PRO02Rel15 ºAutor  ³Saude           º Data ³  12/17/12   	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Evolução por Programa                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PRO02Rel15(nLin,nHeiPag)

Local cFiltro:=""
Local aDados:={}
Local n:=1
Local cTitulo2:=STR0250//"Evolução por Programa"
Local nX:=0
Local cCodPer	:=""
Local cResCarP	:=""
Local cResCarI	:=""
Local cResCarF	:=""
Local cResNumP	:=""
Local cResNumI	:=""
Local cResNumF	:=""
Local CRESDTP	:=""
Local cResDtI	:=""
local aResNum	:={}
local aResCar	:={}
Local cVida	:=""
Local cCarteirap :=""
Local lRet1:=.T.
Local cGraf		:=""

If !cModRel==1
	Return(nLin)
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selects ...             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


cFiltro := Rpro02Sele()
cFiltro += "GFK_CODPER,GFK_RESCAR,	GFK_RESNUM, GFK_RESDAT,GFK_CDANAM, GFK_CDQUES, GFK_GRPPER,GCH_DESPER,BOV_CODPER,GFU_CDQUES,GCH_TIPPER"

cFiltro += "  FROM "+RetSqlName("BOA")+ " BOA "
cFiltro += "  INNER JOIN	"+RetSqlName("BOM")+" BOM ON BOA.BOA_CODPRO = BOM.BOM_CODPRO "
cFiltro += " 		AND BOM.BOM_FILIAL = '" + xFilial("BOM") + "' AND  BOM.D_E_L_E_T_ = ' '  "
cFiltro +=	" 		AND BOM.BOM_DTINSC >= '"+DTOS(cDataI) +"'	  AND BOM.BOM_DTINSC <= '"+DTOS(cDataF)+"' "
If  !EMPTY(cSetorAte)
	cFiltro += 	" AND BOM.BOM_CODLOC >= '"+cSetorDe+"' AND BOM.BOM_CODLOC <= '"+cSetorAte+"'	 "
Endif

cFiltro +=Rpro02Sql()
cFiltro += "  INNER JOIN "+RetSqlName("GBH")+" GBH ON GBH.GBH_MATVID = BOM.BOM_VIDA AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "'   AND GBH.D_E_L_E_T_ = ' ' "
cFiltro += "  INNER JOIN	"+RetSqlName("BOV")+" BOV ON BOA.BOA_CODPRO = BOV.BOV_CODPRO "
cFiltro += " 		AND BOV.BOV_FILIAL = '" + xFilial("BOV") + "' AND  BOV.D_E_L_E_T_ = ' '  "
cFiltro += "  INNER JOIN "+RetSqlName('GCH')+" GCH ON GCH_FILIAL = '" +xFilial('GCH')+ "' AND GCH.GCH_CODPER = BOV.BOV_CODPER AND GCH.D_E_L_E_T_ <> '*' "
cFiltro += "  INNER JOIN "+RetSqlName('GFU')+" GFU ON GFU_FILIAL = '" +xFilial('GFU')+ "' AND GFU_REGGER = GBH_CODPAC AND GFU.D_E_L_E_T_ <> '*' "
cFiltro += "  INNER JOIN "+RetSqlName('GFK')+" GFK ON GFK_FILIAL = '" +xFilial('GFK')+ "' AND GFK_CDANAM = GFU_CDANAM AND GFK.GFK_CODPER = BOV.BOV_CODPER  AND GFK.D_E_L_E_T_ <> '*' "//
cFiltro += "  INNER JOIN "+RetSqlName('GCY')+" GCY ON GCY_FILIAL = '" +xFilial('GCY')+ "' AND GCY_REGATE = GFU_REGATE AND GCY.D_E_L_E_T_ <> '*' "
cFiltro += "  INNER JOIN	"+RetSqlName("BD1")+" BD1 ON BOM.BOM_CODLOC = BD1.BD1_CODLOC   "
cFiltro += "		AND BD1.BD1_FILIAL = '" + xFilial("BD1") + "' AND BD1.D_E_L_E_T_ = ' '"
cFiltro += "  WHERE  BOA.BOA_FILIAL = '" + xFilial("BOA") + "' AND  BOA.D_E_L_E_T_ = ' ' "
If !EMPTY(cProgAte)
	cFiltro += 	" AND BOA.BOA_CODPRO >= '"+cProgDe+"' AND BOA.BOA_CODPRO <= '"+cProgAte+"'	 "
Endif


cFiltro += "GROUP BY BOA.BOA_CODPRO,BOA.BOA_DESPRO,BD1.BD1_CODLOC,BD1.BD1_DESLOC,BOM.BOM_GRARIS,"

If AllTrim(TCGetDB()) $  "MSSQL"
	cFiltro += "BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO ,"
Else
	cFiltro += "BA1_CODINT||BA1_CODEMP||BA1_MATRIC||BA1_TIPREG||BA1_DIGITO ,"
Endif

cFiltro += " BOM.BOM_VIDA,BOM.BOM_NOME,BA1.BA1_DATNAS,BOM.BOM_DTELEG,BOM.BOM_DTINSC,BOM.BOM_DATALT,BOM.BOM_MEDRSP,"
cFiltro += " BI3.BI3_CODIGO,BI3.BI3_DESCRI,BA1.BA1_CODEMP,GFK_CODPER,GFK_RESCAR,GFK_RESNUM,GFK_RESDAT,GFK_CDANAM,"
cFiltro += " GFK_CDQUES,GFK_GRPPER,GCH_DESPER,BOV_CODPER,GFU_CDQUES,GCH_TIPPER,BA1_CODINT,BA1.BA1_CODEMP,"
cFiltro += " BA1.BA1_CODINT,BA1.BA1_CODEMP,BA1.BA1_CONEMP,BA1.BA1_VERCON,BA1.BA1_SUBCON,BA1.BA1_VERSUB"

cFiltro +=" ORDER BY BOA.BOA_CODPRO,"
cFiltro +=" BD1.BD1_CODLOC,BOM.BOM_VIDA,GFK_CODPER,GFK_CDANAM"

cFiltro	:= ChangeQuery(cFiltro)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cFiltro),"QRYITE",.T.,.F.)

DbSelectArea("QRYITE")


If Eof()
	QRYITE->( dbCloseArea() )
	return(nLin)
endif

QRYITE->( dbGotop() )

cVida:=Alltrim(QRYITE->BOM_VIDA)

While !QRYITE->(EOF())
	cResNumP	:= QRYITE->GFK_RESNUM
	cResNumI	:= QRYITE->GFK_RESNUM
	cResCarP	:= QRYITE->GFK_RESCAR
	cResCarI	:= QRYITE->GFK_RESCAR
	cCodPer 	:=QRYITE->BOV_CODPER

	If cResNumF <> cResNumI .And.  cVida== Alltrim(QRYITE->BOM_VIDA) .and. !Empty(cResNumI)
		AADD(aResNum, {cResNumP,cResNumI})
	Endif
	
	If cResCarF <> cResCarI .And.  cVida== Alltrim(QRYITE->BOM_VIDA) .and. !Empty(cResCarI)
		AADD(aResCar, {cResCarP,cResCarI})
	Endif
	
	If Alltrim(cCodPer) == Alltrim(QRYITE->BOV_CODPER)
		cResNumI := QRYITE->GFK_RESNUM
		cResCarI := QRYITE->GFK_RESCAR
		
		if cVida<>Alltrim(QRYITE->BOM_VIDA) .or. lRet1
			For nX := 1 To Len(aResNum)
				If nX == Len(aResNum) .And. nX > 1
					cResNumF := aResNum[nX][2]
				EndIf
			Next nX
			
			For nX := 1 To Len(aResCar)
				If nX == Len(aResCar) .And. nX > 1
					cResCarF := aResCar[nX][2]
				EndIf
			Next nX
			
			Aadd(aDados, { QRYITE->BOA_CODPRO+'-'+QRYITE->BOA_DESPRO ,QRYITE->BD1_CODLOC+'-'+QRYITE->BD1_DESLOC, QRYITE->CARTEIRA ,Substr(QRYITE->BOM_NOME,1,10),HS_A58Age(stod(QRYITE->BA1_DATNAS)),Iif(!Empty(QRYITE->BOM_DTELEG),stod(QRYITE->BOM_DTELEG),""),Iif(!Empty(QRYITE->BOM_DTINSC),stod(QRYITE->BOM_DTINSC),""),substr(QRYITE->GCH_DESPER,1,10),iIf(!Empty(cResNumF),cResNumF,"N/I "),QRYITE->BA1_CODEMP+'-'+Pro02BusEm("QRYITE") ,QRYITE->BI3_CODIGO+'-'+QRYITE->BI3_DESCRI,iIf(!Empty(cResNumP),cResNumP,"N/I  "),cResCarP,cResCarF})//cResDtI, cResDtP
			aResNum:={}
			cVida		:=Alltrim(QRYITE->BOM_VIDA)
			cCodPer		:= QRYITE->BOV_CODPER
			cResNumP	:= QRYITE->GFK_RESNUM
			cResNumI	:= QRYITE->GFK_RESNUM
			cResNumF	:=	""
			cResCarP	:= QRYITE->GFK_RESCAR
			cResCarI	:= QRYITE->GFK_RESCAR
			cResCarF	:=	""
			lRet1		:=.F.
		EndIf
	Endif
	
	QRYITE->(dbSkip())
EndDo

QRYITE->(DbCloseArea())

aHdadoR:={}
Aadd(aHdadoR, { STR0258, STR0261,STR0254,STR0255,STR0253,STR0251,STR0256,STR0260,"R.Num Ini","R.Num Fin",STR0252,"R.Letr.Ini","R.Letr.Fin",""  })//"Dt.Elegibilidade."//"Empresa"//"Idade"//"Matricula"//"Nome"//"Pergunta."//"Plano"//"Programa"//"Resp.Final"//"Resp.Inic."//"Setor"


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Chama a Impressão do Relatorio                                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nLin:=PRO02Graf01(aDados,aHdadoR,nLin,nHeiPag,.t.,oGraphic,.t.,cTitulo2,.T.,.F.)

Return(nLin)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ Ro02Cons  ³ Autor ³                      ³ Data ³ 05.12.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Calculo do Numero de Consulta Total Realizada para os Progr³±±
±±³amas da Promoção a Saude       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/


Static Function Ro02Cons(cDataI,cDataF)
Local nTotCon		:=0
Local aArea		:= getArea()

Default cDataI		:=""
Default cDataF		:=""


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selects ...             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiltro := " Select COUNT(BD6.BD6_CODPRO) QTDPROC "
cFiltro += "  FROM "+RetSqlName("BOA")+ " BOA "
cFiltro += " 	INNER JOIN "+RetSqlName("BOM")+" BOM ON BOA.BOA_CODPRO = BOM.BOM_CODPRO "
cFiltro += "  		AND BOM.BOM_DTINSC >= '"+DTOS(cDataI) +"'	  AND BOM.BOM_DTINSC <= '"+DTOS(cDataF)+"' "
cFiltro += " 		AND BOM.BOM_FILIAL = '" + xFilial("BOM") + "'  AND BOM.D_E_L_E_T_ = ' ' "
cFiltro += " 	INNER JOIN "+RetSqlName("BD6")+" BD6 ON BOM.BOM_VIDA = BD6.BD6_MATVID "
cFiltro += " 		AND BD6.BD6_DATPRO >= '"+DTOS(cDataI) +"'	  AND BD6.BD6_DATPRO <= '"+DTOS(cDataF)+"' "
cFiltro += "  		AND BD6.BD6_FILIAL = '" + xFilial("BD6") + "' "
cFiltro += " 		AND BD6.D_E_L_E_T_ = ' ' "
cFiltro += " 		AND BD6_CODOPE = '"+PlsIntPad()+"' " // Pra ficar um pouco mais rapido
cFiltro += " 		AND BD6.BD6_CODPRO = BOA.BOA_CONPAD "

cFiltro += " 		WHERE  BOA.D_E_L_E_T_ = ' '  "
cFiltro += "  		AND BOA.BOA_FILIAL = '" + xFilial("BOA") + "' "


cFiltro	:= ChangeQuery(cFiltro)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cFiltro),"TRBCON",.T.,.F.)

DbSelectArea("TRBCON")

nTotCon:=TRBCON->QTDPROC


If Eof()
	TRBCON->( dbCloseArea() )
	return(nLin)
endif


TRBCON->( dbCloseArea() )
RestArea(aArea)

Return(nTotCon)






/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSRO02CBX   ºAutor  ³Saude           º Data ³  06/19/12 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função que Monta a Janela de Pergunta para exibicao do F3  º±±
±±º          ³ Parametro MV_Par04                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Function PLSRO02CBX()
Local aArea   := getArea()
Local aHDados := {}
Local aCDados := {}
Local nCont   := 0
Local nOpca   := 0
Local nPos    := 0
Local cRet    := ""
Local cTitulo := STR0262//"Selecione os Relatórios para o filtro"
Local lMarca := .F.
Local ABUTTONS := {}

Aadd(aHDados, {"", "cMark", "@BMP" , 5, 0, ".F.", "", "C", "", "V" ,"" , "","","V"})
Aadd(aHDados, {STR0263, STR0264, "@!" , 1, 0, ".F.", "", "C", "", "V" ,"" , "","","V"}) //"Status"//"cStatus"
Aadd(aHDados, {STR0265, STR0266, "@!" , 40, 0, ".F.", "", "C", "", "V" ,"" , "","","V"})  //"Descrição"//"cDesc"
aAdd(aCDados,{"LBTIK","01",STR0267,.F.}) //"Ações Consolidadas (Nº Participantes) da Promoção da Saúde por Período"
aAdd(aCDados,{"LBTIK","02",STR0268,.F.}) //"Palestras Promoção da Saúde por Período"
aAdd(aCDados,{"LBTIK","03",STR0269,.F.}) //"Nº de Consultas Promoção da Saúde por Período"
aAdd(aCDados,{"LBTIK","04",STR0270,.F.}) //"Nº de Absenteismo Promoção da Saúde por Período"
aAdd(aCDados,{"LBTIK","05",STR0271,.F.}) //"Beneficiários Desligados dos Programas de Promoção da Saúde por Período"
aAdd(aCDados,{"LBTIK","06",STR0272,.F.}) //"Beneficiários Por Empresa"
aAdd(aCDados,{"LBTIK","07",STR0273,.F.}) //"Beneficiários Por Categoria"
aAdd(aCDados,{"LBTIK","08",STR0274,.F.}) //"Beneficiários Por Titularidade"
aAdd(aCDados,{"LBTIK","09","Profissional de Acompanhamento",.F.})
aAdd(aCDados,{"LBTIK","10",STR0276,.F.}) //"Elegiveis Identificados que foram Inscritos"
aAdd(aCDados,{"LBTIK","11",STR0277,.F.}) //"Encaminhamento para Equipe"
aAdd(aCDados,{"LBTIK","12",STR0278,.F.}) //"Numero de Beneficiario por Especialidade medica"
aAdd(aCDados,{"LBTIK","13",STR0279,.F.}) //"N° de beneficiários que estão em 2 ou mais programas "
aAdd(aCDados,{"LBTIK","14","Evolução por Programa ",.F.})

DEFINE MSDIALOG oDlgStatus TITLE cTitulo From 000, 000 To 280, 550 Of oMainWnd Pixel

oGdStatus := MsNewGetDados():New(000, 000, 300, 300,0,,,,,,,,,, oDlgStatus, aHDados, aCDados)
oGdStatus:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGdStatus:oBrowse:blDblClick:= {|| PLSRO02STA(oGdStatus) } //Marca os Relatorios
aAdd(aButtons, {"CHECKED", {|| FS_MarcT(lMarca, oGdStatus), lMarca := !lMarca}, "Todos", "Marca/Desmarca Todos"})

ACTIVATE MSDIALOG oDlgStatus CENTERED ON INIT EnchoiceBar(oDlgStatus, {||nOpca := 1, oDlgStatus:End()}, {|| nOpca := 0, oDlgStatus:End()},, aButtons)


If nOpca == 1
	cRet := ""
	For nCont := 1 to Len(oGdStatus:aCols)
		If oGdStatus:aCols[nCont, 1] == "LBTIK"
			cRet += IIF(Empty(cRet),"","/")+AllTrim(oGdStatus:aCols[nCont, 2])
		EndIf
	Next
EndIf

__RtStusRo02 := cRet
RestArea(aArea)
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSR22RCB ºAutor  ³Saude           º Data ³  06/19/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorno dos Campos selecionados na Consulta F3 do Parametro º±±
±±º          ³MV_Par04                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP     	                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSRO02RCB()
&(Readvar()) := __RtStusRo02
Return(.T.)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  PLSR22STA  ºAutor  ³Saude           º Data ³  06/19/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Marca e Desmarca  os Campos da Consulta F3                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PLSRO02STA(oObj, nPos)
Default nPos := 1

If oObj:aCols[oObj:nAt, nPos] == "LBTIK"
	oObj:aCols[oObj:nAt, nPos] := "LBNO"
Else
	oObj:aCols[oObj:nAt, nPos] := "LBTIK"
EndIf



Return(nil)




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ GeraSX1  ³ Autor ³ Segmento Saude        ³ Data ³ 11.09.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao do SX1 - Perguntas       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao Saúde                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraSX1()
Local aArea 	:= GetArea()
Local aRegs 	:= {}
Local i	  		:= 0
Local j     	:= 0
Local nJ		:=0
Local nI		:=0
Local lInclui	:= .F.
Local aHelpPor	:= {}
Local aHelpSpa	:= {}
Local aHelpEng	:= {}
Local cTexto    := ''
Local aAreaDic := SX1->( GetArea() )

// Cria grupo de perguntas PLRPRO02
cPerg 									:= PADR("PLRPRO02", Len(SX1->X1_GRUPO))
aRegs 									:= {}
AADD(aRegs,{cPerg,"01",STR0280,"                              ","                              ","MV_CH1","C",06,00,00,"G"," ","MV_PAR01       ","               ","               ","               ","                                                            ","               ","               ","               ","               "," ","               ","               ","               ","               "," ","               ","               ","               ","               "," ","               ","               ","               ","          "," ","BOA   "," ","   ","              ","@                                       ","      "})//"Programa de ?                    "
AADD(aRegs,{cPerg,"02",STR0281,"                              ","                              ","MV_CH2","C",06,00,00,"G"," ","MV_PAR02       ","               ","               ","               ","                                                            ","               ","               ","               ","               "," ","               ","               ","               ","               "," ","               ","               ","               ","               "," ","               ","               ","               ","          "," ","BOA   "," ","   ","              ","@                                       ","      "})//"Programa ate?                    "
AADD(aRegs,{cPerg,"03",STR0282,"                              ","                              ","MV_CH3","C",03,00,00,"G"," ","MV_PAR03       ","               ","               ","               ","                                                            ","               ","               ","               ","               "," ","               ","               ","               ","               "," ","               ","               ","               ","               "," ","               ","               ","               ","          "," ","BD1PLS"," ","   ","              ","@                                       ","      "})//"Setor de ?                       "
AADD(aRegs,{cPerg,"04",STR0283,"                              ","                              ","MV_CH4","C",03,00,00,"G"," ","MV_PAR04       ","               ","               ","               ","                                                            ","               ","               ","               ","               "," ","               ","               ","               ","               "," ","               ","               ","               ","               "," ","               ","               ","               ","          "," ","BD1PLS"," ","   ","              ","@                                       ","      "})//"Setor ate?                       "
AADD(aRegs,{cPerg,"05",STR0284,"                              ","                              ","MV_CH5","D",08,00,00,"G"," ","MV_PAR05       ","               ","               ","               ","                                                            ","               ","               ","               ","               "," ","               ","               ","               ","               "," ","               ","               ","               ","               "," ","               ","               ","               ","          "," ","      "," ","   ","              ","@D                                      ","      "})//"Data Inscr. De?             "
AADD(aRegs,{cPerg,"06",STR0285,"                              ","                              ","MV_CH6","D",08,00,00,"G"," ","MV_PAR06       ","               ","               ","               ","                                                            ","               ","               ","               ","               "," ","               ","               ","               ","               "," ","               ","               ","               ","               "," ","               ","               ","               ","          "," ","      "," ","   ","              ","@D                                      ","      "})//"Data Inscr. ate?            "
AADD(aRegs,{cPerg,"07",STR0286,"                              ","                              ","MV_CH7","C",40,00,00,"G"," ","MV_PAR07       ","               ","               ","               ","                                                            ","               ","               ","               ","               "," ","               ","               ","               ","               "," ","               ","               ","               ","               "," ","               ","               ","               ","          "," ","PRO02R"," ","   ","              ","@                                       ","      "})//"Relatorios?                 "
AADD(aRegs,{cPerg,"08",STR0287,"                              ","                              ","MV_CH8","C",01,00,01,"C"," ","MV_PAR08       ",STR0289,"               ","               "," ","               ",STR0288,"               ","               "," ","               ","               ","               ","               "," ","               ","               ","               ","               "," ","               ","               ","               ","          "," ","      "," ","   ","              ","                                        ","      "})//"Grafico?                      "//"Nao            "//"Sim            "
AADD(aRegs,{cPerg,"09",STR0290,"                              ","                              ","MV_CH9","C",01,00,01,"C"," ","MV_PAR09       ",STR0291,"               ","               "," ","               ",STR0292,"               ","               "," ","               ","               ","               ","               "," ","               ","               ","               ","               "," ","               ","               ","               ","          "," ","      "," ","   ","              ","                                        ","      "})//"Ana/Sint?                      "//"Analitico         "//"Sintetico      "
AADD(aRegs,{cPerg,"10",STR0294,"","","mv_chA","C",01,0,0,"C","","mv_par10",STR0293,"","","","","Linhas","","","","","","","","","","","","","","","","","","","","",""})//"Barras"//"Opcão Grafico ?"
AADD(aRegs,{cPerg,"11","Perg. Encam. ?","","","MV_CHA","C",06,00,00,"G","","MV_PAR11","      ","","","","","      ","","","","","     ","","","","","","","","","","","","","","GCH","","","","@",""})


dbSelectArea( "SX1" )
SX1->( dbSetOrder( 1 ) )

If SX1->( !dbSeek(aRegs[9,1]+Space(Len(SX1->X1_GRUPO)-Len(cPerg))+aRegs[9,2])) // Significa que a pergunta não existe.
	
	// Se a pergunta 9 não existe é porque o dicionario esta antigo. Então apago todas pra recriar com a nova estrutura.
	If SX1->( dbSeek(aRegs[1,1]+Space(Len(SX1->X1_GRUPO)-Len(cPerg))+aRegs[1,2]))
		While !SX1->( Eof() ) .and. Alltrim(SX1->X1_GRUPO) == cPerg
			SX1->( RecLock("SX1", .F.) )
			SX1->( dbDelete() )
			SX1->(MsUnlock())
			SX1->(dbSkip())
		Enddo
	Endif
	
	
	
	For i := 1 To Len(aRegs)
		lInclui := !dbSeek(cPerg + aRegs[i,2])
		RecLock("SX1", lInclui)
		For j := 1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
		
		aHelpPor := {} ; aHelpSpa := {} ; 	aHelpEng := {}
		IF i == 1
			AADD(aHelpPor,STR0295)//"Informe o Programa Inicial que"
			AADD(aHelpPor,STR0296)//" que será filtrado Geração do Relatorio"
		ELSEIF i==2
			AADD(aHelpPor,STR0297)//"Informe o Programa Final que"
			AADD(aHelpPor,STR0298)//" que será filtrado Geração do Relatorio"
		ELSEIF i==3
			AADD(aHelpPor,STR0299)//"Informe o Setor de Atendimento Inicial"
			AADD(aHelpPor,STR0300)//" que será filtrado na Geração do Relatorio"
		ELSEIF i==4
			AADD(aHelpPor,STR0301)//"Informe o Setor de Atendimento Final"
			AADD(aHelpPor,STR0302)//" que será filtrado na Geração do Relatorio"
			
		ELSEIF i==5
			AADD(aHelpPor,STR0303)//"Informe a Data Inscrição Inicial dos Pacientes  "
			AADD(aHelpPor,STR0304)//" que será filtrado na Geração do Relatorio"
		ELSEIF i==6
			AADD(aHelpPor,STR0305)//"Informe a Data Inscrição Final dos Pacientes"
			AADD(aHelpPor,STR0306)//" que será filtrado na Geração do Relatorio"
		ELSEIF i==7
			AADD(aHelpPor,STR0307)//"Informe os Relatorios que deverão parecer em Tela "
		ELSEIF i==8
			AADD(aHelpPor,STR0308)//"Informe se Deseja exibir os Graficos na Impressão"
			AADD(aHelpPor,STR0309)//"opção disponivel apenas para o Relatorio Sintetico "
		ELSEIF i==9
			AADD(aHelpPor,STR0310)//"Informe o Tipo de Relatorio que será exibido em Tela"
			AADD(aHelpPor,STR0311)//"Analitico ou Sintetico"
		ELSEIF i==10
			AADD(aHelpPor,"Informe a opção de Graficos")
			AADD(aHelpPor," que será exibido na Geração do Relatorio Sintetico")
		ELSEIF i==11
			AADD(aHelpPor,"Informe a Pergunta da Ananmnese")
			AADD(aHelpPor," que será filtrada para o Relatorio ")
			AADD(aHelpPor," 11-Encaminhamento para Equipe ")
		ENDIF
		PutSX1Help("P."+alltrim(cPerg)+strzero(i,2)+".",aHelpPor,aHelpEng,aHelpSpa)
		
		cTexto += IIf( aRegs[i,1] + aRegs[i,2] $ cTexto, "", aRegs[i,1] + aRegs[i,2] + "\")
		
	Next
	
Endif
RestArea( aAreaDic )
RestArea( aArea )

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ProrCab  ³ Autor ³ Segmento Saude        ³ Data ³ 11.09.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta Cabeçalho dos Relatorios							       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao Saúde                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProrCab(nLin , nHeiPag,nLenPag,cTitulo,cTitulo2)
Default  nHeiPag:=0
Default  nLin:=0
Default nLenPag:=0
Default cTitulo:=""
Default cTitulo2:=""

If nLin >= nHeiPag
	If !lStPag
		oPrn:EndPage()
	EndIf
	oPrn:StartPage()
	lStPag := .F.
EndIf
nLin :=  FS_CabGraf(oPrn, nLenPag, "PLSRPRO02", 0800, cTitulo)
nLin += nEntreLin
nLin += nEntreLin
oPrn:Say(nLin, nMargX+500, STR0312 + cTitulo2, oFontBody1, 100)//"Relatorio "
nLin += nEntreLin

If cModRel==1
	nLin += 2 * nEntreLin
	oPrn:Say(nLin, nMargX+0000, aHdadoR[1][3], oFontBody3, 100)
	oPrn:Say(nLin, nMargX+nPosi, aHdadoR[1][4], oFontBody3, 100)
	oPrn:Say(nLin, nMargX+0857, aHdadoR[1][5], oFontBody3, 100)
	oPrn:Say(nLin, nMargX+1070, aHdadoR[1][6], oFontBody3, 100)
	oPrn:Say(nLin, nMargX+1340, aHdadoR[1][7], oFontBody3, 100)
	oPrn:Say(nLin, nMargX+1540, aHdadoR[1][8], oFontBody3, 100)
	oPrn:Say(nLin, nMargX+1740, aHdadoR[1][9], oFontBody3, 100)
	oPrn:Say(nLin, nMargX+1950, aHdadoR[1][12], oFontBody3, 100)
	oPrn:Say(nLin, nMargX+2170, aHdadoR[1][13], oFontBody3, 100)
	oPrn:Say(nLin, nMargX+2570, aHdadoR[1][14], oFontBody3, 100)
	nLin += nEntreLin
	oPrn:Line(nLin, nColStart, nLin,  nColEnd)
	
Else
	nLin += 2 * nEntreLin
	oPrn:Say(nLin, nMargX+0000, aHdadoR[1][1], oFontBody3, 100)
	oPrn:Say(nLin, nMargX+nPosi, aHdadoR[1][2], oFontBody3, 100)
	oPrn:Say(nLin, nMargX+0957, aHdadoR[1][3], oFontBody3, 100)
	oPrn:Say(nLin, nMargX+1070, aHdadoR[1][4], oFontBody3, 100)
	oPrn:Say(nLin, nMargX+1440, aHdadoR[1][5], oFontBody3, 100)
	oPrn:Say(nLin, nMargX+1740, aHdadoR[1][6], oFontBody3, 100)
	oPrn:Say(nLin, nMargX+1940, aHdadoR[1][7], oFontBody3, 100)
	nLin += nEntreLin
	oPrn:Line(nLin, nColStart, nLin,  nColEnd)
	
Endif


nLin += 2 * nEntreLin

Return(nLin)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Rpro02Sql  ³ Autor ³ Segmento Saude        ³ Data ³ 11.09.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Query comum entre os Relarotios						       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao Saúde                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function  Rpro02Sql()
Local cFiltSql		:=""

cFiltSql := "  INNER JOIN "+RetSqlName("BA1")+" BA1  ON BOM.BOM_VIDA = BA1.BA1_MATVID AND BA1.BA1_FILIAL = '" + xFilial("BA1") + "' AND BA1.BA1_DATBLO = ' ' AND BA1.D_E_L_E_T_ = ' ' "
cFiltSql += "  INNER JOIN "+RetSqlName("BA3")+" BA3  ON BA3.BA3_CODINT = BA1.BA1_CODINT AND BA3.BA3_CODEMP = BA1.BA1_CODEMP AND BA3.BA3_MATRIC = BA1.BA1_MATRIC  AND BA3.BA3_FILIAL = '" + xFilial("BA3") + "'   AND BA3.D_E_L_E_T_ = ' ' "
cFiltSql += "  INNER JOIN "+RetSqlName("BI3")+" BI3  ON BA3.BA3_CODINT = BI3.BI3_CODINT AND BA3.BA3_CODPLA = BI3.BI3_CODIGO AND "
cFiltSql +="						  BI3.BI3_FILIAL = '" + xFilial("BI3") + "'   AND BI3.D_E_L_E_T_ = ' ' "

Return(cFiltSql)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Rpro02Sele ³ Autor ³ Segmento Saude      ³ Data ³ 11.09.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Select comum dos Relatorios							       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao Saúde                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function  Rpro02Sele()
Local cFiltSql		:=""
cFiltSql := " SELECT DISTINCT BOA.BOA_CODPRO,BOA.BOA_DESPRO, BD1.BD1_CODLOC,BD1.BD1_DESLOC,"

If AllTrim(TCGetDB()) $  "MSSQL"
	cFiltSql += "BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO CARTEIRA,"
Else
	cFiltSql += "BA1_CODINT||BA1_CODEMP||BA1_MATRIC||BA1_TIPREG||BA1_DIGITO CARTEIRA,"
Endif

cFiltSql += "BOM.BOM_VIDA,BOM.BOM_NOME,BA1.BA1_DATNAS,BOM.BOM_DTELEG,"
cFiltSql += "BOM.BOM_DTINSC,BOM.BOM_DATALT,BOM.BOM_MEDRSP,BI3.BI3_CODIGO,BI3.BI3_DESCRI,BA1.BA1_CODINT,BA1.BA1_CODEMP,BA1.BA1_CONEMP,BA1.BA1_VERCON,BA1.BA1_SUBCON,BA1.BA1_VERSUB,BOM_GRARIS,"

Return(cFiltSql)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±±±±±±±±±±±±±
±±³Funcao    ³Pro02SetGr³ Autor ³Função para Adicionar as Series 	   ³ Data ³19/09/2014³±±
no Relatorio de Graficos
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±±±±±±±±±±±±±
±±³Descricao ³ParametroA :Array de Dados com a Informação a ser exibido no Grafico  	³±±
±±        	ParametroB :Array de Dados com a Posição do Valor que será exibido no Grafico³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±±±±±±±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Static Function Pro02SetGr(aDados,nPosVal,cGraf)
Local aArea 	:= GetArea()
Local cProgram		:=""
Local cPrograPos	:=""
Local nj,ni		:=0
Local nValor		:=0
Local cMatvi		:=""
Local aColors	:={}
Local n:=1


oGraphic := TMSGraphic():New( 25,05,,,,RGB(239,239,239),375,210)
nSerie := oGraphic:CreateSerie(  IIf( nTipo == 1, GRP_BAR, GRP_LINE   )    )
oGraphic:l3D := .T.
//AAdd( aColors,  CLR_HBLUE     )
AAdd( aColors,  CLR_CYAN      )

For ni:=1 to len(aDados)
	cProgram:=aDados[ni][1]
	If cProgram==cPrograPos
		loop
	Endif
	For nj :=1 to len(aDados)
		If cProgram==aDados[nj][1]
			nValor+= aDados[nj][nPosVal]
		Else
			Loop
		Endif
	Next nj
	oGraphic:Add(nSerie, nValor, substr(cProgram,1,6), RGB(50, 80, 120) )
	nValor		:=0
	cPrograPos	:=cProgram
	If n==1
   		n:=2
   	Else
		n:=1
	Endif
next ni

cBmpName := cGraf+".JPEG"


lSucesso := oGraphic:saveToImage(cBmpName,cRaizServer)


RestArea( aArea )
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Pro02BusEm ³ Autor ³ Segmento Saude      ³ Data ³ 11.09.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Busca Empresa/Familia							       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao Saúde                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Pro02BusEm(cArqTrab)
Local cEmpresa:=""

cEmpresa:=substr(Posicione("BQC",1,xFilial("BQC")+(cArqTrab)->BA1_CODINT+(cArqTrab)->BA1_CODEMP+(cArqTrab)->BA1_CONEMP+(cArqTrab)->BA1_VERCON+(cArqTrab)->BA1_SUBCON+(cArqTrab)->BA1_VERSUB,"BQC_DESCRI"),1,30)
If Empty(cEmpresa)
	cEmpresa:=substr( Posicione("BG9",1,xFilial("BG9")+(cArqTrab)->(BA1_CODINT)+(cArqTrab)->(BA1_CODEMP),"BG9_DESCRI"),1,30)
Endif
Return(cEmpresa)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FS_MarcT ³ Autor ³ Segmento Saude      ³ Data ³ 11.09.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca/Desmarca Tudo							       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao Saúde                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Static Function FS_MarcT(lMarca, oObj, aPos)

Local nForCols := 0
Local nContFor := 0
Local cMarcT   := IIF(lMarca, "LBTIK", "LBNO")

Default aPos := {1}

For nForCols := 1 To Len(oObj:aCols)
	For nContFor := 1 To Len(aPos)
		oObj:aCols[nForCols, aPos[nContFor]] := cMarcT
	Next
Next

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_CabGrafºAutor  ³                    º Data ³  28/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressão de cabeçalho gráfico                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ FS_CabGraf(oTMSPinter, nLenPag, cNomeFunct, nColTit,      º±±
±±º          ³             cTitulo)                                      º±±
±±º          ³ oTMSPrinter -> Objeto TMSPrinte instanciado.               º±±
±±º          ³ nLenPag     -> Largura da Página.                          º±±
±±º          ³ cNomeFunct  -> Nome do programa.                           º±±
±±º          ³ nColTit     -> Coluna onde o título do relatório será      º±±
±±º          ³                impresso.                                   º±±
±±º          ³ cTitulo     -> Título do relatório.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/



Static Function FS_CabGraf(oPrn, nLenPag, cNomeFunc, nColTit, cTitulo)
Local cEmpLogo   := ""

Local nLin1      := 0100
Local nLin2      := 0150
Local nLin3      := 0170
Local nLinTit    := 0180

Local nColStart  := 0050
Local nColEnd    := 3000 - 0050

Local oCabFont1  := TFont():New("Courier New", 13, 11,, .T.,,,,,.F.) //cTitulos dos Relatório
Local oCabFont2  := TFont():New("Courier New", 11, 09,, .F.,,,,,.F.) //Adendos Cabeçalho

Default nColTit    := 0800

oPrn:Line(0000, nColStart, 0000,  nColEnd)

cEmpLogo := "system\lgrl" + Lower(Iif( FindFunction("FWGRPCompany"),FWGRPCompany(), SM0->M0_CODIGO )   ) + ".bmp"
If File(cEmpLogo)
	oPrn:SayBitmap(nLin1-40, nColStart, cEmpLogo, 0300, 0080)
Else
	oPrn:Say(nLin1, nColStart,Iif( FindFunction("FWGRPCompany"),AllTrim(FWFilialName(FWGrpCompany(),FWCodFil(),2)), SM0->M0_CODIGO )+ Iif( FindFunction("FWFilialName"), FWFilialName(),SM0->M0_NOME), oCabFont2, 100)
EndIf

oPrn:Say(nLin2, nColStart, "SIGA/" + AllTrim(cNomeFunc) + "/v." + cVersao, oCabFont2, 100)
oPrn:Say(nLin3, nColStart, Time(), oCabFont2, 100)

oPrn:Say(nLinTit, nColTit, cTitulo, oCabFont1, 100)

oPrn:Say(nLin1, nColEnd-380, Padl("Página: " + AllTrim(Str(m_pag++)), 20), oCabFont2, 100) //"Página: "
oPrn:Say(nLin2, nColEnd-380, Padl("Dt. Ref.: " + DToC(dDataBase), 20), oCabFont2, 100) //"Dt. Ref.: "
oPrn:Say(nLin3, nColEnd-380, Padl("Emissão: " + DToC(Date()), 20), oCabFont2, 100) //"Emissão: "
oPrn:Line(0200, nColStart, 00200,  nColEnd)

Return 0250
