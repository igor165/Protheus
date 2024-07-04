#INCLUDE "PROTHEUS.CH"      
#INCLUDE "TBICONN.CH"       
#INCLUDE "TMKXRPCCALLBACKCLIENT.CH"

#DEFINE MIN_BUILD_VERSION	"7.00.060906P" //Versao da build do Protheus para utilizar o RPCCallBack
Static aRpcCallBack := {}			//Array para controle de CallBacks entre a Thread principal do Protheus e 
									//a Thread de Pooling no servidor de RPCCallBack. Estatico, pois o timer executa
									//por um CodeBlock, nao havendo outra maneira de passar parametros. 
Static oTimer						//Timer para receber os eventos. Variavel static, pois deve haver apenas um por thread do Remote.									

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RPCCallBack�Autor  �Michel W. Mosca    � Data �  24/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Classe cliente para aguardar o retorno de CallBack de apli- ���
���          �-cacao servidora                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Class RPCCallBackClient

//Propriedades
Data cRpcServer   	// Ip do servidor a ser conectado
Data cRpcPort		// Porta a ser conectado no servidor
Data cRpcEnv 		// Ambiente a ser utilizado pelo conexao
Data oRpcServer	    // Objeto conexao RPC
Data cCallBackName   // Identificador da conex�o com o servidor RPC
Data iPosArray  	// Posicao no array de objetos da classe RPC Client
Data lDel			// Flag indicando que o objeto deve ser removido da memoria e array                               

//Metodos
Method New() CONSTRUCTOR
Method Open(cServer, cPort, cEnv)						//Funcao utilizada para atribuir o IP do servidor RPC.
Method Close() 											//Encerra a conex�o RPC. 
Method Register(cCallBackName, cCBLostConnection)       //Funcao utilizada para que o cliente seja registrado  
														//no servidor RPC e passe a receber as chamadas de 
														//RPC CallBack.
Method UnRegister()                                     //Funcao utilizada para que o cliente nao receba mais 
														//chamadas do servidor RPC CallBack. 
Method CheckEvents()                                    //Funcao utilizada para buscar eventos no servidor. 
Method SetCBLostConn(cCBLostConnection)					//Atualizar o CodeBlock de encerramento no servidor RPC CallBack.


EndClass          

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New        �Autor  �Michel W. Mosca    � Data �  24/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New() Class RPCCallBackClient 

//Inicializa valores padr�o
Self:cRpcPort  := 5024  
Self:cCallBackName := ""     
Self:lDel := .F.

If GetBuild() < MIN_BUILD_VERSION
	MsgStop(STR0001 + Chr(13)+Chr(10) + STR0002) //"Foi detectada uma incompatibilidade na vers�o da Build do Protheus." # "Favor atualizar Protheus Server e Protheus Remote."
	Final(STR0003 + MIN_BUILD_VERSION) //"Incompatibilidade com a vers�o da Build. Vers�o necess�ria:"
EndIf	

Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Open         �Autor  �Michel W. Mosca  � Data �  24/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao utilizada para atribuir o IP do servidor RPC.        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Open(ExpC1, ExpN2, ExpC3)                                  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = IP do servidor.                                    ���
���          � ExpN2 = Port para conectar no servidor.                    ���
���          � ExpC3 = Ambiente do servidor.                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Open(cServer, cPort, cEnv) Class RPCCallBackClient 

Self:cRpcServer	:= cServer
Self:cRpcPort 		:= cPort
Self:cRpcEnv 		:= cEnv


Self:oRpcServer := FwRpc():New( Self:cRpcServer, Val(Self:cRpcPort), Self:cRpcEnv )

Self:oRPCServer:SetRetryConnect(10) 

Self:oRPCServer:Connect( Self:cRpcServer, Val(Self:cRpcPort) )

Self:oRPCServer:CallProc("RPCSetType", 3 ) 

Self:oRPCServer:SetEnv(cEmpAnt, cFilAnt)
                                        
If ValType(oTimer) <> "O"
	//Ativa o timer   	  
	//Form escondido
	DEFINE TIMER oTimer INTERVAL 1500 ACTION ( RunTimerWnd() ) OF GetWndDefault()
	oTimer:lLiveAny := .T.
	oTimer:Activate()
EndIf	

Return(.T.) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Close      �Autor  �Michel W. Mosca    � Data �  24/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Encerra a conex�o RPC.                                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Close() Class RPCCallBackClient

Self:oRpcServer:Disconnect()
ADel(aRpcCallBack, Self:iPosArray)	
oTimer:DeActivate()
lExec := .F.	

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Register      �Autor �Michel W. Mosca  � Data �  24/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao utilizada para que o cliente seja registrado  no     ���
���          �servidor RPC e passe a receber as chamadas de RPC CallBack. ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Register(ExpC1, ExpC2)                                     ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Identificador unico para ser utilizado no registro ���
���          �da instancia no servidor RPC.                               ���
���          � ExpC2 = Code Block a ser executado no fim da conexao.      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Register(cCallBackName, cCBLostConnection) Class RPCCallBackClient      

