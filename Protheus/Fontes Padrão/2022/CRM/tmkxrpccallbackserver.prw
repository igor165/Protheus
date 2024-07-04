#INCLUDE "PROTHEUS.CH"      
#INCLUDE "SMARTCTI.CH"

#DEFINE RPCCALLBACK_MAX_THREADS 9	//Numero maximo de threads para o mesmo identificador. 0~9

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RPCCallBackGoºAutor  ³Michel W. Mosca  º Data ³  24/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que devera enviar um bloco de codigo para a Thread doº±±
±±º          ³usuario conectado e esperando em RPC CallBack;              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RPCCallBackGo(ExpC1,ExpC2)                                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome pelo qual o Callback esta registrado.         ³±±
±±³          ³ ExpC2 = CodeBlock a ser executado no cliente.              ³±±
±±³          ³                                                            ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RPCCallBackGo(cCallBackName, CodeBlock)
Local nRet := SMARTCTI_UNKNOWNERROR //Inicializa retorno como falha                                        
Local nIThreads			//Usado em loop 
Local aUsrInfo  		//Array com informacoes do usuario
Local nI        		//Variavel de controle de Loop
Local lActive			//Indica se existe uma thread ativa

If !Empty(cCallBackName)
	//conout("Processing calling to CallBack client named as [" + cCallBackName + "] " +Str(ThreadId()))	
	For nIThreads =0 To RPCCALLBACK_MAX_THREADS
		//Verifica se existe uma thread com o mesmo callbackID e numero de instancia
		lActive := .F.
		aUsrInfo := GetUserInfoArray()	
		For nI := 1 to len(aUsrInfo)     
			//Verifica se a thread ainda está ativa. 
			If At(Upper(cCallBackName) + AllTrim(Str(nIThreads)), Upper(aUsrInfo[nI][11])) > 0									
				//Thread existe
				//Conout("Thread Existe:"+Upper(cCallBackName) +" "+AllTrim(Str(nIThreads)) + " "+ Upper(aUsrInfo[nI][11]))
				lActive := .T.				
				Exit
			Endif 
		Next   		
		If lActive		
			//Aguarda 1 segundo tentando enviar em caso de nao estar em IPCWait
			ManProcEvtQueue(Upper(cCallBackName) + AllTrim(Str(nIThreads)), 1, CodeBlock)			
			nRet := SMARTCTI_SUCCESS			
		EndIf
	Next    	

Endif	

Return(nRet)    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RPCCBRegisterºAutor³Michel W. Mosca    º Data ³  22/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³#Funcao roda como JOB no Servidor#                          º±±
±±ºDesc.     ³Funcao para registro no servidor atraves de chamada RPC.    º±±
±±º          ³Utilizado pela classe RPCCallBackClient e executada como JOBº±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RPCCBRegister(ExpC1)                                       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Identificador do Callback informado pelo cliente.  ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpC1 = Nome que deve ser registrado o CallBack.           ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RPCCBRegister(cRPCPreIdentification)                         
Local nIThreads			//Variavel de controle de Loop
Local cRet              //Retorno da funcao

For nIThreads=0 To RPCCALLBACK_MAX_THREADS
	If(IPCCount(Upper(cRPCPreIdentification + AllTrim(Str(nIThreads))))==0)
		Exit		
	EndIf		
Next     

//Retorna o Identificado informado + o numero da instancia. Evitando conexoes com o mesmo nome em duplicidade
cRet := cRPCPreIdentification + AllTrim(Str(nIThreads))

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RPCCBProcEvtºAutor ³Michel W. Mosca    º Data ³  22/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³#Funcao roda como JOB no Servidor#                          º±±
±±ºDesc.     ³Funcao responsavel por processar mensagens no servidor de   º±±
±±³          ³RPC Callback.Esta funcao permanece ativa todo o tempo que   ³±±
±±³          ³durar a conexao RPC entre o Client e Server.                ³±±
±±º          ³Utilizado pela classe RPCCallBackClient e executada como JOBº±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RPCProccessCB(ExpC1,ExpC2)                                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome pelo qual o Callback esta registrado.         ³±±
±±³          ³ ExpC2 = CodeBlock a ser executado no cliente.              ³±±
±±³          ³                                                            ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RPCCBProcEvt(RPCIdentification, CloseCodeBlock)
Local cRPCID			//Armazena o Identificador da conexão RPC 
Local cPos          	//Auxiliar no tratamento de Strings
Local cPosBracket		//Auxiliar no tratamento de Strings          
Local lIPCRet       	//Indica se saiu por uma chamada IPC ou por timeout.
Local cCodeBlock    	//Auxiliar na recepção de CodeBlocks
Local bBloco            //Auxiliar na execucao de CodeBlock no servidor.
Local aEvents := {}		//Array com a hora que foi recebido e o CodeBlock a ser executado no cliente
						//Conteudo : aEvents[][1] := Seconds()
						//			 aEvents[][2] := CodeBlock} 
