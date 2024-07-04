#INCLUDE "protheus.ch"
#INCLUDE "quicksearch.ch"
#INCLUDE "MATQ225.ch"

QSSTRUCT MATQ22501 DESCRIPTION STR0001 MODULE 4	//-- Saldos em estoque

QSMETHOD INIT QSSTRUCT MATQ22501

//-- Tabelas envolvidas na consulta e seus relacionamentos
QSTABLE "SB1" JOIN "SB2" ON "B2_COD = B1_COD"

//-- Campos/índices utilizados para a pesquisa
QSPARENTFIELD "B1_COD" INDEX ORDER 1 LABEL STR0002	//-- Código do Produto
QSPARENTFIELD "B1_DESC" INDEX ORDER 3 LABEL STR0003	//-- Descrição do Produto

//-- Opcoes de filtro
QSFILTER STR0004 WHERE "B1_COD <> ''"	//-- Todos
QSFILTER STR0005 WHERE "B2_QATU > 0"	//-- Com saldo
QSFILTER STR0006 WHERE "B2_QATU <= 0"	//-- Sem saldo

//-- Campos da consulta rapida
QSFIELD "B2_FILIAL" LABEL STR0007	//-- Empresa
QSFIELD "B2_COD" LABEL STR0002		//-- Código do Produto
QSFIELD "B1_DESC" LABEL STR0003		//-- Descrição do Produto
QSFIELD SUM "B2_QATU" LABEL STR0008	//-- Saldo Atual
QSFIELD "B1_EMIN" LABEL STR0009		//-- Ponto de Pedido
QSFIELD "ESTSEG" BLOCK {|| CalcEstSeg(RetFldProd(B2_COD,"B1_ESTFOR"))} FIELDS "B1_COD","B1_ESTSEG","B1_ESTFOR" LABEL STR0010 TYPE "N" SIZE 8	//-- Estoque de Segurança
QSFIELD SUM "B2_SALPEDI" LABEL STR0011	//-- Quantidade Prevista de Entrada

//-- Acoes relacionadas
QSACTION MENUDEF "MATA010" OPERATION 2 LABEL STR0012	//-- Detalhes do Produto
QSACTION "MAViewSB2" LABEL STR0013	//-- Detalhes do Estoque

Return