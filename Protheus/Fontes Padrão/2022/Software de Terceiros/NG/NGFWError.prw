#Include "Protheus.ch"
#Include "NGFWERROR.CH"

//redefined in frameworkng.ch **************
#DEFINE __VALID_OBRIGAT__  'O'
#DEFINE __VALID_UNIQUE__   'U'
#DEFINE __VALID_FIELDS__   'F'
#DEFINE __VALID_BUSINESS__ 'B'
#DEFINE __VALID_ALL__      'OUFB'
#DEFINE __VALID_NONE__     ''
//******************************************

//------------------------------
// For�a a publica��o do fonte
//------------------------------
Function _NGFWError()
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NGFWError
Classe responsavel por armazenar uma listagem de erros.

@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@since 22/06/2012
@version P12
/*/
//------------------------------------------------------------------------------
Class NGFWError

	// Metodos Publicos
	Method New() CONSTRUCTOR

	Method getErrorList()
	Method getAskList()
	Method getInfoList()

	// Metodos Privados
	Method addError()
	Method addAsk()
	Method addInfo()
	Method clearList()
	Method msgRequired()

	// Atributos Privados
	Data aError As Array
	Data aAsk   As Array
	Data aInfo  As Array

EndClass

//------------------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo inicializador da classe.

@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@since 22/06/2012
@version P12
@return Nil
/*/
//------------------------------------------------------------------------------
Method New() Class NGFWError

	::aError := {}
	::aAsk   := {}
	::aInfo  := {}

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} addError
M�todo que adiciona um erro no objeto.

@param cError Descri��o do erro.
@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@since 22/06/2012
@version P12
@obs m�todo chamado nos m�todos de valida��o (validBusiness e afins)
@return Nil
/*/
//------------------------------------------------------------------------------
Method addError(cError) Class NGFWError

	aAdd(::aError,cError)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} addAsk
M�todo que adiciona uma pergunta yes/no no objeto.

@param cError Descri��o da pergunta yes/no.
@author Felipe Nathan Welter
@since 26/09/2017
@version P12
@obs m�todo chamado nos m�todos de valida��o (validBusiness e afins)
@return Nil
/*/
//------------------------------------------------------------------------------
Method addAsk(cAsk) Class NGFWError

	aAdd(::aAsk,cAsk)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} addInfo
M�todo que adiciona uma mensagem de processamento na classe, que pode ser
acessada ap�s a finaliza��o do upsert no programa chamador. Exemplo � a gera��o
de um registro e retorno de mensagem com seu c�digo, ou uma lista de log
do processamento realizado.

@param cInfo, caracter, Descri��o de mensagens informativas.
@author Maicon Andr� Pinheiro
@since  11/06/2018
@obs m�todo chamado nos m�todos de grava��o (upsert, delete e afins)
@return Nil
/*/
//------------------------------------------------------------------------------
Method addInfo(cInfo) Class NGFWError

	aAdd(::aInfo,cInfo)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} getErrorList
M�todo que retorna a lista completa de erros.

@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@since 22/06/2012
@version P12
@return array Lista dos erros gerados.
/*/
//------------------------------------------------------------------------------
Method getErrorList() Class NGFWError
Return ::aError

//------------------------------------------------------------------------------
/*/{Protheus.doc} getAskList
M�todo que retorna a lista completa de mensagens yes/no.

@author Felipe Nathan Welter
@since 26/09/2017
@version P12
@return array Lista das mensagens yes/no.
/*/
//------------------------------------------------------------------------------
Method getAskList() Class NGFWError
Return ::aAsk

//------------------------------------------------------------------------------
/*/{Protheus.doc} getInfoList
M�todo que retorna a lista completa de mensagens informativas

@author Maicon Andr� Pinheiro
@since  11/06/2018
@return Self:aInfo, array, Lista das mensagens informativas.
/*/
//------------------------------------------------------------------------------
Method getInfoList() Class NGFWError
Return ::aInfo

//------------------------------------------------------------------------------
/*/{Protheus.doc} ClearList
M�todo que limpa a lista de erros.

@author Felipe Nathan Welter
@since 17/04/2013
@version P12
@return Nil
/*/
//------------------------------------------------------------------------------
Method clearList() Class NGFWError

	::aError := {}
	::aAsk   := {}
	::aInfo  := {}

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} msgRequired
M�todo que concatena mensagem de campo obrigat�rio.

@author NG Inform�tica Ltda.
@since 01/01/2015
/*/
//------------------------------------------------------------------------------
Method msgRequired( cFieldReq , nLine ) Class NGFWError

	Local cMessage
	Default nLine := 0
	cMessage := STR0001 + Space(1) + Trim( RetTitle( cFieldReq ) ) //"O campo"
	cMessage += " (" + cFieldReq + STR0002 //") n�o foi preenchido"
	If nLine > 0
		cMessage += CRLF + Space(1) + STR0003 //"Linha:"
		cMessage += Space(1) + cValToChar( nLine )
	EndIf

Return cMessage