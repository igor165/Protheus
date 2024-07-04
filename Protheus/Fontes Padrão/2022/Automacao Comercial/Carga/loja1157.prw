#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1157.CH"
#Include "rwmake.ch"                                        
#Include "TbiConn.ch"

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Fun��o: � LOJA1157                          � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Abre o assist�nte de carregamento de carga.                            ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Function LOJA1157()
	Local oLJInitialLoadLoaderWizard	:= Nil
	Local oClient						:= LJCInitialLoadClient():New()
	Local lImport						:= .F.
	Local lDownload						:= .F.
	Local lActInChildren				:= .F.
	Local lKillOtherThreads				:= .F.
	
	LjGrvLog( "Carga","ID_INICIO")
	
	oClient:cLocation		:= GetMV( "MV_LJILLIP",,"" )
	oClient:nPort			:= Val( GetMV( "MV_LJILLPO",,"" ) )
	oClient:cEnvironment	:= GetMV( "MV_LJILLEN",,"" )
	oClient:cCompany		:= GetMV( "MV_LJILLCO",,"" )
	oClient:cBranch		:= GetMV( "MV_LJILLBR",,"" )
	lImport				:= If(GetMV( "MV_LJILLIM",,"0" )=="1", .T., .F.)
	lDownload				:= If(GetMV( "MV_LJILLDO",,"0" )=="1", .T., .F.)	
	lActInChildren		:= If(GetMV( "MV_LJILLAC",,"0" )=="1", .T., .F.)
	lKillOtherThreads		:= If(GetMV( "MV_LJILLKT",,"0" )=="1", .T., .F.)
		
	oLJInitialLoadLoaderWizard := LJCInitialLoadLoaderWizard():New( oClient, lImport, lDownload, lActInChildren, lKillOtherThreads )
		
	If oLJInitialLoadLoaderWizard:Show()
		PutMV( "MV_LJILLIP", AllTrim( oLJInitialLoadLoaderWizard:oClient:cLocation ) )
		PutMV( "MV_LJILLPO", AllTrim( Str( oLJInitialLoadLoaderWizard:oClient:nPort ) ) )
		PutMV( "MV_LJILLEN", AllTrim( oLJInitialLoadLoaderWizard:oClient:cEnvironment ) )	
		PutMV( "MV_LJILLCO", AllTrim( oLJInitialLoadLoaderWizard:oClient:cCompany ) )		
		PutMV( "MV_LJILLBR", AllTrim( oLJInitialLoadLoaderWizard:oClient:cBranch ) )		
		PutMV( "MV_LJILLIM", If(oLJInitialLoadLoaderWizard:lImport,"1","0") )	
		PutMV( "MV_LJILLDO", If(oLJInitialLoadLoaderWizard:lDownload,"1","0") )	
		PutMV( "MV_LJILLAC", If(oLJInitialLoadLoaderWizard:lActInChildren,"1","0") )	
		PutMV( "MV_LJILLKT", If(oLJInitialLoadLoaderWizard:lKillOtherThreads,"1","0") )									
	EndIf
	
	LjGrvLog( "Carga","ID_FIM")
	
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Fun��o: � LOJA1157Express                   � Autor: Vendas CRM � Data: 23/10/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Abre o assist�nte de carregamento de carga em modo express.            ���
���             � O modo express for�a a atualiza��o da carga, quando h� uma mais nova.  ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Function LOJA1157Express()
	Local oLJInitialLoadLoaderWizard	:= Nil
	Local oLJMessenger					:= Nil
	Local oLJCMessageManager			:= GetLJCMessageManager()	
	Local oClient						:= LJCInitialLoadClient():New()
	Local lImport						:= .F.
	Local lDownload						:= .F.
	Local lActInChildren				:= .F.
	Local lKillOtherThreads				:= .F.
	Local cLocalLastOrder				:= ""
	Local cRemoteLastOrder				:= ""
	Local lAutomatic					:= SuperGetMV("MV_LJILAUT", .F., .F.) //determina se executa o carregamento express de forma automatica
	
	LjGrvLog( "Carga","ID_INICIO")
		
	oClient:cLocation		:= GetMV( "MV_LJILLIP",,"" )
	oClient:nPort			:= Val( GetMV( "MV_LJILLPO",,"" ) )
	oClient:cEnvironment	:= GetMV( "MV_LJILLEN",,"" )
	oClient:cCompany		:= GetMV( "MV_LJILLCO",,"" )
	oClient:cBranch			:= GetMV( "MV_LJILLBR",,"" )
	lImport					:= If(GetMV( "MV_LJILLIM",,"1" )=="1", .T., .F.)
	lDownload				:= If(GetMV( "MV_LJILLDO",,"1" )=="1", .T., .F.)	
	lActInChildren			:= If(GetMV( "MV_LJILLAC",,"0" )=="1", .T., .F.)
	lKillOtherThreads		:= If(GetMV( "MV_LJILLKT",,"0" )=="1", .T., .F.)
	
	oLJMessenger := LJCInitialLoadMessenger():New( oClient )	
	
	If !oLJCMessageManager:HasError()		
		MsgRun(STR0013, STR0014, { || oLJMessenger:CheckCommunication() } ) // "Testando conex�o para verifica��o de carga." "Aguarde..."
		
		If !oLJCMessageManager:HasError()
			cLocalLastOrder := LJILLastOrderLoad()
			cRemoteLastOrder:= oLJMessenger:GetILLastOrderLoad()	
						
			If !oLJCMessageManager:HasError()
				If cRemoteLastOrder > cLocalLastOrder
					oLJInitialLoadLoaderWizard := LJCInitialLoadLoaderWizard():New( oClient, lImport, lDownload, lActInChildren, lKillOtherThreads )
					oLJInitialLoadLoaderWizard:ShowExpress(lAutomatic)
				EndIf
			EndIf
		EndIf
	EndIf 
	
	oLJCMessageManager:Clear()		
	
	LjGrvLog( "Carga","ID_FIM")		
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Fun��o: � LOJA1157Job                       � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Executa o carregamento de carga atrav�s de JOB                         ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cLocation: Endere�o IP ou nome do computar.                            ���
���             � nPort: Porta.                                                          ���
���             � cEnvironment: Ambiente.                                                ���
���             � cCompany: Empresa.                                                     ���
���             � cBranch: Filial.                                                       ���
���             � lImport: Se � para efetuar a importa��o.                               ���
���             � lDownload: Se � para efetuar a baixa.                                  ���
���             � lActInChildren: Se � para replicar a��o no dependentes.                ���
���             � lKillOtherThreas: Se � para derrubar os processos.                     ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � NIl                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Function LOJA1157Job( cLocation, nPort, cEnvironment, cCompany, cBranch, lImport, lDownload, lActInChildren, lKillOtherThreads, lOnlyIfNewer, aEntireLoad )
	Local oLJCMessageManager			:= GetLJCMessageManager()
	Local oLJMessenger					:= Nil
	Local oLJILResult					:= Nil
	Local cWebFileServer				:= ""
	Local oClient						:= Nil
	Local oConsoleUI					:= LJCInitialLoadLoaderConsoleUI():New()
	Local oRequest						:= Nil
	Local oLocalResult					:= LJILLoadResult()
	Local oSelectorLoad				:= nil
	//Local oLocalClient					:= GetLocalClient()
	
	Default lOnlyIfNewer 			:= .T.
	Default aEntireLoad				:= {} //array com a lista de codigos de grupos das cargas inteiras para atualizar

	LjGrvLog( "Carga","ID_INICIO")
		
	oClient := LJCInitialLoadClient():New( cLocation, nPort, cEnvironment, cCompany, cBranch )
	
	oLJMessenger := LJCInitialLoadMessenger():New( oClient )
	
	If !oLJCMessageManager:HasError()
		oLJMessenger:CheckCommunication()
	
		If !oLJCMessageManager:HasError()	
			oLJILResult := oLJMessenger:GetILResult()
			
				If !oLJCMessageManager:HasError()	
					cWebFileServer := oLJMessenger:GetFileServerURL()
			
					If !oLJCMessageManager:HasError()
									
						oRequest := LJCInitialLoadRequest():New(oLJILResult , oClient, lDownload, lImport, lActInChildren, lKillOtherThreads, Nil, .F. )
						oSelectorLoad := LJCInitialLoadSelector():New(oLJILResult, oRequest)	
						oSelectorLoad:MarkIncLoad(,.T.) //seleciona automaticamente as cargas necessarias para deixar o ambiente atualizado conforme opcao de acao (importar ou apenas baixar)
						
						oSelectorLoad:MarkEntire(aEntireLoad, lOnlyIfNewer) 
						
						LoadProcess( oRequest, cWebFileServer, oConsoleUI )
						
					EndIf
				EndIf
			
		EndIf
	EndIf	
	
	If oLJCMessageManager:HasMessage()
		oLJCMessageManager:Show( STR0001 ) // "Houve alguma mensagem durante a importa��o da carga."
		oLJCMessageManager:Clear()
	EndIf	
	
	LjGrvLog( "Carga","ID_FIM")
	
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � LJ1157PSS� Autor �  Vendas CRM           � Data: 07/08/12  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Atualiza as senhas do usuario (SIGAPSS.SPF)                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LJ1157PSS(cRPCServer,nRPCPort,cRPCEnv)
Local lLockOk 					:= .F.
Local bMTrans 					:= ""
Local oServerRPC				:= nil
Local oLJCMessageManager		:= GetLJCMessageManager()
Local cSeparator 				:= Chr(13) + Chr(10)
Local cMessage					:= ""
Local bOriginalErrorBlock		:= Nil
Local nSec1						:= 0
Local nSec2						:= 0

