// ######################################################################################
// Projeto: BI Library
// Modulo : Include
// Fonte  : BIDefs.ch
// -----------+-------------------+------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+------------------------------------------------------
// 15.04.2003   BI Development Team 
// --------------------------------------------------------------------------------------

#include "fileio.ch"
#include "msobject.ch"
#include "xmlxfun.ch"
#include "topconn.ch"

/*----------------------------------------------------------------------------------------
Definição de eventos de TBITable
-----------------------------------------------------------------------------------------*/
#ifndef _TABLE_CH
#define _TABLE_CH

#define FE_BEFORE             -1
#define FE_DURING             0
#define FE_AFTER              1
#define FE_APPEND             2
#define FE_UPDATE             3
#define FE_DELETE             4
#define FE_VALIDATE           5
#define FE_LOCK               6
#define FE_UNLOCK             7
#define FE_RECALL             8
#endif

/*----------------------------------------------------------------------------------------
Definição de eventos de formatos de registros de TBITable
-----------------------------------------------------------------------------------------*/
#define RF_ARRAY        1 
#define RF_ARRAYSTR     2
#define RF_STRSIZE      3
#define RF_STRSDF       4
#define RF_STRCRLF      5
#define RF_WWWURLENCODE 6
#define RF_STRTAB       7
#define RF_ARRAYFLD     8
#define RF_ARRAYOBJ     9
#define RF_ARRAYDOC    10

/*----------------------------------------------------------------------------------------
Definição de erros de TBITable
-----------------------------------------------------------------------------------------*/
#define DBERROR_OK			0 
#define DBERROR_LOCK		1 
#define DBERROR_UNIQUE		2
#define DBERROR_VALID		3

/*----------------------------------------------------------------------------------------*/
                            
#xcommand property <propname> := <value>;
	=> <propname> := iif(valType(<value>)=="U", <propname>, <value>)

#xcommand abstract;
	=> ExUserException("Abstract method in " + ::ClassName())

#define CRLF chr(13)+chr(10)