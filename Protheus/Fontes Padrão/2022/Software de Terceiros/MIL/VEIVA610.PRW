// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 58     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "VEIVA610.CH"

#define STR0070 "" // Reaproveitar

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVA610 | Autor ³ Andre Luis Almeida    ³ Data ³ 18/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Avaliacao de Veiculos Usados                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVA610(cTIPOPAGTO)
Local lRet        := .t.
Local cQuery      := ""
Local cQAlVAZ     := "SQLVAZ"
Local OXverde
Local OXcinza   
Local OXvermelho
Private overde    := LoadBitmap( GetResources(), "BR_verde")
Private ocinza    := LoadBitmap( GetResources(), "BR_cinza")
Private overmelho := LoadBitmap( GetResources(), "BR_vermelho")
Private aMemos    := {{"VAZ_OCOMEM","VAZ_OCORRE"}}
Private aVEITroca := {}
Private cObserv   := ""
Private cAlias    := "VAZ"
Private aCampos   := {}
Private cCadastro := OemToAnsi(STR0001)
Private aRotina   := MenuDef()
Private cPPlaca   := space(len(VV1->VV1_PLAVEI))
Private cPChassi  := space(len(VV1->VV1_CHASSI))
Private cPCodCli  := space(9)
Private cPNomCli  := space(20)
Private aComboP   := {STR0047,STR0016,STR0017,STR0018} // Placa / Chassi / Cod.Cliente / Nome Cliente
Private cComboP   := STR0047 // Placa
Private VV1_CODMAR:= "" // VARIAVEL utilizada para PESQUISA do Modelo/Cor do Veiculo
Private cGruSer   := ""
Private cGruIte   := ""
//PL 23 item 8.2.2.1 - Adicionar botoes enchoice bar
//Private aNewBot    := {}
Default cTIPOPAGTO:= "XXXXXX"
/*
If ExistBlock("PEVA610REC")
aNewBot := { {"CLIENTE",{|| ExecBlock("PEVA610REC",.f.,.f.) },"Recepciona"}}//cria o botão recepciona
EndIF
*/

//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
// TEMPORARIO -> SOMENTE ENQUANTO ESTIVER UTILIZANDO O VEIVM011 //
//////////////////////////////////////////////////////////////////
If cTIPOPAGTO <> "XXXXXX"
	If !(FM_PILHA("VEIVM011"))
		Return .t.
	EndIf
EndIf
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

DbSelectArea("VAW")

If cTIPOPAGTO == "XXXXXX"
	aCores := {{'VAZ->VAZ_APROVA == "1"','BR_VERDE'},;
	{'VAZ->VAZ_APROVA == "2"','BR_CINZA'},;
	{'VAZ->VAZ_APROVA == "0"','BR_VERMELHO'}}
	mBrowse( 6, 1,22,75,"VAZ",,,,,,aCores)
Else
	If !Empty(cTIPOPAGTO) .and. Alltrim(cTIPOPAGTO) == Alltrim(GetNewPar("MV_TPVEITR","VEICULOS"))
		If FunName() $ "VEIVM011/VEIVM012"
			lRet   := .f.
			cQuery := "SELECT TEMP.*, VAZ2.* "
			cQuery += "FROM ( SELECT VAZ_CHASSI, VS9_NUMIDE, MAX(VAZ_REVISA) VAZ_REVISA FROM "+RetSqlName("VAZ")+" VAZ "
			cQuery += "LEFT OUTER JOIN "+RetSqlName("VS9")+" VS9 ON ( VS9.VS9_REFPAG=VAZ.VAZ_CODIGO AND VS9.VS9_FILIAL=VAZ.VAZ_FILIAL AND VS9.D_E_L_E_T_=' ' ) "
			cQuery += "WHERE VAZ.VAZ_FILIAL='"+xFilial("VAZ")+"' AND VAZ.VAZ_APROVA<>'2' AND VAZ.D_E_L_E_T_=' ' "
			cQuery += "GROUP BY VAZ_CHASSI,VS9_NUMIDE ) TEMP "
			cQuery += "JOIN "+RetSqlName("VAZ")+" VAZ2 ON VAZ2.VAZ_FILIAL='"+xFilial("VAZ")+"' AND VAZ2.VAZ_CHASSI = TEMP.VAZ_CHASSI AND VAZ2.VAZ_REVISA = TEMP.VAZ_REVISA AND VAZ2.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVAZ, .F., .T. )
			Do While !( cQAlVAZ )->( Eof() )
				DbSelectArea("SA1")
				DbSetOrder(1)
				DbSeek( xFilial("SA1") + ( cQAlVAZ )->( VAZ_CODCLI ) + ( cQAlVAZ )->( VAZ_LOJCLI ) )
				DbSelectArea("VV2")
				DbSetOrder(1)
				DbSeek( xFilial("VV2") + ( cQAlVAZ )->( VAZ_CODMAR ) + ( cQAlVAZ )->( VAZ_MODVEI ) )
				Aadd(aVEITroca,{ If(Empty(( cQAlVAZ )->( VS9_NUMIDE )),If(( cQAlVAZ )->( VAZ_APROVA )=="1","verde","vermelho"),"cinza") , ( cQAlVAZ )->( VAZ_CHASSI ) , ( cQAlVAZ )->( VAZ_CODCLI )+( cQAlVAZ )->( VAZ_LOJCLI ) , ( cQAlVAZ )->( VAZ_CODMAR )+" "+VV2->VV2_DESMOD , ( cQAlVAZ )->( VAZ_VALCOM ) , Transform(stod(( cQAlVAZ )->( VAZ_DATAVA )),"@D")+" "+UsrRetName(( cQAlVAZ )->( VAZ_CUSAVA )) , If(Empty(( cQAlVAZ )->( VS9_NUMIDE )),( cQAlVAZ )->( VAZ_OCOMEM ),( cQAlVAZ )->( VS9_NUMIDE )) , ( cQAlVAZ )->( VAZ_CODIGO ) , left(SA1->A1_NOME,20) , ( cQAlVAZ )->( VAZ_PLAVEI ) })
				( cQAlVAZ )->( DbSkip() )
			EndDo
			( cQAlVAZ )->( dbCloseArea() )
			If len(aVEITroca) <= 0
				Aadd(aVEITroca,{ "vermelho" , "" , "" , "" , 0 , "  /  /  " , "" , "" , "" , "" })
			EndIf
			FS_OBS610(1)
			DbSelectArea("VS9")
			DEFINE MSDIALOG oVEITroca TITLE STR0019 From 00,00 to 26,92 of oMainWnd
			@ 004,001 BITMAP OXverde RESOURCE "BR_verde" OF oVEITroca PIXEL NOBORDER SIZE 10,10 when .f.
			@ 004,009 SAY STR0020 SIZE 80,10 OF oVEITroca PIXEL COLOR CLR_BLUE
			@ 004,043 BITMAP OXvermelho RESOURCE "BR_vermelho" OF oVEITroca PIXEL NOBORDER SIZE 10,10 when .f.
			@ 004,051 SAY STR0021 SIZE 80,10 OF oVEITroca PIXEL COLOR CLR_BLUE
			@ 004,097 BITMAP OXcinza RESOURCE "BR_cinza" OF oVEITroca PIXEL NOBORDER SIZE 10,10 when .f.
			@ 004,105 SAY STR0030 SIZE 80,10 OF oVEITroca PIXEL COLOR CLR_BLUE
			@ 004,148 SAY STR0022 SIZE 80,10 OF oVEITroca  PIXEL COLOR CLR_BLUE
			@ 003,173 MSCOMBOBOX oComboP VAR cComboP ITEMS aComboP VALID (FS_PESQUISA(1),FS_PESQUISA(2)) SIZE 48,07 OF oVEITroca PIXEL COLOR CLR_BLUE
			@ 003,220 MSGET oPPlaca  VAR cPPlaca  PICTURE VV1->(x3Picture("VV1_PLAVEI")) SIZE 70,08 OF oVEITroca PIXEL COLOR CLR_BLUE
			@ 003,220 MSGET oPChassi VAR cPChassi PICTURE "@!" F3 "VV1" SIZE 70,08 OF oVEITroca PIXEL COLOR CLR_BLUE
			@ 003,220 MSGET oPCodCli VAR cPCodCli PICTURE "@R 999999-99" F3 "SA1" SIZE 70,08 OF oVEITroca PIXEL COLOR CLR_BLUE
			@ 003,220 MSGET oPNomCli VAR cPNomCli PICTURE "@!" SIZE 70,08 OF oVEITroca PIXEL COLOR CLR_BLUE
			oPChassi:lVisible := .f.
			oPCodCli:lVisible := .f.
			oPNomCli:lVisible := .f.
			@ 004,291 BUTTON oOk PROMPT STR0023 OF oVEITroca SIZE 18,09 PIXEL ACTION (FS_PESQUISA(3),FS_OBS610(2))
			@ 015,001 LISTBOX oLbVEITroca FIELDS HEADER OemToAnsi(""),;
			OemToAnsi(STR0047),; // Placa
			OemToAnsi(STR0016),; // Chassi
			OemToAnsi(STR0024),;
			OemToAnsi(STR0025),;
			OemToAnsi(STR0026),;
			OemToAnsi(STR0027) ;
			COLSIZES 10,20,30,45,45,30,70 SIZE 362,155 OF oVEITroca PIXEL ON CHANGE FS_OBS610(2) ON DBLCLICK If(FS_RETORNO(),(lRet:=.t.,oVEITroca:End()),lRet:=.f.)
			oLbVEITroca:SetArray(aVEITroca)
			oLbVEITroca:bLine := { || {If(aVEITroca[oLbVEITroca:nAt,1]<>"cinza",If(aVEITroca[oLbVEITroca:nAt,1]=="verde",overde,overmelho),ocinza),;
			Transform(aVEITroca[oLbVEITroca:nAt,10],VV1->(x3Picture("VV1_PLAVEI"))) ,;
			aVEITroca[oLbVEITroca:nAt,2] ,;
			left(aVEITroca[oLbVEITroca:nAt,3],6)+"-"+right(aVEITroca[oLbVEITroca:nAt,3],2)+" "+aVEITroca[oLbVEITroca:nAt,9] ,;
			aVEITroca[oLbVEITroca:nAt,4] ,;
			FG_AlinVlrs(Transform(aVEITroca[oLbVEITroca:nAt,5],"@E 999,999,999.99")) ,;
			aVEITroca[oLbVEITroca:nAt,6] }}
			@ 170,001 GET oObserv VAR cObserv OF oVEITroca MEMO SIZE 362,025 PIXEL READONLY MEMO
			DEFINE SBUTTON FROM 002,330 TYPE 2 ACTION (oVEITroca:End()) ENABLE OF oVEITroca
			ACTIVATE MSDIALOG oVEITroca CENTER
		Else
			MsgStop(STR0028,STR0002)
		EndIf
	EndIf
