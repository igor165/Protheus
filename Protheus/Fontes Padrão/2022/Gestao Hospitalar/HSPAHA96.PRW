#INCLUDE "HSPAHA96.ch"
#include "protheus.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHA96  º Autor ³ Gilson da Silva    º Data ³  18/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ CADASTRO DE MOTIVOS DE CANCELAMENTO DE UM AGENDAMENTO.     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHA96()
 Private cAlias := "GM7"
 DbSelectArea(cAlias)
 DbSetOrder(1)
 AxCadastro(cAlias, STR0001, "Fs_Exc96()") //"Cadastro de Motivos de Cancelamento do Agendamento"
Return

// Funcao de Exclusao
Function Fs_Exc96()
 Local lRet := .T.
 DbSelectArea("GM9")
 DbSetOrder(2)
 If DbSeek(xFilial("GM9") + GM7->GM7_CODCAN)
  HS_MsgInf(STR0002, STR0004, STR0005)     //"Este Codigo esta sendo usado pela Tabela de Agendamentos Cancelados(GM9).Impossivel Exclui-lo!"###"Atencao"###"Exclusão não Permitida"
  lRet := .F.
 Endif
	DbSelectArea("GMA")
 DbSetOrder(2)
 If DbSeek(xFilial("GMA") + GM7->GM7_CODCAN)
  HS_MsgInf(STR0003, STR0004, STR0005)     //"Este Codigo esta sendo usado pela Tabela de Agendamentos Transferidos(GMA).Impossivel Exclui-lo!"###"Atencao"###"Exclusão não Permitida"
  lRet := .F.
 Endif
 DbSelectArea(cAlias)
Return(lRet)