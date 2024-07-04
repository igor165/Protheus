#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1159.CH"

/*������������������������������������������������������������������������������������������
���     Fun��o: � LJILRPCServer                     � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Recebe as solicita��es de chamada RPC da carga.                        ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cRequest: Comando a ser executado.                                     ���
���             � cPar1...cPar7: Par�metros do comando.                                  ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � uRet: Depende do comando                                               ���
������������������������������������������������������������������������������������������*/
Function LJILRPCServer( cRequest, cPar1, cPar2, cPar3, cPar4, cPar5, cPar6, cPar7, cPar8, cPar9, cParc10 )
	Local uTemp
	Local uRet					
	Local lPrepAmb := .F. 
	
	Default cRequest 	:= "" // tipo de requisi��o quando status = 2
	Default cPar1 		:= "" // tipo de requisi��o quando status = 1
	Default cPar2 		:= ""
	Default cPar3 		:= ""
	Default cPar4 		:= ""
	Default cPar5 		:= ""
	Default cPar6 		:= ""
	Default cPar7 		:= ""
	Default cPar8 		:= ""
	Default cPar9 		:= "" // codigo empresa quando status = 2
	DEfault cParc10		:= "" // codigo empresa quando status = 1
	
	// quando no cadastro de funcionalidade estiver com status = 1 o primeiro parametro fica reservado
	// para o objeto, por isso necess�rio tratar a partir do segundo parametro.
	If !Empty(cRequest) .AND. ValType(cRequest) =="O"
		cRequest 	:= cPar1
		cPar1 		:= cPar2 
		cPar2 		:= cPar3
		cPar3 		:= cPar4
		cPar4 		:= cPar5
		cPar5 		:= cPar6
		cPar6 		:= cPar7
		cPar7 		:= cPar8 
		cPar8 		:= cPar9
		cPar9 		:= cParc10
	End If 

	// Verifica as funcoes que necessitam abrir ambiente , pois eh "caro" ficar preparando toda hora
	// Com o tempo devemos sempre que adicionar verificar se realmente vai precisar do amb. aberto
	If (!Empty(cPar3) .AND. !Empty(cPar4) ) .AND. ;
		(	Lower(cRequest) == Lower("GetProgress")  .OR. Lower(cRequest) == Lower("GetILLastOrderLoad") 		.OR.;
		Lower(cRequest) == Lower("GetFileServerConfiguration").OR. Lower(cRequest) == Lower("GetILStatusLoad") )
		lPrepAmb := .T.
	EndIf
	
	// Aberto empresa e filial para nao gerar erro no uso de funcoes
	// que necessitam de ambiente aberto ( empresa e filial )
	// Func�o � chamada do PDV na carga express	
	If lPrepAmb		
		LjPreparaWs(cPar3, cPar4)  //cEmpAnt, cFilAnt
		LjGrvLog( "Carga","Preparou ambiente")
	Endif	
	

	Do Case
		Case Lower( cRequest ) == Lower( "StartInitialLoad" )
			// Desbloqueia a grava��o do XML
			PutGlbValue( "LJInitialLoadProgress", "0" )			
			// Inicia a job da carga inicial
			StartJob( "LJILThread", GetEnvServer(), .F., cPar1, cPar2 )
		Case Lower( cRequest ) == Lower( "GetProgress" ) 
			// Retorna o progresso da carga inicial
			uRet := LJILLoadProgress()
			uRet := uRet:ToXML(.F.) 
		Case Lower( cRequest ) == Lower( "GetILResult" )
			uTemp := LJILLoadResult( Nil, cPar9)
			
			// -- Incripta informa��o do filtro
			If MethIsMemberOf(uTemp,"Encrypt")
				uTemp:Encrypt(uTemp)
			EndIf
			
			uRet := uTemp:ToXML(.F.)
		Case Lower( cRequest ) == Lower( "GetILLastOrderLoad" ) 
			uRet := LJILLastOrderLoad()
		Case Lower( cRequest ) == Lower( "GetFileServerConfiguration" ) 
			uTemp := LJCFileServerConfiguration():New()
			uRet := uTemp:ToXML(.F.)
		Case Lower( cRequest ) == Lower( "GetFileServerURL" )
			uTemp := LJCFileServerConfiguration():New()
			uRet := uTemp:GetFileServerURL()
		Case Lower( cRequest ) == Lower( "ConnectionTest" )
			uRet := .T.
		Case Lower( cRequest ) == Lower( "GetChildren" )
			uRet := LJILGetChildren( cPar1 )
		Case Lower( cRequest ) == Lower( "GetILStatusLoad" )
			uTemp := GetStatusLoad(nil, cPar1)
			uRet := uTemp:ToXML(.F.)
		Case Lower( cRequest ) == Lower( "GetMVQtyMax" )
			uRet := GetQtyLoad(cPar1)
		
	EndCase	
	
	If lPrepAmb
		RPCClearEnv() // Encerra o ambiente aberto anteriormente
	EndIf
	
Return uRet


