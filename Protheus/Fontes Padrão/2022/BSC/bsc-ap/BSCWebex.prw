// ######################################################################################
// Projeto: BSC
// Modulo : Core
// Fonte  : BSCWebex - Rotinas para controle Webex
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli  
// 08.05.08 | 2516 Lucio Pelinson
// --------------------------------------------------------------------------------------

#include "BSCDefs.ch"
#include "BSCWebex.ch"

// WebStart
function BSCWebStart()
	local nStart := 0, lFirstBase := .f.
	local oGlobalLockFile, cInstanceName

	public oBSCCore := TBSCCore():New(), cBSCErrorMsg := ""

	ErrorBlock( {|oE| __BSCError(oE)})

	set exclusive off
	set talk off
	set scoreboard off
	set date brit
	set epoch to 1960
	set century on
	set cursor on
	set deleted on

//  Rpc nao abre tabelas
//	RpcSetEnv ("99","01", , , , , , , , .F., .F. )
//  Rpc abre todas as tabelas
//	RpcSetEnv ("99","01", , , , , , , , )
//	CriaPublica()

// 	ValidPswFile() - Funcao criada pela tecnologia para resolver problema do psw
// 	Como nuca funcionou não foi implantada, aqui seria o lugar adequado, se funcionasse

	// Instance Name - nome base para os arquivos gerados pelo BSC para trabalhar com multithreading
	cInstanceName := alltrim(getJobProfString("INSTANCENAME", "BSC"))
	oGlobalLockFile := TBIFileIO():New( cInstanceName+".upd" )
	while !oGlobalLockFile:lCreate(FC_NORMAL+FO_EXCLUSIVE)
		sleep(500)
	enddo
	                 
	nStart := nBIVal(GetGlbValue(cInstanceName))
	if(nStart < 1)
		nStart := 1
		PutGlbValue(cInstanceName, cBIStr(nStart))
		conout("")
		conout(STR0001)/*//"Iniciando BSC..."*/
		oBSCCore:LogInit()
		oBSCCore:LanguageInit()
		lFirstBase := oBSCCore:lUpdateDB()
		
		if(oBSCCore:nDBStatus() >= 0)
			oBSCCore:UpdateVersion(lFirstBase)
			conout(STR0002)  /*//"Inicializando working threads..."*/
		endif
		conout(replicate("-", 70))
	else
		nStart++
		PutGlbValue(cInstanceName, cBIStr(nStart))
	endif
	oGlobalLockFile:lClose()

	if(nStart == 1 .and. oBSCCore:nDBStatus() < 0)
		conout(" ")
		ExUserException(cBIMsgTopError(oBSCCore:nDBStatus()))
	endif	
	
	if(oBSCCore:nDBOpen() < 0)
		conout(" ")
		ExUserException(cBIMsgTopError(oBSCCore:nDBStatus()))
	else
		// Inicialização do scheduler do BSC
		// Para o mp8srv.ini BscSchedInit=0 não inicializa o scheduler
		// Por default BscSchedInit=0, ou seja, nao 1inicializa por default 
		oBSCCore:SchedInit(xBIConvTo("N", alltrim(getJobProfString("BscSchedInit", "0"))) > 0)
	endif	
	oBSCCore:nThread(nStart)
	oBSCCore:Log("Working thread "+upper(cInstanceName)+"."+strzero(oBSCCore:nThread(), 4)+STR0003, BSC_LOG_SCRFILE)/*//" inicializada."*/

return .T.

