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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSXF*    �Autor  �Luiz Felipe Couto    � Data �  24/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Este fonte possui as funcionalidades relacionado aos        ���
���          � F3 do sistema utilizando WS.                                ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������ͼ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSXF3000 �Autor  �Luiz Felipe Couto    � Data �  24/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Retorna os dados do F3 do sistema.                          ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������ͼ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
���Cleber M. �17/11/06�111492�-Inclusao de busca F3 p/ Prospects.		   ���
���Joeudo S.F�06/07/07�116560�-Implementada a opcao BRWAVALIAD p/ consulta ���
���          �        �      �F3 ao campo Avaliador						   ���
���Norbert W.�06/08/07�126096�-Implementada a opcao BRWIDNUMBER p/ consulta���
���          �        �      �F3 aos numeros de Pedido/Licitacao no Portal.���
���          �        �      �-Ordenacao dos pedidos de venda pelo numero  ���
���          �        �      �da licitacao na opcao BRWIDNUMBER.           ���
���Norbert W.�10/08/07�126152�-Adaptacao na ordenacao pelo pedido(IdNumber)���
���          �        �      �para permitir a pesquisa de pedidos pelo por-���
���          �        �      �tal do vendedor.                             ���
���MauricioMR�28/05/09�13245 �-Implementada recuperacao do curso/entidade  ���
���          �        �2009  �de entrada para filtrar curso/entidade       ���
���Renan B.  �26/11/14�TQXMZG�Ajuste para realizar a filtragem corretamente���
���          �        �	     �mesmo que haja mudan�a de p�gina.			   ���
���Renan B.  �01/07/15�TSNVN0�Ajuste para realizar a filtragem c�digo de   ���
���          �        �	     �cargos do curr�culo de candidato corretamente���
���          �        �	     �mesmo que haja mudan�a de p�gina.			   ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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

//�����������������������������������������������������Ŀ
//�Faz um parse do HttpGet e coloca o resultado no array�
//�������������������������������������������������������
aGetTemp := ParseGets()

nTam := Len( aGetTemp[2] )

//������������������������������������������������������������������Ŀ
//�Preenche o array de campos com os campos que sao enviados pelo GET�
//��������������������������������������������������������������������
For nI := 1 To nTam
	aAdd( aWebHeader, SubStr( aGetTemp[2][nI], 2 ) )
Next

//���������������������������Ŀ
//�Array para montagem da tela�
//�����������������������������
HttpSession->PWSXF3INFO := {}

If Empty( HttpSession->PWSXF3HEADER )
	HttpSession->PWSXF3HEADER := Array(NUM_HEADERS)
EndIf

