#include "FTCNEOWAYAPI.CH"
#Include 'TOTVS.CH'


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FTCNeowayAPI
Classe para utilização da API Neoway.

@author	Danilo Dias
@since		18/09/2013
@version	P11.9
/*/
//------------------------------------------------------------------------------------------
Class FTCNeowayAPI

	//Atributos
	Data cToken			//Chave utilizada nas requisições ao servidor Neoway
	Data nTimeOut			//Tempo de espera pela resposta de uma requisição
	Data aHeaderOut		//Cabeçalho para envio de requisições
	Data cHeaderReturn	//Cabeçalho de Resposta das requisições
	Data cParametro		//Parâmetros para envio das requisições
	Data cURL_Login		//URL utilizada para realizar a autenticação com o servidor Neoway
	Data cURL_User			//URL utilizada para realizar consulta de dados do usuário autenticado com o servidor Neoway
	Data cURL_Outputs		//URL utilizada para obter os endereços de requisições de Consulta, Campos 
	Data cURL_Filters		//URL para consulta de filtros existentes
	Data cURL_Fields		//URL para consulta de campos retornáveis
	Data cURL_List			//URL para realizar pesquisa de empresas
	Data cReturnHTTP		//Retorno da requisição HTTP
	Data oDados			//Objeto com o retorno no formato JSON deserializado
	Data cUsuSIMM			//Usuário SSIM
	Data cSenha			//Senha
	
	//Métodos
	Method New() Constructor			//Construtor da classe
	Method Authentication()			//Método de autenticação com o servidor Neoway
	Method CompaniesSearch()			//Método para realizar a pesquisa de empresas na Neoway
	Method GetOutputs()				//Método para obter as URL's para Pesquisa, Consulta de Campos de Filtro e Consulta de Campos Retornáveis
	Method GetUserDescription()		//Método para obter a descrição do usuário autenticado
	Method ConnectionTest()			//Método para realizar teste de conexão. Valida se o tempo de vida do token expirou
	Method ExecutePOST()				//Executa o método POST no servidor HTTP
	Method ExecuteGET()				//Executa o método GET no servidor HTTP
	Method GetHTTPStatus()			//Retorna o status da requisição HTTP
	Method Logged()					//Verifica se usuário já está logado

EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da classe.

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
Método utilizado para realizar a autenticação no servidor Neoway e obter o token, chave
necessária para todas as demais transações.

@sample	FTCNeowayAPI:Authentication( cUserName, cPassword )

@param		cUserName		Nome de usuário cadastrado na Neoway.
@param		cPassword		Senha do usuário.

@return	lSuccess		Indica se a autenticação foi bem sucedida.

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
		//Caso usuário e senha inválidos, limpa atributos
		::cUsuSIMM 	:= ""
		::cSenha		:= ""
		
	EndIf

Return lSuccess

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CompaniesSearch()
Método utilizado para realizar a pesquisa de empresas na base de dados da Neoway.

@sample	FTCNeowayAPI:CompaniesSearch( cFilter )

@param		cFilter		Filtro utilizado para a pesquisa.

@return	lSuccess		Indica se a autenticação foi bem sucedida.

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
Obtém os endereços de saída para consultas via API. Esses endereços devem ser obtidos em
tempo real pois, são variáveis de acordo com a empresa do usuário logado.

@sample	FTCNeowayAPI:GetOutputs()

@return	lSuccess	Indica se a execução do método foi bem sucedida.

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
Obtém os dados do usuário autenticado com o servidor Neoway.

@sample	FTCNeowayAPI:GetUserDescription()

@return	lSuccess	Indica se a execução do método foi bem sucedida.

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
Executa o método POST no servidor HTTP.

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
Executa o método GET no servidor HTTP.

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
Obtém o status da última requisição HTTP.

@sample	FTCNeowayAPI:GetHTTPStatus()

@return	aStatus	[1] - Código do status da requisição.
						[2] - Descrição do status 

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
		AAdd( aStatus, STR0002)//'Bad Request - O pedido não pode ser entregue devido à sintaxe incorreta.'
	EndIf
	
	If ( cCodigo == '401' )
		AAdd( aStatus, STR0003)//'Unauthorized - API Token inválido.'
	EndIf
	
	If ( cCodigo == '403' )
		AAdd( aStatus, STR0004)//'O limite de consultas foi excedido.'
	EndIf
	
	If ( cCodigo == '404' )
		AAdd( aStatus, STR0005)//'Not Found - O recurso requisitado não foi encontrado.'
	EndIf
	
	If ( cCodigo == '500' ) .Or. ( cCodigo == '505' )
		AAdd( aStatus, STR0006)//'Internal Server Error - Número de CNPJ inválido.'
	EndIf
	
Return aStatus


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Logged()
Verifica se usuário já está logado.

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
