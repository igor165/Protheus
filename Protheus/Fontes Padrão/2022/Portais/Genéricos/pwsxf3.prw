#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSXF3.CH"     


#DEFINE HEADER_PRODUTO				1
#DEFINE HEADER_TIPO_PRODUTO			2
#DEFINE HEADER_GRUPO_PRODUTO		3
#DEFINE HEADER_CLIENTE				4
#DEFINE HEADER_TRANSPORTADORA		5
#DEFINE HEADER_PEDIDO				6
#DEFINE HEADER_TAXA					7
#DEFINE HEADER_COND_PAGAMENTO		8
#DEFINE HEADER_PRIORIDADE			9
#DEFINE HEADER_ESTADO				10
#DEFINE HEADER_CARGO				   11
#DEFINE HEADER_GRUPO				   12
#DEFINE HEADER_DEPARTAMENTO			13
#DEFINE HEADER_UM					14
#DEFINE HEADER_PROJETO				15
#DEFINE HEADER_RECURSOS				16
#DEFINE HEADER_TAREFA				17
#DEFINE HEADER_OCORRENCIA			18
#DEFINE HEADER_EQUIPE 				19
#DEFINE HEADER_PROSPECT				20 
#DEFINE HEADER_PROCESS				21     
#DEFINE HEADER_AVALIADOR			22
#DEFINE HEADER_IDNUMBERS			23
#DEFINE HEADER_VENDEDOR				24
#DEFINE HEADER_PARCEIRO				25
#DEFINE HEADER_CONTATO				26
#DEFINE HEADER_CURSO				   27
#DEFINE HEADER_ENTIDADE				28
#DEFINE HEADER_RHCARGO           29
#DEFINE HEADER_FORNECEDOR				30
#DEFINE HEADER_AREA					31

#DEFINE NUM_HEADERS					31

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммямммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPWSXF*    ╨Autor  ЁLuiz Felipe Couto    ╨ Data Ё  24/03/05   ╨╠╠
╠╠лммммммммммьммммммммммймммммммомммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Este fonte possui as funcionalidades relacionado aos        ╨╠╠
╠╠╨          Ё F3 do sistema utilizando WS.                                ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ParametrosЁ                                                             ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       ЁPortal Protheus                                              ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╨Analista  Ё Data/Bops/Ver ЁManutencao Efetuada                      	   ╨╠╠
╠╠лммммммммммьммммммммяммммммьммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠хммммммммммоммммммммоммммммоммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммямммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPWSXF3000 ╨Autor  ЁLuiz Felipe Couto    ╨ Data Ё  24/03/05   ╨╠╠
╠╠лммммммммммьммммммммммймммммммомммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Retorna os dados do F3 do sistema.                          ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ParametrosЁ                                                             ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       ЁPortal Protheus                                              ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╨Analista  Ё Data/Bops/Ver ЁManutencao Efetuada                      	   ╨╠╠
╠╠лммммммммммьммммммммяммммммьммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Cleber M. Ё17/11/06Ё111492Ё-Inclusao de busca F3 p/ Prospects.		   ╨╠╠
╠╠╨Joeudo S.FЁ06/07/07Ё116560Ё-Implementada a opcao BRWAVALIAD p/ consulta ╨╠╠
╠╠╨          Ё        Ё      ЁF3 ao campo Avaliador						   ╨╠╠
╠╠╨Norbert W.Ё06/08/07Ё126096Ё-Implementada a opcao BRWIDNUMBER p/ consulta╨╠╠
╠╠╨          Ё        Ё      ЁF3 aos numeros de Pedido/Licitacao no Portal.╨╠╠
╠╠╨          Ё        Ё      Ё-Ordenacao dos pedidos de venda pelo numero  ╨╠╠
╠╠╨          Ё        Ё      Ёda licitacao na opcao BRWIDNUMBER.           ╨╠╠
╠╠╨Norbert W.Ё10/08/07Ё126152Ё-Adaptacao na ordenacao pelo pedido(IdNumber)╨╠╠
╠╠╨          Ё        Ё      Ёpara permitir a pesquisa de pedidos pelo por-╨╠╠
╠╠╨          Ё        Ё      Ёtal do vendedor.                             ╨╠╠
╠╠╨MauricioMRЁ28/05/09Ё13245 Ё-Implementada recuperacao do curso/entidade  ╨╠╠
╠╠╨          Ё        Ё2009  Ёde entrada para filtrar curso/entidade       ╨╠╠
╠╠╨Renan B.  Ё26/11/14ЁTQXMZGЁAjuste para realizar a filtragem corretamente╨╠╠
╠╠╨          Ё        Ё	     Ёmesmo que haja mudanГa de pАgina.			   ╨╠╠
╠╠╨Renan B.  Ё01/07/15ЁTSNVN0ЁAjuste para realizar a filtragem cСdigo de   ╨╠╠
╠╠╨          Ё        Ё	     Ёcargos do currМculo de candidato corretamente╨╠╠
╠╠╨          Ё        Ё	     Ёmesmo que haja mudanГa de pАgina.			   ╨╠╠
╠╠хммммммммммоммммммммоммммммоммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Web Function PWSXF3000()

Local cHtml 		:= ""					//Pagina WEB
Local cQryAdd 		:= ""					//Query Add Where
Local nI 			:= 0					//Variavel de apoio
Local nTam 			:= 0					//Tamanho do Get - campos que serao apresentados na tela de F3
Local aGetTemp 		:= {}					//Array com os campos que serao apresentados na tela de F3 vindos pelo GET
Local aWebHeader 	:= {}					//Array com os campos que serao apresentados na tela de F3
Local oObj									//Objeto WS

WEB EXTENDED INIT cHtml START "InSite"

//зддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFaz um parse do HttpGet e coloca o resultado no arrayЁ
//юддддддддддддддддддддддддддддддддддддддддддддддддддддды
aGetTemp := ParseGets()

nTam := Len( aGetTemp[2] )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁPreenche o array de campos com os campos que sao enviados pelo GETЁ
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nI := 1 To nTam
	aAdd( aWebHeader, SubStr( aGetTemp[2][nI], 2 ) )
Next

//зддддддддддддддддддддддддддд©
//ЁArray para montagem da telaЁ
//юддддддддддддддддддддддддддды
HttpSession->PWSXF3INFO := {}

If Empty( HttpSession->PWSXF3HEADER )
	HttpSession->PWSXF3HEADER := Array(NUM_HEADERS)
EndIf

