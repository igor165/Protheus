#INCLUDE "protheus.CH"
#INCLUDE "HSPAHM28.CH"
#INCLUDE "TopConn.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM28  บ Autor ณ Paulo Jose         บ Data ณ  30/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ GERA A AGENDA MEDICA                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHM28()
Local oFont
Local oDlg
Local aMeses		:= {}
Local cMes			:= ""
Local bFS_M28		:= {|| INCLUI := .F., ALTERA := .T., LREFRESH := .T., LRESVALID := .T., LMODIFIED := .F., HS_A97("GM6", RecNo(), 4), FS_FilM28(.T.)} // Chama a funcao A97
Local bKey_F4		:=  SetKey(VK_F4, { || Eval(bFS_M28)}) // inicializa a tecla F4
Local bFS_Facili	:= {||FS_FACDIS()} // Facilitador para marcar Disponibilidades
Local aButtons		:= {}
Local cCond			:= ""
Local lDataAtu		:= .T.
Local aSize		:= {}
Local aInfo		:= {}
Local aObjects	:= {}


Private lMostra		:= .T.
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

Private oCBXRec     := nil
Private cRecEsc     := ""//
Private aCbxRec     := {}

Private __cCodDis := "" // Variแveis Utilizadas
Private __cCodSal := "" // no Filtro Hs_FilRec
Private lReplAge	:= .F.
Private aDisRepl	:= {}

AjustaSX()

If !Hs_ExisDic({{"C","GNZ_CODREC","FNC 148152"}})
	Return(nil)
EndIf

IF ExistBlock("HS28IND")
	lMostra := ExecBlock("HS28IND",.f.,.f.)
EndIf

cRecEsc     := Space(TamSx3("GNZ_CODREC")[1])

//Adciona o bota na enchoicebar
Aadd(aButtons	, {"edit_ocean", {||Eval(bFS_M28)}, STR0040})  //"Disp. M้d"
Aadd(aButtons	, {'PARAMETROS', {||Eval(bFS_Facili)}, STR0041})  //"Marca Dis"

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

//Retorna Recursos
aCbxRec := Hs_RetRec(GM6->GM6_CODDIS,,,.T.)

cRecEsc     := Substr(aCbxRec[1],1,at("-",aCbxRec[1])-1)

cCond := "GM8_CODDIS = '" + GM6->GM6_CODDIS + "' AND GM8_DATAGE >= '" + DTOS(dDataBase) + "' AND GM8_DATAGE <= '" + DToS(LastDay(dDataBase)) + "'"
cCond += " AND GM8_CODSAL = '" + GM6->GM6_CODSAL + "' AND GM8_CODREC = '" + cRecEsc +"' "

HS_BDados("GM8", @aHGM8, @aCGM8, @nUGM8, 5, "xx", cCond ,,, "GM8_CODDIS/GM8_FILAGE/GM8_DATAGE/GM8_HORAGE/GM8_TIPAGE/GM8_STATUS/GM8_CODREC",,,,,, .T.)

FS_FilM28(.F.)
aSize := MsAdvSize(.F.)

aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } ) // tamanho ( X ) fixo
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0014) From aSize[7], 000 To aSize[6], aSize[5]	Of oMainWnd  pixel //"Gera agenda m้dica."
oGM6 := HS_MBrow(oDlg, "GM6", {033,003,500,070},,,,,"GM6_OK",, @aItensMar, "GM6_CODDIS",, .T., "HS_M28MB", .T., ;
					{"GM6_NOMCRM", "GM6_CODCRM", "GM6_CODSAL", "GM6_CODDIS", "GM6_DESDIS", "GM6_HORINI", "GM6_HORFIM", "GM6_INTMAR", "GM6_QTENCX"}, "HS_VDisMB")

oGM6:bChange := {||	FS_MaDeCal(oCalend:dDiaAtu, "L"), Fs_SetVarF(), oCalend:dDiaAtu := FirstDay(oCalend:dDiaAtu), FS_SeleBrw(.F.), oCalend:Refresh()}
oGM6:bGotFocus  := {||	FS_MaDeCal(oCalend:dDiaAtu, "L"), Fs_SetVarF(), oCalend:dDiaAtu := FirstDay(oCalend:dDiaAtu), FS_SeleBrw(.F.), oCalend:Refresh()}
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

@ 130, 218 MsComboBox oCBXRec VAR cRecEsc ITEMS aCbxRec SIZE 172, 050 On Change(Fs_ChgRec()) PIXEL OF oDlg
oCBXRec:nAt := 1

oGM8 := MsNewGetDados():New(150, 218, 250, 500, 0, , , , , , , , , , oDlg , aHGm8, aCGm8)

oBtnGer := tButton():New(265, 070, STR0016, oDlg, {|| FS_MntPerg("G")}, 50, 15,,,, .T.) //"Gerar Agenda   "
oBtnAju := tButton():New(265, 140, STR0017, oDlg, {|| FS_MntPerg("A")}, 50, 15,,,, .T.) //"Ajusta Horแrios"
oBtnInd := tButton():New(265, 210, STR0018, oDlg, {|| FS_MntPerg("I")}, 50, 15,,,, .T.) //"Indisponibiliza"

oBtnExc := tButton():New(265, 280, STR0019, oDlg, {|| FS_MntPerg("E")}, 50, 15,,,, .T.) //"Excluir Horแrios"
oBtnTran:= tButton():New(265, 350, STR0066, oDlg, {|| FS_MntPerg("T")}, 50, 15,,,, .T.) //"Transfer๊ncia"

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| oDlg:End()}, {||oDlg:End()},, aButtons)

SetKey(VK_F4, { || Eval(bKey_F4)})

Return(Nil)

Static Function Fs_ChgRec()
Local cCond := ""

cRecEsc := Substr(cRecEsc, 1, at("-",cRecEsc)-1)

cCond := " GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8_FILAGE = '" + cFilAnt + "' AND GM8_CODDIS = '" + GM6->GM6_CODDIS + "'"
cCond += " AND GM8_DATAGE = '" + DTOS(oCalend:dDiaAtu) + "'"// AND GM8_DATAGE <= '" + DToS(LastDay(oCalend:dDiaAtu)) + "'"
cCond += " AND GM8->GM8_CODSAL = '" + GM6->GM6_CODSAL + "' AND GM8_CODREC = '"+cRecEsc+"' "
FS_AtuGetD(5, cFilAnt + GM6->GM6_CODDIS + DTOS(oCalend:dDiaAtu) + GM6->GM6_CODSAL + cRecEsc, cCond)

Return(nil)

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
Static Function FS_MntAge(dDataInicial, dDataFinal, cRecIni, cRecFim)
//Local cHoraIni  := time()
//Local cHoraFin  := ""
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

Local nRecFor   := 0
Local aRecDis   := {}

INCLUI := .T.

If Month(dDataInicial) # Month(oCalend:dDiaAtu) //verifica se o mes digitado e diferente do mes corrente na oCalend
	lSele := .T.
EndIf

