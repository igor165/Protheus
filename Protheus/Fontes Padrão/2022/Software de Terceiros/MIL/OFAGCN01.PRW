#include "protheus.ch"

/*/{Protheus.doc} mil_ver()
		Versao do fonte modelo novo

		@author Vinicius Gati
		@since  12/06/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "1"

/*

8.2.1. Relatórios de vendas

* Número de itens com vendas por ano (12, 24 e 36 meses) para itens originais e paralelos

* Quantidade vendida para itens originais e paralelos:
    - Mês a mês (12, 24 e 36 meses)
    - Por loja
    - Por item

*/
#define cBox1 "12=12;24=24;36=36"
#define n1Filial 1
#define n1Peca   2
#define n1Grupo  3
#define n1Qtd    4
#define n1ValorU 5
#define n1ValorT 6

/*/{Protheus.doc} OFAGCN01
	Consulta de vendas VMI AGCO
	
	@type function
	@author Vinicius Gati
	@since 03/10/2017
/*/
function OFAGCN01()
	Private oArrHlp       := DMS_ArrayHelper():New()
	Private oSqlHlp       := DMS_SqlHelper():New()
	Private oDpm          := DMS_DPM():New()
	Private aSizeAut      := MsAdvSize(.t.)
	Private oVmiPar       := OFAGVmiParametros():New()
	Private oInterfHelper := Nil
	Private nOpc          := 1
	Private o1GetDados    := Nil
	Private cBoxFil       := ""
	Private oDlg

	aBoxFil := oArrHlp:Map(oVmiPar:filiais(), {|cFil| cFil + "=" + cFil })
	cBoxFil := oArrHlp:Join(aBoxFil, ';')

	oDlg := FS_UILoad()

	ACTIVATE MSDIALOG oDlg
Return

/*/{Protheus.doc} FS_UILoad
	Cria tela

	@author Vinicius Gati
	@since  03/10/2017
/*/
Static Function FS_UILoad()
	Local oSizePrinc, oSizeFiltro
	Local oInterfHelper := DMS_InterfaceHelper():New()
	Local nIdx          := 1
	Local aFilis        := oDpm:GetFiliais()
	Local oCampo1       := oCampo2 := oCampo3 := oCampo4 := oCampo5 := oCampo6 := oCampo7 := Nil

	cBox := oArrHlp:Map(aFilis, {|aEl| aEl[1]+"="+aEl[1] })
	cBox := oArrHlp:Join(cBox, ';')

	// nOpc (1 - pesquisa; 2 - visualização; 3 - inclusão; 4 - alteração; 5 - exclusão)
	oInterfHelper:nOpc := nOpc

	// divisão da tela
	aDivTela := { ;
		{ "CABEC"    , 110, 058 , .T. , .F. } ,; // Cabecalho
		{ "MIDDLE"   , 100, 150 , .T. , .F. }  ; // Listbox
	}

	// CABEC será dividido conforme
	aDivTela2 := { ;
		{ "ESQUERDA" , 400, 010 , .T. , .t. },; // mGet
		{ "DIREITA"  , 080, 050 , .F. , .t. }  ; // Botoes
	}

	// Criando a janela
	oSizePrinc := oInterfHelper:CreateDefSize(.f., aDivTela)
	oSizePrinc:Process()
	oInterfHelper:SetDefSize(oSizePrinc)
	oDlg := oInterfHelper:CreateDialog("Consulta de quantidade vendida")

	// FAzendo a divisão do filtro no cabecalho
	oSizeFiltro := oInterfHelper:CreateDefSize(.f., aDivTela2, oSizePrinc:GetNextCallArea("CABEC"))
	oSizeFiltro:lLateral := .t.	// Calcula em colunas
	oSizeFiltro:Process()

	oInterfHelper:setDialog(oDlg)

	oInterfHelper:SetDefSize(oSizeFiltro, "DIREITA")
	OFAGCN0101_CreateAcoes()

	// Parte de cima da tela
	oInterfHelper:SetDefSize(oSizeFiltro, "ESQUERDA")
	OFAGCN0102_CreateFiltros()

	oInterfHelper:Clean()
	oInterfHelper:nOpc := nOpc

	// Parte do meio -- resultado 
	oInterfHelper:SetDefSize(oSizePrinc, "MIDDLE")
	OFAGCN0103_CreateResultado()

	// oInterfHelper:addColLBox({{'X3', 'VQZ_FILIAL'}})
	// oInterfHelper:addColLBox({{'X3', 'VQZ_TIPO'}, {'TAMANHO', 15} })
	// oInterfHelper:addColLBox({{'X3', 'VQZ_COONUM'}})
	// oInterfHelper:addColLBox({{'X3', 'VQZ_NOMARQ'}})
	// oInterfHelper:AddColLBox({{'X3', 'VQZ_DATA'},;
	// 	{'CODEBLOCK', "{ || STOD( NOME_OBJETO:aArray[ NOME_OBJETO:nAt, POSICAO_COLUNA ] ) }"};
	// })
	// oInterfHelper:addColLBox({{'X3', 'VQZ_HORA'}})
	// oInterfHelper:addColLBox({{'X3', 'VQZ_CODIGO'}})

	// o1GetDados := oInterfHelper:CreateLBox("o1GetDados")
	// o1GetDados:bChange := {||;
	// 	o2GetDados:SetArray( OFINJD4404_FiltrarDetalhes() ),;
	// 	o2GetDados:Refresh() ;
	// }
	// o1GetDados:SetArray( OFINJD4401_FiltraVQZ() )
	o1GetDados:Refresh()

	oInterfHelper:Clean()
