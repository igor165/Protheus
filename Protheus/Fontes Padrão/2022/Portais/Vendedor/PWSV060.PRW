#INCLUDE "PROTHEUS.CH"
#INCLUDE "PWSV060.CH"
#INCLUDE "APWEBEX.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSV06*   บAutor  ณLuiz Felipe Couto    บ Data ณ  11/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Este fonte possui as funcionalidades relacionado as         บฑฑ
ฑฑบ          ณ estatisticas de venda.                                      บฑฑ
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSV060   บAutor  ณLuiz Felipe Couto    บ Data ณ  11/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mostra os vendedores disponiveis para o usuario logado.     บฑฑ
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
Web Function PWSV060()

Local cHtml := ""					//Pagina WEB
Local aVend	:= {}					//Array de vendedores cadastrados para o usuario logado

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVendedores cadastrados para o usuario logadoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aVend := GetUserVen()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes a serem utilizadas pelo APHณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSV020APH	:= { 	STR0001			,;			//Estatisticas de Venda
								"W_PWSV061.APW"	,;			//Pagina para onde sera enviado o POST
								"" }						//Mensagem a ser mostrada na tela
	
Do Case
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณNao ha vendedores cadastrados para o usuario logadoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case Empty( aVend )
		HttpSession->PWSV020APH[3] := STR0002	//Nao ha vendedores a consultar
		
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณApenas 1 vendedor cadastradoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case Len( aVend ) == 2
		HttpSession->CODVENERP := aVend[2][2]

		Return W_PWSV061()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMais de 1 vendedorณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Otherwise
		cHtml += ExecInPage( "PWSV020" )

EndCase