// WebConnect
function BSCWebConnect()
	local lDebug, cResponse := "", nCard := 0, nContextID := 0, i, aTemp := {}
	
	private lPainel := .f., cUserProt:="", cSessao:=""
	
    httpSession->Title := "Protheus SigaBSC - Balanced ScoreCard"
    httpSession->AccessBtn := STR0050 //"Acessar BSC"	

	// Se modo debug, exibe todas as informações de conexão
	lDebug := (nBIVal(GetJobProfString("debug", "0")) == 1)
	if(lDebug)
		BSCDebug1()
	endif
	
	begin sequence
       
	do case	
		case(oBscCore:nDBStatus() < 0)
			// Avisar erro top, html browser volta ao login
			cResponse := BSCTopError(oBscCore:nDBStatus())
		case(lower(HttpHeadIn->Main)=="bscindex")
			// Mostra a pagina de login do bsc
			cResponse := BSCIndex()
		case(lower(HttpHeadIn->Main)=="bsccore") // Responde ao client, verificando expiração ou necessidade de autenticação
			//-------------------------------------------------------
			// Se a sessão não estiver preenchida pega da BSCCORE.
			//-------------------------------------------------------
			If ( HttpSession->usercard == Nil )
				nCard := nBIVal(oBSCCore:fnUserCard)
			Else
				nCard := nBIVal(HttpSession->usercard)
			EndIf
			//-------------------------------------------------------
			// Se a sessão não estiver preenchida pega da BSCCORE.
			//-------------------------------------------------------
			If ( HttpSession->ContextID == Nil )
				nContextID := nBIVal(oBSCCore:fnContextID)
			Else
				nContextID := nBIVal(HttpSession->ContextID)
			EndIf

			if(oBSCCore:lSetupCard(nCard)) // Autentica o usuario
				if(valtype(HttpPost->bsccontent)=="C")
					oBSCCore:fnContextID := nContextID // Atribui ContextID do contexto atual para session
					cResponse := oBSCCore:cRequest(HttpPost->bsccontent) // Responde ao usuario
					HttpSession->ContextID := oBSCCore:nContextID() // Se houve mudanca no contexto, atualiza session
				endif
			else
				if(valtype(HttpPost->bsccontent)=="U")
						httpSession->BadLogin := .T.
						cResponse := h_biportalby() // html browser volta ao login
				else
					cResponse := BSCXMLLogin() // XML indica ao client novo login
				endif	
			endif 
		case(lower(HttpHeadIn->Main)=="bscpainel")
			// Mostra a pagina de login do bsc porem exibida com restrições
			lPainel := .t.
			for i:=1 to len(HttpGet->aGets)
				if(upper(HttpGet->aGets[i])=="USUARIO")
					cUserProt := &('HttpGet->'+HttpGet->aGets[i])
				elseif(upper(HttpGet->aGets[i])="CSESSAO")
					cSessao := &('HttpGet->'+HttpGet->aGets[i])
				else
				    aadd(aTemp,{HttpGet->aGets[i], upper(&('HttpGet->'+HttpGet->aGets[i])) })
				endif
			next
			cResponse := BSCIndex(.t., aTemp)

			if(!empty(cUserProt+cSessao))
				nCard := oBSCCore:nLogin(cUserProt, , cSessao )
				nContextID := 1 // Estrategia default para teste
				// grava na sessao do usuario
				HttpSession->usercard := nCard
				HttpSession->ContextID := nContextID
				if(nCard==0)
					sleep(500)
					cResponse := BSCBadLogin() // volta ao login anunciando erro na autenticação
				else
					cResponse := BSCNavApplet() // autenticação ok, carrega o applet principal no navegador
				endif
			endif
		case(lower(HttpHeadIn->Main)=="bsclogin")
			if(len(HttpGet->aGets)>0 .and. !empty(HttpGet->entidade))
				lPainel := .t.
			endif

			// Verifica se esta tentando login
			if(valtype(HttpPost->login)=="C" .and. HttpPost->login=="true")
				nCard := oBSCCore:nLogin(HttpPost->Username, HttpPost->Password)
				nContextID := 1 // Estrategia default para teste
				// grava na sessao do usuario
				HttpSession->usercard := nCard
				HttpSession->ContextID := nContextID
				
				// grava na BscCore, o card do usuário.
				oBSCCore:fnUserCard := nCard
				oBSCCore:fnContextID := nContextID
				
				if(nCard==0)
					sleep(500)
					//cResponse := BSCBadLogin() // volta ao login anunciando erro na autenticação
					httpSession->BadLogin := .T.
					
					cResponse := h_biportalby() // html browser volta ao login
				else
					cResponse := BSCNavApplet() // autenticação ok, carrega o applet principal no navegador
				endif
			else
				sleep(500)
				cResponse := BSCBadLogin() // volta ao login anunciando erro na autenticação
			endif	
		case(lower(HttpHeadIn->Main)=="recpassword")
			//Processando a requisicao da senha
			if(oBSCCore:lRecPassword(httpPost->USERNAME,alltrim(httpPost->EMAIL)))
				cResponse := BSCPassSended(alltrim(httpPost->EMAIL))
			else                                  
				cResponse := BSCBadLogin(STR0035) //Usuário ou e-mail inválidos.
			endif 
		case(lower(HttpHeadIn->Main)=="bscreport") 
			//Relatorio BSC
			nCard := nBIVal(HttpSession->usercard)
			if(nCard==0)
				sleep(500)
				cResponse := "<html><br>"+STR0038+"<br></html>" //Sessão expirada! Favor efetuar o login novamente.
			else             
				cResponse := wfLoadFile(oBscCore:fcbscPath+"relato\"+HttpGet->id+".html")
			endif
		case(lower(HttpHeadIn->Main)=="h_bscrecpassword")
			//Enviando a pagina para recuperacao da senha.
			cResponse :=  h_bscrecpassword()
		case(lower(HttpHeadIn->Main)=="h_bscpolicy")
			// Monta arquivo de segurança
			cResponse :=  h_bscpolicy()	  
		case(lower(HttpHeadIn->Main)=="bscsobre")
			// Mostra a pagina de sobre do bsc
			cResponse := BSCSobre()
		case(lower(HttpHeadIn->Main)=="h_bibyforgotpwd")//Enviando a pagina para recuperacao da senha.
			cResponse :=  h_bibyForgotPwd()
		case(lower(HttpHeadIn->Main)=="javawebstart")	
			BIExecDownload(oBSCCore:CreateJNPL())
			cResponse := BSCBadLogin()  
		otherwise
			cResponse := BSCBadLogin() //
		endcase

	recover     

		cResponse := BSCGeneralError(cBSCErrorMsg) // XML general error

	end sequence

	// Se modo debug, exibe todas as informações de conexão
	if(lDebug)
		conout("Response inicio --------------------------------------------------")
		conout(iif(valType(cResponse)=='U', STR0041, cResponse)) //'Transferência por arquivo'
		conout("Response fim -----------------------------------------------------")
	endif	

return iif(valType(cResponse)=='U', '', cResponse)


// WebExit
function BSCWebFinish()
	// Fechar arquivos
	oBSCCore:Log("Working thread BSC"+strzero(oBSCCore:nThread(), 4)+STR0004, BSC_LOG_SCRFILE)/*//" finalizada."*/
	BICloseDB()
return

// BscIndex.apw
function BSCIndex( lPaineis, aParametros )
	httpGet->lPaineis	:= lPaineis
	httpGet->aParametros:= aParametros
   	httpSession->cAction := "bsclogin.apw"
	httpSession->ForgotPwd:= "h_bibyForgotPwd.apw"
return  h_biportalby()

// BSC no navegador
function BSCNavApplet()
	local cHtml, lDebug
	
	// Se modo debug, exibe todas as informações de conexão
	lDebug := (nBIVal(GetJobProfString("debug", "0")) == 1)
	
	cHtml := ""
	cHtml += "<!DOCTYPE html PUBLIC '-//W3C//DTD HTML 4.0 Transitional//PT'>"+CRLF
	cHtml += '<html>'+CRLF
	cHtml += '<head>'+CRLF
	cHtml += '<title>Protheus SigaBSC - Balanced ScoreCard</title>'+CRLF
	cHtml += '</head>'+CRLF
	cHtml += '<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onResize="changeAppSize()">'+CRLF
	cHtml += BSCApplet("bsc.applet.BscNavApplet", lPainel)
	cHtml += '</body>'+CRLF
	cHtml += '</html>'+CRLF
	cHtml += '<script>'+CRLF
	cHtml += 'changeAppSize();'+CRLF
	cHtml += 'function changeAppSize() { '+CRLF
	cHtml += '  if (navigator.appName=="Microsoft Internet Explorer") {'+CRLF 
	cHtml += '	document.AppBsc.width = document.body.clientWidth;'+CRLF
	cHtml += '	document.AppBsc.height = document.body.clientHeight;'+CRLF
	cHtml += '  } else {'+CRLF
	cHtml += '	document.embeds["AppBsc"].width = window.innerWidth;'+CRLF
	cHtml += '	document.embeds["AppBsc"].height = window.innerHeight-5;'+CRLF
	cHtml += '  }'+CRLF
	cHtml += '} '+CRLF
	cHtml += '</script>' 
Return cHtml	
			

function BSCWindowApplet()
return h_bscWindowApplet()

// Retorna a tag para o applet do bsc
function BSCApplet(cAppletClassName)
	local cHtml, lDebug, cPanel := "", cPanelEmb := ""
	
	// Se modo debug, exibe todas as informações de conexão
	lDebug := (nBIVal(GetJobProfString("debug", "0")) == 1)
	
	If(!empty(HttpGet->ENTIDADE))
		cPanel := '	<PARAM NAME = ENTIDADE VALUE = '+HttpGet->ENTIDADE+'>'+CRLF
		cPanelEmb := 'ENTIDADE = ' + HttpGet->ENTIDADE + '"'
	EndIf
	
	If(!empty(HttpGet->ID))
		cPanel += '	<PARAM NAME = ID VALUE = '+HttpGet->ID+'>'+CRLF
		cPanelEmb += 'ID = "' +HttpGet->ID+ '"'
	EndIf  

	cHtml := ""+;
	'<OBJECT name="AppBsc" id="AppBsc" classid = "clsid:8AD9C840-044E-11D1-B3E9-00805F499D93"'+CRLF+;
	'	codebase = "http://java.sun.com/update/1.6.0/jinstall-6u16-windows-i586.cab"'+CRLF+;
	'	WIDTH = 1250 HEIGHT = 860>'+CRLF+;
	'	<PARAM NAME = CODE VALUE = '+cAppletClassName+'>'+CRLF+;
	'	<PARAM NAME = "type" VALUE = "application/x-java-applet;version=1.6.0">'+CRLF+;
	'	<PARAM NAME = ARCHIVE VALUE = "bsc.jar" >'+CRLF+;
	'	<PARAM NAME = "scriptable" VALUE = "false">'+CRLF+;
	'	<PARAM NAME = SESSIONID VALUE = "'+alltrim(cBIStr(HttpSession->SESSIONID))+'">'+CRLF+;
	'	<PARAM NAME = DEBUG VALUE = "'+iif(lDebug, "TRUE", "FALSE")+'">'+CRLF+;
	'	<PARAM NAME = LANGUAGE VALUE = "'+cBSCLanguage()+'">'+CRLF+;
	'	<PARAM NAME = BSCVERSION VALUE = "'+cBSCVersion()+'">'+CRLF+;
	'	<PARAM NAME = PAINEL VALUE = "'+iif(lPainel,"true","false")+'">'+CRLF+;
		cPanel+;
	'	<COMMENT>'+CRLF+;
	'		<embed  name="AppBsc" id="AppBsc" type="application/x-java-applet;version=1.6"'+CRLF+;
	'			CODE = '+cAppletClassName+' ARCHIVE = "bsc.jar"'+CRLF+;
	'			WIDTH = 70 HEIGHT = 50'+;
				' SESSIONID = '+alltrim(cBIStr(HttpSession->SESSIONID))+;
				' DEBUG = '+iif(lDebug, 'TRUE', 'FALSE')+;
				' LANGUAGE = "'+cBSCLanguage()+'"'+;
				' BSCVERSION = "'+cBSCVersion()+'"'+;
				' PAINEL = "'+iif(lPainel,"true","false")+'"' + cPanelEmb +  ;
				' scriptable = false'+CRLF+;
	'			pluginspage = "http://java.sun.com/javase/downloads/ea.jsp">'+CRLF+;
	'			<NOEMBED></NOEMBED>'+CRLF+;
	'		</embed>'+CRLF+;
	'	</COMMENT>'+CRLF+;
	'</OBJECT>'+CRLF
return cHtml

function BSCPassSended(cEmail)
	httpSession->cMsg = STR0037 + cEmail //"Uma nova senha foi gerada e enviada para o seguinte e-mail: " ??? "Nova senha foi enviada para : "  
	httpSession->cClassName = "message"                  
return  h_biportalby() 
	

	
return cHtml
	
function BSCBadLogin(cMessage)
   httpSession->cMsg = cMessage 
   httpSession->cClassName = "badmessage"  
return  h_biportalby() 

function BSCTopError(nTopError)
   local cMessage := cBIMsgTopError(nTopError)     
   
   httpSession->cMsg = cMessage 
   httpSession->cClassName = "badmessage"  
return h_biportalby() 

function BSCSobre()
	Local cMessage := ""
	
	cMessage := "<br>Business Intelligence"
	cMessage += "<br>build " + alltrim(cBSCVersion())
	
return mountDefaultHtml(STR0040, cMessage)
	
	
static function mountDefaultHtml(acTitle, acMessage)
	Local cHtml := ""
	
	cHtml += "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//PT'>" + CRLF
	cHtml += '<html>' + CRLF
	cHtml += '    <head>' + CRLF
	cHtml += '        <link href="favico.ico/" rel="icon">' + CRLF
	cHtml += '        <link href="favico.ico/" rel="shortcut icon">' + CRLF
	cHtml += '        <title>Microsiga Protheus SigaBSC - Balance ScoreCard</title>' + CRLF
	cHtml += '        <meta content="text/html; charset=ISO-8859-1" http-equiv="content-type">' + CRLF
	cHtml += '        <meta content="TOTVS S.A. - IP - Business Intelligence" name="author">' + CRLF
	cHtml += '        <meta content="TOTVS Web Interface" name="Generator">' + CRLF
	cHtml += '        <meta content="application/x-javascript" name="Content-Script-Type">' + CRLF
	cHtml += '        <meta content="no-cache" http-equiv="Cache-control">' + CRLF
	cHtml += '        <meta content="-1" http-equiv="Expires">' + CRLF
	cHtml += '        <meta content="none,noarchive" name="Robots">' + CRLF

	cHtml += '        <link href="./css/reset.css" type="text/css	" rel="stylesheet">' + CRLF
	cHtml += '        <link href="./css/main.css" type="text/css" rel="stylesheet">' + CRLF
	cHtml += '        <link href="./css/layout.css" type="text/css" rel="stylesheet">' + CRLF
	cHtml += '        <link href="./css/decor.css" type="text/css" rel="stylesheet">' + CRLF
	cHtml += '        <link href="./css/ids.css" type="text/css" rel="stylesheet">' + CRLF

	cHtml += '        <link href="estilo.css" rel="stylesheet" type="text/css">' + CRLF
	cHtml += '	</head>' + CRLF

	cHtml += '    <body class="p11">' + CRLF
	cHtml += '        <div id="form1" style="padding-left: 0px; padding-right: 0px; width: 100%; height: 100%;" class="pos-abs">' + CRLF
	cHtml += '			<form name="form1" action="" method="post" style="position: absolute; width: 100%; height: 100%; margin: 0px; padding: 0px;" onSubmit="saveCookies();">' + CRLF
	cHtml += '                <input type="hidden" value="true" name="login">' + CRLF
	cHtml += '                <div style="position: absolute; left: 0px; right: 0px; top: 0px; bottom: 0px;" class="bi-dialog-nopopup bi-dialog-content" id="0000000039">' + CRLF
	cHtml += '                    <div id="0000000074" class="wi-jqmsgbar pos-abs" style="height: 33px; display: none;">&nbsp;</div>' + CRLF
	cHtml += '                    <div id="0000000075" class="wi-jqpanel pos-abs containerLogin" style="width: 632px; height: 420px;">' + CRLF
	cHtml += '                        <div id="0000000077" class="wi-jqpanel pos-abs container_l" style="left: 0px; width: 45px; height: 420px;"></div>' + CRLF
	cHtml += '                        <div id="0000000079" class="wi-jqpanel pos-abs container_m" style="left: 45px; right: 45px; height: 420px;"></div>' + CRLF
	cHtml += '                        <div id="0000000081" class="wi-jqpanel pos-abs divisor" style="left: 276px; top: 50px; bottom: 50px; width: 2px;"></div>' + CRLF
	cHtml += '                        <div id="0000000083" class="wi-jqpanel pos-abs logo_totvs" style="right: 114px; top: 128px; width: 176px; height: 166px;"></div>' + CRLF
	cHtml += '                        <div id="0000000085" class="wi-jqpanel pos-abs divisor" style="right: 48px; top: 50px; bottom: 50px; width: 2px;"></div>' + CRLF
	cHtml += '                        <div id="0000000087" class="wi-jqpanel pos-abs container_r" style="right: 0px; width: 45px; height: 420px;"></div>' + CRLF
	cHtml += '                        <label unselectable="on" id="0000000089" class="wi-jqsay pos-abs title" style="left: 20px; top: 150px; width: 270px; height: 7px;">' + acTitle + '</label>' + CRLF
	cHtml += '                        <label unselectable="on" id="0000000090" class="wi-jqsay pos-abs" style="left: 46px; top: 180px; width: 230px; height: 46px;">' + acMessage + '</label>' + CRLF
	cHtml += '                    </div>' + CRLF
	cHtml += '                    <label unselectable="on" id="0000000092" class="wi-jqsay pos-abs login_rodape" style="bottom: 15px; width: 100%; height: 13px;">Copyright &copy; 2009 <b>TOTVS</b> - ' + STR0044 + '</label>' //Todos os direitos reservados. + CRLF
	cHtml += '                </div>' + CRLF
	cHtml += '            </form>' + CRLF
	cHtml += '        </div>' + CRLF
	cHtml += '    </body>' + CRLF
	cHtml += '</html>' + CRLF  + CRLF

	cHtml += '<script language="Javascript">' + CRLF
	cHtml += '//<!--' + CRLF
	cHtml += '	window.moveTo(0,0);' + CRLF
	cHtml += '	if (document.all) {' + CRLF
	cHtml += '		top.window.resizeTo(screen.availWidth,screen.availHeight);' + CRLF
	cHtml += '	}' + CRLF
	cHtml += '	else if (document.layers||document.getElementById) {' + CRLF
	cHtml += '		if (top.window.outerHeight<screen.availHeight||top.window.outerWidth<screen.availWidth){' + CRLF
	cHtml += '			top.window.outerHeight = screen.availHeight;' + CRLF
	cHtml += '			top.window.outerWidth = screen.availWidth;' + CRLF
	cHtml += '		}' + CRLF
	cHtml += '	}' + CRLF
	cHtml += '//-->	' + CRLF
	cHtml += '</script>'
	
return cHtml

// Java web-start
function BSCJavaWS()
	local nCount, cHtml, lDebug, oJnlpFile, cPanel := ""
	
	// Se modo debug, exibe todas as informações de conexão
	lDebug := (nBIVal(GetJobProfString("debug", "0")) == 1)

	if(!empty(HttpGet->ENTIDADE))
		cPanel := '	<PARAM NAME = ENTIDADE VALUE = "'+HttpGet->ENTIDADE+'">'+CRLF
	endif

	if(!empty(HttpGet->ID))
		cPanel += '	<PARAM NAME = ID VALUE = "'+HttpGet->ID+'">'+CRLF
	endif
	
	cHtml := ''
	cHtml += '<?xml version="1.0" encoding="ISO-8859-1"?>'+CRLF
	cHtml += '<!-- JNLP Microsiga BSC -->'+CRLF
	cHtml += '<jnlp '+CRLF
	cHtml += '  spec="1.0+" '+CRLF
	cHtml += '  codebase="'+left(httpHeadIn->REFERER, rat("/", httpHeadIn->REFERER))+'" '+CRLF
	cHtml += '  href="bsc.jnlp"> '+CRLF
	cHtml += '  <information> '+CRLF
	cHtml += '    <title>Protheus SigaBSC - Balanced ScoreCard</title> '+CRLF
	cHtml += '    <vendor>Microsiga Software S/A</vendor> '+CRLF
	cHtml += '    <homepage href="index.html"/> '+CRLF
	cHtml += '    <description>Protheus - Balanced Scorecard</description> '+CRLF
	cHtml += '    <description kind="short">'
	cHtml += STR0045 //Software para gestão da estratégia empresarial.
	cHtml += '</description> '+CRLF
	cHtml += '    <icon href="images/ap8logo.gif"/> '+CRLF
	cHtml += '    <offline-allowed/> '+CRLF
	cHtml += '  </information> '+CRLF
	cHtml += '  <resources> '+CRLF
	cHtml += '    <j2se version="1.4+"/> '+CRLF
	cHtml += '    <jar href="bscwebstart.jar"/> '+CRLF
	cHtml += '  </resources> '+CRLF
	cHtml += '  <applet-desc '+CRLF
	cHtml += '      documentBase="'+left(httpHeadIn->REFERER, rat("/", httpHeadIn->REFERER))+'" '+CRLF
	cHtml += '      name="Protheus - Balanced Scorecard" '+CRLF
	cHtml += '      main-class="bsc.applet.BscWebStartApplet" '+CRLF
	cHtml += '      width="670" height="400"> '+CRLF
	cHtml += '   <param name="LOGIN" value="TRUE"/> '+CRLF
	cHtml += '   <param name="USUARIO" value=""/> '+CRLF
	cHtml += '   <param name="SENHA" value=""/> '+CRLF
	cHtml += '   <param name="SESSIONID" value="'+alltrim(cBIStr(HttpSession->SESSIONID))+'"/>'+CRLF
	cHtml += '   <param name="DEBUG" value="'+iif(lDebug, "TRUE", "FALSE")+'"/>'+CRLF
	cHtml += '   <param name="LANGUAGE" value="'+cBSCLanguage()+'"/>'+CRLF
	cHtml += '   <param name="BSCVERSION" value="'+cBSCVersion()+'"/>'+CRLF
	cHtml += '   <param name="PAINEL" value="'+if(lPainel,"true","false")+'"/>'+CRLF
	cHtml += cPanel
	cHtml += '  </applet-desc> '+CRLF
	cHtml += '</jnlp> '+CRLF

	oJnlpFile := TBIFileIO():New(oBSCCore:cBscPath()+"bsc.jnlp")
	if(!oJnlpFile:lExists())
		if(!oJnlpFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.))
			conout("Erro na criação do arquivo JNLP.")
			oJnlpFile:lClose()
		endif	
	endif
	
	nCount := 0	
	while((!oJnlpFile:lOpen(FO_WRITE+FO_EXCLUSIVE)) .and. nCount<60)
		sleep(500)
		nCount++
	enddo

	if(nCount == 30)  // se nao abrir em +-15 segundos da erro no conout e libera a thread
		conout(STR0046 + " JNLP.") //Aviso: Timeout expirado ao tentar gravar arquivo
	else
		oJnlpFile:nWriteLn(cHtml)
		oJnlpFile:lClose()
	endif

	HttpCTType( 'application/x-java-jnlp-file' )
