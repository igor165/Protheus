#INCLUDE "HSPAHM25.ch"
#include "Protheus.CH"
#include "TOPCONN.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM25  บ Autor ณ Paulo Jose         บ Data ณ  30/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ GERA A AGENDA DOS BLOCOS                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHM25()

 Local nCntFor  := 0
 Local oFont
 Local oAno
 Local cAno     := StrZero(Year(Date()), 4) 
 Local aMeses   := {}
 Local cMes     := " "
 Local oDlg     // Tem de ser local para que funcione com a tela de alteracao de Disponibilidade   cAlias, nReg, nOpc)
 Local bFS_M25	 := {|| INCLUI := .F., ALTERA := .T., LREFRESH := .T., LRESVALID := .T., LMODIFIED := .F., HS_AA3("GMD", RecNo(), 4)} // Chama a funcao AA3
 Local bKey_F4	 :=  SetKey( VK_F4, { || Eval(bFS_M25)} ) // inicializa a tecla F4
 Local aButtons := {}
 Local cCond    := ""
 Local aSize		:= {}
 Local aInfo		:= {}
 Local aObjects	:= {}
 
 Private aDiasGer    := {}
 Private oMeses
 Private oCalend
 Private aDiasDisp   := {.F., .F., .F., .F., .F., .F., .F., .F.}     //Dias da semana Disponibilidade
 Private aItensMar   := {}     //Itens Selecionado pela HS_MBrow
 Private aHorriosMar := {}     //Horarios Selecionado pela HS_MBrow
 Private oGMJ, oGMG, oGMD
 Private aCGMJ := {}, aHGMJ := {}, nUGMJ := 0
 Private oBtnGer, oBtnInd, oBtnAju, oBtnExc, oBtnAno1, oBtnAno2
 Private cM25Opcao := ""

 //Adciona o bota na enchoicebar
 Aadd(aButtons	, {"edit_ocean", {|| Eval(bFS_M25)}, STR0032}) //"Disponibilidade M้dica"
 
 aAdd(aMeses, STR0001)  //"JANEIRO"
 aAdd(aMeses, STR0002)  //"FEVEREIRO"
 aAdd(aMeses, STR0003)  //"MARวO"
 aAdd(aMeses, STR0004)  //"ABRIL"
 aAdd(aMeses, STR0005)  //"MAIO"
 aAdd(aMeses, STR0006)  //"JUNHO"
 aAdd(aMeses, STR0007)  //"JULHO"
 aAdd(aMeses, STR0008)  //"AGOSTO"
 aAdd(aMeses, STR0009)  //"SETEMBRO"
 aAdd(aMeses, STR0010)  //"OUTUBRO"                                                  
 aAdd(aMeses, STR0011)  //"NOVEMBRO"
 aAdd(aMeses, STR0012)  //"DEZEMBRO"
 
	cCond := "GMJ_CODDIS = '" + GMD->GMD_CODDIS + "' AND GMJ_DATAGE >= '" + DTOS(dDataBase) + "' AND GMJ_DATAGE <= '" + DToS(LastDay(dDataBase)) + "'"

 HS_BDados("GMJ", @aHGMJ, @aCGMJ, @nUGMJ, 3, "", cCond,,, "GMJ_CODDIS/GMJ_FILAGE/GMJ_DATAGE/GMJ_HORAGE/GMJ_TIPAGE/GMJ_STATUS",,,,,, .T.)
 
 aSize := MsAdvSize(.F.)
 aObjects := {}           
 AAdd( aObjects, { 100, 100, .T., .T. } ) // tamanho ( X ) fixo

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0033) From aSize[7], 000 To aSize[6], aSize[5]	Of oMainWnd  pixel //"Gerar horแrio"
  oGMD := HS_MBrow(oDlg, "GMD", {013, 003, 388, 070},,,,, "GMD_OK",, @aItensMar, "GMD_CODDIS",, .T.,, .T., ;
                   {"GMD_NOMCRM", "GMD_CODCRM", "GMD_CODDIS", "GMD_DESDIS", "GMD_HORINI", "GMD_HORFIM", "GMD_INTMAR", "GMD_QTENCX"}, "HS_VDisCB")
  //oGMD:BDRAWSELECT := {|| aDiasGer := {}, FS_SeleBrw(.T.)}
  oGMD:BDRAWSELECT := {||   MsgRun(STR0041,STR0042,{|| aDiasGer := {}, FS_SeleBrw(.T., .F. ) }) } //"aguarde..."###"Processando"
  
  oCalend := MsCalend():New(120, 075, oDlg)
 
  @ 110, 003 ListBox oMeses Var cMes Fields Header OemToAnsi(STR0013) Size 070, 120 NoScroll Of oDlg Pixel //"M๊s Atual"
  oMeses:SetArray(aMeses)
  oMeses:nAt      := Month(dDataBase)
  oMeses:bLine    := {|| {aMeses[oMeses:nAt]} }
  oMeses:bChange  := {|| oCalend:dDiaAtu := FS_PriDia(Ctod("01/" + StrZero(oMeses:nAt, 2) + "/" + cAno)), oCalend:Refresh(), FS_SeleBrw(.T.)}
  oCalend:nHeight := 220
  oCalend:nWidth  := 280
  oCalend:BLDBLCLICK := {|| FS_SeleCal(oCalend:dDiaAtu)}
  oCalend:bChangeMes := {|| oCalend:dDiaIni := FS_PriDia(FirstDay(oCalend:dDiaAtu)), oMeses:nAt := Month(oCalend:dDiaAtu), cAno := StrZero(Year(oCalend:dDiaAtu), 4), oAno:Refresh(), oMeses:Refresh(), oCalend:Refresh(), FS_SeleBrw(.T.)}
 
  //Selecao do Ano
  @ 110, 075 Button oBtnAno1 Prompt "<" Action (cAno := StrZero(Val(cAno) - 1, 4), oAno:Refresh(), FS_MaDeCal(oCalend:dDiaAtu, "L"), oCalend:dDiaAtu := Ctod("01/" + StrZero(oMeses:nAt, 2) + "/" + cAno), oCalend:Refresh(), FS_SeleBrw()) When .T. Size 009, 010 Of oDlg Pixel
 
  @ 110, 105 Button oBtnAno2 Prompt ">" Action (cAno := StrZero(Val(cAno) + 1, 4), oAno:Refresh(), FS_MaDeCal(oCalend:dDiaAtu, "L"), oCalend:dDiaAtu := Ctod("01/" + StrZero(oMeses:nAt, 2) + "/" + cAno), oCalend:Refresh(), FS_SeleBrw()) When .T. Size 009, 010 Of oDlg Pixel
 
  @ 110, 088 SAY oAno PROMPT OemToAnsi(cAno) OF oDlg SIZE 030,010 FONT oFont Pixel COLOR CLR_RED
 
   //Selecao atraves do Calendario
  oCalend:bChange := {|| cAno := StrZero(Year(oCalend:dDiaAtu), 4), oAno:Refresh(), oMeses:nAt := Month(oCalend:dDiaAtu), oMeses:Refresh()}
  oGMJ := MsNewGetDados():New(120, 218, 230, 390, 0,,,,,,,,,, oDlg, aHGMJ, aCGMJ)
 
  oBtnGer := tButton():New(242, 003, STR0014, oDlg, {|| FS_MntPerg("G")}, 50, 15,,,, .T.) //"Gerar horแrios "
  oBtnAju := tButton():New(242, 070, STR0045, oDlg, {|| FS_MntPerg("A")}, 50, 15,,,, .T.) //"Ajusta Horแrios"
  oBtnInd := tButton():New(242, 140, STR0015, oDlg, {|| FS_MntPerg("I")}, 50, 15,,,, .T.) //"Indisponibiliza"
  oBtnExc := tButton():New(242, 210, STR0016, oDlg, {|| FS_MntPerg("E")}, 50, 15,,,, .T.) //"Ecluir horแrios"
  oBtnTran:= tButton():New(242, 280, STR0046,oDlg,{|| FS_MntPerg("T") },50,15,,,,.T.) //"Transfer๊ncia"

 ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| oDlg:End()}, {|| oDlg:End()},, aButtons)
 SetKey(VK_F4, { || Eval(bKey_F4)})
