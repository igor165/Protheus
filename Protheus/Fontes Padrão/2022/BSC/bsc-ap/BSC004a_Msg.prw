// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC004a_Msg.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 17.11.04 | 1645 Leandro Marcelino Santos
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC004a_Msg.ch"

/*--------------------------------------------------------------------------------------
@entity Mensagens
Mensagens no BSC. Contém mensagens recebidas dos usuários do BSC.
@table BSC004
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "DESTINATARIO"
#define TAG_GROUP  "DESTINATARIOS"
#define TEXT_ENTITY STR0001/*//"Mensagem"*/
#define TEXT_GROUP  STR0002/*//"Mensagens"*/

class TBSC004A from TBITable
	method New() constructor
	method NewBSC004A()

	// diversos registros
	method oToXMLList(nParentID)

endclass
	
method New() class TBSC004A
	::NewBSC004A()
return
method NewBSC004A() class TBSC004A

	// Table
	::NewTable("BSC004A")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("PESSID",		"N"))
	::addField(TBIField():New("SITUACAO",	"N")) // 1.Lida 2.Não Lida
	::addField(TBIField():New("PASTA",		"N")) // 2.Entrada 3.Excluido 4.Excluido Definitivamente
	::addField(TBIField():New("PARACC",		"N")) // 1.Para 2.CC
	::addField(TBIField():New("REMETENTE",	"N")) // 1.Remetente 2.Destinatário
	
	// Indexes
	::addIndex(TBIIndex():New("BSC004AI01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC004AI02",	{"PARENTID", "ID"},	.t.))
	::addIndex(TBIIndex():New("BSC004AI03",	{"PARENTID", "REMETENTE"},	.f.))

return

function _BSC004a_Msg()
return