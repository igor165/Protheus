#include "BIDefs.ch"
#include "BSCDefs.ch"
#Include "bsc055G_Ini.ch"

// ######################################################################################
// Projeto: BSC
// Modulo : bsc055G_Ini
// Fonte  : bsc055G_Ini.prw
// Utiliz : Gera o html do relatorio do book estrategico - Estrategia. 
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 09.05.05 | 1776 Alexandre Alves da Silva
// --------------------------------------------------------------------------------------
function bsc055G_Ini(oBSCCore,cReportName,cSpoolName,nContextID,cIniDe,cIniAte,cPath)
	local oHtmFile := TBIFileIO():New(oBSCCore:cBscPath()+"relato\" + cReportName)
	local oIniciativa,oTarefa,oDocumento
	local aDadosCab := {}

	// Cria o arquivo htm
	if ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oBSCCore:Log(STR0001 + cReportName+ "]", BSC_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL055A_ORG"*/
		oBSCCore:Log(STR0002, BSC_LOG_SCRFILE)/*//"Operação abortada"*/
		return
	endif

	oIniciativa := oBSCCore:oGetTable("INICIATIVA")
	oTarefa		:= oBSCCore:oGetTable("TAREFA")
	oDocumento	:= oBSCCore:oGetTable("INIDOC")

	oIniciativa:SetOrder(2) // Por ordem de Nome
	oIniciativa:cSQLFilter("CONTEXTID = " + cBIStr(nContextID) + " AND NOME BETWEEN '" + cIniDe + "' AND '" + cIniAte + "'") // Filtra pelo pai
	oIniciativa:lFiltered(.t.)
	oIniciativa:_First()
	while(!oIniciativa:lEof())
		//Atualiza os dados do cabecalho
		BSC055PreCab(oBSCCore,oIniciativa,@aDadosCab,nContextID)

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

		oHtmFile:nWriteLN('<body>')
		oHtmFile:nWriteLN('<table width="100%" border="0" cellpadding="0" cellspacing="7">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="100%" valign="top"><table width="100%" height="480" border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="61%" height="36" valign="top" background="'+ cPath+'images/topo_01_fundo.jpg"><img src="'+ cPath+'images/topo_01.jpg" width="772" height="70"></td>')
		oHtmFile:nWriteLN('<td width="39%" valign="top" background="'+ cPath+'images/topo_01_fundo.jpg">&nbsp;</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr bgcolor="#F5F5F3">')
		oHtmFile:nWriteLN('<td height="229" colspan="2" valign="top"><table width="774" border="0" cellspacing="0" cellpadding="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="774"><br />')
		oHtmFile:nWriteLN('<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="67" rowspan="6" valign="top"><div align="center"></div></td>')
		oHtmFile:nWriteLN('<td width="125" height="17" class="subTit">'+STR0004+'</td>')//Organizacao
		oHtmFile:nWriteLN('<td colspan="2"><span class="titOrgani">'+ aDadosCab[1,2] +'</span></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="17" class="subTit">'+STR0005+'</td>')//Estrategia
		oHtmFile:nWriteLN('<td colspan="2"><span class="titOrgani">'+ aDadosCab[2,2] +'</span></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="8" class="subTit">'+STR0006+'</td>')//Perspectiva
		oHtmFile:nWriteLN('<td colspan="2"><span class="titOrgani">'+ aDadosCab[3,2] +'</span></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="8" class="subTit">'+STR0007+'</td>')//Objetivo
		oHtmFile:nWriteLN('<td colspan="2" class="titOrgani">'+ aDadosCab[4,2]+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="16" colspan="3"><img src="'+ cPath+'images/linhadivisoriatitulo.jpg" width="100%" height="14" /></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="10" colspan="2" class="subTit">'+STR0008+'</td>')//Responsavel
		oHtmFile:nWriteLN('<td width="627" height="0" class="subTit2">'+bsc055LisPes(oBSCCore,oIniciativa:nValue("RESPID"),oIniciativa:cValue("TIPOPESSOA"))+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td valign="top">&nbsp;</td>')
		oHtmFile:nWriteLN('<td height="19" colspan="3"><img src="'+ cPath+'images/linhadivisoriatitulo.jpg" width="100%" height="14" /></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table> </td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td>&nbsp;</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('<table width="775" border="0" cellspacing="2" cellpadding="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="79" valign="top" class="text_01"><img src="'+ cPath+'images/icone_iniciativa.gif" width="51" height="46" /></td>')
		oHtmFile:nWriteLN('<td width="87" height="23" valign="middle" class="titOrgani">'+STR0009+'</td>')//Iniciativa
		oHtmFile:nWriteLN('<td width="601" colspan="2" valign="top"><table width="100%" height="45"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="titOrganiBlack">&nbsp;'+oIniciativa:cValue("NOME")+' </td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="27" colspan="4" valign="middle" class="text_01"><table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="10%" class="text_01">'+STR0010+'</td>')//Descricao
		oHtmFile:nWriteLN('<td width="90%"><table width="100%" height="25"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="23" bgcolor="#FFFFFF" class="textTab">&nbsp;'+oIniciativa:cValue("DESCRICAO")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table> </td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td colspan="4"><table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="10%" height="21" class="text_01">'+STR0011+'</td>')//Data Inicio
		oHtmFile:nWriteLN('<td width="39%"><table width="100%" height="25"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="23" bgcolor="#FFFFFF" class="textTab">&nbsp;'+oIniciativa:cValue("DATAINI")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('<td width="10%" align="center" class="text_01">'+STR0012+'</td>')//Data Final
		oHtmFile:nWriteLN('<td width="41%"><table width="100%" height="25"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="23" bgcolor="#FFFFFF" class="textTab">&nbsp;'+oIniciativa:cValue("DATAFIN")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td colspan="4"><table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="10%" align="right" height="21" class="text_01">'+STR0013+'</td>')//%Completo
		oHtmFile:nWriteLN('<td width="39%"><table width="100%" height="25"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="23" align="right" bgcolor="#FFFFFF" class="textTab">&nbsp;'+oIniciativa:cValue("COMPLETADO")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('<td width="10%" align="center" class="text_01">'+STR0014+'</td>')//Status
		oHtmFile:nWriteLN('<td width="41%"><table width="100%" height="25"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="23" bgcolor="#FFFFFF" class="textTab">&nbsp;'+oIniciativa:cValue("SITUACAO")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td height="25" colspan="4"> <table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="10%" height="21" class="text_01">&nbsp;</td>')
		oHtmFile:nWriteLN('<td width="39%" align="center" class="titOrgani">'+STR0015+'</td>')//Estimado
		oHtmFile:nWriteLN('<td width="10%" class="text_01">&nbsp;</td>')
		oHtmFile:nWriteLN('<td width="41%" align="center" class="titOrgani">'+STR0016+'</td>')//Real
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td height="31" colspan="4"> <table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="10%"  height="21" class="text_01">'+STR0017+'</td>')//Horas Estimada
		oHtmFile:nWriteLN('<td width="39%"><table width="100%" height="25"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="23" align="right" bgcolor="#FFFFFF" class="textTab">&nbsp;'+oIniciativa:cValue("HORASEST")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('<td width="10%" align="center" class="text_01">'+STR0017+'</td>')//Horas Real
		oHtmFile:nWriteLN('<td width="41%"><table width="100%" height="25"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="23" align="right" bgcolor="#FFFFFF" class="textTab">&nbsp;'+oIniciativa:cValue("HORASREAL")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td height="19" colspan="4"><table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="10%" height="21" class="text_01">'+STR0018+'</td>')//Horas
		oHtmFile:nWriteLN('<td width="39%"> <table width="100%" height="25"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="23" align="right" bgcolor="#FFFFFF" class="textTab">&nbsp;'+oIniciativa:cValue("CUSTOEST")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('<td width="10%" align="center" class="text_01">'+STR0018+'</td>')//Custos
		oHtmFile:nWriteLN('<td width="41%"><table width="100%" height="25"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="23" bgcolor="#FFFFFF" align="right" class="textTab">&nbsp;'+oIniciativa:cValue("CUSTOREAL")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" colspan="2" valign="top"><img src="'+ cPath+'images/linhadivisoriatitulo.jpg" width="100%" height="15" /></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>		<table width="100%"  border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="1265" height="0" valign="top"> <table width="100%"  border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td colspan="2"><img src="'+ cPath+'/images/barra_tit_01_a.jpg" width="16" height="23" /></td>')
		oHtmFile:nWriteLN('<td width="159">')
		oHtmFile:nWriteLN('<!-- In&iacute;cio do bloco para DIV Usu&aacute;rios-->')
		oHtmFile:nWriteLN('<img src="'+ cPath+'/images/barra_tit_02_a.jpg" width="159" height="23" align="absbottom" />')
		oHtmFile:nWriteLN('<!-- Fim do bloco para DIV Usu&aacute;rios-->')
		oHtmFile:nWriteLN('</td>')
		oHtmFile:nWriteLN('<div id="bar" class="subTit">'+STR0019+'</div>')//Lista de Tarefas
		oHtmFile:nWriteLN('<td width="594"><img src="'+ cPath+'/images/barra_tit_03_a.jpg" width="594" height="23" /></td>')
		oHtmFile:nWriteLN('<td width="480" colspan="2" background="'+ cPath+'/images/barra_tit_04_a.jpg"><img src="'+ cPath+'/images/fundo_barra_tit.jpg" width="1" height="7" /></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td height="0" colspan="6"> <table width="760" id="tbl01">')
		oHtmFile:nWriteLN('<tr bgcolor="#7BA0CA">')
		oHtmFile:nWriteLN('<td width="390" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0020+'</div>')//Tarefa
		oHtmFile:nWriteLN('<div align="center" class="titTab"></div></td>')
		oHtmFile:nWriteLN('<td width="390" height="20" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0021+'</div>')//Descricao
		oHtmFile:nWriteLN('<div align="center"></div>')
		oHtmFile:nWriteLN('<div align="center"></div></td>')
		oHtmFile:nWriteLN('</tr>')

		//Lista de Tarefas
		oTarefa:lSoftSeek(3,{oIniciativa:nValue("ID")}) 
		while(! oTarefa:lEof() .and. oTarefa:nValue("PARENTID")== oIniciativa:nValue("ID"))
			oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td width="390" class="textTab" id="tbl01">&nbsp;' + oTarefa:cValue("NOME")+ '</td>')
				oHtmFile:nWriteLN('<td width="390" height="20" class="textTab" id="tbl01">&nbsp;' + oTarefa:cValue("TEXTO")	+ '')
				oHtmFile:nWriteLN('<div align="center" class="textTab">')
				oHtmFile:nWriteLN('</div>')
			oHtmFile:nWriteLN('<div align="center" class="textTab"></div></td>')
			oTarefa:_Next()
		enddo
		
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table> </td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table> </td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('<table width="100%"  border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td colspan="2"><img src="'+ cPath+'/images/barra_tit_01_a.jpg" width="16" height="23" /></td>')
		oHtmFile:nWriteLN('<td width="151">')
		oHtmFile:nWriteLN('<!-- In&iacute;cio do bloco para DIV Usu&aacute;rios-->')
		oHtmFile:nWriteLN('<img src="'+ cPath+'/images/barra_tit_02_a.jpg" width="153" height="23" align="absbottom" />')
		oHtmFile:nWriteLN('<!-- Fim do bloco para DIV Usu&aacute;rios-->')
		oHtmFile:nWriteLN('</td><div id="bar" class="subTit">'+STR0022+'</div>')//Lista de Documentos
		oHtmFile:nWriteLN('<td width="594"><img src="'+ cPath+'/images/barra_tit_03_a.jpg" width="594" height="23" /></td>')
		oHtmFile:nWriteLN('<td width="490" colspan="2" background="'+ cPath+'/images/barra_tit_04_a.jpg"><img src="'+ cPath+'/images/fundo_barra_tit.jpg" width="1" height="7" /></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td height="0" colspan="6">')
		oHtmFile:nWriteLN('<table width="760" id="tbl01">')
		oHtmFile:nWriteLN('<tr bgcolor="#7BA0CA">')
		oHtmFile:nWriteLN('<td width="34%" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0023+'</div></td>')//Documento
		oHtmFile:nWriteLN('<td width="33%" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0021+'</div></td>')//Descricao
		oHtmFile:nWriteLN('<td width="33%" height="20" bgcolor="#7BA0CA"><div align="center" id="tbl02" class="titTab">'+STR0024+'</div>')//Link
		oHtmFile:nWriteLN('<div align="center"></div>')
		oHtmFile:nWriteLN('<div align="center"></div></td>')
		oHtmFile:nWriteLN('</tr>')

		//Lista de Documentos
		oDocumento:lSoftSeek(3,{oIniciativa:nValue("ID")}) 
		while(! oDocumento:lEof() .and. oDocumento:nValue("PARENTID")==oIniciativa:nValue("ID"))
			oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td width="34%" class="textTab" id="tbl01">&nbsp;' + oDocumento:cValue("NOME")		+ '</td>')
				oHtmFile:nWriteLN('<td width="33%" class="textTab" id="tbl01">&nbsp;' + oDocumento:cValue("DESCRICAO")	+ '</td>')
				oHtmFile:nWriteLN('<td width="33%" class="textTab" id="tbl01">&nbsp;' + oDocumento:cValue("LINK")		+ '</td>')
				oHtmFile:nWriteLN('<div align="center" class="textTab"></div></td>')
			oHtmFile:nWriteLN('</tr>')

			oDocumento:_Next()
		enddo

		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('</body>')
		oHtmFile:nWriteLN('</html>')
		oHtmFile:nWriteLN('<br>')
		oHtmFile:nWriteLN('<DIV style="page-break-after:always"></DIV> ')		
		oIniciativa:_Next()
	end

	oIniciativa:cSQLFilter("") // Encerra filtro

	//Faz a copia do relatorio para o diretorio de Spool
	//oHtmFile:lCopyFile("relato\Spool\" + cSpoolName)	
	
	oHtmFile:lClose()

Return