Return(Nil)
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_MntAge บ Autor ณ PAULO JOSE         บ Data ณ 06/12/04    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta rotina para gerar a agenda (GMJ)                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  (Agenda Ambulatorial)                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_MntAge(dDataInicial, dDataFinal)

 Local aArea        := GetArea()
 Local lRet         := .T.
 Local lOkWhil      := .T.
 Local nDia         := 0
 Local nContFor     := 0
 Local nGMJ_OK      := aScan(aHGMJ, {| aVet | aVet[2] == "GMJ_OK"})
 Local cCond        := ""
 Local nContForDias := 0
 Local cDispDias    := Space(12)
 Local nDiaSem      := 0
 Local lFeriado     := .F.               
 Local nMesGer      := 0
 Local cCodDis      := ""
 Local dDataAtu     := ""
 Local dDataFin     := ""
 Local dData        := dDataBase
 
 INCLUI := .T.
 
	//Verifica se ha dia da semana cadastrados(GM5) para esta Disponibilidade
	For nContFor := 1 To Len(aItensMar)
	
	 cCodDis := aItensMar[nContFor][1]
	 
 	If !FS_VldDis("GMG", 1, cCodDis)
 	 HS_MsgInf(OemtoAnsi(STR0017 + cCodDis), OemtoAnsi(STR0018), STR0034) //"Nใo existem dias lan็ados para a disponibilidade: "###"Aten็ใo"###"Rotina para gerar a agenda"
   Return(.F.)
 	EndIf
 	
  //Verific se jแ tem horarios gerado para a disponibilidade no periodo informado
  If FS_HorGer(cCodDis, dDataInicial, dDataFinal)
   Return(.F.) 	
  EndIf
 
 Next nContFor

 oCalend:Disable()
 oMeses:Disable()

 oCalend:dDiaAtu := dDataInicial

 dDataFin := FirstDay(dDataFinal)
 dDataAtu := FirstDay(dDataInicial)

	For nContFor := 1 To Len(aItensMar)
	 cCodDis := aItensMar[nContFor][1]
		FS_LeDiaSe(cCodDis)   

		If Len(aItensMar) > 1
		 aDiasGer := {}
		EndIf 
		
		dData := dDataInicial
		While dData <= dDataFinal
   If aScan(aDiasGer, {| aDia | FirstDay(aDia) == FirstDay(dData)}) == 0
  		
  		dDataAtu := FirstDay(dData)
    While dDataAtu == FirstDay(dData)
  		 nDiaSem  := Dow(dData)
  		 lFeriado := HS_IsFreeDay(dData)

	    If (lFeriado .And. aDiasDisp[8] .And. aDiasDisp[nDiaSem]) .Or. ; // Feriado
  		    (!lFeriado .And. aDiasDisp[nDiaSem])                            // Dias Normais
 	    If aScan(aDiasGer, dData) == 0
 		    aAdd(aDiasGer, dData)
  	   EndIf 
  	  EndIf 

 			 dData++
 			 If dData > dDataFinal
 			  Exit
 			 EndIf 
	
    EndDo
        
   Else    
    dData := LastDay(dData) + 1
   EndIf
 	EndDo	

  If !FS_VldHor(dDataInicial, dDataFinal)
   Return(.F.)
  EndIf

 	//Percorre o Vetor de dias da Semana Selecionadas
  aDiasGer := aSort(aDiasGer)
	 For nContForDias := 1 To Len(aDiasGer)
	  If aDiasGer[nContForDias] >= dDataInicial .And. aDiasGer[nContForDias] <= dDataFinal
 	 	If !FS_VldDis("GMJ", 3, cFilAnt + cCodDis + DToS(aDiasGer[nContForDias])) //Verificar
	  		FS_GerAge(cCodDis, aDiasGer[nContForDias]) //Gera agenda (GMJ)
	  	EndIf	
	 	EndIf
	 Next

 Next nContFor
 		
	FS_SeleBrw(.T.)
 oCalend:Enable()                                 
 oMeses:Enable()
 oBtnAju:Enable()
 oBtnInd:Enable()
 oBtnExc:Enable()
 oBtnAno1:Enable()
 oBtnAno2:Enable()

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
ฑฑบ          ณ 	      cModo       												                            บฑฑ
ฑฑบ          ณ	       "S" = Marca todos os dias da semana                 บฑฑ
ฑฑบ          ณ        "D" = Marca dia do mes (1, ... , 31)                บฑฑ
ฑฑบ          ณ        "L" = Limpa Selecao                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_MaDeCal(dDataAtu, cModo, cChave)

 Local dLimpaSele := FirstDay(dDataAtu)
 Local nPosDia    := aScan(aDiasGer, dDataAtu)

 If cModo == "S" .Or. cModo == "SF"
 	If !(cChave == Nil) .And. FS_VldDis("GMJ", 3, cChave) .And. ( dDataAtu >= dDataBase )
		 If cModo == "SF"
			 oCalend:addRestri(Day(dDataAtu), CLR_HGREEN, CLR_HGREEN)
			Else                                              
			 oCalend:addRestri(Day(dDataAtu), CLR_RED, CLR_RED)
			EndIf 
		Else
		 If cModo == "SF"
			 oCalend:addRestri(day(dDataAtu), CLR_GREEN, CLR_GREEN)
			Else 
			 oCalend:addRestri(day(dDataAtu), CLR_BLUE, CLR_BLUE)
			EndIf 
		EndIf
		
	 If nPosDia == 0
		 aAdd(aDiasGer, dDataAtu)
 	EndIf 
 ElseIf cModo == "D" .Or. cModo == "DF" //MARCA OU DESMARCA UM DIA
 	If nPosDia == 0
 	 If cModo == "DF"
 	  oCalend:addRestri(day( dDataAtu ), CLR_GREEN, CLR_GREEN)
 	 Else
 		 oCalend:addRestri(day( dDataAtu ), CLR_BLUE, CLR_BLUE)
 		EndIf 
 		aAdd(aDiasGer, dDataAtu)
 	Else
 		If !(cChave == Nil)
 			If !FS_VldDis("GMJ", 3, cChave) //Se nao encontrar a Chave ( cFilRet + CODDISP + dDATA )
 				oCalend:addRestri(Day(dDataAtu), CLR_BLACK, CLR_WHITE)
 			EndIf
 		Else
 			oCalend:addRestri(Day(dDataAtu), CLR_BLACK, CLR_WHITE)
 		EndIf
 		
 		aDel(aDiasger, nPosDia)
 		aSize(aDiasGer, Len(aDiasGer) - 1)
 	EndIf
 	
 ElseIf cModo == "L"  //lIMPA OS DIAS LILECIONADOS ( LIMPA TUDO )
 	While Month(dLimpaSele) == Month(dDataAtu)
 		oCalend:addRestri(Day(dLimpaSele), CLR_BLACK, CLR_WHITE)
 		dLimpaSele := dLimpaSele + 1
 	End
 EndIf
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
Static Function FS_SeleCal( dData )

 Local lRet  := .T.
 Local cModo := IIF(HS_IsFreeDay(dData), "DF", "D")

 If FS_VldDis("GMJ", 3, cFilAnt + GMD->GMD_CODDIS + DTOS(oCalend:dDiaAtu))
 	FS_MaDeCal(dData, cModo, cFilAnt + GMD->GMD_CODDIS + DTOS(dData))
 	lRet := .F.
 Else
 	If dData < dDataBase
 		HS_MsgInf(OemtoAnsi(STR0019), OemtoAnsi(STR0018), STR0035) //"Nใo pode ser selecionado um dia anterior ao dia de hoje."###"Aten็ใo"###"Selecionar os dias no calendแrio"
 		lRet := .F.
 	Else
 		FS_MaDeCal(dData, cModo)
 	EndIf
 EndIf
 
	cCond := "GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ_FILAGE = '" + cFilAnt + "' AND GMJ_CODDIS = '" + GMD->GMD_CODDIS + "' AND GMJ_DATAGE = '" + DTOS(oCalend:dDiaAtu) + "'"
 FS_AtuGetD(3, cFilAnt + GMD->GMD_CODDIS + DTOS(oCalend:dDiaAtu), cCond)
 
