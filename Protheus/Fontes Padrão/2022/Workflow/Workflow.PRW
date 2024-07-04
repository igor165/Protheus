#include "SIGAWF.CH"

/******************************************************************************
	TWFObj()
	Retorna um objeto da classe TWorkflow
 ******************************************************************************/
function TWFObj( aParams )
return TWorkflow():New( aParams )

/******************************************************************************
	WFVersion()
	Retorna a atual versao do workflow
 ******************************************************************************/
function WFVersion
	local aVersion := array(6)
	aVersion[1] := "Workflow"									// Identifica o produto   
	aVersion[2] := "4"      								// Versao
	aVersion[3] := "0a"     								// Release
	aVersion[4] := ctod("04/01/2006")   				// Data do path
	aVersion[5] := "10:00"                          // Hora do path
	aVersion[6] := aVersion[1] + " V." + aVersion[2] + "." + aVersion[3]
return aVersion


/******************************************************************************
	CLASSE TWORKFLOW
 ******************************************************************************/
class TWorkflow
	data cRootDir
	data nMaxJobs
	data cMailBox
	data cMailAdmin
	data lAttachImg
	data lHtmlBody
	data lUseJavaS
	data lReacProcs
	data lUseTrans
	data lSendAuto
	data cBrowser
	data cBrwServer
	data lforward
	data lNotif001
	data lNotif002
	data lNotif003  
	data lNotif004
	data cTaskDir
	data cTempDir
	data cProcessDir
	data cMessengerDir
	data cVisioDir
	data oScheduler
	data oMail
	method New( aParams )
	method LoadParams()
	method NewMailID( cPrefixo )               
	method Free()
endclass

function WFMvWFMErr(aParams)
	local oWF := TWorkflow():New( aParams )
	oMailBox := oWF:oMail:GetMailBox( oWF:cMailBox )
	oOutboxFolder := oMailBox:GetFolder( MBF_OUTBOX )
	oErrorFolder := oMailBox:GetFolder( MBF_OUTBOX + MBF_ERROR )
	Conout("Movendo mensagens do diretorio: " + oErrorFolder:cRootPath )
	Conout("Para o diretorio: " + oOutboxFolder:cRootPath )
	oErrorFolder:MoveFiles( "*.wfm", oOutboxFolder )
return


/******************************************************************************
	New()
	Inicializa a classe workflow
 *****************************************************************************/
method New( aParams ) class TWorkflow
	default aParams := { cEmpAnt, cFilAnt }
	WFPrepEnv( aParams[1], aParams[2], "Workflow",, WFGetModulo( aParams[1], aParams[2] ) )
	::LoadParams()
	WFForceDir( ::cRootDir )
	WFForceDir( ::cTempDir )
	WFForceDir( ::cProcessDir )
	WFForceDir( ::cMessengerDir )
	WFForceDir( ::cVisioDir )
	::oScheduler := TWFSchedObj( aParams )
	::oMail := TWFMail():New( aParams )
return

/******************************************************************************
	LoadParams()
	Le os parametros do workflow
 *****************************************************************************/
method LoadParams() class TWorkflow
	::cRootDir		:= WF_ROOTDIR + cEmpAnt + "\"
	::cTempDir		:= ::cRootDir + "temp\"
	::cProcessDir	:= ::cRootDir + "process\"
	::cVisioDir		:= ::cRootDir + "visio\"
	
	::cMessengerDir := AllTrim( Lower( WFGetMV( "MV_WFDHTTP", "\http" ) ) )	// Diretorio HTTP
	::cMessengerDir := StrTran( ::cMessengerDir, "/", "\" )
	
	if Right( ::cMessengerDir, 1 ) <> "\" 
		::cMessengerDir += "\"
	end
	
	::cMessengerDir += "messenger\emp" + cEmpAnt + "\"
	::cMailBox	 	:= WFGetMV( "MV_WFMLBOX", "" )	// Caixa de correio do workflow
	::cMailAdmin 	:= WFGetMV( "MV_WFADMIN", "" )	// E-mail do(s) administrador(es)
	::lAttachImg 	:= WFGetMV( "MV_WFIMAGE", .t. )	// Enviar figuras do html como anexo
	::lHtmlBody		:= WFGetMV( "MV_WFHTML ", .t. )	// Enviar html no corpo da mensagem
	::lUseJavaS 	:= WFGetMV( "MV_WFJAVAS", .t. )	// Usa javascript
	::lSendAuto 	:= WFGetMV( "MV_WFSNDAU", .t. )	// Envia mensagens automaticamente.
	::lReacProcs	:= WFGetMV( "MV_WFREACT", .t. )	// Reativar processos automaticamente
	::nMaxJobs 		:= WFGetMV( "MV_WFMAXJB", .t. )	// Numero max de execucao de retornos por vez
	::lUseTrans 	:= WFGetMV( "MV_WFTRANS", .t. )	// Usa transacao
	::cBrowser		:= WFGetMV( "MV_WFBROWS", "IEXPLORE.EXE" )	// Browser internet utilizado
	::cBrwServer	:= WFGetMV( "MV_WFBRWSR", "127.0.0.1" )	// Browser internet utilizado
	::lforward		:= WFGetMV( "MV_WFMSGNR", .f. )	// Encaminhar Mensagens Nao Reconhecidas para o administrador.
	::lNotif001 	:= WFGetMV( "MV_WFNF001", .t. )	// Notificar se houver erro ao executar funcoes de retorno e timeout
	::lNotif002 	:= WFGetMV( "MV_WFNF002", .t. )	// Notificar ao reativar processos pendentes
	::lNotif003 	:= WFGetMV( "MV_WFNF003", .t. )	// Notificar ao receber mensagens nao reconhecidas.  
	::lNotif004 	:= WFGetMV( "MV_WFNF004", .t. )	// Notificar ao ocorrer falha no envio de email.  	
return

/******************************************************************************
	NewMailID()
	Gera um sufixo para o numero ID do processo ex: 0002201<sufixo>
 *****************************************************************************/
method NewMailID( cPrefixo ) class TWorkflow
	local cMailID := int2Hex(year(msdate()), 3) + int2Hex(month(msdate()), 1) + ;
						  int2Hex(day(msdate()), 1) + int2Hex(seconds(), 5 )
	default cPrefixo := ""
return AllTrim( cPrefixo ) + cMailID

/******************************************************************************
	Free()
	Libera da memoria os agentes que pertencem a class tworkflow
 *****************************************************************************/
method Free() class TWorkflow
	local nC
	local aAlias := { "WFA", "WF1", "WF2", "WF3", "WF4", "WF5", "WF6", "WF7" }
	for nC := 1 to len( aAlias )
		if Select( aAlias[ nC ] ) <> 0
			DbSelectArea( aAlias[ nC ] )
			DbCloseArea()
		end
	next
	::oScheduler:Free()
	::oMail:Free()
return
