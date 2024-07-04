#INCLUDE "PROTHEUS.CH"      
#INCLUDE "TMKARECEPTIVEEVT.CH"

#DEFINE RECEPTIVO  1
#DEFINE ATIVO      2    

#DEFINE USE_MODEM  		"1"
#DEFINE USE_CTI    		"2"
#DEFINE USE_MANUAL		"3"    
#DEFINE USE_SMARTCTI	"4"
      
//Vari�veis estaticas para que sejam utilizadas na abertura da tela de atendimento do receptivo e nao comprometa
//o recebimento da sequencia de eventos vindas da API. A abertura da tela se dara por um timer que fica verificando
//se deve ser aberta a tela.
Static oTmrRing 			//Timer utilizado para abrir a tela e n�o travar a sequencia de eventos
Static aCallDetail := {}   	//Array contendo as chamadas recebidas no ramal do operador
							//1 - Array com dados da chamada para abertura do ScreenPop                
							//2 - Tipo de chamada para abertura do ScreenPop
Static oTimerContainer 		//Dialog invisivel que servira como Container para o timer de abertura de ScreenPop							


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TMKAReceptiveEvt   �Autor�Michel W. Mosca�Data � 24/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Classe que extende a interface AgentEvents, por onde serao  ���
���          �recebidos os eventos no ramal do operador no modo receptivo.���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Class TMKAReceptiveEvt FROM AgentEvents
                    
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
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New() Class TMKAReceptiveEvt

                           
//Form escondido
DEFINE MSDIALOG oTimerContainer FROM 0,0 TO 180,200 PIXEL TITLE "Hide timer form" 
DEFINE TIMER oTmrRing INTERVAL 100 ACTION ( OpenWindow() ) OF oTimerContainer      
//oTmrRing:lLiveAny := .T.
//oTmrRing:Activate()


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
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Connected() Class TMKAReceptiveEvt 
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
Method ServiceInitiated(callID, ANI, DNIS) Class TMKAReceptiveEvt

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
Method Originated(callID, ANI, DNIS) Class TMKAReceptiveEvt

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
Method CallFailure(callID, ANI, DNIS, Cause) Class TMKAReceptiveEvt
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
Method Retrieve(callID, ANI, DNIS) Class TMKAReceptiveEvt
SMSetCallInHold(.F.)

SMSetInCall(.T.,callID)
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
Method ConnectionCleared(callID, ANI, DNIS) Class TMKAReceptiveEvt
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
Method Ringing(callID, ANI, DNIS, associatedData, callType) Class TMKAReceptiveEvt
Local cAux		//Auxiliar no tratamento do associatedData
Local cTipo		//Armazena o tipo de dado passado em associatedData
Local cValue	//Armazena o dado passado em associatedData
Local aBuffer	//Array com dados da chamada para abertura do ScreenPop                
Local nCall		//Tipo de chamada para abertura do ScreenPop
Local nItem     //Variavel utilizada em Loops
Local lFind     //Auxilia na busca por posicoes no array


//conout("Processando Ringing. Operador:" + ::cCodUsrProtheus)                    
cAux := AllTrim(associatedData)
If cAux <> "" 
	cTipo 	:= AllTrim(Str(Val(SubStr(cAux, 1, At("|", cAux)-1))))
	
	cValue 	:= SubStr(cAux, At("|", cAux)+1, Len(cAux)) 
Else
	cTipo	:= "3"	
	cValue	:= ANI
EndIf

aBuffer := {::cCodUsrProtheus, "05", "00", cTipo, cValue, ANI, DNIS}
//conout("Recebendo chamada no ramal. ANI:" + AllTrim(ANI) + ", DNIS:" + AllTrim(DNIS) + ", associatedData:" + cAux)
If callType $ "1|3" // Caso seja chamada receptiva/transferida pelo discador, abre a tela de atendimento
	If callType = "3"
		nCall := ATIVO
	Else
		nCall := RECEPTIVO 	
	EndIf	                
	
	lFind := .F.
	For nItem := 1 To Len(aCallDetail)		
		If(ValType(aCallDetail[nItem]) == "U")
			aCallDetail[nItem] := {aBuffer, nCall}
			lFind := .T.
			Exit		
		EndIf	
	Next    
	If(!lFind)
		AAdd(aCallDetail, {aBuffer, nCall})
	EndIf
	oTmrRing:lLiveAny := .T.
	oTmrRing:Activate()		
