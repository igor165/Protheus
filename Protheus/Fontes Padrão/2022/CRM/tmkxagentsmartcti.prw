#INCLUDE "PROTHEUS.CH"       
#INCLUDE "SMARTCTI.CH"
#INCLUDE "FILEIO.CH" 
#INCLUDE "TMKXAGENTSMARTCTI.CH"

Static aAgentSmartCTI := {} 	//Array com todas as instancias abertas da classe AgentSmartCTI da mesma thread
								//de Protheus Remote.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGENTSMARTCTI�Autor  �Michel W. Mosca  � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Classe utilizado pelo operador para manipular um telefone   ���
���          �atraves do protocolo SmartCTI.                              ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Class AgentSmartCTI

//Propriedades  
Data cCMDWSDLSmartCTIWS		//URL Location do WebService de Comandos do Middleware
Data cEVTWSDLSmartCTIWS		//URL Location do WebService de Eventos do Protheus
Data cAgentID				//ID do agente que est� conectado pela API
Data iLinkID 				//ID do middleware utilizado pela API
Data cDevice				//Device que foi conectado pela API
Data cUserID				//ID do usuario no Protheus
Data oAgentEvents     		//Instancia da classe de eventos fornecido pelo chamador
Data oSmartCTIWSCommand 	//Instancia do WebService de comando do Middleware
Data oRpcCallBack  			//Instancia da classe de conexao RPC com o Servidor SmartCTIServer
Data lShowUserMsg       	//Flag indicativa para exibir mensagens da API na tela do usuario
Data lSaveLog				//Flag indicativa se deve gravar log  
Data iPosArray                                                    
Data cCodUsrProtheus		//Codigo do usuario no Protheus
Data Bound					//Tipo de Ligacao - 1=Receptivo;2=Ativo;3=Ambos               
Data cAgentPass				//Senha AgentID no Equipamento
Data lAgentPw				//Determina se utiliza autentica��o por usuario e senha	 
Data cRota					//Rota para discagem		


//Metodos
Method New() Constructor   
Method WriteLog(cText)						//Escreve em arquivo de log da API.
Method EnableUserMsg(lYesNo)                //Metodo responsavel por definir se mensagens da API serao exibidas na tela do usuario.
Method Connect(cDevice, cUser)             	//Conecta no servidor RPC e inicializacao do WebService de comando. 
Method Close()                              //Encerramento das conexoes com servidor RPC e WebService de comando.
Method AddEventListener(oAgentEvents)       //Adicionar a classe de eventos do aplicativo chamador. 
Method MakeCall(cTelephoneNumber)           //Iniciar chamadas na central telefonica. 
Method ConnectionClear(cCallId)             //Encerrar uma chamada atraves do CallID da chamada.
Method Answer()                             //Atender uma chamada que esteja tocando no ramal.
Method Logon(cAgentID, cGroupID)            //Alterar o estado do agente para logon
Method Logoff(cAgentID, cGroupID)           //Alterar o estado do agente para logoff
Method Ready(cAgentID, cGroupID)            //Alterar o estado do agente para disponivel
Method NotReady(cAgentID, cGroupID)        	//Alterar o estado do agente para em pausa.
Method OneStepCallTransfer(cDeviceTo)       //Tranferir uma chamada ativa para outro ramal.
Method Transfer()                           //Tranferir uma chamada em espera para o ramal em que ocorre a chamada ativa.
Method Conference()                         //Iniciar uma conferencia. Deve haver uma chamada ativa e uma chamada em espera. 
Method Consultation(cDeviceTo)             	//Realizar uma consulta a um ramal  durante uma chamada. 
Method Hold()                               //Colocar uma chamada ativa em espera
Method Retrieve()                          	//Retornar uma chamada que esteja em espera no ramal.
Method Alternate()                          //Alternar entre uma chamada ativa e uma chamada em espera.
Method Redirect(cDeviceTo)                  //Transferir todas as chamadas que venham a tocar no ramal para outro. 
Method StartRec()                          	//Comando de inicio de gravacao da chamada no ramal.
Method StopRec()                            //Comando de fim da gravacao da chamada no ramal.
Method SystemStatus()						//Enviar o comando solicitando o estado do link com o Middleware.
Method AgentState(cDevice, aResp)			//Busca o Estado do Agente no Grupo DAC.
Method GetInfoChamAtiv(cDevice)				//Busca informa��es da chamada ativa: Dispositivo, ID_CHAMADA, Dispositivos_Associados,
											//Numero_Originador, Numero_Discado_Original, Ultimo_Redirecionamento, Troncos_Associados, Categoria e Dados
Method DescError(iRC)                       //Metodo que descreve o erro para ser exibido para o usuario.

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
Method New(cDevice, iLinkID, cUserId, cAgentPass) Class AgentSmartCTI 
Local cRpcServer	:= SuperGetMv("MV_TMKSERV") 	// Endereco IP do servidor de eventos. 
Local cRpcPort  	:= SuperGetMv("MV_TMKPORT")		// Porta do servidor
Local cRpcEnv   	:= SuperGetMV("MV_TMKENVN",,"ENVSMARTCTI")        		// Ambiente para conex�o. N�o eh utilizado ENVDBFBRACTI
Local cAgentID      := ""

Default cDevice 	:= "0"
Default iLinkID 	:= 0                
Default cUserId 	:= __cUserId                                              
Default cAgentPass	:= ""                                                     

DbSelectArea("SU7")
DbSetOrder(4)
If DbSeek(xFilial("SU7") + cUserId)
	::cAgentID := Trim(SU7->U7_AGENTID)
EndIf

::Bound := "3"       
                    
//Codigo do Usuario no Protheus
::cCodUsrProtheus := cUserId               

//���������������������������Ŀ
//|Carrega o Ramal e LinkID   |      
//�����������������������������
If cDevice = "0" .AND. iLinkID = 0
	//������������������������������������������������������������������������������������������Ŀ
	//|Solicita confirmacao dos dados pelo usuario quando as informacoes nao sao repassadas a API |
	//��������������������������������������������������������������������������������������������
	SMGetInitParams(::cCodUsrProtheus,@cAgentID,@cAgentPass)
	::cAgentPass:= cAgentPass
	::cAgentID	:= cAgentID
	::cDevice	:= GetPvProfString("SmartCTI", "Device", "0", GetClientDir()+"SmartCTI.ini")
	::iLinkID	:= Val(GetPvProfString("SmartCTI", "LinkID", "0", GetClientDir()+"SmartCTI.ini"))
Else  
	//�����������������������������������������������Ŀ
	//|Dados passados para API na criacao do objeto.  |
	//�������������������������������������������������	
	::cDevice 		:= cDevice  
	::iLinkID		:= iLinkID	      
	::cAgentPass	:= cAgentPass		
EndIf  

::cEVTWSDLSmartCTIWS	:= SuperGetMv("MV_TKCTIEV",.F.)   //URL_ADDRESS do WEBService de Eventos
::lSaveLog				:= SuperGetMv("MV_TKCTILG",.F.)   //Verifica se deve gravar ou nao um log das operacoes com a SIGACTI

//�������������������������Ŀ
//|Gravacao de dados no Log |
//���������������������������
::WriteLog(STR0001 + ", [Device=" + ::cDevice + "], [LinkID=" + AllTrim(Str(::iLinkID)) + "]") //"Iniciando AgentSmartCTIAPI."
::WriteLog(STR0002 + ", [Server=" + cRpcServer + "], [Port=" + cRpcPort + "], [EVT_URLLOCATION=" + ::cEVTWSDLSmartCTIWS + "]") //"Dados do SmartCTIServer:

