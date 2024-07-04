#INCLUDE "HSPAHF11.CH"
#include "protheus.CH"
#include "colors.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HSPAHF11 º Autor ³ Gilson da Silva    º Data ³  06/05/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Autorização de Doctos                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Modulo Gestao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSPAHF11()
Local cCab01    := ""

cTitulo   := STR0002 //"AUTORIZACAO DE DOCUMENTOS"
cNomeRel  := "HSPAHF11"
nLin      := 0

If nLastKey == 27
	Return(nil)
Endif

nTipo := If(aReturn[4]==1,15,18)

cCAB01 := STR0001 //"A U T O RI Z A C A O     D E      D O C U M E N T O S "

Cabec(cTitulo,	cCab01, "", cNomeRel, H44GetTam(), H44GetTip())

@ PROW()+07,00     PSAY PADC(STR0004,80)   // "A U T O R I Z A C A O"
@ PROW()   ,00     PSAY PADC(STR0004,80)   // "A U T O R I Z A C A O"
@ PROW()+07,02     PSAY STR0005 + PadR(AllTrim(GCY->GCY_NOME), 62, ".") + "," // "Eu, "
@ PROW()+02,02     PSAY STR0006 + PadR(AllTrim(aDadosEmp[1]), 55, ".") + "," // "Autorizo o "
@ PROW()+02,02     PSAY STR0007 // "a enviar copias  de  documentos  do  meu prontuario, a auditoria do"
@ PROW()+02,02     PSAY STR0008 // "convenio, do qual faco parte  relativas  ao  periodo em  que estive"
@ PROW()+02,02     PSAY STR0009 // "internado nesse hospital, para efeito de analise medico-financeira."
@ PROW()+07,20     PSAY aDadosEmp[4]+", "+strzero(DAY(ddatabase),2,0) + STR0003 + MesExtenso(ddatabase) + STR0003 + strzero(year(ddatabase),4,0)
@ PROW()+05,20     PSAY STR0010 // "NOME:_______________________________________"
@ PROW()+02,20     PSAY STR0011 // "R.G.:_________________________"
Return()
