#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"   
#INCLUDE "SMARTCTI.CH"
#INCLUDE "FILEIO.CH" 
#INCLUDE "TMKXWSSMEVENTING.CH"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �  SMARTCTIWSEVENTING�Autor  �Michel W.Mosca� Data �10/25/06 ���
�������������������������������������������������������������������������͹��
���Desc.     �WebService respons�vel pela recepcao de eventos ocorridos no���
���          �Middleware e que os encaminha para as aplica��es cliente.   ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WsService SmartCTIWSEventing Description STR0001
//Par�metros            
WsData ReturnCode 	As Integer 						//C�digo de retorno para os metodos do WebService
WsData cDevice 		As String                       //Ramal que ocorreu o evento
WsData cAgentID 		As String                   //Operador para qual se destina o evento
WsData iLinkID 		As Integer                      //Codigo do Middleware de onde se destina o evento
WsData callID 		As String                       //Identificador da chamada
WsData ANI 			As String                       //Numero do chamador
WsData DNIS 		As String                      	//Numero chamado
WsData associatedData As String						//Dados associados a chamada
WsData callType 	As Integer						//Tipo de ligacao
WsData cGroupID		As String 						//Identificador do grupo ACD de onde se destina o evento
WsData Cause		As Integer                      //Causa da falha na chamada
                 
//M�todos
WsMethod InService 			Description STR0002   	//"Notifica que um usu�rio est� conectado ao Middleware"
WsMethod Ringing 			Description STR0003   	//"Notifica uma nova chamada" 
WsMethod ServiceInitiated 	Description STR0004		//"Notifica que o ramal saiu do gancho para discagem"
WsMethod ConnectionCleared 	Description STR0005     //"Notifica que uma chamada chegou ao fim"
WsMethod CallFailure		Description STR0006     //"Notifica erro ao iniciar uma chamada"
WsMethod Answered			Description STR0007     //"Notifica o atendimento de uma chamada receptiva no ramal"
WsMethod Originated			Description STR0008     //"Notifica que uma chamada come�ou a ser discada"
WsMethod Held				Description STR0009     //"Notifica que uma chamada foi enviada para espera"
WsMethod Retrieve			Description STR0010     //"Notifica que uma chamada saiu de Hold e retornou para o ramal"
WsMethod LoggedOn			Description STR0011     //"Notifica que um operador conectou-se ao DAC"
WsMethod LoggedOff 			Description STR0012     //"Notifica que um operador desconectou-se do DAC"
WsMethod Ready				Description STR0013     //"Notifica que um operador encontra-se dispon�vel para receber chamadas"
WsMethod NotReady			Description STR0014     //"Notifica que um operador encontra-se indispon�vel para receber chamadas"



EndWsService                                                 
                                  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �InService �Autor  �Michel W. Mosca     � Data �  24/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento utilizado para que o middleware notifique o servidor ���
���          �e operadores abaixo dele que o Device entrou em operacao.   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � InService(ExpC1,ExpN2) 	                                  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Ramal conectado no Middleware.                     ���
���          � ExpC2 = Identificado do Middleware.                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SmartCTI                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WsMethod InService WsReceive cDevice, iLinkID WsSend ReturnCode WsService SmartCTIWSEventing
//conout(DtoC(Date()) + " " + TIME() + "Processando WebService InService")
//conout("Parameters -> Device=" + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + "")
WriteLog(STR0015 + "Device=" + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + "") //"Processando WebService InService -> " #
::ReturnCode := SMARTCTI_SUCCESS
::ReturnCode := RPCCallBackGo(cDevice + AllTrim(Str(iLinkID)), "||ProcessEventsAPI('" + AllTrim(cDevice) + "', " + AllTrim(Str(iLinkID)) + ", '|oAgentEvents|oAgentEvents:Connected()')")
If SuperGetMV("MV_TKLOGEV",,.F.)
	WriteLog(STR0028 + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + " RC="+Str(::ReturnCode)+" Desc="+Iif(::ReturnCode==0,STR0029,STR0030)) // "Resultado Inservice Device="
