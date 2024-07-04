// ######################################################################################
// Projeto: BSC
// Modulo : Core
// Fonte  : BSCDatabase - Rotinas para controle do base de dados do bsc
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"

/*-------------------------------------------------------------------------------------
@class TBSC001
@entity Parametro
Tabela com os flags de controle.
@table BSC001
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "PARAMETRO"
#define TAG_GROUP  "PARAMETROSS"
#define TEXT_ENTITY "Parâmetro"
#define TEXT_GROUP  "Parâmetros"

class TBSC001 from TBITable
	method New() constructor
	method NewBSC001() 
endclass
	
method New() class TBSC001
	::NewBSC001()
return
method NewBSC001() class TBSC001
	// Table
	::NewTable("BSC001")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("CHAVE",	"C",	16))
	::addField(TBIField():New("TIPO",	"C",	1))
	::addField(TBIField():New("DADO",	"C",	255))
	// Indexes
	::addIndex(TBIIndex():New("BSC001I01",	{"CHAVE"},	.t.))
return

function _BSC001_Par()
return ::New()