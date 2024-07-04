#include "BIDefs.ch"
#include "BSCDefs.ch"
#Include "bsc055E_Ind.ch"

// ######################################################################################
// Projeto: BSC
// Modulo : Book Estrategico
// Fonte  : bsc055E_Ind.prw
// Utiliz : Gera o html do relatorio do book estrategico - Indicador.
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 12.05.05 | 1776 Alexandre Alves da Silva
// --------------------------------------------------------------------------------------
function bsc055E_Ind(oBSCCore,cReportName,cSpoolName,nContextID,cIndDe,cIndAte,cPath)
	local oHtmFile := TBIFileIO():New(oBSCCore:cBscPath()+"relato\" + cReportName)
	local oIndicador		,oMeta				,oAvaliacao		,oResultado		,oReferencia
	local oPlanReferencia	,oTendencia			,oDocumento		,oPlanIndicador	,oPlanilha
	local aDadosCab:={}		,aLstValores
	local nItem := 0		,nIndID

	// Cria o arquivo htm
	If ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oBSCCore:Log(STR0001 + cReportName+ "]", BSC_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL055A_ORG"*/
		oBSCCore:Log(STR0002, BSC_LOG_SCRFILE)/*//"Operação abortada"*/
		return
	endif

	oIndicador		:= oBSCCore:oGetTable("INDICADOR")
	oMeta			:= oBSCCore:oGetTable("META")
	oAvaliacao		:= oBSCCore:oGetTable("AVALIACAO")
	oResultado		:= oBSCCore:oGetTable("PLANILHA")
	oReferencia		:= oBSCCore:oGetTable("RPLANILHA")
	oDocumento		:= oBSCCore:oGetTable("INDDOC")
	oPlanIndicador	:= oBSCCore:oGetTable("PLANILHA")
	oPlanReferencia	:= oBSCCore:oGetTable("RPLANILHA")
	oTendencia		:= oBSCCore:oGetTable("INDTEND")

	oIndicador:SetOrder(2) // Por ordem de Nome
	oIndicador:cSQLFilter("CONTEXTID = " + cBIStr(nContextID) + " AND NOME BETWEEN '" + cIndDe + "' AND '" + cIndAte + "'") // Filtra pelo pai
	oIndicador:lFiltered(.t.)
	oIndicador:_First()
      
    /*Monta o cabeçalho da página.*/
    If(! oIndicador:lEof()) 
     
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
		oHtmFile:nWriteLN('<td height="0" valign="top"> <table width="100%" height="61" border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="61%" height="36" valign="top" background="'+ cPath+'images/topo_01_fundo.jpg"><img src="'+ cPath+'images/topo_01.jpg" width="772" height="70"></td>')
		oHtmFile:nWriteLN('<td width="39%" valign="top" background="'+ cPath+'images/topo_01_fundo.jpg">&nbsp;</td>')
		oHtmFile:nWriteLN('</tr>')
   
	EndIf
	
	while(! oIndicador:lEof())
		//Atualiza os dados do cabecalho
		BSC055PreCab(oBSCCore,oIndicador,@aDadosCab,nContextID)


		oHtmFile:nWriteLN('<tr bgcolor="#F5F5F3">')
		oHtmFile:nWriteLN('<td height="553" colspan="2" valign="top"> <table width="769" height="21" border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="769"><table width="770" height="145" border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="126" colspan="2"><br />')
		oHtmFile:nWriteLN('<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="67" rowspan="8" valign="top"><div align="center"></div></td>')
		oHtmFile:nWriteLN('<td width="192" height="17" class="subTit">'+STR0004+'</td>')//Organizacao
		oHtmFile:nWriteLN('<td colspan="2"><span class="titOrgani">'+ aDadosCab[1,2] +'</span></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="17" class="subTit">'+STR0005+'</td>')//Estrategia
		oHtmFile:nWriteLN('<td colspan="2"><span class="titOrgani">'+ aDadosCab[2,2] +'</span></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="8" class="subTit">'+STR0006+'</td>')//Perspectiva
		oHtmFile:nWriteLN('<td colspan="2"><span class="titOrgani">'+ aDadosCab[3,2]+'</span></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="8" class="subTit">'+STR0007+'</td>')//Objetivo
		oHtmFile:nWriteLN('<td colspan="2" class="titOrgani">'+ aDadosCab[4,2] +'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="16" colspan="3"><img src="'+ cPath+'images/linhadivisoriatitulo.jpg" width="100%" height="14" /></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="10" colspan="2" class="subTit">'+STR0008+'</td>')//Responsavel
		oHtmFile:nWriteLN('<td width="510" height="0" class="subTit2">'+bsc055LisPes(oBSCCore,oIndicador:nValue("RESPID"),oIndicador:cValue("TIPOPESSOA"))+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="11" colspan="2" class="subTit">'+STR0009+'</td>')//Responsavel pela coleta
		oHtmFile:nWriteLN('<td width="510" height="0" class="subTit2">'+bsc055LisPes(oBSCCore,oIndicador:nValue("MEDRESPID"),oIndicador:cValue("TIPOPESSOA"))+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="13" colspan="2" class="subTit">'+STR0010+'</td>')
		oHtmFile:nWriteLN('<td width="510" height="13" class="subTit2">'+bsc055LisPes(oBSCCore,oIndicador:nValue("RRESPID"),oIndicador:cValue("TIPOPESSOA"))+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td valign="top">&nbsp;</td>')
		oHtmFile:nWriteLN('<td height="19" colspan="3"><img src="'+ cPath+'images/linhadivisoriatitulo.jpg" width="100%" height="14" /></td>')
		oHtmFile:nWriteLN('</tr>')

		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="200">&nbsp;</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')

		oHtmFile:nWriteLN('<table width="771"  border="0" cellspacing="2" cellpadding="0">')
		oHtmFile:nWriteLN('<tr> ')
		oHtmFile:nWriteLN('<td width="20%" valign="middle"> <div align="center"><img src="'+ cPath+'images/icone_indicador.gif" width="56" height="46" align="left" /></div></td>')
		oHtmFile:nWriteLN('<td width="20%" valign="middle" bordercolor="#999999" class="titOrgani">'+ STR0011 +'</td>')//"Indicador"
		oHtmFile:nWriteLN('<td width="60" valign="middle" bordercolor="#999999"> <table width="594" height="27"  border="1" align="center" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr> ')
		oHtmFile:nWriteLN('<td width="590" height="25" bgcolor="#FFFFFF" class="titOrganiBlack">'+oIndicador:cValue("NOME")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="155" valign="middle" class="text_01">'+STR0012+'</td>')//Descricao
		oHtmFile:nWriteLN('<td height="22" colspan="3" valign="top" class="text_01">')
		oHtmFile:nWriteLN('<table width="99%" height="22"  border="1" align="center" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+oIndicador:cValue("DESCRICAO")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td width="155" valign="middle" class="text_01">'+STR0013+'</td>')//Unidade
		oHtmFile:nWriteLN('<td height="23" colspan="3" class="text_01"><table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="29%"><table width="100%" height="22"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+oIndicador:cValue("UNIDADE")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('<td width="20%" align="center" class="text_01">'+STR0014+'</td>')//Decimais
		oHtmFile:nWriteLN('<td width="52%"><table width="100%" height="22"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+oIndicador:cValue("DECIMAIS")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="155" valign="middle" class="text_01">'+STR0015+'</td>')//Ind. tendencia?
		oHtmFile:nWriteLN('<td height="23" colspan="3" valign="top" class="text_01"><table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="29%"><table width="100%" height="22"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')

		if(oIndicador:cValue("TIPOIND")=="T")
			oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+STR0044+'</td>')//Sim
		else
			oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+STR0045+'</td>')//Nao
		endif			

		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('<td width="20%" align="center" class="text_01">'+STR0016+'</td>')//Frequencia
		oHtmFile:nWriteLN('<td width="52%"><table width="100%" height="22"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+oIndicador:getFreqText(oIndicador:nValue("FREQ"))+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="155" valign="middle" class="text_01">'+STR0017+'</td>')//Ind.Cumulativo
		oHtmFile:nWriteLN('<td height="23" colspan="3" valign="top" class="text_01"><table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="29%"><table width="100%" height="22"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')

		if(oIndicador:cValue("CUMULATIVO")=="T")
			oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+STR0044+'</td>')//Sim
		else
			oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+STR0045+'</td>')//Nao
		endif			

		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('<td width="20%" align="center" class="text_01">'+STR0016+'</td>')//Frequencia
		oHtmFile:nWriteLN('<td width="52%"><table width="100%" height="22"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+oIndicador:getFreqText(oIndicador:nValue("FCUMULA"))+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td width="155" valign="middle" class="text_01">'+STR0018+'</td>')
		oHtmFile:nWriteLN('<td height="23" colspan="3" class="text_01"><table width="99%" height="22"  border="1" align="center" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')

		if(oIndicador:cValue("ASCEND")=="T")
			oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+STR0046+'</td>')
		else
			oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+STR0047+'</td>')
		endif

		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td width="155" valign="middle" class="text_01">&nbsp;</td>')
		oHtmFile:nWriteLN('<td height="23" colspan="3" align="left" valign="middle" class="titOrgani">'+STR0019+'</td>')//Coleta
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td width="155" valign="middle" class="text_01">'+STR0020+'</td>')//Descricao da metrica
		oHtmFile:nWriteLN('<td height="23" colspan="3" class="text_01"><table width="99%" height="22"  border="1" align="center" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+oIndicador:cValue("METRICA")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td width="155" valign="middle" class="text_01">'+STR0021+'</td>')
		oHtmFile:nWriteLN('<td height="23" colspan="3" class="text_01"><table width="99%" height="22"  border="1" align="center" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+oIndicador:cValue("FORMA")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td valign="middle" class="text_01">&nbsp;</td>')
		oHtmFile:nWriteLN('<td height="23" colspan="3" align="left" valign="middle" class="titOrgani">'+STR0022+'</td>')//Referencia
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td valign="middle" class="text_01">'+STR0022+'</td>')//Referencia
		oHtmFile:nWriteLN('<td height="23" colspan="3" class="text_01"><table width="99%" height="22"  border="1" align="center" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+oIndicador:cValue("RNOME")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td valign="middle" class="text_01">'+STR0023+'</td>')//Descricao
		oHtmFile:nWriteLN('<td height="23" colspan="3" class="text_01"><table width="99%" height="22"  border="1" align="center" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+oIndicador:cValue("RDESCRICAO")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td valign="middle" class="text_01">'+STR0013+'</td>')//Unidade
		oHtmFile:nWriteLN('<td height="24" colspan="3" class="text_01"> <table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="29%"><table width="100%" height="22"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+oIndicador:cValue("RUNIDADE")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('<td width="20%" align="center" class="text_01">'+STR0014 +'</td>')//Decimais
		oHtmFile:nWriteLN('<td width="51%"><table width="100%" height="22"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+oIndicador:cValue("RDECIMAIS")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td valign="middle" class="text_01">'+STR0016+'</td>')//Frequencia
		oHtmFile:nWriteLN('<td height="22" colspan="3" class="text_01"> <table width="99%" height="22"  border="1" align="center" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+oIndicador:getFreqText(oIndicador:nValue("RFREQ"))+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="19" colspan="2" valign="top"><img src="'+ cPath+'images/linhadivisoriatitulo.jpg" width="100%" height="20" /></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('<table width="100%"  border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="1265" height="107"> <table width="100%"  border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td colspan="2"><img src="'+ cPath+'images/barra_tit_01_a.jpg" width="16" height="23"></td>')
		oHtmFile:nWriteLN('<td width="151" height="23" background="'+ cPath+'images/barra_tit_02_a.jpg">')
		oHtmFile:nWriteLN('<!-- Início do bloco para DIV Estatégia-->')
		oHtmFile:nWriteLN('<a href="'+ cPath+'images/barra_tit_02_a.jpg"><img src="'+ cPath+'images/barra_tit_02_a.jpg" width="153" height="23" border="0" align="absbottom"></a>')
		oHtmFile:nWriteLN('<!-- fim do bloco para DIV Estatégia-->')
		oHtmFile:nWriteLN('</td>')
		oHtmFile:nWriteLN('<div id="bar" class="subTit">'+STR0025+'</div>')//Lista de Metas
		oHtmFile:nWriteLN('<td width="595"><img src="'+ cPath+'images/barra_tit_03_a.jpg" width="600" height="23"></td>')
		oHtmFile:nWriteLN('<td width="487" colspan="2" background="'+ cPath+'images/barra_tit_04_a.jpg" id="teste">&nbsp;</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td height="10" colspan="6"> <table width="770" id="tbl01">')
		oHtmFile:nWriteLN('<tr bgcolor="#7BA0CA">')
		oHtmFile:nWriteLN('<td width="205" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0026+'</div></td>')//Meta
		oHtmFile:nWriteLN('<td width="84" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'	+STR0027+'</div></td>')//DataAlvo
		oHtmFile:nWriteLN('<td width="71" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'	+STR0028+'</div></td>')//Parcelada
		oHtmFile:nWriteLN('<td width="221" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0029+'</div></td>')//Anotacoes
		oHtmFile:nWriteLN('<td width="165" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0030+'</div></td>')//Responsavel
		oHtmFile:nWriteLN('</tr>')

		//Lista de Metas
		oMeta:lSoftSeek(3,{oIndicador:nValue("ID")}) 
		while(! oMeta:lEof() .and. oMeta:nValue("PARENTID")==oIndicador:nValue("ID"))
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="205" class="textTab" id="tbl01">' + oMeta:cValue("NOME") + '</td>')
			oHtmFile:nWriteLN('<td width="84" align="center" class="textTab" id="tbl01">' + oMeta:cValue("DATAALVO")+'</td>')
			if(oMeta:cValue("PARCELADA")=="T")
				oHtmFile:nWriteLN('<td width="71" align="center" class="textTab" id="tbl01">'+STR0044+'</td>')//Sim
			else
				oHtmFile:nWriteLN('<td width="71" align="center" class="textTab" id="tbl01">'+STR0045+'</td>')//Nao
			endif		
			oHtmFile:nWriteLN('<td width="221" align="center" class="textTab" id="tbl01">' + oMeta:cValue("VERDE")+'</td>')
			oHtmFile:nWriteLN('<td width="165" height="20" class="textTab" id="tbl01">'+bsc055LisPes(oBSCCore,oMeta:nValue("RESPID"),oMeta:cValue("TIPOPESSOA"))+'<div align="center" class="textTab">')
			oHtmFile:nWriteLN('</div>')
			oHtmFile:nWriteLN('<div align="center"><span class="style2">')
			oHtmFile:nWriteLN('</span></div></td>')
			oHtmFile:nWriteLN('</tr>')

			oMeta:_Next()
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
		oHtmFile:nWriteLN('<div id="bar" class="subTit">'+STR0031+'</div>')//Lista de avaliacoes
		oHtmFile:nWriteLN('<td width="594"><img src="'+ cPath+'images/barra_tit_03_a.jpg" width="594" height="23"></td>')
		oHtmFile:nWriteLN('<td width="490" colspan="2" background="'+ cPath+'images/barra_tit_04_a.jpg"><img src="'+ cPath+'images/fundo_barra_tit.jpg" width="1" height="7"></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td height="48" colspan="6"> <table width="770" id="tbl01">')
		oHtmFile:nWriteLN('<tr bgcolor="#7BA0CA">')
		oHtmFile:nWriteLN('<td width="203" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0032+'</div></td>')//Avaliacao
		oHtmFile:nWriteLN('<td width="84" bgcolor="#7BA0CA"> <div align="center" id="tbl01" class="titTab">'+STR0033+'</div></td>')//Data
		oHtmFile:nWriteLN('<td width="269" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0034+'</div></td>')//Descricao
		oHtmFile:nWriteLN('<td width="165" height="20" bgcolor="#7BA0CA">')
		oHtmFile:nWriteLN('<div align="center" id="tbl01" class="titTab">'+STR0030+'</div>')//Resonsavel
		oHtmFile:nWriteLN('<div align="center"></div>')
		oHtmFile:nWriteLN('<div align="center"></div></td>')
		oHtmFile:nWriteLN('</tr>')
		
		//Lista de Avaliacao
		oAvaliacao:lSoftSeek(3,{oIndicador:nValue("ID")}) 
		while(! oAvaliacao:lEof() .and. oAvaliacao:nValue("PARENTID")==oIndicador:nValue("ID"))
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="203" class="textTab" id="tbl01">' + oAvaliacao:cValue("NOME")	+ '</td>')
			oHtmFile:nWriteLN('<td width="85" class="textTab" id="tbl01">'	+ oAvaliacao:cValue("DTAVAL")+ '</td>')
			oHtmFile:nWriteLN('<td width="269" class="textTab" id="tbl01">' + oAvaliacao:cValue("TEXTO")+ '</td>')
			oHtmFile:nWriteLN('<td width="193" height="20" class="textTab" id="tbl01">'+bsc055LisPes(oBSCCore,oAvaliacao:nValue("RESPID"),oAvaliacao:cValue("TIPOPESSOA"))+'')
			oHtmFile:nWriteLN('<div align="center" class="textTab"> </div>')
			oHtmFile:nWriteLN('<div align="center" class="textTab"></div></td>')
			oHtmFile:nWriteLN('</tr>')
	
			oAvaliacao:_Next()
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
		oHtmFile:nWriteLN('<div id="bar" class="subTit">'+STR0035+'</div>')//Lista de Valores
		oHtmFile:nWriteLN('<td width="594"><img src="'+ cPath+'images/barra_tit_03_a.jpg" width="594" height="23" /></td>')
		oHtmFile:nWriteLN('<td width="490" colspan="2" background="'+ cPath+'images/barra_tit_04_a.jpg"><img src="'+ cPath+'images/fundo_barra_tit.jpg" width="1" height="7" /></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td height="68" colspan="6"> <table width="770" id="tbl01">')
		oHtmFile:nWriteLN('<tr bgcolor="#7BA0CA">')
		oHtmFile:nWriteLN('<td width="390" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0036+'</div></td>')//Tabelade Resultados 
		oHtmFile:nWriteLN('<td width="390" height="20" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0037+'</div></td>')//Tabelade Referencia 
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="390" class="form_input" id="tbl01"><table width="100%" border="0">')

		//Planilha de valores        
		oPlanilha	:= oPlanIndicador:oToXMLNode(oIndicador:nValue("ID"))
		oIndicador:SetOrder(2) // Por ordem de Nome
		aLstValores := aBsc055ePlan(oPlanilha,oIndicador:nValue("FREQ"))

		oHtmFile:nWriteLN('<tr align="center" class="subTit2">')
		oHtmFile:nWriteLN('<td width="14%">'+aLstValores[1,1]+'</td>')
		oHtmFile:nWriteLN('<td width="14%">'+aLstValores[1,2]+'</td>')
		oHtmFile:nWriteLN('<td width="13%">'+aLstValores[1,3]+'</td>')
		oHtmFile:nWriteLN('<td width="23%">'+aLstValores[1,4]+'</td>')
		oHtmFile:nWriteLN('<td width="36%">'+aLstValores[1,5]+'</td>')
		
		for nItem := 2 to len(aLstValores)
			oHtmFile:nWriteLN('</tr>')
				oHtmFile:nWriteLN('<tr align="center" class="text_01">')
				oHtmFile:nWriteLN('<td>'+aLstValores[nItem,1]+'</td>')
				oHtmFile:nWriteLN('<td>'+aLstValores[nItem,2]+'</td>')
				oHtmFile:nWriteLN('<td>'+aLstValores[nItem,3]+'</td>')
				oHtmFile:nWriteLN('<td>'+aLstValores[nItem,4]+'</td>')
				oHtmFile:nWriteLN('<td>'+aLstValores[nItem,5]+'</td>')
			oHtmFile:nWriteLN('</tr>')
		next nItem			
		
		oPlanilha	:= oPlanReferencia:oToXMLNode(oIndicador:nValue("ID"))
		oIndicador:SetOrder(2) // Por ordem de Nome
		aLstValores := aBsc055ePlan(oPlanilha,oIndicador:nValue("FREQ"))

		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('<td width="390" height="40" id="tbl01"> <table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr align="center" class="subTit2">')
		oHtmFile:nWriteLN('<td width="14%">'+aLstValores[1,1]+'</td>')
		oHtmFile:nWriteLN('<td width="14%">'+aLstValores[1,2]+'</td>')
		oHtmFile:nWriteLN('<td width="13%">'+aLstValores[1,3]+'</td>')
		oHtmFile:nWriteLN('<td width="23%">'+aLstValores[1,4]+'</td>')
		oHtmFile:nWriteLN('<td width="36%">'+aLstValores[1,5]+'</td>')
		
		for nItem := 2 to len(aLstValores)
			oHtmFile:nWriteLN('</tr>')
				oHtmFile:nWriteLN('<tr align="center" class="text_01">')
				oHtmFile:nWriteLN('<td>'+aLstValores[nItem,1]+'</td>')
				oHtmFile:nWriteLN('<td>'+aLstValores[nItem,2]+'</td>')
				oHtmFile:nWriteLN('<td>'+aLstValores[nItem,3]+'</td>')
				oHtmFile:nWriteLN('<td>'+aLstValores[nItem,4]+'</td>')
				oHtmFile:nWriteLN('<td>'+aLstValores[nItem,5]+'</td>')
			oHtmFile:nWriteLN('</tr>')
		next nItem			

		//oIndicador:SetOrder(2) // Por ordem de Nome
		//oIndicador:RestPos()							
	
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
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
		oHtmFile:nWriteLN('<div id="bar" class="subTit">'+STR0038+'</div>')//Lista de Documentos
		oHtmFile:nWriteLN('<td width="594"><img src="'+ cPath+'images/barra_tit_03_a.jpg" width="594" height="23" /></td>')
		oHtmFile:nWriteLN('<td width="490" colspan="2" background="'+ cPath+'images/barra_tit_04_a.jpg"><img src="'+ cPath+'images/fundo_barra_tit.jpg" width="1" height="7" /></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td height="48" colspan="6"> <table width="770" id="tbl01">')
		oHtmFile:nWriteLN('<tr bgcolor="#7BA0CA">')
		oHtmFile:nWriteLN('<td width="190" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0039+'</div></td>')//Documento
		oHtmFile:nWriteLN('<td width="190" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0023+'</div></td>')//Descricao
		oHtmFile:nWriteLN('<td width="190" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0040+'</div></td>')//Texto
		oHtmFile:nWriteLN('<td width="190" height="20" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0041+'</div>')//Link
		oHtmFile:nWriteLN('<div align="center"></div>')
		oHtmFile:nWriteLN('<div align="center"></div></td>')
		oHtmFile:nWriteLN('</tr>')
		
		//Lista de Documentos
		oDocumento:lSoftSeek(3,{oIndicador:nValue("ID")}) 
		while(! oDocumento:lEof() .and. oDocumento:nValue("PARENTID")==oIndicador:nValue("ID"))
			oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td width="190" class="textTab" id="tbl01">&nbsp;' + oDocumento:cValue("NOME")	+ '</td>')
				oHtmFile:nWriteLN('<td width="190" class="textTab" id="tbl01">&nbsp;' + oDocumento:cValue("DESCRICAO")+ '</td>')
				oHtmFile:nWriteLN('<td width="190" class="textTab" id="tbl01">&nbsp;' + oDocumento:cValue("TEXTO")+ '</td>')
				oHtmFile:nWriteLN('<td width="190" height="20" class="textTab" id="tbl01">&nbsp;' + oDocumento:cValue("LINK")+ '')
				oHtmFile:nWriteLN('<div align="center" class="textTab"> </div>')
				oHtmFile:nWriteLN('<div align="center" class="textTab"></div></td>')
			oHtmFile:nWriteLN('</tr>')

			oDocumento:_Next()
		enddo
		
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')

		//Indicadicador de Tendencia				
		if(oIndicador:cValue("TIPOIND")== "T")
			oHtmFile:nWriteLN('<table width="100%"  border="0" cellpadding="0" cellspacing="0">')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td colspan="2"><img src="'+ cPath+'images/barra_tit_01_a.jpg" width="16" height="23" /></td>')
			oHtmFile:nWriteLN('<td width="306">')
			oHtmFile:nWriteLN('<!-- In&iacute;cio do bloco para DIV Usu&aacute;rios-->')
			oHtmFile:nWriteLN('<img src="'+ cPath+'images/barra_tit_02_a.jpg" width="306" height="23" align="absbottom" />')
			oHtmFile:nWriteLN('<!-- Fim do bloco para DIV Usu&aacute;rios-->')
			oHtmFile:nWriteLN('</td>')
			oHtmFile:nWriteLN('<div id="bar" class="subTit">'+STR0042+'</div>')//Lista dos Indicadores que são influenciados
			oHtmFile:nWriteLN('<td width="439"><div align="right"><img src="'+ cPath+'images/barra_tit_03_a.jpg" width="439" height="23" /></div></td>')
			oHtmFile:nWriteLN('<td width="488" colspan="2" background="'+ cPath+'images/barra_tit_04_a.jpg"><img src="'+ cPath+'images/fundo_barra_tit.jpg" width="1" height="7" /></td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('<tr valign="top">')
			oHtmFile:nWriteLN('<td height="49" colspan="6"> <table width="770" id="tbl01">')
			oHtmFile:nWriteLN('<tr bgcolor="#7BA0CA">')
			oHtmFile:nWriteLN('<td height="20" bgcolor="#7BA0CA"><div align="center" class="titTab">')
			oHtmFile:nWriteLN('<div align="center" class="titTab" id="tbl01">'+STR0043+'</div></td>')//Indicador
			oHtmFile:nWriteLN('</tr>')

			nIndID := oIndicador:nValue("ID")
			oIndicador:SavePos()           
			oIndicador:cSQLFilter("") // Encerra filtro		
			oTendencia:lSoftSeek(3,{nIndID}) 
			while(! oTendencia:lEof() .and. oTendencia:nValue("PARENTID")== nIndID)
				if(oIndicador:lSeek(1,{oTendencia:nValue("INDICADOR")}))					
					oHtmFile:nWriteLN('<tr>')
						oHtmFile:nWriteLN('<td height="20" class="textTab" id="tbl01">' + oIndicador:cValue("NOME")	+ '')
						oHtmFile:nWriteLN('<div align="center" class="textTab"> </div>')
						oHtmFile:nWriteLN('<div align="center" class="textTab"></div></td>')
					oHtmFile:nWriteLN('</tr>')
				endif						
				oTendencia:_Next()
			enddo
			oIndicador:SetOrder(2) // Por ordem de Nome
			oIndicador:cSQLFilter("CONTEXTID = " + cBIStr(nContextID) + " AND NOME BETWEEN '" + cIndDe + "' AND '" + cIndAte + "'") // Filtra pelo pai
			oIndicador:lFiltered(.t.)
			oIndicador:RestPos()							
			
			oHtmFile:nWriteLN('</table></td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('</table>')
		endif

		oHtmFile:nWriteLN('</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('</body>')
		oHtmFile:nWriteLN('</html>')
		oHtmFile:nWriteLN('</br>')
		oHtmFile:nWriteLN('<DIV style="page-break-after:always"></DIV> ')		

		oIndicador:_Next()
	end

	oIndicador:cSQLFilter("") // Encerra filtro

	//Faz a copia do relatorio para o diretorio de Spool
	//oHtmFile:lCopyFile("relato\Spool\" + cSpoolName)	
	
	oHtmFile:lClose()

Return

function aBsc055ePlan(oPlan,nIdFrequencia)
	local nTotLin := len(oPlan:FACHILDREN[4]:FACHILDREN)
	local aLstValor := {},nLinha
	local cDia,cMes,cAno,cValor,cMontante

	//Montagem do cabecalho
	do case
		//Ano,,,Valor,Montante
		case nIdFrequencia == BSC_FREQ_ANUAL
			aadd(aLstValor,{STR0048,"","",STR0029,STR0024}) 
		//Ano,Semestre,,Valor,Montante
		case nIdFrequencia == BSC_FREQ_SEMESTRAL 
			aadd(aLstValor,{STR0048,STR0049,"",STR0029,STR0024})
		//Ano,Quadrimestre,,Valor,Montante
		case nIdFrequencia == BSC_FREQ_QUADRIMESTRAL
			aadd(aLstValor,{STR0048,STR0050,"",STR0029,STR0024})
		//Ano,Trimestre,,Valor,Montante		
		case nIdFrequencia == BSC_FREQ_TRIMESTRAL 
			aadd(aLstValor,{STR0048,STR0051,"",STR0029,STR0024})
		//Ano,Bimestre,,Valor,Montante		
		case nIdFrequencia == BSC_FREQ_BIMESTRAL 
			aadd(aLstValor,{STR0048,STR0052,"",STR0029,STR0024})
		//Ano,Mes,Dia,Valor,Montante		
		case nIdFrequencia == BSC_FREQ_MENSAL
			aadd(aLstValor,{STR0048,STR0054,"",STR0029,STR0024})
		//Ano,Mes,Quinzena,Valor,Montante		
		case nIdFrequencia == BSC_FREQ_QUINZENAL
			aadd(aLstValor,{STR0048,STR0054,STR0055,STR0029,STR0024})
		//Ano,Semana,,Valor,Montante
		case nIdFrequencia == BSC_FREQ_SEMANAL 
			aadd(aLstValor,{STR0048,STR0056,"",STR0029,STR0024})
		//Ano,Mes,Dia,Valor,Montante
		case nIdFrequencia == BSC_FREQ_DIARIA
			aadd(aLstValor,{STR0048,STR0054,STR0057,STR0029,STR0024})
	endcase		

	//Montagem dos valores	
	for nLinha := 1  to nTotLin
		cAno 		:=	oPlan:FACHILDREN[4]:FACHILDREN[nLinha]:FACHILDREN[4]:FCVALUE
		cMes 		:=	oPlan:FACHILDREN[4]:FACHILDREN[nLinha]:FACHILDREN[5]:FCVALUE
		cDia 		:=	oPlan:FACHILDREN[4]:FACHILDREN[nLinha]:FACHILDREN[6]:FCVALUE
		cValor		:=	oPlan:FACHILDREN[4]:FACHILDREN[nLinha]:FACHILDREN[7]:FCVALUE
		cMontante	:=	oPlan:FACHILDREN[4]:FACHILDREN[nLinha]:FACHILDREN[8]:FCVALUE

		if(nIdFrequencia == BSC_FREQ_ANUAL)
			aadd(aLstValor,{cAno,"","",cValor,cMontante})
		elseif(nIdFrequencia == BSC_FREQ_QUINZENAL .or. nIdFrequencia == BSC_FREQ_DIARIA)
			aadd(aLstValor,{cAno,cMes,cDia,cValor,cMontante})
		else
			aadd(aLstValor,{cAno,cMes,"",cValor,cMontante})
		endif

	next nLinha               
	
	if nTotLin == 0
		aadd(aLstValor,{"","","","",""})
	endif

return aLstValor