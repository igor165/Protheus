#INCLUDE "plsm090.ch"

#include "PLSMGER.CH"
#include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSM090 ³ Autor ³ Marco Paulo            ³ Data ³ 13.11.01 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Configuracao do Relatorio de Produtos de Saude             ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSM090()                                                  ³±±±
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
Function PLSM090()
PlsConfRe(STR0001,"PLSR080","PLSM090DEF") //"Configuracao do Relatorio de Produtos de Saude"
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³PlsM090Def³ Autor ³ Marco Paulo           ³ Data ³ 13/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera array dos cabecalhos e itens com valores DEFAULT      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ PlsM090Def(aListCab,aListIte)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 		                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsM090Def(aListCab,aListIte)
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

aListCab  := {{.T.,STR0002,"BI3","","","AllwaysTrue()",{},"1"}} //"Produtos de Saude"

aListIte  :={	{.T.,STR0004,"BRV","xFilial('BI3')+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO","BRV->BRV_FILIAL+BRV->BRV_CODPLA+BRV->BRV_VERSAO==xFilial('BRV')+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO","AllwaysTrue()",{},"1"},; //"Cobertura/Carencia - Grupos Determinaddos"
				{.T.,STR0005,"BB2","xFilial('BI3')+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO","BB2->BB2_FILIAL+BB2->BB2_CODIGO+BB2->BB2_VERSAO==xFilial('BB2')+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO","AllwaysTrue()",{},"1"},; //"Cobertura/Carencia -	Procedimentos"
				{.T.,STR0006,"BB6","xFilial('BI3')+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO","BB6->BB6_FILIAL+BB6->BB6_CODIGO+BB6->BB6_VERSAO==xFilial('BB6')+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO","AllwaysTrue()",{},"1"},; //"Rede de Atendimento"
				{.T.,STR0007,"BT1","xFilial('BI3')+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO","BT1->BT1_FILIAL+BT1->BT1_CODIGO+BT1->BT1_VERSAO==xFilial('BT1')+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO","AllwaysTrue()",{},"1"},; //"Usuarios Permitidos"
				{.T.,STR0008,"BJ3","xFilial('BI3')+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO","BJ3->BJ3_FILIAL+BJ3->BJ3_CODIGO+BJ3->BJ3_VERSAO==xFilial('BJ3')+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO","AllwaysTrue()",{},"1"},; //"Cobranca"
				{.T.,STR0009,"BIL","xFilial('BI3')+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO","BIL->BIL_FILIAL+BIL->BIL_CODIGO+BIL->BIL_VERSAO==xFilial('BIL')+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO","AllwaysTrue()",{},"1"},; //"Versoes"
				{.T.,STR0006,"BRU","xFilial('BI3')+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO","BRU->BRU_FILIAL+BRU->BRU_CODIGO+BRU->BRU_VERSAO==xFilial('BRU')+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO","AllwaysTrue()",{},"1"},; //"Rede de Atendimento"
				{.T.,STR0010,"BRZ","xFilial('BI3')+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO","BRZ->BRZ_FILIAL+BRZ->BRZ_CODPLA+BRZ->BRZ_VERSAO==xFilial('BRZ')+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO","AllwaysTrue()",{},"1"},; //"Tratamento Debitos"
				{.T.,STR0011,"BRY","xFilial('BI3')+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO","BRY->BRY_FILIAL+BRY->BRY_CODPLA+BRY->BRY_VERSAO==xFilial('BRY')+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO","AllwaysTrue()",{},"1"},; //"Taxa de Adesao"
				{.T.,STR0012,"BT3","xFilial('BI3')+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO","BT3->BT3_FILIAL+BT3->BT3_CODIGO+BT3->BT3_VERSAO==xFilial('BT3')+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO","AllwaysTrue()",{},"1"},; //"Produtos Agregados"
				{.T.,STR0013,"BT4","xFilial('BI3')+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO","BT4->BT4_FILIAL+BT4->BT4_CODIGO+BT4->BT4_VERSAO==xFilial('BT4')+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO","AllwaysTrue()",{},"1"}}  //"Fornecedores Parceiros"

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

