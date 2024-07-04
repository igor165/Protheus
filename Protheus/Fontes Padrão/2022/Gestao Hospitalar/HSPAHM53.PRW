#INCLUDE "protheus.CH"
#INCLUDE "HSPAHM28.CH"  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ"HSPAHM53 บ Autor ณ Paulo Jose         บ Data ณ  30/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ GERA A AGENDA MEDICA                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHM53()

Local oFont
Local oDlg
Local aMeses     := {}
Local cMes       := ""
Local bFS_M28	   := {|| INCLUI := .F., ALTERA := .T., LREFRESH := .T., LRESVALID := .T., LMODIFIED := .F., HS_ACJ("GM6", RecNo(), 4), FS_FilM28(.T.)} // Chama a funcao A97
Local bKey_F4	   :=  SetKey(VK_F4, { || Eval(bFS_M28)}) // inicializa a tecla F4
Local bFS_Facili	:= {||FS_FACDIS()} // Facilitador para marcar Disponibilidades
Local aButtons   := {}
Local cCond      := ""
Local lDataAtu   := .T.
Local aSize		:= {}
Local aInfo		:= {}
Local aObjects	:= {}

Private lMostra	:= .T.
Private oAno
Private cAno        := StrZero(Year(Date()), 4)
Private aDataGer    := {}
Private aDiasDisp   := {.F., .F., .F., .F., .F., .F., .F., .F.}     //Dias da Disponibilidade
Private aItensMar   := {}    //Itens Selecionado pela HS_MBrow
Private aHorriosMar := {}    //Horarios Selecionado pela HS_MBrow
Private aCGM8       := {}
Private aHGM8       := {}
Private nUGM8       := 0
Private oMeses
Private oCalend
Private oGM8
Private oGM6
Private oBtnGer
Private oBtnAju
Private oBtnInd
Private oBtnExc
Private oBtnTran
Private oBtnAno1
Private oBtnAno2
Private cDispHor //Disponibilidade que conflitam seu horarios
Private cGm7OriCan  := "0/2"
Private cGm7IdeBlo  := "1"
Private lPromo      := GETNEWPAR("MV_PROSAUD",.F.)

If !Hs_ExisDic({{"T","GT7"}},.T.)
	Return
EndIf

//AjustaSX1()

//Adciona o bota na enchoicebar
Aadd(aButtons	, {"edit_ocean", {||Eval(bFS_M28)}, STR0040})  //"Disp. M้d"
Aadd(aButtons	, {'PARAMETROS', {||Eval(bFS_Facili)}, STR0041})  //"Marca Dis"
Aadd(aButtons	, {STR0070, {|| Processa({|| FS_CONFAGE()})}, STR0070})  //'Confere Horarios'
Aadd(aButtons	, {STR0073, {|| Processa({|| FS_EVENAGE()})}, STR0073})  //

If lPromo
	Aadd(aButtons	, {STR0071, {|| Processa({|| ConSug()})}, STR0071}) //'Agendamentos Sugeridos'
EndIf
aAdd(aMeses, STR0002)  //"JANEIRO"
aAdd(aMeses, STR0003)  //"FEVEREIRO"
aAdd(aMeses, STR0004)  //"MARวO"
aAdd(aMeses, STR0005)  //"ABRIL"
aAdd(aMeses, STR0006)  //"MAIO"
aAdd(aMeses, STR0007)  //"JUNHO"
aAdd(aMeses, STR0008)  //"JULHO"
aAdd(aMeses, STR0009)  //"AGOSTO"
aAdd(aMeses, STR0010)  //"SETEMBRO"
aAdd(aMeses, STR0011)  //"OUTUBRO"
aAdd(aMeses, STR0012)  //"NOVEMBRO"
aAdd(aMeses, STR0013)  //"DEZEMBRO"

cCond := "GM8_CODDIS = '" + GM6->GM6_CODDIS + "' AND GM8_DATAGE >= '" + DTOS(dDataBase) + "' AND GM8_DATAGE <= '" + DToS(LastDay(dDataBase)) + "'"

HS_BDados("GM8", @aHGM8, @aCGM8, @nUGM8, 5, "xx", cCond ,,, "GM8_CODDIS/GM8_FILAGE/GM8_DATAGE/GM8_HORAGE/GM8_TIPAGE/GM8_STATUS",,,,,, .T.)

FS_FilM28(.F.)
aSize := MsAdvSize(.F.)

aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )


DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0069) From aSize[7], 000 To 562, 1030	Of oMainWnd pixel  //"Gera agenda clinica"
oGM6 := HS_MBrow(oDlg, "GM6", {033, 003, 500, 070},,,,,"GM6_OK",, @aItensMar, "GM6_CODDIS",, .T., "HS_M53MB", .T., ;
{"GM6_NOMCRM", "GM6_CODCRM", "GM6_CODDIS", "GM6_DESDIS", "GM6_HORINI", "GM6_HORFIM", "GM6_INTMAR", "GM6_QTENCX"}, "HS_VDisMB")

oGM6:bChange := {||	FS_MaDeCal(oCalend:dDiaAtu, "L"), oCalend:dDiaAtu := FirstDay(oCalend:dDiaAtu), FS_SeleBrw(.F.), oCalend:Refresh()}

oCalend := MsCalend():New(140, 075, oDlg)

@ 130, 003 ListBox oMeses Var cMes Fields Header OemToAnsi(STR0015) Size 070, 120 NoScroll Of oDlg Pixel //"M๊s Atual"
oMeses:SetArray(aMeses)
oMeses:nAt     := month(dDataBase)
oMeses:bLine   := {||{aMeses[oMeses:nAt]}}
oMeses:bChange := {|| FS_MaDeCal( oCalend:dDiaAtu, "L" ), oCalend:dDiaAtu := CToD("01/" + StrZero(oMeses:nAt, 2) + "/" + cAno), oCalend:Refresh(), FS_SeleBrw()}

oCalend:dDiaAtu    := dDataBase
oCalend:nHeight    := 220
oCalend:nWidth     := 280
oCalend:BLDBLCLICK := {|| FS_SeleCal(oCalend:dDiaAtu, "D", .F.)}
oCalend:bChangeMes := {|| oCalend:dDiaIni := FirstDay(oCalend:dDiaAtu), oMeses:nAt := Month(oCalend:dDiaAtu), cAno := StrZero(Year(oCalend:dDiaAtu), 4), oAno:Refresh(), oMeses:Refresh(), oCalend:Refresh(), FS_SeleBrw()}

//Selecao do Ano
@ 130, 075 Button oBtnAno1 Prompt "<" Action (cAno := StrZero(Val(cAno) - 1, 4), oAno:Refresh(), FS_MaDeCal(oCalend:dDiaAtu, "L"), oCalend:dDiaAtu := CToD("01/" + StrZero(oMeses:nAt, 2) + "/" + cAno), oCalend:Refresh(), FS_SeleBrw()) When .T. Size 009, 010 Of oDlg Pixel

@ 130, 105 Button oBtnAno2 Prompt ">" Action (cAno := StrZero(Val(cAno) + 1, 4), oAno:Refresh(), FS_MaDeCal(oCalend:dDiaAtu, "L"), oCalend:dDiaAtu := CToD("01/" + StrZero(oMeses:nAt, 2) + "/" + cAno), oCalend:Refresh(), FS_SeleBrw()) When .T. Size 009,010 Of oDlg Pixel

@ 130, 088 SAY oAno PROMPT OemToAnsi(cAno) Of oDlg SIZE 030,010 FONT oFont Pixel COLOR CLR_RED

oCalend:bChange := {||cAno := StrZero(Year(oCalend:dDiaAtu), 4), oAno:Refresh(), oMeses:nAt := Month(oCalend:dDiaAtu), oMeses:Refresh(), FS_SeleDia(oCalend:dDiaAtu)}

oGM8 := MsNewGetDados():New(150, 218, 250, 500, 0, , , , , , , , , , oDlg , aHGm8, aCGm8)

oBtnGer := tButton():New(265, 070, STR0016, oDlg, {|| FS_MntPerg("G")}, 50, 15,,,, .T.) //"Gerar Agenda   "
oBtnAju := tButton():New(265, 140, STR0017, oDlg, {|| FS_MntPerg("A")}, 50, 15,,,, .T.) //"Ajusta Horแrios"
oBtnInd := tButton():New(265, 210, STR0018, oDlg, {|| FS_MntPerg("I")}, 50, 15,,,, .T.) //"Indisponibiliza"
oBtnExc := tButton():New(265, 280, STR0019, oDlg, {|| FS_MntPerg("E")}, 50, 15,,,, .T.) //"Excluir Horแrios"
oBtnTran:= tButton():New(265, 350, STR0066, oDlg, {|| FS_MntPerg("T")}, 50, 15,,,, .T.) //"Transfer๊ncia"

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| oDlg:End()}, {||oDlg:End()},, aButtons)

SetKey(VK_F4, { || Eval(bKey_F4)})

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_MntAge บ Autor ณ PAULO JOSE         บ Data ณ 06/12/04    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta rotina para gerar a agenda (gm8)                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  (Agenda Ambulatorial)                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_MntAge(dDataInicial, dDataFinal)

Local lRet      := .T.
Local lOkWhil   := .T.
Local nDia      := 0
Local nContFor  := 0
Local nGM8_OK   := aScan(aHGM8, {| aVet | aVet[2] == "GM8_OK    "})
Local cCond     := ""
Local lSele     := .F.    //Se o Mes digitado for diferente do mes da oCalend
Local lVldAge   := .F.
Local nForDias  := 0
Local cDispDias := Space(12)
Local lErro		   := .F.
Local nDiaSem   := 0, lFeriado := 0

INCLUI := .T.

If Month(dDataInicial) # Month(oCalend:dDiaAtu) //verifica se o mes digitado e diferente do mes corrente na oCalend
	lSele := .T.
EndIf

dDataAtu		:= dDataInicial
dDataTemp	    := dDataAtu
oMeses:nAt      := Month(dDataAtu)
oCalend:dDiaAtu := dDataAtu
oCalend:Refresh()