EndIf
Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ringing   �Autor  �Michel W. Mosca     � Data �  30/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento utilizado para que o middleware notifique o servidor ���
���          �e operadores da ocorrencia de uma nova chamada receptiva.   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ringing(ExpC1,ExpN2, ExpC3, ExpC4, ExpC5, ExpC6, ExpN7)    ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Ramal conectado no Middleware.                     ���
���          � ExpN2 = Identificado do Middleware.                        ���
���          � ExpC3 = Identificacao da chamada no PABX.                  ���
���          � ExpC4 = Numero do chamador.                                ���
���          � ExpC5 = Numero chamado.                                    ���
���          � ExpC6 = Dados associados                                   ���
���          � ExpN7 = Tipo de chamada                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SmartCTI                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WsMethod Ringing WsReceive cDevice, iLinkID, callID, ANI, DNIS, associatedData, callType WsSend ReturnCode WsService SmartCTIWSEventing 
//conout(DtoC(Date()) + " " + TIME() + "Processando WebService Ringing")
//conout("Parameters -> Device=" + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + ", CallID=" + callID + ", ANI=" + ANI + ", DNIS=" + DNIS + ", AssociatedData=" + associatedData + ", CallType=" + AllTrim(Str(callType)) + "")
WriteLog(STR0016 + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + ", CallID=" + callID + ", ANI=" + ANI + ", DNIS=" + DNIS + ", AssociatedData=" + associatedData + ", CallType=" + AllTrim(Str(callType)) + "") //"Processando WebService Ringing -> Device="
::ReturnCode := SMARTCTI_SUCCESS      
::ReturnCode := RPCCallBackGo(cDevice + AllTrim(Str(iLinkID)), "||ProcessEventsAPI('" + AllTrim(cDevice) + "', " + AllTrim(Str(iLinkID)) + ", '|oAgentEvents, callID, ANI, DNIS, associatedData, callType|oAgentEvents:Ringing(callID, ANI, DNIS, associatedData, callType)', '" + callID + "', '" + ANI + "', '" + DNIS + "', '" + associatedData + "', '" + AllTrim(Str(callType)) + "')")
If SuperGetMV("MV_TKLOGEV",,.F.)
	WriteLog(STR0031 + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + " RC="+Str(::ReturnCode)+" Desc="+Iif(::ReturnCode==0,STR0029,STR0030)) //"Resultado Ringing Device="
EndIf 
Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ServiceInitiated�Autor �Michel W. Mosca� Data �  30/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento utilizado para que o middleware notifique o servidor ���
���          �e operadores de que o ramal esta fora do gancho.            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ServiceInitiated(ExpC1,ExpN2, ExpC3, ExpC4, ExpC5)    	  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Ramal conectado no Middleware.                     ���
���          � ExpN2 = Identificado do Middleware.                        ���
���          � ExpC3 = Identificacao da chamada no PABX.                  ���
���          � ExpC4 = Numero do chamador.                                ���
���          � ExpC5 = Numero chamado.                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SmartCTI                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WsMethod ServiceInitiated WsReceive cDevice, iLinkID, callID, ANI, DNIS WsSend ReturnCode WsService SmartCTIWSEventing 
//conout(DtoC(Date()) + " " + TIME() + "Processando WebService ServiceInitiated")
//conout("Parameters -> Device=" + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + ", CallID=" + callID + ", ANI=" + ANI + ", DNIS=" + DNIS + "")
WriteLog(STR0017 + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + ", CallID=" + callID + ", ANI=" + ANI + ", DNIS=" + DNIS + "") //"Processando WebService ServiceInitiated -> Device="
::ReturnCode := SMARTCTI_SUCCESS                                     
::ReturnCode := RPCCallBackGo(cDevice + AllTrim(Str(iLinkID)), "||ProcessEventsAPI('" + AllTrim(cDevice) + "', " + AllTrim(Str(iLinkID)) + ", '|oAgentEvents, callID, ANI, DNIS|oAgentEvents:ServiceInitiated(callID, ANI, DNIS)', '" + callID + "', '" + ANI + "', '" + DNIS + "')")
If SuperGetMV("MV_TKLOGEV",,.F.) 
	WriteLog(STR0032 + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + " RC="+Str(::ReturnCode)+" Desc="+Iif(::ReturnCode==0,STR0029,STR0030)) //	"Resultado ServiceInitiated Device="
