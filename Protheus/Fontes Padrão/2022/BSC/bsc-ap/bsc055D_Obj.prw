#include "BIDefs.ch"
#include "BSCDefs.ch"
#Include "bsc055D_Obj.ch"

// ######################################################################################
// Projeto: BSC
// Modulo : bsc055C_Obj
// Fonte  : BSC055C_Obj.prw
// Utiliz : Gera o html do relatorio do book estrategico - Estrategia. 
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 09.05.05 | 1776 Alexandre Alves da Silva
// --------------------------------------------------------------------------------------
function bsc055D_Obj(oBSCCore,cReportName,cSpoolName,nContextID,cObjDe,cObjAte,cPath)
	local oHtmFile := TBIFileIO():New(oBSCCore:cBscPath()+"relato\" + cReportName)
	local oIndicador,oObjetivo,oIniciativa
	local aDadosCab := {}
	
	// Cria o arquivo htm
	If ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oBSCCore:Log(STR0001 + cReportName+ "]", BSC_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL055A_ORG"*/
		oBSCCore:Log(STR0002, BSC_LOG_SCRFILE)/*//"Operação abortada"*/
		return
	endif

	//Criando a instancia das classe.
	oObjetivo	:= oBSCCore:oGetTable("OBJETIVO")
	oIndicador	:= oBSCCore:oGetTable("INDICADOR")
	oIniciativa	:= oBSCCore:oGetTable("INICIATIVA")

	oObjetivo:SetOrder(2) /*Por ordem de NOME.*/
	oObjetivo:cSQLFilter("CONTEXTID = " + cBIStr(nContextID) + " AND NOME BETWEEN '" + cObjDe + "' AND '" + cObjAte + "'"   ) // Filtra pelo pai
	oObjetivo:lFiltered(.t.)
	oObjetivo:_First()
    
    /*Monta o cabeçalho da página.*/ 
    If(!oObjetivo:lEof())  
              
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
				oHtmFile:nWriteLN('<td height="0" valign="top">')
				oHtmFile:nWriteLN('<table width="100%" height="320" border="0" cellpadding="0" cellspacing="0">')
				oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td width="61%" height="36" valign="top" background="'+ cPath+'images/topo_01_fundo.jpg"><img src="'+ cPath+'images/topo_01.jpg" width="772" height="70"></td>')
				oHtmFile:nWriteLN('<td width="39%" valign="top" background="'+ cPath+'images/topo_01_fundo.jpg">&nbsp;</td>')
				oHtmFile:nWriteLN('</tr>')
   
   	EndIf

	while( ! oObjetivo:lEof())
		//Atualiza os dados do cabecalho
		BSC055PreCab(oBSCCore,oObjetivo,@aDadosCab,nContextID)


				oHtmFile:nWriteLN('<tr bgcolor="#F5F5F3">')
				oHtmFile:nWriteLN('<td height="192" colspan="2" valign="top"><table width="770" height="145" border="0" cellpadding="0" cellspacing="0">')
				oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td height="126" colspan="2"><br />')
				oHtmFile:nWriteLN('<table width="769" border="0" align="center" cellpadding="0" cellspacing="0">')
				oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td width="34" rowspan="5" valign="top"><div align="center"></div></td>')
				oHtmFile:nWriteLN('<td width="96" height="17" class="subTit">'+ STR0004+'</td>')// "Organização"
				oHtmFile:nWriteLN('<td colspan="2"><span class="titOrgani">'+ aDadosCab[1,2] +'</span></td>')
				oHtmFile:nWriteLN('</tr>')
				oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td height="17" class="subTit">'+ STR0005+'</td>')//Estrategia
				oHtmFile:nWriteLN('<td colspan="2"><span class="titOrgani">'+ aDadosCab[2,2] +'</span></td>')
				oHtmFile:nWriteLN('</tr>')
				oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td height="17" class="subTit">'+ STR0006+'</td>')//Perspectiva
				oHtmFile:nWriteLN('<td colspan="2"><span class="titOrgani">'+ aDadosCab[3,2] +'</span></td>')
				oHtmFile:nWriteLN('</tr>')
				oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td height="16" colspan="3"><img src="'+ cPath+'images/linhadivisoriatitulo.jpg" width="100%" height="14" /></td>')
				oHtmFile:nWriteLN('</tr>')
				oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td height="21" colspan="2" class="subTit">'+STR0007+'</td>')// "Responsável"
				oHtmFile:nWriteLN('<td width="637" height="21" class="subTit2">'+bsc055LisPes(oBSCCore,oObjetivo:nValue("RESPID"),oObjetivo:cValue("TIPOPESSOA"))+'')
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
				oHtmFile:nWriteLN('</table>')
				oHtmFile:nWriteLN('<table width="759"  border="0" cellspacing="2" cellpadding="0">')
				oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td width="94" valign="top"><div align="center"><img src="'+ cPath+'images/icone_objetivo.gif" width="56" height="46" /></div></td>')
				oHtmFile:nWriteLN('<td width="82" valign="middle" bordercolor="#999999" class="titOrgani">'+STR0008+'</td>')//Objetivo
				oHtmFile:nWriteLN('<td width="586" valign="top" bordercolor="#999999"><table width="582" height="42"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
				oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td width="578" height="40" bgcolor="#FFFFFF" class="titOrganiBlack">'+oObjetivo:cValue("NOME") +'</td>')
				oHtmFile:nWriteLN('</tr>')
				oHtmFile:nWriteLN('</table></td>')
				oHtmFile:nWriteLN('</tr>')
				oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td width="94" valign="middle" bordercolor="#999999" class="text_01">'+STR0009+'</td>')
				oHtmFile:nWriteLN('<td height="33" colspan="2" valign="top" class="text_01">')
				oHtmFile:nWriteLN('<table width="665" height="33"  border="1" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">')
				oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td width="661" height="31" bgcolor="#FFFFFF" class="textTab">'+oObjetivo:cValue("DESCRICAO")+'</td>')
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
				oHtmFile:nWriteLN('<td colspan="2"><img src="'+ cPath+'images/barra_tit_01_a.jpg" width="16" height="23"></td>')
				oHtmFile:nWriteLN('<td width="151" height="23" background="'+ cPath+'images/barra_tit_02_a.jpg">')
				oHtmFile:nWriteLN('<!-- Início do bloco para DIV Estatégia-->')
				oHtmFile:nWriteLN('<a href="'+ cPath+'images/barra_tit_02_a.jpg"><img src="'+ cPath+'images/barra_tit_02_a.jpg" width="153" height="23" border="0" align="absbottom"></a>')
				oHtmFile:nWriteLN('<!-- fim do bloco para DIV Estatégia-->')
				oHtmFile:nWriteLN('</td>')
				oHtmFile:nWriteLN('<div id="bar" class="subTit">'+STR0010+'</div>')//Lista de Indicadores.
				oHtmFile:nWriteLN('<td width="595"><img src="'+ cPath+'images/barra_tit_03_a.jpg" width="594" height="23"></td>')
				oHtmFile:nWriteLN('<td width="487" colspan="2" background="'+ cPath+'images/barra_tit_04_a.jpg" id="lstIndicador">&nbsp;</td>')
				oHtmFile:nWriteLN('</tr>')
				oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td colspan="6">')
				oHtmFile:nWriteLN('<table width="759" id="tbl01">')
				oHtmFile:nWriteLN('<tr bgcolor="#7BA0CA">')
				oHtmFile:nWriteLN('<td height="20" bgcolor="#7BA0CA"><div align="center" id="tbl01" class="titTab">'+STR0011+'</div>')//Indicadores
				oHtmFile:nWriteLN('<div align="center"></div>')
				oHtmFile:nWriteLN('<div align="center"></div></td>')
				oHtmFile:nWriteLN('</tr>')

                //Lista os indicadores
				oIndicador:lSoftSeek(3,{oObjetivo:nValue("ID")}) 
				while(! oIndicador:lEof() .and. oIndicador:nValue("PARENTID")==oObjetivo:nValue("ID"))
					oHtmFile:nWriteLN('<tr>')
					oHtmFile:nWriteLN('<td height="20" class="textTab" id="tbl01">' + oIndicador:cValue("NOME") + '')
					oHtmFile:nWriteLN('<div align="center" class="textTab"> </div>')
					oHtmFile:nWriteLN('<div align="center" class="textTab"></div></td>')
					oHtmFile:nWriteLN('</tr>')                                          
					oIndicador:_Next()
				enddo
				
				oHtmFile:nWriteLN('</table>')
				oHtmFile:nWriteLN('</td>')
				oHtmFile:nWriteLN('</tr>')
				oHtmFile:nWriteLN('</table> </td>')
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
				oHtmFile:nWriteLN('<div id="bar" class="subTit">'+STR0012+'	</div>')// "Lista de Iniciativas"
				oHtmFile:nWriteLN('<td width="594"><img src="'+ cPath+'images/barra_tit_03_a.jpg" width="594" height="23"></td>')
				oHtmFile:nWriteLN('<td width="490" colspan="2" background="'+ cPath+'images/barra_tit_04_a.jpg"><img src="'+ cPath+'images/fundo_barra_tit.jpg" width="1" height="7"></td>')
				oHtmFile:nWriteLN('</tr>')
				oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td height="26" colspan="6">')
				oHtmFile:nWriteLN('<table width="759" id="tbl01">')
				oHtmFile:nWriteLN('<tr bgcolor="#7BA0CA">')
				oHtmFile:nWriteLN('<td width="269"><div align="center" id="tbl01" class="titTab">'+STR0013+'</div></td>')//Iniciativas
				oHtmFile:nWriteLN('<td width="105"><div align="center" id="tbl01" class="titTab">'+STR0014+'</div></td>')//Data Inicio
				oHtmFile:nWriteLN('<td width="105"><div align="center" id="tbl01" class="titTab">'+STR0015+'</div></td>')//Data Final
				oHtmFile:nWriteLN('<td width="260" height="20"><div align="center" id="tbl01" class="titTab">'+STR0016+'</div></td>')//Responsavel
				oHtmFile:nWriteLN('</tr>')

				oIniciativa:lSoftSeek(3,{oObjetivo:nValue("ID")}) 
				while(! oIniciativa:lEof() .and. oIniciativa:nValue("PARENTID")==oObjetivo:nValue("ID"))
					oHtmFile:nWriteLN('<tr>')
						oHtmFile:nWriteLN('<td width="269" class="textTab" id="tbl01">' + oIniciativa:cValue("NOME") + '</td>')
						oHtmFile:nWriteLN('<td width="105" align="center" class="textTab" id="tbl01">' + oIniciativa:cValue("DATAINI") + '</td>')
						oHtmFile:nWriteLN('<td width="105" align="center" class="textTab" id="tbl01">' + oIniciativa:cValue("DATAFIN") + '</td>')
						oHtmFile:nWriteLN('<td width="260" height="20" class="textTab" id="tbl01">')
						oHtmFile:nWriteLN(''+bsc055LisPes(oBSCCore,oIniciativa:nValue("RESPID"),oIniciativa:cValue("TIPOPESSOA"))+'')
						oHtmFile:nWriteLN('<div align="center" class="textTab"> </div><div align="center"><span class="style2"><span class="textTab"> </span></span></div></td>')
					oHtmFile:nWriteLN('</tr>')

					oIniciativa:_Next()
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
		oHtmFile:nWriteLN('</br>')
		oHtmFile:nWriteLN('<DIV style="page-break-after:always"></DIV> ')
		
		oObjetivo:_Next()

	end

	oObjetivo:cSQLFilter("") // Encerra filtro

	//Faz a copia do relatorio para o diretorio de Spool
	//oHtmFile:lCopyFile("relato\Spool\" + cSpoolName)	
	
	oHtmFile:lClose()

Return