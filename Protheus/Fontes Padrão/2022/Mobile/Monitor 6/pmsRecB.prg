#include "_pmspalm.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³VldHora   ºAutor  ³Reynaldo Miyashita  º Data ³  12.08.04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ valida a hora                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cHorario - Hora a ser validado                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Palm                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VldHora(cHorario)

	Local cHora    := ""
	Local cMinuto  := ""

	Local lRetorno := .F.

	Local nAchou  := 0
	Local nPosMin := 0

	cHora 	:= Substr(cHorario, 1, 2)
	nAchou 	:= At(":", cHorario)  //Verificar se a hora foi passada no formato 99:99 ou 9999
	nPosMin := If(nAchou > 0, nAchou + 1, 3)
	
	If Empty(cHorario)
		lRetorno := .T.
	Else
		cMinuto  := Substr(cHorario, nPosMin, 2)
	
		If ((cHora >= "00" .And. cHora < "24") .And. (cMinuto >= "00" .And. cMinuto < "60"))
			lRetorno := .T.
		Else
			MsgAlert("Hora invalido. Utilize o formato hh:mm.")
		EndIf
	EndIf
Return lRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AjustaHora³ Autor ³ Reynaldo Miyashita    ³ Data ³ 16.08.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajusta a hora informada conforme a parametrizacao do         ³±±
±±³          ³ MV_PRECISA na tabela SX6.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±º          ³ cHora   - Hora a ser validado                                º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PALMPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AjustaHora(cHora)
	Local nX 		:= 0
	Local nInterv   := 0
	Local nPrecisa  := 0

	nPrecisa  := GetMV("MV_PRECISA")

	nInterv := 60 / nPrecisa

	For nX := 1 to nPrecisa 
		Do Case 
			Case nX == 1
				If Val(Substr(cHora,4,2)) < nInterv
					If Val(Substr(cHora,4,2)) < nInterv / 2 
						cHora := Substr(cHora,1,3)+"00"
						Exit
					Else
						cHora := Substr(cHora,1,3) + LTrim(Str(nInterv))
						Exit
					EndIf
				EndIf
	
			Case nX > 1 .And. nX < nPrecisa 
				If Val(Substr(cHora,4,2)) > (nInterv*(nX-1)) .AND. Val(Substr(cHora,4,2)) < (nInterv*nX)
					If Val(Substr(cHora,4,2)) < ((nInterv*nX)-(nInterv/2))
						cHora := Substr(cHora,1,3) + LTrim(Str(nInterv*(nX-1)))
						Exit
					Else
						cHora := Substr(cHora,1,3) + LTrim(Str(nInterv*nX))
						Exit
					EndIf
				EndIf
				
			Case nX == nPrecisa 
				If Val(Substr(cHora,4,2)) > (nInterv*(nX-1)) .And. Val(Substr(cHora,4,2)) < (nInterv*nX)
					If Val(Substr(cHora,4,2)) < ((nInterv*nX)-(nInterv/2)) .And. Val(Substr(cHora,4,2)) > nInterv*(nX-1)
						cHora := Substr(cHora,1,3) + LTrim(Str(nInterv*(nX-1)))
						Exit
					Else
						cHora := StrZero(Val(Substr(cHora,1,2))+1,2) + ":00"
						Exit
					EndIf
				EndIf
				
		EndCase
	Next
