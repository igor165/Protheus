// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 26     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#Include "Protheus.ch"
#Include "OFIOA520.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOA520 | Autor ³ Otavio Favarelli      ³ Data ³ 13/05/09 ³±±
±±³          ³          | Autor ³ Rafael G. da Silva    ³      ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de Itens Alternativos                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA520()
Private aCampos 	:= {}
Private aRotina 	:= MenuDef()
Private cCadastro := STR0001 // Cadastro de Itens Alternativos

/////////////////////////////////////////////////////////////////
mBrowse( 6, 1,22,75,"VB1")
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_OA520PQ³ Autor ³ Rafael G. da Silva    ³ Data ³01/04/2009|±±
±±³          ³          ³ Autor ³ Otavio Favarelli      ³      ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta Cadastros Alternativo                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_OA520PQ()

Local lRetDiag := .f.
Private aConIte 	:= {}
Private cTexto 	:= STR0002 // Codigo
Private cGrupo		:= ""
Private cCodIte	:= ""
Private nCkPerg1 	:= 1
Private nCkPerg2	:= 1
Private cCodAlt	:= Space(TAMSX3("VB1_KEYALT")[1])
Private cDesMes	:= Space(TAMSX3("B1_DESC")[1])
Private cGruIte	:= Space(TAMSX3("B1_GRUPO")[1])
Private cIteMes	:= Space(TAMSX3("B1_CODITE")[1])
Private cCodMes	:= Space(TAMSX3("B1_COD")[1])
Private nOpca		:= 0

AAdd(aConIte,{"", "", "", "", ""})

DEFINE MSDIALOG oPesAlt FROM 000,000 TO 035,100 TITLE OemToAnsi(STR0003) OF oMainWnd // Pesquisa Cadastro Alternativo 

@ 002,002 TO 045,310 LABEL ("") OF oPesAlt PIXEL COLOR CLR_BLUE

@ 012,005 RADIO oRadio1 VAR nCkPerg1 3D SIZE 45,10 PROMPT;
OemToAnsi(STR0004), OemToAnsi(STR0005); // Alternativo, Mestre
OF oPesAlt PIXEL ON CHANGE ( Processa({ || FS_MOSTRATELA(nCkPerg1) }))

// Se for selecionado o Radio Alternativo
@ 013,055 SAY cTexto SIZE 80,08 OF oPesAlt PIXEL COLOR CLR_BLUE
@ 012,074 MSGET oCodAlt VAR cCodAlt PICTURE "@!" F3 "VB1B" SIZE 125,08 OF oPesAlt PIXEL COLOR CLR_BLUE

// Se for selecionado o Radio Mestre
@ 009,055 RADIO oRadio2 VAR nCkPerg2 3D SIZE 51,10 PROMPT;
OemToAnsi(STR0002), OemToAnsi(STR0006), OemToAnsi(STR0007); // Codigo, Grupo/ Cod. Item, Descricao
OF oPesAlt PIXEL ON CHANGE ( Processa({ || FS_MOSTRATELA(nCkPerg2+2) }))

// Se for selecionado Codigo
@ 009,110 MSGET oCodMes VAR cCodMes PICTURE "@!" F3 "SB1" SIZE 058,08 OF oPesAlt PIXEL COLOR CLR_BLUE

// Se for selecionado Grupo
@ 019,108 SAY cGrupo SIZE 80,08 OF oPesAlt PIXEL COLOR CLR_BLUE
@ 018,125 MSGET oGruIte VAR cGruIte PICTURE "@!" F3 "SBM" VALID cIteMes := Space(TAMSX3("B1_CODITE")[1]) SIZE 010,08 OF oPesAlt PIXEL COLOR CLR_BLUE

@ 019,170 SAY cCodIte SIZE 80,08 OF oPesAlt PIXEL COLOR CLR_BLUE
@ 018,195 MSGET oIteMes VAR cIteMes PICTURE "@!" F3 "B16" SIZE 100,08 OF oPesAlt PIXEL COLOR CLR_BLUE

// Se for selecionado Descricao
@ 028,110 MSGET oDesMes VAR cDesMes PICTURE "@!" SIZE 095,08 OF oPesAlt PIXEL COLOR CLR_BLUE 

@ 002,320 BUTTON oFiltrar PROMPT OemToAnsi(STR0008)       OF oPesAlt SIZE 55,10 PIXEL ACTION (Processa( {|| FS_FILTRA() } )) // PESQUISAR

@ 049,002 LISTBOX olBox1 FIELDS HEADER 	OemToAnsi(STR0009),; // Cod. Alternativo
													 	OemToAnsi(STR0010),; // Cod. Mestre
														OemToAnsi(STR0011),; // Grupo
														OemToAnsi(STR0012),; // Cod. Item
														OemToAnsi(STR0007);  // Descricao
														COLSIZES 50,50,20,60,65 SIZE 394,215 OF oPesAlt PIXEL ON DBLCLICK (nOpca := olBox1:nAt, FS_POS(), lRetDiag := .f., oPesAlt:END())