//�������������������������Ŀ
//|Inicializa conexoes		|
//���������������������������
::oRpcCallBack := RPCCallBackClient():New()
::oRpcCallBack:Open(cRpcServer, cRpcPort, cRpcEnv) 
::lShowUserMsg	:= .T.                 

::lAgentPw	:= SuperGetMv("MV_TMKAGPW",.F.,.F.)	//Determina se Utilizara autentica��o com senha do equipamento no login.

//MV_TMKROTA define se enviar� rota no makecall                         
If SuperGetMV("MV_TMKROTA",.F.,.F.)
	::cRota := Trim(TkPosto(TkOperador(),"U0_EXTERNA")) 
Else
	::cRota := ""
EndIf
Return Self 
 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SMGetInitParams�Autor�Michel W. Mosca  � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Apresenta uma tela solicitando Ramal e o middleware que sera���
���          �utilizado pela Estacao.                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SMGetInitParams(cCodUsrProtheus,cAgentID,cAgentPass) 
Local oDlgRamal    								//Handle de tela
Local cDevice := "000000" 						//Armazena o device
Local iLinkID									//Armazena o LinkID
Local aCbx := {}								//Armazena o nome de Middleware para exibicao no combo
Local aLinkID := {}  							//Armazena o LinkID para comparar na saida da tela
Local cCbx := ""								//Armaznea o nome do item selecionado no combo
Local nSelected									//Armaznea o ID selecionado no combo 
Local lAgentId	:= SuperGetMv("MV_TMKAGID",.F.,.T.)	//Determina se Poder� alterar o AgentID
Local lAgentPw	:= SuperGetMv("MV_TMKAGPW",.F.,.F.)	//Determina se Digitar� senha do equipamento no login.
Local cLogin	:= Space(TamSX3("U7_AGENTID")[1])
Local cPass		:= Space(TamSX3("U7_AGENTPW")[1])                     
Local oGetLogin
Local oGetSenha
Local oChkSenha                                         
Local lSalvaSen := .F.
Local nLin1		:= 5
Local nLin2		:= 13  
Local nAjusAlt	:= 0 							//Ajuste de Altura

Default cCodUsrProtheus := ""

cDevice := GetPvProfString("SmartCTI", "Device", "0", GetClientDir()+"SmartCTI.ini") 
cDevice := IIf(cDevice == "0", "000000", cDevice)
iLinkID := GetPvProfString("SmartCTI", "LinkID", "1", GetClientDir()+"SmartCTI.ini")

                             
//������������������������������Ŀ
//|Carrega a lista de Middlewares|
//��������������������������������
DbSelectArea("SK4")                                                
DbSetOrder(2)
DbSeek(xFilial("SK4"))
While (!EOF()) .AND. xFilial("SK4") == SK4->K4_FILIAL
	//�����������������������������������Ŀ
	//|Inibe a selecao de Links inativos. |              
	//�������������������������������������	
	If AllTrim(K4_ENABLE) == "1"  
		AAdd( aCbx, K4_DESC )
		AAdd( aLinkID, Val(K4_LINKID) )
	EndIf
	DbSkip()
End                    

DbSelectarea("SU7")
DbSetorder(4)
If DbSeek(xFilial("SU7") + cCodUsrProtheus)
	cLogin := SU7->U7_AGENTID
	If lAgentPw 
		cPass := IIf(Trim(SU7->U7_AGENTPW)<>"",Encript(SU7->U7_AGENTPW,1),SU7->U7_AGENTPW)
	EndIf
EndIf

lSalvaSen := (lAgentPw .AND. Trim(SU7->U7_AGENTPW)<>"")

//Ajuste de altura na dialog
If !lAgentId
	nAjusAlt += 50
EndIf
If !lAgentPw
	nAjusAlt += 80
EndIf

//�����������������������������������Ŀ
//|Pega o ramal e o LinkID da estacao |
//�������������������������������������
DEFINE MSDIALOG oDlgRamal FROM 0,0 TO (280-nAjusAlt),200 PIXEL TITLE STR0152 //"Dados da esta��o"

	If lAgentId	
		@ nLin1,10 SAY STR0153 SIZE 100,10  OF oDlgRamal PIXEL //"Informe o Login:"
		@ nLin2,10 MSGET oGetLogin VAR cLogin PIXEL SIZE 40,10 PICTURE "@!" OF oDlgRamal 
		
		nLin1 += 25
		nLin2 += 25                                                       
	EndIf
	           
	If lAgentPw
		@ nLin1,10 SAY STR0154 SIZE 100,10  OF oDlgRamal PIXEL //"Informe a Senha:"
		@ nLin2,10 MSGET oGetSenha VAR cPass PASSWORD PIXEL SIZE 40,10 PICTURE "@!" OF oDlgRamal 

		nLin1 += 25
		nLin2 += 25                                                                
		
		@ nLin1,10 CHECKBOX oChkSenha VAR lSalvaSen SIZE 100,10 PIXEL  OF oDlgRamal PROMPT STR0155 //"Salvar a Senha ?"
		//@ 33,10 CHECKBOX oMala VAR lMala SIZE 130,8 PIXEL OF oDlg PROMPT cLblMala		

		nLin1 += 15
		nLin2 += 15                                                                
		
	EndIf

	@ nLin1,10 SAY STR0003 SIZE 100,10 OF oDlgRamal PIXEL //"Informe o n�mero do ramal:"
	@ nLin2,10 MSGET oGetRamal VAR cDevice PIXEL SIZE 40,10 PICTURE "999999" OF oDlgRamal VALID !Empty(cDevice)

	nLin1 += 25
	nLin2 += 25
		
	@ nLin1,10 SAY STR0151 SIZE 100,10  OF oDlgRamal PIXEL //"Selecione o Centro de Atendimento"
	@ nLin2, 10 MSCOMBOBOX oCbx VAR cCbx ITEMS aCbx SIZE 075, 65 OF oDlgRamal PIXEL ON CHANGE nSelected := oCbx:nAt		 
                       
   	oCbx:nAt := Val(iLinkID)
   	oCbx:Refresh()          
   	
	nLin1 += 25   	
   	
	@ nLin1,30 BUTTON STR0005 SIZE 40,12 OF oDlgRamal PIXEL ACTION oDlgRamal:End();nSelected := oCbx:nAt //"Confirmar"
		
ACTIVATE MSDIALOG oDlgRamal CENTER 

If Found()          
	If lAgentId .AND. SU7->U7_AGENTID <> cLogin
		RecLock("SU7",.F.)
			SU7->U7_AGENTID := cLogin
		MsUnlock()	
	EndIf
	If lSalvaSen  
		RecLock("SU7",.F.)	
			SU7->U7_AGENTPW := Encript(cPass,0)			
		MsUnlock()			   
	EndIf
EndIf

//�������������������������������������������Ŀ
//|Escreve os parametros lidos no arquivo .ini|
//���������������������������������������������
WritePProString("SmartCTI", "Device", cDevice, GetClientDir()+"SmartCTI.ini")
If nSelected > 0 .AND. Len(aLinkID) >= nSelected 
	WritePProString("SmartCTI", "LinkID", AllTrim(Str(aLinkID[nSelected])), GetClientDir()+"SmartCTI.ini")   
EndIf

//Seta Login e Password passados por Refer�ncia
cAgentID	:= Trim(cLogin)
cAgentPass	:= Trim(cPass)
Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | EnableUserMsg()�Autor�Michel W. Mosca � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por definir se mensagens da API serao    ���
���          �exibidas na tela do usuario.                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � EnableUserMsg(ExpL1)                                       ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpL1 = Indica se a API devera exibir mensagens de falha   ���
���          �para o usuario.                                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method EnableUserMsg(lYesNo) Class AgentSmartCTI