While dDataAtu <= dDataFinal

	If Len(aItensMar) > 0

		//Verifica se ha dia da semana cadastrados(GM5) para esta Disponibilidade
		For nContFor := 1 To Len(aItensMar)
			If !FS_VldDis("GM5", 1, aItensMar[nContFor][1])
				cDispDias := cDispDias + "/" + aItensMar[nContFor][1]
			EndIf
		Next

		If !Empty(cDispDias)
			HS_MsgInf(OemtoAnsi(STR0020 + cDispDias), OemtoAnsi(STR0001), STR0014)  //"Nใo Existe dias lan็ados para estas Disponibilidades :" ###"Aten็ใo"###"Gera agenda m้dica.
			lRet := .F.
		EndIf

		oCalend:Disable()
		oMeses:Disable()

		If lSele //Se for diferente Atualizar as selecao na oCalend
			FS_SeleBrw()
		EndIf
	EndIf

	//Percorre o Vetor de Disponibilidades Selecionadas
	For nContFor := 1 To Len(aItensMar)

		DbSelectarea("GM6")
		DbSetOrder(1) // GM6_FILIAL + GM6_CODDIS
		DbSeek(xFilial("GM6") + aItensMar[nContFor][1])

		oCalend:Disable()
		oMeses:Disable()
		ddata := oCalend:dDiaAtu

		//Quando for selecionada mais de uma Disponibilidade
		If Len(aItensMar) > 1

			FS_aDiaSemLimp()
			FS_LeDiaSe(aItensMar[nContFor][1])

			While cMonth(dData) == cMonth(oCalend:dDiaAtu)

				nDiaSem  := Dow(dData)
				lFeriado := HS_IsFreeDay(dData)

				If (lFeriado .And. aDiasDisp[8] .And. aDiasDisp[nDiaSem]) .Or. ; // Feriado
					(!lFeriado .And. aDiasDisp[nDiaSem])                            // Dias Normais
					FS_MaDeCal(ddata, IIf(lFeriado, "SF", "S"))
				EndIF

				dData++

			EndDo

		EndIf

		//Percorre o Vetor de dias da Semana Selecionadas
		For nForDias := 1 To Len(aDataGer)

			If !Empty(aDataGer[nForDias])
				// Os horarios nao podem ser gerados para datas anteriores a data base do sistema
				If CToD(aDataGer[nForDias] + SubStr(HS_DToC(oCalend:dDiaAtu, 1), 3, 6)) < dDataBase
					Loop
				EndIf

				// Verifica se a faixa de horarios eh valida para o dia informado, nao entrando em conflito
				// com horarios do mesmo CRM ja gerados.
				If CToD(aDataGer[nForDias] + SubStr(HS_DToC(oCalend:dDiaAtu, 1), 3, 6)) < dDataInicial
					Loop
				EndIf

				If CToD(aDataGer[nForDias] + SubStr(HS_DToC(oCalend:dDiaAtu, 1), 3, 6)) > dDataFinal
					Loop
				EndIf

				// Nao executa se o dia for maior do que a data final
				If CToD(aDataGer[nForDias] + SubStr(HS_DToC(oCalend:dDiaAtu, 1), 3, 6)) > dDataFinal .Or. ;
					CToD(aDataGer[nForDias] + SubStr(HS_DToC(oCalend:dDiaAtu, 1), 3, 6)) < dDataInicial
					Loop
				EndIf

				If !FS_VldDis("GM8", 5, cFilAnt + aItensMar[nContFor][1] + DTOS(CToD(aDataGer[nForDias] + SubStr(HS_DToC(oCalend:dDiaAtu, 1), 3, 6))))
					If !FS_GerAge(aItensMar[nContFor][1], CToD(aDataGer[nForDias] + SubStr(HS_DToC(oCalend:dDiaAtu, 1), 3, 6)))
						lErro := .t.
						Exit
					EndIf
				EndIf

			EndIf

		Next

		//Limpa a oCalend
		FS_MaDeCal(oCalend:dDiaAtu, "L")

		cCond := "GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8_FILAGE = '" + cFilAnt + "' AND GM8_CODDIS = '" + GM6->GM6_CODDIS + "' AND GM8_DATAGE >= '" + DTOS(oCalend:dDiaAtu) + "' AND GM8_DATAGE <= '" + DToS(LastDay(oCalend:dDiaAtu)) + "'"

		FS_AtuGetD(5, cFilAnt + GM6->GM6_CODDIS + DTOS(oCalend:dDiaAtu), cCond)

		If lErro
			Exit
		EndIf

	Next

	dDataTemp       := LastDay(dDataTemp) + 1
	dDataAtu	       := dDataTemp
	oMeses:nAt      := Month(dDataTemp)
	oCalend:dDiaAtu := FirstDay(dDataTemp)
	oCalend:Refresh()

	If dDataAtu <= dDataFinal
		FS_SeleBrw()
	EndIf

	If lErro
		Exit
	EndIf
EndDo

oMeses:nAt      := month(dDataInicial)
oCalend:dDiaAtu := dDataInicial

oCalend:Enable()
oMeses:Enable()
oBtnGer:Enable()
oBtnAju:Enable()
oBtnInd:Enable()
oBtnExc:Enable()
oBtnTran:Enable()
oBtnAno1:Enable()
oBtnAno2:Enable()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณFS_aDiaSemLimp บ Autor ณ PAULO JOSE       บ Data ณ 06/12/04 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Cria o Vetor de Dias marcados no oCalend                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  (Agenda Ambulatorial)                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_aDiaSemLimp()

Local nContFor

aDataGer := {}

For nContFor := 1 To 31
	aAdd(aDataGer, "")
Next

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_MaDeCalบ Autor ณ PAULO JOSE         บ Data ณ 14/12/04    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca ou Desmarca um dia no oCalend                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  (Agenda Ambulatorial)                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ  dDataAtu, Data Atual                                      บฑฑ
ฑฑบ          ณ 	cSeleSemana  																																													บฑฑ
ฑฑบ          ณ	       "S" = Marca todos os dias da semana                 บฑฑ
ฑฑบ          ณ        "D" = Marca dia do mes (1, ... , 31)                บฑฑ
ฑฑบ          ณ        "L" = Limpa Selecao                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
//Marca Desmarca Dia no oCalend
Static Function FS_MaDeCal(dDataAtu, cModo, cChave)

Local dLimpaSele := FirstDay(dDataAtu)
Local dData      :=  dDataAtu

If cModo == "S" .Or. cModo == "SF"
	If !(cChave == Nil) .And. FS_VldDis("GM8", 5, cChave) .And. (dData >= dDataBase)
		If cModo == "SF"
			oCalend:addRestri(day(dData), CLR_HGREEN, CLR_HGREEN)
		Else
			oCalend:addRestri(day(dData), CLR_RED, CLR_RED)
		EndIf
	Else
		If cModo == "SF"
			oCalend:addRestri(day(dData), CLR_GREEN, CLR_GREEN)
		Else
			oCalend:addRestri(day(dData), CLR_BLUE, CLR_BLUE)
		EndIf
	EndIf

	aDataGer[Day(dData)] := Str(Day(dData))
ElseIf cModo == "D" .Or. cModo == "DF" //MARCA OU DESMARCA UM DIA
	//Marca dia do mes
	If Empty(aDataGer[day(dDataAtu)])
		If cModo == "DF"
			oCalend:addRestri(day(dDataAtu), CLR_GREEN, CLR_GREEN)
		Else
			oCalend:addRestri(day(dDataAtu), CLR_BLUE, CLR_BLUE)
		EndIf
		aDataGer[day(dDataAtu)] := Str(day(dData))
	Else
		If !(cChave == Nil)
			If !FS_VldDis("GM8", 5, cChave) //Se nao encontrar a Chave ( cFilRet + CODDISP + dDATA )
				oCalend:addRestri(day(dDataAtu), CLR_BLACK, CLR_WHITE)
				aDataGer[day(dDataAtu)] := ""
			EndIf
		Else
			oCalend:addRestri(day(dDataAtu), CLR_BLACK, CLR_WHITE)
			aDataGer[day(dDataAtu)] := ""
		EndIf
	EndIf

ElseIf cModo == "L"  //lIMPA OS DIAS LILECIONADOS ( LIMPA TUDO )
	//Limpa Selecao
	FS_aDiaSemLimp()
	while CMonth(dLimpaSele) == CMonth(dDataAtu)
		oCalend:addRestri(day(dLimpaSele), CLR_BLACK, CLR_WHITE)
		dLimpaSele  := dLimpaSele + 1
	EndDo
EndIf //if cModo == "S"

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_SeleCalบ Autor ณ PAULO JOSE         บ Data ณ 09/12/04    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Selecio os dias no calendario (oCalend)                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  (Agenda Ambulatorial)                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_SeleCal(dData)

Local lRet  := .T., cCond := ""

If Len(aItensMar) > 0
	If FS_VldDis("GM8", 5, cFilAnt + GM6->GM6_CODDIS + DTOS(dData/*oCalend:dDiaAtu*/))
		If HS_IsFreeDay(dData)
			FS_MaDeCal(dData, "DF", cFilAnt + GM6->GM6_CODDIS + DTOS(dData/*oCalend:dDiaAtu*/))
		Else
			FS_MaDeCal(dData, "D", cFilAnt + GM6->GM6_CODDIS + DTOS(dData/*oCalend:dDiaAtu*/))
		EndIf
		lRet := .F.
	Else
		If dData < dDataBase
			HS_MsgInf(OemtoAnsi(STR0021), OemtoAnsi(STR0001), STR0014)  //"Nใo pode ser selecionado um dia anterior ao dia de hoje." ###"Aten็ใo"###"Gera agenda m้dica.
			lRet := .F.
		Else
			If HS_IsFreeDay(dData)
				FS_MaDeCal(dData, "DF", )
			Else
				FS_MaDeCal(dData, "D",  )
			EndIf
		EndIf
	EndIf
EndIf

cCond := "GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8_FILAGE = '" + cFilAnt + "' AND GM8_CODDIS = '" + GM6->GM6_CODDIS + "' AND GM8_DATAGE = '" + DTOS(oCalend:dDiaAtu) + "'"

FS_AtuGetD(5, cFilAnt + GM6->GM6_CODDIS + DTOS(oCalend:dDiaAtu), cCond)