dDataAtu			:= dDataInicial
dDataTemp			:= dDataAtu
oMeses:nAt			:= Month(dDataAtu)
oCalend:dDiaAtu	:= dDataAtu
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

		//Retorna Recursos por sala
		aRecDis := Hs_RetRec(aItensMar[nContFor][1], cRecIni, cRecFim)	//Caso nใo haja recursos
		//vetor com duas posi็๕es vazias
		//Percorre o Vetor de dias da Semana Selecionadas
		For nForDias := 1 To Len(aDataGer)

			If !Empty(aDataGer[nForDias])

				If CToD(aDataGer[nForDias] + SubStr(HS_DToC(oCalend:dDiaAtu, 1), 3, 6)) < dDataBase  .Or. ;  // Os horarios nao podem ser gerados para datas anteriores a data base do sistema
					CToD(aDataGer[nForDias] + SubStr(HS_DToC(oCalend:dDiaAtu, 1), 3, 6)) > dDataFinal .Or. ;		// Nao executa se o dia for maior do que a data final
					CToD(aDataGer[nForDias] + SubStr(HS_DToC(oCalend:dDiaAtu, 1), 3, 6)) < dDataInicial			    // Nao executa se o dia for menor do que a data inicial
					Loop
				EndIf


				For nRecFor := 1 to len(aRecDis)

					If Hs_CountTb("GM8"," GM8_FILAGE = '"+cFilAnt+"' AND " +;
						" GM8_CODDIS = '"+aItensMar[nContFor][1]+"' AND " +;
						" GM8_DATAGE = '"+DTOS(CToD(aDataGer[nForDias] + SubStr(HS_DToC(oCalend:dDiaAtu, 1), 3, 6)))+"' AND " +;
						" GM8_CODSAL = '"+GM6->GM6_CODSAL+"' AND " +;
						" GM8_CODREC = '"+aRecDis[nRecFor]+"'") == 0
						If !FS_GerAge(aItensMar[nContFor][1], CToD(aDataGer[nForDias] + SubStr(HS_DToC(oCalend:dDiaAtu, 1), 3, 6)), , ,GM6->GM6_CODSAL, aRecDis[nRecFor])
							lErro := .T.
							Exit
						EndIf
					EndIf

				Next

			EndIf

		Next

		//Limpa a oCalend
		FS_MaDeCal(oCalend:dDiaAtu, "L")

		cCond := "GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8_FILAGE = '" + cFilAnt + "' AND GM8_CODDIS = '" + GM6->GM6_CODDIS + "' AND GM8_DATAGE >= '" + DTOS(oCalend:dDiaAtu) + "' AND GM8_DATAGE <= '" + DToS(LastDay(oCalend:dDiaAtu)) + "'"
		cCond += " AND GM8->GM8_CODSAL = '" + GM6->GM6_CODSAL + "' AND GM8_CODREC = '"+cRecEsc+"' "
		FS_AtuGetD(5, cFilAnt + GM6->GM6_CODDIS + DTOS(oCalend:dDiaAtu) + GM6->GM6_CODSAL + cRecEsc, cCond)

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
If lMostra
	oBtnInd:Enable()
Else
	oBtnInd:Disable()
EndIf
oBtnExc:Enable()
oBtnTran:Enable()
oBtnAno1:Enable()
oBtnAno2:Enable()

While __lSx8
	ConfirmSx8()
End


//cHoraFin := time()
//HS_MsgInf("Hora Inicial [" + cHoraIni + "] Hora Final [" + cHoraFin + "] Tempo gasto [" + HS_TotHoras(cHoraIni, cHoraFin, "-", .T., .F.) + "]", "Aten็ใo", "Gera็ใo Agenda")
Return(.T.)

Function Hs_RetRec(cCodDis, cRecIni, cRecFim, lRetDesc)
Local aArea := getArea()
Local cSql  := ""
Local aRet  := {}
 Local lDicStatu := HS_EXISDIC({{"C", "GO3_STATUS"}},.F.)

Default lRetDesc := .F.
Default cRecIni := Space(TamSx3("GO3_CODREC")[1])
Default cRecFim := Replicate("Z",TamSx3("GO3_CODREC")[1])

cSql += " Select GO3_CODSAL, GO3_CODREC, GNZ.GNZ_DESREC "
cSql += "   From "+RetSqlName("GO3")+" GO3 "
cSql += "   Join "+RetSqlName("GNZ")+" GNZ ON GNZ.GNZ_FILIAL = '"+xFilial("GNZ")+"' AND GNZ.D_E_L_E_T_ <> '*' AND GNZ.GNZ_CODREC = GO3.GO3_CODREC "
cSql += "  Where GO3.GO3_FILIAL = '"+xFilial("GO3")+"' AND GO3.D_E_L_E_T_ <> '*' "
 If lDicStatu
 	cSql += "	AND GO3.GO3_STATUS <> '1'"
 Endif
cSql += "    And GO3.GO3_CODDIS = '"+cCodDis+"' "
cSql += "    And GO3.GO3_CODREC >= '"+cRecIni+"' And GO3.GO3_CODREC <= '"+cRecFim+"' "

TCQuery cSql New Alias "TMPREC"

DbSelectArea("TMPREC")

TMPREC->(DbGoTop())

If TMPREC->(Eof())
	aAdd(aRet, Space(TamSx3("GO3_CODREC")[1]))
Else
	While TMPREC->(!Eof())
		aAdd(aRet, TMPREC->GO3_CODREC+IIF(lRetDesc,"-"+TMPREC->GNZ_DESREC,""))   //{TMPREC->GO3_CODSAL, TMPREC->GO3_CODREC})
		DbSkip()
	EndDo
EndIf

DbSelectArea("TMPREC")
DbCloseArea()

RestArea(aArea)
return(aRet)

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
cCond += " AND GM8->GM8_CODSAL = '"+GM6->GM6_CODSAL+"' AND GM8_CODREC = '"+cRecEsc+"' "

FS_AtuGetD(5, cFilAnt + GM6->GM6_CODDIS + DTOS(oCalend:dDiaAtu) + GM6->GM6_CODSAL + cRecEsc, cCond)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |HS_VDisMB บ Autor ณ PAULO JOSE         บ Data ณ 16/12/04    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Le os dias da semana (gm5) cadastrados para a              บฑฑ
ฑฑบ          ณ disponibilidae                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  (Agenda Ambulatorial)                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_VDisMB()
Local lRet := .T.

If !FS_VldDis("GM5", 1, GM6->GM6_CODDIS)
	If Len(aItensMar) > 1
		HS_MsgInf(OemtoAnsi(STR0020), OemtoAnsi(STR0001), STR0014) //"Nใo existe dias lan็ados para estas Disponibilidades "###"Aten็ใo"###"Gera agenda m้dica.
		lRet := .F.
	EndIf

EndIf

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
	If lMostra
		oBtnInd:Enable()
	Else
		oBtnInd:Disable()
	EndIf
	oBtnExc:Enable()
	oBtnTran:Enable()
	oBtnAno1:Enable()
	oBtnAno2:Enable()

	cCond := "GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8_FILAGE = '" + cFilAnt + "' AND GM8_CODDIS = '" + GM6->GM6_CODDIS + "' AND " + ;
	"GM8_DATAGE BETWEEN '" + DTOS(oCalend:dDiaAtu) + "' AND '" + DToS(LastDay(oCalend:dDiaAtu)) + "'"

	cCond += " AND GM8->GM8_CODSAL = '"+GM6->GM6_CODSAL+"' AND GM8_CODREC = '"+cRecEsc+"' "

	FS_AtuGetD(5, cFilAnt + aItensMar[1][1] + DTOS(oCalend:dDiaAtu) + GM6->GM6_CODSAL + cRecEsc, cCond)

	FS_aDiaSemLimp()

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