EndIf
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_PESQUIS| Autor ³ Andre Luis Almeida    ³ Data ³ 18/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Avaliacao de Veiculos Usados                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PESQUISA(nTip)
If nTip == 1
	oPPlaca:lVisible  := .f.
	oPChassi:lVisible := .f.
	oPCodCli:lVisible := .f.
	oPNomCli:lVisible := .f.
	If cComboP == STR0047 // Placa
		oPPlaca:lVisible := .t.
	ElseIf cComboP == STR0016 // Chassi
		oPChassi:lVisible := .t.
	ElseIf cComboP == STR0017 // Cod.Cliente
		oPCodCli:lVisible := .t.
	Else // cComboP == STR0018 // Nome Cliente
		oPNomCli:lVisible := .t.
	EndIf
	oPPlaca:Refresh()
	oPChassi:Refresh()
	oPCodCli:Refresh()
	oPNomCli:Refresh()
ElseIf nTip == 2
	If cComboP == STR0047 // Placa
		oPPlaca:SetFocus()
	ElseIf cComboP == STR0016 // Chassi
		oPChassi:SetFocus()
	ElseIf cComboP == STR0017 // Cod.Cliente
		oPCodCli:SetFocus()
	Else // cComboP == STR0018 // Nome Cliente
		oPNomCli:SetFocus()
	EndIf
Else // nTip == 3
	If cComboP == STR0047 // Placa
		aSort(aVEITroca,1,,{|x,y| x[10] < y[10] })
		nPos := aScan(aVEITroca,{|x| UPPER(Alltrim(cPPlaca)) $ UPPER(x[10]) })
	ElseIf cComboP == STR0016 // Chassi
		aSort(aVEITroca,1,,{|x,y| x[2] < y[2] })
		nPos := aScan(aVEITroca,{|x| UPPER(Alltrim(cPChassi)) $ UPPER(x[2]) })
	ElseIf cComboP == STR0017 // Cod.Cliente
		aSort(aVEITroca,1,,{|x,y| x[3] < y[3] })
		nPos := aScan(aVEITroca,{|x| Alltrim(cPCodCli) $ x[3] })
	Else // cComboP == STR0018 // Nome Cliente
		aSort(aVEITroca,1,,{|x,y| x[9] < y[9] })
		nPos := aScan(aVEITroca,{|x| Alltrim(cPNomCli) $ x[9]  })
	EndIf
	If nPos <= 0
		MsgStop(STR0034,STR0002) // Veiculo nao encontrado! / Atencao
		nPos := 1
	EndIf
	oLbVEITroca:nAt := nPos
	oLbVEITroca:SetArray(aVEITroca)
	oLbVEITroca:bLine := { || {If(aVEITroca[oLbVEITroca:nAt,1]<>"cinza",If(aVEITroca[oLbVEITroca:nAt,1]=="verde",overde,overmelho),ocinza),;
	Transform(aVEITroca[oLbVEITroca:nAt,10],VV1->(x3Picture("VV1_PLAVEI"))) ,;
	aVEITroca[oLbVEITroca:nAt,2] ,;
	left(aVEITroca[oLbVEITroca:nAt,3],6)+"-"+right(aVEITroca[oLbVEITroca:nAt,3],2)+" "+aVEITroca[oLbVEITroca:nAt,9] ,;
	aVEITroca[oLbVEITroca:nAt,4] ,;
	FG_AlinVlrs(Transform(aVEITroca[oLbVEITroca:nAt,5],"@E 999,999,999.99")) ,;
	aVEITroca[oLbVEITroca:nAt,6] }}
	oLbVEITroca:Refresh()
EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_OBS610 | Autor ³ Andre Luis Almeida    ³ Data ³ 18/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tratativa da Observação                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OBS610(nTip)
cObserv := ""
If nTip == 1
	If aVEITroca[1,1] <> "cinza"
		cObserv := IIF(!Empty(aVEITroca[1,7]), MSMM(aVEITroca[1,7],47),"")
	Else
		cObserv := STR0030+" - "+STR0031+" "+aVEITroca[1,7]
	EndIf
Else // nTip == 2
	If !Empty(aVEITroca[oLbVEITroca:nAt,7])
		If aVEITroca[oLbVEITroca:nAt,1] <> "cinza"
			cObserv := IIF(!Empty(aVEITroca[oLbVEITroca:nAt,7]),MSMM(aVEITroca[oLbVEITroca:nAt,7],47),"")
		Else
			cObserv := STR0030+" - "+STR0031+" "+aVEITroca[oLbVEITroca:nAt,7]
		EndIf
	EndIf
	oObserv:Refresh()
EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_RETORNO| Autor ³ Andre Luis Almeida    ³ Data ³ 18/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Avaliacao de Veiculos Usados                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_RETORNO()
Local lRet := .f.
Local nPos := 0
Local ni := 0
If aVEITroca[oLbVEITroca:nAt,1] == "verde"
	nPos := aScan(aCols, {|x| Alltrim(x[FG_POSVAR("VS9_REFPAG")]) == Alltrim(aVEITroca[oLbVEITroca:nAt,8]) .and. x[13] == .f. })
	If nPos == 0
		lRet := .t.
		aCols[n,FG_POSVAR("VS9_TIPPAG")] := M->VS9_TIPPAG
		dbSelectarea("VSA")
		dbSetOrder(1)
		if dbSeek(xFilial("VSA")+M->VS9_TIPPAG)
			M->VS9_DESPAG := VSA->VSA_DESPAG
			aCols[n,FG_POSVAR("VS9_DESPAG")] := M->VS9_DESPAG
		Endif
		aCols[len(aCols),FG_POSVAR("VS9_DATPAG")] := dDataBase
		aCols[len(aCols),FG_POSVAR("VS9_VALPAG")] := aVEITroca[oLbVEITroca:nAt,5]
		aCols[len(aCols),FG_POSVAR("VS9_REFPAG")] := aVEITroca[oLbVEITroca:nAt,8]
		aCols[len(aCols),FG_POSVAR("VS9_SEQUEN")] := "01"
		aadd(aColsC,{})
		For ni := 1 to len(aCols[len(aCols)])
			aadd(aColsC[len(aColsC)],aCols[len(aCols),ni])
		Next
		FS_CALC011()
	Else
		MsgStop(STR0029,STR0002)
	EndIf
