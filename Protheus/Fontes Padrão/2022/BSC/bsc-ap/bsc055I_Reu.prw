#include "BIDefs.ch"
#include "BSCDefs.ch"
#Include "bsc055I_Reu.ch"

// ######################################################################################
// Projeto: BSC
// Modulo : bsc055I_Reu
// Fonte  : bsc055I_Reu.prw
// Utiliz : Gera o html do relatorio do book estrategico - Reuniao. 
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 09.05.05 | 1776 Alexandre Alves da Silva
// --------------------------------------------------------------------------------------
function bsc055I_Reu(oBSCCore,cReportName,cSpoolName,nParentID,cTarDe,cTarAte,cPath)
	local oHtmFile := TBIFileIO():New(oBSCCore:cBscPath()+"relato\" + cReportName)
	local oReuniao,oPes_X_Con,oPauta,oDocumento,oRetorno
	local aDadosCab := {}

	// Cria o arquivo htm
	if ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oBSCCore:Log(STR0001 + cReportName + "]", BSC_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL055A_ORG"*/
		oBSCCore:Log(STR0002, BSC_LOG_SCRFILE)/*//"Operação abortada"*/
		return
	endif

	oReuniao	:= oBSCCore:oGetTable("REUNIAO")
	oPes_X_Con	:= oBSCCore:oGetTable("REUCON")
	oPauta		:= oBSCCore:oGetTable("REUPAU")
	oDocumento	:= oBSCCore:oGetTable("REUDOC")
	oRetorno	:= oBSCCore:oGetTable("REURET")

	oReuniao:SetOrder(2) // Por ordem de Nome	
	oReuniao:cSQLFilter("PARENTID = " + cBIStr(nParentID) + " AND NOME BETWEEN '" + cTarDe + "' AND '" + cTarAte + "'") // Filtra pelo pai
	oReuniao:lFiltered(.t.)
	oReuniao:_First()

	while(!oReuniao:lEof())
		//Atualiza os dados do cabecalho
		BSC055PreCab(oBSCCore,oReuniao,@aDadosCab,nParentID)

		oHtmFile:nWriteLN('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">')
		oHtmFile:nWriteLN('<html>')
		oHtmFile:nWriteLN('<head>')
		oHtmFile:nWriteLN('<title>'+ STR0003 +'</title>') //"Book Estratégico:"		
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

		oHtmFile:nWriteLN('</head>')
		oHtmFile:nWriteLN('<body>')
		oHtmFile:nWriteLN('<table width="100%" border="0" cellpadding="0" cellspacing="7">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="0" valign="top"> <table width="100%" height="327" border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="61%" height="36" valign="top" background="'+ cPath+'images/topo_01_fundo.jpg"><img src="'+ cPath+'images/topo_01.jpg" width="772" height="70"></td>')
		oHtmFile:nWriteLN('<td width="39%" valign="top" background="'+ cPath+'images/topo_01_fundo.jpg">&nbsp;</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr bgcolor="#F5F5F3">')
		oHtmFile:nWriteLN('<td height="0" colspan="2" valign="top"> <table width="774" height="21" border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td colspan="2"><br /> <table width="769" border="0" align="center" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="171" valign="top"><div align="center"></div></td>')
		oHtmFile:nWriteLN('<td width="95" height="17" class="subTit">'+STR0025+'</td>')//Organizacao
		oHtmFile:nWriteLN('<td width="503" class="titOrgani">'+aDadosCab[1,2]+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td valign="top">&nbsp;</td>')
		oHtmFile:nWriteLN('<td height="20" colspan="2" class="subTit"><img src="'+ cPath+'images/linhadivisoriatitulo.jpg" width="100%" height="20" /></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="200">&nbsp;</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('<table width="775" border="0" cellspacing="2" cellpadding="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="22%" valign="top" class="text_01"><img src="'+ cPath+'images/icone_reuniao.gif" width="53" height="46" /></td>')
		oHtmFile:nWriteLN('<td width="10%" height="27" align="center" valign="middle" class="titOrgani">'+STR0004+'</td>')//Reuniao
		oHtmFile:nWriteLN('<td width="68%" colspan="5" valign="top"><table width="100%" height="43"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="41" bgcolor="#FFFFFF" class="titOrganiBlack">'+oReuniao:cValue("NOME")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td colspan="7"><table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="22%" class="text_01">'+STR0019+'</td>')//Data
		oHtmFile:nWriteLN('<td width="15%"><table width="97%" height="20"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+oReuniao:cValue("DATAREU")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('<td width="13%"><span class="text_01">'+STR0005+'</span></td>')//Horario de Inicio
		oHtmFile:nWriteLN('<td width="15%"><table width="97%" height="20"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+oReuniao:cValue("HORAINI")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('<td width="15%" nowrap="nowrap"><span class="text_01">'+STR0006+'</span></td>')//Horario de Termino
		oHtmFile:nWriteLN('<td width="20%"><table width="100%" height="20"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+oReuniao:cValue("HORAFIM")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td colspan="7"><table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="22%" class="text_01">'+STR0007+'</td>')//Local
		oHtmFile:nWriteLN('<td width="78%"><table width="100%" height="20"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+oReuniao:cValue("LOCAL")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td height="30" colspan="7"> <table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="22%" class="text_01">'+STR0008+'</td>')//Detalhes
		oHtmFile:nWriteLN('<td width="78%"><table width="100%" height="23"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="21" bgcolor="#FFFFFF" class="textTab">'+oReuniao:cValue("DETALHES")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="27" colspan="2" valign="top"><img src="'+ cPath+'images/linhadivisoriatitulo.jpg" width="100%" height="20" /></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('<table width="100%"  border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="1265" height="0"> <table width="100%"  border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td colspan="2"><img src="'+ cPath+'images/barra_tit_01_a.jpg" width="16" height="23"></td>')
		oHtmFile:nWriteLN('<td width="199" height="23" background="'+ cPath+'images/barra_tit_02_a.jpg">')
		oHtmFile:nWriteLN('<!-- Início do bloco para DIV Estatégia-->')
		oHtmFile:nWriteLN('<a href="'+ cPath+'images/barra_tit_02_a.jpg"><img src="'+ cPath+'images/barra_tit_02_a.jpg" width="199" height="23" border="0" align="absbottom"></a>')
		oHtmFile:nWriteLN('<!-- fim do bloco para DIV Estatégia-->')
		oHtmFile:nWriteLN('</td>')
		oHtmFile:nWriteLN('<div id="bar" class="subTit">'+STR0009+'</div>')//Lista de Pessoas Convocadas
		oHtmFile:nWriteLN('<td width="551"><div align="right"><img src="'+ cPath+'images/barra_tit_03_a.jpg" width="550" height="23"></div></td>')
		oHtmFile:nWriteLN('<td width="309" colspan="2" background="'+ cPath+'images/barra_tit_04_a.jpg" id="teste">&nbsp;</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td height="0" colspan="6"> <table width="760" id="tbl01">')
		oHtmFile:nWriteLN('<tr bgcolor="#7BA0CA">')
		oHtmFile:nWriteLN('<td width="390" bgcolor="#7BA0CA"><div align="center" id="tbl02" class="titTab">'+STR0010+'</div>')//Nome
		oHtmFile:nWriteLN('<div align="center" class="titTab"></div></td>')
		oHtmFile:nWriteLN('<td width="390" height="20" bgcolor="#7BA0CA"><div align="center" id="tbl02" class="titTab">'+STR0011+'</div>')//Cargo
		oHtmFile:nWriteLN('<div align="center" id="tbl02" class="titTab"></div>')
		oHtmFile:nWriteLN('<div align="center"></div>')
		oHtmFile:nWriteLN('<div align="center"></div></td>')
		oHtmFile:nWriteLN('</tr>')
		
		oPes_X_Con:lSoftSeek(3,{oReuniao:nValue("ID")}) 
		while(! oPes_X_Con:lEof() .and. oPes_X_Con:nValue("PARENTID")== oReuniao:nValue("ID"))					
			oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td width="390" class="textTab" id="tbl01">&nbsp;'+bsc055LisPes(oBSCCore,oPes_X_Con:nValue("PESSOAID"),oPes_X_Con:cValue("TIPOPESSOA"))+'</td>')
				oHtmFile:nWriteLN('<td width="390" height="20" class="textTab" id="tbl01">&nbsp;'+bsc055PesCar(oBSCCore,oPes_X_Con:nValue("PESSOAID"),oPes_X_Con:cValue("TIPOPESSOA"))+'')
				oHtmFile:nWriteLN('<div align="center" class="textTab">')
				oHtmFile:nWriteLN('</div>')
				oHtmFile:nWriteLN('<div align="center" class="textTab"></div></td>')
			oHtmFile:nWriteLN('</tr>')
			oPes_X_Con:_Next()
		enddo
		
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('<table width="100%"  border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td colspan="2"><img src="'+ cPath+'images/barra_tit_01_a.jpg" width="16" height="23"></td>')
		oHtmFile:nWriteLN('<td width="151">')
		oHtmFile:nWriteLN('<!-- Início do bloco para DIV Usuários-->')
		oHtmFile:nWriteLN('<img src="'+ cPath+'images/barra_tit_02_a.jpg" width="153" height="23" align="absbottom">')
		oHtmFile:nWriteLN('<!-- Fim do bloco para DIV Usuários-->')
		oHtmFile:nWriteLN('</td>')
		oHtmFile:nWriteLN('<div id="bar" class="subTit">'+STR0012+'</div>')//Lista da Pauta
		oHtmFile:nWriteLN('<td width="594"><img src="'+ cPath+'images/barra_tit_03_a.jpg" width="594" height="23"></td>')
		oHtmFile:nWriteLN('<td width="490" colspan="2" background="'+ cPath+'images/barra_tit_04_a.jpg"><img src="'+ cPath+'images/fundo_barra_tit.jpg" width="1" height="7"></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td height="0" colspan="6"> <table width="760" id="tbl01">')
		oHtmFile:nWriteLN('<tr bgcolor="#7BA0CA">')
		oHtmFile:nWriteLN('<td width="190" bgcolor="#7BA0CA"><div align="center" id="tbl02" class="titTab">'+STR0013+'</div></td>')//Pauta
		oHtmFile:nWriteLN('<td width="190" bgcolor="#7BA0CA"><div align="center" id="tbl02" class="titTab">'+STR0014+'</div></td>')//Estrategia
		oHtmFile:nWriteLN('<td width="190" bgcolor="#7BA0CA"><div align="center" id="tbl02" class="titTab">'+STR0015+'</div></td>')//Descricao
		oHtmFile:nWriteLN('<td width="190" height="20" bgcolor="#7BA0CA"><div align="center" id="tbl02" class="titTab">'+STR0016+'</div>')//Detalhes
		oHtmFile:nWriteLN('<div align="center"></div>')
		oHtmFile:nWriteLN('<div align="center"></div></td>')
		oHtmFile:nWriteLN('</tr>')
		
		//Lista de Pauta
		oPauta:lSoftSeek(3,{oReuniao:nValue("ID")}) 
		while(! oPauta:lEof() .and. oPauta:nValue("PARENTID")==oReuniao:nValue("ID"))
			oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td width="190" class="textTab" id="tbl01">' + oPauta:cValue("ORG")	+ '</td>')
				oHtmFile:nWriteLN('<td width="190" class="textTab" id="tbl01">' + oPauta:cValue("EST")	+ '</td>')
				oHtmFile:nWriteLN('<td width="190" class="textTab" id="tbl01">' + oPauta:cValue("NOME")	+ '</td>')
				oHtmFile:nWriteLN('<td width="190" height="20" class="textTab" id="tbl01">'+ oPauta:cValue("DETALHES")	+ '')
				oHtmFile:nWriteLN('<div align="center" class="textTab"> </div>')
				oHtmFile:nWriteLN('<div align="center" class="textTab"></div></td>')
			oHtmFile:nWriteLN('</tr>')
			oPauta:_Next()
		enddo
		
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('<table width="100%"  border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td colspan="2"><img src="'+ cPath+'images/barra_tit_01_a.jpg" width="16" height="23" /></td>')
		oHtmFile:nWriteLN('<td width="151">')
		oHtmFile:nWriteLN('<!-- In&iacute;cio do bloco para DIV Usu&aacute;rios-->')
		oHtmFile:nWriteLN('<img src="'+ cPath+'images/barra_tit_02_a.jpg" width="153" height="23" align="absbottom" />')
		oHtmFile:nWriteLN('<!-- Fim do bloco para DIV Usu&aacute;rios-->')
		oHtmFile:nWriteLN('</td>')
		oHtmFile:nWriteLN('<div id="bar" class="subTit">'+STR0017+'</div>')//Lista de Retornos
		oHtmFile:nWriteLN('<td width="594"><img src="'+ cPath+'images/barra_tit_03_a.jpg" width="594" height="23" /></td>')
		oHtmFile:nWriteLN('<td width="490" colspan="2" background="'+ cPath+'images/barra_tit_04_a.jpg"><img src="'+ cPath+'images/fundo_barra_tit.jpg" width="1" height="7" /></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td height="0" colspan="6"> <table width="760" id="tbl01">')
		oHtmFile:nWriteLN('<tr bgcolor="#7BA0CA">')
		oHtmFile:nWriteLN('<td width="145" height="20"><div align="center"><span class="titTab">'+STR0018+'</span></div></td>')//Retorno
		oHtmFile:nWriteLN('<td width="151"><div align="center" id="tbl02" class="titTab">'+STR0015+'</div></td>')//Descricao
		oHtmFile:nWriteLN('<td width="91"><div align="center" id="tbl02" class="titTab">'+STR0019+'</div></td>')//Data
		oHtmFile:nWriteLN('<td width="86"><div align="center" id="tbl02" class="titTab">'+STR0020+'</div></td>')//Hora
		oHtmFile:nWriteLN('<td width="263"><div align="center" id="tbl02" class="titTab">'+STR0021+'</div></td>')//Responsavel
		oHtmFile:nWriteLN('</tr>')

		oRetorno:lSoftSeek(3,{oReuniao:nValue("ID")}) 
		while(! oRetorno:lEof() .and. oRetorno:nValue("PARENTID")==oReuniao:nValue("ID"))
			oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td width="145" height="20" class="textTab" id="tbl01">&nbsp;' + oRetorno:cValue("NOME")		+ '</td>')
				oHtmFile:nWriteLN('<td width="151" class="textTab" id="tbl01">&nbsp;' + oRetorno:cValue("TEXTO")		+ '</td>')
				oHtmFile:nWriteLN('<td width="91" align="center" class="textTab" id="tbl01">&nbsp;' + oRetorno:cValue("DATAR")		+ '</td>')
				oHtmFile:nWriteLN('<td width="86" align="center" class="textTab" id="tbl01">&nbsp;' + oRetorno:cValue("HORAR")		+ '</td>')
				oHtmFile:nWriteLN('<td width="263" class="textTab" id="tbl01">&nbsp;'+bsc055LisPes(oBSCCore,oRetorno:nValue("RESPID"),oRetorno:cValue("TIPOPESSOA"))+'</td>')
			oHtmFile:nWriteLN('</tr>')
			oRetorno:_Next()
		enddo
		
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('<table width="100%"  border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td colspan="2"><img src="'+ cPath+'images/barra_tit_01_a.jpg" width="16" height="23" /></td>')
		oHtmFile:nWriteLN('<td width="151">')
		oHtmFile:nWriteLN('<!-- In&iacute;cio do bloco para DIV Usu&aacute;rios-->')
		oHtmFile:nWriteLN('<img src="'+ cPath+'images/barra_tit_02_a.jpg" width="153" height="23" align="absbottom" />')
		oHtmFile:nWriteLN('<!-- Fim do bloco para DIV Usu&aacute;rios-->')
		oHtmFile:nWriteLN('</td>')
		oHtmFile:nWriteLN('<div id="bar" class="subTit">'+STR0022+'</div>')//Lista de Documentos
		oHtmFile:nWriteLN('<td width="594"><img src="'+ cPath+'images/barra_tit_03_a.jpg" width="594" height="23" /></td>')
		oHtmFile:nWriteLN('<td width="490" colspan="2" background="'+ cPath+'images/barra_tit_04_a.jpg"><img src="'+ cPath+'images/fundo_barra_tit.jpg" width="1" height="7" /></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td height="0" colspan="6"> <table width="760" id="tbl01">')
		oHtmFile:nWriteLN('<tr bgcolor="#7BA0CA">')
		oHtmFile:nWriteLN('<td width="190" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0024+'</div></td>')//Documento
		oHtmFile:nWriteLN('<td width="190" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0015+'</div></td>')//Descricao
		oHtmFile:nWriteLN('<td width="190" height="20" bgcolor="#7BA0CA"><div align="center" id="tbl02" class="titTab">'+STR0024+'</div>')//Link
		oHtmFile:nWriteLN('<div align="center"></div>')
		oHtmFile:nWriteLN('<div align="center"></div></td>')
		oHtmFile:nWriteLN('</tr>')
		
		//Lista de Documentos
		oDocumento:lSoftSeek(3,{oReuniao:nValue("ID")}) 
		while(! oDocumento:lEof() .and. oDocumento:nValue("PARENTID")==oReuniao:nValue("ID"))
			oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td width="190" class="textTab" id="tbl01">&nbsp;' + oDocumento:cValue("NOME")		+ '</td>')
				oHtmFile:nWriteLN('<td width="190" class="textTab" id="tbl01">&nbsp;' + oDocumento:cValue("DESCRICAO")	+ '</td>')
				oHtmFile:nWriteLN('<td width="190" height="20" class="textTab" id="tbl01">&nbsp;' + oDocumento:cValue("LINK")		+ '')
				oHtmFile:nWriteLN('<div align="center" class="textTab"></div></td>')
			oHtmFile:nWriteLN('</tr>')

			oDocumento:_Next()
		enddo
		
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('</body>')
		oHtmFile:nWriteLN('</html>')
		oHtmFile:nWriteLN('<br>')
		oHtmFile:nWriteLN('<DIV style="page-break-after:always"></DIV> ')		

		oReuniao:_Next()
	enddo

	oReuniao:cSQLFilter("") // Encerra filtro
	
	//Faz a copia do relatorio para o diretorio de Spool
	//oHtmFile:lCopyFile("relato\Spool\" + cSpoolName)	
	
	oHtmFile:lClose()
	
Return      

function _BSC055i_Reu()
return