Local cIPAddress 			:= GETCLIENTIP()		//Armazena o IP da Thread Local 
Local cThreadID 			:= THREADID()  			//Armazena o identificador da thread
Local nCount										//Variavel auxiliar para ser utilizado em Loops
Local aBkpRpcCallBack								//Variavel auxiliar para ser utilizado em Loops
Local nAux 					:= 0 					// Variavel auxilar para o FOR/NEXT

Default cCBLostConnection := "||" 

Self:cCallBackName := cCallBackName
	
Self:cCallBackName := AllTrim(Self:oRpcServer:Callproc("RPCCBRegister",cCallBackName))
Self:oRpcServer:Callproc('PtInternal',1,AllTrim(Self:cCallBackName))
Self:oRpcServer:CallProc("RPCSetType", 3 )
Self:oRpcServer:oRPCSRV:StartJob("RPCCBProcEvt", .F.,"RPCCallBack:" + AllTrim(Self:cCallBackName) + "|IPAddress:" + cIPAddress + "|ThreadID:" + Str(cThreadID), cCBLostConnection)

oTimer:DeActivate()
aBkpRpcCallBack := aRpcCallBack    

nAux:= Len(aRpcCallBack)
For nCount = 1 To nAux                     
	If ValType(aRpcCallBack[nCount]) == "O"		
		If aRpcCallBack[nCount]:iPosArray <> Self:iPosArray .AND. At(cCallBackName, aRpcCallBack[nCount]:cCallBackName) > 0 .AND. !aRpcCallBack[nCount]:lDel			
			aBkpRpcCallBack[nCount]:Close()
			Exit
		EndIf  
	EndIf
Next                                                      
AAdd(aRpcCallBack, Self)   
Self:iPosArray := Len(aRpcCallBack)         
aRpcCallBack := aBkpRpcCallBack        
oTimer:lLiveAny := .T.
oTimer:Activate()

		
Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �UnRegister    �Autor �Michel W. Mosca  � Data �  24/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao utilizada para que o cliente nao receba mais chamadas���
���          �do servidor RPC CallBack.                                   ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �UnRegister(ExpC1)                                           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Identificador unico para ser utilizado no registro ���
���          �da instancia no servidor RPC.                               ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method UnRegister() Class RPCCallBackClient
Self:oRpcServer:Callproc('PtInternal',1,"")
Return(.T.) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CheckEvents   �Autor �Michel W. Mosca  � Data �  24/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao utilizada para buscar eventos no servidor.           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �CheckEvents()                                               ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                
Method CheckEvents() Class RPCCallBackClient
Local nItens				//Variavel auxiliar para ser utilizado em Loops
Local nTotItens				//Variavel auxiliar para ser utilizado em Loops
Local aCodeBlocks := {} 	//Array com a hora que foi recebido e o CodeBlock a ser executado no cliente
							//Conteudo : aCodeBlocks[][1] := Seconds()
							//			 aCodeBlocks[][2] := CodeBlock} 

//conout("Executou CheckEvents")  
If ValType(Self:oRPCServer) == "O"   
	//conout(DtoC(Date()) + " " + TIME() + " - RPCCallBackClient - " + Self:cCallBackName + " - check events"+Str(ThreadId()))
	aCodeBlocks := Self:oRPCServer:CallProc("RPCCBChkEvt", Self:cCallBackName)  
	nTotItens := Len(aCodeBlocks)
	//conout(DtoC(Date()) + " " + TIME() + " - RPCCallBackClient - Number of CodeBlocks Receved: " + AllTrim(Str(nTotItens)))
	
	For nItens := 1 To nTotItens		
		If ValType(aCodeBlocks[nItens][2]) == "C"
			Eval(&("{" + aCodeBlocks[nItens][2] + "}"), "")
		EndIf	
	Next nItens
EndIf
Return(.T.) 

                                            
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SetCBLostConn �Autor �Michel W. Mosca  � Data �  24/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao utilizada para atualizar o CodeBlock de encerramento ���
���          �no servidor RPC CallBack.                                   ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �SetCBLostConn(ExpC1)                                        ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Identificador unico para ser utilizado no registro ���
���          �da instancia no servidor RPC.                               ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/           
Method SetCBLostConn(cCBLostConnection) Class RPCCallBackClient

Self:oRPCServer:CallProc("RPCCBSetCodeBlock", Self:cCallBackName, cCBLostConnection) 

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RunTimerWnd   �Autor �Michel W. Mosca  � Data �  24/10/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Timer do sistema, que estimula o mecanismo de busca por     ���
���          �eventos no servidor RPCCallBack.                            ���
���          �Atencao: Nao reaproveitar esta funcao                       ���
���          �Atencao2: Nao divulgar esta funcao.                         ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �RunTimerWnd()                                               ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                
Function RunTimerWnd() 

Local nItem		//Variavel auxiliar para ser utilizado em Loops

If ValType(aRpcCallBack) == "A"
	For nItem := 1 To Len(aRpcCallBack)
		If ValType(aRpcCallBack[nItem]) == "O"
			If !aRpcCallBack[nItem]:lDel
				aRpcCallBack[nItem]:CheckEvents()
			EndIf
		EndIf
	Next
EndIf
Return Nil


