#INCLUDE "PROTHEUS.CH"      
#INCLUDE "TMKAACTIVEEVT.CH"

#DEFINE RECEPTIVO  1
#DEFINE ATIVO      2    

#DEFINE USE_MODEM  		"1"
#DEFINE USE_CTI    		"2"
#DEFINE USE_MANUAL		"3"    
#DEFINE USE_SMARTCTI	"4"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TMKAActiveEvt �Autor�Michel W. Mosca   � Data �  24/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Classe que extende a interface AgentEvents, por onde serao  ���
���          �recebidos os eventos no ramal do operador no modo ativo.    ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Class TMKAActiveEvt FROM AgentEvents  
                    
Method New()
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

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New          �Autor  �Michel W. Mosca  � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New() Class TMKAActiveEvt
Return Self  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Connected    �Autor  �Michel W. Mosca  � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento recebido quando a API completa o processo de conexao.���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Connected() Class TMKAActiveEvt 
	//conout(DtoC(Date()) + " " + TIME() + "Connected recebido")

Return(.T.)    


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ServiceInitiated�Autor�Michel W. Mosca � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento utilizado para que o middleware notifique o servidor ���
���          �e operadores de que o ramal esta fora do gancho.            ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ServiceInitiated(ExpC1, ExpC2, ExpC3)				      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Identificacao da chamada no PABX.                  ���
���          � ExpC2 = Numero do chamador.                                ���
���          � ExpC3 = Numero chamado.                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                               
Method ServiceInitiated(callID, ANI, DNIS) Class TMKAActiveEvt
SMSetInCall(.T.,callID)
Return Nil         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Originated�Autor  �Michel W. Mosca     � Data �  30/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento utilizado para que o middleware notifique o servidor ���
���          �e operadores do inicio da discagem de uma chamada ativa.    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Originated(ExpC1, ExpC2, ExpC3)						      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Identificacao da chamada no PABX.                  ���
���          � ExpC2 = Numero do chamador.                                ���
���          � ExpC3 = Numero chamado.                                    ���
�������������������������������������������������������������������������͹��
���Uso       � SmartCTI                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                              
Method Originated(callID, ANI, DNIS) Class TMKAActiveEvt

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CallFailure�Autor �Michel W. Mosca     � Data �  30/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento utilizado para que o middleware notifique o servidor ���
���          �e operadores de falha ao iniciar discagem.                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CallFailure(ExpC1, ExpC2, ExpC3)						      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Identificacao da chamada no PABX.                  ���
���          � ExpC2 = Numero do chamador.                                ���
���          � ExpC3 = Numero chamado.                                    ���
�������������������������������������������������������������������������͹��
���Uso       � SmartCTI                                                   ���
�������������������������������������������������������������������������͹��
���Alteracoes� Data    Versao Descricao                                   ���
�������������������������������������������������������������������������Ĺ��
���Conrado Q �23/08/07�8.11  � -BOPS 131234: Altera��o das mensagens      ���
���          �        �      � informativas.                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/        
Method CallFailure(callID, ANI, DNIS, Cause) Class TMKAActiveEvt
Local cDescCause := ""	// Descri��o da causa
Local cDescResol := ""	// Descri��o da resolu��o

If SMGetShowUsrMsg()                            
	Do Case     
		Case Cause == 2
			cDescCause	:= STR0003	// "N�o foi poss�vel completar a chamada pois o n�mero de telefone � inv�lido."
			cDescResol	:= STR0004	// "Informar um n�mero v�lido."
		Case Cause == 8
			cDescCause	:= STR0005	// "N�o foi poss�vel realizar a chamada. Todas as linhas est�o ocupadas."
			cDescResol	:= STR0006	// "Verifique se h� tom de discagem ou tente novamente mais tarde."		
		Case Cause == 10
			cDescCause	:= STR0007	// "N�o foi poss�vel completar a chamada pois o n�mero de telefone est� ocupado."
			cDescResol	:= STR0008	// "Tente novamente mais tarde."
		Case Cause == 11
			cDescCause	:= STR0009	// "N�o foi poss�vel completar a chamada pois o n�mero de telefone n�o atende."
			cDescResol	:= STR0010	// "Tente novamente mais tarde."
		Case Cause == 20
			cDescCause	:= STR0011	// "N�o foi poss�vel colocar a chamada em espera, pois todos as posi��es de estacionamento est�o ocupados."
			cDescResol	:= STR0012	// "Tente novamente."
		Case Cause == 25
			cDescCause	:= STR0013	// "N�o foi poss�vel completar a chamada pois a liga��o foi atendida por um correio de voz."
			cDescResol	:= STR0014	// "Tente novamente mais tarde."
		Otherwise
			cDescCause	:= STR0015	// "O PABX retornou uma informa��o n�o esperada."
			cDescResol	:= STR0016	// "Tente novamente." + Chr(13)+Chr(10) + "Se persistir o problema contate o administrador do sistema e relate a situa��o."
	End Case

	MsgInfo(STR0001 + CRLF + cDescCause + CRLF + CRLF + STR0002 + cDescResol, "Protheus")	// "Causa:" "Resolu��o:"
	SMSetShowUsrMsg(.F.)
