// ######################################################################################
// Projeto: BI Library
// Modulo : Foundation Classes
// Fonte  : TBIIndex.prw
// -----------+-------------------+------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+------------------------------------------------------
// 15.04.2003   BI Development Team
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIIndex
Classe para os objetos Index da classe TBIDataSet.
Características: 
	- Cria e dropa indices.
	- Permite tratar indice como Unique.
	- Permite definir ordem do indice (dbsetorder).
	- Trata a concatenação de campos como Sql e traduz tudo para o Top.
--------------------------------------------------------------------------------------*/
class TBIIndex from TBIObject

	data fcIndexName	// Nome do indice
	data faFields		// Campos que compõem o indice (em ordem de concatenação)
	data flUnique		// Define se o indice é único (causa exceção ao repetir chaves já existentes)
		
	method New(cIndexName, aFields, lUnique) constructor
	method Free()
	method NewIndex(cIndexName, aFields, lUnique)
	method FreeIndex()

	// props
	method cIndexName(cValue)
	method aFields(aValues)
	method lUnique(lEnabled)                       
	method nOrder()
	
	// methods
	method lCreate()
	method lOpen()
	method lDrop()

	// internal
	method bKeyExpression()	
	method cKeyExpression()	

endclass

/*--------------------------------------------------------------------------------------
@constructor New(cIndexName, aFields, lUnique)
Constroe o objeto em memória.
@param - Nome do indice.
@param - Campos que compoem o indice.
@param - Se o indice é chave única.
--------------------------------------------------------------------------------------*/
method New(cIndexName, aFields, lUnique) class TBIIndex
	::NewIndex(cIndexName, aFields, lUnique)
return

method NewIndex(cIndexName, aFields, lUnique) class TBIIndex
	::NewObject()

	default lUnique := .f.

	::fcIndexName 	:= cIndexName
	::faFields 		:= aFields
	::flUnique 		:= lUnique
return

/*--------------------------------------------------------------------------------------
@destructor Free()
Destroe o objeto (limpa recursos).
--------------------------------------------------------------------------------------*/
method Free() class TBIIndex
	::FreeIndex()
return

method FreeIndex() class TBIIndex
	::FreeObject()
return

/*--------------------------------------------------------------------------------------
@property cIndexName(cValue)
Define/Recupera o nome do indice.
@param cValue - Nome do indice.
@return - Nome do indice.
--------------------------------------------------------------------------------------*/                         
method cIndexName(cValue) class TBIIndex
	property ::fcIndexName := cValue
return ::fcIndexName

/*--------------------------------------------------------------------------------------
@property aFields(aValues)
Define/Recupera os campos que compôem o índice.
@param aValues - Array com os campos em formato String.
@return - Array com os campos em formato String.
--------------------------------------------------------------------------------------*/                         
method aFields(aValues) class TBIIndex
	property ::faFields := aValues
return ::faFields

/*--------------------------------------------------------------------------------------
@property lUnique(lEnabled)
Define/Recupera se o indice é Unique (causa exceção ao repetir chaves já existentes).
@param lEnabled - Liga ou desliga Unique.
@return - Se Unique está ligado ou desligado.
--------------------------------------------------------------------------------------*/                         
method lUnique(lEnabled) class TBIIndex
	property ::flUnique := lEnabled
return ::flUnique

/*--------------------------------------------------------------------------------------
@property nOrder()
Recupera a ordem do indice na tabela/query.
@return - Ordem do indice.
--------------------------------------------------------------------------------------*/                         
method nOrder() class TBIIndex
	local nOrder := 0
	local aIndexes
	if(valtype(::oOwner())=="O")
		nOrder := aScan(::oOwner:aIndexes(), {|x| x:cIndexName() == ::cIndexName()})
	endif	
return nOrder

/*--------------------------------------------------------------------------------------
@method lCreate()
Cria este indice fisicamente na base.
return - Indica o sucesso da operação.
--------------------------------------------------------------------------------------*/                         
method lCreate() class TBIIndex
	Local cIndice 	:= ::cIndexName()
	Local cRDD 		:= "TOPCONN"
    
	//-------------------------------------------------------------------
	// Define o nome do índice que será criado. 
	//-------------------------------------------------------------------	
	If ( ::oOwner():lLocal() ) 
		cIndice := RetArq( RddName(), ::cIndexName(), .F. )
	Else
		cIndice := ::cIndexName()
	EndIf 
    
	//-------------------------------------------------------------------
	// Verifica se a tabela na qual o índice será criado está aberta. 
	//-------------------------------------------------------------------
	If ( Select( ::oOwner():cAlias() ) == 0 ) 
		If( ::oOwner():lLocal() )	
			cRDD := Iif( ( "CTREE" $ RealRDD() ), "CTREECDX", "DBFCDX" ) 
	    EndIf
	    
	    USE ( ::oOwner():cTablename() ) ALIAS ( ::oOwner():cAlias() ) SHARED NEW VIA ( cRDD )		
	EndIf
	
	//-------------------------------------------------------------------
	// Cria o índice. 
	//-------------------------------------------------------------------		
	DBCreateIndex( cIndice, ::cKeyExpression(), &("{ || " + ::cKeyExpression() + "}") )
	DBcommit()
return .t.

