#include "BIDefs.ch"
#include "BSCDefs.ch"
#Include "bsc055_Desc.ch"

// ######################################################################################
// Projeto: BSC
// Modulo : bsc055_Desc
// Fonte  : BSC055_Desc.prw
// Utiliz : Gera o html do relatorio do book estrategico - Estrategia. 
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 09.05.05 | 1776 Alexandre Alves da Silva
// --------------------------------------------------------------------------------------
function bsc055_Desc(oBSCCore,cReportName,cSpoolName,nContextID,nReportId,cPath)
	local oReport, oOrganizacao
	local oHtmFile := TBIFileIO():New(oBSCCore:cBscPath()+"relato\" + cReportName)

	// Cria o arquivo htm
	If ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oBSCCore:Log(STR0001 + cReportName+ "]", BSC_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL055A_ORG"*/
		oBSCCore:Log(STR0002, BSC_LOG_SCRFILE)/*//"Operação abortada"*/
		return
	endif

	oReport	:= oBSCCore:oGetTable("RELBOOKSTRA")

	if(oReport:lSeek(1,{nReportId})	)
		//Atualiza os dados do cabecalho
		oOrganizacao := oBSCCore:oAncestor("ORGANIZACAO", oReport)

		// Montagem do cabeçalho do html
		oHtmFile:nWriteLN('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">')
		oHtmFile:nWriteLN('<html>')
		oHtmFile:nWriteLN('<head>')
		oHtmFile:nWriteLN('<title>'+ STR0003 +'</title>') //"Book Estratégico Descrição"					
		oHtmFile:nWriteLN('<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"/>')
    	oHtmFile:nWriteLN('<META HTTP-EQUIV="Pragma" CONTENT="no-cache"> ')
        oHtmFile:nWriteLN('<META HTTP-EQUIV="Expires" CONTENT="-1"> ')		
		oHtmFile:nWriteLN('<script language="JavaScript" type="text/JavaScript">')
		oHtmFile:nWriteLN('<!--')
		oHtmFile:nWriteLN('function MM_reloadPage(init) {  //reloads the window if Nav4 resized')
		  oHtmFile:nWriteLN('if (init==true) with (navigator) {if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {')
		    oHtmFile:nWriteLN('document.MM_pgW=innerWidth; document.MM_pgH=innerHeight; onresize=MM_reloadPage; }}')
		  oHtmFile:nWriteLN('else if (innerWidth!=document.MM_pgW || innerHeight!=document.MM_pgH) location.reload();')
		oHtmFile:nWriteLN('}')
		oHtmFile:nWriteLN('MM_reloadPage(true);')
		oHtmFile:nWriteLN('//-->')
		oHtmFile:nWriteLN('</script>')
		oHtmFile:nWriteLN('<link href="'+cPath+'images/bscRel055.css" rel="stylesheet" type="text/css" />')
		oHtmFile:nWriteLN('</head>')

		oHtmFile:nWriteLN('<body>')
		oHtmFile:nWriteLN('<table width="100%" border="0" cellpadding="0" cellspacing="7">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="298" valign="top"> <table width="100%" height="239" border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="61%" height="36" valign="top" background="'+cPath+'images/topo_01_fundo.jpg"><img src="'+ cPath+'images/topo_01.jpg" width="772" height="70"></td>')
		oHtmFile:nWriteLN('<td width="39%" valign="top" background="'+ cPath+'images/topo_01_fundo.jpg">&nbsp;</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr bgcolor="#F5F5F3">')
		oHtmFile:nWriteLN('<td height="149" colspan="2" valign="top"> <table width="773" height="149"  border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="149"> <table width="769" border="0" align="center" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="171" valign="top"><div align="center"></div></td>')
		oHtmFile:nWriteLN('<td width="95" height="17" class="subTit">'+STR0006+'</td>')//Organizacao
		oHtmFile:nWriteLN('<td width="503" class="titOrgani">'+oOrganizacao:cValue("NOME")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td valign="top">&nbsp;</td>')
		oHtmFile:nWriteLN('<td height="20" colspan="2" class="subTit"><img src="'+ cPath+'images/linhadivisoriatitulo.jpg" width="100%" height="20" /></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('<table width="775" border="0" cellspacing="2" cellpadding="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="11%" valign="top" class="text_01"><img src="'+ cPath+'images/logo.jpg" width="53" height="46" /></td>')
		oHtmFile:nWriteLN('<td width="11%" height="27" align="center" valign="middle" class="titOrgani">'+STR0004+'</td>')//Relatorio
		oHtmFile:nWriteLN('<td width="78%" colspan="5" valign="top"><table width="100%" height="43"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="41" bgcolor="#FFFFFF" class="titOrganiBlack">'+oReport:cValue("NOME")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td height="29" colspan="7"> <table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="11%" class="text_01">'+STR0005+'</td>')//Descricao
		oHtmFile:nWriteLN('<td width="81%"><table width="100%" height="23"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="21" bgcolor="#FFFFFF" class="textTab">'+oReport:cValue("DESCRICAO")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" colspan="2" valign="top"><img src="'+ cPath+'images/linhadivisoriatitulo.jpg" width="100%" height="20" /></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('</body>')
		oHtmFile:nWriteLN('</html>')

		//Faz a copia do relatorio para o diretorio de Spool
		//oHtmFile:lCopyFile("relato\Spool\" + cSpoolName)	
		
		oHtmFile:lClose()
	endif
	
return .t.