Return(lRet)   


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |HS_VDisCB บ Autor ณ PAULO JOSE         บ Data ณ 16/12/04    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Le os dias da semana (GMD) cadastrados para a              บฑฑ
ฑฑบ          ณ disponibilidae                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  (Agenda Ambulatorial)                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_VDisCB()

 Local lRet := .T.

 If !FS_VldDis("GMD", 1, GMD->GMD_CODDIS)
	 If Len(aItensMar) > 1
	 	HS_MsgInf(OemtoAnsi(STR0020), OemtoAnsi(STR0018), STR0036) //"Nใo existe dias lan็ados para estas disponibilidades"###"Aten็ใo"###"Dias da semana (GMD)cadastrados para a disponibilidade"
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
ฑฑบDescricao ณ Le os dias da semana (GMD) cadastrados para a              บฑฑ
ฑฑบ          ณ disponibilidae                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  (Agenda Ambulatorial)                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_SeleBrw(lLimpa) //cGMD_CODDIS

 Local ddata
 Local lRet  := .T.
 Local cCond := ""
 
 Default lLimpa   := .F.
 
 //Data da oCalend deve ser sempre maior ou igual a Data Base do sistema
	dData           := FS_PriDia(FirstDay(oCalend:dDiaAtu))
 oCalend:dDiaAtu := dData

 ntecla = lastkey()
 
 If Len(aItensMar) == 0
 	FS_MaDeCal(oCalend:dDiaAtu, "L")
 	
 	If Len(aCGMJ) > 0
   aCGMJ := {}
   oGMJ:SetArray(aCGMJ)
   oGMJ:oBrowse:Refresh()
  EndIf 
  
 	oCalend:Enable()
 	oMeses:Enable()
 	oBtnAju:Enable()
 	oBtnInd:Enable()
 	oBtnExc:Enable()
 	oBtnAno1:Enable()
 	oBtnAno2:Enable()
 ElseIf Len(aItensMar) == 1
 	//FS_LeDiaSe(aItensMar[1][1])
 	FS_LeDiaSe(GMD->GMD_CODDIS)
 	oCalend:Enable()
 	oMeses:Enable()
 	oBtnAju:Enable()
 	oBtnInd:Enable()
 	oBtnExc:Enable()
 	oBtnAno1:Enable()
 	oBtnAno2:Enable()
  
 	If lLimpa
 	 FS_MaDeCal(oCalend:dDiaAtu, "L")
 	Endif 

		cCond := "GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ_FILAGE = '" + cFilAnt + "' AND GMJ_CODDIS = '" + GMD->GMD_CODDIS + "' AND GMJ_DATAGE >= '" + DTOS(oCalend:dDiaAtu) + "' AND GMJ_DATAGE <= '" + DToS(LastDay(oCalend:dDiaAtu)) + "'"
 	//FS_AtuGetD(3, cFilAnt + aItensMar[1][1] + DTOS(oCalend:dDiaAtu), cCond)
 	FS_AtuGetD(3, cFilAnt + GMD->GMD_CODDIS + DTOS(oCalend:dDiaAtu), cCond)
 	
 	If aScan(aDiasGer, {| aDias | FirstDay(aDias) == FirstDay(dData)}) == 0
 	 While Month(dData) == Month(oCalend:dDiaAtu)

 	 	//If aDiasDisp[Dow(ddata)] .Or. FS_VldDis("GMJ", 3, cFilAnt + aItensMar[1][1] + DToS(dData))
 	 	If aDiasDisp[Dow(ddata)] .Or. FS_VldDis("GMJ", 3, cFilAnt + GMD->GMD_CODDIS + DToS(dData))
	 			//FS_MaDeCal(ddata, IIF(HS_IsFreeDay(dData), "SF", "S"), cFilAnt + aItensMar[1][1] + DToS(dData))
	 			FS_MaDeCal(ddata, IIF(HS_IsFreeDay(dData), "SF", "S"), cFilAnt + GMD->GMD_CODDIS + DToS(dData))
 	 	EndIf
 		
  		dData++
  	EndDo
  Else
   //FS_MaDeArr(aDiasGer, cFilAnt + aItensMar[1][1], dData)
   FS_MaDeArr(aDiasGer, cFilAnt + GMD->GMD_CODDIS, dData)
  EndIf	
 ElseIf Len(aItensMar) > 1
 	
 	FS_MaDeCal(oCalend:dDiaAtu, "L")

  If Len(aCGMJ) > 0
   aCGMJ := {}
   oGMJ:SetArray(aCGMJ)
   oGMJ:oBrowse:Refresh()
  EndIf 
 	
 	oCalend:Disable()
 	oMeses:Disable()
 	oBtnAju:Disable()
 	oBtnInd:Disable()
 	oBtnExc:Disable()
 	oBtnAno1:Disable()
 	oBtnAno2:Disable()
 EndIf
 
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_AtuGetDบ Autor ณ PAULO JOSE         บ Data ณ 21/12/04    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza a MSNewGetDados com os dados da GMJ referente     บฑฑ
ฑฑบ          ณ          ao filtro                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParame   	ณ	cChave:  chave para pesquisa 																														บฑฑ
ฑฑบ										ณ	nOrd:		 	ordem para pesquisa     																										บฑฑ
ฑฑบ										ณ	cFiltro: Filtro																																												บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  (Agenda Ambulatorial)                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_AtuGetD( nOrd, cChave, cFiltro )

 Local lRet := .T.
 
 aHGMJ := {}
 aCGMJ := {}
 nUGMJ := 0
 
 HS_BDados("GMJ", @aHGMJ, @aCGMJ, @nUGMJ, nOrd, cChave, cFiltro,,, "GMJ_CODDIS/GMJ_FILAGE/GMJ_DATAGE/GMJ_HORAGE/GMJ_TIPAGE/GMJ_STATUS",,,,,, .T.)
 
 oGMJ:SetArray(aCGMJ)
 oGMJ:oBrowse:Refresh()
 
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_LeDiaSeบ Autor ณ PAULO JOSE         บ Data ณ 09/12/04    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Le os dias da semana (GMD) cadastrados para a              บฑฑ
ฑฑบ          ณ disponibilidae                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  (Agenda Ambulatorial)                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_LeDiaSe(cGMD_CODDIS)

 Local cAliasOld := Alias()
 Local lRet := .F.
             
 If cGmd_CodDis # GMD->GMD_CODDIS
	 DbSelectArea("GMD")
  DbSetOrder(1) // GMD_FILIAL + GMD_CODDIS
	 DbSeek(xFilial("GMD") + cGMD_CodDis)
	EndIf 
 
 DbSelectArea("GMG")
 DbSetOrder(1) // GMG_FILIAL + GMG_CODDIS + GMG_DIASEM
 
 If DbSeek(xFilial("GMG") + cGMD_CODDIS)
 	aDiasDisp := {.F., .F., .F., .F., .F., .F., .F., .F.}
 	lRet := .T.
 	
 	//Carregar dias da Semana no vetor aDiasDisp
 	While (GMG->GMG_CODDIS == cGMD_CODDIS)
 		aDiasDisp[Val(GMG->GMG_DIASEM)] := .T.
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
ฑฑบDescricao ณ Gera horario na agenda (GMJ)                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  (Agenda Ambulatorial)                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GerAge(cGMD_CODDIS, dDataAge, cOp, aColsReg)

 Local cTipoAge     := space(01)
 Local nContaEcx    := 0
 Local cHoraInicial := space(05)
 Local cHoraFinal   := space(05)
 Local cHoraAge     := space(05)
 Local lAchou       := .F.
 Local nContFor     := 0
 
 cOp := IIF (cOp == Nil, "GER", cOp )
 aColsReg := IIF (aColsReg == Nil, {}, aColsReg)
 
 DbSelectArea("GMJ")
 DbSetOrder(1) //GMJ_FILIAL + GMJ_CODAGE
 
 cHoraAge := GMD->GMD_HORINI
 nContFor := 0
 cTipoAge := "0"      //Agendamento

 //Verifica se quantos encaixes ja foram usados
 For nContFor := 1 To Len(aColsReg)
 	If aColsReg[ncontfor][3] = "1"
 		nContaEcx ++
 	EndIf
 Next
 
 //Repete enquanto hora de agendamento nao estiver vazia
 While !Empty(cHoraAge)
 	
 	If (cOp == "AJU") .And. Len(aColsReg) > 0
 		
 		lAchou := !(aScan(aColsReg, {| aVet | aVet[1]+aVet[2] == dtoc(dDataAge)+cHoraAge}) = 0)
 		
 	EndIf
 	
 	If !lAchou                         
 	 M->GMJ_CODAGE := HS_VSxeNum("GMJ", "M->GMJ_CODAGE", 1)
 	 ConfirmSx8()
 	 
 		Begin Transaction
 		 RecLock("GMJ", .T.)
 				GMJ->GMJ_FILIAL := xFilial("GMJ")
 		  GMJ->GMJ_FILAGE := cFilAnt
 		  GMJ->GMJ_CODAGE := M->GMJ_CODAGE
 		  GMJ->GMJ_LOCATE := GMD->GMD_LOCATE
 		  GMJ->GMJ_CODLOC := GMD->GMD_CODLOC
 		  GMJ->GMJ_CRMPRI := GMD->GMD_CODCRM  //CRM PRIORITARIO
 		  GMJ->GMJ_QUARTO := GMD->GMD_QUARTO
 		  GMJ->GMJ_DATAGE := dDataAge
 		  GMJ->GMJ_HORAGE := cHoraAge
 		  GMJ->GMJ_CODDIS := cGMD_CODDIS
 		  GMJ->GMJ_DATCAD := dDataBase
 		  GMJ->GMJ_HORCAD := TIME()
 		  GMJ->GMJ_STATUS := "0"
 		  GMJ->GMJ_LOGARQ := HS_LogArq()
 		 MsUnlock()
 		 ConfirmSx8()
 		End Transaction
 	EndIf
 	
 	//Cria novo Horario no GMJ
 	cHoraAge := FS_GerHor(cHoraAge , GMD->GMD_HORFIM , GMD->GMD_INTMAR)
 EndDo
 
