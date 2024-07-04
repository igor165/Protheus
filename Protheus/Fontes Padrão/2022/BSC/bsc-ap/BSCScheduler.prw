// ######################################################################################
// Projeto: BSC
// Modulo : Agendador
// Fonte  : TBSCScheduler.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 19.10.04 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSCScheduler.ch"

class TBSCScheduler from TBISCheduler
	data scheLog    

	method New( cInstancia ) constructor
	method NewBSCScheduler( cInstancia )
	method lOpen()
	method cClassName()
	method nExecute(nID, cLoadCMD)


	//Metodos de log
	method lSche_CriaLog(cPathSite,cLogName) 
	method lSche_WriteLog(cMensagem)
	method lSche_CloseLog()

endclass
	
method New( cInstancia ) class TBSCScheduler
	::NewBSCScheduler( cInstancia )
return

method NewBSCScheduler( cInstancia ) class TBSCScheduler
	::NewBIScheduler("BSC082", "AGENDADOR", cInstancia )
return

method lOpen() class TBSCScheduler
	local lRet := .t.
	local cTableName := "BSC082"
	local cAlias := "AGENDADOR"

	// Abrir driver
	nBIOpenDBIni(,,)
	
	use (cTablename) alias (cAlias) shared new via ("TOPCONN")

	if(lRet := !neterr())
		//if(lOpenIndexes)
			::OpenIndexes()
			::lClose()
			use (cTablename) alias (cAlias) shared new via ("TOPCONN")
			::OpenIndexes()
		//endif
	   	::InitFields()
	endif

return lRet

method cClassName() class TBSCScheduler

return "TBSCScheduler"

method nExecute(nID, cExecCMD) class TBSCScheduler
	
	if(cExecCMD=="START")
		::Start()
	elseIf(cExecCMD=="STOP")
		::Stop()
    endif
return BSC_ST_OK



/*
*Cria o arquivo de log
*/
method lSche_CriaLog(cPathSite,cLogName) class TBSCScheduler
	cPathSite	:=	strtran(cPathSite,"\","/")
	::scheLog	:= 	TBIFileIO():New(oBSCCore:cBscPath()+"logs\"+ cLogName + ".html")

	// Cria o arquivo htm
	If ! ::scheLog:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oBSCCore:Log(STR0001)  //"Erro na criacao do arquivo de log de importação."
	else
		::scheLog:nWriteLN('<html>')
		::scheLog:nWriteLN('<head>')
		::scheLog:nWriteLN('<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">')
		::scheLog:nWriteLN('<STYLE TYPE="text/css">')
		::scheLog:nWriteLN('.body {																	')
		::scheLog:nWriteLN('	margin-left: 0px;                                                   ')
		::scheLog:nWriteLN('	margin-top: 0px;                                                    ')
		::scheLog:nWriteLN('	margin-right: 0px;                                                  ')
		::scheLog:nWriteLN('	margin-bottom: 0px;                                                 ')
		::scheLog:nWriteLN('}                                                                       ')
		::scheLog:nWriteLN('                                                                        ')
		::scheLog:nWriteLN('.texto {                                                                ')
		::scheLog:nWriteLN('	color: #666666;                                                     ')
		::scheLog:nWriteLN('	font-family: Verdana;                                               ')
		::scheLog:nWriteLN('	font-size: 9px;                                                     ')
		::scheLog:nWriteLN('	background-color: #FFFFFF;                                          ')
		::scheLog:nWriteLN('	margin: 2px;                                                        ')
		::scheLog:nWriteLN('	padding: 2px;                                                       ')
		::scheLog:nWriteLN('    	border-collapse: collapse;                                      ')
		::scheLog:nWriteLN('    	                                                                ')
		::scheLog:nWriteLN('}                                                                       ')
		::scheLog:nWriteLN('                                                                        ')
		::scheLog:nWriteLN('.titulo{                                                                ')
		::scheLog:nWriteLN('	font-family: Verdana, Arial, Helvetica, sans-serif;                 ')
		::scheLog:nWriteLN('	font-size: 16px;                                                    ')
		::scheLog:nWriteLN('	font-weight: bold;                                                  ')
		::scheLog:nWriteLN('	color: #406496;                                                     ')
		::scheLog:nWriteLN('	margin: 3px;                                                        ')
		::scheLog:nWriteLN('	padding: 3px;                                                       ')
		::scheLog:nWriteLN('}                                                                       ')
		::scheLog:nWriteLN('                                                                        ')
		::scheLog:nWriteLN('.tabela {                                                               ')
		::scheLog:nWriteLN('	color: #000000;                                                     ')
		::scheLog:nWriteLN('	padding: 0px;                                                       ')
		::scheLog:nWriteLN('    border-collapse: collapse;                                          ')
		::scheLog:nWriteLN('	                                                                    ')
		::scheLog:nWriteLN('}                                                                       ')
		::scheLog:nWriteLN('                                                                        ')
		::scheLog:nWriteLN('.cabecalho_1 {                                                          ')
		::scheLog:nWriteLN('	color: #000000;                                                     ')
		::scheLog:nWriteLN('	font-family: Verdana;                                               ')
		::scheLog:nWriteLN('	font-size: 11px;                                                    ')
		::scheLog:nWriteLN('	background-color: #C6C6C6;                                          ')
		::scheLog:nWriteLN('	border-collapse: collapse;                                          ')
		::scheLog:nWriteLN('	font-weight: bold;                                                  ')
		::scheLog:nWriteLN('	margin: 3px;                                                        ')
		::scheLog:nWriteLN('	padding: 3px;                                                       ')
		::scheLog:nWriteLN('	                                                                    ')
		::scheLog:nWriteLN('}                                                                       ')
		::scheLog:nWriteLN('</STYLE>')
  		::scheLog:nWriteLN('<title>'+STR0004+'</title>')
		::scheLog:nWriteLN('</head>')
		::scheLog:nWriteLN('<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">')
		::scheLog:nWriteLN('<table width="80%"  border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
		::scheLog:nWriteLN('<tr>')
		::scheLog:nWriteLN('<td class="titulo"><div align="center">'+STR0004+ '</div></td>')
		::scheLog:nWriteLN('</tr>')
		::scheLog:nWriteLN('</table>')
		::scheLog:nWriteLN('<table width="80%"  border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
		::scheLog:nWriteLN('<tr>')
		::scheLog:nWriteLN('<td width="21%" class="cabecalho_1">'+STR0002+'</td>')
		::scheLog:nWriteLN('<td width="79%" class="cabecalho_1">'+STR0003+'</td>')
		::scheLog:nWriteLN('</tr>')
	endif
return .t.

/*
*Grava um evento no log.
*/
method lSche_WriteLog(cMensagem) class TBSCScheduler
	  ::scheLog:nWriteLN('<tr>')
	  ::scheLog:nWriteLN('<td class="texto">'+dToC(date())+ " " + time()+ '</td>')
	  ::scheLog:nWriteLN('<td class="texto">'+cMensagem+'</td>')
	  ::scheLog:nWriteLN('</tr>')
return .t.

/*
*Fecha o arquivo de log.
*/
method lSche_CloseLog() class TBSCScheduler
	::scheLog:nWriteLN('</table>')
	::scheLog:nWriteLN('<br>')
	::scheLog:nWriteLN('</body>')
	::scheLog:nWriteLN('</html>')
	::scheLog:lClose()

return .t.

function _BSCScheduler()
return
