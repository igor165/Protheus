#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "WebDeskIntegration.ch"
#INCLUDE "ECMCONST.CH"
    
//-------------------------------------------------------------------
/*/{Protheus.doc} BIStartTask
Inicializa um processo no TOTVS ECM

@param cTpProc		Tipo de processo
@param cCodPrt		Código equivalente no Microsiga Protheus
@param cProcessId	Identificação do processo no TOTVS ECM
@param cComments	Comentário
@param cCardData	Dados que irão ao formulário (em formato XML)
@param aAttach		Anexo no formato {<descrição>, <nome físico>, <conteúdo>}
@param lComplete	Indica se completa ou não a tarefa
@param nNextTask	Próxima tarefa a ser executada
@param aUsers		Lista com a identificação dos usuários no TOTVS ECM que irão receber a atribuição da tarefa
@param acUser		Usuário (ECM) que irá executar a ação
@param acPassword	Senha no formato MD5:xxxxxxx
@author  BI TEAM
@version P10 R1.3
@since   22/07/2009
@return  aRet 
				em caso de sucesso: a[1] { 'iTask', <ID da proxima tarefa> }
										  a[2] { 'iProcess', <Código da instância do processo> }
										  a[3] { 'cDestino', <Nome do usuário da próxima tarefa> }

				em caso de falha: a[n] { 'ERROR', <mensagem de erro> }

@obs	- Função para efetuar a integração do Microsiga Protheus com ECM 
		- Antes de executar a função deve verificar se o ambiente(Prepare Environment) foi inicializado  				
		- Cadastrar o endereço do WebService(TOTVS ECM) no Parametro(MV) "MV_ECMWS" no configurador 
		- Cadastrar a equivalência do código da empresa no Parâmetro(MV) "MV_ECMEMP" no configurador
		- Se forem omitidos usuário e senha, será adotado o usuário logado atualmente no microsiga protheus
/*/
//-------------------------------------------------------------------    
function BIStartTask( cTpProc, cCodPrt, cProcessId, cComments, cCardData, aAttach, lComplete, nNextTask, aUsers, acUser, acPassword )
	local aRet 				:= {}
	local cUser 			:= ""
	local cPassword 		:= ""  
	local cAux				:= ""                           
	local cTmpPwd			:= ""
	local nCompanyId 		:= 0
	local nPosicao			:= 0
		
	default nNextTask		:= 0
	default aAttach 		:= {}
	default aUsers			:= {}
	default lComplete		:= .T.
	

	cAux := biPrt2Ecm( cTpProc, cCodPrt )
	
	if empty( cAux )
		if ( valtype( acUser ) == "U" ) .and. ( valtype( acPassword ) == "U" )
			cUser :=  __cUserID 
			
			cTmpPwd := PswMD5GetPass( __cUserID )
			
			if !Empty( cTmpPwd ) .and. valtype( cTmpPwd ) == "C"
				cPassword := "MD5:" + cTmpPwd
			endif
		else
			cUser := acUser
			
			if ( len( acPassword ) == 36 ) .and. ( left( acPassword, 4 ) == "MD5:" )
				cPassword := acPassword
			else
				cPassword := "MD5:" + md5( acPassword )
			endif
		endif
	    
		if !Empty( cPassword )
			nCompanyId := getMv( "MV_ECMEMP", .F. ,"" )
			if len( alltrim( nCompanyId ) ) > 0
				nCompanyId	:= val( ncompanyId ) 
				//-------------------------------------------------- 
	            // Executa a tarefa no ECM. 
	            //--------------------------------------------------
		  		aRet 		:= _BIStartTask( Alltrim( cUser ), Alltrim( cPassword ), nCompanyId, cProcessId, cComments, cCardData, aAttach, lComplete, nNextTask, aUsers )
	            //-------------------------------------------------- 
	            // Recupera o código do processo do ECM. 
	            //--------------------------------------------------
	            nPosicao 	:=  aScan( aRet, { |x| Upper( x[1] ) == "IPROCESS" } )
	            //-------------------------------------------------- 
	            // Grava na tabela de equivalência (WFE) do Protheus. 
	            //--------------------------------------------------  
	     		If ( nPosicao > 0 )
	       			if !biPrtEcm( cTpProc, cCodPrt, aRet[nPosicao][2] )
						BISetLogEvent(ECM_EV_LEVEL_ERROR, "StartProcess", STR0015 + CRLF + STR0016 ) //###"Erro ao gravar tabela de equivalencia"  + "Chave duplicada"
						aAdd( aRet, { "ERROR", STR0015 + CRLF + STR0016 } )
					endif		
	     		EndIf 
			else 
				BISetLogEvent(ECM_EV_LEVEL_ERROR, "StartProcess", STR0012) //###"Parametro (MV) MV_ECMEMP nao configurado"

				aAdd( aRet, { "ERROR", STR0012 } )
			endif
		else
			BISetLogEvent(ECM_EV_LEVEL_ERROR, "StartProcess", STR0013 + CRLF + STR0014) //###"Usuário não pode inicializar tarefas." "Usuários administradores não podem realizar esta operação"
			
			aAdd( aRet, { "ERROR", STR0013 + CRLF + STR0014 } )
		endif
	else
		BISetLogEvent(ECM_EV_LEVEL_ERROR, "StartProcess", STR0015 + CRLF + STR0016 ) //###"Erro ao gravar tabela de equivalencia" "Chave duplicada"

		aAdd( aRet, { "ERROR", STR0015 + CRLF + STR0016 } )
	endif
			