Return(lRet)




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_SeleBrwบ Autor ณ PAULO JOSE         บ Data ณ 09/12/04    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Le os dias da semana (gm5) cadastrados para a              บฑฑ
ฑฑบ          ณ disponibilidae                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  (Agenda Ambulatorial)                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_SeleBrw(lPosGm6) //cGM6_CODDIS

Local ddata   := oCalend:dDiaAtu
Local lRet    := .T.
Local cCond   := " "
Local nDiaSem := 0, lFeriado := 0

Default lPosGm6 := .T.

//Data da oCalend deve ser sempre maior ou igual a Data Base do sistema
If (oCalend:dDiaAtu < dDataBase)
	ddata := dDataBase
EndIf

If Len (aItensMar)  = 0
	FS_MaDeCal(oCalend:dDiaAtu, "L")
	oCalend:Enable()
	oMeses:Enable()

	oBtnAno1:Enable()
	oBtnAno2:Enable()

	oBtnGer:Disable()
	oBtnAju:Disable()
	oBtnInd:Disable()
	oBtnExc:Disable()
	oBtnTran:Disable()

	FS_AtuGetD(5, "xx", Nil)

ElseIf Len(aItensMar) = 1
	If lPosGm6
		GM6->(DbSetOrder(1)) // GM6_FILIAL + GM6_CODDIS
		GM6->(DbSeek(xFilial("GM6") + aItensMar[1][1]))
		oGM6:Refresh()
	EndIf

	FS_LeDiaSe(aItensMar[1][1])
	oCalend:Enable()
	oMeses:Enable()

	oBtnGer:Enable()
	oBtnAju:Enable()
	oBtnInd:Enable()
	oBtnExc:Enable()
	oBtnTran:Enable()
	oBtnAno1:Enable()
	oBtnAno2:Enable()

	cCond := "GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8_FILAGE = '" + cFilAnt + "' AND GM8_CODDIS = '" + GM6->GM6_CODDIS + "' AND " + ;
	"GM8_DATAGE BETWEEN '" + DTOS(oCalend:dDiaAtu) + "' AND '" + DToS(LastDay(oCalend:dDiaAtu)) + "'"

	FS_AtuGetD(5, cFilAnt + aItensMar[1][1] + DTOS(oCalend:dDiaAtu), cCond)

	FS_MaDeCal(oCalend:dDiaAtu, "L")

	While cmonth(ddata) == cmonth(oCalend:dDiaAtu)

		nDiaSem  := Dow(dData)
		lFeriado := HS_IsFreeDay(dData)

		If (lFeriado .And. aDiasDisp[8] .And. aDiasDisp[nDiaSem]) .Or. ; // Feriado
			(!lFeriado .And. aDiasDisp[nDiaSem])                            // Dias Normais
			FS_MaDeCal(ddata, IIF(lFeriado, "SF", "S"), cFilAnt + aItensMar[1][1] + DTOS(ddata))
		EndIf

		dData++
	EndDo

ElseIf Len(aItensMar) > 1

	FS_MaDeCal(oCalend:dDiaAtu, "L")

	oCalend:Disable()
	oMeses:Disable()

	oBtnGer:Enable()
	oBtnAju:Disable()
	oBtnInd:Disable()
	oBtnExc:Disable()
	oBtnTran:Disable()
	FS_AtuGetD(5, "xx", Nil)

EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_AtuGetDบ Autor ณ PAULO JOSE         บ Data ณ 21/12/04    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza a MSNewGetDados com os dados da gm8 referente     บฑฑ
ฑฑบ          ณ ao filtro                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParame    ณ	cChave:  chave para pesquisa 							                       บฑฑ
ฑฑบ	      		 ณ	nOrd: 	 ordem para pesquisa            				                บฑฑ
ฑฑบ			       ณ	cFiltro: Filtro 		                               								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  (Agenda Ambulatorial)                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_AtuGetD(nOrd, cChave, cFiltro)

Local lRet := .T.

aHGM8 := {}
aCGM8 := {}
nUGM8 := 0

Set Softseek On

HS_BDados("GM8", @aHGM8, @aCGM8, @nUGM8, nOrd, cChave, cFiltro  ,,,;
"GM8_CODDIS/GM8_FILAGE/GM8_DATAGE/GM8_HORAGE/GM8_TIPAGE/GM8_STATUS",,,,,, .T.) //, .T.

Set Softseek Off

oGM8:SetArray(aCGM8)
oGM8:oBrowse:Refresh()
SysRefresh()
//oCalend:Refresh()

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_LeDiaSeบ Autor ณ PAULO JOSE         บ Data ณ 09/12/04    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Le os dias da semana (gm5) cadastrados para a              บฑฑ
ฑฑบ          ณ disponibilidae                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  (Agenda Ambulatorial)                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_LeDiaSe(cGM6_CODDIS)

Local cAliasOld := Alias()
Local lRet      := .F.

DbSelectarea("GM5")
DbSetOrder(1) // GM5_FILIAL + GM5_CODDIS + GM5_DIASEM

If DbSeek(xFilial("GM5") + cGM6_CODDIS)
	aDiasDisp := {.F., .F., .F., .F., .F., .F., .F., .F.}
	lRet := .T.
	//Carregar dias da Semana no vetor aDiasDisp
	While (GM5->GM5_CODDIS == cGM6_CODDIS)
		aDiasDisp[Val(GM5->GM5_DIASEM)] := .T.
		DbSkip()
	EndDo
EndIf

DbSelectArea(cAliasOld)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_GerAge บ Autor ณ PAULO JOSE         บ Data ณ 06/12/04    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera horario na agenda (gm8)                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  (Agenda Ambulatorial)                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GerAge(cGM6_CODDIS, dDataAge, cOp, aColsReg)

Local nContaEcx    := 0
Local cHoraInicial := Space(05)
Local cHoraFinal   := Space(05)
Local cHoraAge     := Space(05)
Local lAchou       := .F.
Local nContFor     := 0
Local lErro			     := .F.
Local nPosReg      := 0
Local nForEcx      := 0
Private cHorInt	 := ""
Private cFimBloq := ""
Default cOp      := "GER"
Default aColsReg := {}

If dDataAge < dDataBase
	Return(.T.)
EndIf

DbSelectArea("GM6")
DbSetOrder(1) // GM6_FILIAL + GM6_CODDIS
DbSeek(xFilial("GM6") + cGM6_CODDIS)
cHoraAge := GM6->GM6_HORINI

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Trata os horarios normais a serem gerados                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
While Val(Substr(cHoraAge, 1, 2)) < Val(Substr(GM6->GM6_HORFIM, 1, 2)) .Or. ;
	(Val(Substr(cHoraAge, 1, 2)) == Val(Substr(GM6->GM6_HORFIM, 1, 2)) .And. Val(Substr(cHoraAge, 4, 2)) <= Val(Substr(GM6->GM6_HORFIM, 4, 2)))

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Caso seja um ajuste, verifica se o horario ja havia sido agen- ณ
	//ณ dado ou bloqueado. Se sim, nao gera novamente.                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	lAchou := .F.
	If (cOp == "AJU") .And. Len(aColsReg) > 0
		nPosReg := aScan(aColsReg, {| aVet | aVet[1] + aVet[2] + aVet[3] == DToC(dDataAge) + cHoraAge + "0"})
		If lAchou := (nPosReg <> 0)
			If aColsReg[nPosReg, 5] == "1" /*Ocupado*/
				If (aColsReg[nPosReg, 1] <> DToC(dDataAge) .And. aColsReg[nPosReg, 2] <> cHoraAge) .Or. FS_GrvBloq(cGM6_CodDis, dDataAge, cHoraAge, @cHorInt)
					FS_BloAju(aColsReg[nPosReg, 4])
				EndIf
			EndIf
			aDel(aColsReg, nPosReg)
			aSize(aColsReg, Len(aColsReg)-1)
		EndIf
	EndIf

	If !lAchou
		If lErro := !FS_VldAge(dDataAge)
			Exit
		EndIf
		If FS_GrvBloq(cGM6_CodDis, dDataAge, cHoraAge, @cHorInt,@cFimBloq, GM6->GM6_HORFIM) //Verifica se o Horario esta na ABA "Periodos Indisponiveis"
			FS_GrvHor(cFilAnt, cGM6_CodDis, "0", dDataAge, cHoraAge, "2")
		Else
			FS_GrvHor(cFilAnt, cGM6_CodDis, "0", dDataAge, cHoraAge)
		EndIf
	EndIf

	//Calcula o proximo horario
	cHoraAge := FS_GerHor(cHoraAge , GM6->GM6_HORFIM , GM6->GM6_INTMAR, @cHorInt, cFimBloq)
	
EndDo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Tratamento dos encaixes                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lErro
	For nForEcx := 1 To GM6->GM6_QTENCX
		lAchou := .F.
		If cOp == "AJU" .And. Len(aColsReg) > 0
			If (lAchou := (nPosReg := aScan(aColsReg, {| aVet | aVet[1] + aVet[3] == DToC(dDataAge) + "1"})) <> 0)
				aDel(aColsReg, nPosReg)
				aSize(aColsReg, Len(aColsReg)-1)
			EndIf
		EndIf

		If !lAchou
			FS_GrvHor(cFilAnt, cGM6_CodDis, "1", dDataAge, "  :  ")
		EndIf
	Next nForEcx
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Bloqueia os horarios antigos que ja estejam ocupados           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("GM8")
DbSetOrder(1) //GM8_FILIAL + GM8_CODAGE
For nPosReg := 1 To Len(aColsReg)
	If aColsReg[nPosReg, 5] == "1" //Ocupado
		FS_BloAju(aColsReg[nPosReg, 4])
	EndIf
Next nPosReg

Return (!lErro)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_GerHor บ Autor ณ PAULO JOSE         บ Data ณ 07/12/04    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera os horarios respeitando o intervalo de marcacao       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   | Gera e retorna a hora da marcacao                          บฑฑ
ฑฑบ          |	Quando HORAGE for maior que HORFIM retorna em branco      	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  (Agenda Ambulatorial)                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GerHor(cHorIni, cHorFim, cIntMar)

