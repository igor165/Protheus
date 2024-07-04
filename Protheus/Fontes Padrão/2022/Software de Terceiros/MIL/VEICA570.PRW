// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 04     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#Include "VEICA570.ch"
#Include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ VEICA570 ³ Autor ³  Fabio                ³ Data ³ 17/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Pessoa de Contato                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICA570(cCodCli,cLojCli)

Local cFiltro     := ""
Default cCodCli   := ""
Default cLojCli   := ""
PRIVATE aCampos := {}
PRIVATE aMemos:={{"VC2_OBSMEM","VC2_OBSERV"}}
PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0001)
If !Empty(cCodCli)
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+cCodCli+Alltrim(cLojCli)))
	cFiltro  := " VC2_CODCLI='"+cCodCli+"' "+IIf(!Empty(cLojCli),"AND VC2_LOJA='"+cLojCli+"' ","")
EndIf

mBrowse( 6, 1,22,75,"VC2",,,,,,,,,,,,,,cFiltro)

Return

Function VEICA570A(cAlias,nReg,nOpc)
Local cNome := left(VC2->VC2_NOMCON+space(30),30)
Local lOk := .f.
Local cChave := VC2->VC2_CODCLI+VC2->VC2_LOJA
Local nRecNo := VC2->(RecNo())
DEFINE MSDIALOG oTelaNome FROM 000,000 TO 006,040 TITLE STR0008 OF oMainWnd
	@ 007,010 SAY STR0009 OF oTelaNome SIZE 20,10 PIXEL COLOR CLR_BLUE
	@ 006,030 MSGET oNome VAR cNome VALID !Empty(cNome) PICTURE "@!" SIZE 120,08 OF oTelaNome PIXEL COLOR CLR_BLUE 
	DEFINE SBUTTON FROM 025,065 TYPE 1 ACTION (lOk:=.t.,oTelaNome:End()) ENABLE OF oTelaNome WHEN !Empty(cNome)
ACTIVATE MSDIALOG oTelaNome CENTER
If lOk 
	DbSelectArea("VC2")
	DbSetOrder(1)
	If !DbSeek(xFilial("VC2")+cChave+Alltrim(cNome))
		DbSelectArea("VC2")
		DbGoTo(nRecNo)
		RecLock("VC2",.F.)
		  VC2->VC2_NOMCON := cNome
		MsUnLock()
	Else
		If VC2->(RecNo()) # nRecNo
			MSGAlert(STR0009+" "+Alltrim(cNome)+", "+STR0011+" "+left(cChave,6)+"-"+right(cChave,2)+"!",STR0010)
			DbSelectArea("VC2")
			DbGoTo(nRecNo)
			VEICA570A()
		EndIf
	EndIf
EndIf
Return

Static Function MenuDef()
Local aRotina := { { STR0002 ,"AxPesqui",0,1},;		// Pesquisar
                     { STR0003 ,"AxVisual",0,2},;		// Visualizar
                     { STR0004 ,"AxInclui",0,3},;		// Incluir
                     { STR0005 ,"AxAltera",0,4},;	// Alterar Dados
                     { STR0006 ,"VEICA570A",0,4},;	// Alterar Nome
                     { STR0007 ,"AxDeleta",0,5}}		// Excluir/Deleta
Return aRotina