/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Fun��o: � LJILGetChildren                   � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Pega os clientes filhos do cliente solicitado.                         ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cSerializedClient: Objeto LJCInitialLoadClient serializado.            ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � aSerializedClients: Array de LJCInitialLoadClient serializados.        ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Function LJILGetChildren( cSerializedClient )
	Local oFather				:= Nil
	Local aoClients				:= {}
	Local aSerializedClients	:= {}
	Local nCount				:= 0
	Local cAmbLocal				:= ""
	
	If !Empty( cSerializedClient )
	
		oFather := LJCInitialLoadClient():New()
		oFather:Deserializer( cSerializedClient, .T. )
		
		If oFather != Nil
		
			RPCSetType(3)		
			// "FRT" > Liberacao de acesso PDV cTree para o modulo FrontLoja
			RPCSetEnv( oFather:cCompany, oFather:cBranch, Nil, Nil,"FRT")
			LjGrvLog( "Carga","Preparou ambiente")
			
			cAmbLocal := GetMV("MV_LJAMBIE",,"")
			
			If !Empty( cAmbLocal )
				DbSelectArea( "MD4" )
				DbSetOrder(1)				
				MD4->(DbSeek(xFilial("MD4")))
								
				While MD4->MD4_FILIAL == xFilial( "MD4" ) .And. MD4->(!EOF())
				 	If AllTrim(MD4->MD4_AMBPAI) == AllTrim(cAmbLocal)
						DbSelectArea( "MD3" )
						DbSetOrder( 1 )
						If MD3->(DbSeek( xFilial( "MD3" ) + MD4->MD4_CODIGO ))						
							While MD3->(!EOF()) .And. MD3->MD3_CODAMB == MD4->MD4_CODIGO
								If AllTrim(MD3->MD3_TIPO) == "R"
							 		aAdd( aoClients, LJCInitialLoadClient():New( AllTrim(MD3->MD3_IP), Val(MD3->MD3_PORTA), AllTrim(MD3->MD3_NOMAMB), MD3->MD3_EMP, MD3->MD3_FIL ) )
							 	EndIf
						 		MD3->(DbSkip())
						 	End
					 	EndIf
				 	EndIf
					MD4->(DbSkip())
				End
								
				For nCount := 1 To Len( aoClients )
					aAdd( aSerializedClients, aoClients[nCount]:ToXML(.F.) )
				Next
				
			EndIf
			
			RPCClearEnv()			
		EndIf
	EndIf
Return aSerializedClients


