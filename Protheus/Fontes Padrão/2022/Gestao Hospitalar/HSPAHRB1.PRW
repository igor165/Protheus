#INCLUDE "HSPAHRB1.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HSPAHRB1 ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 15.09.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Laudo                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPAHRB1(void)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HSP                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHRB1(aIteLau)

Local oPrint

Default aIteLau := {}


oPrint := TMSPrinter():New(STR0001) //"Laudo"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada - HSRB1ALT ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("HSRB1ALT")
	Execblock("HSRB1ALT", .F., .F., {aIteLau})
	Return(Nil)
EndIf

MsgRun(STR0002,"",{|| CursorWait(), MontaRel(oPrint, aIteLau), CursorArrow()}) //"Gerando Relatorio, Aguarde..."

oPrint:SetPortrait()

If MsgYesNo(STR0003) //"Visualizar antes ?"
	oPrint:Preview()
Else
	oPrint:Print()
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MontaRel ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 21.09.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Laudo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MotaRel(ExpO1)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HSPAHRB1                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MontaRel(oPrint, aIteLau)
Local lin
Local x,i,nLines
Local cFileLogo  := "LGRL" + IIF(FindFunction("FWGRPCompany"), FWGRPCompany(),SM0->M0_CODIGO) + Iif (FindFunction("FWCodFil"),FWGETCODFILIAL, SM0->M0_CODFIL) + ".BMP" // Empresa+Filial
Local nLinTotal
Local nCont
Local aDiaSem := {"Domingo", "Segunda-Feira", "Terça-Feira","Quarta-Feira","Quinta-Feira","Sexta-Feira", "Sábado"}
Local nPos    := 0, nPosLau := 0
Local aLaudo  := {}
Private oFont13
Private oFont14

For nPos := 1 to Len(aIteLau)
	nPosLau := Ascan(aIteLau, {|aVet| aVet[2] == aIteLau[nPos, 2]})
	If nPosLau <> nPos .Or. Empty(aIteLau[nPos, 2])
		Loop
	Endif
	
	If nPos > 1
		oPrint:EndPage()
		oPrint:StartPage()
	Endif
	
	oFont13				:= TFont():New("Courier New",12,12,,.F.,,,,.T.,.F.)
	oFont14				:= TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)
	
	If !File(cFileLogo)
		cFileLogo := "LGRL" + IIF(FindFunction("FWGRPCompany"), FWGRPCompany(),SM0->M0_CODIGO) +".BMP" // Empresa
	Endif
	
	oPrint:SayBitmap(05,0005, cFileLogo,328,82)             // Tem que estar abaixo do RootPath
	
	oPrint:Say(200, 200, STR0004, oFont13) //"Pedido :"
	oPrint:Say(250, 200, STR0005, oFont13) //"Paciente :"
	oPrint:Say(300, 200, STR0006, oFont13) //"Data :"
	oPrint:Say(350, 200, STR0007, oFont13) //"Convenio :"
	oPrint:Say(400, 200, STR0008, oFont13) //"Medico Solicitante :"
	
	GBY->(DbSetOrder(1))
	GBY->(DbSeek(xFilial("GBY") + aIteLau[nPos, 1]))
	
	SRA->(DbSetOrder(11))
	SRA->(DbSeek(xFilial("SRA") + GBY->GBY_CODCRM))
	
	GCY->(DbSetOrder(1))
	GCY->(DbSeek(xFilial("GCY") + GBY->GBY_REGATE))
	
	GCZ->(DbSetOrder(2))
	GCZ->(DbSeek(xFilial("GCZ") + GBY->GBY_REGATE))
	
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1") + GCY->GCY_REGGER))
	
	GD4->(dbSetOrder(2))
	GD4->(dbSeek(xFilial("GD4") + GCY->GCY_REGGER))
	
	GCM->(DbSetOrder(2))
	GCM->(DbSeek(xFilial("GCM") + GCZ->GCZ_CODPLA))
	
	GA9->(DbSetOrder(1))
	GA9->(DbSeek(xFilial("GA9") + GCM->GCM_CODCON))
	
	aLaudo := HS_BusResp("GCP", {{"GCP->GCP_SOLICI", aIteLau[nPos, 2]}}, "GCP")  // Funcao q monta um array com os dados do Laudo
	
	
	oPrint:Say(200, 710, GBY->GBY_SOLICI, oFont13)
	oPrint:Say(250, 710, GCY->GCY_REGATE + '-' + AllTrim(GCY->GCY_NOME) + " - Sexo: " + HS_RDescrB("GCY_SEXO  " , GCY->GCY_SEXO) + " - Idade:" + GCY->GCY_IDADE, oFont13)
	oPrint:Say(300, 710, DtoC(GBY->GBY_DATSOL), oFont13)
	oPrint:Say(350, 710, GCM->GCM_CODCON + '-' + AllTrim(GA9->GA9_NREDUZ) + '-' + PadR(AllTrim(HS_DesPla(GCM->GCM_CODCON, GCZ->GCZ_CODPLA)), 9), oFont13)
	oPrint:Say(400, 710, AllTrim(GBY->GBY_CODCRM) + '-' + SRA->RA_NOME, oFont13)
	oPrint:Line( 500, 200, 500, 2500 )   	// horizontal
	
	lin := 600
	
	For x := 1 To Len(aLaudo)
		
		oPrint:Say(lin,200,aLaudo[x][3]+":",oFont14)  // Descricao da pergunta
		lin += 60
		
		If ValType(aLaudo[x][2]) == "N"
			aLaudo[x][2] := AllTrim(STR(aLaudo[x][2]))
		ElseIf ValType(aLaudo[x][2]) == "D"
			aLaudo[x][2] := DTOC(aLaudo[x][2])
		ElseIf ValType(aLaudo[x][2]) == "C"
			aLaudo[x][2] := AllTrim(aLaudo[x][2])
			
		EndIf
		
		nLines := MLCOUNT(aLaudo[x][2], 83)
		For i := 1 To nLines
			oPrint:Say(lin,200,(MEMOLINE(aLaudo[x][2], 83, i)),oFont13)
			lin += 80
			If lin > 2280
				oPrint:EndPage()
				oPrint:StartPage()
				lin := 600
			Endif
		Next
		
		lin += 80
		
		If lin > 2280
			oPrint:EndPage()
			oPrint:StartPage()
			lin := 600
		Endif
		
	Next x
	
	If Lin > 2100
		oPrint:EndPage()
		oPrint:StartPage()
	Endif
	
	lin := 2100
	oPrint:Say(lin,200,AllTrim(SM0->M0_CIDENT) + ", " + aDiaSem[Dow(dDataBase)] + " " + AllTrim(Str(Day(dDataBase))) + " de "+ MesExtenso(dDataBase) + " de " + Alltrim(Str(Year(dDataBase))) ,oFont13)
	lin += 100
	oPrint:Say(lin,200,"___________________________________" ,oFont13)
	lin += 80
	
Next nPos

Return Nil
