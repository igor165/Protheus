#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT110BLO
        Ap�s a montagem da dialog de aprova��o da Solicita��o de compras. 
        � acionado quando o usu�rio clica nos bot�es Solicita��o Aprovada, 
        Rejeita ou Bloqueada, deve ser utilizado para continuar estas a��es 
        retorno .T.' ou interromper  'retorno .F.' , ap�s clicar os bot�es.
        
        Usado em complemento � rotina u_a110aprv para identificar qual bot�o foi 
        pressionado.
        
@since 20170328
@author JRScatolon
@return Logico, Sempre .t.  
/*/
user function MT110BLO()
local lRet := .t.
// ParamIXB[1]
//   3 -> "Solicitac�o Bloqueada"
//   1 -> "Solicitac�o Aprovada"
//   2 -> "Solicitac�o Rejeitada"
//   0 -> "Sair"
   nOpcAprv := ParamIXB[1]  

return lRet