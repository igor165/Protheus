#INCLUDE "protheus.ch"
#INCLUDE "quicksearch.ch"
#INCLUDE "MATQ110.ch"

QSSTRUCT MATQ11001 DESCRIPTION STR0001 MODULE 2 //-- Solicita��es de compra em aberto

QSMETHOD INIT QSSTRUCT MATQ11001

//-- Tabelas envolvidas na consulta e seus relacionamentos
QSTABLE "SC1" JOIN "SB1" ON "B1_COD = C1_PRODUTO"
QSTABLE "SC1" LEFT JOIN "SB5" ON "B5_COD = C1_PRODUTO"

//-- Campos/�ndices utilizados para a pesquisa 
QSPARENTFIELD "C1_PRODUTO" INDEX ORDER 2 LABEL STR0002	//-- C�digo do Produto
QSPARENTFIELD "C1_NUM" INDEX ORDER 1 LABEL STR0003	//-- N�mero da Solicita��o
QSPARENTFIELD "C1_SOLICIT" INDEX ORDER 12 LABEL STR0004 //-- Solicitante
QSPARENTFIELD "B1_DESC" INDEX ORDER 3 SET RELATION TO "C1_PRODUTO" WITH "B1_COD" LABEL STR0005	//-- Descri��o do Produto
QSPARENTFIELD "B5_CEME" INDEX ORDER 7 SET RELATION TO "C1_PRODUTO" WITH "B5_COD" LABEL STR0006	//-- Descri��o Complementar do Produto

//-- Opcoes de filtro
QSFILTER STR0007 WHERE "C1_QUJE < C1_QUANT AND C1_RESIDUO <> 'S' AND C1_FLAGGCT <> '1' AND C1_EMISSAO >= '" +DToS(Date() - 30) +"'"	//-- �ltimos 30 dias
QSFILTER STR0008 WHERE "C1_QUJE < C1_QUANT AND C1_RESIDUO <> 'S' AND C1_FLAGGCT <> '1' AND C1_EMISSAO >= '" +DToS(Date() - 60) +"'"	//-- �ltimos 60 dias
QSFILTER STR0009 WHERE "C1_QUJE < C1_QUANT AND C1_RESIDUO <> 'S' AND C1_FLAGGCT <> '1' AND C1_EMISSAO >= '" +DToS(Date() - 90) +"'"	//-- �ltimos 90 dias
QSFILTER STR0010 WHERE "C1_QUJE < C1_QUANT AND C1_RESIDUO <> 'S' AND C1_FLAGGCT <> '1' AND C1_EMISSAO >= '" +DToS(Date() - 120) +"'"	//-- �ltimos 120 dias
QSFILTER STR0011 WHERE "C1_QUJE < C1_QUANT AND C1_RESIDUO <> 'S' AND C1_FLAGGCT <> '1' AND C1_EMISSAO >= '" +DToS(Date() - 360) +"'"	//-- �ltimos 360 dias
QSFILTER STR0012 WHERE "C1_QUJE < C1_QUANT AND C1_RESIDUO <> 'S' AND C1_FLAGGCT <> '1'"	//-- Todos

//-- Campos da consulta rapida
QSFIELD "C1_FILIAL" LABEL STR0013	//-- Empresa
QSFIELD "C1_NUM" LABEL STR0003		//-- N�mero da Solicita��o
QSFIELD "C1_SOLICIT" LABEL STR0004	//-- Solicitante
QSFIELD "C1_PRODUTO" LABEL STR0002	//-- C�digo do Produto
QSFIELD "B1_DESC" LABEL STR0005		//-- Descri��o do Produto
QSFIELD "B5_CEME" LABEL STR0006		//-- Descri��o Complementar do Produto
QSFIELD "SALDO" EXPRESSION "C1_QUANT - C1_QUJE" LABEL STR0014 FIELDS "C1_QUANT","C1_QUJE" TYPE "N" SIZE TamSX3("C1_QUANT")[1] DECIMAL TamSX3("C1_QUANT")[2] PICTURE PesqPict("SC1","C1_QUANT")	//-- Quantidade
QSFIELD "LEGENDA" BLOCK {|| MTQ110Leg()} FIELDS "C1_QUANT","C1_QUJE","C1_COTACAO","C1_CODED" LABEL STR0015 TYPE "C" SIZE 50	//-- Status 

//-- Acoes relacionadas
QSACTION MENUDEF "MATA110" OPERATION 2 LABEL STR0016	//-- Detalhes da Solicita��o
QSACTION MENUDEF "MATA010" OPERATION 2 LABEL STR0017	//-- Detalhes do Produto

Return

Function MTQ110Leg()
Local cRet := ""

Do Case
	Case C1_QUJE < C1_QUANT 
		cRet := STR0018	//-- Parcialmente Atendida
	Case !Empty(C1_COTACAO)
		cRet := STR0019	//-- Em Cota��o
	Case !Empty(C1_CODED)
		cRet := STR0020	//-- Em Edital
	Otherwise
		cRet := STR0021	//-- Pendente
EndCase

Return cRet
