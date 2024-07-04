// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 05     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Protheus.ch"
#include "VEICM690.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEICM690 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 04/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Geracao de Agenda por Calendario/Periodicidade/Classificac ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICM690()
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nOpcRadio := 1  // Opcao Radio: 1=Calendário    /    2=Periodicidade do Cliente    /    3=Classificação do Cliente
Local aEmiteFic := X3CBOXAVET("VC1_EMIFIC","0")
Local aTipVBO   := {"1="+STR0016,"3="+STR0015,"4="+STR0014} // Servicos / Pecas / Veiculos
Local aClassi   := X3CBOXAVET("VCF_CLAVEI","0")
Local aOperad   := {"1=(<=)","2=(=)","3=(>=)","4=(<>)"}
Private cEmiteFic := "0"
Private cTpAgenda := space(TamSX3("VC1_TIPAGE")[1])
Private cObjetiv  := ""
Private cVendedor := space(TamSX3("A3_COD")[1])
Private cCodCli   := space(TamSX3("A1_COD")[1])
Private cLojCli   := space(TamSX3("A1_LOJA")[1])
Private cCdPros   := space(TamSX3("US_COD")[1])
Private cLjPros   := space(TamSX3("US_LOJA")[1])
Private cTipVBO   := "4"
Private cClassi   := "A"
Private cOper1    := "2"
Private cOper2    := "2"
Private nQtdDia   := 0
Private dDtPIni   := dDataBase
Private dDtPFin   := ctod("01/"+IIf(month(dDataBase)<12,strzero(month(dDataBase)+1,2)+"/"+substr(strzero(year(dDataBase),4),3,2),"01/"+substr(strzero(year(dDataBase)+1,4),3,2)))-1
Private aAgendas  := {{ctod(""),"","","","","",""}}
Private nOrdList  := 1
//
If VCF->(FieldPos("VCF_VENVEU")) > 0 // Possui campos novos
	aTipVBO := {"1="+STR0016,"3="+STR0015,"4="+STR0031,"5="+STR0032,"6="+STR0033,"7="+STR0034} // Servicos / Pecas / Veic.Novos / Veic.Usados / Pneus / Outros
