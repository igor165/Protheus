#INCLUDE "PROTHEUS.CH"
#INCLUDE "PWSF100.CH"
#INCLUDE "APWEBEX.CH"

#DEFINE FORNECERP_ENTIDADE 1
#DEFINE FORNECERP_CODIGO   2
#DEFINE FORNECERP_NOMEFANT 3
#DEFINE FORNECERP_RAZAOSOC 4
#DEFINE FORNECERP_CPFCNPJ  5

#DEFINE MYUSERCODE GetUsrCode()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSF10*   บAutor  ณ Flavio Luiz Vicco   บ Data ณ  22/09/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Este fonte possui as funcionalidades relacionado a          บฑฑ
ฑฑบ          ณ Alteracao dos Dados Cadastrais do Fornecedor.               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบComents.  ณFuncoes Pertinentes ao Menu Financeiro (fornecedores):       บฑฑ
ฑฑบ          ณ Tํtulos Baixados	[Ok]         W_PWSF100                     บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑบ          ณAphs Envolvidos :                                            บฑฑ
ฑฑบ          ณ PWSF020.APH Sele็ใo de Fornecedores                         บฑฑ
ฑฑบ          ณ PWSF101.APH Browse de Baixas                                บฑฑ
ฑฑบ          ณ PWSF102.APH Detalhes das Baixas                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                          บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSF100   บAutor  ณ Flavio Luiz Vicco   บ Data ณ  22/09/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mostra os fornecedores disponiveis para o usuario logado.   บฑฑ
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
Web Function PWSF100()

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
HttpSession->PWSF020APH := { STR0001 , ;  // Titulo
                              "W_PWSF101A.APW", ;     // Proxima Tela
                              "" }                    // Msg de Erro

Do Case
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณNao ha fornecedores cadastrados para o usuario logadoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case Empty( HttpPost->PWSF020FOR )
		HttpSession->PWSF020APH[3] := STR0002 //"Nใo hแ Fornecedores a consultar."
		cHtml += ExecInPage( "PWSF020" )
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณApenas 1 fornecedor cadastrado.                               ณ
	//ณ Define a navega็ใo para pular a tela de sele็ใo de Fornecedorณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case Len( HttpPost->PWSF020FOR ) == 2	
		HttpPost->CODFORERP := HttpPost->PWSF020FOR[2][FORNECERP_CODIGO]	
		cHtml += W_PWSF101A()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMais de 1 fornecedor. Chama tela de sele็ใo de Fornecedoresณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Otherwise
		cHtml += ExecInPage( "PWSF020" )

EndCase

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSF101A  บAutor  ณ Flavio Luiz Vicco   บ Data ณ  22/09/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de Busca dos Titulos Baixados do Fornecedor.           บฑฑ
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
Web Function PWSF101A()