Else
	If aVEITroca[oLbVEITroca:nAt,1] == "cinza"
		MsgStop(STR0030+" - "+STR0031+" "+aVEITroca[oLbVEITroca:nAt,7],STR0002)
	Else
		MsgStop(STR0014,STR0002)
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ML610Val | Autor ³ Andre Luis Almeida    ³ Data ³ 18/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida o Motivo                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ML610Val()
Local lRet := .t.
If M->VAZ_APROVA=="0" .and. Empty(M->VAZ_OCORRE)
	MsgStop(STR0005,STR0002)
	lRet := .f.
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VEIVA61| Autor ³ Andre Luis Almeida    ³ Data ³ 18/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria/Exclui VV1                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VEIVA610(cTip)
Local lAux := Inclui
Local lInc := .t.
If cTip == "INC"
	DbSelectArea("VV1")
	DbSetOrder(2)
	If DbSeek(xFilial("VV1")+VAZ->VAZ_CHASSI)
		lInc := .f.
	EndIf
	DbSelectArea("VV1")
	RecLock("VV1",lInc)
	VV1->VV1_FILIAL := xFilial("VV1")
	VV1->VV1_CHASSI := VAZ->VAZ_CHASSI
	VV1->VV1_CODMAR := VAZ->VAZ_CODMAR
	VV1->VV1_MODVEI := VAZ->VAZ_MODVEI
	VV1->VV1_PROATU := VAZ->VAZ_CODCLI
	VV1->VV1_LJPATU := VAZ->VAZ_LOJCLI
	VV1->VV1_CORVEI := VAZ->VAZ_CORVEI
	VV1->VV1_FABMOD := VAZ->VAZ_FABMOD
	VV1->VV1_COMVEI := VAZ->VAZ_COMVEI
	VV1->VV1_PLAVEI := VAZ->VAZ_PLAVEI
	VV1->VV1_SUGVDA := If(VAZ->VAZ_VALAVA>(VAZ->VAZ_VALCOM+VAZ->VAZ_VALREP),VAZ->VAZ_VALAVA,(VAZ->VAZ_VALCOM+VAZ->VAZ_VALREP))
	VV1->VV1_KILVEI := VAZ->VAZ_KILVEI
	If lInc
		Inclui := .t.
		VV1->VV1_CHAINT := CriaVar("VV1_CHAINT")
		VV1->VV1_SITVEI := " "
		VV1->VV1_VEIACO := "0"
		VV1->VV1_CODORI := "2"
		VV1->VV1_PROVEI := " "
		VV1->VV1_ESTVEI := "1"
		VV1->VV1_INDCAL := " "
		VV1->VV1_LOCPAD := "VU"
		VV1->VV1_PORTAS := VAZ->VAZ_QTDPOR
		VV1->VV1_RENAVA := VAZ->VAZ_CERTIF
		ConfirmSx8("VV1")
		Inclui := lAux
	EndIf
	MsUnLock()
Else
	DbSelectArea("VV1")
	DbSetOrder(2)
	If DbSeek(xFilial("VV1")+cTip)
		RecLock("VV1",.F.,.T.)
		dbdelete()
		MsUnlock()
		WriteSx2("VV1")
	EndIf
EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VEIVA610L | Autor ³ Andre Luis Almeida    ³ Data ³ 18/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda BROWSE                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVA610L()
Local aLegenda := {{'BR_VERDE'   ,STR0012},;
{'BR_CINZA'   ,STR0013},;
{'BR_VERMELHO',STR0014}}
BrwLegenda(cCadastro,STR0011 ,aLegenda)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VEIVA610V | Autor ³ Andre Luis Almeida    ³ Data ³ 18/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica CHASSI                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVA610V(cChassi)
Local nRec      := 0
Local cNumAte   := ""
Local lRet      := .t.
Local nOp       := 0
Local cQuery    := ""
Local cQAlias   := "SQLVAZ"
Local cNumRevis := ""
Local cGruVei   := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))
Local oVeiculos := DMS_Veiculo():New()

//verificar se o veiculo esta em estoque se tiver nao permite a avaliacao/reavaliacao
DbSelectArea("VV1")
DbSetOrder(2)
If DBSeek(xFilial("VV1")+cChassi)
	// Chassi Bloqueado
	If oVeiculos:Bloqueado(VV1->VV1_CHAINT)
		lRet := .f. // A mensagem já é exibida dentro da função Bloqueado()
	EndIf

	If lRet
		DBSelectArea("SB1")
		DBSetOrder(7)
		If DBSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)
			DbSelectArea("SB2")
			DbsetOrder(1)
			If DbSeek(xFilial("SB2")+SB1->B1_COD)
				if SB2->B2_QATU > 0
					lRet := .f.
					MsgInfo(STR0057,STR0002)  //Não será possivel realizar a Avaliação, pois o Veiculo está em estoque
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If !Empty(cChassi) .and. lRet
	DbSelectArea("VAZ")
	nRec := VAZ->(RecNo())
	cQuery := "SELECT VAZ.VAZ_CHASSI , VAZ.VAZ_APROVA , VAZ.VAZ_CODIGO , VAZ.VAZ_REVISA FROM "+RetSqlName("VAZ")+" VAZ  WHERE "
	cQuery += "VAZ.VAZ_FILIAL='"+xFilial("VAZ")+"' AND VAZ.VAZ_CHASSI='"+cChassi+"' AND "
	cQuery += "VAZ.D_E_L_E_T_=' ' ORDER BY VAZ.VAZ_REVISA DESC"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
	cNumRevis := ( cQAlias )->( VAZ_REVISA ) // numero da revisao
	If !Empty(( cQAlias )->( VAZ_CODIGO ))
		cNumAte := FS_ATEABERTO(( cQAlias )->( VAZ_CODIGO ))
	EndIF
	If !Empty(cNumAte)
		MsgStop(STR0003+CHR(13)+CHR(10)+CHR(13)+CHR(10)+Alltrim(VAZ->(RetTitle("VAZ_NUMATE")))+": "+cNumAte,STR0002)
		lRet := .f.
	EndIf
	If !( cQAlias )->( Eof() ) .and. lRet
		If ( cQAlias )->( VAZ_APROVA ) $ "0/1" // 0=Reprovada / 1=Aprovada
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se existe Atendimento em Aberto com esta Avaliacao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nOp := Aviso(STR0002,STR0059,{STR0060,STR0061},1,STR0002) // Atencao / Ja existe Avalicao para o Veiculo! Deseja gerar uma reavaliação? / Sim / Não / Atenção
			If nOp == 1 //reavaliacao
				//se o codigo da revisao estiver em braco significa que eh anterior a esta anteracao e gravara a provima como 02
				IF Empty(cNumRevis)
					cNumRevis := "01"
				EndIf
				//grava o codigo com o da avaliacao anterior.
				M->VAZ_CODIGO := ( cQAlias )->( VAZ_CODIGO )
				lRet := .t.
			Elseif nOp == 2 .or. nOp == 0 //nao raeliza a reavaliacao / Esc
				lRet := .f.
			Endif
		Endif
	EndIf
	( cQAlias )->( dbCloseArea() )
	DbSelectArea("VAZ")
	
	If lRet
		//grava o codigo da avaliazao
		M->VAZ_REVISA := IIF(!Empty(cNumRevis),strzero((VAL(cNumRevis)+1),2),"01")
		IIF(Empty(M->VAZ_CODIGO),M->VAZ_CODIGO := GetSXENum("VAZ","VAZ_CODIGO"),)
		DbSelectArea("VV1")
		DbSetOrder(2)
		If DbSeek(xFilial("VV1")+cChassi)
			M->VAZ_CODMAR := VV1->VV1_CODMAR
			M->VAZ_DESMAR := Posicione("VE1",1,xFilial("VE1")+VV1->VV1_CODMAR,"VE1_DESMAR")
			M->VAZ_MODVEI := VV1->VV1_MODVEI
			M->VAZ_DESMOD := Posicione("VV2",1,xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI,"VV2_DESMOD")
			M->VAZ_CODCLI := VV1->VV1_PROATU
			M->VAZ_LOJCLI := VV1->VV1_LJPATU
			M->VAZ_NOMCLI := Posicione("SA1",1,xFilial("SA1")+VV1->VV1_PROATU+VV1->VV1_LJPATU,"A1_NREDUZ")
			M->VAZ_CORVEI := VV1->VV1_CORVEI
			M->VAZ_DESCOR := Posicione("VVC",1,xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI,"VVC_DESCRI")
			M->VAZ_FABMOD := VV1->VV1_FABMOD
			M->VAZ_COMVEI := VV1->VV1_COMVEI
			M->VAZ_PLAVEI := VV1->VV1_PLAVEI
		EndIf
	EndIf
	If nRec > 0
		DbSelectArea("VAZ")
		DbGoTo(nRec)
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PEVA610  | Autor ³ Andre Luis Almeida    ³ Data ³ 18/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ ponto de entrada botao recepciona Recepciona               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//
Function PEVA610()
If ExistBlock("PEVA610REC") // <<-- OBSOLETO
	ExecBlock("PEVA610REC",.f.,.f.)
else
	Help(1," ","NOWINDOWS",,STR0062,4,1)  
EndIF

If ExistBlock("PEVA610R")
	ExecBlock("PEVA610R",.f.,.f.)
else
	Help(1," ","NOWINDOWS",,STR0062,4,1)  