Return(.T.)

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

 Local nHoraIni := Val(SubStr(cHorIni, 1, 2))
 Local nMinIni	 := Val(SubStr(cHorIni, 4, 2))
 Local nHoraInt := Val(SubStr(cIntMar, 1, 2))
 Local nMinInt	 := Val(SubStr(cIntMar, 4, 2))
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

 cRet	:= StrZero(nHoraRet, 2) + ":" + StrZero(nMinRet, 2)
 
 If cRet < cHorIni .Or. cRet > cHorFim 
 	cRet	:= " "
 EndIf  
 
Return(cRet)

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
 Local lRet := .F.

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
ฑฑบPrograma  |FS_HorGer บ Autor ณ Cibele Peria       บ Data ณ 29/11/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verifica se ha horarios gerados na agenda para a disponibi-บฑฑ
ฑฑบ          ณ lidade, no periodo informado.                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_HorGer(cCodDis, dDtIni, dDtFin)      

 DbSelectArea("GMJ")
 DbSetOrder(3) //GMJ_FILIAL + GMJ_FILAGE + GMJ_CODDIS + GMJ_DATAGE
 DbSeek(xFilial("GMJ") + cFilAnt + cCodDis + DToS(dDtIni), .T.) 
 If !EOF() .And. GMJ->GMJ_FILIAL == xFilial("GMJ") .And. GMJ->GMJ_FILAGE == cFilAnt .And. GMJ->GMJ_CODDIS == cCodDis .And. DToS(GMJ->GMJ_DATAGE) <= DTos(dDtFin)
  HS_MsgInf(STR0031 + cCodDis + CHR(10) + STR0040 + DTOC(GMJ->GMJ_DATAGE), STR0018, STR0034) //"Jแ existem horแrios gerados no perํodo informado para a disponibilidade: "###"Data: "###"Aten็ใo"###"Rotina para gerar a agenda" 
  Return(.T.)
 EndIf

