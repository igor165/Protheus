#DEFINE IMPORTADOR "1"
#DEFINE FABFOR     "2"
#DEFINE AGENTES    "3"                                                                          
#DEFINE FORNEC     "4"  // EOB - 29/09/09

#DEFINE DESPACHANTE"5"  // LGS - 03/09/15
#DEFINE ACORDO     "6"
#DEFINE EXPORTADOR "7"
#DEFINE UN_MEDIDA  "8"
#DEFINE PRODUTO    "9"
#DEFINE NORMA      "A"
#DEFINE PAIS       "B"
*----------------------------------------------------------------------------*
*  =============  CADASTROS ESPECIFICOS DO MODULO GERENCIAL  ==============  *
*----------------------------------------------------------------------------*
//#INCLUDE "FIVEWIN.CH"
#INCLUDE "Eiccadge.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "EEC.CH"

/*

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICUR100 ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 21/01/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Programa de atualizacao do Cadastro de URF's               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISCOMEX/Easy                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICUR100
Local cAux := ""
LOCAL cCadastro:=OemtoAnsi(STR0001) //"Cadastro de URF/Despacho" 

If !EasyCallMVC("MVC_EICUR100",1) // CRF
   cAux :=  AxCadastro("SJ0",cCadastro)
EndIf

RETURN cAux 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICSJE   ³ Autor ³ Gustavo Carreiro      ³ Data ³ 28/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cadastro de Documentos p/ Instrução de Despacho.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISCOMEX/Easy                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICSJE
Local cAux := ""
LOCAL cCadastro:=OemtoAnsi(STR0025) //"Cadastro de Doctos. para Instrução de Despacho"

If !EasyCallMVC("MVC_SJEEIC",1) // CRF
   cAux := AxCadastro("SJE",cCadastro)
EndIf

RETURN cAux



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICSJF   ³ Autor ³ Gustavo Carreiro      ³ Data ³ 28/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cadastro de Tipos de Embalagens.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISCOMEX/Easy                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICSJF
Local cAux := ""
LOCAL cCadastro:=OemtoAnsi(STR0026) //"Cadastro de Tipos de Embalagens"

If !EasyCallMVC("MVC_SJFEIC",1) // CRF
   cAux := AxCadastro("SJF",cCadastro)
EndIf


RETURN cAux


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICSJG   ³ Autor ³ Gustavo Carreiro      ³ Data ³ 28/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cadastro de Setores de Importação.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Manutenção   ³ Lucas Lopes                          ³ Data ³ 09/01/04 ³±±       
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISCOMEX/Easy                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICSJG

Private cCadastro:=OemtoAnsi(STR0027) //"Cadastro de Setores de Importação"
PRIVATE aRotina := MenuDef(ProcName())
mBrowse( 6, 1,22,75,"SJG")
RETURN .T.  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICSJH   ³ Autor ³ Gustavo Carreiro      ³ Data ³ 28/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cadastro de Códigos da Receita Tributária.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISCOMEX/Easy                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICSJH
Local cAux := ""
LOCAL cCadastro:=OemtoAnsi(STR0028) //"Cadastro de Códigos da Receita Tributária"


If !EasyCallMVC("MVC_SJHEIC",1) // CRF
   cAux := AxCadastro("SJH",cCadastro)
EndIf


RETURN cAux 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICSJI   ³ Autor ³ Gustavo Carreiro      ³ Data ³ 28/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cadastro de Tipos de Ato Legal           .                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISCOMEX/Easy                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/



Function EICSJI
Local cAux := ""
LOCAL cCadastro:=OemtoAnsi(STR0029) //"Cadastro de Tipos de Ato Legal"

If !EasyCallMVC("MVC_SJIEIC",1) // CRF
   cAux := AxCadastro("SJI",cCadastro)
EndIf

RETURN cAux 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICSJJ   ³ Autor ³ Gustavo Carreiro      ³ Data ³ 28/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cadastro de Órgãos Emissores de Ato Legal.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISCOMEX/Easy                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/* Function EICSJJ
Local cAux := ""
LOCAL cCadastro:=OemtoAnsi(STR0030) //"Cadastro de Órgãos Emissores de Ato Legal"

If !EasyCallMVC("MVC_SJJEIC",1) // CRF
   cAux := AxCadastro("SJJ",cCadastro)
EndIf

RETURN cAux 
 */