EndIF

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  | Autor ³ Andre Luis Almeida    ³ Data ³ 18/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Avaliacao de Veiculos Usados                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRecebe
Local aRotina := {	{ STR0006 ,"AxPesqui"   	, 0 , 1 },;	 	// Pesquisar
					{ STR0007 ,"VEIA610"   		, 0 , 2 },; 	// Visualizar
					{ STR0008 ,"VEIA610" 	 	, 0 , 3 },;	 	// Incluir
					{ STR0009 ,"VEIA610"  		, 0 , 4 },; 	// Alterar
					{ STR0010 ,"VEIA610"  		, 0 , 5 },; 	// Excluir
					{ STR0067 ,"VEIA610FAS"		, 0 , 3 },;	 	// Incluir Fast
					{ STR0011 ,"VEIVA610L"  	, 0 , 4 ,2,.f.},; // Legenda
					{ STR0035 ,"VE610_LVEI" 	, 0 , 1},;		//Gera Orc.
					{ STR0063 ,"PEVA610" 		, 0	, 4 },;		//Recepciona
					{ STR0068 ,"U_RAVAVEIU" 		, 0	, 4 },;	//Impressao
					{ STR0069 ,"U_VA610MUL" , 0	, 4 } }		    //"Impr.Termo Multas"
If ExistBlock("PE610AROT")
	aRecebe := ExecBlock("PE610AROT",.f.,.f.,{aRotina} )
Endif
If Valtype(aRecebe) == "A"
	aRotina := aClone(aRecebe)
Endif
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³VE610_LVEI³Autor³ Andre Luis Almeida / Rafael ³Data³ 20/10/08 ³±±
±±ÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descr.³ Levantamento dos REGISTROS pelo Chassi do Veiculo            ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VE610_LVEI()
Local nOpca := 0
Local aFilAtu   := FWArrFilAtu()
Local aSM0      := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt:= cFilAnt //Salvar cFilAnt 
Local nCont := 0  
Private aEmpAtu  := {}
Private aLevPesq := {{"","","",ctod(""),0,"",""}}
Private cLevChas := left(space(50),len(VV1->VV1_CHASSI))
Private overd    := LoadBitmap( GetResources(), "BR_verde")
Private ocinz    := LoadBitmap( GetResources(), "BR_cinza")
Private overm    := LoadBitmap( GetResources(), "BR_vermelho")  
nOpc := 1
For nCont := 1 to Len(aSM0)     
	cFilAnt := aSM0[nCont]
	aFilAtu   := FWArrFilAtu()
	aAdd( aEmpAtu , { cFilAnt , aFilAtu[5] } )
Next

cFilAnt := ""
Do While Empty(cFilAnt) //Nao sai da tela enquanto nao escolher uma filial
	cFilant := FWPesqSM0("M0_CODFIL",cEmpAnt) //Escolher a filial que deseja trabalhar
EndDo	

DEFINE MSDIALOG oLevPesq TITLE OemtoAnsi(STR0036) FROM  01,05 TO 17,70 OF oMainWnd     //Pesquisa Chassi
@ 003,004 SAY STR0037 SIZE 80,7 OF oLevPesq PIXEL COLOR CLR_BLUE     //Veiculo:
@ 002,025 MSGET oLevChas VAR cLevChas F3 "VV1" VALID FS_LEVVEI() PICTURE "@!" SIZE 100,08 OF oLevPesq PIXEL
@ 002,212 BUTTON oNo PROMPT OemToAnsi(STR0038) OF oLevPesq SIZE 43,11 PIXEL ACTION (nOpca := 0, oLevPesq:End())  //SAIR
@ 015,002 LISTBOX oLbLevPesq FIELDS HEADER OemToAnsi(""),;
OemToAnsi(STR0039),; 		//Filial
OemToAnsi(STR0040),; 		//Dt.Avaliacao
OemToAnsi(STR0041),;		//Valor
OemToAnsi(STR0042),;		//Usuario
OemToAnsi(STR0043);			//Cliente
COLSIZES 10,45,35,35,50,150 SIZE 253,104 OF oLevPesq PIXEL ON DBLCLICK (nOpca := oLbLevPesq:nAt, oLevPesq:End() )
oLbLevPesq:SetArray(aLevPesq)
oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="1",oVerd,IIf(aLevPesq[oLbLevPesq:nAt,02]=="2",oCinz,oVerm)),;
aLevPesq[oLbLevPesq:nAt,03],;
Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
FG_AlinVlrs(Transform(aLevPesq[oLbLevPesq:nAt,05],"@E 999,999,999.99")),;
aLevPesq[oLbLevPesq:nAt,06],;
aLevPesq[oLbLevPesq:nAt,07] }}
ACTIVATE MSDIALOG oLevPesq CENTER
dbSelectArea("VAZ")
if nOpca > 0 .and. Len(aLevPesq) >= nOpca
	//posiciona no registro
	dbSetOrder(5)//CODIGO
	If GetVersao(.f.) == "P10" 
		DbSeek(left(aLevPesq[nOpca,3],2)+ aLevPesq[nOpca,1])
	Else
		DbSeek(left(aLevPesq[nOpca,3],9)+ aLevPesq[nOpca,1])
	Endif	
endif
dbSetOrder(1)
cFilAnt := cBkpFilAnt // Voltar cFilAnt
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_LEVVEI| Autor ³ Andre Luis Almeida    ³ Data ³ 18/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Avaliacao de Veiculos Usados                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVVEI()
Local cEmpAtu := ""
Local nEmpAtu := 0
Local lOk := .t.
Local cQuery := ""
Local cQAlVAZ := "SQLVAZ"
Local cFilLibs := ""
Local aSM0     := {}
aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)
If FS_POSVEI() .and. !Empty(cLevChas)
	aLevPesq := {}
	cQuery := "SELECT VAZ.VAZ_CODIGO , VAZ.VAZ_APROVA , VAZ.VAZ_FILIAL , VAZ.VAZ_DATAVA , VAZ.VAZ_VALAVA , VAZ.VAZ_CODCLI , VAZ.VAZ_LOJCLI , VAZ.VAZ_CUSAVA FROM "+RetSqlName("VAZ")+" VAZ WHERE "
	cQuery += "VAZ.VAZ_CHASSI='"+cLevChas+"' AND "
	cFilLibs := FG_FilLib(2) // retorna apenas filiais que o usuario pode acessar
	If len(cFilLibs) > 1
		cQuery += "VAZ.VAZ_FILIAL IN ("
		While len(cFilLibs) > 1
			If aSM0[1] == left(cFilLibs,2)   
				If GetVersao(.f.) == "P10" 
					cQuery += "'"+substr(cFilLibs,3,2)+"',"
				Else
					cQuery += "'"+substr(cFilLibs,3,9)+"',"
				Endif	
			EndIf
			If GetVersao(.f.) == "P10" 
				cFilLibs := substr(cFilLibs,6)
			Else
				cFilLibs := substr(cFilLibs,13)
			Endif	
		EndDo
		cQuery := left(Alltrim(cQuery),len(Alltrim(cQuery))-1)+") AND "
	EndIf
	cQuery += "VAZ.D_E_L_E_T_=' ' ORDER BY VAZ.VAZ_DATAVA "
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVAZ, .F., .T. )
	Do While !( cQAlVAZ )->( Eof() )
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + ( cQAlVAZ )->( VAZ_CODCLI ) + ( cQAlVAZ )->( VAZ_LOJCLI ) )
		cEmpAtu := ""
		nEmpAtu := Ascan(aEmpAtu,{|x| x[1] == ( cQAlVAZ )->( VAZ_FILIAL ) })
		If nEmpAtu > 0
			cEmpAtu := left(aEmpAtu[nEmpAtu,2],15)
		EndIf
		aAdd(aLevPesq,{ ( cQAlVAZ )->( VAZ_CODIGO ) , ( cQAlVAZ )->( VAZ_APROVA) , ( cQAlVAZ )->( VAZ_FILIAL )+"-"+cEmpAtu , stod(( cQAlVAZ )->( VAZ_DATAVA )) , ( cQAlVAZ )->( VAZ_VALAVA ) ,UsrRetname(( cQAlVAZ )->( VAZ_CUSAVA )) , ( cQAlVAZ )->( VAZ_CODCLI )+"-"+( cQAlVAZ )->( VAZ_LOJCLI )+" "+SA1->A1_NOME })
		( cQAlVAZ )->( DbSkip() )
	EndDo
	( cQAlVAZ )->( dbCloseArea() )
	If len(aLevPesq) <= 0
		MsgAlert(STR0044 +" "+cLevChas,STR0002)// Nenhuma Avaliacao encontrada para o chassi # Atencao
		aLevPesq := {{"","","",ctod(""),0,"",""}}
		lOk := .f.
	EndIf
	oLbLevPesq:nAt := 1
	oLbLevPesq:SetArray(aLevPesq)
	oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="1",oVerd,IIf(aLevPesq[oLbLevPesq:nAt,02]=="2",oCinz,oVerm)),;
	aLevPesq[oLbLevPesq:nAt,03],;
	Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
	FG_AlinVlrs(Transform(aLevPesq[oLbLevPesq:nAt,05],"@E 999,999,999.99")),;
	aLevPesq[oLbLevPesq:nAt,06],;
	aLevPesq[oLbLevPesq:nAt,07] }}
	oLbLevPesq:SetFocus()
	oLbLevPesq:Refresh()
	If !lOk
		oLevChas:SetFocus()
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_POSVEI()³ Autor ³ Andre Luis Almeida / Rafael ³ Data ³ 06/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Posicionamento do veiculo na Tabela VAZ                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_POSVEI()
Local lRet   	:= .f.
Local cQAlVAZ 	:= "SQLVAZ"
Local cQAlSA1 	:= "SQLSA1"
Local cQuery  	:= ""
Local cQuerySA1 := ""
Local cQuerAux	:= ""
Local lAchouVAZ	:= .f.
Local aVAZ     	:= {}
Local _cChassi 	:= left(Alltrim(cLevChas)+space(30),Len(VAZ->VAZ_CHASSI))
Local _cPlaVei 	:= left(Alltrim(cLevChas)+space(10),Len(VAZ->VAZ_PLAVEI))
Local aSA1 		:= {}

