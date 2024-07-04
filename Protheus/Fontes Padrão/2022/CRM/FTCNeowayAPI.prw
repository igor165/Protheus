#include "FTCNEOWAYAPI.CH"
#Include 'TOTVS.CH'


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FTCNeowayAPI
Classe para utiliza��o da API Neoway.

@author	Danilo Dias
@since		18/09/2013
@version	P11.9
/*/
//------------------------------------------------------------------------------------------
Class FTCNeowayAPI

	//Atributos
	Data cToken			//Chave utilizada nas requisi��es ao servidor Neoway
	Data nTimeOut			//Tempo de espera pela resposta de uma requisi��o
	Data aHeaderOut		//Cabe�alho para envio de requisi��es
	Data cHeaderReturn	//Cabe�alho de Resposta das requisi��es
	Data cParametro		//Par�metros para envio das requisi��es
	Data cURL_Login		//URL utilizada para realizar a autentica��o com o servidor Neoway
	Data cURL_User			//URL utilizada para realizar consulta de dados do usu�rio autenticado com o servidor Neoway
	Data cURL_Outputs		//URL utilizada para obter os endere�os de requisi��es de Consulta, Campos 
	Data cURL_Filters		//URL para consulta de filtros existentes
	Data cURL_Fields		//URL para consulta de campos retorn�veis
	Data cURL_List			//URL para realizar pesquisa de empresas
	Data cReturnHTTP		//Retorno da requisi��o HTTP
	Data oDados			//Objeto com o retorno no formato JSON deserializado
	Data cUsuSIMM			//Usu�rio SSIM
	Data cSenha			//Senha
	
	//M�todos
	Method New() Constructor			//Construtor da classe
	Method Authentication()			//M�todo de autentica��o com o servidor Neoway
	Method CompaniesSearch()			//M�todo para realizar a pesquisa de empresas na Neoway
	Method GetOutputs()				//M�todo para obter as URL's para Pesquisa, Consulta de Campos de Filtro e Consulta de Campos Retorn�veis
	Method GetUserDescription()		//M�todo para obter a descri��o do usu�rio autenticado
	Method ConnectionTest()			//M�todo para realizar teste de conex�o. Valida se o tempo de vida do token expirou
	Method ExecutePOST()				//Executa o m�todo POST no servidor HTTP
	Method ExecuteGET()				//Executa o m�todo GET no servidor HTTP
	Method GetHTTPStatus()			//Retorna o status da requisi��o HTTP
	Method Logged()					//Verifica se usu�rio j� est� logado

EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo construtor da classe.

@sample	FTWBANeoway():New()

@return	Self		Objeto da classe FTWBANeoway

@author	Danilo Dias
@since		18/09/2013
@version	P11.9
/*/
//------------------------------------------------------------------------------------------
Method New() Class FTCNeowayAPI

	::cToken			:= ""
	::nTimeOut			:= 120
	::aHeaderOut		:= {}
	::cHeaderReturn	:= ''
	::cURL_Login		:= 'https://simm.neoway.com.br/api/login'
	::cURL_User		:= 'https://simm.neoway.com.br/api/user'
	::cURL_Outputs	:= 'https://simm.neoway.com.br/api/search/v1/outputs'
	
	AAdd( ::aHeaderOut, 'User-Agent: Mozilla/4.0 (compatible; Protheus ' + GetBuild() + ')' )
	AAdd( ::aHeaderOut, 'Content-Type: application/x-www-form-urlencoded' )
	AAdd( ::aHeaderOut, 'Connection: Keep-Alive' )

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Authentication()
M�todo utilizado para realizar a autentica��o no servidor Neoway e obter o token, chave
necess�ria para todas as demais transa��es.

@sample	FTCNeowayAPI:Authentication( cUserName, cPassword )

@param		cUserName		Nome de usu�rio cadastrado na Neoway.
@param		cPassword		Senha do usu�rio.

