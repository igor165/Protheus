#INCLUDE "TOTVS.CH"
#INCLUDE "Shopify.ch"
#INCLUDE "ShopifyExt.ch"

/*/{Protheus.doc} ShpInt003
    CRUD of integration parameters
    @type  Function
    @author Yves Oliveira
    @since 25/03/2020
    /*/
Function ShpInt003()
    
    Local cAlias   := "A1F"
	Local cTitulo  := STR0013 //"Shopify - Integration parameters"
	Local cVldExc  := ".T." 
	Local cVldAlt  := ".T." 
   
    If !IntegraShp()
	    Return .F. 
    Endif
	
	DbSelectArea(cAlias) 

    //aqui verifico se nao existe nenhum parametro eu crio os parametros necessarios para o Shopify funcionar
     ShpInitPar()

	(cAlias)->(DbSetOrder(1)) 

	AxCadastro(cAlias,cTitulo,cVldExc,cVldAlt)
    
Return 
