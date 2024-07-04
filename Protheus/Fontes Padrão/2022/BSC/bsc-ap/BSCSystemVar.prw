// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSCSystemVar.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 03.08.04 | 1645 Leandro Marcelino Santos
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBSCSystemVar
@entity SystemVar
Variáveis de Sistema
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "SYSTEMVAR"
#define TAG_GROUP  "SYSTEMVARS"

class TBSCSystemVar from TBIObject
	method New() constructor
	method NewBSCSystemVar() 

//	method oToXMLNode()
//	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
//	method nDelFromXML(nID)

	method xSessionValue(cVar, xValue)
	
endclass
	
method New() class TBSCSystemVar
	::NewBSCSystemVar()
return
method NewBSCSystemVar() class TBSCSystemVar

return

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSCSystemVar
	local cNome, cTipo, xValue, nStatus := BSC_ST_OK
	private oXMLInput := oXML
	
	// Extrai valores do XML
	cNome  := xBIConvTo("C", &("oXMLInput:"+cPath+":_NOME:TEXT"))
	cTipo  := xBIConvTo("C", &("oXMLInput:"+cPath+":_TIPO:TEXT"))
	xValue := xBIConvTo(cTipo, &("oXMLInput:"+cPath+":_VALOR:TEXT"))
                      
	::xSessionValue(cNome, xValue)

return nStatus

/*-------------------------------------------------------------------------------------
@property xSessionValue(cVar, xValue)
Grava ou Recupera uma Variavel de uma Sessão.
@param cVar - Nome da Variavel.
@param xValue - Valor da Variavel
@return - Valor da Variavel gravada na Sessão do Usuario.
--------------------------------------------------------------------------------------*/
method xSessionValue(cVar, xValue) class TBSCSystemVar
	if(valtype(xValue) != "U")
		&("HttpSession->" + alltrim(cVar)) := xValue
	endif
return &("HttpSession->" + alltrim(cVar))
        

function _BSCSystemVar()
return 