::lShowUserMsg := lYesNo

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Connect()    �Autor  �Michel W. Mosca  � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela conex�o com servidor RPC e iniciali-���
���          �zacao do WebService de comando.                             ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������͹��
���Analista  �   Data/Bops   �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Conrado Q.�23/08/07|131234� Altera��o das mensagens informativas.      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Connect() Class AgentSmartCTI                     
Local RC					:= SMARTCTI_SUCCESS    		// Retorno da funcao
Local descConnection		:= STR0140					// Descri��o da conex�o	"N�o informado"

DbSelectArea("SK4")                                                
DbSetOrder(2)
If DbSeek(xFilial("SK4") + AllTrim(Str(::iLinkID))) 	
	If !Empty(SK4->K4_BOUND)
		::Bound := SK4->K4_BOUND
	EndIf	
	::cCMDWSDLSmartCTIWS 	:= AllTrim(K4_CMD_URL)
	descConnection			:= K4_DESC
	::WriteLog(STR0006 + ", [Desc. = " + K4_DESC + "], [CMD_URLLOCATION=" + ::cCMDWSDLSmartCTIWS + "]") //"Dados do Middleware:
	::WriteLog(STR0007) //"Enviando comando de Connect ao Middleware."
	::oSmartCTIWSCommand	:= WSSmartCTIWSCommandService():New(::cCMDWSDLSmartCTIWS)
	If ( ValType(::oRPCCallBack:oRpcServer) == "U" )         
		Help(" ",1,"SMARTOUT")
		Return SMARTCTI_OUTOFSERVICE		
	Else
		::oRPCCallBack:Register(::cDevice + AllTrim(Str(::iLinkID)), "||OnLostConnection('" + ::cDevice + "', '" + ::cCMDWSDLSmartCTIWS + "', '" + ::cAgentID + "')")		
	EndIf	
	::oSmartCTIWSCommand:AgentInService(::cDevice,::cEVTWSDLSmartCTIWS)                      	    
	RC := ::oSmartCTIWSCommand:nReturn    
	If RC != SMARTCTI_SUCCESS	//Caso retorne falha, deixa de receber eventos do Middleware.				
		If RC == NIL	//Caso em que o WebService SmartCTIWSCommand nao foi encontrado
			RC = SMARTCTI_DISCONNECTEDLINK
		EndIf                        		
		::WriteLog(STR0008 + AllTrim(Str(RC)) + ", " + ::DescError(RC))				//"O Middleware retornou o comando de Connect com C�digo de Erro:" # "Descri��o:"
		::oRPCCallBack:UnRegister() 
	EndIf	
	
Else
    ::WriteLog(STR0009)  //"Middleware informado, n�o � valido."
    RC = SMARTCTI_OUTOFSERVICE
EndIf     
                        
If RC != SMARTCTI_SUCCESS	
	If ::lShowUserMsg 
		MsgInfo(::DescError(RC, STR0141 + ::cDevice + CRLF + STR0142 + Alltrim(descConnection) + CRLF + STR0143 + Alltrim(::cCMDWSDLSmartCTIWS),.F.), "AgentSmartCTI API") 	// "Ramal: " "Conex�o: " "URLCommand: "
	EndIf	
EndIf                              

::WriteLog(STR0015 + " -> RC=" + AllTrim(Str(RC)) + ", " + ::DescError(RC)) //"Resposta do comando Connect # Descri��o do Erro: "

Return RC

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Close()      �Autor  �Michel W. Mosca  � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela encerramento das conexoes com servi-���
���          �dor RPC e WebService de comando.                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������͹��
���Analista  �   Data/Bops   �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Conrado Q.�23/08/07|131234� Altera��o das mensagens informativas.      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Close() Class AgentSmartCTI                                                             
Local RC := SMARTCTI_SUCCESS       //Retorno da funcao   
                                                                        
::WriteLog(STR0016) //"Enviando comando de Close para o Middleware."
::oSmartCTIWSCommand:AgentOutOfService(::cDevice)                      
RC := ::oSmartCTIWSCommand:nReturn

If RC == NIL	//Caso em que o WebService SmartCTIWSCommand nao foi encontrado
	RC = SMARTCTI_DISCONNECTEDLINK
EndIf 

::WriteLog(STR0017 + " -> RC=" + AllTrim(Str(RC)) + ",  " + ::DescError(RC)) //"Resposta do comando Close # Descri��o do Erro:
If ( ValType(::oRPCCallBack:oRpcServer) == "O" )         
	::oRPCCallBack:UnRegister()
EndIf

Return RC

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AddEventListener�Autor�Michel W. Mosca � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por adicionar a classe de eventos do     ���
���          �aplicativo chamador.                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � AddEventListener(ExpO1)                                    ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Classe que contem a interface para recepcao dos    ���
���          �eventos da API.                                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AddEventListener(oAgentEvents) Class AgentSmartCTI
Local RC := SMARTCTI_SUCCESS 		//Retorno da funcao
                                                        
::oAgentEvents := oAgentEvents 
::oAgentEvents:cCodUsrProtheus := ::cCodUsrProtheus

//������������������������������������������������������������������������������Ŀ
//|Adiciona a classe no array de instancias para CallBack						 |
//��������������������������������������������������������������������������������
AAdd(aAgentSmartCTI, Self)   
::iPosArray := Len(aAgentSmartCTI)

Return(RC)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MakeCall        �Autor�Michel W. Mosca � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por iniciar chamadas na central telefoni-���
���          �-ca.                                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MakeCall(ExpC1)    		                                  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Numero de telefone a ser discado.                  ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������͹��
���Analista  �   Data/Bops   �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Conrado Q.�23/08/07|131234� Altera��o das mensagens informativas.      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method MakeCall(cTelephoneNumber) Class AgentSmartCTI
Local RC := SMARTCTI_SUCCESS      //Retorno da funcao

::WriteLog(STR0018 + ", [AgentID=" + cValToChar(::cAgentID) + "], [Route=" + cValToChar(::cRota) + "], [Telephone=" + cTelephoneNumber + "]") //"Enviando comando de MakeCall para o Middleware."                    
If ::lAgentPw .OR. cValToChar(::cRota) <> ""
	::oSmartCTIWSCommand:MakeCallPass(::cDevice, cTelephoneNumber, cValToChar(::cAgentID), cValToChar(::cAgentPass), cValToChar(::cRota))                       
	RC := ::oSmartCTIWSCommand:nReturn
Else
	::oSmartCTIWSCommand:MakeCall(::cDevice, cTelephoneNumber)       
	RC := ::oSmartCTIWSCommand:nReturn
EndIf

If RC == NIL	//Caso em que o WebService SmartCTIWSCommand nao foi encontrado
	RC = SMARTCTI_DISCONNECTEDLINK
EndIf   
::WriteLog(STR0019 + " -> RC=" + AllTrim(Str(RC)) + ", " + ::DescError(RC)) //"Resposta do comando MakeCall # Descri��o do Erro: "

Return(RC)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ConnectionClear �Autor�Michel W. Mosca � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por encerrar uma chamada atraves do Call-���
���          �-ID da chamada.                                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ConnectionClear(ExpC1)	                                  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Identificador da chamada a ser finalizada.         ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������͹��
���Analista  �   Data/Bops   �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Conrado Q.�23/08/07|131234� Altera��o das mensagens informativas.      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConnectionClear(cCallId) Class AgentSmartCTI
Local RC := SMARTCTI_SUCCESS     //Retorno da funcao  

