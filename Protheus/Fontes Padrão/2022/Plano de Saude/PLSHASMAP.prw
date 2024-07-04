#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#define HASH_BYPRAU  1 

STATIC lHabThasMap 	:= !IsSrvUnix()
STATIC nTB5M_FUNNAM	:= 10

//Objetos THashMap para melhora de performance 
STATIC __oBHMPRE_AUT := nil

/*/{Protheus.doc} PLRetHash
//Carrega/inicializa o objeto HashMap solicitado
@author PLSTEAM
@since 19/10/2016
@version 1.0
@param nHashId, numerico, ID do Hash a ser retornado
@return tHashMap, objeto solicitado conforme ID.
/*/
function PLRetHash(nTp)

do case

	case nTp == HASH_BYPRAU
	
		if valType(__oBHMPRE_AUT) == "U"
			PLHashIni(@__oBHMPRE_AUT)
		endIf
		
		return __oBHMPRE_AUT
		
endCase
		
return() 

/*/{Protheus.doc} PLClearHM
@description Limpa obj's da memoria 
@author PLSTEAM
@since 10/08/2017
@version P12
@return nil
/*/
function PLClearHM(nTp)

do case
	
	case nTp == HASH_BYPRAU .and. valType(__oBHMPRE_AUT) <> "U"
	
		HMClean( __oBHMPRE_AUT )
		
		FreeObj( __oBHMPRE_AUT )
		
		__oBHMPRE_AUT := nil
			
endCase

return 

/*/{Protheus.doc} PLHashIni
Inicializa a variavel de controle de itens que ja foram auditados
@type function
@author PLSTEAM
@since 18/10/2016
/*/
function PLHashIni(xObj)

if lHabThasMap
	xObj := THashMap():New()
else
	xObj := {}
endIf

return

/*/{Protheus.doc} PLSetHash
//Alimenta o objeto HashMap (ou array caso o servidor for LINUX )
@author PLSTEAM
@since 20/10/2016
@version 1.0
@param xKey, caracter, Chave para guardar o conteudo a ser acessado posteriormente
@param xVarRet, caracter, Variavel onde sera armazenado o retorno
@param xObj, caracter, Objeto/Array pai
@return boolean, localizou o objeto no Hash solicitado?
/*/
function PLSetHash(xKey,xVarPut,xObj)
local lRet	:= .f.

if lHabThasMap
	lRet := xObj:set(xKey,xVarPut)
else
	lRet := .t.
	aadd(xObj,{xKey,xVarPut})
endIf

return lRet

/*/{Protheus.doc} PLGetHash
Retorna objeto Contido dentro de um HashMap (ou array caso o servidor for LINUX) e o transfere parauma variavel de referencia
@author PLSTEAM
@since 20/10/2016
@version 1.0
@param xKey, caracter, Chave para guardar o conteudo a ser acessado posteriormente
@param xVarRet, caracter, Variavel onde sera armazenado o retorno
@param xObj, caracter, Objeto/Array pai
@return boolean, localizou o objeto no Hash solicitado?
/*/
function PLGetHash(xKey,xVarRet,xObj)
local nPos	:= 0
local lRet	:= .f.
local cType	:= ''

if lHabThasMap .and. valType(xObj) == "O"

	lRet := xObj:get(xKey,xVarRet)

elseIf len(xObj) > 0 .and. ( lRet := ( nPos := aScan(xObj,{|x| x[1] == xKey} ) ) > 0 )
	
	if valType(xObj[nPos,2]) == "A"
		xVarRet := aClone(xObj[nPos,2])
	else
		xVarRet := xObj[nPos,2]
	endIf
	
endIf

cType := valType(xVarRet)

if cType == 'U' .or. ( cType == 'A' .and. len(xVarRet) == 0 )
	lRet := .f.
endIf

return lRet


/*/{Protheus.doc} PLSetGD
Seta matriz global data
@author PLSTEAM
@since 20/04/2018
@version 1.0
/*/
function PLSetGD(cUID, cHashCHV, aRet)
return	

/*/{Protheus.doc} PLGetGD
Retorna matriz global data
@author PLSTEAM
@since 20/04/2018
@version 1.0
/*/
function PLGetGD(cUID, cHashCHV, aRet)
return .f.

/*/{Protheus.doc} PLClearGD
Limpa Global Data
@author PLSTEAM
@since 20/04/2018
@version 1.0
/*/
function PLClearGD()
return .f.