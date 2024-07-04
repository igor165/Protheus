#include "SigaWF.ch"   
#include "Protheus.ch"
#include "WFQueue.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} QueueSendMail
Função que devolve as filas ativas para envio do workflow.
/*/
//-------------------------------------------------------------------   
Function getQueues()
	Local cQueueName := "QUEUE" 
	Local nQueueIndex := 1       
	Local aQueuesReturn := {}  
	Local lInJob := IsBlind()
		
   	dbSelectArea("WFQ")
	While( ! ("WFQ")->( EOF() ) )   
    	if( WFQ->WFQ_ATIVA ) 
			cQueueName := "QUEUE" + AllTrim( Str( nQueueIndex ) )
			&("oMailbox"+cValtochar(nQueueIndex)) := TWFMail():New( { rTrim(WFQ->WFQ_FEMP), trim(WFQ->WFQ_FFIL) } )
			&("oMailbox"+cValtochar(nQueueIndex)) := &("oMailbox"+cValtochar(nQueueIndex)):GetMailBox( alltrim(WFQ->WFQ_EMAIL))
			&("oMailbox"+cValtochar(nQueueIndex)):cQueueName := rTrim(cBiStr(WFQ->WFQ_NOME))
			&("oMailbox"+cValtochar(nQueueIndex)):cRootDir := "\workflow\emp" + rTrim(WFQ->WFQ_FEMP) + "\mail" 
			&("oMailbox"+cValtochar(nQueueIndex)):cRootPath := "\workflow\emp" + rTrim(WFQ->WFQ_FEMP) + "\mail\" + alltrim(WFQ->WFQ_EMAIL)		 
	 		&("oMailbox"+cValtochar(nQueueIndex)):cRootDir := Iif(!lInJob, AllTrim(WFQ->WFQ_ROOT), '') + &("oMailbox"+cValtochar(nQueueIndex)):cRootDir
	 		&("oMailbox"+cValtochar(nQueueIndex)):cRootPath := Iif(!lInJob, AllTrim(WFQ->WFQ_ROOT), '') + &("oMailbox"+cValtochar(nQueueIndex)):cRootPath			
	
			aAdd( aQueuesReturn , &("oMailbox" + cValToChar(nQueueIndex)) )    
			nQueueIndex++
		endIf
		WFQ->( DBSkip() )			
   	End   
	WFQ->( DBCloseArea() )	
Return aQueuesReturn   

//-------------------------------------------------------------------
/*/{Protheus.doc} QueueSendMail
Rotina especifica para envio de mensagens do workflow via fila.

@param 	pcEmpresa 	Empresa para conexão
@param	pcFilail	Filial para conexão
@param 	pcQueueName	Nome da fila que está sendo processada
/*/
//-------------------------------------------------------------------   
FUNCTION QueueSendMail( pcEmpresa, pcFilial, pcQueueName )
   	Default pcEmpresa 	:= "01"
   	Default pcFilial 	:= "01"
   	Default pcQueueName := ""
      
   	WFPrepEnv( pcEmpresa, pcFilial )               
   	While .T.
		WFSendMail( {pcEmpresa, pcFilial}, .F. , rtrim(pcQueueName) )
 	  	Sleep(60000)
	EndDo
RETURN NIL           

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckQueues
Função de monitoramento das filas de email.

@param	pcEmpresa 	Empresa para conexão
@param	pcFilail	Filial para conexão
/*/
//-------------------------------------------------------------------          
Function CheckQueues(pcEmpresa, pcFilial)
	Local oRpcConnection
	Local oStream 	:= WFStream()
	Local lFila 	:= .F.
	Local nFila		:= 0
	Local nFilaOut	:= 0  
	
   	WFPrepEnv( pcEmpresa, pcFilial )

	lFila := xBIConvTo("L", WFGetMV("MV_WFFILA", .F.) )	// Habilitar o novo recurso de utilização de filas de envio de email
	
	If( lFila )
	  	dbSelectarea("WFQ")
	  	While( ! ("WFQ")->( EOF() ) )
			nFila++  
			if( WFQ->WFQ_ATIVA ) 
				oRpcConnection := TRPC():New( alltrim(WFQ->WFQ_FENV) )
		  		if !(oRpcConnection:Connect( alltrim(WFQ->WFQ_HOST), WFQ->WFQ_PORTA ))                                                     
					WFConOut( STR0001 + alltrim(WFQ->WFQ_NOME), oStream, .F., .F. ) //"Fila:"
					WFConOut( STR0002, oStream, .F., .F. ) //"Status: Servidor inativo"
					WFConOut( STR0003, oStream, .F., .F. ) //"Esta fila foi desativada." 
					WFConOut( STR0004, oStream, .F., .F. ) //"ATENÇÃO! Pode(m) haver email(s) pendente(s) nesta fila! "
					WFConOut( STR0005, oStream, .F., .F. ) //"Para reativá-la, inicie o servidor da fila , acesse o Cadastro de Filas de Email, selecione-a e clique em 'Ativar'"

					if RecLock("WFQ", .F.)
						WFQ->WFQ_ATIVA := .F.
						WFQ->(MSUnLock())
					EndIf
					nFilaOut++
				Else
					oRpcConnection:Disconnect()	
				EndIf
			Else
				nFilaOut++
		    EndIf		
			WFQ->( DBSkip() )			
		End  
		
		// Se não houver nenhuma fila ativa, desabilita o envio por fila.      
		If nFilaOut == nFila
			lFila := .F.
			WFSetMV( "MV_WFFILA", lFila )
			WFConOut( "", oStream, .F., .F. )
			WFConOut( STR0006, oStream, .F., .F. ) //"Não há nenhuma fila ativa! Desativando funcionalidade."
			WFConOut( STR0007, oStream, .F., .F. ) //"Para reativá-la, ative as filas desejadas , acesse 'Parametros WF' e marque a opção 'Utilizar filas de envio de email'"
		EndIf
		      
		if !Empty(oStream:cBuffer)
			WFNotifyAdmin( , WF_NOTIFY, oStream:GetBuffer( .T. ), , .T. ) 
		EndIf
              		       
		WFQ->( DBCloseArea() )	       
	Else 
		WFConOut(STR0008) //"A funcionalidade de filas de envio de email está desativada."
	EndIf
Return