#INCLUDE "TOTVS.CH"
#INCLUDE "Shopify.ch"
#INCLUDE "ShopifyExt.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} Shpint005
Painel SHOPIFY

@author Izo Cristiano Montebugnoli
@since 04/11/2020
@sample SCHMNTINT()
@return
@obs
/*/
Function ShpInt007()
	Local aArea   := GetArea()

	Local cTitulo := STR0030 //"Shopify Integration Monitor "

	DEFINE DIALOG oDlg TITLE cTitulo FROM 300,050 TO 450,350 PIXEL

	ACTIVATE DIALOG oDlg CENTERED

	RestArea(aArea)
Return Nil
