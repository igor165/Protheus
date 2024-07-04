// ######################################################################################
// Projeto: BI Library
// Modulo : Foundation Classes
// Fonte  : TBIObject.prw
// -----------+-------------------+------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+------------------------------------------------------
// 15.04.2003   BI Development Team
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject
Classe básica dos sistemas de BI, todas as classes devem ser subclasses desta,
salvo se forem objetos de outro contexto(Tecnologia, Sistemas, Web...)
Características: 
	- ID do objeto e Nome do grupo.
	- Atribuição de objeto pai.
	- Notificação para objetos filhos.
	- Persistência através de Array ou String.
--------------------------------------------------------------------------------------*/
class TBIObject
	
	data fcID		// ID do objeto (único)
	data fcName		// Nome do grupo do objeto
	data foOwner    // Objeto pai
	data faChildren // Objetos filhos
	
	method New() constructor
	method Persist(xData) constructor
	method Free()
	method NewObject()
	method FreeObject()
    
	method cID(cText)
	method cName(cText)

	method oOwner(oObject)
	method RemoveOwner()
	method AddChild(oObject)
	method RemoveChild(oObject)
	method lNotify(nCode, aParams)

	method aToArray(aIgnoreList)
	method FromArray(aArray, aIgnoreList)

	// Falta implementar os seguintes
	method lSaveInFile(cName, aIgnoreList)
	method lLoadFromFile(cName, aIgnoreList)

endclass

/*--------------------------------------------------------------------------------------
@constructor New()
Constroe o objeto em memória.
--------------------------------------------------------------------------------------*/
method New() class TBIObject
	::NewObject()
return

method NewObject() class TBIObject

	::faChildren := {}

return

/*--------------------------------------------------------------------------------------
@constructor Persist()
Constroe o objeto em memória a partir dados gerados por aToArray.
--------------------------------------------------------------------------------------*/
method Persist(aData) class TBIObject
	::NewObject()
	if valtype(aData)=="A"
		::FromArray(xData)
	endif	
return

/*--------------------------------------------------------------------------------------
@destructor Free()
Destroe o objeto (limpa recursos).
--------------------------------------------------------------------------------------*/
method Free() class TBIObject
	::FreeObject()
return

method FreeObject() class TBIObject
return

/*-------------------------------------------------------------------------------------
@property cID(cText)
Define/Recupera o ID do objeto.
@param cText - ID do objeto.
@return - ID do objeto.
--------------------------------------------------------------------------------------*/
method cID(cText) class TBIObject
	property ::fcID := cText
return ::fcID

/*-------------------------------------------------------------------------------------
@property cName(cText)
Define/Recupera o nome do grupo do objeto.
@param cText - Nome do grupo do objeto.
@return - Nome do grupo do objeto.
--------------------------------------------------------------------------------------*/
method cName(cText) class TBIObject
	property ::fcName := cText
return ::fcName

/*-------------------------------------------------------------------------------------
@property oOwner(oObject)
Define um objeto pai e adiciona self a sua lista de filhos.
@param oObject - Objeto da classe TBIObject que sera pai deste objeto.
@return - Objeto da classe TBIObject pai deste objeto.
--------------------------------------------------------------------------------------*/
method oOwner(oObject) class TBIObject
	if valtype(oObject) == "O"
		if valtype(::foOwner) == "O" // ja tem pai
			::RemoveOwner()
		endif	
		oObject:AddChild(self)
	endif
	property ::foOwner := oObject
return ::foOwner

/*-------------------------------------------------------------------------------------
@method RemoveOwner()
Remove o objeto pai e remove self de sua lista de filhos.
--------------------------------------------------------------------------------------*/
method RemoveOwner() class TBIObject
	if valtype(::foOwner) == "O"
		::foOwner:RemoveChild(self)
	endif
	::foOwner := nil
return