Local cHtml    := ""
Local aWebCols := {}
Local oObj
Local oObjIndex

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Fornecedor Selecionado                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty( HttpPost->CODFORERP )
	HttpSession->CODFORERP := HttpPost->CODFORERP
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes a serem utilizadas pelo APHณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSF101AAPH := { STR0001, ;  //"Tํtulos Baixados"
                              "W_PWSF101.APW", ;      //Proxima Tela
                              "W_PWSF100.APW" }       //Pagina de retorno

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa o objeto WS - WSFINANCESUPPLIERBILLณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSFINANCESUPPLIERBILL"), WSFINANCESUPPLIERBILL():New())
WSChgURL( @oObj, "FINANCESUPPLIERBILL.APW" )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa o objeto WS - WSCFGDICTIONARYณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObjIndex := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
WSChgURL( @oObjIndex, "CFGDICTIONARY.APW" )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณHeader a ser utilizado pelas funcoes GridHeader e GridLinesExณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty( HttpSession->PWSF101HEADER )
   HttpSession->PWSF101HEADER := { NIL, NIL, NIL }

   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   //ณHeader da estrutura BILLVIEW - Cabec Titulo: ณ
   //ณPREFIX                : Prefixo              ณ
   //ณBILLNUMBER            : No. Titulo           ณ
   //ณINSTALLMENT           : Parcela              ณ
   //ณBILLTYPE              : Tipo                 ณ
   //ณCUSTOMERCODE          : Cliente              ณ
   //ณUNITCUSTOMERCODE      : Loja                 ณ
   //ณCUSTOMERNAME          : Nome                 ณ
   //ณCLASSCODE             : Natureza             ณ
   //ณISSUEDATE             : DT Emissao           ณ
	//ณORIGINALDUEDATE       : Vencto Orig          ณ
	//ณREALDUEDATE           : Vencto Real          ณ
	//ณCURRENCY              : Moeda                ณ
	//ณCURRENCYSYMBOL        : Moeda                ณ
	//ณORIGINALVALUE         : Vlr. Titulo          ณ
	//ณORIGINALCURRENCYVALUE : Vlr. R$              ณ
	//ณDEDUCTIONSVALUE       : Abatimento           ณ
	//ณDEDUCTIONSVALUE       : Sld.Acresc.          ณ
	//ณINCREASEVALUE         : Sld.Decresc.         ณ
	//ณBALANCEVALUE          : Saldo                ณ
	//ณBALANCECURRENCYVALUE  : Saldo                ณ
	//ณBANK                  : Portador             ณ
	//ณHISTORY               : Historico            ณ
	//ณDELAYINDATES          : Atrasados            ณ
	//ณDELAYINTERESTRATE     : Porc Juros           ณ
	//ณDELAYINTERESTVALUE    : Taxa Perman.         ณ
   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   oObj:cHEADERTYPE := "BILLVIEW"
   If oObj:GETHEADER()
      HttpSession->PWSF101HEADER[1] := { oObj:oWSGetHEADERRESULT:oWSBRWHEADER }
   Else
      Return PWSHtmlAlert( "", STR0003 , "", "W_PWSF100.APW" )
   EndIf

   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   //ณHeader da estrutura PAIDBILLCOLLECTION - Titulo bxsณ
   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   oObj:cHEADERTYPE := "PAIDBILLVIEW"
   If oObj:GETHEADER()
      HttpSession->PWSF101HEADER[2] := { oObj:oWSGetHEADERRESULT:oWSBRWHEADER }
   Else
      Return PWSHtmlAlert( "", STR0003 , "", "W_PWSF100.APW" )
   EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณHeader da estrutura do WS CFGDICTIONARYณ
	//|- CODE        : Ordem                  |
	//|- DESCRIPTION : Chave                  |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Empty( HttpSession->PWSF101HEADER[3] )
		If oObjIndex:GETHEADER()
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณRetorno do Metodo GETHEADERณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			HttpSession->PWSF101HEADER[3] := { oObjIndex:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003 , "", "W_PWSF100.APW" )
		EndIf
	EndIf

EndIf //If Empty

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณIndices da Tabela SE1ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty( HttpSession->PWSF101INDEX )
	HttpSession->PWSF101INDEX := {}
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณParametros do metodo GETINDEXณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oObjIndex:cUSERCODE 	:= GetUsrCode()
	oObjIndex:cTABLE 		:= "SE2" // Tabela: Contas a Pagar
	
	//cUSERCODE,cTABLE
	If oObjIndex:GETINDEX()
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณResultado do Metodo GETINDEXณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		HttpSession->PWSF101INDEX := { oObjIndex:oWSGETINDEXRESULT:oWSGENERICSTRUCT }
	Else
		Return PWSHtmlAlert( "", STR0003 , "", "W_PWSF100.APW" )
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDados para montagem do campo de Ordemณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty( HttpSession->PWSF101AINFO )
	HttpSession->PWSF101AINFO := {}

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPonto de Entrada - Campos do WS WSCFGDICTIONARYณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ExistBlock( "PEF101A" )
		aWebCols := ExecBlock( "PEF101A", .F., .F., {} )
	Else
		aAdd( aWebCols, "CODE" )
		aAdd( aWebCols, "DESCRIPTION" )
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFuncao de montagem da descricao dos campos da telaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   GridHeader( HttpSession->PWSF101AINFO, ;
               HttpSession->PWSF101HEADER[3][1], aWebCols )
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFuncao de montagem dos campos da telaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   GridLinesEx( { HttpSession->PWSF101AINFO, ;
               HttpSession->PWSF101HEADER[3][1], ;
               HttpSession->PWSF101INDEX[1], ;
               aWebCols, .F., "A", NIL, 0 } )
EndIf