//	HttpCTDisp( 'attachment; filename="bsc.jnlp"' )
//	HttpCTLen(len(cHtml))
//	HttpSend(cHtml)
return cHtml

// Session expirada
function BSCXMLLogin()
	local oXMLOutput, oNode
	
	oXMLOutput := TBIXMLNode():New("RESPOSTAS")
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("RESPOSTA"))
	oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_EXPIREDSESSION))
return oXMLOutput:cXMLString(.t., "ISO-8859-1")

// Erro durante a execução do ADVPL
function BSCGeneralError(cStatusMsg)
	local oXMLOutput, oNode, oAttrib

	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("MSG", cStatusMsg)

	oXMLOutput := TBIXMLNode():New("RESPOSTAS")
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("RESPOSTA"))
	oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_GENERALERROR, oAttrib))
return oXMLOutput:cXMLString(.t., "ISO-8859-1")

// Tratamento de erro
function __BSCError(oE)
	local cMsg := "", nPilha := 0
	
//	if oE:gencode > 0      
		cMsg := str(oE:gencode,4,0) + " - " + oE:Description 
		conout(cMsg, "Called from ")
		while ProcName( nPilha ) <> ""
			if(nPilha >= 2)
				conout("    " + ProcName(nPilha) + " line " + strZero(procLine(nPilha), 5))
			endif
			nPilha++
		end
		cBSCErrorMsg := cMsg
		break
