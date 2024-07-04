#include "PMSA330.CH"
#include "protheus.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PMSA330  ³ Autor ³ Fabio Rogerio Pereira ³ Data ³ 22/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Cadastramento de Exce‡”es ao Calend rio.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPMS                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSA330
Local oDlg
Local oCalend
Local oSay
Local oBtnInc
Local oBtnCanc
Local aCalend  :={} 
Local aCalend1 :={} 
Local lVazio   :=.F.
Local nOpc     := 0
Private cTitulo:=OemToAnsi(STR0001)	//"Exce‡”es ao Calend rio"
Private Inclui := Altera := .F.
Private lHasDataF

If PMSBLKINT()
	Return Nil
EndIf

dbSelectArea("AFY")
lHasDataF := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define qual a precisao utilizada pelo SIGAPMS                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AFY")
dbSetOrder(2) 
dbSeek(xFilial("AFY"))
While !Eof()
	If ( AFY->AFY_FILIAL == xFilial("AFY") )
		Aadd(aCalend,{;
						AFY_DATA,;
						AFY_RECURSO,;
						AFY_PROJETO,;
						AFY_MALOC,;
						AFY_MOTIVO,;
						IIf( lHasDataF , IIf( empty(AFY_DATAF) , AFY_DATA , AFY_DATAF ) , AFY_DATA );
		})
	EndIf
	dbSkip()
End

A330Mont(aCalend,@aCalend1,dDataBase)
	
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) FROM 1,1 TO 400,600 PIXEL //"Exce‡”es ao Calend rio"
	oCalend:=MsCalend():New(010,040,oDlg)
	oCalend:ColorDay(1,CLR_HRED)
	oCalend:ColorDay(7,CLR_HRED)
	oCalend:dDiaAtu:=dDataBase
	// Eventos
	oCalend:bChangeMes := {|| A330Mark(Year(oCalend:dDiaAtu) ,Month(oCalend:dDiaAtu) ,oCalend,aCalend) }
	oCalend:bChange	   := {|| A330Mont(aCalend,@aCalend1,oCalend:dDiaAtu,@oSay,@oLbx)}

	@ 085,010 SAY oSay PROMPT OemToAnsi(STR0010) + DTOC(oCalend:dDiaAtu) + ":" SIZE 150,7 OF oDlg PIXEL	//"Excecoes cadastradas para o dia "
	If lHasDataF
		@ 100,010 LISTBOX oLbx FIELDS HEADER OemToAnsi(STR0006),OemToAnsi(STR0017),OemToAnsi(STR0018),OemToAnsi(STR0008),OemToAnsi(STR0007) SIZE 280,80 OF oDlg PIXEL	//"Hist¢rico"###"Inicio"###"Fim"###"Projeto"###"Recurso"
	Else
		@ 100,010 LISTBOX oLbx FIELDS HEADER OemToAnsi(STR0006),OemToAnsi(STR0008),OemToAnsi(STR0007) SIZE 280,80 OF oDlg PIXEL	//"Hist¢rico"###"Projeto"###"Recurso"
	EndIf
	oLbx:SetArray(aCalend1)
	If lHasDataF
		oLbx:bLine := { || {aCalend1[oLbx:nAt,1],aCalend1[oLbx:nAt,5],aCalend1[oLbx:nAt,6],aCalend1[oLbx:nAt,2],aCalend1[oLbx:nAt,3]} }
	Else
		oLbx:bLine := { || {aCalend1[oLbx:nAt,1],aCalend1[oLbx:nAt,2],aCalend1[oLbx:nAt,3]} }
	EndIf

	@ 010, 220  BUTTON oBtnInc PROMPT STR0012 SIZE 42,11 PIXEL ACTION (nOpc:=3,A330Proc1(@aCalend,@aCalend1,oLbx,oCalend:dDiaAtu,@lVazio,oBtnEdit,oBtnDel,oBtnVis,oCalend,nOpc)) //" Incluir >>"
	@ 024, 220  BUTTON oBtnEdit PROMPT STR0013 SIZE 42,11 PIXEL ACTION (nOpc:=4,A330Proc1(@aCalend,@aCalend1,oLbx,oCalend:dDiaAtu,@lVazio,oBtnEdit,oBtnDel,oBtnVis,oCalend,nOpc)) //" Editar >>"
	@ 038, 220  BUTTON oBtnDel PROMPT STR0014 SIZE 42,11 PIXEL ACTION (nOpc:=5,A330Proc1(@aCalend,@aCalend1,oLbx,oCalend:dDiaAtu,@lVazio,oBtnEdit,oBtnDel,oBtnVis,oCalend,nOpc)) //" Excluir >>"
	@ 052, 220  BUTTON oBtnVis PROMPT STR0015 SIZE 42,11 PIXEL ACTION (nOpc:=2,A330Proc1(@aCalend,@aCalend1,oLbx,oCalend:dDiaAtu,@lVazio,oBtnEdit,oBtnDel,oBtnVis,oCalend,nOpc)) //" Visualizar >>"
	@ 066, 220  BUTTON oBtnCanc PROMPT STR0016 SIZE 42,11 PIXEL ACTION oDlg:End() //" Sair >>"