return aRet
                      

//-------------------------------------------------------------------
/*/{Protheus.doc} _BIStartTask
Inicializa um processo no TOTVS ECM

@protected
@param cUser		Usuário (ECM) que irá executar a ação
@param cPassword	Senha no formato MD5:xxxxxxx
@param nCompanyId	Empresa no TOTVS ECM
@param cProcessId	Identificação do processo no TOTVS ECM
@param cComments	Comentário
@param cCardData	Dados que irão ao formulário (em formato XML)
@param aAttach		Anexo no formato {<descrição>, <nome físico>, <conteúdo>}
@param lComplete	Indica se completa ou não a tarefa
@param nNextTask	Próxima tarefa a ser executada
@param aUsers		Lista com a identificação dos usuários no TOTVS ECM que irão receber a atribuição da tarefa
@author  BI TEAM
@version P10 R1.3
@since   22/07/2009
@return  aRet 
				em caso de sucesso: a[1] { 'iTask', <ID da proxima tarefa> }
										  a[2] { 'iProcess', <Código da instância do processo> }
										  a[3] { 'cDestino', <Nome do usuário da próxima tarefa> }

				em caso de falha: a[n] { 'ERROR', <mensagem de erro> }

/*/
//-------------------------------------------------------------------    
static function _BIStartTask(cUser, cPassword, nCompanyId, cProcessId, cComments, cCardData, aAttach, lComplete, nNextTask, aUsers)
	local obj 				:= WSXMLWorkflowEngineServiceService():new()  
	local oProcessAttach	:= obj:oWSstartProcessattachments
	local oUsers 			:= obj:oWSstartProcesscolleagueIds
	local oAppointment	:= obj:oWSstartProcessappointment

	local cUrlWS			:= "" 
	local cCriptCard		:= ""
	
	local oTmp 				:= nil
	local oAttach 			:= nil

	local aRet				:= {}
	
	local cRetITask		:= ""
	local cRetIProc		:= ""
	local cRetIDest		:= ""  
	
	local nPos				:= 0
	
	default aAttach 		:= {}
	default aUsers			:= {}
	default nNextTask		:= 0
	default lComplete		:= .T.

	cUrlWS := getMv("MV_ECMWS",.f.,"")

	if len(alltrim(cUrlWS)) > 0
		cUrlWS := cUrlWS + "/XMLWorkflowEngineService"

		obj:_URL := cUrlWS

    	BISetLogEvent(ECM_EV_LEVEL_INFO, "StartProcess", STR0008 + ": " + cUrlWS) //###"Conectando no WS"

		if ECM_DEBUG
			wsdldbglevel(2)
		endif

		if len( aAttach ) > 0
			//Anexar arquivo
			oTmp := XMLWorkflowEngineServiceService_processAttachmentDto():New()
			oTmp:nattachmentSequence := 1
			oTmp:ldeleted := .F.
			oTmp:lnewAttach := .T.
			oTmp:noriginalMovementSequence := 1
			oTmp:cpermission := "3"
			oTmp:nprocessInstanceId := 0
			oTmp:nversion := 0
			
			oTmp:ccolleagueId := cUser
			oTmp:ncompanyId := nCompanyId
			oTmp:cdescription := aAttach[ECM_FILE_DESC]
			oTmp:cfileName := aAttach[ECM_FILE_NAME]
			
			oAttach := XMLWorkflowEngineServiceService_attachment():New()
			oAttach:lattach := .T.
			oAttach:ldescriptor := .F.
			oAttach:lediting := .T.
			oAttach:cfileName := aAttach[ECM_FILE_NAME]
			oAttach:cfilecontent := aAttach[ECM_FILE_CONT]

			aAdd( oTmp:oWSattachments, oAttach )

			aAdd( oProcessAttach:oWSitem, oTmp )
		endif

		aEval( aUsers, {|x| aAdd( oUsers:citem, x )} )
		
		cCriptCard := biCript( cCardData )

		if obj:StartProcess( cUser				; // Usuario integração
 								 , cpassword		; // Senha integracao
								 , ncompanyId		; // Codigo da empresa integracao
								 , cprocessId		; // Nome do processo workflow
								 , nNextTask		; // Proxima atividade. Passando zero ele calcula a proxima atividade automaticamente
								 , oUsers			; // StringArray com a lista de usuarios que vão receber a tarefa
								 , ccomments		; // Cometario da tarefa
								 , cUser				; // Usuario que executou o processo Workflow
								 , lComplete		; // Completa ou não a atividade
								 , oProcessAttach	; // Anexos
								 , cCriptCard		; // Dados da ficha (em formato gzip + base64)
								 , oAppointment	; // Apontamentos
								 , .F. )				  // Modo manager

			aEval( obj:oWSstartProcessresult:oWsItem, { |x| aAdd( aRet, { x:cItem[1], x:cItem[2] } ) } )

			nPos := aScan( aRet, { |x| Upper( x[1] ) == "ERROR" } )
			
			if nPos == 0
				BISetLogEvent(ECM_EV_LEVEL_INFO, "StartProcess", STR0009 + ": " + cprocessId) //###"Processo iniciado com sucesso"
			else
				BISetLogEvent(ECM_EV_LEVEL_ERROR, "StartProcess", STR0010 + ": " + cprocessId + CRLF + aRet[nPos][2] ) //###"Processo iniciado com erro"
			endif
		else                                                                    
			BISetLogEvent(ECM_EV_LEVEL_ERROR, "StartProcess", STR0010 + ": " + cprocessId + " - " + getWscError()) //###"Processo iniciado com erro"
			
			aAdd( aRet, { "ERROR", STR0010 + ": " + cprocessId + " - " + getWscError() } ) //###"Processo iniciado com erro"
		endif
	else
		BISetLogEvent(ECM_EV_LEVEL_ERROR, "StartProcess", STR0011) //###"Parametro (MV) MV_ECMWS nao configurado"
		
		aAdd( aRet, { "ERROR", STR0011 } )
	endif	   