/*

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICSJM   ³ Autor ³ Gustavo Carreiro      ³ Data ³ 28/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cadastro de Métodos de Valoração.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISCOMEX/Easy                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICSJM
Local cAux := ""
LOCAL cCadastro:=OemtoAnsi(STR0033) //"Cadastro de Métodos de Valoração"

If !EasyCallMVC("MVC_SJMEIC",1) // CRF
   cAux := AxCadastro("SJM",cCadastro)
EndIf

RETURN cAux 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICSJN   ³ Autor ³ Gustavo Carreiro      ³ Data ³ 28/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cadastro de Tabelas de Acréscimos.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISCOMEX/Easy                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICSJN
Local cAux := ""
LOCAL cCadastro:=OemtoAnsi(STR0034) //"Cadastro de Tabelas de Acréscimos"

If !EasyCallMVC("MVC_SJNEIC",1) // CRF
   cAux := AxCadastro("SJN",cCadastro)       
EndIf

RETURN cAux

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICSJO   ³ Autor ³ Gustavo Carreiro      ³ Data ³ 28/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cadastro de Tabelas de Deduções.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISCOMEX/Easy                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICSJO
Local cAux := ""
LOCAL cCadastro:=OemtoAnsi(STR0035) //"Cadastro de Tabelas de Deduções"

If !EasyCallMVC("MVC_SJOEIC",1) // CRF
   cAux := AxCadastro("SJO",cCadastro)       
EndIf

RETURN cAux


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICSJP   ³ Autor ³ Gustavo Carreiro      ³ Data ³ 28/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cadastro de Regimes Trubutários.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISCOMEX/Easy                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICSJP
Local cAux := ""
LOCAL cCadastro:=OemtoAnsi(STR0036) //"Cadastro de Regimes Tributários"
                                    
If !EasyCallMVC("MVC_EICSJP",1) // CRF
   cAux := AxCadastro("SJP",cCadastro)       
EndIf
RETURN cAux


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICSJR   ³ Autor ³ Gustavo Carreiro      ³ Data ³ 28/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cadastro de Motivos de Admissão Temporária.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISCOMEX/Easy                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICSJR
Local cAux := ""
LOCAL cCadastro:=OemtoAnsi(STR0038) //"Cadastro de Motivos de Admissão Temporária"

If !EasyCallMVC("MVC_EICSJR",1) // CRF
   cAux := AxCadastro("SJR",cCadastro)
EndIf   

RETURN cAux

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICSJT   ³ Autor ³ Gustavo Carreiro      ³ Data ³ 28/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cadastro de Tipos de Recipiente.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISCOMEX/Easy                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICSJT
Local cAux := ""
LOCAL cCadastro:=OemtoAnsi(STR0040) //"Cadastro de Tipos de Recipiente"

If !EasyCallMVC("MVC_EICSJT",1) // CRF
   cAux := AxCadastro("SJT",cCadastro)
EndIf   

RETURN cAux



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICSJU   ³ Autor ³ Gustavo Carreiro      ³ Data ³ 01/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cadastro de Taxas de Juros - BACEN.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISCOMEX/Easy                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICSJU
Local cAux := ""
LOCAL cCadastro:=OemtoAnsi(STR0041) //"Cadastro de Taxas de Juros - BACEN"
If !EasyCallMVC("MVC_EICSJU",1) // CRF
   cAux := AxCadastro("SJU",cCadastro)
EndIf   

RETURN cAux
                                    



//Funcao   : EICSJV()
//Autor    : Leandro Delfino R.
//Data     : 17/09/03
//Descricao: Natureza da Operacao
//Uso      : Menu - Tabelas SISCOMEX
*-----------------------*
Function EICSJV()
*-----------------------*
Local cAux := ""

If !EasyCallMVC("MVC_EICSJV",1) // CRF
   cAux := AxCadastro("SJV","Natureza da Operacao")
EndIf
    
RETURN cAux



//Funcao   : EICSJW()
//Autor    : Alex Wallauer
//Data     : 23/10/03
//Descricao: Regras da DSI
//Uso      : Menu - Tabelas SISCOMEX
*-----------------------*
Function EICSJW()
*-----------------------*
RETURN AxCadastro("SJW","Regras da DSI")

//Funcao   : EICEIQ() 
//Autor    : Alexandro Wallauer (AWR)
//Data     : 04/02/02
//Descricao: Cadastro de Tributacao do I.C.M.S.
//Uso      : SIGAEIC
*-----------------------*
Function EICEIQ()
*-----------------------*
aMemos:={{'EIQ_TEXCOD','EIQ_TEXTO'}}
RETURN AxCadastro("EIQ",STR0042)//"Cadastro de Tributacao do I.C.M.S."

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICNS100 ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 22/01/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Programa de atualizacao do Cadastro de NALADI SH           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISCOMEX/Easy                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICNS100
Local cAux := ""
LOCAL cCadastro:=OemtoAnsi(STR0002) //"Tabela de Naladi SH"

If !EasyCallMVC("MVC_NS100EIC",1) // CRF
   cAux := AxCadastro("SJ1",cCadastro) 
EndIf

RETURN cAux




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICNC100 ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 22/01/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Programa de atualizacao do Cadastro de NALADI NCCA         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISCOMEX/Easy                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICNC100
Local cAux := ""
LOCAL cCadastro:=OemtoAnsi(STR0003) //"Tabela de Naladi N C C A"

If !EasyCallMVC("MVC_NC100EIC",1) // CRF
   cAux := AxCadastro("SJ2",cCadastro) 
EndIf

RETURN cAux


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICAL100 ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 22/01/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Programa de atualizacao do Cadastro de ALADI               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISCOMEX/Easy                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICAL100
Local cAux := "" 
LOCAL cCadastro:=OemtoAnsi(STR0004) //"Tabela de Aladi"
                                      
If !EasyCallMVC("MVC_EICAL100",1) // CRF
   cAux := AxCadastro("SJC",cCadastro)
EndIf    

Return cAux

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICUN100 ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 22/01/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Programa de atualizacao do Cadastro de Unidades            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISCOMEX/Easy                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICUN100
Local cAux := ""
LOCAL cCadastro:=OemtoAnsi(STR0005) //"Tabela de Unidades"

If !EasyCallMVC("MVC_EICUN100",1) // CRF
   cAux := AxCadastro("SAH",cCadastro,"UN100EX()","UN100OK()")
EndIf   
Return cAux

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICTU100 ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 22/01/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Tabelas de Unidades p/ Conversao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISCOMEX/Easy                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICTU100(xAutoCab,xAutoItens,xOpcAuto)

Local cAlias:="SJ5", nOldArea:=Select()

Private aRotina := MenuDef(ProcName())

Private lAbriuExp := .F., aBotao:= {}, cFilSB1:=xFilial("SB1"), cFilSJ5:=xFilial("SJ5")
Private cFilSB1Aux:=cFilSB1, cAliasSB1:="SB1" //Para utilizar produtos de outra Empresa/Filial
Private nOrderSX3:=SX3->(IndexOrd()), cF3, lReturn:= .T.
Private cMarca := GetMark(), lInverte := .F., cCadastro:=STR0006 //"Tabela de Conversao de Unidades"  

Private lSJ5ExecAuto := xAutoCab <> NIL
Private nOpcAuto := xOpcAuto
Private aAutoCab := xAutoCab

If Select("SB1EXP") = 0
   lAbriuExp := AbreArqExp("SB1",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,"")),cFilSB1,"SB1EXP") // Abre arq. produtos de outra Empresa/Filial de acordo com os parametros.   
Else
   lAbriuExp := .T.
Endif              
If lAbriuExp
   cAliasSB1  := "SB1EXP"
   cFilSB1Aux := EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))
   If(Empty(Alltrim(cFilSB1Aux)),cFilSB1Aux:=Space(FWSizeFilial()),) //Devido ao parâmetro vir com um espaço apenas
   
   SETKEY(VK_F4,{||EDCAC400HLP(@M->J5_COD_I)}) // F4 para produtos a exportar
Endif

If lAbriuExp
   Aadd(aBotao,{"PESQUISA",{|| EDCAC400HLP(@M->J5_COD_I) }, STR0044}) //"Pesquisa de Produtos"
EndIf

SX3->(DbSetOrder(nOrderSX3)) 

If (lExcMVcAuto := !EasyCallMVC("MVC_EICTU100",1)) .And.  !lSJ5ExecAuto
   mBrowse( 6, 1,22,75,cAlias) 
ElseIf lSJ5ExecAuto .And. lExcMVcAuto
   MBrowseAuto(nOpcAuto, aAutoCab, "SJ5",,.T.)
EndIf 

DbSelectArea(nOldArea)

If lAbriuExp   // Desabilita o F4 caso esteja ativo
   SETKEY(VK_F4,NIL)
   SX3->(dbSetOrder(2))   
Endif   

SX3->(DbSetOrder(nOrderSX3))

Return .T.                  

*---------------------------------------*
Function TU100Manut(cAlias,nReg,nOpc)
*---------------------------------------*
Local nSelect := Select(), oEnc
Local nOrder := SJ5->(INDEXORD())
Local oDlg,nInc,nOp,bCancel := {||nOp:=0, If(!lSJ5ExecAuto, oDlg:End(),)  }
Local bVal_OK:={||nOp:=1, If(!lSJ5ExecAuto,oDlg:End(),) }

Private aTela[0][0],aGets[0]
    
If nOpc == INCLUIR
   dbSelectArea(cAlias)
   For nInc := 1 TO (cAlias)->(FCount())
	     M->&(FIELDNAME(nInc)) := CRIAVAR(FIELDNAME(nInc))
   Next nInc
Else
   dbSelectArea(cAlias)
   For nInc := 1 TO (cAlias)->(FCount())
      M->&(FIELDNAME(nInc)) := FieldGet(nInc)
   Next nInc
	      
   If nOpc = VISUALIZAR
      bVal_OK:={||If(!lSJ5ExecAuto,oDlg:End(),)}
	     	  
   //ElseIf nOpc = EXCLUIR
      //bVal_OK:={||nOp:=0,oDlg:End()}
         
   EndIf
Endif
                           
If !lSJ5ExecAuto
   DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
         
   oEnc := MsMget():New(cAlias, nReg, If(nOpc=6,INCLUIR,nOpc),,,,,PosDlg(oDlg))
   
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||If(Obrigatorio(aGets,aTela) .And. If(nOpc <> VISUALIZAR .OR. nOpc <> EXCLUIR, TU100Valid("",nOpc), .T.) .AND. IF(nOpc = ALTERAR .OR. nOpc = EXCLUIR,TU100TotReg(),.T.), Eval(bVal_OK), )},{||Eval(bCancel)},,aBotao) ,;
                                oEnc:oBox:Align :=  CONTROL_ALIGN_ALLCLIENT)
Else
      If lRet := EnchAuto(cAlias, aAutoCab, {|| Obrigatorio(aGets,aTela)}, nOpc)
         Eval(bVal_Ok)
      Else
         Eval(bCancel)
      EndIf
EndIf  
              
If nOp=1
   MsAguarde( { || TU100Grv(nOpc)}, "Gravando Dados...")
Else
  Return
EndIf
 
SJ5->(dbsetorder(nOrder))

Select(nSelect)
    
Return NIL

/*
Função..: TU100TotReg
Autor...: Thiago Rinaldi Pinto - TRP
Data....: 16/03/2010
Objetivo: Verificar se a unidade de medida está sendo utilizada no DrawBack
Parâmetros: -
*/
*------------------------------*
Function TU100TotReg(nTypeChk)
*------------------------------*
Local lGrava:= .T.
Local lContinua:= .T.
Local nTotalReg
Local cQuery     := ""
Local cFilED3:= xFilial("ED3")
Local cFilED4:= xFilial("ED4")
Local cFilEYY:= xFilial("EYY")
Local cCampoDe:=SJ5->J5_DE 
Local cCampoPara:=SJ5->J5_PARA
Local lTop:= .F.
Default nTypeChk := 1

