#INCLUDE "veiva000.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIVA000 ³ Autor ³  Manoel               ³ Data ³ 14/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Precos por Modelo                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVA000

PRIVATE cCadastro := OemToAnsi(STR0001) //"Precos por Modelo"
PRIVATE aCampos := {}
PRIVATE aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"VVP")

Return


********************************
Function Vei000V(cAlias,nReg,nOpc)

CpoVei000()
AxVisual(cAlias,nReg,nOpc,aCampos)

Return


********************************
Function Vei000I(cAlias,nReg,nOpc)

CpoVei000()
AxInclui(cAlias,nReg,nOpc,aCampos)

Return

********************************
Function Vei000A(cAlias,nReg,nOpc)

CpoVei000()
nOpca1 := AxAltera(cAlias,nReg,nOpc,aCampos)

if nOpca1 == 1
   RecLock("VVP",.f.)
   VVP->VVP_DATUSU := dTos(dDataBase) + "-" + __cUserID
   MsUnlock()
Endif

Return

********************
Function CpoVei000()

DbSelectArea("SX3")
dbseek("VVP02")
aCampos := {}

Do While !eof() .and. x3_arquivo == "VVP"
	if X3USO(x3_usado).and.cNivel>=x3_nivel
       aadd(aCampos,x3_campo)
    Endif
    dbskip()
Enddo
DbSelectArea("VVP")

Return .T.

Static Function MenuDef()
Local aRotina := {{ OemToAnsi(STR0002) ,"AxPesqui", 0 , 1},; // Pesquisar
                  { OemToAnsi(STR0003) ,"Vei000V" , 0 , 2},; // Visualizar
                  { OemToAnsi(STR0004) ,"Vei000I" , 0 , 3},; // Incluir
                  { OemToAnsi(STR0005) ,"Vei000A" , 0 , 4},; // Alterar
                  { OemToAnsi(STR0006) ,"AxDeleta", 0 , 5}}  // Excluir
Return aRotina
