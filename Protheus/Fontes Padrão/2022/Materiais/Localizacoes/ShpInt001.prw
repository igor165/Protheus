#INCLUDE "TOTVS.CH"
#INCLUDE "Shopify.ch"
#INCLUDE "ShopifyExt.ch"
#INCLUDE "TOPCONN.CH"
#xcommand XCONOUT [<message>] => conout( '[ShpInt001] [Thread ' + cValtoChar( threadId() ) + '] [' + dtoc( date()) + ' ' + time() + '] ' + alltrim( <message> ) )

/*
{Protheus.doc} ShpInt001
JOB para chamada da rotina de gravacao 
do order shopify.

@author  Izo Cristiano Montebugnoli
@version 1.0
@since   03/30/2020
@return  Nil  Sem Retorno.
@sample  
*/
Function ShpInt001(aParam)

Local cXEmpresa	:= ""
Local cXFilial	:= ""
Local lJob			:= .T.
local cHoraInicio := time()
Local oInt 

//Local aSm0        := FwLoadSm0()
Default aParam := {"99","01"} //ambiente local de testes

If !IntegraShp()
	Return .F. 
Endif

XCONOUT STR0154 //start

If ValType(aParam) == "A"
	cXEmpresa    := aParam[1]
	cXFilial     := aParam[2]
Else
	cXEmpresa    := "01"
	cXFilial     := "01"
EndIf

If  LockByName("ShpInt001", .F., .F. )
	If lJob .and. Select("SX2") == 0
		RpcSetType( 3 )  //Sem licenca
		if !RpcSetEnv(cXEmpresa,cXFilial,,,'FAT')
			XCONOUT STR0155 + '[' + STR0156 + cXEmpresa + '/' + cXFilial + ']'//Invalid environment //Company/subsidiary:
			BREAK
		endif
	EndIf

	XCONOUT STR0159 //processing...
	
	ConOut( Replicate("R",80) )
	ConOut('['+DtoC(date())+' - '+Time()+'] '+STR0157+' ShpInt001 ==> '+ STR0158) //PROGRAM START //Orders integration Shopify
	ConOut( Replicate("R",80) )

    //Ativa o processamento das orders
    oInt := ShpOrder():new()
	oInt:getOrders() //busca o ultimo processamento	
    oInt:requestToShopify()
    freeObj(oInt)
	
	ConOut( Replicate("R",80) )
	ConOut('['+DtoC(date())+' - '+Time()+'] '+STR0160+' ShpInt001 ==>' +STR0158) //PROGRAM END//Orders integration Shopify
	ConOut( Replicate("R",80) )
	
	UnLockByName("ShpInt001", .F., .F. )
	
Else
	XCONOUT STR0161 + '(ShpInt001)' + STR0162 //program // Running code in another thread
Endif

XCONOUT STR0163 + elapTime( cHoraInicio, time() ) //End - Total time:

Return .T.
