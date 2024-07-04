#INCLUDE "protheus.ch"
#INCLUDE "quicksearch.ch"
#INCLUDE "GCPQ200.ch"

QSSTRUCT GCPQ20001 DESCRIPTION STR0001 MODULE 87	//-- Licitações em andamento

QSMETHOD INIT QSSTRUCT GCPQ20001

//-- Tabelas envolvidas na consulta e seus relacionamentos 
QSTABLE "CO1" JOIN "CO2"

//-- Campos/índices utilizados para a pesquisa
QSPARENTFIELD "CO1_CODEDT" INDEX ORDER 1 LABEL STR0002	//-- Código do Edital
QSPARENTFIELD "CO1_NUMPRO" INDEX ORDER 2 LABEL STR0003	//-- Número do Processo

//-- Opcoes de filtro
QSFILTER STR0004 WHERE "CO1_ETAPA <> 'FI'"							//-- Todos
QSFILTER STR0005 WHERE "CO1_ETAPA <> 'FI' AND CO1_DTPUBL = ' '"		//-- Não publicados
QSFILTER STR0006 WHERE "CO1_ETAPA <> 'FI' AND CO1_DTPUBL <> ' '"	//-- Publicados

//-- Campos da consulta rapida
QSFIELD "CO1_FILIAL" LABEL STR0007	//-- Empresa
QSFIELD "CO1_CODEDT" LABEL STR0008	//-- Código do Edital
QSFIELD "CO1_NUMPRO" LABEL STR0009	//-- Número do Processo
QSFIELD "MODALI" BLOCK {|| Tabela("LF",M->CO1_MODALI,.F.)} FIELDS "CO1_MODALI" LABEL STR0010 TYPE "C" SIZE 25	//-- Modalidade
QSFIELD "TIPO" BLOCK {|| Tabela("LG",M->CO1_TIPO,.F.)} FIELDS "CO1_TIPO" LABEL STR0011	TYPE "C" SIZE 25 //-- Tipo de Modalidade
QSFIELD "ETAPA" BLOCK {|| Tabela("LE",M->CO1_ETAPA,.F.)} FIELDS "CO1_ETAPA" LABEL STR0012	TYPE "C" SIZE 25	//-- Etapa Atual
QSFIELD SUM "CO2_VLESTI * CO2_QUANT" LABEL STR0013	//-- Valor Estimado 

//-- Acoes relacionadas
QSACTION MENUDEF "GCPA200" OPERATION 2 LABEL STR0014	//-- Detalhes do Edital

Return