Local nHoraIni := Val(Subs(cHorIni,1,2))
Local nMinIni	 := Val(Subs(cHorIni,4,2))
Local nHoraInt := Val(Subs(cIntMar,1,2))
Local nMinInt	 := Val(Subs(cIntMar,4,2))
Local nHoraRet	:= nHoraIni + nHoraInt
Local nMinRet	 := nMinIni + nMinInt

If nMinRet > 60
	nHoraRet += 1
	nMinRet	:= nMinRet - 60
EndIf

If nMinRet == 60
	nHoraRet += 1
	nMinRet	:= 0
EndIf

Return(StrZero(nHoraRet,2) + ":" + StrZero(nMinRet, 2))



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_VldDis บ Autor ณ PAULO JOSE         บ Data ณ 06/12/04    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verifica se existe dias(gm4) para esta disponibilidade     บฑฑ
ฑฑบ          ณ Verifica se existe Disponibilidade e DatAge                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  (Agenda Ambulatorial)                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_VldDis(cAlias, nOrd, cChave)

Local cAliasOld := Alias()
Local lRet      := .F.

DbSelectArea(cAlias)
DbSetOrder(nOrd)

If DbSeek(xFilial(cAlias) + cChave)
	lRet := .T.
EndIf

DbSelectArea(cAliasOld)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_MntPergบ Autor ณ PAULO JOSE         บ Data ณ 06/12/04    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta as Perguntas                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  (Agenda Ambulatorial)                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_MntPerg(cOpPerg)

Local lRet         	:= .T.
Local dDataInicial 	:= ctod(" ")
Local dDataFinal   	:= ctod(" ")
Local cHorIni      	:= ""
Local cHorFin      	:= ""
Local cCODCAN
Local cPerg

Private lGeraConfer := .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a Perguntas para o usuario...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cOpPerg $ "G/A/E/T"
	cPerg := "HSM28C"//"HSM28A"
ElseIf (cOpPerg == "I")
	cPerg := "HSM53A"
EndIf

If Pergunte(cPerg, .T.)
	If cOpPerg $ "G/A/E/T"

		dDataInicial := MV_PAR01
		dDataFinal   := MV_PAR02

		dbSelectArea("SX1")
		dbSetOrder(1)
		If ValType("MV_PAR03") # "U" .AND. cOpPerg == "G"
			lGeraConfer	 := (MV_PAR03 == 1)
		EndIf

		If Empty(dDataInicial) .Or. Empty(dDataFinal)
			If Empty(dDataInicial)
				HS_MsgInf(STR0033, STR0001, STR0014) //"Data Inicial nใo pode ser vazia"###"Aten็ใo"###"Gera agenda m้dica.
				lRet := .F.
			ElseIf Empty(dDataFinal)
				HS_MsgInf(STR0022, STR0001, STR0014) //"A data final nใo pode estar branco."###"Aten็ใo"###"Gera agenda m้dica.
				lRet := .F.
			EndIf
		ElseIf(dDataFinal < dDataInicial)
			HS_MsgInf(STR0023, STR0001, STR0014)  //"A data final nใo pode ser menor que a inicial"###"Aten็ใo"###"Gera agenda m้dica.
			lRet := .F.
		Else
			lRet := .T.
		EndIf
	ElseIf cOpPerg == "I"
		cCODCAN      := MV_PAR01
		dDataInicial := MV_PAR02
		dDataFinal   := MV_PAR03
		cHorIni      := MV_PAR04
		cHorFin      := MV_PAR05
		If Empty(cCODCAN)
			HS_MsgInf(STR0024, STR0001, STR0014)  	//"Para esta opera็ใo ้ necessแrio escolher um motivo de cancelamento."###"Aten็ใo"###"Gera agenda m้dica.
			lRet := .F.
		ElseIf Empty(dDataInicial)
			HS_MsgInf(STR0045, STR0001, STR0014) //"Data Inicial nใo pode ser vazia"###"Aten็ใo"###"Gera agenda m้dica.
			lRet := .F.
		ElseIf Empty(dDataFinal)
			HS_MsgInf(STR0022, STR0001, STR0014) //"A data final nใo pode estar branco."###"Aten็ใo"###"Gera agenda m้dica.
			lRet := .F.
		ElseIf (!Empty(dDataFinal) .And. !Empty(dDataInicial)) .And. (dDataFinal < dDataInicial)
			HS_MsgInf(STR0023, STR0001, STR0014)  //"A data final nใo pode ser menor que a inicial"###"Aten็ใo"###"Gera agenda m้dica.
			lRet := .F.
		Else
			lRet := .T.
		EndIf
	EndIf
Else
	lRet := .F.
EndIf
If lRet
	dDataInicial := IIF(dDataInicial < dDataBase, dDataBase, dDataInicial)

	If cOpPerg =="G" .And. lRet
		If ExistBlock("HM53GERA")
			lret:= ExecBlock("HM53GERA", .F., .F.,{dDataInicial, dDataFinal})
			ConSug(cOpPerg)
			Return(lRet)
		Endif
		//Gera a Agenda.
		MsgRun(STR0025,, { || FS_MntAge(dDataInicial, dDataFinal)}) //"Aguarde, gerando horแrios..."

	ElseIf cOpPerg == "A" .And. lRet
		//Ajusta Horarios
		MsgRun(STR0026,, { || FS_AjustaH(dDataInicial, dDataFinal, aItensMar[1][1])})  //"Aguarde, atualizando horแrios..."

	ElseIf cOpPerg =="I" .And. lRet

		If Len(aItensMar) = 1
			//Indisponibiliza Horarios
			FS_MntInd(dDataInicial, dDataFinal, cCODCAN, aItensMar[1][1], cHorIni, cHorFin)
		ElseIf Len(aItensMar) > 1
			HS_MsgInf(STR0027, STR0001, STR0014)  //"Selecionar apenas uma disponibilidade."###"Aten็ใo"###"Gera agenda m้dica.
		ElseIf Len(aItensMar) = 0
			HS_MsgInf(STR0028, STR0001, STR0014)  //"Nใo existe disponibilidade selecionada."###"Aten็ใo"###"Gera agenda m้dica.
		EndIf

	ElseIf cOpPerg == "E" .And. lRet
		//Ajusta Excli horarios
		MsgRun(STR0029,, { || FS_ExcluiH(dDataInicial, dDataFinal, aItensMar[1][1])}) //"Aguarde, excluindo horแrios..."
	elseIf cOpPerg == "T" .AND. lRet
		if len (aItensMar)  = 1
			//Transferencia de setor dos horarios marcados
			HS_TranSet("GM8",dDataInicial, dDataFinal, aItensMar[1][1], SPACE(TamSx3("GM8_CODSAL")[1]), SPACE(TamSx3("GM8_CODREC")[1]), SPACE(TamSx3("GM8_CODREC")[1]), "J")
		elseif len (aItensMar)  > 1
			HS_MsgInf(STR0029, STR0001, STR0015)  //"Selecionar apenas uma disponibilidade." ###"Atencao" ###"Gera agenda medica.
		elseif len (aItensMar)  = 0
			HS_MsgInf(STR0030, STR0001, STR0015)  //"Nao existe disponibilidade selecionada." ###"Atencao" ###"Gera agenda medica.
		endif

	EndIf
	Eval(oMeses:bChange)
	ConSug(cOpPerg)
EndIf
Return()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_AjustaHบ Autor ณ PAULO JOSE         บ Data ณ 23/12/04    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Ajusta os horarios de agendamentos                         บฑฑ
ฑฑบ          ณ Ajusta apenas os horarios livres                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  (Agenda Ambulatorial)                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_AjustaH(dDataInicial, dDataFinal, cCodDis)

Local lRet        := .T.
Local nContFor    := 0
Local aRegAge     := {}
Local aHeGM8      := {}
Local aCoGM8      := {}
Local nUsGM8      := 0
Local dData       := ctod(" ")
Local cLstCpo     := "GM8_CODDIS/GM8_DATAGE/GM8_HORAGE/GM8_TIPAGE/GM8_STATUS/GM8_CODAGE"
Local nGM8_DATAGE := 1
Local nGM8_HORAGE := 2
Local nGM8_FILAGE := 3
Local nGM8_STATUS := 4
Local nGM8_CODDIS := 5
Local nGM8_CODAGE := 6
Local nGM8_TIPAGE := 7
Local cCond       := ""

Private cCdCanAju   := AllTrim(GetMV("MV_CDCANAJ"))

If Empty(cCodDis)

	HS_MsgInf(STR0044, STR0001, STR0014) //"Nใo existem dados para esta opera็ใo"###"Aten็ใo"###"Gera agenda m้dica."
	Return(.F.)

EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Tratamento do parametro que contem o codigo do bloqueio do horario a ser utilizado no ajuste ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty(cCdCanAju)

	HS_MsgInf(STR0045, STR0001, STR0046) //"O parโmetro MV_CDCANAJ (que deve conter o c๓digo de cancelamento de horแrios da rotina de ajuste) nใo foi encontrado ou nใo estแ atualizado"###"Aten็ใo"###"Ajuste de horแrios"
	Return(.F.)

EndIf

DbSelectArea("GM7")
DbSetOrder(1) // GM7_FILIAL + GM7_CODCAN
If !DbSeek(xFilial("GM7") + cCdCanAju)
	HS_MsgInf(STR0047, STR0001, STR0046) //"O c๓digo de cancelamento informado no parโmetro MV_CDCANAJ nใo foi encontrado no cadastro de motivo de cancelamento."###"Aten็ใo"###"Ajuste de horแrios"
	Return(.F.)
EndIf
If GM7->GM7_IDEBLO <> "1" //Nao bloqueia horario
	HS_MsgInf(STR0048 + cCdCanAju + STR0049, STR0001, STR0046) //"O c๓digo de cancelamento informado no parโmetro MV_CDCANAJ ("###") nใo possui identificacao de bloqueio de horแrio. C๓digo invแlido!"###"Aten็ใo"###"Ajuste de horแrios"
	Return(.F.)
EndIf

aHeGM8 := {}
aCoGM8 := {}
nUsGM8 := 0

cCond :=  "'" + cCODDIS + "' == GM8->GM8_CODDIS .AND. GM8->GM8_DATAGE >= '" + DTOS(dDataInicial) + "' .AND. GM8->GM8_DATAGE <= '" + DTOS(dDataFinal) + "'"

