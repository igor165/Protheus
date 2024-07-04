#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"   
#INCLUDE "SMARTCTI.CH"
#INCLUDE "FILEIO.CH" 
#INCLUDE "TMKXWSSMEVENTING.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออหอออออออัออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบPrograma  ณ  SMARTCTIWSEVENTINGบAutor  ณMichel W.Moscaบ Data ณ10/25/06 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออสอออออออฯออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณWebService responsแvel pela recepcao de eventos ocorridos noบฑฑ
ฑฑบ          ณMiddleware e que os encaminha para as aplica็๕es cliente.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
WsService SmartCTIWSEventing Description STR0001
//Parโmetros            
WsData ReturnCode 	As Integer 						//C๓digo de retorno para os metodos do WebService
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
                 
//M้todos
WsMethod InService 			Description STR0002   	//"Notifica que um usuแrio estแ conectado ao Middleware"
WsMethod Ringing 			Description STR0003   	//"Notifica uma nova chamada" 
WsMethod ServiceInitiated 	Description STR0004		//"Notifica que o ramal saiu do gancho para discagem"
WsMethod ConnectionCleared 	Description STR0005     //"Notifica que uma chamada chegou ao fim"
WsMethod CallFailure		Description STR0006     //"Notifica erro ao iniciar uma chamada"
WsMethod Answered			Description STR0007     //"Notifica o atendimento de uma chamada receptiva no ramal"
WsMethod Originated			Description STR0008     //"Notifica que uma chamada come็ou a ser discada"
WsMethod Held				Description STR0009     //"Notifica que uma chamada foi enviada para espera"
WsMethod Retrieve			Description STR0010     //"Notifica que uma chamada saiu de Hold e retornou para o ramal"
WsMethod LoggedOn			Description STR0011     //"Notifica que um operador conectou-se ao DAC"
WsMethod LoggedOff 			Description STR0012     //"Notifica que um operador desconectou-se do DAC"
WsMethod Ready				Description STR0013     //"Notifica que um operador encontra-se disponํvel para receber chamadas"
WsMethod NotReady			Description STR0014     //"Notifica que um operador encontra-se indisponํvel para receber chamadas"



EndWsService                                                 
                                  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณInService บAutor  ณMichel W. Mosca     บ Data ณ  24/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEvento utilizado para que o middleware notifique o servidor บฑฑ
