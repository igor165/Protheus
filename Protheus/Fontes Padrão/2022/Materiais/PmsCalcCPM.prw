#include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsCalcCPM³ Autor ³ Edson Maricate        ³ Data ³ 09-06-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de calculo da data mais cedo e data mais tarde das     ³±±
±±³          ³tarefas do projeto.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PmsCalcCPM(cProjeto,cRevisa,cTrfDe,cTrfAte)

Local nx
Local aEDT		:= {}

Local aArea		:= GetArea()
Local aTasks	:= {}

DEFAULT cTrfDe		:= ""
DEFAULT cTrfAte		:= "ZZZZZZZZZZZZ"

dbSelectArea("AFC")
dbSetOrder(1)
If MsSeek(xFilial()+cProjeto+cRevisa+cProjeto+(SPACE(2)))

	dbSelectArea("AF9")
	dbSetOrder(1)
	MsSeek(xFilial()+cProjeto+cRevisa+cTrfDe,.T.)
	While !Eof().And.AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA==;
						xFilial("AF9")+cProjeto+cRevisa .And. AF9->AF9_TAREFA <= cTrfAte
		AuxRelMCMT(cProjeto,cRevisa,AF9->AF9_TAREFA,aTasks)
		dbSelectArea("AF9")
		dbSkip()
	End
/*
		aAdd(aTasks,
		{	1 - cTarefa,;
		 	2 - AF9->AF9_START,;
		 	3 - AF9->AF9_HORAI,;
		 	4 - AF9->AF9_FINISH,;
		 	5 - AF9->AF9_HORAF,;
		 	6 - .F.,;
		 	7 - .F.,;
		 	8 - AF9->(RecNo()),;
		 	9 - {},;
		 	10 -{},;
		 	11 - {AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF},;
		 	12 - {AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF}
		 })

*/
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula a data mais cedo                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nx := 1 to Len(aTasks)
		If !aTasks[nx][6]
			AF9->(MsGoto(aTasks[nx][8]))
			aAuxRet := PMSDTaskF(AFC->AFC_START,AFC->AFC_HORAI,AF9->AF9_CALEND,AF9->AF9_HDURAC,AF9->AF9_PROJET,Nil)
			aTasks[nx][11] := aClone(aAuxRet)
			AuxRelScs(cProjeto,cRevisa,aTasks[nx][1],aTasks,aClone(aTasks[nx][10]),11)
		EndIf 
		If !aTasks[nx][7]
			AF9->(MsGoto(aTasks[nx][8]))
			aAuxRet := PMSDTaskI(AFC->AFC_FINISH,AFC->AFC_HORAF,AF9->AF9_CALEND,AF9->AF9_HDURAC,AF9->AF9_PROJET,Nil)
 			aTasks[nx][12] := aClone(aAuxRet)
 			AuxRelScsI(cProjeto,cRevisa,aTasks[nx][1],aTasks,aClone(aTasks[nx][9]),12)
		EndIf
	Next
	
	For nx := 1 to Len(aTasks)
		If (aTasks[nx][6] .Or. aTasks[nx][7]) .And. DTOS(aTasks[nx][11][1])+aTasks[nx][11][2] < DTOS(AFC->AFC_START)+AFC->AFC_HORAI
			AF9->(MsGoto(aTasks[nx][8]))
			aAuxRet := PMSDTaskF(AFC->AFC_START,AFC->AFC_HORAI,AF9->AF9_CALEND,AF9->AF9_HDURAC,AF9->AF9_PROJET,Nil)	
			aTasks[nx][11] := aClone(aAuxRet)
			AuxRelScs(cProjeto,cRevisa,aTasks[nx][1],aTasks,aClone(aTasks[nx][10]),11)
			AuxRelScsI(cProjeto,cRevisa,aTasks[nx][1],aTasks,aClone(aTasks[nx][9]),11)
		EndIf
		If (aTasks[nx][6] .Or. aTasks[nx][7]) .And. DTOS(aTasks[nx][12][1])+aTasks[nx][12][2] > DTOS(AFC->AFC_FINISH)+AFC->AFC_HORAF
			AF9->(MsGoto(aTasks[nx][8]))
			aAuxRet := PMSDTaskI(AFC->AFC_FINISH,AFC->AFC_HORAF,AF9->AF9_CALEND,AF9->AF9_HDURAC,AF9->AF9_PROJET,Nil)
			aTasks[nx][12] := aClone(aAuxRet)
			AuxRelScs(cProjeto,cRevisa,aTasks[nx][1],aTasks,aClone(aTasks[nx][10]),12)
			AuxRelScsI(cProjeto,cRevisa,aTasks[nx][1],aTasks,aClone(aTasks[nx][9]),12)
		EndIf
	Next nx

	AFC->(dbSetOrder(1))
	For nx := 1 to Len(aTasks)
		AF9->(MsGoto(aTasks[nx][8]))
		AuxAtuEDT(aEDT,cProjeto,cRevisa,AF9->AF9_EDTPAI,ACLONE(aTasks[nx][11]),ACLONE(aTasks[nx][12]))
	Next