EndIf
Return(.T.)  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ConnectionCleared�Autor�Michel W. Mosca� Data �  30/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento utilizado para que o middleware notifique o servidor ���
���          �e operadores do fim de uma chamada.                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ConnectionCleared(ExpC1,ExpN2, ExpC3, ExpC4, ExpC5)    	  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Ramal conectado no Middleware.                     ���
���          � ExpN2 = Identificado do Middleware.                        ���
���          � ExpC3 = Identificacao da chamada no PABX.                  ���
���          � ExpC4 = Numero do chamador.                                ���
���          � ExpC5 = Numero chamado.                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SmartCTI                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WsMethod ConnectionCleared WsReceive cDevice, iLinkID, callID, ANI, DNIS WsSend ReturnCode WsService SmartCTIWSEventing 
//conout(DtoC(Date()) + " " + TIME() + "Processando WebService ConnectionCleared")
//conout("Parameters -> Device=" + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + ", CallID=" + callID + ", ANI=" + ANI + ", DNIS=" + DNIS + "")
WriteLog(STR0018 + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + ", CallID=" + callID + ", ANI=" + ANI + ", DNIS=" + DNIS + "") //"Processando WebService ConnectionCleared -> Device="
::ReturnCode := SMARTCTI_SUCCESS                                     
::ReturnCode := RPCCallBackGo(cDevice + AllTrim(Str(iLinkID)), "||ProcessEventsAPI('" + AllTrim(cDevice) + "', " + AllTrim(Str(iLinkID)) + ", '|oAgentEvents, callID, ANI, DNIS|oAgentEvents:ConnectionCleared(callID, ANI, DNIS)', '" + callID + "', '" + ANI + "', '" + DNIS + "')")
If SuperGetMV("MV_TKLOGEV",,.F.) 
	WriteLog(STR0033 + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + " RC="+Str(::ReturnCode)+" Desc="+Iif(::ReturnCode==0,STR0029,STR0029)) //"Resultado ConnectionCleared Device="
EndIf
Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Answered  �Autor  �Michel W. Mosca     � Data �  30/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento utilizado para que o middleware notifique o servidor ���
���          �e operadores do atendimento de uma chamada.                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Answered(ExpC1,ExpN2, ExpC3, ExpC4, ExpC5) 			   	  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Ramal conectado no Middleware.                     ���
���          � ExpN2 = Identificado do Middleware.                        ���
���          � ExpC3 = Identificacao da chamada no PABX.                  ���
���          � ExpC4 = Numero do chamador.                                ���
���          � ExpC5 = Numero chamado.                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SmartCTI                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WsMethod Answered WsReceive cDevice, iLinkID, callID, ANI, DNIS WsSend ReturnCode WsService SmartCTIWSEventing 
//conout(DtoC(Date()) + " " + TIME() + "Processando WebService Answered")
//conout("Parameters -> Device=" + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + ", CallID=" + callID + ", ANI=" + ANI + ", DNIS=" + DNIS + "")
WriteLog(STR0019 + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + ", CallID=" + callID + ", ANI=" + ANI + ", DNIS=" + DNIS + "") //"Processando WebService Answered -> Device="
::ReturnCode := SMARTCTI_SUCCESS       
::ReturnCode := RPCCallBackGo(cDevice + AllTrim(Str(iLinkID)), "||ProcessEventsAPI('" + AllTrim(cDevice) + "', " + AllTrim(Str(iLinkID)) + ", '|oAgentEvents, callID, ANI, DNIS|oAgentEvents:Answered(callID, ANI, DNIS)', '" + callID + "', '" + ANI + "', '" + DNIS + "')")
If SuperGetMV("MV_TKLOGEV",,.F.) 
	WriteLog(STR0034 + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + " RC="+Str(::ReturnCode)+" Desc="+Iif(::ReturnCode==0,STR0029,STR0030)) //"Resultado Answered Device="
