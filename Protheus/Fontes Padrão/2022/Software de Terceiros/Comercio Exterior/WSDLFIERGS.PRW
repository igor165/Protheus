#include 'protheus.ch'
#include 'parmtype.ch'

#define DATETIME DTOC(DATE()) + " " + TIME()
#define LINHA    CRLF + REPLICATE("-", 99) + CRLF

/*
Programa  : WSDLFIERGS.PRW
Objetivo  : Integra��o FIERGS
Par�metros: nOp  - 1-Teste conex�o / 2-Envio certificado origem
            cURL - Endere�o do WSDL
            cUser- Usuario para conectar no Webservices
            cPWD - Senha de acesso ao Webservices
            cMSG - Mensagem SOAP que ser� enviada ao servi�o
            lAtuTela - Verifica se o objeto de status da tela ser� atualizado
Retorno   : L�gico (.T. ou .F.)
Autor     : Laercio G Souza Junior
Data      : Outubro de 2015
Obs.      : 
*/
FUNCTION WSDLFIERGS(nOp,cURL,cUser,cPWD,cMSG,lAtuTela)

LOCAL lRet��� := Nil
LOCAL cSOAP	:= ""
LOCAL oWsdl�� := Nil
LOCAL cMsgRet := ""
LOCAL cOper   := ""
Default nOp   := 1
Default cURL  := cUser := cPWD := cMSG := ""
Default lAtuTela := .F.

Begin Sequence���
	
	If Empty(cUser) .Or. Empty(cPWD)
	   cSBMsg += DATETIME + CRLF + "Informe usuario e senha antes de realizar o teste de conex�o" + LINHA
	   If lAtuTela
	      oTMultMSG:Refresh()
	      oTMultMSG:GoEnd()
	   EndIf
	   Break
	EndIf
	
	/*******
	1-Teste de conexao (consultarPaises)
	************************************/
	cOper := "consultarPaises"
	
	/*******
	Cria metodo webservice
	***********************/
	oWsdl := TWsdlManager():New()
	
	/*******
	Realiza o parse do wsdl para recuperar os metodos //conout(DecodeUTF8(cMsgRet))
	*******************************************************************************/
	lRet := oWsdl:ParseURL(cURL)
	If lRet == .F.
	   cMsgRet := "Erro ParseURL: " + oWsdl:cError
	   cSBMsg += DATETIME + CRLF + DecodeUTF8(cMsgRet) + LINHA
	   If lAtuTela
	      oTMultMSG:Refresh()
	      oTMultMSG:GoEnd()
	   EndIf
	   Break
	EndIf
	
	/*******
	Define a opera��o
	*********************************/
	lRet := oWsdl:SetOperation(cOper)
	If lRet == .F.
	   cMsgRet := "Erro SetOperation: " + oWsdl:cError
	   cSBMsg += DATETIME + CRLF + DecodeUTF8(cMsgRet) + LINHA
	   If lAtuTela
	      oTMultMSG:Refresh()
	      oTMultMSG:GoEnd()
	   EndIf
	   Break
	EndIf
	
	/*******
	Mensagem enviada com namespace de SOAP 1.1 (Teste de Conex�o)
	*************************************************************/
	cSOAP := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://servicos.fiergs.org.br" xmlns:dto="http://dto.web.servicos.fiergs.org.br">'
	cSOAP += '<soapenv:Header/>'
	cSOAP += '<soapenv:Body>'
	cSOAP += '<ser:consultarPaises>'
	cSOAP += '<ser:in0>'
	cSOAP += '<dto:senha>'+EncodeUtf8(cPWD)+'</dto:senha>'
	cSOAP += '<dto:usuario>'+EncodeUtf8(cUser)+'</dto:usuario>'
	cSOAP += '</ser:in0>'
	cSOAP += '</ser:consultarPaises>'
	cSOAP += '</soapenv:Body>'
	cSOAP += '</soapenv:Envelope>'
	
	/*
	Envia uma mensagem SOAP personalizada ao servidor
	**************************************************/
	lRet := oWsdl:SendSoapMsg( cSOAP )
	If lRet == .F.
	   cMsgRet := "Erro SendSoapMsg: " + oWsdl:cError + CRLF + "Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode
	   cSBMsg += DATETIME + CRLF + DecodeUTF8(cMsgRet) + LINHA
	   If lAtuTela
	      oTMultMSG:Refresh()
	      oTMultMSG:GoEnd()
	   EndIf
	   Break
	EndIf
	        
	/*
	Recupera o xml de retorno do servi�o
	*************************************/
	cMsgRet := oWsdl:GetSoapResponse()
	If !Empty(cMsgRet)
	   cSBMsg += DATETIME + CRLF + "Teste de conex�o OK." + LINHA
	   If lAtuTela
	      oTMultMSG:Refresh()
	      oTMultMSG:GoEnd()
	   EndIf
	EndIf
	
	Do case  
	   Case nOp == 2
	        cOper := "inserirCertificado"
	        
	        If Empty(cMSG)
	           cSBMsg += DATETIME + CRLF + "O XML de integra��o com a FIERGS est� vazio e n�o poder� ser transmitido" + LINHA
	           Break
	        Else
	           /*******
	           Mensagem enviada com namespace de SOAP 1.1
	           *******************************************/
	           cSOAP := cMSG
	        EndIf
	        
	        /*******
	        Define a opera��o
	        *********************************/
	        lRet := oWsdl:SetOperation(cOper)
	        If lRet == .F.
	           cMsgRet := "Erro SetOperation: " + oWsdl:cError
	           cSBMsg += DATETIME + CRLF + DecodeUTF8(cMsgRet) + LINHA
	           Break
	        EndIf
	        
	        /*******
	        Envia uma mensagem SOAP personalizada ao servidor
	        **************************************************/
	        lRet := oWsdl:SendSoapMsg( cSOAP )
	        If lRet == .F.
	           cMsgRet := "Erro SendSoapMsg: " + oWsdl:cError + CRLF + "Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode
	           cSBMsg += DATETIME + CRLF + DecodeUTF8(cMsgRet) + LINHA
	           Break
	        EndIf
	        
	        /*******
	        Recupera o xml de retorno do servi�o
	        *************************************/
	        cMsgRet := oWsdl:GetSoapResponse()
	        If !Empty(cMsgRet)
	           cSBMsg += DATETIME + CRLF + "Certificado cadastrado com sucesso." + LINHA
	        EndIf
	EndCase
	
End Sequence

return lRet