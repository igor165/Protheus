// ######################################################################################
// Projeto: BI Library
// Modulo : Foundation Classes
// Fonte  : TBIXMLAttrib.prw
// -----------+-------------------+------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+------------------------------------------------------
// 15.04.2003   BI Development Team
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIXMLAttrib
Classe representa os atributos de uma tag XML.
Características: 
	- Pode acrescentar valores com seus devidos tipos de dados.
	- Pode obter através do nome valores com seus devidos tipos de dados.
	- Pode remover valores pelo nome
--------------------------------------------------------------------------------------*/
class TBIXMLAttrib from TBIObject

	data faFields		// vetor de atributos da tag com nome e valor strings (nome, valor)
		
	method New() constructor
	method NewXMLAttrib()

	method nAttribCount()
	method lSet(cAttrib, xValue)
	method lRemove(cAttrib)
	method cValue(cAttrib)
	method nValue(cAttrib)
	method dValue(cAttrib)
	method lValue(cAttrib)
	method cXMLString()
	
endclass

/*--------------------------------------------------------------------------------------
@constructor New(cXML)
Constroe o objeto em memória.
@param cXML - Texto XML representando os atributos.
--------------------------------------------------------------------------------------*/
method New() class TBIXMLAttrib
	::NewXMLAttrib()
return
method NewXMLAttrib() class TBIXMLAttrib
	::NewObject()
	::faFields := {}
return

/*--------------------------------------------------------------------------------------
@method nAttribCount()
Retorna o numero atual de atributos deste XMLAttrib.
@return - Numero de atributos.
--------------------------------------------------------------------------------------*/                         
method nAttribCount() class TBIXMLAttrib
return len(::faFields)

/*--------------------------------------------------------------------------------------
@method lSet(cAttrib, xValue)
Adiciona um atributo (nome, valor). Se ja existir, atualiza o valor.
@param cAttrib - Nome do atributo.
@param xValue - Valor do atributo.
@return - Indica o sucesso da operação.
--------------------------------------------------------------------------------------*/                         
method lSet(cAttrib, xValue) class TBIXMLAttrib
	local nPos := aScan(::faFields, {|x| x[1] == cAttrib})
	xValue := cBIStr(xValue)
	if(nPos == 0)
		aAdd(::faFields, {cAttrib, xValue})
	else
		::faFields[nPos][2] := xValue
	endif	
return .t.

/*--------------------------------------------------------------------------------------
@method lRemove(cAttrib)
Remove um atributo (nome, valor).
@param cAttrib - Nome do atributo a remover.
@return - Indica se conseguiu remover (se o atributo existia).
--------------------------------------------------------------------------------------*/                         
method lRemove(cAttrib) class TBIXMLAttrib
	local nLength := ::nAttribCount()
	local nPos := aScan(::faFields, {|x| x[1] == cAttrib})
	if(nPos != 0)
		BIADel(::faFields, nPos)
	endif
return (::nAttribCount() < nLength)

/*--------------------------------------------------------------------------------------
@property cValue(cAttrib)
Recupera (como String) o valor de um atributo através do nome.
@param cAttrib - Nome do atributo.
@return - Valor do atributo no formato String.
--------------------------------------------------------------------------------------*/                         
method cValue(cAttrib) class TBIXMLAttrib
	local cRet := nil
	local nPos := aScan(::faFields, {|x| x[1] == cAttrib})
	if(nPos != 0)
		cRet := ::faFields[nPos][2] // Os valores já são armazenados como caracter
	endif
return cRet

/*--------------------------------------------------------------------------------------
@property nValue(cAttrib)
Recupera (como Numerico) o valor de um atributo através do nome.
@param cAttrib - Nome do atributo.
@return - Valor do atributo no formato Numerico.
--------------------------------------------------------------------------------------*/                         
method nValue(cAttrib) class TBIXMLAttrib
	local nRet := nil
	local nPos := aScan(::faFields, {|x| x[1] == cAttrib})
	if(nPos != 0)
		nRet := xBIConvTo("N", ::faFields[nPos][2])
	endif
return nRet

/*--------------------------------------------------------------------------------------
@property dValue(cAttrib)
Recupera (como Date) o valor de um atributo através do nome.
@param cAttrib - Nome do atributo.
@return - Valor do atributo no formato Date.
--------------------------------------------------------------------------------------*/                         
method dValue(cAttrib) class TBIXMLAttrib
	local dRet := nil
	local nPos := aScan(::faFields, {|x| x[1] == cAttrib})
	if(nPos != 0)
		dRet := xBIConvTo("D", ::faFields[nPos][2])
	endif
return dRet

/*--------------------------------------------------------------------------------------
@property lValue(cAttrib)
Recupera (como Logico) valor de um atributo através do nome.
@param cAttrib - Nome do atributo.
@return - Valor do atributo no formato Logico.
--------------------------------------------------------------------------------------*/                         
method lValue(cAttrib) class TBIXMLAttrib
	local lRet := nil
	local nPos := aScan(::faFields, {|x| x[1] == cAttrib})
	if(nPos != 0)
		lRet := xBIConvTo("L", ::faFields[nPos][2])
	endif
return lRet

/*--------------------------------------------------------------------------------------
@method cXMLString()
Gera o texto XML dos atributos pronto para ser colocado dentro da tag.
@return - Texto XML gerado.
--------------------------------------------------------------------------------------*/                         
method cXMLString() class TBIXMLAttrib
	local cXML := ''
	
	aEval(::faFields, {|x| cXML += ' '+x[1]+'="'+cBIXMLEncode(x[2])+'"'})

return cXML

function _TBIXMLAttrib()
return nil
// ************************************************************************************
// Fim da definição da classe TBIXMLAttrib
// ************************************************************************************