EndIf
//
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 70 , .T. , .F. } ) // Geracao de Agendas
aAdd( aObjects, { 0 , 00 , .T. , .T. } ) // ListBox
aPos := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oVCM690 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001) OF oMainWnd PIXEL // Geracao de Agendas

	@ aPos[1,1]+008,aPos[1,2]+007 SAY (STR0002+":") SIZE 25,08 OF oVCM690 PIXEL COLOR CLR_BLUE // Agenda:
	@ aPos[1,1]+007,aPos[1,2]+032 MSGET oTpAgenda VAR cTpAgenda PICTURE "!" F3 "VC5" VALID FS_VALVCM690("TP") SIZE 25,08 OF oVCM690 PIXEL COLOR CLR_BLUE

	@ aPos[1,1]+008,aPos[1,2]+092 SAY (STR0003+":") SIZE 35,08 OF oVCM690 PIXEL COLOR CLR_BLUE // Emite Ficha:
	@ aPos[1,1]+007,aPos[1,2]+125 MSCOMBOBOX oEmiteFic VAR cEmiteFic ITEMS aEmiteFic SIZE 30,08 OF oVCM690 PIXEL COLOR CLR_BLUE

	@ aPos[1,1]+022,aPos[1,2]+007 SAY (STR0004+":") SIZE 27,08 OF oVCM690 PIXEL COLOR CLR_BLUE // Objetivo:
	@ aPos[1,1]+031,aPos[1,2]+007 GET oObjetiv VAR cObjetiv OF oVCM690 MEMO SIZE 147,32 PIXEL

	@ aPos[1,1]+008,aPos[1,2]+170 SAY (STR0005+":") SIZE 27,08 OF oVCM690 PIXEL COLOR CLR_BLUE // Tipo:
	@ aPos[1,1]+019,aPos[1,2]+175 RADIO oRadio VAR nOpcRadio 3D SIZE 075,10 PROMPT STR0011,STR0012,STR0013 OF oVCM690 PIXEL ON CHANGE FS_RADIO(nOpcRadio)

	@ aPos[1,1]+010,aPos[1,2]+270 SAY (STR0006+":") SIZE 27,08 OF oVCM690 PIXEL COLOR CLR_BLUE // Vendedor:
	@ aPos[1,1]+009,aPos[1,2]+305 MSGET oVendedor VAR cVendedor PICTURE "@!" F3 "SA3" VALID FS_VALVCM690("EV") SIZE 40,08 OF oVCM690 PIXEL COLOR CLR_BLUE

	@ aPos[1,1]+024,aPos[1,2]+270 SAY oTit1 VAR (STR0007+":") SIZE 27,08 OF oVCM690 PIXEL COLOR CLR_BLUE // Cliente:
	@ aPos[1,1]+023,aPos[1,2]+300 MSGET oCodCli VAR cCodCli PICTURE "@!" F3 "SA1" VALID FS_VALVCM690("CL") SIZE 42,08 OF oVCM690 PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+023,aPos[1,2]+345 MSGET oLojCli VAR cLojCli PICTURE "@!" VALID FS_VALVCM690("CL") SIZE 25,08 OF oVCM690 PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+038,aPos[1,2]+270 SAY oTit7 VAR (STR0028+":") SIZE 27,08 OF oVCM690 PIXEL COLOR CLR_BLUE // Prospect:
	@ aPos[1,1]+037,aPos[1,2]+300 MSGET oCdPros VAR cCdPros PICTURE "@!" F3 "SUS" VALID FS_VALVCM690("PR") SIZE 42,08 OF oVCM690 PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+037,aPos[1,2]+345 MSGET oLjPros VAR cLjPros PICTURE "@!" VALID FS_VALVCM690("PR") SIZE 25,08 OF oVCM690 PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+052,aPos[1,2]+270 BUTTON oBotao1 PROMPT (STR0010) OF oVCM690 SIZE 100,10 PIXEL ACTION FS_CALENDAR(1) WHEN ( !Empty(cVendedor) .and. ( ( !Empty(cCodCli) .and. !Empty(cLojCli) ) .or. ( !Empty(cCdPros) .and. !Empty(cLjPros) ) ) ) // Selecionar Datas

	@ aPos[1,1]+024,aPos[1,2]+270 SAY oTit2 VAR (STR0008+":") SIZE 60,8 OF oVCM690 PIXEL COLOR CLR_BLUE // Periodicidade:
	@ aPos[1,1]+023,aPos[1,2]+305 MSCOMBOBOX oTipVBO VAR cTipVBO SIZE 48,08 ITEMS aTipVBO OF oVCM690 PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+023,aPos[1,2]+353 MSCOMBOBOX oOper1 VAR cOper1 SIZE 25,08 ITEMS aOperad OF oVCM690 PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+023,aPos[1,2]+378 MSGET oQtdDia VAR nQtdDia PICTURE "@E 999" VALID nQtdDia >= 0 SIZE 20,08 OF oVCM690 PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+016,aPos[1,2]+382 SAY oTit3 VAR STR0017 SIZE 20,8 OF oVCM690 PIXEL COLOR CLR_BLUE // Dias
	
	@ aPos[1,1]+038,aPos[1,2]+270 SAY oTit4 VAR STR0018 SIZE 60,8 OF oVCM690 PIXEL COLOR CLR_BLUE // Gerar: de
	@ aPos[1,1]+037,aPos[1,2]+300 MSGET oDtPIni VAR dDtPIni PICTURE "@D" VALID dDtPIni >= dDataBase SIZE 44,08 OF oVCM690 PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+038,aPos[1,2]+347 SAY oTit5 VAR STR0019 SIZE 15,8 OF oVCM690 PIXEL COLOR CLR_BLUE // a
	@ aPos[1,1]+037,aPos[1,2]+354 MSGET oDtPFin VAR dDtPFin PICTURE "@D" VALID dDtPFin >= dDtPIni SIZE 44,08 OF oVCM690 PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+052,aPos[1,2]+270 BUTTON oBotao2 PROMPT (STR0020) OF oVCM690 SIZE 128,10 PIXEL ACTION FS_PERIODIC() WHEN ( !Empty(cVendedor) ) // Levantar Clientes

	@ aPos[1,1]+024,aPos[1,2]+270 SAY oTit6 VAR (STR0009+":") SIZE 60,8 OF oVCM690 PIXEL COLOR CLR_BLUE // Classificacao:
	@ aPos[1,1]+037,aPos[1,2]+305 MSCOMBOBOX oOper2 VAR cOper2 SIZE 25,08 ITEMS aOperad OF oVCM690 PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+037,aPos[1,2]+330 MSCOMBOBOX oClassi VAR cClassi SIZE 30,08 ITEMS aClassi OF oVCM690 PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+052,aPos[1,2]+270 BUTTON oBotao3 PROMPT (STR0010) OF oVCM690 SIZE 100,10 PIXEL ACTION FS_CALENDAR(3) WHEN !Empty(cVendedor) // Selecionar Datas

	@ aPos[1,1]+000,aPos[1,2] TO aPos[1,3],aPos[1,4] LABEL "" OF oVCM690 PIXEL

	@ aPos[2,1],aPos[2,2] LISTBOX oLbAgendas FIELDS HEADER STR0021,STR0006,STR0005,STR0029 COLSIZES 30,135,40,(aPos[2,4]-210) SIZE aPos[2,4]-2,aPos[2,3]-aPos[2,1] OF oVCM690 PIXEL ON DBLCLICK FS_CALENDAR(2)
	oLbAgendas:SetArray(aAgendas)
	oLbAgendas:bLine := { || { Transform(aAgendas[oLbAgendas:nAt,1],"@D") , aAgendas[oLbAgendas:nAt,2]+" "+aAgendas[oLbAgendas:nAt,3] , aAgendas[oLbAgendas:nAt,7] , aAgendas[oLbAgendas:nAt,4]+"-"+aAgendas[oLbAgendas:nAt,5]+" "+aAgendas[oLbAgendas:nAt,6] }}
	oLbAgendas:bHeaderClick := {|oObj,nCol| ( nOrdList := nCol , FS_REFRESH() ) }

	@ aPos[1,1]+052,aPos[1,2]+175 BUTTON oBotao0 PROMPT (STR0022) OF oVCM690 SIZE 69,10 PIXEL ACTION FS_LIMPAR() // Limpar Agendas

	FS_RADIO(1)