ACTIVATE MSDIALOG oDlg CENTER ON INIT A330Mark(Year(dDataBase) ,Month(dDataBase) ,oCalend,aCalend)
//alterado o botão Cancelar para Sair por problema com entendimento quando traduzido para espanhol

Return(.T.)

	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A330Proc1 ³ Autor ³ Fabio Rogerio Pereira ³ Data ³ 22/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de Inclus„o/Altera‡„o do Cadastro de Exce‡”es ao    ³±±
±±³          ³ Calend rio.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA330                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A330Proc1(aCalend,aCalend1,oLbx,dData,lVazio,oBtnEdit,oBtnDel,oBtnVis,oCalend,nOpc)
Local oDlg
Local oGetHR
Local oWorkTime
Local oDesc
Local oRec
Local oProj
Local oDtIni
Local oDtFim
Local i			 := 0
Local nOpca 	 := 0
Local lDesmarca  := .T.
Local nPrecisao  := GetMv("MV_PRECISA")
Local nTamDia    := 1440 / (60/nPrecisao)
Local cOldTitulo := cTitulo
Local c330Rec    := CriaVar("AE8_RECURS",.F.)
Local c330Projeto:= CriaVar("AF8_PROJET",.F.)
Local c330Desc   := CriaVar("AF8_DESCRI",.F.)
Local d330DtIni  := CriaVar("AFY_DATA"  ,.F.)
Local d330DtFim  := IIf( lHasDataF , CriaVar("AFY_DATAF",.F.) , CriaVar("AFY_DATA",.F.) )
Local cCargaHR   := "00:00"
Local nPosArray	 := 0
Local dDt
Private Inclui   := IIf(nOpc == 3,.T.,.F.)
Private Altera   := IIf(nOpc == 4,.T.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcoes de nOpc:= 0-Abandona 2-Visualiza 3-Inclui 4-Altera 5-Exclui  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nOpc <> 3
	If (Len(aCalend1) = 0)	.Or.(Len(aCalend1) = 1 .And. aCalend1[1, 4] = 0)
		Return Nil
	EndIf 
EndIf

If nOpc == 2
	cTitulo:=cTitulo+OemToAnsi(STR0002)	//" - Visualiza‡„o"
ElseIf nOpc == 3
	cTitulo:=cTitulo+OemToAnsi(STR0003)	//" - Inclus„o"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ A ocorrencia 81 (ACS), verifica se o usuario poder  ou n„o   ³
	//³ incluir excecoes ao calendario.             			     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !ChkPsw( 81 )
		Return(.F.)
	EndIf
ElseIf nOpc == 4
	cTitulo:=cTitulo+OemToAnsi(STR0004)	//" - Altera‡„o"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ A ocorrencia 82 (ACS), verifica se o usuario poder  ou n„o   ³
	//³ alterar excecoes ao calendario.             					  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !ChkPsw( 82 )
		Return(.F.)
	EndIf
ElseIf nOpc == 5
	cTitulo:=cTitulo+OemToAnsi(STR0005)	//" - Exclus„o"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ A ocorrencia 3 (ACS), verifica se o usuario poder  ou n„o    ³
	//³ excluir excecoes ao calendario.             				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !ChkPsw( 3 )
		Return(.F.)
	EndIf
EndIf

If !lHasDataF
	cTitulo += STR0011 + Dtoc(oCalend:dDiaAtu) //" - Dia "
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera o desenho padrao de atualizacoes no DOS e desenha   ³
//³ janelas no WINDOWS.                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! StrZero(nPrecisao, 2) $ "01, 02, 04, 06, 12, 30, 60"
	Help(" ",1,"A780PREINV",,Str(GetMV("MV_PRECISA"),2,0),15,10)
    Return
EndIf


If nOpc == 3
	cCalend := Space(nTamDia)
Else
	nPosArray   := aCalend1[oLbx:nAt,4]
	c330Desc    := aCalend[nPosArray][5]
    c330Rec     := aCalend[nPosArray][2]
	c330Projeto := aCalend[nPosArray][3]
    cCalend     := aCalend[nPosArray][4]       
    cCargaHR    := A330Time(cCalend,nPrecisao)
    If lHasDataF
	   	d330DtIni := aCalend[nPosArray][1]
    	d330DtFim := aCalend[nPosArray][6]
    Else
	   	d330DtIni := dData
    	d330DtFim := dData
    EndIf
EndIf
	
DEFINE MSDIALOG oDlg FROM  13,11 TO 400,590 TITLE cTitulo PIXEL

    @ 006                   ,005 SAY OemToAnsi(STR0006)+":" SIZE 030,008 OF oDlg PIXEL  //"Hist¢rico"
	If lHasDataF
	    @ 006,175 SAY OemToAnsi(STR0017)+":" SIZE 060,008 OF oDlg PIXEL  //"Inicio"
	    @ 019,005 SAY OemToAnsi(STR0018)+":" SIZE 030,008 OF oDlg PIXEL  //"Fim"
	EndIf
    @ IIf(lHasDataF,019,006),175 SAY OemToAnsi(STR0008)+":" SIZE 060,008 OF oDlg PIXEL  //"Projetos"
    @ IIf(lHasDataF,032,019),005 SAY OemToAnsi(STR0007)+":" SIZE 030,008 OF oDlg PIXEL  //"Recurso"
    @ IIf(lHasDataF,032,019),175 SAY OemToAnsi(STR0009)+":" SIZE 047,008 OF oDlg PIXEL  //"Carga Hor ria"
	@ 005                   ,040 MSGET oDesc  VAR c330Desc     PICTURE PesqPict("AFY","AFY_MOTIVO") VALID NaoVazio(c330Desc)			 SIZE 125,008 OF oDlg PIXEL WHEN (nOpc = 3 .Or. nOpc = 4)
	If lHasDataF
		@ 005,217 MSGET oDtIni VAR d330DtIni	VALID !Empty(d330DtIni)                                SIZE 040,008 OF oDlg PIXEL WHEN (nOpc = 3 .Or. nOpc = 4)
		@ 018,040 MSGET oDtFim VAR d330DtFim    VALID !Empty(d330DtFim) .And. (d330DtFim >= d330DtIni) SIZE 040,008 OF oDlg PIXEL WHEN (nOpc = 3 .Or. nOpc = 4)
	EndIf
	@ IIf(lHasDataF,018,005),217 MSGET oProj  VAR c330Projeto	HASBUTTON F3 "AF8" PICTURE PesqPict("AFY","AFY_PROJET") VALID Empty(c330Projeto) .Or.ExistCpo("AF8",c330Projeto) SIZE 040,008 OF oDlg PIXEL WHEN (nOpc = 3 .Or. nOpc = 4)
	@ IIf(lHasDataF,031,018),040 MSGET oRec   VAR c330Rec	    HASBUTTON F3 "AE8" PICTURE PesqPict("AFY","AFY_RECURS") VALID Empty(c330Rec) .Or. ExistCpo("AE8",c330Rec)     SIZE 040,008 OF oDlg PIXEL WHEN (nOpc = 3 .Or. nOpc = 4)
	@ IIf(lHasDataF,031,018),217 MSGET oGetHR VAR cCargaHR SIZE 030,008 OF oDlg PIXEL WHEN .F.

    @ 004,IIf(lHasDataF,45,34) WORKTIME oWorkTime SIZE 280,133 RESOLUTION nPrecisao VALUE cCalend WHEN (Inclui .or. Altera) On Change {|oWorkTime| A330TimeGet(oWorkTime,@cCargaHR,@oGetHR,nPrecisao)}

    DEFINE SBUTTON FROM IIf(lHasDataF,182,174),223 TYPE 1 ACTION { || IIF(A330Vld(nOpc,aCalend,nPosArray,c330Projeto,c330Rec,dData,oWorktime,d330DtIni,d330DtFim),(nOpca:=1,oDlg:End(),oDlg:End()),) } ENABLE
    DEFINE SBUTTON FROM IIf(lHasDataF,182,174),251 TYPE 2 ACTION { || oDlg:End() } ENABLE
ACTIVATE MSDIALOG oDlg CENTER

If nOpca = 1 .And. (nOpc = 3 .Or. nOpc = 4)
    A330Grava(nOpc,@aCalend1,dData,oCalend,c330Desc,c330Rec,c330Projeto,aCalend,nPosArray,d330DtIni,d330DtFim)
ElseIf nOpca = 1 .And. nOpc = 5
	dbSelectArea("AFY")
	dbSetOrder(1)
	dbSeek(xFilial("AFY")+aCalend[nPosArray][3]+aCalend[nPosArray][2]+Dtos(aCalend[nPosArray][1]))
	If !Found()
		Return NIL
	EndIf
	RecLock("AFY",.F.,.T.)
	dbDelete()
	MsUnLock()
	dbCommit()

	For i:= oLbx:nAt To Len(aCalend1)
		aCalend1[i][4] -= 1
	Next
	
	ADel(aCalend,nPosArray)
	ADel(aCalend1,oLbx:nAt)
	ASize(aCalend,Len(aCalend)-1)
    ASize(aCalend1,Len(aCalend1)-1)
	
	dDt := d330DtIni
	Do While dDt <= d330DtFim
		
		If Year(dData)==Year(dDt) .And. Month(dData)==Month(dDt)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se dia deve ser desmarcado                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For i:= 1 to Len(aCalend)
				If lHasDataF
					If dDt >= aCalend[i,1] .And. dDt <= aCalend[i,6]
						lDesmarca:=.F.
					EndIf
				Else
					If aCalend[i,1] == dDt
						lDesmarca:=.F.
					EndIf
				EndIf
			Next i
			If lDesmarca
				oCalend:DelRestri(Day(dDt))
				oCalend:Refresh()
			EndIf
		EndIf
		
		dDt := dDt + 1
		
    EndDo
	
EndIf

cTitulo:=cOldTitulo
oLbx:Refresh()
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A330Vld   ³ Autor ³ Fabio Rogerio Pereira ³ Data ³ 22/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fun‡„o que valida as inclusoes/alteracoes nas excecoes ao   ³±±
±±³          ³ Calendario WINDOWS.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PMSA330                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A330Vld(nOpc,aCalend,nPosArray,c330Projeto,c330Rec,dData,oWorktime,dDataIni,dDataFim)
Local lRet:=.T.

If lHasDataF
	If nOpc = 3 .Or. (nOpc = 4 .And. (aCalend[nPosArray][2] # c330Rec .Or. aCalend[nPosArray][3] # c330Projeto))
		dbSelectArea("AFY")
		dbSetOrder(RetOrder("AFY_FILIAL+AFY_PROJET+AFY_RECURS+AFY_DATA"))
		dbSeek(xFilial("AFY")+c330Projeto+c330Rec)
		Do While lRet .And. !AFY->(Eof()) .And. xFilial("AFY")+c330Projeto+c330Rec==AFY->(AFY_FILIAL+AFY_PROJET+AFY_RECURS) .And. AFY->AFY_DATA<=dDataFim
			If dDataIni<=AFY->AFY_DATAF
				If !Empty(c330Rec)
					Help(" ",1,"A640RECJA",,c330Rec,02,17) //Exceção ao Calendário neste dia, específica ao Recurso ### já existe.
					lRet:=.F.
				ElseIf !Empty(c330Projeto)
					Help(" ",1,"A640CCJA",,c330Projeto,02,31) //Exceção ao Calendário neste dia, específica ao Centro de Custo ### já existe.
					lRet:=.F.
				Else
					Help(" ",1,"A640GERJA") //Já existe uma Exceção Geral ao Calendário cadastrada neste dia.
					lRet:=.F.
				EndIf
			EndIf
			AFY->(dbSkip())
		EndDo
	EndIf
Else
	If nOpc = 3
		If Ascan(aCalend, { |x| x[1] == dData .And. x[2] == c330Rec .And. x[3] == c330Projeto } ) > 0
			If !Empty(c330Rec)
				Help(" ",1,"A640RECJA",,c330Rec,02,17) //Exceção ao Calendário neste dia, específica ao Recurso ### já existe.
				lRet:=.F.
			ElseIf !Empty(c330Projeto)
				Help(" ",1,"A640CCJA",,c330Projeto,02,31) //Exceção ao Calendário neste dia, específica ao Centro de Custo ### já existe.
				lRet:=.F.
			Else
				Help(" ",1,"A640GERJA") //Já existe uma Exceção Geral ao Calendário cadastrada neste dia.
				lRet:=.F.
			EndIf
		EndIf
	ElseIf nOpc = 4
		If aCalend[nPosArray][2] # c330Rec .Or. aCalend[nPosArray][3] # c330Projeto
			dbSelectArea("AFY")
			dbSeek(xFilial("AFY")+c330Projeto+c330Rec+Dtos(aCalend[nPosArray][1]))
	        If Found()
				If !Empty(c330Rec)
					Help(" ",1,"A640RECJA",,c330Rec,02,17) //Exceção ao Calendário neste dia, específica ao Recurso ### já existe.
					lRet:=.F.
				ElseIf !Empty(c330Projeto)
					Help(" ",1,"A640CCJA",,c330Projeto,02,31) //Exceção ao Calendário neste dia, específica ao Centro de Custo ### já existe.
					lRet:=.F.
				Else
					Help(" ",1,"A640GERJA") //Já existe uma Exceção Geral ao Calendário cadastrada neste dia.
					lRet:=.F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
cCalend := oWorkTime:GetValue()
Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A330Grava  ³ Autor ³ Fabio Rogerio Pereira ³ Data ³ 22/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fun‡„o de grava‡„o dos dados alterados.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PMSA330                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A330Grava(nOpc,aCalend1,dData,oCalend,c330Desc,c330Rec,c330Projeto,aCalend,nPosArray,dDataIni,dDataFim)
Local nAcho

If nOpc == 3
	RecLock("AFY",.T.)
ElseIf nOpc == 4
	dbSelectArea("AFY")
	dbSetOrder(1)
	dbSeek(xFilial("AFY")+aCalend[nPosArray][3]+aCalend[nPosArray][2]+Dtos(aCalend[nPosArray][1]))
	If !Found()
		Return NIL
	EndIf
	RecLock("AFY",.F.)
EndIf

Replace AFY_FILIAL  With cFilial
Replace AFY_RECURSO With c330Rec
Replace AFY_MOTIVO  With c330Desc
If lHasDataF
	Replace AFY_DATA    With dDataIni
	Replace AFY_DATAF   With dDataFim
Else
	Replace AFY_DATA    With dData
EndIf
	Replace AFY_MALOC    With cCalend
Replace AFY_PROJETO With c330Projeto
MsUnLock()

If nOpc == 3
	Aadd(aCalend,{;
					AFY_DATA,;
					AFY_RECURSO,;
					AFY_PROJETO,;
					AFY_MALOC,;
					AFY_MOTIVO,;
					IIf( lHasDataF , IIf( empty(AFY_DATAF) , AFY_DATA , AFY_DATAF ) , AFY_DATA );
	})
	nAcho:=ASCAN(aCalend1,{|x| x[4] = 0})
	If nAcho = 0
		AADD(aCalend1,{AFY_MOTIVO,AFY_PROJETO,AFY_RECURSO,Len(aCalend),dDataIni,dDataFim})
	Else
		aCalend1[nAcho][1]:=AFY_MOTIVO
		aCalend1[nAcho][2]:=AFY_PROJETO
		aCalend1[nAcho][3]:=AFY_RECURSO
		aCalend1[nAcho][4]:=Len(aCalend)
		aCalend1[nAcho][5]:=dDataIni
		aCalend1[nAcho][6]:=dDataFim
	EndIf
	
	If !lHasDataF
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se dia deve ser marcado                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    oCalend:AddRestri(Day(dData),CLR_RED,CLR_BLUE)
	EndIf
    
ElseIf nOpc == 4
	aCalend[nPosArray][1] := AFY_DATA
	aCalend[nPosArray][2] := AFY_RECURSO
	aCalend[nPosArray][3] := AFY_PROJETO
	aCalend[nPosArray][4] := AFY_MALOC
	aCalend[nPosArray][5] := AFY_MOTIVO
	If lHasDataF
		aCalend[nPosArray][6] := AFY_DATAF
	EndIf
	
	A330Mont(aCalend,@aCalend1,oCalend:dDiaAtu)
EndIf

If lHasDataF
	oCalend:DelAllRestri()
	A330Mark(Year(dData) ,Month(dData) ,oCalend ,aCalend)
EndIf

oLbx:SetArray(aCalend1)
If lHasDataF
	oLbx:bLine := { || {aCalend1[oLbx:nAt,1],aCalend1[oLbx:nAt,5],aCalend1[oLbx:nAt,6],aCalend1[oLbx:nAt,2],aCalend1[oLbx:nAt,3]} }
Else
	oLbx:bLine := { || {aCalend1[oLbx:nAt,1],aCalend1[oLbx:nAt,2],aCalend1[oLbx:nAt,3]} }
EndIf

oLbx:Refresh()

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A330Mont   ³ Autor ³ Fabio Rogerio Pereira ³ Data ³ 22/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fun‡„o de remontagem do listbox qdo altera data             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PMSA330                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A330Mont(aCalend,aCalend1,dDia,oSay,oLbx)
Local i:=0

aCalend1:={}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array do ListBox.                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For i:= 1 to Len(aCalend)
	If lHasDataF
		If dDia >= aCalend[i,1] .And. dDia <= aCalend[i,6]
			AADD(aCalend1,{aCalend[i,5],aCalend[i,3],aCalend[i,2],i,aCalend[i,1],aCalend[i,6]})
		EndIf
	Else
		If aCalend[i,1] == dDia
			AADD(aCalend1,{aCalend[i,5],aCalend[i,3],aCalend[i,2],i})
		EndIf
	EndIf
Next i

If Empty(aCalend1)
	lVazio:=.T.
	AADD(aCalend1,{CriaVar("AFY_MOTIVO"),CriaVar("AFY_PROJETO"),CriaVar("AFY_RECURSO"),0,CriaVar("AFY_DATA"),IIf(lHasDataF,CriaVar("AFY_DATAF"),CriaVar("AFY_DATA"))})
EndIf

If oSay <> Nil
	oSay:Refresh()
EndIf

If oLbx <> Nil
	oLbx:SetArray(aCalend1)
	If lHasDataF
		oLbx:bLine := { || {aCalend1[oLbx:nAt,1],aCalend1[oLbx:nAt,5],aCalend1[oLbx:nAt,6],aCalend1[oLbx:nAt,2],aCalend1[oLbx:nAt,3]} }
	Else
		oLbx:bLine := { || {aCalend1[oLbx:nAt,1],aCalend1[oLbx:nAt,2],aCalend1[oLbx:nAt,3]} }
	EndIf
	oLbx:Refresh()
EndIf             

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A330Mark   ³ Autor ³ Fabio Rogerio Pereira ³ Data ³ 22/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fun‡„o que marca/desmarca restricoes no calendario          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PMSA330                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A330Mark(nAno ,nMes ,oCalend ,aCalend)
Local nI := 0
Local dDt
Local s
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o array do ListBox.                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 to Len(aCalend)
		If lHasDataF
			If StrZero(nAno,4)+StrZero(nMes,2) >= StrZero(Year(aCalend[nI,1]),4)+StrZero(Month(aCalend[nI,1]),2) .And.;
					StrZero(nAno,4)+StrZero(nMes,2) <= StrZero(Year(aCalend[nI,6]),4)+StrZero(Month(aCalend[nI,6]),2)
				If StrZero(nAno,4)+StrZero(nMes,2) == StrZero(Year(aCalend[nI,1]),4)+StrZero(Month(aCalend[nI,1]),2)
					s:=DTOS(aCalend[nI,1])
				Else
					s:=StrZero(nAno,4)+StrZero(nMes,2)+"01"
				EndIf
				dDt:=STOD(s)
				Do While dDt<=aCalend[nI,6] .And. Month(dDt)==nMes
					oCalend:AddRestri(Day(dDt),CLR_HRED,CLR_BLUE)
					dDt:=dDt+1
				EndDo
			EndIf
		Else
			If Year(aCalend[nI,1]) == nAno .And. Month(aCalend[nI,1]) == nMes
				oCalend:AddRestri(Day(aCalend[nI,1]),CLR_HRED,CLR_BLUE)
			EndIf
		EndIf
	Next nI
	
Return .T. 
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A330Time   ³ Autor ³ Fabio Rogerio Pereira ³ Data ³ 22/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fun‡„o que preenche a Carga Horaria de acordo com o Calend. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PMSA330			                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A330Time(cCalend,nPrecisao)
Local cHoras, cMinutos 
Local nMarca:= 0
Local nX	:= 0

For nx:=1 to Len(cCalend)
  If !Empty(Subs(cCalend,nx,1))
    nMarca+=1
  EndIf
Next nx
cHoras  := StrZero(Int(nMarca /nPrecisao) ,2)
cMinutos:= StrZero( (60/nPrecisao) * ( ( (nMarca /nPrecisao) - Int(nMarca /nPrecisao) ) * nPrecisao ) , 2 )
cHoras  :=cHoras + ":" + cMinutos

Return(cHoras)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A330TimeGet³ Autor ³Fabio Rogerio Pereira   ³ Data ³ 22/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fun‡„o que preenche a carga horaria de acordo com o calend.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PMSA330                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A330TimeGet(oCalend,cCargaHR,oGetHR,nPrecisao)
Local cHoras, cMinutos
Local nMark:= oCalend:nTotalMark

cHoras  := StrZero( Int( nMark / nPrecisao ) , 2 )
cMinutos:= StrZero( (60/nPrecisao) * ( ( (nMark/nPrecisao) - Int(nMark/nPrecisao) ) * nPrecisao ) , 2 )
cCargaHR:= cHoras+":"+cMinutos
oGetHR:Refresh()

Return
