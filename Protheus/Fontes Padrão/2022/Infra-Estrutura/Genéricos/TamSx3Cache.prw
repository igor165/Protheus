#include "protheus.ch"

static nPosX3_TAMANHO 
static nPosX3_DECIMAL
static nPosX3_TIPO
static __oHashCache := initHash()
//-------------------------------------------------------------------
/*/{Protheus.doc} _EngTamSX3
Versão em HashMap

@author  Rodrigo Antonio - Eng. Protheus

@param cCampo Campo do SX3
@return aRet Array com o tamanho, decimal e tipo
/*/
//-------------------------------------------------------------------
function _EngTamSX3( cCampo )
    local cSvFilAnt		:= cFilAnt
    local cKey
    local aRetorno := {}    
    cCampo := Alltrim(cCampo)
    cKey := cCampo
    if !__oHashCache:Get(cKey,@aRetorno)	            

        nOrdSX3 := SX3->( IndexOrd() )
        if nOrdSX3 != 2
            SX3->( dbSetOrder( 2 ) )
        endif
        If SX3->( MsSeek( cCampo ) )
            aRetorno := {SX3->( FieldGet( nPosX3_TAMANHO  ) ),SX3->( FieldGet( nPosX3_DECIMAL  ) ),SX3->( FieldGet( nPosX3_TIPO  ) )}
            __oHashCache:set(cKey,aRetorno)
        EndIf
        if nOrdSX3 != 2
            SX3->( dbSetOrder( nOrdSX3 ) )
        endif
    endif
    cFilAnt := cSvFilAnt    
return aClone(aRetorno) //Temos que clonar aqui, pois senão a referencia do cache é alterada pode ser alterada pelo chamador.


//-------------------------------------------------------------------
/*/{Protheus.doc} initHash
Inicializa o Hash

@author  Rodrigo Antonio - Eng. Protheus
/*/
//-------------------------------------------------------------------
static function initHash()
    if __oHashCache == Nil
        __oHashCache := THashMap():New()
        nPosX3_TAMANHO := SX3->( FieldPos( "X3_TAMANHO" ) )
        nPosX3_DECIMAL := SX3->( FieldPos( "X3_DECIMAL" ) )
        nPosX3_TIPO := SX3->( FieldPos( "X3_TIPO" ) )
    endif    
return __oHashCache


//-------------------------------------------------------------------
/*/{Protheus.doc} _etamsx3reset
Limpa o cache da TamSx3
@author  Rodrigo Antonio - Eng. Protheus

/*/
//-------------------------------------------------------------------

function _etamsx3reset()    
    __oHashCache:clean()
return