ฑฑบ          ณe operadores abaixo dele que o Device entrou em operacao.   บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ InService(ExpC1,ExpN2) 	                                  ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Ramal conectado no Middleware.                     ณฑฑ
ฑฑณ          ณ ExpC2 = Identificado do Middleware.                        ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SmartCTI                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRinging   บAutor  ณMichel W. Mosca     บ Data ณ  30/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEvento utilizado para que o middleware notifique o servidor บฑฑ
ฑฑบ          ณe operadores da ocorrencia de uma nova chamada receptiva.   บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ Ringing(ExpC1,ExpN2, ExpC3, ExpC4, ExpC5, ExpC6, ExpN7)    ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Ramal conectado no Middleware.                     ณฑฑ
ฑฑณ          ณ ExpN2 = Identificado do Middleware.                        ณฑฑ
ฑฑณ          ณ ExpC3 = Identificacao da chamada no PABX.                  ณฑฑ
ฑฑณ          ณ ExpC4 = Numero do chamador.                                ณฑฑ
ฑฑณ          ณ ExpC5 = Numero chamado.                                    ณฑฑ
ฑฑณ          ณ ExpC6 = Dados associados                                   ณฑฑ
ฑฑณ          ณ ExpN7 = Tipo de chamada                                    ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SmartCTI                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณServiceInitiatedบAutor ณMichel W. Moscaบ Data ณ  30/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEvento utilizado para que o middleware notifique o servidor บฑฑ
ฑฑบ          ณe operadores de que o ramal esta fora do gancho.            บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ ServiceInitiated(ExpC1,ExpN2, ExpC3, ExpC4, ExpC5)    	  ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Ramal conectado no Middleware.                     ณฑฑ
ฑฑณ          ณ ExpN2 = Identificado do Middleware.                        ณฑฑ
ฑฑณ          ณ ExpC3 = Identificacao da chamada no PABX.                  ณฑฑ
ฑฑณ          ณ ExpC4 = Numero do chamador.                                ณฑฑ
ฑฑณ          ณ ExpC5 = Numero chamado.                                    ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SmartCTI                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณConnectionClearedบAutorณMichel W. Moscaบ Data ณ  30/10/06   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEvento utilizado para que o middleware notifique o servidor บฑฑ
ฑฑบ          ณe operadores do fim de uma chamada.                         บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ ConnectionCleared(ExpC1,ExpN2, ExpC3, ExpC4, ExpC5)    	  ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Ramal conectado no Middleware.                     ณฑฑ
ฑฑณ          ณ ExpN2 = Identificado do Middleware.                        ณฑฑ
ฑฑณ          ณ ExpC3 = Identificacao da chamada no PABX.                  ณฑฑ
ฑฑณ          ณ ExpC4 = Numero do chamador.                                ณฑฑ
ฑฑณ          ณ ExpC5 = Numero chamado.                                    ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SmartCTI                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAnswered  บAutor  ณMichel W. Mosca     บ Data ณ  30/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEvento utilizado para que o middleware notifique o servidor บฑฑ
ฑฑบ          ณe operadores do atendimento de uma chamada.                 บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ Answered(ExpC1,ExpN2, ExpC3, ExpC4, ExpC5) 			   	  ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Ramal conectado no Middleware.                     ณฑฑ
ฑฑณ          ณ ExpN2 = Identificado do Middleware.                        ณฑฑ
ฑฑณ          ณ ExpC3 = Identificacao da chamada no PABX.                  ณฑฑ
ฑฑณ          ณ ExpC4 = Numero do chamador.                                ณฑฑ
ฑฑณ          ณ ExpC5 = Numero chamado.                                    ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SmartCTI                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOriginatedบAutor  ณMichel W. Mosca     บ Data ณ  30/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEvento utilizado para que o middleware notifique o servidor บฑฑ
ฑฑบ          ณe operadores do inicio da discagem de uma chamada ativa.    บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ Originated(ExpC1,ExpN2, ExpC3, ExpC4, ExpC5) 			  ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Ramal conectado no Middleware.                     ณฑฑ
ฑฑณ          ณ ExpN2 = Identificado do Middleware.                        ณฑฑ
ฑฑณ          ณ ExpC3 = Identificacao da chamada no PABX.                  ณฑฑ
ฑฑณ          ณ ExpC4 = Numero do chamador.                                ณฑฑ
ฑฑณ          ณ ExpC5 = Numero chamado.                                    ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SmartCTI                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHeld      บAutor  ณMichel W. Mosca     บ Data ณ  30/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEvento utilizado para que o middleware notifique o servidor บฑฑ
ฑฑบ          ณe operadores do inicio da discagem de uma chamada ativa.    บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ Held(ExpC1,ExpN2, ExpC3, ExpC4, ExpC5) 			  		  ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Ramal conectado no Middleware.                     ณฑฑ
ฑฑณ          ณ ExpN2 = Identificado do Middleware.                        ณฑฑ
ฑฑณ          ณ ExpC3 = Identificacao da chamada no PABX.                  ณฑฑ
ฑฑณ          ณ ExpC4 = Numero do chamador.                                ณฑฑ
ฑฑณ          ณ ExpC5 = Numero chamado.                                    ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SmartCTI                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณCallFailureบAutor  ณMichel W. Mosca     บ Data ณ  30/10/06   บฑฑ
ฑฑฬอออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEvento utilizado para que o middleware notifique o servidor บฑฑ
ฑฑบ          ณe operadores do inicio da discagem de uma chamada ativa.    บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ CallFailure(ExpC1,ExpN2, ExpC3, ExpC4, ExpC5, ExpN6)		  ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Ramal conectado no Middleware.                     ณฑฑ
ฑฑณ          ณ ExpN2 = Identificado do Middleware.                        ณฑฑ
ฑฑณ          ณ ExpC3 = Identificacao da chamada no PABX.                  ณฑฑ
ฑฑณ          ณ ExpC4 = Numero do chamador.                                ณฑฑ
ฑฑณ          ณ ExpC5 = Numero chamado.                                    ณฑฑ
ฑฑณ          ณ ExpC6 = Identificador da causa da falha.                   ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SmartCTI                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetrieve  บAutor  ณMichel W. Mosca     บ Data ณ  30/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEvento utilizado para que o middleware notifique o servidor บฑฑ
ฑฑบ          ณe operadores de que a discagem de uma chamada finalizou em  บฑฑ
ฑฑบ          ณdestino ocupado.                                            บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ Busy(ExpC1,ExpN2, ExpC3, ExpC4, ExpC5) 					  ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Ramal conectado no Middleware.                     ณฑฑ
ฑฑณ          ณ ExpN2 = Identificado do Middleware.                        ณฑฑ
ฑฑณ          ณ ExpC3 = Identificacao da chamada no PABX.                  ณฑฑ
ฑฑณ          ณ ExpC4 = Numero do chamador.                                ณฑฑ
ฑฑณ          ณ ExpC5 = Numero chamado.                                    ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SmartCTI                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLoggedOn  บAutor  ณMichel W. Mosca     บ Data ณ  30/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEvento utilizado para que o middleware notifique o servidor บฑฑ
ฑฑบ          ณe operadores que o usuario esta conectado no DAC.           บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ LoggedOn(ExpC1,ExpN2, ExpC3, ExpC4)		 				  ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Ramal conectado no Middleware.                     ณฑฑ
ฑฑณ          ณ ExpN2 = Identificado do Middleware.                        ณฑฑ
ฑฑณ          ณ ExpC3 = Identificacao do agente no DAC.                    ณฑฑ
ฑฑณ          ณ ExpC4 = Identificacao do grupo DAC.                        ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SmartCTI                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLoggedOff บAutor  ณMichel W. Mosca     บ Data ณ  30/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEvento utilizado para que o middleware notifique o servidor บฑฑ
ฑฑบ          ณe operadores que o usuario esta desconectado no DAC.        บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ LoggedOff(ExpC1,ExpN2, ExpC3, ExpC4)		 				  ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Ramal conectado no Middleware.                     ณฑฑ
ฑฑณ          ณ ExpN2 = Identificado do Middleware.                        ณฑฑ
ฑฑณ          ณ ExpC3 = Identificacao do agente no DAC.                    ณฑฑ
ฑฑณ          ณ ExpC4 = Identificacao do grupo DAC.                        ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SmartCTI                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReady     บAutor  ณMichel W. Mosca     บ Data ณ  30/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEvento utilizado para que o middleware notifique o servidor บฑฑ
ฑฑบ          ณe operadores que o usuario esta disponivel para receber     บฑฑ
ฑฑบ          ณchamadas transferidas pelo DAC.                             บฑฑ 
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ Ready(ExpC1,ExpN2, ExpC3, ExpC4)	   		 				  ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Ramal conectado no Middleware.                     ณฑฑ
ฑฑณ          ณ ExpN2 = Identificado do Middleware.                        ณฑฑ
ฑฑณ          ณ ExpC3 = Identificacao do agente no DAC.                    ณฑฑ
ฑฑณ          ณ ExpC4 = Identificacao do grupo DAC.                        ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SmartCTI                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNotReady  บAutor  ณMichel W. Mosca     บ Data ณ  30/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEvento utilizado para que o middleware notifique o servidor บฑฑ
ฑฑบ          ณe operadores que o usuario esta indisponivel para receber   บฑฑ
ฑฑบ          ณchamadas transferidas pelo DAC.                             บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ NotReady(ExpC1,ExpN2, ExpC3, ExpC4)		 				  ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Ramal conectado no Middleware.                     ณฑฑ
ฑฑณ          ณ ExpN2 = Identificado do Middleware.                        ณฑฑ
ฑฑณ          ณ ExpC3 = Identificacao do agente no DAC.                    ณฑฑ
ฑฑณ          ณ ExpC4 = Identificacao do grupo DAC.                        ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SmartCTI                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |WriteLog        บAutorณMichel W. Mosca บ Data ณ  10/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEscreve em arquivo de log.                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function WriteLog(cText)
Local cFileLog := ""
Local nAux

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//|Grava o Log se estiver habilitado. |            
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If GetMv("MV_TKCTILG",.F.)
	cFileLog  := ALLTRIM(GetPvProfString(GetEnvServer(),"startpath","",GetADV97()))

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//|Monta o nome do arquivo de log que sera grava no StartPath (SIGAADV)          |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
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