Set SoftSeek On
HS_BDados("GM8", @aHeGM8, @aCoGM8, @nUsGM8, 5, cFilAnt + cCODDIS + DTOS(dDataInicial), cCond ,,, cLstCpo,,,,,, .T., .T.)
Set SoftSeek Off

nGM8_DATAGE := aScan(aHeGM8, {| aVet | aVet[2] == "GM8_DATAGE"})
nGM8_HORAGE := aScan(aHeGM8, {| aVet | aVet[2] == "GM8_HORAGE"})
nGM8_STATUS := aScan(aHeGM8, {| aVet | aVet[2] == "GM8_STATUS"})
nGM8_CODDIS := aScan(aHeGM8, {| aVet | aVet[2] == "GM8_CODDIS"})
nGM8_CODAGE := aScan(aHeGM8, {| aVet | aVet[2] == "GM8_CODAGE"})
nGM8_TIPAGE := aScan(aHeGM8, {| aVet | aVet[2] == "GM8_TIPAGE"})

DbSelectArea("GM8")
DbSetOrder(1) // GM8_FILIAL + GM8_CODAGE

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se ha horarios ja gerados, exclui os liberados e salva os ja agendados ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nContFor := 1 To Len(aCoGM8)

	If Dbseek(xFilial("GM8") + aCoGM8[nContFor][nGM8_CODAGE])
		If aCoGM8[nContFor][nGM8_STATUS] == "0" //0=Liberado

			RecLock("GM8", .F., .T.)
			DBDelete()
			MsUnlock()

		Else
			aAdd(aRegAge, {DToC(aCoGM8[nContFor][nGM8_DATAGE]), ;
			aCoGM8[nContFor][nGM8_HORAGE], ;
			aCoGM8[nContFor][nGM8_TIPAGE], ;
			aCoGM8[nContFor][nGM8_CODAGE], ;
			aCoGM8[nContFor][nGM8_STATUS]})
		EndIf

	EndIf

Next nContFor

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Gera  horarios ja gerados, exclui os liberados e salva os ja agendados ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("GM6")
DbSetOrder(1) // GM6_FILIAL + GM6_CODDIS
Dbseek(xFilial("GM6") + aCoGM8[1][nGM8_CODDIS])

For nContFor := 1 To Len(aCoGM8)

	If dData <> aCoGM8[nContFor][nGM8_DATAGE]
		dData := aCoGM8[nContFor][nGM8_DATAGE]
		FS_GerAge( aCoGM8[nContFor][nGM8_CODDIS], aCoGM8[nContFor][nGM8_DATAGE], "AJU", aRegAge) //Gera agenda (GM8)
	EndIf

Next nContFor

cCond := "GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8_FILAGE = '" + cFilAnt + "' AND GM8_CODDIS = '" + GM6->GM6_CODDIS + "' AND " + ;
"GM8_DATAGE BETWEEN '" + DTOS(oCalend:dDiaAtu) + "' AND '" + DToS(LastDay(oCalend:dDiaAtu)) + "'"

FS_AtuGetD(5, cFilAnt + GM6->GM6_CODDIS + DTOS(oCalend:dDiaAtu), cCond)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MntInd บ Autor ณ PAULO JOSE         บ Data ณ  20/10/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ FUNCAO QUE MANIPULA O SX1.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_MntInd(dDataInicial, dDataFinal, cCODCAN, cCODDIS, cHorIni, cHorFin)

Local lRet    := .T.
Local aHInd   := {}
Local aCInd   := {}
Local cLstCpo := "GM8_CODDIS/GM8_FILAGE/GM8_DATAGE/GM8_HORAGE/GM8_TIPAGE/GM8_CODAGE/GM8_STATUS"   // /GM8_MOTIVO/GM8_DESCAN
Local nUInd   := 0
Local oGM8Ind
Local oDlgInd
Local nGM8_OK := 0, nGM8_HorAge :=0
Local nGM8Status := 0, nCh := 0
Local aItensInd
Local cFiltro
Local cMarca
Local aButtons   := {}
Local bFS_M28Ind	:= {} // Chama a funcao que marca e desmarca os horarios
Local aSize		:= {}
Local aInfo		:= {}
Local aObjects	:= {}
Local aPObjs	:= {}

Private lMarca_Ok := .F.// Indica se esta marcado ou desmarcado
aSize    := MsAdvSize(.T.)
aObjects := {}
AAdd(aObjects, {100, 100, .T., .T.})
aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
aPObjs := MsObjSize(aInfo, aObjects, .T.)

If Empty(dDataInicial) .Or. dDataInicial < dDataBase
	dDataInicial := oCalend:dDiaAtu
	If dDataInicial < dDataBase
		dDataInicial := dDataBase
	EndIf
EndIf

#IFDEF TOP
	cFiltro := "' .AND. GM8->GM8_DATAGE <= '" + dtos(dDataFinal) + "'"
#ELSE
	cFiltro := "' .AND. DTOS(GM8->GM8_DATAGE) <= '" + dtos(dDataFinal) + "'"
#ENDIF
cMarca  := "IIf(GM8->GM8_STATUS = '2' .OR. GM8->GM8_STATUS = '4' ,'LBTIK','LBNO')"   //"'LBNO'"

//Adciona o bota na enchoicebar
Aadd(aButtons	, {"edit_ocean", {||Eval(bFS_M28Ind)}, STR0042})  //"Todos"

DEFINE MSDIALOG oDlgInd TITLE OemToAnsi(STR0030) From  aSize[ 7 ], 000 To aSize[ 6 ], aSize[ 5 ]	Of oMainWnd pixel  //"Indisponibiliza horแrio."

#IFDEF TOP
	cFiltro := "'" + cCODDIS + "' == GM8->GM8_CODDIS .AND. GM8->GM8_DATAGE >= '" + DTOS(dDataInicial) + cFiltro
#ELSE
	cFiltro := "'" + cCODDIS + "' == GM8->GM8_CODDIS .AND. DTOS(GM8->GM8_DATAGE) >= '" + DTOS(dDataInicial) + cFiltro
#ENDIF

cFiltro += " .AND. GM8->GM8_FILAGE = '" + cFilAnt + "'"

Set Softseek On
HS_BDados("GM8", @aHInd, @aCInd, @nUInd, 5, cFilAnt + cCODDIS + DTOS(dDataInicial), cFiltro ,,, cLstCpo , /*cElimina*/,,, "GM8_OK", cMarca, .T.) //, .T.
Set Softseek Off

nGM8_OK     := aScan(aHInd, {| aVet | aVet[2] == "GM8_OK    "})
nGM8_HorAge := aScan(aHInd, {| aVet | aVet[2] == "GM8_HORAGE"})
nGM8Status := aScan(aHInd, {| aVet | aVet[2] == "GM8_STATUS"})
oGM8Ind := MsNewGetDados():New(	aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], GD_UPDATE, , , , , , , , , , oDlgInd , aHInd, aCInd)
oGM8Ind:oBrowse:BlDblClick := {|| FS_DblClk(oGM8Ind, nGM8_OK)}


bFS_M28Ind	:= {|| FS_MarkInd(oGM8Ind, nGM8_OK)}

//marca os horarios passados pelo parametro
If !Empty(cHorIni) .And. !Empty(cHorFin)
	FS_MarkInd(oGM8Ind, nGM8_OK, nGM8_HorAge, cHorIni, cHorFin)
EndIf
For nCh := 1 to Len(oGM8Ind:aCols)
	If Alltrim(oGM8Ind:aCols[nCh, nGM8Status]) $ "24"
		oGM8Ind:aCols[nCh, nGM8_OK] := "LBTIK"
	EndIf
Next nCh

ACTIVATE MSDIALOG oDlgInd CENTERED ON INIT EnchoiceBar(oDlgInd, {|| FS_GrvInd(oGM8Ind, cCODCAN ) .And. oDlgInd:End()}, {|| oDlgInd:End()} ,, aButtons)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DblClk บ Autor ณPaulo jose          บ Data ณ  30/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca/Desmarca plano padrao do paciente                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_DblClk(oNewGetD, nCpoOK, lTransf,  nStatus, nCodPla, nCodPro, nCodloc)

Local lRet  := .T.
Local aArea := GetArea()
Default lTransf := .F.

If !lTransf
	If oNewGetD:aCols[oNewGetD:oBrowse:nAt, nCpoOK] == "LBNO"
		oNewGetD:aCols[oNewGetD:oBrowse:nAt, nCpoOK] := "LBTIK"
	Else
		oNewGetD:aCols[oNewGetD:oBrowse:nAt, nCpoOK] := "LBNO"
	EndIf
Else
	If cCodTra == oNewGetD:aCols[oNewGetD:oBrowse:nAt, nCodloc]
		HS_MsgInf(STR0051,STR0001,STR0052)   //"Setor da transfer๊ncia nใo pode ser igual ao setor do registro selecionado"###"Valida transfer๊ncia"
		lRet := .F.
	Else
		If oNewGetD:aCols[oNewGetD:oBrowse:nAt, nStatus] == "1"
			DbSelectArea("GM2")
			DbSetOrder(1)
			If !DbSeek(xFilial("GM2")+ cCodTra + oNewGetD:aCols[oNewGetD:oBrowse:nAt, nCodPro])
				HS_MsgInf(STR0053+ ALLTRIM(oNewGetD:aCols[oNewGetD:oBrowse:nAt, nCodPro])+ STR0054,STR0001,STR0052)   //"Procedimento "###" nใo permitido no setor de transfer๊ncia"###"Valida transfer๊ncia"
				lRet := .F.
			Else
				DbSelectArea("GM0")
				DbSetOrder(1)
				If DbSeek(xFilial("GM0") + cCodTra + oNewGetD:aCols[oNewGetD:oBrowse:nAt, nCodPla])
					HS_MsgInf(STR0055+ ALLTRIM(oNewGetD:aCols[oNewGetD:oBrowse:nAt, nCodPla])+ STR0054,STR0001,STR0052)    //"Plano "###" nใo permitido no setor de transfer๊ncia"###"Valida transfer๊ncia"
					lRet := .F.
				Endif
			Endif
		Endif
		If lRet
			If oNewGetD:aCols[oNewGetD:oBrowse:nAt, nCpoOK] == "LBNO"
				oNewGetD:aCols[oNewGetD:oBrowse:nAt, nCpoOK] := "LBTIK"
			Else
				oNewGetD:aCols[oNewGetD:oBrowse:nAt, nCpoOK] := "LBNO"
			EndIf
		Endif
	Endif