/*-------------------------------------------------------------------------------------
@method AddChild(oObject)
Adiciona um objeto do tipo TBIObject a lista de filhos deste objeto.
@param oObject - Objeto TBIObject a ser adicionado a lista de filhos deste objeto.
--------------------------------------------------------------------------------------*/
method AddChild(oObject) class TBIObject
	aAdd(::faChildren, oObject)
return

/*-------------------------------------------------------------------------------------
@method RemoveChild(oObject)
Remove um objeto da lista de filhos deste objeto.
@param oObject - Objeto TBIObject a ser removido da lista de filhos deste objeto
--------------------------------------------------------------------------------------*/
method RemoveChild(oObject) class TBIObject
	local nInd

	if valtype(oObject) == "O"
		for nInd := 1 to len(::faChildren)
			if(::faChildren[nInd] == oObject)
				BIADel(::faChildren, nInd)
				exit
			endif
		next	
	endif
return

/*-------------------------------------------------------------------------------------
@abstract lNotify(nCode, aParams)
Deve ser usado para notificar o objeto de alguma ocorrencia.
@param nCode - Mensagem codigo para notificacao (cada implementacao tem as suas)
@param aParams - Parametros da notificacao (cada implementacao tem os seus)
@return - .t.: Notificação ok. / .f.: Notificação com exceção.
--------------------------------------------------------------------------------------*/
method lNotify(nCode, aParams) class TBIObject
	// Abstrato
return .t.

/*-------------------------------------------------------------------------------------
@method aToArray(aIgnoreList)
Converte este objeto num array que pode ser convertido novamente em objeto pelo 
método FromArray desta classe. (Uso geral: tornar o objeto persistente)
@param aIgnoreList - Lista de nomes dos campos a ignorar.
@return - Array com a estrutura de nomes e dados do objeto.
--------------------------------------------------------------------------------------*/
method aToArray(aIgnoreList) class TBIObject
	local aData := ClassDataArr(self)
	local aArray := {}
	local cName, nInd
	default aIgnoreList := {}
	
	for nInd := 1 to len(aData)
		cName := aData[nInd]
		if aScan(aIgnoreList, {|x| upper(x)==upper(cName)}) == -1
			aAdd(aArray, { cName, cBIStr(&cName, .t.) })
		endif
	next	
return aArray

/*-------------------------------------------------------------------------------------
@method FromArray(aArray, aIgnoreList)
Converte um array gerado pelo método aToArray novamente em objeto.
(Uso geral: tornar o objeto persistente)
@param aIgnoreList - Lista de nomes dos campos a ignorar.
@param aArray - Array com a estrutura de nomes e dados do objeto.
--------------------------------------------------------------------------------------*/
method FromArray(aArray, aIgnoreList) class TBIObject
	local cName, nInd
	default aIgnoreList := {}
	for nInd := 1 to len(aArray)
		cName := aArray[nInd,1]
		if aScan(aIgnoreList, { |x| upper(x)==cName }) == -1
			&(cName+" := "+aArray[nInd,2])
		endif	
	next
return

/*-------------------------------------------------------------------------------------
@method lSaveInFile(cName, aIgnoreList)
Salva o objeto em um arquivo em disco.
(Uso geral: tornar o objeto persistente)
@param aIgnoreList - Lista de nomes dos campos a ignorar.
@param cName - Nome do arquivo.
@return - .t. Salvamento ok. / .f. - Problemas.
--------------------------------------------------------------------------------------*/
method lSaveInFile(cName, aIgnoreList) class TBIObject
return .t.

/*-------------------------------------------------------------------------------------
@method lLoadFromFile(cName, aIgnoreList)
Carrega um objeto a partir de um arquivo em disco.
(Uso geral: tornar o objeto persistente)
@param cName - Nome do arquivo.
@param aIgnoreList - Lista de nomes dos campos a ignorar.
@return - .t. Carregamento ok. / .f. - Problemas.
--------------------------------------------------------------------------------------*/
method lLoadFromFile(cName, aIgnoreList) class TBIObject
return .t.

function _TBIObject()
return nil