EndIf
Return(.T.)                                                          

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Originated�Autor  �Michel W. Mosca     � Data �  30/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento utilizado para que o middleware notifique o servidor ���
���          �e operadores do inicio da discagem de uma chamada ativa.    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Originated(ExpC1,ExpN2, ExpC3, ExpC4, ExpC5) 			  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Ramal conectado no Middleware.                     ���
���          � ExpN2 = Identificado do Middleware.                        ���
���          � ExpC3 = Identificacao da chamada no PABX.                  ���
���          � ExpC4 = Numero do chamador.                                ���
���          � ExpC5 = Numero chamado.                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SmartCTI                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WsMethod Originated WsReceive cDevice, iLinkID, callID, ANI, DNIS WsSend ReturnCode WsService SmartCTIWSEventing 
//conout(DtoC(Date()) + " " + TIME() + "Processando WebService Originated")
//conout("Parameters -> Device=" + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + ", CallID=" + callID + ", ANI=" + ANI + ", DNIS=" + DNIS + "")
WriteLog(STR0020 + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + ", CallID=" + callID + ", ANI=" + ANI + ", DNIS=" + DNIS + "") //"Processando WebService Originated -> Device="
::ReturnCode := SMARTCTI_SUCCESS                                     
::ReturnCode := RPCCallBackGo(cDevice + AllTrim(Str(iLinkID)), "||ProcessEventsAPI('" + AllTrim(cDevice) + "', " + AllTrim(Str(iLinkID)) + ", '|oAgentEvents, callID, ANI, DNIS|oAgentEvents:Originated(callID, ANI, DNIS)', '" + callID + "', '" + ANI + "', '" + DNIS + "')")
If SuperGetMV("MV_TKLOGEV",,.F.) 
	WriteLog(STR0035 + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + " RC="+Str(::ReturnCode)+" Desc="+Iif(::ReturnCode==0,STR0029,STR0030)) //"Resultado Originated Device="
EndIf
Return(.T.)   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Held      �Autor  �Michel W. Mosca     � Data �  30/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento utilizado para que o middleware notifique o servidor ���
���          �e operadores do inicio da discagem de uma chamada ativa.    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Held(ExpC1,ExpN2, ExpC3, ExpC4, ExpC5) 			  		  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Ramal conectado no Middleware.                     ���
���          � ExpN2 = Identificado do Middleware.                        ���
���          � ExpC3 = Identificacao da chamada no PABX.                  ���
���          � ExpC4 = Numero do chamador.                                ���
���          � ExpC5 = Numero chamado.                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SmartCTI                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WsMethod Held WsReceive cDevice, iLinkID, callID, ANI, DNIS WsSend ReturnCode WsService SmartCTIWSEventing 
//conout(DtoC(Date()) + " " + TIME() + "Processando WebService Held")
//conout("Parameters -> Device=" + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + ", CallID=" + callID + ", ANI=" + ANI + ", DNIS=" + DNIS + "")
WriteLog(STR0021 + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + ", CallID=" + callID + ", ANI=" + ANI + ", DNIS=" + DNIS + "") //"Processando WebService Held -> Device="
::ReturnCode := SMARTCTI_SUCCESS                                     
::ReturnCode := RPCCallBackGo(cDevice + AllTrim(Str(iLinkID)), "||ProcessEventsAPI('" + AllTrim(cDevice) + "', " + AllTrim(Str(iLinkID)) + ", '|oAgentEvents, callID, ANI, DNIS|oAgentEvents:Held(callID, ANI, DNIS)', '" + callID + "', '" + ANI + "', '" + DNIS + "')")
If SuperGetMV("MV_TKLOGEV",,.F.)
	WriteLog(STR0036 + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + " RC="+Str(::ReturnCode)+" Desc="+Iif(::ReturnCode==0,STR0029,STR0030)) //"Resultado Held Device="