@return	lSuccess		Indica se a autentica��o foi bem sucedida.

@author	Danilo Dias
@since		18/09/2013
@version	P11.9
/*/
//------------------------------------------------------------------------------------------
Method Authentication( cUserName, cPassword ) Class FTCNeowayAPI

	Local uValue		:= Nil
	Local lSuccess		:= .F.
	
	If !Empty(cUserName) .And. !Empty(cPassword)
		::cUsuSIMM 	:= cUserName
		::cSenha		:= cPassword
	EndIf
	
	::cParametro := 'simm_username=' + AllTrim(::cUsuSIMM) + '&simm_password=' + AllTrim(::cSenha)
	::ExecutePOST( ::cURL_Login )
	
	::oDados := FWJsonObject():New()
	
	If ( ValType(::cReturnHTTP) == 'C' ) .And. ( ::oDados:Activate(::cReturnHTTP) )
	
		If ::oDados:GetValueStr( @uValue, "simm-auth/token" )
			::cToken := uValue
			
			If ( Empty(::cURL_Fields) ) .Or. ( Empty(::cURL_Filters) ) .Or. ( Empty(::cURL_List) )
				::GetOutputs()
			EndIf
			
			lSuccess := .T.
		
		EndIf
		
	Else
		//Caso usu�rio e senha inv�lidos, limpa atributos
		::cUsuSIMM 	:= ""
		::cSenha		:= ""
		
	EndIf

Return lSuccess

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CompaniesSearch()
M�todo utilizado para realizar a pesquisa de empresas na base de dados da Neoway.

@sample	FTCNeowayAPI:CompaniesSearch( cFilter )

@param		cFilter		Filtro utilizado para a pesquisa.

@return	lSuccess		Indica se a autentica��o foi bem sucedida.

@author	Danilo Dias
@since		18/09/2013
@version	P11.9
/*/
//------------------------------------------------------------------------------------------
Method CompaniesSearch( cFilter ) Class FTCNeowayAPI

	Local lSuccess		:= .F.
	
	::cParametro := 'token=' + ::cToken + '&q=' + cFilter
	::ExecuteGET( ::cURL_List )

	If ( ValType(::cReturnHTTP) == 'C' ) .And. ( ::oDados:Activate(::cReturnHTTP) )
		lSuccess := .T.
	EndIf

Return lSuccess


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetOutputs()
Obt�m os endere�os de sa�da para consultas via API. Esses endere�os devem ser obtidos em
tempo real pois, s�o vari�veis de acordo com a empresa do usu�rio logado.

@sample	FTCNeowayAPI:GetOutputs()

@return	lSuccess	Indica se a execu��o do m�todo foi bem sucedida.

@author	Danilo Dias
@since		18/09/2013
@version	P11.9
/*/
//------------------------------------------------------------------------------------------
Method GetOutputs() Class FTCNeowayAPI
	
	Local uValue
	Local lSuccess		:= .F.
	
	::cParametro := 'token=' + ::cToken
	::ExecuteGET( ::cURL_Outputs )

	If ( ValType(::cReturnHTTP) == 'C' ) .And. ( ::oDados:Activate(::cReturnHTTP) )
		
		If ::oDados:GetValueStr( @uValue, "simm-outputs[1]/_link_list_filters" )
			::cURL_Filters := uValue
		EndIf
		
		If ::oDados:GetValueStr( @uValue, "simm-outputs[1]/_link_list_fields" )
			::cURL_Fields := uValue
		EndIf
		
		If ::oDados:GetValueStr( @uValue, "simm-outputs[1]/_link_list" )
			::cURL_List := uValue
		EndIf
		
		lSuccess := .T.
		
	EndIf
	
Return lSuccess
 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetUserDescription()
Obt�m os dados do usu�rio autenticado com o servidor Neoway.

@sample	FTCNeowayAPI:GetUserDescription()

@return	lSuccess	Indica se a execu��o do m�todo foi bem sucedida.

@author	Danilo Dias
@since		18/09/2013
@version	P11.9
/*/
//------------------------------------------------------------------------------------------
Method GetUserDescription() Class FTCNeowayAPI

	Local lSuccess := .F.
	
	::cParametro := 'token=' + ::cToken
	::ExecutePOST( Self:cURL_User )
	
	If ( ValType(::cReturnHTTP) == 'C' ) .And. ( ::oDados:Activate(::cReturnHTTP) )	
		lSuccess := .T.		
	EndIf
	