EndIf


RestArea(aArea)
Return {aTasks,aEDT}



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AuxRelMCMT³ Autor ³ Edson Maricate        ³ Data ³ 10-06-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carrega as redes de relacionamentos de uma tarefa.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AuxRelMCMT(cProjeto,cRevisa,cTarefa,aTasks)
Local nPosTrf		:= 0
Local aArea			:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAFD	:= AFD->(GetArea())

If aScan(aTasks,{|x| x[1]==cTarefa}) <= 0
	AF9->(dbSetOrder(1))
	If AF9->(MsSeek(xFilial()+cProjeto+cRevisa+cTarefa))
		aAdd(aTasks,{cTarefa,AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,.F.,.F.,AF9->(RecNo()),{},{},{AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF},{AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF}})
		nPosTrf := Len(aTasks)
		dbSelectArea("AFD")
		dbSetOrder(1)
		If dbSeek(xFilial()+cProjeto+cRevisa+cTarefa)
			aTasks[nPosTrf][6]	:= .T.
			While !Eof() .And. xFilial()+cProjeto+cRevisa+cTarefa==AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA
				aAdd(aTasks[nPosTrf][9],AFD->(RecNo()))
				AuxRelMCMT(cProjeto,cRevisa,AFD->AFD_PREDEC,aTasks)
				dbSkip()
			End
		EndIf
		dbSelectArea("AFD")
		dbSetOrder(2)
		If dbSeek(xFilial()+cProjeto+cRevisa+cTarefa)
			aTasks[nPosTrf][7]	:= .T.	
			While !Eof() .And. xFilial()+cProjeto+cRevisa+cTarefa==AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD->AFD_PREDEC
				aAdd(aTasks[nPosTrf][10],AFD->(RecNo()))
				AuxRelMCMT(cProjeto,cRevisa,AFD->AFD_TAREFA,aTasks)
				dbSkip()
			End
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
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AuxRelScs³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a atualizacao das datas das tarefas Sucessoras.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AuxRelScs(cProjeto,cRevisa,cTarefa,aTasks,aRelacs,nPosRet)
Local nx
Local nPosTrf

For nx := 1 to Len(aRelacs)
	AFD->(dbGoto(aRelacs[nx]))
	nPosTrf := aScan(aTasks,{|x| x[1] == AFD->AFD_TAREFA})
	AuxRelPrd(cProjeto,cRevisa,aTasks[nPosTrf][1],aTasks,aClone(aTasks[nPosTrf][9]),nPosRet)
	AuxRelScs(cProjeto,cRevisa,aTasks[nPosTrf][1],aTasks,aClone(aTasks[nPosTrf][10]),nPosRet)
Next nx

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AuxRelPrd³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a atualizacao das datas da tarefa de acordo com as    ³±±
±±³          ³suas predecessoras.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AuxRelPrd(cProjeto,cRevisa,cTarefa,aTasks,aRelacs,nPosRet)

Local nx
Local cHoraF
Local aAuxRet
Local dFinish
Local cCalend
Local nHDurac
Local nRecAF9
Local dStart		:= CTOD("01/01/1980")
Local cHoraI		:= "00:00"
Local nPosTrf		:= aScan(aTasks,{|x| x[1] == cTarefa})

dbSelectArea("AF9")
dbSetOrder(1)
MsSeek(xFilial()+cProjeto+cRevisa+cTarefa)
nRecAF9	:= RecNo()
cCalend	:= AF9->AF9_CALEND
nHDurac	:= AF9->AF9_HDURAC

