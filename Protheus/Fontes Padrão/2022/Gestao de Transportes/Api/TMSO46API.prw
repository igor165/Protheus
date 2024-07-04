#include "tbiconn.ch"
#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE 'TMSAO46API.ch'

/*/-----------------------------------------------------------
{Protheus.doc} WSTPRNeolog()
Call Back Planejamento Rotas  (TPR)
Uso: SIGATMS
@sample

@author Caio Murakami
@since 12/08/2019
@version 1.0
@type function
-----------------------------------------------------------/*/
WSRESTFUL WSTPRNEOLOG DESCRIPTION STR0004  FORMAT 'application/json,text/html' //-- "Serviço de callback para o TPR - Totvs Planejamento de Rotas" 

    WSDATA Fields     AS STRING  OPTIONAL

    WSMETHOD GET Main DESCRIPTION STR0005; //"Serviço para o recebimento de callback do TPR - Totvs Planejamento de Rotas"
    WSSYNTAX "V1/WSTPRNEOLOG/";
    PATH 'V1/WSTPRNEOLOG/';
    PRODUCES APPLICATION_JSON
    
    WSMETHOD POST Main DESCRIPTION STR0005; //-- "Método para postar as informações do callback TPR" 
    WSSYNTAX "V1/WSTPRNEOLOG/";
    PATH 'V1/WSTPRNEOLOG/';
    PRODUCES APPLICATION_JSON

    WSMETHOD GET NEWROUTE DESCRIPTION "Método para postar as atualizações de rotas TPR"; //O GET retorna se o servico esta no ar!
    WSSYNTAX "V1/WSTPRNEOLOG/NEWROUTE/";
    PATH 'V1/WSTPRNEOLOG/NEWROUTE/';
    PRODUCES APPLICATION_JSON

	WSMETHOD POST NEWROUTE DESCRIPTION "Método para postar as atualizações de rotas TPR";
    WSSYNTAX "V1/WSTPRNEOLOG/NEWROUTE/";
    PATH 'V1/WSTPRNEOLOG/NEWROUTE/';
    PRODUCES APPLICATION_JSON

ENDWSRESTFUL

/*/-----------------------------------------------------------
{Protheus.doc} POST /WSTPRNeolog
Call back integração tms x tpr

@param  WSTPRNeolog, caracter, Campos que serão retornados no GET.
@return .T.        , Lógico, Informa se o processo foi executado com sucesso.

@author Caio Murakami
@since 12/08/2019
@version 1.0
@type function
---------------------------------------------------------------/*/
WSMETHOD POST Main WSRECEIVE Callback WSSERVICE WSTPRNEOLOG
Local lRet          := .T. 
Local cResult       := self:getContent()
Local oResult       := FwJsonObject():New() 
Local cQualif       := ""
Local oQualifier    := FwJsonObject():New()

If FWJsonDeserialize(cResult,@oResult)
     If AttIsMemberOf(oResult,"qualifiers")
        cQualif     := oResult:qualifiers
        If FWJsonDeserialize(cQualif,@oQualifier)
            If AttIsMemberOf(oQualifier,"modulo")
                If AllTrim( Upper(oQualifier["modulo"])) == "TMS"
                    If AttIsMemberOf(oQualifier,"identifier")
                        lRet:= TMSAC21Prc( Upper(oQualifier["identifier"]), cResult )
                    EndIf
                ElseIf AllTrim( Upper(oQualifier["modulo"])) == "OMS"
                    If AttIsMemberOf(oQualifier,"identifier")
						LogMsg( "TMSO46API",0, 0,1, cValToChar(TIME()), '',"TOTVS Planejamento de Rotas(TPR) - TMSO46API/Main - Tentando fazer login com empresa: " +;
						 		cValToChar(oQualifier["empresa"]) + " e filial: " +;
						  		cValToChar(oQualifier["filial"]) + " no módulo: " +;
						  		cValToChar(oQualifier["modulo"]) )
						RpcSetType(3)
						RpcClearEnv()
						If RpcSetEnv(oQualifier["empresa"],oQualifier["filial"],,,AllTrim( Upper(oQualifier["modulo"])) ,,)
							lRet:= OMSATPR2( oQualifier["identifier"], cResult )
						EndIf
                    EndIf
                EndIf 

                If lRet
                    ::SetResponse('{"result":"Processado com sucesso." } ')
                Else 
                    ::SetResponse('{"error":"Ocorreram falhas no processamento." } ')
                EndIf 
            EndIf 
        EndIf 
       
     EndIf
