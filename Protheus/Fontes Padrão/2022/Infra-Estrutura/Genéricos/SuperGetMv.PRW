#include "protheus.ch"
static __oHashCache := initGetMV() 


//-------------------------------------------------------------------
/*/{Protheus.doc} _GetMvCached
Refactory da SuperGetMV

@author  Rodrigo Antonio - Eng. Protheus
@param cParametro Parametro no SX6
@param lHelp Mostra o Help
@param cDefault Valor Default, caso não tenha o Parametor no SX6
@param cFil Filial a se olhar, Default cFilAnt
@return xValue Valor do parametro
/*/
//-------------------------------------------------------------------
function _GetMvCached( cParametro , lHelp , cDefault , cFil )
    local cSvFilAnt		:= cFilAnt
    local xResultado
    local cKey
    DEFAULT cFil := cFilAnt
    cKey := cFil + cParametro    
    if !__oHashCache:Get(cKey,@xResultado)
        cFilAnt	:= cFil	    
        xResultado := GetMv( cParametro , lHelp , cDefault )
        __oHashCache:set(cKey,xResultado)
        cFilAnt := cSvFilAnt
    endif
return xResultado

//-------------------------------------------------------------------
/*/{Protheus.doc} _sgetmvreset
Inicializa o cache
/*/
//-------------------------------------------------------------------

static function initGetMV()
    if __oHashCache == Nil
        __oHashCache := THashMap():New()
    endif

return __oHashCache


//-------------------------------------------------------------------
/*/{Protheus.doc} _sgetmvreset
Limpa o cache da superGetMV
@author  Rodrigo Antonio - Eng. Protheus

/*/
//-------------------------------------------------------------------

function _sgetmvreset()
    __oHashCache:clean()    
return
//-------------------------------------------------------------------
/*/{Protheus.doc} _sputParCache
Seta um parametro via codigo, e atualiza o cache

@author  Rodrigo Antonio - Eng. Protheus
@param cVar Nome do parametro 
@param xValor Valor
@param cFilx Filial, default cFilAnt
/*/
//-------------------------------------------------------------------

function _sputParCache( cVar , xValor, cFilx)
    local lContinua
    local ckey
    local xResultado
    DEFAULT cFilx 	:= cFilAnt
    DEFAULT __aCache	:= {}
    lContinua := PutMv(cVar,xValor)
    if lContinua      
        cKey := cFilx + cVar
        if __oHashCache:Get(cKey,@xResultado)	    
            __oHashCache:set(cKey,xValor)
        endif      
    endif
return