Do Case
	//зддддддддддддддддд©
	//ЁBusca de ProdutosЁ
	//юддддддддддддддддды
	Case HttpGet->F3Nome == "GETCATALOG"
		//здддддддддддддддддддддддддддддддддддд©
		//ЁInicializa o Objeto WS - WSMTPRODUCTЁ
		//юдддддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTPRODUCT"), WSMTPRODUCT():New() )
		WsChgUrl( @oObj, "MTPRODUCT.APW" )
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁHeader da estrutura PRODUCTVIEW - Produto                              Ё
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
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Empty( HttpSession->PWSXF3HEADER[HEADER_PRODUTO] )
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды
			oObj:cHEADERTYPE := "PRODUCTVIEW"

			//cHEADERTYPE
			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_PRODUTO] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//зддддддддддддд©
		//ЁPaginacao WEBЁ
		//юддддддддддддды
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		
		//зддддддддддддддддддддддддддддддд©
		//ЁParametros do metodo GETCATALOGЁ
		//юддддддддддддддддддддддддддддддды
		oObj:cUSERCODE			:= GetUsrCode()
		oObj:cPRODUCTCODELIKE	:= IIf( HttpGet->Tipo == "1", HttpGet->Busca, "" )
		oObj:cDESCRIPTIONLIKE	:= IIf( HttpGet->Tipo == "2", HttpGet->Busca, "" )
		oObj:nPAGELEN			:= 10
		oObj:nPAGEFIRST			:= ( Val( HttpGet->cPagina ) * 10 ) + 1
        oObj:cCUSTOMERID		:= IIf(!Empty(HttpSession->CODCLIERP), HttpSession->CODCLIERP, "")
        //Filtros exclusivos para inclusЦo de Pedido de Venda e OrГamentos no Portal do Vendedor
        oObj:cQUERYADDWHERE		:= IIF(!(Empty(HttpSession->PWSV044GRAVA)),"MV_PVCODPV",IIF(!(Empty(HttpSession->PWSV084GRAVA)),"MV_PVCODOC",""))

		//cUSERCODE,cTYPEOFPRODUCTIN,cGROUPOFPRODUCTIN,cPRODUCTCODELIKE,cDESCRIPTIONLIKE,nPAGELEN,nPAGEFIRST,cQUERYADDWHERE,cINDEXKEY,cCUSTOMERID
		If oObj:GETCATALOG()
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_PRODUTO][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO					, HttpSession->PWSXF3HEADER[HEADER_PRODUTO][1]	,;
							oObj:oWSGETCATALOGRESULT:oWSPRODUCTVIEW	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETCATALOGRESULT:oWSPRODUCTVIEW )
			
			If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//зддддддддддддддддддддддддд©
	//ЁBusca de Tipo de ProdutosЁ
	//юддддддддддддддддддддддддды
	Case HttpGet->F3Nome == "GETTYPEOFPRODUCT"
		//здддддддддддддддддддддддддддддддддд©
		//ЁInicializa Objeto WS - WSMTPRODUCTЁ
		//юдддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTPRODUCT"), WSMTPRODUCT():New() )
		WsChgUrl( @oObj, "MTPRODUCT.APW" )
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁHeader da estrutura PRODUCTVIEW - Produto                              Ё
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
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Empty( HttpSession->PWSXF3HEADER[HEADER_TIPO_PRODUTO] )
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды
			oObj:cHEADERTYPE := "PRODUCTVIEW"
		
			//cHEADERTYPE
			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_TIPO_PRODUTO] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf
		
		//зддддддддддддддддддддддддддддддддддддд©
		//ЁParametros do metodo GETTYPEOFPRODUCTЁ
		//юддддддддддддддддддддддддддддддддддддды
		oObj:cUSERCODE := GetUsrCode()

		//cUSERCODE
		If oObj:GETTYPEOFPRODUCT()
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_TIPO_PRODUTO][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO							, HttpSession->PWSXF3HEADER[HEADER_TIPO_PRODUTO][1]	,;
							oObj:oWSGETTYPEOFPRODUCTRESULT:oWSGENERICSTRUCT	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETTYPEOFPRODUCTRESULT:oWSGENERICSTRUCT )
			
			If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//зддддддддддддддддддддддддддд©
	//ЁBusca de Grupos de ProdutosЁ
	//юддддддддддддддддддддддддддды
	Case HttpGet->F3Nome == "GETGROUPOFPRODUCT"
		//зддддддддддддддддддддддддддддддддддддддддддд©
		//ЁInicializa o objeto WS - WSMTGROUPOFPRODUCTЁ
		//юддддддддддддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTGROUPOFPRODUCT"), WSMTGROUPOFPRODUCT():New() )
		WsChgUrl( @oObj,"MTGROUPOFPRODUCT.APW" )
		
		If Empty( HttpSession->PWSXF3HEADER[HEADER_GRUPO_PRODUTO] )
			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_GRUPO_PRODUTO] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf
		
		//зддддддддддддддддддддддддддддд©
		//ЁParametros do metodo GETGROUPЁ
		//юддддддддддддддддддддддддддддды
		oObj:cUSERCODE	:= GetUsrCode()

		//cUSERCODE,cINDEXKEY
		If oObj:GETGROUP()
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_GRUPO_PRODUTO][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO						, HttpSession->PWSXF3HEADER[HEADER_GRUPO_PRODUTO][1]	,;
							oObj:oWSGETGROUPRESULT:oWSGROUPOFPRODUCTVIEW, aWebHeader						,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETGROUPRESULT:oWSGROUPOFPRODUCTVIEW )
			
			If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//здддддддддддддддддддддддддддддд©
	//ЁBusca de Clientes por VendedorЁ
	//юдддддддддддддддддддддддддддддды
	Case HttpGet->F3Nome == "BRWCUSTOMER"
		//зддддддддддддддддддддддддддддддддддддддддд©
		//ЁInicializa Objeto WS - WSMTSELLERCUSTOMERЁ
		//юддддддддддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSELLERCUSTOMER"), WSMTSELLERCUSTOMER():New() )
		WsChgUrl( @oObj, "MTSELLERCUSTOMER.APW" )

		//зддддддддддддддддддддддддддддддддд©
		//ЁHeader da estrutura GENERICVIEW2 Ё
		//|- CODE        : Codigo do Cliente|
		//|- UNIT        : Loja do Cliente  |
		//|- DESCRIPTION : Nome do Cliente  |
		//юддддддддддддддддддддддддддддддддды
		If Empty( HttpSession->PWSXF3HEADER[HEADER_CLIENTE] )
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды
			oObj:cHEADERTYPE := "GENERICVIEW2"
		
			//cHEADERTYPE
			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_CLIENTE] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
				
				//Walk-around
				If Empty(oObj:oWSGETHEADERRESULT:oWSBRWHEADER)
					oObj:cHEADERTYPE := "GENERICVIEW2"	
					If oObj:BRWHEADER()
						HttpSession->PWSXF3HEADER[HEADER_CLIENTE] := { oObj:oWSBRWHEADERRESULT:oWSBRWHEADER }
					Else
						PWSGetWSError()
					EndIf
				EndIf
			Else
				PWSGetWSError()
			EndIf
		EndIf
		
		//зддддддддддддд©
		//ЁPaginacao WEBЁ
		//юддддддддддддды
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf

		//здддддддддддддддддддддддддддддддд©
		//ЁParametros do metodo BRWCUSTOMERЁ
		//юдддддддддддддддддддддддддддддддды
		oObj:cUSERCODE		:= GetUsrCode()
		oObj:cSELLERCODE	:= HttpSession->CODVENERP
		oObj:nPAGELEN		:= 10
		oObj:nPAGEFIRST		:= ( Val( HttpGet->cPagina ) * 10 ) + 1
		oObj:cNAMELIKE		:= IIf( HttpGet->Tipo == "1", HttpGet->Busca, "" )
		oObj:cNICKNAMELIKE	:= IIf( HttpGet->Tipo == "2", HttpGet->Busca, "" )
		oObj:cINDEXKEY		:= IIf( HttpGet->Tipo == "1", "A1_NOME", "A1_NREDUZ" )
		
		//cUSERCODE,cSELLERCODE,nPAGELEN,nPAGEFIRST,cNAMELIKE,cNICKNAMELIKE,cQUERYADDWHERE,cINDEXKEY
		If oObj:BRWCUSTOMER()
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_CLIENTE][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO						, HttpSession->PWSXF3HEADER[HEADER_CLIENTE][1]	,;
							oObj:oWSBRWCUSTOMERRESULT:oWSGENERICVIEW2	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWCUSTOMERRESULT:oWSGENERICVIEW2 )
			
	  		If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//здддддддддддддддддддддддд©
	//ЁBusca de TransportadorasЁ
	//юдддддддддддддддддддддддды
	Case HttpGet->F3Nome == "GETCARRIER"
		//здддддддддддддддддддддддддддддддддд©
		//ЁInicializa Objeto WS - WSMTCARRIERЁ
		//юдддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTCARRIER"), WSMTCARRIER():New() )
		WsChgUrl( @oObj, "MTCARRIER.APW" )

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁHeader da estrutura GENERICSTRUCT - Estrutura GenericaЁ
		//Ё- CODE        : Codigo                                Ё
		//Ё- DESCRIPTION : Descricao                             Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Empty( HttpSession->PWSXF3HEADER[HEADER_TRANSPORTADORA] )
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды
			oObj:cHEADERTYPE := "GENERICSTRUCT"
		
			//cHEADERTYPE
			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_TRANSPORTADORA] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//зддддддддддддд©
		//ЁPaginacao WEBЁ
		//юддддддддддддды
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		
		//зддддддддддддддддддддддддддддддд©
		//ЁParametros do metodo BRWCARRIERЁ
		//юддддддддддддддддддддддддддддддды
		oObj:cUSERCODE		:= GetUsrCode()
		oObj:nPAGELEN		:= 10
		oObj:nPAGEFIRST		:= ( Val( HttpGet->cPagina ) * 10 ) + 1
		oObj:cNAMELIKE		:= IIf( HttpGet->Tipo == "1", HttpGet->Busca, "" )
		oObj:cNICKNAMELIKE	:= IIf( HttpGet->Tipo == "2", HttpGet->Busca, "" )
		oObj:cQUERYADDWHERE	:= ""

		//cUSERCODE,nPAGELEN,nPAGEFIRST,cNAMELIKE,cNICKNAMELIKE,cQUERYADDWHERE,cINDEXKEY
		If oObj:BRWCARRIER()
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_TRANSPORTADORA][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO					, HttpSession->PWSXF3HEADER[HEADER_TRANSPORTADORA][1]	,;
							oObj:oWSBRWCARRIERRESULT:oWSGENERICVIEW	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWCARRIERRESULT:oWSGENERICVIEW )
			
			If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//зддддддддддддддддддддддддддддддд©
	//ЁBusca de Pedidos por FornecedorЁ
	//юддддддддддддддддддддддддддддддды
	Case HttpGet->F3Nome == "BRWPURCHASEORDER"
		//здддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁInicializa o objeto WS - WSMTSUPPLIERPURCHASEORDERЁ
		//юдддддддддддддддддддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIERPURCHASEORDER"), WSMTSUPPLIERPURCHASEORDER():New() )
		WsChgUrl( @oObj, "MTSUPPLIERPURCHASEORDER.APW" )

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁHeader da estrutura PURCHASEORDERHEADERVIEW - Cab. Pedido de VendaЁ
		//|- PURCHASEORDERID     : Codigo                                    |
		//|- SUPPLIER            : Fornecedor                                |
		//|- REGISTERDATE        : Data de Emissao                           |
		//|- CONTACT             : Contato                                   |
		//|- CURRENCY            : Moeda                                     |
		//|- CURRENCYRATE        : Taxa da Moeda                             |
		//|- DISCOUNTINCASCADE1  : Desconto 1                                |
		//|- DISCOUNTINCASCADE2  : Desconto 2                                |
		//|- DISCOUNTINCASCADE3  : Desconto 3                                |
		//|- PURCHASEORDERSTATUS : Status                                    |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Empty( HttpSession->PWSXF3HEADER[HEADER_PEDIDO] )
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды
			oObj:cHEADERTYPE := "PURCHASEORDERHEADERVIEW"
		
			//cHEADERTYPE
			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_PEDIDO] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//зддддддддддддддддддддддддддддддддддддд©
		//ЁParametros do metodo BRWPURCHASEORDERЁ
		//юддддддддддддддддддддддддддддддддддддды
		oObj:cUSERCODE			:= GetUsrCode()
		oObj:cSUPPLIER			:= HttpSession->CODFORERP
		oObj:dDELIVERYDATEFROM	:= IIf( !Empty( HttpGet->DtInicio ), CToD( HttpGet->DtInicio ), )
		oObj:dDELIVERYDATETO 	:= IIf( !Empty( HttpGet->DtFim ), CToD( HttpGet->DtFim ), )

		//cUSERCODE,cSUPPLIER,dDELIVERYDATEFROM,dDELIVERYDATETO,cQUERYADDWHERE
		If oObj:BRWPURCHASEORDER()
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_PEDIDO][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO										, HttpSession->PWSXF3HEADER[HEADER_PEDIDO][1]	,;
							oObj:oWSBRWPURCHASEORDERRESULT:oWSPURCHASEORDERHEADERVIEW	, aWebHeader									,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWPURCHASEORDERRESULT:oWSPURCHASEORDERHEADERVIEW )
			
			If !Empty( HttpGet->DtInicio ) .AND. !Empty( HttpGet->DtFim )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//здддддддддддддд©
	//ЁBusca de TaxasЁ
	//юдддддддддддддды
	Case HttpGet->F3Nome == "BRWTAXES"
		//зддддддддддддддддддддддддддддддддддддддддддд©
		//ЁInicializa o objeto WS - WSMTSELLERCUSTOMERЁ
		//юддддддддддддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTTAXES"), WSMTTAXES():New() )
		WsChgUrl( @oObj, "MTTAXES.APW" )

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁHeader da estrutura GENERICSTRUCT - Estrutura GenericaЁ
		//Ё- CODE        : Codigo                                Ё
		//Ё- DESCRIPTION : Descricao                             Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Empty( HttpSession->PWSXF3HEADER[HEADER_TAXA] )
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды
			oObj:cHEADERTYPE := "GENERICSTRUCT"
			
			//cHEADERTYPE
			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_TAXA] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		If oObj:BRWTAXES()
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_TAXA][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO					, HttpSession->PWSXF3HEADER[HEADER_TAXA][1]	,;
							oObj:oWSBRWTAXESRESULT:oWSGENERICSTRUCT	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWTAXESRESULT:oWSGENERICSTRUCT )
			
			If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//зддддддддддддддддддддддддддддддд©
	//ЁBusca de Condicoes de PagamentoЁ
	//юддддддддддддддддддддддддддддддды
	Case HttpGet->F3Nome == "BRWPAYMENTPLAN"
		//здддддддддддддддддддддддддддддддддддддд©
		//ЁInicializa Objeto WS - WSMTPAYMENTPLANЁ
		//юдддддддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTPAYMENTPLAN"), WSMTPAYMENTPLAN():New() )
		WsChgUrl( @oObj, "MTPAYMENTPLAN.APW" )

		If Empty( HttpSession->PWSXF3HEADER[HEADER_COND_PAGAMENTO] )
			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_COND_PAGAMENTO] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//зддддддддддддд©
		//ЁPaginacao WEBЁ
		//юддддддддддддды
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		
		//зддддддддддддддддддд©
		//ЁAdicao de Query ADDЁ
		//юддддддддддддддддддды
		If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
			If HttpGet->Tipo == "1"
				cQryAdd := "E4_CODIGO"
			Else
				cQryAdd := "E4_DESCRI"
			EndIf
			
			cQryAdd += " LIKE '%" + HttpGet->Busca + "%' "
		EndIf
		
		//зддддддддддддддддддддддддддддддддддд©
		//ЁParametros do metodo BRWPAYMENTPLANЁ
		//юддддддддддддддддддддддддддддддддддды
		oObj:nPAGELEN		:= 10
		oObj:nPAGEFIRST		:= ( Val( HttpGet->cPagina ) * 10 ) + 1
		oObj:cQUERYADDWHERE	:= cQryAdd
		
		//nPAGELEN,nPAGEFIRST,cQUERYADDWHERE
		If oObj:BRWPAYMENTPLAN()
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_COND_PAGAMENTO][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO							, HttpSession->PWSXF3HEADER[HEADER_COND_PAGAMENTO][1]	,;
							oObj:oWSBRWPAYMENTPLANRESULT:oWSPAYMENTPLANVIEW	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWPAYMENTPLANRESULT:oWSPAYMENTPLANVIEW )
			
			If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//здддддддддддддддддддддддддддддд©
	//ЁBusca de Prioridade de TarefasЁ
	//юдддддддддддддддддддддддддддддды
	Case HttpGet->F3Nome == "GETPRIORITY"
		//зддддддддддддддддддддддддддддддддддддддддд©
		//ЁInicializa o objeto WS - WSFTCUSTOMERTASKЁ
		//юддддддддддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSFTCUSTOMERTASK"), WSFTCUSTOMERTASK():New() )
		WsChgUrl( @oObj, "FTCUSTOMERTASK.APW" )

		//здддддддддддддддддддддддддддддддддддддддд©
		//ЁHeader da estrutura TASKVIEW - Tarefas  Ё
		//|- TASKID              : Codigo          |
		//|- SUBJECT             : Topico          |
		//|- STARTDATE           : Data de Inicio  |
		//|- ENDDATE             : Data de Fim     |
		//|- STATUSCODE          : Status          |
		//|- STATUSDESCRIPTION   : Desc. do Status |
		//|- PRIORITY            : Prioridade      |
		//|- PRIORITYDESCRIPTION : Desc. Prioridade|
		//|- PERCENTCOMPLETE     : Porc. Completa  |
		//|- NOTE                : Observacao      |
		//юдддддддддддддддддддддддддддддддддддддддды
		If Empty( HttpSession->PWSXF3HEADER[HEADER_PRIORIDADE] )
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды
			oObj:cHEADERTYPE := "TASKVIEW"
		
			//cHEADERTYPE
			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_PRIORIDADE] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf
		
		//здддддддддддддддддддддддддддд©
		//ЁParametros do metodo BRWTASKЁ
		//юдддддддддддддддддддддддддддды
		oObj:cUSERCODE		:= GetUsrCode()
		oObj:cCUSTOMERID	:= HttpSession->CODCLIERP
		oObj:dDATEFROM		:= IIf( !Empty( HttpGet->DtInicio ), CToD( HttpGet->DtInicio ), )
		oObj:dDATETO		:= IIf( !Empty( HttpGet->DtFim ), CToD( HttpGet->DtFim ), )

		//cUSERCODE,cCUSTOMERID,dDATEFROM,dDATETO,cQUERYADDWHERE,cINDEXKEY
		If oObj:BRWTASK()
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_PRIORIDADE][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO				, HttpSession->PWSXF3HEADER[HEADER_PRIORIDADE][1]	,;
							oObj:oWSBRWTASKRESULT:oWSTASKVIEW	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWTASKRESULT:oWSTASKVIEW )
			
			If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//здддддддддддддддд©
	//ЁBusca de EstadosЁ
	//юдддддддддддддддды
	Case HttpGet->F3Nome == "GETUF"
		//здддддддддддддддддддддддддддддддддддддддддддд©
		//ЁInicializa o objeto WS - WSCFGSTANDARDTABLESЁ
		//юдддддддддддддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGSTANDARDTABLES"), WSCFGSTANDARDTABLES():New() )
		WsChgUrl( @oObj, "CFGSTANDARDTABLES.APW" )

		//здддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁHeader da estrutura do Objeto WS WSCFGSTANDARDTABLESЁ
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Empty( HttpSession->PWSXF3HEADER[HEADER_ESTADO] )
			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_ESTADO] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf
		
		//зддддддддддддддддддддддддддддддддддддд©
		//ЁParametros do metodo GETSTANDARDTABLEЁ
		//юддддддддддддддддддддддддддддддддддддды
		oObj:cUSERCODE			:= GetUsrCode()
		oObj:cSTANDARDTABLECODE	:= "12"

		//cUSERCODE,cSTANDARDTABLECODE
		If oObj:GETSTANDARDTABLE()
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_ESTADO][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO							, HttpSession->PWSXF3HEADER[HEADER_ESTADO][1]	,;
							oObj:oWSGETSTANDARDTABLERESULT:oWSGENERICSTRUCT	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETSTANDARDTABLERESULT:oWSGENERICSTRUCT )
			
			If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//здддддддддддддддд©
	//ЁBusca de FornecЁ
	//юдддддддддддддддды
	Case HttpGet->F3Nome == "SUPPLIERCODE"
		//здддддддддддддддддддддддддддддддддддддддддддд©
		//ЁInicializa o objeto WS - WSMTSUPPLIER       Ё
		//юдддддддддддддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIER"), WSMTSUPPLIER():New() )
		WsChgUrl( @oObj, "MTSUPPLIER.APW" )
		
		If Empty( HttpSession->PWSXF3HEADER[HEADER_FORNECEDOR] )
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды
			oObj:cHEADERTYPE := "SUPPLIERVIEW"
		
			//cHEADERTYPE
			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_FORNECEDOR] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf
		oObj:cUSERCODE			:= GetUsrCode()
		If oObj:GetListSupplier()
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO	, HttpSession->PWSXF3HEADER[HEADER_FORNECEDOR][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддыADMIN
			
			
			GridLinesEx( { 	HttpSession->PWSXF3INFO										, HttpSession->PWSXF3HEADER[HEADER_FORNECEDOR][1]	,;
							oObj:oWSGETLISTSUPPLIERRESULT:OWSSUPPLIERVIEW	, aWebHeader									,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETLISTSUPPLIERRESULT:OWSSUPPLIERVIEW )
			
			If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
			//ExecInPage( "PWSXF3BUSCA" )
		Else
			PWSGetWSError()
		EndIf
	//зддддддддддддддд©
	//ЁBusca de CargosЁ
	//юддддддддддддддды
	Case HttpGet->F3Nome == "GETPOSITION"
		//зддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁInicializa o objeto WS - WSCRMCUSTOMERCONTACTЁ
		//юддддддддддддддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCRMCUSTOMERCONTACT"), WSCRMCUSTOMERCONTACT():New() )
		WsChgUrl( @oObj, "CRMCUSTOMERCONTACT.APW" )

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁHeader da estrutura GENERICSTRUCT - Estrutura GenericaЁ
		//Ё- CODE        : Codigo                                Ё
		//Ё- DESCRIPTION : Descricao                             Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Empty( HttpSession->PWSXF3HEADER[HEADER_CARGO] )
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды
			oObj:cHEADERTYPE := "GENERICSTRUCT"

			//cHEADERTYPE
			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_CARGO] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		If oObj:GETPOSITION()
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_CARGO][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO					, HttpSession->PWSXF3HEADER[HEADER_CARGO][1]	,;
							oObj:oWSGETPOSITIONRESULT:oWSGENERICVIEW, aWebHeader						,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETPOSITIONRESULT:oWSGENERICVIEW )
			
			If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//зддддддддддддддд©
	//ЁBusca de GruposЁ
	//юддддддддддддддды
	Case HttpGet->F3Nome == "GETGROUP"
		//зддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁInicializa o objeto WS - WSCRMCUSTOMERCONTACTЁ
		//юддддддддддддддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCRMCUSTOMERCONTACT"), WSCRMCUSTOMERCONTACT():New() )
		WsChgUrl( @oObj, "CRMCUSTOMERCONTACT.APW" )

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁHeader da estrutura GENERICSTRUCT - Estrutura GenericaЁ
		//Ё- CODE        : Codigo                                Ё
		//Ё- DESCRIPTION : Descricao                             Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Empty( HttpSession->PWSXF3HEADER[HEADER_GRUPO] )
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды
			oObj:cHEADERTYPE := "GENERICSTRUCT"

			//cHEADERTYPE
			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_GRUPO] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		If oObj:GETGROUP()
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_GRUPO][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO					, HttpSession->PWSXF3HEADER[HEADER_GRUPO][1]	,;
							oObj:oWSGETGROUPRESULT:oWSGENERICVIEW	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETGROUPRESULT:oWSGENERICVIEW )
			
			If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//здддддддддддддддддддддд©
	//ЁBusca de DepartamentosЁ
	//юдддддддддддддддддддддды
	Case HttpGet->F3Nome == "GETDEPARTMENT"
		//зддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁInicializa o objeto WS - WSCRMCUSTOMERCONTACTЁ
		//юддддддддддддддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCRMCUSTOMERCONTACT"), WSCRMCUSTOMERCONTACT():New())
		WsChgUrl( @oObj, "CRMCUSTOMERCONTACT.APW" )

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁHeader da estrutura GENERICSTRUCT - Estrutura GenericaЁ
		//Ё- CODE        : Codigo                                Ё
		//Ё- DESCRIPTION : Descricao                             Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Empty( HttpSession->PWSXF3HEADER[HEADER_DEPARTAMENTO] )
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды
			oObj:cHEADERTYPE := "GENERICSTRUCT"
			
			//cHEADERTYPE
			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_DEPARTAMENTO] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		If oObj:GETDEPARTMENT()
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_DEPARTAMENTO][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO						, HttpSession->PWSXF3HEADER[HEADER_DEPARTAMENTO][1]	,;
							oObj:oWSGETDEPARTMENTRESULT:oWSGENERICVIEW	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETDEPARTMENTRESULT:oWSGENERICVIEW )
			
			If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//здддддддддддддддддддддд©
	//ЁBusca de DepartamentosЁ
	//юдддддддддддддддддддддды
	Case HttpGet->F3Nome == "BRWMEASUREUNIT"
		//зддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁInicializa o objeto WS - WSCRMCUSTOMERCONTACTЁ
		//юддддддддддддддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSQTMEASUREUNIT"), WSQTMEASUREUNIT():New() )
		WsChgUrl( @oObj, "QTMEASUREUNIT.APW" )

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁHeader da estrutura Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Empty( HttpSession->PWSXF3HEADER[HEADER_UM] )
			//здддддддддддддддддддддддддддддд©
			//cHEADERTYPE
			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_UM] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		If oObj:BRWMEASUREUNIT()
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_UM][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO							, HttpSession->PWSXF3HEADER[HEADER_UM][1]	,;
							oObj:oWSBRWMEASUREUNITRESULT:oWSMEASUREUNITVIEW	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWMEASUREUNITRESULT:oWSMEASUREUNITVIEW )
			
			If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf
	Case Alltrim(HttpGet->F3Nome) == "GETPROJECT"
		//здддддддддддддддддддддддддддддддддддд©
		//ЁInicializa o Objeto WS - WSMTPROJECTЁ
		//юдддддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSPMSREPORT"), WSPmsReport():New() )
		WsChgUrl( @oObj, "PMSREPORT.APW" )
		
		If Empty( HttpSession->PWSXF3HEADER[HEADER_PROJETO] )
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды
			oObj:cHeaderType := "PROJECTLISTVIEW"
			//cHEADERTYPE
			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_PROJETO] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//зддддддддддддд©
		//ЁPaginacao WEBЁ
		//юддддддддддддды
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		//зддддддддддддддддддд©
		//ЁAdicao de Query ADDЁ
		//юддддддддддддддддддды
		If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
			cQryAdd := ""
			If HttpGet->Tipo == "1"
				cQryAdd := "AF8_PROJET"
			Else
				cQryAdd := "AF8_DESCRI"
			EndIf
			#IFDEF TOP 
				cQryAdd += " LIKE '%" + HttpGet->Busca + "%' "
			#ELSE
				cQryAdd := "'"+Alltrim(HttpGet->Busca)+"'" + "$"+cQryAdd			
			#ENDIF
		EndIf                                
		                 
		If Empty (cQryAdd)
			cQryAdd := "AF8_ENCPRJ <> '1'"
		Else
			cQryAdd += "AND AF8_ENCPRJ <> '1'"
		EndIf	 	
		
		oObj:cQryAdd  	:= cQryAdd
		
		//зддддддддддддддддддддддддддддддд©
		//ЁParametros do metodo GETCATALOGЁ
		//юддддддддддддддддддддддддддддддды
		oObj:cUSERCODE				:= GtPtUsrCod()[1]
		oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
		oObj:dDATEINITIAL			:= Ctod('')
		oObj:dDATEFINAL			:= Date()+(365)*30
		oObj:cPROJECTINITIAL		:= ' '
		oObj:cPROJECTFINAL		:= 'zzzzzzzzzzzzzzzzzzzz'
		oObj:nPAGELEN				:= 10
		oObj:nPAGEFIRST			:= ( Val( HttpGet->cPagina ) * 10 ) + 1

		//cUSERCODE,cTYPEOFPRODUCTIN,cGROUPOFPRODUCTIN,cPRODUCTCODELIKE,cDESCRIPTIONLIKE,nPAGELEN,nPAGEFIRST,cQUERYADDWHERE,cINDEXKEY
		If oObj:GetProjectList() 
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_PROJETO][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO					, HttpSession->PWSXF3HEADER[HEADER_PROJETO][1]	,;
							oObj:oWSGETPROJECTLISTRESULT:oWSPROJECTLISTVIEW	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETPROJECTLISTRESULT:oWSPROJECTLISTVIEW )
			
			If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf
	Case Alltrim(HttpGet->F3Nome) == "GETRESOURCE"
		//здддддддддддддддддддддддддддддддддддд©
		//ЁInicializa o Objeto WS - WSMTPROJECTЁ
		//юдддддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSPMSREPORT"), WSPmsReport():New() )
		WsChgUrl( @oObj, "PMSREPORT.APW" )
		
		If Empty( HttpSession->PWSXF3HEADER[HEADER_RECURSOS] )
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды
			oObj:cHeaderType := "RESOURCEVIEW"
			//cHEADERTYPE
			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_RECURSOS] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()                 	
			EndIf
		EndIf

		//зддддддддддддд©
		//ЁPaginacao WEBЁ
		//юддддддддддддды
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		//зддддддддддддддддддд©
		//ЁAdicao de Query ADDЁ
		//юддддддддддддддддддды         
		
		If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
			cQryAdd := ""
			If HttpGet->Tipo == "1"
				cQryAdd := "AE8_RECURS"
			Else
				cQryAdd := "AE8_DESCRI"
			EndIf
			#IFDEF TOP 
				cQryAdd += " LIKE '%" + alltrim(HttpGet->Busca) + "%' "
			#ELSE
				cQryAdd := "'"+Alltrim(HttpGet->Busca)+"'" + "$"+cQryAdd			
			#ENDIF
		EndIf                                   

		oObj:cQryAdd   	:= cQryAdd
		
		//зддддддддддддддддддддддддддддддд©
		//ЁParametros do metodo GETCATALOGЁ
		//юддддддддддддддддддддддддддддддды
		oObj:cUSERCODE				:= GtPtUsrCod()[1]
		oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
		oObj:cRESOURCEINITIAL	:= ' '
		oObj:cRESOURCEFINAL		:= 'zzzzzzzzzzzzzzzzzzzz'
		oObj:nPAGELEN				:= 10
		oObj:nPAGEFIRST			:= ( Val( HttpGet->cPagina ) * 10 ) + 1

		//cUSERCODE,cTYPEOFPRODUCTIN,cGROUPOFPRODUCTIN,cPRODUCTCODELIKE,cDESCRIPTIONLIKE,nPAGELEN,nPAGEFIRST,cQUERYADDWHERE,cINDEXKEY
		If oObj:GetResourceList() 
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_RECURSOS][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO					, HttpSession->PWSXF3HEADER[HEADER_RECURSOS][1]	,;
							oObj:oWSGETRESOURCELISTRESULT:oWSRESOURCEVIEW	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETRESOURCELISTRESULT:oWSRESOURCEVIEW )
			
			If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	Case Alltrim(HttpGet->F3Nome) == "GETTASK"
		//здддддддддддддддддддддддддддддддддддд©
		//ЁInicializa o Objeto WS - WSMTPROJECTЁ
		//юдддддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSPMSREPORT"), WSPmsReport():New() )
		WsChgUrl( @oObj, "PMSREPORT.APW" )
		
		If Empty( HttpSession->PWSXF3HEADER[HEADER_TAREFA] )
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды
			oObj:cHeaderType := "GANTTTASKVIEW"
			//cHEADERTYPE
			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_TAREFA] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//зддддддддддддд©
		//ЁPaginacao WEBЁ
		//юддддддддддддды
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		//зддддддддддддддддддд©
		//ЁAdicao de Query ADDЁ
		//юддддддддддддддддддды
		If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
			cQryAdd := ""
			If HttpGet->Tipo == "1"
				cQryAdd := "AF9_TAREFA"
			Else
				cQryAdd := "AF9_DESCRI"
			EndIf
			#IFDEF TOP 
				cQryAdd += " LIKE '%" + HttpGet->Busca + "%' "
			#ELSE
				cQryAdd := "'"+Alltrim(HttpGet->Busca)+"'" + "$"+cQryAdd			
			#ENDIF
		EndIf
		oObj:cQryAdd   	:= cQryAdd
		
		//зддддддддддддддддддддддддддддддд©
		//ЁParametros do metodo GETCATALOGЁ
		//юддддддддддддддддддддддддддддддды
		oObj:cUSERCODE				:= GtPtUsrCod()[1]
		oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
		oObj:nPAGELEN				:= 10
		oObj:nPAGEFIRST			:= ( Val( HttpGet->cPagina ) * 10 ) + 1
		If Empty(HTTPGET->cProjectCode).And.Empty(HttpSession->cProjectCode)
			HttpSession->cLinkErro	:= ""
			HttpSession->cTitErro	:= STR0001 //"Aviso"
			HttpSession->cBotaoErro	:= ""
			HttpSession->nNewWin	:= 0
			HttpSession->cErro		:= STR0002 //"Por favor informe o projeto"
			cHtml 					:= ExecInPage( "PWSP001" )
		Else                                                                 
			If !Empty(HTTPGET->cProjectCode)
				HttpSession->cProjectCode		:= HTTPGET->cProjectCode
			Endif
			//cUSERCODE,cTYPEOFPRODUCTIN,cGROUPOFPRODUCTIN,cPRODUCTCODELIKE,cDESCRIPTIONLIKE,nPAGELEN,nPAGEFIRST,cQUERYADDWHERE,cINDEXKEY
			oObj:cPROJECTCODE  		:= HttpSession->cProjectCode
			If oObj:GetTaskList() 
				//здддддддддддддддддддддддддддддддддддддддддддддддддд©
				//ЁFuncao de montagem da descricao dos campos da telaЁ
				//юдддддддддддддддддддддддддддддддддддддддддддддддддды
				GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_TAREFA][1], aWebHeader )
	
				//зддддддддддддддддддддддддддддддддддддд©
				//ЁFuncao de montagem dos campos da telaЁ
				//юддддддддддддддддддддддддддддддддддддды
				GridLinesEx( { 	HttpSession->PWSXF3INFO					, HttpSession->PWSXF3HEADER[HEADER_TAREFA][1]	,;
								oObj:oWSGETTASKLISTRESULT:oWSGANTTTASKVIEW	, aWebHeader						,;
								.F., "A",, 0 } )
				
				//здддддддддддддддддддддддддддддддддд©
				//ЁScript para abertura da tela de F3Ё
				//юдддддддддддддддддддддддддддддддддды
				HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETTASKLISTRESULT:oWSGANTTTASKVIEW )
				
				If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
					Return ExecInPage( "PWSXF3GRID" )
				EndIf
			Else
				PWSGetWSError()
			EndIf
	   Endif
	Case Alltrim(HttpGet->F3Nome) == "GETOCORRENCE"
		//здддддддддддддддддддддддддддддддддддд©
		//ЁInicializa o Objeto WS - WSMTPROJECTЁ
		//юдддддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSPMSREPORT"), WSPmsReport():New() )
		WsChgUrl( @oObj, "PMSREPORT.APW" )
		
		If Empty( HttpSession->PWSXF3HEADER[HEADER_OCORRENCIA] )
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды
			oObj:cHeaderType := "OCORRENCEVIEW"
			//cHEADERTYPE
			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_OCORRENCIA] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//зддддддддддддд©
		//ЁPaginacao WEBЁ
		//юддддддддддддды
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		//зддддддддддддддддддд©
		//ЁAdicao de Query ADDЁ
		//юддддддддддддддддддды
		If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
			cQryAdd := ""
			If HttpGet->Tipo == "1"
				cQryAdd := "AE7_CODIGO"
			Else
				cQryAdd := "AE7_DESCRI"
			EndIf
			#IFDEF TOP 
				cQryAdd += " LIKE '%" + HttpGet->Busca + "%' "
			#ELSE
				cQryAdd := "'"+Alltrim(HttpGet->Busca)+"'" + "$"+cQryAdd			
			#ENDIF
		EndIf
		oObj:cQryAdd   	:= cQryAdd
		
		//зддддддддддддддддддддддддддддддд©
		//ЁParametros do metodo GETCATALOGЁ
		//юддддддддддддддддддддддддддддддды
		oObj:cUSERCODE				:= GtPtUsrCod()[1]
		oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
		oObj:cOcorrenceInitial	:= ''
		oObj:cOcorrenceFinal		:= 'zz'		
		oObj:nPAGELEN				:= 10
		oObj:nPAGEFIRST			:= ( Val( HttpGet->cPagina ) * 10 ) + 1

		If oObj:GetOcorrenceList() 
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_OCORRENCIA][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO					, HttpSession->PWSXF3HEADER[HEADER_OCORRENCIA][1]	,;
							oObj:oWSGETOCORRENCELISTRESULT:oWSOCORRENCEVIEW	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETOCORRENCELISTRESULT:oWSOCORRENCEVIEW )
			
			If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//здддддддддддддддддддддддддддддд©
	//ЁBusca de todos os clientes    Ё
	//юдддддддддддддддддддддддддддддды
	Case HttpGet->F3Nome == "BRWALLCUSTOMER"
		//зддддддддддддддддддддддддддддддддддддддддд©
		//ЁInicializa Objeto WS - WSMTSELLERCUSTOMERЁ
		//юддддддддддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMtSystemCustomer"), WSMtSystemCustomer():New() )
		WsChgUrl( @oObj, "MTSYSTEMCUSTOMER.APW" )

		//зддддддддддддддддддддддддддддддддд©
		//ЁHeader da estrutura GENERICVIEW2 Ё
		//|- CODE        : Codigo do Cliente|
		//|- UNIT        : Loja do Cliente  |
		//|- DESCRIPTION : Nome do Cliente  |
		//юддддддддддддддддддддддддддддддддды
		If Empty( HttpSession->PWSXF3HEADER[HEADER_CLIENTE] )
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды
			oObj:cHEADERTYPE := "GENERICVIEW2"
		
			//cHEADERTYPE
			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_CLIENTE] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf
		
		//зддддддддддддд©
		//ЁPaginacao WEBЁ
		//юддддддддддддды
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf

		//здддддддддддддддддддддддддддддддд©
		//ЁParametros do metodo BRWCUSTOMERЁ
		//юдддддддддддддддддддддддддддддддды
		oObj:cUSERCODE			:= GetUsrCode()
		oObj:nPAGELEN			:= 10
		oObj:nPAGEFIRST	   		:= ( Val( HttpGet->cPagina ) * 10 ) + 1
		oObj:cNAMELIKE			:= IIf( HttpGet->Tipo == "1", HttpGet->Busca, "" )
		oObj:cNICKNAMELIKE 		:= IIf( HttpGet->Tipo == "2", HttpGet->Busca, "" )
		oObj:cINDEXKEY			:= IIf( HttpGet->Tipo == "1", "A1_NOME", "A1_NREDUZ" )
		
		//cUSERCODE,cSELLERCODE,nPAGELEN,nPAGEFIRST,cNAMELIKE,cNICKNAMELIKE,cQUERYADDWHERE,cINDEXKEY
		If oObj:BRWCUSTOMER()
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_CLIENTE][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO						, HttpSession->PWSXF3HEADER[HEADER_CLIENTE][1]	,;
							oObj:oWSBRWCUSTOMERRESULT:oWSGENERICVIEW2	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWCUSTOMERRESULT:oWSGENERICVIEW2 )
			
			If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf
	Case Alltrim(HttpGet->F3Nome) == "GETTEAM"
		//здддддддддддддддддддддддддддддддддддд©
		//ЁInicializa o Objeto WS - WSMTPROJECTЁ
		//юдддддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSPmsReport"), WSPmsReport():New())
		WsChgUrl( @oObj, "PMSREPORT.APW" )
		
		If Empty( HttpSession->PWSXF3HEADER[HEADER_EQUIPE] )
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды
			oObj:cHeaderType := "TEAMVIEW"
			//cHEADERTYPE
			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_EQUIPE] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()                 	
			EndIf
		EndIf

		//зддддддддддддд©
		//ЁPaginacao WEBЁ
		//юддддддддддддды
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		//зддддддддддддддддддд©
		//ЁAdicao de Query ADDЁ
		//юддддддддддддддддддды
		If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
			cQryAdd := ""
			If HttpGet->Tipo == "1"
				cQryAdd := "AED_EQUIP"
			Else
				cQryAdd := "AEA_DESCRI"
			EndIf
			#IFDEF TOP 
				cQryAdd += " LIKE '%" + HttpGet->Busca + "%' "
			#ELSE
				cQryAdd := "'"+Alltrim(HttpGet->Busca)+"'" + "$"+cQryAdd			
			#ENDIF
		EndIf
		oObj:cQryAdd   	:= cQryAdd
		
		//зддддддддддддддддддддддддддддддд©
		//ЁParametros do metodo GETCATALOGЁ
		//юддддддддддддддддддддддддддддддды
		oObj:cUSERCODE				:= GtPtUsrCod()[1]
		oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
		oObj:cTEAMINITIAL	:= ' '
		oObj:cTEAMFINAL		:= 'zzzzzzzzzzzzzzzzzzzz'
		oObj:nPAGELEN				:= 10
		oObj:nPAGEFIRST			:= ( Val( HttpGet->cPagina ) * 10 ) + 1

		//cUSERCODE,cTYPEOFPRODUCTIN,cGROUPOFPRODUCTIN,cPRODUCTCODELIKE,cDESCRIPTIONLIKE,nPAGELEN,nPAGEFIRST,cQUERYADDWHERE,cINDEXKEY
		If oObj:GetTeamList() 
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_EQUIPE][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO					, HttpSession->PWSXF3HEADER[HEADER_EQUIPE][1]	,;
							oObj:oWSGETTEAMLISTRESULT:oWSTEAMVIEW	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETTEAMLISTRESULT:oWSTEAMVIEW )
			
			If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//здддддддддддддддддддддд©
	//Ё  Busca de Prospects	 Ё
	//юдддддддддддддддддддддды
	Case HttpGet->F3Nome == "BRWPROSPECT"
		//зддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Inicializa o objeto WSCRMPROSPECT			  Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCRMPROSPECT"), WSCRMPROSPECT():New())
		WsChgUrl( @oObj, "CRMPROSPECT.APW" )

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁHeader da estrutura PROSPECTVIEW  					 Ё
		//Ё- PROSPECTCODE   	: Codigo Prospect                Ё
		//Ё- UNITPROSPECTCODE   : Loja Prospect                  Ё
		//Ё- NAME               : Nome Prospect                  Ё	
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Empty( HttpSession->PWSXF3HEADER[HEADER_PROSPECT] )
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды
			oObj:cHEADERTYPE := "PROSPECTVIEW"
			
			//cHEADERTYPE
			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_PROSPECT] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//зддддддддддддд©
		//ЁPaginacao WEBЁ
		//юддддддддддддды
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		
		//зддддддддддддддддддд©
		//ЁAdicao de Query ADDЁ
		//юддддддддддддддддддды
		If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
			If HttpGet->Tipo == "1"		//Nome 
				cQryAdd := "US_NOME"
			Else						//Nome Fantasia
				cQryAdd := "US_NREDUZ"
			EndIf
			
			#IFDEF TOP 
				cQryAdd += " LIKE '%" + HttpGet->Busca + "%' "
			#ELSE
				cQryAdd := "'"+Alltrim(HttpGet->Busca)+"'" + "$"+cQryAdd			
			#ENDIF			
		EndIf
		     
		//здддддддддддддддддддддддддддддддд©
		//ЁParametros do metodo BRWPROSPECTЁ
		//юдддддддддддддддддддддддддддддддды
		oObj:cUSERCODE		:= GetUsrCode()
		oObj:cSELLERCODE	:= HttpSession->CODVENERP
		oObj:cQUERYADDWHERE	:= cQryAdd 
		oObj:cINDEXKEY		:= "US_COD"		
	
		If oObj:BRWPROSPECT()
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_PROSPECT][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO						, HttpSession->PWSXF3HEADER[HEADER_PROSPECT][1]	,;
							oObj:oWSBRWPROSPECTRESULT:oWSPROSPECTVIEW	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWPROSPECTRESULT:oWSPROSPECTVIEW )
			
			If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
			PWSHTMLALERT( "", STR0001, PWSGetWSError(), "W_PWSV110.APW" ) //"Aviso"
		EndIf

	//здддддддддддддддддддддддд©
	//ЁBusca de Processos VendaЁ
	//юдддддддддддддддддддддддды
	Case HttpGet->F3Nome == "BRWPROCESS"
		//здддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Inicializa Objeto WS - WSMTSELLEROPPORTUNITY	 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSELLEROPPORTUNITY"), WSMTSELLEROPPORTUNITY():New() )
		WsChgUrl( @oObj, "MTSELLEROPPORTUNITY.APW" )

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Header da estrutura ProcessView 		   	    	 Ё
		//Ё - PROCESS     : Processo                             Ё
		//Ё - STAGE       : Estagio                              Ё
		//Ё - DESCRIPTION : Descricao                            Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Empty( HttpSession->PWSXF3HEADER[HEADER_PROCESS] )
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды
			oObj:cHEADERTYPE := "PROCESSVIEW"
		
			//cHEADERTYPE
			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_PROCESS] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//зддддддддддддд©
		//ЁPaginacao WEBЁ
		//юддддддддддддды
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		
		//зддддддддддддддддддддддддддддддд©
		//ЁParametros do metodo BRWPROCESSЁ
		//юддддддддддддддддддддддддддддддды
		oObj:cUSERCODE		:= GetUsrCode()
		oObj:cSELLERCODE	:= HttpSession->CODVENERP
		oObj:cINDEXKEY		:= ""

		//cUSERCODE,cSELLERCODE,cINDEXKEY
		If oObj:BRWPROCESS()
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_PROCESS][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO					,	HttpSession->PWSXF3HEADER[HEADER_PROCESS][1],;
							oObj:oWSBRWPROCESSRESULT:oWSPROCESSVIEW	,	aWebHeader									,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWPROCESSRESULT:oWSPROCESSVIEW )
			
			If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//зддддддддддддддддддддддддддд©
	//ЁBusca de Avaliado\AvaliadorЁ
	//юддддддддддддддддддддддддддды
	Case HttpGet->F3Nome == "BRWAVALIAD"     
		//здддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Inicializa Objeto WS - WSRHPERSONALDESENVPLAN	 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
		WsChgUrl( @oObj, "RHPERSONALDESENVPLAN.APW" )

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Header da estrutura USER 				   	    	 Ё   
		//Ё	- UserID		: Codigo do Usuario					 Ё
		//Ё - UserName		: Descricao do Usuario               Ё
		//Ё - UserMat       : Codigo do Centro de Custo          Ё
		//Ё - UserCC		: Codigo do Centro de Custo          Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды

		If Empty(HttpSession->PWSXF3HEADER[HEADER_AVALIADOR])    
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды
			
			oObj:cHEADERTYPE := "USER"
		   
			If oObj:GetHeaderRh()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_AVALIADOR] := { oObj:oWSGETHEADERRHRESULT:oWSBRWHEADER }    	
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//зддддддддддддд©
		//ЁPaginacao WEBЁ
		//юддддддддддддды
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		
		//зддддддддддддддддддддддддддддддд©
		//ЁParametros do metodo BRWPROCESSЁ
		//юддддддддддддддддддддддддддддддды              
		
		oObj:cUserCode		:=	GetUsrCode()  
		oObj:cParticipantId	:=	HttpSession->cParticipantId
		oObj:cFiltro		:= 	If(!Empty(HttpGet->Busca),HttpGet->Busca,"")
		oObj:nPage			:= 	Val(HttpGet->cPagina)


		//cUserCode,cParticipantId
		If oObj:ShowAllParticipant()
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды  
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_AVALIADOR][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO,;
							HttpSession->PWSXF3HEADER[HEADER_AVALIADOR][1],;
							oObj:oWSSHOWALLPARTICIPANTRESULT:oWSUSER,;
							aWebHeader,;
							.F.,;
							"A",;
							,;
							0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды     

			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSSHOWALLPARTICIPANTRESULT:oWSUSER )
			HttpSession->USR_SKIN := "images"
			//If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
			//If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
			If !Empty( HttpGet->Busca ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
	   		EndIf
		Else
	  		HttpSession->_HTMLERRO := { STR0003, STR0004, "javascript:window.close();"  } //"Dados enviados para Web Function InvАlidos"
			cHtml := ExecInPage("PWSAMSG")
		EndIf

	//здддддддддддддддддддддддд©
	//ЁBusca de Nr. de Pedidos Ё
	//юдддддддддддддддддддддддды
	Case HttpGet->F3Nome == "BRWIDNUMBER"
		//здддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Inicializa Objeto WS - WSMTCUSTOMERSALESORDER	 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддды
		If Type("HttpSession->PWSV042HEADER") == "A"
			oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSELLERSALESORDER"), WSMTSELLERSALESORDER():New() )
			WsChgURL( @oObj, "MTSELLERSALESORDER.APW" )
		Else
			oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTCUSTOMERSALESORDER"), WSMTCUSTOMERSALESORDER():New() )
			WsChgURL( @oObj, "MTCUSTOMERSALESORDER.APW" )
		EndIf

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Carrega header da estrutura SalesOrderHeaderView	 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Empty( HttpSession->PWSXF3HEADER[HEADER_IDNUMBERS] )
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды
			oObj:cHEADERTYPE := "SALESORDERHEADERVIEW"
		
			//cHEADERTYPE
			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_IDNUMBERS] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//зддддддддддддд©
		//ЁPaginacao WEBЁ
		//юддддддддддддды
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		
		//зддддддддддддддддддддддддддддддд©
		//ЁParametros do metodo BRWIDORDERЁ
		//юддддддддддддддддддддддддддддддды
		oObj:cUSERCODE		:= GetUsrCode()

		If Type("HttpSession->PWSV042HEADER") == "A"
			oObj:cSELLERCODE	:= HttpSession->CODVENERP
		Else
			oObj:cCUSTOMERID	:= HttpSession->CODCLIERP
		EndIf

		If !Empty( HttpGet->Busca  )
			oObj:cORDERID	:= HttpGet->Busca
		Else
			oObj:cORDERID	:= ""
		EndIf
		oObj:cQUERYADDWHERE	:= ""
		oObj:cINDEXKEY		:= ""
		oObj:nPAGELEN		:= 10
		oObj:nPAGEFIRST		:= ( Val( HttpGet->cPagina ) * 10 ) + 1

		//cUSERCODE,cCUSTOMERID,cORDERID,cQUERYADDWHERE,cINDEXKEY,nPAGELEN,nPAGEFIRST
		If oObj:BRWIDORDER()
		    
			//зддддддддддддддддддддддддддддддддддддддд©
			//ЁOrdena pedidos pelo numero da licitacaoЁ
			//юддддддддддддддддддддддддддддддддддддддды
			aSort(oObj:oWSBRWIDORDERRESULT:OWSSALESORDERHEADERVIEW,,,{|x,y| x:cBIDNUMBER < y:cBIDNUMBER })
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_IDNUMBERS][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO								,	HttpSession->PWSXF3HEADER[HEADER_IDNUMBERS][1],;
							oObj:oWSBRWIDORDERRESULT:oWSSALESORDERHEADERVIEW	,	aWebHeader									,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWIDORDERRESULT:oWSSALESORDERHEADERVIEW )
			
			If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf
				
	//здддддддддддддддддддддддд©
	//ЁBusca de Nr. de Pedidos Ё
	//юдддддддддддддддддддддддды
	Case HttpGet->F3Nome == "BRWSALESREP"

		//здддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Inicializa Objeto WS - WSMTCUSTOMERSALESORDER	 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSELLER"), WSMTSELLER():New() )
		WsChgURL( @oObj, "MTSELLER.APW" )

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Carrega header da estrutura SalesOrderHeaderView	 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Empty( HttpSession->PWSXF3HEADER[HEADER_VENDEDOR] )
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды
			oObj:cHEADERTYPE := "GENERICSTRUCT"

			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_VENDEDOR] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//зддддддддддддд©
		//ЁPaginacao WEBЁ
		//юддддддддддддды
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		
		//зддддддддддддддддддддддддддддддд©
		//ЁParametros do metodo BRWIDORDERЁ
		//юддддддддддддддддддддддддддддддды
		oObj:cUSERCODE		:= GetUsrCode()
		oObj:cSELLERCODE	:= HttpSession->CODVENERP

		If !Empty( HttpGet->Busca  )
			If HttpGet->Tipo == "1"
				oObj:cCODELIKE	:= HttpGet->Busca
				oObj:cNAMELIKE	:= ""
			Else
				oObj:cCODELIKE	:= ""
				oObj:cNAMELIKE	:= HttpGet->Busca
			EndIf				
		Else
			oObj:cCODELIKE	:= ""
			oObj:cNAMELIKE	:= ""
		EndIf
		oObj:cQUERYADDWHERE	:= ""
		oObj:cINDEXKEY		:= ""
		oObj:nPAGELEN		:= 10
		oObj:nPAGEFIRST		:= ( Val( HttpGet->cPagina ) * 10 ) + 1

		If oObj:BRWSELLER()
		    
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_VENDEDOR][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO								,	HttpSession->PWSXF3HEADER[HEADER_VENDEDOR][1],;
							oObj:oWSBRWSELLERRESULT:oWSGENERICSTRUCT			,	aWebHeader									,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWSELLERRESULT:oWSGENERICSTRUCT )
			
			If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf	


	//здддддддддддддддддддддддд©
	//ЁBusca de Parceiros (AC4)Ё
	//юдддддддддддддддддддддддды
	Case HttpGet->F3Nome == "BRWPARTNER"

		//здддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Inicializa Objeto WS - WSMTSELLEROPPORTUNITY	 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSELLEROPPORTUNITY"), WSMTSELLEROPPORTUNITY():New() )
		WsChgURL( @oObj, "MTSELLEROPPORTUNITY.APW" )

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Carrega header da estrutura GENERICSTRUCT			 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Empty( HttpSession->PWSXF3HEADER[HEADER_PARCEIRO] )
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды
			oObj:cHEADERTYPE := "GENERICSTRUCT"

			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_PARCEIRO] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//зддддддддддддд©
		//ЁPaginacao WEBЁ
		//юддддддддддддды
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		
		//зддддддддддддддддддддддддддддддд©
		//ЁParametros do metodo BRWPARTNERЁ
		//юддддддддддддддддддддддддддддддды
		oObj:cUSERCODE		:= GetUsrCode()
		oObj:cSELLERCODE	:= HttpSession->CODVENERP

		If !Empty( HttpGet->Busca  )
			If HttpGet->Tipo == "1"
				oObj:cCODELIKE	:= HttpGet->Busca
				oObj:cNAMELIKE	:= ""
			Else
				oObj:cCODELIKE	:= ""
				oObj:cNAMELIKE	:= HttpGet->Busca
			EndIf				
		Else
			oObj:cCODELIKE	:= ""
			oObj:cNAMELIKE	:= ""
		EndIf
		oObj:cQUERYADDWHERE	:= ""
		oObj:cINDEXKEY		:= ""
		oObj:nPAGELEN		:= 10
		oObj:nPAGEFIRST		:= ( Val( HttpGet->cPagina ) * 10 ) + 1

		If oObj:BRWPARTNER()
		    
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_PARCEIRO][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO								,	HttpSession->PWSXF3HEADER[HEADER_PARCEIRO][1],;
							oObj:oWSBRWPARTNERRESULT:oWSGENERICSTRUCT			,	aWebHeader									,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWPARTNERRESULT:oWSGENERICSTRUCT )
			
			If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf	


	//здддддддддддддддддддддддд©
	//ЁBusca de Contatos (SU5) Ё
	//юдддддддддддддддддддддддды
	Case HttpGet->F3Nome == "BRWIDCONTACT"

		//здддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Inicializa Objeto WS - WSMTSELLEROPPORTUNITY	 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддды
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSELLEROPPORTUNITY"), WSMTSELLEROPPORTUNITY():New() )
		WsChgURL( @oObj, "MTSELLEROPPORTUNITY.APW" )

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Carrega header da estrutura CONTACTVIEW  			 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Empty( HttpSession->PWSXF3HEADER[HEADER_CONTATO] )
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды
			oObj:cHEADERTYPE := "CONTACTVIEW"

			If oObj:GETHEADER()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_CONTATO] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//зддддддддддддд©
		//ЁPaginacao WEBЁ
		//юддддддддддддды
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		
		//зддддддддддддддддддддддддддддддддддд©
		//Ё Parametros do metodo BRWIDCONTACT Ё
		//юддддддддддддддддддддддддддддддддддды
		oObj:cUSERCODE		:= GetUsrCode()
		oObj:cSELLERCODE	:= HttpSession->CODVENERP

		If !Empty( HttpGet->Busca  )
			If HttpGet->Tipo == "1"
				oObj:cCODELIKE	:= HttpGet->Busca
				oObj:cNAMELIKE	:= ""
			Else
				oObj:cCODELIKE	:= ""
				oObj:cNAMELIKE	:= HttpGet->Busca
			EndIf				
		Else
			oObj:cCODELIKE	:= ""
			oObj:cNAMELIKE	:= ""
		EndIf
		oObj:cQUERYADDWHERE	:= ""
		oObj:cINDEXKEY		:= ""
		oObj:nPAGELEN		:= 10
		oObj:nPAGEFIRST		:= ( Val( HttpGet->cPagina ) * 10 ) + 1

		If oObj:BRWIDCONTACT()
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_CONTATO][1], aWebHeader )

			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO							,	HttpSession->PWSXF3HEADER[HEADER_CONTATO][1],;
							oObj:oWSBRWIDCONTACTRESULT:oWSCONTACTVIEW		,	aWebHeader									,;
							.F., "A",, 0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWIDCONTACTRESULT:oWSCONTACTVIEW )
			
			If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf	
	Case HttpGet->F3Nome == "BRWCOURSE"
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
		WsChgUrl( @oObj, "RHPERSONALDESENVPLAN.APW" )

		If Empty(HttpSession->PWSXF3HEADER[HEADER_CURSO])    
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды			
			oObj:cHEADERTYPE := "COURSE"
		   
			If oObj:GetHeaderRh()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_CURSO] := { oObj:oWSGETHEADERRHRESULT:oWSBRWHEADER }    	
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//зддддддддддддд©
		//ЁPaginacao WEBЁ
		//юддддддддддддды
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf

		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
		WsChgUrl( @oObj, "RHCURRICULUM.APW" )
		
		//зддддддддддддддддддддддддддддддд©
		//ЁParametros do metodo BRWCOURSE Ё
		//юддддддддддддддддддддддддддддддды              	
		//-- Recupera o curso selecionado na chamada do F3 
		HttpSession->cFiltro:= If( !Empty(HttpGet->Tipo), HttpGet->Tipo,HttpSession->cFiltro)
		oObj:nType			:= Val(HttpSession->cFiltro)
		oObj:nPage		:= Val(HttpGet->cPagina)
		oObj:cSearch	:= 	HttpGet->Busca

		//cUserCode,cParticipantId
		If oObj:BrwCourse()
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды  
			GridHeader(	HttpSession->PWSXF3INFO,;							//aGrid
						HttpSession->PWSXF3HEADER[HEADER_CURSO][1],;		//aHeader
						aWebHeader,;										//aWebCols
						NIL,; 												//oUserField					
						NIL,; 												//cNomeWS
						NIL) 												//cAlias					
					
			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO,;
							HttpSession->PWSXF3HEADER[HEADER_CURSO][1],;
							oObj:oWSBrwCourseRESULT:oWSCoursesCurriculum,;
							aWebHeader,;
							.F.,;
							"A",;
							,;
							0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды     

			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBrwCourseRESULT:oWSCoursesCurriculum )
			HttpSession->USR_SKIN := "images"

			If !Empty( HttpGet->Busca ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
	   		EndIf
		Else
	  		HttpSession->_HTMLERRO := { STR0003, STR0004, "javascript:window.close();"  } //"Dados enviados para Web Function InvАlidos"
			cHtml := ExecInPage("PWSAMSG")
		EndIf	
	Case HttpGet->F3Nome == "BRWENTITY"
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
		WsChgUrl( @oObj, "RHPERSONALDESENVPLAN.APW" )

		If Empty(HttpSession->PWSXF3HEADER[HEADER_ENTIDADE])    
			//здддддддддддддддддддддддддддддд©
			//ЁParametros do metodo GETHEADERЁ
			//юдддддддддддддддддддддддддддддды			
			oObj:cHEADERTYPE := "ENTITY"
		   
			If oObj:GetHeaderRh()
				//зддддддддддддддддддддддддддд©
				//ЁRetorno do Metodo GETHEADERЁ
				//юддддддддддддддддддддддддддды
				HttpSession->PWSXF3HEADER[HEADER_ENTIDADE] := { oObj:oWSGETHEADERRHRESULT:oWSBRWHEADER }    	
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//зддддддддддддд©
		//ЁPaginacao WEBЁ
		//юддддддддддддды
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf

		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
		WsChgUrl( @oObj, "RHCURRICULUM.APW" )
		
		//зддддддддддддддддддддддддддддддд©
		//ЁParametros do metodo BRWENTITY Ё
		//юддддддддддддддддддддддддддддддды              	
		//-- Recupera o curso selecionado na chamada do F3 
		HttpSession->cFiltro:= If( !Empty(HttpGet->Tipo), HttpGet->Tipo,HttpSession->cFiltro)
		oObj:nType			:= Val(HttpSession->cFiltro)
		oObj:nPage			:= Val(HttpGet->cPagina)
		oObj:cSearch		:= 	HttpGet->Busca
	
		//cUserCode,cParticipantId
		If oObj:BrwEntity()
			//здддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem da descricao dos campos da telaЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддддды  
			GridHeader(	HttpSession->PWSXF3INFO,;							//aGrid
						HttpSession->PWSXF3HEADER[HEADER_ENTIDADE][1],;		//aHeader
						aWebHeader,;										//aWebCols
						NIL,; 												//oUserField					
						NIL,; 												//cNomeWS
						NIL) 												//cAlias					
					
			//зддддддддддддддддддддддддддддддддддддд©
			//ЁFuncao de montagem dos campos da telaЁ
			//юддддддддддддддддддддддддддддддддддддды
			GridLinesEx( { 	HttpSession->PWSXF3INFO,;
							HttpSession->PWSXF3HEADER[HEADER_ENTIDADE][1],;
							oObj:oWSBrwEntityResult:oWSEntity,;
							aWebHeader,;
							.F.,;
							"A",;
							,;
							0 } )
			
			//здддддддддддддддддддддддддддддддддд©
			//ЁScript para abertura da tela de F3Ё
			//юдддддддддддддддддддддддддддддддддды     

			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBrwEntityResult:oWSEntity )
			HttpSession->USR_SKIN := "images"

			If !Empty( HttpGet->Busca ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
	   		EndIf
		Else
	  		HttpSession->_HTMLERRO := { STR0003, STR0004, "javascript:window.close();"  } //"Dados enviados para Web Function InvАlidos"
			cHtml := ExecInPage("PWSAMSG")
		EndIf
		
    //здддддддддддддддддд©
    //ЁBusca de Cargos RHЁ
    //юдддддддддддддддддды
    Case HttpGet->F3Nome == "GETRHPOSITION"
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
        WsChgUrl( @oObj, "RHPERSONALDESENVPLAN.APW" )

        If Empty(HttpSession->PWSXF3HEADER[HEADER_RHCARGO])    
            //здддддддддддддддддддддддддддддд©
            //ЁParametros do metodo GETHEADERЁ
            //юдддддддддддддддддддддддддддддды          
            oObj:cHEADERTYPE := "RHPOSITION"
           
            If oObj:GetHeaderRh()
                //зддддддддддддддддддддддддддд©
                //ЁRetorno do Metodo GETHEADERЁ
                //юддддддддддддддддддддддддддды
                HttpSession->PWSXF3HEADER[HEADER_RHCARGO] := { oObj:oWSGETHEADERRHRESULT:oWSBRWHEADER }        
            Else
                PWSGetWSError()
            EndIf
        EndIf

        //зддддддддддддд©
        //ЁPaginacao WEBЁ
        //юддддддддддддды
        If Empty( HttpGet->cPagina )
            HttpGet->cPagina := "0"
        EndIf

		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCompetence"), WSRHCompetence():New())
        WsChgUrl( @oObj, "RHCompetence.APW" )
        
        //зддддддддддддддддддддддддддддддддддд©
        //ЁParametros do metodo GETRHPOSITION Ё
        //юддддддддддддддддддддддддддддддддддды                 
        //-- Recupera o cargo selecionado na chamada do F3 
        HttpSession->cFiltro:= HttpSession->cFiltro
		 oObj:nPage		:= Val(HttpGet->cPagina)
		 oObj:cSearch	:= HttpGet->Busca

        If oObj:GetRHPosition()
            //здддддддддддддддддддддддддддддддддддддддддддддддддд©
            //ЁFuncao de montagem da descricao dos campos da telaЁ
            //юдддддддддддддддддддддддддддддддддддддддддддддддддды  
            GridHeader( HttpSession->PWSXF3INFO,;                           //aGrid
                        HttpSession->PWSXF3HEADER[HEADER_RHCARGO][1],;       //aHeader
                        aWebHeader,;                                     //aWebCols
                        NIL,;                                           //oUserField                    
                        NIL,;                                           //cNomeWS
                        NIL)                                            //cAlias                    
                    
            //зддддддддддддддддддддддддддддддддддддд©
            //ЁFuncao de montagem dos campos da telaЁ
            //юддддддддддддддддддддддддддддддддддддды
            GridLinesEx( {  HttpSession->PWSXF3INFO,;
                            HttpSession->PWSXF3HEADER[HEADER_RHCARGO][1],;
                            oObj:oWSGetRHPositionRESULT:oWSPositionView,;
                            aWebHeader,;
                            .F.,;
                            "A",;
                            ,;
                            0 } )
            
            //здддддддддддддддддддддддддддддддддд©
            //ЁScript para abertura da tela de F3Ё
            //юдддддддддддддддддддддддддддддддддды     

            HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGetRHPositionRESULT:oWSPositionView )
            HttpSession->USR_SKIN := "images"

            If !Empty( HttpGet->Busca ) .OR. !Empty( HttpGet->TrcPag )
                Return ExecInPage( "PWSXF3GRID" )
            EndIf
        Else
            HttpSession->_HTMLERRO := { STR0003, STR0004, "javascript:window.close();"  } //"Dados enviados para Web Function InvАlidos"
            cHtml := ExecInPage("PWSAMSG")
        EndIf   
	
	//здддддддддддддддд©
	//ЁBusca de EstadosЁ
	//юдддддддддддддддды
	Case HttpGet->F3Nome == "GETAREA"
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
        WsChgUrl( @oObj, "RHPERSONALDESENVPLAN.APW" )

        If Empty(HttpSession->PWSXF3HEADER[HEADER_AREA])    
            //здддддддддддддддддддддддддддддд©
            //ЁParametros do metodo GETHEADERЁ
            //юдддддддддддддддддддддддддддддды          
            oObj:cHEADERTYPE := "SX5TABLE"
           
            If oObj:GetHeaderRh()
                //зддддддддддддддддддддддддддд©
                //ЁRetorno do Metodo GETHEADERЁ
                //юддддддддддддддддддддддддддды
                HttpSession->PWSXF3HEADER[HEADER_AREA] := { oObj:oWSGETHEADERRHRESULT:oWSBRWHEADER }        
            Else
                PWSGetWSError()
            EndIf
        EndIf

        //зддддддддддддд©
        //ЁPaginacao WEBЁ
        //юддддддддддддды
        If Empty( HttpGet->cPagina )
            HttpGet->cPagina := "0"
        EndIf

		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCompetence"), WSRHCompetence():New())
        WsChgUrl( @oObj, "RHCompetence.APW" )
        
        //зддддддддддддддддддддддддддддддддддд©
        //ЁParametros do metodo GETRHPOSITION Ё
        //юддддддддддддддддддддддддддддддддддды                 
        //-- Recupera o cargo selecionado na chamada do F3 
        HttpSession->cFiltro:= HttpSession->cFiltro
		oObj:nPage		:= Val(HttpGet->cPagina)
		oObj:cSearch	:= HttpGet->Busca
		oObj:cX5Id	:= HttpGet->F3Tabela
		HttpSession->F3Tabela := HttpGet->F3Tabela
        If oObj:GetX5Table()
            //здддддддддддддддддддддддддддддддддддддддддддддддддд©
            //ЁFuncao de montagem da descricao dos campos da telaЁ
            //юдддддддддддддддддддддддддддддддддддддддддддддддддды  
            GridHeader( HttpSession->PWSXF3INFO,;                           //aGrid
                        HttpSession->PWSXF3HEADER[HEADER_AREA][1],;       //aHeader
                        aWebHeader,;                                     //aWebCols
                        NIL,;                                           //oUserField                    
                        NIL,;                                           //cNomeWS
                        NIL)                                            //cAlias                    
                    
            //зддддддддддддддддддддддддддддддддддддд©
            //ЁFuncao de montagem dos campos da telaЁ
            //юддддддддддддддддддддддддддддддддддддды
            GridLinesEx( {  HttpSession->PWSXF3INFO,;
                            HttpSession->PWSXF3HEADER[HEADER_AREA][1],;
                            oObj:oWSGetx5tableRESULT:oWSX5TableView,;
                            aWebHeader,;
                            .F.,;
                            "A",;
                            ,;
                            0 } )
            
            //здддддддддддддддддддддддддддддддддд©
            //ЁScript para abertura da tela de F3Ё
            //юдддддддддддддддддддддддддддддддддды     

            HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGetX5TableRESULT:oWSX5TableView )
            HttpSession->USR_SKIN := "images"

            If !Empty( HttpGet->Busca ) .OR. !Empty( HttpGet->TrcPag )
                Return ExecInPage( "PWSXF3GRID" )
            EndIf
        Else
            HttpSession->_HTMLERRO := { STR0003, STR0004, "javascript:window.close();"  } //"Dados enviados para Web Function InvАlidos"
            cHtml := ExecInPage("PWSAMSG")
        EndIf   	