Endif
oNewGetD:oBrowse:Refresh()
RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvInd บ Autor ณ PAULO JOSE         บ Data ณ  29/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ FUNCAO QUE INDSPONIBILIZA HORARIOS.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_GrvInd(oNewGetD, cCODCAN)

Local lRet        := .T.
Local cAliasOld   := Alias()
Local nContFor    := 0
Local nGM8_DATAGE := aScan(oNewGetD:aHeader, {| aVet | aVet[2] == "GM8_DATAGE"})
Local nGM8_HORAGE := aScan(oNewGetD:aHeader, {| aVet | aVet[2] == "GM8_HORAGE"})
Local nGM8_FILAGE := aScan(oNewGetD:aHeader, {| aVet | aVet[2] == "GM8_FILAGE"})
Local nGM8_STATUS := aScan(oNewGetD:aHeader, {| aVet | aVet[2] == "GM8_STATUS"})
Local nGM8_CODDIS := aScan(oNewGetD:aHeader, {| aVet | aVet[2] == "GM8_CODDIS"})
Local nGM8_CODAGE := aScan(oNewGetD:aHeader, {| aVet | aVet[2] == "GM8_CODAGE"})
Local nGM8_TIPAGE := aScan(oNewGetD:aHeader, {| aVet | aVet[2] == "GM8_TIPAGE"})
Local nGM8_OK     := aScan(oNewGetD:aHeader, {| aVet | aVet[2] == "GM8_OK    "})
Local nGM8_DESCAN := aScan(oNewGetD:aHeader, {| aVet | aVet[2] == "GM8_DESCAN"})

DbSelectArea("GM8")
DbSetOrder(1) // GM8_FILIAL + GM8_CODAGE
//Posiciona o no Registro que esta na matriz
For nContFor := 1 To Len(oNewGetD:aCols)

	If DbSeek(xFilial("GM8") + oNewGetD:aCols[nContFor][nGM8_CODAGE])

		RecLock("GM8", .F.)
		If oNewGetD:aCols[nContFor][nGM8_OK] == "LBTIK"
			If GM8->GM8_STATUS == "0"        // se estiver LIBERADO
				GM8->GM8_STATUS := "2"          // 2=bloqueia o horario
				GM8->GM8_MOTIVO := cCODCAN			   // grava o motivo
			ElseIf GM8->GM8_STATUS $ "1/5"   // se estiver OCUPADO
				GM8->GM8_STATUS := "4"          // 4=OCUPADO/BLOQUEADO
				GM8->GM8_MOTIVO := cCODCAN			   // grava o motivo
			ElseIf GM8->GM8_STATUS $ "8"   // se estiver transferido
				GM8->GM8_STATUS := "2"          // 2=BLOQUEADO
				GM8->GM8_MOTIVO := cCODCAN			   // grava o motivo 
			EndIf

		ElseIf oNewGetD:aCols[nContFor][nGM8_OK] == "LBNO"
			If GM8->GM8_STATUS == "2"        // se estiver BLOQUEADO
				GM8->GM8_STATUS := "0"          // 0= libera o horario
				GM8->GM8_MOTIVO := ""			        // limpa o motivo
			ElseIf GM8->GM8_STATUS == "4"    // se estiver OCUPADO/BLOQUADO
				IIF(Empty(GM8->GM8_DATCFM), GM8->GM8_STATUS := "1", GM8->GM8_STATUS := "5") // marca como 1=OCUPADO/5=Confirmado
				GM8->GM8_MOTIVO := ""			        // limpa o motivo
			EndIf
		EndIf
		MsUnlock()

	EndIf

Next

DbSelectArea(cAliasOld)

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ExcluiHบ Autor ณ PAULO JOSE         บ Data ณ  29/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Exclui horarios da gm8                                     บฑฑ
ฑฑบ          ณ Desde que nao exista nenhum horario agendado               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_ExcluiH(dDataInicial, dDataFinal, cCODDIS)

Local lRet        := .T.
Local lOcupado    := .F.
Local nContFor    := 0
Local aHeGM8      := {}
Local aCoGM8      := {}
Local nUsGM8      := 0
Local nGM8_STATUS := 4
Local nGM8_CODAGE := 6
Local nGM8_DATAGE := 0
Local nGM8_CODDIS := 0
Local cCond       := ""

If !Empty(cCODDIS)
	aHeGM8 := {}
	aCoGM8 := {}
	nUsGM8 := 0

	#IFDEF TOP
		cCond := "'" + cCODDIS + "' == GM8->GM8_CODDIS .AND. GM8->GM8_DATAGE >= '" + DTOS(dDataInicial) + "' .AND. GM8->GM8_DATAGE <= '" + DTOS(dDataFinal) + "'"
	#ELSE
		cCond := "'" + cCODDIS + "' == GM8->GM8_CODDIS .AND. DTOS(GM8->GM8_DATAGE) >= '" + DTOS(dDataInicial) + "' .AND. DTOS(GM8->GM8_DATAGE) <= '" + DTOS(dDataFinal) + "'"
	#ENDIF

	Set SoftSeek On
	HS_BDados("GM8", @aHeGM8, @aCoGM8, @nUsGM8, 5, cFilAnt + cCODDIS + DTOS(dDataInicial), cCond ,,,;
	"GM8_CODDIS/GM8_DATAGE/GM8_HORAGE/GM8_TIPAGE/GM8_STATUS/GM8_CODAGE/GM8_DESCAN" ,,,,,, .T., .T.)
	Set SoftSeek Off

	If Len(aCoGM8) > 0

		nGM8_CODDIS := aScan(aHeGM8, {| aVet | aVet[2] == "GM8_CODDIS"})
		nGM8_DATAGE := aScan(aHeGM8, {| aVet | aVet[2] == "GM8_DATAGE"})
		nGM8_STATUS := aScan(aHeGM8, {| aVet | aVet[2] == "GM8_STATUS"})
		nGM8_CODAGE := aScan(aHeGM8, {| aVet | aVet[2] == "GM8_CODAGE"})

		DbSelectArea("GM8")
		DbSetOrder(1) // GM8_FILIAL + GM8_CODAGE

		For nContFor := 1 To Len(aCoGM8)
			If aCoGM8[nContFor][nGM8_STATUS] == "1" .Or. aCoGM8[nContFor][nGM8_STATUS] == "4" //Ocupado ou Ocupado/Bloqueado
				lOcupado := .T.
				lRet     := .F.
				Exit
			EndIf
		Next

		If !lOcupado
			Begin Transaction
			For nContFor := 1 To Len(aCoGM8)
				If DbSeek(xFilial("GM8") + aCoGM8[nContFor][nGM8_CODAGE])
					RecLock("GM8", .F., .T.)
					DbDelete()
					MsUnlock()
				EndIf
			Next
			End Transaction
			FS_MaDeCal(FirstDay(dDataInicial), "L")
		Else
			HS_MsgInf(STR0031, STR0001, STR0046)   //"Jแ existem horแrios agendados para esta disponibilidade. Ajuste de horแrios nใo permitido."###"Aten็ใo"###"Ajuste de Horแrios"
			lRet := .F.
		EndIf
	EndIf
Else
	HS_MsgInf(STR0032, STR0001, STR0046)  //"Nใo existe dados para essa opera็ใo."###"Aten็ใo"###"Ajuste de Horแrios"
	lRet := .F.

EndIf

FS_MaDeCal(FirstDay(oCalend:dDiaAtu), "L")
FS_SeleDia(oCalend:dDiaAtu)
oCalend:dDiaAtu := dDataInicial
FS_SeleBrw(.F.)
SYSREFRESH()

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_VldAge บ Autor ณAlessandro Freire   บ Data ณ 23/02/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verifica se ja                                             บฑฑ
ฑฑบ          ณ existe disponibilidades com conflito de horario            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  (Agenda Ambulatorial)                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_VldAge(dData)

Local cHoraIni := GM6->GM6_HORINI
Local cHoraFim	:= RetHoraFim(GM6->GM6_HORFIM, GM6->GM6_INTMAR)
Local cCRM		   := GM6->GM6_CODCRM
Local cMsg1		  := ""
Local aArea		  := GetArea()

cMsg1		:= STR0034 + Chr(13) + Chr(10) //"O horแrio final de atendimento deve acontecer dentro do mesmo dia."
cMsg1		+= STR0035 //"Por favor, corrija o cadastro de disponibilidade de c๓digo "
cMsg1		+= GM6->GM6_CODDIS + "."

// Significa que o atendimento ultrapassara o dia e a disponibilidade do profissional deve ser refeita
If cHoraIni > cHoraFim
	HS_MsgInf(cMsg1, STR0036, STR0050) //"Impossํvel continuar"###"Existe disponibilidades com conflito de horแrio"
	Return(.F.)
EndIf

// Verifica se ja existe agendamento para este profissional nesta data
DbSelectArea("GM8")
DbSetOrder(8)  // GM8_FILIAL + GM8_CODCRM + GM8_DATAGE + GM8_HORAGE
If !DbSeek(xFilial("GM8") + cCrm + DTOS(dData))
	Return(.T.)
EndIf

While !Eof() .And. xFilial("GM8") == GM8->GM8_FILIAL

	IF dData != GM8->GM8_DATAGE
		Exit
	EndIf

	If cCrm != GM8->GM8_CODCRM
		Exit
	EndIf

	// O horario gravado no GM8 esta entre o horario inicial e final
	If cHoraIni <= GM8->GM8_HORAGE .And. cHoraFim >= GM8->GM8_HORAGE .And. GM8->GM8_CODDIS <> GM6->GM6_CODDIS
		cMsg1	:= STR0037 + DtoC(dData)  //"Hแ conflito de horแrios no dia "
		cMsg1 += STR0038 + GM6->GM6_CODDIS + ". " //" para a disponibilidade de c๓digo "
		cMsg1 += STR0039 //"Esta rotina serแ encerrada."
		HS_MsgInf( cMsg1, STR0036,STR0050 ) //"Impossํvel continuar"###"Existe disponibilidades com conflito de horแrio"
		Return(.F.)
	EndIf

	DbSkip()