If Empty(cLevChas)
	Return(.t.)
EndIf
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
cQuerAux := "SELECT VAZ.VAZ_CODIGO , VAZ.VAZ_PLAVEI , VAZ.VAZ_CHASSI , VAZ.VAZ_FABMOD , VAZ.VAZ_CODMAR , VAZ.VAZ_MODVEI , VAZ.VAZ_CODCLI , VAZ.VAZ_LOJCLI , SA1.A1_NOME "
cQuerAux += "FROM "+RetSqlName("VAZ")+" VAZ , " +RetSqlName("SA1")+" SA1 WHERE VAZ.VAZ_CODCLI=SA1.A1_COD AND VAZ.VAZ_LOJCLI=SA1.A1_LOJA AND VAZ.VAZ_FILIAL='"+xFilial("VAZ")+"' AND "
cQuerAux += "SA1.A1_FILIAL='"+xFilial("SA1")+"' AND VAZ.D_E_L_E_T_=' ' AND SA1.D_E_L_E_T_=' ' AND "
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DbSelectArea("SBM")
DbSetOrder(1)
DbSeek( xFilial("SBM") + left(Alltrim(GetNewPar("MV_GRUVEI","VEI"))+space(4),4) )
If	SBM->BM_LENREL # 99
	cQuery := cQuerAux + "( VAZ.VAZ_CHASSI='"+_cChassi+"' OR VAZ.VAZ_CHASSI LIKE '%"+Alltrim(_cChassi)+"' OR VAZ.VAZ_CHASSI LIKE '%"+Alltrim(_cChassi)+" %' OR VAZ.VAZ_PLAVEI='"+_cPlaVei+"' ) "
Else
	cQuery := cQuerAux + "( VAZ.VAZ_CHASSI='"+_cChassi+"' OR VAZ.VAZ_CHASSI LIKE '%"+Alltrim(_cChassi)+"%' OR VAZ.VAZ_PLAVEI='"+_cPlaVei+"' ) "
EndIf

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVAZ, .F., .T. )
if ( cQAlVAZ )->( Eof())
	( cQAlVAZ )->( dbCloseArea() )
else
	lAchouVAZ := .t.
endif
if !lAchouVAZ //se nao achar o chassi pesquisa pelo cliente
	cQuerySA1 := "SELECT SA1.A1_COD , SA1.A1_LOJA , SA1.A1_NOME , SA1.A1_CGC, "
	cQuerySA1 += "A1_END, A1_MUN CIDADE, A1_EST UF "
	cQuerySA1 += "FROM "+RetSqlName("SA1")+" SA1 "

	cQuerySA1 += "WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_NOME LIKE '%"+Alltrim(cLevChas)+"%' AND SA1.D_E_L_E_T_=' ' ORDER BY SA1.A1_NOME"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuerySA1 ), cQAlSA1, .F., .T. )
	Do While !( cQAlSA1 )->( Eof())
		Aadd(aSA1,{( cQAlSA1 )->( A1_COD ),;
					( cQAlSA1 )->( A1_LOJA ),;
					AllTrim(( cQAlSA1 )->( A1_NOME )),;
					Transform(( cQAlSA1 )->( A1_CGC ),IIf(Len(Alltrim(( cQAlSA1 )->( A1_CGC )))>12,"@R 99.999.999/9999-99","@R 999.999.999-99")),;
					AllTrim(( cQAlSA1 )->( A1_END )),;
					AllTrim(( cQAlSA1 )->( CIDADE )),;
					( cQAlSA1 )->( UF )})
		( cQAlSA1 )->( DbSkip() )
	EndDo
	( cQAlSA1 )->( dbCloseArea() )
	if len(aSA1)>0
		If FG_POSSA1(aSA1)
			dbSelectarea("SA1")
			cQuery := cQuerAux + "VAZ.VAZ_CODCLI='"+SA1->A1_COD+"' AND VAZ.VAZ_LOJCLI='"+SA1->A1_LOJA+"'"
			
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVAZ, .F., .T. )
			if ( cQAlVAZ )->( Eof())
				( cQAlVAZ )->( dbCloseArea() )
			else
				lAchouVAZ := .t.
			endif
		endif
	endif
endif
If lAchouVAZ
	Do While !( cQAlVAZ )->( Eof())
		Aadd(aVAZ,{( cQAlVAZ )->( VAZ_PLAVEI ),( cQAlVAZ )->( VAZ_CHASSI ),( cQAlVAZ )->( VAZ_CODMAR )+" "+( cQAlVAZ )->( VAZ_MODVEI ),( cQAlVAZ )->( VAZ_FABMOD ),( cQAlVAZ )->( VAZ_CODCLI )+"-"+( cQAlVAZ )->( VAZ_LOJCLI )+" "+left(( cQAlVAZ )->( A1_NOME ),25),( cQAlVAZ )->( VAZ_CODIGO )})
		( cQAlVAZ )->( DbSkip() )
	EndDo
	( cQAlVAZ )->( dbCloseArea() )
Else
MsgAlert(STR0015+xFilial("VAZ")+CHR(10)+CHR(13)+cLevChas,STR0002)
endif
DbSelectArea("VAZ")
DbSetOrder(5)
If len(aVAZ) > 1
	DEFINE MSDIALOG oVAZObj TITLE (STR0046) From 5,08 to 22,107 of oMainWnd   //Veiculos
	@ 002,002 LISTBOX oLbVAZ FIELDS HEADER 	OemToAnsi(STR0047),;						//Placa
	OemToAnsi(STR0048),;						//Chassi
	OemToAnsi(STR0049),;						//Marca/Modelo
	OemToAnsi(STR0050),;						//Fab/Mod
	OemToAnsi(STR0051);							//Prop.Atual
	COLSIZES 30,60,80,30,100 SIZE 388,125 OF oVAZObj PIXEL ON DBLCLICK (DbSeek(xFilial("VAZ")+aVAZ[oLbVAZ:nAt,6]),lRet:=.t.,oVAZObj:End())
	oLbVAZ:SetArray(aVAZ)
	oLbVAZ:bLine := { || {Transform(aVAZ[oLbVAZ:nAt,1],PesqPict("VAZ","VAZ_PLAVEI")) ,;
	aVAZ[oLbVAZ:nAt,2],;
	aVAZ[oLbVAZ:nAt,3],;
	Transform(aVAZ[oLbVAZ:nAt,4],PesqPict("VAZ","VAZ_FABMOD")) ,;
	aVAZ[oLbVAZ:nAt,5] }}
	ACTIVATE MSDIALOG oVAZObj CENTER
	If lRet
		cLevChas := VAZ->VAZ_CHASSI
	EndIf
ElseIf len(aVAZ) == 1
	DbSeek(xFilial("VAZ")+aVAZ[1,6])
	cLevChas := VAZ->VAZ_CHASSI
	lRet := .t.
EndIf
DbSelectArea("VAZ")
DbSetOrder(1)
Return(lRet)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VEIA610   ³ Autor ³Manoel                 ³ Data ³ 17/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Trata Inclusao, alteracao ou exclusao de Avaliacao de      ³±±
±±³          ³ veiculos Usados                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIA610(cAlias,nReg,nOpc)

Local bCampo  := { |nCPO| Field(nCPO) }
Local nCntFor := 0
Local _ni	  := 0
Local cNumAte := ""
Local aPos    := {}
Local cAprova := ""
Private oAuxEnchoice
Private oAuxGetDados
Private oAuxDlg
Private aLsItem  := {}
Private oTik 	 := LoadBitmap( GetResources(), "LBTIK" )
Private oNoTik   := LoadBitmap( GetResources(), "LBNO" )
Private lChecked := .f. //Checa todos

