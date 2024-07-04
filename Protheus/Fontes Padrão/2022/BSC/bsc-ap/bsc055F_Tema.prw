#include "BIDefs.ch"
#include "BSCDefs.ch"
#Include "bsc055F_Tema.ch"

// ######################################################################################
// Projeto: BSC
// Modulo : bsc055F_Tema
// Fonte  : bsc055F_Tema.prw
// Utiliz : Gera o html do relatorio do book estrategico - Estrategia. 
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 09.05.05 | 1776 Alexandre Alves da Silva
// --------------------------------------------------------------------------------------
function bsc055F_Tema(oBSCCore,cReportName,cSpoolName,nContextID,cTemaDe,cTemaAte,cPath)
	local oHtmFile := TBIFileIO():New(oBSCCore:cBscPath()+"relato\" + cReportName)
	local oTema,oObjetivo,oTema_X_Obj,aDadosCab:={}

	// Cria o arquivo htm
	If ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oBSCCore:Log(STR0001 + cReportName+ "]", BSC_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL055A_ORG"*/
		oBSCCore:Log(STR0002, BSC_LOG_SCRFILE)/*//"Operação abortada"*/
		return
	endif

	oTema		:= oBSCCore:oGetTable("TEMAEST")
	oTema_X_Obj	:= oBSCCore:oGetTable("TEMESTOBJ")
	oObjetivo	:= oBSCCore:oGetTable("OBJETIVO")

	//Atualiza os dados do cabecalho
	BSC055PreCab(oBSCCore,oTema,@aDadosCab,nContextID)

	oTema:SetOrder(2) // Por ordem de Nome
	oTema:cSQLFilter( "CONTEXTID = " + cBIStr(nContextID) + " AND NOME BETWEEN '" + cTemaDe + "' AND '" + cTemaAte + "'"  ) // Filtra pelo pai
	oTema:lFiltered(.t.)
	oTema:_First()

	while(!oTema:lEof())
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
	
		oHtmFile:nWriteLN('<body>')
			oHtmFile:nWriteLN('<table width="100%" border="0" cellpadding="0" cellspacing="7">')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td height="0" valign="top"> <table width="100%" height="269" border="0" cellpadding="0" cellspacing="0">')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="61%" height="36" valign="top" background="'+ cPath+'images/topo_01_fundo.jpg"><img src="'+ cPath+'images/topo_01.jpg" width="772" height="70"></td>')
			oHtmFile:nWriteLN('<td width="39%" valign="top" background="'+ cPath+'images/topo_01_fundo.jpg">&nbsp;</td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('<tr bgcolor="#F5F5F3">')
			oHtmFile:nWriteLN('<td height="199" colspan="2" valign="top"> <table width="770" height="58"  border="0" cellpadding="0" cellspacing="0">')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td height="40"><table width="770" height="21" border="0" cellpadding="0" cellspacing="0">')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td colspan="2"><br /> <table width="769" border="0" align="center" cellpadding="0" cellspacing="0">')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="80" rowspan="2" valign="top"><div align="center"></div></td>')
			oHtmFile:nWriteLN('<td width="90" height="17" class="subTit">'+STR0009+'</td>')//Organizacao
			oHtmFile:nWriteLN('<td width="599"><span class="titOrgani">'+ aDadosCab[1,2] + '</span></td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td height="17" class="subTit">'+STR0004+'</td>')//Estrategia
			oHtmFile:nWriteLN('<td class="titOrgani">'+ aDadosCab[2,2] + '</td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td valign="top">&nbsp;</td>')
			oHtmFile:nWriteLN('<td height="17" colspan="2" class="subTit"><img src="'+ cPath+'images/linhadivisoriatitulo.jpg" width="100%" height="16" /></td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('</table></td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="200">&nbsp;</td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('</table></td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('</table>')
			oHtmFile:nWriteLN('<table width="772"  border="0" cellspacing="2" cellpadding="0">')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="78" height="23" valign="top" bordercolor="#999999" class="text_01"><img src="'+ cPath+'images/icone_tema.gif" width="56" height="46" /></td>')
			oHtmFile:nWriteLN('<td width="101" valign="middle" bordercolor="#999999" class="titOrgani">'+STR0005+'</td>')//Perspectiva
			oHtmFile:nWriteLN('<td width="585" valign="top" bordercolor="#999999"><table width="100%" height="43"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td height="41" bgcolor="#FFFFFF" class="titOrganiBlack">' +oTema:cValue("NOME")+ '')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('</table></td>')
			oHtmFile:nWriteLN('</tr>')

			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td valign="middle" class="text_01">'+STR0006+'</td>')//Descricao
			oHtmFile:nWriteLN('<td colspan="2" valign="middle" class="text_01"><table width="100%" height="26"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td height="24" bgcolor="#FFFFFF" class="textTab">'+oTema:cValue("DESCRICAO")+ '</td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('</table></td>')
			oHtmFile:nWriteLN('</tr>')
		
			oHtmFile:nWriteLN('</table></td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('</table>')
			oHtmFile:nWriteLN('<img src="'+ cPath+'images/linhadivisoriatitulo.jpg" width="100%" height="20" />')
			oHtmFile:nWriteLN('<table width="100%"  border="0" cellpadding="0" cellspacing="0">')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="1265" height="54"><table width="100%"  border="0" cellpadding="0" cellspacing="0">')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td colspan="2"><img src="'+ cPath+'images/barra_tit_01_a.jpg" /></td>')
			oHtmFile:nWriteLN('<td width="159" height="23" background="'+ cPath+'images/barra_tit_02_a.jpg">')
			oHtmFile:nWriteLN('<!-- Início do bloco para DIV Estatégia-->')
			oHtmFile:nWriteLN('<a href="'+ cPath+'images/barra_tit_02_a.jpg"><img src="'+ cPath+'images/barra_tit_02_a.jpg" width="159" height="23" border="0" align="absbottom"></a>')
			oHtmFile:nWriteLN('<!-- fim do bloco para DIV Estatégia-->')
			oHtmFile:nWriteLN('</td>')
			oHtmFile:nWriteLN('<div id="bar" class="subTit">'+STR0007+'</div>')//Lista de Objetivos
			oHtmFile:nWriteLN('<td width="594"><img src="'+ cPath+'images/barra_tit_03_a.jpg" width="594" height="23"></td>')
			oHtmFile:nWriteLN('<td width="317" colspan="2" background="'+ cPath+'images/barra_tit_04_a.jpg" id="teste">&nbsp;</td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td colspan="6"><table width="759" id="tbl01">')
			oHtmFile:nWriteLN('<tr bgcolor="#7BA0CA">')
			oHtmFile:nWriteLN('<td height="20" bgcolor="#7BA0CA"><div align="center" id="tbl02" class="titTab">')
			oHtmFile:nWriteLN(''+STR0008 +'</div>')//"Objetivos"
			oHtmFile:nWriteLN('<div align="center"></div>')
			oHtmFile:nWriteLN('<div align="center"></div></td>')
			oHtmFile:nWriteLN('</tr>')

			//Lista de Objetivos
			oTema_X_Obj:lSoftSeek(2,{oTema:nValue("ID")}) 
			while(! oTema_X_Obj:lEof() .and. oTema_X_Obj:nValue("PARENTID")==oTema:nValue("ID"))					
				if(oObjetivo:lSeek(1,{oTema_X_Obj:nValue("OBJETIVOID")}))
					oHtmFile:nWriteLN('<tr>')
						oHtmFile:nWriteLN('<td height="20" class="textTab" id="tbl01">' + oObjetivo:cValue("NOME") + '')
						oHtmFile:nWriteLN('<div align="center" class="textTab"> </div>')
						oHtmFile:nWriteLN('<div align="center" class="textTab"></div></td>')
					oHtmFile:nWriteLN('</tr>')
				endif							
				oTema_X_Obj:_Next()
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
		oHtmFile:nWriteLN('</br>')
		oHtmFile:nWriteLN('<DIV style="page-break-after:always"></DIV> ')
		
		oTema:_Next()		
	enddo

	oTema:cSQLFilter("") // Encerra filtro

	//Faz a copia do relatorio para o diretorio de Spool
	//oHtmFile:lCopyFile("relato\Spool\" + cSpoolName)	
	
	oHtmFile:lClose()

Return