#IFDEF TOP
   lTop := .T.
#ENDIF


If lTop
     
   If Select("TOTALREG") > 0
      TOTALREG->( dbCloseArea() )
   Endif

   If nTypeChk == 1

      cFrom    := RetSqlName("ED3")+" ED3, " + RetSqlName("ED4")+" ED4 "
   
      cWhere   := iIF( TcSrvType()=="AS/400"," ED3.@DELETED@ <> '*' "," ED3.D_E_L_E_T_ <> '*'" ) + " AND ED3.ED3_FILIAL = '"+cFilED3+"' "+;
                                    "AND (ED3.ED3_UMPROD = '"+cCampoDe+"' OR ED3.ED3_UMPROD = '"+cCampoPara+"') "

   
      cWhere   += iIF( TcSrvType()=="AS/400"," AND ED4.@DELETED@ <> '*' "," AND ED4.D_E_L_E_T_ <> '*'" ) + " AND ED4.ED4_FILIAL = '"+cFilED4+"' "+;
                                    "AND (ED4.ED4_UMITEM = '"+cCampoDe+"' OR ED4.ED4_UMITEM = '"+cCampoPara+"') "
   ElseIf nTypeChk == 2

      cFrom    := RetSqlName("EYY")+" EYY "
   
      cWhere   := iIF( TcSrvType()=="AS/400"," EYY.@DELETED@ <> '*' "," EYY.D_E_L_E_T_ <> '*'" ) + " AND EYY.EYY_FILIAL = '"+cFilEYY+"' "+;
                                    "AND (EYY.EYY_UMDSD1 = '"+cCampoDe+"' OR EYY.EYY_UMDSD1 = '"+cCampoPara+"') "

   
      cWhere   +=                   "AND (EYY.EYY_UNIDAD = '"+cCampoDe+"' OR EYY.EYY_UNIDAD = '"+cCampoPara+"') "

   EndIf

   //Total de Registros
   cQuery := " SELECT COUNT(*) AS TOTAL FROM "+cFrom+" WHERE "+cWhere 

   dbUseArea( .t., "TopConn", TCGenQry(,,cQuery),"TOTALREG", .F., .F. )

   nTotalReg:= TOTALREG->TOTAL

   TOTALREG->( dbCloseArea() )

   If nTypeChk == 1  
      If nTotalReg > 0 .And. !EasyGParam("MV_EDC0012",,.F.) //MCF - 15/06/2015
         EasyHelp(STR0052) //"Conversão não pode ser alterada/excluída pois está sendo utilizada no DrawBack!"
         lGrava:= .F.
      Endif
   ElseIf nTypeChk == 2
      If nTotalReg > 0 
         EasyHelp(STR0053) //"Conversão não pode ser alterada/excluída pois está sendo utilizada em vinculação de saldos de fim específico de exportação para um ou mais processos de embarque!"
         lGRava:= .F.
      EndIf
   EndIf



Else

  
   ED3->(DbGotop())
   
   DO WHILE ! ED3->(EOF()) .AND. ED3->ED3_FILIAL == cFilED3 
   
      If (ED3->ED3_UMPROD = Alltrim(cCampoDe) .OR. ED3->ED3_UMPROD = Alltrim(cCampoPara))
         MsgInfo("Conversão não pode ser alterada/excluída pois está sendo utilizada no DrawBack! - Ato:" + Space(1) + ED3->ED3_AC)
         lGrava:= .F.    
         lContinua:= .F.
         Exit
      Endif   
      ED3->(DbSkip())
   ENDDO   

   If lContinua
      ED4->(DbGotop())

      DO WHILE ! ED4->(EOF()) .AND. ED4->ED4_FILIAL == cFilED4  
   
         If (ED4->ED4_UMITEM = Alltrim(cCampoDe) .OR. ED4->ED4_UMITEM = Alltrim(cCampoPara))
            MsgInfo("Conversão não pode ser alterada/excluída pois está sendo utilizada no DrawBack! - Ato:" + Space(1) + ED4->ED4_AC)
            lGrava:= .F.    
            Exit
         Endif   
         ED4->(DbSkip())
      ENDDO  
   Endif
Endif

Return lGrava
*------------------------------*
Static Function TU100Grv(nOpc)
*------------------------------* 
Local i
dbSelectArea("SJ5")
//TRP - 16/03/2010
If nOpc = EXCLUIR
   SJ5->(Reclock("SJ5",.F.))
   SJ5->(DbDelete())
   SJ5->(MsUnlock())
Endif

SJ5->(RecLock("SJ5",If(nOpc=INCLUIR .or. nOpc=6,.T.,.F.)))

FOR i := 1 TO FCount()
   SJ5->&(FIELDNAME(i)) := M->&(FIELDNAME(i))
NEXT i

SJ5->J5_FILIAL := cFilSJ5

SJ5->(MSUnlock())

Return .T.

*---------------------------------*
Function TU100Valid(cParam, nOpc)
*---------------------------------*
Local cFilSJ5 := xFilial("SJ5")
Local nRegSJ5:=SJ5->(RecNo())
Private lRet:= .T.

