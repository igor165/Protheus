#INCLUDE "BADEFINITION.CH"
#INCLUDE "BAENTITY.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BAEntity
Classe que representa uma entidade ( Entidade pode ser uma fato ou dimensão)

@author  Helio Leal
@since   31/08/2017
/*/
//-------------------------------------------------------------------
Class BAEntity
	Data cEntity
	Data cType
	Data cOrigin
	Data lChangeQry
	Data nStatus
	Data cTpExtr	

	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
	Method GetEntity( )
	Method GetType( )
	Method GetOrigin( )
	Method Destroy( )
	Method GetQuery( )
	Method GetStatus( )
	Method GetTpExtr( )
	Method SetTpExtr( )
	Method BuildUndefined( )
	Method ShowErrorMessage( ) 

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Instancia a entidade

@author  Andreia Lima
@since   08/09/2017
/*/
//-------------------------------------------------------------------
Method Setup( cEntity, cType, cOrigin, lChangeQry, cTpExtr ) Class BAEntity
	Default cEntity    := ""
	Default cType      := ""
	Default cOrigin    := ""
	Default lChangeQry := .T.
	Default cTpExtr	   := "P"

	::cEntity    := cEntity
	::cType      := cType
	::cOrigin    := cOrigin
	::lChangeQry := lChangeQry
	::nStatus    := MSG_SUCESS
	::cTpExtr	 := cTpExtr
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Toda classe (Entidade fato ou dimensão) deve implementar esse método, responsável pela montagem da query.

@return aQuery, array, deve retornar um array com as queries por empresa.

@author  Helio Leal
@since   01/09/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAEntity
	// Deve ser reescrito.
Return {}

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Destrói o objeto e libera a memória alocada. 

@author  Helio Leal
@since   04/09/2017
/*/
//-------------------------------------------------------------------
Method Destroy( ) Class BAEntity
	::cEntity := Nil
	::cType   := Nil
	::cOrigin := Nil
	::lChangeQry := Nil
	::nStatus    := Nil
	::cTpExtr	 := Nil
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetEntity
Retorna o nome da entidade.

@return ::cEntity, string, nome da entidade.

@author  Helio Leal
@since   01/09/2017
/*/
//-------------------------------------------------------------------
Method GetEntity( )  Class BAEntity
Return ::cEntity

//-------------------------------------------------------------------
/*/{Protheus.doc} GetType
Retorna o nome da entidade.

@return ::cType, string, tipo da entidade ( D: Dimensão, F: Fato)

@author  Helio Leal
@since   04/09/2017
/*/
//-------------------------------------------------------------------
Method GetType( )  Class BAEntity
Return ::cType

//-------------------------------------------------------------------
/*/{Protheus.doc} GetOrigin
Retorna a tabela origem do Protheus.

@return ::cOrigin, string, tabela origem do protheus.

@author  Helio Leal
@since   04/09/2017
/*/
//-------------------------------------------------------------------
Method GetOrigin( )  Class BAEntity
Return ::cOrigin

//-------------------------------------------------------------------
/*/{Protheus.doc} GetStatus
Retorna o status da entidade.

@return ::nStatus, integer, status da entidade.

@author  Andréia Lima
@since   16/04/2018
/*/
//-------------------------------------------------------------------
Method GetStatus( )  Class BAEntity
Return ::nStatus

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTpExtr
Retorna o tipo de extração da entidade. O conteúdo pode ser P=período
e M=mensal e afeta o fluxo apenas das fatos.

@return ::cTpExtr, string, tipo de extração

@author  Marcia Junko
@since   12/09/2018
/*/
//-------------------------------------------------------------------
Method GetTpExtr( )  Class BAEntity
Return ::cTpExtr

//-------------------------------------------------------------------
/*/{Protheus.doc} SetTpExtr
Atribui o tipo de extração da entidade. O conteúdo pode ser P=período
e M=mensal e afeta o fluxo apenas das fatos.

@return ::cTpExtr, string, tipo de extração

@author  Marcia Junko
@since   12/09/2018
/*/
//-------------------------------------------------------------------
Method SetTpExtr( cTpExtr )  Class BAEntity
	Default cTpExtr := "P"
	
	::cTpExtr := cTpExtr
Return ::cTpExtr

//-------------------------------------------------------------------
/*/{Protheus.doc} GetQuery
Retorna a query pronta para a gravação

