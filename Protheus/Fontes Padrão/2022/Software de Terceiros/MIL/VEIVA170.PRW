// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 004    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#INCLUDE "veiva170.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIVA170 ³ Autor ³  Andre                ³ Data ³ 22/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Indices de Convers„o                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVA170

PRIVATE cCadastro := OemToAnsi(STR0001) //"Indices de Convers„o"
PRIVATE aCampos := {}
PRIVATE aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"VVI")

Return

Function Vei170V(cAlias,nReg,nOpc)

CpoVei170()
AxVisual(cAlias,nReg,nOpc,aCampos)

Return


********************************
Function Vei170I(cAlias,nReg,nOpc)

CpoVei170()
AxInclui(cAlias,nReg,nOpc,aCampos)

Return

********************************
Function Vei170A(cAlias,nReg,nOpc)

CpoVei170()
nOpca1 := AxAltera(cAlias,nReg,nOpc,aCampos)

if nOpca1 == 1
   RecLock("VVI",.f.)
   VVI->VVI_DATUSU := dTos(dDataBase) + "-" + __cUserID
   MsUnlock()
Endif

Return

********************
Function CpoVei170()

DbSelectArea("SX3") 
dbSetOrder(1)
dbseek("VVI")
aCampos := {}

Do While !eof() .and. x3_arquivo == "VVI"
	if X3USO(x3_usado).and.cNivel>=x3_nivel
       aadd(aCampos,x3_campo)
    Endif
    dbskip()
Enddo
DbSelectArea("VVI")

Return .T.

Static Function MenuDef()
Local aRotina := {{ OemToAnsi(STR0002) ,"AxPesqui", 0 , 1},;    // Pesquisar
                  { OemToAnsi(STR0003) ,"Vei170V" , 0 , 2},;    // Visualizar
                  { OemToAnsi(STR0004) ,"Vei170I" , 0 , 3},;    // Incluir
                  { OemToAnsi(STR0005) ,"Vei170A" , 0 , 4},;  	// Alterar
                  { OemToAnsi(STR0006) ,"AxDeleta", 0 , 5}}  	// Excluir
Return aRotina
