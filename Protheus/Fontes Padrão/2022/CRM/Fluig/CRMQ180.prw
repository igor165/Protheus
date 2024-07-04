#include "CRMQ180.CH"
#include "protheus.ch"
#include "quicksearch.ch"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMQ180

Consulta Rápida (Quick View) de Atividades Abertas

@param		Nenhum
	
@return	Nenhum 

@author	Vendas CRM
@since		20/05/2014       
@version	P12   
/*/
//------------------------------------------------------------------------------

QSSTRUCT CRMQ180 DESCRIPTION STR0001 MODULE 5   //"Atividades Abertas"

QSMETHOD INIT QSSTRUCT CRMQ180

Local cWhere
	
	QSTABLE "AOF"
	
	// campos do SX3 e indices do SIX
	QSPARENTFIELD "AOF_ENTIDA" INDEX ORDER 4
	
	// campos do SX3
	QSFIELD "AOF_ASSUNT", "AOF_DTINIC", "AOF_DTFIM"
	
	QSFIELD "AOF_TIPO" ;
	EXPRESSION "CASE WHEN AOF.AOF_TIPO = '1' THEN 'TAREFA' WHEN AOF.AOF_TIPO = '2' THEN 'COMPROMISSO' WHEN AOF.AOF_TIPO = '3' THEN 'EMAIL' END" ;
	LABEL STR0002 FIELDS "AOF.AOF_TIPO" TYPE "C" SIZE 30 //"Tipo"

	QSFIELD "AOF_TIPO" ;
	EXPRESSION "CASE WHEN AOF.AOF_TIPO = '1' THEN '" + STR0003 + ;  //"Tarefa"
		"' WHEN AOF.AOF_TIPO = '2' THEN '" + STR0004 + ;  //"Compromisso"
		"' WHEN AOF.AOF_TIPO = '3' THEN '" + STR0005 + "' END" ;  //"E-mail"
	LABEL STR0006 FIELDS "AOF.AOF_TIPO" TYPE "C" SIZE 30  //"Tipo"
	
	QSFIELD "AOF_STATUS" ; 
	EXPRESSION "CASE WHEN AOF.AOF_STATUS = '1' THEN '" + STR0007 + ; //"Não iniciado"
		"' WHEN AOF.AOF_STATUS = '2' THEN '" + STR0008 + ;  //"Em andamento"
		"' WHEN AOF.AOF_STATUS = '4' THEN '" + STR0009 + ;  //"Aguardando outros"
		"' WHEN AOF.AOF_STATUS = '5' THEN '" + STR0010 + ;  //"Adiada"
		"' WHEN AOF.AOF_STATUS = '6' THEN '" + STR0011 + "' END" ;  //"Pendente"
	LABEL STR0012 FIELDS "AOF.AOF_STATUS" TYPE "C" SIZE 30 //"Status"

	QSFIELD "AOF_PRIORI" ; 
	EXPRESSION "CASE WHEN AOF.AOF_PRIORI = '1' THEN '" + STR0013 + ;  //"Alta"
		"' WHEN AOF.AOF_PRIORI = '2' THEN '" + STR0014 + ;  //"Normal"
		"' WHEN AOF.AOF_PRIORI = '3' THEN '" + STR0015 + "' END" ;  //"Baixa"
	LABEL STR0016 FIELDS "AOF.AOF_PRIORI" TYPE "C" SIZE 20  //"Prioridade"

	QSACTION MENUDEF "CRMA180" OPERATION 2 LABEL STR0017  //"Visualizar Atividade"
	
	cWhere := 	"AOF.AOF_STATUS NOT IN('3','7','8') AND AOF.AOF_DTFIM >= '" + DTOS(Date()) + "'" +;
				"AND AOF.AOF_DTFIM <= '{1}' AND AOF.AOF_CODUSR = '" + __cUserId + "'"
	
	QSFILTER STR0018 WHERE StrTran(cWhere, "{1}", DTOS(Date()))   //"Hoje"
	
	QSFILTER STR0019 WHERE StrTran(cWhere, "{1}", DTOS(Date() + 7))   //"Próximos 7 dias"
	
	QSFILTER STR0020 WHERE StrTran(cWhere, "{1}", DTOS(Date() + 30))   //"Próximos 30 dias"
	
	QSFILTER STR0021 WHERE StrTran(cWhere, "{1}", DTOS(Date() + 60))   //"Próximos 60 dias"
	
Return
