#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc}u_MT110Apv
    Valida se o usu�rio pode executa a rotina de aprova��o solicita��o de compras (MATA110).
@since 20170328
@author JRScatolon
@return Logico, retorna .t. caso o usu�rio tenha permiss�o para liberar e .f. caso contrario. 
/*/
user function MT110APV()
local lRet := .f.

    DbSelectArea("Z0A")
    DbSetOrder(1) // Z0A_FILIAL + Z0A_USERID 
    if DbSeek(xFilial("Z0A")+__cUserId) .and. Z0A->Z0A_MSBLQL <> '1'
        lRet := .t.
    endif
	
return lRet