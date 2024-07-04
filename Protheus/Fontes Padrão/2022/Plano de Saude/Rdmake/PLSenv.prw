
#include "protheus.ch"


// chamada no momento da subida da thread
// nao recebe parametro
// deve retornar .T. caso tenha conseguido subir o ambiente
User Function mystart
          
conout('iniciando')
RpcSetEnv ( "01", "01", "", "","","", {"BA0"} )       

return  .t. 


// funcao executada 
user function myconnect(x1,x2,x3,x4,x5,x6,cFn)
local cHtmlRet := ""
conout('vou executar '+cFN)
cHtmlRet := &cFn.(x1,x2,x3,x4,x5,x6)
conout('executei ela ('+cFn+')')
Return cHtmlRet


user function myexit
conout('finalizando')
return    