::WriteLog(STR0020) //"Enviando comando de ConnectionClear para o Middleware."
::oSmartCTIWSCommand:ConnectionClear(::cDevice, cCallId)                                 
RC := ::oSmartCTIWSCommand:nReturn
If RC == NIL	//Caso em que o WebService SmartCTIWSCommand nao foi encontrado
	RC = SMARTCTI_DISCONNECTEDLINK
EndIf                                             
::WriteLog(STR0021 + " -> RC=" + AllTrim(Str(RC)) + ", " + ::DescError(RC)) //"Resposta do comando ConnectionClear # Descri��o do Erro: "

Return(RC)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Answer          �Autor�Michel W. Mosca � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por atender uma chamada que esteja tocan-���
���          �-do no ramal.                                               ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������͹��
���Analista  �   Data/Bops   �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Conrado Q.�23/08/07|131234� Altera��o das mensagens informativas.      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Answer() Class AgentSmartCTI
Local RC := SMARTCTI_SUCCESS     	//Retorno da funcao 

::WriteLog(STR0022) //"Resposta do comando de Answer para o Middleware."
::oSmartCTIWSCommand:Answer(::cDevice)                      
RC := ::oSmartCTIWSCommand:nReturn
If RC == NIL	//Caso em que o WebService SmartCTIWSCommand nao foi encontrado
	RC = SMARTCTI_DISCONNECTEDLINK
EndIf   
::WriteLog(STR0023 + " -> RC=" + AllTrim(Str(RC)) + ", " + ::DescError(RC)) //"Resposta do comando Answer # Descri��o do Erro: "

Return(RC)               

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Logon           �Autor�Michel W. Mosca � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por alterar o estado do agente para logon���
���          �                                                            ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Logon(ExpC1, ExpC2)  	                                  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Identificador do operador junto ao DAC.(PIN)       ���
���          � ExpC2 = Identificador do grupo DAC a ser conectado.        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������͹��
���Analista  �   Data/Bops   �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Conrado Q.�23/08/07|131234� Altera��o das mensagens informativas.      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Logon(cAgentID, cGroupID) Class AgentSmartCTI
Local RC := SMARTCTI_SUCCESS      //Retorno da funcao

::WriteLog(STR0024 + ", [AgentID=" + cAgentID + "], [GroupID=" + cGroupID + "]") //"Enviando comando de Logon para o Middleware."

If ::lAgentPw
	::oSmartCTIWSCommand:LogonPass(::cDevice, Trim(cAgentID), cGroupID, cValToChar(::cAgentPass))	
	RC := ::oSmartCTIWSCommand:nReturn
Else
	::oSmartCTIWSCommand:Logon(::cDevice, Trim(cAgentID), cGroupID) 	
	RC := ::oSmartCTIWSCommand:nReturn
EndIf
                     
If RC == NIL	//Caso em que o WebService SmartCTIWSCommand nao foi encontrado
	RC = SMARTCTI_DISCONNECTEDLINK
EndIf                   

If RC <> SMARTCTI_SUCCESS 
	If ::lShowUserMsg 
		MsgInfo( ::DescError(RC,STR0141 + ::cDevice + CRLF + STR0144 + cAgentID + CRLF + STR0145 + cGroupID,.F.), "AgentSmartCTI API")	// "Ramal: "  "Agente: " "Grupo DAC: "
	EndIf                                          	
Else	
	::oRPCCallBack:SetCBLostConn("||OnLostConnection('" + ::cDevice + "', '" + ::cCMDWSDLSmartCTIWS + "','" + cAgentID + "','" + cGroupID + "', '"+cValToChar(::cAgentPass)+"')")
EndIf
::WriteLog(STR0027 + " -> RC=" + AllTrim(Str(RC)) + ", " + ::DescError(RC)) //"Resposta do comando Logon # Descri��o do Erro: "

Return(RC)            

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Logoff          �Autor�Michel W. Mosca � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por alterar o estado do agente para      ���
���          �Logoff.                                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Logoff(ExpC1, ExpC2)  	                                  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Identificador do operador junto ao DAC.(PIN)       ���
���          � ExpC2 = Identificador do grupo DAC a ser conectado.        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������͹��
���Analista  �   Data/Bops   �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Conrado Q.�23/08/07|131234� Altera��o das mensagens informativas.      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Logoff(cAgentID, cGroupID) Class AgentSmartCTI
Local RC := SMARTCTI_SUCCESS      //Retorno da funcao

::WriteLog(STR0028 + ", [AgentID=" + cAgentID + "], [GroupID=" + cGroupID + "]") //"Enviando comando de Logoff para o Middleware."

If ::lAgentPw
	::oSmartCTIWSCommand:LogoffPass(::cDevice, cAgentID, cGroupID, cValToChar(::cAgentPass))                      
	RC := ::oSmartCTIWSCommand:nReturn
Else
	::oSmartCTIWSCommand:Logoff(::cDevice, cAgentID, cGroupID)                      
	RC := ::oSmartCTIWSCommand:nReturn
EndIf                                       

If RC == NIL	//Caso em que o WebService SmartCTIWSCommand nao foi encontrado
	RC = SMARTCTI_DISCONNECTEDLINK
EndIf   

If RC <> SMARTCTI_SUCCESS
	If ::lShowUserMsg 
		MsgInfo( ::DescError(RC,STR0141 + ::cDevice + CRLF + STR0144 + cAgentID + CRLF + STR0145 + cGroupID,.F.), "AgentSmartCTI API")	// "Ramal: "  "Agente: " "Grupo DAC: "
	EndIf                                          	
EndIf
::WriteLog(STR0030 + " -> RC=" + AllTrim(Str(RC)) + ", " + ::DescError(RC)) //"Resposta do comando Logoff # Descri��o do Erro: "

Return(RC)  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ready           �Autor�Michel W. Mosca � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por alterar o estado do agente para      ���
���          �disponivel.                                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ready(ExpC1, ExpC2)  	                                  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Identificador do operador junto ao DAC.(PIN)       ���
���          � ExpC2 = Identificador do grupo DAC a ser conectado.        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������͹��
���Analista  �   Data/Bops   �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Conrado Q.�23/08/07|131234� Altera��o das mensagens informativas.      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Ready(cAgentID, cGroupID) Class AgentSmartCTI
Local RC := SMARTCTI_SUCCESS      //Retorno da funcao

::WriteLog(STR0031 + ", [AgentID=" + cAgentID + "], [GroupID=" + cGroupID + "]") //"Enviando comando de Ready para o Middleware."

If ::lAgentPw
	::oSmartCTIWSCommand:ReadyPass(::cDevice, cAgentID, cGroupID, cValToChar(::cAgentPass))                      
	RC := ::oSmartCTIWSCommand:nReturn
Else
	::oSmartCTIWSCommand:Ready(::cDevice, cAgentID, cGroupID)                      
	RC := ::oSmartCTIWSCommand:nReturn
EndIf

If RC == NIL	//Caso em que o WebService SmartCTIWSCommand nao foi encontrado
	RC = SMARTCTI_DISCONNECTEDLINK
EndIf                                               
If RC <> SMARTCTI_SUCCESS
	If ::lShowUserMsg 
		MsgInfo( ::DescError(RC,STR0141 + ::cDevice + CRLF + STR0144 + cAgentID + CRLF + STR0145 + cGroupID,.F.), "AgentSmartCTI API")	// "Ramal: "  "Agente: " "Grupo DAC: "
	EndIf                