olBox1:SetArray(aConIte)
olBox1:bLine := { || {  aConIte[olBox1:nAt,1] ,;
								aConIte[olBox1:nAt,2] ,;
								aConIte[olBox1:nAt,3] ,;
								aConIte[olBox1:nAt,4] ,;
								aConIte[olBox1:nAt,5] }}

@ 014,320 BUTTON oSair      PROMPT OemToAnsi(STR0013)OF oPesAlt SIZE 55,10 PIXEL  ACTION (oPesAlt:End()) // SAIR

oRadio2:lVisible 	:= .f.
oCodMes:lVisible := .f.
oGruIte:lVisible 	:= .f.
oIteMes:lVisible := .f.
oDesMes:lVisible := .f.



ACTIVATE MSDIALOG oPesAlt CENTER

RETURN lRetDiag


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_MOSTRATELA ³ Autor ³ Rafael G. da Silva  ³ Data ³01/04/09|±±
±±³          ³              ³ Autor ³ Otavio Favarelli    ³      ³        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MOSTRATELA(nTip)

cTexto 	:= ""
cGrupo 	:= ""
cCodIte	:= ""
aConIte	:= {}
AAdd(aConIte,{"","","","",""})

olBox1:SetArray(aConIte)
olBox1:bLine := { || {  aConIte[olBox1:nAt,1] ,;
								aConIte[olBox1:nAt,2] ,;
								aConIte[olBox1:nAt,3] ,;
								aConIte[olBox1:nAt,4] ,;
								aConIte[olBox1:nAt,5] }}
olBox1:SetFocus()
olBox1:Refresh()

cCodAlt	:= Space(TAMSX3("VB1_KEYALT")[1])
cDesMes	:= Space(TAMSX3("B1_DESC")[1])
cGruIte	:= Space(TAMSX3("B1_GRUPO")[1])
cIteMes	:= Space(TAMSX3("B1_CODITE")[1])
cCodMes	:= Space(TAMSX3("B1_COD")[1])

oCodAlt:lVisible 	:= .f.
oRadio2:lVisible 	:= .f.
oCodMes:lVisible := .f.
oGruIte:lVisible 	:= .f.
oIteMes:lVisible := .f.
oDesMes:lVisible := .f.

If nTip == 1
	cTexto := STR0002 // Codigo
	oCodAlt:lVisible := .t.
ElseIf nTip == 2
	nCkPerg2 := 1	
	oRadio2:lVisible 	:= .t.
	oCodMes:lVisible := .t.
ElseIf nTip == 3
	oRadio2:lVisible 	:= .t.
	oCodMes:lVisible := .t.
ElseIf nTip == 4
	oRadio2:lVisible 	:= .t.	
	oGruIte:lVisible 	:= .t.
	oIteMes:lVisible := .t.
	cGrupo 	:= STR0011 // Grupo
	cCodIte	:= STR0012 // Cod. Item
ElseIf nTip == 5
	oRadio2:lVisible 	:= .t.
	oDesMes:lVisible := .t.
EndIf

oRadio1:Refresh()
oRadio2:Refresh()
oCodMes:Refresh()
oGruIte:Refresh()
oIteMes:Refresh()
oDesMes:Refresh()
oPesAlt:Refresh()

If nTip == 1
	oCodAlt:SetFocus()		
ElseIf nTip == 2
	oRadio2:SetFocus()
	oCodMes:SetFocus()
ElseIf nTip == 3
	oRadio2:SetFocus()
	oCodMes:SetFocus()
ElseIf nTip == 4
	oRadio2:SetFocus()	
	oGruIte:SetFocus()		
ElseIf nTip == 5
	oRadio2:SetFocus()
	oDesMes:SetFocus()
EndIf 

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_FILTRA ³ Autor ³ Rafael G. da Silva    ³ Data ³01/04/2009|±±
±±³          ³          ³ Autor ³ Otavio Favarelli      ³      ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRA()

Local cQuery  	:= ""
Local cQSB1 	:= "SQLSB1"
Local nPos