SB1->(dbSetOrder(1))
SJ5->(dbSetOrder(1))
SX3->(dbSetOrder(2))

lProdSJ5:= SX3->(dbSeek("J5_COD_I"))

If cParam == "DE"
   If ExistCpo("SAH",LEFT(M->J5_DE,2))
      If M->J5_DE==M->J5_PARA
         Help(" ",1,"AVG0005261") //"A Conversão não pode ser efetuada com Unidades de Medidas iguais!"
         lRet:= .F.
      Endif
   Else
      lRet:= .F.
   Endif
ElseIf cParam == "PARA"
   If ExistCpo("SAH",LEFT(M->J5_PARA,2))
      If M->J5_DE==M->J5_PARA
         Help(" ",1,"AVG0005261") //"A Conversão não pode ser efetuada com Unidades de Medidas iguais!"
         lRet:= .F.
      Endif
   Else
      lRet:= .F.
   Endif
ElseIf cParam == "COD"
   If !Empty(M->J5_COD_I)
      If lAbriuExp
         If !(cAliasSB1)->(dbSeek(cFilSB1Aux+M->J5_COD_I)) .And. !SB1->(dbSeek(cFilSB1+M->J5_COD_I))
            Help("", 1, "REGNOIS")
            lRet:= .F.
         Endif            
      Else
         If(!ExistCpo("SB1", M->J5_COD_I), lRet:= .F., )
      Endif
   Endif
Else   
   If nOpc <> INCLUIR .and. nOpc <> 6
      If SJ5->(dbSeek(cFilSJ5+M->J5_DE+M->J5_PARA+M->J5_COD_I+M->J5_FORN+M->J5_FORLOJ)) //wfs jun/2017 - complemento da chave com as informações do fornecedor
         If SJ5->(RecNo()) <> nRegSJ5
            Help(" ",1,"JAGRAVADO")
            lRet:= .F.
         Else
            lRet:= .T.
         Endif
      Endif
   Else
      If SJ5->(dbSeek(cFilSJ5+M->J5_DE+M->J5_PARA+M->J5_COD_I+M->J5_FORN+M->J5_FORLOJ)) //wfs jun/2017 - complemento da chave com as informações do fornecedor
         Help(" ",1,"JAGRAVADO")
         lRet:= .F.
      Endif
   Endif
Endif

SX3->(DBSETORDER(nOrderSX3))
SJ5->(dbGoTo(nRegSJ5))

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICMO100 ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 22/01/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modalidades de Pagto                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISCOMEX/Easy                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICMO100
Local cAux := ""
LOCAL cCadastro:=OemtoAnsi(STR0007) //"Tabela de Modalidades de Pagamento"

If !EasyCallMVC("MVC_MO100EIC",1) // CRF
   cAux := AxCadastro("SJ6",cCadastro)
EndIf

Return cAux


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICIF100 ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 22/01/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Instituicoes Financiadoras                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISCOMEX/Easy                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICIF100
Local cAux := ""
LOCAL cCadastro:=OemtoAnsi(STR0008) //"Cadastro de Instituicoes Financiadoras"

If !EasyCallMVC("MVC_IF100EIC",1) // CRF
   cAux := AxCadastro("SJ7",cCadastro)
EndIf

Return cAux





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICMT100 ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 22/01/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Motivos Sem Cobertura                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISCOMEX/Easy                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICMT100
Local cAux := ""
LOCAL cCadastro:=OemtoAnsi(STR0009) //"Tabela de Motivos Sem Cobertura"

If !EasyCallMVC("MVC_MT100EIC",1) // CRF
   cAux := AxCadastro("SJ8",cCadastro)
EndIf

Return cAux





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICAS100 ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 22/01/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Agencias Secex                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISCOMEX/Easy                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICAS100
Local cAux := ""
LOCAL cCadastro:=OemtoAnsi(STR0010) //"Cadastro de Agencias Secex"

If !EasyCallMVC("MVC_100ASEIC",1) // CRF
   cAux := AxCadastro("SJ9",cCadastro)
EndIf

Return cAux




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICAR100 ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 22/01/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Recinto Alfandegado                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISCOMEX/Easy                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICAR100

Local cAux := ""
LOCAL cCadastro:=OemtoAnsi(STR0011) //"Cadastro de Recinto Alfandegado"

If !EasyCallMVC("MVC_100AREIC",1) // CRF
   cAux := AxCadastro("SJA",cCadastro)
EndIf

Return cAux


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICTD100 ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 22/01/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Tipos de Declaracao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISCOMEX/Easy                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICTD100
Local cAux := ""
LOCAL cCadastro:=OemtoAnsi(STR0012) //"Tabela de Tipos de Declaracao"

If !EasyCallMVC("MVC_EICTD100",1) // CRF
   cAux := AxCadastro("SJB",cCadastro)
EndIf

Return cAux

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICTE110 ³ Autor ³ AVERAGE-Robson        ³ Data ³ 29/07/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao da Integracao Easy-GipLite         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICTE110
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cAlias:="SYU", nOldArea:=Select()
LOCAL cFilTroSYU:= ""
PRIVATE aRotina := MenuDef(ProcName())
PRIVATE cDelFunc

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemtoAnsi(STR0018) //"de/Para Integrações"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If SYU->(FieldPos("YU_ORIGEM")) > 0
   cFilTroSYU  := If(nModulo==17, "YU_ORIGEM = '   '", "YU_ORIGEM = 'EEC'")
   mBrowse( 6, 1,22,75,cAlias,,,,,,,,,,,,,,cFilTroSYU)
Else
   mBrowse( 6, 1,22,75,cAlias)
EndIf

DbSelectArea(nOldArea)
Return .T.

*----------------------------------------------------------------------------*
Function EICTE110Descr(cTipo) //JWJ 09-NOV-2006
*----------------------------------------------------------------------------*
Local cDesc := ""