Otherwise
	//Nossa!!!
EndCase

ExecInPage( "PWSXF3FRAME" )

WEB EXTENDED END

Return cHtml

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммямммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPWSXF3GRID╨Autor  ЁLuiz Felipe Couto    ╨ Data Ё  24/03/05   ╨╠╠
╠╠лммммммммммьммммммммммймммммммомммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Retorna a tela com os dados do F3 do sistema.               ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ParametrosЁ                                                             ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       ЁPortal Protheus                                              ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╨Analista  Ё Data/Bops/Ver ЁManutencao Efetuada                      	   ╨╠╠
╠╠лммммммммммьммммммммяммммммьммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠хммммммммммоммммммммоммммммоммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Web Function PWSXF3GRID()

Local cHtml := ""					//Pagina WEB

WEB EXTENDED INIT cHtml START "InSite"

ExecInPage( "PWSXF3GRID" )

WEB EXTENDED END

Return cHtml

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммямммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPWSXF3BUSC╨Autor  ЁLuiz Felipe Couto    ╨ Data Ё  24/03/05   ╨╠╠
╠╠лммммммммммьммммммммммймммммммомммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Retorna a tela de busca dos dados do F3 do sistema.         ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ParametrosЁ                                                             ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       ЁPortal Protheus                                              ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╨Analista  Ё Data/Bops/Ver ЁManutencao Efetuada                      	   ╨╠╠
╠╠лммммммммммьммммммммяммммммьммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠хммммммммммоммммммммоммммммоммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Web Function PWSXF3BUSCA()

Local cHtml := ""					//Pagina WEB

WEB EXTENDED INIT cHtml START "InSite"

ExecInPage( "PWSXF3BUSCA" )

WEB EXTENDED END

Return cHtml
