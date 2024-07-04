#Include "VEIVA600.CH"
#Include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVA600 | Autor ³ Andre Luis Almeida    ³ Data ³ 06/10/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro e Validacao do Chassi do Veiculo                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVA600()
Local cChassi := ""
Local cCampoP := ""
Local ni := 0
Local lRet  := .t.
Local lOk   := .f.
Local cProb := ""
Private lD := .f.
Private aCampos := {}
Private aRotina := { { STR0002 ,"AxPesqui" , 0 , 1 },;		// Pesquisar
                     { STR0003 ,"AxVisual" , 0 , 2 },; 		// Visualizar
                     { STR0004 ,"AxInclui" , 0 , 3 },;		// Incluir
                     { STR0011 ,"VEIVA600D", 0 , 3 },;		// Duplicar / Incluir
                     { STR0005 ,"AxAltera" , 0 , 4 },;		// Alterar
                     { STR0006 ,"AxDeleta" , 0 , 5 }}		// Excluir
Private cCadastro := OemToAnsi(STR0001)
If FunName() == "VEIVA600"
	mBrowse( 6, 1,22,75,"VZJ",,,,,,)
Else
	DbSelectArea("VZJ")
	DbSetOrder(1)
	If DbSeek( xFilial("VZJ") + M->VV1_CODMAR + M->VV1_MODVEI + M->VV1_FABMOD )
		lOk := .t.
	ElseIf DbSeek( xFilial("VZJ") + M->VV1_CODMAR + M->VV1_MODVEI + space(8) )
		lOk := .t.
	ElseIf DbSeek( xFilial("VZJ") + M->VV1_CODMAR + space(30) + M->VV1_FABMOD )
		lOk := .t.
	ElseIf DbSeek( xFilial("VZJ") + space(3) + M->VV1_MODVEI + M->VV1_FABMOD )
		lOk := .t.
	ElseIf DbSeek( xFilial("VZJ") + space(3) + M->VV1_MODVEI + space(8) )
		lOk := .t.
	ElseIf DbSeek( xFilial("VZJ") + space(33) + M->VV1_FABMOD )
		lOk := .t.
	ElseIf DbSeek( xFilial("VZJ") + M->VV1_CODMAR + space(38) )
		lOk := .t.
	ElseIf DbSeek( xFilial("VZJ") + space(41) )
		lOk := .t.
	EndIf
	If lOk
		cProb := ""
		cChassi := M->VV1_CHASSI
		For ni := 1 to len(cChassi)
			cCampoP := "VZJ->VZJ_POS"+strzero(ni,2)
			If ni <= 25 .and. !Empty(&cCampoP)
				If Alltrim(&cCampoP) == "#"
					If !Empty(substr(cChassi,ni,1))
						cProb += strzero(ni,2)+" / "
					EndIf
				Else
					If !(substr(cChassi,ni,1) $ Alltrim(&cCampoP))
						cProb += strzero(ni,2)+" / "
					EndIf
				EndIf
		   EndIf
		Next
		If !Empty(cProb) 
			cProb := left(cProb,len(cProb)-3)
			MsgAlert(STR0007+CHR(10)+CHR(10)+STR0008+cProb+CHR(10)+CHR(10)+STR0009,STR0010)
			lRet := .f.
		EndIf
	EndIf
EndIf
Return(lRet)

Function VEIVA600D() // Duplicar
	DbSelectArea("VZJ")
	If !Empty(VZJ->VZJ_FILIAL+VZJ->VZJ_CODMAR+VZJ->VZJ_MODVEI+VZJ->VZJ_FABMOD+VZJ->VZJ_POS01)
		lD := .t.
		DbSelectArea("SX3")
		dbseek("VZJ")
		aCampos := {}
		do While !eof() .and. x3_arquivo == "VZJ"
	   	If X3USO(x3_usado).and.cNivel>=x3_nivel
		       aadd(aCampos,x3_campo)
		   EndIf
		   dbskip()
		Enddo
		DbSelectArea("VZJ")
		AxInclui("VZJ",VZJ->(RecNo()),3,aCampos)
		lD := .f.
	Else
		MsgAlert(STR0012,STR0010)
	EndIf
Return()