DO CASE
   Case cTipo == IMPORTADOR
      SYT->(DBSETORDER(1))
      SYT->(DBSEEK(xFilial()+ALLTRIM(SYU->YU_EASY) ))
      cDesc := SYT->YT_NOME_RE
      
   Case cTipo == FABFOR
      SA2->(DBSETORDER(1))
      SA2->(DBSEEK(xFilial()+ALLTRIM(SYU->(YU_EASY+YU_LOJA) ) )) //MCF - 22/03/2016
      cDesc := SA2->A2_NREDUZ
      
   Case cTipo == AGENTES
      SY4->(DBSETORDER(1))
      SY4->(DBSEEK(xFilial()+ALLTRIM(SYU->YU_EASY) ))
      cDesc := LEFT(SY4->Y4_NOME, AVSX3("YU_DESC",3))
      
   Case cTipo == FORNEC  // EOB - 29/09/09
      SA2->(DBSETORDER(1))
      SA2->(DBSEEK(xFilial()+ALLTRIM(SYU->(YU_EASY+YU_LOJA) ) ))
      cDesc := SA2->A2_NREDUZ

   Case cTipo == DESPACHANTE  // LGS - 03/09/2015      
      SY5->(DBSETORDER(1))
      SY5->(DBSEEK(xFilial()+ALLTRIM(SYU->YU_EASY) ))
      cDesc := SY5->Y5_NOME

   Case cTipo == ACORDO      // LGS - 03/09/2015      
      E11->(DBSETORDER(1))
      E11->(DBSEEK(xFilial()+ALLTRIM(SYU->YU_EASY) ))
      cDesc := E11->E11_DESCRI        

   Case cTipo == EXPORTADOR      // LGS - 03/09/2015      
      SA2->(DBSETORDER(1))
      SA2->(DBSEEK(xFilial()+ALLTRIM(SYU->(YU_EASY+YU_LOJA) ) ))
      cDesc := SA2->A2_NREDUZ

   Case cTipo == UN_MEDIDA      // LGS - 03/09/2015      
      SAH->(DBSETORDER(1))
      SAH->(DBSEEK(xFilial()+ALLTRIM(SYU->YU_EASY) ))
      cDesc := SAH->AH_UMRES

   Case cTipo == PRODUTO      // LGS - 08/09/2015      
      SB1->(DBSETORDER(1))
      SB1->(DBSEEK(xFilial()+ALLTRIM(SYU->YU_EASY) ))
      cDesc := SB1->B1_DESC

   Case cTipo == NORMA      // LGS - 08/09/2015      
      EEI->(DBSETORDER(1))
      EEI->(DBSEEK(xFilial()+ALLTRIM(SYU->YU_EASY) ))
      cDesc := MSMM(EEI->EEI_DESC,35,1)

   Case cTipo == PAIS      // LGS - 26/10/2015      
      SYA->(DBSETORDER(1))
      SYA->(DBSEEK(xFilial()+ALLTRIM(SYU->YU_EASY) ))
      cDesc := SYA->YA_DESCR
Endcase

Return cDesc


*----------------------------------------------------------------------------*
Function EICTE110Tipo(cTipo,cMCodCad)
*----------------------------------------------------------------------------*
LOCAL oDlg, nOpcA:=0 		//LGS - 08/08/2013
LOCAL cLoja:= "" 
Local aRotinaAux := aClone(aRotina)
PRIVATE cArqF3, cCampoF3, cCod, cPict, bValid, bCampo, cRDTipo:=cTipo /*cRDTipo:=EICTE110DTIPO(cTipo)*/, cDesc:=EICTE110DTIPO(cTipo) //LGS - 30/08/2013

Default cMCodCad := ""

If Empty(cMCodCad)
	DEFINE MSDIALOG oDlg TITLE cCadastro+STR0019 From 9,0 To 25,50 OF GetWndDefault() //" - Tipo Cadastro"
	
	oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 20/07/2015
	oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

	DO Case
	   Case cTipo == IMPORTADOR
	        cCod:=SPACE(LEN(SYT->YT_COD_IMP))
	        cPict:= E_Tran("YT_COD_IMP",,.T.)
	        cArqF3:="SYT"  ; cCampoF3:="YT_COD_IMP"
	        bValid:={||SYT->(DBSEEK(xFilial()+cCod))}
	        bCampo:={||M->YU_DESC:=SYT->YT_NOME}
	        
	   Case cTipo == FABFOR
	        cCod:=SPACE(LEN(SA2->A2_COD))
	        If EICLOJA()
	           cLoja:= SPACE(LEN(SA2->A2_LOJA))
	        Endif
	        cPict :=E_Tran("A2_COD",,.T.)
	        //cArqF3:="SA2"  ; cCampoF3:="A2_COD" //LRS 05/11/2014
	        cArqF3:="FABLOJ"  ; cCampoF3:="A2_COD" //LRS 05/11/2014
	        bValid:={||SA2->(DBSEEK(xFilial()+cCod+cLoja))}
	        bCampo:={||M->YU_DESC:=SA2->A2_NREDUZ}
	        //bLoja:={||M->YU_LOJA:=SA2->A2_LOJA}
	        
	   Case cTipo == AGENTES
	        cCod:=SPACE(LEN(SY4->Y4_COD))
	        cPict :=E_Tran("Y4_COD",,.T.)
	        cArqF3:="SY4"  ; cCampoF3:="Y4_COD"
	        bValid:={||SY4->(DBSEEK(xFilial()+cCod))}
	        bCampo:={||M->YU_DESC:=SY4->Y4_NOME}
	         
	   Case cTipo == FORNEC
	        cCod:=SPACE(LEN(SA2->A2_COD))
	        If EICLOJA()
	           cLoja:= SPACE(LEN(SA2->A2_LOJA))
	        Endif
	        cPict :=E_Tran("A2_COD",,.T.)
	        //cArqF3:="SA2"  ; cCampoF3:="A2_COD" //LRS 05/11/2014
	        cArqF3:="FABLOJ"  ; cCampoF3:="A2_COD" //LRS 05/11/2014
	        bValid:={||SA2->(DBSEEK(xFilial()+cCod+cLoja))}
	        bCampo:={||M->YU_DESC:=SA2->A2_NREDUZ}
	        //bLoja:={||M->YU_LOJA:=SA2->A2_LOJA}
	        
	   //Tratamento para FIERGS
	   Case cTipo == DESPACHANTE						//LGS - 03/09/2015
	        cCod:=SPACE(LEN(SY5->Y5_COD))
	        cPict:= E_Tran("Y5_COD",,.T.)
	        cArqF3:="SY5"  ; cCampoF3:="Y5_COD"
	        bValid:={||SY5->(DBSEEK(xFilial()+cCod))}
	        bCampo:={||M->YU_DESC:=SY5->Y5_NOME}

	   Case cTipo == ACORDO 								//LGS - 03/09/2015
	        cCod:=SPACE(LEN(E11->E11_CODACO))
	        cPict:= E_Tran("E11_CODACO",,.T.)
	        cArqF3:="EECE11"  ; cCampoF3:="E11_CODACO"
	        bValid:={||E11->(DBSEEK(xFilial()+cCod))}
	        bCampo:={||M->YU_DESC:=E11->E11_DESCRI}
	        
	   Case cTipo == EXPORTADOR
	        cCod:=SPACE(LEN(SA2->A2_COD))
	        If EICLOJA()
	           cLoja:= SPACE(LEN(SA2->A2_LOJA))
	        Endif
	        cPict :=E_Tran("A2_COD",,.T.)
	        cArqF3:="FABLOJ"  ; cCampoF3:="A2_COD"
	        bValid:={||SA2->(DBSEEK(xFilial()+cCod+cLoja))}
	        bCampo:={||M->YU_DESC:=SA2->A2_NREDUZ}       

	   Case cTipo == UN_MEDIDA
	        cCod:=SPACE(LEN(SAH->AH_UNIMED))
	        cPict :=E_Tran("AH_UNIMED",,.T.)
	        cArqF3:="SAH"  ; cCampoF3:="AH_UNIMED"
	        bValid:={||SAH->(DBSEEK(xFilial()+cCod))}
	        bCampo:={||M->YU_DESC:=SAH->AH_UMRES}

	   Case cTipo == PRODUTO
	        cCod:=SPACE(LEN(SB1->B1_COD))
	        cPict :=E_Tran("B1_COD",,.T.)
	        cArqF3:="B00"  ; cCampoF3:="B1_COD"
	        bValid:={||SB1->(DBSEEK(xFilial()+cCod))}
	        bCampo:={||M->YU_DESC:=SB1->B1_DESC}
	        
	   Case cTipo == NORMA
	        cCod:=SPACE(LEN(EEI->EEI_COD))
	        cPict :=E_Tran("EEI_COD",,.T.)
	        cArqF3:="EEI"  ; cCampoF3:="EEI_COD"
	        bValid:={||EEI->(DBSEEK(xFilial()+cCod))}
	        bCampo:={||M->YU_DESC:=MSMM(EEI->EEI_DESC,35,1)}

	   Case cTipo == PAIS
	        cCod:=SPACE(LEN(SYA->YA_CODGI))
	        cPict :=E_Tran("YA_CODGI",,.T.)
	        cArqF3:="SYA"  ; cCampoF3:="YA_CODGI"
	        bValid:={||SYA->(DBSEEK(xFilial()+cCod))}
	        bCampo:={||M->YU_DESC:=SYA->YA_DESCR}
	              	        	        
	   EndCase
	   
	If(EasyEntryPoint("EICCADGE"),ExecBlock("EICCADGE",.F.,.F.,"TELA_GET_COD_EASY"),) //LGS - 08/08/2013 - Criacao de ponto de entrada
	
	@ 2.0,0.8  SAY cDesc OF oPanel
	
	//TDF - 16/07/11 
	If EICLoja() .AND. (cTipo == FORNEC .OR. cTipo == FABFOR)
	   @ 2.0,6.5  MSGET cCod F3 cArqF3 PICT cPict OF oPanel //VALID cLoja:= SA2->A2_LOJA
	   @ 4.0,0.8  SAY "Loja" OF oPanel 
	   @ 4.0,6.5  MSGET cLoja PICTURE "@!" OF oPanel
	ELSE
	   @ 2.0,6.5  MSGET cCod F3 cArqF3 PICT cPict OF oPanel
	EndIf 


	ACTIVATE MSDIALOG oDlg ON INIT ;
         EnchoiceBar(oDlg,{||nOpca:=1,IF(TE110Valid(bValid,bCampo,cTipo,cCod,If(EICLOJA(),cLoja,"")),oDlg:End(),nOpca:=0)},;
                          {||nOpca:=0,oDlg:End()}) CENTERED

	aRotina := aClone(aRotinaAux)

	IF nOpca == 0
	   RETURN .F.
	ENDIF

