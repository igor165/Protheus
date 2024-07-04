#include "Pmsproj.CH"
#include "MProject.CH"
#include "protheus.ch"
#include "PMSICONS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMontaProjeบAutor  ณMichel Dantas       บ Data ณ  14/05/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณIntegracao com o Project                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function MontaProject(cProjeti,cVersao,cProjetf,dDataRef,cNivel,cFase)

Local oDlg, oFont, oSay
Private oApp

DEFAULT cProjeti := ""
DEFAULT cVersao  := ""
DEFAULT cProjetf := "ZZZ"
DEFAULT dDataRef := dDataBase
DEFAULT cNivel   := ""
DEFAULT cFase    := ""

DEFINE MSDIALOG oDlg TITLE STR0003 FROM 0,0 TO 150,350 OF oMainWnd Pixel //"Parametros"

@ 0, 0 BITMAP RESNAME BMP_LOGIN oF oDlg SIZE 30,(oDlg:nBottom/2.4) ADJUST NOBORDER WHEN .F. PIXEL

DEFINE FONT oFont NAME "Arial" SIZE 0, -13 BOLD

@ 03, 40 SAY STR0004 FONT oFont PIXEL //"Integra็ใo com o MsProject"

@ 14, 30 TO 16 ,400 LABEL "" OF oDlg PIXEL

@ 30,30 Say oSay Prompt Padc(STR0005,50) PIXEL //"Aguarde"

@ (oDlg:nBottom/2-25), 132 BUTTON oBut2 PROMPT STR0006 SIZE 35,10; //"Fechar"
	ACTION ( oApp:Quit(),oApp:Destroy(),oDlg:End() ) PIXEL

ACTIVATE MSDIALOG oDlg CENTERED On Init (oBut2:Hide(),;
						StartProject(cProjeti,cVersao,cProjetf,dDataRef,cNivel,cFase),;
						oBut2:Show(),oSay:SetText(STR0007) ) //"Tecle para finalizar"

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณStartProjeบAutor  ณMichel Dantas       บ Data ณ  06/06/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao Auxiliar da MontaProject                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function StartProject(cProjeti,cVersao,cProjetf,dDataRef,cNivel,cFase)

Local aAreaAF8	:= AF8->(GetArea())
Local nQuantTask := 0
Local nTask     := 0
Local x         := 0
Local cCalend   := ""
Local aCalend   := {}
Local aCalBase  := {PJSUNDAY, PJMONDAY, PJTUESDAY, PJWEDNESDAY, PJTHURSDAY, PJFRIDAY, PJSATURDAY}
Local lWork     := .T.
Local nNivAtu	:= 1
Local nx        := 1
Local aProject  := {}
Local nCount    := 1
Local nProject  := 1
Local cAlTemp   := ""
Local cRecurso  := ""
Local cStartNiv := ""
Local nPos1     := 0
Local nPos2     := 0
Local cRec      := ""
Local nnCount   := 0

DbSelectArea("AF8")
DbSetOrder(1)
If Empty(cProjeti)
	DbGoTop()
Else
	MsSeek(xFilial("AF8")+cProjeti)
EndIf

oApp := MsProject():New()
oApp:VISIBLE:= .T.

oApp:Projects:Add()

//oApp:Caption := rTrim(AF8->AF8_DESCRI)

