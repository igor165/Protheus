// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC023B_Val.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 23.06.05 | 0739 Aline Correa do Vale (identico ao BSC023B_VAL.PRW)
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC023B_Val.ch"

/*--------------------------------------------------------------------------------------
@entity RPLANILHA
Valores de REFERENCIA armazenados das Indicadores.
Serão usados em todo o BSC para gerar estatisticas.
@table BSC023B
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "VALOR"
#define TAG_GROUP  "VALORES"
#define TEXT_ENTITY STR0001/*//"Valor"*/
#define TEXT_GROUP  STR0002/*//"Valores"*/

class TBSC023B from TBSCValueTable
	method New() constructor
	method NewBSC023B()
endclass
	
method New() class TBSC023B
	::NewBSC023B()
return
method NewBSC023B() class TBSC023B
	// Table
	::NewBSCValueTable("BSC023B")
	::cEntity("FCSRPLAN")
	
	// Atributos
	::fcTagEntity 	:= TAG_ENTITY
	::fcTagGroup 	:= TAG_GROUP
	::fcTextEntity 	:= TEXT_ENTITY
	::fcTextGroup 	:= TEXT_GROUP
return

function _BSC023b_Val()
return