HS_BDados("GM8", @aHGM8, @aCGM8, @nUGM8, nOrd, cChave, cFiltro  ,,,;
"GM8_CODDIS/GM8_FILAGE/GM8_DATAGE/GM8_HORAGE/GM8_TIPAGE/GM8_STATUS/GM8_CODREC",,,,,, .T.) //, .T.

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
Static Function FS_GerAge(cGM6_CODDIS, dDataAge, cOp, aColsReg, cCodSal, cCodRec)
Local nContaEcx    := 0
Local cHoraInicial := Space(05)
Local cHoraFinal   := Space(05)
Local cHoraAge     := Space(05)
Local lAchou       := .F.
Local nContFor     := 0
Local lErro			     := .F.
Local nPosReg      := 0
Local nForEcx      := 0

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
		nPosReg := aScan(aColsReg, {| aVet | aVet[1] + aVet[2] + aVet[3] + aVet[6] + aVet[7] == DToC(dDataAge) + cHoraAge + "0" + cCodSal + cCodRec})
		If lAchou := (nPosReg <> 0)
			If aColsReg[nPosReg, 5] == "1" /*Ocupado*/
				If FS_GrvBloq(cGM6_CodDis, dDataAge, cHoraAge, aColsReg[nPosReg, 7])//(aColsReg[nPosReg, 1] <> DToC(dDataAge) .And. aColsReg[nPosReg, 2] <> cHoraAge) .Or. FS_GrvBloq(cGM6_CodDis, dDataAge, cHoraAge, aColsReg[nPosReg, 7])
					FS_BloAju(aColsReg[nPosReg, 4])
				EndIf
			EndIf
			aDel(aColsReg, nPosReg)
			aSize(aColsReg, Len(aColsReg)-1)
		EndIf
	EndIf

	If !lAchou
		If lErro := !FS_VldAge(dDataAge, cCodSal, cCodRec)
			Exit
		EndIf
		If FS_GrvBloq(cGM6_CodDis, dDataAge, cHoraAge, cCodRec) //Verifica se o Horario esta na ABA "Periodos Indisponiveis"
			FS_GrvHor(cFilAnt, cGM6_CodDis, "0", dDataAge, cHoraAge, "2", cCodSal, cCodRec)
		Else
			FS_GrvHor(cFilAnt, cGM6_CodDis, "0", dDataAge, cHoraAge, , cCodSal, cCodRec)
		EndIf
	EndIf

	//Calcula o proximo horario
	cHoraAge := FS_GerHor(cHoraAge , GM6->GM6_HORFIM , GM6->GM6_INTMAR)

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
			FS_GrvHor(cFilAnt, cGM6_CodDis, "1", dDataAge, "  :  ", , cCodSal, cCodRec)
		EndIf
	Next nForEcx
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Bloqueia os horarios antigos que ja estejam ocupados           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//DbSelectArea("GM8")
//DbSetOrder(1) //GM8_FILIAL + GM8_CODAGE
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
Local lRet         := .F.
Local dDataInicial := ctod(" ")
Local dDataFinal   := ctod(" ")
Local cHorIni      := ""
Local cHorFin      := ""
Local cRecIni      := SPACE(TAMSX3("GNZ_CODREC")[1])
Local cRecFim      := REPLICATE("Z",TAMSX3("GNZ_CODREC")[1])
Local cCODCAN      := ""
Local cPerg        := ""
Local lOk          := .T.
//MV_PAR01                     //MV_PAR04
//   HSM28A -> DATA INICIAL    //   HSM28A -> ATE RECURSO
//   HSM28B -> MOTIVO	         //   HSM28B -> DA HORA
//   HSM28C -> DATA INICIAL    //   HSM28D -> DA HORA
//   HSM28D -> MOTIVO	         //MV_PAR05
//MV_PAR02           	         //   HSM28B -> ATE HORA
//   HSM28A -> DATA FINAL      //   HSM28D -> ATE HORA
//   HSM28B -> DATA INICIAL    //MV_PAR06
//   HSM28C -> DATA FINAL      //   HSM28B -> DO RECURSO
//   HSM28D -> DATA INICIAL    //MV_PAR07
//MV_PAR03           	         //   HSM28B -> ATE RECURSO
//   HSM28A -> DO RECURSO
//   HSM28B -> DATA FINAL
//   HSM28D -> DATA FINAL

If (cOpPerg $ "G/E/T" .And. (Len(aItensMar) > 1 .Or. Hs_CountTb("GO3", " GO3_CODDIS = '"+aItensMar[1][1]+"'") = 0) ) .Or. cOpPerg == "A"
	cPerg := "HSM28C"
ElseIf cOpPerg == "I"
	If Hs_CountTb("GO3", " GO3_CODDIS = '"+aItensMar[1][1]+"'") = 0
		cPerg := "HSM28D"
	Else
		cPerg := "HSM28B"
	EndIf
Else
	cPerg := "HSM28A"
EndIf

If !Pergunte(cPerg, .T.)
	Return()
EndIf