EndDo

RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณrethorafimบAutor  ณAlessandro Freire   บ Data ณ  23/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o horario final possivel de atendimento            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ fs_vldage()                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RetHoraFim(cHora, cIntervalo)

Local cHorF := Subs(cHora, 1, 2)
Local cMinF := Subs(cHora, 4, 2)
Local cHorI	:= Subs(cIntervalo, 1, 2)
Local cMinI	:= Subs(cIntervalo, 4, 2)
Local cHorRet  := StrZero(Val(cHorF) + Val(cHorI), 2)
Local cMinRet	:= StrZero(Val(cMinF) + Val(cMinI), 2)

If cMinRet > "59"
	cHorRet := StrZero(Val(cHorRet) + 1, 2)
	cMinRet := StrZero(Val(cMinRet) - 60, 2)
EndIf

If cHorRet > "24" .And. cMinRet > "00"
	cHorRet := StrZero(Val(cHorRet) - 24, 2)
EndIf

Return(cHorRet + ":" + cMinRet)

**************************************************************************************************
Function HS_M53MB(cMarca)
FS_MaDeCal( oCalend:dDiaAtu, "L")
oCalend:dDiaAtu := FirstDay(oCalend:dDiaAtu)
FS_SeleBrw(.F.)
oCalend:Refresh()
Return(.T.)

*************************************************************************************************
Static Function FS_SELEDIA(dData)

Local cCond := ""

#IFDEF TOP
	cCond := "'" + xFilial("GM8") + "' == GM8_FILIAL .AND. '" + cFilAnt + "' == GM8->GM8_FILAGE  .AND. '" + GM6->GM6_CODDIS + "' == GM8->GM8_CODDIS .AND. GM8->GM8_DATAGE = '" + DTOS(oCalend:dDiaAtu) + "'"
#ELSE
	cCond := "'" + xFilial("GM8") + "' == GM8_FILIAL .AND. '" + cFilAnt + "' == GM8->GM8_FILAGE  .AND. '" + GM6->GM6_CODDIS + "' == GM8->GM8_CODDIS .AND. DTOS(GM8->GM8_DATAGE) = '" + DTOS(oCalend:dDiaAtu) + "'"
#ENDIF

FS_AtuGetD(5, cFilAnt + GM6->GM6_CODDIS + DTOS(oCalend:dDiaAtu), cCond)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MarkIndบ Autor ณPaulo Jose          บ Data ณ  30/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca/Desmarca plano padrao do paciente                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_MarkInd(oNewGetD, nCpoOk, nCpoHor, cHorIni, cHorFin)

Local lRet     := .T.
Local nContFor := 0

Default nCpoHor := 0, cHorIni := "", cHorFin := ""

If nCpoHor <> 0 .And. !Empty(cHorIni) .And. !Empty(cHorFin)
	For nContFor := 1 To Len(oNewGetD:aCols)
		If oNewGetD:aCols[nContFor, nCpoHor] >= cHorIni .And. oNewGetD:aCols[nContFor, nCpoHor] <= cHorFin
			oNewGetD:aCols[nContFor, nCpoOK] := "LBTIK"
		Else
			oNewGetD:aCols[nContFor, nCpoOK] := "LBNO"
		EndIf
	Next
Else
	For nContFor := 1 To Len(oNewGetD:aCols)
		If lMarca_Ok
			oNewGetD:aCols[nContFor, nCpoOK] := "LBNO"
		Else
			oNewGetD:aCols[nContFor, nCpoOK] := "LBTIK"
		EndIf
	Next

	lMarca_Ok := !lMarca_Ok

EndIf

oNewGetD:oBrowse:Refresh()

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FACDIS บ Autor ณ Daniel Peixoto     บ Data ณ  13/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Facilitador para marcar as disponibilidades de acordo      บฑฑ
ฑฑบ          ณ com os medicos                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_FACDIS()

Local aArea := GetArea()

If Pergunte("HSM28E", .T.)
	DbSelectArea("GM6") //disponibilidades
	DbSetOrder(3)  // GM6_FILIAL + GM6_CODCRM
	ProcRegua(RecCount())
	DbSeek(xFilial("GM6") + MV_PAR01, .T.)
	While !Eof() .And. GM6->GM6_FILIAL == xFilial("GM6") .And. GM6->GM6_CODCRM <= MV_PAR02
		IncProc(STR0043 + GM6->GM6_CODCRM)  //"Processando... "
		HS_DblClick("GM6", "GM6_OK", __cHS_Marca, @aItensMar, "GM6_CODDIS", "HS_M53MB", "HS_VDisMB")
		DbSkip()
	EndDo
EndIf

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvHor บ Autor ณ Cibele Peria       บ Data ณ  21/12/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava o agendamento na tabela                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GrvHor(cFilAnt, cCodDis, cTipoAge, dDataAge, cHoraAge, cStatus)

Default cStatus := "0"

If Type("lGeraConfer") # "U" .AND. lGeraConfer .AND. cStatus == "0"
	cStatus := "7"
EndIf

M->GM8_CODAGE := HS_VSxeNum("GM8", "M->GM8_CODAGE", 1)
ConfirmSx8()

Begin Transaction
RecLock("GM8", .T.)
GM8->GM8_FILIAL := xFilial("GM8")
GM8->GM8_FILAGE := cFilAnt
GM8->GM8_CODAGE := M->GM8_CODAGE
GM8->GM8_CODLOC := GM6->GM6_CODLOC
GM8->GM8_CODCRM := GM6->GM6_CODCRM
GM8->GM8_DATAGE := dDataAge
GM8->GM8_HORAGE := cHoraAge
GM8->GM8_CODDIS := cCodDis
GM8->GM8_STATUS := cStatus
If cStatus == "2" //Bloq.
	GM8->GM8_MOTIVO := GetMV("MV_CANAGEN")
EndIf
GM8->GM8_LOGARQ := HS_LogArq()
GM8->GM8_TIPAGE := cTipoAge       //0 = Agendamento ou  1 = encaixes
GM8->GM8_EXCTRA := .F.

MsUnlock()
ConfirmSx8()
End Transaction

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_BloAju บ Autor ณ Cibele Peria       บ Data ณ  18/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cancela o agendamento (ja ocupado) por ajuste de horario   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_BloAju(cCodAge)

Local aArea := GetArea()

DbSelectArea("GM8")
DbSetOrder(1) //GM8_FILIAL + GM8_CODAGE
DbSeek(xFilial("GM8") + cCodAge)
RecLock("GM8", .F.)
GM8->GM8_STATUS := "4" //Ocupado/Bloqueado
GM8->GM8_MOTIVO := cCdCanAju
GM8->GM8_ORICAN := HS_INIPADR("GM7", 1, cCdCanAju, "GM7_ORICAN",, .F.)
GM8->GM8_EXCTRA := .T.
MsUnLock()

RestArea(aArea)

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvBloqบAutor  ณDaniel Peixoto      บ Data ณ  30/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o dia/hora esta cadastrado na ABA "Periodos     บฑฑ
ฑฑบ          ณ Indisponiveis no Cad. Disponibilidade                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GrvBloq(cCodDis, dDatAge, cHorAge, cHorInt, cFimBloq, cHorFim)

Local aAreaOld := GetArea()
Local lRet     := .F.
Local cDiaSem  := ""

If HS_IsFreeDay(dDatAge)
	cDiaSem := "8"
ElseIf CDOW(dDatAge) == "Sunday"
	cDiaSem := "1"
ElseIf CDOW(dDatAge) == "Monday"
	cDiaSem := "2"
ElseIf CDOW(dDatAge) == "Tuesday"
	cDiaSem := "3"
ElseIf CDOW(dDatAge) == "Wednesday"
	cDiaSem := "4"
ElseIf CDOW(dDatAge) == "Thursday"
	cDiaSem := "5"
ElseIf CDOW(dDatAge) == "Friday"
	cDiaSem := "6"
ElseIf CDOW(dDatAge) == "Saturday"
	cDiaSem := "7"
EndIf

cFimBloq := ""

DbSelectArea("GMK")
DbSetOrder(1) // GMK_CODDIS + GMK_DIASEM
If DbSeek(xFilial("GMK") + cCodDis + cDiaSem)
	While !Eof() .And. xFilial("GMK") == GMK->GMK_FILIAL .And. cCodDis == GMK->GMK_CODDIS .And. GMK->GMK_DIASEM == cDiaSem
		If (cHorAge >= GMK->GMK_HORINI .And. cHorAge < GMK->GMK_HORFIN)
			lRet := .T.
			cFimBloq := GMK->GMK_HORFIN
			If cHorInt <> NIL
				IF Val(Substr(GMK->GMK_HORFIN,4,2)) - Val(Substr(GMK->GMK_HORINI,4,2))	>=0		
					cHInt := Val(Substr(GMK->GMK_HORFIN,1,2)) - Val(Substr(GMK->GMK_HORINI,1,2))
			   		If cHInt < 10
				   		cHInt := "0" + cValToChar(cHInt)
			   		Else
				   		cHInt := cValToChar(cHInt)
			   		EndIf
				Else
					cHInt :="00"
				Endif
				
				cMInt := Val(Substr(GMK->GMK_HORFIN,4,2)) - Val(Substr(GMK->GMK_HORINI,4,2))
				If cMInt == 0
					cMInt := "0"+cValToChar(cMInt)
				Else
					cMInt := cValToChar(cMInt)
				EndIf
                
				If Val(cMInt) < 0
					cMInt := Val(cMInt) * (-1)
				EndIf
					
				cHorInt := cHInt+":"+cValToChar(cMInt)

			Endif 
			Exit

		EndIf
		DbSkip()
	EndDo
EndIf

RestArea(aAreaOld)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FilM28 บAutor  ณMario Arizono       บ Data ณ  29/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFiltra disponibilidades ativas no browse.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_FilM28(lSetFilter)

Local cFiltro := ""
Local aArea   := GetArea()