If nOpc == 4 // Alterar
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Altera somente a ultima Avaliacao do Veiculo (Posiciona no ultimo Registro de Re-Avalicao) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nReg := FM_SQL("SELECT VAZ.R_E_C_N_O_ VAZRECNO FROM "+RetSQLName("VAZ")+" VAZ WHERE VAZ.VAZ_FILIAL='"+xFilial("VAZ")+"' AND VAZ.VAZ_CODIGO='"+VAZ->VAZ_CODIGO+"' AND VAZ.D_E_L_E_T_=' ' ORDER BY VAZ.VAZ_REVISA DESC")
	DbSelectArea("VAZ")
	If nReg <> VAZ->(RecNo())
		If MsgYesNo(STR0045,STR0002) // Nao e possivel alterar a Avaliacao selecionada, pois existe(m) revisao(oes). Deseja alterar a ultima revisao? / Atencao
			DbGoTo(nReg)
		Else
			Return()
		EndIf
	EndIf
EndIf

If nOpc == 5 // Excluir
	
	cAprova:=FM_SQL("SELECT VAZ.VAZ_APROVA FROM "+RetSQLName("VAZ")+" VAZ WHERE VAZ.VAZ_FILIAL='"+xFilial("VAZ")+"' AND VAZ.VAZ_CODIGO='"+VAZ->VAZ_CODIGO+"' AND VAZ.D_E_L_E_T_=' ' ORDER BY VAZ.VAZ_REVISA DESC")
	
	If cAprova == "1"
		
		cQuery := "SELECT VV9.VV9_STATUS FROM "+RetSqlName("VAZ")+" VAZ "
		cQuery += " LEFT OUTER JOIN "+RetSqlName("VS9")+" VS9 ON"
		cQuery += " ( VS9.VS9_REFPAG=VAZ.VAZ_CODIGO AND VS9.VS9_FILIAL=VAZ.VAZ_FILIAL AND VS9.D_E_L_E_T_=' ' )"
		cQuery += " INNER JOIN "+RetSqlName("VV9")+" VV9 ON "
		cQuery += " VV9.VV9_FILIAL='"+xFilial("VV9")+"' AND VV9.VV9_NUMATE=VS9.VS9_NUMIDE AND VV9.VV9_STATUS IN ('L','O') AND VV9.D_E_L_E_T_=' '"
		cQuery += " WHERE VAZ.VAZ_FILIAL='"+xFilial("VAZ")+"' AND VAZ.VAZ_CODIGO='"+VAZ->VAZ_CODIGO+"' AND VAZ.D_E_L_E_T_=' ' "
		cStatus:=FM_SQL(cQuery)
		
		if cStatus $ "LO"
			MsgStop(STR0004,STR0002)
			Return()
		endif
		
	elseif cAprova == "2"
		MsgStop(STR0004,STR0002)
		Return()
	EndIf

	cQuery := "SELECT COUNT(VVG_TRACPA) "
	cQuery +=  " FROM " + RetSQLName("VVG") + " VVG JOIN " + RetSQLName("VVF") + " VVF ON VVG.VVG_FILIAL = VVF.VVF_FILIAL AND VVG.VVG_TRACPA = VVF.VVF_TRACPA AND VVF.D_E_L_E_T_ = ' '"
	cQuery += " WHERE VVG_FILIAL = '" + xFilial("VVG") + "'"
	cQuery +=   " AND VVG_CHASSI = '" + VAZ->VAZ_CHASSI + "'"
	cQuery +=   " AND VVG.D_E_L_E_T_ = ' '"
	cQuery +=   " AND VVF_SITNFI = '1'"	// Nota Fiscal Valida ...
	If FM_SQL(cQuery) <> 0
		MsgStop(STR0066+STR0053,STR0002) //##"Existe uma entrada para este veículo. "//##"Nao e possivel excluir!" //##"Atencao"
		Return()
	EndIf
	
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RegToMemory("VAZ",.f.)         // .t. para carregar campos virtuais
RegToMemory("VAW",.f.)         // .t. para carregar campos virtuais

aCpoEnchoice:={}

nOpcE := nOpc//permitir somente vizulizar qdo for exportar para OS
nOpcG := nOpc

aHeader:={}
aCols  := {}

If nOpc == 4
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a Avaliacao foi utilizada                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If VAZ->VAZ_APROVA == "2"
		MsgStop(STR0003+CHR(13)+CHR(10)+CHR(13)+CHR(10)+Alltrim(VAZ->(RetTitle("VAZ_NUMATE")))+": "+Alltrim(VAZ->VAZ_NUMATE)+" ( "+STR0039+": "+Alltrim(VAZ->VAZ_FILATE)+" )",STR0002)
		Return()
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe Atendimento em Aberto com esta Avaliacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cNumAte := FS_ATEABERTO(VAZ->VAZ_CODIGO)
	If !Empty(cNumAte)
		MsgStop(STR0003+CHR(13)+CHR(10)+CHR(13)+CHR(10)+Alltrim(VAZ->(RetTitle("VAZ_NUMATE")))+": "+cNumAte,STR0002)
		Return()
	EndIf
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a Modelo 3                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cTitulo       :=STR0001
cAliasEnchoice:="VAZ"
cAliasGetD    :="VAW"
cLinOk        :="FG_OBRIGAT(),FS_VALIDP()"
cTudOk        :="AllwaysTrue()"                      //BOBY 05/10/10
cFieldOk      :="FS_ATRIB610(),FS_VALIDP()"

nOpca := 0

FM_Mod3(cTitulo,cAliasEnchoice,cAliasGetD,@aCpoEnchoice,,@aHeader,@aCols,cFieldOk,cLinOk,cTudOk,,nOpcE,nOpcG,,oMainWnd,@oAuxDlg,@oAuxEnchoice,@oAuxGetDados,"VAZ_REVISA","VAW_MOMGRA/VAW_REVISA",,,,@aPos)

IF nOpcG <> 3
	
	oAuxGetDados:aCols := {}
	
	dbSelectArea("VAW")
	dbSetOrder(1)
	DbSeek(xFilial("VAW")+VAZ->VAZ_CODIGO+VAZ->VAZ_REVISA)
	While !Eof() .and. VAW->VAW_FILIAL+VAW->VAW_CODAVA == xFilial("VAW")+VAZ->VAZ_CODIGO .and. VAW->VAW_REVISA == VAZ->VAZ_REVISA
		AADD(oAuxGetDados:aCols,Array(Len(aHeader)+1))
		For nCntFor:=1 to Len(aHeader)
			If IsHeadRec(aHeader[nCntFor,2])
				oAuxGetDados:aCols[Len(oAuxGetDados:aCols),nCntFor] := VAW->(Recno())
			ElseIf IsHeadAlias(aHeader[nCntFor,2])
				oAuxGetDados:aCols[Len(oAuxGetDados:aCols),nCntFor] := "VAW"
			Else
				oAuxGetDados:aCols[Len(oAuxGetDados:aCols),nCntFor]:=If(aHeader[nCntFor,10] # "V",FieldGet(FieldPos(aHeader[nCntFor,2])),CriaVar(aHeader[nCntFor,2]))
			EndIF
		Next
		oAuxGetDados:aCols[Len(oAuxGetDados:aCols),Len(aHeader)+1]:=.F.
		dbSkip()
	Enddo
	
	If Len(oAuxGetDados:aCols) == 0
		
		oAuxGetDados:aCols := { Array(Len(aHeader)+1) }
		oAuxGetDados:aCols[1,Len(aHeader)+1] := .F.
		For nCntFor:=1 to Len(aHeader)
			If IsHeadRec(aHeader[nCntFor,2])
				oAuxGetDados:aCols[Len(oAuxGetDados:aCols),nCntFor] := VAW->(Recno())
			ElseIf IsHeadAlias(aHeader[nCntFor,2])
				oAuxGetDados:aCols[Len(oAuxGetDados:aCols),nCntFor] := "VAW"
			Else
				oAuxGetDados:aCols[1,nCntFor]:=CriaVar(aHeader[nCntFor,2])
			EndIF
		Next
		
	endif
	
endif

oAuxGetDados:oBrowse:bChange := {|| FG_MEMVAR(oAuxGetDados:aHeader,oAuxGetDados:aCols,oAuxGetDados:nAt)}
oAuxGetDados:oBrowse:bDelete := {|| FS_Delete() .and. Fs_TotAbat()}
oAuxGetDados:oBrowse:Refresh()

ACTIVATE MSDIALOG oAuxDlg ON INIT EnchoiceBar(oAuxDlg,{ || IIf(FS_TUDOOKTELA(nOpc),(oAuxDlg:End(),nOpca := 1),.f.) }, { || oAuxDlg:End() },,)

If nOpca <> 0
	Fs_Grava(nOpc)
Endif
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_TUDOOKT| Autor ³ Andre Luis Almeida    ³ Data ³ 18/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ VALIDA CAMPOS ENCHOICE                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TUDOOKTELA(nOpc)
Local cQuery  := ""
Local cQAlSQL := "SQLVSO"
Local ni      := 0
Local iii     := 0
Local nResp   := 0
Local lRet    := .t.
Local nQtde   := 0
Local i := 0
If nOpc != 2 .and. nOpc != 5
	DbSelectArea("VAZ")
	For iii:=1 to Len(aCpoEnchoice)
		If X3Obrigat(aCpoEnchoice[iii]) .and. Empty(&("M->"+aCpoEnchoice[iii]))
			Help(" ",1,"OBRIGAT2",,RetTitle(aCpoEnchoice[iii]),4,1 )
			Return(.f.)
		EndIf
	Next
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se ja existe a mesma placa para outro veiculo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpc == 3 .or. nOpc == 4) .And. M->VAZ_APROVA == "1" .And. !Empty(M->VAZ_PLAVEI)
	nQtde := FM_SQL("SELECT COUNT(*) FROM " + RetSQLName("VV1") + " VV1 " +;
	" WHERE VV1.VV1_FILIAL = '" + xFilial("VV1") + "'" +;
	" AND VV1.VV1_PLAVEI = '" + M->VAZ_PLAVEI + "'" +;
	" AND VV1.VV1_CHASSI <> '" + M->VAZ_CHASSI + "'" +;
	" AND VV1.D_E_L_E_T_ = ' '")
	
	if nQtde > 0
		MsgInfo(STR0065)
		Return (.f.)
	endif