Do Case
	//�����������������Ŀ
	//�Busca de Produtos�
	//�������������������
	Case HttpGet->F3Nome == "GETCATALOG"
		//������������������������������������Ŀ
		//�Inicializa o Objeto WS - WSMTPRODUCT�
		//��������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTPRODUCT"), WSMTPRODUCT():New() )
		WsChgUrl( @oObj, "MTPRODUCT.APW" )
		
		//�����������������������������������������������������������������������Ŀ
		//�Header da estrutura PRODUCTVIEW - Produto                              �
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
		//�������������������������������������������������������������������������
		If Empty( HttpSession->PWSXF3HEADER[HEADER_PRODUTO] )
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������
			oObj:cHEADERTYPE := "PRODUCTVIEW"

			//cHEADERTYPE
			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_PRODUTO] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//�������������Ŀ
		//�Paginacao WEB�
		//���������������
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		
		//�������������������������������Ŀ
		//�Parametros do metodo GETCATALOG�
		//���������������������������������
		oObj:cUSERCODE			:= GetUsrCode()
		oObj:cPRODUCTCODELIKE	:= IIf( HttpGet->Tipo == "1", HttpGet->Busca, "" )
		oObj:cDESCRIPTIONLIKE	:= IIf( HttpGet->Tipo == "2", HttpGet->Busca, "" )
		oObj:nPAGELEN			:= 10
		oObj:nPAGEFIRST			:= ( Val( HttpGet->cPagina ) * 10 ) + 1
        oObj:cCUSTOMERID		:= IIf(!Empty(HttpSession->CODCLIERP), HttpSession->CODCLIERP, "")
        //Filtros exclusivos para inclus�o de Pedido de Venda e Or�amentos no Portal do Vendedor
        oObj:cQUERYADDWHERE		:= IIF(!(Empty(HttpSession->PWSV044GRAVA)),"MV_PVCODPV",IIF(!(Empty(HttpSession->PWSV084GRAVA)),"MV_PVCODOC",""))

		//cUSERCODE,cTYPEOFPRODUCTIN,cGROUPOFPRODUCTIN,cPRODUCTCODELIKE,cDESCRIPTIONLIKE,nPAGELEN,nPAGEFIRST,cQUERYADDWHERE,cINDEXKEY,cCUSTOMERID
		If oObj:GETCATALOG()
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_PRODUTO][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO					, HttpSession->PWSXF3HEADER[HEADER_PRODUTO][1]	,;
							oObj:oWSGETCATALOGRESULT:oWSPRODUCTVIEW	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETCATALOGRESULT:oWSPRODUCTVIEW )
			
			If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//�������������������������Ŀ
	//�Busca de Tipo de Produtos�
	//���������������������������
	Case HttpGet->F3Nome == "GETTYPEOFPRODUCT"
		//����������������������������������Ŀ
		//�Inicializa Objeto WS - WSMTPRODUCT�
		//������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTPRODUCT"), WSMTPRODUCT():New() )
		WsChgUrl( @oObj, "MTPRODUCT.APW" )
		
		//�����������������������������������������������������������������������Ŀ
		//�Header da estrutura PRODUCTVIEW - Produto                              �
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
		//�������������������������������������������������������������������������
		If Empty( HttpSession->PWSXF3HEADER[HEADER_TIPO_PRODUTO] )
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������
			oObj:cHEADERTYPE := "PRODUCTVIEW"
		
			//cHEADERTYPE
			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_TIPO_PRODUTO] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf
		
		//�������������������������������������Ŀ
		//�Parametros do metodo GETTYPEOFPRODUCT�
		//���������������������������������������
		oObj:cUSERCODE := GetUsrCode()

		//cUSERCODE
		If oObj:GETTYPEOFPRODUCT()
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_TIPO_PRODUTO][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO							, HttpSession->PWSXF3HEADER[HEADER_TIPO_PRODUTO][1]	,;
							oObj:oWSGETTYPEOFPRODUCTRESULT:oWSGENERICSTRUCT	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETTYPEOFPRODUCTRESULT:oWSGENERICSTRUCT )
			
			If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//���������������������������Ŀ
	//�Busca de Grupos de Produtos�
	//�����������������������������
	Case HttpGet->F3Nome == "GETGROUPOFPRODUCT"
		//�������������������������������������������Ŀ
		//�Inicializa o objeto WS - WSMTGROUPOFPRODUCT�
		//���������������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTGROUPOFPRODUCT"), WSMTGROUPOFPRODUCT():New() )
		WsChgUrl( @oObj,"MTGROUPOFPRODUCT.APW" )
		
		If Empty( HttpSession->PWSXF3HEADER[HEADER_GRUPO_PRODUTO] )
			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_GRUPO_PRODUTO] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf
		
		//�����������������������������Ŀ
		//�Parametros do metodo GETGROUP�
		//�������������������������������
		oObj:cUSERCODE	:= GetUsrCode()

		//cUSERCODE,cINDEXKEY
		If oObj:GETGROUP()
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_GRUPO_PRODUTO][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO						, HttpSession->PWSXF3HEADER[HEADER_GRUPO_PRODUTO][1]	,;
							oObj:oWSGETGROUPRESULT:oWSGROUPOFPRODUCTVIEW, aWebHeader						,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETGROUPRESULT:oWSGROUPOFPRODUCTVIEW )
			
			If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//������������������������������Ŀ
	//�Busca de Clientes por Vendedor�
	//��������������������������������
	Case HttpGet->F3Nome == "BRWCUSTOMER"
		//�����������������������������������������Ŀ
		//�Inicializa Objeto WS - WSMTSELLERCUSTOMER�
		//�������������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSELLERCUSTOMER"), WSMTSELLERCUSTOMER():New() )
		WsChgUrl( @oObj, "MTSELLERCUSTOMER.APW" )

		//���������������������������������Ŀ
		//�Header da estrutura GENERICVIEW2 �
		//|- CODE        : Codigo do Cliente|
		//|- UNIT        : Loja do Cliente  |
		//|- DESCRIPTION : Nome do Cliente  |
		//�����������������������������������
		If Empty( HttpSession->PWSXF3HEADER[HEADER_CLIENTE] )
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������
			oObj:cHEADERTYPE := "GENERICVIEW2"
		
			//cHEADERTYPE
			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
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
		
		//�������������Ŀ
		//�Paginacao WEB�
		//���������������
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf

		//��������������������������������Ŀ
		//�Parametros do metodo BRWCUSTOMER�
		//����������������������������������
		oObj:cUSERCODE		:= GetUsrCode()
		oObj:cSELLERCODE	:= HttpSession->CODVENERP
		oObj:nPAGELEN		:= 10
		oObj:nPAGEFIRST		:= ( Val( HttpGet->cPagina ) * 10 ) + 1
		oObj:cNAMELIKE		:= IIf( HttpGet->Tipo == "1", HttpGet->Busca, "" )
		oObj:cNICKNAMELIKE	:= IIf( HttpGet->Tipo == "2", HttpGet->Busca, "" )
		oObj:cINDEXKEY		:= IIf( HttpGet->Tipo == "1", "A1_NOME", "A1_NREDUZ" )
		
		//cUSERCODE,cSELLERCODE,nPAGELEN,nPAGEFIRST,cNAMELIKE,cNICKNAMELIKE,cQUERYADDWHERE,cINDEXKEY
		If oObj:BRWCUSTOMER()
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_CLIENTE][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO						, HttpSession->PWSXF3HEADER[HEADER_CLIENTE][1]	,;
							oObj:oWSBRWCUSTOMERRESULT:oWSGENERICVIEW2	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWCUSTOMERRESULT:oWSGENERICVIEW2 )
			
	  		If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//������������������������Ŀ
	//�Busca de Transportadoras�
	//��������������������������
	Case HttpGet->F3Nome == "GETCARRIER"
		//����������������������������������Ŀ
		//�Inicializa Objeto WS - WSMTCARRIER�
		//������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTCARRIER"), WSMTCARRIER():New() )
		WsChgUrl( @oObj, "MTCARRIER.APW" )

		//������������������������������������������������������Ŀ
		//�Header da estrutura GENERICSTRUCT - Estrutura Generica�
		//�- CODE        : Codigo                                �
		//�- DESCRIPTION : Descricao                             �
		//��������������������������������������������������������
		If Empty( HttpSession->PWSXF3HEADER[HEADER_TRANSPORTADORA] )
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������
			oObj:cHEADERTYPE := "GENERICSTRUCT"
		
			//cHEADERTYPE
			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_TRANSPORTADORA] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//�������������Ŀ
		//�Paginacao WEB�
		//���������������
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		
		//�������������������������������Ŀ
		//�Parametros do metodo BRWCARRIER�
		//���������������������������������
		oObj:cUSERCODE		:= GetUsrCode()
		oObj:nPAGELEN		:= 10
		oObj:nPAGEFIRST		:= ( Val( HttpGet->cPagina ) * 10 ) + 1
		oObj:cNAMELIKE		:= IIf( HttpGet->Tipo == "1", HttpGet->Busca, "" )
		oObj:cNICKNAMELIKE	:= IIf( HttpGet->Tipo == "2", HttpGet->Busca, "" )
		oObj:cQUERYADDWHERE	:= ""

		//cUSERCODE,nPAGELEN,nPAGEFIRST,cNAMELIKE,cNICKNAMELIKE,cQUERYADDWHERE,cINDEXKEY
		If oObj:BRWCARRIER()
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_TRANSPORTADORA][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO					, HttpSession->PWSXF3HEADER[HEADER_TRANSPORTADORA][1]	,;
							oObj:oWSBRWCARRIERRESULT:oWSGENERICVIEW	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWCARRIERRESULT:oWSGENERICVIEW )
			
			If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//�������������������������������Ŀ
	//�Busca de Pedidos por Fornecedor�
	//���������������������������������
	Case HttpGet->F3Nome == "BRWPURCHASEORDER"
		//��������������������������������������������������Ŀ
		//�Inicializa o objeto WS - WSMTSUPPLIERPURCHASEORDER�
		//����������������������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIERPURCHASEORDER"), WSMTSUPPLIERPURCHASEORDER():New() )
		WsChgUrl( @oObj, "MTSUPPLIERPURCHASEORDER.APW" )

		//������������������������������������������������������������������Ŀ
		//�Header da estrutura PURCHASEORDERHEADERVIEW - Cab. Pedido de Venda�
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
		//��������������������������������������������������������������������
		If Empty( HttpSession->PWSXF3HEADER[HEADER_PEDIDO] )
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������
			oObj:cHEADERTYPE := "PURCHASEORDERHEADERVIEW"
		
			//cHEADERTYPE
			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_PEDIDO] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//�������������������������������������Ŀ
		//�Parametros do metodo BRWPURCHASEORDER�
		//���������������������������������������
		oObj:cUSERCODE			:= GetUsrCode()
		oObj:cSUPPLIER			:= HttpSession->CODFORERP
		oObj:dDELIVERYDATEFROM	:= IIf( !Empty( HttpGet->DtInicio ), CToD( HttpGet->DtInicio ), )
		oObj:dDELIVERYDATETO 	:= IIf( !Empty( HttpGet->DtFim ), CToD( HttpGet->DtFim ), )

		//cUSERCODE,cSUPPLIER,dDELIVERYDATEFROM,dDELIVERYDATETO,cQUERYADDWHERE
		If oObj:BRWPURCHASEORDER()
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_PEDIDO][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO										, HttpSession->PWSXF3HEADER[HEADER_PEDIDO][1]	,;
							oObj:oWSBRWPURCHASEORDERRESULT:oWSPURCHASEORDERHEADERVIEW	, aWebHeader									,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWPURCHASEORDERRESULT:oWSPURCHASEORDERHEADERVIEW )
			
			If !Empty( HttpGet->DtInicio ) .AND. !Empty( HttpGet->DtFim )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//��������������Ŀ
	//�Busca de Taxas�
	//����������������
	Case HttpGet->F3Nome == "BRWTAXES"
		//�������������������������������������������Ŀ
		//�Inicializa o objeto WS - WSMTSELLERCUSTOMER�
		//���������������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTTAXES"), WSMTTAXES():New() )
		WsChgUrl( @oObj, "MTTAXES.APW" )

		//������������������������������������������������������Ŀ
		//�Header da estrutura GENERICSTRUCT - Estrutura Generica�
		//�- CODE        : Codigo                                �
		//�- DESCRIPTION : Descricao                             �
		//��������������������������������������������������������
		If Empty( HttpSession->PWSXF3HEADER[HEADER_TAXA] )
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������
			oObj:cHEADERTYPE := "GENERICSTRUCT"
			
			//cHEADERTYPE
			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_TAXA] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		If oObj:BRWTAXES()
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_TAXA][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO					, HttpSession->PWSXF3HEADER[HEADER_TAXA][1]	,;
							oObj:oWSBRWTAXESRESULT:oWSGENERICSTRUCT	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWTAXESRESULT:oWSGENERICSTRUCT )
			
			If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//�������������������������������Ŀ
	//�Busca de Condicoes de Pagamento�
	//���������������������������������
	Case HttpGet->F3Nome == "BRWPAYMENTPLAN"
		//��������������������������������������Ŀ
		//�Inicializa Objeto WS - WSMTPAYMENTPLAN�
		//����������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTPAYMENTPLAN"), WSMTPAYMENTPLAN():New() )
		WsChgUrl( @oObj, "MTPAYMENTPLAN.APW" )

		If Empty( HttpSession->PWSXF3HEADER[HEADER_COND_PAGAMENTO] )
			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_COND_PAGAMENTO] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//�������������Ŀ
		//�Paginacao WEB�
		//���������������
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		
		//�������������������Ŀ
		//�Adicao de Query ADD�
		//���������������������
		If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
			If HttpGet->Tipo == "1"
				cQryAdd := "E4_CODIGO"
			Else
				cQryAdd := "E4_DESCRI"
			EndIf
			
			cQryAdd += " LIKE '%" + HttpGet->Busca + "%' "
		EndIf
		
		//�����������������������������������Ŀ
		//�Parametros do metodo BRWPAYMENTPLAN�
		//�������������������������������������
		oObj:nPAGELEN		:= 10
		oObj:nPAGEFIRST		:= ( Val( HttpGet->cPagina ) * 10 ) + 1
		oObj:cQUERYADDWHERE	:= cQryAdd
		
		//nPAGELEN,nPAGEFIRST,cQUERYADDWHERE
		If oObj:BRWPAYMENTPLAN()
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_COND_PAGAMENTO][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO							, HttpSession->PWSXF3HEADER[HEADER_COND_PAGAMENTO][1]	,;
							oObj:oWSBRWPAYMENTPLANRESULT:oWSPAYMENTPLANVIEW	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWPAYMENTPLANRESULT:oWSPAYMENTPLANVIEW )
			
			If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//������������������������������Ŀ
	//�Busca de Prioridade de Tarefas�
	//��������������������������������
	Case HttpGet->F3Nome == "GETPRIORITY"
		//�����������������������������������������Ŀ
		//�Inicializa o objeto WS - WSFTCUSTOMERTASK�
		//�������������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSFTCUSTOMERTASK"), WSFTCUSTOMERTASK():New() )
		WsChgUrl( @oObj, "FTCUSTOMERTASK.APW" )

		//����������������������������������������Ŀ
		//�Header da estrutura TASKVIEW - Tarefas  �
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
		//������������������������������������������
		If Empty( HttpSession->PWSXF3HEADER[HEADER_PRIORIDADE] )
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������
			oObj:cHEADERTYPE := "TASKVIEW"
		
			//cHEADERTYPE
			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_PRIORIDADE] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf
		
		//����������������������������Ŀ
		//�Parametros do metodo BRWTASK�
		//������������������������������
		oObj:cUSERCODE		:= GetUsrCode()
		oObj:cCUSTOMERID	:= HttpSession->CODCLIERP
		oObj:dDATEFROM		:= IIf( !Empty( HttpGet->DtInicio ), CToD( HttpGet->DtInicio ), )
		oObj:dDATETO		:= IIf( !Empty( HttpGet->DtFim ), CToD( HttpGet->DtFim ), )

		//cUSERCODE,cCUSTOMERID,dDATEFROM,dDATETO,cQUERYADDWHERE,cINDEXKEY
		If oObj:BRWTASK()
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_PRIORIDADE][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO				, HttpSession->PWSXF3HEADER[HEADER_PRIORIDADE][1]	,;
							oObj:oWSBRWTASKRESULT:oWSTASKVIEW	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWTASKRESULT:oWSTASKVIEW )
			
			If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//����������������Ŀ
	//�Busca de Estados�
	//������������������
	Case HttpGet->F3Nome == "GETUF"
		//��������������������������������������������Ŀ
		//�Inicializa o objeto WS - WSCFGSTANDARDTABLES�
		//����������������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGSTANDARDTABLES"), WSCFGSTANDARDTABLES():New() )
		WsChgUrl( @oObj, "CFGSTANDARDTABLES.APW" )

		//����������������������������������������������������Ŀ
		//�Header da estrutura do Objeto WS WSCFGSTANDARDTABLES�
		//������������������������������������������������������
		If Empty( HttpSession->PWSXF3HEADER[HEADER_ESTADO] )
			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_ESTADO] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf
		
		//�������������������������������������Ŀ
		//�Parametros do metodo GETSTANDARDTABLE�
		//���������������������������������������
		oObj:cUSERCODE			:= GetUsrCode()
		oObj:cSTANDARDTABLECODE	:= "12"

		//cUSERCODE,cSTANDARDTABLECODE
		If oObj:GETSTANDARDTABLE()
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_ESTADO][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO							, HttpSession->PWSXF3HEADER[HEADER_ESTADO][1]	,;
							oObj:oWSGETSTANDARDTABLERESULT:oWSGENERICSTRUCT	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETSTANDARDTABLERESULT:oWSGENERICSTRUCT )
			
			If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//����������������Ŀ
	//�Busca de Fornec�
	//������������������
	Case HttpGet->F3Nome == "SUPPLIERCODE"
		//��������������������������������������������Ŀ
		//�Inicializa o objeto WS - WSMTSUPPLIER       �
		//����������������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIER"), WSMTSUPPLIER():New() )
		WsChgUrl( @oObj, "MTSUPPLIER.APW" )
		
		If Empty( HttpSession->PWSXF3HEADER[HEADER_FORNECEDOR] )
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������
			oObj:cHEADERTYPE := "SUPPLIERVIEW"
		
			//cHEADERTYPE
			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_FORNECEDOR] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf
		oObj:cUSERCODE			:= GetUsrCode()
		If oObj:GetListSupplier()
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO	, HttpSession->PWSXF3HEADER[HEADER_FORNECEDOR][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������ADMIN
			
			
			GridLinesEx( { 	HttpSession->PWSXF3INFO										, HttpSession->PWSXF3HEADER[HEADER_FORNECEDOR][1]	,;
							oObj:oWSGETLISTSUPPLIERRESULT:OWSSUPPLIERVIEW	, aWebHeader									,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETLISTSUPPLIERRESULT:OWSSUPPLIERVIEW )
			
			If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
			//ExecInPage( "PWSXF3BUSCA" )
		Else
			PWSGetWSError()
		EndIf
	//���������������Ŀ
	//�Busca de Cargos�
	//�����������������
	Case HttpGet->F3Nome == "GETPOSITION"
		//���������������������������������������������Ŀ
		//�Inicializa o objeto WS - WSCRMCUSTOMERCONTACT�
		//�����������������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCRMCUSTOMERCONTACT"), WSCRMCUSTOMERCONTACT():New() )
		WsChgUrl( @oObj, "CRMCUSTOMERCONTACT.APW" )

		//������������������������������������������������������Ŀ
		//�Header da estrutura GENERICSTRUCT - Estrutura Generica�
		//�- CODE        : Codigo                                �
		//�- DESCRIPTION : Descricao                             �
		//��������������������������������������������������������
		If Empty( HttpSession->PWSXF3HEADER[HEADER_CARGO] )
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������
			oObj:cHEADERTYPE := "GENERICSTRUCT"

			//cHEADERTYPE
			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_CARGO] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		If oObj:GETPOSITION()
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_CARGO][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO					, HttpSession->PWSXF3HEADER[HEADER_CARGO][1]	,;
							oObj:oWSGETPOSITIONRESULT:oWSGENERICVIEW, aWebHeader						,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETPOSITIONRESULT:oWSGENERICVIEW )
			
			If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//���������������Ŀ
	//�Busca de Grupos�
	//�����������������
	Case HttpGet->F3Nome == "GETGROUP"
		//���������������������������������������������Ŀ
		//�Inicializa o objeto WS - WSCRMCUSTOMERCONTACT�
		//�����������������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCRMCUSTOMERCONTACT"), WSCRMCUSTOMERCONTACT():New() )
		WsChgUrl( @oObj, "CRMCUSTOMERCONTACT.APW" )

		//������������������������������������������������������Ŀ
		//�Header da estrutura GENERICSTRUCT - Estrutura Generica�
		//�- CODE        : Codigo                                �
		//�- DESCRIPTION : Descricao                             �
		//��������������������������������������������������������
		If Empty( HttpSession->PWSXF3HEADER[HEADER_GRUPO] )
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������
			oObj:cHEADERTYPE := "GENERICSTRUCT"

			//cHEADERTYPE
			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_GRUPO] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		If oObj:GETGROUP()
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_GRUPO][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO					, HttpSession->PWSXF3HEADER[HEADER_GRUPO][1]	,;
							oObj:oWSGETGROUPRESULT:oWSGENERICVIEW	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETGROUPRESULT:oWSGENERICVIEW )
			
			If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//����������������������Ŀ
	//�Busca de Departamentos�
	//������������������������
	Case HttpGet->F3Nome == "GETDEPARTMENT"
		//���������������������������������������������Ŀ
		//�Inicializa o objeto WS - WSCRMCUSTOMERCONTACT�
		//�����������������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCRMCUSTOMERCONTACT"), WSCRMCUSTOMERCONTACT():New())
		WsChgUrl( @oObj, "CRMCUSTOMERCONTACT.APW" )

		//������������������������������������������������������Ŀ
		//�Header da estrutura GENERICSTRUCT - Estrutura Generica�
		//�- CODE        : Codigo                                �
		//�- DESCRIPTION : Descricao                             �
		//��������������������������������������������������������
		If Empty( HttpSession->PWSXF3HEADER[HEADER_DEPARTAMENTO] )
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������
			oObj:cHEADERTYPE := "GENERICSTRUCT"
			
			//cHEADERTYPE
			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_DEPARTAMENTO] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		If oObj:GETDEPARTMENT()
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_DEPARTAMENTO][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO						, HttpSession->PWSXF3HEADER[HEADER_DEPARTAMENTO][1]	,;
							oObj:oWSGETDEPARTMENTRESULT:oWSGENERICVIEW	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETDEPARTMENTRESULT:oWSGENERICVIEW )
			
			If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//����������������������Ŀ
	//�Busca de Departamentos�
	//������������������������
	Case HttpGet->F3Nome == "BRWMEASUREUNIT"
		//���������������������������������������������Ŀ
		//�Inicializa o objeto WS - WSCRMCUSTOMERCONTACT�
		//�����������������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSQTMEASUREUNIT"), WSQTMEASUREUNIT():New() )
		WsChgUrl( @oObj, "QTMEASUREUNIT.APW" )

		//������������������������������������������������������Ŀ
		//�Header da estrutura �
		//��������������������������������������������������������
		If Empty( HttpSession->PWSXF3HEADER[HEADER_UM] )
			//������������������������������Ŀ
			//cHEADERTYPE
			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_UM] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		If oObj:BRWMEASUREUNIT()
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_UM][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO							, HttpSession->PWSXF3HEADER[HEADER_UM][1]	,;
							oObj:oWSBRWMEASUREUNITRESULT:oWSMEASUREUNITVIEW	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWMEASUREUNITRESULT:oWSMEASUREUNITVIEW )
			
			If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf
	Case Alltrim(HttpGet->F3Nome) == "GETPROJECT"
		//������������������������������������Ŀ
		//�Inicializa o Objeto WS - WSMTPROJECT�
		//��������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSPMSREPORT"), WSPmsReport():New() )
		WsChgUrl( @oObj, "PMSREPORT.APW" )
		
		If Empty( HttpSession->PWSXF3HEADER[HEADER_PROJETO] )
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������
			oObj:cHeaderType := "PROJECTLISTVIEW"
			//cHEADERTYPE
			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_PROJETO] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//�������������Ŀ
		//�Paginacao WEB�
		//���������������
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		//�������������������Ŀ
		//�Adicao de Query ADD�
		//���������������������
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
		
		//�������������������������������Ŀ
		//�Parametros do metodo GETCATALOG�
		//���������������������������������
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
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_PROJETO][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO					, HttpSession->PWSXF3HEADER[HEADER_PROJETO][1]	,;
							oObj:oWSGETPROJECTLISTRESULT:oWSPROJECTLISTVIEW	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETPROJECTLISTRESULT:oWSPROJECTLISTVIEW )
			
			If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf
	Case Alltrim(HttpGet->F3Nome) == "GETRESOURCE"
		//������������������������������������Ŀ
		//�Inicializa o Objeto WS - WSMTPROJECT�
		//��������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSPMSREPORT"), WSPmsReport():New() )
		WsChgUrl( @oObj, "PMSREPORT.APW" )
		
		If Empty( HttpSession->PWSXF3HEADER[HEADER_RECURSOS] )
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������
			oObj:cHeaderType := "RESOURCEVIEW"
			//cHEADERTYPE
			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_RECURSOS] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()                 	
			EndIf
		EndIf

		//�������������Ŀ
		//�Paginacao WEB�
		//���������������
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		//�������������������Ŀ
		//�Adicao de Query ADD�
		//���������������������         
		
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
		
		//�������������������������������Ŀ
		//�Parametros do metodo GETCATALOG�
		//���������������������������������
		oObj:cUSERCODE				:= GtPtUsrCod()[1]
		oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
		oObj:cRESOURCEINITIAL	:= ' '
		oObj:cRESOURCEFINAL		:= 'zzzzzzzzzzzzzzzzzzzz'
		oObj:nPAGELEN				:= 10
		oObj:nPAGEFIRST			:= ( Val( HttpGet->cPagina ) * 10 ) + 1

		//cUSERCODE,cTYPEOFPRODUCTIN,cGROUPOFPRODUCTIN,cPRODUCTCODELIKE,cDESCRIPTIONLIKE,nPAGELEN,nPAGEFIRST,cQUERYADDWHERE,cINDEXKEY
		If oObj:GetResourceList() 
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_RECURSOS][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO					, HttpSession->PWSXF3HEADER[HEADER_RECURSOS][1]	,;
							oObj:oWSGETRESOURCELISTRESULT:oWSRESOURCEVIEW	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETRESOURCELISTRESULT:oWSRESOURCEVIEW )
			
			If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	Case Alltrim(HttpGet->F3Nome) == "GETTASK"
		//������������������������������������Ŀ
		//�Inicializa o Objeto WS - WSMTPROJECT�
		//��������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSPMSREPORT"), WSPmsReport():New() )
		WsChgUrl( @oObj, "PMSREPORT.APW" )
		
		If Empty( HttpSession->PWSXF3HEADER[HEADER_TAREFA] )
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������
			oObj:cHeaderType := "GANTTTASKVIEW"
			//cHEADERTYPE
			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_TAREFA] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//�������������Ŀ
		//�Paginacao WEB�
		//���������������
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		//�������������������Ŀ
		//�Adicao de Query ADD�
		//���������������������
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
		
		//�������������������������������Ŀ
		//�Parametros do metodo GETCATALOG�
		//���������������������������������
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
				//��������������������������������������������������Ŀ
				//�Funcao de montagem da descricao dos campos da tela�
				//����������������������������������������������������
				GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_TAREFA][1], aWebHeader )
	
				//�������������������������������������Ŀ
				//�Funcao de montagem dos campos da tela�
				//���������������������������������������
				GridLinesEx( { 	HttpSession->PWSXF3INFO					, HttpSession->PWSXF3HEADER[HEADER_TAREFA][1]	,;
								oObj:oWSGETTASKLISTRESULT:oWSGANTTTASKVIEW	, aWebHeader						,;
								.F., "A",, 0 } )
				
				//����������������������������������Ŀ
				//�Script para abertura da tela de F3�
				//������������������������������������
				HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETTASKLISTRESULT:oWSGANTTTASKVIEW )
				
				If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
					Return ExecInPage( "PWSXF3GRID" )
				EndIf
			Else
				PWSGetWSError()
			EndIf
	   Endif
	Case Alltrim(HttpGet->F3Nome) == "GETOCORRENCE"
		//������������������������������������Ŀ
		//�Inicializa o Objeto WS - WSMTPROJECT�
		//��������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSPMSREPORT"), WSPmsReport():New() )
		WsChgUrl( @oObj, "PMSREPORT.APW" )
		
		If Empty( HttpSession->PWSXF3HEADER[HEADER_OCORRENCIA] )
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������
			oObj:cHeaderType := "OCORRENCEVIEW"
			//cHEADERTYPE
			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_OCORRENCIA] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//�������������Ŀ
		//�Paginacao WEB�
		//���������������
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		//�������������������Ŀ
		//�Adicao de Query ADD�
		//���������������������
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
		
		//�������������������������������Ŀ
		//�Parametros do metodo GETCATALOG�
		//���������������������������������
		oObj:cUSERCODE				:= GtPtUsrCod()[1]
		oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
		oObj:cOcorrenceInitial	:= ''
		oObj:cOcorrenceFinal		:= 'zz'		
		oObj:nPAGELEN				:= 10
		oObj:nPAGEFIRST			:= ( Val( HttpGet->cPagina ) * 10 ) + 1

		If oObj:GetOcorrenceList() 
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_OCORRENCIA][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO					, HttpSession->PWSXF3HEADER[HEADER_OCORRENCIA][1]	,;
							oObj:oWSGETOCORRENCELISTRESULT:oWSOCORRENCEVIEW	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETOCORRENCELISTRESULT:oWSOCORRENCEVIEW )
			
			If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//������������������������������Ŀ
	//�Busca de todos os clientes    �
	//��������������������������������
	Case HttpGet->F3Nome == "BRWALLCUSTOMER"
		//�����������������������������������������Ŀ
		//�Inicializa Objeto WS - WSMTSELLERCUSTOMER�
		//�������������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMtSystemCustomer"), WSMtSystemCustomer():New() )
		WsChgUrl( @oObj, "MTSYSTEMCUSTOMER.APW" )

		//���������������������������������Ŀ
		//�Header da estrutura GENERICVIEW2 �
		//|- CODE        : Codigo do Cliente|
		//|- UNIT        : Loja do Cliente  |
		//|- DESCRIPTION : Nome do Cliente  |
		//�����������������������������������
		If Empty( HttpSession->PWSXF3HEADER[HEADER_CLIENTE] )
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������
			oObj:cHEADERTYPE := "GENERICVIEW2"
		
			//cHEADERTYPE
			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_CLIENTE] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf
		
		//�������������Ŀ
		//�Paginacao WEB�
		//���������������
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf

		//��������������������������������Ŀ
		//�Parametros do metodo BRWCUSTOMER�
		//����������������������������������
		oObj:cUSERCODE			:= GetUsrCode()
		oObj:nPAGELEN			:= 10
		oObj:nPAGEFIRST	   		:= ( Val( HttpGet->cPagina ) * 10 ) + 1
		oObj:cNAMELIKE			:= IIf( HttpGet->Tipo == "1", HttpGet->Busca, "" )
		oObj:cNICKNAMELIKE 		:= IIf( HttpGet->Tipo == "2", HttpGet->Busca, "" )
		oObj:cINDEXKEY			:= IIf( HttpGet->Tipo == "1", "A1_NOME", "A1_NREDUZ" )
		
		//cUSERCODE,cSELLERCODE,nPAGELEN,nPAGEFIRST,cNAMELIKE,cNICKNAMELIKE,cQUERYADDWHERE,cINDEXKEY
		If oObj:BRWCUSTOMER()
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_CLIENTE][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO						, HttpSession->PWSXF3HEADER[HEADER_CLIENTE][1]	,;
							oObj:oWSBRWCUSTOMERRESULT:oWSGENERICVIEW2	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWCUSTOMERRESULT:oWSGENERICVIEW2 )
			
			If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf
	Case Alltrim(HttpGet->F3Nome) == "GETTEAM"
		//������������������������������������Ŀ
		//�Inicializa o Objeto WS - WSMTPROJECT�
		//��������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSPmsReport"), WSPmsReport():New())
		WsChgUrl( @oObj, "PMSREPORT.APW" )
		
		If Empty( HttpSession->PWSXF3HEADER[HEADER_EQUIPE] )
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������
			oObj:cHeaderType := "TEAMVIEW"
			//cHEADERTYPE
			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_EQUIPE] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()                 	
			EndIf
		EndIf

		//�������������Ŀ
		//�Paginacao WEB�
		//���������������
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		//�������������������Ŀ
		//�Adicao de Query ADD�
		//���������������������
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
		
		//�������������������������������Ŀ
		//�Parametros do metodo GETCATALOG�
		//���������������������������������
		oObj:cUSERCODE				:= GtPtUsrCod()[1]
		oObj:cPROTHEUSUSERCODE	:= GtPtUsrCod()[2]
		oObj:cTEAMINITIAL	:= ' '
		oObj:cTEAMFINAL		:= 'zzzzzzzzzzzzzzzzzzzz'
		oObj:nPAGELEN				:= 10
		oObj:nPAGEFIRST			:= ( Val( HttpGet->cPagina ) * 10 ) + 1

		//cUSERCODE,cTYPEOFPRODUCTIN,cGROUPOFPRODUCTIN,cPRODUCTCODELIKE,cDESCRIPTIONLIKE,nPAGELEN,nPAGEFIRST,cQUERYADDWHERE,cINDEXKEY
		If oObj:GetTeamList() 
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_EQUIPE][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO					, HttpSession->PWSXF3HEADER[HEADER_EQUIPE][1]	,;
							oObj:oWSGETTEAMLISTRESULT:oWSTEAMVIEW	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGETTEAMLISTRESULT:oWSTEAMVIEW )
			
			If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//����������������������Ŀ
	//�  Busca de Prospects	 �
	//������������������������
	Case HttpGet->F3Nome == "BRWPROSPECT"
		//�����������������������������������������������Ŀ
		//� Inicializa o objeto WSCRMPROSPECT			  �
		//�������������������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCRMPROSPECT"), WSCRMPROSPECT():New())
		WsChgUrl( @oObj, "CRMPROSPECT.APW" )

		//������������������������������������������������������Ŀ
		//�Header da estrutura PROSPECTVIEW  					 �
		//�- PROSPECTCODE   	: Codigo Prospect                �
		//�- UNITPROSPECTCODE   : Loja Prospect                  �
		//�- NAME               : Nome Prospect                  �	
		//��������������������������������������������������������
		If Empty( HttpSession->PWSXF3HEADER[HEADER_PROSPECT] )
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������
			oObj:cHEADERTYPE := "PROSPECTVIEW"
			
			//cHEADERTYPE
			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_PROSPECT] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//�������������Ŀ
		//�Paginacao WEB�
		//���������������
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		
		//�������������������Ŀ
		//�Adicao de Query ADD�
		//���������������������
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
		     
		//��������������������������������Ŀ
		//�Parametros do metodo BRWPROSPECT�
		//����������������������������������
		oObj:cUSERCODE		:= GetUsrCode()
		oObj:cSELLERCODE	:= HttpSession->CODVENERP
		oObj:cQUERYADDWHERE	:= cQryAdd 
		oObj:cINDEXKEY		:= "US_COD"		
	
		If oObj:BRWPROSPECT()
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_PROSPECT][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO						, HttpSession->PWSXF3HEADER[HEADER_PROSPECT][1]	,;
							oObj:oWSBRWPROSPECTRESULT:oWSPROSPECTVIEW	, aWebHeader						,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWPROSPECTRESULT:oWSPROSPECTVIEW )
			
			If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
			PWSHTMLALERT( "", STR0001, PWSGetWSError(), "W_PWSV110.APW" ) //"Aviso"
		EndIf

	//������������������������Ŀ
	//�Busca de Processos Venda�
	//��������������������������
	Case HttpGet->F3Nome == "BRWPROCESS"
		//��������������������������������������������������Ŀ
		//� Inicializa Objeto WS - WSMTSELLEROPPORTUNITY	 �
		//����������������������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSELLEROPPORTUNITY"), WSMTSELLEROPPORTUNITY():New() )
		WsChgUrl( @oObj, "MTSELLEROPPORTUNITY.APW" )

		//������������������������������������������������������Ŀ
		//� Header da estrutura ProcessView 		   	    	 �
		//� - PROCESS     : Processo                             �
		//� - STAGE       : Estagio                              �
		//� - DESCRIPTION : Descricao                            �
		//��������������������������������������������������������
		If Empty( HttpSession->PWSXF3HEADER[HEADER_PROCESS] )
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������
			oObj:cHEADERTYPE := "PROCESSVIEW"
		
			//cHEADERTYPE
			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_PROCESS] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//�������������Ŀ
		//�Paginacao WEB�
		//���������������
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		
		//�������������������������������Ŀ
		//�Parametros do metodo BRWPROCESS�
		//���������������������������������
		oObj:cUSERCODE		:= GetUsrCode()
		oObj:cSELLERCODE	:= HttpSession->CODVENERP
		oObj:cINDEXKEY		:= ""

		//cUSERCODE,cSELLERCODE,cINDEXKEY
		If oObj:BRWPROCESS()
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_PROCESS][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO					,	HttpSession->PWSXF3HEADER[HEADER_PROCESS][1],;
							oObj:oWSBRWPROCESSRESULT:oWSPROCESSVIEW	,	aWebHeader									,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWPROCESSRESULT:oWSPROCESSVIEW )
			
			If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf

	//���������������������������Ŀ
	//�Busca de Avaliado\Avaliador�
	//�����������������������������
	Case HttpGet->F3Nome == "BRWAVALIAD"     
		//��������������������������������������������������Ŀ
		//� Inicializa Objeto WS - WSRHPERSONALDESENVPLAN	 �
		//����������������������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
		WsChgUrl( @oObj, "RHPERSONALDESENVPLAN.APW" )

		//������������������������������������������������������Ŀ
		//� Header da estrutura USER 				   	    	 �   
		//�	- UserID		: Codigo do Usuario					 �
		//� - UserName		: Descricao do Usuario               �
		//� - UserMat       : Codigo do Centro de Custo          �
		//� - UserCC		: Codigo do Centro de Custo          �
		//��������������������������������������������������������

		If Empty(HttpSession->PWSXF3HEADER[HEADER_AVALIADOR])    
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������
			
			oObj:cHEADERTYPE := "USER"
		   
			If oObj:GetHeaderRh()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_AVALIADOR] := { oObj:oWSGETHEADERRHRESULT:oWSBRWHEADER }    	
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//�������������Ŀ
		//�Paginacao WEB�
		//���������������
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		
		//�������������������������������Ŀ
		//�Parametros do metodo BRWPROCESS�
		//���������������������������������              
		
		oObj:cUserCode		:=	GetUsrCode()  
		oObj:cParticipantId	:=	HttpSession->cParticipantId
		oObj:cFiltro		:= 	If(!Empty(HttpGet->Busca),HttpGet->Busca,"")
		oObj:nPage			:= 	Val(HttpGet->cPagina)


		//cUserCode,cParticipantId
		If oObj:ShowAllParticipant()
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������  
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_AVALIADOR][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO,;
							HttpSession->PWSXF3HEADER[HEADER_AVALIADOR][1],;
							oObj:oWSSHOWALLPARTICIPANTRESULT:oWSUSER,;
							aWebHeader,;
							.F.,;
							"A",;
							,;
							0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������     

			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSSHOWALLPARTICIPANTRESULT:oWSUSER )
			HttpSession->USR_SKIN := "images"
			//If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
			//If !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca )
			If !Empty( HttpGet->Busca ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
	   		EndIf
		Else
	  		HttpSession->_HTMLERRO := { STR0003, STR0004, "javascript:window.close();"  } //"Dados enviados para Web Function Inv�lidos"
			cHtml := ExecInPage("PWSAMSG")
		EndIf

	//������������������������Ŀ
	//�Busca de Nr. de Pedidos �
	//��������������������������
	Case HttpGet->F3Nome == "BRWIDNUMBER"
		//��������������������������������������������������Ŀ
		//� Inicializa Objeto WS - WSMTCUSTOMERSALESORDER	 �
		//����������������������������������������������������
		If Type("HttpSession->PWSV042HEADER") == "A"
			oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSELLERSALESORDER"), WSMTSELLERSALESORDER():New() )
			WsChgURL( @oObj, "MTSELLERSALESORDER.APW" )
		Else
			oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTCUSTOMERSALESORDER"), WSMTCUSTOMERSALESORDER():New() )
			WsChgURL( @oObj, "MTCUSTOMERSALESORDER.APW" )
		EndIf

		//������������������������������������������������������Ŀ
		//� Carrega header da estrutura SalesOrderHeaderView	 �
		//��������������������������������������������������������
		If Empty( HttpSession->PWSXF3HEADER[HEADER_IDNUMBERS] )
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������
			oObj:cHEADERTYPE := "SALESORDERHEADERVIEW"
		
			//cHEADERTYPE
			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_IDNUMBERS] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//�������������Ŀ
		//�Paginacao WEB�
		//���������������
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		
		//�������������������������������Ŀ
		//�Parametros do metodo BRWIDORDER�
		//���������������������������������
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
		    
			//���������������������������������������Ŀ
			//�Ordena pedidos pelo numero da licitacao�
			//�����������������������������������������
			aSort(oObj:oWSBRWIDORDERRESULT:OWSSALESORDERHEADERVIEW,,,{|x,y| x:cBIDNUMBER < y:cBIDNUMBER })
			
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_IDNUMBERS][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO								,	HttpSession->PWSXF3HEADER[HEADER_IDNUMBERS][1],;
							oObj:oWSBRWIDORDERRESULT:oWSSALESORDERHEADERVIEW	,	aWebHeader									,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWIDORDERRESULT:oWSSALESORDERHEADERVIEW )
			
			If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf
				
	//������������������������Ŀ
	//�Busca de Nr. de Pedidos �
	//��������������������������
	Case HttpGet->F3Nome == "BRWSALESREP"

		//��������������������������������������������������Ŀ
		//� Inicializa Objeto WS - WSMTCUSTOMERSALESORDER	 �
		//����������������������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSELLER"), WSMTSELLER():New() )
		WsChgURL( @oObj, "MTSELLER.APW" )

		//������������������������������������������������������Ŀ
		//� Carrega header da estrutura SalesOrderHeaderView	 �
		//��������������������������������������������������������
		If Empty( HttpSession->PWSXF3HEADER[HEADER_VENDEDOR] )
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������
			oObj:cHEADERTYPE := "GENERICSTRUCT"

			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_VENDEDOR] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//�������������Ŀ
		//�Paginacao WEB�
		//���������������
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		
		//�������������������������������Ŀ
		//�Parametros do metodo BRWIDORDER�
		//���������������������������������
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
		    
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_VENDEDOR][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO								,	HttpSession->PWSXF3HEADER[HEADER_VENDEDOR][1],;
							oObj:oWSBRWSELLERRESULT:oWSGENERICSTRUCT			,	aWebHeader									,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWSELLERRESULT:oWSGENERICSTRUCT )
			
			If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf	


	//������������������������Ŀ
	//�Busca de Parceiros (AC4)�
	//��������������������������
	Case HttpGet->F3Nome == "BRWPARTNER"

		//��������������������������������������������������Ŀ
		//� Inicializa Objeto WS - WSMTSELLEROPPORTUNITY	 �
		//����������������������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSELLEROPPORTUNITY"), WSMTSELLEROPPORTUNITY():New() )
		WsChgURL( @oObj, "MTSELLEROPPORTUNITY.APW" )

		//������������������������������������������������������Ŀ
		//� Carrega header da estrutura GENERICSTRUCT			 �
		//��������������������������������������������������������
		If Empty( HttpSession->PWSXF3HEADER[HEADER_PARCEIRO] )
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������
			oObj:cHEADERTYPE := "GENERICSTRUCT"

			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_PARCEIRO] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//�������������Ŀ
		//�Paginacao WEB�
		//���������������
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		
		//�������������������������������Ŀ
		//�Parametros do metodo BRWPARTNER�
		//���������������������������������
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
		    
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_PARCEIRO][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO								,	HttpSession->PWSXF3HEADER[HEADER_PARCEIRO][1],;
							oObj:oWSBRWPARTNERRESULT:oWSGENERICSTRUCT			,	aWebHeader									,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBRWPARTNERRESULT:oWSGENERICSTRUCT )
			
			If ( !Empty( HttpGet->Tipo ) .AND. !Empty( HttpGet->Busca ) ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
			EndIf
		Else
			PWSGetWSError()
		EndIf	


	//������������������������Ŀ
	//�Busca de Contatos (SU5) �
	//��������������������������
	Case HttpGet->F3Nome == "BRWIDCONTACT"

		//��������������������������������������������������Ŀ
		//� Inicializa Objeto WS - WSMTSELLEROPPORTUNITY	 �
		//����������������������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSELLEROPPORTUNITY"), WSMTSELLEROPPORTUNITY():New() )
		WsChgURL( @oObj, "MTSELLEROPPORTUNITY.APW" )

		//������������������������������������������������������Ŀ
		//� Carrega header da estrutura CONTACTVIEW  			 �
		//��������������������������������������������������������
		If Empty( HttpSession->PWSXF3HEADER[HEADER_CONTATO] )
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������
			oObj:cHEADERTYPE := "CONTACTVIEW"

			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_CONTATO] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//�������������Ŀ
		//�Paginacao WEB�
		//���������������
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf
		
		//�����������������������������������Ŀ
		//� Parametros do metodo BRWIDCONTACT �
		//�������������������������������������
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
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader(	HttpSession->PWSXF3INFO, HttpSession->PWSXF3HEADER[HEADER_CONTATO][1], aWebHeader )

			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO							,	HttpSession->PWSXF3HEADER[HEADER_CONTATO][1],;
							oObj:oWSBRWIDCONTACTRESULT:oWSCONTACTVIEW		,	aWebHeader									,;
							.F., "A",, 0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������
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
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������			
			oObj:cHEADERTYPE := "COURSE"
		   
			If oObj:GetHeaderRh()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_CURSO] := { oObj:oWSGETHEADERRHRESULT:oWSBRWHEADER }    	
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//�������������Ŀ
		//�Paginacao WEB�
		//���������������
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf

		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
		WsChgUrl( @oObj, "RHCURRICULUM.APW" )
		
		//�������������������������������Ŀ
		//�Parametros do metodo BRWCOURSE �
		//���������������������������������              	
		//-- Recupera o curso selecionado na chamada do F3 
		HttpSession->cFiltro:= If( !Empty(HttpGet->Tipo), HttpGet->Tipo,HttpSession->cFiltro)
		oObj:nType			:= Val(HttpSession->cFiltro)
		oObj:nPage		:= Val(HttpGet->cPagina)
		oObj:cSearch	:= 	HttpGet->Busca

		//cUserCode,cParticipantId
		If oObj:BrwCourse()
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������  
			GridHeader(	HttpSession->PWSXF3INFO,;							//aGrid
						HttpSession->PWSXF3HEADER[HEADER_CURSO][1],;		//aHeader
						aWebHeader,;										//aWebCols
						NIL,; 												//oUserField					
						NIL,; 												//cNomeWS
						NIL) 												//cAlias					
					
			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO,;
							HttpSession->PWSXF3HEADER[HEADER_CURSO][1],;
							oObj:oWSBrwCourseRESULT:oWSCoursesCurriculum,;
							aWebHeader,;
							.F.,;
							"A",;
							,;
							0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������     

			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBrwCourseRESULT:oWSCoursesCurriculum )
			HttpSession->USR_SKIN := "images"

			If !Empty( HttpGet->Busca ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
	   		EndIf
		Else
	  		HttpSession->_HTMLERRO := { STR0003, STR0004, "javascript:window.close();"  } //"Dados enviados para Web Function Inv�lidos"
			cHtml := ExecInPage("PWSAMSG")
		EndIf	
	Case HttpGet->F3Nome == "BRWENTITY"
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
		WsChgUrl( @oObj, "RHPERSONALDESENVPLAN.APW" )

		If Empty(HttpSession->PWSXF3HEADER[HEADER_ENTIDADE])    
			//������������������������������Ŀ
			//�Parametros do metodo GETHEADER�
			//��������������������������������			
			oObj:cHEADERTYPE := "ENTITY"
		   
			If oObj:GetHeaderRh()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSXF3HEADER[HEADER_ENTIDADE] := { oObj:oWSGETHEADERRHRESULT:oWSBRWHEADER }    	
			Else
				PWSGetWSError()
			EndIf
		EndIf

		//�������������Ŀ
		//�Paginacao WEB�
		//���������������
		If Empty( HttpGet->cPagina )
			HttpGet->cPagina := "0"
		EndIf

		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
		WsChgUrl( @oObj, "RHCURRICULUM.APW" )
		
		//�������������������������������Ŀ
		//�Parametros do metodo BRWENTITY �
		//���������������������������������              	
		//-- Recupera o curso selecionado na chamada do F3 
		HttpSession->cFiltro:= If( !Empty(HttpGet->Tipo), HttpGet->Tipo,HttpSession->cFiltro)
		oObj:nType			:= Val(HttpSession->cFiltro)
		oObj:nPage			:= Val(HttpGet->cPagina)
		oObj:cSearch		:= 	HttpGet->Busca
	
		//cUserCode,cParticipantId
		If oObj:BrwEntity()
			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������  
			GridHeader(	HttpSession->PWSXF3INFO,;							//aGrid
						HttpSession->PWSXF3HEADER[HEADER_ENTIDADE][1],;		//aHeader
						aWebHeader,;										//aWebCols
						NIL,; 												//oUserField					
						NIL,; 												//cNomeWS
						NIL) 												//cAlias					
					
			//�������������������������������������Ŀ
			//�Funcao de montagem dos campos da tela�
			//���������������������������������������
			GridLinesEx( { 	HttpSession->PWSXF3INFO,;
							HttpSession->PWSXF3HEADER[HEADER_ENTIDADE][1],;
							oObj:oWSBrwEntityResult:oWSEntity,;
							aWebHeader,;
							.F.,;
							"A",;
							,;
							0 } )
			
			//����������������������������������Ŀ
			//�Script para abertura da tela de F3�
			//������������������������������������     

			HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSBrwEntityResult:oWSEntity )
			HttpSession->USR_SKIN := "images"

			If !Empty( HttpGet->Busca ) .OR. !Empty( HttpGet->TrcPag )
				Return ExecInPage( "PWSXF3GRID" )
	   		EndIf
		Else
	  		HttpSession->_HTMLERRO := { STR0003, STR0004, "javascript:window.close();"  } //"Dados enviados para Web Function Inv�lidos"
			cHtml := ExecInPage("PWSAMSG")
		EndIf
		
    //������������������Ŀ
    //�Busca de Cargos RH�
    //��������������������
    Case HttpGet->F3Nome == "GETRHPOSITION"
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
        WsChgUrl( @oObj, "RHPERSONALDESENVPLAN.APW" )

        If Empty(HttpSession->PWSXF3HEADER[HEADER_RHCARGO])    
            //������������������������������Ŀ
            //�Parametros do metodo GETHEADER�
            //��������������������������������          
            oObj:cHEADERTYPE := "RHPOSITION"
           
            If oObj:GetHeaderRh()
                //���������������������������Ŀ
                //�Retorno do Metodo GETHEADER�
                //�����������������������������
                HttpSession->PWSXF3HEADER[HEADER_RHCARGO] := { oObj:oWSGETHEADERRHRESULT:oWSBRWHEADER }        
            Else
                PWSGetWSError()
            EndIf
        EndIf

        //�������������Ŀ
        //�Paginacao WEB�
        //���������������
        If Empty( HttpGet->cPagina )
            HttpGet->cPagina := "0"
        EndIf

		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCompetence"), WSRHCompetence():New())
        WsChgUrl( @oObj, "RHCompetence.APW" )
        
        //�����������������������������������Ŀ
        //�Parametros do metodo GETRHPOSITION �
        //�������������������������������������                 
        //-- Recupera o cargo selecionado na chamada do F3 
        HttpSession->cFiltro:= HttpSession->cFiltro
		 oObj:nPage		:= Val(HttpGet->cPagina)
		 oObj:cSearch	:= HttpGet->Busca

        If oObj:GetRHPosition()
            //��������������������������������������������������Ŀ
            //�Funcao de montagem da descricao dos campos da tela�
            //����������������������������������������������������  
            GridHeader( HttpSession->PWSXF3INFO,;                           //aGrid
                        HttpSession->PWSXF3HEADER[HEADER_RHCARGO][1],;       //aHeader
                        aWebHeader,;                                     //aWebCols
                        NIL,;                                           //oUserField                    
                        NIL,;                                           //cNomeWS
                        NIL)                                            //cAlias                    
                    
            //�������������������������������������Ŀ
            //�Funcao de montagem dos campos da tela�
            //���������������������������������������
            GridLinesEx( {  HttpSession->PWSXF3INFO,;
                            HttpSession->PWSXF3HEADER[HEADER_RHCARGO][1],;
                            oObj:oWSGetRHPositionRESULT:oWSPositionView,;
                            aWebHeader,;
                            .F.,;
                            "A",;
                            ,;
                            0 } )
            
            //����������������������������������Ŀ
            //�Script para abertura da tela de F3�
            //������������������������������������     

            HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGetRHPositionRESULT:oWSPositionView )
            HttpSession->USR_SKIN := "images"

            If !Empty( HttpGet->Busca ) .OR. !Empty( HttpGet->TrcPag )
                Return ExecInPage( "PWSXF3GRID" )
            EndIf
        Else
            HttpSession->_HTMLERRO := { STR0003, STR0004, "javascript:window.close();"  } //"Dados enviados para Web Function Inv�lidos"
            cHtml := ExecInPage("PWSAMSG")
        EndIf   
	
	//����������������Ŀ
	//�Busca de Estados�
	//������������������
	Case HttpGet->F3Nome == "GETAREA"
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
        WsChgUrl( @oObj, "RHPERSONALDESENVPLAN.APW" )

        If Empty(HttpSession->PWSXF3HEADER[HEADER_AREA])    
            //������������������������������Ŀ
            //�Parametros do metodo GETHEADER�
            //��������������������������������          
            oObj:cHEADERTYPE := "SX5TABLE"
           
            If oObj:GetHeaderRh()
                //���������������������������Ŀ
                //�Retorno do Metodo GETHEADER�
                //�����������������������������
                HttpSession->PWSXF3HEADER[HEADER_AREA] := { oObj:oWSGETHEADERRHRESULT:oWSBRWHEADER }        
            Else
                PWSGetWSError()
            EndIf
        EndIf

        //�������������Ŀ
        //�Paginacao WEB�
        //���������������
        If Empty( HttpGet->cPagina )
            HttpGet->cPagina := "0"
        EndIf

		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCompetence"), WSRHCompetence():New())
        WsChgUrl( @oObj, "RHCompetence.APW" )
        
        //�����������������������������������Ŀ
        //�Parametros do metodo GETRHPOSITION �
        //�������������������������������������                 
        //-- Recupera o cargo selecionado na chamada do F3 
        HttpSession->cFiltro:= HttpSession->cFiltro
		oObj:nPage		:= Val(HttpGet->cPagina)
		oObj:cSearch	:= HttpGet->Busca
		oObj:cX5Id	:= HttpGet->F3Tabela
		HttpSession->F3Tabela := HttpGet->F3Tabela
        If oObj:GetX5Table()
            //��������������������������������������������������Ŀ
            //�Funcao de montagem da descricao dos campos da tela�
            //����������������������������������������������������  
            GridHeader( HttpSession->PWSXF3INFO,;                           //aGrid
                        HttpSession->PWSXF3HEADER[HEADER_AREA][1],;       //aHeader
                        aWebHeader,;                                     //aWebCols
                        NIL,;                                           //oUserField                    
                        NIL,;                                           //cNomeWS
                        NIL)                                            //cAlias                    
                    
            //�������������������������������������Ŀ
            //�Funcao de montagem dos campos da tela�
            //���������������������������������������
            GridLinesEx( {  HttpSession->PWSXF3INFO,;
                            HttpSession->PWSXF3HEADER[HEADER_AREA][1],;
                            oObj:oWSGetx5tableRESULT:oWSX5TableView,;
                            aWebHeader,;
                            .F.,;
                            "A",;
                            ,;
                            0 } )
            
            //����������������������������������Ŀ
            //�Script para abertura da tela de F3�
            //������������������������������������     

            HttpSession->PWSXF3SCRIPT := GeraJs( aGetTemp[1], oObj:oWSGetX5TableRESULT:oWSX5TableView )
            HttpSession->USR_SKIN := "images"

            If !Empty( HttpGet->Busca ) .OR. !Empty( HttpGet->TrcPag )
                Return ExecInPage( "PWSXF3GRID" )
            EndIf
        Else
            HttpSession->_HTMLERRO := { STR0003, STR0004, "javascript:window.close();"  } //"Dados enviados para Web Function Inv�lidos"
            cHtml := ExecInPage("PWSAMSG")
        EndIf   	
Otherwise
	//Nossa!!!
EndCase

ExecInPage( "PWSXF3FRAME" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSXF3GRID�Autor  �Luiz Felipe Couto    � Data �  24/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Retorna a tela com os dados do F3 do sistema.               ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������ͼ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSXF3GRID()

Local cHtml := ""					//Pagina WEB

WEB EXTENDED INIT cHtml START "InSite"

ExecInPage( "PWSXF3GRID" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSXF3BUSC�Autor  �Luiz Felipe Couto    � Data �  24/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Retorna a tela de busca dos dados do F3 do sistema.         ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������ͼ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSXF3BUSCA()

Local cHtml := ""					//Pagina WEB

WEB EXTENDED INIT cHtml START "InSite"

ExecInPage( "PWSXF3BUSCA" )

WEB EXTENDED END

Return cHtml