EndIf                          	
::WriteLog(STR0033 + " -> RC=" + AllTrim(Str(RC)) + ", " + ::DescError(RC)) //"Resposta do comando Ready" #Descri��o do Erro: "

Return(RC)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NotReady        �Autor�Michel W. Mosca � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por alterar o estado do agente para      ���
���          �em pausa.                                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � NotReady(ExpC1, ExpC2)  	                                  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Identificador do operador junto ao DAC.(PIN)       ���
���          � ExpC2 = Identificador do grupo DAC a ser conectado.        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������͹��
���Analista  �   Data/Bops   �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Conrado Q.�23/08/07|131234� Altera��o das mensagens informativas.      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method NotReady(cAgentID, cGroupID) Class AgentSmartCTI
Local RC := SMARTCTI_SUCCESS      //Retorno da funcao

::WriteLog(STR0034 + ", [AgentID=" + cAgentID + "], [GroupID=" + cGroupID + "]") //"Enviando comando de NotReady para o Middleware."

If ::lAgentPw
	::oSmartCTIWSCommand:NotReadyPass(::cDevice, cAgentID, cGroupID, cValToChar(::cAgentPass))                      
	RC := ::oSmartCTIWSCommand:nReturn
Else
	::oSmartCTIWSCommand:NotReady(::cDevice, cAgentID, cGroupID)                      
	RC := ::oSmartCTIWSCommand:nReturn
EndIf

If RC == NIL	//Caso em que o WebService SmartCTIWSCommand nao foi encontrado
	RC = SMARTCTI_DISCONNECTEDLINK
EndIf                                   
If RC <> SMARTCTI_SUCCESS
	If ::lShowUserMsg 
		MsgInfo( ::DescError(RC,STR0141 + ::cDevice + CRLF + STR0144 + cAgentID + CRLF + STR0145 + cGroupID,.F.), "AgentSmartCTI API")	// "Ramal: "  "Agente: " "Grupo DAC: "
	EndIf                
EndIf                          	
::WriteLog(STR0036 + " -> RC=" + AllTrim(Str(RC)) + ", " + ::DescError(RC)) //"Resposta do comando NotReady # Descri��o do Erro: "

Return(RC)               

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �OneStepCallTransfer�Autor�Michel W. Mosca � Data �  26/10/06���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por tranferir uma chamada ativa para     ���
���          �outro ramal.(Single-step call Transfer)                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Transfer(ExpC1)		  	                                  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Numero do ramal para transferir a chamada. 	      ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������͹��
���Analista  �   Data/Bops   �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Conrado Q.�23/08/07|131234� Altera��o das mensagens informativas.      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method OneStepCallTransfer(cDeviceTo) Class AgentSmartCTI
Local RC := SMARTCTI_SUCCESS      //Retorno da funcao

::WriteLog(STR0083 + ", [DeviceTo=" + cDeviceTo + "]") //"Enviando comando de OneStepCallTransfer para o Middleware."
::oSmartCTIWSCommand:OneStepCallTransfer(::cDevice, cDeviceTo)                      
RC := ::oSmartCTIWSCommand:nReturn
If RC == NIL	//Caso em que o WebService SmartCTIWSCommand nao foi encontrado
	RC = SMARTCTI_DISCONNECTEDLINK
EndIf                                     
::WriteLog(STR0084 + " -> RC=" + AllTrim(Str(RC)) + ", " + ::DescError(RC)) //"Resposta do comando OneStepCallTransfer" #Descri��o do Erro: "

Return(RC)               

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Transfer        �Autor�Michel W. Mosca � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por tranferir uma chamada em espera para ���
���          �o ramal em que ocorre a chamada ativa.                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Transfer(ExpC1)		  	                                  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Numero do ramal para transferir a chamada. 	      ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������͹��
���Analista  �   Data/Bops   �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Conrado Q.�23/08/07|131234� Altera��o das mensagens informativas.      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Transfer() Class AgentSmartCTI
Local RC := SMARTCTI_SUCCESS      //Retorno da funcao

::WriteLog(STR0037) //"Enviando comando de Transfer para o Middleware."
::oSmartCTIWSCommand:Transfer(::cDevice)                      
RC := ::oSmartCTIWSCommand:nReturn
If RC == NIL	//Caso em que o WebService SmartCTIWSCommand nao foi encontrado
	RC = SMARTCTI_DISCONNECTEDLINK
EndIf                                     
::WriteLog(STR0038 + " -> RC=" + AllTrim(Str(RC)) + ", " + ::DescError(RC)) //"Resposta do comando Transfer #Descri��o do Erro: "

Return(RC)               


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Conference      �Autor�Michel W. Mosca � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por iniciar uma conferencia. Deve haver  ���
���          �uma chamada ativa e uma chamada em espera.                  ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������͹��
���Analista  �   Data/Bops   �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Conrado Q.�23/08/07|131234� Altera��o das mensagens informativas.      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Conference() Class AgentSmartCTI
Local RC := SMARTCTI_SUCCESS      //Retorno da funcao

::WriteLog(STR0039) //"Enviando comando de Conference para o Middleware."
::oSmartCTIWSCommand:Conference(::cDevice)                      
RC := ::oSmartCTIWSCommand:nReturn
If RC == NIL	//Caso em que o WebService SmartCTIWSCommand nao foi encontrado
	RC = SMARTCTI_DISCONNECTEDLINK
EndIf                                       
::WriteLog(STR0040 + " -> RC=" + AllTrim(Str(RC)) + ", " + ::DescError(RC)) //"Resposta do comando Conference # Descri��o do Erro: "

Return(RC)               

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Consultation    �Autor�Michel W. Mosca � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por realizar uma consulta a um ramal     ���
���          �durante uma chamada.                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Consultation(ExpC1)		  	                              ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Numero do ramal a ser consultado.              	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������͹��
���Analista  �   Data/Bops   �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Conrado Q.�23/08/07|131234� Altera��o das mensagens informativas.      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Consultation(cDeviceTo) Class AgentSmartCTI
Local RC := SMARTCTI_SUCCESS      //Retorno da funcao

::WriteLog(STR0041 + ", [DeviceTo=" + cDeviceTo + "]") //"Enviando comando de Consultation para o Middleware."
::oSmartCTIWSCommand:Consultation(::cDevice, cDeviceTo)                      
RC := ::oSmartCTIWSCommand:nReturn
If RC == NIL	//Caso em que o WebService SmartCTIWSCommand nao foi encontrado
	RC = SMARTCTI_DISCONNECTEDLINK
EndIf                               
::WriteLog(STR0042 + " -> RC=" + AllTrim(Str(RC)) + ", " + ::DescError(RC)) //"Resposta do comando Consultation # Descri��o do Erro: "

Return(RC)               

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Hold            �Autor�Michel W. Mosca � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por colocar uma chamada ativa em espera. ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������͹��
���Analista  �   Data/Bops   �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Conrado Q.�23/08/07|131234� Altera��o das mensagens informativas.      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Hold() Class AgentSmartCTI
Local RC := SMARTCTI_SUCCESS      //Retorno da funcao

::WriteLog(STR0043) //"Enviando comando de Hold para o Middleware."
::oSmartCTIWSCommand:Hold(::cDevice)                      
RC := ::oSmartCTIWSCommand:nReturn
If RC == NIL	//Caso em que o WebService SmartCTIWSCommand nao foi encontrado
	RC = SMARTCTI_DISCONNECTEDLINK