cHtml += ExecInPage( "PWSF101A" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSF101   บAutor  ณ Flavio Luiz Vicco   บ Data ณ  22/09/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela com Browse dos Titulos baixados do Fornecedor.         บฑฑ
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
Web Function PWSF101()

Local cHtml    := ""
Local nPos     := 0
Local aWebCols := {}
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Fornecedor Selecionado                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty( HttpPost->CODFORERP )
	HttpSession->CODFORERP := HttpPost->CODFORERP
EndIf

HttpSession->PWSF101APH := { STR0001 , ;   //Titulo baixados
                              "W_PWSF102.APW", ;      //Proxima Tela
                              "W_PWSF101A.APW" }       //Pagina de retorno

HttpSession->PWSF101INFO := { }

If !Empty( HttpSession->CODFORERP )
   nPos := aScan( HttpSession->PWSF020FOR , {|x| x[FORNECERP_CODIGO] == HttpSession->CODFORERP } )

   If nPos > 0
      HttpSession->PWSF101APH[1] := STR0001+": "+HttpSession->PWSF020FOR[nPos][FORNECERP_RAZAOSOC]

      //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
      //ณInicializa o objeto WS - WSFINANCESUPPLIERBILLณ
      //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
      oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSFINANCESUPPLIERBILL"), WSFINANCESUPPLIERBILL():New())
      WSChgURL( @oObj, "FINANCESUPPLIERBILL.APW" )

      //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
      //ณParametros do metodo BRWPAIDBILLณ
      //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
      oObj:cUSERCODE      := MYUSERCODE
      oObj:cSUPPLIERID    := HttpSession->CODFORERP
      oObj:dDATEFROM      := CToD( HttpPost->dDATEFROM )
      oObj:dDATETO        := CToD( HttpPost->dDATETO )
      oObj:cQUERYADDWHERE := ""
      oObj:cINDEXKEY      := HttpPost->cINDEX
      //cUSERCODE,cSUPPLIERID,dDATEFROM,dDATETO,cQUERYADDWHERE,cINDEXKEY
      If oObj:BRWPAIDBILL()
         HttpSession->PWSF101RESULT := { oObj:oWSBRWPAIDBILLRESULT:oWSBILLVIEW }
      Else
         Return PWSHtmlAlert( "", STR0003 , "", "W_PWSF100.APW" )
      EndIf

      //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
      //ณVerifica Resultado da Buscaณ
      //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
      If !Empty( HttpSession->PWSF101RESULT ) .AND. Len( HttpSession->PWSF101RESULT[1] ) > 0

         //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
         //ณ Cabecalho dos Titulos     ณ
         //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
         If ExistBlock( "PEF101" )
            aWebCols := ExecBlock( "PEF101", .F., .F., {} )
         Else
            aAdd( aWebCols, "PREFIX" )
            aAdd( aWebCols, "BILLNUMBER" )
            aAdd( aWebCols, "INSTALLMENT" )
            aAdd( aWebCols, "BILLTYPE" )
            aAdd( aWebCols, "ISSUEDATE" )
            aAdd( aWebCols, "REALDUEDATE" )
         EndIf
        
         GridHeader( HttpSession->PWSF101INFO, ;
                     HttpSession->PWSF101HEADER[1][1], ;
                     aWebCols ,;
                     HttpSession->PWSF101RESULT[1], "FINANCESUPPLIERBILL", "SE2" )

         GridLinesEx( { HttpSession->PWSF101INFO, ;
                        HttpSession->PWSF101HEADER[1][1], ;
                        HttpSession->PWSF101RESULT[1], ;
                        aWebCols, .F., "A", NIL, 0 }, "FINANCESUPPLIERBILL", "SE2" )

         cHtml += ExecInPage( "PWSF101" )

      Else
	      Return PWSHtmlAlert( "", STR0003 , STR0004 , "W_PWSF100.APW" ) //"A busca nใo retornou nenhuma titulo para este fornecedor no perํodo solicitado."
      EndIf

   EndIf //If nPos > 0

EndIf

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSF102   บAutor  ณ Flavio Luiz Vicco   บ Data ณ  22/09/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de detalhes dos titulos baixados.                      บฑฑ
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
Web Function PWSF102()

Local cHtml    := ""
Local nPosTit  := 0
Local nPos     := 0
Local aWebCols := {}
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

nPosTit := Val( HttpGet->cTitulo )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArray com as informacoes a serem mostradas na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSF102APH := { 	STR0005 + ;
                              HttpSession->PWSF101RESULT[1][nPosTit]:cPREFIX + ;
                              HttpSession->PWSF101RESULT[1][nPosTit]:cBILLNUMBER + ;
                              HttpSession->PWSF101RESULT[1][nPosTit]:cINSTALLMENT + ;
                              HttpSession->PWSF101RESULT[1][nPosTit]:cBILLTYPE, ;
                              STR0006 , ;
                              "W_PWSF101A.APW" }        //Pagina de Volta


HttpSession->PWSF102INFO   := { { }, { } }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Fornecedor Selecionado                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty( HttpPost->CODFORERP )
	HttpSession->CODFORERP := HttpPost->CODFORERP
EndIf


If nPosTit > 0

	nPosFor := aScan( HttpSession->PWSF020FOR, { |x| x[FORNECERP_CODIGO] == HttpSession->CODFORERP } )

	If nPosFor > 0
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Inicializa o objeto WS - WSFINANCESUPPLIERBILL ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSFINANCESUPPLIERBILL"), WSFINANCESUPPLIERBILL():New())
		WSChgURL( @oObj, "FINANCESUPPLIERBILL.APW" )

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Metodo GETPAIDBILL              ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		//cUSERCODE,cSUPPLIERID,cPREFIX,cBILLNUMBER,cINSTALLMENT,cBILLTYPE
		oObj:cUSERCODE    := MYUSERCODE
		oObj:cSUPPLIERID  := HttpSession->CODFORERP
		oObj:cPREFIX      := HttpSession->PWSF101RESULT[1][nPosTit]:cPREFIX
		oObj:cBILLNUMBER  := HttpSession->PWSF101RESULT[1][nPosTit]:cBILLNUMBER
		oObj:cINSTALLMENT := HttpSession->PWSF101RESULT[1][nPosTit]:cINSTALLMENT
		oObj:cBILLTYPE    := HttpSession->PWSF101RESULT[1][nPosTit]:cBILLTYPE
		If oObj:GETPAIDBILL()
			HttpSession->PWSF102RESULT := { oObj:oWSGETPAIDBILLRESULT }

			If ExistBlock( "PEF102" )
				aWebCols := ExecBlock( "PEF102", .F., .F., {1} )
			EndIf

			// --- Temporario : Necessario criar estrutura separada do Ctas a Receber (BILLVIEW)
			If (nPos := aScan(HttpSession->PWSF101HEADER[1][1],{|x| AllTrim(x:cHeaderTitle) == "Cliente"})) >0 
				HttpSession->PWSF101HEADER[1][1][nPos]:cHeaderTitle := STR0011 // "Fornecedor"
			EndIf

			GridLinesEx( { 	HttpSession->PWSF102INFO[1], ;
							HttpSession->PWSF101HEADER[1][1], ;
							HttpSession->PWSF102RESULT[1]:oWSBILL, ;
							aWebCols, .F., "H", NIL, 0 }, "FINANCESUPPLIERBILL", "SE2" )

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPonto de Entrada - Baixaณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If ExistBlock( "PEF102" )
				aWebCols := ExecBlock( "PEF102", .F., .F., { 2 } )
			EndIf

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณFuncao de montagem da descricao dos campos da telaณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			GridHeader( HttpSession->PWSF102INFO[2], ;
						HttpSession->PWSF101HEADER[2][1], ;
						aWebCols ,;
						HttpSession->PWSF102RESULT[1]:oWSPAYMENT:oWSPAIDBILLVIEW, "FINANCESUPPLIERBILL", "SE5" )

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณFuncao de montagem da descricao dos campos da telaณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			GridLinesEx( {	HttpSession->PWSF102INFO[2], ;
							HttpSession->PWSF101HEADER[2][1], ;
							HttpSession->PWSF102RESULT[1]:oWSPAYMENT:oWSPAIDBILLVIEW, ;
							aWebCols, .F., "A", NIL, 0 }, "FINANCESUPPLIERBILL", "SE5" )

		Else
			Return PWSHtmlAlert( "", STR0003 , "", "W_PWSF101.APW" )
		EndIf
	Else
		Return PWSHtmlAlert( "", STR0003 , "", "W_PWSF101.APW" )
	EndIf

	cHtml += ExecInPage( "PWSF102" )

EndIf

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSF102A  บAutor  ณ Flavio Luiz Vicco   บ Data ณ  22/09/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela com as baixas do titulos selecionado.                  บฑฑ
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
Web Function PWSF102A()

Local cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSF102A" )

WEB EXTENDED END

Return cHtml