Local nFunctionality 	//Indica se e: 
						//	1 - Gravacao de dados
						//	2 - Leitura de dados
						//	3 - Encerra a Thread  
Local nIThreads			//Variavel auxiliar para controle do ID unico
Local cUnique			//Controle do ID unico						
Local cCloseCodeBlock	//CodeBlock a ser executado no fim da conexao
                                 
//Armazena o code block para encerramento da thread
cCloseCodeBlock := CloseCodeBlock


//Exemplo de RPCIdentification:
//RPCCallBack:XXXXXXX|IPAddress:XXXXXXXXXXX|ThreadID:XXXXXXXXXXXXXXXXX
//conout("RPCProccessCB Started ")
//conout("Starting RPC CallBack for named thread:" + RPCIdentification)
//Conout("Thread Job RPCCBPROCEVT: "+Str(ThreadId()))

cPos := At("RPCCallBack:", RPCIdentification)
cPosBracket := At("|", RPCIdentification)
If cPos > 0 .AND. cPosBracket > 0 	
	cRPCID := SubStr(RPCIdentification, cPos+12, cPosBracket-13)
	While(.T.)                                                        
		cCodeBlock := ""    
		nFunctionality := 1
		lIPCRet := IPCWaitEx(Upper(cRPCID), 30000, @nFunctionality, @cCodeBlock)
		If !lIPCRet  
			//Saindo por timeout, verifica se a thread está ativa
			StartJob("CheckThreadClosed", GetEnvServer(), .F., Upper(cRPCID))
		EndIf
		//conout("Processando eventos da Thread RPCCallBack:" + cRPCID+" nFunctionality:"+Str(nFunctionality)+" CodeBlock:"+Iif(ValType(cCodeBlock) == "U","",cCodeBlock))                    		
		Do Case               
		//Gravação de dados
		Case nFunctionality = 1
			If lIPCRet
				 //conout("Dados recebidos do IPC:" + cCodeBlock)
				 AAdd(aEvents, {Seconds(), cCodeBlock})
			EndIf		
		//Leitura de dados
		Case nFunctionality = 2
			//IPCGo("CHKEVTS" + Upper(cRPCID), aEvents)
			ManProcEvtQueue("CHKEVTS" + Upper(cRPCID), aEvents)

			aEvents := {}
		//Encerra a Thread
		Case nFunctionality = 3 .OR. nFunctionality = 4  
			//A thread do operador não está mais ativa, encerra o processamento
			//conout("Finishing RPC CallBack for named thread:" + cRPCID)
			If nFunctionality = 4 //Indica que nao há outras threads com o mesmo ID, executa o CodeBlock de encerramento
				//conout("Processing CodeBlock for finishing threads.")
				bBloco := &("{" + cCloseCodeBlock + "}")  
				Eval(bBloco, RPCIdentification)				
			EndIf
			Exit		
		Case nFunctionality = 5   
			//conout("Atualização de CodeBlock recebido:" + cCodeBlock)
			cCloseCodeBlock := cCodeBlock					
		End Case			
	End		
EndIf
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |CheckThreadClosedºAutor³Michel W. Moscaº Data ³  24/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³#Funcao roda como JOB no Servidor#                          º±±
±±ºDesc.     ³Funcao executada no servidor por uma nova threas verifican- º±±
±±º          ³-do se a thread do client continua ativa.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CheckThreadClosed(ExpC1)                                   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Identificador unico para ser utilizado no registro ³±±
±±³          ³da instancia no servidor RPC.                               ³±±
±±³          ³                                                            ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CheckThreadClosed(cThreadName,nInkey)
Local nI            	//Usado em loop
Local aUsrInfo      	//Armazena o array de Threads    
Local lActive			//Indica se a thread saiu do ar para que a função seja encerrada
Local cThreadID			//Identificador unico da thread sem o numero da instancia
Local nNumSameID:=0		//Conta o numero de thread com o mesmo identificador.
Default nInkey := 5

lActive := .F.                  
cThreadID := Left(AllTrim(cThreadName), Len(AllTrim(cThreadName))-1)  

inkey(nInkey) //Espera 5 segundos antes de verificar o aUserArrayInfo, porque as vezes a Thread some do array, mas ela nao esta morta.

// Funcao que lista as threads do monitor do Protheus, no servidor atual
aUsrInfo := GetUserInfoArray()	
// Identifica usuarios conectados
For nI := 1 to len(aUsrInfo)     
	//Verifica se a thread ainda está ativa. 
	If At(Upper(cThreadName), Upper(aUsrInfo[nI][11])) > 0									
		lActive := .T.				
	Endif 
	If At(Upper(cThreadID), Upper(aUsrInfo[nI][11]))> 0 
		nNumSameID++	
	EndIf
