#INCLUDE "plsm010.ch"
#include "PLSMGER.CH"
#include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSM010 ³ Autor ³ Eduardo Motta          ³ Data ³ 03.07.01 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Configuracao do Relatorio de Rede de Atendimento           ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSM010()                                                  ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial                               ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSM010()
PlsConfRe(OemtoAnsi(STR0001),"PLSR020","PLSM010DEF") //"Configuracao do Relatorio da Rede de Atendimento"
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³PlsM010Def³ Autor ³ Eduardo Motta	   	  ³ Data ³ 29/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera array dos cabecalhos e itens com valores DEFAULT      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ PlsM010Def(aListCab,aListIte)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 		                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsM010Def(aListCab,aListIte)
Local nI := 0

/*
Estrutura dos arrays aListCab e aListIte
[1] - Selecionado
[2] - Descricao
[3] - Alias
[4] - Chave a pesquisar inicialmente
[5] - Condicao do While
[6] - Condicao de impressao da linha
[7] - Campos (aCampos)
[8] - Indice a ser usado

Estrutura do aCampos
[1] - Selecionado
[2] - Nome do Campo
[3] - Ordem
[4] - Titulo
[5] - Expressao do campo
[6] - Tamanho do campo

*/

aListCab  := {{.T.,OemtoAnsi(STR0002),"BAU","","",".T.",{},"1"}} //"Operadora"

aListIte  :={   {.T.,OemtoAnsi(STR0003)		,"BAW","xFilial('BAU')+BAU->BAU_CODIGO","BAW->BAW_FILIAL+BAW->BAW_CODIGO==xFilial('BAW')+BAU->BAU_CODIGO",".T.",{},"1"},; //"Operadora  "
					{.T.,OemtoAnsi(STR0006)	,"BB8","xFilial('BAU')+BAU->BAU_CODIGO","BB8->BB8_FILIAL+BB8->BB8_CODIGO==xFilial('BB8')+BAU->BAU_CODIGO",".T.",{},"1"},; //"Local de Atendimento"
					{.T.,OemtoAnsi(STR0007)	,"BC0","xFilial('BAU')+BAU->BAU_CODIGO","BC0->BC0_FILIAL+BC0->BC0_CODIGO==xFilial('BC0')+BAU->BAU_CODIGO",".T.",{},"1"},; //"Procecimentos Autorizados"
					{.T.,OemtoAnsi(STR0009)	,"BC1","xFilial('BAU')+BAU->BAU_CODIGO","BC1->BC1_FILIAL+BC1->BC1_CODIGO==xFilial('BC1')+BAU->BAU_CODIGO",".T.",{},"1"},; //"Medicos"
					{.T.,OemtoAnsi(STR0010)	,"BE6","xFilial('BAU')+BAU->BAU_CODIGO","BE6->BE6_FILIAL+BE6->BE6_CODIGO==xFilial('BE6')+BAU->BAU_CODIGO",".T.",{},"1"},; //"Procedimentos por Medico"
					{.T.,OemtoAnsi(STR0011)	,"BAX","xFilial('BAU')+BAU->BAU_CODIGO","BAX->BAX_FILIAL+BAX->BAX_CODIGO==xFilial('BAX')+BAU->BAU_CODIGO",".T.",{},"1"},; //"Especialidades por Local"
					{.T.,OemtoAnsi(STR0012)	,"BBG","xFilial('BAU')+BAU->BAU_CODIGO","BBG->BBG_FILIAL+BBG->BBG_CODIGO==xFilial('BBG')+BAU->BAU_CODIGO",".T.",{},"1"},; //"Contatos"
					{.T.,OemtoAnsi(STR0013)	,"BBI","xFilial('BAU')+BAU->BAU_CODIGO","BBI->BBI_FILIAL+BBI->BBI_CODIGO==xFilial('BBI')+BAU->BAU_CODIGO",".T.",{},"1"},; //"Planos"
					{.T.,OemtoAnsi(STR0014)	,"BBK","xFilial('BAU')+BAU->BAU_CODIGO","BBK->BBK_FILIAL+BBK->BBK_CODIGO==xFilial('BBK')+BAU->BAU_CODIGO",".T.",{},"1"},; //"Redes de Atendimento"
					{.T.,OemtoAnsi(STR0015)	,"BBN","xFilial('BAU')+BAU->BAU_CODIGO","BBN->BBN_FILIAL+BBN->BBN_CODIGO==xFilial('BBN')+BAU->BAU_CODIGO",".T.",{},"1"},; //"Procedimentos nao autorizados"
					{.T.,OemtoAnsi(STR0017)	,"BBF","xFilial('BAU')+BAU->BAU_CODIGO","BBF->BBF_FILIAL+BBF->BBF_CODIGO==xFilial('BBF')+BAU->BAU_CODIGO",".T.",{},"1"},; //"Especialidades"
					{.T.,OemtoAnsi(STR0018)	,"BC8","xFilial('BAU')+BAU->BAU_CODIGO","BC8->BC8_FILIAL+BC8->BC8_CODIGO==xFilial('BC8')+BAU->BAU_CODIGO",".T.",{},"1"},; //"Documentos"
					{.T.,OemtoAnsi(STR0019)	,"BBE","xFilial('BAU')+BAU->BAU_CODIGO","BBE->BBE_FILIAL+BBE->BBE_CODIGO==xFilial('BBE')+BAU->BAU_CODIGO",".T.",{},"1"},; //"Dependentes"
					{.T.,OemtoAnsi(STR0020)	,"BBC","xFilial('BAU')+BAU->BAU_CODIGO","BBC->BBC_FILIAL+BBC->BBC_CODIGO==xFilial('BBC')+BAU->BAU_CODIGO",".T.",{},"1"}} //"Servicos Contratados"

For nI := 1 to Len(aListCab)
   aCampos := PlsRelDic(aListCab[nI,3])
   aListCab[nI,7] := aClone(aCampos)
Next   
For nI := 1 to Len(aListIte)
   If Empty(aListIte[nI,3])
      Loop
   EndIf   
   aCampos := PlsRelDic(aListIte[nI,3])
   aListIte[nI,7] := aClone(aCampos)
Next   

Return