EndIf

Return .T. 


/*/-----------------------------------------------------------
{Protheus.doc} POST /WSTPRNeolog/NEWROUTE
Call back integração tms x tpr - Nova Rota

@param  WSTPRNeolog, caracter, Campos que serão retornados no GET.
@return .T.        , Lógico, Informa se o processo foi executado com sucesso.

@author Equipe OMS
@since 02/05/2022
@version 1.0
@type function
---------------------------------------------------------------/*/
WSMETHOD POST NEWROUTE WSSERVICE WSTPRNEOLOG
	Local lRet          := .F. 
	Local cResult       := Decodeutf8(self:getContent())
	Local oResult       := FwJsonObject():New() 
	Local cIdentif      := ""
	Local oIdentifier   := FwJsonObject():New()
	Local oViagem 		:= nil

	If FWJsonDeserialize(cResult,@oResult)
		If AttIsMemberOf(oResult,"tripResults")
			If !Empty(oResult:TRIPRESULTS)
				oViagem  := oResult:TRIPRESULTS[1] //Recebemos uma lista (sem cabeçalho)
				cIdentif := oViagem:identifier
			EndIf
			If FWJsonDeserialize(cIdentif,@oIdentifier)
				If AttIsMemberOf(oIdentifier,"modulo")
					If AllTrim( Upper(oIdentifier["modulo"])) == "OMS"
						If AttIsMemberOf(oIdentifier,"identifier")
							LogMsg( "TMSO46API",0, 0,1, cValToChar(TIME()), '',"TOTVS Planejamento de Rotas(TPR) - TMSO46API/NEWROUTE - Tentando fazer login com empresa: " +;
						 		cValToChar(oIdentifier["empresa"]) + " e filial: " +;
						  		cValToChar(oIdentifier["filial"]) + " no módulo: " +;
						  		cValToChar(oIdentifier["modulo"]) )
							RpcSetType(3)
							RpcClearEnv()
							If RpcSetEnv(oIdentifier["empresa"],oIdentifier["filial"],,,AllTrim( Upper(oIdentifier["modulo"])) ,,)
								lRet:= OMSATPR7( oIdentifier, cResult )
							EndIf
						EndIf
						If lRet
							::SetResponse('{"result":"Processado com sucesso." } ')
						Else 
							::SetResponse('{"error":"Ocorreram falhas no processamento." } ')
						EndIf 
					EndIf
				EndIf 
			EndIf 
		EndIf
	EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} GET /WSTPRNeolog
GET WSTPRNeolog - TPR Neolog

@param  WSTPRNeolog, caracter, Campos que serão retornados no GET.

@author Caio Murakami
@since 12/08/2019
@version 1.0
@type function
---------------------------------------------------------------/*/
WSMETHOD GET Main WSSERVICE WSTPRNeolog

	::SetContentType("application/json")
	::SetResponse('{"id":"TPR X PROTHEUS", "status":"Serviço para o recebimento de callback do TPR - Totvs Planejamento de Rotas"}')

Return .T. 


/*/-----------------------------------------------------------
{Protheus.doc} GET /WSTPRNeolog/NEWROUTE
GET WSTPRNeolog/NEWROUTE - TPR Neolog

@param  WSTPRNeolog, caracter, Campos que serão retornados no GET.

@author Equipe OMS
@since 29/04/2022
@version 1.0
@type function
---------------------------------------------------------------/*/
WSMETHOD GET NEWROUTE WSSERVICE WSTPRNeolog

	::SetContentType("application/json")
	::SetResponse('{"id":"TPR X PROTHEUS - Nova Rota", "status":"Serviço para o recebimento de callback do TPR para atualização de rotas - Totvs Planejamento de Rotas"}')

Return .T. 