Endif			

Return Nil         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �OpenWindow�Autor  �Michel W. Mosca     � Data �  30/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Abre a janela do receptivo, evitando que trave o processa-  ���
���          �-mento de eventos da API.                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � OpenWindow()                    						      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SmartCTI                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/       
Function OpenWindow()   
Local nItem 			//Variavel utilizada em Loops                           
Local aData := {}		//Array com dados da chamada
Local lFind := .T.		//Flag indicando que ha ScreenPop que nao foram abertos ainda

If(Len(aCallDetail) > 0)
	Do While(lFind)	
		lFind := .F.	
		For nItem := 1 To Len(aCallDetail) 		                             	
			If(ValType(aCallDetail[nItem]) <> "U")
				aData := aCallDetail[nItem]
				aCallDetail[nItem] := NIL
				lFind := .T. 				
				Exit
			EndIf			
		Next
		If(lFind) 	
			SGShowProfile(aData[1], 13,aData[2], USE_SMARTCTI)
		EndIf
	EndDo	
EndIf
oTmrRing:DeActivate()

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
Method Answered(callID, ANI, DNIS) Class TMKAReceptiveEvt
	//Local lSMGetInfoChamDigitro 		:= ExistBlock("SMGetInfoChamDigitro")	// Ponto de Entrada para gravar o Grupo DAC que recebeu a chamada
	Local oAgtSmartCTI 		:= getObjCTI()
	Local cDadosDaChamada	:= ""
	Local aDadosChamada		:= {}	/*Extrutura do Array aDadosChamada
									aDadosChamada[1] = CMD | aDadosChamada[2] = INFOCHAMATIV| aDadosChamada[3] = RC (0 = sucesso, 11 = nao existe chamada ativa)
									aDadosChamada[4] = DEVICE | aDadosChamada[5] = CALL_ID| aDadosChamada[6] = DISPOSITIVOS_ASSOCIADOS
									aDadosChamada[7] = NUMERO_ORIGINADOR| aDadosChamada[8] = NUMERO_DISCADO_ORIGINAL| aDadosChamada[9] = ULTIMO_REDIRECIONAMENTO
									aDadosChamada[10] = TRONCOS_ASSOCIADOS | aDadosChamada[11] = CATEGORIA | aDadosChamada[12] = DADOS
									*/
	
	SMSetInCall(.T.,callID)
    
	If (ValType(oAgtSmartCTI) == "O")
		cDadosDaChamada := oAgtSmartCTI:GetInfoChamAtiv(oAgtSmartCTI:cDevice)
		aDadosChamada	:= strToArray(cDadosDaChamada,"#")
		
		cCurrentACDGroup :=	""
		
		//Se resposta = Sucesso e Ultimo Redirecionamento <> ""
		if Len(aDadosChamada) >= 3 .AND. Val(aDadosChamada[3]) == 0 .AND. Len(aDadosChamada) >= 9 .AND. aDadosChamada[9] <> ""
			cCurrentACDGroup := aDadosChamada[9]
		EndIf                 
	EndIf
	/*If lSMGetInfoChamDigitro
		ExecBlock("SMGetInfoChamDigitro",.F.,.F.,{DNIS} )
	EndIf*/
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
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Method Held(callID, ANI, DNIS) Class TMKAReceptiveEvt
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
Method LoggedOn(agentID, groupID) Class TMKAReceptiveEvt
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
Method LoggedOff(agentID, groupID) Class TMKAReceptiveEvt
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
Method Ready(agentID, groupID) Class TMKAReceptiveEvt
	//conout(DtoC(Date()) + " " + TIME() + "Ready recebido. AgentID:" + agentID + ", GroupID:" + groupID + "")
	TkUpdReady()
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
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Method NotReady(agentID, groupID) Class TMKAReceptiveEvt
	//conout(DtoC(Date()) + " " + TIME() + "NotReady recebido. AgentID:" + agentID + ", GroupID:" + groupID + "")
	TkUpdNotReady()
Return Nil         