EndIf
RETURN .T.

*------------------------------*
Function EICTE110DTIPO(cTipo)
*------------------------------*
LOCAL cDesc:=""
LOCAL lDePara2 := EasyGParam("MV_DEPARA2",,.F.)

DO Case
   Case cTipo == IMPORTADOR
        cDesc:=STR0020 //"Importador"
   Case cTipo == FABFOR
        IF lDePara2
           cDesc := "Fabricante"
        ELSE 
           cDesc:=STR0021 //"Fab/For"
        ENDIF
   Case cTipo == AGENTES
        cDesc:=STR0022 //"Agentes"
   Case cTipo == FORNEC
        cDesc:="Fornecedor"
   
   //Tratamento para FIERGS - LGS - 03/09/2015
   Case cTipo == DESPACHANTE
        cDesc:="Despachante"
   Case cTipo == ACORDO
        cDesc:="Acordo"                
   Case cTipo == EXPORTADOR
        cDesc:="Exportador"
   Case cTipo == UN_MEDIDA
        cDesc:="UN Medida"
   Case cTipo == PRODUTO
        cDesc:="Produto"
   Case cTipo == NORMA
        cDesc:="Norma"
   Case cTipo == PAIS
        cDesc:="País"
                        
EndCase
Return cDesc

Function TE110Valid(bValid,bCampo,cTipo,cCod,cLoja)
IF ! EVAL(bValid)
   Help("", 1, "AVG0000230")//MsgInfo(OemToAnsi(STR0023),STR0024) //"C¢digo Inv lido"###"Informação"
   RETURN .F.
ENDIF
IF SYU->(DBSEEK(xFilial()+M->YU_DESP+cTipo+cCod+cLoja))
   Help("", 1, "AVG0000231")//MsgInfo(OemToAnsi(STR0025),STR0024) //"C¢digo j  Cadastrado para este Despachante"###"Informação"
   RETURN .F.
ENDIF
M->YU_EASY:=cCod

If EMPTY(cLoja)
   cloja:= ""
EndIF

M->YU_LOJA:=cLoja

EVAL(bCampo)
lRefresh:=.T.
RETURN .T.

FUNCTION UN100OK()
LOCAL I,;
      cCOD := AVKEY(M->AH_UNIMED,"EE2_COD"),;
      lRET := .F.,;
      lEE2 := .T.,;
      aEE2 := {{STR0049,M->AH_DESCPO},;
               {STR0050,M->AH_DESCIN},;
               {STR0051,M->AH_DESCES}}

FOR I := 1 TO LEN(aEE2)
    EE2->(DBSETORDER(2))
    lEE2 := (EE2->(DBSEEK(XFILIAL("EE2")+MC_TUNM+TM_GER+cCOD+aEE2[I,1])))
    IF EMPTY(aEE2[I,2])
       IF lEE2
          EE2->(RECLOCK("EE2",.F.),DBDELETE(),MSUNLOCK())
       ENDIF
    ELSE
       lRET := EE2->(RECLOCK("EE2",!lEE2))
       IF ! lEE2
          EE2->EE2_FILIAL := XFILIAL("EE2")
          EE2->EE2_CODCAD := MC_TUNM
          EE2->EE2_TIPMEN := TM_GER
          EE2->EE2_COD    := cCOD
          EE2->EE2_IDIOMA := aEE2[I,1]
       ENDIF
       EE2->EE2_DESCMA := aEE2[I,2]
       EE2->(MSUNLOCK())
    ENDIF
NEXT
RETURN(lRET)

FUNCTION UN100EX()
LOCAL cCOD := AVKEY(SAH->AH_UNIMED,"EE2_COD")

EE2->(DBSETORDER(2))
EE2->(DBSEEK(XFILIAL("EE2")+MC_TUNM+TM_GER+cCOD))
DO WHILE ! EE2->(EOF()) .AND.;
   EE2->(EE2_FILIAL+EE2_CODCAD+EE2_TIPMEN+EE2_COD) = (XFILIAL("EE2")+MC_TUNM+TM_GER+cCOD)
   *
   EE2->(RECLOCK("EE2",.F.),DBDELETE(),MSUNLOCK(),DBSKIP())
ENDDO   
RETURN(.T.)



*---------------------------------------------*
function EICSJGIncluir(cAlias,nReg,nOpc)   //LRL 09/01/04 
**--------------------------------------------*
AxInclui(cAlias,nReg,nOpc,,,,"EICSJGValida()")
Return .T.


*---------------------------------------------*
Function EICSJGValida   //LRL 09/01/04 
//Validação do Incluir
*---------------------------------------------*
Local lRet:=.T.
Private cFilSJG := xFilial('SJG')
If  INCLUI .AND. SJG->(Dbseek(cFilSJG+M->JG_RECINTO+M->JG_CODIGO+M->JG_ORGAO))
 MsgInfo(STR0047)
 lRet := .F. 