Return(.F.)


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

 Local dDataInicial := ctod("  /  /  ")
 Local dDataFinal   := ctod("  /  /  ")
 Local cCodCan      := ""
 
 cM25Opcao := cOpPerg
 
 If !Pergunte(IIf(cOpPerg == "I", "HSM25B", "HSM25A"), .T.)
 	Return(.F.)
 Else
  If cOpPerg == "I"	
   cCodCan      := MV_PAR01
   dDataInicial := MV_PAR02
   dDataFinal   := MV_PAR03
  Else                     
   dDataInicial := MV_PAR01
   dDataFinal   := MV_PAR02
  EndIf
 EndIf                           
 
 If cOpPerg =="G"
 	
 	MsgRun(STR0024,, {|| FS_MntAge(dDataInicial, dDataFinal)}) //"Aguarde, gerando horแrios..."

	ElseIf cOpPerg == "A"
		//Ajusta Horarios
		MsgRun(STR0047,, { || FS_AjustaH(dDataInicial, dDataFinal, aItensMar[1][1])})  //"Aguarde, atualizando horแrios..."
 	
 ElseIf cOpPerg =="I"
 	
 	If Len(aItensMar) == 1
 		FS_MntInd(dDataInicial, dDataFinal, cCodCan) //Indisponibiliza Horarios
 	ElseIf Len(aItensMar) > 1
 		HS_MsgInf(STR0025, STR0018, STR0034) //"Selecionar apenas uma disponibilidade."###"Aten็ใo"###"Rotina para gerar a agenda"
 	ElseIf Len(aItensMar) == 0
 		HS_MsgInf(STR0026, STR0018, STR0034) //"Nใo existe disponibilidade selecionada."###"Aten็ใo"###"Rotina para gerar a agenda"
 	EndIf
 	
 ElseIf cOpPerg =="E"
 	
 	MsgRun(STR0027,, {|| FS_ExcluiH(dDataInicial, dDataFinal, aItensMar[1][1])}) //"Aguarde, excluindo horแrios..."
 
 ElseIf cOpPerg =="T"
  If len (aItensMar)  = 1
	 	//Transferencia de setor dos horarios marcados 
	 	HS_TranSet("GMJ",dDataInicial, dDataFinal, aItensMar[1][1])
	 Elseif len (aItensMar)  > 1
 		HS_MsgInf(STR0025, STR0018, STR0034) //"Selecionar apenas uma disponibilidade."###"Aten็ใo"###"Rotina para gerar a agenda"
 	Elseif len (aItensMar)  = 0
 		HS_MsgInf(STR0026, STR0018, STR0034) //"Nใo existe disponibilidade selecionada."###"Aten็ใo"###"Rotina para gerar a agenda"
 	Endif 		
 EndIf
 
 Eval( oMeses:bChange )
 
Return(.T.)


