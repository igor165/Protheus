// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 02     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#INCLUDE "ofipa950.ch"
#INCLUDE "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIPA950 ³ Autor ³  Fabio                ³ Data ³ 13/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marcas                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ (Pecas)                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION OFIPA950

PRIVATE cCadastro := OemToAnsi(STR0001) //"Marcas"

Private cFiltroVX5 := "028"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
axCadastro("VE1", cCadastro,"OFIPA950EX()")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OFIPA950EX³ Autor ³ Eduardo Motta         ³ Data ³ 02/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida se pode ser feito a exclusao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIPA950EX()
Local aArquivos := {}

aadd(aArquivos,{"VE2",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VE5",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VEI",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VEJ",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VF0",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VF1",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VF5",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VF6",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VF7",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VF8",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VG0",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VG1",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VG2",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VG3",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VG5",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VG6",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VG8",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VG9",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VGA",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VGB",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VGC",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VH0",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VH1",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VH2",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VH3",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VH4",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VH5",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VH6",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VI0",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VI1",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VI2",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VI3",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VI4",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VI5",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VI6",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VI7",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VI8",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VI9",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VIA",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VIB",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VIC",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VO7",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VO8",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VOC",2, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VOS",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VV1",3, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VV2",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VVC",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VVK",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VVP",1, VE1->VE1_CODMAR,})

aadd(aArquivos,{"VC3","VC3_CODMAR",VE1->VE1_CODMAR,})
aadd(aArquivos,{"VC6","VC6_CODMAR",VE1->VE1_CODMAR,})
aadd(aArquivos,{"VFC","VFC_CODMAR",VE1->VE1_CODMAR,})
aadd(aArquivos,{"VFD","VFD_CODMAR",VE1->VE1_CODMAR,})
aadd(aArquivos,{"VG4","VG4_CODMAR",VE1->VE1_CODMAR,})

Return FG_DELETA(aArquivos)

Static Function MenuDef()
Return StaticCall(MATXATU,MENUDEF)