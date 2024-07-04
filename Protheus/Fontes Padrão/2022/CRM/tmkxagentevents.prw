#INCLUDE "PROTHEUS.CH"      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAgentEvents   บAutorณMichel W. Mosca   บ Data ณ  24/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInterface a ser utilizada para receber os eventos da API    บฑฑ
ฑฑบ          ณAgentSmartCTI.                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class AgentEvents                    

Data cCodUsrProtheus		//Codigo do usuario no Protheus

Method ServiceInitiated(callID, ANI, DNIS)							//ramal esta fora do gancho 
Method Originated(callID, ANI, DNIS)								//inicio da discagem de uma chamada ativa
Method CallFailure(callID, ANI, DNIS, Cause)						//falha ao iniciar discagem
Method Retrieve(callID, ANI, DNIS)									//chamada saiu da espera e retornou ao ramal.
Method ConnectionCleared(callID, ANI, DNIS)							//fim de uma chamada
Method Ringing(callID, ANI, DNIS, associatedData, callType)			//ocorrencia de uma nova chamada 
Method Answered(callID, ANI, DNIS)									//atendimento de uma chamada
Method Held(callID, ANI, DNIS)										//chamada foi para espera
Method LoggedOn(agentID, groupID)									//agente muda para Logado no DAC
Method LoggedOff(agentID, groupID)                                  //operador desloga do DAC
Method Ready(agentID, groupID)                  					//agente entra em disponivel no DAC
Method NotReady(agentID, groupID)									//agente esta indisponivel no DAC
Method Connected() 													//Evento recebido quando a API completa o processo de conexao.

EndClass