cHtml += ExecInPage( "PWSV020" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSV061   บAutor  ณLuiz Felipe Couto    บ Data ณ  11/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de busca dos produtos para o vendedor selecionado.     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCleber M. ณ04/07/07ณ128597ณ-Alteracao do nome do metodo GetHeader para  บฑฑ
ฑฑบ          ณ        ณ      ณGetHeadSum para evitar a leitura de um resul-บฑฑ
ฑฑบ          ณ        ณ      ณtado antigo na memoria. 	                   บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSV061()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array contendo os campos que serao mostrados na tela
Local oObjProd							//Objeto WS - WSMTPRODUCT
Local oObjIndex							//Objeto WS - WSCFGDICTIONARY
Local oObjSum							//Objeto WS - WSFTSELLERSALESSUMMARY

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes a serem utilizadas pelo APHณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSV061APH := { STR0001		,;	//Estatisticas de Venda
							 "W_PWSV062.APW" }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa o objeto WS - WSMTPRODUCTณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObjProd := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTPRODUCT' ), WSMTPRODUCT():New() )
WsChgUrl( @oObjProd, "MTPRODUCT.APW" )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa o objeto WS - WSCFGDICTIONARYณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObjIndex := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGDICTIONARY' ), WSCFGDICTIONARY():New() )
WsChgUrl( @oObjIndex, "CFGDICTIONARY.APW" )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa o objeto WS - WSFTSELLERSALESSUMMARYณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObjSum := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFTSELLERSALESSUMMARY' ), WSFTSELLERSALESSUMMARY():New() )
WsChgUrl( @oObjSum, "FTSELLERSALESSUMMARY.APW" )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArray contendo os headers dos WS utilizados nesta paginaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty( HttpSession->PWSV061HEADER )
	HttpSession->PWSV061HEADER := { NIL, NIL, NIL, NIL }

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณHeader da estrutura PRODUCTVIEW - Produto                              ณ
	//|- PRODUCTCODE                  : Codigo                                |
	//|- DESCRIPTION                  : Descricao                             |
	//|- SCIENCEDESCRIPTION           : Descricao Cientifica                  |
	//|- MEASUREUNIT                  : Unidade de Medida                     |
	//|- DESCRIPTIONMEASUREUNIT       : Descricao da Unidade de Medida        |
	//|- SECONDMEASUREUNIT            : Segunda Unidade de Medida             |
	//|- DESCRIPTIONSECONDMEASUREUNIT : Descricao da Segunda Unidade de Medida|
	//|- TYPEOFPRODUCT                : Tipo                                  |
	//|- DESCRIPTIONTYPEOFPRODUCT     : Descricao do Tipo                     |
	//|- GROUPOFPRODUCT               : Grupo                                 |
	//|- DESCRIPTIONGROUPOFPRODUCT    : Descricao do Grupo                    |
	//|- NCM                          : Nomenclatura Ext. Mercosul            |
	//|- QUANTITYPERPACKAGE           : Quntidade por Embalagem               |
	//|- ORDERPOINT                   : Ponto de Pedido                       |
	//|- NETWEIGHT                    : Peso Liquido                          |
	//|- GROSSWEIGHT                  : Peso Bruto                            |
	//|- LEADTIME                     : Prazo de Entrega                      |
	//|- TYPEOFLEADTIME               : Tipo de Prazo de Entrega              |
	//|- ECONOMICLOT                  : Lote Economico                        |
	//|- MINIMUMLOT                   : Lote Minimo                           |
	//|- MINIMUMGRADE                 : Nota Minima                           |
	//|- TERMOFVALIDATY               : Termo de Validade                     |
	//|- BARCODE                      : Codigo de Barra                       |
	//|- STORAGELENGHT                : Comprimento da Armazenagem            |
	//|- STORAGEWIDTH                 : Largura da Armazenagem                |
	//|- STORAGEHEIGHT                : Altura da Armazenagem                 |
	//|- STORAGEMAXIMUMPILING         : Fator de Armazenamento                |
	//|- STANDARDWAREHOUSE            : Armazem                               |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Empty( HttpSession->PWSV061HEADER[1] )
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณParametros do metodo GETHEADERณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oObjProd:cHEADERTYPE := "PRODUCTVIEW"
	
		//cHEADERTYPE
		If oObjProd:GETHEADER()
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณRetorno do Metodo GETHEADERณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			HttpSession->PWSV061HEADER[1] := { oObjProd:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003		,;	//Atencao
								 "", "W_PWSV060.APW" )
		EndIf
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณHeader da estrutura do WS CFGDICTIONARYณ
	//|- CODE        : Ordem                  |
	//|- DESCRIPTION : Chave                  |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Empty( HttpSession->PWSV061HEADER[2] )
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณParametros do metodo GETHEADERณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If oObjIndex:GETHEADER()
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณRetorno do Metodo GETHEADERณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			HttpSession->PWSV061HEADER[2] := { oObjIndex:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003		,; //Atencao
								 "", "W_PWSV060.APW" )
		EndIf
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณHeader da estrutura do WS GENERICSTRUCTณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Empty( HttpSession->PWSV061HEADER[3] )
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณParametros do metodo GETHEADSUM ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oObjSum:cHEADERTYPE := "GENERICSTRUCT"
	
		//cHEADERTYPE
		If oObjSum:GETHEADSUM()
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณRetorno do Metodo GetHeadSumณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			HttpSession->PWSV061HEADER[3] := { oObjSum:oWSGETHEADSUMRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003		,;	//Atencao
								 "", "W_PWSV060.APW" )
		EndIf
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณHeader da estrutura do WS PRODUCTSUMMARYณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Empty( HttpSession->PWSV061HEADER[4] )
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณParametros do metodo GETHEADSUMณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oObjSum:cHEADERTYPE := "PRODUCTSUMMARY"
		
		//cHEADERTYPE
		If oObjSum:GETHEADSUM()
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณRetorno do Metodo GETHEADSUMณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			HttpSession->PWSV061HEADER[4] := { oObjSum:oWSGETHEADSUMRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003		,;	//Atencao
								 "", "W_PWSV060.APW" )
		EndIf
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณIndices da Tabela SB1ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty( HttpSession->PWSV061INDEX )
	HttpSession->PWSV061INDEX := {}
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณParametros do metodo GETINDEXณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oObjIndex:cUSERCODE 	:= GetUsrCode()
	oObjIndex:cTABLE 		:= "SB1"
	
	//cUSERCODE,cTABLE
	If oObjIndex:GETINDEX()
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณResultado do Metodo GETINDEXณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		HttpSession->PWSV061INDEX := { oObjIndex:oWSGETINDEXRESULT:oWSGENERICSTRUCT }
	Else
		Return PWSHtmlAlert( "", STR0003		,;	//Atencao
							 "", "W_PWSV060.APW" )
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDados para montagem do campo de Ordemณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty( HttpSession->PWSV061INFO )
	HttpSession->PWSV061INFO := {}

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPonto de Entrada - Campos do WS WSCFGDICTIONARYณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ExistBlock( "PEV061" )
		aWebCols := ExecBlock( "PEV061", .F., .F., {} )
	Else
		aAdd( aWebCols, "CODE" )
		aAdd( aWebCols, "DESCRIPTION" )
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFuncao de montagem da descricao dos campos da telaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   	GridHeader( HttpSession->PWSV061INFO, HttpSession->PWSV061HEADER[2][1], aWebCols )
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFuncao de montagem dos campos da telaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	GridLinesEx( { 	HttpSession->PWSV061INFO		, HttpSession->PWSV061HEADER[2][1]	,;
					HttpSession->PWSV061INDEX[1]	, aWebCols							,;
					.F., "A",, 0 } )
EndIf

cHtml += ExecInPage( "PWSV061" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSV062   บAutor  ณLuiz Felipe Couto    บ Data ณ  11/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela com a busca dos produtos.                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCleber M. ณ06/04/06ณ95815 ณVerificacao se o cliente escolhido pertence  บฑฑ
ฑฑบ          ณ        ณ      ณa carteira do vendedor.                      บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSV062()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array contendo os campos a serem mostrados na tela
Local oObj								//Objeto WS - WSMTPRODUCT
Local oObjCliente						//Objeto WS - WSMTCUSTOMER

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes a serem mostradas na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSV062APH := { 	STR0004		,;				//Estatisticas de Venda - Resultado da Busca PRODUTOS
								"W_PWSV063.APW"	,;				//Pagina para onde sera enviado o POST
								"W_PWSV061.APW" }				//Pagina de Volta

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArray para montagem da telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSV062INFO := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa o objeto WS - WSMTPRODUCTณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTPRODUCT' ), WSMTPRODUCT():New() )
WsChgUrl( @oObj, "MTPRODUCT.APW" )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa o objeto WS - WSMTPRODUCTณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObjCliente := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMER' ), WSMTCUSTOMER():New() )
WsChgUrl( @oObjCliente, "MTCUSTOMER.APW" )

oObjCliente:cUSERCODE	:= GetUsrCode()
oObjCliente:cCUSTOMERID	:= HttpPost->cCUSTOMERCODE + HttpPost->cCUSTOMERUNIT

//cUSERCODE,cCUSTOMERID
If oObjCliente:GETCUSTOMER()
	HttpSession->cCUSTOMERID := oObjCliente:oWSGETCUSTOMERRESULT:cCUSTOMERCODE + oObjCliente:oWSGETCUSTOMERRESULT:cUNITCUSTOMERCODE
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Valida se o vendedor do cliente eh o mesmo do Portal ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If (oObjCliente:oWSGETCUSTOMERRESULT:cSELLERCODE <> HttpSession->CODVENERP)
		Return PWSHtmlAlert( "", STR0003	,;	//Atencao
							 STR0005		,;	//Este cliente pertence a carteira de outro vendedor
							 "W_PWSV061.APW" )
	EndIf
Else
	Return PWSHtmlAlert( "", STR0003		,;	//Atencao
						 "", "W_PWSV061.APW" )
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณParametros do metodo GETCATALOGณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObj:cUSERCODE			:= GetUsrCode()
oObj:cPRODUCTCODELIKE	:= HttpPost->cPRODUCTCODELIKE
oObj:cDESCRIPTIONLIKE	:= HttpPost->cDESCRIPTIONLIKE
oObj:cINDEXKEY			:= HttpPost->cINDEX

//cUSERCODE,cTYPEOFPRODUCTIN,cGROUPOFPRODUCTIN,cPRODUCTCODELIKE,cDESCRIPTIONLIKE,nPAGELEN,nPAGEFIRST,cQUERYADDWHERE,cINDEXKEY
If oObj:GETCATALOG()
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRetorno do metodo GETCATALOGณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	HttpSession->PWSV062RESULT := { oObj:oWSGETCATALOGRESULT:oWSPRODUCTVIEW }
Else
	Return PWSHtmlAlert( "", 	STR0003		,;	//Atencao
						 "", "W_PWSV060.APW" )
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica Resultado da Buscaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty( HttpSession->PWSV062RESULT ) .AND. Len( HttpSession->PWSV062RESULT[1] ) > 0
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPonto de Entrada - Produtoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ExistBlock( "PEV062" )
		aWebCols := ExecBlock( "PEV062", .F., .F., {} )
	Else
		AAdd( aWebCols, "PRODUCTCODE" )
		AAdd( aWebCols, "DESCRIPTION" )
		AAdd( aWebCols, "MEASUREUNIT" )
		AAdd( aWebCols, "TYPEOFPRODUCT" )
		AAdd( aWebCols, "GROUPOFPRODUCT" )
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFuncao de montagem da descricao dos campos da telaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	GridHeader(	HttpSession->PWSV062INFO, HttpSession->PWSV061HEADER[1][1], aWebCols )
             
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFuncao de montagem dos campos da telaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	GridLinesEx( { 	HttpSession->PWSV062INFO		, HttpSession->PWSV061HEADER[1][1]	,;
					HttpSession->PWSV062RESULT[1]	, aWebCols							,;
					.F., "A",, 0 } )
Else
	Return PWSHtmlAlert( "", STR0003	,;  //Atencao
						 STR0006		,;	//A busca nao retornou nenhum produto cadastrado.
						 "W_PWSV061.APW" )
EndIf

cHtml += ExecInPage( "PWSV062" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSV063   บAutor  ณLuiz Felipe Couto    บ Data ณ  11/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela com a busca por data.                                  บฑฑ
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
Web Function PWSV063()

Local cHtml 	:= ""					//Pagina WEB

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes a serem mostradas na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSV063APH := { 	STR0007			, ;			//Estatisticas de Venda - Busca por periodo
								"W_PWSV064.APW"	, ;			//Pagina para onde sera enviado o POST
								"W_PWSV061.APW" }			//Pagina de Volta

cHtml += ExecInPage( "PWSV063" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSV064   บAutor  ณLuiz Felipe Couto    บ Data ณ  11/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela com as estatisticas de venda para o produto no periodo บฑฑ
ฑฑบ          ณ selecionado.                                                บฑฑ
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
Web Function PWSV064()

Local cHtml 		:= ""					//Pagina WEB
Local nTam			:= 0					//Tamanho do array
Local aWebCols		:= {}					//Array com os campos a serem mostrados na pagina
Local oObj									//Objeto WS - WSFTSELLERSALESSUMMARY

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes a serem mostradas na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSV064APH := { 	STR0001	,;		//Estatisticas de Venda							
								STR0008	,;		//Faturamento bonificado no periodo					
								STR0009	,;		//Vendas bonificadas no periodo						
								STR0016	,;		//Faturamento bonificado por produtos no periodo
								STR0017	,;		//Vendas bonificadas por produto no periodo
								STR0010	,;		//Devolucoes por produtos no periodo
								STR0011	,;		//Faturamento por produtos no periodo
								STR0012	,;		//Vendas por produtos no periodo
								STR0013	,;		//Devolucoes no periodo
								STR0014	,;		//Faturamento no periodo
								STR0015	,;      //Vendas no periodo
								"W_PWSV063.APW" }	//Pagina de Volta

HttpSession->PWSV064INFO := { {}, {}, {}, {}, {}, {}, {}, {}, {}, {} }

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFTSELLERSALESSUMMARY' ), WSFTSELLERSALESSUMMARY():New() )
WsChgURL( @oObj, "FTSELLERSALESSUMMARY.APW" )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFaturamento bonificado no periodoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObj:cUSERCODE			:= GetUsrCode()
oObj:cSELLERCODE		:= HttpSession->CODVENERP
oObj:cCUSTOMERID		:= HttpSession->cCUSTOMERID
oObj:dDATEFROM			:= CToD( HttpPost->dDATEFROM )
oObj:dDATETO			:= CToD( HttpPost->dDATETO )
oObj:cTYPEOFPRODUCT		:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cTYPEOFPRODUCT
oObj:cGROUPOFPRODUCT	:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cGROUPOFPRODUCT
oObj:cPRODUCTCODE		:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cPRODUCTCODE
oObj:nCURRENCY			:= HttpPost->nCURRENCY

//cUSERCODE,cSELLERCODE,cCUSTOMERID,dDATEFROM,dDATETO,cTYPEOFPRODUCT,cGROUPOFPRODUCT,cPRODUCTCODE,nCURRENCY
If oObj:GETBONUSINVOICE()
	aWebCols := {}

	If ExistBlock( "PEV064" )
		aWebCols := ExecBlock( "PEV064", .F., .F., { 1 } )
	Else
		AAdd( aWebCols, "DESCRIPTION" )
		AAdd( aWebCols, "VALUE" )
	Endif

	GridHeader( HttpSession->PWSV064INFO[1]			,;
				HttpSession->PWSV061HEADER[3][1]	,;
				aWebCols )
	
	GridLinesEx( { 	HttpSession->PWSV064INFO[1]						,;
					HttpSession->PWSV061HEADER[3][1]				,;
					oObj:oWSGETBONUSINVOICERESULT:oWSGENERICSTRUCT	,;
					aWebCols										,;
					.F.												,;
					"A"												,;
					NIL												,;
					0 } )
Else
	Return PWSHtmlAlert( "", STR0003		,;	//Atencao
						 "", "W_PWSV061.APW" )
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVendas bonificadas no periodoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObj:cUSERCODE			:= GetUsrCode()
oObj:cSELLERCODE		:= HttpSession->CODVENERP
oObj:cCUSTOMERID		:= HttpSession->cCUSTOMERID
oObj:dDATEFROM			:= CToD( HttpPost->dDATEFROM )
oObj:dDATETO			:= CToD( HttpPost->dDATETO )
oObj:cTYPEOFPRODUCT		:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cTYPEOFPRODUCT
oObj:cGROUPOFPRODUCT	:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cGROUPOFPRODUCT
oObj:cPRODUCTCODE		:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cPRODUCTCODE
oObj:nCURRENCY			:= HttpPost->nCURRENCY

//cUSERCODE,cSELLERCODE,cCUSTOMERID,dDATEFROM,dDATETO,cTYPEOFPRODUCT,cGROUPOFPRODUCT,cPRODUCTCODE,nCURRENCY
If oObj:GETBONUSSALESORDER()
	aWebCols := {}

	If ExistBlock( "PEV064" )
		aWebCols := ExecBlock( "PEV064", .F., .F., { 2 } )
	Else
		AAdd( aWebCols, "DESCRIPTION" )
		AAdd( aWebCols, "VALUE" )
	Endif

	GridHeader( HttpSession->PWSV064INFO[2]			,;
				HttpSession->PWSV061HEADER[3][1]	,;
				aWebCols )
	
	GridLinesEx( { 	HttpSession->PWSV064INFO[2]							,;
					HttpSession->PWSV061HEADER[3][1]					,;
					oObj:oWSGETBONUSSALESORDERRESULT:oWSGENERICSTRUCT	,;
					aWebCols											,;
					.F.													,;
					"A"													,;
					NIL													,;
					0 } )
Else
	Return PWSHtmlAlert( "", STR0003		,;	//Atencao
						 "", "W_PWSV061.APW" )
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFaturamento bonificado por produtos no periodoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObj:cUSERCODE			:= GetUsrCode()
oObj:cSELLERCODE		:= HttpSession->CODVENERP
oObj:cCUSTOMERID		:= HttpSession->cCUSTOMERID
oObj:dDATEFROM			:= CToD( HttpPost->dDATEFROM )
oObj:dDATETO			:= CToD( HttpPost->dDATETO )
oObj:cTYPEOFPRODUCT		:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cTYPEOFPRODUCT
oObj:cGROUPOFPRODUCT	:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cGROUPOFPRODUCT
oObj:cPRODUCTCODE		:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cPRODUCTCODE
oObj:nCURRENCY			:= HttpPost->nCURRENCY

//cUSERCODE,cSELLERCODE,cCUSTOMERID,dDATEFROM,dDATETO,cTYPEOFPRODUCT,cGROUPOFPRODUCT,cPRODUCTCODE,nCURRENCY
If oObj:GETPRODUCTBONUSINVOICE()
	aWebCols := {}

	If Len( oObj:oWSGETPRODUCTBONUSINVOICERESULT:oWSPRODUCTSUMMARY ) > 0
		If ExistBlock( "PEV064" )
			aWebCols := ExecBlock( "PEV064", .F., .F., { 3 } )
		Else
			AAdd( aWebCols, "DESCRIPTION" )
			AAdd( aWebCols, "VALUE" )
		Endif

		nTam := Len( oObj:oWSGETPRODUCTBONUSINVOICERESULT:oWSPRODUCTSUMMARY )

		GridHeader( HttpSession->PWSV064INFO[3]			,;
					HttpSession->PWSV061HEADER[3][1]	,;
					aWebCols )
		
		GridLinesEx( { 	HttpSession->PWSV064INFO[3]			,;
						HttpSession->PWSV061HEADER[3][1]	,;
						oObj:oWSGETPRODUCTBONUSINVOICERESULT:oWSPRODUCTSUMMARY[nTam]:oWSVALUESUMMARY:oWSGENERICSTRUCT,;
						aWebCols							,;
						.F.									,;
						"A"									,;
						NIL									,;
						0 } )
	Else
		If ExistBlock( "PEV064" )
			aWebCols := ExecBlock( "PEV064", .F., .F., { 3 } )
		Endif

		GridHeader( HttpSession->PWSV064INFO[3]			,;
					HttpSession->PWSV061HEADER[4][1]	,;
					aWebCols )
		
		GridLinesEx( { 	HttpSession->PWSV064INFO[3]								,;
						HttpSession->PWSV061HEADER[4][1]						,;
						oObj:oWSGETPRODUCTBONUSINVOICERESULT:oWSPRODUCTSUMMARY	,;
						aWebCols												,;
						.F.														,;
						"A"														,;
						NIL														,;
						0 } )
	Endif
Else
	Return PWSHtmlAlert( "", STR0003		,;	//Atencao
						 "", "W_PWSV061.APW" )
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVendas bonificadas por produto no periodoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObj:cUSERCODE			:= GetUsrCode()
oObj:cSELLERCODE		:= HttpSession->CODVENERP
oObj:cCUSTOMERID		:= HttpSession->cCUSTOMERID
oObj:dDATEFROM			:= CToD( HttpPost->dDATEFROM )
oObj:dDATETO			:= CToD( HttpPost->dDATETO )
oObj:cTYPEOFPRODUCT		:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cTYPEOFPRODUCT
oObj:cGROUPOFPRODUCT	:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cGROUPOFPRODUCT
oObj:cPRODUCTCODE		:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cPRODUCTCODE
oObj:nCURRENCY			:= HttpPost->nCURRENCY

//cUSERCODE,cSELLERCODE,cCUSTOMERID,dDATEFROM,dDATETO,cTYPEOFPRODUCT,cGROUPOFPRODUCT,cPRODUCTCODE,nCURRENCY
If oObj:GETPRODUCTBONUSSALESORDER()
	aWebCols := {}

	If Len( oObj:oWSGETPRODUCTBONUSSALESORDERRESULT:oWSPRODUCTSUMMARY ) > 0
		If ExistBlock( "PEV064" )
			aWebCols := ExecBlock( "PEV064", .F., .F., { 4 } )
		Else
			AAdd( aWebCols, "DESCRIPTION" )
			AAdd( aWebCols, "VALUE" )
		Endif

		nTam := Len( oObj:oWSGETPRODUCTBONUSSALESORDERRESULT:oWSPRODUCTSUMMARY )

		GridHeader( HttpSession->PWSV064INFO[4]			,;
					HttpSession->PWSV061HEADER[3][1]	,;
					aWebCols )
		
		GridLinesEx( { 	HttpSession->PWSV064INFO[4]			,;
						HttpSession->PWSV061HEADER[3][1]	,;
						oObj:oWSGETPRODUCTBONUSSALESORDERRESULT:oWSPRODUCTSUMMARY[nTam]:oWSVALUESUMMARY:oWSGENERICSTRUCT,;
						aWebCols							,;
						.F.									,;
						"A"									,;
						NIL									,;
						0 } )
	Else
		If ExistBlock( "PEV064" )
			aWebCols := ExecBlock( "PEV064", .F., .F., { 4 } )
		Endif

		GridHeader( HttpSession->PWSV064INFO[4]			,;
					HttpSession->PWSV061HEADER[4][1]	,;
					aWebCols )
		
		GridLinesEx( { 	HttpSession->PWSV064INFO[4]							,;
						HttpSession->PWSV061HEADER[4][1]					,;
						oObj:oWSGETPRODUCTBONUSSALESORDERRESULT:oWSPRODUCTSUMMARY	,;
						aWebCols											,;
						.F.													,;
						"A"													,;
						NIL													,;
						0 } )
	Endif
Else
	Return PWSHtmlAlert( "", STR0003		,;	//Atencao
						 "", "W_PWSV061.APW" )
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDevolucoes por produtos no periodoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObj:cUSERCODE			:= GetUsrCode()
oObj:cSELLERCODE		:= HttpSession->CODVENERP
oObj:cCUSTOMERID		:= HttpSession->cCUSTOMERID
oObj:dDATEFROM			:= CToD( HttpPost->dDATEFROM )
oObj:dDATETO			:= CToD( HttpPost->dDATETO )
oObj:cTYPEOFPRODUCT		:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cTYPEOFPRODUCT
oObj:cGROUPOFPRODUCT	:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cGROUPOFPRODUCT
oObj:cPRODUCTCODE		:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cPRODUCTCODE
oObj:nCURRENCY			:= HttpPost->nCURRENCY

//cUSERCODE,cSELLERCODE,cCUSTOMERID,dDATEFROM,dDATETO,cTYPEOFPRODUCT,cGROUPOFPRODUCT,cPRODUCTCODE,nCURRENCY
If oObj:GETPRODUCTRETURNINVOICE()
	aWebCols := {}

	If Len( oObj:oWSGETPRODUCTRETURNINVOICERESULT:oWSPRODUCTSUMMARY ) > 0
		If ExistBlock( "PEV064" )
			aWebCols := ExecBlock( "PEV064", .F., .F., { 5 } )
		Else
			AAdd( aWebCols, "DESCRIPTION" )
			AAdd( aWebCols, "VALUE" )
		Endif

		nTam := Len( oObj:oWSGETPRODUCTRETURNINVOICERESULT:oWSPRODUCTSUMMARY )

		GridHeader( HttpSession->PWSV064INFO[5]			,;
					HttpSession->PWSV061HEADER[3][1]	,;
					aWebCols )
		
		GridLinesEx( { 	HttpSession->PWSV064INFO[5]			,;
						HttpSession->PWSV061HEADER[3][1]	,;
						oObj:oWSGETPRODUCTRETURNINVOICERESULT:oWSPRODUCTSUMMARY[nTam]:oWSVALUESUMMARY:oWSGENERICSTRUCT,;
						aWebCols							,;
						.F.									,;
						"A"									,;
						NIL									,;
						0 } )
	Else
		If ExistBlock( "PEV064" )
			aWebCols := ExecBlock( "PEV064", .F., .F., { 5 } )
		Endif

		GridHeader( HttpSession->PWSV064INFO[5]			,;
					HttpSession->PWSV061HEADER[4][1]	,;
					aWebCols )
		
		GridLinesEx( { 	HttpSession->PWSV064INFO[5]						,;
						HttpSession->PWSV061HEADER[4][1]				,;
						oObj:oWSGETPRODUCTRETURNINVOICERESULT:oWSPRODUCTSUMMARY	,;
						aWebCols										,;
						.F.												,;
						"A"												,;
						NIL												,;
						0 } )
	Endif
Else
	Return PWSHtmlAlert( "", STR0003		,;		//Atencao
						 "", "W_PWSV061.APW" )
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFaturamento por produtos no periodoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObj:cUSERCODE			:= GetUsrCode()
oObj:cSELLERCODE		:= HttpSession->CODVENERP
oObj:cCUSTOMERID		:= HttpSession->cCUSTOMERID
oObj:dDATEFROM			:= CToD( HttpPost->dDATEFROM )
oObj:dDATETO			:= CToD( HttpPost->dDATETO )
oObj:cTYPEOFPRODUCT		:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cTYPEOFPRODUCT
oObj:cGROUPOFPRODUCT	:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cGROUPOFPRODUCT
oObj:cPRODUCTCODE		:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cPRODUCTCODE
oObj:nCURRENCY			:= HttpPost->nCURRENCY
oObj:cQUERYADDWHERE		:= ""

//cUSERCODE,cSELLERCODE,cCUSTOMERID,dDATEFROM,dDATETO,cTYPEOFPRODUCT,cGROUPOFPRODUCT,cPRODUCTCODE,nCURRENCY,cQUERYADDWHERE
If oObj:GETPRODUCTSALESINVOICE()
	aWebCols := {}

	If Len( oObj:oWSGETPRODUCTSALESINVOICERESULT:oWSPRODUCTSUMMARY ) > 0
		If ExistBlock( "PEV064" )
			aWebCols := ExecBlock( "PEV064", .F., .F., { 6 } )
		Else
			AAdd( aWebCols, "DESCRIPTION" )
			AAdd( aWebCols, "VALUE" )
		Endif

		nTam := Len( oObj:oWSGETPRODUCTSALESINVOICERESULT:oWSPRODUCTSUMMARY )

		GridHeader( HttpSession->PWSV064INFO[6]			,;
					HttpSession->PWSV061HEADER[3][1]	,;
					aWebCols )
		
		GridLinesEx( { 	HttpSession->PWSV064INFO[6]			,;
						HttpSession->PWSV061HEADER[3][1]	,;
						oObj:oWSGETPRODUCTSALESINVOICERESULT:oWSPRODUCTSUMMARY[nTam]:oWSVALUESUMMARY:oWSGENERICSTRUCT,;
						aWebCols							,;
						.F.									,;
						"A"									,;
						NIL									,;
						0 } )
	Else
		If ExistBlock( "PEV064" )
			aWebCols := ExecBlock( "PEV064", .F., .F., { 6 } )
		Endif

		GridHeader( HttpSession->PWSV064INFO[6]			,;
					HttpSession->PWSV061HEADER[4][1]	,;
					aWebCols )
		
		GridLinesEx( { 	HttpSession->PWSV064INFO[6]						,;
						HttpSession->PWSV061HEADER[4][1]				,;
						oObj:oWSGETPRODUCTSALESINVOICERESULT:oWSPRODUCTSUMMARY	,;
						aWebCols										,;
						.F.												,;
						"A"												,;
						NIL												,;
						0 } )
	Endif
Else
	Return PWSHtmlAlert( "", STR0003		,;		//Atencao
						 "", "W_PWSV061.APW" )
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVendas por produtos no periodoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObj:cUSERCODE			:= GetUsrCode()
oObj:cSELLERCODE		:= HttpSession->CODVENERP
oObj:cCUSTOMERID		:= HttpSession->cCUSTOMERID
oObj:dDATEFROM			:= CToD( HttpPost->dDATEFROM )
oObj:dDATETO			:= CToD( HttpPost->dDATETO )
oObj:cTYPEOFPRODUCT		:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cTYPEOFPRODUCT
oObj:cGROUPOFPRODUCT	:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cGROUPOFPRODUCT
oObj:cPRODUCTCODE		:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cPRODUCTCODE
oObj:nCURRENCY			:= HttpPost->nCURRENCY
oObj:cQUERYADDWHERE		:= ""

//cUSERCODE,cSELLERCODE,cCUSTOMERID,dDATEFROM,dDATETO,cTYPEOFPRODUCT,cGROUPOFPRODUCT,cPRODUCTCODE,nCURRENCY,cQUERYADDWHERE
If oObj:GETPRODUCTSALESORDER()
	aWebCols := {}

	If Len( oObj:oWSGETPRODUCTSALESORDERRESULT:oWSPRODUCTSUMMARY ) > 0
		If ExistBlock( "PEV064" )
			aWebCols := ExecBlock( "PEV064", .F., .F., { 7 } )
		Else
			AAdd( aWebCols, "DESCRIPTION" )
			AAdd( aWebCols, "VALUE" )
		Endif

		nTam := Len( oObj:oWSGETPRODUCTSALESORDERRESULT:oWSPRODUCTSUMMARY )

		GridHeader( HttpSession->PWSV064INFO[7]			,;
					HttpSession->PWSV061HEADER[3][1]	,;
					aWebCols )
		
		GridLinesEx( { 	HttpSession->PWSV064INFO[7]			,;
						HttpSession->PWSV061HEADER[3][1]	,;
						oObj:oWSGETPRODUCTSALESORDERRESULT:oWSPRODUCTSUMMARY[nTam]:oWSVALUESUMMARY:oWSGENERICSTRUCT,;
						aWebCols							,;
						.F.									,;
						"A"									,;
						NIL									,;
						0 } )
	Else
		If ExistBlock( "PEV064" )
			aWebCols := ExecBlock( "PEV064", .F., .F., { 7 } )
		Endif

		GridHeader( HttpSession->PWSV064INFO[7]			,;
					HttpSession->PWSV061HEADER[4][1]	,;
					aWebCols )
		
		GridLinesEx( { 	HttpSession->PWSV064INFO[7]						,;
						HttpSession->PWSV061HEADER[4][1]				,;
						oObj:oWSGETPRODUCTSALESORDERRESULT:oWSPRODUCTSUMMARY,;
						aWebCols										,;
						.F.												,;
						"A"												,;
						NIL												,;
						0 } )
	Endif
Else
	Return PWSHtmlAlert( "", STR0003		,;		//Atencao
						 "", "W_PWSV061.APW" )
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDevolucoes no periodoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObj:cUSERCODE			:= GetUsrCode()
oObj:cSELLERCODE		:= HttpSession->CODVENERP
oObj:cCUSTOMERID		:= HttpSession->cCUSTOMERID
oObj:dDATEFROM			:= CToD( HttpPost->dDATEFROM )
oObj:dDATETO			:= CToD( HttpPost->dDATETO )
oObj:cTYPEOFPRODUCT		:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cTYPEOFPRODUCT
oObj:cGROUPOFPRODUCT	:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cGROUPOFPRODUCT
oObj:cPRODUCTCODE		:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cPRODUCTCODE
oObj:nCURRENCY			:= HttpPost->nCURRENCY

//cUSERCODE,cSELLERCODE,cCUSTOMERID,dDATEFROM,dDATETO,cTYPEOFPRODUCT,cGROUPOFPRODUCT,cPRODUCTCODE,nCURRENCY
If oObj:GETRETURNINVOICE()
	aWebCols := {}

	If ExistBlock( "PEV064" )
		aWebCols := ExecBlock( "PEV064", .F., .F., { 8 } )
	Else
		AAdd( aWebCols, "DESCRIPTION" )
		AAdd( aWebCols, "VALUE" )
	Endif

	GridHeader( HttpSession->PWSV064INFO[8]			,;
				HttpSession->PWSV061HEADER[3][1]	,;
				aWebCols )
	
	GridLinesEx( { 	HttpSession->PWSV064INFO[8]						,;
					HttpSession->PWSV061HEADER[3][1]				,;
					oObj:oWSGETRETURNINVOICERESULT:oWSGENERICSTRUCT	,;
					aWebCols										,;
					.F.												,;
					"A"												,;
					NIL												,;
					0 } )
Else
	Return PWSHtmlAlert( "", STR0003		,;	//Atencao
						 "", "W_PWSV061.APW" )
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFaturamento no periodoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObj:cUSERCODE			:= GetUsrCode()
oObj:cSELLERCODE		:= HttpSession->CODVENERP
oObj:cCUSTOMERID		:= HttpSession->cCUSTOMERID
oObj:dDATEFROM			:= CToD( HttpPost->dDATEFROM )
oObj:dDATETO			:= CToD( HttpPost->dDATETO )
oObj:cTYPEOFPRODUCT		:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cTYPEOFPRODUCT
oObj:cGROUPOFPRODUCT	:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cGROUPOFPRODUCT
oObj:cPRODUCTCODE		:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cPRODUCTCODE
oObj:nCURRENCY			:= HttpPost->nCURRENCY
oObj:cQUERYADDWHERE		:= ""

//cUSERCODE,cSELLERCODE,cCUSTOMERID,dDATEFROM,dDATETO,cTYPEOFPRODUCT,cGROUPOFPRODUCT,cPRODUCTCODE,nCURRENCY,cQUERYADDWHERE
If oObj:GETSALESINVOICE()
	aWebCols := {}

	If ExistBlock( "PEV064" )
		aWebCols := ExecBlock( "PEV064", .F., .F., { 9 } )
	Else
		AAdd( aWebCols, "DESCRIPTION" )
		AAdd( aWebCols, "VALUE" )
	Endif

	GridHeader( HttpSession->PWSV064INFO[9]			,;
				HttpSession->PWSV061HEADER[3][1]	,;
				aWebCols )
	
	GridLinesEx( { 	HttpSession->PWSV064INFO[9]						,;
					HttpSession->PWSV061HEADER[3][1]				,;
					oObj:oWSGETSALESINVOICERESULT:oWSGENERICSTRUCT	,;
					aWebCols										,;
					.F.												,;
					"A"												,;
					NIL												,;
					0 } )
Else
	Return PWSHtmlAlert( "", STR0003		,;	//Atencao
						 "", "W_PWSV061.APW" )
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVendas no periodoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObj:cUSERCODE			:= GetUsrCode()
oObj:cSELLERCODE		:= HttpSession->CODVENERP
oObj:cCUSTOMERID		:= HttpSession->cCUSTOMERID
oObj:dDATEFROM			:= CToD( HttpPost->dDATEFROM )
oObj:dDATETO			:= CToD( HttpPost->dDATETO )
oObj:cTYPEOFPRODUCT		:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cTYPEOFPRODUCT
oObj:cGROUPOFPRODUCT	:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cGROUPOFPRODUCT
oObj:cPRODUCTCODE		:= HttpSession->PWSV062RESULT[1][Val( HttpPost->cProduto )]:cPRODUCTCODE
oObj:nCURRENCY			:= HttpPost->nCURRENCY
oObj:cQUERYADDWHERE		:= ""

//cUSERCODE,cSELLERCODE,cCUSTOMERID,dDATEFROM,dDATETO,cTYPEOFPRODUCT,cGROUPOFPRODUCT,cPRODUCTCODE,nCURRENCY,cQUERYADDWHERE
If oObj:GETSALESORDER()
	aWebCols := {}

	If ExistBlock( "PEV064" )
		aWebCols := ExecBlock( "PEV064", .F., .F., { 10 } )
	Else
		AAdd( aWebCols, "DESCRIPTION" )
		AAdd( aWebCols, "VALUE" )
	Endif

	GridHeader( HttpSession->PWSV064INFO[10]		,;
				HttpSession->PWSV061HEADER[3][1]	,;
				aWebCols )
	
	GridLinesEx( { 	HttpSession->PWSV064INFO[10]					,;
					HttpSession->PWSV061HEADER[3][1]				,;
					oObj:oWSGETSALESORDERRESULT:oWSGENERICSTRUCT	,;
					aWebCols										,;
					.F.												,;
					"A"												,;
					NIL												,;
					0 } )
Else
	Return PWSHtmlAlert( "", STR0003		,;		//Atencao
						 "", "W_PWSV061.APW" )
Endif

cHtml += ExecInPage( "PWSV064" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSV064A  บAutor  ณLuiz Felipe Couto    บ Data ณ  11/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela com a as estatisticas de venda.                        บฑฑ
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
Web Function PWSV064A()

Local cHtml 	:= ""					//Pagina WEB

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSV064A" )

WEB EXTENDED END

Return cHtml
