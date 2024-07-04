// ######################################################################################
// Projeto: BI Library
// Modulo : Foundation Classes
// Fonte  : TBIXMLNode.prw
// -----------+-------------------+------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+------------------------------------------------------
// 15.04.2003   BI Development Team
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"

static __BIXMLBuffer  // Implementada para ganho de performance em concatenações de strings

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIXMLNode
Classe para montar nodes em XML. Representa um node e todos os seus filhos.
--------------------------------------------------------------------------------------*/
class TBIXMLNode from TBIObject

	data fcTagName		// Nome deste tag
	data fcValue		// Valor desta tag
	data foAttrib		// Atributos desta tag
	
	// Campos herdados de TBIObject que possuem papel fundamental
	// data TBIObject:faChildren 	// Filhos deste NODE: Array de instancias de TBIXMLNode's
	// data TBIObject:foOwner		// Pai deste NODE, NIL se esse Node for Root
	
	method New(cTagName, xValue, oAttrib) constructor
	method NewXMLNode(cTagName, xValue, oAttrib)
	
	// Parent / Child
	method oAddChild(oNode)
	method oRemoveChild(oNode)
	method oChildByPos(nPos)
	method oChildByName(cTagName, nTagPos)
	method nChildCount(cTagName)

	// Read / Write
	method cTagName(cName)
	method SetValue(xValue)
	method cGetValue()
	method nGetValue()
	method dGetValue()
	method lGetValue()
	method oAttrib(oValue)

	// Result
	method cXMLString(lHeader, cEncoding, lMakeEmpty, oFile)
	method XMLFile(cFilename, lHeader, cEncoding, lMakeEmpty)
	method oGetXMLObject() 	
	//Clear
	method clearAllNodes(oNode)
	
endclass

/*--------------------------------------------------------------------------------------
@constructor New(cTagName, xValue, oAttrib)
Constroe o objeto em memória.
@param cTagName - Nome desta tag.
@param xValue - Valor desta tag.
@param oAttrib - Atributos desta tag (intancia de TBIXMLAttrib).
--------------------------------------------------------------------------------------*/
method New(cTagName, xValue, oAttrib) class TBIXMLNode
	::NewXMLNode(cTagName, xValue, oAttrib)
return
method NewXMLNode(cTagName, xValue, oAttrib) class TBIXMLNode
	::NewObject()  
	::fcTagName := cTagName
	::fcValue := cBIStr(xValue) // Converte qualquer valor em CARACTER ao guardar
	::foAttrib := oAttrib
return

/*--------------------------------------------------------------------------------------
@method oAddChild(oNode)
Adiciona um child node a este node.
@param oNode - Instancia da classe TBIXMLNode representando uma nova tag(node).
@return - Um ponteiro para o proprio node que foi adicionado.
--------------------------------------------------------------------------------------*/                         
method oAddChild(oNode) class TBIXMLNode
	oNode:oOwner(self)
return oNode

/*--------------------------------------------------------------------------------------
@method oRemoveChild(oNode)
Remove um child node deste node.
@param oNode - Ponteiro para a instancia da classe TBIXMLNode a ser excluida.
@return - Ponteiro para o proprio que foi excluido.
--------------------------------------------------------------------------------------*/                         
method oRemoveChild(oNode) class TBIXMLNode
	oNode:RemoveOwner()
return oNode

/*--------------------------------------------------------------------------------------
@method oChildByPos(nPos)
Pega o ponteiro para um dos filhos deste node.
@param nPos - Intancia da classe TBIXMLNode representando uma nova tag(node).
@return - Um ponteiro para o node filho. Nil se nao houver filho nesta posicao.
--------------------------------------------------------------------------------------*/                         
method oChildByPos(nPos) class TBIXMLNode
	local oNode
	if(nPos <= len(::faChildren))
		oNode := ::faChildren[nPos]
	endif	
return oNode

/*--------------------------------------------------------------------------------------
@method oChildByName(cTag, nTagPos)
Pega o ponteiro para um dos filhos deste node.
@param cTag - Nome da tag a ser encontrada.
@param cTagPos - Posicao da tag num grupo de tags com mesmo nome. 
@return - Um ponteiro para o node filho. Nil se nao houver filho.
--------------------------------------------------------------------------------------*/                         
method oChildByName(cTag, nTagPos) class TBIXMLNode
	local oNode, nPos := 0, nFound := 0

	default nTagPos := 1
	
	while( (nPos := aScan(::faChildren, {|x| x:cTagName()==cTag}, ++nPos)) != 0)
		if(++nFound == nTagPos)
			oNode := ::faChildren[nPos]
			exit
		endif
	end