Return lSuccess


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExecutePOST()
Executa o m�todo POST no servidor HTTP.

@sample	FTCNeowayAPI:ExecutePOST( cURL )

@param		cURL	URL do servidor HTTP.

@author	Danilo Dias
@since		18/09/2013
@version	P11.9
/*/
//------------------------------------------------------------------------------------------
Method ExecutePOST( cURL ) Class FTCNeowayAPI

	::cReturnHTTP := HTTPPost( cURL, "", ::cParametro, ::nTimeOut, ::aHeaderOut, @::cHeaderReturn )

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExecuteGET()
Executa o m�todo GET no servidor HTTP.

@sample	FTCNeowayAPI:ExecuteGET( cURL )

@param		cURL	URL do servidor HTTP.

@author	Danilo Dias
@since		18/09/2013
@version	P11.9
/*/
//------------------------------------------------------------------------------------------
Method ExecuteGET( cURL ) Class FTCNeowayAPI

Local lSuccess := .T.

	::cReturnHTTP := HTTPGet( cURL, ::cParametro, ::nTimeOut, ::aHeaderOut, @Self:cHeaderReturn )
	
	If AllTrim(Str(HTTPGetStatus())) <> "200"
		lSuccess := .F.
	EndIf

Return lSuccess


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetHTTPStatus()
Obt�m o status da �ltima requisi��o HTTP.

@sample	FTCNeowayAPI:GetHTTPStatus()

@return	aStatus	[1] - C�digo do status da requisi��o.
						[2] - Descri��o do status 

@author	Danilo Dias
@since		18/09/2013
@version	P11.9
/*/
//------------------------------------------------------------------------------------------
Method GetHTTPStatus() Class FTCNeowayAPI

	Local aStatus := {}
	Local cCodigo	:= AllTrim(Str(HTTPGetStatus()))
	
	AAdd( aStatus, cCodigo )
	
	If ( cCodigo == '200' )
		AAdd( aStatus, STR0001)//'OK - Sucesso.'
	EndIf
	
	If ( cCodigo == '400' )
		AAdd( aStatus, STR0002)//'Bad Request - O pedido n�o pode ser entregue devido � sintaxe incorreta.'
	EndIf
	
	If ( cCodigo == '401' )
		AAdd( aStatus, STR0003)//'Unauthorized - API Token inv�lido.'
	EndIf
	
	If ( cCodigo == '403' )
		AAdd( aStatus, STR0004)//'O limite de consultas foi excedido.'
	EndIf
	
	If ( cCodigo == '404' )
		AAdd( aStatus, STR0005)//'Not Found - O recurso requisitado n�o foi encontrado.'
	EndIf
	
	If ( cCodigo == '500' ) .Or. ( cCodigo == '505' )
		AAdd( aStatus, STR0006)//'Internal Server Error - N�mero de CNPJ inv�lido.'
	EndIf
	
Return aStatus


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Logged()
Verifica se usu�rio j� est� logado.

@sample	FTCNeowayAPI:Logged()

@param		cURL	URL do servidor HTTP.

@author	Cristiane Nishizaka
@since		23/09/2013
@version	P11.9
/*/
//------------------------------------------------------------------------------------------
Method Logged() Class FTCNeowayAPI

Local lSuccess := .F.
	
	If !Empty(::cUsuSIMM) .And. !Empty(::cSenha)
		lSuccess := .T.
	EndIf

Return lSuccess