return aRet



//-------------------------------------------------------------------
/*/{Protheus.doc} BIGetCardData
Retorna um formulário do TOTVS ECM (XML)

@param axProcessId	Código da instância do processo no TOTVS ECM
@param acUser			Usuário (ECM) que irá executar a ação
@param acPassword		Senha no formato MD5:xxxxxxx
@author  BI TEAM
@version P10 R1.3
@since   22/07/2009
@return  cRet 
				em caso de sucesso: XML com os dados do formulário no TOTVS ECM
				em caso de falha: a[1] { 'ERROR', <mensagem de erro> }

/*/
//-------------------------------------------------------------------    
function BIGetCardData( axProcessId, acUser, acPassword )
	local cRet			:= ""
	local cUser			:= ""
	local cPassword	:= ""
	local nCompanyId	:= 0
	
	local cTmpPwd		:= ""

	if ( valtype( acUser ) == "U" ) .and. ( valtype( acPassword ) == "U" )
		cUser := __cUserID

		cTmpPwd := PswMD5GetPass( __cUserID )
		
		if !Empty( cTmpPwd ) .and. valtype( cTmpPwd ) == "C"
			cPassword := "MD5:" + cTmpPwd
		endif
	else
		cUser := acUser

		if ( len( acPassword ) == 36 ) .and. ( left( acPassword, 4 ) == "MD5:" )
			cPassword := acPassword
		else
			cPassword := "MD5:" + md5( acPassword )
		endif
	endif
    
	if !Empty( cPassword )
		nCompanyId := getMv( "MV_ECMEMP", .F. ,"" )
		if len( alltrim( nCompanyId ) ) > 0
			nCompanyId := val( ncompanyId )

	  		cRet := _BIGetCardData( Alltrim( cUser ), Alltrim( cPassword ), nCompanyId, axProcessId )
		else 
			BISetLogEvent(ECM_EV_LEVEL_ERROR, "getInstanceCardData", STR0012) //###"Parametro (MV) MV_ECMEMP nao configurado"

			cRet := {}
			aAdd( cRet, { "ERROR", STR0012 } )
		endif
	else
		BISetLogEvent(ECM_EV_LEVEL_ERROR, "getInstanceCardData", STR0014) //### "Usuários administradores não podem realizar esta operação"

		cRet := {}
		aAdd( cRet, { "ERROR", STR0014 } )
	endif