EndIf 
Return(.T.)                 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa �CallFailure�Autor  �Michel W. Mosca     � Data �  30/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento utilizado para que o middleware notifique o servidor ���
���          �e operadores do inicio da discagem de uma chamada ativa.    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CallFailure(ExpC1,ExpN2, ExpC3, ExpC4, ExpC5, ExpN6)		  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Ramal conectado no Middleware.                     ���
���          � ExpN2 = Identificado do Middleware.                        ���
���          � ExpC3 = Identificacao da chamada no PABX.                  ���
���          � ExpC4 = Numero do chamador.                                ���
���          � ExpC5 = Numero chamado.                                    ���
���          � ExpC6 = Identificador da causa da falha.                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SmartCTI                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WsMethod CallFailure WsReceive cDevice, iLinkID, callID, ANI, DNIS, Cause WsSend ReturnCode WsService SmartCTIWSEventing 
//conout(DtoC(Date()) + " " + TIME() + "Processando WebService CallFailure")
//conout("Parameters -> Device=" + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + ", CallID=" + callID + ", ANI=" + ANI + ", DNIS=" + DNIS + ", Cause=" + AllTrim(Str(Cause)))
WriteLog(STR0022 + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + ", CallID=" + callID + ", ANI=" + ANI + ", DNIS=" + DNIS + ", Cause=" + AllTrim(Str(Cause))) //"Processando WebService CallFailure -> Device="
::ReturnCode := SMARTCTI_SUCCESS                                     
::ReturnCode := RPCCallBackGo(cDevice + AllTrim(Str(iLinkID)), "||ProcessEventsAPI('" + AllTrim(cDevice) + "', " + AllTrim(Str(iLinkID)) + ", '|oAgentEvents, callID, ANI, DNIS, Cause|oAgentEvents:CallFailure(callID, ANI, DNIS, Cause)', '" + callID + "', '" + ANI + "', '" + DNIS + "', " + AllTrim(Str(Cause)) + ")")
If SuperGetMV("MV_TKLOGEV",,.F.)
	WriteLog(STR0037 + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + " RC="+Str(::ReturnCode)+" Desc="+Iif(::ReturnCode==0,STR0029,STR0030)) //"Resultado CallFailure Device="
EndIf 
Return(.T.)  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Retrieve  �Autor  �Michel W. Mosca     � Data �  30/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento utilizado para que o middleware notifique o servidor ���
���          �e operadores de que a discagem de uma chamada finalizou em  ���
���          �destino ocupado.                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Busy(ExpC1,ExpN2, ExpC3, ExpC4, ExpC5) 					  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Ramal conectado no Middleware.                     ���
���          � ExpN2 = Identificado do Middleware.                        ���
���          � ExpC3 = Identificacao da chamada no PABX.                  ���
���          � ExpC4 = Numero do chamador.                                ���
���          � ExpC5 = Numero chamado.                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SmartCTI                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WsMethod Retrieve WsReceive cDevice, iLinkID, callID, ANI, DNIS WsSend ReturnCode WsService SmartCTIWSEventing 
//conout(DtoC(Date()) + " " + TIME() + "Processando WebService Retrieve")
//conout("Parameters -> Device=" + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + ", CallID=" + callID + ", ANI=" + ANI + ", DNIS=" + DNIS + "")
WriteLog(STR0023 + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + ", CallID=" + callID + ", ANI=" + ANI + ", DNIS=" + DNIS + "") //"Processando WebService Retrieve -> Device="
::ReturnCode := SMARTCTI_SUCCESS       
::ReturnCode := RPCCallBackGo(cDevice + AllTrim(Str(iLinkID)), "||ProcessEventsAPI('" + AllTrim(cDevice) + "', " + AllTrim(Str(iLinkID)) + ", '|oAgentEvents, callID, ANI, DNIS|oAgentEvents:Retrieve(callID, ANI, DNIS)', '" + callID + "', '" + ANI + "', '" + DNIS + "')")
If SuperGetMV("MV_TKLOGEV",,.F.)
	WriteLog(STR0038 + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + " RC="+Str(::ReturnCode)+" Desc="+Iif(::ReturnCode==0,STR0029,STR0030)) //"Resultado Retrieve Device="
