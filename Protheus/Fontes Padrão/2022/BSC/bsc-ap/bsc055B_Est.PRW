#include "BIDefs.ch"
#include "BSCDefs.ch"
#Include "bsc055B_Est.ch"

// ######################################################################################
// Projeto: BSC
// Modulo : bsc055B_Est
// Fonte  : BSC055_Book.prw
// Utiliz : Gera o html do relatorio do book estrategico - Estrategia. 
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 09.05.05 | 1776 Alexandre Alves da Silva
// --------------------------------------------------------------------------------------
function bsc055B_Est(oBSCCore,cReportName,cSpoolName,nContextID,nEstDe, nEstAte,cPath)
	local oHtmFile := TBIFileIO():New(oBSCCore:cBscPath()+"relato\" + cReportName)
	local oEstrategia,oPerspectiva,oTema

	// Cria o arquivo htm
	If ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oBSCCore:Log(STR0001 + cReportName+ "]", BSC_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL055A_ORG"*/
		oBSCCore:Log(STR0002, BSC_LOG_SCRFILE)/*//"Operação abortada"*/
		return
	endif

	oEstrategia		:= oBSCCore:oGetTable("ESTRATEGIA")
	oPerspectiva	:= oBSCCore:oGetTable("PERSPECTIVA")
	oTema			:= oBSCCore:oGetTable("TEMAEST")
	oOrganizacao	:= oBSCCore:oGetTable("ORGANIZACAO")
	//Atualiza os dados do cabecalho
	//BSC055PreCab(oBSCCore,oEstrategia,@aDadosCab,nEstDe)

	if(oEstrategia:lSeek(1,{nEstDe}))		
		oOrganizacao:lSeek(1,{oEstrategia:nValue("PARENTID")})	
		
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
		oHtmFile:nWriteLN('<td valign="top"><table width="100%" height="327" border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="61%" height="36" valign="top" background="'+ cPath+'images/topo_01_fundo.jpg"><img src="'+ cPath+'images/topo_01.jpg" width="772" height="70"></td>')
		oHtmFile:nWriteLN('<td width="39%" valign="top" background="'+ cPath+'images/topo_01_fundo.jpg">&nbsp;</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr bgcolor="#F5F5F3">')
		oHtmFile:nWriteLN('<td height="237" colspan="2" valign="top"> ')
		oHtmFile:nWriteLN('<table width="769" height="21" border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr> ')
		oHtmFile:nWriteLN('<td width="769" colspan="2"><br /> ')
		oHtmFile:nWriteLN('<table width="773" border="0" align="center" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr> ')
		oHtmFile:nWriteLN('<td width="88" rowspan="3" valign="top"><div align="center"></div></td>')
		oHtmFile:nWriteLN('<td width="89" height="17" class="subTit">'+ STR0004 + '</td>')//Organizacao
		oHtmFile:nWriteLN('<td width="596" height="17" colspan="2" class="titOrgani">'+ oOrganizacao:cValue("NOME") + '</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr> ')
		oHtmFile:nWriteLN('<td height="19" colspan="3" class="subTit"><img src="'+ cPath+'images/linhadivisoriatitulo.jpg" width="100%" height="14" /></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('<table width="771"  border="0" cellspacing="2" cellpadding="0">')
		oHtmFile:nWriteLN('<tr> ')
		oHtmFile:nWriteLN('<td width="86" valign="middle"> <div align="center"><img src="'+ cPath+'images/icone_estrategia.gif" width="56" height="46" align="left" /></div></td>')
		oHtmFile:nWriteLN('<td width="91" valign="middle" bordercolor="#999999" class="titOrgani">'+ STR0005 +'</td>')//"Estratégia"
		oHtmFile:nWriteLN('<td width="586" valign="middle" bordercolor="#999999"> <table width="594" height="27"  border="1" align="center" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr> ')
		oHtmFile:nWriteLN('<td width="590" height="25" bgcolor="#FFFFFF" class="titOrganiBlack">'+oEstrategia:cValue("NOME")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr> ')
		oHtmFile:nWriteLN('<td align="left" class="text_01" valign="middle">'+ STR0006 +'</td>')//"Descrição"
		oHtmFile:nWriteLN('<td colspan="2" valign="middle"><table width="687" height="55"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr> ')
		oHtmFile:nWriteLN('<td width="683" height="55" bgcolor="#FFFFFF" class="textTab">'+ oEstrategia:cValue("DESCRICAO")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr> ')
		oHtmFile:nWriteLN('<td align="left" valign="middle"><span class="text_01">'+STR0007+'</span></td>')//"Data Incio"
		oHtmFile:nWriteLN('<td colspan="2" valign="middle"><table width="104" height="22"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr> ')
		oHtmFile:nWriteLN('<td width="147" height="20" bgcolor="#FFFFFF" class="textTab"> ')
		oHtmFile:nWriteLN('<div align="center">'+oEstrategia:cValue("DATAINI")+'</div></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table> </td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr> ')
		oHtmFile:nWriteLN('<td align="left" valign="middle"><span class="text_01">'+STR0008	+'</span></td>')//"Data Final"
		oHtmFile:nWriteLN('<td colspan="2" valign="middle"><table width="104" height="22"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr> ')
		oHtmFile:nWriteLN('<td width="147" height="20" bgcolor="#FFFFFF" class="textTab"> ')
		oHtmFile:nWriteLN('<div align="center">'+oEstrategia:cValue("DATAFIN")+'</div></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		//Final da tela de detalhes
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" colspan="2" valign="top"><img src="'+ cPath+'images/linhadivisoriatitulo.jpg" width="100%" height="20" /></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('<table width="100%"  border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr> ')
		oHtmFile:nWriteLN('<td width="1265" height="175"> ')
		oHtmFile:nWriteLN('<table width="100%"  border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr> ')
		oHtmFile:nWriteLN('<td colspan="2"><span class="subTit"><img src="'+ cPath+'images/barra_tit_01_a.jpg" width="16" height="23" /></span></td>')
		oHtmFile:nWriteLN('<td width="151" height="23" background="'+ cPath+'images/barra_tit_02_a.jpg"> ')
		oHtmFile:nWriteLN('<span class="subTit"> ')
		oHtmFile:nWriteLN('<!-- Início do bloco para DIV Estatégia-->')
		oHtmFile:nWriteLN('<a href="'+ cPath+'images/barra_tit_02_a.jpg"><img src="'+ cPath+'images/barra_tit_02_a.jpg" width="153" height="23" border="0" align="absbottom" /></a> ')
		oHtmFile:nWriteLN('<!-- fim do bloco para DIV Estatégia-->')
		oHtmFile:nWriteLN('</span></td>')
		oHtmFile:nWriteLN('<div id="bar" class="subTit"><span class="subTit">'+STR0009	+'</span></div>')//Lista de Perspectivas
		oHtmFile:nWriteLN('<td width="594"><span class="subTit"><img src="'+ cPath+'images/barra_tit_03_a.jpg" width="594" height="23" /></span></td>')
		oHtmFile:nWriteLN('<td width="487" colspan="2" background="'+ cPath+'images/barra_tit_04_a.jpg" id="teste">&nbsp;</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr> ')
		oHtmFile:nWriteLN('<td height="112" colspan="6"> ')
		oHtmFile:nWriteLN('<table width="772" id="tbl01">')
		oHtmFile:nWriteLN('<tr bgcolor="#7BA0CA"> ')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#7BA0CA"><div align="center" id="tbl02" class="titTab"><span class="subTit">'+STR0010	 +'')//Perspectivas
		oHtmFile:nWriteLN('</span></div>')
		oHtmFile:nWriteLN('<div align="center"></div></td>')
		oHtmFile:nWriteLN('</tr>')
		
		//Lista das perspectivas
		oPerspectiva:lSoftSeek(3,{nEstDe}) 
		while(! oPerspectiva:lEof() .and. oPerspectiva:nValue("PARENTID")==nEstDe )
			oHtmFile:nWriteLN(' <tr> ')
				oHtmFile:nWriteLN('<td height="20" class="textTab" id="tbl01">' + oPerspectiva:cValue("NOME") + ' ')
				oHtmFile:nWriteLN('<div align="center" class="textTab"></div></td>')
			oHtmFile:nWriteLN('</tr>')		
			oPerspectiva:_Next()
		enddo

		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('<table width="100%"  border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td colspan="2"><span class="subTit"><img src="'+ cPath+'images/barra_tit_01_a.jpg" width="16" height="23"></span></td>')
		oHtmFile:nWriteLN('<td width="151">')
		oHtmFile:nWriteLN('<span class="subTit"><!-- Início do bloco para DIV Usuários-->		  ')
		oHtmFile:nWriteLN('<img src="'+ cPath+'images/barra_tit_02_a.jpg" width="153" height="23" align="absbottom">	')
		oHtmFile:nWriteLN('<!-- Fim do bloco para DIV Usuários-->	')
		oHtmFile:nWriteLN('</span></td>')
		oHtmFile:nWriteLN('<div id="bar" class="subTit"><span class="subTit">'+STR0011+'</span></div>')//Lista de Temas
		oHtmFile:nWriteLN('<td width="594"><span class="subTit"><img src="'+ cPath+'images/barra_tit_03_a.jpg" width="594" height="23"></span></td>')
		oHtmFile:nWriteLN('<td width="490" colspan="2" background="'+ cPath+'images/barra_tit_04_a.jpg"><span class="subTit"><img src="'+ cPath+'images/fundo_barra_tit.jpg" width="1" height="7"></span></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td colspan="6"><table width="772" id="tbl01">')
		oHtmFile:nWriteLN('<tr bgcolor="#7BA0CA">')
		oHtmFile:nWriteLN('<td height="20"><div id="tbl02" align="center" class="titTab"><span class="subTit">'+STR0012+'</span></div>')// Temas
		oHtmFile:nWriteLN('<div align="center" class="titTab"> </div></td>')
		oHtmFile:nWriteLN('</tr>')
		
		oTema:lSoftSeek(2,{nEstDe}) 
		while(! oTema:lEof() .and. oTema:nValue("PARENTID")==nEstDe )
              oHtmFile:nWriteLN('<tr>')
                oHtmFile:nWriteLN('<td height="20" class="textTab" id="tbl01">' + oTema:cValue("NOME") + '')
                 oHtmFile:nWriteLN('</span><div align="center"> </div></td>')
              oHtmFile:nWriteLN('</tr>')
			oTema:_Next()
		enddo
              
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('</body>')
		oHtmFile:nWriteLN('</html>')
	
		//Faz a copia do relatorio para o diretorio de Spool
		//oHtmFile:lCopyFile("relato\Spool\" + cSpoolName)	
		
		oHtmFile:lClose()
	endif
Return