return oNode

/*--------------------------------------------------------------------------------------
@method nChildCount(cTag)
Conta os filhos deste node.
@param cTag - Se for passado, contara somente os filhos com essa tag.
@return - Quantidade de filhos.
--------------------------------------------------------------------------------------*/                         
method nChildCount(cTag) class TBIXMLNode
	local nPos := 0, nFound := 0

	if(valtype(cTag) == "U")
		nFound := len(::faChildren)
	else
		while( (nPos := aScan(::faChildren, {|x| x:cTagName()==cTag}, ++nPos)) != 0)
			nFound++
		end
	endif
return nFound

/*--------------------------------------------------------------------------------------
@property cTagName(cName)
Define/recupera o nome(tag) deste node.
@param cName - Nome da tag ser atribuido a este node.
@return - Nome atual da tag deste node.
--------------------------------------------------------------------------------------*/                         
method cTagName(cName) class TBIXMLNode
	property ::fcTagName := cName
return ::fcTagName	

/*--------------------------------------------------------------------------------------
@property oAttrib(oValue)
Define/recupera os attributos deste node(tag).
@param oValue - Instancia de TBIXMLAttrib representando os atributos desta tag.
@return - Instancia atual representando os atributos desta tag.
--------------------------------------------------------------------------------------*/                         
method oAttrib(oValue) class TBIXMLNode
	property ::foAttrib := oValue
return ::foAttrib

/*--------------------------------------------------------------------------------------
@property SetValue(xValue)
Define/recupera o nome(tag) deste node.
@param xValue - Nome da tag ser atribuido a este node.
--------------------------------------------------------------------------------------*/                         
method SetValue(xValue) class TBIXMLNode
	::fcValue := cBIStr(xValue)  // Converte valor para CARACTER ao guardar
return

/*--------------------------------------------------------------------------------------
@method cGetValue()
Recupera o valor deste node no formato string.
@return - Valor string deste node.
--------------------------------------------------------------------------------------*/                         
method cGetValue() class TBIXMLNode
return ::fcValue

/*--------------------------------------------------------------------------------------
@method nGetValue()
Recupera o valor deste node no formato numerico.
@return - Valor numerico deste node.
--------------------------------------------------------------------------------------*/                         
method nGetValue() class TBIXMLNode
return xBIConvTo("N", ::fcValue)

/*--------------------------------------------------------------------------------------
@method dGetValue()
Recupera o valor deste node no formato data.
@return - Valor deste node.
--------------------------------------------------------------------------------------*/                         
method dGetValue() class TBIXMLNode
return xBIConvTo("D", ::fcValue)

/*--------------------------------------------------------------------------------------
@method lGetValue()
Recupera o valor deste node no formato logico.
@return - Valor logico deste node.
--------------------------------------------------------------------------------------*/                         
method lGetValue() class TBIXMLNode
return xBIConvTo("L", ::fcValue)