Default cRPCServer	:= ""
Default nRPCPort	:= 0
Default cRPCEnv		:= ""
// "Front Loja: Iniciando a atualizacao das Senhas..."
ConOut("Front Loja: " + STR0015)
LjGrvLog( "Carga",STR0015)

bOriginalErrorBlock := ErrorBlock( {|oErr| oLJCMessageManager := GetLJCMessageManager(), oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCLoaderGetSincSigapss", 1, oErr:ErrorStack + oErr:ErrorEnv ) ) } )	
Begin Sequence

	If MPIsUsrInDB() // Se os usuarios est�o no banco

		nSec1 := Seconds()
		If MPUsrSync( "", "", cRPCEnv,cRPCServer,nRPCPort,@cMessage )
			// "Front Loja: Atualiza��o de senhas finalizada."
			ConOut("Front Loja: " + STR0016) 	//Atualizacao das Senhas finalizada.
			LjGrvLog( "Senhas",STR0016) 		//Atualizacao das Senhas finalizada.
		Else
			cMessage += cSeparator
			cMessage += "Location: " + cRPCServer + cSeparator
			cMessage += "Port: " + AllTrim(Str(nRPCPort)) + cSeparator
			cMessage += "Environment: " + cRPCEnv + cSeparator
			oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCLoaderGetSincSigapss", 1,cMessage ) )
			ConOut("Front Loja: " + cMessage)
			ConOut("Front Loja: " + STR0017)
			LjGrvLog( "Senhas",cMessage)
			LjGrvLog( "Senhas",STR0017)
		Endif
		nSec2 := Seconds()-nSec1

		Conout("-------------------------")
		ConOut("Tempo de atualiza��o de senhas: " + Str(nSec2))
		LjGrvLog( "Senhas",  "Tempo de atualiza��o de senhas: " + AllTrim(Str(nSec2)) )
		Conout("-------------------------")

	Else

		oServerRPC := TRPC():New(cRPCEnv)
		If oServerRPC:Connect(cRPCServer, nRPCPort) 
			If !PSWGetSinc(oServerRPC)
				// "Front Loja: Erro ao finalizar a atualizacao do arquivo de Senhas."
				oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCLoaderGetSincSigapss", 1, STR0017 ) ) // "Erro ao finalizar a atualizacao do arquivo de Senhas"
				ConOut("Front Loja: " + STR0017)	
				LjGrvLog( "Carga",STR0017)	
			Else
				// "Front Loja: Atualiza��o de senhas finalizada."
				ConOut("Front Loja: " + STR0016)	//Atualizacao das Senhas finalizada.
				LjGrvLog( "Carga",STR0016)			//Atualizacao das Senhas finalizada.
			EndIf
		Else
			cMessage := "Location: " + cRPCServer + cSeparator
			cMessage += "Port: " + AllTrim(Str(nRPCPort)) + cSeparator
			cMessage += "Environment: " + cRPCEnv + cSeparator
			// "Front Loja: Erro ao finalizar a atualizacao do arquivo de Senhas."
			oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCLoaderGetSincSigapss", 1, "N�o foi poss�vel conectar em: " + cSeparator + cMessage ) ) // "N�o foi poss�vel conectar em: " 						
			ConOut("Front Loja: " + STR0017)
			LjGrvLog( "Carga",STR0017)
		EndIf

	EndIf
End Sequence
ErrorBlock( bOriginalErrorBlock )

Return



/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Classe: � LJCInitialLoadLoaderConsoleUI     � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Exibe o progresso do carregamento da carga no console.                 ���
���             �                                                                        ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Class LJCInitialLoadLoaderConsoleUI
	Method New()
	Method Update()
	Method FormatSize()
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
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method New() Class LJCInitialLoadLoaderConsoleUI
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � Update                            � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Exibe no console o progresso do carregamento da carga.                 ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � oLJInitialLoadLoaderProgress: Objeto LJCInitialLoadLoaderProgress.     ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method Update( oLJInitialLoadLoaderProgress ) Class LJCInitialLoadLoaderConsoleUI
	Local oFilesProgress 	:= oLJInitialLoadLoaderProgress:oFilesProgress
	Local oDownloadProgress := Nil
	Local oTablesProgress 	:= oLJInitialLoadLoaderProgress:oTablesProgress
	Local cOut				:= ""
	
	If oLJInitialLoadLoaderProgress:nStep == 1
		cOut += STR0002 // "Conectado"
	ElseIf oLJInitialLoadLoaderProgress:nStep == 2
		cOut += STR0003 // "Iniciando carga"
	ElseIf oLJInitialLoadLoaderProgress:nStep == 3
		cOut += STR0004 + " " // "Baixando carga:"
		If oFilesProgress != Nil
			oDownloadProgress := oFilesProgress:oDownloadProgress
			
			If oDownloadProgress != Nil	
				Do Case
					Case oDownloadProgress:nStatus == 1
						cOut += STR0005 + " - " // "Iniciado"
					Case oDownloadProgress:nStatus == 2
						cOut += STR0006 + " - " // "Baixando"
					Case oDownloadProgress:nStatus == 3
						cOut += STR0007 + " - " // "Finalizado"
					Case oDownloadProgress:nStatus == 4
						cOut += STR0008 + " - " // "Erro"
				End
				
				cOut += Self:FormatSize( oDownloadProgress:NBYTESPERSECOND) + "/s" + " - "
				cOut += Self:FormatSize( oDownloadProgress:NDOWNLOADEDBYTES) + "/" + Self:FormatSize( oDownloadProgress:NTOTALBYTES) + " (" +  AllTrim(Str(Round((oDownloadProgress:NDOWNLOADEDBYTES*100)/oDownloadProgress:NTOTALBYTES,2))) + "%)" + " - "
			EndIf
			
			If Len( oFilesProgress:aFiles ) > 0 .And. oFilesProgress:nActualFile <= Len( oFilesProgress:aFiles )
				cOut += oFilesProgress:aFiles[oFilesProgress:nActualFile] + " (" + AllTrim(Str(oFilesProgress:nActualFile))  + "/" + AllTrim(Str(Len( oFilesProgress:aFiles ))) + ")"
			EndIf	
		EndIf
	ElseIf oLJInitialLoadLoaderProgress:nStep == 4
		cOut += STR0009 + " " // "Importando carga:"
		
		If oTablesProgress != Nil
			Do Case
				Case oTablesProgress:nStatus == 1
					cOut += STR0005 + " - "
				Case oTablesProgress:nStatus == 2
					cOut += STR0010 + " - " // "Descompactando"
				Case oTablesProgress:nStatus == 3
					cOut += STR0011 + " - " // "Importando"
				Case oTablesProgress:nStatus == 4
					cOut += STR0012 + " - " // "Finalizado"
				Case oTablesProgress:nStatus == 5
					cOout += STR0008 + " - " // "Erro"
			EndCase
			
			If Len(oTablesProgress:aTables) > 0 .And. (oTablesProgress:nActualTable >= 0 .And. oTablesProgress:nActualTable <= Len(oTablesProgress:aTables) )
				cOut += oTablesProgress:aTables[oTablesProgress:nActualTable] + " (" + AllTrim(Str(oTablesProgress:nActualTable)) + "/" + AllTrim(Str(Len(oTablesProgress:aTables))) + ")" + " - "
			EndIf
			
			If ValType( oTablesProgress:nActualRecord ) != "U" .And. ValType(oTablesProgress:nTotalRecords) != "U"
				If oTablesProgress:nActualRecord > 0 .And. oTablesProgress:nTotalRecords > 0
					cOut += AllTrim(Str(oTablesProgress:nActualRecord)) + "/" + AllTrim(Str(oTablesProgress:nTotalRecords)) + " (" + AllTrim(Str(Round((oTablesProgress:nActualRecord*100)/oTablesProgress:nTotalRecords,2))) + "%)" + " - "			
				EndIf
			EndIf
			
			If ValType( oTablesProgress:nRecordsPerSecond ) != "U"
				cOut += AllTrim(Str(oTablesProgress:nRecordsPerSecond)) + "r/s" 
			EndIf	
		EndIf
	ElseIf oLJInitialLoadLoaderProgress:nStep == 5
		cOut += STR0012 // "Finalizado"
	ElseIf oLJInitialLoadLoaderProgress:nStep == -1
		cOut += STR0008 // "Erro"
	EndIf	
	ConOut( cOut )
	
	LJILSaveProgress( oLJInitialLoadLoaderProgress )	
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � FormatSize                        � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Formata um valor em bytes em um texto para ser exibida amigavelmente.  ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � nSize: Tamanho em bytes.                                               ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � cRet: Texto amig�vel.                                                  ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method FormatSize( nSize ) Class LJCInitialLoadLoaderConsoleUI
	Local cRet	:= ""

	Do Case
		Case nSize < 1024			
			cRet := Transform(Int(nSize),"9999") + "B"
		Case nSize >= 1024 .And. nSize < 1024*1024
			cRet := Transform(Round(nSize/1024,2),"9999.99") + "KB"
		Case nSize >= 1024*1024 .And. nSize < 1024*1024*1024
			cRet := Transform(Round(nSize/(1024*1024),2),"9999.99") + "MB"			
		Case nSize >= 1024*1024*1024 .And. nSize < 1024*1024*1024*1024
			cRet := Transform(Round(nSize/(1024*1024*1024),2),"9999.99") + "GB"
	EndCase
Return AlLTrim(cRet)