While !lRet

	If cPerg $ "HSM28B/HSM28D"
		cCODCAN      := MV_PAR01
		dDataInicial := MV_PAR02
		dDataFinal   := MV_PAR03
		cHorIni      := MV_PAR04
		cHorFin      := MV_PAR05
		cRecIni  := IIF(cPerg # "HSM28B", SPACE(TAMSX3("GNZ_CODREC")[1])        , MV_PAR06)
		cRecFim  := IIF(cPerg # "HSM28B", REPLICATE("Z",TAMSX3("GNZ_CODREC")[1]), MV_PAR07)
	Else
		dDataInicial := MV_PAR01
		dDataFinal   := MV_PAR02
		cRecIni  	:= IIF(cPerg # "HSM28C", MV_PAR03, SPACE(TAMSX3("GNZ_CODREC")[1]))
		cRecFim  	:= IIF(cPerg # "HSM28C", MV_PAR04, REPLICATE("Z",TAMSX3("GNZ_CODREC")[1]))
		lReplAge	:= IIF(cPerg # "HSM28C" .AND. ValType("MV_PAR05") # "U", MV_PAR05 == 2,.F.)
	EndIf

	If     !(lRet := !Empty(dDataInicial))
		HS_MsgInf(STR0033, STR0001, STR0014) //"Data Inicial nใo pode ser vazia"###"Aten็ใo"###"Gera agenda m้dica.
		lOk := .F.
	ElseIf !(lRet := !Empty(dDataFinal))
		HS_MsgInf(STR0022, STR0001, STR0014) //"A data final nใo pode estar branco."###"Aten็ใo"###"Gera agenda m้dica.
		lOk := .F.
	ElseIf !(lRet := (dDataFinal >= dDataInicial))
		HS_MsgInf(STR0023, STR0001, STR0014)  //"A data final nใo pode ser menor que a inicial"###"Aten็ใo"###"Gera agenda m้dica.
		lOk := .F.
	ElseIf !(lRet := (Empty(GM6->GM6_CODSAL) .Or. !Empty(cRecFim)))
		HS_MsgInf("O recurso final nใo pode ser vazio", STR0001, STR0014)//###"Aten็ใo"###"Gera agenda m้dica.
		lOk := .F.
	ElseIf !(lRet := (cPerg # "HSM28B" .Or. !Empty(cCODCAN)))
		HS_MsgInf(STR0024, STR0001, STR0014)  	//"Para esta opera็ใo ้ necessแrio escolher um motivo de cancelamento."###"Aten็ใo"###"Gera agenda m้dica.
		lOk := .F.
	EndIf
	If(!lOk)
		Return()
	EndIf
EndDo


dDataInicial := IIF(dDataInicial < dDataBase, dDataBase, dDataInicial)

If cOpPerg =="G"
	//Gera a Agenda.
	MsgRun(STR0025,, { || FS_MntAge(dDataInicial, dDataFinal, cRecIni, cRecFim)}) //"Aguarde, gerando horแrios..."
	If lReplAge
		MsgRun(STR0068,, { || FS_ReplAge(dDataInicial, dDataFinal, cRecIni, cRecFim)}) //"Aguarde, replicando agendamentos..."
	EndIf
ElseIf cOpPerg == "A"
	//Ajusta Horarios
	MsgRun(STR0026,, { || FS_AjustaH(dDataInicial, dDataFinal, aItensMar[1][1])})  //"Aguarde, atualizando horแrios..."
ElseIf cOpPerg =="I"
	If Len(aItensMar) = 1
		//Indisponibiliza Horarios
		FS_MntInd(dDataInicial, dDataFinal, cCODCAN, aItensMar[1][1], cHorIni, cHorFin, GM6->GM6_CODSAL, cRecIni, cRecFim)
	ElseIf Len(aItensMar) > 1
		HS_MsgInf(STR0027, STR0001, STR0014)  //"Selecionar apenas uma disponibilidade."###"Aten็ใo"###"Gera agenda m้dica.
	ElseIf Len(aItensMar) = 0
		HS_MsgInf(STR0028, STR0001, STR0014)  //"Nใo existe disponibilidade selecionada."###"Aten็ใo"###"Gera agenda m้dica.
	EndIf
ElseIf cOpPerg == "E"
	//Ajusta Excli horarios
	MsgRun(STR0029,, { || FS_ExcluiH(dDataInicial, dDataFinal, aItensMar[1][1], cRecIni, cRecFim)}) //"Aguarde, excluindo horแrios..."
ElseIf cOpPerg == "T"
	If len (aItensMar)  = 1
		//Transferencia de setor dos horarios marcados
		HS_TranSet("GM8",dDataInicial, dDataFinal, aItensMar[1][1], GM6->GM6_CODSAL, cRecIni, cRecFim)
	Elseif len (aItensMar)  > 1
		HS_MsgInf(STR0029, STR0001, STR0015)  //"Selecionar apenas uma disponibilidade." ###"Atencao" ###"Gera agenda medica.
	Elseif len (aItensMar)  = 0
		HS_MsgInf(STR0030, STR0001, STR0015)  //"Nao existe disponibilidade selecionada." ###"Atencao" ###"Gera agenda medica.
	Endif
EndIf

Eval(oMeses:bChange)

Return(nil)

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
//Local cHoraIni  := time()
//Local cHoraFin  := ""
Local lRet        := .T.
Local aRegAge     := {}
Local dData       := Stod(" ")
//Local cLstCpo     := "GM8_CODDIS/GM8_DATAGE/GM8_HORAGE/GM8_TIPAGE/GM8_STATUS/GM8_CODAGE/GM8_CODSAL/GM8_CODREC"
Local cCond       := ""
Local cRecurso    := ""
Local cSql        := ""
Private cCdCanAju   := AllTrim(GetMV("MV_CDCANAJ"))
Private cOrican   :=  ""

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

//Posicionando GM6
DbSelectArea("GM6")
DbSetOrder(1) // GM6_FILIAL + GM6_CODDIS
IIF(GM6->GM6_CODDIS # cCodDis,Dbseek(xFilial("GM6") + cCodDis),nil)

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

cOrican := HS_INIPADR("GM7", 1, cCdCanAju, "GM7_ORICAN",, .F.)

cSql := " SELECT GM8.GM8_CODDIS, GM8.GM8_DATAGE, GM8.GM8_HORAGE, GM8.GM8_TIPAGE, "
cSql += "        GM8.GM8_STATUS, GM8.GM8_CODAGE, GM8.GM8_CODSAL, GM8.GM8_CODREC, "
cSql += "        GM8.R_E_C_N_O_ "
cSql += "   FROM "+RetSqlName("GM8")+" GM8 "
cSql += "  WHERE GM8.GM8_CODDIS = '"+   cCODDIS    +"' AND GM8.GM8_DATAGE BETWEEN '"+DTOS(dDataInicial)+"' AND '"+DTOS(dDataFinal)+"'"
cSql += "    AND GM8.GM8_FILIAL = '"+xFilial("GM8")+"' AND GM8.D_E_L_E_T_ <> '*' "

//cSql += "    AND GM8.GM8_STATUS = '1' "

TCQuery cSql + "    AND GM8.GM8_STATUS IN ('1','4') " New Alias "TMPDISP"

DbSelectArea("TMPDISP")
DbGoTop()

If !TMPDISP->(Eof())
	HS_MSGINF(STR0067,STR0001, STR0046)  //"Nใo ้ possivel ajustar pois existem horแrios com status de Ocupado, Ocupado/Bloqueado no perํodo selecionado!"
	DbSelectArea("TMPDISP")
	DbCloseArea()
	Return(.F.)
EndIf

/*While TMPDISP->(!Eof())
	aAdd(aRegAge, {TMPDISP->GM8_DATAGE, ;//DToC(TMPDISP->GM8_DATAGE), ;
	TMPDISP->GM8_HORAGE, ;
	TMPDISP->GM8_TIPAGE, ;
	TMPDISP->GM8_CODAGE, ;
	TMPDISP->GM8_STATUS, ;
	TMPDISP->GM8_CODSAL, ;
	TMPDISP->GM8_CODREC})
	DbSkip()
End*/

DbCloseArea()

TCQuery cSql New Alias "TMPDISP"

DbSelectArea("TMPDISP")
DbGoTop()

dData    := CtoD("")//StoD(TMPDISP->GM8_DATAGE)
cRecurso := ""//TMPDISP->GM8_CODREC

While TMPDISP->(!EoF())
	If (dData <> StoD(TMPDISP->GM8_DATAGE)) .Or. (cRecurso <> TMPDISP->GM8_CODREC)
		FS_GerAge(cCODDIS, StoD(TMPDISP->GM8_DATAGE), "AJU", aRegAge,GM6->GM6_CODSAL, TMPDISP->GM8_CODREC) //Gera agenda (GM8)
		dData    := StoD(TMPDISP->GM8_DATAGE)
		cRecurso := TMPDISP->GM8_CODREC
		//aAdd(aDatGer, {dData, cRecurso})
	EndIf


	If TMPDISP->GM8_STATUS == "0"  .Or. TMPDISP->GM8_STATUS == "2"//0=Liberado
		DbSelectArea("GM8")
		DbSetOrder(1)
		DbGoTo(TMPDISP->R_E_C_N_O_)
		RecLock("GM8", .F., .T.)
		DBDelete()
		MsUnlock()
	EndIf

	DbSelectArea("TMPDISP")
	DbSkip()
EndDo

DbCloseArea()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Gera  horarios ja gerados, exclui os liberados e salva os ja agendados ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("GM6")
DbSetOrder(1) // GM6_FILIAL + GM6_CODDIS
Dbseek(xFilial("GM6") + cCodDis)

//For nContFor := 1 To Len(aDatGer)
//	FS_GerAge(cCODDIS, aDatGer[nContFor, 1], "AJU", aRegAge,GM6->GM6_CODSAL,aDatGer[nContFor, 2]) //Gera agenda (GM8)
//Next nContFor

cCond := "GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8_FILAGE = '" + cFilAnt + "' AND GM8_CODDIS = '" + GM6->GM6_CODDIS + "' AND " + ;
"GM8_DATAGE BETWEEN '" + DTOS(oCalend:dDiaAtu) + "' AND '" + DToS(LastDay(oCalend:dDiaAtu)) + "'"

FS_AtuGetD(5, cFilAnt + GM6->GM6_CODDIS + DTOS(oCalend:dDiaAtu), cCond)

//cHoraFin := time()
//HS_MsgInf("Hora Inicial [" + cHoraIni + "] Hora Final [" + cHoraFin + "] Tempo gasto [" + HS_TotHoras(cHoraIni, cHoraFin, "-", .T., .F.) + "]", "Aten็ใo", "Gera็ใo Agenda")

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
Static Function FS_MntInd(dDataInicial, dDataFinal, cCODCAN, cCODDIS, cHorIni, cHorFin, cCodSal, cRecIni, cRecFim)
Local lRet    := .T.
Local aHInd   := {}
Local aCInd   := {}
Local cLstCpo := "GM8_CODDIS/GM8_FILAGE/GM8_DATAGE/GM8_HORAGE/GM8_TIPAGE/GM8_CODAGE/GM8_STATUS/GM8_CODSAL/GM8_CODREC"  //GM8_MOTIVO/GM8_DESCAN
Local nUInd   := 0
Local oGM8Ind
Local oDlgInd
Local nGM8_OK := 0, nGM8_HorAge :=0
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

DEFINE MSDIALOG oDlgInd TITLE OemToAnsi(STR0030) From aSize[ 7 ], 000 To aSize[ 6 ] , aSize[ 5 ]	Of oMainWnd pixel  //"Indisponibiliza horแrio."

#IFDEF TOP
	cFiltro := "'" + cCODDIS + "' == GM8->GM8_CODDIS .AND. GM8->GM8_DATAGE >= '" + DTOS(dDataInicial) + cFiltro
#ELSE
	cFiltro := "'" + cCODDIS + "' == GM8->GM8_CODDIS .AND. DTOS(GM8->GM8_DATAGE) >= '" + DTOS(dDataInicial) + cFiltro
#ENDIF

cFiltro += " .AND. GM8->GM8_FILAGE = '" + cFilAnt + "'"
cFiltro += " .AND. GM8->GM8_CODSAL = '" + cCodSal + "' .AND. GM8->GM8_CODREC BETWEEN '"+cRecIni+"' AND '"+cRecFim+"' "

//Set Softseek On
HS_BDados("GM8", @aHInd, @aCInd, @nUInd, 5, cFilAnt + cCODDIS + DTOS(dDataInicial), cFiltro ,,, cLstCpo , /*cElimina*/,,, "GM8_OK", cMarca, .T.) //, .T.
//Set Softseek Off

nGM8_OK     := aScan(aHInd, {| aVet | aVet[2] == "GM8_OK    "})
nGM8_HorAge := aScan(aHInd, {| aVet | aVet[2] == "GM8_HORAGE"})

oGM8Ind := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], GD_UPDATE, , , , , , , , , , oDlgInd , aHInd, aCInd)
oGM8Ind:oBrowse:BlDblClick := {|| FS_DblClk(oGM8Ind, nGM8_OK)}
bFS_M28Ind	:= {|| FS_MarkInd(oGM8Ind, nGM8_OK)}

//marca os horarios passados pelo parametro
If !Empty(cHorIni) .And. !Empty(cHorFin)
	FS_MarkInd(oGM8Ind, nGM8_OK, nGM8_HorAge, cHorIni, cHorFin)
EndIf

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
			If GM8->GM8_STATUS == "0" .or. GM8->GM8_STATUS == "8"        // se estiver LIBERADO
				GM8->GM8_STATUS := "2"          // 2=bloqueia o horario
				GM8->GM8_MOTIVO := cCODCAN			   // grava o motivo
			ElseIf GM8->GM8_STATUS $ "1/5"   // se estiver OCUPADO
				GM8->GM8_STATUS := "4"          // 4=OCUPADO/BLOQUEADO
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
Static Function FS_ExcluiH(dDataInicial, dDataFinal, cCODDIS, cRecIni, cRecFim)
Local lRet        := .T.
Local lOcupado    := .F.
Local nContFor    := 0
Local aHeGM8      := {}
Local aCoGM8      := {}
Local nUsGM8      := 0
Local nGM8_CODAGE := 6
Local cCond       := ""

If !Empty(cCODDIS)
	aHeGM8 := {}
	aCoGM8 := {}
	nUsGM8 := 0

	#IFDEF TOP
		cCond := "'" + cCODDIS + "' = GM8.GM8_CODDIS AND GM8.GM8_DATAGE >= '" + DTOS(dDataInicial) + "' AND GM8.GM8_DATAGE <= '" + DTOS(dDataFinal) + "'"
	#ELSE
		cCond := "'" + cCODDIS + "' == GM8->GM8_CODDIS .AND. DTOS(GM8->GM8_DATAGE) >= '" + DTOS(dDataInicial) + "' .AND. DTOS(GM8->GM8_DATAGE) <= '" + DTOS(dDataFinal) + "'"
	#ENDIF

	cCond += " AND GM8.GM8_CODSAL = '"+GM6->GM6_CODSAL+"' AND GM8.GM8_CODREC >= '"+cRecIni+"' AND GM8.GM8_CODREC <= '"+cRecFim+"' "

	If Hs_CountTb("GM8", cCond + " AND  GM8.GM8_STATUS IN ('1','4') ") > 0
		lOcupado := .T.
		lRet     := .F.
		HS_MsgInf(STR0031, STR0001, STR0046)   //"Jแ existem horแrios agendados para esta disponibilidade. Ajuste de horแrios nใo permitido."###"Aten็ใo"###"Ajuste de Horแrios"
	Else
		HS_BDados("GM8", @aHeGM8, @aCoGM8, @nUsGM8, 5, cFilAnt + cCODDIS + DTOS(dDataInicial), cCond ,,,;
		"GM8_CODDIS/GM8_DATAGE/GM8_HORAGE/GM8_TIPAGE/GM8_STATUS/GM8_CODAGE/GM8_DESCAN" ,,,,,, .T., .T.)

		nGM8_CODAGE := aScan(aHeGM8, {| aVet | aVet[2] == "GM8_CODAGE"})

		DbSelectArea("GM8")
		DbSetOrder(1) // GM8_FILIAL + GM8_CODAGE
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
Static Function FS_VldAge(dData, cSala, cRecurso)
Local cHoraIni := GM6->GM6_HORINI
Local cHoraFim	:= RetHoraFim(GM6->GM6_HORFIM, GM6->GM6_INTMAR)
Local cCRM		   := GM6->GM6_CODCRM
Local cMsg1		  := ""
Local aArea		  := GetArea()
Local cCond    := ""

// Significa que o atendimento ultrapassara o dia e a disponibilidade do profissional deve ser refeita
If cHoraIni > cHoraFim
	cMsg1		:= STR0034 + Chr(13) + Chr(10) //"O horแrio final de atendimento deve acontecer dentro do mesmo dia."
	cMsg1		+= STR0035 //"Por favor, corrija o cadastro de disponibilidade de c๓digo "
	cMsg1		+= GM6->GM6_CODDIS + "."

	HS_MsgInf(cMsg1, STR0036, STR0050) //"Impossํvel continuar"###"Existe disponibilidades com conflito de horแrio"
	Return(.F.)
EndIf

cCond    := " GM8_CODCRM  = '"+cCRM            +"' AND "
cCond    += " GM8_FILAGE  = '"+cFilAnt         +"' AND GM8_DATAGE  = '"+DTOS(dData)+"' AND "
cCond    += " GM8_CODSAL  = '"+cSala           +"' AND GM8_CODREC  = '"+cRecurso+"' AND "
cCond    += " GM8_HORAGE >= '"+cHoraIni        +"' AND GM8_HORAGE <= '"+cHoraFim+"' AND "
cCond    += " GM8_CODDIS <> '"+GM6->GM6_CODDIS +"' "

If Hs_CountTb("GM8", cCond) > 0
	cMsg1	:= STR0037 + DtoC(dData)  //"Hแ conflito de horแrios no dia "
	cMsg1 += STR0038 + GM6->GM6_CODDIS + ". " //" para a disponibilidade de c๓digo "
	cMsg1 += STR0039 //"Esta rotina serแ encerrada."
	HS_MsgInf( cMsg1, STR0036,STR0050 ) //"Impossํvel continuar"###"Existe disponibilidades com conflito de horแrio"
	Return(.F.)
EndIf

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
Function HS_M28MB(cMarca)
FS_MaDeCal( oCalend:dDiaAtu, "L")
oCalend:dDiaAtu := FirstDay(oCalend:dDiaAtu)
FS_SeleBrw(.F.)
oCalend:Refresh()
Return(.T.)

*************************************************************************************************
Function FS_SELEDIA(dData)

Local cCond := ""

#IFDEF TOP
	cCond := "'" + xFilial("GM8") + "' == GM8_FILIAL .AND. '" + cFilAnt + "' == GM8->GM8_FILAGE  .AND. '" + GM6->GM6_CODDIS + "' == GM8->GM8_CODDIS .AND. GM8->GM8_DATAGE = '" + DTOS(oCalend:dDiaAtu) + "'"
#ELSE
	cCond := "'" + xFilial("GM8") + "' == GM8_FILIAL .AND. '" + cFilAnt + "' == GM8->GM8_FILAGE  .AND. '" + GM6->GM6_CODDIS + "' == GM8->GM8_CODDIS .AND. DTOS(GM8->GM8_DATAGE) = '" + DTOS(oCalend:dDiaAtu) + "'"
#ENDIF

cCond += " AND GM8->GM8_CODSAL = '"+GM6->GM6_CODSAL+"' AND GM8_CODREC = '"+cRecEsc+"' "

FS_AtuGetD(5, cFilAnt + GM6->GM6_CODDIS + DTOS(oCalend:dDiaAtu) + GM6->GM6_CODSAL + cRecEsc, cCond)

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
		HS_DblClick("GM6", "GM6_OK", __cHS_Marca, @aItensMar, "GM6_CODDIS", "HS_M28MB", "HS_VDisMB")
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
Static Function FS_GrvHor(cFilAnt, cCodDis, cTipoAge, dDataAge, cHoraAge, cStatus, cCodSal, cCodRec)
Default cStatus := "0"

M->GM8_CODAGE := GetSxENum("GM8","GM8_CODAGE",,1)//HS_VSxeNum("GM8", "M->GM8_CODAGE", 1)
ConfirmSx8()

Begin Transaction
RecLock("GM8", .T.)
GM8->GM8_FILIAL := xFilial("GM8")
GM8->GM8_FILAGE := cFilAnt
GM8->GM8_CODAGE := M->GM8_CODAGE
GM8->GM8_CODLOC := GM6->GM6_CODLOC
GM8->GM8_CODCRM := GM6->GM6_CODCRM
GM8->GM8_CODSAL := cCodSal
GM8->GM8_CODREC := cCodRec
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
GM8->GM8_ORICAN := cOrican
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
Static Function FS_GrvBloq(cCodDis, dDatAge, cHorAge, cCodRec)
Local aAreaOld := GetArea()
Local lRet     := .F.
Local cDiaSem  := ""

If HS_IsFreeDay(dDatAge)
	cDiaSem := "8"
Else
	cDiaSem := AllTrim(str(DoW(dDatAge)))
EndIf

If Hs_CountTb("GMK"," GMK_CODDIS  = '"+cCodDis+"' AND " +;
					" GMK_DIASEM  = '"+cDiaSem+"' AND " +;
					" GMK_CODREC  = '"+cCodRec+"' AND " +;
					" GMK_HORINI <= '"+cHorAge+"' AND " +;
					" GMK_HORFIN >= '"+cHorAge+"' ") > 0

	lRet := .T.
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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_TranSetบAutor  ณMario Arizono       บ Data ณ  29/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTransfere horarios gerados de um setor para outro.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_TranSet(cAlias, dDataInicial, dDataFinal, cCodDis, cCodSal, cRecIni, cRecFim, cTipLoc)
Local aArea 	:= GetArea()
Local aHTran 	:= {}, aCTran := {}, ajoin := {}
Local nUTran 	:= 0
Local nOK 		:= 0, nCodage := 0, nStatus := 0, nCodpla := 0, nCodpro := 0, nCodloc := 0
Local cCond  	:= "", cLstCpo := ""
Local oTran
Local aButtons   	:= {}
Local bFS_M28Tod	:= {} // Chama a funcao que marca e desmarca os horarios
Local lMudou 	:= .T.
Local cPrefSql 	:= cAlias + "." + cAlias
Local cPrefCpo 	:= cAlias + "->" + cAlias
Local cCrmCond 	:= IIF(cAlias == "GM8","GM8.GM8_CODCRM","(CASE GMJ_STATUS "+;
" WHEN '0' THEN   "+;
"  GMJ.GMJ_CRMPRI "+;
" WHEN '1' THEN   "+;
"  GMJ.GMJ_CODCRM "+;
" ELSE            "+;
"  ''             "+;
" END)")
Local nTam		:=15

Default cTipLoc := IIF(cAlias == "GM8","1","4")
Private cCodTra	:= Criavar("GCS_CODLOC"), cNomTra := Criavar("GCS_NOMLOC")
Private oCodSet, oDesSet
Private cGcsTipLoc := cTipLoc


AADD(aJoin, {"      JOIN " + RetSqlName("GCS") + " GCS", "GCS.GCS_NOMLOC", "GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = "+cPrefSQL+"_CODLOC", cAlias+"_LOCDES"})
AADD(aJoin, {"      JOIN " + RetSqlName("SRA") + " SRA", "SRA.RA_NOME"   , "SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO  = "+cCrmCond          , cAlias+"_NOMCRM"})
AADD(aJoin, {" LEFT JOIN " + RetSqlName("GA7") + " GA7", "GA7.GA7_DESC"  , "GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = "+cPrefSQL+"_CODPRO", cAlias+"_DESPRO"})
AADD(aJoin, {" LEFT JOIN " + RetSqlName("GCM") + " GCM", "GCM.GCM_DESPLA", "GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' AND GCM.GCM_CODPLA = "+cPrefSQL+"_CODPLA", cAlias+"_DESPLA"})

cLstCpo := cAlias+"_DATAGE/"+cAlias+"_HORAGE/"+cAlias+"_FILAGE/"+cAlias+"_CODDIS/"+cAlias+"_DESDIS/"+cAlias+"_CODCRM/"+cAlias+"_NOMCRM/"+;
cAlias+"_CODLOC/"+cAlias+"_LOCDES/"+cAlias+"_STATUS/"+cAlias+"_HORINI/"+cAlias+"_HORFIN/"+cAlias+"_CODAGE/"+;
cAlias+"_CODPRO/"+cAlias+"_DESPRO/"+cAlias+"_CODPLA/"+cAlias+"_DESPLA"

cCond   :=  cAlias+"_DATAGE  >= '" + DTOS(dDataInicial) + "' AND "+cAlias+"_DATAGE <= '" + DTOS(dDataFinal) + "' AND "+cAlias+"_CODDIS = '" + cCodDis + "' AND "+cAlias+"_STATUS IN ('0','1') "

If cAlias == "GM8" //Sala e Recurso no Agendamento Ambulatorial
	cLstCpo += "/GM8_CODSAL/GM8_CODREC"
	cCond   +=  " AND GM8_CODSAL  = '" + cCodSal + "' AND GM8_CODREC BETWEEN '" + cRecIni + "' AND '" + cRecFim + "' "
EndIf

HS_BDados(cAlias, @aHTran, @aCTran, @nUTran, 2,, cCond, , ,cLstCpo, , , .T., cAlias+"_OK", "IIf("+cPrefCpo+"_OK =='1','LBTIK','LBNO')",.T.,,,,,,,aJoin)

nOK      := aScan(aHTran, {| aVet | AllTrim(aVet[2]) == cAlias+"_OK"} )
nCodage  := aScan(aHTran, {| aVet | AllTrim(aVet[2]) == cAlias+"_CODAGE"} )
nStatus  := aScan(aHTran, {| aVet | AllTrim(aVet[2]) == cAlias+"_STATUS"} )
nCodpla  := aScan(aHTran, {| aVet | AllTrim(aVet[2]) == cAlias+"_CODPLA"} )
nCodpro  := aScan(aHTran, {| aVet | AllTrim(aVet[2]) == cAlias+"_CODPRO"} )
nCodloc  := aScan(aHTran, {| aVet | AllTrim(aVet[2]) == cAlias+"_CODLOC"} )

Aadd(aButtons	, {"edit_ocean", {||Eval(bFS_M28Tod)}, STR0042})  //"Todos"

nOpcA := 0
aSize := MsAdvSize(.T.)
aObjects := {}

AAdd( aObjects, { 100, 015, .T., .T. } )
AAdd( aObjects, { 100, 085, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE STR0056 From aSize[7], 000 To aSize[6], aSize[5]	Of oMainWnd Pixel //"Transferencia de Setor"

@ 30+nTam,004 SAY OemToAnsi(STR0057) OF oDlg PIXEL COLOR CLR_BLUE    //"Setor Transf."
@ 30+nTam,044 MSGET oCodSet VAR cCodTra PICTURE "@!" F3 "GCS" VALID FS_VLDSET(cCodDis,nOK, oTran, cGcsTipLoc) SIZE 25,9  OF oDlg PIXEL COLOR CLR_BLACK
@ 30+nTam,085 MSGET oDesSet VAR cNomTra PICTURE "@!" SIZE 120,9 OF oDlg PIXEL COLOR CLR_BLACK WHEN .F.

oTran := MsNewGetDados():New(aPObjs[2, 1]+nTam, aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4],0,,,,,,,,,, , aHTran, aCTran)
oTran:oBrowse:Align := CONTROL_ALIGN_BOTTOM
oTran:oBrowse:BlDblClick := {|| FS_DblClk(oTran, nOK, .T., nStatus, nCodpla, nCodpro, nCodloc)}
bFS_M28Tod	:= {|| FS_MarTod (oTran, nOK, nCodpro, nCodpla, nCodloc, nStatus)}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1,  IIF(FS_VLDOK(oTran, nOK, nCodage),oDlg:End(), nOpcA == 0)}, ;
{|| nOpcA := 0, oDlg:End()},, aButtons )

If nOpcA == 1
	FS_GrvTra(cAlias, nOK, nCodage, cCodTra, oTran:aCols)
Endif

RestArea(aArea)
Return(nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_VLDSETบ Autor ณ Mario Arizono      บ Data ณ  31/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida setor de transferencia                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_VLDSET(cCodDis, nOk, oTran, cTipLoc)
Local lRet := .T.
Local nPos := 0
Local aArea:= GetArea()

If !HS_SeekRet("GCS","cCodTra",1,.F.)
	HS_MsgInf(STR0058,STR0001,STR0052)   //"Setor Invแlido"###"Valida transfer๊ncia"
	lRet := .F.
Else
	If GCS->GCS_TIPLOC <> cTipLoc
		HS_MsgInf(STR0059,STR0001,STR0052)   //"Setor nใo ้ do tipo ambulatorial"###"Valida transfer๊ncia"
		lRet := .F.
	Else
		cNomTra := GCS->GCS_NOMLOC
	Endif
Endif

If lRet
	For nPos := 1 to len(oTran:aCols)
		If oTran:aCols[nPos,nOk]== "LBTIK"
			oTran:aCols[nPos,nOk] := "LBNO"
		Endif
	Next nPos

	oTran:Refresh()
Endif
RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_GRVTRAบ Autor ณ Mario Arizono      บ Data ณ  31/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava a transferencia                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GRVTRA(cAlias, nOk, nCodage, cCodLoc, aCols)
Local aArea := GetArea()
Local nPos  := 0
Local cSetOld := ""
Local cPrefix := cAlias +"->"+ cAlias

DbSelectArea(cAlias)
DbSetOrder(1)

For nPos := 1 to len(aCols)
	If aCols[nPos,nOk] == "LBTIK"                                    '
		Dbseek(xFilial(cAlias)+aCols[nPos,nCodage])
		cSetOld := &(cPrefix+"_CODLOC")
		Begin Transaction
		RecLock(cAlias,.F.)
		&(cPrefix+"_CODLOC") := cCodLoc
		If cAlias == "GM8"
			GM8->GM8_LOCORI := cSetOld
		EndIf
		MsUnlock()

		End Transaction
	Endif

Next Pos

RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_MarTodบ Autor ณ Mario Arizono      บ Data ณ  22/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca/Desmarca todas as solicitacoes no browse             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_MarTod(oTran, nOk, nCodPro, nCodPla, nCodLoc,nStatus)
Local aArea   := GetArea()
Local nForTra := 0
Local nRegTra := 0

If !Empty(cCodTra)
	For nForTra := 1 to len(oTran:aCols)
		If oTran:aCols[nForTra, nOk] == "LBNO"
			If oTran:aCols[nForTra, nStatus] == "0"
				If oTran:aCols[nForTra, nCodLoc] <> cCodTra
					oTran:aCols[nForTra, nOk] := "LBTIK"
				Else
					nRegTra++
				Endif
			Else
				oTran:aCols[nForTra, nOk] := "LBTIK"
				DbSelectArea("GM2")
				DbSetOrder(1)
				If !DbSeek(xFilial("GM2")+ cCodTra + oTran:aCols[nForTra, nCodPro])
					nRegTra++
					oTran:aCols[nForTra, nOk] := "LBNO"
					Loop
				ElseIf oTran:aCols[nForTra, nCodLoc] == cCodTra
					nRegTra++
					oTran:aCols[nForTra, nOk] := "LBNO"
					Loop
				Else
					DbSelectArea("GM0")
					DbSetOrder(1)
					If DbSeek(xFilial("GM0") + cCodTra + oTran:aCols[nForTra, nCodPla])
						nRegTra++
						oTran:aCols[nForTra, nOk] := "LBNO"
						Loop
					Endif
				Endif
			Endif
		Else
			oTran:aCols[nForTra, nOk] := "LBNO"
		Endif
	Next nForTra
Else
	HS_MsgInf(STR0060,STR0001,STR0052)    //"Preencha o setor de transfer๊ncia."###"Valida transfer๊ncia"
	Return .F.
Endif

oTran:Refresh()
If nRegTra > 0
	HS_MsgInf(IIF(nRegTra == len(oTran:aCols), STR0061, STR0062) + STR0063,STR0001,STR0052)   //"Todos os"###"Alguns"###" registros nใo puderam ser selecionados. Verifique."###"Valida transfer๊ncia"
Endif
RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_VLDOK บ Autor ณ Mario Arizono      บ Data ณ  25/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida ok.                                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_VLDOK(oTran, nOk, nCodage)
Local aArea := GetArea()
Local nPos  := 0
Local lRet  := .T., lOk := .T.

If len(oTran:aCols) == 1
	If Empty(oTran:aCols[1,nCodage])
		HS_MsgInf(STR0064,STR0001,STR0052)   //"Transfer๊ncia nใo efetuada. Registro nใo possui dados."###"Valida transfer๊ncia"
		lRet:= .F.
	Endif
Else
	For nPos := 1 to len(oTran:aCols)
		If oTran:aCols[nPos,nOk] == "LBTIK"
			lOk := .F.
		Endif
	Next nPos
	If lOk
		HS_MsgInf(STR0065,STR0001,STR0052)   //"Nenhum registro foi selecionado."###"Valida transfer๊ncia"
		lRet:= .F.
	Endif
Endif
RestArea(aArea)
Return(lRet)

Static Function Fs_SetVarF()
__cCodDis := GM6->GM6_CODDIS
__cCodSal := GM6->GM6_CODSAL
oCBXRec:aItems := Hs_RetRec(GM6->GM6_CODDIS,,,.T.)
cRecEsc := Substr(cRecEsc, 1, at("-",cRecEsc)-1)
oCBXRec:Refresh()
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AjustaSX บ Autor ณ Rogerio Tabosa     บ Data ณ  16/04/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Ajusta Dicionarios de Dados                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function AjustaSX()
Local aArea 	:= GetArea()
Local aRegs 	:= {}
Local j     			:= 0
Local aHelpPor	:= {}
Local aHelpSpa	:= {}
Local aHelpEng	:= {}
Local nCont     := 0

dbSelectArea("SX1")
dbSetOrder(1)

// Adiciona pergunta "HSM28A"
cPerg := PADR("HSM28A",Len(SX1->X1_GRUPO))
AADD(aRegs,{cPerg,"05","Replica Agenda ?              ","Replica Agenda ?              ","Replica Agenda ?              ","MV_CH4","N",01,00,00,"C","                                                            ","MV_PAR05       ","Nใo            ","Nใo            ","Nใo            ","                                                            ","               ","Sim            ","Sim            ","Sim            ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","            ","                                                            ","      ","N","   ","              ","                                        ","      "})

// Adiciona pergunta "HSM28E"
cPerg := PADR("HSM28E",Len(SX1->X1_GRUPO))
AADD(aRegs,{cPerg,"01","CRM De ?                      ","CRM De ?                      ","CRM De ?                      ","MV_CH0","G",07,00,00,"C","                                                            ","MV_PAR01       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","            ","                                                            ","MED   ","N","   ","              ","                                        ","      "})
AADD(aRegs,{cPerg,"02","CRM Ate?                      ","CRM Ate?                      ","CRM Ate?                      ","MV_CH1","G",07,00,00,"C","                                                            ","MV_PAR02       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","            ","                                                            ","MED   ","N","   ","              ","                                        ","      "})

For nCont := 1 to len(aRegs)
    If !dbSeek(aRegs[nCont,1] + aRegs[nCont,2])
	    RecLock("SX1", .T.)
	    For j := 1 to FCount()
		    If j <= Len(aRegs[nCont])
			    FieldPut(j,aRegs[nCont,j])
		    Endif
	    Next
	    MsUnlock()

	    If Alltrim(aRegs[nCont,1]) == "HSM28A"
	        AADD(aHelpPor,"Informe se serแ replicado ")
	        AADD(aHelpPor,"os agendamentos para o mesmo ")
	        AADD(aHelpPor,"periodo do mes anterior.(APAC)")
	        PutSX1Help("P."+cPerg+strzero(1,2)+".",aHelpPor,aHelpEng,aHelpSpa)
	    EndIf
    EndIf
Next

RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ReplAgeบ Autor ณ Rogerio Tabosa     บ Data ณ  16/04/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Replica os agendamentos para a disponibilidade criada      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_ReplAge(dDatIni, dDatFin, cRecIni, cRecFim, cDisp)
Local aArea		:= getArea()
Local cCodDis 	:= ""
Local cSql	 	:= ""
Local cAnoI	 	:= ""
Local cAnoF	 	:= ""
Local aDatsMes	:= {}
Local nMesI		:= 0
Local nMesF		:= 0
Local nAux		:= 1
Local cMes		:= StrZero(Month(dDatIni),2)
Local dIMesAnt	:= CTOD("")
Local dFMesAnt	:= CTOD("")
Local nMes 		:=0

Default cDisp	:= ""

If cMes == "01"
	dIMesAnt	:= CTOD("01/12/" + AllTrim(Str(Val(Substr(DTOC(dDatIni),7,4))-1)) + "")
	dFMesAnt	:= CTOD(StrZero(F_ULTDIA(dIMesAnt),2)+"/12/"+AllTrim(Str(Val(Substr(DTOC(dDatIni),7,4))-1)) + "")
Else
	dIMesAnt	:= CTOD("01/" + StrZero(Month(dDatIni)-1,2) + "/" + Substr(DTOC(dDatIni),7,4) + "")
	dFMesAnt	:= CTOD(StrZero(F_ULTDIA(dIMesAnt),2)+"/"+StrZero(Month(dDatIni)-1,2)+"/"+Substr(DTOC(dDatIni),7,4))
EndIf

If !Empty(cDisp)
	cCodDis := cDisp
ElseIf Len(aItensMar) > 0
	cCodDis := aItensMar[1][1]
Else
	Return(Nil)
EndIf

If StrZero(Month(dDatIni),2) == StrZero(Month(dDatFin),2)
	AADD(aDatsMes,{dDatIni,dDatFin})
Else
	cAnoI 	:= Substr(DTOC(dDatIni),7,4)
	cAnoF 	:= Substr(DTOC(dDatFin),7,4)
	nMesI	:= Month(dDatIni)
	nMesF	:= Month(dDatFin)
	nMes ++
	//AADD(  aDatsMes,{  dDatIni,  CTOD(  StrZero(F_ULTDIA(  dDatIni  ),2  )+"/"+  StrZero(Month(dDatIni),2)  +"/"+cAnoI)  }  )
	AADD(aDatsMes,{dDatIni, CTOD (StrZero(F_ULTDIA(dDatIni),2)+"/"+  StrZero(Month(dDatIni),2)  +"/"+cAnoI) } )
	If cAnoI == cAnoF
		While nMesI < nMesF
			AADD(aDatsMes,{CTOD("01/"+StrZero(nMesI,2)+"/"+cAnoI), CTOD (StrZero(F_ULTDIA(CTOD("01/"+StrZero(nMesI,2)+"/"+cAnoI)),2)+"/"+  StrZero(nMesI,2)  +"/"+cAnoI) } )
			//			AADD(aDatsMes,{"01/"+StrZero(nMes,2)+"/"+cAnoI)), CTOD(StrZero(F_ULTDIA(CTOD("01/"+StrZero(nMes,2)+"/"+cAnoI)),2)+"/"+StrZero(nMes,2)+"/"+cAnoI))})
			nMesI++
		End
	Else
		While nMesI <= 12
			AADD(aDatsMes,{CTOD("01/"+StrZero(nMesI,2)+"/"+cAnoI), CTOD (StrZero(F_ULTDIA(CTOD("01/"+StrZero(nMesI,2)+"/"+cAnoI)),2)+"/"+  StrZero(nMesI,2)  +"/"+cAnoI) } )
			nMesI++
		End
		While nAux < nMesF
			AADD(aDatsMes,{CTOD("01/"+StrZero(nAux,2)+"/"+cAnoF), CTOD (StrZero(F_ULTDIA(CTOD("01/"+StrZero(nAux,2)+"/"+cAnoF)),2)+"/"+  StrZero(nAux,2)  +"/"+cAnoF) } )
			nAux++
		End
	EndIf
	AADD(aDatsMes,{CTOD (StrZero(F_ULTDIA(dDatFin),2)+"/"+  StrZero(Month(dDatFin),2)  +"/"+cAnoF),dDatFin } )
EndIf

cSql := "SELECT GM8.GM8_CODAGE,GM8.GM8_SEQAGE,GM8.GM8_DATAGE,GM8.GM8_HORAGE,GM8.GM8_CODREC "
cSql += " FROM " + RetSqlName("GM8") + " GM8 WHERE GM8.GM8_SEQAGE IN ("
cSql += "SELECT GM8_SEQAGE "
cSql += " FROM " + RetSqlName("GM8") + " GM82 "
cSql += " JOIN " + RetSqlName("GK7") + " GK7 ON GK7_SEQAGE = GM82.GM8_SEQAGE"
cSql += " AND GK7.D_E_L_E_T_ <> '*' AND GK7_FILIAL = '" + xFilial("GK7") + "'"
cSql += " JOIN " + RetSqlName("GCY") + " GCY ON GCY_REGATE = GM82.GM8_REGATE AND GCY_DATALT = '        '"
cSql += " AND GCY.D_E_L_E_T_ <> '*' AND GCY_FILIAL = '" + xFilial("GCY") + "'"
cSql += " WHERE GM82.GM8_DATAGE BETWEEN '"+DTOS(dIMesAnt)+"' AND '"+DTOS(dFMesAnt)+"'"
cSql += " AND GM82.GM8_CODREC >= '"+cRecIni+"' And GM82.GM8_CODREC <= '"+cRecFim+"' "
cSql += " AND GM82.GM8_CODDIS = '" + cCodDis + "'"
cSql += " AND GM82.D_E_L_E_T_ <> '*' AND GM8_FILIAL = '" + xFilial("GM8") + "')"
cSql += " AND GM8.GM8_DATAGE BETWEEN '"+DTOS(dIMesAnt)+"' AND '"+DTOS(dFMesAnt)+"'"
cSql += " AND GM8.GM8_CODREC >= '"+cRecIni+"' And GM8.GM8_CODREC <= '"+cRecFim+"' "
cSql += " ORDER BY GM8_SEQAGE"

cSql := ChangeQuery(cSql)

TCQuery cSql New Alias "TMPREPL"

DbSelectArea("TMPREPL")

While !Eof()
	FS_CRIAREPL(TMPREPL->GM8_CODAGE, TMPREPL->GM8_SEQAGE, TMPREPL->GM8_DATAGE, TMPREPL->GM8_HORAGE, TMPREPL->GM8_CODREC, aDatsMes, cCodDis)
	DbSkip()
End

DbSelectArea("TMPREPL")
DbCloseArea()

RestArea(aArea)
Return

Static Function FS_CRIAREPL(cCODAGE, cSEQAGE, cDATAGE, cHORAGE, cCODREC, aInterv, cCodDis)
Local aArea 	:= GetArea()
Local nInterv 	:= 0
Local cSql		:= ""
Local dDatIni	:= CTOD("")
Local dDatFin	:= CTOD("")
Local nDiaSem  := Dow(STOD(cDATAGE))

For nInterv := 1 to Len(aInterv)
	dDatIni := aInterv[nInterv,1]
	dDatFin := aInterv[nInterv,2]
	While dDatIni <= dDatFin
		//cAlias := GetNextAlias()
		If Dow(dDatIni) == nDiaSem
			cAlias := GetNextAlias()
			cSql := " SELECT GM8_CODAGE "
			cSql += " FROM " + RetSqlName("GM8") + " GM8 "
			cSql += " WHERE GM8.GM8_DATAGE ='" + DTOS(dDatIni) + "' AND GM8_HORAGE = '" + cHORAGE + "'"
			cSql += " AND GM8.GM8_CODDIS = '" + cCodDis + "' AND GM8_CODREC = '" + cCODREC + "' AND GM8_STATUS = '0'"
			cSql += " AND GM8.D_E_L_E_T_ <> '*' AND GM8_FILIAL = '" + xFilial("GM8") + "'"
			cSql := ChangeQuery(cSql)

			TCQuery cSql New Alias "TMPNAGE"

			DbSelectArea("TMPNAGE")
			If !Eof()
				FS_GRVREPL(TMPNAGE->GM8_CODAGE, cCODAGE, dDatIni, cHORAGE)
				DbSelectArea("TMPNAGE")
				DbCloseArea()
				RestArea(aArea)
				Return()
			EndIf
			DbSelectArea("TMPNAGE")
			DbCloseArea()
		EndIf
		dDatIni++
	End

Next  nInterv

RestArea(aArea)
Return

Static Function FS_GRVREPL(cAgeDest, cAgeOri, dDatNew, cHorNew)
Local aArea 	:= GetArea()
Local nCont		:= 0
Local bCampo	:=	{|nCpo| Field(nCpo)}

INCLUI := .F.

DbSelectArea("GM8")
DbSetOrder(1)
If DbSeek(xFilial("GM8") + cAgeOri)
	RegToMemory("GM8", .F.)
Else
	RestArea(aArea)
	Return()
EndIf

INCLUI := .T.

DbSelectArea("GM8")
DbSetOrder(1)
DbGoTop()
If DbSeek(xFilial("GM8") + cAgeDest)
	RecLock("GM8", .F.)

	M->GM8_STATUS	:= "1"
	M->GM8_DATAGE	:= dDatNew
	M->GM8_HORAGE	:= cHorNew
	M->GM8_DATCAD	:= dDataBase
	M->GM8_HORCAD	:= Time()
	M->GM8_LOGARQ	:= HS_LogArq()
	M->GM8_NUMSES	:= M->GM8_NUMSES + 1
	M->GM8_CODAGE	:= GM8->GM8_CODAGE
	M->GM8_REGATE	:= Space(TamSx3("GM8_REGATE")[1])
	M->GM8_AGDPRC	:= GM8->GM8_CODAGE

	For nCont := 1 To FCount()  // Copia dados do registro original
		If "FILIAL" $ Field(nCont)
			FieldPut(nCont, xFilial("GM8"))
		Else
			FieldPut(nCont, M->&(Eval(bCampo, nCont)))
		EndIf
	Next nCont
	MsUnLock()
EndIf

RestArea(aArea)
Return()
/**/