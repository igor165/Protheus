// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC015B_Val.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC015B_Val.ch"

/*--------------------------------------------------------------------------------------
@entity RPLANILHA
Valores de REFERENCIA armazenados das Indicadores.
Serão usados em todo o BSC para gerar estatisticas.
@table BSC015B
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "VALOR"
#define TAG_GROUP  "VALORES"
#define TEXT_ENTITY STR0001/*//"Valor"*/
#define TEXT_GROUP  STR0002/*//"Valores"*/

class TBSC015B from TBSCValueTable
	method New() constructor
	method NewBSC015B()
endclass
	
method New() class TBSC015B
	::NewBSC015B()
return
method NewBSC015B() class TBSC015B
	// Table
	::NewBSCValueTable("BSC015B")
	::cEntity("RPLANILHA")
	
	// Atributos
	::fcTagEntity 	:= TAG_ENTITY
	::fcTagGroup 	:= TAG_GROUP
	::fcTextEntity 	:= TEXT_ENTITY
	::fcTextGroup 	:= TEXT_GROUP
return

function _BSC015b_Val()
return