Function HS_VldM25(cOpcao)

 Local lRet := .T.
 
 If cOpcao == "I"
  If ReadVar() == "MV_PAR01" // Codigo do cancelamento
   If Empty(MV_PAR01)
	 		HS_MsgInf(STR0023, STR0018, STR0034) //"Para esta opera็ใo ้ necessแrio escolher um motivo de cancelamento."###"Aten็ใo"###"Rotina para gerar a agenda"  
	 		lRet := .F.
	 	EndIf	
  ElseIf ReadVar() == "MV_PAR02" // Data Inicial
   If !Empty(MV_PAR02) .And. !Empty(MV_PAR03) .And. MV_PAR02 > MV_PAR03
	 		HS_MsgInf(STR0022, STR0018, STR0034) //"A data final nใo pode ser menor que a inicial."###"Aten็ใo"###"Rotina para gerar a agenda"
	 		lRet := .F.
	 	EndIf	
  ElseIf ReadVar() == "MV_PAR03" // Data Final
   If !Empty(MV_PAR02) .And. !Empty(MV_PAR03) .And. MV_PAR02 > MV_PAR03
	 		HS_MsgInf(STR0022, STR0018, STR0034) //"A data final nใo pode ser menor que a inicial."###"Aten็ใo"###"Rotina para gerar a agenda"
	 		lRet := .F.
	 	EndIf	
  EndIf
 Else
  If ReadVar() == "MV_PAR01" // Data Inicial
   If !Empty(MV_PAR01) .And. !Empty(MV_PAR02) .And. MV_PAR01 > MV_PAR02
	 		HS_MsgInf(STR0022, STR0018, STR0034) //"A data final nใo pode ser menor que a inicial."###"Aten็ใo"###"Rotina para gerar a agenda"
	 		lRet := .F.
	 	EndIf	
  ElseIf ReadVar() == "MV_PAR02" // Data Final
   If Empty(MV_PAR02)
    HS_MsgInf(STR0021, STR0018, STR0034) //"A data final nใo pode estar branco."###"Aten็ใo"###"Rotina para gerar a agenda"
	 		lRet := .F.
   ElseIf !Empty(MV_PAR01) .And. !Empty(MV_PAR02) .And. MV_PAR01 > MV_PAR02
	 		HS_MsgInf(STR0022, STR0018, STR0034) //"A data final nใo pode ser menor que a inicial."###"Aten็ใo"###"Rotina para gerar a agenda"
	 		lRet := .F.
	 	EndIf	
  EndIf
 EndIf
 
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FS_AjustaHบ Autor ณ Wiliam Silva       บ Data ณ 24/10/07    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Ajusta os horarios de agendamentos                         บฑฑ
ฑฑบ          ณ Ajusta apenas os horarios livres                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_AjustaH(dDataInicial, dDataFinal, cCodDis)

 Local lRet        := .T.
 Local nContFor    := 0
 Local aRegAge     := {}
 Local aHeGMJ      := {}
 Local aCoGMJ      := {}
 Local nUsGMJ      := 0
 Local dData       := ctod(" ")
 Local cLstCpo     := "GMJ_CODDIS/GMJ_DATAGE/GMJ_HORAGE/GMJ_STATUS/GMJ_CODAGE"
 Local nGMJ_DATAGE := 1
 Local nGMJ_HORAGE := 2
 Local nGMJ_FILAGE := 3
 Local nGMJ_STATUS := 4
 Local nGMJ_CODDIS := 5
 Local nGMJ_CODAGE := 6
 Local nGMJ_TIPAGE := 7
 Local cCond       := ""

 If Empty(cCodDis)
  HS_MsgInf(STR0044, STR0018, STR0034) //"Nใo existem dados para esta opera็ใo"###"Aten็ใo"###"Gera agenda m้dica." 
 	Return(.F.)
 EndIf

 aHeGMJ := {}
 aCoGMJ := {}
 nUsGMJ := 0
 	
	cCond :=  "'" + cCODDIS + "' == GMJ->GMJ_CODDIS .AND. GMJ->GMJ_DATAGE >= '" + DTOS(dDataInicial) + "' .AND. GMJ->GMJ_DATAGE <= '" + DTOS(dDataFinal) + "'"
 
 Set SoftSeek On
 HS_BDados("GMJ", @aHeGMJ, @aCoGMJ, @nUsGMJ, 5, cFilAnt + cCODDIS + DTOS(dDataInicial), cCond ,,, cLstCpo,,,,,, .T., .T.)
 Set SoftSeek Off
 
 nGMJ_DATAGE := aScan(aHeGMJ, {| aVet | aVet[2] == "GMJ_DATAGE"})
 nGMJ_HORAGE := aScan(aHeGMJ, {| aVet | aVet[2] == "GMJ_HORAGE"})
 nGMJ_STATUS := aScan(aHeGMJ, {| aVet | aVet[2] == "GMJ_STATUS"})
 nGMJ_CODDIS := aScan(aHeGMJ, {| aVet | aVet[2] == "GMJ_CODDIS"})
 nGMJ_CODAGE := aScan(aHeGMJ, {| aVet | aVet[2] == "GMJ_CODAGE"})
 
 DbSelectArea("GMJ")
 DbSetOrder(1) // GMJ_FILIAL + GMJ_CODAGE
 	
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Se ha horarios ja gerados, exclui os liberados e salva os ja agendados ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 For nContFor := 1 To Len(aCoGMJ)
 	If Dbseek(xFilial("GMJ") + aCoGMJ[nContFor][nGMJ_CODAGE])
 		If aCoGMJ[nContFor][nGMJ_STATUS] == "0" //0=Liberado
 			RecLock("GMJ", .F., .T.)
 			DBDelete()
 			MsUnlock()
 		Else
  		aAdd(aRegAge, {DToC(aCoGMJ[nContFor][nGMJ_DATAGE]), ;
  		                aCoGMJ[nContFor][nGMJ_HORAGE], ;
  		                aCoGMJ[nContFor][nGMJ_CODAGE], ;
  		                aCoGMJ[nContFor][nGMJ_STATUS]})
 		EndIf
 	EndIf		
	Next nContFor
                          
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Gera  horarios ja gerados, exclui os liberados e salva os ja agendados ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("GMD")
	DbSetOrder(1) // GMD_FILIAL + GMD_CODDIS
	Dbseek(xFilial("GMD") + aCoGMJ[1][nGMJ_CODDIS])
		
	For nContFor := 1 To Len(aCoGMJ)
			
		If dData <> aCoGMJ[nContFor][nGMJ_DATAGE]
			dData := aCoGMJ[nContFor][nGMJ_DATAGE]
			FS_GerAge( aCoGMJ[nContFor][nGMJ_CODDIS], aCoGMJ[nContFor][nGMJ_DATAGE], "AJU", aRegAge) //Gera agenda (GMJ)
		EndIf
		
	Next nContFor
	
	cCond := "GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ_FILAGE = '" + cFilAnt + "' AND GMJ_CODDIS = '" + GMD->GMD_CODDIS + "' AND " + ;
	         "GMJ_DATAGE BETWEEN '" + DTOS(oCalend:dDiaAtu) + "' AND '" + DToS(LastDay(oCalend:dDiaAtu)) + "'"
		
	FS_AtuGetD(5, cFilAnt + GMD->GMD_CODDIS + DTOS(oCalend:dDiaAtu), cCond)
 
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