Return oDlg

/*/{Protheus.doc} CreateAcoes
	Cria os botoes de acao do relatorio
	
	@type function
	@author Vinicius Gati
	@since 03/10/2017
/*/
Static Function OFAGCN0101_CreateAcoes()
	TButton():New(;
		oSizeFiltro:GetDimension("DIREITA","LININI") + 00, ;
		oSizeFiltro:GetDimension("DIREITA","COLINI")    , ;
		"Filtrar", ;
		oDlg , { || OFAGCN0104_CreateResultado() }, ;
		oSizeFiltro:GetDimension("DIREITA","XSIZE") ;
		, 010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(;
		oSizeFiltro:GetDimension("DIREITA","LININI") + 44, ;
		oSizeFiltro:GetDimension("DIREITA","COLINI") , ;
		"Sair", ;
		oDlg , { || oDlg:End() }, ;
		oSizeFiltro:GetDimension("DIREITA","XSIZE") ;
		, 010,,,.F.,.T.,.F.,,.F.,,,.F. )
Return

/*/{Protheus.doc} Create Filtros
	Cria os campos do filtro da consulta

	Filtro originais/paralelos, produto filial e qtd de meses
	
	@type function
	@author Vinicius Gati
	@since 03/10/2017
/*/
Static Function OFAGCN0102_CreateFiltros()
	oInterfHelper:SetOwnerPvt("OFINJD44")
	oInterfHelper:SetPrefixo("SBM")
	oInterfHelper:AddMGet("BM_PROORI")
	oInterfHelper:AddMGet("B1_COD")
	oInterfHelper:AddMGet("VS3_FILIAL", {;
		{'X3_CBOX'   , cBoxFil        },;
		{'X3_TAMANHO', FWSizeFilial() } ;
	})
	oInterfHelper:AddMGet("VS3_FILIAL", {;
		{'X3_CBOX'   , cBox1 },;
		{'X3_TAMANHO', 2     } ;
	})
	oInterfHelper:CreateMSMGet(.F.)
Return

/*/{Protheus.doc} CreateResultado
	Cria os get que vão mostrar o resultado da pesquisa

	* Número de itens com vendas por ano (12, 24 e 36 meses) para itens originais e paralelos

	@type function
	@author Vinicius Gati
	@since 03/10/2017
/*/
Static Function OFAGCN0103_CreateResultado()
	oInterfHelper:SetOwnerPvt("OFINJD44")
	oInterfHelper:SetPrefixo("SB2")
	oInterfHelper:AddMGet("B2_QATU", {{"X3_TITULO", "Qtd 12"}, {"NOMECAMPO", "QTD12"}})
	oInterfHelper:AddMGet("B2_QATU", {{"X3_TITULO", "Qtd 24"}, {"NOMECAMPO", "QTD24"}})
	oInterfHelper:AddMGet("B2_QATU", {{"X3_TITULO", "Qtd 36"}, {"NOMECAMPO", "QTD36"}})
	oInterfHelper:CreateMSMGet(.F.)
Return

/*/{Protheus.doc} OFAGCN0104_CreateResultado
	
	Rodará a query e preencherá a tela

	@type  Static Function
	@author Vinicius Gati
	@since 03/10/2017
	@version 12
/*/
Static Function OFAGCN0104_CreateResultado

Return 