If Empty(AF9->AF9_DTATUI)
	For nx := 1 to Len(aRelacs)
		AFD->(dbGoto(aRelacs[nx]))					
		nPosRel := aScan(aTasks,{|x| x[1] == AFD->AFD_PREDEC })
		Do Case
			Case AFD->AFD_TIPO=="1" //Fim no Inicio
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(aTasks[nPosRel][nPosRet][3],aTasks[nPosRel][nPosRet][4],AF8->AF8_CALEND,AFD->AFD_HRETAR,AF8->AF8_PROJET,Nil)
					aAuxRet := PMSDTaskF(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF8->AF8_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskF(aTasks[nPosRel][nPosRet][3],aTasks[nPosRel][nPosRet][4],cCalend,nHDurac,AF8->AF8_PROJET,Nil)
				EndIf
			Case AFD->AFD_TIPO=="2" //Inicio no Inicio
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(aTasks[nPosRel][nPosRet][1],aTasks[nPosRel][nPosRet][2],AF8->AF8_CALEND,AFD->AFD_HRETAR,AF8->AF8_PROJET,Nil)
					aAuxRet := PMSDTaskF(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF8->AF8_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskF(aTasks[nPosRel][nPosRet][1],aTasks[nPosRel][nPosRet][2],cCalend,nHDurac,AF8->AF8_PROJET,Nil)
				EndIf
			Case AFD->AFD_TIPO=="3" //Fim no Fim
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(aTasks[nPosRel][nPosRet][3],aTasks[nPosRel][nPosRet][4],AF8->AF8_CALEND,AFD->AFD_HRETAR,AF8->AF8_PROJET,Nil)
					aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF8->AF8_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskI(aTasks[nPosRel][nPosRet][3],aTasks[nPosRel][nPosRet][4],cCalend,nHDurac,AF8->AF8_PROJET,Nil)
				EndIf
			Case AFD->AFD_TIPO=="4" //Inicio no Fim
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(aTasks[nPosRel][nPosRet][1],aTasks[nPosRel][nPosRet][2],AF8->AF8_CALEND,AFD->AFD_HRETAR,AF8->AF8_PROJET,Nil)
					aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF8->AF8_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskI(aTasks[nPosRel][nPosRet][1],aTasks[nPosRel][nPosRet][2],cCalend,nHDurac,AF8->AF8_PROJET,Nil)
				EndIf
			EndCase
			If  (aAuxRet[1]==dStart.And.SubStr(aAuxRet[2],1,2)+SubStr(aAuxRet[2],4,2)>SubStr(cHoraI,1,2)+SubStr(cHoraI,4,2)).Or.;
				(aAuxRet[1] > dStart)
				dStart := aAuxRet[1]
				cHoraI := aAuxRet[2]
				dFinish:= aAuxRet[3]
				cHoraF := aAuxRet[4]
			EndIf
	Next	
	If nPosRet == 11 .OR. ;
	   (nPosRet == 12 .And. ;
	   		((dStart == aTasks[nPosTrf][nPosRet][1] .And. ;
	   			SubStr(cHoraI,1,2)+SubStr(cHoraI,4,2)>SubStr(aTasks[nPosTrf][nPosRet][2],1,2)+SubStr(aTasks[nPosTrf][nPosRet][2],4,2)).Or.;
	   		dStart > aTasks[nPosTrf][nPosRet][1]) .And. ;
	   		((dFinish == aTasks[nPosTrf][nPosRet][3] .And. ;
	   			SubStr(cHoraF,1,2)+SubStr(cHoraF,4,2)>SubStr(aTasks[nPosTrf][nPosRet][4],1,2)+SubStr(aTasks[nPosTrf][nPosRet][4],4,2)).Or.;
	   		dFinish > aTasks[nPosTrf][nPosRet][3]) ;	   		
	   )
		aTasks[nPosTrf][nPosRet] := {dStart,cHoraI,dFinish,cHoraF}
	EndIf	
EndIf

dbSelectArea("AF9")
dbGoto(nRecAF9)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AuxRelScsI³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a atualizacao das datas das tarefas Sucessoras.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AuxRelScsI(cProjeto,cRevisa,cTarefa,aTasks,aRelacs,nPosRet)
Local nx
Local nPosTrf

For nx := 1 to Len(aRelacs)
	AFD->(dbGoto(aRelacs[nx]))
	nPosTrf := aScan(aTasks,{|x| x[1] == AFD->AFD_PREDEC})	
	AuxRelPrdI(cProjeto,cRevisa,aTasks[nPosTrf][1],aTasks,aClone(aTasks[nPosTrf][10]),nPosRet)
	AuxRelScsI(cProjeto,cRevisa,aTasks[nPosTrf][1],aTasks,aClone(aTasks[nPosTrf][9]),nPosRet)
Next nx

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AuxRelPrdI³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a atualizacao das datas da tarefa de acordo com as    ³±±
±±³          ³suas predecessoras.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AuxRelPrdI(cProjeto,cRevisa,cTarefa,aTasks,aRelacs,nPosRet)

Local nx
Local cHoraF
Local aAuxRet
Local dFinish
Local cCalend
Local nHDurac
Local nRecAF9
Local dStart		:= CTOD("31/12/9999")
Local cHoraI		:= "00:00"
Local nPosTrf		:= aScan(aTasks,{|x| x[1] == cTarefa})

dbSelectArea("AF9")
dbSetOrder(1)
MsSeek(xFilial()+cProjeto+cRevisa+cTarefa)
nRecAF9	:= RecNo()
cCalend	:= AF9->AF9_CALEND
nHDurac	:= AF9->AF9_HDURAC

If Empty(AF9->AF9_DTATUI)
	For nx := 1 to Len(aRelacs)
		AFD->(dbGoto(aRelacs[nx]))
			nPosRel := aScan(aTasks,{|x| x[1] == AFD->AFD_TAREFA })
			Do Case
				Case AFD->AFD_TIPO=="4" //Fim no Inicio
					If !Empty(AFD->AFD_HRETAR)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aAuxRet := PMSADDHrs(aTasks[nPosRel][nPosRet][3],aTasks[nPosRel][nPosRet][4],AF8->AF8_CALEND,AFD->AFD_HRETAR,AF8->AF8_PROJET,Nil)
						aAuxRet := PMSDTaskF(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF8->AF8_PROJET,Nil)
					Else
						aAuxRet := PMSDTaskF(aTasks[nPosRel][nPosRet][3],aTasks[nPosRel][nPosRet][4],cCalend,nHDurac,AF8->AF8_PROJET,Nil)
					EndIf
				Case AFD->AFD_TIPO=="2" //Inicio no Inicio
					If !Empty(AFD->AFD_HRETAR)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aAuxRet := PMSADDHrs(aTasks[nPosRel][nPosRet][1],aTasks[nPosRel][nPosRet][2],AF8->AF8_CALEND,AFD->AFD_HRETAR,AF8->AF8_PROJET,Nil)
						aAuxRet := PMSDTaskF(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF8->AF8_PROJET,Nil)
					Else
						aAuxRet := PMSDTaskF(aTasks[nPosRel][nPosRet][1],aTasks[nPosRel][nPosRet][2],cCalend,nHDurac,AF8->AF8_PROJET,Nil)
					EndIf
				Case AFD->AFD_TIPO=="3" //Fim no Fim
					If !Empty(AFD->AFD_HRETAR)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aAuxRet := PMSADDHrs(aTasks[nPosRel][nPosRet][3],aTasks[nPosRel][nPosRet][4],AF8->AF8_CALEND,AFD->AFD_HRETAR,AF8->AF8_PROJET,Nil)
						aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF8->AF8_PROJET,Nil)
					Else
						aAuxRet := PMSDTaskI(aTasks[nPosRel][nPosRet][3],aTasks[nPosRel][nPosRet][4],cCalend,nHDurac,AF8->AF8_PROJET,Nil)
					EndIf
				Case AFD->AFD_TIPO=="1" //Inicio no Fim
					If !Empty(AFD->AFD_HRETAR)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aAuxRet := PMSADDHrs(aTasks[nPosRel][nPosRet][1],aTasks[nPosRel][nPosRet][2],AF8->AF8_CALEND,AFD->AFD_HRETAR,AF8->AF8_PROJET,Nil)
						aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF8->AF8_PROJET,Nil)
					Else
						aAuxRet := PMSDTaskI(aTasks[nPosRel][nPosRet][1],aTasks[nPosRel][nPosRet][2],cCalend,nHDurac,AF8->AF8_PROJET,Nil)
					EndIf
			EndCase
			If  (aAuxRet[1]==dStart.And.SubStr(aAuxRet[2],1,2)+SubStr(aAuxRet[2],4,2)<SubStr(cHoraI,1,2)+SubStr(cHoraI,4,2)).Or.;
				(aAuxRet[1] < dStart)
				dStart := aAuxRet[1]
				cHoraI := aAuxRet[2]
				dFinish:= aAuxRet[3]
				cHoraF := aAuxRet[4]
			EndIf
	Next	
	If nPosRet == 11 .OR. ;
	   (nPosRet == 12 .And. ;
   			((dStart == aTasks[nPosTrf][nPosRet][1] .And. ;
   				SubStr(cHoraI,1,2)+SubStr(cHoraI,4,2)>SubStr(aTasks[nPosTrf][nPosRet][2],1,2)+SubStr(aTasks[nPosTrf][nPosRet][2],4,2)).Or.;
   				dStart > aTasks[nPosTrf][nPosRet][1]) .And. ;
   			((dFinish == aTasks[nPosTrf][nPosRet][3] .And. ;
   				SubStr(cHoraF,1,2)+SubStr(cHoraF,4,2)>SubStr(aTasks[nPosTrf][nPosRet][4],1,2)+SubStr(aTasks[nPosTrf][nPosRet][4],4,2)).Or.;
   				dFinish > aTasks[nPosTrf][nPosRet][3]) ;	   		
   		)
		aTasks[nPosTrf][nPosRet] := {dStart,cHoraI,dFinish,cHoraF}
	EndIf	