Return cHora


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsHrUtil³ Autor ³ Edson Maricate         ³ Rev. ³ 15-08-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o numero de horas uteis em uma determinada Data.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Expc1 : Codigo da Filial                                      ³±±
±±³          ³ExpC2 : Codigo do Projeto                                     ³±±
±±³          ³ExpC3 : Codigo do Recurso                                     ³±±
±±³          ³ExpD4 : Data                                                  ³±±
±±³          ³ExpC5 : Hora Inicial   ("XX:XX")                              ³±±
±±³          ³ExpC6 : Hora Final     ("XX:XX")                              ³±±
±±³          ³ExpC7 : Codigo do Calendario                                  ³±±
±±³          ³ExpC8 : Array contento a string de aloc. calendario (Opcional)³±±
±±³          ³ExpN9 : Tamanho do bloco por dia (Opcional)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSPALM                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsHrUtil(cFilial, cProjeto, cRecurso, dData, cHoraIni, cHoraFim, cCalend, cAloc, nTamanho)
	Local nHoras    := 0
	Local nDayWeek  := DoW(dData)
	Local nMinBit   := 0
	Local nBitIni   := 0
	Local nBitFim   := 0
	Local nPrecisa  := 0
	Local i := 0
	Local j := 1

	nPrecisa := GetMV("MV_PRECISA")
	nDayWeek := If(nDayWeek==1, 7, nDayWeek-1)

	nMinBit := 60 / nPrecisa
	//Alert(nMinBit)
	//Alert(nPrecisa)
	nBitIni := Round((Val(Substr(cHoraIni, 1, 2)) * 60 + Val(Substr(cHoraIni, 4, 2))) / nMinBit, 0) + 1
	nBitFim := Round((Val(Substr(cHoraFim, 1, 2)) * 60 + Val(Substr(cHoraFim, 4, 2))) / nMinBit, 0) + 1

	If cAloc == Nil
		dbSelectArea("SH7")
		SH7->(dbSetOrder(1))  // SH7_FILIAL + SH7_CODIGO
	
		If SH7->(dbSeek(cFilial + cCalend, .F.))
			cAloc    := SH7Decode(SH7->SH7_ALOC)
			
			//For i := 1 To Len(cAloc)
	//			If Asc(Substr(cAloc, i)) == 0
	//				Alert("contem zero" + Str(i))
	//			EndIf
	//		Next
			//Alert(cAloc)
			//Alert(Len(cAloc))
			nTamanho := Len(cAloc) / 7
		Else
			MsgAlert("O calendario Cod. " + cCalend + " não existe. Verifique.")
			cAloc	:= ""
			nTamanho:= 0
		EndIf
	EndIf

	cAloc := Substr(cAloc, (nTamanho * (nDayWeek - 1)) + 1, nTamanho)

	dbSelectArea("AFY")
	dbSetOrder(1)
	If dbSeek(cFilial + dtoc(dData))
		While !Eof() .And. (cFilial == AFY->AFY_FILIAL) .And. (dtos(dData) == dtos(AFY->AFY_DATA))
			If 	(Empty(AFY->AFY_PROJET) .Or. (AFY->AFY_PROJET == cProjeto)) .And. ;
				(Empty(AFY->AFY_RECURS) .Or. (AFY->AFY_RECURS == cRecurso))
				If FieldPos("HAFY_MALOCA") > 0
					cAloc := HAFY->AFY_MALOCA
				Else
					cAloc := (HAFY->AFY_ALOCA)
				EndIf	
				Exit
			EndIf
			dbSkip()
		End
	EndIf
	
	//Alert(cAloc)
	//Alert(Str(nBitIni) + " " + Str(nBitFim))
	
	//Alert(Substr(cAloc, nBitIni, nBitFim - nBitIni))
	
	//While (j < Len(cAloc))
	//	Alert(Substr(cAloc, j, 80))	
	//	j += 80
	//End
	
	//Alert(Substr(cAloc, 01, 28))
	//Alert(Substr(cAloc, 29, 96))
	//Alert(Substr(cAloc, 125, 96))
	//Alert(Substr(cAloc, 221, 96))
	//Alert(Substr(cAloc, 317, 96))
	//Alert(Substr(cAloc, 413, 46))
	//Alert(Substr(cAloc, 459, 213))
	
	nHoras := (Len(TrocaStr(Substr(cAloc, nBitIni, nBitFim - nBitIni), "0", "")) * nMinBit) / 60
Return nHoras


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TrocaStr ³ Autor ³ Reynaldo Miyashita     ³ Rev. ³ 18-08-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o numero de horas uteis em uma determinada Data.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : string a ser modificado                               ³±±
±±³          ³ExpC2 : string a ser procurada                                ³±±
±±³          ³ExpC3 : string a ser substituida                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSPALM                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TrocaStr(cTexto ,cPesq ,cRepl)
	Local nC := 0
	Local cChar := ""
	Local cNewText := ""

	For nC := 1 to len(cTexto)
		
		If SubStr(cTexto,nC,1) == cPesq
			cNewText += cRepl
		Else
			cNewText += SubStr(cTexto,nC,1) 
		EndIf
		
	Next
