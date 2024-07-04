#Include "Protheus.Ch"
#Include "PLSA117.Ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA117   ºAutor  ³Diogo Ximenes       º Data ³ 10/02/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza o estorno do status de parcelamento do usuario.	  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA117()	
Private cPerg	:= "PLSA117"


If Pergunte(cPerg,.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chama a rotina para estorno d status...   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsAguarde({|| EstUsr() }, STR0001, "", .T.) //"Mudar Regra"
Else
	Return(.T.)
Endif

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EstUsr    ºAutor  ³Diogo Ximenes       º Data ³ 10/12/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Realiza a mudaca da regra do usuario.					  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function EstUsr()
Local cChaveBA1	:= "BA1->BA1_CODINT+BA1->BA1_CODEMP"
Local cChave 	:= MV_PAR01+MV_PAR02
Local nVal 		:= 0
Local nTotal	:= 0
Local lChaveBA1	:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico qual a composição das chaves...³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(MV_PAR03)
	cChaveBA1	+= "+BA1->BA1_CONEMP"
	cChave		+= MV_PAR03
Else
	lChaveBA1	:= .F.
EndIf

If !Empty(MV_PAR04)
	cChaveBA1	+= "+BA1->BA1_VERCON"
	cChave		+= MV_PAR04
Else
	lChaveBA1	:= .F.
EndIf

If !Empty(MV_PAR05) .And. lChaveBA1
	cChaveBA1	+= "+BA1->BA1_SUBCON"
	cChave		+= MV_PAR05
Else
	lChaveBA1	:= .F.
EndIf

If !Empty(MV_PAR06)
	cChaveBA1	+= "+BA1->BA1_VERSUB"
	cChave		+= MV_PAR06
Else
	lChaveBA1	:= .F.
EndIf

If !Empty(MV_PAR07) .And. lChaveBA1
	cChaveBA1	+= "+BA1->BA1_MATRIC"
	cChave		+= MV_PAR07
Else
	lChaveBA1	:= .F.
EndIf

If !Empty(MV_PAR08) .And. lChaveBA1
	cChaveBA1	+= "+BA1->BA1_TIPREG"
	cChave		+= MV_PAR08
Else
	lChaveBA1	:= .F.
EndIf

DBSelectArea("BA1")
BA1->(DbSetOrder(13)) //BA1_FILIAL, BA1_CODINT, BA1_CODEMP, BA1_CONEMP, BA1_VERCON, BA1_SUBCON, BA1_VERSUB, BA1_MATRIC, BA1_TIPREG
If BA1->(MsSeek(xFilial("BA1")+cChave))
	While !BA1->(Eof()) .And. &cChaveBA1 == cChave
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Somente verifico o usuario se ele estiver com o tipo de regra diferente do subcontrato...	  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If BA1->BA1_TREGRA != "0"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Limpo o contador de saldo...³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nVal := 0
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifico o saldo... ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DBSelectArea("BK2")
			BK2->(DbSetOrder(1))// BK2_FILIAL, BK2_CODINT, BK2_CODEMP, BK2_MATRIC, BK2_TIPREG, BK2_DIGITO, BK2_TIPLAN, BK2_CODLAN, BK2_ANO, BK2_MES
			If 	BK2->(MsSeek(xFilial("BK2")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)))
				While ! BK2->(Eof()) .And. BK2->(BK2_FILIAL+BK2_CODINT+BK2_CODEMP+BK2_MATRIC+BK2_TIPREG) ==;
				xFilial("BK2")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)

					If Empty(BK2->BK2_PLNUCO)
						nVal += BK2->BK2_SALDO
					EndIf
					BK2->(DbSkip())
				Enddo
			EndIf
			If nVal == 0
				BA1->(RecLock("BA1",.F.))
				BA1->BA1_TREGRA := "0"
				BA1->(MsUnLock())
				nTotal ++
			EndIf
		EndIf
		BA1->(DbSkip())
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe a mensagem para o usuario...³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTotal <= 0
	MsgAlert(STR0002) //"Nenhum Usuário foi Alterado!"
ElseIf nTotal == 1
	MsgAlert(STR0003) //"Foi Alterado um Usuário!"
ElseIf nTotal > 1
	MsgAlert(STR0004+AllTrim(str(nTotal))+STR0005 )//"Foram alterados " ###" Usuários!"
EndIf

Return(.T.)