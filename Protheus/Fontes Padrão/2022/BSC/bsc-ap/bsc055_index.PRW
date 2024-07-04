#include "BIDefs.ch"
#include "BSCDefs.ch"
#Include "bsc055_Index.ch"

// ######################################################################################
// Projeto: BSC
// Modulo : Book Estrategico
// Fonte  : bsc055A_Org.prw
// Utiliz : Gera o html do relatorio do book estrategico - Organizacao.
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 23.05.05 | 1776 Alexandre Alves da Silva
// --------------------------------------------------------------------------------------
function bsc055_Index(oBSCCore,cReportName,cSpoolName,aReportLink,cPath)
	local nLink := 0, oHtmFile


		oHtmFile := TBIFileIO():New(oBSCCore:cBscPath()+"relato\" + cReportName)

		// Cria o arquivo htm
		If ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
			oBSCCore:Log(STR0001 + cReportName+ "]", BSC_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL055A_ORG"*/
			oBSCCore:Log(STR0002, BSC_LOG_SCRFILE)/*//"Operação abortada"*/
			return
		endif
		oHtmFile:nWriteLN('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">')
		oHtmFile:nWriteLN('<html>')
		oHtmFile:nWriteLN('<head>')
		oHtmFile:nWriteLN('<title>'+ STR0003 +'</title>') //"Book Estratégico Índice:"		
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
		oHtmFile:nWriteLN('<link href="'+ cPath+'images/bscRel055.css" rel="stylesheet" type="text/css" />')
		oHtmFile:nWriteLN('</head>')

		oHtmFile:nWriteLN('<table width="100%" border="0" cellpadding="0" cellspacing="7">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td valign="top"><table width="100%" height="256" border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="61%" height="70" valign="top" background="'+ cPath+'images/topo_01_fundo.jpg"><img src="'+ cPath+'images/topo_01.jpg" width="772" height="70"></td>')
		oHtmFile:nWriteLN('<td width="39%" valign="top" background="'+ cPath+'images/topo_01_fundo.jpg">&nbsp;</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr bgcolor="#F5F5F3">')
		oHtmFile:nWriteLN('<td height="155" colspan="2" valign="top"><table width="75%" height="290"  border="0" align="left" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr valign="bottom" background="'+ cPath+'images/barra_tit_04_a.jpg">')
		oHtmFile:nWriteLN('<td height="23" colspan="2"><strong><font color="#574FA2" size="2" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;&nbsp;&nbsp;&nbsp;<font color="#333333">'+STR0003+'</font></font></strong></td>')//"Book Estratégico Índice:"		
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="8%">&nbsp;</td>')
		oHtmFile:nWriteLN('<td width="92%">&nbsp;</td>')
		oHtmFile:nWriteLN('</tr>')
			for nLink := 1 to len(aReportLink)
				if(empty(aReportLink[nLink,4]))
					aReportLink[nLink,4] := "images/icone_relatorio.gif"
				endif
				oHtmFile:nWriteLN('<tr>')		
		            oHtmFile:nWriteLN('<td height="20"><div align="center"><img src="'+ cPath + aReportLink[nLink,4] + '" width="20" height="20"></div></td>')
        		    oHtmFile:nWriteLN('<td height="20" class="form_input"><a href="' + cPath + 'relato/' + aReportLink[nLink,2] + '.html ' + '" target="_top">'+ aReportLink[nLink,1]+'</a></td>')
				oHtmFile:nWriteLN('</tr>')
			next nLink				
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="25">&nbsp;</td>')
		oHtmFile:nWriteLN('<td height="25">&nbsp;</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" colspan="2" valign="top"><img src="'+ cPath+'images/linhadivisoriatitulo.jpg" width="100%" height="20" /></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')  

		oHtmFile:lClose()
		oHtmFile := Nil

return                         