ACTIVATE MSDIALOG oVCM690 ON INIT EnchoiceBar(oVCM690,{ || IIf(FS_AGEND_GERA(),oVCM690:End(),.t.) }, { || oVCM690:End() },,)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_RADIO    ³ Autor ³ Andre Luis Almeida ³ Data ³ 04/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Radio 1=Calendario / 2=Periodicid / 3=Classificacao        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_RADIO(nOpcRadio)
oTit1:lVisible := .f.
oTit2:lVisible := .f.
oTit3:lVisible := .f.
oTit4:lVisible := .f.
oTit5:lVisible := .f.
oTit6:lVisible := .f.
oTit7:lVisible := .f.
oCodCli:lVisible := .f.
oLojCli:lVisible := .f.
oCdPros:lVisible := .f.
oLjPros:lVisible := .f.
oBotao1:lVisible := .f.
oTipVBO:lVisible := .f.
oClassi:lVisible := .f.
oOper2:lVisible := .f.
oQtdDia:lVisible := .f.
oOper1:lVisible := .f.
oDtPIni:lVisible := .f.
oDtPFin:lVisible := .f.
oBotao2:lVisible := .f.
oBotao3:lVisible := .f.
If nOpcRadio == 1 // Calendário
	oTit1:lVisible := .t.
	oTit7:lVisible := .t.
	oCodCli:lVisible := .t.
	oLojCli:lVisible := .t.
	oBotao1:lVisible := .t.
	oCdPros:lVisible := .t.
	oLjPros:lVisible := .t.