cFiltro := "GM6_FILIAL = '" + xFilial("GM6") + "' AND GM6_IDEATI = '1'"

SetMBTopFilter("GM6", cFiltro)
If lSetFilter
	oGM6:GoTop()
	oGM6:Refresh()
EndIf

RestArea(aArea)

Return(Nil)




/*Static Function AjustaSx1()

Local aHelpPor := {}
Local aHelpEsp := {}
Local aHelpIng := {}

Aadd(aHelpPor,"Informe se os horแrios serใo" ) //'Informe o Setor definido para o '
Aadd(aHelpPor,"gerados com status de confer๊ncia.") //'Atendimento Ambulatorial, ou consulte '

Aadd(aHelpEsp,"Informe se os horแrios serใo" ) //'Informe o Setor definido para o '
Aadd(aHelpEsp,"gerados com status de conferสncia.") //'Atendimento Ambulatorial, ou consulte '

Aadd(aHelpIng,"Informe se os horแrios serใo" ) //'Informe o Setor definido para o '
Aadd(aHelpIng,"gerados com status de confer๊ncia.") //'Atendimento Ambulatorial, ou consulte '

//Cria a pergunta para Solicitacao do Setor, caso a mesma nao esteja definida no SX1
PutSx1('HSM28C','03','Em Confer๊ncia ?','Em Confer๊ncia ?','Em Confer๊ncia ?','mv_ch3','N',1,0,02,'C',;
'','','','N','mv_par03',; //"Agendamento Ambulatorial"
'Sim','','','','Nao','','','','','','','','','','','',aHelpPor,aHelpEsp,aHelpIng)

aHelpPor := {}
aHelpEsp := {}
aHelpIng := {}

Aadd(aHelpPor,"Informe a data inicial" )
Aadd(aHelpEsp,"Informe a data inicial" )
Aadd(aHelpIng,"Informe a data inicial" )

PutSx1('HSM28E',"01","Data data ?","Data data ?","Data data ?","MV_CH0",;
                "D",08,00,00,"G","","","","N","MV_PAR01","","","","","","","","","","",;
                "","","","","","",aHelpPor,aHelpIng,aHelpEsp)
aHelpPor := {}
aHelpEsp := {}
aHelpIng := {}

Aadd(aHelpPor,"Informe a data final" )
Aadd(aHelpEsp,"Informe a data final" )
Aadd(aHelpIng,"Informe a data final" )

PutSx1('HSM28E',"02","Ate a Data ?","Ate a Data ?","Ate a Data ?","MV_CH1",;
                "D",08,00,00,"G","","","","N","MV_PAR02","","","","","","","","","","",;
                "","","","","","",aHelpPor,aHelpIng,aHelpEsp)

Return() */

Static Function FS_CONFAGE()
Local aArea 	:= GetArea()
Local nContFor	:= 0
Local lRet 		:= .F.
Local dDataTemp, dDataInicial, dDataFinal


If !Pergunte('HSM28F', .T.)
	Return()
EndIf

dDataInicial := MV_PAR01
dDataFinal   := MV_PAR02

If Empty(dDataInicial) .Or. Empty(dDataFinal)
	If Empty(dDataInicial)
		HS_MsgInf(STR0033, STR0001, STR0014) //"Data Inicial nใo pode ser vazia"###"Aten็ใo"###"Gera agenda m้dica.
		lRet := .F.
	ElseIf Empty(dDataFinal)
		HS_MsgInf(STR0022, STR0001, STR0014) //"A data final nใo pode estar branco."###"Aten็ใo"###"Gera agenda m้dica.
		lRet := .F.
	EndIf
ElseIf(dDataFinal < dDataInicial)
	HS_MsgInf(STR0023, STR0001, STR0014)  //"A data final nใo pode ser menor que a inicial"###"Aten็ใo"###"Gera agenda m้dica.
	lRet := .F.
Else
	lRet := .T.
EndIf

If !lRet
	Return()
EndIf

dDataAtu	   := dDataInicial
dDataTemp	   := dDataAtu

If Len(aItensMar) > 0
	For nContFor := 1 To Len(aItensMar)
		While dDataAtu <= dDataFinal
			FS_GRVCONF(aItensMar[nContFor][1],dDataAtu)
			dDataTemp ++      //:= LastDay(dDataTemp) + 1
			dDataAtu        := dDataTemp
		EndDo
	Next
Else
	HS_MsgInf(STR0072, STR0001, STR0014)  //"Selecione a disponibilidade!" ### "A data final nใo pode ser menor que a inicial"###"Aten็ใo"###"Gera agenda m้dica.
	Return()
EndIf

oCalend:dDiaAtu := FirstDay(dDataTemp)
oCalend:Refresh()

RestArea(aArea)
Return

Static Function FS_GRVCONF(cCodDis,dData)
Local aArea := getArea()

DbSelectArea("GM8")
DbSetOrder(9)
If DbSeek(xFilial("GM8") + cCodDis + DTOS(dData))
	While !Eof() .AND. GM8->GM8_CODDIS == cCodDis .AND. GM8->GM8_DATAGE == dData
		If GM8->GM8_STATUS == '7'
			RecLock("GM8",.F.)
				GM8->GM8_STATUS := '0'
			MsUnlock()
		EndIf
		DbSkip()
	EndDo
EndIf

RestArea(aArea)
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณConSug    บAutor  ณMicrosiga           บ Data ณ  01/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta os agendamentos sugeridos.                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function ConSug(cOpPerg)
Local nCont := 0
//Local lPromo  := GETNEWPAR("MV_PROSAUD",.F.)
Local cCodDis
Local cDispon := ""

Default cOpPerg := ""

If Empty(cOpPerg)
	If !Pergunte('HSM28F', .T.)
		Return()
	EndIf
EndIf

If lPromo
	If cOpPerg $ "G" .Or. Empty(cOpPerg)
		For nCont := 1 To Len(aItensMar)
			cCodDis := (aItensMar[nCont][1])
			cDispon := cDispon+"'"+cCodDis+"'"
			If nCont < Len(aItensMar)
				cDispon := cDispon+".Or. BOQ_CODDIS == ""
			EndIf
		Next nCont

		If Empty(cDispon)
			cDispon := "''"
		EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณChama a rotina que irแ listar os agendamentos sugeridos, ณ
//ณLogo ap๓s a gera็ใo de Horarios.                         ณ
//ณFuncionalidade da Promo็ใo Saude.                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		PLSPreAg(MV_PAR01,MV_PAR02,cDispon)
	EndIf
Endif

Return  


/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณROTINA DE ATRIBUIวรO DE EVENTOS ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
Static Function FS_EVENAGE()
Local aArea 	:= GetArea()
Local nContFor	:= 0
Local lRet 		:= .F.
Local dDataTemp, dDataInicial, dDataFinal
Local cHoraIni, cHoraFim
Local n


If !Pergunte('HSM28G', .T.)
	Return()
EndIf

cCodEven	 := MV_PAR01
dDataInicial := MV_PAR02
dDataFinal   := MV_PAR03
cHoraIni 	 := MV_PAR04
cHoraFim	 := MV_PAR05

If Empty(dDataInicial) .Or. Empty(dDataFinal)
	If Empty(dDataInicial)
		HS_MsgInf(STR0033, STR0001, STR0014) //"Data Inicial nใo pode ser vazia"###"Aten็ใo"###"Gera agenda m้dica.
		lRet := .F.
	ElseIf Empty(dDataFinal)
		HS_MsgInf(STR0022, STR0001, STR0014) //"A data final nใo pode estar branco."###"Aten็ใo"###"Gera agenda m้dica.
		lRet := .F.
	EndIf
ElseIf(dDataFinal < dDataInicial)
	HS_MsgInf(STR0023, STR0001, STR0014)  //"A data final nใo pode ser menor que a inicial"###"Aten็ใo"###"Gera agenda m้dica.
	lRet := .F.
ElseIf cHoraIni > cHoraFim
	HS_MsgInf("Hora inicial nใo pode ser maior que a final!", STR0001, STR0014)  //"A data final nใo pode ser menor que a inicial"###"Aten็ใo"###"Gera agenda m้dica.
	lRet := .F.
Else
	lRet := .T.
EndIf

If !lRet
	Return()
EndIf

dDataAtu	   := dDataInicial
dDataTemp	   := dDataAtu

If Len(aItensMar) > 0
	For nContFor := 1 To Len(aItensMar)
		While dDataAtu <= dDataFinal
			FS_GRVEVEN(aItensMar[nContFor][1],dDataAtu, cCodEven,cHoraIni, cHoraFim, MV_PAR06 == 1)
			dDataTemp ++      //:= LastDay(dDataTemp) + 1
			dDataAtu        := dDataTemp
		EndDo
	Next
Else
	HS_MsgInf("Selecione a disponibilidade!", STR0001, STR0014)  //"A data final nใo pode ser menor que a inicial"###"Aten็ใo"###"Gera agenda m้dica.
	Return()
EndIf

oCalend:dDiaAtu := FirstDay(dDataTemp)
oCalend:Refresh()

RestArea(aArea)
Return

/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGRAVA O EVENTO NO HORARIO DA GM8ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
Static Function FS_GRVEVEN(cCodDis,dData, cEvento, cHoraIni, cHoraFim, lAtrib)
Local aArea := getArea()

DbSelectArea("GM8")
DbSetOrder(9)
If DbSeek(xFilial("GM8") + cCodDis + DTOS(dData))
	While !Eof() .AND. GM8->GM8_CODDIS == cCodDis .AND. GM8->GM8_DATAGE == dData
		If GM8->GM8_STATUS == '0' .AND. GM8->GM8_HORAGE >= cHoraIni .AND. GM8->GM8_HORAGE <=cHoraFim
			RecLock("GM8",.F.)
			If lAtrib // Se ้ atribui็ใo grava o evento
				GM8->GM8_EVENTO := cEvento
			Else // caso seja exclusใo limpa o campo
				GM8->GM8_EVENTO := IIf(GM8->GM8_EVENTO == cEvento, SPACE(TamSx3("GM8_EVENTO")[1]), GM8->GM8_EVENTO)
			EndIf
			MsUnlock()
		EndIf
		DbSkip()
	EndDo
EndIf

RestArea(aArea)
Return()