/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Fun��o: � LJPersistObject                   � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Grava em disco a serializa��o do objeto passado por par�metro.         ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cSerialize: Objeto serializado.                                        ���
���             � cName: Nome do arquivo a ser gravado (Comumente � o nome da classe).   ���
���             � cPath: Local onde o arquivo ser� gravado.                              ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Function LJPersistObject( cSerialize, cName, cPath )
	Local nHandle := 0
	Local nCount		:= 0
	Local nTries		:= 3
	Local lSuccess		:= .F.
	
	cPath := If( Right( cPath,1) != If( IsSrvUnix(), "/", "\" ) , cPath += If( IsSrvUnix(), "/", "\" ) , cPath )
		
	nCount := 1
	While nCount <= nTries		
		If LockByName("LJCObjectPersist" + cName, .F. , .F.)	
			nHandle := FCreate( cPath + cName + ".xml" )
			If nHandle > 0
				FWrite( nHandle, cSerialize )
				FClose( nHandle )			
				lSuccess := .T.
			EndIf
			UnLockByName("LJCObjectPersist" + cName , .F. , .F.)	
			If lSuccess
				Exit
			EndIf
		Else
			InKey(0.5)			
		EndIf
		nCount++
	End	
Return
  
/*������������������������������������������������������������������������������������������
���     Fun��o: � LJReadPersistedObject             � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Recupera do disco a serializa��o de um objeto.                         ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cName: Nome do arquivo gravado (Comumente � o nome da classe).         ���
���             � cPath: Local onde o arquivo est� gravado.                              ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
������������������������������������������������������������������������������������������*/
Function LJReadPersistedObject( cName, cPath )
Local nHandle		:= 0
Local nTotalSize	:= 0
Local cBuffer		:= ""
Local cSerialize	:= ""
Local nCount		:= 0
Local nTries		:= 3
Local lSuccess		:= .F.

	
cPath := If( Right( cPath,1) != If( IsSrvUnix(), "/", "\" ) , cPath += If( IsSrvUnix(), "/", "\" ) , cPath )	
	
	
nCount := 1
While nCount <= nTries
	If LockByName("LJCObjectPersist" + cName, .F. , .F.)			
		nHandle := FOpen( cPath + cName + ".xml" )
		If nHandle > 0
			nTotalSize := FSeek( nHandle, 0, 2 )
			If nTotalSize > 0
				FSeek( nHandle, 0 )
				cBuffer := Space(nTotalSize)
				If FRead( nHandle, @cBuffer, nTotalSize ) == nTotalSize
					cSerialize := cBuffer
					lSuccess := .T.
				EndIf
			EndIf
			FClose(nHandle)
		EndIf
		UnLockByName("LJCObjectPersist" + cName, .F. , .F.)	
		If lSuccess
			Exit
		EndIf
	Else
		InKey(0.5)
	EndIf
	nCount++
End


/*Valido somente o XML 'ljcinitialloadstatus' pois n�o sei se pode haver problema
se entrar na fun��o ValidXML e for outro XML diferente dos que existem nela*/
If !Empty(AllTrim(cSerialize)) .And. (Lower(cName) == 'ljcinitialloadstatus') .And. !ValidXMLVersion(cSerialize,cName)
	cSerialize := ""
EndIf
		
Return cSerialize

/*������������������������������������������������������������������������������������������
���     Fun��o: � LJILLoadProgress                  � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Pega o progresso de carga do ambiente em que � executado.              ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum                                                                 ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � oLJInitialLoadProgress: Objeto LJCInitialLoadProgress com o progresso. ���
������������������������������������������������������������������������������������������*/
Function LJILLoadProgress( cSerialized )
	Local oLJInitialLoadProgress	:= LJCInitialLoadProgress():New(,6)
	Local oLJILConfiguration		:= LJCInitialLoadConfiguration():New()
	
	If cSerialized == Nil	
		cSerialized := LJReadPersistedObject( cEmpAnt + "LJCInitialLoadProgress", oLJILConfiguration:GetILPersistPath() )
	EndIf
	
	If !Empty(AllTrim(cSerialized))
		oLJInitialLoadProgress:Deserializer( cSerialized, .T. )
	EndIf	
Return oLJInitialLoadProgress

/*������������������������������������������������������������������������������������������
���     Fun��o: � GetStatusLoad                    � Autor: Vendas CRM � Data: 17/07/12 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � pega o status das cargas do ambiente             						 ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum                                                                 ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � oLJInitialLoadProgress: Objeto LJCInitialLoadProgress com o progresso. ���
������������������������������������������������������������������������������������������*/
Function GetStatusLoad( cSerialized, cClientSerialized )
Local oGroupStatus			:= Nil
Local oLJILConfiguration	:= LJCInitialLoadConfiguration():New()	
Local cPath					:= oLJILConfiguration:GetILPersistPath()	
Local oClient 				:= Nil
Local cArquivo				:= ""
Local lExistXML				:= .F.

cPath		:=	If( Right( cPath,1) != If( IsSrvUnix(), "/", "\" ) , cPath += If( IsSrvUnix(), "/", "\" ) , cPath )
cArquivo	:=	cPath + cEmpAnt + "LJCInitialLoadStatus.xml"
lExistXML	:=	File(cArquivo)

cPath := If( Right( cPath,1) != If( IsSrvUnix(), "/", "\" ) , cPath += If( IsSrvUnix(), "/", "\" ) , cPath )
If Empty(AllTrim(cSerialized))	
	If !lExistXML //caso nao exista o xml, tenta montar o arquivo e retorna
		If !Empty(cClientSerialized) //se recebeu o cliente verifica status dele, senao pega o local
			oClient := LJCInitialLoadClient():New()
			oClient:Deserializer( cClientSerialized, .T. )
		EndIf
		MakeXMLStatus(oClient)
	EndIf		
	cSerialized := LJReadPersistedObject(cEmpAnt + "LJCInitialLoadStatus", oLJILConfiguration:GetILPersistPath())
EndIf

oGroupStatus := LJCInitialLoadGroupStatus():New()

// Se o resultado n�o estiver em branco	 
If !Empty(AllTrim(cSerialized))
	oGroupStatus:Deserializer(cSerialized , .T.)
	LjGrvLog("Carga" , cEmpAnt + "LJCInitialLoadStatus.xml -> Objeto Deserializado")
Else
	Conout(ProcName(0) + " - " + cEmpAnt + "LJCInitialLoadStatus.xml -> Arquivo em branco ou n�o existe")
	LjGrvLog("Carga" , " - " + cEmpAnt + "LJCInitialLoadStatus.xml -> Arquivo em branco ou n�o existe")
	
	If lExistXML
		FErase(cArquivo)
		Conout(ProcName(0) + " - " + cEmpAnt + "LJCInitialLoadStatus.xml -> Arquivo em branco ser� deletado")
		LjGrvLog("Carga" , " - " + cEmpAnt + "LJCInitialLoadStatus.xml -> Arquivo em branco ser� deletado")		
	EndIf
EndIf
	
Return oGroupStatus

/*������������������������������������������������������������������������������������������
���     Fun��o: � LJILLastOrderLoad                 � Autor: Vendas CRM � Data: 15/08/12 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Pega a ordem da ultima carga do ambiente em que � executado.           ���
���             � (ultima carga disponivel para os filhos baixarem)                      ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum                                                                 ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � LJILLastOrderLoad:ordem da ultima carga incremental 					 ���
������������������������������������������������������������������������������������������*/
Function LJILLastOrderLoad()
Local cLastOrder 			:= PADL("",10,"0") //se a tabela estiver vazia significa que o ambiente nao tem nenhuma carga... retorna ordem 0000000000 
Local oLJCMessageManager 	:= GetLJCMessageManager()
Local oResult 			:= Nil  	//resultado das cargas geradas no ambiente
Local nI					:= 0

If AliasInDic("MDF") //protecao caso nao tenha a MDF
	DBSelectArea("MDF") // Esta tabela possui somente um registro com o campo MDF_ORDEM que representa a ordem da ultima carga do ambiente
	If MDF->(!EOF())
		cLastOrder:= MDF->MDF_ORDEM //pega a ordem da ultima incremental
	EndIf
	
	//protecao para ambientes legados que ainda nao tinham o controle dessa forma
	If Val(cLastOrder) == 0
		//tenta criar o registro na MDF
		//Se for na retaguarda cria baseado no xml de cargas geradas
		If LJ1176IsServer()
			oResult := LJILLoadResult()
			For nI := Len(oResult:aoGroups) to 1 Step -1
				If oResult:aoGroups[nI]:cEntireIncremental == "2" 
					WLastIncOrder(oResult:aoGroups[nI]:cOrder) //grava a ordem da ultima carga incremental disponivel
					Exit
				EndIf
			Next nI	
		//Se nao for retaguarda, cria baseado na MBY (status das cargas carregadas)
		Else
			If AliasInDic("MBY") //protecao caso nao tenha a MBY
				//Verifica qual eh a ultima carga incremental (de maior ordem) - para protecao
				DBSelectArea("MBY")
				DbSetOrder(2)//Filial + intInc + ordem + codcarga
				If DbSeek( xFilial("MBY") + "2")
					While MBY->(!EOF()) .AND. MBY->MBY_INTINC == "2" //percorre todas as incrementais
						MBY->( DbSkip() )
					EndDo
					MBY->( DbSkip(-1) ) //volta um registro pra pegar a ultima incremental	
					WLastIncOrder(MBY->MBY_ORDEM)  //grava a ordem da ultima carga incremental do ambiente
				EndIf	
			Else
				oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCInitialLoadLoaderTableDoesntExist", 1, STR0002) ) // Atusx // 
			EndIf
			
		EndIf
		
		//tenta pegar novamente a ultima ordem
		DBSelectArea("MDF") // Esta tabela possui somente um registro com o campo MDF_ORDEM que representa a ordem da ultima carga do ambiente
		If MDF->(!EOF())
			cLastOrder:= MDF->MDF_ORDEM //pega a ordem da ultima incremental
		EndIf
	
	EndIf
	
Else
	oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCInitialLoadLoaderTableDoesntExist", 1, STR0003 ) ) // Atusx // 
EndIf

LjGrvLog("Carga", "Ultima ordem " , cLastOrder )

Return cLastOrder


//--------------------------------------------------------------------------------
/*/{Protheus.doc} WLastIncOrder()

Grava na MDF a ordem da ultima carga

@param cOrder ordem a ser gravada 

@return nil

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------------------    
Function WLastIncOrder(cOrder)
Local oLJCMessageManager := GetLJCMessageManager()

If AliasInDic("MDF") //protecao caso nao tenha a MDF
	DBSelectArea("MDF") // Esta tabela possui somente um registro com o campo MDF_ORDEM que representa a ordem da ultima carga do ambiente
	If MDF->(EOF())
		Reclock("MDF", .T.)
		Replace MDF->MDF_FILIAL	With xFilial( "MDF" )
		Replace MDF->MDF_ORDEM 	With PADL(cOrder,10,"0")
		MDF->( MsUnLock() )
		
	Else
		Reclock("MDF", .F.) 
		Replace MDF->MDF_ORDEM 	With PADL(cOrder,10,"0")
		MDF->( MsUnLock() )
	EndIf

Else
	oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCInitialLoadLoaderTableDoesntExist", 1, STR0003) ) // Atusx // 
EndIf

Return Nil

/*�������������������������������������������������������������������������������������������������
���     Fun��o: � LJILLoadResult                    � Autor: Vendas CRM � Data: 23/10/10 		���
�����������������������������������������������������������������������������������������������͹��
���  Descri��o: � Pega o resultado da carga do ambiente em que � executado.             	    ���
���             �                                                                        		���
�����������������������������������������������������������������������������������������������͹��
��� Parametros: � cSerialized: objeto LJCInitialLoadMakerResult serializado              		���
�����������������������������������������������������������������������������������������������͹��
���    Retorno: � oLJCInitialLoadMakerResult: Objeto LJCInitialLoadMakerResult com o resultado. ���
���������������������������������������������������������������������������������������������������*/
Function LJILLoadResult( cSerialized, cPar9 )
Local oLJILMakerResult			:= Nil
Local oLJILConfiguration		:= LJCInitialLoadConfiguration():New()	


oLJILMakerResult := LJCInitialLoadMakerResult():New() //sempre instancia a classe (mesmo qdo nao tiver xml, para evitar error log)

If cSerialized == Nil
	If cPar9 == Nil //Tratamento necessario para controlar Multi Empresas 
		cSerialized := LJReadPersistedObject(cEmpAnt + "LJCInitialLoadMakerResult", oLJILConfiguration:GetILPersistPath())
	Else	
		cSerialized := LJReadPersistedObject(cPar9 + "LJCInitialLoadMakerResult", oLJILConfiguration:GetILPersistPath())
	Endif
EndIf

// Se o resultado n�o estiver em branco e for versao nova
If !Empty(AllTrim(cSerialized)) 
	If ValidXMLVersion(cSerialized, 'LJCInitialLoadMakerResult') 
		oLJILMakerResult:Deserializer(cSerialized , .T.) 
	Else
		//Se o xml nao eh valido apaga para recriar na proxima chamada.
		If cPar9 == Nil
			FErase(oLJILConfiguration:GetILPersistPath() + cEmpAnt + "LJCInitialLoadMakerResult.xml")
			Conout(ProcName(0) + " - " + oLJILConfiguration:GetILPersistPath() + cEmpAnt + "LJCInitialLoadMakerResult.xml -> Arquivo inv�lido ser� deletado")
			LjGrvLog("Carga" , oLJILConfiguration:GetILPersistPath() + cEmpAnt + "LJCInitialLoadMakerResult.xml -> Arquivo inv�lido ser� deletado")	
		Else
			FErase(oLJILConfiguration:GetILPersistPath() + cPar9 + "LJCInitialLoadMakerResult.xml")
			Conout(ProcName(0) + " - " + oLJILConfiguration:GetILPersistPath() + cPar9 + "LJCInitialLoadMakerResult.xml -> Arquivo inv�lido ser� deletado")
			LjGrvLog("Carga" , oLJILConfiguration:GetILPersistPath() + cPar9 + "LJCInitialLoadMakerResult.xml -> Arquivo inv�lido ser� deletado")	
		Endif
	EndIf	
EndIf
Return oLJILMakerResult

/*������������������������������������������������������������������������������������������
���     Fun��o: � LJILSaveProgress                  � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Grava em disco o progresso da carga.                                   ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � oProgress: Objeto LJCInitialLoadProgress com o progresso.              ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
������������������������������������������������������������������������������������������*/
Function LJILSaveProgress( oProgress, cGrpEmp )
	Local oLJILConfiguration	:= LJCInitialLoadConfiguration():New()
 	IF valtype(cGrpEmp) <> "C" 
		LJPersistObject( oProgress:ToXML(.F.), cEmpAnt + "LJCInitialLoadProgress", oLJILConfiguration:GetILPersistPath() )	
	Else
		LJPersistObject( oProgress:ToXML(.F.), cGrpEmp + "LJCInitialLoadProgress", oLJILConfiguration:GetILPersistPath() )	
	EndIf
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Fun��o: � LJILThread                        � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Fun��o executada por thread ou job que gerencia o carregamento         ���
���             � de carga.                                                              ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cSerializedRequest: Objeto LJCInitialLoadRequest com a requisi��o.     ���
���             � cWebFileServer: Endere�o do servidor de arquivos.                      ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Function LJILThread( cSerializedRequest, cWebFileServer )
	Local oLJCMessageManager			:= GetLJCMessageManager()
	Local bOriginalErrorBlock			:= Nil
	Local oRequest					:= Nil
	Local oLocalClient					:= Nil
	Local nCount						:= 0
	Local nTries						:= 3	
	Local cGrpEmp						:= ""
		
	If !Empty( cSerializedRequest )
		oRequest := LJCInitialLoadRequest():New()
		oRequest:Deserializer( cSerializedRequest, .T. )
		cGrpEmp := oRequest:oClient:cCompany
	Endif
	
	oILProgress := LJCInitialLoadProgress():New(,1)
	LJILSaveProgress( oILProgress, cGrpEmp )	
	
	LjGrvLog( "Carga","Gerencia o carregamento da carga" )
		
	nCount := 1
	While nCount <= nTries		
		// N�o permite que haja duas execu��es da carga
		If LockByName("LJILThread", .F. , .F.)
			bOriginalErrorBlock := ErrorBlock( {|oErr| oLJCMessageManager := GetLJCMessageManager(), oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJILThreadRuntimeError", 1, oErr:ErrorStack ) ) } )
			Begin Sequence 		
				If !Empty( cSerializedRequest )
					
					// Pega a requisi��o com as informa��es da carga
					oRequest := LJCInitialLoadRequest():New()
					oRequest:Deserializer( cSerializedRequest, .T. )
						
					RPCSetType(3)			
					// "FRT" > Liberacao de acesso PDV cTree para o modulo FrontLoja
					RPCSetEnv( oRequest:oClient:cCompany, oRequest:oClient:cBranch,Nil,Nil,"FRT")
					LjGrvLog( "Carga","Preparou ambiente")
						
					LoadProcess( oRequest, cWebFileServer, LJCInitialLoadPersistProgress():New() )
		
					RPCClearEnv()
		
				Else
					oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJILThreadInvalidRequest", 1, STR0001 ) ) // "Os dados da carga inicial n�o est�o corretos."
				EndIf
			End Sequence
			
			// Recupera o error block original
			ErrorBlock( bOriginalErrorBlock )
		
			
			// Se houve algum erro no processamento da carga inicial, configura o objeto de progresso com o erro, e a informa��o do erro
			If oLJCMessageManager:HasError()
				oILProgress := LJILLoadProgress()
				oILProgress:nStep := -1
				oILProgress:oMessage := oLJCMessageManager:oMessage
				LJILSaveProgress( oILProgress )
			ElseIf oILProgress:nStep == 1 //caso nao tenha nenhuma carga selecionada no processo (atraves do array aSelection). Ira abortar o processo no meio com step = 1. Entao atualiza para o step 5 finalizando automaticamente 
				oILProgress:nStep := 5
				LJILSaveProgress( oILProgress )
			EndIf
			UnLockByName("LJILThread" , .F. , .F.)
			Exit
		Else
			InKey(0.5)						
		EndIf
		nCount++
	End	
	
	If nCount > nTries
		oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJILThreadInvalidRequest", 1, "N�o foi poss�vel executar o carregamento de carga pois j� existe um processo de carregamento rodando ao mesmo tempo." ) )
	EndIf	
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Fun��o: � LoadProcess                       � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Fun��o executada pelas interfaces que efetuam o carregamento de carga. ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � oRequest: Objeto LJCInitialLoadRequest com a requisi��o.               ���
���             � cWebFileServer: Endere�o do servidor de arquivos.                      ���
���             � oObserver: Observador que ir� precisar do progresso do carregamento.   ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Function LoadProcess( oRequest, cWebFileServer, oObserver )
	Local oLJCMessageManager			:= GetLJCMessageManager()
	Local oLJILConfiguration			:= LJCInitialLoadConfiguration():New()
	Local oLJILFileServerConfiguration	:= LJCFileServerConfiguration():New(.F.)	
	Local oLJILChildRequester			:= Nil		
	Local oLoader						:= Nil	
	Local nI							:= 0
	Local cStatus						:= ""
	Local cLastOrder					:= ""
	Local oDelete						:= Nil
	Local oLocalClient					:= GetLocalClient()
	Local cIP							:= ""
	Local cPort							:= ""
	Local cEnv							:= ""
	Local cCompany						:= ""
	Local cBranch						:= ""
	Local cTypeLoad						:= ""
	Local lVerOrder 					:= SuperGetMV("MV_LJVEROD", Nil, .T.)
	Local lForcePSS						:= .F.						//Indica se � necessario atualizar usuarios (Caso a carga Tenha SA6)
	Local lUsrInDb						:= MPIsUsrInDB()			//Identifica se os usuarios est�o no banco

	LjGrvLog( "Carga","Inicio LoadProcess " )
	LjGrvLog( "Carga","Valida ordem MV_LJVEROD " , lVerOrder )

	//grava as informacoes das cargas existentes para que outra m�quina possa puxar o banco de dados dessa. Mas s� � v�lido se essa m�quina estiver configurada para ser servidor de arquivo.
	LJPersistObject( oRequest:oResult:ToXML(.F.), cEmpAnt + "LJCInitialLoadMakerResult", oLJILConfiguration:GetILPersistPath() )
		
	//limpa cargas velhas que ja foram apagadas do servidor (caso existam)
	oDelete := LJCInitialLoadDeleteLoad():New(oRequest:oResult,Nil)
	oDelete:CleanClientTrash()
					
	//percorre as cargas selecionadas e executa o procedimento todo para cada carga
	For nI := 1 to Len(oRequest:aSelection)
		If oRequest:aSelection[nI]	//verifica se a carga esta selecionada para executar os procedimentos
			
			//Caso a Carga atual tenha SA6 realizo a atualiza��o das Senhas, caso encontre a primeira n�o preciso ficar verificando novamente.
			If lUsrInDb .AND. !lForcePSS .AND. aScan( oRequest:oResult:aoGroups[nI]:OTRANSFERTABLES:AOTABLES,{|x| x:CTABLE == "SA6" }) > 0
				lForcePSS := .T.
			EndIf 
			//log 
			cTypeLoad := IIF((oRequest:oResult:aoGroups[nI]:cEntireIncremental == "2"), "INCREMENTAL", "INTEIRA") 
			
			LjGrvLog( "Carga","Processando a carga " + cTypeLoad + " - " + oRequest:oResult:aoGroups[nI]:cCode + " ....." )
			Conout("Processando a carga " + cTypeLoad + " - " + oRequest:oResult:aoGroups[nI]:cCode + " ....." )
			
			//Se for atualizacao completa do ambiente, valida se a proxima carga existe
			If  ( oRequest:lUpdateAll ) .AND. ( !ExistNextOrder(oRequest, lVerOrder) ) 
				//se o modo de atualizacao for o express, aborta protheus, senao apenas retorna erro no gerenciador de mensagens 
				If oRequest:lIsExpress	
					UserException( STR0004 )
				Else
					LjGrvLog("Carga", STR0004)
					Conout(STR0004)
					If Empty(oLJCMessageManager:oMessage) .OR. !(!Empty(oLJCMessageManager:oMessage) .AND. oLJCMessageManager:oMessage:cMessage == STR0004) 	
						oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCLoaderInvalidLoadOrder", 1, STR0004) ) //atusx  // "A pr�xima carga da sequ�ncia n�o existe. Solicite para o administrador gerar uma carga inteira e atualizar manualment o ambiente."
					EndIf 
				EndIf
			Else
			
				// Processa a carga - passa apenas a carga selecionada
				oLoader := LJCInitialLoadLoader():New( oRequest:oResult:aoGroups[nI], cWebFileServer, oLJILConfiguration:GetILTempPath(), oLJILFileServerConfiguration:GetPath() + oRequest:oResult:aoGroups[nI]:cCode + "\", oRequest:lKillOtherThreads )
				oLoader:AddObserver( oObserver )			
				
				// Se for para baixar, executa a baixa e grava as informa��es da baixa e da carga (oResult).
				If oRequest:lDownload
					oLoader:Download()
				EndIf
				
				If !oLJCMessageManager:HasError() 
					If oRequest:lImport
						oLoader:Import()
					EndIf
								
					If oRequest:lActInChildren
						// Verifica se o cliente tem dependentes, se tiver, solicita a execu��o da carga neles					
						oLJILChildRequester := LJCInitialLoadChildRequester():New( oLocalClient, oRequest:lDownload, oRequest:lImport, oRequest:lActInChildren, oRequest:lKillOtherThreads, oRequest:aSelection )
						oLJILChildRequester:StartIL(nil, oRequest:lUpdateAll)
					EndIf
				EndIf				
				
				
				//grava status da carga no ambiente
				If !oLJCMessageManager:HasError() 
					If oRequest:lDownload
						cStatus := "1"
					End
					If oRequest:lImport
						cStatus := "2"
					End
					
					LjGrvLog( "Carga","Status " , cStatus )
					oLoader:UpdateEnvironmentStatus( cStatus ) //atualiza o status da carga no ambiente
					MakeXMLStatus()//Gera xml com o status de todas as cargas do ambiente
					
				EndIf
				
				If oRequest:lDownload
					If !oLJCMessageManager:HasError()
						cLastOrder := LJILLastOrderLoad()
						
						// Significa que a carga foi baixada no ambiente, ent�o gravo as informa��es da ultima carga disponivel para os filhos deste ambiente
						//verifica se a carga eh incremental e se a carga baixada eh mais recente (ordem) que a ultima (maior ordem) carga ja disponivel neste ambiente (avalia a ultima carga disponivel no ambiente)
						If oLoader:oProgress:nStep == 5 .AND. oRequest:oResult:aoGroups[nI]:cEntireIncremental == "2" .AND. oRequest:oResult:aoGroups[nI]:cOrder > cLastOrder
							WLastIncOrder(oRequest:oResult:aoGroups[nI]:cOrder ) //grava a ordem da ultima carga incremental carregada
						EndIf									
					EndIf
				EndIf
								
			EndIf 
			
		EndIf 
			
	Next nI

	//Atualiza arquivo de senhas/usuarios - sigapss
	If oRequest:lLoadPSS .OR. (lUsrInDb .AND. lForcePSS ) //Se os usuarios estiverem no banco
		//Para evitar erro quando o client da requisicao (oRequest) for o proprio ambiente, pego os dados de conexao dos parametros 
		cIP			:= SuperGetMV("MV_LJILLIP", .F.)
		cPort		:= SuperGetMV("MV_LJILLPO", .F.)
		cEnv		:= SuperGetMV("MV_LJILLEN", .F.)
		cCompany	:= SuperGetMV("MV_LJILLCO", .F.)
		cBranch		:= SuperGetMV("MV_LJILLBR", .F.)

		//Esse parametro define se a atualiza��o de senhas esta habilitado ou n�o
		If SuperGetMv("MV_LJATUSE",,1) == 1
			If !IsBlind()			
				MsgRun(STR0015,STR0014,{|| LJ1157PSS(cIP,Val(cPort),cEnv,cCompany,cBranch) }) //" Iniciando a atualizacao das Senhas..." ## "Aguarde..."
			Else
				LJ1157PSS(cIP,Val(cPort),cEnv,cCompany,cBranch)	
			EndIf	
		Else
			LjGrvLog("Carga","As senhas dos usuarios n�o foram atualizadas pois o parametro MV_LJATUSE n�o esta igual a 1")
		EndIf
	EndIf
		
	LjGrvLog( "Carga","Fim LoadProcess " )	
			
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Fun��o: � LJILRealDriver                    � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Fun��o auxiliar para pegar o nome do driver local utilizado na gera��o ���
���             � da carga.                                                              ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Function LJILRealDriver()

Local cDriver 		:= "DBFCDXADS"
Local cDrvParam 	:= UPPER(AllTrim(SuperGetMV("MV_LJILDRV",,""))) //Driver definido via param
Local cRelease		:= GetRPORelease()								//Release atual

If MpDicInDb() .AND. cRelease >= "12.1.025" 
	cDrvParam := "CSV"
	LjGrvLog( "Carga","Release Atua: " + cRelease + " e Dicionario no banco, parametro MV_LJILDRV obrigatoriamente devera ser igual a 'CSV'.")							
EndIf

If !Empty(cDrvParam) .AND. cDrvParam $ "DBFCDX|DBFCDXADS|CTREECDX|CSV"
	cDriver := cDrvParam
ElseIf RealRDD() == "ADSSERVER"
   cDriver := "DBFCDX"
Else                                                                                     
   If RealRDD() == "CTREE"
      cDriver := "CTREECDX"
   Else
      cDriver := "DBFCDXADS"
   EndIf
EndIf

LjGrvLog( "Carga","MV_LJILDRV: " + cDrvParam + " |RealRDD: " + AllTrim(RealRDD()) + " |Retorno LJILRealDriver: " + cDriver)
	
Return cDriver


//--------------------------------------------------------
/*/{Protheus.doc} LJILRealExt()
Funcao responsavel por definir qual extensao de arquivos a carga sera gerada
@type function
@author  	rafael.pessoa
@since   	28/09/2016
@version 	P12.1.14
@return	cExtension - Retorna extensao de arquivos da carga
/*/
//--------------------------------------------------------
Function LJILRealExt()

Local cDrvParam 	:= UPPER(AllTrim(SuperGetMV("MV_LJILDRV",,""))) //Driver definido via param
Local cExtension 	:= "" 											//Define qual sera a extensao da carga
Local cRelease		:= GetRPORelease()								//Release atual

If MpDicInDb() .AND. cRelease >= "12.1.025" 
	cDrvParam := "CSV"
	LjGrvLog( "Carga","Release Atua: " + cRelease + " e Dicionario no banco, parametro MV_LJILDRV obrigatoriamente devera ser igual a 'CSV'.")							
EndIf

If !Empty(cDrvParam) .AND. cDrvParam $ "DBFCDX|DBFCDXADS|CTREECDX|CSV"
	If cDrvParam == "CTREECDX"
		cExtension := ".dtc"
	ElseIf cDrvParam == "CSV"
		cExtension := ".csv"
	Else
		cExtension := ".dbf"
	EndIf	
Else
	cExtension := GetDBExtension()
EndIf	

LjGrvLog( "Carga","Driver MV_LJILDRV: " + cDrvParam + " |GetDBExtension: " + AllTrim(GetDBExtension()) + " |Retorno LJILRealExt: " + cExtension  )

Return cExtension

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Funcao: � GetLocalClient                    � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Pega o cliente que representa a m�quina local.                         ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum                                                                 ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � oClient: Objeto LJCInitialLoadClient                                   ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Function GetLocalClient()
	Local oLJCMessageManager	:= GetLJCMessageManager()
	Local cAmbLocal 			:= GetMV("MV_LJAMBIE",,"")
	Local oClient				:= Nil
	Local lEnvironmentFound		:= .F.
	Local lRPCConfigurationFound:= .F.
	Local oLJMessenger			:= Nil

	LjGrvLog( "Carga","Ambiente Local" , cAmbLocal)

	If !Empty( cAmbLocal )
		// Procura pelo cliente local
		DbSelectArea( "MD4" )
		DbSetOrder(1)	
		MD4->(DbSeek(xFilial("MD4")))
		
		While MD4->MD4_FILIAL == xFilial( "MD4" ) .And. MD4->(!EOF())
		 	If AllTrim(MD4->MD4_CODIGO) == AllTrim(cAmbLocal)
		 		lEnvironmentFound := .T.
		 		// Procura pela configura��o de comunica��o RPC do pr�prio ambiente
				DbSelectArea( "MD3" )
				DbSetOrder( 1 )
				If MD3->(DbSeek( xFilial( "MD3" ) + MD4->MD4_CODIGO ))						
					While MD3->(!EOF()) .And. MD3->MD3_CODAMB == MD4->MD4_CODIGO				
						If AllTrim(MD3->MD3_TIPO) == "R"
						
							If Empty(MD3->MD3_IP) .OR. Empty(MD3->MD3_PORTA)
							    oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCMonitorLocalAmbientNotConfigured", 1, STR0011) ) //"IP ou Porta n�o foram definidos na Tabela MD3"
							    oLJCMessageManager:Show( STR0007 ) //"O ambiente configurado no par�metro MV_LJAMBIE n�o tem a configura��o de comunica��o RPC efetuada."
								oLJCMessageManager:Clear()
							Else
								lRPCConfigurationFound := .T.
						 		oClient := LJCInitialLoadClient():New( AllTrim(MD3->MD3_IP), Val(MD3->MD3_PORTA), AllTrim(MD3->MD3_NOMAMB), MD3->MD3_EMP, MD3->MD3_FIL )			 		
						 		// Efetua o teste de comunica��o com o cliente para validar se conseguir� se conectar em si mesmo.
								oLJMessenger := LJCInitialLoadMessenger():New( oClient )
								oLJMessenger:CheckCommunication()
							EndIf
								
							If oLJCMessageManager:HasError()
								oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCMonitorConnotSelfConnect", 1, STR0005 ) ) //atusx // "N�o foi poss�vel se comunicar com o pr�prio ambiente."
							EndIf												
				 		EndIf
				 		MD3->(DbSkip())
				 	End
			 	EndIf
		 	EndIf
			MD4->(DbSkip())
		End
		
		If !lEnvironmentFound
			oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCMonitorLocalEnvironmentNotFoundInDatabase", 1, STR0006 ) ) //atusx  // "O ambiente configurado no par�metro MV_LJAMBIE n�o foi encontrado no cadastro de ambientes."
		EndIf		
		
		If !lRPCConfigurationFound
			oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCMonitorLocalEnvironmentNotFoundInDatabase", 1, STR0007 ) ) //atusx  // "O ambiente configurado no par�metro MV_LJAMBIE n�o tem a configura��o de comunica��o RPC efetuada."
		EndIf
	Else
		oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCMonitorLocalAmbientNotConfigured", 1, STR0008) ) //atusx  // "O par�metro MV_LJAMBIE n�o est� configurado com o c�digo do ambiente atual."
	EndIf
Return oClient


//--------------------------------------------------------------------------------
/*/{Protheus.doc} MakeXMLStatus()

Grava xml com status das cargas locais (no cliente recebido)

@param oClient cliente

@return Self

@author Vendas CRM
@since 07/08/12
/*/
//--------------------------------------------------------------------------------    
Function MakeXMLStatus(oClient)

Local oLJILConfiguration	:= LJCInitialLoadConfiguration():New()	
Local oGroupStatus			:= Nil
Local oStatus				:= Nil
Local oLJCMessageManager	:= GetLJCMessageManager()
Local nCont := 1  //Contador
Local nMax  := SuperGetMV("MV_LJILQTD", .F., 200)  //Numeros maximo de cargas ativas

If nMax > 1000
	nMax := 1000 //Maximo para nao estourar xml 1 Mb
	LjGrvLog( "Carga","Limite de cargas MV_LJILQTD superior ao permitido foi redefinido para 1.000 cargas ao gerar " + cEmpAnt + "LJCInitialLoadStatus.xml")
EndIf

If oClient <> Nil //quando chama a execucao em outro ambiente precisa dar o prepare enviroment
	RPCSetType(3)		
	// "FRT" > Liberacao de acesso PDV cTree para o modulo FrontLoja
	RPCSetEnv( oClient:cCompany, oClient:cBranch,Nil,Nil,"FRT")
	LjGrvLog( "Carga","Preparou ambiente")
EndIf

oGroupStatus := LJCInitialLoadGroupStatus():New()

If AliasInDic("MBY") //protecao caso nao tenha a MBY
	DbSelectArea("MBY")
	DbSetOrder(1) //MBY_FILIAL+MBY_CODGRP              
	If DbSeek(xFilial("MBY"))

		//Posiciona no ultimo registro
		If MBY->(!EOF())
			MBY->(DbGoTo(MBY->(LastRec())+1))
			MBY->(DbSkip(-1))
		EndIf
	
		While MBY->(!BOF()) .AND. MBY->MBY_FILIAL == xFilial("MBY") .AND. (nCont <= nMax)		
			oStatus := LJCInitialLoadStatus():New(MBY_CODGRP, MBY_STATUS, MBY_ORDEM, MBY_INTINC)
			oGroupStatus:AddStatus(oStatus)
			++nCont
			MBY->( DbSkip(-1) )
		EndDo
		
		LJPersistObject( oGroupStatus:ToXML(.F.), cEmpAnt + "LJCInitialLoadStatus", oLJILConfiguration:GetILPersistPath() )

	EndIf
Else
	oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCInitialLoadLoaderTableDoesntExist", 1,STR0002 ) ) // Atusx // 
EndIf

If oClient <> Nil
	RPCClearEnv()	
EndIf

Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} ExistNextOrder()

Verifica se a proxima carga necessaria (de acordo com a ordem sequencial de cargas
incrementais) existe

@param oRequest requisicao com os dados das cargas a serem aplicadas

@return lRet .T. se existir, .F. se nao existir

@author Vendas CRM
@since 07/08/12
/*/
//-------------------------------------------------------------------------------- 
Function ExistNextOrder(oRequest, lVerOrder)
Local lExistNextOrder 	:= .F.
Local cLastOrder		:= PADR("",10,"0")
Local nI				:= 0
Local oGroupsLoad 	:= oRequest:oResult

Default lVerOrder := .T.

If lVerOrder

	If oRequest:lDownload

		cLastOrder := LJILLastOrderLoad()

		For nI:= 1 to Len(oGroupsLoad:aoGroups)
		   If Val(oGroupsLoad:aoGroups[nI]:cOrder) == (Val( cLastOrder ) + 1)
		        lExistNextOrder := .T.
		        Exit
		   EndIf
		Next nI
		
	Else //se nao for para fazer download, nao precisa avaliar a existencia da proxima carga no servidor.
		lExistNextOrder := .T.
	EndIf

Else
	lExistNextOrder := .T.
EndIf

LjGrvLog( "Carga","Verifica se existe a proxima ordem " , lExistNextOrder)

Return lExistNextOrder


//--------------------------------------------------------------------------------
/*/{Protheus.doc} ValidXMLVersion()

verifica se o xml esta na versao correta

@param cXMLSerialized xml a ser validado
@param cClass classe serializada

@return lValid .T. , se a versao � valida 

@author Vendas CRM
@since 07/08/12
/*/
//-------------------------------------------------------------------------------- 
Function ValidXMLVersion(cXMLSerialized, cClass)
Local oLJCMessageManager	:= GetLJCMessageManager()
Local lValid 				:= .F.

//avalia se o xml esta atualizado. 
//Para cada versao nova de xml deve ser colocado a regra que considera o xml atualizado (verificar os campos novos ou os campos retirados)
Do Case
	Case Lower(cClass) == Lower('LJCInitialLoadMakerResult')
		lValid := (At("AOGROUPS",Upper(cXMLSerialized)) > 0)

	Case Lower(cClass) == Lower('LJCINITIALLOADSTATUS')
		lValid := (At("AOSTATUS",Upper(cXMLSerialized)) > 0)
EndCase

If !lValid
	oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJILXMLVersion", 1, STR0009 + cClass + STR0010 ) ) // atusx
EndIf

Return lValid


//--------------------------------------------------------------------------------
/*/{Protheus.doc} GetQtyLoad()

Pega a quantidade limite de cargas ativas do ambiente (MV_LJILQTD) 

@return quantidade limite de cargas ativas 

@author Vendas CRM
@since 07/08/12
/*/
//-------------------------------------------------------------------------------- 
Function GetQtyLoad(cSerializedClient)
Local nQty := 250

// Trecho retirado para evitar ficar dando prepare enviroment
// Isso pq no custo benenficio eh melhor eu nao usufruir da informacao do parametro do que ficar todo 
// momento os PDVs fazendo requisicoes de carga abrindo o ambiente so para pegar esse conteudo 
// Para consultar o trecho antigo , basta pegar um fonte inferior a 22/08/15

Return nQty

/*������������������������������������������������������������������������������������������
���     Classe: � LJCInitialLoadPersistProgress     � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Classe que efetua a grava��o do progresso de carga em um arquivo.      ���
���             �                                                                        ���
������������������������������������������������������������������������������������������*/
Class LJCInitialLoadPersistProgress
	Method New()
	Method Update()
EndClass

/*������������������������������������������������������������������������������������������
���     M�todo: � New                               � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Construtor.                                                            ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Self                                                                   ���
������������������������������������������������������������������������������������������*/
Method New() Class LJCInitialLoadPersistProgress
Return
                         
/*������������������������������������������������������������������������������������������
���     M�todo: � Update                            � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Recebe a atualiza��o do progresso da carga.                            ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � oLoadProgress: Objeto LJCInitialLoadProgress com o progresso.          ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
������������������������������������������������������������������������������������������*/
Method Update( oLoadProgress ) Class LJCInitialLoadPersistProgress
	LJILSaveProgress( oLoadProgress )	
Return  
