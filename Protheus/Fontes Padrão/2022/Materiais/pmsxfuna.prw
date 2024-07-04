#include "Protheus.CH"
#include "PMSXFUNA.CH"
#include "DBTREE.CH"
#include "AP5MAIL.CH"
#include "pmsicons.ch"
#include "mproject.ch"
#INCLUDE "FWLIBVERSION.CH"

#define SIM_TABELA 1
#define SIM_TAREFA 2
#define SIM_START  3
#define SIM_HORAI  4
#define SIM_FINISH 5
#define SIM_HORAF  6
#define SIM_HDURAC 7
#define SIM_HUTEIS 8
#define SIM_NIVEL  9
#define SIM_DTATUI 10
#define SIM_DTATUF 11
#define SIM_RECNO  12

STATIC aHeadAFNCQ := {}
STATIC aChkExc    := {}
Static lAF2ValIt
Static lAF5ValIt
Static lAF2ValUti
Static lAF5ValUti
Static lMsgUnica:=IsIntegTop()//verifica se o pms esta integrado com outras marcas via msgunica
STATIC lAltRec
STATIC lPMGRAFV := ExistBlock("PMGRAFV")
STATIC lPMSGAFA := ExistBlock("PMSGAFA")
STATIC lAF9_HRATUI
STATIC lAF9_HRATUF
STATIC lAFC_HRATUI
STATIC lAFC_HRATUF
Static __lTopConn	:= IfDefTopCTB()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSRpr   ³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que executa a reprogramacao do projeto.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA200                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSRpr(oTree,cRevisa,cArquivo)

Local aRet
Local lContinua := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o evento de alteracao no Fase atual.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !PmsVldFase("AF8",AF8->AF8_PROJET,"11")
	lContinua := .F.
EndIf

If lContinua .And. ParamBox({	{3,STR0027, 1, {STR0028,STR0029}, 50 , "" ,.F. } ,;  //"Reprogramar"###"Pelo Inicio"###"Pelo Fim"
								{1,STR0030, PMS_EMPTY_DATE, "" ,"","","", 55 ,.T.},;
							  	{ 1, STR0178, Space(LEN(AE8->AE8_RECURS))		  ,"@!" 	 ,""  ,"AE8" ,"" ,65 ,.F. };  //"Recurso de"
								,{ 1, STR0179, Replicate("Z",LEN(AE8->AE8_RECURS)) ,"@!" 	 ,""  ,"AE8" ,"" ,65 ,.F. };  //"Recurso ate"
							    ,{ 1, STR0180,Space(LEN(AE8->AE8_EQUIP))		  ,"@!" 	 ,""  ,"AED" ,"" ,65 ,.F. };
							    ,{ 1, STR0181,Replicate("Z",LEN(AE8->AE8_EQUIP)) ,"@!" 	 ,""  ,"AED" ,"" ,65 ,.F. };
					           ,{5,STR0200, .T., 160,,.F.};  // "Ignorar tarefas em execucao"
					           ,{5,STR0201, .F., 160,,.F.};  //"Ignorar tarefas nao atrasadas"
					           	},STR0012,@aRet) //"Data de Referencia" "Parametros"

	Processa({|| AF8CalcNew(AF8->(RecNo()),aRet[1],aRet[2],.T.,cRevisa,oTree,cArquivo,aRet[3],aRet[4],aRet[5],aRet[6],!aRet[7],aRet[8],.F.)},STR0031) //"Reprogramando Projeto..."
	Eval(bRefresh)
EndIf

PMS200Rev()

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSRprSim³ Autor ³ Bruno Sobieski         ³ Data ³ 01-06-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que executa a simulacao da reprogramacao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA200                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±PMS
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSRprSim(oTree,cRevisa,cArquivo)

Local aRet

If  ParamBox({	{1,STR0030,PMS_EMPTY_DATE, "" ,"","","", 55 ,.T.},;
				  	{ 1, STR0178, Space(LEN(AE8->AE8_RECURS))		  ,"@!" 	 ,""  ,"AE8" ,"" ,65 ,.F. };  //"Recurso de"
					,{ 1, STR0179, Replicate("Z",LEN(AE8->AE8_RECURS)) ,"@!" 	 ,""  ,"AE8" ,"" ,65 ,.F. };  //"Recurso ate"
				    ,{ 1, STR0180,Space(LEN(AE8->AE8_EQUIP))		  ,"@!" 	 ,""  ,"AED" ,"" ,65 ,.F. };
				    ,{ 1, STR0181,Replicate("Z",LEN(AE8->AE8_EQUIP)) ,"@!" 	 ,""  ,"AED" ,"" ,65 ,.F. };
		          ,{5,STR0200, .T., 160,,.F.};  // "Ignorar tarefas em execucao"
	   	       ,{5,STR0201, .F., 160,,.F.};  //"Ignorar tarefas nao atrasadas"
			        	},STR0012,@aRet) //"Data de Referencia" "Parametros"

	Processa({||    PmsAF8Simu(AF8->(RecNo()),1,aRet[1],.T.,cRevisa,oTree,cArquivo,aRet[2],aRet[3],aRet[4],aRet[5],!aRet[6],aRet[7])},STR0031) //"Reprogramando Projeto..."
	Eval(bRefresh)
EndIf


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsCalend ºAutor  ³Fabio Rogerio Pereiraº Data ³  26/03/02  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Transforma os dados binarios referente calendario do SH7    º±±
±±º          ³para o formato hora (hh:mm) e os retorna em um array        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPMS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsCalend(cCalend)
Local aArray  := {}
Local aRet    := {}
Local nTamanho:= 0
Local cAloc	  := ""
Local x		  := 0
Local y		  := 0
Local cAlias  := Alias()
Local nRecSH7 := SH7->(RecNo())
Local cHoraFim:= ""

dbSelectArea("SH7")
If ! MsSeek(xFilial("SH7")+cCalend)
	dbGoto(nRecSH7)
	dbSelectArea(cAlias)
	Return(aArray)
EndIf

cAloc    := Upper(SH7->H7_ALOC)
nTamanho := Len(cAloc) / 7

Aadd(aArray, "")
While Len(cAloc) > 0
    Aadd(aArray, SubStr(cAloc, 1, nTamanho) + " ")
    cAloc := SubStr(cAloc, nTamanho + 1)
End

If Len(aArray) >= 8
	aArray[1] := aArray[8]
	aDel(aArray, 8)
	aSize(aArray, 7)
EndIf	

For x := 1 to Len(aArray)
	nPos1 := 0
	nPos2 := 0
	Aadd(aRet, {x})

	For y := 1 to Len(aArray[x])
		If SubStr(aArray[x], y, 1) == "X" .and. nPos1 = 0
			nPos1 := y
		ElseIf SubStr(aArray[x], y, 1) == " " .And. nPos1 # 0
			nPos2 := y
			If Len(aRet[Len(aRet)]) < 10
				Aadd(aRet[Len(aRet)], Bit2Tempo(nPos1-1))
				cHoraFim := PmsSec2Time(Secs(SubStr(Bit2Tempo(nPos2-1), 3) + ":00"))
				Aadd(aRet[Len(aRet)], cHoraFim)
			EndIf
			nPos1 := 0
		EndIf
	Next
	aSize(aRet[Len(aRet)], 11)
Next

dbGoto(nRecSH7)
dbSelectArea(cAlias)

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsSec2Time ºAutor  ³Fabio Rogerio Pereiraº Data ³  26/03/02 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Transforma de segundos para formato hora HH:MM:SS            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPMS                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PmsSec2Time( nSeconds )
Local cRet:= StrZero(Int(Mod(nSeconds / 3600, 24)), 4, 0) + ":" +;
	         StrZero(Int(Mod(nSeconds / 60, 60)), 2, 0)
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PmsDocPesq ³ Autor ³Fabio Rogerio Pereira ³ Data ³28/03/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a chamada da janela de pequisa                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PmsDocPesq()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PmsDocPesq(oTree,cOrcProj,cRevisa,cArquivo)
Local aResultado := {}
Local aListBox   := {{"","","",""}}
Local aOrdem     := {}
Local aArea      := GetArea()
Local aAreaACB   := ACB->(GetArea())
Local cKeyWord   := Space( 100 )
Local cDescri    := Space( 40 )
Local cObjeto    := Space( 200 )
Local cOrdem     := ""
Local lExata     := .F.
Local lKeyWord   := .F.
Local nPosList   := 0
Local nOpca      := 0
Local oDlg
Local oListBox
Local oBut1
Local oBut2
Local oBut3
Local oPesqExata
Local oOrdem

DEFAULT cOrcProj:= CriaVar("AF8_PROJET",.F.)
DEFAULT cRevisa := CriaVar("AF8_REVISA",.F.)

DEFINE MSDIALOG oDlg TITLE CCADASTRO FROM 09,0 TO 33.8,60 OF oMainWnd

	DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

	@  0, 0 BITMAP oBmp RESNAME BMP_PROJETOAP oF oDlg SIZE 30, 1000 NOBORDER WHEN .F. PIXEL ADJUST

	@ 03, 40 SAY STR0032 FONT oBold PIXEL //"Localizar conhecimento"

	@ 14, 30 TO 16 ,400 LABEL '' OF oDlg   PIXEL

	@ 25, 40 SAY STR0033 SIZE 40, 10    PIXEL   //"Objeto"
	@ 23, 85 MSGET oGetPesq3 VAR cObjeto PICTURE "@!" SIZE 80, 10 VALID .T. PIXEL

	@ 38, 40 SAY STR0019 SIZE 40, 10    PIXEL   //"Descricao"
	@ 36, 85 MSGET oGetPesq2 VAR cDescri PICTURE "@!" SIZE 80, 10 VALID .T. PIXEL

	@ 51, 40 SAY STR0034  SIZE 40, 10 PIXEL   //"Palavras chave"
	@ 49, 85 MSGET oGetPesq1 VAR cKeyWord PICTURE "@!" SIZE 80, 10 VALID .T. PIXEL

	aOrdem := { STR0035, STR0019 }   //"Ocorrencias""Descricao"

	@ 64, 40 SAY STR0036  SIZE 40, 10 PIXEL 	  //"Ordenar por"

	@ 62, 85 COMBOBOX oOrdem VAR cOrdem ITEMS aOrdem SIZE 80,10 OF oDlg PIXEL;
		ON CHANGE PmsDocSort( @aListBox, @oListBox, oOrdem:nAT)

	DEFINE SBUTTON oBut1 FROM 22, 202 TYPE 5 ACTION PmsDocFiltro( @aListBox, @oListBox, cKeyWord, cDescri, cObjeto,;
	 @aResultado, lExata, oOrdem, @lKeyWord, cOrcProj, cRevisa ) ENABLE of oDlg ONSTOP STR0037 //"Pesquisar"

	oListBox := TWBrowse():New( 81,40,490,80,,{STR0038},,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Objetos Localizados"
	oListBox:SetArray(aListBox)
	oListBox:bLine := { || {aListBox[oListBox:nAT,1]}}

	@ 168,40 CHECKBOX oPesqExata VAR lExata SIZE 60,8 PIXEL OF oDlg PROMPT STR0039 //"Pesquisa Exata"

	DEFINE SBUTTON oBut3 FROM 168, 169 TYPE 1 ACTION ( nOpca := 1, nPosList := oListBox:nAt, oDlg:End() )  ENABLE of oDlg
	DEFINE SBUTTON oBut2 FROM 168, 202 TYPE 2 ACTION ( nOpca := 0, oDlg:End() )  ENABLE of oDlg

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 1 .And. (Len(aListBox) > 0)
	PmsDocPos( @aListBox, nPosList, @oTree,cArquivo)
EndIf

ACB->( dbClearFilter() )
RestArea( aAreaACB )
RestArea( aArea )

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PmsDocFiltr³ Autor ³Fabio Rogerio Pereira ³ Data ³08/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a chamada da janela de pequisa                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PmsDocLocLz()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 -> Objeto ListBox                                    ³±±
±±³          ³ ExpC1 -> String com palavras-chave                         ³±±
±±³          ³ ExpC2 -> Descricao para pesquisa                           ³±±
±±³          ³ ExpC3 -> Objeto para pesquisa                              ³±±
±±³          ³ ExpA1 -> Array contendo os resultados da busca             ³±±
±±³          ³ ExpL1 -> Indica pesquisa exata                             ³±±
±±³          ³ ExpO2 -> Objeto Combobox ( Ordem )                         ³±±
±±³          ³ ExpL2 -> Indica se havia keyword                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PmsDocFiltro( aListBox, oListBox, cKeyWord, cDescri, cObjeto, aResult, lExata, oOrdem, lKeyWord, cOrcProj, cRevisa )
Local cFiltro  := ""
Local aObjs    := {}
Local lTcSrvType := TcSrvType() <> "AS/400"

//³Filtra o ACB com os objetos do projeto.³
If lTcSrvType
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Rotina para recuperacao de dados em SQL                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Identifica os conhecimentos que possuem pelo menos uma palavra chave   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasQry := CriaTrab( ,.F.)

	cQuery := 	"SELECT AC9_CODOBJ, AC9_FILENT, AC9_ENTIDA, AC9_CODENT FROM "  + RetSqlName( "AC9" ) + " AC9 "+;
	"WHERE AC9_CODENT LIKE '" + cOrcProj + "%' AND AC9_ENTIDA IN ('AF2','AF5','AF9','AFC') AND "+;
	"AC9.D_E_L_E_T_=' ' ORDER BY AC9_CODOBJ"

	cQuery := ChangeQuery( cQuery )

	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

	If Alias() == cAliasQry

		While !Eof()
			Aadd(aObjs,{AC9_CODOBJ,AC9_FILENT,AC9_ENTIDA,AC9_CODENT})
			dbSkip()
		End

	EndIf
Else


	dbSelectArea("AC9")
	dbSetOrder(1)
	dbGoTop()

	While !Eof()
		If (cOrcProj == Left(AC9->AC9_CODENT,TamSX3("AF8_PROJET")[1])) .And. (AC9->AC9_ENTIDA $ "AF2/AF5/AF9/AFC")
			Aadd(aObjs,{AC9->AC9_CODOBJ,AC9->AC9_FILENT,AC9->AC9_ENTIDA,AC9->AC9_CODENT})

			If (Len(aObjs) == 1)
				cFiltro:= 'ACB_CODOBJ $ "' + AC9->AC9_CODOBJ + "/"
			Else
				cFiltro+= AC9->AC9_CODOBJ + "/"
			EndIf
		EndIf
		dbSkip()
	End

	cFiltro:= IIf(Empty(cFiltro), "", cFiltro+'"')

	dbSelectArea("ACB")
	dbSetOrder(1)
	dbClearFilter()

	If !Empty(cFiltro)
		dbSetFilter({||&cFiltro},cFiltro)
	EndIf

	dbGoTop()

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua a pesquisa                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Processa( { || PmsDocLoc( cKeyWord, cDescri, cObjeto, @aResult, lExata, @lKeyWord, cOrcProj, cRevisa ) }, STR0040,STR0041,.F.)  //"Efetuando pesquisa..."###"Atencao"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta e ordena a listbox                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Processa( { || PmsDocShow(@aListBox, @oListBox, aResult, oOrdem:nAT, lKeyWord, aObjs, cOrcProj, cRevisa ) } , STR0042,STR0041,.F.) //"Classificando resultado...""Atencao"


Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PmsDocLoc  ³ Autor ³Fabio Rogerio Pereira ³ Data ³28/03/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Engine de busca do banco de conhecimentos                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 :=PmsDocLoclz(ExpC1,ExpC2,ExpC3,@ExpA1,ExpL1,ExpL2)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 -> .T.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 -> String com palavras-chave                         ³±±
±±³          ³ ExpC2 -> Descricao para pesquisa                           ³±±
±±³          ³ ExpC3 -> Objeto para pesquisa                              ³±±
±±³          ³ ExpA1 -> Array contendo os resultados da busca             ³±±
±±³          ³ ExpL1 -> Indica pesquisa exata                             ³±±
±±³          ³ ExpL2 -> Indica se havia keyword                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PmsDocLoc( cKeyWord, cDescri, cObjeto, aResult, lExata, lKeyWord, cOrcProj, cRevisa )

LOCAL aKeyWord    := {}
LOCAL aItem       := {}

LOCAL lAdicObj    := .F.

LOCAL nLoop       := 0
LOCAL nKeyCount   := 0

DEFAULT lKeyWord  := .F.
DEFAULT lExata    := .F.

aResult  := {}
aKeyWord := Ft340ExtKey( cKeyWord )

cDescri := AllTrim( cDescri )
cObjeto := AllTrim( cObjeto )

lKeyWord := !Empty( aKeyWord )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Rotina para recuperacao de dados em SQL                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Identifica os conhecimentos que possuem pelo menos uma palavra chave   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAliasQry := CriaTrab( ,.F.)

cQuery := ""
cQuery += "SELECT ACB_CODOBJ, ACB_DESCRI, ACB.R_E_C_N_O_ ACBRECNO "
If lKeyWord
	cQuery += ",ACC_CODOBJ,ACC_KEYWRD "
EndIf

cQuery += " FROM " + RetSqlName( "ACB" ) + " ACB "

If lKeyWord
	cQuery += "," + RetSqlName( "ACC" ) + " ACC "
EndIf

cQuery += "WHERE "
cQuery += "ACB_FILIAL='" + xFilial( "ACB" ) + "' AND "

If lKeyWord

	cQuery += "ACC_FILIAL='" + xFilial( "ACB" ) + "' AND "
	cQuery += "ACB_CODOBJ=ACC_CODOBJ AND ( "

	For nLoop := 1 To Len( aKeyWord )

		If nLoop > 1
			cQuery += " OR "
		EndIf

		If lExata
			cQuery += "ACC_KEYWRD='" + aKeyWord[ nLoop, 1 ] + "'"
		Else
			cQuery += "ACC_KEYWRD LIKE '%" + AllTrim( aKeyWord[ nLoop, 1 ] ) + "%'"
		EndIf
	Next nLoop

	cQuery += " ) AND "
	cQuery += "ACC.D_E_L_E_T_=' ' AND "

EndIf

If !Empty( cObjeto )
	If lExata
		cQuery += "ACB_OBJETO='" + cObjeto + "' AND "
	Else
		cQuery += "ACB_OBJETO LIKE '%" + AllTrim( cObjeto ) + "%' AND "
	EndIf
EndIf

If !Empty( cDescri )
	If lExata
		cQuery += "ACB_DESCRI='" + cDescri + "' AND "
	Else
		cQuery += "ACB_DESCRI LIKE '%" + AllTrim( cDescri ) + "%' AND "
	EndIf
EndIf

cQuery += 	"ACB_CODOBJ IN (SELECT AC9_CODOBJ FROM "  + RetSqlName( "AC9" ) + " AC9 "+;
"WHERE AC9_CODENT LIKE '" + cOrcProj + "%' AND AC9_ENTIDA IN ('AF2','AF5','AF9','AFC') ) AND "+;
"ACB.D_E_L_E_T_=' ' ORDER BY ACB_CODOBJ"

cQuery := ChangeQuery( cQuery )

dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

If Alias() == cAliasQry

	While !Eof()
		nKeyCount := 0
		If lKeyWord
			cCodObj := ACB_CODOBJ
			AEval( aKeyWord, { |x| x[2] := .F. } )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se este conhecimento possui todas as palavras chave           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nKeyCount := 0

			While !Eof() .And. ACB_CODOBJ == cCodObj
				If !Empty( nScan := AScan( aKeyWord, { |x| x[1] $ ACC_KEYWRD } ) )
					aKeyWord[ nScan, 2 ] := .T.
					nKeyCount++
				EndIf

				aItem := { Capital( Alltrim(ACB_DESCRI) ), ACB_CODOBJ, nKeyCount }
				dbSkip()

			EndDo

			lAdicObj := .T.

			For nLoop := 1 To Len( aKeyWord )
				If !aKeyWord[ nLoop, 2 ]
					lAdicObj := .F.
					Exit
				EndIf
			Next nLoop
		Else
			lAdicObj := .T.
			aItem := { Capital( Alltrim(ACB_DESCRI) ), ACB_CODOBJ, nKeyCount }
			dbSkip()
		EndIf

		If lAdicObj
			AAdd( aResult, aItem )
		EndIf

	EndDo

EndIf

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PmsDocShow ³ Autor ³Fabio Rogerio Pereira ³ Data ³28/03/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe e Ordena os resultados da pesquisa                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PmsDocShow( ExpO1, ExpA1, ExpO2 )                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 -> Objeto ListBox                                    ³±±
±±³          ³ ExpA1 -> Array os recnos dos conhecimentos                 ³±±
±±³          ³ ExpO2 -> Objeto combobox                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PmsDocShow( aListBox, oListBox, aResultado, nOrdem, lKeyWord, aObjs, cOrcProj, cRevisa )
Local nItem    := 0
Local nObj     := 0
Local cChave   := ""

CursorWait()

aListBox:= {}
For nItem:= 1 To Len(aResultado)
	For nObj:= 1 To Len(aObjs)
		If (aObjs[nObj,1] == aResultado[nItem,2])

			If (aObjs[nObj,3] $ "AF9/AFC")
				cChave:= aObjs[nObj,2] + Stuff(aObjs[nObj,4],Len(cOrcProj)+1,0,cRevisa)
			Else
				cChave:= aObjs[nObj,2] + aObjs[nObj,4]
			EndIf

			Aadd(aListbox,{aResultado[nItem,1] + " - " + Posicione(aObjs[nObj,3], 1, cChave, aObjs[nObj,3] + "_DESCRI"), cChave, aObjs[nObj,3], aObjs[nObj,1]})
		EndIf
	Next nObj
Next nItem

If (Len(aListBox) == 0)
	aListBox:= {{"","","",""}}
EndIf

PmsDocSort(@aListBox,@oListBox,nOrdem)

CursorArrow()

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PmsDocPos  ³ Autor ³Fabio Rogerio Pereira ³ Data ³28/03/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Posiciona no documento desejado                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PmsDocPos( ExpO1, ExpA1, ExpO2 )                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 -> Array os recnos dos conhecimentos                 ³±±
±±³          ³ ExpO1 -> Objeto ListBox                                    ³±±
±±³          ³ ExpO2 -> Objeto Tree                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PmsDocPos( aListBox, nObj, oTree,cArquivo )
Local cSeek		:= ""
Local lAchou	:=	.F.
Local nRecIni	:=	0
Local nLen

If !Empty(aListBox[nObj,1])
	dbSelectArea(aListBox[nObj,3])
	dbSetOrder(1)
	If aListBox[nObj,3] $ "AF1,AF2,AF5,ACB"
		nLen := Len(AF2->AF2_FILIAL + AF2->AF2_ORCAME + AF2->AF2_TAREFA)
	Else
		nLen := Len(AF9->AF9_FILIAL + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_TAREFA)
	EndIf
	If MsSeek(Substr(aListBox[nObj,2],1,nLen))
		If oTree == Nil
			nRecIni	:=	(cArquivo)->(Recno())
			(cArquivo)->(DbGoTop())
			While !(cArquivo)->(Eof()) .And. !lAchou
				If aListBox[nObj,3]==(cArquivo)->ALIAS .And. (aListBox[nObj,3])->(Recno()) == (cArquivo)->RECNO
					lAchou	:=	.T.
				Else
					(cArquivo)->(DbSkip())
				Endif
			EndDo
			If !lAchou
				(cArquivo)->(MsGoTo(nRecIni))
			Endif
		Else
			cSeek:= aListBox[nObj,3] + StrZero(Recno(),12)
			oTree:TreeSeek(cSeek)
			oTree:Refresh()
		Endif
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PmsDocSort ³ Autor ³Fabio Rogerio Pereira ³ Data ³28/03/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Indexa os documentos pela ordem desejada                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PmsDocSort( ExpO1, ExpA1, ExpO2 )                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 -> Array os recnos dos conhecimentos                 ³±±
±±³          ³ ExpO1 -> Objeto ListBox                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PmsDocSort( aListBox, oListBox, nOpc)
Local bSort    := { || .T. }

If nOpc == 1
	bSort := { |x,y| x[2] > y[2] }
ElseIf nOpc == 2
	bSort := { |x,y| x[1] < y[1] }
EndIf

aListBox:= ASort( aListBox, , , bSort )
oListBox:SetArray(aListBox)
oListBox:bLine := { || {aListBox[oListBox:nAT,1]}}
oListBox:Refresh()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsCfgCol  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Configuracao das colunas para exibicao da EDT/Tarefa na       ³±±
±±³          ³planilha.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 : Array com os parametros MV_PMSPLN? (SX6)              ³±±
±±³          ³ExpA2 : Array com os campos padroes                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PmsCfgCol(aMvPmsPln,aCamposExc,nOrcPrj)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local nCampos1
Local nCampos2
Local nPos1      := 0
Local nPos2      := 0
Local cAlias1
Local cAlias2
Local cPln1SX6
Local cPln2SX6
Local cCampoAux
Local aCampos1   := {}
Local aCampos2   := {}
Local aCamposA   := {}
Local aCamposB   := {}
Local aBtn       := Array(5)
Local oCampos1
Local oCampos2
Local oBtn1
Local oBtn2
Local lCampos1   := .T.
Local lCampos2   := .F.
Local nPosFunc   := 0
Local aFunc		 := {"HDURAC", "CALEND", "COMPOS", "EDTPAI", "CUSTO", "CUSTO2", "CUSTO3","CUSTO4", "CUSTO5", "GRPCOM", "TPMEDI", "ORDEM" , "PRIORI","QUANT", "UM"}
Local nCnt1		:= 0
Local nCnt2		:= 0

DEFAULT nOrcPrj  := 2

If nOrcPrj == 1
	DEFAULT aCamposExc := {"FILIAL","ORCAME","DESCRI","NIVEL","TAREFA","EDT"}
	cAlias1 := "AF2"
	cAlias2 := "AF5"
Else
	DEFAULT aCamposExc := {"FILIAL","PROJET","DESCRI","NIVEL","TAREFA","EDT","REVISA"}
	cAlias1 := "AF9"
	cAlias2 := "AFC"
Endif

nOrdSX3  := SX3->(IndexOrd())
nRegSX3  := SX3->(Recno())

cPln1SX6 := GetMv(aMvPmsPln[1])
cPln2SX6 := GetMv(aMvPmsPln[2])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do array de campos selecionados                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While At("#",cPln1SX6) <> 0
	nPosSep := At("#",cPln1SX6)
	aAdd(aCampos2,{,})
	aCampos2[Len(aCampos2),2] := AllTrim(Substr(cPln1Sx6,2,nPosSep-2))
	dbSelectArea("SX3")
	dbSetOrder(2)
	If MsSeek(cAlias1+"_"+aCampos2[Len(aCampos2),2])
		aCampos2[Len(aCampos2),1] := AllTrim(X3Descric())
	Else
		If MsSeek(cAlias2+"_"+aCampos2[Len(aCampos2),2])
			aCampos2[Len(aCampos2),1] := AllTrim(X3Descric())
		Endif
	Endif
	cPln1Sx6 := Substr(cPln1SX6,nPosSep+1,Len(cPln1SX6)-nPosSep)
End
While At("#",cPln2SX6) <> 0
	aAdd(aCampos2,{,})
	aCampos2[Len(aCampos2),2] := AllTrim(Substr(cPln2Sx6,2,nPosSep-2))
	dbSelectArea("SX3")
	dbSetOrder(2)
	If MsSeek(cAlias1+"_"+aCampos2[Len(aCampos2),2])
		aCampos2[Len(aCampos2),1] := AllTrim(X3Descric())
	Else
		If MsSeek(cAlias2+"_"+aCampos2[Len(aCampos2),2])
			aCampos2[Len(aCampos2),1] := AllTrim(X3Descric())
		Endif
	Endif
	cPln2Sx6 := Substr(cPln2SX6,nPosSep+1,Len(cPln2SX6)-nPosSep)
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do array de campos disponiveis                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
If (MsSeek(cAlias1))
	While SX3->X3_ARQUIVO == cAlias1
		If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
			cCampoAux := AllTrim(Substr(SX3->X3_CAMPO,5,6))

			nPosFunc := 0
			nPosFunc := aScan(aFunc,{|x| AllTrim(x)==AllTrim(cCampoAux)} )

			If nPosFunc > 0
				If Len(aCampos1) <> 0
					If  (nPosCampo := AScan(aCampos1,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
						(nPosCampo := AScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
						(nPosCampo := AScan(aCamposExc,cCampoAux)) == 0
						aAdd(aCampos1,{X3Descric(),cCampoAux})
					Endif
				Else
					If  (nPosCampo := AScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
						(nPosCampo := AScan(aCamposExc,cCampoAux)) == 0
						aAdd(aCampos1,{X3Descric(),cCampoAux})
					Endif
				Endif
			EndIf
		Endif
		dbSkip()
	End
Endif

If (MsSeek(cAlias2))
	While SX3->X3_ARQUIVO == cAlias2
		If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
			cCampoAux := AllTrim(Substr(SX3->X3_CAMPO,5,6))
			nPosFunc := 0
			nPosFunc := aScan(aFunc,{|x| AllTrim(x)==AllTrim(cCampoAux)} )

			If nPosFunc > 0
				If Len(aCampos1) <> 0
					If  (nPosCampo := AScan(aCampos1,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
						(nPosCampo := AScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
						(nPosCampo := AScan(aCamposExc,cCampoAux)) == 0
						aAdd(aCampos1,{X3Descric(),cCampoAux})
					Endif
				Else
					If  (nPosCampo := AScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
						(nPosCampo := AScan(aCamposExc,cCampoAux)) == 0
						aAdd(aCampos1,{X3Descric(),cCampoAux})
					Endif
				Endif
			EndIf
		Endif
		dbSkip()
	End
Endif
aSort(aCampos1,,, {|x,y| x[1] < y[1]})
aCampos3 := aClone(aCampos1)
aCampos4 := aClone(aCampos2)
aCamposA  := {}
aCamposB  := {}
For nCnt1 := 1 to Len(aCampos1)
	aAdd(aCamposA,aCampos1[nCnt1,1])
Next
For nCnt2 := 1 to Len(aCampos2)
	aAdd(aCamposB,aCampos2[nCnt2,1])
Next

DEFINE MSDIALOG oDlg1 FROM 00,00 TO 300,520 TITLE STR0043 PIXEL //"Selecione os campos"

@08,05  SAY STR0044  PIXEL OF oDlg1 //"Campos Disponiveis"
@08,143 SAY STR0045 PIXEL OF oDlg1 //"Campos Selecionados"
@45,240 SAY STR0046               PIXEL OF oDlg1 //"Mover"
@50,237 SAY STR0047              PIXEL OF oDlg1 //"Campos"

@16,05  LISTBOX oCampos1 VAR nCampos1 ITEMS aCamposA SIZE 90,110 ON DBLCLICK;
AddFields(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB,nPos1,nPos2) PIXEL OF oDlg1
oCampos1:SetArray(aCamposA)
oCampos1:bChange    := {|| nCampos2 := 0,nPos1:=oCampos1:nAT,oCampos2:Refresh(),lCampos1 := .T.,lCampos2 := .F.}
oCampos1:bGotFocus  := {|| lCampos1 := .T.,lCampos2 := .F.}

@16,143 LISTBOX oCampos2 VAR nCampos2 ITEMS aCamposB SIZE 90,110 ON DBLCLICK;
DelFields(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB,nPos1,nPos2) PIXEL OF oDlg1
oCampos2:SetArray(aCamposB)
oCampos2:bChange    := {|| nCampos1 := 0,nPos2:=oCampos2:nAT,oCampos1:Refresh(),lCampos1 := .F.,lCampos2 := .T.}
oCampos2:bGotFocus  := {|| lCampos1 := .F.,lCampos2 := .T.}

@16,98  BUTTON aBtn[1] PROMPT STR0048 SIZE 42,11 PIXEL; //" Add.Todos >>"
ACTION AddAllFld(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB)

@28,98  BUTTON aBtn[2] PROMPT STR0049 SIZE 42,11 PIXEL; //"&Adicionar >>"
ACTION AddFields(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB,nPos1,nPos2) WHEN lCampos1

@40,98  BUTTON aBtn[3] PROMPT STR0050  SIZE 42,11 PIXEL; //"<< &Remover "
ACTION DelFields(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB,nPos1,nPos2) WHEN lCampos2

@52,98  BUTTON aBtn[4] PROMPT STR0051  SIZE 42,11 PIXEL; //"<< Rem.Todos"
ACTION DelAllFld(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB)

@115,98 BUTTON aBtn[5] PROMPT STR0052  SIZE 42,11 PIXEL; //"  Restaurar "
ACTION RestFields(@aCampos1,oCampos1,@aCampos2,oCampos2,aCampos3,aCampos4,@aCamposA,@aCamposB)

@115,480 BTNBMP oBtn1 RESOURCE BMP_SETA_UP   SIZE 25,25 ACTION UpField(@aCampos2,oCampos2,@aCamposB,nPos2);
MESSAGE STR0053  WHEN lCampos2 //"Mover campo para cima"

@140,480 BTNBMP oBtn2 RESOURCE BMP_SETA_DOWN SIZE 25,25 ACTION DwField(@aCampos2,oCampos2,@aCamposB,nPos2);
MESSAGE STR0054 WHEN lCampos2 //"Mover campo para baixo"

DEFINE SBUTTON FROM 130,175 TYPE 1 ENABLE OF oDlg1 ACTION {|| GravaMvSX6(aCampos2,aMvPmsPln),oDlg1:End()}
DEFINE SBUTTON FROM 130,205 TYPE 2 ENABLE OF oDlg1 ACTION oDlg1:End()

ACTIVATE DIALOG oDlg1 CENTERED

dbSelectArea("SX3")
dbSetOrder(nOrdSX3)
dbGoTo(nRegSX3)

Return Nil



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AddFields  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move campo disponivel para array de campos selecionados       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function AddFields(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB,nPos1,nPos2)
Local nCnt1	:= 0
Local nCnt2	:= 0

If nPos1 <> 0 .And. Len(aCampos1) <> 0
	aAdd(aCampos2,{aCampos1[nPos1,1],aCampos1[nPos1,2]})
	aDel(aCampos1,nPos1)
	aSize(aCampos1,Len(aCampos1)-1)
	aSort(aCampos1,,, {|x,y| x[1] < y[1]})
	aCamposA  := {}
	aCamposB  := {}
	For nCnt1 := 1 to Len(aCampos1)
		aAdd(aCamposA,aCampos1[nCnt1,1])
	Next
	For nCnt2 := 1 to Len(aCampos2)
		aAdd(aCamposB,aCampos2[nCnt2,1])
	Next
	oCampos1:SetArray(aCamposA)
	oCampos1:nAt := 1
	oCampos1:Refresh()
	oCampos2:SetArray(aCamposB)
	oCampos2:Refresh()
	oCampos1:SetFocus()
Endif
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³DelFields  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move campo selecionados para array de campos disponiveis      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DelFields(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB,nPos1,nPos2)
Local nCnt1	:= 0
Local nCnt2	:= 0

If nPos2 <> 0 .And. Len(aCampos2) <> 0
	aAdd(aCampos1,{aCampos2[nPos2,1],aCampos2[nPos2,2]})
	aDel(aCampos2,nPos2)
	aSize(aCampos2,Len(aCampos2)-1)
	aSort(aCampos1,,, {|x,y| x[1] < y[1]})
	aCamposA  := {}
	aCamposB  := {}
	For nCnt1 := 1 to Len(aCampos1)
		aAdd(aCamposA,aCampos1[nCnt1,1])
	Next
	For nCnt2 := 1 to Len(aCampos2)
		aAdd(aCamposB,aCampos2[nCnt2,1])
	Next
	oCampos1:SetArray(aCamposA)
	oCampos1:Refresh()
	oCampos2:SetArray(aCamposB)
	oCampos2:nAt := 1
	oCampos2:Refresh()
	oCampos2:SetFocus()
Endif
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AddAllFld  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move todos os campos do array de campos disponiveis para      ³±±
±±³          ³array de campos selecionados.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function AddAllFld(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB)
Local nCnt1 := 0
Local nCnt2 := 0

If Len(aCampos1) <> 0
	For nCnt1 := 1 to Len(aCampos1)
		aAdd(aCampos2,{aCampos1[nCnt1,1],aCampos1[nCnt1,2]})
	Next
	aCampos1 := {}
	aCamposA := {}
	aSort(aCampos1,,, {|x,y| x[1] < y[1]})
	aCamposB  := {}
	For nCnt2 := 1 to Len(aCampos2)
		aAdd(aCamposB,aCampos2[nCnt2,1])
	Next
	oCampos1:SetArray(aCamposA)
	oCampos1:Refresh()
	oCampos2:SetArray(aCamposB)
	oCampos2:nAt := 1
	oCampos2:Refresh()
	oCampos2:SetFocus()
Endif
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³DelAllFld  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move todos os campos do array de campos selecionados para     ³±±
±±³          ³array de campos disponiveis.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DelAllFld(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB)
Local nCnt1 := 0

If Len(aCampos2) <> 0
	For nCnt1 := 1 to Len(aCampos2)
		aAdd(aCampos1,{aCampos2[nCnt1,1],aCampos2[nCnt1,2]})
	Next
	aCampos2 := {}
	aCamposB := {}
	aSort(aCampos1,,, {|x,y| x[1] < y[1]})
	aCamposA  := {}
	For nCnt1 := 1 to Len(aCampos1)
		aAdd(aCamposA,aCampos1[nCnt1,1])
	Next
	oCampos1:SetArray(aCamposA)
	oCampos1:nAt   := 1
	oCampos1:Refresh()
	oCampos2:SetArray(aCamposB)
	oCampos2:Refresh()
	oCampos1:SetFocus()
Endif
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³UpField    ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move o campo para uma posicao acima dentro do array           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function UpField(aCampos2,oCampos2,aCamposB,nPos2)

Local cCampoAux
Local nCnt2 	:= 0

If nPos2 <> 1 .And. nPos2 <> 0
	cCampoAux := aCampos2[nPos2-1,1]
	aCampos2[nPos2-1,1] := aCampos2[nPos2,1]
	aCampos2[nPos2,1] := cCampoAux
	cCampoAux := aCampos2[nPos2-1,2]
	aCampos2[nPos2-1,2] := aCampos2[nPos2,2]
	aCampos2[nPos2,2] := cCampoAux
	aCamposB  := {}
	For nCnt2 := 1 to Len(aCampos2)
		aAdd(aCamposB,aCampos2[nCnt2,1])
	Next
	oCampos2:SetArray(aCamposB)
	oCampos2:nAt:=nPos2-1
	oCampos2:Refresh()
Endif
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³UpField    ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move o campo para uma posicao abaixo dentro do array          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DwField(aCampos2,oCampos2,aCamposB,nPos2)

Local cCampoAux
Local nCnt2 	:= 0

If nPos2 < Len(aCampos2) .And. nPos2 <> 0
	cCampoAux := aCampos2[nPos2+1,1]
	aCampos2[nPos2+1,1] := aCampos2[nPos2,1]
	aCampos2[nPos2,1] := cCampoAux
	cCampoAux := aCampos2[nPos2+1,2]
	aCampos2[nPos2+1,2] := aCampos2[nPos2,2]
	aCampos2[nPos2,2] := cCampoAux
	aCamposB  := {}
	For nCnt2 := 1 to Len(aCampos2)
		aAdd(aCamposB,aCampos2[nCnt2,1])
	Next
	oCampos2:SetArray(aCamposB)
	oCampos2:nAt:=nPos2+1
	oCampos2:Refresh()
Endif
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RestFields ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Restaura arrays originais                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RestFields(aCampos1,oCampos1,aCampos2,oCampos2,aCampos3,aCampos4,aCamposA,aCamposB)
Local nCnt1 := 0
Local nCnt2 := 0

aCampos1  := aClone(aCampos3)
aCampos2  := aClone(aCampos4)
aSort(aCampos1,,, {|x,y| x[1] < y[1]})
aCamposA  := {}
aCamposB  := {}
For nCnt1 := 1 to Len(aCampos1)
	aAdd(aCamposA,aCampos1[nCnt1,1])
Next
For nCnt2 := 1 to Len(aCampos2)
	aAdd(aCamposB,aCampos2[nCnt2,1])
Next
oCampos1:SetArray(aCamposA)
oCampos2:SetArray(aCamposB)
If Len(aCampos1) > 0
	oCampos1:nAt := 1
	oCampos1:Refresh()
	oCampos1:SetFocus()
Else
	If Len(aCampos2) > 0
		oCampos2:nAt := 1
		oCampos2:Refresh()
		oCampos2:SetFocus()
	Else
		oCampos1:Refresh()
		oCampos2:Refresh()
	Endif
EndIf
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GravaMvSX6 ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os campos selecionados nos parametros MV_PMSPLN? (SX6)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function GravaMvSX6(aCampos2,aMvPmsPln)

Local nCntMv		:= 1
Local cMvFldPln		:= ""
Local nCntFields	:= 0

For nCntFields := 1 to Len(aCampos2)
	If Len(cMvFldPln) < 240
		cMvFldPln := cMvFldPln + ("_"+aCampos2[nCntFields,2]+"#")
	Else
		PutMv(aMvPmsPln[nCntMv],cMvFldPln)
		nCntMv++
	Endif
Next
PutMv(aMvPmsPln[nCntMv],cMvFldPln)
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsChangeQuery  ³ Autor ³Fabio Rogerio Pereira ³ Data ³ 18-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que analisa os operadores da query e executa a ChangeQuery. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                        	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsChangeQuery(cQuery)
Local nFor  := 0
Local nPos  := 0
Local nOper := 0
Local aOper := {}

Aadd(aOper, {PrefixoCpo(cAlias) + "_",	"?"} )
Aadd(aOper, {"==",						" = "} )
Aadd(aOper, {".OR.",						" OR "} )
Aadd(aOper, {".AND.",					" AND "} )
Aadd(aOper, {".NOT.",					" NOT "} )
Aadd(aOper, {".T.",						" TRUE "} )
Aadd(aOper, {".F.",						" FALSE "} )
Aadd(aOper, {"ALLTRIM(",					" "} )
Aadd(aOper, {"DTOS(",					" "} )
Aadd(aOper, {")",							" "} )
Aadd(aOper, {'"',							"'"} )


For nFor:= 1 To Len(cQuery)
	nOper:= IIf(nOper > 5,1,nOper+1)

	nPos:= AT(aOper[nOper,1],Upper(cQuery))
	If nPos > 0
		cQuery:= Stuff(cQuery,nPos,Len(aOper[nOper,1]),aOper[nOper,2])
	EndIf
Next

aOper := {}
Aadd(aOper, {"?", cAlias + "." + PrefixoCpo(cAlias) + "_"} )

For nFor := 1 To Len(cQuery)
	For nOper := 1 To Len(aOper)
		nPos:= AT(aOper[nOper,1],Upper(cQuery))
		If (nPos > 0)
			cQuery := Stuff(cQuery,nPos,Len(aOper[nOper,1]),aOper[nOper,2])
		EndIf
	Next nOper
Next nFor


cQuery:= ChangeQuery(Upper(cQuery))
// liberacao de memoria utilizado pelos arrays
aSize(aOper, 0)
aOper := NIL
Return(cQuery)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAF9CusTrf³Autor ³Fabio Rogerio Pereira  ³ Data ³ 09-05-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de calculo do custo da tarefa 							 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAF9CusTrf(nGet,cProjeto,cRevisa,cTarefa)
Local aArea    := GetArea()
Local nX       := 0
Local nCusto   := 0
Local nFerram  := 0
Local nPCod    := 0
Local nPItem   := 0
Local nPQuant  := 0
Local nPCustd  := 0
Local nPValor  := 0
Local nPCodR   := 0
Local nPQuantR := 0
Local nPCustdR := 0
Local nPMoedaP := 0
Local nPMoedaD := 0
Local nPMoedaR := 0
Local nPHrProd := 0
Local nPHrImpr := 0
Local nPCusPrd := 0
Local nPCusImp := 0
Local nPGrOrga := 0
Local nPDMT	   := 0
Local nPDMTD   := 0
Local nPTipoD  := ""
Local aColsPrd := {}
Local aColsDes := {}
Local aColsRec := {}
Local aColsIns := {}
Local aColsSub := {}
Local nQuantAFA:= 0
Local nValorAFB:= 0
Local cTrunca	 := "1"
Local aCusto 	:= {0,0,0,0,0}
Local aTX2M		:= {0,0,0,0,0}
Local dDtConv, cCnvPrv
Local lCompUnic := 0
Local cGrOrga
Local nDesp		:= 0
Local nSubComp	:= 0
Local nCustoA	:= 0
Local nCustoB	:= 0
Local nCustoE	:= 0
Local nCustoF	:= 0
Local nDecCst	:= TamSX3("AF9_CUSTO")[2]
Local nPCalcCst := 0
Local nPCalcCstR:= 0
Local cPmsCust := SuperGetMv("MV_PMSCUST",.F.,"1") //Indica se utiliza o custo pela quantidade unitaria ou total

DEFAULT nGet    := 0
DEFAULT cProjeto:= AF9->AF9_PROJET
DEFAULT cRevisa := AF9->AF9_REVISA
DEFAULT cTarefa := AF9->AF9_TAREFA

lCompUnic := AF8ComAJT(cProjeto)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se esta sendo chamado atraves de getdados ou nao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Type("aCols") == "A") .And. (Type("aHeader") == "A") .And. (nGet > 0)

	DbSelectArea("AF8")
	DbSetOrder(1)
	If (MSseek(XFILIAL("AF8")+M->AF9_PROJET))
		cTrunca:=AF8->AF8_TRUNCA
	EndIf

	dbSelectArea("AF9")
	aTX2M[1]:=1
	aTX2M[2]:=M->AF9_TXMO2
	aTX2M[3]:=M->AF9_TXMO3
	aTX2M[4]:=M->AF9_TXMO4
	aTX2M[5]:=M->AF9_TXMO5

	//
	// Se for uma tarefa de um projeto do padrão
	//
	If !lCompUnic
		If (nGet == 1) //getdados de produtos
			nPCod   := aScan(aHeader,{|x| AllTrim(x[2]) == "AFA_PRODUT"})
			nPQuant := aScan(aHeader,{|x| AllTrim(x[2]) == "AFA_QUANT"})
			nPCustd := aScan(aHeader,{|x| AllTrim(x[2]) == "AFA_CUSTD"})
			nPMoedaP:= aScan(aHeader,{|x| AllTrim(x[2]) == "AFA_MOEDA"})
			nPItem  := aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AFB_ITEM"})
			nPMoedaD:= aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AFB_MOEDA"})
			nPValor := aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AFB_VALOR"})
			nPCodR  := aScan(aHeaderSV[5],{|x| AllTrim(x[2]) == "AFA_PRODUT"})
			nPQuantR:= aScan(aHeaderSV[5],{|x| AllTrim(x[2]) == "AFA_QUANT"})
			nPCustdR:= aScan(aHeaderSV[5],{|x| AllTrim(x[2]) == "AFA_CUSTD"})
			nPMoedaR:= aScan(aHeaderSV[5],{|x| AllTrim(x[2]) == "AFA_MOEDA"})
			nPRec   := aScan(aHeaderSV[5],{|x| AllTrim(x[2]) == "AFA_RECURS"})
			nPCalcCst:= aScan(aHeader,{|x| AllTrim(x[2]) == "AFA_ACUMUL"})
			nPCalcCstR:= aScan(aHeaderSV[5],{|x| AllTrim(x[2]) == "AFA_ACUMUL"})

			aColsPrd:= aClone(aCols)
			aColsDes:= aClone(aColsSV[2])
			aColsRec:= aClone(aColsSV[5])

		ElseIf (nGet == 2) //Getdados de despesas

			nPItem  := aScan(aHeader,{|x| AllTrim(x[2]) == "AFB_ITEM"})
			nPValor := aScan(aHeader,{|x| AllTrim(x[2]) == "AFB_VALOR"})
			nPMoedaD:= aScan(aHeader,{|x| AllTrim(x[2]) == "AFB_MOEDA"})
			nPCod   := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AFA_PRODUT"})
			nPMoedaP:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AFA_MOEDA"})
			nPQuant := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AFA_QUANT"})
			nPCustd := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AFA_CUSTD"})
			nPCodR  := aScan(aHeaderSV[5],{|x| AllTrim(x[2]) == "AFA_PRODUT"})
			nPMoedaR:= aScan(aHeaderSV[5],{|x| AllTrim(x[2]) == "AFA_MOEDA"})
			nPQuantR:= aScan(aHeaderSV[5],{|x| AllTrim(x[2]) == "AFA_QUANT"})
			nPCustdR:= aScan(aHeaderSV[5],{|x| AllTrim(x[2]) == "AFA_CUSTD"})
			nPRec   := aScan(aHeaderSV[5],{|x| AllTrim(x[2]) == "AFA_RECURS"})
			nPCalcCst:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AFA_ACUMUL"})
			nPCalcCstR:= aScan(aHeaderSV[5],{|x| AllTrim(x[2]) == "AFA_ACUMUL"})

			aColsPrd:= aClone(aColsSV[1])
			aColsRec:= aClone(aColsSV[5])
			aColsDes:= aClone(aCols)

		ElseIf (nGet == 5) //Getdados de alocacao de recursos
			nPItem  := aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AFB_ITEM"})
			nPValor := aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AFB_VALOR"})
			nPMoedaD:= aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AFB_MOEDA"})
			nPCod   := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AFA_PRODUT"})
			nPMoedaP:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AFA_MOEDA"})
			nPQuant := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AFA_QUANT"})
			nPCustd := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AFA_CUSTD"})
			nPCodR  := aScan(aHeader,{|x| AllTrim(x[2]) == "AFA_PRODUT"})
			nPMoedaR:= aScan(aHeader,{|x| AllTrim(x[2]) == "AFA_MOEDA"})
			nPQuantR:= aScan(aHeader,{|x| AllTrim(x[2]) == "AFA_QUANT"})
			nPCustdR:= aScan(aHeader,{|x| AllTrim(x[2]) == "AFA_CUSTD"})
			nPRec   := aScan(aHeader,{|x| AllTrim(x[2]) == "AFA_RECURS"})
			nPCalcCst:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AFA_ACUMUL"})
			nPCalcCstR:= aScan(aHeader,{|x| AllTrim(x[2]) == "AFA_ACUMUL"})

			aColsPrd:= aClone(aColsSV[1])
			aColsDes:= aClone(aColsSV[2])
			aColsRec:= aClone(aCols)
		Else
			nPItem  := aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AFB_ITEM"})
			nPValor := aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AFB_VALOR"})
			nPMoedaD:= aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AFB_MOEDA"})
			nPCod   := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AFA_PRODUT"})
			nPMoedaP:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AFA_MOEDA"})
			nPQuant := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AFA_QUANT"})
			nPCustd := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AFA_CUSTD"})
			nPCodR  := aScan(aHeaderSV[5],{|x| AllTrim(x[2]) == "AFA_PRODUT"})
			nPMoedaR:= aScan(aHeaderSV[5],{|x| AllTrim(x[2]) == "AFA_MOEDA"})
			nPQuantR:= aScan(aHeaderSV[5],{|x| AllTrim(x[2]) == "AFA_QUANT"})
			nPCustdR:= aScan(aHeaderSV[5],{|x| AllTrim(x[2]) == "AFA_CUSTD"})
			nPRec   := aScan(aHeaderSV[5],{|x| AllTrim(x[2]) == "AFA_RECURS"})
			nPCalcCst:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AFA_ACUMUL"})
			nPCalcCstR:= aScan(aHeaderSV[5],{|x| AllTrim(x[2]) == "AFA_ACUMUL"})

			aColsPrd:= aClone(aColsSV[1])
			aColsDes:= aClone(aColsSV[2])
			aColsRec:= aClone(aColsSV[5])
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcula o custo dos produtos.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nPQuant > 0) .And. (nPCustd > 0)
			For nX:= 1 To Len(aColsPrd)
				If !aColsPrd[nX,Len(aColsPrd[nX])]
					nQuantAFA	:=  PmsAFAQuant(M->AF9_PROJET,M->AF9_REVISA,M->AF9_TAREFA,aColsPrd[nX,nPCod],M->AF9_QUANT,aColsPrd[nX,nPQuant],M->AF9_HDURAC,,"")
					PmsVerConv(@dDtConv,@cCnvPrv,,.T.)
				// Cronograma de consumo previsto dos produtos na tarefa
				If aColsPrd[nX ,nPCalcCst] == "7" .And. PmsAF8CstAjust(M->AF9_PROJET) $ '12' .AND. !Empty(aColsPrd[nX ,nPCod]) .AND. Len(aColsAEF1) > 0 .AND. !Empty(aColsAEF1[1,1])
					//
					// calcula o custo
					//
					nCusto := PmsAFACrnCon("P" ,nX , IIf(PmsAF8CstAjust(M->AF9_PROJET) == '1',dDataBase,Nil) ,M->AF9_QUANT ,aHeaderSV[1] ,aColsPrd)
					PmsConvCus(nCusto ,aColsPrd[nX,nPMoedaP],cCnvPrv,dDtConv,M->AF9_START,M->AF9_FINISH,aCusto,aTX2M,cTrunca,M->AF9_QUANT)
				Else
					nQuantAFA	:=  PmsAFAQuant(M->AF9_PROJET,M->AF9_REVISA,M->AF9_TAREFA,aColsPrd[nX,nPCod],M->AF9_QUANT,aColsPrd[nX,nPQuant],M->AF9_HDURAC,,"")
					PmsConvCus((aColsPrd[nX,nPCustd] * nQuantAFA),aColsPrd[nX,nPMoedaP],cCnvPrv,dDtConv,M->AF9_START,M->AF9_FINISH,aCusto,aTX2M,cTrunca,M->AF9_QUANT)
				EndIf
				EndIf
			Next nX
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcula o custo das despesas.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nPValor > 0)
			For nX:= 1 To Len(aColsDes)
				If !aColsDes[nX,Len(aColsDes[nX])]
					nValorAFB:= PmsAFBValor(M->AF9_QUANT,aColsDes[nX,nPValor])
					PmsVerConv(@dDtConv,@cCnvPrv,,.T.)
					PmsConvCus(nValorAFB,aColsDes[nX,nPMoedaD],cCnvPrv,dDtConv,M->AF9_START,M->AF9_FINISH,aCusto,aTX2M,cTrunca,M->AF9_QUANT)
				EndIf
			Next nX
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcula o custo da alocacao dos recursos.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nPQuantR > 0) .And. (nPCustdR > 0)
			For nX:= 1 To Len(aColsRec)
				If !aColsRec[nX,Len(aColsRec[nX])]
				// Cronograma de consumo previsto dos recursos na tarefa
				If aColsRec[nX ,nPCalcCstR] == "7" .And. PmsAF8CstAjust(M->AF9_PROJET) $ '12' .And. !Empty(aColsRec[nX ,nPRec]) .AND. Len(aColsAEF2) > 0 .AND. !Empty(aColsAEF2[1,1])
					//
					// calcula o custo
					//
					nCusto := PmsAFACrnCon( "R" ,nX , IIf(PmsAF8CstAjust(M->AF9_PROJET) == '1',dDataBase,Nil) ,M->AF9_QUANT ,aColsPrd)
					PmsConvCus(nCusto ,aColsRec[nX,nPMoedaR],cCnvPrv,dDtConv,M->AF9_START,M->AF9_FINISH,aCusto,aTX2M,cTrunca,M->AF9_QUANT)
				Else
					nQuantAFA:= PmsAFAQuant(M->AF9_PROJET,M->AF9_REVISA,M->AF9_TAREFA,aColsRec[nX,nPCodR],M->AF9_QUANT,aColsRec[nX,nPQuantR],M->AF9_HDURAC,,aColsRec[nX,nPRec])
					PmsVerConv(@dDtConv,@cCnvPrv,,.T.)
					PmsConvCus((aColsRec[nX,nPCustdR] * nQuantAFA),aColsRec[nX,nPMoedaR],cCnvPrv,dDtConv,M->AF9_START,M->AF9_FINISH,aCusto,aTX2M,cTrunca,M->AF9_QUANT)
				EndIf
				EndIf
			Next nX
		EndIf
	Else
	    //
		// Se for uma tarefa de um projeto que utiliza composicao aux
	    //
		If (nGet == 1) //getdados de insumos
			nPCod   := aScan(aHeader,{|x| AllTrim(x[2]) == "AEL_INSUMO"})
			nPQuant := aScan(aHeader,{|x| AllTrim(x[2]) == "AEL_QUANT"})
			nPCustd := aScan(aHeader,{|x| AllTrim(x[2]) == "AEL_CUSTD"})
			nPMoedaP:= aScan(aHeader,{|x| AllTrim(x[2]) == "AEL_MOEDA"})
			nPHrProd:= aScan(aHeader,{|x| AllTrim(x[2]) == "AEL_HRPROD"})
			nPHrImpr:= aScan(aHeader,{|x| AllTrim(x[2]) == "AEL_HRIMPR"})
			nPCusPrd:= aScan(aHeader,{|x| AllTrim(x[2]) == "AEL_CUSPRD"})
			nPCusImp:= aScan(aHeader,{|x| AllTrim(x[2]) == "AEL_CUSIMP"})
			nPGrOrga:= aScan(aHeader,{|x| AllTrim(x[2]) == "AEL_GRORGA"})
			nPDMT	:= aScan(aHeader,{|x| AllTrim(x[2]) == "AEL_DMT"})
			nPItem  := aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AFB_ITEM"})
			nPMoedaD:= aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AFB_MOEDA"})
			nPValor := aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AFB_VALOR"})
			nPDMTD	:= aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AFB_DMT"})
			nPTipoD	:= aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AFB_TIPOD"})
			nPCodR  := aScan(aHeaderSV[3],{|x| AllTrim(x[2]) == "AEN_SUBCOM"})
			nPQuantR:= aScan(aHeaderSV[3],{|x| AllTrim(x[2]) == "AEN_QUANT"})
			nPCustdR:= aScan(aHeaderSV[3],{|x| AllTrim(x[2]) == "AEN_CUSIT"})

			aColsIns:= aClone(aCols)
			aColsDes:= aClone(aColsSV[2])
			aColsSub:= aClone(aColsSV[3])

		ElseIf (nGet == 2) //Getdados de despesas

			nPCod   := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_INSUMO"})
			nPMoedaP:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_MOEDA"})
			nPQuant := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_QUANT"})
			nPCustd := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_CUSTD"})
			nPHrProd:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_HRPROD"})
			nPHrImpr:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_HRIMPR"})
			nPCusPrd:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_CUSPRD"})
			nPCusImp:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_CUSIMP"})
			nPGrOrga:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_GRORGA"})
			nPDMT	:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_DMT"})
			nPItem  := aScan(aHeader,{|x| AllTrim(x[2]) == "AFB_ITEM"})
			nPValor := aScan(aHeader,{|x| AllTrim(x[2]) == "AFB_VALOR"})
			nPMoedaD:= aScan(aHeader,{|x| AllTrim(x[2]) == "AFB_MOEDA"})
			nPDMTD	:= aScan(aHeader,{|x| AllTrim(x[2]) == "AFB_DMT"})
			nPTipoD	:= aScan(aHeader,{|x| AllTrim(x[2]) == "AFB_TIPOD"})
			nPCodR  := aScan(aHeaderSV[3],{|x| AllTrim(x[2]) == "AEN_SUBCOM"})
			nPQuantR:= aScan(aHeaderSV[3],{|x| AllTrim(x[2]) == "AEN_QUANT"})
			nPCustdR:= aScan(aHeaderSV[3],{|x| AllTrim(x[2]) == "AEN_CUSIT"})

			aColsIns:= aClone(aColsSV[1])
			aColsDes:= aClone(aCols)
			aColsSub:= aClone(aColsSV[3])

		ElseIf (nGet == 3) //Getdados de subcomposicoes
			nPCod   := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_INSUMO"})
			nPMoedaP:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_MOEDA"})
			nPQuant := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_QUANT"})
			nPCustd := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_CUSTD"})
			nPHrProd:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_HRPROD"})
			nPHrImpr:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_HRIMPR"})
			nPCusPrd:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_CUSPRD"})
			nPCusImp:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_CUSIMP"})
			nPGrOrga:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_GRORGA"})
			nPDMT	:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_DMT"})
			nPItem  := aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AFB_ITEM"})
			nPValor := aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AFB_VALOR"})
			nPMoedaD:= aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AFB_MOEDA"})
			nPDMTD	:= aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AFB_DMT"})
			nPTipoD	:= aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AFB_TIPOD"})
			nPCodR  := aScan(aHeader,{|x| AllTrim(x[2]) == "AEN_SUBCOM"})
			nPQuantR:= aScan(aHeader,{|x| AllTrim(x[2]) == "AEN_QUANT"})
			nPCustdR:= aScan(aHeader,{|x| AllTrim(x[2]) == "AEN_CUSIT"})

			aColsIns:= aClone(aColsSV[1])
			aColsDes:= aClone(aColsSV[2])
			aColsSub:= aClone(aCols)
		Else
			nPCod   := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_INSUMO"})
			nPMoedaP:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_MOEDA"})
			nPQuant := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_QUANT"})
			nPCustd := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_CUSTD"})
			nPHrProd:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_HRPROD"})
			nPHrImpr:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_HRIMPR"})
			nPCusPrd:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_CUSPRD"})
			nPCusImp:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_CUSIMP"})
			nPGrOrga:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_GRORGA"})
			nPDMT	:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_DMT"})
			nPItem  := aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AFB_ITEM"})
			nPValor := aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AFB_VALOR"})
			nPMoedaD:= aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AFB_MOEDA"})
			nPDMTD	:= aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AFB_DMT"})
			nPTipoD	:= aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AFB_TIPOD"})
			nPCodR  := aScan(aHeaderSV[3],{|x| AllTrim(x[2]) == "AEN_SUBCOM"})
			nPQuantR:= aScan(aHeaderSV[3],{|x| AllTrim(x[2]) == "AEN_QUANT"})
			nPCustdR:= aScan(aHeaderSV[3],{|x| AllTrim(x[2]) == "AEN_CUSIT"})

			aColsIns:= aClone(aColsSV[1])
			aColsDes:= aClone(aColsSV[2])
			aColsSub:= aClone(aColsSV[3])
		EndIf

		If (nPQuant > 0) .And. (nPCustd > 0)
			For nX:= 1 To Len(aColsIns)
				If !aColsIns[nX,Len(aColsIns[nX])]
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Calcula o custo dos insumos.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cGrOrga := aColsIns[nX,nPGrOrga]

					Do Case
						Case cGrOrga == "A" //Equipamentos
							nCusto   := ( aColsIns[nX,nPHrProd] * aColsIns[nX,nPCusPrd] ) + ( aColsIns[nX,nPHrImpr] * aColsIns[nX,nPCusImp] )
							nCustoA  += PMSTrunca(cTrunca, aColsIns[nX,nPQuant] * nCusto, nDecCst)

						Case cGrOrga == "B" //Mao de Obra
							nCustoB  += PMSTrunca(cTrunca, aColsIns[nX,nPQuant] * aColsIns[nX,nPCustD], nDecCst)

						Case cGrOrga == "E" .Or. Empty(cGrOrga)
							nCustoE  += PMSTrunca(cTrunca, aColsIns[nX,nPQuant] * aColsIns[nX,nPCustD], nDecCst)

						Case cGrOrga == "F" //Transporte
							nCusto   := aColsIns[nX,nPQuant] * aColsIns[nX,nPCustD]
							// DMT
							If aColsIns[nX,nPDMT] > 0
								nCusto *= aColsIns[nX,nPDMT]
							Else
								nCusto := 0
							EndIf
							nCustoF  += PMSTrunca(cTrunca, nCusto, nDecCst)

						OtherWise
							nCustoE  += PMSTrunca(cTrunca, aColsIns[nX,nPQuant] * aColsIns[nX,nPCustD], nDecCst)
					EndCase

				EndIf
			Next nX
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcula o custo das despesas.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nPValor > 0)
			For nX:= 1 To Len(aColsDes)
				If !aColsDes[nX,Len(aColsDes[nX])]
					If aColsDes[nX,nPTipoD]="9999"
						nCustoF += xMoeda( aColsDes[nX,nPValor], aColsDes[nX,nPMoedaD], 1, , nDecCst)
					Else
						nDesp += xMoeda( aColsDes[nX,nPValor], aColsDes[nX,nPMoedaD], 1, , nDecCst)
					EndIf
				EndIf
			Next nX
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcula o custo das subcomposicoes.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nPQuantR > 0) .And. (nPCustdR > 0)
			For nX:= 1 To Len(aColsSub)
				If !aColsSub[nX,Len(aColsSub[nX])]
					nSubComp += PmsCusAJT(M->AF9_PROJET, M->AF9_REVISA, aColsSub[nX,nPCodR], aColsSub[nX,nPQuantR], nDecCst)
				EndIf
			Next nX
		EndIf

		If M->AF9_FERRAM > 0
			nFerram := nCustoB * M->AF9_FERRAM / 100
		Else
			nFerram := 0
		EndIf
		nFerram := Round(nFerram, nDecCst)

		If M->AF9_TIPO == "1" //Unitario
			nCusto := pmsTrunca( "2", ( nCustoA + nCustoB + nCustoE + nCustoF + nFerram + nDesp + nSubComp ), nDecCst )
		Else
			nCusto := pmsTrunca( "2", ( ( nCustoA + nCustoB + nFerram ) / M->AF9_PRODUC ) + nCustoE + nCustoF + nDesp + nSubComp, nDecCst )
		EndIf

		If GetMV( "MV_PMSCUST" ) == "2"
			nCusto := pmsTrunca( "2", nCusto *  M->AF9_QUANT, nDecCst )
		EndIf

		PmsVerConv(@dDtConv,@cCnvPrv,,.T.)
		PmsConvCus(nCusto, 1, cCnvPrv, dDtConv, M->AF9_START, M->AF9_FINISH, aCusto, aTX2M, cTrunca, M->AF9_QUANT)

	EndIf
Else
	If !Empty(cProjeto) .And. !Empty(cRevisa) .And. !Empty(cTarefa)
		aHandle := PmsIniCOTP(cProjeto,cRevisa,PMS_MAX_DATE,cTarefa,cTarefa,,)
		aCusto	:= PmsRetCOTP(aHandle,1,cTarefa)
	EndIf
EndIf

If cPmsCust=='2' .and. cTrunca == '4'

	For nX := 1 to Len(aCusto)
		aCusto[nX] := Round(aCusto[nX], nDecCst)
	Next nFaz

Endif

RestArea(aArea)
Return(aCusto)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAF9CusEDT³ Autor ³Fabio Rogerio Pereira   ³ Data ³ 09/05/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de atualizacao do custo das EDT's na estrutura de uma     ³±±
±±³          ³Tarefa.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAF9CusEDT(cProjeto, cRevisa,cEDTPai)
Local aArea		:= GetArea()
Local aAreaPrj	:= AF8->(GetArea())
Local aAreaTrf	:= AF9->(GetArea())
Local aAreaEDT	:= AFC->(GetArea())
Local aCusto	:= {0,0,0,0,0}
Local nValBDI	:= 0
Local nAF9BDI   := 0
Local cFilAFC	:= xFilial("AFC")
Local cFilAF9	:= xFilial("AF9")

DEFAULT cProjeto:= AF9->AF9_PROJET
DEFAULT cRevisa := AF9->AF9_REVISA
DEFAULT cEDTPai := AF9->AF9_EDTPAI

// se o recalculo de custo do orcamento estiver habilitado OU
// se deve fazer o calculo dos custos das tarefas e edts,
// calcula os custos.
If ! Empty(cEdtPai)
	AF8->(dbSetOrder(1))
	AF8->(MsSeek(xFilial()+cProjeto))
	If      (AF8->AF8_RECALC=="1") ;
		.OR. (AF8->AF8_AUTCUS!="2")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se utiliza o calculo padrao ou do template.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistTemplate("PMAAF9CEDT") .And. (GetMV("MV_PMSCCT") == "2")
			ExecTemplate("PMAAF9CEDT",.F.,.F.,{cProjeto,cRevisa,cEDTPai})
		Else
			dbSelectArea("AFC")
			dbSetOrder(2)
			If MsSeek(cFilAFC + cProjeto + cRevisa + cEDTPai)
				While !Eof() .And. (cFilAFC + cProjeto + cRevisa + cEDTPai == AFC->AFC_FILIAL + AFC->AFC_PROJET + AFC_REVISA + AFC->AFC_EDTPAI)
					aCusto[1] += AFC->AFC_CUSTO
					aCusto[2] += AFC->AFC_CUSTO2
					aCusto[3] += AFC->AFC_CUSTO3
					aCusto[4] += AFC->AFC_CUSTO4
					aCusto[5] += AFC->AFC_CUSTO5
					nValBDI += AFC->AFC_VALBDI
					dbSkip()
				End
			EndIf

			dbSelectArea("AF9")
			dbSetOrder(2)
			If MsSeek(cFilAF9 + cProjeto + cRevisa + cEDTPai)
				While !Eof() .And. (cFilAF9 + cProjeto + cRevisa + cEDTPai == AF9->AF9_FILIAL + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_EDTPAI)
					aCusto[1] += AF9->AF9_CUSTO
					aCusto[2] += AF9->AF9_CUSTO2
					aCusto[3] += AF9->AF9_CUSTO3
					aCusto[4] += AF9->AF9_CUSTO4
					aCusto[5] += AF9->AF9_CUSTO5
					nValBDI += AF9->AF9_VALBDI
					nAF9BDI := AF9->AF9_VALBDI
					dbSkip()

				End
			EndIf

			dbSelectArea("AFC")
			dbSetOrder(1)
			If MsSeek(cFilAFC + cProjeto + cRevisa + cEDTPai)
				If (AFC->AFC_NIVEL == "001")
					nValBDI+= IIf(AF8->AF8_VALBDI <> 0, AF8->AF8_VALBDI, aCusto[1] * AF8->AF8_BDI / 100)
				EndIf

				RecLock("AFC",.F.)
				AFC->AFC_CUSTO	:= aCusto[1]
				AFC->AFC_CUSTO2	:= aCusto[2]
				AFC->AFC_CUSTO3	:= aCusto[3]
				AFC->AFC_CUSTO4	:= aCusto[4]
				AFC->AFC_CUSTO5	:= aCusto[5]
				AFC->AFC_VALBDI	:= nValBDI
				AFC->AFC_TOTAL := AFC->AFC_CUSTO + nValBDI
				MsUnlock()

				PMSAF9CusEDT(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDTPAI)
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aAreaPrj)
RestArea(aAreaTrf)
RestArea(aAreaEDT)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAvalAF2³ Autor ³Fabio Rogerio Pereira  ³ Data ³ 17-05-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de avaliacao dos eventos de uma Tarefa de Orcamentos.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela de Tarefas do Orcamento                ³±±
±±³          ³ExpC2: Codigo da Tarefa do Orcamento                			³±±
±±³			 ³ExpC3: Codigo da EDT PAI da Tarefas do Orcamento              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo atualizar os eventos vinculados ³±±
±±³          ³a uma Tarefa de Orcamentos:                                   ³±±
±±³          ³A) Atualizacao das tabelas complementares.                    ³±±
±±³          ³B) Atualizacao das informacoes complementares da Tarefa       ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAvalAF2(cAlias,cOrcame,cEdtPai)

Local aArea 		:= GetArea()
Local aAreaAF2  	:= AF2->(GetArea())

DEFAULT cOrcame:= (cAlias)->AF2_ORCAME
DEFAULT cEdtPai:= (cAlias)->AF2_EDTPAI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa o recalculo do custo das tarefas e edt.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PmsAF2CusEDT(cOrcame,cEDTPai)

RestArea(aAreaAF2)
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAF2CusEDT³ Autor ³Fabio Rogerio Pereira   ³ Data ³ 09/05/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de atualizacao do custo das EDT's na estrutura de uma     ³±±
±±³          ³Tarefa.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAF2CusEDT(cOrcame,cEDTPai)
Local aArea		 := GetArea()
Local aAreaTrf	 := AF2->(GetArea())
Local aAreaEDT	 := AF5->(GetArea())
Local aCusto	 := {0,0,0,0,0}
Local nValBDI	 := 0
Local nValIt	 := 0
Local nValUti	 := 0
Local lPMAF5CST	 := ExistBlock("PMAF5CST")
Local cFilAF5		:= xFilial("AF5")
Local cFilAF2		:= xFilial("AF2")

DEFAULT cOrcame := AF2->AF2_ORCAME
DEFAULT cEDTPai := AF2->AF2_EDTPAI
Default lAF2ValIt := AF2->(ColumnPos("AF2_VALIT")) > 0
Default lAF5ValIt := AF5->(ColumnPos("AF5_VALIT")) > 0
Default lAF2ValUti:= AF2->(ColumnPos("AF2_VALUTI")) > 0
Default lAF5ValUti:= AF5->(ColumnPos("AF5_VALUTI")) > 0

// formata para o tamanho do campo de acordo com o sx3.
cOrcame := padr( cOrcame ,TamSX3("AF2_ORCAME")[1] )
cEDTPai := padr( cEDTPai ,TamSX3("AF2_EDTPAI")[1] )

If ! Empty(cEDTPai)
	dbSelectArea("AF1")
	dbSetOrder(1)
	If MSSeek(xFilial("AF1") + cOrcame)
		// se o recalculo de custo do orcamento estiver habilitado OU
		// se deve fazer o calculo dos custos das tarefas e edts,
		// calcula os custos.
		If      (AF1->AF1_RECALC=="1").OR. (AF1->AF1_AUTCUS!="2")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se utiliza o calculo padrao ou do template.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistTemplate("PMAAF2CEDT") .And. (GetMV("MV_PMSCCT") == "2")
				ExecTemplate("PMAAF2CEDT",.F.,.F.,{cOrcame,cEDTPai})
			Else
				dbSelectArea("AF5")
				dbSetOrder(2)
				If MsSeek(cFilAF5 + cOrcame + cEDTPai)
					While !Eof() .And. (cFilAF5 + cOrcame + cEDTPai == AF5->AF5_FILIAL + AF5->AF5_ORCAME + AF5->AF5_EDTPAI)
						aCusto[1] += AF5->AF5_CUSTO
						aCusto[2] += AF5->AF5_CUSTO2
						aCusto[3] += AF5->AF5_CUSTO3
						aCusto[4] += AF5->AF5_CUSTO4
						aCusto[5] += AF5->AF5_CUSTO5
						nValBDI += AF5->AF5_VALBDI
						dbSkip()
					End
				EndIf

				dbSelectArea("AF2")
				dbSetOrder(2)
				If MsSeek(cFilAF2 + cOrcame + cEDTPai)
					While !Eof() .And. (cFilAF2 + cOrcame + cEDTPai == AF2->AF2_FILIAL + AF2->AF2_ORCAME + AF2->AF2_EDTPAI)
						aCusto[1] += AF2->AF2_CUSTO
						aCusto[2] += AF2->AF2_CUSTO2
						aCusto[3] += AF2->AF2_CUSTO3
						aCusto[4] += AF2->AF2_CUSTO4
						aCusto[5] += AF2->AF2_CUSTO5
						nValBDI += AF2->AF2_VALBDI
						If lAF2ValIt
							nValIt += AF2->AF2_VALIT
						EndIf
						If lAF2ValUti
							nValUti += AF2->AF2_VALUTI
						EndIf
						dbSkip()
					End
				EndIf

				dbSelectArea("AF5")
				dbSetOrder(1)
				If MsSeek(cFilAF5 + cOrcame + cEDTPai)
					If (AF5->AF5_NIVEL == "001")
						nValBDI+= IIf(AF1->AF1_VALBDI <> 0, AF1->AF1_VALBDI, aCusto[1] * AF1->AF1_BDI / 100)
					EndIf

					RecLock("AF5",.F.)
					AF5->AF5_CUSTO	:= aCusto[1]
					AF5->AF5_CUSTO2	:= aCusto[2]
					AF5->AF5_CUSTO3	:= aCusto[3]
					AF5->AF5_CUSTO4	:= aCusto[4]
					AF5->AF5_CUSTO5	:= aCusto[5]
					AF5->AF5_VALBDI	:= nValBDI
					If lAF5ValIt
						AF5->AF5_VALIT := nValIt
					EndIf
					If lAF5ValUti
						AF5->AF5_VALUTI := nValUti
					EndIf
					AF5->AF5_TOTAL 	:= AF5->AF5_CUSTO + nValBDI + nValIt + nValUti
					MsUnlock()

					If lPMAF5CST
						ExecBlock("PMAF5CST", .F., .F.)
					EndIf

					PMSAF2CusEDT(AF5->AF5_ORCAME,AF5->AF5_EDTPAI)
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aAreaTrf)
RestArea(aAreaEDT)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAF2CusTrf³Autor ³Fabio Rogerio Pereira  ³ Data ³ 08-05-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de calculo do custo da tarefa 							 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAF2CusTrf(nGet,cOrcame,cTarefa)
Local aArea    := GetArea()
Local aAreaAF1 := AF1->(GetArea())
Local nX       := 0
Local aCusto   := {0,0,0,0,0}
Local nPCod    := 0
Local nPItem   := 0
Local nPQuant  := 0
Local nPCustd  := 0
Local nPValor  := 0
Local nPMoedaP := 0
Local nPMoedaD := 0
Local aColsPrd := {}
Local aColsDes := {}
Local aColsRec := {}
Local nQuantAF3:= 0
Local nValorAF4:= 0
Local nFaz	   := 0
Local aTX2M	   := {0,0,0,0,0}
Local aDecCst  := {0,0,0,0,0}
Local nCusto   := 0
Local cPmsCust := SuperGetMv("MV_PMSCUST",.F.,"1") //Indica se utiliza o custo pela quantidade unitaria ou total
Local cFilAF3	:= xFilial("AF3")
Local cFilAF4	:= xFilial("AF4")

DEFAULT nGet    := 0
DEFAULT cOrcame := AF2->AF2_ORCAME
DEFAULT cTarefa := AF2->AF2_TAREFA

// formata para o tamanho do campo de acordo com o sx3.
cOrcame := padr( cOrcame ,TamSX3("AF2_ORCAME")[1] )
cTarefa := padr( cTarefa ,TamSX3("AF2_TAREFA")[1] )

aDecCst[1]:=TamSX3("AF2_CUSTO")[2]
aDecCst[2]:=TamSX3("AF2_CUSTO2")[2]
aDecCst[3]:=TamSX3("AF2_CUSTO3")[2]
aDecCst[4]:=TamSX3("AF2_CUSTO4")[2]
aDecCst[5]:=TamSX3("AF2_CUSTO5")[2]

//
// define a forma de arredondar ou truncar os valores
//
dbSelectArea("AF1")
DbSetOrder(1)
MsSeek(xFilial("AF1")+cOrcame)

cTrunca := iIf( Empty(AF1->AF1_TRUNCA) ,"1" ,AF1->AF1_TRUNCA)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se esta sendo chamado atraves de getdados ou nao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Type("aCols") == "A") .And. (Type("aHeader") == "A") .And. (nGet > 0)

	If (nGet == 1) //getdados de produtos
		nPCod    := aScan(aHeader,{|x| AllTrim(x[2]) == "AF3_PRODUT"})
		nPQuant  := aScan(aHeader,{|x| AllTrim(x[2]) == "AF3_QUANT"})
		nPCustd  := aScan(aHeader,{|x| AllTrim(x[2]) == "AF3_CUSTD"})
		nPMoedaP := aScan(aHeader,{|x| AllTrim(x[2]) == "AF3_MOEDA"})
		nPMoedaD := aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AF4_MOEDA"})
		nPItem   := aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AF4_ITEM"})
		nPValor  := aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AF4_VALOR"})
		nPCod2   := aScan(aHeaderSV[4],{|x| AllTrim(x[2]) == "AF3_PRODUT"})
		nPMoedaP2:= aScan(aHeaderSV[4],{|x| AllTrim(x[2]) == "AF3_MOEDA"})
		nPQuant2 := aScan(aHeaderSV[4],{|x| AllTrim(x[2]) == "AF3_QUANT"})
		nPCustd2 := aScan(aHeaderSV[4],{|x| AllTrim(x[2]) == "AF3_CUSTD"})
		nPRec2	 := aScan(aHeaderSV[4],{|x| AllTrim(x[2]) == "AF3_RECURS"})
        aColsPrd := aClone(aCols)
        aColsDes := aClone(aColsSV[2])
        aColsRec := aClone(aColsSV[4])

	ElseIf (nGet == 2) //Getdados de despesas
		nPValor   := aScan(aHeader,{|x| AllTrim(x[2]) == "AF4_VALOR"})
		nPMoedaD  := aScan(aHeader,{|x| AllTrim(x[2]) == "AF4_MOEDA"})
		nPItem    := aScan(aHeader,{|x| AllTrim(x[2]) == "AF4_ITEM"})
		nPCod     := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AF3_PRODUT"})
		nPMoedaP  := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AF3_MOEDA"})
		nPQuant   := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AF3_QUANT"})
		nPCustd   := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AF3_CUSTD"})
		nPCod2    := aScan(aHeaderSV[4],{|x| AllTrim(x[2]) == "AF3_PRODUT"})
		nPMoedaP2 := aScan(aHeaderSV[4],{|x| AllTrim(x[2]) == "AF3_MOEDA"})
		nPQuant2  := aScan(aHeaderSV[4],{|x| AllTrim(x[2]) == "AF3_QUANT"})
		nPCustd2  := aScan(aHeaderSV[4],{|x| AllTrim(x[2]) == "AF3_CUSTD"})
		nPRec2	  := aScan(aHeaderSV[4],{|x| AllTrim(x[2]) == "AF3_RECURS"})
        aColsPrd  := aClone(aColsSV[1])
        aColsDes  := aClone(aCols)
        aColsRec := aClone(aColsSV[4])
	ElseIf (nGet == 4) //Getdados de alocacao de recursos
		nPCod     := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AF3_PRODUT"})
		nPQuant   := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AF3_QUANT"})
		nPCustd   := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AF3_CUSTD"})
		nPMoedaP  := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AF3_MOEDA"})
		nPMoedaD  := aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AF4_MOEDA"})
		nPItem    := aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AF4_ITEM"})
		nPValor   := aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AF4_VALOR"})
		nPCod2    := aScan(aHeader,{|x| AllTrim(x[2]) == "AF3_PRODUT"})
		nPMoedaP2 := aScan(aHeader,{|x| AllTrim(x[2]) == "AF3_MOEDA"})
		nPQuant2  := aScan(aHeader,{|x| AllTrim(x[2]) == "AF3_QUANT"})
		nPCustd2  := aScan(aHeader,{|x| AllTrim(x[2]) == "AF3_CUSTD"})
		nPRec2	  := aScan(aHeader,{|x| AllTrim(x[2]) == "AF3_RECURS"})
        aColsPrd:= aClone(aColsSV[1])
        aColsDes:= aClone(aColsSV[2])
        aColsRec:= aClone(aCols)

	ElseIf (nGet == 5) //Getdados de produtos na proposta de serviços
		nPCod    := aScan(aHeader,{|x| AllTrim(x[2]) == "AF3_PRODUT"})
		nPQuant  := aScan(aHeader,{|x| AllTrim(x[2]) == "AF3_QUANT"})
		nPCustd  := aScan(aHeader,{|x| AllTrim(x[2]) == "AF3_CUSTD"})
		nPMoedaP := aScan(aHeader,{|x| AllTrim(x[2]) == "AF3_MOEDA"})
		nPCod2   := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AF3_PRODUT"})
		nPMoedaP2:= aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AF3_MOEDA"})
		nPQuant2 := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AF3_QUANT"})
		nPCustd2 := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AF3_CUSTD"})
        aColsPrd := aClone(aCols)
        aColsDes := aClone(aColsSV[1])

	Else
		nPCod    := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AF3_PRODUT"})
		nPQuant  := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AF3_QUANT"})
		nPCustd  := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AF3_CUSTD"})
		nPMoedaP := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AF3_MOEDA"})
		nPMoedaD := aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AF4_MOEDA"})
		nPItem   := aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AF4_ITEM"})
		nPValor  := aScan(aHeaderSV[2],{|x| AllTrim(x[2]) == "AF4_VALOR"})
		nPCod2   := aScan(aHeaderSV[4],{|x| AllTrim(x[2]) == "AF3_PRODUT"})
		nPMoedaP2:= aScan(aHeaderSV[4],{|x| AllTrim(x[2]) == "AF3_MOEDA"})
		nPQuant2 := aScan(aHeaderSV[4],{|x| AllTrim(x[2]) == "AF3_QUANT"})
		nPCustd2 := aScan(aHeaderSV[4],{|x| AllTrim(x[2]) == "AF3_CUSTD"})
		nPRec2	 := aScan(aHeaderSV[4],{|x| AllTrim(x[2]) == "AF3_RECURS"})
		aColsPrd := aClone(aColsSV[1])
		aColsDes := aClone(aColsSV[2])
		aColsRec := aClone(aColsSV[4])

	EndIf

	aTX2M[1]:=1
	aTX2M[2]:=M->AF2_TXMO2
	aTX2M[3]:=M->AF2_TXMO3
	aTX2M[4]:=M->AF2_TXMO4
	aTX2M[5]:=M->AF2_TXMO5

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula o custo dos produtos.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nPQuant > 0) .And. (nPCustd > 0)
		For nX:= 1 To Len(aColsPrd)
			If !aColsPrd[nX,Len(aColsPrd[nX])]

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica a quantidade do produto.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nQuantAF3	:= PmsAF3Quant(cOrcame,cTarefa,aColsPrd[nX,nPCod],M->AF2_QUANT,aColsPrd[nX,nPQuant],M->AF2_HDURAC,,"")
				nCusto      := nQuantAF3*aColsPrd[nX,nPCustd]
				For nFaz :=1 to 5
					If aTX2M[nFaz] != 0
						aCusto[nFaz] += PmsTrunca(cTrunca, xMoeda(nCusto, aColsPrd[nX,nPMoedaP], nFaz, If(!Empty(AF1->AF1_DTCONV),AF1->AF1_DTCONV,Nil), aDecCst[nFaz], aTX2M[aColsPrd[nX,nPMoedaP]], aTX2M[nFaz]), aDecCst[nFaz], M->AF2_QUANT)
					Else
						aCusto[nFaz] += PmsTrunca(cTrunca, xMoeda(nCusto, aColsPrd[nX,nPMoedaP], nFaz, If(!Empty(AF1->AF1_DTCONV),AF1->AF1_DTCONV,Nil), aDecCst[nFaz]), aDecCst[nFaz], M->AF2_QUANT)
					EndIf
				Next nFaz
			EndIf
		Next nX
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula o custo das despesas.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nPValor > 0)
		For nX:= 1 To Len(aColsDes)
			If !aColsDes[nX,Len(aColsDes[nX])]

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica o valor da despesa.     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nValorAF4 := PmsAF4Valor(M->AF2_QUANT,aColsDes[nX,nPValor])
				nCusto    := nValorAF4
				For nFaz :=1 to 5
					If aTX2M[nFaz] != 0
						aCusto[nFaz] += PmsTrunca(cTrunca, xMoeda(nCusto, aColsDes[nX,nPMoedaD], nFaz, If(!Empty(AF1->AF1_DTCONV), AF1->AF1_DTCONV, Nil), aDecCst[nFaz], aTX2M[aColsDes[nX,nPMoedaD]], aTX2M[nFaz]), aDecCst[nFaz], M->AF2_QUANT)
					Else
						aCusto[nFaz] += PmsTrunca(cTrunca, xMoeda(nCusto, aColsDes[nX,nPMoedaD], nFaz, If(!Empty(AF1->AF1_DTCONV), AF1->AF1_DTCONV, Nil), aDecCst[nFaz]), aDecCst[nFaz], M->AF2_QUANT)
					Endif
				Next nFaz
   			EndIf
		Next nX
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula o custo do recurso   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nPQuant2 > 0) .And. (nPCustd2 > 0)
		For nX:= 1 To Len(aColsRec)
			If !aColsRec[nX,Len(aColsRec[nX])]

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica a quantidade do produto.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nQuantAF3	:= PmsAF3Quant(cOrcame,cTarefa,aColsRec[nX,nPCod2],M->AF2_QUANT,aColsRec[nX,nPQuant2],M->AF2_HDURAC,,aColsRec[nX,nPRec2])
				nCusto      := nQuantAF3*aColsRec[nX,nPCustd2]
				For nFaz := 1 to 5
					If aTX2M[nFaz] != 0
						aCusto[nFaz] += PmsTrunca(cTrunca, xMoeda(nCusto, aColsRec[nX,nPMoedaP2], nFaz, If(!Empty(AF1->AF1_DTCONV), AF1->AF1_DTCONV, Nil), aDecCst[nFaz], aTX2M[aColsRec[nX,nPMoedaP2]], aTX2M[nFaz]), aDecCst[nFaz], M->AF2_QUANT)
					Else
						aCusto[nFaz] += PmsTrunca(cTrunca, xMoeda(nCusto, aColsRec[nX,nPMoedaP2], nFaz, If(!Empty(AF1->AF1_DTCONV), AF1->AF1_DTCONV, Nil), aDecCst[nFaz]), aDecCst[nFaz], M->AF2_QUANT)
					EndIf
				Next nFaz
   			EndIf
		Next nX
	EndIf
Else
	If !Empty(cOrcame) .And. !Empty(cTarefa)

		aTX2M[1] := 1
		aTX2M[2] := AF2->AF2_TXMO2
		aTX2M[3] := AF2->AF2_TXMO3
		aTX2M[4] := AF2->AF2_TXMO4
		aTX2M[5] := AF2->AF2_TXMO5

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica os custos dos produtos.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AF3")
		dbSetOrder(1)
		If MsSeek(cFilAF3 + cOrcame + cTarefa)
			While !Eof() .And. (cFilAF3 + cOrcame + cTarefa == AF3->AF3_FILIAL + AF3->AF3_ORCAME + AF3->AF3_TAREFA)

				If !Empty( AF3->AF3_PRODUT )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica a quantidade do produto.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nQuantAF3 := PmsAF3Quant(AF3->AF3_ORCAME,AF3->AF3_TAREFA,AF3->AF3_PRODUT,AF2->AF2_QUANT,AF3->AF3_QUANT,AF2->AF2_HDURAC)
					nCusto    := AF3->AF3_CUSTD * nQuantAF3

					For nFaz :=1 to 5
						If aTX2M[nFaz] != 0
							aCusto[nFaz] += PmsTrunca(cTrunca, xMoeda(nCusto, AF3->AF3_MOEDA, nFaz, If(!Empty(AF1->AF1_DTCONV), AF1->AF1_DTCONV, Nil), aDecCst[nFaz], aTX2M[IIf(AF3->AF3_MOEDA<1,1,AF3->AF3_MOEDA)], aTX2M[nFaz]), aDecCst[nFaz], AF2->AF2_QUANT)
						Else
							aCusto[nFaz] += PmsTrunca(cTrunca, xMoeda(nCusto, AF3->AF3_MOEDA, nFaz, If(!Empty(AF1->AF1_DTCONV), AF1->AF1_DTCONV, Nil), aDecCst[nFaz]), aDecCst[nFaz], AF2->AF2_QUANT)
						EndIf
					Next nFaz
				EndIf
				AF3->(dbSkip())
			EndDo
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica os custos das despesas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AF4")
		dbSetOrder(1)
		If MsSeek(cFilAF4 + cOrcame + cTarefa)
			While !Eof() .And. (cFilAF4 + cOrcame + cTarefa == AF4->AF4_FILIAL + AF4->AF4_ORCAME + AF4->AF4_TAREFA)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica o valor da despesa.     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nValorAF4 := PmsAF4Valor(AF2->AF2_QUANT,AF4->AF4_VALOR)
				nCusto    := nValorAF4
				For nFaz := 1 to 5
					If aTX2M[nFaz] != 0
						aCusto[nFaz] += PmsTrunca(cTrunca, xMoeda(nCusto, AF4->AF4_MOEDA, nFaz, If(!Empty(AF1->AF1_DTCONV), AF1->AF1_DTCONV, Nil), aDecCst[nFaz], aTX2M[AF4->AF4_MOEDA], aTX2M[nFaz]), aDecCst[nFaz], AF2->AF2_QUANT)
					Else
						aCusto[nFaz] += PmsTrunca(cTrunca, xMoeda(nCusto, AF4->AF4_MOEDA, nFaz, If(!Empty(AF1->AF1_DTCONV), AF1->AF1_DTCONV, Nil), aDecCst[nFaz]), aDecCst[nFaz], AF2->AF2_QUANT)
					EndIf
				Next nFaz
				AF4->(dbSkip())
			EndDo
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica os custos dos RECURSOS.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AF3")
		dbSetOrder(1)
		If MsSeek(cFilAF3 + cOrcame + cTarefa)
			While !Eof() .And. (cFilAF3 + cOrcame + cTarefa == AF3->AF3_FILIAL + AF3->AF3_ORCAME + AF3->AF3_TAREFA)

				If Empty( AF3->AF3_PRODUT )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica a quantidade do RECURSO.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nQuantAF3 := PmsAF3Quant(AF3->AF3_ORCAME,AF3->AF3_TAREFA,AF3->AF3_PRODUT,AF2->AF2_QUANT,AF3->AF3_QUANT,AF2->AF2_HDURAC,,AF3->AF3_RECURS)
					nCusto    := AF3->AF3_CUSTD * nQuantAF3
					For nFaz := 1 to 5
						If aTX2M[nFaz] != 0
							aCusto[nFaz] += PmsTrunca(cTrunca, xMoeda(nCusto, AF3->AF3_MOEDA, nFaz, If(!Empty(AF1->AF1_DTCONV), AF1->AF1_DTCONV, Nil), aDecCst[nFaz], aTX2M[AF3->AF3_MOEDA], aTX2M[nFaz]), aDecCst[nFaz], AF2->AF2_QUANT)
						Else
							aCusto[nFaz] += PmsTrunca(cTrunca, xMoeda(nCusto, AF3->AF3_MOEDA, nFaz, If(!Empty(AF1->AF1_DTCONV), AF1->AF1_DTCONV, Nil), aDecCst[nFaz]), aDecCst[nFaz], AF2->AF2_QUANT)
						EndIf
					Next nFaz
				EndIf
				AF3->(dbSkip())
			EndDo
		EndIf
	EndIf
EndIf

If cPmsCust=='2' .and. cTrunca == '4'

	For nFaz := 1 to 5
		If aTX2M[nFaz] != 0
			aCusto[nFaz] := Round(aCusto[nFaz], aDecCst[nFaz])
		EndIf
	Next nFaz

Endif
RestArea(aAreaAF1)
RestArea(aArea)
Return(aCusto)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsIniFin³ Autor ³ Edson Maricate              ³ Data ³ 21-05-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que inicializa os valores financeiros da EDT                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aAnaArrayTrb:array com os valores de cada dia analiticamente       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aArrayTrb : array com os valores de cada dia                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsIniFin(cProjeto,cRevisa,cEDT,lFluxo,nMoeda,dDataRef,aAnaArrayTrb)
Local aArrayTrb      := {}
Default lFluxo       := .F.
Default nMoeda       := 1
Default aAnaArrayTrb := {}

If ExistBlock("PMSINIFIN")
	aArrayTrb := ExecBlock("PMSINIFIN",.F.,.F.,{cProjeto,cRevisa,cEDT,aArrayTrb,lFluxo,nMoeda,dDataRef})
Else
	AuxIniFin(cProjeto,cRevisa,cEDT,aArrayTrb,lFluxo,nMoeda,dDataRef,aAnaArrayTrb)
EndIf

Return aArrayTrb

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AuxIniFin³ Autor ³ Edson Maricate              ³ Data ³ 21-05-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que inicializa os valores financeiros da EDT                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aArrayTrb : array com os valores de cada dia                       ³±±
±±³          |aAnaArrayTrb : array com os valores de cada dia analiticamente     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AuxIniFin(cProjeto,cRevisa,cEDT,aArrayTrb,lFluxo,nMoeda,dDataRef,aAnaArrayTrb)
Local nX
Local aAuxRet
Local aRet     := {0,0,0,0,0,0}
Local aFluxo   := {{},{},0,{},{},0}
Local aArea    := GetArea()
Local aAreaAFC := AFC->(GetArea())
Local aAreaSF4 := SF4->(GetArea())
Local aAreaAF9 := AF9->(GetArea())
Local aAreaAFG := AFG->(GetArea())
Local aAreaSD1 := SD1->(GetArea())
Local aAreaSD2 := SD1->(GetArea())
Local aAreaSC1 := SC1->(GetArea())
Local aAreaSC7 := SC7->(GetArea())
Local aAreaSE5 := SE5->(GetArea())
Local nPosDt   := 0
Local nValAux  := 0
Local cFilSC6  := xFilial("SC6")
Local cFilSE1  := xFilial("SE1")
Local cFilSF4  := xFilial("SF4")
Local cFilSD2  := xFilial("SD2")
Local cFilAJE  := xFilial("AJE")
Local cFilAF9  := xFilial("AF9")
Local cFilAFC  := xFilial("AFC")
Local cAliasSE1:= "SE1"
Local lTcSrvType := TcSrvType() <> "AS/400"
Local cFilAFT	:= xFilial("AFT")
Local cFilSF2	:= xFilial("SF2")
Local cMv1DUPREF := SuperGetMV("MV_1DUPREF")

Default dDataRef     := PMS_MAX_DATE
Default aAnaArrayTrb := {}

/*
aFluxo[1] - pedidos de compra
aFluxo[2] - array dos titulos/mov. bancaria a pagar
[data, soma do valor dos titulos desta data, soma dos titulos antecipado desta data]
aFluxo[3] - saldo de despesas inicial
aFluxo[4] - pedidos de venda
aFluxo[5] - array dos titulos/mov. bancaria a receber
[data, soma do valor dos titulos desta data, soma dos titulos antecipado desta data]
aFluxo[6] - saldo de receitas inicial
*/


	aRet   := {0,0,0,0,0,0}
	aFluxo := {{},{},0,{},{},0}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o Saldo atual por pedido de vendas - EDT   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC6")
	SC6->(DbSetOrder(8)) //C6_FILIAL+C6_PROJPMS+C6_TASKPMS+C6_EDTPMS

	If Alltrim(cProjeto) == Alltrim(cEDT) // se o fluxo for da EDT principal entao...
		SC6->(DbSeek(cFilSC6+cProjeto+SPACE(LEN(SC6->C6_TASKPMS))+SPACE(LEN(SC6->C6_EDTPMS)),.T.)) //este DbSeek nao deve ir para o protheus 10 pois o pedido nao podera ser amarrado somente ao projeto(devera ser proj+EDT ou proj+trf)
	Else
		SC6->(DbSeek(cFilSC6+cProjeto+SPACE(LEN(SC6->C6_TASKPMS))+cEDT))
	EndIf

	While SC6->(!Eof()) .And. ;
		( cFilSC6+cProjeto+SPACE(LEN(SC6->C6_TASKPMS))+SPACE(LEN(SC6->C6_EDTPMS)) == SC6->C6_FILIAL+SC6->C6_PROJPMS+SC6->C6_TASKPMS+SC6->C6_EDTPMS .Or. ;
		cFilSC6+cProjeto+SPACE(LEN(SC6->C6_TASKPMS))+cEDT == SC6->C6_FILIAL+SC6->C6_PROJPMS+SC6->C6_TASKPMS+SC6->C6_EDTPMS       )
		SC5->(dbSetOrder(1))
		SC5->(MsSeek(cFilSC6+SC6->C6_NUM))
		If SC5->C5_EMISSAO <= dDataRef
			SF4->(dbSetOrder(1)) //F4_FILIAL+F4_CODIGO
			If SF4->(MsSeek(cFilSF4+SC6->C6_TES)) .And. SF4->F4_DUPLIC == "S" .And. SF4->F4_MOVPRJ $ '15'//Receita ou receita e despesa (ao mesmo tempo)
				aRet[4] += xMoeda(((SC6->C6_QTDVEN-SC6->C6_QTDENT)*SC6->C6_PRCVEN),SC5->C5_MOEDA,nMoeda,SC6->C6_ENTREG,8)
				If lFluxo
					aDupl := Condicao(xMoeda(((SC6->C6_QTDVEN-SC6->C6_QTDENT)*SC6->C6_PRCVEN),SC5->C5_MOEDA,nMoeda,SC6->C6_ENTREG,8),SC5->C5_CONDPAG,0,SC6->C6_ENTREG,0)
					If Len(aDupl) > 0
						nAcerto := 0
						For nX := 1 To Len(aDupl)
							nAcerto += aDupl[nX,2]
						Next nX
						aDupl[Len(aDupl),2] += xMoeda(((SC6->C6_QTDVEN-SC6->C6_QTDENT)*SC6->C6_PRCVEN),SC5->C5_MOEDA,nMoeda,SC6->C6_ENTREG,8) - nAcerto
						For nX := 1 To Len(aDupl)
							nPosDt := aScan(aFluxo[4],{|x| x[1]==aDupl[nX,1]})
							If nPosDt > 0
								aFluxo[4,nPosDt,2] += aDupl[nX,2]
							Else
								aAdd(aFluxo[4],{aDupl[nX,1],aDupl[nX,2]})
							EndIf
							//adiciona no array analitico o Pedido de Venda
							Aadd(aAnaArrayTrb,{,aDupl[nX,1],"PEDIDO DE VENDA",SC6->C6_FILIAL,SC6->C6_NUM,SC6->C6_ITEM,aDupl[nX,2]})
						Next nX
					Endif
				EndIf
			EndIf
			If SC6->C6_QTDENT <> 0
				dbSelectArea("SD2")
				dbSetOrder(8)
				MsSeek(cFilSD2+SC6->C6_NUM+SC6->C6_ITEM)
				While !Eof() .And. cFilSD2+SC6->C6_NUM+SC6->C6_ITEM==;
					SD2->D2_FILIAL+SD2->D2_PEDIDO+SD2->D2_ITEMPV

					SF4->(DbSetOrder(1)) //F4_FILIAL+F4_CODIGO
					If SF4->(DbSeek(cFilSF4+SD2->D2_TES)) .And. SF4->F4_DUPLIC == "S" .And. SF4->F4_MOVPRJ $ '15'//Receita ou receita e despesa (ao mesmo tempo)

						dbSelectArea("SF2")
						dbSetOrder(1)
						MsSeek(cFilSF2+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Carega o Array contendo as Duplicatas a Receber (SE1)   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cSerie := If(Empty(SF2->F2_PREFIXO),&(cMv1DUPREF),SF2->F2_PREFIXO)
						cSerie := PadR(cSerie,Len(SE1->E1_PREFIXO))

						If lTcSrvType
							lQuery    := .T.
							cAliasSE1 := CriaTrab(,.F.)
							aStruSE1  := SE1->(dbStruct())
							cQuery := "SELECT SE1.*,SE1.R_E_C_N_O_ RECSE1 FROM "
							cQuery += RetSqlName("SE1") + " SE1 "
							cQuery += " WHERE "
							cQuery += "E1_FILIAL = '"+cFilSE1+"' AND "
							cQuery += "E1_CLIENTE = '"+SF2->F2_CLIENTE+"' AND "
							cQuery += "E1_LOJA = '"+SF2->F2_LOJA+"' AND "
							cQuery += "E1_PREFIXO = '"+cSerie+"' AND "
							cQuery += "E1_NUM = '"+SF2->F2_DOC+"' AND "
							cQuery += "SE1.D_E_L_E_T_ = ' ' "
							cQuery := ChangeQuery(cQuery)
							dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE1,.F.,.T.)
							For nX := 1 To Len(aStruSE1)
								If aStruSE1[nX,2]!="C"
									TcSetField(cAliasSE1,aStruSE1[nX,1],aStruSE1[nX,2],aStruSE1[nX,3],aStruSE1[nX,4])
								EndIf
							Next nX
						Else

							DbSelectArea("SE1")
							SE1->(DbSetOrder(2))
							SE1->(MsSeek(cFilSE1+SF2->F2_CLIENTE+SF2->F2_LOJA+cSerie+SF2->F2_DOC))

						Endif


						While !Eof() .And. (cAliasSE1)->E1_FILIAL == cFilSE1 .And.;
							(cAliasSE1)->E1_CLIENTE == SF2->F2_CLIENTE .And.;
							(cAliasSE1)->E1_LOJA == SF2->F2_LOJA .And. ;
							(cAliasSE1)->E1_PREFIXO == cSerie .And. ;
							(cAliasSE1)->E1_NUM == SF2->F2_DOC
							nValAux := xMoeda((cAliasSE1)->E1_SALDO*(SD2->D2_TOTAL/SF2->F2_VALFAT),(cAliasSE1)->E1_MOEDA,nMoeda,(cAliasSE1)->E1_VENCREA,8)
							If SE1->E1_TIPO $ MVABATIM		 // Se for abatimento
								aRet[2] += nValAux
							Else
								aRet[5] += nValAux
							EndIf
							aRet[6] += PmsBaixas((cAliasSE1)->E1_PREFIXO,(cAliasSE1)->E1_NUM,(cAliasSE1)->E1_PARCELA,(cAliasSE1)->E1_TIPO,nMoeda,"R",(cAliasSE1)->E1_CLIENTE,(cAliasSE1)->E1_LOJA,dDataRef,.F.)*(SD2->D2_TOTAL/SF2->F2_VALFAT)

							If lFluxo
								aFluxo[6] += PmsBaixas((cAliasSE1)->E1_PREFIXO,(cAliasSE1)->E1_NUM,(cAliasSE1)->E1_PARCELA,(cAliasSE1)->E1_TIPO,nMoeda,"R",(cAliasSE1)->E1_CLIENTE,(cAliasSE1)->E1_LOJA, dDataRef,.T.)*(SD2->D2_TOTAL/SF2->F2_VALFAT)


								If lTcSrvType
									//o posicionamento no SE2 eh necessario pois a funcao SALDOTIT utiliza este posicionamento
									SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
									SE1->(DbSeek((cAliasSE1)->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) ))
								EndIf


								nValAux := SaldoTit((cAliasSE1)->E1_PREFIXO,(cAliasSE1)->E1_NUM,(cAliasSE1)->E1_PARCELA,(cAliasSE1)->E1_TIPO,(cAliasSE1)->E1_NATUREZ,"R",(cAliasSE1)->E1_CLIENTE,nMoeda,dDataBase,dDataBase,SE1->E1_LOJA,,,1) // 1 = DT BAIXA    3 = DT DIGIT
								nValAux := nValAux * (SD2->D2_TOTAL/SF2->F2_VALFAT)

								nPosDt := aScan(aFluxo[5],{|x| x[1]==(cAliasSE1)->E1_VENCREA})
								If nPosDt > 0
									If SE1->E1_TIPO $ MVABATIM // Se for abatimento
										aFluxo[2,nPosDt,2] += nValAux
									Else
										aFluxo[5,nPosDt,2] += nValAux
										//adiciona no array analitico a NF
										Aadd(aAnaArrayTrb,{,(cAliasSE1)->E1_VENCREA,"NOTA FISCAL",SD2->D2_FILIAL,SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_ITEM,SD2->D2_COD,SD2->D2_CLIENTE,SD2->D2_LOJA,nValAux})
									EndIf
								Else
									If SE1->E1_TIPO $ MVABATIM		 // Se for abatimento
										aAdd(aFluxo[2],{(cAliasSE1)->E1_VENCREA,nValAux,0})
									Else
										aAdd(aFluxo[5],{(cAliasSE1)->E1_VENCREA,nValAux,0})
										//adiciona no array analitico a NF
										Aadd(aAnaArrayTrb,{,(cAliasSE1)->E1_VENCREA,"NOTA FISCAL",SD2->D2_FILIAL,SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_ITEM,SD2->D2_COD,SD2->D2_CLIENTE,SD2->D2_LOJA,nValAux})
									EndIf
								EndIf

							EndIf
							(cAliasSE1)->(DbSkip())
						EndDo

						If lQuery
							dbSelectArea(cAliasSE1)
							dbCloseArea()
						EndIf
					EndIf
					dbSelectArea("SD2")
					dbSkip()
				EndDo
			EndIf
		EndIf
		SC6->(DbSkip())
	EndDo
	AuxAddEDT(cProjeto,cRevisa,cEDT,aArrayTrb,aRet,aFluxo)


	aRet   := {0,0,0,0,0,0}
	aFluxo := {{},{},0,{},{},0}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o Saldo atual por Titulos a Receber - EDT  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFT")
	dbSetOrder(4)
	MsSeek(cFilAFT+cProjeto+cRevisa+cEDT)
	While !Eof() .And. cFilAFT+cProjeto+cRevisa+cEDT==;
		AFT->AFT_FILIAL+AFT->AFT_PROJET+AFT->AFT_REVISA+AFT->AFT_EDT
		SE1->(dbSetOrder(1))
		If SE1->(MsSeek(cFilSE1+AFT->AFT_PREFIXO+AFT->AFT_NUM+AFT->AFT_PARCELA+AFT->AFT_TIPO+AFT->AFT_CLIENT+AFT->AFT_LOJA)) .And. ;
			SE1->E1_EMISSAO <= dDataRef
			nValAux := xMoeda(SE1->E1_SALDO*(AFT->AFT_VALOR1/SE1->E1_VLCRUZ),SE1->E1_MOEDA,nMoeda,SE1->E1_VENCREA,8)
			If SE1->E1_TIPO $ MVABATIM		 // Se for abatimento
				aRet[2] += nValAux
			Else
				aRet[5] += nValAux
			EndIf
			aRet[6] += PmsBaixas(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,nMoeda,"R",SE1->E1_CLIENTE,SE1->E1_LOJA,dDataRef,.F.)*(AFT->AFT_VALOR1/SE1->E1_VLCRUZ)

			If lFluxo
				nValAux := SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,nMoeda,dDataBase,dDataBase,SE1->E1_LOJA,,,1) // 1 = DT BAIXA    3 = DT DIGIT
				nValAux := nValAux * (AFT->AFT_VALOR1/SE1->E1_VLCRUZ)  //apenas o valor amarrado ao projeto deve entrar no fluxo
				If SE1->E1_TIPO == MVRECANT
					If SE1->E1_EMISSAO <= dDataBase
						aFluxo[6] += xMoeda(SE1->E1_VALOR*(AFT->AFT_VALOR1/SE1->E1_VLCRUZ),SE1->E1_MOEDA,nMoeda,SE1->E1_VENCREA,8)
					EndIf
					dDataAux := SE1->E1_EMISSAO
				Else
					aFluxo[6] += PmsBaixas(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,nMoeda,"R",SE1->E1_CLIENTE,SE1->E1_LOJA, dDataRef,.T.)*(AFT->AFT_VALOR1/SE1->E1_VLCRUZ)
					dDataAux  := SE1->E1_VENCREA
				EndIf

				nPosDt := aScan(aFluxo[5],{|x| x[1]==dDataAux})
				If nPosDt > 0
					If SE1->E1_TIPO $ MVABATIM		 // Se for abatimento
						aFluxo[2,nPosDt,2] += nValAux
					Else
						If SE1->E1_TIPO == MVRECANT
							aFluxo[5,nPosDt,3] += nValAux
						Else
							aFluxo[5,nPosDt,2] += nValAux
						EndIf
					EndIf
				Else
					If SE1->E1_TIPO $ MVABATIM		 // Se for abatimento
						aAdd(aFluxo[2],{SE1->E1_VENCREA,nValAux,0})
					Else
						If SE1->E1_TIPO == MVRECANT
							aAdd(aFluxo[5],{dDataAux,     0,nValAux})
						Else
							aAdd(aFluxo[5],{SE1->E1_VENCREA,nValAux,0})
						EndIf
					EndIf
				EndIf

				//adiciona no array analitico o Titulo a Receber
				If nValAux != 0 .And. ;
					( !(SE1->E1_TIPO==MVRECANT) .Or. (SE1->E1_TIPO==MVRECANT .And. SE1->E1_EMISSAO>dDataBase) )
					Aadd(aAnaArrayTrb,{,dDataAux,"TITULO RECEBER",SE1->E1_FILIAL,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,nValAux})
				EndIf

			EndIf
		EndIf
		dbSelectArea("AFT")
		dbSkip()
	End
	AuxAddEDT(cProjeto,cRevisa,cEDT,aArrayTrb,aRet,aFluxo)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o Saldo atual por Movimentacao Bancaria - EDT  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRet   := {0,0,0,0,0,0}
aFluxo := {{},{},0,{},{},0}
SE5->(dbSetOrder(9))
dbSelectArea("AJE")
AJE->(DbSetOrder(2)) //AJE_FILIAL+AJE_PROJET+AJE_REVISA+AJE_EDT+DTOS(AJE_DATA)
AJE->(MsSeek(cFilAJE+cProjeto+cRevisa+cEDT))
While AJE->(!Eof()) .And. AJE_FILIAL+AJE_PROJET+AJE_REVISA+AJE_EDT==cFilAJE+cProjeto+cRevisa+cEDT
	If SE5->(dbSeek(PmsFilial("SE5","AJE")+AJE->AJE_ID)).And. ;
		SE5->E5_SITUACA <> "C" .And. SE5->E5_SITUACA <> "X" .And. SE5->E5_SITUACA <> "E"

		If SE5->E5_DTDISPO <= dDataBase //vai para o saldo inicial
			If SE5->E5_RECPAG=="P"
				aRet[3] += xMoeda(AJE->AJE_VALOR,1,nMoeda,SE5->E5_DTDISPO,8)
				If lFluxo
					aFluxo[3] += xMoeda(AJE->AJE_VALOR,1,nMoeda,SE5->E5_DTDISPO,8)
				EndIf
			Else
				aRet[6] += xMoeda(AJE->AJE_VALOR,1,nMoeda,SE5->E5_DTDISPO,8)
				If lFluxo
					aFluxo[6] += xMoeda(AJE->AJE_VALOR,1,nMoeda,SE5->E5_DTDISPO,8)
				EndIf
			EndIf
		Else //vai para o fluxo
			If SE5->E5_RECPAG=="P"
				nPosDt := aScan(aFluxo[2],{|x| x[1]==SE5->E5_DTDISPO})
				If nPosDt > 0
					aFluxo[2,nPosDt,2] += xMoeda(AJE->AJE_VALOR,1,nMoeda,SE5->E5_DTDISPO,8)
				Else
					aAdd(aFluxo[2],{SE5->E5_DTDISPO,xMoeda(AJE->AJE_VALOR,1,nMoeda,SE5->E5_DTDISPO,8),0})
				EndIf
				//adiciona no array analitico a movimentacao bancaria
				Aadd(aAnaArrayTrb,{,SE5->E5_DTDISPO,"MOV.BANCARIA PAGAR",SE5->E5_MOEDA,SE5->E5_NATUREZ,SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,AJE->AJE_VALOR})
			Else
				nPosDt := aScan(aFluxo[5],{|x| x[1]==SE5->E5_DTDISPO})
				If nPosDt > 0
					aFluxo[5,nPosDt,2] += xMoeda(AJE->AJE_VALOR,1,nMoeda,SE5->E5_DTDISPO,8)
				Else
					aAdd(aFluxo[5],{SE5->E5_DTDISPO,xMoeda(AJE->AJE_VALOR,1,nMoeda,SE5->E5_DTDISPO,8),0})
				EndIf
				//adiciona no array analitico a movimentacao bancaria
				Aadd(aAnaArrayTrb,{,SE5->E5_DTDISPO,"MOV.BANCARIA RECEBER",SE5->E5_MOEDA,SE5->E5_NATUREZ,SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,AJE->AJE_VALOR})
			EndIf

		EndIf
	EndIf
	dbSelectArea("AJE")
	dbSkip()
End
AuxAddEDT(cProjeto,cRevisa,cEDT,aArrayTrb,aRet,aFluxo)

dbSelectArea("AF9")
AF9->(DbSetOrder(2)) //AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_EDTPAI+AF9_ORDEM
AF9->(MsSeek(cFilAF9+cProjeto+cRevisa+cEDT))
While AF9->(!Eof()) .And. cFilAF9+cProjeto+cRevisa+cEDT==AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_EDTPAI
	aAuxRet := PmsRetFin(AF9_PROJET,AF9_REVISA,AF9_TAREFA,lFluxo,aFluxo,nMoeda,dDataRef,aAnaArrayTrb)
	aAdd(aArrayTrb,{AF9->AF9_TAREFA,,aClone(aAuxRet),aClone(aFluxo)})
	AuxAddEDT(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_EDTPAI,aArrayTrb,aAuxRet,aFluxo)
	dbSelectArea("AF9")
	dbSkip()
End

dbSelectArea("AFC")
AFC->(dbSetOrder(2)) //AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDTPAI+AFC_ORDEM
AFC->(MsSeek(cFilAFC+cProjeto+cRevisa+cEDT))
While AFC->(!Eof()) .And. cFilAFC+cProjeto+cRevisa+cEDT==AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDTPAI
	AuxIniFin(AFC_PROJET,AFC_REVISA,AFC_EDT,aArrayTrb,lFluxo,nMoeda,dDataRef,aAnaArrayTrb)
	dbSelectArea("AFC")
	dbSkip()
End

RestArea(aAreaSF4)
RestArea(aAreaSD1)
RestArea(aAreaSD2)
RestArea(aAreaSE5)
RestArea(aAreaSC7)
RestArea(aAreaSC1)
RestArea(aAreaAFG)
RestArea(aAreaAFC)
RestArea(aAreaAF9)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AuxAddEDT³ Autor ³ Edson Maricate              ³ Data ³ 21-05-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que inicializa os valores financeiros da EDT                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                        	   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AuxAddEDT(cProjeto,cRevisa,cEDT,aArrayTrb,aVlrFin,aFluxo)
Local nX
Local nPosDt
Local aArea		:= GetArea()
Local aAreaAFC	:= AFC->(GetArea())
Local nPosEDT	:= aScan(aArrayTrb,{|x|x[2]==cEDT})

If nPosEDT > 0
	aArrayTrb[nPosEDT,3,1] += aVlrFin[1]
	aArrayTrb[nPosEDT,3,2] += aVlrFin[2]
	aArrayTrb[nPosEDT,3,3] += aVlrFin[3]
	aArrayTrb[nPosEDT,3,4] += aVlrFin[4]
	aArrayTrb[nPosEDT,3,5] += aVlrFin[5]
	aArrayTrb[nPosEDT,3,6] += aVlrFin[6]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o fluxo de caixa                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aArrayTrb[nPosEDT,4,3] += aFluxo[3]
	aArrayTrb[nPosEDT,4,6] += aFluxo[6]
	For nx := 1 to Len(aFluxo[1])
		nPosDt := aScan(aArrayTrb[nPosEDT,4,1],{|x| x[1]==aFluxo[1,nX,1]})
		If nPosDt > 0
			aArrayTrb[nPosEDT,4,1,nPosDt,2] += aFluxo[1,nX,2]
		Else
			aAdd(aArrayTrb[nPosEDT,4,1],{aFluxo[1,nX,1],aFluxo[1,nX,2]})
		EndIf
	Next
	For nx := 1 to Len(aFluxo[2])
		nPosDt := aScan(aArrayTrb[nPosEDT,4,2],{|x| x[1]==aFluxo[2,nX,1]})
		If nPosDt > 0
			aArrayTrb[nPosEDT,4,2,nPosDt,2] += aFluxo[2,nX,2]
			aArrayTrb[nPosEDT,4,2,nPosDt,3] += aFluxo[2,nX,3]
		Else
			aAdd(aArrayTrb[nPosEDT,4,2],aClone(aFluxo[2,nX]))
		EndIf
	Next
	For nx := 1 to Len(aFluxo[4])
		nPosDt := aScan(aArrayTrb[nPosEDT,4,4],{|x| x[1]==aFluxo[4,nX,1]})
		If nPosDt > 0
			aArrayTrb[nPosEDT,4,4,nPosDt,2] += aFluxo[4,nX,2]
		Else
			aAdd(aArrayTrb[nPosEDT,4,4],{aFluxo[4,nX,1],aFluxo[4,nX,2]})
		EndIf
	Next
	For nx := 1 to Len(aFluxo[5])
		nPosDt := aScan(aArrayTrb[nPosEDT,4,5],{|x| x[1]==aFluxo[5,nX,1]})
		If nPosDt > 0
			aArrayTrb[nPosEDT,4,5,nPosDt,2] += aFluxo[5,nX,2]
			aArrayTrb[nPosEDT,4,5,nPosDt,3] += aFluxo[5,nX,3]
		Else
			aAdd(aArrayTrb[nPosEDT,4,5],aClone(aFluxo[5,nX]))
		EndIf
	Next
Else
	aAdd(aArrayTrb,{,cEdt,{0,0,0,0,0,0},aClone(aFluxo)})
	nPosEDT	:= Len(aArrayTrb)
	aArrayTrb[nPosEDT,3,1] := aVlrFin[1]
	aArrayTrb[nPosEDT,3,2] := aVlrFin[2]
	aArrayTrb[nPosEDT,3,3] := aVlrFin[3]
	aArrayTrb[nPosEDT,3,4] := aVlrFin[4]
	aArrayTrb[nPosEDT,3,5] := aVlrFin[5]
	aArrayTrb[nPosEDT,3,6] := aVlrFin[6]
EndIf

dbSelectArea("AFC")
dbSetOrder(1)
If MsSeek(xFilial()+cProjeto+cRevisa+cEDT) .And. !Empty(AFC_EDTPAI)
	AuxAddEDT(cProjeto,cRevisa,AFC->AFC_EDTPAI,aArrayTrb,aVlrFin,aFluxo)
EndIf

RestArea(aAreaAFC)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsRetFin ³ Autor ³ Edson Maricate        ³ Data ³ 04-07-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna os custos da tarefa,EDT ou Bloco de Trabalho          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsRetFinVal(aArrayTrb,nTipo,cCodigo)
Local aValFin := {0,0,0,0,0,0}

Do Case
	Case nTipo == 1
		nPosSeek := aScan(aArrayTrb,{|x|x[1]==cCodigo})
		If nPosSeek>0
			aValFin := aArrayTrb[nPosSeek,3]
		EndIf
	Case nTipo == 2
		nPosSeek := aScan(aArrayTrb,{|x|x[2]==cCodigo})
		If nPosSeek>0
			aValFin := aArrayTrb[nPosSeek,3]
		EndIf
	Case nTipo == 3
		nPosSeek := aScan(aArrayTrb,{|x|x[1]==cCodigo})
		If nPosSeek>0
			aValFin := aArrayTrb[nPosSeek,4]
		EndIf
	Case nTipo == 4
		nPosSeek := aScan(aArrayTrb,{|x|x[2]==cCodigo})
		If nPosSeek>0
			aValFin := aArrayTrb[nPosSeek,4]
		EndIf
EndCase

Return aValFin

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsRetFin³ Autor ³ Edson Maricate              ³ Data ³ 21-05-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que retorna os valores financeiros atuais da Tarefa         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aFluxo : array com os valores do fluxo sintetico                   ³±±
±±³          ³aAnaArrayTrb : array com os valores de cada dia analitico          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
aFluxo[1] - pedidos de compra
aFluxo[2] - array dos titulos/mov. bancaria a pagar
[data, soma do valor dos titulos desta data, soma dos titulos antecipado desta data]
aFluxo[3] - saldo de despesas inicial
aFluxo[4] - pedidos de venda
aFluxo[5] - array dos titulos/mov. bancaria a receber
[data, soma do valor dos titulos desta data, soma dos titulos antecipado desta data]
aFluxo[6] - saldo de receitas inicial
*/
Function PmsRetFin(cProjeto,cRevisa,cTarefa,lFluxo,aFluxo,nMoeda,dDataRef,aAnaArrayTrb)
Local cAlias
Local cAlias2
Local lQuery2    := .F.
Local lQuery     := .F.
Local aAuxRec    := {}
Local aRet       := {0,0,0,0,0,0}
Local aArea      := GetArea()
Local aAreaAFG   := AFG->(GetArea())
Local aAreaSD1   := SD1->(GetArea())
Local aAreaSD2   := SD1->(GetArea())
Local aAreaSC1   := SC1->(GetArea())
Local aAreaSC7   := SC7->(GetArea())
Local aAreaSE5   := SE5->(GetArea())
Local aAreaSF4   := SF4->(GetArea())
Local aRetorno	 := {}
Local cFilSC1    := ""
Local cFilOldSC1 := ""
Local cFilSC3    := ""
Local cFilOldSC3 := ""
Local cFilSD1    := xFilial("SD1")
Local cFilOldSD1 := ""
Local cFilSE2    := ""
Local cFilOldSE2 := ""
Local cFilSE1    := xFilial("SE1")
Local cFilOldSE1 := ""
Local cFilSC7	 := xFilial("SC7")
Local cFilOldSC7 := ""
Local cFilSF4     := xFilial("SF4")
Local cFilSD2     := xFilial("SD2")
Local nX          := 0
Local nPosDt      := 0
Local dDataAux
Local nValAux     := 0
Local cAliasSE1   := "SE1"
Local lTcSrvType  := TcSrvType() <> "AS/400"
Local lConsidera  := .T.
Local cFilAFG		:= xFilial("AFG")
Local cFilAFH		:= xFilial("AFH")
Local cFilSCQ		:= xFilial("SCQ")
Local cFilAJ7		:= xFilial("AJ7")
Local cFilAFL		:= xFilial("AFL")
Local cFilAFN		:= xFilial("AFN")
Local cFilAFR		:= xFilial("AFR")
Local cFilSC6		:= xFilial("SC6")
Local cFilSC5		:= xFilial("SC5")
Local cFilSF2		:= xFilial("SF2")
Local cFilAFT		:= xFilial("AFT")
Local cFilAJE		:= xFilial("AJE")
Local cFilSCP		:= xFilial("SCP")
Local cMv1DUPREF	:= SuperGetMV("MV_1DUPREF")
Local lCompAFG		:= FWModeAccess("AFG") == "E"
Local lCompSF4		:= FWModeAccess("SF4") == "E"
Local nValComp		:= 0
DEFAULT dDataRef     := PMS_MAX_DATE
DEFAULT lFluxo       := .F.
DEFAULT nMoeda       := 1
DEFAULT aAnaArrayTrb := {}

aFluxo := {{},{},0,{},{},0}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o Saldo atual por solicitacao de compras com pedido colocado  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AFG")
dbSetOrder(1)
MsSeek(cFilAFG+cProjeto+cRevisa+cTarefa)
While !Eof() .And. cFilAFG+cProjeto+cRevisa+cTarefa==;
	AFG->AFG_FILIAL+AFG->AFG_PROJET+AFG->AFG_REVISA+AFG->AFG_TAREFA

	cFilSC1 		:= PmsFilial("SC1","AFG")
	cFilOldSC1  := cFilAnt
	If cFilSC1 <> ""
		cFilAnt 	:= cFilSC1
	EndIf

	dbSelectArea("SC1")
	dbSetOrder(1)
	If MsSeek(cFilSC1+AFG->AFG_NUMSC+AFG->AFG_ITEMSC) .And. SC1->C1_QUJE <> 0 .And. SC1->C1_EMISSAO <= dDataRef
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o saldo em pedido de compras                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lTcSrvType
			lQuery := .T.
			cAlias := CriaTrab(,.F.)
			cQuery := "SELECT SC7.*,R_E_C_N_O_ SC7RECNO "
			cQuery += "FROM "+RetSqlName("SC7")+" SC7 WHERE "
			If lCompAFG
				cQuery += "SC7.C7_FILIAL='"+cFilSC7+"' AND "
			EndIf
			cQuery += "SC7.C7_PRODUTO='"+SC1->C1_PRODUTO+"' AND "
			cQuery += "SC7.C7_NUMSC='"+SC1->C1_NUM+"' AND "
			cQuery += "SC7.C7_ITEMSC='"+SC1->C1_ITEM+"' AND "
			cQuery += "SC7.C7_TIPO=1 AND "
			cQuery += "SC7.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			SC7->(dbCommit())
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
		Else

			cAlias := "SC7"
			dbSelectArea("SC7")
			dbSetOrder(2)
			MsSeek(cFilSC7+SC1->C1_PRODUTO)

		EndIf

		While ( !Eof() .And. (!lCompAFG .Or. cFilSC7 == (cAlias)->C7_FILIAL) .And. SC1->C1_PRODUTO == (cAlias)->C7_PRODUTO )
			If	SC1->C1_NUM == (cAlias)->C7_NUMSC .And.;
				SC1->C1_ITEM == (cAlias)->C7_ITEMSC .And.;
				(cAlias)->C7_TIPO == 1 .And.;
				(cAlias)->C7_CONAPRO <> 'B'

				If ( lQuery )
					SC7->(MsGoto((cAlias)->SC7RECNO))
				EndIf

				If SC7->C7_RESIDUO != "S" .and. SC7->C7_FLUXO != "N"

					If !lCompAFG .And. lCompSF4
						cFilSF4 := (cAlias)->C7_FILIAL
					EndIf

					SF4->(DbSetOrder(1)) //F4_FILIAL+F4_CODIGO
					If Empty((cAlias)->C7_TES) .Or.;
						(SF4->(DbSeek(cFilSF4+(cAlias)->C7_TES)) .And. SF4->F4_DUPLIC == "S" .And. SF4->F4_MOVPRJ $ '25') //Despesa ou receita e despesa (ao mesmo tempo)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Acumula o saldo referente a quantidade da SC                   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aRet[1] += xMoeda((AFG->AFG_QUANT/SC1->C1_QUANT)*(SC7->C7_QUANT-SC7->C7_QUJE)*SC7->C7_PRECO,SC7->C7_MOEDA,nMoeda,SC7->C7_DATPRF,TamSX3("D1_VUNIT")[2],SC7->C7_TXMOEDA,)
						If lFluxo
							aDupl := Condicao(xMoeda((AFG->AFG_QUANT/SC1->C1_QUANT)*(SC7->C7_QUANT-SC7->C7_QUJE)*SC7->C7_PRECO,SC7->C7_MOEDA,nMoeda,SC7->C7_DATPRF,TamSX3("D1_VUNIT")[2],SC7->C7_TXMOEDA,),SC7->C7_COND,0,SC7->C7_DATPRF,0)
							If Len(aDupl) > 0
								nAcerto := 0
								For nX := 1 To Len(aDupl)
									nAcerto += aDupl[nX,2]
								Next nX
								aDupl[Len(aDupl),2] += xMoeda((AFG->AFG_QUANT/SC1->C1_QUANT)*(SC7->C7_QUANT-SC7->C7_QUJE)*SC7->C7_PRECO,SC7->C7_MOEDA,nMoeda,SC7->C7_DATPRF,TamSX3("D1_VUNIT")[2],SC7->C7_TXMOEDA,) - nAcerto
								For nX := 1 To Len(aDupl)
									nPosDt := aScan(aFluxo[1],{|x| x[1]==aDupl[nX,1]})
									If nPosDt > 0
										aFluxo[1,nPosDt,2] += aDupl[nX,2]
									Else
										aAdd(aFluxo[1],{aDupl[nX,1],aDupl[nX,2]})
									EndIf
									//adiciona no array analitico o pedido de compra
									Aadd(aAnaArrayTrb,{cTarefa,aDupl[nX,1],"PEDIDO DE COMPRA",SC7->C7_FILIAL,SC7->C7_NUM,SC7->C7_ITEM,aDupl[nX,2]})
								Next nX
							Endif
						EndIf
					EndIf

					If SC7->C7_QUJE < SC7->C7_QUANT .and. SC7->C7_FLUXO != "N"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica o saldo em Notas Fiscais de Entrada                   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lTcSrvType
							lQuery2 := .T.
							cAlias2 := CriaTrab(,.F.)
							cQuery := "SELECT SD1.*,R_E_C_N_O_ SD1RECNO "
							cQuery += "FROM "+RetSqlName("SD1")+" SD1 "
							cQuery += "WHERE SD1.D1_FILIAL='"+cFilSD1+"' AND "
							cQuery += "SD1.D1_COD='"+SC7->C7_PRODUTO+"' AND "
							cQuery += "SD1.D1_PEDIDO='"+SC7->C7_NUM+"' AND "
							cQuery += "SD1.D1_ITEMPC='"+SC7->C7_ITEM+"' AND "
							cQuery += "SD1.D_E_L_E_T_ = ' '"
							cQuery := ChangeQuery(cQuery)
							SD1->(dbCommit())
							dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias2,.T.,.T.)
						Else

							cAlias2 := "SD1"
							dbSelectArea("SD1")
							dbSetOrder(2)
							MsSeek(cFilSD1+SC7->C7_PRODUTO)

						EndIf

						While ( !Eof() .And. cFilSD1 == (cAlias2)->D1_FILIAL .And.;
							SC7->C7_PRODUTO == (cAlias2)->D1_COD )

							If ( SC7->C7_NUM == (cAlias2)->D1_PEDIDO .And.;
								SC7->C7_ITEM == (cAlias2)->D1_ITEMPC )
								If ( lQuery2 )
									SD1->(MsGoto((cAlias2)->SD1RECNO))
								EndIf
								dbSelectArea("SD1")

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Acumula o saldo referente a quantidade da SC                   ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								PmsSldNFE(aRet,(AFG->AFG_QUANT / SC1->C1_QUANT),aAuxRec,cProjeto,cRevisa,cTarefa,lFluxo,aFluxo,nMoeda,dDataRef,aAnaArrayTrb)
							EndIf
							dbSelectArea(cAlias2)
							dbSkip()
						EndDo
						If ( lQuery2 )
							dbSelectArea(cAlias2)
							dbCloseArea()
						EndIf
					EndIf

				EndIf
			EndIf
			dbSelectArea(cAlias)
			dbSkip()
		EndDo
		If ( lQuery )
			dbSelectArea(cAlias)
			dbCloseArea()
		EndIf
	EndIf

	cFilAnt := cFilOldSC1
	dbSelectArea("AFG")
	dbSkip()

EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o Saldo atual por Pré-Requisição (SA) x SC x pedido colocado  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AFH")
dbSetOrder(1)
MsSeek(cFilAFH+cProjeto+cRevisa+cTarefa)
While !Eof() .And. cFilAFH+cProjeto+cRevisa+cTarefa==;
	AFH->AFH_FILIAL+AFH->AFH_PROJET+AFH->AFH_REVISA+AFH->AFH_TAREFA

	cFilSC1 		:= PmsFilial("SCP","AFH")
	cFilOldSC1  := cFilAnt
	If cFilSC1 <> ""
		cFilAnt 	:= cFilSC1
	EndIf

	dbSelectArea("SCQ")
	dbSetOrder(1) //CQ_FILIAL+CQ_NUM+CQ_ITEM+CQ_NUMSQ
	aRetorno := COMPosDHN({2,{'1',cFilSCP,AFH->AFH_NUMSA+AFH->AFH_ITEMSA}})
	If aRetorno[1]
		While !(aRetorno[2])->(Eof()) 
			MsSeek(cFilSCQ+(aRetorno[2])->(DHN_DOCORI+DHN_ITORI))
			dbSelectArea("SC1")
			dbSetOrder(1)
			If MsSeek(cFilSC1+(aRetorno[2])->(DHN_DOCDES+DHN_ITDES)) .And. SC1->C1_QUJE <> 0 .And. SC1->C1_EMISSAO <= dDataRef
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica o saldo em pedido de compras                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lTcSrvType
					#IFDEF TOP
						lQuery := .T.
						cAlias := CriaTrab(,.F.)
						cQuery := "SELECT SC7.*,R_E_C_N_O_ SC7RECNO "
						cQuery += "FROM "+RetSqlName("SC7")+" SC7 "
						cQuery += "WHERE SC7.C7_FILIAL='"+xFilial("SC7")+"' AND "
						cQuery += "SC7.C7_PRODUTO='"+SC1->C1_PRODUTO+"' AND "
						cQuery += "SC7.C7_NUMSC='"+SC1->C1_NUM+"' AND "
						cQuery += "SC7.C7_ITEMSC='"+SC1->C1_ITEM+"' AND "
						cQuery += "SC7.C7_TIPO=1 AND "
						cQuery += "SC7.D_E_L_E_T_ = ' '"
						cQuery := ChangeQuery(cQuery)
						SC7->(dbCommit())
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
					#ENDIF
				Else

					cAlias := "SC7"
					dbSelectArea("SC7")
					dbSetOrder(2)
					MsSeek(xFilial("SC7")+SC1->C1_PRODUTO)

				EndIf

				While ( !Eof() .And. xFilial("SC7") == (cAlias)->C7_FILIAL .And. SC1->C1_PRODUTO == (cAlias)->C7_PRODUTO )
					If	SC1->C1_NUM == (cAlias)->C7_NUMSC .And.;
						SC1->C1_ITEM == (cAlias)->C7_ITEMSC .And.;
						(cAlias)->C7_TIPO == 1 .And.;
						(cAlias)->C7_CONAPRO <> 'B'

						If ( lQuery )
							SC7->(MsGoto((cAlias)->SC7RECNO))
						EndIf

						If SC7->C7_RESIDUO != "S" .and. SC7->C7_FLUXO != "N"

							SF4->(DbSetOrder(1)) //F4_FILIAL+F4_CODIGO
							If Empty((cAlias)->C7_TES) .Or.;
								(SF4->(DbSeek(cFilSF4+(cAlias)->C7_TES)) .And. SF4->F4_DUPLIC == "S" .And. SF4->F4_MOVPRJ $ '25') //Despesa ou receita e despesa (ao mesmo tempo)

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Acumula o saldo referente a quantidade da Pre-Requisicao       ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								aRet[1] += xMoeda((AFH->AFH_QUANT/SCQ->CQ_QUANT)*(SC7->C7_QUANT-SC7->C7_QUJE)*SC7->C7_PRECO,SC7->C7_MOEDA,nMoeda,SC7->C7_DATPRF,TamSX3("D1_VUNIT")[2],SC7->C7_TXMOEDA,)
								If lFluxo
									aDupl := Condicao(xMoeda((AFH->AFH_QUANT/SCQ->CQ_QUANT)*(SC7->C7_QUANT-SC7->C7_QUJE)*SC7->C7_PRECO,SC7->C7_MOEDA,nMoeda,SC7->C7_DATPRF,TamSX3("D1_VUNIT")[2],SC7->C7_TXMOEDA,),SC7->C7_COND,0,SC7->C7_DATPRF,0)
									If Len(aDupl) > 0
										nAcerto := 0
										For nX := 1 To Len(aDupl)
											nAcerto += aDupl[nX,2]
										Next nX
										aDupl[Len(aDupl),2] += xMoeda((AFH->AFH_QUANT/SCQ->CQ_QUANT)*(SC7->C7_QUANT-SC7->C7_QUJE)*SC7->C7_PRECO,SC7->C7_MOEDA,nMoeda,SC7->C7_DATPRF,TamSX3("D1_VUNIT")[2],SC7->C7_TXMOEDA,) - nAcerto
										For nX := 1 To Len(aDupl)
											nPosDt := aScan(aFluxo[1],{|x| x[1]==aDupl[nX,1]})
											If nPosDt > 0
												aFluxo[1,nPosDt,2] += aDupl[nX,2]
											Else
												aAdd(aFluxo[1],{aDupl[nX,1],aDupl[nX,2]})
											EndIf
											//adiciona no array analitico o pedido de compra
											Aadd(aAnaArrayTrb,{cTarefa,aDupl[nX,1],"PEDIDO DE COMPRA",SC7->C7_FILIAL,SC7->C7_NUM,SC7->C7_ITEM,aDupl[nX,2]})
										Next nX
									Endif
								EndIf
							EndIf

							If SC7->C7_QUJE < SC7->C7_QUANT .and. SC7->C7_FLUXO != "N"
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Verifica o saldo em Notas Fiscais de Entrada                   ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If lTcSrvType
									#IFDEF TOP
										lQuery2 := .T.
										cAlias2 := CriaTrab(,.F.)
										cQuery := "SELECT SD1.*,R_E_C_N_O_ SD1RECNO "
										cQuery += "FROM "+RetSqlName("SD1")+" SD1 "
										cQuery += "WHERE SD1.D1_FILIAL='"+xFilial("SD1")+"' AND "
										cQuery += "SD1.D1_COD='"+SC7->C7_PRODUTO+"' AND "
										cQuery += "SD1.D1_PEDIDO='"+SC7->C7_NUM+"' AND "
										cQuery += "SD1.D1_ITEMPC='"+SC7->C7_ITEM+"' AND "
										cQuery += "SD1.D_E_L_E_T_ = ' '"
										cQuery := ChangeQuery(cQuery)
										SD1->(dbCommit())
										dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias2,.T.,.T.)
									#ENDIF
								Else

									cAlias2 := "SD1"
									dbSelectArea("SD1")
									dbSetOrder(2)
									MsSeek(xFilial("SD1")+SC7->C7_PRODUTO)

								EndIf

								While ( !Eof() .And. xFilial("SD1") == (cAlias2)->D1_FILIAL .And.;
									SC7->C7_PRODUTO == (cAlias2)->D1_COD )

									If ( SC7->C7_NUM == (cAlias2)->D1_PEDIDO .And.;
										SC7->C7_ITEM == (cAlias2)->D1_ITEMPC )
										If ( lQuery2 )
											SD1->(MsGoto((cAlias2)->SD1RECNO))
										EndIf
										dbSelectArea("SD1")

										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Acumula o saldo referente a quantidade da SC                   ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										PmsSldNFE(aRet,(AFH->AFH_QUANT/SCQ->CQ_QUANT),aAuxRec,cProjeto,cRevisa,cTarefa,lFluxo,aFluxo,nMoeda,dDataRef,aAnaArrayTrb)
									EndIf
									dbSelectArea(cAlias2)
									dbSkip()
								EndDo
								If ( lQuery2 )
									dbSelectArea(cAlias2)
									dbCloseArea()
								EndIf
							EndIf

						EndIf
					EndIf
					dbSelectArea(cAlias)
					dbSkip()
				EndDo
				If ( lQuery )
					dbSelectArea(cAlias)
					dbCloseArea()
				EndIf
			EndIf
			(aRetorno[2])->(DbSkip())
		EndDo
	EndIf
	cFilAnt := cFilOldSC1
	dbSelectArea("AFH")
	dbSkip()

EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o Saldo atual por pedido de compras  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AJ7")
dbSetOrder(1)
MsSeek(cFilAJ7+cProjeto+cRevisa+cTarefa)
While !Eof() .And. cFilAJ7+cProjeto+cRevisa+cTarefa==;
	AJ7->AJ7_FILIAL+AJ7->AJ7_PROJET+AJ7->AJ7_REVISA+AJ7->AJ7_TAREFA

	cFilSC7 		:= PmsFilial("SC7","AJ7")
	cFilOldSC7  := cFilAnt
	If cFilSC7 <> ""
		cFilAnt 	:= cFilSC7
	EndIf

	dbSelectArea("SC7")
	dbSetOrder(1)
	If MsSeek(cFilSC7+AJ7->AJ7_NUMPC+AJ7->AJ7_ITEMPC) .And. SC7->C7_EMISSAO <= dDataRef .And. SC7->C7_CONAPRO <> 'B'
		If SC7->C7_RESIDUO != "S" .and. SC7->C7_FLUXO != "N"

			SF4->(DbSetOrder(1)) //F4_FILIAL+F4_CODIGO
			If Empty(SC7->C7_TES) .Or.;
				(SF4->(DbSeek(cFilSF4+SC7->C7_TES)) .And. SF4->F4_DUPLIC == "S" .And. SF4->F4_MOVPRJ $ '25') //Despesa ou receita e despesa (ao mesmo tempo)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Acumula o saldo referente a quantidade da SC                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRet[1] += xMoeda((AJ7->AJ7_QUANT/SC7->C7_QUANT)*(SC7->C7_QUANT-SC7->C7_QUJE)*SC7->C7_PRECO,SC7->C7_MOEDA,nMoeda,SC7->C7_DATPRF,TamSX3("D1_VUNIT")[2],SC7->C7_TXMOEDA,)
				If lFluxo
					aDupl := Condicao(xMoeda((AJ7->AJ7_QUANT/SC7->C7_QUANT)*(SC7->C7_QUANT-SC7->C7_QUJE)*SC7->C7_PRECO,SC7->C7_MOEDA,nMoeda,SC7->C7_DATPRF,TamSX3("D1_VUNIT")[2],SC7->C7_TXMOEDA,),SC7->C7_COND,0,SC7->C7_DATPRF,0)
					If Len(aDupl) > 0
						nAcerto := 0
						For nX := 1 To Len(aDupl)
							nAcerto += aDupl[nX,2]
						Next nX
						aDupl[Len(aDupl),2] += xMoeda((AJ7->AJ7_QUANT/SC7->C7_QUANT)*(SC7->C7_QUANT-SC7->C7_QUJE)*SC7->C7_PRECO,SC7->C7_MOEDA,nMoeda,SC7->C7_DATPRF,TamSX3("D1_VUNIT")[2],SC7->C7_TXMOEDA,) - nAcerto
						For nX := 1 To Len(aDupl)
							nPosDt := aScan(aFluxo[1],{|x| x[1]==aDupl[nX,1]})
							If nPosDt > 0
								aFluxo[1,nPosDt,2] += aDupl[nX,2]
							Else
								aAdd(aFluxo[1],{aDupl[nX,1],aDupl[nX,2]})
							EndIf

							//adiciona no array analitico o pedido de compra
							Aadd(aAnaArrayTrb,{cTarefa,aDupl[nX,1],"PEDIDO DE COMPRA",SC7->C7_FILIAL,SC7->C7_NUM,SC7->C7_ITEM,aDupl[nX,2]})
						Next nX
					Endif
				EndIf
			EndIf

		EndIf

		If SC7->C7_QUJE < SC7->C7_QUANT .and. SC7->C7_FLUXO != "N"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o saldo em Notas Fiscais de Entrada                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTcSrvType
				lQuery2 := .T.
				cAlias2 := CriaTrab(,.F.)
				cQuery := "SELECT SD1.*,R_E_C_N_O_ SD1RECNO "
				cQuery += "FROM "+RetSqlName("SD1")+" SD1 "
				cQuery += "WHERE SD1.D1_FILIAL='"+cFilSD1+"' AND "
				cQuery += "SD1.D1_COD='"+SC7->C7_PRODUTO+"' AND "
				cQuery += "SD1.D1_PEDIDO='"+SC7->C7_NUM+"' AND "
				cQuery += "SD1.D1_ITEMPC='"+SC7->C7_ITEM+"' AND "
				cQuery += "SD1.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				SD1->(dbCommit())
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias2,.T.,.T.)
			Else

				cAlias2 := "SD1"
				dbSelectArea("SD1")
				dbSetOrder(2)
				MsSeek(cFilSD1+SC7->C7_PRODUTO)

			EndIf

			While ( !Eof() .And. cFilSD1 == (cAlias2)->D1_FILIAL .And.;
				SC7->C7_PRODUTO == (cAlias2)->D1_COD )

				If ( SC7->C7_NUM == (cAlias2)->D1_PEDIDO .And.;
					SC7->C7_ITEM == (cAlias2)->D1_ITEMPC )
					If ( lQuery2 )
						SD1->(MsGoto((cAlias2)->SD1RECNO))
					EndIf
					dbSelectArea("SD1")

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acumula o saldo referente a quantidade da SC                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PmsSldNFE(aRet,(AJ7->AJ7_QUANT / SC7->C7_QUANT),aAuxRec,cProjeto,cRevisa,cTarefa,lFluxo,aFluxo,nMoeda,dDataRef,aAnaArrayTrb)
				EndIf

				dbSelectArea(cAlias2)
				dbSkip()
			EndDo
			If ( lQuery2 )
				dbSelectArea(cAlias2)
				dbCloseArea()
			EndIf
		EndIf
	EndIf

	cFilAnt := cFilOldSC7
	dbSelectArea("AJ7")
	dbSkip()

End


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o Saldo atual por Contrato de Parceira     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AFL")
dbSetOrder(1)
MsSeek(cFilAFL+cProjeto+cRevisa+cTarefa)
While !Eof() .And. cFilAFL+cProjeto+cRevisa+cTarefa==;
	AFL->AFL_FILIAL+AFL->AFL_PROJET+AFL->AFL_REVISA+AFL->AFL_TAREFA

	cFilSC3 	:= PmsFilial("SC3","AFL")
	cFilOldSC3  := cFilAnt
	If cFilSC3 <> ""
		cFilAnt := cFilSC3
	EndIf

	dbSelectArea("SC3")
	dbSetOrder(1)
	If MsSeek(cFilSC3+AFL->AFL_NUMCP+AFL->AFL_ITEMCP) .And. SC3->C3_QUJE <> 0 .And. SC3->C3_EMISSAO <= dDataRef
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o saldo em Autorizacao de Entrega                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTcSrvType
			lQuery := .T.
			cAlias := CriaTrab(,.F.)
			cQuery := "SELECT SC7.*,R_E_C_N_O_ SC7RECNO "
			cQuery += "FROM "+RetSqlName("SC7")+" SC7 "
			cQuery += "WHERE SC7.C7_FILIAL='"+cFilSC7+"' AND "
			cQuery += "SC7.C7_PRODUTO='"+SC3->C3_PRODUTO+"' AND "
			cQuery += "SC7.C7_NUMSC='"+SC3->C3_NUM+"' AND "
			cQuery += "SC7.C7_ITEMSC='"+SC3->C3_ITEM+"' AND "
			cQuery += "SC7.C7_TIPO=2 AND "
			cQuery += "SC7.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			SC7->(dbCommit())
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
		Else

			cAlias := "SC7"
			dbSelectArea("SC7")
			dbSetOrder(2)
			MsSeek(cFilSC7+SC1->C1_PRODUTO)

		EndIf

		While ( !Eof() .And. cFilSC7 == (cAlias)->C7_FILIAL .And. SC3->C3_PRODUTO == (cAlias)->C7_PRODUTO )
			If	SC3->C3_NUM == (cAlias)->C7_NUMSC .And.;
				SC3->C3_ITEM == (cAlias)->C7_ITEMSC .And.;
				(cAlias)->C7_TIPO == 2 .And.;
				(cAlias)->C7_CONAPRO <> 'B'

				If ( lQuery )
					SC7->(MsGoto((cAlias)->SC7RECNO))
				EndIf

				If SC7->C7_RESIDUO != "S" .and. SC7->C7_FLUXO != "N"

					SF4->(DbSetOrder(1)) //F4_FILIAL+F4_CODIGO
					If Empty((cAlias)->C7_TES) .Or.;
						(SF4->(DbSeek(cFilSF4+(cAlias)->C7_TES)) .And. SF4->F4_DUPLIC == "S" .And. SF4->F4_MOVPRJ $ '25') //Despesa ou receita e despesa (ao mesmo tempo)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Acumula o saldo referente a quantidade do Contrato             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aRet[1] += xMoeda((AFL->AFL_QUANT/SC3->C3_QUANT)*(SC7->C7_QUANT-SC7->C7_QUJE)*SC7->C7_PRECO,SC7->C7_MOEDA,nMoeda,SC7->C7_DATPRF,TamSX3("D1_VUNIT")[2],SC7->C7_TXMOEDA,)
						If lFluxo
							aDupl := Condicao(xMoeda((AFL->AFL_QUANT/SC3->C3_QUANT)*(SC7->C7_QUANT-SC7->C7_QUJE)*SC7->C7_PRECO,SC7->C7_MOEDA,nMoeda,SC7->C7_DATPRF,TamSX3("D1_VUNIT")[2],SC7->C7_TXMOEDA,),SC7->C7_COND,0,SC7->C7_DATPRF,0)
							If Len(aDupl) > 0
								nAcerto := 0
								For nX := 1 To Len(aDupl)
									nAcerto += aDupl[nX,2]
								Next nX
								aDupl[Len(aDupl),2] += xMoeda((AFL->AFL_QUANT/SC3->C3_QUANT)*(SC7->C7_QUANT-SC7->C7_QUJE)*SC7->C7_PRECO,SC7->C7_MOEDA,nMoeda,SC7->C7_DATPRF,TamSX3("D1_VUNIT")[2],SC7->C7_TXMOEDA,) - nAcerto
								For nX := 1 To Len(aDupl)
									nPosDt := aScan(aFluxo[1],{|x| x[1]==aDupl[nX,1]})
									If nPosDt > 0
										aFluxo[1,nPosDt,2] += aDupl[nX,2]
									Else
										aAdd(aFluxo[1],{aDupl[nX,1],aDupl[nX,2]})
									EndIf
									//adiciona no array analitico o pedido de compra
									Aadd(aAnaArrayTrb,{cTarefa,aDupl[nX,1],"PEDIDO DE COMPRA",SC7->C7_FILIAL,SC7->C7_NUM,SC7->C7_ITEM,aDupl[nX,2]})
								Next nX
							Endif
						EndIf
					EndIf
				EndIf

				If SC7->C7_QUJE < SC7->C7_QUANT .and. SC7->C7_FLUXO != "N"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica o saldo em Notas Fiscais de Entrada                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lTcSrvType
						lQuery2 := .T.
						cAlias2 := CriaTrab(,.F.)
						cQuery := "SELECT SD1.*,R_E_C_N_O_ SD1RECNO "
						cQuery += "FROM "+RetSqlName("SD1")+" SD1 "
						cQuery += "WHERE SD1.D1_FILIAL='"+cFilSD1+"' AND "
						cQuery += "SD1.D1_COD='"+SC7->C7_PRODUTO+"' AND "
						cQuery += "SD1.D1_PEDIDO='"+SC7->C7_NUM+"' AND "
						cQuery += "SD1.D1_ITEMPC='"+SC7->C7_ITEM+"' AND "
						cQuery += "SD1.D_E_L_E_T_ = ' '"
						cQuery := ChangeQuery(cQuery)
						SD1->(dbCommit())
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias2,.T.,.T.)
					Else

						cAlias2 := "SD1"
						dbSelectArea("SD1")
						dbSetOrder(2)
						MsSeek(cFilSD1+SC7->C7_PRODUTO)

					EndIf

					While ( !Eof() .And. cFilSD1 == (cAlias2)->D1_FILIAL .And.;
						SC7->C7_PRODUTO == (cAlias2)->D1_COD )

						If ( SC7->C7_NUM == (cAlias2)->D1_PEDIDO .And.;
							SC7->C7_ITEM == (cAlias2)->D1_ITEMPC )
							If ( lQuery2 )
								SD1->(MsGoto((cAlias2)->SD1RECNO))
							EndIf
							// Abate a quantidade apontada para outras tarefas
							dbSelectArea("SD1")

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Acumula o saldo referente a quantidade do Contrato             ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							PmsSldNFE(aRet,(AFL->AFL_QUANT/SC3->C3_QUANT),aAuxRec,cProjeto,cRevisa,cTarefa,lFluxo,aFluxo,nMoeda,dDataRef,aAnaArrayTrb)
						EndIf
						dbSelectArea(cAlias2)
						dbSkip()
					EndDo
					If ( lQuery2 )
						dbSelectArea(cAlias2)
						dbCloseArea()
					EndIf
				EndIf
			EndIf
			dbSelectArea(cAlias)
			dbSkip()
		EndDo
		If ( lQuery )
			dbSelectArea(cAlias)
			dbCloseArea()
		EndIf
	EndIf

	cFilAnt	:= cFilOldSC3
	dbSelectArea("AFL")
	dbSkip()

End


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o Saldo atual por Notas Fiscais de Entrada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AFN")
dbSetOrder(1)
MsSeek(cFilAFN+cProjeto+cRevisa+cTarefa)
While !Eof() .And. cFilAFN+cProjeto+cRevisa+cTarefa==;
	AFN->AFN_FILIAL+AFN->AFN_PROJET+AFN->AFN_REVISA+AFN->AFN_TAREFA

	cFilSD1    := PmsFilial("SD1","AFN")
	cFilOldSD1 := cFilAnt
	If cFilSD1 <> ""
		cFilAnt := cFilSD1
	EndIf

	dbSelectArea("SD1")
	dbSetOrder(1)
	If MsSeek(cFilSD1+AFN->AFN_DOC+AFN->AFN_SERIE+AFN->AFN_FORNECE+AFN->AFN_LOJA+AFN->AFN_COD+AFN->AFN_ITEM) .And. ;
		SD1->D1_DTDIGIT <= dDataRef
		If aScan(aAuxRec,{|z| z[1]=="SD1"+cProjeto+cRevisa+cTarefa .And. z[2]==SD1->(RecNo())})<=0
			//Bruno D. Borges
			//19/11/2008
			//Incluido tratamento p/ considerar no fluxo de caixa mesmo AFNs sem movimentar estoque (AFN_ESTOQU)
			PmsSldNFE(aRet,PmsAFNQUANT("VALOR",,,"S")/PmsSD1QUANT(),aAuxRec,cProjeto,cRevisa,cTarefa,lFluxo,aFluxo,nMoeda,dDataRef,aAnaArrayTrb)
		EndIf
	EndIf

	cFilAnt	:= cFilOldSD1
	dbSelectArea("AFN")
	AFN->(dbSkip())

End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o Saldo atual por Titulos a Pagar          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AFR")
dbSetOrder(1)
MsSeek(cFilAFR+cProjeto+cRevisa+cTarefa)
While !Eof() .And. cFilAFR+cProjeto+cRevisa+cTarefa==;
	AFR->AFR_FILIAL+AFR->AFR_PROJET+AFR->AFR_REVISA+AFR->AFR_TAREFA

	cFilSE2    := PmsFilial("SE2","AFR")
	cFilOldSE2 := cFilAnt
	If cFilSE2 <> ""
		cFilAnt := cFilSE2
	EndIf

	dbSelectArea("SE2")
	dbSetOrder(1)
	If SE2->(MsSeek(xFilial()+AFR->AFR_PREFIXO+AFR->AFR_NUM+AFR->AFR_PARCELA+AFR->AFR_TIPO+AFR->AFR_FORNEC+AFR->AFR_LOJA))  .And. ;
		SE2->E2_EMISSAO <= dDataRef
		If aScan(aAuxRec,{|z| z[1]=="SE2"+cProjeto+cRevisa+cTarefa .And. z[2]==SE2->(RecNo())})<=0
			If SE2->E2_TIPO == MVPAGANT
				aRet[3] += xMoeda(SE2->E2_VALOR*(AFR->AFR_VALOR1/SE2->E2_VLCRUZ),SE2->E2_MOEDA,nMoeda,SE2->E2_VENCREA,8)
			Else
				If SE2->E2_TIPO == MVPAGANT  .OR. SE2->E2_TIPO $ MV_CPNEG
					aRet[5] += xMoeda(SE2->E2_SALDO*(AFR->AFR_VALOR1/SE2->E2_VLCRUZ),SE2->E2_MOEDA,nMoeda,SE2->E2_VENCREA,8)
				Else
					aRet[2] += xMoeda(SE2->E2_SALDO*(AFR->AFR_VALOR1/SE2->E2_VLCRUZ),SE2->E2_MOEDA,nMoeda,SE2->E2_VENCREA,8)
				EndIf
				aRet[3] += PmsBaixas(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,nMoeda,"P",SE2->E2_FORNECE,SE2->E2_LOJA,dDataRef,.F.)*(AFR->AFR_VALOR1/SE2->E2_VALOR)
			EndIf
			If lFluxo
				nValAux := SaldoTit(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_NATUREZ,"P",SE2->E2_FORNECE,nMoeda,dDataBase,dDataBase,SE2->E2_LOJA,,,1) // 1 = DT BAIXA    3 = DT DIGIT
				nValAux := nValAux * (AFR->AFR_VALOR1/SE2->E2_VLCRUZ) //apenas o valor amarrado ao projeto deve entrar no fluxo
				If SE2->E2_TIPO == MVPAGANT
					If SE2->E2_EMISSAO <= dDataBase
						aFluxo[3] += xMoeda(SE2->E2_VALOR*(AFR->AFR_VALOR1/SE2->E2_VLCRUZ),SE2->E2_MOEDA,nMoeda,SE2->E2_VENCREA,8)
					EndIf
					dDataAux := SE2->E2_EMISSAO
				Elseif !(SE2->E2_TIPO $ MV_CPNEG)
					aFluxo[3] += PmsBaixas(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,nMoeda,"P",SE2->E2_FORNECE,SE2->E2_LOJA,dDataRef,.T.)*(AFR->AFR_VALOR1/SE2->E2_VLCRUZ)
					dDataAux := SE2->E2_VENCREA
				Endif

				nPosDt := aScan(aFluxo[2],{|x| x[1]==dDataAux})
				If nPosDt > 0
					If SE2->E2_TIPO $ MVABATIM		 // Se for abatimento
						aFluxo[5,nPosDt,2] += nValAux
					Else
						If SE2->E2_TIPO == MVPAGANT
							aFluxo[2,nPosDt,3] += nValAux
						Elseif !(SE2->E2_TIPO $ MV_CPNEG)
							aFluxo[2,nPosDt,2] += nValAux
						Endif
					EndIf
				Else
					If SE2->E2_TIPO $ MVABATIM		 // Se for abatimento
						aAdd(aFluxo[5],{SE2->E2_VENCREA,nValAux,0})
					Else
						If SE2->E2_TIPO == MVPAGANT
							aAdd(aFluxo[2],{SE2->E2_EMISSAO,      0,nValAux})
						Elseif  !(SE2->E2_TIPO $ MV_CPNEG)
							aAdd(aFluxo[2],{SE2->E2_VENCREA,nValAux,0})
						Endif
					Endif
				EndIf
				//adiciona no array analitico o Titulo a Pagar
				If nValAux != 0
					If IsInCallStack("PMSC100")
						Aadd(aAnaArrayTrb,{cTarefa,dDataAux,"TITULO PAGAR",SE2->E2_FILIAL,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,nValAux})
					Elseif ( !(SE2->E2_TIPO==MVPAGANT) .Or. (SE2->E2_TIPO==MVPAGANT .And. SE2->E2_EMISSAO>dDataBase) )
						Aadd(aAnaArrayTrb,{cTarefa,dDataAux,"TITULO PAGAR",SE2->E2_FILIAL,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,nValAux})
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	cFilAnt  := cFilOldSE2
	dbSelectArea("AFR")
	dbSkip()

End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o Saldo atual por pedido de vendas         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC6")
dbSetOrder(8)
MsSeek(cFilSC6+cProjeto+cTarefa)
While !Eof() .And. cFilSC6+Alltrim(cProjeto)+Alltrim(cTarefa)==;
	SC6->C6_FILIAL+Alltrim(SC6->C6_PROJPMS)+Alltrim(SC6->C6_TASKPMS)

	SC5->(dbSetOrder(1))
	SC5->(MsSeek(cFilSC5+SC6->C6_NUM))

	If existblock("PMSRETPV",.F.,.F.)
		lConsidera := execblock("PMSRETPV",.F.,.F.,{lFluxo})
	EndIf

	SF4->(dbSetOrder(1))
	If SF4->(DbSeek(cFilSF4+SC6->C6_TES)) .And. SF4->F4_DUPLIC == "S".And. SF4->F4_MOVPRJ $ '15' .AND. lConsidera
		If SC5->C5_EMISSAO <= dDataRef
			aRet[4] += xMoeda(((SC6->C6_QTDVEN-SC6->C6_QTDENT)*SC6->C6_PRCVEN),SC5->C5_MOEDA,nMoeda,SC6->C6_ENTREG,8)
			If lFluxo
				aDupl := Condicao(xMoeda(((SC6->C6_QTDVEN-SC6->C6_QTDENT)*SC6->C6_PRCVEN),SC5->C5_MOEDA,nMoeda,SC6->C6_ENTREG,8),SC5->C5_CONDPAG,0,SC6->C6_ENTREG,0)
				If Len(aDupl) > 0
					nAcerto := 0
					For nX := 1 To Len(aDupl)
						nAcerto += aDupl[nX,2]
					Next nX
					aDupl[Len(aDupl),2] += xMoeda(((SC6->C6_QTDVEN-SC6->C6_QTDENT)*SC6->C6_PRCVEN),SC5->C5_MOEDA,nMoeda,SC6->C6_ENTREG,8) - nAcerto
					For nX := 1 To Len(aDupl)
						nPosDt := aScan(aFluxo[4],{|x| x[1]==aDupl[nX,1]})
						If nPosDt > 0
							aFluxo[4,nPosDt,2] += aDupl[nX,2]
						Else
							aAdd(aFluxo[4],{aDupl[nX,1],aDupl[nX,2]})
						EndIf
						//adiciona no array analitico o Pedido de Venda
						Aadd(aAnaArrayTrb,{cTarefa,aDupl[nX,1],"PEDIDO DE VENDA",SC6->C6_FILIAL,SC6->C6_NUM,SC6->C6_ITEM,aDupl[nX,2]})
					Next nX
				Endif
			EndIf
		EndIf
	EndIf
	If SC6->C6_QTDENT <> 0 .And. SC5->C5_EMISSAO <= dDataRef
		dbSelectArea("SD2")
		dbSetOrder(8)
		MsSeek(cFilSD2+SC6->C6_NUM+SC6->C6_ITEM)
		While !Eof() .And. cFilSD2+SC6->C6_NUM+SC6->C6_ITEM==;
			SD2->D2_FILIAL+SD2->D2_PEDIDO+SD2->D2_ITEMPV

			SF4->(DbSetOrder(1)) //F4_FILIAL+F4_CODIGO
			If SF4->(DbSeek(cFilSF4+SD2->D2_TES)) .And. SF4->F4_DUPLIC == "S" .And. SF4->F4_MOVPRJ $ '15'//Receita ou receita e despesa (ao mesmo tempo)

				dbSelectArea("SF2")
				dbSetOrder(1)
				MsSeek(cFilSF2+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Carega o Array contendo as Duplicatas a Receber (SE1)   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cSerie := If(Empty(SF2->F2_PREFIXO),&(cMv1DUPREF),SF2->F2_PREFIXO)
				cSerie := PadR(cSerie,Len(SE1->E1_PREFIXO))

				If lTcSrvType
						lQuery    := .T.
						cAliasSE1 := CriaTrab(,.F.)
						aStruSE1  := SE1->(dbStruct())
						cQuery := "SELECT SE1.*,SE1.R_E_C_N_O_ RECSE1 FROM "
						cQuery += RetSqlName("SE1") + " SE1 "
						cQuery += " WHERE "
						cQuery += "E1_FILIAL = '"+cFilSE1+"' AND "
						cQuery += "E1_CLIENTE = '"+SF2->F2_CLIENTE+"' AND "
						cQuery += "E1_LOJA = '"+SF2->F2_LOJA+"' AND "
						cQuery += "E1_PREFIXO = '"+cSerie+"' AND "
						cQuery += "E1_NUM = '"+SF2->F2_DOC+"' AND "
						cQuery += "SE1.D_E_L_E_T_ = ' ' "
						cQuery := ChangeQuery(cQuery)
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE1,.F.,.T.)
						For nX := 1 To Len(aStruSE1)
							If aStruSE1[nX,2]!="C"
								TcSetField(cAliasSE1,aStruSE1[nX,1],aStruSE1[nX,2],aStruSE1[nX,3],aStruSE1[nX,4])
							EndIf
						Next nX
				Else

					DbSelectArea("SE1")
					SE1->(DbSetOrder(2))
					MsSeek(cFilSE1+SF2->F2_CLIENTE+SF2->F2_LOJA+cSerie+SF2->F2_DOC)

				Endif


				While !Eof() .And. (cAliasSE1)->E1_FILIAL == cFilSE1 .And.;
					(cAliasSE1)->E1_CLIENTE == SF2->F2_CLIENTE .And.;
					(cAliasSE1)->E1_LOJA == SF2->F2_LOJA .And. ;
					(cAliasSE1)->E1_PREFIXO == cSerie .And. ;
					(cAliasSE1)->E1_NUM == SF2->F2_DOC
					nValAux := xMoeda((cAliasSE1)->E1_SALDO*(SD2->D2_TOTAL/SF2->F2_VALFAT),(cAliasSE1)->E1_MOEDA,nMoeda,(cAliasSE1)->E1_VENCREA,8)
					If (cAliasSE1)->E1_TIPO $ MVABATIM		 // Se for abatimento
						aRet[2] += nValAux
					Else
						aRet[5] += nValAux
					EndIf
					aRet[6] += PmsBaixas((cAliasSE1)->E1_PREFIXO,(cAliasSE1)->E1_NUM,(cAliasSE1)->E1_PARCELA,(cAliasSE1)->E1_TIPO,nMoeda,"R",(cAliasSE1)->E1_CLIENTE,(cAliasSE1)->E1_LOJA,dDataRef,.F.)*(SD2->D2_TOTAL/SF2->F2_VALFAT)

					If lFluxo
						aFluxo[6] += PmsBaixas((cAliasSE1)->E1_PREFIXO,(cAliasSE1)->E1_NUM,(cAliasSE1)->E1_PARCELA,(cAliasSE1)->E1_TIPO,nMoeda,"R",(cAliasSE1)->E1_CLIENTE,(cAliasSE1)->E1_LOJA, dDataRef,.T.)*(SD2->D2_TOTAL/SF2->F2_VALFAT)

						If lTcSrvType
							//o posicionamento no SE2 eh necessario pois a funcao SALDOTIT utiliza este posicionamento
							SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
							SE1->(DbSeek((cAliasSE1)->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) ))
						Endif


						nValAux := SaldoTit((cAliasSE1)->E1_PREFIXO,(cAliasSE1)->E1_NUM,(cAliasSE1)->E1_PARCELA,(cAliasSE1)->E1_TIPO,(cAliasSE1)->E1_NATUREZ,"R",(cAliasSE1)->E1_CLIENTE,nMoeda,dDataBase,dDataBase,SE1->E1_LOJA,,,1) // 1 = DT BAIXA    3 = DT DIGIT
						nValAux := nValAux * (SD2->D2_TOTAL/SF2->F2_VALFAT)

						nPosDt := aScan(aFluxo[5],{|x| x[1]==(cAliasSE1)->E1_VENCREA})
						If nPosDt > 0
							If (cAliasSE1)->E1_TIPO $ MVABATIM		 // Se for abatimento
								aFluxo[2,nPosDt,2] += nValAux
							Else
								aFluxo[5,nPosDt,2] += nValAux
								//adiciona no array analitico a NF
								Aadd(aAnaArrayTrb,{cTarefa,(cAliasSE1)->E1_VENCREA,"NOTA FISCAL",SD2->D2_FILIAL,SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_ITEM,SD2->D2_COD,SD2->D2_CLIENTE,SD2->D2_LOJA,nValAux})
							EndIf
						Else
							If (cAliasSE1)->E1_TIPO $ MVABATIM		 // Se for abatimento
								aAdd(aFluxo[2],{(cAliasSE1)->E1_VENCREA,nValAux,0})
							Else
								aAdd(aFluxo[5],{(cAliasSE1)->E1_VENCREA,nValAux,0})
								//adiciona no array analitico a NF
								Aadd(aAnaArrayTrb,{cTarefa,(cAliasSE1)->E1_VENCREA,"NOTA FISCAL",SD2->D2_FILIAL,SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_ITEM,SD2->D2_COD,SD2->D2_CLIENTE,SD2->D2_LOJA,nValAux})
							EndIf
						EndIf

					EndIf
					(cAliasSE1)->(DbSkip())
				EndDo

				If lQuery
					dbSelectArea(cAliasSE1)
					dbCloseArea()
				EndIf
			EndIf
			DbSelectArea("SD2")
			DbSkip()
		EndDo
	EndIf
	dbSelectArea("SC6")
	dbSkip()
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o Saldo atual por Titulos a Receber        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AFT")
dbSetOrder(1)
MsSeek(cFilAFT+cProjeto+cRevisa+cTarefa)
While !Eof() .And. cFilAFT+cProjeto+cRevisa+cTarefa==;
	AFT->AFT_FILIAL+AFT->AFT_PROJET+AFT->AFT_REVISA+AFT->AFT_TAREFA

	cFilSE1 	:= PmsFilial("SE1","AFT")
	cFilOldSE1  := cFilAnt
	If cFilSE1 <> ""
		cFilAnt := cFilSE1
	EndIf

	SE1->(dbSetOrder(1))
	If SE1->(MsSeek(cFilSE1+AFT->AFT_PREFIXO+AFT->AFT_NUM+AFT->AFT_PARCELA+AFT->AFT_TIPO+AFT->AFT_CLIENT+AFT->AFT_LOJA)) .And. ;
		SE1->E1_EMISSAO <= dDataRef
		If SE1->E1_TIPO = "RA " .And. SE1->E1_SALDO < SE1->E1_VALOR
			nValComp := CalcComp(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_VALOR,cProjeto,cRevisa,cTarefa)
			nValAux := xMoeda((AFT->AFT_VALOR1-nValComp),SE1->E1_MOEDA,nMoeda,SE1->E1_VENCREA,8)	//Calcula valor compensado
			aRet[6] += (PmsBaixas(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,nMoeda,"R",SE1->E1_CLIENTE,SE1->E1_LOJA,dDataRef,.F.)*(AFT->AFT_VALOR1/SE1->E1_VLCRUZ))-nValComp
		Else 
			nValAux := xMoeda(SE1->E1_SALDO*(AFT->AFT_VALOR1/SE1->E1_VLCRUZ),SE1->E1_MOEDA,nMoeda,SE1->E1_VENCREA,8)
			aRet[6] += (PmsBaixas(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,nMoeda,"R",SE1->E1_CLIENTE,SE1->E1_LOJA,dDataRef,.F.)*(AFT->AFT_VALOR1/SE1->E1_VLCRUZ))
		EndIf
		If SE1->E1_TIPO $ MVABATIM .or. SE1->E1_TIPO $ MV_CRNEG		 // Se for abatimento ou nota de credito
			aRet[2] += nValAux
		Else
			aRet[5] += nValAux
		EndIf

		If lFluxo
			If SE1->E1_TIPO == MVRECANT
				If SE1->E1_EMISSAO <= dDataBase
					aFluxo[6] += xMoeda(SE1->E1_VALOR*(AFT->AFT_VALOR1/SE1->E1_VLCRUZ),SE1->E1_MOEDA,nMoeda,SE1->E1_VENCREA,8)
				EndIf
				dDataAux := SE1->E1_EMISSAO
			Elseif  !(SE1->E1_TIPO $ MV_CRNEG)
				aFluxo[6] += PmsBaixas(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,nMoeda,"R",SE1->E1_CLIENTE,SE1->E1_LOJA, dDataRef,.T.)*(AFT->AFT_VALOR1/SE1->E1_VLCRUZ)
				dDataAux := SE1->E1_VENCREA
			EndIf

			nPosDt := aScan(aFluxo[5],{|x| x[1]==dDataAux})

			nValAux := SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,nMoeda,dDataBase,dDataBase,SE1->E1_LOJA,,,1) // 1 = DT BAIXA    3 = DT DIGIT
			nValAux := nValAux * (AFT->AFT_VALOR1/SE1->E1_VLCRUZ)  //apenas o valor amarrado ao projeto deve entrar no fluxo
			If nPosDt > 0
				If SE1->E1_TIPO $ MVABATIM		 // Se for abatimento
					aFluxo[2,nPosDt,2] += xMoeda((cAliasSE1)->E1_SALDO*(SD2->D2_TOTAL/SF2->F2_VALMERC),(cAliasSE1)->E1_MOEDA,nMoeda,(cAliasSE1)->E1_VENCREA,8)
				Else
					If SE1->E1_TIPO == MVRECANT
						aFluxo[5,nPosDt,3] += nValAux
					Elseif  !(SE1->E1_TIPO $ MV_CRNEG)
						aFluxo[5,nPosDt,2] += nValAux
					EndIf
				EndIf
			Else
				If SE1->E1_TIPO $ MVABATIM		 // Se for abatimento
					aAdd(aFluxo[2],{SE1->E1_VENCREA,nValAux,0})
				Else
					If SE1->E1_TIPO == MVRECANT
						aAdd(aFluxo[5],{dDataAux,      0,nValAux})
					Elseif  !(SE1->E1_TIPO $ MV_CRNEG)
						aAdd(aFluxo[5],{SE1->E1_VENCREA,nValAux,0})
					EndIf
				EndIf
			EndIf
			//adiciona no array analitico o Titulo a Receber
			If nValAux != 0
					If IsInCallStack("PMSC100")
						Aadd(aAnaArrayTrb,{cTarefa,dDataAux,"TITULO RECEBER",SE1->E1_FILIAL,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,nValAux})
					Elseif ( !(SE1->E1_TIPO==MVRECANT) .Or. (SE1->E1_TIPO==MVRECANT .And. SE1->E1_EMISSAO>dDataBase) )
						Aadd(aAnaArrayTrb,{cTarefa,dDataAux,"TITULO RECEBER",SE1->E1_FILIAL,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,nValAux})
					EndIf
				EndIf
		EndIf
	EndIf

	cFilAnt := cFilOldSE1
	dbSelectArea("AFT")
	dbSkip()
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o Saldo atual por Movimentacao Bancaria - Tarefa ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SE5->(dbSetOrder(9))
dbSelectArea("AJE")
dbSetOrder(1)
MsSeek(cFilAJE+cProjeto+cRevisa+cTarefa)
While !Eof() .And. AJE_FILIAL+AJE_PROJET+AJE_REVISA+AJE_TAREFA==;
	cFilAJE+cProjeto+cRevisa+cTarefa
	If SE5->(dbSeek(PmsFilial("SE5","AJE")+AJE->AJE_ID)).And.SE5->E5_SITUACA <> "C" .And. ;
		SE5->E5_SITUACA <> "X" .And. SE5->E5_SITUACA <> "E"

		If SE5->E5_DTDISPO <= dDataBase //vai para o saldo inicial
			If SE5->E5_RECPAG=="P"
				aRet[3] += xMoeda(AJE->AJE_VALOR,1,nMoeda,SE5->E5_DTDISPO,8)
				If lFluxo
					aFluxo[3] += xMoeda(AJE->AJE_VALOR,1,nMoeda,SE5->E5_DTDISPO,8)
				EndIf
				Aadd(aAnaArrayTrb,{cTarefa,SE5->E5_DTDISPO,"MOV.BANCARIA PAGAR",SE5->E5_MOEDA,SE5->E5_NATUREZ,SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,AJE->AJE_VALOR})
			Else
				aRet[6] += xMoeda(AJE->AJE_VALOR,1,nMoeda,SE5->E5_DTDISPO,8)
				If lFluxo
					aFluxo[6] += xMoeda(AJE->AJE_VALOR,1,nMoeda,SE5->E5_DTDISPO,8)
				EndIf
				Aadd(aAnaArrayTrb,{cTarefa,SE5->E5_DTDISPO,"MOV.BANCARIA RECEBER",SE5->E5_MOEDA,SE5->E5_NATUREZ,SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,AJE->AJE_VALOR})
			EndIf
		Else //vai para o fluxo
			If SE5->E5_RECPAG=="P"
				nPosDt := aScan(aFluxo[2],{|x| x[1]==SE5->E5_DTDISPO})
				If nPosDt > 0
					aFluxo[2,nPosDt,2] += xMoeda(AJE->AJE_VALOR,1,nMoeda,SE5->E5_DTDISPO,8)
				Else
					aAdd(aFluxo[2],{SE5->E5_DTDISPO,xMoeda(AJE->AJE_VALOR,1,nMoeda,SE5->E5_DTDISPO,8),0})
				EndIf
				//adiciona no array analitico a movimentacao bancaria
				Aadd(aAnaArrayTrb,{cTarefa,SE5->E5_DTDISPO,"MOV.BANCARIA PAGAR",SE5->E5_MOEDA,SE5->E5_NATUREZ,SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,AJE->AJE_VALOR})
			Else
				nPosDt := aScan(aFluxo[5],{|x| x[1]==SE5->E5_DTDISPO})
				If nPosDt > 0
					aFluxo[5,nPosDt,2] += xMoeda(AJE->AJE_VALOR,1,nMoeda,SE5->E5_DTDISPO,8)
				Else
					aAdd(aFluxo[5],{SE5->E5_DTDISPO,xMoeda(AJE->AJE_VALOR,1,nMoeda,SE5->E5_DTDISPO,8),0})
				EndIf
				//adiciona no array analitico a movimentacao bancaria
				Aadd(aAnaArrayTrb,{cTarefa,SE5->E5_DTDISPO,"MOV.BANCARIA RECEBER",SE5->E5_MOEDA,SE5->E5_NATUREZ,SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,AJE->AJE_VALOR})
			EndIf

		EndIf
	EndIf
	dbSelectArea("AJE")
	dbSKip()
End


RestArea(aAreaSF4)
RestArea(aAreaSD1)
RestArea(aAreaSD2)
RestArea(aAreaSE5)
RestArea(aAreaSC7)
RestArea(aAreaSC1)
RestArea(aAreaAFG)
RestArea(aArea)
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsSldNFE³ Autor ³ Edson Maricate              ³ Data ³ 21-05-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula o valor do Documento de Entrada que nao foi pago.         ³±±
±±³          ³ A tabela SD1 deve estar posicionada.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aFluxo : array com valores sinteticos por dia                      ³±±
±±³          |aAnaArrayTrb : array com os valores de cada dia analitico          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsSldNFE(aRet,nCoef,aAuxRec,cProjeto,cRevisa,cTarefa,lFluxo,aFluxo,nMoeda,dDataRef,aAnaArrayTrb)
Local cPrefixo
Local cAliasSE2 := "SE2"
Local lQuery    := .F.
Local aArea     := GetArea()
Local aAreaSF4  := SF4->(GetArea())
Local nY        := 0
Local cMunic    := ""
Local aParcela  := {}
Local aFornece  := {}
Local aTmpArea  := {}
Local nPosDt    := 0
Local nValAux   := 0
Local cFilSE2   := xFilial("SE2")
Local lTcSrvType := TcSrvType()<>"AS/400"
Local lVerLib 	:= FWLibVersion() >= "20211116"
Local oQrySE2 	:= Nil
Local nPos1	  	:= 0

DEFAULT nMoeda	:= 1
DEFAULT dDataRef := dDataBase
Default aAnaArrayTrb := {}

aAdd(aAuxRec,{"SD1"+cProjeto+cRevisa+cTarefa ,SD1->(RecNo())})

SF4->(DbSetOrder(1)) //F4_FILIAL+F4_CODIGO
If (SF4->(DbSeek(xFilial("SF4")+SD1->D1_TES)) .And. SF4->F4_DUPLIC == "S" .And. SF4->F4_MOVPRJ $ '25') //Despesa ou receita e despesa (ao mesmo tempo)
	dbSelectArea("SF1")
	dbSetOrder(1)
	MsSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_TIPO)
	cPrefixo := IIf(Empty(SF1->F1_PREFIXO),&(SuperGetMV("MV_2DUPREF")),SF1->F1_PREFIXO)
	cPrefixo := PadR(cPrefixo,Len(SE2->E2_PREFIXO))

	If lTcSrvType
		lQuery    := .T.
		aStruSE2  := SE2->(dbStruct())
		cAliasSE2 := GetNextAlias()
		cQuery    := "SELECT E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, "
		cQuery    += "E2_PARCELA,E2_TIPO, E2_NATUREZ, E2_VENCREA, "
		cQuery    += "E2_PARCIR, E2_PARCINS, E2_PARCISS, E2_PARCCSS, "
		cQuery    += "E2_PARCPIS, E2_PARCCOF, E2_PARCSLL, SE2.R_E_C_N_O_ SE2RECNO "
		cQuery    += "FROM "+RetSqlName("SE2")+" SE2 "
		cQuery    += "WHERE SE2.E2_FILIAL = ? "
		cQuery    += "AND SE2.E2_FORNECE = ? "
		cQuery    += "AND SE2.E2_LOJA = ? "
		cQuery    += "AND SE2.E2_PREFIXO = ? "
		cQuery    += "AND SE2.E2_NUM = ? "
		cQuery    += "AND SE2.E2_TIPO = ? "
		cQuery    += "AND SE2.D_E_L_E_T_ = ? "
		cQuery    += "ORDER BY "+SqlOrder(SE2->(IndexKey(6)))

		cQuery := ChangeQuery(cQuery)

		oQrySE2 := IIf(lVerLib,FwExecStatement():New(cQuery),FWPreparedStatement():New(cQuery))

		oQrySE2:SetString(1,cFilSE2)	
		oQrySE2:SetString(2,SF1->F1_FORNECE)
		oQrySE2:SetString(3,SF1->F1_LOJA)
		oQrySE2:SetString(4,cPrefixo)
		oQrySE2:SetString(5,SF1->F1_DUPL)
		oQrySE2:SetString(6,'NF')
		oQrySE2:SetString(7,' ')
		
		If lVerLib
			cAliasSE2 := oQrySE2:OpenAlias()
			dbSelectArea(cAliasSE2)
		Else
			cQuery := oQrySE2:GetFixQuery()
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE2,.T.,.T.)
		EndIf

		nPos1 := ASCAN(aStruSE2,  {|x| X[1] = "E2_VENCREA"})
		TcSetField(cAliasSE2,aStruSE2[nPos1,1],aStruSE2[nPos1,2],aStruSE2[nPos1,3],aStruSE2[nPos1,4])
		
	Else

		DbSelectArea("SE2")
		SE2->(dbSetOrder(6))
		SE2->(MsSeek(xFilial()+SF1->F1_FORNECE+SF1->F1_LOJA+cPrefixo+SF1->F1_DUPL))

	EndIf


	While ( !Eof() .And. ;
		cFilSE2 == (cAliasSE2)->E2_FILIAL .And.;
		SF1->F1_FORNECE == (cAliasSE2)->E2_FORNECE .And.;
		SF1->F1_LOJA == (cAliasSE2)->E2_LOJA .And.;
		cPrefixo == (cAliasSE2)->E2_PREFIXO .And.;
		SF1->F1_DUPL == (cAliasSE2)->E2_NUM )
		If (cAliasSE2)->E2_TIPO == "NF "
			If lTcSrvType
				aAdd(aAuxRec,{"SE2"+cProjeto+cRevisa+cTarefa ,(cAliasSE2)->SE2RECNO})
				SE2->(DbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
				SE2->(DbSeek((cAliasSE2)->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO) )) //o posicionamento no SE2 eh necessario pois a funcao SALDOTIT utiliza este posicionamento
			EndIf
			nValAux := SaldoTit((cAliasSE2)->E2_PREFIXO,(cAliasSE2)->E2_NUM,(cAliasSE2)->E2_PARCELA,(cAliasSE2)->E2_TIPO,(cAliasSE2)->E2_NATUREZ,"P",(cAliasSE2)->E2_FORNECE,nMoeda,dDataBase,dDataBase,(cAliasSE2)->E2_LOJA,,,1) // 1 = DT BAIXA    3 = DT DIGIT
			nValAux := nValAux * (SD1->D1_TOTAL/SF1->F1_VALMERC)*nCoef
			aRet[2] += nValAux
			aRet[3] += PmsBaixas((cAliasSE2)->E2_PREFIXO,(cAliasSE2)->E2_NUM,(cAliasSE2)->E2_PARCELA,(cAliasSE2)->E2_TIPO,nMoeda,"P",(cAliasSE2)->E2_FORNECE,(cAliasSE2)->E2_LOJA,dDataRef,.F.)*(SD1->D1_TOTAL/SF1->F1_VALMERC)*nCoef

			If lFluxo
				aFluxo[3] += PmsBaixas((cAliasSE2)->E2_PREFIXO,(cAliasSE2)->E2_NUM,(cAliasSE2)->E2_PARCELA,(cAliasSE2)->E2_TIPO,nMoeda,"P",(cAliasSE2)->E2_FORNECE,(cAliasSE2)->E2_LOJA,dDataRef,.T.)*(SD1->D1_TOTAL/SF1->F1_VALMERC)*nCoef
				nPosDt := aScan(aFluxo[2],{|x| x[1]==(cAliasSE2)->E2_VENCREA})
				If nPosDt > 0
					aFluxo[2,nPosDt,2] += nValAux
				Else
					aAdd(aFluxo[2],{(cAliasSE2)->E2_VENCREA,nValAux,0})
				EndIf
				//adiciona no array analitico o Documento de Entrada
				Aadd(aAnaArrayTrb,{cTarefa,(cAliasSE2)->E2_VENCREA,"DOCUMENTO ENTRADA",SD1->D1_FILIAL,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_ITEM,SD1->D1_COD,SD1->D1_FORNECE,SD1->D1_LOJA,nValAux})
			EndIf

			aTmpArea := GetArea()
			aParcela := {}
			cMunic   := PadR(SuperGetMv("MV_MUNIC"),Len((cAliasSE2)->E2_FORNECE))
			aFornece := {{PadR(SuperGetMv('MV_UNIAO'),Len((cAliasSE2)->E2_FORNECE)),PadR(IIf(SubStr(SuperGetMv('MV_UNIAO'),Len((cAliasSE2)->E2_FORNECE)+1)<>"",SubStr(SuperGetMv('MV_UNIAO'),Len((cAliasSE2)->E2_FORNECE)+1),"00"),Len((cAliasSE2)->E2_LOJA)),PadR('TX',Len((cAliasSE2)->E2_TIPO)),"E2_PARCIR",{ || .T. }},;
			{PadR(SuperGetMv('MV_FORINSS'),Len((cAliasSE2)->E2_FORNECE)),PadR(IIf(SubStr(SuperGetMv('MV_FORINSS'),Len((cAliasSE2)->E2_FORNECE)+1)<>"",SubStr(SuperGetMv('MV_FORINSS'),Len((cAliasSE2)->E2_FORNECE)+1),"00"),Len((cAliasSE2)->E2_LOJA)),PadR('INS',Len((cAliasSE2)->E2_TIPO)),"E2_PARCINS",{ || .T. }},;
			{Left(cMunic,Len((cAliasSE2)->E2_FORNECE)),PadR(IIf(SubStr(cMunic,Len((cAliasSE2)->E2_FORNECE)+1)<>"",SubStr(cMunic,Len((cAliasSE2)->E2_FORNECE)+1),"00"),Len((cAliasSE2)->E2_LOJA)),PadR('ISS',Len((cAliasSE2)->E2_TIPO)),"E2_PARCISS",{ || .T. }},;
			{PadR(SuperGetMv('MV_UNIAO'),Len((cAliasSE2)->E2_FORNECE)),PadR(IIf(SubStr(SuperGetMv('MV_UNIAO'),Len((cAliasSE2)->E2_FORNECE)+1)<>"",SubStr(SuperGetMv('MV_UNIAO'),Len((cAliasSE2)->E2_FORNECE)+1),"00"),Len((cAliasSE2)->E2_LOJA)),PadR('TX',Len((cAliasSE2)->E2_TIPO)),"E2_PARCCSS",{|| AllTrim((cAliasSE2)->E2_NATUREZ) == AllTrim(SuperGetMv("MV_CSS"))}}}

			aadd(aFornece,{PadR(SuperGetMv('MV_UNIAO'),Len((cAliasSE2)->E2_FORNECE)),PadR(IIf(SubStr(SuperGetMv('MV_UNIAO'),Len((cAliasSE2)->E2_FORNECE)+1)<>"",SubStr(SuperGetMv('MV_UNIAO'),Len((cAliasSE2)->E2_FORNECE)+1),"00"),Len((cAliasSE2)->E2_LOJA)),PadR('TX',Len((cAliasSE2)->E2_TIPO)),"E2_PARCPIS",{ || .T. }})
			aadd(aFornece,{PadR(SuperGetMv('MV_UNIAO'),Len((cAliasSE2)->E2_FORNECE)),PadR(IIf(SubStr(SuperGetMv('MV_UNIAO'),Len((cAliasSE2)->E2_FORNECE)+1)<>"",SubStr(SuperGetMv('MV_UNIAO'),Len((cAliasSE2)->E2_FORNECE)+1),"00"),Len((cAliasSE2)->E2_LOJA)),PadR('TX',Len((cAliasSE2)->E2_TIPO)),"E2_PARCCOF",{ || .T. }})
			aadd(aFornece,{PadR(SuperGetMv('MV_UNIAO'),Len((cAliasSE2)->E2_FORNECE)),PadR(IIf(SubStr(SuperGetMv('MV_UNIAO'),Len((cAliasSE2)->E2_FORNECE)+1)<>"",SubStr(SuperGetMv('MV_UNIAO'),Len((cAliasSE2)->E2_FORNECE)+1),"00"),Len((cAliasSE2)->E2_LOJA)),PadR('TX',Len((cAliasSE2)->E2_TIPO)),"E2_PARCSLL",{ || .T. }})


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Titulos vinculados ao titulo principal                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nY := 1 To Len(aFornece)
				aadd(aParcela,(cAliasSE2)->(FieldGet(ColumnPos(aFornece[nY,4]))))
			Next nY
			For nY := 1 To Len(aFornece)
				dbSelectArea("SE2")
				dbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
				If MsSeek(cFilSE2+(cAliasSE2)->E2_PREFIXO+(cAliasSE2)->E2_NUM+aParcela[nY]+aFornece[nY,3]+aFornece[nY,1]+aFornece[nY,2])
					If Eval(aFornece[nY,5])
						nValAux := SaldoTit(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_NATUREZ,"P",SE2->E2_FORNECE,nMoeda,dDataBase,dDataBase,SE2->E2_LOJA,,,1) // 1 = DT BAIXA    3 = DT DIGIT
						nValAux := nValAux * (SD1->D1_TOTAL/SF1->F1_VALMERC)*nCoef
						aRet[2] += nValAux
						aRet[3] += PmsBaixas(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,nMoeda,"P",SE2->E2_FORNECE,SE2->E2_LOJA,dDataRef,.F.)*(SD1->D1_TOTAL/SF1->F1_VALMERC)*nCoef

						If lFluxo
							aFluxo[3] += PmsBaixas(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,nMoeda,"P",SE2->E2_FORNECE,SE2->E2_LOJA,dDataRef,.T.)*(SD1->D1_TOTAL/SF1->F1_VALMERC)*nCoef
							nPosDt := aScan(aFluxo[2],{|x| x[1]==SE2->E2_VENCREA})
							If nPosDt > 0
								aFluxo[2,nPosDt,2] += nValAux
							Else
								aAdd(aFluxo[2],{SE2->E2_VENCREA,nValAux,0})
							EndIf
							//adiciona no array analitico o Documento de Entrada
							Aadd(aAnaArrayTrb,{cTarefa,(cAliasSE2)->E2_VENCREA,"DOCUMENTO ENTRADA",SD1->D1_FILIAL,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_ITEM,SD1->D1_COD,SD1->D1_FORNECE,SD1->D1_LOJA,nValAux})
						EndIf

					EndIf
				EndIf
			Next nY
			RestArea(aTmpArea)
		EndIf
		dbSelectArea(cAliasSE2)
		dbSkip()
	EndDo
	If lQuery
		dbSelectArea(cAliasSE2)
		dbCloseArea()
		oQrySE2:Destroy()
		oQrySE2 := Nil 
		dbSelectArea("SE2")
	EndIf
EndIf

RestArea(aAreaSF4)
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsRetEDT³ Autor ³ Edson Maricate              ³ Data ³ 21-05-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que retorna os valores financeiros atuais da EDT            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsRetEDT(cProjeto,cRevisa,cEDT,nMoeda,dDataRef)
Local aRet
Local aArrayTrb
DEFAULT dDataRef := PMS_MAX_DATE

aArrayTrb := PmsIniFin(cProjeto,cRevisa,cEDT,,nMoeda,dDataRef)

aRet := PmsRetFinVal(aArrayTrb,2,cEDT)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PmsPrjCopy
Funcao que perimite a copia de uma estrutura de um projeto para outro. Ou uma estrutura de orçamento para um projeto.
possibilitando trazer estruturas de projetos ou orçamentos que se encontram em outras filiais.
Sendo chamado exclusivamente pela funcao PMS200Import.

@param cAlias, caracter, Alias da tabela que irá receber a copia
@param nRecno, numerico, numero do registro da tabela que ira receber a copia
@param cAliasCpy, caracter, Alias da tabela a ser copiada
@param nRecCpy, numerico, numero do registro da tabela a ser copiada
@param nOrcPrj, numerico, 1 - tabelas de orcamento / 2 - tabelas de projeto
@param aMarkPrj, array, contem os alias e numero de registros que devem ser copiados
							[n]
							[n,1] - alias da tabela
							[n,2] - recno da tabela
@param cFilCopy, caracter, Se preenchido deve conter a Filial referente das tabelas a serem copiadas.

@return Logico,

@author Edson Maricate
@since 29-05-2002
@version 1.0
/*/
//-------------------------------------------------------------------
Function PmsPrjCopy(cAlias,nRecno,cAliasCpy,nRecCpy,nOrcPrj,aMarkPrj, cFilCopy)
Local nPosTsk
Local nPosPrd
Local nRecOrig
Local cItem     := ""
Local cEDT      := ""
Local cTarefa   := ""
Local cUltTrf   := ""
Local cCODMEM   := ""
Local cOldCode  := ""
Local cPrjCode  := ""
Local cRevCode  := ""
Local cCalendFil:= ""
Local nX        := 0
Local nC        := 0
Local nI        := 0
Local nZ        := 0
Local aRecalc   := {}
Local aStack    := {}
Local aConfig   := {}
Local aRecCpy   := {}
Local aRelac    := {}
Local aLinks    := {}
Local aLinksAJ4 := {}
Local aCposAFD  := {}
Local aCposAJ4  := {}
Local aRecAF9   := {}
Local aParam    := {}
Local bCampo    := {|n| FieldName(n) }
Local aImport   := {cAliasCpy,nRecCpy}
Local aCpyFrmFil:= {{.T.,Nil},{.F.,Nil}}
Local aRetCopy  := {}
Local aDestCpy  := {"","",""}
Local lRet      := .F.
Local lHrExec   := .T.
Local lCalc 	:= .T. // recalcula as tarefas e edts que foram copiadas
Local lNewRec	:= .T.
Local lUsaAJT	:= AF8ComAJT( AF8->AF8_PROJET )
Local aArea     := GetArea()
Local lExist_HESF := .F.
Local bOk 		:= {||MSGYESNO(STR0227,STR0120)} // "Deseja confirmar a importação dos dados para este projeto?" // "Atenção"
Local nTamCpy	:= 0

Local cFilAFC 		:= xFilial("AFC")
Local cFilAF9 		:= xFilial("AF9")
Local cFilAFA 		:= xFilial("AFA")
Local cFilAFD 		:= xFilial("AFD")

Local nAFC_Nivel 	:= TamSX3("AFC_NIVEL")[1]
Local nAF9_Nivel 	:= TamSX3("AF9_NIVEL")[1]
Local nAFC_OBS 		:= TamSX3("AFC_OBS")[1]
Local nAF9_OBS 		:= TamSX3("AF9_OBS")[1]
Local nAFA_PRODUT	:= TamSX3("AFA_PRODUT")[1]

Local c_PMSTCOD 	:= IIF((GetMV("MV_PMSTCOD") $ "1|2|3"),GetMV("MV_PMSTCOD"),"1") //Define se a geração de numero de edt será automatica ou manual
Local lPMAPCPY 		:= ExistBlock("PMAPCPY")
Local lPMSCPAF9 	:= ExistBlock("PMSCPAF9")
Local lPMSCPAFC 	:= ExistBlock("PMSCPAFC")
Local lPMACPYCAL 	:= ExistBlock("PMACPYCAL")
Local lPMSINCAFP 	:= ExistBlock("PMSINCAFP")
Local lPM200CpPr 	:= ExistBlock("PM200CpPr")
Local lPMB2PCPY 	:= ExistBlock("PMB2PCPY")

Private Inclui := .T.

// Valida se existe os campos AF9_HESF e AFC_HESF
lExist_HESF := .T.

If cFilCopy <> Nil
	If !Empty(xFilial('SB1'))
		aCpyFrmFil[1] := {.F.,"{||.F.}"}
	Endif
	If !Empty(xFilial('AE8'))
		aCpyFrmFil[2] := {.F.,"{||.F.}"}
	Endif
Endif
If ExistBlock("PMCPYFIL")
	aCpyFrmFil :=	ExecBlock("PMCPYFIL",.F.,.F.,{aCpyFrmFil})
Endif

// incluir parametros nesta ordem
Aadd(aParam, {4,STR0062,aCpyFrmFil[1,1],STR0063,60,,.F. , aCpyFrmFil[1,2]})  	//"Copiar :"###"Produtos previstos"
Aadd(aParam, {4,"",.T.,STR0064,60,,.F.})  				   						//"Despesas previstas"
Aadd(aParam, {4,"",aCpyFrmFil[2,1],STR0065,60,,.F. , aCpyFrmFil[2,2]})  		//"Recursos alocados"
Aadd(aParam, {4,"",.T.,STR0066,60,,.F.})  				   						//"Relacionamentos"
Aadd(aParam, {4,"", (nOrcPrj == 2), STR0206,120,,.F., If(nOrcPrj == 2, "{||.T.}", "{||.F.}") })  //"Eventos"
Aadd(aParam, {4,"", (nOrcPrj == 2),STR0068,40,,.F., If(nOrcPrj == 2, "{||.T.}", "{||.F.}") })  //"Documentos"

If SuperGetMV("MV_PMSCPSL",,"2") == "1"
	Aadd(aParam, {4,"",.F.,STR0073,50,,.T.})  //"EDT Selecionada"
Else
	Aadd(aParam, {4,"",.T.,STR0073,50,,.F.})  //"EDT Selecionada"
EndIf

Aadd(aParam, {4,"", (nOrcPrj == 2),STR0096,50,,.F., If(nOrcPrj == 2, "{||.T.}", "{||.F.}")})  // Copiar Usuarios
Aadd(aParam, {3,STR0069,0,{STR0070,STR0071},50,,.T.})//"Copiar duracao"###"Prevista"###"Real"
Aadd(aParam, {1,STR0097,1, "@E 999" ,"mv_par10 > 0","","", 55 ,.T.}) //"Num.Copias"
Aadd(aParam, {7,STR0182,"AF9",""}) //"Filtro Tarefas"
Aadd(aParam, {7,STR0183,"AFC",""}) //"Filtro EDT"

If c_PMSTCOD == "1" //codificação manual
	Aadd(aParam, {3, STR0209, 2, {STR0184, STR0205}, 90, , .T. }) //"Codificação"###"Renumerar automaticamente?"###"Copiar código de origem"
Else
	Aadd(aParam, {3, STR0209, 1, {STR0184, STR0205}, 90, , .T. }) //"Codificação"###"Renumerar automaticamente?"###"Copiar código de origem"
EndIf

Aadd(aParam, {4,"", (nOrcPrj == 2),STR0230,90,,.F., If(nOrcPrj == 2, "{||.T.}", "{||.F.}") })  //"Copiar Checklist" @@// Projeto TDI - Chamado original TEHNAO

If ParamBox(aParam,STR0072,aConfig,bOk,,.F.,90,15) //"Copiar EDT/Tarefa - Opcoes"

	For nc := 1 to aConfig[10]
		nPosTsk	:= 0
		nPosPrd	:= 0
		aStack	:= {}
		aRelac	:= {}
		aLinks	:= {}
		aRecCpy	:= {}
		cItem	:= ""

		If nOrcPrj == 2

			//
			// Projeto -> Projeto
			//
			If Len(aMarkPrj) > 0

				For nX := 1 To Len(aMarkPrj)
					dbSelectArea("AFC")
					MsGoto(nRecno)
					aAdd(aStack,{AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT,AFC->AFC_NIVEL})

					If aMarkPrj[nX,1] == "AFC"
						dbSelectArea("AFC")
						dbGoto(aMarkPrj[nX,2])

						aAdd(aRecCpy, {"AFC", AFC->(RecNo()), AFC->AFC_NIVEL})
					Else
						dbSelectArea("AF9")
						dbGoto(aMarkPrj[nX,2])

						aAdd(aRecCpy, {"AF9", AF9->(RecNo()), AF9->AF9_NIVEL})
					EndIf
				Next
			Else
				dbSelectArea("AFC")
				MsGoto(nRecno)
				aAdd(aStack,{AFC->AFC_PROJET,cRevisa,AFC->AFC_EDT,AFC->AFC_NIVEL})

				If cAliasCpy="AFC"
					dbSelectArea("AFC")
					dbGoto(nRecCpy)
					AuxCpyAFC(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,@aRecCpy,aConfig[7],NIL,,cFilCopy) //,, aMarkPrj)
					cCalendFil	:= AFC->AFC_CALEND
				Else
					AF9->(dbGoto(nRecCpy))
					aAdd(aRecCpy,{"AF9",AF9->(RecNo()),AF9->AF9_NIVEL})
					cCalendFil	:= AF9->AF9_CALEND
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³No caso de copia entre filiais          ³
				//³Compatibiliza o calendario a ser copiado³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cFilCopy <> cFilAnt
					PmsxVerCal(	cCalendFil , cFilCopy , cFilAnt)
				EndIf
			EndIf
			nTamCpy := Len(aRecCpy)
			ProcRegua(nTamCpy)
			SetMaxCodes(nTamCpy)  // Define a quantidade de códigos reservados 
			For nx := 1 to nTamCpy
				IncProc(STR0198+Str(nc,2,0)+STR0199)		//"Copiando estruturas [" ## "].Aguarde..."
				If aRecCpy[nx,1]=="AFC"
					dbSelectArea("AFC")
					dbGoto(aRecCpy[nx,2])
					If !Empty(aConfig[12]) .And. !&(aConfig[12])
						Loop
					EndIf
					aImport:={"AFC",AFC->(Recno())}

					Inclui := .T.
					cEDT   := ""

					If lPMSCPAFC // ExistBlock("PMSCPAFC")
						lOk := .T.
						While lOK
							cEDT := ExecBlock("PMSCPAFC",.F.,.F.,{ cEDT ,"AFC" ,AFC->(Recno()) })
							If !Empty(cEDT)
								If !ExistChav("AFC",aStack[Len(aStack),1] + aStack[Len(aStack),2] + cEDT ) .OR.!FreeForUse("AFC",aStack[Len(aStack),1] + aStack[Len(aStack),2] + cEDT)
									If (Aviso(STR0085+cEDT ,STR0197 + CRLF + STR0194, {STR0195,STR0196})==1)
										cEDT := ""
										lOk := .F.
									Else
										lOk := .T.
									EndIf
								Else
									lOk := .F.
								EndIf
								FreeUsedCode(.T.)

							Endif
						End
					EndIf

					While Empty(cEDT)
						cEDT := AFC->AFC_EDT

						Do Case
							Case (c_PMSTCOD $ "1|3") .And. aConfig[13] == 1
								// codificação manual //Renumerar automaticamente
								cEDT := PmsNumAFC(aStack[Len(aStack),1],aStack[Len(aStack),2],aStack[Len(aStack),4],aStack[Len(aStack),3])

							Case (c_PMSTCOD $ "1|3") .And. aConfig[13] == 2
								// codificação manual //Copiar código de origem
								If ExistPrjEDT( aStack[Len(aStack),1] , aStack[Len(aStack),2] , cEDT, .F.)
									cEDT := PMSWindowPrompt( 2, "EDT", {aStack[Len(aStack),1],AFC->AFC_EDT,cEDT,aStack[Len(aStack),2]})
								EndIf

							Case c_PMSTCOD == "1"
								// codificação manual
								cEDT := PMSWindowPrompt( 2, "EDT", {aStack[Len(aStack),1],AFC->AFC_EDT,cEDT,aStack[Len(aStack),2]})

							Case c_PMSTCOD == "2"
								// codificação automática
								cEDT := PmsNumAFC(aStack[Len(aStack),1],aStack[Len(aStack),2],aStack[Len(aStack),4],aStack[Len(aStack),3])

						EndCase
					EndDo

					RegToMemory("AFC",.F.,.F.)
					PmsNewRec("AFC")
					For nz := 1 TO FCount()
						FieldPut(nz,M->&(EVAL(bCampo,nz)))
					Next nz
					cOldCode := AFC->AFC_EDT
					cPrjCode := AFC->AFC_PROJET
					cRevCode := AFC->AFC_REVISA
					AFC->AFC_FILIAL := cFilAFC
					AFC->AFC_PROJET := aStack[Len(aStack),1]
					AFC->AFC_REVISA := aStack[Len(aStack),2]
					AFC->AFC_EDTPAI := aStack[Len(aStack),3]
					AFC->AFC_EDT    := cEDT
					AFC->AFC_NIVEL  := StrZero(Val(aStack[Len(aStack),4]) + 1, nAFC_Nivel)
					AFC->AFC_DTATUI := PMS_EMPTY_DATE
					AFC->AFC_DTATUF := PMS_EMPTY_DATE
					AFC->AFC_START  := PMS_EMPTY_DATE
					AFC->AFC_FINISH := PMS_EMPTY_DATE
					AFC->AFC_HORAI  := ""
					AFC->AFC_HORAF  := ""
					AFC->AFC_HDURAC := 0
					AFC->AFC_HUTEIS := 0
					AFC->AFC_CUSTO  := 0
					AFC->AFC_CUSTO2 := 0
					AFC->AFC_CUSTO3 := 0
					AFC->AFC_CUSTO4 := 0
					AFC->AFC_CUSTO5 := 0

					M->AFC_OBS := MSMM(AFC->AFC_CODMEM,nAFC_OBS,,,3,,,"AFC", "AFC_CODMEM")

					If ! Empty(M->AFC_OBS)
						AFC->AFC_CODMEM := ""
						M->AFC_CODMEM := ""
						cCODMEM := CriaVar("AFC_CODMEM")
						MSMM(cCodMem,nAFC_OBS,,M->AFC_OBS,1,,,"AFC","AFC_CODMEM")
					Endif

					MsUnlock()

					If lPMAPCPY //ExistBlock("PMAPCPY")
						ExecBlock("PMAPCPY", .F., .F., {"E", AFC->AFC_PROJET, AFC->AFC_REVISA, AFC->AFC_EDT, cPrjCode, cRevCode, cOldCode})
					EndIf

					If aConfig[6]
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Pesquisa todos os documentos da tarefa.     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("AC9")
						dbSetOrder(2)
						cFilSeek	:=	xFilial("AC9")
						If cFilCopy	<> Nil .And. !Empty(cFilSeek)
							cFilSeek	:=	cFilCopy
						Endif
						MsSeek(cFilSeek + "AFC" + M->AFC_FILIAL + M->AFC_PROJET + M->AFC_EDT)
						While !Eof() .And. AllTrim(cFilSeek + "AFC" + M->AFC_FILIAL + M->AFC_PROJET + M->AFC_EDT)==;
							Alltrim(AC9->AC9_FILIAL + AC9->AC9_ENTIDA + AC9->AC9_FILENT + AC9->AC9_CODENT)
							aAuxArea := GetArea()
							RegToMemory("AC9",.F.,.F.)
							PmsNewRec("AC9")
							For nz := 1 TO FCount()
								FieldPut(nz,M->&(EVAL(bCampo,nz)))
							Next nz
							AC9->AC9_FILIAL := xFilial("AC9")
							AC9->AC9_ENTIDA := "AFC"
							AC9->AC9_FILENT := AFC->AFC_FILIAL
							AC9->AC9_CODENT := AFC->AFC_PROJET + AFC->AFC_EDT
							MsUnlock()
							RestArea(aAuxArea)
							dbSKip()
						EndDo
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Copia os usuarios da EDT                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If aConfig[8]
						dbSelectArea("AFX")
						dbSetOrder(1)
						cFilSeek	:=	xFilial("AFX")
						If cFilCopy	<> Nil .And. !Empty(cFilSeek)
							cFilSeek	:=	cFilCopy
						Endif
						MsSeek(cFilSeek+M->AFC_PROJET+Space(Len(AFX->AFX_REVISA))+M->AFC_EDT)

						While !AFX->(Eof()) .And. cFilSeek+M->AFC_PROJET+Space(Len(AFX->AFX_REVISA))+M->AFC_EDT==;
							AFX->AFX_FILIAL + AFX->AFX_PROJET + Space(Len(AFX->AFX_REVISA)) + AFX->AFX_EDT
							aAuxArea := GetArea()

							RegToMemory("AFX",.F.,.F.)
							PmsNewRec("AFX")

							For nz := 1 TO FCount()
								FieldPut(nz,M->&(EVAL(bCampo,nz)))
							Next nz

							AFX->AFX_FILIAL := xFilial("AFX")
							AFX->AFX_PROJET := aStack[Len(aStack),1]
							AFX->AFX_REVISA := Space(Len(AFX->AFX_REVISA))
							AFX->AFX_EDT    := cEdt

							MsUnlock()
							RestArea(aAuxArea)
							dbSkip()
						EndDo
					EndIf

					If aConfig[5]
						dbSelectArea("AFP")
						dbSetOrder(2)
						cFilSeek	:=	xFilial("AFP")
						If cFilCopy	<> Nil .And. !Empty(cFilSeek)
							cFilSeek	:=	cFilCopy
						Endif
						MsSeek(cFilSeek + M->AFC_PROJET + M->AFC_REVISA+M->AFC_EDT)
						While !Eof() .And. cFilSeek + M->AFC_PROJET + M->AFC_REVISA + M->AFC_EDT==;
							AFP->AFP_FILIAL + AFP->AFP_PROJET + AFP->AFP_REVISA + AFP->AFP_EDT
							aAuxArea := GetArea()
							RegToMemory("AFP",.F.,.F.)
							PmsNewRec("AFP")
							For nz := 1 TO FCount()
								FieldPut(nz,M->&(EVAL(bCampo,nz)))
							Next nz
							AFP->AFP_FILIAL := xFilial("AFP")
							AFP->AFP_PROJET := AFC->AFC_PROJET
							AFP->AFP_REVISA := AFC->AFC_REVISA
							AFP->AFP_EDT    := AFC->AFC_EDT
							AFP->AFP_NUM    := SPACE(Len(AFP->AFP_NUM))
							AFP->AFP_PREFIX := SPACE(Len(AFP->AFP_PREFIX))
							AFP->AFP_DTATU  := PMS_EMPTY_DATE
							MsUnlock()
							RestArea(aAuxArea)
							dbSkip()
						EndDo
					EndIf

					If nx < Len(aRecCpy)
						If Val(aRecCpy[nx,3]) < Val(aRecCpy[nx+1,3])
							aAdd(aStack,{AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT,AFC->AFC_NIVEL})
						Else
							If Val(aRecCpy[nx,3]) > Val(aRecCpy[nx+1,3])
								For ni := 1 To Val(aRecCpy[nx,3]) - Val(aRecCpy[nx+1,3])
									aSize(aStack, Len(aStack) - 1)
								Next ni
							EndIf
						EndIf
					EndIf
				Else
					dbSelectArea("AF9")
					dbGoto(aRecCpy[nx,2])

					aAuxArea := AFC->(GetArea())
					dbSelectArea("AFC")
					dbSetOrder(1)
					cFilSeek	:=	xFilial("AFC")
					If cFilCopy	<> Nil .And. !Empty(cFilSeek)
						cFilSeek	:=	cFilCopy
					Endif
					MsSeek(cFilSeek + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_EDTPAI)
					If !Empty(aConfig[12]) .And. !&(aConfig[12])
						RestArea(aAuxArea)
						Loop
					Else
						RestArea(aAuxArea)
					EndIf
					dbSelectArea("AF9")
					If !Empty(aConfig[11]) .And. !&(aConfig[11])
						If nx < Len(aRecCpy)
							If Val(aRecCpy[nx,3]) < Val(aRecCpy[nx+1,3])
								aAdd(aStack,{AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT,AFC->AFC_NIVEL})
							Else
								If Val(aRecCpy[nx,3]) > Val(aRecCpy[nx+1,3])
									For ni := 1 To Val(aRecCpy[nx,3]) - Val(aRecCpy[nx+1,3])
										aSize(aStack, Len(aStack) - 1)
									Next ni
								EndIf
							EndIf
						EndIf
						Loop
					EndIf

					aImport := {"AF9",AF9->(Recno())}

					dbSelectArea("AFC")
					dbGoto(aRecCpy[nx,2])
					If !Empty(aConfig[12]) .And. !&(aConfig[12])
						Loop
					EndIf
					aImport:={"AFC",AFC->(Recno())}

					Inclui  := .T.
					cTarefa := ""
					If lPMSCPAF9 // ExistBlock("PMSCPAF9")
						lOk := .T.
						While lOK
							cTarefa := ExecBlock("PMSCPAF9",.F.,.F.,{ cTarefa ,"AF9" ,AF9->(Recno()) })
							If !Empty(cTarefa)
								If !ExistChav("AF9",aStack[Len(aStack),1] + aStack[Len(aStack),2] + cTarefa ) .OR.!FreeForUse("AF9",aStack[Len(aStack),1] + aStack[Len(aStack),2] + cTarefa)
									If (Aviso(STR0084+cTarefa ,STR0193 + CRLF + STR0194, {STR0195,STR0196})==1)
										cTarefa	:=	""
										lOk := .F.
									Else
										lOk := .T.
									EndIf

								Else
									lOk := .F.
								EndIf
								FreeUsedCode(.T.)
							Endif
						End
					EndIf


					While Empty(cTarefa)
						cTarefa := AF9->AF9_TAREFA
						lLiberaCod := .F.

						Do Case

							Case (c_PMSTCOD $ "1|3") .And. aConfig[13] == 1
								// codificação manual //Renumerar automaticamente
								cTarefa := PmsNumAF9(aStack[Len(aStack),1],aStack[Len(aStack),2],aStack[Len(aStack),4],aStack[Len(aStack),3])

							Case (c_PMSTCOD $ "1|3") .And. aConfig[13] == 2
								// codificação manual //Copiar código de origem
								If ExistPrjTrf( aStack[Len(aStack),1] , aStack[Len(aStack),2] , cTarefa , .F., @lLiberaCod)
									cTarefa := PMSWindowPrompt( 2, "TAREFA", {aStack[Len(aStack),1],AF9->AF9_TAREFA,cTarefa,aStack[Len(aStack),2]})
								EndIf

							Case c_PMSTCOD == "1"
								// codificação manual
								cTarefa := PMSWindowPrompt( 2, "TAREFA", {aStack[Len(aStack),1],AF9->AF9_TAREFA,cTarefa,aStack[Len(aStack),2]})

							Case c_PMSTCOD == "2"
								// codificação automática
								cTarefa := PmsNumAF9(aStack[Len(aStack),1],aStack[Len(aStack),2],aStack[Len(aStack),4],aStack[Len(aStack),3])

						EndCase
					EndDo


					RegToMemory("AF9",.F.,.F.)
					PmsNewRec("AF9")
					For nz := 1 TO FCount()
						FieldPut(nz,M->&(EVAL(bCampo,nz)))
					Next nz
					cOldCode := AF9->AF9_TAREFA
					cPrjCode := AF9->AF9_PROJET
					cRevCode := AF9->AF9_REVISA
					AF9->AF9_FILIAL := cFilAF9
					AF9->AF9_PROJET := aStack[Len(aStack),1]
					AF9->AF9_EDTPAI := aStack[Len(aStack),3]
					AF9->AF9_TAREFA := cTarefa
					AF9->AF9_REVISA := aStack[Len(aStack),2]
					AF9->AF9_NIVEL  := StrZero(Val(aStack[Len(aStack),4]) + 1, nAF9_Nivel)
					AF9->AF9_DTATUI := PMS_EMPTY_DATE
					AF9->AF9_DTATUF := PMS_EMPTY_DATE

					M->AF9_OBS := MSMM(AF9->AF9_CODMEM,nAF9_OBS,,,3,,,"AF9", "AF9_CODMEM")

					If ! Empty(M->AF9_OBS)
						AF9->AF9_CODMEM := ""
						M->AF9_CODMEM := ""
						cCODMEM := CriaVar("AF9_CODMEM")
						MSMM(cCodMem,nAF9_OBS,,M->AF9_OBS,1,,,"AF9","AF9_CODMEM")
					Endif

					lHrExec := .F.
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Copia as horas executadas                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If aConfig[9]==2
						If !Empty(M->AF9_DTATUI) .And. !Empty(M->AF9_DTATUF)
							AF9->AF9_HDURAC:= PmsHrsItvl(M->AF9_DTATUI,"00:00",M->AF9_DTATUF,"24:00",AF9->AF9_CALEND,AF9->AF9_PROJET)
							AF9->AF9_HUTEIS:= AF9->AF9_HDURAC
							aAuxRet := PMSDTaskF(M->AF9_DTATUI,"00:00",AF9->AF9_CALEND,AF9->AF9_HDURAC,AF9->AF9_PROJET,Nil)
							AF9->AF9_START	:= aAuxRet[1]
							AF9->AF9_HORAI	:= aAuxRet[2]
							AF9->AF9_FINISH	:= aAuxRet[3]
							AF9->AF9_HORAF	:= aAuxRet[4]
							lHrExec := .T.
						EndIf
					EndIf

					//
					// Se Tipo de medicao for cronograma por periodo
					// E copia de outro projeto ou copia de horas executadas
					// assume Tipo de medicao = proporcional ao tempo
					If  AF9->AF9_TPMEDI == "6" .AND. !( M->AF9_PROJET == AF9->AF9_PROJET .AND. !lHrExec)
						AF9->AF9_TPMEDI := "4"
					EndIf

					If !aConfig[3] .and. lExist_HESF  //se nao copia os recursos nao deve gravar hrs esforco - Chamado TGFLY3
						AF9->AF9_HESF := 0
					EndIf

					MsUnlock()

					If aConfig[14] // @@ Projeto TDI - Chamado Original TEHNAO
						SIMFCHKCAL( 1 , aRecCpy[nX,2], .F., " ["+STR0170+" "+ALLTRIM(AF9->AF9_PROJET)+" "+STR0171+" "+ALLTRIM(AF9->AF9_TAREFA)+"] "+ALLTRIM(AF9->AF9_DESCRI), AF9->( Recno()) ) //"Projeto:"##"Tarefa:"
					Endif

					If lLiberaCod
						FreeUsedCode(.T.)
					Endif

					If lPMAPCPY // ExistBlock("PMAPCPY")
						ExecBlock("PMAPCPY", .F., .F., {"T", AF9->AF9_PROJET, AF9->AF9_REVISA, AF9->AF9_TAREFA, cPrjCode, cRevCode, cOldCode})
					EndIf

					aAdd(aRecAF9,AF9->(RecNo()))

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Copia o cronograma por periodo da tarefa    ³
					//³somente se ambas pertencem ao projeto e não ³
					//³for por horas executadas.                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If M->AF9_PROJET == AF9->AF9_PROJET .AND. !lHrExec
						dbSelectArea("AFZ")
						dbSetOrder(1)
						cFilSeek	:=	xFilial("AFZ")
						If cFilCopy	<> Nil .And. !Empty(cFilSeek)
							cFilSeek	:=	cFilCopy
						Endif
						MsSeek(cFilSeek+M->AF9_PROJET+M->AF9_REVISA+M->AF9_TAREFA)
						While !Eof() .And. cFilSeek+M->AF9_PROJET+M->AF9_REVISA+M->AF9_TAREFA==;
							AFZ->AFZ_FILIAL+AFZ->AFZ_PROJET+AFZ->AFZ_REVISA+AFZ->AFZ_TAREFA
							aAuxArea := GetArea()

							RegToMemory("AFZ",.F.,.F.)
							PmsNewRec("AFZ")

							For nz := 1 TO FCount()
								FieldPut(nz,M->&(EVAL(bCampo,nz)))
							Next nz

							AFZ->AFZ_FILIAL := xFilial("AFZ")
							AFZ->AFZ_PROJET := AF9->AF9_PROJET
							AFZ->AFZ_REVISA := AF9->AF9_REVISA
							AFZ->AFZ_TAREFA := AF9->AF9_TAREFA

							MsUnlock()
							RestArea(aAuxArea)
							dbSkip()
						EndDo
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Copia os usuarios da tarefa                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If aConfig[8]
						dbSelectArea("AFV")
						dbSetOrder(1)
						cFilSeek	:=	xFilial("AFV")
						If cFilCopy	<> Nil .And. !Empty(cFilSeek)
							cFilSeek	:=	cFilCopy
						Endif
						MsSeek(cFilSeek + M->AF9_PROJET + Space(Len(AFV->AFV_REVISA)) + M->AF9_TAREFA)

						While !AFV->(Eof()) .And. cFilSeek + M->AF9_PROJET + Space(Len(AFV->AFV_REVISA)) + M->AF9_TAREFA==;
							AFV->AFV_FILIAL + AFV->AFV_PROJET + Space(Len(AFV->AFV_REVISA)) + AFV->AFV_TAREFA
							aAuxArea := GetArea()

							RegToMemory("AFV",.F.,.F.)
							PmsNewRec("AFV")

							For nz := 1 TO FCount()
								FieldPut(nz,M->&(EVAL(bCampo,nz)))
							Next nz

							AFV->AFV_FILIAL := xFilial("AFV")
							AFV->AFV_PROJET := aStack[Len(aStack),1]
							AFV->AFV_REVISA := Space(Len(AFV->AFV_REVISA))
							AFV->AFV_TAREFA := cTarefa

							MsUnlock()
							RestArea(aAuxArea)
							dbSkip()
						End
					EndIf

					aAdd(aRelac,{M->AF9_TAREFA,AF9->AF9_TAREFA,AF9->AF9_PROJET,AF9->AF9_REVISA,M->AF9_EDTPAI,AF9->AF9_EDTPAI})
					If aScan(aRecalc,{|x| x[3]==AF9->AF9_EDTPAI})==0
						aAdd(aRecalc,{AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_EDTPAI})
					EndIf
					If aConfig[1] .Or. aConfig[3]
						If lUsaAJT // utiliza template de construcao civil e composicao unica
							DbSelectArea( "AEL" )
							AEL->( DbSetOrder( 1 ) )
							cFilSeek :=	xFilial("AEL")
							If cFilCopy	<> Nil .And. !Empty(cFilSeek)
								cFilSeek	:=	cFilCopy
							Endif
							AEL->( DbSeek( cFilSeek + M->( AF9_PROJET + AF9_REVISA + AF9_TAREFA ) ) )
							While AEL->( !Eof() ) .AND. cFilSeek + M->( AF9_PROJET + AF9_REVISA + AF9_TAREFA ) == AEL->( AEL_FILIAL + AEL_PROJET + AEL_REVISA + AEL_TAREFA )
								aAuxArea := AEL->( GetArea() )
								RegToMemory( "AEL", .F., .F. )

								DbSelectArea( "AJY" )
								AJY->( DbSetOrder( 1 ) )
								AJY->( DbSeek( xFilial( "AJY" ) + AEL->( AEL_FILIAL + AEL_PROJET + AEL_REVISA + AEL_INSUMO ) ) )

								If  ( aConfig[1] .And. Empty( AJY->AJY_RECURS ) ) .Or.;
									( aConfig[3] .And. !Empty( AJY->AJY_RECURS ) )

									If AEL->( DbSeek( cFilSeek + AF9->( AF9_PROJET + AF9_REVISA + AF9_TAREFA ) + M->AEL_ITEM ) )
										PmsAvalAEL(,,M->AEL_INSUMO,2)
										RecLock("AEL",.F.)
									Else
										RecLock("AEL",.T.)
									EndIf

									For nz := 1 TO AEL->( FCount() )
										FieldPut( nz, M->&( Eval( bCampo, nz ) ) )
									Next nz

									AEL->AEL_FILIAL := xFilial( "AEL" )
									AEL->AEL_PROJET := AF9->AF9_PROJET
									AEL->AEL_REVISA := AF9->AF9_REVISA
									AEL->AEL_TAREFA := AF9->AF9_TAREFA
									AEL->AEL_PLANEJ	:= ""

									MsUnlock()
									//PmsAvalAEL(,,AEL->AEL_INSUMO, 1)
									PMSAJYCopy(AEL->AEL_INSUMO, M->AF9_PROJET, M->AF9_REVISA, AF9->AF9_PROJET, AF9->AF9_REVISA)
								EndIf

								// Copia a estrutuda da composicao aux do projeto
								PMSCpyCU(	M->AF9_PROJET,;		// 01- Projeto origem no qual sera copiado
											M->AF9_REVISA,;		// 02- Revisao
											AF9->AF9_PROJET,;	// 03- Projeto destino no qual recebera a copia
											AF9->AF9_REVISA,;	// 04- Revisao
											M->AF9_COMPUN )		// 05- Composicao Aux a ser copiada

								AEL->( RestArea( aAuxArea ) )

								AEL->( DbSkip() )
							End

							DbSelectArea( "AEN" )
							AEN->( DbSetOrder( 1 ) )
							cFilSeek :=	xFilial("AEN")
							If cFilCopy	<> Nil .And. !Empty(cFilSeek)
								cFilSeek	:=	cFilCopy
							Endif
							AEN->( DbSeek( cFilSeek + M->( AF9_PROJET + AF9_REVISA + AF9_TAREFA ) ) )
							While AEN->( !Eof() ) .AND. cFilSeek + M->( AF9_PROJET + AF9_REVISA + AF9_TAREFA ) == AEN->( AEN_FILIAL + AEN_PROJET + AEN_REVISA + AEN_TAREFA )
								aAuxArea := AEN->( GetArea() )
								RegToMemory( "AEN", .F., .F. )

								If AEN->( DbSeek( cFilSeek + AF9->( AF9_PROJET + AF9_REVISA + AF9_TAREFA ) + M->AEN_ITEM ) )
									PmsAvalAEN(M->AEN_SUBCOM, 2)
									RecLock("AEN",.F.)
								Else
									RecLock("AEN",.T.)
								EndIf

								For nz := 1 TO AEN->( FCount() )
									FieldPut( nz, M->&( Eval( bCampo, nz ) ) )
								Next nz

								AEN->AEN_FILIAL := xFilial( "AEN" )
								AEN->AEN_PROJET := AF9->AF9_PROJET
								AEN->AEN_REVISA := AF9->AF9_REVISA
								AEN->AEN_TAREFA := AF9->AF9_TAREFA

								MsUnlock()
								PMSAJTCopy(AEN->AEN_SUBCOM, M->AF9_PROJET, M->AF9_REVISA, AF9->AF9_PROJET, AF9->AF9_REVISA)

								AEN->( RestArea( aAuxArea ) )

								AEN->( DbSkip() )
							End

						Else
							dbSelectArea("AFA")
							dbSetOrder(1)
							cFilSeek	:=	xFilial("AFA")
							If cFilCopy	<> Nil .And. !Empty(cFilSeek)
								cFilSeek	:=	cFilCopy
							Endif
							MsSeek( cFilSeek + M->AF9_PROJET + M->AF9_REVISA + M->AF9_TAREFA)
							While !Eof() .And. cFilSeek + M->AF9_PROJET+M->AF9_REVISA+M->AF9_TAREFA==;
								AFA->AFA_FILIAL+AFA->AFA_PROJET+AFA->AFA_REVISA+AFA->AFA_TAREFA
								If  (aConfig[1] .And. Empty(AFA->AFA_RECURS)) .Or.;
									(aConfig[3] .And. !Empty(AFA->AFA_RECURS))
									aAuxArea := GetArea()
									RegToMemory("AFA",.F.,.F.)
									PmsNewRec("AFA")
									For nz := 1 TO FCount()
										FieldPut(nz,M->&(EVAL(bCampo,nz)))
									Next nz
									AFA->AFA_FILIAL := cFilAFA
									AFA->AFA_PROJET := AF9->AF9_PROJET
									AFA->AFA_REVISA := AF9->AF9_REVISA
									AFA->AFA_TAREFA := AF9->AF9_TAREFA
									AFA->AFA_PLANEJ	:= ""
									MsUnlock()
									RestArea(aAuxArea)

									//Copia o cronograma de consumo somente se ambas pertencem ao mesmo projeto e nao
									//for por horas executadas.
									If M->AF9_PROJET == AF9->AF9_PROJET .And. !lHrExec
										cFilAEF := xFilial("AEF")
										DbSelectArea("AEF")
										DbSetOrder(1) //AEF_FILIAL+AEF_PROJET+AEF_REVISA+AEF_TAREFA+AEF_ITEM+AEF_PRODUT+AEF_RECURS+DTOS(AEF_DATREF)
										If Empty(AFA->AFA_RECURS)
											cAux := AFA->AFA_PRODUT
										Else
											cAux := Space(nAFA_PRODUT)
										EndIf
										AEF->(DbSeek(cFilAEF+AFA->AFA_PROJET+AFA->AFA_REVISA+AFA->AFA_TAREFA+AFA->AFA_ITEM+cAux+AFA->AFA_RECURS) )
										While AEF->(AEF_FILIAL+AEF_PROJET+AEF_REVISA+AEF_TAREFA+AEF_ITEM+AEF_PRODUT+AEF_RECURS) ==;
											cFilAEF+AFA->AFA_PROJET+AFA->AFA_REVISA+AFA->AFA_TAREFA+AFA->AFA_ITEM+cAux+AFA->AFA_RECURS
											aAuxArea := GetArea()
											RegToMemory("AEF",.F.,.F.)
											PmsNewRec("AEF")
											For nz := 1 TO FCount()
												FieldPut(nz,M->&(EVAL(bCampo,nz)))
											Next nz
											AEF->AEF_FILIAL := xFilial("AEF")
											AEF->AEF_PROJET := AF9->AF9_PROJET
											AEF->AEF_REVISA := AF9->AF9_REVISA
											AEF->AEF_TAREFA := AF9->AF9_TAREFA
											MsUnlock()
											RestArea(aAuxArea)
											AEF->(DbSkip())
										EndDo
										DbSelectArea("AFA")
									EndIf

								EndIf
								dbSkip()
							End
						EndIf
					EndIf
					If aConfig[2]
						dbSelectArea("AFB")
						dbSetOrder(1)
						cFilSeek	:=	xFilial("AFB")
						If cFilCopy	<> Nil .And. !Empty(cFilSeek)
							cFilSeek	:=	cFilCopy
						Endif
						MsSeek(cFilSeek + M->AF9_PROJET+M->AF9_REVISA+M->AF9_TAREFA)
						While !Eof() .And. cFilSeek + M->AF9_PROJET+M->AF9_REVISA+M->AF9_TAREFA==;
							AFB->AFB_FILIAL+AFB->AFB_PROJET+AFB->AFB_REVISA+AFB->AFB_TAREFA
							aAuxArea := GetArea()
							RegToMemory("AFB",.F.,.F.)
							PmsNewRec("AFB")
							For nz := 1 TO FCount()
								FieldPut(nz,M->&(EVAL(bCampo,nz)))
							Next nz
							AFB->AFB_FILIAL := xFilial("AFB")
							AFB->AFB_PROJET := AF9->AF9_PROJET
							AFB->AFB_REVISA := AF9->AF9_REVISA
							AFB->AFB_TAREFA := AF9->AF9_TAREFA
							MsUnlock()

							RestArea(aAuxArea)
							dbSkip()
						End

						If lUsaAJT
							DbSelectArea( "AJV" )
							AJV->( DbSetOrder( 2 ) )

							cFilSeek	:=	xFilial("AJV")
							If cFilCopy	<> Nil .And. !Empty(cFilSeek)
								cFilSeek	:=	cFilCopy
							Endif

							AJV->( DbSeek( cFilSeek + M->( AF9_PROJET + AF9_REVISA + AF9_COMPUN ) ) )
							While AJV->( !Eof() ) .AND. cFilSeek + M->( AF9_PROJET + AF9_REVISA + AF9_COMPUN ) == AJV->( AJV_FILIAL + AJV_PROJET + AJV_REVISA + AJV_COMPUN )
								aAuxArea := GetArea()

								RegToMemory( "AJV", .F., .F. )

								lNewRec := AJV->( !DbSeek( cFilSeek + AF9->( AF9_PROJET + AF9_REVISA + AF9_COMPUN ) ) )
								If lNewRec
									RecLock( "AJV", lNewRec )
									For nz := 1 TO FCount()
										FieldPut( nz, M->&( EVAL( bCampo, nz ) ) )
									Next nz

									AJV->AJV_FILIAL := xFilial( "AJV" )
									AJV->AJV_PROJET := AF9->AF9_PROJET
									AJV->AJV_REVISA := AF9->AF9_REVISA
									AJV->AJV_COMPUN := AF9->AF9_COMPUN
									MsUnlock()
								EndIf

								RestArea(aAuxArea)

								AJV->( DbSkip() )
							End
						EndIf
					EndIf
					If aConfig[6]
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Pesquisa todos os documentos da tarefa.     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("AC9")
						dbSetOrder(2)
						cFilSeek	:=	xFilial("AC9")
						If cFilCopy	<> Nil .And. !Empty(cFilSeek)
							cFilSeek	:=	cFilCopy
						Endif
						MsSeek(cFilSeek + "AF9" + M->AF9_FILIAL + M->AF9_PROJET + M->AF9_TAREFA)
						While !Eof() .And. AllTrim(cFilSeek + "AF9" + M->AF9_FILIAL + M->AF9_PROJET + M->AF9_TAREFA)==;
							Alltrim(AC9->AC9_FILIAL + AC9->AC9_ENTIDA + AC9->AC9_FILENT + AC9->AC9_CODENT)
							aAuxArea := GetArea()
							If !MsSeek(xFilial("AC9")+"AF9"+AF9->AF9_FILIAL+PADR(AF9->AF9_PROJET+AF9->AF9_TAREFA,TamSX3("AC9_CODENT")[1])+AC9->AC9_CODOBJ)
								RestArea(aAuxArea)
								RegToMemory("AC9",.F.,.F.)
								PmsNewRec("AC9")
								For nz := 1 TO FCount()
									FieldPut(nz,M->&(EVAL(bCampo,nz)))
								Next nz
								AC9->AC9_FILIAL := xFilial("AC9")
								AC9->AC9_ENTIDA := "AF9"
								AC9->AC9_FILENT := AF9->AF9_FILIAL
								AC9->AC9_CODENT := AF9->AF9_PROJET + AF9->AF9_TAREFA
								MsUnlock()
							EndIf
							RestArea(aAuxArea)
							dbSKip()
						End
					EndIf
					If aConfig[5]
						dbSelectArea("AFP")
						dbSetOrder(1)
						cFilSeek	:=	xFilial("AFP")
						If cFilCopy	<> Nil .And. !Empty(cFilSeek)
							cFilSeek	:=	cFilCopy
						Endif

						MsSeek(cFilSeek + M->AF9_PROJET+M->AF9_REVISA+M->AF9_TAREFA)
						While !Eof() .And. cFilSeek + M->AF9_PROJET+M->AF9_REVISA+M->AF9_TAREFA==;
							AFP->AFP_FILIAL+AFP->AFP_PROJET+AFP->AFP_REVISA+AFP->AFP_TAREFA

							nRecOrig := AFP->(Recno())
							aAuxArea := GetArea()
							RegToMemory("AFP",.F.,.F.)
							PmsNewRec("AFP")
							For nz := 1 TO FCount()
								If EVAL(bCampo,nz) == "AFP_DTCALC"
									AFP_DTCALC := CTOD("  /  /  ")
								ELSEIF EVAL(bCampo,nz) == "AFP_GERPRV"
									AFP_GERPRV := "3"
								Else
									FieldPut(nz,M->&(EVAL(bCampo,nz)))
								EndIf
							Next nz
							AFP->AFP_FILIAL := xFilial("AFP")
							AFP->AFP_PROJET := AF9->AF9_PROJET
							AFP->AFP_REVISA := AF9->AF9_REVISA
							AFP->AFP_TAREFA := AF9->AF9_TAREFA
							AFP->AFP_NUM    := SPACE(Len(AFP->AFP_NUM))
							AFP->AFP_PREFIX := SPACE(Len(AFP->AFP_PREFIX))
							AFP->AFP_DTATU  := PMS_EMPTY_DATE

							MsUnlock()
							//Ponto de entrada para manipular campos de Evento da tarefa copiada
							//Criada para o cliente poder gerar titulos no financeiro quando a tarefa
							//for copiada e tiver eventos cadastrados.
							If lPMSINCAFP // ExistBlock("PMSINCAFP")
								Execblock("PMSINCAFP",.F.,.F.,{nRecOrig})
								lCopy := .F.
							EndIf

							RestArea(aAuxArea)
							dbSkip()
						End
					EndIf
					dbSelectArea("AFD")
					dbSetOrder(1)
					cFilSeek	:=	xFilial("AFD")
					If cFilCopy	<> Nil .And. !Empty(cFilSeek)
						cFilSeek	:=	cFilCopy
					Endif
					MsSeek(cFilSeek +M->AF9_PROJET+M->AF9_REVISA+M->AF9_TAREFA)
					While !Eof() .And. cFilSeek +M->AF9_PROJET+M->AF9_REVISA+M->AF9_TAREFA==;
						AFD->AFD_FILIAL+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_TAREFA
						aAdd(aCposAFD,{})
						RegToMemory("AFD",.F.,.F.)
						For nz := 1 TO FCount()
							aAdd(aCposAFD[Len(aCposAFD)],{nz,M->&(EVAL(bCampo,nz))})
						Next nz
						aAdd(aLinks,{AFD->AFD_TAREFA,AFD->AFD_PREDEC,AFD->AFD_TIPO,AFD->AFD_HRETAR, AFD->AFD_ITEM})
						dbSkip()
					End

					dbSelectArea("AJ4")
					dbSetOrder(1)
					cFilSeek	:=	xFilial("AJ4")
					If cFilCopy	<> Nil .And. !Empty(cFilSeek)
						cFilSeek	:=	cFilCopy
					Endif
					dbSeek(cFilSeek + M->(AF9_PROJET + AF9_REVISA+AF9_TAREFA))
					While !AJ4->(Eof()) .And. AJ4->(xFilial("AJ4")+M->(AF9_PROJET+AF9_REVISA+AF9_TAREFA))==AJ4->(AJ4_FILIAL+AJ4_PROJET+AJ4_REVISA+AJ4_TAREFA)
						aAdd(aCposAJ4,{})
						RegToMemory("AJ4",.F.,.F.)
						For nz := 1 to AJ4->(FCount())
							aAdd(aCposAJ4[Len(aCposAJ4)],{nz,M->&(EVAL(bCampo,nz))})
						Next nz
						aAdd(aLinksAJ4,{AJ4->AJ4_TAREFA,AJ4->AJ4_PREDEC,AJ4->AJ4_TIPO,AJ4->AJ4_HRETAR, AJ4->AJ4_ITEM})
						dbSkip()
					End

					If nx < Len(aRecCpy)
						If Val(aRecCpy[nx,3]) < Val(aRecCpy[nx+1,3])
							aAdd(aStack,{AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT,AFC->AFC_NIVEL})
						Else
							If Val(aRecCpy[nx,3]) > Val(aRecCpy[nx+1,3])
								For ni := 1 To Val(aRecCpy[nx,3]) - Val(aRecCpy[nx+1,3])
									aSize(aStack, Len(aStack) - 1)
								Next ni
							EndIf
						EndIf
					EndIf
				EndIf

				If lPM200CpPr // ExistBlock("PM200CpPr")
					aRetCopy:=PmsRetCopy(aImport)
					If aImport[1]=="AFC"
						aDestCpy[1]:=AFC->AFC_PROJET
						aDestCpy[2]:=AFC->AFC_REVISA
						aDestCpy[3]:=AFC->AFC_EDT
					Else
						aDestCpy[1]:=AF9->AF9_PROJET
						aDestCpy[2]:=AF9->AF9_REVISA
						aDestCpy[3]:=AF9->AF9_TAREFA
					EndIf
					ExecBlock("PM200CpPr", .F., .F., {aDestCpy[1], aDestCpy[2], aDestCpy[3], aRetCopy[1], aRetCopy[2], aRetCopy[3]})
				EndIf
			Next nx

			If aConfig[4]
				cItem   := "00"
				cUltTrf := ""
				For nx := 1 to Len(aLinks)
					nPosTsk :=aScan(aRelac,{|x| x[1]==aLinks[nx,1]})
					nPosPrd :=aScan(aRelac,{|x| x[1]==aLinks[nx,2]})
					If nPosTsk > 0 .And. nPosPrd > 0
						If AllTrim(cUltTrf) != AllTrim(aRelac[nPosTsk,1])
							cItem := "00"
							cUltTrf := aRelac[nPosTsk,1]
						EndIf
						cItem := Soma1(cItem)

						PmsNewRec("AFD")
						For nz := 1 TO FCount()
							FieldPut(aCposAFD[nx,nz,1],aCposAFD[nx,nz,2])
						Next nz
						AFD->AFD_FILIAL := cFilAFD
						AFD->AFD_ITEM   := cItem
						AFD->AFD_PROJET := aRelac[nPosTsk,3]
						AFD->AFD_REVISA := aRelac[nPosTsk,4]
						AFD->AFD_TAREFA := aRelac[nPosTsk,2]
						AFD->AFD_PREDEC := aRelac[nPosPrd,2]
						AFD->AFD_TIPO   := aLinks[nx,3]
						AFD->AFD_HRETAR := aLinks[nx,4]
						MsUnlock()
					EndIf
				Next nx

				cItem   := "00"
				cUltTrf := ""
				For nx := 1 to Len(aLinksAJ4)
					nPosTsk := aScan(aRelac,{|x| x[1]==aLinksAJ4[nx,1]})
					nPosPrd := aScan(aRelac,{|x| x[5]==aLinksAJ4[nx,2]})
					If nPosTsk > 0 .And. nPosPrd > 0
						If AllTrim(cUltTrf) != AllTrim(aRelac[nPosTsk,1])
							cItem := "00"
							cUltTrf := aRelac[nPosTsk,1]
						EndIf
						cItem := Soma1(cItem)

						PmsNewRec("AJ4")
						For nz := 1 to FCount()
							FieldPut(aCposAJ4[nx,nz,1],aCposAJ4[nx,nz,2])
						Next nz
						AJ4->AJ4_FILIAL := xFilial("AJ4")
						AJ4->AJ4_ITEM   := cItem
						AJ4->AJ4_PROJET := aRelac[nPosTsk,3]
						AJ4->AJ4_REVISA := aRelac[nPosTsk,4]
						AJ4->AJ4_TAREFA := aRelac[nPosTsk,2]
						AJ4->AJ4_PREDEC := aRelac[nPosPrd,6]
						AJ4->AJ4_TIPO   := aLinksAJ4[nx,3]
						AJ4->AJ4_HRETAR := aLinksAJ4[nx,4]
						MsUnlock()
					EndIf
				Next nx
			EndIf

		Else
			//
			// Orçamento -> Projeto
			//
			If Len(aMarkPrj) > 0

				For nX := 1 To Len(aMarkPrj)

					dbSelectArea("AFC")
					MsGoto(nRecno)
					aAdd(aStack, {AFC->AFC_PROJET, AFC->AFC_REVISA , AFC->AFC_EDT, AFC->AFC_NIVEL, AFC->AFC_CALEND})

					If aMarkPrj[nX,1] == "AF5"

						dbSelectArea("AF5")
						dbGoto(aMarkPrj[nX,2])

						aAdd(aRecCpy, {"AF5", AF5->(RecNo()), AF5->AF5_NIVEL})
					Else
						dbSelectArea("AF2")
						dbGoto(aMarkPrj[nX,2])

						aAdd(aRecCpy, {"AF2", AF2->(RecNo()), AF2->AF2_NIVEL})
					EndIf
				Next
			Else
				dbSelectArea("AFC")
				MsGoto(nRecno)
				aAdd(aStack, {AFC->AFC_PROJET, cRevisa, AFC->AFC_EDT, AFC->AFC_NIVEL, AFC->AFC_CALEND})

				If cAliasCpy = "AF5"
					dbSelectArea("AF5")
					dbGoto(nRecCpy)
					AuxCpyAF5(AF5->AF5_ORCAME + AF5->AF5_EDT, @aRecCpy, aConfig[7], )
				Else
					AF2->(dbGoto(nRecCpy))
					aAdd(aRecCpy, {"AF2", AF2->(RecNo()), AF2->AF2_NIVEL})
				EndIf
				ProcRegua(Len(aRecCpy))
			EndIf

			For nx := 1 to Len(aRecCpy)
				IncProc(STR0198 + Str(nc,2,0) + STR0199) //"Copiando estruturas [" ## "].Aguarde..."
				If aRecCpy[nx,1] == "AF5"
					AF5->(dbGoto(aRecCpy[nx,2]))
					Inclui := .T.
					cEDT   := ""

					While Empty(cEDT)
						cEDT := AF5->AF5_EDT

						Do Case
							Case (c_PMSTCOD $ "1|3") .And. aConfig[13] == 1
								// codificação manual //Renumerar automaticamente
								cEDT := PmsNumAFC(aStack[Len(aStack),1], ;
													aStack[Len(aStack),2], ;
													aStack[Len(aStack),4], ;
													aStack[Len(aStack),3], , .F.)

							Case (c_PMSTCOD $ "1|3") .And. aConfig[13] == 1
								// codificação manual //Copiar código de origem
								If ExistPrjEDT( aStack[Len(aStack),1] , aStack[Len(aStack),2] , cEDT, .F.)
									cEDT := PMSWindowPrompt( 2, "EDT", {aStack[Len(aStack),1],AF5->AF5_EDT,cEDT,aStack[Len(aStack),2]})
								EndIf

							Case c_PMSTCOD == "1"
								// codificação manual
								cEDT := PMSWindowPrompt( 2, "EDT", {aStack[Len(aStack),1],AF5->AF5_EDT,cEDT,aStack[Len(aStack),2]})

							Case c_PMSTCOD == "2"
								// codificação automática
								cEDT := PmsNumAFC(aStack[Len(aStack),1], ;
													aStack[Len(aStack),2], ;
													aStack[Len(aStack),4], ;
													aStack[Len(aStack),3], , .F.)

						EndCase
					EndDo

					RegToMemory("AFC",.T.,.F.)
					PmsNewRec("AFC")

					For nz := 1 TO FCount()
						cCampoAF5 := "AF5_" + Substr(EVAL(bCampo,nz),5,6)
						If AF5->(ColumnPos(cCampoAF5) > 0)
							&("M->"+EVAL(bCampo,nz)) := &("AF5->"+cCampoAF5)
						EndIf
						FieldPut(nz,M->&(EVAL(bCampo,nz)))
					Next nz

					AFC->AFC_FILIAL  := cFilAFC
					AFC->AFC_NIVEL   := StrZero(Val(aStack[Len(aStack),4]) + 1, nAFC_Nivel)
					AFC->AFC_EDT     := cEDT
					AFC->AFC_PROJETO := aStack[Len(aStack),1]
					AFC->AFC_REVISA  := aStack[Len(aStack),2]
					AFC->AFC_EDTPAI  := aStack[Len(aStack),3]
					AFC->AFC_CUSTO   := 0
					AFC->AFC_CUSTO2  := 0
					AFC->AFC_CUSTO3  := 0
					AFC->AFC_CUSTO4  := 0
					AFC->AFC_CUSTO5  := 0
					AFC->AFC_CALEND  := aStack[Len(aStack),5]
					MsUnlock()

					If lPMB2PCPY // ExistBlock("PMB2PCPY")
						ExecBlock("PMB2PCPY", .F., .F., {"E", AFC->AFC_PROJET, AFC->AFC_REVISA, ;
						AFC->AFC_EDT, AF5->AF5_ORCAME, AF5->AF5_EDT})
					EndIf

					//
					// Documentos
					//
					If nx < Len(aRecCpy)
						If Val(aRecCpy[nx,3]) < Val(aRecCpy[nx+1,3])
							aAdd(aStack,{AFC->AFC_PROJET, AFC->AFC_REVISA, AFC->AFC_EDT,AFC->AFC_NIVEL, AFC->AFC_CALEND})
						Else
							If Val(aRecCpy[nx,3]) > Val(aRecCpy[nx+1,3])
								For ni := 1 To Val(aRecCpy[nx,3]) - Val(aRecCpy[nx+1,3])
									aSize(aStack, Len(aStack) - 1)
								Next ni
							EndIf
						EndIf
					EndIf
				Else
					AF2->(dbGoto(aRecCpy[nx,2]))

					Inclui  := .T.
					cTarefa := ""

					While Empty(cTarefa)
						cTarefa := AF2->AF2_TAREFA
						lLiberaCod := .F.
						Do Case
							Case (c_PMSTCOD $ "1|3") .And. aConfig[13] == 1
								// codificação manual //Renumerar automaticamente
								cTarefa := PmsNumAF9(aStack[Len(aStack),1], ;
								aStack[Len(aStack),2], ;
								aStack[Len(aStack),4], ;
								aStack[Len(aStack),3],,.T.)

							Case (c_PMSTCOD $ "1|3") .And. aConfig[13] == 2
								// codificação manual //Copiar código de origem
								If ExistPrjTrf(aStack[Len(aStack),1],aStack[Len(aStack),2],cTarefa,.F., @lLiberaCod)
									cTarefa := PMSWindowPrompt( 2, "TAREFA", {aStack[Len(aStack),1],AF2->AF2_TAREFA,cTarefa,aStack[Len(aStack),2]})
								EndIf

							Case c_PMSTCOD == "1"
								// codificação manual
								cTarefa := PMSWindowPrompt( 2, "TAREFA", {aStack[Len(aStack),1],AF2->AF2_TAREFA,cTarefa,aStack[Len(aStack),2]})

							Case c_PMSTCOD == "2"
								// codificação automática
								cTarefa := PmsNumAF9(aStack[Len(aStack),1], ;
								aStack[Len(aStack),2], ;
								aStack[Len(aStack),4], ;
								aStack[Len(aStack),3],,.T.)

						EndCase
					EndDo


					RegToMemory("AF9",.T.,.F.)
					PmsNewRec("AF9")
					For nz := 1 TO FCount()
						cCampoAF2 := "AF2_" + Substr(EVAL(bCampo,nz),5,6)
						If AF2->(ColumnPos(cCampoAF2) > 0)
							&("M->"+EVAL(bCampo,nz)) := &("AF2->"+cCampoAF2)
						EndIf
						FieldPut(nz,M->&(EVAL(bCampo,nz)))
					Next nz
					AF9->AF9_FILIAL := cFilAF9
					AF9->AF9_NIVEL  := StrZero(Val(aStack[Len(aStack),4]) + 1, nAF9_Nivel)
					AF9->AF9_TAREFA := cTarefa
					AF9->AF9_EDTPAI := aStack[Len(aStack),3]
					AF9->AF9_PROJET := aStack[Len(aStack),1]
					AF9->AF9_REVISA := aStack[Len(aStack),2]
					AF9->AF9_CALEND := aStack[Len(aStack),5]

					aAuxRet := PMSDTaskF(dDatabase, "00:00", AF9->AF9_CALEND, AF9->AF9_HDURAC, AF9->AF9_PROJET, Nil)

					AF9->AF9_START  := aAuxRet[1]
					AF9->AF9_HORAI  := aAuxRet[2]
					AF9->AF9_FINISH := aAuxRet[3]
					AF9->AF9_HORAF  := aAuxRet[4]
					AF9->AF9_ORDEM  := ""
					MsUnlock()

					If lLiberaCod
						FreeUsedCode(.T.)
					Endif

					If lPMB2PCPY // ExistBlock("PMB2PCPY")
						ExecBlock("PMB2PCPY", .F., .F., {"T", AFC->AFC_PROJET, AFC->AFC_REVISA, AFC->AFC_EDT, ;
						AF2->AF2_ORCAME, AF2->AF2_TAREFA})
					EndIf

					aAdd(aRelac,{AF9->AF9_TAREFA,AF2->AF2_TAREFA,AF9->AF9_PROJET, AF9->AF9_REVISA /* REVISA */})
					aAdd(aRecAF9,AF9->(RecNo()))

					//
					// Produtos
					//
					If aConfig[1]
						dbSelectArea("AF3")
						dbSetOrder(1)
						MsSeek(xFilial("AF3")+AF2->AF2_ORCAME+AF2->AF2_TAREFA)
						While !Eof() .And. xFilial("AF3")+AF2->AF2_ORCAME+AF2->AF2_TAREFA==;
							AF3->AF3_FILIAL+AF3->AF3_ORCAME+AF3->AF3_TAREFA
							aAuxArea := GetArea()
							If Empty(AF3->AF3_RECURS)
								RegToMemory("AFA",.T.,.F.)
								PmsNewRec("AFA")
								For nz := 1 TO FCount()
									cCampoAF3 := "AF3_" + Substr(EVAL(bCampo,nz),5,6)
									If AF3->(ColumnPos(cCampoAF3) > 0)
										&("M->"+EVAL(bCampo,nz)) := &("AF3->"+cCampoAF3)
									EndIf
									FieldPut(nz,M->&(EVAL(bCampo,nz)))
								Next nz
								AFA->AFA_FILIAL := cFilAFA
								AFA->AFA_PROJET := AF9->AF9_PROJET
								AFA->AFA_REVISA := AF9->AF9_REVISA
								AFA->AFA_TAREFA := AF9->AF9_TAREFA
								AFA->AFA_DATPRF := dDataBase
								AFA->AFA_PLANEJ	:= ""
								MsUnlock()
							EndIf
							RestArea(aAuxArea)
							dbSkip()
						End
					EndIf

					//
					// Recursos
					//
					If aConfig[3]
						dbSelectArea("AF3")
						dbSetOrder(1)
						MsSeek(xFilial("AF3")+AF2->AF2_ORCAME+AF2->AF2_TAREFA)
						While !Eof() .And. xFilial("AF3")+AF2->AF2_ORCAME+AF2->AF2_TAREFA==;
							AF3->AF3_FILIAL+AF3->AF3_ORCAME+AF3->AF3_TAREFA
							aAuxArea := GetArea()
							If !Empty(AF3->AF3_RECURS)
								RegToMemory("AFA",.T.,.F.)
								PmsNewRec("AFA")
								For nz := 1 TO FCount()
									cCampoAF3 := "AF3_" + Substr(EVAL(bCampo,nz),5,6)
									If AF3->(ColumnPos(cCampoAF3) > 0)
										&("M->"+EVAL(bCampo,nz)) := &("AF3->"+cCampoAF3)
									EndIf
									FieldPut(nz,M->&(EVAL(bCampo,nz)))
								Next nz
								AFA->AFA_FILIAL := cFilAFA
								AFA->AFA_PROJET := AF9->AF9_PROJET
								AFA->AFA_REVISA := AF9->AF9_REVISA
								AFA->AFA_TAREFA := AF9->AF9_TAREFA
								AFA->AFA_PLANEJ	:= ""
								AFA->AFA_FIX    := "2"
								MsUnlock()
							EndIf
							RestArea(aAuxArea)
							dbSkip()
						End
					EndIf

					//
					// Despesas
					//
					If aConfig[2]
						dbSelectArea("AF4")
						dbSetOrder(1)
						MsSeek(xFilial("AF4")+AF2->AF2_ORCAME+AF2->AF2_TAREFA)
						While !Eof() .And. xFilial("AF4")+AF2->AF2_ORCAME+AF2->AF2_TAREFA==;
							AF4->AF4_FILIAL+AF4->AF4_ORCAME+AF4->AF4_TAREFA
							aAuxArea := GetArea()
							RegToMemory("AFB",.T.,.F.)
							PmsNewRec("AFB")
							For nz := 1 TO FCount()
								cCampoAF4 := "AF4_" + Substr(EVAL(bCampo,nz),5,6)
								If AF4->(ColumnPos(cCampoAF4) > 0)
									&("M->"+EVAL(bCampo,nz)) := &("AF4->"+cCampoAF4)
								EndIf
								FieldPut(nz,M->&(EVAL(bCampo,nz)))
							Next nz
							AFB->AFB_FILIAL := xFilial("AFB")
							AFB->AFB_PROJET := AF9->AF9_PROJET
							AFB->AFB_REVISA := AF9->AF9_REVISA /* REVISA */
							AFB->AFB_TAREFA := AF9->AF9_TAREFA
							MsUnlock()
							RestArea(aAuxArea)
							dbSkip()
						End
					EndIf


					//
					// Eventos
					//
					dbSelectArea("AF7")
					dbSetOrder(1)
					MsSeek(xFilial("AF7")+AF2->AF2_ORCAME+AF2->AF2_TAREFA)
					While !Eof() .And. xFilial("AF7")+AF2->AF2_ORCAME+AF2->AF2_TAREFA==;
						AF7->AF7_FILIAL+AF7->AF7_ORCAME+AF7->AF7_TAREFA
						aAdd(aLinks,{AF7->AF7_TAREFA,AF7->AF7_PREDEC,AF7->AF7_TIPO,AF7->AF7_HRETAR})
						dbSkip()
					End
					If nx < Len(aRecCpy)
						For ni := 1 to Val(aRecCpy[nx,3])-Val(aRecCpy[nx+1,3])
							aDel(aStack,Len(aStack))
							aSize(aStack,Len(aStack)-1)
						Next ni
					EndIf
				EndIf
			Next nx
			If aConfig[3]
				cItem   := "00"
				cUltTrf := ""
				For nx := 1 to Len(aLinks)
					nPosTsk :=aScan(aRelac,{|x| x[2]==aLinks[nx,1]})
					nPosPrd :=aScan(aRelac,{|x| x[2]==aLinks[nx,2]})
					If nPosTsk > 0 .And. nPosPrd > 0
						If AllTrim(cUltTrf) != AllTrim(aRelac[nPosTsk,1])
							cItem := "00"
							cUltTrf := aRelac[nPosTsk,1]
						EndIf
						cItem := Soma1(cItem)

						PmsNewRec("AFD")
						AFD->AFD_FILIAL := xFilial("AFD")
						AFD->AFD_ITEM	:= cItem
						AFD->AFD_PROJET := aRelac[nPosTsk,3]
						AFD->AFD_REVISA := aRelac[nPosTsk,4]  /* REVISA */
						AFD->AFD_TAREFA := aRelac[nPosTsk,1]
						AFD->AFD_PREDEC := aRelac[nPosPrd,1]
						AFD->AFD_TIPO	:= aLinks[nx,3]
						AFD->AFD_HRETAR	:= aLinks[nx,4]
						MsUnlock()
					EndIf
				Next nx
			EndIf
		EndIf
	Next nc

	If lPMACPYCAL // ExistBlock("PMACPYCAL")
		lCalc := ExecBlock("PMACPYCAL", .F., .F.)
	EndIf

	If lCalc
		ProcRegua(Len(aRecalc)+Len(aRecAF9))
		For nc := 1 to len(aRecAF9)
			IncProc(STR0192)//"Atualizando EDT. Aguarde..."
			AF9->(dbGoto(aRecAF9[nc]))
			PmsAvalTrf("AF9",1,,,,.T.)
		Next nc
		For nx := 1 to Len(aRecalc)
			IncProc(STR0192)//"Atualizando EDT. Aguarde..."
			PmsEdtPrv( aRecalc[nx,1],aRecalc[nx,2],aRecalc[nx,3],{}) // atualiza as datas e custos previstos das edts
			PMSEdtReal( aRecalc[nx,1],aRecalc[nx,2],aRecalc[nx,3],{}) // atualiza as datas e custos realizados das edts
		Next
	EndIf
	lRet	:= .T.
EndIf

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AuxCpyAFC³ Autor ³ Edson Maricate         ³ Data ³ 29-05-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao auxiliar que retorna o array com a estrutura a ser im- ³±±
±±³          ³portada no projeto.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AuxCpyAFC(cChave,aRecCpy,lCopySel,nNivel ,aMarkPrj, cFilCP)
Local aArea    := GetArea()
Local aAreaAFC := AFC->(GetArea())
Local aAreaAF9 := AF9->(GetArea())
Local aNodes   := {}  // array utilizado na ordenacao de tarefas e EDTs
Local nNode    := 0   // contador utilizado para iteracao com aNodes
Local cFilSeek :=	If (!Empty(xFilial('AFC')) .And. cFilCp <> Nil,cFilCp,xFilial('AFC'))

DEFAULT nNivel := 1

If lCopySel
	dbSelectArea("AFC")
	dbSetOrder(1)
	MsSeek( cFilSeek + cChave )
	aAdd(aRecCpy,{"AFC",AFC->(RecNo()),StrZero(nNivel,3)})
EndIf

dbSelectArea("AF9")
dbSetOrder(2)
MsSeek(cFilSeek + cChave)
While !Eof() .And. cFilSeek + AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT==;
	AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_EDTPAI

	aAdd(aNodes, {PMS_TASK,;
	AF9->(Recno()),;
	IIf(Empty(AF9->AF9_ORDEM), "000", AF9->AF9_ORDEM),;
	AF9->AF9_TAREFA})
	dbSkip()
End

dbSelectArea("AFC")
dbSetOrder(2)
MsSeek(cFilSeek + cChave)
While !Eof() .And. cFilSeek + cChave==;
	AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDTPAI

	aAdd(aNodes, {PMS_WBS,;
	AFC->(Recno()),;
	IIf(Empty(AFC->AFC_ORDEM), "000", AFC->AFC_ORDEM),;
	AFC->AFC_EDT})
	dbSkip()
End

// ordenacao conjunta de tarefa/EDTs
aSort(aNodes, , , {|x, y| x[3]+x[4] < y[3]+y[4] })

For nNode := 1 To Len(aNodes)
	If aNodes[nNode,1] == PMS_TASK  // tarefa
		aAdd(aRecCpy, {"AF9", aNodes[nNode,2], StrZero(nNivel+1,3)})
	Else
		AFC->(dbGoto(aNodes[nNode,2]))
		AuxCpyAFC(AFC->AFC_PROJET + AFC->AFC_REVISA + AFC->AFC_EDT, @aRecCpy, .T., nNivel + 1, ,cFilCP)
	EndIf
Next

RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsNewRec³ Autor ³ Edson Maricate         ³ Data ³ 29-05-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que cria um novo registro no arquivo e faz a gravacao  ³±±
±±³          ³dos campos com inicializador padrao .                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PmsNewRec(cAlias)
Local nj
Local bCampo 	:= {|n| FieldName(n) }

dbSelectArea(cAlias)
RegToMemory(cAlias,.T.)
RecLock(cAlias,.T.)
For nj := 1 TO FCount()
	FieldPut(nj,M->&(EVAL(bCampo,nj)))
Next nj

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PmsOrcCopy ³ Autor ³Cristiano G. da Cunha³ Data ³ 06-06-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de importacao de estruturas.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOrcPrj - 1:copia do orcamento                               ³±±
±±³          ³           2:copia do projeto                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsOrcCopy(cAlias,nRecno,cAliasCpy,nRecCpy,nOrcPrj,aMarkPrj)
Local nPosTsk
Local nPosPrd
Local aStack   := {}
Local aConfig  := {}
Local aRecCpy  := {}
Local aRelac   := {}
Local aRecAF2  := {}
Local aLinks   := {}
Local aArea    := GetArea()
Local bCampo   := {|n| FieldName(n) }
Local lRet     := .F.
Local cItem    := ""
Local cEDT     := ""
Local cTarefa  := ""
Local cUltTrf  := ""
Local nC       := 0
Local nX       := 0
Local nI       := 0
Local nZ       := 0
Local cOldCode := ""
Local cOrcCode := ""
Local cCodMem  := ""
Local aParam   := {}
Local i   	   := 0
Local cVersao  := ""

Private Inclui := .T.

Aadd(aParam, {4,STR0062,.T.,STR0074,60,,.F.}) //"Copiar :"###"Produtos"
Aadd(aParam, {4,"",.T.,STR0075,60,,.F.})      //"Despesas"
Aadd(aParam, {4,"",.T.,STR0066,60,,.F.})      //"Relacionamentos"
Aadd(aParam, {4,"",.T.,STR0068,40,,.F.})      //"Documentos"

If SuperGetMV("MV_PMSCPSL",,"2") == "1"
	Aadd(aParam, {4,"",.F.,STR0073,50,,.T.})      //"EDT Selecionada"
Else
	Aadd(aParam, {4,"",.T.,STR0073,50,,.F.})      //"EDT Selecionada"
EndIf

Aadd(aParam, {4,"",.F.,STR0065,60,,.F.})      //"Recursos alocados"
Aadd(aParam, {1,STR0097,1, "@E 999" ,"mv_par07 > 1","","", 55 ,.T.}) //"Num.Copias"

If GetMV("MV_PMSTCOD") == "1" // codificação manual
	Aadd(aParam, {3, STR0209, 2, {STR0184, STR0205}, 90, , .T. }) //"Codificação"###"Renumerar automaticamente?"###"Copiar código de origem"
Else
	Aadd(aParam, {3, STR0209, 1, {STR0184, STR0205}, 90, , .T. }) //"Codificação"###"Renumerar automaticamente?"###"Copiar código de origem"
EndIf


If ParamBox(aParam, STR0072, aConfig,,, .F., 90, 15) //"Copiar EDT/Tarefa - Opcoes"

	PmsNewProc()

	For nc := 1 to aConfig[7]
		PmsIncProc(.T.)
		nPosTsk	:= 0
		nPosPrd	:= 0
		aStack	:= {}
		aRelac	:= {}
		aLinks	:= {}
		aRecCpy	:= {}
		cItem	:= ""

		// orçamento
		If nOrcPrj == 1

			//
			// Orçamento -> Orçamento
			//
			If Len(aMarkPrj) > 0

				For i := 1 To Len(aMarkPrj)
					dbSelectArea("AF5")
					MsGoto(nRecno)
					aAdd(aStack,{AF5->AF5_ORCAME,AF5->AF5_EDT,AF5->AF5_NIVEL})

					If aMarkPrj[i,1] == "AF5"
						dbSelectArea("AF5")
						dbGoto(aMarkPrj[i,2])

						aAdd(aRecCpy, {"AF5", AF5->(RecNo()), AF5->AF5_NIVEL})
					Else
						dbSelectArea("AF2")
						dbGoto(aMarkPrj[i,2])

						aAdd(aRecCpy, {"AF2", AF2->(RecNo()), AF2->AF2_NIVEL})
					EndIf
				Next
			Else
				dbSelectArea("AF5")
				MsGoto(nRecno)
				aAdd(aStack,{AF5->AF5_ORCAME,AF5->AF5_EDT,AF5->AF5_NIVEL})
				cVersao := AF5->AF5_VERSAO
				If cAliasCpy="AF5"
					dbSelectArea("AF5")
					dbGoto(nRecCpy)

					AuxCpyAF5(AF5->AF5_ORCAME + AF5->AF5_EDT, @aRecCpy, aConfig[5])
				Else
					AF2->(dbGoto(nRecCpy))
					aAdd(aRecCpy,{"AF2",AF2->(RecNo()),AF2->AF2_NIVEL})
				EndIf
			EndIf
			ProcRegua(Len(aRecCpy))
			For nx := 1 to Len(aRecCpy)
				IncProc(STR0198+Str(nc,2,0)+STR0199)		//"Copiando estruturas [" ## "].Aguarde..."
				If aRecCpy[nx,1]=="AF5"
					AF5->(dbGoto(aRecCpy[nx,2]))
					Inclui := .T.
					cEDT   := ""
					If ExistBlock("PMSCPAF5")
						lOk := .T.
						While lOK
							cEDT := ExecBlock("PMSCPAF5",.F.,.F.,{ cEDT ,"AF5" ,AF5->(Recno()) })
							If !Empty(cEDT)
								If !ExistChav("AF5",aStack[Len(aStack),1] + cEDT ) .OR.!FreeForUse("AF5",aStack[Len(aStack),1] + cEDT )
									If (Aviso(STR0085+cEDT ,STR0197 + CRLF + STR0194, {STR0195,STR0196})==1)
										cEDT := ""
										lOk := .F.
									Else
										lOk := .T.
									EndIf
								Else
									lOk := .F.
								EndIf
								FreeUsedCode(.T.)
							Endif
						End
					EndIf


					While Empty(cEDT)
						cEDT := AF5->AF5_EDT

						Do Case
							Case (GetMV("MV_PMSTCOD")=="1") .And. aConfig[8] == 1
								// codificação manual //Renumerar automaticamente
								cEDT	:= PmsNumAF5(aStack[Len(aStack),1],aStack[Len(aStack),3],aStack[Len(aStack),2],,.F.)

							Case (GetMV("MV_PMSTCOD")=="1") .And. aConfig[8] == 2
								// codificação manual //Copiar código de origem
								If ExistOrcEDT( aStack[Len(aStack),1] , cEDT , .T.)
									cEDT := PMSWindowPrompt( 1, "EDT", {aStack[Len(aStack),1],AF5->AF5_EDT,cEDT})
								EndIf

							Case GetMV("MV_PMSTCOD") == "1"
								// codificação manual
								cEDT := PMSWindowPrompt( 1, "EDT", {aStack[Len(aStack),1],AF5->AF5_EDT,cEDT})

							Case GetMV("MV_PMSTCOD") == "2"
								// codificação automática
								cEDT	:= PmsNumAF5(aStack[Len(aStack),1],aStack[Len(aStack),3],aStack[Len(aStack),2],,.F.)

						EndCase
					EndDo


					RegToMemory("AF5",.F.,.F.)
					PmsNewRec("AF5")
					For nz := 1 TO FCount()
						FieldPut(nz,M->&(EVAL(bCampo,nz)))
					Next nz
					cOldCode := AF5->AF5_EDT
					cOrcCode := AF5->AF5_ORCAME
					AF5->AF5_FILIAL := xFilial("AF5")
					AF5->AF5_NIVEL  := StrZero(Val(aStack[Len(aStack),3]) + 1, TamSX3("AF5_NIVEL")[1])
					AF5->AF5_EDT    := cEDT
					AF5->AF5_ORCAME := aStack[Len(aStack),1]
					AF5->AF5_EDTPAI := aStack[Len(aStack),2]
					AF5->AF5_ORDEM  := ""
					AF5->AF5_CUSTO  := 0
					AF5->AF5_CUSTO2 := 0
					AF5->AF5_CUSTO3 := 0
					AF5->AF5_CUSTO4 := 0
					AF5->AF5_CUSTO5 := 0
					AF5->AF5_VERSAO := cVersao 

					M->AF5_OBS := MSMM(AF5->AF5_CODMEM,TamSX3("AF5_OBS")[1],,,3,,,"AF5", "AF5_CODMEM")
					If ! Empty(M->AF5_OBS)
						AF5->AF5_CODMEM := ""
						M->AF5_CODMEM   := ""
						cCODMEM := CriaVar("AF5_CODMEM")
						MSMM(cCodMem,TamSx3("AF5_OBS")[1],,M->AF5_OBS,1,,,"AF5","AF5_CODMEM")
					Endif

					MsUnlock()

					If ExistBlock("PMAOCPY")
						ExecBlock("PMAOCPY", .F., .F., {"E", AF5->AF5_ORCAME, AF5->AF5_EDT, cOrcCode, cOldCode})
					EndIf

					If aConfig[4]
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Pesquisa todos os documentos da tarefa.     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("AC9")
						dbSetOrder(2)
						MsSeek(xFilial("AC9") + "AF5" + M->AF5_FILIAL + M->AF5_ORCAME + M->AF5_EDT)
						While !Eof() .And. AllTrim(xFilial("AC9") + "AF5" + M->AF5_FILIAL + M->AF5_ORCAME + M->AF5_EDT)==;
							Alltrim(AC9->AC9_FILIAL + AC9->AC9_ENTIDA + AC9->AC9_FILENT + AC9->AC9_CODENT)
							aAuxArea := GetArea()
							RegToMemory("AC9",.F.,.F.)
							PmsNewRec("AC9")
							For nz := 1 TO FCount()
								FieldPut(nz,M->&(EVAL(bCampo,nz)))
							Next nz
							AC9->AC9_FILIAL := xFilial("AC9")
							AC9->AC9_ENTIDA := "AF5"
							AC9->AC9_FILENT := AF5->AF5_FILIAL
							AC9->AC9_CODENT := AF5->AF5_ORCAME + AF5->AF5_EDT
							MsUnlock()
							RestArea(aAuxArea)
							dbSKip()
						End
					EndIf
					If nx < Len(aRecCpy)
						If Val(aRecCpy[nx,3]) < Val(aRecCpy[nx+1,3])
							aAdd(aStack,{AF5->AF5_ORCAME,AF5->AF5_EDT,AF5->AF5_NIVEL})
						Else
							If Val(aRecCpy[nx,3]) > Val(aRecCpy[nx+1,3])
								For ni := 1 To Val(aRecCpy[nx,3]) - Val(aRecCpy[nx+1,3])
									aSize(aStack, Len(aStack) - 1)
								Next ni
							EndIf
						EndIf
					EndIf
				Else
					AF2->(dbGoto(aRecCpy[nx,2]))

					Inclui  := .T.
					cTarefa := ""
					If ExistBlock("PMSCPAF2")
						lOk := .T.
						While lOK
							cTarefa := ExecBlock("PMSCPAF2",.F.,.F.,{ cTarefa ,"AF2" ,AF2->(Recno()) })
							If !Empty(cTarefa)
								If !ExistChav("AF2" ,aStack[Len(aStack),1] + cTarefa ) .OR.!FreeForUse("AF2",aStack[Len(aStack),1] + cTarefa )
									If (Aviso(STR0084+cTarefa ,STR0193 + CRLF + STR0194, {STR0195,STR0196})==1)
										cTarefa := ""
										lOk := .F.
									Else
										lOk := .T.
									EndIf
								Else
									lOk := .F.
								EndIf
								FreeUsedCode(.T.)
							Endif
						End
					EndIf


					While Empty(cTarefa)
						cTarefa := AF2->AF2_TAREFA

						Do Case
							Case (GetMV("MV_PMSTCOD")=="1") .And. aConfig[8] == 1
								// codificação manual //Renumerar automaticamente
								cTarefa	:= PmsNumAF2(aStack[Len(aStack),1],aStack[Len(aStack),3],aStack[Len(aStack),2],,.T.)

							Case (GetMV("MV_PMSTCOD")=="1") .And. aConfig[8] == 2
								// codificação manual //Copiar código de origem
								If ExistOrcTrf( aStack[Len(aStack),1] , cTarefa , .T.)
									cTarefa := PMSWindowPrompt( 1, "TAREFA", {aStack[Len(aStack),1],AF2->AF2_TAREFA,cTarefa})
								EndIf

							Case GetMV("MV_PMSTCOD") == "1"
								// codificação manual
								cTarefa := PMSWindowPrompt( 1, "TAREFA", {aStack[Len(aStack),1],AF2->AF2_TAREFA,cTarefa})

							Case GetMV("MV_PMSTCOD") == "2"
								// codificação automática
								cTarefa := PmsNumAF2(aStack[Len(aStack),1],aStack[Len(aStack),3],aStack[Len(aStack),2],,.T.)

						EndCase
					EndDo


					RegToMemory("AF2",.F.,.F.)
					PmsNewRec("AF2")
					For nz := 1 TO FCount()
						FieldPut(nz,M->&(EVAL(bCampo,nz)))
					Next nz
					cOldCode := AF2->AF2_TAREFA
					cOrcCode := AF2->AF2_ORCAME
					AF2->AF2_FILIAL := xFilial("AF2")
					AF2->AF2_NIVEL  := StrZero(Val(aStack[Len(aStack),3]) + 1, TamSX3("AF2_NIVEL")[1])
					AF2->AF2_TAREFA := cTarefa
					AF2->AF2_EDTPAI := aStack[Len(aStack),2]
					AF2->AF2_ORCAME := aStack[Len(aStack),1]
					AF2->AF2_ORDEM  := ""
					AF2->AF2_VERSAO := cVersao

					M->AF2_OBS := MSMM(AF2->AF2_CODMEM,TamSX3("AF2_OBS")[1],,,3,,,"AF2", "AF2_CODMEM")
					If ! Empty(M->AF2_OBS)
						AF2->AF2_CODMEM := ""
						M->AF2_CODMEM   := ""
						cCODMEM := CriaVar("AF2_CODMEM")
						MSMM(cCodMem,TamSx3("AF2_OBS")[1],,M->AF2_OBS,1,,,"AF2","AF2_CODMEM")
					Endif

					MsUnlock()

					If ExistBlock("PMAOCPY")
						ExecBlock("PMAOCPY", .F., .F., {"T", AF2->AF2_ORCAME, AF2->AF2_TAREFA, cOrcCode, cOldCode})
					EndIf

					aAdd(aRelac,{M->AF2_TAREFA,AF2->AF2_TAREFA,AF2->AF2_ORCAME})
					aAdd(aRecAF2,AF2->(RecNo()))
					If aConfig[1]
						dbSelectArea("AF3")
						dbSetOrder(1)
						MsSeek(xFilial()+M->AF2_ORCAME+M->AF2_TAREFA)
						While !Eof() .And. xFilial()+M->AF2_ORCAME+M->AF2_TAREFA==;
							AF3->AF3_FILIAL+AF3->AF3_ORCAME+AF3->AF3_TAREFA

							If Empty(AF3->AF3_RECURS)
								aAuxArea := GetArea()
								RegToMemory("AF3",.F.,.F.)
								PmsNewRec("AF3")
								For nz := 1 TO FCount()
									FieldPut(nz,M->&(EVAL(bCampo,nz)))
								Next nz
								AF3->AF3_FILIAL := xFilial("AF3")
								AF3->AF3_ORCAME := AF2->AF2_ORCAME
								AF3->AF3_TAREFA := AF2->AF2_TAREFA
								AF3->AF3_VERSAO := cVersao
								MsUnlock()
								RestArea(aAuxArea)
							EndIf

							dbSkip()
						End
					EndIf

					// recurso
					If aConfig[6]
						dbSelectArea("AF3")
						dbSetOrder(1)
						MsSeek(xFilial() + M->AF2_ORCAME + M->AF2_TAREFA)
						While !Eof() .And. xFilial() + M->AF2_ORCAME + M->AF2_TAREFA == ;
							AF3->AF3_FILIAL + AF3->AF3_ORCAME + AF3->AF3_TAREFA

							If !Empty(AF3->AF3_RECURS)
								aAuxArea := GetArea()
								RegToMemory("AF3", .F., .F.)
								PmsNewRec("AF3")
								For nz := 1 TO FCount()
									FieldPut(nz, M->&(EVAL(bCampo, nz)))
								Next nz
								AF3->AF3_FILIAL := xFilial("AF3")
								AF3->AF3_ORCAME := AF2->AF2_ORCAME
								AF3->AF3_TAREFA := AF2->AF2_TAREFA
								AF3->AF3_VERSAO := cVersao
								MsUnlock()
								RestArea(aAuxArea)
							EndIf

							AF3->(dbSkip())
						End
					EndIf
					If aConfig[2]
						dbSelectArea("AF4")
						dbSetOrder(1)
						MsSeek(xFilial()+M->AF2_ORCAME+M->AF2_TAREFA)
						While !Eof() .And. xFilial()+M->AF2_ORCAME+M->AF2_TAREFA==;
							AF4->AF4_FILIAL+AF4->AF4_ORCAME+AF4->AF4_TAREFA
							aAuxArea := GetArea()
							RegToMemory("AF4",.F.,.F.)
							PmsNewRec("AF4")
							For nz := 1 TO FCount()
								FieldPut(nz,M->&(EVAL(bCampo,nz)))
							Next nz
							AF4->AF4_FILIAL := xFilial("AF4")
							AF4->AF4_ORCAME := AF2->AF2_ORCAME
							AF4->AF4_TAREFA := AF2->AF2_TAREFA
							MsUnlock()
							RestArea(aAuxArea)
							dbSkip()
						End
					EndIf
					If aConfig[4]
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Pesquisa todos os documentos da tarefa.     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("AC9")
						dbSetOrder(2)
						MsSeek(xFilial("AC9") + "AF2" + M->AF2_FILIAL + M->AF2_ORCAME + M->AF2_TAREFA)
						While !Eof() .And. AllTrim(xFilial("AC9") + "AF2" + M->AF2_FILIAL + M->AF2_ORCAME + M->AF2_TAREFA)==;
							Alltrim(AC9->AC9_FILIAL + AC9->AC9_ENTIDA + AC9->AC9_FILENT + AC9->AC9_CODENT)
							aAuxArea := GetArea()
							RegToMemory("AC9",.F.,.F.)
							PmsNewRec("AC9")
							For nz := 1 TO FCount()
								FieldPut(nz,M->&(EVAL(bCampo,nz)))
							Next nz
							AC9->AC9_FILIAL := xFilial("AC9")
							AC9->AC9_ENTIDA := "AF2"
							AC9->AC9_FILENT := AF2->AF2_FILIAL
							AC9->AC9_CODENT := AF2->AF2_ORCAME + AF2->AF2_TAREFA
							MsUnlock()
							RestArea(aAuxArea)
							dbSKip()
						End
					EndIf
					dbSelectArea("AF7")
					dbSetOrder(1)
					MsSeek(xFilial()+M->AF2_ORCAME+M->AF2_TAREFA)
					While !Eof() .And. xFilial()+M->AF2_ORCAME+M->AF2_TAREFA==;
						AF7->AF7_FILIAL+AF7->AF7_ORCAME+AF7->AF7_TAREFA
						aAdd(aLinks,{AF7->AF7_TAREFA,AF7->AF7_PREDEC,AF7->AF7_TIPO,AF7->AF7_HRETAR})
						dbSkip()
					End
					If nx < Len(aRecCpy)
						For ni := 1 to Val(aRecCpy[nx,3])-Val(aRecCpy[nx+1,3])
							aDel(aStack,Len(aStack))
							aSize(aStack,Len(aStack)-1)
						Next ni
					EndIf
				EndIf
			Next nx
			If aConfig[3]
				cItem   := "00"
				cUltTrf := ""
				For nx := 1 to Len(aLinks)
					nPosTsk :=aScan(aRelac,{|x| x[1]==aLinks[nx,1]})
					nPosPrd :=aScan(aRelac,{|x| x[1]==aLinks[nx,2]})
					If nPosTsk > 0 .And. nPosPrd > 0
						If AllTrim(cUltTrf) != AllTrim(aRelac[nPosTsk,1])
							cItem := "00"
							cUltTrf := aRelac[nPosTsk,1]
						EndIf
						cItem := Soma1(cItem)

						PmsNewRec("AF7")
						AF7->AF7_FILIAL := xFilial("AF7")
						AF7->AF7_ITEM	:= cItem
						AF7->AF7_ORCAME := aRelac[nPosTsk,3]
						AF7->AF7_TAREFA := aRelac[nPosTsk,2]
						AF7->AF7_PREDEC := aRelac[nPosPrd,2]
						AF7->AF7_TIPO	:= aLinks[nx,3]
						AF7->AF7_HRETAR	:= aLinks[nx,4]
						AF7->AF7_VERSAO := cVersao
						MsUnlock()
					EndIf
				Next nx
			EndIf

		ElseIf nOrcPrj == 2

			//
			// Projeto -> Orçamento
			//

			If Len(aMarkPrj) > 0

				For i := 1 To Len(aMarkPrj)
					dbSelectArea("AF5")
					MsGoto(nRecno)
					aAdd(aStack,{AF5->AF5_ORCAME,AF5->AF5_EDT,AF5->AF5_NIVEL})

					If aMarkPrj[i,1] == "AFC"
						dbSelectArea("AFC")
						dbGoto(aMarkPrj[i,2])

						aAdd(aRecCpy, {"AFC", AFC->(RecNo()), AFC->AFC_NIVEL})
					Else
						dbSelectArea("AF9")
						dbGoto(aMarkPrj[i,2])

						aAdd(aRecCpy, {"AF9", AF9->(RecNo()), AF9->AF9_NIVEL})
					EndIf
				Next
			Else

				dbSelectArea("AF5")
				MsGoto(nRecno)
				aAdd(aStack,{AF5->AF5_ORCAME,AF5->AF5_EDT,AF5->AF5_NIVEL})
				cVersao := AF5->AF5_VERSAO 
				If cAliasCpy = "AFC"
					dbSelectArea("AFC")
					dbGoto(nRecCpy)
					AuxCpyAFC(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,@aRecCpy,aConfig[5],,aMarkPrj)
				Else
					AF9->(dbGoto(nRecCpy))
					aAdd(aRecCpy,{"AF9",AF9->(RecNo()),AF9->AF9_NIVEL})
				EndIf
			EndIf
			ProcRegua(Len(aRecCpy))

			For nx := 1 to Len(aRecCpy)
				IncProc(STR0198+Str(nc,2,0)+STR0199)		//"Copiando estruturas [" ## "].Aguarde..."
				If aRecCpy[nx,1] == "AFC"
					AFC->(dbGoto(aRecCpy[nx,2]))
					Inclui := .T.
					cEDT   := ""
					If ExistBlock("PMSCPAF5")
						lOk := .T.
						While lOK
							cEDT := ExecBlock("PMSCPAF5",.F.,.F.,{ cEDT ,"AFC" ,AFC->(Recno()) })
							If !Empty(cEDT)
								If !ExistChav("AF5",aStack[Len(aStack),1] + cEDT) .OR.!FreeForUse("AF5",aStack[Len(aStack),1] + cEDT )
									If (Aviso(STR0085+cEDT ,STR0197 + CRLF + STR0194, {STR0195,STR0196})==1)
										cEDT := ""
										lOk := .F.
									Else
										lOk := .T.
									EndIf
								Else
									lOk := .F.
								EndIf
								FreeUsedCode(.T.)
							Endif
						End
					EndIf


					While Empty(cEDT)
						cEDT := AFC->AFC_EDT

						Do Case
							Case (GetMV("MV_PMSTCOD")=="1") .And. aConfig[8] == 1
								// codificação manual //Renumerar automaticamente
								cEDT	:= PmsNumAF5(aStack[Len(aStack),1],aStack[Len(aStack),3],aStack[Len(aStack),2],,.F.)

							Case (GetMV("MV_PMSTCOD")=="1") .And. aConfig[8] == 2
								// codificação manual //Copiar código de origem
								If ExistOrcEDT( aStack[Len(aStack),1] , cEDT , .T.)
									cEDT := PMSWindowPrompt( 1, "EDT", {aStack[Len(aStack),1],AFC->AFC_EDT,cEDT})
								EndIf

							Case GetMV("MV_PMSTCOD") == "1"
								// codificação manual
								cEDT := PMSWindowPrompt( 1, "EDT", {aStack[Len(aStack),1],AFC->AFC_EDT,cEDT})

							Case GetMV("MV_PMSTCOD") == "2"
								// codificação automática
								cEDT	:= PmsNumAF5(aStack[Len(aStack),1],aStack[Len(aStack),3],aStack[Len(aStack),2],,.F.)

						EndCase
					EndDo


					RegToMemory("AF5",.T.,.F.)
					PmsNewRec("AF5")
					For nz := 1 TO FCount()
						cCampoAFC := "AFC_" + Substr(EVAL(bCampo,nz),5,6)
						If AFC->(ColumnPos(cCampoAFC) > 0)
							&("M->"+EVAL(bCampo,nz)) := &("AFC->"+cCampoAFC)
						EndIf
						FieldPut(nz,M->&(EVAL(bCampo,nz)))
					Next nz
					AF5->AF5_FILIAL := xFilial("AF5")
					AF5->AF5_NIVEL  := StrZero(Val(aStack[Len(aStack),3]) + 1, TamSX3("AF5_NIVEL")[1])
					AF5->AF5_EDT    := cEDT
					AF5->AF5_ORCAME := aStack[Len(aStack),1]
					AF5->AF5_EDTPAI := aStack[Len(aStack),2]
					AF5->AF5_ORDEM  := ""
					AF5->AF5_CUSTO  := 0
					AF5->AF5_CUSTO2 := 0
					AF5->AF5_CUSTO3 := 0
					AF5->AF5_CUSTO4 := 0
					AF5->AF5_CUSTO5 := 0
					AF5->AF5_VERSAO := cVersao 
					MsUnlock()

					If ExistBlock("PMP2BCPY")
						ExecBlock("PMP2BCPY", .F., .F., {"E", AF5->AF5_ORCAME, AF5->AF5_EDT, AFC->AFC_PROJET, ;
						AFC->AFC_REVISA, AFC->AFC_EDT})
					EndIf

					If aConfig[4]
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Pesquisa todos os documentos da tarefa.     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("AC9")
						dbSetOrder(2)
						MsSeek(xFilial("AC9") + "AFC" + AFC->AFC_FILIAL + AFC->AFC_PROJET + M->AF5_EDT)
						While !Eof() .And. AllTrim(xFilial("AC9") + "AFC" + AFC->AFC_FILIAL + AFC->AFC_PROJET + AFC->AFC_EDT)==;
							Alltrim(AC9->AC9_FILIAL + AC9->AC9_ENTIDA + AC9->AC9_FILENT + AC9->AC9_CODENT)
							aAuxArea := GetArea()
							RegToMemory("AC9",.F.,.F.)
							PmsNewRec("AC9")
							For nz := 1 TO FCount()
								FieldPut(nz,M->&(EVAL(bCampo,nz)))
							Next nz
							AC9->AC9_FILIAL := xFilial("AC9")
							AC9->AC9_ENTIDA := "AF5"
							AC9->AC9_FILENT := AF5->AF5_FILIAL
							AC9->AC9_CODENT := AF5->AF5_ORCAME + AF5->AF5_EDT
							MsUnlock()
							RestArea(aAuxArea)
							dbSKip()
						End
					EndIf
					If nx < Len(aRecCpy)
						If Val(aRecCpy[nx,3]) < Val(aRecCpy[nx+1,3])
							aAdd(aStack,{AF5->AF5_ORCAME,AF5->AF5_EDT,AF5->AF5_NIVEL})
						Else
							If Val(aRecCpy[nx,3]) > Val(aRecCpy[nx+1,3])
								For ni := 1 To Val(aRecCpy[nx,3]) - Val(aRecCpy[nx+1,3])
									aSize(aStack, Len(aStack) - 1)
								Next ni
							EndIf
						EndIf
					EndIf
				Else
					AF9->(dbGoto(aRecCpy[nx,2]))

					Inclui  := .T.
					cTarefa := ""
					If ExistBlock("PMSCPAF2")
						lOk := .T.
						While lOK
							cTarefa := ExecBlock("PMSCPAF2",.F.,.F.,{ cTarefa ,"AF9" ,AF9->(Recno()) })
							If !Empty(cTarefa)
								If !ExistChav("AF2",aStack[Len(aStack),1] + cTarefa ) .OR.!FreeForUse("AF2",aStack[Len(aStack),1] + cTarefa)
									If (Aviso(STR0084+cTarefa ,STR0193 + CRLF + STR0194, {STR0195,STR0196})==1)
										cTarefa := ""
										lOk := .F.
									Else
										lOk := .T.
									EndIf
								Else
									lOk := .F.
								EndIf
								FreeUsedCode(.T.)
							Endif
						End
					EndIf


					While Empty(cTarefa)
						cTarefa := AF9->AF9_TAREFA

						Do Case
							Case (GetMV("MV_PMSTCOD")=="1") .And. aConfig [8] == 1
								// codificação manual //Renumerar automaticamente
								cTarefa	:= PmsNumAF2(aStack[Len(aStack),1],aStack[Len(aStack),3],aStack[Len(aStack),2],,.T.)

							Case (GetMV("MV_PMSTCOD")=="1") .And. aConfig [8] == 2
								// codificação manual //Copiar código de origem
								If ExistOrcTrf( aStack[Len(aStack),1] , cTarefa , .T.)
									cTarefa := PMSWindowPrompt( 1, "TAREFA", {aStack[Len(aStack),1],AF9->AF9_TAREFA,cTarefa})
								EndIf

							Case GetMV("MV_PMSTCOD") == "1"
								// codificação manual
								cTarefa := PMSWindowPrompt( 1, "TAREFA", {aStack[Len(aStack),1],AF9->AF9_TAREFA,cTarefa})

							Case GetMV("MV_PMSTCOD") == "2"
								// codificação automática
								cTarefa := PmsNumAF2(aStack[Len(aStack),1],aStack[Len(aStack),3],aStack[Len(aStack),2],,.T.)

						EndCase
					EndDo


					RegToMemory("AF2",.T.,.F.)
					PmsNewRec("AF2")
					For nz := 1 TO FCount()
						cCampoAF9 := "AF9_" + Substr(EVAL(bCampo,nz),5,6)
						IF cCampoAF9 != "AF9_CODMEM" .and. AF9->(ColumnPos(cCampoAF9) > 0)
							&("M->"+EVAL(bCampo,nz)) := &("AF9->"+cCampoAF9)
						EndIf
						if cCampoAF9 == "AF9_CODMEM"
						cAux := MSMM(AF9->AF9_CODMEM)
						EndIf

						FieldPut(nz,M->&(EVAL(bCampo,nz)))
					Next nz

					AF2->AF2_FILIAL := xFilial("AF2")
					AF2->AF2_NIVEL  := StrZero(Val(aStack[Len(aStack),3]) + 1, TamSX3("AF2_NIVEL")[1])
					AF2->AF2_TAREFA := cTarefa
					AF2->AF2_EDTPAI := aStack[Len(aStack),2]
					AF2->AF2_ORCAME := aStack[Len(aStack),1]
					AF2->AF2_ORDEM  := ""
					AF2->AF2_VERSAO := cVersao
					MsUnlock()
					AF2->(RecLock("AF2"))
					MSMM(,len(cAux) ,,cAux ,1 ,,,"AF2" ,"AF2_CODMEM")
					MsUnlock()

					If ExistBlock("PMP2BCPY")
						ExecBlock("PMP2BCPY", .F., .F., {"T", AF2->AF2_ORCAME, AF2->AF2_TAREFA, AF9->AF9_PROJET, ;
						AF9->AF9_REVISA, AF9->AF9_TAREFA})
					EndIf

					aAdd(aRelac,{AF2->AF2_TAREFA,AF9->AF9_TAREFA,AF2->AF2_ORCAME})
					aAdd(aRecAF2,AF2->(RecNo()))
					If aConfig[1]
						dbSelectArea("AFA")
						dbSetOrder(1) //AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA+AFA_ITEM
						MsSeek(xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
						While !Eof() .And. xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==;
							AFA->AFA_FILIAL+AFA->AFA_PROJET+AFA->AFA_REVISA+AFA->AFA_TAREFA
							aAuxArea := GetArea()
							If Empty(AFA->AFA_RECURS)
								RegToMemory("AF3",.T.,.F.)
								PmsNewRec("AF3")
								For nz := 1 TO FCount()
									cCampoAFA := "AFA_" + Substr(EVAL(bCampo,nz),5,6)
									If AFA->(ColumnPos(cCampoAFA) > 0)
										&("M->"+EVAL(bCampo,nz)) := &("AFA->"+cCampoAFA)
									EndIf
									FieldPut(nz,M->&(EVAL(bCampo,nz)))
								Next nz
								AF3->AF3_FILIAL := xFilial("AF3")
								AF3->AF3_ORCAME := AF2->AF2_ORCAME
								AF3->AF3_TAREFA := AF2->AF2_TAREFA
								AF3->AF3_VERSAO := cVersao
								MsUnlock()
							EndIf
							RestArea(aAuxArea)
							dbSkip()
						End
					EndIf

					If aConfig[6]
						dbSelectArea("AFA")
						dbSetOrder(1) //AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA+AFA_ITEM
						MsSeek(xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
						While !Eof() .And. xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==;
							AFA->AFA_FILIAL+AFA->AFA_PROJET+AFA->AFA_REVISA+AFA->AFA_TAREFA
							aAuxArea := GetArea()
							If !Empty(AFA->AFA_RECURS)
								RegToMemory("AF3",.T.,.F.)
								PmsNewRec("AF3")
								For nz := 1 TO FCount()
									cCampoAFA := "AFA_" + Substr(EVAL(bCampo,nz),5,6)
									If AFA->(ColumnPos(cCampoAFA) > 0)
										&("M->"+EVAL(bCampo,nz)) := &("AFA->"+cCampoAFA)
									EndIf
									FieldPut(nz,M->&(EVAL(bCampo,nz)))
								Next nz
								AF3->AF3_FILIAL := xFilial("AF3")
								AF3->AF3_ORCAME := AF2->AF2_ORCAME
								AF3->AF3_TAREFA := AF2->AF2_TAREFA
								AF3->AF3_VERSAO := cVersao
								MsUnlock()
							EndIf
							RestArea(aAuxArea)
							dbSkip()
						End
					EndIf

					If aConfig[2]
						dbSelectArea("AFB")
						dbSetOrder(1)
						MsSeek(xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
						While !Eof() .And. xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==;
							AFB->AFB_FILIAL+AFB->AFB_PROJET+AFB->AFB_REVISA+AFB->AFB_TAREFA
							aAuxArea := GetArea()
							RegToMemory("AF4",.T.,.F.)
							PmsNewRec("AF4")
							For nz := 1 TO FCount()
								cCampoAFB := "AFB_" + Substr(EVAL(bCampo,nz),5,6)
								If AFB->(ColumnPos(cCampoAFB) > 0)
									&("M->"+EVAL(bCampo,nz)) := &("AFB->"+cCampoAFB)
								EndIf
								FieldPut(nz,M->&(EVAL(bCampo,nz)))
							Next nz
							AF4->AF4_FILIAL := xFilial("AF4")
							AF4->AF4_ORCAME := AF2->AF2_ORCAME
							AF4->AF4_TAREFA := AF2->AF2_TAREFA
							MsUnlock()
							RestArea(aAuxArea)
							dbSkip()
						End
					EndIf
					If aConfig[4]
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Pesquisa todos os documentos da tarefa.     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("AC9")
						dbSetOrder(2)
						MsSeek(xFilial("AC9") + "AFC" + AFC->AFC_FILIAL + AFC->AFC_PROJET + M->AF5_EDT)
						While !Eof() .And. AllTrim(xFilial("AC9") + "AFC" + AFC->AFC_FILIAL + AFC->AFC_PROJET + AFC->AFC_EDT)==;
							Alltrim(AC9->AC9_FILIAL + AC9->AC9_ENTIDA + AC9->AC9_FILENT + AC9->AC9_CODENT)
							aAuxArea := GetArea()
							RegToMemory("AC9",.F.,.F.)
							PmsNewRec("AC9")
							For nz := 1 TO FCount()
								FieldPut(nz,M->&(EVAL(bCampo,nz)))
							Next nz
							AC9->AC9_FILIAL := xFilial("AC9")
							AC9->AC9_ENTIDA := "AF5"
							AC9->AC9_FILENT := AF5->AF5_FILIAL
							AC9->AC9_CODENT := AF5->AF5_ORCAME + AF5->AF5_EDT
							MsUnlock()
							RestArea(aAuxArea)
							dbSKip()
						End
					EndIf
					dbSelectArea("AFD")
					dbSetOrder(1)
					MsSeek(xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
					While !Eof() .And. xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==;
						AFD->AFD_FILIAL+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_TAREFA
						aAdd(aLinks,{AFD->AFD_TAREFA,AFD->AFD_PREDEC,AFD->AFD_TIPO,AFD->AFD_HRETAR})
						dbSkip()
					End
					If nx < Len(aRecCpy)
						For ni := 1 to Val(aRecCpy[nx,3])-Val(aRecCpy[nx+1,3])
							aDel(aStack,Len(aStack))
							aSize(aStack,Len(aStack)-1)
						Next ni
					EndIf
				EndIf
			Next nx
			If aConfig[3]
				cItem   := "00"
				cUltTrf := ""
				For nx := 1 to Len(aLinks)
					nPosTsk :=aScan(aRelac,{|x| x[2]==aLinks[nx,1]})
					nPosPrd :=aScan(aRelac,{|x| x[2]==aLinks[nx,2]})
					If nPosTsk > 0 .And. nPosPrd > 0
						If AllTrim(cUltTrf) != AllTrim(aRelac[nPosTsk,1])
							cItem := "00"
							cUltTrf := aRelac[nPosTsk,1]
						EndIf
						cItem := Soma1(cItem)

						PmsNewRec("AF7")
						AF7->AF7_FILIAL := xFilial("AF7")
						AF7->AF7_ITEM	:= cItem
						AF7->AF7_ORCAME := aRelac[nPosTsk,3]
						AF7->AF7_TAREFA := aRelac[nPosTsk,1]
						AF7->AF7_PREDEC := aRelac[nPosPrd,1]
						AF7->AF7_TIPO	:= aLinks[nx,3]
						AF7->AF7_HRETAR	:= aLinks[nx,4]
						AF7->AF7_VERSAO := cVersao
						MsUnlock()
					EndIf
				Next nx
			EndIf
		EndIf
	Next nc
	ProcRegua(Len(aRecAF2))
	For nc := 1 to len(aRecAF2)
		IncProc("Atualizando EDT.Aguarde...")
		AF2->(dbGoto(aRecAF2[nc]))
		PmsAvalAF2("AF2")
	Next nc
	lRet := .T.
EndIf

RestArea(aArea)
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AuxCpyAF5³ Autor ³ Cristiano G. da Cunha  ³ Data ³ 06-06-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao auxiliar que retorna o array com a estrutura a ser im- ³±±
±±³          ³portada no orcamento.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AuxCpyAF5(cChave,aRecCpy,lCopySel,nNivel)
Local aArea		:= GetArea()
Local aAreaAF5	:= AF5->(GetArea())
Local aAreaAF2	:= AF2->(GetArea())

Local aNodes    := {}  // array utilizado na ordenacao de tarefas e EDTs
Local nNode     := 0   // contador utilizado para iteracao com aNodes

DEFAULT nNivel := 1
If lCopySel
	dbSelectArea("AF5")
	dbSetOrder(1)
	MsSeek(xFilial()+cChave)
	aAdd(aRecCpy,{"AF5",AF5->(RecNo()),StrZero(nNivel,3)})
EndIf

dbSelectArea("AF2")
dbSetOrder(2)
MsSeek(xFilial()+cChave)
While !Eof() .And. xFilial()+AF5->AF5_ORCAME+AF5->AF5_EDT==;
	AF2->AF2_FILIAL+AF2->AF2_ORCAME+AF2->AF2_EDTPAI

	aAdd(aNodes, {PMS_TASK,;
	AF2->(Recno()),;
	IIf(Empty(AF2->AF2_ORDEM), "000", AF2->AF2_ORDEM),;
	AF2->AF2_TAREFA})
	dbSkip()
End

dbSelectArea("AF5")
dbSetOrder(2)
MsSeek(xFilial()+cChave)
While !Eof() .And. xFilial()+cChave==;
	AF5->AF5_FILIAL+AF5->AF5_ORCAME+AF5->AF5_EDTPAI

	aAdd(aNodes, {PMS_WBS,;
	AF5->(Recno()),;
	IIf(Empty(AF5->AF5_ORDEM), "000", AF5->AF5_ORDEM),;
	AF5->AF5_EDT})
	dbSkip()
End

// ordenacao conjunta de tarefa/EDTs
aSort(aNodes, , , {|x, y| x[3]+x[4] < y[3]+y[4] })

For nNode := 1 To Len(aNodes)
	If aNodes[nNode,1] == PMS_TASK  // tarefa
		aAdd(aRecCpy, {"AF2", aNodes[nNode,2], StrZero(nNivel + 1, 3)})
	Else
		AF5->(dbGoto(aNodes[nNode,2]))
		AuxCpyAF5(AF5->AF5_ORCAME + AF5->AF5_EDT, @aRecCpy, .T., nNivel + 1)
	EndIf
Next

RestArea(aAreaAF2)
RestArea(aAreaAF5)
RestArea(aArea)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAF3Quant³ Autor ³ Fabio Rogerio Pereira  ³ Data ³26-07-2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que calcula a quantidade do produto do orcamento		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAF3Quant(cOrcame,cTarefa,cProduto,nQuantTsk,nQuantPrd,nDuracTsk,lCompos,cRecurso,lProduc)
Local nRet    := 0
Local cPmsCust:= GetMV("MV_PMSCUST") //Indica se utiliza o custo pela quantidade unitaria ou total

DEFAULT cOrcame  := AF1->AF1_ORCAME
DEFAULT cTarefa  := AF2->AF2_TAREFA
DEFAULT cProduto := AF3->AF3_PRODUT
DEFAULT cRecurso := AF3->AF3_RECURS
DEFAULT nQuantTsk:= 1
DEFAULT nQuantPrd:= 1
DEFAULT nDuracTsk:= AF2->AF2_HDURAC
DEFAULT lCompos  := .F.
DEFAULT lProduc  := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica qual o tipo do calculo sera utilizado 1= Padrao 2=Template³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistTemplate("CCTAF3QUANT") .And. (GetMV("MV_PMSCCT") == "2")
	nRet:= ExecTemplate("CCTAF3QUANT",.F.,.F.,{cOrcame,cTarefa,cProduto,nQuantTsk,nQuantPrd,nDuracTsk,lCompos,cRecurso,lProduc})
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se for importacao de composicao deve calcular o valor       ³
	//³ proporcional da quantidade do produto em relacao da tarefa  ³
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	If lCompos
		nRet:= nQuantTsk * nQuantPrd
	Else
		nRet:= IIf(cPmsCust == "1",nQuantPrd,nQuantTsk * nQuantPrd)
	EndIf
EndIf

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAF4Valor³ Autor ³ Fabio Rogerio Pereira  ³ Data ³26-07-2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que calcula o valor da despesa							³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAF4Valor(nQuantTsk,nValor,lCompos)
Local nRet    := 0

DEFAULT nQuantTsk:= 1
DEFAULT nValor   := 1
DEFAULT lCompos  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for importacao de composicao faz-se a validacao contraria.³
//³Custo Total -> Utilza-se o valor unitario					³
//³Custo Unitario -> Utiliza-se a quantidade total              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistTemplate("CCTAF4VLR") .And. (GetMV("MV_PMSCCT") == "2")
	nRet:= ExecTemplate("CCTAF4VLR",.F.,.F.,{nQuantTsk,nValor,lCompos})
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se for importacao de composicao deve calcular o valor       ³
	//³ proporcional da quantidade do produto em relacao da tarefa  ³
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	If lCompos
		nRet:= nQuantTsk * nValor
	Else
		nRet:= IIf(GetMV("MV_PMSCUST") == "1",nValor,nQuantTsk * nValor)
	EndIf
EndIf

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAFAQuant³ Autor ³ Fabio Rogerio Pereira  ³ Data ³26-07-2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que calcula a quantidade do produto do projeto			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PmsAFAQuant(cProjeto,cRevisa,cTarefa,cProduto,nQuantTsk,nQuantPrd,nDuracTsk,lCompos,cRecurso,lProduc)
Local nRet    := 0
Local cPmsCust:= GetMV("MV_PMSCUST") //Indica se utiliza o custo pela quantidade unitaria ou total

DEFAULT cProjeto := AF8->AF8_PROJET
DEFAULT cRevisa  := AF8->AF8_REVISA
DEFAULT cTarefa  := AF9->AF9_TAREFA
DEFAULT cProduto := AFA->AFA_PRODUTO
DEFAULT nQuantTsk:= 1
DEFAULT nQuantPrd:= 1
DEFAULT nDuracTsk:= AF9->AF9_HDURAC
DEFAULT cRecurso := AFA->AFA_RECURS
DEFAULT lCompos  := .F.
DEFAULT lProduc  := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica qual o tipo do calculo sera utilizado 1= Padrao 2=Template³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistTemplate("CCTAFAQUANT") .And. (GetMV("MV_PMSCCT") == "2")
	nRet:= ExecTemplate("CCTAFAQUANT",.F.,.F.,{cProjeto,cRevisa,cTarefa,cProduto,nQuantTsk,nQuantPrd,nDuracTsk,lCompos,cRecurso,lProduc})
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se for importacao de composicao deve calcular o valor       ³
	//³ proporcional da quantidade do produto em relacao da tarefa  ³
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	If lCompos
		nRet:= nQuantTsk * nQuantPrd
	Else
		nRet:= IIf(cPmsCust == "1",nQuantPrd,nQuantTsk * nQuantPrd)
	EndIf
EndIf

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAFBValor³ Autor ³ Fabio Rogerio Pereira  ³ Data ³26-07-2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que calcula o valor da despesa	do projeto				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAFBValor(nQuantTsk,nValor,lCompos)
Local nRet    := 0

DEFAULT nQuantTsk:= 1
DEFAULT nValor   := 1
DEFAULT lCompos  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for importacao de composicao faz-se a validacao contraria.³
//³Custo Total -> Utilza-se o valor unitario					³
//³Custo Unitario -> Utiliza-se a quantidade total              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica qual o tipo do calculo sera utilizado 1= Padrao 2=Template³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistTemplate("CCTAFBVLR") .And. (GetMV("MV_PMSCCT") == "2")
	nRet:= ExecTemplate("CCTAFBVLR",.F.,.F.,{nQuantTsk,nValor,lCompos})
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se for importacao de composicao deve calcular o valor       ³
	//³ proporcional da quantidade do produto em relacao da tarefa  ³
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	If lCompos
		nRet:= nQuantTsk * nValor
	Else
		nRet:= IIf(GetMV("MV_PMSCUST") == "1",nValor,nQuantTsk * nValor)
	EndIf
EndIf

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAF8Ver³ Autor ³ Edson Maricate         ³ Data ³ 06-06-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a versao atual do projeto                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAF8Ver(cProjeto)
Local cReturn	:= ""
Local aArea		:= GetArea()
Local aAreaAF8	:= AF8->(GetArea())

dbSelectArea("AF8")
dbSetOrder(1)
MsSeek(xFilial("AF8")+cProjeto) // Wilson
cReturn := AF8->AF8_REVISA

RestArea(aAReaAF8)
RestArea(aARea)
Return cReturn

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAvalAFA³ Autor ³ Edson Maricate        ³ Data ³ 14-08-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de avaliacao dos recursos alocados na tarefa           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela de recursos                            ³±±
±±³          ³ExpN2: Codigo do Evento                                       ³±±
±±³          ³       [1] Implantacao de um recurso                          ³±±
±±³          ³       [2] Estorno de um recurso                              ³±±
±±³          ³       [3] Exclusao de um recurso                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAvalAFA(cAlias,nEvento)

Local aArea		:= GetArea()
Local aAreaAE8	:= AE8->(GetArea())
Local aAreaAFV	:= AFV->(GetArea())
Local aAreaAF9	:= AF9->(GetArea())
Local lAltRec	:= SuperGetMv("MV_PMSAREC",,.T.) // Altera responsável da etapa ao incluir um novo recurso?

DEFAULT lAltRec		:= SuperGetMv("MV_PMSAREC",,.T.) // Altera responsável da etapa ao incluir um novo recurso?

Do Case
	Case nEvento == 1
		AE8->(dbSetOrder(1))
		If !Empty((cAlias)->AFA_RECURS) .And. AE8->(MsSeek(xFilial("AE8")+(cAlias)->AFA_RECURS))
			AF9->(dbSetOrder(1))
			AF9->(MsSeek(xFilial("AF9")+AFA->AFA_PROJET+AFA->AFA_REVISA+AFA->AFA_TAREFA))
			dbSelectArea("AFA")
			RecLock("AFA",.F.)
				If AFA->AFA_FIX<>"1"
					AFA->AFA_ALOC := PmsAFAQuant(AFA->AFA_PROJET,AFA->AFA_REVISA,AFA->AFA_TAREFA,AFA->AFA_PRODUT,AF9->AF9_QUANT,AFA->AFA_QUANT,AF9->AF9_HDURAC)/PmsHrsItvl(AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,If(!Empty(AE8->AE8_CALEND),AE8->AE8_CALEND,AF9->AF9_CALEND),AF9->AF9_PROJET,AE8->AE8_RECURS)*100
				Else
					nQtAloc	:= (AFA->AFA_ALOC*PmsHrsItvl(AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,If(!Empty(AE8->AE8_CALEND),AE8->AE8_CALEND,AF9->AF9_CALEND),AF9->AF9_PROJET,AE8->AE8_RECURS))/100
					If nQtAloc > 0
						AFA->AFA_QUANT	:= PmsIAFAQuant(AFA->AFA_PROJET,AFA->AFA_REVISA,AFA->AFA_TAREFA,AFA->AFA_PRODUT,AF9->AF9_QUANT,nQtAloc,AF9->AF9_HDURAC)
					EndIf
				EndIf
			MsUnlock()

			If !Empty(AE8->AE8_USER)
				If !Empty(AE8->AE8_ESTRUT)
					dbSelectArea("AFV")
					dbSetOrder(1)
					If !MsSeek(xFilial("AFV")+(cAlias)->AFA_PROJET+SPACE(LEN(AFA->AFA_REVISA))+(cAlias)->AFA_TAREFA+AE8->AE8_USER)
						RecLock("AFV",.T.)
						AFV->AFV_FILIAL := xFilial("AFV")
						AFV->AFV_PROJET := AFA->AFA_PROJET
						AFV->AFV_TAREFA	:= AFA->AFA_TAREFA
						AFV->AFV_USER	:= AE8->AE8_USER
						AFV->AFV_ESTRUT := AE8->AE8_ESTRUT
						AFV->AFV_DOCUME := AE8->AE8_DOCUME
						AFV->AFV_GERSC	:= AE8->AE8_GERSC
						AFV->AFV_GERSA	:= AE8->AE8_GERSA
						AFV->AFV_GEROP	:= AE8->AE8_GEROP
						AFV->AFV_GERCP	:= AE8->AE8_GERCP
						AFV->AFV_GEREMP	:= AE8->AE8_GEREMP
						AFV->AFV_CONFIR	:= AE8->AE8_CONFIR
						AFV->AFV_NFE	:= AE8->AE8_NFE
						AFV->AFV_REQUIS	:= AE8->AE8_REQUIS
						AFV->AFV_DESP	:= AE8->AE8_DESP
						AFV->AFV_RECEI	:= AE8->AE8_RECEI
						AFV->AFV_RECURS	:= AE8->AE8_APTMRE
						AFV->AFV_NFS	:= AE8->AE8_NFS
						AFV->AFV_MOVBAN := AE8->AE8_MOVBAN
						AFV->AFV_PREREC := AE8->AE8_PREREC
						AFV->AFV_APRPRE := AE8->AE8_APRPRE
						MsUnlock()
						If lPMGRAFV
							ExecBlock("PMGRAFV",.F.,.F.)
						EndIf
					EndIf
				EndIf
			EndIf

			//
			// Se PMS esta integrado com QNC
			//
			If !Empty(AF9->AF9_FNC) .AND. !Empty(AF9->AF9_REVFNC) .AND. !Empty(AF9->AF9_ACAO) .AND. !Empty(AF9->AF9_REVACAO) .AND. !Empty(AF9->AF9_TPACAO)
				IF lAltRec
					// Altera o responsavel da ETAPA da FNC
					QNCAltResp(/*NAO PASSAR*/ ,AF9->AF9_ACAO ,AF9->AF9_REVACAO ,AF9->AF9_TPACAO ,RDZRetEnt("AE8",xFilial("AE8")+(cAlias)->AFA_RECURS,"QAA",,,,.F.))
				EndIf
			EndIf
		EndIf
	Case nEvento == 2
		// Nil
	Case nEvento == 3
		If !Empty((cAlias)->AFA_RECURS)
			AE8->(dbSetOrder(1))
			AE8->(MsSeek(xFilial()+(cAlias)->AFA_RECURS))
			If !Empty(AE8->AE8_USER)
				dbSelectArea("AFV")
				dbSetOrder(1)
				If MsSeek(xFilial("AFV")+(cAlias)->AFA_PROJET+SPACE(LEN(AFA->AFA_REVISA))+(cAlias)->AFA_TAREFA+AE8->AE8_USER)
					RecLock("AFV",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
			EndIf
		EndIf
EndCase

If lPMSGAFA
	cEDT := ExecBlock("PMSGAFA",.F.,.F.,{nEvento})
EndIf

RestArea(aAreaAE8)
RestArea(aAreaAF9)
RestArea(aAreaAFV)
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAvalAFG³ Autor ³ Edson Maricate        ³ Data ³ 14-08-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de avaliacao da amarracao Tarefas x SC                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela de amarracao                           ³±±
±±³          ³ExpN2: Codigo do Evento                                       ³±±
±±³          ³       [1] Implantacao de uma amarracao                       ³±±
±±³          ³       [2] Estorno de um amarracao                            ³±±
±±³          ³       [3] Exclusao de uma amarracao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAvalAFG(cAlias,nEvento,cPlaneja)

Local aArea		:= GetArea()
Local aAreaAFG	:= AFG->(GetArea())
Local aAreaSC1	:= SC1->(GetArea())
Local cTRT		:= ""
Local lGetEmp   := SuperGetMV("MV_PMSOPSC",,"1") == "1"
Local nQtd			:= 0

Default cPlaneja := ""

Do Case
	Case nEvento == 1
		SC1->(dbSetOrder(1))
		If SC1->(MsSeek(PmsFilial("SC1","AFG")+(cAlias)->AFG_NUMSC+(cAlias)->AFG_ITEMSC))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza os empenhos do Projeto                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cTRT := (cAlias)->AFG_TRT
			PmsAtuEmp((cAlias)->AFG_PROJET,(cAlias)->AFG_TAREFA,SC1->C1_PRODUTO,SC1->C1_LOCAL,(cAlias)->AFG_QUANT,"+",.T.,(cAlias)->AFG_QTSEGU,@cTRT,SC1->C1_DATPRF,"1",cPlaneja,SC1->C1_TPOP=="P")
			RecLock("AFG",.F.)
			AFG->AFG_TRT := cTRT
			MsUnlock()
			If cAlias <> 'AFG'
				AFG->(DbSetOrder(1))
				AFG->(MsSeek(&(cAliasAFG+"->"+AFG->(IndexKey()))))
			Endif
			RecLock('AFG',.F.)
			AFG->AFG_NATEND	:=	0
			AFG->AFG_NATEN2	:=	0
			MsUnLock()

		EndIf
	Case nEvento == 2
		SC1->(dbSetOrder(1))
		If lGetEmp
			If SC1->(MsSeek(PmsFilial("SC1","AFG")+(cAlias)->AFG_NUMSC+(cAlias)->AFG_ITEMSC))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza os empenhos do Projeto                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If AllTrim(FunName()) == "MATA235" //Eliminação de residuo
					nQtd := (SC1->C1_QUANT-SC1->C1_QUJE)
					
					If nQtd > (cAlias)->AFG_QUANT
						nQtd := (cAlias)->AFG_QUANT
					Endif
				Else
					nQtd := (cAlias)->AFG_QUANT
				Endif
				
				PmsAtuEmp((cAlias)->AFG_PROJET,(cAlias)->AFG_TAREFA,SC1->C1_PRODUTO,SC1->C1_LOCAL,nQtd,"-",.T.,(cAlias)->AFG_QTSEGU,(cAlias)->AFG_TRT,SC1->C1_DATPRF,"1",,SC1->C1_TPOP=="P")
				If cAlias <> 'AFG'
					AFG->(DbSetOrder(1))
					AFG->(MsSeek(&(cAliasAFG+"->"+AFG->(IndexKey()))))
				Endif
				RecLock('AFG',.F.)
				AFG->AFG_NATEND	+=	(SC1->C1_QUANT-SC1->C1_QUJE)
				AFG->AFG_NATEN2	+=	ConvUm(SC1->C1_PRODUTO,(SC1->C1_QUANT-SC1->C1_QUJE))
				MsUnLock()

			EndIf
		Else
			dbSelectArea("AFJ")
			dbSetOrder(3)
			If MsSeek(xFilial("AFJ")+(cAlias)->AFG_PROJET+(cAlias)->AFG_TAREFA+(cAlias)->AFG_TRT)
				// Caso a OP tenha sido gerada por um planejamento e o parametro estiver ativo
				// o empenho deverá permanecer, caso contrario, sera um empenho pontual do prj
				// e conceitualmente nao ha necessidade de manter o seu empenho

				If EMPTY(AFJ->AFJ_PLANEJ) // Se nao foi gerado por planejamento do PMS deleta o empenho

					If SC1->(MsSeek(PmsFilial("SC1","AFG")+(cAlias)->AFG_NUMSC+(cAlias)->AFG_ITEMSC))
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza os empenhos do Projeto                      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If AllTrim(FunName()) == "MATA235" //Eliminação de residuo
							nQtd := (SC1->C1_QUANT-SC1->C1_QUJE)
							
							If nQtd > (cAlias)->AFG_QUANT
								nQtd := (cAlias)->AFG_QUANT
							Endif
						Else
							nQtd := (cAlias)->AFG_QUANT
						Endif
						
						PmsAtuEmp((cAlias)->AFG_PROJET,(cAlias)->AFG_TAREFA,SC1->C1_PRODUTO,SC1->C1_LOCAL,nQtd,"-",.T.,(cAlias)->AFG_QTSEGU,(cAlias)->AFG_TRT,SC1->C1_DATPRF,"1",,SC1->C1_TPOP=="P")
						If cAlias <> 'AFG'
							AFG->(DbSetOrder(1))
							AFG->(MsSeek(&(cAliasAFG+"->"+AFG->(IndexKey()))))
						Endif
						RecLock('AFG',.F.)
						AFG->AFG_NATEND	+=	(SC1->C1_QUANT-SC1->C1_QUJE)
						AFG->AFG_NATEN2	+=	ConvUm(SC1->C1_PRODUTO,(SC1->C1_QUANT-SC1->C1_QUJE))
						MsUnLock()

					EndIf

				ENDIF
			EndIf
    	EndIf
	Case nEvento == 3
		If ExistBlock("PMSEXCSC")
			ExecBlock("PMSEXCSC",.F.,.F.)
		EndIf

		///////////////////////////////////////////////////
		// DENARDI - 10.07.06
		// Somente irá buscar as dependencias na AFA caso
		// AFG_PLANEJ estiver preenchido, indicando que foi
		// gerado atraves de um planejamento do PMS
		RecLock("AFG",.F.,.T.)
		dbDelete()
		MsUnlock()
EndCase
RestArea(aAreaSC1)
RestArea(aAreaAFG)
RestArea(aArea)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAvalAFI³ Autor ³ Edson Maricate        ³ Data ³ 14-08-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de avaliacao das mov. internas ao projeto              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela de amarracao                           ³±±
±±³          ³ExpN2: Codigo do Evento                                       ³±±
±±³          ³       [1] Implantacao de uma amarracao                       ³±±
±±³          ³       [2] Estorno de um amarracao                            ³±±
±±³          ³       [3] Exclusao de uma amarracao                          ³±±
±±³          ³ExpA3: Array contendo o custo do movimento                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAvalAFI(cAlias,nEvento,aCusto)

Local aArea		:= GetArea()
Local aAreaAFI	:= AFI->(GetArea())
Local aAreaSD3	:= SD3->(GetArea())
Local cChvSD3  := (cAlias)->AFI_COD+(cAlias)->AFI_LOCAL+DTOS((cAlias)->AFI_EMISSA)+(cAlias)->AFI_NUMSEQ
Local cSinal
Local cFilSD3 		:= ""
Local cFilOldSD3 	:= ""
Local nQtd          := 0
Local cQuery		:=""
Local cAreaTMP
Do Case
	Case nEvento == 1

		cFilSD3 	:= PmsFilial("SD3","AFI")
		cFilOldSD3  := cFilAnt
		If cFilSD3 <> ""
			cFilAnt := cFilSD3
		EndIf

		SD3->(dbSetOrder(7))
		If SD3->(MsSeek(xFilial("SD3")+cChvSD3))
			aCusto := If(aCusto==Nil,PegaCusD3(),aCusto)
			cSinal := If(SD3->D3_TM > "500", "-", "+")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Efetua a baixa dos empenhos do Projeto               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PmsBxEmp((cAlias)->AFI_PROJET,(cAlias)->AFI_TAREFA,SD3->D3_COD,SD3->D3_LOCAL,SD3->D3_QUANT,cSinal,SD3->D3_QTSEGUM,SD3->D3_TRT)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza os valores da Tarefa                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AF9AtuComD3(aCusto)

			nQtd := AFI->AFI_QUANT
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Integração com TOP, inclui apropriacao para o projeto.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !(IsIntegTop())
				IF (GetNewPar("MV_RMCOLIG",0) >0) .And. IntePms()
					cQuery:= "SELECT AFH_ITEMSA FROM "+ RetSQLName("AFH")
					cQuery+=" WHERE AFH_FILIAL = '"+xFilial("AFH")+"' AND AFH_PROJET='"+(cAlias)->AFI_PROJET+"'"
					cQuery+=" AND AFH_REVISA ='0001' AND AFH_TAREFA='"+(cAlias)->AFI_TAREFA+"'"
					cQuery+=" AND AFH_NUMSA='"+SCP->CP_NUM+"' AND AFH_COD='"+(cAlias)->AFI_COD+"' AND D_E_L_E_T_ =' '"
					cQuery := ChangeQuery(cQuery)
					cAreaTMP:=GetNextAlias()
					If Select(cAreaTMP)>0
						(cAreaTMP)->(dbCloseArea())
					EndIf
					dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAreaTMP, .T., .T.)
					If (cAreaTMP)->(!EOF())
						If !SlmAtuMov((cAlias)->AFI_PROJET, (cAlias)->AFI_TAREFA, SCP->CP_NUM , (cAreaTMP)->AFH_ITEMSA, SD3->D3_QUANT ,SD3->D3_CUSTO1,"SA", nEvento )
							SLMPMSCOST(0, "AFI", (cAlias)->AFI_EMISSA, (cAlias)->AFI_PROJET, (cAlias)->AFI_TAREFA, (cAlias)->AFI_COD, (cAlias)->AFI_QUANT, SD3->D3_CUSTO1/SD3->D3_QUANT)
						EndIf
					Endif
					(cAreaTMP)->(dbCloseArea())
				Endif
			Endif
		EndIf

		cFilAnt := cFilOldSD3

	Case nEvento == 2

		cFilSD3 		:= PmsFilial("SD3","AFI")
		cFilOldSD3  := cFilAnt
		If cFilSD3 <> ""
			cFilAnt 	:= cFilSD3
		EndIf

		SD3->(dbSetOrder(7))

		If SD3->(MsSeek(xFilial("SD3")+cChvSD3))
			While SD3->(! EOF() .And. D3_FILIAL+D3_COD+D3_LOCAL+DTOS(D3_EMISSAO)+D3_NUMSEQ == xFilial("SD3")+cChvSD3 )
				If Substr(SD3->D3_TM,2,2) == "99"  // Somente considerar estorno
					aCusto := If(aCusto==Nil,PegaCusD3(),aCusto)
					cSinal := If(SD3->D3_TM <= "500", "+", "-")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza os valores da Tarefa                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					AF9AtuComD3(aCusto)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza os empenhos do Projeto                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PmsBxEmp((cAlias)->AFI_PROJET,(cAlias)->AFI_TAREFA,SD3->D3_COD,SD3->D3_LOCAL,SD3->D3_QUANT,cSinal,SD3->D3_QTSEGUM,SD3->D3_TRT)

					nQtd := AFI->AFI_QUANT

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Integração com TOP, exclui apropriacao para o projeto.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !(IsIntegTop())
						IF (GetNewPar("MV_RMCOLIG",0) >0) .And. IntePms()
							cQuery:= "SELECT AFH_ITEMSA FROM "+ RetSQLName("AFH")
							cQuery+=" WHERE AFH_FILIAL = '"+xFilial("AFH")+"' AND AFH_PROJET='"+(cAlias)->AFI_PROJET+"'"
							cQuery+=" AND AFH_REVISA ='0001' AND AFH_TAREFA='"+(cAlias)->AFI_TAREFA+"'"
							cQuery+=" AND AFH_NUMSA='"+SCP->CP_NUM+"' AND AFH_COD='"+(cAlias)->AFI_COD+"' AND D_E_L_E_T_ =' '"
							cQuery := ChangeQuery(cQuery)
							cAreaTMP:=GetNextAlias()
							If Select(cAreaTMP)>0
								(cAreaTMP)->(dbCloseArea())
							EndIf
							dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAreaTMP, .T., .T.)
							If (cAreaTMP)->(!EOF())
								If !SlmAtuMov((cAlias)->AFI_PROJET, (cAlias)->AFI_TAREFA, SCP->CP_NUM ,(cAreaTMP)->AFH_ITEMSA,((SD3->D3_QUANT)*-1) ,SD3->D3_CUSTO1,"SA", nEvento)
								SLMPMSCOST(2, "AFI")
								EndIf
							Endif
							(cAreaTMP)->(dbCloseArea())
						Endif
					Endif
				EndIf
				SD3->(dbSkip())
			End
		EndIf

		cFilAnt := cFilOldSD3

	Case nEvento == 3

		SD3->(dbSetOrder(7))
		If SD3->(MsSeek(xFilial("SD3")+cChvSD3))
			RecLock("SD3",.F.)
			SD3->D3_PROJPMS := ""
			SD3->D3_TASKPMS := ""
			MsUnlock()
		EndIf

		RecLock("AFI",.F.,.T.)
		dbDelete()
		MsUnlock()
EndCase


RestArea(aAreaSD3)
RestArea(aAreaAFI)
RestArea(aArea)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAvalAFL³ Autor ³ Edson Maricate        ³ Data ³ 14-08-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de avaliacao da amaracao com os contratos              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela de amarracao                           ³±±
±±³          ³ExpN2: Codigo do Evento                                       ³±±
±±³          ³       [1] Implantacao de uma amarracao                       ³±±
±±³          ³       [2] Estorno de um amarracao                            ³±±
±±³          ³       [3] Exclusao de uma amarracao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAvalAFL(cAlias,nEvento)
Local aArea		:= GetArea()
Local aAreaAFL	:= AFL->(GetArea())
Local aAreaSC3	:= SC3->(GetArea())

Do Case
	Case nEvento == 1
		//		SC3->(dbSetOrder(1))
		//		If SC3->(MsSeek(xFilial()+(cAlias)->AFL_NUMCP+(cAlias)->AFL_ITEMCP))
		//		EndIf
	Case nEvento == 2
		//		SC3->(dbSetOrder(1))
		//		If SC3->(MsSeek(xFilial()+(cAlias)->AFL_NUMCP+(cAlias)->AFL_ITEMCP))
		//		EndIf
	Case nEvento == 3
		RecLock("AFL",.F.,.T.)
		dbDelete()
		MsUnlock()
EndCase
RestArea(aAreaSC3)
RestArea(aAreaAFL)
RestArea(aArea)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAvalAFM³ Autor ³ Edson Maricate        ³ Data ³ 14-08-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de avaliacao da amaracao com as OPs                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela de amarracao                           ³±±
±±³          ³ExpN2: Codigo do Evento                                       ³±±
±±³          ³       [1] Implantacao de uma amarracao                       ³±±
±±³          ³       [2] Estorno de um amarracao                            ³±±
±±³          ³       [3] Exclusao de uma amarracao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAvalAFM(cAlias,nEvento,cPlaneja)
Local aArea		:= GetArea()
Local aAreaAFM	:= AFM->(GetArea())
Local aAreaSC2	:= SC2->(GetArea())
Local cTRT		:= ""
Local lGetEmp   := SuperGetMV("MV_PMSOPSC",,"1") == "1"
Default cPlaneja := ""

Do Case
	Case nEvento == 1
		SC2->(dbSetOrder(1))
		If SC2->(MsSeek(PmsFilial("SC2","AFM")+(cAlias)->AFM_NUMOP+(cAlias)->AFM_ITEMOP+(cAlias)->AFM_SEQOP))
			cTRT := (cAlias)->AFM_TRT
			PmsAtuEmp((cAlias)->AFM_PROJET,(cAlias)->AFM_TAREFA,SC2->C2_PRODUTO,SC2->C2_LOCAL,(cAlias)->AFM_QUANT,"+",.T.,(cAlias)->AFM_QTSEGU,@cTRT,SC2->C2_DATPRF,"2",cPlaneja,SC2->C2_TPOP=="P")
			RecLock("AFM",.F.)
			AFM->AFM_TRT := cTRT
			MsUnlock()
		EndIf
	Case nEvento == 2
		SC2->(dbSetOrder(1))
		If lGetEmp  //parametro que verifica se apaga ou nao os empenhos da OP deletada
			If SC2->(MsSeek(PmsFilial("SC2","AFM")+(cAlias)->AFM_NUMOP+(cAlias)->AFM_ITEMOP+(cAlias)->AFM_SEQOP))
				PmsAtuEmp((cAlias)->AFM_PROJET,(cAlias)->AFM_TAREFA,SC2->C2_PRODUTO,SC2->C2_LOCAL,(cAlias)->AFM_QUANT,"-",.T.,(cAlias)->AFM_QTSEGU,(cAlias)->AFM_TRT,SC2->C2_DATPRF,"2",,SC2->C2_TPOP=="P")
			EndIf

		Else

			dbSelectArea("AFJ")
			dbSetOrder(3)
			If MsSeek(xFilial("AFJ")+(cAlias)->AFM_PROJET+(cAlias)->AFM_TAREFA+(cAlias)->AFM_TRT)
				// Caso a OP tenha sido gerada por um planejamento e o parametro estiver ativo
				// o empenho deverá permanecer, caso contrario, sera um empenho pontual do prj
				// e conceitualmente nao ha necessidade de manter o seu empenho
				If EMPTY(AFJ->AFJ_PLANEJ)
					If SC2->(MsSeek(PmsFilial("SC2","AFM")+(cAlias)->AFM_NUMOP+(cAlias)->AFM_ITEMOP+(cAlias)->AFM_SEQOP))
						PmsAtuEmp((cAlias)->AFM_PROJET,(cAlias)->AFM_TAREFA,SC2->C2_PRODUTO,SC2->C2_LOCAL,(cAlias)->AFM_QUANT,"-",.T.,(cAlias)->AFM_QTSEGU,(cAlias)->AFM_TRT,SC2->C2_DATPRF,"2",,SC2->C2_TPOP=="P")
					EndIf
				ENDIF
			EndIf

		EndIf

	Case nEvento == 3
		RecLock("AFM",.F.,.T.)
		dbDelete()
		MsUnlock()
EndCase

RestArea(aAreaSC2)
RestArea(aAreaAFM)
RestArea(aArea)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAvalAFN³ Autor ³ Edson Maricate        ³ Data ³ 14-08-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de avaliacao da amaracao com as NFsEntrada             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela de amarracao                           ³±±
±±³          ³ExpN2: Codigo do Evento                                       ³±±
±±³          ³       [1] Implantacao de uma amarracao                       ³±±
±±³          ³       [2] Estorno de um amarracao                            ³±±
±±³          ³       [3] Exclusao de uma amarracao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAvalAFN(cAlias,nEvento,lGeraSD3 ,aCusto)
Local aArea      := GetArea()
Local aAreaAFN   := AFN->(GetArea())
Local aAreaSF4   := SF4->(GetArea())
Local aAreaSD1   := SD1->(GetArea())
Local cFilSD1    := ""
Local cFilOldSD1 := ""
Local cLocalDest := ""
Local nQtd       := 0
Local lContinua  := .T.
Local lNFFreImp		:= .F.
Local lApropAll	:=  SuperGetMV("MV_ITAPALL",,.F.)
Local lContAprop	:= Nil
Local lVldPrdMO	:= SuperGetMV("MV_ITVLDPR",,.F.) .And. IsIntegTop(,.T.)
Local cTpProd		:= ""
Local cTes			:= ""
Local lNFSA		:= .F.

DEFAULT lGeraSD3	:= .T.
DEFAULT aCusto      := {}

//Incluido por Bruno D. Borges
//13/11/2008
//BOPS: Yokogawa - Nao movimentar custos quando campo AFN_ESTOQU estiver com 2 = Nao incide Custo
If (cAlias)->AFN_ESTOQU == "2"
	lGeraSD3 := .F.
EndIf

//Se parametro estiver habilitado e for integração TOP x Protheus, valida o tipo do produto MO (Produto serviço),
//diferente de MO (produto material).
//Se for produto MO (Sera apropriado), caso contrario não sera apropriado.
If lVldPrdMO
	//Verifica o tipo do produto
	cTpProd := AllTrim(Posicione("SB1",1,xFilial("SB1") + Padr(AFN->AFN_COD,TamSx3("AFN_COD")[1]),"B1_TIPO"))
	
	If cTpProd == "MO"
		lGeraSD3 := .T.
	Else
		lGeraSD3 := .F.
	Endif
Endif

// Se for nota de frete, não deve atualizar estoque
If AllTrim(FUNNAME()) $ "MATA116|MATA119"
	lNFFreImp := .T.
Endif

Do Case
	Case nEvento == 1

		cFilSD1 	:= PmsFilial("SD1","AFN")
		cFilOldSD1  := cFilAnt
		If cFilSD1 <> ""
			cFilAnt := cFilSD1
		EndIf

		SD1->(dbSetOrder(1))
		If SD1->(MsSeek(xFilial()+(cAlias)->AFN_DOC+(cAlias)->AFN_SERIE+(cAlias)->AFN_FORNECE+(cAlias)->AFN_LOJA+(cAlias)->AFN_COD+(cAlias)->AFN_ITEM))
			SF4->(dbSetOrder(1))

			lContAprop := .F.
			If lApropAll
				lContAprop := .T.
			Else
				If !Empty(SD1->D1_TES)
					cTes := SD1->D1_TES
				Else
					cTes := aCols[n,GdFieldPos("D1_TES")]
				EndIf
			
				// Efetua a apropriacao da quantidade e o custo,
				If lGeraSD3 
					lContAprop := .F.
					
					If SF4->(MsSeek(xFilial("SF4")+cTes))
						If lNFFreImp .AND. SF4->F4_ESTOQUE == "S" // NF de frete ou complemente de importação, somente apropriam o custo
								lContAprop := .T.
						Else
							// Efetua a apropriacao a quantidade e o  custo pelo documento de entrada gerado movimentacao interna(SD3)
							If SF4->F4_ESTOQUE == "S"
								lContAprop := .T.
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			lGeraSD3 := Iif (lApropAll,.F.,lGeraSD3)

			If lContAprop
				// Se nao foi informado no. de lote, assume da tabela SD1
				If Empty(SD1->D1_NUMCQ) .Or. !ExisteSX2('AFO')
					cLocalDest := SD1->D1_LOCAL
					// caso contrario, deve procurar a movimentantacao da qualidade referente
					// ao produto e se o produto foi liberado.
					nQtd := AFN->AFN_QUANT
				Else
					//O SD7 deve estar posicionado
					cLocalDest := SD7->D7_LOCDEST
					AFO->(dbSetOrder(1))
					AFO->(MsSeek(xFilial()+SD7->D7_NUMERO+SD7->D7_SEQ+(cAlias)->AFN_PROJET+(cAlias)->AFN_REVISA+(cAlias)->AFN_TAREFA ))
					nQtd := AFO->AFO_QUANT
				Endif

				//Verifica se tem SA associada, caso tenha não gera SD3, pois a movimentação deve ser gerada pela baixa da SA.
				If cPaisLoc == "BRA"
					If !Empty(SD1->D1_PEDIDO) .And. !Empty(SD1->D1_ITEMPC)
						lNFSA := PMSNFSA(SD1->D1_PEDIDO,SD1->D1_ITEMPC)[1]		
						If lNFSA 
							lGeraSD3 := .F.
						Endif
					Endif
				Else
					If AllTrim(SD1->D1_TIPODOC) == "10" //Factura
						If !Empty(SD1->D1_REMITO)
							lGeraSD3 := .F.
						ElseIf !Empty(SD1->D1_PEDIDO) .And. !Empty(SD1->D1_ITEMPC)
							lNFSA := PMSNFSA(SD1->D1_PEDIDO,SD1->D1_ITEMPC)[1]
							If lNFSA 
								lGeraSD3 := .F.
							Endif
						Endif
					Elseif AllTrim(SD1->D1_TIPODOC) == "60" //Remito
						If !Empty(SD1->D1_PEDIDO) .And. !Empty(SD1->D1_ITEMPC)
							lNFSA := PMSNFSA(SD1->D1_PEDIDO,SD1->D1_ITEMPC)[1]
							If lNFSA 
								lGeraSD3 := .F.
							Endif
						Endif
					Endif
				EndIf

				If lGeraSD3 .AND. !Empty(cLocalDest) .AND. lContinua
				
					nQtd := Iif(lNFFreImp,0,nQtd)
				
					If !lNFFreImp // Notas de frete ou complemento de importação não atualizam empenhos de projeto
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Efetua a baixa dos empenhos do Projeto               ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						PmsBxEmp((cAlias)->AFN_PROJET,(cAlias)->AFN_TAREFA,SD1->D1_COD,SD1->D1_LOCAL,(cAlias)->AFN_QUANT,"-",(cAlias)->AFN_QTSEGU,(cAlias)->AFN_TRT)
					EndIf
					
					dbSelectArea("SD3")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Gera requisicao automatica RE5           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					RecLock("SD3",.T.)
					SD3->D3_FILIAL  := xFilial("SD3")
					SD3->D3_COD     := SD1->D1_COD
					SD3->D3_QUANT   := nQtd
					SD3->D3_TM      := "999"
					SD3->D3_LOCAL   := cLocalDest
					SD3->D3_DOC     := SD1->D1_DOC
					SD3->D3_EMISSAO := SD1->D1_DTDIGIT
					SD3->D3_NUMSEQ  := SD1->D1_NUMSEQ
					SD3->D3_UM      := SD1->D1_UM
					SD3->D3_GRUPO   := SD1->D1_GRUPO
					SD3->D3_TIPO    := SD1->D1_TP
					SD3->D3_SEGUM   := SD1->D1_SEGUM
					SD3->D3_CONTA   := SD1->D1_CONTA
					SD3->D3_CC      := SD1->D1_CC
					SD3->D3_ITEMCTA := SD1->D1_ITEMCTA
					SD3->D3_CLVL    := SD1->D1_CLVL
					SD3->D3_CF      := "RE5"
					SD3->D3_QTSEGUM := ConvUm(SD1->D1_COD,nQtd)
					SD3->D3_USUARIO := cUsername
					If len(aCusto) > 0
						SD3->D3_CUSTO1 := aCusto[1]
						SD3->D3_CUSTO2 := aCusto[2]
						SD3->D3_CUSTO3 := aCusto[3]
						SD3->D3_CUSTO4 := aCusto[4]
						SD3->D3_CUSTO5 := aCusto[5]
					Else
						SD3->D3_CUSTO1 := SD1->D1_CUSTO *(nQtd/SD1->D1_QUANT)
						SD3->D3_CUSTO2 := SD1->D1_CUSTO2*(nQtd/SD1->D1_QUANT)
						SD3->D3_CUSTO3 := SD1->D1_CUSTO3*(nQtd/SD1->D1_QUANT)
						SD3->D3_CUSTO4 := SD1->D1_CUSTO4*(nQtd/SD1->D1_QUANT)
						SD3->D3_CUSTO5 := SD1->D1_CUSTO5*(nQtd/SD1->D1_QUANT)
					EndIf
					SD3->D3_NUMLOTE   := SD1->D1_NUMLOTE
					SD3->D3_LOTECTL   := SD1->D1_LOTECTL
					SD3->D3_DTVALID   := SD1->D1_DTVALID
					SD3->D3_PROJPMS   := AFN->AFN_PROJET
					SD3->D3_TASKPMS   := AFN->AFN_TAREFA

					MsUnlock()
					B2AtuComD3({SD3->D3_CUSTO1,SD3->D3_CUSTO2,SD3->D3_CUSTO3,SD3->D3_CUSTO4,SD3->D3_CUSTO5})
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza os valores da Tarefa                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					AF9AtuComD3({SD3->D3_CUSTO1,SD3->D3_CUSTO2,SD3->D3_CUSTO3,SD3->D3_CUSTO4,SD3->D3_CUSTO5})

					/////////////////////////////////////////////////////////////////
					//
					// Integração com TOP, faz a baixa da apropriação gerada pelo TOP quando for uma solicitação de compra gerada pelo planejamento.
					// Caso contrario, é uma apropriacao manual
					//
					If !lNFSA .And. !SlmAtuMov((cAlias)->AFN_PROJET, (cAlias)->AFN_TAREFA, SD1->D1_PEDIDO ,SD1->D1_ITEMPC ,nQtd ,SD3->D3_CUSTO1)
						/////////////////////////////////////////////////////////////////
						//
						// Integração com RM Corpore TOP, gera a apropriacao para o projeto.
						//
						/////////////////////////////////////////////////////////////////
						SLMPMSCOST(0, "AFN", dDatabase, (cAlias)->AFN_PROJET, (cAlias)->AFN_TAREFA, SD1->D1_COD, nQtd, SD3->D3_CUSTO1)
						/////////////////////////////////////////////////////////////////
					EndIf
				Else
					If lApropAll
						If !lNFSA .And. !SlmAtuMov((cAlias)->AFN_PROJET, (cAlias)->AFN_TAREFA, SD1->D1_PEDIDO ,SD1->D1_ITEMPC ,nQtd ,Iif(Len(aCusto)>0,aCusto[1],SD1->D1_CUSTO *(nQtd/SD1->D1_QUANT)))
							// Integração com RM Corpore TOP, gera a apropriacao para o projeto.
							SLMPMSCOST(0, "AFN", dDatabase, (cAlias)->AFN_PROJET, (cAlias)->AFN_TAREFA, SD1->D1_COD, nQtd, Iif(Len(aCusto)>0,aCusto[1],SD1->D1_CUSTO *(nQtd/SD1->D1_QUANT)))
						EndIf
					Endif
				EndIf
			EndIf
		EndIf

		cFilAnt := cFilOldSD1

	Case nEvento == 2 // estorno de NF com projeto e tarefa

		cFilSD1 	:= PmsFilial("SD1","AFN")
		cFilOldSD1  := cFilAnt
		If cFilSD1 <> ""
			cFilAnt := cFilSD1
		EndIf
		SD1->(dbSetOrder(1))
		If SD1->(MsSeek(xFilial("SD1")+(cAlias)->AFN_DOC+(cAlias)->AFN_SERIE+(cAlias)->AFN_FORNECE+(cAlias)->AFN_LOJA+(cAlias)->AFN_COD+(cAlias)->AFN_ITEM))
			SF4->(dbSetOrder(1))

			lContAprop := .T. //Por se tratar de estorno, independente se ouve ou não inclusão deve ser verificado se existe registro de movimentação na SD3 em relação a SD1
			lGeraSD3		:= Iif (lApropAll,.F.,lGeraSD3)
			
			//Verifica se tem SA associada, caso tenha não gera SD3, pois a movimentação deve ser gerada pela baixa da SA.
			If cPaisLoc == "BRA"
				If !Empty(SD1->D1_PEDIDO) .And. !Empty(SD1->D1_ITEMPC)
					lNFSA := PMSNFSA(SD1->D1_PEDIDO,SD1->D1_ITEMPC)[1]		
					If lNFSA 
						lContAprop := .F.
					Endif
				Endif
			Else
				If AllTrim(SD1->D1_TIPODOC) == "10" //Factura
					If !Empty(SD1->D1_REMITO)
						lContAprop := .F.
					ElseIf !Empty(SD1->D1_PEDIDO) .And. !Empty(SD1->D1_ITEMPC)
						lNFSA := PMSNFSA(SD1->D1_PEDIDO,SD1->D1_ITEMPC)[1]
						If lNFSA 
							lContAprop := .F.
						Endif
					Endif
				Elseif AllTrim(SD1->D1_TIPODOC) == "60" //Remito
					If !Empty(SD1->D1_PEDIDO) .And. !Empty(SD1->D1_ITEMPC)
						lNFSA := PMSNFSA(SD1->D1_PEDIDO,SD1->D1_ITEMPC)[1]
						If lNFSA 
							lContAprop := .F.
						Endif
					Endif
				Endif
			Endif

			If lContAprop
				If lGeraSD3
					// Se nao foi informado no. de lote, assume da tabela SD1
					If Empty(SD1->D1_NUMCQ)
						cLocalDest := SD1->D1_LOCAL
						// caso contrario, deve procurar a movimentantacao da qualidade referente
						// ao produto e se o produtofoi liberado.
						nQtd := AFN->AFN_QUANT
					Else
						//O SD7 deve estar posicionado
						cLocalDest := SD7->D7_LOCDEST
						AFO->(dbSetOrder(1))
						AFO->(MsSeek(xFilial()+SD7->D7_NUMERO+SD7->D7_SEQ+(cAlias)->AFN_PROJET+(cAlias)->AFN_REVISA+(cAlias)->AFN_TAREFA ))
						nQtd := AFO->AFO_QUANT
					Endif
					
					If !lNFFreImp // Notas de frete ou complemento de importação não atualizam empenhos de projeto
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza os empenhos do Projeto                      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						PmsBxEmp((cAlias)->AFN_PROJET,(cAlias)->AFN_TAREFA,SD1->D1_COD,SD1->D1_LOCAL,(cAlias)->AFN_QUANT,"+",(cAlias)->AFN_QTSEGU,(cAlias)->AFN_TRT)
					EndIf
					
					nQtd := Iif(lNFFreImp,0,nQtd)
					
					dbSelectArea("SD3")
					dbSetOrder(4)
					MsSeek(xFilial()+SD1->D1_NUMSEQ)
					While !Eof() .And. SD3->D3_CF # "RE5" .And. SD3->D3_NUMSEQ == SD1->D1_NUMSEQ
						dbSkip()
					End
					lEofSD3 := IIF(SD3->D3_NUMSEQ # SD1->D1_NUMSEQ,.t.,.f.)
					If !lEofSD3
						aCustSD3 := {0,0,0,0,0}
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Estorna os itens RE5                     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("SD3")
						dbSetOrder(4)
						MsSeek(xFilial()+SD1->D1_NUMSEQ)
						While !Eof() .And. !(SD3->D3_CF # "RE5") .And. SD3->D3_NUMSEQ == SD1->D1_NUMSEQ
							// totaliza o custo das movimentacao para o estorno dos mesmos
							aCustSD3[1] += SD3->D3_CUSTO1
							aCustSD3[2] += SD3->D3_CUSTO2
							aCustSD3[3] += SD3->D3_CUSTO3
							aCustSD3[4] += SD3->D3_CUSTO4
							aCustSD3[5] += SD3->D3_CUSTO5
							
							RecLock("SD3",.F.)
							Replace  D3_ESTORNO With "S"
							MsUnlock()
							dbSkip()
						End
						RecLock("SD3",.T.)
						Replace D3_FILIAL  With xFilial()
						Replace D3_COD     With SD1->D1_COD
						Replace D3_QUANT   With nQtd
						Replace D3_TM      With "499"
						Replace D3_LOCAL   With SD1->D1_LOCAL
						Replace D3_DOC     With SD1->D1_DOC
						Replace D3_EMISSAO With SD1->D1_DTDIGIT
						Replace D3_NUMSEQ  With SD1->D1_NUMSEQ
						Replace D3_UM      With SD1->D1_UM
						Replace D3_GRUPO   With SD1->D1_GRUPO
						Replace D3_TIPO    With SD1->D1_TP
						Replace D3_SEGUM   With SD1->D1_SEGUM
						Replace D3_CONTA   With SD1->D1_CONTA
						Replace D3_CC      With SD1->D1_CC
						Replace D3_ITEMCTA With SD1->D1_ITEMCTA
						Replace D3_CLVL    With SD1->D1_CLVL
						Replace D3_CF      With "DE5"
						Replace D3_QTSEGUM With ConvUm(SD1->D1_COD,nQtd)
						Replace D3_USUARIO With cUsername
						If lNFFreImp
							Replace D3_CUSTO1  With aCustSD3[1]
							Replace D3_CUSTO2  With aCustSD3[2]
							Replace D3_CUSTO3  With aCustSD3[3]
							Replace D3_CUSTO4  With aCustSD3[4]
							Replace D3_CUSTO5  With aCustSD3[5]
						Else
							Replace D3_CUSTO1  With SD1->D1_CUSTO* (nQtd/SD1->D1_QUANT)
							Replace D3_CUSTO2  With SD1->D1_CUSTO2*(nQtd/SD1->D1_QUANT)
							Replace D3_CUSTO3  With SD1->D1_CUSTO3*(nQtd/SD1->D1_QUANT)
							Replace D3_CUSTO4  With SD1->D1_CUSTO4*(nQtd/SD1->D1_QUANT)
							Replace D3_CUSTO5  With SD1->D1_CUSTO5*(nQtd/SD1->D1_QUANT)
						EndIf
						Replace D3_ESTORNO With "S"
						Replace D3_PROJPMS With (cAlias)->AFN_PROJET
						Replace D3_TASKPMS With (cAlias)->AFN_TAREFA
						MsUnlock()
						B2AtuComD3({SD3->D3_CUSTO1,SD3->D3_CUSTO2,SD3->D3_CUSTO3,SD3->D3_CUSTO4,SD3->D3_CUSTO5})
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza os valores da Tarefa                        ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						AF9AtuComD3({SD3->D3_CUSTO1,SD3->D3_CUSTO2,SD3->D3_CUSTO3,SD3->D3_CUSTO4,SD3->D3_CUSTO5})
					EndIf

					/////////////////////////////////////////////////////////////////
					//
					// Integração com TOP, faz o estorno da apropriação gerada pelo TOP quando for uma solicitação de compra gerada pelo planejamento.
					// Caso contrario, é uma apropriacao manual
					//
					If !lNFSA .And. lGeraSD3 .And. !SlmAtuMov((cAlias)->AFN_PROJET, (cAlias)->AFN_TAREFA, SD1->D1_PEDIDO ,SD1->D1_ITEMPC ,(nQtd*-1) ,SD1->D1_CUSTO*(nQtd/SD1->D1_QUANT))
						/////////////////////////////////////////////////////////////////
						//
						// Integração com TOP, exclui apropriacao para o projeto.
						//
						/////////////////////////////////////////////////////////////////
						SLMPMSCOST(2, "AFN")
						/////////////////////////////////////////////////////////////////
					EndIf
				Else
					If !lNFFreImp // Notas de frete ou complemento de importação não atualizam empenhos de projeto
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza os empenhos do Projeto                      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						PmsBxEmp((cAlias)->AFN_PROJET,(cAlias)->AFN_TAREFA,SD1->D1_COD,SD1->D1_LOCAL,(cAlias)->AFN_QUANT,"+",(cAlias)->AFN_QTSEGU,(cAlias)->AFN_TRT)
					EndIf
					dbSelectArea("SD3")
					dbSetOrder(4)
					MsSeek(xFilial()+SD1->D1_NUMSEQ)
					While !Eof() .And. SD3->D3_CF # "RE5" .And. SD3->D3_NUMSEQ == SD1->D1_NUMSEQ
						dbSkip()
					End
					lEofSD3 := IIF(SD3->D3_NUMSEQ # SD1->D1_NUMSEQ,.t.,.f.)
					If !lEofSD3
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Gera requisicao automatica  DE5          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RecLock("SD3",.F.)
						Replace D3_ESTORNO With " "
						Replace D3_PROJPMS With " "
						Replace D3_TASKPMS With " "
						MsUnlock()
					EndIf

					// Integração com TOP, faz o estorno da apropriação gerada pelo TOP quando for uma solicitação de compra gerada pelo planejamento.
					// Caso contrario, é uma apropriacao manual
					If !lNFSA .And. !SlmAtuMov((cAlias)->AFN_PROJET, (cAlias)->AFN_TAREFA, SD1->D1_PEDIDO ,SD1->D1_ITEMPC ,((cAlias)->AFN_QUANT*-1) ,SD1->D1_CUSTO*((cAlias)->AFN_QUANT/SD1->D1_QUANT))
						// Integração com TOP, exclui apropriacao para o projeto.
						SLMPMSCOST(2, "AFN")
					EndIf
				EndIf
			Endif
		EndIf

		cFilAnt := cFilOldSD1

	Case nEvento == 3 // exclusao de projeto/tarefa com NF
		RecLock("AFN",.F.,.T.)
		dbDelete()
		MsUnlock()
EndCase

RestArea(aAreaSF4)
RestArea(aAreaSD1)
RestArea(aAreaAFN)
RestArea(aArea)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSNFSA³ Autor ³ Rodrigo M Pontes         ³ Data ³ 24-08-2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Verifica se item da NF vinculado ao pedido, é originado por   ³±±
±±³          ³uma solicitação de armazem                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Numero do Pedido                                       ³±±
±±³          ³ExpC2: Item do pedido                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³{lRet,cNumSA}                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMSNFSA(cPedido,cItemPC)

Local lRet 		:= .F.
Local cNumSA	:= ""
Local cItemSA	:= ""
Local cFilSC1	:= xFilial("SC1")
Local cFilSC7	:= xFilial("SC7")
Local lIntTop	:= .F.
Local aArea		:= GetArea()
Local aAreaSC7	:= SC7->(GetArea())
Local aAreaSC1	:= SC1->(GetArea())
Local aAreaSCP	:= SCP->(GetArea())
Local aRetorno	:= {}

DbSelectArea("SC7")
SC7->(DbSetOrder(1))
If SC7->(DbSeek(cFilSC7 + cPedido + cItemPC))
	
	DbSelectArea("SC1")
	SC1->(DbSetOrder(1))
	If SC1->(DbSeek(cFilSC1 + SC7->C7_NUMSC + SC7->C7_ITEMSC))
		aRetorno:= COMPosDHN({3,{'1',cFilSC1,SC1->C1_NUM,SC1->C1_ITEM}})
		If (aRetorno[1])
			While !(aRetorno[2])->(Eof())
				If (aRetorno[2])->DHN_DOCDES + (aRetorno[2])->DHN_ITDES == SC7->C7_NUMSC + SC7->C7_ITEMSC
					lRet	:= .T.
					cNumSA	:= (aRetorno[2])->DHN_DOCORI
					cItemSA	:= (aRetorno[2])->DHN_ITORI
					cNumSA		:= SCP->CP_NUM
					cItemSA	:= SCP->CP_ITEM
					lIntTop	:= PMSNFSATOP(cNumSA,cItemSA)
					Exit
				EndIf
				(aRetorno[2])->(dbSkip())
			EndDo
			(aRetorno[2])->(DbCloseArea())
		EndIf
	EndIf
EndIf

RestArea(aAreaSCP)
RestArea(aAreaSC1)
RestArea(aAreaSC7)
RestArea(aArea)

Return {lRet,cNumSA,cItemSA,lIntTop}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSNFSATOP³ Autor ³ Rodrigo M Pontes      ³ Data ³ 24-08-2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Verifica se a solicitação de armazem é originada pela         ³±±
±±³          ³integração top x protheus                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Numero da solicitação                                  ³±±
±±³          ³ExpC2: Item da solicitação                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³{lRet,cNumSA}                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMSNFSATOP(cNumSA,cItemSA)

Local lRet	:= .F.
Local cQry	:= ""

If Select("SAINTNF") > 0
	SAINTNF->(DbCloseArea())
Endif
	
cQry := " SELECT AFH_VIAINT"
cQry += " FROM " + RetSqlName("AFH")
cQry += " WHERE  D_E_L_E_T_ = ' '"
cQry += "        AND AFH_NUMSA = '" + cNumSA + "'"
cQry += "        AND AFH_ITEMSA = '" + cItemSA + "'"
cQry += " GROUP BY AFH_VIAINT"

cQry := ChangeQuery(cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"SAINTNF")

DbSelectArea("SAINTNF")
If SAINTNF->(!EOF())
	If SAINTNF->AFH_VIAINT == "S"
		lRet := .T.
	Endif
Endif

SAINTNF->(DbCloseArea())
	
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSConvCus³ Autor ³ Edson Maricate        ³ Data ³ 14-08-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de conversao de moeda do custo previsto nas tarefas.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Custo a ser convertido                                 ³±±
±±³          ³ExpN2: Moeda do Custo a ser convertido                        ³±±
±±³          ³ExpC3: Tipo de Taxa                                           ³±±
±±³          ³ExpD4: Data fixa para conversao                               ³±±
±±³          ³ExpD5: Data inicial da tarefa                                 ³±±
±±³          ³ExpD6: Data final da tarefa                                   ³±±
±±³          ³ExpA7: Array de retorno do Custo ( Opcional )                 ³±±
±±³          ³ExpA8: Array das Taxas de Conversao Informadas pelo Usuario   ³±±
±±³          ³ExpA9: Trunca (1) Arredonda (2)							    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³{CustoM1,CustoM2,CustoM3,CustoM4,CustoM5}                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsConvCus(nCusto,nMoeda,cCnvPRV,dDtConv,dStart,dFinish,aCusto,aTX2,cTrunca,nQuantTrf)

Local nx
Local dAuxConv
Local nFaz		:= 0
Local aDecCst	:= {0,0,0,0,0}
Local aAuxCusto	:= {0,0,0,0,0}
DEFAULT aCusto	:= {0,0,0,0,0}

aDecCst[1]:=TamSX3("AF9_CUSTO")[2]
aDecCst[2]:=TamSX3("AF9_CUSTO2")[2]
aDecCst[3]:=TamSX3("AF9_CUSTO3")[2]
aDecCst[4]:=TamSX3("AF9_CUSTO4")[2]
aDecCst[5]:=TamSX3("AF9_CUSTO5")[2]

If nMoeda<=0
	Return aCusto
EndIf

For nFaz:=1 to 5
	Do Case
		Case cCnvPrv == "2" // Data Fixa
			//If nCusto > 0
				aCusto[nFaz]	+= PmsTrunca(cTrunca,xMoeda(nCusto,nMoeda,nFaz,dDtConv,aDecCst[nFaz]),aDecCst[nFaz],nQuantTrf)
			//EndIf
		Case cCnvPrv == "3" // Taxa Media ( 3 Valores )
			//If nCusto > 0
				if nFaz==1
					dAuxConv := dStart
					For nx := 1 to 3
						aAuxCusto[1]	+= xMoeda(nCusto,nMoeda,1,dAuxConv,aDecCst[1])
						aAuxCusto[2]	+= xMoeda(nCusto,nMoeda,2,dAuxConv,aDecCst[2])
						aAuxCusto[3]	+= xMoeda(nCusto,nMoeda,3,dAuxConv,aDecCst[3])
						aAuxCusto[4]	+= xMoeda(nCusto,nMoeda,4,dAuxConv,aDecCst[4])
						aAuxCusto[5]	+= xMoeda(nCusto,nMoeda,5,dAuxConv,aDecCst[5])
						dAuxConv 	+= (dFinish-dStart)/3
					Next nx
				endif
				aCusto[nFaz]	+= PmsTrunca(cTrunca,aAuxCusto[nFaz]/3,aDecCst[nFaz],nQuantTrf)
			//EndIf
		Case cCnvPrv == "4" // Taxa Media ( 15 Valores )
			//If nCusto > 0
				if nFaz==1
					dAuxConv := dStart
					For nx := 1 to 15
						aAuxCusto[1]	+= xMoeda(nCusto,nMoeda,1,dAuxConv,aDecCst[1])
						aAuxCusto[2]	+= xMoeda(nCusto,nMoeda,2,dAuxConv,aDecCst[2])
						aAuxCusto[3]	+= xMoeda(nCusto,nMoeda,3,dAuxConv,aDecCst[3])
						aAuxCusto[4]	+= xMoeda(nCusto,nMoeda,4,dAuxConv,aDecCst[4])
						aAuxCusto[5]	+= xMoeda(nCusto,nMoeda,5,dAuxConv,aDecCst[5])
						dAuxConv 	+= (dFinish-dStart)/15
					Next nx
				endif
				aCusto[nFaz]	+= PmsTrunca(cTrunca,aAuxCusto[nFaz]/15,aDecCst[nFaz],nQuantTrf)
			//EndIf
		Case cCnvPrv == "5" // Data Inicial
			//If nCusto > 0
				aCusto[nFaz]	+= PmsTrunca(cTrunca,xMoeda(nCusto,nMoeda,nFaz,dStart,aDecCst[nFaz]),aDecCst[nFaz],nQuantTrf)
			//EndIf
		Case cCnvPrv == "6" // Data Final
			//If nCusto > 0
				aCusto[nFaz]	+= PmsTrunca(cTrunca,xMoeda(nCusto,nMoeda,nFaz,dFinish,aDecCst[nFaz]),aDecCst[nFaz],nQuantTrf)
			//EndIf
		Case cCnvPrv == "7" // Usuario Informa
			If aTX2[nFaz] == 0
				aCusto[nFaz]	+= 0
			Else
				aCusto[nFaz]	+= PmsTrunca(cTrunca,xMoeda(nCusto,nMoeda,nFaz,,aDecCst[nFaz],aTX2[nMoeda],aTX2[nFaz]),aDecCst[nFaz],nQuantTrf)
			EndIf

		OtherWise	// Data Base
			//If nCusto > 0
				aCusto[nFaz]	+= PmsTrunca(cTrunca,xMoeda(nCusto,nMoeda,nFaz,,aDecCst[nFaz]),aDecCst[nFaz],nQuantTrf)
			//EndIf
	EndCase
Next nFaz

Return aCusto


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsPrxEmp³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de geração da sequencia de empenho do projeto.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsPrxEmp(cProjeto,ForadeUso,cTarefa)
Local aArea		:= GetArea()
Local cPrxEmp	:= ""

DEFAULT cProjeto := ""
DEFAULT cTarefa  := ""

cProjeto := PadR(AllTrim(cProjeto),TamSX3("AFJ_PROJET")[1])
cTarefa  := PadR(AllTrim(cTarefa),TamSX3("AFJ_TAREFA")[1])
dbSelectArea("AFJ")
dbSetOrder(3)
MsSeek(xFilial("AFJ")+cProjeto+cTarefa+REPLICATE('Z',LEN(AFJ->AFJ_TRT)),.T.)
dbSkip(-1)
If xFilial()+cProjeto+cTarefa==AFJ_FILIAL+AFJ_PROJET+AFJ_TAREFA
	cPrxEmp := Soma1(AFJ_TRT)
Else
	cPrxEmp := "001"
EndIf

RestArea(aArea)
Return cPrxEmp

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsPlnEmp³ Autor ³ reynaldo Miyashita     ³ Data ³ 13-03-2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de retorna da sequencia atual de empenho do            ³±±
±±³          ³planejamento feito para o projeto.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsPlnEmp(cProjeto,cTarefa,cPlanej)
Local aArea		:= GetArea()
Local cSeqEmp	:= ""

dbSelectArea("AFJ")
dbSetOrder(1) // AFJ_FILIAL+AFJ_PROJET+AFJ_TAREFA+AFJ_COD+AFJ_LOCAL
MsSeek(xFilial()+cProjeto+cTarefa,.T.)
While !AFJ->(Eof()) .and. xFilial()+cProjeto+cTarefa==AFJ_FILIAL+AFJ_PROJET+AFJ_TAREFA
	If AFJ->AFJ_PLANEJ == cPlanej
		cSeqEmp := AFJ->AFJ_TRT
		Exit
	EndIf
	dbSkip()
EndDo

RestArea(aArea)
Return cSeqEmp

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsTrtAFG³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao da sequencia de empenho do projeto.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsTrtAFG()

Return Vazio().Or. ExistChav("AFJ",aCols[n,aScan(aHeader,{|x|AllTrim(x[2])=="AFG_PROJET"})]+aCols[n,aScan(aHeader,{|x|AllTrim(x[2])=="AFG_TAREFA"})]+M->AFG_TRT,3)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsTrtAFM³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao da sequencia de empenho do projeto.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsTrtAFM()

Return Vazio().Or. ExistChav("AFJ",aCols[n,aScan(aHeader,{|x|AllTrim(x[2])=="AFM_PROJET"})]+aCols[n,aScan(aHeader,{|x|AllTrim(x[2])=="AFM_TAREFA"})]+M->AFM_TRT,3)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsSelEmp³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de selecao a um empenho para baixa                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsSelEmp(cProjeto,cTarefa,aHeader,aCols,cProduto,cLocal,lEstorno)
Local oDlg
Local aArea		:= GetArea()
Local aViewEmp	:= {}
Local aRecEmp	:= {}
Local lOk		:= .F.
Local cReturn 	:= SPACE(LEN(AFJ->AFJ_TRT))

DEFAULT lEstorno := .F.
dbSelectArea('AFJ')
dbSetOrder(1)
MsSeek(xFilial()+cProjeto+cTarefa+cProduto+cLocal)
While !Eof().And.AFJ->AFJ_FILIAL+AFJ->AFJ_PROJET+AFJ->AFJ_TAREFA+AFJ->AFJ_COD+AFJ->AFJ_LOCAL==xFilial("AFJ")+cProjeto+cTarefa+cProduto+cLocal
	If (!lEstorno .AND. AFJ->AFJ_QEMP > (AFJ->AFJ_QATU+AFJ->AFJ_EMPEST)) .OR. (lEstorno .AND. (AFJ->AFJ_QATU+AFJ->AFJ_EMPEST)>0)
		aAdd(aViewEmp,{AFJ_TRT,AFJ_COD,AFJ_LOCAL,TransForm(AFJ_QEMP,PesqPict("AFJ","AFJ_QEMP")),TransForm(AFJ_QATU,PesqPict("AFJ","AFJ_QATU")),AFJ_DATA})
		aAdd(aRecEmp,AFJ->(RecNo()))
	EndIf
	dbSkip()
End
If !Empty(aViewEmp)
	DEFINE MSDIALOG oDlg FROM 85,35 to 330,610 TITLE cCadastro Of oMainWnd PIXEL
	oListBox := TWBrowse():New( 16,5,284,105,,{STR0076,STR0018,STR0077,STR0078,STR0079,STR0080},,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Seq.Empenho"###"Produto"###"Armazem"###"Qtd.Empenhada"###"Qtd.Atual"###"Dt.Necessidade"
	oListBox:Align := CONTROL_ALIGN_ALLCLIENT
	oListBox:SetArray(aViewEmp)
	oListBox:bLine := { || aViewEmp[oListBox:nAT]}
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk:=.T.,cReturn:=aViewEmp[oListBox:nAT,1],oDlg:End()},{||oDlg:End()},,{{"BMPINCLUIR",{|| MaViewEmp(aRecEmp[oListBox:nAT])},STR0081}} ) //"Detalhes"
Else
	HELP("  ",1,"PMSNOEMP")
EndIf


RestArea(aArea)
Return cReturn

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsTrtAFN³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao da sequencia de empenho do projeto.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsTrtAFN()

Return Vazio().Or. ExistCpo("AFJ",aCols[n,aScan(aHeader,{|x|AllTrim(x[2])=="AFN_PROJET"})]+aCols[n,aScan(aHeader,{|x|AllTrim(x[2])=="AFN_TAREFA"})]+M->AFN_TRT,3)

Function MaViewEmp(nRecAFJ)

AFJ->(dbGoto(nRecAFJ))
axVisual("AFJ",nRecAFJ,2)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MaConvCombo³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Converte a opcao selecionada do Combo.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MaConvCombo(xVariavel,aCombo,cCombo,aReferencia)

Local nPos	:= aScan(aCombo,cCombo)

If nPos > 0
	xVariavel	:= aReferencia[nPos]
EndIf

Return (nPos>0)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsNumAF5³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna proximo numero da EDT do Orcamento.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsNumAF5(cOrcamen,cNivelTrf,cEDTPai,cEDTAtual,lLiberaCod)
Local aArea		:= GetArea()
Local aAreaAF5	:= AF5->(GetArea())
Local aAreaAF1	:= AF1->(GetArea())
Local cEDT      := ""
Local lZZ		:= .F.
Local cLastEDT  := ""
Local cLastEDT2 := ""
Local cEDTAux   := ""
Local cTipo 	:= GetNewPar("MV_PMSECOD","1")
Local lTipCode  := GetNewPar("MV_PMSCODE",.F.)
Local cDelim    := ""
Local cMascara  := ""
Local aEDTAux   := {}
Local nI        := 0
Local nPos      := 0
Local nEDT      := 0
Local nDigitos  := 0
Local cOldNivelTrf := cNivelTrf
Local cEDTIni	 := ''
Local cNumero,cUltNum   := ""

DEFAULT lLiberaCod	:= .T.
DEFAULT cEDTAtual := ""

//
// Busca no orcamento a mascara e delimitador.
//
AF1->(dbSetOrder(1))
AF1->(MSSeek(xFilial("AF1")+cOrcamen))

cDelim    := AllTrim(AF1->AF1_DELIM)
cMascara  := AllTrim(AF1->AF1_MASCAR)

//
// caso nao tenha informado a mascara.
//
If Empty(cMascara)
	cMascara := "111111111111111111"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a codificacao e normal ou estruturada.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case Substr(cEDTAtual,1,3)=="ERR"
		AF5->(dbSetOrder(1))
		AF2->(dbSetOrder(1))
		cEDT	:=	Soma1(cEDTAtual)
		While AF5->(MsSeek(xFilial("AF5")+cOrcamen+cEDT)).Or.	AF2->(MsSeek(xFilial("AF2")+cOrcamen+cEDT))
			cEDT	:=	Soma1(cEDT)
		Enddo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Codificacao Estruturada.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTipo == "1"
		cNivelTrf := Soma1(cNivelTrf)

		nDigitos:= Val(SubStr(cMascara,Val(cNivelTrf)-1,1))

		If (nDigitos > 0)
			cEDTIni := IIf(cNivelTrf == "002",StrZero(1,nDigitos),AllTrim(cEDTPai)+ cDelim + StrZero(1,nDigitos))
		Else
			cEDTIni := IIf(cNivelTrf == "002","1",AllTrim(cEDTPai)+ cDelim + "1")
		EndIf


		If Empty(cEDTAtual)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pesquisa todas as EDT's filhas.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("AF5")
			dbSetOrder(2)
			MsSeek(xFilial("AF5")+cOrcamen+cEDTPai)
			While !Eof() .And. xFilial("AF5")+cOrcamen+cEDTPai==;
				AF5->AF5_FILIAL+AF5->AF5_ORCAME+AF5->AF5_EDTPAI

				If Substr(AF5->AF5_EDT,1,2) == "ER"
					dbSkip()
					Loop
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Armazena o codigo da ultima tarefa da edt.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Len(AllTrim(AF5->AF5_EDT))== Len(AllTrim(cEDTIni)) .And. cLastEDT < AF5->AF5_EDT //(AllTrim(cEDTPai) == Substr(AF5->AF5_EDTPAI,1,Len(AllTrim(cEDTPai))))
					cLastEDT := AllTrim(AF5->AF5_EDT)
				EndIf
				dbSkip()
			End

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pesquisa todas as tarefas filhas.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("AF2")
			dbSetOrder(2)
			MsSeek(xFilial("AF2")+cOrcamen+cEDTPai)
			While !Eof() .And. xFilial("AF2")+cOrcamen+cEDTPai==;
				AF2->AF2_FILIAL+AF2->AF2_ORCAME+AF2->AF2_EDTPAI

				If Substr(AF2->AF2_TAREFA,1,2) == "ER"
					dbSkip()
					Loop
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Armazena o codigo da ultima tarefa da edt.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Len(AllTrim(AF2->AF2_TAREFA))== Len(AllTrim(cEDTIni)) .And. cLastEDT < AF2->AF2_TAREFA //(AllTrim(cEDTPai) == Substr(AF2->AF2_EDTPAI,1,Len(AllTrim(cEDTPai))))
					cLastEDT := AllTrim(AF2->AF2_TAREFA)
				EndIf
				dbSkip()
			End
		Else
			cLastEDT := alltrim(cEDTAtual)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Desmembra o codigo da ultima EDT para facilitar a manipulcao dos dados.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPos:= 0
		cLastEDT2 := cLastEDT
		For nI:= 1 To Len(cLastEDT)
			If !Empty(cDelim)
				nPos   := AT(cDelim,cLastEDT)
				nPos   := IIf(nPos > 0,nPos,Len(cLastEDT)+1)
				cEDTAux:= SubStr(cLastEDT,1,IIf(nPos > 1,nPos-1,1))
			Else
				nPos    := Val(SubStr(cMascara,nI,1))
				cEDTAux := SubStr(cLastEDT,1,IIf(nPos > 1,nPos,1))
			EndIf

			If !Empty(cEDTAux)
				aAdd(aEDTAux,cEDTAux)
			EndIf

			cLastEDT:= SubStr(cLastEDT,nPos+1,Len(cLastEDT))
		Next nI


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza a analise dos niveis e compoe a numeracao da nova EDT.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nEDT:= Val(cNivelTrf) - 1

		If Len(aEDTAux) == 0 .Or. (Len(aEDTAux) < Val(cNivelTrf) - 1)
			If (nDigitos > 0)
				cEDT := IIf(cNivelTrf == "002",StrZero(1,nDigitos),AllTrim(cEDTPai)+ cDelim + StrZero(1,nDigitos))
			Else
				cEDT := IIf(cNivelTrf == "002","1",AllTrim(cEDTPai)+ cDelim + "1")
			EndIf
		Else
			If aEDTAux[Val(cNivelTrf)-1] == replicate("Z",Len(aEDTAux[Val(cNivelTrf)-1]))
				cEDT := cLastEDT2
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se os ultimos caracteres sao numeros ou letras³
				//³para realizar a adicao correta.                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cNumero := SubStr( aEDTAux[Len(aEDTAux)],1)
				cUltNum := SubStr( aEDTAux[Len(aEDTAux)], Len(cNumero),1)

				If Len(aEDTAux) > 0 .And. cUltNum == "9"

					If lTipCode // Se .T. usa somente numeros, se .F. (padrao) usa alfanumericos p/ o novo codigo da tarefa

						If cNumero == replicate( "9" ,Len(cNumero))
							lZZ:= .T.
						Else


							nEDT  	 := Val(cNumero) + 1
							cLastEDT  := StrZero(nEDT,Len(cNumero))

							// Atualiza o numero da proxima tarefa
							aEDTAux[Len(aEDTAux)] := cLastEDT

						EndIf

					Else

					    //Se alcacou o limite de tarefas
						If cNumero == replicate( "Z" ,Len(cNumero))
							lZZ:= .T.
						Else
							//Para soma1, preciso do valor em string sem 0 a esquerda
							nEDT 	 := Val(cUltNum)
							cLastEDT := Soma1(Alltrim(STR(nEDT)))

							cNumero := SubStr( aEDTAux[Len(aEDTAux)] , 1, Len(cNumero)-1)
							cNumero += cLastEDT
							aEDTAux[Len(aEDTAux)] := cNumero
						EndIf
					EndIf
				EndIf

				aEDTAux[Len(aEDTAux)]:= Soma1(cNumero)

				For nI:= 1 To Len(aEDTAux)
					cEDT += aEDTAux[nI]

					If nI <> Len(aEDTAux)
						cEDT+= cDelim
					EndIf

				Next nI
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se a numeracao ja existe ou se existe inconsistencia ³
		//³com relacao ao tamanho da nova numeracao e o tamanho do campo.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AF5")
		AF5->(dbSetOrder(1))
		dbSelectArea("AF2")
		AF2->(dbSetOrder(1))

		//Se coicide com o codigo do orcamento incrementar um
		If AF5->(MsSeek(xFilial("AF5") + cOrcamen + cEDT + Space(Len(AF5->AF5_EDT)-Len(cEDT)))) .And. AF5->AF5_NIVEL == "001"
			cEDT := Soma1(cEDT)
		Endif

		If (Len(cEDT) > Len(AF5->AF5_EDT)) .OR. ( AllTrim(cEDTAtual) == AllTrim(cEDT) ) .Or. lZZ
			dbSelectArea("AF2")
			dbSetOrder(1)
			MsSeek(xFilial("AF2") + cOrcamen + "ERR" + Replicate("Z",Len(AF2->AF2_TAREFA)-3),.T.)
			dbSkip(-1)
			If (xFilial("AF2") + cOrcamen == AF2->AF2_FILIAL + AF2->AF2_ORCAME) .And. (AF2->AF2_NIVEL <> "001") .And. (SubStr(AF2->AF2_TAREFA,1,3) == "ERR")
				cEDT := Soma1(AF2->AF2_TAREFA)
			Else
				cEDT := "ERR" + StrZero(1,Len(AF2->AF2_TAREFA)-3)
			EndIf

			dbSelectArea("AF5")
			dbSetOrder(1)
			MsSeek(xFilial("AF5") + cOrcamen + "ERR" + Replicate("Z",Len(AF5->AF5_EDT)-3),.T.)
			dbSkip(-2) // Pula o Nivel 002
			If (xFilial("AF5") + cOrcamen == AF5->AF5_FILIAL + AF5->AF5_ORCAME) .And. (AF5->AF5_NIVEL <> "001") .And. (SubStr(AF5->AF5_EDT,1,3) == "ERR")
				cEDT := If(Soma1(AF5->AF5_EDT)>cEDT,Soma1(AF5->AF5_EDT),cEDT)
			Else
				cEDT := If("ERR" + StrZero(1,Len(AF5->AF5_EDT)-3)>cEDT,"ERR"+StrZero(1,Len(AF5->AF5_EDT)-3),cEDT)
			EndIf

			While AF5->(MsSeek(xFilial("AF5")+cOrcamen+cEDT)) .Or. AF2->(MsSeek(xFilial("AF2")+cOrcamen+cEDT))
				If AF5->(!Eof())
					cEDT := Soma1(AF5->AF5_EDT)
				Else
					cEDT := Soma1(AF2->AF2_TAREFA)
				EndIf
			End
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Codificacao Sequencial Nao Estruturada.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTipo == "2"
		dbSelectArea("AF2")
		dbSetOrder(1)
		MsSeek(xFilial("AF2") + cOrcamen + Replicate("Z",Len(AF2->AF2_TAREFA)),.T.)
		dbSkip(-1)
		If (xFilial("AF2") + cOrcamen == AF2->AF2_FILIAL + AF2->AF2_ORCAME) .And. (AF2->AF2_NIVEL <> "001")
			cEDT := Soma1(AF2->AF2_TAREFA)
		Else
			cEDT := StrZero(1,Len(AF2->AF2_TAREFA))
		EndIf

		dbSelectArea("AF5")
		dbSetOrder(1)
		MsSeek(xFilial("AF5") + cOrcamen + Replicate("Z",Len(AF5->AF5_EDT)),.T.)
		dbSkip(-2) // Pula o Nivel 002
		If (xFilial("AF5") + cOrcamen == AF5->AF5_FILIAL + AF5->AF5_ORCAME) .And. (AF5->AF5_NIVEL <> "001")
			cEDT := If(Soma1(AF5->AF5_EDT)>cEDT,Soma1(AF5->AF5_EDT),cEDT)
		Else
			cEDT := If(StrZero(1,Len(AF5->AF5_EDT))>cEDT,StrZero(1,LEN(AF5->AF5_EDT)),cEDT)
		EndIf

		While AF5->(MsSeek(xFilial("AF5")+cOrcamen+cEDT)) .Or. AF2->(MsSeek(xFilial("AF2")+cOrcamen+cEDT))
			If AF5->(!Eof())
				cEDT := Soma1(AF5->AF5_EDT)
			Else
				cEDT := Soma1(AF2->AF2_TAREFA)
			EndIf
		EnddO
EndCase


//
// Verifica se o codigo gerado da tarefa esta sendo utilizado,
// em caso positivo gera um novo codigo.
// obs.: deve ser utiliza a string "AF5" pra chave. Pois para gerar o codigo da edt
//       ou tarefa depende sempre das tabelas AF5 e AF2. Evitando a duplicidade de chave.
//
dbSelectArea("AF2")
dbSetOrder(1)
dbSelectArea("AF5")
dbSetOrder(1)
While AF5->(MsSeek(xFilial("AF5")+cOrcamen+PadR(cEDT,Len(AF5->AF5_EDT)))) .Or. AF2->(MsSeek(xFilial("AF2")+cOrcamen+PadR(cEDT,Len(AF2->AF2_TAREFA)))) .Or. !MayIUseCode("AF5"+xFilial("AF5")+cOrcamen+PadR(cEDT,Len(AF5->AF5_EDT)))
	Leave1Code("AF5"+xFilial("AF5")+cOrcamen+PadR(cEDT,Len(AF5->AF5_EDT)))
	cEDT := PmsNumAF5(cOrcamen,cOldNivelTrf,cEDTPai,cEDT,lLiberaCod)
EndDo

If ExistBlock("PMSNUMAF5")
	cEDT := ExecBlock("PMSNUMAF5",.F.,.F.,{cEDT})
EndIf
//
// Ponto de entrada criado devido ao problema do ponto acima ultrapassar os 10 caracteres,
// isto é: U_PMSNUMAF5 vai ser considerado somente pelo compilador como U_PMSNUMAF
//
If ExistBlock("PMSNOAF5")
	cEDT := ExecBlock("PMSNOAF5",.F.,.F.,{cEDT})
EndIf

If lLiberaCod
	FreeUsedCode(.T.)
Endif

RestArea(aAreaAF1)
RestArea(aAreaAF5)
RestArea(aArea)
Return cEDT

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsNumAF2³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna proximo numero da Tarefa do Projeto.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsNumAF2(cOrcamen,cNivelTrf,cEDTPai,cTrfAtual,lLiberaCod)
Local aArea		:= GetArea()
Local aAreaAF5	:= AF5->(GetArea())
Local aAreaAF2	:= AF2->(GetArea())
Local aAreaAF1	:= AF1->(GetArea())
Local cTarefa   := ""
Local cLastTrf  := ""
Local cLastTrf2 := ""
Local cTrfAux   := ""
Local lZZ		:= .F.
Local cTipo 	:= GetNewPar("MV_PMSECOD","1")
Local cDelim    := ""
Local cMascara  := ""
Local aTrfAux   := {}
Local nI        := 0
Local nPos      := 0
Local nTRf      := 0
Local nDigitos  := 0
Local cOldNivelTrf := cNivelTrf
Local cTrfIni	 := ''
local nQtdNivel,nNewTrf := 0
Local cNumero,cUltNum   := ""
Local lTipCode  := GetNewPar("MV_PMSCODE",.F.)


DEFAULT lLiberaCod	:= .T.
DEFAULT cTrfAtual := ""

//
// Busca no orcamento a mascara e delimitador.
//
AF1->(dbSetOrder(1))
AF1->(MSSeek(xFilial("AF1")+cOrcamen))

cDelim    := AllTrim(AF1->AF1_DELIM)
cMascara  := AllTrim(AF1->AF1_MASCAR)

//
// caso nao tenha informado a mascara.
//
If Empty(cMascara)
	cMascara := "111111111111111111"
EndIf

nTamAF9:= TamSx3("AF9_TAREFA")[1]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a codificacao e normal ou estruturada.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case Substr(cTrfAtual,1,3)=="ERR"
		AF2->(dbSetOrder(1))
		AF5->(dbSetOrder(1))
		cTarefa	:=	Soma1(cTrfAtual)
		While AF5->(MsSeek(xFilial("AF5")+cOrcamen+cTarefa)).Or. AF2->(MsSeek(xFilial("AF2")+cOrcamen+cTarefa)	)
			cTarefa	:=	Soma1(cTarefa)
		Enddo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Codificacao Estruturada.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTipo == "1"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Incrementa o nivel da tarefa.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cNivelTrf := Soma1(cNivelTrf)

		nDigitos:= Val(SubStr(cMascara,Val(cNivelTrf)-1,1))

		If (nDigitos > 0)
			cTrfIni := IIf(cNivelTrf == "002",StrZero(1,nDigitos),AllTrim(cEDTPai)+ cDelim + StrZero(1,nDigitos))
		Else
			cTrfIni := IIf(cNivelTrf == "002","1",AllTrim(cEDTPai)+ cDelim + "1")
		EndIf

		If empty(cTrfAtual)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pesquisa todas as tarefas filhas.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("AF2")
			dbSetOrder(2)
			MsSeek(xFilial("AF2")+cOrcamen+cEDTPai)
			While !Eof() .And. xFilial("AF2")+cOrcamen+cEDTPai==;
				AF2->AF2_FILIAL+AF2->AF2_ORCAME+AF2->AF2_EDTPAI

				If Substr(AF2->AF2_TAREFA,1,2) == "ER"
					dbSkip()
					Loop
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Armazena o codigo da ultima tarefa da edt.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Len(AllTrim(AF2->AF2_TAREFA))== Len(AllTrim(cTrfIni)) .And. cLastTrf < AF2->AF2_TAREFA //(AllTrim(cEDTPai) == Substr(AF2->AF2_EDTPAI,1,Len(AllTrim(cEDTPai))))
					cLastTrf := AllTrim(AF2->AF2_TAREFA)
				EndIf
				dbSkip()
			End

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pesquisa todas as EDT's filhas.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("AF5")
			dbSetOrder(2)
			MsSeek(xFilial("AF5")+cOrcamen+cEDTPai)
			While !Eof() .And. xFilial("AF5")+cOrcamen+cEDTPai==;
				AF5->AF5_FILIAL+AF5->AF5_ORCAME+AF5->AF5_EDTPAI

				If Substr(AF5->AF5_EDT,1,2) == "ER"
					dbSkip()
					Loop
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Armazena o codigo da ultima tarefa da edt.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Len(AllTrim(AF5->AF5_EDT))== Len(AllTrim(cTrfIni)) .And. cLastTrf < AF5->AF5_EDT //(AllTrim(cEDTPai) == Substr(AF5->AF5_EDTPAI,1,Len(AllTrim(cEDTPai))))
					cLastTrf := AllTrim(AF5->AF5_EDT)
				EndIf
				dbSkip()
			End

		Else
			cLastTrf := cTrfAtual

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Desmembra o codigo da ultima tarefa para facilitar a manipulcao dos dados.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPos:= 0
		cLastTrf2 := cLastTrf
		For nI:= 1 To Len(cLastTrf)
			If !Empty(cDelim)
				nPos   := AT(cDelim,cLastTrf)
				nPos   := IIf(nPos > 0,nPos,Len(cLastTrf)+1)
				cTrfAux:= SubStr(cLastTrf,1,IIf(nPos > 1,nPos-1,1))
			Else
				nPos    := Val(SubStr(cMascara,nI,1))
				cTrfAux := SubStr(cLastTrf,1,IIf(nPos > 1,nPos,1))
			EndIf

			If !Empty(cTrfAux)
				aAdd(aTrfAux,cTrfAux)
			EndIf

			cLastTrf:= SubStr(cLastTrf,nPos+1,Len(cLastTrf))
		Next nI


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza a analise dos niveis e compoe a numeracao da nova tarefa.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nTrf:= Val(cNivelTrf) - 1

		If Len(aTrfAux) == 0 .Or. (Len(aTrfAux) < Val(cNivelTrf) - 1)
			If (nDigitos > 0)
				cTarefa := IIf(cNivelTrf == "002",StrZero(1,nDigitos),AllTrim(cEDTPai)+ cDelim + StrZero(1,nDigitos))
			Else
				cTarefa := IIf(cNivelTrf == "002","1",AllTrim(cEDTPai)+ cDelim + "1")
				If Len(cTarefa) > nTamAF9
					cTarefa := Substr(cTarefa,1,(nTamAF9 - 1))+"1"
				EndIf
			EndIf
		Else
	      /////////////////////////////////////////////////////////////////////
			// Verifica quantos algaritimos tenho depois do ultimo delimitador //
	      /////////////////////////////////////////////////////////////////////

			nQtdNivel := Len(aTrfAux[Len(aTrfAux)])
			cNumero := Alltrim(aTrfAux[Len(aTrfAux)])
			cUltNum := SubStr(cNumero,Len(cNumero))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se os ultimos caracteres sao numeros ou letras³
			//³para realizar a adicao correta.                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aTrfAux) > 0 .And. cUltNum == "9"

				If lTipCode // Usa somente numeros ou alfanumericos no novo codigo da tarefa

					If cNumero == replicate( "9" ,nQtdNivel)
						lZZ:= .T.
					Else

						nNewTrf := Val(cNumero) + 1
						cLastTrf2 := StrZero(nNewTrf,nQtdNivel)

						// Atualiza o numero da proxima tarefa
						aTrfAux[Len(aTrfAux)] := cLastTrf2

					EndIf

				Else

				   //Se alcacou o limite de tarefas
					If cNumero == replicate( "Z" ,nQtdNivel)
						lZZ:= .T.
					Else
						//Para soma1, preciso do valor em string sem 0 a esquerda
						nNewTrf 	 := Val(cUltNum)
						cLastTrf2 := Soma1(Alltrim(STR(nNewTrf)))

						cNumero := SubStr( aTrfAux[Len(aTrfAux)] , 1, Len(cNumero)-1 )
						cNumero += cLastTrf2
						aTrfAux[Len(aTrfAux)] := cNumero
					EndIf

				EndIf

				For nI:= 1 To Len(aTrfAux)
					cTarefa += aTrfAux[nI]

					If nI <> Len(aTrfAux)
						cTarefa+= cDelim
					EndIf

				Next nI

			Else

			   //Se alcacou o limite de tarefas
				If cNumero == replicate( "Z" ,nQtdNivel)
					lZZ:= .T.
				Else
				   // Caso seja alfanumerico
					aTrfAux[Len(aTrfAux)] := Soma1(cNumero)
				EndIf

				For nI:= 1 To Len(aTrfAux)
					cTarefa += aTrfAux[nI]

					If nI <> Len(aTrfAux)
						cTarefa+= cDelim
					EndIf

				Next nI

			EndIf
		EndIf


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se a numeracao ja existe ou se existe inconsistencia ³
		//³com relacao ao tamanho da nova numeracao e o tamanho do campo.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AF2")
		AF2->(dbSetOrder(1))
		dbSelectArea("AF5")
		AF5->(dbSetOrder(1))

		//Se coicide com o codigo do orcamento incrementar um
		If AF5->(MsSeek(xFilial("AF5") + cOrcamen + cTarefa + Space(Len(AF5->AF5_EDT)-Len(cTarefa)))) .And. AF5->AF5_NIVEL == "001"
			cTarefa	:= Soma1(cTarefa)
		Endif

		If Len(cTarefa) > Len(AF2->AF2_TAREFA) .OR. ( AllTrim(cTrfAtual) == AllTrim(cTarefa) ) .Or. lZZ
			dbSelectArea("AF2")
			dbSetOrder(1)
			MsSeek(xFilial("AF2")+cOrcamen+"ERR"+Replicate("Z",Len(AF5->AF5_EDT)-3),.T.)
			dbSkip(-1)

			If (xFilial("AF2") + cOrcamen == AF2->AF2_FILIAL + AF2->AF2_ORCAME) .And. (AF2->AF2_NIVEL <> "001") .And. (SubStr(AF2->AF2_TAREFA,1,3) == "ERR")
				cTarefa := Soma1(AF2->AF2_TAREFA)
			Else
				cTarefa := "ERR" + StrZero(1,Len(AF2->AF2_TAREFA)-3)
			EndIf

			dbSelectArea("AF5")
			dbSetOrder(1)
			MsSeek(xFilial("AF5")+cOrcamen+"ERR"+Replicate("Z",Len(AF5->AF5_EDT)-3),.T.)
			dbSkip(-2) // Pula o Nivel 002

			If (xFilial("AF5") + cOrcamen == AF5->AF5_FILIAL + AF5->AF5_ORCAME) .And. (AF5->AF5_NIVEL <> "001") .And. (SubStr(AF5->AF5_EDT,1,3) == "ERR")
				cTarefa := If(Soma1(AF5->AF5_EDT)>cTarefa,Soma1(AF5->AF5_EDT),cTarefa)
			Else
				cTarefa := If("ERR"+StrZero(1,Len(AF5->AF5_EDT)-3)>cTarefa,"ERR"+StrZero(1,Len(AF5->AF5_EDT)-3),cTarefa)
			EndIf
			While AF5->(MsSeek(xFilial("AF5")+cOrcamen+cTarefa)) .Or. AF2->(MsSeek(xFilial("AF2")+cOrcamen+cTarefa))
				If AF5->(!Eof())
					cTarefa := Soma1(AF5->AF5_EDT)
				Else
					cTarefa := Soma1(AF2->AF2_TAREFA)
				EndIf
			End
		EndIf

	Case cTipo == "2"
		If Empty(cTrfAtual)
			dbSelectArea("AF2")
			dbSetOrder(1)
			MsSeek(xFilial("AF2")+cOrcamen+Replicate("Z",Len(AF2->AF2_TAREFA)),.T.)
			dbSkip(-1)

			If (xFilial("AF2") + cOrcamen == AF2->AF2_FILIAL + AF2->AF2_ORCAME) .And. (AF2->AF2_NIVEL <> "001")
				cTarefa := Soma1(AF2->AF2_TAREFA)
			Else
				cTarefa := StrZero(1,Len(AF2->AF2_TAREFA))
			EndIf

			dbSelectArea("AF5")
			dbSetOrder(1)
			MsSeek(xFilial("AF5")+cOrcamen+Replicate("Z",Len(AF5->AF5_EDT)),.T.)
			dbSkip(-2) // Pula o Nivel 002

			If (xFilial("AF5") + cOrcamen == AF5->AF5_FILIAL + AF5->AF5_ORCAME) .And. (AF5->AF5_NIVEL <> "001")
				cTarefa := If(Soma1(AF5->AF5_EDT)>cTarefa,Soma1(AF5->AF5_EDT),cTarefa)
			Else
				cTarefa := If(StrZero(1,Len(AF5->AF5_EDT))>cTarefa,StrZero(1,Len(AF5->AF5_EDT)),cTarefa)
			EndIf
		Else
			cTarefa := Soma1(cTrfAtual)
		EndIf

		While AF5->(MsSeek(xFilial("AF5")+cOrcamen+cTarefa)) .Or. AF2->(MsSeek(xFilial("AF2")+cOrcamen+cTarefa))
			If AF5->(!Eof())
				cTarefa := Soma1(AF5->AF5_EDT)
			Else
				cTarefa := Soma1(AF2->AF2_TAREFA)
			EndIf
		End
EndCase

//
// Verifica se o codigo gerado da tarefa esta sendo utilizado,
// em caso positivo gera um novo codigo.
// obs.: deve ser utiliza a string "AF5" pra chave. Pois para gerar o codigo da edt
//       ou tarefa depende sempre das tabelas AF5 e AF2. Evitando a duplicidade de chave.
//
dbSelectArea("AF5")
dbSetOrder(1)
dbSelectArea("AF2")
dbSetOrder(1)
While AF5->(MsSeek(xFilial("AF5")+cOrcamen+PadR(cTarefa,Len(AF5->AF5_EDT)))) .Or. AF2->(MsSeek(xFilial("AF2")+cOrcamen+PadR(cTarefa,Len(AF2->AF2_TAREFA)))).Or. !MayIUseCode("AF2"+xFilial("AF2")+cOrcamen+PadR(cTarefa,Len(AF2->AF2_TAREFA)))
	Leave1Code("AF2"+xFilial("AF2")+cOrcamen+PadR(cTarefa,Len(AF2->AF2_TAREFA)))
	cTarefa := PmsNumAF2(cOrcamen,cOldNivelTrf,cEDTPai,cTarefa,lLiberaCod )
EndDo

If ExistBlock("PMSNUMAF2")
	cTarefa	:= ExecBlock("PMSNUMAF2",.F.,.F.,{cTarefa})
EndIf
//
// Ponto de entrada criado devido ao problema do ponto acima ultrapassar os 10 caracteres,
// isto é: U_PMSNUMAF2 vai ser considerado somente pelo compilador como U_PMSNUMAF
//
If ExistBlock("PMSNOAF2")
	cTarefa	:= ExecBlock("PMSNOAF2",.F.,.F.,{cTarefa})
EndIf

If lLiberaCod
	FreeUsedCode(.T.)
Endif

RestArea(aAreaAF1)
RestArea(aAreaAF2)
RestArea(aAreaAF5)
RestArea(aArea)
Return cTarefa

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PmsNumAFC³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna proximo numero da EDT do Projeto.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProjeto   : projeto da EDT                                           ³±±
±±³          ³ cRevisa    : revisao atual do projeto                                 ³±±
±±³          ³ cNivelTrf  : nivel da EDT pai                                         ³±±
±±³          ³ cEDTPai    : codigo da EDT pai                                        ³±±
±±³          ³ cEDTAtual  : codigo da EDT(apartir desta EDT que sera gerado o        ³±±
±±³          ³              proximo numero da EDT)                                   ³±±
±±³          ³ lLiberaCod : .T. para liberar no semaforo o codigo gerado             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsNumAFC(cProjeto,cRevisa,cNivelTrf,cEDTPai,cEDTAtual,lLiberaCod)
Local aArea     := GetArea()
Local aAreaAFC  := AFC->(GetArea())
Local aAreaAF8  := AF8->(GetArea())
Local cEDT      := ""
Local cLastEDT  := ""
Local cLastEDT2 := ""
Local cEDTAux   := ""
Local lZZ       := .F.
Local lTipCode  := GetNewPar("MV_PMSCODE",.F.)
Local cTipo     := GetNewPar("MV_PMSECOD","1")
Local cDelim
Local cMascara
Local aEDTAux   := {}
Local nI        := 0
Local nPos      := 0
Local nEDT      := 0
Local nDigitos  := 0
Local cOldNivelTrf := cNivelTrf
Local cEDTIni   := ''
Local lAchou 	 := .F.
local nQtdNivel,nNewEDT,nPtoStart := 0
Local cNumero   := ""

DEFAULT lLiberaCod := .T.
DEFAULT cEDTAtual  := ""

AF8->(dbSetOrder(1))
AF8->(MsSeek(xFilial()+cProjeto))

cDelim    := AllTrim(AF8->AF8_DELIM)
cMascara  := AllTrim(AF8->AF8_MASCAR)

If Empty(cMascara)
	cMascara := "111111111111111111"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a codificacao e normal ou estruturada.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case Substr(cEDTAtual,1,3)=="ERR"
		cNumERR	:=	PMSGetLastErr(cProjeto,cRevisa)
		If Empty(cNumERR)
			cEDT	:=	Soma1(cEDTAtual)
		Else
			cEDT	:=	Soma1(cNumErr)
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Codificacao Estruturada.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTipo == "1"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Incrementa o nivel da tarefa.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cNivelTrf := StrZero(Val(cNivelTrf) + 1, TamSX3("AFC_NIVEL")[1])

		nDigitos:= Val(SubStr(cMascara,Val(cNivelTrf)-1,1))

		If (nDigitos > 0)
			cEDTIni    := IIf(cNivelTrf == "002",StrZero(1,nDigitos),AllTrim(cEDTPai)+ cDelim + StrZero(1,nDigitos))
			cEDTIniQry := IIf(cNivelTrf == "002","",AllTrim(cEDTPai)+ cDelim ) + Replicate(" ",nDigitos)
			cEDTFimQry := IIf(cNivelTrf == "002","",AllTrim(cEDTPai)+ cDelim ) + Replicate("Z",nDigitos)
		Else
			cEDTIni    := IIf(cNivelTrf == "002","1",AllTrim(cEDTPai)+ cDelim + StrZero(1,Val(cMascara)))
			cEDTIniQry := IIf(cNivelTrf == "002"," ",AllTrim(cEDTPai)+ cDelim + " ")
			cEDTFimQry := IIf(cNivelTrf == "002","Z",AllTrim(cEDTPai)+ cDelim + "Z")
		EndIf

		If Empty(cEDTAtual)
			cLastEDT :=	PMSPegaFilho(cProjeto,cRevisa, cEdtPai , cEDTIniQry , cEDTFimQry)
		Else
			cLastEDT := cEDTAtual
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Desmembra o codigo da ultima EDT para facilitar a manipulcao dos dados.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPos:= 0
		cLastEDT2 := cLastEDT
		For nI:= 1 To Len(Alltrim(cLastEDT))

			If !Empty(cDelim)
				cEDTAux := Substr(cLastEDT2,nI,1)
			Else
				cEDTAux := Substr(cLastEDT2,nI,1)
			EndIf

			If !Empty(cEDTAux)
				aAdd(aEDTAux,cEDTAux)
			EndIf

			cLastEDT:= SubStr(cLastEDT2,nPos+1,Len(cLastEDT))

		Next nI


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza a analise dos niveis e compoe a numeracao da nova EDT.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nEDT := Val(cNivelTrf) - 1

		If Len(aEDTAux) == 0 .Or. (Len(aEDTAux) < Val(cNivelTrf) - 1)
			If (nDigitos > 0)
				cEDT := IIf(cNivelTrf == "002",StrZero(1,nDigitos),AllTrim(cEDTPai)+ cDelim + StrZero(1,nDigitos))
			Else
				cEDT := IIf(cNivelTrf == "002","1",AllTrim(cEDTPai)+ cDelim + "1")
			EndIf
		Else
			If nEDT>1
				If (aEDTAux[Val(cNivelTrf)-1] == replicate( "Z" ,Len(aEDTAux[Val(cNivelTrf)-1])))
					cEDT := cLastEDT2
				Else

					ni:=Len(aEDTAux)
					While ni <> 0

						If !lAchou
							lAchou := (aEDTAux[ni] == cDelim )
						else
							Exit
						EndIf

						If !lAchou
							ni--
						EndIf

					Enddo

					nQtdNivel := Len(aEDTAux) - ni
					nPtoStart := ni + 1

					For nI:= nPtoStart To Len(aEDTAux)
						cNumero += aEDTAux[nI]
					Next nI

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se os ultimos caracteres sao numeros ou letras³
					//³para realizar a adicao correta.                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Len(aEDTAux) > 0 .And. aEDTAux[Len(aEDTAux)] == "9"

	    				If lTipCode // Se .T. usa somente numeros, se .F. (padrao) usa alfanumericos p/ o novo codigo da tarefa

							If cNumero == replicate( "9" ,nQtdNivel)
								lZZ:= .T.
							Else
								nNewEDT := Val(cNumero) + 1
								cLastEDT2 := StrZero(nNewEDT,nQtdNivel)

								// Atualiza o numero da proxima tarefa
								nPos := 1
								For nI:=nPtoStart To Len(aEDTAux)

									cEDTAux:= Substr(cLastEDT2,nPos,1)

									If !Empty(cEDTAux)
										aEDTAux[nI] := cEDTAux
									EndIf

									nPos++
								Next nI
							EndIf

						Else

						   //Se alcacou o limite de tarefas
							If cNumero == replicate( "Z" ,nQtdNivel)
								lZZ:= .T.
							Else
							   // Caso seja alfanumerico
								aEDTAux[Len(aEDTAux)] := Soma1(Alltrim( aEDTAux[Len(aEDTAux)] ))
							EndIf

						EndIf

						For nI:= 1 To Len(aEDTAux)
							cEDT += aEDTAux[nI]
						Next nI

					Else

			   		aEDTAux[Len(aEDTAux)]:= Soma1(cNumero)


						For nI:= 1 To (nPtoStart-1)
							cEDT += aEDTAux[nI]
						Next nI
						cEDT += Alltrim( aEDTAux[Len(aEDTAux)] )
					EndIf
				EndIf

			else

				ni:=Len(aEDTAux)
				While ni <> 0

					If !lAchou
						lAchou := (aEDTAux[ni] == cDelim )
					else
						Exit
					EndIf

					If !lAchou
						ni--
					EndIf

				Enddo

				nQtdNivel := Len(aEDTAux) - ni //QUANTIDADE DE CARACTERES QUE ESTE NIVEL TERA BASEADA NA POSICAO DO DELIMITADOR
				nPtoStart := ni + 1  //POSIÇAO QUE DEVEMOS BUSCAR O NOVO NUMERO

				For nI:= nPtoStart To Len(aEDTAux)
					cNumero += aEDTAux[nI]
				Next nI

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se os ultimos caracteres sao numeros ou letras³
				//³para realizar a adicao correta.                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Len(aEDTAux) > 0 .And. aEDTAux[Len(aEDTAux)] == "9"

	    				If lTipCode // Se .T. usa somente numeros, se .F. (padrao) usa alfanumericos p/ o novo codigo da tarefa

							If cNumero == replicate( "9" ,nQtdNivel)
								lZZ:= .T.
							Else
								nNewEDT := Val(cNumero) + 1
								cLastEDT2 := StrZero(nNewEDT,nQtdNivel)

								// Atualiza o numero da proxima tarefa
								nPos := 1
								For nI:=nPtoStart To Len(aEDTAux)

									cEDTAux:= Substr(cLastEDT2,nPos,1)

									If !Empty(cEDTAux)
										aEDTAux[nI] := cEDTAux
									EndIf

									nPos++
								Next nI
							EndIf

						Else

						   //Se alcacou o limite de tarefas
							If cNumero == replicate( "Z" ,nQtdNivel)
								lZZ:= .T.
							Else
							   // Caso seja alfanumerico
								aEDTAux[Len(aEDTAux)] := Soma1(Alltrim( aEDTAux[Len(aEDTAux)] ))
							EndIf

						EndIf

						For nI:= 1 To Len(aEDTAux)
							cEDT += aEDTAux[nI]
						Next nI

					Else

						aEDTAux[Len(aEDTAux)]:= Soma1(cNumero)


						For nI:= 1 To (nPtoStart-1)
							cEDT += aEDTAux[nI]
						Next nI
						cEDT += Alltrim( aEDTAux[Len(aEDTAux)] )
						//cEDT += SUBSTR(aEDTAux[Len(aEDTAux)], Len(aEDTAux[Len(aEDTAux)] ), Len(aEDTAux[Len(aEDTAux)] ))
					EndIf
			EndIf
		EndIf


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se a numeracao ja existe ou se existe inconsistencia ³
		//³com relacao ao tamanho da nova numeracao e o tamanho do campo.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AFC")
		AFC->(dbSetOrder(1))
		dbSelectArea("AF9")
		AF9->(dbSetOrder(1))

		//Se coicide com o codigo do projeto, incrementar um
		If	AFC->(MsSeek(xFilial("AFC") + cProjeto + cRevisa + cEDT + Space(Len(AFC->AFC_EDT)-Len(cEDT)))) .And. AFC->AFC_NIVEL == "001"
			cEDT := Soma1( AllTrim(cEDT) )
		Endif

		If (Len(cEDT) > Len(AFC->AFC_EDT)) .OR. ( AllTrim(cEDTAtual) == AllTrim(cEDT) ) .Or. lZZ
			cNumERR	:=	PMSGetLastErr(cProjeto,cRevisa)
			If Empty(cNumERR)
				cEDT := "ERR" + StrZero(1,Len(AFC->AFC_EDT)-3)
			Else
				cEDT	:=	Soma1(cNumErr)
			Endif
		EndIf


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Codificacao Sequencial Nao Estruturada.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTipo == "2"

		If Empty(cEDTAtual)
			dbSelectArea("AF9")
			dbSetOrder(1)
			MsSeek(xFilial("AF9") + cProjeto + cRevisa + Replicate("Z",Len(AFC->AFC_EDT)),.T.)
			dbSkip(-1)
			If (xFilial("AF9") + cProjeto + cRevisa == AF9->AF9_FILIAL + AF9->AF9_PROJET + AF9->AF9_REVISA) .And. (AF9->AF9_NIVEL <> "001")
				cEDT := Soma1( AllTrim(AF9->AF9_TAREFA) )
			Else
				cEDT := StrZero(1,Len(AFC->AFC_EDT))
			EndIf

			dbSelectArea("AFC")
			dbSetOrder(1)
			MsSeek(xFilial("AFC") + cProjeto + cRevisa + Replicate("Z",Len(AFC->AFC_EDT)),.T.)
			dbSkip(-2) // Pula o Nivel 002
			If (xFilial("AFC") + cProjeto + cRevisa == AFC->AFC_FILIAL + AFC->AFC_PROJET + AFC->AFC_REVISA) .And. (AFC->AFC_NIVEL <> "001")
				cEDT := If(Soma1( AllTrim(AFC->AFC_EDT))>cEDT,Soma1(AFC->AFC_EDT),cEDT)
			Else
				cEDT := If(StrZero(1,Len(AFC->AFC_EDT))>cEDT,StrZero(1,Len(AFC->AFC_EDT)),cEDT)
			EndIf
		Else
			cEDT := Soma1( AllTrim(cEDTAtual) )
		Endif

		While AFC->(MsSeek(xFilial("AFC")+cProjeto+cRevisa+cEDT)) .Or. AF9->(MsSeek(xFilial("AF9")+cProjeto+cRevisa+cEDT))
			If AFC->(!Eof())
				cEDT := Soma1( AllTrim(AFC->AFC_EDT) )
			Else
				cEDT := Soma1( AllTrim(AF9->AF9_TAREFA) )
			EndIf
		End
EndCase

//
// Verifica se o codigo gerado da tarefa esta sendo utilizado,
// em caso positivo gera um novo codigo.
// obs.: deve ser utiliza a string "AFC" pra chave. Pois para gerar o codigo da edt
//       ou tarefa depende sempre das tabelas AFC e AF9. Evitando a duplicidade de chave.
//
dbSelectArea("AF9")
dbSetOrder(1)
dbSelectArea("AFC")
dbSetOrder(1)
While AFC->(MsSeek(xFilial("AFC")+cProjeto+cRevisa+PadR(cEDT,Len(AFC->AFC_EDT)))) .Or. AF9->(MsSeek(xFilial("AF9")+cProjeto+cRevisa+PadR(cEDT,Len(AF9->AF9_TAREFA)))) .Or. !MayIUseCode("AFC"+xFilial("AFC")+cProjeto+PadR(cEDT,Len(AFC->AFC_EDT)))
	Leave1Code("AFC"+xFilial("AFC")+cProjeto+PadR(cEDT,Len(AFC->AFC_EDT)))
	cEDT := PmsNumAFC(cProjeto,cRevisa,cOldNivelTrf,cEDTPai,cEDT,lLiberaCod)
EndDo

If ExistBlock("PMSNUMAFC")
	cEDT := ExecBlock("PMSNUMAFC",.F.,.F.,{cEDT,cProjeto,cRevisa,cOldNivelTrf,cEDTPai,lLiberaCod})
EndIf
//
// Ponto de entrada criado devido ao problema do ponto acima ultrapassar os 10 caracteres,
// isto é: U_PMSNUMAFC vai ser considerado somente pelo compilador como U_PMSNUMAF
//
If ExistBlock("PMSNOAFC")
	cEDT := ExecBlock("PMSNOAFC",.F.,.F.,{cEDT,cProjeto,cRevisa,cOldNivelTrf,cEDTPai,lLiberaCod})
EndIf

If lLiberaCod
	FreeUsedCode(.T.)
Endif

RestArea(aAreaAF8)
RestArea(aAreaAFC)
RestArea(aArea)
Return cEDT

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsNumAF9³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna proximo numero da Tarefa do Projeto.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProjeto   : projeto da Tarefa                                        ³±±
±±³          ³ cRevisa    : revisao atual da Tarefa                                  ³±±
±±³          ³ cNivelTrf  : nivel da EDT pai                                         ³±±
±±³          ³ cEDTPai    : codigo da EDT pai                                        ³±±
±±³          ³ cEDTAtual  : codigo da Tarefa(apartir desta Tarefa que sera gerado o  ³±±
±±³          ³              proximo numero da Tarefa)                                ³±±
±±³          ³ lLiberaCod : .T. para liberar no semaforo o codigo gerado             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsNumAF9(cProjeto,cRevisa,cNivelTrf,cEDTPai,cTrfAtual ,lLiberaCod)
Local aArea     := GetArea()
Local aAreaAFC	:= AFC->(GetArea())
Local aAreaAF9  := AF9->(GetArea())
Local aAreaAF8  := AF8->(GetArea())
Local cTarefa   := ""
Local cLastTrf  := ""
Local cLastTrf2 := ""
Local cTrfAux   := ""
Local cTipo     := GetNewPar("MV_PMSECOD","1")
Local lZZ       := .F.
Local lTipCode  := GetNewPar("MV_PMSCODE",.F.)
Local cDelim
Local cMascara
Local aTrfAux   := {}
Local nI        := 0
Local nPos      := 0
Local nTamAF9
Local nTrf      := 0
Local nDigitos  := 0
Local cOldNivelTrf := ""
Local cTrfIni   := ''
Local lNaoTemNumero := .T.
Local lAchou 	 := .F.
local nQtdNivel,nNewTrf,nPtoStart := 0
Local cNumero   := ""

DEFAULT lLiberaCod  := .T.
DEFAULT cTrfAtual   := ""

If cNivelTrf == NIL .OR. (ValType(cNivelTrf) == "C" .AND. Empty(cNivelTrf))
	dbSelectArea("AFC")
	aAreaAFC  := AFC->(GetArea())
	dbSetOrder(1)
	If MsSeek(xFilial("AFC")+cProjeto+cRevisa+cEDTPai,.F.)
		// deve obter o nivel da edt pai para ser utilizado na geracao do codigo da tarefa
		cNivelTrf := AFC->AFC_NIVEL
	Else
		cNivelTrf := ""
	EndIf
	RestArea(aAreaAFC)
EndIf

aAreaAFC  := AFC->(GetArea())

AF8->(dbSetOrder(1))
AF8->(MsSeek(xFilial()+cProjeto))

cDelim    := AllTrim(AF8->AF8_DELIM)
cMascara  := AllTrim(AF8->AF8_MASCAR)
If Empty(cMascara)
	cMascara := "111111111111111111"
EndIf
While lNaoTemNumero
	lZZ			:= .F.
	cNumero     := ""
	cTarefa   	:= ""
	cLastTrf  	:= ""
	cLastTrf2 	:= ""
	cTrfAux   	:= ""
	aTrfAux   	:= {}
	cOldNivelTrf:= cNivelTrf
	cTrfIni		:= ''
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a codificacao e normal ou estruturada.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
		Case Substr(cTrfAtual,1,3)=="ERR"
			cNumERR	:=	PMSGetLastErr(cProjeto,cRevisa)
			If Empty(cNumERR)
				cTarefa	:=	Soma1(cTrfAtual)
			Else
				cTarefa	:=	Soma1(cNumErr)
			Endif
			While  !MayIUseCode("AF9"+xFilial("AF9")+cProjeto+cRevisa+PadR(cTarefa,Len(AF9->AF9_TAREFA)))
				Leave1Code("AF9"+xFilial("AF9")+cProjeto+cRevisa+PadR(cTarefa,Len(AF9->AF9_TAREFA)))
				cTarefa	:=	Soma1(cTarefa)
			EndDo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Codificacao Estruturada.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case cTipo == "1"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Incrementa o nivel da tarefa.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cNivelTrf := StrZero(Val(cNivelTrf) + 1, TamSX3("AF9_NIVEL")[1])

			nDigitos:= Val(SubStr(cMascara,Val(cNivelTrf)-1,1))
			If (nDigitos > 0)
				cTrfIni 	:= IIf(cNivelTrf == "002",StrZero(1,nDigitos)    ,AllTrim(cEDTPai)+ cDelim + StrZero(1,nDigitos))
				cTrfIniQry	:= IIf(cNivelTrf == "002",StrZero(1,nDigitos)    ,AllTrim(cEDTPai)+ cDelim + Replicate(' ',nDigitos))
				cTrfFimQry	:= IIf(cNivelTrf == "002",Replicate("z",nDigitos),AllTrim(cEDTPai)+ cDelim + Replicate('z',nDigitos))
			Else
				cTrfIni 	:= IIf(cNivelTrf == "002","1",AllTrim(cEDTPai)+ cDelim + "1")
				cTrfIniQry	:= IIf(cNivelTrf == "002","1",AllTrim(cEDTPai)+ cDelim + " ")
				cTrfFimQry	:= IIf(cNivelTrf == "002","z",AllTrim(cEDTPai)+ cDelim + "z")
			EndIf

			If Empty(cTrfAtual)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Pesquisa todas as tarefas filhas.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cLastTrf :=	PMSPegaFilho(cProjeto,cRevisa, cEdtPai , cTrfIniQry , cTrfFimQry)
			Else
				cLastTrf := cTrfAtual
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Desmembra o codigo da ultima tarefa para facilitar a manipulcao dos dados.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPos:= 0
			nIni:= 1
			cLastTrf2 := cLastTrf
			For nI:= 1 To Len(Alltrim(cLastTrf))
				If !Empty(cDelim)
					cTrfAux:= Substr(cLastTrf2,nI,1)
				else
					cTrfAux:= Substr(cLastTrf2,nI,1)
				EndIf

				If !Empty(cTrfAux)
					aAdd(aTrfAux,cTrfAux)
				EndIf

			Next nI
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Realiza a analise dos niveis e compoe a numeracao da nova tarefa.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTrf:= Val(cNivelTrf) - 1
			nTamAF9 := TamSx3("AF9_TAREFA")[1]
			If Len(aTrfAux) == 0 .Or. (Len(aTrfAux) < Val(cNivelTrf) - 1)
				If (nDigitos > 0)
					cTarefa := IIf(cNivelTrf == "002",StrZero(1,nDigitos),AllTrim(cEDTPai)+ cDelim + StrZero(1,nDigitos))
				Else
					cTarefa := IIf(cNivelTrf == "002","1",AllTrim(cEDTPai)+ cDelim + "1")
					If (Len(cTarefa) > nTamAF9)
						cTarefa := Substr(cTarefa,1,(nTamAF9 - 1))+"1"
					EndIf
				EndIf
			Else
		      /////////////////////////////////////////////////////////////////////
				// Verifica quantos algaritimos tenho depois do ultimo delimitador //
		      /////////////////////////////////////////////////////////////////////

				ni:=Len(aTrfAux)
				While ni <> 0

					If !lAchou
						lAchou := (aTrfAux[ni] == cDelim )
					else
						Exit
					EndIf

					If !lAchou
						ni--
					EndIf

				Enddo
				lAchou := .F.
				nQtdNivel := Len(aTrfAux) - ni
				nPtoStart := ni + 1

				For nI:= nPtoStart To Len(aTrfAux)
					cNumero += aTrfAux[nI]
				Next nI

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se os ultimos caracteres sao numeros ou letras³
				//³para realizar a adicao correta.                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Len(aTrfAux) > 0 .And. aTrfAux[Len(aTrfAux)] == "9" .or. (cNumero == replicate( "Z" ,nQtdNivel))

					If lTipCode // Se .T. usa somente numeros, se .F. (padrao) usa alfanumericos p/ o novo codigo da tarefa

						If cNumero == replicate( "9" ,nQtdNivel)
							lZZ:= .T.
						Else
							nNewTrf := Val(cNumero) + 1
							cLastTrf2 := StrZero(nNewTrf,nQtdNivel)

							// Atualiza o numero da proxima tarefa
							nPos := 1
							For nI:=nPtoStart To Len(aTrfAux)

								cTrfAux:= Substr(cLastTrf2,nPos,1)

								If !Empty(cTrfAux)
									aTrfAux[nI] := cTrfAux
								EndIf

								nPos++
							Next nI
						EndIf

					Else

					   //Se alcacou o limite de tarefas
						If cNumero == replicate( "Z" ,nQtdNivel)
							lZZ:= .T.
						Else
						   // Caso seja alfanumerico
							aTrfAux[Len(aTrfAux)] := Soma1(Alltrim( aTrfAux[Len(aTrfAux)] ))
						EndIf

					EndIf

					For nI:= 1 To Len(aTrfAux)
						cTarefa += aTrfAux[nI]
					Next nI

				Else

		   		aTrfAux[Len(aTrfAux)]:= Soma1(cNumero)


					For nI:= 1 To (nPtoStart-1)
						cTarefa += aTrfAux[nI]
					Next nI
					cTarefa += Alltrim( aTrfAux[Len(aTrfAux)] 	)

				EndIf
		EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se a numeracao ja existe ou se existe inconsistencia ³
			//³com relacao ao tamanho da nova numeracao e o tamanho do campo.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("AF9")
			AF9->(dbSetOrder(1))
			dbSelectArea("AFC")
			AFC->(dbSetOrder(1))

			//Se coicide com o codigo do projeto, incrementar um
			If	AFC->(MsSeek(xFilial("AFC") + cProjeto + cRevisa + cTarefa + Space(Len(AFC->AFC_EDT)-Len(cTarefa)))) .And. AFC->AFC_NIVEL == "001"
				cTarefa := Soma1(Alltrim(cTarefa))
			Endif

			If Len(cTarefa) > Len(AF9->AF9_TAREFA) .OR. ( AllTrim(cTrfAtual) == AllTrim(cTarefa) ) .Or. lZZ
				cNumERR	:=	PMSGetLastErr(cProjeto,cRevisa)
				If Empty(cNumERR)
					cTarefa := "ERR" + StrZero(1,Len(AF9->AF9_TAREFA)-3)
				Else
					cTarefa	:=	Soma1(Alltrim(cNumErr))
				Endif
				While  !MayIUseCode("AF9"+xFilial("AF9")+cProjeto+cRevisa+PadR(cTarefa,Len(AF9->AF9_TAREFA)))
					Leave1Code("AF9"+xFilial("AF9")+cProjeto+cRevisa+PadR(cTarefa,Len(AF9->AF9_TAREFA)))
					cTarefa	:=	Soma1(cTarefa)
				Enddo
			EndIf


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Codificacao Sequencial Nao Estruturada.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case cTipo == "2"
			If empty(cTrfAtual)
				dbSelectArea("AF9")
				dbSetOrder(1)
				MsSeek(xFilial("AF9")+cProjeto+cRevisa+Replicate("Z",Len(AFC->AFC_EDT)),.T.)
				dbSkip(-1)

				If (xFilial("AF9") + cProjeto + cRevisa == AF9->AF9_FILIAL + AF9->AF9_PROJET + AF9->AF9_REVISA) .And. (AF9->AF9_NIVEL <> "001")
					cTarefa := Soma1(Alltrim(AF9->AF9_TAREFA))
				Else
					cTarefa := StrZero(1,Len(AFC->AFC_EDT))
				EndIf

				dbSelectArea("AFC")
				dbSetOrder(1)
				MsSeek(xFilial("AFC")+cProjeto+cRevisa+Replicate("Z",Len(AFC->AFC_EDT)),.T.)
				dbSkip(-2) // Pula o Nivel 002

				If (xFilial("AFC") + cProjeto + cRevisa == AFC->AFC_FILIAL + AFC->AFC_PROJET + AFC->AFC_REVISA) .And. (AFC->AFC_NIVEL <> "001")
					cTarefa := If(Soma1(Alltrim(AFC->AFC_EDT))>cTarefa,Soma1(Alltrim(AFC->AFC_EDT)),cTarefa)
				Else
					cTarefa := If(StrZero(1,LEN(AFC->AFC_EDT))>cTarefa,StrZero(1,LEN(AFC->AFC_EDT)),cTarefa)
				EndIf
			Else
				cTarefa := Soma1(Alltrim(cTrfAtual))
			EndIf

			While AFC->(MsSeek(xFilial("AFC")+cProjeto+cRevisa+cTarefa)) .Or. AF9->(MsSeek(xFilial("AF9")+cProjeto+cRevisa+cTarefa))
				If AFC->(!Eof())
					cTarefa := Soma1(Alltrim(AFC->AFC_EDT))
				Else
					cTarefa := Soma1(Alltrim(AF9->AF9_TAREFA))
				EndIf
			End
	EndCase
	//
	// Verifica se o codigo gerado da tarefa esta sendo utilizado,
	// em caso positivo gera um novo codigo.
	// obs.: deve ser utiliza a string "AFC" pra chave. Pois para gerar o codigo da edt
	//       ou tarefa depende sempre das tabelas AFC e AF9. Evitando a duplicidade de chave.
	//
	dbSelectArea("AF9")
	dbSetOrder(1)
	dbSelectArea("AFC")
	dbSetOrder(1)
	If AFC->(MsSeek(xFilial("AFC")+cProjeto+cRevisa+PadR(cTarefa,Len(AFC->AFC_EDT)))) .Or. AF9->(MsSeek(xFilial("AF9")+cProjeto+cRevisa+PadR(cTarefa,Len(AF9->AF9_TAREFA))))  .Or. !MayIUseCode("AF9"+xFilial("AF9")+cProjeto+cRevisa+PadR(cTarefa,Len(AF9->AF9_TAREFA)))
		If Substr(cTarefa,1,3)== "ERR"
			Leave1Code("AF9"+xFilial("AF9")+cProjeto+cRevisa+PadR(cTarefa,Len(AF9->AF9_TAREFA)))
		Endif
		cTrfAtual	:=	cTarefa
		cNivelTrf	:= cOldNivelTrf
	Else
		//Garantir que nao foi gravado o numero no AFC e no AF9
		If AFC->(MsSeek(xFilial("AFC")+cProjeto+cRevisa+PadR(cTarefa,Len(AFC->AFC_EDT)))) .Or.;
			AF9->(MsSeek(xFilial("AF9")+cProjeto+cRevisa+PadR(cTarefa,Len(AF9->AF9_TAREFA))))
			Leave1Code("AF9"+xFilial("AF9")+cProjeto+cRevisa+PadR(cTarefa,Len(AF9->AF9_TAREFA)))
			cTrfAtual	:=	cTarefa
			cNivelTrf	:= cOldNivelTrf
		Else
			lNaoTemNumero	:=	.F.
		Endif
	EndIf
EndDo

If ExistBlock("PMSNUMAF9")
	cTarefa := ExecBlock("PMSNUMAF9",.F.,.F.,{cTarefa,cProjeto,cRevisa,cOldNivelTrf,cEDTPai,lLiberaCod})
EndIf
//
// Ponto de entrada criado devido ao problema do ponto acima ultrapassar os 10 caracteres,
// isto é: U_PMSNUMAF9 vai ser considerado somente pelo compilador como U_PMSNUMAF
//
If ExistBlock("PMSNOAF9")
	cTarefa := ExecBlock("PMSNOAF9",.F.,.F.,{cTarefa,cProjeto,cRevisa,cOldNivelTrf,cEDTPai,lLiberaCod})
EndIf

If lLiberaCod
	FreeUsedCode(.T.)
Endif

RestArea(aAreaAF8)
RestArea(aAreaAFC)
RestArea(aAreaAF9)
RestArea(aArea)
Return cTarefa

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MaExclAF1  ³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a exclusao de um Orcamento.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : Codigo do Orcamento                                   ³±±
±±³          ³ExpN2 : RecNo do Orcam. ( Opcional )                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MaExclAF1(cOrcamento,nRecAF1)

Local aArea	:= GetArea()
Local aAreaAF2	:= AF2->(GetArea())
Local aAreaAF3	:= AF3->(GetArea())
Local aAreaAF4	:= AF4->(GetArea())
Local aAreaAF5	:= AF5->(GetArea())
Local aAreaAF7	:= AF7->(GetArea())
Local lContinua	:= .T.


If nRecAF1<>Nil
	dbSelectArea("AF1")
	dbGoto(nRecAF1)
	cOrcamento	:= AF1->AF1_ORCAME
Else
	dbSelectArea("AF1")
	dbSetOrder(1)
	lContinua	:= MsSeek(xFilial()+cOrcamento)
	nRecAF1		:= RecNo()
EndIf

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros nas EDTs                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AF5")
	dbSetOrder(1)
	MsSeek(xFilial()+cOrcamento)
	While !Eof() .And. xFilial("AF5")+cOrcamento==;
		AF5->AF5_FILIAL+AF5->AF5_ORCAME
		MaExclAF5(,,AF5->(RecNo()))
		dbSkip()
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui o refistro do AF1                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AF1")
	dbGoto(nRecAF1)
	RecLock("AF1",.F.,.T.)
	dbDelete()
	MsUnlock()
EndIf

RestArea(aAreaAF2)
RestArea(aAreaAF3)
RestArea(aAreaAF4)
RestArea(aAreaAF5)
RestArea(aAreaAF7)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MaDelAF9³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a exclusao de uma Tarefa do Projeto.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : Codigo do Projeto                                     ³±±
±±³          ³ExpC2 : Codigo da Tarefa                                      ³±±
±±³          ³ExpN3 : RecNo da Tarefa ( Opcional )                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MaDelAF9(cProjeto,cRevisao,cTarefa,nRecAF9,lAtuEDT)

DEFAULT lAtuEDT := .T.

If lAtuEDT
	Processa({|| AuxDelAF9(cProjeto,cRevisao,cTarefa,nRecAF9,lAtuEDT)},"Excluindo a Tarefa")
Else
	AuxDelAF9(cProjeto,cRevisao,cTarefa,nRecAF9,lAtuEDT)
EndIf

Return 


Function AuxDelAF9(cProjeto,cRevisao,cTarefa,nRecAF9,lAtuEDT)

Local aArea		:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAFA	:= AFA->(GetArea())
Local aAreaAFB	:= AFB->(GetArea())
Local aAreaAFC	:= AFC->(GetArea())
Local aAreaAFD	:= AFD->(GetArea())
Local aAJOArea	:= {}
Local aAreaAEL
Local lContinua	:= .T.
Local cEDTPai
Local cInsumo		:= ""
Local cCompAux	:= ""
Local lUsaAJT		:= .F.
Local lExistAN9	:= .T.

Default lAtuEDT := .T.

If nRecAF9<>Nil
	dbSelectArea("AF9")
	dbGoto(nRecAF9)
	cProjeto	:= AF9->AF9_PROJET
	cRevisao	:= AF9->AF9_REVISA
	cTarefa		:= AF9->AF9_TAREFA
Else
	dbSelectArea("AF9")
	dbSetOrder(1)
	lContinua	:= MsSeek(xFilial("AF9")+cProjeto+cRevisao+cTarefa)
	nRecAF9		:= AF9->( RecNo() )
EndIf

If lExistAN9
	DbSelectArea("AN9")
	AN9->(DbSetOrder(1))
EndIf

lUsaAJT	:= AF8ComAJT( cProjeto )

If lContinua

	ProcRegua(28)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui as tabelas conforme o projeto se ele usa composicao aux   ou nao.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lUsaAJT
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a existencia de registros no AFA e efetua a exclusao   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AFA")
		dbSetOrder(1)
		MsSeek(xFilial("AFA")+cProjeto+cRevisao+cTarefa)
		While !Eof() .And. xFilial("AFA")+cProjeto+cRevisao+cTarefa==;
			AFA->AFA_FILIAL+AFA->AFA_PROJET+AFA->AFA_REVISA+AFA->AFA_TAREFA
			PmsAvalAFA("AFA",2)
			PmsAvalAFA("AFA",3)
			RecLock("AFA",.F.,.T.)
			dbDelete()
			MsUnlock()
			dbSkip()
		EndDo

		IncProc()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a existencia de registros no AFB e efetua a exclusao   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AFB")
		dbSetOrder(1)
		MsSeek(xFilial("AFB")+cProjeto+cRevisao+cTarefa)
		While !Eof() .And. xFilial("AFB")+cProjeto+cRevisao+cTarefa==;
			AFB->AFB_FILIAL+AFB->AFB_PROJET+AFB->AFB_REVISA+AFB->AFB_TAREFA
			RecLock("AFB",.F.,.T.)
			dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a existencia de registros no AEL e efetua a exclusao   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea( "AEL" )
		AEL->( DbSetOrder( 1 ) )
		AEL->( DbSeek( xFilial( "AEL" ) + cProjeto + cRevisao + cTarefa ) )
		While AEL->( !Eof() ) .AND. xFilial( "AEL" ) + cProjeto + cRevisao + cTarefa == AEL->( AEL_FILIAL + AEL_PROJET + AEL_REVISA + AEL_TAREFA )
			cInsumo	:= AEL->AEL_INSUMO

			RecLock( "AEL" )
			AEL->( DbDelete() )
			AEL->( MsUnlock() )

			// Verifica e exclui o insumo se nao estiver sendo usado no
			// projeto ou em alguma estrutura
			aAreaAEL := AEL->( GetArea() )
			If !PA204UsaInsumo( cProjeto, cRevisa, cInsumo, .F. )
				PA204Exc( cProjeto, cRevisa, cInsumo, .T. )
			EndIf
			RestArea( aAreaAEL )

			AEL->( DbSkip() )
		End

		IncProc()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a existencia de registros no AFB e efetua a exclusao   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea( "AFB" )
		dbSetOrder( 1 )
		MsSeek( xFilial( "AFB" ) + cProjeto + cRevisao + cTarefa )
		While !Eof() .And. xFilial( "AFB" ) + cProjeto + cRevisao + cTarefa == AFB->( AFB_FILIAL + AFB_PROJET + AFB_REVISA + AFB_TAREFA )
			RecLock("AFB",.F.,.T.)
			dbDelete()
			MsUnlock()

			dbSkip()
		End

		IncProc()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a existencia de registros no AEN e efetua a exclusao   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea( "AEN" )
		AEN->( DbSetOrder( 1 ) )
		AEN->( DbSeek( xFilial( "AEN" ) + cProjeto + cRevisao + cTarefa ) )
		While AEN->( !Eof() ) .AND. xFilial( "AEN" ) + cProjeto + cRevisao + cTarefa == AEN->( AEN_FILIAL + AEN_PROJET + AEN_REVISA + AEN_TAREFA )
			PmsAvalAEN(AEN->AEN_SUBCOM, 3)
			RecLock( "AEN", .F., .T. )
			AEN->( DbDelete() )
			AEN->( MsUnlock() )

			AEN->( DbSkip() )
		End
	EndIf

	IncProc()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AFD e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFD")
	dbSetOrder(1)
	MsSeek(xFilial("AFD")+cProjeto+cRevisao+cTarefa)
	While !Eof() .And. xFilial("AFD")+cProjeto+cRevisao+cTarefa==;
		AFD->AFD_FILIAL+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_TAREFA
		RecLock("AFD",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo

	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AFD e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFD")
	dbSetOrder(2)
	MsSeek(xFilial("AFD")+cProjeto+cRevisao+cTarefa)
	While !Eof() .And. xFilial("AFD")+cProjeto+cRevisao+cTarefa==;
		AFD->AFD_FILIAL+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_PREDEC
		RecLock("AFD",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo

	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AEF e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AEF")
	dbSetOrder(1)
	MsSeek(xFilial("AEF")+cProjeto+cRevisao+cTarefa)
	While !Eof() .And. xFilial("AEF")+cProjeto+cRevisao+cTarefa==;
		AEF->AEF_FILIAL+AEF->AEF_PROJET+AEF->AEF_REVISA+AEF->AEF_TAREFA
		RecLock("AEF",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo

	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AFG e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFG")
	dbSetOrder(1)
	MsSeek(xFilial("AFG")+cProjeto+cRevisao+cTarefa)
	While !Eof() .And. xFilial("AFG")+cProjeto+cRevisao+cTarefa==;
		AFG->AFG_FILIAL+AFG->AFG_PROJET+AFG->AFG_REVISA+AFG->AFG_TAREFA
		PmsAvalAFG("AFG",2)
		PmsAvalAFG("AFG",3)
		dbSelectArea("AFG")
		dbSkip()
	EndDo

	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AFM e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFM")
	dbSetOrder(1)
	MsSeek(xFilial("AFM")+cProjeto+cRevisao+cTarefa)
	While !Eof() .And. xFilial("AFM")+cProjeto+cRevisao+cTarefa==;
		AFM->AFM_FILIAL+AFM->AFM_PROJET+AFM->AFM_REVISA+AFM->AFM_TAREFA
		PmsAvalAFM("AFM",2)
		PmsAvalAFM("AFM",3)
		dbSelectArea("AFM")
		dbSkip()
	EndDo

	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AFH e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFH")
	dbSetOrder(1)
	MsSeek(xFilial("AFH")+cProjeto+cRevisao+cTarefa)
	While !Eof() .And. xFilial("AFH")+cProjeto+cRevisao+cTarefa==;
		AFH->AFH_FILIAL+AFH->AFH_PROJET+AFH->AFH_REVISA+AFH->AFH_TAREFA
		RecLock("AFH",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSelectArea("AFH")
		dbSkip()
	EndDo

	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AFL e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFL")
	dbSetOrder(1)
	MsSeek(xFilial("AFL")+cProjeto+cRevisao+cTarefa)
	While !Eof() .And. xFilial("AFL")+cProjeto+cRevisao+cTarefa==;
		AFL->AFL_FILIAL+AFL->AFL_PROJET+AFL->AFL_REVISA+AFL->AFL_TAREFA
		PmsAvalAFL("AFL",2)
		PmsAvalAFL("AFL",3)
		dbSelectArea("AFL")
		dbSkip()
	EndDo

	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AFR e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFR")
	dbSetOrder(1)
	MsSeek(xFilial("AFR")+cProjeto+cRevisao+cTarefa)
	While !Eof() .And. xFilial("AFR")+cProjeto+cRevisao+cTarefa==;
		AFR->AFR_FILIAL+AFR->AFR_PROJET+AFR->AFR_REVISA+AFR->AFR_TAREFA
		RecLock("AFR",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo

	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AFS e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFS")
	dbSetOrder(1)
	MsSeek(xFilial("AFS")+cProjeto+cRevisao+cTarefa)
	While !Eof() .And. xFilial("AFS")+cProjeto+cRevisao+cTarefa==;
		AFS->AFS_FILIAL+AFS->AFS_PROJET+AFS->AFS_REVISA+AFS->AFS_TAREFA
		RecLock("AFS",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo

	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AFP e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFP")
	dbSetOrder(1)
	MsSeek(xFilial("AFP")+cProjeto+cRevisao+cTarefa)
	While !Eof() .And. xFilial("AFP")+cProjeto+cRevisao+cTarefa==;
		AFP->AFP_FILIAL+AFP->AFP_PROJET+AFP->AFP_REVISA+AFP->AFP_TAREFA
		RecLock("AFP",.F.,.T.)
		PMSAvalAFP("AFP",3)
		dbDelete()
		MsUnlock()
		dbSelectArea("AFP")
		dbSkip()
	EndDo

	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AFT e efetua a exclusao   ³
	//³                                                                 ³
	//³ ATENCAO!!! Executada sempre apos a tabela AFP                   ³
	//³                                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFT")
	dbSetOrder(1)
	MsSeek(xFilial("AFT")+cProjeto+cRevisao+cTarefa)
	While !Eof() .And. xFilial("AFT")+cProjeto+cRevisao+cTarefa==;
		AFT->AFT_FILIAL+AFT->AFT_PROJET+AFT->AFT_REVISA+AFT->AFT_TAREFA
		RecLock("AFT",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo

	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AFU e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFU")
	dbSetOrder(1)
	MsSeek(xFilial("AFU")+"1"+cProjeto+cRevisao+cTarefa)
	While !Eof() .And. xFilial("AFU")+"1"+cProjeto+cRevisao+cTarefa==;
		AFU->AFU_FILIAL+AFU->AFU_CTRRVS+AFU->AFU_PROJET+AFU->AFU_REVISA+AFU->AFU_TAREFA
		RecLock("AFU",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo

	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AFU e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFU")
	dbSetOrder(1)
	MsSeek(xFilial("AFU")+"2"+cProjeto+cRevisao+cTarefa)
	While !Eof() .And. xFilial("AFU")+"2"+cProjeto+cRevisao+cTarefa==;
		AFU->AFU_FILIAL+AFU->AFU_CTRRVS+AFU->AFU_PROJET+AFU->AFU_REVISA+AFU->AFU_TAREFA
		RecLock("AFU",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo

	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AN2 e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AN2")
	dbSetOrder(1)
	MsSeek(xFilial("AN2")+"1"+cProjeto+cRevisao+cTarefa)
	While !Eof() .And. xFilial("AN2")+"1"+cProjeto+cRevisao+cTarefa==;
		AN2->AN2_FILIAL+AN2->AN2_CTRRVS+AN2->AN2_PROJET+AN2->AN2_REVISA+AN2->AN2_TAREFA
		RecLock("AN2",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo


	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AN2 e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AN2")
	dbSetOrder(1)
	MsSeek(xFilial("AN2")+"2"+cProjeto+cRevisao+cTarefa)
	While !Eof() .And. xFilial("AN2")+"2"+cProjeto+cRevisao+cTarefa==;
		AN2->AN2_FILIAL+AN2->AN2_CTRRVS+AN2->AN2_PROJET+AN2->AN2_REVISA+AN2->AN2_TAREFA
		RecLock("AN2",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo


	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AJC e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AJC")
	dbSetOrder(1)
	MsSeek(xFilial("AJC")+"1"+cProjeto+cRevisao+cTarefa)
	While !Eof() .And. xFilial("AJC")+"1"+cProjeto+cRevisao+cTarefa==;
		AJC->AJC_FILIAL+AJC->AJC_CTRRVS+AJC->AJC_PROJET+AJC->AJC_REVISA+AJC->AJC_TAREFA
		RecLock("AJC",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo

	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AJC e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AJC")
	dbSetOrder(1)
	MsSeek(xFilial("AJC")+"2"+cProjeto+cRevisao+cTarefa)
	While !Eof() .And. xFilial("AJC")+"2"+cProjeto+cRevisao+cTarefa==;
		AJC->AJC_FILIAL+AJC->AJC_CTRRVS+AJC->AJC_PROJET+AJC->AJC_REVISA+AJC->AJC_TAREFA
		RecLock("AJC",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo

	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AFV e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFV")
	dbSetOrder(1)
	MsSeek(xFilial("AFV")+cProjeto+cRevisao+cTarefa)
	While !Eof() .And. xFilial("AFV")+cProjeto+cRevisao+cTarefa==;
		AFV->AFV_FILIAL+AFV->AFV_PROJET+AFV->AFV_REVISA+AFV->AFV_TAREFA
		RecLock("AFV",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo

	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AFV e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFV")
	dbSetOrder(1)
	MsSeek(xFilial("AFV")+cProjeto+SPACE(LEN(AFV->AFV_REVISA))+cTarefa)
	While !Eof() .And. xFilial("AFV")+cProjeto+SPACE(LEN(AFV->AFV_REVISA))+cTarefa==;
		AFV->AFV_FILIAL+AFV->AFV_PROJET+AFV->AFV_REVISA+AFV->AFV_TAREFA
		RecLock("AFV",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo

	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AFN e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFN")
	dbSetOrder(1)
	MsSeek(xFilial("AFN")+cProjeto+cRevisao+cTarefa)
	While !Eof() .And. xFilial("AFN")+cProjeto+cRevisao+cTarefa==;
		AFN->AFN_FILIAL+AFN->AFN_PROJET+AFN->AFN_REVISA+AFN->AFN_TAREFA
		PmsAvalAFN("AFN",2,.F.)
		PmsAvalAFN("AFN",3,.F.)
		dbSelectArea("AFN")
		dbSkip()
	EndDo

	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AFI e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFI")
	dbSetOrder(1)
	MsSeek(xFilial("AFI")+cProjeto+cRevisao+cTarefa)
	While !Eof() .And. xFilial("AFI")+cProjeto+cRevisao+cTarefa==;
		AFI->AFI_FILIAL+AFI->AFI_PROJET+AFI->AFI_REVISA+AFI->AFI_TAREFA
		PmsAvalAFI("AFI",2)
		PmsAvalAFI("AFI",3)
		dbSelectArea("AFI")
		dbSkip()
	EndDo

	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AFJ e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFJ")
	dbSetOrder(1)
	MsSeek(xFilial("AFJ")+cProjeto+cTarefa)
	While !Eof() .And. xFilial("AFJ")+cProjeto+cTarefa==;
		AFJ->AFJ_FILIAL+AFJ->AFJ_PROJET+AFJ->AFJ_TAREFA
		RecLock("AFJ",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSelectArea("AFJ")
		dbSkip()
	EndDo

	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AFF e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFF")
	dbSetOrder(1)
	MsSeek(xFilial("AFF")+cProjeto+cRevisao+cTarefa)
	While !Eof() .And. xFilial("AF9")+cProjeto+cRevisao+cTarefa==;
		AFF->AFF_FILIAL+AFF->AFF_PROJET+AFF->AFF_REVISA+AFF->AFF_TAREFA
		RecLock("AFF",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo

	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no SC6 e efetua a Alteracao  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC6")
	dbSetOrder(8)
	MsSeek(xFilial("SC6")+cProjeto+cTarefa)
	While !Eof() .And. xFilial("SC6")+cProjeto+cTarefa==;
		SC6->C6_FILIAL+SC6->C6_PROJPMS+SC6->C6_TASKPMS
		RecLock("SC6",.F.)
		SC6->C6_PROJPMS := ""
		SC6->C6_TASKPMS := ""
		MsUnlock()
		dbSelectArea("SC9")
		dbSetOrder(1)
		MsSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM)
		While !Eof() .And. xFilial()+SC6->C6_NUM+SC6->C6_ITEM==SC9->C9_PEDIDO+SC9->C9_ITEM
			RecLock("SC9",.F.)
			SC9->C9_PROJPMS := ""
			SC9->C9_TASKPMS := ""
			SC9->C9_TRT  := ""
			MsUnlock()
			dbSelectArea("SC9")
			dbSkip()
		End
		dbSelectArea("SC6")
		dbSkip()
	EndDo

	IncProc()
	If PmsChkAJE(.F.)
		SE5->(dbSetOrder(9))
		dbSelectArea("AJE")
		dbSetOrder(1)
		MsSeek(xFilial("AJE")+cProjeto+cRevisao+cTarefa,.T.)
		While !Eof().And.AJE_FILIAL+AJE_PROJET+AJE_REVISA+AJE_TAREFA==;
			xFilial("AJE")+cProjeto+cRevisao+cTarefa
			If SE5->(dbSeek(PmsFilial("SE5","AJE")+AJE->AJE_ID))
				RecLock("SE5",.F.)
				SE5->E5_PROJPMS := ""
				SE5->E5_TASKPMS	:= ""
				MsUnlock()
			EndIf
			RecLock("AJE",.F.,.T.)
			dbDelete()
			MsUnlock()
			AJE->(dbSkip())
		EndDo
	Else
		dbSelectArea("SE5")
		dbSetOrder(9)
		MsSeek(xFilial("SE5")+cProjeto+SPACE(LEN(SE5->E5_EDTPMS))+cTarefa)
		While !Eof() .And. SE5->E5_FILIAL+SE5->E5_PROJPMS+SE5->E5_EDTPMS+SE5->E5_TASKPMS == xFilial("SE5")+cProjeto+SPACE(LEN(SE5->E5_EDTPMS))+cTarefa
			RecLock("SE5",.F.)
			SE5->E5_PROJPMS := ""
			SE5->E5_TASKPMS	:= ""
			MsUnlock()
			dbSelectArea("SE5")
			dbSkip()
		End
	EndIf

	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AFZ e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFZ")
	dbSetOrder(1)
	MsSeek(xFilial("AFZ")+cProjeto+cRevisao+cTarefa)
	While !Eof() .And. xFilial("AFZ")+cProjeto+cRevisao+cTarefa==;
		AFZ->AFZ_FILIAL+AFZ->AFZ_PROJET+AFZ->AFZ_REVISA+AFZ->AFZ_TAREFA
		RecLock("AFZ",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo

	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AJ4 e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AJ4")
	dbSetOrder(1)
	MsSeek(xFilial("AJ4")+cProjeto+cRevisao+cTarefa)
	While !Eof() .And. xFilial("AJ4")+cProjeto+cRevisao+cTarefa==;
		AJ4->AJ4_FILIAL+AJ4->AJ4_PROJET+AJ4->AJ4_REVISA+AJ4->AJ4_TAREFA
		RecLock("AJ4",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo

	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AJO e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AJO")
	aAJOArea := AJO->(GetArea())
	dbSetOrder(1)
	MsSeek(xFilial("AJO")+cProjeto+cRevisao+cTarefa)
	While !Eof() .And. xFilial("AJO")+cProjeto+cRevisao+cTarefa==;
		AJO->AJO_FILIAL+AJO->AJO_PROJET+AJO->AJO_REVISA+AJO->AJO_TAREFA
		RecLock("AJO",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo
	RestArea(aAJOArea)


    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros na AN9 e efetua a exclusao	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lExistAN9
		MaDelAN9(cProjeto,AFE->AFE_REVISA,cTarefa)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso utilize composição aux   efetua a exclusão dos dados³
	//³referentes a composição aux do projeto/tarefa            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If AF8ComAJT( cProjeto )
		PMSDelAJT( cProjeto, cTarefa )
	EndIf


	If ExistBlock("PMSDEAF9")
		ExecBLock("PMSDEAF9",.F.,.F.,{cProjeto,cRevisao,cTarefa})
	EndIf

	If ExistTemplate("PMSDelAF9")
		ExecTemplate("PMSDelAF9",.F.,.F.,{cProjeto,cRevisao,cTarefa})
	EndIf

	IncProc()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui o registro do AF9                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FkCommit()
	dbSelectArea("AF9")
	dbGoto(nRecAF9)
	cProjeto	:= AF9->AF9_PROJET
	cRevisa	:= AF9->AF9_REVISA
	cEDTPai	:= AF9->AF9_EDTPAI
	cCompAux	:= AF9->AF9_COMPUN
	RecLock("AF9",.F.,.T.)
	dbDelete()
	MsUnlock()

	// Verifica e exclui a composicao se nao estiver sendo usado no
	// projeto ou em alguma estrutura
	If AF8ComAjt(cProjeto)
		If PMSA205Del( cCompAux, cProjeto, cRevisa, .F. )
			DbSelectArea( "AJT" )
			DbSetOrder( 2 )
			If AJT->( DbSeek( xFilial( "AJT" ) + cProjeto + cRevisa + cCompAux ) )
				a205Grava( .T., AJT->( RecNo() ), cProjeto, cRevisa, cCompAux )
			EndIf
		EndIf
	EndIf

	IncProc()

	If lAtuEDT
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa o recalculo das datas previstas da EDT          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PmsAtuEDT(cProjeto,cRevisa,cEDTPai)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa o recalculo dos percentuais executados da EDT   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PMSEdtReal(cProjeto, cRevisa, cEDTPai)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa o recalculo do custo das tarefas e edt.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PmsAF9CusEDT(cProjeto,cRevisa,cEDTPai)
	EndIf

	IncProc()
EndIf

RestArea(aAreaAF9)
RestArea(aAreaAFA)
RestArea(aAreaAFB)
RestArea(aAreaAFC)
RestArea(aAreaAFD)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MaDelAF8³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a exclusao de um Projeto.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : Codigo do Projeto                                     ³±±
±±³          ³ExpN2 : RecNo do Projeto( Opcional )                          ³±±
±±³          ³ExpC3 : Versao simulada ou antiga especifica a ser deletada   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MaDelAF8(cProjeto,nRecAF8,cRevisa)

Local aArea	:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAFA	:= AFA->(GetArea())
Local aAreaAFB	:= AFB->(GetArea())
Local aAreaAFC	:= AFC->(GetArea())
Local aAreaAFD	:= AFD->(GetArea())
Local lContinua	:= .T.
Local lExistAN9 := .T.
Local lExistANE := .T.

If nRecAF8<>Nil
	dbSelectArea("AF8")
	dbGoto(nRecAF8)
	cProjeto	:= AF8->AF8_PROJET
Else
	dbSelectArea("AF8")
	dbSetOrder(1)
	lContinua	:= MsSeek(xFilial()+cProjeto)
	nRecAF8		:= RecNo()
EndIf

If lExistAN9
	DbSelectArea("AN9")
	AN9->(DbSetOrder(1))
EndIf

If lContinua

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica existencia de amarracao do projeto com documentos             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PMSAVALDOC("AF8", nRecAF8)

	dbSelectArea("AFE")
	dbSetOrder(1)
	MsSeek(xFilial("AFE")+cProjeto)
	BEGIN TRANSACTION
	While !Eof() .And. xFilial("AFE")+cProjeto==AFE->AFE_FILIAL+AFE->AFE_PROJET
		If cRevisa==Nil .Or. (cRevisa<>Nil .And. AFE->AFE_REVISA == cRevisa)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica a existencia de registros no AFC e efetua a exclusao   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("AFC")
			dbSetOrder(2)
			MsSeek(xFilial()+cProjeto+AFE->AFE_REVISA)
			While !Eof() .And. xFilial("AFC")+cProjeto+AFE->AFE_REVISA==;
				AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA
				MaDelAFC(,,,AFC->(RecNo()),.F.)
				dbSkip()
			EndDo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui o registro do AJB                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("AJB")
			dbSetOrder(1)
			If MsSeek(xFilial("AJB")+cProjeto+AFE->AFE_REVISA)
				RecLock("AJB",.F.,.T.)
				dbDelete()
				MsUnlock()
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica a existencia de registros na AN9 e efetua a exclusao	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lExistAN9
				MaDelAN9(cProjeto,AFE->AFE_REVISA,)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui o registro do AFE                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("AFE")
			RecLock("AFE",.F.,.T.)
			dbDelete()
			MsUnlock()

		EndIf
		dbSkip()
	End

	END TRANSACTION

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso utilize composição aux   efetua a exclusão dos dados³
	//³referentes a composição aux do projeto                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If AF8ComAJT(cProjeto)
		PMSDelAJT( cProjeto, cRevisa )
	EndIf

	If lExistANE
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a existencia de registros no ANE e efetua a exclusao   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("ANE")
		dbSetOrder(1)
		MsSeek(xFilial("ANE")+cProjeto+AF8->AF8_REVISA)
		While !Eof() .And. xFilial("ANE")+cProjeto+AF8->AF8_REVISA==;
			ANE->(ANE_FILIAL+ANE_PROJET+ANE_REVISA)

			RecLock("ANE",.F.,.T.)
			dbDelete()
			MsUnlock()

			dbSkip()
		EndDo
	Endif

	If cRevisa==Nil

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a existencia de registros na AN9 e efetua a exclusao	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lExistAN9
			dbSelectArea("AFC")
			dbSetOrder(1)
			AFC->(MsSeek(xFilial("AFC")+cProjeto))
			MaDelAN9(cProjeto, AFC->AFC_REVISA,)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui o registro do AF8                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AF8")
		dbGoto(nRecAF8)
		RecLock("AF8",.F.,.T.)
		dbDelete()
		MsUnlock()
	EndIf
EndIf

MsUnlockAll()

RestArea(aAreaAF9)
RestArea(aAreaAFA)
RestArea(aAreaAFB)
RestArea(aAreaAFC)
RestArea(aAreaAFD)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MaDelAN9³ Autor ³ William Pires           ³ Data ³ 07-07-2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a exclusao dos impostos das tarefas                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : Codigo do Projeto                                     ³±±
±±³          ³ExpC2 : Codigo da versao do projeto                      		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MaDelAN9(cProjeto,cRevisa,cTarefa)

Default cProjeto := ""
Default cRevisa  := ""
Default cTarefa	 := ""	//preenchido na funcao AuxDelAF9

If AN9->(MsSeek(xFilial("AN9")+cProjeto+cRevisa+cTarefa))
	Do While AN9->(!Eof()) .And. AllTrim(AN9->(AN9_FILIAL+AN9_PROJET+AN9_REVISA+cTarefa)) == AllTrim(xFilial("AN9")+cProjeto+cRevisa+cTarefa)
		RecLock("AN9",.F.,.T.)
		DbDelete()
		MsUnlock()
		AN9->(DbSkip())
	EndDo
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MaDelAFC³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a exclusao de uma EDT do Projeto.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : Codigo do Projeto                                     ³±±
±±³          ³ExpC2 : Codigo da EDT                                         ³±±
±±³          ³ExpN3 : RecNo da EDT    ( Opcional )                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MaDelAFC(cProjeto,cRevisao,cEDT,nRecAFC,lAtuEDT)
DEFAULT lAtuEDT := .F.

	If lAtuEDT 
		MSAguarde( {||AuxDelAFC(cProjeto,cRevisao,cEDT,nRecAFC,lAtuEDT)}, "Excluindo a EDT")
	Else
		AuxDelAFC(cProjeto,cRevisao,cEDT,nRecAFC,lAtuEDT)
	EndIf
	 
Return

Static Function AuxDelAFC(cProjeto,cRevisao,cEDT,nRecAFC,lAtuEDT)
Local aArea		:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAFA	:= AFA->(GetArea())
Local aAreaAFB	:= AFB->(GetArea())
Local aAreaAFC	:= AFC->(GetArea())
Local aAreaAFD	:= AFD->(GetArea())
Local lContinua	:= .T.
Local cEDTPai		:= ""
Local cFilAFC		:= xFilial("AFC")
Local cFilAF9		:= xFilial("AF9")
Local cFilAFQ		:= xFilial("AFQ")
Local cFilAFX		:= xFilial("AFX")
Local aAtuEDT		:= {}
Local nCnt			:= 0

Default lAtuEDT	:= .T.

If nRecAFC<>Nil
	dbSelectArea("AFC")
	dbGoto(nRecAFC)
	cProjeto	:= AFC->AFC_PROJET
	cRevisao	:= AFC->AFC_REVISA
	cEDT		:= AFC->AFC_EDT
	cEDTPai	:= AFC->AFC_EDT
Else
	dbSelectArea("AFC")
	dbSetOrder(1)
	lContinua	:= MsSeek(cFilAFC+cProjeto+cRevisao+cEDT)
	nRecAFC	:= RecNo()
EndIf

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AFC e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFC")
	dbSetOrder(1)
	If MsSeek(cFilAFC+cProjeto+cRevisao+cEDT)
	
		cEDTPai	:= AFC->AFC_EDTPAI
	
		// carrega todas as EDTs filha da EDT, inclusive ela mesma.
		PMSLoadEDT( cProjeto, cRevisao, cEDT, .T., .T., @aAtuEDT )

		For nCnt := 1 To len(aAtuEDT)
		
			If MsSeek(cFilAFC+cProjeto+cRevisao+aAtuEDT[nCnt,01])
	
				cProjeto := AFC->AFC_PROJET
				cRevisa  := AFC->AFC_REVISA
				cEDT     := AFC->AFC_EDT
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica a existencia de registros no AF9 e efetua a exclusao   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("AF9")
				dbSetOrder(2)
				MsSeek(cFilAF9+cProjeto+cRevisao+cEDT)
				While !Eof() .And. cFilAF9+cProjeto+cRevisao+cEDT==;
									AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_EDTPAI
					MaDelAF9(,,,AF9->(RecNo()),.F.)
					dbSkip()
				EndDo
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica a existencia de registros no AFQ e efetua a exclusao   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("AFQ")
				dbSetOrder(1)
				MsSeek(cFilAFQ+cProjeto+cRevisao+cEDT)
				While !Eof() .And. cFilAFQ+cProjeto+cRevisao+cEDT==;
								AFQ->AFQ_FILIAL+AFQ->AFQ_PROJET+AFQ->AFQ_REVISA+AFQ->AFQ_EDT
					RecLock("AFQ",.F.,.T.)
					dbDelete()
					MsUnlock()
					dbSkip()
				EndDo
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica a existencia de registros no AFX e efetua a exclusao   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("AFX")
				dbSetOrder(1)
				MsSeek(cFilAFX+cProjeto+cRevisao+cEDT)
				While !Eof() .And. cFilAFX+cProjeto+cRevisao+cEDT==;
									AFX->AFX_FILIAL+AFX->AFX_PROJET+AFX->AFX_REVISA+AFX->AFX_EDT
					RecLock("AFX",.F.,.T.)
					dbDelete()
					MsUnlock()
					dbSkip()
				EndDo
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica a existencia de registros no AFX e efetua a exclusao   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("AFX")
				dbSetOrder(1)
				MsSeek(cFilAFX+cProjeto+SPACE(LEN(AFX->AFX_REVISA))+cEDT)
				While !Eof() .And. cFilAFX+cProjeto+SPACE(LEN(AFX->AFX_REVISA))+cEDT==;
							AFX->AFX_FILIAL+AFX->AFX_PROJET+AFX->AFX_REVISA+AFX->AFX_EDT
					RecLock("AFX",.F.,.T.)
					dbDelete()
					MsUnlock()
					dbSkip()
				EndDo
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica a existencia de registros no AFP e efetua a exclusao   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("AFP")
				dbSetOrder(2)
				MsSeek(xFilial("AFP")+cProjeto+cRevisao+cEDT)
				While !Eof() .And. xFilial("AFP")+cProjeto+cRevisao+cEDT==;
								AFP->AFP_FILIAL+AFP->AFP_PROJET+AFP->AFP_REVISA+AFP->AFP_EDT
					RecLock("AFP",.F.,.T.)
					PMSAvalAFP("AFP",3,2)
					dbDelete()
					MsUnlock()
					dbSkip()
				EndDo
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica a existencia de registros no AFT e efetua a exclusao   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("AFT")
				dbSetOrder(4)
				MsSeek(xFilial("AFT")+cProjeto+cRevisao+cEDT)
				While !Eof() .And. xFilial("AFT")+cProjeto+cRevisao+cEDT==;
								AFT->AFT_FILIAL+AFT->AFT_PROJET+AFT->AFT_REVISA+AFT->AFT_EDT
					RecLock("AFT",.F.,.T.)
					dbDelete()
					MsUnlock()
					dbSkip()
				EndDo
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica a existencia de registros no SC6 e efetua a exclusao   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SC6")
				dbSetOrder(8)
				MsSeek(xFilial("SC6")+cProjeto+SPACE(LEN(SC6->C6_TASKPMS))+cEDT)
				While !Eof() .And. xFilial("SC6")+cProjeto+SPACE(LEN(SC6->C6_TASKPMS))+cEDT==;
								SC6->C6_FILIAL+SC6->C6_PROJPMS+SC6->C6_TASKPMS+SC6->C6_EDTPMS
					RecLock("SC6",.F.)
					SC6->C6_PROJPMS	:= ""
					SC6->C6_EDTPMS	:= ""
					MsUnlock()
					dbSelectArea("SC9")
					dbSetOrder(1)
					MsSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM)
					While !Eof() .And. xFilial()+SC6->C6_NUM+SC6->C6_ITEM==SC9->C9_PEDIDO+SC9->C9_ITEM
						RecLock("SC9",.F.)
						SC9->C9_PROJPMS	:= ""
						SC9->C9_EDTPMS	:= ""
						MsUnlock()
						dbSelectArea("SC9")
						dbSkip()
					EndDo
					dbSelectArea("SC6")
					dbSkip()
				EndDo
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica a existencia de registros no SE5 e efetua a exclusao   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SE5")
				dbSetOrder(9)
				MsSeek(xFilial("SE5")+cProjeto+cEDT)
				While !Eof() .And. SE5->E5_FILIAL+SE5->E5_PROJPMS+SE5->E5_EDTPMS == xFilial("SE5")+cProjeto+cEDT
					RecLock("SE5",.F.)
					SE5->E5_PROJPMS	:= ""
					SE5->E5_EDTPMS	:= ""
					MsUnlock()
					dbSelectArea("SE5")
					dbSkip()
				EndDo
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica a existencia de registros no AFS e efetua a exclusao   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("AFS")
				dbSetOrder(3)
				MsSeek(xFilial("AFS")+cProjeto+cRevisao+cEDT)
				While !Eof() .And. xFilial("AFS")+cProjeto+cRevisao+cEDT==;
								AFS->AFS_FILIAL+AFS->AFS_PROJET+AFS->AFS_REVISA+AFS->AFS_EDT
					RecLock("AFS",.F.,.T.)
					dbDelete()
					MsUnlock()
					dbSkip()
				EndDo
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica a existencia de registros no AJ5 e efetua a exclusao   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("AJ5")
				dbSetOrder(1)
				MsSeek(xFilial("AJ5")+cProjeto+cRevisao+cEDT)
				While !Eof() .And. xFilial("AJ5")+cProjeto+cRevisao+cEDT==;
								AJ5->AJ5_FILIAL+AJ5->AJ5_PROJET+AJ5->AJ5_REVISA+AJ5->AJ5_EDT
					RecLock("AJ5",.F.,.T.)
					dbDelete()
					MsUnlock()
					dbSkip()
				EndDo
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica a existencia de registros no AJ6 e efetua a exclusao   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("AJ6")
				dbSetOrder(1)
				MsSeek(xFilial("AJ6")+cProjeto+cRevisao+cEDT)
				While !Eof() .And. xFilial("AJ6")+cProjeto+cRevisao+cEDT==;
								AJ6->AJ6_FILIAL+AJ6->AJ6_PROJET+AJ6->AJ6_REVISA+AJ6->AJ6_EDT
					RecLock("AJ6",.F.,.T.)
					dbDelete()
					MsUnlock()
					dbSkip()
				EndDo
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Exclui o refistro do AFC                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("AFC")
				RecLock("AFC",.F.,.T.)
				dbDelete()
				MsUnlock()
				
			EndIf
		Next nCnt
		
		If lAtuEDT .And. !Empty(cEDTPai)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa o recalculo das datas da EDT                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PmsAtuEDT(cProjeto,cRevisa,cEDTPai)
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa o recalculo dos percentuais executados da EDT   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PMSEdtReal(cProjeto, cRevisa, cEDTPai)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa o recalculo do custo das tarefas e edt.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PmsAF9CusEDT(cProjeto,cRevisa,cEDTPai)
		EndIf
				
	EndIf

EndIf

RestArea(aAreaAF9)
RestArea(aAreaAFA)
RestArea(aAreaAFB)
RestArea(aAreaAFC)
RestArea(aAreaAFD)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MaPmsRevisa³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria uma no revisao no Projeto Atual.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : RecNo do projeto                                      ³±±
±±³          ³ExpN2 : Evento : 1-Criar nova versao                          ³±±
±±³          ³                 2-Mover versao                               ³±±
±±³          ³                 3-Deletar uma versao                         ³±±
±±³          ³ExpC3 : Versao Origem da nova versao (opcional).              ³±±
±±³          ³ExpC4 : Codigo da nova versao do projeto.                     ³±±
±±³          ³lSimula : define se eh nova versão ou simulacao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MaPmsRevisa(nRecAF8,nEvento,cVerAtu,cNextVer,lSimula)
DEFAULT lSimula := .F.

Processa({||AuxRevisa(nRecAF8,nEvento,cVerAtu,@cNextVer,lSimula)})

Return cNextVer

/*/{Protheus.doc} AuxRevisa
Cria uma nova revisão do projeto, a partir de outra revisão de projeto.
@author Edson Maricate
@since 09-02-2001
@version 1.0
@param nRecAF8, numérico, Recno do projeto desejado (tabela AF8)
@param nEvento, numérico, 1= Gerar uma nova revisao para o projeto;2=Gerar uma nova simulação;3-Exclui a revisão do projeto  
@param cVerAtu, character, Código da revisão do projeto de origem(opcional, assume a revisão do projeto (AF8_REVISA))
@param cNextVer, character, Novo código da revisão para o projeto(opcional, gera o codigo de revisão com base do campo AF8_REVISA)
@param lSimula, logico, Verdadeiro se trata de uma simulação de projeto, porem tem dependencia da variavel nEvento ser igual a 1
@return character, Novo código da revisão do projeto ou simulação
/*/
Function AuxRevisa(nRecAF8,nEvento,cVerAtu,cNextVer,lSimula)
Local nX			:= 0
Local aAuxCpy		:= {}
Local aArea		:= GetArea()
Local aAreaAF8	:= AF8->(GetArea())
Local aCpyRlz		:= {"AFF","AFG","AFH","AFI","AFL","AFM","AFN","AFQ","AFR","AFS","AFT","AJ7","AJ9","AJA","AJE"}
Local nY			:= 0
Local aAliasCpy
Local cVerRlz
Local lVersao		:= PMSVersion()
Local c_CTRRVS	:= ""

DEFAULT nEvento	:= 1
DEFAULT cVerAtu	:= AF8->AF8_REVISA
DEFAULT cNextVer	:= Soma1(AF8->AF8_REVISA)
DEFAULT lSimula	:= .F.

dbSelectArea("AF8")
MsGoto(nRecAF8)
cVerRlz := AF8->AF8_REVISA

Do Case
	// gerando uma nova revisao do projeto ou uma nova simulaçao do projeto
	Case nEvento == 1 .Or. nEvento == 2
		aAliasCpy := {"AFC","AF9","AFA","AFB","AFD","AFP","AFZ","AJ4","AJ5","AJ6"} // Ordem de inclusao ( tratamento da Integridade )

		aAdd(aAliasCpy ,"AEF")
		aAdd(aAliasCpy ,"AEE")
		aAdd(aAliasCpy ,"AEC")

		If AF8ComAJT(AF8->AF8_PROJET)
			aAdd(aAliasCpy,"AJY") // Insumos do projeto
			aAdd(aAliasCpy,"AEM") // Estrutura do insumo do projeto
			aAdd(aAliasCpy,"AJT") // Comp Un do Projeto
			aAdd(aAliasCpy,"AJU") // Insumos da Comp Un do Projeto
			aAdd(aAliasCpy,"AJV") // Despesas da Comp Un do Projeto
			aAdd(aAliasCpy,"AJX") // Subcomposicoes da Comp Un do Projeto
			aAdd(aAliasCpy,"AEL") // Insumos da Tarefa
			aAdd(aAliasCpy,"AEN") // Subcomposicoes da Tarefa
		EndIf

		// Verifica existencia da tabela de Tarefa x CheckList (AJO)

		aAdd( aAliasCpy, "AJO" ) // Tarefa X Check-List
		If lVersao
			aAdd( aAliasCpy, "ANE" ) // Projeto X Contratos
		Endif

		ProcRegua(((Len(aAliasCpy)+Len(aCpyRlz))*2)+10)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica e deleta os registros da proxima versao                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For ny := 1 to Len(aAliasCpy)
			IncProc()
			dbSelectArea(aAliasCpy[ny])
			If '.'+aAliasCpy[ny]+'.' $ ".AJT.AJU.AJV.AJX."
				dbSetOrder(2)
			Else
				dbSetOrder(1)
			EndIf
			MsSeek(xFilial(aAliasCpy[ny])+AF8->AF8_PROJET+cNextVer)
			While !Eof() .And. FieldGet(ColumnPos(aAliasCpy[ny]+"_FILIAL"))+;
				FieldGet(ColumnPos(aAliasCpy[ny]+"_PROJET"))+;
				FieldGet(ColumnPos(aAliasCpy[ny]+"_REVISA"))==;
				xFilial(aAliasCpy[ny])+;
				AF8->AF8_PROJET+;
				cNextVer
				RecLock(aAliasCpy[ny],.F.,.T.)
				dbDelete()
				MsUnlock()
				dbSkip()
			EndDo
		Next ny
		For ny := 1 to Len(aCpyRlz)
			IncProc()
			dbSelectArea(aCpyRlz[ny])
			dbSetOrder(1)
			MsSeek(xFilial(aCpyRlz[ny])+AF8->AF8_PROJET+cNextVer)
			While !Eof() .And. FieldGet(ColumnPos(aCpyRlz[ny]+"_FILIAL"))+;
				FieldGet(ColumnPos(aCpyRlz[ny]+"_PROJET"))+;
				FieldGet(ColumnPos(aCpyRlz[ny]+"_REVISA"))==;
				xFilial(aCpyRlz[ny])+;
				AF8->AF8_PROJET+;
				cNextVer
				RecLock(aCpyRlz[ny],.F.,.T.)
				dbDelete()
				MsUnlock()
				dbSkip()
			EndDo
		Next ny

		// exclui os registros ativos da revisão atual(AFU_CTRRVS=1) e
		// os registros inativos da revisao atual(AFU_CTRRVS=2)
		For nY := 1 to 2
			IncProc()
			c_CTRRVS	:= AllTrim(Str(nY))
			dbSelectArea("AFU")
			dbSetOrder(1)
			MsSeek(xFilial("AFU")+c_CTRRVS+AF8->AF8_PROJET+cNextVer)
			While !Eof() .And. AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA==;
				xFilial("AFU")+c_CTRRVS+AF8->AF8_PROJET+cNextVer
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Altera o codigo do controle de revisao                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("AFU",.F.)
				dbDelete()
				MsUnlock()
				dbSkip()
			EndDo
		Next nY

		// exclui os registros ativos da revisão atual(AN2_CTRRVS=1) e
		// os registros inativos da revisao atual(AN2_CTRRVS=2)
		For nY := 1 to 2
			IncProc()
			c_CTRRVS	:= AllTrim(Str(nY))
			dbSelectArea("AN2")
			dbSetOrder(1)
			MsSeek(xFilial("AN2")+"1"+AF8->AF8_PROJET+cNextVer)
			While !Eof() .And. AN2_FILIAL+AN2_CTRRVS+AN2_PROJET+AN2_REVISA==;
				xFilial("AN2")+c_CTRRVS+AF8->AF8_PROJET+cNextVer
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Altera o codigo do controle de revisao                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("AN2",.F.)
				dbDelete()
				MsUnlock()
				dbSkip()
			EndDo
		Next nY

		// exclui os registros ativos da revisão atual(AJK_CTRRVS=1) e
		// os registros inativos da revisao atual(AJK_CTRRVS=2)
		For nY := 1 to 2
			IncProc()	
			c_CTRRVS	:= AllTrim(Str(nY))
			
			dbSelectArea("AJK")
			dbSetOrder(1)
			MsSeek(xFilial("AJK")+c_CTRRVS+AF8->AF8_PROJET+cNextVer)
			While !Eof() .And. AJK_FILIAL+AJK_CTRRVS+AJK_PROJET+AJK_REVISA==;
				xFilial("AJK")+c_CTRRVS+AF8->AF8_PROJET+cNextVer
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Altera o codigo do controle de revisao                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("AJK",.F.)
				dbDelete()
				MsUnlock()
				dbSkip()
			EndDo
		Next nY

		// exclui os registros ativos da revisão atual(AJC_CTRRVS=1) e
		// os registros inativos da revisao atual(AJC_CTRRVS=2)
		For nY := 1 to 2
			IncProc()
			c_CTRRVS	:= AllTrim(Str(nY))
			dbSelectArea("AJC")
			dbSetOrder(1)
			MsSeek(xFilial("AJC")+c_CTRRVS+AF8->AF8_PROJET+cNextVer)
			While !Eof() .And. AJC_FILIAL+AJC_CTRRVS+AJC_PROJET+AJC_REVISA==;
				xFilial("AJC")+c_CTRRVS+AF8->AF8_PROJET+cNextVer
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Altera o codigo do controle de revisao                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("AJC",.F.)
				dbDelete()
				MsUnlock()
				dbSkip()
			EndDo
		Next nY

		// se for efetivacao de uma simulaçao para projeto,
		// deve desconsiderar a copia dos registros da tabela AFA
		// para serem tratadas de forma especifica. 		
		If nEvento==1 .and. lSimula		
			aDel(aAliasCpy,aScan(aAliasCpy,{|xAlias|xAlias=="AFA"}))
			aSize(aAliasCpy,len(aAliasCpy)-1)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria os registros da nova versao                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For ny := 1 to Len(aAliasCpy)
			IncProc()
			aAuxCpy	:= {}
			dbSelectArea(aAliasCpy[ny])
			If '.'+aAliasCpy[ny]+'.' $ ".AJT.AJU.AJV.AJX."
				dbSetOrder(2)
			Else
				dbSetOrder(1)
			EndIf
			
			MsSeek(xFilial(aAliasCpy[ny])+AF8->AF8_PROJET+cVerAtu)
			While !Eof() .And. FieldGet(ColumnPos(aAliasCpy[ny]+"_FILIAL"))+;
				FieldGet(ColumnPos(aAliasCpy[ny]+"_PROJET"))+;
				FieldGet(ColumnPos(aAliasCpy[ny]+"_REVISA"))==;
				xFilial(aAliasCpy[ny])+;
				AF8->AF8_PROJET+;
				cVerAtu
				aAdd(aAuxCpy,(aAliasCpy[ny])->(RecNo()))
				dbSkip()
			End
			For nX := 1 to Len(aAuxCpy)
				PmsCopyReg(aAliasCpy[ny],aAuxCpy[nx],{{aAliasCpy[ny]+"_REVISA",cNextVer}})
			Next nX
		Next nY
		
		// se for efetivacao de uma simulaçao para projeto, 
		// deve verificar se o codigo do planejamento no item de produto da tarefa
		// da simulação for diferente do projeto. Se for deve atualizar com o do projeto 
		If nEvento==1 .and. lSimula
			IncProc()
			aAuxCpy	:= {}
			// armazena os registros da tabela referente a simulação do projeto
			dbSelectArea("AFA")
			dbSetOrder(1)
			MsSeek(xFilial("AFA")+AF8->AF8_PROJET+cVerAtu)
			While !Eof() .And. AFA->(AFA_FILIAL+AFA_PROJET+AFA_REVISA)==;
				xFilial("AFA")+;
				AF8->AF8_PROJET+;
				cVerAtu
				aAdd(aAuxCpy,{AFA->(RecNo()),{AFA->AFA_TAREFA,AFA->AFA_ITEM,AFA->AFA_PRODUT,AFA->AFA_PLANEJ}})
				dbSkip()
			End
			For nX := 1 to Len(aAuxCpy)
				// busca os registros da tabela referente ao projeto para 
				// comparar o codigo do planejamento com a simulação do projeto 
				dbSelectArea("AFA")
				dbSetOrder(1)
				If dbSeek(xFilial("AFA")+AF8->AF8_PROJET+AF8->AF8_REVISA+aAuxCpy[nX,02,01]+aAuxCpy[nX,02,02]+aAuxCpy[nX,02,03])
				
					If aAuxCpy[nX,02,04] == AFA->AFA_PLANEJ
						PmsCopyReg("AFA",aAuxCpy[nx,01],{{"AFA_REVISA",cNextVer}})
					Else
						PmsCopyReg("AFA",aAuxCpy[nx,01],{{"AFA_REVISA",cNextVer},{"AFA_PLANEJ",AFA->AFA_PLANEJ}})
					EndIf
				Else
					PmsCopyReg("AFA",aAuxCpy[nx,01],{{"AFA_REVISA",cNextVer}})
				EndIf
			Next nX
		EndIf

		For ny := 1 to Len(aCpyRlz)
			IncProc()
			aAuxCpy	:= {}
			dbSelectArea(aCpyRlz[ny])
			dbSetOrder(1)
			MsSeek(xFilial(aCpyRlz[ny])+AF8->AF8_PROJET+cVerRlz)
			While !Eof() .And. FieldGet(ColumnPos(aCpyRlz[ny]+"_FILIAL"))+;
				FieldGet(ColumnPos(aCpyRlz[ny]+"_PROJET"))+;
				FieldGet(ColumnPos(aCpyRlz[ny]+"_REVISA"))==;
				xFilial(aCpyRlz[ny])+;
				AF8->AF8_PROJET+;
				cVerRlz
				aAdd(aAuxCpy,(aCpyRlz[ny])->(RecNo()))
				dbSkip()
			EndDo
			For nx := 1 to Len(aAuxCpy)
				PmsCopyReg(aCpyRlz[ny],aAuxCpy[nx],{{aCpyRlz[ny]+"_REVISA",cNextVer}})
			Next nX
		Next nY

		IncProc()
		// se for uma nova revisão do projeto 
		If nEvento==1 
			If AliasIndic("AJK")
				aAuxCpy	:= {}
				dbSelectArea("AJK")
				dbSetOrder(1)
				MsSeek(xFilial("AJK")+"1"+AF8->AF8_PROJET+cVerRlz)
				While !Eof() .And. AJK_FILIAL+AJK_CTRRVS+AJK_PROJET+AJK_REVISA==;
					xFilial("AJK")+"1"+AF8->AF8_PROJET+cVerRlz
					aAdd(aAuxCpy,AJK->(RecNo()))
					dbSkip()
				EndDo
				For nX := 1 to Len(aAuxCpy)
					AJK->(dbGoto(aAuxCpy[nX]))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Altera o codigo do controle de revisao para 2 ( Registro Inat.) ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					RecLock("AJK",.F.)
					AJK->AJK_CTRRVS := "2"
					MsUnlock()
					PmsCopyReg("AJK",aAuxCpy[nX],{{"AJK_REVISA",cNextVer},{"AJK_CTRRVS","1"}})
				Next nX
			EndIf

			aAuxCpy	:= {}
			dbSelectArea("AFU")
			dbSetOrder(1)
			MsSeek(xFilial("AFU")+"1"+AF8->AF8_PROJET+cVerRlz)
			While !Eof() .And. AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA==;
				xFilial("AFU")+"1"+AF8->AF8_PROJET+cVerRlz
				aAdd(aAuxCpy,AFU->(RecNo()))
				dbSkip()
			EndDo
			For nX := 1 to Len(aAuxCpy)
				AFU->(dbGoto(aAuxCpy[nX]))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Altera o codigo do controle de revisao para 2 ( Registro Inat.) ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("AFU",.F.)
				AFU->AFU_CTRRVS := "2"
				MsUnlock()
				PmsCopyReg("AFU",aAuxCpy[nX],{{"AFU_REVISA",cNextVer},{"AFU_CTRRVS","1"}})
			Next nX


			aAuxCpy	:= {}
			dbSelectArea("AN2")
			dbSetOrder(1)
			MsSeek(xFilial("AN2")+"1"+AF8->AF8_PROJET+cVerRlz)
			While !Eof() .And. AN2_FILIAL+AN2_CTRRVS+AN2_PROJET+AN2_REVISA==;
				xFilial("AN2")+"1"+AF8->AF8_PROJET+cVerRlz
				aAdd(aAuxCpy,AN2->(RecNo()))
				dbSkip()
			EndDo
			For nX := 1 to Len(aAuxCpy)
				AN2->(dbGoto(aAuxCpy[nX]))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Altera o codigo do controle de revisao para 2 ( Registro Inat.) ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("AN2",.F.)
				AN2->AN2_CTRRVS := "2"
				MsUnlock()
				PmsCopyReg("AN2",aAuxCpy[nX],{{"AN2_REVISA",cNextVer},{"AN2_CTRRVS","1"}})
			Next nX


			IncProc()
			aAuxCpy	:= {}
			dbSelectArea("AJC")
			dbSetOrder(1)
			MsSeek(xFilial("AJC")+"1"+AF8->AF8_PROJET+cVerRlz)
			While !Eof() .And. AJC_FILIAL+AJC_CTRRVS+AJC_PROJET+AJC_REVISA==;
				xFilial("AJC")+"1"+AF8->AF8_PROJET+cVerRlz
				aAdd(aAuxCpy,AJC->(RecNo()))
				dbSkip()
			EndDo
			For nX := 1 to Len(aAuxCpy)
				AJC->(dbGoto(aAuxCpy[nX]))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Altera o codigo do controle de revisao para 2 ( Registro Inat.) ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("AJC",.F.)
				AJC->AJC_CTRRVS := "2"
				MsUnlock()
				PmsCopyReg("AJC",aAuxCpy[nX],{{"AJC_REVISA",cNextVer},{"AJC_CTRRVS","1"}})
			Next nX
		EndIf

		// Somente atualiza a a revisao do projeto, se for uma nova revisao.
		If nEvento == 1

			dbSelectArea("AEB")
			dbSetOrder(1)
			If dbSeek(xFilial("AEB")+AF8->(AF8_PROJET+AF8_REVISA))
				RecLock("AEB",.F.)
				AEB->AEB_REVISA	:= cNextVer
				MsUnlock()
			EndIf

			RecLock("AF8",.F.)
			AF8->AF8_REVISA	:= cNextVer
			MsUnlock()

			// Atualiza tabela de impostos
			// Nao uso DbSkip no While para forçar posicionamento na tarefa que possui mais de um imposto
			DbSelectArea("AN9")
			AN9->(DbSetOrder(1))
			If AN9->(MsSeek(xFilial("AN9")+AF8->AF8_PROJET+cVerAtu))
				Do While AN9->(!Eof()) .And. AN9->(MsSeek(xFilial("AN9")+AF8->AF8_PROJET+cVerAtu))
					RecLock("AN9",.F.)
					AN9->AN9_REVISA := cNextVer
					MsUnlock()
				EndDo
			EndIf

		EndIf

	// excluindo a revisão do projeto ou simulaçao do projeto
	Case nEvento == 3
		aAliasCpy := {"AFA","AFB","AFD","AFP","AFZ","AJ4","AJ5","AJ6","AFC","AF9"}


		aAuxCpy := {}
		aAdd(aAuxCpy ,"AEC")
		aAdd(aAuxCpy ,"AEE")
		aAdd(aAuxCpy ,"AEF")
		aEval(aAliasCpy ,{|x|aAdd(aAuxCpy ,x)})
		aAliasCpy := aClone(aAuxCpy)
		aAuxCpy := {}

		If AF8ComAJT(AF8->AF8_PROJET)
			aAdd(aAliasCpy,"AJY") // Insumos do projeto
			aAdd(aAliasCpy,"AEM") // Estrutura do insumo do projeto
			aAdd(aAliasCpy,"AJT") // Comp Un do Projeto
			aAdd(aAliasCpy,"AJU") // Insumos da Comp Un do Projeto
			aAdd(aAliasCpy,"AJV") // Despesas da Comp Un do Projeto
			aAdd(aAliasCpy,"AJX") // Subcomposicoes da Comp Un do Projeto
			aAdd(aAliasCpy,"AEL") // Insumos da Tarefa
			aAdd(aAliasCpy,"AEN") // Subcomposicoes da Tarefa
		EndIf

		If lVersao
			aAdd( aAliasCpy, "ANE" ) // Projeto X Contratos
		Endif

		ProcRegua(Len(aAliasCpy)+Len(aCpyRlz)+5)
		For ny := 1 to Len(aCpyRlz)
			IncProc()
			dbSelectArea(aCpyRlz[ny])
			dbSetOrder(1)
			MsSeek(xFilial(aCpyRlz[ny])+AF8->AF8_PROJET+cVerAtu)
			While !Eof() .And. FieldGet(ColumnPos(aCpyRlz[ny]+"_FILIAL"))+;
				FieldGet(ColumnPos(aCpyRlz[ny]+"_PROJET"))+;
				FieldGet(ColumnPos(aCpyRlz[ny]+"_REVISA"))==;
				xFilial(aCpyRlz[ny])+;
				AF8->AF8_PROJET+;
				cVerAtu
				RecLock(aCpyRlz[ny],.F.,.T.)
				dbDelete()
				MsUnlock()
				dbSkip()
			EndDo
		Next ny

		IncProc()

		aAuxCpy	:= {}
		dbSelectArea("AJK")
		dbSetOrder(1)
		MsSeek(xFilial("AJK")+"1"+AF8->AF8_PROJET+cVerAtu)
		While !Eof() .And. AJK_FILIAL+AJK_CTRRVS+AJK_PROJET+AJK_REVISA==;
			xFilial("AJK")+"1"+AF8->AF8_PROJET+cVerAtu
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Altera o codigo do controle de revisao para 2 ( Registro Inat.) ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("AJK",.F.)
			dbDelete()
			MsUnlock()
			dbSkip()
		EndDo

		IncProc()
		dbSelectArea("AFU")
		dbSetOrder(1)
		MsSeek(xFilial("AFU")+"1"+AF8->AF8_PROJET+cVerAtu)
		While !Eof() .And. AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA==;
			xFilial("AFU")+"1"+AF8->AF8_PROJET+cVerAtu
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Altera o codigo do controle de revisao para 2 ( Registro Inat.) ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("AFU",.F.)
			dbDelete()
			MsUnlock()
			dbSkip()
		EndDo

		IncProc()

		aAuxCpy	:= {}
		dbSelectArea("AN2")
		dbSetOrder(1)
		MsSeek(xFilial("AN2")+"1"+AF8->AF8_PROJET+cVerAtu)
		While !Eof() .And. AN2_FILIAL+AN2_CTRRVS+AN2_PROJET+AN2_REVISA==;
			xFilial("AN2")+"1"+AF8->AF8_PROJET+cVerAtu
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Altera o codigo do controle de revisao para 2 ( Registro Inat.) ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("AN2",.F.)
			dbDelete()
			MsUnlock()
			dbSkip()
		EndDo

		IncProc()
		dbSelectArea("AJC")
		dbSetOrder(1)
		MsSeek(xFilial("AJC")+"1"+AF8->AF8_PROJET+cVerAtu)
		While !Eof() .And. AJC_FILIAL+AJC_CTRRVS+AJC_PROJET+AJC_REVISA==;
			xFilial("AJC")+"1"+AF8->AF8_PROJET+cVerAtu
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Altera o codigo do controle de revisao para 2 ( Registro Inat.) ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("AJC",.F.)
			dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
		For ny := 1 to Len(aAliasCpy)
			IncProc()
			aAuxCpy	:= {}
			dbSelectArea(aAliasCpy[ny])
			If '.'+aAliasCpy[ny]+'.' $ ".AJT.AJU.AJV.AJX."
				dbSetOrder(2)
			Else
				dbSetOrder(1)
			EndIf
			MsSeek(xFilial(aAliasCpy[ny])+AF8->AF8_PROJET+cVerAtu)
			While !Eof() .And. FieldGet(ColumnPos(aAliasCpy[ny]+"_FILIAL"))+;
				FieldGet(ColumnPos(aAliasCpy[ny]+"_PROJET"))+;
				FieldGet(ColumnPos(aAliasCpy[ny]+"_REVISA"))==;
				xFilial(aAliasCpy[ny])+;
				AF8->AF8_PROJET+;
				cVerAtu
				RecLock(aAliasCpy[ny],.F.,.T.)
				dbDelete()
				MsUnlock()
				dbSkip()
			EndDo
		Next ny
EndCase

If ExistTemplate("PMSREVISA")
	ExecTemplate("PMSREVISA",.F.,.F.,{nEvento,cVerAtu,cNextVer})
EndIf

If ExistBlock("PMSREVISA")
	ExecBlock("PMSREVISA",.F.,.F.,{nEvento,cVerAtu,cNextVer})
EndIf

RestArea(aAreaAF8)
RestArea(aArea)

// libera memoria do array
aSize(aAuxCpy, 0)
aAuxCpy := NIL

Return cNextVer


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MaPmsRecodi³ Autor ³ Edson Maricate       ³ Data ³ 28-06-2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a recodificação da EDT / Tarefa                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Tipo : 1=EDT , 2=Tarefa                               ³±±
±±³          ³ExpN2 : RecNo do projeto                                      ³±±
±±³          ³ExpC3 : Novo Código                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Function MaPmsRecodi(nTipo,nRecNo,cNewCode)

Processa({||AuxRecodi(nTipo,nRecNo,@cNewCode)})

Return cNewCode

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AuxRecodi³ Autor ³ Edson Maricate         ³ Data ³ 28-06-2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a recodificação da EDT / Tarefa                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Tipo : 1=EDT , 2=Tarefa                               ³±±
±±³          ³ExpN2 : RecNo do projeto                                      ³±±
±±³          ³ExpC3 : Novo Código                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Function AuxRecodi(nTipo,nRecNo,cNewCode)

Local aArea	:= GetArea()
Local lRet 	:= .T.
Local cProjeto
Local cRevisa
Local aAlias

If nTipo == 1
	dbSelectArea("AFC")
	MsGoto(nRecNo)
	cProjeto := AFC->AFC_PROJET
	cRevisa	:= AFC->AFC_REVISA
	cEDT		:= AFC->AFC_EDT
	If !dbSeek(xFilial()+cProjeto+cRevisa+cNewCode)
		dbSelectArea("AFC")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria o registro com o novo codigo ( Mantendo a integridade )    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PmsCopyReg("AFC",nRecNo,{{"AFC_EDT",cNewCode}})



	Else
		lRet := .F.
	EndIf
Else
EndIf

RestArea(aArea)
Return lRet



Local nx		:= 0
Local aAuxCpy	:= {}
Local aArea		:= GetArea()
Local aAreaAF8	:= AF8->(GetArea())
Local aCpyRlz	:= {"AFF","AFG","AFH","AFI","AFL","AFM","AFN","AFQ","AFR","AFS","AFT","AJ7","AJ9","AJA","AJE"}
Local nY		:= 0
Local aAliasCpy
Local cVerRlz

dbSelectArea("AF8")
MsGoto(nRecAF8)
cVerRlz				:= AF8->AF8_REVISA
DEFAULT nEvento		:= 1
DEFAULT cVerAtu		:= AF8->AF8_REVISA
DEFAULT cNextVer	:= Soma1(AF8->AF8_REVISA)

Do Case
	Case nEvento == 1 .Or. nEvento == 2
		aAliasCpy := {"AFC","AF9","AFA","AFB","AFD","AFP","AFZ","AJ4","AJ5","AJ6"} // Ordem de inclusao ( tratamento da Integridade )
		ProcRegua(((Len(aAliasCpy)+Len(aCpyRlz))*2)+6)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica e deleta os registros da proxima versao                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For ny := 1 to Len(aAliasCpy)
			IncProc()
			aAuxCpy	:= {}
			dbSelectArea(aAliasCpy[ny])
			dbSetOrder(1)
			MsSeek(xFilial()+AF8->AF8_PROJET+cNextVer)
			While !Eof() .And. FieldGet(ColumnPos(aAliasCpy[ny]+"_FILIAL"))+;
				FieldGet(ColumnPos(aAliasCpy[ny]+"_PROJET"))+;
				FieldGet(ColumnPos(aAliasCpy[ny]+"_REVISA"))==;
				xFilial(aAliasCpy[ny])+;
				AF8->AF8_PROJET+;
				cNextVer
				RecLock(aAliasCpy[ny],.F.,.T.)
				dbDelete()
				MsUnlock()
				dbSkip()
			End
		Next ny
		For ny := 1 to Len(aCpyRlz)
			IncProc()
			aAuxCpy	:= {}
			dbSelectArea(aCpyRlz[ny])
			dbSetOrder(1)
			MsSeek(xFilial()+AF8->AF8_PROJET+cNextVer)
			While !Eof() .And. FieldGet(ColumnPos(aCpyRlz[ny]+"_FILIAL"))+;
				FieldGet(ColumnPos(aCpyRlz[ny]+"_PROJET"))+;
				FieldGet(ColumnPos(aCpyRlz[ny]+"_REVISA"))==;
				xFilial(aCpyRlz[ny])+;
				AF8->AF8_PROJET+;
				cNextVer
				RecLock(aCpyRlz[ny],.F.,.T.)
				dbDelete()
				MsUnlock()
				dbSkip()
			End
		Next ny
		IncProc()
		aAuxCpy	:= {}
		dbSelectArea("AFU")
		dbSetOrder(1)
		MsSeek(xFilial()+"1"+AFU->AFU_PROJET+cNextVer)
		While !Eof() .And. AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA==;
			xFilial("AFU")+"1"+AF8->AF8_PROJET+cNextVer
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Altera o codigo do controle de revisao para 2 ( Registro Inat.) ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("AFU",.F.)
			dbDelete()
			MsUnlock()
			dbSkip()
		End
		IncProc()
		aAuxCpy	:= {}
		dbSelectArea("AFU")
		dbSetOrder(1)
		MsSeek(xFilial()+"2"+AFU->AFU_PROJET+cNextVer)
		While !Eof() .And. AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA==;
			xFilial("AFU")+"2"+AF8->AF8_PROJET+cNextVer
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Altera o codigo do controle de revisao para 2 ( Registro Inat.) ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("AFU",.F.)
			dbDelete()
			MsUnlock()
			dbSkip()
		End
		IncProc()
		aAuxCpy	:= {}
		dbSelectArea("AJC")
		dbSetOrder(1)
		MsSeek(xFilial()+"1"+AJC->AJC_PROJET+cNextVer)
		While !Eof() .And. AJC_FILIAL+AJC_CTRRVS+AJC_PROJET+AJC_REVISA==;
			xFilial("AJC")+"1"+AJC->AJC_PROJET+cNextVer
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Altera o codigo do controle de revisao para 2 ( Registro Inat.) ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("AJC",.F.)
			dbDelete()
			MsUnlock()
			dbSkip()
		End
		IncProc()
		aAuxCpy	:= {}
		dbSelectArea("AJC")
		dbSetOrder(1)
		MsSeek(xFilial()+"2"+AJC->AJC_PROJET+cNextVer)
		While !Eof() .And. AJC_FILIAL+AJC_CTRRVS+AJC_PROJET+AJC_REVISA==;
			xFilial("AJC")+"2"+AJC->AJC_PROJET+cNextVer
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Altera o codigo do controle de revisao para 2 ( Registro Inat.) ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("AJC",.F.)
			dbDelete()
			MsUnlock()
			dbSkip()
		End
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria os registros da nova versao                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For ny := 1 to Len(aAliasCpy)
			IncProc()
			aAuxCpy	:= {}
			dbSelectArea(aAliasCpy[ny])
			dbSetOrder(1)
			MsSeek(xFilial()+AF8->AF8_PROJET+cVerAtu)
			While !Eof() .And. FieldGet(ColumnPos(aAliasCpy[ny]+"_FILIAL"))+;
				FieldGet(ColumnPos(aAliasCpy[ny]+"_PROJET"))+;
				FieldGet(ColumnPos(aAliasCpy[ny]+"_REVISA"))==;
				xFilial(aAliasCpy[ny])+;
				AF8->AF8_PROJET+;
				cVerAtu
				aAdd(aAuxCpy,(aAliasCpy[ny])->(RecNo()))
				dbSkip()
			End
			For nx := 1 to Len(aAuxCpy)
				PmsCopyReg(aAliasCpy[ny],aAuxCpy[nx],{{aAliasCpy[ny]+"_REVISA",cNextVer}})
			Next
		Next ny
		For ny := 1 to Len(aCpyRlz)
			IncProc()
			aAuxCpy	:= {}
			dbSelectArea(aCpyRlz[ny])
			dbSetOrder(1)
			MsSeek(xFilial()+AF8->AF8_PROJET+cVerRlz)
			While !Eof() .And. FieldGet(ColumnPos(aCpyRlz[ny]+"_FILIAL"))+;
				FieldGet(ColumnPos(aCpyRlz[ny]+"_PROJET"))+;
				FieldGet(ColumnPos(aCpyRlz[ny]+"_REVISA"))==;
				xFilial(aCpyRlz[ny])+;
				AF8->AF8_PROJET+;
				cVerRlz
				aAdd(aAuxCpy,(aCpyRlz[ny])->(RecNo()))
				dbSkip()
			End
			For nx := 1 to Len(aAuxCpy)
				PmsCopyReg(aCpyRlz[ny],aAuxCpy[nx],{{aCpyRlz[ny]+"_REVISA",cNextVer}})
			Next
		Next ny
		IncProc()
		aAuxCpy	:= {}
		dbSelectArea("AFU")
		dbSetOrder(1)
		MsSeek(xFilial()+"1"+AF8->AF8_PROJET+cVerRlz)
		While !Eof() .And. AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA==;
			xFilial("AFU")+"1"+AF8->AF8_PROJET+cVerRlz
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Altera o codigo do controle de revisao para 2 ( Registro Inat.) ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("AFU",.F.)
			AFU->AFU_CTRRVS := "2"
			MsUnlock()
			aAdd(aAuxCpy,AFU->(RecNo()))
			dbSkip()
		End
		For nx := 1 to Len(aAuxCpy)
			PmsCopyReg("AFU",aAuxCpy[nx],{{"AFU_REVISA",cNextVer},{"AFU_CTRRVS","1"}})
		Next

		IncProc()
		aAuxCpy	:= {}
		dbSelectArea("AJC")
		dbSetOrder(1)
		MsSeek(xFilial()+"1"+AF8->AF8_PROJET+cVerRlz)
		While !Eof() .And. AJC_FILIAL+AJC_CTRRVS+AJC_PROJET+AJC_REVISA==;
			xFilial("AJC")+"1"+AF8->AF8_PROJET+cVerRlz
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Altera o codigo do controle de revisao para 2 ( Registro Inat.) ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("AJC",.F.)
			AJC->AJC_CTRRVS := "2"
			MsUnlock()
			aAdd(aAuxCpy,AJC->(RecNo()))
			dbSkip()
		End
		For nx := 1 to Len(aAuxCpy)
			PmsCopyReg("AJC",aAuxCpy[nx],{{"AJC_REVISA",cNextVer},{"AJC_CTRRVS","1"}})
		Next
		If nEvento == 1
			RecLock("AF8",.F.)
			AF8->AF8_REVISA	:= cNextVer
			MsUnlock()
		EndIf

	Case nEvento == 3
		aAliasCpy := {"AFA","AFB","AFD","AFP","AFZ","AJ4","AJ5","AJ6","AFC","AF9"} // Ordem de exclusao ( tratamento da Integridade )
		ProcRegua(Len(aAliasCpy)+Len(aCpyRlz)+2)
		For ny := 1 to Len(aCpyRlz)
			IncProc()
			aAuxCpy	:= {}
			dbSelectArea(aCpyRlz[ny])
			dbSetOrder(1)
			MsSeek(xFilial()+AF8->AF8_PROJET+cVerAtu)
			While !Eof() .And. FieldGet(ColumnPos(aCpyRlz[ny]+"_FILIAL"))+;
				FieldGet(ColumnPos(aCpyRlz[ny]+"_PROJET"))+;
				FieldGet(ColumnPos(aCpyRlz[ny]+"_REVISA"))==;
				xFilial(aCpyRlz[ny])+;
				AF8->AF8_PROJET+;
				cVerAtu
				RecLock(aCpyRlz[ny],.F.,.T.)
				dbDelete()
				MsUnlock()
				dbSkip()
			End
		Next ny
		IncProc()
		aAuxCpy	:= {}
		dbSelectArea("AFU")
		dbSetOrder(1)
		MsSeek(xFilial()+"1"+AFU->AFU_PROJET+cVerAtu)
		While !Eof() .And. AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA==;
			xFilial("AFU")+"1"+AF8->AF8_PROJET+cVerAtu
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Altera o codigo do controle de revisao para 2 ( Registro Inat.) ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("AFU",.F.)
			dbDelete()
			MsUnlock()
			dbSkip()
		End
		IncProc()
		aAuxCpy	:= {}
		dbSelectArea("AJC")
		dbSetOrder(1)
		MsSeek(xFilial()+"1"+AJC->AJC_PROJET+cVerAtu)
		While !Eof() .And. AJC_FILIAL+AJC_CTRRVS+AJC_PROJET+AJC_REVISA==;
			xFilial("AJC")+"1"+AJC->AJC_PROJET+cVerAtu
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Altera o codigo do controle de revisao para 2 ( Registro Inat.) ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("AJC",.F.)
			dbDelete()
			MsUnlock()
			dbSkip()
		End
		For ny := 1 to Len(aAliasCpy)
			IncProc()
			aAuxCpy	:= {}
			dbSelectArea(aAliasCpy[ny])
			dbSetOrder(1)
			MsSeek(xFilial()+AF8->AF8_PROJET+cVerAtu)
			While !Eof() .And. FieldGet(ColumnPos(aAliasCpy[ny]+"_FILIAL"))+;
				FieldGet(ColumnPos(aAliasCpy[ny]+"_PROJET"))+;
				FieldGet(ColumnPos(aAliasCpy[ny]+"_REVISA"))==;
				xFilial(aAliasCpy[ny])+;
				AF8->AF8_PROJET+;
				cVerAtu
				RecLock(aAliasCpy[ny],.F.,.T.)
				dbDelete()
				MsUnlock()
				dbSkip()
			End
		Next ny
EndCase

If ExistBlock("PMSREVISA")
	ExecBlock("PMSREVISA",.F.,.F.,{nEvento,cVerAtu,cNextVer})
EndIf


RestArea(aAreaAF8)
RestArea(aArea)

Return cNextVer

*/


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAtuNec³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a atualizacao das datas de necessidade da tarefa.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAtuNec(cProjeto,cRevisa,cTarefa,lAtuDtPrf)
Local aArea		:= GetArea()
Local aAreaAFB	:= AFB->(GetArea())
Local aAreaAFA	:= AFA->(GetArea())
Local aAreaAF9	:= AF9->(GetArea())
Default lAtuDtPrf := .T.

dbSelectArea("AF9")
dbSetOrder(1)
MsSeek(xFilial()+cProjeto+cRevisa+cTarefa)

If ExistBlock("PMSCHGDT")
	ExecBlock("PMSCHGDT",.F.,.F.)
EndIf

dbSelectArea("AFA")
dbSetOrder(1)
MsSeek(xFilial()+cProjeto+cRevisa+cTarefa)
While !Eof() .And. xFilial()+cProjeto+cRevisa+cTarefa==;
	AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA
	RecLock("AFA",.F.)
	If lAtuDtPrf
		AFA->AFA_DATPRF	:= AF9->AF9_START
	EndIf
	If !Empty(AFA_RECURS)
		AE8->(dbSetOrder(1))
		AE8->(MsSeek(xFilial()+AFA->AFA_RECURS))
		AFA->AFA_START	:= AF9->AF9_START
		AFA->AFA_HORAI	:= AF9->AF9_HORAI
		AFA->AFA_FINISH	:= AF9->AF9_FINISH
		AFA->AFA_HORAF	:= AF9->AF9_HORAF

		If AFA->AFA_FIX == "1"
			AFA->AFA_QUANT := (PmsIAFAQuant(AFA->AFA_PROJET,AFA->AFA_REVISA,AFA->AFA_TAREFA,AFA->AFA_PRODUT,AF9->AF9_QUANT,AFA->AFA_ALOC,AF9->AF9_HDURAC)*PmsHrsItvl(AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,If(!Empty(AE8->AE8_CALEND),AE8->AE8_CALEND,AF9->AF9_CALEND),AF9->AF9_PROJET,AE8->AE8_RECURS))/100
		Else
			AFA->AFA_ALOC  := PmsAFAQuant(AFA->AFA_PROJET,AFA->AFA_REVISA,AFA->AFA_TAREFA,AFA->AFA_PRODUT,AF9->AF9_QUANT,AFA->AFA_QUANT,AF9->AF9_HDURAC)/PmsHrsItvl(AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,If(!Empty(AE8->AE8_CALEND),AE8->AE8_CALEND,AF9->AF9_CALEND),AF9->AF9_PROJET,AE8->AE8_RECURS)*100
		EndIf

	EndIf
	MsUnlock()
	dbSkip()
EndDo

dbSelectArea("AFB")
If lAtuDtPrf
	dbSetOrder(1)
	MsSeek(xFilial()+cProjeto+cRevisa+cTarefa)
	While !Eof() .And. xFilial()+cProjeto+cRevisa+cTarefa==;
		AFB_FILIAL+AFB_PROJET+AFB_REVISA+AFB_TAREFA
		If !(AFB->AFB_DATPRF == AF9->AF9_START)
			RecLock("AFB",.F.)
			AFB->AFB_DATPRF	:= AF9->AF9_START
			MsUnlock()
		EndIf
		dbSkip()
	EndDo
EndIf

If ExistBlock("PMSAF9DT")
	ExecBlock("PMSAF9DT",.F.,.F.)
EndIf

RestArea(aAreaAF9)
RestArea(aAreaAFA)
RestArea(aAreaAFB)
RestArea(aArea)
Return

/*/{Protheus.doc} PmsAtuScs

Função principal onde executa a atualizacao dos eventos e as datas das tarefas sucessoras a partir da tarefa predessora.
Chamado a funcao AuxAtuScs onde ocorre processamento, assim evitando estouro de pilha.


@author Edson Maricate

@since 09-02-2001

@version P11

@param cProjeto,   caracter, Codigo do projeto
@param cRevisa,    caracter, Codigo da revisão
@param cTarefa,    caracter, Codigo  da tarefa
@param lAtuEDT,    logico,   Se deve atualizar as EDTs
@param aAtuEDT,    array,    Codigos da EDT que houveram alteracao nas datas previstas das tarefas ou EDTs filhas
@param lReprParc,  logico,   Se verdadeiro deve recalcular parcialmente

@return nulo

/*/
Function PmsAtuScs(cProjeto,cRevisa,cTarefa,lAtuEDT, aAtuEDT,lReprParc)
Local aArea		:= GetArea()
Local aAreaAFD	:= AFD->(GetArea())
Local aAreaAFP	:= AFP->(GetArea())
Local aTarefas:= {}

DEFAULT lAtuEDT	:= .T.
DEFAULT aAtuEDT	:= {}
DEFAULT lReprParc := .F.

	aTarefas := {cTarefa}
	While Len(aTarefas) > 0
		aTarefas := auxAtuScs(cProjeto,cRevisa,aTarefas,lAtuEDT, aAtuEDT,lReprParc)
	End

RestArea(aAreaAFP)
RestArea(aAreaAFD)
RestArea(aArea)
Return

/*/{Protheus.doc} PmsAtuScs

Função auxliar que processa a atualizacao dos eventos e as datas das tarefas sucessoras a partir da tarefa predessora.

@author Edson Maricate

@since 09-02-2001

@version P11

@param cProjeto,   caracter, Codigo do projeto
@param cRevisa,    caracter, Codigo da revisão
@param aTarefas,   Array, Vetor com os codigos de tarefa para serem avaliados e atualizados se necessario
@param lAtuEDT,    logico,   Se deve atualizar as EDTs
@param aAtuEDT,    array,    Codigos da EDT que houveram alteracao nas datas previstas das tarefas ou EDTs filhas
@param lReprParc,  logico,   Se verdadeiro deve recalcular parcialmente

@return nulo

/*/
Static Function AuxAtuScs(cProjeto,cRevisa,aTarefas,lAtuEDT, aAtuEDT,lReprParc)
Local nCnt := 0
Local cTarefa := ""
Local aTskSuck := {}

DEFAULT lAtuEDT	:= .T.
DEFAULT aAtuEDT	:= {}
DEFAULT lReprParc := .F.

For nCnt := 1 to Len(aTarefas)

	cTarefa := aTarefas[nCnt]

	dbSelectArea("AFD")
	dbSetOrder(2) // AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_PREDEC+AFD_ITEM
	MsSeek(xFilial()+cProjeto+cRevisa+cTarefa)
	While !Eof() .And. xFilial()+cProjeto+cRevisa+cTarefa==;
		AFD->AFD_FILIAL+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_PREDEC
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a atualizacao dos Eventos.                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AFP")
		dbSetOrder(1)
		MsSeek(xFilial()+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_TAREFA)
		While !Eof() .And. xFilial()+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_TAREFA==;
			AFP_FILIAL+AFP_PROJET+AFP_REVISA+AFP_TAREFA
			PmsAvalAFP("AFP",3)
			dbSkip()
		End

		// atualiza a datas previstas da tarefa sucessora
		If PmsAtuPrd(AFD->AFD_PROJET,AFD->AFD_REVISA,AFD->AFD_TAREFA,lAtuEDT,aAtuEDT,lReprParc)
			aAdd(aTskSuck, cTarefa)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a atualizacao dos Eventos.                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AFP")
		dbSetOrder(1)
		MsSeek(xFilial()+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_TAREFA)
		While !Eof() .And. xFilial()+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_TAREFA==;
			AFP_FILIAL+AFP_PROJET+AFP_REVISA+AFP_TAREFA
			PmsAvalAFP("AFP",1)
			dbSkip()
		End
		dbSelectArea("AFD")
		dbSkip()
	EndDo
Next
Return aTskSuck

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAtuScsE³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a atualizacao das datas das tarefas Sucessoras.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAtuScsE(cProjeto,cRevisa,cEDT,lAtuEDT, aAtuEDT)
Local aArea		:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAFD	:= AFD->(GetArea())

DEFAULT lAtuEDT	:= .T.
DEFAULT aAtuEDT	:= {}

dbSelectArea("AJ4")
dbSetOrder(2)
MsSeek(xFilial()+cProjeto+cRevisa+cEDT)
While !Eof() .And. xFilial()+cProjeto+cRevisa+cEDT==;
	AJ4_FILIAL+AJ4_PROJET+AJ4_REVISA+AJ4_PREDEC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua a atualizacao dos Eventos.                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFP")
	dbSetOrder(1)
	MsSeek(xFilial()+AJ4->AJ4_PROJET+AJ4->AJ4_REVISA+AJ4->AJ4_TAREFA)
	While !Eof() .And. xFilial()+AJ4->AJ4_PROJET+AJ4->AJ4_REVISA+AJ4->AJ4_TAREFA==;
		AFP_FILIAL+AFP_PROJET+AFP_REVISA+AFP_TAREFA
		PmsAvalAFP("AFP",3)
		dbSkip()
	End

	// atualiza a datas previstas da tarefa sucessora
	PmsAtuPrd(AJ4->AJ4_PROJET,AJ4->AJ4_REVISA,AJ4->AJ4_TAREFA,lAtuEDT,aAtuEDT)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua a atualizacao dos Eventos.                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFP")
	dbSetOrder(1)
	MsSeek(xFilial()+AJ4->AJ4_PROJET+AJ4->AJ4_REVISA+AJ4->AJ4_TAREFA)
	While !Eof() .And. xFilial()+AJ4->AJ4_PROJET+AJ4->AJ4_REVISA+AJ4->AJ4_TAREFA==;
		AFP_FILIAL+AFP_PROJET+AFP_REVISA+AFP_TAREFA
		PmsAvalAFP("AFP",1)
		dbSkip()
	End
	dbSelectArea("AJ4")
	PmsAtuScs(AJ4_PROJET,AJ4_REVISA,AJ4_TAREFA,lAtuEDT,aAtuEDT)
	dbSkip()
End

RestArea(aAreaAFD)
RestArea(aAreaAF9)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAvalEvent³ Autor ³ Edson Maricate      ³ Data ³ 18-05-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de avaliacao dos disparos dos eventos do Projeto.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: 1:Tarefa , 2:EDT                                       ³±±
±±³          ³ExpC2: Alias da Tabela de Tarefas ou EDT                      ³±±
±±³          ³nEvento: Codigo do Evento                                     ³±±
±±³          ³         [1] Inclusao da Confirmacao                          ³±±
±±³          ³         [2] Estorno da Confirmacao                           ³±±
±±³          ³nPerc : percentual do ultimo apontamento da EDT               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo atualizar os eventos vinculados ³±±
±±³          ³ao disparo dos Eventos do Projeto :                           ³±±
±±³          ³A) Atualizacao das tabelas complementares.                    ³±±
±±³          ³B) Atualizacao das informacoes complementares da Tarefa/EDT   ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAvalEvent(nTabela,cAlias,nEvento,nPerc)
Local lSendOk
Local lOk         := .F.
Local cSeek       := ''
Local aArea       := GetArea()
Local aAreaAFP    := AFP->(GetArea())
Local aAreaAFF    := AFF->(GetArea())
Local aAreaTMP    := {}
Local cError
Local cProjeto    := ""
Local cTarefa     := ""
Local cEdt        := ""
Local aCond       := {}
Local cFilAFF     := xFilial("AFF")
Local lSldInf 		:= .F.
Local nX				:= 0
Local cParcela		:= ""
Local lPMSMSGEA := ExistBlock("PMSMSGEA")
Local cAssunAux := ""

Private cMensagem   := ''
Private cAssunto := STR0093
Private cMailConta  := GETMV("MV_EMCONTA")
Private cMailServer := GETMV("MV_RELSERV")
Private cMailSenha  := GETMV("MV_EMSENHA")

If nTabela==1
	nPerc := 0
	AFP->(dbSetOrder(1)) //AFP_FILIAL+AFP_PROJET+AFP_REVISA+AFP_TAREFA+AFP_ITEM
	cSeek := xFilial("AFP")+(cAlias)->AF9_PROJET+(cAlias)->AF9_REVISA+(cAlias)->AF9_TAREFA

	aAreaTmp := AFF->(GetArea())
	//pega o ultimo apontamento da tarefa
	AFF->(DbSetOrder(1)) //AFF_FILIAL+AFF_PROJET+AFF_REVISA+AFF_TAREFA+DTOS(AFF_DATA)
	AFF->(DbSeek(cFilAFF+(cAlias)->(AF9_PROJET+AF9_REVISA+AF9_TAREFA) ))
	While !AFF->(EOF()) .And. AFF->(AFF_FILIAL+AFF_PROJET+AFF_REVISA+AFF_TAREFA)==cFilAFF+(cAlias)->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)
		//na exclusao do apontamento o ultimo apontamento nao deve ser o apontamento que sera excluido
		If nEvento==1 .Or. !(aAreaAFF[3]==AFF->(Recno()))
			nPerc := AFF->AFF_QUANT
		EndIf
		AFF->(DbSkip())
	EndDo
	AFF->(RestArea(aAreaTmp))
Else
	AFP->(DbSetOrder(2)) //AFP_FILIAL+AFP_PROJET+AFP_REVISA+AFP_EDT+AFP_ITEM
	cSeek := xFilial("AFP")+(cAlias)->AFC_PROJET+(cAlias)->AFC_REVISA+(cAlias)->AFC_EDT
EndIf


DbSelectArea("AFP")
DbSeek(cSeek,.T.)

While !Eof() .And. cSeek==AFP_FILIAL+AFP_PROJETO+AFP_REVISA+If(nTabela==1,AFP_TAREFA,AFP_EDT)

	// se evento nao disparado e % do evento menor que ultimo apontamento entao
	If Empty(AFP_DTATU) .And. AFP_PERC<=(nPerc/AF9->AF9_QUANT)*100
		//atualiza o evento com a data do apontamento
		RecLock("AFP",.F.)
		AFP->AFP_DTATU := dDataBase
		MsUnlock()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existem titulos provisorios gerados para ³
		//³ o evento e executa a exclusao.                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SE1")
		dbSetOrder(2)
		MsSeek(PmsFilial("SE1","AFP")+AFP->AFP_CLIENT+AFP->AFP_LOJA+AFP->AFP_PREFIX+AFP->AFP_NUM)

		While !Eof() .And. PmsFilial("SE1","AFP")+AFP->AFP_CLIENT+AFP->AFP_LOJA+AFP->AFP_PREFIX+AFP->AFP_NUM==;
			E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM
			If SE1->E1_TIPO$MVPROVIS
				dbSelectArea("AFT")
				dbSetOrder(2)
				If MsSeek(xFilial("AFT")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA) .And. AFT->AFT_EVENTO==AFP->AFP_ITEM
					RecLock("AFT",.F.,.T.)
					dbDelete()
					MsUnlock()
					RecLock("SE1",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
			EndIf
			SE1->(dbSkip())
		End
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se ja existe titulo para este evento.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AFT")
		dbSetOrder(2)
		If !MsSeek(xFilial("AFT")+AFP->AFP_PREFIX+AFP->AFP_NUM+Space(Len(SE1->E1_PARCELA))+MVNOTAFIS+AFP->AFP_CLIENT+AFP->AFP_LOJA) //.And. AFT->AFT_EVENTO==AFP->AFP_ITEM

			aCond := Condicao(AFP->AFP_VALOR, AFP->AFP_COND, , AFP->AFP_DTATU)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se deve gerar Titulo Financeiro a Receber.     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(AFP->AFP_CLIENT) .And. !Empty(AFP->AFP_LOJA) .And. AFP->AFP_GERTIT=="1"

				If Len(aCond)>0
					For nX:=1 to Len(aCond)
						cParcela := STRZERO(nX,TamSx3("E1_PARCELA")[1])

						RecLock("SE1",.T.)
						SE1->E1_FILIAL		:= xFilial("SE1")
						SE1->E1_PREFIXO	:= AFP->AFP_PREFIX
						SE1->E1_NUM			:= AFP->AFP_NUM
						SE1->E1_TIPO		:= MVNOTAFIS
						SE1->E1_NATUREZ	:= AFP->AFP_NATURE
						SE1->E1_CLIENTE	:= AFP->AFP_CLIENT
						SE1->E1_LOJA		:= AFP->AFP_LOJA
						SE1->E1_PARCELA 	:= cParcela
						SE1->E1_VENCTO 	:= aCond[nX,1]
						SE1->E1_VENCREA	:= DataValida(SE1->E1_VENCTO)
						SE1->E1_VALOR		:= aCond[nX,2]
						SE1->E1_MOEDA		:= AFP->AFP_MOEDA
						SE1->E1_EMISSAO	:= dDataBase
						SE1->E1_PROJPMS 	:= "1"
						SE1->E1_ORIGEM		:= "PMSXFUN1"
						MsUnlock()

						A040DupRec("FINA040")

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualizacao dos dados do Modulo SIGAPMS    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RecLock("AFT",.T.)
						AFT->AFT_FILIAL	:= xFilial("AFT")
						AFT->AFT_VALOR1	:= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,1,SE1->E1_EMISSAO)
						AFT->AFT_VALOR2	:= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,2,SE1->E1_EMISSAO)
						AFT->AFT_VALOR3	:= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,3,SE1->E1_EMISSAO)
						AFT->AFT_VALOR4	:= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,4,SE1->E1_EMISSAO)
						AFT->AFT_VALOR5	:= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,5,SE1->E1_EMISSAO)
						AFT->AFT_PREFIX	:= SE1->E1_PREFIXO
						AFT->AFT_NUM		:= SE1->E1_NUM
						AFT->AFT_PARCEL	:= SE1->E1_PARCELA
						AFT->AFT_TIPO		:= SE1->E1_TIPO
						AFT->AFT_CLIENT	:= SE1->E1_CLIENTE
						AFT->AFT_LOJA		:= SE1->E1_LOJA
						AFT->AFT_VENREA	:= SE1->E1_VENCREA
						AFT->AFT_PROJET	:= AFP->AFP_PROJET
						AFT->AFT_REVISA	:= AFP->AFP_REVISA
						AFT->AFT_TAREFA	:= AFP->AFP_TAREFA
						AFT->AFT_EVENTO 	:= AFP->AFP_ITEM
						AFT->AFT_EDT	:= AFP->AFP_EDT
						MsUnlock()
					Next nX

				Else

					RecLock("SE1",.T.)
					SE1->E1_FILIAL		:= xFilial("SE1")
					SE1->E1_PREFIXO	:= AFP->AFP_PREFIX
					SE1->E1_NUM			:= AFP->AFP_NUM
					SE1->E1_TIPO		:= MVNOTAFIS
					SE1->E1_NATUREZ	:= AFP->AFP_NATURE
					SE1->E1_CLIENTE	:= AFP->AFP_CLIENT
					SE1->E1_LOJA		:= AFP->AFP_LOJA
					SE1->E1_VENCTO 	:= AFP->AFP_DTATU
					SE1->E1_VENCREA	:= DataValida(SE1->E1_VENCTO)
					SE1->E1_VALOR		:= AFP->AFP_VALOR
					SE1->E1_MOEDA		:= AFP->AFP_MOEDA
					SE1->E1_EMISSAO	:= dDataBase
					SE1->E1_PROJPMS 	:= "1"
					SE1->E1_ORIGEM		:= "PMSXFUN1"
					MsUnlock()

					A040DupRec("FINA040")

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualizacao dos dados do Modulo SIGAPMS    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					RecLock("AFT",.T.)
					AFT->AFT_FILIAL	:= xFilial("AFT")
					AFT->AFT_VALOR1	:= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,1,SE1->E1_EMISSAO)
					AFT->AFT_VALOR2	:= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,2,SE1->E1_EMISSAO)
					AFT->AFT_VALOR3	:= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,3,SE1->E1_EMISSAO)
					AFT->AFT_VALOR4	:= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,4,SE1->E1_EMISSAO)
					AFT->AFT_VALOR5	:= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,5,SE1->E1_EMISSAO)
					AFT->AFT_PREFIX	:= SE1->E1_PREFIXO
					AFT->AFT_NUM		:= SE1->E1_NUM
					AFT->AFT_PARCEL	:= SE1->E1_PARCELA
					AFT->AFT_TIPO		:= SE1->E1_TIPO
					AFT->AFT_CLIENT	:= SE1->E1_CLIENTE
					AFT->AFT_LOJA		:= SE1->E1_LOJA
					AFT->AFT_VENREA	:= SE1->E1_VENCREA
					AFT->AFT_PROJET	:= AFP->AFP_PROJET
					AFT->AFT_REVISA	:= AFP->AFP_REVISA
					AFT->AFT_TAREFA	:= AFP->AFP_TAREFA
					AFT->AFT_EVENTO 	:= AFP->AFP_ITEM
					AFT->AFT_EDT	:= AFP->AFP_EDT
					MsUnlock()
				Endif
			Endif
		Endif
		If !Empty(AFP->AFP_USRFUN) .And. ExistBlock(AFP->AFP_USRFUN)
			ExecBlock(AFP->AFP_USRFUN,.F.,.F.)
		EndIf

		If !Empty(AFP->AFP_EMAIL)
			dbSelectArea("AF8")
			dbSetOrder(1)
			If dbSeek(xFilial("AF8")+AFP->AFP_PROJET)
				cProjeto:=AF8->AF8_DESCRI
				If !Empty(AFP->AFP_TAREFA)
					dbSelectArea("AF9")
					dbSetOrder(1)
					If dbSeek(xFilial("AF9")+AF8->AF8_PROJET+AF8->AF8_REVISA+AFP->AFP_TAREFA)
						cTarefa:=AF9->AF9_DESCRI
					EndIf
				Else
					dbSelectArea("AFC")
					dbSetOrder(1)
					If dbSeek(xFilial("AFC")+AF8->AF8_PROJET+AF8->AF8_REVISA+AFC->AFC_EDT)
						cEdt:=AFC->AFC_DESCRI
					EndIf
				EndIf
			EndIf
			cMensagem := ""

			// head
			cMensagem += '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'
			cMensagem += '<html>' + Chr(13) + Chr(10)
			cMensagem += '  <head>' + Chr(13) + Chr(10)
			cMensagem += '    <meta name="generator" content="Advanced Protheus 7.10 - Project Management System">' + Chr(13) + Chr(10)
			cMensagem += '    <meta http-equiv="Content-Type" content="text/html; charset=us-ascii">' + Chr(13) + Chr(10)
			cMensagem += '    <title>Evento</title>'
			cMensagem += '  </head>' + Chr(13) + Chr(10)

			// body
			cMensagem += '  <body><center><table border="0"><tr><td colspan="2"><center><h3>' + STR0082  + '</h3></center></td></tr>' //"Confirmacao do Evento"

			// titulo
			cMensagem += '<tr><td><b>' + STR0083 + '</b></td><td>' //"Projeto : "
			cMensagem += HTMLEnc(AFP->AFP_PROJET) + '</td></tr>'

			// Descricao projeto
			cMensagem += '<tr><td><b>' + STR0164 + '</b></td><td>' //"Desc. Proj.: "
			cMensagem += HTMLEnc(cProjeto) + '</td></tr>'

			// tarefa - EDT
			If !Empty(AFP->AFP_TAREFA)
				cMensagem	+= '<tr><td><b>' + STR0084 + '</b></td><td>' + HTMLEnc(AFP->AFP_TAREFA) + '</td></tr>'  //"Tarefa  :"
				cMensagem	+= '<tr><td><b>' + STR0165 + '</b></td><td>' + HTMLEnc(cTarefa) + '</td></tr>'  //"Desc.Tar: "
			Else
				cMensagem	+= '<tr><td><b>' + STR0085+ '</b></td><td>' + HTMLEnc(AFP->AFP_EDT) + '</td></tr>'    //"EDT  :"
				cMensagem	+= '<tr><td><b>' + STR0166+ '</b></td><td>' + HTMLEnc(cEDT) + '</td></tr>'  //"Desc.EDT: "
			EndIf
			cMensagem += '<tr><td colspan="2"><hr width="100%"></td></tr>'

			// evento
			cMensagem	+= '<tr><td><b>' + STR0086 + '</b></td><td>' + HTMLEnc(AFP->AFP_DESCRI) + '</td></tr>'    //"Evento : "

			cMensagem	+= '<tr><td><b>' + STR0233 + '</b></td><td>' + HTMLEnc(Transform(AF9->AF9_QUANT,X3Picture( "AF9_QUANT" ))) + '</td></tr>'  //"Qtd Projeto: "
			// percentual informado para o envio do email
			cMensagem	+= '<tr><td><b>' + STR0087 + '</b></td><td>' + HTMLEnc(Transform(AFP->AFP_PERC,"@E9999.99%")) + '%</td></tr>'  //"% Evento : "
			cMensagem	+= '<tr><td><b>' + STR0234 + '</b></td><td>' + HTMLEnc(Transform((AF9->AF9_QUANT*AFP->AFP_PERC)/ 100,X3Picture( "AFF_QUANT" ))) + '</td></tr>'  //"Qtd Evento: "
			// Quantidade
			cMensagem += '<tr><td><b>' + STR0235 + '</b></td><td>' + HTMLEnc((Transform((nPerc*100)/ AF9->AF9_QUANT,"@E9999.99%" ))) + '%</td></tr>' //"% Exec:"
			cMensagem += '<tr><td><b>' + STR0088 + '</b></td><td>' + HTMLEnc((Transform(nPerc,X3Picture( "AFF_QUANT" )))) + '</td></tr>' //"Qtd Exec:"
			cMensagem += '<tr><td colspan="2"><hr width="100%"></td></tr>'

			// data prevista
			cMensagem	+= '<tr><td><b>'+STR0089+ '</b></td><td>' + HTMLEnc(DTOC(AFP->AFP_DTPREV)) + '</td></tr>'  //"Data Prevista : "

			// data prevista calculada pelo PMS
			cMensagem	+= '<tr><td><b>'+STR0090+ '</b></td><td>' + HTMLEnc(DTOC(AFP->AFP_DTCALC)) + '</td></tr>' //"Data Prev. Calc : "

			// data realizada
			cMensagem	+= '<tr><td><b>'+STR0091+ '</b></td><td>' + HTMLEnc(DTOC(AFP->AFP_DTATU)) +'</td></tr>'  //"Data Real : "
			cMensagem += '<tr><td colspan="2"><hr width="100%"></td></tr>'

			// observacao da tarefa
			cMensagem += '<tr><td valign="top"><b>' + STR0092 + '<br>' + STR0157 + '</b></td>' //"Observacoes:"
			cMensagem += '<td>'
			cMensagem += Strtran(HTMLEnc(MSMM(AF9->AF9_CODMEM,TamSX3("AF9_OBS")[1],,,3,,,"AF9", "AF9_CODMEM")), Chr(13)+Chr(10), "<BR>")
			cMensagem += '</td></tr>'
			cMensagem += '<tr><td colspan="2"><hr width="100%"></td></tr>'

			// observacao da confirmacao da tarefa
			cMensagem += '<tr><td valign="top"><b>' + STR0092 + '<br>' + STR0158 + '</b></td>' //"Observacoes:"
			cMensagem += '<td>'
			cMensagem += Strtran(HTMLEnc(MSMM(AFF->AFF_CODMEM,TamSX3("AFF_OBS")[1],,,3,,,"AFF", "AFF_CODMEM")), Chr(13)+Chr(10), "<BR>")
			cMensagem += '</td></tr>'
			cMensagem += '</table></center></body></html>'

			//Ponto de entrada para alterar a mensagem do email
			If ExistBlock("PMSNEWMSG")
				ExecBlock("PMSNEWMSG",.F.,.F.)
			EndIF

			//			If !Empty(cMailServer) .And. !Empty(cMailConta) .And. !Empty(cMailSenha)
			CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lOk

			If lOk .AND. SuperGetMv("MV_RELAUTH")
				lOk := MailAuth(cMailConta, cMailSenha)
			EndIf

			If lOk
				If lPMSMSGEA
					cAssunAux:= Execblock("PMSMSGEA", .F., .F.)
					If ValType(cAssunAux) == "C"
						cAssunto := cAssunAux
					EndIf
				EndIf

				SEND MAIL FROM cMailConta to AFP->AFP_EMAIL SUBJECT cAssunto BODY cMensagem RESULT lSendOk FORMAT TEXT  //"AP6 SIGAPMS - Confirmacao do Evento"
				If !lSendOk
					GET MAIL ERROR cError
					Aviso(STR0094,cError,{STR0095},2)  //"Erro no envio do e-Mail"###"Fechar"
				EndIf
			Else
				GET MAIL ERROR cError
				Aviso(STR0094,cError,{STR0095},2)  //"Erro no envio do e-Mail"###"Fechar"
			EndIf

			If lOk
				DISCONNECT SMTP SERVER
			EndIf
		EndIf
		//		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se deve liberar o pedido de vendas - cabecalho ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(AFP->AFP_CTV)
			dbSelectArea("SC6")
			dbSetOrder(1)
			dbSeek(xFilial("SC6")+AFP->AFP_CTV)
			While !Eof() .And. xFilial("SC6")+AFP->AFP_CTV==SC6->C6_FILIAL+SC6->C6_NUM
				If PmsAPVQtL(SC6->C6_QTDVEN*AFP->AFP_CTVPER/100)
					MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN*AFP->AFP_CTVPER/100,,,,,,,,{|| PmsGrvAJA(AFP->AFP_PROJET,AFP->AFP_REVISA,AFP->AFP_EDT,AFP->AFP_TAREFA,AFP->AFP_ITEM) })
					dbSelectArea("SC6")
					dbSkip()
				Else
					Aviso(STR0222,STR0223+Alltrim(SC6->C6_NUM)+".",{STR0095},2)  //"Saldo insuficiente do pedido.","Verifique o evento desta tarefa, pois ele tentou liberar uma quantidade a maior do saldo do pedido "
					lSldInf := .T.
					Exit
				Endif
			EndDo
			MaLiberOk({AFP->AFP_CTV})
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se deve liberar o pedido de vendas - cabecalho ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(AFP->AFP_CTVITE)
			dbSelectArea("SC6")
			dbSetOrder(1)
			dbSeek(xFilial()+AFP->AFP_CTVITE)
			If PmsAPVQtL(SC6->C6_QTDVEN*AFP->AFP_CTVPER/100) .AND. !lSldInf
				MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN*AFP->AFP_CTVPER/100,,,,,,,,{|| PmsGrvAJA(AFP->AFP_PROJET,AFP->AFP_REVISA,AFP->AFP_EDT,AFP->AFP_TAREFA,AFP->AFP_ITEM) })
				MaLiberOk({SC6->C6_NUM})
			Elseif !lSldInf
				Aviso(STR0222,STR0223+Alltrim(SC6->C6_NUM)+".",{STR0095},2)  //"Saldo insuficiente do pedido.","Verifique o evento desta tarefa, pois ele tentou liberar uma quantidade a maior do saldo do pedido "
			Endif
		EndIf

		// se evento disparado    e     % do evento maior que ultimo apontamento entao estorna
	ElseIf !Empty(AFP_DTATU) .And. AFP_PERC>(nPerc/AF9->AF9_QUANT)*100

		RecLock("AFP",.F.)
		AFP->AFP_DTATU := CTOD("  /  /  ")
		MsUnlock()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Estorna as liberacoes dos Pedidos de Vendas             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SC9->(dbSetOrder(1))
		dbSelectArea("AJA")
		dbSetOrder(1)
		dbSeek(xFilial()+AFP->AFP_PROJET+AFP->AFP_REVISA+AFP->AFP_EDT+AFP->AFP_TAREFA+AFP->AFP_ITEM)
		While !Eof() .And. xFilial()+AFP->AFP_PROJET+AFP->AFP_REVISA+AFP->AFP_EDT+AFP->AFP_TAREFA+AFP->AFP_ITEM==;
			AJA_FILIAL+AJA_PROJET+AJA_REVISA+AJA_EDT+AJA_TAREFA+AJA_ITEM
			If SC9->(dbSeek(xFilial()+AJA->AJA_NUMPV+AJA->AJA_ITEMPV+AJA->AJA_SEQUEN+AJA->AJA_PRODUT)) .And. SC9->C9_BLEST <> "10" .And. SC9->C9_BLCRED <> "10"
				A460Estorna()
				RecLock("AJA",.F.,.T.)
				dbDelete()
				MsUnlock()
			EndIf
			dbSelectArea("AJA")
			dbSkip()
		End
		If !Empty(AFP->AFP_CTVITE)
			MaLiberOk({AFP->AFP_CTVITE})
		EndIf
		If !Empty(AFP->AFP_CTV)
			MaLiberOk({AFP->AFP_CTV})
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existem titulos Normais gerados para o   ³
		//³ evento e executa a exclusao.                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SE1")
		dbSetOrder(2)
		MsSeek(PmsFilial("SE1", "AFP")+AFP->AFP_CLIENT+AFP->AFP_LOJA+AFP->AFP_PREFIX+AFP->AFP_NUM)
		While !Eof() .And. PmsFilial("SE1", "AFP")+AFP->AFP_CLIENT+AFP->AFP_LOJA+AFP->AFP_PREFIX+AFP->AFP_NUM==;
			E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM
			If SE1->E1_TIPO$MVNOTAFIS .And. Empty(SE1->E1_BAIXA) .And. SE1->E1_VALOR == SE1->E1_SALDO .And. SE1->E1_SITUACA == "0"
				dbSelectArea("AFT")
				dbSetOrder(2)
				If MsSeek(xFilial()+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA) .And. AFT->AFT_EVENTO==AFP->AFP_ITEM
					RecLock("AFT",.F.,.T.)
					dbDelete()
					MsUnlock()
					RecLock("SE1",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
			EndIf
			dbSkip()
		End
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera o Titulo no Contas a Receber Provisorio            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(AFP->AFP_CLIENT) .And. !Empty(AFP->AFP_LOJA) .And. AFP->AFP_GERPRV!="3"
			RecLock("SE1",.T.)
			SE1->E1_FILIAL	:= xFilial("SE1")
			SE1->E1_PREFIXO	:= AFP->AFP_PREFIX
			SE1->E1_NUM		:= AFP->AFP_NUM
			SE1->E1_TIPO	:= MVPROVIS
			SE1->E1_NATUREZ	:= AFP->AFP_NATURE
			SE1->E1_CLIENTE	:= AFP->AFP_CLIENT
			SE1->E1_LOJA	:= AFP->AFP_LOJA
			SE1->E1_VENCTO	:= If(AFP->AFP_GERPRV=="1",AFP->AFP_DTPREV,AFP->AFP_DTCALC)
			SE1->E1_VENCREA	:= DataValida(SE1->E1_VENCTO)
			SE1->E1_VALOR	:= AFP->AFP_VALOR
			SE1->E1_MOEDA	:= AFP->AFP_MOEDA
			SE1->E1_EMISSAO := dDataBase
			SE1->E1_VLCRUZ	:= Round( xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,1,SE1->E1_EMISSAO,3), MsDecimais(1) )
			SE1->E1_PROJPMS := "1"
			SE1->E1_ORIGEM	:= "PMSXFUN2"
			MsUnlock()
			A040DupRec("FINA040")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualizacao dos dados do Modulo SIGAPMS    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("AFT",.T.)
			AFT->AFT_FILIAL := xFilial("AFT")
			AFT->AFT_VALOR1 := xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,1,SE1->E1_EMISSAO)
			AFT->AFT_VALOR2 := xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,2,SE1->E1_EMISSAO)
			AFT->AFT_VALOR3 := xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,3,SE1->E1_EMISSAO)
			AFT->AFT_VALOR4 := xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,4,SE1->E1_EMISSAO)
			AFT->AFT_VALOR5 := xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,5,SE1->E1_EMISSAO)
			AFT->AFT_PREFIX := SE1->E1_PREFIXO
			AFT->AFT_NUM    := SE1->E1_NUM
			AFT->AFT_PARCEL := SE1->E1_PARCELA
			AFT->AFT_TIPO   := SE1->E1_TIPO
			AFT->AFT_CLIENT := SE1->E1_CLIENTE
			AFT->AFT_LOJA   := SE1->E1_LOJA
			AFT->AFT_VENREA := SE1->E1_VENCREA
			AFT->AFT_PROJET := AFP->AFP_PROJET
			AFT->AFT_REVISA := AFP->AFP_REVISA
			AFT->AFT_TAREFA := AFP->AFP_TAREFA
			AFT->AFT_EVENTO := AFP->AFP_ITEM
			AFT->AFT_EDT := AFP->AFP_EDT
			MsUnlock()
		EndIf
	EndIf
	dbSelectArea("AFP")
	dbSkip()
EndDo


RestArea(aAreaAFF)
RestArea(aAreaAFP)
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsEnvGrff³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de envio do grafico por email.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC100                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsEnvGrff(oGraphic,cAssunto,aTexto,cTo,cCC,aTabela,nEspacos,nColLeft)

Local cMailConta	:=GETMV("MV_EMCONTA")
Local cMailServer	:=GETMV("MV_RELSERV")
Local cMailSenha	:=GETMV("MV_EMSENHA")
Local lOk			:= .F.
Local cMensagem
Local nx			:= 0
Local lBmp			:= !( oGraphic == NIL )
Local cBmpName, nWidth := 0
Local cError
Local X				:= 0

Local lAuthOK := .F.

Local cAutConta := ""
Local cAutSenha := ""
Local aAutRet   := {}
Local cRaizServer := If(issrvunix(), "/", "\")

Default aTexto  	:= {}
Default aTabela 	:= {}
Default nEspacos  := 10
Default nColLeft 	:= 1

If lBmp
	cBmpName := CriaTrab( , .F.) + ".jpg"
EndIf

cMensagem := '<!doctype html public "-//W3C//DTD HTML 4.0 Transitional//EN">'
cMensagem += '<html><head>'
cMensagem += '<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">'
cMensagem += '</head>'
cMensagem += '<body><b>'

cMensagem += "<br>" + STR0170 + AllTrim(UsrFullName(RetCodUsr())) + "</br>" //"Enviado por "
cMensagem += '<br>&nbsp;</br>'


For nx := 1 To Len(aTexto)
	cMensagem += "<p>" + Alltrim(aTexto[nx]) + "</p>"
Next
cMensagem += "<center>"

nX:= Len(aTabela)
If nX > 0
	For x := 1 To Len(aTabela[nX])
		nWidth += Len(aTabela[nX,x]) + nEspacos
	Next
EndIf

If Len(aTabela) > 1
	cMensagem += '<table border="0" width="' + Str(nWidth, 3) + '%"><tr>'
	For x := 1 To Len(aTabela[1])
		cMensagem += '<td bgcolor="#33CCFF">'
		cMensagem += '<b><center>' + aTabela[1,x] + '</center></b> </td>'
	Next
	cMensagem += '</tr>'
EndIf

For nx := 2 To Len(aTabela)

	For x := 1 To Len(aTabela[nx])
		cMensagem += '<td bgcolor="' + If( Mod(nx,2)==0, '#CEE7F7','#FFFFFF') +  '" >'
		cMensagem += If(x <= nColLeft,"",'<p align="right">')+ aTabela[nx,x] + If(x == 1,"</center>","")+' </td>'
	Next
	cMensagem += '</tr>'

Next
cMensagem +='</table>'
cMensagem += '</B>'
cMensagem += '<BR>&nbsp;</BR>'
If lBmp
	cMensagem += '<p><img src="' + cBmpName + '"></p>'
EndIf
cMensagem += "</center>"
cMensagem += '</b></body>'
cMensagem += '</html>'

ProcRegua(8)

If lBmp
	oGraphic:SaveToImage(cBmpName, cRaizServer, "JPEG")
EndIf

IncProc()
IncProc(STR0161) //"Conectando servidor..."

// Envia e-mail com os dados necessarios
If !Empty(cMailServer) .And. !Empty(cMailConta) .And. !Empty(cMailSenha)
	// Conecta uma vez com o servidor de e-mails
	If !lOk
		CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lOk

		// tenta executar a autenticacao com a conta
		// do usuario para permitir o envio fora
		// fora do dominio da conta usada
		If GetMV("MV_RELAUTH")
			cAutConta := cMailConta
			cAutSenha := cMailSenha

			lAuthOK := MailAuth(cAutConta, cAutSenha)

			Do While !lAuthOK
				If !ParamBox({{1, STR0167, PadR(cAutConta, 50, Space(1)), "", "", "", "", 55, .T.},;   //"Conta:"
					{8, STR0168, PadR(cAutSenha, 50, Space(1)), "", "", "", "", 55, .T.}},;  //"Senha:"
					STR0169, @aAutRet)  //"Autenticacao SMTP"

					// o usuario cancelou a autenticacao
					If lOk
						DISCONNECT SMTP SERVER
						IncProc()
						IncProc()
						IncProc()
					EndIf

					If lBmp .and. File(cRaizServer + cBmpName)
						FErase(cRaizServer + cBmpName)
					EndIf

					Return .F.
				EndIf

				cAutConta := AllTrim(aAutRet[1])
				cAutSenha := AllTrim(aAutRet[2])

				lAuthOK := MailAuth(cAutConta, cAutSenha)
			EndDo
		EndIf

		IncProc()
		IncProc()
		IncProc(STR0162) //"Enviando e-mail..."
	EndIf
	If lOk
		If lBmp
			SEND MAIL FROM cMailConta to cTo BCC cCC  SUBJECT cAssunto BODY cMensagem  ATTACHMENT cRaizServer + cBmpName RESULT lSendOk
		Else
			SEND MAIL FROM cMailConta to cTo BCC cCC  SUBJECT cAssunto BODY cMensagem  RESULT lSendOk
		EndIf
		IncProc()
		IncProc()
		IncProc(STR0163) //"Desconectando..."
		If !lSendOk
			//Erro no Envio do e-mail
			GET MAIL ERROR cError
			Aviso(STR0160,cError,{STR0095},2) //"Erro no envio do e-Mail"###"Fechar"
		EndIf
	Else
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		Aviso(STR0160,cError,{STR0095},2) //"Erro no envio do e-Mail"###"Fechar"
	EndIf
EndIf
If lOk
	DISCONNECT SMTP SERVER
	IncProc()
	IncProc()
	IncProc()
EndIf

If lBmp .and. File(cRaizServer + cBmpName)
	Ferase(cRaizServer + cBmpName)
EndIf

Return lOk

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MaExclAF2  ³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a exclusao de uma Tarefa.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : Codigo do Orcamento                                   ³±±
±±³          ³ExpC3 : Codigo da Tarefa                                      ³±±
±±³          ³ExpN4 : RecNo da Tarefa ( Opcional )                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MaExclAF2(cOrcamento,cTarefa,nRecAF2)

Local aArea	:= GetArea()
Local aAreaAF2	:= AF2->(GetArea())
Local aAreaAF3	:= AF3->(GetArea())
Local aAreaAF4	:= AF4->(GetArea())
Local aAreaAF5	:= AF5->(GetArea())
Local aAreaAF7	:= AF7->(GetArea())
Local lContinua	:= .T.
Local cEdtPai   := ""

If nRecAF2<>Nil
	dbSelectArea("AF2")
	dbGoto(nRecAF2)
	cOrcamento	:= AF2->AF2_ORCAME
	cNivelTrf	:= AF2->AF2_NIVEL
	cTarefa		:= AF2->AF2_TAREFA
	cEdtPai     := AF2->AF2_EDTPAI
Else
	dbSelectArea("AF2")
	dbSetOrder(1)
	lContinua	:= MsSeek(xFilial()+cOrcamento+cTarefa)
	nRecAF2		:= RecNo()
	cEdtPai     := AF2->AF2_EDTPAI
EndIf

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AF3 e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AF3")
	dbSetOrder(1)
	MsSeek(xFilial()+cOrcamento+cTarefa)
	While !Eof() .And. xFilial("AF3")+cOrcamento+cTarefa==;
		AF3->AF3_FILIAL+AF3->AF3_ORCAME+AF3->AF3_TAREFA
		RecLock("AF3",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AF4 e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AF4")
	dbSetOrder(1)
	MsSeek(xFilial()+cOrcamento+cTarefa)
	While !Eof() .And. xFilial("AF4")+cOrcamento+cTarefa==;
		AF4->AF4_FILIAL+AF4->AF4_ORCAME+AF4->AF4_TAREFA
		RecLock("AF4",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AF7 e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AF7")
	dbSetOrder(1)
	MsSeek(xFilial()+cOrcamento+cTarefa)
	While !Eof() .And. xFilial("AF7")+cOrcamento+cTarefa==;
		AF7->AF7_FILIAL+AF7->AF7_ORCAME+AF7->AF7_TAREFA
		RecLock("AF7",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AF7 e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AF7")
	dbSetOrder(2)
	MsSeek(xFilial()+cOrcamento+cTarefa)
	While !Eof() .And. xFilial("AF7")+cOrcamento+cTarefa==;
		AF7->AF7_FILIAL+AF7->AF7_ORCAME+AF7->AF7_PREDEC
		RecLock("AF7",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AJ1 e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AJ1")
	dbSetOrder(1)
	MsSeek(xFilial()+cOrcamento+cTarefa)
	While !Eof() .And. xFilial("AJ1")+cOrcamento+cTarefa==;
		AJ1->AJ1_FILIAL+AJ1->AJ1_ORCAME+AJ1->AJ1_TAREFA
		RecLock("AJ1",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AJF e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AJG")
	dbSetOrder(1)
	MsSeek(xFilial()+cOrcamento+cTarefa)
	While !Eof() .And. xFilial("AJG")+cOrcamento+cTarefa==;
		AJG->AJG_FILIAL+AJG->AJG_ORCAME+AJG->AJG_TAREFA
		RecLock("AJG",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSelectArea("AJG")
		dbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui o refistro do AF2                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AF2")
	dbGoto(nRecAF2)

	RecLock("AF2",.F.,.T.)
	dbDelete()
	MsUnlock()

	PmsAvalAF2("AF2",cOrcamento,cEdtPai)
EndIf

RestArea(aAreaAF2)
RestArea(aAreaAF3)
RestArea(aAreaAF4)
RestArea(aAreaAF5)
RestArea(aAreaAF7)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MaExclAF5  ³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a exclusao de uma EDT.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : Codigo do Orcamento                                   ³±±
±±³          ³ExpC3 : Codigo da EDT                                         ³±±
±±³          ³ExpN4 : RecNo da EDT    ( Opcional )                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MaExclAF5(cOrcamento,cEDT,nRecAF5)

Local aArea	:= GetArea()
Local aAreaAF2	:= AF2->(GetArea())
Local aAreaAF3	:= AF3->(GetArea())
Local aAreaAF4	:= AF4->(GetArea())
Local aAreaAF5	:= AF5->(GetArea())
Local aAreaAF7	:= AF7->(GetArea())
Local lContinua	:= .T.


If nRecAF5<>Nil
	dbSelectArea("AF5")
	dbGoto(nRecAF5)
	cOrcamento	:= AF5->AF5_ORCAME
	cEDT		:= AF5->AF5_EDT
Else
	dbSelectArea("AF5")
	dbSetOrder(1)
	lContinua	:= MsSeek(xFilial()+cOrcamento+cEDT)
	nRecAF5		:= RecNo()
EndIf

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AF2 e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AF5")
	dbSetOrder(2)
	MsSeek(xFilial()+cOrcamento+cEDT)
	While !Eof() .And. xFilial("AF5")+cOrcamento+cEDT==;
		AF5->AF5_FILIAL+AF5->AF5_ORCAME+AF5->AF5_EDTPAI
		MaExclAF5(,,AF5->(RecNo()))
		dbSkip()
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AF2 e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AF2")
	dbSetOrder(2)
	MsSeek(xFilial()+cOrcamento+cEDT)
	While !Eof() .And. xFilial("AF2")+cOrcamento+cEDT==;
		AF2->AF2_FILIAL+AF2->AF2_ORCAME+AF2->AF2_EDTPAI
		MaExclAF2(,,AF2->(RecNo()))
		dbSkip()
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AJ2 e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AJ2")
	dbSetOrder(1)
	MsSeek(xFilial()+cOrcamento+cEDT)
	While !Eof() .And. xFilial("AJ2")+cOrcamento+cEDT==;
		AJ2->AJ2_FILIAL+AJ2->AJ2_ORCAME+AJ2->AJ2_EDT
		RecLock("AJ2",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSelectArea("AJ2")
		dbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AJ3 e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AJ3")
	dbSetOrder(1)
	MsSeek(xFilial()+cOrcamento+cEDT)
	While !Eof() .And. xFilial("AJ3")+cOrcamento+cEDT==;
		AJ3->AJ3_FILIAL+AJ3->AJ3_ORCAME+AJ3->AJ3_EDT
		RecLock("AJ3",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSelectArea("AJ3")
		dbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AJ3 e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AJ3")
	dbSetOrder(2)
	MsSeek(xFilial()+cOrcamento+cEDT)
	While !Eof() .And. xFilial("AJ3")+cOrcamento+cEDT==;
		AJ3->AJ3_FILIAL+AJ3->AJ3_ORCAME+AJ3->AJ3_EDT
		RecLock("AJ3",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSelectArea("AJ3")
		dbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no AJF e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AJF")
	dbSetOrder(1)
	MsSeek(xFilial()+cOrcamento+cEDT)
	While !Eof() .And. xFilial("AJF")+cOrcamento+cEDT==;
		AJF->AJF_FILIAL+AJF->AJF_ORCAME+AJF->AJF_EDT
		RecLock("AJF",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSelectArea("AJF")
		dbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui o registro do AF5                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AF5")
	dbGoto(nRecAF5)
	RecLock("AF5",.F.,.T.)
	dbDelete()
	MsUnlock()
EndIf

RestArea(aAreaAF2)
RestArea(aAreaAF3)
RestArea(aAreaAF4)
RestArea(aAreaAF5)
RestArea(aAreaAF7)
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MontaTabela³ Autor ³ Adriano Ueda         ³ Data ³ 23-01-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta uma tabela HTML a partir de um array bidimensional      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aDados  - array para montar a tabela                          ³±±
±±³          ³lCabec  - indica se a primeira linha e cabecalho da tabela    ³±±
±±³          ³cWidth  - tamanho da tabela                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   |string com a tabela em HTML                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MontaTabelaHTML(aDados, lCabec, cWidth)
Local cBuffer := ""
Local ni      := 1
Local nj      := 1

If ValType(cWidth)=="U"
	cBuffer+='<table border="1">'
Else
	cBuffer+='<table border="1" width="' + cWidth + '">'
EndIf

For ni := 1 To Len(aDados)
	cBuffer+="<tr>"

	For nj := 1 To Len(aDados[ni])
		If lCabec .And. ni==1
			cBuffer += "<td><b>" + HTMLEnc(aDados[ni,nj]) + "</b></td>"
		Else
			cBuffer += "<td>" + HTMLEnc(aDados[ni,nj]) + "</td>"
		EndIf
	Next

	cBuffer+="</tr>"
Next

cBuffer+="</table>"
Return cBuffer

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³HTMLEnc    ³ Autor ³ Adriano Ueda         ³ Data ³ 01-10-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a string codificada em entidades HTML                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cString - string a ser codificada                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³string codificada em entidades HTML                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HTMLEnc(xString)
Local cBuffer := xString

Do Case
	Case ValType(xString)=="C"
		cBuffer = Strtran(cBuffer, "&", "&amp;")
		cBuffer = Strtran(cBuffer, '"', "&quot;")
		cBuffer = Strtran(cBuffer, "<", "&lt;")
		cBuffer = Strtran(cBuffer, ">", "&gt;")
	Case ValType(xString)=="N"
		cBuffer = Str(xString)
EndCase

Return cBuffer

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsBaixas    ³ Autor ³ Lu¡s C. Cunha      ³ Data ³ 14.04.03           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o valor pago ou recebido de um titulo.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ aMatriz := Baixas ( ... )                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ú cNatureza ¿                                                        ³±±
±±³          ³ ú cPrefixo  ´                                                        ³±±
±±³          ³ ú cNumero   ÅÄ ğ Identifica‡„o do t¡tulo.                            ³±±
±±³          ³ ú cParcela  ´                                                        ³±±
±±³          ³ ú cTipo     Ù                                                        ³±±
±±³          ³ ú nMoeda    Moeda em que os valores ser„o processados.               ³±±
±±³          ³ ú cModo ú   R - Receber , P - Pagar                                  ³±±
±±³          ³ ú cFornec   Codigo do Fornecedor (Se Contas a Pagar )                ³±±
±±³          ³ ú lSaldoIni .T. para retornar somente se teve Movimentacao Bancaria  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Espec¡fico para os relat¢rios FinR340 e FinR350.                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsBaixas(cPrefixo,cNumero,cParcela,cTipo,nMoeda,cModo,cFornec,cLoja,dDataRef,lSaldoIni)

Static aMotBaixas

Local cArea   :=Alias()
Local nOrdem  :=0
Local nValor  :=0
Local nMoedaTit
Local lNaoConv
Local aMotBx := {}
Local nI := 0
Local dAntDataBase := dDataBase
Local cFilSE5 := xFilial("SE5")
Default lSaldoIni := .F.

dDataBase := dDataRef

If aMotBaixas == NIL
	// Monto array com codigo e descricao do motivo de baixa
	aMotBx := ReadMotBx()
	aMotBaixas := {}
	For NI := 1 to Len(aMotBx)
		AADD( aMotBaixas,{substr(aMotBx[nI],01,03),substr(aMotBx[nI],07,10)})
	Next
Endif

// Quando eh chamada do Excel, estas variaveis estao em branco
IF Empty(MVABATIM) .Or.;
	Empty(MV_CRNEG) .Or.;
	Empty(MVRECANT) .Or.;
	Empty(MV_CPNEG) .Or.;
	Empty(MVPAGANT) .Or.;
	Empty(MVPROVIS)
	CriaTipos()
Endif

cFornec:=IIF( cFornec == NIL, "", cFornec )
cLoja := IIF( cLoja == NIL, "" , cLoja )
nMoeda:=IIf(nMoeda==NIL,1,nMoeda)
dbSelectArea("SE5")
nOrdem:=IndexOrd()
dbSetOrder(7)
dbSeek(cFilSE5+cPrefixo+cNumero+cParcela+cTipo,.T.)

nMoedaTit := Iif( cModo == "R", SE1-> E1_MOEDA , SE2 -> E2_MOEDA )

While cFilSE5+cPrefixo+cNumero+cParcela+cTipo==SE5->E5_FILIAL+;
	SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO

	//Nas localizacoes e usada a movimentacao bancaria em mais de uma moeda
	//por isso, quando a baixa for contra um banco, devo pegar a E5_VLMOED2,
	//pois na E5_VALOR, estara grvado o movimento na moeda do banco.
	//Bruno. Paraguay 23/08/00
	lNaoConv	:=	(nMoeda == 1 .And.(cPaisLoc=="BRA".Or.Empty(E5_BANCO)))
	Do Case
		Case SE5->E5_DATA > dDataRef
			dbSkip()
			Loop

		Case SE5->E5_SITUACA = "C" .or. ;
			SE5->E5_TIPODOC = "ES"
			dbSkip()
			Loop
			// Despresa as movimenta‡oes diferentes do tipo solicitado somente se
			// o tipo for != de RA e PA, pois neste caso o RECPAG sera invertido.
		Case SE5->E5_RECPAG != cModo .AND. !(SE5->E5_TIPO$MVRECANT+"/"+MVPAGANT)
			dbSkip()
			Loop
		Case TemBxCanc()
			dbSkip()
			Loop
		Case SE5->E5_CLIFOR+SE5->E5_LOJA != cFornec + cLoja
			dbSkip( )
			Loop
		Case SE5->E5_TIPODOC$"VLüBA/V2"
			If lSaldoIni==.F. .Or. (lSaldoIni==.T. .And. !(SE5->E5_TIPODOC$"CP") )
				nValor +=Iif(lNaoConv,SE5->E5_VALOR,xMoeda(SE5->E5_VLMOED2,nMoedaTit,nMoeda,SE5->E5_DATA))
			EndIf
		Case SE5->E5_TIPODOC$"CP" .And. cModo <> "P"
			If lSaldoIni==.F. .Or. (lSaldoIni==.T. .And. !(SE5->E5_TIPODOC$"CP") )
				nValor +=Iif(lNaoConv,SE5->E5_VALOR,xMoeda(SE5->E5_VLMOED2,nMoedaTit,nMoeda,SE5->E5_DATA))
			EndIf
		Case SE5->E5_TIPODOC $ "RA /"+MV_CRNEG
			nValor +=Iif(lNaoConv,SE5->E5_VALOR,xMoeda(SE5->E5_VLMOED2,nMoedaTit,nMoeda,E5_DATA))
		Case SE5->E5_TIPODOC = "PA" .or. SE5->E5_TIPODOC $ MV_CPNEG
			nValor +=Iif(lNaoConv,SE5->E5_VALOR,xMoeda(SE5->E5_VLMOED2,nMoedaTit,nMoeda,E5_DATA))
	EndCase
	dbSkip()
End

//Se o saldo do RA ou PA for menor que o valor do titulo significa que o valor ja foi contabilizado
// e esta diferença deve ser deduzida do total
If cTipo == "RA " .And. cModo == "R" .And. SE1->E1_SALDO < SE1->E1_VALOR
	nValor -= xMoeda(SE1->E1_VALOR-SE1->E1_SALDO,SE1->E1_MOEDA,nMoeda,SE1->E1_VENCREA,8)
EndIf
dDataBase := dAntDataBase

dbSetOrder(nOrdem)
dbSelectArea(cArea)
Return nValor

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsEqpAloc³ Autor ³ Edson Maricate        ³ Data ³ 23-05-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna um array contendo a alocacao da equipe e seu percent. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsEqpAloc(cEquipe,dIni,cHIni,dFim,cHFim,nFilter,cProjeto,cVersao,cAltTrf,aRecAF9,aAE8xAF9)

Local lSeek			:= .T.
Local aAuxAloc		:= {}
Local cHoraRef		:= "00:00"
Local dAuxRef		:= PMS_MAX_DATE
Local dRef			:= PMS_MIN_DATE
Local cAuxHoraRef	:= "24:00"
Local aAloc			:= {}
Local aArea			:= GetArea()
Local aAreaAFA		:= AFA->(GetArea())
Local aAreaAE8		:= AE8->(GetArea())
Local nX            := 0
Local nY            := 0
Local cRecurso		:= ""
Local aAuxRet		:= {}
Local nDecCst		:= TamSX3( "AF9_CUSTO" )[2]
Local nQuant
Local nProduc
Local nAloc

DEFAULT nFilter		:= 1

dbSelectArea("AE8")
dbSetOrder(4)
MsSeek(xFilial()+cEquipe)
While !Eof() .And. xFilial()+cEquipe==AE8_FILIAL+AE8_EQUIP
	cRecurso := AE8->AE8_RECURS

	dbSelectArea("AFA")
	dbSetOrder(3)
	MsSeek(xFilial()+cRecurso)
	While !Eof() .And. xFilial()+cRecurso==AFA_FILIAL+AFA_RECURS
		AF8->(dbSetOrder(1))
		AF8->(MsSeek(xFilial()+AFA->AFA_PROJET))
		AF9->(dbSetOrder(1))
		AF9->(MsSeek(xFilial()+AFA->AFA_PROJET+AFA->AFA_REVISA+AFA->AFA_TAREFA))

		AuxEqpAloc(AFA->AFA_START,AFA->AFA_HORAI,AFA->AFA_FINISH,AFA->AFA_HORAF,AFA->AFA_ALOC,dIni,cHIni,dFim,cHFim,nFilter,cProjeto,cVersao,cAltTrf,@aRecAF9,@aAE8xAF9,@aAuxAloc)

		dbSelectArea("AFA")
		dbSkip()
	End

	dbSelectArea("AJY")
	dbSetOrder(2) //AJY_FILIAL+AJY_RECURS
	AJY->(MsSeek(xFilial("AJY")+cRecurso))
	Do While !AJY->(Eof()) .And. xFilial("AJY")+cRecurso==AJY_FILIAL+AJY_RECURS

		// Procura insumo nos projetos
		dbSelectArea("AEL")
            AEL->(dbSetOrder(2)) //AEL_FILIAL+AEL_PROJET+AEL_REVISA+AEL_INSUMO
		AEL->(MsSeek(xFilial("AEL")+AJY->AJY_PROJET+AJY->AJY_REVISA+AJY->AJY_INSUMO))
		Do While !AEL->(Eof()) .And. xFilial("AEL")+AJY->(AJY_PROJET+AJY_REVISA+AJY_INSUMO)==AEL->(AEL_FILIAL+AEL_PROJET+AEL_REVISA+AEL_INSUMO)
			AF8->(dbSetOrder(1))
			AF8->(MsSeek(xFilial("AF8")+AJY->AJY_PROJET))
			AF9->(dbSetOrder(1))
			AF9->(MsSeek(xFilial("AF9")+AJY->AJY_PROJET+AJY->AJY_REVISA+AEL->AEL_TAREFA))

			nProduc := 1
			If AF9->AF9_TIPO<>'1'
				nProduc := AF9->AF9_PRODUC / nProduc
			EndIf
			nQuant	:= AEL->AEL_QUANT
			nQuant	:= pmsTrunca( "2", nQuant/nProduc, nDecCst )
			nQuant	:= pmsTrunca( "2", nQuant * AF9->AF9_QUANT, nDecCst )
			nAloc	:= (nQuant / AF9->AF9_HDURAC) * 100

			aAuxRet := PMSDTaskF(AEL->AEL_DATPRF,"00:00",AF9->AF9_CALEND,nQuant,AF9->AF9_PROJET,Nil)

			AuxEqpAloc(aAuxRet[1],aAuxRet[2],aAuxRet[3],aAuxRet[4],nAloc,dIni,cHIni,dFim,cHFim,nFilter,cProjeto,cVersao,cAltTrf,@aRecAF9,@aAE8xAF9,@aAuxAloc)

			dbSelectArea("AEL")
			AEL->(dbSkip())
		EndDo

		// Procura insumo nas subcomps
		dbSelectArea("AEN")
		AEN->(dbSetOrder(1)) //AEN_FILIAL+AEN_PROJET+AEN_REVISA+AEN_TAREFA+AEN_ITEM
		AEN->(MsSeek(xFilial("AEN")+AJY->AJY_PROJET+AJY->AJY_REVISA))
		Do While !AEN->(Eof()) .And. xFilial("AEN")+AJY->(AJY_PROJET+AJY_REVISA)==AEN->(AEN_FILIAL+AEN_PROJET+AEN_REVISA)

			If AF9->AF9_TIPO<>'1'
				nProduc := AF9->AF9_PRODUC
			Else
				nProduc := 1
			EndIf

			AuxEqpAlCU(AEN->AEN_SUBCOM,AF9->AF9_QUANT * AEN->AEN_QUANT,nProduc,AEN->AEN_DATPRF,dIni,cHIni,dFim,cHFim,nFilter,cProjeto,cVersao,cAltTrf,@aRecAF9,@aAE8xAF9,@aAuxAloc)

			dbSelectArea("AEN")
			AEN->(dbSkip())
		EndDo

		dbSelectArea("AJY")
		AJY->(dbSkip())
	EndDo

	dbSelectArea("AE8")
	dbSkip()
End
While lSeek
	lSeek := .F.
	For nx := 1 to Len(aAuxAloc)
		If DTOS(aAuxAloc[nx,1])+aAuxAloc[nx,2]>DTOS(dRef)+cHoraRef .And. ;
			DTOS(aAuxAloc[nx,1])+aAuxAloc[nx,2]<DTOS(dAuxRef)+cAuxHoraRef
			lSeek	:= .T.
			dAuxRef	:= aAuxAloc[nx,1]
			cAuxHoraRef:= aAuxAloc[nx,2]
		EndIf
		If DTOS(aAuxAloc[nx,3])+aAuxAloc[nx,4]>DTOS(dRef)+cHoraRef .And.;
			DTOS(aAuxAloc[nx,3])+aAuxAloc[nx,4]<DTOS(dAuxRef)+cAuxHoraRef
			lSeek	:= .T.
			dAuxRef	:= aAuxAloc[nx,3]
			cAuxHoraRef:= aAuxAloc[nx,4]
		EndIf
	Next
	If lSeek
		dRef := dAuxRef
		cHoraRef := cAuxHoraRef
		aAdd(aAloc,{dAuxRef,cAuxHoraRef,0})


		dAuxRef		:= PMS_MAX_DATE
		cAuxHoraRef	:= "24:00"
	EndIf
End
For nx := 1 to Len(aAloc)-1
	dIni	:= aAloc[nx,1]
	cHIni	:= aAloc[nx,2]
	dFim	:= aAloc[nx+1,1]
	cHFim	:= aAloc[nx+1,2]
	For ny := 1 to Len(aAuxAloc)
		If  ((DTOS(aAuxAloc[ny,1])+aAuxAloc[ny,2] > DTOS(dIni)+cHIni .And.;
			DTOS(aAuxAloc[ny,1])+aAuxAloc[ny,2] < DTOS(dFim)+cHFim) .Or.;
			(DTOS(aAuxAloc[ny,3])+aAuxAloc[ny,4] > DTOS(dIni)+cHIni .And.;
			DTOS(aAuxAloc[ny,3])+aAuxAloc[ny,4] < DTOS(dFim)+cHFim)) .Or.;
			((DTOS(aAuxAloc[ny,1])+aAuxAloc[ny,2]<= DTOS(dIni)+cHIni .And.;
			DTOS(aAuxAloc[ny,3])+aAuxAloc[ny,4] >= DTOS(dFim)+cHFim))
			aAloc[nx,3] += aAuxAloc[ny,5]
		EndIf
	Next
Next

RestArea(aAreaAE8)
RestArea(aAreaAFA)
RestArea(aArea)
Return aAloc

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaCanAltAFF³ Autor ³ Edson Maricate       ³ Data ³27.05.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Verifica se uma confirmacao pode ser excluida .              ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela de confirmacoes                       ³±±
±±³          ³ExpL2: Indica se o help deve ser disparado                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: .T. - Se a confirmacao pode ser excluida              ³±±
±±³          ³       .F. - Se a confirmacao nao pode ser excluida          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo verificar se a confirmacao     ³±±
±±³          ³pode ser excluida sem maiores problemas para a integridade   ³±±
±±³          ³do sistema                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAPMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaCanAltAFF(cAliasAFF,lHelp)

Local lRet		:= .T.
Local aArea		:= GetArea()

DEFAULT lHelp := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a amarracao com os contratos de parceira para geracao de AEs   ³
//³ automaticas.                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AJ9")
dbSetOrder(1)
dbSeek(xFilial()+AFF->AFF_PROJET+AFF->AFF_REVISA+AFF->AFF_TAREFA+DTOS(AFF->AFF_DATA))
While !Eof() .And. 	xFilial()+AFF->AFF_PROJET+AFF->AFF_REVISA+AFF->AFF_TAREFA+DTOS(AFF->AFF_DATA)==AJ9->AJ9_FILIAL+AJ9->AJ9_PROJET+AJ9->AJ9_REVISA+AJ9_TAREFA+DTOS(AJ9->AJ9_DATA)
	dbSelectArea("SC7")
	dbSetOrder(1)
	If dbSeek(xFilial()+AJ9->AJ9_NUMAE+AJ9->AJ9_ITEMAE)
		If !MaCanDelPC("SC7",.F.)
			If lHelp
				Aviso(STR0098,STR0099+SC7->C7_NUM+"/"+SC7->C7_ITEM+STR0100,{STR0101},2 )   //"Operacao Invalida."###"Esta confirmacao nao podera ser alterada/excluida pois a Autorizacao de Entrega Num. "###" gerada automaticamente por esta confirmacao ja foi parcialmente ou totalmente atendida."
			EndIf
			lRet := .F.
			Exit
		EndIf
	EndIf
	dbSelectArea("AJ9")
	dbSkip()
End

RestArea(aArea)
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PmsDlgAF8Eq³ Autor ³ Adriano Ueda         ³ Data ³03.06.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina permite a chamada do grafico de alocacao de      ³±±
±±³          ³equipes a partir dos programas PMSA200, PMSA410              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PMSA200, PMSA410                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PmsDlgAF8Eqp(cVersao,oTree,cArquivo)

Local aConfig := {6,.F.,.T.,.T.,.T.,3}
Local dIni
Local aDependencia := {}
Local aGantt
Local nTsk
Local lRet		:= .T.
Local nTop      := oMainWnd:nTop+23
Local nLeft     := oMainWnd:nLeft+5
Local nBottom   := oMainWnd:nBottom-60
Local nRight    := oMainWnd:nRight-10

PmsCfgEqp(cVersao,,aConfig,dIni,aGantt)

While lRet
	MsgRun(STR0123 ,cCadastro,{|| lRet := AuxDlgAF8Eqp(@cVersao,@aConfig,@dIni,@aGantt,@nTsk,nTop,nLeft,nBottom,nRight,oTree,cArquivo,@aDependencia) })
End

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AuxDlgAF8Eq³ Autor ³ Adriano Ueda         ³ Data ³03.06.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina permite a chamada do grafico de alocacao de      ³±±
±±³          ³equipes a partir dos programas PMSA200, PMSA410              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PMSA200, PMSA410                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AuxDlgAF8Eqp(cVersao, aConfig, dIniGnt, aGantt, nTsk, nTop, nLeft, nBottom, nRight,oTree,cArquivo,aDependencia)
Local lRet := .F.

Local aRecAF9	:= {}
Local aAreaAE8 := AE8->(GetArea())
Local aAreaAED := AED->(GetArea())
Local aAreaAF8 := AF8->(GetArea())
Local aAreaAFA := AFA->(GetArea())

Local oFont
Local oDlg

Local nZ		:= 0
Local nX		:= 0
Local nUMaxEqp	:= 0
Local aEqp		:= {}

Local aCorBarras:= LoadCorBarra( "MV_PMSACOR" )
Local aRGB		:= {}
Local cAlias
Local nRecAlias

Local nLenRec	:=	30
Local nLenTar	:=	75
Local aButtons	:= {}

If oTree!= Nil
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecAlias	:= Val(SubStr(oTree:GetCargo(),4,12))
Else
	cAlias := (cArquivo)->ALIAS
	nRecAlias := (cArquivo)->RECNO
EndIf

RegToMemory("AFA",.T.)
RegToMemory("AFB",.T.)

If aGantt == Nil
	aGantt := {}

	aAuxArea := AF8->(GetArea())
	aRecursos:= {}
	If cAlias == "AF8"
		dbSelectArea("AF8")
		dbGoto(nRecAlias)
		dbSelectArea("AFC")
		dbSetOrder(1)
		dbSeek(xFilial()+AF8->AF8_PROJET+cVersao+Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)))
		PmsLoadRec(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,aRecursos)
	ElseIf cAlias == "AFC"
		dbSelectArea("AFC")
		dbGoto(nRecAlias)
		PmsLoadRec(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,aRecursos)
	ElseIf cAlias == "AF9"
		dbSelectArea("AF9")
		dbGoto(nRecAlias)
		PmsLoadRec(AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA,aRecursos,.T.)
	Endif


	For nZ := 1 to Len(aRecursos)
		AE8->(dbSetOrder(1))
		AE8->(MsSeek(xFilial()+aRecursos[nz]))

		dbSelectArea("AED")
		dbSetOrder(1)
		If !Empty(AE8->AE8_EQUIP) .And. MsSeek(xFilial()+AE8->AE8_EQUIP) .And. aScan(aEqp,AE8->AE8_EQUIP) <= 0
			aAdd(aEqp,AE8->AE8_EQUIP)
			aRecAF9	:= {}
			If cAlias == "AF9"
				aAloc := PmsEqpAloc(AED->AED_EQUIP,AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,aCOnfig[6],AF9->AF9_PROJET,cVersao,,aRecAF9)
			Else
				aAloc := PmsEqpAloc(AED->AED_EQUIP,AFC->AFC_START,AFC->AFC_HORAI,AFC->AFC_FINISH,AFC->AFC_HORAF,aCOnfig[6],AFC->AFC_PROJET,cVersao,,aRecAF9)
			EndIf
			nUMaxEqp := UMaxEquip(AED->AED_EQUIP)

			If !Empty(aAloc)
				aAdd(aGantt,{{"",AED->AED_EQUIP,AED->AED_DESCRI},{},CLR_HBLUE,})
				nLenRec	:=	 Max(nLenRec,Len(Alltrim(AED->AED_EQUIP))*3.7)

				For nx := 1 to Len(aAloc)-1
					If aAloc[nx,3] > 0
						dIni	:= aAloc[nx,1]
						cHIni	:= aAloc[nx,2]
						dFim	:= aAloc[nx+1,1]
						cHFim	:= aAloc[nx+1,2]
						cView	:= "PmsDispBox({	{'"+STR0130+"','"+AED->AED_EQUIP+"'},"+;  //'Equipe '
						"	{'"+STR0131+"','"+AED->AED_DESCRI+"'},"+; //'Descricao'
						"	{'"+STR0132+"','"+Transform(nUMaxEqp, "@E 9999.99%")+"'},"+; //'% Aloc.Max.'
						"	{'"+STR0133+"','"+DTOC(dIni)+"-"+cHIni+"'},"+; //'Data Inicial'
						"	{'"+STR0134+"','"+DTOC(dFim)+"-"+cHFim+"'},"+; //'Data Final'
						"	{'"+STR0135+"','"+Transform(aAloc[nx,3],"@E 9999.99%")+"'}},2,'"+STR0136+"',{40,120},,1)"

						// o calculo do tom da cor e feito atraves de regra de tres, sendo:
						//
						// 255 - o valor maximo possivel para o tom de verde (alocacao minima)
						// 075 - o valor minimo possivel para o tom de verde (alocacao maxima)
						aRGB := ValorCorBarra( "2" ,aCorBarras ,2 )
						aAdd(aGantt[Len(aGantt),2],{dIni,cHIni,dFim,cHFim,"",If(aAloc[nx,3]>nUMaxEqp,ValorCorBarra( "1" ,aCorBarras ) ;
						,RGB( (255-Int(aAloc[nx,3]/nUMaxEqp*((255-aRGB[1])))) ,(255-Int(aAloc[nx,3]/nUMaxEqp*((255-aRGB[2])))) ,(255-Int(aAloc[nx,3]/nUMaxEqp*((255-aRGB[3])))) ) ;
						),cView,2,CLR_BLACK})
					EndIf
				Next nx
				If aConfig[5]
					For nx := 1 to Len(aRecAF9)
						dbSelectArea("AF9")
						dbGoto(aRecAF9[nx])

						dbSelectArea("AF9")
						nColor	:=	RGB( (255-Int(MAx(AF9->AF9_PRIORI,100)/10*((255-ValorCorBarra( "3" ,aCorBarras,2 )[1])/100))) ,(255-Int(Max(AF9->AF9_PRIORI,100)/10*((255-ValorCorBarra( "3" ,aCorBarras,2 )[2])/100))) ,(255-Int(Max(AF9->AF9_PRIORI,100)/10*((255-ValorCorBarra( "3" ,aCorBarras,2 )[3])/100))) )
						Do Case
							Case !Empty(AF9->AF9_DTATUF)
								aAdd(aGantt,{{AF9->AF9_PROJET+AF9->AF9_REVISA+"/"+AF9->AF9_TAREFA,"",""},{{AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,"["+AllTrim(AF9->AF9_PROJET)+AF9->AF9_TAREFA+"]:"+Alltrim(AF9->AF9_DESCRI)+" POC :"+AllTrim(TransForm(PmsPOCAF9(AF9_PROJET,AF9_REVISA,AF9_TAREFA,PMS_MAX_DATE,AF9->AF9_QUANT),"@E 999.99%")),,"PmsViewTask("+STR(AF9->(RecNo()))+")",1,CLR_GRAY}},nColor ,})
							Case !Empty(AF9->AF9_DTATUI)
								aAdd(aGantt,{{AF9->AF9_PROJET+AF9->AF9_REVISA+"/"+AF9->AF9_TAREFA,"",""},{{AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,"["+AllTrim(AF9->AF9_PROJET)+AF9->AF9_TAREFA+"]:"+Alltrim(AF9->AF9_DESCRI)+" POC :"+AllTrim(TransForm(PmsPOCAF9(AF9_PROJET,AF9_REVISA,AF9_TAREFA,PMS_MAX_DATE,AF9->AF9_QUANT),"@E 999.99%")),,"PmsViewTask("+STR(AF9->(RecNo()))+")",1,CLR_BROWN}},nColor ,})
							Case dDataBase > AF9->AF9_START
								aAdd(aGantt,{{AF9->AF9_PROJET+AF9->AF9_REVISA+"/"+AF9->AF9_TAREFA,"",""},{{AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,"["+AllTrim(AF9->AF9_PROJET)+AF9->AF9_TAREFA+"]:"+Alltrim(AF9->AF9_DESCRI)+" POC :"+AllTrim(TransForm(PmsPOCAF9(AF9_PROJET,AF9_REVISA,AF9_TAREFA,PMS_MAX_DATE,AF9->AF9_QUANT),"@E 999.99%")),,"PmsViewTask("+STR(AF9->(RecNo()))+")",1,CLR_HRED}},nColor ,})
							OtherWise
								aAdd(aGantt,{{AF9->AF9_PROJET+AF9->AF9_REVISA+"/"+AF9->AF9_TAREFA,"",""},{{AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,"["+AllTrim(AF9->AF9_PROJET)+AF9->AF9_TAREFA+"]:"+Alltrim(AF9->AF9_DESCRI)+" POC :"+AllTrim(TransForm(PmsPOCAF9(AF9_PROJET,AF9_REVISA,AF9_TAREFA,PMS_MAX_DATE,AF9->AF9_QUANT),"@E 999.99%")),,"PmsViewTask("+STR(AF9->(RecNo()))+")",1,CLR_GREEN}},nColor ,})
						EndCase
						// o fator eh 3 porque geralmente a tarefa esta composta por numeros.
						nLenTar	:=	 Max(nLenTar,Len(Alltrim(AF9->AF9_PROJET+AF9->AF9_REVISA+"/"+AF9->AF9_TAREFA))*3)
						dbSelectArea("AFD")
						dbSetOrder(1)
						If MsSeek(xFilial("AFD")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
							While !AFD->(EOF()) .And. xFilial("AFD")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA
								nPos := aScan( aDependencia ,{|aTarefa| aTarefa[1] == AFD->AFD_PROJET+AFD->AFD_REVISA+"/"+AFD->AFD_TAREFA})
								If nPos > 0
									aadd( aDependencia[nPos,2],{ AFD->AFD_PROJET+AFD->AFD_REVISA+"/"+AFD->AFD_PREDEC ,AFD->AFD_TIPO } )
								Else
									aadd( aDependencia ,{ AFD->AFD_PROJET+AFD->AFD_REVISA+"/"+AFD->AFD_TAREFA ,{ {AFD->AFD_PROJET+AFD->AFD_REVISA+"/"+AFD->AFD_PREDEC ,AFD->AFD_TIPO} }} )
								Endif
								AFD->(dbSkip())
							End
						EndIf
					Next nx
				EndIf
			EndIf
		EndIf
	Next nZ
EndIf

// visualizacao do grafico
If Empty(aGantt)
	Aviso(STR0120, STR0121,{STR0122},2)
Else
	DEFINE FONT oFont NAME "Arial" SIZE 0, -10
	DEFINE MSDIALOG oDlg TITLE STR0190 OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight
	oDlg:lMaximized := .T.

	AADD(aButtons, {BMP_OPCOES			, {|| If(PmsCfgEqp(cVersao, @oDlg,aConfig,@dIniGnt,aGantt),(oDlg:End(),lRet := .T.),Nil) }, TIP_OPCOES })
	AADD(aButtons, {BMP_RETROCEDER_CAL	, {|| (PmsPrvGnt(cVersao,@oDlg,aConfig,@dCfgIni,aGantt,@nTsk),oDlg:End(),lRet := .T.) }	, TIP_RETROCEDER_CAL})
	AADD(aButtons, {BMP_AVANCAR_CAL		, {|| (PmsNxtGnt(cVersao,@oDlg,aConfig,@dIniGnt,aGantt,@nTsk),oDlg:End(),lRet := .T.) }	, TIP_AVANCAR_CAL })
	AADD(aButtons, {BMP_CORES			, {|| {PMSColorGantt("MV_PMSACOR") ,oDlg:End() ,lRet := .T. ,lAtualiza := .T.} }			, TIP_CORES})
	EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()},,aButtons,,,,,.F.,.F.)


	PmsGantt(aGantt,aConfig,@dIniGnt,,oDlg,{14,1,(nBottom/2)-40,(nRight/2)-4},{{STR0191,nLenTar},{STR0128,nLenRec},{STR0129,115}},@nTsk ,aDependencia,,,,{1,2,3})

	ACTIVATE MSDIALOG oDlg
EndIf

RestArea(aAreaAED)
RestArea(aAreaAE8)
RestArea(aAreaAF8)
RestArea(aAreaAFA)
Return lRet



Function PmsGrvAJA(cProjeto,cRevisa,cEDT,cTarefa,cItem)
Local aArea	:= GetArea()

RecLock("AJA",.T.)
AJA->AJA_FILIAL := xFilial("AJA")
AJA->AJA_PROJET	:= cProjeto
AJA->AJA_REVISA	:= cRevisa
AJA->AJA_EDT	:= cEDT
AJA->AJA_TAREFA	:= cTarefa
AJA->AJA_ITEM	:= cItem
AJA->AJA_NUMPV	:= SC9->C9_PEDIDO
AJA->AJA_ITEMPV	:= SC9->C9_ITEM
AJA->AJA_SEQUEN	:= SC9->C9_SEQUEN
AJA->AJA_PRODUT	:= SC9->C9_PRODUTO
MsUnlock()

RestArea(aArea)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsCfgEqp³ Autor ³ Adriano Ueda           ³ Data ³ 01-08-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exibe uma tela com as configuracoes de visualizacao do Gantt  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsCfgEqp(cVersao,oDlg,aConfig,dIni,aGantt)
Local lRet		:= .F.
Local aOldCfg	:= aClone(aConfig)


If ParamBox({	{3,STR0138,aConfig[1],{STR0139, STR0140, STR0141, STR0142, STR0143, STR0144},70,,.F.},;  //"Escala de Tempo"###"Diario"###"Semanal"###"Mensal"###"Mensal (Zoom 30%)"###"Bimestral"###"Melhor escala"
	{4,STR0145,aConfig[2],STR0191,45,,.F.},;  //"Exibir detalhes :"######"Codigo"
	{4,"",aConfig[3],STR0146,40,,.F.},;  //"Exibir detalhes :"######"Codigo"
	{4,"",aConfig[4],STR0147,40,,.F.},;  //"Descricao"
	{4,"",aConfig[5],STR0148,45,,.F.},;  //"Exibir Tarefas"
	{3,STR0151,aConfig[6],{STR0152,STR0153,STR0154},60,,.F.}},STR0155,aConfig)  //"Considerar"###"Todas as tarefas"###"Tarefas finalizadas"###"Tarefas a executar"###"Parametros"

	If aOldCfg[1] != aConfig[1]
		dIni := PMS_EMPTY_DATE
	EndIf
	lRet := .T.
	If aConfig[5]!=aOldCfg[5]
		aGantt	:= Nil
	EndIf
	If aConfig[6]!=aOldCfg[6]
		aGantt	:= Nil
	EndIf
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QbTexto   ºAutor  ³Paulo Carnelossi    º Data ³  02/09/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Quebra o Texto de acordo com tamnho e separador informado   º±±
±±º          ³devolvendo um array com a string quebrada                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QbTexto(cTexto, nTamanho, cSeparador)
Local aString := {}, nTamAux := nTamanho
Local nPos, nCtd, nTamOri := Len(cTexto), cAuxTexto

If Len(Trim(cTexto)) > 0

	If Len(Trim(cTexto)) <= nTamanho

		If Len(Trim(cTexto)) > 0
			aAdd(aString, AllTrim(cTexto) )
		EndIf

	Else

		If (nPos := At(cSeparador, cTexto)) != 0

			For nCtd := 1 TO nTamOri STEP nTamAux

				cAuxTexto := Subs(cTexto, nCtd, nTamanho)

				If nCtd+nTamanho < nTamOri
					While Len(Subs(cAuxTexto, Len(cAuxTexto), 1)) > 0 .And. ;
						Subs(cAuxTexto, Len(cAuxTexto), 1) <> cSeparador

						cAuxTexto := Subs(cAuxTexto, 1, Len(cAuxTexto)-1)

					End
				EndIf

				If Len(cAuxTexto) > 0
					cAuxTexto 	:= Subs(cTexto, nCtd, Len(cAuxTexto))
					nTamAux 		:= Len(cAuxTexto)
				Else
					cAuxTexto := Subs(cTexto, nCtd, nTamanho)
					nTamAux 		:= nTamanho
				EndIf

				If Len(Trim(cAuxTexto)) > 0
					aAdd(aString, Alltrim(cAuxTexto))
				EndIf
			Next

		Else

			For nCtd := 1 TO nTamOri STEP nTamanho
				If Len(Subs(cTexto, nCtd, nTamanho)) > 0
					If Len(Trim(Subs(cTexto, nCtd, nTamanho))) > 0
						aAdd(aString, AllTrim(Subs(cTexto, nCtd, nTamanho)))
					EndIf
				EndIf
			Next

		EndIf

	EndIf
Else
	aAdd(aString, Space(nTamanho))
EndIf

Return aString
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsCpoInicºAutor  ³Paulo Carnelossi    º Data ³  26/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inicializador padrao para quando chamar diretamente do ger. º±±
±±º          ³de apontamento/Execucao ja sugere Cod. Projeto ou da Tarefa º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsCpoInic(cCampo)
Local xRet

Do Case
	Case cCampo == 'AFR_PROJET'
		xRet := If(Type("lCallPrj")<>"U".And.Valtype(lCallPrj)=="L".And.lCallPrj, _cProjCod, SPACE(LEN(AFR->AFR_PROJET)))
	Case cCampo == 'AFR_TAREFA'
		xRet := If(Type("lCallPrj")<>"U".And.Valtype(lCallPrj)=="L".And.lCallPrj, _cTarefa, SPACE(LEN(AFR->AFR_TAREFA)))
	Case cCampo == 'AFR_REVISA'
		xRet := If(Type("lCallPrj")<>"U".And.Valtype(lCallPrj)=="L".And.lCallPrj, cRevisa, SPACE(LEN(AFR->AFR_REVISA)))
	Case cCampo == 'AFL_PROJET'
		xRet := If(Type("lCallPrj")<>"U".And.Valtype(lCallPrj)=="L".And.lCallPrj, _cProjCod, SPACE(LEN(AFL->AFL_PROJET)))
	Case cCampo == 'AFL_TAREFA'
		xRet := If(Type("lCallPrj")<>"U".And.Valtype(lCallPrj)=="L".And.lCallPrj, _cTarefa, SPACE(LEN(AFL->AFL_TAREFA)))
	Case cCampo == 'AFL_REVISA'
		xRet := If(Type("lCallPrj")<>"U".And.Valtype(lCallPrj)=="L".And.lCallPrj, cRevisa, SPACE(LEN(AFL->AFL_REVISA)))
	Case cCampo == 'AFG_PROJET'
		xRet := If(Type("lCallPrj")<>"U".And.Valtype(lCallPrj)=="L".And.lCallPrj, _cProjCod, SPACE(LEN(AFG->AFG_PROJET)))
	Case cCampo == 'AFG_TAREFA'
		xRet := If(Type("lCallPrj")<>"U".And.Valtype(lCallPrj)=="L".And.lCallPrj, _cTarefa, SPACE(LEN(AFG->AFG_TAREFA)))
	Case cCampo == 'AFG_REVISA'
		xRet := If(Type("lCallPrj")<>"U".And.Valtype(lCallPrj)=="L".And.lCallPrj, cRevisa, SPACE(LEN(AFG->AFG_REVISA)))
	Case cCampo == 'AFH_PROJET'
		xRet := If(Type("lCallPrj")<>"U".And.Valtype(lCallPrj)=="L".And.lCallPrj, _cProjCod, SPACE(LEN(AFH->AFH_PROJET)))
	Case cCampo == 'AFH_TAREFA'
		xRet := If(Type("lCallPrj")<>"U".And.Valtype(lCallPrj)=="L".And.lCallPrj, _cTarefa, SPACE(LEN(AFH->AFH_TAREFA)))
	Case cCampo == 'AFH_REVISA'
		xRet := If(Type("lCallPrj")<>"U".And.Valtype(lCallPrj)=="L".And.lCallPrj, cRevisa, SPACE(LEN(AFH->AFH_REVISA)))
	Case cCampo == 'AFM_PROJET'
		xRet := If(Type("lCallPrj")<>"U".And.Valtype(lCallPrj)=="L".And.lCallPrj, _cProjCod, SPACE(LEN(AFM->AFM_PROJET)))
	Case cCampo == 'AFM_TAREFA'
		xRet := If(Type("lCallPrj")<>"U".And.Valtype(lCallPrj)=="L".And.lCallPrj, _cTarefa, SPACE(LEN(AFM->AFM_TAREFA)))
	Case cCampo == 'AFM_REVISA'
		xRet := If(Type("lCallPrj")<>"U".And.Valtype(lCallPrj)=="L".And.lCallPrj, cRevisa, SPACE(LEN(AFM->AFM_REVISA)))
	Case cCampo == 'AFN_PROJET'
		xRet := If(Type("lCallPrj")<>"U".And.Valtype(lCallPrj)=="L".And.lCallPrj, _cProjCod, SPACE(LEN(AFN->AFN_PROJET)))
	Case cCampo == 'AFN_TAREFA'
		xRet := If(Type("lCallPrj")<>"U".And.Valtype(lCallPrj)=="L".And.lCallPrj, _cTarefa, SPACE(LEN(AFN->AFN_TAREFA)))
	Case cCampo == 'AFN_REVISA'
		xRet := If(Type("lCallPrj")<>"U".And.Valtype(lCallPrj)=="L".And.lCallPrj, cRevisa, SPACE(LEN(AFN->AFN_REVISA)))
	Case cCampo == 'AFT_PROJET'
		xRet := If(Type("lCallPrj")<>"U".And.Valtype(lCallPrj)=="L".And.lCallPrj, _cProjCod, SPACE(LEN(AFT->AFT_PROJET)))
	Case cCampo == 'AFT_TAREFA'
		xRet := If(Type("lCallPrj")<>"U".And.Valtype(lCallPrj)=="L".And.lCallPrj, _cTarefa, SPACE(LEN(AFT->AFT_TAREFA)))
	Case cCampo == 'AFT_REVISA'
		xRet := If(Type("lCallPrj")<>"U".And.Valtype(lCallPrj)=="L".And.lCallPrj, cRevisa, SPACE(LEN(AFT->AFT_REVISA)))
	Case cCampo == 'D3_PROJPMS'
		xRet := If(Type("lCallPrj")<>"U".And.Valtype(lCallPrj)=="L".And.lCallPrj, _cProjCod, SPACE(LEN(SD3->D3_PROJPMS)))
	Case cCampo == 'D3_TASKPMS'
		xRet := If(Type("lCallPrj")<>"U".And.Valtype(lCallPrj)=="L".And.lCallPrj, _cTarefa, SPACE(LEN(SD3->D3_TASKPMS)))
	Case cCampo == 'AFJ_PROJET'
		xRet := If(Type("lCallPrj")<>"U".And.Valtype(lCallPrj)=="L".And.lCallPrj, _cProjCod, SPACE(LEN(AFJ->AFJ_PROJET)))
EndCase

Return xRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsIAFAQuant³ Autor ³ Edson Maricate        ³ Data ³04-05-2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que calcula a quantidade do produto do projeto			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsIAFAQuant(cProjeto,cRevisa,cTarefa,cProduto,nQuantTsk,nQuantPrdT,nDuracTsk,lCompos,cRecurso)
Local nRet    := 0
Local cPmsCust:= GetMV("MV_PMSCUST") //Indica se utiliza o custo pela quantidade unitaria ou total

DEFAULT cProjeto := AF8->AF8_PROJET
DEFAULT cRevisa  := AF8->AF8_REVISA
DEFAULT cTarefa  := AF9->AF9_TAREFA
DEFAULT cProduto := AFA->AFA_PRODUTO
DEFAULT nQuantTsk:= 1
DEFAULT nQuantPrdT:= 1
DEFAULT nDuracTsk:= AF9->AF9_HDURAC
DEFAULT cRecurso := AFA->AFA_RECURS
DEFAULT lCompos  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica qual o tipo do calculo sera utilizado 1= Padrao 2=Template³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistTemplate("CCTIAFAQUANT") .And. (GetMV("MV_PMSCCT") == "2")
	nRet:= ExecTemplate("CCTIAFAQUANT",.F.,.F.,{cProjeto,cRevisa,cTarefa,cProduto,nQuantTsk,nQuantPrdT,nDuracTsk,lCompos,cRecurso})
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se for importacao de composicao deve calcular o valor       ³
	//³ proporcional da quantidade do produto em relacao da tarefa  ³
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	If lCompos
		nRet:= nQuantPrdT / nQuantTsk
	Else
		nRet:= IIf(cPmsCust == "1",nQuantPrdT,nQuantPrdT / nQuantTsk )
	EndIf
EndIf

Return(nRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |PmsSD1Quant³ Autor ³ Edson Maricate         ³ Data ³ 30-06-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a quantidade referencial do D1_QUANT de acordo com o   ³±±
±±³          ³ tipo de NF. Esta funcao sempre deve ser utilizada nos calculos ³±±
±±³          ³ onde a quantidade do D1_QUANT e referenciada pois o mesmo pode ³±±
±±³          ³ ser compreendido como 100 ( NF de Frete e Desp. de Importacao) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsSD1QUANT(cAliasSD1,cAliasAFN)
Local nRet        := 0
Local aNFfrete
Local nQtdeProj   := 0
Local nQtdeTot    := 0
DEFAULT cAliasSD1 := "SD1"
DEFAULT cAliasAFN := "AFN"

//Tratamento feito para quando tipo da NF for Complemento de preco/frete
// pois quando for, a quantidade sera igual a 0
// para considerar esse valor, passarei quantidade igual a 1
If (cAliasSD1)->D1_TIPO == "C" .AND. (cAliasSD1)->D1_QUANT == 0
	nRet := 1
Else
	If (cAliasSD1)->D1_ORIGLAN == "DP" .Or. (cAliasSD1)->D1_ORIGLAN == "FR"

		aNFfrete := {}
		Aadd(aNFfrete,(cAliasAFN)->AFN_DOC)
		Aadd(aNFfrete,(cAliasAFN)->AFN_SERIE)
		Aadd(aNFfrete,(cAliasAFN)->AFN_FORNEC)
		Aadd(aNFfrete,(cAliasAFN)->AFN_LOJA)
		Aadd(aNFfrete,(cAliasAFN)->AFN_PROJET)
		Aadd(aNFfrete,(cAliasAFN)->AFN_REVISA)
		Aadd(aNFfrete,(cAliasAFN)->AFN_TAREFA)
		Aadd(aNFfrete,(cAliasAFN)->AFN_COD)
		QTDEFRETE(aNFfrete , @nQtdeProj, @nQtdeTot)

		nRet := nQtdeTot
	Else
		nRet := (cAliasSD1)->D1_QUANT
	EndIf
EndIf

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |PmsAFNQuant³ Autor ³ Edson Maricate         ³ Data ³ 30-06-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a quantidade referencial do AFN_QUANT de acordo com o  ³±±
±±³          ³ tipo de NF. Esta funcao sempre deve ser utilizada nos calculos ³±±
±±³          ³ onde a quantidade do AFN_QUANT e referenciada pois o mesmo pode³±±
±±³          ³ ser compreendido como 0 ( NF de Frete e Desp. de Importacao)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAFNQUANT(cRet,cAliasAFN,cAliasSD1,cOrigem)
local aArea		:= {}
local aAreaAFS	:= {}
local aAreaSD2	:= {}
local aNFfrete
local nQtdeProj	:= 0
local nQtdeTot	:= 0
local nRet			:= 0

DEFAULT cAliasAFN	:= "AFN"
DEFAULT cAliasSD1	:= "SD1"
DEFAULT cOrigem     := ""
//Tratamento feito para quando tipo da NF for Complemento de preco/frete
// pois quando for, a quantidade sera igual a 0
// Após ajuste da gravação da AFN no complemento de frete colhemos a quantidade, esta proprocional ao vateio do projeto
If (cAliasAFN)->AFN_TIPONF == "C" .AND. (cAliasSD1)->D1_QUANT==0
	If (cAliasSD1)->D1_ORIGLAN == "FR"
		nRet := (cAliasAFN)->AFN_QUANT
	Else
		nRet := 1
	EndIf

// É um documento de entrada de devolução
elseIf (cAliasAFN)->AFN_TIPONF == "D"

	aArea := GetArea()
	dbSelectArea("AFS")
	aAreaAFS := GetArea()
	dbSetOrder(2) // AFS_FILIAL+AFS_COD+AFS_LOCAL+DTOS(AFS_EMISSA)+AFS_NUMSEQ+AFS_PROJET+AFS_REVISA+AFS_TAREFA
	dbSelectArea("SD2")
	aAreaSD2 := GetArea()
	dbSetOrder(3) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	// Busco pelo documento de saida de origem
	If dbSeek(xFilial("SD2")+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasAFN)->AFN_COD+(cAliasSD1)->D1_ITEMORI)
		dbSelectArea("AFS")
		// busco associacao o projeto e tarefa associado a nota fiscal de saida
		If dbSeek(xFilial("AFS")+SD2->D2_COD+SD2->D2_LOCAL+DTOS(SD2->D2_EMISSAO)+SD2->D2_NUMSEQ+(cAliasAFN)->AFN_PROJET+(cAliasAFN)->AFN_REVISA)
			// quando houver a associacao com um projeto e edt/tarefa, será unico
			// Pois no pedido de venda que gera o documento de saida não é possivel
			// ratear um item em varios projetos e/ou edts e tarefas.
			nRet := 0 // Anulo o valor do documento de entrada
		EndIf
	EndIf
	RestArea(aAreaAFS)
	RestArea(aAreaSD2)
	RestArea(aArea)

Else
	If cRet == "QUANT"
		//Incluido em 19/11/2008
		//Bruno D. Borges
		//Yokogawa - Tratamento p/ novo campo de movimento estoque SIM ou NAO
		If Iif((cAliasAFN)->(ColumnPos("AFN_ESTOQU")) > 0,(cAliasAFN)->AFN_ESTOQU == "2",.F.)
			nRet := 0
		ElseIf (cAliasSD1)->D1_ORIGLAN == "DP" .Or. (cAliasSD1)->D1_ORIGLAN == "FR"
			nRet := 0 // ( Quantidade 0 pois nao houve consumo do produto )
		Else
			nRet := (cAliasAFN)->AFN_QUANT
			If SuperGetMV("MV_PMSNFED",.F.,"1")=="1" .And. (cAliasSD1)->D1_QTDEDEV > 0
				nRet -= (cAliasAFN)->AFN_QUANT *((cAliasSD1)->D1_QTDEDEV/(cAliasSD1)->D1_QUANT)
			EndIf
		EndIf
	ElseIf cRet == "VALOR"
		//Incluido em 19/11/2008
		//Bruno D. Borges
		//Yokogawa - Tratamento p/ novo campo de movimento estoque SIM ou NAO
		If Iif((cAliasAFN)->(ColumnPos("AFN_ESTOQU")) > 0,(cAliasAFN)->AFN_ESTOQU == "2",.F.) .And. Empty(cOrigem)
			nRet := 0
		Else
			nRet := (cAliasAFN)->AFN_QUANT
			If (cAliasSD1)->D1_ORIGLAN == "FR"

				aNFfrete := {}
				Aadd(aNFfrete,(cAliasAFN)->AFN_DOC)
				Aadd(aNFfrete,(cAliasAFN)->AFN_SERIE)
				Aadd(aNFfrete,(cAliasAFN)->AFN_FORNEC)
				Aadd(aNFfrete,(cAliasAFN)->AFN_LOJA)
				Aadd(aNFfrete,(cAliasAFN)->AFN_PROJET)
				Aadd(aNFfrete,(cAliasAFN)->AFN_REVISA)
				Aadd(aNFfrete,(cAliasAFN)->AFN_TAREFA)
				Aadd(aNFfrete,(cAliasAFN)->AFN_COD)
				QTDEFRETE(aNFfrete , @nQtdeProj, @nQtdeTot)

				nRet := nQtdeProj
			Else
				If SuperGetMV("MV_PMSNFED",.F.,"1")=="1" .And. (cAliasSD1)->D1_QTDEDEV > 0
					nRet -= (cAliasAFN)->AFN_QUANT *((cAliasSD1)->D1_QTDEDEV/(cAliasSD1)->D1_QUANT)
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return nRet

/*/{Protheus.doc} PmsAFSQuant

Verifica se existe qtde devolvida e faz a proporcao para o projeto

@author Daniel Tadashi Batori

@since 28-11-2006

@version P10 R4

@param cAliasAFS,   caracter, Alias corrente da tabela SF2
@param cAliasSD2,   caracter, Alias corrente da tabela SD2

@return nRet, Quantidade referente ao produto informado no item do documento de saida

/*/
Function PmsAFSQUANT(cAliasAFS,cAliasSD2)
Local aArea 		:= {}
Local aAreaSD1 	:= {}
Local aAreaAFN 	:= {}
Local nRet 		:= 0
Local lNfDebCred	:= .F.

DEFAULT cAliasAFS	:= "AFS"
DEFAULT cAliasSD2	:= "SD2"

	If cPaisLoc <> "BRA"
		lNfDebCred := AllTrim((cAliasSD2)->D2_ESPECIE) == "NCP" .And. QtdComp((cAliasSD2)->D2_QUANT) == QtdComp(0) .And. !Empty((cAliasSD2)->D2_NFORI)
	EndIf

	// Trata-se de uma nota de credito
	If lNfDebCred
		aArea := GetArea()
		dbSelectArea("SD1")
		aAreaSD1 := GetArea()
		dbSetOrder(1) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		dbSelectArea("AFN")
		aAreaAFN := GetArea()
		dbSetOrder(2) //AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_ITEM+AFN_PROJET+AFN_REVISA+AFN_TAREFA
		If dbSeek(xFilial("AFN")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI) //+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+SD2->D2_ITEMORI+(cAliasAFS)->AFS_PROJET+(cAliasAFS)->AFS_REVISA+(cAliasAFS)->AFS_TAREFA)
			While !Eof() .AND. AFN->(AFN_FILIAL+AFN_DOC+AFN_SERIE) == xFilial("AFN")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI
				If AFN->AFN_ITEM==(cAliasSD2)->D2_ITEMORI .AND. AFN->AFN_COD==(cAliasSD2)->D2_COD
					If SD1->(dbSeek(xFilial("SD1")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI+AFN->AFN_FORNECE+AFN->AFN_LOJA+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_ITEMORI))
						nRet := AFN->AFN_QUANT
						Exit
					EndIf
				EndIf
				dbSkip()
			EndDo
		EndIf
		RestArea(aAreaAFN)
		RestArea(aAreaSD1)
		RestArea(aArea)
	Else
		nRet := (cAliasAFS)->AFS_QUANT
		If SuperGetMV("MV_PMSNFED",.F.,"1")=="1" .And. (cAliasSD2)->D2_QTDEDEV > 0
			nRet -= (cAliasAFS)->AFS_QUANT *((cAliasSD2)->D2_QTDEDEV/(cAliasSD2)->D2_QUANT)
		EndIf
	EndIf

Return nRet

/*/{Protheus.doc} PmsSD2QUANT

Função que retorna a quantidade do produto informado no item do documento de saida,
caso seja uma nota de credito busca na nota de entrada a quantidade informada para aquele produto.

@author Reynaldo Tetsu Miyashita

@since 24/03/2014

@version P10 R4

@param cAliasSD2,   caracter, Alias corrente da tabela SD2

@return nRet, Quantidade referente ao produto informado no item do documento de saida

/*/
Function PmsSD2QUANT(cAliasSD2)
Local aArea 		:= {}
Local aAreaSD1 	:= {}
Local lNfDebCred	:= .F.
Local nRet 		:= 0

DEFAULT cAliasSD2	:= "SD2"

	If cPaisLoc <> "BRA"
		lNfDebCred := AllTrim((cAliasSD2)->D2_ESPECIE) == "NCP" .And. QtdComp((cAliasSD2)->D2_QUANT) == QtdComp(0) .And. !Empty((cAliasSD2)->D2_NFORI)
	EndIf

	// Trata-se de uma nota de credito
	If lNfDebCred
		aArea := GetArea()
		dbSelectArea("SD1")
		aAreaSD1 := GetArea()
		dbSetOrder(1) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		If dbSeek(xFilial("SD1")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI)
			While !Eof() .AND. SD1->(D1_FILIAL+D1_DOC+D1_SERIE) == xFilial("SD1")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI
				If SD1->D1_ITEM==(cAliasSD2)->D2_ITEMORI .AND. SD1->D1_COD==(cAliasSD2)->D2_COD
					nRet := SD1->D1_QUANT
					Exit
				EndIf
			EndDo
		EndIf
		RestArea(aAreaSD1)
		RestArea(aArea)
	Else
		nRet := (cAliasSD2)->D2_QUANT
	EndIf

Return nRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsIniFat³ Autor ³ Edson Maricate              ³ Data ³ 24-09-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que inicializa os valores faturados do projeto              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsIniFat(cProjeto,cRevisa,cEDT,nMoeda,dDataRef,aArrayTrb)

Local aAuxRet
Local aRet		:= {0,0,0,0,0,0}
Local aArea		:= GetArea()
Local aAreaAFC	:= AFC->(GetArea())
Local aAreaSF4	:= SF4->(GetArea())
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaSC6	:= SC6->(GetArea())
Local aAreaSD2	:= SD2->(GetArea())

DEFAULT aArrayTrb:= {}
DEFAULT dDataRef := PMS_MAX_DATE

cEDT := padr(cEDT,len(AFC->AFC_EDTPAI))

If SC6->(ColumnPos("C6_EDTPMS"))>0
	aRet := {0,0,0,0}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o Saldo atual por pedido de vendas - EDT   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC6")
	dbSetOrder(8)
	MsSeek(xFilial("SC6")+cProjeto+SPACE(LEN(SC6->C6_TASKPMS))+cEDT)
	While !Eof() .And. xFilial("SC6")+cProjeto+SPACE(LEN(SC6->C6_TASKPMS))+cEDT==;
		SC6->C6_FILIAL+SC6->C6_PROJPMS+SC6->C6_TASKPMS+SC6->C6_EDTPMS
		If SC6->C6_EDTPMS == cEDT
			SC5->(dbSetOrder(1))
			SC5->(MsSeek(xFilial("SC5")+SC6->C6_NUM))

			If SC5->C5_EMISSAO <= dDataRef
				If !Empty(SuperGetMv("MV_PMSTSV",,"")).Or. SC6->C6_TES $ SuperGetMv("MV_PMSTSV",,"")
					aRet[1] += xMoeda(((SC6->C6_QTDVEN)*SC6->C6_PRCVEN),SC5->C5_MOEDA,nMoeda,SC5->C5_EMISSAO,8)
					aRet[3] += xMoeda(((MAX(SC6->C6_QTDVEN-SC6->C6_QTDENT,0))*SC6->C6_PRCVEN),SC5->C5_MOEDA,nMoeda,SC5->C5_EMISSAO,8)
				EndIf
				If SC6->C6_TES $ SuperGetMv("MV_PMSTSR",,"")
					aRet[2] += xMoeda(((SC6->C6_QTDVEN)*SC6->C6_PRCVEN),SC5->C5_MOEDA,nMoeda,SC5->C5_EMISSAO,8)
					aRet[4] += xMoeda(((MAX(SC6->C6_QTDVEN-SC6->C6_QTDENT,0))*SC6->C6_PRCVEN),SC5->C5_MOEDA,nMoeda,SC5->C5_EMISSAO,8)
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Processa as devolucoes do pedido de vendas          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SC6->C6_QTDENT <> 0
					dbSelectArea("SD2")
					dbSetOrder(8)
					MsSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM)
					While !Eof() .And. xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM==;
						SD2->D2_FILIAL+SD2->D2_PEDIDO+SD2->D2_ITEMPV

						If Empty(SuperGetMv("MV_PMSTSV",,"")).Or.SD2->D2_TES $ SuperGetMv("MV_PMSTSV",,"")
							aRet[1] -= SD2->D2_VALDEV
						EndIf

						If SD2->D2_TES $ SuperGetMv("MV_PMSTSR",,"")
							aRet[2] -= SD2->D2_VALDEV
						EndIf

						dbSelectArea("SD2")
						dbSkip()
					End
				EndIf

			EndIf
		EndIf
		dbSelectArea("SC6")
		dbSkip()
	End
	AuxFatEDT(cProjeto,cRevisa,cEDT,aArrayTrb,aRet)
EndIf


dbSelectArea("AF9")
dbSetOrder(2)
MsSeek(xFilial("AF9")+cProjeto+cRevisa+cEDT)
While !Eof() .And. xFilial("AF9")+cProjeto+cRevisa+cEDT==;
	AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_EDTPAI
	aAuxRet := PmsRetFat(AF9_PROJET,AF9_REVISA,AF9_TAREFA,nMoeda,dDataRef)
	aAdd(aArrayTrb,{AF9->AF9_TAREFA,,aClone(aAuxRet)})
	AuxFatEDT(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_EDTPAI,aArrayTrb,aAuxRet)
	dbSelectArea("AF9")
	dbSkip()
End

dbSelectArea("AFC")
dbSetOrder(2)
MsSeek(xFilial("AFC")+cProjeto+cRevisa+cEDT)
While !Eof() .And. xFilial("AFC")+cProjeto+cRevisa+cEDT==;
	AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDTPAI
	PmsIniFat(AFC_PROJET,AFC_REVISA,AFC_EDT,nMoeda,dDataRef,aArrayTrb)
	dbSelectArea("AFC")
	dbSkip()
End

RestArea(aAreaSD2)
RestArea(aAreaSC6)
RestArea(aAreaSF4)
RestArea(aAreaAFC)
RestArea(aAreaAF9)
RestArea(aArea)

Return aArrayTrb



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AuxFatEDT³ Autor ³ Edson Maricate              ³ Data ³ 27-09-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que inicializa os valores financeiros da EDT                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AuxFatEDT(cProjeto,cRevisa,cEDT,aArrayTrb,aVlrFin)
Local aArea		:= GetArea()
Local aAreaAFC	:= AFC->(GetArea())
Local nPosEDT	:= aScan(aArrayTrb,{|x|x[2]==cEDT})

If nPosEDT > 0
	aArrayTrb[nPosEDT,3,1] += aVlrFin[1]
	aArrayTrb[nPosEDT,3,2] += aVlrFin[2]
	aArrayTrb[nPosEDT,3,3] += aVlrFin[3]
	aArrayTrb[nPosEDT,3,4] += aVlrFin[4]
Else
	aAdd(aArrayTrb,{,cEdt,{0,0,0,0}})
	nPosEDT	:= Len(aArrayTrb)
	aArrayTrb[nPosEDT,3,1] := aVlrFin[1]
	aArrayTrb[nPosEDT,3,2] := aVlrFin[2]
	aArrayTrb[nPosEDT,3,3] += aVlrFin[3]
	aArrayTrb[nPosEDT,3,4] += aVlrFin[4]
EndIf

dbSelectArea("AFC")
dbSetOrder(1)
If MsSeek(xFilial()+cProjeto+cRevisa+cEDT) .And. !Empty(AFC_EDTPAI)
	AuxFatEDT(cProjeto,cRevisa,AFC->AFC_EDTPAI,aArrayTrb,aVlrFin)
EndIf

RestArea(aAreaAFC)
RestArea(aArea)
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsRetFat³ Autor ³ Edson Maricate              ³ Data ³ 27-09-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que retorna os valores financeiros atuais da Tarefa         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                         	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsRetFat(cProjeto,cRevisa,cTarefa,nMoeda,dDataRef)
Local aRet		:= {0,0,0,0,0,0}
Local aArea		:= GetArea()
Local aAreaSD2	:= SD2->(GetArea())
Local aAreaSC6	:= SC6->(GetArea())
Local cFilBkp	:= cFilAnt
Local cTmpAlias	:= GetNextAlias()
Local lAF9Shared:= FWModeAccess( 'AF9' ) == 'C' 
Local cPmsTsv	:= Nil
Local cPmsTsr	:= Nil
Local lIsCall	:= IsInCallStack("A410Altera") .And. IsInCallStack("A410TudOk")

DEFAULT dDataRef := PMS_MAX_DATE


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o Saldo atual por pedido de vendas         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


cQuery := " SELECT DISTINCT SC6.C6_FILIAL, SC6.C6_NUM, SC6.C6_ITEM, SC5.R_E_C_N_O_ SC5RECNO, SC6.R_E_C_N_O_ SC6RECNO "
cQuery += " FROM "+ RetSQLName( 'SC6' ) +" SC6 "
cQuery += " 	INNER JOIN "+ RetSQLName( 'SC5' ) +" SC5 ON ( SC5.C5_FILIAL = SC6.C6_FILIAL AND SC5.C5_NUM = SC6.C6_NUM ) "

cQuery += " WHERE SC6.C6_FILIAL "+ IIf( lAF9Shared, " IS NOT NULL " , " = '"+ FWxFilial( 'SC6' ) +"' " )  


cQuery += " 	AND SC6.C6_PROJPMS = '"+ cProjeto +"' "
cQuery += " 	AND SC6.C6_TASKPMS = '"+ cTarefa  +"' "
cQuery += " 	AND SC5.D_E_L_E_T_ = ' ' "
cQuery += " 	AND SC6.D_E_L_E_T_ = ' ' "

cQuery += " GROUP BY SC6.C6_FILIAL, SC6.C6_NUM, SC6.C6_ITEM, SC5.R_E_C_N_O_ , SC6.R_E_C_N_O_ "
cQuery += " ORDER BY 1,2,3 "

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., __cRdd, TcGenQry(,,cQuery ), cTmpAlias , .T., .F. )
dbSelectArea( cTmpAlias )

While !( cTmpAlias )->( Eof() )
	SC5->( dbGoto( ( cTmpAlias )->SC5RECNO ) )
	SC6->( dbGoto( ( cTmpAlias )->SC6RECNO ) )

	If lAF9Shared
		cFilAnt := SC6->C6_FILIAL
	EndIf

	If lIsCall .And. !Empty(SC6->C6_NUM)
		( cTmpAlias )->( dbskip() ) ; Loop
	EndIf

	cPmsTsv	:= SuperGetMv("MV_PMSTSV",,"")
	cPmsTsr	:= SuperGetMv("MV_PMSTSR",,"")
	If SC5->C5_EMISSAO <= dDataRef
		If Empty( cPmsTsv ).Or.SC6->C6_TES $ cPmsTsv
			IF !AllTrim(SC6->C6_BLQ) $ 'R' .Or. SC6->C6_QTDENT <> 0
				aRet[1] += xMoeda(((SC6->C6_QTDENT)*SC6->C6_PRCVEN),SC5->C5_MOEDA,nMoeda,SC5->C5_EMISSAO,8)
				If !AllTrim(SC6->C6_BLQ) $ 'R'
					aRet[3] += xMoeda(((MAX(SC6->C6_QTDVEN-SC6->C6_QTDENT,0))*SC6->C6_PRCVEN),SC5->C5_MOEDA,nMoeda,SC5->C5_EMISSAO,8)
				EndIf
			EndIF
		EndIf
		If SC6->C6_TES $ cPmsTsr
			aRet[2] += xMoeda(((SC6->C6_QTDVEN)*SC6->C6_PRCVEN),SC5->C5_MOEDA,nMoeda,SC5->C5_EMISSAO,8)
			aRet[4] += xMoeda(((MAX(SC6->C6_QTDVEN-SC6->C6_QTDENT,0))*SC6->C6_PRCVEN),SC5->C5_MOEDA,nMoeda,SC5->C5_EMISSAO,8)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processa as devolucoes do pedido de vendas          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SC6->C6_QTDENT <> 0
			dbSelectArea("SD2")
			dbSetOrder(8)
			MsSeek(xFilial()+SC6->C6_NUM+SC6->C6_ITEM)
			While !Eof() .And. xFilial()+SC6->C6_NUM+SC6->C6_ITEM==;
				SD2->D2_FILIAL+SD2->D2_PEDIDO+SD2->D2_ITEMPV

				If Empty( cPmsTsv ).Or.SD2->D2_TES $ cPmsTsv
					aRet[1] -= SD2->D2_VALDEV
				EndIf

				If SD2->D2_TES $ cPmsTsr
					aRet[2] -= SD2->D2_VALDEV
				EndIf

				dbSelectArea("SD2")
				dbSkip()
			End
		EndIf
	EndIf

	( cTmpAlias )->( dbSkip() )
EndDo

If lAF9Shared
	cFilAnt := cFilBkp
EndIf

IIf( Select( cTmpAlias ) > 0, ( cTmpAlias )->( dbCloseArea() ), Nil )
RestArea(aAreaSD2)
RestArea(aAreaSC6)
RestArea(aArea)
Return aRet


Function PmsChkSldF(aHandFat,nMoeda,nValorF,cProjeto,cEDT,cTarefa,lAltera,dEmissao,nSaldoF,nValorR,nSaldoR)
Local lRet := .T.

If !Empty(cEDT)
	If nValor > 0 // Nao e permitido o faturamento de EDT quando o controle de saldos esta ativo
		lRet := .F.
	EndIf
Else
	dbSelectArea("AF8")
	dbSetOrder(1)
	MsSeek(xFilial()+cProjeto)
	dbSelectArea("AF9")
	dbSetOrder(1)
	MsSeek(xFilial()+cProjeto+AF8->AF8_REVISA+cTarefa)
	nSaldoF := AF9->AF9_TOTAL-PmsRetFinVal(aHandFat,1,AF9->AF9_TAREFA)[1]
	If xMoeda(nValorF,nMoeda,1,dEmissao) > nSaldoF
		lRet := .F.
	EndIf
	nSaldoR := AF9->AF9_TOTAL-PmsRetFinVal(aHandFat,1,AF9->AF9_TAREFA)[2]
	If xMoeda(nValorR,nMoeda,1,dEmissao) > nSaldoR
		lRet := .F.
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsWriteAFO Autor ³ Bruno Sobieski        ³ Data ³ 03-03-2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de gravacao de apontamentos chamado pela rotina de   ³±±
±±³          ³Liberacao de matrial do CQ                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Evento - [1] - Inclusao de aprovacao                  ³±±
±±³          ³                 [6] - Estorno de aprovacao                   ³±±
±±³          ³ExpA2 : Array contendo a distribuicao                         ³±±
±±³          ³ExpC3 : Alias da tabela SD1                                   ³±±
±±³          ³ExpC4 : Alias da tabela SD7                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA240                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsWriteAFO(nEvento,aItems,cAliasSD1,cAliasSD7,aRecsAFO,aRecsAFN)

Local aArea		:= GetArea()
Local aAreaAFO	:= AFO->(GetArea())
Local cChaveAFN
Local nX
Local nPosProj	:=	Ascan(aHeadAFNCQ,{|x| Alltrim(x[2])=='AFN_PROJET'})
Local nPosRev 	:=	Ascan(aHeadAFNCQ,{|x| Alltrim(x[2])=='AFN_REVISA'})
Local nPosTar 	:=	Ascan(aHeadAFNCQ,{|x| Alltrim(x[2])=='AFN_TAREFA'})
Local nPosQuant:=	Ascan(aHeadAFNCQ,{|x| Alltrim(x[2])=='AFN_LIBCQ'})
Local cSerieNF	:=	""
AFN->(DbSetOrder(1))

DEFAULT cAliasSD7	:=	"SD7"
DEFAULT cAliasSD1	:=	"SD1"

Do Case
	Case nEvento == 1
		For nX := 1 To Len(aItems)
			If aItems[nX,nPosQuant] > 0
				RecLock('AFO',.T.)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza os dados contidos na GetDados                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				AFO->AFO_FILIAL	:= xFilial("AFI")
				AFO->AFO_PROJET	:= aItems[nX,nPosProj]
				AFO->AFO_TAREFA	:= aItems[nX,nPosTar]
				AFO->AFO_REVISA	:= aItems[nX,nPosRev]
				AFO->AFO_QUANT		:= aItems[nX,nPosQuant]
				AFO->AFO_NUMERO	:= (cAliasSD7)->D7_NUMERO
				AFO->AFO_SEQ		:= (cAliasSD7)->D7_SEQ
				AFO->AFO_COD		:= (cAliasSD1)->D1_COD
				AFO->AFO_DOC     	:= (cAliasSD1)->D1_DOC
				AFO->AFO_SERIE   	:= (cAliasSD1)->D1_SERIE
				If	SerieNfId("AFO",6,"AFO_SERIE")>3
					cSerieNF		:=	SerieNfId(cAliasSD1,2,"D1_SERIE")	
					AFO->(FieldPut(ColumnPos(SerieNfId("AFO",3,"AFO_SERIE")), cSerieNF))
				EndIf
				AFO->AFO_FORNEC  	:= (cAliasSD1)->D1_FORNECE
				AFO->AFO_LOJA    	:= (cAliasSD1)->D1_LOJA
				AFO->AFO_ITEM    	:= (cAliasSD1)->D1_ITEM
				MsUnlock()
				cChaveAFN	:=	xFilial('AFN')+AFO->AFO_PROJET+AFO->AFO_REVISA+AFO->AFO_TAREFA+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEM
				AFN->(DbSeek(cChaveAFN))
				RecLock('AFN')
				Replace AFN_SALDCQ	With AFN_SALDCQ - AFO->AFO_QUANT
				MsUnLock()
			Endif
		Next
	Case nEvento == 2
		//Posicionar AFO
		AFO->(DbSetOrder(1))
		AFO->(DbSeek(xFilial()+(cAliasSD7)->D7_NUMERO+(cAliasSD7)->D7_SEQ))
		While  !AFO->(EOF()) .And. AFO->AFO_FILIAL+AFO->AFO_NUMERO+AFO->AFO_SEQ == xFilial('AFO')+(cAliasSD7)->D7_NUMERO+(cAliasSD7)->D7_SEQ
			cChaveAFN	:=	xFilial('AFN')+AFO->AFO_PROJET+AFO->AFO_REVISA+AFO->AFO_TAREFA+(cAliasSD1)->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM)
			AFN->(DbSeek(cChaveAFN))
			RecLock('AFN')
			Replace AFN_SALDCQ	With AFN_SALDCQ + AFO->AFO_QUANT
			MsUnLock()
			AFO->(DbSkip())
			AADD(aRecsAFO,AFO->(Recno()))
			AADD(aRecsAFN,AFN->(Recno()))
		Enddo
	Case nEvento == 3
		For nX := 1 To Len(aRecsAFO)
			Reclock('AFO',.F.)
			DbDelete()
			MsUnLock()
		Next
EndCase

RestArea(aAreaAFO)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSVldCQ ³ Autor ³ Bruno Sobieski         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valdia a quantidade digitada na amarracao com o SD7.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSDLGNF,PMSXFUN                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION PMSVLDCQ()
Local nPosSaldo	:=	Ascan(aHeadAFNCQ,{|x| Alltrim(x[2]) == "AFN_SALDCQ"})
Local aHelpEsp,aHelpPor,aHelpEng
lRet	:=	.T.
If M->AFN_LIBCQ > aCols[n,nPosSaldo]
	aHelpEsp	:=	{"La cantidad seleccionada es mayor  ","al saldo disponible para esta tarea"}
	aHelpPor	:=	{"A quantidade selecionada e maior ao","saldo disponivel para esta  tarefa"}
	aHelpEng	:=	{"The selected quantity is greater   ","than the available balance for this","task."}
	PutHelp("PPMSQTCQ",aHelpPor,aHelpEng,aHelpEsp,.F.)
	Help("   ",1,"PMSQTCQ")
	lRet	:=	.F.
Endif


Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsDlgSD7³ Autor³ Bruno Sobieski          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Esta funcao cria uma janela para configuracao e apontamentos  ³±±
±±³          ³das liberacoes de CQ para o Gerenciamento de Projetos.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA175                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsDlgSD7(nOpcao,cNumero,cSeq)

Local bSavSetKey	:= SetKey(VK_F4,Nil)
Local bSavKeyF5     := SetKey(VK_F5,Nil)
Local bSavKeyF6     := SetKey(VK_F6,Nil)
Local bSavKeyF7     := SetKey(VK_F7,Nil)
Local bSavKeyF8     := SetKey(VK_F8,Nil)
Local bSavKeyF9     := SetKey(VK_F9,Nil)
Local bSavKeyF10    := SetKey(VK_F10,Nil)

Local lOk
Local oDlg,oBold
Local nQuantSD7	:= aCols[n,aScan(aHeader,{|x| Alltrim(x[2]) == "D7_QTDE"})]
Local nTipoMov 	:= aCols[n,aScan(aHeader,{|x| Alltrim(x[2]) == "D7_TIPO"})]
Local nSldSD7	:= aCols[n,aScan(aHeader,{|x| Alltrim(x[2]) == "D7_SALDO"})]
Local nPosItem 	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D7_SEQ"})
Local nPosQtde  := aScan(aHeader,{|x| Alltrim(x[2]) == "D7_QTDE"})
Local nPosSld	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D7_SALDO"})
Local nPosRat		:= aScan(aRatAFO,{|x| x[1] == aCols[n,nPosItem]})
Local lGetDados		:= .T.
Local cSayCliFor	:= ""
Local oGetDados
Local nY := 0
Local nX := 0
Local nI := 0
Local nPosSaldoCQ:=nPosLibCQ:=0
Local cNumNF	:=	""
Local cSerieNF	:=	""
Local cFornece	:=	""
Local cLoja		:=	""
Local cTipo		:=	""
Local aCposAFN  := {}
Local aCmpsAux1 := {}
Local aCmpsAux2 := {}
Local nQtdCpos  := 0

dbSelectArea('SD1')
dbSetOrder(4)
MsSeek(xFilial('SD1')+SD7->D7_NUMSEQ)
cNumNF	:=	SD1->D1_DOC
//cSerieNF	:=	SD1->D1_SERIE
cSerieNF	:=	SerieNfId("SD1",2,"D1_SERIE")
cFornece	:=	SD1->D1_FORNECE
cLoja		:=	SD1->D1_LOJA
cItemNF	:=	SD1->D1_ITEM
cTipo		:=	SD1->D1_TIPO

cSayCliFor	:=	If(cTipo$'BD',STR0176,STR0177) //'Cliente:'###'Fornecedor:'

Private aSavCols	:= aClone(aCols)
Private aSavHeader	:= aClone(aHeader)
Private nSavN		:= n
Private aOrigAFN	:= {}
Private nQtTotSD7	:= nQuantSD7
Private nTotSldSD7	:= nSldSD7

aCols	:= {}
aHeader	:= {}
n		:= 1

If nTipoMov == 1 .Or. nTipoMov == 6
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aHeadAFNCQ == Nil .Or. Empty(aHeadAFNCQ)
		aCmpsAux1 := FWSX3Util():GetListFieldsStruct("AFN",.T.)
		nQtdCpos := Len(aCmpsAux1)
		//Ordenar pelo campo X3_ORDEM
		For nX := 1 To nQtdCpos
			aAdd(aCmpsAux2,{aCmpsAux1[nX],GetSX3Cache(aCmpsAux1[nX][1],"X3_ORDEM")})
		Next nX
		aSort(aCmpsAux2,,,{|x,y| x[2] < y[2] })
		For nX := 1 To nQtdCpos
			aAdd(aCposAFN,aCmpsAux2[nX][1])
		Next nX
		For nX := 1 To nQtdCpos
			If (X3USO(GetSX3Cache(aCposAFN[nX][1],"X3_USADO")) .And.;
				cNivel >= GetSX3Cache(aCposAFN[nX][1],"X3_NIVEL")) .Or.;		
				(Alltrim(aCposAFN[nX][1]) $ "AFN_SALDCQ/AFN_LIBCQ")
					AADD(aHeader,{ AllTrim(FWX3Titulo(aCposAFN[nX][1])),;
								aCposAFN[nX][1],;
								GetSX3Cache(aCposAFN[nX][1],"X3_PICTURE"),;
								aCposAFN[nX][3],;
								aCposAFN[nX][4],;
								IIf((Alltrim(aCposAFN[nX][1]) $ "AFN_LIBCQ"),"PMSVldLibCQ()",GetSX3Cache(aCposAFN[nX][1],"X3_VALID")),;
								GetSX3Cache(aCposAFN[nX][1],"X3_USADO"),;
								aCposAFN[nX][2],;
								GetSX3Cache(aCposAFN[nX][1],"X3_ARQUIVO"),;
								GetSX3Cache(aCposAFN[nX][1],"X3_CONTEXT") } )
			EndIf
		Next nX
		aHeadAFNCQ	:= aClone(aHeader)
	Else
		aHeader	:=	aClone(aHeadAFNCQ)
	Endif

	nPosSaldoCQ	:=	Ascan(aHeader,{|x| alltrim(x[2])=="AFN_SALDCQ"})
	nPosLibCQ	:=	Ascan(aHeader,{|x| alltrim(x[2])=="AFN_LIBCQ"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Procura no AFN os projetos informados para o item e os  ³
	//³apontamentos ja feitos                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cChaveAFN := xFilial('AFN')+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEM

	AFN->(dbSetOrder(2))
	If AFN->(MsSeek(cChaveAFN))
		dbSelectArea("AF8")
		dbSetOrder(1)
		If AF8->(MsSeek(xFilial("AF8")+AFN->AFN_PROJET))
			AFN->(dbSetOrder(2))
			If AFN->(MsSeek(cChaveAFN+AF8->AF8_PROJET + AF8->AF8_REVISA))
				While !AFN->(Eof()) .And. AFN->AFN_FILIAL+AFN->AFN_DOC+AFN->AFN_SERIE+AFN->AFN_FORNEC+AFN->AFN_LOJA+AFN->AFN_ITEM ==;
					xFilial('AFN')+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEM

					aAdd(aOrigAFN,{AFN->AFN_PROJET,AFN->AFN_TAREFA,AFN->AFN_COD,AFN->AFN_SALDCQ})		
					aAdd(aCols,Array(Len(aHeader)+1))

					For ny := 1 to Len(aHeader)
						If aHeader[nY,10] <> "V"
							aCols[Len(aCols),ny] := AFN->(FieldGet(ColumnPos(Trim(aHeader[ny,2]))))
						Else
							aCols[Len(aCols),ny] := CriaVar(aHeader[ny,2])
						EndIf
					Next ny

					aCols[Len(aCols),Len(aHeader)+1] := .F.

					AFN->( dbSkip() )
				EndDo
			EndIf
		EndIf
	EndIf
EndIf

lGetDados := Len(aCols) > 0

If lGetDados
	// devolve para o acols a quantidade a ser liberada.
	If nPosRat>0 .And. Len(aCols) == Len(aRatAFO[nPosRat,2])
		For nX := 1 To Len(aCols)
			//Se não foi alterada a quantidade na SD7, carrega a quantidade que havia sido rateado.
			If nQtTotSD7 == aRatAFO[nPosRat,3]
				aCols[nX,nPosLibCQ] := aRatAFO[nPosRat,2,nX,nPosLibCQ]
			EndIf
		Next nX
	EndIf

	For nX := 1 To Len(aRatAFO)
		For nI := 1 To Len(aRatAFO[nX,2])
			//	Vai sempre buscar o saldo inicial para cada tarefa e a partir dai
			// subtrair todos os registros de liberacoes existentes
			If nX == 1
				If nQtTotSD7 == aRatAFO[nPosRat,3]
					aCols[nI,nPosSaldoCQ] := aOrigAFN[nI,4] - aRatAFO[nX,2,nI,nPosLibCQ]
				EndIF
			Else
				aCols[nI,nPosSaldoCQ] -=  aRatAFO[nX,2,nI,nPosLibCQ]
			EndIf
		Next nI
	Next nX

	DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
	DEFINE MSDIALOG oDlg FROM 88 ,22  TO 350,619 TITLE STR0175 Of oMainWnd PIXEL //'Assistente de Apontamentos : Gerenciamento de Projetos - NF'
	
	oGetDados := MSGetDados():New(23,3,112,296,nOpcao,,'PMSAFOTOK',,.F.,{"AFN_LIBCQ"},,,IIf(lGetDados,Len(aCols),1))
	
	@ 16 ,3   TO 18 ,310 LABEL '' OF oDlg PIXEL
	@ 6  ,4   SAY STR0171 Of oDlg PIXEL SIZE 27 ,9 //'Doc:'
	@ 5  ,20  SAY  cSerieNF+"/"+cNumNF Of oDlg PIXEL SIZE 80,9 FONT oBold
	@ 6  ,78  SAY  cSayCliFor Of oDlg PIXEL SIZE 31 ,9
	@ 5  ,110 SAY  cFornece+"-"+cLoja Of oDlg PIXEL SIZE 35 ,9 FONT oBold
	@ 6  ,220 SAY STR0172 Of oDlg PIXEL SIZE 40 ,9 //'Item/Seq:'
	@ 5  ,270 SAY  cItemNF+"/"+cSeq Of oDlg PIXEL SIZE 27 ,9 FONT oBold
	@ 118,249 BUTTON STR0173 SIZE 35 ,11   FONT oDlg:oFont ACTION {||If(oGetDados:TudoOk(),(lOk:=.T.,oDlg:End()),(lOk:=.F.))}  OF oDlg PIXEL  //'Confirma'
	@ 118,210 BUTTON STR0174 SIZE 35 ,11   FONT oDlg:oFont ACTION (oDlg:End())  OF oDlg PIXEL  //'Cancelar'
	
	If nPosLibCQ > 0 .And. GetSX3Cache("AFN_LIBCQ","X3_VISUAL") == "V"
		oGetDados:aInfo[nPosLibCQ][5] := "A"	//Altera o X3_VISUAL do campo AFN_LIBCQ para "A-Altera"
	EndIf
	
	ACTIVATE MSDIALOG oDlg
EndIf

If nOpcao <> 2 .And. lOk
	If nPosRat > 0
		aRatAFO[nPosRat,2] := aClone(aCols)
		aRatAFO[nPosRat,3] := aSavCols[nSavN,nPosQtde]	
		aRatAFO[nPosRat,4] := aSavCols[nSavN,nPosSld]
	Else
		aADD(aRatAFO,{aSavCols[nSavN,nPosItem],aClone(aCols),aSavCols[nSavN,nPosQtde],aSavCols[nSavN,nPosSld]})
	EndIf

	If ExistBlock("PMSDLGCQ")
		U_PMSDLGCQ(aCols,aHeader,aSavCols,aSavHeader,nSavN)
	EndIf
EndIf

aCols	:= aClone(aSavCols)
aHeader	:= aClone(aSavHeader)
n		:= nSavN

SetKey(VK_F4,bSavSetKey)
SetKey(VK_F5,bSavKeyF5)
SetKey(VK_F6,bSavKeyF6)
SetKey(VK_F7,bSavKeyF7)
SetKey(VK_F8,bSavKeyF8)
SetKey(VK_F9,bSavKeyF9)
SetKey(VK_F10,bSavKeyF10)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAFOTOK³ Autor ³ Bruno Sobieski         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao TudOk da GetDados de rateio do SD7        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSDLGNF,PMSXFUN                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAFOTOK()

Local nx		:= 0
Local lRet		:= .T.
Local nTotQuant	:= 0
Local nTotSldCQ := 0
Local nSavN		:= n
Local nPosQuant	:= aScan(aHeader,{|x|AllTrim(Subs(x[2],4,7))=="_LIBCQ"})
Local nPosSldCQ := aScan(aHeader,{|x|AllTrim(Subs(x[2],4,7))=="_SALDCQ"})
Local lDifAFN	:= SuperGetMV("MV_DIFAFN",,.T.)

If ExistBlock("PMSAFOV")
	lRet := Execblock("PMSAFOV", .F., .F.)
EndIf

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica os campos obrigatorios do SX3.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nx := 1 to Len(aCols)
		n	:= nx
		If !aCols[n,len(aCols[n])]
			nTotQuant += aCols[n,nPosQuant]
			nTotSldCQ += aCols[n,nPosSldCQ]
		EndIf
	Next

	If !lDifAFN .And. ((nQtTotSD7 >= aOrigAFN[n][4] .And. nTotQuant <> nQtTotSD7 .And. nTotSldCQ > 0 ) .Or.;
		 ( nQtTotSD7 <= aOrigAFN[n][4] .And. nTotQuant <> nQtTotSD7))
		Help(" ",1,"PMSQTSD7",,STR0236,1,0)		//##"A quantidade liberada deve ser totalmente distribuída nas tarefas."
		lRet := .F.
	ElseIf lDifAFN 
		If nTotSldSD7 == 0 .And. nTotSldCQ > 0
			Help(" ",1,"PMSTOTSLD",,STR0237,1,0)	//##"O produto está com o saldo zerado no CQ, portanto deverá ser distribuído a quantidade total nas tarefas."
			lRet := .F.
		ElseIf nTotSldCQ <> 0 .And. nTotSldCQ > nTotSldSD7
			Help(" ",1,"PMSVLDSLD",,STR0238,1,0)	//##"Saldo distribuído nas tarefas está maior que o saldo disponível no CQ."
			lRet := .F.
		ElseIf nTotQuant > nQtTotSD7
			Help(" ",1,"PMSVLDQTD",,STR0239,1,0)	//##"A quantidade distribuída nas tarefas está maior que a quantidade liberada do CQ."
			lRet := .F.
		EndIf
	EndIf
EndIf

n := nSavN

Return lRet

Function ExisteSX2(cAlias)
Local lRet		:=	.F.
Local cFilter	:=	SX2->(DbFilter())
Local aArea		:=	GetArea()

DbSelectArea('SX2')
dbClearFilter() //Set Filter To
lRet	:=	MsSeek(cAlias)

Set Filter To &cFilter.

RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SE1ParcNo³ Autor ³ Adriano Ueda           ³ Data ³ 19/10/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica quantas parcelas foram geradas para um mesmo titulo  ³±±
±±³          ³apos o desdobramento do mesmo.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSXFUN                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SE1ParcNo(cFil, cPrefixo, cNum, cTipo)
Local aAreaSE1 := SE1->(GetArea())
Local nNoParc  := 0

dbSelectArea("SE1")
SE1->(dbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
SE1->(MsSeek(cFil + cPrefixo + cNum))

While !SE1->(Eof()) .And. SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM == ;
	cFil + cPrefixo + cNum .And. SE1->E1_DESDOBR == "1"
	//Desconsiderar o título original do desdobramento que fica como baixado
	If SE1->E1_STATUS = "B"
		SE1->(DbSkip())
		Loop
	EndIf

	If SE1->E1_TIPO == cTipo
		nNoParc++
	EndIf
	SE1->(dbSkip())
End

RestArea(aAreaSE1)
Return nNoParc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SE2ParcNo³ Autor ³ Adriano Ueda           ³ Data ³ 02/03/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica quantas parcelas foram geradas para um mesmo titulo  ³±±
±±³          ³apos o desdobramento do mesmo.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cFil     : filial do titulo a pagar                           ³±±
±±³          ³cPrefixo : prefixo do titulo a pagar                          ³±±
±±³          ³cNum     : numero do titulo a pagar                           ³±±
±±³          ³cTipo    : tipo do titulo a pagar                             ³±±
±±³          ³cFornece : fornecedor do titulo a pagar                       ³±±
±±³          ³cLoja    : loja do fornecedor do titulo a pagar               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSXFUN                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SE2ParcNo(cFil, cPrefixo, cNum, cTipo, cFornece, cLoja)
Local aAreaSE2 := SE2->(GetArea())
Local nNoParc  := 0

dbSelectArea("SE2")
SE2->(dbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
SE2->(MsSeek(cFil + cPrefixo + cNum))

While !SE2->(Eof()) .And. SE2->E2_FILIAL + SE2->E2_PREFIXO + SE2->E2_NUM == ;
	cFil + cPrefixo + cNum

	If SE2->(E2_TIPO+E2_FORNECE+E2_LOJA) == cTipo+cFornece+cLoja .And. SE2->E2_DESDOBR == "S"
		nNoParc++
	EndIf

	SE2->(dbSkip())
EndDo

RestArea(aAreaSE2)
Return nNoParc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSSE2Ass³ Autor ³ Adriano Ueda           ³ Data ³ 14/03/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica quantas parcelas foram geradas para um mesmo titulo  ³±±
±±³          ³apos o desdobramento do mesmo.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSXFUN                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSSE2Ass(cAliasSE2, aHeaderAFR, aRatAFR, nx, nParc)
Local aAreaAFR := AFR->(GetArea())
Local aAreaSE2 := SE2->(GetArea())

Local aRecAFR	:= {}

Local nPosProj   := aScan(aHeaderAFR, {|x| Alltrim(x[2]) == "AFR_PROJET"})
Local nPosTask   := aScan(aHeaderAFR, {|x| Alltrim(x[2]) == "AFR_TAREFA"})
Local nPosTipoD  := aScan(aHeaderAFR, {|x| Alltrim(x[2]) == "AFR_TIPOD"})
Local nPosValor1 := aScan(aHeaderAFR, {|x| Alltrim(x[2]) == "AFR_VALOR1"})
Local nPosRevisa := aScan(aHeaderAFR, {|x| Alltrim(x[2]) == "AFR_REVISA"})
Local lExistPe 	 := ExistBlock("PmsAFRTx")
Local nValTit  := 0

Local nz := 0
Local ny := 0

Default nParc := 0

dbSelectArea("AFR")
dbSetOrder(2)
MsSeek(xFilial("AFR") + (cAliasSE2)->E2_PREFIXO + (cAliasSE2)->E2_NUM +;
(cAliasSE2)->E2_PARCELA + (cAliasSE2)->E2_TIPO +;
(cAliasSE2)->E2_FORNECE + (cAliasSE2)->E2_LOJA)

// carrega no array os registros ja existentes
While !Eof() .And. xFilial()+(cAliasSE2)->E2_PREFIXO+(cAliasSE2)->E2_NUM+(cAliasSE2)->E2_PARCELA+(cAliasSE2)->E2_TIPO+(cAliasSE2)->E2_FORNECE+(cAliasSE2)->E2_LOJA==;
	AFR_FILIAL+AFR_PREFIX+AFR_NUM+AFR_PARCEL+AFR_TIPO+AFR_FORNEC+AFR_LOJA
	If AFR->AFR_REVISA == PmsAF8Ver(AFR->AFR_PROJET)
		aAdd(aRecAFR, AFR->(RecNo()))
	EndIf
	dbSkip()
End
For nz := 1 To Len(aRatAFR[nx,2])  // 2 para 2 registro
	If !aRatAFR[nx,2,nz,Len(aRatAFR[nx,2,nz])]
		dbSelectArea('AFR')
		nCount:=0
		If nz <= Len(aRecAFR) // 1 para 1
			AFR->(dbGoto(aRecAFR[nz]))
			RecLock('AFR', .F.)
		Else
			RecLock('AFR', .T.)
		EndIf

		// atualiza os dados contidos na GetDados
		For ny := 1 To Len(aHeaderAFR)
			If aHeaderAFR[ny,10] # "V"
				cVar := Trim(aHeaderAFR[ny,2])

				If nParc > 0 .And. Upper(AllTrim(cVar)) == "AFR_VALOR1"
					AFR->AFR_VALOR1 := aRatAFR[nx,2,nz,ny] / nParc
				Else
					Replace &cVar. With aRatAFR[nx,2,nz,ny]
				EndIf
			Endif
		Next
		AFR->AFR_FILIAL := xFilial("AFR")
		AFR->AFR_PREFIX := (cAliasSE2)->E2_PREFIXO
		AFR->AFR_NUM    := (cAliasSE2)->E2_NUM
		AFR->AFR_PARCEL := (cAliasSE2)->E2_PARCELA
		AFR->AFR_TIPO   := (cAliasSE2)->E2_TIPO
		AFR->AFR_FORNEC := (cAliasSE2)->E2_FORNECE
		AFR->AFR_LOJA   := (cAliasSE2)->E2_LOJA
		AFR->AFR_VENREA := (cAliasSE2)->E2_VENCREA
		If AFR->(ColumnPos("AFR_VIAINT"))>0 .and. lMsgUnica .and. IsInCallStack('FINI050') //somente grava se o pms estiver integrado via mu e vindo da mu
			AFR->AFR_VIAINT:='S'
		Endif
		If AFR->(ColumnPos("AFR_ID")) > 0 .And. SE2->(ColumnPos("E2_MSIDENT")) > 0    // Incluido por Wilson em 10/08/2011
			AFR->AFR_ID := (cAliasSE2)->E2_MSIDENT
		Endif
		MsUnlock()

		/////////////////////////////////////////////////////////////////
		//
		// Integração com TOP, gera a apropriacao para o projeto.
		//
		/////////////////////////////////////////////////////////////////
		SLMPMSCOST(0, "AFR", dDatabase, AFR->AFR_PROJET, AFR->AFR_TAREFA, "", 0, AFR->AFR_VALOR1)
		/////////////////////////////////////////////////////////////////

		// verifica se o valor do CSLL sera associado
		// ao projeto
		If !lExistPe .and. SE2->(ColumnPos("E2_PARCSLL")) > 0 .And. (cAliasSE2)->E2_CSLL > 0
			aAreaSE2 := (cAliasSE2)->(GetArea())
			nValTit := (cAliasSE2)->E2_VALOR

			dbSelectArea(cAliasSE2)
			(cAliasSE2)->(dbSetOrder(1))

			If (cAliasSE2)->(MsSeek(PmsFilial("SE2","AFR")+AFR->AFR_PREFIXO+AFR->AFR_NUM))
				While (cAliasSE2)->(!Eof() .And.;
					E2_FILIAL + E2_PREFIXO + E2_NUM ==;
					PmsFilial("SE2","AFR") + AFR->AFR_PREFIXO + AFR->AFR_NUM)
					If (cAliasSE2)->E2_TIPO == Iif(cTipoE2 $ MVPAGANT+"/"+MV_CPNEG,MVTXA,MVTAXA) .And. cParcCsll == (cAliasSE2)->E2_PARCELA
						RecLock("AFR", .T.)

						AFR->AFR_PROJETO := aRatAFR[nx,2,nz,nPosProj]
						AFR->AFR_TAREFA  := aRatAFR[nx,2,nz,nPosTask]
						AFR->AFR_TIPOD   := aRatAFR[nx,2,nz,nPosTipoD]

						// alterado o calculo para levar em consideracao
						// o rateio do valor do imposto
						// (valor do titulo rateado/valor do titulo) * valor do imposto
						AFR->AFR_VALOR1  := (aRatAFR[nx,2,nz,nPosValor1] / nValTit) * (cAliasSE2)->E2_VALOR

						AFR->AFR_VALOR2  := 0
						AFR->AFR_VALOR3  := 0
						AFR->AFR_VALOR4  := 0
						AFR->AFR_VALOR5  := 0
						AFR->AFR_REVISA  := aRatAFR[nx,2,nz,nPosRevisa]
						AFR->AFR_DATA    := (cAliasSE2)->E2_EMIS1
						AFR->AFR_FILIAL  := xFilial("AFR")
						AFR->AFR_PREFIX  := (cAliasSE2)->E2_PREFIXO
						AFR->AFR_NUM     := (cAliasSE2)->E2_NUM
						AFR->AFR_PARCEL  := (cAliasSE2)->E2_PARCELA
						AFR->AFR_TIPO    := (cAliasSE2)->E2_TIPO
						AFR->AFR_FORNEC  := (cAliasSE2)->E2_FORNECE
						AFR->AFR_LOJA    := (cAliasSE2)->E2_LOJA
						AFR->AFR_VENREA  := (cAliasSE2)->E2_VENCREA

						MsUnlock()

						/////////////////////////////////////////////////////////////////
						//
						// Integração com TOP, gera a apropriacao para o projeto.
						//
						/////////////////////////////////////////////////////////////////
						SLMPMSCOST(0, "AFR", dDatabase, AFR->AFR_PROJET, AFR->AFR_TAREFA, "", 0, AFR->AFR_VALOR1)
						/////////////////////////////////////////////////////////////////

						RecLock("SE2",.F.)
						SE2->E2_PROJPMS := "1"
						MsUnlock()

						Exit

					EndIf
					(cAliasSE2)->(dbSkip())
				End
			EndIf

			RestArea(aAreaSE2)
		EndIf


		// verifica se o valor do PIS sera associado
		// ao projeto
		If !lExistPe .and. SE2->(ColumnPos("E2_PARCPIS")) > 0 .And. (cAliasSE2)->E2_PIS > 0
			aAreaSE2 := (cAliasSE2)->(GetArea())
			nValTit := (cAliasSE2)->E2_VALOR

			dbSelectArea(cAliasSE2)
			(cAliasSE2)->(dbSetOrder(1))

			If (cAliasSE2)->(MsSeek(PmsFilial("SE2","AFR")+AFR->AFR_PREFIXO+AFR->AFR_NUM))
				While (cAliasSE2)->(!Eof() .And.;
					E2_FILIAL + E2_PREFIXO + E2_NUM ==;
					PmsFilial("SE2","AFR") + AFR->AFR_PREFIXO + AFR->AFR_NUM)
					If (cAliasSE2)->E2_TIPO == Iif(cTipoE2 $ MVPAGANT+"/"+MV_CPNEG,MVTXA,MVTAXA) .And. cParcPis == (cAliasSE2)->E2_PARCELA
						RecLock("AFR", .T.)

						AFR->AFR_PROJETO := aRatAFR[nx,2,nz,nPosProj]
						AFR->AFR_TAREFA  := aRatAFR[nx,2,nz,nPosTask]
						AFR->AFR_TIPOD   := aRatAFR[nx,2,nz,nPosTipoD]

						// alterado o calculo para levar em consideracao
						// o rateio do valor do imposto
						// (valor do titulo rateado/valor do titulo) * valor do imposto
						AFR->AFR_VALOR1  := (aRatAFR[nx,2,nz,nPosValor1] / nValTit) * (cAliasSE2)->E2_VALOR

						AFR->AFR_VALOR2  := 0
						AFR->AFR_VALOR3  := 0
						AFR->AFR_VALOR4  := 0
						AFR->AFR_VALOR5  := 0
						AFR->AFR_REVISA  := aRatAFR[nx,2,nz,nPosRevisa]
						AFR->AFR_DATA    := (cAliasSE2)->E2_EMIS1
						AFR->AFR_FILIAL  := xFilial("AFR")
						AFR->AFR_PREFIX  := (cAliasSE2)->E2_PREFIXO
						AFR->AFR_NUM     := (cAliasSE2)->E2_NUM
						AFR->AFR_PARCEL  := (cAliasSE2)->E2_PARCELA
						AFR->AFR_TIPO    := (cAliasSE2)->E2_TIPO
						AFR->AFR_FORNEC  := (cAliasSE2)->E2_FORNECE
						AFR->AFR_LOJA    := (cAliasSE2)->E2_LOJA
						AFR->AFR_VENREA  := (cAliasSE2)->E2_VENCREA

						MsUnlock()

						/////////////////////////////////////////////////////////////////
						//
						// Integração com TOP, gera a apropriacao para o projeto.
						//
						/////////////////////////////////////////////////////////////////
//						SLMPMSCOST(0, "AFR", dDatabase, AFR->AFR_PROJET, AFR->AFR_TAREFA, "", 0, AFR->AFR_VALOR1)
						/////////////////////////////////////////////////////////////////

						RecLock("SE2",.F.)
						SE2->E2_PROJPMS := "1"
						MsUnlock()

						Exit

					EndIf
					(cAliasSE2)->(dbSkip())
				End
			EndIf

			RestArea(aAreaSE2)
		EndIf

		// verifica se o valor do COFINS sera associado
		// ao projeto
		If !lExistPe .and. SE2->(ColumnPos("E2_PARCCOF")) > 0 .And. (cAliasSE2)->E2_COFINS > 0
			aAreaSE2 := (cAliasSE2)->(GetArea())
			nValTit := (cAliasSE2)->E2_VALOR

			dbSelectArea(cAliasSE2)
			(cAliasSE2)->(dbSetOrder(1))

			If (cAliasSE2)->(MsSeek(PmsFilial("SE2","AFR")+AFR->AFR_PREFIXO+AFR->AFR_NUM))
				While (cAliasSE2)->(!Eof() .And.;
					E2_FILIAL + E2_PREFIXO + E2_NUM ==;
					PmsFilial("SE2","AFR") + AFR->AFR_PREFIXO + AFR->AFR_NUM)
					If (cAliasSE2)->E2_TIPO == Iif(cTipoE2 $ MVPAGANT+"/"+MV_CPNEG,MVTXA,MVTAXA).And.cParcCof == (cAliasSE2)->E2_PARCELA
						RecLock("AFR", .T.)

						AFR->AFR_PROJETO := aRatAFR[nx,2,nz,nPosProj]
						AFR->AFR_TAREFA  := aRatAFR[nx,2,nz,nPosTask]
						AFR->AFR_TIPOD   := aRatAFR[nx,2,nz,nPosTipoD]

						// alterado o calculo para levar em consideracao
						// o rateio do valor do imposto
						// (valor do titulo rateado/valor do titulo) * valor do imposto
						AFR->AFR_VALOR1  := (aRatAFR[nx,2,nz,nPosValor1] / nValTit) * (cAliasSE2)->E2_VALOR

						AFR->AFR_VALOR2  := 0
						AFR->AFR_VALOR3  := 0
						AFR->AFR_VALOR4  := 0
						AFR->AFR_VALOR5  := 0
						AFR->AFR_REVISA  := aRatAFR[nx,2,nz,nPosRevisa]
						AFR->AFR_DATA    := (cAliasSE2)->E2_EMIS1
						AFR->AFR_FILIAL  := xFilial("AFR")
						AFR->AFR_PREFIX  := (cAliasSE2)->E2_PREFIXO
						AFR->AFR_NUM     := (cAliasSE2)->E2_NUM
						AFR->AFR_PARCEL  := (cAliasSE2)->E2_PARCELA
						AFR->AFR_TIPO    := (cAliasSE2)->E2_TIPO
						AFR->AFR_FORNEC  := (cAliasSE2)->E2_FORNECE
						AFR->AFR_LOJA    := (cAliasSE2)->E2_LOJA
						AFR->AFR_VENREA  := (cAliasSE2)->E2_VENCREA

						MsUnlock()

						/////////////////////////////////////////////////////////////////
						//
						// Integração com TOP, gera a apropriacao para o projeto.
						//
						/////////////////////////////////////////////////////////////////
//						SLMPMSCOST(0, "AFR", dDatabase, AFR->AFR_PROJET, AFR->AFR_TAREFA, "", 0, AFR->AFR_VALOR1)
						/////////////////////////////////////////////////////////////////

						RecLock("SE2",.F.)
						SE2->E2_PROJPMS := "1"
						MsUnlock()

						Exit

					EndIf
					(cAliasSE2)->(dbSkip())
				End
			EndIf

			RestArea(aAreaSE2)
		EndIf

		// verifica se o valor de ISS sera associado
		// ao projeto
		If !lExistPe .and. (cAliasSE2)->E2_ISS > 0
			aAreaSE2 := (cAliasSE2)->(GetArea())
			nValTit := (cAliasSE2)->E2_VALOR

			dbSelectArea(cAliasSE2)
			(cAliasSE2)->(dbSetOrder(1))

			If (cAliasSE2)->(MsSeek(PmsFilial("SE2","AFR")+AFR->AFR_PREFIXO+AFR->AFR_NUM))
				While (cAliasSE2)->(!Eof() .And.;
					E2_FILIAL + E2_PREFIXO + E2_NUM ==;
					PmsFilial("SE2","AFR") + AFR->AFR_PREFIXO + AFR->AFR_NUM)
					If (cAliasSE2)->E2_TIPO == MVISS .And. cParcISS == (cAliasSE2)->E2_PARCELA
						RecLock("AFR", .T.)

						AFR->AFR_PROJETO := aRatAFR[nx,2,nz,nPosProj]
						AFR->AFR_TAREFA  := aRatAFR[nx,2,nz,nPosTask]
						AFR->AFR_TIPOD   := aRatAFR[nx,2,nz,nPosTipoD]

						// alterado o calculo para levar em consideracao
						// o rateio do valor do imposto
						// (valor do titulo rateado/valor do titulo) * valor do imposto
						AFR->AFR_VALOR1  := (aRatAFR[nx,2,nz,nPosValor1] / nValTit) * (cAliasSE2)->E2_VALOR

						AFR->AFR_VALOR2  := 0
						AFR->AFR_VALOR3  := 0
						AFR->AFR_VALOR4  := 0
						AFR->AFR_VALOR5  := 0
						AFR->AFR_REVISA  := aRatAFR[nx,2,nz,nPosRevisa]
						AFR->AFR_DATA    := (cAliasSE2)->E2_EMIS1
						AFR->AFR_FILIAL  := xFilial("AFR")
						AFR->AFR_PREFIX  := (cAliasSE2)->E2_PREFIXO
						AFR->AFR_NUM     := (cAliasSE2)->E2_NUM
						AFR->AFR_PARCEL  := (cAliasSE2)->E2_PARCELA
						AFR->AFR_TIPO    := (cAliasSE2)->E2_TIPO
						AFR->AFR_FORNEC  := (cAliasSE2)->E2_FORNECE
						AFR->AFR_LOJA    := (cAliasSE2)->E2_LOJA
						AFR->AFR_VENREA  := (cAliasSE2)->E2_VENCREA

						MsUnlock()

						/////////////////////////////////////////////////////////////////
						//
						// Integração com TOP, gera a apropriacao para o projeto.
						//
						/////////////////////////////////////////////////////////////////
//						SLMPMSCOST(0, "AFR", dDatabase, AFR->AFR_PROJET, AFR->AFR_TAREFA, "", 0, AFR->AFR_VALOR1)
						/////////////////////////////////////////////////////////////////

						RecLock("SE2",.F.)
						SE2->E2_PROJPMS := "1"
						MsUnlock()

						Exit

					EndIf
					(cAliasSE2)->(dbSkip())
				End
			EndIf

			RestArea(aAreaSE2)
		EndIf

		// verifica se o valor de INSS sera associado
		// ao projeto
		If !lExistPe .and. (cAliasSE2)->E2_INSS > 0
			aAreaSE2 := (cAliasSE2)->(GetArea())
			nValTit := (cAliasSE2)->E2_VALOR

			dbSelectArea(cAliasSE2)
			(cAliasSE2)->(dbSetOrder(1))

			If (cAliasSE2)->(MsSeek(PmsFilial("SE2","AFR")+AFR->AFR_PREFIX+AFR->AFR_NUM))
				While (cAliasSE2)->(!Eof() .And.;
					E2_FILIAL + E2_PREFIXO + E2_NUM ==;
					PmsFilial("SE2","AFR") + AFR->AFR_PREFIXO + AFR->AFR_NUM)

					If (cAliasSE2)->E2_TIPO == MVINSS .And. cParcINSS == (cAliasSE2)->E2_PARCELA
						RecLock("AFR", .T.)

						AFR->AFR_PROJETO := aRatAFR[nx,2,nz,nPosProj]
						AFR->AFR_TAREFA  := aRatAFR[nx,2,nz,nPosTask]
						AFR->AFR_TIPOD   := aRatAFR[nx,2,nz,nPosTipoD]
						AFR->AFR_VALOR1  := (aRatAFR[nx,2,nz,nPosValor1] / nValTit) * (cAliasSE2)->E2_VALOR
						AFR->AFR_VALOR2  := 0
						AFR->AFR_VALOR3  := 0
						AFR->AFR_VALOR4  := 0
						AFR->AFR_VALOR5  := 0
						AFR->AFR_REVISA  := aRatAFR[nx,2,nz,nPosRevisa]
						AFR->AFR_DATA    := (cAliasSE2)->E2_EMIS1
						AFR->AFR_FILIAL  := xFilial("AFR")
						AFR->AFR_PREFIX  := (cAliasSE2)->E2_PREFIXO
						AFR->AFR_NUM     := (cAliasSE2)->E2_NUM
						AFR->AFR_PARCEL  := (cAliasSE2)->E2_PARCELA
						AFR->AFR_TIPO    := (cAliasSE2)->E2_TIPO
						AFR->AFR_FORNEC  := (cAliasSE2)->E2_FORNECE
						AFR->AFR_LOJA    := (cAliasSE2)->E2_LOJA
						AFR->AFR_VENREA  := (cAliasSE2)->E2_VENCREA

						MsUnlock()

						/////////////////////////////////////////////////////////////////
						//
						// Integração com TOP, gera a apropriacao para o projeto.
						//
						/////////////////////////////////////////////////////////////////
//						SLMPMSCOST(0, "AFR", dDatabase, AFR->AFR_PROJET, AFR->AFR_TAREFA, "", 0, AFR->AFR_VALOR1)
						/////////////////////////////////////////////////////////////////

						RecLock("SE2",.F.)
						SE2->E2_PROJPMS := "1"
						MsUnlock()

						Exit

					EndIf
					(cAliasSE2)->(dbSkip())
				End
			EndIf

			RestArea(aAreaSE2)
		EndIf

		// verifica se o valor de IRRF sera associado
		// ao projeto
		If !lExistPe .and. (cAliasSE2)->E2_IRRF > 0
			aAreaSE2 := (cAliasSE2)->(GetArea())
			nValTit := (cAliasSE2)->E2_VALOR

			dbSelectArea(cAliasSE2)
			(cAliasSE2)->(dbSetOrder(1))

			If (cAliasSE2)->(MsSeek(PmsFilial("SE2","AFR")+AFR->AFR_PREFIXO+AFR->AFR_NUM))
				While (cAliasSE2)->(!Eof() .And.;
					E2_FILIAL + E2_PREFIXO + E2_NUM ==;
					PmsFilial("SE2","AFR") + AFR->AFR_PREFIXO + AFR->AFR_NUM)
					If (cAliasSE2)->E2_TIPO == MVTAXA .And. cParcIR  == (cAliasSE2)->E2_PARCELA
						RecLock("AFR", .T.)

						AFR->AFR_PROJETO := aRatAFR[nx,2,nz,nPosProj]
						AFR->AFR_TAREFA  := aRatAFR[nx,2,nz,nPosTask]
						AFR->AFR_TIPOD   := aRatAFR[nx,2,nz,nPosTipoD]
						AFR->AFR_VALOR1  := (aRatAFR[nx,2,nz,nPosValor1] / nValTit) * (cAliasSE2)->E2_VALOR
						AFR->AFR_VALOR2  := 0
						AFR->AFR_VALOR3  := 0
						AFR->AFR_VALOR4  := 0
						AFR->AFR_VALOR5  := 0
						AFR->AFR_REVISA  := aRatAFR[nx,2,nz,nPosRevisa]
						AFR->AFR_DATA    := (cAliasSE2)->E2_EMIS1
						AFR->AFR_FILIAL  := xFilial("AFR")
						AFR->AFR_PREFIX  := (cAliasSE2)->E2_PREFIXO
						AFR->AFR_NUM     := (cAliasSE2)->E2_NUM
						AFR->AFR_PARCEL  := (cAliasSE2)->E2_PARCELA
						AFR->AFR_TIPO    := (cAliasSE2)->E2_TIPO
						AFR->AFR_FORNEC  := (cAliasSE2)->E2_FORNECE
						AFR->AFR_LOJA    := (cAliasSE2)->E2_LOJA
						AFR->AFR_VENREA  := (cAliasSE2)->E2_VENCREA

						MsUnlock()

						/////////////////////////////////////////////////////////////////
						//
						// Integração com TOP, gera a apropriacao para o projeto.
						//
						/////////////////////////////////////////////////////////////////
//						SLMPMSCOST(0, "AFR", dDatabase, AFR->AFR_PROJET, AFR->AFR_TAREFA, "", 0, AFR->AFR_VALOR1)
						/////////////////////////////////////////////////////////////////

						RecLock("SE2",.F.)
						SE2->E2_PROJPMS := "1"
						MsUnlock()

						Exit

					EndIf
					(cAliasSE2)->(dbSkip())
				End
			EndIf

			RestArea(aAreaSE2)
		EndIf

		// atualiza os valores da Tarefa
		//AF9AtuComD3({SD3->D3_CUSTO1,SD3->D3_CUSTO2,SD3->D3_CUSTO3,SD3->D3_CUSTO4,SD3->D3_CUSTO5})
	Else
		If nz <= Len(aRecAFR)
			MsGoto(aRecAFR[nz])
			/////////////////////////////////////////////////////////////////
			//
			// Integração com TOP, gera a apropriacao para o projeto.
			//
			/////////////////////////////////////////////////////////////////
//			SLMPMSCOST(2, "AFR")
			/////////////////////////////////////////////////////////////////
			RecLock("AFR",.F.,.T.)
			dbDelete()
			MsUnlock()
		EndIf
	EndIf
Next

// deleta os demais registros
If Len(aRecAFR) > Len(aRatAFR[nx,2])
	For nz := (Len(aRatAFR[nx,2])+1) To Len(aRecAFR)
		MsGoto(aRecAFR[nz])
		/////////////////////////////////////////////////////////////////
		//
		// Integração com TOP, gera a apropriacao para o projeto.
		//
		/////////////////////////////////////////////////////////////////
//		SLMPMSCOST(0, "AFR", dDatabase, AFR->AFR_PROJET, AFR->AFR_TAREFA, "", 0, AFR->AFR_VALOR1)
		/////////////////////////////////////////////////////////////////
		RecLock("AFR",.F.,.T.)
		dbDelete()
		MsUnLock()
	Next nz
EndIf

RestArea(aAreaAFR)
RestArea(aAreaSE2)
Return


/*/{Protheus.doc} PmsAF8Simu
Efetua o calculo das datas Previstas para execucao da tarefa de acordo com o metodo de calculo escolhido.

@param nRecAF8,		numérico, (Descrição do parâmetro)
@param nMetodo,		numérico, (Descrição do parâmetro)
@param dData,			data, (Descrição do parâmetro)
@param lProcessa,		logico, (Descrição do parâmetro)
@param cRevisa,		character, (Descrição do parâmetro)
@param oTree,			objeto, (Descrição do parâmetro)
@param cArquivo,		character, (Descrição do parâmetro)
@param cRecDe,			character, (Descrição do parâmetro)
@param cRecAte,		character, (Descrição do parâmetro)
@param cEquipDe,		character, (Descrição do parâmetro)
@param cEquipAte,		character, (Descrição do parâmetro)
@param lReprParc,		logico, (Descrição do parâmetro)
@param lFixNaoIni,	logico, (Descrição do parâmetro)

@return nil, ${return_description}

@author Rodrigo Antonio
@since 11-05-2006
@version 1.0

@example
(examples)
@see (links_or_references)
/*/
Function PmsAF8Simu(nRecAF8,nMetodo,dData,lProcessa,cRevisa,oTree,cArquivo,cRecDe,cRecAte,cEquipDe,cEquipAte,lReprParc,lFixNaoIni)
Local aArea		:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAF8	:= AF8->(GetArea())
Local aRecsAF9	:= {}
Local cAlias
Local nRecAlias
Local aTsk		:= {}
Local aAllEDT	:= {}
Local nx
Local aTarefs	:= {} //Array com as informacoes das tarefas atualizadas
Local nPosTaf	:= 0
Local aConfig	:= {1, PMS_MIN_DATE, PMS_MAX_DATE,Space(TamSX3("AE8_RECURS")[1])}
Local oDlg
Local aAuxRet	:= {}

dbSelectArea("AF8")
MsGoto(nRecAF8)

DEFAULT lReprParc		:= .F.
DEFAULT lProcessa		:= .F.
DEFAULT cRevisa	  	:= AF8->AF8_REVISA

If oTree!= Nil
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecAlias	:= Val(SubStr(oTree:GetCargo(),4,12))
ElseIf cArquivo <> Nil
	cAlias := (cArquivo)->ALIAS
	nRecAlias := (cArquivo)->RECNO
Else
	cAlias := "AF8"
	nRecAlias := nRecAF8
EndIf

If cAlias == "AF8"
	dbSelectArea("AF8")
	dbGoto(nRecAlias)
	dbSelectArea("AFC")
	dbSetOrder(1)
	dbSeek(xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA+Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)))
	PmsLoadTsk(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,aTsk,,cRecDe,cRecAte,cEquipDe,cEquipAte,"( Empty(AF9->AF9_DTATUI).Or. "+If(lReprParc,".T.",".F.")+") .And. AF9->AF9_PRIORI < 1000 .And. Empty(AF9->AF9_DTATUF)")
ElseIf cAlias == "AFC"
	dbSelectArea("AFC")
	dbGoto(nRecAlias)
	PmsLoadTsk(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,aTsk,,cRecDe,cRecAte,cEquipDe,cEquipAte,"( Empty(AF9->AF9_DTATUI).Or. "+If(lReprParc,".T.",".F.")+") .And. AF9->AF9_PRIORI < 1000 .And. Empty(AF9->AF9_DTATUF)")
ElseIf cAlias == "AF9"
	dbSelectArea("AF9")
	dbGoto(nRecAlias)
	PmsLoadTsk(AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA,aTsk,.T.,cRecDe,cRecAte,cEquipDe,cEquipAte,"( Empty(AF9->AF9_DTATUI).Or. "+If(lReprParc,".T.",".F.")+") .And. AF9->AF9_PRIORI < 1000 .And. Empty(AF9->AF9_DTATUF)")
Endif
If lProcessa
	ProcRegua(Len(aTsk) * 2)
EndIf

If nMetodo == 1
	AFD->(dbSetOrder(1))
	AF9->(dbSetOrder(1))
	For nx := 1 to Len(aTsk)
		If lProcessa
			IncProc(STR0202) //"Recalculando datas do projeto..."
		EndIf
		AF9->(dbGoto(aTsk[nx]))
		dbSelectArea("AFD")
		//Busca as Tarefas sem Relacionamento
		If !MsSeek(xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
			If ( Empty(AF9->AF9_DTATUI) .Or. lReprParc ) .And. AF9->AF9_PRIORI < 1000 .And. Empty(AF9->AF9_DTATUF) .AND. !(lFixNaoIni .AND. AF9->AF9_START > dData)
				If !Empty(AF9->AF9_DTATUI) .AND. lReprParc 	//Verifica se nao foi escolhido Fixar datas previstas das tarefas em execucao,
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Faz o Tratamento das tarefas que ja iniciaram.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSCalcRe(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dData)
				Else
					aAuxRet := PMSDTaskF(dData,"00:00",AF9->AF9_CALEND,AF9->AF9_HDURAC,AF9->AF9_PROJET,Nil)
				Endif
				//TABELA,TAREFA,START,HORAI,FINSIH,HORAF,HDURAC,HUTEIS
				aAdd(aTarefs,{"AF9",AF9->AF9_TAREFA,aAuxRet[1],aAuxRet[2],aAuxRet[3],aAuxRet[4],AF9->AF9_HDURAC,AF9->AF9_HUTEIS,AF9->AF9_NIVEL,AF9->AF9_DTATUI,AF9->AF9_DTATUF, AF9->(Recno())})
				dbSelectArea("AF9")
				If aScan(aAllEDT,AF9->AF9_EDTPAI) <= 0
					aAdd(aAllEDT,AF9->AF9_EDTPAI)
				EndIf
				PmsSimScs(AF9_PROJET,AF9_REVISA,AF9_TAREFA,.F.,aAllEDT,lReprParc,aTarefs)
			EndIf
		EndIf
		//	atualiza das EDT's
	Next nx
	For nx := 1 to Len(aTsk)
		If lProcessa
			IncProc(STR0202) //"Recalculando datas do projeto..."
		EndIf
		AF9->(dbGoto(aTsk[nx]))
		dbSelectArea("AFD")
		dbSetOrder(1)
		lSeek1 := MsSeek(xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA) //Procura a tarefa
		dbSelectArea("AFD")
		dbSetOrder(2)
		lSeek2 := MsSeek(xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)//Procura pelo antecesor
		If lSeek1 .Or. lSeek2
			nPosTaf := aScan(aTarefs,{|x|x[1]+x[2] == "AF9" + AF9->AF9_TAREFA})
			If nPosTaf == 0
				If Empty(aAuxRet)
					If !Empty(AF9->AF9_DTATUI) .AND. lReprParc 	//Verifica se nao foi escolhido Fixar datas previstas das tarefas em execucao,
						aAuxRet := PMSCalcRe(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dData) //Faz o Tratamento das tarefas que ja iniciaram
					Else
						aAuxRet := PMSDTaskF(dData,"00:00",AF9->AF9_CALEND,AF9->AF9_HDURAC,AF9->AF9_PROJET,Nil)
					Endif
				EndIf
				aAdd(aTarefs,{"AF9",AF9->AF9_TAREFA,aAuxRet[1] ,aAuxRet[2]	,aAuxRet[3]	,aAuxRet[4],AF9->AF9_HDURAC,AF9->AF9_HUTEIS,AF9->AF9_NIVEL,AF9->AF9_DTATUI,AF9->AF9_DTATUF, AF9->(Recno())})
			Endif
			nPosTaf := aScan(aTarefs,{|x|x[1]+x[2] == "AF9" + AF9->AF9_TAREFA})
			If aTarefs[nPosTaf,3] < dData //3-Start
				If ( Empty(AF9->AF9_DTATUI).Or. lReprParc ) .And. AF9->AF9_PRIORI < 1000 .And. Empty(AF9->AF9_DTATUF)
					If !Empty(AF9->AF9_DTATUI) .AND. lReprParc 	//Verifica se nao foi escolhido Fixar datas previstas das tarefas em execucao,
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Faz o Tratamento das tarefas que ja iniciaram.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aAuxRet := PMSCalcRe(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dData)
					Else
						aAuxRet := PMSDTaskF(dData,"00:00",AF9->AF9_CALEND,AF9->AF9_HDURAC,AF9->AF9_PROJET,Nil)
					Endif
					aTarefs[nPosTaf,3]	 := aAuxRet[1]
					aTarefs[nPosTaf,4]	 := aAuxRet[2]
					aTarefs[nPosTaf,5]	 := aAuxRet[3]
					aTarefs[nPosTaf,6]	 := aAuxRet[4]

					dbSelectArea("AF9")
					If aScan(aAllEDT,AF9->AF9_EDTPAI) <= 0
						aAdd(aAllEDT,AF9->AF9_EDTPAI)
					EndIf
					PmsSimScs(AF9_PROJET,AF9_REVISA,AF9_TAREFA,.F.,aAllEDT,lReprParc,@aTarefs)
					PmsSimScsI(AF9_PROJET,AF9_REVISA,AF9_TAREFA,.F., nMetodo, aRecsAF9, aAllEDT,lReprParc,@aTarefs)
				EndIf
			EndIf
		EndIf
	Next nx
	If lProcessa
		ProcRegua(Len(aAllEDT))
	EndIf
	For nX := 1 to Len(aAllEDT)
		If lProcessa
			IncProc(STR0203) //"Atualizando datas da estrutura..."
		EndIf
		PmsSimEDT(AF8->AF8_PROJET, cRevisa, aAllEDT[nX], , , , ,lReprParc,@aTarefs)
	Next nX
Else
	//Ainda nao implementado
EndIf

If ExistBlock("PMAF8SIM")
	If ExecBlock("PMAF8SIM", .F., .F., {AF8->AF8_PROJET,aTarefs})
		PmsDlgSimGnt(cRevisa,aConfig,@oDlg,@oTree,cArquivo,aTarefs)
	Endif
Else
	PmsDlgSimGnt(cRevisa,aConfig,@oDlg,@oTree,cArquivo,aTarefs)
EndIf
RestArea(aAreaAF8)
RestArea(aAreaAF9)
RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsSimScs³ Autor ³ Rodrigo Antonio	     ³ Data ³ 17-05-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a atualizacao das datas das tarefas Sucessoras.       ³±±
±±³          ³no array de Simulacao													    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsSimScs(cProjeto,cRevisa,cTarefa,lAtuEDT, aAtuEDT,lReprParc,aBaseDados)
Local aArea		:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAFD	:= AFD->(GetArea())
Local lRet		:= .T.
Local aTarefas := {}
Local aRetorno := {}

DEFAULT lAtuEDT	:= .T.
DEFAULT aAtuEDT	:= {}
DEFAULT lReprParc := .F.

	aTarefas := {cTarefa}
	While Len(aTarefas) >0
		aRetorno := auxSimScs(cProjeto,cRevisa,aTarefas,lAtuEDT, aAtuEDT,lReprParc,aBaseDados)
		lRet := aRetorno[1]
		If !lRet
			Exit
		EndIf
		aTarefas:= aClone(aRetorno[2])
	EndDo

RestArea(aAreaAFD)
RestArea(aAreaAF9)
RestArea(aArea)
Return lRet

/*/{Protheus.doc} auxSimScs

Funcao auxiliar para executar a atualizacao das datas das tarefas Sucessoras no array de Simulacao.
O calculo das datas e horas de inicio e fim referente as tarefas sucessoras.

@author Rodrigo Antonio

@since 17-05-2006

@version P11

@param cProjeto, 		caracter, Codigo do projeto
@param cRevisa, 		caracter, Codigo da revisão
@param aTarefas, 		array,    Codigos da tarefa
@param lAtuEDT, 		logico,   Se deve atualizar as EDTs
@param aAtuEDT, 		array,    Codigos da EDT que tiveram as tarefas editadas
@param lReprParc, 	logico,   Se verdadeiro deve recalcular parcialmente
@param aBaseDados, 	array     Contem informacoes das tarefas já lidas como: o codigo, data e hora de inicio e fim, Recno

@return array, [1] - Verdadeiro, as datas das tarefas estao corretas e [2] - Array com os codigos das tarefas sucessoras.

/*/
Static Function auxSimScs(cProjeto,cRevisa,aTarefas,lAtuEDT,aAtuEDT,lReprParc,aBaseDados)
Local aTskSuc := {}
Local lRet		:= .T.
Local nX      := 0
Local cTarefa := ""

DEFAULT lAtuEDT	:= .T.
DEFAULT aAtuEDT	:= {}
DEFAULT lReprParc := .F.

For nX := 1 to len(aTarefas)

	cTarefa := aTarefas[nX]

	dbSelectArea("AFD")
	dbSetOrder(2)  // verifica se alguma tarefa depende da tarefa atual (tem ela como predecessora)
	MsSeek(xFilial("AFD")+cProjeto+cRevisa+cTarefa)
	While (!Eof() .And. xFilial("AFD")+cProjeto+cRevisa+cTarefa==;
		AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_PREDEC) .and. lRet
		PmsSimPrd(AFD->AFD_PROJET,AFD->AFD_REVISA,AFD->AFD_TAREFA,lAtuEDT,@aAtuEDT,lReprParc,@aBaseDados)

		// Busco registro da tarefa que terá novas datas e horas
		nPosBase := aScan(aBaseDados,{|x|x[1]+x[2] == "AF9" + AFD->AFD_TAREFA })

		If (lRet := PA203VldRes(aBaseDados, nPosBase))
			aAdd(aTskSuc, AFD->AFD_TAREFA)
		else
			aTskSuc := {}
			Exit
		EndIf

		AFD->(dbSkip())
	EndDo

	If !lRet
		Exit
	EndIf

Next nX

Return {lRet,aTskSuc}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsSimPrd³ Autor ³ Rodrigo Antonio 		  ³ Data ³ 17-05-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a atualizacao das datas das tarefas de acordo com as  ³±±
±±³          ³suas predecessoras. No array de Simulacao							 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsSimPrd(cProjeto,cRevisa,cTarefa,lAtuEDT,aAtuEDT,lReprParc,aBaseDados)

Local cHoraF
Local aAuxRet
Local dFinish
Local cCalend
Local nHDurac
Local aArea		:= GetArea()
Local aAreaAFC	:= AFC->(GetArea())
Local aAreaAJ4	:= AJ4->(GetArea())
Local aAreaAFD	:= AFD->(GetArea())
Local aAreaAF9	:= AF9->(GetArea())
Local dStart	:= PMS_MIN_DATE
Local cHoraI	:= "00:00"
Local nPosBase
Local lVarMemo := IIF(Type("lRotSimula")=="U", .F., lRotSimula)  //NO CASO DA CHAMADA DA ROTINA DE SIMULACAO, NAO TEREMOS VARIAVEIS DE MEMORIA

DEFAULT lAtuEDT	:= .T.
DEFAULT aAtuEDT	:= {}
DEFAULT lReprParc := .F.

dbSelectArea("AFC")
dbSetOrder(1)

dbSelectArea("AF9")
dbSetOrder(1)//AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_TAREFA+AF9_ORDEM
MsSeek(xFilial("AF9")+cProjeto+cRevisa+cTarefa) //pega o calendario e duracao da tarefa q depende da trf atual
nRecAF9	:= RecNo()
cCalend	:= AF9->AF9_CALEND
nHDurac	:= AF9->AF9_HDURAC
// Pega a restriçao da tarefa para que faça validação quando possivel
cRestricao := AF9->AF9_RESTRI
dDataRest  := AF9->AF9_DTREST
cHrRest    := AF9->AF9_HRREST

nPosBase := getPosArry(@aBaseDados,"AF9",cTarefa)
If ( Empty(AF9->AF9_DTATUI) .Or. lReprParc ) .And. Empty(AF9->AF9_DTATUF) .And. (AF9->AF9_PRIORI < 1000)
	dbSelectArea("AFD")
	dbSetOrder(1) //AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA+AFD_ITEM
	MsSeek(xFilial("AFD")+cProjeto+cRevisa+cTarefa)
	While (!Eof() .And. xFilial("AFD")+cProjeto+cRevisa+cTarefa==;
		AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA)

		// Seleciona a tarefa atual
		AF9->(DbSeek(xFilial("AF9") + AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_PREDEC))
		If lVarMemo .and. (AFD->AFD_PREDEC == M->AF9_TAREFA)

			// Caso eu esteja manipulando a tarefa predecessora, nao necessariamente
			// os dados da base estao iguais aos de memoria atual (posso ter alterado)
			If (aScan(aBaseDados,{|x|x[1]+x[2] == "AF9" + AFD->AFD_PREDEC }) == 0)
				aAdd(aBaseDados,{"AF9",M->AF9_TAREFA,M->AF9_START,M->AF9_HORAI,M->AF9_FINISH,M->AF9_HORAF,M->AF9_HDURAC,M->AF9_HUTEIS,M->AF9_NIVEL,M->AF9_DTATUI,M->AF9_DTATUF, AF9->(RECNO())})
				nPosBase := getPosArry(@aBaseDados,"AF9",AFD->AFD_PREDEC)
			Endif
			//nPosBase := getPosArry(@aBaseDados,"AF9",AFD->AFD_PREDEC)
		Else
			nPosBase := getPosArry(@aBaseDados,"AF9",AFD->AFD_PREDEC, TYPE("M->AF9_TAREFA") == "C" )
		EndIf

		// retorno para o registro da tarefa sucessora e faço os devidos calculos
		AF9->(DbGoto(nRecAF9))
		Do Case
			Case AFD->AFD_TIPO=="1" //Fim no Inicio
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(aBaseDados[nPosBase,SIM_FINISH],aBaseDados[nPosBase,SIM_HORAF],AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskF(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSCalRest(cRestricao, dDataRest, cHrRest ,aAuxRet,cCalend,nHDurac,AF9->AF9_PROJET)
				Else
					aAuxRet := PMSDTaskF(aBaseDados[nPosBase,SIM_FINISH],aBaseDados[nPosBase,SIM_HORAF],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSCalRest(cRestricao, dDataRest, cHrRest ,aAuxRet,cCalend,nHDurac,AF9->AF9_PROJET)
				EndIf
			Case AFD->AFD_TIPO=="2" //Inicio no Inicio
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(aBaseDados[nPosBase,SIM_START],aBaseDados[nPosBase,SIM_HORAI],AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskF(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskF(aBaseDados[nPosBase,SIM_START],aBaseDados[nPosBase,SIM_HORAI],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				EndIf
			Case AFD->AFD_TIPO=="3" //Fim no Fim
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(aBaseDados[nPosBase,SIM_FINISH],aBaseDados[nPosBase,SIM_HORAF],AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskI(aBaseDados[nPosBase,SIM_FINISH],aBaseDados[nPosBase,SIM_HORAF],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				EndIf
			Case AFD->AFD_TIPO=="4" //Inicio no Fim
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(aBaseDados[nPosBase,SIM_START],aBaseDados[nPosBase,SIM_HORAI],AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskI(aBaseDados[nPosBase,SIM_START],aBaseDados[nPosBase,SIM_HORAI],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				EndIf
		EndCase
		If  (aAuxRet[1]==dStart.And.SubStr(aAuxRet[2],1,2)+SubStr(aAuxRet[2],4,2)>SubStr(cHoraI,1,2)+SubStr(cHoraI,4,2)).Or.;
			(aAuxRet[1] > dStart)
			dStart := aAuxRet[1]
			cHoraI := aAuxRet[2]
			dFinish:= aAuxRet[3]
			cHoraF := aAuxRet[4]
		EndIf
		AFD->(dbSkip())
	End
	dbSelectArea("AJ4")
	dbSetOrder(1)
	MsSeek(xFilial("AJ4")+cProjeto+cRevisa+cTarefa) // Existe amarracao tambem com EDT?
	While !Eof() .And. xFilial("AJ4")+cProjeto+cRevisa+cTarefa==;
		AJ4_FILIAL+AJ4_PROJET+AJ4_REVISA+AJ4_TAREFA
		AFC->(MsSeek(xFilial("AFC")+AJ4->AJ4_PROJET+AJ4->AJ4_REVISA+AJ4->AJ4_PREDEC))
		nPosBase := getPosArry(@aBaseDados,"AFC",AFC->AFC_EDT)
		Do Case
			Case AJ4->AJ4_TIPO=="1" //Fim no Inicio
				If !Empty(AJ4->AJ4_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(aBaseDados[nPosBase,SIM_FINISH],aBaseDados[nPosBase,SIM_HORAF],AF8->AF8_CALEND,AJ4->AJ4_HRETAR,AFC->AFC_PROJET,Nil)
					aAuxRet := PMSDTaskF(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AFC->AFC_PROJET,Nil)
					aAuxRet := PMSCalRest(cRestricao, dDataRest, cHrRest ,aAuxRet,cCalend,nHDurac,AFC->AFC_PROJET)
				Else
					aAuxRet := PMSDTaskF(aBaseDados[nPosBase,SIM_FINISH],aBaseDados[nPosBase,SIM_HORAF],cCalend,nHDurac,AFC->AFC_PROJET,Nil)
					aAuxRet := PMSCalRest(cRestricao, dDataRest, cHrRest ,aAuxRet,cCalend,nHDurac,AFC->AFC_PROJET)
				EndIf
			Case AJ4->AJ4_TIPO=="2" //Inicio no Inicio
				If !Empty(AJ4->AJ4_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(aBaseDados[nPosBase,SIM_START],aBaseDados[nPosBase,SIM_HORAI],AF8->AF8_CALEND,AJ4->AJ4_HRETAR,AFC->AFC_PROJET,Nil)
					aAuxRet := PMSDTaskF(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AFC->AFC_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskF(aBaseDados[nPosBase,SIM_START],aBaseDados[nPosBase,SIM_HORAI],cCalend,nHDurac,AFC->AFC_PROJET,Nil)
				EndIf
			Case AJ4->AJ4_TIPO=="3" //Fim no Fim
				If !Empty(AJ4->AJ4_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(aBaseDados[nPosBase,SIM_FINISH],aBaseDados[nPosBase,SIM_HORAF],AF8->AF8_CALEND,AJ4->AJ4_HRETAR,AFC->AFC_PROJET,Nil)
					aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AFC->AFC_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskI(aBaseDados[nPosBase,SIM_FINISH],aBaseDados[nPosBase,SIM_HORAF],cCalend,nHDurac,AFC->AFC_PROJET,Nil)
				EndIf
			Case AJ4->AJ4_TIPO=="4" //Inicio no Fim
				If !Empty(AJ4->AJ4_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(aBaseDados[nPosBase,SIM_START],aBaseDados[nPosBase,SIM_HORAI],AF8->AF8_CALEND,AJ4->AJ4_HRETAR,AFC->AFC_PROJET,Nil)
					aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AFC->AFC_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskI(aBaseDados[nPosBase,SIM_START],aBaseDados[nPosBase,SIM_HORAI],cCalend,nHDurac,AFC->AFC_PROJET,Nil)
				EndIf
		EndCase
		If  (aAuxRet[1]==dStart.And.SubStr(aAuxRet[2],1,2)+SubStr(aAuxRet[2],4,2)>SubStr(cHoraI,1,2)+SubStr(cHoraI,4,2)).Or.;
			(aAuxRet[1] > dStart)
			dStart := aAuxRet[1]
			cHoraI := aAuxRet[2]
			dFinish:= aAuxRet[3]
			cHoraF := aAuxRet[4]
		EndIf

		AJ4->(dbSkip())
	End
	 // VALIDAÇÃO DA DATA DA TAREFA RELACIONADA COM A EDT (AJ4)
	nPosBase := getPosArry(aBaseDados,"AF9",cTarefa)
	//TABELA -1 ,TAREFA-2 ,START-3 ,HORAI-4,FINSIH-5,HORAF-6,HDURAC-7,HUTEIS-8
	aBaseDados[nPosBase,SIM_START]	 := dStart
	aBaseDados[nPosBase,SIM_HORAI]	 := cHoraI
	aBaseDados[nPosBase,SIM_FINISH]	 := dFinish
	aBaseDados[nPosBase,SIM_HORAF]	 := cHoraF

	If lAtuEDT
		PmsSimEDT(AF9_PROJET,AF9_REVISA,AF9_EDTPAI,@aAtuEDT,.T.,,,,@aBaseDados)
	Else
		If aScan(aAtuEDT,AF9->AF9_EDTPAI) <= 0
			aAdd(aAtuEDT,AF9->AF9_EDTPAI)
		EndIf
	EndIf

EndIf

RestArea(aAreaAFC)
RestArea(aAreaAF9)
RestArea(aAreaAJ4)
RestArea(aAreaAFD)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsSimEDT³ Autor ³ Rodrigo Antonio	     ³ Data ³ 16-05-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de atualizacao das Datas das EDT na estrutura de uma   ³±±
±±³          ³Tarefa.                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PmsSimEDT(cProjeto,cRevisa,cEDTPai,aAuxEDT,lAtuEDT,lAtuScs,lForceAtu,lReprParc,aBaseDados)

Local nHrsUteis	:= 0
Local cHrsIni	:= "24:00"
Local cHrsFim	:= "00:00"
Local dIniEDT	:= PMS_MAX_DATE
Local dFimEDT	:= PMS_MIN_DATE
Local lAtuHDurac := .F.
Local nX
Local lFirst	:= .F.
Local nPosBase := 0
Local lOk 		:= .T.

DEFAULT lAtuScs	  := .T.
DEFAULT lAtuEDT	  := .T.
DEFAULT lForceAtu := .F.

If aAuxEDT == Nil
	lFirst  := .T.
	aAuxEDT := {}
EndIf

dbSelectArea("AFC")
dbSetOrder(2)//AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDTPAI+AFC_ORDEM
If MsSeek(xFilial("AFC")+cProjeto+cRevisa+cEDTPai)
	While (!Eof() .And. xFilial("AFC")+cProjeto+cRevisa+cEDTPai==;
		AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDTPAI)

		nPosBase := getPosArry(@aBaseDados,"AFC",AFC->AFC_EDT)
		nHrsUteis += aBaseDados[nPosBase,SIM_HUTEIS]

		If !Empty(aBaseDados[nPosBase,SIM_START]).And.((aBaseDados[nPosBase,SIM_START]==dIniEDT.And.SubStr(aBaseDados[nPosBase,SIM_HORAI],1,2)+SubStr(aBaseDados[nPosBase,SIM_HORAI],4,2)<SubStr(cHrsIni,1,2)+SubStr(cHrsIni,4,2)).Or.;
					(aBaseDados[nPosBase,SIM_START]<dIniEDT))

			dIniEDT := aBaseDados[nPosBase,SIM_START]
			cHrsIni	:= aBaseDados[nPosBase,SIM_HORAI]
			lAtuHDurac:= .T.
		EndIf

		If  !Empty(aBaseDados[nPosBase,SIM_FINISH]).And.((aBaseDados[nPosBase,SIM_FINISH]==dFimEDT.And.SubStr(aBaseDados[nPosBase,SIM_HORAF],1,2)+;
			SubStr(aBaseDados[nPosBase,SIM_HORAF],4,2)>SubStr(chrsFim,1,2)+SubStr(cHrsFim,4,2)).Or.	(aBaseDados[nPosBase,SIM_FINISH]>dFimEDT))
			dFimEDT := aBaseDados[nPosBase,SIM_FINISH]
			cHrsFim	:= aBaseDados[nPosBase,SIM_HORAF]
			lAtuHDurac:= .T.
		EndIf

		AFC->(dbSkip())
	EndDo
EndIf
dbSelectArea("AF9")
dbSetOrder(2)//AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_EDTPAI+AF9_ORDEM
If MsSeek(xFilial("AF9")+cProjeto+cRevisa+cEDTPai)
	While !Eof() .And. xFilial("AF9")+cProjeto+cRevisa+cEDTPai==;
		AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_EDTPAI

		nPosBase := aScan(aBaseDados,{|x|x[1]+x[2] == "AF9" + AF9->AF9_TAREFA })
		If nPosBase > 0
			nHrsUteis += aBaseDados[nPosBase,SIM_HUTEIS]

			If !Empty(aBaseDados[nPosBase,SIM_START]).And.((aBaseDados[nPosBase,SIM_START]==dIniEDT.And.SubStr(aBaseDados[nPosBase,SIM_HORAI],1,2)+;
				SubStr(aBaseDados[nPosBase,SIM_HORAI],4,2)<SubStr(cHrsIni,1,2)+SubStr(cHrsIni,4,2)).Or.;
				(aBaseDados[nPosBase,SIM_START]<dIniEDT))

				dIniEDT := aBaseDados[nPosBase,SIM_START]
				cHrsIni	:= aBaseDados[nPosBase,SIM_HORAI]

				lAtuHDurac:= .T.
			EndIf

			If  !Empty(aBaseDados[nPosBase,SIM_FINISH]).And.((aBaseDados[nPosBase,SIM_FINISH]==dFimEDT.And.SubStr(aBaseDados[nPosBase,SIM_HORAF],1,2)+;
				SubStr(aBaseDados[nPosBase,SIM_HORAF],4,2)>SubStr(chrsFim,1,2)+SubStr(cHrsFim,4,2)).Or.	(aBaseDados[nPosBase,SIM_FINISH]>dFimEDT))

				dFimEDT := aBaseDados[nPosBase,SIM_FINISH]
				cHrsFim	:= aBaseDados[nPosBase,SIM_HORAF]
				lAtuHDurac:= .T.
			EndIf

		Else
			nHrsUteis += AF9->AF9_HUTEIS

			If !Empty(AF9->AF9_START).And.((AF9->AF9_START==dIniEDT.And.SubStr(AF9->AF9_HORAI,1,2)+;
				SubStr(AF9->AF9_HORAI,4,2)<SubStr(cHrsIni,1,2)+SubStr(cHrsIni,4,2)).Or.;
				(AF9->AF9_START<dIniEDT))

				dIniEDT 	:= AF9->AF9_START
				cHrsIni 	:= AF9->AF9_HORAI

				lAtuHDurac:= .T.
			EndIf

			If  !Empty(AF9->AF9_FINISH).And.((AF9->AF9_FINISH==dFimEDT.And.SubStr(AF9->AF9_HORAF,1,2)+;
				SubStr(AF9->AF9_HORAF,4,2)>SubStr(cHrsFim,1,2)+SubStr(cHrsFim,4,2)).Or. (AF9->AF9_FINISH>dFimEDT))

				dFimEDT := AF9->AF9_FINISH
				cHrsFim	:= AF9->AF9_HORAF
				lAtuHDurac:= .T.
			EndIf

		EndIf

		AF9->(dbSkip())
	EndDo

	If	Type("M->AF9_TAREFA")<>"U"
		nPosBase := aScan(aBaseDados,{|x|x[1]+x[2] == "AF9" + M->AF9_TAREFA })
		If nPosBase > 0
			nHrsUteis += aBaseDados[nPosBase,SIM_HUTEIS]

			If !Empty(aBaseDados[nPosBase,SIM_START]).And.((aBaseDados[nPosBase,SIM_START]==dIniEDT.And.SubStr(aBaseDados[nPosBase,SIM_HORAI],1,2)+;
				SubStr(aBaseDados[nPosBase,SIM_HORAI],4,2)<SubStr(cHrsIni,1,2)+SubStr(cHrsIni,4,2)).Or.;
				(aBaseDados[nPosBase,SIM_START]<dIniEDT))

				dIniEDT := aBaseDados[nPosBase,SIM_START]
				cHrsIni	:= aBaseDados[nPosBase,SIM_HORAI]

				lAtuHDurac:= .T.
			EndIf

			If  !Empty(aBaseDados[nPosBase,SIM_FINISH]).And.((aBaseDados[nPosBase,SIM_FINISH]==dFimEDT.And.SubStr(aBaseDados[nPosBase,SIM_HORAF],1,2)+;
				SubStr(aBaseDados[nPosBase,SIM_HORAF],4,2)>SubStr(chrsFim,1,2)+SubStr(cHrsFim,4,2)).Or.	(aBaseDados[nPosBase,SIM_FINISH]>dFimEDT))

				dFimEDT := aBaseDados[nPosBase,SIM_FINISH]
				cHrsFim	:= aBaseDados[nPosBase,SIM_HORAF]
				lAtuHDurac:= .T.
			EndIf
		Endif
	EndIf

EndIf

dbSelectArea("AFC")
dbSetOrder(1)//AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDT+AFC_ORDEM
If MsSeek(xFilial("AFC")+cProjeto+cRevisa+cEDTPai)
	nPosBase := getPosArry(aBaseDados,"AFC",AFC->AFC_EDT)
	If lAtuHDurac
		If DTOS(aBaseDados[nPosBase,SIM_START])+aBaseDados[nPosBase,SIM_HORAI]+DTOS(aBaseDados[nPosBase,SIM_FINISH])+;
			aBaseDados[nPosBase,SIM_HORAF]<>DTOS(dIniEDT)+cHrsIni+DTOS(dFimEDT)+cHrsFim .OR. lForceAtu
			aBaseDados[nPosBase,SIM_START]	 := dIniEDT
			aBaseDados[nPosBase,SIM_HORAI]	 := cHrsIni
			aBaseDados[nPosBase,SIM_FINISH]	 := dFimEDT
			aBaseDados[nPosBase,SIM_HORAF]	 := cHrsFim
			nHDurac := PmsHrsItvl(dIniEDT,cHrsIni,dFimEDT,cHrsFim,AFC->AFC_CALEND,AFC->AFC_PROJET)
			aBaseDados[nPosBase,SIM_HDURAC] := IIf (ChkTam("AFC_HDURAC",nHDurac),nHDurac,0)
			aBaseDados[nPosBase,SIM_HUTEIS] := IIf (ChkTam("AFC_HUTEIS",nHrsUteis),nHrsUteis,0)
		Else
			lAtuScs := .F.
			lATuEDT := .F.
		EndIf
		If lAtuScs
			lOk := PmsSimScsE(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT,.F.,aAuxEDT,lReprParc,@aBaseDados)
		EndIf
	Else
		If ( Empty(AFC->AFC_START) .And.Empty(AFC->AFC_FINISH).And.Empty(AFC->AFC_HORAI).And.Empty(AFC->AFC_HORAF))
			lAtuScs := .F.
			lATuEDT := .F.
		Else
			RecLock("AFC",.F.)
			AFC->AFC_START	:= PMS_EMPTY_DATE
			AFC->AFC_FINISH	:= PMS_EMPTY_DATE
			AFC->AFC_HORAI	:= ""
			AFC->AFC_HORAF	:= ""
			AFC->AFC_HDURAC	:= 0
			AFC->AFC_HUTEIS	:= 0
			MsUnlock()
		EndIf

		If lAtuScs
			lOk := PmsSimScsE(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT,.F.,aAuxEDT,lReprParc,@aBaseDados)
		EndIf
	EndIf

	If aScan(aAuxEDT,AFC->AFC_EDT) <= 0
		aAdd(aAuxEDT,AFC->AFC_EDT)
	EndIf

	AJ4->(dbSetOrder(2))
	If lOk .AND. (lAtuEDT .Or. (!Empty(AFC->AFC_EDTPAI) .And. AJ4->(MsSeek(xFilial()+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDTPAI))))
		PmsSimEDT(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDTPAI,@aAuxEDT,lAtuEDT,lAtuScs,lForceAtu,lReprParc,@aBaseDados)
	EndIf

EndIf

If lFirst .AND. lOk
	If lAtuScs
		For nx := 1 to Len(aAuxEDT)
			PmsSimEDT(cProjeto,cRevisa,aAuxEDT[nx],,.T.,lAtuScs,lForceAtu,lReprParc,@aBaseDados)
		Next nX
	EndIf
EndIf


Return lOk

//*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
//³Debug Array³
//ÀÄÄÄÄÄÄÄÄÄÄÄÙ
//ENDDOC*/

Function debugImpA(aArray)
Local cRet := ""
Local nx
Local ny
For nx :=1 to Len (aArray)
	For ny := 1 to len (aArray[nx])
		If ValType( aArray[nx,ny] ) == 'D'
			aArray[nx,ny] := DtoS(aArray[nx,ny])
		Endif
		cRet +=	Alltrim(aArray[nx,ny]) + ","
	Next ny
	cRet += Chr(13) + Chr(10)
Next nx
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsSimPrdI³ Autor ³ Rodrigo Antonio		  ³ Data ³ 17-05-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a atualizacao das datas das tarefas de acordo com as  ³±±
±±³          ³suas sucessoras. Original PmsAuPrdI                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsSimPrdI(cProjeto,cRevisa,cTarefa,lAtuEDT, nMetodo, aRecsAF9, aAtuEDT,lReprParc,aBaseDados)

Local cHoraF
Local aAuxRet
Local dFinish
Local cCalend
Local nHDurac
Local nRecAF9
Local aArea		:= GetArea()
Local aAreaAFD	:= AFD->(GetArea())
Local aAreaAF9	:= AF9->(GetArea())
Local dStart	:= PMS_MAX_DATE
Local cHoraI	:= "00:00"
Local lCalcDtHr := .F.
Local nPosBase
DEFAULT lAtuEDT	:= .T.
DEFAULT aAtuEDT	:= {}
DEFAULT lReprParc := .F.

dbSelectArea("AF9")
dbSetOrder(1)
MsSeek(xFilial()+cProjeto+cRevisa+cTarefa)
nRecAF9	:= RecNo()
cCalend	:= AF9->AF9_CALEND
nHDurac	:= AF9->AF9_HDURAC

//Busca na base em array, se nao achar adiciona a tarefa la
nPosBase := getPosArry (aBaseDados,"AF9",AF9->AF9_TAREFA)
If ( Empty(AF9->AF9_DTATUI) .Or. lReprParc ) .And. Empty(AF9->AF9_DTATUF) .And. AF9->AF9_PRIORI < 1000
	dbSelectArea("AFD")
	dbSetOrder(2)
	MsSeek(xFilial("AFD")+cProjeto+cRevisa+cTarefa)
	While (!Eof() .And. xFilial("AFD")+cProjeto+cRevisa+cTarefa==;
		AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_PREDEC)
		AF9->(MsSeek(xFilial("AF9")+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_TAREFA))
		nPosBase := getPosArry(aBaseDados,"AF9",AF9->AF9_TAREFA)
		Do Case
			Case AFD->AFD_TIPO=="4" //Fim no Inicio
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(aBaseDados[nPosBase,SIM_FINISH],aBaseDados[nPosBase,SIM_HORAF],AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskF(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskF(aBaseDados[nPosBase,SIM_FINISH],aBaseDados[nPosBase,SIM_HORAF],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				EndIf
			Case AFD->AFD_TIPO=="2" //Inicio no Inicio
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(aBaseDados[nPosBase,SIM_START],aBaseDados[nPosBase,SIM_HORAI],AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskF(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskF(aBaseDados[nPosBase,SIM_START],aBaseDados[nPosBase,SIM_HORAI],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				EndIf
			Case AFD->AFD_TIPO=="3" //Fim no Fim
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(aBaseDados[nPosBase,SIM_FINISH],aBaseDados[nPosBase,SIM_HORAF],AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskI(aBaseDados[nPosBase,SIM_FINISH],aBaseDados[nPosBase,SIM_HORAF],cCalend,nHDurac,AF9->AF9_PROJET,Nil)

				EndIf
			Case AFD->AFD_TIPO=="1" //Inicio no Fim
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(aBaseDados[nPosBase,SIM_START],aBaseDados[nPosBase,SIM_HORAI],AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskI(aBaseDados[nPosBase,SIM_START],aBaseDados[nPosBase,SIM_HORAI],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				EndIf
		EndCase

		If  (aAuxRet[1]==dStart.And.SubStr(aAuxRet[2],1,2)+SubStr(aAuxRet[2],4,2)<SubStr(cHoraI,1,2)+SubStr(cHoraI,4,2)).Or.;
			(aAuxRet[1] < dStart)
			dStart := aAuxRet[1]
			cHoraI := aAuxRet[2]
			dFinish:= aAuxRet[3]
			cHoraF := aAuxRet[4]
		EndIf
		dbSelectArea("AFD")
		dbSkip()
	End
	dbSelectArea("AF9")
	If dStart <> PMS_MAX_DATE
		AF9->(dbGoto(nRecAF9))
		nPosBase := getPosArry(aBaseDados,"AF9",AF9->AF9_TAREFA)
		lCalcDtHr := (Ascan(aRecsAF9, nRecAF9) > 0)
		If nMetodo == 1 .OR. ;
			( nMetodo == 2 .And. !lCalcDtHr ) .OR. ;
			(	nMetodo == 2 .And. lCalcDtHr .And. ;
			((dStart == aBaseDados[nPosBase,SIM_START] .And. ;
			SubStr(cHoraI,1,2)+SubStr(cHoraI,4,2)>SubStr(aBaseDados[nPosBase,SIM_HORAI],1,2)+SubStr(aBaseDados[nPosBase,SIM_HORAI],4,2)).Or.;
			dStart > aBaseDados[nPosBase,SIM_START]  ) .And. ;
			((dFinish == aBaseDados[nPosBase,SIM_FINISH]  .And. ;
			SubStr(cHoraF,1,2)+SubStr(cHoraF,4,2)>SubStr(aBaseDados[nPosBase,SIM_HORAF],1,2)+SubStr(aBaseDados[nPosBase,SIM_HORAF],4,2)).Or.;
			dFinish > aBaseDados[nPosBase,SIM_FINISH]))
			aAdd(aRecsAF9, nRecAF9)
			aBaseDados[nPosBase,SIM_START]		:= dStart
			aBaseDados[nPosBase,SIM_HORAI]		:= cHoraI
			aBaseDados[nPosBase,SIM_FINISH]	:= dFinish
			aBaseDados[nPosBase,SIM_HORAF]		:= cHoraF

			If aScan(aAtuEDT,AF9->AF9_EDTPAI) <= 0
				aAdd(aAtuEDT,AF9->AF9_EDTPAI)
			EndIf
			If lAtuEDT
				PmsSimEDT(AF9_PROJET,AF9_REVISA,AF9_EDTPAI,,,,,lReprParc,@aBaseDados)
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaAF9)
RestArea(aAreaAFD)
RestArea(aArea)
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsSimScsI³ Autor ³ Rodrigo Antonio		  ³ Data ³ 17-05-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a atualizacao das datas das tarefas Sucessoras.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsSimScsI(cProjeto,cRevisa,cTarefa,lAtuEDT, nMetodo, aRecsAF9, aAtuEDT,lReprParc,aBaseDados)
Local aArea		:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAFD	:= AFD->(GetArea())

DEFAULT lAtuEDT	:= .T.
DEFAULT aAtuEDT	:= {}
DEFAULT lReprParc := .F.

dbSelectArea("AFD")
dbSetOrder(1) // AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA+AFD_ITEM
MsSeek(xFilial("AFD")+cProjeto+cRevisa+cTarefa) //PROCURA O RELACIONAMENTO DA TAREFA ATUAL
While !Eof() .And. xFilial("AFD")+cProjeto+cRevisa+cTarefa==;
	AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA
	PmsSimPrdI(AFD->AFD_PROJET,AFD->AFD_REVISA,AFD->AFD_PREDEC,lAtuEDT, nMetodo, aRecsAF9, aAtuEDT,lReprParc,aBaseDados)

	dbSelectArea("AFD")
	PmsSimScsI(AFD_PROJET,AFD_REVISA,AFD_PREDEC,lAtuEDT, nMetodo, aRecsAF9, aAtuEDT,lReprParc,@aBaseDados)
	PmsSimScs(AFD->AFD_PROJET,AFD->AFD_REVISA,AFD->AFD_PREDEC,lAtuEDT, aAtuEDT,lReprParc,@aBaseDados)

	dbSkip()
EndDo


RestArea(aAreaAF9)
RestArea(aAreaAFD)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsSimScsE³ Autor ³ Rodrigo Antonio			³ Data ³ 18/05/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a atualizacao das datas das tarefas Sucessoras. No Arra³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsSimScsE(cProjeto,cRevisa,cTarefa,lAtuEDT, aAtuEDT,lReprParc,aBaseDados)
Local aArea		:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAFD	:= AFD->(GetArea())
Local nPosBase	:= 0
Local lRet 		:= .T.

DEFAULT lAtuEDT	:= .T.
DEFAULT aAtuEDT	:= {}

dbSelectArea("AJ4")
dbSetOrder(2)
MsSeek(xFilial("AJ4")+cProjeto+cRevisa+cTarefa)  // verifica se alguma tarefa depende desta EDT
While !Eof() .And. xFilial("AJ4")+cProjeto+cRevisa+cTarefa==;
	AJ4_FILIAL+AJ4_PROJET+AJ4_REVISA+AJ4_PREDEC .and. lRet

	PmsSimPrd(AJ4->AJ4_PROJET,AJ4->AJ4_REVISA,AJ4->AJ4_TAREFA,lAtuEDT,@aAtuEDT,lReprParc,@aBaseDados)

	// Busco registro da tarefa que terá novas datas e horas
	nPosBase := aScan(aBaseDados,{|x|x[1]+x[2] == "AF9" + AJ4->AJ4_TAREFA })

	If (lRet := PA203VldRes(aBaseDados, nPosBase))
		PmsSimScs(AJ4_PROJET,AJ4_REVISA,AJ4_TAREFA,lAtuEDT,aAtuEDT,lReprParc,@aBaseDados)
	else
		Exit
	EndIf

	dbSkip()
End


RestArea(aAreaAFD)
RestArea(aAreaAF9)
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsDlgSimGnt³ Autor ³ Rodrigo Antonio	  ³ Data ³ 18-05-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta a tela de visualizacao do Gantt do projeto, quando      ³±±
±±³ 			 ³ usamos simulacao														    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsDlgSimGnt(cVersao,aCfgTsk,oDLg,oTree,cArquivo,aBaseDados)

Local aArea		:= GetArea()
Local aAreaAF8	:= AF8->(GetArea())
Local aConfig	:= {6,1,.F.,.T.,.T.,.T.,.F.,.F.,.F.,99}
Local dIni
Local aGantt
Local nTsk
Local nTop      := oMainWnd:nTop+35
Local nLeft     := oMainWnd:nLeft+10
Local nBottom   := oMainWnd:nBottom-12
Local nRight    := oMainWnd:nRight-10
If PmsCfgGnt(cVersao,,aConfig,dIni,aGantt)
	MsgRun("Gantt",cCadastro,{|| AuxDlgAF8Gnt(@cVersao,@aConfig,@dIni,@aGantt,@nTsk,nTop,nLeft,nBottom,nRight,aCfgTsk,@oTree,cArquivo,aBaseDados) })
EndIf

RestArea(aAreaAF8)
RestArea(aArea)
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsArrayGnt³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta o array contendo os dados do Gantt.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PmsSimGnt(aGant,cChave,lViewRec,nTpData,oBold,aConfig,aTaskCPM,nMaxNiveis,nNivelAtu,aTarefasDep,aBaseDados)

Local aArea		:= GetArea()
Local aAreaAFC	:= AFC->(GetArea())
Local aAreaAF9	:= AF9->(GetArea())
Local cCritica	:= ""
Local nPosTsk
Local aCorBarras := LoadCorBarra( "MV_PMSGCOR" )
Local lAdiciona := .T.
Local nEspaco := 0
Local nRealEspaco := 0
Local cDescri := ""
Local cDesc		:= ""
Local nContLin:= 0
Local nFaz		:= 0
Local dDtaIniEf
Local cHorIniEf
Local dDtaFimEf
Local cHorFimef
Local cCor
Local aNodes := {}
Local nNode  := 0

DEFAULT aTarefasDep := {}
DEFAULT nNivelAtu := 1
DEFAULT aConfig	:= {1, PMS_MIN_DATE, PMS_MAX_DATE}

nPosBase := getPosArry(aBaseDados,"AFC",AFC->AFC_EDT)
If PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,1,"ESTRUT",AFC->AFC_REVISA)
	If 	(aConfig[1]==1) .Or.;
		(aConfig[1]==2 .And. !Empty(aBaseDados[nPosBase,SIM_DTATUF])).Or.;
		(aConfig[1]==3 .And. Empty(aBaseDados[nPosBase,SIM_DTATUF]))

		If !(aBaseDados[nPosBase,SIM_FINISH]<aConfig[2].Or.aBaseDados[nPosBase,SIM_START]>aConfig[3]) .Or. Empty(aBaseDados[nPosBase,SIM_START])
			If nTpData==1 .Or. nTpData == 3
				nRealEspaco := (VAL(aBaseDados[nPosBase,SIM_NIVEL])-1)
				nEspaco := nRealEspaco*3
				If Len(AllTrim( AFC->AFC_DESCRI )) <= (31-(nRealEspaco))
					cDescri := SPACE(nEspaco)+Substr( AFC->AFC_DESCRI,1,31-(nRealEspaco) )
				Else
					cDescri := SPACE(nEspaco)+Substr( AFC->AFC_DESCRI,1,28-(nRealEspaco) )+ "..."
				EndIf
				nContLin:=0
				If Len(space(nEspaco)+alltrim(AFC->AFC_DESCRI)) >= 30
					nTmpLin	:=	Len(space(nEspaco)+alltrim(AFC->AFC_DESCRI))/29
					nTmpLin	:=	If(Int(nTmpLin)<>nTmpLin,Int(nTmpLin)+1,nTmpLin)
					For nFaz := 1 to nTmpLin
						nContlin+=1
					Next nFaz
				Else
					nContLin := 1
				EndIf
				Do Case
					Case !Empty(aBaseDados[nPosBase,SIM_DTATUF])
						cCor := CLR_GRAY
					Case !Empty(aBaseDados[nPosBase,SIM_DTATUI])
						cCor := CLR_BROWN
					Case dDataBase > aBaseDados[nPosBase,SIM_START]
						cCor := CLR_HRED
					OtherWise
						cCor := CLR_GREEN
				EndCase
				aAdd(aGant,{{AFC->AFC_EDT,cDescri,DTOC(aBaseDados[nPosBase,SIM_START]),DTOC(aBaseDados[nPosBase,SIM_FINISH]),;
				Transform(aBaseDados[nPosBase,SIM_HDURAC],"@E 99999.99h"),"",SPACE(nEspaco)+Alltrim(AFC->AFC_DESCRI),nContlin},;
				{{aBaseDados[nPosBase,SIM_START],aBaseDados[nPosBase,SIM_HORAI],aBaseDados[nPosBase,SIM_FINISH],;
				aBaseDados[nPosBase,SIM_HORAF],"POC:"+AllTrim(TransForm(PmsPOCAFC(AFC->AFC_PROJET,AFC->AFC_REVISA,;
				AFC->AFC_EDT,PMS_MAX_DATE),"@E 999.99%")),,"",1,cCor}},ValorCorBarra( "1" ,aCorBarras ) ,oBold})
			EndIf
			If nTpData== 2 .Or. nTpData == 3
				nRealEspaco := (VAL(aBaseDados[nPosBase,SIM_NIVEL])-1)//(VAL(AF9->AF9_NIVEL)-1)
				nEspaco := nRealEspaco*3
				If Len(AllTrim( AFC->AFC_DESCRI)) <= (34-(nRealEspaco))
					cDescri := SPACE(nEspaco)+Substr( AFC->AFC_DESCRI,1,34-(nRealEspaco) )
				Else
					cDescri := SPACE(nEspaco)+Substr( AFC->AFC_DESCRI,1,31-(nRealEspaco) )+"..."
				EndIf
				If AFC->(ColumnPos("AFC_HRATUI")) > 0
					If !Empty(AFC->AFC_DTATUI)
						dDtaIniEf :=aBaseDados[nPosBase,SIM_DTATUI]
						cHorIniEf :=AFC->AFC_HRATUI
						dDtaFimEf := Iif(!Empty(aBaseDados[nPosBase,SIM_DTATUF]),aBaseDados[nPosBase,SIM_DTATUF],dDataBase)
						cHorFimef := AFC->AFC_HRATUF
					Else
						dDtaIniEf := dDataBase
						cHorIniEf := "00:00"
						dDtaFimEf := dDataBase
						cHorFimef := "00:00"
					EndIf
				Else
					If !Empty(aBaseDados[nPosBase,SIM_DTATUI])
						dDtaIniEf := aBaseDados[nPosBase,SIM_DTATUI]
						cHorIniEf := "08:00"
						dDtaFimEf := Iif(!Empty(aBaseDados[nPosBase,SIM_DTATUF]),aBaseDados[nPosBase,SIM_DTATUF],dDataBase)
						cHorFimef := "18:00"
					Else
						dDtaIniEf := dDataBase
						cHorIniEf := "00:00"
						dDtaFimEf := dDataBase
						cHorFimef := "00:00"
					EndIf
				EndIf
				aAdd(aGant,{{AFC->AFC_EDT,cDescri,DTOC(aBaseDados[nPosBase,SIM_DTATUI]),DTOC(aBaseDados[nPosBase,SIM_DTATUF]),;
				Transform(aBaseDados[nPosBase,SIM_HDURAC],"@E 99999.99h"),"",;
				SPACE(nEspaco)+Alltrim(AFC->AFC_DESCRI),nContlin},{{dDtaIniEf,cHorIniEf,dDtaFimEf,cHorFimef,;
				"POC:"+AllTrim(TransForm(PmsPOCAFC(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT, PMS_MAX_DATE),;
				"@E 999.99%")),,"",1,CLR_BLACK}},CLR_GRAY ,oBold})
			EndIf
		EndIf
	EndIf
EndIf
If nNivelAtu < nMaxNiveis
	nNivelAtu++

	dbSelectArea("AF9")
	dbSetOrder(2)
	MsSeek(xFilial()+cChave)
	//Posiciona o array na tarefa
	nPosBase := getPosArry(aBaseDados,"AF9",AF9->AF9_TAREFA)
	While !Eof() .And. AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+;
		AF9->AF9_EDTPAI==xFilial("AF9")+cChave
		lAdiciona := .T.
		If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,1,"ESTRUT",AF9->AF9_REVISA)
			If 	(aConfig[1]==1) .Or.;
				(aConfig[1]==2 .And. !Empty(aBaseDados[nPosBase,SIM_DTATUF])).Or.;
				(aConfig[1]==3 .And. Empty(aBaseDados[nPosBase,SIM_DTATUF]))
				If (Len(aConfig)>3)
					If !Empty(aConfig[4])
						dbSelectArea("AFA")
						dbSetOrder(5) // AFA_FILIAL + AFA_PROJET + AFA_REVISA + AFA_TAREFA + AFA_RECURS

						If !(AFA->(MsSeek(xFilial("AFA") + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_TAREFA + aConfig[4])))
							lAdiciona := .F.
						EndIf

						dbSelectArea("AF9")
						dbSetOrder(2)
					EndIf
				EndIf

				If lAdiciona
					aAdd(aNodes, {PMS_TASK,;
					AF9->(Recno()),;
					IIf(Empty(AF9->AF9_ORDEM), "000", AF9->AF9_ORDEM),;
					AF9->AF9_TAREFA,nPosBase})

					//Determina Dependencias entre tarefas
					dbSelectArea("AFD")
					dbSetOrder(1)
					If MsSeek(xFilial("AFD")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
						While !AFD->(EOF()) .And.  xFilial("AFD")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA== AFD->AFD_FILIAL+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_TAREFA
							nPos := aScan( aTarefasDep ,{|aTarefa| aTarefa[1] == AFD->AFD_TAREFA})
							If nPos > 0
								aadd( aTarefasDep[nPos,2],{ AFD->AFD_PREDEC ,AFD->AFD_TIPO } )
							Else
								aadd( aTarefasDep ,{ AFD->AFD_TAREFA ,{ {AFD->AFD_PREDEC ,AFD->AFD_TIPO} }} )
							Endif
							AFD->(dbSkip())
						End

					EndIf

					dbSelectArea("AJ4")
					dbSetOrder(1)

					If MsSeek(xFilial("AJ4")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
						While !AJ4->(EOF()) .And.  xFilial("AJ4")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA== AJ4->AJ4_FILIAL+AJ4->AJ4_PROJET+AJ4->AJ4_REVISA+AJ4->AJ4_TAREFA
							nPos := aScan( aTarefasDep ,{|aTarefa| aTarefa[1] == AJ4->AJ4_TAREFA})
							If nPos > 0
								aadd( aTarefasDep[nPos,2],{ AJ4->AJ4_PREDEC ,AJ4->AJ4_TIPO } )
							Else
								aadd( aTarefasDep ,{ AJ4->AJ4_TAREFA ,{ {AJ4->AJ4_PREDEC ,AJ4->AJ4_TIPO} }} )
							Endif
							AJ4->(dbSkip())
						End
					EndIf

				EndIf
			EndIf
		EndIf
		dbSelectArea("AF9")
		dbSkip()
	End

	dbSelectArea("AFC")
	dbSetOrder(2)
	MsSeek(xFilial()+cChave)
	While !Eof() .And. AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+;
		AFC->AFC_EDTPAI==xFilial("AFC")+cChave
		nPosBase := getPosArry(aBaseDados,"AFC",AFC->AFC_EDT)
		aAdd(aNodes, {PMS_WBS,;
		AFC->(Recno()),;
		IIf(Empty(AFC->AFC_ORDEM), "000", AFC->AFC_ORDEM),;
		AFC->AFC_EDT,nPosBase})
		dbSkip()
	EndDo

	aSort(aNodes, , , {|x, y| x[3]+x[4] < y[3]+y[4]})

	For nNode := 1 To Len(aNodes)
		If aNodes[nNode,1] == PMS_TASK
			// Tarefa
			dbSelectArea("AF9")
			AF9->(dbGoto(aNodes[nNode,2]))
			nPosBase := getPosArry(aBaseDados,"AF9",AF9->AF9_TAREFA)
			If !(aBaseDados[nPosBase,SIM_FINISH]<aConfig[2].Or.aBaseDados[nPosBase,SIM_START]>aConfig[3]) .Or.;
				Empty(aBaseDados[nPosBase,SIM_START])
				If nTpData==1 .Or. nTpData == 3
					If aTaskCPM <> Nil
						nPosTsk := aScan(aTaskCPM,{|x| x[1] == AF9->AF9_TAREFA })
						If nPosTsk > 0
							If 	DTOS(aBaseDados[nPosBase,SIM_FINISH])+aBaseDados[nPosBase,SIM_HORAF]==;
								DTOS(aTaskCPM[nPosTsk,12,3])+aTaskCPM[nPosTsk,12,4]
								cCritica := STR0195//"Sim"
							Else
								cCritica := STR0196//"Nao"
							EndIf
						Else
							cCritica := STR0196//"Nao"
						EndIf
					EndIf
					nRealEspaco := (VAL(aBaseDados[nPosBase,SIM_NIVEL])-1)
					nEspaco := nRealEspaco*3
					If Len(AllTrim( AF9->AF9_DESCRI )) <= (34-(nRealEspaco))
						cDescri := SPACE(nEspaco)+Substr( AF9->AF9_DESCRI,1,34-(nRealEspaco) )
					Else
						cDescri := SPACE(nEspaco)+Substr( AF9->AF9_DESCRI,1,31-(nRealEspaco) )+"..."
					EndIf
					cDesc := SPACE(nEspaco)+Alltrim(AF9->AF9_DESCRI)
					nContLin:=0
					If Len(cDesc) > 30
						nTmpLin	:=	Len(cDesc)/29
						nTmpLin	:=	If(Int(nTmpLin)<>nTmpLin,Int(nTmpLin)+1,nTmpLin)
						For nFaz := 1 to nTmpLin
							nContlin+=1
						Next nFaz
					Else
						nContLin := 1
					EndIf
					Do Case
						Case !Empty(aBaseDados[nPosBase,SIM_DTATUF])
							cCor := CLR_GRAY
						Case !Empty(aBaseDados[nPosBase,SIM_DTATUI])
							cCor := CLR_BROWN
						Case dDataBase > aBaseDados[nPosBase,SIM_START]
							cCor := CLR_HRED
						OtherWise
							cCor := CLR_GREEN
					EndCase
					aAdd(aGant,{{AF9->AF9_TAREFA,cDescri,DTOC(aBaseDados[nPosBase,SIM_START]),;
					DTOC(aBaseDados[nPosBase,SIM_FINISH]),Transform(AF9->AF9_HDURAC,;
					"@E 99999.99h"),cCritica,SPACE(nEspaco)+Alltrim(AF9->AF9_DESCRI),;
					nContlin},{{aBaseDados[nPosBase,SIM_START],aBaseDados[nPosBase,SIM_HORAI],;
					aBaseDados[nPosBase,SIM_FINISH],aBaseDados[nPosBase,SIM_HORAF],"POC:"+;
					AllTrim(TransForm(PmsPOCAF9(AF9->AF9_PROJET, AF9->AF9_REVISA,;
					AF9->AF9_TAREFA,PMS_MAX_DATE,AF9->AF9_QUANT),"@E 999.99%")),,;
					"",1,cCor}},ValorCorBarra( "2" ,aCorBarras ),})
					If lViewRec
						AF8->(dbSetOrder(1))
						dbSelectArea("AFA")
						dbSetOrder(1)
						MsSeek(xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
						While !Eof() .And. AFA->AFA_FILIAL+AFA->AFA_PROJET+AFA_REVISA+AFA->AFA_TAREFA==xFilial("AFA")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA
							If !Empty(AFA->AFA_RECURS)
								AE8->(MsSeek(xFilial()+AFA->AFA_RECURS))
								aAdd(aGant,{{"",SPACE((VAL(AF9->AF9_NIVEL)-1)*2)+AE8->AE8_DESCRI,"",;
								"","","",SPACE((VAL(AF9->AF9_NIVEL)-1)*2)+AE8->AE8_DESCRI,nContlin},;
								{{aBaseDados[nPosBase,SIM_START],aBaseDados[nPosBase,SIM_HORAI],aBaseDados[nPosBase,SIM_FINISH],aBaseDados[nPosBase,SIM_HORAF],;
								AllTrim(AFA->AFA_RECURS)+"  %Aloc:"+AllTrim(Transform(AFA->AFA_ALOC,"@E 9999.99%")),,,1,CLR_BLACK}},ValorCorBarra( "3" ,aCorBarras ),}) //"  %Aloc:"
							EndIf
							dbSkip()
						End
					EndIf
				EndIf
				If nTpData == 2 .Or. nTpData == 3
					If aTaskCPM <> Nil
						nPosTsk := aScan(aTaskCPM,{|x| x[1] == AF9->AF9_TAREFA })
						If nPosTsk > 0
							If 	DTOS(aBaseDados[nPosBase,SIM_FINISH])+aBaseDados[nPosBase,SIM_HORAF]==;
								DTOS(aTaskCPM[nPosTsk,12,3])+aTaskCPM[nPosTsk,12,4]
								cCritica := STR0195//"Sim"
							Else
								cCritica := STR0196//"Nao"
							EndIf
						Else
							cCritica := STR0196//"Nao"
						EndIf
					EndIf
					nRealEspaco := (VAL(AF9->AF9_NIVEL)-1)
					nEspaco := nRealEspaco*3
					If Len(AllTrim( AF9->AF9_DESCRI )) <= (34-(nRealEspaco))
						cDescri := SPACE(nEspaco)+Substr( AF9->AF9_DESCRI,1,34-(nRealEspaco) )
					Else
						cDescri := SPACE(nEspaco)+Substr( AF9->AF9_DESCRI,1,31-(nRealEspaco) )+"..."
					EndIf
					If AF9->(ColumnPos("AF9_HRATUI")) > 0
						If !Empty(AF9->AF9_DTATUI)
							dDtaIniEf :=aBaseDados[nPosBase,SIM_DTATUI]
							cHorIniEf :=AF9->AF9_HRATUI
							dDtaFimEf := Iif(!Empty(aBaseDados[nPosBase,SIM_DTATUF]),aBaseDados[nPosBase,SIM_DTATUF],dDataBase)
							cHorFimef := AFC->AFC_HRATUF
						Else
							dDtaIniEf := dDataBase
							cHorIniEf := "00:00"
							dDtaFimEf := dDataBase
							cHorFimef := "00:00"
						EndIf
					Else
						If !Empty(aBaseDados[nPosBase,SIM_DTATUI])
							dDtaIniEf := aBaseDados[nPosBase,SIM_DTATUI]
							cHorIniEf := "08:00"
							dDtaFimEf := Iif(!Empty(aBaseDados[nPosBase,SIM_DTATUF]),aBaseDados[nPosBase,SIM_DTATUF],dDataBase)
							cHorFimef := "18:00"
						Else
							dDtaIniEf := dDataBase
							cHorIniEf := "00:00"
							dDtaFimEf := dDataBase
							cHorFimef := "00:00"
						EndIf
					EndIf
					aAdd(aGant,{{AF9->AF9_TAREFA,cDescri,DTOC(aBaseDados[nPosBase,SIM_DTATUI]),;
					DTOC(aBaseDados[nPosBase,SIM_DTATUF]),Transform(AF9->AF9_HDURAC,;
					"@E 99999.99h"),cCritica,SPACE(nEspaco)+Alltrim(AF9->AF9_DESCRI),;
					nContlin},{{dDtaIniEf,cHorIniEf,dDtaFimEf,cHorFimef,"POC:"+;
					AllTrim(TransForm(PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,;
					AF9->AF9_TAREFA,PMS_MAX_DATE,AF9->AF9_QUANT),"@E 999.99%")),,;
					"",1,CLR_BLACK}},CLR_GRAY,})
				EndIf
			EndIf

		Else
			// EDT
			dbSelectArea("AFC")
			AFC->(dbGoto(aNodes[nNode,2]))
			PmsSimGnt(aGant,AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,lViewRec,nTpData,oBold,aConfig,aTaskCPM,nMaxNiveis,nNivelAtu,aTarefasDep,aBaseDados)
		EndIf
	Next
EndIf
RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ArraySeek³ Autor ³ Rodrigo Antonio 		  ³ Data ³ 15-05-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Procura a  tarefas  na base de dados em Array.				    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ArraySeek(aArray,cTabela,cTarefa)
Local nRet := 0
nRet := aScan(aArray,{|x|x[1]+x[2] == cTabela + cTarefa })
Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³getPosArry³ Autor ³ Rodrigo Antonio 		  ³ Data ³ 15-05-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Procura a  tarefas  na base de dados em Array se não encontrar³±±
±±³          ³adiciona a mesma.															 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function getPosArry(aBaseDados,cTabela,cTarefa, lVarMemo)
Local nPosBase := ArraySeek(aBaseDados,cTabela,cTarefa)
DEFAULT lVarMemo := .F.

If nPosBase == 0 .AND. !Empty(Alltrim(cTarefa))
	If cTabela == "AFC"
		aAdd(aBaseDados,{"AFC",	AFC->AFC_EDT	,AFC->AFC_START,	AFC->AFC_HORAI,	AFC->AFC_FINISH,	AFC->AFC_HORAF,	AFC->AFC_HDURAC,	AFC->AFC_HUTEIS,	AFC->AFC_NIVEL,	AFC->AFC_DTATUI,	AFC->AFC_DTATUF, AFC->(Recno())})
	ElseIf cTabela == "AF9"
		If lVarMemo .and. cTarefa == M->AF9_TAREFA
			aAdd(aBaseDados,{"AF9",	M->AF9_TAREFA	,M->AF9_START,	M->AF9_HORAI,	M->AF9_FINISH,	M->AF9_HORAF,	M->AF9_HDURAC,	M->AF9_HUTEIS,	M->AF9_NIVEL,	M->AF9_DTATUI,	M->AF9_DTATUF, AF9->(Recno())})
		Else
			aAdd(aBaseDados,{"AF9",	AF9->AF9_TAREFA	,AF9->AF9_START,	AF9->AF9_HORAI,	AF9->AF9_FINISH,	AF9->AF9_HORAF,	AF9->AF9_HDURAC,	AF9->AF9_HUTEIS,	AF9->AF9_NIVEL,	AF9->AF9_DTATUI,	AF9->AF9_DTATUF, AF9->(Recno())})
		Endif
	Endif
	nPosBase := ArraySeek(aBaseDados,cTabela,cTarefa)
Endif

Return nPosBase
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSCalcRe³ Autor ³ Rodrigo Antonio		  ³ Rev  ³ 22-05-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula a data e Hora Inicial da tarefa a partir da Data de 	 ³±±
±±³          ³referencia, considerando o percetual executado 			       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cProjeto : Projeto 														 ³±±
±±³          ³cRevisao : Revisao do Projeto											 ³±±
±±³          ³cTarefa  : Tarefa a ser Calculada										 ³±±
±±³          ³dData 	  : Data de Referencia										    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSCalcRe(cProjeto,cRevisao,cTarefa,dData)
Local aAreaAF9	:= AF9->(GetArea())
Local nPercTask :=0
Local aTmp :={}
Local aRet :={}
AF9->(DbSetOrder(1))
If AF9->(DbSeek(xFilial("AF9") + cProjeto + cRevisao + cTarefa))
	nPercTask := PMSPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dData) /100
	nHorasEfe := AF9->AF9_HUTEIS * nPercTask
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Determina quando terminaria uma tarefa comecando na data, com³
	//³a duracao do restante da tarefa que teria que ser feita.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTmp := PMSDTaskF(dData,"00:00",AF9->AF9_CALEND,AF9->AF9_HDURAC - nHorasEfe,AF9->AF9_PROJET,Nil)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Agora termina o inicio utilizando a data da "tarefa  acima".³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRet := PMSDTaskI(aTmp[3],aTmp[4],AF9->AF9_CALEND,AF9->AF9_HDURAC,AF9->AF9_PROJET,Nil)
Endif
RestArea(aAreaAF9)
Return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ QTDEFRETE³ Autor ³ Daniel Tadashi Batori ³ Rev. ³ 08.12.06       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula a qtde do item na NF original e a qtde apropriada        ³±±
±±³          ³ ao projeto apartir da NF de frete(conhecimeto)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nQtdeProj - qtde do item na NF original apropriada pelo projeto   ³±±
±±³          ³nQtdeTot - qtde total da NF original                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aNFfrete - array contendo informacoes da NF de frete(conhecimento)³±±
±±³          ³           [1]numero da NF                                        ³±±
±±³          ³           [2]serie da NF                                         ³±±
±±³          ³           [3]fornecedor da NF                                    ³±±
±±³          ³           [4]loja do fornecedor da NF                            ³±±
±±³          ³           [5]Projeto                                             ³±±
±±³          ³           [6]Revisao                                             ³±±
±±³          ³           [7]Tarefa                                              ³±±
±±³          ³           [8]codigo do produto da NF                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QTDEFRETE(aNFfrete, nQtdeProj, nQtdeTot)
Local aAreaSD1   := GetArea("SD1")
Local aAreaAFN   := GetArea("AFN")
Local cAliasQry1 := GetNextAlias()
Local cFiltro    := ""

nQtdeProj := 0
nQtdeTot  := 0

AFN->(dbSetOrder(2))

cFiltro := "% AND F8_NFDIFRE = '"+aNFfrete[1]+"' "+ ;
" AND F8_SEDIFRE = '"+aNFfrete[2]+"' "+ ;
" AND F8_TRANSP = '"+aNFfrete[3]+"' "+ ;
" AND F8_LOJTRAN = '"+aNFfrete[4]+"' "+ ;
" AND D1_COD = '"+aNFfrete[8]+"' %"

BeginSql Alias cAliasQry1
	SELECT D1_QUANT, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_ITEM
	FROM %table:SF8% SF8 INNER JOIN %table:SD1% SD1 ON D1_FILIAL = %xFilial:SD1%
	AND D1_DOC = F8_NFORIG
	AND D1_SERIE = F8_SERORIG
	AND D1_FORNECE = F8_FORNECE
	AND D1_LOJA = F8_LOJA
	AND SD1.%NotDel%
	WHERE F8_FILIAL = %xFilial:SF8% AND
	SF8.%NotDel%
	%Exp:cFiltro%
EndSql

(cAliasQry1)->(DbGotop())
While !(cAliasQry1)->(EOF())

	If AFN->(dbSeek(xFilial("AFN")+(cAliasQry1)->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM)+aNFfrete[5]+aNFfrete[6]+aNFfrete[7]))
		nQtdeProj := AFN->AFN_QUANT
	EndIf

	nQtdeTot  += (cAliasQry1)->D1_QUANT

	(cAliasQry1)->(dbSkip())
EndDo
(cAliasQry1)->(DbCloseArea())

RestArea(aAreaSD1)
RestArea(aAreaAFN)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PMSWindowPrompt³ Autor ³ Daniel Tadashi Batori ³ Rev. ³ 01/07/2007     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Abre uma janela para o usuario digitar o codico da EDT/Tarefa quando   ³±±
±±³          ³ a codificacao for manual(MV_PMSTCOD=1)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lReturn : .T. para codigo valido                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOrcPrj : 1-copia para o orcamento                                     ³±±
±±³          ³           2-copia para o projeto                                       ³±±
±±³          ³ cEstrut : "EDT"   -copia da EDT                                        ³±±
±±³          ³           "TAREFA"-copia da Terefa                                     ³±±
±±³          ³ aValues : array com os valores dos campos do ParamBox                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSWindowPrompt(nOrcPrj, cEstrut, aValues)
Local cReturn := ""
Local aInput  := {}
Local aParams := {}
Local cValid  := ""
Local cTitle  := ""
Local nTam    := 0


//copia para o orcamento
If nOrcPrj==1
	If cEstrut=="EDT" //copia da EDT
		cValid := "!ExistOrcEDT('"+aValues[1]+"', AllTrim(mv_par03))"
		cTitle := STR0188 //"Renomear codigo EDT"
		nTam   := TamSX3("AF5_EDT")[1]
	Else
		cValid := "!ExistOrcTrf('"+aValues[1]+"', AllTrim(mv_par03))"
		cTitle := STR0189 //"Renomear codigo Tarefa"
		nTam   := TamSX3("AF2_TAREFA")[1]
	End

	Aadd(aParams, {1, STR0204, aValues[1], "@!",,"", ".F.", 55 ,.F.})    //"Orçamento"
	Aadd(aParams, {1, STR0186, aValues[2], "@!",,"", ".F.", 55 ,.F.})    //"Cod. Anterior"
	Aadd(aParams, {1, STR0187, aValues[3], "@!" ,cValid,"","", 55 ,.T.}) //"Novo codigo"

	//copia para o projeto
Else
	If cEstrut=="EDT" //copia da EDT
		cValid := "ExistChav('AFC', '" + aValues[1] + aValues[4] + "'+ mv_par03,1 ) .And. FreeForUse('AFC','" + aValues[1] + aValues[4] + "' + mv_par03)"
		cTitle := STR0188 //"Renomear codigo EDT"
		nTam   := TamSX3("AFC_EDT")[1]
	Else
		cValid := "ExistChav('AF9', '" + aValues[1] + aValues[4] + "'+ mv_par03,1 ) .And. FreeForUse('AF9','" + aValues[1] + aValues[4] + "' + mv_par03)"
		cTitle := STR0189 //"Renomear codigo Tarefa"
		nTam   := TamSX3("AF9_TAREFA")[1]
	End

	Aadd(aParams, {1, STR0185, aValues[1], "@!",,"", ".F.", 55 ,.F.})    //"Projeto"
	Aadd(aParams, {1, STR0186, aValues[2], "@!",,"", ".F.", 55 ,.F.})    //"Cod. Anterior"
	Aadd(aParams, {1, STR0187, aValues[3], "@!" ,cValid,"","", 55 ,.T.}) //"Novo codigo"
EndIf

If ParamBox(aParams, cTitle, aInput,,,,,,,,.F.,)
	cReturn := aInput[3]
EndIf

Return cReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PMSGetlastERR  ³ Autor ³ Bruno Sobieski        ³ Rev. ³ 01/07/2007     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pega o ultimo codigo de erro de tarefa de um projeto                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cNumErr : Ultimo codigo de erro ou nulo se nao existir                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProjeto: Codigo do projeto                                            ³±±
±±³          ³ cRevisa : Codigo da revisao                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PMSGetlastERR(cProjeto,cRevisa)
Local cNumERR
Local cAliasQry
Local cQuery	:=	"SELECT MAX(AF9_TAREFA) NUMERR FROM "+RetSqlName('AF9')+ " AF9 "
cQuery	+=	" WHERE  AF9_FILIAL = '"+ xFilial("AF9")+"' "
cQuery	+=	"    AND AF9_PROJET = '"+cProjeto+"' "
cQuery	+=	"    AND AF9_REVISA = '"+cRevisa+"' "
cQuery	+=	"    AND AF9_TAREFA LIKE 'ERR%' "
cQuery	+=	"    AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery( cQuery )
cAliasQry	:=	GetNextAlias()
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )
If !Eof()
	cNumErr	:=	NUMERR
Endif
DbCloseArea()
cQuery	:=	"SELECT Max(AFC_EDT) NUMERR FROM "+RetSqlName('AFC')+ " AFC "
cQuery	+=	" WHERE  AFC_FILIAL = '"+ xFilial("AFC")+"' "
cQuery	+=	"    AND AFC_PROJET = '"+cProjeto+"' "
cQuery	+=	"    AND AFC_REVISA = '"+cRevisa+"' "
cQuery	+=	"    AND AFC_EDT LIKE 'ERR%' "
cQuery	+=	"    AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )
If !Eof() .AND. NUMERR > cNumErr
	cNumErr	:=	NUMERR
Endif
DbCloseArea()
Return cNumERR

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PMSPegaFilho   ³ Autor ³ Bruno Sobieski        ³ Rev. ³ 01/07/2007     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pega o maximo codigo de tarefa ou EDt para uma determinada EDT Pai     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cLasTask: Ultimo codigo de tarefa/EDT                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PMSPegaFilho(cProjeto,cRevisa,cEdtPai , cIni , cFim)
Local cLastTask
Local cQuery
Local cAliasQry
Local lOracle	 	:= "ORACLE"   $ Upper(TCGetDB())
Local lPostgres 	:= "POSTGRES" $ Upper(TCGetDB())
Local lDB2		 	:= "DB2"      $ Upper(TCGetDB())
cQuery	:=	"SELECT MAX(AF9_TAREFA) MAXTASK FROM "+RetSqlName('AF9')+ " AF9 "
cQuery	+=	" WHERE  AF9_FILIAL = '"+ xFilial("AF9")+"' "
cQuery	+=	"    AND AF9_PROJET = '"+ cProjeto+"' "
cQuery	+=	"    AND AF9_REVISA = '"+ cRevisa +"' "
cQuery	+=	"    AND AF9_EDTPAI = '"+cEDTPAI+"' "
cQuery	+=	"    AND AF9_TAREFA NOT LIKE 'ER%' "
cQuery	+=	"    AND AF9_TAREFA BETWEEN  '"+cIni+"' AND '"+cFim+"'
//Depois do fim da mascara deve estar vazio
If Len(cFim) < TamSx3("AFC_EDT")[1]
	If lOracle .Or. lDB2
		cQuery	+=	"    AND SUBSTR(AF9_TAREFA,"+Str(Len(cIni)+1)+",1) = ' ' "
	Elseif lPostgres
		cQuery	+=	"    AND SUBSTR(AF9_TAREFA,"+Str(Len(cIni)+1)+",1) = ' ' "
	Else
		cQuery	+=	"    AND SUBSTRING(AF9_TAREFA,"+Str(Len(cIni)+1)+",1)   = ' ' "
	Endif
Endif
cQuery	+=	"    AND AF9_TAREFA BETWEEN  '"+cIni+"' AND '"+cFim+"'
cQuery	+=	"    AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery( cQuery )
cAliasQry	:=	GetNextAlias()
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )
If !Eof()
	cLastTask	:=	MAXTASK
Endif
DbCloseArea()
cQuery	:=	"SELECT Max(AFC_EDT) MAXTASK FROM "+RetSqlName('AFC')+ " AFC "
cQuery	+=	"   WHERE  AFC_FILIAL = '"+ xFilial("AFC")+"' "
cQuery	+=	"    AND AFC_PROJET = '"+cProjeto+"' "
cQuery	+=	"    AND AFC_REVISA = '"+cRevisa+"' "
cQuery	+=	"    AND AFC_EDTPAI = '"+cEDTPAI+"' "
cQuery	+=	"    AND AFC_EDT NOT LIKE 'ER%' "
cQuery	+=	"    AND AFC_EDT BETWEEN  '"+cIni+"' AND '"+cFim+"'
//Depois do fim da mascara deve estar vazio
If Len(cFim) < TamSx3("AFC_EDT")[1]
	If lOracle .Or. lDB2
		cQuery	+=	"    AND Substr(AFC_EDT,"+Str(Len(cIni)+1)+",1) = ' ' "
	Elseif lPostgres
		cQuery	+=	"	 AND SUBSTR(AFC_EDT,"+Str(Len(cIni)+1)+",1) = ' ' "
	Else
		cQuery	+=	"    AND Substring(AFC_EDT,"+Str(Len(cIni)+1)+",1) = ' ' "
	Endif
Endif
cQuery	+=	"    AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )
If !Eof() .AND. MAXTASK > cLastTask
	cLastTask	:=	MAXTASK
Endif
DbCloseArea()

Return cLastTask

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSXCalTarºAutor  ³WILKER VALLADARES   º Data ³  04/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz os calculos de realizados via topconnect               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 - codigo do projeto                                  º±±
±±º          ³ ExpC2 - codigo da revisao                                  º±±
±±º          ³ ExpC3 - codigo da EDT                                      º±±
±±º          ³ ExpD1 - data de referencia                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºOBS.      ³ MUITO CUIDADO AO MEXER NESTA ROTINA!!!!                    º±±
±±º          ³ Pois podem existir tarefas E/OU EDTs sem horas de duracao  º±±
±±º          ³ (AF9_HDURAC==0 ou AFC_HDURAC==0) a EDT PAI vai ser         º±±
±±º          ³ considerada somente 100% executada, se todas as tarefas    º±±
±±º          ³ estiverem 100%. Caso contrario só considera o %executado   º±±
±±º          ³ das EDTs e tarefas com horas.                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSXCalTar(cProjeto,cRevisa,cEDT, dDataRef,lPmsProject)
Local cQuery   := ""
Local nHUteis	:= 0
Local dMinIni1	:= CTOD("  /  /    ")
Local dMaxFim1	:= CTOD("  /  /    ")
Local dMinIni2	:= CTOD("  /  /    ")
Local dMaxFim2	:= CTOD("  /  /    ")
Local cHrATuI1	:= ""
Local cHrATuF1	:= ""
Local cHrATuI2	:= ""
Local cHrATuF2	:= ""
Local lMinIni1	:= .F.
Local lMaxFim1	:= .T.
Local aDataMin := {}
Local aDataMax := {}
Local lConclui := .F.
Local nRecno   := 0
Local cOper 	:= Iif("MSSQL" $ Upper(TcGetDb()) .Or. "SYBASE" $ Upper(TcGetDb()), "+", "||") // trata o operador || para não ocorrer erro na ChangeQuery()
Local nQuant   := 0
Local nAux     := 0
Local nQtdEtapa  := 0
Local aQtdTsk := {}
Local lContinua := .T.
Local cFilAFC 	:= xFilial("AFC")
Local cFilAF9 	:= xFilial("AF9")
Local cFilAFQ 	:= xFilial("AFQ")
Local cFilAFF 	:= xFilial("AFF")
Local cSQLAFC	:= RetSqlNamE("AFC")
Local cSQLAF9	:= RetSqlNamE("AF9")
Local cSQLAFQ	:= RetSqlNamE("AFQ")
Local cSQLAFF	:= RetSqlNamE("AFF")

Default lAF9_HRATUI := AF9->(ColumnPos("AF9_HRATUI")) > 0
Default lAF9_HRATUF := AF9->(ColumnPos("AF9_HRATUF")) > 0
Default lAFC_HRATUI := AFC->(ColumnPos("AFC_HRATUI")) > 0
Default lAFC_HRATUF := AFC->(ColumnPos("AFC_HRATUF")) > 0
Default lPmsProject	:= .F.


If Empty(dDataRef) .OR. Empty(cEDT)
	lContinua := .F.
EndIf

If lContinua
	If !lPmsProject
		CursorWait()
	Endif

	dbSelectArea("AFC")
	dbSetOrder(1)
	If MsSeek(cFilAFC+cProjeto+cRevisa+cEDT)
		nHUteis	:= AFC->AFC_HUTEIS

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ :::::: 1ª parte - Verificacao das confirmacoes entre AFF / AF9 :::::: ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := " SELECT AFF_QUANT AS QUANTAFF, AF9_HUTEIS, AF9_QUANT ,AF9_DTATUF "
		cQuery += " FROM " + cSQLAFF+ " AFFA, " + cSQLAF9+ " AF9 "
		cQuery += "  WHERE AFFA.AFF_FILIAL = '" + cFilAFF + "' "
		cQuery += "  AND AFFA.AFF_PROJET = '" + cProjeto + "' "
		cQuery += "  AND AFFA.AFF_REVISA = '" + cRevisa  + "' "
		cQuery += "  AND AF9_FILIAL = '" + cFilAF9 + "' "
		cQuery += "  AND AF9_PROJET = AFFA.AFF_PROJET "
		cQuery += "  AND AF9_REVISA = AFFA.AFF_REVISA "
		cQuery += "  AND AF9_TAREFA = AFFA.AFF_TAREFA "
		cQuery += "  AND AFFA.AFF_TAREFA IN ( "
		cQuery += " 	 							SELECT AF9_TAREFA FROM " + cSQLAF9
		cQuery += " 								WHERE AF9_FILIAL = '" + cFilAF9 + "'"
		cQuery += "  								AND AF9_PROJET = '" + cProjeto + "'"
		cQuery += "  								AND AF9_REVISA = '" + cRevisa + "'"
		cQuery += "  								AND AF9_EDTPAI = '" + cEDT + "'"
		cQuery += "  								AND D_E_L_E_T_ = ' '  ) "
		cQuery += "  AND AFFA.AFF_DATA = ( "
		cQuery += "								   SELECT MAX(AFF_DATA) FROM " + cSQLAFF + " AFFB "
		cQuery += " 			 				   WHERE	AFFB.AFF_FILIAL = '" + cFilAFF + "' "
		cQuery += " 			 					AND AFFB.AFF_PROJET = '" + cProjeto + "' "
		cQuery += " 			 					AND AFFB.AFF_REVISA = '" + cRevisa +  "' "
		cQuery += " 			 					AND AFFB.AFF_TAREFA = AFFA.AFF_TAREFA "
		cQuery += " 			 					AND AFFB.AFF_DATA <= '" + dtos(dDataRef) + "'" // retirado a data, pois o calculo do maximo nao pode ter este criterio
		cQuery += " 			 					AND AFFB.D_E_L_E_T_ = ' '  )"
		cQuery += "  AND AFFA.D_E_L_E_T_ = ' ' "
		cQuery += "  AND AF9.D_E_L_E_T_ = ' ' "

		// zera o acumulador de execucao das TAREFAS
		nAux := 0
		nQtdEtapa := 0 // Quantidade de tarefas e/ou EDT que sao etapas finalizadas,
						// 	Etapas sao tarefas com duracao igual a zero(0)

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYAFF",.F.,.T.)
		If !QRYAFF->(EOF())  //nAux > 0
			While !QRYAFF->(EOF()) // .And. !(nHUteis==0)

				nPercRef := 0

				If nHUteis == 0
					If QRYAFF->AF9_HUTEIS == 0
						If Empty(QRYAFF->AF9_DTATUF)
							nPercRef := 0

						Else
							nPercRef := 1
							nQtdEtapa++
						EndIf

					EndIf
				Else
					nPercRef := QRYAFF->AF9_HUTEIS / nHUteis
				EndIf

				nAux     += (QRYAFF->QUANTAFF / QRYAFF->AF9_QUANT) * nPercRef
				QRYAFF->(DbSkip())
			EndDo
			nQuant += nAux

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica qual é a quantidade das tarefas³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lAF9_HRATUI
				cQuery := "SELECT MIN(AF9_DTATUI"+cOper+"AF9_HRATUI) AS DTMIN, MAX(AF9_DTATUF"+cOper+"AF9_HRATUF) AS DTMAX "
			Else
				cQuery := "SELECT MIN(AF9_DTATUI) AS DTMIN, MAX(AF9_DTATUF) AS DTMAX "
			Endif
			cQuery += "  FROM " + cSQLAF9
			cQuery += "  WHERE AF9_FILIAL = '" + cFilAF9 + "' "
			cQuery += " AND AF9_PROJET = '" + cProjeto + "' "
			cQuery += " AND AF9_REVISA = '" + cRevisa + "' "
			cQuery += " AND AF9_EDTPAI = '" + cEDT + "' "
			cQuery += " AND D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYAF9",.F.,.T.)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcula as datas iniciais e finais³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dMinIni1 := if( !Empty(QRYAF9->DTMIN), stod(substr(QRYAF9->DTMIN,1,8)), dMinIni1)
			If lAF9_HRATUI
				cHrAtuI1 := if( !Empty(QRYAF9->DTMIN), substr(QRYAF9->DTMIN,9,5), cHrAtuI1)
			EndIf

			dMaxFim1 := if( !Empty(QRYAF9->DTMAX), stod(substr(QRYAF9->DTMAX,1,8)), dMaxFim1)
			If lAF9_HRATUF
				cHrAtuF1 := if( !Empty(QRYAF9->DTMAX), substr(QRYAF9->DTMAX,9,5), cHrAtuF1)
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verificar a consistencia do minimo da data, caso esteja em branco, submeter a nova pesquisa, pois³
			//³pode ter sido de uma tarefa nao iniciada                                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(dMinIni1)
				AADD( aDataMin, { dMinIni1 , cHrAtuI1 } ) // guarda para analise entre os 2 processos
				AADD( aDataMax, { dMaxFim1 , cHrAtuF1 } )
			Else
				If lAF9_HRATUI
					cQuery := " SELECT MIN(AF9_DTATUI"+cOper+"AF9_HRATUI) AS DTMIN "
				Else
					cQuery := " SELECT MIN(AF9_DTATUI) AS DTMIN "
				Endif
				cQuery += "  FROM " + cSQLAF9
				cQuery += "  WHERE AF9_FILIAL = '" + cFilAF9 + "' "
				cQuery += " AND AF9_PROJET = '" + cProjeto + "' "
				cQuery += " AND AF9_REVISA = '" + cRevisa + "' "
				cQuery += " AND AF9_EDTPAI = '" + cEDT + "' "
				cQuery += " AND AF9_DTATUI <> ' ' " // nao trazer datas em brancos para fazer o calculo do minimo corretamente
				cQuery += " AND D_E_L_E_T_ = ' ' "

				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYDTAF9",.F.,.T.)

				If !Empty(QRYDTAF9->DTMIN)
					dMinIni1 := stod(substr(QRYDTAF9->DTMIN,1,8))
					cHrAtuI1 := substr(QRYDTAF9->DTMIN,9,5)
					AADD( aDataMin, { dMinIni1 , cHrAtuI1 } )
					AADD( aDataMax, { dMaxFim1 , cHrAtuF1 } )
				EndIf

				QRYDTAF9->( dbclosearea() )
				dbselectarea("AF9")
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Final da verificacao de datas - excessao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ :::::: 2ª parte - Verificacao das confirmacoes entre AFC / AFQ :::::: ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := " SELECT AFQ_QUANT AS QUANTAFQ, AFC_HUTEIS, AFC_QUANT ,AFC_DTATUF "
		cQuery += " FROM " + cSQLAFQ + " AFQA, " + cSQLAFC + " AFC "
		cQuery += " WHERE AFQA.AFQ_FILIAL = '" + cFilAFQ + "'"
		cQuery += " AND AFQA.AFQ_PROJET = '" + cProjeto + "'"
		cQuery += " AND AFQA.AFQ_REVISA = '" + cRevisa + "'"
		cQuery += " AND AFC_FILIAL = '" + cFilAFC + "' "
		cQuery += " AND AFC_PROJET = AFQA.AFQ_PROJET "
		cQuery += " AND AFC_REVISA = AFQA.AFQ_REVISA "
		cQuery += " AND AFC_EDT    = AFQA.AFQ_EDT "
		cQuery += " AND AFQA.AFQ_EDT IN ( "
		cQuery += "								SELECT AFC_EDT FROM " + cSQLAFC
		cQuery += " 							WHERE AFC_FILIAL = '" + cFilAFC + "'"
		cQuery += " 							AND AFC_PROJET = '" + cProjeto + "'"
		cQuery += " 							AND AFC_REVISA = '" + cRevisa + "'"
		cQuery += " 							AND AFC_EDTPAI = '" + cEDT + "'"
		cQuery += " 							AND D_E_L_E_T_ = ' '  ) "
		cQuery += " AND AFQA.AFQ_DATA = (  "
		cQuery += "								SELECT MAX(AFQ_DATA) FROM " + cSQLAFQ + " AFQB "
		cQuery += "			 					WHERE	AFQB.AFQ_FILIAL = '" + cFilAFQ + "'"
		cQuery += "			 					AND AFQB.AFQ_PROJET = '" + cProjeto + "'"
		cQuery += "			 					AND AFQB.AFQ_REVISA = '" + cRevisa + "'"
		cQuery += "			 					AND AFQB.AFQ_EDT = AFQA.AFQ_EDT "
		cQuery += "			 					AND AFQB.AFQ_DATA <= '" + dtos(dDataRef) + "' "// retirado a data, pois o calculo do maximo nao pode ter este criterio
		cQuery += "			 					AND AFQB.D_E_L_E_T_ = ' '  ) "
		cQuery += " AND AFQA.D_E_L_E_T_ = ' ' "
		cQuery += " AND AFC.D_E_L_E_T_ = ' ' "

		If Select("QRYAFQ") > 0
			QRYAFC->( dbclosearea() )
			dbselectarea("AFQ")
		Endif

		// zera o acumulador de execucao das EDTS
		nAux := 0

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYAFQ",.F.,.T.)
		// se existir registros, deve procurar a menor data de inicio de execucao e a maior data de termino de execucao
		If !QRYAFQ->(Eof())
			While !QRYAFQ->(EOF())

				nPercRef := 0

				If nHUteis == 0
					If QRYAFQ->AFC_HUTEIS == 0
						If Empty(QRYAFQ->AFC_DTATUF)
							nPercRef := 0
						Else
							nPercRef := 1
							nQtdEtapa++
						EndIf
					EndIf

				Else
					nPercRef := QRYAFQ->AFC_HUTEIS / nHUteis
				EndIf

				nAux += (QRYAFQ->QUANTAFQ / QRYAFQ->AFC_QUANT) * nPercRef
				QRYAFQ->(DbSkip())
			EndDo

			nQuant += nAux

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica qual é a menor data de inicio de execuao e a maior data de fim de execucao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lAFC_HRATUI
				cQuery := " SELECT MIN(AFC_DTATUI"+cOper+"AFC_HRATUI) AS DTMIN, MAX(AFC_DTATUF"+cOper+"AFC_HRATUF) AS DTMAX, SUM(AFC_QUANT) AS QUANTAFC, SUM(AFC_HUTEIS) HUTEIS "
			Else
				cQuery := " SELECT MIN(AFC_DTATUI) AS DTMIN, MAX(AFC_DTATUF) AS DTMAX, SUM(AFC_QUANT) AS QUANTAFC, SUM(AFC_HUTEIS) HUTEIS "
			Endif
			cQuery += "  FROM " + cSQLAFC
			cQuery += "  WHERE AFC_FILIAL = '" + cFilAFC + "' "
			cQuery += " AND AFC_PROJET = '" + cProjeto + "' "
			cQuery += " AND AFC_REVISA = '" + cRevisa + "' "
			cQuery += " AND AFC_EDTPAI = '" + cEDT + "' "
			cQuery += " AND D_E_L_E_T_ = ' ' "

			If Select("QRYAFC") > 0
				QRYAFC->( dbclosearea() )
				dbselectarea("AFC")
			Endif

			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYAFC",.F.,.T.)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcula as datas iniciais e finais³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dMinIni2 := if( !Empty(QRYAFC->DTMIN), stod(substr(QRYAFC->DTMIN,1,8)), dMinIni2)
			If lAFC_HRATUI
				cHrAtuI2 := if( !Empty(QRYAFC->DTMIN), substr(QRYAFC->DTMIN,9,5), cHrAtuI2)
			endif

			dMaxFim2 := if( !Empty(QRYAFC->DTMAX), stod(substr(QRYAFC->DTMAX,1,8)), dMaxFim2)
			If lAFC_HRATUF
				cHrAtuF2 := if( !Empty(QRYAFC->DTMAX), substr(QRYAFC->DTMAX,9,5), cHrAtuF2)
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verificar a consistencia do minimo da data, caso esteja em branco, submeter a nova pesquisa, pois³
			//³pode ter sido de uma tarefa nao iniciada                                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(dMinIni2)
				AADD( aDataMin, { dMinIni2 , cHrAtuI2 } )
				AADD( aDataMax, { dMaxFim2 , cHrAtuF2 } )
			Else
				If lAFC_HRATUI
					cQuery := " SELECT MIN(AFC_DTATUI"+cOper+"AFC_HRATUI) AS DTMIN "
				Else
					cQuery := " SELECT MIN(AFC_DTATUI) AS DTMIN "
				Endif
				cQuery += "  FROM " + cSQLAFC
				cQuery += "  WHERE AFC_FILIAL = '" + cFilAFC + "' "
				cQuery += "  AND AFC_PROJET = '" + cProjeto + "' "
				cQuery += "  AND AFC_REVISA = '" + cRevisa + "' "
				cQuery += "  AND AFC_EDTPAI = '" + cEDT + "' "
				cQuery += "  AND AFC_DTATUI <> ' ' "  // nova condicao para trazer a data, a query nao tem vinculo com o calculo de percentual
				cQuery += "  AND D_E_L_E_T_ = ' ' "

				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYDTAFC",.F.,.T.)

				If !Empty(QRYDTAFC->DTMIN)
					dMinIni2 := stod(substr(QRYDTAFC->DTMIN,1,8))
					cHrAtuI2 := substr(QRYDTAFC->DTMIN,9,5)
					AADD( aDataMin, { dMinIni2 , cHrAtuI2 } )
					AADD( aDataMax, { dMaxFim2 , cHrAtuF2 } )
				Endif

				QRYDTAFC->( dbclosearea() )
				dbselectarea("AFC")
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Final da verificacao de datas - excessao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calculo do Percentual apos execucao dos 2 processos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		// conta quantas tarefas e edt estão com horas uteis
		// e as que estao sem horas uteis
		aQtdTsk := TaskCount(cProjeto ,cRevisa ,cEDT)

		If !Empty(aQtdTsk) .AND. aQtdTsk[1] == aQtdTsk[2]
			nPercAtu := iIf( aQtdTsk[2] == nQtdEtapa, 1, 0 )
		Else
			nPercAtu  := nQuant
		EndIf

		lConclui := nPercAtu == 1

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verificacao entre Data Minima e Data Maxima para gravacao na EDT³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aDataMin) == 0
			lMinIni1 := .F.
			lMaxFim1 := .F.
		Else
			aDataMin := ASort(aDataMin,,, { |x, y| dtos(x[1])+x[2] < dtos(y[1])+y[2] } )
			aDataMax := ASort(aDataMax,,, { |x, y| dtos(x[1])+x[2] > dtos(y[1])+y[2] } )

			dMinIni1 := aDataMin[1,1]
			cHrAtuI1 := aDataMin[1,2]
			dMaxFim1 := aDataMax[1,1]
			cHrAtuF1 := aDataMax[1,2]

			lMinIni1 := !Empty(dMinIni1)
			lMaxFim1 := !Empty(dMaxFim1)
		Endif

		//Verificar se existe alguma tarefa ou EDT com HORAS UTEIS=ZERO e tira 1% se a tarefa não estiver concluida
		If nPercAtu == 1
			cQuery := "	SELECT 1 FROM " + cSQLAFC
			cQuery += "		WHERE AFC_FILIAL = '" + cFilAFC + "'"
			cQuery += "		AND AFC_PROJET = '" + cProjeto + "'"
			cQuery += "		AND AFC_REVISA = '" + cRevisa + "'"
			cQuery += "		AND AFC_EDTPAI = '" + cEDT + "'"
			cQuery += "		AND AFC_HUTEIS = 0 "
			cQuery += "		AND AFC_DTATUF = ' ' "
			cQuery += "		AND D_E_L_E_T_ = ' '  "
			If Select("QRYAFC2") > 0
				QRYAFC2->( dbclosearea() )
				dbselectarea("AFC")
			Endif

			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYAFC2",.F.,.T.)
			DbSelectArea("QRYAFC2")
			If !EOF()
				nPercAtu := 0.99
				lConclui := .F.
			Endif
			dbclosearea()
			If nPercAtu == 1
				cQuery := "	SELECT 1 FROM " + cSQLAF9
				cQuery += "		WHERE AF9_FILIAL = '" + cFilAF9 + "'"
				cQuery += "		AND AF9_PROJET = '" + cProjeto + "'"
				cQuery += "		AND AF9_REVISA = '" + cRevisa + "'"
				cQuery += "		AND AF9_EDTPAI = '" + cEDT + "'"
				cQuery += "		AND AF9_HUTEIS = 0 "
				cQuery += "		AND AF9_DTATUF = ' ' "
				cQuery += "		AND D_E_L_E_T_ = ' '  "
				If Select("QRYAF92") > 0
					QRYAF92->( dbclosearea() )
					dbselectarea("AF9")
				Endif

				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYAF92",.F.,.T.)
				DbSelectArea("QRYAF92")
				If !EOF() .and. (aQtdTsk[1] == aQtdTsk[2])
					nPercAtu := 0
					lConclui := .F.
				elseif !EOF()
					nPercAtu := 0.99
					lConclui := .F.
				Endif
				dbclosearea()
			Endif
		Endif
		AFC->(dbSetOrder(1))
		AFC->(MsSeek(cFilAFC+cProjeto+cRevisa+cEDT))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca o apontamento da EDT na data que foi realizado o apontamento da tarefa ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nRecno := PMSXMaxAFQ( cProjeto, cRevisa, cEDT, dDataRef, cSqlAFQ , cFilAFQ)
		AFQ->(dbSetOrder(1))
		If nRecno > 0
			AFQ->(MsGoto(nRecno))
		Endif
		If nRecno == 0	.Or. (dDataRef <> AFQ->AFQ_DATA .And. !AFQ->(MsSeek(cFilAFQ+cProjeto+cRevisa+cEdt+DTOS(dDataRef))))
			RecLock("AFQ",.T.)
			AFQ->AFQ_FILIAL := cFilAFQ
			AFQ->AFQ_PROJET := cProjeto
			AFQ->AFQ_REVISA := cRevisa
			AFQ->AFQ_EDT    := cEDT
			AFQ->AFQ_DATA   := dDataRef
			AFQ->AFQ_QUANT  := AFC->AFC_QUANT*nPercAtu
			AFQ->( MsUnlock() )
		Else
			RecLock("AFQ",.F.)
			AFQ->AFQ_QUANT	:= AFC->AFC_QUANT*nPercAtu
			AFQ->( MsUnlock() )
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se atualiza data de realizado da EDT ou da Tarefa³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PmsAtuDT(AFC->AFC_PROJET,AFC->AFC_EDT,If(lMinIni1,dMinIni1,SToD("")),If(lMaxFim1 .and. lConclui,dMaxFim1,SToD("")),"AFC",If(lMinIni1,cHrAtuI1,"  :  "),If(lMaxFim1 .and. lConclui,cHrAtuF1,"  :  "))

		If !lPmsProject
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Solicita ao top que grave as informações no disco³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbCommitALL()
		Endif

		If AFC->AFC_NIVEL == "001"
			dbSelectArea("AF8")
			dbSetOrder(1)
			MsSeek(xFilial("AF8")+cProjeto)
			RecLock("AF8",.F.)
			AF8->AF8_DTATUI	:= If(lMinIni1,dMinIni1,CTOD("  /  /  "))
			AF8->AF8_DTATUF	:= If(lMaxFim1 .AND. lConclui,dMaxFim1,CTOD("  /  /  "))
			MsUnlock()
		EndIf

	Endif

	If Select("QRYAFC") > 0
		QRYAFC->( dbclosearea() )
		dbselectarea("AFC")
	endif
	if Select("QRYAFQ") > 0
		QRYAFQ->( dbclosearea() )
		dbselectarea("AFQ")
	endif
	if Select("QRYAFF") > 0
		QRYAFF->( dbclosearea() )
		dbselectarea("AFC")
	endif
	if Select("QRYAF9") > 0
		QRYAF9->( dbclosearea() )
		dbselectarea("AF9")
	endif

	If !lPmsProject
		CursorArrow()
	Endif

EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSXMaxAFQºAutor  ³WILKER VALLADARES   º Data ³  11/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica qual eh a data maxima da EDT para atualizar o     º±±
±±º          ³ percentual de realizado                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 - codigo do projeto                                  º±±
±±º          ³ ExpC2 - codigo da revisao                                  º±±
±±º          ³ ExpC3 - codigo da EDT                                      º±±
±±º          ³ dDataRef - data do apontamento na tarefa                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PMSXMaxAFQ( cProjeto, cRevisao, cEDT, dDataRef, cSqlAFQ ,cFilAFQ)
Local cQuery := ""
Local nRec   := 0

Default cSqlAFQ := RetSqlName("AFQ")
Default cFilAFQ := xFilial("AFQ")

cQuery := " SELECT R_E_C_N_O_ AS REG FROM "  + cSqlAFQ
cQuery += "  WHERE AFQ_FILIAL = '" + cFilAFQ + "'"
cQuery += "  AND AFQ_PROJET = '" + cProjeto + "'"
cQuery += "  AND AFQ_REVISA = '" + cRevisao + "'"
cQuery += "  AND AFQ_EDT = '" + cEDT + "'"
cQuery += "  AND AFQ_DATA = '" + dtos(dDataRef) + "'"
cQuery += "  AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYMAX",.F.,.T.)

nRec := if( Empty(QRYMAX->REG), 0, QRYMAX->REG )

QRYMAX->( dbCloseArea() )
dbselectarea("AFQ")

Return nRec


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsxVerCalºAutor  ³LEANDRO LIMA   º Data ³  24/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Caso importar uma EDT/Tarefa de um porjeto de outra   º±±
±±º          ³ filial verifica se existe o calendario na filial      º±±
±±º          ³ atual caso nao exista vai incluir.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 - Calendario da filial Copia				     º±±
±±º          ³ ExpC2 - Filial Copia                                  º±±
±±º          ³ ExpC3 - Filial Corrente / Filial Origem               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSXFUNA                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PmsxVerCal(cCalend,cFilCopy,cFilCor)

Local aCamposSH7 := {}						// Conteudo dos campos da Tabela SH7
Local aStructSH7 := SH7->(DbStruct())      // Estrutura da tabela SH7
Local nX		 := 0	                    // Contador para o FOR
Local aArea		 := GetArea()              // Guarda a area do Alias Corrente

DEFAULT cCalend	 := ""
DEFAULT cFilCopy := xFilial("SH7")
DEFAULT cFilCor  := cFilAnt

DbSelectArea("SH7")
DbSetOrder(1)      			// FILIAL + CODIGO
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso nao encontre o calendario na filial corrente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !DbSeek( cFilCor + cCalend )
	If DbSeek( cFilCopy + cCalend )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrego os campos do calendario cadastrado na outra filial³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX :=1	to Len(aStructSH7)
			Aadd(aCamposSH7 , &(aStructSH7[nX,1]) )
		Next nX
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inclui um novo registro no SH7 com a filial Corrente ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("SH7",.T.)
		For nX :=1 to Len(aStructSH7)
			If "_FILIAL" $ aStructSH7[nX,1]
				aCamposSH7[nX] := cFilCor
			EndIf
			REPLACE &(aStructSH7[nX,1]) WITH aCamposSH7[nX]
		Next nX
		MsUnlock()
	EndIf
EndIf

RestArea( aArea )

Return (Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TaskCount ºAutor  ³Reynaldo Miyashita  º Data ³  17/07/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ retorna um array onde o 1o elemento contem a quantidade de º±±
±±º          ³ tarefas e edts de uma determinada EDT Pai e o 2o elemento  º±±
±±º          ³ contem quantidade de tarefas e edts sem horas.			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TaskCount(cProjeto ,cRevisa ,cEDT)
Local cQuery := ""
Local aArea := GetArea()
Local aQtd := {0,0}

cQuery := "SELECT 'AF9' as Alias ,'T' as Ocorrencia ,COUNT(AF9_TAREFA) AS QTD"
cQuery += "  FROM " + RetSqlName("AF9")
cQuery += "  WHERE AF9_FILIAL = '" + xFilial("AF9") + "' "
cQuery += " AND AF9_PROJET = '" + cProjeto + "' "
cQuery += " AND AF9_REVISA = '" + cRevisa + "' "
cQuery += " AND AF9_EDTPAI = '" + cEDT + "' "
cQuery += " AND D_E_L_E_T_ = ' ' "
cQuery += " UNION "
cQuery += "SELECT 'AF9' as Alias ,'S' as Ocorrencia ,COUNT(AF9_TAREFA) AS QTD"
cQuery += "  FROM " + RetSqlName( "AF9")
cQuery += "  WHERE AF9_FILIAL = '" + xFilial("AF9") + "' "
cQuery += " AND AF9_PROJET = '" + cProjeto + "' "
cQuery += " AND AF9_REVISA = '" + cRevisa + "' "
cQuery += " AND AF9_EDTPAI = '" + cEDT + "' "
cQuery += " AND AF9_HDURAC = 0 "
cQuery += " AND D_E_L_E_T_ = ' ' "
cQuery += " UNION "
cQuery += "SELECT 'AFC' as Alias ,'T' as Ocorrencia ,COUNT(AFC_EDT) AS QTD"
cQuery += "  FROM " + RetSqlName("AFC")
cQuery += "  WHERE AFC_FILIAL = '" + xFilial("AFC") + "' "
cQuery += " AND AFC_PROJET = '" + cProjeto + "' "
cQuery += " AND AFC_REVISA = '" + cRevisa + "' "
cQuery += " AND AFC_EDTPAI = '" + cEDT + "' "
cQuery += " AND D_E_L_E_T_ = ' ' "
cQuery += " UNION "
cQuery += "SELECT 'AFC' as Alias ,'S' as Ocorrencia ,COUNT(AFC_EDT) AS QTD"
cQuery += "  FROM " + RetSqlName("AFC")
cQuery += "  WHERE AFC_FILIAL = '" + xFilial("AFC") + "' "
cQuery += " AND AFC_PROJET = '" + cProjeto + "' "
cQuery += " AND AFC_REVISA = '" + cRevisa + "' "
cQuery += " AND AFC_EDTPAI = '" + cEDT + "' "
cQuery += " AND AFC_HDURAC = 0 "
cQuery += " AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QryTmp",.F.,.T.)
While !Eof()

	If QryTmp->Ocorrencia == "S" // DURACAO COM 0 HORAS
		aQtd[2] += QryTmp->Qtd
	Else
		aQtd[1] += QryTmp->Qtd
	EndIf

	dbSkip()
EndDo
QryTmp->(dbclosearea())

RestArea(aArea)

Return aQtd

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsNxtAF9 ºAutor  ³Marcos S. Lobo      º Data ³  08/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Encapsulamento da PMSNumAF9 com tratamento de erro/excessao.º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsNxtAF9(lShowDlg, cTxtErro, cProjeto,cRevisa,cNivelTrf,cEDTPai,cTrfAtual ,lLiberaCod)
Local aAreaOri	:= GetArea()
Local aAreaAFC	:= {}
Local cTarefa	:= ""

DEFAULT lShowDlg := !IsBlind()
DEFAULT cTxtErro := ""
DEFAULT lLiberaCod  := .F.
DEFAULT cTrfAtual   := ""

If cProjeto == NIL .OR. (ValType(cProjeto) =="C" .AND. Empty(cProjeto))
	cTxtErro += STR0221+CRLF //"Cod. Projeto vazio."
EndIf

If cEDTPai == NIL .OR. (ValType(cEDTPai) =="C" .AND. Empty(cEDTPai))
	cTxtErro += STR0220 +CRLF // "Cod. EDT Pai vazia / inválida"
EndIf

If Empty(cTxtErro)
	If cRevisa == NIL .OR. (ValType(cRevisa) == "C" .AND. Empty(cRevisa))
		cRevisa := PMSAF8VER(cProjeto)
	EndIf

	//
	// deve obter o nivel da edt pai para ser utilizado na geracao do codigo da tarefa
	//////////////
	If cNivelTrf==NIL .OR. (ValType(cNivelTrf) == "C" .AND. Empty(cNivelTrf))
		cProjeto := padR(cProjeto ,len(AF9->AF9_PROJET))
		cRevisa  := padR(cRevisa ,len(AF9->AF9_REVISA))
		cEDTPai  := padR(cEDTPAI ,len(AF9->AF9_EDTPAI))

		dbSelectArea("AFC")
		aAreaAFC := GetArea()
		dbsetOrder(1)
		If MsSeek(xFilial("AFC")+cProjeto+cRevisa+cEDTPai,.F.)
			cNivelTrf := AFC->AFC_NIVEL
		Else
			cTxtErro += STR0216 +CRLF //"EDT não localizada, veja estrutura do projeto / EDT informada."
		EndIf
		RestArea(aAreaAFC)
	EndIf
EndIf

If Empty(cTxtErro)
	cTarefa := PmsNumAF9(cProjeto,cRevisa,cNivelTrf,cEDTPai,cTrfAtual ,lLiberaCod)
	If Empty(cTarefa)
		cTxtErro += STR0217+CRLF //"Não foi possível gerar codigo de tarefa."
	EndIf
EndIf

If !Empty(cTxtErro)
	cTxtErro := STR0218 + CRLF+ ; // "Numeração de Tarefa "
	cProjeto+" "+cRevisa+" "+cEDTPai+ ;
	CRLF+CRLF+cTxtErro

	If Empty(cRevisa)
		cTxtErro += CRLF+ STR0219  //"Revisão em branco."
	EndIf

	If lShowDlg
		MsgInfo(cTxtErro)
	EndIf
	CONOUT("********************"+CRLF+cTxTerro+CRLF+"********************"+CRLF )
EndIf

RestArea(aAreaOri)

Return cTarefa

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsPOCLL2³ Autor ³ Rodrigo Antonio		³ Data ³ 16-09-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna os percentual realizado da tarefa por frente          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Template de CCTR												³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CCTPOCAFC(cProjeto,cRevisa,cTarefa, dSeek)
Local aArea		:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local aAllEDT	:=	{}
Local aAllTasks := {}
Local cFiltro := "CTTrfIsFrt(PmsGetFrt())"
Local nY :=0
Local nPercRef := 0
Local nPercAtu := 0
PmsLoadTrf(cProjeto+cRevisa+cTarefa,aAllEDT,,aAllTasks,cFiltro) //Carregua as Tarefas
For nY:=	1 To	Len(aAllTasks)
	AF9->(MsGoTo(aAlltasks[nY]))
	dbSelectArea("AFC")
	dbSetOrder(1)
	If MsSeek(xFilial("AFC")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_EDTPAI)
		nHUteis	:= AFC->AFC_HUTEIS
	Endif
	dbSelectArea("LL2")
	dbSetOrder(2)//LL2_FILIAL+LL2_PROJET+LL2_REVISA+LL2_TAREFA+LL2_CODFRT+DTOS(LL2_DATA)
	If MsSeek(xFilial("LL2")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA+PmsGetFrt()+DTOS(dSeek),.T.)
		// Se a EDT Pai nao tem horas uteis, não calcula.
		// Ou a Tarefa atual e a EDT Pai estão zerados, pois pode ser um milestone
		If (nHUteis == 0 .AND. AF9->AF9_HUTEIS == 0 )
			nPercRef := 1
		Else
			nPercRef := (AF9->AF9_HUTEIS/nHUteis)
		EndIf
		nPercAtu  += ((LL2->LL2_QUANT/AF9->AF9_QUANT)*(nPercRef))

	Else
		dbSkip(-1)
		If 	!Bof() .And. AF9->AF9_PROJET==LL2->LL2_PROJET.And.;
			AF9->AF9_REVISA==LL2->LL2_REVISA .And.;
			AF9->AF9_TAREFA==LL2->LL2_TAREFA .And.;
			LL2->LL2_CODFRT== PmsGetFrt()
			// Se a EDT Pai nao tem horas uteis, não calcula.
			// Ou a Tarefa atual e a EDT Pai estão zerados, pois pode ser um milestone
			If (nHUteis == 0 .AND. AF9->AF9_HUTEIS == 0 )
				nPercRef := 1
			Else
				nPercRef := (AF9->AF9_HUTEIS/nHUteis)
			EndIf
			nPercAtu  += (LL2->LL2_QUANT/AF9->AF9_QUANT)*(nPercRef)
		EndIf
	EndIf
Next nY
nPercAtu *= 100
RestArea( aAreaAF9 )
RestArea( aArea )
Return nPercAtu

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsPercFrt³ Autor ³ Rodrigo Antonio		 ³ Data ³ 16-09-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna os percentual realizado da tarefa por frente           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Template de CCTR											     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PmsPercFrt(cProjet,cRevisao,cTarefa,cFrente)
Local nPerc := 0
LL1->(DbSetOrder(1))
If LL1->(DbSeek(xFilial("LL1")+ cProjet+cRevisao+cTarefa+cFrente))
	nPerc:= LL1->LL1_EXEC /100
EndIf
Return nPerc

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsSetFrt³ Autor ³ Rodrigo Antonio		³ Data ³ 16-09-2006	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Set o valor da Var Static da Frente						  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Template de CCTR														  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PmsSetFrt(cFrtNew)
cCCTRFrente := cFrtNew
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TemAppTOP ºAutor  ³Clovis Magenta      º Data ³  10/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que busca apontamentos de uma alias(tabela) de uma   º±±
±±º          ³ determinada tarefa por meio de linguagem SQL	             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSXFUNA(GeralApp)                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TemAppTOP( cAlias, cProjeto ,cRevisa,cTarefa)

Local aArea		:= GetArea()
Local cQuery 	:= ""
Local cEdt  	:= ""

IF cAlias <> "SC6"

	cQuery := "SELECT R_E_C_N_O_ "
	cQuery += "FROM "+RetSqlName(cAlias)+" " + cAlias + " "
	cQuery += "WHERE " +cAlias+ "_FILIAL='" +xFilial(cAlias)+ "' AND "
	cQuery += cAlias+"_PROJET = '"+cProjeto+"' AND "

	If !( cAlias $ "AFJ,AFK" )
		cQuery += cAlias+"_REVISA = '"+cRevisa+"'  AND "
   EndIf

	If cAlias $ "AFU,AJC,AJK"
		cQuery += cAlias+"_CTRRVS = '1'  AND "
   EndIf

	cQuery += cAlias+"_TAREFA = '"+cTarefa+"'  AND "

   If cAlias $ "AJA"    // considerar que o vinculo foi somente com tarefas e nao com EDT
		cEdt	:= SPACE(Tamsx3(cAlias+"_EDT")[1])
		cQuery += cAlias+"_EDT = '"+cEDT+"'  AND "
   EndIf

	cQuery += " D_E_L_E_T_=' ' "

ELSE
   // QUERY DIFERENCIADA PARA O PEDIDO DE VENDA ( SC6 )
	cQuery := "SELECT R_E_C_N_O_ "
	cQuery += "FROM "+RetSqlName("SC6")+" " + "SC6" + " "
	cQuery += "WHERE C6_FILIAL='"+xFilial("SC6")+"' AND "
	cQuery += "C6_PROJPMS = '"+cProjeto+"' AND "
	cQuery += "C6_TASKPMS = '"+cTarefa+"'  AND "
	cQuery += "D_E_L_E_T_=' ' "

ENDIF

RestArea(aArea)

Return cQuery

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TemAppTOP ºAutor  ³Clovis Magenta      º Data ³  10/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que busca apontamentos de uma alias(tabela) de uma   º±±
±±º          ³ determinada tarefa por meio de linguagem ADVPL	           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSXFUNA(GeralApp)                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TemAppADVPL( cAlias, cProjeto ,cRevisa, cTarefa)

Local lExist := .F.
Local aArea		:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAF8	:= AF8->(GetArea())
Local cEdt  	:= ""

IF cAlias <> "SC6" // SE O ALIAS NAO EH DE PEDIDO DE VENDA

	dbSelectArea(cAlias)
	dbSetOrder(1)

	Do Case

		Case cAlias == "AFO"
			dbSetOrder(2)
			cKey 		:= (xFilial("AFO")+cProjeto+cRevisa+cTarefa)

		Case cAlias == "AFJ"
			cKey 		:= (xFilial("AFJ")+cProjeto+cTarefa)

		Case cAlias == "AFK"
			dbSetOrder(3)
			cDescri 	:= ((cAlias)->&(cAlias+"_DESCRI"))
			cKey 		:= (xFilial("AFK")+cProjeto+cDescri)

		Case cAlias == "AJA"
			cEDT	 	:= ((cAlias)->&(cAlias+"_EDT"))
			cKey 		:= (xFilial("AJA")+cProjeto+cRevisa+cEDT+cTarefa)

		Case cAlias $ "AFU,AJC,AJK"
			cCtrrvs := "1" //((cAlias)->&(cAlias+"_CTRRVS"))
			cKey := (xFilial()+cCtrrvs+cProjeto+cRevisa+cTarefa)
		OTHERWISE
			cKey := (xFilial()+cProjeto+cRevisa+cTarefa)
	EndCase

	If MsSeek(cKey)
		lExist := .T.
	EndIf

ELSE
	dbSelectArea(cAlias)
	dbSetOrder(8)
	If MsSeek(xFilial(cAlias)+cProjeto+cTarefa)
		lExist := .T.
	EndIf

ENDIF

RestArea(aAreaAF8)
RestArea(aAreaAF9)
RestArea(aArea)

Return lExist


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GeralApp  ºAutor  ³Clovis Magenta      º Data ³  10/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao utilizada para verficar se a tarefa tem algum tipo   º±±
±±º          ³de apontamento, possibilitando ou nao sua exclusao          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA201, PMSA203                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function GeralApp( cProjeto, cRevisa, cTarefa )

Local lExist := .F.
Local aAlias := {	"AFF" , "AFG" , "AFH" , "AFI" , "AFJ" , "AFL" , "AFM" ,;
					"AFN" , "AFO" , "AFR" , "AFS" , "AFT" , "AFU" , "AJ7" ,;
					"AJ9" , "AJA" , "AJC" , "AJE" , "AJK" , "SC6" }
Local nLoop := 1
Local cAliasQry := GetNextAlias()
Local cQuery := ""

// Ponto de entrada que permite a escolha de quais movimentos
// serao considerados para exclusao de tarefas e EDTs
If ExistBlock("PMSAPONT")
	aAlias := ExecBlock("PMSAPONT", .F., .F., {aAlias})
EndIf

If Len(aAlias) >0

	cQuery := "SELECT R_E_C_N_O_ AS QTD FROM "
	cQuery += RetSqlName( "AF9" ) + " AF9 "
	cQuery += "WHERE "
	cQuery += " AF9_FILIAL = '"+xFilial("AF9")+"'"
	cQuery += " AND AF9_PROJET = '"+cProjeto+"'"
	cQuery += " AND AF9_REVISA = '"+cRevisa+"'"
	cQuery += " AND AF9_TAREFA = '"+cTarefa+"'"
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery += " AND EXISTS ( "

	While nLoop <= Len(aAlias)

		cQuery += TemAppTOP( aAlias[nLoop], cProjeto ,cRevisa, cTarefa)
		If nLoop < Len(aAlias)
			cQuery += " UNION "
		EndIf
		nLoop++
	EndDo
	cQuery += " ) "

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

	If (cAliasQry)->QTD > 0
		lExist := .T.
	EndIf

	If Select(cAliasQry)>0
		(cAliasQry)->(dbCloseArea())
	Endif
EndIf

Return lExist


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VrfAppEdt ºAutor  ³Clovis Magenta      º Data ³  10/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao utilizada para verificar se as tarefas/edts filhas   º±±
±±º          ³de uma determinada EDT Pai possuem apontamentos.            º±±
±±º          ³Caso encontre, impossibilita a exclusao da edt pai.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function VrfAppEdt( cProjeto, cRevisa, cEDTPai )

Local aArea 	:= GetArea()
Local aAreaAF8 := AF8->( GetArea() )
Local aAreaAFC := AFC->( GetArea() )
Local aAreaAF9 := AF9->( GetArea() )
Local cAliasTrf:= GetNextAlias()
Local cAliasEdt:= GetNextAlias()
Local lExist   := .F.
Local cQuery 	:= ""

// Procura as Tarefas Filhas
cQuery := "Select AF9.AF9_TAREFA AS TRF FROM " +RetSqlName("AF9")+ " AF9 "
cQuery += "WHERE AF9.AF9_EDTPAI = '" +cEDTPai+ "' AND "
cQuery += "AF9.AF9_PROJET = '" +cProjeto+ "' AND "
cQuery += "AF9.AF9_REVISA = '" +cRevisa+ "' AND "
cQuery += "AF9.D_E_L_E_T_ = ' ' "

cQuery += "ORDER BY TRF"

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTrf, .F., .T. )

While (cAliasTrf)->(!Eof())

	If lExist := GeralApp( cProjeto, cRevisa, (cAliasTrf)->TRF )
		Exit
	EndIf

	(cAliasTrf)->( dbSkip() )

EndDo

If !lExist

	cQuery 	:= ""
  	// Procura as EDTs Filhas
	cQuery += "Select AFC.AFC_EDT AS EDT FROM " + RetSqlName( "AFC" ) + " AFC "
	cQuery += "WHERE AFC.AFC_EDTPAI = '" +cEDTPai+ "' AND "
	cQuery += "AFC.AFC_PROJET = '" +cProjeto+ "' AND "
	cQuery += "AFC.AFC_REVISA = '" +cRevisa+ "' AND "
	cQuery += "AFC.D_E_L_E_T_ = ' '"

	cQuery += "ORDER BY EDT"

  	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasEdt, .F., .T. )

	dbSelectArea(cAliasEdt)
	While (cAliasEdt)->(!EOF())

		If lExist := VrfAppEdt( cProjeto, cRevisa, (cAliasEdt)->EDT )
			Exit
		EndIf
		(cAliasEdt)->( dbSkip() )

	EndDo

	If Select(cAliasEdt)>0
		(cAliasEdt)->(dbCloseArea())
	Endif
EndIf

RestArea( aAreaAF9 )
RestArea( aAreaAFC )
RestArea( aAreaAF8 )
RestArea( aArea )

Return lExist

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PMSDelAJT  ºAutor³ Totvs                     º Data ³ 12/06/2009    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³ Programa para exclusão de registros referente a composição aux      ³±±
±±³          ³ de projeto e ou/tarefa                                              ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ PMSDelAJT(cProjComp,cTareComp)                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros³ ExpC1 - Código do Projeto a ter a composição aux excluída           º±±
±±º          ³ ExpC2 - Código da Tarefa a ter a composição aux excluída            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Gestão de Projetos / Template Construção Civil                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSDelAJT(cProjComp,cTareComp)

Local aRecnoAJT := {}
Local aRecnoAJU := {}
Local aRecnoAJV := {}
Local aRecnoAJX := {}
Local nContItem

dbSelectArea("AJU")
dbSetOrder(1)
If AJU->(dbSeek(xfilial("AJU") + cProjComp))
	While AJU->AJU_PROJET == cProjComp .And. ! AJU->(Eof())
		aAdd(aRecnoAJU,AJU->(Recno()))
		AJU->(dbSkip())
	EndDo
EndIf

dbSelectArea("AJV")
dbSetOrder(1)
If AJV->(dbSeek(xfilial("AJV") + cProjComp))
	While AJV->AJV_PROJET == cProjComp .And. ! AJV->(Eof())
		aAdd(aRecnoAJV,AJV->(Recno()))
		AJV->(dbSkip())
	End
EndIf

dbSelectArea("AJX")
dbSetOrder(1)
If AJX->(dbSeek(xfilial("AJX") + cProjComp))
	While AJX->AJX_PROJET == cProjComp .And. ! AJX->(Eof())
		aAdd(aRecnoAJX,AJX->(Recno()))
		AJX->(dbSkip())
	End
EndIf

dbSelectArea("AJT")
dbSetOrder(1)
If AJT->(dbSeek(xfilial("AJT") + cProjComp))
	While AJT->AJT_PROJET  == cProjComp .And. ! AJT->(Eof())
		aAdd(aRecnoAJT,AJT->(Recno()))
		AJT->(dbSkip())
	End
EndIf

For nContItem := 1 to Len(aRecnoAJU)
	AJU->(dbGoto(aRecnoAJU[nContItem]))
	RecLock("AJU",.F.,.T.)
	dbDelete()
	MsUnlock()
Next

For nContItem := 1 to Len(aRecnoAJV)
	AJV->(dbGoto(aRecnoAJV[nContItem]))
	RecLock("AJV",.F.,.T.)
	dbDelete()
	MsUnlock()
Next

For nContItem := 1 to Len(aRecnoAJX)
	AJX->(dbGoto(aRecnoAJX[nContItem]))
	RecLock("AJX",.F.,.T.)
	dbDelete()
	MsUnlock()
Next

For nContItem := 1 to Len(aRecnoAJT)
	AJT->(dbGoto(aRecnoAJT[nContItem]))
	RecLock("AJT",.F.,.T.)
	dbDelete()
	MsUnlock()
Next
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AF8ComAJT  ºAutor³João Gonçalves de Oliveira º Data ³ 11/11/2008    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descrição ³ Verifica se o projeto utiliza composição aux                        ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ AF8COMAJT(cCodiProj)                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros³ ExpC1 - Código do Projeto a ser verificado                          º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 - Determina se o projeto utiliza composição aux               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Gestão de Projetos / Template Construção Civil                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF8ComAJT(cCodiProj)
Local 	lCompUnic := .F.
Local 	aArea := GetArea()
Local 	aAreaAF8 := AF8->(GetArea())

Default cCodiProj := AF8->AF8_PROJET

If HasTemplate( "CCT" )
	AF8->( DbSetOrder(1) )
	lCompUnic := AF8->( DbSeek( xFilial( "AF8" ) + cCodiProj ) ) .AND. AF8->AF8_USAAJT == "1"
EndIf

RestArea(aAreaAF8)
RestArea(aArea)

Return( lCompUnic )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PMSCusAAJT ºAutor³João Gonçalves de Oliveira º Data ³ 26/11/2008    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descrição ³ Determina percentuais e calcula o custo do projeto com base         ³±±
±±³          ³ em composição aux                                                   ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ PMSCusAAJT(cCodiProj,cReviProj,cTareProj,lAcumDias,dDataRefe,aCusto,º±±
±±º          ³  nHoraDura,nQtdeTare,dInicTare,dFinaTare,nHoraUtil)                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros³ ExpC1 - Código do Projeto                                           º±±
±±º          ³ ExpC2 - Revisão do Projeto                                          º±±
±±º          ³ ExpC3 - Tarefa do Projeto                                           º±±
±±º          ³ ExpL4 - Define se acumula os custos no período da tarefa            º±±
±±º          ³ ExpC5 - Data de Referência para cálculo                             º±±
±±º          ³ ExpN6 - Tempo de duração da tarefa                                  º±±
±±º          ³ ExpN7 - Quantidade da tarefa                                        º±±
±±º          ³ ExpD8 - Data de início da tarefa                                    º±±
±±º          ³ ExpD9 - Data final da tarefa                                        º±±
±±º          ³ ExpNA - Horas úteis da tarefa                                       º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpA1 - Vetor com valores de custo calculados por tarefa / EDT      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Gestão de Projetos / Template Construção Civil                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMSCusAAJT(cCodiProj,cReviProj,cTareProj,lAcumulado,dDataRef)

Local aArea		 := GetArea()
Local aAreaAF8	 := AF8->(GetArea())
Local aAreaAF9	 := AF9->(GetArea())
Local aCustTare := {0,0,0,0,0}
Local aCusto    := {}
Local nDecCst   := TamSX3("AF9_CUSTO")[2]

DEFAULT lAcumulado := .T.

// tarefa do projeto
dbSelectArea("AF9")
dbSetOrder(1)
If AF9->(MsSeek(xFilial("AF9") + cCodiProj + cReviProj + cTareProj))

	// composicao aux
	dbSelectArea("AJT")
	dbSetOrder(1)
	If AJT->(dbSeek(xfilial("AJT") + AF9->AF9_COMPUN + cCodiProj + cReviProj))

		// despesas da composicao aux
		dbSelectArea("AJV")
		dbSetOrder(2) //AJV_FILIAL+AJV_PROJET+AJV_REVISA+AJV_COMPUN
		MsSeek(xFilial() + cCodiProj + cReviProj+ AJT->AJT_COMPUN)
		While !Eof().And.AJV->AJV_FILIAL+AJV->AJV_PROJET+AJV->AJV_REVISA+ AJV->AJV_COMPUN==;
			xFilial("AJV") + cCodiProj + cReviProj+ AJT->AJT_COMPUN
			If PmsCOTPAJV(cCodiProj, cReviProj, cTareProj, AJV->AJV_ITEM,dDataRef,@aCusto,nDecCst,lAcumulado)
				aCustTare[1] += aCusto[1]
				aCustTare[2] += aCusto[2]
				aCustTare[3] += aCusto[3]
				aCustTare[4] += aCusto[4]
				aCustTare[5] += aCusto[5]
			EndIf
			dbSelectArea("AJV")
			dbSkip()
		EndDo

		// subcomposicao da composicao aux
		dbSelectArea("AJX")
		dbSetOrder(2)
		MsSeek(xFilial()+cCodiProj + cReviProj+ AJT->AJT_COMPUN)
		While !Eof() .AND. AJX->(AJX_FILIAL+AJX_PROJET+AJX_REVISA+AJX_COMPUN)==xFilial()+cCodiProj + cReviProj+ AJT->AJT_COMPUN

			If PmsCOTPAJX(cCodiProj, cReviProj, cTareProj, AJX->AJX_ITEM ,dDataRef,@aCusto,nDecCst,lAcumulado)
				aCustTare[1] += aCusto[1]
				aCustTare[2] += aCusto[2]
				aCustTare[3] += aCusto[3]
				aCustTare[4] += aCusto[4]
				aCustTare[5] += aCusto[5]
			EndIf

			dbSkip()
		EndDo

	EndIf
EndIf

RestArea(aAreaAF9)
RestArea(aAreaAF8)
RestArea(aArea)

Return(aCustTare)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsCOTPAEL³ Autor ³ Reynaldo Miyashita    ³ Data ³ 28-01-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna os custos previstos do insumo da composicao aux   da  ³±±
±±³ tarefa do projeto, duplicado a partir da funcao PMSCOTPAFA.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsCOTPAEL(cProjeto, cRevisa, cTarefa, cItem, dDataRef,aCusto,nDecCst,lAcumulado,nPercEx, nRecAEL )

Local nPerc
Local lRet		:= .F.
Local aArea		:= GetArea()
Local aAreaAF8	:= AF8->(GetArea())
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAEL	:= AEL->(GetArea())
Local nCusto	:= 0
Local aTX2M		:= {0,0,0,0,0}
Local cTrunca	:= "1"
Local dDtConv, cCnvPrv
Local nPercFrt := 1
Local nMoedaCust := 0
Local cGrOrga
Local nFerram
Local nProdun
lOCAL lVirtual		:= .T.

DEFAULT nDecCst		:= TamSX3("AF9_CUSTO")[2]
DEFAULT lAcumulado	:= .T.
DEFAULT nRecAEL		:= -1

aCusto	:= {0,0,0,0,0}

dbSelectArea("AF9")
dbSetOrder(1)
MsSeek(xFilial("AF9") + cProjeto + cRevisa + cTarefa)
nRecAF9 := AF9->(recno())

// Busca o item de insumo da tarefa no projeto
dbSelectArea("AEL")
dbSetOrder(1) //AEL_FILIAL+AEL_PROJET+AEL_REVISA+AEL_TAREFA+AEL_ITEM

If nRecAEL < 0
	MsSeek(xFilial("AEL") + cProjeto + cRevisa + cTarefa + cItem)
Else
	AEL->( DbGoTo( nRecAEL ) )
EndIf

//* reynaldo <BEGIN>
// Busca o cadastro de insumo do projeto
dbSelectArea("AJY")
dbSetOrder(1) //AJY_FILIAL+AJY_PROJET+AJY_REVISA+AJY_INSUMO
If MsSeek(xFilial("AJY") + cProjeto + cRevisa + AEL->AEL_INSUMO)
	If nRecAEL > 0
		lVirtual := .F.
	EndIf
EndIf

cGrOrga := IIf( lVirtual, PMSCpoCoUn("AEL_GRORGA"), AJY->AJY_GRORGA )
nProdun := IIf(cGrOrga $ IIf(AF9->AF9_TPPRDE=='1',"AB","ABE") .And. AF9->AF9_TIPO='2', AF9->AF9_PRODUC, 1 )
nFerram := Round( IIf(cGrOrga == "B", AF9->AF9_FERRAM / nProdun, 0 ), nDecCst )

If cGrOrga $ "AB"
	If AJY->AJY_TPPARC $"1;2"
		// calcula o custo standard
		nCusto := (IIf(AF8->AF8_DEPREC $ "13", PMSCpoCoUn("AEL_DEPREC"), 0) +;
				   IIf(AF8->AF8_JUROS  $ "13", PMSCpoCoUn("AEL_VLJURO" ), 0) +;
				   IIf(AF8->AF8_MDO    $ "13", PMSCpoCoUn("AEL_MDO"   ), 0) +;
				   IIf(AF8->AF8_MATERI $ "1", PMSCpoCoUn("AEL_MATERI"), 0) +;
				   IIf(AF8->AF8_MANUT  $ "1", PMSCpoCoUn("AEL_MANUT" ), 0) ) * AEL->AEL_HRPROD +;
				  (IIf(AF8->AF8_DEPREC $ "23", PMSCpoCoUn("AEL_DEPREC"), 0) +;
				   IIf(AF8->AF8_JUROS  $ "23", PMSCpoCoUn("AEL_VLJURO"), 0) +;
				   IIf(AF8->AF8_MDO    $ "23", PMSCpoCoUn("AEL_MDO"   ), 0) ) * AEL->AEL_HRIMPR
	Else
		//nCusto := PMSCpoCoUn('AEL_CUSTD')
		nCusto := IIf( lVirtual, PMSCpoCoUn('AEL_CUSTD'), AJY->AJY_CUSTD )
	EndIf
	nCusto := nCusto/nProdun + nCusto*nFerram/100
Else
	nCusto     := IIf( lVirtual, PMSCpoCoUn('AEL_CUSTD'), AJY->AJY_CUSTD ) / nProdun
EndIf
If lAcumulado
	If nPercEx == Nil
		If dDataRef >= AF9->AF9_START
			nPerc := PMSPrvAF9Cst(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dDataRef)
		Else
			nPerc := 0
		EndIf
		nCusto		:= nCusto*AEL->AEL_QUANT*AF9->AF9_QUANT*nPerc
	Else
		nCusto		:= nCusto*AEL->AEL_QUANT*AF9->AF9_QUANT*nPercEx
	Endif
	lRet		:= .T.
// faz o calculo do custo no valor nao acumulado,
// isto é não é o valor previsto até o dia, mas o valor previsto pro dia.
Else
	If nPercEx == Nil
		nCusto		:= (nCusto*PMSPrvAF9Cst(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dDataRef))*nPercFrt
	Else
		nCusto		:= (nCusto*nPercEx)*nPercFrt
	Endif
	lRet		:= .T.
EndIf

dbSelectArea("AF9")

aTX2M[1]:=1
aTX2M[2]:=AF9->AF9_TXMO2
aTX2M[3]:=AF9->AF9_TXMO3
aTX2M[4]:=AF9->AF9_TXMO4
aTX2M[5]:=AF9->AF9_TXMO5


DbSelectArea("AF8")
If ColumnPos("AF8_TRUNCA") > 0
	DbSetOrder(1)
	If (MsSeek(XFILIAL("AF8")+AF9->AF9_PROJET))
		cTrunca:=AF8->AF8_TRUNCA
	Endif
Else
	cTrunca:="1"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³CCTR - Verifica se estamos usados Frente e Pega o seu Percentual.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(PmsGetFrt())
	nPercFrt := PmsPercFrt(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,PmsGetFrt())
	nCusto *= nPercFrt
Endif

// Moeda no cadastro de insumo da tarefa
// nMoedaCust := PMSCpoCoUn('AEL_MOEDA')
nMoedaCust := IIf( lVirtual, PMSCpoCoUn( 'AEL_MOEDA' ), Val( AJY->AJY_MCUSTD ) )

PmsVerConv(@dDtConv,@cCnvPrv)
aCusto := PmsConvCus(nCusto,nMoedaCust,cCnvPrv,dDtConv,AF9->AF9_START,AF9->AF9_FINISH,,aTX2M,cTrunca,AF9->AF9_QUANT)

RestArea(aAreaAEL)
RestArea(aAreaAF9)
RestArea(aAreaAF8)
RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsCOTPAEN³ Autor ³ Marcelo Akama         ³ Data ³ 28-04-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna os custos previstos da subcomposicao da composicao    ³±±
±±³          ³aux da tarefa do projeto                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsCOTPAEN(cProjeto, cRevisa, cTarefa, cItem, dDataRef,aCusto,nDecCst,lAcumulado,nPercEx)

Local nPerc
Local lRet		:= .F.
Local aArea		:= GetArea()
Local aAreaAF8	:= AF8->(GetArea())
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAEN	:= AEN->(GetArea())
Local nCusto	:= 0
Local aTX2M		:= {0,0,0,0,0}
Local cTrunca	:= "1"
Local dDtConv, cCnvPrv
Local nPercFrt  := 1
Local nCustoAJT := 0

DEFAULT nDecCst    := TamSX3("AF9_CUSTO")[2]
DEFAULT lAcumulado := .T.

aCusto	:= {0,0,0,0,0}

dbSelectArea("AF9")
dbSetOrder(1)
MsSeek(xFilial("AF9") + cProjeto + cRevisa + cTarefa)
nRecAF9 := AF9->(recno())

aTX2M[1]:=1
aTX2M[2]:=AF9->AF9_TXMO2
aTX2M[3]:=AF9->AF9_TXMO3
aTX2M[4]:=AF9->AF9_TXMO4
aTX2M[5]:=AF9->AF9_TXMO5

dbSelectArea("AEN")
dbSetOrder(1) //AEN_FILIAL+AEN_PROJET+AEN_REVISA+AEN_TAREFA+AEN_ITEM
MsSeek(xFilial("AEN") + cProjeto + cRevisa + cTarefa + cItem)
nCustoAJT := PmsCusAJT(cProjeto, cRevisa, AEN->AEN_SUBCOM, AEN->AEN_QUANT)
If lAcumulado
	If nPercEx == Nil
		If dDataRef >= AF9->AF9_START
			nPerc := PMSPrvAF9Cst(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dDataRef)
		Else
			nPerc := 0
		EndIf
		nCusto		:= nCustoAJT*AF9->AF9_QUANT*nPerc
	Else
		nCusto		:= nCustoAJT*AF9->AF9_QUANT*nPercEx
	Endif
	lRet		:= .T.
// faz o calculo do custo no valor nao acumulado,
// isto é não é o valor previsto até o dia, mas o valor previsto pro dia.
Else
	If nPercEx == Nil
		nCusto		:= (nCustoAJT*PMSPrvAF9Cst(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dDataRef))*nPercFrt
	Else
		nCusto		:= (nCustoAJT*nPercEx)*nPercFrt
	Endif
	lRet		:= .T.
EndIf

DbSelectArea("AF8")
DbSetOrder(1)
If (MsSeek(XFILIAL("AF8")+AF9->AF9_PROJET))
	cTrunca:=AF8->AF8_TRUNCA
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³CCTR - Verifica se estamos usados Frente e Pega o seu Percentual.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(PmsGetFrt())
	nPercFrt := PmsPercFrt(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,PmsGetFrt())
	nCusto *= nPercFrt
Endif

PmsVerConv(@dDtConv,@cCnvPrv)
aCusto := PmsConvCus(nCusto,1 /*Moeda*/,cCnvPrv,dDtConv,AF9->AF9_START,AF9->AF9_FINISH,,aTX2M,cTrunca,AF9->AF9_QUANT)

RestArea(aAreaAEN)
RestArea(aAreaAF9)
RestArea(aAreaAF8)
RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsCusAJT ³ Autor ³ Marcelo Akama         ³ Data ³ 28-04-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna os custos previstos da composicao aux   do projeto    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsCusAJT(cProjeto, cRevisa, cCompun, nQtd, nDecCst)
Local aArea		:= GetArea()
Local aAreaAJT	:= AJT->(GetArea())
Local aAreaAEG	:= AEG->(GetArea())
Local aAreaAJU	:= {}
Local aAreaAJV	:= {}
Local aAreaAJX	:= {}
Local aAreaAJY	:= {}
Local aAreaAEH	:= {}
Local aAreaAEI	:= {}
Local aAreaAEJ	:= {}
Local aAreaAJZ	:= {}
Local nRet		:= 0
Local nCusto	:= 0
Local nFerram	:= 0
Local nDesp		:= 0
Local nSubComp	:= 0
Local nCustoA	:= 0
Local nCustoB	:= 0
Local nCustoE	:= 0
Local nCustoF	:= 0
Local cTrunca	:= "2"
//Local nPSubComp := 0

DEFAULT cProjeto:= AF8->AF8_PROJET
DEFAULT cRevisa := AF8->AF8_REVISA
DEFAULT cCompun := AJT->AJT_COMPUN
DEFAULT nQtd	:= 1
DEFAULT nDecCst	:= TamSX3("AF9_CUSTO")[2]

// composicao aux
dbSelectArea("AEG")
dbSetOrder(1)

DbSelectArea("AJT")
AJT->( DbSetOrder( 2 ) )
If AJT->(DbSeek( xFilial("AJT") + cProjeto + cRevisa + cCompun ) )

	aAreaAJU := AJU->(GetArea())
	aAreaAJV := AJV->(GetArea())
	aAreaAJX := AJX->(GetArea())
	aAreaAJY := AJY->(GetArea())

	// Insumos da composicao aux
	dbSelectArea("AJY")
	dbSetOrder(1) //AJY_FILIAL+AJY_PROJET+AJY_REVISA+AJY_INSUMO
	dbSelectArea("AJU")
	dbSetOrder(2) //AJU_FILIAL+AJU_PROJET+AJU_REVISA+AJU_COMPUN
	MsSeek(xFilial("AJU") + cProjeto + cRevisa + AJT->AJT_COMPUN)
	Do While !AJU->(Eof()) .and. AJU->AJU_FILIAL+AJU->AJU_PROJET+AJU->AJU_REVISA+AJU->AJU_COMPUN==;
			xFilial("AJU") + cProjeto + cRevisa + AJT->AJT_COMPUN
		If AJY->(dbSeek(xFilial("AJY") + cProjeto + cRevisa + AJU->AJU_INSUMO))

			Do Case
				Case AJU->AJU_GRORGA == "A" //Equipamentos
					nCusto   := ( AJU->AJU_HRPROD * AJY->AJY_CUSTD ) + ( AJU->AJU_HRIMPR * AJY->AJY_CUSTIM )
					nCustoA  += PMSTrunca(cTrunca, AJU->AJU_QUANT * nCusto, nDecCst)

				Case AJU->AJU_GRORGA == "B" //Mao de Obra
					nCustoB  += PMSTrunca(cTrunca, AJU->AJU_QUANT * AJY->AJY_CUSTD, nDecCst)

				Case AJU->AJU_GRORGA == "E" .Or. Empty(AJU->AJU_GRORGA)
					nCustoE  += PMSTrunca(cTrunca, AJU->AJU_QUANT * AJY->AJY_CUSTD, nDecCst)

				Case AJU->AJU_GRORGA == "F" //Transporte
					nCusto   := AJU->AJU_QUANT * AJY->AJY_CUSTD
					// DMT
					If AJU->AJU_DMT > 0
						nCusto *= AJU->AJU_DMT
					Else
						nCusto := 0
					EndIf
					nCustoF  += PMSTrunca(cTrunca, nCusto, nDecCst)

				OtherWise
					nCustoE  += PMSTrunca(cTrunca, AJU->AJU_QUANT * AJY->AJY_CUSTD, nDecCst)
			EndCase

		EndIf

		AJU->(dbSkip())
	EndDo

	// despesas da composicao aux
	dbSelectArea("AJV")
	dbSetOrder(2) //AJV_FILIAL+AJV_PROJET+AJV_REVISA+AJV_COMPUN
	MsSeek(xFilial() + cProjeto + cRevisa + AJT->AJT_COMPUN)
	While !AJV->(Eof()) .and. AJV->AJV_FILIAL+AJV->AJV_PROJET+AJV->AJV_REVISA+AJV->AJV_COMPUN==;
			xFilial("AJV") + cProjeto + cRevisa + AJT->AJT_COMPUN
		If AJV->AJV_TIPOD="9999"
			nCustoF += xMoeda( AJV->AJV_VALOR, AJV->AJV_MOEDA, 1, , nDecCst)
		Else
			nDesp += xMoeda( AJV->AJV_VALOR, AJV->AJV_MOEDA, 1, , nDecCst)
		EndIf
		AJV->(dbSkip())
	EndDo

	// subcomposicao da composicao aux
	dbSelectArea("AJX")
	dbSetOrder(2)
	MsSeek(xFilial() + cProjeto + cRevisa + AJT->AJT_COMPUN)
	While AJX->(!Eof()) .and. AJX->AJX_FILIAL+AJX->AJX_PROJET+AJX->AJX_REVISA+AJX->AJX_COMPUN==;
			xFilial("AJX") + cProjeto + cRevisa + AJT->AJT_COMPUN

		nSubComp += PmsCusAJT(cProjeto, cRevisa, AJX->AJX_SUBCOM, AJX->AJX_QUANT, nDecCst)

		AJX->(dbSkip())
	EndDo

	If AJT->AJT_FERRAM > 0
		nFerram := nCustoB * AJT->AJT_FERRAM / 100
	Else
		nFerram := 0
	EndIf
	nFerram := Round( nFerram, nDecCst )

	If AJT->AJT_TIPO == "1" //Unitario
		nRet := pmsTrunca( "2", ( nCustoA + nCustoB + nCustoE + nCustoF + nFerram + nDesp + nSubComp ), nDecCst )
	Else
		nRet := pmsTrunca( "2", ( ( nCustoA + nCustoB + nFerram ) / AJT->AJT_PRODUC ) + nCustoE + nCustoF + nDesp + nSubComp, nDecCst )
	EndIf

	RestArea(aAreaAJU)
	RestArea(aAreaAJV)
	RestArea(aAreaAJX)
	RestArea(aAreaAJY)

ElseIf AEG->(DbSeek( xFilial("AEG") + cCompun ) )

	aAreaAEH := AEH->(GetArea())
	aAreaAEI := AEI->(GetArea())
	aAreaAEJ := AEJ->(GetArea())
	aAreaAJZ := AJZ->(GetArea())

	// Insumos da composicao aux
	dbSelectArea("AJZ")
	dbSetOrder(1) //AJZ_FILIAL+AJZ_INSUMO
	dbSelectArea("AEH")
	dbSetOrder(1) //AEH_FILIAL+AEH_COMPUN+AEH_ITEM
	MsSeek(xFilial("AEH") + AEG->AEG_COMPUN)
	While !AEH->(Eof()) .and. AEH->AEH_FILIAL+AEH->AEH_COMPUN==xFilial("AEH") + AEG->AEG_COMPUN
		If AJZ->(dbSeek(xFilial("AJZ") + AEH->AEH_INSUMO))

			Do Case
				Case AEH->AEH_GRORGA == "A" //Equipamentos
					nCusto   := ( AEH->AEH_HRPROD * AJZ->AJZ_CUSTD ) + ( AEH->AEH_HRIMPR * AJZ->AJZ_CUSTIM )
					nCustoA  += PMSTrunca(cTrunca, AEH->AEH_QUANT * nCusto, nDecCst)

				Case AEH->AEH_GRORGA == "B" //Mao de Obra
					nCustoB  += PMSTrunca(cTrunca, AEH->AEH_QUANT * AJZ->AJZ_CUSTD, nDecCst)

				Case AEH->AEH_GRORGA == "E" .Or. Empty(AEH->AEH_GRORGA)
					nCustoE  += PMSTrunca(cTrunca, AEH->AEH_QUANT * AJZ->AJZ_CUSTD, nDecCst)

				Case AEH->AEH_GRORGA == "F" //Transporte
					nCusto   := AEH->AEH_QUANT * AJZ->AJZ_CUSTD
					// DMT
					If AEH->AEH_DMT > 0
						nCusto *= AEH->AEH_DMT
					Else
						nCusto := 0
					EndIf
					nCustoF  += PMSTrunca(cTrunca, nCusto, nDecCst)

				OtherWise
					nCustoE  += PMSTrunca(cTrunca, AEH->AEH_QUANT * AJZ->AJZ_CUSTD, nDecCst)
			EndCase

		EndIf
		AEH->(dbSkip())
	EndDo

	// despesas da composicao aux
	dbSelectArea("AEI")
	dbSetOrder(1) //AEI_FILIAL+AEI_COMPUN+AEI_ITEM
	MsSeek(xFilial() + AEG->AEG_COMPUN)
	While !AEI->(Eof()) .and. AEI->AEI_FILIAL+AEI->AEI_COMPUN==;
			xFilial("AEI") + AEG->AEG_COMPUN
		If AEI->AEI_TIPOD="9999"
			nCustoF += xMoeda( AEI->AEI_VALOR, AEI->AEI_MOEDA, 1, , nDecCst)
		Else
			nDesp += xMoeda( AEI->AEI_VALOR, AEI->AEI_MOEDA, 1, , nDecCst)
		EndIf
		AEI->(dbSkip())
	EndDo

	// subcomposicao da composicao aux
	dbSelectArea("AEJ")
	dbSetOrder(1) //AEJ_FILIAL+AEJ_COMPOS+AEJ_ITEM
	MsSeek(xFilial() + AEG->AEG_COMPUN)
	While !AEJ->(Eof()) .and. AEJ->AEJ_FILIAL+AEJ->AEJ_COMPOS==;
			xFilial("AEJ") + AEG->AEG_COMPUN
		nSubComp += PmsCusAJT(cProjeto, cRevisa, AEJ->AEJ_SUBCOM, AEJ->AEJ_QUANT, nDecCst)
		AEJ->(dbSkip())
	EndDo

	If AEG->AEG_FERRAM > 0
		nFerram := nCustoB * AEG->AEG_FERRAM / 100
	Else
		nFerram := 0
	EndIf
	nFerram := Round(nFerram, nDecCst)

	If AEG->AEG_TIPO == "1" //Unitario
		nRet := pmsTrunca( "2", ( nCustoA + nCustoB + nCustoE + nCustoF + nFerram + nDesp + nSubComp ), nDecCst )
	Else
		nRet := pmsTrunca( "2", ( ( nCustoA + nCustoB + nFerram ) / AEG->AEG_PRODUC ) + nCustoE + nCustoF + nDesp + nSubComp, nDecCst )
	EndIf

	RestArea(aAreaAEH)
	RestArea(aAreaAEI)
	RestArea(aAreaAEJ)
	RestArea(aAreaAJZ)
EndIf

nRet := pmsTrunca( "2", ( nRet * nQtd ), nDecCst )

RestArea(aAreaAEG)
RestArea(aAreaAJT)
RestArea(aArea)

Return nRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CCTAJUQuant ³ Autor ³Reynaldo Miyashita      ³ Data ³ 28/01/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de calculo da quantidade dos produtos da composicao aux   ³±±
±±³  do projeto com template , duplicado a partir a funcao CCTAFAQuant         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Template CCT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function CCTAJUQUANT()
Local aArea     := GetArea()
Local aAreaAF9	:= AF9->( GetArea() )
Local aAreaAJZ	:= AJZ->( GetArea() )
Local nRet     := 0
Local cPmsCust := SuperGetMv("MV_PMSCUST",.F.,"1") //Indica se utiliza o custo pela quantidade unitaria ou total
Local nProduc  := 0
Local cTpQuant  := IIf(Type("M->AF9_TPQUAN" ) == "U",AF9->AF9_TPQUAN,M->AF9_TPQUAN)
Local cTipo    := IIf(Type("M->AF9_TIPO" ) == "U",AF9->AF9_TIPO  ,M->AF9_TIPO)
Local cProduto := IIf(Type("ParamIxb[4]" ) == "U",AJU->AJU_PRODUT,ParamIxb[4])
Local nQuantTsk:= IIf(Type("ParamIxb[5]" ) == "U",AF9->AF9_QUANT ,ParamIxb[5])
Local nQuantPrd:= IIf(Type("ParamIxb[6]" ) == "U",AJU->AJU_QUANT ,ParamIxb[6])
Local nDuracTsk:= IIf(Type("ParamIxb[7]" ) == "U",AF9->AF9_HDURAC,ParamIxb[7])
Local lCompos  := IIf(Type("ParamIxb[8]" ) == "U",.F.,ParamIxb[8])
Local lProduc  := iIf(Type("ParamIxb[10]") == "U",.T.,ParamIxb[10] )

Local cOrgao    := ""
Local cUnidMedi := ""
Local cCalcTran := ""

If lProduc
	nProduc := IIf(Type("M->AF9_PRODUC") == "U",AF9->AF9_PRODUC,M->AF9_PRODUC)
Else
	nProduc := 1
EndIf
If !Empty(cTpQuant)
	cPmsCust	:= cTpQuant
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for importacao de composicao deve calcular o valor       ³
//³ proporcional da quantidade do produto em relacao da tarefa  ³
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
If lCompos
	//nRet:= nQuantPrd
	//nRet:= IIf(cPmsCust == "2",nQuantPrd,nQuantTsk * nQuantPrd)
	nRet:= nQuantTsk * nQuantPrd

Else
	If AF8ComAJT(AF9->AF9_PROJET)
		AJZ->(dbSetOrder(1))
		AJZ->(MsSeek(xFilial("AJZ") + cProduto))
		cOrgao    := AJZ->AJZ_GRORGA
		cUnidMedi := AJZ->AJZ_UM
		cCalcTran := AJZ->AJZ_CALCTR
	EndIf

	If Empty(cTipo) .OR. cTipo != "1" //Equipamento ou Mao de Obra e Tipo Producao por Equipe
		nRet:=iIf(cPmsCust == "1" ,(nQuantPrd/nProduc) ,(nQuantPrd*nQuantTsk/nProduc))
	ElseIf cOrgao == "X" .AND. cUnidMedi == "HR" //Trata quando eh caminhao basculante proprio
		nRet:= IIf(cPmsCust == "1",nQuantPrd,nDuracTsk * nQuantPrd)
	ElseIf (cOrgao $ "F") .And. cCalcTran == "2"
		If (cPmsCust == "1")
			nRet:= (nQuantPrd/nProduc)
		Else
			nRet:= (nQuantPrd * nQuantTsk / nProduc)
		EndIf
	Else // considera um material , inclusive se não foi informado grupo orgao
		If cTipo != "1" //Equipamento ou Mao de Obra e Tipo Producao por Equipe
			nRet:=iIf(cPmsCust == "1" ,(nQuantPrd/nProduc) ,(nQuantPrd*nQuantTsk/nProduc))
		Else
			nRet:= IIf(cPmsCust == "1" ,nQuantPrd ,nQuantTsk*nQuantPrd)
		EndIf
	EndIf
EndIf

If ExistBlock("CCTQTAJU")
	nRet := ExecBlock("CCTQTAJU",.F.,.F.,ParamIXB)
EndIf

RestArea( aAreaAF9 )
RestArea( aAreaAJZ )
RestArea( aArea )

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAJVValor³ Autor ³ Reynaldo Miyashita     ³ Data ³28-01-2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que calcula o valor da despesa	da tarefa com composicao³±±
±±³          ³aux no projeto, duplicada a partir da PMSAFBValor			    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAJVValor(nQuantTsk,nValor,lCompos)
Local nRet    := 0

DEFAULT nQuantTsk:= 1
DEFAULT nValor   := 1
DEFAULT lCompos  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for importacao de composicao faz-se a validacao contraria.³
//³Custo Total -> Utilza-se o valor unitario					³
//³Custo Unitario -> Utiliza-se a quantidade total              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica qual o tipo do calculo sera utilizado 1= Padrao 2=Template³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistTemplate("CCTAJVVLR") .And. (GetMV("MV_PMSCCT") == "2")
	nRet:= ExecTemplate("CCTAJVVLR",.F.,.F.,{nQuantTsk,nValor,lCompos})
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se for importacao de composicao deve calcular o valor       ³
	//³ proporcional da quantidade do produto em relacao da tarefa  ³
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	If lCompos
		nRet:= nQuantTsk * nValor
	Else
		nRet:= IIf(GetMV("MV_PMSCUST") == "1",nValor,nQuantTsk * nValor)
	EndIf
EndIf

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAJXValor³ Autor ³ Reynaldo Miyashita     ³ Data ³28-01-2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que calcula o valor da subcomposicao da tarefa com     ³±±
±±³          ³composicao aux no projeto, duplicada a partir da PMSAFBValor  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAJXValor(nQuantTsk,nValor,lCompos)
Local nRet    := 0

DEFAULT nQuantTsk:= 1
DEFAULT nValor   := 1
DEFAULT lCompos  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for importacao de composicao faz-se a validacao contraria.³
//³Custo Total -> Utilza-se o valor unitario					³
//³Custo Unitario -> Utiliza-se a quantidade total              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se for importacao de composicao deve calcular o valor       ³
	//³ proporcional da quantidade do produto em relacao da tarefa  ³
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	If lCompos
		nRet:= nQuantTsk * nValor
	Else
		nRet:= IIf(GetMV("MV_PMSCUST") == "1",nValor,nQuantTsk * nValor)
	EndIf

Return(nRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsCOTPAFV³ Autor ³ Reynaldo Miyashita    ³ Data ³ 28-01-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna os custos previstos do Recurso na data.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsCOTPAJV(cProjeto,cRevisa,cTarefa,cItem,dDataRef,aCusto,nDecCst,lAcumulado,nPercExc)
Local nPerc
Local lRet		:= .F.
Local aArea		:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAJV	:= AJV->(GetArea())
Local nCusto	:= 0
Local aTX2M		:= {0,0,0,0,0}
Local cTrunca	:= "1"
Local dDtConv, cCnvPrv
Local nPercFrt := 1

DEFAULT nDecCst    := TamSX3("AF9_CUSTO")[2]
DEFAULT lAcumulado := .T.

aCusto	:= {0,0,0,0,0}

dbSelectArea("AF9")
dbSetOrder(1)
MsSeek(xFilial()+ cProjeto + cRevisa + cTarefa)
nRecAF9 := AF9->(recno())
dbSelectArea("AJV")
dbSetOrder(2) //AJV_FILIAL+AJV_PROJET+AJV_REVISA+AJV_COMPUN
MsSeek(xFilial("AJV") + cProjeto + cRevisa + AF9->AF9_COMPUN+cItem)

dbSelectArea("AJV")
If lAcumulado
	If nPercExc <> Nil
	   nPerc	:=	nPercExc
	Else
		If dDataRef >= AF9->AF9_START
			nPerc := PMSPrvAF9Cst(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dDataRef)
		Else
			nPerc := 0
		EndIf
	Endif
	nCusto		:= PmsAJVValor(AF9->AF9_QUANT,AJV->AJV_VALOR)*nPerc
	lRet		:= .T.

// faz o calculo do custo no valor nao acumulado,
// isto é não é o valor previsto até o dia, mas o valor previsto pro dia.
Else
	If nPercExc <> Nil
		nPerc	:=	nPercExc
	Else
		nPerc := PMSPrvAF9Cst(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dDataRef)
	EndIf
	nCusto		:= PmsAJVValor(AF9->AF9_QUANT,AJV->AJV_VALOR)*nPerc
	lRet		:= .T.
EndIf

dbSelectArea("AF9")
If ColumnPos("AF9_TXMO2") > 0
	aTX2M[1]:=1
	aTX2M[2]:=AF9->AF9_TXMO2
	aTX2M[3]:=AF9->AF9_TXMO3
	aTX2M[4]:=AF9->AF9_TXMO4
	aTX2M[5]:=AF9->AF9_TXMO5
Else
	aTX2M[1]:=1
	aTX2M[2]:=0
	aTX2M[3]:=0
	aTX2M[4]:=0
	aTX2M[5]:=0
EndIf

DbSelectArea("AF8")
If ColumnPos("AF8_TRUNCA") > 0
	DbSetOrder(1)
	If (MsSeek(XFILIAL("AF8")+AF9->AF9_PROJET))
		cTrunca:=AF8->AF8_TRUNCA
	Endif
Else
	cTrunca:="1"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³CCTR - Verifica se estamos usados Frente e Pega o seu Percentual.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(PmsGetFrt())
	nPercFrt := PmsPercFrt(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,PmsGetFrt())
	nCusto *= nPercFrt
Endif

PmsVerConv(@dDtConv,@cCnvPrv)

aCusto := PmsConvCus(nCusto,AJV->AJV_MOEDA,cCnvPrv,dDtConv,AF9->AF9_START,AF9->AF9_FINISH,,aTX2M,cTrunca,AF9->AF9_QUANT)

RestArea(aAreaAF9)
RestArea(aAreaAJV)
RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsCOTPAJX³ Autor ³ Reynaldo Miyashita    ³ Data ³ 28-01-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna os custos previstos da subcomposicao da composicao    ³±±
±±³          ³aux na tarefa do projeto.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PmsCOTPAJX(cProjeto,cRevisa,cTarefa,cItem,dDataRef,aCusto,nDecCst,lAcumulado,nPercExc)
Local nPerc
Local lRet		:= .F.
Local aArea		:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAJX	:= AJX->(GetArea())
Local nCusto	:= 0
Local aTX2M		:= {0,0,0,0,0}
Local cTrunca	:= "1"
Local dDtConv, cCnvPrv
Local nPercFrt := 1
Local nAJX_Custo := 0

DEFAULT nDecCst    := TamSX3("AF9_CUSTO")[2]
DEFAULT lAcumulado := .T.

aCusto	:= {0,0,0,0,0}

dbSelectArea("AF9")
dbSetOrder(1)
MsSeek(xFilial()+ cProjeto + cRevisa + cTarefa)
nRecAF9 := AF9->(recno())
dbSelectArea("AJX")
dbSetOrder(2) //AJX_FILIAL+AJX_PROJET+AJX_REVISA+AJX_COMPUN
MsSeek(xFilial("AJX") + cProjeto + cRevisa + AF9->AF9_COMPUN+cItem)

dbSelectArea("AJX")
If ExistTemplate("CCTAJTCALC")
	nAJX_Custo := ExecTemplate("CCTAJTCALC",.F.,.F.,{AJX->AJX_SUBCOM, AJX->AJX_PROJET, AJX->AJX_REVISA,'2'})
EndIf

If lAcumulado
	If nPercExc <> Nil
	   nPerc	:=	nPercExc
	Else
		If dDataRef >= AF9->AF9_START
			nPerc := PMSPrvAF9Cst(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dDataRef)
		Else
			nPerc := 0
		EndIf
	Endif
	nCusto		:= PmsAJXValor(AF9->AF9_QUANT,nAJX_Custo)*nPerc
	lRet		:= .T.

// faz o calculo do custo no valor nao acumulado,
// isto é não é o valor previsto até o dia, mas o valor previsto pro dia.
Else
	If nPercExc <> Nil
		nPerc	:=	nPercExc
	Else
		nPerc := PMSPrvAF9Cst(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dDataRef)
	EndIf
	nCusto		:= PmsAJXValor(AF9->AF9_QUANT,nAJX_Custo)*nPerc
	lRet		:= .T.
EndIf

dbSelectArea("AF9")
If ColumnPos("AF9_TXMO2") > 0
	aTX2M[1]:=1
	aTX2M[2]:=AF9->AF9_TXMO2
	aTX2M[3]:=AF9->AF9_TXMO3
	aTX2M[4]:=AF9->AF9_TXMO4
	aTX2M[5]:=AF9->AF9_TXMO5
Else
	aTX2M[1]:=1
	aTX2M[2]:=0
	aTX2M[3]:=0
	aTX2M[4]:=0
	aTX2M[5]:=0
EndIf

DbSelectArea("AF8")
If ColumnPos("AF8_TRUNCA") > 0
	DbSetOrder(1)
	If (MsSeek(XFILIAL("AF8")+AF9->AF9_PROJET))
		cTrunca:=AF8->AF8_TRUNCA
	Endif
Else
	cTrunca:="1"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³CCTR - Verifica se estamos usados Frente e Pega o seu Percentual.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(PmsGetFrt())
	nPercFrt := PmsPercFrt(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,PmsGetFrt())
	nCusto *= nPercFrt
Endif

PmsVerConv(@dDtConv,@cCnvPrv)

aCusto := PmsConvCus(nCusto,1,cCnvPrv,dDtConv,AF9->AF9_START,AF9->AF9_FINISH,,aTX2M,cTrunca,AF9->AF9_QUANT)

RestArea(aAreaAF9)
RestArea(aAreaAJX)
RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsAvalDocºAutor  ³Clovis Magenta      º Data ³  20/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que verifica para cada registro do projeto, os docs º±±
±±º          ³ com amarracao(AC9)		                            	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSXFUNA (MOMENTO DE EXCLUSAO DO PROJETO)                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

FUNCTION PmsAvalDoc(cAlias, nReg, bSeek, bWhile)

Local nX		:= 0
Local aRecAC9	:= {}
Local aEntidade	:= {}
Local aAreaAFC	:= {}
Local aAreaAF9	:= {}
Local aAreaAlias:= {}
Local aEntidAux := MsRelation()
Local aChavDoc	:= {}
Local cCodEnt 	:= ""
Local cEntidade := ""

DEFAULT cAlias 	:= Alias()
DEFAULT nReg   	:= 0
DEFAULT bWhile    := { || .F. }
DEFAULT bSeek  := { || .F. }

dbSelectArea(calias)
dbGoTo(nReg)

If cAlias=="AF8"

	dbSelectArea("AFC")
	dbSetOrder(1)
	DbSeek(xFilial("AFC") + AF8->(AF8_PROJET+AF8_REVISA) )

	While !Eof() .and. AFC->(AFC_PROJET+AFC_REVISA)==AF8->(AF8_PROJET+AF8_REVISA)

		aAreaAFC := AFC->( GetArea() )
		aRecAC9  := {}
		aEntidade:= {}
		aChavDoc := {}

		If !Empty( nScan := AScan( aEntidAux, { |x| x[1] == "AFC" } ) )
			aAdd(aEntidade, aClone(aEntidAux[nScan]))
		EndIf

		cEntidade:= "AFC"
		aChavDoc := aClone(aEntidade[1,2])
		cCodEnt  := MaBuildKey( cEntidade, aChavDoc )
		cCodEnt  := PadR( cCodEnt, Len( AC9->AC9_CODENT ) )
		MsDocArray( cEntidade, cCodEnt, , , @aRecAC9 , 1)

		For nX:=1 to Len(aRecAC9)

			dbSelectArea("AC9")
			AC9->( dbGoTo(aRecAC9[nX]) )
			RecLock("AC9",.F.)
				dbDelete()
			AC9->( MsUnlock() )
			AC9->( dbCloseArea() )

		Next nX

		RestArea( aAreaAFC )

		AFC->( DbSkip() )
	EndDo

	dbSelectArea("AF9")
	dbSetOrder(1)
	DbSeek(xFilial("AF9") + AF8->(AF8_PROJET+AF8_REVISA) )

	While !Eof() .and. AF9->(AF9_PROJET+AF9_REVISA)==AF8->(AF8_PROJET+AF8_REVISA)

		aAreaAF9 := AF9->( GetArea() )
		aRecAC9  := {}
		aEntidade:= {}
		aChavDoc := {}

		If !Empty( nScan := AScan( aEntidAux, { |x| x[1] == "AF9" } ) )
			aAdd(aEntidade, aClone(aEntidAux[nScan]))
		EndIf

		cEntidade:= "AF9"
		aChavDoc := aClone(aEntidade[1,2])
		cCodEnt  := MaBuildKey( cEntidade, aChavDoc )
		cCodEnt  := PadR( cCodEnt, Len( AC9->AC9_CODENT ) )
		MsDocArray( cEntidade, cCodEnt, , , @aRecAC9 , 1)

		For nX:=1 to Len(aRecAC9)

			dbSelectArea("AC9")
			AC9->( dbGoTo(aRecAC9[nX]) )
			RecLock("AC9",.F.)
				dbDelete()
			AC9->( MsUnlock() )
			AC9->( dbCloseArea() )

		Next nX

		RestArea( aAreaAF9 )

		AF9->( DbSkip() )

	EndDo

else

	Eval(bSeek) //dbSeek
	While Eval(bWhile)

		aAreaAlias := (Alias)->( GetArea() )
		aRecAC9  := {}
		aEntidade:= {}
		aChavDoc := {}
		If !Empty( nScan := AScan( aEntidAux, { |x| x[1] == cAlias } ) )
			aAdd(aEntidade, aClone(aEntidAux[nScan]))
		EndIf

		cEntidade:= cAlias
		aChavDoc := aClone(aEntidade[1,2])
		cCodEnt  := MaBuildKey( cEntidade, aChavDoc )
		cCodEnt  := PadR( cCodEnt, Len( AC9->AC9_CODENT ) )
		MsDocArray( cEntidade, cCodEnt, , , @aRecAC9 , 1)

		For nX:=1 to Len(aRecAC9)

			dbSelectArea("AC9")
			AC9->( dbGoTo(aRecAC9[nX]) )
			RecLock("AC9",.F.)
				dbDelete()
			AC9->( MsUnlock() )
			AC9->( dbCloseArea() )

		Next nX

		RestArea(aAreaAlias)
		(cAlias)->( dbSkip() )

	EndDo
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAvalAEL³ Autor ³ Marcelo Akama         ³ Data ³ 29-04-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de avaliacao dos insumos na tarefa                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do insumo                                       ³±±
±±³          ³ExpN2: Codigo do Evento                                       ³±±
±±³          ³       [1] Inclusao                                           ³±±
±±³          ³       [2] Alteracao                                          ³±±
±±³          ³       [3] Exclusao                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAvalAEL(cProjet, cRevisa, cCod, nEvento)

Local aArea		:= GetArea()
Local aAreaAJY	:= AJY->(GetArea())
Local aAreaAJZ	:= AJZ->(GetArea())
Local aAreaAEK	:= AEK->(GetArea())
Local aAreaAEM	:= AEM->(GetArea())
Local cItem

DEFAULT cProjet := AEL->AEL_PROJET
DEFAULT cRevisa := AEL->AEL_REVISA
DEFAULT cCod    := AEL->AEL_INSUMO
DEFAULT nEvento := 2

Do Case
	Case nEvento == 1 // Inclusao

		// Insumos

		dbSelectArea('AJY')
		AJY->(dbSetOrder(1))
		If !AJY->(dbSeek(xFilial('AJY')+cProjet+cRevisa+cCod))
			// Se o insumo nao existir nos insumos do projeto, inclui
			dbSelectArea('AJZ')
			AJZ->(dbSetOrder(1))
			If AJZ->(dbSeek(xFilial('AJZ')+cCod))
				RecLock("AJY",.T.)

				AJY->AJY_FILIAL := xFilial("AJY")
				AJY->AJY_PROJET := cProjet
				AJY->AJY_REVISA := cRevisa
				AJY->AJY_INSUMO := AJZ->AJZ_INSUMO
				AJY->AJY_DESC   := AJZ->AJZ_DESC
				AJY->AJY_TIPO   := AJZ->AJZ_TIPO
				AJY->AJY_UM     := AJZ->AJZ_UM
				AJY->AJY_SEGUM  := AJZ->AJZ_SEGUM
				AJY->AJY_PRODUT := AJZ->AJZ_PRODUT
				AJY->AJY_RECURS := AJZ->AJZ_RECURS
				AJY->AJY_PRIORI := AJZ->AJZ_PRIORI
				AJY->AJY_CONV   := AJZ->AJZ_CONV
				AJY->AJY_TIPCON := AJZ->AJZ_TIPCON
				AJY->AJY_CUSTD  := AJZ->AJZ_CUSTD
				AJY->AJY_MCUSTD := AJZ->AJZ_MCUSTD
				AJY->AJY_POTENC := AJZ->AJZ_POTENC
				AJY->AJY_VIDAUT := AJZ->AJZ_VIDAUT
				AJY->AJY_HORANO := AJZ->AJZ_HORANO
				AJY->AJY_CALCTR := AJZ->AJZ_CALCTR
				AJY->AJY_AQUISI := AJZ->AJZ_AQUISI
				AJY->AJY_JUROS  := AJZ->AJZ_JUROS
				AJY->AJY_DEPREC := AJZ->AJZ_DEPREC
				AJY->AJY_VALCOM := AJZ->AJZ_VALCOM
				AJY->AJY_MANUT  := AJZ->AJZ_MANUT
				AJY->AJY_MATERI := AJZ->AJZ_MATERI
				AJY->AJY_MDO    := AJZ->AJZ_MDO
				AJY->AJY_GRORGA := AJZ->AJZ_GRORGA
				AJY->AJY_CUSTIM := AJZ->AJZ_CUSTIM
				AJY->AJY_TPCUSD := AJZ->AJZ_TPCUSD
				AJY->AJY_TPCUSI := AJZ->AJZ_TPCUSI
				AJY->AJY_RESIDU := AJZ->AJZ_RESIDU
				AJY->AJY_COEFMA := AJZ->AJZ_COEFMA
				AJY->AJY_COMBUS := AJZ->AJZ_COMBUS
				AJY->AJY_CALCTR := AJZ->AJZ_CALCTR
				AJY->AJY_TPPARC := AJZ->AJZ_TPPARC
				AJY->AJY_MATERI := AJZ->AJZ_MATERI
				AJY->AJY_MANUT  := AJZ->AJZ_MANUT
				AJY->AJY_MDO    := AJZ->AJZ_MDO
				AJY->AJY_VLJURO := AJZ->AJZ_VLJURO
				AJY->AJY_DEPREC := AJZ->AJZ_DEPREC
				AJY->AJY_TPJUR  := AJZ->AJZ_TPJUR
				AJY->AJY_GRUPO  := AJZ->AJZ_GRUPO
				AJY->AJY_BCOMPO := AJZ->AJZ_BCOMPO
				AJY->AJY_DATREF := AJZ->AJZ_DATREF
				AJY->AJY_TXDEPR := AJZ->AJZ_TXDEPR

				If AJZ->AJZ_GRORGA=='A' .And. AJZ->AJZ_TPPARC $ '1;2'
					AJY->AJY_CUSTD  :=	IIf(AF8->AF8_DEPREC $ "13", AJZ->AJZ_DEPREC, 0) +;
										IIf(AF8->AF8_JUROS  $ "13", AJZ->AJZ_VLJURO, 0) +;
										IIf(AF8->AF8_MDO    $ "13", AJZ->AJZ_MDO   , 0) +;
										IIf(AF8->AF8_MATERI $ "13", AJZ->AJZ_MATERI, 0) +;
										IIf(AF8->AF8_MANUT  $ "13", AJZ->AJZ_MANUT , 0)
					AJY->AJY_CUSTIM :=	IIf(AF8->AF8_DEPREC $ "23", AJZ->AJZ_DEPREC, 0) +;
										IIf(AF8->AF8_JUROS  $ "23", AJZ->AJZ_VLJURO, 0) +;
										IIf(AF8->AF8_MDO    $ "23", AJZ->AJZ_MDO   , 0)
				EndIf

				AJY->( MsUnlock() )

				// Estrutura do insumo

				// So importa quando for insumo que nao existia nos insumos do projeto,
				// caso contrario, prevalece o que ja foi customizado para o projeto

				dbSelectArea('AEM')
				AEM->(dbSetOrder(2)) //AEM_FILIAL+AEM_PROJET+AEM_REVISA+AEM_INSUMO+AEM_SUBINS
				dbSelectArea('AEK')
				AEK->(dbSetOrder(1)) //AEK_FILIAL+AEK_INSUMO+AEK_ITEM

				// verifica se o insumo tem estrutura
				AEK->(dbSeek(xFilial('AEK')+cCod))
				While !AEK->(Eof()) .and. AEK->AEK_FILIAL+AEK->AEK_INSUMO==xFilial('AEK')+cCod
					If !AEM->(dbSeek(xFilial('AEM')+cProjet+cRevisa+AEK->AEK_INSUMO+AEK->AEK_SUBCOD))
						// Se o item da estrutura do insumo não existe na estrutura do insumo do projeto, inclui
						If !AJY->(dbSeek(xFilial('AJY')+cProjet+cRevisa+AEK->AEK_SUBCOD))
							// Se o subinsumo do insumo nao existir nos insumos do projeto,
							// inclui antes de incluir a estrutura para não causar violacao de chave (se existir...)
							PmsAvalAEL(,,AEK->AEK_SUBCOD,nEvento)
						EndIf
						// Procura o proximo numero de item
						cItem := '01'
						If AEM->(dbSeek(xFilial('AEM')+cProjet+cRevisa+AEK->AEK_INSUMO))
							While !AEM->(Eof()) .and. AEM->AEM_FILIAL+cProjet+cRevisa+AEM->AEM_INSUMO == ;
													xFilial('AEM')+cProjet+cRevisa+AEK->AEK_INSUMO
								If AEM->AEM_ITEM>cItem
									cItem:=AEM->AEM_ITEM
								EndIf
								AEM->(dbSkip())
							EndDo
							cItem := Soma1(cItem)
						EndIf

						RecLock("AEM",.T.)

						AEM->AEM_FILIAL := xFilial("AEM")
						AEM->AEM_PROJET := cProjet
						AEM->AEM_REVISA := cRevisa
						AEM->AEM_INSUMO := AEK->AEK_INSUMO
						AEM->AEM_ITEM   := cItem
						AEM->AEM_TPPARC := AEK->AEK_TPPARC
						AEM->AEM_SUBINS := AEK->AEK_SUBCOD
						AEM->AEM_QUANT  := AEK->AEK_QUANT

						AEM->( MsUnlock() )
					EndIf

					AEK->(dbSkip())
				EndDo

			EndIf

		EndIf

	Case nEvento == 2 // Alteracao

	Case nEvento == 3 // Exclusao

        ///// //    //   //// //     //   //   /////   ////    /////
       //     // //    //    //     //   //  //      //  //  //   //
      /////    //     //    //     //   //   ///    //  //  //   //
     //      // //   //    //     //   //      //  //////  //   //
    ////// //    //  //// //////  /////   /////   //  //   /////

    ///////////////////////////////////////////////////////////////
    //                                                           //
    // A G U A R D A N D O   D E F I N I C A O   P R O C E S S O //
    //                                                           //
    ///////////////////////////////////////////////////////////////

    // Deve-se excluir ou criar um flag para indicar se e usado?

EndCase

RestArea(aAreaAJY)
RestArea(aAreaAJZ)
RestArea(aAreaAEK)
RestArea(aAreaAEM)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAvalAEN³ Autor ³ Marcelo Akama         ³ Data ³ 29-04-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de avaliacao das subcomposicoes na tarefa              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do insumo                                       ³±±
±±³          ³ExpN2: Codigo do Evento                                       ³±±
±±³          ³       [1] Inclusao                                           ³±±
±±³          ³       [2] Alteracao                                          ³±±
±±³          ³       [3] Exclusao                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAvalAEN(cCod,nEvento)

Local aArea		:= GetArea()
Local aAreaAEG	:= AEG->(GetArea())
Local aAreaAJT	:= AJT->(GetArea())
Local aAreaAEH	:= AEH->(GetArea())
//Local aAreaAJU	:= AJU->(GetArea())
Local aAreaAEI	:= AEI->(GetArea())
Local aAreaAJV	:= AJV->(GetArea())
Local aAreaAEJ	:= AEJ->(GetArea())
Local aAreaAJX	:= AJX->(GetArea())
Local aAreaAEL	:= AEL->(GetArea())
Local cItem

DEFAULT cCod    := AEN->AEN_SUBCOM
DEFAULT nEvento := 2

Do Case
	Case nEvento == 1 // Inclusao

		// Composicao aux
		dbSelectArea('AJT')
		AJT->(dbSetOrder(2)) //AJT_FILIAL+AJT_PROJET+AJT_REVISA+AJT_COMPUN
		If !AJT->(dbSeek(xFilial('AJT')+AEN->AEN_PROJET+AEN->AEN_REVISA+cCod))
			// Se a composicao nao existir nas composicoes do projeto, inclui
			dbSelectArea('AEG')
			AEG->(dbSetOrder(1)) //AEG_FILIAL+AEG_COMPUN
			If AEG->(dbSeek(xFilial('AEG')+cCod))
				RecLock("AJT",.T.)

				AJT->AJT_FILIAL := xFilial("AJT")
				AJT->AJT_PROJET := AEN->AEN_PROJET
				AJT->AJT_REVISA := AEN->AEN_REVISA
				AJT->AJT_COMPUN := AEG->AEG_COMPUN
				AJT->AJT_DESCRI := AEG->AEG_DESCRI
				AJT->AJT_GRPCOM := AEG->AEG_GRPCOM
				AJT->AJT_UM     := AEG->AEG_UM
				AJT->AJT_USO    := AEG->AEG_USO
				AJT->AJT_ULTATU := AEG->AEG_ULTATU
				AJT->AJT_PRIORI := AEG->AEG_PRIORI
				AJT->AJT_PRODUC := AEG->AEG_PRODUC
				AJT->AJT_QTDEQP := AEG->AEG_QTDEQP
				AJT->AJT_PRODUN := AEG->AEG_PRODUN
				AJT->AJT_TIPO   := AEG->AEG_TIPO
				AJT->AJT_BCOMPO := AEG->AEG_BCOMPO
				AJT->AJT_CODIGO := AEG->AEG_CODIGO
				AJT->AJT_TPPRDE := AEG->AEG_TPPRDE
				AJT->AJT_FERRAM := AEG->AEG_FERRAM

				AJT->( MsUnlock() )

				// Itens da composicao (insumos, despesas e subcomposicoes)

				// So importa quando for composicao aux que nao existia nas composicoes aux do projeto,
				// caso contrario, prevalece o que ja foi customizado para o projeto

				// Insumos da composicao aux

				dbSelectArea('AEL')
				AEL->(dbSetOrder(1)) //AEL_FILIAL+AEL_PROJET+AEL_REVISA+AEL_TAREFA+AEL_ITEM
				dbSelectArea('AJU')
				AJU->(dbSetOrder(3)) //AJU_FILIAL+AJU_PROJET+AJU_REVISA+AJU_COMPUN+AJU_INSUMO
				dbSelectArea('AEH')
				AEH->(dbSetOrder(1)) //AEH_FILIAL+AEH_COMPUN+AEH_ITEM

				AEH->(dbSeek(xFilial('AEH')+AEG->AEG_COMPUN))
				// verifica se o insumo da comp unic existe nos insumos da comp unic do projeto
				While !AEH->(Eof()) .and. AEH->AEH_FILIAL+AEH->AEH_COMPUN==xFilial('AEH')+AEG->AEG_COMPUN
					If !AJU->(dbSeek(xFilial('AJU')+AEN->AEN_PROJET+AEN->AEN_REVISA+AEG->AEG_COMPUN+AEH->AEH_INSUMO))
						// Posiciona AEL para chamar PmsAvalAEL
						AEL->(dbSeek(xFilial('AEL')+AEN->AEN_PROJET+AEN->AEN_REVISA+AEN->AEN_TAREFA))
						// Copia o insumo da comp unic para os insumos da comp unic do projeto se não existir
						PmsAvalAEL(AEN->AEN_PROJET,AEN->AEN_REVISA,AEH->AEH_INSUMO,nEvento)

						// Procura o proximo numero de item
						cItem := '01'
						If AJU->(dbSeek(xFilial('AJU')+AEN->AEN_PROJET+AEN->AEN_REVISA+AEG->AEG_COMPUN))
							While !AJU->(Eof()) .and. AJU->AJU_FILIAL+AJU->AJU_PROJET+AJU->AJU_REVISA+AJU->AJU_COMPUN == ;
													xFilial('AJU')+AEN->AEN_PROJET+AEN->AEN_REVISA+AEG->AEG_COMPUN
								If AJU->AJU_ITEM>cItem
									cItem:=AJU->AJU_ITEM
								EndIf
								AJU->(dbSkip())
							EndDo
							cItem := Soma1(cItem)
						EndIf

						RecLock("AJU",.T.)

						AJU->AJU_FILIAL := xFilial("AJU")
						AJU->AJU_PROJET := AEN->AEN_PROJET
						AJU->AJU_REVISA := AEN->AEN_REVISA
						AJU->AJU_COMPUN := AEG->AEG_COMPUN
						AJU->AJU_ITEM   := cItem
						AJU->AJU_INSUMO := AEH->AEH_INSUMO
						AJU->AJU_QUANT  := AEH->AEH_QUANT
						AJU->AJU_HRIMPR := AEH->AEH_HRIMPR
						AJU->AJU_HRPROD := AEH->AEH_HRPROD
						AJU->AJU_GRORGA := AEH->AEH_GRORGA
						AJU->AJU_PRODUC := AEH->AEH_PRODUC
						AJU->AJU_DMT    := AEH->AEH_DMT

						AJU->( MsUnlock() )
					EndIf

					AEH->(dbSkip())
				EndDo


				// Despesas da composicao aux

				dbSelectArea('AJV')
				AJV->(dbSetOrder(2)) //AJV_FILIAL+AJV_PROJET+AJV_REVISA+AJV_COMPUN+AJV_ITEM
				dbSelectArea('AEI')
				AEI->(dbSetOrder(1)) //AEI_FILIAL+AEI_COMPUN+AEI_ITEM

				AEI->(dbSeek(xFilial('AEI')+AEG->AEG_COMPUN))
				// verifica se a despesa da comp unic existe nos despesas da comp unic do projeto
				While !AEI->(Eof()) .and. AEI->AEI_FILIAL+AEI->AEI_COMPUN==xFilial('AEI')+AEG->AEG_COMPUN

					// Procura o proximo numero de item
					cItem := '01'
					If AJV->(dbSeek(xFilial('AJV')+AEN->AEN_PROJET+AEN->AEN_REVISA+AEG->AEG_COMPUN))
						While !AJV->(Eof()) .and. AJV->AJV_FILIAL+AJV->AJV_PROJET+AJV->AJV_REVISA+AJV->AJV_COMPUN == ;
												xFilial('AJV')+AEN->AEN_PROJET+AEN->AEN_REVISA+AEG->AEG_COMPUN
							If AJV->AJV_ITEM>cItem
								cItem:=AJV->AJV_ITEM
							EndIf
							AJV->(dbSkip())
						EndDo
						cItem := Soma1(cItem)
					EndIf

					RecLock("AJV",.T.)

					AJV->AJV_FILIAL := xFilial("AJV")
					AJV->AJV_PROJET := AEN->AEN_PROJET
					AJV->AJV_REVISA := AEN->AEN_REVISA
					AJV->AJV_COMPUN := AEG->AEG_COMPUN
					AJV->AJV_ITEM   := cItem
					AJV->AJV_TIPOD  := AEI->AEI_TIPOD
					AJV->AJV_DESCRI := AEI->AEI_DESCRI
					AJV->AJV_MOEDA  := AEI->AEI_MOEDA
					AJV->AJV_VALOR  := AEI->AEI_VALOR
					AJV->AJV_DMTT   := AEI->AEI_DMTT
					AJV->AJV_DMT    := AEI->AEI_DMT
					AJV->AJV_DMTP   := AEI->AEI_DMTP
					AJV->AJV_CUSTO  := AEI->AEI_CUSTO
					AJV->AJV_CONSUM := AEI->AEI_CONSUM

					AJV->( MsUnlock() )

					AEI->(dbSkip())
				EndDo


				// Subcomposicao da composicao aux

				dbSelectArea('AJX')
				AJX->(dbSetOrder(4)) //AJX_FILIAL+AJX_PROJET+AJX_REVISA+AJX_COMPUN+AJX_SUBCOM
				dbSelectArea('AEJ')
				AEJ->(dbSetOrder(1)) //AEJ_FILIAL+AEJ_COMPUN+AEJ_ITEM

				AEJ->(dbSeek(xFilial('AEJ')+AEG->AEG_COMPUN))
				// verifica se a subcomp da comp unic existe nas subcomp da comp unic do projeto
				While !AEJ->(Eof()) .and. AEJ->AEJ_FILIAL+AEJ->AEJ_COMPOS==xFilial('AEJ')+AEG->AEG_COMPUN
					If !AJX->(dbSeek(xFilial('AJX')+AEN->AEN_PROJET+AEN->AEN_REVISA+AEG->AEG_COMPUN+AEJ->AEJ_SUBCOM))

						// Copia a subcomp da comp unic para as subcomp da comp unic do projeto se não existir
						PmsAvalAEN(AEJ->AEJ_SUBCOM,nEvento)

						// Procura o proximo numero de item
						cItem := '01'
						If AJX->(dbSeek(xFilial('AJX')+AEN->AEN_PROJET+AEN->AEN_REVISA+AEG->AEG_COMPUN))
							While !AJX->(Eof()) .and. AJX->AJX_FILIAL+AJX->AJX_PROJET+AJX->AJX_REVISA+AJX->AJX_COMPUN == ;
													xFilial('AJX')+AEN->AEN_PROJET+AEN->AEN_REVISA+AEG->AEG_COMPUN
								If AJX->AJX_ITEM>cItem
									cItem:=AJX->AJX_ITEM
								EndIf
								AJX->(dbSkip())
							EndDo
							cItem := Soma1(cItem)
						EndIf

						RecLock("AJX",.T.)

						AJX_FILIAL := xFilial("AJX")
						AJX_PROJET := AEN->AEN_PROJET
						AJX_REVISA := AEN->AEN_REVISA
						AJX_COMPUN := AEG->AEG_COMPUN
						AJX_ITEM   := cItem
						AJX_SUBCOM := AEJ->AEJ_SUBCOM
						AJX_QUANT  := AEJ->AEJ_QUANT

						AJX->( MsUnlock() )
					EndIf

					AEJ->(dbSkip())
				EndDo

			EndIf

		EndIf

	Case nEvento == 2 // Alteracao

	Case nEvento == 3 // Exclusao

		If PMSA205Del( cCod, AEN->AEN_PROJET, AEN->AEN_REVISA, .F., AEN->(Recno()) )
			DbSelectArea( "AJT" )
			AJT->( DbSetOrder( 2 ) )
			If AJT->( DbSeek( xFilial( "AJT" ) + AEN->AEN_PROJET + AEN->AEN_REVISA + cCod ) )
				a205Grava( .T., AJT->( RecNo() ), AJT->AJT_PROJET, AJT->AJT_REVISA, AJT->AJT_COMPUN )
			EndIf
		EndIf

EndCase

RestArea(aAreaAEG)
RestArea(aAreaAJT)
RestArea(aAreaAEH)
RestArea(aAreaAEL)
RestArea(aAreaAEI)
RestArea(aAreaAJV)
RestArea(aAreaAEJ)
RestArea(aAreaAJX)
RestArea(aAreaAEL)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PmsCmpVld  ³ Autor ³ Totvs               ³ Data ³ 23-03-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida ais um linha no range.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Codigo do Projeto                                    ³±±
±±³          ³ ExpC2 : Revisao do Projeto                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsCmpVld( cProjeto, cRevisa )
	Local aAreaAF9		:= AF9->( GetArea() )
	Local cCompUnica	:= ""
	Local lRet			:= .T.

	If AF9->( ColumnPos( "AF9_COMPUN" ) ) > 0
		cCompUnica	:= M->AF9_COMPUN
		If !Empty( cCompUnica )
			DbSelectArea( "AF9" )
			AF9->( DbSetOrder( 1 ) )
			AF9->( DbSeek( xFilial( "AF9" ) + cProjeto + cRevisa ) )
			While AF9->( !Eof() ) .AND. AF9->AF9_FILIAL == xFilial( "AF9" ) .AND. AF9->AF9_PROJET == cProjeto .AND. AF9->AF9_REVISA == cRevisa
				If !Empty( AF9->AF9_COMPUN ) .AND. AF9->AF9_COMPUN <> cCompUnica
					MsgAlert( STR0210, STR0143 )
					lRet 			:= .F.
					M->AF9_COMPUN 	:= CriaVar( "AF9_COMPUN" )

					Exit
				EndIf

				AF9->( DbSkip() )
			End
		EndIf
	EndIf

	AF9->( RestArea( aAreaAF9 ) )
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSCpyCU   ³ Autor ³ Totvs               ³ Data ³ 24-06-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a copia da composicao aux   de um projeto para outro. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Codigo do Projeto Origem                             ³±±
±±³          ³ ExpC2 : Revisao do Projeto Origem                            ³±±
±±³          ³ ExpC3 : Codigo do Projeto Destino                            ³±±
±±³          ³ ExpC4 : Revisao do Projeto Destino                           ³±±
±±³          ³ ExpC5 : Composicao Aux   do Projeto Origem                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSCpyCU( cPrjDe, cRevDe, cPrjPara, cRevPara, cCompun )
	Local aFields 	:= {}
	Local aTabelas	:= { "AJT", "AJU", "AJV", "AJX" }
	Local aArea		:= {}
	Local bCampo    := { |n| FieldName( n ) }
	Local cChave	:= ""
	Local cCopia	:= ""
	Local cOrigem	:= ""
	Local lNewRec	:= .T.
	Local nCampo	:= 0
	Local nInc		:= 0
	Local nIncCU	:= 0
	Local aCodCU	:= {}
	Local cItem

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inclui as sub-composicoes das composicoes que devem ser copiadas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aCodCU, { cPrjDe, cRevDe, cCompun } )
	PA205IncSub( cPrjDe, cRevDe, cCompun, @aCodCU, .T. )

	For nIncCU := 1 To Len( aCodCU )
		cCodCU := aCodCU[ nIncCU ,3]

		For nInc := 1 To Len( aTabelas )
			cOrigem		:= aTabelas[nInc]
			cCopia		:= aTabelas[nInc]
			If cOrigem == "AEJ"
				cChave	:= cOrigem + "_PROJET+" + cOrigem + "_REVISA+" + cOrigem + "_COMPOS"
			Else
				cChave	:= cOrigem + "_PROJET+" + cOrigem + "_REVISA+" + cOrigem + "_COMPUN"
			EndIf

			DbSelectArea( cOrigem )
			(cOrigem)->( DbSetOrder( 2 ) )

			// Localiza a composicao aux a ser copiada
			(cOrigem)->( DbSeek( xFilial( cOrigem ) + cPrjDe + cRevDe + cCodCU ) )
			aFields := (cOrigem)->( DbStruct() )
			While (cOrigem)->( !Eof() ) .AND. (cOrigem)->( &( cOrigem + "_FILIAL") ) == xFilial( cOrigem ) .AND. (cOrigem)->( &(cChave) ) == cPrjDe + cRevDe + cCodCU

				If cOrigem == "AJT"
					cItem := ''
				Else
					cItem := (cOrigem)->( &( cOrigem + "_ITEM") )
				EndIf

				// Guarda posicionamento
				aArea := (cOrigem)->( GetArea() )

				// Carrega a composicao aux a ser copiada na memoria
				RegToMemory( cOrigem, .F., .F. )

				// Verifica se a composicao aux ja existe para o projeto destino
				lNewRec := (cCopia)->( !DbSeek( xFilial( cCopia ) + cPrjPara + cRevPara + cCodCU + cItem ) )

				// Inicia a copia da composicao aux da memoria para um novo registro
				If ( xFilial( cCopia ) + cPrjPara + cRevPara ) <> ( xFilial( cOrigem ) + cPrjDe + cRevDe ) .OR. lNewRec
					RecLock( cCopia, lNewRec )
					For nCampo := 1 To FCount()
						FieldPut( nCampo, M->&( Eval( bCampo, nCampo ) ) )
					Next nz

					(cCopia)->( &( cCopia + "_FILIAL" ) ) := xFilial( cCopia )
					(cCopia)->( &( cCopia + "_PROJET" ) ) := cPrjPara
					(cCopia)->( &( cCopia + "_REVISA" ) ) := cRevPara
					(cCopia)->( MsUnLock() )
				EndIf

				// Restaura posicionamento para continuar o while
				RestArea( aArea )
				(cOrigem)->( DbSkip() )
			End
		Next
	Next
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSCalcNec³ Autor ³ Edson Maricate        ³ Data ³ 18-05-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta um array contendo a necessidade dos produtos            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProjeto                                                     ³±±
±±³          ³ cRevisa                                                      ³±±
±±³          ³ cTarefa                                                      ³±±
±±³          ³ aAuxProd                                                     ³±±
±±³          ³ aAuxRat                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSCalcNec(cProjeto,cRevisa,cTarefa,aAuxProd,aAuxRat,cEDTPai)

Local nQuant      := 0
Local nQuant2     := 0
Local nQtdAFA     := 0
Local nQtd2AFA    := 0
Local nSumQtd     := 0
Local nSumQtd2    := 0
Local nCount      := 0
Local dData       := stod("")
Local aQtdPlan    := {}
Local aArea       := GetArea()
Local aAreaAFA    := AFA->(GetArea())
Local aAreaAFC    := AFC->(GetArea())
Local aAreaAF8    := AF8->(GetArea())
Local aAreaAF9    := AF9->(GetArea())
Local aAreaAFJ    := AFJ->(GetArea())
Local aAreaAEL
Local aAreaAEN
Local cLocPad
Local cTrunca     := ""
Local nDecQuant   := TamSX3("AFA_QUANT")[1]
Local nDecQtSegu  := TamSX3("AFA_QTSEGU")[1]
Local cPlanejaPor := ""
Local lGerPlan
Local lPlanPrev   := (SuperGetMV("MV_PMSPREV", .F., "1")=="1") // Se calcula as quantidades que já foram requisitadas
Local lAglut_SC   := (SuperGetMV("MV_PMSAGSC", .F., "1")=="1") // Se aglutina os produtos na solicitacao de compra
Local lReplaneja  := (SuperGetMV("MV_PMSREPL", .F., "2")=="1")
Local lOpcPadrao	:= SuperGetMv("MV_REPGOPC",.F.,"N") == "N"			//Determina se será possível repetir o mesmo grupo de opcionais em vários níveis da estrutura.
Local nCnt        := 0
Local cProduto    := ""
Local aTmpProd    := {}
Local nCntIt      := 0
Local nCntIt2     := 0
Local nPosDtNec   := 0
Local lUsaAJT     := AF8ComAJT( cProjeto )
Local aInsumos    := {}
Local cPmsCust:= GetMV("MV_PMSCUST") //Indica se utiliza o custo pela quantidade unitaria ou total
Local dDataNec
Local dDataAux
Local nPos
Local nProdun
Local nX
Local lCPConsumo := .F.


SB1->(dbSetOrder(1))
AF8->(dbSetOrder(1))
AFJ->(dbSetOrder(1))
AF8->(MsSeek(xFilial("AF8")+cProjeto))

If AF8->(ColumnPos("AF8_TRUNCA")) > 0 .AND. !Empty(AF8->AF8_TRUNCA)
	cTrunca	:= AF8->AF8_TRUNCA
Else
	cTrunca	:= "1"
EndIf

If !lUsaAJT
	lGerPlan := AFA->( ColumnPos("AFA_GERPLA") > 0 )
	dbSelectArea("AFA")
	dbSetOrder(1)
	MsSeek(xFilial("AFA")+cProjeto+cRevisa+cTarefa)
	While !Eof() .And. xFilial("AFA")+cProjeto+cRevisa+cTarefa==;
						AFA->AFA_FILIAL+AFA->AFA_PROJET+AFA->AFA_REVISA+AFA->AFA_TAREFA

		lCPConsumo := .F.

		// desconsidera o produto associado ao recurso
		If !Empty(AFA->AFA_RECURS)
			dbSelectArea("AFA")
			dbSkip()
			Loop
		EndIf

	    If !Empty(AFA->AFA_PRODUT).AND.(lReplaneja.OR.(Empty(AFA->AFA_PLANEJ).AND.!lReplaneja))
			If lGerPlan .And. AFA->AFA_GERPLA == "2"
				dbSelectArea("AFA")
				dbSkip()
				Loop
			EndIf
			SB1->(MsSeek(xFilial("SB1")+AFA->AFA_PRODUT))
			If SB1->B1_GRUPO  < M->AFK_GRPDE .Or. SB1->B1_GRUPO  > M->AFK_GRPATE ;
				.Or. AFA->AFA_PRODUT < M->AFK_PRDDE .Or. AFA->AFA_PRODUT > M->AFK_PRDATE .Or.;
				AFA->AFA_DATPRF < M->AFK_DATAI .Or. AFA->AFA_DATPRF > M->AFK_DATAF .OR.;
				 !RegistroOK("SB1",.F.)

				If !RegistroOK("SB1",.F.)
					HELP("",1,"REGBLOQ",,ALLTRIM(AFA->AFA_PRODUT) +" - "+ ALLTRIM(SB1->B1_DESC) +CRLF+ STR0207,3,1)
	    		EndIf

				dbSelectArea("AFA")
				dbSkip()
				Loop
			EndIf
			If ExistBlock("PMS220FL")
				If ExecBlock("PMS220FL",.F.,.F.)
					dbSelectArea("AFA")
					dbSkip()
					Loop
				EndIf
			EndIf
			If SB1->B1_TIPO != "BN" .and. SB1->B1_TIPO != "MO"
				AF9->(dbSetOrder(1))
				AF9->(MsSeek(xFilial()+AFA->AFA_PROJET+AFA->AFA_REVISA+AFA->AFA_TAREFA))
				cLocPad	:= If(Empty(AF8->AF8_LOCPAD),RetFldProd(SB1->B1_COD,"B1_LOCPAD"),AF8->AF8_LOCPAD)

				If ExistBlock("PMS220LOC")
				     aNewLoc := ExecBlock("PMS220LOC",.F.,.F.,{cLocPad})
				     If ValType(aNewLoc)=="A" .AND. ValType(aNewLoc[1])=="C"
				     	cLocPad := aNewLoc[1]
				     EndIf
				EndIf

				dbSelectArea("AFA")
				If Empty(AFA->AFA_PLANEJ)
					RecLock("AFA",.F.)
						AFA->AFA_PLANEJ := M->AFK_PLANEJ
					MsUnlock()
	    		EndIf

	         	// calcula a quantidade prevista do item do produto da tarefa do projeto na 1a e 2a unidade de medida
				nQtdAFA  := PmsAFAQuant(AFA->AFA_PROJET,AFA->AFA_REVISA,AFA->AFA_TAREFA,AFA->AFA_PRODUT,AF9->AF9_QUANT,AFA->AFA_QUANT ,AF9->AF9_HDURAC)
				nQtd2AFA := PmsAFAQuant(AFA->AFA_PROJET,AFA->AFA_REVISA,AFA->AFA_TAREFA,AFA->AFA_PRODUT,AF9->AF9_QUANT,AFA->AFA_QTSEGU,AF9->AF9_HDURAC)

				// Se deve planejar por data de necessidade ou pelo cronograma por periodo
				If AFA->(ColumnPos("AFA_PLNPOR")) > 0 .AND. !Empty(AFA->AFA_PLNPOR)
					cPlanejaPor := AFA->AFA_PLNPOR
				Else
					cPlanejaPor := "1"
				EndIf

				If nQtdAFA > 0
					// Cronograma por periodo
					If cPlanejaPor == "2"

						nPerc    := 0
						nSumQtd  := 0
						nSumQtd2 := 0

						//Cronograma Previsto de Consumo
						DbSelectArea("AEF")
						AEF->(DbSetOrder(1))
						If AEF->(DbSeek(xFilial("AEF")+AFA->(AFA_PROJET+AFA_REVISA+AFA_TAREFA+AFA_ITEM+AFA_PRODUT)))
							lCPConsumo := .T.
						EndIf

						//Cronograma Previsto de Consumo

						If lCPConsumo//Cronograma Previsto de Consumo
							While AEF->(!Eof()) .AND. (AEF->(AEF_FILIAL+AEF_PROJET+AEF_REVISA+AEF->AEF_TAREFA+AEF_ITEM+AEF_PRODUT) ==;
							 									xFilial("AEF")+AFA->(AFA_PROJET+AFA_REVISA+AFA_TAREFA+AFA_ITEM+AFA_PRODUT))

								nPerc := AEF->AEF_QUANT

								nQuant	:= PmsTrunca( cTrunca ,nQtdAFA *(nPerc/100) ,nDecQuant )
								nQuant2	:= PmsTrunca( cTrunca ,nQtd2AFA*(nPerc/100) ,nDecQtSegu )

								If nQuant # 0
									aAdd( aQtdPlan ,{ AEF->AEF_DATREF ,nQuant ,nQuant2 } )
									nSumQtd  += nQuant
									nSumQtd2 += nQuant2
								EndIf

								AEF->(DbSkip())
							EndDo
						Else//Cronograma por Período
							dbSelectArea("AFZ")
							dbSetOrder(1)
							dbSeek(xFilial("AFZ")+AFA->AFA_PROJET+AFA->AFA_REVISA+AFA->AFA_TAREFA)
							While AFZ->(!Eof()) .AND. ( AFZ->AFZ_FILIAL+AFZ->AFZ_PROJET+AFZ->AFZ_REVISA+AFZ->AFZ_TAREFA == xFilial("AFZ")+AFA->AFA_PROJET+AFA->AFA_REVISA+AFA->AFA_TAREFA )

								nPerc := AFZ->AFZ_PERC -nPerc

								nQuant	:= PmsTrunca( cTrunca ,nQtdAFA *(nPerc/100) ,nDecQuant )
								nQuant2	:= PmsTrunca( cTrunca ,nQtd2AFA*(nPerc/100) ,nDecQtSegu )

								If nQuant # 0
									aAdd( aQtdPlan ,{ AFZ->AFZ_DATA ,nQuant ,nQuant2 } )
									nSumQtd  += nQuant
									nSumQtd2 += nQuant2
								EndIf

								nPerc := AFZ->AFZ_PERC

								dbSelectArea("AFZ")
								dbSkip()
							EndDo
						EndIf

						If cPmsCust=="1"
							If Len(aQtdPlan)>0 .AND. (AFA->AFA_QUANT # nSumQtd)
								aQtdPlan[Len(aQtdPlan),2] := aQtdPlan[Len(aQtdPlan),2] +round(AFA->AFA_QUANT-nSumQtd  ,nDecQuant )
								aQtdPlan[Len(aQtdPlan),3] := aQtdPlan[Len(aQtdPlan),3] +round(AFA->AFA_QTSEGU-nSumQtd2,nDecQtSegu)
							EndIf
						else
							If Len(aQtdPlan)>0 .AND. ((AFA->AFA_QUANT * AF9->AF9_QUANT) # nSumQtd)
								aQtdPlan[Len(aQtdPlan),2] := aQtdPlan[Len(aQtdPlan),2] +round(AFA->AFA_QUANT-nSumQtd  ,nDecQuant )
								aQtdPlan[Len(aQtdPlan),3] := aQtdPlan[Len(aQtdPlan),3] +round(AFA->AFA_QTSEGU-nSumQtd2,nDecQtSegu)
							EndIf
						Endif
					// Data de necessidade
					Else
						nQuant	:= nQtdAFA
						nQuant2	:= nQtd2AFA
						If nQuant # 0
							aQtdPlan := {{ AFA->AFA_DATPRF ,nQuant ,nQuant2 }}
						EndIf
					EndIf
				Endif
				For nCount := 1 To len(aQtdPlan)
					dData   := aQtdPlan[nCount,1]
					nQuant  := Round(aQtdPlan[nCount,2],TamSX3("AFJ_QEMP")[2])
					nQuant2 := Round(aQtdPlan[nCount,3],TamSX3("AFJ_QATU")[2])

					If nQuant # 0 .OR. nQuant2 # 0

					    //
					    // estrutura do array aTmpProd que guarda os produtos e quantidades previstas para a tarefa
					    //
						// aTmpProd[n,01] - Codigo do Produto
						// aTmpProd[n,02] - Quantidade requisitada na 1a unidade de medida
						// aTmpProd[n,03] - Quantidade requisitadas por data de necessidade

						// aTmpProd[n,03,n,01] - Data de necessidade
						// aTmpProd[n,03,n,02] - Quantidade requisitadas na 1a unidade de medida
						// aTmpProd[n,03,n,03] - Quantidade requisitadas na 2a unidade de medida
						// aTmpProd[n,03,n,04] - Opcional <finalidade desconhecida>
						// aTmpProd[n,03,n,05] - <em branco> ou item do produto na tarefa
						// aTmpProd[n,03,n,06] - Quantidades requistadas por item do produto na tarefa

						// aTmpProd[n,03,n,07] - Armazem

						// aTmpProd[n,03,n,06,n,01] - Quantidades requistadas na 1a unidade de medida
	 					// aTmpProd[n,03,n,06,n,02] - Quantidades requistadas na 2a unidade de medida
						// aTmpProd[n,03,n,06,n,03] - 0 <finalidade desconhecida>
						// aTmpProd[n,03,n,06,n,04] - Item do produto na tarefa

						// aTmpProd[n,03,n,06,n,05] - Armazem

						aItemRat := Array(5)
						aItemRat[1] := nQuant //quantidade na 1a unidade de medida
						aItemRat[2] := nQuant2 //quantidade na 2a unidade de medida
						aItemRat[3] := 0 // 0
						aItemRat[4] := AFA->AFA_ITEM // Numero do item
						aItemRat[5] := cLocPad

	                    // busca pelo codigo do produto
						If (nPosProd := aScan(aTmpProd,{|x|x[1]==AFA->AFA_PRODUT})) > 0

							aTmpProd[nPosProd,02] += nQuant // adiciona no total do produto na tarefa

		                    // busca pelo data de necessidade
							If lAglut_SC .AND. (nPosDtNec := aScan(aTmpProd[nPosProd,03],{|x|x[1]==dData .AND. x[7]==cLocPad })) > 0
								aTmpProd[nPosProd ,03 ,nPosDtNec,2] += nQuant // adiciona no total do produto e data de necessidade
								aAdd(aTmpProd[nPosProd ,03 ,nPosDtNec,6] ,aItemRat)

							Else

								aAdd(aTmpProd[nPosProd ,03], { dData, nQuant, nQuant2, If(!lOpcPadrao,AFA->AFA_MOPC,AFA->AFA_OPC), If(lAglut_SC,"",AFA->AFA_ITEM);
									                              ,{aItemRat}, 	aItemRat[5] })

							EndIf

						// adiciona o produto no array
						Else

							aAdd(aTmpProd, { AFA->AFA_PRODUT, nQuant, {{dData, nQuant, nQuant2, If(!lOpcPadrao,AFA->AFA_MOPC,AFA->AFA_OPC), If(lAglut_SC,"",AFA->AFA_ITEM);
    						                ,{aItemRat}, 	aItemRat[5]}} })


	                    EndIf
					EndIf
				Next nCount
				aQtdPlan := {}
			EndIf
		EndIf
		dbSelectArea("AFA")
		dbSkip()
	EndDo

Else

	lAglut_SC := .T.
	lGerPlan  := .T.


		aAreaAEL := AEL->( GetArea() )
		aAreaAEN := AEN->( GetArea() )

		// Estrutura: aInsumos
		// aInsumos[1] -> Codigo do Insumo
		// aInsumos[2] -> Data necessidade
		// aInsumos[3] -> Armazem padrao
		// aInsumos[4] -> Quantidade
		// aInsumos[5] -> Quantidade 2a UM

		DbSelectArea( "AF9" )
		AF9->( DbSetOrder( 1 ) )
		If AF9->( DbSeek( xFilial( "AF9" ) + cProjeto + cRevisa + cTarefa ) )

			//Insumos da tarefa

			DbSelectArea( "AEL" )
			AEL->( DbSetOrder( 1 ) )
			AEL->( DbSeek( xFilial( "AEL" ) + cProjeto + cRevisa + cTarefa ) )
			Do While AEL->( !Eof() ) .And. AEL->( AEL_FILIAL + AEL_PROJET + AEL_REVISA + AEL_TAREFA ) == xFilial( "AEL" ) + cProjeto + cRevisa + cTarefa

				If !AEL->AEL_GRORGA $ 'AE'
					AEL->( DbSkip() )
					Loop
				EndIf

				If lReplaneja .Or. ( Empty(AEL->AEL_PLANEJ) .And. !lReplaneja )
					If lGerPlan .And. AEL->AEL_GERPLA == "2"
						AEL->( DbSkip() )
						Loop
					EndIf
				EndIf

				// Se deve planejar por data de necessidade ou pelo cronograma por periodo
				If AEL->(ColumnPos("AEL_PLNPOR")) > 0 .AND. !Empty(AEL->AEL_PLNPOR)
					cPlanejaPor := AEL->AEL_PLNPOR
				Else
					cPlanejaPor := "1"
				EndIf

				If empty(AEL->AEL_DATPRF)
					dDataAux := AF9->AF9_START
				Else
					dDataAux := AEL->AEL_DATPRF
				EndIf

				If AF9->AF9_TPMEDI<>'6' .Or. cPlanejaPor=='1'
					dDataNec := dDataAux
				Else
					dDataNec := nil
				EndIf

				nProdun := IIf(AEL->AEL_GRORGA $ IIf(AF9->AF9_TPPRDE=='1',"AB","ABE") .And. AF9->AF9_TIPO='2', AF9->AF9_PRODUC, 1 )

				If PMSNecIns(cProjeto, cRevisa, AEL->AEL_INSUMO, AEL->AEL_QUANT * AF9->AF9_QUANT / nProdun, AEL->AEL_QTSEGU * AF9->AF9_QUANT / nProdun, AEL->AEL_HRPROD, dDataAux, dDataNec, @aInsumos)
					dbSelectArea("AEL")
					If Empty(AEL->AEL_PLANEJ)
						RecLock("AEL",.F.)
						AEL->AEL_PLANEJ := M->AFK_PLANEJ
						MsUnlock()
		    		EndIf
				EndIf

				DbSelectArea( "AEL" )
				AEL->(dbSkip())

			EndDo

			// Subcomposicoes da tarefa

			DbSelectArea( "AEN" )
			AEN->( DbSetOrder( 1 ) )
			AEN->( DbSeek( xFilial( "AEN" ) + cProjeto + cRevisa + cTarefa ) )
			Do While AEN->( !Eof() ) .And. AEN->( AEN_FILIAL + AEN_PROJET + AEN_REVISA + AEN_TAREFA ) == xFilial( "AEN" ) + cProjeto + cRevisa + cTarefa

				// Se deve planejar por data de necessidade ou pelo cronograma por periodo
				If AF9->AF9_TPMEDI=='6'
					cPlanejaPor := "2"
				Else
					cPlanejaPor := "1"
				EndIf

				dDataAux := AF9->AF9_START

				If cPlanejaPor=='1'
					dDataNec := dDataAux
				Else
					dDataNec := nil
				EndIf

				nProdun := IIf(AF9->AF9_TPPRDE<>'1' .And. AF9->AF9_TIPO='2', AF9->AF9_PRODUC, 1 )
				If PMSNecSub(cProjeto, cRevisa, AEN->AEN_SUBCOM, AEN->AEN_QUANT * AF9->AF9_QUANT / nProdun, dDataAux, dDataNec, @aInsumos)
					dbSelectArea("AEN")
					If Empty(AEN->AEN_PLANEJ)
						RecLock("AEN",.F.)
						AEN->AEN_PLANEJ := M->AFK_PLANEJ
						MsUnlock()
		    		EndIf
				EndIf

				AEN->( DbSkip() )
			EndDo

		EndIf

		RestArea( aAreaAEL )
		RestArea( aAreaAEN )



	For nX := 1 To len(aInsumos)

		If aInsumos[nX,4] > 0
			// Cronograma por periodo
			If aInsumos[nX,2]==nil
				nPerc    := 0
				nSumQtd  := 0
				nSumQtd2 := 0

				dbSelectArea("AFZ")
				dbSetOrder(1)
				dbSeek(xFilial("AFZ")+cProjeto+cRevisa+cTarefa)
				Do While AFZ->(!Eof()) .AND. ( AFZ->AFZ_FILIAL+AFZ->AFZ_PROJET+AFZ->AFZ_REVISA+AFZ->AFZ_TAREFA == xFilial("AFZ")+cProjeto+cRevisa+cTarefa )
					nPerc	:= AFZ->AFZ_PERC -nPerc
					nQuant	:= PmsTrunca( cTrunca ,aInsumos[nX,4]*(nPerc/100) ,nDecQuant )
					nQuant2	:= PmsTrunca( cTrunca ,aInsumos[nX,5]*(nPerc/100) ,nDecQtSegu )

					If nQuant # 0
						aAdd( aQtdPlan ,{ AFZ->AFZ_DATA ,nQuant ,nQuant2 } )
						nSumQtd  += nQuant
						nSumQtd2 += nQuant2
					EndIf

					nPerc := AFZ->AFZ_PERC

					AFZ->( dbSkip() )
				EndDo
				If Len(aQtdPlan)>0 .AND. (aInsumos[nX,4] # nSumQtd)
					aQtdPlan[Len(aQtdPlan),2] := aQtdPlan[Len(aQtdPlan),2] +round(aInsumos[nX,4]-nSumQtd  ,nDecQuant )
					aQtdPlan[Len(aQtdPlan),3] := aQtdPlan[Len(aQtdPlan),3] +round(aInsumos[nX,5]-nSumQtd2 ,nDecQtSegu)
				EndIf
			// Data de necessidade
			Else
				nQuant	:= aInsumos[nX,4]
				nQuant2	:= aInsumos[nX,5]
				If nQuant # 0
					aQtdPlan := {{ aInsumos[nX,2] ,nQuant ,nQuant2 }}
				EndIf
			EndIf

		EndIf

        cLocPad  := aInsumos[nX,3]
        cProduto := aInsumos[nX,6]

		For nCount := 1 To len(aQtdPlan)
			dData   := aQtdPlan[nCount,1]
			nQuant  := Round(aQtdPlan[nCount,2],TamSX3("AFJ_QEMP")[2])
			nQuant2 := Round(aQtdPlan[nCount,3],TamSX3("AFJ_QATU")[2])

			If nQuant # 0 .Or. nQuant2 # 0
			    //
			    // estrutura do array aTmpProd que guarda os produtos e quantidades previstas para a tarefa
			    //
				// aTmpProd[n,01] - Codigo do Produto
				// aTmpProd[n,02] - Quantidade requisitada na 1a unidade de medida
				// aTmpProd[n,03] - Quantidade requisitadas por data de necessidade

				// aTmpProd[n,03,n,01] - Data de necessidade
				// aTmpProd[n,03,n,02] - Quantidade requisitadas na 1a unidade de medida
				// aTmpProd[n,03,n,03] - Quantidade requisitadas na 2a unidade de medida
				// aTmpProd[n,03,n,04] - Opcional <finalidade desconhecida>
				// aTmpProd[n,03,n,05] - <em branco> ou item do produto na tarefa
				// aTmpProd[n,03,n,06] - Quantidades requistadas por item do produto na tarefa

				// aTmpProd[n,03,n,07] - Armazem

				// aTmpProd[n,03,n,06,n,01] - Quantidades requistadas na 1a unidade de medida
				// aTmpProd[n,03,n,06,n,02] - Quantidades requistadas na 2a unidade de medida
				// aTmpProd[n,03,n,06,n,03] - 0 <finalidade desconhecida>
				// aTmpProd[n,03,n,06,n,04] - Item do produto na tarefa

				// aTmpProd[n,03,n,06,n,05] - Armazem

				aItemRat := Array(5)
				aItemRat[1] := nQuant //quantidade na 1a unidade de medida
				aItemRat[2] := nQuant2 //quantidade na 2a unidade de medida
				aItemRat[3] := 0 // 0
				aItemRat[4] := '' //AEL->AEL_ITEM // Numero do item
				aItemRat[5] := cLocPad

				// busca pelo codigo do produto
				If (nPosProd := aScan(aTmpProd,{|x|x[1]==cProduto})) > 0
					aTmpProd[nPosProd,02] += nQuant // adiciona no total do produto na tarefa

                    // busca pelo data de necessidade
					If lAglut_SC .AND. (nPosDtNec := aScan(aTmpProd[nPosProd,03],{|x|x[1]==dData .AND. x[7]==cLocPad })) > 0
						aTmpProd[nPosProd ,03 ,nPosDtNec,2] += nQuant // adiciona no total do produto e data de necessidade
						aAdd(aTmpProd[nPosProd ,03 ,nPosDtNec,6] ,aItemRat)
					Else
						aAdd(aTmpProd[nPosProd ,03], { dData, nQuant, nQuant2, "", ""/*If(lAglut_SC,"",AEL->AEL_ITEM)*/;
						                              ,{aItemRat}, 	aItemRat[5] })
					EndIf

				// adiciona o produto no array
				Else
					aAdd(aTmpProd, { cProduto, nQuant, {{dData, nQuant, nQuant2, "", ""/*If(lAglut_SC,"",AEL->AEL_ITEM)*/;
					                ,{aItemRat}, 	aItemRat[5]}} })
				EndIf
			EndIf
		Next nCount
		aQtdPlan := {}

    Next nX

EndIf

// calcula as quantidades que já foram requisitadas para os produtos da tarefa e desconta das quantidades previstas
If lPlanPrev
	PMSCalcReq(cProjeto, cRevisa, cTarefa, aTmpProd)
EndIf
// Este loop tem a finalidade "carregar" os arrays aAuxProd e aAuxRat

For nCnt := 1 To Len(aTmpProd)
	cProduto := aTmpProd[nCnt,01]
	// Se tem a quantidade prevista do produto na tarefa
	If aTmpProd[nCnt,02] > 0
		For nCntIt := 1 to len(aTmpProd[nCnt,03])
			dData := aTmpProd[nCnt ,03 ,nCntIt ,01]
			// Se tem a quantidade prevista do produto por data de necessidade na tarefa
			If aTmpProd[nCnt ,03 ,nCntIt ,02] > 0
				For nCntIt2 := 1 to len(aTmpProd[nCnt ,03 ,nCntIt ,06])
					// Se tem a quantidade prevista do produto por item na tarefa
					If aTmpProd[nCnt,03,nCntIt,06,nCntIt2,01] > 0

						aItemRat := Array(9)
						aItemRat[1] := cProjeto
						aItemRat[2] := cRevisa
						aItemRat[3] := cTarefa
						aItemRat[4] := aTmpProd[nCnt,03,nCntIt,06,nCntIt2,01] //quantidade na 1a unidade de medida
						aItemRat[5] := aTmpProd[nCnt,03,nCntIt,06,nCntIt2,02] //quantidade na 2a unidade de medida
						aItemRat[6] := aTmpProd[nCnt,03,nCntIt,06,nCntIt2,03] // 0
						aItemRat[7] := aTmpProd[nCnt,03,nCntIt,06,nCntIt2,04] // Numero do item
						aItemRat[8] := aTmpProd[nCnt,03,nCntIt,06,nCntIt2,05]
						aItemRat[9] := cEDTPai
						// Se aglutina o produto na solicitacao de compra baseado no produto ,data de necessidade e armazem.
						If lAglut_SC .And. (nPosProd := aScan(aAuxProd,{|x| x[1]==cProduto .And. x[2]==dData /*.AND. x[7]==aTmpProd[nCnt,03,nCntIt,06,nCntIt2,05]*/})) > 0

							aAuxProd[nPosProd,3] += aItemRat[4] // acumula a quantidade necessaria do produto no projeto
							aAuxProd[nPosProd,4] += aItemRat[5]

							// Adiciona a tarefa no rateio do projeto.
							nPosRat := aScan(aAuxRat,{|x|x[1]==nPosProd})
							nPos := aScan(aAuxRat[nPosRat,2],{|x| x[1]==aItemRat[1] .And. x[2]==aItemRat[2] .And. x[3]==aItemRat[3]})
							If nPos>0
								aAuxRat[nPosRat,2,nPos,4] += aItemRat[4]
								aAuxRat[nPosRat,2,nPos,5] += aItemRat[5]
							Else
								aAdd(aAuxRat[nPosRat,2],aItemRat)
							EndIf

						Else

							aAdd(aAuxProd, { cProduto ,aTmpProd[nCnt ,03 ,nCntIt ,01],aItemRat[4],aItemRat[5];
							                ,aTmpProd[nCnt ,03 ,nCntIt ,04] ,aTmpProd[nCnt ,03 ,nCntIt ,05],aTmpProd[nCnt ,03 ,nCntIt ,07]})

							aAdd(aAuxRat,{Len(aAuxProd),{aItemRat}})

						EndIf
					EndIf
				Next nCntIt2
			EndIf
		Next nCntIt
	EndIf

Next nCnt

RestArea(aAreaAFA)
RestArea(aAreaAFC)
RestArea(aAreaAF8)
RestArea(aAreaAF9)
RestArea(aAreaAFJ)
RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAELQuant³ Autor ³ Totvs                  ³ Data ³01-06-2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que calcula a quantidade do insumo do projeto			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAELQuant(cProjeto,cRevisa,cTarefa,nQuantTsk,nQuantPrd)
Local nRet			:= 0
Local cPmsCust		:= GetMV( "MV_PMSCUST" ) //Indica se utiliza o custo pela quantidade unitaria ou total

DEFAULT cProjeto	:= AF8->AF8_PROJET
DEFAULT cRevisa		:= AF8->AF8_REVISA
DEFAULT cTarefa		:= AF9->AF9_TAREFA
DEFAULT nQuantTsk	:= 1
DEFAULT nQuantPrd	:= 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica qual o tipo do calculo sera utilizado 1= Padrao 2=Template³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetMV( "MV_PMSCCT" ) == "2"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for importacao de composicao deve calcular o valor     ³
	//³proporcional da quantidade do produto em relacao da tarefa³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRet:= nQuantTsk * nQuantPrd
	If cPmsCust == "1"
		nRet := nQuantPrd
	EndIf
EndIf

Return( nRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsPrvAEL³ Autor ³ Totvs                  ³ Data ³ 23-06-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a quantidade prevista do AEL no periodo especificado. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsPrvAEL( nRecAJY, dDataDe, dDataAte, nRecAF9, nRecAEL )

Local nPerc
Local nHrsUteis := 0
Local nQuant	:= 0
Local aArea		:= GetArea()
Local aAreaAEL	:= AEL->(GetArea())

AEL->( DBGoto( nRecAEL ) )
AJY->( DBGoto( nRecAJY ) )
If nRecAF9 == Nil
	dbSelectArea("AF9")
	AF9->( DbSetOrder( 1 ) )
	AF9->( DbSeek( xFilial( "AF9" ) + AEL->( AEL_PROJET + AEL_REVISA + AEL_TAREFA ) ) )
Else
	AF9->( DbGoto( nRecAF9 ) )
EndIf

Do Case
	Case AEL->AEL_ACUMUL == "1"
		If (dDataDe >= AF9->AF9_START .And. dDataDe < AF9->AF9_FINISH) .Or.(dDataAte >= AF9->AF9_START .And. dDataAte < AF9->AF9_FINISH)
			nQuant	:= PmsAFAQuant(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,AJY->AJY_PRODUT,AF9->AF9_QUANT,AEL->AEL_QUANT,AF9->AF9_HDURAC)/2
    	EndIf
		If dDataDe <= AF9->AF9_START .And. dDataAte >= AF9->AF9_FINISH
			nQuant	:= PmsAFAQuant(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,AJY->AJY_PRODUT,AF9->AF9_QUANT,AEL->AEL_QUANT,AF9->AF9_HDURAC)
    	EndIf
	Case AEL->AEL_ACUMUL == "2"
		If dDataDe <= AF9->AF9_FINISH .And. dDataAte >= AF9->AF9_FINISH
			nQuant	:= PmsAFAQuant(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,AJY->AJY_PRODUT, AF9->AF9_QUANT,AEL->AEL_QUANT,AF9->AF9_HDURAC)
		EndIf
	Case AEL->AEL_ACUMUL == "4"
		If dDataDe <= AFA->AFA_DATPRF .And. dDataAte >= AFA->AFA_DATPRF
			nQuant	:= PmsAFAQuant(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,AJY->AJY_PRODUT,AF9->AF9_QUANT,AEL->AEL_QUANT,AF9->AF9_HDURAC)
		EndIf
	Case AEL->AEL_ACUMUL == "5"
		If dDataDe>=AFA->AFA_DTAPRO
			nQuant	:= PmsAFAQuant(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,AJY->AJY_PRODUT,AF9->AF9_QUANT,AEL->AEL_QUANT,AF9->AF9_HDURAC)
		EndIf
	Case AEL->AEL_ACUMUL == "6"
		If AF9->AF9_HUTEIS > 0

  			If !((dDataDe < AEL->AEL_DTAPRO .And. dDataAte < AEL->AEL_DTAPRO) ;
  			    .OR.(dDataDe > AF9->AF9_FINISH .And. dDataAte > AF9->AF9_FINISH))

				If AEL->AEL_DTAPRO >= dDataDe
					dDataDe := AEL->AEL_DTAPRO
				EndIf

				If AF9->AF9_FINISH < dDataAte
					dDataAte := AF9->AF9_FINISH
				EndIf

				nHrsUteis := PmsHrsItvl(dDataDe ,AF9->AF9_HORAI, dDataAte ,"24:00",AF9->AF9_CALEND,AF9->AF9_PROJET)
				If nHrsUteis==AF9->AF9_HUTEIS
					nPerc := 1
				Else
					nPerc := nHrsUteis/PmsHrsItvl(AEL->AEL_DTAPRO,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,AF9->AF9_CALEND,AF9->AF9_PROJET)
				EndIf
			Else
				nPerc := 0
  			EndIf
		Else
			If dDataDe <= AEL->AEL_DTAPRO .And. dDataAte >= AF9->AF9_FINISH
				nPerc	:= 1
			Else
				nPerc	:= 0
			EndIf
		EndIf

		nQuant	:= PmsAFAQuant(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,AJY_PRODUT,AF9->AF9_QUANT,AEL->AEL_QUANT,AF9->AF9_HDURAC)*nPerc
	OtherWise
		If AF9->AF9_HUTEIS > 0
			nPerc		:= (PMSPrvAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dDataAte)-PMSPrvAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dDataDe-1))/AF9->AF9_HDURAC
		Else
			If dDataDe <= AF9->AF9_START .And. dDataAte >= AF9->AF9_FINISH
				nPerc	:= 1
			Else
				nPerc	:= 0
			EndIf
		EndIf
		nQuant	:= PmsAFAQuant(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,AJY_PRODUT,AF9->AF9_QUANT,AEL->AEL_QUANT,AF9->AF9_HDURAC)*nPerc
EndCase

RestArea( aAreaAEL )
RestArea( aArea )

Return nQuant

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsVldHr ³ Autor ³ Totvs                  ³ Data ³ 23-06-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a quantidade de horas produtivas/improdutivas         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsVldHr( cInsumo, cTipo, nValor, nValorContra )
	Local nRet := nValorContra

	If cTipo == "2" .AND. PmsGpOrgIns( cInsumo ) == "A"
		nRet := 1 - nValor
	EndIf
Return nRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsGpOrgIns³ Autor ³ Totvs                ³ Data ³ 02-07-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o grupo orgao do insumo                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsGpOrgIns( cInsumo )
	Local cRet	:= ""

	DbSelectArea( "AJZ" )
	AJZ->( DbSetOrder( 1 ) )
	If AJZ->( DbSeek( xFilial( "AJZ" ) + cInsumo ) )
		cRet := AJZ->AJZ_GRORGA
	EndIf
Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³PmaVldFldHr  ³ Autor ³ Totvs                 ³ Data ³ 02.07.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Valida a quantidade de horas produtivas/improdutivas do insumo³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PmaVldFldHr( cCodIns, nValor )
	Local lRet 		:= .T.
	Local cInsumo	:= ""
	Local nPos		:= aScan( aHeader, { |x| x[2] == cCodIns } )

	If nPos > 0
		cInsumo := aCols[n,nPos]
		If PmsGpOrgIns( cInsumo ) == "A" .AND. nValor > 1
			lRet := .F.
		EndIf
	EndIf

	If !lRet
		MsgAlert( STR0215 ) //"O valor maximo para insumos do grupo orgao 'A' e 1!"
	EndIf
Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³PmsCalcCCTHr ³ Autor ³ Totvs                 ³ Data ³ 02.07.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Calcula a hora produtiva/improdutiva no aCols                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PmsCalcCCTHr( lCalcula )
Local cCampo  	:= ReadVar()
Local nPIndImp	:= aScan( aHeader, { |x| "_HRIMPR" $ x[2] } )
Local nPIndPrd	:= aScan( aHeader, { |x| "_HRPROD" $ x[2] } )
Local nPCusPrd	:= aScan( aHeader, { |x| "_CUSPRD" $ x[2] } )
Local nPCusImp	:= aScan( aHeader, { |x| "_CUSIMP" $ x[2] } )
Local nPCustd 	:= aScan( aHeader, { |x| "_CUSTD"  $ x[2] } )
Local nCustD	:= 0
Local lCompUnic	:= "AJU" $ cCampo

Default lCalcula := .T.

Do Case
	Case cCampo $ "M->AEH_INSUMO#M->AJU_INSUMO#M->AEL_INSUMO"
		nCustD				:= (aCols[n,nPCusPrd] * aCols[n,nPIndPrd]) + (aCols[n,nPCusImp] * aCols[n,nPIndImp])
		aCols[n,nPCustd]	:= nCustD
	Case cCampo $ "M->AEH_HRPROD#M->AJU_HRPROD#M->AEL_HRPROD"
		nCustD				:= (aCols[n,nPCusPrd] * aCols[n,nPIndPrd]) + (aCols[n,nPCusImp] * aCols[n,nPIndImp])
		aCols[n,nPCustd]	:= nCustD
	Case cCampo $ "M->AEH_HRIMPR#M->AJU_HRIMPR#M->AEL_HRIMPR"
		nCustD				:= (aCols[n,nPCusPrd] * aCols[n,nPIndPrd]) + (aCols[n,nPCusImp] * aCols[n,nPIndImp])
		aCols[n,nPCustd]	:= nCustD
EndCase

If lCalcula
	If lCompUnic
		If ExistTemplate("CCTAJTCUST")
			ExecTemplate("CCTAJTCUST",.F.,.F.,{ 1,, "AJT" })
		EndIf
	Else
		If ExistTemplate("CCTAEGCUST")
			ExecTemplate("CCTAEGCUST",.F.,.F.,{1,,"AEG"})
		EndIf
	EndIf
EndIf

Return nCustD


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSAvalEmpºAutor  ³Clovis Magenta      º Data ³  24/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que verificará se o projeto+tarefa+produto+local    º±±
±±º          ³ possui algum empenho que esteja perneta, por causa de uma  º±±
±±º          ³ exclusao de uma OP gerada por um planejamento              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ X3_RELACAO AFM_TAREFA                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAvalEmp(cAlias)
Local aRecsAFJ := {}
Local nPosPrj 	:= 0
Local nPosTrf 	:= 0
Local nPosTRT 	:= 0
Local nPosQuant:= 0
Local nPosPlan := 0
Local cTrt		:= ""
Local cC1Prod 	:= ""
Local cC1Local := ""
Local nX 		:=0
Local lAchou 	:= .F.
Local lGetEmp   := SuperGetMV("MV_PMSOPSC",,"1") == "1"

DEFAULT cAlias 	:= "AFM"

nPosPrj 	:= aScan(aHeader,{|x| alltrim(x[2])==cAlias+"_PROJET"})
nPosTrf 	:= aScan(aHeader,{|x| alltrim(x[2])==cAlias+"_TAREFA"})
nPosTRT 	:= aScan(aHeader,{|x| alltrim(x[2])==cAlias+"_TRT"})
nPosQuant:= aScan(aHeader,{|x| alltrim(x[2])==cAlias+"_QUANT"})
nPosPlan := aScan(aHeader,{|x| alltrim(x[2])==cAlias+"_PLANEJ"})

If cAlias=="AFG"
	cC1Prod  :=	aSC1Itens[1,2] // produto SC
	cC1Local := aSC1Itens[2,2] // local do produto da SC
elseif cAlias=="AFM"
	cC1Prod  :=	M->C2_PRODUTO
	cC1Local := M->C2_LOCAL
Endif

If !lGetEmp

	If (nPosPrj>0) .and. (nPosTrf>0) .and. (nPosTRT>0) .and. (nPosQuant>0) .and. (nPosPlan>0)

		dbselectArea("AFJ")
		dbSetOrder(1) //AFJ_FILIAL+AFJ_PROJET+AFJ_TAREFA+AFJ_COD+AFJ_LOCAL
		dbSeek(xFilial("AFJ")+aCols[n,nPosPrj]+M->&(cAlias+"_TAREFA")+cC1Prod+cC1Local)
		WHILE AFJ->(!EOF()) .and.;
			(AFJ->(AFJ_PROJETO+AFJ_TAREFA+AFJ_COD+AFJ_LOCAL)==aCols[n,nPosPrj]+M->&(cAlias+"_TAREFA")+cC1Prod+cC1Local)
            // ROTGER = 1 SIGNIFICA QUE O EMPENHO É DE UMA SC  // ROTGER = 2 SIGNIFICA QUE O EMPENHO É DE UMA OP
			If !EMPTY(AFJ->AFJ_PLANEJ) .AND. (IIF(cAlias=="AFM",AFJ->AFJ_ROTGER == "2",AFJ->AFJ_ROTGER == "1"))

				dbselectArea(cAlias)
				dbSetOrder(4) //AFM_FILIAL+AFM_PROJET+AFM_REVISA+AFM_TAREFA+AFM_TRT
				If !dbSeek(xFilial(cAlias)+ AFJ->AFJ_PROJET + PmsRevAtu(AFJ->AFJ_PROJET) + AFJ->AFJ_TAREFA + AFJ->AFJ_TRT)
					nSubtrai := 0
					// VERIFICA SE NAO EXISTE AMARRACAO DESTE MESMO EMPENHO NA PROPRIA ACOLS E SUBTRAI DO QUE AINDA RESTA
					For nX:=1 to Len(aCols)
						lAchou	:= .F.

						If aCols[nX,nPosPrj]==AFJ->AFJ_PROJET .AND. aCols[nX,nPosTrf]==AFJ->AFJ_TAREFA;
			 				.AND. aCols[nX,nPosTRT]==AFJ->AFJ_TRT .AND. aCols[nX,nPosPlan]==AFJ->AFJ_PLANEJ  .AND.;
			 				!(aCols[nX,Len(aHeader)+1]) .AND. (nX <> n)

			 				lAchou := .T.
			 			EndIf

					 	If lAchou
					 		nSubtrai += aCols[nX,nPosQuant]
						EndIf
					Next nX

					aadd(aRecsAFJ,{AFJ->(Recno()), nSubtrai})

				EndIf
				AFJ->( dbSkip() )

			else
				AFJ->( dbSkip() )
		 	EndIf
		EndDo

		If cAlias == "AFM"
			IF Aviso(STR0212,STR0211,{STR0195, STR0196},2)==1 //"Gerenciamento de Projetos"# "Deseja verificar se existe um empenho já existente e disponivel para amarração com esta OP?" #  SIM ## NAO
				cTrt := PmsUseEmp(AFJ->AFJ_PROJET,AFJ->AFJ_TAREFA,cC1Prod,cC1Local,aRecsAFJ,cAlias)

				// Verifica se possui outra amarração para o mesmo PROJ + TAREFA + SEQ.EMPENHO
				nPosReg := aScan(aCols, {|x| x[nPosPrj]==aCols[n,nPosPrj] .and. x[nPosTrf]==aCols[n,nPosTrf] .and. x[nPosTRT]==cTrt .and. !x[Len(aHeader)+1]} )

				If (nPosReg > 0) .and. (nPosReg <> n)
					aCols[n,nPosPlan] := ""
					cTRT := ""
					MSGAlert(STR0213)
				EndIf

			Endif
		Else
			IF Aviso(STR0212,STR0214,{STR0195, STR0196},2)==1 //"Gerenciamento de Projetos"# "Deseja verificar se existe um empenho já existente e disponivel para amarração com esta SC?" #  SIM ## NAO
				cTrt := PmsUseEmp(AFJ->AFJ_PROJET,AFJ->AFJ_TAREFA,cC1Prod,cC1Local,aRecsAFJ,cAlias)

				// Verifica se possui outra amarração para o mesmo PROJ + TAREFA + SEQ.EMPENHO
				nPosReg := aScan(aCols, {|x| x[nPosPrj]==aCols[n,nPosPrj] .and. x[nPosTrf]==aCols[n,nPosTrf] .and. x[nPosTRT]==cTrt .and. !x[Len(aHeader)+1]} )

				If (nPosReg > 0) .and. (nPosReg <> n)
					aCols[n,nPosPlan] := ""
					cTRT := ""
					MSGAlert(STR0213)
				EndIf

			Endif
		EndIf

	EndIf
EndIf

Return cTrt

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsUseEmp³ Autor ³ Clovis Magenta         ³ Data ³ 24-09-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de selecao de um empenho perneta na AFJ                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSXFUNA                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsUseEmp(cProjeto,cTarefa,cProduto,cLocal,aRecsAFJ,cAlias)
Local oDlg
Local aArea		:= GetArea()
Local aViewEmp	:= {}
Local aRecEmp	:= {}
Local lOk		:= .F.
Local cRetTRT 	:= SPACE(LEN(AFJ->AFJ_TRT))
Local nX		:= 0
Local nPosPlan  := 0
DEFAULT cAlias  := ""

If !empty(cAlias)
	nPosPlan := aScan(aHeader,{|x| alltrim(x[2])==cAlias+"_PLANEJ"})
endif

dbselectArea("AFJ")
dbSetOrder(1) //AFJ_FILIAL+AFJ_PROJET+AFJ_TAREFA+AFJ_COD+AFJ_LOCAL
For nX:=1 to Len(aRecsAFJ)

	DbGoTo(aRecsAFJ[nX,1])

	If (AFJ->AFJ_QEMP > (AFJ->AFJ_QATU+AFJ->AFJ_EMPEST)+aRecsAFJ[nX,2])
		aAdd(aViewEmp,{AFJ_TRT,AFJ_COD,AFJ_LOCAL,TransForm(AFJ_QEMP-aRecsAFJ[nX,2],PesqPict("AFJ","AFJ_QEMP")),TransForm(AFJ_QATU,PesqPict("AFJ","AFJ_QATU")),AFJ_DATA, AFJ_PLANEJ})
		aAdd(aRecEmp,aRecsAFJ[nX,1])
	EndIf

Next nX


If !Empty(aViewEmp) .and. (nPosPlan>0)
	DEFINE MSDIALOG oDlg FROM 85,35 to 330,610 TITLE cCadastro Of oMainWnd PIXEL
	oListBox := TWBrowse():New( 16,5,284,105,,{STR0076,STR0018,STR0077,STR0078,STR0079,STR0080},,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Seq.Empenho"###"Produto"###"Armazem"###"Qtd.Empenhada"###"Qtd.Atual"###"Dt.Necessidade"
	oListBox:SetArray(aViewEmp)
	oListBox:bLine := { || aViewEmp[oListBox:nAT]}
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk:=.T.,(cRetTRT :=aViewEmp[oListBox:nAT,1], aCols[n,nPosPlan] :=aViewEmp[oListBox:nAT,7]),oDlg:End()},{||oDlg:End()},,{{"BMPINCLUIR",{|| MaViewEmp(aRecEmp[oListBox:nAT])},STR0081}} ) //"Detalhes"
Else
	HELP("  ",1,"PMSNOEMP")
EndIf


RestArea(aArea)

Return cRetTRT

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsGetEmp³ Autor ³ Clovis Magenta         ³ Data ³ 24-09-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de alteracao de um empenho perneta com nova amarracao  ³±±
±±³          ³ou pesquisa de empenho existente na propria aCols             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSXFUNA                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsGetEmp(aColsAlias,aHeadAlias,nOpc, cAlias)

Local nEmp 		:= 0
Local nX 		:= 0
Local nSubtrai 	:= 0
Local aArea   	:= GetArea()
Local aAreaAFJ	:= AFJ->(GetArea())
Local aAreaAlias:= (cAlias)->(GetArea())
Local nPosPln 	:= aScan(aHeadAlias,{|x| alltrim(x[2])== cAlias + "_PLANEJ"})
Local nPosTRT 	:= aScan(aHeadAlias,{|x| alltrim(x[2])== cAlias + "_TRT"})
Local nPosPrj 	:= aScan(aHeadAlias,{|x| alltrim(x[2])== cAlias + "_PROJET"})
Local nPosTrf 	:= aScan(aHeadAlias,{|x| alltrim(x[2])== cAlias + "_TAREFA"})
Local nPosQtd 	:= aScan(aHeadAlias,{|x| alltrim(x[2])== cAlias + "_QUANT"})
Local lMantem   := .F.
Default aColsAlias 	 := {}
Default aHeadAlias   := {}
Default nOpc  	:= 1

If (nPosPln > 0) .and. (nPosTRT > 0 ) .and. ( nPosPrj > 0 ) .and. (nPosTrf > 0 ) .and. (nPosQtd > 0 )
	Do Case
		Case nOpc == 1 // Alterar Registro

			dbSelectarea("AFJ")
			dbsetorder(3) // AFJ_FILIAL+AFJ_PROJET+AFJ_TAREFA+AFJ_TRT
			If dbSeek(xFilial("AFJ") + aColsAlias[nPosPrj] + aColsAlias[nPosTrf] + aColsAlias[nPosTRT])
				If Alltrim(AFJ->AFJ_PLANEJ) == alltrim(aColsAlias[nPosPln]) .AND.;
					(AFJ->AFJ_QEMP > (AFJ->AFJ_QATU+AFJ->AFJ_EMPEST)) .AND.;
					 (AFJ->AFJ_QEMP - (AFJ->AFJ_QATU+AFJ->AFJ_EMPEST) >= aColsAlias[nPosQtd])

					IF (AFJ->AFJ_QEMP <> aColsAlias[nPosQtd])
						Reclock("AFJ",.F.)
							AFJ->AFJ_QEMP := AFJ->AFJ_QEMP - aColsAlias[nPosQtd]
						MsUnlock("AFJ")
					else
						lMantem := .T.
					Endif
				EndIf
			Endif

		Case nOpc == 2 // Procurar registro
			dbSelectarea("AFJ")
			dbsetorder(3) // AFJ_FILIAL+AFJ_PROJET+AFJ_TAREFA+AFJ_TRT
			If dbSeek(xFilial("AFJ") + aColsAlias[nPosPrj] + aColsAlias[nPosTrf] + aColsAlias[nPosTRT])
				nEmp :=	AFJ->AFJ_QEMP - (AFJ->AFJ_QATU+Iif(AFJ->(ColumnPos("AFJ_EMPEST")) > 0,AFJ->AFJ_EMPEST,0) )

				For nX:=1 to Len(aCols)
					lAchou	:= .F.

					If aCols[nX,nPosPrj]==AFJ->AFJ_PROJET .AND. aCols[nX,nPosTrf]==AFJ->AFJ_TAREFA;
		 				.AND. aCols[nX,nPosTRT]==AFJ->AFJ_TRT .AND. aCols[nX,nPosPln]==AFJ->AFJ_PLANEJ;
		 				.AND. !(aCols[nX,Len(aHeadAlias)+1]) .AND. (nX <> n)

		 				lAchou := .T.
		 			EndIf

				 	If lAchou
				 		nSubtrai += aCols[nX,nPosQtd]
					EndIf
				Next nX
			EndIf
	EndCase
EndIf

RestArea(aAreaAlias)
RestArea(aAreaAFJ)
RestArea(aArea)

Return Iif(nOpc == 1, lMantem, nEmp-nSubtrai)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LinDelet  ºAutor  ³Clovis Magenta      º Data ³  20/08/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se a linha do array em questão está deletada      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ All                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LinDelet(aLinha)

Local lDel := .F.
DEFAULT aLinha := {}

lDel := aLinha[Len(aLinha)]

Return lDel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LinDelet  ºAutor  ³Clovis Magenta      º Data ³  20/08/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz quase o mesmo tratamento da funcao Len(), porem esta   º±±
±±º          ³ irá retornar tamanho do array descartando linhas deletadas º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ All                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LenVal(aLinha)
Local nLen := 0
Local nX	  := 0
DEFAULT aLinha := {}

For nX:=1 to Len(aLinha)
	If !LinDelet(aLinha[nX])
		nLen++
	EndIf
Next nX

Return nLen

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSCalRest ºAutor  ³Clovis Magenta      º Data ³  16/04/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função que verifica restrição da tarefa, porem, em alguns  º±±
±±º          ³ casos, a data e hora podem ser alteradas baseadas na restr.º±±
±±º          ³ sem necessidade de dar inconsistencias de restrições 	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSCalRest(cRestr, dDtRestr, cHrRestr, aDtsTask, cCalend, nHDurac, cPrj,lMaisTarde)
Local aDtsRecalc 	:= {}
Local lRestrict  	:= !(Empty(cRestr) .and. Empty(dDtRestr) .and. Empty(cHrRestr))
Local cDataRest  	:= ""
Local cHoraRest  	:= ""
Local cStart 		:= DtoS(aDtsTask[1])
Local cFinish     := DtoS(aDtsTask[3])
Local cHorai      := Substr(aDtsTask[2],1,2)+Substr(aDtsTask[2],4,2)
Local cHoraf      := Substr(aDtsTask[4],1,2)+Substr(aDtsTask[4],4,2)

DEFAULT lMaisTarde	:= .F.
DEFAULT aDtsTask := {}

aDtsRecalc := aClone(aDtsTask)

If lRestrict
	cDataRest  := DtoS(dDtRestr)
	cHoraRest  := Substr(cHrRestr,1,2)+Substr(cHrRestr,4,2)

	Do case
		Case cRestr == "1"  // iniciar em
			// Caso o inicio oferecido pelo sistema seja MENOR que o da restriçao, fica com a data/hora restrição
			If (cStart+cHorai) <> (cDataRest+cHoraRest) .and. (cStart+cHorai) < (cDataRest+cHoraRest)
				aDtsRecalc := PMSDTaskF(StoD(cDataRest),cHrRestr,cCalend,nHDurac,cPrj,Nil)
			EndIf

		Case cRestr == "2"  // terminar em

			If (cFinish+cHoraf) <> (cDataRest+cHoraRest) .and. (cFinish+cHoraf) < (cDataRest+cHoraRest)
				aDtsRecalc := PMSDTaskI(StoD(cDataRest),cHrRestr,cCalend,nHDurac,cPrj,Nil)
			EndIf

		Case cRestr == "3"  // nao iniciar antes

	 		If (cStart+cHorai) <> (cDataRest+cHoraRest) .AND. (cStart+cHorai) < (cDataRest+cHoraRest)
				aDtsRecalc := PMSDTaskF(StoD(cDataRest),cHrRestr,cCalend,nHDurac,cPrj,Nil)
			EndIf

		Case cRestr == "4"  .and. lMaisTarde// nao iniciar Depois

	 		If (cStart+cHorai) <> (cDataRest+cHoraRest)
				aDtsRecalc := PMSDTaskF(StoD(cDataRest),cHrRestr,cCalend,nHDurac,cPrj,Nil)
			EndIf

		Case cRestr == "5"  // nao terminar antes

			If (cFinish+cHoraf) <> (cDataRest+cHoraRest) .and. (cFinish+cHoraf) < (cDataRest+cHoraRest)
				aDtsRecalc := PMSDTaskI(StoD(cDataRest),cHrRestr,cCalend,nHDurac,cPrj,Nil)
			EndIf

		Case cRestr == "5"  // nao terminar antes
			If (cFinish+cHoraf) <> (cDataRest+cHoraRest) .and. (cFinish+cHoraf) < (cDataRest+cHoraRest)
				aDtsRecalc := PMSDTaskI(StoD(cDataRest),cHrRestr,cCalend,nHDurac,cPrj,Nil)
			EndIf

		Case cRestr == "6" .and. lMaisTarde // nao terminar Depois
			If (cFinish+cHoraf) <> (cDataRest+cHoraRest) .and. (cFinish+cHoraf) > (cDataRest+cHoraRest)
				aDtsRecalc := PMSDTaskI(StoD(cDataRest),cHrRestr,cCalend,nHDurac,cPrj,Nil)
			EndIf

	EndCase

EndIf

Return aDtsRecalc


// funcao de validação de uma EDT com a restricao alterada
Function AtuTrfbyEdt(cProjeto,cRevisa,cEdtPai,nOpc,aSimulaDts,dDateRestr, cHourRestr)

Local aFilhasAF9 	:= {}
Local aFilhasAFC	:= {}
Local aAuxRet    	:= {}
Local aAtuEDT	  	:= {}
Local cDtRestr   	:= ""
Local cHrRestr   	:= ""
Local cRestricao 	:= ""
Local cHora		  	:= ""
Local cAlias	  	:= ""
Local cAliasTmp  	:= ""
Local lOk 		  	:= .T.
Local nX			  	:= 0
Local nPosTrf	  	:= 0
Local dData
Local cConcat		:= ""
Local cQuery	:= ""

DEFAULT cProjeto	:= ""
DEFAULT cRevisa  	:= ""
DEFAULT cEdtPai  	:= ""
DEFAULT aSimulaDts:= {}
DEFAULT dDateRestr:= M->AFC_DTREST
DEFAULT cHourRestr:= M->AFC_HRREST

cDtRestr   	:= DtoS(M->AFC_DTREST)
cHrRestr   	:= Substr(M->AFC_HRREST,1,2)+Substr(M->AFC_HRREST,4,2)
cRestricao 	:= cDtRestr+cHrRestr

// Define o simbolo de concatenacao de acordo com o banco de dados
If Upper( TcGetDb() ) $ "ORACLE*POSTGRES*DB2*INFORMIX"
	cConcat := "||"
Else
	cConcat	:= "+"
EndIf

If nOpc == 1    // Nao iniciar antes de

	cQuery := " SELECT AF9_TAREFA AS ENTIDADE, 'AF9' AS TPENTIDA , R_E_C_N_O_ AS REC "
	cQuery += " FROM "+ RetSqlName("AF9")
	cQuery += " WHERE AF9_START " + cConcat + " AF9_HORAI < '"+cDtRestr+M->AFC_HRREST+"' "
	cQuery += " AND AF9_START <> ' ' AND  AF9_HORAI <> ' ' "
	cQuery += " AND AF9_FILIAL = '" + xFilial("AF9") + "' "
	cQuery += " AND AF9_PROJET = '"+cProjeto+"' "
	cQuery += " AND AF9_REVISA = '"+cRevisa+"' "
	cQuery += " AND AF9_EDTPAI = '"+cEdtPai+"' "
	cQuery += " AND D_E_L_E_T_ = ' ' "

	cQuery += " UNION ALL "

	cQuery += " SELECT AFC_EDT AS ENTIDADE, 'AFC' AS TPENTIDA , R_E_C_N_O_ AS REC "
	cQuery += " FROM "+ RetSqlName("AFC")
	cQuery += " WHERE AFC_START " + cConcat + " AFC_HORAI < '"+cDtRestr+M->AFC_HRREST+"' "
	cQuery += " AND AFC_START <> ' ' AND  AFC_HORAI <> ' ' "
	cQuery += " AND AFC_FILIAL = '" + xFilial("AFC") + "' "
	cQuery += " AND AFC_PROJET = '"+cProjeto+"' "
	cQuery += " AND AFC_REVISA = '"+cRevisa+"' "
	cQuery += " AND AFC_EDTPAI = '"+cEdtPai+"' "
	cQuery += " AND D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	cAliasTmp := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasTmp, .T., .T.)

elseif nOpc == 2     // Nao terminar depois de

	cQuery := " SELECT AF9_TAREFA AS ENTIDADE, 'AF9' AS TPENTIDA , R_E_C_N_O_ AS REC"
	cQuery += " FROM "+ RetSqlName("AF9")
	cQuery += " WHERE AF9_FINISH " + cConcat + " AF9_HORAF > '"+cDtRestr+M->AFC_HRREST+"' "
	cQuery += " AND AF9_FINISH <> ' ' AND  AF9_HORAF <> ' ' "
	cQuery += " AND AF9_FILIAL = '" + xFilial("AF9") + "' "
	cQuery += " AND AF9_PROJET = '"+cProjeto+"' "
	cQuery += " AND AF9_REVISA = '"+cRevisa+"' "
	cQuery += " AND AF9_EDTPAI = '"+cEdtPai+"' "
	cQuery += " AND D_E_L_E_T_ = ' ' "

	cQuery += " UNION ALL "

	cQuery += " SELECT AFC_EDT AS ENTIDADE, 'AFC' AS TPENTIDA , R_E_C_N_O_ AS REC"
	cQuery += " FROM "+ RetSqlName("AFC")
	cQuery += " WHERE AFC_FINISH " + cConcat + " AFC_HORAF > '"+cDtRestr+M->AFC_HRREST+"' "
	cQuery += " AND AFC_FINISH <> ' ' AND  AFC_HORAF <> ' ' "
	cQuery += " AND AFC_FILIAL = '" + xFilial("AFC") + "' "
	cQuery += " AND AFC_PROJET = '"+cProjeto+"' "
	cQuery += " AND AFC_REVISA = '"+cRevisa+"' "
	cQuery += " AND AFC_EDTPAI = '"+cEdtPai+"' "
	cQuery += " AND D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	cAliasTmp := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasTmp, .T., .T.)

Endif

dbSelectArea(cAliasTmp)
(cAliasTmp)->(dbGoTop())
While (cAliasTmp)->(!Eof())

	If (cAliasTmp)->TPENTIDA == "AF9"
		aAdd(aFilhasAF9, {(cAliasTmp)->ENTIDADE , (cAliasTmp)->TPENTIDA , (cAliasTmp)->REC})
	Else
		aAdd(aFilhasAFC, {(cAliasTmp)->ENTIDADE , (cAliasTmp)->TPENTIDA , (cAliasTmp)->REC})
	Endif

	(cAliasTmp)->(dbSkip())
EndDo
   // Ordeno por tarefas e depois EDT´s
If (nOpc == 1)
	aFilhas := aSort(aFilhasAF9, , ,{ |x, y| (x[1]) < y[1] })
	aFilhas := aSort(aFilhasAFC, , ,{ |x, y| (x[1]) < y[1] })
else
	aFilhas := aSort(aFilhasAF9, , ,{ |x, y| (x[1]) > y[1] })
	aFilhas := aSort(aFilhasAFC, , ,{ |x, y| (x[1]) > y[1] })
Endif


For nX:=1 to Len(aFilhasAF9)

	dbSelectArea("AF9")
	AF9->(dbGoTo(aFilhasAF9[nX,3]))
	nPosTrf := aScan(aSimulaDts,{|x|x[1]+x[2] == "AF9" + AF9->AF9_TAREFA })
   // nOpc 1 - Nao iniciar antes de
	If (nOpc == 1) .and. ((DtoS(AF9_START)+substr(AF9_HORAI,1,2)+substr(AF9_HORAI,4,2)) < cRestricao) .and. (nPosTrf==0)

		dData := stod(substr(cRestricao,1,8))
      cHora := substr(cRestricao,9,2)+":"+substr(cRestricao,11,2)

		aAuxRet	:= PMSDTaskF(dData, cHora ,AF9->AF9_CALEND,AF9->AF9_HDURAC,AF9->AF9_PROJET,Nil)

		// se for a primeira vez, temos que validar a primeira tarefa antes de ver sua sucessora
		aAdd(aSimulaDts,{"AF9",AF9->AF9_TAREFA,aAuxRet[1],aAuxRet[2],aAuxRet[3],aAuxRet[4],AF9->AF9_HDURAC,AF9->AF9_HUTEIS,AF9->AF9_NIVEL,AF9->AF9_DTATUI,AF9->AF9_DTATUF, AF9->(RECNO())})
		nPosTrf := aScan(aSimulaDts,{|x|x[1]+x[2] == "AF9" + AF9->AF9_TAREFA })

		If (lOk := PA203VldRes(aSimulaDts, nPosTrf)) // Valida a restricao da tarefa com as datas e horas novas
			lOk := PmsSimScs(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,, @aAtuEDT,, @aSimulaDts) // verifica suas sucessoras
			lOk := PA201VldPrd("I", aSimulaDts, "AF9")

			If aScan(aAtuEDT,AF9->AF9_EDTPAI) <= 0
				aAdd(aAtuEDT,AF9->AF9_EDTPAI)
			EndIf
		EndIf

		If !lOk
			Exit
		EndIf

   // nOpc 2 - Nao terminar depois de
	elseif (nOpc == 2) .and. ((DtoS(AF9_FINISH)+substr(AF9_HORAF,1,2)+substr(AF9_HORAF,4,2)) > cRestricao) .and. (nPosTrf==0)

		dData := stod(substr(cRestricao,1,8))
      cHora := substr(cRestricao,9,2)+":"+substr(cRestricao,11,2)
      // calcula novas datas e horas para a tarefa
		aAuxRet	:= PMSDTaskI(dData, cHora ,AF9->AF9_CALEND,AF9->AF9_HDURAC,AF9->AF9_PROJET,Nil)

		// se for a primeira vez, temos que validar a primeira tarefa antes de ver sua sucessor
		aAdd(aSimulaDts,{"AF9",AF9->AF9_TAREFA,aAuxRet[1],aAuxRet[2],aAuxRet[3],aAuxRet[4],AF9->AF9_HDURAC,AF9->AF9_HUTEIS,AF9->AF9_NIVEL,AF9->AF9_DTATUI,AF9->AF9_DTATUF, AF9->(RECNO())})
		nPosTrf := aScan(aSimulaDts,{|x|x[1]+x[2] == "AF9" + AF9->AF9_TAREFA })

		If (lOk := PA203VldRes(aSimulaDts, nPosTrf)) // Valida a restricao da tarefa com as datas e horas novas
			lOk := PA201BakPrd(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,, @aAtuEDT,, @aSimulaDts, nPosTrf)
		EndIf

		If !lOk
			Exit
		EndIf

	Endif
Next nX

For nX:=1 to Len(aFilhasAFC)

	// NO CASO DE SER UMA EDT FILHA, BASTA FAZER A RECURSIVIDADE DESTA FUNCAO COM A MESMA DATA E HORA RESTRICAO
	dbSelectArea("AFC")
	AFC->(dbGoTo(aFilhasAFC[nX,3]))
  	nPosTrf := aScan(aSimulaDts,{|x|x[1]+x[2] == "AFC" + AFC->AFC_EDT })

	If (nPosTrf==0)
		// Recursividade na EDT filha para atualizar as Tarefas filhas.
		AtuTrfbyEdt(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT, nOpc, @aSimulaDts, dDateRestr, cHourRestr)
	EndIf

Next nX

If lOk
	For nX:=1 to Len(aSimulaDts)
		cAlias := aSimulaDts[nX,1]
		If cAlias=="AF9"
			dbSelectArea(cAlias)
			dbGoTo(aSimulaDts[nX,SIM_RECNO])
			Reclock(cAlias , .F.)
				(cAlias)->(AF9_START)  := aSimulaDts[nX,SIM_START]
				(cAlias)->(AF9_HORAI)  := aSimulaDts[nX,SIM_HORAI]
				(cAlias)->(AF9_FINISH) := aSimulaDts[nX,SIM_FINISH]
				(cAlias)->(AF9_HORAF)  := aSimulaDts[nX,SIM_HORAF]
			MsUnlock(cAlias)
			If aScan(aAtuEDT,AF9->AF9_EDTPAI) <= 0
				aAdd(aAtuEDT,AF9->AF9_EDTPAI)
			EndIf

		ElseIf cAlias == "AFC"

			dbSelectArea(cAlias)
			dbGoTo(aSimulaDts[nX,SIM_RECNO])
			Reclock(cAlias , .F.)
				(cAlias)->(AFC_START)  := aSimulaDts[nX,SIM_START]
				(cAlias)->(AFC_HORAI)  := aSimulaDts[nX,SIM_HORAI]
				(cAlias)->(AFC_FINISH) := aSimulaDts[nX,SIM_FINISH]
				(cAlias)->(AFC_HORAF)  := aSimulaDts[nX,SIM_HORAF]
			MsUnlock(cAlias)

			If aScan(aAtuEDT,AFC->AFC_EDTPAI) <= 0
				aAdd(aAtuEDT,AFC->AFC_EDTPAI)
			EndIf

		EndIf
	Next nX
EndIf


If M->AFC_EDT == AFC->AFC_EDT
	For nX:=1 To Len(aAtuEDT)
		PmsAtuEDT(AF8->AF8_PROJET,AF8->AF8_REVISA,aAtuEDT[nX])
	Next nX
	IF Type("lEDTRest")<>"U"
// Caso .T. é sinal que os campos da EDT ja foram atualizados e
// nao deverão ser atualizados na funcao PMS201Grava()
		lEDTRest := .T.
	Endif
Endif

(cAliasTmp)->(dbCloseArea())

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³P203SimPrd³ Autor ³ Clovis Magenta  		  ³ Data ³ 24/09/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a atualizacao das datas das tarefas de acordo com as  ³±±
±±³          ³suas predecessoras de tras para frente (mais tarde possivel)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function P203SimPrd(cProjeto,cRevisa,cTarefa,lAtuEDT,aAtuEDT,lReprParc,aBaseDados,lMemoria)

Local cHoraF
Local aAuxRet
Local dFinish
Local cCalend
Local nHDurac
Local aArea		:= GetArea()
Local aAreaAFC	:= AFC->(GetArea())
Local aAreaAJ4	:= AJ4->(GetArea())
Local aAreaAFD	:= AFD->(GetArea())
Local aAreaAF9	:= AF9->(GetArea())
Local dStart	:= PMS_MIN_DATE
Local cHoraI	:= "00:00"
Local nPosBase
Local dDtAtuI
Local dDtAtuF
Local nPriori	  := 0

DEFAULT lAtuEDT	:= .T.
DEFAULT aAtuEDT	:= {}
DEFAULT lReprParc := .F.
DEFAULT lMemoria 	:= .F.

dbSelectArea("AFC")
dbSetOrder(1)

dbSelectArea("AF9")
dbSetOrder(1)
MsSeek(xFilial("AF9")+cProjeto+cRevisa+cTarefa)
nRecAF9	:= RecNo()
If lMemoria
	cCalend	:= M->AF9_CALEND
	nHDurac	:= M->AF9_HDURAC
	cRestricao := M->AF9_RESTRI
	dDataRest  := M->AF9_DTREST
	cHrRest    := M->AF9_HRREST
	dDtAtuI	  := M->AF9_DTATUI
	dDtAtuF	  := M->AF9_DTATUF
	nPriori	  := M->AF9_PRIORI
Else
	cCalend	:= AF9->AF9_CALEND
	nHDurac	:= AF9->AF9_HDURAC
	cRestricao := AF9->AF9_RESTRI
	dDataRest  := AF9->AF9_DTREST
	cHrRest    := AF9->AF9_HRREST
	dDtAtuI	  := AF9->AF9_DTATUI
	dDtAtuF	  := AF9->AF9_DTATUF
	nPriori	  := AF9->AF9_PRIORI
Endif
If ( Empty(dDtAtuI) .Or. lReprParc ) .And. Empty(dDtAtuF) .And. (nPriori < 1000)
	dbSelectArea("AFD")
	dbSetOrder(2) //AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA+AFD_ITEM
	MsSeek(xFilial("AFD")+cProjeto+cRevisa+cTarefa)
	While (!Eof() .And. xFilial("AFD")+cProjeto+cRevisa+cTarefa==;
		AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_PREDEC)

		nPosBase := aScan(aBaseDados,{|x|x[1]+x[2] == "AF9" + AFD->AFD_TAREFA })
		If nPosBase == 0
			nPosBase := getPosArry(aBaseDados,"AF9",AFD->AFD_TAREFA)
		EndIf

 		AF9->(DbGoto(nRecAF9))
		Do Case
			Case AFD->AFD_TIPO=="1" //Fim no Inicio
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := P203ADDHrs(aBaseDados[nPosBase,SIM_FINISH],aBaseDados[nPosBase,SIM_HORAF],AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSCalRest(cRestricao, dDataRest, cHrRest ,aAuxRet,cCalend,nHDurac,AF9->AF9_PROJET, .T.)
				Else
					aAuxRet := PMSDTaskI(aBaseDados[nPosBase,SIM_START],aBaseDados[nPosBase,SIM_HORAI],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSCalRest(cRestricao, dDataRest, cHrRest ,aAuxRet,cCalend,nHDurac,AF9->AF9_PROJET, .T.)
				EndIf
			Case AFD->AFD_TIPO=="2" //Inicio no Inicio
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := P203ADDHrs(aBaseDados[nPosBase,SIM_START],aBaseDados[nPosBase,SIM_HORAI],AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskF(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskF(aBaseDados[nPosBase,SIM_START],aBaseDados[nPosBase,SIM_HORAI],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				EndIf
			Case AFD->AFD_TIPO=="3" //Fim no Fim
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(aBaseDados[nPosBase,SIM_FINISH],aBaseDados[nPosBase,SIM_HORAF],AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskI(aBaseDados[nPosBase,SIM_FINISH],aBaseDados[nPosBase,SIM_HORAF],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				EndIf
			Case AFD->AFD_TIPO=="4" //Inicio no Fim
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(aBaseDados[nPosBase,SIM_START],aBaseDados[nPosBase,SIM_HORAI],AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskI(aBaseDados[nPosBase,SIM_START],aBaseDados[nPosBase,SIM_HORAI],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				EndIf
		EndCase
		If  (aAuxRet[1]==dStart.And.SubStr(aAuxRet[2],1,2)+SubStr(aAuxRet[2],4,2)>SubStr(cHoraI,1,2)+SubStr(cHoraI,4,2)).Or.;
			(aAuxRet[1] > dStart)
			dStart := aAuxRet[1]
			cHoraI := aAuxRet[2]
			dFinish:= aAuxRet[3]
			cHoraF := aAuxRet[4]
		EndIf

		nPosBase := getPosArry(aBaseDados,"AF9",cTarefa)
		aBaseDados[nPosBase,SIM_START]	 := dStart
		aBaseDados[nPosBase,SIM_HORAI]	 := cHoraI
		aBaseDados[nPosBase,SIM_FINISH]	 := dFinish
		aBaseDados[nPosBase,SIM_HORAF]	 := cHoraF
		AFD->(dbSkip())
	End

	If lMemoria
		If lAtuEDT .Or. (!Empty(M->AF9_EDTPAI) .And. AJ4->(MsSeek(xFilial("AJ4")+M->AF9_PROJET+M->AF9_REVISA+M->AF9_EDTPAI)))
			PmsSimEDT(M->AF9_PROJET,M->AF9_REVISA,M->AF9_EDTPAI,aAtuEDT,.T.)
		Else
			If aScan(aAtuEDT,M->AF9_EDTPAI) <= 0
				aAdd(aAtuEDT,M->AF9_EDTPAI)
			EndIf
		EndIf
	Else
		If lAtuEDT .Or. (!Empty(AF9->AF9_EDTPAI) .And. AJ4->(MsSeek(xFilial("AJ4")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_EDTPAI)))
			PmsSimEDT(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_EDTPAI,aAtuEDT,.T.)
		Else
			If aScan(aAtuEDT,AF9->AF9_EDTPAI) <= 0
				aAdd(aAtuEDT,AF9->AF9_EDTPAI)
			EndIf
		EndIf
	EndIf

ELSE

	If lAtuEDT .Or. (!Empty(AF9->AF9_EDTPAI) .And. AJ4->(MsSeek(xFilial("AJ4")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_EDTPAI)))
		PmsSimEDT(AF9_PROJET,AF9_REVISA,AF9_EDTPAI,aAtuEDT,.T.)
	Else
		If aScan(aAtuEDT,AF9->AF9_EDTPAI) <= 0
			aAdd(aAtuEDT,AF9->AF9_EDTPAI)
		EndIf
	EndIf

EndIf

RestArea(aAreaAFC)
RestArea(aAreaAF9)
RestArea(aAreaAJ4)
RestArea(aAreaAFD)
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³P203ADDHrs³ Autor ³ Clovis Magenta        ³ Data ³ 21-09-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a soma ou a subtracao um numero de horas a uma data   ³±±
±±³          ³de acordo com o calendario.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpD1 : Data de Referencia                                    ³±±
±±³          ³ExpC2 : Hora Referencia("XX:XX")                              ³±±
±±³          ³ExpC3 : Calendario                                            ³±±
±±³          ³ExpN4 : Numero de Horas a Adicionar/Subtrair                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA203                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function P203ADDHrs(dData,cHora,cCalend,nAddHrs,cProjeto,cRecurso)
Local aAuxRet

aAuxRet := PMSDTaskI(dData,cHora,cCalend,(nAddHrs*-1),cProjeto,cRecurso)
dData	:= aAuxRet[3]
cHora	:= aAuxRet[4]

Return {dData,cHora}


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³P203SimE  ³ Autor ³ Clovis Magenta			³ Data ³ 25/09/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a atualizacao das datas das tarefas Sucessoras. No Arra³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function P203SimE(cProjeto,cRevisa,cTarefa,lAtuEDT, aAtuEDT,lReprParc,aBaseDados,aColsRel)

Local aArea		:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAFD	:= AFD->(GetArea())
Local nPosBase	:= 0
Local lRet 		:= .T.
Local lP203Auto:= iIf(Type("lPMS203Auto") == "L",lPMS203Auto, .F.)
DEFAULT lAtuEDT	:= .T.
DEFAULT aAtuEDT	:= {}
DEFAULT aColsRel  := {}

If lP203Auto == .T.

	dbSelectArea("AJ4")
	dbSetOrder(1)
	MsSeek(xFilial("AJ4")+cProjeto+cRevisa+cTarefa)  // verifica se alguma tarefa depende desta EDT
	While !Eof() .And. xFilial("AJ4")+cProjeto+cRevisa+cTarefa==;
		AJ4_FILIAL+AJ4_PROJET+AJ4_REVISA+AJ4_TAREFA .and. lRet

		PmsSimPrd(AJ4->AJ4_PROJET,AJ4->AJ4_REVISA,AJ4->AJ4_TAREFA,lAtuEDT,@aAtuEDT,lReprParc,@aBaseDados)

		// Busco registro da tarefa que terá novas datas e horas
		nPosBase := aScan(aBaseDados,{|x|x[1]+x[2] == "AF9" + AJ4->AJ4_TAREFA })

		If !(lRet := PA203VldRes(aBaseDados, nPosBase))
			Exit
		EndIf

		AJ4->(dbSkip())
	EndDo

elseif LenVal(aColsRel)>0

	dbSelectArea("AJ4")
	dbSetOrder(1)
	MsSeek(xFilial("AJ4")+cProjeto+cRevisa+cTarefa)  // verifica se alguma tarefa depende desta EDT
	While !Eof() .And. xFilial("AJ4")+cProjeto+cRevisa+cTarefa==;
		AJ4_FILIAL+AJ4_PROJET+AJ4_REVISA+AJ4_TAREFA .and. lRet

		PmsSimPrd(AJ4->AJ4_PROJET,AJ4->AJ4_REVISA,AJ4->AJ4_TAREFA,lAtuEDT,@aAtuEDT,lReprParc,@aBaseDados)

		// Busco registro da tarefa que terá novas datas e horas
		nPosBase := aScan(aBaseDados,{|x|x[1]+x[2] == "AF9" + AJ4->AJ4_TAREFA })

		If !(lRet := PA203VldRes(aBaseDados, nPosBase))
			Exit
		EndIf

		AJ4->(dbSkip())
	EndDo

EndIf

RestArea(aAreaAFD)
RestArea(aAreaAF9)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsAPVQtL ºAutor  ³Clovis Magenta      º Data ³  21/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao utilizada para validar a quantidade a ser liberada  º±±
±±º          ³ de um PV no PMS. Funcao praticamente igual a A440Qtdl do   º±±
±±º          ³ fonte fatxfun para tratamento do faturamento           	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PmsAvalEvent                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAPVQtL(nQtdLib)

Local aArea 	 := getArea()
Local aTam      := TamSX3("C6_QTDVEN")
Local cLote     := ""
Local cProduto  := ""
Local cLocal    := ""
Local cItem     := ""
Local cGrade    := ""
Local cReserv   := ""
Local cLoteCtl  := ""
Local cLocaliza := ""
Local cNumSerie := ""
Local cProjeto  := ""
Local cTarefa   := ""
Local cServico  := ""
Local cAlias    := Alias()
Local nSaldo    := 0
Local nQtdRese  := 0
Local nQtdEnt   := 0
Local nQtdVen   := 0
Local lPmsInt:=IsIntegTop(,.T.)
Local lRsDoFAt  := IIF(SuperGetMv("MV_RSDOFAT") == "S",.F.,.T.)
Local lBloq     := .F.
Local lGrade    := MaGrade()


SC5->(dbSetOrder(1))
SC5->(MsSeek(xFilial("SC5")+SC6->C6_NUM))

If ALLTRIM(SC6->C6_BLQ) $ "RS"
	lBloq := .T.
Endif
cItem 	:= SC6->C6_ITEM
cProduto := SC6->C6_PRODUTO
cLocal 	:= SC6->C6_LOCAL
cLote 	:= SC6->C6_NUMLOTE
cLoteCtl := SC6->C6_LOTECTL
cLocaliza:= SC6->C6_LOCALIZ
cNumSerie:= SC6->C6_NUMSERI
nQtdVen 	:= SC6->C6_QTDVEN
nQtdEnt 	:= SC6->C6_QTDENT
cGrade 	:= SC6->C6_GRADE
cTes 		:= SC6->C6_TES
cReserv 	:= SC6->C6_RESERVA
cProjeto := SC6->C6_PROJPMS
cTarefa 	:= SC6->C6_TASKPMS
cServico	:= SC6->C6_SERVIC

If ( lBloq .And. lRsDoFat .and. nQtdLib > 0  )
	Help(" ",1,"A410ELIM")
	Return .F.
Endif

If SuperGetMv("MV_LIBACIM") .And. nQtdLib > 0
	If ( INCLUI )
		If Round(nQtdLib,aTam[2]) > Round(nQtdVen,aTam[2])
			HELP(" ",1,"A440QTDL")
			Return .F.
		EndIf
	Endif
	If !lGrade  .Or. cGrade <> "S"
		dbSelectArea("SC6")
		dbSetOrder(1)
		MsSeek(xFilial("SC6")+SC5->C5_NUM+cItem)
		If Found() .And. Round(nQtdLib,aTam[2]) > Round(SC6->C6_QTDVEN - (SC6->C6_QTDEMP+SC6->C6_QTDENT),aTam[2])
			HELP(" ",1,"A440QTDL")
			Return .F.
		Endif
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso movimente Estoque em Quantidade                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF4")
dbSetOrder(1)
MsSeek(xFilial("SF4")+cTes)

// If ( SF4->F4_ESTOQUE == "S" .And. !(SC5->C5_TIPO$"CIP") .And. !Empty(cReserv) )
If ( IIf( lPmsInt, .T., (SF4->F4_ESTOQUE == "S")) .And. !(SC5->C5_TIPO$"CIP") .And. !Empty(cReserv) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validacao para Reserva                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( INCLUI )
		dbSelectArea("SC0")
		dbSetOrder(1)
		If ( MsSeek(xFilial("SC0")+cReserv+cProduto+cLocal) )
			nQtdRese := Min(SC0->C0_QUANT,nQtdVen)
		EndIf
	Else
		dbSelectArea("SC6")
		dbSetOrder(1)
		If ( MsSeek(xFilial("SC6")+SC5->C5_NUM+cItem+cProduto,.F.) )
			If ( cReserv == SC6->C6_RESERVA )
				nQtdRese := Min(SC6->C6_QTDRESE,nQtdLib)
			Else
				dbSelectArea("SC0")
				dbSetOrder(1)
				If ( MsSeek(xFilial("SC0")+cReserv+cProduto+cLocal) )
					nQtdRese := Min(SC0->C0_QUANT,nQtdVen)
				EndIf
			EndIf
		EndIf
	EndIf
	If ( NoRound(nQtdLib,aTam[2]) > NoRound(nQtdRese,aTam[2]) )
		Help(" ",1,"A440RESE01",,Str(nQtdRese),03,20)
		Return(.F.)
	EndIf
Else
//	If ((Rastro(cProduto) .Or. Localiza(cProduto)) .And. !(SC5->C5_TIPO $ "CIP") .And. SF4->F4_ESTOQUE == "S" ) .And. SuperGetMv("MV_GERABLQ")=="N"
If ((Rastro(cProduto) .Or. Localiza(cProduto)) .And. !(SC5->C5_TIPO $ "CIP") .And. IIf( lPmsInt, .T., (SF4->F4_ESTOQUE == "S")) ) .And. SuperGetMv("MV_GERABLQ")=="N"
		nSaldo := SldAtuEst(cProduto,cLocal,nQtdLib,cLoteCtl,cLote,cLocaliza,cNumSerie,cReserv,SF4->F4_PODER3<>"N" .Or. (SF4->(ColumnPos("F4_TESP3"))<>0 .And. !Empty(SF4->F4_TESP3)),NIL,cProjeto,cTarefa,cServico)
		dbSelectArea("SC6")
		dbSetOrder(1)
		If ( MsSeek(xFilial("SC6")+SC5->C5_NUM+cItem+cProduto,.F.) )
			nSaldo += SC6->C6_QTDEMP
		EndIf
		If ( nSaldo < nQtdLib )
			If ( Localiza(cProduto) )
				Help(" ",1,"SALDOLOCLZ")
				Return(.F.)
			EndIf
			If ( Rastro(cProduto) )
				Help(" ",1,"A440ACILOT")
				Return(.F.)
			EndIf
		EndIf
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ S¢ permitir alterar a quantidade quando esta for maior que a ³
//³ quantidade entregue, somente para outros paises...           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc <> "BRA"
	If nQtdLib < nQtdEnt
		Help(" ",1,"CANTRESERV")
		Return(.F.)
	EndIf
EndIf
dbSelectArea(cAlias)

RestArea(aArea)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³PmsFerram    ³ Autor ³ Totvs                 ³ Data ³ 15.07.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Calcula o valor de ferramenta que deve agregar a composicao   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PmsFerram( cCompos, cProjet, cRevisa )
	Local nValor	:= 0
	Local nProduc   := 0
	Local nDecCst   := TamSX3( "AJT_CUSTO" )[2]

	DbSelectArea( "AJT" )
	AJT->( DbSetOrder( 1 ) )
	If AJT->( DbSeek( xFilial( "AJT" ) + cCompos + cProjet + cRevisa ) )
		If AJT->AJT_TIPO == "1"
			nProduc := AJT->AJT_PRODUC
		EndIf

		DbSelectArea( "AJU" )
		AJU->( DbSetOrder( 2 ) )
		AJU->( DbSeek( xFilial( "AJU" ) + cProjet + cRevisa + cCompos ) )
		While AJU->( !Eof() ) .AND. AJU->( AJU_FILIAL + AJU_PROJET + AJU_REVISA + AJU_COMPUN ) == xFilial( "AJU" ) + cProjet + cRevisa + cCompos
			DbSelectArea( "AJY" )
			AJY->( DbSetOrder( 1 ) )
			If AJY->( DbSeek( xFilial( "AJY" ) + cProjet + cRevisa + AJU->AJU_INSUMO ) )
				If AJY->AJY_GRORGA == "B"
					nValor += pmsTrunca( "2", ( AJY->AJY_CUSTD * AJU->AJU_QUANT / nProduc ), nDecCst )
				EndIf
			EndIf

			AJU->( DbSkip() )
		End
	EndIf

Return nValor

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSChkNec ³ Autor ³ Marcelo Akama         ³ Data ³ 08/10/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se os insumos estao vinculados com produtos ou se   ³±±
±±³          ³ pode gerar necessidade sem produtos vinculados               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProjet                                                      ³±±
±±³          ³ cRevisa                                                      ³±±
±±³          ³ cTarefa                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSChkNec(cProjet,cRevisa,cTarefa)
Local aArea    := GetArea()
Local aAreaAEL := AEL->( GetArea() )
Local aAreaAEM := AEM->( GetArea() )
Local aAreaAEN := AEN->( GetArea() )
Local aAreaAJY := AJY->( GetArea() )
Local aInsumos := {}
Local lRet     := .T.
Local nX

DbSelectArea( "AJY" )
AJY->( DbSetOrder( 1 ) )
DbSelectArea( "AEL" )
AEL->( DbSetOrder( 1 ) )
AEL->( DbSeek( xFilial( "AEL" ) + cProjet + cRevisa + cTarefa ) )
Do While AEL->( !Eof() ) .And. AEL->( AEL_FILIAL + AEL_PROJET + AEL_REVISA + AEL_TAREFA ) == xFilial( "AEL" ) + cProjet + cRevisa + cTarefa

	If AEL->AEL_GRORGA=='E'
		If aScan( aInsumos, AEL->AEL_INSUMO ) == 0
			aAdd( aInsumos, AEL->AEL_INSUMO )
		EndIf
	ElseIf AEL->AEL_GRORGA=='A'
		DbSelectArea( "AEM" )
		AEM->( DbSetOrder( 2 ) )
		AEM->( DbSeek( xFilial( "AEM" ) + cProjet + cRevisa + AEL->AEL_INSUMO ) )
		Do While AEM->( !Eof() ) .AND. AEM->( AEM_FILIAL + AEM_PROJET + AEM_REVISA + AEM_INSUMO ) == xFilial( "AEM" ) + cProjet + cRevisa + AEL->AEL_INSUMO
			If !Empty( AEM->AEM_SUBINS )
				AJY->( DbSeek( xFilial( "AJY" ) + cProjet + cRevisa + AEM->AEM_SUBINS ) )
				If AJY->(Eof()) .Or. AJY->AJY_GRORGA=='E'
					If aScan( aInsumos, AEM->AEM_SUBINS ) == 0
						aAdd( aInsumos, AEM->AEM_SUBINS )
					EndIf
				EndIf
			EndIf
			AEM->( DbSkip() )
		EndDo
	EndIf
	AEL->(dbSkip())
EndDo

DbSelectArea( "AEN" )
AEN->( DbSetOrder( 1 ) )
AEN->( DbSeek( xFilial( "AEN" ) + cProjet + cRevisa + cTarefa ) )
Do While AEN->( !Eof() ) .And. AEN->( AEN_FILIAL + AEN_PROJET + AEN_REVISA + AEN_TAREFA ) == xFilial( "AEN" ) + cProjet + cRevisa + cTarefa
	PMSChkNecS(cProjet,cRevisa,AEN->AEN_SUBCOM,@aInsumos)
	AEN->( DbSkip() )
EndDo

DbSelectArea( "AJY" )
AJY->( DbSetOrder( 1 ) )
For nX := 1 to len(aInsumos)
	If AJY->( DbSeek( xFilial( "AJY" ) + cProjet + cRevisa + aInsumos[nX] ) )
		If empty(AJY->AJY_PRODUT)
			lRet := .F.
		EndIf
	EndIf
Next nX

If !lRet
	lRet := MsgYesNo( STR0231 +chr(13)+chr(10)+STR0232 ) //"Existem insumos sem vinculo com produto."
														//	"Confirma a geracao do planejamento?"
EndIf

RestArea( aAreaAEL )
RestArea( aAreaAEM )
RestArea( aAreaAEN )
RestArea( aAreaAJY )
RestArea( aArea )

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSChkNecS³ Autor ³ Marcelo Akama         ³ Data ³ 08/10/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se os insumos estao vinculados com produtos ou se   ³±±
±±³          ³ pode gerar necessidade sem produtos vinculados               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProjet                                                      ³±±
±±³          ³ cRevisa                                                      ³±±
±±³          ³ cCompUn                                                      ³±±
±±³          ³ aInsumos                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PMSChkNecS(cProjet,cRevisa,cCompUn,aInsumos)
Local aArea    := GetArea()
Local aAreaAJT := AJT->( GetArea() )
Local aAreaAJU := AJU->( GetArea() )
Local aAreaAJX := AJX->( GetArea() )

DbSelectArea( "AJT" )
AJT->( DbSetOrder( 2 ) )

If AJT->( DbSeek( xFilial( "AJT" ) + cProjet + cRevisa + cCompUn ) )

	//Insumos da composicao

	DbSelectArea( "AJU" )
	AJU->( DbSetOrder( 3 ) )
	AJU->( DbSeek( xFilial( "AEL" ) + cProjet + cRevisa + AJT->AJT_COMPUN ) )
	Do While AJU->( !Eof() ) .And. AJU->( AJU_FILIAL + AJU_PROJET + AJU_REVISA + AJU_COMPUN ) == xFilial( "AJU" ) + cProjet + cRevisa + AJT->AJT_COMPUN

		If AJU->AJU_GRORGA=='E'

			If aScan( aInsumos, AJU->AJU_INSUMO ) == 0
				aAdd( aInsumos, AJU->AJU_INSUMO )
			EndIf

		ElseIf AJU->AJU_GRORGA=='A'

			DbSelectArea( "AEM" )
			AEM->( DbSetOrder( 2 ) )
			AEM->( DbSeek( xFilial( "AEM" ) + cProjet + cRevisa + AJU->AJU_INSUMO ) )
			Do While AEM->( !Eof() ) .AND. AEM->( AEM_FILIAL + AEM_PROJET + AEM_REVISA + AEM_INSUMO ) == xFilial( "AEM" ) + cProjet + cRevisa + AJU->AJU_INSUMO
				If !Empty( AEM->AEM_SUBINS )
					AJY->( DbSeek( xFilial( "AJY" ) + cProjet + cRevisa + AEM->AEM_SUBINS ) )
					If AJY->(Eof()) .Or. AJY->AJY_GRORGA=='E'
						If aScan( aInsumos, AEM->AEM_SUBINS ) == 0
							aAdd( aInsumos, AEM->AEM_SUBINS )
						EndIf
					EndIf
				EndIf
				AEM->( DbSkip() )
			EndDo
		EndIf
		DbSelectArea( "AJU" )
		AJU->(dbSkip())
	EndDo

	// Subcomposicoes da composicao
	DbSelectArea( "AJX" )
	AJX->( DbSetOrder( 4 ) )
	AJX->( DbSeek( xFilial( "AJX" ) + cProjet + cRevisa + AJT->AJT_COMPUN ) )
	Do While AJX->( !Eof() ) .And. AJX->( AJX_FILIAL + AJX_PROJET + AJX_REVISA + AJX_COMPUN ) == xFilial( "AJX" ) + cProjet + cRevisa + AJT->AJT_COMPUN
		PMSChkNecS(cProjet,cRevisa,AJX->AJX_SUBCOM,@aInsumos)
		dbSelectArea("AJX")
		AJX->( DbSkip() )
	EndDo
EndIf

RestArea( aAreaAJT )
RestArea( aAreaAJU )
RestArea( aAreaAJX )
RestArea( aArea )
Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSChkNIns³ Autor ³ Marcelo Akama         ³ Data ³ 08/10/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se pode gerar necessidade para o insumo             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProjet                                                      ³±±
±±³          ³ cRevisa                                                      ³±±
±±³          ³ cInsumo                                                      ³±±
±±³          ³ dDataRef                                                     ³±±
±±³          ³ cLocPad                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSChkNIns(cProjet,cRevisa,cInsumo,dDataRef,cLocPad)
Local aArea    := GetArea()
Local aAreaAJY := AJY->( GetArea() )
Local aAreaSB1 := SB1->( GetArea() )
Local lRet     := .F.
Local lAux

DbSelectArea( "AJY" )
AJY->( DbSetOrder( 1 ) )
If AJY->( DbSeek( xFilial( "AJY" ) + cProjet + cRevisa + cInsumo ) )
	// desconsidera o produto associado ao recurso
	// somente gerar necessidade para insumos do grupo orgao E

	If Empty(AJY->AJY_RECURS) .And. AJY->AJY_GRORGA $ "E" .And. !Empty(AJY->AJY_PRODUT)
		DbSelectArea( "SB1" )
		SB1->( DbSetOrder( 1 ) )
		If SB1->(MsSeek(xFilial("SB1")+AJY->AJY_PRODUT))
			If SB1->B1_GRUPO >= M->AFK_GRPDE .And. SB1->B1_GRUPO <= M->AFK_GRPATE .And. ;
					AJY->AJY_PRODUT >= M->AFK_PRDDE .And. AJY->AJY_PRODUT <= M->AFK_PRDATE .And. ;
					dDataRef >= M->AFK_DATAI .And. dDataRef <= M->AFK_DATAF
				If !RegistroOK("SB1",.F.)
					HELP("",1,"REGBLOQ",,ALLTRIM(AJY->AJY_PRODUT) +" - "+ ALLTRIM(SB1->B1_DESC) +CRLF+ STR0207,3,1)
	    		Else
					If ExistBlock("PMS220FL")
						lAux := !ExecBlock("PMS220FL",.F.,.F.)
					Else
						lAux := .T.
					EndIf
					If lAux .And. SB1->B1_TIPO != "BN" .And. SB1->B1_TIPO != "MO"
						cLocPad	:= If(Empty(AF8->AF8_LOCPAD),RetFldProd(SB1->B1_COD,"B1_LOCPAD"),AF8->AF8_LOCPAD)
						If ExistBlock("PMS220LOC")
						     aNewLoc := ExecBlock("PMS220LOC",.F.,.F.,{cLocPad})
						     If ValType(aNewLoc)=="A" .AND. ValType(aNewLoc[1])=="C"
						     	cLocPad := aNewLoc[1]
						     EndIf
						EndIf
                        lRet := .T.
      				EndIf
      			EndIf
      		EndIf
      	EndIf
	EndIf
EndIf

RestArea( aAreaSB1 )
RestArea( aAreaAJY )
RestArea( aArea )

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSNecIns ³ Autor ³ Marcelo Akama         ³ Data ³ 09/10/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Popula array de insumos                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProjet                                                      ³±±
±±³          ³ cRevisa                                                      ³±±
±±³          ³ cInsumo                                                      ³±±
±±³          ³ nQuant                                                       ³±±
±±³          ³ nQtSegu                                                      ³±±
±±³          ³ nHrProd                                                      ³±±
±±³          ³ dDataRef                                                     ³±±
±±³          ³ dDataNec                                                     ³±±
±±³          ³ aInsumos                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSNecIns(cProjet,cRevisa,cInsumo,nQuant,nQtSegu,nHrProd,dDataRef,dDataNec,aInsumos)
Local aArea    := GetArea()
Local aAreaAJY := AJY->( GetArea() )
Local aAreaAEM := AEM->( GetArea() )
Local lRet     := .F.
Local cLocPad
Local nQtd1
Local nQtd2
Local cProduto

If AJY->( DbSeek( xFilial( "AJY" ) + cProjet + cRevisa + cInsumo ) )

	If AJY->AJY_GRORGA=='E'

		cProduto := AJY->AJY_PRODUT

		If PMSChkNIns(cProjet, cRevisa, cInsumo, dDataRef, @cLocPad)

			nQtd1 := nQuant
			nQtd2 := nQtSegu

			nPos   := aScan( aInsumos, { |x| x[1] == cInsumo .And. x[2] == dDataNec } )
			If nPos > 0
				aInsumos[nPos,4] += nQtd1
				aInsumos[nPos,5] += nQtd2
			Else
				aAdd( aInsumos, { cInsumo, dDataNec, cLocPad, nQtd1, nQtd2, cProduto } )
			EndIf

			lRet := .T.

		EndIf

	ElseIf AJY->AJY_GRORGA=='A'

		DbSelectArea( "AEM" )
		AEM->( DbSetOrder( 2 ) )
		AEM->( DbSeek( xFilial( "AEM" ) + cProjet + cRevisa + cInsumo ) )
		Do While AEM->( !Eof() ) .AND. AEM->( AEM_FILIAL + AEM_PROJET + AEM_REVISA + AEM_INSUMO ) == xFilial( "AEM" ) + cProjet + cRevisa + cInsumo
			If !Empty( AEM->AEM_SUBINS ) .And. PMSChkNIns(cProjet, cRevisa, AEM->AEM_SUBINS, dDataRef, @cLocPad)

				If AJY->( DbSeek( xFilial( "AJY" ) + cProjet + cRevisa + AEM->AEM_SUBINS ) )
					cProduto := AJY->AJY_PRODUT
				Else
					cProduto := ''
				EndIf

				nQtd1	:= nQuant  * nHrProd * AEM->AEM_QUANT
				nQtd2	:= nQtSegu * nHrProd * AEM->AEM_QUANT

				nPos := aScan( aInsumos, { |x| x[1] == AEM->AEM_SUBINS .And. x[2] == dDataNec } )
				If nPos > 0
					aInsumos[nPos,4] += nQtd1
					aInsumos[nPos,5] += nQtd2
				Else
					aAdd( aInsumos, { AEM->AEM_SUBINS, dDataNec, cLocPad, nQtd1, nQtd2, cProduto } )
				EndIf

				lRet := .T.

			EndIf
			AEM->( DbSkip() )
		EndDo

	EndIf

EndIf

RestArea( aAreaAEM )
RestArea( aAreaAJY )
RestArea( aArea )

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSNecSub ³ Autor ³ Marcelo Akama         ³ Data ³ 09/10/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Popula array de insumos com os insumos da composicao         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProjet                                                      ³±±
±±³          ³ cRevisa                                                      ³±±
±±³          ³ cCompUn                                                      ³±±
±±³          ³ nQuant                                                       ³±±
±±³          ³ dDataRef                                                     ³±±
±±³          ³ dDataNec                                                     ³±±
±±³          ³ aInsumos                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSNecSub(cProjet,cRevisa,cCompUn,nQuant,dDataRef,dDataNec,aInsumos)
Local aArea    := GetArea()
Local aAreaAJT := AJT->( GetArea() )
Local aAreaAJU := AJU->( GetArea() )
Local aAreaAJX := AJX->( GetArea() )
Local lRet     := .F.
Local nProdun

DbSelectArea( "AJT" )
AJT->( DbSetOrder( 2 ) )
If AJT->( DbSeek( xFilial( "AJT" ) + cProjet + cRevisa + cCompUn ) )

	//Insumos da composicao

	DbSelectArea( "AJU" )
	AJU->( DbSetOrder( 3 ) )
	AJU->( DbSeek( xFilial( "AEL" ) + cProjet + cRevisa + AJT->AJT_COMPUN ) )
	Do While AJU->( !Eof() ) .And. AJU->( AJU_FILIAL + AJU_PROJET + AJU_REVISA + AJU_COMPUN ) == xFilial( "AJU" ) + cProjet + cRevisa + AJT->AJT_COMPUN

		If !AJU->AJU_GRORGA $ 'AE'
			AJU->( DbSkip() )
			Loop
		EndIf

		nProdun := IIf(AJU->AJU_GRORGA $ IIf(AJT->AJT_TPPRDE=='1',"AB","ABE") .And. AJT->AJT_TIPO='2', AJT->AJT_PRODUC, 1 )

		If PMSNecIns(cProjet, cRevisa, AJU->AJU_INSUMO, AJU->AJU_QUANT*nQuant/nProdun, AJU->AJU_QTSEGU*nQuant/nProdun, AJU->AJU_HRPROD, dDataRef, dDataNec, @aInsumos)
			lRet := .T.
		EndIf

		DbSelectArea( "AJU" )
		AJU->(dbSkip())

	EndDo

	// Subcomposicoes da composicao

	DbSelectArea( "AJX" )
	AJX->( DbSetOrder( 4 ) )
	AJX->( DbSeek( xFilial( "AJX" ) + cProjet + cRevisa + AJT->AJT_COMPUN ) )
	Do While AJX->( !Eof() ) .And. AJX->( AJX_FILIAL + AJX_PROJET + AJX_REVISA + AJX_COMPUN ) == xFilial( "AJX" ) + cProjet + cRevisa + AJT->AJT_COMPUN

		nProdun := IIf(AJT->AJT_TPPRDE<>'1' .And. AJT->AJT_TIPO='2', AJT->AJT_PRODUC, 1 )
		If PMSNecSub(cProjet, cRevisa, AJX->AJX_SUBCOM, AJX->AJX_QUANT*nQuant/nProdun, dDataRef, dDataNec, @aInsumos)
			lRet := .T.
		EndIf

		dbSelectArea("AJX")
		AJX->( DbSkip() )
	EndDo

EndIf

RestArea( aAreaAJT )
RestArea( aAreaAJU )
RestArea( aAreaAJX )
RestArea( aArea )

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAJYCopy³ Autor ³ Marcelo Akama         ³ Data ³ 11/10/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de copia de insumos do projeto para insumos do projeto ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do insumo                                       ³±±
±±³          ³ExpC2: Projeto origem                                         ³±±
±±³          ³ExpC3: Revisao Projeto origem                                 ³±±
±±³          ³ExpC4: Projeto destino                                        ³±±
±±³          ³ExpC5: Revisao Projeto destino                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAJYCopy(cInsumo, cPrjOri, cRevOri, cPrjDes, cRevDes)

Local aArea		:= GetArea()
Local aAreaAJY	:= AJY->(GetArea())
Local aAreaAEM	:= AEM->(GetArea())
Local bCampo    := {|n| FieldName(n) }
Local nRecAEM
Local nZ

// Insumos

dbSelectArea('AJY')
AJY->(dbSetOrder(1))
If cPrjOri+cRevOri<>cPrjDes+cRevDes
	If !AJY->(dbSeek(xFilial('AJY')+cPrjDes+cRevDes+cInsumo))
		If AJY->(dbSeek(xFilial('AJY')+cPrjOri+cRevOri+cInsumo))
			RegToMemory("AJY",.F.,.F.)
			PmsNewRec("AJY")
			For nz := 1 TO FCount()
				FieldPut(nz,M->&(EVAL(bCampo,nz)))
			Next nz
			AJY->AJY_FILIAL := xFilial("AJY")
			AJY->AJY_PROJET := cPrjDes
			AJY->AJY_REVISA := cRevDes

			If AJY->AJY_GRORGA=='A' .And. AJY->AJY_TPPARC $ '1;2'
				AJY->AJY_CUSTD  :=	IIf(AF8->AF8_DEPREC $ "13", AJY->AJY_DEPREC, 0) +;
									IIf(AF8->AF8_JUROS  $ "13", AJY->AJY_VLJURO, 0) +;
									IIf(AF8->AF8_MDO    $ "13", AJY->AJY_MDO   , 0) +;
									IIf(AF8->AF8_MATERI $ "13", AJY->AJY_MATERI, 0) +;
									IIf(AF8->AF8_MANUT  $ "13", AJY->AJY_MANUT , 0)
				AJY->AJY_CUSTIM :=	IIf(AF8->AF8_DEPREC $ "23", AJY->AJY_DEPREC, 0) +;
									IIf(AF8->AF8_JUROS  $ "23", AJY->AJY_VLJURO, 0) +;
									IIf(AF8->AF8_MDO    $ "23", AJY->AJY_MDO   , 0)
			EndIf

			MsUnlock()

			// Estrutura do insumo

			// So importa quando for insumo que nao existia nos insumos do projeto,
			// caso contrario, prevalece o que ja foi customizado para o projeto

			dbSelectArea('AEM')
			AEM->(dbSetOrder(2)) //AEM_FILIAL+AEM_PROJET+AEM_REVISA+AEM_INSUMO+AEM_SUBINS
			If !AEM->(dbSeek(xFilial('AEM')+cPrjDes+cRevDes+cInsumo))
		 		If AEM->(dbSeek(xFilial('AEM')+cPrjOri+cRevOri+cInsumo))
		 			Do While !AEM->(Eof()) .And. AEM->( AEM_FILIAL + AEM_PROJET + AEM_REVISA + AEM_INSUMO ) == xFilial('AEM')+cPrjOri+cRevOri+cInsumo
		 				nRecAEM := AEM->(RecNo())
		 				PMSAJYCopy(AEM->AEM_SUBINS, cPrjOri, cRevOri, cPrjDes, cRevDes)

						RegToMemory("AEM",.F.,.F.)
						PmsNewRec("AEM")
						For nz := 1 TO FCount()
							FieldPut(nz,M->&(EVAL(bCampo,nz)))
						Next nz
						AEM->AEM_FILIAL := xFilial("AEM")
						AEM->AEM_PROJET := cPrjDes
						AEM->AEM_REVISA := cRevDes

						MsUnlock()

						AEM->(dbGoTo(nRecAEM))
						AEM->(dbSkip())
					EndDo
	 			EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaAJY)
RestArea(aAreaAEM)
RestArea(aArea)
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAJTCopy³ Autor ³ Marcelo Akama         ³ Data ³ 11/10/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de copia de composic do projeto p/ composic do projeto ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo da composicao                                   ³±±
±±³          ³ExpC2: Projeto origem                                         ³±±
±±³          ³ExpC3: Revisao Projeto origem                                 ³±±
±±³          ³ExpC4: Projeto destino                                        ³±±
±±³          ³ExpC5: Revisao Projeto destino                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAJTCopy(cCompos, cPrjOri, cRevOri, cPrjDes, cRevDes)
Local aArea		:= GetArea()
Local aAreaAJT	:= AJT->(GetArea())
Local aAreaAJU	:= AJU->(GetArea())
Local aAreaAJX	:= AJX->(GetArea())
Local aAreaAJV	:= AJV->(GetArea())
Local bCampo    := {|n| FieldName(n) }
Local nRec
Local nZ

// Composicao aux

dbSelectArea('AJT')
AJT->(dbSetOrder(2))
If cPrjOri+cRevOri<>cPrjDes+cRevDes

	If !AJT->(dbSeek(xFilial('AJT')+cPrjDes+cRevDes+cCompos))
		If AJT->(dbSeek(xFilial('AJT')+cPrjOri+cRevOri+cCompos))
			RegToMemory("AJT",.F.,.F.)
			PmsNewRec("AJT")
			For nz := 1 TO FCount()
				FieldPut(nz,M->&(EVAL(bCampo,nz)))
			Next nz
			AJT->AJT_FILIAL := xFilial("AJT")
			AJT->AJT_PROJET := cPrjDes
			AJT->AJT_REVISA := cRevDes

			MsUnlock()

			dbSelectArea('AJU')
			AJU->(dbSetOrder(3)) // AJU_FILIAL+AJU_PROJET+AJU_REVISA+AJU_COMPUN+AJU_INSUMO
			If !AJU->(dbSeek(xFilial('AJU')+cPrjDes+cRevDes+cCompos))
		 		If AJU->(dbSeek(xFilial('AJU')+cPrjOri+cRevOri+cCompos))
		 			Do While !AJU->(Eof()) .And. AJU->( AJU_FILIAL + AJU_PROJET + AJU_REVISA + AJU_COMPUN ) == xFilial('AJU')+cPrjOri+cRevOri+cCompos
		 				nRec := AJU->(RecNo())
		 				PMSAJYCopy(AJU->AJU_INSUMO, cPrjOri, cRevOri, cPrjDes, cRevDes)

						RegToMemory("AJU",.F.,.F.)
						PmsNewRec("AJU")
						For nz := 1 TO FCount()
							FieldPut(nz,M->&(EVAL(bCampo,nz)))
						Next nz
						AJU->AJU_FILIAL := xFilial("AJU")
						AJU->AJU_PROJET := cPrjDes
						AJU->AJU_REVISA := cRevDes

						MsUnlock()
						AJU->(dbGoTo(nRec))
						AJU->(dbSkip())
					EndDo
	 			EndIf
			EndIf


			dbSelectArea('AJX')
			AJX->(dbSetOrder(4)) // AJX_FILIAL+AJX_PROJET+AJX_REVISA+AJX_COMPUN+AJX_SUBCOM
			If !AJX->(dbSeek(xFilial('AJX')+cPrjDes+cRevDes+cCompos))
		 		If AJX->(dbSeek(xFilial('AJX')+cPrjOri+cRevOri+cCompos))
		 			Do While !AJX->(Eof()) .And. AJX->( AJX_FILIAL + AJX_PROJET + AJX_REVISA + AJX_COMPUN ) == xFilial('AJX')+cPrjOri+cRevOri+cCompos
		 				nRec := AJX->(RecNo())
		 				PMSAJTCopy(AJX->AJX_SUBCOM, cPrjOri, cRevOri, cPrjDes, cRevDes)

						RegToMemory("AJX",.F.,.F.)
						PmsNewRec("AJX")
						For nz := 1 TO FCount()
							FieldPut(nz,M->&(EVAL(bCampo,nz)))
						Next nz
						AJX->AJX_FILIAL := xFilial("AJX")
						AJX->AJX_PROJET := cPrjDes
						AJX->AJX_REVISA := cRevDes

						MsUnlock()

						AJX->(dbGoTo(nRec))
						AJX->(dbSkip())
					EndDo
	 			EndIf
			EndIf


			dbSelectArea('AJV')
			AJV->(dbSetOrder(2)) // AJV_FILIAL+AJV_PROJET+AJV_REVISA+AJV_COMPUN+AJV_ITEM
			If !AJV->(dbSeek(xFilial('AJV')+cPrjDes+cRevDes+cCompos))
		 		If AJV->(dbSeek(xFilial('AJV')+cPrjOri+cRevOri+cCompos))
		 			Do While !AJV->(Eof()) .And. AJV->( AJV_FILIAL + AJV_PROJET + AJV_REVISA + AJV_COMPUN ) == xFilial('AJV')+cPrjOri+cRevOri+cCompos
		 				nRec := AJV->(RecNo())

						RegToMemory("AJV",.F.,.F.)
						PmsNewRec("AJV")
						For nz := 1 TO FCount()
							FieldPut(nz,M->&(EVAL(bCampo,nz)))
						Next nz
						AJV->AJV_FILIAL := xFilial("AJV")
						AJV->AJV_PROJET := cPrjDes
						AJV->AJV_REVISA := cRevDes

						MsUnlock()

						AJV->(dbGoTo(nRec))
						AJV->(dbSkip())
					EndDo
	 			EndIf
			EndIf

		EndIf

	EndIf
EndIf

RestArea(aAreaAJV)
RestArea(aAreaAJX)
RestArea(aAreaAJU)
RestArea(aAreaAJT)
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSAF8CSTAJUST  ºAutor  ³Pedro Pereira Lima  º Data ³  17/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                                  º±±
±±º          ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Cronograma Previsto de Consumo                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAF8CstAjust(cProjeto)
Local cTpAjust := ""
Local aArea := {}
Local aAreaAF8 := {}

	If AF8->(ColumnPos("AF8_AJCUST")) >0
		aArea := GetArea()
		aAreaAF8 := AF8->(Getarea())
		dbSelectArea("AF8")
		dbSetOrder(1)
		If MsSeek(xFilial("AF8")+cProjeto)
			cTpAjust := AF8->AF8_AJCUST
		EndIf
		restarea(aAreaAF8)
		restarea(aArea)
	EndIf

Return(cTpAjust)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PMSAFACrnCon   ³ Autor ³ Pedro Pereira Lima    ³ Data ³ 17/11/2009     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtem o Custo do produto conforme planilha de cotacao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nCusto: Custo na data solicitada                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PmsAFACrnCon(cTipo ,nPos ,dData ,nQtdTsk ,aAFAHeader ,aAFACols)
Local nTotal   := 0
Local nPItem := 0
Local nPProd := 0
Local nPRecurs := 0
Local nPQuant:= 0
Local nCntFor := 0
Local cPmsCust:= GetMV("MV_PMSCUST") //Indica se utiliza o custo pela quantidade unitaria ou total
Local nCustPeri := 0

DEFAULT nQtdTsk := 1
DEFAULT dData := Ctod('31/12/2049')

nPAFACustRea := aScan(aAFAHeader ,{|x| AllTrim(x[2])=="AFA_CUSTRE"})

If cTipo == "R"
	nPItem   := aScan(aHeadAEF2,{|x| AllTrim(x[2])=="AEF_ITEM"})
	nPRecurs := aScan(aHeadAEF2,{|x| AllTrim(x[2])=="AEF_RECURS"})
	nPQuant  := aScan(aHeadAEF2 ,{|x| AllTrim(x[2])=="AEF_QTD001"})


	If nPos <= len(aColsAEF2)
		dSeek := CTOD(aHeadAEF2[nPQuant ,01])
		For nCntFor := nPQuant to Len(aHeadAEF2)
			If dtos(dData) >= dtos(CTOD(aHeadAEF2[nCntFor ,01]))
				dSeek := CTOD(aHeadAEF2[nCntFor ,01])
			EndIf
			dbSelectArea("AF8")
			dbSetOrder(1)
			If MsSeek(xFilial()+AFA->AFA_PROJET) .AND. !Empty(AF8->AF8_ULMES) .AND. dSeek <= AF8->AF8_ULMES
				nCustPeri := aAFACols[nPos ,nPAFACustRea]
			Else
				nCustPeri := AEFPrdCust(M->AF9_PROJET ,M->AF9_REVISA ,cTipo ,aColsAEF2[nPos ,nPRecurs] ,dSeek)
			EndIf

			nTotal += nCustPeri*(aColsAEF2[nPos ,nCntFor]*IIf(cPmsCust == "1" ,1 ,nQtdTsk))
		Next nCntFor
	EndIf
Else
	If nPos <= len(aColsAEF1)

		nPItem  := aScan(aHeadAEF1,{|x| AllTrim(x[2])=="AEF_ITEM"})
		nPProd  := aScan(aHeadAEF1,{|x| AllTrim(x[2])=="AEF_PRODUT"})
		nPQuant := aScan(aHeadAEF1 ,{|x| AllTrim(x[2])=="AEF_QTD001"})

		dSeek := CTOD(aHeadAEF1[nPQuant ,01])
		For nCntFor := nPQuant to Len(aHeadAEF1)
			If dtos(dData) >= dtos(CTOD(aHeadAEF1[nCntFor ,01]))
				dSeek := CTOD(aHeadAEF1[nCntFor ,01])
			EndIf
			dbSelectArea("AF8")
			dbSetOrder(1)
			If MsSeek(xFilial()+M->AF9_PROJET) .AND. !Empty(AF8->AF8_ULMES) .AND. dSeek <= AF8->AF8_ULMES
				nCustPeri := aAFACols[nPos ,nPAFACustRea]
			Else
				nCustPeri := AEFPrdCust(M->AF9_PROJET ,M->AF9_REVISA ,"P" ,aColsAEF1[nPos ,nPProd] ,dSeek)
			EndIf
			nTotal += nCustPeri*(aColsAEF1[nPos ,nCntFor]*IIf(cPmsCust == "1" ,1 ,nQtdTsk))
		Next nCntFor
	EndIF
EndIf

Return( nTotal )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ AEFPrdCust     ³ Autor ³ Pedro Pereira Lima    ³ Rev. ³ 17/11/2009     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtem o Custo do produto conforme planilha de cotacao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nCusto: Custo na data solicitada                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AEFPrdCust(cProjeto ,cRevisa ,cTipo ,cSeek ,dData)
Local nCust    := 0
Local aArea    := GetArea()
Local aAreaAEE := AEC->(GetArea())
Local aAreaAEC := AEC->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
Local aAreaAE8 := AE8->(GetArea())
Local cProduto := ""
Local cRecurso := ""
Local lFound   := .T.

DEFAULT cTipo := ""
DEFAULT cSeek := ""

	If cTipo == "R"
		cProduto := SPACE(TamSX3("AEC_PRODUT")[1])
		cRecurso := cSeek
	Else
		cRecurso := SPACE(TamSX3("AEC_RECURS")[1])
		cProduto := cSeek
	EndIf

	dbSelectArea("AEE")
	dbSetOrder(1)
	If dbSeek(xFilial()+cProjeto+cRevisa+cProduto+cRecurso)
		dbSelectArea("AEC")
		dbSetOrder(1)
		If dbSeek(xFilial()+cProjeto+cRevisa+cProduto+cRecurso+dtos(dData))
			nCust := AEC->AEC_CUSTD
		Else
			If dbSeek(xFilial()+cProjeto+cRevisa+cProduto+cRecurso+left(dtos(dData),6))
				While AEC->(AEC_FILIAL+AEC_PROJET+AEC_REVISA+AEC_PRODUT+AEC_RECURS+Left(DtoS(AEC_DATREF) ,6)) ==xFilial()+cProjeto+cRevisa+cProduto+cRecurso+left(dtos(dData) ,6)
					nCust := AEC->AEC_CUSTD
					If dtos(dData)>dtos(AEC->AEC_DATREF)
						Exit
					EndIf
					dbSkip()
				EndDo
			Else
				lFound   := .F.
			EndIf
		EndIf
	Else
		lFound   := .F.
	EndIf

	If !lFound
		nCust := 0
		If cTipo == "R"
			DbSelectArea("AE8")
			DbSetOrder(1)
			If DbSeek(xFilial("AE8")+cRecurso)
				If AE8->AE8_VALOR >0
					nCust := AE8->AE8_VALOR
				Else
					If !Empty(AE8->AE8_PRODUT)
						dbSelectArea("SB1")
						DbSetOrder(1)
						If DbSeek(xFilial("SB1")+AE8->AE8_PRODUT)
							nCust := RetFldProd(SB1->B1_COD,"B1_CUSTD")
						EndIf
					EndIf
				EndIf
			EndIf
		Else
			dbSelectArea("SB1")
			DbSetOrder(1)
			If DbSeek(xFilial("SB1")+cProduto)
				nCust := RetFldProd(SB1->B1_COD,"B1_CUSTD")
			EndIf
		EndIf
	EndIf

RestArea(aAreaAE8)
RestArea(aAreaSB1)
RestArea(aAreaAEC)
RestArea(aAreaAEE)
RestArea(aArea)

Return nCust

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³EncChgFoco³ Autor ³ Cristiano Denardi     ³ Data ³ 18-07-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao necessaria para que possa clicar no botao OK de uma   ³±±
±±³    enchoice sem trocar o foco do campo alterado, pois a enchoice nao    ³±±
±±³    gerencia essa troca de valor, sendo assim nao e' executado o Valid,  ³±±
±±³    Gatilhos, etc. do campo.                                             ³±±
±±³    A ideia e' forcar a troca de foco antes de executar qualquer         ³±±
±±³    processamento ao clicar no botao OK da enchoice.                     ³±±
±±³    Basta chamar essa funcao, passando como parametro o objeto da        ³±±
±±³    Enchoice, no momento que se clica no botao OK, aconselhavel ser a    ³±±
±±³    primeira funcao a ser chamada.                                       ³±±
±±³    INFELIZMENTE E' UMA GAMBIARRA.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ "O" - Enchoice                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EncChgFoco( oEnchoice )
If ValType(oEnchoice)=="O"
	oEnchoice:aEntryCtrls[Len(oEnch:aEntryCtrls)]:SetFocus()
Endif
Return Nil
/*
//-----------------------
Funcao.....: PmsVerConv()
Data.......: 21.08.06
Autor......: Cristiano Denardi
Descricao
---------
Funcao que verifica o conteudo do cadastro do projeto para os campos,
AF8_DTCONV e AF8->AF8_CNVPRV, se estiverem OK, entao eh ignorado os
mesmos valores da tabela AF9, caso contrario, usa os valores cadastrados
na tarefa.
//-----------------------
*/
Function PmsVerConv(dDtConv,cCnvPrv,lAF8Mem,lAF9Mem)

Local aCpos := {}
	Aadd( aCpos, "AF8->AF8_DTCONV" )
	Aadd( aCpos, "AF8->AF8_CNVPRV" )

Default lAF8Mem := .F.
Default lAF9Mem := .F.

If ExecLisFun( aCpos, "ValType", "U", .F. )
	If ExecLisFun( aCpos, "Empty",,, .T. )
		If lAF8Mem
			dDtConv := M->AF8_DTCONV
			cCnvPrv := M->AF8_CNVPRV
		Else
			dDtConv := AF8->AF8_DTCONV
			cCnvPrv := AF8->AF8_CNVPRV
		EndIf
	Else
		If lAF9Mem
			dDtConv := M->AF9_DTCONV
			cCnvPrv := M->AF9_CNVPRV
		Else
			dDtConv := AF9->AF9_DTCONV
			cCnvPrv := AF9->AF9_CNVPRV
		EndIf
	EndIf
EndIf

Return
/*
//-----------------------
Funcao.....: ExecLisFun()
Data.......: 21.08.06
Autor......: Cristiano Denardi
*/
Function ExecLisFun( aVar, cFunc, cTipo, lIgual, lNega )

Local lRet := .T.
Local cExp := ""
Local cSinal := ""
Local nA   := 0

Default aVar	:= {}
Default cFunc	:= ""
Default cTipo	:= ""
Default lIgual	:= .F.
Default lNega	:= .F.

cSinal := If( lIgual, "==", "<>" )
If !Empty(cFunc)
	For nA := 1 To Len(aVar)

		/////////////////////////////
		// Monta Expressao solicitada
			cExp := If( lNega, "!", "" )
			cExp += cFunc +"(" + aVar[nA] + ")"
			If !Empty(cTipo)
				cExp += " "  + cSinal
				cExp += " '" + cTipo + "'"
			EndIf
		// Monta Expressao solicitada
		/////////////////////////////
		lRet := &cExp

		If !lRet
			Exit
		Endif
	Next nA
EndIf

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsTrtSC6³ Autor ³ Bruno Sobieski         ³ Data ³ 30-07-2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao da sequencia de empenho do projeto.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsTrtSC6()
Local aArea		:= GetArea()

DbSelectArea("AFJ")
AFJ->(DbSetOrder(1))
AFJ->(DbGoTop())
If AFJ->(MsSeek(xFilial()+aCols[n,aScan(aHeader,{|x|AllTrim(x[2])=="C6_PROJPMS"})]+aCols[n,aScan(aHeader,{|x|AllTrim(x[2])=="C6_TASKPMS"})]+aCols[n,aScan(aHeader,{|x|AllTrim(x[2])=="C6_PRODUTO"})]+aCols[n,aScan(aHeader,{|x|AllTrim(x[2])=="C6_LOCAL"})]))
	SF4->(DbSetOrder(1))
	SF4->(DbGoTop())
  	If SF4->(MsSeek(xFilial()+aCols[n,aScan(aHeader,{|x|AllTrim(x[2])=="C6_TES"})]))
  		If SF4->F4_DUPLIC="N"
			aCols[n,aScan(aHeader,{|x|AllTrim(x[2])=="C6_TRT"})]:=AFJ->AFJ_TRT
		EndIf
	EndIf
EndIf
RestArea(aArea)

Return .T.
//Funcoes removidas do PMSXFUN para o PMSXFUNA


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsHrsItv2³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o numero de horas uteis em um determinado intervalo   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpD1 : Data Inicial                                          ³±±
±±³          ³ExpC2 : Hora Inicial   ("XX:XX")                              ³±±
±±³          ³ExpD3 : Data Final                                            ³±±
±±³          ³ExpC4 : Hora Final     ("XX:XX")                              ³±±
±±³          ³ExpC5 : Codigo do Calendario                                  ³±±
±±³          ³ExpC6 : Codigo do Projeto                                     ³±±
±±³          ³ExpC7 : Codigo do Recurso                                     ³±±
±±³          ³ExpL8 : Flag que indica se funcao esta sendo chamada pelo PCP ³±±
±±³          ³ExpL9 : Flag para indicar se estah sendo chamada de uma rotina³±±
±±³          ³        de apontamento de recurso.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsHrsItv2(dDataIni,cHoraIni,dDataFim,cHoraFim,cCalend,cProjeto,cRecurso,lPcP,lAponta,cAliasAFY,aTrbs)
Local cAloc
Local nTamanho
Local nDuracao	:= 0
Local nMinBit		:= 0
Local aArea		:= {}
Local nx			:= 0
Local cQuery		:= ""
Local lNewCalend	:= SuperGetMv("MV_PMSCALE" , .T. , .F. )
Local cFilAFY 	:= ""
Local lIntMSP		:= IsInCallStack("Aux010BGrv")
Local cCaleTsk		:= AF9->AF9_CALEND

Default cAliasAFY 	:= ""
DEFAULT cProjeto	:= ""
DEFAULT cRecurso	:= ""
DEFAULT lPcp		:= .F.
DEFAULT lAponta	:= .F.

If !lPcP .AND. lNewCalend .and. __lTopConn .and. AliasinDic("AEG")
	nDuracao := PmsAEGItvl(dDataIni,cHoraIni,dDataFim,cHoraFim,cCalend,cProjeto,cRecurso,aTrbs)
Else

	aArea := GetArea()

	If !lIntMSP .AND. Type("M->AF9_CALEND") == 'C' //Caso não seja da integração Project deve pegar informação da memória
		cCaleTsk := M->AF9_CALEND
	EndIf
	
	If dDataIni<=dDataFim
	
		cFilAFY 	:= ""
		nMinBit	:= 60 / SuperGetMV("MV_PRECISA")
		cFilAFY 	:= xFilial("AFY")

		cAliasAFY := GetNextAlias()
	
		/* Teste de mesa
		###################################################################
		AFY (dias)				1	2	3	4	5	6	7	8	9	10	11	12				#
		Possibilidades da tarefa														#
		DtI e DtF		30	31	1	2	3	4												#
		DtI e DtF						3	4	5	6	7	8								#
		DtI e DtF												9	10	11	12	13	14		#
		DtI e DtF		30	31	1	2	3	4	5	6	7	8	9	10	11	12	13	14		#
		DtI e DtF				1	2	3	4	5											#
		DtI e DtF											8	9	10	11	12				#
		###################################################################
		*/
	
		cQuery := " SELECT AFY_FILIAL, AFY_RECURS, AFY_PROJET, AFY_DATA, AFY_DATAF, AFY_ALOC, R_E_C_N_O_ "
		cQuery += " FROM "+RetSqlName("AFY")+" "
		cQuery += " WHERE ( AFY_PROJET = ' ' OR AFY_PROJET = '"+cProjeto+"' ) "
		cQuery += " AND ( AFY_RECURS = ' ' OR AFY_RECURS = '"+cRecurso+"' ) "
		cQuery += " AND ( "
		cQuery += "		( AFY_DATA <= '"+Dtos(dDataIni)+"' AND AFY_DATAF >= '"+Dtos(dDataIni)+"'  ) "
		cQuery += " 	OR ( AFY_DATA <= '"+Dtos(dDataFim)+"' AND AFY_DATAF >= '"+Dtos(dDataFim)+"'  ) "
		cQuery += " 	OR ( AFY_DATA BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' ) "
		cQuery += " 	OR ( AFY_DATAF BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' ) "
		cQuery += " ) "
		cQuery += " AND D_E_L_E_T_ = ' ' "
	
		cQuery := ChangeQuery(cQuery)
	
		dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasAFY, .T., .T.)
	
		TcSetField(cAliasAFY,"AFY_DATA","D",8,0)
		TcSetField(cAliasAFY,"AFY_DATAF","D",8,0)
	
		dbSelectArea("SH7")
		If MsSeek(xFilial("SH7")+cCalend)
			cAloc    := Upper(SH7->H7_ALOC)
			nTamanho := Len(cAloc) / 7
		Else
			Aviso(STR0224,STR0225+cCalend+STR0226,{STR0122},2) //"Inconsistencia na base de dados"##"O Calendario Cod. "###" nao existe no cadastro de calendarios.. Verifique a base de dados."###"Fechar"
			cAloc	:= ""
			nTamanho:= 0
		EndIf
		Do Case
			Case dDataIni==dDataFim
				nDuracao += PmsHrUtil(dDataIni,"00"+cHoraIni,"00"+cHoraFim,cCalend,,cProjeto,cRecurso,lPcp,cAloc,nTamanho,lAponta,cAliasAFY)
			Case dDataFim-dDataIni < 14 .OR. cCalend <> cCaleTsk
				nDuracao += PmsHrUtil(dDataIni,"00"+cHoraIni,"0024:00",cCalend,,cProjeto,cRecurso,lPcp,cAloc,nTamanho,lAponta,cAliasAFY)
				dDataIni++
				While dDataIni <= dDataFim
					If dDataIni==dDataFim
						nDuracao += PmsHrUtil(dDataIni,"0000:00","00"+cHoraFim,cCalend,,cProjeto,cRecurso,lPcp,cAloc,nTamanho,lAponta,cAliasAFY)
					Else
						nDuracao += PmsHrUtil(dDataIni,"0000:00","0024:00",cCalend,,cProjeto,cRecurso,lPcp,cAloc,nTamanho,lAponta,cAliasAFY)
					EndIf
					dDataIni++
				End
			OtherWise
				nDuracao += PmsHrUtil(dDataIni,"00"+cHoraIni,"0024:00",cCalend,,cProjeto,cRecurso,lPcp,cAloc,nTamanho,lAponta,cAliasAFY)
				dDataIni++
				(cAliasAFY)->(dbGotop())
				For nx := 1 to ((dDataFim-dDataIni-1)/7)
					lSeek := .F.
					dbSelectArea(cAliasAFY)
	
					Do While !lSeek .And. !(cAliasAFY)->(Eof()) .And. (cAliasAFY)->AFY_FILIAL==cFilAFY .And. (cAliasAFY)->AFY_DATA<=dDataIni+7
						If dDataIni<=(cAliasAFY)->AFY_DATAF
							If (Empty((cAliasAFY)->AFY_PROJET) .Or. ((cAliasAFY)->AFY_PROJET == cProjeto)) .And. ;
								(Empty((cAliasAFY)->AFY_RECURS) .Or. ((cAliasAFY)->AFY_RECURS == cRecurso))
								lSeek := .T.
								Exit
							EndIf
						EndIf
						(cAliasAFY)->(dbSkip())
					EndDo
	
					If lSeek
						dAuxData := dDataIni+6
						While dDataIni < dAuxData
							nDuracao += PmsHrUtil(dDataIni,"0000:00","0024:00",cCalend,,cProjeto,cRecurso,lPcp,cAloc,nTamanho,lAponta,cAliasAFY)
							dDataIni++
						EndDo
					Else
						nDuracao += ((Len(StrTran(Substr(cAloc,1,Len(cAloc))," ","")))*nMinBit)/60
						dDataIni += 7
					EndIf
				Next nX
	
				While dDataIni <= dDataFim
					If dDataIni==dDataFim
						nDuracao += PmsHrUtil(dDataIni,"0000:00","00"+cHoraFim,cCalend,,cProjeto,cRecurso,lPcp,cAloc,nTamanho,lAponta,cAliasAFY)
					Else
						nDuracao += PmsHrUtil(dDataIni,"0000:00","0024:00",cCalend,,cProjeto,cRecurso,lPcp,cAloc,nTamanho,lAponta,cAliasAFY)
					EndIf
					dDataIni++
				EndDo
		EndCase
	
		If Select(cAliasAFY)>0
			(cAliasAFY)->(dbCloseArea())
		Endif
	EndIf
	
	RestArea(aArea)
EndIf

Return If(lPcp,nDuracao,NoRound(nDuracao,2))


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsHrUti2³ Autor ³ Edson Maricate         ³ Rev. ³ 15-08-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o numero de horas uteis em uma determinada Data.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpD1 : Data de Referencia                                    ³±±
±±³          ³ExpC2 : Hora Final     ("XXXX:XX")                            ³±±
±±³          ³ExpC3 : Hora Inicial   ("XXXX:XX")                            ³±±
±±³          ³ExpC4 : Codigo do Calendario                                  ³±±
±±³          ³ExpA4 : Fora de Uso                                           ³±±
±±³          ³ExpC5 : Codigo do Projeto para tratamento de excecoes         ³±±
±±³          ³ExpC6 : Codigo do Recurso para tratamento de excecoes         ³±±
±±³          ³ExpL6 : Flag para tratamento da funcao para o PCP             ³±±
±±³          ³ExpC7 : Array contento a string de aloc. calendario (Opcional)³±±
±±³          ³ExpN8 : Tamanho do bloco por dia (Opcional)                   ³±±
±±³          ³ExpL9 : Indicar se foi chamado do apontamento da tarefa       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS, SXB                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsHrUti2(dData,cHoraIni,cHoraFim,cCalend,aForaDeUso,cProjeto,cRecurso,lPcp,cAloc,nTamanho,lAponta)
return .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSCHKEXC2ºAutor  ³Microsiga           º Data ³  01/08/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsChkExc2(dData,cProjeto,cRecurso,cAlocDay)
Local aArea
Local cAliasTmp 	:= ""
Local cFilAFY 		:= ""
Local nPrioridade	:= 0
Local nPos 			:= aScan(aChkExc,{|x| x[1]== xFilial("AFY") .And. x[2]== dData .And. ;
											( x[3]== cProjeto .Or. Empty(x[3]) ) .And. ;
											( x[4]== cRecurso .Or. Empty(x[4]) )	 })

If nPos > 0
	cAlocDay := aChkExc[nPos,5]
Else
	aArea	:= GetArea()
	cAliasTmp	:= GetNextAlias()
	nPrioridade := 0
	cFilAFY		:= xFilial( 'AFY' ) 
		
	BeginSql alias cAliasTmp
	SELECT 
		AFY.AFY_FILIAL,
		AFY.AFY_DATA,
		AFY.AFY_DATAF,
		AFY.AFY_RECURS,
		AFY.AFY_PROJET,
		AFY.AFY_MALOC
	FROM
		%table:AFY% AFY,
	WHERE
		AFY.AFY_FILIAL= %xfilial:AFY% AND
		AFY.AFY_DATA <= %exp:DtoS(dData)% AND
		AFY.AFY_DATAF >= %exp:DtoS(dData)% AND
		AFY.%notDel%
	ORDER BY 
		AFY_DATA
	EndSql

	Do While !(cAliasTmp)->(Eof()) .And. (cAliasTmp)->AFY_FILIAL==cFilAFY .And. STOD((cAliasTmp)->AFY_DATA)<=dData
		If dData<=STOD((cAliasTmp)->AFY_DATAF)
			//
			// ******** RECURSO E PROJETO PREENCHIDOS
			// Calendario de excecao do recurso sobrepõe do projeto ou geral,isto é, projeto e recurso em brancos.
			// Se a excecao de calendario ter informado recurso e projeto, assume este.
			//
			If (!Empty((cAliasTmp)->AFY_RECURS).AND.(cAliasTmp)->AFY_RECURS == cRecurso) .AND. (!Empty((cAliasTmp)->AFY_PROJET) .AND. (cAliasTmp)->AFY_PROJET == cProjeto)
				nPrioridade := 4
				cAlocDay := (cAliasTmp)->AFY_MALOC
				Exit
			EndIf

			// ******** RECURSO PREENCHIDO E PROJETO EM BRANCO
			// Calendario de excecao do recurso sobrepõe do projeto ou geral,isto é, projeto e recurso em brancos.
			// Se a excecao de calendario ter informado recurso e projeto em branco, assume este.
			//
			If (nPrioridade < 4) .AND. (!Empty((cAliasTmp)->AFY_RECURS).AND.(cAliasTmp)->AFY_RECURS == cRecurso) .AND. (Empty((cAliasTmp)->AFY_PROJET))
				nPrioridade := 3
				cAlocDay := (cAliasTmp)->AFY_MALOC
			EndIf

			// ******** PROJETO PREENCHIDO E RECURSO EM BRANCO
			// Calendario de excecao do projeto sobrepõe o geral, isto é projeto e recurso em brancos
			// Se a excecao de calendario ter informado projeto e recurso em branco, assume este.
			//
			If (nPrioridade < 3) .AND. (!Empty((cAliasTmp)->AFY_PROJET) .AND. (cAliasTmp)->AFY_PROJET == cProjeto) .AND. Empty((cAliasTmp)->AFY_RECURS)
				nPrioridade := 2
				cAlocDay := (cAliasTmp)->AFY_MALOC
			EndIf

			// ******** PROJETO E RECURSO EM BRANCOS
			// Calendario de excecao do projeto sobrepõe o geral, isto é projeto e recurso em brancos
			// Se a excecao de calendario ter projeto e recurso em brancos, assume este.
			//
			If (nPrioridade < 2) .AND. (Empty((cAliasTmp)->AFY_PROJET) .AND. Empty((cAliasTmp)->AFY_RECURS))
				nPrioridade := 1
				cAlocDay := (cAliasTmp)->AFY_MALOC
			EndIf

			If nPrioridade > 0
				aAdd(aChkExc,{(cAliasTmp)->AFY_FILIAL,(cAliasTmp)->AFY_DATA,(cAliasTmp)->AFY_PROJET,(cAliasTmp)->AFY_RECURS,cAlocDay})
			EndIf

		EndIf
		(cAliasTmp)->(dbSkip())
	EndDo
	(cAliasTmp)->(dbCloseArea())
	RestArea(aArea)
EndIf
aSize(aChkExc, 0)
Return cAlocDay


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsExAFN  ºAutor  ³Clovis Magenta      º Data ³  08/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que verifica se o item da nota de entrada tem amar- º±±
±±º          ³ ração com PMS.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA103X                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PmsExAFN(cAlias)
Local lAFN := .F.
Local aArea := GetArea()
Local aAreaSD1 := SD1->(GetArea())
Local aAreaSF1 := SF1->(GetArea())
DEFAULT cAlias := "SD1"

dbselectarea("AFN")
dbsetOrder(2) // AFN_FILIAL+AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_ITEM+AFN_PROJET+AFN_REVISA+AFN_TAREFA
If DbSeek(xFilial("AFN")+(cAlias)->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM))
	lAFN := .T.
EndIf
RestArea(aAreaSF1)
RestArea(aAreaSD1)
RestArea(aArea)

Return lAFN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSExcecptºAutor  ³Clovis Magenta      º Data ³  09/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função que retorna o periodo de horas que foram parametri- º±±
±±º          ³ zadas como exceçao de calendario                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSC010A                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSExcecpt(cAloc)

Local aArray  := {}
Local aRet    := {}
Local nTamanho:= 0
Local x		  := 0
Local y		  := 0
Local cHoraFim:= ""

cAloc := STRTran(cAloc,"X" ,"x")
nTamanho := Len(cAloc)

While Len(cAloc) > 0
    Aadd(aArray, SubStr(cAloc, 1, nTamanho))
    cAloc := SubStr(cAloc, nTamanho + 1)
EndDo

For x := 1 to Len(aArray)
	nPos1 := 0
	nPos2 := 0
	Aadd(aRet, {x})

	For y := 1 to Len(aArray[x])
		If SubStr(aArray[x], y, 1) == "x" .and. nPos1 = 0
			nPos1 := y
		ElseIf SubStr(aArray[x], y, 1) == " " .And. nPos1 # 0
			nPos2 := y
			If Len(aRet[Len(aRet)]) < 10
				Aadd(aRet[Len(aRet)], Bit2Tempo(nPos1-1))
				cHoraFim := PmsSec2Time(Secs(SubStr(Bit2Tempo(nPos2-1), 3) + ":00"))
				Aadd(aRet[Len(aRet)], cHoraFim)
			EndIf
			nPos1 := 0
		EndIf
	Next
	aSize(aRet[Len(aRet)], 11)
Next

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsReadTskºAutor  ³Marcelo Akama       º Data ³  18/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função que chama a PjReadTask ou a emula caso nao exista   º±±
±±º          ³ no repositorio                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsReadTsk(nTaskId, cField)
Local uResult	:= ""
Local aResult
Local aParms	:= { 'MsProject', _TASK_RAWREAD, Alltrim(Str(nTaskId))+";" + cField +";" }

If FindFunction("PjReadTask")

	uResult := PjReadTask(nTaskId, cField)

Else

	aResult := ExecInClient( 400, aParms )

	If ( Len(aResult) > 0 )
		uResult	:= Subs( aResult [1], 2 )
	EndIf

EndIf

If IsIncallStack("Aux010BGrv") .AND. cField $ uResult 
	uResult	:= ""
EndIf

Return uResult

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AuxEqpAloc³ Autor ³ Marcelo Akama			³ Data ³ 15/04/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Popula o array contendo a alocacao da equipe e seu percent.	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Template CCT													³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AuxEqpAloc(dStart,cHoraI,dFinish,cHoraF,nAloc,dIni,cHIni,dFim,cHFim,nFilter,cProjeto,cVersao,cAltTrf,aRecAF9,aAE8xAF9,aAuxAloc)

If cAltTrf == Nil .Or.( cAltTrf <> Nil .And. AF9->AF9_TAREFA <> cAltTrf )
	If (AF9->AF9_REVISA==AF8->AF8_REVISA .And. cProjeto==Nil) .Or. (AF9->AF9_REVISA==AF8->AF8_REVISA .And. cProjeto!=AF8->AF8_PROJET).Or.(AF9->AF9_REVISA==cVersao .And. cProjeto==AF8->AF8_PROJET)
		If ( DTOS(dStart)+cHoraI >= DTOS(DIni)+cHIni .And. DTOS(dStart)+cHoraI  <= DTOS(dFim)+cHFim)  .Or. 	;
			( DTOS(dFinish)+cHoraF >= DTOS(DIni)+cHIni .And. DTOS(dFinish)+cHoraF <= DTOS(dFim)+cHFim) .Or.;
			( DTOS(dStart)+cHoraI < DTOS(DIni)+cHIni .And. DTOS(dFinish)+cHoraF > DTOS(dFim)+cHFim)

			Do Case
				Case nFilter==1  //Todas
					aAdd(aAuxAloc,{dStart,cHoraI,dFinish,cHoraF,nAloc})
					If aRecAF9 <> Nil
						aAdd(aRecAF9,AF9->(RecNo()) )
						If aAE8xAF9 <> Nil
							AAdd(aAE8xAF9,{Len(aRecAF9),AE8->(Recno())})
						Endif
					EndIf
				Case nFilter==2 .And. !Empty(AF9->AF9_DTATUF) //Tarefas Executadas
					aAdd(aAuxAloc,{dStart,cHoraI,dFinish,cHoraF,nAloc})
					If aRecAF9 <> Nil
						aAdd(aRecAF9,AF9->(RecNo()) )
						If aAE8xAF9 <> Nil
							AAdd(aAE8xAF9,{Len(aRecAF9),AE8->(Recno())}		)
						Endif
					EndIf
				Case nFilter==3 .And. Empty(AF9->AF9_DTATUF) //Tarefas a Executar
					aAdd(aAuxAloc,{dStart,cHoraI,dFinish,cHoraF,nAloc})
					If aRecAF9 <> Nil
						aAdd(aRecAF9,AF9->(RecNo()) )
						If aAE8xAF9 <> Nil
							AAdd(aAE8xAF9,{Len(aRecAF9),AE8->(Recno())}		 )
						Endif
					EndIf
			EndCase
		EndIf
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AuxEqpAlCU³ Autor ³ Marcelo Akama			³ Data ³ 16/04/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Popula o array contendo a alocacao da equipe e seu percent.	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Template CCT													³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AuxEqpAlCU(cCompun,nQtd,nProdEqp,dDataIni,dIni,cHIni,dFim,cHFim,nFilter,cProjeto,cVersao,cAltTrf,aRecAF9,aAE8xAF9,aAuxAloc)
Local nDecCst	:= TamSX3( "AF9_CUSTO" )[2]
Local nQuant
Local nProduc
Local nAloc

dbSelectArea("AJU")
AJU->(dbSetOrder(3)) //AJU_FILIAL+AJU_PROJET+AJU_REVISA+AJU_COMPUN+AJU_INSUMO
AJU->(MsSeek(xFilial("AJU")+AJY->AJY_PROJET+AJY->AJY_REVISA+cCompun+AJY->AJY_INSUMO))
Do While !AJU->(Eof()) .And. xFilial("AJU")+AJY->(AJY_PROJET+AJY_REVISA+cCompun+AJY_INSUMO)==AJU->(AJU_FILIAL+AJU_PROJET+AJU_REVISA+AJU_COMPUN+AJU_INSUMO)
	AF8->(dbSetOrder(1))
	AF8->(MsSeek(xFilial("AF8")+AJY->AJY_PROJET))
	AF9->(dbSetOrder(1))
	AF9->(MsSeek(xFilial("AF9")+AJY->AJY_PROJET+AJY->AJY_REVISA+AEN->AEN_TAREFA))
	AJT->(dbSetOrder(2)) // AJT_FILIAL+AJT_PROJET+AJT_REVISA+AJT_COMPUN
	AJT->(MsSeek(xFilial("AJT")+AJY->AJY_PROJET+AJY->AJY_REVISA+cCompun))

	nProduc := nProdEqp
	If AJT->AJT_TIPO<>'1'
		nProduc := AJT->AJT_PRODUC / nProduc
	EndIf
	nQuant	:= AJU->AJU_QUANT
	nQuant	:= pmsTrunca( "2", nQuant/nProduc, nDecCst )
	nQuant	:= pmsTrunca( "2", nQuant * nQtd, nDecCst )
	nAloc	:= (nQuant / AF9->AF9_HDURAC) * 100

	aAuxRet := PMSDTaskF(dDataIni,"00:00",AF9->AF9_CALEND,nQuant,AF9->AF9_PROJET,Nil)

	AuxEqpAloc(aAuxRet[1],aAuxRet[2],aAuxRet[3],aAuxRet[4],nAloc,dIni,cHIni,dFim,cHFim,nFilter,cProjeto,cVersao,cAltTrf,@aRecAF9,@aAE8xAF9,@aAuxAloc)

	dbSelectArea("AJU")
	AJU->(dbSkip())
EndDo

dbSelectArea("AJX")
AJX->(dbSetOrder(2)) //AJX_FILIAL+AJX_PROJET+AJX_REVISA+AJX_COMPUN+AJX_ITEM
AJX->(MsSeek(xFilial("AJX")+AJY->AJY_PROJET+AJY->AJY_REVISA+cCompun))
Do While !AJX->(Eof()) .And. xFilial("AJX")+AJY->(AJY_PROJET+AJY_REVISA+cCompun)==AJX->(AJX_FILIAL+AJX_PROJET+AJX_REVISA+AJX_COMPUN)
	AF8->(dbSetOrder(1))
	AF8->(MsSeek(xFilial("AF8")+AJY->AJY_PROJET))
	AF9->(dbSetOrder(1))
	AF9->(MsSeek(xFilial("AF9")+AJY->AJY_PROJET+AJY->AJY_REVISA+AEN->AEN_TAREFA))
	AJT->(dbSetOrder(2)) // AJT_FILIAL+AJT_PROJET+AJT_REVISA+AJT_COMPUN
	AJT->(MsSeek(xFilial("AJT")+AJY->AJY_PROJET+AJY->AJY_REVISA+cCompun))

	nProduc := nProdEqp
	If AJT->AJT_TIPO<>'1'
		nProduc := nProduc / AJT->AJT_PRODUC
	EndIf

	AuxEqpAlCU(AJX->AJX_SUBCOM,AJX->AJX_QUANT * nQtd,nProduc,dDataIni,dIni,cHIni,dFim,cHFim,nFilter,cProjeto,cVersao,cAltTrf,@aRecAF9,@aAE8xAF9,@aAuxAloc)

	dbSelectArea("AEN")
	AEN->(dbSkip())
EndDo

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PegaPredec³ Autor ³ Marcelo Akama			³ Data ³ 20/08/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Popula o array contendo as predecessoras da tarefa			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMS															³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PegaPredec(cProjet, cRevisa, cTarefa, nNivel, aRecurs )
Local aRet := {}

Default aRecurs := {}

AuxPegaPre(cProjet, cRevisa, cTarefa, nNivel, @aRet, "", aRecurs)

Return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AuxPegaPre³ Autor ³ Marcelo Akama			³ Data ³ 20/08/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Popula o array contendo as predecessoras da tarefa			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMS															³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AuxPegaPre(cProjet, cRevisa, cTarefa, nNivel, aPred, cNivel, aRecurs )
Local aArea		:= GetArea()
Local aAreaAFD	:= AFD->(GetArea())
Local aAreaAJ4	:= AJ4->(GetArea())
Local aAreaAF9	:= AF9->(GetArea())
Local cHiera	:= "00"

dbSelectArea("AF9")
dbSetOrder(1)

If ColumnPos("AF9_RASTRO")>0

	dbSelectArea("AFD")
	dbSetOrder(1)
	If AFD->( MsSeek(xFilial("AFD")+cProjet+cRevisa+cTarefa) )
		Do While !AFD->(Eof()) .And. xFilial("AFD")+cProjet+cRevisa+cTarefa == AFD->(AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA)
			If AF9->( MsSeek(xFilial("AF9")+cProjet+cRevisa+AFD->AFD_PREDEC) )
				If nNivel >= AF9->AF9_RASTRO
					cHiera := Soma1(cHiera)
					If aScan(aPred,{|x| AllTrim(x[1])==AllTrim(AFD->AFD_PREDEC)} ) == 0
						AADD(aPred, {AFD->AFD_PREDEC,''})
					EndIf
					AuxPegaPre(cProjet, cRevisa, AFD->AFD_PREDEC, nNivel, @aPred, cNivel+cHiera, @aRecurs)
				EndIf

				dbSelectArea( "AFA" )
				AFA->( DbSetOrder( 5 ) )
				AFA->( DbSeek( xFilial( "AFA" ) + AF9->( AF9_PROJET + AF9_REVISA + AF9_TAREFA ) ) )
				While AFA->( !Eof()) .And. AFA->( AFA_FILIAL + AFA_PROJET + AFA_REVISA + AFA_TAREFA ) == xFilial("AFA")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)
					If !Empty( AFA->AFA_RECURS ) .And. ASCAN(aRecurs, AFA->AFA_RECURS)==0
						aAdd( aRecurs, AFA->AFA_RECURS )
					EndIf

					AFA->(dbSkip())
				End
			EndIf
			AFD->(dbSkip())
		EndDo
	EndIf

	dbSelectArea("AF9")
	dbSetOrder(2)

	dbSelectArea("AJ4")
	dbSetOrder(1)
	If AJ4->( MsSeek(xFilial("AJ4")+cProjet+cRevisa+cTarefa) )
		Do While !AJ4->(Eof()) .And. xFilial("AJ4")+cProjet+cRevisa+cTarefa == AJ4->(AJ4_FILIAL+AJ4_PROJET+AJ4_REVISA+AJ4_TAREFA)
			If AF9->( MsSeek(xFilial("AF9")+cProjet+cRevisa+AJ4->AJ4_PREDEC) )
				If nNivel >= AF9->AF9_RASTRO
					cHiera := Soma1(cHiera)
					Do While !AF9->(Eof()) .And. xFilial("AF9")+cProjet+cRevisa+AJ4->AJ4_PREDEC == AF9->(AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_EDTPAI)
						If aScan(aPred,{|x| AllTrim(x[1])==AllTrim(AF9->AF9_TAREFA)} ) == 0
							AADD(aPred, {AF9->AF9_TAREFA,''})
						EndIf
						AuxPegaPre(cProjet, cRevisa, AF9->AF9_TAREFA, nNivel, @aPred, cNivel+cHiera, @aRecurs)
						AF9->(dbSkip())
					EndDo
				EndIf

				dbSelectArea( "AFA" )
				AFA->( DbSetOrder( 5 ) )
				AFA->( DbSeek( xFilial( "AFA" ) + AF9->( AF9_PROJET + AF9_REVISA + AF9_TAREFA ) ) )
				While AFA->( !Eof()) .And. AFA->( AFA_FILIAL + AFA_PROJET + AFA_REVISA + AFA_TAREFA ) == xFilial("AFA")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)
					If !Empty( AFA->AFA_RECURS ) .And. ASCAN(aRecurs, AFA->AFA_RECURS)==0
						aAdd( aRecurs, AFA->AFA_RECURS )
					EndIf

					AFA->(dbSkip())
				End
			EndIf
			AJ4->(dbSkip())
		EndDo
	EndIf

EndIf

RestArea(aAreaAFD)
RestArea(aAreaAJ4)
RestArea(aAreaAF9)
RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSHLPAFN ºAutor  ³Clovis Magenta      º Data ³  16/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclui HELP na rotina MATA103 para validar usuario x PMS  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION PMSHLPAFN()
Local aHelpPor := {}
Local aHelpSpa := {}
Local aHelpEng := {}
Local aSoluPor := {}
Local aSoluSpa := {}
Local aSoluEng := {}

Aadd(aHelpPor,"Usuário sem permissão de amarrar uma   " )
Aadd(aHelpPor,"NFE a um projeto/tarefa do SIGAPMS.    " )

Aadd(aHelpSpa,"Usuario sin permiso para vincular una " )
Aadd(aHelpSpa,"factura a un proyecto/tarea del SIGAPMS.")

Aadd(aHelpEng,"User with no permission to link a NFE " )
Aadd(aHelpEng,"(electronic invoice) to a SIGAPMS " )
Aadd(aHelpEng,"project/task.")

//³SOLUCAO³
Aadd(aSoluPor,"Verificar permissões de usuários no" )
Aadd(aSoluPor," projeto/tarefa junto ao administra-")
Aadd(aSoluPor,"dor do sistema.                    " )

Aadd(aSoluSpa,"Verificar permisos de usuarios en el")
Aadd(aSoluSpa," proyecto/tarea junto al administrador")
Aadd(aSoluSpa," del sistema. " )

Aadd(aSoluEng,"Check the user permissions in ")
Aadd(aSoluEng,"projetc/task with the system administrator." )

PutHelp("PPMSUSRNFE",aHelpPor, aHelpEng, aHelpSpa, .T.)
PutHelp("SPMSUSRNFE",aSoluPor, aSoluEng, aSoluSpa, .T.)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsVral   ºAutor  ³Clovis Magenta      º Data ³  04/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que validara o parametro MV_PMSVRAL no valid do cam-º±±
±±º          ³ po AFU_RECURS                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ X3_VALID - AFU_RECURS	                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsVral()
Local lRet := .T.
Local nPosPrj	:= 0
Local nPosRev	:= 0
Local nPosTrf	:= 0
Local cRecurso	:= &(ReadVar())

IF FUNNAME() == "PMSA321"

	nPosRev	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFU_REVISA"})
	nPosTrf	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFU_TAREFA"})
	nPosRec	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFU_RECURS"})
	nPosPrj	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFU_PROJET"})

	If SuperGetMV("MV_PMSVRAL", .F., 0) <> 0 .AND. !EMPTY(aCols[n,nPosPrj]) .AND. !EMPTY(aCols[n,nPosRev]) .AND. !EMPTY(aCols[n,nPosTrf]) .and. !Empty(cRecurso)
		If !IsAllocatedRes(aCols[n,nPosPrj] , aCols[n,nPosRev] , aCols[n,nPosTrf] , cRecurso)
			Aviso(STR0228, STR0229 , {STR0122}, 2) //"Apontamento de Recurso" ; "É necessário que o recurso esteja alocado na tarefa para efetuar apontamento." ; "Fechar"
			Return .F.
		EndIf
	EndIf

Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IsAllocatedResºAutor  ³Clovis Magenta  º Data ³  04/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que verifica a alocação de um recurso na tarefa     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ pmsvral()                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IsAllocatedRes(cProject, cRevision, cTask, cResource)
Local aArea := GetArea()
Local aAreaAFA := AFA->(GetArea())

Local lReturn := .F.

dbSelectArea("AFA")
AFA->(dbSetOrder(5))

// AFA - índice 5:
// AFA_FILIAL + AFA_PROJET + AFA_REVISA + AFA_TAREFA + AFA_RECURS
lReturn := AFA->(MsSeek(xFilial("AFA") + cProject + cRevision + cTask + cResource))

RestArea(aAreaAFA)
RestArea(aArea)
Return lReturn


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsVldAFR ºAutor Leandro Sousa         º Data ³  01/16/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validaçao para ver o tipo do titulo que esta sendo excluidoº±±
±±º          ³ ou estornado da tabela AFR                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PmsVldAFR(cAFRProj, cAFRRev, cAFRTrf)

Local lRet 		:= .F.

DEFAULT cAFRProj:= ""
DEFAULT cAFRRev	:= ""
DEFAULT cAFRTrf	:= ""

If	cAFRProj+cAFRRev+cAFRTrf==AFR->AFR_PROJET+AFR->AFR_REVISA+AFR->AFR_TAREFA
	If 	(AFR->AFR_TIPO == MVISS .And. AFR->AFR_PARCEL == cParcISS ) .Or. ;
	 	(AFR->AFR_TIPO == MVINSS .And. AFR->AFR_PARCEL == cParcINSS ).Or.;
	 	(AFR->AFR_TIPO == MVTAXA .And. AFR->AFR_PARCEL == cParcIR ) .Or.;
	 	(AFR->AFR_TIPO == Iif(cTipoE2 $ MVPAGANT+"/"+MV_CPNEG,MVTXA,MVTAXA) .And. AFR->AFR_PARCEL == cParcCof ) .Or.;
	 	(AFR->AFR_TIPO == Iif(cTipoE2 $ MVPAGANT+"/"+MV_CPNEG,MVTXA,MVTAXA) .And. AFR->AFR_PARCEL == cParcPIS ) .Or.;
	 	(AFR->AFR_TIPO == Iif(cTipoE2 $ MVPAGANT+"/"+MV_CPNEG,MVTXA,MVTAXA) .And. AFR->AFR_PARCEL == cParcCsll )
		// Integração com TOP, gera a apropriacao para o projeto.
		lRet := .T.
	EndIf
EndIf
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³LeCor		  ³ Autor ³ Daniel Sobreira	³ Data ³ 04-07-2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Le a configuracao das cores do Gantt por usuario.				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³SIGAPMS														³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LeCor(cChave)
Local cProfExChave 	:= cChave
Local aAreaAF8 		:= AF8->(GetArea())
Local cCores		:=	""
Local aRet 			:= {}
Local cUsrName		:= ""

psworder(1)
PswSeek(__cUSerID)
aRet      := PswRet(1)
cUsrName := aRet[1,2]

//Carrega profile do usuario (Cores do Gantt)
If FindProfDef( cUsrName, FunName(), cProfExChave, "PMSGANTCOR" )
	cCores	:=	RetProfDef(cUsrName,FunName() ,cProfExChave, "PMSGANTCOR")
Endif
RestArea(aAreaAF8)
Return cCores

/*/{Protheus.doc} CalcComp
	Calcula o valor compensado de um RA de acordo com o rateio do título que foi abatido
	@type  Static Function
	@author CRM/Fat
	@since 23/07/2021
	@param cPrefixo, caracter, Prefixo do título
			cNum, caracter, Número do título
			cParcela, caracter, Parcela do título
			cCliente, caracter, Cliente do título
			cLoja, caracter, Loja do título
			nValSE1RA, numérico, Valor do RA
			cProjeto, caracter, Código do projeto
			cRevisa, caracter, Identificador da revisão
			cTarefa, caracter, Código do tarefa
	@return nRetComp, numérico, Valor compensado do RA proporcional ao rateado no projeto
/*/
Static Function CalcComp(cPrefixo,cNum,cParcela,cCliente,cLoja,nValSE1RA,cProjeto,cRevisa,cTarefa)
	
	Local aArea			:= GetArea()
	Local aAreaSE1		:= SE1->(GetArea())
	Local aAreaAFT		:= AFT->(GetArea())
	Local cAliasQry		:= ""
	Local cQuery		:= ""
	Local nRetComp		:= 0
	Local cFilSE5		:= xFilial("SE5")
	Local cFilAFT		:= xFilial("AFT")

	Default cPrefixo	:= ""
	Default cNum		:= ""
	Default cParcela	:= ""
	Default cCliente	:= ""
	Default cLoja		:= ""
	Default nValSE1RA	:= 0
	Default cProjeto	:= ""
	Default cRevisa		:= ""
	Default cTarefa		:= ""

	cAliasQry := CriaTrab( ,.F.)

	cQuery := 	"SELECT E5_FILORIG, E5_DOCUMEN FROM "  + RetSqlName( "SE5" ) + " SE5"
	cQuery += 	" WHERE SE5.E5_FILIAL ='" + cFilSE5 + "'"
	cQuery += 	" AND SE5.E5_PREFIXO ='" + cPrefixo + "'"
	cQuery += 	" AND SE5.E5_NUMERO ='" + cNum + "'"
	cQuery += 	" AND SE5.E5_PARCELA ='" + cParcela + "'"
	cQuery += 	" AND SE5.E5_TIPODOC ='BA'"
	cQuery += 	" AND SE5.E5_MOTBX ='CMP'"
	cQuery += 	" AND SE5.E5_CLIFOR ='" + cCliente + "'"
	cQuery += 	" AND SE5.E5_LOJA ='" + cLoja + "'"
	cQuery += 	" AND SE5.D_E_L_E_T_=' '"
	cQuery += 	" GROUP BY E5_FILORIG, E5_DOCUMEN"

	cQuery := ChangeQuery( cQuery )

	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

	SE1->(DbSetOrder(1))
	AFT->(DbSetOrder(1))
	While (cAliasQry)->(!Eof())
		If SE1->(DbSeek((cAliasQry)->E5_FILORIG+(cAliasQry)->E5_DOCUMENT))
			If AFT->(DbSeek(cFilAFT+cProjeto+cRevisa+cTarefa+;
				SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+;
				SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA))
				nRetComp += (SE1->E1_VALOR-SE1->E1_SALDO)*(AFT->AFT_VALOR1/SE1->E1_VALOR)
			EndIf
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo 

	(cAliasQry)->(dbCloseArea())

	RestArea(aAreaAFT)
	RestArea(aAreaSE1)
	RestArea(aArea)

Return nRetComp

/*/{Protheus.doc} PMSVldLibCQ
	Função utilizada para validação do campo AFN_LIBCQ
	@type Function
	@author SQUAD CRM & FAT
	@since 01/11/2021
	@return lRet, lógico
/*/
Function PMSVldLibCQ()

Local lRet    := .T.
Local nLibCq  := &(Readvar())
Local nPSldCQ := Ascan(aHeader,{|x| alltrim(x[2])=="AFN_SALDCQ"})

If nPSldCQ > 0
	If (nLibCq > aOrigAFN[n][4] .Or. nLibCq > nQtTotSD7)
		Help(" ",1,"PMSLIBCQ",,STR0240,1,0)		//##"A quantidade digitada está maior que a quantidade disponível."
		lRet := .F.
	Else
		aCols[n][nPSldCQ] := aOrigAFN[n][4] - nLibCq
	EndIf
EndIf

Return lRet