EndIF
RETURN lRet 


*---------------------------------------------*
function EICSJLIncluir(cAlias,nReg,nOpc)   //LRL 09/01/04 
*---------------------------------------------*
AxInclui(cAlias,nReg,nOpc,,,,"EICSJLValida()")
Return .T.


*---------------------------------------------*
Function EICSJLValida   //LRL 09/01/04 
//Validação do Incluir
*---------------------------------------------*
Local lRet:=.T.
Private cFilSJL := xFilial('SJL')
If  INCLUI .AND. SJL->(Dbseek(cFilSJL+M->JL_NCM+M->JL_ATRIB+M->JL_ESPECIF))
 MsgInfo(STR0048)
 lRet := .F. 
EndIF
RETURN lRet


*---------------------------------------------*
function EICSJKIncluir(cAlias,nReg,nOpc)   //LRL 09/01/04 
*---------------------------------------------*
AxInclui(cAlias,nReg,nOpc,,,,"EICSJKValida()")
Return .T.

*---------------------------------------------*
Function EICSJKValida   //LRL 09/01/04 
//Validação do Incluir
*---------------------------------------------*
Local lRet:=.T.
Private cFilSJK := xFilial('SJK')
If  INCLUI .AND. SJK->(Dbseek(cFilSJK+M->JK_NCM+M->JK_ATRIB))
 MsgInfo(STR0046)
 lRet := .F. 
EndIF
RETURN lRet

/*
Funcao     : MenuDef()
Parametros : cFuncao
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 24/01/07 - 10:17
*/
Static Function MenuDef(cOrigem)
Local aRotAdic := {}                               
Local aRotina := {}     
Default cOrigem  := AvMnuFnc()

cOrigem := Upper(AllTrim(cOrigem))

Begin Sequence

   Do Case
      
      Case cOrigem $ "EICTU100" // Conversão de Unidades
           Aadd(aRotina, { STR0013, "AxPesqui"   , 0 , 1} )  //"Pesquisar"
           Aadd(aRotina, { STR0014, "AxVisual"   , 0 , 2} )  //"Visualizar"
           Aadd(aRotina, { STR0015, "TU100Manut" , 0 , 3} )  //"Incluir"
           Aadd(aRotina, { STR0043, "TU100Manut" , 0 , 4} )  //"Alterar"
           Aadd(aRotina, { STR0016, /*"AxDeleta"*/"TU100Manut"   , 0 , 5,3} )//"Excluir"
           Aadd(aRotina, { STR0045, "TU100Manut" , 0 , 6, ,.F.})   //"Copiar"
                    
           // P.E. utilizado para adicionar itens no Menu da mBrowse
           If nModulo == 17 //SIGAEIC
              If EasyEntryPoint("ITU100MNU")
	             aRotAdic := ExecBlock("ITU100MNU",.f.,.f.)
	          EndIf
           Else 
              If EasyEntryPoint("ETU100MNU")
	             aRotAdic := ExecBlock("ETU100MNU",.f.,.f.)
	          EndIf
           EndIf
   
           If ValType(aRotAdic) == "A"
		      AEval(aRotAdic,{|x| AAdd(aRotina,x)})
      	   EndIf

      Case cOrigem $ "EICSJG" // Setor Importação
           Aadd(aRotina, { STR0013, "AxPesqui"  , 0 , 1}) //"Pesquisar"
           Aadd(aRotina, { STR0014, "AxVisual"  , 0 , 2}) //"Visualizar"
           Aadd(aRotina, { STR0015, "EICSJGIncluir" , 0 , 3}) //"Incluir"
           Aadd(aRotina, { STR0043, "AxAltera"  , 0 , 4}) //"Alterar"
           Aadd(aRotina, { STR0016, "AxDeleta"  , 0 , 5,3})//"Excluir"

           If EasyEntryPoint("ISJGMNU")
	          aRotAdic := ExecBlock("ISJGMNU",.f.,.f.)
	          If ValType(aRotAdic) == "A"
		         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf      
           
      Case cOrigem $ "EICSJK" //Atributos para Valoração Aduaneira
           Aadd(aRotina, { STR0013, "AxPesqui"  , 0 , 1}) //"Pesquisar"
           Aadd(aRotina, { STR0014, "AxVisual"  , 0 , 2}) //"Visualizar"
           Aadd(aRotina, { STR0015, "EICSJKIncluir" , 0 , 3}) //"Incluir"
           Aadd(aRotina, { STR0043, "AxAltera"  , 0 , 4}) //"Alterar"
           Aadd(aRotina, { STR0016, "AxDeleta"  , 0 , 5,3})//"Excluir"
     
           If EasyEntryPoint("ISJKMNU")
	          aRotAdic := ExecBlock("ISJKMNU",.f.,.f.)
	          If ValType(aRotAdic) == "A"
		         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf       

      Case cOrigem $ "EICSJL" //Especificações para Valoração.
           Aadd(aRotina, { STR0013, "AxPesqui"  , 0 , 1}) //"Pesquisar"
           Aadd(aRotina, { STR0014, "AxVisual"  , 0 , 2}) //"Visualizar"
           Aadd(aRotina, { STR0015, "EICSJLIncluir" , 0 , 3}) //"Incluir"
           Aadd(aRotina, { STR0043, "AxAltera"  , 0 , 4}) //"Alterar"
           Aadd(aRotina, { STR0016, "AxDeleta"  , 0 , 5,3})//"Excluir"  
           
           If EasyEntryPoint("ISJLMNU")
	          aRotAdic := ExecBlock("ISJLMNU",.f.,.f.)
	          If ValType(aRotAdic) == "A"
		         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf 
             
      Case cOrigem $ "EICTE110"
           Aadd(aRotina, { STR0013, "AxPesqui"  , 0 , 1}) //"Pesquisar"
           Aadd(aRotina, { STR0014, "AxVisual"  , 0 , 2}) //"Visualizar"
           Aadd(aRotina, { STR0015, "TE110Inclui"  , 0 , 3}) //"Incluir" AxInclui
           Aadd(aRotina, { STR0016, "AxDeleta"  , 0 , 5,3}) //"Excluir"
           Aadd(aRotina, { STR0017, "TEG100EmpAgen",0,6 }) //"Ger.Fab-For" //LRS -18/08/2016
           
           If EasyEntryPoint("ITE110MNU")
	          aRotAdic := ExecBlock("ITE110MNU",.f.,.f.)
	          If ValType(aRotAdic) == "A"
		         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf 
      OtherWise
           aRotina := StaticCall(MATXATU,MENUDEF)
   End Case

End Sequence

Return aRotina 

//NCF - 20/05/09 - Função para Cadastro de Trasnportadoras
Function EICTransp()

AxCadastro("SA4","Cadastro de Transportadoras",".T.",".T.")

Return

/*
Funcao     : TE110Inclui()
Parametros : cCod
Objetivos  : Realizar a inclusão no dicionario "SYU" - Tabela de/Para
Autor      : Laercio G Souza Junior
Data/Hora  : 03/09/2015 - 13:13
*/
*--------------------------------*
Function TE110Inclui(cCod,cReg)
*--------------------------------*
Local oDlg, nOp, nOpc:=3, nInc
Local bVal_OK := {||nOp:=1, oDlg:End()}, bCancel := {|| oDlg:End()}
Local cCadastro := OemtoAnsi(STR0018)// + " - Inclusão" 