Next                                                     
If !lActive     
	If nNumSameID > 0 
		//IPCGo(Upper(cThreadName), 3)
		ManProcEvtQueue(Upper(cThreadName), 3)
	Else
		//IPCGo(Upper(cThreadName), 4)	
		ManProcEvtQueue(Upper(cThreadName), 4)		
	EndIf
EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |RPCCBChkEvt   ºAutor ³Michel W. Mosca  º Data ³  24/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao executada no servidor para busca de eventos do clientº±±
±±º          ³conectado.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RPCCBChkEvt(ExpC1)                                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Identificador unico para ser utilizado no registro ³±±
±±³          ³da instancia no servidor RPC.                               ³±±
±±³          ³                                                            ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RPCCBChkEvt(name)
Local aCodeBlock := {}     // Copia do vetor de eventos 
Default name		:= ""

//conout("RPCCallBackServer - RPCID:" + name)
ManProcEvtQueue(Upper(name), 2)
IPCWaitEx("CHKEVTS" + Upper(name), 1500, @aCodeBlock)
//conout(DtoC(Date()) + " " + TIME() + " - RPCCallBackServer -  ThreadName:" + name + " ,Number of sent CodeBlocks:" + Str(Len(aCodeBlock))) 


Return(aCodeBlock)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |RPCCBSetCodeBlockºAutor³Michel W. Moscaº Data ³  24/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao executada no servidor para atualizar o CodeBlock     º±±
±±º          ³executado no fim da conexao.                                º±±
±±º          ³Utilizado pela classe RPCCallBackClient e executada como JOBº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RPCCBSetCodeBlock(ExpC1,ExpC2)                             ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Identificador unico para ser utilizado no registro ³±±
±±³          ³da instancia no servidor RPC.                               ³±±
±±³          ³ ExpC2 = CodeBlock                                          ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RPCCBSetCodeBlock(RPCIdentification, cCloseCodeBlock)

ManProcEvtQueue(Upper(RPCIdentification), 5, cCloseCodeBlock)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |ManProcEvtQueue  ºAutor³Michel W. Moscaº Data ³  24/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao utilizada no gerenciamento da fila de processamento  º±±
±±º          ³de eventos que utilizam IPC para troca de dados entre       º±±
±±º          ³Threads. Prefira utilizar este metodo contra o IPC, por ha- º±±
±±³          ³-ver possibilidade de perca de dados.                       ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ManProcEvtQueue(ExpC1,ExpC2, ExpC3)                        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Identificador unico para ser utilizado no registro ³±±
±±³          ³da instancia no servidor RPC.                               ³±±
±±³          ³ Exp1 = Qualquer tipo de variavel. [OPTIONAL]               ³±±
±±³          ³ Exp2 = Qualquer tipo de variavel. [OPTIONAL]               ³±±
±±³          ³ Exp3 = Qualquer tipo de variavel. [OPTIONAL]               ³±±
±±³          ³ Exp4 = Qualquer tipo de variavel. [OPTIONAL]               ³±±
±±³          ³ Exp5 = Qualquer tipo de variavel. [OPTIONAL]               ³±±
±±³          ³ Exp6 = Qualquer tipo de variavel. [OPTIONAL]               ³±±
±±³          ³ Exp7 = Qualquer tipo de variavel. [OPTIONAL]               ³±±
±±³          ³ Exp8 = Qualquer tipo de variavel. [OPTIONAL]               ³±±
±±³          ³ Exp9 = Qualquer tipo de variavel. [OPTIONAL]               ³±±
±±³          ³ Exp10= Qualquer tipo de variavel. [OPTIONAL]               ³±±
±±³          ³ Exp11= Qualquer tipo de variavel. [OPTIONAL]               ³±±
±±³          ³ Exp12= Qualquer tipo de variavel. [OPTIONAL]               ³±±
±±³          ³ Exp13= Qualquer tipo de variavel. [OPTIONAL]               ³±±
±±³          ³ Exp14= Qualquer tipo de variavel. [OPTIONAL]               ³±±
±±³          ³ Exp15= Qualquer tipo de variavel. [OPTIONAL]               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ManProcEvtQueue(cCallBackName, Exp1, Exp2, Exp3, Exp4, Exp5, Exp6, Exp7, Exp8, Exp9, Exp10, Exp11, Exp12, Exp13, Exp14, Exp15)
Local nIPC			//Variavel de controle de Loop
Local nIPCWait      //Armazena o numero de threads encontradas para o mesmo identificador


//Aguarda 1 segundo tentando enviar em caso de nao estar em IPCWait
For nIpc=0 To 100      
	//Verifica se a thread de IPCWait está ativa. Utilizado para evitar perca de dados.
	nIPCWait := IPCCount(Upper(cCallBackName))
	If nIPCWait > 0 
		Exit			
	EndIf   
	Sleep(10)		
Next		
IPCGo(Upper(cCallBackName), Exp1, Exp2, Exp3, Exp4, Exp5, Exp6, Exp7, Exp8, Exp9, Exp10, Exp11, Exp12, Exp13, Exp14, Exp15)
Return Nil