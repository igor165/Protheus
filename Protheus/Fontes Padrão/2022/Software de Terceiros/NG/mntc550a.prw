#INCLUDE 'MNTC550.CH'
#INCLUDE 'PROTHEUS.CH'

//--------------------------------------------------
/*/{Protheus.doc} MNTC550A
Monta um browse com os problemas da ordem

@author Maria Elisandra de paula
@since 18/05/21
@return Nil
/*/
//--------------------------------------------------
Function MNTC550A()
	
    Local cFuncBkp := FunName()
    Local aMenu    := MenuDef()
    
    SetFunName( 'MNTC550A' )

    MNTC550PRO( aMenu )

    SetFunName( cFuncBkp )

Return 

//--------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da rotina

@author Maria Elisandra de paula
@since 18/05/21
@return array
/*/
//--------------------------------------------------
Static Function MenuDef()

    Local aReturn := {{ STR0012, 'NGVISUAL(,,, "NGCAD01" )', 0, 2 }} // Visualizar

Return aReturn