EndIf 
Return(.T.)                  
                    
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LoggedOn  �Autor  �Michel W. Mosca     � Data �  30/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento utilizado para que o middleware notifique o servidor ���
���          �e operadores que o usuario esta conectado no DAC.           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � LoggedOn(ExpC1,ExpN2, ExpC3, ExpC4)		 				  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Ramal conectado no Middleware.                     ���
���          � ExpN2 = Identificado do Middleware.                        ���
���          � ExpC3 = Identificacao do agente no DAC.                    ���
���          � ExpC4 = Identificacao do grupo DAC.                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SmartCTI                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WsMethod LoggedOn WsReceive cDevice, iLinkID, cAgentID, cGroupID WsSend ReturnCode WsService SmartCTIWSEventing 
//conout(DtoC(Date()) + " " + TIME() + "Processando WebService LoggedOn")
//conout("Parameters -> Device=" + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + ", AgentID=" + cAgentID + ", GroupID=" + cGroupID + "")
WriteLog(STR0024 + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + ", AgentID=" + cAgentID + ", GroupID=" + cGroupID + "") //"Processando WebService LoggedOn -> Device="
::ReturnCode := SMARTCTI_SUCCESS       
::ReturnCode := RPCCallBackGo(cDevice + AllTrim(Str(iLinkID)), "||ProcessEventsAPI('" + AllTrim(cDevice) + "', " + AllTrim(Str(iLinkID)) + ", '|oAgentEvents, agentID, groupID|oAgentEvents:LoggedOn(agentID, groupID)', '" + cAgentID + "', '" + cGroupID + "')")
If SuperGetMV("MV_TKLOGEV",,.F.)
	WriteLog(STR0039 + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + " RC="+Str(::ReturnCode)+" Desc="+Iif(::ReturnCode==0,STR0029,STR0030)) //"Resultado LoggedOn Device="
EndIf
Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LoggedOff �Autor  �Michel W. Mosca     � Data �  30/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento utilizado para que o middleware notifique o servidor ���
���          �e operadores que o usuario esta desconectado no DAC.        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � LoggedOff(ExpC1,ExpN2, ExpC3, ExpC4)		 				  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Ramal conectado no Middleware.                     ���
���          � ExpN2 = Identificado do Middleware.                        ���
���          � ExpC3 = Identificacao do agente no DAC.                    ���
���          � ExpC4 = Identificacao do grupo DAC.                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SmartCTI                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WsMethod LoggedOff WsReceive cDevice, iLinkID, cAgentID, cGroupID WsSend ReturnCode WsService SmartCTIWSEventing 
//conout(DtoC(Date()) + " " + TIME() + "Processando WebService LoggedOff")
//conout("Parameters -> Device=" + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + ", AgentID=" + cAgentID + ", GroupID=" + cGroupID + "")
WriteLog(STR0025 + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + ", AgentID=" + cAgentID + ", GroupID=" + cGroupID + "") //"Processando WebService LoggedOff -> Device="
::ReturnCode := SMARTCTI_SUCCESS                                     
::ReturnCode := RPCCallBackGo(cDevice + AllTrim(Str(iLinkID)), "||ProcessEventsAPI('" + AllTrim(cDevice) + "', " + AllTrim(Str(iLinkID)) + ", '|oAgentEvents, agentID, groupID|oAgentEvents:LoggedOff(agentID, groupID)', '" + cAgentID + "', '" + cGroupID + "')")
If SuperGetMV("MV_TKLOGEV",,.F.)
	WriteLog(STR0040 + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + " RC="+Str(::ReturnCode)+" Desc="+Iif(::ReturnCode==0,STR0029,STR0030)) //"Resultado LoggedOff Device="
EndIf
Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ready     �Autor  �Michel W. Mosca     � Data �  30/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento utilizado para que o middleware notifique o servidor ���
���          �e operadores que o usuario esta disponivel para receber     ���
���          �chamadas transferidas pelo DAC.                             ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ready(ExpC1,ExpN2, ExpC3, ExpC4)	   		 				  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Ramal conectado no Middleware.                     ���
���          � ExpN2 = Identificado do Middleware.                        ���
���          � ExpC3 = Identificacao do agente no DAC.                    ���
���          � ExpC4 = Identificacao do grupo DAC.                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SmartCTI                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WsMethod Ready WsReceive cDevice, iLinkID, cAgentID, cGroupID WsSend ReturnCode WsService SmartCTIWSEventing 
//conout(DtoC(Date()) + " " + TIME() + "Processando WebService Ready")
//conout("Parameters -> Device=" + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + ", AgentID=" + cAgentID + ", GroupID=" + cGroupID + "")
WriteLog(STR0026 + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + ", AgentID=" + cAgentID + ", GroupID=" + cGroupID + "") //"Processando WebService Ready -> Device="
::ReturnCode := SMARTCTI_SUCCESS                                     
::ReturnCode := RPCCallBackGo(cDevice + AllTrim(Str(iLinkID)), "||ProcessEventsAPI('" + AllTrim(cDevice) + "', " + AllTrim(Str(iLinkID)) + ", '|oAgentEvents, agentID, groupID|oAgentEvents:Ready(agentID, groupID)', '" + cAgentID + "', '" + cGroupID + "')")
If SuperGetMV("MV_TKLOGEV",,.F.)
	WriteLog(STR0041 + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + " RC="+Str(::ReturnCode)+" Desc="+Iif(::ReturnCode==0,STR0029,STR0030)) // "Resultado Ready Device="