/*--------------------------------------------------------------------------------------
@method cXMLString(lHeader, cEncoding, lMakeEmpty, oFile)
Gera o texto XML utilizando como root este objeto.
@param lHeader - Indica se gera o cabecalho do XML. Default e .f.
@param cEncoding - Indica qual a codificação par o PARSE xml. Default e nenhum encoding definido.
@param lMakeEmpty - Indica se gera ou não os nós que estiverem vazios. Default e .t.
@return - Texto XML gerado.
--------------------------------------------------------------------------------------*/                         
method cXMLString(lHeader, cEncoding, lMakeEmpty, oFile) class TBIXMLNode
	local nInd, lValue, lChild
	local lRootBuffer, cXML
	// local nTime1, nTime2

	default lHeader := .f.
	default lMakeEmpty := .t.
	
	// Verifica se é root e inicia buffer
	lRootBuffer := .f.
	if(__BIXMLBuffer == NIL)
		// MEDE O TEMPO DO PARSER
		//nTime1 := round(seconds()*1000, 0)
		//conout("* Antes de parsear: " + cBIStr(nTime1))
		__BIXMLBuffer := ""
		lRootBuffer := .t.
	elseif len(__BIXMLBuffer) >= 500000 .and. ! (Valtype(oFile) == "U")//Tamanho máximo da string 1048576
		oFile:nWrite(__BIXMLBuffer)
		__BIXMLBuffer := ""
	endif

	// Header XML
	if(lHeader)
		__BIXMLBuffer += '<?xml version="1.0"'
		if !empty(cEncoding)
			__BIXMLBuffer += ' encoding="'
			__BIXMLBuffer += cEncoding
			__BIXMLBuffer += '" '
		endif
		__BIXMLBuffer += "?>"
	endif

	// Valida e divide informações
	lValue := !empty(::cGetValue())
	lChild := (::nChildCount()!=0)
	
	if(lMakeEmpty .or. lValue .or. lChild)

		// Inicia tag abertura
		__BIXMLBuffer += CRLF+'<'
		__BIXMLBuffer += ::cTagName()

		// Se possui atributos
		if (::foAttrib != NIL)
			__BIXMLBuffer += ::foAttrib:cXMLString(,,,oFile)
		endif

		// Finaliza tag abertura
		__BIXMLBuffer += '>'

		// Acrescenta valor
		__BIXMLBuffer += cBIXMLEncode(::cGetValue())

		// Se tem nodes filhos
		if(lChild)
			aEval(::faChildren , {|x| x:cXMLString(, , lMakeEmpty, oFile)})
			__BIXMLBuffer += CRLF
		endif

		// Tag de fecha
		__BIXMLBuffer += '</'
		__BIXMLBuffer += ::cTagName()
		__BIXMLBuffer += '>'
	endif

	// Verifica se é root e deve então zerar o buffer
	if(lRootBuffer)
		cXML := __BIXMLBuffer
		__BIXMLBuffer := NIL

		// MEDE O TEMPO DO PARSER
		// nTime2 := round(seconds()*1000, 0)
		// conout("* Depois de parsear: " + cBIStr(nTime2) + " - Total: "+cBIStr(nTime2-nTime1))
	endif

return cXML

/*--------------------------------------------------------------------------------------
@method XMLFile(cFilename, lHeader, cEncoding, lMakeEmpty)
Gera o texto XML utilizando como root este objeto e grava o resultado em <cFilename>.
@param cFileName - Nome do arquivo a ser gerado.
@param lHeader - Indica se gera o cabecalho do XML. Default e .f.
@param cEncoding - Indica se gera o cabecalho do XML. Default e nenhum encoding definido.
@param lMakeEmpty - Indica se gera ou não os nós que estiverem vazios. Default e .t.
--------------------------------------------------------------------------------------*/                         
method XMLFile(cFilename, lHeader, cEncoding, lMakeEmpty,oFile) class TBIXMLNode
	default oFile	:= nil
	
	if oFile == NIL
		oFile := TBIFileIO():New(cFilename)
		oFile:lCreate()
		oFile:nWriteLn(::cXMLString(lHeader, cEncoding, lMakeEmpty, oFile))
		oFile:lClose()                     
	else
		oFile:nWrite(::cXMLString(lHeader, cEncoding, lMakeEmpty, oFile)	)
	endif		

return


/*--------------------------------------------------------------------------------------
@method oGetXMLObject()
Gera um objeto Protheus de XML.
--------------------------------------------------------------------------------------*/                         
method oGetXMLObject() class TBIXMLNode
	Local oNewXML 	:= nil
	Local cError	:= ""
	Local cWarning	:= ""
	
	oNewXML := XmlParser(::cXMLString(.t., "ISO-8859-1"), '_', @cError, @cWarning)

return oNewXML

/*--------------------------------------------------------------------------------------
@method clearAllNodes()
Limpa todos os valores do XML, desalocando a memoria.
--------------------------------------------------------------------------------------*/                         
method clearAllNodes(oNode) class TBIXMLNode
	local nNode := 0
    default oNode	:=	nil

    if oNode == nil
		oNode := self
    endif
			                                  
	if valType(oNode)== "O"  .and. valType(oNode:faChildren) == "A" 
		for nNode := 1 to len(oNode:faChildren)
			if valType(oNode:faChildren[nNode]) == "O"
				::clearAllNodes(oNode:faChildren[nNode])
			endif
			oNode:faChildren[nNode] := nil
	  	next
	  	oNode:faChildren := nil
	endif  
	oNode := nil
	
return .t.

// ************************************************************************************
// Fim da definição da classe TBIXMLNode
// ************************************************************************************
function TBIXMLNODE()
return nil