If nCkPerg1 == 1
	If !Vazio(cCodAlt)
		cQuery := "SELECT VB1.VB1_KEYALT, VB1.VB1_COD, SB1.B1_GRUPO, SB1.B1_CODITE, SB1.B1_DESC FROM " + RetSqlName("SB1")+" SB1"
		cQuery += " JOIN "  + RetSqlName("VB1")+" VB1 ON SB1.B1_COD = VB1.VB1_COD"
	  	cQuery += " WHERE VB1.VB1_KEYALT LIKE '%" + AllTrim(cCodAlt) + "%' AND VB1.D_E_L_E_T_= ' ' AND SB1.D_E_L_E_T_= ' '"
		cQuery += " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND VB1.VB1_FILIAL = '" + xFilial("VB1") + "' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQSB1, .F., .T. )
		
		If (cQSB1)->(Eof())
			MsgInfo(STR0015,STR0016) // Nao foram encontrados registros para esta consulta!, Atencao!
			oCodAlt:SetFocus()
			(cQSB1)->(DbCloseArea())
			Return (.f.)
		EndIf
		
		aConIte := {}
		While !(cQSB1)->(Eof())
			AAdd(aConIte,{(cQSB1)->(VB1_KEYALT), (cQSB1)->(VB1_COD), (cQSB1)->(B1_GRUPO), (cQSB1)->(B1_CODITE), (cQSB1)->(B1_DESC)})
			(cQSB1)->(DbSkip())
		EndDo
		(cQSB1)->(DbCloseArea())
		dbSelectArea("VB1")
		
		olBox1:SetArray(aConIte)
		olBox1:bLine := { || {  aConIte[olBox1:nAt,1] ,;
								aConIte[olBox1:nAt,2] ,;
								aConIte[olBox1:nAt,3] ,;
								aConIte[olBox1:nAt,4] ,;
								aConIte[olBox1:nAt,5] }}
	
		olBox1:Refresh()
			
	EndIf
ElseIf nCkPerg1 == 2 .and. nCkPerg2 == 1
	If !Vazio(cCodMes)			
		cQuery := "SELECT VB1.VB1_KEYALT, VB1.VB1_COD, SB1.B1_GRUPO, SB1.B1_CODITE, SB1.B1_DESC FROM " + RetSqlName("SB1")+" SB1"
	 	cQuery += " JOIN "  + RetSqlName("VB1")+" VB1 ON VB1.VB1_COD = SB1.B1_COD"
		cQuery += " WHERE VB1.VB1_COD = '" + cCodMes + "' AND SB1.D_E_L_E_T_= ' ' AND VB1.D_E_L_E_T_= ' '"
		cQuery += " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND VB1.VB1_FILIAL = '" + xFilial("VB1") + "' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQSB1, .F., .T. )

		If (cQSB1)->(Eof())
			MsgInfo(STR0015,STR0016) // Nao foram encontrados registros para esta consulta!, Atencao!
			oCodAlt:SetFocus()
			(cQSB1)->(DbCloseArea())
			Return (.f.)
		EndIf
		
		aConIte := {}
		While !(cQSB1)->(Eof())
			AAdd(aConIte,{(cQSB1)->(VB1_KEYALT), (cQSB1)->(VB1_COD), (cQSB1)->(B1_GRUPO), (cQSB1)->(B1_CODITE), (cQSB1)->(B1_DESC)})
			(cQSB1)->(DbSkip())
		EndDo
		(cQSB1)->(DbCloseArea())
		dbSelectArea("VB1")
		
		olBox1:SetArray(aConIte)
		olBox1:bLine := { || {  aConIte[olBox1:nAt,1] ,;
								aConIte[olBox1:nAt,2] ,;
								aConIte[olBox1:nAt,3] ,;
								aConIte[olBox1:nAt,4] ,;
								aConIte[olBox1:nAt,5] }}
		olBox1:Refresh()
	EndIf
ElseIf nCkPerg1 == 2 .and. nCkPerg2 == 2
	If !Vazio(cIteMes)		
		cQuery := "SELECT VB1.VB1_KEYALT, VB1.VB1_COD, SB1.B1_GRUPO, SB1.B1_CODITE, SB1.B1_DESC FROM " + RetSqlName("SB1")+" SB1"
		cQuery += " JOIN "  + RetSqlName("VB1")+" VB1 ON VB1.VB1_COD = SB1.B1_COD"
		cQuery += " WHERE SB1.B1_GRUPO = '" + AllTrim(cGruIte) + "' AND SB1.B1_CODITE = '" + AllTrim(cIteMes) + "'"
		cQuery += " AND SB1.D_E_L_E_T_= ' ' AND VB1.D_E_L_E_T_= ' '"
		cQuery += " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND VB1.VB1_FILIAL = '" + xFilial("VB1") + "' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQSB1, .F., .T. )

		If (cQSB1)->(Eof())
			MsgInfo(STR0015,STR0016) // Nao foram encontrados registros para esta consulta!, Atencao!
			oCodAlt:SetFocus()
			(cQSB1)->(DbCloseArea())
			Return (.f.)
		EndIf
		
		aConIte := {}
		While !(cQSB1)->(Eof())
			AAdd(aConIte,{(cQSB1)->(VB1_KEYALT), (cQSB1)->(VB1_COD), (cQSB1)->(B1_GRUPO), (cQSB1)->(B1_CODITE), (cQSB1)->(B1_DESC)})
			(cQSB1)->(DbSkip())
		EndDo
		(cQSB1)->(DbCloseArea())
		dbSelectArea("VB1")
		
		olBox1:SetArray(aConIte)
		olBox1:bLine := { || {  aConIte[olBox1:nAt,1] ,;
								aConIte[olBox1:nAt,2] ,;
								aConIte[olBox1:nAt,3] ,;
								aConIte[olBox1:nAt,4] ,;
								aConIte[olBox1:nAt,5] }}
		olBox1:Refresh()
	EndIf	