EndIf
Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NotReady  �Autor  �Michel W. Mosca     � Data �  30/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento utilizado para que o middleware notifique o servidor ���
���          �e operadores que o usuario esta indisponivel para receber   ���
���          �chamadas transferidas pelo DAC.                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � NotReady(ExpC1,ExpN2, ExpC3, ExpC4)		 				  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Ramal conectado no Middleware.                     ���
���          � ExpN2 = Identificado do Middleware.                        ���
���          � ExpC3 = Identificacao do agente no DAC.                    ���
���          � ExpC4 = Identificacao do grupo DAC.                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SmartCTI                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WsMethod NotReady WsReceive cDevice, iLinkID, cAgentID, cGroupID WsSend ReturnCode WsService SmartCTIWSEventing 
//conout(DtoC(Date()) + " " + TIME() + "Processando WebService NotReady")
//conout("Parameters -> Device=" + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + ", AgentID=" + cAgentID + ", GroupID=" + cGroupID + "")
WriteLog(STR0027 + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + ", AgentID=" + cAgentID + ", GroupID=" + cGroupID + "") //"Processando WebService NotReady -> Device="
::ReturnCode := SMARTCTI_SUCCESS                                     
::ReturnCode := RPCCallBackGo(cDevice + AllTrim(Str(iLinkID)), "||ProcessEventsAPI('" + AllTrim(cDevice) + "', " + AllTrim(Str(iLinkID)) + ", '|oAgentEvents, agentID, groupID|oAgentEvents:NotReady(agentID, groupID)', '" + cAgentID + "', '" + cGroupID + "')")
If SuperGetMV("MV_TKLOGEV",,.F.)
	WriteLog(STR0042 + cDevice + ",LinkID=" + AllTrim(Str(iLinkID)) + " RC="+Str(::ReturnCode)+" Desc="+Iif(::ReturnCode==0,STR0029,STR0030)) //"Resultado NotReady Device="
EndIf
Return(.T.)                

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |WriteLog        �Autor�Michel W. Mosca � Data �  10/11/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Escreve em arquivo de log.                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function WriteLog(cText)
Local cFileLog := ""
Local nAux

//�����������������������������������Ŀ
//|Grava o Log se estiver habilitado. |            
//�������������������������������������
If GetMv("MV_TKCTILG",.F.)
	cFileLog  := ALLTRIM(GetPvProfString(GetEnvServer(),"startpath","",GetADV97()))

	//������������������������������������������������������������������������������Ŀ
	//|Monta o nome do arquivo de log que sera grava no StartPath (SIGAADV)          |
	//��������������������������������������������������������������������������������		
	If Subs(cFileLog,Len(cFileLog),1) <> "\"
		cFileLog += "\"
	EndIf
	cFileLog += "SmartCTILog\"
	MakeDir(cFileLog)	                                                                                        
	//Apagar o log do dia posterior
	Ferase(cFileLog + "WSSMEVENTING-" + AllTrim(Str(Day(Date()+1))) + ".LOG")
	cFileLog += "WSSMEVENTING-" + AllTrim(Str(Day(Date()))) + ".LOG"
	
	If File(cFileLog)
		nAux := fOpen(cFileLog, FO_READWRITE+FO_SHARED)		
	Else
		nAux := fCreate(cFileLog,0)
	EndIf
	
	If nAux != -1
	   	FSeek(nAux,0,2)
		FWrite(nAux, AllTrim(DtoC(Date())) + " " + TIME() + " - " + cText + CRLF)
		FClose(nAux)
	EndIf
EndIf
	
Return NIL