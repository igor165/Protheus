#INCLUDE "HSPAHF09.ch"
#include "protheus.CH"
#include "colors.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HSPAHF09 º Autor ³ Gilson da Silva    º Data ³  06/05/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ficha de Anotações de Enfermagem                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Modulo Gestao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSPAHF09()
 Local nCont := 0
 Local cCab01    := ""

 cTitulo   := STR0002 //"ANOTACOES DE ENFERMAGEM"
 cNomeRel  := "HSPAHF09"
 nLin      := 0

 If nLastKey == 27
	 Return(nil)
 Endif

 nTipo := If(aReturn[4]==1,15,18)

 cCAB01 := STR0001 //"F O R M U L A R I O     D E      A N O T A C A O      D E     E N F E R M A G E M "

 Cabec(cTitulo,	cCab01, "", cNomeRel, H44GetTam(), H44GetTip())

 @ PROW()+01,00     PSAY STR0003 + GCY->GCY_REGATE + "   " + GCY->GCY_NOME + "        " + STR0004 + GCY->GCY_QUAINT+"/"+GCY->GCY_LEIINT //"Registro.: "###"      Leito: " @ PROW()+03,00     PSAY PADC("A N O T A C O E S   D E   E N F E R M A G E M",80) 
 @ PROW()+03,00     PSAY PADC(STR0005,132)//"A N O T A C O E S   D E   E N F E R M A G E M"
 @ PROW()   ,00     PSAY PADC(STR0005,132)//"A N O T A C O E S   D E   E N F E R M A G E M"
 @ prow()+2,00      PSAY STR0006 //"+-------------+----------------------------------------------------------------------------------------------------------------+"
 @ prow()+1,00      PSAY STR0007 //"|   DATA      |                                                                                                                |"
 @ prow()+1,00      PSAY STR0006
 For nCont = 1 to 26   
  @ prow()+1,00     PSAY STR0008 //"|             |                                                                                                                |"
  @ prow()+1,00     PSAY STR0006
 Next
Return()