@param cCompany, String, empresa.

@Return cQuery, String, Query.

@author  Andréia Lima
@since   08/09/2017
/*/
//-------------------------------------------------------------------
Method GetQuery( cCompany ) Class BAEntity
	Local cQuery     := ""
	Local cAuxQuery  := ""
	Local cQueryOrig := ""	
	Default cCompany := ""

	cQuery := ::BuildQuery()
	
	//-----------------------------------------------------------------------------
	// Armazena a query original para criação do registro indefinido das dimensões
	//-----------------------------------------------------------------------------
	cQueryOrig := cQuery
	
	cQuery := BAParseQuery( cQuery, cCompany )
	
	If ! ( Empty( cQuery ) )
		
		If ::lChangeQry
			cQuery := ChangeQuery( cQuery )
		EndIf

		If ::cType == DIMENSION
			If !BAExistDimension( ::cEntity, cCompany )
				cAuxQuery := ::BuildUndefined( Upper(cQueryOrig), ::cOrigin, cCompany )
			EndIf	

			If !Empty( cAuxQuery )
				cQuery += cAuxQuery
			EndIf	
		EndIf	
		
		cQuery := BACrypt( cQuery )
	Else
		::nStatus := MSG_ERR_EMPTY_QUERY	
	EndIf

Return cQuery 

//------------------------------------------------------------------- 
/*/{Protheus.doc} ShowErrorMessage
Mostra a mensagem de erro que ocorrer durante a execução do Fast Analytics

@param, cQuery, String, query da dimensão.

@author Helio Leal
@since 20/04/2018
/*/ 
//-------------------------------------------------------------------- 
Method ShowErrorMessage( nStatus ) Class BAEntity
	Default nStatus := MSG_SUCESS

	::nStatus := nStatus
	
	Do Case
		Case ( nStatus == MSG_ERR_TABLE_NOT_EXIST )
			ConOut( STR0004 + ::GetEntity( ) + STR0005 + ::GetOrigin( ) ) // "BAEntity:BuildUndefined - Erro na geração da entidade ##. Não foi encontrada a tabela ##
	EndCase
Return 

//------------------------------------------------------------------- 
/*/{Protheus.doc} BuildUndefined
Gera registro indefinido para a dimensão

@param, cQuery, String, query da dimensão.
@param, cOrigin, String, tabela origem da dimensão.
@param, cCompany, String, grupo de empresa da dimensão.

@Return cUndefined, String, Query do registro indefinido.

@author Marcia Junko Doi
@since 24/05/2018 
/*/ 
//-------------------------------------------------------------------- 

Method BuildUndefined( cQuery, cOrigin, cCompany ) Class BAEntity
	Local nFrom      := 0
	Local nUnion     := 0
	Local cUndefined := ""
	Local cField	 := ""
	Local cKey		 := ""
	Local aField     := {}
	Local nField     := 0
	Local cDatabase  := Upper( TCGetDB() )
	
	nFrom := At('FROM ', cQuery)
	nUnion := At(' UNION ', cQuery)
	
	If nFrom > 0 .Or. nUnion > 0 
		cUndefined := "UNION SELECT "
		If nFrom > 0
			cField := Subs( cQuery, 1, nFrom - 1)
		ElseIF nUnion > 0 
			cField := Subs( cQuery, 1, nUnion - 1)
		EndIf
	
		cKey := BAPrefixBK( "<<KEY_" + cOrigin + "_>>" ) + "|"

		aField := StrTokArr( cField, "," )
	
		For nField := 1 to Len(aField)
			//--------------------------------------------------------
			// Coloca o conteúdo da chave no campo correspondente a BK
			//--------------------------------------------------------
			If ( "BK_" $ aField[nField] )
				cUndefined += "'" + cKey + "'"
			Else
				cUndefined += "'" + cCompany + " - " + STR0001 + "'" //INDEFINIDO
			EndIf
	
			//----------------------------
			// Vírgula para separar campos
			//----------------------------
			If nField < Len( aField )
				cUndefined += ","
			EndIf
		Next
		Do Case    
			Case ( "ORACLE" $ cDatabase )
				cUndefined += " FROM DUAL "
			Case ( "DB2" $ cDatabase )
				cUndefined += " FROM SYSIBM.SYSDUMMY1 "
		EndCase
	EndIf 
	
Return cUndefined