Static Function FS_MntInd(dDataInicial, dDataFinal, cCODCAN)

 Local lRet    := .T.
 Local aHInd   := {}
 Local aCInd   := {}
 Local nUInd   := 0
 Local nGMJ_OK := 0
 Local oGMJInd
 Local oDlgInd
 Local aItensInd
 Local cFiltro := ""
 Local cMarca  := ""
 Local aSize		:= {}
 Local aInfo		:= {}
 Local aObjects	:= {}
 Local aPObjs	:= {} 
 
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
 
 If Empty(dDataFinal)
 	cMarca  := "IIf(GMJ->GMJ_STATUS == '2', 'LBTIK', 'LBNO')"
 Else
 	cFiltro := "AND GMJ_DATAGE <= '" + DToS(dDataFinal) + "'"
 	cMarca  := "'LBTIK'"
 EndIf
 
 cFiltro := "GMJ_CODDIS = '" + GMD->GMD_CODDIS + "' AND GMJ_DATAGE >= '" + DToS(dDataInicial) + "' " + cFiltro
 
 HS_BDados("GMJ", @aHInd, @aCInd, @nUInd, 3, "", cFiltro,,, "GMJ_CODDIS/GMJ_FILAGE/GMJ_DATAGE/GMJ_HORAGE/GMJ_TIPAGE/GMJ_CODAGE/GMJ_STATUS/GMJ_DESCAN", "GMJ->GMJ_STATUS == '1'",,, "GMJ_OK", cMarca, .T.)
 
 nGMJ_OK := aScan(aHInd, {| aVet | aVet[2] == "GMJ_OK    "})
 nMaxLin := Len(aCInd) 
 DEFINE MSDIALOG oDlgInd TITLE OemToAnsi(STR0028)  From aSize[ 7 ], 000 To aSize[ 6 ] , aSize[ 5 ]	Of oMainWnd pixel //"Indisponibiliza horแrio."
  oGMJInd := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], 1,,,,,,nMaxLin,,,, oDlgInd , aHInd, aCInd)
  oGMJInd:oBrowse:BlDblClick := {|| FS_DblClk(oGMJInd, nGMJ_OK)}
 ACTIVATE MSDIALOG oDlgInd CENTERED ON INIT EnchoiceBar(oDlgInd, {|| FS_GrvInd(oGMJInd, cCODCAN) .And. oDlgInd:End()}, {|| oDlgInd:End()})
 
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
Static Function FS_DblClk(oNewGetD, nCpoPosi)

 Local lRet := .T.

 If oNewGetD:aCols[oNewGetD:oBrowse:nAt, nCpoPosi] == "LBNO"
 	oNewGetD:aCols[oNewGetD:oBrowse:nAt, nCpoPosi] := "LBTIK"
 Else
 	oNewGetD:aCols[oNewGetD:oBrowse:nAt, nCpoPosi] := "LBNO"
 EndIf

 oNewGetD:oBrowse:Refresh()
 
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvInd บ Autor ณ PAULO JOSE         บ Data ณ  29/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ FUNCAO QUE MANIPULA O SX1.                                 บฑฑ
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
 Local nGMJ_DATAGE := aScan(oNewGetD:aHeader, {| aVet | aVet[2] == "GMJ_DATAGE"} )
 Local nGMJ_HORAGE := aScan(oNewGetD:aHeader, {| aVet | aVet[2] == "GMJ_HORAGE"} )
 Local nGMJ_FILAGE := aScan(oNewGetD:aHeader, {| aVet | aVet[2] == "GMJ_FILAGE"} )
 Local nGMJ_STATUS := aScan(oNewGetD:aHeader, {| aVet | aVet[2] == "GMJ_STATUS"} )
 Local nGMJ_CODDIS := aScan(oNewGetD:aHeader, {| aVet | aVet[2] == "GMJ_CODDIS"} )
 Local nGMJ_CODAGE := aScan(oNewGetD:aHeader, {| aVet | aVet[2] == "GMJ_CODAGE"} )
 Local nGMJ_TIPAGE := aScan(oNewGetD:aHeader, {| aVet | aVet[2] == "GMJ_TIPAGE"} )
 Local nGMJ_OK     := aScan(oNewGetD:aHeader, {| aVet | aVet[2] == "GMJ_OK    "} )
 Local nGMJ_DESCAN := aScan(oNewGetD:aHeader, {| aVet | aVet[2] == "GMJ_DESCAN"} )

 DbSelectArea("GMJ")
 DbSetOrder(1) //GMJ_FILIAL + GMJ_CODAGE
 
 //Posiciona o no Registro que esta na matriz
 For nContFor := 1 to len( oNewGetD:aCols )
	 If DbSeek(xFilial("GMJ") + oNewGetD:aCols[nContFor][nGMJ_CODAGE])
	 	Begin Transaction
	 	 RecLock("GMJ", .F.)
	 	  If oNewGetD:aCols[nContFor][nGMJ_OK] == "LBTIK"
	 	  	GMJ->GMJ_STATUS := "2"
	 	  	GMJ->GMJ_MOTIVO := cCODCAN
	 	  ElseIf oNewGetD:aCols[nContFor][nGMJ_OK] == "LBNO"
	 	  	GMJ->GMJ_STATUS := "0"
	 	  	GMJ->GMJ_MOTIVO := ""
	 	  EndIf
	 	 MsUnlock()
	 	End Transaction
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
ฑฑบDescricao ณ Exclui horarios da GMJ                                     บฑฑ
ฑฑบ          ณ Desde que nao exista nenhum horario agendado               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_ExcluiH(dDataInicial, dDataFinal, cCODDIS)

 Local aRecNoGMJ   := {}
 Local nContFor    := 0
 Local lOcupado    := .F.
 
 If Empty(cCODDIS)
 	HS_MsgInf(STR0030, STR0018, STR0034)  //"Nใo existe dados para essa opera็ใo."###"Aten็ใo"###"Rotina para gerar a agenda"
 	Return(.F.)
 EndIf	
 
	DbSelectArea("GMJ")
 DbSetOrder(3) //GMJ_FILIAL + GMJ_FILAGE + GMJ_CODDIS + GMJ_DATAGE
 DbSeek(xFilial("GMJ") + cFilAnt + cCodDis + DtoS(dDataInicial), .T.)  // SoftSeek ligado
 
 While !Eof() .And. GMJ->GMJ_FILIAL == xFilial("GMJ") .And. GMJ->GMJ_FILAGE == cFilAnt .And. ;
                     GMJ->GMJ_CODDIS == cCodDis .And. DTOS(GMJ->GMJ_DATAGE) <= DtoS(dDataFinal)
  If GMJ->GMJ_STATUS == "1"
   lOcupado := .T.
   Exit
  EndIf
  aAdd(aRecNoGMJ, RecNo())
  DbSkip()
 EndDo  
 		
 If lOcupado
		HS_MsgInf(STR0029, STR0018, STR0034) //"Nใo pode excluir, pois jแ existe horแrios agendados."###"Aten็ใo"###"Rotina para gerar a agenda"
		Return(.F.)
	EndIf	

	DbSelectArea("GMJ")
	Begin Transaction
	For nContFor := 1 To Len(aRecNOGMJ)
	 DbGoTo(aRecNoGMJ[nContFor])
	 RecLock("GMJ", .F., .T.)
 	 DbDelete()
		MsUnlock()
	Next
	End Transaction
	
	cCond :=  "GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ_FILAGE = '" + cFilAnt + "' AND GMJ_CODDIS = '" + cCodDis + "' AND GMJ_DATAGE >= '" + DToS(dDataInicial) + "' AND GMJ_DATAGE <= '" + DToS(dDataFinal) + "'"
 FS_AtuGetD(3, cFilAnt + cCodDis + DToS(dDataInicial), cCond)
 