return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} _BIGetCardData
Retorna um formulário do TOTVS ECM (XML)

@protected
@param cUser			Usuário (ECM) que irá executar a ação
@param cPassword		Senha no formato MD5:xxxxxxx
@param nCompanyId		Empresa no TOTVS ECM
@param xProcessId		Código da instância do processo no TOTVS ECM
@author  BI TEAM
@version P10 R1.3
@since   22/07/2009
@return  cDecriptCard 
				em caso de sucesso: XML com os dados do formulário no TOTVS ECM
				em caso de falha: a[1] { 'ERROR', <mensagem de erro> }

/*/
//-------------------------------------------------------------------
static function _BIGetCardData(cUser, cPassword, nCompanyId, xProcessId)

	local obj 				:= WSXMLWorkflowEngineServiceService():new()  

	local cUrlWS			:= "" 
	local cDeCriptCard	:= .F.
	
	cUrlWS := getMv("MV_ECMWS",.f.,"")

	if len(alltrim(cUrlWS)) > 0
	  	cUrlWS := cUrlWS + "/XMLWorkflowEngineService"

		obj:_URL := cUrlWS

    	BISetLogEvent(ECM_EV_LEVEL_INFO, "getInstanceCardData", STR0008 + ": " + cUrlWS) //###"Conectando no WS"

		if ECM_DEBUG
			wsdldbglevel(2)
		endif
		
		if valtype( xProcessId ) == "C"
			xProcessId := val( xProcessId )
		endif

		if obj:getInstanceCardData(  cUser			; // Usuario integração
											, cpassword		; // Senha integracao
								 			, ncompanyId	; // Codigo da empresa integracao
											, cUser			; // Usuario que executa o processo
											, xProcessId	; // Instancia do processo
		 								  )

			BISetLogEvent(ECM_EV_LEVEL_INFO, "getInstanceCardData", STR0009 + ": " + str( xProcessId ) ) //###"Processo iniciado com sucesso"

			cDecriptCard := biDeCript( obj:cCardData )
		else                                                                    
			BISetLogEvent(ECM_EV_LEVEL_ERROR, "getInstanceCardData", getWscError()) //###"Processo iniciado com erro"
			
			cDecriptCard := {}
			aAdd( cDecriptCard, { "ERROR", getWscError() } )
		endif
	else
		BISetLogEvent(ECM_EV_LEVEL_ERROR, "getInstanceCardData", STR0011) //###"Parametro (MV) MV_ECMWS nao configurado"

		cDecriptCard := {}
		aAdd( cDecriptCard, { "ERROR", STR0011 } )
	endif	   
   
return cDecriptCard        
                     

//-------------------------------------------------------------------
/*/{Protheus.doc} BIUpdateTask
Atualiza um processo no TOTVS ECM

@param xProcessId	Código da instância do processo no TOTVS ECM
@param cComments	Comentário
@param cCardData	Dados que irão ao formulário (em formato XML)
@param aAttach		Anexo no formato {<descrição>, <nome físico>, <conteúdo>}
@param lComplete	Indica se completa ou não a tarefa
@param nNextTask	Próxima tarefa a ser executada
@param aUsers		Lista com a identificação dos usuários no TOTVS ECM que irão receber a atribuição da tarefa
@param acUser		Usuário (ECM) que irá executar a ação
@param acPassword	Senha no formato MD5:xxxxxxx
@author  BI TEAM
@version P10 R1.3
@since   22/07/2009			  
@return  aRet 
				em caso de sucesso: a[1] { 'iTask', <ID da proxima tarefa> }
										  a[2] { 'cDestino', <Nome do usuário da próxima tarefa> }

				em caso de falha: a[n] { 'ERROR', <mensagem de erro> }