Private aTela[0][0], aGets[0], cMCodCad := "", lSYU := .T.

Default cCod := "", cReg := ''

Begin Sequence
	
	dbSelectArea("SYU")
	For nInc := 1 TO ("SYU")->(FCount())
	    M->&(FIELDNAME(nInc)) := CRIAVAR(FIELDNAME(nInc))
	Next nInc
	
	If nModulo == 29
	   
	   If !cCod $ "56789AB"
	      cCod := ""	      
	   EndIf	   
	   
	   cMCodCad := cCod
	EndIf
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
		
		oEnc := MsMget():New("SYU",, nOpc,,,,,PosDlg(oDlg))
		
		If cCod $ "56789AB"
		   lSYU := TE110AtuBrowse(cReg)
		EndIf
		
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, bVal_OK, bCancel), oEnc:oBox:Align := CONTROL_ALIGN_ALLCLIENT)
	
	If nOp=1
	   SYU->(RecLock("SYU",lSYU))
	   AvReplace("M","SYU")
	   If SYU->(FieldPos("YU_ORIGEM")) > 0 .And. nModulo == 29 
	      SYU->YU_ORIGEM := "EEC"
	   EndIf
	   SYU->(MsUnlock())	   
	EndIf

End Sequence	
Return Nil

/*
Funcao     : TE110GeraBox()
Parametros : nModulo
Objetivos  : Preencher o ComboBox do campo "YU_TIP_CAD"
Autor      : Laercio G Souza Junior
Retorno    : cBuffer - que contem as opções do combo
Data/Hora  : 03/09/2015 - 13:13
*/
Function TE110GeraBox()
Local cBuffer := ""
	
	cMCodCad := IF(TYPE("cMCodCad" )<>"C","",cMCodCad)
	
	If nModulo == 17
	   cBuffer := "1=Importador;2=Fab/For;3=Agentes;5=Despachante"
	   
	ElseIf nModulo == 29  
		Do Case
		   Case cMCodCad == DESPACHANTE    //5
		        cBuffer := "5=Despachante"
		   Case cMCodCad == ACORDO			//6
		        cBuffer := "6=Acordo"
		   Case cMCodCad == EXPORTADOR		//7
		        cBuffer := "7=Exportador"
		   Case cMCodCad == UN_MEDIDA		//8
		        cBuffer := "8=Und.Medida"
		   Case cMCodCad == PRODUTO        //9
		        cBuffer := "9=Produto"
		   Case cMCodCad == NORMA          //10
		        cBuffer := "A=Norma"
		   Case cMCodCad == PAIS           //10
		        cBuffer := "B=Pais"
		   Case Empty(cMCodCad)				//Todas as opções
		        cBuffer := "5=Despachante;6=Acordo;7=Exportador;8=Und.Medida;9=Produto;A=Norma;B=Pais"
		EndCase
	EndIf
Return cBuffer

/*
Funcao     : TE110AtuBrowse()
Parametros : cRec - Tipo do cadastro
Objetivos  : Carregar as variaveis de memoria
Autor      : Laercio G Souza Junior
Retorno    : lRet - ().T./.F.)
Data/Hora  : 03/09/2015 - 13:13
*/
Static Function TE110AtuBrowse(cRec)
Local lRet := .T.
Local aInfoSYU := {} /*YU_DESP ,YU_TIP_CAD ,YU_EASY ,YU_LOJA ,YU_DESC*/
Local cEmpSY5  := AvKey(EasyGParam("MV_EEC0047",," "),"Y5_COD")
Default cRec := 0

Do Case
   Case cMCodCad == DESPACHANTE
        SY5->(DbSetOrder(1))
        SY5->(DbSeek(xFilial("SY5")+AvKey(cRec,"Y5_COD")))
        aaDD(aInfoSYU,{cEmpSY5, cMCodCad, SY5->Y5_COD,"",SY5->Y5_NOME})
               
   Case cMCodCad == ACORDO
        E11->(DbSetOrder(1))
        E11->(DbSeek(xFilial("E11") + cRec ))
        aaDD(aInfoSYU,{cEmpSY5, cMCodCad, E11->E11_CODACO,"",E11->E11_DESCRI})
        
   Case cMCodCad == EXPORTADOR
        SA2->(DbSetOrder(1))
        SA2->(DbSeek(xFilial("SA2") + cRec ))
        aaDD(aInfoSYU,{cEmpSY5, cMCodCad, SA2->A2_COD,SA2->A2_LOJA,SA2->A2_NOME})
        
   Case cMCodCad == UN_MEDIDA
        SAH->(DbSetOrder(1))
        SAH->(DbSeek(xFilial("SAH")+AvKey(cRec,"AH_UNIMED") ))
        aaDD(aInfoSYU,{cEmpSY5, cMCodCad, SAH->AH_UNIMED, "", SAH->AH_UMRES})
        
   Case cMCodCad == PRODUTO
        SB1->(DbSetOrder(1))
        SB1->(DbSeek(xFilial("SB1")+AvKey(cRec,"B1_COD") ))
        aaDD(aInfoSYU,{cEmpSY5, cMCodCad, SB1->B1_COD, "", SB1->B1_DESC})
     
   Case cMCodCad == NORMA
        EEI->(DbSetOrder(1))
        EEI->(DbSeek(xFilial("EEI")+AvKey(cRec,"EEI_COD") ))
        aaDD(aInfoSYU,{cEmpSY5, cMCodCad, EEI->EEI_COD, "", MSMM(EEI->EEI_DESC,35,1)})

   Case cMCodCad == PAIS
        SYA->(DbSetOrder(1))
        SYA->(DbSeek(xFilial("EEI")+AvKey(cRec,"YA_CODGI") ))
        aaDD(aInfoSYU,{cEmpSY5, cMCodCad, SYA->YA_CODGI, "", SYA->YA_DESCR})
        
EndCase

If (cMCodCad == DESPACHANTE .Or. cMCodCad == ACORDO .Or. cMCodCad == EXPORTADOR .Or.;
    cMCodCad == UN_MEDIDA .Or. cMCodCad == PRODUTO .Or. cMCodCad == NORMA .Or. cMCodCad == PAIS)
   M->YU_DESP	 := aInfoSYU[1][1]
   M->YU_TIP_CAD := aInfoSYU[1][2]
   M->YU_EASY	 := aInfoSYU[1][3]
   M->YU_LOJA	 := aInfoSYU[1][4]
   M->YU_DESC	 := aInfoSYU[1][5]
   
   SYU->(DbSetOrder(4))
   If SYU->(DbSeek(xFilial("SYU")+AvKey(M->YU_DESP,"YU_DESP")+AvKey(M->YU_TIP_CAD,"YU_TIP_CAD")+AvKey(M->YU_EASY,"YU_EASY")+"EEC" ))
      M->YU_GIP_1:= SYU->YU_GIP_1
      lRet := .F.
   EndIf
EndIf        
        
Return lRet