#INCLUDE "PWSF060.ch" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

#INCLUDE "FILEIO.CH"

#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"


#DEFINE MYUSERCODE GetUsrCode()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSF06*   บAutor  ณ Flavio Luiz Vicco   บ Data ณ  21/09/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Este fonte possui as funcionalidades relacionado ao         บฑฑ
ฑฑบ          ณ processamento de Cotacoes.                                  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบComents   ณ Aphs Envolvidos :                                           บฑฑ
ฑฑบ          ณ PWSF020.APH Sele็ใo de Fornecedores                         บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                          บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSF060   บAutor  ณ Flavio Luiz Vicco   บ Data ณ  21/09/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mostra os fornecedores disponives para o usuario logado.    บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                          บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSF060()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFornecedores cadastrados para o usuario logadoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpPost->PWSF020FOR := GetUserFor()
HttpSession->PWSF020FOR := HttpPost->PWSF020FOR

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes a serem utilizadas pelo APHณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSF020APH := { STR0001, "W_PWSF061.APW", "" } //"Processamento de Cota็๕es"

Do Case
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณNao ha fornecedores cadastrados para o usuario logado         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case Empty( HttpPost->PWSF020FOR )
		HttpSession->PWSF020APH[3] := STR0002 //"Nใo hแ Fornecedores a consultar."
		cHtml += ExecInPage( "PWSF020" )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณApenas 1 fornecedor cadastrado.                               ณ
	//ณ Define a navega็ใo para pular a tela de sele็ใo de Fornecedorณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case Len( HttpPost->PWSF020FOR ) == 2
		HttpPost->CODFORERP := HttpPost->PWSF020FOR[2][2]
		cHtml += W_PWSF061()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMais de 1 fornecedor. Chama tela de sele็ใo de Fornecedores   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Otherwise
		cHtml += ExecInPage( "PWSF020" )

EndCase

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSF061   บAutor  ณ Flavio Luiz Vicco   บ Data ณ  21/09/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela para escolha de Cotacoes.                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                          บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSF061()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

If	!Empty( HttpPost->CODFORERP )
	HttpSession->CODFORERP := HttpPost->CODFORERP
EndIf

HttpSession->PWSF065GRAVA := { }
HttpSession->PWSF061APH   := { STR0001, "W_PWSF062.APW", "W_PWSF064.APW" }//"Processamento de Cota็๕es"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicializa o WS - MTSUPPLIERQUOTE ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIERQUOTE"), WSMTSUPPLIERQUOTE():New())
WsChgURL( @oObj, "MTSUPPLIERQUOTE.APW" )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณHeader a ser utilizado pelas funcoes GridHeader e GridLinesExณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If	Empty( HttpSession->PWSF061HEADER )
	HttpSession->PWSF061HEADER := { { }, { } }

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Header do Cabecalho da Cotacao:   ณ
	//ณ-cCONTACT            : Contato     ณ
	//ณ-nCURRENCY           : Moeda       ณ
	//ณ-nCURRENCYRATE       : Taxa Moeda  ณ
	//ณ-nDISCOUNTINCASCADE1 : Desconto1   ณ
	//ณ-nDISCOUNTINCASCADE2 : Desconto2   ณ
	//ณ-nDISCOUNTINCASCADE3 : Desconto3   ณ
	//ณ-cPAYMENTPLANCODE    : Cond.Pagto  ณ
	//ณ-cPROPOSALID         : Proposta    ณ
	//ณ-oWSPURCHASERES      : Compradores ณ
	//ณ-cQUOTEID            : Num. Cotacaoณ
	//ณ-cQUOTESTATUS        : Status      ณ
	//ณ-dREGISTERDATE       : Dt.Emissao  ณ
	//ณ-cSUPPLIER           : Fornecedor  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oObj:cHEADERTYPE := "QUOTEHEADERVIEW"

	If	oObj:GETHEADER()
		HttpSession->PWSF061HEADER[1] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0007, "", "W_PWSF060.APW" ) //"Erro"
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Header dos Itens da Cotacao:        ณ
	//ณ-dDELIVERYDATE       : Dt. Entrega   ณ
	//ณ-nDELIVERYTERMINDAYS : Dias Entrega  ณ
	//ณ-cDESCRIPTIONPRODUCT : Descricao     ณ
	//ณ-nDISCOUNTPERCENT    : % Desc. Item  ณ
	//ณ-nDISCOUNTVALUE      : Vlr. Desconto ณ
	//ณ-nEXPENSESVALUE      : Vlr. Despesas ณ
	//ณ-dEXPIRYDATE         : Dt. Validade  ณ
	//ณ-nFREIGHTVALUE       : Vlr. Frete    ณ
	//ณ-nINSURANCEVALUE     : Vlr. Seguro   ณ
	//ณ-cMEASUREUNIT        : U.M.          ณ
	//ณ-cNOTES              : Obsevacoes    ณ
	//ณ-cPAYMENTPLANCODE    : Cond. Pagto   ณ
	//ณ-cPRODUCTCODE        : Cod. Produto  ณ
	//ณ-cPROPOSALID         : Proposta      ณ
	//ณ-nQUANTITY           : Quantidade    ณ
	//ณ-cSEQUENTIALID       : Item          ณ
	//ณ-oWSTAXES            : Impostos      ณ
	//ณ-nTOTALVALUE         : Vlr. Total    ณ
	//ณ-nUNITPRICE          : Preco Unit.   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oObj:cHEADERTYPE := "QUOTEITEMVIEW"
	If	oObj:GETHEADER()
		HttpSession->PWSF061HEADER[2] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0007, "", "W_PWSF060.APW" ) //"Erro"
	EndIf