ElseIf nOpcRadio == 2 // Periodicidade do Cliente
	oTit2:lVisible := .t.
	oTit3:lVisible := .t.
	oTit4:lVisible := .t.
	oTit5:lVisible := .t.
	oTipVBO:lVisible := .t.
	oQtdDia:lVisible := .t.
	oOper1:lVisible := .t.
	oDtPIni:lVisible := .t.
	oDtPFin:lVisible := .t.
	oBotao2:lVisible := .t.
ElseIf nOpcRadio == 3 // Classificacao do Cliente
	oTit6:lVisible := .t.
	oTipVBO:lVisible := .t.
	oClassi:lVisible := .t.
	oOper2:lVisible := .t.
	oBotao3:lVisible := .t.
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_CALENDAR ³ Autor ³ Andre Luis Almeida ³ Data ³ 04/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do Calendario ( FGX_CALEND )                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CALENDAR(nTp)
Local cQuery    := ""
Local cSQLAlias := "SQLALIAS"
Local aDatas    := {}
Local aDtSel    := {}
Local aAux      := {}
Local ni        := 0
Local cNomVen   := ""
Local cNomCli   := ""
Local cOp       := "="
//
If nTp == 1 // Botao "Selecionar Datas" - quando tipo = "Calendario"
	//
	If Empty(aAgendas[1,2])
		aAgendas := {}
	EndIf
	For ni := 1 to len(aAgendas)
		If cVendedor == aAgendas[ni,2] .and. ( ( !Empty(cCodCli+cLojCli) .and. aAgendas[ni,7]==STR0007 .and. cCodCli+cLojCli == aAgendas[ni,4]+aAgendas[ni,5] ) .or. ( !Empty(cCdPros+cLjPros) .and. aAgendas[ni,7]==STR0028 .and. cCdPros+cLjPros == aAgendas[ni,4]+aAgendas[ni,5] ) )
			aAdd(aDtSel,aAgendas[ni,1])
		Else
			aAdd(aAux,{aAgendas[ni,1],aAgendas[ni,2],aAgendas[ni,3],aAgendas[ni,4],aAgendas[ni,5],aAgendas[ni,6],aAgendas[ni,7]})
		EndIf
	Next
	cNomVen := FM_SQL("SELECT A3_NOME FROM "+RetSqlName("SA3")+" WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_COD='"+cVendedor+"' AND D_E_L_E_T_=' '")
	aDatas := FGX_CALEND(,,aDtSel)
	If !Empty(cCodCli) // Cliente
		cNomCli := FM_SQL("SELECT A1_NOME FROM "+RetSqlName("SA1")+" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+cCodCli+"' AND A1_LOJA='"+cLojCli+"' AND D_E_L_E_T_=' '")
		For ni := 1 to len(aDatas)
			aAdd(aAux,{aDatas[ni],cVendedor,cNomVen,cCodCli,cLojCli,cNomCli,STR0007}) // Cliente
		Next
	Else // Prospect
		cNomCli := FM_SQL("SELECT US_NOME FROM "+RetSqlName("SUS")+" WHERE US_FILIAL='"+xFilial("SUS")+"' AND US_COD='"+cCdPros+"' AND US_LOJA='"+cLjPros+"' AND D_E_L_E_T_=' '")
		For ni := 1 to len(aDatas)
			aAdd(aAux,{aDatas[ni],cVendedor,cNomVen,cCdPros,cLjPros,cNomCli,STR0028}) // Prospect
		Next
	EndIf
	//
ElseIf nTp == 2 // DuploClique no ListBox
	//
	If Empty(aAgendas[1,2])
		Return()
	EndIf
	For ni := 1 to len(aAgendas)
		If aAgendas[oLbAgendas:nAt,2] == aAgendas[ni,2] .and. ( aAgendas[oLbAgendas:nAt,4]+aAgendas[oLbAgendas:nAt,5] == aAgendas[ni,4]+aAgendas[ni,5] )
			aAdd(aDtSel,aAgendas[ni,1])
		Else
			aAdd(aAux,{aAgendas[ni,1],aAgendas[ni,2],aAgendas[ni,3],aAgendas[ni,4],aAgendas[ni,5],aAgendas[ni,6],aAgendas[ni,7]})
		EndIf
	Next
	aDatas := FGX_CALEND(,,aDtSel)
	For ni := 1 to len(aDatas)
		aAdd(aAux,{aDatas[ni],aAgendas[oLbAgendas:nAt,2],aAgendas[oLbAgendas:nAt,3],aAgendas[oLbAgendas:nAt,4],aAgendas[oLbAgendas:nAt,5],aAgendas[oLbAgendas:nAt,6],STR0007}) // Cliente
	Next
	//
ElseIf nTp == 3 // Botao "Selecionar Datas" - quando tipo = "Classificacao do cliente"
	//
	If cOper2 == "1"
		cOp := "<="
	ElseIf cOper2 == "2"
		cOp := "="
	ElseIf cOper2 == "3"
		cOp := ">="
	ElseIf cOper2 == "4"
		cOp := "<>"
	EndIf
	//
	If Empty(aAgendas[1,2])
		aAgendas := {}
	EndIf
	For ni := 1 to len(aAgendas)
		aAdd(aAux,{aAgendas[ni,1],aAgendas[ni,2],aAgendas[ni,3],aAgendas[ni,4],aAgendas[ni,5],aAgendas[ni,6],aAgendas[ni,7]})
	Next
	cNomVen := FM_SQL("SELECT A3_NOME FROM "+RetSqlName("SA3")+" WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_COD='"+cVendedor+"' AND D_E_L_E_T_=' '")
	aDatas := FGX_CALEND(,,aDtSel)
	cQuery := "SELECT VCF.VCF_CODCLI , VCF.VCF_LOJCLI , SA1.A1_NOME "
	cQuery += "FROM "+RetSQLName("VCF")+" VCF "
	cQuery += "JOIN "+RetSQLName("SA1")+" SA1 ON ( SA1.A1_FILIAL='" + xFilial("SA1") + "' AND SA1.A1_COD=VCF.VCF_CODCLI AND SA1.A1_LOJA=VCF.VCF_LOJCLI AND SA1.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VCF.VCF_FILIAL='" + xFilial("VCF") + "' AND "
	Do Case
		Case cTipVBO == "1" // Servicos
			cQuery += "VCF.VCF_CLASRV"+cOp+"'" + cClassi + "' AND VCF.VCF_CLASRV<>' ' AND "
		Case cTipVBO == "3" // Pecas
			cQuery += "VCF.VCF_CLAPEC"+cOp+"'" + cClassi + "' AND VCF.VCF_CLAPEC<>' ' AND "
		Case cTipVBO == "4" // Veic.Novos
			cQuery += "VCF.VCF_CLAVEI"+cOp+"'" + cClassi + "' AND VCF.VCF_CLAVEI<>' ' AND "
		Case cTipVBO == "5" // Veic.Usados
			cQuery += "VCF.VCF_CLAVEU"+cOp+"'" + cClassi + "' AND VCF.VCF_CLAVEU<>' ' AND "
		Case cTipVBO == "6" // Pneus
			cQuery += "VCF.VCF_CLAPNE"+cOp+"'" + cClassi + "' AND VCF.VCF_CLAPNE<>' ' AND "
		Case cTipVBO == "7" // Outros
			cQuery += "VCF.VCF_CLAOUT"+cOp+"'" + cClassi + "' AND VCF.VCF_CLAOUT<>' ' AND "
	EndCase
	cQuery += "VCF.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
	While !(cSQLAlias)->(Eof())
		For ni := 1 to len(aDatas)
			aAdd(aAux,{aDatas[ni],cVendedor,cNomVen,(cSQLAlias)->( VCF_CODCLI ),(cSQLAlias)->( VCF_LOJCLI ),(cSQLAlias)->( A1_NOME ),STR0007}) // Cliente
		Next
		(cSQLAlias)->(dbSkip())
	EndDo
	(cSQLAlias)->(dbCloseArea())
	//
EndIf
aAgendas := aClone(aAux)
FS_REFRESH()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_PERIODIC ³ Autor ³ Andre Luis Almeida ³ Data ³ 10/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Levantar os clientes pela periodicidade e calcular as datas³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PERIODIC()
Local cQuery    := ""
Local cSQLAlias := "SQLALIAS"
Local cNomVen   := FM_SQL("SELECT A3_NOME FROM "+RetSqlName("SA3")+" WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_COD='"+cVendedor+"' AND D_E_L_E_T_=' '")
Local aAux      := {}
Local nAux      := 0
Local ni        := 0
Local cOp       := "="
//
If cOper1 == "1"
	cOp := "<="
ElseIf cOper1 == "2"
	cOp := "="
ElseIf cOper1 == "3"
	cOp := ">="
ElseIf cOper1 == "4"
	cOp := "<>"
EndIf
//
If Empty(aAgendas[1,2])
	aAgendas := {}
EndIf
//
aAdd(aAux,dDtPIni)
If nQtdDia > 0
	nAux := int( ( ( dDtPFin - dDtPIni ) + 1 ) / nQtdDia )
	For ni := 1 to nAux
		aAdd(aAux,( dDtPIni + ( ni * nQtdDia ) )) // Datas pela periodicidade
	Next
EndIf
//
cQuery := "SELECT VCF.VCF_CODCLI , VCF.VCF_LOJCLI , SA1.A1_NOME "
cQuery += "FROM "+RetSQLName("VCF")+" VCF "
cQuery += "JOIN "+RetSQLName("SA1")+" SA1 ON ( SA1.A1_FILIAL='" + xFilial("SA1") + "' AND SA1.A1_COD=VCF.VCF_CODCLI AND SA1.A1_LOJA=VCF.VCF_LOJCLI AND SA1.D_E_L_E_T_=' ' ) "
cQuery += "WHERE VCF.VCF_FILIAL='" + xFilial("VCF") + "' AND "
Do Case
	Case cTipVBO == "1" // Servicos
		cQuery += "VCF.VCF_DIAPES"+cOp+ Alltrim(str(nQtdDia)) + " AND VCF.VCF_DIAPES<>0 AND "
	Case cTipVBO == "3" // Pecas
		cQuery += "VCF.VCF_DIAPEP"+cOp+ Alltrim(str(nQtdDia)) + " AND VCF.VCF_DIAPEP<>0 AND "
	Case cTipVBO == "4" // Veic.Novos
		cQuery += "VCF.VCF_DIAPER"+cOp+ Alltrim(str(nQtdDia)) + " AND VCF.VCF_DIAPER<>0 AND "
	Case cTipVBO == "5" // Veic.Usados
		cQuery += "VCF.VCF_DIAVEU"+cOp+ Alltrim(str(nQtdDia)) + " AND VCF.VCF_DIAVEU<>0 AND "
	Case cTipVBO == "6" // Pneus
		cQuery += "VCF.VCF_DIAPNE"+cOp+ Alltrim(str(nQtdDia)) + " AND VCF.VCF_DIAPNE<>0 AND "
	Case cTipVBO == "7" // Outros
		cQuery += "VCF.VCF_DIAOUT"+cOp+ Alltrim(str(nQtdDia)) + " AND VCF.VCF_DIAOUT<>0 AND "
EndCase
cQuery += "VCF.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
While !(cSQLAlias)->(Eof())
	For ni := 1 to len(aAux)
		aAdd(aAgendas,{aAux[ni],cVendedor,cNomVen,(cSQLAlias)->( VCF_CODCLI ),(cSQLAlias)->( VCF_LOJCLI ),(cSQLAlias)->( A1_NOME ),STR0007})
	Next
	(cSQLAlias)->(dbSkip())
EndDo
(cSQLAlias)->(dbCloseArea())
FS_REFRESH()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_LIMPAR   ³ Autor ³ Andre Luis Almeida ³ Data ³ 10/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Limpar vetor das agendas / datas                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LIMPAR()
aAgendas := {}
FS_REFRESH()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_REFRESH  ³ Autor ³ Andre Luis Almeida ³ Data ³ 10/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Refresh no listbox das agendas / datas                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_REFRESH()
If len(aAgendas) <= 0
	aAdd(aAgendas,{ctod(""),"","","","","",""})
EndIf
If nOrdList == 1 // Data
	aSort(aAgendas,1,,{|x,y| dtos(x[1])+x[2]+x[7]+x[4]+x[5] < dtos(y[1])+y[2]+y[7]+y[4]+y[5] })
ElseIf nOrdList == 2 // Vendedor
	aSort(aAgendas,1,,{|x,y| x[2]+dtos(x[1])+x[7]+x[4]+x[5] < y[2]+dtos(y[1])+y[7]+y[4]+y[5] })
Else // Cliente/Propspect
	aSort(aAgendas,1,,{|x,y| x[7]+x[4]+x[5]+dtos(x[1])+x[2] < y[7]+y[4]+y[5]+dtos(y[1])+y[2] })
EndIf
oLbAgendas:nAt := 1
oLbAgendas:SetArray(aAgendas)
oLbAgendas:bLine := { || { Transform(aAgendas[oLbAgendas:nAt,1],"@D") , aAgendas[oLbAgendas:nAt,2]+" "+aAgendas[oLbAgendas:nAt,3] , aAgendas[oLbAgendas:nAt,7] , aAgendas[oLbAgendas:nAt,4]+"-"+aAgendas[oLbAgendas:nAt,5]+" "+aAgendas[oLbAgendas:nAt,6] }}
oLbAgendas:Refresh()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VALVCM690³ Autor ³ Andre Luis Almeida ³ Data ³ 07/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes ( Tipo de Agenda / Vendedor / Cliente )         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALVCM690(cTipo)
Local lRet := .f.
Do Case
	Case cTipo == "TP"	// Verifica Tipo de Agenda
		DbSelectArea("VC5")
		DbSetOrder(1)
		If DbSeek( xFilial("VC5") + Alltrim(cTpAgenda) )
			lRet := .t.
		EndIf
	Case cTipo == "EV"	// Verifica Vendedor
		VAI->(DbSetOrder(4))
		VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
		DbSelectArea("SA3")
		DbSetOrder(1)
		If DbSeek( xFilial("SA3") + Alltrim(cVendedor) )
			lRet := .t.
			If VAI->VAI_CEVAGE == "2"
				If VAI->VAI_CODVEN <> cVendedor
					lRet := .f.
				EndIf
			EndIf
		EndIf
	Case cTipo == "CL"	// Clientes
		If !Empty(cCodCli)
			DbSelectArea("SA1")
			DbSetOrder(1)
			If DbSeek( xFilial("SA1") + cCodCli + Alltrim(cLojCli) )
				lRet    := .t.
				cLojCli := SA1->A1_LOJA
				cCdPros := space(TamSX3("US_COD")[1])
				cLjPros := space(TamSX3("US_LOJA")[1])
			EndIf
		Else
			lRet    := .t.
			cLojCli := space(TamSX3("A1_LOJA")[1])
		EndIf
	Case cTipo == "PR"	// Prospect
		If !Empty(cCdPros)
			DbSelectArea("SUS")
			DbSetOrder(1)
			If DbSeek( xFilial("SUS") + cCdPros + Alltrim(cLjPros) )
				lRet    := .t.
				cLjPros := SUS->US_LOJA
				cCodCli := space(TamSX3("A1_COD")[1])
				cLojCli := space(TamSX3("A1_LOJA")[1])
				If !Empty(SUS->US_CODCLI+SUS->US_LOJACLI)
					MsgAlert(STR0030,STR0023) // Este Prospect já é um Cliente padrão! / Atencao
					cCodCli := SUS->US_CODCLI
					cLojCli := SUS->US_LOJACLI
					cCdPros := space(TamSX3("US_COD")[1])
					cLjPros := space(TamSX3("US_LOJA")[1])
				EndIf				
			EndIf
		Else
			lRet    := .t.
			cLjPros := space(TamSX3("US_LOJA")[1])
		EndIf
EndCase
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_AGEND_GERA³ Autor ³ Andre Luis Almeida ³ Data ³ 10/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Geracao de Agenda CEV                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_AGEND_GERA()
Local ni   := 0
Local lRet := .f.
If !Empty(aAgendas[1,2])
	If !Empty(cTpAgenda)
		lRet := .t.
		For ni := 1 to Len(aAgendas)
			// Validacao do reg.da visita para Vendedor/Tp.Agenda/Cliente //
			If aAgendas[ni,7] == STR0007 // Cliente
				If !VCM510VAL("1",aAgendas[ni,2],cTpAgenda,aAgendas[ni,4],aAgendas[ni,5],aAgendas[ni,1],"","")
					lRet := .f.
					Exit
				Else
					If !ML500IVal(cTpAgenda,aAgendas[ni,4],aAgendas[ni,5])
						lRet := .f.
						Exit
					EndIf
				EndIf
			ElseIf aAgendas[ni,7] == STR0028 // Prospect
				If !VCM510VAL("1",aAgendas[ni,2],cTpAgenda,"","",aAgendas[ni,1],aAgendas[ni,4],aAgendas[ni,5])
					lRet := .f.
					Exit
				EndIf
			EndIf
		Next
	Else
		MsgAlert(STR0024,STR0023) // Tipo de Agenda nao informado! / Atencao
		oTpAgenda:SetFocus()
	EndIf
	If lRet
		If MsgYesNo(STR0025,STR0023) // Confirma geracao de Agenda? / Atencao
			For ni := 1 to Len(aAgendas)
				If aAgendas[ni,7] == STR0007 // Cliente
					FS_AGENDA(cTpAgenda,aAgendas[ni,1],aAgendas[ni,2],aAgendas[ni,4],aAgendas[ni,5],"","",cEmiteFic,cObjetiv,"","")
				ElseIf aAgendas[ni,7] == STR0028 // Prospect
					FS_AGENDA(cTpAgenda,aAgendas[ni,1],aAgendas[ni,2],"","","","",cEmiteFic,cObjetiv,aAgendas[ni,4],aAgendas[ni,5])
				EndIf
			Next
			MsgInfo(STR0026,STR0023) // Agenda criada com sucesso! / Atencao
		Else
			lRet := .f.
		EndIf
	EndIf
Else
	MsgAlert(STR0027,STR0023) // Favor preencher corretamente os dados! / Atencao
	oTpAgenda:SetFocus()
EndIf
Return(lRet)