ElseIf nCkPerg1 == 2 .and. nCkPerg2 == 3
	If !Vazio(cDesMes)	
		cQuery := "SELECT VB1.VB1_KEYALT, VB1.VB1_COD, SB1.B1_GRUPO, SB1.B1_CODITE, SB1.B1_DESC FROM " + RetSqlName("SB1")+" SB1"
   		cQuery += " JOIN "  + RetSqlName("VB1")+" VB1 ON VB1.VB1_COD = SB1.B1_COD"
	   	cQuery += " WHERE VB1.VB1_COD = SB1.B1_COD AND SB1.B1_DESC LIKE '%" + AllTrim(cDesMes) + "%' AND SB1.D_E_L_E_T_= ' ' AND VB1.D_E_L_E_T_= ' '"
		cQuery += " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND VB1.VB1_FILIAL = '" + xFilial("VB1") + "' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQSB1, .F., .T. )

		If (cQSB1)->(Eof())
			MsgInfo(STR0015,STR0016) // Nao foram encontrados registros para esta consulta!, Atencao!
			oCodAlt:SetFocus()
			(cQSB1)->(DbCloseArea())
			Return (.f.)
		EndIf
		
		aConIte := {}
		While !(cQSB1)->(Eof())
			AAdd(aConIte,{(cQSB1)->(VB1_KEYALT), (cQSB1)->(VB1_COD), (cQSB1)->(B1_GRUPO), (cQSB1)->(B1_CODITE), (cQSB1)->(B1_DESC)})
			(cQSB1)->(DbSkip())
		EndDo
		(cQSB1)->(DbCloseArea())
		dbSelectArea("VB1")
		
		olBox1:SetArray(aConIte)
		olBox1:bLine := { || {  aConIte[olBox1:nAt,1] ,;
								aConIte[olBox1:nAt,2] ,;
								aConIte[olBox1:nAt,3] ,;
								aConIte[olBox1:nAt,4] ,;
								aConIte[olBox1:nAt,5] }}

		olBox1:Refresh()
		EndIf		
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_POS      ³ Autor ³ Rafael G. da Silva    ³ Data ³01/04/09|±±
±±³          ³            ³ Autor ³ Otavio Favarelli      ³      ³        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_POS()

If nOpca > 0		
	DbSelectArea("VB1")
	DbSetOrder(1)
	DbSeek(xFilial("VB1")+aConIte[nOpca,1])
EndIf

Return 					

//////////////////////////////////////////////////////
Static Function MenuDef()
Local aRotina := { 	{ 	STR0017		,"AxPesqui"		, 0 , 1},;	// Pesquisar
					{ 	STR0018		,"FS_OA520PQ"	, 0 , 1},;	// Pesquisar
                   	{ 	STR0019		,"AXVISUAL"		, 0 , 2},;	// Visualizar
                    { 	STR0020 	,"AXINCLUI"		, 0 , 3},;	// Incluir
					{	STR0021		,"AxAltera"		, 0 , 4},;	// Alterar
                    { 	STR0022 	,"AXDELETA"		, 0 , 5}}	// Excluir

Return aRotina


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OFIOA520VLD ³ Autor ³ Rafael G. da Silva    ³ Data ³01/04/09|±±
±±³          ³            ³ Autor ³ Otavio Favarelli      ³      ³        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA520VLD()
Local lRet     := .t.
Local cAreaAnt := GetArea()
Local cQuery   := ""
Local cQAlVB1  := "SQLVB1"
DbSelectArea("SB1")
If ReadVar() == "M->VB1_COD"
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+M->VB1_COD)
	If SB1->B1_GRUPO $ ( left(GetMv("MV_GRUVEI")+space(4),4)+"/"+left(GetNewPar("MV_GRUSRV","SRVC")+space(4),4) )
		MsgInfo(STR0023,STR0016) // O produto escolhido nao e uma peca!, Atencao!
		lRet := .f.
	EndIf 
	//RAFAEL
	cQuery := "SELECT COUNT(VB1.VB1_KEYALT) AS QTDE FROM "+RetSqlName("VB1")+" VB1 WHERE VB1.VB1_FILIAL='"+xFilial("VB1")+"' AND "
	cQuery += "VB1.VB1_COD='"+left(M->VB1_COD+space(40),TAMSX3("VB1_COD")[1])+"' AND "
	cQuery += "VB1.VB1_KEYALT='"+left(M->VB1_KEYALT+space(30),TAMSX3("VB1_KEYALT")[1])+"' AND VB1.D_E_L_E_T_=' '"
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVB1 , .F., .T. )
	If ( cQAlVB1 )->( QTDE ) > 0
		MsgInfo(STR0025,STR0016) // "Codigo Alternativo já Relacionado a este item", Atencao!
		lRet := .f.
	EndIf
	( cQAlVB1 )->( dbCloseArea() )
	DbSelectArea("SB1")
	//
    //FNC 27323 - PERENCHER OS CAMPOS VIRTUAIS AO INFORMAR O CODIGO DO ITEM MANUALMENTE
    M->VB1_GRUPO  := SB1->B1_GRUPO
    M->VB1_CODITE := SB1->B1_CODITE
    M->VB1_DESC	  := SB1->B1_DESC
	//fim