oApp:TableEdit( 'Ap6View', .T.,.T. , .T.,    ,'ID' ,               ,                  , 6, PJCENTER, .T., .T., PJDATEDEFAULT, 1, ,PJCENTER )
oApp:TableEdit( 'Ap6View', .T.,    , .T.,    ,     , 'Text1'       , STR0008         , 15,  PJLEFT, .T., .T., PJDATEDEFAULT, 1, ,PJCENTER ) //'Codigo'
oApp:TableEdit( 'Ap6View', .T.,    , .T.,    ,     , 'Name'        , STR0009 , 24,  PJLEFT, .T., .T., PJDATEDEFAULT, 1, ,PJCENTER ) //'Nome da Tarefa'
oApp:TableEdit( 'Ap6View', .T.,    , .T.,    ,     , 'Duration'    , STR0010        ,  9, PJRIGHT, .T., .T., PJDATEDEFAULT, 1, ,PJCENTER ) //"Dura็ใo"
oApp:TableEdit( 'Ap6View', .T.,    , .T.,    ,     , 'Start'       , STR0011         , 12, PJRIGHT, .T., .T., PJDATEDEFAULT, 1, ,PJCENTER ) //"Inicio"
oApp:TableEdit( 'Ap6View', .T.,    , .T.,    ,     , 'Finish'      , STR0012            , 12, PJRIGHT, .T., .T., PJDATEDEFAULT, 1, ,PJCENTER ) //"Fim"
oApp:TableEdit( 'Ap6View', .T.,    , .T.,    ,     , '% Complete'  , STR0013    , 12,  PJLEFT, .T., .T., PJDATEDEFAULT, 1, ,PJCENTER ) //"% Concluida"
oApp:TableApply( 'Ap6View' )

//Criar o calendario

dbSelectArea("SH7")
DbSetOrder(1)
MsSeek(xFilial("SH7"))
do While ! Eof() .And. SH7->H7_FILIAL == xFilial("SH7")
	cCalend := SH7->H7_CODIGO
	oApp:BaseCalendarCreate(cCalend)
	aCalend := PmsCalend(SH7->H7_CODIGO)
	For x := 1 to Len(aCalend)
		lWork := !Empty(aCalend[x, 2]) .or. !Empty(aCalend[x, 3]) .or. ;
			!Empty(aCalend[x, 4]) .or. !Empty(aCalend[x, 5]) .or. ;
			!Empty(aCalend[x, 6]) .or.  !Empty(aCalend[x, 7]) .or. ;
			!Empty(aCalend[x, 8]) .or. !Empty(aCalend[x, 9]) .or. ;
			!Empty(aCalend[x, 10]) .or. !Empty(aCalend[x, 11])

		oApp:BaseCalendarEditDays(cCalend, , , aCalBase[aCalend[x, 1]], lWork ,aCalend[x, 2], aCalend[x, 3],;
		aCalend[x, 4], aCalend[x, 5],aCalend[x, 6], aCalend[x, 7],,aCalend[x, 8], aCalend[x, 9],;
		aCalend[x, 10], aCalend[x, 11])
	Next
	dbSkip()
Enddo

DbSelectArea("AF8")

While !Eof() .and. xFilial()+AF8->AF8_PROJET >= AF8->AF8_FILIAL+cProjeti .and. ;
		AF8->AF8_PROJET <= cProjetf
	If PmrPertence(AF8_FASE,cFase) .and. PmrPertence(AF8_REVISA,cVersao)
		PMS2TreeEDT(,AF8->AF8_REVISA,@aProject,"AF9,AF8,AFA,AFB,AFC" ,;
			{|| PmrPertence(If(Alias() == "AFC", AFC->AFC_NIVEL, AF9->AF9_NIVEL),cNivel)})
	EndIf
	DbSelectArea("AF8")
	DbSkip()
Enddo