//	endif
return .t.

// Funcoes para debug
function BSCDebug1()
	local nInd, cText := "<html><body>", cLogin := ""

	cText += saida(" ")
	cText += saida("Posts:")
	cText += saida("-------------------------------")
	aTmp := HTTPPOST->aPost
	cLogin := iif( HttpPost->login != Nil, AllTrim( HttpPost->login ), "" )
	//-------------------------------------------------------------------
	//  Verifica se o formulário que está vindo é o da tela de login.
	//  Caso seja não é mostrado no monitor usuário e senha.
	//-------------------------------------------------------------------
	If cLogin != 'true'
		for nInd := 1 to len(aTmp)
			cText += saida(aTmp[nInd]+": "+&("HTTPPOST->"+aTmp[nInd]))
		next
	EndIf	
		
	cText += saida(" ")
	cText += saida("Gets:")
	cText += saida("-------------------------------")
	aTmp := HTTPGET->aGets
	for nInd := 1 to len(aTmp)
		cText += saida(aTmp[nInd]+": "+&("HTTPGET->"+aTmp[nInd]))
	next

	cText += saida(" ")
	cText += saida("Cookies:")
	cText += saida("-------------------------------")
	aTmp := HTTPCOOKIES->aCookies
	for nInd := 1 to len(aTmp)
		cText += saida(aTmp[nInd]+": "+&("HTTPCOOKIES->"+aTmp[nInd]))
	next

	cText += saida(" ")
	cText += saida("Header:")
	cText += saida("-------------------------------")
	aTmp := HTTPHEADIN->aHeaders
	for nInd := 1 to len(aTmp)
		if (" "$aTmp[nInd])
			cText += saida(aTmp[nInd])
		else	
			cText += saida(aTmp[nInd]+": "+&("HTTPHEADIN->"+aTmp[nInd]))
		endif	
	next

	cText +="</body></html>"

