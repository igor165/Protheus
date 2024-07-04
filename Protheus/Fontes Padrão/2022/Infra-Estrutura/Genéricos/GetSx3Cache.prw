#include "protheus.ch"
static __oHashSX3Pos
static __oHashCache := initSx3Cache()    
//Atencão a funcao de inicialização static precisar sempre ser chamada depois de todas a declaracoes de staticas



//-------------------------------------------------------------------
/*/{Protheus.doc} initSx3Cache
Inicializa o cache se for possivel

/*/
//-------------------------------------------------------------------
static function initSx3Cache()    
    if __oHashCache == Nil
        __oHashCache := THashMap():New()
        __oHashSX3Pos := THashMap():New()
    endif
return __oHashCache
//-------------------------------------------------------------------
/*/{Protheus.doc} _GtSx3Cached
Refactory da SuperGetMV

@author  Rodrigo Antonio - Eng. Protheus
@param cSX3Campo
@param cCampo
@return Se existir retorna o conteudo do campo
/*/
//-------------------------------------------------------------------

function _GtSx3Cached(cSX3Campo,cCampo) 
    local cSvFilAnt		:= cFilAnt
    local xResultado
    local cKey
    local nFieldPosOnSX3
    cSX3Campo := PadR( cSX3Campo , 10 )    
    cKey := cCampo + cSX3Campo
    if !__oHashCache:Get(cKey,@xResultado)	    
        //Busca no Cache de fieldpos a coluna do SX3        
        if !__oHashSX3Pos:Get(cCampo,@nFieldPosOnSX3)	            
            nFieldPosOnSX3 := SX3->( FieldPos( cCampo ) )
            if (nFieldPosOnSX3 == 0)
                UserException("Invalid SX3 field.")
            Endif
            __oHashSX3Pos:set(cCampo,nFieldPosOnSX3)
            
        endif

        nOrdSX3 := SX3->( IndexOrd() )
        if nOrdSX3 != 2
            SX3->( dbSetOrder( 2 ) )
        endif
        If SX3->( MsSeek( cSX3Campo ) )
            xResultado := SX3->( FieldGet( nFieldPosOnSX3 ) )
            __oHashCache:set(cKey,xResultado)
        EndIf
        if nOrdSX3 != 2
            SX3->( dbSetOrder( nOrdSX3 ) )
        endif
    endif
    cFilAnt := cSvFilAnt
return xResultado


//-------------------------------------------------------------------
/*/{Protheus.doc} _sgetmvreset
Limpa o cache da GetSx3Cache
@author  Rodrigo Antonio - Eng. Protheus

/*/
//-------------------------------------------------------------------
function _sgtsx3reset()    
    __oHashCache:clean()
return
