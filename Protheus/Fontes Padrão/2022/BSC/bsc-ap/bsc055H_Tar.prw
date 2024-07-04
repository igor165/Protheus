#include "BIDefs.ch"
#include "BSCDefs.ch"
#Include "bsc055H_Tar.ch"

// ######################################################################################
// Projeto: BSC
// Modulo : bsc055H_Tar
// Fonte  : bsc055H_Tar.prw
// Utiliz : Gera o html do relatorio do book estrategico - Estrategia.
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 09.05.05 | 1776 Alexandre Alves da Silva
// --------------------------------------------------------------------------------------
function bsc055H_Tar(oBSCCore,cReportName,cSpoolName,nContextID,cTarDe,cTarAte,nImportancia,nUrgencia,cPath)
	local oHtmFile := TBIFileIO():New(oBSCCore:cBscPath()+"relato\" + cReportName)
	local oTarefa,oPes_X_Cob,oRetorno,oDocumento
	local aDadosCab := {}, cFiltro := "", cImportancia := "", cUrgencia := ""
	local oImportancia, oUrgencia

	// Cria o arquivo htm
	if ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oBSCCore:Log(STR0001 + cReportName + "]", BSC_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL055A_ORG"*/
		oBSCCore:Log(STR0002, BSC_LOG_SCRFILE)/*//"Operação abortada"*/
		return
	endif
	
	oTarefa		:= oBSCCore:oGetTable("TAREFA")
	oPes_X_Cob	:= oBSCCore:oGetTable("TARCOB")
	oRetorno  	:= oBSCCore:oGetTable("RETORNO")
	oDocumento 	:= oBSCCore:oGetTable("TARDOC")

	// Virtual Fields
	oTarefa:SetOrder(2) // Por ordem de Nome
	cFiltro := "CONTEXTID = " + cBIStr(nContextID) + " AND NOME BETWEEN '" + cTarDe + "' AND '" + cTarAte + "'" // Filtra pelo pai
	if(val(nImportancia) > 0) // Selecionou Importancia
		cFiltro += " AND IMPORTANCI = " + cBIStr(nImportancia)
	endif
	if(val(nUrgencia) > 0) // Selecionou Urgencia
		cFiltro += " AND URGENCIA = " + cBIStr(nUrgencia)
	endif
	oTarefa:cSQLFilter(cFiltro) // Filtra pelo pai
	oTarefa:SetOrder(4)  //{"URGENCIA","NOME", "CONTEXTID"})
	oTarefa:lFiltered(.t.)
	oTarefa:_First()
	oImportancia := oTarefa:oXMLImportancia()
	oUrgencia := oTarefa:oXMLUrgencia()
	while(!oTarefa:lEof())
		//Atualiza os dados do cabecalho
		BSC055PreCab(oBSCCore,oTarefa,@aDadosCab,nContextID)

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
		oHtmFile:nWriteLN('<td height="0" valign="top"> <table width="100%" height="529" border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="61%" height="36" valign="top" background="'+ cPath+'images/topo_01_fundo.jpg"><img src="'+ cPath+'images/topo_01.jpg" width="772" height="70"></td>')
		oHtmFile:nWriteLN('<td width="39%" valign="top" background="'+ cPath+'images/topo_01_fundo.jpg">&nbsp;</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr bgcolor="#F5F5F3">')
		oHtmFile:nWriteLN('<td height="229" colspan="2" valign="top"> <table width="774" border="0" cellspacing="0" cellpadding="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="774"><br /> <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="67" rowspan="5" valign="top"><div align="center"></div></td>')
		oHtmFile:nWriteLN('<td width="116" height="17" class="subTit">'+STR0004+'</td>')//Organizacao
		oHtmFile:nWriteLN('<td width="591" colspan="2"><span class="titOrgani">'+aDadosCab[1,2]+'</span></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="17" class="subTit">'+STR0005+'</td>')//Estrategia
		oHtmFile:nWriteLN('<td colspan="2"><span class="titOrgani">'+aDadosCab[2,2]+'</span></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="8" class="subTit">'+STR0007+'</td>')//Perspectiva
		oHtmFile:nWriteLN('<td colspan="2"><span class="titOrgani">'+aDadosCab[3,2]+'</span></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="8" class="subTit">'+STR0008+'</td>')//Objetivo
		oHtmFile:nWriteLN('<td colspan="2" class="titOrgani">'+aDadosCab[4,2]+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="8" class="subTit">'+STR0009+'</td>')//Iniciativa
		oHtmFile:nWriteLN('<td colspan="2" class="titOrgani">'+aDadosCab[5,2]+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td valign="top">&nbsp;</td>')
		oHtmFile:nWriteLN('<td height="19" colspan="3"><img src="'+ cPath+'images/linhadivisoriatitulo.jpg" width="100%" height="14" /></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td>&nbsp;</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('<table width="774" border="0" cellspacing="2" cellpadding="0">')
		
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="15%" valign="top" class="text_01"><img src="'+ cPath+'images/icones-tarefa.gif" width="56" height="46" /></td>')
		oHtmFile:nWriteLN('<td width="10%" height="46" align="center" valign="middle" class="titOrgani">'+STR0010+'</td>')//Tarefa
		oHtmFile:nWriteLN('<td width="75%" colspan="2" valign="top"> <div align="left">')
		oHtmFile:nWriteLN('<table width="100%" height="44"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		
		oHtmFile:nWriteLN('<td height="42" bgcolor="#FFFFFF" class="titOrganiBlack">'+oTarefa:cValue("NOME")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('</div></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="24" colspan="4" valign="top" class="text_01">')
		oHtmFile:nWriteLN('<table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="17%" class="text_01">'+STR0011+' </td>')//Descricao
		oHtmFile:nWriteLN('<td width="83%"><table width="100%" height="24"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="22" bgcolor="#FFFFFF" class="textTab">'+oTarefa:cValue("TEXTO")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="28" colspan="4" valign="top" class="text_01">')
		oHtmFile:nWriteLN('<table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="17%" class="text_01">'+STR0012+' </td>')//Local(Where)
		oHtmFile:nWriteLN('<td><table width="100%" height="20"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+oTarefa:cValue("LOCAL")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="32" colspan="4" valign="top" class="text_01">')
		oHtmFile:nWriteLN('<table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="17%" height="28" class="text_01">'+STR0013+'</td>')//Data Inicio (When)
		oHtmFile:nWriteLN('<td width="32%"><table width="100%" height="20"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+oTarefa:cValue("DATAINI")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('<td width="12%" align="center" class="text_01">'+STR0014+'</td>')//Data Termino(When)
		oHtmFile:nWriteLN('<td width="39%"><table width="100%" height="20"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+oTarefa:cValue("DATAFIN")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')

		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="19" colspan="4" valign="top" class="text_01"><table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td class="text_01">'+STR0015+'<span class="text_01"></span>')//Situacao
		oHtmFile:nWriteLN('</td>')
		oHtmFile:nWriteLN('<td><table width="100%" height="20"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+	oTarefa:cValue("SITUACAO")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('<td class="text_01"align="center">'+STR0016+'</td>')//% Completado
		oHtmFile:nWriteLN('<td><table width="100%" height="20"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" align="right" bgcolor="#FFFFFF" class="textTab">'+oTarefa:cValue("COMPLETADO")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')

		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td class="text_01">'+STR0035+'<span class="text_01"></span>')//Importância
		oHtmFile:nWriteLN('</td>')
		oHtmFile:nWriteLN('<td><table width="100%" height="20"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		cImportancia := ""
		if(oTarefa:nValue("IMPORTANCI")>0)
			cImportancia := oImportancia:oChildByName("IMPORTANCI", oTarefa:nValue("IMPORTANCI")):oChildByName("NOME"):cGetValue()
		endif
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+	cImportancia+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('<td class="text_01"align="center">'+STR0036+'</td>')//Urgência
		oHtmFile:nWriteLN('<td><table width="100%" height="20"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		cUrgencia := ""
		if(oTarefa:nValue("URGENCIA")>0)
			cUrgencia := oUrgencia:oChildByName("URGENCIA", oTarefa:nValue("URGENCIA")):oChildByName("NOME"):cGetValue()
		endif
		oHtmFile:nWriteLN('<td height="20" align="right" bgcolor="#FFFFFF" class="textTab">'+cUrgencia+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')

		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="17%">&nbsp;</td>')
		oHtmFile:nWriteLN('<td width="32%" align="left" class="titOrgani">'+STR0017+'</td>')//Custo Estimado (How Much)
		oHtmFile:nWriteLN('<td width="12%">&nbsp;</td>')
		oHtmFile:nWriteLN('<td width="39%" align="left" class="titOrgani">'+STR0018+'</td>')//Custo Real (How Much)
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="19" colspan="4" valign="top" class="text_01"><table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="17%" class="text_01">'+STR0019+'</td>')//Mao de Obra
		oHtmFile:nWriteLN('<td width="32%"><table width="100%" height="20"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" align="right" bgcolor="#FFFFFF" class="textTab">'+oTarefa:cValue("CE_MAOOBRA")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('<td width="12%" align="center" class="text_01">'+STR0019+'</td>')//
		oHtmFile:nWriteLN('<td width="39%"><table width="100%" height="20"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" align="right" class="textTab">'+oTarefa:cValue("CR_MAOOBRA")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="19" colspan="4" valign="top" class="text_01"><table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="17%" class="text_01">'+STR0020+'</td>')//Materais
		oHtmFile:nWriteLN('<td width="32%"><table width="100%" height="20"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" align="right" bgcolor="#FFFFFF" class="textTab">'+oTarefa:cValue("CE_MATERIA")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('<td width="12%" align="center" class="text_01">'+STR0020+'</td>')//Materiais
		oHtmFile:nWriteLN('<td width="39%"><table width="100%" height="20"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" align="right" bgcolor="#FFFFFF" class="textTab">'+oTarefa:cValue("CR_MATERIA")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="19" colspan="4" valign="top" class="text_01"><table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="17%" class="text_01">'+STR0021+'</td>')//Terceirizacao
		oHtmFile:nWriteLN('<td width="32%"><table width="100%" height="20"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" align="right" class="textTab">'+oTarefa:cValue("CE_TERCEIR")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('<td width="12%" align="center" class="text_01">'+STR0021+'</td>')//Terceirizacao
		oHtmFile:nWriteLN('<td width="39%"><table width="100%" height="20"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" align="right" class="textTab">'+oTarefa:cValue("CR_TERCEIR")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="19" colspan="4" valign="top" class="text_01"><table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="17%" class="text_01">'+STR0022+'</td>')//Horas
		oHtmFile:nWriteLN('<td width="32%"><table width="100%" height="20"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" align="right" class="textTab">'+oTarefa:cValue("HORASEST")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('<td width="12%" align="center" class="text_01">'+STR0022+'</td>')//Horas
		oHtmFile:nWriteLN('<td width="39%"><table width="100%" height="20"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" align="right" class="textTab">'+oTarefa:cValue("HORASREAL")+'</td>')
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
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('<table width="100%"  border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="1265" height="0" valign="top"> <table width="100%"  border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td colspan="2"><img src="'+ cPath+'images/barra_tit_01_a.jpg" width="16" height="23" /></td>')
		oHtmFile:nWriteLN('<td width="206">')
		oHtmFile:nWriteLN('<!-- In&iacute;cio do bloco para DIV Usu&aacute;rios-->')
		oHtmFile:nWriteLN('<img src="'+ cPath+'images/barra_tit_02_a.jpg" width="206" height="23" align="absbottom" />')
		oHtmFile:nWriteLN('<!-- Fim do bloco para DIV Usu&aacute;rios-->')
		oHtmFile:nWriteLN('</td>')
		oHtmFile:nWriteLN('<div id="bar" class="subTit">'+STR0023+'</div>')//Lista de Pessoas em Cobrança
		oHtmFile:nWriteLN('<td width="539"><div align="left"><img src="'+ cPath+'images/barra_tit_03_a.jpg" width="539" height="23" /></div></td>')
		oHtmFile:nWriteLN('<td width="488" colspan="2" background="'+ cPath+'images/barra_tit_04_a.jpg"><img src="'+ cPath+'images/fundo_barra_tit.jpg" width="1" height="7" /></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td height="51" colspan="6"> <table width="760" id="tbl01">')
		oHtmFile:nWriteLN('<tr bgcolor="#7BA0CA">')
		oHtmFile:nWriteLN('<td width="390" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0024+'</div></td>')//Pessoa
		oHtmFile:nWriteLN('<td width="390" height="20" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0025+'</div></td>')//Cargo
		oHtmFile:nWriteLN('</tr>')

		//Lista de Pessoas
		oPes_X_Cob:lSoftSeek(3,{oTarefa:nValue("ID")})
		while(! oPes_X_Cob:lEof() .and. oPes_X_Cob:nValue("PARENTID")== oTarefa:nValue("ID"))
			oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td width="390" id="tbl01">&nbsp;'+bsc055LisPes(oBSCCore,oPes_X_Cob:nValue("PESSOAID"),oPes_X_Cob:cValue("TIPOPESSOA"))+'</td>')
				oHtmFile:nWriteLN('<td width="390" height="20" id="tbl01"><span class="textTab">&nbsp;'+bsc055PesCar(oBSCCore,oPes_X_Cob:nValue("PESSOAID"),oPes_X_Cob:cValue("TIPOPESSOA"))+'</span>')
				oHtmFile:nWriteLN('<div align="center" class="textTab"></div>')
				oHtmFile:nWriteLN('<div align="center" class="textTab"></div></td>')
			oHtmFile:nWriteLN('</tr>')
			oPes_X_Cob:_Next()
		enddo
		
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('<table width="100%"  border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td colspan="2"><img src="'+ cPath+'images/barra_tit_01_a.jpg" width="16" height="23" /></td>')
		oHtmFile:nWriteLN('<td width="166">')
		oHtmFile:nWriteLN('<!-- In&iacute;cio do bloco para DIV Usu&aacute;rios-->')
		oHtmFile:nWriteLN('<img src="'+ cPath+'images/barra_tit_02_a.jpg" width="166" height="23" align="absbottom" />')
		oHtmFile:nWriteLN('<!-- Fim do bloco para DIV Usu&aacute;rios-->')
		oHtmFile:nWriteLN('</td>')
		oHtmFile:nWriteLN('<div id="bar" class="subTit">'+STR0026+'</div>')//Lista de Retornos
		oHtmFile:nWriteLN('<td width="594"><img src="'+ cPath+'images/barra_tit_03_a.jpg" width="594" height="23" /></td>')
		oHtmFile:nWriteLN('<td width="480" colspan="2" background="'+ cPath+'images/barra_tit_04_a.jpg"><img src="'+ cPath+'images/fundo_barra_tit.jpg" width="1" height="7" /></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td height="51" colspan="6"> <table width="760" id="tbl01">')
		oHtmFile:nWriteLN('<tr bgcolor="#7BA0CA">')
		oHtmFile:nWriteLN('<td width="152" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0027+'</div></td>')//Retorno
		oHtmFile:nWriteLN('<td width="152" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0028+'</div></td>')//Descricao
		oHtmFile:nWriteLN('<td width="152" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0029+'</div></td>')//Data
		oHtmFile:nWriteLN('<td width="152" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0030+'</div></td>')//Horário
		oHtmFile:nWriteLN('<td width="152" height="20" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0031+'</div></td>')//Responsavel
		oHtmFile:nWriteLN('</tr>')

		oRetorno:lSoftSeek(3,{oTarefa:nValue("ID")})
		while(! oRetorno:lEof() .and. oRetorno:nValue("PARENTID")==oTarefa:nValue("ID"))
			oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td width="152"  id="tbl01">&nbsp;' + oRetorno:cValue("NOME")	+ '</td>')
				oHtmFile:nWriteLN('<td width="152"  id="tbl01">&nbsp;' + oRetorno:cValue("TEXTO")	+ '</td>')
				oHtmFile:nWriteLN('<td width="152" align="center" id="tbl01">&nbsp;' + oRetorno:cValue("DATAR")	+ '</td>')
				oHtmFile:nWriteLN('<td width="152" align="center" id="tbl01">&nbsp;' + oRetorno:cValue("HORAR")	+ '</td>')
                //Responsavel
				oHtmFile:nWriteLN('<td width="152" height="20"  id="tbl01"><span class="textTab">&nbsp;')
				oHtmFile:nWriteLN(bsc055LisPes(oBSCCore,oRetorno:nValue("RESPID"),"P"))
				oHtmFile:nWriteLN('</span> <div align="center" class="textTab"></div>')
				oHtmFile:nWriteLN('<div align="center" class="textTab"></div></td>')
			oHtmFile:nWriteLN('</tr>')
		oRetorno:_Next()
		enddo

		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('<table width="100%"  border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td colspan="2"><img src="'+ cPath+'images/barra_tit_01_a.jpg" width="16" height="23" /></td>')
		oHtmFile:nWriteLN('<td width="206">')
		oHtmFile:nWriteLN('<!-- In&iacute;cio do bloco para DIV Usu&aacute;rios-->')
		oHtmFile:nWriteLN('<img src="'+ cPath+'images/barra_tit_02_a.jpg" width="206" height="23" align="absbottom" />')
		oHtmFile:nWriteLN('<!-- Fim do bloco para DIV Usu&aacute;rios-->')
		oHtmFile:nWriteLN('</td>')
		oHtmFile:nWriteLN('<div id="bar" class="subTit">'+STR0032+'</div>')//Lista de Documentos
		oHtmFile:nWriteLN('<td width="539"><div align="left"><img src="'+ cPath+'images/barra_tit_03_a.jpg" width="539" height="23" /></div></td>')
		oHtmFile:nWriteLN('<td width="488" colspan="2" background="'+ cPath+'images/barra_tit_04_a.jpg"><img src="'+ cPath+'images/fundo_barra_tit.jpg" width="1" height="7" /></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td height="0" colspan="6"> <table width="760" id="tbl01">')
		oHtmFile:nWriteLN('<tr bgcolor="#7BA0CA">')
		oHtmFile:nWriteLN('<td width="190" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0033+'</div></td>')//Documento
		oHtmFile:nWriteLN('<td width="190" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0028+'</div></td>')//Descricao
		oHtmFile:nWriteLN('<td width="190" height="20" bgcolor="#7BA0CA"><div align="center" id="tbl02" class="titTab">'+STR0034+'</div>')//Link
		oHtmFile:nWriteLN('<div align="center"></div>')
		oHtmFile:nWriteLN('<div align="center"></div></td>')
		oHtmFile:nWriteLN('</tr>')

		//Lista de Documentos
		nItem := 0
		oDocumento:lSoftSeek(3,{oTarefa:nValue("ID")})
		while(! oDocumento:lEof() .and. oDocumento:nValue("PARENTID")==oTarefa:nValue("ID"))
			oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td width="190" class="textTab" id="tbl01">&nbsp;' + oDocumento:cValue("NOME")		+ '</td>')
				oHtmFile:nWriteLN('<td width="190" class="textTab" id="tbl01">&nbsp;' + oDocumento:cValue("DESCRICAO")	+ '</td>')
				oHtmFile:nWriteLN('<td width="190" height="20" class="textTab" id="tbl01">&nbsp;' + oDocumento:cValue("LINK")	+ '')
				oHtmFile:nWriteLN('<div align="center" class="textTab"></div></td>')
			oHtmFile:nWriteLN('</tr>')
		oDocumento:_Next()
		enddo
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('</body>')
		oHtmFile:nWriteLN('</html>')
		oHtmFile:nWriteLN('<br>')
		oHtmFile:nWriteLN('<DIV style="page-break-after:always"></DIV> ')		
		
		oTarefa:_Next()
	enddo
	
	oTarefa:cSQLFilter("") // Encerra filtro

	//Faz a copia do relatorio para o diretorio de Spool
	//oHtmFile:lCopyFile("relato\Spool\" + cSpoolName)
	
	oHtmFile:lClose()
	
Return