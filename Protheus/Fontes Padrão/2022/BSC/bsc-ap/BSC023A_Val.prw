// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC023A_Val.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 23.06.05 | 0739 Aline Correa do Vale (identico ao BSC015A_VAL.PRW)
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC023A_Val.ch"

/*--------------------------------------------------------------------------------------
@entity PLANILHA
Valores armazenados das Indicadores.
Serão usados em todo o BSC para gerar estatisticas.
@table BSC023A
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "VALOR"
#define TAG_GROUP  "VALORES"
#define TEXT_ENTITY STR0001/*//"Valor"*/
#define TEXT_GROUP  STR0002/*//"Valores"*/

class TBSC023A from TBSCValueTable
	method New() constructor
	method NewBSC023A()
endclass
	                            
method New() class TBSC023A
	::NewBSC023A()
return
method NewBSC023A() class TBSC023A
	// Table
	::NewBSCValueTable("BSC023A")
	::cEntity("FCSPLAN")
	
	// Atributos
	::fcTagEntity 	:= TAG_ENTITY
	::fcTagGroup 	:= TAG_GROUP
	::fcTextEntity 	:= TEXT_ENTITY
	::fcTextGroup 	:= TEXT_GROUP
return

function _BSC023a_Val()
return