EndIf			
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Retrieve  �Autor  �Michel W. Mosca     � Data �  30/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento utilizado para que o middleware notifique o servidor ���
���          �e operadores de que uma chamada saiu da espera e retornou ao���
���          �ramal.                                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Retrieve(ExpC1, ExpC2, ExpC3)					      	  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Identificacao da chamada no PABX.                  ���
���          � ExpC2 = Numero do chamador.                                ���
���          � ExpC3 = Numero chamado.                                    ���
�������������������������������������������������������������������������͹��
���Uso       � SmartCTI                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Method Retrieve(callID, ANI, DNIS) Class TMKAActiveEvt

SMSetInCall(.T.,callID)
SMSetCallInHold(.F.)
Return Nil         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ConnectionCleared�Autor�Michel W. Mosca� Data �  30/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento utilizado para que o middleware notifique o servidor ���
���          �e operadores do fim de uma chamada.                         ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ConnectionCleared(ExpC1, ExpC2, ExpC3)				      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Identificacao da chamada no PABX.                  ���
���          � ExpC2 = Numero do chamador.                                ���
���          � ExpC3 = Numero chamado.                                    ���
�������������������������������������������������������������������������͹��
���Uso       � SmartCTI                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                           
Method ConnectionCleared(callID, ANI, DNIS) Class TMKAActiveEvt
SMSetShowUsrMsg(.F.)	
SMSetCallInHold(.F.)

SMSetInCall(.F.,callID,.T.)

Return Nil         


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ringing   �Autor  �Michel W. Mosca     � Data �  30/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento utilizado para que o middleware notifique o servidor ���
���          �e operadores da ocorrencia de uma nova chamada receptiva.   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ringing(ExpC1, ExpC2, ExpC3, ExpC4, ExpN5)   			  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Identificacao da chamada no PABX.                  ���
���          � ExpC2 = Numero do chamador.                                ���
���          � ExpC3 = Numero chamado.                                    ���
���          � ExpC4 = Dados associados                                   ���
���          � ExpN5 = Tipo de chamada                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SmartCTI                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Ringing(callID, ANI, DNIS, associatedData, callType) Class TMKAActiveEvt
           
Return Nil         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Answered  �Autor  �Michel W. Mosca     � Data �  30/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento utilizado para que o middleware notifique o servidor ���
���          �e operadores do atendimento de uma chamada.                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Answered(ExpC1, ExpC2, ExpC3) 						      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Identificacao da chamada no PABX.                  ���
���          � ExpC2 = Numero do chamador.                                ���
���          � ExpC3 = Numero chamado.                                    ���
�������������������������������������������������������������������������͹��
���Uso       � SmartCTI                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                              
Method Answered(callID, ANI, DNIS) Class TMKAActiveEvt

SMSetInCall(.T.,callID)

Return Nil         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Held	       �Autor  �Michel W. Mosca  � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento recebido quando uma chamada vai para espera.(Hold)   ���
���          �                                                            ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Held(ExpC1, ExpC2, ExpC3)				      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Identificacao da chamada no PABX.                  ���
���          � ExpC2 = Numero do chamador.                                ���
���          � ExpC3 = Numero chamado.                                    ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Method Held(callID, ANI, DNIS) Class TMKAActiveEvt
SMSetCallInHold(.T.)

SMSetInCall(.F.)
Return Nil         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LoggedOn     �Autor  �Michel W. Mosca  � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento recebido quando o agente muda para Logado no DAC.    ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � LoggedOn(ExpC1, ExpC2)					 				  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Identificacao do agente no DAC.                    ���
���          � ExpC2 = Identificacao do grupo DAC.                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/    
Method LoggedOn(agentID, groupID) Class TMKAActiveEvt
	//conout(DtoC(Date()) + " " + TIME() + "LoggedOn recebido. AgentID:" + agentID + ", GroupID:" + groupID + "")
Return Nil         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LoggedOff    �Autor  �Michel W. Mosca  � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento recebido quando o operador desloga do DAC.           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � LoggedOff(ExpC1, ExpC2)					 				  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Identificacao do agente no DAC.                    ���
���          � ExpC2 = Identificacao do grupo DAC.                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/      
Method LoggedOff(agentID, groupID) Class TMKAActiveEvt
	//conout(DtoC(Date()) + " " + TIME() + "LoggedOff recebido. AgentID:" + agentID + ", GroupID:" + groupID + "")
Return Nil         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ready	       �Autor  �Michel W. Mosca  � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento recebido quando o agente entra em disponivel no DAC. ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ready(ExpC1, ExpC2)						 				  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Identificacao do agente no DAC.                    ���
���          � ExpC2 = Identificacao do grupo DAC.                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/         
Method Ready(agentID, groupID) Class TMKAActiveEvt
	//conout(DtoC(Date()) + " " + TIME() + "Ready recebido. AgentID:" + agentID + ", GroupID:" + groupID + "")
Return Nil         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NotReady     �Autor  �Michel W. Mosca  � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Evento recebido quando o agente esta indisponivel no DAC.   ���
���          �                                                            ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � NotReady(ExpC1, ExpC2)					 				  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Identificacao do agente no DAC.                    ���
���          � ExpC2 = Identificacao do grupo DAC.                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Method NotReady(agentID, groupID) Class TMKAActiveEvt
	//conout(DtoC(Date()) + " " + TIME() + "NotReady recebido. AgentID:" + agentID + ", GroupID:" + groupID + "")
Return Nil         
