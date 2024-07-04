// ######################################################################################
// Projeto: iReport
// Modulo : Core
// Fonte  : iReportDefs.ch
// -----------+-------------------+------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+------------------------------------------------------
// 23.11.2006   1776. Alexandre Alves da Silva
// --------------------------------------------------------------------------------------

//Constantes que identificam a marca em que o iReport esta funcionado.
#define MICROSIGA		1
#define LOGOCENTER		2
#define RM				3

//Nome do arquivo de internacionalizacao
#IFDEF SPANISH
	#define INTER_FILE_NAME "microsiga_international_es.properties"
	#define IREP_LOCATION "es"	
#ELSE
	#IFDEF ENGLISH
		#define INTER_FILE_NAME "microsiga_international_en.properties"
		#define IREP_LOCATION "en"		
	#ELSE
		#define INTER_FILE_NAME "microsiga_international_pt_br.properties"
		#define IREP_LOCATION "pt_br"		
	#ENDIF
#ENDIF

//Constantes que identificam o tipo do banco de dados.
#define CONN_ODBC	"0"
#define CONN_MSSQL	"1"
#define CONN_ORACLE	"2"
#define CONN_DB2	"3"
#define CONN_DB2400 "3"

// constantes de caminhos/paths para o iReport
#define IREPORTS_PROTHEUS 	"\iReport"
#define REPORTS_PATH 		IREPORTS_PROTHEUS + "\reports"
#define IREPORTS_LIB 		IREPORTS_PROTHEUS + "\lib"     
#define IREPORTS_JDBC 		IREPORTS_PROTHEUS + "\jdbc"