#INCLUDE 'MNTC550.CH'
#INCLUDE 'PROTHEUS.CH'

//--------------------------------------------------
/*/{Protheus.doc} MNTC550B
Monta um browse com as etapas da ordem

@author Maria Elisandra de Paula
@since 18/05/21
@return Nil
/*/
//--------------------------------------------------
Function MNTC550B()
	
    Local cFuncBkp := FunName()
    Local aMenu    := MenuDef()
    
    SetFunName( 'MNTC550B' )

    OSETAPAS2( aMenu )

    SetFunName( cFuncBkp )

Return 

//--------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da rotina

@author Maria Elisandra de Paula
@since 18/05/21
@return array
/*/
//--------------------------------------------------
Static Function MenuDef()

    Local aReturn := { { STR0012 , 'NGVISUAL(,,, "NGCAD01" )', 0, 2 },; //"Visualizar"
				        { STR0025 , 'TPQRESPOS', 0, 4 } }  // 'Opcoes'

Return aReturn