EndIf

dbSelectArea("AF9")
dbGoto(nRecAF9)
	

Return


Static Function AuxAtuEDT(aEDT,cProjeto,cRevisa,cEDT,aAuxCedo,aAuxTarde)

Local aAreaAFC	:= AFC->(GetArea())
Local nPosEDT := aScan(aEDT,{|x| x[1]==cEDT })

If nPosEDT > 0 
	If aAuxCedo[1] < aEDT[nPosEdt][2][1] .Or.(aAuxCedo[1]==aEDT[nPosEdt][2][1] .And. SubStr(aAuxCedo[2],1,2)+SubStr(aAuxCedo[2],4,2)<Substr(aEDT[nPosEdt][2][2],1,2)+Substr(aEDT[nPosEdt][2][2],4,2) )
		aEDT[nPosEDT][2][1] := aAuxCedo[1]
		aEDT[nPosEDT][2][2]	 := aAuxCedo[2]
	EndIf
	If aAuxTarde[1] < aEDT[nPosEdt][3][1] .Or.(aAuxTarde[1]==aEDT[nPosEdt][3][1] .And. SubStr(aAuxTarde[2],1,2)+SubStr(aAuxTarde[2],4,2)<Substr(aEDT[nPosEdt][3][2],1,2)+Substr(aEDT[nPosEdt][3][2],4,2) )
		aEDT[nPosEDT][3][1] := aAuxTarde[1]
		aEDT[nPosEDT][3][2]	 := aAuxTarde[2]
	EndIf
	If aAuxCedo[3] > aEDT[nPosEdt][2][3] .Or.(aAuxCedo[3]==aEDT[nPosEdt][2][3] .And. SubStr(aAuxCedo[4],1,2)+SubStr(aAuxCedo[4],4,2)>Substr(aEDT[nPosEdt][2][4],1,2)+Substr(aEDT[nPosEdt][2][4],4,2) )
		aEDT[nPosEDT][2][3] := aAuxCedo[3]
		aEDT[nPosEDT][2][4]	 := aAuxCedo[4]
	EndIf
	If aAuxTarde[3] > aEDT[nPosEdt][3][3] .Or.(aAuxTarde[3]==aEDT[nPosEdt][3][3] .And. SubStr(aAuxTarde[4],1,2)+SubStr(aAuxTarde[4],4,2)>Substr(aEDT[nPosEdt][3][4],1,2)+Substr(aEDT[nPosEdt][3][4],4,2) )
		aEDT[nPosEDT][3][3] := aAuxTarde[3]
		aEDT[nPosEDT][3][4]	 := aAuxTarde[4]
	EndIf
Else
	aAdd(aEDT,{cEDT,aClone(aAuxCedo),aClone(aAuxTarde)})
EndIf

AFC->(dbSetOrder(1))
If MsSeek(xFilial()+cProjeto+cRevisa+cEDT) .And. !Empty(AFC->AFC_EDTPAI)
	AuxAtuEDT(aEDT,cProjeto,cRevisa,AFC->AFC_EDTPAI,aClone(aAuxCedo),aClone(aAuxTarde))
EndIf

RestArea(aAreaAFC)
Return