For nCount := 1 to Len(aProject) // projetos

	oApp:Projects(1):Tasks:Add(aProject[nCount,nProject,2])

	nQuantTask += 1

	DbSelectArea("AF8")

	DbGoto(aProject[nCount,nProject,3])
	//Projeto
	oApp:Projects(1):Tasks(nQuantTask):Text1 := AF8->AF8_PROJET
	oApp:Projects(1):Tasks(nQuantTask):Start := Dtoc(AF8->AF8_START) + " 23:59:59"
	oApp:Projects(1):Tasks(nQuantTask):Duration := "0 h"

	For nnCount := 2 to Len(aProject[nCount]) // tarefas
		// montando tarefas
		cAlTemp := aProject[nCount,nncount,4] // alias Temporario

		DbSelectArea(cAlTemp)

		If cAlTemp $ "AF9,AFC"
		
			DbGoto(aProject[nCount,nncount,3])

			oApp:Projects(1):Tasks:Add(&(cAlTemp+"_DESCRI"))
			
			If Empty(cStartNiv)
				cStartNiv := &(cAlTemp+"_NIVEL")
			EndIf

			nQuantTask += 1

			cRecurso  := ""

			aadd(aProject[nCount,nncount],nQuantTask)

			oApp:Projects(1):Tasks(nQuantTask):Calendar := &(cAlTemp+"_CALEND")
			cCalend := &(cAlTemp+"_CALEND")
			If cAlTemp == "AF9"
				oApp:Projects(1):Tasks(nQuantTask):Text1 := &(cAlTemp+"_TAREFA")
			Else
				oApp:Projects(1):Tasks(nQuantTask):Text1 := &(cAlTemp+"_EDT")
			EndIf
			oApp:Projects(1):Tasks(nQuantTask):Text2 := &(cAlTemp+"_NIVEL")
			oApp:Projects(1):Tasks(nQuantTask):Text3 := IF(Alias() == "AF9","TASK","EDT")
            If !Empty(&(cAlTemp+"_START"))
				oApp:Projects(1):Tasks(nQuantTask):Start := DTOC(&(cAlTemp+"_START"))  + " " + &(cAlTemp+"_HORAI")
			EndIf
			oApp:Projects(1):Tasks(nQuantTask):Duration := Alltrim(TransForm(&(cAlTemp+"_HDURAC"),"@E 999999999.99")) +' h'

			If aProject[nCount,nncount,6] <> nNivatu
				If aProject[nCount,nncount,6] > nNivAtu
					For nx := 1 To aProject[nCount,nncount,6]- nNivAtu
						oApp:Projects(1):Tasks(nQuantTask):OutLineIndent()
					Next
				Else
					For nx := 1 To nNivAtu - aProject[nCount,nncount,6]
						oApp:Projects(1):Tasks(nQuantTask):OutLineOutdent()
					Next
				EndIf
				nNivAtu := aProject[nCount,nncount,6]
			EndIf
			
		ElseIf cAlTemp $ "AFA,AFB"
		
			DbGoto(aProject[nCount,nncount,3])

			If cAlTemp == "AFA"
				If Empty(AFA_RECURS)
					cRec := ""
					cRecurso += ""
				Else
					DbSelectArea("AE8")
					DbSetOrder(1)
					MsSeek(xFilial("AFA")+AFA->AFA_RECURS)
					cRec := Alltrim(AE8_DESCRI)
					cRecurso += Alltrim(AE8_DESCRI) + "[" + Str(AFA->AFA_ALOC,4)  + "]% "
				EndIf

			Else
				If Empty(AFB_RECURS)
					cRec := ""
					cRecurso += ""
				Else
					DbSelectArea("AE8")
					DbSetOrder(1)
					MsSeek(xFilial("AFB")+AFB->AFB_RECURS)
					cRec := Alltrim(AE8_DESCRI)
					cRecurso += Alltrim(AE8_DESCRI) + "[" + Str(AFB->AFB_ALOC,4)  + "]% "
				EndIf
			EndIf
			If !Empty(cRec)
			
				oApp:Projects(1):Resources:Add( cRec )

				SH7->( MsSeek( xFilial("SH7") + AE8->AE8_CALEND ) )
				aCalend := PmsCalend( SH7->H7_CODIGO )
				For x := 1 to Len(aCalend)
					lWork := !Empty(aCalend[x, 2]) .or. !Empty(aCalend[x, 3]) .or. ;
					!Empty(aCalend[x, 4]) .or. !Empty(aCalend[x, 5]) .or. ;
					!Empty(aCalend[x, 6]) .or.  !Empty(aCalend[x, 7]) .or. ;
					!Empty(aCalend[x, 8]) .or. !Empty(aCalend[x, 9]) .or. ;
					!Empty(aCalend[x, 10]) .or. !Empty(aCalend[x, 11]) //rTrim(AF8->AF8_DESCRI)
						oApp:ResourceCalendarEditDays("Projeto1",cRec, , aCalBase[aCalend[x, 1]], lWork ,aCalend[x, 2], aCalend[x, 3],;
						aCalend[x, 4], aCalend[x, 5],aCalend[x, 6], aCalend[x, 7],,aCalend[x, 8], aCalend[x, 9],;
						aCalend[x, 10], aCalend[x, 11])
				Next
				oApp:Projects(1):Tasks(nQuantTask):ResourceNames := cRecurso
				oApp:Projects(1):Tasks(nnCount):SetField( "Calendแrio base",cCalend )
				If AE8->AE8_TIPO == "1"
					oApp:Projects(1):Tasks(nnCount):SetField( "PJTASKRESOURCETYPE","MATERIAL" )
				ElseIf AE8->AE8_TIPO == "2"
					oApp:Projects(1):Tasks(nnCount):SetField( "PJTASKRESOURCETYPE","TRABALHO" )
				EndIf
			EndIf
		EndIf
	Next

	For nnCount := 1 to len(aProject[nCount])
		If aProject[nCount,nnCount,4] == "AF9"

			DbSelectArea("AF9")
			DbGoto(aProject[nCount,nnCount,3])
			DbSelectArea("AFD")
			DbSetOrder(1)

			If MsSeek(xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
				If (nTask := Ascan(aProject[nCount],{|x| x[1] == AllTrim(AFD->AFD_PREDEC) .and. x[4] == "AF9"})) > 0
					nPos1 := Len(aProject[nCount,nnCount])
					nPos2 := Len(aProject[nCount,nTask])
					Do Case
						Case AFD->AFD_TIPO == "1"
							oApp:LinkTasksEdit( aProject[nCount,nTask,npos2],aProject[nCount,nnCount,npos1],,PJFINISHTOSTART,Alltrim(Str(AFD->AFD_HRETAR)) + " h")
						Case AFD->AFD_TIPO == "2"
							oApp:LinkTasksEdit( aProject[nCount,nTask,Len(aProject[nCount,nTask])],aProject[nCount,nnCount,Len(aProject[nCount,nnCount])],,PJSTARTTOSTART,Alltrim(Str(AFD->AFD_HRETAR)) + " h")
						Case AFD->AFD_TIPO == "3"
							oApp:LinkTasksEdit( aProject[nCount,nTask,Len(aProject[nCount,nTask])],aProject[nCount,nnCount,Len(aProject[nCount,nnCount])],,PJFINISHTOFINISH,Alltrim(Str(AFD->AFD_HRETAR)) + " h")
						Case AFD->AFD_TIPO == "4"
							oApp:LinkTasksEdit( aProject[nCount,nTask,Len(aProject[nCount,nTask])],aProject[nCount,nnCount,Len(aProject[nCount,nnCount])],,PJSTARTTOFINISH,Alltrim(Str(AFD->AFD_HRETAR)) + " h")
					EndCase
				EndIf
			EndIf
		EndIf

		DbSelectArea("AFF")
		DbSetOrder(1)
		If !AFF->(MsSeek(xFilial("AFF") +AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA +dtos(dDataRef),.T.))
			If	xFilial("AF9")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA <>;
				xFilial("AFF")+AFF->AFF_PROJET+AFF->AFF_REVISA+AFF->AFF_TAREFA .or. ;
				AFF->AFF_DATA > dDataRef
				AFF->(DbSkip(-1))
			EndIf
			If 	xFilial("AF9")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA == ;
				xFilial("AFF")+AFF->AFF_PROJET+AFF->AFF_REVISA+AFF->AFF_TAREFA .and. ;
				AFF->AFF_DATA < dDataRef
				oApp:Projects(1):Tasks(nnCount):SetField( "PJTASKPERCENTCOMPLETE", Round( (AFF->AFF_QUANT*100)/AF9->AF9_QUANT , 0) )
			Else
				oApp:Projects(1):Tasks(nnCount):SetField( "PJTASKPERCENTCOMPLETE", 0 )
			EndIf
		Else
//			oApp:Projects(1):Tasks(nnCount):SetField( "PJTASKPERCENTCOMPLETE", Round( (AFF->AFF_QUANT*100) /AF9->AF9_QUANT , 0) )
			oApp:Projects(1):Tasks(nnCount):SetField( "PJTASKPERCENTCOMPLETE", Round( (AFF->AFF_QUANT*100) /AF9->AF9_QUANT , 0) )
		EndIf
	Next

	oApp:Projects(1):Tasks:Add("")

	nQuantTask += 1

	For nx := 1 To nNivatu -= 1
		oApp:Projects(1):Tasks(nQuantTask):OutLineOutdent()
	Next nx

	nNivAtu := 1

	oApp:Projects(1):Tasks(nQuantTask):Text1 := ""
	oApp:Projects(1):Tasks(nQuantTask):Start := "01/01/00"
	oApp:Projects(1):Tasks(nQuantTask):Duration := "0 h"

	cStartNiv := ""

Next
RestArea(aAreaAF8)
Return oApp

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsFoll   บAutor  ณMichel Dantas       บ Data ณ  23/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao Auxiliar da MontaProject                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PmsFoll()
Local oDlg,oBut,oBold,oApp

Private cProjeti := Space(Len(CriaVar("AF8_PROJET")))
Private cProjetf := Replicate("Z",Len(CriaVar("AF8_PROJET")))
Private cNivel   := Space(20)
Private cFase    := Space(20)
Private cVersao  := Space(20)
Private dDataRef := dDataBase

DEFINE MSDIALOG oDlg TITLE STR0005 FROM 0,0 TO 150,350 OF oMainWnd PIXEL //"Aguarde"

@ 0, 0 BITMAP RESNAME BMP_LOGIN oF oDlg SIZE 30, (oDlg:nBottom/2.3) ADJUST WHEN .F. PIXEL NOBORDER

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

@ 03, 40 SAY STR0004 FONT oBold PIXEL //"Integracao com o MsProject"

@ 14, 30 TO 16 ,400 LABEL "" OF oDlg PIXEL

@ 20, 30 SAY STR0045 PIXEL //"Para finalizar tecle em concluir"

@ (oDlg:nBottom/2.4)-7, 132 BUTTON oBut PROMPT STR0046 SIZE 35,10 ACTION ( oDlg:End() ) PIXEL //"Concluir"

ACTIVATE MSDIALOG oDlg CENTERED;
	ON INIT( oDlg:Hide(),If(PmsPergPrj(),MsgRun(STR0047,,; //"Aguarde, exportando ao MsProject"
		{||oApp := StartProject(cProjeti,cVersao,cProjetf,dDataRef,cNivel,cFase)}),;
		oDlg:End()),oDlg:Show() );
	VALID(If(oApp <> NIL,PmsIprtProj(oApp),.T.))

If oApp # NIL	
	oApp:Quit()
	oApp:Destroy()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsFoll   บAutor  ณMichel Dantas       บ Data ณ  23/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao Auxiliar da MontaProject                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PmsIprtProj(oApp)
Local lOk      := .T.
/*
nTask := oApp:Projects(1):Tasks:Count
For x := 1 to nTask
	Aadd(aProject,{})
	Aadd(aProject[Len(aProject)],oApp:Projects(1):Tasks(x):Name          )//1
	Aadd(aProject[Len(aProject)],oApp:Projects(1):Tasks(x):Text1         )//2
	Aadd(aProject[Len(aProject)],oApp:Projects(1):Tasks(x):Start         )//3
	Aadd(aProject[Len(aProject)],oApp:Projects(1):Tasks(x):Duration      )//4
	Aadd(aProject[Len(aProject)],oApp:Projects(1):Tasks(x):Calendar      )//5
	Aadd(aProject[Len(aProject)],oApp:Projects(1):Tasks(x):Text2         )//6
	Aadd(aProject[Len(aProject)],oApp:Projects(1):Tasks(x):Text3         )//7
	Aadd(aProject[Len(aProject)],oApp:Projects(1):Tasks(x):Start         )//8
	Aadd(aProject[Len(aProject)],oApp:Projects(1):Tasks(x):Duration      )//9
	Aadd(aProject[Len(aProject)],oApp:Projects(1):Tasks(x):ResourceNames )//10
	Aadd(aProject[Len(aProject)],oApp:Projects(1):Tasks(x):GetField( "PJTASKPERCENTCOMPLETE"))//11
Next
*/
Return lOk