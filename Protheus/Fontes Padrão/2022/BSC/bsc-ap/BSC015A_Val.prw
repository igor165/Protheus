// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC015A_Val.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC015A_Val.ch"

/*--------------------------------------------------------------------------------------
@entity PLANILHA
Valores armazenados das Indicadores.
Serão usados em todo o BSC para gerar estatisticas.
@table BSC015A
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "VALOR"
#define TAG_GROUP  "VALORES"
#define TEXT_ENTITY STR0001/*//"Valor"*/
#define TEXT_GROUP  STR0002/*//"Valores"*/

class TBSC015A from TBSCValueTable
	method New() constructor
	method NewBSC015A()
endclass
	                            
method New() class TBSC015A
	::NewBSC015A()
return
method NewBSC015A() class TBSC015A
	// Table
	::NewBSCValueTable("BSC015A")
	::cEntity("PLANILHA")
	
	// Atributos
	::fcTagEntity 	:= TAG_ENTITY
	::fcTagGroup 	:= TAG_GROUP
	::fcTextEntity 	:= TEXT_ENTITY
	::fcTextGroup 	:= TEXT_GROUP
return

function _BSC015A_Val()
return
