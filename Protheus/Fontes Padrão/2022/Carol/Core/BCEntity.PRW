#INCLUDE "BCDEFINITION.CH"
#INCLUDE "BCENTITY.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BCEntity
Classe que representa uma  entidade (fato ou dimensao)

@author  Andreia Lima
@since   23/04/2019
/*/
//-------------------------------------------------------------------
Class BCEntity
	Data cEntity
	Data cType
	Data cOrigin
	Data lChangeQry
	Data lChkQuery
	Data nStatus

	Method Setup( ) CONSTRUCTOR
	Method BuildView( )
	Method GetEntity( )
	Method GetType( )
	Method GetOrigin( )
	Method Destroy( )
	Method GetQuery( )
	Method GetView( )
	Method GetStatus( )
	Method BuildUndefined( )
	Method ShowErrorMessage( ) 
	Method GetNameView()
	Method GetUseOtherView( )

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Instancia a entidade

@author  Andreia Lima
@since   23/04/2019
/*/
//-------------------------------------------------------------------
Method Setup( cEntity, cType, cOrigin, lChangeQry, lChkQuery ) Class BCEntity
	Default cEntity    := ""
	Default cType      := ""
	Default cOrigin    := ""
	Default lChangeQry := .T.
	Default lChkQuery  := .T.
	

	::cEntity    := cEntity
	::cType      := cType
	::cOrigin    := cOrigin
	::lChangeQry := lChangeQry
	::lChkQuery  := lChkQuery
	::nStatus    := MSG_SUCESS

Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildView
Toda classe deve implementar esse metodo, responsavel pela montagem da view.

@return aQuery, array, deve retornar um array com as queries por empresa.

@author  Andreia Lima
@since   23/04/2019
/*/
//-------------------------------------------------------------------
Method BuildView( ) Class BCEntity
	// Deve ser reescrito.
Return {}

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Destroi o objeto e libera a memoria alocada. 

@author  Andreia Lima
@since   23/04/2019
/*/
//-------------------------------------------------------------------
Method Destroy( ) Class BCEntity
	::cEntity    := Nil
	::cType      := Nil
	::cOrigin    := Nil
	::lChangeQry := Nil
	::nStatus    := Nil
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetEntity
Retorna o nome da entidade.

@return ::cEntity, string, nome da entidade.

@author  Andreia Lima
@since   23/04/2019
/*/
//-------------------------------------------------------------------
Method GetEntity( )  Class BCEntity
Return ::cEntity

//-------------------------------------------------------------------
/*/{Protheus.doc} GetType
Retorna o nome da entidade.

@return ::cType, string, tipo da entidade ( D: Dimensao, F: Fato)
/*/
//-------------------------------------------------------------------
Method GetType( )  Class BCEntity
Return ::cType

//-------------------------------------------------------------------
/*/{Protheus.doc} GetOrigin
Retorna a tabela origem do Protheus.

@return ::cOrigin, string, tabela origem do protheus.

@author  Andreia Lima
@since   23/04/2019
/*/
//-------------------------------------------------------------------
Method GetOrigin( )  Class BCEntity
Return ::cOrigin

//-------------------------------------------------------------------
/*/{Protheus.doc} GetStatus
Retorna o status da entidade.

@return ::nStatus, integer, status da entidade.

@author  Andreia Lima
@since   23/04/2019
/*/
//-------------------------------------------------------------------
Method GetStatus( )  Class BCEntity
Return ::nStatus

//-------------------------------------------------------------------
/*/{Protheus.doc} GetView
Retorna a query pronta para a gravacao

@param cCompany, String, empresa.

@Return cQuery, String, Query.

@author  Andreia Lima
@since   23/04/2019
/*/
//-------------------------------------------------------------------
Method GetView( cCompany ) Class BCEntity
	Local cView      := ""
	Default cCompany := ""

	cView := ::BuildView()

	
	cView := BIParseQuery( cView, cCompany, 2 )
	
	If ! ( Empty( cView ) )
		
		If ::lChangeQry
			cView := ChangeQuery( cView )
		EndIf	
				
		If ( ::lChkQuery .And. !BITestDDL( cView ))
			::nStatus := MSG_ERR_CREATE_VIEW
		Else
			If ' AND 1=2 ' $ cView
				cView := StrTran( cView, ' AND 1=2 ',  '', 1, 1)
			EndIf
		
			cView := BICrypt( cView )
		EndIf
	Else
		::nStatus := MSG_ERR_EMPTY_QUERY	
	EndIf

Return cView 


//-------------------------------------------------------------------
/*/{Protheus.doc} GetUseOtherView
Retorna se a entidade utiliza uma outra view na sua estrutura

@return ::nStatus, integer, status da entidade.

@author  Marcia Junko
@since   09/10/2019
/*/
//-------------------------------------------------------------------
Method GetUseOtherView( )  Class BCEntity
Return Iif(::lChkQuery, "F", "T")

//------------------------------------------------------------------- 
/*/{Protheus.doc} ShowErrorMessage
Mostra a mensagem de erro que ocorrer durante a execucao da Carol

@param, cQuery, String, query da dimensao.

@author  Andreia Lima
@since   23/04/2019
/*/ 
//-------------------------------------------------------------------- 
Method ShowErrorMessage( nStatus ) Class BCEntity
	Default nStatus := MSG_SUCESS

	::nStatus := nStatus
	
	Do Case
		Case ( nStatus == MSG_ERR_TABLE_NOT_EXIST )
			ConOut( STR0001 + ::GetEntity( ) + STR0002 + ::GetOrigin( ) ) // "BCEntity:ShowErrorMessage - Erro na geracao da entidade ##. Nao foi encontrada a tabela ##
	EndCase
Return
