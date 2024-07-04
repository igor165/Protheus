#include "BIDefs.ch"
#include "BSCDefs.ch"
#Include "bsc055A_Org.ch"

// ######################################################################################
// Projeto: BSC
// Modulo : Book Estrategico
// Fonte  : bsc055A_Org.prw
// Utiliz : Gera o html do relatorio do book estrategico - Organizacao.
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 09.05.05 | 1776 Alexandre Alves da Silva
// --------------------------------------------------------------------------------------
function bsc055A_Org(oBSCCore,cReportName,cSpoolName,nContextID,nOrgDe,nOrgAte,cPath)
	local oOrganizacao,oEstrategia, oPessoa, oGru_X_Pes, oGrupo
	local cGrupoName
	local oHtmFile := TBIFileIO():New( oBSCCore:cBscPath()+"relato\"+ cReportName)
	
	// Cria o arquivo htm
	If ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oBSCCore:Log(STR0001 + cReportName+ "]", BSC_LOG_SCRFILE+"]")/*//"Erro na criação do arquivo [REL055A_ORG"*/
		oBSCCore:Log(STR0002, BSC_LOG_SCRFILE)/*//"Operação abortada"*/
		return
	endif
	
	oOrganizacao	:= oBSCCore:oGetTable("ORGANIZACAO")
	
	if(oOrganizacao:lSeek(1,{nOrgDe}))
		oEstrategia 	:= oBSCCore:oGetTable("ESTRATEGIA")
		oPessoa			:= oBSCCore:oGetTable("PESSOA")
		oGru_X_Pes		:= oBSCCore:oGetTable("GRPXPESSOA")
		oGrupo			:= oBSCCore:oGetTable("PGRUPO")
		
		oHtmFile:nWriteLN('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">')
		oHtmFile:nWriteLN('<html>')
		oHtmFile:nWriteLN('<head>')
		oHtmFile:nWriteLN('<title>'+ STR0018 +'</title>') //"Book Estratégico Índice:"
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
		oHtmFile:nWriteLN('<td height="609" valign="top"> <table width="100%" height="0" border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="61%" height="36" valign="top" background="'+ cPath+'images/topo_01_fundo.jpg"><img src="'+ cPath+'images/topo_01.jpg" width="772" height="70"></td>')
		oHtmFile:nWriteLN('<td width="39%" valign="top" background="'+ cPath+'images/topo_01_fundo.jpg">&nbsp;</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr bgcolor="#F5F5F3">')
		oHtmFile:nWriteLN('<td height="0" colspan="2" valign="top"> <table width="773" height="80"  border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="40"><table width="774" height="21" border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td colspan="2"><br /> <table width="769" border="0" align="center" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="171" valign="top"><div align="center"></div></td>')
		oHtmFile:nWriteLN('<td width="95" height="17" class="subTit">'+STR0003+'</td>')//Organizacao
		oHtmFile:nWriteLN('<td width="503" class="titOrgani">'+oOrganizacao:cValue("NOME")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td valign="top">&nbsp;</td>')
		oHtmFile:nWriteLN('<td height="20" colspan="2" class="subTit"><img src="'+ cPath+'images/linhadivisoriatitulo.jpg" width="100%" height="20" /></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="200"><table width="775" border="0" cellspacing="2" cellpadding="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="22%" valign="top" class="text_01"><img src="'+ cPath+'images/icone_organizacao.gif" width="56" height="46" /></td>')
		oHtmFile:nWriteLN('<td width="12%" height="27" align="center" valign="middle" class="titOrgani">'+STR0003+'</td>')//Organizacao
		oHtmFile:nWriteLN('<td width="66%" colspan="5" valign="top"><table width="100%" height="43"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="41" bgcolor="#FFFFFF" class="titOrganiBlack">'+oOrganizacao:cValue("NOME")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td colspan="7"><table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="22%" class="text_01">'+STR0009+'</td>')//Descricao
		oHtmFile:nWriteLN('<td width="78%"><table width="100%" height="20"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+oOrganizacao:cValue("DESCRICAO")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td colspan="7"><table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="22%" class="text_01">'+STR0004+'</td>')//Missao
		oHtmFile:nWriteLN('<td width="78%"><table width="100%" height="20"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+oOrganizacao:cValue("MISSAO")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td height="30" colspan="7"><table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="22%" class="text_01">'+STR0005+'</td>')//Visao
		oHtmFile:nWriteLN('<td width="78%"><table width="100%" height="20"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+oOrganizacao:cValue("VISAO")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td height="30" colspan="7"><table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="22%" class="text_01">'+STR0006+'</td>')//Nota
		oHtmFile:nWriteLN('<td width="78%"><table width="100%" height="20"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+oOrganizacao:cValue("NOTAS")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td height="30" colspan="7"><table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="22%" class="text_01">'+STR0007+'</td>')//Politica de qualidade
		oHtmFile:nWriteLN('<td width="78%"><table width="100%" height="20"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+oOrganizacao:cValue("QUALIDADE")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr valign="top">')
		oHtmFile:nWriteLN('<td height="30" colspan="7"><table width="100%" border="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="22%" class="text_01">'+STR0008+'</td>')//Valores
		oHtmFile:nWriteLN('<td width="78%"><table width="100%" height="20"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" bgcolor="#FFFFFF" class="textTab">'+oOrganizacao:cValue("VALORES")+'</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
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
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('<table width="100%"  border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="1265" height="54"><table width="100%"  border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td colspan="2"><img src="'+ cPath+'images/barra_tit_01_a.jpg" width="16" height="23" /></td>')
		oHtmFile:nWriteLN('<td width="151" height="23" background="'+ cPath+'images/barra_tit_02_a.jpg">')
		oHtmFile:nWriteLN('<!-- Início do bloco para DIV Estatégia-->')
		oHtmFile:nWriteLN('<a href="'+ cPath+'images/barra_tit_02_a.jpg"><img src="'+ cPath+'images/barra_tit_02_a.jpg" width="153" height="23" border="0" align="absbottom" /></a>')
		oHtmFile:nWriteLN('<!-- fim do bloco para DIV Estatégia-->')
		oHtmFile:nWriteLN('</td>')
		oHtmFile:nWriteLN('<div id="bar" class="subTit">'+STR0011+'</div>')//Lista de estrategias
		oHtmFile:nWriteLN('<td width="595"><img src="'+ cPath+'images/barra_tit_03_a.jpg" width="594" height="23" /></td>')
		oHtmFile:nWriteLN('<td width="487" colspan="2" background="'+ cPath+'images/barra_tit_04_a.jpg" id="teste">&nbsp;</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="48" colspan="6"> <table width="773" id="tbl01">')
		oHtmFile:nWriteLN('<tr bgcolor="#7BA0CA">')
		oHtmFile:nWriteLN('<td width="57%" height="20" id="tbl01" ><div align="center" class="titTab">'+STR0010+'</div></td>')//estrategia
		oHtmFile:nWriteLN('<td width="23%" height="20" id="tbl01" class="titTab">')
		oHtmFile:nWriteLN('<div align="center">'+STR0012+'')//Data de inicio
		oHtmFile:nWriteLN('</div></td>')
		oHtmFile:nWriteLN('<td width="20%" height="20" id="tbl01" class="titTab">')
		oHtmFile:nWriteLN('<div align="center">'+STR0013+'')//Data Final
		oHtmFile:nWriteLN('</div></td>')
		oHtmFile:nWriteLN('</tr>')
		
		oEstrategia:lSoftSeek(3,{nOrgDe})
		while(! oEstrategia:lEof() .and. oEstrategia:nValue("PARENTID") == nOrgDe )
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td height="20" id="tbl01" class="textTab">&nbsp;' + oEstrategia:cValue("NOME") + '</td>')
			oHtmFile:nWriteLN('<td height="20" id="tbl01" ><div align="center" class="textTab">&nbsp;' + oEstrategia:cValue("DATAINI")+ '</div></td>')
			oHtmFile:nWriteLN('<td height="20" id="tbl01" ><div align="center" class="textTab">&nbsp;' + oEstrategia:cValue("DATAFIN")+ '')
			oHtmFile:nWriteLN('</div></td>')
			oHtmFile:nWriteLN('</tr>')
			oEstrategia:_Next()
		enddo
		
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('<table width="100%"  border="0" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td colspan="2"><img src="'+ cPath+'images/barra_tit_01_a.jpg" width="16" height="23" /></td>')
		oHtmFile:nWriteLN('<td width="151" height="23" background="'+ cPath+'images/barra_tit_02_a.jpg">')
		oHtmFile:nWriteLN('<!-- Início do bloco para DIV Estatégia-->')
		oHtmFile:nWriteLN('<a href="'+ cPath+'images/barra_tit_02_a.jpg"><img src="'+ cPath+'images/barra_tit_02_a.jpg" width="153" height="23" border="0" align="absbottom" /></a>')
		oHtmFile:nWriteLN('<!-- fim do bloco para DIV Estatégia-->')
		oHtmFile:nWriteLN('</td>')
		oHtmFile:nWriteLN('<div id="bar" class="subTit">'+STR0014+'</div>')//Lista de usuarios
		oHtmFile:nWriteLN('<td width="595"><img src="'+ cPath+'images/barra_tit_03_a.jpg" width="594" height="23" /></td>')
		oHtmFile:nWriteLN('<td width="487" colspan="2" background="'+ cPath+'images/barra_tit_04_a.jpg" id="teste">&nbsp;</td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="48" colspan="6"> <table width="773" id="tbl01">')
		oHtmFile:nWriteLN('<tr bgcolor="#7BA0CA">')
		oHtmFile:nWriteLN('<td width="57%" height="20" id="tbl01" ><div align="center" class="titTab">'+STR0015+'</div></td>')//Pessoa
		oHtmFile:nWriteLN('<td width="23%" height="20" id="tbl01" class="titTab">')
		oHtmFile:nWriteLN('<div align="center">'+STR0016+'</div></td>')//Cargo
		oHtmFile:nWriteLN('<td width="20%" height="20" id="tbl01" class="titTab">')
		oHtmFile:nWriteLN('<div align="center">'+STR0017+'</div></td>')//Grupo
		oHtmFile:nWriteLN('</tr>')
		
		
		oPessoa:lSoftSeek(3,{nOrgDe})
		while(! oPessoa:lEof() .and. oPessoa:nValue("PARENTID")==nOrgDe )
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td height="20" id="tbl01" class="textTab">&nbsp;' + oPessoa:cValue("NOME") + '</td>')
			oHtmFile:nWriteLN('<td height="20" id="tbl01" ><div align="center" class="textTab">&nbsp;' + oPessoa:cValue("CARGO") + '</div></td>')
			
			oGru_X_Pes:lSoftSeek(2,{oPessoa:nValue("ID")})
			cGrupoName = "&nbsp;"
			while(! oGru_X_Pes:lEof() .and. oGru_X_Pes:nValue("PESSOAID")==oPessoa:nValue("ID") )
				if(oGrupo:lSeek(1,{oGru_X_Pes:nValue("PARENTID")}))
					cGrupoName += oGrupo:cValue("NOME") + "; "
				endif
				oGru_X_Pes:_Next()
			end while
			oHtmFile:nWriteLN('<td height="20" id="tbl01" ><div align="center" class="textTab">' + cGrupoName+ '</div></td>')
			oHtmFile:nWriteLN('</tr>')
			oPessoa:_Next()
			
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
	
	