Return(.T.)


Static Function FS_PriDia(dData)

Return(IIF(FirstDay(dData)==FirstDay(dDataBase), dDataBase, FirstDay(dData)))


Static Function FS_MaDeArr(aDias, cChave, dData)

 Local nDia := 0, nDiaIni := 0
 
 aSort(aDias)                 
 nDiaIni := aScan(aDias, {| dDia | FirstDay(dDia) == FirstDay(dData)})
 
 For nDia := nDiaIni To Len(aDias)
  If aDias[nDia] > LastDay(dData)
   Exit
  EndIf 
 
  If !Empty(aDias[nDia])
   If !(cChave == Nil) .And. FS_VldDis("GMJ", 3, cChave + DToS(aDias[nDia]))
 	  If HS_IsFreeDay(aDias[nDia])
 	 	 oCalend:addRestri(Day(aDias[nDia]), CLR_HGREEN, CLR_HGREEN)
 	 	Else                                              
 	 	 oCalend:addRestri(Day(aDias[nDia]), CLR_RED, CLR_RED)
 	 	EndIf 
 	 Else
 	  If HS_IsFreeDay(aDias[nDia])
 	 	 oCalend:addRestri(Day(aDias[nDia]), CLR_GREEN, CLR_GREEN)
 	 	Else 
 	 	 oCalend:addRestri(Day(aDias[nDia]), CLR_BLUE, CLR_BLUE)
 	 	EndIf 
		 EndIf
		EndIf 
 Next 
 
Return(Nil)   


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldHor บ Autor ณ Patricia Queiroz   บ Data ณ  28/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida se existe horarios gerados com o mesmo intervalo de บฑฑ
ฑฑบ          ณ data.                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 

Static Function FS_VldHor(dDataInicial, dDataFinal)    

Local cSQL     := ""         
Local cMsg     := "" 
Local lRet     := .T.
Local cSala    := GMD->GMD_QUARTO
Local cHorIni  := GMD->GMD_HORINI
Local cHorFim  := GMD->GMD_HORFIM  
Local aArea    := GetArea()
Local cDiasGer := ""
Local nCont    := 0

DbSelectArea("GMJ")
DbSetOrder(4) // GMJ_FILIAL + GMJ_FILAGE + GMJ_CODLOC + GMJ_QUARTO + GMJ_DATAGE + GMJ_HORAGE + GMJ_STATUS

For nCont := 1 To Len(aDiasGer)
 If aDiasGer[nCont] >= dDataInicial .AND. aDiasGer[nCont] <= dDataFinal
   cDiasGer += IIF(Empty(cDiasGer), "", "/") + DTOS(aDiasGer[nCont])
 EndIf
Next

cSQL := "SELECT GMJ.GMJ_CODDIS, GMJ.GMJ_QUARTO, GMJ.GMJ_DATAGE, GMJ.GMJ_HORAGE "
cSQL += " FROM " + RetSqlName("GMJ") + " GMJ "
cSQL += " WHERE GMJ.GMJ_FILIAL = '" + xFilial("GMJ")+ "' AND GMJ.D_E_L_E_T_ <> '*' "
cSQL += " AND GMJ.GMJ_FILAGE = '" + cFilAnt + "' "
cSQL += " AND GMJ.GMJ_QUARTO = '" + cSala + "' "
cSQL += " AND GMJ.GMJ_DATAGE IN (" + HS_InSql(cDiasGer) + ") "
cSQL += " AND GMJ.GMJ_HORAGE BETWEEN '" + cHorIni+ "' AND '" + cHorFim + "' "

cSQL := ChangeQuery(cSQL)
TCQUERY cSQL NEW ALIAS "QRY"

DbSelectArea("QRY")

If !Eof()
 cMsg := STR0037 + DTOC(STOD(QRY->GMJ_DATAGE)) + CHR(10)  //"Hแ conflito de horแrios para o dia: "
 cMsg += STR0043 + ALLTRIM(QRY->GMJ_QUARTO) + CHR(10)  //"Sala: "
 cMsg += STR0038 + ALLTRIM(QRY->GMJ_CODDIS) //"Disponibilidade: "
 HS_MsgInf(cMsg, STR0018, STR0039) //"Aten็ใo"###"Validar Horแrio Cir๚rgico"
 lRet := .F.
EndIf

DbCloseArea()
RestArea(aArea)

Return(lRet)