#INCLUDE "TOTVS.CH"
#INCLUDE "Shopify.ch"
#INCLUDE "ShopifyExt.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} Shpint005
Monitor de integração SHOPIFY

@author Izo Cristiano Montebugnoli
@since 04/09/2020
@sample SCHMNTINT()
@return
@obs
/*/
Function Shpint005()

Local aArea	:= GetArea()	// Armazena ultima area utilizada 
If !IntegraShp()
	Return .F. 
Endif

oBrowse	:= Nil	   			// Objeto do Browse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('A1C')
oBrowse:SetDescription(STR0030)//'Monitor de integracao Shopify')

//Legendas 
oBrowse:AddLegend( "(A1C_STATUS = 'R')", "GREEN" ,STR0031,"1",.T.) //"Procesado"
oBrowse:AddLegend( "(A1C_STATUS = 'P')", "RED"   ,STR0032,"1",.T.)//"Falta processar"
oBrowse:AddLegend( "(A1C_STATUS = 'I')", "BLACK" ,STR0038,"1",.T.)//"Internal Error"


//Adiciona filters
//FWBrowse(): AddFilter ( "(A1C_STATUS = 'R')", < cExpAdvPL>, [ lNoCheck], [ lSelected], [ cAlias], [ lFilterAsk], [ aFilParser], [ cID] ) 
oBrowse:AddFilter("Orders"   , "( Alltrim(A1C_INTEGR) = 'ORDERS'			)" ,.F.)
oBrowse:AddFilter("Products" , "( Alltrim(A1C_INTEGR) = 'PRODUCTS'  		)" ,.F.) 
oBrowse:AddFilter("Customer" , "( Alltrim(A1C_INTEGR) = 'CUSTOMERS'  		)" ,.F.) 
oBrowse:AddFilter("Inventory", "( Alltrim(A1C_INTEGR) = 'INVENTORY_LEVELS'  )" ,.F.) 

//oBrowse:SetFilterDefault( "!(A1C_STATUS = 'P')")

oBrowse:Activate()

RestArea(aArea)

Return

/*/{Protheus.doc} MenuDef
Rotina para criacao do Menu
@author Izo Cristiano Montebugnoli
@since 04/09/2020
@sample MenuDef()
@return aRotina		Array com o menu da rotina
@obs
/*/
Static Function MenuDef()

	Local aRotina := {}  		// Array de retorno

	ADD OPTION aRotina TITLE   STR0033	ACTION 'VIEWDEF.Shpint005'       OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE   STR0034	ACTION 'Ship00501'               OPERATION 9 ACCESS 0 //'Reprocessar'

Return aRotina

/*/
{Protheus.doc} MenuDef
Rotina para criacao do Model
@author Izo Cristiano Montebugnoli
@since 04/09/2020
@sample MenuDef()
@return oModel		Modelo de dados da rotina
@obs
/*/
Static Function ModelDef()

Local oModel		:= Nil    							// Modelo de dados da rotina
Local oStruA1C	:= FWFormStruct( 1, 'A1C')				// Estrutura tabela A1C

oModel := MPFormModel():New('F010312M', /*bPreValidacao*/,/*bPosVld*/, /*bCommit*/,/* bCancel*/ )
oModel:AddFields( 'A1CMASTER', /*cOwner*/, oStruA1C, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetPrimaryKey( {"xFilial('A1C')","A1C_ID"} )
oModel:SetDescription( STR0035)// 'Monitor de Logs integração Shopify' )
oModel:GetModel( 'A1CMASTER' ):SetDescription( STR0035 )//'Monitor de Logs integração Shopify' )

Return oModel

/*/
{Protheus.doc} MenuDef
Rotina para criacao da View
@author Izo Cristiano Montebugnoli
@since 04/09/2020
@sample ViewDef()
@return oView		View da rotina
@obs
/*/

Static Function ViewDef()
Local oView		:= Nil							// View da rotina
Local oModel	:= FWLoadModel('Shpint005')		// Modelo de dados da rotina
Local oStruA1C	:= FWFormStruct(2,'A1C')		// Estrutura tabela A1C - Cabecalho

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_A1C', oStruA1C, 'A1CMASTER' )

Return oView

/*/{Protheus.doc} Ship00501
Rotina para encerrar o processo de
integração do  com o Protheus

@author Izo Cristiano Montebugnoli
@since 04/09/2020
@sample Ship00501(oModel)
/*/
Function Ship00501()
	
	Local aArea	:= GetArea()

	Local nRecno := A1C->(RECNO()) //guardo a informacao do recno para depois atualizar o status

	If A1C->A1C_STATUS = "P" .AND.  MsgYesNo( STR0036 + Alltrim(A1C->A1C_INTEGR) + "? ", STR0030 ) //  "Confirma reprocessar "  /"Monitor integração Shopify" quer dizer que vai precisar reprocessar a order novamente

		If  AtuStatA1C(nRecno,A1C->A1C_INTEGR,A1C->A1C_ID,A1C->A1C_IDEXT)
		
			If Alltrim(A1C->A1C_INTEGR) == Alltrim(ID_INT_ORDER) //quer dizer que vai precisar reprocessar ORDER novamente
				ProcrOrder(A1C->A1C_IDEXT) 
			ElseIf Alltrim(A1C->A1C_INTEGR) == Alltrim(ID_INT_CUSTOMER) //quer dizer que vai precisar reprocessar CUSTOMER novamente
				ProcCustomer( Val(A1C->A1C_ID) )
			ElseIf Alltrim(A1C->A1C_INTEGR) == Alltrim(ID_INT_PRODUCT) //quer dizer que vai precisar reprocessar PRODUCT novamente
				ProcProduct( Val(A1C->A1C_ID) )
			ElseIf Alltrim(A1C->A1C_INTEGR) == Alltrim(ID_INT_INVENTORY) //quer dizer que vai precisar reprocessar INVENTORY novamente
				ProcInventory( Val(A1C->A1C_ID) )
			ElseIf Alltrim(A1C->A1C_INTEGR) == Alltrim(ID_INT_CUSTOM_COLLECTION) //quer dizer que vai precisar reprocessar COLLECTION novamente
				ProcCollection( Val(A1C->A1C_ID) )
			EndIf 

			AtuStatA1C(nRecno)

		EndIF 


	EndIf

	RestArea(aArea)
	
Return



/*/{Protheus.doc} Ship00501
Rotina para encerrar o processo de
integração do  com o Protheus

@author Izo Cristiano Montebugnoli
@since 04/09/2020
@sample Ship00501(oModel)
/*/
Static Function AtuStatA1C(nRecno,cIntegr,cId,cIdext)

	Local aArea	:= GetArea()
	Local lRet := .T. 

	Default cIntegr := ""
	Default cId		:= ""
	Default cIdext  := ""

	//se tiver vazio cIntegr+cId+cIdext quer dizer que somente vai atualizar o registro posicionado caso ao contrario ira atualizar todos os registros execto o registro atuaal
	If Empty(cIntegr+cId+cIdext) 

		A1C->(MsGoTo(nRecno))
		oBrowse:Refresh()

		RecLock("A1C",.F.)
		A1C->A1C_STATUS	:= "R"		
		A1C->( MsUnLock() )

		oBrowse:GoTop()
			
		oBrowse:Refresh(.T.)	
	
	Else 

		cUpd := "UPDATE " + retSQLName("A1C")  + "  SET A1C_STATUS = 'R' " 		+ CRLF
		cUpd += "WHERE D_E_L_E_T_   = ' ' " 									+ CRLF
		cUpd += "AND A1C_INTEGR	    = '" + Alltrim(cIntegr) + "' " 				+ CRLF
		cUpd += "AND A1C_ID 		= '" + Alltrim(cId) + "' "  				+ CRLF
		cUpd += "AND A1C_IDEXT 		= '" + Alltrim(cIdext) + "' " 				+ CRLF
		cUpd += "AND R_E_C_N_O_ 	<> '" + Alltrim(cValtoChar(nRecno)) + "' "	+ CRLF

		If (TCSQLExec(cUpd) < 0)
			MsgStop("TCSQLError() " + TCSQLError())
			lRet := .F. 
		EndIf

	EndIf 

	RestArea(aArea)
Return lRet


/*/{Protheus.doc} Ship00501
Rotina para encerrar o processo de
integração do  com o Protheus

@author Izo Cristiano Montebugnoli
@since 04/09/2020
@sample Ship00501(oModel)
/*/
Static Function ProcrOrder(idExt)
	Local aArea	:= GetArea()
   	Local oInt 	

	oInt := ShpOrder():new()	   
	oInt:getOrderId(Alltrim(idExt)) //A1C->A1C_IDEXT
	oInt:requestToShopify()

	If !Empty(oInt:getMsgError()) //quer dizer que deu algum problema no processamento
		MsgStop( STR0037 + oInt:getMsgError() , STR0030 )//"Ocorreu Erro no processamento: "
	EndIf 

	freeObj(oInt)

	RestArea(aArea)
Return


/*/{Protheus.doc} Ship00501
Rotina para encerrar o processo de
integração do  com o Protheus

@author Izo Cristiano Montebugnoli
@since 04/09/2020
@sample Ship00501(oModel)
/*/
Static Function ProcCustomer(cId)

	Local aArea	:= GetArea()
   	Local oInt 	

	oInt  := ShpInteg():New()
	oInt:intCustomer(cId)

	If !Empty(oInt:error) //quer dizer que deu algum problema no processamento
		MsgStop( STR0037 + oInt:error , STR0030 )//"Ocorreu Erro no processamento: "
	EndIf 

	freeObj(oInt)	

	RestArea(aArea)

Return 


/*/{Protheus.doc} Ship00501
Rotina para encerrar o processo de
integração do  com o Protheus

@author Izo Cristiano Montebugnoli
@since 04/09/2020
@sample Ship00501(oModel)
/*/
Static Function ProcProduct(cId)

	Local aArea	:= GetArea()
   	Local oInt 	

	oInt  := ShpInteg():New()
	oInt:intProduct(cId)

	If !Empty(oInt:error) //quer dizer que deu algum problema no processamento
		MsgStop( STR0037 + oInt:error , STR0030 )//"Ocorreu Erro no processamento: "
	EndIf 

	freeObj(oInt)			

	RestArea(aArea)

Return 




/*/{Protheus.doc} Ship00501
Rotina para encerrar o processo de
integração do  com o Protheus

@author Izo Cristiano Montebugnoli
@since 04/09/2020
@sample Ship00501(oModel)
/*/
Static Function ProcInventory(cId)

	Local aArea	:= GetArea()
   	Local oInt 	

	oInt  := ShpInteg():New()
	oInt:intPGroup(cId)

	freeObj(oInt)			

	RestArea(aArea)

Return 



/*/{Protheus.doc} Ship00501
Rotina para encerrar o processo de
integração do  com o Protheus

@author Izo Cristiano Montebugnoli
@since 04/09/2020
@sample Ship00501(oModel)
/*/
Static Function ProcCollection(cId)

	Local aArea	:= GetArea()
   	Local oInt 	

	oInt  := ShpInteg():New()
	oInt:intPGroup(cId)

	freeObj(oInt)			

	RestArea(aArea)

Return 



