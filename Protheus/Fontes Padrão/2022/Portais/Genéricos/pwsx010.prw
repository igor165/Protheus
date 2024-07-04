#INCLUDE "PWSX010.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSX001   บAutor  ณLuiz Felipe Couto    บ Data ณ  17/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Seleciona o portal que deve ser aberto de acordo com o cod. บฑฑ
ฑฑบ          ณ do usuario no portal.                                       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista      ณ Data/Bops/Ver ณManutencao Efetuada                      บฑฑ
ฑฑบEmerson Camposณ 29/04/2014 ณAjuste na apresenta็ใo do menu para o moduloบฑฑ
ฑฑบ              ณ            ณde RH, que serแ ordenado nos agrupadores porบฑฑ
ฑฑบ              ณ            ณordem numerica e os itens dos agrupadores   บฑฑ
ฑฑบ              ณ            ณpor ordem alfabetica                        บฑฑ
ฑฑบ              ณ            ณRemovido um fieldpos.                       บฑฑ
ฑฑบMatheus M. 	 ณ 08/12/2016 ณAjuste na verifica็ใo de acesso com mult-ma-บฑฑ
ฑฑบ              ณ            ณtrํculas, para apresentar o menu corretamen-บฑฑ
ฑฑบ              ณ            ณte.										   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSX001()

Local cHtml := ""
Local cAph := ""

WEB EXTENDED INIT cHtml START "InSite"

SetPrtInf( HttpPost->cCodPrt, GetUsrCode() )

If HttpPost->cCodPrt == "000001"
	cAph := "PWSC010"
ElseIf HttpPost->cCodPrt == "000002"
	cAph := "PWSF010"
ElseIf HttpPost->cCodPrt == "000003"
	cAph := "PWSV010"
ElseIf HttpPost->cCodPrt == "000004"
	cAph := "PWST010"
ElseIf HttpPost->cCodPrt == "000006"
	cAph := "PWSQ010"	
Else
	cAph := "PWSX001"
Endif

ExecInPage(cAph)

WEB EXTENDED END