Return cNewText


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³HoraIApp ³ Autor ³ Reynaldo Miyashita     ³ Rev. ³ 18-08-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se a hora inicial já nao foi apontada.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cHoraI   - string com a hora inicial                          ³±±
±±³          ³cHoraF   - string com a hora final                            ³±±
±±³          ³aAFUItem - array com o apontamento atual                      ³±±
±±³          ³aItens   - array com todos apontamentos                       ³±±
±±³          ³nSelItem - posicao do apontamento na alteracao no array aItens³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSPALM                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HoraIApp( cHoraI ,cHoraF ,aAFUItem ,aItens ,nSelItem )
	Local lExiste := .F.
	Local nC := 0

	Default nSelItem := 0 

	For nC := 1 To len( aItens )
		If    aItens[nC][SUB_AFU_FILIAL]     == aAFUItem[SUB_AFU_FILIAL] ;
		.AND. aItens[nC][SUB_AFU_RECURS]     == aAFUItem[SUB_AFU_RECURS] ;
		.AND. dtos(aItens[nC][SUB_AFU_DATA]) == dtos(aAFUItem[SUB_AFU_DATA])
		
			If (Substr(cHoraI,1,2) + Substr(cHoraI,4,2) >= Substr(aItens[nC][SUB_AFU_HORAI],1,2) + Substr(aItens[nC][SUB_AFU_HORAI],4,2) .And.;
				Substr(cHoraI,1,2) + Substr(cHoraI,4,2) <= Substr(aItens[nC][SUB_AFU_HORAF],1,2) + Substr(aItens[nC][SUB_AFU_HORAF],4,2));
				.Or. ;
			   (Substr(cHoraI,1,2) + Substr(cHoraI,4,2) <= Substr(aItens[nC][SUB_AFU_HORAI],1,2) + Substr(aItens[nC][SUB_AFU_HORAI],4,2) .And.;
				Substr(cHoraF,1,2) + Substr(cHoraF,4,2) >= Substr(aItens[nC][SUB_AFU_HORAI],1,2) + Substr(aItens[nC][SUB_AFU_HORAI],4,2))
				// se for o registro em edicao deve ignorar.
				If nSelItem != nC
					MsgAlert("Ja existem apontamentos gravados para este recurso neste periodo. Verifique a hora informada", APP_NAME)
					lExiste  := .T.
					Exit
				EndIf
			EndIf
		EndIf
	Next
Return lExiste


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³HoraFApp ³ Autor ³ Reynaldo Miyashita     ³ Rev. ³ 18-08-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se a hora final já nao foi apontada.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cHoraI   - string com a hora inicial                          ³±±
±±³          ³cHoraF   - string com a hora final                            ³±±
±±³          ³aAFUItem - array com o apontamento atual                      ³±±
±±³          ³aItens   - array com todos apontamentos                       ³±±
±±³          ³nSelItem - posicao do apontamento na alteracao no array aItens³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSPALM                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HoraFApp( cHoraI ,cHoraF ,aAFUItem ,aItens ,nSelItem )
	Local lExiste := .F.
	Local nC := 0

	Default nSelItem := 0 

	For nC := 1 To len( aItens )
		If    aItens[nC][SUB_AFU_FILIAL]     == aAFUItem[SUB_AFU_FILIAL] ;
		.AND. aItens[nC][SUB_AFU_RECURS]     == aAFUItem[SUB_AFU_RECURS] ;
		.AND. dtos(aItens[nC][SUB_AFU_DATA]) == dtos(aAFUItem[SUB_AFU_DATA])
		
			If (Substr(cHoraF,1,2) + Substr(cHoraF,4,2) >= Substr(aItens[nC][SUB_AFU_HORAI],1,2) + Substr(aItens[nC][SUB_AFU_HORAI],4,2) .And.;
				Substr(cHoraF,1,2) + Substr(cHoraF,4,2) <= Substr(aItens[nC][SUB_AFU_HORAF],1,2) + Substr(aItens[nC][SUB_AFU_HORAF],4,2));
				.Or.;
				(Substr(cHoraF,1,2) + Substr(cHoraF,4,2) >= Substr(aItens[nC][SUB_AFU_HORAF],1,2) + Substr(aItens[nC][SUB_AFU_HORAF],4,2) .And.;
				Substr(cHoraI,1,2) + Substr(cHoraI,4,2) <= Substr(aItens[nC][SUB_AFU_HORAF],1,2) + Substr(aItens[nC][SUB_AFU_HORAF],4,2))
				// se for o registro em edicao deve ignorar.
				If nSelItem != nC
					MsgAlert("Ja existem apontamentos gravados para este recurso neste periodo. Verifique a hora informada", APP_NAME)
					lExiste  := .T.
					Exit
				EndIf
			EndIf
		EndIf
	Next 
Return lExiste


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GetMV    ³ Autor ³ Reynaldo Miyashita     ³ Rev. ³ 23-08-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o valor do parametro solicitado.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cParam - parametro desejado                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSPALM                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GetMV(cParam)
	Local uReturn := Nil
	Local nCount  := 0

	If SX6->(dbSeek(Space(02) + cParam ))
		//Alert("str: " + SX6->X6_CONTEUD)
	
		Do Case
			Case SX6->X6_TIPO == "N"
				uReturn := Val(SX6->X6_CONTEUD)

			Case SX6->X6_TIPO == "D"
				uReturn := CToD(SX6->X6_CONTEUD)

			Otherwise
				uReturn := SX6->X6_CONTEUD
		EndCase
	EndIf
Return uReturn