EndIf

cHtml += ExecInPage( "PWSF061" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSF062   บAutor  ณ Flavio Luiz Vicco   บ Data ณ  21/09/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela para escolha de cotacoes.                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                          บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSF062()

Local cAddWhere
Local cNpedVazio:="  "
Local cHtml    := ""
Local aWebCols := {}
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicializa o WS - MTSUPPLIERQUOTE ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIERQUOTE"), WSMTSUPPLIERQUOTE():New())
WsChgURL( @oObj, "MTSUPPLIERQUOTE.APW" )

HttpSession->PWSF062APH := { STR0001+" - "+STR0008, "W_PWSF063.APW", "W_PWSF061.APW" } //"Resultado Busca"

//dEXPIRYDATEFROM,dEXPIRYDATETO

If	( !Empty( HttpGet->dEXPIRYDATEFROM ) .AND. !Empty( HttpGet->dEXPIRYDATETO ) )
	HttpPost->dEXPIRYDATEFROM := HttpGet->dEXPIRYDATEFROM
	HttpPost->dEXPIRYDATETO	  := HttpGet->dEXPIRYDATETO
EndIf

oObj:cUSERCODE := MYUSERCODE
oObj:cSUPPLIER := HttpSession->CODFORERP
oObj:dEXPIRYDATEFROM	  := Ctod( HttpPost->dEXPIRYDATEFROM )
oObj:dEXPIRYDATETO		  := Ctod( HttpPost->dEXPIRYDATETO )

If	!Empty( HttpGet->cCOMBOSIT )
	HttpPost->cCOMBOSIT := HttpGet->cCOMBOSIT
EndIf

cAddWhere := ""
Do Case
Case HttpPost->cCOMBOSIT == "2"	// Aberto
	cAddWhere	:= "SC8.C8_NUMPED  = '" + cNPedVazio + "'"
Case HttpPost->cCOMBOSIT == "3"	// Fechado
	cAddWhere	:= "SC8.C8_NUMPED <> '" + cNPedVazio + "'"
EndCase

If	!Empty( HttpPost->cBuscaAv )
	Do Case
	Case HttpPost->cComboAv == "1"
		cAddWhere += If(!Empty(cAddWhere)," AND ","")+"SC8.C8_NUM='" + HttpPost->cBuscaAv + "'"
	EndCase
EndIf

oObj:cQUERYADDWHERE	:= cAddWhere

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Metodo BRWQUOTE                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//cUSERCODE,cSUPPLIER,dEXPIRYDATEFROM,dEXPIRYDATETO,cQUERYADDWHERE
If	oObj:BRWQUOTE()
	HttpSession->PWSF062RESULT := { oObj:oWSBRWQUOTERESULT:oWSQUOTEHEADERVIEW }
	HttpSession->PWSF062INFO   := { }
Else
	Return PWSHTMLALERT( "", STR0007, "", "W_PWSF060.APW" ) //"Erro"
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cabecalhos das Cotacoes   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aWebCols := {}
If	ExistBlock( "PEF062" )
	aWebCols := ExecBlock( "PEF062", .F., .F., {} )
Else
	aAdd( aWebCols, "QUOTEID" )
	aAdd( aWebCols, "SUPPLIER" )
	aAdd( aWebCols, "REGISTERDATE" )
	aAdd( aWebCols, "CONTACT" )
	aAdd( aWebCols, "PAYMENTPLANCODE" )
	aAdd( aWebCols, "CURRENCY" )
 	aAdd( aWebCols, "CURRENCYRATE" )
	aAdd( aWebCols, "QUOTESTATUS" )
EndIf
   
GridHeader(		HttpSession->PWSF062INFO, ;
				HttpSession->PWSF061HEADER[1][1], ;
				aWebCols,;
                HttpSession->PWSF062RESULT[1], "MTSUPPLIERQUOTE", "SC8" )

GridLinesEx( {	HttpSession->PWSF062INFO, ;
				HttpSession->PWSF061HEADER[1][1], ;
				HttpSession->PWSF062RESULT[1], ;
				aWebCols, .F., "A", NIL, 0 }, "MTSUPPLIERQUOTE", "SC8" )

cHtml += ExecInPage( "PWSF062" )

HttpSession->dEXPIRYDATEFROM := HttpPost->dEXPIRYDATEFROM
HttpSession->dEXPIRYDATETO   := HttpPost->dEXPIRYDATETO
HttpSession->cCOMBOSIT		 := HttpPost->cCOMBOSIT

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSF063   บAutor  ณ Flavio Luiz Vicco   บ Data ณ  21/09/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela para escolha de propostas.                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                          บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSF063()

Local cAddWhere
Local cNpedVazio:="  "
Local cHtml    := ""
Local aWebCols := {}
Local nI       := 0
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

If	!Empty( HttpPost->cCotacao )
	HttpGet->cCotacao := HttpPost->cCotacao
EndIf
If	( !Empty( HttpGet->dEXPIRYDATEFROM ) .AND. !Empty( HttpGet->dEXPIRYDATETO ) )
	HttpPost->dEXPIRYDATEFROM := HttpGet->dEXPIRYDATEFROM
	HttpPost->dEXPIRYDATETO	  := HttpGet->dEXPIRYDATETO
EndIf

If	!Empty( HttpGet->cCOMBOSIT )
	HttpPost->cCOMBOSIT := HttpGet->cCOMBOSIT
EndIf

HttpSession->PWSF063APH := { STR0005 + HttpGet->cCotacao + STR0009 , "W_PWSF064.APW" }//"Cota็ใo N๚mero : "," - Propostas"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicializa o WS - MTSUPPLIERQUOTE ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIERQUOTE"), WSMTSUPPLIERQUOTE():New())
WsChgUrl( @oObj, "MTSUPPLIERQUOTE.APW" )

oObj:cUSERCODE := MYUSERCODE
oObj:cQUOTEID  := HttpGet->cCotacao
oObj:cSUPPLIER := HttpSession->CODFORERP

cAddWhere := ""
Do Case
Case HttpPost->cCOMBOSIT == "2"	// Aberto
	cAddWhere	:= "SC8.C8_NUMPED  = '" + cNPedVazio + "'"
Case HttpPost->cCOMBOSIT == "3"	// Fechado
	cAddWhere	:= "SC8.C8_NUMPED <> '" + cNPedVazio + "'"
EndCase

If	!Empty( HttpPost->cBuscaAv )
	Do Case
	Case HttpPost->cComboAv == "1"
		cAddWhere += If(!Empty(cAddWhere)," AND ","")+"SC8.C8_NUM='" + HttpPost->cBuscaAv + "'"
	EndCase
EndIf

oObj:cQUERYADDWHERE	:= cAddWhere

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Metodo GETQUOTE                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//cUSERCODE,cQUOTEID,cSUPPLIER,cQUERYADDWHERE
If	oObj:GETQUOTE()
	HttpSession->PWSF063RESULT	:= { oObj:oWSGETQUOTERESULT:oWSQUOTEVIEW }
	HttpSession->PWSF063INFO	:= {}

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cabecalhos das Propostas  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aWebCols := { }
	If	ExistBlock( "PEF063" )
		aWebCols := ExecBlock( "PEF063", .F., .F., {} )
	Else
		aAdd( aWebCols, "QUOTEID" )
		aAdd( aWebCols, "PROPOSALID" )
		aAdd( aWebCols, "SUPPLIER" )
		aAdd( aWebCols, "REGISTERDATE" )
		aAdd( aWebCols, "CONTACT" )
		aAdd( aWebCols, "PAYMENTPLANCODE" )
		aAdd( aWebCols, "CURRENCY" )
		aAdd( aWebCols, "CURRENCYRATE" )
		aAdd( aWebCols, "QUOTESTATUS" )
	EndIf

	GridHeader( HttpSession->PWSF063INFO, ;
               HttpSession->PWSF061HEADER[1][1], ;
               aWebCols,;
               HttpSession->PWSF063RESULT[1][1]:oWSQUOTEHEADER,"MTSUPPLIERQUOTE", "SC8" )

	For nI := 1 To Len( HttpSession->PWSF063RESULT[1] )
	GridLinesEx( {	HttpSession->PWSF063INFO, ;
					HttpSession->PWSF061HEADER[1][1], ;
					HttpSession->PWSF063RESULT[1][nI]:oWSQUOTEHEADER, ;
					aWebCols, .F., "A", NIL, 0 }, "MTSUPPLIERQUOTE", "SC8" )
	Next nI
	
	//Adiciona o item da cota็ใo ao array de informa็๕es
	AADD(HttpSession->PWSF063APH,HTTPSESSION->PWSF063RESULT[1][1]:OWSQUOTEITEM:OWSQUOTEITEMVIEW[1]:CSEQUENTIALID)
	
Else
	Return PWSHTMLALERT( "", STR0007, "", "W_PWSF060.APW" ) //"Erro"
EndIf

cHtml += ExecInPage( "PWSF063" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSF064   บAutor  ณ Flavio Luiz Vicco   บ Data ณ  21/09/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela para detalhes de cotacao.                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                          บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSF064()

Local cHtml    := ""
Local aWebCols := {}
Local nPos     := 0
Local oObj
Local cEmpPF	:= HTTPSESSION->PWSF063RESULT[1][1]:OWSQUOTEITEM:OWSQUOTEITEMVIEW[1]:cCode
Local cFilPF	:= HTTPSESSION->PWSF063RESULT[1][1]:OWSQUOTEITEM:OWSQUOTEITEMVIEW[1]:cBranch

PREPARE ENVIRONMENT EMPRESA cEmpPF FILIAL cFilPF MODULO "COM" TABLES "ACB","ACB","ACC"

//Abre a empresa
//PrepEnvPor()

HttpSession->PWSF130APH := 	{ 	TamSX3("ACB_OBJETO")[1],; 	//tamanho do campo
									"",;							//motivo do retorno falso
									"",;							//nome do arquivo
									"";								//extensใo do arquivo
								}

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWSF064APH := { STR0010 + HttpGet->cProposta, "W_PWSF065.APW" }//"Proposta N๚mero : "

HttpSession->cProposta := HttpGet->cProposta

If	HttpSession->dEXPIRYDATEFROM == Nil
	HttpSession->dEXPIRYDATEFROM := HttpPost->dEXPIRYDATEFROM
EndIf

If	HttpSession->dDEXPIRYDATETO == Nil
	HttpSession->dEXPIRYDATETO   := HttpPost->dEXPIRYATETO
EndIf

If	HttpSession->cCOMBOSIT == Nil
	HttpSession->cCOMBOSIT   := HttpPost->cCOMBOSIT
EndIf

nPos := aScan( HttpSession->PWSF063RESULT[1], { |x| x:oWSQUOTEHEADER:cPROPOSALID == HttpGet->cProposta } )

If	nPos > 0
	HttpSession->PWSF064INFO := { {}, {} }

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cabecalho da Proposta     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If	ExistBlock( "PEF064" )
		aWebCols := ExecBlock( "PEF064", .F., .F., { 1 } )
	EndIf

	GridLinesEx( {	HttpSession->PWSF064INFO[1], ;
					HttpSession->PWSF061HEADER[1][1], ;
					HttpSession->PWSF063RESULT[1][nPos]:oWSQUOTEHEADER, ;
					aWebCols, .F., "H", NIL, 0 }, "MTSUPPLIERQUOTE", "SC8" )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Itens da Proposta         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If	ExistBlock( "PEF064" )
		aWebCols := ExecBlock( "PEF064", .F., .F., { 2 } )
	EndIf

	GridHeader(	HttpSession->PWSF064INFO[2], ;
				HttpSession->PWSF061HEADER[2][1], ;
				aWebCols,;
				HttpSession->PWSF063RESULT[1][nPos]:oWSQUOTEITEM:oWSQUOTEITEMVIEW, "MTSUPPLIERQUOTE", "SC8" )

	GridLinesEx( {	HttpSession->PWSF064INFO[2], ;
					HttpSession->PWSF061HEADER[2][1], ;
					HttpSession->PWSF063RESULT[1][nPos]:oWSQUOTEITEM:oWSQUOTEITEMVIEW, ;
					aWebCols, .F., "A",NIL , 0 }, "MTSUPPLIERQUOTE", "SC8" )


Else
	Return PWSHTMLALERT( "", STR0007, STR0011, "W_PWSF060.APW" ) //"Erro"//"Proposta nใo encontrada."
EndIf

cHtml += ExecInPage( "PWSF064" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSF064A  บAutor  ณ Flavio Luiz Vicco   บ Data ณ  21/09/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela para detalhes de itens da cotacao.                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                          บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSF064A()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSF064A" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSF065   บAutor  ณ Flavio Luiz Vicco   บ Data ณ  21/09/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela para inclusao e alteracao de cotacao.                  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                          บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSF065()

Local cHtml		:= ""
Local nI		:= 0
Local nPos		:= 0
Local aWebCols	:= { }
Local oObj
Local oObjItem
Local nX		:= 0

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicializa o WS - MTSUPPLIERQUOTE ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIERQUOTE"), WSMTSUPPLIERQUOTE():New())
WsChgURL( @oObj, "MTSUPPLIERQUOTE.APW" )

HttpSession->PWSF065APH := { IIf( HttpPost->cAcao == "A", STR0012, STR0013 ), "W_PWSF067.APW" }//"Altera็ใo Cota็ใo","Inclusใo Proposta"
HttpSession->PWSF065INFO := { { }, { } }

If	HttpPost->cAcao == "A" .OR. HttpPost->cAcao == "I"
	HttpSession->nTotalCot := 0

	oObj:cUSERCODE		:= MYUSERCODE
	oObj:cQUOTEID		:= HttpPost->cCotacao
	oObj:cSUPPLIER		:= HttpSession->CODFORERP
	oObj:cQUERYADDWHERE	:= "SC8.C8_NUMPED='  ' "
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Metodo GETQUOTE                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//cUSERCODE,cQUOTEID,cSUPPLIER,cQUERYADDWHERE
	If	oObj:GETQUOTE()
		HttpSession->PWSF065GRAVA := { , { } }

		If	HttpPost->cAcao == "I"
			nPos := 1
		Else
			nPos := aScan( oObj:oWSGETQUOTERESULT:oWSQUOTEVIEW, { |x| x:oWSQUOTEHEADER:cPROPOSALID == HttpPost->cProposta } )
		EndIf

		If	nPos > 0
			HttpSession->PWSF065GRAVA[1] := oObj:oWSGETQUOTERESULT:oWSQUOTEVIEW[nPos]:oWSQUOTEHEADER

			If	HttpPost->cAcao == "I"
				HttpSession->PWSF065GRAVA[1]:cPROPOSALID := StrZero( Len( HttpSession->PWSF063RESULT[1] ) + 1, 2 )
			EndIf

			For nI := 1 To Len( oObj:oWSGETQUOTERESULT:oWSQUOTEVIEW[nPos]:oWSQUOTEITEM:oWSQUOTEITEMVIEW )
				aAdd( HttpSession->PWSF065GRAVA[2], MTSUPPLIERQUOTE_ARRAYOFQUOTEITEMVIEW():New() )
				HttpSession->PWSF065GRAVA[2][nI] := oObj:oWSGETQUOTERESULT:oWSQUOTEVIEW[nPos]:oWSQUOTEITEM:oWSQUOTEITEMVIEW[nI]

				If	HttpPost->cAcao == "I"
					HttpSession->PWSF065GRAVA[2][nI]:cPROPOSALID := StrZero( Len( HttpSession->PWSF063RESULT[1] ) + 1, 2 )
				EndIf

				HttpSession->nTotalCot += HttpSession->PWSF065GRAVA[2][nI]:nTOTALVALUE
				// Soma o valor dos impostos no total da cota็ใo
				For nX := 1 To Len( HttpSession->PWSF065GRAVA[2][nI]:oWSTAXES:oWSTAXESVIEW )
					If HttpSession->PWSF065GRAVA[2][nI]:oWSTAXES:oWSTAXESVIEW[nX]:cTAXCODE $ "IPI"
						HttpSession->nTotalCot += HttpSession->PWSF065GRAVA[2][nI]:oWSTAXES:oWSTAXESVIEW[nX]:nTAXAMOUNT
					EndIf
				Next nX
				HttpSession->nTotalCot -= HttpSession->PWSF065GRAVA[2][nI]:NDISCOUNTVALUE
			Next nI
		EndIf
	Else
		Return PWSHTMLALERT( "", STR0007, "", "W_PWSF060.APW" ) //"Erro"
	EndIf

	HttpPost->cAcao := "I"
EndIf

If	HttpPost->cAcao == "I" .AND. Empty( HttpSession->cAcao )
	HttpSession->cAcao := "I"
EndIf

If	HttpSession->cAcao == "I"

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cabecalho da Proposta     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aWebCols := { }
	If	ExistBlock( "PEF065" )
		aWebCols := ExecBlock( "PEF065", .F., .F., { 1 } )
	Else
		aAdd( aWebCols, { "QUOTEID",		"D" } )
		aAdd( aWebCols, { "PROPOSALID",		"D" } )
		aAdd( aWebCols, { "SUPPLIER",		"D" } )
		aAdd( aWebCols, { "REGISTERDATE",	"D" } )
		aAdd( aWebCols,   "CONTACT"  )
		aAdd( aWebCols, { "PAYMENTPLANCODE","N", { "BRWPAYMENTPLAN", ;
													{ "CPAYMENTPLANCODE", "CPAYMENTPLANCODE" } ;
													}, ;
													{ "CPAYMENTPLANCODE", "CDESCRIPTIONPAYMENTPLAN" } } )
	EndIf

	GridLinesEx( {	HttpSession->PWSF065INFO[1], ;
					HttpSession->PWSF061HEADER[1][1], ;
					HttpSession->PWSF065GRAVA[1], ;
					aWebCols, .T., "H", NIL, 1 }, "MTSUPPLIERQUOTE", "SC8" )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Itens da Proposta         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aWebCols := { }

	If	ExistBlock( "PEF065" )
		aWebCols := ExecBlock( "PEF065", .F., .F., { 2 } )
	Else
		aAdd( aWebCols, { "PROPOSALID",			"N", 0, .F. } )
		aAdd( aWebCols, { "SEQUENTIALID",		"N", 0, .F. } )
		aAdd( aWebCols, { "PRODUCTCODE",		"N", 0, .F. } )
		aAdd( aWebCols, { "DESCRIPTIONPRODUCT",	"N", 0, .F. } )
		aAdd( aWebCols, { "MEASUREUNIT",		"N", 2, .F. } )
		aAdd( aWebCols, { "QUANTITY",			"N", 3, .F. } )
		aAdd( aWebCols, { "UNITPRICE",			"N", 9, .T. } )
		aAdd( aWebCols, { "TAXRATE",			"N", 5 } )
		aAdd( aWebCols, { "DISCOUNTPERCENT",	"N", 3 } )
		aAdd( aWebCols, { "TOTALVALUE",			"N", 0, .F. } )
	EndIf

	GridHeader( HttpSession->PWSF065INFO[2], ;
				HttpSession->PWSF061HEADER[2][1], ;
				aWebCols ,;
				HttpSession->PWSF065GRAVA[2][1], "MTSUPPLIERQUOTE", "SC8" )

	For nI := 1 To Len( HttpSession->PWSF065GRAVA[2] )
		GridLinesEx( { 	HttpSession->PWSF065INFO[2], ;
						HttpSession->PWSF061HEADER[2][1], ;
						HttpSession->PWSF065GRAVA[2][nI], ;
						aWebCols, .T., "H", AllTrim( Str( nI ) ), ;
						IIf( nI == Len( HttpSession->PWSF065GRAVA[2] ), 3, 2 ), .T. },"MTSUPPLIERQUOTE", "SC8" )
	Next nI

EndIf

cHtml += ExecInPage( "PWSF065" )

WEB EXTENDED END

Return cHtml


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSF066   บAutor  ณ Flavio Luiz Vicco   บ Data ณ  21/09/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela para inclusao e alteracao de cotacao.                  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                          บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSF066()

Local cHtml := ""
Local oObjItem

WEB EXTENDED INIT cHtml START "InSite"

If	!Empty( HttpPost->cItem )
	If	Len( HttpSession->PWSF066GRAVA[2] ) > 1
		aDel(  HttpSession->PWSF066GRAVA[2], Val( HttpPost->cItem ) )
		aSize( HttpSession->PWSF066GRAVA[2], Len( HttpSession->PWSF066GRAVA[2] ) - 1 )
	EndIf
Else
	PWSSetObjToPost( HttpSession->PWSF066GRAVA[1], HttpSession->PWSF061HEADER[1][1], HttpPost->aPost )

	nTam := Len( HttpSession->PWSF066GRAVA[2] )
	PWSSetObjToPost( HttpSession->PWSF066GRAVA[2][nTam], HttpSession->PWSF061HEADER[2][1], HttpPost->aPost, AllTrim( Str( nTam ) ) )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Inicializa o WS - MTSUPPLIERQUOTE_QUOTEITEMVIEW ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oObjItem := MTSUPPLIERQUOTE_QUOTEITEMVIEW():New()
	oObjItem:dDELIVERYDATE := Date()
	aAdd( HttpSession->PWSF066GRAVA[2], oObjItem )
EndIf

cHtml += W_PWSF066()

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSF067   บAutor  ณ Flavio Luiz Vicco   บ Data ณ  21/09/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Simulacao.                                                  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                          บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSF067()

Local cHtml		:= ""
Local nI		:= 0
Local nJ		:= 0
Local nPos		:= 0
Local nTam		:= 0
Local aProp		:= {}
Local aGrava	:= {}
Local oObj
Local oObjCfg
Local nX		:= 0

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicializa o WS - MTSIMULATIONQUOTE ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSIMULATIONQUOTE"), WSMTSIMULATIONQUOTE():New())
WsChgURL( @oObj, "MTSIMULATIONQUOTE.APW" )

oObjCfg	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
WsChgURL( @oObjCfg, "CFGDICTIONARY.APW" )

PWSSetObjToPost( HttpSession->PWSF065GRAVA[1], HttpSession->PWSF061HEADER[1][1], HttpPost->aPost )

nTam := Len( HttpSession->PWSF065GRAVA[2] )

For nI := 1 To nTam
	aProp := ClassDataArr( HttpSession->PWSF065GRAVA[2][nI] )
	nPos  := aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )

	oObjCfg:cUSERCODE	:= GetUsrCode()
	oObjCfg:cALIAS		:= "SC8"

	//cUSERCODE,cALIAS
	If	oObjCfg:GETUSERFIELD()
		aProp[nPos][2] := MTSIMULATIONQUOTE_ARRAYOFUSERFIELD():New()

		For nJ := 1 To Len( oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD )
			aAdd( aProp[nPos][2]:oWSUSERFIELD, MTSIMULATIONQUOTE_USERFIELD():New() )

			aProp[nPos][2]:oWSUSERFIELD[nJ]:nUSERDEC		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:nUSERDEC
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERNAME		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERNAME
			aProp[nPos][2]:oWSUSERFIELD[nJ]:lUSEROBLIG		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:lUSEROBLIG
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERPICTURE	:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERPICTURE
			aProp[nPos][2]:oWSUSERFIELD[nJ]:nUSERSIZE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:nUSERSIZE
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTAG		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTAG
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTITLE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTITLE
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTYPE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTYPE
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERCOMBOBOX	:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERCOMBOBOX
		Next nJ
	Else
	 	conout( GetWsCError( 3 ) )
	EndIf

	If	Empty( HttpSession->PWSF065GRAVA[1]:cCONTACT )
		HttpSession->PWSF065GRAVA[1]:cCONTACT := STR0014 //"CONTATO"
	EndIf

	PWSSetObjToPost( HttpSession->PWSF065GRAVA[2][nI], HttpSession->PWSF061HEADER[2][1], HttpPost->aPost, AllTrim( Str( nI ) ) )

	//--Se existir gatilho para calular o campo C8_TOTAL (Total Item), o mesmo nao pode ser editavel e tem que ser zerado.
	If	HttpSession->PWSF065GRAVA[2][nI]:NTOTALVALUE == Nil .Or. aScan(HttpPost->aPost, {|x|x=="NTOTALVALUE_1_H"})>0
		HttpSession->PWSF065GRAVA[2][nI]:NTOTALVALUE := 0
	EndIf

Next nI

aGrava := aClone( HttpSession->PWSF065GRAVA )

oObj:cUSERCODE   := MYUSERCODE
oObj:cSUPPLIER   := HttpSession->CODFORERP

oObj:oWSOLDQUOTE := MTSIMULATIONQUOTE_QUOTEVIEW():New()
oObj:oWSOLDQUOTE:oWSQUOTEHEADER := HttpSession->PWSF065GRAVA[1]
oObj:oWSOLDQUOTE:oWSQUOTEITEM := MTSIMULATIONQUOTE_ARRAYOFQUOTEITEMVIEW():New()


nTam := Len( HttpSession->PWSF065GRAVA[2] )
For nI := 1 To nTam
	aAdd( oObj:oWSOLDQUOTE:oWSQUOTEITEM:oWSQUOTEITEMVIEW, MTSIMULATIONQUOTE_QUOTEITEMVIEW():New() )
	oObj:oWSOLDQUOTE:oWSQUOTEITEM:oWSQUOTEITEMVIEW[nI] := HttpSession->PWSF065GRAVA[2][nI]
Next nI

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Metodo PUTQUOTE                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//cUSERCODE,cSUPPLIER,oWSOLDQUOTE
If	oObj:PUTQUOTE()
	HttpSession->PWSF065GRAVA[1] := oObj:oWSPUTQUOTERESULT:oWSQUOTEHEADER
	HttpSession->PWSF065GRAVA[2] := {}
	HttpSession->nTotalCot := 0

	For nI := 1 To Len( oObj:oWSPUTQUOTERESULT:oWSQUOTEITEM:oWSQUOTEITEMVIEW )
		aAdd( HttpSession->PWSF065GRAVA[2], MTSIMULATIONQUOTE_QUOTEITEMVIEW():New() )
		HttpSession->PWSF065GRAVA[2][nI] := oObj:oWSPUTQUOTERESULT:oWSQUOTEITEM:oWSQUOTEITEMVIEW[nI]
		HttpSession->nTotalCot += HttpSession->PWSF065GRAVA[2][nI]:nTOTALVALUE
		// Soma o valor dos impostos no total da cota็ใo
		For nX := 1 To Len( HttpSession->PWSF065GRAVA[2][nI]:oWSTAXES:oWSTAXESVIEW )
			If HttpSession->PWSF065GRAVA[2][nI]:oWSTAXES:oWSTAXESVIEW[nX]:cTAXCODE $ "IPI"
				HttpSession->nTotalCot += HttpSession->PWSF065GRAVA[2][nI]:oWSTAXES:oWSTAXESVIEW[nX]:nTAXAMOUNT
			EndIf
		Next nX
		HttpSession->PWSF065GRAVA[2][nI]:cDESCRIPTIONPRODUCT := aGrava[2][nI]:cDESCRIPTIONPRODUCT
		HttpSession->nTotalCot -= HttpSession->PWSF065GRAVA[2][nI]:NDISCOUNTVALUE
	Next nI
Else
	Return PWSHTMLALERT( "", STR0007, "", "W_PWSF065.APW" ) //"Erro"
EndIf

cHtml += W_PWSF065()

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSF068   บAutor  ณ Flavio Luiz Vicco   บ Data ณ  21/09/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gravacao da Cotacao                                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                          บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSF068()
Local cHtml		:= ""
Local nI		:= 0
Local nJ		:= 0
Local nPos		:= 0
Local nTam		:= 0
Local aProp		:= {}
Local oObj
Local oObjCfg

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicializa o WS - MTSUPPLIERQUOTE   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIERQUOTE"), WSMTSUPPLIERQUOTE():New())
WsChgURL( @oObj, "MTSUPPLIERQUOTE.APW" )

oObjCfg	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
WsChgURL( @oObjCfg, "CFGDICTIONARY.APW" )

PWSSetObjToPost( HttpSession->PWSF065GRAVA[1], HttpSession->PWSF061HEADER[1][1], HttpPost->aPost )

nTam := Len( HttpSession->PWSF065GRAVA[2] )
For nI := 1 To nTam
	If	Empty( HttpSession->PWSF065GRAVA[2][nI]:cSEQUENTIALID )
		HttpSession->PWSF065GRAVA[2][nI]:cSEQUENTIALID := StrZero( nI, 4 )
	EndIf
Next nI

For nI := 1 To nTam
	aProp := ClassDataArr( HttpSession->PWSF065GRAVA[2][nI] )
	nPos  := aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )

	oObjCfg:cUSERCODE := GetUsrCode()
	oObjCfg:cALIAS    := "SC8"

	//cUSERCODE,cALIAS
	If	oObjCfg:GETUSERFIELD()
		aProp[nPos][2] := MTSUPPLIERQUOTE_ARRAYOFUSERFIELD():New()

		For nJ := 1 To Len( oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD )
			aAdd( aProp[nPos][2]:oWSUSERFIELD, MTSUPPLIERQUOTE_USERFIELD():New() )

			aProp[nPos][2]:oWSUSERFIELD[nJ]:nUSERDEC		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:nUSERDEC
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERNAME		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERNAME
			aProp[nPos][2]:oWSUSERFIELD[nJ]:lUSEROBLIG		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:lUSEROBLIG
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERPICTURE	:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERPICTURE
			aProp[nPos][2]:oWSUSERFIELD[nJ]:nUSERSIZE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:nUSERSIZE
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTAG		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTAG
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTITLE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTITLE
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTYPE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTYPE
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERCOMBOBOX	:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERCOMBOBOX
		Next nJ
	Else
		conout( GetWsCError( 3 ) )
	EndIf

	PWSSetObjToPost( HttpSession->PWSF065GRAVA[2][nI], HttpSession->PWSF061HEADER[2][1], HttpPost->aPost, AllTrim( Str( nI ) ) )
	If	Empty( HttpSession->PWSF065GRAVA[1]:cCONTACT )
		HttpSession->PWSF065GRAVA[1]:cCONTACT := STR0014 //"CONTATO"
	EndIf

	//Verifica se existe gatilho para calular o campo C8_TOTAL (Total Item), o mesmo nao pode ser editavel e tem que ser zerado.
	//O campo nใo pode ficar igual a Nil
	If	HttpSession->PWSF065GRAVA[2][nI]:NTOTALVALUE == Nil .Or. aScan(HttpPost->aPost, {|x|x=="NTOTALVALUE_1_H"})>0
		HttpSession->PWSF065GRAVA[2][nI]:NTOTALVALUE := 0
	EndIf

Next nI

oObj:cUSERCODE := MYUSERCODE
oObj:cSUPPLIER := HttpSession->CODFORERP
oObj:oWSQUOTE  := MTSUPPLIERQUOTE_QUOTEVIEW():New()
oObj:oWSQUOTE:oWSQUOTEHEADER := HttpSession->PWSF065GRAVA[1]
oObj:oWSQUOTE:oWSQUOTEITEM := MTSUPPLIERQUOTE_ARRAYOFQUOTEITEMVIEW():New()

For nI := 1 To Len( HttpSession->PWSF065GRAVA[2] )
	If	Empty( HttpSession->PWSF065GRAVA[2][nI]:cSEQUENTIALID )
		HttpSession->PWSF065GRAVA[2][nI]:cSEQUENTIALID := StrZero( nI, 4 )
	EndIf
	aAdd( oObj:oWSQUOTE:oWSQUOTEITEM:oWSQUOTEITEMVIEW, MTSUPPLIERQUOTE_QUOTEITEMVIEW():New() )
	oObj:oWSQUOTE:oWSQUOTEITEM:oWSQUOTEITEMVIEW[nI] := HttpSession->PWSF065GRAVA[2][nI]
Next nI

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Metodo PUTQUOTE                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//cUSERCODE,cSUPPLIER,oWSQUOTE
If	oObj:PUTQUOTE()
	Return PWSHTMLALERT( "", STR0015, STR0005 + oObj:cPUTQUOTERESULT + STR0016, "W_PWSF060.APW" )//"Aten็ใo","Cota็ใo N๚mero "," cadastrado com SUCESSO!"
Else
	Return PWSHTMLALERT( "", STR0007, "", "W_PWSF065.APW" ) //"Erro"
EndIf

cHtml += W_PWSF065()

WEB EXTENDED END

Return cHtml