Return cHtml   
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณPorEncode  ณ Autor ณ Fernando Separovic	   ณ Data ณ 22.04.09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ trata caracteres com acento em paginas html      			 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
function PorEncode(acValue, alApplet)
	local cRet := acValue
	local aDe, aPara
	if valType(acValue) == "C"
		default alApplet := .f.
		if !alApplet                      			      //บ        , ช      ,แ         ,ใ         ,โ        ,เ         ,้         ,๊        ,ํ         ,๔        ,๓         ,๕         ,๚         ,ü       ,๙         ,็
			aDe   := { "<"   , ">"   , "  "          , "\" , chr(167),chr(166),chr(225)  ,chr(227)  ,chr(226) ,chr(224)  ,chr(233)  ,chr(234) ,chr(237)  ,chr(244) ,chr(243)  ,chr(245)  ,chr(250)  ,chr(252),chr(249)  ,chr(231)   }
			aPara := { "&lt;", "&gt;", "&nbsp;&nbsp;", "\\", "&ordm;","&ordf;","&aacute;","&atilde;","&acirc;","&agrave;","&eacute;","&ecirc;","&iacute;","&ocirc;","&oacute;","&otilde;","&uacute;","&uuml;","&ugrave;","&ccedil;" }
		else
			aDe   := { "\" , '"' , "'", CRLF, CR, LF  }
			aPara := { "\\", '\"', "\'", "\n", "\n", "" }
		endif
		aEval(aDe, { |x, i|cRet := strTran(cRet, x, aPara[i]) })
	endif
	
return cRet 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณPORESQSENH  ณ Autor ณ Fernando Separovic	   ณ Data ณ 22.04.09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ chama a pagina "esqueci minha a senha"                        ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Web Function PORESQSENH()

LOCAL cHtml := ""

WEB EXTENDED INIT cHtml

cHtml += ExecInPage("PORESQSENH")

WEB EXTENDED END

Return cHtml
        
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณPWSANovoLoginณ Autor ณ Marcelo Faria		   ณ Data ณ 16.04.12 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ chama a pagina "Login Unificado" para cadastro Portal RH      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Web Function PWSANovoLogin()
LOCAL cHtml 			:= ""
Private cMsgLog	:= ""
Private cAtuUsu 	:= HttpPost->cLogin 

WEB EXTENDED INIT cHtml
	cHtml += ExecInPage("PWSANovoLogin")
WEB EXTENDED END

Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณAtualizaLoginณ Autor ณ Marcelo Faria		   ณ Data ณ 16.04.12 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ chama webservice para atualizar o novo login unificado RH     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Web Function PWSAAtualizaLogin()
Local oOrg
Local cHtml 			:= ""
Private lAtuLog	:= .T.
Private cMsgLog	:= ""
Private cAtuUsu 	:= HttpPost->cLogin 

WEB EXTENDED INIT cHtml

	oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
	WsChgURL(@oOrg,"ORGSTRUCTURE.APW")  

	if oOrg <> Nil	
		oOrg:cPrtEmpFil		:= ""
		oOrg:cPrtOriLogin	:= HttpSession->Login
		oOrg:cPrtUnifLogin	:= HttpPost->cNovoLog
		oOrg:cPrtAcess		:= HttpSession->cAcessoPP
		IF oOrg:PutPrtULogin()
			cMsgLog	:= STR0034 //Login unificado, atualizado com sucesso!
		else
			lAtuLog	:= .F.
			cMsgLog 	:= PWSGetWSError()
		EndIf

		cHtml += ExecInPage("PWSANovoLogin")
	Else
		HttpSession->_HTMLERRO[1] := 'Erro de Processamento'
		HttpSession->_HTMLERRO[2] := "Erro no instanciamento do Webservice"
		HttpSession->_HTMLERRO[3] := ''
		cHtml += ExecInPage( "PWSXERRO" )
	endif

WEB EXTENDED END

Return cHtml
        
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณPrepEnvPor  ณ Autor ณ Fernando Separovic	   ณ Data ณ 22.04.09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricaoณ Permite utilizar as tabelas do ERP em Webservices e paginas aphณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
function PrepEnvPor()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณColeta qual a empresa e a filial presente no JOB corrent do .iniณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  

	cEmpFil := GetPvProfString( getWebJob(), "PrepareIn", "", GetADV97() )
	cEmp := substr(cEmpFil,1,2)
	cFil := substr(cEmpFil,4,2)   
	
	If Empty(cEmp) .OR. Empty(cFil)
		return .F.	
	Endif
	
	
	PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil  
	
return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณPortMail      ณ Autor ณ Fernando Separovic     ณ Data ณ 22.04.09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Validacao de dados e envio de e-mail com a senha do usuแrio	   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Web Function PortMail() 

	Local oServer
	Local oMessage
	Local oObj
	
	Local cSmtpEnv
	Local cUsuEmai
	Local cUsuPass
	Local cEmail	:= ""
	Local cSenha	:= "" 
	Local cCorpo	:= ""
	Local lAuth	    
	Local lResult 	:= .F.
	Local nAt 		:= 0
	Local cUser 	:= ""
	Local cFrom 	:= ""
		
	If !(PrepEnvPor())
		Return PWSHtmlAlert( "",STR0037, STR0009, "W_PORESQSENH.APW", .F.) //"Erro ao reenviar a senha"###"Empresa ou Filial nใo informadas na chave PREPAREIN do Job do Portal no arquivo de configura็ใo do servidor"
	EndIf
	
	dbSelectArea("AI3")
	dbSetOrder(2)
		
	If !(MsSeek(xFilial("AI3")+ALLTRIM(HttpPost->cUser)))
		Return PWSHtmlAlert( "",STR0037, STR0011, "W_PORESQSENH.APW", .F.) //"Erro ao reenviar a senha"###"Usuแrio nใo cadastrado"
	Else                                                               
		cEmail := AI3_EMAIL
		cSenha := AI3_PSW 
		
		If Empty(cEmail) 
			Return PWSHtmlAlert( "",STR0037, STR0028, "W_PORESQSENH.APW", .F.) //"Erro ao reenviar a senha"###"Usuแrio sem email cadastrado"
		Endif
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณObj																	   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
		WsChgURL( @oObj, "CFGDICTIONARY.APW" )
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณParametro															   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oObj:cUSERCODE	:= "MSALPHA"
		oObj:cMVPARAM	:= "MV_RELSERV"
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMetodo																   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If oObj:GETPARAM()
			cSmtpEnv := oObj:cGETPARAMRESULT
			If Type(cSmtpEnv) == 'L'
				Return PWSHtmlAlert( "",STR0037, STR0012, "W_PORESQSENH.APW", .F.) //"Erro ao reenviar a senha"###"Parametro MV_RELSERV nใo encontrado"
			Else
				If Empty(cSmtpEnv)
					Return PWSHtmlAlert( "",STR0037, STR0013, "W_PORESQSENH.APW", .F.) //"Erro ao reenviar a senha"###"Parametro MV_RELSERV sem conteudo"
				EndIf
			EndIf
		Else
			Return PWSHtmlAlert( "",STR0037, STR0012, "W_PORESQSENH.APW", .F.) //"Erro ao reenviar a senha"###"Parametro MV_RELSERV nใo encontrado"
		EndIf
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณPega a conta do usuario para fazer o envio							   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oObj:cMVPARAM	:= "MV_RELACNT"
		If oObj:GETPARAM()
			cUsuEmai := oObj:cGETPARAMRESULT
			If Type(cUsuEmai) == 'L'
				Return PWSHtmlAlert( "",STR0037, STR0014, "W_PORESQSENH.APW", .F.) //"Erro ao reenviar a senha"###"Parametro MV_RELACNT nใo encontrado"
			Else
				If Empty(cUsuEmai)
					Return PWSHtmlAlert( "",STR0037, STR0015, "W_PORESQSENH.APW", .F.) //"Erro ao reenviar a senha"###"Parametro MV_RELACNT sem conteudo"
				EndIf
			EndIf
		Else
			Return PWSHtmlAlert( "",STR0037, STR0014, "W_PORESQSENH.APW", .F.) //"Erro ao reenviar a senha"###"Parametro MV_RELACNT nใo encontrado"
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se o servidor de envio de email necessita autenticacao		   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		oObj:cMVPARAM	:= "MV_RELAUTH" 
		If oObj:GETPARAM()
			lAuth := Iif(Valtype(oObj:cGETPARAMRESULT)== "C",&(oObj:cGETPARAMRESULT) ,oObj:cGETPARAMRESULT)
			If ValType(lAuth)  <> "L"
				Return PWSHtmlAlert( "",STR0037, STR0029, "W_PORESQSENH.APW", .F.) //"Erro ao reenviar a senha"###"Parametro MV_RELAUTH nใo encontrado"
			EndIf
		Else
			Return PWSHtmlAlert( "",STR0037, STR0029, "W_PORESQSENH.APW", .F.) //"Erro ao reenviar a senha"###"Parametro MV_RELAUTH nใo encontrado"
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณPega a senha do usuario para fazer o envio							   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oObj:cMVPARAM	:= "MV_RELPSW"
		If oObj:GETPARAM()
			cUsuPass := oObj:cGETPARAMRESULT
			If Type(cUsuEmai) = 'L'
				Return PWSHtmlAlert( "",STR0037, STR0016, "W_PORESQSENH.APW", .F.) //"Erro ao reenviar a senha"###"Parametro MV_RELPSW nใo encontrado"
			Else
				If Empty(cUsuPass) .and. lAuth
					Return PWSHtmlAlert( "",STR0037, STR0017, "W_PORESQSENH.APW", .F.) //"Erro ao reenviar a senha"###"Parametro MV_RELPSW sem conteudo"
				EndIf
			EndIf
		Else
			Return PWSHtmlAlert( "",STR0037, STR0016, "W_PORESQSENH.APW", .F.) //"Erro ao reenviar a senha"###"Parametro MV_RELPSW nใo encontrado"
		EndIf


		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณPega o email do remetente para fazer o envio							   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oObj:cMVPARAM	:= "MV_RELFROM"
		If oObj:GETPARAM()
			cFrom := oObj:cGETPARAMRESULT
			If Type(cFrom) = 'L'
				Return PWSHtmlAlert( "",STR0037, STR0035, "W_PORESQSENH.APW", .F.) //"Erro ao reenviar a senha"###"Parโmetro MV_RELFROM nใo encontrado"
			Else
				If Empty(cFrom)
					Return PWSHtmlAlert( "",STR0037, STR0036, "W_PORESQSENH.APW", .F.) //"Erro ao reenviar a senha"###"Parโmetro MV_RELFROM sem conte๚do"
				EndIf
			EndIf
		Else
			Return PWSHtmlAlert( "",STR0037, STR0035, "W_PORESQSENH.APW", .F.) //"Erro ao reenviar a senha"###"Parโmetro MV_RELFROM nใo encontrado"
		EndIf
	EndIf	

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe pode continuar													   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    // monta o corpo da mensagem
	cCorpo 				:= PorEncode(STR0021) + ALLTRIM(AI3_NOME) + "," //"Sr (a) "
	cCorpo				+= "<br><br>"
	cCorpo				+= PorEncode(STR0022) //"Conforme solicita็ใo voc๊ estแ recebendo sua senha pessoal e intransferํvel de acesso ao Portal."
	cCorpo				+= "<br>" 
	cCorpo				+= PorEncode(STR0023) + cSenha //"Sua senha ้: "
	cCorpo				+= "<br><br><br>"   
	cCorpo          	+= PorEncode(STR0024) //"At. Administrador"
    
	//conecta com o servidor de envio
	CONNECT SMTP SERVER cSmtpEnv ACCOUNT cUsuEmai PASSWORD cUsuPass RESULT lResult
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se o Servidor de EMAIL necessita de Autenticacaoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	if lResult .and. lAuth
		//Primeiro tenta fazer a Autenticacao de E-mail utilizando o e-mail completo
		lResult := MailAuth(cUsuEmai, cUsuPass)
		//Se nao conseguiu fazer a Autenticacao usando o E-mail completo, tenta fazer a autenticacao usando apenas o nome de usuario do E-mail
		if !lResult
			nAt 	:= At("@",cUsuEmai)
			cUser 	:= If(nAt>0,Subs(cUsuEmai,1,nAt-1),cUsuEmai)
			lResult := MailAuth(cUser, cUsuPass)
		endif  
	endif	
	
	If lResult
		//realiza o envio de email
		SEND MAIL FROM cFrom ;
		TO      	cEmail;
		SUBJECT 	PorEncode(STR0020); //"Envio de senha" 
   		BODY    	cCorpo;
		RESULT lResult 
	
		If !lResult
			//Erro no envio do email
			Return PWSHtmlAlert( "",STR0037, STR0025, "W_PORESQSENH.APW", .F. ) //"Erro ao reenviar a senha"###"Erro ao enviar o e-mail"
		EndIf
	
		DISCONNECT SMTP SERVER
	
	Else
		//Erro na conexao com o SMTP Server
		Return PWSHtmlAlert( "",STR0037, STR0019, "W_PORESQSENH.APW", .F. ) //"Erro ao reenviar a senha"###"Falha ao conectar"
	EndIf	
	EndEnv()
	Return PWSHtmlAlert( "",STR0020, STR0027, "W_PORESQSENH.APW", .F.) //"Envio de senha"###"Email enviado com sucesso"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSX010   บAutor  ณLuiz Felipe Couto    บ Data ณ  17/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Seleciona os modulos que estao disponiveis para o usuario   บฑฑ
ฑฑบ          ณ logado.                                                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSX010()
Local cHtml := ""

if(Type("HttpGet->redirect") <> "U")
	HttpSession->cRedirect := HttpGet->redirect
endIf

WEB EXTENDED INIT cHtml START "InSite"

cHtml += SelModulos()

WEB EXTENDED END

Return cHtml   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFunction  ณPWSX011   บAutor  ณMarcelo Faria		    บ Data ณ  09/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega acesso ao Portal Protheus apos usuario selecionar   บฑฑ
ฑฑบ          ณ a matricula escolhida.                                      บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSX011()
Local cHtml := ""
Local nPos  := 0

WEB EXTENDED INIT cHtml

	nPos := Val(HttpPost->SelMat)
	
	HTTPSession->USR_INFO		:= HTTPSession->USR_RH
		
	If nPos > 0 
		HTTPSession->RHMat		:= HttpSession->aMats[nPos]:cRegistration
		HTTPSession->RHSit 		:= HttpSession->aMats[nPos]:cSituacao
		HTTPSession->RHFilMat 	:= HttpSession->aMats[nPos]:cEmployeeFilial
	EndIf	
	
	cHtml 			 					+= SelModulos()
WEB EXTENDED END

Return cHtml


/*/{Protheus.doc} InSite
Funcao de verIficacao da session de login.
@type function
@author Luiz Felipe Couto
@since 12/09/05
@version 1.0
@obs 	Cuidado com qualquer instru็ใo inserida nessa fun็ใo, pois sใo chamadas repetidas inumeras vezes,
		No portal chega a chamar 1500 vezes por exemplo, isso pode onerar a aplica็ใo de maneira consideravel
/*/
Function InSite()
Local oObj				:= Nil
Local oOrg 				:= Nil 
Local oParam			:= Nil
Local cPortal			:= ""
Local nI 				:= 1
Local nJ 				:= 1
Local bPerm 			:= .F.
Local sRotAtual 		:= ""
Local cIdiom			:= FWRetIdiom()        //Retorna Idioma Atual

Private cMsg 			:= ""
Private cMsgLog			:= ""
Private cUnifLogin		:= ""
Private lControlMat		:= .F.
Private aRetMat			:= {}
Private cMsgGen 		:= STR0001 //"Portal Protheus"
Private cMsgRH 			:= STR0007 //"Portal Gestใo do Capital Humano"
Private cMsgTMS  		:= STR0033 //"TMS - Gestใo de Transportes"

Public cPaisLoc 		
Public lLanguageFile


Default cPaisLoc 		:= "BRA"
Default lLanguageFile	:= .F.

If cIdiom == 'en' 
	SET DATE AMERICAN
EndIf

if !lLanguageFile .AND. HttpSession->cTipoPortal <> "4"
	lLanguageFile := CriaJsLang()
EndIf
 
If ExistBlock( "PWSG001" )
	cMsg := ExecBlock( "PWSG001", .F., .F.)
Endif          

If HttpSession->cTipoPortal <> "4"
	HttpSession->lR5     := ( GetRpoRelease() >= "R5" )
	HttpSession->nVersao := Val( GetVersao(.F.) )		
EndIf

//Identifica se foi chamada de Site ou Portal					  		
//1 = Site 2 = Portal											  		
//Configuracao na sessao host do INI incluir chave TPACESSO
if valType(HttpSession->cLoginPLS) == 'U'	  		
	HttpSession->cLoginPLS	:= Left(GETPVPROFSTRING(GetEnvHost(),"TPACESSO","0",GetADV97()),1)
endIf

//carrega parametros do modulo PLS somente uma vez quando acessar o login do portal
if findFunction("setLoadPar") .and. valType(HttpSession->lUnimeds) == 'U' .and. (HttpPost->cTipoPortal == "4" .Or. valType(HttpPost->cTipoPortal) == "U")
	setLoadPar(oObj)
endIf

//ณCarrega o lista de matriculas ativas para o usuario				
If ValType(HttpSession->aMats) == 'U'
	HttpSession->aMats := {}
EndIf		

oParam := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
WsChgURL(@oParam,"CFGDICTIONARY.APW")                                
		
//ณ Tamanho do campo de login
If ValType(HttpSession->nTAI3Login) == 'U'
	If oParam:GETSX3FIELDSIZE('AI3_LOGIN')
		HttpSession->nTAI3Login := AllToChar( oParam:nGETSX3FIELDSIZERESULT )
	EndIf	
EndIf	                                                  

setEstilo( { "#FFFFFF", "TituloMenor", "TituloMenorBold", "texto", "combo", "comboselect" } )

If Empty( HttpSession->USR_INFO )
	
	If !ProcName( 2 ) $ "W_PWSX010"
	
		oObj	:= Nil
		oOrg	:= Nil 
		oParam	:= Nil	
	
		Return RedirPage( "W_PWSX010.APW", "top" )

	ElseIf Empty( HttpPost->cLogin )
	
		if ( valType(HttpSession->cAcessoPP) == "U" )
	
			//ณConsulta parametro para verIfica se acesso ao portal  	   	
			//ณgestao do capital humano sera por e-mail ou cpf. 		  	
			//ณse retorno, 1 = acesso por e-mail; senao, acesso pelo CPF	
			If oParam:GETPARAM( "MSALPHA", "MV_ACESSPP" )
				HttpSession->cAcessoPP := oParam:cGETPARAMRESULT        
				If HttpSession->cAcessoPP == "1"
					cMsgRH := STR0007 //"Portal Gestใo do Capital Humano" 
				Else
					HttpSession->cAcessoPP := ""					
				Endif
			Else                      
				HttpSession->cAcessoPP := ""
			Endif
			
		endif
		
		oObj	:= Nil
		oOrg	:= Nil 
		oParam	:= Nil		

		Return ExecInPage( "PWSX000" ) + "</html>"
	Else
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSUSERPORTAL"), WSUSERPORTAL():New())
		WsChgUrl( @oObj, "USERPORTAL.apw" )

		If !Empty( HttpPost->cTipoPortal )
			HttpSession->cTipoPortal := HttpPost->cTipoPortal
		Endif

		//ณPORTAL RH
		If HttpSession->cTipoPortal == "2"
		   HttpGet->cLoginRH := "1"
		Endif
		
		cPortal	:=	IIf(HttpSession->cTipoPortal=="3" .Or. HttpSession->cTipoPortal=="5","1",HttpSession->cTipoPortal)
		HttpPost->cLogin := StrTran(HttpPost->cLogin,'"','')
		HttpPost->cLogin := StrTran(HttpPost->cLogin,"'","")

		If oObj:PRTLOGIN( HttpPost->cLogin, HttpPost->cPassword, cPortal, HttpSession->cAcessoPP, HTTPHEADIN->REMOTE_ADDR )
			
			HTTPSession->Login 		:= HttpPost->cLogin
			HttpSession->USR_INFO	:= { oObj:oWSPRTLOGINRESULT }
			HTTPSession->RHSit		:= " "
			
			If HttpSession->cTipoPortal == "2"

				//ณverifica se o usuario possui mais de 1 matricula ativa
				oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
				WsChgURL(@oOrg, "ORGSTRUCTURE.APW")
				                
				oOrg:cParticipantID  := HttpPost->cLogin 
				oOrg:GetEmployee()
				
				If len(oOrg:oWSGetEmployeeResult:oWSLISTOFEMPLOYEE:oWSDataEmployee) > 0
					HTTPSession->RHSit		:= "D"
					HTTPSession->aMats		:= oOrg:oWSGetEmployeeResult:oWSLISTOFEMPLOYEE:oWSDataEmployee
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
					//ณvariavel de sessao RHMat tambem utilizada para identificar quando
					//ณo usuario possuir mais de 1 matricula ativa	
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
					HTTPSession->RHMat 		:= HttpSession->aMats[1]:cRegistration
					HTTPSession->RHFilMat	:= HttpSession->aMats[1]:cEmployeeFilial
			        HTTPSession->RHSit		:= HttpSession->aMats[1]:cSituacao					
					If Len(oOrg:oWSGetEmployeeResult:oWSLISTOFEMPLOYEE:oWSDataEmployee) > 1
						lControlMat	:= .T.
					EndIf	
				EndIf
							
				If !(lControlMat)
					SelModulos()
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
					//ณPonto de entrada criado inicialmente pela necessidade de capturar 
					//ณinformacoes do usuแrio que realizou o login no portal para gravar
					//ณno ERP. (sem parametros e sem retorno)
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
					If ExistBlock("PORTLOGIN")
						ExecBlock("PORTLOGIN",.F.,.F.)
					EndIf
		
					Return "</html>"
				Else
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
					//ณUsuario possui mais de 1 matricula ativa, retorna para selecao
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
					HttpSession->USR_RH		:= { oObj:oWSPRTLOGINRESULT }
					HttpSession->USR_INFO	:= Nil
					Return ExecInPage( "PWSX000" ) + "</html>"
				EndIf
			Else
				HTTPSession->RHMat	:= ""
				SelModulos()
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
				//ณPonto de entrada criado inicialmente pela necessidade de capturar 
				//ณinformacoes do usuแrio que realizou o login no portal para gravar
				//ณno ERP. (sem parametros e sem retorno)
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
				If ExistBlock("PORTLOGIN")
					ExecBlock("PORTLOGIN",.F.,.F.)
				EndIf
				
				oObj	:= Nil
				oOrg	:= Nil 
				oParam	:= Nil				
	
				Return "</html>"
			EndIf		
		Else		
		       		
			cMsg 	:= PWSGetWSError( STR0002 ) //"Erro Interno<br><br>Login nใo disponํvel."
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
			//ณAvalia Retorno login unificado portal RH
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ			
			If Substr(cMsg,1,8) == "*Ret001*"
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
				//ณUsuario ainda nao possui novo login unificado(RD0_Login)!
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ			
				HTTPSession->Login := HttpPost->cLogin	
				cUnifLogin := "01"
			ElseIf Substr(cMsg,1,8) == "*Ret002*"
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
				//ณUsuario ja possui login unificado(RD0_Login), mas tentou usar acesso antigo
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ			
				HTTPSession->Login 	:= HttpPost->cLogin			
				cUnifLogin 			:= "02"
			ElseIf AT("INTERNAL SERVER ERROR",cMsg) > 0
				cMsg := "<b>" + "Erro interno, por favor contate o administrador." + "</b>"
			Else
				cMsg := "<b>" + cMsg + "</b>"
			EndIf						
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
			//ณPonto de entrada executado quando login eh invalido.
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ			
			If ExistBlock("PORTLOG2")
				ExecBlock("PORTLOG2",.F.,.F.,{HttpPost->cLogin,HttpPost->cPassword,cMsg,oObj:_Url})
			EndIf	

			oObj	:= Nil
			oOrg	:= Nil 
			oParam	:= Nil
			                         			
			Return ExecInPage( "PWSX000" ) + "</html>" 
		Endif
	Endif
// Verifica se o usuแrio nใo possui permissใo para acessar suas solicita็๕es.
ELSE
	// Se os menus foram carregados
	IF !EMPTY(HttpSession->_aMENU)
		sRotAtual := UPPER((httpHeadIn->MAIN) + ".APW")
		
		// Valida็ใo apenas para portal RH
		IF HttpSession->cTipoPortal == "2"
			
			// Controla chamadas ao Web Service
			IF EMPTY(HttpSession->_aAI8)
				HttpSession->_aAI8 := {}
				callWSSM()
			ENDIF
			
			// Verifica menu Pai
			IF AScan( HttpSession->_aAI8, { |x| x:CSROTINAS == sRotAtual } ) != 0
			
				// Percorre o Array de Rotinas Permitidas ao login, pesquisando pela rotina atual.
				For nI := 1 To LEN(HttpSession->_aMENU)
					
					// Verifica se deve descer mais 1 nivel
					IF VALTYPE(HttpSession->_aMENU[nI][1]) == "O" .AND. AllTrim(HttpSession->_aMENU[nI][1]:CPROCEDURECALL) == sRotAtual
						bPerm := .T.
						EXIT
					ENDIF
			
					IF VALTYPE(HttpSession->_aMENU[nI][2]) == "A" .AND. AScan(HttpSession->_aMENU[nI][2],{|x| AllTrim(x:CPROCEDURECALL) == sRotAtual}) != 0
						bPerm := .T.
						EXIT
					ENDIF
				Next
				
				// Redireciona para pแgina Inicial se login nใo possuir acesso เ rotina
				IF !bPerm
					Return RedirPage( "W_PWSX010.APW", "top" )
				ENDIF
			ENDIF
		ENDIF
	ENDIF
ENDIF

oObj	:= Nil
oOrg	:= Nil 
oParam	:= Nil

Return ""


// Chamada do Web Service que traz os menus pais do portal
Static Function callWSSM()
	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSWSSEARCHMENU"), WSWSSEARCHMENU():New())
	WsChgUrl(@oObj,"WSSEARCHMENU.apw")
	
	IF oObj:SEARCHMENU(HTTPSession->RHFilMat, HttpSession->lGSP)
		HttpSession->_aAI8 := oObj:oWSSEARCHMENURESULT:OWSAROTINAS:OWSCAI8
	ENDIF
RETURN NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSXLogoutบAutor  ณLuiz Felipe Couto    บ Data ณ  17/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Logout do Portal.                                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PWSXLogout( cMensagem )

Local cHtml := ""
Local oObj := Nil

Private cMsg := ""
Private cMsgGen := ""

If !Empty(cMensagem)
	cMsgGen := "<b>"+cMensagem+"</b>"
Else
	cMsgGen := STR0001 //"Portal Protheus"
Endif

WEB EXTENDED INIT cHtml START IIF(Empty(cMensagem),"InSite","")

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSUSERPORTAL"), WSUSERPORTAL():New())
WsChgUrl(@oObj,"USERPORTAL.apw")

If !oObj:PRTLOGOUT( GetUsrCode() )
	cMsg := PWSGetWSError()
Endif

// Efetua o Logoff, mesmo que o WebService tenha retornado erro. 
HttpFreeSession()

If Empty(cMensagem)
	cHtml += RedirPage( "W_PWSX010.APW", "top" )
Else
	cHtml += ExecInPage("PWSX000") + "</html>"
Endif

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetModulosบAutor  ณLuiz Felipe Couto    บ Data ณ  17/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que retorna os modulos para o usuario logado no      บฑฑ
ฑฑบ          ณ Portal.                                                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetModulos()

Local oObj 	:= NIL
Local nI 	:= 0

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSUSERPORTAL"), WSUSERPORTAL():New())
WsChgUrl( @oObj, "USERPORTAL.APW" )

If Empty( HttpSession->PRT_MODULOS )
	HttpSession->PRT_MODULOS := {}

	If oObj:PRTLISTPORTALS()
		For nI := 1 To nTam
			AAdd( HttpSession->PRT_MODULOS, oObj:oWSPRTLISTPORTALSRESULT )
		Next
	Else
		conout( PWSGetWSError() )
	Endif
Endif

Return HttpSession->PRT_MODULOS

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSelModulosบAutor  ณLuiz Felipe Couto    บ Data ณ  17/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que mostra os modulos que o usuario logado no Portal บฑฑ
ฑฑบ          ณ tem acesso.                                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SelModulos()
Local cAph 			:= ""		//APH a ser carregado
Local nTot 			:= 0		//Total de portais a exibir
Local cAcessoPortal := "0"		//Portal a carregar automaticamente (default 0=todos)
Local oObj          := NIL	    //Portal - TMS 1บ Login
Local nI 			:= 0
Local aAtalhos 		:= {}
Local cIdiom		:= FWRetIdiom()        //Retorna Idioma Atual

HttpSession->USR_ACESS_PRT 	:= { "", "", "", "", "" }
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Chamada do XXX															 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If HttpSession->cTipoPortal == "2"
	Return W_PWSA000()
Endif

//Chamada do PLS															 
If HttpSession->cTipoPortal == "4"

	//carrega parametros do modulo PLS
	if findFunction("setLoadPar") .and. valType(HttpSession->lUnimeds) == 'U'
		setLoadPar(oObj)
	endIf

	HttpSession->USR_SKIN 	:= "imagens-pls"
		
	aAtalhos := HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFACS:OWSSATALHOS

	If ValType(HttpSession->ATAVIEW) != "A"	
	    HttpSession->ATAVIEW := {}
		For nI := 1 to Len(aAtalhos)	
		   	AADD(HttpSession->ATAVIEW, {aAtalhos[nI]:cCodMnu, aAtalhos[nI]:cDescri, aAtalhos[nI]:cImagem, aAtalhos[nI]:cWebSrv, aAtalhos[nI]:cRotina })
	   Next nI
    EndIf
	
	Do Case
		Case HttpSession->USR_INFO[1]:OWSUSERLOGPLS:nTpPortal == 1
		
			HttpSession->MPortal	:= "000008"
			HttpSession->RDAVIEW	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFRDA:OWSRDAVIEW //Prestador
			
		Case HttpSession->USR_INFO[1]:OWSUSERLOGPLS:nTpPortal == 2 .Or. HttpSession->USR_INFO[1]:OWSUSERLOGPLS:nTpPortal == 3
		
			HttpSession->MPortal	:= "000010"
			HttpSession->OPEVIEW	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:oWSLISTOFOPE:oWSSOPERADORA //Empresa/Familia
			
	EndCase
			
	Return W_PPLSW00()
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Chamada do TMS															 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If HttpSession->cTipoPortal == "5" 

	oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSTMSCFGUSER' ), WSTMSCFGUSER():New() )
	WsChgUrl(@oObj,"TMSCFGUSER.APW")
	
	oObj:GETFIRSTLOG(GetUsrCode()) 
	
	If oObj:lGETFIRSTLOGRESULT                      
		cAph := "PWSTMS14"
		Return ExecInPage( cAph )
	Else
		cAph := "PWSTMS10"
		SetPrtInf( "000009", GetUsrCode() )
		Return ExecInPage( cAph )
	Endif
	
Endif
                        
If HttpSession->cTipoPortal == "3"
	
	cAph := "PWSP010"
	SetPrtInf( "000005", GetUsrCode() )
	nTot++
	
Else

	If Len( GetUserCli( "000001" ) ) > 1
		cAph := "PWSC010"
		SetPrtInf( "000001", GetUsrCode() )
		nTot++
		HttpSession->USR_ACESS_PRT[nTot] := "logo_mod-cliente.gif"
	Endif
	
	If Len( GetUserFor( "000002" ) ) > 1
	
		SetPrtInf( "000002", GetUsrCode() )
		cAph := "PWSF010"
		nTot++      
	 		
		If cIdiom == 'es' 
			HttpSession->USR_ACESS_PRT[nTot] := "logo_mod-proveedor.png"
		Else 
			HttpSession->USR_ACESS_PRT[nTot] := "logo_mod-fornecedor.gif"
		Endif
		
	Endif 
	
	If Len( GetUserVen( "000003" ) ) > 1
		SetPrtInf( "000003", GetUsrCode() )
		cAph := "PWSV010"
		nTot++
		HttpSession->USR_ACESS_PRT[nTot] := "logo_mod-vendedor.gif"
	Endif
	
	If Len( GetUserTec( "000004" ) ) > 1
		SetPrtInf( "000004", GetUsrCode() )
		cAph := "PWST010"
		nTot++
		HttpSession->USR_ACESS_PRT[nTot] := "logo_mod-tecnico.gif" //Substituir pelo logo do m๓dulo T้cnico
	Endif
	
	If Len( GetUserQdo( "000006" ) ) > 1
		SetPrtInf( "000006", GetUsrCode() )
		cAph := "PWSQ010"
		nTot++
		HttpSession->USR_ACESS_PRT[nTot] := "logo_mod-documentos.png"
	Endif
	     
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Ponto de Entrada p/ permitir configurar qual Portal ณ
	//ณ Protheus acessar automaticamente                    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ExistBlock("PORTACESS")
		cAcessoPortal := ExecBlock("PORTACESS", .F., .F.)
		If ValType(cAcessoPortal) <> "C"
			cAcessoPortal := "0"		//Todos
		EndIf
	EndIf
	
	If nTot > 0
		If cAcessoPortal == "1"			//Cliente
			cAph := "PWSC010"	
			nTot := 1
		ElseIf cAcessoPortal == "2"		//Fornecedor
			cAph := "PWSF010"
			nTot := 1	
		ElseIf cAcessoPortal == "3"		//Vendedor
			cAph := "PWSV010"
			nTot := 1
		ElseIf cAcessoPortal == "4"		//Tecnico
			cAph := "PWST010"
			nTot := 1
		EndIf      
	EndIf
	
	If nTot > 1
		cAph := "PWSX001"
	ElseIf nTot == 0
		Return( PWSXLogout( STR0004 ) ) //"Usuแrio registrado, mas sem acesso a um portal"
		Endif
	
Endif
	
Return ExecInPage( cAph )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSetPrtInfoบAutor  ณLuiz Felipe Couto    บ Data ณ  17/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que seta o skin do Portal para o usuario logado.     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1: Codigo do Portal                                     บฑฑ
ฑฑบ          ณ ExpC2: Codigo do Usuario                                    บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SetPrtInf( cPrtCode, cUsrCode )
	
	HttpSession->PRT_CODE := cPrtCode
	HttpSession->USR_SKIN := "images"
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetUserCliบAutor  ณLuiz Felipe Couto    บ Data ณ  17/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que devolve os clientes para o usuario logado no     บฑฑ
ฑฑบ          ณ Portal.                                                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1: Codigo do Portal                                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetUserCli( cPortal )

If !Empty( cPortal )
	HttpSession->PRT_CODE := cPortal
Endif

MntUserPrt()

Return HttpSession->USR_CLI

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetUserForบAutor  ณLuiz Felipe Couto    บ Data ณ  17/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que devolve os fornecedores para o usuario logado no บฑฑ
ฑฑบ          ณ Portal.                                                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1: Codigo do Portal                                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetUserFor( cPortal )	

If !Empty( cPortal )
	HttpSession->PRT_CODE := cPortal
Endif

MntUserPrt()

Return HttpSession->USR_FOR

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetUserVenบAutor  ณLuiz Felipe Couto    บ Data ณ  17/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que devolve os vendedores para o usuario logado no   บฑฑ
ฑฑบ          ณ Portal.                                                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1: Codigo do Portal                                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetUserVen( cPortal )

If !Empty( cPortal )
	HttpSession->PRT_CODE := cPortal
Endif

MntUserPrt()

Return HttpSession->USR_VEN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetUserTecบAutor  ณLuiz Felipe Couto    บ Data ณ  17/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que devolve os tecnicos para o usuario logado no     บฑฑ
ฑฑบ          ณ Portal.                                                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1: Codigo do Portal                                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetUserTec( cPortal )

If !Empty( cPortal )
	HttpSession->PRT_CODE := cPortal
Endif

MntUserPrt()

Return HttpSession->USR_TEC

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetUserTecบAutor  ณLuiz Felipe Couto    บ Data ณ  17/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que devolve os tecnicos para o usuario logado no     บฑฑ
ฑฑบ          ณ Portal.                                                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1: Codigo do Portal                                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetUserQdo( cPortal )

If !Empty( cPortal )
	HttpSession->PRT_CODE := cPortal
Endif

MntUserPrt()

Return HttpSession->USR_QDO

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMntUserGrpบAutor  ณLuiz Felipe Couto    บ Data ณ  17/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para voltar os Grupos de Usuarios. Esse retorno fica บฑฑ
ฑฑบ          ณ em Session.                                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MntUserGrp()

Local oObj := NIL

If Empty( HttpSession->USR_GRP )
	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSUSERPORTAL"), WSUSERPORTAL():New())
	
	WsChgUrl( @oObj, "USERPORTAL.APW" )
	
	If oObj:PRTGETGROUP( GetUsrCode() )
		HttpSession->USR_GRP := { oObj:oWSPRTGETGROUPRESULT }
	Else
		conout( "--------------------------------------------" )
		conout( PWSGetWSError() )
		conout( "--------------------------------------------" )
	Endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMntUserPrtบAutor  ณLuiz Felipe Couto    บ Data ณ  17/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que monta as session para clientes, fornecedores,    บฑฑ
ฑฑบ          ณ vendedores e direitos                                       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Analista     ณ Data    ณ BOPS ณ  Motivo da Alteracao                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Tatiane M.   ณ 15/06/07ณ118960ณ -Comentado a valida็ใo da variavel de  ณฑฑ
ฑฑณ              ณ         ณ      ณsessใo USR_QDO, pois o Portal de Docu-  ณฑฑ
ฑฑณ              ณ         ณ      ณmentos ainda nใo foi implementado       ณฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MntUserPrt()

Local nZ		:= 0
Local nI		:= 0
Local nJ		:= 0
Local nPos 		:= 0
Local aRet  	:= {}
Local aTemp 	:= {}
Local aTemp1	:= {}
Local nTam  	:= 0
Local aMenu 	:= {}

//*************************************************************************
//HttpSession->USR_QDO comentado pois ainda nใo existe o portal Documentos.
//Serแ implementado posteriormente.
//*************************************************************************
If !Empty( HttpSession->USR_CLI ) .And. !Empty( HttpSession->USR_FOR ) .And. !Empty( HttpSession->USR_DIR ) .And. !Empty( HttpSession->USR_VEN ) .And. !Empty( HttpSession->USR_TEC ) //.And. !Empty( HttpSession->USR_QDO )
	GetPrtMenu()
	Return
Endif

HttpSession->USR_CLI := {}
HttpSession->USR_FOR := {}
HttpSession->USR_VEN := {}
HttpSession->USR_DIR := {}
HttpSession->USR_TEC := {}
HttpSession->USR_QDO := {}

aTemp 	:= HttpSession->USR_INFO[1]:oWSUSERENTIRIESHEADER:cSTRING
nTam 	:= Len( aTemp )

For nI := 1 To nTam
	AAdd( aTemp1, aTemp[nI] )
Next

AAdd( aRet, aTemp1 )

aTemp 	:= HttpSession->USR_INFO[1]:oWSUSERENTIRIES:oWSLOGINENTIRYSTRUCT
nTam 	:= Len( aTemp )

For nI := 1 To nTam
	If aTemp[nI]:cENTIRY == "SA1"
		AAdd( aRet, { aTemp[nI]:cENTIRY, aTemp[nI]:cID_ENTIRY, aTemp[nI]:cNICKNAME, aTemp[nI]:cNAME, aTemp[nI]:cFEDERALID, IIF( Empty( aTemp[nI]:cSKIN ), "images", AllTrim( aTemp[nI]:cSKIN ) ) } )
	ElseIf aTemp[nI]:cENTIRY == "SA2"
		AAdd( aRet, { aTemp[nI]:cENTIRY, aTemp[nI]:cID_ENTIRY, aTemp[nI]:cNICKNAME, aTemp[nI]:cNAME, aTemp[nI]:cFEDERALID, IIF( Empty( aTemp[nI]:cSKIN), "images", AllTrim( aTemp[nI]:cSKIN ) ) } )
	ElseIf aTemp[nI]:cENTIRY == "SA3"
		AAdd( aRet, { aTemp[nI]:cENTIRY, aTemp[nI]:cID_ENTIRY, aTemp[nI]:cNICKNAME, aTemp[nI]:cNAME, aTemp[nI]:cFEDERALID, IIF( Empty( aTemp[nI]:cSKIN ), "images", AllTrim( aTemp[nI]:cSKIN ) ) } )
	ElseIf aTemp[nI]:cENTIRY == "AA1"
		AAdd( aRet, { aTemp[nI]:cENTIRY, aTemp[nI]:cID_ENTIRY, aTemp[nI]:cNICKNAME, aTemp[nI]:cNAME, aTemp[nI]:cFEDERALID, IIF( Empty( aTemp[nI]:cSKIN ), "images", AllTrim( aTemp[nI]:cSKIN ) ) } ) //substituir pelo logo do m๓dulo T้cnico
	ElseIf aTemp[nI]:cENTIRY == "QAA"
		AAdd( aRet, { aTemp[nI]:cENTIRY, aTemp[nI]:cID_ENTIRY, aTemp[nI]:cNICKNAME, aTemp[nI]:cNAME, aTemp[nI]:cFEDERALID, IIF( Empty( aTemp[nI]:cSKIN ), "images", AllTrim( aTemp[nI]:cSKIN ) ) } ) 
	Else
		AAdd( aRet, { aTemp[nI]:cENTIRY, aTemp[nI]:cID_ENTIRY, aTemp[nI]:cNICKNAME, aTemp[nI]:cNAME, aTemp[nI]:cFEDERALID, "" } )
	Endif
Next

AAdd( HttpSession->USR_CLI, aRet[1] )
AAdd( HttpSession->USR_FOR, aRet[1] )
AAdd( HttpSession->USR_VEN, aRet[1] )
AAdd( HttpSession->USR_TEC, aRet[1] )
AAdd( HttpSession->USR_QDO, aRet[1] )


nTam := Len( aRet )

If nTam <= 1
	Return
Endif

For nI := 2 To nTam
	If Upper( AllTrim( aRet[nI][1] ) ) == "SA1"
		AAdd( HttpSession->USR_CLI, aRet[nI] )
	ElseIf Upper( AllTrim( aRet[nI][1] ) ) == "SA2"
		AAdd( HttpSession->USR_FOR, aRet[nI] )
	ElseIf Upper( AllTrim( aRet[nI][1] ) ) == "SA3"
		AAdd( HttpSession->USR_VEN, aRet[nI] )
	ElseIf Upper( AllTrim( aRet[nI][1] ) ) == "AA1"
		AAdd( HttpSession->USR_TEC, aRet[nI] )	
	ElseIf Upper( AllTrim( aRet[nI][1] ) ) == "QAA"
		AAdd( HttpSession->USR_QDO, aRet[nI] )			
	Endif                                          
Next

If Len( HttpSession->USR_CLI ) == 1
	HttpSession->USR_CLI := {}
Endif

If Len( HttpSession->USR_FOR ) == 1
	HttpSession->USR_FOR := {}
Endif

If Len( HttpSession->USR_VEN ) == 1
	HttpSession->USR_VEN := {}
Endif

If Len( HttpSession->USR_TEC ) == 1
	HttpSession->USR_TEC := {}
Endif

If Len( HttpSession->USR_QDO ) == 1
	HttpSession->USR_QDO := {}
Endif
                                 
If Empty( HttpSession->_MENU_HEADER )
	GetPrtMenu()
Endif

aTemp  	:= HttpSession->USR_INFO[1]:oWSUSERACCESSESHEADER:cSTRING
aTemp1 	:= {}
aRet   	:= {}

AAdd( aTemp1, HttpSession->_MENU_HEADER[2]:cHEADERTITLE )

nTam := Len( aTemp )

For nI := 1 To nTam
	AAdd( aTemp1, aTemp[nI] )
Next

AAdd( aRet, aTemp1 )

aTemp 	:= HttpSession->USR_INFO[1]:oWSUSERACCESSES:oWSLOGINACCESSESSTRUCT
nTam 	:= Len( aTemp )

If !Empty( HttpSession->_aMENU )
	For nI := 1 To Len( HttpSession->_aMENU )
		For nJ := 2 To Len( HttpSession->_aMENU[nI] )
			For nZ := 1 To Len( HttpSession->_aMENU[nI][nJ] )
				AAdd( aMenu, { HttpSession->_aMENU[nI][nJ][nZ]:cWEBSERVICE, HttpSession->_aMENU[nI][nJ][nZ]:cDESCRIPTION } )
			Next nZ
		Next nJ
	Next nI
	
	For nI := 2 To nTam
		nPos := AScan( aMenu, { |x| AllTrim( x[1] ) == AllTrim( aTemp[nI]:cWEBSRV ) } )
		AAdd( aRet, { IIF( nPos > 0, aMenu[nPos][2], STR0005 ), aTemp[nI]:cWEBSRV, aTemp[nI]:cNAME } ) //"Gen้rico"
	Next
Endif

AAdd( HttpSession->USR_DIR, aRet[1] )

nTam := Len( aRet )

If nTam <= 1
	Return
Endif

For nI := 2 To nTam
	AAdd( HttpSession->USR_DIR, aRet[nI] )
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetPrtMenuบAutor  ณLuiz Felipe Couto    บ Data ณ  17/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que retorna o menu do Portal.                        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1: Codigo do Portal                                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetPrtMenu( cPrtCode )
Local nI 	:= 0
Local nTam 	:= 0
Local nPos 	:= 0
Local nPosMenu	:= 0
Local aTemp := {}
Local oTemp := NIL

If !Empty( cPrtCode )
	HttpSession->PRT_CODE := cPrtCode
Endif

HttpSession->_aMENU 	:= {}
oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSUSERPORTAL"), WSUSERPORTAL():New())

WsChgUrl( @oObj, "USERPORTAL.apw" )

If oObj:PRTHEADER( "LOGINMENU" )
	HttpSession->_MENU_HEADER := oObj:oWSPRTHEADERRESULT:oWSBRWHEADER
Endif

If !Empty( HttpSession->PRT_CODE )
	If oObj:PRTLISTMENU( GetPrtCode(), GetUsrCode(), GetUsrLogin() )
		oTemp := oObj:oWSPRTLISTMENURESULT:oWSLOGINMENU
		
		nTam := Len( oTemp )                         

		If oTemp[1]:nOrder == 0
			aSort( oTemp,,, { |x1, x2| x1:cSUPERIORCODE + x1:cCODE < x2:cSUPERIORCODE + x2:cCODE } )
		else
			If HttpSession->cTipoPortal == "2" //Portal do RH
				// - Ordena็ใo a partir do campo AI8_ORDEM.
				aSort( oTemp,,, { |x1, x2| x1:cSUPERIORCODE + StrZero(x1:nOrder,3) < x2:cSUPERIORCODE + StrZero(x2:nOrder,3) } )
			Else
				aSort( oTemp,,, { |x1, x2| x1:cSUPERIORCODE + str(x1:nOrder) < x2:cSUPERIORCODE + str(x2:nOrder) } )
			EndIf
					
		endif
		
		For nI := 1 To nTam
			If Empty( oTemp[nI]:cSUPERIORCODE )
				If !oTemp[nI]:lMENUISBLOCKED
					oTemp[nI]:cDESCRIPTION	 := AllTrim( oTemp[nI]:cDESCRIPTION )
					oTemp[nI]:cWEBSERVICE	 := AllTrim( oTemp[nI]:cWEBSERVICE )
					
					AAdd( HttpSession->_aMENU, { oTemp[nI],{} } )
				Endif
				AAdd( aTemp, {oTemp[nI]:cCODE, oTemp[nI]:lMENUISBLOCKED})
			Else
				If ( nPos := AScan(aTemp, {|aElem| aElem[1] == oTemp[nI]:cSUPERIORCODE}) ) > 0
					If !aTemp[nPos,2] ; // verifica se o menu pai estแ bloqueado
							.and. !oTemp[nI]:lMENUISBLOCKED // verifica se o pr๓prio menu estแ bloqueado
						oTemp[nI]:cPROCEDURECALL 	:= IIF( Empty( oTemp[nI]:cPROCEDURECALL ), "#", AllTrim( oTemp[nI]:CPROCEDURECALL ) )
						oTemp[nI]:cDESCRIPTION		:= AllTrim( oTemp[nI]:cDESCRIPTION )
						oTemp[nI]:cWEBSERVICE		:= AllTrim( oTemp[nI]:cWEBSERVICE )
	
						nPosMenu := AScan(HttpSession->_aMENU, {|aElem| aElem[1]:CCODE == oTemp[nI]:cSUPERIORCODE})
						AAdd( HttpSession->_aMENU[nPosMenu][2], oTemp[nI] )
					Endif
				Else
					conout( STR0006 ) //"Erro: Retorno de WebService invalido"
					Return {}
				Endif
			Endif
		Next
	Else
		//Se der erro saio e volto um menu vazio
		ConOut( PWSGetWSError() )
		Return {}
	Endif
Endif

Return HttpSession->_aMENU

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetUserDirบAutor  ณLuiz Felipe Couto    บ Data ณ  17/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que retorna os direitos de acesso do usuario logado  บฑฑ
ฑฑบ          ณ no Portal.                                                  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1: Codigo do Portal                                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetUserDir( cPortal )

If !Empty( cPortal )
	HttpSession->PRT_CODE := cPortal
Endif

MntUserPrt()

Return HttpSession->USR_DIR

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetUserGrpบAutor  ณLuiz Felipe Couto    บ Data ณ  17/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que devolve os grupos para o cadastro de usuarios    บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ10/05/06ณ98244 ณ-Incluido tratamento no retorno da funcao p/ บฑฑ
ฑฑบ          ณ        ณ      ณevitar erro de "array out of bounds".        บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetUserGrp()
Local aRet	:= {}	//Array de retorno da funcao

MntUserGrp()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se encontrou o grupo do usuario ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(HttpSession->USR_GRP)
	aRet := aClone(HttpSession->USR_GRP[1]:oWSLOGINUSERSTRUCT)
EndIf

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIsUsrAdm  บAutor  ณLuiz Felipe Couto    บ Data ณ  17/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao quer verIfica se o usuario logado no Portal e admi-  บฑฑ
ฑฑบ          ณ nistrador.                                                  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function IsUsrAdm()
Return ( HttpSession->USR_INFO[1]:nUserRoles == 1 )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetUsrCodeบAutor  ณLuiz Felipe Couto    บ Data ณ  17/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que retorna o codigo do usuario logado no Portal.    บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetUsrCode()
Return Iif( ValType(HttpSession->USR_INFO) != 'U',HttpSession->USR_INFO[1]:cUserCode,"")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetPrtCodeบAutor  ณLuiz Felipe Couto    บ Data ณ  17/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que retorna o codigo do portal do qual o usuario     บฑฑ
ฑฑบ          ณ logado esta utilizando no momento.                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetPrtCode()
Return HttpSession->PRT_CODE

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetPrtSkinบAutor  ณLuiz Felipe Couto    บ Data ณ  17/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que retorna o skin do Portal para o usuario logado.  บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function getPrtSkin()
Return Iif( ValType(HttpSession->USR_SKIN) <> 'U',HttpSession->USR_SKIN,"" )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetUsrLogiบAutor  ณLuiz Felipe Couto    บ Data ณ  17/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que retorna o login do usuario logado no Portal.     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetUsrLogin()
Local cUserLogin := ""

if Valtype(HttpSession->USR_INFO) != "U"
	cUserLogin := HttpSession->USR_INFO[1]:cUserLogin
endif

return cUserLogin    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetUsrSenhบAutor  ณLuiz Felipe Couto    บ Data ณ  17/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que retorna a senha do usuario logado no Portal.     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetUsrSenha()
Return HttpSession->USR_INFO[1]:cUserPassword

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSetUsrSenhบAutor  ณLuiz Felipe Couto    บ Data ณ  17/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Seta a nova senha para o usuario logado no Portal.          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1: Nova Senha                                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SetUsrSenha( cNewSenha )

Local lRet := .F.	//Indica retorno da funcao

If !Empty( cNewSenha )
	HttpSession->USR_INFO[1]:cUSERPASSWORD := cNewSenha
	lRet := .T.
Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEndEnv    บAutor  ณCesar A. Bianchi    บ Data ณ  14/10/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFinaliza o Enviroment preparado atraves da funcao PrepEnvPorบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function EndEnv()
RESET ENVIRONMENT
Return
 