EndIf 

RestArea(cAreaAnt)
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOA520C| Autor ³ Otavio Favarelli      ³ Data ³ 18/05/09 ³±±
±±³          ³          | Autor ³ Rafael G. da Silva    ³      ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de Itens Alternativos                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA520C()

Local cAreaAnt		:= GetArea()
Local cQuery1 		:= ""
Local cQuery2  		:= ""
Local cQuery3 		:= ""
Local cQuery4  		:= ""
Local cQVB11		:= "SQLVB11"
Local cQVB12		:= "SQLVB12"
Local cQVB1SB11		:= "SQLVB1SB11"
Local cQVB1SB12		:= "SQLVB1SB12" 
Local aConVB11		:= {}
Local aConVB12		:= {}
Local aConVB1SB11	:= {}
Local aConVB1SB12	:= {}
Local nPos			:= 0 
Local nOpcao := 1	
Local lVB1MARPEC    := VB1->(FieldPos("VB1_MARPEC")) > 0
Local lContinua		:= .T.

If ExistBlock("PEOF520C")
	lContinua := ExecBlock("PEOF520C",.f.,.f.)
EndIf

If FunName() == "OFIOM110" .or.  FunName() == "OFIXA011"  .or.  FunName() == "OFIXA018" 
	nOpcao := 1    

	//CI 011134 altera PEOF520C para o usuário controlar se exibe a tela ou não
	If !lContinua
		Return .T.
	EndIf	

	If Vazio(M->VS3_CODITE)  .and. !(FM_PILHA("OFIXC001"))
		Return .T.
	EndIf

	// Tentar achar o CODITE exato antes de pesquisar/apresentar os itens alternativos
	If OA5200011_ItemExato( M->VS3_GRUITE , M->VS3_CODITE ) 
		Return .T.
	EndIf

	cQuery1 := "SELECT VB1.VB1_KEYALT, SB1.B1_GRUPO, SB1.B1_CODITE, SB1.B1_COD , SB1.B1_DESC "
	if lVB1MARPEC
		cQuery1 += ", VB1.VB1_MARPEC "
	Endif	
	cQuery1 +=  " FROM " + RetSqlName("VB1") + " VB1 "
	cQuery1 +=  	" JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = VB1.VB1_COD AND SB1.D_E_L_E_T_ = ' '"
	cQuery1 += " WHERE VB1.VB1_FILIAL = '" + xFilial("VB1") + "'"
	cQuery1 +=   " AND VB1.VB1_KEYALT LIKE '" + AllTrim(M->VS3_CODITE) + "%'"
	cQuery1 +=   " AND VB1.D_E_L_E_T_= ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery1 ), cQVB11, .F., .T. )
	
	While !(cQVB11)->(Eof())
		SB1->(DBSetOrder(1))
		SB1->(DBSeek(xFilial("SB1") + ( cQVB11 )->( B1_COD ) ) )
		if lVB1MARPEC
			VQS->(DBSetOrder(1))
			VQS->(DBSeek(xFilial("VQS") + ( cQVB11 )->( VB1_MARPEC ) ) )
			AAdd(aConVB11,{(cQVB11)->(VB1_KEYALT), (cQVB11)->(B1_GRUPO), (cQVB11)->(B1_CODITE), (cQVB11)->(B1_DESC), (cQVB11)->(B1_COD), OX001SLDPC(xFilial("SB2")+SB1->B1_COD+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")),(cQVB11)->(VB1_MARPEC),VQS->VQS_DESCRI})
		Else
			AAdd(aConVB11,{(cQVB11)->(VB1_KEYALT), (cQVB11)->(B1_GRUPO), (cQVB11)->(B1_CODITE), (cQVB11)->(B1_DESC), (cQVB11)->(B1_COD), OX001SLDPC(xFilial("SB2")+SB1->B1_COD+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"))})
		Endif
		(cQVB11)->(DbSkip())
	EndDo
	(cQVB11)->(DbCloseArea())
	if FunName() == "OFIXA011" .and. !(FM_PILHA("OFIXC001"))
		M->VS3_KEYALT := space(TamSX3("VS3_KEYALT")[1])
		oGetPecas:aCols[oGetPecas:nAt,fg_posvar("VS3_KEYALT","aHeaderP")] := space(TamSX3("VS3_KEYALT")[1])
	endif
	If Len(aConVB11) >= 1 //.and. nOpcao<>2
		RestArea(cAreaAnt)
		DEFINE MSDIALOG oDesVB1 FROM 000,000 TO 015,095 TITLE OemToAnsi(STR0014) OF oMainWnd // Cadastros Alternativos Encontrados  		
		olBox2 := TWBrowse():New(000, 000, 376, 115,,,,oDesVB1,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		olBox2:nAt := 1
		olBox2:SetArray(aConVB11)
		olBox2:addColumn( TCColumn():New(STR0009					, { || aConVB11[olBox2:nAt,1] }								,,,,"LEFT" ,45,.F.,.F.,,,,.F.,) )
		olBox2:addColumn( TCColumn():New(STR0011					, { || aConVB11[olBox2:nAt,2] }								,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) )
		olBox2:addColumn( TCColumn():New(STR0012					, { || aConVB11[olBox2:nAt,3] }								,,,,"LEFT" ,50,.F.,.F.,,,,.F.,) )
		olBox2:addColumn( TCColumn():New(STR0007					, { || aConVB11[olBox2:nAt,4] }								,,,,"LEFT" ,65,.F.,.F.,,,,.F.,) )
		if lVB1MARPEC
			olBox2:addColumn( TCColumn():New(STR0027					, { || aConVB11[olBox2:nAt,7] }								,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) )
			olBox2:addColumn( TCColumn():New(STR0028					, { || aConVB11[olBox2:nAt,8] }								,,,,"LEFT" ,70,.F.,.F.,,,,.F.,) )
		Endif
		olBox2:addColumn( TCColumn():New(STR0026					, { || FG_AlinVlrs(Transform(aConVB11[olBox2:nAt,6],"@E 9,999,999.99")) }								,,,,"LEFT" ,15,.F.,.F.,,,,.F.,) )
		olBox2:bLDblClick := { || (nPos := olBox2:nAt, oDesVB1:END()) }



		ACTIVATE MSDIALOG oDesVB1 CENTER
		
		if nPos == 0
			return .f.
		endif

		If nPos != 0		
			M->VS3_KEYALT := aConVB11[nPos,1]
			M->VS3_GRUITE := aConVB11[nPos,2]
			M->VS3_CODITE := aConVB11[nPos,3]		
			if FunName() == "OFIXA011"   .and. !(FM_PILHA("OFIXC001"))
				oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_KEYALT")] := aConVB11[nPos,1]
				oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_GRUITE")] := aConVB11[nPos,2]
				oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_CODITE")] := aConVB11[nPos,3]
				// Quando trocar o item deve deixar a TES em branco para recarregar com a TES do novo item informado
				oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_CODTES")] := Space(TAMSX3("VS3_CODTES")[1])
				M->VS3_CODTES := Space(TAMSX3("VS3_CODTES")[1])
			else
				aCols[n,FG_POSVAR("VS3_KEYALT")] := aConVB11[nPos,1]
				aCols[n,FG_POSVAR("VS3_GRUITE")] := aConVB11[nPos,2]
				aCols[n,FG_POSVAR("VS3_CODITE")] := aConVB11[nPos,3]
				// Quando trocar o item deve deixar a TES em branco para recarregar com a TES do novo item informado
				aCols[n,FG_POSVAR("VS3_CODTES")] := Space(TAMSX3("VS3_CODTES")[1])
				M->VS3_CODTES := Space(TAMSX3("VS3_CODTES")[1])
			endif
		EndIf						

	ElseIf Vazio(M->VS3_KEYALT)
		cQuery2 := "SELECT VB1.VB1_KEYALT, SB1.B1_GRUPO, SB1.B1_CODITE, SB1.B1_COD , SB1.B1_DESC "
		cQuery2 +=  " FROM " + RetSqlName("SB1") + " SB1"
		cQuery2 += 		" JOIN " + RetSqlName("VB1") + " VB1 ON VB1.VB1_FILIAL = '" + xFilial("VB1") + "' AND VB1.VB1_COD = SB1.B1_COD AND VB1.D_E_L_E_T_ = ' '"
		cQuery2 += " WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
		cQuery2 += " AND (SB1.B1_CODITE = '" + AllTrim(M->VS3_CODITE) + "' OR SB1.B1_COD = '" + AllTrim(M->VS3_CODITE) + "')"
		cQuery2 += " AND SB1.D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery2 ), cQVB1SB11, .F., .T. )
		While !(cQVB1SB11)->(Eof())
			AAdd(aConVB1SB11,{(cQVB1SB11)->(VB1_KEYALT), (cQVB1SB11)->(B1_GRUPO), (cQVB1SB11)->(B1_CODITE), (cQVB1SB11)->(B1_DESC) , (cQVB1SB11)->(B1_COD)})
			(cQVB1SB11)->(DbSkip())
		EndDo
		(cQVB1SB11)->(DbCloseArea())
		If Len(aConVB1SB11) == 1
			M->VS3_KEYALT := aConVB1SB11[1,1]
			M->VS3_GRUITE := aConVB1SB11[1,2]
			M->VS3_CODITE := aConVB1SB11[1,3]		
			if FunName() == "OFIXA011"  .and. !(FM_PILHA("OFIXC001"))
				oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_KEYALT")] := aConVB1SB11[1,1]
				oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_GRUITE")] := aConVB1SB11[1,2]
				oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_CODITE")] := aConVB1SB11[1,3]
				// Quando trocar o item deve deixar a TES em branco para recarregar com a TES do novo item informado
				oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_CODTES")] := Space(TAMSX3("VS3_CODTES")[1])
				M->VS3_CODTES := Space(TAMSX3("VS3_CODTES")[1])
            else
				aCols[n,FG_POSVAR("VS3_KEYALT")] := aConVB1SB11[1,1]
				aCols[n,FG_POSVAR("VS3_GRUITE")] := aConVB1SB11[1,2]
				aCols[n,FG_POSVAR("VS3_CODITE")] := aConVB1SB11[1,3]
				// Quando trocar o item deve deixar a TES em branco para recarregar com a TES do novo item informado
				aCols[n,FG_POSVAR("VS3_CODTES")] := Space(TAMSX3("VS3_CODTES")[1])
				M->VS3_CODTES := Space(TAMSX3("VS3_CODTES")[1])
			endif
			RestArea(cAreaAnt)
			
		ElseIf Len(aConVB1SB11) < 1
			M->VS3_KEYALT 							:= Space(TAMSX3("VS3_KEYALT")[1])	
		   	if FunName() == "OFIXA011"   .and. !(FM_PILHA("OFIXC001"))
				oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_KEYALT")] := Space(TAMSX3("VS3_KEYALT")[1])		
			else
				aCols[n,FG_POSVAR("VS3_KEYALT")]	:= Space(TAMSX3("VS3_KEYALT")[1])		
			endif

			RestArea(cAreaAnt)
		EndIf
	
	Else 
	   	if FunName() != "OFIXA011"   .and. !(FM_PILHA("OFIXC001"))
			M->VS3_KEYALT 						:= Space(TAMSX3("VS3_KEYALT")[1])	
			aCols[n,FG_POSVAR("VS3_KEYALT")] 	:= Space(TAMSX3("VS3_KEYALT")[1])
		endif
	
	EndIf

ElseIf FM_PILHA("OFIA310")
	Return .t.

ElseIf FM_PILHA("OFIOM020")

	If Vazio(M->VO3_CODITE)
		Return .t.
	EndIf

	// Tentar achar o CODITE exato antes de pesquisar/apresentar os itens alternativos
	If OA5200011_ItemExato( M->VO3_GRUITE , M->VO3_CODITE )
		Return .t.
	EndIf

	cQuery3 := "SELECT VB1.VB1_KEYALT, SB1.B1_GRUPO, SB1.B1_CODITE, SB1.B1_COD , SB1.B1_DESC "
	cQuery3 +=  " FROM " + RetSqlName("VB1") + " VB1 "
	cQuery3 +=  	" JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = VB1.VB1_COD AND SB1.D_E_L_E_T_ = ' '"
	cQuery3 += " WHERE VB1.VB1_FILIAL = '" + xFilial("VB1") + "'"
	cQuery3 +=   " AND VB1.VB1_KEYALT LIKE '" + AllTrim(M->VO3_CODITE) + "%'"
	cQuery3 +=   " AND VB1.D_E_L_E_T_= ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery3 ), cQVB12, .F., .T. )
	While !(cQVB12)->(Eof())
		AAdd(aConVB12,{(cQVB12)->(VB1_KEYALT), (cQVB12)->(B1_GRUPO), (cQVB12)->(B1_CODITE), (cQVB12)->(B1_DESC),(cQVB12)->(B1_COD)})
		(cQVB12)->(DbSkip())
	EndDo
	(cQVB12)->(DbCloseArea())
		
	If Len(aConVB12) >= 1 //.and. nOpcao<>2
		RestArea(cAreaAnt) 		
		DEFINE MSDIALOG oDesVB1 FROM 000,000 TO 015,080 TITLE OemToAnsi(STR0014) OF oMainWnd  // Cadastros Alternativos Encontrados
		@ 001,001 LISTBOX olBox2 FIELDS HEADER ;
			STR0009,; // Codigo Alternativo
			STR0011,; // Grupo
			STR0012,; // Cod. Item
			STR0007;  // Descricao
			COLSIZES 50,20,60,65 SIZE 315,111 OF oDesVB1 PIXEL ON DBLCLICK (nPos := olBox2:nAt, oDesVB1:END())
		olBox2:SetArray(aConVB12)
		olBox2:bLine := { || {  aConVB12[olBox2:nAt,1] ,;
								aConVB12[olBox2:nAt,2] ,;
								aConVB12[olBox2:nAt,3] ,;
								aConVB12[olBox2:nAt,4] }}
		ACTIVATE MSDIALOG oDesVB1 CENTER
		If nPos != 0
			aCols[n,FG_POSVAR("VO3_KEYALT")] := M->VO3_KEYALT := aConVB12[nPos,1]
			aCols[n,FG_POSVAR("VO3_GRUITE")] := M->VO3_GRUITE := aConVB12[nPos,2]
			aCols[n,FG_POSVAR("VO3_CODITE")] := M->VO3_CODITE := aConVB12[nPos,3]	

			// Quando trocar o item deve deixar a TES em branco para recarregar com a TES do novo item informado
			aCols[n,FG_POSVAR("VO3_CODTES")] := Space(TAMSX3("VO3_CODTES")[1])
			M->VO3_CODTES := Space(TAMSX3("VO3_CODTES")[1])
		else
			return .f.
		EndIf
		
	ElseIf Vazio(M->VO3_KEYALT)

		cQuery4 := "SELECT VB1.VB1_KEYALT, SB1.B1_GRUPO, SB1.B1_CODITE, SB1.B1_COD , SB1.B1_DESC "
		cQuery4 +=  " FROM " + RetSqlName("SB1") + " SB1"
		cQuery4 += 		" JOIN " + RetSqlName("VB1") + " VB1 ON VB1.VB1_FILIAL = '" + xFilial("VB1") + "' AND VB1.VB1_COD = SB1.B1_COD AND VB1.D_E_L_E_T_ = ' '"
		cQuery4 += " WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
		cQuery4 += " AND (SB1.B1_CODITE = '" + AllTrim(M->VO3_CODITE) + "' OR SB1.B1_COD = '" + AllTrim(M->VO3_CODITE) + "')"
		cQuery4 += " AND SB1.D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery4 ), cQVB1SB12, .F., .T. )
		While !(cQVB1SB12)->(Eof())
			AAdd(aConVB1SB12,{(cQVB1SB12)->(VB1_KEYALT), (cQVB1SB12)->(B1_GRUPO), (cQVB1SB12)->(B1_CODITE), (cQVB1SB12)->(B1_DESC), (cQVB1SB12)->(B1_COD)})
			(cQVB1SB12)->(DbSkip())
		EndDo
		(cQVB1SB12)->(DbCloseArea())
		If Len(aConVB1SB12) == 1
			aCols[n,FG_POSVAR("VO3_KEYALT")] := M->VO3_KEYALT := aConVB1SB12[1,1]
			aCols[n,FG_POSVAR("VO3_GRUITE")] := M->VO3_GRUITE := aConVB1SB12[1,2]
			aCols[n,FG_POSVAR("VO3_CODITE")] := M->VO3_CODITE := aConVB1SB12[1,3]

			// Quando trocar o item deve deixar a TES em branco para recarregar com a TES do novo item informado
			aCols[n,FG_POSVAR("VO3_CODTES")] := Space(TAMSX3("VO3_CODTES")[1])
			M->VO3_CODTES := Space(TAMSX3("VO3_CODTES")[1])
			RestArea(cAreaAnt)
		EndIf
	Else
		aCols[n,FG_POSVAR("VO3_KEYALT")] := M->VO3_KEYALT := Space(TAMSX3("VO3_KEYALT")[1])
	EndIf

EndIf

Return .T.

/*/{Protheus.doc} OA5200011_ItemExato
	Verifica se existe este CODITE exato no SB1
	
	@author Andre Luis Almeida
	@since 20/05/2021
/*/
Static Function OA5200011_ItemExato( _cGrupo , _cCodIte )
Local lRet   := .f.
Local cQuery := "SELECT COUNT(*)"
cQuery += "  FROM " + RetSqlName("SB1")
cQuery += " WHERE B1_FILIAL = '" + xFilial("SB1") + "'"
If !Empty(_cGrupo)
	cQuery += "   AND B1_GRUPO = '"+_cGrupo+"'"
EndIf
cQuery += "   AND B1_CODITE = '" + AllTrim(_cCodIte) + "'"
cQuery += "   AND D_E_L_E_T_= ' '"
If FM_SQL(cQuery) > 0
	lRet := .t.
EndIf
Return lRet