/*--------------------------------------------------------------------------------------
@method lOpen()
Abre este indice na tabela atual.
return - Indica o sucesso da operação.
--------------------------------------------------------------------------------------*/                         
method lOpen() class TBIIndex
	Local cDriver		:= RddName()
	Local cFile		:= ::oOwner():cTablename()
	Local cIndice 	:= ::cIndexName()
	Local cRDD 		:= "TOPCONN"
	Local lOpened 	:= .F. 
    
   //-------------------------------------------------------------------
	// Verifica se a tabela na qual o índice será criado está aberta. 
	//-------------------------------------------------------------------	
	If ( Select( ::oOwner():cAlias() ) == 0 ) 
		If( ::oOwner():lLocal() )	
			cRDD := Iif( ( "CTREE" $ RealRDD() ), "CTREECDX", "DBFCDX" ) 
	    EndIf
	    
	    USE ( ::oOwner():cTablename() ) ALIAS ( ::oOwner():cAlias() ) SHARED NEW VIA ( cRDD )		
	EndIf

	//-------------------------------------------------------------------
	// Verifica se o índice foi criado anteriormente. 
	//-------------------------------------------------------------------	
	If ( ::oOwner():lLocal() )
		cIndice 	:= RetArq( cDriver, cIndice, .F. )
		lOpened	:= MsFile( cFile, cIndice, cDriver )
	else
		lOpened	:= TCCanOpen( cFile, cIndice )
	endif
	
	If !( lOpened )
		//-------------------------------------------------------------------
		// Cria o índice. 
		//-------------------------------------------------------------------	
		::lCreate() 
	ElseIf !( "CDX" $ cDriver )
		//-------------------------------------------------------------------
		// Seta o índice. 
		//-------------------------------------------------------------------	
		DBSetIndex( cIndice )
	EndIf
return .T.

/*--------------------------------------------------------------------------------------
@method lDrop()
Deleta este indice fisicamente na base.
return - Indica o sucesso da operação.
--------------------------------------------------------------------------------------*/                         
method lDrop() class TBIIndex
	local lOpenAfterDrop := ::oOwner():lIsOpen()
	
	if(lOpenAfterDrop)
		::oOwner():lClose()
	endif

	if(::oOwner():lLocal())
		fErase(RetArq(RddName(), ::cIndexName(), .F.))
	else
		TCINTERNAL(60, ::oOwner():cTablename() + "|" + ::cIndexName())
	endif

	if(lOpenAfterDrop)
		::oOwner():lOpen()
	endif
return .t.

/*--------------------------------------------------------------------------------------
@method bKeyExpression()
Método de uso interno da classe:
Recupera o valor concatenado da chave para o Top, em forma de bloco de código.
@return - Bloco representando o valor da chave.
--------------------------------------------------------------------------------------*/                         
method bKeyExpression() class TBIIndex
	local aFields := ::aFields(), oField, nInd
	local nSeq := 0, cParName, aBlocks := {}
	local lOneField := len(aFields) == 1
	local cExpChave := ""
	
	for nInd := 1 to len(aFields)
		oField := ::oOwner():aFields(aFields[nInd])
		if valType(oField) == "O"
			nSeq++
			cParName := "p" + cBIint2hex(nSeq,2)
			if lOneField
				aAdd(aBlocks, cParName)
			elseif oField:cType() == "N"
				aAdd(aBlocks, "cStrNil(" + cBIConcatWSep(",", cParName, oField:nLength(), oField:nDecimals()) + ")" )
			elseif oField:cType() == "D"
				aAdd(aBlocks, cBIConcat("cDtosNil(", cParName, ")") )
			elseif oField:cType() == "C"
				if(oField:lSensitive())
					aAdd(aBlocks, "padr(" + cBIConcatWSep(",", cParName, oField:nLength()) + ")" )
				else
					aAdd(aBlocks, "cBIUpper(padr(" + cBIConcatWSep(",", substr(cParName,1,8), oField:nLength()) + "))" )
				endif
			endif
		endif
	next

	cExpChave := "{|"
	aEval(aBlocks, { |x,i| cExpChave += "p" + cBIint2hex(i,2) + "," })
	cExpChave := left(cExpChave, len(cExpChave)-1) + "|"
	cExpChave += cBIConcatWSep("+", aBlocks) + "}"
return &(cExpChave)

/*--------------------------------------------------------------------------------------
@method cKeyExpression()
Método de uso interno da classe:
Recupera o valor concatenado da chave para o Top, em forma de String.
@return - String representando o valor da chave.
--------------------------------------------------------------------------------------*/                         
method cKeyExpression() class TBIIndex
	local aFieldList := ::aFields()
	local lOneField := len(aFieldList) == 1
	local nInd, oField, aFields := {}
	
	for nInd := 1 to len(aFieldList)
		oField := ::oOwner():aFields(aFieldList[nInd])
		if valType(oField) == "O"
			if lOneField
				aAdd(aFields, oField:cFieldName())
			elseif oField:cType() == "N"
				aAdd(aFields, "str(" + cBIConcatWSep(",", oField:cFieldName(), oField:nLength(), oField:nDecimals()) + ")" )
			elseif oField:cType() == "D"
				aAdd(aFields, cBIConcat("dtos(", oField:cFieldName(), ")") )
			elseif oField:cType() == "C"
				if(oField:lSensitive())
					aAdd(aFields, oField:cFieldName())
				else
					aAdd(aFields, "NS"+substr(oField:cFieldName(),1,8))
				endif
			endif
		endif
	next
return cBIConcatWSep("+", aFields)

function _TBIIndex()
return nil

// ************************************************************************************
// Fim da definição da classe TBIIndex
// ************************************************************************************