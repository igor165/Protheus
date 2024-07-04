#INCLUDE "plsm100.ch"

#include "PLSMGER.CH"
#include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSM100 ³ Autor ³ Eduardo Motta          ³ Data ³ 26.10.01 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Configuracao do Relatorio de Planos                        ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSM100()                                                  ³±±±
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
Function PLSM100()
                  
PlsConfRe(STR0001,"PLSR040","PLSM100DEF") //"Configuracao do Relatorio de Planos"
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³PlsM010Def³ Autor ³ Eduardo Motta	  	    ³ Data ³ 29/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera array dos cabecalhos e itens com valores DEFAULT      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ PlsM010Def(aListCab,aListIte)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsM100Def(aListCab,aListIte)
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

aListCab  := {	{.T.,STR0002,"BI3","","",".T.",{},"1"},; //"Plano de Saude"
         		{.T.,STR0003       ,"BIL","","",".T.",{},"1"}} //"Versoes"

aListIte  :={	{.T.,STR0004		,"BRX","xFilial('BRX')+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)","BRX->BRX_FILIAL+BRX->BRX_CODPLA+BRX->BRX_VERSAO == xFilial('BRX')+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)",".T.",{},"1"},; //"Tipo Padrao de Saude"
		  	 		{.T.,STR0005	,"BRV","xFilial('BRV')+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)","BRV->BRV_FILIAL+BRV->BRV_CODPLA+BRV->BRV_VERSAO == xFilial('BRV')+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)",".T.",{},"1"},; //"Grupos Determinados"
					{.T.,STR0006	,"BB2","xFilial('BB2')+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)","BB2->BB2_FILIAL+BB2->BB2_CODIGO+BB2->BB2_VERSAO == xFilial('BB2')+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)",".T.",{},"1"},; //"Procedimentos"
					{.T.,STR0007	,"BB6","xFilial('BB6')+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)","BB6->BB6_FILIAL+BB6->BB6_CODIGO+BB6->BB6_VERSAO == xFilial('BB6')+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)",".T.",{},"1"},; //"Rede de Atendimento"
					{.T.,STR0008	,"BJ3","xFilial('BJ3')+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)","BJ3->BJ3_FILIAL+BJ3->BJ3_CODIGO+BJ3->BJ3_VERSAO == xFilial('BJ3')+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)",".T.",{},"1"},; //"Cobranca"
					{.T.,STR0009	,"BRU","xFilial('BRU')+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)","BRU->BRU_FILIAL+BRU->BRU_CODIGO+BRU->BRU_VERSAO == xFilial('BRU')+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)",".T.",{},"1"},; //"Rede Referenciada"
					{.T.,STR0010	,"BRZ","xFilial('BRZ')+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)","BRZ->BRZ_FILIAL+BRZ->BRZ_CODPLA+BRZ->BRZ_VERSAO == xFilial('BRZ')+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)",".T.",{},"1"},; //"Tratamento de Debitos"
					{.T.,STR0011	,"BRY","xFilial('BRY')+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)","BRY->BRY_FILIAL+BRY->BRY_CODPLA+BRY->BRY_VERSAO == xFilial('BRY')+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)",".T.",{},"1"}} //"Taxa de Adesao"

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