EndIf                                  
::WriteLog(STR0044 + " -> RC=" + AllTrim(Str(RC)) + ", " + ::DescError(RC)) //"Resposta do comando Hold # Descri��o do Erro: "

Return(RC)               

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Retrieve        �Autor�Michel W. Mosca � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar uma chamada que esteja em   ���
���          �espera no ramal.                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������͹��
���Analista  �   Data/Bops   �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Conrado Q.�23/08/07|131234� Altera��o das mensagens informativas.      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Retrieve() Class AgentSmartCTI
Local RC := SMARTCTI_SUCCESS      //Retorno da funcao

::WriteLog(STR0045) //"Enviando comando de Retrieve para o Middleware."
::oSmartCTIWSCommand:Retrieve(::cDevice)                      
RC := ::oSmartCTIWSCommand:nReturn
If RC == NIL	//Caso em que o WebService SmartCTIWSCommand nao foi encontrado
	RC = SMARTCTI_DISCONNECTEDLINK
EndIf                                    
::WriteLog(STR0046 + " -> RC=" + AllTrim(Str(RC)) + ", " + ::DescError(RC)) //"Resposta do comando Retrieve # Descri��o do Erro: "

Return(RC)               

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Alternate       �Autor�Michel W. Mosca � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por alternar entre uma chamada ativa e   ���
���          �uma chamada em espera.                                      ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������͹��
���Analista  �   Data/Bops   �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Conrado Q.�23/08/07|131234� Altera��o das mensagens informativas.      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Alternate() Class AgentSmartCTI
Local RC := SMARTCTI_SUCCESS      //Retorno da funcao

::WriteLog(STR0047) //"Enviando comando de Alternate para o Middleware."
::oSmartCTIWSCommand:Alternate(::cDevice)                      
RC := ::oSmartCTIWSCommand:nReturn
If RC == NIL	//Caso em que o WebService SmartCTIWSCommand nao foi encontrado
	RC = SMARTCTI_DISCONNECTEDLINK
EndIf                                   
::WriteLog(STR0048 + " -> RC=" + AllTrim(Str(RC)) + ", " + ::DescError(RC))//"Resposta do comando Alternate # Descri��o do Erro: "

Return(RC)               

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Redirect        �Autor�Michel W. Mosca � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por transferir todas as chamadas que     ���
���          �venham a tocar no ramal para outro.                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Redirect(ExpC1)		  	                                  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Numero do ramal para redirecionar as chamadas.     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������͹��
���Analista  �   Data/Bops   �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Conrado Q.�23/08/07|131234� Altera��o das mensagens informativas.      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Redirect(cDeviceTo) Class AgentSmartCTI
Local RC := SMARTCTI_SUCCESS      //Retorno da funcao

::WriteLog(STR0049 + ", [DeviceTo=" + cDeviceTo + "]") //"Enviando comando de Redirect para o Middleware."
::oSmartCTIWSCommand:Redirect(::cDevice, cDeviceTo)                      
RC := ::oSmartCTIWSCommand:nReturn
If RC == NIL	//Caso em que o WebService SmartCTIWSCommand nao foi encontrado
	RC = SMARTCTI_DISCONNECTEDLINK
EndIf                                   
::WriteLog(STR0050 + " -> RC=" + AllTrim(Str(RC)) + ", " + ::DescError(RC)) //"Resposta do comando Redirect # Descri��o do Erro: "

Return(RC)               

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �StartRec        �Autor�Michel W. Mosca � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por enviar o comando de inicio de grava- ���
���          �-cao da chamada no ramal.                                   ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������͹��
���Analista  �   Data/Bops   �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Conrado Q.�23/08/07|131234� Altera��o das mensagens informativas.      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method StartRec() Class AgentSmartCTI
Local RC := SMARTCTI_SUCCESS      //Retorno da funcao

::WriteLog(STR0051) //"Enviando comando de StartRec para o Middleware."
::oSmartCTIWSCommand:StartRec(::cDevice)                      
RC := ::oSmartCTIWSCommand:nReturn
If RC == NIL	//Caso em que o WebService SmartCTIWSCommand nao foi encontrado
	RC = SMARTCTI_DISCONNECTEDLINK
EndIf                                  
::WriteLog(STR0052 + " -> RC=" + AllTrim(Str(RC)) + ", " + ::DescError(RC)) //"Resposta do comando StartRec # Descri��o do Erro: "

Return(RC)               

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |StopRec         �Autor�Michel W. Mosca � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por enviar o comando de fim da gravacao  ���
���          �da chamada no ramal.                                        ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������͹��
���Analista  �   Data/Bops   �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Conrado Q.�23/08/07|131234� Altera��o das mensagens informativas.      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method StopRec() Class AgentSmartCTI
Local RC := SMARTCTI_SUCCESS      //Retorno da funcao

::WriteLog(STR0053) //"Enviando comando de StopRec para o Middleware."
::oSmartCTIWSCommand:StopRec(::cDevice)                      
RC := ::oSmartCTIWSCommand:nReturn
If RC == NIL	//Caso em que o WebService SmartCTIWSCommand nao foi encontrado
	RC = SMARTCTI_DISCONNECTEDLINK
EndIf   
::WriteLog(STR0054 + " -> RC=" + AllTrim(Str(RC)) + ", " + ::DescError(RC)) //"Resposta do comando StopRec # Descri��o do Erro: "

Return(RC)             
          
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetAgentState   �Autor�Vendas - CRM    � Data �  11/08/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel buscar o estado do agente no grupo DAC.  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ready(ExpC1, ExpC2)  	                                  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Identificador do operador junto ao DAC.(PIN)       ���
���          � ExpC2 = Identificador do grupo DAC a ser conectado.        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������͹��
���Analista  �   Data/Bops   �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���          �               �                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AgentState(cDevice, aResp) Class AgentSmartCTI
Local RC := SMARTCTI_SUCCESS      //Retorno da funcao

//::WriteLog("Buscando Estado do agente" + ", [AgentID=" + cAgentID + "], [GroupID=" + cGroupID + "]") //"Enviando comando de Ready para o Middleware."
//::oSmartCTIWSCommand:xxx(::cDevice, @Self:aAgtState)                      
::oSmartCTIWSCommand:queryAgentState(cDevice/*, aResp*/)
RC := ::oSmartCTIWSCommand:nReturn
If RC == NIL	//Caso em que o WebService SmartCTIWSCommand nao foi encontrado
	RC = SMARTCTI_DISCONNECTEDLINK
EndIf                                               
/*If RC <> SMARTCTI_SUCCESS
	If ::lShowUserMsg 
		MsgInfo( ::DescError(RC,STR0141 + ::cDevice + CRLF,.F.), "AgentSmartCTI API")	// "Ramal: "
	EndIf                
EndIf*/                          	
::WriteLog("Resposta do comando AgentState" + " -> RC=" + AllTrim(Str(RC)) + ", " + ::DescError(RC)) //"Resposta do comando Ready" #Descri��o do Erro: "

Return(RC)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetInfoChamAtiv �Autor�Vendas - CRM    � Data �  03/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel buscar as informacoes da chamada ativa.  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � SGInfoAtiva(cDevice) 	                                  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Ramal que esta com a chamada ativa                 ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetInfoChamAtiv(cDevice) Class AgentSmartCTI
Local RC := SMARTCTI_SUCCESS      //Retorno da funcao
Local cRet := ""
Local Splited := []
Local UltimoRed := ""