return cText
          
/*-------------------------------------------------------------
Identica se o BSC está sendo executado em modo de DEBUG.
@Param:
@Return:
	Boolean - Verdadeiro quando está em modo de DEBUG. 	
-------------------------------------------------------------*/
function BSCIsDebug()
return (nBIVal(GetJobProfString("DEBUG", "0")) == 1)

function saida(cText)
	conout(cText)
return cText+CRLF+"<br>"

function BSCRemote(cHost, cPainel, cID, time)
	local o, oDlg, cTitle := "[SigaBSC]"
	local cSessao := PswGetSession(pswRet(1)[1][1])
	local cURL := cHost + "?entidade="+cPainel+"&ID="+cID+"&usuario="+cUserName+"&cSessao="+cSessao
	local nValidaTime := (val(subs(time(),1,2))*60*60) + (val(subs(time(),4,2))*60) + val(subs(time(),7,2))
	local lRetorno := .t.

	if( (nValidaTime - (val(subs(time,1,2))*60*60) + (val(subs(time,4,2))*60) + val(subs(time,7,2))) / 60) > 120
		lRetorno := .f.
	endif

	DEFINE MSDIALOG oDlg FROM 0, 0 TO 570, 950 TITLE cTitle PIXEL

	    oDlg:lMaximized := .T.
	    o:=TiBrowser():New(10,0,oDlg:nWidth / 2,oDlg:nHeight / 2, cURL ,oDlg)
	    o:Navigate(cURL)
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()}) )
                      
return lRetorno

//Retorna o numero da sessao
function BSCXMLSession()
	local oXMLOutput, oNode
	local oXMLNode, cSession
	local oNodeSession
	
	oXMLOutput := TBIXMLNode():New("RESPOSTAS")
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("RESPOSTA"))

	oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_OK))
	oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))

	// Gera no principal
	oXMLNode := TBIXMLNode():New("SESSIONS")
	cSession := alltrim(cBIStr(HttpSession->SESSIONID))
	oNodeSession := oXMLNode:oAddChild(TBIXMLNode():New("SESSIONID",cSession))

	oNode:oAddChild(oXMLNode)

return oXMLOutput:cXMLString(.t., "ISO-8859-1")      
