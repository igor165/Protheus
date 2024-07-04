#INCLUDE "PROTHEUS.CH"  
#INCLUDE "LOJA1150.CH"

// O protheus necessita ter ao menos uma fun��o p�blica para que o fonte seja exibido na inspe��o de fontes do RPO.
Function LOJA1150() ; Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Classe: � LJCInitialLoadMessenger           � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Classe repons�vel por efetuar a comunica��o entre terminais.           ���
���             �                                                                        ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Class LJCInitialLoadMessenger
	Data oClient
	Data aoObservers
	
	Method New()
	Method Comunicate()
	Method StartLoadOnClient()
	Method GetProgress()
	Method CheckCommunication()
	Method GetILResult() 
	Method GetFileServerURL()
	Method GetChildren()
	Method GetFSConfiguration()
	Method GetILLastOrderLoad()
	Method GetStatusLoad()
	Method GetMVQtyMax()
	
EndClass

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � New                               � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Construtor.                                                            ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � oClient: Cliente a se comunicar.                                       ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Self                                                                   ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method New( oClient ) Class LJCInitialLoadMessenger
	Self:oClient	:= oClient
Return 

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � Comunicate                        � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Efetua a comunica��o com o cliente.                                    ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cRequest: O nome do comando.                                           ���
���             � cPar1 at� cPar8: Par�metros do comando.                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: �                                                                        ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method Comunicate( cRequest, cPar1, cPar2, cPar3, cPar4, cPar5, cPar6, cPar7, cPar8, cPar9 ) Class LJCInitialLoadMessenger
	Local oRPCConection			:= Nil
	Local oLoadProgress			:= Nil
	Local uRet					:= Nil
	Local bOriginalErrorBlock	:= Nil
	Local oLJCMessageManager	:= GetLJCMessageManager()
	Local lHasConnect			:= .F.			// Controla se houve erro na conecxao com o host 
	Local lHostError			:= .F.			// Controla se houve erro na execucao do host 
	Local lContinua  			:= .F.			// Controle de execucao
	Local nCodRet				:= 0          // Codigo retorno da execucao do host
	Local lPOS 					:= FindFunction("STFIsPOS") .AND. STFIsPOS() //Eh TOTVS PDV?
	Local lServerPosOk			:= .T.			//Valida se o server esta pronto para executar funcao da carga
	Local cPar9 				:= cEmpAnt

	Default cRequest 	:= ""
	Default cPar1 		:= ""
	Default cPar2 		:= ""
	Default cPar3 		:= ""
	Default cPar4 		:= ""
	Default cPar5 		:= ""
	Default cPar6 		:= ""
	Default cPar7 		:= ""
	Default cPar8 		:= ""
				    
	bOriginalErrorBlock := ErrorBlock( {|oErr| oLJCMessageManager := GetLJCMessageManager(), oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadMessengerComunicationError", 1, oErr:ErrorStack + oErr:ErrorEnv ) ) } )
		
	Begin Sequence
		
		If lPOS
		
			//Comunicacao via HOST ambiente ja esta preparado
			cPar3 := "" //Empresa
			cPar4 := "" //Filial
			
			LjGrvLog( "Carga","Conexao via HOST ")	
			
			If STBRemoteExecute(	"LJILRPCSER", { cRequest, cPar1, cPar2, cPar3, cPar4, cPar5, cPar6, cPar7, cPar8, cPar9 } 	, NIL	, .F.	,;
							 		@uRet       ,  /*cType*/	, /*cKeyOri*/	, @nCodRet )
				
				// Se retornar esses codigos siginifica que a retaguarda esta off	
				lHasConnect := !(nCodRet == -105 .OR. nCodRet == -107 .OR. nCodRet == -104) 
				
				// Verifica erro de execucao por parte do host
				//-103 : erro na execu��o ,-106 : 'erro deserializar os parametros (JSON)			
				lHostError := (nCodRet == -103 .OR. nCodRet == -106) 
				
				lContinua := lHasConnect .AND. !lHostError
				
				If lContinua .AND. ValType(uRet) == "C" .And. uRet == "Connection broken"
					oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadMessengerComunicationError", 1, "Connection Broken" + " '" + Self:oClient:ToString() + "'") ) // "N�o foi possivel se conectar em"
				EndIf

			ElseIf nCodRet == -101 .OR. nCodRet == -108
				lServerPosOk := .F.
				LjGrvLog( "Carga","Servidor PDV nao Preparado. Funcionalidade nao existe ou host responsavel n�o associado - LJILRPCSER ")	
				LjGrvLog( "Carga","Cadastre a funcionalidade e vincule ao Host da Retaguarda - LJILRPCSER  ")
				LjGrvLog( "Carga","A carga ser� realizada via RPC ")	
			Else
				oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadMessengerComunicationError", 1, STR0001 + " '" + Self:oClient:ToString() + "'") ) // "N�o foi possivel se conectar em"
			EndIf	
		
		EndIf
		
		//Se nao for TOTVS PDV ou servidor Nao preparado faz conexao RPC
		If !lPOS .OR. !lServerPosOk 
			
			LjGrvLog( "Carga","Conexao via RPC ")
			
			//RPC sera mantido apenas para FrontLoja		
			oRPCConection := TRPC():New( Self:oClient:cEnvironment )
						
			If oRPCConection:Connect( Self:oClient:cLocation, Self:oClient:nPort )
				cPar3 := Self:oClient:cCompany
				cPar4 := Self:oClient:cBranch
				uRet := oRPCConection:CallProcEx( "LJILRPCServer", cRequest, cPar1, cPar2, cPar3, cPar4, cPar5, cPar6, cPar7, cPar8, cPar9 )
				If ValType(uRet) == "C" .And. uRet == "Connection broken"
					oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadMessengerComunicationError", 1, "Connection Broken" + " '" + Self:oClient:ToString() + "'") ) // "N�o foi possivel se conectar em"
				EndIf
				oRPCConection:Disconnect()
			Else
				oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadMessengerComunicationError", 1, STR0001 + " '" + Self:oClient:ToString() + "'") ) // "N�o foi possivel se conectar em"
			EndIf				
		
		EndIf
		
	End Sequence
	
	ErrorBlock( bOriginalErrorBlock )
	
	If ValType(uRet) <> "U"
		
		If UPPER(cRequest) == UPPER("GetILResult")
			LjGrvLog( "Carga","Chamada de comunica��o com o server. Comunicate("+ cRequest +") Retorno: XML recebido" ) //XMl � muito grande o log ficaria ilegivel
		Else
			LjGrvLog( "Carga","Chamada de comunica��o com o server. Comunicate("+ cRequest +") Retorno: " , uRet )
		EndIf	
	Else
		LjGrvLog( "Carga","Retorno desconhecido da funcao Comunicate ")
	EndIf	
	
Return uRet

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � CheckCommunication                � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Valida a disponibilidade de comuni��o.                                 ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � lRet: .T. se foi poss�vel a comunica��o, .F. se n�o.                   ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method CheckCommunication() Class LJCInitialLoadMessenger
Return Self:Comunicate( "ConnectionTest" )

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � StartLoadOnClient                 � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Initica a carga no cliente.                                            ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cSerializedResult: Serializa��o do objeto LJCInitialLoadMakerResult.   ���
���             � cWebFileServer: Endere�o do servidor de arquivos do solicitante.       ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method StartLoadOnClient( cSerializedResult, cWebFileServer ) Class LJCInitialLoadMessenger
	Self:Comunicate( "StartInitialLoad", cSerializedResult, cWebFileServer )
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � GetProgress                       � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Recebe o progresso da carga.                                           ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � oLoadProgress: Objeto LJCInitialLoadProgress                           ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method GetProgress() Class LJCInitialLoadMessenger
	Local oLJCMessageManager	:= GetLJCMessageManager()
	Local lError			:= .F.
	Local oLoadProgress 	:= Nil
	
	cSerializedProgress := Self:Comunicate( "GetProgress" )	
	
	If !oLJCMessageManager:HasError()
		If cSerializedProgress != Nil .And. !Empty( cSerializedProgress )							 
			oLoadProgress := LJCInitialLoadProgress():New()
			oLoadProgress:Deserializer( cSerializedProgress, .T. )
			oLoadProgress:oClient := Self:oClient
		Else				
			lError := .T.
		EndIf	
	Else
		lError := .T.		
	EndIf
	
	If lError
		// Tem que adicionar a mensagem de erro no progresso
		oLoadProgress := LJCInitialLoadProgress():New( Self:oClient, -1 )
		oLoadProgress:oMessage := LJCMessage():New( "LJCInitialLoadMessengerServerError", 1, STR0002 + " '" + Self:oClient:ToString() + "' " + STR0003) // "Servidor" "n�o retornou informa��o."
	EndIf
	

Return oLoadProgress

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � GetILLastOrderLoad                � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Pega a ordem da ultima carga existente (disponivel).                   ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � oResult: Objeto LJCInitialLoadMakerResult                              ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method GetILLastOrderLoad() Class LJCInitialLoadMessenger
Return Self:Comunicate( "GetILLastOrderLoad" )



/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � GetILResult                       � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Pega o resultado da carga inicial.                                     ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � oResult: Objeto LJCInitialLoadMakerResult                              ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method GetILResult() Class LJCInitialLoadMessenger
	Local cSerializedResult	:= ""
	Local oResult				:= Nil
	Local oLJCMessageManager	:= GetLJCMessageManager()
	
	cSerializedResult := Self:Comunicate( "GetILResult" )
	
	If !oLJCMessageManager:HasError()
		oResult := LJILLoadResult( cSerializedResult )
		
		// -- Decripta informa��o do filtro
		If MethIsMemberOf(oResult,"Decrypt")
			oResult:Decrypt(oResult)
		EndIf
	EndIf
Return oResult


/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � GetFSConfiguration                � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Pega a configura��o do servidor de arquivos do cliente.                ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � oLJFileServerConfiguration: Objeto LJCFileServerConfiguration          ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method GetFSConfiguration() Class LJCInitialLoadMessenger
	Local cSerializedFSConfiguration	:= ""
	Local oLJFileServerConfiguration	:= Nil
	Local oLJCMessageManager				:= GetLJCMessageManager()
	
	cSerializedFSConfiguration := Self:Comunicate( "GetFileServerConfiguration" )
	
	If !oLJCMessageManager:HasError()
		If cSerializedFSConfiguration != Nil .And. !Empty( cSerializedFSConfiguration )
			oLJFileServerConfiguration := LJCFileServerConfiguration():New()
			oLJFileServerConfiguration:Deserializer( cSerializedFSConfiguration, .T. )
		EndIf
	EndIf
Return oLJFileServerConfiguration

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � GetFileServerURL                  � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Pega o endere�o do servidor de arquivos do cliente.                    ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � cRet: Endere�o do servidor de arquivos.                                ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method GetFileServerURL() Class LJCInitialLoadMessenger
Return Self:Comunicate( "GetFileServerURL" )

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � GetChildren                       � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Pega os filhos do cliente.                                             ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � aoClients: Array de objeto LJCInitialLoadClient.                       ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method GetChildren() Class LJCInitialLoadMessenger
	Local aSerializedClients	:= {}
	Local oClient				:= Nil
	Local oLJCMessageManager	:= GetLJCMessageManager()
	Local nCount				:= 0
	Local aoClients				:= {}
	
	aSerializedClients := Self:Comunicate( "GetChildren", Self:oClient:ToXML(.F.) )
	
	If !oLJCMessageManager:HasError()
		If ValType( aSerializedClients ) == "A"
			For nCount := 1 To Len( aSerializedClients )
				If aSerializedClients[nCount] != Nil .And. !Empty(aSerializedClients[nCount])
					oClient := LJCInitialLoadClient():New()
					oClient:Deserializer( aSerializedClients[nCount], .T. )
					aAdd( aoClients, oClient )
				EndIf
			Next
		EndIf
	EndIf
	
	
Return aoClients


/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � GetStatusLoad                       � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Pega o status de uma determinada carga no cliente                      ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � aoClients: Array de objeto LJCInitialLoadClient.                       ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method GetStatusLoad() Class LJCInitialLoadMessenger

	Local cSerializedResult	:= ""
	Local oGroupStatus				:= LJCInitialLoadGroupStatus():New()
	Local oLJCMessageManager	:= GetLJCMessageManager()
	
	cSerializedResult := Self:Comunicate( "GetILStatusLoad" , Self:oClient:ToXML(.F.) )
	
	If !oLJCMessageManager:HasError() .AND. !Empty(cSerializedResult)
		oGroupStatus:= GetStatusLoad(cSerializedResult) 
	EndIf
	
Return oGroupStatus


/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � GetMVQtyMax                       � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Pega a quantidade limite de cargas ativas do ambiente (MV_LJILQTD)     ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � aoClients: Array de objeto LJCInitialLoadClient.                       ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method GetMVQtyMax() Class LJCInitialLoadMessenger
Return Self:Comunicate( "GetMVQtyMax", Self:oClient:ToXML(.F.))

 