/*/
//-------------------------------------------------------------------
function BIUpdateTask( xProcessId, cComments, cCardData, aAttach, lComplete, nNextTask, aUsers, acUser, acPassword )
	local aRet 				:= {}
	local cUser 			:= ""
	local cPassword 		:= ""
	local nCompanyId 		:= 0
	
	local cTmpPwd			:= ""

	default nNextTask		:= 0
	default aAttach 		:= {}
	default aUsers			:= {}
	default lComplete		:= .T.

	if ( valtype( acUser ) == "U" ) .and. ( valtype( acPassword ) == "U" )
		cUser := __cUserID

		cTmpPwd := PswMD5GetPass( __cUserID )
		
		if !Empty( cTmpPwd ) .and. valtype( cTmpPwd ) == "C"
			cPassword := "MD5:" + cTmpPwd
		endif
	else
		cUser := acUser
		
		if ( len( acPassword ) == 36 ) .and. ( left( acPassword, 4 ) == "MD5:" )
			cPassword := acPassword
		else
			cPassword := "MD5:" + md5( acPassword )
		endif
	endif
    
	if !Empty( cPassword )
		nCompanyId := getMv( "MV_ECMEMP", .F. ,"" )
		if len( alltrim( nCompanyId ) ) > 0
			nCompanyId := val( ncompanyId )

	  		aRet := _BIUpdateTask( Alltrim( cUser ), Alltrim( cPassword ), nCompanyId, xProcessId, cComments, cCardData, aAttach, lComplete, nNextTask, aUsers )
		else 
			BISetLogEvent(ECM_EV_LEVEL_ERROR, "SaveAndSendTask", STR0012) //###"Parametro (MV) MV_ECMEMP nao configurado"

			aAdd( aRet, { "ERROR", STR0012 } )
		endif
	else
		BISetLogEvent(ECM_EV_LEVEL_ERROR, "SaveAndSendTask", STR0014) //###"Usuários administradores não podem realizar esta operação"
		
		aAdd( aRet, { "ERROR", STR0014 } )
	endif

return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} _BIUpdateTask
Atualiza um processo no TOTVS ECM

@protected
@param cUser		Usuário (ECM) que irá executar a ação
@param cPassword	Senha no formato MD5:xxxxxxx
@param nCompanyId	Empresa no TOTVS ECM
@param xProcessId	Código da instância do processo no TOTVS ECM
@param cComments	Comentário
@param cCardData	Dados que irão ao formulário (em formato XML)
@param aAttach		Anexo no formato {<descrição>, <nome físico>, <conteúdo>}
@param lComplete	Indica se completa ou não a tarefa
@param nNextTask	Próxima tarefa a ser executada
@param aUsers		Lista com a identificação dos usuários no TOTVS ECM que irão receber a atribuição da tarefa
@author  BI TEAM
@version P10 R1.3
@since   22/07/2009
@return  aRet 
				em caso de sucesso: a[1] { 'iTask', <ID da proxima tarefa> }
										  a[2] { 'cDestino', <Nome do usuário da próxima tarefa> }

				em caso de falha: a[n] { 'ERROR', <mensagem de erro> }

/*/
//-------------------------------------------------------------------
static function _BIUpdateTask(cUser, cPassword, nCompanyId, xProcessId, cComments, cCardData, aAttach, lComplete, nNextTask, aUsers)
	local obj 				:= WSXMLWorkflowEngineServiceService():new()  
	local oProcessAttach	:= obj:oWSsaveAndSendTaskattachments
	local oUsers 			:= obj:oWSsaveAndSendTaskcolleagueIds
	local oAppointment	:= obj:oWSsaveAndSendTaskappointment

	local cUrlWS			:= "" 
	local cCriptCard		:= ""
	
	local oTmp 				:= nil
	local oAttach 			:= nil

	local aRet				:= {}   
	
	local nPos				:= 0
	
	local cRetITask		:= ""
	local cRetIProc		:= ""
	local cRetIDest		:= ""
	
	default aAttach 		:= {}
	default aUsers			:= {}
	default nNextTask		:= 0
	default lComplete		:= .T.

	cUrlWS := getMv("MV_ECMWS",.f.,"")

	if len(alltrim(cUrlWS)) > 0
		cUrlWS := cUrlWS + "/XMLWorkflowEngineService"

		obj:_URL := cUrlWS

    	BISetLogEvent(ECM_EV_LEVEL_INFO, "SaveAndSendTask", STR0008 + ": " + cUrlWS) //###"Conectando no WS"

		if ECM_DEBUG
			wsdldbglevel(2)
		endif
		
		if valtype( xProcessId ) == "C"
			xProcessId := val( xProcessId )
		endif

		if len( aAttach ) > 0
			//Anexar arquivo
			oTmp := XMLWorkflowEngineServiceService_processAttachmentDto():New()
			oTmp:nattachmentSequence := 1
			oTmp:ldeleted := .F.
			oTmp:lnewAttach := .T.
			oTmp:noriginalMovementSequence := 1
			oTmp:cpermission := "3"
			oTmp:nprocessInstanceId := 0
			oTmp:nversion := 0
			
			oTmp:ccolleagueId := cUser
			oTmp:ncompanyId := nCompanyId
			oTmp:cdescription := aAttach[ECM_FILE_DESC]
			oTmp:cfileName := aAttach[ECM_FILE_NAME]
			
			oAttach := XMLWorkflowEngineServiceService_attachment():New()
			oAttach:lattach := .T.
			oAttach:ldescriptor := .F.
			oAttach:lediting := .T.
			oAttach:cfileName := aAttach[ECM_FILE_NAME]
			oAttach:cfilecontent := aAttach[ECM_FILE_CONT]

			aAdd( oTmp:oWSattachments, oAttach )

			aAdd( oProcessAttach:oWSitem, oTmp )
		endif

		aEval( aUsers, {|x| aAdd( oUsers:citem, x )} )
		
		cCriptCard := biCript( cCardData )

		if obj:saveAndSendTask( cUser				; // Usuario integração
 							 		 , cpassword		; // Senha integracao
									 , ncompanyId		; // Codigo da empresa integracao
									 , xProcessId		; // Código da instância do processo
									 , nNextTask		; // Proxima atividade. Passando zero ele calcula a proxima atividade automaticamente
									 , oUsers			; // StringArray com a lista de usuarios que vão receber a tarefa
									 , ccomments		; // Cometario da tarefa
									 , cUser				; // Usuario que executou o processo Workflow
									 , lComplete		; // Completa ou não a atividade
									 , oProcessAttach	; // Anexos
									 , cCriptCard		; // Dados da ficha (em formato gzip + base64)
									 , oAppointment	; // Apontamentos
									 , .F. 				; // Modo manager
									 , 0 )		  		  // Numero da Tread passar sempre zero

			aEval( obj:oWSsaveAndSendTaskresult:oWsItem, { |x| aAdd( aRet, { x:cItem[1], x:cItem[2] } ) } )

			nPos := aScan( aRet, { |x| Upper( x[1] ) == "ERROR" } )
			
			if nPos == 0
				BISetLogEvent(ECM_EV_LEVEL_INFO, "SaveAndSendTask", STR0009 + ": " + str( xProcessId ) ) //###"Processo iniciado com sucesso"
			else
				BISetLogEvent(ECM_EV_LEVEL_ERROR, "SaveAndSendTask", STR0010 + ": " + str( xProcessId ) + CRLF + aRet[nPos][2] ) //###"Processo iniciado com erro"
			endif
		else                                                                    
			BISetLogEvent(ECM_EV_LEVEL_ERROR, "SaveAndSendTask", str( xProcessId ) + " - " + getWscError()) //###"Processo iniciado com erro"
			
			aAdd( aRet, { "ERROR", str( xProcessId ) + " - " + getWscError() } )
		endif
	else
		BISetLogEvent(ECM_EV_LEVEL_ERROR, "SaveAndSendTask", STR0011) //###"Parametro (MV) MV_ECMWS nao configurado"
		
		aAdd( aRet, { "ERROR", STR0011 } )
	endif	   

return aRet