::oSmartCTIWSCommand:GetInfoChamAtiv(cDevice)
cRet := ::oSmartCTIWSCommand:creturn                  
If ValType(cRet) == "C"
	Splited := strToArray(cRet,"#")
	RC := Val(Splited[3])
	If RC = 0 //Sucesso
		UltimoRed := Splited[9]
	EndIf
	If RC == NIL	//Caso em que o WebService SmartCTIWSCommand nao foi encontrado
		RC = SMARTCTI_DISCONNECTEDLINK
	EndIf                                               
	::WriteLog("Resposta do comando GetInfoChamAtiv" + " -> RC=" + AllTrim(cRet) + ", " + ::DescError(RC)) //"Resposta do comando Ready" #Descri��o do Erro: "
Else
	::WriteLog("Resposta do comando GetInfoChamAtiv" + " -> RC=" + cValToChar(cRet) + ", " + ::DescError(RC)) //"Resposta do comando Ready" #Descri��o do Erro: "
EndIf	

Return(cRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |SystemStatus    �Autor�Michel W. Mosca � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por enviar o comando de estado do link   ���
���          �com o Middleware.                                           ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������͹��
���Analista  �   Data/Bops   �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Conrado Q.�23/08/07|131234� Altera��o das mensagens informativas.      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method SystemStatus() Class AgentSmartCTI
Local RC := SMARTCTI_SUCCESS      //Retorno da funcao

::WriteLog(STR0085) //"Enviando comando de SystemStatus para o Middleware."
::oSmartCTIWSCommand:SystemStatus()                      
RC := ::oSmartCTIWSCommand:nReturn
If RC == NIL	//Caso em que o WebService SmartCTIWSCommand nao foi encontrado
	RC = SMARTCTI_DISCONNECTEDLINK
EndIf   
::WriteLog(STR0086 + " -> RC=" + AllTrim(Str(RC)) + ", " + ::DescError(RC)) //"Resposta do comando SystemStatus" # Descri��o do Erro: "

Return(RC)           

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |WriteLog        �Autor�Michel W. Mosca � Data �  10/11/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Escreve em arquivo de log da API.                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method WriteLog(cText) Class AgentSmartCTI 
Local cFileLog := ""                 //Path do arquivo de log a ser gravado
Local nAux                           //Auxilia na construcao do arquivo de log

//�����������������������������������Ŀ
//|Grava o Log se estiver habilitado. |            
//�������������������������������������
If ::lSaveLog
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
	Ferase(cFileLog + ::cDevice + "-" + AllTrim(Str(::iLinkID)) + "-" + AllTrim(Str(Day(Date()+1))) + ".LOG")
	cFileLog += "" + ::cDevice + "-" + AllTrim(Str(::iLinkID)) + "-" + AllTrim(Str(Day(Date()))) + ".LOG"
	
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
	
Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DescError       �Autor�Michel W. Mosca � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo que descreve o erro para ser exibido para o usuario. ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � DescError(ExpN1)		  	                                  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Codigo de erro.                                    ���
���          � ExpC2 = Detalhes do erro.                                  ���
���          � ExpL3 = Se retorna o erro sem quebra de linha.             ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������͹��
���Analista  �   Data/Bops   �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Conrado Q.�23/08/07|131234� Altera��o das mensagens informativas.      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method DescError(iRC, detailRC, lLog) Class AgentSmartCTI 
Local returnText		:= ""	// Texto de retorno
Local causeRC			:= ""	// Causa do erro
Local resolutionRC		:= ""	// Resolu��o do erros
                
Default detailRC		:= ""
Default lLog			:= .T.

Do Case
	Case iRC == 0
		causeRC		:= STR0090	// "Sucesso"
	Case iRC == 1
		causeRC		:= STR0091	// "O c�digo de agente informado n�o foi aceito no PABX."
		resolutionRC:= STR0170 + CRLF + STR0171 // "Cadastrar um c�digo de agente v�lido do PABX no cadastro de operador." + Chr(13) + Chr(10)	 + "Contate o administrador do sistema."
	Case iRC == 2
		causeRC		:= STR0093	// "N�o foi poss�vel completar a chamada pois o n�mero de telefone � inv�lido."
		resolutionRC:= STR0094	// "Corrigir o n�mero no cadastro."
	Case iRC == 3
		causeRC		:= STR0095	// "N�o foi poss�vel completar a chamada."
		resolutionRC:= STR0172 + CRLF + STR0173 // "Verifique se o ramal est� no gancho;" + Chr(13) + Chr(10) + "Verifique se o ramal conectado est� correto."
	Case iRC == 4
		causeRC		:= STR0097	// "Arquivo n�o encontrado."
	Case iRC == 5             
		causeRC		:= STR0098	// "Identificador da chamada inv�lido."
		resolutionRC:= STR0099	// "Tente novamente mais tarde."
	Case iRC == 6
		causeRC		:= STR0100	// "Identificador da chamada j� existe."
		resolutionRC:= STR0101	// "Tente novamente mais tarde."
	Case iRC == 7
		causeRC		:= STR0102	// "Informa��o recebida do PABX inv�lida."
		resolutionRC:= STR0103	// "Tente novamente mais tarde."
	Case iRC == 8
		causeRC		:= STR0104	// "N�o foi poss�vel realizar a chamada. Todas as linhas est�o ocupadas."
		resolutionRC:= STR0105	// "Verifique se h� tom de discagem ou tente novamente mais tarde."
	Case iRC == 10
		causeRC		:= STR0106	// "N�o foi poss�vel completar a chamada pois o n�mero de telefone est� ocupado."
		resolutionRC:= STR0107	// "Tente novamente mais tarde."
	Case iRC == 11
		causeRC		:= STR0108	// "N�o foi poss�vel completar a chamada pois o n�mero de telefone n�o atende."
		resolutionRC:= STR0109	// "Tente novamente mais tarde."
	Case iRC == 12
		causeRC		:= STR0110	// "N�o foi poss�vel completar a chamada pois a liga��o foi atendida por um correio de voz."
		resolutionRC:= STR0111	// "Tente novamente mais tarde."
	Case iRC == 13
		causeRC		:= STR0112	// "N�o foi poss�vel completar a chamada pois a liga��o foi atendida por um fax."
		resolutionRC:= STR0113	// "Tente novamente mais tarde."
	Case iRC == 14
		causeRC		:= STR0114	// "Liga��o perdida."
		resolutionRC:= STR0115	// "Tente novamente mais tarde."
	Case iRC == 15
		causeRC		:= STR0116	// "N�o foi poss�vel enviar o fax."
		resolutionRC:= STR0117	// "Tente novamente mais tarde."
	Case iRC == 16
		causeRC		:= STR0118	// "N�o foi poss�vel comunicar com o Middleware."
		resolutionRC:= STR0174 + CRLF + STR0175 + CRLF + STR0176 // "Contate o administrador do sistema para:" + Chr(13)+Chr(10) + "Verificar se o Middleware est� em execu��o;" + Chr(13)+Chr(10) + "	Verificar as configura��es do Protheus."
	Case iRC == 17            
		causeRC		:= STR0120	// "Informa��o recebida do PABX inv�lida."
		resolutionRC:= STR0121	// "Tente novamente mais tarde."
	Case iRC == 18
		causeRC		:= STR0122	// "N�o foi poss�vel conectar com o Middleware. Pois o n�mero do ramal informado est� inv�lido ou n�o existe."
		resolutionRC:= STR0177 + CRLF + STR0178 // "Verifique se o ramal est� correto;" + Chr(13)+Chr(10) + "Se persistir o problema contate o administrador do sistema e relate a situa��o."
	Case iRC == 19
		causeRC		:= STR0124	// "Voc� tentou retirar uma chamada da espera, mas n�o h� chamada em espera."
		resolutionRC:= STR0125	// "Certifique-se que h� uma chamada em espera."
	Case iRC == 20
		causeRC		:= STR0126	// "N�o foi poss�vel colocar a chamada em espera, pois todos as posi��es de estacionamento est�o ocupados."
		resolutionRC:= STR0127	// "Tente novamente."
	Case iRC == 21
		causeRC		:= STR0128	// "Facilidade solicitada n�o dispon�vel."
		resolutionRC:= STR0129	// "Contate o administrador do sistema."
	Case iRC == 22
		causeRC		:= STR0130	// "Opera��o solicitada n�o est� dispon�vel no momento."
		resolutionRC:= STR0131	//	"Tente novamente mais tarde."
	Case iRC == 23
		causeRC		:= STR0132	// "O c�digo do agente ou ramal j� est�o em uso no momento ou o grupo DAC informado est� incorreto."
		resolutionRC:= STR0179 + CRLF + STR0180 + CRLF + STR0181 + CRLF + STR0182 // "Tente desconectar manualmente atrav�s do telefone ou" + Chr(13)+Chr(10) + "Contate o administrador do sistema para:" + Chr(13)+Chr(10) + 	"Desconectar o agente no PABX;" + Chr(13)+Chr(10) + "Verificar se o c�digo do Grupo ACD informado no grupo de atendimento est� correto;"
	Case iRC == 24
		causeRC		:= STR0134	// "N�o foi poss�vel enviar o comando solicitado ao PABX."
		resolutionRC:= STR0183 + CRLF + STR0184 // "Verifique se o ramal est� no gancho e tente novamente." + Chr(13)+Chr(10) + "Se persistir o problema contate o administrador do sistema e relate a situa��o."
	Case iRC == 25
		causeRC		:= STR0136	// "A chamada foi atendida pela compania telef�nica do destino."
		resolutionRC:= STR0185 + CRLF + STR0186 + CRLF + STR0187 // "Verifique se o n�mero do contato � v�lido;" + Chr(13)+Chr(10) + "Corrija o n�mero no cadastro;" + Chr(13)+Chr(10) + "Tente novamente mais tarde."
	Otherwise
		causeRC		:= STR0138	// "O PABX retornou uma informa��o n�o esperada."
		resolutionRC:= STR0188 + CRLF + STR0189 // "Tente novamente." + Chr(13)+Chr(10) + "Se persistir o problema contate o administrador do sistema e relate a situa��o."
EndCase

//����������������������������Ŀ
//�Monta a mensagem de retorno.�
//������������������������������
If lLog
	returnText := STR0087 + " " + StrTran(causeRC, Chr(13)+Chr(10), " ")	// "Causa:"
	If !Empty(resolutionRC)
		returnText += " | " + STR0088 + " " + StrTran(resolutionRC, Chr(13)+Chr(10), " ")	// "Resolu��o:"
	EndIf
	If !Empty(detailRC)
		returnText += " | " + STR0089 + " " + StrTran(detailRC, Chr(13)+Chr(10), " ")	// "Detalhe:"
	EndIf
Else
	returnText :=	STR0087 + Chr(13) + Chr(10) + causeRC	// "Causa:"
	If !Empty(resolutionRC)
		returnText += Chr(13) + Chr(10) + Chr(13) + Chr(10) + STR0088 + Chr(13) + Chr(10) + resolutionRC	// "Resolu��o:"
	EndIf					
	If !Empty(detailRC)
		returnText += Chr(13) + Chr(10) + Chr(13) + Chr(10) + STR0089 + Chr(13) + Chr(10) + detailRC	// "Detalhe:"
	EndIf
EndIf
            
Return(returnText)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ProcessEventsAPI�Autor�Michel W. Mosca � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo acionado pelo servidor quando houver a recepcao de   ���
���          �eventos do servidor.                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ProcessEventsAPI(ExpC1) 	                                  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Numero do ramal para redirecionar as chamadas.     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ProcessEventsAPI(cDevice, iLinkID, CodeBlock, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10)
Local nI                  //Variavel auxiliar em Loops

//conout("Start - Processando eventos da API. AgentSmartCTI:" + Str(Len(aAgentSmartCTI)))
For nI := 1 To Len(aAgentSmartCTI) 
	//conout("Agent available: Device:" + aAgentSmartCTI[nI]:cDevice + ", LinkID:" + AllTrim(Str(aAgentSmartCTI[nI]:iLinkID)) + ", oAgentEvents:" + ValType(aAgentSmartCTI[nI]:oAgentEvents))
	If aAgentSmartCTI[nI]:cDevice = cDevice .AND. aAgentSmartCTI[nI]:iLinkID = iLinkID
		aAgentSmartCTI[nI]:WriteLog(STR0055 + ":[" + CodeBlock + "], " + STR0056 + ":[p1:" + AllTrim(p1) + ", p2:" + AllTrim(p2) + ", p3:" + AllTrim(p3) + ", p4:" + AllTrim(p4) + ", p5:" + AllTrim(p5) + ", p6:" + AllTrim(p6) + ", p7:" + AllTrim(p7) + ", p8:" + AllTrim(p8) + ", p9:" + AllTrim(p9) + ", p10:" + AllTrim(p10) + "]") //Evento Recebido # Parametros
		
		//conout("Encontrou instancia.ValType=" + ValType(aAgentSmartCTI[nI]:oAgentEvents))
		If ValType(aAgentSmartCTI[nI]:oAgentEvents) <> "U"	
			//conout("Processando Code Block:" + CodeBlock)
			ErrorBlock(&("{|oError|OnProcessError(oError)}"))		
			Eval(&("{" + CodeBlock + "}"), aAgentSmartCTI[nI]:oAgentEvents, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10)
		EndIf
	EndIf
Next
//conout("Finish - Processando eventos da API. AgentSmartCTI:" + Str(Len(aAgentSmartCTI))) 
Return NIL                      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �OnProcessError  �Autor�Michel W. Mosca � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo acionado em caso de erro ao processar eventos.       ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � OnProcessError(ExpO1)  	                                  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Error object recebido do Protheus.                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OnProcessError(oError)
	//MsgStop("Ocorreu um erro ao processar os eventos." + CRLF + "Description:" + oError:Description + CRLF + "ErrorCode:" + AllTrim(Str(oError:gencode)) + CRLF + "ErrorStack:" + oError:ErrorStack) 
	MsgStop(oError:ErrorStack) 
Return .F.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �OnLostConnection�Autor�Michel W. Mosca � Data �  26/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo acionado pelo servidor quando a conexao com o client ���
���          �for encerrada.                                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Redirect(ExpC1)		  	                                  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Numero do ramal para redirecionar as chamadas.     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OnLostConnection(cDevice, cCMDWSDLSmartCTIWS, cAgentID, cGroupID, cSenhaAgente)
Local oSmartCTIWSCommand		//Instancia da classe SmartCTIWSCommand

Default cAgentID 	 := ""
Default cGroupID 	 := ""
Default cSenhaAgente := "" 

//conout("Executando OnLostConnection")
oSmartCTIWSCommand	:= WSSmartCTIWSCommandService():New(cCMDWSDLSmartCTIWS)	
If cAgentID <> "" 
	If !Empty(cSenhaAgente)
		oSmartCTIWSCommand:LogoffPass(cDevice, cAgentID, cGroupID, cSenhaAgente)
	Else
		oSmartCTIWSCommand:Logoff(cDevice, cAgentID, cGroupID)	
	EndIf
EndIf
oSmartCTIWSCommand:AgentOutOfService(cDevice)
Return Nil