EndIf


Return(.t.)



/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_TotAbat³ Autor ³Manoel                 ³ Data ³ 21/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Soma Valores da Getdados no VAZ_VALREP (Abatimentos)       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fs_TotAbat(lRefreshEnc)

Local cont := 0
Default lRefreshEnc := .t.

M->VAZ_VALREP := 0
For cont := 1 to Len(oAuxGetDados:aCols)
	if !oAuxGetDados:aCols[cont,Len(oAuxGetDados:aCols[cont])]
		If oAuxGetDados:nAt == Cont
			M->VAZ_VALREP += M->VAW_VALITE
		Else
			M->VAZ_VALREP += oAuxGetDados:aCols[cont,FG_POSVAR("VAW_VALITE","aHeader")]
		Endif
	Endif
Next
If lRefreshEnc
	M->VAZ_VALCOM := M->VAZ_VALAVA - M->VAZ_VALREP
	oAuxEnchoice:Refresh()
Else
	If MsgYesNo(STR0064,STR0002)
		M->VAZ_VALCOM := M->VAZ_VALAVA - M->VAZ_VALREP
	Endif
Endif

return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_Atrib61| Autor ³ Andre Luis Almeida    ³ Data ³ 18/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Avaliacao de Veiculos Usados                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_Atrib610()
If ReadVar() $ "M->VAW_GRUSER.M->VAW_TIPSER.M->VAW_TIPTEM.M->VAW_CODSER"
	
	If ReadVar() == "M->VAW_GRUSER"
		cGruSer := M->VAW_GRUSER
	Endif
	
	DbSelectArea("VOK")
	DbSetOrder(1)
	DbSeek( xFilial("VOK") + oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VAW_TIPSER","aHeader")] )
	nTemPad  := int(FG_TEMPAD("",M->VAW_CODSER,if(VOK->VOK_INCTEM == "3","1",VOK->VOK_INCTEM),VOK->VOK_INCMOB,VE1->VE1_CODMAR))/100
	nVlHrTab := FG_ValHor(oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VAW_TIPTEM","aHeader")],dDataBase)
	If !Empty(oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VAW_CODSER","aHeader")]) .or. !Empty(M->VAW_CODSER)
		M->VAW_VALITE := nTemPad * nVlHrTab
		oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VAW_VALITE","aHeader")] := M->VAW_VALITE
		Fs_TotAbat()
	Endif
	
ElseIf ReadVar() == "M->VAW_GRUITE"
	
	cGruIte := M->VAW_GRUITE
	
ElseIf ReadVar() == "M->VAW_TIPABA"
	
	If M->VAW_TIPABA != oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VAW_TIPABA","aHeader")]
		If M->VAW_TIPABA $ "1.3" // Pecas ou Outros
			oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VAW_GRUSER","aHeader")] := Criavar("VAW_GRUSER")
			oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VAW_CODSER","aHeader")] := Criavar("VAW_CODSER")
			oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VAW_TIPSER","aHeader")] := Criavar("VAW_TIPSER")
			oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VAW_TIPTEM","aHeader")] := Criavar("VAW_TIPTEM")
			oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VAW_CODSEC","aHeader")] := Criavar("VAW_CODSEC")
			oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VAW_DESCRI","aHeader")] := Criavar("VAW_DESCRI")
			oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VAW_VALITE","aHeader")] := Criavar("VAW_VALITE")
		Else // If M->VAW_TIPABA == "2" // Servicos
			oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VAW_GRUITE","aHeader")] := Criavar("VAW_GRUITE")
			oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VAW_CODITE","aHeader")] := Criavar("VAW_CODITE")
			oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VAW_DESCRI","aHeader")] := Criavar("VAW_DESCRI")
			oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VAW_VALITE","aHeader")] := Criavar("VAW_VALITE")
		Endif
		//	   Fs_TotAbat()
	Endif
ElseIf ReadVar() == "M->VAW_CODITE"
	oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VAW_DESCRI","aHeader")] := M->VAW_DESCRI   //fnc 11420
Endif

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VALIDP| Autor ³ Andre Luis Almeida    ³ Data ³ 18/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ VALIDA SE EXISTE DUPLICIDADE DE ITEMS NA ACOLS             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALIDP()
Local ni:=0
//valida duplicidade de itens no acols
IF M->VAW_TIPABA == "1" //pecas - Gruite
	For ni := 1 to len(oAuxGetDados:aCols)
		If !oAuxGetDados:aCols[ni,len(oAuxGetDados:aCols[ni])] .and. oAuxGetDados:nAt <> ni// Verificar se a Duplicidade entre as Linhas do aCols  e se a linha e diferente
			//valida se codite eh diferente.
			If oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VAW_CODITE","aHeader")] == oAuxGetDados:aCols[ni,FG_POSVAR("VAW_CODITE","aHeader")] .and. !Empty(oAuxGetDados:aCols[ni,FG_POSVAR("VAW_CODITE","aHeader")])
				MsgStop(STR0054,STR0002) //Item ja cadastrado. ## Atencao"
				oAuxGetDados:aCols[oAuxGetDados:nAt,len(oAuxGetDados:aCols[ni])] := .t.
			EndIf
		EndIf
	Next
ElseIf M->VAW_TIPABA == "2"
	For ni := 1 to len(oAuxGetDados:aCols)
		If !oAuxGetDados:aCols[ni,len(oAuxGetDados:aCols[ni])] .and. oAuxGetDados:nAt <> ni// Verificar se a Duplicidade entre as Linhas do aCols  e se a linha e diferente
			//valida se grupo + cod servico são diferentes.
			If oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VAW_GRUSER","aHeader")] == oAuxGetDados:aCols[ni,FG_POSVAR("VAW_GRUSER","aHeader")] .and. oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VAW_CODSER","aHeader")] == oAuxGetDados:aCols[ni,FG_POSVAR("VAW_CODSER","aHeader")] .and. ;
				!Empty(oAuxGetDados:aCols[ni,FG_POSVAR("VAW_GRUSER","aHeader")]) .and. !Empty(oAuxGetDados:aCols[ni,FG_POSVAR("VAW_CODSER","aHeader")])
				MsgStop(STR0055,STR0002) //Servico ja cadastrado. ## Atencao"
				oAuxGetDados:aCols[oAuxGetDados:nAt,len(oAuxGetDados:aCols[ni])] := .t.
			EndIf
		EndIf
	Next
ElseIf M->VAW_TIPABA == "3"
	For ni := 1 to len(oAuxGetDados:aCols)
		If !oAuxGetDados:aCols[ni,len(oAuxGetDados:aCols[ni])] .and. oAuxGetDados:nAt <> ni// Verificar se a Duplicidade entre as Linhas do aCols  e se a linha e diferente
			//valida se descricao
			If oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VAW_DESCRI","aHeader")] == oAuxGetDados:aCols[ni,FG_POSVAR("VAW_DESCRI","aHeader")] .and. !Empty(oAuxGetDados:aCols[ni,FG_POSVAR("VAW_DESCRI","aHeader")])
				MsgStop(STR0056,STR0002) //Descricao ja cadastrado. ## Atencao"
				oAuxGetDados:aCols[oAuxGetDados:nAt,len(oAuxGetDados:aCols[ni])] := .t.
			EndIf
		EndIf
	Next
EndIF
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Fs_Grava | Autor ³ Andre Luis Almeida    ³ Data ³ 18/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Avaliacao de Veiculos Usados                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fs_Grava(nOpc)

Local i := 0
Private lMsHelpAuto := .f.

If Inclui
	nOpc := 3
Endif

If Altera
	nOpc := 4
Endif

If nOpc != 2

	// Na inclusa ou alteracao, marca como nao aprovado as avaliacoes anteriores 
	if Inclui
		DbSelectArea("VAZ")
		dbSetOrder(5)
		dbSeek(xFilial("VAZ") + M->VAZ_CODIGO)
		While !VAZ->(Eof()) .and. VAZ->VAZ_CODIGO == M->VAZ_CODIGO
			RecLock("VAZ",.f.)
			VAZ->VAZ_REVISA := StrZero(1,TamSX3("VAZ_REVISA")[1])
			MsUnlock()
			VAZ->(dbSkip())
		End
	EndIf
	
	DbSelectArea("VAZ")
	DbSetOrder(1)
	DbSeek(xFilial("VAZ")+M->VAZ_CHASSI+M->VAZ_REVISA)
	
	if Inclui .or. Altera
		
		Fs_TotAbat(.f.)
		
		RecLock("VAZ",!Found())
		FG_GRAVAR("VAZ")
		ConfirmSx8()
		VAZ->VAZ_FILIAL := xFilial("VAZ")
		MSMM(VAZ->VAZ_OCOMEM,TamSx3("VAZ_OCORRE")[1],,&(aMemos[1][2]),1,,,"VAZ","VAZ_OCOMEM")
		
		MsUnlock()
		
		DbSelectArea("VAW")
		DbSetOrder(1)
		For i = 1 to Len(oAuxGetDados:aCols)
			
			If oAuxGetDados:aCols[i,FG_POSVAR("VAW_TIPABA","aHeader")] == "1"
				If Empty(oAuxGetDados:aCols[i,FG_POSVAR("VAW_GRUITE","aHeader")])
					Loop
				Endif
			ElseIf oAuxGetDados:aCols[i,FG_POSVAR("VAW_TIPABA","aHeader")] == "2"
				If Empty(oAuxGetDados:aCols[i,FG_POSVAR("VAW_TIPSER","aHeader")])
					Loop
				Endif
				// RETIRADO POIS CAMPO VAW_DESCRI E UM CAMPO VIRTUAL E O SISTEMA NAO PERMITE ALTERA-LO
				//		   ElseIf oAuxGetDados:aCols[i,FG_POSVAR("VAW_TIPABA","aHeader")] == "3"
				//		   	If Empty(oAuxGetDados:aCols[i,FG_POSVAR("VAW_DESCRI","aHeader")])
				//			   	Loop
				//			   Endif
			Endif
			
			DbSelectArea("VAW")
			dbSeek(xFilial("VAW")+M->VAZ_CODIGO+;
			oAuxGetDados:aCols[i,FG_POSVAR("VAW_TIPABA","aHeader")]+;
			oAuxGetDados:aCols[i,FG_POSVAR("VAW_GRUITE","aHeader")]+;
			oAuxGetDados:aCols[i,FG_POSVAR("VAW_CODITE","aHeader")]+;
			oAuxGetDados:aCols[i,FG_POSVAR("VAW_DESCRI","aHeader")]+;
			oAuxGetDados:aCols[i,FG_POSVAR("VAW_TIPTEM","aHeader")]+;
			oAuxGetDados:aCols[i,FG_POSVAR("VAW_TIPSER","aHeader")]+;
			oAuxGetDados:aCols[i,FG_POSVAR("VAW_GRUSER","aHeader")]+;
			oAuxGetDados:aCols[i,FG_POSVAR("VAW_CODSER","aHeader")]+M->VAZ_REVISA)
			
			
			If oAuxGetDados:aCols[i,Len(oAuxGetDados:aCols[i])]
				
				RecLock("VAW",.f.,.t.)
				DbDelete()
				MsUnlock()
				WriteSx2("VAW")
				
			Else
				
				RecLock("VAW",!Found())
				Fg_Gravar("VAW",oAuxGetDados:aCols,aHeader,i)
				VAW->VAW_FILIAL := xFilial("VAW")
				VAW->VAW_CODAVA := M->VAZ_CODIGO
				VAW->VAW_MOMGRA := "1" //inclusao
				VAW->VAW_REVISA := M->VAZ_REVISA
				MsUnlock()
				WriteSx2("VAW")
				
			Endif
		Next
		
		If nOpc == 3
			If VAZ->VAZ_APROVA == "1"
				FS_VEIVA610("INC")
			EndIf
		EndIf
		
		If VAZ->VAZ_APROVA == "1"
			FS_VEIVA610("INC")
		Else
			FS_VEIVA610(VAZ->VAZ_CHASSI)
		EndIf
		
		If ExistBlock("VA610DPGR")
			ExecBlock("VA610DPGR",.f.,.f.)
		EndIF
		
	Else
		
		If M->VAZ_APROVA <> "2" .and. Empty(M->VAZ_NUMATE)
			FS_VEIVA610(M->VAZ_CHASSI)
		Else
			MsgStop(STR0004,STR0002)
			return
		EndIf
		
		DbSelectArea("VAZ")
		DbSetOrder(5)
		DbSeek(xFilial("VAZ")+M->VAZ_CODIGO+M->VAZ_REVISA)
		
		If Found()
			RecLock("VAZ",.f.,.t.)
			DbDelete()
			MsUnlock()
			WriteSx2("VAZ")
			
			DbSelectArea("VAW")
			DbSeek(xFilial("VAW")+M->VAZ_CODIGO)
			While !eof() .and. xFilial("VAW")+M->VAZ_CODIGO == VAW->VAW_FILIAL+VAW->VAW_CODAVA
				
				If VAW->VAW_REVISA == M->VAZ_REVISA
					
					RecLock("VAW",.f.,.t.)
					DbDelete()
					MsUnlock()
					WriteSx2("VAW")
					
				Endif
				
				DbSkip()
				
			Enddo
			
		Endif
		
	Endif
	
EndIf    

// Imprime termo de responsabilidade de multas do veiculo
if GetNewPar("MV_RESPMUL","1") == "1"
	If ExistBlock("VA610MUL")
		ExecBlock("VA610MUL",.f.,.f.,{"1"})
	Endif
Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_Delete| Autor ³ Andre Luis Almeida    ³ Data ³ 18/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Avaliacao de Veiculos Usados                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_Delete()
oAuxGetDados:aCols[oAuxGetDados:nAt,len(oAuxGetDados:aCols[oAuxGetDados:nAt])] := !oAuxGetDados:aCols[oAuxGetDados:nAt,len(oAuxGetDados:aCols[oAuxGetDados:nAt])]
oAuxGetDados:oBrowse:Refresh()
Return(.t.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_ATEABER| Autor ³ Andre Luis Almeida    ³ Data ³ 18/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Avaliacao de Veiculos Usados                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ATEABERTO(cNroVAZ)
Local cQuery  := ""
Local cNroVS9 := ""
Local nRecVS9 := 0
cQuery  := "SELECT VS9.R_E_C_N_O_ FROM "+RetSQLName("VS9")+" VS9 , "+RetSQLName("VV9")+" VV9 WHERE "
cQuery  += "VS9.VS9_FILIAL='"+xFilial("VS9")+"' AND VS9.VS9_TIPOPE='V' AND VS9.VS9_REFPAG='"+cNroVAZ+"' AND VS9.D_E_L_E_T_=' ' AND "
cQuery  += "VV9.VV9_FILIAL='"+xFilial("VV9")+"' AND VV9.VV9_NUMATE=VS9.VS9_NUMIDE AND VV9.VV9_STATUS NOT IN ('C','F') AND VV9.D_E_L_E_T_=' '"
nRecVS9 := FM_SQL(cQuery)
If nRecVS9 > 0
	DbSelectArea("VS9")
	DbGoTo(nRecVS9)
	cNroVS9 := Alltrim(VS9->VS9_NUMIDE) + " ( "+STR0039+": "+Alltrim(VS9->VS9_FILIAL)+" )"
EndIf
DbSelectArea("VAZ")
Return(cNroVS9)


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VEIA610FAS³ Autor ³Rafael Goncalves       ³ Data ³ 17/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Trata Inclusao de avaliacao fast - VIAMAR                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIA610FAS(cAlias,nReg,nOpc)
Local cCampo := ""
Private aCampos := {}

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VAZ")
cCampo := "VAZ_PLAVEI/VAZ_TIPAVA/VAZ_CODMAR/VAZ_CORVEI/VAZ_MODVEI/VAZ_FABMOD/VAZ_COMVEI/VAZ_QTDPOR/VAZ_KILVEI/VAZ_VALAVA/VAZ_ACEDIR/VAZ_ACEARC/VAZ_ACETRI/VAZ_ACEAUT/VAZ_APROVA/"

If ExistBlock("PE610FAST")
	cCampo := ExecBlock("PE610FAST",.f.,.f., { cCampo } )
Endif
cCampo += "/VAZ_CHASSI"

do While !eof() .and. x3_arquivo == "VAZ"
	If X3USO(x3_usado).and.cNivel>=x3_nivel .and. x3_campo$cCampo
		aadd(aCampos,x3_campo)
	EndIf
	DbSkip()
Enddo
aadd(aCampos,"NOUSER") //ESSE PARAMETRO NAO EXIBI CAMPOS DO USUARIO, SOMENTE SE ESTES EXISTIREM NO VETOR. - Rafael/Andre
AxInclui(cAlias,nReg,nOpc,aCampos)

DbSelectArea("VAZ")

return
