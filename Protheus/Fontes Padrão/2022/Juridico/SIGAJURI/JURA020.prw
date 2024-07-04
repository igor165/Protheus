#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RWMAKE.CH"
#include "REPORT.CH"
#include "TOPCONN.CH"
#INCLUDE "JURA020.CH"

Static lXML
Static lXmlWS
Static oPnl
Static aCodDup        := {}
Static lMsg           := .T.
Static cMask          := STR0114 + "(*.XML)|*.XML| " + STR0115 + "(*.Txt)|*.TXT|" // "Documentos Anexos" | "Arquivos Texto"
Static oGrid
Static cCajuris       := ""

Static __cTxtP        := "1"

Static cPalavraChaves := ""
Static aPalavras      := {}
Static lChkAnd        := .T. //variável do tipo lógica que define se no filtro das palavras chave será usado OR ou AND
Static cProcessos     := ""
Static aAgrupadores   := {}

//<- Encapsulamento: cTextoPub  ->
Static Function SetcTextoPub(xVal)
Return __cTxtP := xVal

Static Function GetcTextoPub()
Return __cTxtP

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA020
Importação de documentos

@author Jorge Luis Branco Martins Junior
@since 24/02/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA020()

	Local aArea    := GetArea()
	Local cTipoImp := SuperGetMV('MV_JTPIMP',, '3') 			//1=XML, 2=KURIER, 3=AMBOS
	Local lTOTVS   := SuperGetMV('MV_JPUBTOT',, '2') == '1'		//Publicações pela Totvs\Vista

	Private lAbortPrint := .F. //Indica se a operação foi cancelada. Usada para controlar a opção de cancelar da funcionalidade PROCESSAPrivate lAbortPrint := .F. //Indica se a operação foi cancelada. Usada para controlar a opção de cancelar da funcionalidade PROCESSA
	Private lAutomato   := .F.

	oGrid    := Nil
	cCajuris := ""

	cPalavraChaves := ""  //Zera as variaveis estaticas ao entrar pela primeira vez.
	aPalavras      := {}
	aAgrupadores   := {}
	cProcessos     := ""

	If lTOTVS
		J20PergImp(.F., "2")
	ElseIf cTipoImp == '3'
		oGrid:=FWGridProcess():New("JURA020A",STR0010,STR0109,{|| J20PergImp(.F., cTipoImp)},"JURA020A"/*Pergunte*/)//"Importação de Publicações" | "Escolha o tipo de importação"
		oGrid:SetMeters(1)
		oGrid:Activate()
	Else
		J20PergImp(.F., cTipoImp)
	Endif

	RestArea(aArea)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} J20PergImp
Executa o Pergunte referente a opção selecionada (XML ou Kurier)

@param  lF12        Indica se a chamada é vinda da Chave F12
@param  cTipoImp    Tipo da importação: 1=XML, 2=KURIER, 3=AMBOS

@author Jorge Luis Branco Martins Junior
@since 25/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J20PergImp(lF12, cTipoImp)

	Local lRet     := .F.
	Local lTOTVS   := SuperGetMV('MV_JPUBTOT',, '2') == '1'		//Publicações pela Totvs\Vista
	Local cDescEmp := IIF(lTOTVS, "TOTVS", "Kurier")

	oGrid    := Nil
	cCajuris := ""

	lXmlWS := SuperGetMV('MV_JKURXML',, '2') == '1' .Or. lTOTVS

	If !lF12
		If cTipoImp == '1' //XML
			lXML := .T.
		ElseIf cTipoImp == '2' //KURIER
			lXML := .F.
		Else
			lXML := (MV_PAR01 == 1)
		EndIf
	EndIf

	If lXML
		oGrid:=FWGridProcess():New("JURA020",STR0110,STR0111,{|lEnd| lRet := J20VlPgt(1, oGrid, @lEnd)},"JURA020XML"/*Pergunte*/)//"Importação XML" | "Importação de arquivo XML. É necessário selecionar o documento"
		oGrid:SetMeters(1)
		oGrid:Activate()
	Else
		oGrid:=FWGridProcess():New("JURA020", I18n(STR0112, {cDescEmp}), I18n(STR0113, {cDescEmp}),{|lEnd| lRet := J20VlPgt(2, oGrid, @lEnd)},"JURA020KUR"/*Pergunte*/)//"Importação #1" | "Importação de dados via #1. Selecione um período com intervalo máximo de 30 dias para filtro."
		oGrid:SetMeters(1)
		oGrid:Activate()
	EndIf

	If lRet
		oGrid:IsFinished()
	EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author André Spirigoni
@since 24/02/14
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0033 , "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
	aAdd( aRotina, { STR0116 , "VIEWDEF.JURA020", 0, 2, 0, NIL } ) // "Visualizar"
	aAdd( aRotina, { STR0117 , "VIEWDEF.JURA020", 0, 3, 0, NIL } ) // "Incluir"
	aAdd( aRotina, { STR0118 , "VIEWDEF.JURA020", 0, 4, 0, NIL } ) // "Alterar"
	aAdd( aRotina, { STR0061 , "VIEWDEF.JURA020", 0, 5, 0, NIL } ) // "Excluir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de importação de documentos

@author André Spirigoni
@since 24/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel     := FWLoadModel( "JURA020" )
	Local oStructNR0 := FWFormStruct( 2, "NR0" )
	Local oStrNR01   := FWFormStruct( 2, "NR0" )
	Local oStrNR02   := FWFormStruct( 2, "NR0" )
	Local oStrNR03   := FWFormStruct( 2, "NR0" )
	Local oStrNR04   := FWFormStruct( 2, "NR0" )
	Local oStrNR05   := FWFormStruct( 2, "NR0" )
	Local oStrNR06   := FWFormStruct( 2, "NR0" )
	Local oView
	Local lAtoAuto   := FwAliasInDic("O0O") .And. FwAliasInDic("O0P") //Define se tem o tratamento para Ato Automático
	Local lOcultNLoc := J020VldPar('MV_PAR08')
	Local lOcultImp  := J020VldPar('MV_PAR09')
	Local oAuxStruct := Nil	
	Local nI         := 0
	Local aCposRemov := {}

	If oGrid <> Nil
		oGrid:SetIncMeter(1)
	EndIf

	//campos virtuais
	oStrNR01:AddField( ;
	"NR0__TICK"      , ;             // [01] Campo
	'01'             , ;             // [02] Ordem
	''               , ;             // [03] Titulo
	''               , ;             // [04] Descricao
	, ;                              // [05] Help
	'CHECK'          , ;             // [06] Tipo do campo   COMBO, Get ou CHECK
	''               , ;             // [07] Picture
	, ;             // [08] PictVar
	''               )               // [09] F3

	oStrNR02:AddField( ;
	"NR0__TICK"      , ;             // [01] Campo
	'01'             , ;             // [02] Ordem
	''               , ;             // [03] Titulo
	''               , ;             // [04] Descricao
	, ;                              // [05] Help
	'CHECK'          , ;             // [06] Tipo do campo   COMBO, Get ou CHECK
	''               , ;             // [07] Picture
	, ;             // [08] PictVar
	''               )               // [09] F3

	oStrNR03:AddField( ;
	"NR0__TICK"      , ;             // [01] Campo
	'01'             , ;             // [02] Ordem
	''               , ;             // [03] Titulo
	''               , ;             // [04] Descricao
	, ;                              // [05] Help
	'CHECK'          , ;             // [06] Tipo do campo   COMBO, Get ou CHECK
	''               , ;             // [07] Picture
	, ;             // [08] PictVar
	''               )               // [09] F3

	oStrNR04:AddField( ;
	"NR0__TICK"      , ;             // [01] Campo
	'01'             , ;             // [02] Ordem
	''               , ;             // [03] Titulo
	''               , ;             // [04] Descricao
	, ;                              // [05] Help
	'CHECK'          , ;             // [06] Tipo do campo   COMBO, Get ou CHECK
	''               , ;             // [07] Picture
	, ;             // [08] PictVar
	''               )               // [09] F3

	oStrNR06:AddField( ;
	"NR0__TICK"      , ;             // [01] Campo
	'01'             , ;             // [02] Ordem
	''               , ;             // [03] Titulo
	''               , ;             // [04] Descricao
	, ;                              // [05] Help
	'CHECK'          , ;             // [06] Tipo do campo   COMBO, Get ou CHECK
	''               , ;             // [07] Picture
	, ;             // [08] PictVar
	''               )               // [09] F3

	If lXml .And. Empty(MV_PAR02)
		oStructNR0:AddField( ;
		"NR0__PCAM"        , ;         // [01] Campo
		'01'               , ;         // [02] Ordem
		STR0120            , ;         // [03] Titulo // "Caminho:"
		STR0121            , ;         // [04] Descricao // "Caminho importação"
		, ;                            // [05] Help
		'GET'              , ;         // [06] Tipo do campo   COMBO, Get ou CHECK
		'@!'               , ;         // [07] Picture
		, ;                            // [08] PictVar
		''                 )           // [09] F3

		oStructNR0:AddField( ;
		'BOTAO'            , ;         // [01] Campo
		"02"               , ;         // [02] Ordem
		STR0122            , ;         // [03] Titulo // "Arquivo XML"
		STR0122            , ;         // [04] Descricao // "Arquivo XML"
		NIL                , ;         // [05] Help
		'BT'               )           // [06] Tipo do campo   COMBO, Get ou CHECK

		oStructNR0:AddField( ;
		"NR0__TPARQ"       , ;                            // [01] Campo
		'03'               , ;                            // [02] Ordem
		STR0123            , ;                            // [03] Titulo // "Tipo Arquivo XML"
		STR0123            , ;                            // [04] Descricao // "Tipo Arquivo XML"
		, ;                                               // [05] Help
		'C'                , ;                            // [06] Tipo do campo   COMBO, Get ou CHECK
		"@!"               , ;                            // [07] Picture
		, ;                                               // [08] PictVar
		, ;                                               // [09] F3
		.T.                , ;                            // [10] Editavel
		""                 , ;                            // [11] Folder
		, ;                                               // [12] Group
		{" ","1="+STR0002,"2="+STR0003,"3="+STR0004} , ;  // [13] Lista Combo //"1=Procergs","2=DaJusti","3=Destaque"
		1                  , ;                            // [14] Tam Max Combo
		""                 , ;                            // [15] Inic. Browse
		.F.                )                              // [16] Virtual

		oStructNR0:AddField( ;
		'BOTAO2'           , ;         // [01] Campo
		"04"               , ;         // [02] Ordem
		STR0015            , ;         // [03] Titulo // "Importar Arquivo"
		STR0015            , ;         // [04] Descricao // "Importar Arquivo"
		NIL                , ;         // [05] Help
		'BT'               )           // [06] Tipo do campo   COMBO, Get ou CHECK

	EndIf
	If !lOcultImp
		oStructNR0:AddField( ;
		"NR0__PIMP"        , ;          // [01] Campo
		'ZB'               , ;          // [02] Ordem
		STR0130            , ;          // [03] Titulo // "Qtd. Importadas"
		STR0131            , ;          // [04] Descricao // "Qtd Publicações Importadas"
		, ;                             // [05] Help
		'GET'              , ;          // [06] Tipo do campo   COMBO, Get ou CHECK
		'@!'               , ;          // [07] Picture
		, ;                             // [08] PictVar
		''                 )            // [09] F3
	EndIf

	oStructNR0:AddField( ;
	"NR0__PLOC"        , ;           // [01] Campo
	'ZC'               , ;           // [02] Ordem
	STR0124            , ;           // [03] Titulo // "Qtd. Localizadas"
	STR0125            , ;           // [04] Descricao // "Qtd Publicações localizadas"
	, ;                              // [05] Help
	'GET'              , ;           // [06] Tipo do campo   COMBO, Get ou CHECK
	'@!'               , ;           // [07] Picture
	, ;                              // [08] PictVar
	''                 )             // [09] F3

	If !lXml .And. !lXmlWS
		oStructNR0:AddField( ;
		"NR0__PPROV"       , ;         // [01] Campo
		'ZF'               , ;         // [02] Ordem
		STR0128            , ;         // [03] Titulo // "Qtd. Prováveis"
		STR0129            , ;         // [04] Descricao // "Qtd Publicações Prováveis"
		, ;                            // [05] Help
		'GET'              , ;         // [06] Tipo do campo   COMBO, Get ou CHECK
		'@!'               , ;         // [07] Picture
		, ;                            // [08] PictVar
		''                 )           // [09] F3
	EndIf

	If lXml .Or. lXmlWS
		If !lOcultNLoc
			oStructNR0:AddField( ;
			"NR0__PNLOC"       , ;        // [01] Campo
			'ZD'               , ;        // [02] Ordem
			STR0132            , ;        // [03] Titulo // "Qtd. Não Localizadas"
			STR0133            , ;        // [04] Descricao // "Qtd Publicações não localizadas"
			, ;                           // [05] Help
			'GET'              , ;        // [06] Tipo do campo   COMBO, Get ou CHECK
			'@!'               , ;        // [07] Picture
			, ;                           // [08] PictVar
			''                 )          // [09] F3
		EndIf
		oStructNR0:AddField( ;
		"NR0__PDUP"        , ;        // [01] Campo
		'ZE'               , ;        // [02] Ordem
		STR0134            , ;        // [03] Titulo // "Qtd. Duplicados"
		STR0135            , ;        // [04] Descricao // "Qtd Processos duplicadas"
		, ;                           // [05] Help
		'GET'              , ;        // [06] Tipo do campo   COMBO, Get ou CHECK
		'@!'               , ;        // [07] Picture
		, ;        // [08] PictVar
		''                 )          // [09] F3
	EndIf

	If lXml .Or. lXmlWS
		oStructNR0:AddField( ;
		"NR0__PDEL"        , ;           // [01] Campo
		'ZF'               , ;           // [02] Ordem
		STR0126            , ;           // [03] Titulo // "Qtd. Excluídas"
		STR0127            , ;           // [04] Descricao // "Qtd Publicações excluídas"
		, ;                              // [05] Help
		'GET'              , ;           // [06] Tipo do campo   COMBO, Get ou CHECK
		'@!'               , ;           // [07] Picture
		, ;                              // [08] PictVar
		''                 )             // [09] F3
	Else
		oStructNR0:AddField( ;
		"NR0__PDEL"        , ;           // [01] Campo
		'ZD'               , ;           // [02] Ordem
		STR0126            , ;           // [03] Titulo // "Qtd. Excluídas"
		STR0127            , ;           // [04] Descricao // "Qtd Publicações excluídas"
		, ;                              // [05] Help
		'GET'              , ;           // [06] Tipo do campo   COMBO, Get ou CHECK
		'@!'               , ;           // [07] Picture
		, ;                              // [08] PictVar
		''                 )             // [09] F3
	EndIf

	// Remove os campos do cabeçalho
	If oStructNR0:HasField("NR0_LOGIN")
		oStructNR0:RemoveField("NR0_LOGIN")
	EndIf
	
	If oStructNR0:HasField("NR0_ERRO")
		oStructNR0:RemoveField("NR0_ERRO")
	EndIf

	If oStructNR0:HasField("NR0_FILPRO")
		oStructNR0:RemoveField("NR0_FILPRO")
	EndIf

	oStructNR0:RemoveField("NR0_CODSEQ")
	oStructNR0:RemoveField("NR0_CAJURI")
	oStructNR0:RemoveField("NR0_NUMPRO")
	oStructNR0:RemoveField("NR0_SITUAC")
	oStructNR0:RemoveField("NR0_OBS")
	oStructNR0:RemoveField("NR0_TEORPB")
	oStructNR0:RemoveField("NR0_PAGINA")
	oStructNR0:RemoveField("NR0_CODREL")
	oStructNR0:RemoveField("NR0_NOME")
	oStructNR0:RemoveField("NR0_JORNAL")
	oStructNR0:RemoveField("NR0_VARA")
	oStructNR0:RemoveField("NR0_CIDADE")
	oStructNR0:RemoveField("NR0_ORGAO")
	oStructNR0:RemoveField("NR0_DTALTE")
	oStructNR0:RemoveField("NR0_USRALT")
	oStructNR0:RemoveField("NR0_DTEXCL")
	oStructNR0:RemoveField("NR0_USREXC")
	oStructNR0:RemoveField("NR0_SITUAO")
	oStructNR0:RemoveField("NR0_DTPUBL")
	oStructNR0:RemoveField("NR0_CODIMP")
	oStructNR0:RemoveField("NR0_CCLIEN")
	oStructNR0:RemoveField("NR0_DCLIEN")
	oStructNR0:RemoveField("NR0_PROCO")
	oStructNR0:RemoveField("NR0_DADVOG")
	oStructNR0:RemoveField("NR0_NOMEPC")
	oStructNR0:RemoveField("NR0_DADVPC")
	oStructNR0:RemoveField("NR0_NOMEPI")
	oStructNR0:RemoveField("NR0_FONTE")
	oStructNR0:RemoveField("NR0_DTCHEG")
	oStructNR0:RemoveField("NR0_CAJURP")
	oStructNR0:RemoveField("NR0_SIGLA")

	// Desconsidera a configuração do X3_BROWSE e faz tratamento padrão de acordo com o tipo de importação (XML / Kurrier)
	If !lXml
		If oStrNR01:HasField("NR0_CODIMP")
			oStrNR01:RemoveField("NR0_CODIMP")
		EndIf
		If oStrNR01:HasField("NR0_FILPRO")
			oStrNR01:RemoveField("NR0_FILPRO")
		EndIf
		If oStrNR02:HasField("NR0_CODIMP")
			oStrNR02:RemoveField("NR0_CODIMP")
		EndIf
		If oStrNR05:HasField("NR0_FILPRO")
			oStrNR05:RemoveField("NR0_FILPRO")
		EndIf
		If oStrNR06:HasField("NR0_FILPRO")
			oStrNR06:RemoveField("NR0_FILPRO")
		EndIf
	EndIf

	// valida se é Kurier para mostrar o campo codrel.
	If (!lXml .Or. lXmlWS)
		If oStrNR03:HasField("NR0_CODIMP")
			oStrNR03:RemoveField("NR0_CODIMP")
		EndIf
	Else
		If oStrNR03:HasField("NR0_CODREL")
			oStrNR03:RemoveField("NR0_CODREL")
		EndIf
	EndIf

	// Aplica o RemoveField para os campos dos Grids, cujo usuario configurou como "X3_BROWSE" == "N"
	oAuxStruct := FWFormStruct(2, "NR0", {| cCampo | IIF( GetSX3Cache(cCampo, "X3_BROWSE") == "N", .T., .F. ) })
	aCposRemov := aClone(oAuxStruct:aFields)

	If len(aCposRemov) > 0

		For nI := 1 To Len(aCposRemov)

			// //-- Remove os campos do cabeçalho
			// If oStructNR0:HasField(aCposRemov[nI][1]) 
			// 	oStructNR0:RemoveField(aCposRemov[nI][1])
			// EndIf

			//-- Remove os campos do grid 1 - Localizadas
			If oStrNR01:HasField(aCposRemov[nI][1])
				oStrNR01:RemoveField(aCposRemov[nI][1])
			EndIf

			//-- Remove os campos do grid 2 - Duplicadas
			If oStrNR02:HasField(aCposRemov[nI][1]) 
				oStrNR01:RemoveField(aCposRemov[nI][1])
			EndIf

			//-- Remove os campos do grid 3 - Não localizadas
			If oStrNR03:HasField(aCposRemov[nI][1])
				oStrNR03:RemoveField(aCposRemov[nI][1])
			EndIf

			//-- Remove os campos do grid 4 - Excluídas
			If oStrNR04:HasField(aCposRemov[nI][1])
				oStrNR04:RemoveField(aCposRemov[nI][1])
			EndIf

			//-- Remove os campos do grid 5 - Importadas
			If oStrNR05:HasField(aCposRemov[nI][1])
				oStrNR05:RemoveField(aCposRemov[nI][1])
			EndIf

			//Remove os campos do grid 6 - Prováveis
			If oStrNR06:HasField(aCposRemov[nI][1])
				oStrNR06:RemoveField(aCposRemov[nI][1])
			EndIf

		Next nI
	EndIf

	JurSetAgrp( 'NR0',, oStructNR0 )

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( "JURA020_PUB", oStructNR0, "NR0MASTER"  )

	oView:AddGrid( "NR01", oStrNR01, "NR0DETAIL1")

	If lXml .Or. lXmlWS
		oView:AddGrid( "NR02", oStrNR02, "NR0DETAIL2")
			If !lOcultNLoc
				oView:AddGrid( "NR03", oStrNR03, "NR0DETAIL3")
			EndIf
	EndIf

	oView:AddGrid( "NR04", oStrNR04, "NR0DETAIL4")
	If !lOcultImp
		oView:AddGrid( "NR05", oStrNR05, "NR0DETAIL5")
	EndIf
	If !lXml .And. !lXmlWS
		oView:AddGrid( "NR06", oStrNR06, "NR0DETAIL6")
	EndIf

	oView:CreateHorizontalBox( "FORMMAIN" , 50 )
	oView:CreateHorizontalBox( "FORMABAS" , 50 )

	oView:CreateVerticalBox(  'INFERIOR', 100, 'FORMMAIN'  )

	oView:CreateHorizontalBox( 'FMAIN', 30, 'INFERIOR' )
	oView:CreateHorizontalBox( 'FTEOR', 70, 'INFERIOR' )

	oView:CreateFolder("FOLDER_01","FORMABAS")
	If !lOcultImp
		oView:AddSheet("FOLDER_01", "ABA_05", STR0136, { || TeorRefresh(,oView, ,"NR0DETAIL5") } ) //"Publicações importadas"
	EndIf
	oView:AddSheet("FOLDER_01", "ABA_01", STR0137, { || TeorRefresh(,oView, ,"NR0DETAIL1") } ) //"Publicações localizadas"

	If lXml .Or. lXmlWS
		If !lOcultNLoc
			oView:AddSheet("FOLDER_01", "ABA_03", STR0138, { || TeorRefresh(,oView,,"NR0DETAIL3") } ) //"Publicações não localizadas"
		EndIf
		oView:AddSheet("FOLDER_01", "ABA_02", STR0139, { || TeorRefresh(,oView, ,"NR0DETAIL2") } ) //"Processos duplicados"
	EndIf

	oView:AddSheet("FOLDER_01", "ABA_04", STR0140, { || TeorRefresh(,oView, ,"NR0DETAIL4") } ) //"Publicações excluídas"

	If !lXml .And. !lXmlWS
		oView:AddSheet("FOLDER_01", "ABA_06", STR0141, { || TeorRefresh(,oView, ,"NR0DETAIL6") } ) //"Publicações prováveis"
	EndIf

	If !lOcultImp
		oView:CreateHorizontalBox("FORMF05",100,,,'FOLDER_01',"ABA_05")
	EndIf
	oView:CreateHorizontalBox("FORMF01",100,,,'FOLDER_01',"ABA_01")

	If lXml .Or. lXmlWS
		oView:CreateHorizontalBox("FORMF03",100,,,'FOLDER_01',"ABA_03")
		oView:CreateHorizontalBox("FORMF02",100,,,'FOLDER_01',"ABA_02")
	Endif

	oView:CreateHorizontalBox("FORMF04",100,,,'FOLDER_01',"ABA_04")
	oView:CreateHorizontalBox("FORMF06",100,,,'FOLDER_01',"ABA_06")

	oView:SetOwnerView( "JURA020_PUB" , "FMAIN" )

	oView:SetOwnerView( "NR01" , "FORMF01" )

	If lXml .Or. lXmlWS
		oView:SetOwnerView( "NR02" , "FORMF02" )
		If !lOcultNLoc
			oView:SetOwnerView( "NR03" , "FORMF03" )
		EndIf
	Endif

	oView:SetOwnerView( "NR04" , "FORMF04" )
	If !lOcultImp
		oView:SetOwnerView( "NR05" , "FORMF05" )
	EndIf

	If !lXml .And. !lXmlWS
		oView:SetOwnerView( "NR06" , "FORMF06" )
	Endif

	// Cria componentes nao MVC
	oView:AddOtherObject("OTHER_TEOR", {|oPanel,oView, x, y| TelaTeor(.F.,oPanel,,oView, x)})

	oView:SetOwnerView("OTHER_TEOR",'FTEOR')

	oView:SetViewAction( 'REFRESH', { |oView| TeorRefresh(,oView,,cViewID) } )
	If !lOcultImp
		oView:SetViewProperty( 'NR0DETAIL5', "CHANGELINE", {{ |oView, cViewID| TeorRefresh(,oView, ,cViewID) }} )
	EndIf
	oView:SetViewProperty( 'NR0DETAIL1', "CHANGELINE", {{ |oView, cViewID| TeorRefresh(,oView, ,cViewID) }} )

	If lXml .Or. lXmlWS
		oView:SetViewProperty( 'NR0DETAIL2', "CHANGELINE", {{ |oView, cViewID| TeorRefresh(,oView, ,cViewID) }} )
		If !lOcultNLoc
			oView:SetViewProperty( 'NR0DETAIL3', "CHANGELINE", {{ |oView, cViewID| TeorRefresh(,oView, ,cViewID) }} )
		EndIf
	Endif

	oView:SetViewProperty( 'NR0DETAIL4', "CHANGELINE", {{ |oView, cViewID| TeorRefresh(,oView, ,cViewID) }} )

	If !lXml .And. !lXmlWS
		oView:SetViewProperty( 'NR0DETAIL6', "CHANGELINE", {{ |oView, cViewID| TeorRefresh(,oView, ,cViewID) }} )
	Endif

	oView:SetUseCursor( .T. )
	oView:EnableControlBar( .T. )

	oView:SetNoInsertLine("NR0DETAIL1")

	If lXml .Or. lXmlWS
		oView:SetNoInsertLine("NR0DETAIL2")
		If !lOcultNLoc
			oView:SetNoInsertLine("NR0DETAIL3")
		EndIf
	Endif

	oView:SetNoInsertLine("NR0DETAIL4")
	If !lOcultImp
		oView:SetNoInsertLine("NR0DETAIL5")
		oView:SetNoUpdateLine("NR0DETAIL5")
	EndIf

	If !lXml .And. !lXmlWS
		oView:SetNoInsertLine("NR0DETAIL6")
	Endif

	//-- Seta as propriedades se o campo esta na estrutura de cada grid
	// Grid 1
	If lXml .AND. oStrNR01:HasField("NR0_CODIMP")
		oStrNR01:setProperty("NR0_CODIMP",  MVC_VIEW_CANCHANGE, .F.)
	EndIf
	If oStrNR01:HasField("NR0_CAJURI")
		oStrNR01:setProperty("NR0_CAJURI",  MVC_VIEW_CANCHANGE, .F.)
	EndIf
	If oStrNR01:HasField("NR0_NUMPRO")
		oStrNR01:setProperty("NR0_NUMPRO",  MVC_VIEW_CANCHANGE, .F.)
	EndIf	
	If oStrNR01:HasField("NR0_DTPUBL")
		oStrNR01:setProperty("NR0_DTPUBL",  MVC_VIEW_CANCHANGE, .F.)
	EndIf
	If oStrNR01:HasField("NR0_FILPRO")
		oStrNR01:setProperty("NR0_FILPRO",  MVC_VIEW_CANCHANGE, .F.)
	EndIf
	If oStrNR01:HasField("NR0_NOME")
		oStrNR01:setProperty("NR0_NOME",  MVC_VIEW_CANCHANGE, .F.)
	EndIf

	// Grid 2
	If lXml .AND. oStrNR02:HasField("NR0_CODIMP")
		oStrNR02:setProperty("NR0_CODIMP",  MVC_VIEW_CANCHANGE, .F.)
	Endif

	If oStrNR02:HasField("NR0_NUMPRO")
		oStrNR02:setProperty("NR0_NUMPRO",  MVC_VIEW_CANCHANGE, .F.)
	EndIf
	If oStrNR02:HasField("NR0_DTPUBL")
		oStrNR02:setProperty("NR0_DTPUBL",  MVC_VIEW_CANCHANGE, .F.)
	EndIf
	If oStrNR02:HasField("NR0_NOME")
		oStrNR02:setProperty("NR0_NOME",  MVC_VIEW_CANCHANGE, .F.)
	EndIf

	// Grid 3
	If !lOcultNLoc
		//valida se é kurier para usar o campo codrel e não o campo codimp
		If (!lXml .Or. lXmlWS) .AND. oStrNR03:HasField("NR0_CODREL")
			oStrNR03:setProperty("NR0_CODREL",  MVC_VIEW_CANCHANGE, .F.)
		Elseif oStrNR03:HasField("NR0_CODIMP")
			oStrNR03:setProperty("NR0_CODIMP",  MVC_VIEW_CANCHANGE, .F.)
		Endif

		If oStrNR03:HasField("NR0_NUMPRO")
			oStrNR03:setProperty("NR0_NUMPRO",  MVC_VIEW_CANCHANGE, .F.)
		EndIf
		If oStrNR03:HasField("NR0_DTPUBL")
			oStrNR03:setProperty("NR0_DTPUBL",  MVC_VIEW_CANCHANGE, .F.)
		EndIf
		If oStrNR03:HasField("NR0_NOME")
			oStrNR03:setProperty("NR0_NOME",  MVC_VIEW_CANCHANGE, .F.)
		EndIf
	EndIf

	// Grid 4
	If oStrNR04:HasField("NR0_NUMPRO")
		oStrNR04:setProperty("NR0_NUMPRO",  MVC_VIEW_CANCHANGE, .F.)
	EndIf
	If oStrNR04:HasField("NR0_DTPUBL")
		oStrNR04:setProperty("NR0_DTPUBL",  MVC_VIEW_CANCHANGE, .F.)
	EndIf
	If oStrNR04:HasField("NR0_NOME")
		oStrNR04:setProperty("NR0_NOME",  MVC_VIEW_CANCHANGE, .F.)
	EndIf

	// Grid 5
	If !lOcultImp // Se não oculta a aba de Importadas
		If oStrNR05:HasField("NR0_CAJURI")
			oStrNR05:setProperty("NR0_CAJURI",  MVC_VIEW_CANCHANGE, .F.)
		EndIf
		If oStrNR05:HasField("NR0_NUMPRO")
			oStrNR05:setProperty("NR0_NUMPRO",  MVC_VIEW_CANCHANGE, .F.)
		EndIf
		If oStrNR05:HasField("NR0_DTPUBL")
			oStrNR05:setProperty("NR0_DTPUBL",  MVC_VIEW_CANCHANGE, .F.)
		EndIf
		If oStrNR05:HasField("NR0_FILPRO")
			oStrNR05:setProperty("NR0_FILPRO",  MVC_VIEW_CANCHANGE, .F.)
		EndIf
		If oStrNR05:HasField("NR0_NOME")
			oStrNR05:setProperty("NR0_NOME",  MVC_VIEW_CANCHANGE, .F.)
		EndIf
	EndIf

	// Grid 6
	If oStrNR06:HasField("NR0_NUMPRO")
		oStrNR06:setProperty("NR0_NUMPRO",  MVC_VIEW_CANCHANGE, .F.)
	EndIf
	If oStrNR06:HasField("NR0_DTPUBL")
		oStrNR06:setProperty("NR0_DTPUBL",  MVC_VIEW_CANCHANGE, .F.)
	EndIf
	If oStrNR06:HasField("NR0_FILPRO")
		oStrNR06:setProperty("NR0_FILPRO",  MVC_VIEW_CANCHANGE, .F.)
	EndIf
	If oStrNR06:HasField("NR0_NOME")
		oStrNR06:setProperty("NR0_NOME",  MVC_VIEW_CANCHANGE, .F.)
	EndIf

	oView:AddUserButton( STR0157, "BUDGET", { | oView | JCall182(oView) } ) 				 // "Palavra Chave"
	oView:AddUserButton( STR0169, "BUDGET", { | oView | J20Filtrar(oView) } )				 // "Filtrar por Palavra-chave"
	oView:AddUserButton( STR0199, "BUDGET", { | oView, oBotao | J20Marcar(oView, oBotao) } ) // "Marcar Todos"
	If !lXml
		oView:AddUserButton( STR0194, "BUDGET", { | oView | J20FiltAgrp(oView) } ) // "Filtrar por Agrupadores"
	EndIf
	oView:AddUserButton( STR0058                , "BUDGET", { | oView | IIF(lXml .And. Empty(ALLTRIM(MV_PAR02)), MsgAlert(STR0156,""), IIF(ApMsgYesNo(STR0097, STR0058), Processa( {|| J20VisuPro(oView, oModel)} )                                              , ) ) } )	//"Visualizar Processo"	//"Esta operação não é permitida pois não foi indicada publicação importada para modificações. Importe uma publicação ou informe uma para realizar essa operação!" 	//"Ao realizar esta operação o sistema salvará todas as alterações feitas na tela! Deseja continuar?"	//"Visualizar Processo"
	oView:AddUserButton( STR0062                , "BUDGET", { | oView | IIF(lXml .And. Empty(ALLTRIM(MV_PAR02)), MsgAlert(STR0156,""), IIF(ApMsgYesNo(STR0097, STR0062), Processa( {|| J20VincPro(oView, oModel)} )                                              , ) ) } ) 	//"Vincular Processo"	//"Esta operação não é permitida pois não foi indicada publicação importada para modificações. Importe uma publicação ou informe uma para realizar essa operação!" 	//"Ao realizar esta operação o sistema salvará todas as alterações feitas na tela! Deseja continuar?"	//"Vincular Processo"
	oView:AddUserButton( STR0061                , "BUDGET", { | oView | IIF(lXml .And. Empty(ALLTRIM(MV_PAR02)), MsgAlert(STR0156,""), IIF(ApMsgYesNo(STR0097, STR0061), Processa( {|| J20Excluir(oView, oModel)} )                                              , ) ) } ) 	//"Excluir"				//"Esta operação não é permitida pois não foi indicada publicação importada para modificações. Importe uma publicação ou informe uma para realizar essa operação!" 	//"Ao realizar esta operação o sistema salvará todas as alterações feitas na tela! Deseja continuar?"	//"Excluir"
	oView:AddUserButton( STR0063                , "BUDGET", { | oView | IIF(lXml .And. Empty(ALLTRIM(MV_PAR02)), MsgAlert(STR0156,""), IIF(ApMsgYesNo(STR0097, STR0063), Processa( {|| J20Restore(oView, oModel)} )                                              , ) ) } ) 	//"Restaurar" 			//"Esta operação não é permitida pois não foi indicada publicação importada para modificações. Importe uma publicação ou informe uma para realizar essa operação!"	//"Ao realizar esta operação o sistema salvará todas as alterações feitas na tela! Deseja continuar?"	//"Restaurar"
	oView:AddUserButton( STR0032 + " " + STR0203, "BUDGET", { | oView | IIF(lXml .And. Empty(ALLTRIM(MV_PAR02)), MsgAlert(STR0156,""), IIF(ApMsgYesNo(STR0097, STR0032), Processa( {|| J20Concil( oView, oModel, /*cCodAto*/, /*cCajuAuto*/, /*cFilpAuto*/, 1)} ), ) ) } )  //"Conciliar" 	"Manual"	"Ao realizar esta operação o sistema salvará todas as alterações feitas na tela! Deseja continuar?"
	If lAtoAuto
		oView:AddUserButton( STR0032 + " " + STR0204, "BUDGET", { | oView | IIF(lXml .And. Empty(ALLTRIM(MV_PAR02)), MsgAlert(STR0156,""), IIF(ApMsgYesNo(STR0097, STR0032), Processa( {|| J20Concil(oView, oModel, /*cCodAto*/, /*cCajuAuto*/, /*cFilpAuto*/, 2)} ) , ) ) } ) // "Conciliar"	"Automático"	"Ao realizar esta operação o sistema salvará todas as alterações feitas na tela! Deseja continuar?"
	EndIf
	oView:AddUserButton( STR0180, "BUDGET", { | oView | IIF(lXml .And. Empty(ALLTRIM(MV_PAR02)), MsgAlert(STR0156,""), IIF(ApMsgYesNo(STR0097, STR0180), J20Pesqui( oView, oModel) , ) ) } ) // "Reprocessar" e "Ao realizar esta operação o sistema salvará todas as alterações feitas na tela! Deseja continuar?"
	If lAtoAuto
		oView:AddUserButton( STR0202, "BUDGET", { | oView | JCall257(oView) } ) // "Ato Processual Automático"
	EndIf

	If JVldPrinter()  
		oView:AddUserButton( STR0223, "BUDGET", { |oView| JA020XLSX(oView)} ) //"Exportar Publicações"
	Else
		oView:AddUserButton( STR0223, "BUDGET", { |oView| JA020Export(oView) } ) //"Exportar Publicações"
	EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de importação de documentos

@author André Spirigoni
@since 24/02/14
@version 1.0

@obs NR0MASTER - Dados de importação de documentos

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
	Local oModel     := NIL
	Local oStructNR0 := FWFormStruct( 1, "NR0" )
	Local oStrNR01   := FWFormStruct( 1, "NR0" )
	Local oStrNR02   := FWFormStruct( 1, "NR0" )
	Local oStrNR03   := FWFormStruct( 1, "NR0" )
	Local oStrNR04   := FWFormStruct( 1, "NR0" )
	Local oStrNR05   := FWFormStruct( 1, "NR0" )
	Local oStrNR06   := FWFormStruct( 1, "NR0" )
	Local cCodDoc    := ""
	Local cClien     := ""
	Local cLoja      := ""
	Local cArea      := ""
	Local cCajuris   := ""
	Local cLoadFilter:= ""
	Local cPalavraChv:= ""
	Local cLikeSQL   := J20LikeSQL(aPalavras, cPalavraChaves, aAgrupadores)  //Variaveis estaticas
	Local lPubCheg   := J020VldPar('MV_PAR10')
	Local lOcultNLoc := J020VldPar('MV_PAR08')
	Local lOcultImp  := J020VldPar('MV_PAR09')

	cLikeSQL := IIF( !Empty(cLikeSQL), " AND " + cLikeSQL, "")

	If oGrid <> Nil
		oGrid:SetIncMeter(1)
	Endif

	If lXml
		If Empty(MV_PAR02)
			cCodDoc := "0000"	//Força 0000 para não trazer publicações do web-service
		Else
			cCodDoc := ALLTRIM(MV_PAR02)
		EndIf
	EndIf

	oStrNR01:AddField( ;
	""               , ;               // [01] Titulo do campo
	"Check"          , ;               // [02] ToolTip do campo
	"NR0__TICK"      , ;               // [03] Id do Field
	"L"              , ;               // [04] Tipo do campo
	1                , ;               // [05] Tamanho do campo
	0                , ;               // [06] Decimal do campo
	, ;                                // [07] Code-block de validação do campo
	, ;                                // [08] Code-block de validação When do campo
	, ;                                // [09] Lista de valores permitido do campo
	.F.              )                 // [10] Indica se o campo tem preenchimento obrigatório   ]

	oStrNR02:AddField( ;
	""               , ;               // [01] Titulo do campo
	"Check"          , ;               // [02] ToolTip do campo
	"NR0__TICK"      , ;               // [03] Id do Field
	"L"              , ;               // [04] Tipo do campo
	1                , ;               // [05] Tamanho do campo
	0                , ;               // [06] Decimal do campo
	, ;                                // [07] Code-block de validação do campo
	, ;                                // [08] Code-block de validação When do campo
	, ;                                // [09] Lista de valores permitido do campo
	.F.              )                 // [10] Indica se o campo tem preenchimento obrigatório   ]

	oStrNR03:AddField( ;
	""               , ;               // [01] Titulo do campo
	"Check"          , ;               // [02] ToolTip do campo
	"NR0__TICK"      , ;               // [03] Id do Field
	"L"              , ;               // [04] Tipo do campo
	1                , ;               // [05] Tamanho do campo
	0                , ;               // [06] Decimal do campo
	, ;                                // [07] Code-block de validação do campo
	, ;                                // [08] Code-block de validação When do campo
	, ;                                // [09] Lista de valores permitido do campo
	.F.              )                 // [10] Indica se o campo tem preenchimento obrigatório   ]

	oStrNR04:AddField( ;
	""               , ;               // [01] Titulo do campo
	"Check"          , ;               // [02] ToolTip do campo
	"NR0__TICK"      , ;               // [03] Id do Field
	"L"              , ;               // [04] Tipo do campo
	1                , ;               // [05] Tamanho do campo
	0                , ;               // [06] Decimal do campo
	, ;                                // [07] Code-block de validação do campo
	, ;                                // [08] Code-block de validação When do campo
	, ;                                // [09] Lista de valores permitido do campo
	.F.              )                 // [10] Indica se o campo tem preenchimento obrigatório   ]

	oStrNR06:AddField( ;
	""               , ;               // [01] Titulo do campo
	"Check"          , ;               // [02] ToolTip do campo
	"NR0__TICK"      , ;               // [03] Id do Field
	"L"              , ;               // [04] Tipo do campo
	1                , ;               // [05] Tamanho do campo
	0                , ;               // [06] Decimal do campo
	, ;                                // [07] Code-block de validação do campo
	, ;                                // [08] Code-block de validação When do campo
	, ;                                // [09] Lista de valores permitido do campo
	.F.              )                 // [10] Indica se o campo tem preenchimento obrigatório   ]

	oStructNR0:AddField( ;
	STR0124            , ;             // [01] Titulo do campo // "Qtd. Localizadas"
	STR0125            , ;             // [02] ToolTip do campo // "Qtd Publicações localizadas"
	"NR0__PLOC"        , ;             // [03] Id do Field
	"C"                , ;             // [04] Tipo do campo
	7                  , ;             // [05] Tamanho do campo
	0                  , ;             // [06] Decimal do campo
	, ;                                // [07] Code-block de validação do campo
	{||.F.}            , ;             // [08] Code-block de validação When do campo
	, ;                                // [09] Lista de valores permitido do campo
	.F.                )               // [10] Indica se o campo tem preenchimento obrigatório

	oStructNR0:AddField( ;
	STR0126            , ;             // [01] Titulo do campo // "Qtd. Excluídas"
	STR0127            , ;             // [02] ToolTip do campo // "Qtd Publicações excluídas"
	"NR0__PDEL"        , ;             // [03] Id do Field
	"C"                , ;             // [04] Tipo do campo
	7                  , ;             // [05] Tamanho do campo
	0                  , ;             // [06] Decimal do campo
	, ;                                // [07] Code-block de validação do campo
	{||.F.}            , ;             // [08] Code-block de validação When do campo
	, ;                                // [09] Lista de valores permitido do campo
	.F.                )               // [10] Indica se o campo tem preenchimento obrigatório

	oStructNR0:AddField( ;
	STR0128             , ;            // [01] Titulo do campo // "Qtd. Prováveis:"
	STR0129  			, ;    		   // [02] ToolTip do campo // "Qtd Publicações provaveis"
	"NR0__PPROV"        , ; 		   // [03] Id do Field
	"C"                 , ; 		   // [04] Tipo do campo
	7                   , ;  		   // [05] Tamanho do campo
	0				    , ; 		   // [06] Decimal do campo
	, ;   							   // [07] Code-block de validação do campo
	{||.F.}             , ;            // [08] Code-block de validação When do campo
	, ;                                // [09] Lista de valores permitido do campo
	.F.                 ) 			   // [10] Indica se o campo tem preenchimento obrigatório

	oStructNR0:AddField( ;
	STR0130             , ;            // [01] Titulo do campo // "Qtd. importadas"
	STR0131  			, ;            // [02] ToolTip do campo // "Qtd Publicações importadas"
	"NR0__PIMP"         , ;  		   // [03] Id do Field
	"C"                 , ; 		   // [04] Tipo do campo
	7                   , ;   		   // [05] Tamanho do campo
	0					, ; 		   // [06] Decimal do campo
	, ;   							   // [07] Code-block de validação do campo
	{||.F.}				, ;            // [08] Code-block de validação When do campo
	, ;                                // [09] Lista de valores permitido do campo
	.F.                 ) 			   // [10] Indica se o campo tem preenchimento obrigatório

	oStructNR0:AddField( ;
	STR0132             , ;            // [01] Titulo do campo // "Qtd. Não Localizadas"
	STR0133  			, ;            // [02] ToolTip do campo // "Qtd Publicações não localizadas"
	"NR0__PNLOC"        , ; 		   // [03] Id do Field
	"C"                 , ; 		   // [04] Tipo do campo
	7                   , ;  		   // [05] Tamanho do campo
	0					, ;            // [06] Decimal do campo
	, ;   							   // [07] Code-block de validação do campo
	{||.F.}				, ;            // [08] Code-block de validação When do campo
	, ;                                // [09] Lista de valores permitido do campo
	.F.                 ) 			   // [10] Indica se o campo tem preenchimento obrigatório

	oStructNR0:AddField( ;
	STR0134             , ;            // [01] Titulo do campo // "Qtd. Processos Duplicadas"
	STR0135  			, ;            // [02] ToolTip do campo // "Qtd Processos Duplicadas"
	"NR0__PDUP"         , ;  		   // [03] Id do Field
	"C"                 , ; 		   // [04] Tipo do campo
	7                   , ;  		   // [05] Tamanho do campo
	0					, ; 		   // [06] Decimal do campo
	, ;   							   // [07] Code-block de validação do campo
	{||.F.}				, ;            // [08] Code-block de validação When do campo
	, ;                                // [09] Lista de valores permitido do campo
	.F.                 ) 			   // [10] Indica se o campo tem preenchimento obrigatório

	oStructNR0:AddField( ;
	STR0142             , ;            // [01] Titulo do campo // "Caminho"
	STR0142  			, ;            // [02] ToolTip do campo // "Caminho"
	"NR0__PCAM"         , ;  		   // [03] Id do Field
	"C"                 , ;            // [04] Tipo do campo
	255                 , ;            // [05] Tamanho do campo
	0					, ;            // [06] Decimal do campo
	, ;   							   // [07] Code-block de validação do campo
	{||.F.}				, ;            // [08] Code-block de validação When do campo
	, ;                                // [09] Lista de valores permitido do campo
	.F.                 )              // [10] Indica se o campo tem preenchimento obrigatório

	oStructNR0:AddField( ;
	STR0122             , ;            // [01] Titulo do campo // "Arquivo XML"
	STR0122             , ;            // [02] ToolTip do campo // "Arquivo XML"
	'BOTAO'             , ;            // [03] Id do Field
	'BT'                , ;            // [04] Tipo do campo
	1                   , ;            // [05] Tamanho do campo
	0                   , ;             // [06] Decimal do campo
	{||SetCaminho()} 	, ; // [07] Code-block de validação do campo // "Arquivo XML"
	, ;                                // [08] Code-block de validação When do campo
	, ;                                // [09] Lista de valores permitido do campo
	.F.                  )             // [10] Indica se o campo tem preenchimento obrigatório

	oStructNR0:AddField( ;
	STR0015            , ;             // [01] Titulo do campo // "Importar Arquivo"
	STR0015            , ;             // [02] ToolTip do campo // "Importar Arquivo"
	'BOTAO2'           , ;             // [03] Id do Field
	'BT'               , ;             // [04] Tipo do campo
	1                  , ;             // [05] Tamanho do campo
	0                  , ;             // [06] Decimal do campo
	{|| J20Import(, oModel)} , ;       // [07] Code-block de validação do campo
	, ;                                // [08] Code-block de validação When do campo
	, ;                                // [09] Lista de valores permitido do campo
	.F.                )               // [10] Indica se o campo tem preenchimento obrigatório

	oStructNR0:AddField( ;
	STR0123             , ;            // [01] Titulo do campo // "Tipo Arquivo XML"
	STR0123  			, ;            // [02] ToolTip do campo // "Tipo Arquivo XML"
	"NR0__TPARQ"        , ;            // [03] Id do Field
	"C"                 , ;            // [04] Tipo do campo
	1                   , ;            // [05] Tamanho do campo
	0					, ;            // [06] Decimal do campo
	, ;   							   // [07] Code-block de validação do campo
	, ;                                // [08] Code-block de validação When do campo
	{"1="+STR0002,"2="+STR0003,"3="+STR0004}, ; // [09] Lista de valores permitido do campo // "1=Procergs","2=DaJusti","3=Destaque"
	.F.                              ) // [10] Indica se o campo tem preenchimento obrigatório

	//----------------------------------------------
	//Monta o modelo do formulário
	//----------------------------------------------
	oModel:= MPFormModel():New("JURA020", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	oModel:SetDescription(STR0010) // "Importação de publicações"

	JurSetRules(oModel, "NR0MASTER",, "NR0")

	oModel:AddFields("NR0MASTER", NIL, oStructNR0, /*Pre-Validacao*/, /*Pos-Validacao*/ )

	oModel:AddGrid( "NR0DETAIL1", "NR0MASTER" /*cOwner*/, oStrNR01, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )

	If lXml .Or. lXmlWS
		oModel:AddGrid( "NR0DETAIL2", "NR0MASTER" /*cOwner*/, oStrNR02, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
		If !lOcultNLoc
			oModel:AddGrid( "NR0DETAIL3", "NR0MASTER" /*cOwner*/, oStrNR03, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
		EndIf
	Endif

	oModel:AddGrid( "NR0DETAIL4", "NR0MASTER" /*cOwner*/, oStrNR04, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )

	If !lOcultImp
		oModel:AddGrid( "NR0DETAIL5", "NR0MASTER" /*cOwner*/, oStrNR05, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
	EndIf
	If !lXml .And. !lXmlWS
		oModel:AddGrid( "NR0DETAIL6", "NR0MASTER" /*cOwner*/, oStrNR06, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
	Endif

	oModel:GetModel("NR0MASTER"):SetDescription(STR0143) // "Informações Publicações"
	oModel:GetModel("NR0DETAIL1"):SetDescription(STR0137) // "Publicações Localizadas"

	If lXml .Or. lXmlWS
		oModel:GetModel("NR0DETAIL2"):SetDescription(STR0139) // "Processos Duplicados"
		If !lOcultNLoc
			oModel:GetModel("NR0DETAIL3"):SetDescription(STR0138) // "Publicações não Localizadas"
		EndIf
	Endif

	oModel:GetModel("NR0DETAIL4"):SetDescription(STR0140) // "Publicações Excluídas"
	If !lOcultImp
		oModel:GetModel("NR0DETAIL5"):SetDescription(STR0136) // "Publicações Importadas"
	EndIf

	If !lXml .And. !lXmlWS
		oModel:GetModel("NR0DETAIL6"):SetDescription(STR0141) // "Publicações Prováveis"
	EndIf

	If lXml
		oModel:SetRelation( "NR0DETAIL1", { { "NR0_FILIAL", "XFILIAL('NR0')" }, { "NR0_CODIMP", "'"+cCodDoc+"'" } }, NR0->( IndexKey( 1 ) ) )
		oModel:SetRelation( "NR0DETAIL2", { { "NR0_FILIAL", "XFILIAL('NR0')" }, { "NR0_CODIMP", "'"+cCodDoc+"'" } }, NR0->( IndexKey( 1 ) ) )
		If !lOcultNLoc
			oModel:SetRelation( "NR0DETAIL3", { { "NR0_FILIAL", "XFILIAL('NR0')" }, { "NR0_CODIMP", "'"+cCodDoc+"'" } }, NR0->( IndexKey( 1 ) ) )
		EndIf
		oModel:SetRelation( "NR0DETAIL4", { { "NR0_FILIAL", "XFILIAL('NR0')" }, { "NR0_CODIMP", "'"+cCodDoc+"'" } }, NR0->( IndexKey( 1 ) ) )
		If !lOcultImp
			oModel:SetRelation( "NR0DETAIL5", { { "NR0_FILIAL", "XFILIAL('NR0')" }, { "NR0_CODIMP", "'"+cCodDoc+"'" } }, NR0->( IndexKey( 1 ) ) )
		EndIf
	Elseif lXmlWS
		oModel:SetRelation( "NR0DETAIL1", { { "NR0_FILIAL", "XFILIAL('NR0')" } }, NR0->( IndexKey( 1 ) ) )
		oModel:SetRelation( "NR0DETAIL2", { { "NR0_FILIAL", "XFILIAL('NR0')" } }, NR0->( IndexKey( 1 ) ) )
		If !lOcultNLoc
			oModel:SetRelation( "NR0DETAIL3", { { "NR0_FILIAL", "XFILIAL('NR0')" } }, NR0->( IndexKey( 1 ) ) )
		EndIf
		oModel:SetRelation( "NR0DETAIL4", { { "NR0_FILIAL", "XFILIAL('NR0')" } }, NR0->( IndexKey( 1 ) ) )
		If !lOcultImp
			oModel:SetRelation( "NR0DETAIL5", { { "NR0_FILIAL", "XFILIAL('NR0')" } }, NR0->( IndexKey( 1 ) ) )
		EndIf
	Else
		oModel:SetRelation( "NR0DETAIL1", { { "NR0_FILIAL", "XFILIAL('NR0')" } }, NR0->( IndexKey( 1 ) ) )
		oModel:SetRelation( "NR0DETAIL4", { { "NR0_FILIAL", "XFILIAL('NR0')" } }, NR0->( IndexKey( 1 ) ) )
		If !lOcultImp
			oModel:SetRelation( "NR0DETAIL5", { { "NR0_FILIAL", "XFILIAL('NR0')" } }, NR0->( IndexKey( 1 ) ) )
		EndIf
		oModel:SetRelation( "NR0DETAIL6", { { "NR0_FILIAL", "XFILIAL('NR0')" } }, NR0->( IndexKey( 1 ) ) )
	EndIf

	oModel:SetOptional( "NR0DETAIL1" , .T. )

	If lXml .Or. lXmlWS
		oModel:SetOptional( "NR0DETAIL2" , .T. )
		If !lOcultNLoc
			oModel:SetOptional( "NR0DETAIL3" , .T. )
		EndIf
	EndIf

	oModel:SetOptional( "NR0DETAIL4" , .T. )
	If !lOcultImp
		oModel:SetOptional( "NR0DETAIL5" , .T. )
	EndIf

	If !lXml .And. !lXmlWS
		oModel:SetOptional( "NR0DETAIL6" , .T. )
	Endif

	//--------------------------------------- lXml------------------------------------------------------
	If lXml

		oModel:GetModel( 'NR0DETAIL1' ):SetLoadFilter( , "NR0_SITUAC = '1' AND NR0_CODIMP = '" + cCodDoc + "'" + cLikeSQL )	// "Publicações Localizadas"
		oModel:GetModel( 'NR0DETAIL2' ):SetLoadFilter( , "NR0_SITUAC = '2' AND NR0_CODIMP = '" + cCodDoc + "'" + cLikeSQL )	// "Publicações Duplicados"
		If !lOcultNLoc
			oModel:GetModel( 'NR0DETAIL3' ):SetLoadFilter( , "NR0_SITUAC = '3' AND NR0_CODIMP = '" + cCodDoc + "'" + cLikeSQL )	// "Publicações não Localizadas"
		EndIf
		oModel:GetModel( 'NR0DETAIL4' ):SetLoadFilter( , "NR0_SITUAC = '4' AND NR0_CODIMP = '" + cCodDoc + "'" + cLikeSQL )	// "Publicações Excluídas"
		If !lOcultImp
			oModel:GetModel( 'NR0DETAIL5' ):SetLoadFilter( , "NR0_SITUAC = '5' AND NR0_CODIMP = '" + cCodDoc + "'" + cLikeSQL )	// "Publicações Importadas"
		EndIf

	//--------------------------------------- !lXml------------------------------------------------------
	Else

		cClien := MV_PAR04
		cLoja  := MV_PAR05
		cArea  := MV_PAR06

		//valida se existe o filtro de agrupamento.
		if Type("MV_PAR07") != "U"
			cLogin := MV_PAR07
		Else
			cLogin := ""
		Endif

		cCajuris	:= IIF( !Empty(cClien + cLoja) .Or. !Empty(cArea), J020FilAsj(cClien, cLoja, cArea), '')

		cPalavraChv := J020TeorPb()

		If lPubCheg //Filtro por data da publicação, verificando se está vazio, pois se não tiver atualizado o x1 o parametro se perde por conta da ordem
			cLoadFilter := " AND NR0_DTCHEG >= '" + DTOS(MV_PAR01) + "' AND NR0_DTCHEG <= '" + DTOS(MV_PAR02) + "' "
		Else//Filtro por data de chegada
			cLoadFilter := " AND NR0_DTPUBL >= '" + DTOS(MV_PAR01) + "' AND NR0_DTPUBL <= '" + DTOS(MV_PAR02) + "' "
		EndIf

		If !Empty(cLikeSQL)
			cLoadFilter += cLikeSQL
		EndIf

		If !Empty(cCajuris)
			cLoadFilter += " AND NR0_CAJURI IN " + cCajuris
		EndIf

		If !Empty(cLogin)
			cLoadFilter += " AND NR0_LOGIN = '" + cLogin + "'"
		Endif

		//Se nao for encontrado nenhum processo, mas tenha filtro por cliente, loja ou area, precisa aplicar esse filtro para nao retornar todas as publicacoes
		If Empty(cCajuris) .And. ( !Empty(cClien) .Or. !Empty(cLoja) .Or. !Empty(cArea) )
			cLoadFilter += " AND NR0_CAJURI = 'SEMPROCESSO' "
		EndIf

		//--------------------------------------- !lXml .and. !XmlWS------------------------------------------------------
		If !lXmlWS
			oModel:GetModel( 'NR0DETAIL1' ):SetLoadFilter( , "NR0_SITUAC = '1'" + cLoadFilter)
			oModel:GetModel( 'NR0DETAIL4' ):SetLoadFilter( , "NR0_SITUAC = '4'" + cLoadFilter)
			If !lOcultImp
				oModel:GetModel( 'NR0DETAIL5' ):SetLoadFilter( , "NR0_SITUAC = '5'" + cLoadFilter)
			EndIf
			oModel:GetModel( 'NR0DETAIL6' ):SetLoadFilter( , "NR0_SITUAC = '6'" + cLoadFilter)
			//--------------------------------------- !lXml .and. XmlWS------------------------------------------------------
		ElseIf lXmlWS
			oModel:GetModel( 'NR0DETAIL1' ):SetLoadFilter( , "NR0_SITUAC = '1'" + cLoadFilter)
			oModel:GetModel( 'NR0DETAIL2' ):SetLoadFilter( , "NR0_SITUAC = '2'" + cLoadFilter)
			If !lOcultNLoc
				oModel:GetModel( 'NR0DETAIL3' ):SetLoadFilter( , "NR0_SITUAC = '3'" + cLoadFilter)
			EndIf
			oModel:GetModel( 'NR0DETAIL4' ):SetLoadFilter( , "NR0_SITUAC = '4'" + cLoadFilter)
			If !lOcultImp
				oModel:GetModel( 'NR0DETAIL5' ):SetLoadFilter( , "NR0_SITUAC = '5'" + cLoadFilter)
			EndIf
		EndIf

	EndIf
	If !lOcultImp
		oModel:GetModel( 'NR0DETAIL5' ):SetOnlyView( .T. )
	EndIf
	oModel:SetVldActivate( { |o| J20LoadFlt(o)} )

	oModel:SetActivate( { |o| J20AtuaQtd(o)} )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J20LoadFlt
Atualiza a tela com nova publicação importada

@param  oModel  Modelo de dados de importação de documentos

@author Jorge Luis Branco Martins Junior
@since 26/03/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J20LoadFlt(oModel)
	Local cCajuris   := ""
	Local cClien     := ""
	Local cLoja      := ""
	Local cArea      := ""
	Local cLoadFilter:= ""
	Local cPalavraChv:= ""
	Local cLikeSQL   := J20LikeSQL(aPalavras, cPalavraChaves, aAgrupadores)  //Variaveis estaticas
	Local cCodDoc    := ""
	Local lPubCheg   := J020VldPar('MV_PAR10')//Define se o filtro de datas será feito pela publicação ou pela chegada
	Local lOcultNLoc := J020VldPar('MV_PAR08')
	Local lOcultImp  := J020VldPar('MV_PAR09')

	cLikeSQL := IIF( !Empty(cLikeSQL), " AND " + cLikeSQL, "")

	If oGrid <> Nil
		oGrid:SetIncMeter(1)
	Endif

	//-------------------------------------------------------------------
	// "Publicações localizadas" 		- "NR0DETAIL1" - NR0_SITUAC = '1'
	// "Processos duplicados"			- "NR0DETAIL2" - NR0_SITUAC = '2'
	// "Publicações não localizadas"	- "NR0DETAIL3" - NR0_SITUAC = '3'
	// "Publicações excluídas"			- "NR0DETAIL4" - NR0_SITUAC = '4'
	// "Publicações importadas"  		- "NR0DETAIL5" - NR0_SITUAC = '5'
	// "Publicações prováveis"			- "NR0DETAIL6" - NR0_SITUAC = '6'
	//-------------------------------------------------------------------

	// Montagem da Relação para Importação via XML ( Arquivo )
	If lXml

		If Empty(MV_PAR02)
			cCodDoc := "0000"	//Força 0000 para não trazer publicações do web-service
		Else
			cCodDoc := ALLTRIM(MV_PAR02)
		EndIf

		oModel:SetRelation( "NR0DETAIL1", { { "NR0_FILIAL", "XFILIAL('NR0')" }, { "NR0_CODIMP", "'"+cCodDoc+"'" } }, NR0->( IndexKey( 1 ) ) )
		oModel:SetRelation( "NR0DETAIL2", { { "NR0_FILIAL", "XFILIAL('NR0')" }, { "NR0_CODIMP", "'"+cCodDoc+"'" } }, NR0->( IndexKey( 1 ) ) )
		If !lOcultNLoc
			oModel:SetRelation( "NR0DETAIL3", { { "NR0_FILIAL", "XFILIAL('NR0')" }, { "NR0_CODIMP", "'"+cCodDoc+"'" } }, NR0->( IndexKey( 1 ) ) )
		EndIf
		oModel:SetRelation( "NR0DETAIL4", { { "NR0_FILIAL", "XFILIAL('NR0')" }, { "NR0_CODIMP", "'"+cCodDoc+"'" } }, NR0->( IndexKey( 1 ) ) )
		If !lOcultImp
			oModel:SetRelation( "NR0DETAIL5", { { "NR0_FILIAL", "XFILIAL('NR0')" }, { "NR0_CODIMP", "'"+cCodDoc+"'" } }, NR0->( IndexKey( 1 ) ) )
		EndIf

	// Montagem da Relação para Importação via XML ( WebService ) - Kurier
	Elseif lXmlWS
		oModel:SetRelation( "NR0DETAIL1", { { "NR0_FILIAL", "XFILIAL('NR0')" } }, NR0->( IndexKey( 1 ) ) )
		oModel:SetRelation( "NR0DETAIL2", { { "NR0_FILIAL", "XFILIAL('NR0')" } }, NR0->( IndexKey( 1 ) ) )
		If !lOcultNLoc
			oModel:SetRelation( "NR0DETAIL3", { { "NR0_FILIAL", "XFILIAL('NR0')" } }, NR0->( IndexKey( 1 ) ) )
		EndIf
		oModel:SetRelation( "NR0DETAIL4", { { "NR0_FILIAL", "XFILIAL('NR0')" } }, NR0->( IndexKey( 1 ) ) )
		If !lOcultImp
			oModel:SetRelation( "NR0DETAIL5", { { "NR0_FILIAL", "XFILIAL('NR0')" } }, NR0->( IndexKey( 1 ) ) )
		EndIf

	// Montagem da Relação para Importação via WebService ( Direto na tabela NR0 ) - Kurier
	ElseIf !lXml .and. !lXmlWS
		oModel:SetRelation( "NR0DETAIL1", { { "NR0_FILIAL", "XFILIAL('NR0')" } }, NR0->( IndexKey( 1 ) ) )
		oModel:SetRelation( "NR0DETAIL4", { { "NR0_FILIAL", "XFILIAL('NR0')" } }, NR0->( IndexKey( 1 ) ) )
		If !lOcultImp
			oModel:SetRelation( "NR0DETAIL5", { { "NR0_FILIAL", "XFILIAL('NR0')" } }, NR0->( IndexKey( 1 ) ) )
		EndIf
		oModel:SetRelation( "NR0DETAIL6", { { "NR0_FILIAL", "XFILIAL('NR0')" } }, NR0->( IndexKey( 1 ) ) )
	EndIf

	// Montagem da Filtro para Importação via XML ( Arquivo )
	//--------------------------------------- ------lXml------------------------------------------------------
	If lXml

		oModel:GetModel( 'NR0DETAIL1' ):SetLoadFilter( , "NR0_SITUAC = '1' AND NR0_CODIMP = '" + cCodDoc + "'" + cLikeSQL )	// "Publicações Localizadas"
		oModel:GetModel( 'NR0DETAIL2' ):SetLoadFilter( , "NR0_SITUAC = '2' AND NR0_CODIMP = '" + cCodDoc + "'" + cLikeSQL )	// "Publicações Duplicados"
		If !lOcultNLoc
			oModel:GetModel( 'NR0DETAIL3' ):SetLoadFilter( , "NR0_SITUAC = '3' AND NR0_CODIMP = '" + cCodDoc + "'" + cLikeSQL )	// "Publicações não Localizadas"
		EndIf
		oModel:GetModel( 'NR0DETAIL4' ):SetLoadFilter( , "NR0_SITUAC = '4' AND NR0_CODIMP = '" + cCodDoc + "'" + cLikeSQL )	// "Publicações Excluídas"
		If !lOcultImp
			oModel:GetModel( 'NR0DETAIL5' ):SetLoadFilter( , "NR0_SITUAC = '5' AND NR0_CODIMP = '" + cCodDoc + "'" + cLikeSQL )	// "Publicações Importadas"
		EndIf

	//--------------------------------------- !lXml------------------------------------------------------
	Else

		cClien	:= MV_PAR04
		cLoja  	:= MV_PAR05
		cArea  	:= MV_PAR06

		//valida se existe o filtro de agrupamento.
		if Type("MV_PAR07") != "U"
			cLogin := MV_PAR07
		Else
			cLogin := ""
		Endif

		cCajuris 	:= IIF( !Empty(cClien + cLoja) .Or. !Empty(cArea), J020FilAsj(cClien, cLoja, cArea), '')

		cPalavraChv := J020TeorPb()

		If lPubCheg //Filtro por data da publicação
			cLoadFilter := " AND NR0_DTCHEG >= '" + DTOS(MV_PAR01) + "' AND NR0_DTCHEG <= '" + DTOS(MV_PAR02) + "' "
		Else//Filtro por data de chegada
			cLoadFilter := " AND NR0_DTPUBL >= '" + DTOS(MV_PAR01) + "' AND NR0_DTPUBL <= '" + DTOS(MV_PAR02) + "' "
		EndIf

		If !Empty(cLikeSQL)
			cLoadFilter += cLikeSQL
		EndIf

		If !Empty(cCajuris)
			cLoadFilter += " AND NR0_CAJURI IN " + cCajuris
		EndIf

		If !Empty(cLogin)
			cLoadFilter += " AND NR0_LOGIN = '" + cLogin + "'"
		Endif

		//Se nao for encontrado nenhum processo, mas tenha filtro por cliente, loja ou area, precisa aplicar esse filtro para nao retornar todas as publicacoes - replica 12.1.5
		If Empty(cCajuris) .And. ( !Empty(cClien) .Or. !Empty(cLoja) .Or. !Empty(cArea) )
			cLoadFilter += " AND NR0_CAJURI = 'SEMPROCESSO' "
		EndIf

		//--------------------------------------- !lXml .and. !XmlWS------------------------------------------------------
		If !lXmlWS
			oModel:GetModel( 'NR0DETAIL1' ):SetLoadFilter( , "NR0_SITUAC = '1'" + cLoadFilter)
			oModel:GetModel( 'NR0DETAIL4' ):SetLoadFilter( , "NR0_SITUAC = '4'" + cLoadFilter)
			If !lOcultImp
				oModel:GetModel( 'NR0DETAIL5' ):SetLoadFilter( , "NR0_SITUAC = '5'" + cLoadFilter)
			EndIf
			oModel:GetModel( 'NR0DETAIL6' ):SetLoadFilter( , "NR0_SITUAC = '6'" + cLoadFilter)
			//--------------------------------------- !lXml .and. XmlWS------------------------------------------------------
		ElseIf lXmlWS
			oModel:GetModel( 'NR0DETAIL1' ):SetLoadFilter( , "NR0_SITUAC = '1'" + cLoadFilter)
			oModel:GetModel( 'NR0DETAIL2' ):SetLoadFilter( , "NR0_SITUAC = '2'" + cLoadFilter)
			If !lOcultNLoc
				oModel:GetModel( 'NR0DETAIL3' ):SetLoadFilter( , "NR0_SITUAC = '3'" + cLoadFilter)
			EndIf
			oModel:GetModel( 'NR0DETAIL4' ):SetLoadFilter( , "NR0_SITUAC = '4'" + cLoadFilter)
			If !lOcultImp
				oModel:GetModel( 'NR0DETAIL5' ):SetLoadFilter( , "NR0_SITUAC = '5'" + cLoadFilter)
			EndIf
		EndIf

	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J20AtuaQtd
Atualiza campos de quantidade de publicações

@param  oModel  Modelo de dados de importação de documentos

@author André Spirigoni
@since 14/03/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function J20AtuaQtd(oModel)

	Local lOcultNLoc := J020VldPar('MV_PAR08')
	Local lOcultImp  := J020VldPar('MV_PAR09')
	Local oMdl01     := oModel:GetModel( "NR0DETAIL1")
	Local oMdl02     := oModel:GetModel( "NR0DETAIL2")
	Local oMdl03     := Iif(!lOcultNLoc, oModel:GetModel( "NR0DETAIL3"), Nil)
	Local oMdl04     := oModel:GetModel( "NR0DETAIL4")
	Local oMdl05     := If (!lOcultImp, oModel:GetModel( "NR0DETAIL5"), Nil)
	Local oMdl06     := oModel:GetModel( "NR0DETAIL6")


	If oGrid <> Nil
		oGrid:SetIncMeter(1)
	Endif

	oModel:LoadValue('NR0MASTER','NR0__PLOC', IIF(Empty(oMdl01:GetValue("NR0_CODSEQ")),'0',AllTrim(Str(IIF(oMdl01:isEmpty(),0,oMdl01:Length(.T.)))))) //Publicações Localizadas
	oModel:LoadValue('NR0MASTER','NR0__PDEL', IIF(Empty(oMdl04:GetValue("NR0_CODSEQ")),'0',AllTrim(Str(IIF(oMdl04:isEmpty(),0,oMdl04:Length(.T.)))))) //Publicações Excluidas
	If !lOcultImp
		oModel:LoadValue('NR0MASTER','NR0__PIMP', IIF(Empty(oMdl05:GetValue("NR0_CODSEQ")),'0',AllTrim(Str(IIF(oMdl05:isEmpty(),0,oMdl05:Length(.T.)))))) //Publicações Importadas
	EndIf

	If lXml
		oModel:LoadValue('NR0MASTER','NR0__PDUP'  , IIF(Empty(oMdl02:GetValue("NR0_CODSEQ")),'0',AllTrim(Str(oMdl02:Length(.T.))))) //Publicações Duplicadas
		If !lOcultNLoc
			oModel:LoadValue('NR0MASTER','NR0__PNLOC' , IIF(Empty(oMdl03:GetValue("NR0_CODSEQ")),'0',AllTrim(Str(oMdl03:Length(.T.))))) //Publicações não Localizadas
		EndIf
		oModel:LoadValue('NR0MASTER','NR0__PPROV' , '0') //Publicações Prováveis
	Elseif lXmlWS
		oModel:LoadValue('NR0MASTER','NR0__PDUP'  , AllTrim(Str(IIF(oMdl02:IsEmpty(),0,oMdl02:Length(.T.))))) //Publicações Duplicadas
		If !lOcultNLoc
			oModel:LoadValue('NR0MASTER','NR0__PNLOC' , AllTrim(Str(IIF(oMdl03:IsEmpty(),0,oMdl03:Length(.T.))))) //Publicações não Localizadas
		EndIf
	Else
		oModel:LoadValue('NR0MASTER','NR0__PDUP'  , '0') //Publicações Duplicadas

		If !lOcultNLoc
			oModel:LoadValue('NR0MASTER','NR0__PNLOC' , '0') //Publicações não Localizadas
		EndIf
		oModel:LoadValue('NR0MASTER','NR0__PPROV' , IIF(Empty(oMdl06:GetValue("NR0_CODSEQ")),'0',AllTrim(Str(oMdl06:Length(.T.))))) //Publicações Prováveis
	Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TelaTeor
Criação do campo de Teor

@param  lReDraw  Indica se irá recarregar o campo MEMO de teor
@param  oPanel   Objeto Memo que exibe teor da publicação
@param  cValor   Valor a ser indicado no campo MEMO
@param  oView    View de dados de importação de documentos
@param  cViewID  Identificação da View em evidência

@author André Spirigoni
@since 14/03/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TelaTeor(lReDraw, oPanel, cValor, oView, cViewID )
	Local aArea   := GetArea()
	Local  oModel := FwModelActive()
	Local cDetail := ""
	Local oMdlVl
	Local ocTeor
	Local lOcultImp  := Iif(Type("MV_PAR09") != "U",IIf(CVALTOCHAR(MV_PAR09) == '1',.T.,.F.),.F.) //Verifica se o parametro para ocultar a aba de Importadas esta como 1 - Sim

	Default cViewID := Iif (!lOcultImp, cDetail := "NR0DETAIL5", cDetail := "NR0DETAIL1")
	Default cValor  := ""

	If lReDraw
		cDetail := J20GetModel(oView:GetFolderActive('FOLDER_01',2)[1])
		cViewID := cDetail
	Endif
	oMdlVl := oModel:GetModel(cViewID)

	If Empty(cValor)
		cValor := oMdlVl:GetValue("NR0_TEORPB")
	endif

	If Empty(oPanel)
		oPanel := oPnl
	Else
		oPnl := oPanel
	Endif

	//Descrição do andamento
	@ 005,005 Get ocTeor Var cValor Memo Size 600,100 PIXEL OF oPanel

	//<- Seta como Read Only para que o usuario não possa alterar o conteudo.
	// Não alterar com o WHEN, pois desta forma o scroll não funcionara.
	ocTeor:lReadOnly := .T.
	ocTeor:Align:= CONTROL_ALIGN_ALLCLIENT    //ocupa toda a area disponivel da tela de acordo com o monitor.
	oPanel:Refresh()
	SetcTextoPub( cValor )

	RestArea( aArea )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} TeorRefresh
Atualiza o campo de Teor

@param  oPanel   Objeto Memo que exibe teor da publicação
@param  oView    View de dados de importação de documentos
@param  cValor   Valor a ser indicado no campo MEMO
@param  cViewID  Identificação da View em evidência

@author André Spirigoni
@since 14/03/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TeorRefresh(oPanel,oView,cValor, cViewID)
	TelaTeor( .T.,, cValor, oView, cViewID )
	SetcTextoPub(GetcTextoPub())
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} SetCaminho
Indica o caminho do arquivo XML a ser importado

@param	 cValor 	Caminho do arquivo

@author André Spirigoni
@since 14/03/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SetCaminho()
Local oModel := FwModelActive()
Local cValor := AllTrim(cGetFile(cMask,STR0122,,'C:\',.F.,nOr(GETF_LOCALHARD,GETF_NETWORKDRIVE),,.F.))

	If !Empty(cValor) .AND. Substr(cValor,1,1) != '\' //Valida se é utilizado o caminho do servidor
		if cpyt2s(cValor,'/spool/',.T.) //Copia o caminho para a pasta spool quando for utilizado um caminho local
			cValor := '/spool/' + SubStr(cValor, rat('\',cValor) +1)
		Else
			JurMsgErro(STR0096)
			Return .F.
		Endif
	Endif
	cValor := Replace(cValor,'\\','\') //Via HTML é incluido //, realizada tratativa para o caminho.
	cValor := Lower(cValor)
	oModel:LoadValue("NR0MASTER","NR0__PCAM",cValor)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J20VlPgt
Rotina que valida os filtros (perguntas) e inicia a rotina de
importação de documentos

@param		nTipo		1 - XML
2 - Kurier

@return lRet    Indica se as perguntas foram validadas corretamente

@author Jorge Luis Branco Martins Junior
@since 14/03/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function J20VlPgt(nTipo, oGrid, lEnd)
	Local aArea := GetArea()
	Local aPerg := {}
	Local lRet  := .F.

	If oGrid <> Nil
		oGrid:SetMaxMeter(7, 1, STR0010)
	EndIf

	aPerg := J20Perg(nTipo)
	/*
	lRet  := aPerg[1]
	lDoc  := aPerg[2] Validação de documento - Somente XML
	lData := aPerg[3] Validação de Data - Somente Kurier
	*/
	lRet := aPerg[1]

	If oGrid <> Nil
		oGrid:SetIncMeter(1)
	Endif

	If lRet
		FWExecView(STR0118,"JURA020", 4,, { || .T. },, ) // "Alterar"
		lEnd := .T.
	Else
		lEnd := .F.
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J20Perg
Rotina que valida os dados registrados no pergunte

@param		nTipo		1 - XML     2 - Kurier

@return aRet    Indica resultado das validações das perguntas

@author Jorge Luis Branco Martins Junior
@since 25/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J20Perg(nTipo)
Local lDoc  := .T.
Local lData := .F.
Local lRet  := .T.
Local aRet  := {}

If  nTipo == 1

	aRet := {lRet, lDoc, .T.}

ElseIf nTipo == 2

	//Validação de DATAS do pergunte
	If (!Empty(MV_PAR01) .And. !Empty(MV_PAR02) .And. MV_PAR02 >= MV_PAR01 .And. MV_PAR02 - MV_PAR01 <= 30 )
		lData := .T.
	ElseIf (Empty(MV_PAR01) .Or. Empty(MV_PAR02))
		lRet := .F.
		MsgAlert(STR0145)//'Preencha as datas'
	ElseIf !Empty(MV_PAR01) .And. !Empty(MV_PAR02)
		If MV_PAR01 > MV_PAR02
			lRet := .F.
			MsgAlert(STR0146)//'Filtro incorreto. Data inicial está maior que data final'
		ElseIf MV_PAR02 - MV_PAR01 > 30
			lRet := .F.
			MsgAlert(STR0147)//'Periodo máximo para filtro é de 30 dias. Verifique!'
		Endif
	Endif

	If (!Empty(MV_PAR04) .And. !Empty(MV_PAR05))
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+MV_PAR04+MV_PAR05) )
			lData := .T.
		Else
			lRet := .F.
			MsgAlert(STR0184)	//"Cliente não localizado, verifique a digitação do codigo de cliente e loja!"
		EndIf
	ElseIf (!Empty(MV_PAR04) .And. Empty(MV_PAR05))
		lRet := .F.
		MsgAlert(STR0158)//"Preencha também o campo de loja para realizar esse filtro"
	ElseIf (Empty(MV_PAR04) .And. !Empty(MV_PAR05))
		lRet := .F.
		MsgAlert(STR0159)//"Preencha também o campo de cliente para realizar esse filtro"
	Endif

	If (!Empty(MV_PAR03))
		NS8->(dbSetOrder(1))
		If NS8->(dbSeek(xFilial("NS8")+MV_PAR03))
			lData := .T.
		Else
			lRet := .F.
			MsgAlert(STR0190) //"Código de Palavra-Chave inválido"
		EndIf
	Endif

	If lRet
		If (!Empty(AllTrim(MV_PAR04+MV_PAR05)) .Or. !Empty(AllTrim(MV_PAR06)))
			cCajuris := J020FilAsj(MV_PAR04, MV_PAR05, MV_PAR06)
			If Empty(cCajuris)
				MsgAlert(STR0185) //"Não foi localizado nenhum assunto jurídico com os parâmetros solicitados!"
				lRet := .F.
			Endif
		EndIf
	EndIf
	If(!Empty(MV_PAR07))
		If Empty(Posicione("NZP",1,xFilial("NZP")+MV_PAR07,'NZP_LOGIN'))
			MsgAlert(STR0197)//"Agrupador não Existe"
			lRet:= .F.
		Else
			lRet:= .T.
		EndIf
	EndIf

	If lRet .And. !J20ValZero()
		MsgAlert(STR0198)
		lRet := .F.
	EndIf
	aRet := {lRet, .T., lData}

Endif

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J20Import
Rotina que realiza a importação de arquivos

@param  oView   View de dados de importação de documentos
@param  oModel  Modelo de dados de importação de documentos

@author Jorge Luis Branco Martins Junior
@since 06/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J20Import(oView, oModel)
	Local cLocaliz := oModel:GetValue("NR0MASTER","NR0__PCAM")
	Local cCodDoc  := IIF(lXml, MV_PAR02, "") //passo 1

	Default oView := FWViewActive()

	If !Empty(cLocaliz)

		IF !ExistNQZ(oModel)
			ProcJur020("1", oModel, oView) // Importa publicação
		EndIF

	ElseIF !Empty(cCodDoc)

		IF !ExistNQZ(oModel)
			ProcJur020("2", oModel, oView) // Processa registro do arquivo selecionado
		Endif

	ElseIF !ExistNQZ(oModel)
		ProcJur020("3", oModel, oView) // Processa todos os registros de todos os arquivos

	Else
		Alert(STR0016,STR0017) // Caminho não informado!!!
	EndIf

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} J20VisuPro
Rotina para visualização do processo

@param  oView   View de dados de importação de documentos
@param  oModel  Modelo de dados de importação de documentos

@author Jorge Luis Branco Martins Junior
@since 27/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J20VisuPro(oView, oModel)
	Local cDetail    := J20GetModel(oView:GetFolderActive('FOLDER_01',2)[1])
	Local oModelDet  := oModel:GetModel( cDetail )
	Local cTextoPub  := GetcTextoPub()
	Local nI         := 0
	Local aSaveLines := FWSaveRows()
	Local aLines     := {}

	If cDetail == "NR0DETAIL1"
		For nI := 1 To oModelDet:GetQtdLine()
			If oModelDet:GetValue("NR0__TICK", nI) == .T.
				aAdd(aLines, nI)
			EndIF
		Next

		If Len(aLines) > 1
			JurMsgErro(STR0148) // "Existe mais de uma publicação marcada para visualização. Marque apenas uma."
		ElseIf Len(aLines) == 1
			DbSelectArea("NSZ")
			NSZ->(DbSetOrder(1))
			If ( NSZ->(DBSEEK(XFILIAL("NSZ")+oModelDet:GetValue("NR0_CAJURI", aLines[1]))) ) .Or. ( NR0->(FieldPos("NR0_FILPRO")) > 0 .AND. ;
				(NSZ->(DBSEEK(oModelDet:GetValue("NR0_FILPRO", aLines[1])+oModelDet:GetValue("NR0_CAJURI", aLines[1])))) )
				J20VinVisP(oModel, .F., aLines, oView, cTextoPub)
			Else
				Alert(STR0160) //'Não foi localizado processo para visualização'
			EndIf
		EndIf
	ElseIf cDetail == "NR0DETAIL5"
		aAdd(aLines, oModelDet:GetLine())
		J20VinVisP(oModel, .F., aLines, oView, cTextoPub)
	Else
		Alert(STR0149) // "Operação não permitida para publicações nesta situação."
	Endif

	FWRestRows( aSaveLines )
	aSize(aLines, 0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J20VincPro
Rotina para vinculo do processo

@param  oView   View de dados de importação de documentos
@param  oModel  Modelo de dados de importação de documentos

@author Jorge Luis Branco Martins Junior
@since 27/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J20VincPro(oView, oModel)
	Local cDetail    := J20GetModel(oView:GetFolderActive('FOLDER_01',2)[1])
	Local oModelDet  := oModel:GetModel( cDetail )
	Local cTextoPub  := GetcTextoPub()
	Local nI         := 0
	Local aSaveLines := FWSaveRows()
	Local aLines     := {}
	Local lMsg       := .T.

	If cDetail == "NR0DETAIL2" .OR. cDetail == "NR0DETAIL3" .OR. cDetail == "NR0DETAIL6" .Or. cDetail == "NR0DETAIL1"

		IncProc(STR0210)	//"Vinculando publicações selecionadas"

		DbSelectArea("NSZ")
		NSZ->( DbSetOrder(1) )	//NSZ_FILIAL + NSZ_COD

		//Processa enquanto estiver registro selecionado
		While oModelDet:SeekLine( { {"NR0__TICK", .T.} } )

			nI := oModelDet:GetLine()

			If cDetail == 'NR0DETAIL1'
				If NSZ->( DbSeek(oModelDet:GetValue("NR0_FILPRO") + oModelDet:GetValue("NR0_CAJURI")) )
					Alert(STR0149) // "Operação não permitida para publicações nesta situação."
					lMsg := .F.
					Exit
				Else
					aAdd(aLines, nI)
				Endif
			Else
				aAdd(aLines, nI)
			Endif

			oModelDet:SetValue("NR0__TICK" , .F.)
		EndDo

		If Len(aLines) > 0
			J20VinVisP(oModel, .T., aLines, oView, cTextoPub)
		ElseIf lMsg
			Alert(STR0161)//'Não foi selecionada nenhuma publicação para vínculo. Verifique!'
		Endif

	Else
		Alert(STR0149) // "Operação não permitida para publicações nesta situação."
	EndIf

	FWRestRows( aSaveLines )
	aSize(aLines, 0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J20VinVisP
Rotina para vinculo e visualização do processo

@param  oModel  Modelo de dados de importação de documentos
@param  lVin    Indica se é vinculo ou não(visualização)
@param  aLines  Indica as linhas selecionadas no grid
@param  oView   View de dados de importação de documentos

@author Jorge Luis Branco Martins Junior
@since 27/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J20VinVisP(oModel, lVin, aLines, oView, cTextoPub)
Local oClient, oLoja, oProces, oAutor, oReu, oTpAcao, oCaso, oComarca, oForo, oVara, oTxtPub, oDlgVinc
Local cDetail   	:= J20GetModel(oView:GetFolderActive('FOLDER_01',2)[1])
Local oModelDet 	:= oModel:GetModel( cDetail )
Local cQryVinc		:= ""
Local cVar      	:= ""
Local cCajuri   	:= ""
Local cCajurP   	:= ""
Local aTxtMem		:= {}
Local aVetor    	:= {}
Local lHab    	    := .F.
Local cLista  	    := GetNextAlias()
Local cAutor    	:= CriaVar('NT9_NOME', .F.)
Local cReu      	:= CriaVar('NT9_NOME', .F.)
Local cCaso		    := CriaVar('NSZ_NUMCAS', .F.)
Local cProces   	:= CriaVar('NUQ_NUMPRO', .F.)
Local cVara     	:= CriaVar('NUQ_CLOC3N', .F.)
Local cTpAcao   	:= CriaVar('NUQ_CTIPAC', .F.)
Local oOk       	:= LoadBitmap( GetResources(), "LBOK" ) //CHECKED    //LBOK  //LBTIK
Local oNo       	:= LoadBitmap( GetResources(), "LBNO" ) //UNCHECKED  //LBNO
Local oLbx

Static cClient   	:= ""
Static cTxtPub   	:= ""
Static cLoja     	:= ""
Static cComarca  	:= ""
Static cForo     	:= ""

Default cTextoPub := ''
Default aLines    := {}

	cClient  := CriaVar('NSZ_CCLIEN', .F.)
	cTxtPub  := CriaVar('NT4_DESC', .F.)
	cLoja    := CriaVar('NSZ_LCLIEN', .F.)
	cComarca := CriaVar('NUQ_CCOMAR', .F.)
	cForo    := CriaVar('NUQ_CLOC2N', .F.)

	If !lVin
		cCajuri := oModelDet:GetValue("NR0_CAJURI", aLines[1])
	Endif

	If cDetail == 'NR0DETAIL6' .And. !lXml .And. !lXmlWS
		cCajurP := oModelDet:GetValue("NR0_CAJURP", aLines[1])
	Endif

	If !Empty(cCajuri)

		aVetor:={}
		cQryVinc := "SELECT NSZ_COD,A1_NOME, "
		cQryVinc += "A1_COD, A1_LOJA, "
		cQryVinc += "A1_NREDUZ,"
		cQryVinc += "NUQ_NUMPRO, "
		cQryVinc += "NT9_NOME, "
		cQryVinc += "NQU_DESC,"
		cQryVinc += "NSZ_NUMCAS, "
		cQryVinc += "NQ6_DESC, "
		cQryVinc += "NQC_DESC,"
		cQryVinc += "NQE_DESC "
		cQryVinc += "FROM " + RetSqlName("NSZ") + " NSZ "
		cQryVinc += "LEFT JOIN " + RetSqlName("NUQ") + " NUQ "
		cQryVinc += "ON NUQ.NUQ_CAJURI = NSZ.NSZ_COD "
		cQryVinc += "AND NUQ.NUQ_INSATU = '1' "
		cQryVinc += "AND NUQ.D_E_L_E_T_ = ' ' "
		cQryVinc += "LEFT JOIN " + RetSqlName("SA1") + " SA1 "
		cQryVinc += "ON SA1.A1_COD  = NSZ.NSZ_CCLIEN "
		cQryVinc += "AND SA1.A1_LOJA = NSZ.NSZ_LCLIEN "
		cQryVinc += "AND SA1.D_E_L_E_T_ = ' ' "
		cQryVinc += "LEFT JOIN " + RetSqlName("NQ6") + " NQ6 "
		cQryVinc += "ON NQ6.NQ6_COD = NUQ.NUQ_CCOMAR "
		cQryVinc += "AND NUQ.NUQ_INSATU = '1' "
		cQryVinc += "AND NQ6.D_E_L_E_T_ = ' ' "
		cQryVinc += "LEFT JOIN " + RetSqlName("NQC") + " NQC "
		cQryVinc += "ON NQC.NQC_COD = NUQ.NUQ_CLOC2N "
		cQryVinc += "AND NQC.NQC_CCOMAR = NUQ.NUQ_CCOMAR "
		cQryVinc += "AND NQC.D_E_L_E_T_ = ' ' "
		cQryVinc += "LEFT JOIN " + RetSqlName("NQE") + " NQE "
		cQryVinc += "ON NQE.NQE_COD    = NUQ.NUQ_CLOC3N "
		cQryVinc += "AND NQE.NQE_CLOC2N = NUQ.NUQ_CLOC2N "
		cQryVinc += "AND NQE.D_E_L_E_T_ = ' ' "
		cQryVinc += "LEFT JOIN " + RetSqlName("NQU") + " NQU "
		cQryVinc += "ON NQU.NQU_COD = NUQ.NUQ_CTIPAC "
		cQryVinc += "AND NQU.D_E_L_E_T_ = ' ' "
		cQryVinc += "LEFT JOIN " + RetSqlName("NT9") + " NT9 "
		cQryVinc += "ON NT9.NT9_CAJURI = NSZ.NSZ_COD "
		cQryVinc += "AND NT9.D_E_L_E_T_ = ' ' "
		cQryVinc += " 			AND NSZ.D_E_L_E_T_ = ' ' "
		cQryVinc += " WHERE NSZ.NSZ_COD = '"+cCajuri+"' "

		cQryVinc := ChangeQuery(cQryVinc)
		dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQryVinc ) , cLista, .T., .F.)
			While !(cLista)->( Eof() )

				cClient	 := (cLista)->A1_NOME
				cLoja	 := (cLista)->A1_LOJA
				cAutor 	 := rTrim(Posicione('NT9',3, xFilial('NT9')+ cCajuri + '1' + '1','NT9_NOME'))
				cProces	 := (cLista)->NUQ_NUMPRO
				cReu   	 := rTrim(Posicione('NT9',3, xFilial('NT9')+ cCajuri + '2' + '1','NT9_NOME'))
				cTpAcao	 := (cLista)->NQU_DESC
				cCaso  	 := (cLista)->NSZ_NUMCAS
				cComarca := (cLista)->NQ6_DESC
				cForo  	 := (cLista)->NQC_DESC
				cVara    := (cLista)->NQE_DESC
				cTxtPub	 := cTextoPub

				aVetor	 :={}
				Aadd(aVetor, {(cLista)->NUQ_NUMPRO, (cLista)->NSZ_COD, cAutor, cReu, (cLista)->NQU_DESC} )

				(cLista)->( DbSkip() )
			End

		(cLista)->(dbCloseArea())

		lHab:=.F.

	//Nao Localizada e Duplicadas
	Else
		aVetor:={}
		aadd(aVetor,{.F., "", "", "", "", ""})
		lHab:=.T.
	Endif

	DEFINE MSDIALOG oDlgVinc TITLE STR0065 FROM 218,178 TO 705,964 PIXEL STYLE DS_MODALFRAME//"Selecione o processo correspondente ao do arquivo XML"
	//Cliente
	@ 005,005 Say STR0066 Size 030,008 PIXEL	OF oDlgVinc
	@ 015,005 MsGet oClient	Var cClient Picture "@!"   F3 "SA1" When lHab	Size 090,008 PIXEL 	OF oDlgVinc HasButton

	//Loja
	@ 005,105 Say STR0091 Size 030,008 PIXEL	OF oDlgVinc
	@ 015,105 MsGet oLoja Var cLoja	Picture "@!" 	        When lHab	Size 034,008 PIXEL 	OF oDlgVinc

	//Caso
	@ 005,205 Say STR0071 Size 050,008 PIXEL	OF oDlgVinc
	@ 015,205 MsGet oCaso Var cCaso F3 "NVEXML"  When lHab Size 134,008 PIXEL 	OF oDlgVinc HasButton

	//Processo
	@ 025,005 Say STR0067  Size 030,008 PIXEL	OF oDlgVinc
	@ 035,005 MsGet oProces	Var cProces When lHab	Size 134,008 PIXEL 	OF oDlgVinc

	//Autor
	@ 045,005 Say STR0068  Size 030,008 PIXEL	OF oDlgVinc//"Autor"
	@ 055,005 MsGet oAutor 	Var cAutor  When lHab	Size 134,008 PIXEL 	OF oDlgVinc

	//Réu
	@ 065,005 Say STR0069 Size 030,008 PIXEL	OF oDlgVinc
	@ 075,005 MsGet oReu  Var cReu When lHab	Size 134,008 PIXEL 	OF oDlgVinc

	//Tipo de ação
	@ 085,005 Say STR0070 Size 050,008 PIXEL	OF oDlgVinc
	@ 095,005 MsGet oTpAcao	 Var cTpAcao F3 "NQU" When lHab	Size 134,008 PIXEL 	OF oDlgVinc HasButton

	//Comarca
	@ 025,205 Say STR0072 Size 050,008 PIXEL	OF oDlgVinc
	@ 035,205 MsGet oComarca Var cComarca F3 "NQ6"	 When lHab	Size 134,008 PIXEL 	OF oDlgVinc HasButton

	//Foro / Tribunal
	@ 045,205 Say STR0073 Size 050,008 PIXEL	OF oDlgVinc
	@ 055,205 MsGet oForo 	 Var cForo F3 "NQCXML"	When lHab	Size 134,008 PIXEL 	OF oDlgVinc HasButton

	//Vara / Órgão
	@ 065,205 Say STR0074 Size 050,008 PIXEL	OF oDlgVinc
	@ 075,205 MsGet oVara Var cVara F3 "NQEXML"  When lHab	Size 134,008 PIXEL 	OF oDlgVinc HasButton

	//Texto da Publicação
	@ 105,005 Say STR0075 Size 050,008 PIXEL	OF oDlgVinc
	@ 115,005 GET oTxtPub Var cTxtPub MEMO When .F.	Size 378,040 PIXEL 	OF oDlgVinc

	If lHab
		@ 095,205 BUTTON STR0034 SIZE 30,10 ACTION (cClient:=Space(50), cProces:=Space(50), cAutor:=Space(50), cReu:=Space(50),;
		cLoja := Space(2), cTpAcao:=Space(50), cCaso:=Space(50), cComarca:=Space(50), cForo:=Space(50), cVara:=Space(50),;
		oClient:Refresh(), oLoja:Refresh(), oProces:Refresh(), oAutor:Refresh(), oReu:Refresh(), oTpAcao:Refresh(), oCaso:Refresh(), ;
		oComarca:Refresh(),oForo:Refresh(), oVara:Refresh())																							PIXEL OF oDlgVinc//"&Limpar"

		@ 095,245 BUTTON STR0046 SIZE 30,10 ACTION (aTxtMem := PesqVinc(cClient,cLoja,cProces,cAutor,cReu,cTpAcao,cCaso,cComarca,cForo,cVara,@oLbx,@aVetor,cCajurP,cDetail)) PIXEL OF oDlgVinc//"Pesquisar"

		@ 165,005 LISTBOX oLbx VAR cVar FIELDS HEADER " ", STR0090,STR0076,STR0068,STR0069,STR0070; //#"Num.Processo"#"Cód.Interno"#Autor"#"Réu"#"Tipo de Ação"
		SIZE 380,060 OF oDlgVinc PIXEL ON dblClick(aVetor[oLbx:nAt,1] := !aVetor[oLbx:nAt,1] )
		oLbx:bChange := {|| (cTxtPub:=cTextoPub,oTxtPub:Refresh()) }
		oLbx:SetArray( aVetor )
		oLbx:bLine := {|| {Iif(aVetor[oLbx:nAt,1],oOk,oNo),aVetor[oLbx:nAt,2],aVetor[oLbx:nAt,3],aVetor[oLbx:nAt,4],aVetor[oLbx:nAt,5],aVetor[oLbx:nAt,6]}}
	Else
		@ 165,005 LISTBOX oLbx VAR cVar FIELDS HEADER ;
		STR0090,STR0076,STR0068,STR0069,STR0070; //#"Num.Processo"#"Cód.Interno"#Autor"#"Réu"#"Tipo de Ação"
		SIZE 380,060 PIXEL OF oDlgVinc
		oLbx:bChange := {||}
		oLbx:SetArray( aVetor )
		oLbx:bLine := {|| {aVetor[oLbx:nAt,1],aVetor[oLbx:nAt,2],aVetor[oLbx:nAt,3],aVetor[oLbx:nAt,4],aVetor[oLbx:nAt,5]}}
	Endif
	oTxtPub:Refresh()
	DEFINE SBUTTON FROM 230,300 TYPE 1 ACTION ((cClient:=Space(50), cProces:=Space(50), cAutor:=Space(50), cReu:=Space(50),;
	cLoja := Space(2), cTpAcao:=Space(50), cCaso:=Space(50), cComarca:=Space(50), cForo:=Space(50), cVara:=Space(50),;
	oClient:Refresh(), oLoja:Refresh(), oProces:Refresh(), oAutor:Refresh(), oReu:Refresh(), oTpAcao:Refresh(), oCaso:Refresh(), ;
	oComarca:Refresh(),oForo:Refresh(), oVara:Refresh()),IIF(lHab,J20ConfVinc(aVetor, oModel, aLines, oView),.T.),oDlgVinc:End()) ENABLE 	OF oDlgVinc  //Botão Ok
	DEFINE SBUTTON FROM 230,340 TYPE 2 ACTION (oDlgVinc:End()) ENABLE 	OF oDlgVinc  //Botão Cancelar

	oDlgVinc:LESCCLOSE := .F. // Chamar logo antes do Activate
	ACTIVATE MSDIALOG oDlgVinc CENTERED

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J20Excluir
Rotina para excluir publicação selecionada

@param  oView   View de dados de importação de documentos
@param  oModel  Modelo de dados de importação de documentos

@author Jorge Luis Branco Martins Junior
@since 27/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J20Excluir(oView, oModel)
	Local cDetail    := J20GetModel(oView:GetFolderActive('FOLDER_01',2)[1])
	Local oModelDet  := oModel:GetModel( cDetail )
	Local nCount     := 0
	Local aSaveLines := FWSaveRows()
	Local cCodDoc    := IIF(lXml, MV_PAR02, "")

	ProcRegua(0)
	IncProc()

	If cDetail == "NR0DETAIL1" .OR. cDetail == "NR0DETAIL2" .OR. cDetail == "NR0DETAIL3" .OR. cDetail == "NR0DETAIL4" .OR. cDetail == "NR0DETAIL6"

		IncProc(STR0208)	//"Excluíndo publicações selecionadas"

		While oModelDet:SeekLine( { {"NR0__TICK", .T.} } )
			nCount++

			If cDetail != "NR0DETAIL4"
				oModelDet:SetValue("NR0_SITUAO", oModelDet:GetValue("NR0_SITUAC"))
				oModelDet:SetValue("NR0_SITUAC", "4")
				oModelDet:SetValue("NR0_DTALTE", dDataBase)
				oModelDet:SetValue("NR0_USRALT", __cUserId)
				oModelDet:SetValue("NR0__TICK" , .F.)
			Else
				oModelDet:DeleteLine()
			Endif
		EndDo

		If oModel:VldData()
			oModel:CommitData()
		EndIf

		If nCount > 0
			AtuTela(cCodDoc, oModel, oView, .T.)
		Endif

	Else
		Alert(STR0149) // "Operação não permitida para publicações nesta situação."
	Endif

	FWRestRows( aSaveLines )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J20Restore
Rotina para restaurar publicação excluida

@param  oView   View de dados de importação de documentos
@param  oModel  Modelo de dados de importação de documentos

@author Jorge Luis Branco Martins Junior
@since 27/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J20Restore(oView, oModel)
	Local cDetail    := J20GetModel(oView:GetFolderActive('FOLDER_01',2)[1])
	Local oModelDet  := oModel:GetModel( cDetail )
	Local nCount     := 0
	Local aSaveLines := FWSaveRows()
	Local cCodDoc    := IIF(lXml, MV_PAR02, "")

	ProcRegua(0)
	IncProc()

	If cDetail == "NR0DETAIL4"

		IncProc(STR0209)	//"Restaurando publicações selecionadas"

		While oModelDet:SeekLine( { {"NR0__TICK", .T.} } )
			nCount++

			oModelDet:SetValue("NR0_SITUAC", oModelDet:GetValue("NR0_SITUAO"))
			oModelDet:SetValue("NR0_DTALTE", dDataBase)
			oModelDet:SetValue("NR0_USRALT", __cUserId)
			oModelDet:SetValue("NR0__TICK" , .F.)
		EndDo

		If oModel:VldData()
			oModel:CommitData()
		EndIf

		If nCount > 0
			AtuTela(cCodDoc, oModel, oView, .T.)
		Endif

	Else
		Alert(STR0149) // "Operação não permitida para publicações nesta situação."
	Endif

	FWRestRows( aSaveLines )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J20Concil
Rotina que efetua a conciliação

@param  oView   View de dados de importação de documentos
@param  oModel  Modelo de dados de importação de documentos

@author Jorge Luis Branco Martins Junior
@since 26/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J20Concil(oView, oModel, cCodAto, cCajuAuto, cFilpAuto, nTipoCon)
	Local aLines     := {}
	Local aPalavraCh := {}
	Local aRet       := {.F.,""}
	Local aSaveLines := FWSaveRows()
	Local cDesAto    := Space(100)
	Local cDetail    := ""
	Local cCodDoc    := IIF(lXml, MV_PAR02, "")
	Local cMostraClie:= SuperGetMV('MV_JNT4CLI',, '2')	//Paramentro exigido para preenchimento do campo "NT4_PCLIEN"
	Local cCodFase   := SuperGetMV('MV_JNT4FAS',, '')// Parametro para retornar o código da fase processual
	Local lConf      := .F.
	Local nI         := 0
	Local nCtRef     := 0 //variável que via controlar a quantidade de vezez que o incproc é chamado para diminuir a troca de mensagens
	Local oModelNT4  := Nil
	Local oModelDet  := Nil
	Local cMensagem  := ""

	// Parâmetro para caso da automação em que é obrigatório passar o código do ato
	Default cCodAto   := Space(TAMSX3('NRO_COD')[1])
	Default oView     := Nil
	Default cCajuAuto := ""
	Default cFilpAuto := ""

	Default nTipoCon  := 1	//1=Conciliar Manual \ 2=Conciliar Automático

	Private __JurConErr := .F. //variável estática que controla se deu erro na inclusão do andamento/fw.

	lAutomato := !Empty(cCodAto) // Se estiver vazio não é automação

	If lAutomato
		cDetail    := J20GetModel(2)
		oModelDet  := oModel:GetModel( cDetail )
		oModelDet:LoadValue("NR0__TICK",.T.) //simular como usuário estivesse clicando no grid
	Else
		cDetail    := J20GetModel(oView:GetFolderActive('FOLDER_01',2)[1])
		oModelDet  := oModel:GetModel( cDetail )
	EndIf

	aLines := J020VlConc(oModelDet, cDetail, cCajuAuto, cFilpAuto)
	aRet   := J20CclVld(cMostraClie, cCodFase)

	If aRet[1] .And. Len(aLines) > 0	 //Valida as publicações na Aba de 'Publicações Localizadas'

		// Tela de seleção de Ato
		If !lAutomato

			If nTipoCon == 1 //1=Conciliar Manual
				cCodAto := SelAtoPro()
			Else //2=Conciliar Automático
				aPalavraCh := J020Palavr()
			EndIf

			//Verifica se deve continuar com a conciliação
			lConf := !Empty(cCodAto) .Or. Len(aPalavraCh) > 0
		Else
			cDesAto := JurGetDados("NRO", 1, xFilial("NRO") + AvKey(cCodAto,"NRO_COD"), "NRO_DESC")
			lConf   := !Empty(cDesAto)
		EndIf

		If lConf
			//================================
			//Localizada
			//================================
			DbSelectArea("NR0")
			NR0->( DbSetOrder(1) )	//NR0_FILIAL, NR0_CODIMP, NR0_CODSEQ

			If !lAutomato
				//estabelece o tamanho da régua
				ProcRegua(Len(aLines))
				lAbortPrint := .F. //zera a variável do cancelamento
			EndIf

			//Carrega o model de andamento apenas 1 vez
			oModelNT4 := FWLoadModel('JURA100')

			For nI := 1 To Len(aLines)

				If NR0->(DbSeek(xFilial("NR0") + JA020GetPub(oModelDet, 1, aLines[nI])))

					//2=Conciliar Automático
					If nTipoCon == 2 .And. Len(aPalavraCh) > 0
						cCodAto := J20RetAto(NR0->NR0_TEORPB, aPalavraCh)
					EndIf



					If Empty(cCodAto)
						aRet[2] := STR0205 + CRLF +;	//"Algumas Publicações não foram conciliadas, porque não foi encontrado o Ato Processual Automático."
									STR0206				//"Utilize a apção Conciliar Manual, para concilia-las.
					Else
						//Criação de PE na função J20CclProc que enviará código do andamento gerado e devolva verdadeiro ou falso na criação do andamento
						aRet := J20CclProc(cCodAto, cMostraClie, cCodFase, oModelNT4)

						If !aRet[1] .AND. !lAutomato // Erro no Processamento da conciliação
							JurMsgErro(aRet[2])
													ElseIf !aRet[1] //se der erro no processamento e for automação, manda o Help
							Help(,, 'Help',, aRet[2] , 1, 0 ) // Joga erro na tela do robo
						EndIf
					EndIf

				EndIf

				If !lAutomato // Se não for automação
					if __JurConErr //valida se houve erro em algum lugar na conciliação para dar um tempo do usuário clicar no botão cancelar.
						__JurConErr := .F.
						Sleep(1000)
					Endif

					nCtRef++

					If nCtRef == 50 .Or. (Len(aLines) - nI) < 50
						nCtRef := 0
						incProc(I18N(STR0189,{nI,Len(aLines)})) //"Conciliando publicação #1 de #2"
					Endif

					If lAbortPrint //valida se não foi cancelado.
						Exit
					EndIf
				ElseIf !aRet[1] //Se for automação e tiver erro // Verificar se deve haver interrupção caso aconteça algum erro, ou se deve ser ignorado
					Help( ,, 'Help',, aRet[2], 1, 0 )
					Exit
				EndIf
			Next

			//Destroy model de andamento
			If oModelNT4 <> Nil
				oModelNT4:Destroy()
			EndIf

			FWModelActive(oModel, .T.) //volta o modelo ativo para a NR0

			// Somente executa se for a rotina normal
			If !lAutomato
				If aRet[1]

					If !Empty(aRet[2])
						cMensagem := aRet[2]
					Else
						cMensagem := STR0057	//"Processo efetuado com sucesso."
					EndIf

					Aviso(STR0056, cMensagem, {"Ok"})	//"Conciliacao"
					Processa({|| AtuTela(cCodDoc, oModel, oView)})//Refresh da tela
				EndIf
			EndIf
		Else//Mostra mensagem se der erro na conciliação
			If nTipoCon == 1//Erro na concilição:
				cMensagem := STR0108 + CRLF + STR0213// "Para conciliar Informe um ato processual."
			Else
				cMensagem := STR0108 + CRLF + STR0214//"Para conciliar cadastre ao menos uma palavra chave, em ato processual automatico."
			EndIf
			If lAutomato
				Help( ,, 'Help',, cMensagem , 1, 0 )
			Else
				JurMsgErro(cMensagem )
			EndIF
		Endif
	Else
		If !Empty( aRet[2] )
			If lAutomato
				Help( ,, 'Help',, aRet[2] , 1, 0 )
				Processa({|| AtuTela(cCodDoc, oModel, oView)})//Refresh da tela
			Else
				JurMsgErro(aRet[2])
				Processa({|| AtuTela(cCodDoc, oModel, oView)})//Refresh da tela
			EndIf
		Else
			Processa({|| AtuTela(cCodDoc, oModel, oView)})//Refresh da tela
		EndIf
	EndIf

	FWRestRows( aSaveLines )

	//Limpa memória.
	aSize(aLines,0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J20Pesqui
Rotina para pesquisar publicação

@param  oView   View de dados de importação de documentos
@param  oModel  Modelo de dados de importação de documentos

@author Jorge Luis Branco Martins Junior
@since 27/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J20Pesqui(oView, oModel)
	Local cCodDoc    := IIF(lXml, MV_PAR02, "")
	Local cDetail    := J20GetModel(oView:GetFolderActive('FOLDER_01',2)[1])
	Local lOcultNLoc := J020VldPar('MV_PAR08')

	If Empty(cCodDoc) //se for Kurier
		If !lOcultNLoc .AND. cDetail == "NR0DETAIL3" //Se estiver na não localizadas, precisa reprocessar tudo
			ProcJur020("3", oModel, oView)
		Else
			Processa({|| AtuTela(cCodDoc, oModel, oView, /*lForce*/)})
		EndIf
	Else
		ProcJur020("2", oModel, oView)
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J20Refresh
Atualiza a tela

@param  oView   View de dados de importação de documentos
@param  oModel  Modelo de dados de importação de documentos

@author Jorge Luis Branco Martins Junior
@since 27/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J20Refresh(oView, oModel)
	Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J020VlConc()
Valida as publicações da aba Publicação Localizada para Conciliar

@param  oModelDet  Modelo DETAIL (Filho)de dados de importação de
documentos
@param  cDetail    Nome do Detail

@Return aLines     Linhas selecionadas para conciliação

@author Jorge Luis Branco Martins Junior
@since 06/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J020VlConc(oModelDet, cDetail, cCajuAuto, cFilpAuto)
Local aSaveLines := FWSaveRows()
Local lAutomato  := !Empty(cCajuAuto)
Local nQtdLines  := oModelDet:GetQtdLine()
Local nI         := 0
Local aLines     := {}
Local cCajuri    := ""
Local cFilPro    := ""
Local cNumPro    := ""
Local lMsg       := .T.

	If cDetail == "NR0DETAIL1"
		For nI := 1 To nQtdLines
			If oModelDet:GetValue("NR0__TICK", nI)

				cNumPro := oModelDet:GetValue("NR0_NUMPRO", nI)
				cCajuri := Iif(lAutomato,cCajuAuto,oModelDet:GetValue("NR0_CAJURI", nI))
				cFilPro := Iif(lAutomato,cFilpAuto,oModelDet:GetValue("NR0_FILPRO", nI))

				DbSelectArea("NSZ")
				NSZ->(DbSetOrder(1))

				If (NSZ->(DbSeek(xFilial("NSZ") + cCajuri ))) .Or. (NR0->(FieldPos("NR0_FILPRO")) > 0 .AND. (NSZ->(DbSeek(cFilPro + cCajuri ))))
					aAdd(aLines, nI)
				Else
					DbSelectArea("NR0")
					NR0->(DbSetOrder(4))

					Begin Transaction
					If NR0->(DbSeek(xFilial("NR0") + cCajuri + cNumPro))
						NR0->(RecLock("NR0", .F.))
						NR0->NR0_SITUAC := "3"
						NR0->NR0_CAJURI := " "
						NR0->NR0_FILPRO := " "
						NR0->( MsUnlock() )
					EndIf
					End Transaction

					lMsg := .F.
				Endif
			Endif
		Next

		If Len(aLines) < 1 .and. lMsg
			MsgInfo(STR0093)//"Não há nenhum processo selecionado nas Publicações Localizadas"
		EndIf
	Else
		Alert(STR0149)	// "Operação não permitida para publicações nesta situação."
	Endif

	FWRestRows( aSaveLines )

	Return aLines

//-------------------------------------------------------------------
/*/{Protheus.doc} J20GetModel()
Retorna o detail da aba que está ativa

Obs:
NR0DETAIL5 - Importadas
NR0DETAIL1 - Localizadas
NR0DETAIL3 - Não Localizada
NR0DETAIL2 - Duplicadas
NR0DETAIL4 - Excluidas

@param  nAba  Número da aba em evidência

@Return cDetail Indica detail em evidência

@author Jorge Luis Branco Martins Junior
@since 27/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J20GetModel(nAba)
	Local cDetail    := ""
	Local lOcultNLoc := J020VldPar('MV_PAR08')
	Local lOcultImp  := J020VldPar('MV_PAR09')

	If nAba == 1
		Iif (!lOcultImp, cDetail := "NR0DETAIL5", cDetail := "NR0DETAIL1")
	ElseIf nAba == 2
		If lOcultImp .AND. !lOcultNLoc
			cDetail := "NR0DETAIL3"
		ElseIf lOcultImp .AND. lOcultNLoc
			cDetail := "NR0DETAIL2"
		Else
			cDetail := "NR0DETAIL1"
		EndIf
	ElseIf nAba == 3
		If !lOcultNLoc .AND. !lOcultImp
			IIf( lXml .Or. lXmlWS, cDetail := "NR0DETAIL3", cDetail := "NR0DETAIL4" )
		ElseIf lOcultNLoc .AND. lOcultImp
			cDetail := "NR0DETAIL4"
		Else
			IIf( lXml .Or. lXmlWS, cDetail := "NR0DETAIL2", cDetail := "NR0DETAIL4" )
		EndIf
	ElseIf nAba == 4
		If lOcultImp .OR. lOcultNLoc
			IIf( lXml .Or. lXmlWS, cDetail := "NR0DETAIL4", cDetail := "NR0DETAIL6" )
		Else
			IIf( lXml .Or. lXmlWS, cDetail := "NR0DETAIL2", cDetail := "NR0DETAIL6" )
		EndIf
	Else
		cDetail := "NR0DETAIL4"
	EndIf

	Return cDetail

//-------------------------------------------------------------------
/*/{Protheus.doc} J20ConfVinc()
Confirma o Vinculo do arquivo importado XML com o Cod.Processo

@param  aVetor  Indica processo selecionado na pesquisa
@param  oModel  Modelo de dados de importação de documentos
@param  aLines  Indica as linhas selecionadas no grid
@param  oView   View de dados de importação de documentos

@author Jorge Luis Branco Martins Junior
@since 05/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J20ConfVinc(aVetor, oModel, aLines, oView)
Local cDetail    := J20GetModel(oView:GetFolderActive('FOLDER_01',2)[1])
Local oModelDet  := oModel:GetModel( cDetail )
Local cCodDoc    := IIF(lXml, MV_PAR02, "")
Local nI         := 0
Local nJ         := 0
Local lVetor     := .F.
Local aSaveLines := FWSaveRows()
Local lAtuNum    := SuperGetMV('MV_JPUBNUM',, '1') == '1'
Local lCmpFilPro := NR0->( FieldPoS("NR0_FILPRO") ) > 0
Local lReproc    := .F.

	If Len(aVetor) > 0
		For nJ := 1 to Len(aVetor)
			If aVetor[nJ][1] .And. ALLTRIM(aVetor[nJ][2]) <> "" .And. ALLTRIM(aVetor[nJ][3]) <> ""
				lVetor := .T.
				Exit
			Endif
		Next

		If Len(aLines) > 0 .And. lVetor
			For nI := 1 To Len(aLines)

				DbSelectArea("NR0")
				NR0->( DbSetOrder(1) ) //NR0_FILIAL, NR0_CODIMP, NR0_CODSEQ
				If NR0->( DbSeek(xFilial("NR0") + JA020GetPub(oModelDet, 1, aLines[nI])) )

					DbSelectArea("NUQ")
					NUQ->( DbSetOrder(2) )	//NUQ_FILIAL+NUQ_CAJURI+NUQ_INSATU

					If (!Empty(NR0->NR0_NUMPRO)) .And. lAtuNum .And. ApMsgYesNo(STR0164) // "Deseja Atualizar o número do processo?"
						lReproc := .T.
						J20Vincula(aVetor[nJ][7], aVetor[nJ][3], lCmpFilPro, .T.)
					Else
						lReproc := .F.
						J20Vincula(aVetor[nJ][7], aVetor[nJ][3], lCmpFilPro, .F.)
					Endif
				EndIf
			Next
		EndIf
	Endif

	if lReproc //se atualizou o número, reprocessa os não localizados, caso contrário não há necessidade
		If !Empty(cCodDoc)
			If !ExistNQZ(oModel)
				ProcJur020("2", oModel, oView)//Processa somente o registros do arquivo selecionado
			Else
				Processa({|| AtuTela(, oModel, oView,.T.)}) //apenas atualiza os dados
			EndIf
		Else
			Processa({||ProcJur020("3", oModel, oView)})//Processa todos os registros
		Endif
	Else
		Processa({|| AtuTela(, oModel, oView,.T.)}) //apenas atualiza os dados
	Endif

	FWRestRows( aSaveLines )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JA020GetPub
Retorna o filtro para Seek do objeto

@param  oModel   Modelo de dados de importação de documentos
@param  nIndice  Indica o indice usado (controle da função)
@param  nLine    Linha do grid selecionada

@return cFiltro Indica a chave para Seek na tabela NR0

@author Jorge Luis Branco Martins Junior
@since 15/05/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA020GetPub(oModel, nIndice, nLine)
	Local cFiltro := ""

	If nIndice == 1
		cFiltro := PADR((oModel:GetValue("NR0_CODIMP", nLine)),TamSX3('NR0_CODIMP')[1]," ") + PADR((oModel:GetValue("NR0_CODSEQ", nLine)),TamSX3('NR0_CODSEQ')[1]," ")
	EndIf

Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} PesqVinc
Efetua a pesquisa para vinculo de processos

@param  cClient   Indica o cliente para pesquisa
@param  cLoja     Indica a loja para pesquisa
@param  cProces   Indica o processo para pesquisa
@param  cAutor    Indica o autor para pesquisa
@param  cReu      Indica o réu para pesquisa
@param  cTpAcao   Indica o tipo de ação para pesquisa
@param  cCaso     Indica o caso para pesquisa
@param  cComarca  Indica a comarca para pesquisa
@param  cForo     Indica o foro para pesquisa
@param  cVara     Indica a vara para pesquisa
@param  oLbx      Objeto que indica os dados
@param  aVetor    Dados do processos que serão exibidos na busca
@param  cCajurP   Indica Processos prováveis (KURIER)
@param  cDetail   Indica o model detail que está em evidência

@return aText     Indica texto da publicação

@author Jorge Luis Branco Martins Junior
@since 06/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function PesqVinc(cClient,cLoja,cProces,cAutor,cReu,cTpAcao,cCaso,cComarca,cForo,cVara,oLbx,aVetor,cCajurP,cDetail, cExclui)

	Local aArea		:= GetArea()
	Local cTabTemp	:= GetNextAlias()
	Local cQryVinc	:=""
	Local cTxtPub   :=""
	Local cCodNsz 	:=""
	Local cDesNQU  	:=""
	Local cNomST9 	:=""
	Local cNomSA1  	:=""
	Local cNumPro   :=""
	Local cCondNUQ  :=""
	Local cCondNT9  :=""
	Local aCajurP   := {}
	Local aCodDup   := {}
	Local aArray    := {}
	Local aText     := {}
	Local lExistNUQ := .F.
	Local lExistNT9 := .F.
	Local nI        := 0
	Local aFiliais  := ''
	Local cFiliais  := ''

	Default cClient	:=""
	Default cProces	:=""
	Default cAutor 	:=""
	Default cReu   	:=""
	Default cTpAcao	:=""
	Default cCaso 	:=""
	Default cComarca:=""
	Default cForo   :=""
	Default cVara  	:=""
	Default cExclui :="" 

	aFiliais := JURFILUSR(__CUSERID, "NSZ")[3]

	For nI := 1 To Len(aFiliais)
		cFiliais := (cFiliais + "'" + aFiliais[nI] + "'" + ",")
	Next nI

	cFiliais := UPPER(SUBSTR(cFiliais, 1, Len(cFiliais)-1))

	nI := 0

	cCondNUQ:=" AND EXISTS(SELECT NUQ_CAJURI FROM "+RetSqlName("NUQ")+" NUQ WHERE 1 = 1 "
	cCondNUQ+="AND NSZ_COD = NUQ_CAJURI "
	If !JurAuto() .Or. Empty(Alltrim(FwFilial("NSZ")))
		cCondNUQ+="     AND UPPER(NUQ_FILIAL) IN ("+ALLTRIM(cFiliais)+")"
	EndIf
	cCondNUQ+="AND NUQ.D_E_L_E_T_ = ' ' "

	cCondNT9:="AND EXISTS(SELECT NT9_CAJURI FROM "+RetSqlName("NT9")+" NT9 WHERE 1 = 1 "
	cCondNT9+="AND NSZ_COD = NT9_CAJURI "
	If !JurAuto() .Or. Empty(Alltrim(FwFilial("NSZ")))
		cCondNT9+="     AND UPPER(NT9_FILIAL) IN ("+ALLTRIM(cFiliais)+")"
	EndIf
	cCondNT9+="AND NT9.D_E_L_E_T_ = ' ' "

	cQryVinc:=" SELECT NSZ_COD, NUQ_NUMPRO, NT9AUT.NT9_NOME AUTOR, NT9REU.NT9_NOME REU, NQU_DESC, NSZ_NUMCAS, NUQ_FILIAL  "
	cQryVinc+="FROM "+RetSqlName("NSZ")+" NSZ "
	cQryVinc+="LEFT JOIN "+RetSqlName("NT9")+" NT9AUT "
	cQryVinc+="ON NSZ_COD = NT9AUT.NT9_CAJURI "
	cQryVinc+="AND NT9AUT.NT9_PRINCI  = '1' "
	cQryVinc+="AND NT9AUT.NT9_TIPOEN  = '1' "
	cQryVinc+="     AND UPPER(NT9AUT.NT9_FILIAL) = UPPER(NSZ_FILIAL)"
	cQryVinc+="AND NT9AUT.D_E_L_E_T_  = ' ' "

	cQryVinc+="LEFT JOIN "+RetSqlName("NT9")+" NT9REU "
	cQryVinc+="ON NSZ_COD  = NT9REU.NT9_CAJURI "
	cQryVinc+="AND NT9REU.NT9_PRINCI  = '1' "
	cQryVinc+="AND NT9REU.NT9_TIPOEN  = '2' "
	cQryVinc+="     AND UPPER(NT9REU.NT9_FILIAL) = UPPER(NSZ_FILIAL)"
	cQryVinc+="AND NT9REU.D_E_L_E_T_  = ' ' "

	cQryVinc+="LEFT JOIN "+RetSqlName("NUQ")+" NUQ "
	cQryVinc+="ON NUQ_CAJURI = NSZ_COD "
	cQryVinc+="AND NUQ_INSATU = '1' "
	cQryVinc+="     AND UPPER(NUQ_FILIAL) = UPPER(NSZ_FILIAL)"
	cQryVinc+="AND NUQ.D_E_L_E_T_ = ' ' "

	cQryVinc+="LEFT JOIN "+RetSqlName("NQU")+" NQU "
	cQryVinc+="ON NQU.NQU_COD = NUQ.NUQ_CTIPAC "
	cQryVinc+="     AND UPPER(NQU.NQU_FILIAL) = UPPER(NSZ_FILIAL)"
	cQryVinc+="AND NQU.D_E_L_E_T_ = ' ' "

	cQryVinc+="WHERE NSZ.D_E_L_E_T_ = ' ' "
	// Exclui um processo específico da consulta
	If !Empty(cExclui)
		cQryVinc+= " AND NSZ.NSZ_COD <> '"+cExclui+"' "
	EndIf

	If !JurAuto() .Or. Empty(Alltrim(FwFilial("NSZ")))
		cQryVinc+="     AND UPPER(NSZ.NSZ_FILIAL) IN ("+ALLTRIM(cFiliais)+")"
	EndIf

	If !Empty(cClient)
		cQryVinc+=" AND NSZ.NSZ_CCLIEN = '"+ALLTRIM(cClient)+"' "
	Endif

	If !Empty(cLoja)
		cQryVinc+=" AND NSZ.NSZ_LCLIEN  = '"+ALLTRIM(cLoja)+"'"
	Endif

	If !Empty(cCaso)
		cQryVinc+=" AND NSZ.NSZ_NUMCAS = '"+ALLTRIM(cCaso)+"' "
	Endif

	If !Empty((aCodDup)) .And. cDetail == 'NR0DETAIL2'
		If Len(aCodDup) > 0
			For nI := 1 To Len(aCodDup)
				If nI == 1
					cQryVinc += " AND ( (NSZ.NSZ_COD = '"+ALLTRIM(aCodDup[nI][1])+"' AND NSZ.NSZ_FILIAL = '"+ALLTRIM(aCodDup[nI][3])+"' )"
				Else
					cQryVinc += " OR (NSZ.NSZ_COD = '"+ALLTRIM(aCodDup[nI][1])+"' AND NSZ.NSZ_FILIAL = '"+ALLTRIM(aCodDup[nI][3])+"')"
				EndIf
			Next
			cQryVinc+= ')'
		EndIf
	EndIf

	If !Empty(Alltrim(cCajurP)) .And. cDetail == 'NR0DETAIL6'
		aCajurP := STRTOKARR(cCajurP, ",")
		If Len(aCajurP) > 0
			For nI := 1 To Len(aCajurP)
				If nI == 1
					cQryVinc += " AND (NSZ.NSZ_COD = '"+ALLTRIM(aCajurP[nI])+"' "
				Else
					cQryVinc += " OR NSZ.NSZ_COD = '"+ALLTRIM(aCajurP[nI])+"' "
				EndIf
			Next
			cQryVinc+= ')'
		EndIf
	EndIf

	If !Empty(cProces)
		cQryVinc+= cCondNUQ +"AND (UPPER(NUQ.NUQ_NUMPRO) LIKE UPPER ('%"+ALLTRIM(cProces)+"%') "
		cQryVinc+= " OR UPPER(NUQ.NUQ_NUMANT) LIKE UPPER ('%"+ALLTRIM(cProces)+"%')) "
		lExistNUQ := .T.
	Endif

	If !Empty(cTpAcao)
		if lExistNUQ
			cQryVinc+=" AND NUQ.NUQ_CTIPAC = '"+ALLTRIM(cTpAcao)+"' "
		Else
			cQryVinc+= cCondNUQ + " AND NUQ.NUQ_CTIPAC = '"+ALLTRIM(cTpAcao)+"' "
			lExistNUQ := .T.
		Endif
	Endif

	If !Empty(cComarca)
		if lExistNUQ
			cQryVinc+=" AND NUQ.NUQ_CCOMAR = '"+ALLTRIM(cComarca)+"' "
		Else
			cQryVinc+= cCondNUQ + " AND NUQ.NUQ_CCOMAR = '"+ALLTRIM(cComarca)+"' "
			lExistNUQ := .T.
		Endif
	Endif

	If !Empty(cForo)
		if lExistNUQ
			cQryVinc+=" AND NUQ.NUQ_CLOC2N = '"+ALLTRIM(cForo)+"' "
		Else
			cQryVinc+= cCondNUQ + " AND NUQ.NUQ_CLOC2N = '"+ALLTRIM(cForo)+"' "
			lExistNUQ := .T.
		Endif
	Endif

	If !Empty(cVara)
		if lExistNUQ
			cQryVinc+=" AND NUQ.NUQ_CLOC3N = '"+ALLTRIM(cVara)+"' "
		Else
			cQryVinc+= cCondNUQ + " AND NUQ.NUQ_CLOC3N = '"+ALLTRIM(cVara)+"' "
			lExistNUQ := .T.
		Endif
	Endif

	if lExistNUQ
		cQryVinc+= ')'
	Endif

	If !Empty(cAutor)
		cQryVinc+= cCondNT9 +	"AND UPPER(NT9AUT.NT9_NOME) LIKE UPPER('%"+ALLTRIM(cAutor)+"%') "
		lExistNT9 := .T.
	Endif

	If !Empty(cReu)
		if lExistNT9
			cQryVinc+=" AND UPPER(NT9REU.NT9_NOME) LIKE UPPER('%"+ALLTRIM(cReu)+"%') "
		Else
			cQryVinc+= cCondNT9 + " AND UPPER(NT9REU.NT9_NOME) LIKE UPPER('%"+ALLTRIM(cReu)+"%') "
			lExistNT9 := .T.
		Endif
	Endif

	if lExistNT9
		cQryVinc+= ')'
	Endif


	cQryVinc+=" ORDER BY NSZ_COD"

	cQryVinc := ChangeQuery(cQryVinc)
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQryVinc), cTabTemp, .F., .T.)

	aVetor:= {}

	If !(cTabTemp)->( Eof() )

		Do While !(cTabTemp)->( Eof() )

			cCodNsz := Upper( (cTabTemp)->NSZ_COD)
			cDesNQU := Upper( (cTabTemp)->NQU_DESC)
			cNomST9 := Upper( (cTabTemp)->REU)
			cNomSA1 := Upper( (cTabTemp)->AUTOR)
			cNumPro := (cTabTemp)->NUQ_NUMPRO
			cNomST9 := Substr(cNomST9, 1, Len(cNomST9)-1)

			Aadd(aArray, {.F., cNumPro, cCodNsz, cNomSA1, cNomST9, cDesNQU, (cTabTemp)->NUQ_FILIAL} )
			Aadd(aText , Upper(cTxtPub) )

			(cTabTemp)->( DbSkip() )
		End
	Else

		Aadd(aArray, {.F., "", "", "", "", ""} )
		Aadd(aText, "")
		ApMsgInfo(STR0207)	//"Nenhum registro encontrado"
	Endif

	oLbx:aArray := {}
	oLbx:aArray := aArray
	aVetor		:= aArray

	aSize(aFiliais, 0)

	(cTabTemp)->( DbCloseArea() )
	RestArea(aArea)

Return aText

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcJur020
Importação e refresh de importações

@param  cOpc: 1 = Faz Importação,
              2 = Processa registros do arquivo indicado,
              3 = Processa registros de todos os arquivos
@param  oModel  Modelo de dados de importação de documentos
@param  oView   View de dados de importação de documentos
@param  lConc   Indica se é conciliação

@author Jorge Luis Branco Martins Junior
@since 06/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcJur020(cOpc, oModel, oView, lConc)
Local nQtdImp    := 0
Local cTipo      := ""
Local cNomArq    := ""
Local cCodImp    := ""
Local cSituac    := ""
Local cCtrlInst  := ""
Local cProcErro  := "" //Armazena o nº dos processos localizados sem Instância Atual
Local aInfXml    := {}
Local aPalChv    := {}
Local aCtrl      := {}
Local aDup       := {}
Local aRetDup    := {}
Local lOk        := .F.
Local lImpAnt    := .F.
Local lInstAtua  := .F. //Confirma se há cadastro de Instância Atual
Local lCtrlAtu   := .T. //Controle de Refresh na tela
Local lExibChv   := .F.
Local lSuces     := .F.
Local dDtIni     := IIF(!lXml, MV_PAR01, CToD( '  /  /  '  ))
Local dDtFim     := IIF(!lXml, MV_PAR02, CToD( '  /  /  '  ))
Local cLocaliz   := AllTrim(oModel:GetValue("NR0MASTER","NR0__PCAM"))
Local cPalChv    := ""
Local cCodDoc    := IIF(lXml, MV_PAR02, "") //passo2
Local cDetail    := J20GetModel(oView:GetFolderActive('FOLDER_01',2)[1])
Local nSaveSX8   := GetSX8Len()		// Número gerado para identificação do registro
Local nCt        := 0
Local dDtVerif   := CToD( '  /  /  '  )
Local lPubCheg   := J020VldPar('MV_PAR10')
Local lOcultNLoc := J020VldPar('MV_PAR08')

Default cOpc     := "3"
Default lConc    := .F.

	ProcRegua(0)
	IncProc()

	If lXml
		cPalChv := JurGetDados("NS8",1,XFILIAL("NS8")+MV_PAR02, "NS8_DESCHV")
	Else
		cPalChv := JurGetDados("NS8",1,XFILIAL("NS8")+MV_PAR03, "NS8_DESCHV")
	EndIf

	lExibChv   := !Empty(AllTrim(cPalChv))

	DbSelectArea("NS8")
	NS8->( DbSetOrder(2) )	//NS8_FILIAL+NS8_DESCHV
	NS8->( DbGoTop() )
	Do While !NS8->( Eof() )
		Aadd(aPalChv, Alltrim(UPPER(NS8->NS8_DESCHV)))
		NS8->( DbSkip() )
	End

	If lXml
		cTipo := SubStr(oModel:GetValue("NR0MASTER","NR0__TPARQ"),1,1)
	EndIf

	//===========================================
	//Gerando informacoes referente a publicacoes
	//===========================================
	aCtrl   := {}  //Controle do NQZ_COD já inserido
	cCodImp := ""
	cSituac := ""
	lImpAnt := .F. //Importação Antiga?

	If cOpc == "1" .And. !Empty(cLocaliz)

		If File(cLocaliz)
			//==========================================
			//Arquivo Importado efetuada via XML ou TXT
			//==========================================
			cNomArq := cLocaliz

			Do While (AT("\" ,UPPER(cNomArq))>0)
				cNomArq := Substr(cNomArq,AT("\" ,UPPER(cNomArq))+1,Len(cNomArq))
			End

			If "XML" $ UPPER(cNomArq) .Or. "TXT" $ UPPER(cNomArq)

				DbSelectArea("NQZ")
				NQZ->( DbSetOrder(2) )		//NQZ_FILIAL+NQZ_COD
				If NQZ->(DbSeek(xFilial("NQZ") + AVKEY(Alltrim(cTipo), "NQZ_TIPARQ") + AVKEY(UPPER(cNomArq),"NQZ_NOMARQ")))
					If !Empty(cCodDoc)
						Aviso(STR0050 + Dtoc(NQZ->NQZ_DTIMPO) , STR0047 + " " + Alltrim(NQZ->NQZ_NOMARQ) + " " + STR0051, {"Ok"} )//"Data da Importacao:"#"Arquivo"#"importado anteriormente."

						lImpAnt := .T.
						cCodDoc := NQZ->NQZ_COD
						cNomArq := NQZ->NQZ_NOMARQ
						cNomDoc := UPPER(cNomArq)

					Endif
				Else

					Begin Transaction

						//Processando o arquivo XML ou TXT
						Processa( {||aInfXml := RunCont(cLocaliz,cTipo, @lSuces) })

						If Len(aInfXml) > 0

							//Gravando Importacoes Publicacoes
							cCodImp	 := GETSX8Num("NQZ","NQZ_COD")
							DbSelectArea("NQZ")
							RecLock("NQZ", .T.)
								NQZ->NQZ_FILIAL := xFilial("NQZ")
								NQZ->NQZ_COD    := cCodImp
								NQZ->NQZ_NOMARQ := UPPER(cNomArq)
								NQZ->NQZ_TIPARQ := Alltrim(cTipo)
								NQZ->NQZ_DTIMPO := dDataBase
								NQZ->NQZ_USRIMP := __cUserId
							NQZ->( MsUnlock() )

							//<-  O sistema confirmara somente os codigos da Sx8 abertos entre o inicio da
							//<-  função até o momento do Confirm. ->
							While ( GetSX8Len() > nSaveSx8 )
								ConfirmSx8()
							End

							cCodDoc  := cCodImp
							MV_PAR02 := cCodDoc		//Atualixza codigo de documento importado, para sre utilizado nos filtros
							cNomDoc  := UPPER(cNomArq)
						Endif

					End Transaction
				Endif

			Endif
		Else
			MsgAlert(STR0052,STR0053)//"Arquivo nao encontrado"#"Verifique"
		Endif

	ElseIf cOpc == "2" .And. !Empty(cCodDoc)//Arquivo Importado Anteriormente

		DbSelectArea("NQZ")
		NQZ->( DbSetOrder(1) )	//NQZ_FILIAL+NQZ_COD

		If NQZ->( DBSEEK(XFILIAL("NQZ") + AVKey(cCodDoc,"NQZ_COD")) )
			cTipo := NQZ->NQZ_TIPARQ

			DbSelectArea("NR0")
			NR0->( DbSetOrder(2) )	//NR0_FILIAL+NR0_CODIMP+NR0_CAJURI+NR0_NUMPRO

			If NR0->(DbSeek(xFilial("NR0") + NQZ->NQZ_COD))
				Do While NR0->(!Eof()) .AND. NR0->NR0_CODIMP == NQZ->NQZ_COD

					If lPubCheg //Filtro por data da publicação
						dDtVerif := NR0->NR0_DTCHEG
					Else//Filtro por data de chegada
						dDtVerif := NR0->NR0_DTPUBL
					EndIf

					If dDtVerif >= dDtIni .And. Iif( !Empty(dDtFim), dDtVerif <= dDtFim, .T.) ;
						.And. Iif(lExibChv,UPPER(ALLTRIM(JurLmpCpo(cPalChv))) $ UPPER(JurLmpCpo(NR0->NR0_TEORPB)),.T.)

						Aadd(aInfXml, { NR0->NR0_CAJURI,;   //1
										NR0->NR0_DTPUBL,;   //2
										" ",;               //3
										NR0->NR0_NUMPRO,;   //4
										NR0->NR0_TEORPB,;   //5
										NR0->NR0_SITUAC,;   //6
										NR0->NR0_CODIMP,;   //7
										NR0->NR0_DTEXCL,;   //8
										NR0->NR0_USREXC,;   //9
										NR0->NR0_CODREL,;   //10
										NR0->NR0_NOME,;     //11
										NR0->NR0_PAGINA,;   //12
										NR0->NR0_JORNAL,;   //13
										NR0->NR0_OBS,;      //14
										NR0->NR0_ORGAO,;    //15
										NR0->NR0_CIDADE,;   //16
										NR0->NR0_VARA,;     //17
										NR0->NR0_CODSEQ } ) //18
					Endif
					NR0->(DbSkip())
				End
			Endif
		Endif

	ElseIf cOpc == "3"

		IncProc(STR0187) //"Carregando informações das publicações não localizadas"

		If !lOcultNLoc .And. (lXml .Or. lXmlWS)

			For nCt := 1 to oModel:GetModel("NR0DETAIL3"):GetQtdLine()
				Aadd(aInfXml, { oModel:GetModel("NR0DETAIL3"):GetValue("NR0_CAJURI",nCt),;   //1
								oModel:GetModel("NR0DETAIL3"):GetValue("NR0_DTPUBL",nCt),;   //2
								" ",;                                                        //3
								oModel:GetModel("NR0DETAIL3"):GetValue("NR0_NUMPRO",nCt),;   //4
								oModel:GetModel("NR0DETAIL3"):GetValue("NR0_TEORPB",nCt),;   //5
								oModel:GetModel("NR0DETAIL3"):GetValue("NR0_SITUAC",nCt),;   //6
								oModel:GetModel("NR0DETAIL3"):GetValue("NR0_CODIMP",nCt),;   //7
								oModel:GetModel("NR0DETAIL3"):GetValue("NR0_DTEXCL",nCt),;   //8
								oModel:GetModel("NR0DETAIL3"):GetValue("NR0_USREXC",nCt),;   //9
								oModel:GetModel("NR0DETAIL3"):GetValue("NR0_CODREL",nCt),;   //10
								oModel:GetModel("NR0DETAIL3"):GetValue("NR0_NOME",nCt),;     //11
								oModel:GetModel("NR0DETAIL3"):GetValue("NR0_PAGINA",nCt),;   //12
								oModel:GetModel("NR0DETAIL3"):GetValue("NR0_JORNAL",nCt),;   //13
								oModel:GetModel("NR0DETAIL3"):GetValue("NR0_OBS",nCt),;      //14
								oModel:GetModel("NR0DETAIL3"):GetValue("NR0_ORGAO",nCt),;    //15
								oModel:GetModel("NR0DETAIL3"):GetValue("NR0_CIDADE",nCt),;   //16
								oModel:GetModel("NR0DETAIL3"):GetValue("NR0_VARA",nCt),;     //17
								oModel:GetModel("NR0DETAIL3"):GetValue("NR0_CODSEQ",nCt) } ) //18
			Next
		EndIf
	Endif

	//===========================================
	//Processando informacoes para alimentar a tela
	//===========================================
	nQtdImp        := 0
	lCtrlAtu       := .T.  //controle de Refresh na tela
	lInstAtua      := .F.  //confirma se há cadastro de Instância Atual
	cCtrlInst      := ""
	cProcErro      := "" //Armazena o nº dos processos localizados sem Instância Atual

	If Len(aInfXml) > 0
		IncProc(STR0188) //"Processando as publicações não localizadas"
		nQtdImp := Processa({|| J20ProcXML(aInfXml,aPalChv,cOpc,cCodImp,,,lConc)})
		aSize(aInfXml,0)

	ElseIf cOpc == "1" .And. !Empty(cNomArq) .And. !lImpAnt
		MsgAlert(STR0054,STR0053)//"Arquivo nao compativel com o Tipo de Arquivo XML"#"Verifique"
		lCtrlAtu := .F. //Não faz Refresh
	EndIf

	If lCtrlAtu
		If cOpc == "1" .And. !Empty(cProcErro)
			JurMsgErro(STR0094 + CRLF + STR0095 + CRLF + cProcErro)//"Importação realiza, mas não foi identificado a Instância Atual nos processo(s) abaixo,"
		Endif

		IncProc(STR0186) //"Atualizando as informações da tela"

		If oModel:VldData()
			oModel:Deactivate()
			dbSelectArea( 'NR0' )
			oModel:Activate()
			oView:Refresh()
			TeorRefresh(,oView, , cDetail)
		Endif
	Endif

	If lSuces .And. lOk .And. lCtrlAtu
		MsgAlert(STR0155) //" Arquivo importado com sucesso! "
	Endif

	aSize(aInfXml, 0)
	aSize(aPalChv, 0)
	aSize(aCtrl  , 0)
	aSize(aDup   , 0)
	aSize(aRetDup, 0)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} RunCont
Montagem da informacao via arquivo

@param  cLocaliz  Caminho do arquivo XML
@param  cTipo     1 = Procergs;
2 = Da-Justi;
3 = Destaque

@Return aDadXml	 	Array com Publicações

@author Jorge Luis Branco Martins Junior
@since 07/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RunCont(cLocaliz,cTipo, lSuces)
	Local cError   := ""
	Local cWarning := ""
	Local oXml     := NIL
	Local aDadXml  := {}

	// Tratativa para leitura de arquivo local ( temporário no servidor rootpath\spool )
	oXml:= XmlParserFile( cLocaliz, "_", @cError, @cWarning )

	If  oXml <> Nil .And. Empty(cError) .And. Empty(cWarning)

		If cTipo == '1' //Procergs
			aDadXml := JA020Proce(oXml, cLocaliz)
		ElseIf cTipo == '2' //Da-Justi
			aDadXml := JA020DaJus(oXML, cLocaliz)
		Elseif cTipo == '3' //Destaque
			aDadXml := JA020Desta(oXml, cLocaliz)
		EndIF

		lSuces:= .T.
	Else
		// "Erro ao abrir o arquivo XML"
		JurMsgErro(STR0096)
		lSuces:= .F.
	EndIf

	IF Substr(cLocaliz,1,1) != '\' .aND. FERASE(cLocaliz) == -1           //Apaga arquivo após utilização do arquivo temporário.
		JurMsgErro(STR0181+ " "+ cLocaliz + " " + STR(FERROR()))
		Return NIL
	Endif

Return aDadXml

//-------------------------------------------------------------------
/*/{Protheus.doc} JA020Proce(oXml, cLocaliz)
Retorna os dados contidos no XML com a formatação da Procergs

@param  oXML	  Objeto com dados do XML indicado no caminho(cLocaliz)
@param  cLocaliz  Caminho do arquivo XML

@Return aDadXml	  Comando para filtro

@sample JA020Proce(oXml)

@author Clóvis Eduardo Teixeira
@since 28/11/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA020Proce(oXml, cLocaliz)
	Local cBuffer   := ''
	Local cData     := ''
	Local cProcesso := ''
	Local cTexto    := ''
	Local cCodigo   := ''
	Local cXML      := ''
	Local dData     := cToD("//")
	Local lAbre     := .T.
	Local nCont     := 0
	Local nI        := 0
	Local aDadXml   := {}

	If oGrid <> Nil
		oGrid:SetIncMeter(1)
	Endif

	FT_FUSE(cLocaliz) //ABRIR
	FT_FGOTOP()       //PONTO NO TOPO
	cXML := FT_FREADLN()
	ProcRegua(FT_FLASTREC()) //QTOS REGISTROS LER

	if AT("00#",UPPER(Alltrim(cXML))) > 0

		While !FT_FEOF() //FACA ENQUANTO NAO FOR FIM DE ARQUIVO
			IncProc(nI++)
			// Capturar dados
			cBuffer := FT_FREADLN() //LENDO LINHA

			//**************************************************************************************
			//1-PROCERGS
			//======================================================================================
			If SubStr(Alltrim(cBuffer),1,2)=="05"
				lAbre:=.T.
			ElseIf lAbre .And. SubStr(Alltrim(cBuffer),1,2)=="15"
				cData:=Substr(cBuffer,AT("#" ,UPPER(cBuffer))+1,8)
				If At("/",cData)>0//Formato:31/12/09
					dData:=CtoD(cData)
				Else//Formato:20091231
					dData:=StoD(cData)
				Endif
			ElseIf lAbre .And. SubStr(Alltrim(cBuffer),1,2)=="35"
				For nCont:=1 To 2
					cBuffer:=Substr(cbuffer,AT("#" ,UPPER(cBuffer))+1,Len(cBuffer)-AT("#" ,UPPER(cBuffer)))
				Next
				cProcesso:=substr(cbuffer,1,AT("#" ,UPPER(cBuffer))-1)
			ElseIf lAbre .And. SubStr(Alltrim(cBuffer),1,2)$"20/40/45/50"
				If SubStr(Alltrim(cBuffer),1,2)=="20"
					cTexto += STR0150 // "ABERTURA DA NOTA: "
					For nCont:=3 To Len(cBuffer)
						IF Substr(cBuffer,nCont,1)=="#"
							cTexto+=Space(1)
						Else
							cTexto+=Substr(cBuffer,nCont,1)
						Endif
					Next
					cTexto+=+CHR(13)+CHR(10)
				ElseIf SubStr(Alltrim(cBuffer),1,2)=="40"
					cTexto += STR0151 // "ADVOGADOS DO PROCESSO: "
					For nCont:=3 To Len(cBuffer)
						If Substr(cBuffer,nCont,1)=="#"
							cTexto+=Space(1)
						Else
							cTexto+=Substr(cBuffer,nCont,1)
						Endif
					Next
					cTexto+=CHR(13)+CHR(10)
				ElseIf SubStr(Alltrim(cBuffer),1,2)=="45"
					cTexto += STR0152 // "PARTES DO PROCESSO: "
					For nCont:=3 To Len(cBuffer)
						If Substr(cBuffer,nCont,1)=="#"
							cTexto+=Space(1)
						Else
							cTexto+=Substr(cBuffer,nCont,1)
						Endif
					Next
					cTexto+=CHR(13)+CHR(10)
					cTexto += STR0153 // "DESCRICAO: "
					cTexto+=CHR(13)+CHR(10)
				Else
					If Alltrim(cBuffer)=="50#"
						lAbre:=.F.
						Aadd(aDadXml,{Alltrim(cCodigo),dData,"",cProcesso,cTexto," "," ",""," ","","","","","","","",""})
						cCodigo 	:= ""
						cData   	:= ""
						dData		:=ctod("//")
						cProcesso 	:= ""
						cTexto  	:= ""
					Else
						For nCont:=3 To Len(cBuffer)
							If Substr(cBuffer,nCont,1)=="#"
								cTexto+=Space(1)
							Else
								cTexto+=Substr(cBuffer,nCont,1)
							Endif
						Next
						cTexto+=CHR(13)+CHR(10)
					Endif
				Endif
			Endif

			FT_FSKIP() //próximo registro no arquivo xml
		EndDo
		FT_FUSE()
	Endif

Return aDadXml

//-------------------------------------------------------------------
/*/{Protheus.doc} JA020DaJus(oXml, cLocaliz)
Retorna os dados contidos no XML com a formatação da Da-Justi

@param oXML	 	    Objeto com dados do XML indicado no caminho(cLocaliz)
@param  cLocaliz  Caminho do arquivo XML

@Return aDadXml	 	Array com Publicações

@sample JA020DaJus(oXml)
@author Clóvis Eduardo Teixeira
@since 28/11/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA020DaJus(oXml, cLocaliz)
	Local cDiario   := ''
	Local cXML      := ''
	Local aDadXml   := {}
	Local nI

	cXML := MEMOREAD(cLocaliz) 

	if AT("<ROOT>",UPPER(Alltrim(cXML))) > 0

		//<-1 Elemento igual a Object ->
		IF ValType( oXml:_ROOT:_ROW ) == "O"

			//Insere no array
			Aadd(aDadXml,;
			{ Alltrim(oXML:_ROOT:_ROW:_CODIGO:TEXT),;
			DateFormat( oXML:_ROOT:_ROW:_DATA:TEXT),;
			" " ,;
			oXML:_ROOT:_ROW:_PROCESSO:TEXT,;
			oXML:_ROOT:_ROW:_TEXTO:TEXT,;
			" " ,;
			" " ,;
			CtoD("//"),;
			" ",;
			'',;
			oXML:_ROOT:_ROW:_NOME:TEXT,;
			oXML:_ROOT:_ROW:_PAGINA:TEXT, ;
			cDiario,;
			'',;
			oXML:_ROOT:_ROW:_ORGAO:TEXT,;
			oXML:_ROOT:_ROW:_CIDADE:TEXT,;
			oXML:_ROOT:_ROW:_VARA:TEXT		})

		ElseIF ValType( oXml:_ROOT:_ROW ) == "A" // 2 Elementos igual a Array

			nTotal := Len(XMLChildEx( oXml:_ROOT , '_ROW' ))

			ProcRegua(nTotal)

			If nTotal > 0
				For nI = 1 to nTotal

					IncProc(nI)

					//Insere no array
					Aadd(aDadXml,;
					{ Alltrim(oXML:_ROOT:_ROW[nI]:_CODIGO:TEXT),;
					DateFormat( oXML:_ROOT:_ROW[nI]:_DATA:TEXT) ,;
					" ",;
					oXML:_ROOT:_ROW[nI]:_PROCESSO:TEXT,;
					oXML:_ROOT:_ROW[nI]:_TEXTO:TEXT,;
					" ",;
					" ",;
					CtoD("//"),;
					" ",;
					'',;
					oXML:_ROOT:_ROW[nI]:_NOME:TEXT,;
					oXML:_ROOT:_ROW[nI]:_PAGINA:TEXT, ;
					cDiario,;
					'',;
					oXML:_ROOT:_ROW[nI]:_ORGAO:TEXT,;
					oXML:_ROOT:_ROW[nI]:_CIDADE:TEXT,;
					oXML:_ROOT:_ROW[nI]:_VARA:TEXT ;
					})
				Next
			Endif
		EndIf
	Endif

Return aDadXml

//-------------------------------------------------------------------
/*/{Protheus.doc} JA020Desta
Retorna os dados contidos no XML com a formatação da Destaque

@param oXML	 	    Objeto com dados do XML indicado no caminho(cLocaliz)
@param  cLocaliz  Caminho do arquivo XML

@Return aDadXml	 	Array com Publicações

@sample JA020Desta(oXml)
@author Clóvis Eduardo Teixeira
@since 28/11/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA020Desta(oXml, cLocaliz)
	Local cCidade   := ''
	Local cCodigo   := ''
	Local cData     := ''
	Local cNome     := ''
	Local cOrgao    := ''
	Local cPagina   := ''
	Local cProcesso := ''
	Local cTexto    := ''
	Local cVara     := ''
	Local cCodRel   := ''
	Local cDiario   := ''
	Local cObs      := ''
	Local cXML      := ''
	Local dData	    := CtoD("//")
	Local aDadXml   := {}
	Local nTotal    := 0
	Local nI

	cXML := MEMOREAD(cLocaliz)
	if AT("<PUBLICACAO>",UPPER(Alltrim(cXML))) > 0 .And. XMLChildEx(oXml, "_NEWDATASET") <> Nil

		If ValType(oXml:_NEWDATASET:_PUBLICACAO) == "A"
			nTotal:= Len(oXml:_NEWDATASET:_PUBLICACAO)

			ProcRegua(nTotal)

			For nI := 1 to nTotal
				IncProc(nI)
				cCodigo   := oXml:_NEWDATASET:_PUBLICACAO[nI]:_CODIGO:TEXT
				cData     := oXml:_NEWDATASET:_PUBLICACAO[nI]:_DATAPUBLICACAO:TEXT
				cCodRel   := oXml:_NEWDATASET:_PUBLICACAO[nI]:_CODIGORELACIONAL:TEXT
				cNome     := oXml:_NEWDATASET:_PUBLICACAO[nI]:_NOME:TEXT
				cProcesso := oXml:_NEWDATASET:_PUBLICACAO[nI]:_PROCESSO:TEXT
				cPagina   := oXml:_NEWDATASET:_PUBLICACAO[nI]:_PAGINA:TEXT
				cDiario   := oXml:_NEWDATASET:_PUBLICACAO[nI]:_DIARIO:TEXT
				cObs      := oXml:_NEWDATASET:_PUBLICACAO[nI]:_OBS:TEXT
				cTexto    := oXml:_NEWDATASET:_PUBLICACAO[nI]:_TEXTO:TEXT

				If At("/",cData)>0
					dData:= cToD(cData)
				Else
					dData:= sToD(cData)
				Endif

				Aadd(aDadXml,{Alltrim(cCodigo),dData," ",cProcesso,cTexto," "," ",CtoD("//")," ",cCodRel,cNome,cPagina,cDiario,cObs,cOrgao,cCidade,cVara})
			Next
		Else
			cCodigo   := oXml:_NEWDATASET:_PUBLICACAO:_CODIGO:TEXT
			cData     := oXml:_NEWDATASET:_PUBLICACAO:_DATAPUBLICACAO:TEXT
			cCodRel   := oXml:_NEWDATASET:_PUBLICACAO:_CODIGORELACIONAL:TEXT
			cNome     := oXml:_NEWDATASET:_PUBLICACAO:_NOME:TEXT
			cProcesso := oXml:_NEWDATASET:_PUBLICACAO:_PROCESSO:TEXT
			cPagina   := oXml:_NEWDATASET:_PUBLICACAO:_PAGINA:TEXT
			cDiario   := oXml:_NEWDATASET:_PUBLICACAO:_DIARIO:TEXT
			cObs      := oXml:_NEWDATASET:_PUBLICACAO:_OBS:TEXT
			cTexto    := oXml:_NEWDATASET:_PUBLICACAO:_TEXTO:TEXT

			If At("/",cData)>0
				dData:= cToD(cData)
			Else
				dData:= sToD(cData)
			Endif

			Aadd(aDadXml,{Alltrim(cCodigo),dData," ",cProcesso,cTexto," "," ",CtoD("//")," ",cCodRel,cNome,cPagina,cDiario,cObs,cOrgao,cCidade,cVara})
		EndIf

	Endif

Return aDadXml

//-------------------------------------------------------------------
/*/{Protheus.doc} J20MskPro
Função para alterar a mascara do numero do processo
caso exista,

@param cProcesso Indica o número do processo a ser tratado

@return cNum      Indica o número do processo já tratado

@author Rafael Rezende Costa
@since 19/11/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function J20MskPro(cProcesso)
	Local aVer    := {"ª","º",")", "(","\", "/","_","-",".","," }
	Local cSepara := ''
	Local cNum    := cProcesso
	Local nY      := 0
	Local nSepara := 0
	Local nX      := 1

	If SuperGetMV( "MV_JNUMCNJ", ,"2") == "1"

		If AT("-",cProcesso) <> 0
			cSepara := "-"
			nSepara ++
		Else
			cSepara := "."
		EndIf

		For nX:=1 To Len(cProcesso)
	  		If At(cSepara,cProcesso) <> 8
	    		cProcesso := "0" + cProcesso
	  		EndIf
	  		If Substr(cProcesso,nX,1) == "."
	  			nSepara ++
	  		EndIf
		Next

		While Len(cProcesso) < 24
	    	cProcesso := Substr(cProcesso,1,RAT(".",cProcesso))+"0" + RIGHT(cProcesso, LEN(cProcesso) - RAT(".", cProcesso))
		End
	EndIF

	If nSepara <> 4
		cProcesso := cNum
	EndIf

	For nY := 1 to LEN(aVer)
		cProcesso := STRTRAN(cProcesso, aVer[nY],'')
	Next nY

Return cProcesso

//-------------------------------------------------------------------
/*/{Protheus.doc} J20SqlNuq
Função para selecionar os registros da NUQ necessários para
analise com xml.

@param cNumProc Indica o número do processo para busca de dados

@Return aCajuri Array com os processos encontrados

@author Rafael Rezende Costa
@since 21/11/13
@version 1.0

@author Ronaldo Gonçalves de Oliveira
@since 01/10/2018
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function J20SqlNuq(cNumProc,cFiliais)
Local cSql		 := ''
Local aCajuri    := {}

Default cNumProc := ''

	cNumProc := J020LmpZer(cNumProc)

	If !EMPTY(cNumProc)
		cSql := "SELECT NUQ_CAJURI,NUQ_FILIAL"
		cSql +=  " FROM "+RetSqlName("NUQ")+" NUQ " + CRLF
		cSql += " WHERE NUQ_FILIAL IN( "+ cFiliais+")"
		cSql +=   " AND NUQ.D_E_L_E_T_ = ' ' "
		cSql +=   " AND (REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(NUQ.NUQ_NUMPRO,"+;
		                   "'-','###'),'/','###'),',','###'),'.','###'),'_','###'),'\','###'),'º','###'),'ª','###'),' ','###') LIKE '%"+ cNumProc + "%'"
		cSql +=    " OR REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(NUQ.NUQ_NUMANT,"+;
		                   "'-','###'),'/','###'),',','###'),'.','###'),'_','###'),'\','###'),'º','###'),'ª','###'),' ','###') LIKE '%"+ cNumProc + "%')"
		cSql += " GROUP BY NUQ_CAJURI, NUQ_FILIAL"

		aCajuri := JurSQL(cSQL, {"NUQ_CAJURI", "NUQ_FILIAL"}, .F., {{"###",''}})
	Endif
Return aCajuri

//-------------------------------------------------------------------
/*/{Protheus.doc} DateFormat

Função para correção da data do XML

@author Rafael Rezende Costa
@since 30/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static function DateFormat(cString)
	local aDate := {}

	aDate := StrTokArr(cString, '-')

	If Len(aDate) = 3
		cString := aDate[3] +'/' + aDate[2] + '/' + aDate[1]
	endif

Return CtoD(cString)

//-------------------------------------------------------------------
/*/{Protheus.doc} Set020lMsg
Indica se será exibida mensagem da validação da rotina de andamentos

@param lExibe Indica se será exibida mensagem de validação da rotina
de andamentos.

@author Jorge Luis Branco Martins Junior
@since 12/05/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function Set020lMsg(lExibe)
	lMsg := lExibe
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J020FilAsj
Retorna os assunto jurídicos que estão no filtro.

@param cClien Indica o cliente para filtro
@param cLoja  Indica a loja para filtro
@param cArea  Indica o área para filtro

@Return cCajuri Retorna assuntos jurídicos que foram filtrados

@author Jorge Luis Branco Martins Junior
@since 24/05/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J020FilAsj(cClien, cLoja, cArea)

	Local aArea		:= GetArea()
	Local cCajuri 	:= ""
	Local cQuery  	:= ""
	Local cAlias  	:= GetNextAlias()

	cQuery += "SELECT NSZ_COD CAJURI "
	cQuery += " FROM "+RetSqlName("NSZ")+" NSZ "
	cQuery += " WHERE NSZ.D_E_L_E_T_ = ' '"
	cQuery += "   AND NSZ_FILIAL = '"+xFilial("NSZ")+"'"
	If !Empty(Alltrim(cClien)) .And. !Empty(AllTrim(cLoja))
		cQuery += " AND NSZ.NSZ_CCLIEN = '" + cClien + "' AND NSZ.NSZ_LCLIEN = '" + cLoja + "'
	EndIf
	If !Empty(AllTrim(cArea))
		cQuery += " AND NSZ.NSZ_CAREAJ = '" + cArea + "'"
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	//Verifica se tem alguma assunto juridico com esses filtros para ai sim retornar a query da condicao
	If !(cAlias)->( EOF() )
		cCajuri := "(" + cQuery + ")"
	EndIf

	(cAlias)->( dbcloseArea() )
	RestArea( aArea )

Return cCajuri

//-------------------------------------------------------------------
/*/{Protheus.doc} J020TeorPb
Retorna uma mensagem caso a palavra não exista no cadastro e limpa o
filtro.

@Param  nMsg   1 = Irá emitir mensagem.

@Return cChave Retorna palavra-chave ou valor em branco caso não
exista palavra no cadastro.

@author Jorge Luis Branco Martins Junior
@since 30/05/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J020TeorPb(nMsg)
	Local cChave   := ""
	Local cPalavra := IIF(lXml, MV_PAR02, MV_PAR03)
	Default nMsg   := 0

	cChave := AllTrim(JurGetDados("NS8",2,XFILIAL("NS8")+cPalavra, "NS8_DESCHV"))

	If Empty(AllTrim(cChave)) .And. nMsg == 1
		MsgAlert(STR0163)//"Palavra não existe no cadastro de palavra-chave, portanto esse filtro será desconsiderado."

	EndIf


Return cChave

//-------------------------------------------------------------------
/*/{Protheus.doc} JU020CAS
Filtra a consulta padrão de caso conforme o cliente
Uso na pesquisa de processo da tela importação de publicações
@Return lRet	.T./.F. As informações são válidas ou não
@author Clóvis Eduardo Teixeira
@since 19/08/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JU020CAS()
	Local cRet := "@#@#"

	If !(Empty(cClient) .And. Empty(cLoja))
		cRet := "@#NVE->NVE_CCLIEN == '"+AllTrim(cClient)+"' .AND. NVE->NVE_LCLIEN == '"+AllTrim(cLoja)+"'@#"
	EndIF

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JU020NQC
Filtra consulta padrão de localização de 2. nivel conforme comarca
@Return cRet	 	Comando para filtro
@sample @#JURA95NQC()
@author Clóvis Eduardo Teixeira
@since 28/08/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JU020NQC()
	Local cRet := "@#@#"

	If !Empty(cComarca)
		cRet := "@#NQC->NQC_CCOMAR == '"+AllTrim(cComarca)+"'@#"
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JU020NQE
Filtra consulta padrão de localização de 3. nivel conforme localização de 2. nivel
@Return cRet	 	Comando para filtro
@sample #JURA95NQE()
@author Clóvis Eduardo Teixeira
@since 28/08/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JU020NQE()
	Local cRet := "@#@#"

	If !Empty(cForo)
		cRet := "@#NQE->NQE_CLOC2N == '"+AllTrim(cForo)+"'@#"
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J20Filtrar
Permite que o usuário escolha mais de uma palavra chave do cadastro da NS8
e permite que o usuário digite palavras separadas por vírgula (,).

@author Antonio C Ferreira
@since 09/03/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J20Filtrar(oView)

	Local aArea          := GetArea()
	Local lRet           := .F.
	Local oDlg           := Nil
	Local cTitulo        := STR0172     //"Filtro de Palavra-chave"
	Local aHeader        := {}
	Local oCheck         := LoadBitmap( GetResources(), "CHECKED" )      // Legends : CHECKED  / LBOK  /LBTIK
	Local oNoCheck       := LoadBitmap( GetResources(), "UNCHECKED" )    // Legends : UNCHECKED /LBNO
	Local oFWLayer       := nil
	Local oPnlACima      := nil
	Local oPalavraChaves := nil
	Local cCodPalavra    := Lower(JurLmpCpo(If(lXml, Alltrim(MV_PAR01), "")))
	Local cChave         := ""
	Local lPalavras      := .F.
	Local oChkAnd        := Nil
	Local lFlag          :=.F.

	If  !( Empty(cCodPalavra) )
		cChave := Lower(JurLmpCpo(AllTrim(JurGetDados("NS8",1,xFilial("NS8")+cCodPalavra, "NS8_DESCHV"))))
	EndIf

	//------------------------------ aHeader ------------------------------
	aHeader  := {"", STR0157}

	//----------------------------- aPalavra -----------------------------
	DbSelectArea("NS8")
	NS8->( DbSetOrder(2) )		//NS8_FILIAL+NS8_DESCHV
	NS8->( DbGoTop() )

	aPalavras      := {}  //Variavel estatica - Zera para obter dados novos do cadastro de palavras-chaves.

	Do While !NS8->( Eof() )
		If !Empty(NS8->NS8_DESCHV)
			lFlag := !Empty(cChave) .And. (Alltrim(NS8->NS8_DESCHV) == cChave)
			Aadd(aPalavras, {lFlag, NS8->NS8_DESCHV})
			lPalavras := .T.
		EndIf

		NS8->( DbSkip() )
	EndDo

	If !lPalavras
		Aadd(aPalavras, {.F., STR0179})  //"[Nenhuma palavra chave cadastrada!]"
	EndIf

	//+-----------------------------------------------+
	//| Monta a tela para usuario visualizar consulta |
	//+-----------------------------------------------+
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 6,6 TO 500,550 PIXEL

	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlg, .F., .F.)

	// Painel Superior
	oFWLayer:AddLine('ACIMA', 50, .F.)
	oFWLayer:AddCollumn('ALL', 100, .T., 'ACIMA')
	oPnlACima := oFWLayer:GetColPanel( 'ALL', 'ACIMA' )

	// Painel Intermediario
	oFWLayer:AddLine('MEIO', 30, .F. )
	oFWLayer:AddCollumn('ALL' , 100, .T., 'MEIO')
	oPanelMeio := oFWLayer:GetColPanel('ALL' , 'MEIO')

	// Painel Resultado
	oFWLayer:AddLine('RESULTADO', 06, .F. )
	oFWLayer:AddCollumn('ALL' , 100, .T., 'RESULTADO')
	oPanelResultado := oFWLayer:GetColPanel('ALL' , 'RESULTADO')

	// Painel Inferior
	oFWLayer:AddLine('ABAIXO', 14, .F. )
	oFWLayer:AddCollumn('ALL' , 100, .T., 'ABAIXO')
	oPanelABaixo := oFWLayer:GetColPanel('ALL' , 'ABAIXO')

	//------------------------- ACima -------------------------------------------------------------------------------------------------

	@ 005,005 Say STR0173 Size 200,008 Color CLR_BLUE PIXEL OF oPnlACima   //"DOIS CLIQUES PARA SELECIONAR A PALAVRA-CHAVE:"
	//@ 004,220 Button "Cadastrar"      Size 037,008 	PIXEL OF oPnlACima ACTION ({JCall182(oView),Self:Refresh()}  )  //"Cadastrar Palavra Chave"
	oListBox1 := TwBrowse():New(015,3,Int(oPnlACima:nWidth/2.05),Int(oPnlACima:nHeight/2.4),,aHeader,,oPnlACima,,,,,,,,,,,,.T.,,.T.,,.F.,,,)
	oListBox1:SetArray( aPalavras )
	oListBox1:bLine := {|| {If(aPalavras[oListBox1:nAt,1], oCheck , oNoCheck ), aPalavras[oListBox1:nAt,2]}}
	If  lPalavras
		oListBox1:BLDblClick := {|| aPalavras[ oListBox1:nAt , 1 ] := !aPalavras[ oListBox1:nAt , 1 ] , oListBox1:Refresh()}
	EndIf

	//------------------------- Meio -------------------------------------------------------------------------------------------------------

	@ 005,005 Say STR0174 Size 200,008 Color CLR_BLUE PIXEL OF oPanelMeio    //"DIGITE AS PALAVRAS-CHAVES SEPARADAS POR VÍRGULA:"
	@ 015,003 Get oPalavraChaves Var cPalavraChaves Memo Size Int(oPanelMeio:nWidth/2.05),015 Pixel Of oPanelMeio

	oChkAnd := TCheckBox():New(40,05,STR0191,{|u|if( pcount()>0,lChkAnd := !u, !lChkAnd)},oPanelMeio,300,210,,,,,,,,.T.,,,) // "Utilizar operador de agrupamento <OU> ?"

	//------------------------- Resultado --------------------------------------------------------------------------------------------------

	@ 005,005 Say STR0175 Size 080,008 Color CLR_BLUE PIXEL OF oPanelResultado   //"Resultado do teste de filtragem:"
	@ 005,083 Say oSay Prompt Space(10) Size 080,008 Color CLR_RED  PIXEL OF oPanelResultado

	//------------------------- ABaixo -----------------------------------------------------------------------------------------------------

	@ 005,120 Button STR0176      Size 037,012 	PIXEL OF oPanelABaixo ACTION ( Processa({|| J20TstFiltro(aPalavras, Lower(JurLmpCpo(cPalavraChaves)), @oDlg, @oSay)}, STR0157, STR0211) )  //"Testar"	//"Palavra-Chave"	//"Contando publicações..."
	@ 005,170 Button STR0177      Size 037,012 	PIXEL OF oPanelABaixo ACTION ( Processa({|| J20PlvChFiltro(oView, Lower(JurLmpCpo(cChave))), oDlg:End()}			, STR0157, STR0212) )  //"Filtrar"	//"Palavra-Chave"	//"Aplicando filtro..."
	@ 005,220 Button STR0178      Size 037,012 	PIXEL OF oPanelABaixo ACTION oDlg:End()  //"Cancelar"

	ACTIVATE MSDIALOG oDlg CENTER

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J20TstFiltro
Verifica a quantidade de registros filtrados atraves das palavras chaves
escolhidas e digitadas pelo usuário.

@author Antonio C Ferreira
@since 10/03/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J20TstFiltro(aPalavras, cPalavraChaves, oDlg, oSay)

	Local aArea      := GetArea()
	Local cCodDoc    := If(lXml, MV_PAR02, "")
	Local cLikeSQL   := J20LikeSQL(aPalavras, cPalavraChaves)
	Local cQuery     := "SELECT COUNT(1) AS NRegs FROM " + RetSqlName("NR0") + " WHERE D_E_L_E_T_ = ' '"
	Local cAlias     := GetNextAlias()
	Local dDtIni     := IIF(!lXml, DtoS(MV_PAR01), '' )
	Local dDtFim     := IIF(!lXml, DtoS(MV_PAR02), '' )
	Local lPubCheg   := J020VldPar('MV_PAR10')

	ProcRegua(0)
	IncProc()
	IncProc()

	Begin Sequence

		If Empty(cLikeSQL)
			MsgAlert(STR0182) //"Nenhuma palavra-chave selecionada ou digitada!"
			Break
		EndIf

		If !( Empty(cCodDoc) )
			cQuery += " AND NR0_CODIMP = " + ValToSQL(cCodDoc)
		EndIf

		Do Case
			Case lXml
				cQuery += " AND ( NR0_SITUAC = '1' OR NR0_SITUAC = '2' OR NR0_SITUAC = '3' OR NR0_SITUAC = '4' OR NR0_SITUAC = '5' )"
			Case !lXml .and. !lXmlWS
				cQuery += " AND ( NR0_SITUAC = '1' OR NR0_SITUAC = '4' OR NR0_SITUAC = '5' OR NR0_SITUAC = '6' )"
			Case !lXml .and. lXmlWS
				cQuery += " AND ( NR0_SITUAC = '1' OR NR0_SITUAC = '2' OR NR0_SITUAC = '3' OR NR0_SITUAC = '4' OR NR0_SITUAC = '5' )"
		EndCase

		If !lXml .And. !( Empty(cQuery) )
			If lPubCheg //Filtro por data da publicação
				cQuery += " AND NR0_DTCHEG >= '" + dDtIni + "' AND NR0_DTCHEG <= '" + dDtFim + "'"
			Else//Filtro por data de chegada
				cQuery += " AND NR0_DTPUBL >= '" + dDtIni + "' AND NR0_DTPUBL <= '" + dDtFim + "'"
			EndIF
		EndIf

		//Adiciona filtros de palavra-chave
		If !Empty(cLikeSQL)
			cQuery += " AND " + cLikeSQL
		EndIf

		cQuery := ChangeQuery(cQuery)
		cQuery := StrTran(cQuery,",' '",",''")
		cQuery := StrTran(cQuery,", ' '",",''")

		dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQuery ) , cAlias, .T., .F.)

			oSay:cCaption := cValToChar( (cAlias)->NRegs )

		(cAlias)->(dbCloseArea())

		oDlg:Refresh()

		MsgAlert(STR0171 + oSay:cCaption) //"Total de registros filtrados: "

	End Sequence

	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J20LikeSQL
Separa as palavras chaves e monta a condicao SQL com like de cada palavra.

@author Antonio C Ferreira
@since 10/03/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J20LikeSQL(aPalavras, cPalavraChaves, aAgrupadores)
	Local nA          := 0
	Local nB          := 0
	Local cLikeSQL    := ""
	Local aDados      := {}
	Local cCodPalavra := If(lXml, Alltrim(MV_PAR01), "")
	Local cChave      := ""
	Local cOper       := IIF(lChkAnd,' AND ', ' OR ')
	Local cLogin      := ""

	Default aAgrupadores := {}

	If JurCarEsp(cPalavraChaves,",")
		Return
		ApMsgInfo(STR0182)//"Caracteres especiais não são permitidos"
	EndIf

	If Len(aAgrupadores) == 0 .And. !lXml .And. !Empty(MV_PAR07)
		aAdd(aAgrupadores,{.T., MV_PAR07})
	EndIf

	aDados:=J20PChavToA(cPalavraChaves)

	If Len(aPalavras) == 0
		aADD(aPalavras,{.T.,JurGetDados("NS8",1,XFILIAL("NS8")+MV_PAR03, "NS8_DESCHV")})
	EndIF

	If  !( Empty(cCodPalavra) )
		cChave := Lower(JurLmpCpo((AllTrim(JurGetDados("NS8",1,xFilial("NS8")+cCodPalavra, "NS8_DESCHV")))))
	EndIf

	For nA := 1 to Len(aPalavras)
		If  aPalavras[nA][1]
			aadd(aDados, {lower(JurLmpCpo(aPalavras[nA][2])),1})
		EndIf
	Next nA

	If  !( Empty(cChave) )
		aadd(aDados, {cChave,1})
	EndIf

	If Len(aAgrupadores) > 0
		For nA := 1 to Len(aAgrupadores)
			If aAgrupadores[nA][1]
				aadd(aDados, {(aAgrupadores[nA][2]),2})
			EndIf
		Next nA
	EndIf

	For nA := 1 to Len(aDados)
		If ValType(aDados[nA]) == "C"
			If  !( Empty(aDados[nA]) )
				If Empty(cLikeSQL)
					cLikeSQL += " ( "
				Endif

				cLikeSQL += IIf(++nB > 1, cOper, '') + '(' + JA020QryFil(aDados[nA]) + " OR " + JA020QryFil(aDados[nA], "NR0_NOME") + ')' //filtra teor e nome.

			EndIf
		Else
			If  !( Empty(aDados[nA][1]) )
				If Empty(cLikeSQL)
					cLikeSQL += " ( "
				Endif

				If aDados[nA][2] == 1
					cLikeSQL += IIf(++nB > 1, cOper, '') + '(' + JA020QryFil(aDados[nA][1]) + " OR " + JA020QryFil(aDados[nA][1], "NR0_NOME") + ')' //filtra teor e nome.
				ElseIf aDados[nA][2] == 2
					If Empty(cLogin)
						cLogin := "'" + (aDados[nA][1]) + "'"
					Else
						cLogin += ", '" + (aDados[nA][1]) + "'"
					EndIf
				EndIf
			EndIf
		EndIf
	Next nA

	If !Empty(cLogin)
		If !(cLikeSQL == " ( ")
			cLikeSQL += " AND "
		EndIf
		cLikeSQL += " NR0_LOGIN IN (" + cLogin + ") "
	EndIf

	If !Empty(cLikeSQL)
		cLikeSQL += " ) "
	Endif

Return cLikeSQL

//-------------------------------------------------------------------
/*/{Protheus.doc} J20PChavToA
Separa as palavras chaves e monta a condicao SQL com like de cada palavra.

@author 02
@since 10/03/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J20PChavToA(cPChave)
	Local aRet   := {}
	Local cTrata := ''
	If !Empty(cPChave)
		cTrata := replace( cPChave , '"','' )
		cTrata := replace( cTrata , "'", "" )
		cTrata := replace( cTrata , "#", "," )
		cTrata := replace( cPChave , '.','' )
		cTrata := replace( cPChave , '-','' )
		cTrata := StrTran( cTrata , ';', ',')
		aRet   := StrToKarr(cTrata,',')
	EndIf
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J20PlvChFiltro
Executa o refresh da tela para aplicar o filtro de palavra-chave.

@author Antonio C Ferreira
@since 10/03/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J20PlvChFiltro(oView, cChaveT)

	Local nA        := 0
	Local oModel    := FWModelActive()
	Local cDetail   := J20GetModel(oView:GetFolderActive('FOLDER_01',2)[1])
	Local cChave    := Lower(JurLmpCpo(cChaveT))
	Local aDados    := J20PChavToA(cPalavraChaves)

	ProcRegua(0)
	IncProc()
	IncProc()

	For nA := 1 to Len(aDados)
		aadd(aPalavras, {.T.,aDados[nA]})
	Next nA

	If lXml
		If  !( Empty(cChave) )
			For nA := 1 to Len(aPalavras)
				If  (Alltrim(Lower(JurLmpCpo(aPalavras[nA][2]))) == cChave)
					If !aPalavras[nA][1]
						MV_PAR01 := ""  //A partir deste momento o controle sai do parametro e passa para a tela de filtragem.
					EndIf
					Exit
				EndIf
			Next nA
		EndIf
	EndIf

	oModel:Deactivate()
	dbSelectArea( 'NR0' )
	oModel:Activate()
	oView:Refresh()
	TeorRefresh(,oView, , cDetail)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JCall182
Função que chama a JURA182.

@author André Spirigoni Pinto
@since 01/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCall182(oView)
	Local cAceAnt  	:= AcBrowse
	Local cFunName 	:= FunName()
	Local oModel    := FwModelActive(,.T.)
	Local cDetail   := J20GetModel(oView:GetFolderActive('FOLDER_01',2)[1])

	// JAX/Ernani: A linha abaixo serve liberar o acesso aos botões da Browse, para não manter a regra da tela JURA100 inserida no XNU.
	AcBrowse := Replicate("x",10)
	SetFunName( 'JURA182' ) // Isto serve para o filtro de tela ter sua própia configuração na JURA182

	JURA182()

	SetFunName( cFunName )
	AcBrowse := cAceAnt

	FwModelActive(oModel)
	oModel:Deactivate()
	dbSelectArea( 'NR0' )
	oModel:Activate()
	oView:Refresh()
	TeorRefresh(,oView, , cDetail)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ExistNQZ
Função para verificar se o arquivo de XML já tenha sido carregado e importado
anteriormente.

@Return lExist 	 Retorna se o nome do arquivo já tenha sido importado
Se não encontrar o arquivo retorna falso;
caso já exista retorna true

@author Rafael Rezende Costa
@since 30/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function ExistNQZ(oModel)
	Local lExist	:= .F.
	Local cLocaliz	:= AllTrim(oModel:GetValue("NR0MASTER","NR0__PCAM"))
	Local cTipo		:= SubStr(oModel:GetValue("NR0MASTER","NR0__TPARQ"),1,1)
	Local cNomArq	:= ''

	If !Empty(cLocaliz)
		cNomArq	:= SubStr( cLocaliz, RAT( "\" , cLocaliz) +1) // Nome do arquivo

		If !EMPTY(cTipo) .AND. ( "XML" $ UPPER(cNomArq) .Or. "TXT" $ UPPER(cNomArq) )

			DbSelectArea("NQZ")
			NQZ->(DbSetOrder(2))  //NQZ_FILIAL+NQZ_COD
			If NQZ->( DbSeek( xFilial("NQZ") + AVKEY(Alltrim(cTipo), "NQZ_TIPARQ") + AVKEY(UPPER(cNomArq),"NQZ_NOMARQ")))
				lExist := .T.
			EndIf

			If lExist
				MsgAlert( STR0047 + ' '+STR0051 , STR0053)// "Arquivo" + ' ' + "Importado anteriormente."
			EndIF
		EndIF
	Elseif lXmlWS //se for Kurier, via Web Service, retorna true pois já foi importado.
		lExist := .T.
	EndIf

Return lExist

///-------------------------------------------------------------------
/*/{Protheus.doc} JVldXmlWs(lTOTVS)
Validação se o xml de publicações vem por xml

@since 07/10/2020
/*/
//-------------------------------------------------------------------
static Function JVldXmlWs()
Local lRet   := .F.
Local lTOTVS := SuperGetMV('MV_JPUBTOT',, '2') == '1' //Publicações pela Totvs\Vista

	If Empty(lXmlWS)
		lRet := lTOTVS .Or. SuperGetMV('MV_JKURXML',, '2') == '1'
	Else
		lRet := lXmlWS
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J20ProcXML
Função para verificar se o arquivo de XML já tenha sido carregado e importado
anteriormente.

@Return lExist 	 Retorna se o nome do arquivo já tenha sido importado
Se não encontrar o arquivo retorna falso;
caso já exista retorna true

@author Rafael Rezende Costa
@since 30/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J20ProcXML(aInfXml,aPalChv,cOpc,cCodImp,lTask,nSeq,lConc,aFiliais)
Local nCont      := 0
Local nChv       := 0
Local nJ         := 0
Local nQtdImp    := 0
Local cCodProc   := ""
Local cTmpCodPro := ""
Local cSituac    := ""
Local cChave     := ""
Local cCtrlInst  := ""
Local cProcNUQ   := ""
Local aUltXml    := {}
Local aCtrl      := {}
Local aDup       := {}
Local aRetDup    := {}
Local lOk        := .F.
Local lInstAtua  := .F. //Confirma se há cadastro de Instância Atual
Local lTela      := !IsBlind() //valida se existe interface aberta
Local cTmpCodFil := ''
Local cFiliais   := ''
Local cFilialPro := ''
Local aCajuri    := {}

Default aInfXml  := {}
Default aPalChv  := {}
Default cOpc 	 := "1"
Default cCodImp  := '    '
Default lTask 	 := .F. //indica se esta função está sendo executada a partir de um job
Default nSeq 	 := 0 	//indica o número que deve ser somado a nQtdImp para preencher a chave.
Default lConc 	 := .F.
Default aFiliais := JURFILUSR( __CUSERID, "NSZ" )

	lXmlWS := JVldXmlWs()
	lXML   := IIF(Empty(lXml), .F., lXml)
	
	For nCont := 1 To Len(aFiliais[3])
		cFiliais := cFiliais + "'" + aFiliais[3][nCont] + "'" + ","
	Next nCont

	if Empty(cFiliais)
		cFiliais := "'" + xFilial('NUQ') + "',"
	Endif

	cFiliais := SUBSTR(cFiliais, 1, Len(cFiliais)-1)

	if (lTela)
		ProcRegua(Len(aInfXml))
	Endif

	For nCont := 1 To Len(aInfXml)
		nQtdImp := nQtdImp + 1

		//===========================================
		//verificando se o arquivo texto possui alguma palavra chave
		//===========================================
		lInstAtua  := .F.
		cCtrlInst  := ""
		cChave     := ""
		cCodProc   := ""
		cSituac    := ""
		cProcNUQ   := ""
		cTmpCodPro := ""

		If Len(aPalChv) > 0
			For nChv := 1 To Len(aPalChv)
				If !Empty(UPPER(aInfXml[nCont][5]))
					If aPalChv[nChv]$UPPER(aInfXml[nCont][5])
						cChave += aPalChv[nChv] + "/"
					EndIf
				EndIf
			Next nChv
		Endif

		cProcNUQ   := J20MskPro( aInfXml[nCont][4] )
		cProcNUQ   := AVKEY( cProcNUQ , "NUQ_NUMPRO" )

		If !aInfXml[nCont][6]$"1/4/5"

			aCajuri := J20SqlNuq(J20MskPro(Alltrim(aInfXml[nCont][4])),cFiliais)
			If Empty(aCajuri) .And. Len(Alltrim(aInfXml[nCont][4])) == 11 //Se não achar o processo na NUQ, procura na NSZ pelo NIRE que é composto por 11 digitos
				aCajuri := J20SqlNsz(J20MskPro(Alltrim(aInfXml[nCont][4])),cFiliais)
			EndIf

			If Len(aCajuri) == 1 // Processo Localizado
				cCodProc := Alltrim(aCajuri[1][1])
				cFilialPro := aCajuri[1][2]
				If !Empty(Alltrim(aInfXml[nCont][7])) .Or. !Empty(Alltrim(cCodImp)) .Or. lXmlWS
					cSituac := '1'
				Else
					cSituac := aInfXml[nCont][6]
				EndIf

			ElseIf Len(aCajuri) > 1 // Processo Duplicado
				For nJ := 1 to Len(aCajuri)
					If nJ == 1
						cCodProc := Alltrim(aCajuri[nJ][1])
					Else
						cCodProc += " / " + Alltrim(aCajuri[nJ][1])
					EndIf
				Next nJ

				If !Empty(Alltrim(aInfXml[nCont][7])) .Or. !Empty(Alltrim(cCodImp));
					.Or.  (lXml .Or. lXmlWS)
					cSituac := '2'
					aInfXml[nCont][6] :='2'
				Else
					//cSituac := aInfXml[nCont][6]
					cSituac := '6'
					aInfXml[nCont][6] := "6"
				EndIf
			Else // // Processo Não Localizado
					cCodProc 	:= ""
					cSituac		:= "3"
			EndIf

			lOk := .T.
		Else
			DbSelectArea("NUQ")
			NUQ->(DbSetOrder(1))	//NUQ_FILIAL+NUQ_CAJURI
			If NUQ->(DbSeek(xFilial("NUQ") + AVKEY(cCodProc,"NUQ_CAJURI")))
				cSituac := '1'
			Endif

			If aInfXml[nCont][6] == "1" .and. !Empty(aInfXml[nCont][4])
				cSituac := '3'
				lOk := .T.
			ElseIf Empty(aInfXml[nCont][6]) .Or. aInfXml[nCont][6] == "3" //Pasta nao localizados
				cSituac := '3'
				lOk := .T.
			ElseIf aInfXml[nCont][6] == "4" //Pasta excluidos
				lOk := .F.
			ElseIf aInfXml[nCont][6] == "5" //Pasta Importadas
				lOk := .F.
			ElseIf aInfXml[nCont][6] == "6" //Pasta Provaveis
				cSituac := '6'
				lOk := .T.
			Endif
		Endif

		If lOk

			Begin Transaction

				//===========================================
				//Gravando informacoes da publicacoes
				//===========================================
				If cOpc == "1"//Arquivo importado(Registro Novo)
					//aInfXml[nCont][1]-Codigo do Processo(CAJURI)
					//aInfXml[nCont][6]-Situacao
					//aInfXml[nCont][7]-Codigo Importacao
					//aInfXml[nCont][8]-Data da Exclusao
					//aInfXml[nCont][9]-Usuario da Exclusao
					//aInfXml[nCont][18]-Login
					RecLock("NR0", .T.)
						NR0->NR0_CAJURI := IIF(Empty(cCodProc),cTmpCodPro,cCodProc)
						NR0->NR0_FILIAL := xFilial("NR0")
						NR0->NR0_CODIMP := cCodImp
						NR0->NR0_CAJURP := cCodProc //Relação dos CAJURIS concatenados por " / " quando a publicação for duplicada

						//valida se deve usar o controle de numeração ou sequencia do banco.
						NR0->NR0_CODSEQ := StrZero(IIF(nSeq!=0,(nQtdImp+nSeq),(val(GetSXEnum("NR0","NR0_CODSEQ")))),TamSX3('NR0_CODSEQ')[1])
						NR0->NR0_SITUAC := cSituac
						NR0->NR0_DTPUBL := aInfXml[nCont][2]   //aInfXml[nCont][2]-Data da Publicacao
						NR0->NR0_NUMPRO := aInfXml[nCont][4]   //aInfXml[nCont][4]-Numero do Processo
						NR0->NR0_TEORPB := aInfXml[nCont][5]   //aInfXml[nCont][5]-Texto
						NR0->NR0_CODREL := aInfXml[nCont][10]  //aInfXml[nCont][10]-Codigo Relacional
						NR0->NR0_NOME   := aInfXml[nCont][11]  //aInfXml[nCont][11]-Nome
						NR0->NR0_PAGINA := aInfXml[nCont][12]  //aInfXml[nCont][12]-Pagina
						NR0->NR0_JORNAL := aInfXml[nCont][13]  //aInfXml[nCont][13]-Diario
						NR0->NR0_OBS    := aInfXml[nCont][14]  //aInfXml[nCont][14]-Obs
						NR0->NR0_ORGAO  := aInfXml[nCont][15]  //aInfXml[nCont][15]-Orgao
						NR0->NR0_CIDADE := aInfXml[nCont][16]  //aInfXml[nCont][16]-Cidade
						NR0->NR0_VARA   := aInfXml[nCont][17]  //aInfXml[nCont][17]-Vara
						NR0->NR0_FILPRO := IIF(!Empty(cFilialPro),cFilialPro,cTmpCodFil)
						NR0->NR0_DTCHEG := Date()

						If (ColumnPos("NR0_LOGIN") > 0 .And. len(aInfXml[nCont]) >= 18)
							NR0->NR0_LOGIN  := aInfXml[nCont][18]
						Endif
					NR0->( MsUnlock() )

					ConfirmSX8()

					if !lTask
						MV_PAR02 := cCodImp
					Endif

				ElseIf !lConc
					DbSelectArea("NR0")
					NR0->( DbsetOrder(1) )	//NR0_FILIAL+NR0_CODIMP+NR0_CODSEQ
					If NR0->(DbSeek(xFilial("NR0") + aInfXml[nCont][7] + aInfXml[nCont][18] ))
						If NR0->NR0_SITUAC == '3' .And. cSituac == "1"
							RecLock("NR0", .F.)
								NR0->NR0_CAJURI := cCodProc
								NR0->NR0_SITUAC := cSituac
								NR0->NR0_FILPRO := IIF(!Empty(cFilialPro), cFilialPro, cTmpCodFil)
							NR0->( MsUnlock() )
						ElseIf NR0->NR0_SITUAC == '3' .And. cSituac $ "2 | 6"
							RecLock("NR0", .F.)
								NR0->NR0_CAJURP := cCodProc
								NR0->NR0_SITUAC := cSituac
								NR0->NR0_FILPRO := IIF(!Empty(cFilialPro), cFilialPro, cTmpCodFil)
							NR0->( MsUnlock() )
						EndIf

						If Empty(aInfXml[nCont][4]) .and. NR0->NR0_SITUAC == '1' .And. cSituac == '3'
							RecLock("NR0", .F.)
								NR0->NR0_CAJURI := cCodProc
								NR0->NR0_SITUAC := cSituac
								NR0->NR0_FILPRO := IIF(!Empty(cFilialPro), cFilialPro, cTmpCodFil)
							NR0->( MsUnlock() )
						EndIf
					Else

						DbSelectArea("NR0")
						NR0->( DbsetOrder(2) )	//NR0_FILIAL+NR0_CODIMP+NR0_CAJURI+NR0_NUMPRO
						If NR0->( DbSeek(xFilial("NR0") + IIF(Empty(aInfXml[nCont][7]), AVKEY(cCodImp,"NR0_CODIMP"), AVKEY(aInfXml[nCont][7],"NR0_CODIMP")) +;
										 AVKEY(cCodProc,"NR0_CAJURI") + AVKEY(aInfXml[nCont][4],"NR0_NUMPRO")) ) .And. NR0->NR0_SITUAC <> '5'
							RecLock("NR0", .F.)
								NR0->NR0_SITUAC := cSituac
							NR0->( MsUnlock() )
						Endif
					Endif
				EndIf

			End Transaction
		Endif

		if lTela
			IncProc(STR0188) //"Processando publicações não localizadas."
		Endif

	Next nCont

	aSize(aUltXml , 0)
	aSize(aCtrl	  , 0)
	aSize(aDup	  , 0)
	aSize(aRetDup , 0)

Return nQtdImp

///-------------------------------------------------------------------
/*/{Protheus.doc} J20Marcar(oView, oBotao)
Menu da rotina para marcar todos os registros do Grid.

@Param  oView  Objeto da View
@Param  oBotao Objeto do AddUserButon

@Return Nil

@author Luciano Pereira dos Santos
@since 19/12/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J20Marcar(oView, oBotao)
Local oMenuAnexo  := Nil
Local oMenuItem   := {}

oMenu := MenuBegin(,,,, .T.,,oBotao, )
aAdd( oMenuItem, MenuAddItem( STR0199,,, .T.,,,, oMenuAnexo, {|| J20MarcarP(oView, '1') } ,,,,, {||.T.} )) // "Marcar Todos"
aAdd( oMenuItem, MenuAddItem( STR0200,,, .T.,,,, oMenuAnexo, {|| J20MarcarP(oView, '2') } ,,,,, {||.T.} )) // "Desmarcar Todos"
aAdd( oMenuItem, MenuAddItem( STR0201,,, .T.,,,, oMenuAnexo, {|| J20MarcarP(oView, '3') } ,,,,, {||.T.} )) // "Inverter Seleção"
MenuEnd()

oMenu:Activate( 10, 10, oBotao )

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} J20MarcarP(oView, cOpcao)
Rotina para marcar todos os registros do Grid.

@Param  oView  Objeto da View
@Param  cOpcao  '1'- Marca; '2'- Desmarca; '3'-Inverte

@Return lRet  .T. se conseguiu marcar os itens esperados

@author Luciano Pereira dos Santos
@since 19/12/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J20MarcarP(oView, cOpcao)
Local lRet      := .T.
Local lMarca    := .T.
Local oModel    := oView:GetModel()
Local oModelNR0 := Nil
Local cAba      := oView:GetFolderActive("FOLDER_01", 2)[2] //Descrição da aba
Local cModelId  := ""
Local nI        := 0
Local nNR0Line  := 0

Do Case
	Case cAba == STR0137 //"Publicações localizadas"
		cModelId := "NR0DETAIL1"
	Case cAba == STR0138 //"Publicações não localizadas"
		cModelId := "NR0DETAIL3"
	Case cAba == STR0139 //"Processos duplicados"
		cModelId := "NR0DETAIL2"
	Case cAba == STR0140 //"Publicações excluídas"
		cModelId := "NR0DETAIL4"
	Case cAba == STR0141 ////"Publicações prováveis"
		cModelId := "NR0DETAIL6"
End Case

If !Empty(cModelId)
	oModelNR0 := oModel:GetModel(cModelId)
	nNR0Line  := oModelNR0:GetLine()
	If !oModelNR0:IsEmpty()
		For nI := 1 to oModelNR0:GetQtdLine()
			oModelNR0:Goline(nI)
			If !oModelNR0:IsDeleted()
				If cOpcao == '1'
					lMarca := .T.
				ElseIf cOpcao == '2'
					lMarca := .F.
				ElseIf cOpcao == '3'
					lMarca := !oModelNR0:GetValue("NR0__TICK")
			EndIf

				If !(lRet := oModelNR0:SetValue("NR0__TICK", lMarca))
					Exit
				EndIf
				EndIf
		Next nI
		oModelNR0:Goline(nNR0Line)
		oView:Refresh(cModelId)
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA020QryFil()
Filtro da Query

@param cPchave - Palavra chave para ser buscada
@param cCampo  - Campos a ser pesquisado
@param lCast   - Faz o cast de acordo com o banco
@param cBanco  - Banco Utilizado
@param lUpper  - Converte a palavra para maiúsculo

@since 24/09/2015
/*/
//-------------------------------------------------------------------
Function JA020QryFil(cPchave, cCampo, lCast, cBanco, lUpper)
Local cLike    := ''
Default cCampo := "NR0_TEORPB"
Default lCast  := .T.
Default cBanco := (Upper(TcGetDb()))
Default lUpper := .T.

	cPchave := JurClearStr(cPchave, .T., .T.,.F., lUpper)
	cCampo  := JurClearStr(cCampo, .T., .T. , .T., lUpper)

	If lCast
		If cBanco == "ORACLE"
			cCampo := " to_char(substr(" + cCampo + ",1,4000)) "
		Elseif cBanco == "MSSQL"
			cCampo := " cast(" + cCampo +" as varchar(MAX)) "
		Elseif cBanco == "DB2"
			cCampo := " cast(substr(" + cCampo + ",1,8000) as VARCHAR(8000)) "
		Elseif cBanco == "POSTGRES"
			cCampo := " cast(" + cCampo +" as TEXT) "
		EndIf
	EndIf

	cLike := cCampo + " LIKE '%" + cPchave + "%' "

	cLike := SubStr(ChangeQuery("SELECT 1 FROM " + cLike),14)

Return cLike

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuTela()
Rotina que chama atualizacao de dados da tela

@author Rafael Tenorio
@since 06/10/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuTela(cCodDoc, oModel, oView, lForce)
	Local cDetail  := J20GetModel(oView:GetFolderActive('FOLDER_01',2)[1])

	Default cCodDoc := ""
	Default lForce := .F. //força apenas a atualização da tela

	IncProc(STR0186) //"Atualizando as informações da tela"

	If lForce .Or. cDetail == "NR0DETAIL1" //Se estiver em localizadas, só precisa atualizar a tela
		oModel:Deactivate()
		dbSelectArea( 'NR0' )
		oModel:Activate()
		oView:Refresh()
		TeorRefresh(,oView, , cDetail)
	Else
		Processa( {|| IIF(Empty(cCodDoc), IIF(ExistNQZ(oModel),,ProcJur020("3", oModel, oView, .T.)) , IIF(ExistNQZ(oModel),,ProcJur020("2", oModel, oView, .T.))) } , STR0183, , .F. )	//"Atualizando Registros"
	EndIf

	Return Nil

	//-------------------------------------------------------------------
	/*/{Protheus.doc} J20HABCNJ()
	Função que retorna se o parâmetro do número CNJ esta habilitado ou não

	@author André Spirigoni Pinto
	@since 11/12/2015
	@version 1.0
	/*/
//-------------------------------------------------------------------
Static Function J20HABCNJ(cProcesso, cFilPrc, cNatur)
	Local aArea		:= GetArea()
	Local lRet := .F.
	Local cTipoAS	:= ""
	Local cValCnj	:= ""

	cTipoAS	:= JurGetDados("NSZ", 1, cFilial + cProcesso, "NSZ_TIPOAS")
	cValCnj	:= JurGetDados("NQ1", 1, xFilial("NQ1") + cNatur, "NQ1_VALCNJ")

	//Verifica se deve fazer a validacao do numero do processo CNJ
	If JGetParTpa(cTipoAS, "MV_JNUMCNJ", "2") == "1" .And. ( Empty(cValCnj) .Or. cValCnj == "1" )
		lRet := .T.
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J20FiltAgrp
Permite que o usuário escolha mais de um agrupador do cadastro da NZP

@author Jorge Luis Branco Martins Junior
@since 28/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J20FiltAgrp(oView)

Local aArea          := GetArea()
Local lRet           := .F.
Local oDlg           := Nil
Local cTitulo        := STR0192     //"Filtro de Agrupadores"
Local aHeader        := {}
Local oCheck         := LoadBitmap( GetResources(), "CHECKED" )      // Legends : CHECKED  / LBOK  /LBTIK
Local oNoCheck       := LoadBitmap( GetResources(), "UNCHECKED" )    // Legends : UNCHECKED /LBNO
Local oFWLayer       := nil
Local oPnlACima      := nil
Local cLogin         := Lower(JurLmpCpo(If(lXml, "", Alltrim(MV_PAR07))))
Local cChave         := ""
Local lAgrupadores   := .F.
Local oListBox1

lChkAnd := .F.

If  !( Empty(cLogin) )
    cChave := cLogin
EndIf

//------------------------------ aHeader ------------------------------
aHeader  := {"", STR0195} //"Agrupadores"

//----------------------------- aAgrupadores -----------------------------
DbSelectArea("NZP")
NZP->( DbSetOrder(1) ) //NZP_FILIAL+NZP_LOGIN
NZP->( DbGoTop() )

aAgrupadores      := {}  //Variavel estatica - Zera para obter dados novos do cadastro de palavras-chaves.

Do While !NZP->( EOF() )
	If !Empty(NZP->NZP_LOGIN)
		aadd(aAgrupadores, {!Empty(cChave) .And. (Alltrim(NZP->NZP_LOGIN) == cChave), NZP->NZP_LOGIN})
		lAgrupadores := .T.
	EndIf

	NZP->( DbSkip() )
EndDo

If !( lAgrupadores )
	aadd(aAgrupadores, {.F., STR0196})  //""[Nenhum agrupador cadastrado!]"
EndIf

//+-----------------------------------------------+
//| Monta a tela para usuario visualizar consulta |
//+-----------------------------------------------+
DEFINE MSDIALOG oDlg TITLE cTitulo FROM 6,6 TO 500,550 PIXEL

	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlg, .F., .F.)

	// Painel Superior
	oFWLayer:AddLine('ACIMA', 86/*50*/, .F.)
	oFWLayer:AddCollumn('ALL', 100, .T., 'ACIMA')
	oPnlACima := oFWLayer:GetColPanel( 'ALL', 'ACIMA' )

	// Painel Inferior
	oFWLayer:AddLine('ABAIXO', 14, .F. )
	oFWLayer:AddCollumn('ALL' , 100, .T., 'ABAIXO')
	oPanelABaixo := oFWLayer:GetColPanel('ALL' , 'ABAIXO')

//------------------------- ACima -------------------------------------------------------------------------------------------------

	@ 005,005 Say STR0193 Size 200,008 Color CLR_BLUE PIXEL OF oPnlACima   //"DOIS CLIQUES PARA SELECIONAR O AGRUPADOR:"
	oListBox1 := TwBrowse():New(015,3,Int(oPnlACima:nWidth/2.05),Int(oPnlACima:nHeight/2.4 ),,aHeader,,oPnlACima,,,,,,,,,,,,.T.,,.T.,,.F.,,,)
	oListBox1:SetArray( aAgrupadores )
	oListBox1:bLine := {|| {If(aAgrupadores[oListBox1:nAt,1], oCheck , oNoCheck ), aAgrupadores[oListBox1:nAt,2]}}
	If  lAgrupadores
		oListBox1:BLDblClick := {|| aAgrupadores[ oListBox1:nAt , 1 ] := !aAgrupadores[ oListBox1:nAt , 1 ] , oListBox1:Refresh()}
	EndIf

	@ 005,170 Button STR0177      Size 037,012 	PIXEL OF oPanelABaixo ACTION ( (J20AgrupFiltro(oView, Lower(JurLmpCpo(cChave))), oDlg:End()) )  //"Filtrar"
	@ 005,220 Button STR0178      Size 037,012 	PIXEL OF oPanelABaixo ACTION oDlg:End()  //"Cancelar"

ACTIVATE MSDIALOG oDlg CENTER

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J20AgrupFiltro
Executa o refresh da tela para aplicar o filtro de agrupadores.

@author Jorge Luis Branco Martins Junior
@since 10/03/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J20AgrupFiltro(oView, cChaveT)

Local nA      := 0
Local oModel  := FWModelActive()
Local cDetail := J20GetModel(oView:GetFolderActive('FOLDER_01',2)[1])
Local cChave  := Lower(JurLmpCpo(cChaveT))

If !lXml
	If  !( Empty(cChave) )
		For nA := 1 to Len(aAgrupadores)
			If  (Alltrim(Lower(JurLmpCpo(aAgrupadores[nA][2]))) == cChave)
				If  !( aAgrupadores[nA][1] )
					MV_PAR07 := ""  //A partir deste momento o controle sai do parametro e passa para a tela de filtragem.
				EndIf
				Exit
			EndIf
		Next nA
	EndIf
EndIf

oModel:Deactivate()
dbSelectArea( 'NR0' )
oModel:Activate()
oView:Refresh()
TeorRefresh(,oView, , cDetail)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J20ValZero
Verifica se o filtro utilizado retorna algum valor

@author Marcelo Araujo Dente
@since 17/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J20ValZero()
Local cQuery    := ''
Local lRet      := .T.
Local cTabela   := ''
Local cCajuris  := ''
Local dDtIni    := DTOS(MV_PAR01)
Local dDtFim    := DTOS(MV_PAR02)
Local lPubCheg  := J020VldPar('MV_PAR10')

	If (!Empty(Alltrim(MV_PAR04)) .And. !Empty(AllTrim(MV_PAR05))) .OR. !Empty(AllTrim(MV_PAR05))
		cCajuris := J020FilAsj(MV_PAR04, MV_PAR05, MV_PAR06)
	EndIf

	cTabela := GetNextAlias()

	cQuery := "SELECT COUNT(NR0.NR0_CODSEQ) CONTADOR " + CRLF
	cQuery += "FROM " + RetSqlName("NR0") + " NR0"  + CRLF

	If lPubCheg //Filtro por data da publicação
		cQuery += " WHERE NR0.NR0_DTCHEG >= '" + dDtIni +"' AND NR0.NR0_DTCHEG <= '" + dDtFim +"' "
	Else//Filtro por data de chegada
		cQuery += " WHERE NR0.NR0_DTPUBL >= '" + dDtIni +"' AND NR0.NR0_DTPUBL <= '" + dDtFim +"' "
	EndIF

	If !Empty(cCajuris)
		cQuery += " AND NR0.NR0_CAJURI IN " + cCajuris
	EndIf

	cQuery += " AND NR0.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTabela, .F., .T.)
		If (cTabela)->( Eof() ) .OR. (cTabela)->CONTADOR = 0
			lRet := .F.
		EndIf
	(cTabela)->(dbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J20CclVld
Validação da conciliação

@author Willian Yoshiaki Kazahaya
@since 27/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J20CclVld(cMostraClie, cCodFase)
	Local aRet := {.T., ""}

	If !(cMostraClie == '1' .Or. cMostraClie == '2')
		// "Informe um valor válido para o parametro 'MV_JNT4CLI'." +CHR(13)+ " Operacao de conciliação cancelada. "
		aRet := {.F., STR0167  + CHR(13) + STR0166}
	EndIF

	If aRet[1]
		//<- Validação dos parametro  'MV_JNT4FAS' ->
		cCodFase := ALLTRIM( cCodFase )
		If !Empty( cCodFase )
			If(JurGetDados("NQG",1,xFilial("NQG")+cCodFase, "NQG_COD") == Nil )
				//"Informe um código de fase processual válido no parametro 'MV_JNT4FAS'."+CHR(13)+ " Operacao de conciliação cancelada. "
				aRet := {.F., STR0165 + CHR(13) + STR0166 }
			ElseIf EMPTY( JurGetDados("NQG",1,xFilial("NQG")+cCodFase, "NQG_COD") ) //Necessário pois o ExistCpo retorna mensagem // !ExistCpo('NQG',cCodFase,1)
				//"Informe um código de fase processual válido no parametro 'MV_JNT4FAS'."+CHR(13)+ " Operacao de conciliação cancelada. "
				aRet := {.F., STR0165 + CHR(13) + STR0166 }
			EndIF
		Endif
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J20CclProc
Processamento da Conciliação

@author Willian Yoshiaki Kazahaya
@since 27/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J20CclProc(cCodAto, cMostraClie, cCodFase, oModelNT4)

	Local cCodInstan := ""
	Local aRet 		 := {.T., ""}
	Local cNomeUser  := SubStr(cUserName, 1, TamSx3("NT4_USUALT")[1])
	Local nSaveSX8   := GetSX8Len()
	Local aErro		 := {}
	Local lDestroy   := .F.
	Local cFilialOri := cFilAnt
	Local lCmpFilPro := NR0->( FieldPos("NR0_FILPRO") ) > 0
	Local lRet       := .T.
	Local lCodRel    := .F.

	//Carrega o modelo caso não venha por parâmetro
	If oModelNT4 == Nil
		lDestroy  := .T.
		oModelNT4 := FWLoadModel('JURA100')
	EndIf

	oModelNT4:SetOperation( 3 )
	oModelNT4:Activate()

	BEGIN TRANSACTION

	If Existblock("JA020CONC")
		lRet :=  ExecBlock("JA020CONC",.F.,.F.,{cFilAnt, cCodAto, cMostraClie, cCodFase, oModelNT4})
	Else

		// Verifica se o campo NT4_CODREL existe no dicionário
		If Select("NT4") > 0
			lCodRel := (NT4->(FieldPos('NT4_CODREL')) > 0)
		Else
			DBSelectArea("NT4")
				lCodRel := (NT4->(FieldPos('NT4_CODREL')) > 0)
			NT4->( DBCloseArea() )
		EndIf

		// Grava o código da publicação que originou o andamento
		If lCodRel
			lRet := oModelNT4:SetValue("NT4MASTER","NT4_CODREL",NR0->NR0_CODREL)
		EndIf
	EndIf

	If lRet
		If !lCmpFilPro .OR. Empty(NR0->NR0_FILPRO)
			oModelNT4:SetValue("NT4MASTER", "NT4_FILIAL", xFilial("NT4"))
		Else
			cFilAnt := NR0->NR0_FILPRO
			oModelNT4:SetValue("NT4MASTER", "NT4_FILIAL", cFilAnt )
		EndIf

		oModelNT4:SetValue("NT4MASTER"	, "NT4_FILIAL"  , xFilial("NT4") )
		oModelNT4:SetValue("NT4MASTER"	, "NT4_COD"     , GetSX8Num("NT4","NT4_COD") )
		oModelNT4:LoadValue("NT4MASTER"	, "NT4_CAJURI"  , NR0->NR0_CAJURI )
		oModelNT4:SetValue("NT4MASTER"	, "NT4_DTANDA"  , NR0->NR0_DTPUBL )
		oModelNT4:SetValue("NT4MASTER"	, "NT4_CATO"    , cCodAto )
		oModelNT4:SetValue("NT4MASTER"	, "NT4_IMPXML"  , "1" )
		oModelNT4:SetValue("NT4MASTER"	, "NT4_DTINCL"  , dDatabase )
		oModelNT4:SetValue("NT4MASTER"	, "NT4_USUINC"  , cNomeUser )
		oModelNT4:SetValue("NT4MASTER"	, "NT4_DTALTE"  , dDatabase )
		oModelNT4:SetValue("NT4MASTER"	, "NT4_USUALT"  , cNomeUser )
		oModelNT4:SetValue("NT4MASTER"	, "NT4_PCLIEN"  , cMostraClie )
		If !Empty( cCodFase )
			oModelNT4:SetValue("NT4MASTER"	, "NT4_CFASE"   , cCodFase )
		Endif
		oModelNT4:SetValue("NT4MASTER"	, "NT4_DESC"    , NR0->NR0_TEORPB )

		cCodInstan := JACODINST(NR0->NR0_CAJURI, NR0->NR0_FILPRO)

		If JurGetDados('NRO',1,xFilial('NRO')+cCodAto, "NRO_TIPO") == "1" .And. SuperGetMV( 'MV_JINSTST',, '2' ) == '1' .And. Empty(cCodInstan)
			If !lCmpFilPro .OR. Empty(NR0->NR0_FILPRO)
				cCodInstan := JurGetDados('NUQ',2,xFilial('NUQ') + NR0->NR0_CAJURI+"1", "NUQ_COD")
			Else
				cCodInstan := JurGetDados('NUQ',2,NR0->NR0_FILPRO + NR0->NR0_CAJURI+"1", "NUQ_COD")
			EndIf
		Endif

		oModelNT4:SetValue("NT4MASTER", "NT4_CINSTA" , cCodInstan)

		//Efetudas a validações e grava o andamento
		If oModelNT4:VldData() .And. oModelNT4:CommitData()
			/*<- Confirma o uso do GetSX8Num  ->*/
			While ( GetSX8Len() > nSaveSx8 )
				ConfirmSx8()
			End

			//--Move a publicação para a aba de Importadas. Se estiver na aba duplicadas (por conta do PE), mantém.
			If (NR0->NR0_SITUAC <> "2")
				NR0->(RecLock("NR0", .F.))
					NR0->NR0_SITUAC := "5"
				NR0->( MsUnlock() )
			EndIf


		Else
			aErro := oModelNT4:GetErrorMessage()

			cMsg  := ""
			cMsg  += STR0099 + '[' + AllToChar( aErro[1] ) + ']' + CRLF //"Id do formulário de origem: "
			cMsg  += STR0100 + '[' + AllToChar( aErro[2] ) + ']' + CRLF //"Id do campo de origem: "
			cMsg  += STR0101 + '[' + AllToChar( aErro[3] ) + ']' + CRLF //"Id do formulário de erro: "
			cMsg  += STR0102 + '[' + AllToChar( aErro[4] ) + ']' + CRLF //"Id do campo de erro: "
			cMsg  += STR0103 + '[' + AllToChar( aErro[5] ) + ']' + CRLF //"Id do erro: "
			cMsg  += STR0104 + '[' + AllToChar( aErro[6] ) + ']' + CRLF //"Mensagem do erro: "
			cMsg  += STR0105 + '[' + AllToChar( aErro[7] ) + ']' + CRLF //"Mensagem da solução: "
			cMsg  += STR0106 + '[' + AllToChar( aErro[8] ) + ']' + CRLF //"Valor atribuido: "
			cMsg  += STR0107 + '[' + AllToChar( aErro[9] ) + ']' + CRLF //"Valor anterior: "

			aRet := {.F., STR0108 + CRLF + cMsg}
		EndIf

	//--Se o PE retornar .F., verifica se é porque deu problema no modelo ou se é porque não quer incluir Andamento.
	Else
		aErro := oModelNT4:GetErrorMessage()

		//--Se não há erro no modelo, significa que o PE retornou .F. pois não ira incluir Andamento e portanto pode realizar a conciliação.
		If Empty(aErro[1])

			//--Move a publicação para a aba de Importadas. Se estiver na aba duplicadas (por conta do PE), mantém.
			If (NR0->NR0_SITUAC <> "2")
				NR0->(RecLock("NR0", .F.))
					NR0->NR0_SITUAC := "5"
				NR0->( MsUnlock() )
			EndIf
		EndIf
	EndIf

	cFilAnt := cFilialOri
	oModelNT4:DeActivate()

	If lDestroy
		oModelNT4:Destroy()
	EndIf

	END TRANSACTION

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} JCall257
Função que chama a JURA257 (Cadastro de Ato Processual Automático).

@author Beatriz Gomes
@since 19/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCall257(oView)
	Local cAceAnt  := AcBrowse
	Local cFunName := FunName()

	AcBrowse := Replicate("x",10)
	SetFunName( 'JURA257' ) // Isto serve para o filtro de tela ter sua própia configuração na JURA257

	JURA257()

	SetFunName( cFunName )
	AcBrowse := cAceAnt
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SelAtoPro
Apresenta tela para selecionar o ato processual default.
Este ato será utilizado caso não seja encontrada as palavras chaves do
Cadastro de Ato Processual Automático

@author  Rafael Tenorio da Costa
@since 	 08/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SelAtoPro()

	Local oDlgAto := Nil
	Local oCodAto := Nil
	Local cCodAto := Space( TamSx3("NRO_COD")[1]  )
	Local oDesAto := Nil
	Local cDesAto := Space( TamSx3("NRO_DESC")[1] )

	DEFINE MSDIALOG oDlgAto TITLE STR0055 FROM 290,300 TO 350,730 PIXEL STYLE DS_MODALFRAME // "Ato Processual"

	@ 008,005 MsGet oCodAto Var cCodAto F3 "NRO" HasButton;
	valid(ExistCpo('NRO',cCodAto,1), cDesAto := JurGetDados("NRO",1,xFilial("NRO")+AvKey(cCodAto,"NRO_COD"),"NRO_DESC"),oDesAto:Refresh()) Size 040,010 PIXEL OF oDlgAto

	@ 008,050 MsGet oDesAto Var cDesAto When .F. Size 100,010 PIXEL OF oDlgAto

	DEFINE SBUTTON FROM 008,158 TYPE 1 ACTION ( IIF(!Empty(cDesAto), oDlgAto:End(), "") ) ENABLE OF oDlgAto
	DEFINE SBUTTON FROM 008,190 TYPE 2 ACTION ( oDlgAto:End() ) ENABLE OF oDlgAto

	oDlgAto:lEscClose := .F.

	ACTIVATE MSDIALOG oDlgAto CENTERED

Return cCodAto

//-------------------------------------------------------------------
/*/{Protheus.doc} J020Palavr
Retorna as palavras chaves e os Atos Processuais relacionados a elas.

@author  Rafael Tenorio da Costa
@since 	 09/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J020Palavr()

	Local aArea      := GetArea()
	Local aRetorno   := {}
	Local aPalavraCh := {}
	Local cSql       := ""
	Local aAux       := {}
	Local cCont      := 1
	Local cCodAnt    := ""
	Local cAtoAnt    := ""
	Local lObrig     := .F.
	Local cConteudo  := ""
	Local nQtdOpc    := 0

	DbSelectArea("O0P")
	lObrig := O0P->( FieldPos("O0P_OBRIGA") ) > 0


	cSql := " SELECT O0O_COD, O0O_CODATO, O0P_CPCHAV"

	//Caso possua o campo de palavra obrigatória, monta a query conforme necessário
	If lObrig
		cSql += ",O0O_QTDOPC, O0P_OBRIGA "
	Else
		cSql += ",0 O0O_QTDOPC, '1' as O0P_OBRIGA"
	Endif

	cSql += " FROM " + RetSqlName("O0O") + " O0O " 
	cSql += 	" INNER JOIN " + RetSqlName("O0P") + " O0P ON "
	cSql += 		" O0O_FILIAL = O0P_FILIAL "
	cSql += 		" AND O0O_COD = O0P_CATOAU"
	cSql += " WHERE"
	cSql += 	" O0O.D_E_L_E_T_ = ' '"
	cSql += 	" AND O0P.D_E_L_E_T_ = ' '"
	cSql += " ORDER BY O0O_COD, O0P_CPCHAV"

	aRetorno := JurSQL(cSql, "*")

	While cCont <= Len(aRetorno)

		cCodAnt := aRetorno[cCont][1]
		cAtoAnt := aRetorno[cCont][2]
		nQtdOpc := aRetorno[cCont][4]

		While cCodAnt == aRetorno[cCont][1]
			//Adiciona palavra chave sem acentos e caracteres especiais
			cConteudo := AllTrim( StrTran( Lower( JurLmpCpo(aRetorno[cCont][3]) ), "#", " ") )
			//Caso for diferente de 2 (opicional), seta true nesse array
			Aadd(aAux, { cConteudo, aRetorno[cCont][5] <> '2' } )
			
			cCont++

			If cCont > Len(aRetorno)
				Exit
			EndIf
		EndDo

		Aadd(aPalavraCh, { cCodAnt, cAtoAnt, aClone(aAux), lObrig, nQtdOpc })

		Asize(aAux, 0)
	EndDo

	Asize(aAux	  , 0)
	Asize(aRetorno, 0)

	RestArea(aArea)
Return aPalavraCh

//-------------------------------------------------------------------
/*/{Protheus.doc} J20RetAto
Retorna o ato processual a partir das palavras chaves. (O0O, O0P)

@param	cTeorPb		- Conteudo da publicação onde serão pesquisadas as palavras chaves
@param	aPalavraCh	- Palavras chaves e seus Atos

@author  Rafael Tenorio da Costa
@since 	 09/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J20RetAto(cTeorPb, aPalavraCh)

Local cCodAto    := ""
Local lAchou     := .T.
Local nCont      := 0
Local nPalavra   := 0
Local cPalavra   := ""
Local lChkObrig  := .F.
Local lObrig     := .F.
Local nQtdAchou  := 0

Default aPalavraCh := {}

	//Tira acentos e caracteres especiais
	cTeorPb := AllTrim( StrTran( Lower( JurLmpCpo(cTeorPb) ), "#", " ") )

	//Percorre os Ato
	For nCont :=1 To Len(aPalavraCh)

		//A cada novo Ato Automatico volta ao default
		lAchou    := .T.
		nQtdAchou := 0
		lChkObrig := aPalavraCh[nCont][4]

		//Percorre as palvras
		For nPalavra:=1 To Len(aPalavraCh[nCont][3])

			//Os acentos e caracteres especiais ja foram retirados na função J020Palavr()
			cPalavra := aPalavraCh[nCont][3][nPalavra][1]
			lObrig   := aPalavraCh[nCont][3][nPalavra][2]

			//Se não encontrou a palavra dentro do teor da publicação
			If !(cPalavra $ cTeorPb)
				//verifica se a palavra é obrigatória ou não realiza a checagem (caso o campo não exista)
				//Se essa condição for verdadeira, finaliza o laço
				If !lChkObrig .or. lObrig
					lAchou := .F.
					Exit
				Endif
			Else
				//Caso cheque a obrigatoriedade da palavra, ignora na contagem
				// Preenchendo apenas quando opcional
				// Se não checar a obrigatoriedade, incrementa a variavel
				If lChkObrig .and. lObrig
					loop
				Endif
				nQtdAchou++
			EndIf

		Next nPalavra

		//O primeiro ato que tiver:
		//1- caso cheque a obrigatóriedade, verifica se todas as palavras obrigatórias foram contempladas
		// e q quantidade de minima de palavras opcionais
		//2- caso não cheque, verifica se todas as palavras se enquadram no teor.
		If lAchou .and.;
			((!lChkObrig .and. nQtdAchou == Len(aPalavraCh[nCont][3]));
			.or. (lChkObrig .and. nQtdAchou >= aPalavraCh[nCont][5]))
			cCodAto := aPalavraCh[nCont][2]
			Exit
		EndIf

	Next nCont

Return cCodAto

//-------------------------------------------------------------------
/*/{Protheus.doc} J020LmpZer
Elimina zeros a esquerda de uma string

@param	cValor		- String para limpar zeros a esquerda

@author  Ronaldo Gonçalves de Oliveira
@since 	 28/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J020LmpZer(cValor)

	//cValor := AllTrim(cValor)
	cValor := StrTran(cValor," ","")
	Do While substr(cValor,1,1) =="0"
		cValor := substr(cValor,2,len(cValor)-1)
	End

Return cValor
//-------------------------------------------------------------------
/*/{Protheus.doc} J020VLDPAR
Valida MV_PARXX

@param cMvPArXX - Parametro para verificação

@author  Brenno Gomes
@since   16/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J020VldPar(cMvPArXX)
Local lRet := .F.

	If Type(cMvPArXX) != "U"
		lRet := .T.
	EndIf

	If lRet
		If cValToChar(cMvPArXX) == 'MV_PAR10'//Define se o filtro de datas será feito pela publicação ou pela chegada 1 - Publicação, 2 - Chegada
			lRet := CVALTOCHAR(MV_PAR10) == '2'
		ElseIf cValToChar(cMvPArXX) == 'MV_PAR09'//Verifica se o parametro para ocultar a aba de não localizada esta como 1 - Sim
			lRet := CVALTOCHAR(MV_PAR09) == '1'
		ElseIf cValToChar(cMvPArXX) == 'MV_PAR08'//Verifica se o parametro para ocultar a aba de Importadas esta como 1 - Sim
			lRet := CVALTOCHAR(MV_PAR08) == '1'
		EndIf
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JA020Export(oView)
Gera a exportação dos resultados das Publicações.

@param oView

@author nishizaka.cristiane
@since  138/01/2019
@version 1.0
/*/
//--------------------------------------------------------
Static Function JA020Export(oView)

	Local oExcel  	:= FWMSEXCEL():New()
	Local aCamps  	:= {}
	Local aDados  	:= {}
	Local nI,nX,nY 	:= 0
	Local nTipo   	:= 0
	Local oDetail1 	:= oView:getModel("NR0DETAIL1")
	Local oDetail2 	:= oView:getModel("NR0DETAIL2")
	Local oDetail3 	:= oView:getModel("NR0DETAIL3")
	Local oDetail4 	:= oView:getModel("NR0DETAIL4")
	Local oDetail5 	:= oView:getModel("NR0DETAIL5")
	Local cExtens 	:= STR0215 + " XLS | *.xls"		//"Arquivo"
	Local lHtml   	:= (GetRemoteType() == 5) 		//Valida se o ambiente é SmartClientHtml
	Local cArq    	:= ""
	Local cFunction	:= "CpyS2TW"
	Local cPathS	:= "\SPOOL\" 					//Caminho onde o arquivo será gerado no servidor
	Local aDetail 	:= {}

	//Escolha o local para salvar o arquivo
	//Se for o html, não precisa escolher o arquivo
	If !lHtml
		cArq := cGetFile(cExtens, STR0216, , 'C:\', .F., nOr(GETF_LOCALHARD, GETF_NETWORKDRIVE), .F.) //"Salvar como"
	Else
		cArq := cPathS + JurTimeStamp(1) + "_" + STR0217 + "_" + RetCodUsr() //"Publicações"
	Endif

	If At(".xls",cArq) == 0
		cArq += ".xls"
	Endif

	aDetail 	:= {{oDetail5,STR0136},; //"Publicações Importadas"
					{oDetail1,STR0137},; //"Publicações Localizadas"
					{oDetail3,STR0138},; //"Publicações não Localizadas"
					{oDetail2,STR0139},; //"Processos Duplicados"
					{oDetail4,STR0140}}  //"Publicações Excluídas"

	//Gerando o arquivo
	For nY := 1 To Len(aDetail)

		aCamps  	:= {}
		aDados  	:= {}

		oExcel:AddworkSheet(aDetail[nY][2])
		oExcel:AddTable (aDetail[nY][2],STR0217) //"Publicações"

		For nI := 1 To Len(aDetail[nY][1]:aHeader)
			If aDetail[nY][1]:aHeader[nI][8] <> 'L'
				If aDetail[nY][1]:aHeader[nI][8] == 'C'
					nTipo := 1
				ElseIf aDetail[nY][1]:aHeader[nI][8] == 'N'
					nTipo := 2
				Else
					nTipo := 4
				EndIf
				oExcel:AddColumn(aDetail[nY][2],STR0217,aDetail[nY][1]:aHeader[nI][1],2,nTipo,.F.) //"Publicações"
				aAdd(aCamps,{aDetail[nY][1]:aHeader[nI][1]/*Titulo*/,aDetail[nY][1]:aHeader[nI][2]/*Campo*/})
			EndIF
		Next nI

		For nX := 1 To Len(aDetail[nY][1]:aDataModel)
			For nI := 1 To Len(aCamps)
				If aCamps[nI][2] == "NR0_TEORPB"
					aAdd(aDados,SUBSTR(_NOTAGS( aDetail[nY][1]:GetValue(aCamps[nI][2],nX) ), 1, 30000))
				Else
					If GetSx3Cache(aCamps[nI][2], 'X3_TIPO') == "D"
						If !(aDetail[nY][1]:GetValue(aCamps[nI][2],nX) == CTOD('  /  /    '))
							aAdd(aDados,aDetail[nY][1]:GetValue(aCamps[nI][2],nX))
						Else
							aAdd(aDados, "-")
						EndIf
					Else
						aAdd(aDados,aDetail[nY][1]:GetValue(aCamps[nI][2],nX))
					EndIf
				EndIf
			Next nI
			oExcel:AddRow(aDetail[nY][2],STR0217,aDados) //"Publicações"
			aDados :={}
		Next nX

	Next nY

	oExcel:Activate()

	If oExcel:GetXMLFile(cArq)
		If !lHtml

			If ApMsgYesNo(I18n(STR0218,{cArq}))	//"Deseja abrir o arquivo #1 ?"
				If !File(cArq)
					ApMsgYesNo(I18n(STR0219,{cArq}))	//"O arquivo #1 não pode ser aberto "
				Else
					nRet := ShellExecute('open', cArq , '', "C:\", 1)
				EndIf
			EndIf

		ElseIf FindFunction(cFunction)
			//Executa o download no navegador do cliente
			nRet := CpyS2TW(cArq,.T.)
			If nRet == 0
				MsgAlert(STR0220 + cArq)	//"Arquivo gerado com sucesso, caminho: "
			Else
				JurMsgErro(STR0221)	//"Erro ao efetuar o download do arquivo"
			EndIf
		Endif
	Else
		JurMsgErro(STR0222)	//"Erro ao gerar arquivo"
	EndIf

	// tratamento para apagar .rel
	cArq := SUBSTR(cArq, 1, LEN(cArq) -4)
	cArq := cArq + ".rel"
	If FILE(cArq)
		FERASE(cArq)
	EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} J20SqlNsz
Função para selecionar os registros da NSZ pelo NIRE da empresa

@param cNumProc Indica o número do processo para busca de dados

@Return aCajuri Array com os processos encontrados

@author Cristiane Nishizaka
@since 04/02/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J20SqlNsz(cNumProc, cFiliais)
Local cSql		 := ''
Local aCajuri    := {}

Default cNumProc := ''

	If !EMPTY(cNumProc)
		cSql := "SELECT NSZ_COD, NSZ_FILIAL"
		cSql +=  " FROM "+RetSqlName("NSZ")+" NSZ " + CRLF
		cSql += " WHERE NSZ_FILIAL IN( "+ cFiliais+")"
		cSql +=   " AND NSZ.D_E_L_E_T_ = ' ' "
		cSql +=   " AND REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(NSZ.NSZ_NIRE,"+;
							"'-','###'),'/','###'),',','###'),'.','###'),'_','###'),'\','###'),'º','###'),'ª','###'),' ','###') LIKE '%"+ cNumProc + "%'"

		aCajuri := JurSQL(cSQL, {"NSZ_COD", "NSZ_FILIAL"}, .F., {{"###",''}})
	EndIf

Return aCajuri

//-------------------------------------------------------------------
/*/{Protheus.doc} J20Vincula()
Realiza o vínculo da publicação com o processo. Atualiza o número do 
processo, quando o usuário solicita

@param  cFilPro    - Filial do processo
@param  cCajuri    - Processo
@param  lCmpFilPro - Valida se o campo NR0_FILPRO existe no dicionário
@param  lAtuProc   - Valida se irá atualizar o numero do processo

@since 26/10/2020
/*/
//-------------------------------------------------------------------
Function J20Vincula(cFilPro, cCajuri, lCmpFilPro, lAtuProc)

Local lOk := .F.

	If lAtuProc
		Begin Transaction

			If NUQ->( DbSeek(cFilPro + cCajuri + '1') )

				NUQ->(RecLock("NUQ", .F.))
					// Número Anterior
					If Empty(NUQ->NUQ_NUMANT)
						NUQ->NUQ_NUMANT := NUQ->NUQ_NUMPRO
					EndIf

					// Valida se o número CNJ esta habilitado. Se estiver, retira a pontuação do número do processo, caso não esteja, manda a pontuação do jeito que veio da publicação.
					NUQ->NUQ_NUMPRO := IIF(J20HABCNJ(NUQ->NUQ_CAJURI,NUQ->NUQ_FILIAL,NUQ->NUQ_CNATUR), J20MskPro(Alltrim(NR0->NR0_NUMPRO)), Alltrim(NR0->NR0_NUMPRO))
				NUQ->( MsUnlock() )

				lOk := .T.
			EndIf

			DbSelectArea("NSZ")
			NSZ->( DbSetOrder(1) ) // NSZ_FILIAL + NSZ_COD
			If NSZ->( DbSeek(xFilial("NSZ") + cCajuri) )
				RecLock("NSZ", .F.)
					NSZ->NSZ_NUMPRO := NUQ->NUQ_NUMPRO
				NSZ->( MsUnlock() )
			EndIf

		End Transaction
	Else
		If NUQ->( DbSeek(cFilPro + cCajuri + '1') )
			lOk := .T.
		EndIf
	EndIf

	If lOk
		NR0->(RecLock("NR0", .F.))
			NR0->NR0_SITUAC := "1"
			NR0->NR0_CAJURI := cCajuri
			If lCmpFilPro
				NR0->NR0_FILPRO := cFilPro
			EndIf
			NR0->NR0_DTALTE := dDataBase
			NR0->NR0_USRALT := __cUserId
		NR0->( MsUnlock() )
	EndIf

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} JA020XLSX(oView)
Exportar Publicações em XLSX

@param oView - View de dados

@since 11/08/2021
/*/
//-------------------------------------------------------------------
Static Function JA020XLSX(oView)

Local oExcel as object
Local oDetail1  := oView:getModel("NR0DETAIL1")
Local oDetail2  := oView:getModel("NR0DETAIL2")
Local oDetail3  := oView:getModel("NR0DETAIL3")
Local oDetail4  := oView:getModel("NR0DETAIL4")
Local oDetail5  := oView:getModel("NR0DETAIL5")
Local aCamps    := {}
Local aDados    := {}
Local aDetail   := {}
Local nI        := 0
Local nX        := 0
Local nY        := 0
Local nR        := 0
Local nCols     := 1
Local nLinha    := 1
Local lHtml     := (GetRemoteType() == 5) // Valida se o ambiente é SmartClientHtml
Local cArq      := ""
Local cNomeCpo  := ""
Local cCampo    := ""
Local cFunction := "CpyS2TW"
Local cPathS    := "\SPOOL\"  // Caminho onde o arquivo será gerado no servidor
Local xValue    := ""

	// Escolha o local para salvar o arquivo
	// Se for o html, não precisa escolher o arquivo
	If !lHtml
		cArq := cGetFile("", STR0216, , 'C:\', .F., nOr(GETF_LOCALHARD, GETF_NETWORKDRIVE), .F.) //"Salvar como"
	Else
		cArq := cPathS + JurTimeStamp(1) + "_" + STR0217 + "_" + RetCodUsr() //"Publicações"
	Endif

	aDetail 	:= {{oDetail5,STR0136},; //"Publicações Importadas"
					{oDetail1,STR0137},; //"Publicações Localizadas"
					{oDetail3,STR0138},; //"Publicações não Localizadas"
					{oDetail2,STR0139},; //"Processos Duplicados"
					{oDetail4,STR0140}}  //"Publicações Excluídas"

	oExcel := FwPrinterXlsx():New()
	oExcel:Activate(cArq + ".rel")

	If At(".xlsx",cArq) == 0
		cArq += ".xlsx"
	Endif

	// Gerando o arquivo
	For nY := 1 To Len(aDetail)

		aCamps := {}
		aDados := {}

		oExcel:AddSheet(aDetail[nY][2])
		nCols  := 1
		nLinha := 1

		// Cabeçalho da planilha
		For nR := 1 To Len(aDetail[nY][1]:aHeader)
			If !('NR0__TICK' $ aDetail[nY][1]:aHeader[nR][2])  // Não considera o campo de check dos grids
				oExcel:SetValue(nLinha, nCols, aDetail[nY][1]:aHeader[nR][1])
				nCols ++
			EndIf
		Next nR

		nCols := 1
		nLinha ++

		// Linhas
		For nX := 1 To Len(aDetail[nY][1]:aDataModel)
			
			// Colunas - Preenche campo a campo
			For nI := 1 To Len(aDetail[nY][1]:aHeader)
				If !('NR0__TICK' $ aDetail[nY][1]:aHeader[nI][2]) // Não considera o campo de check dos grids

					cNomeCpo := aDetail[nY][1]:aHeader[nI][1]
					cCampo   := aDetail[nY][1]:aHeader[nI][2]
					aAdd(aCamps,{cNomeCpo/*Titulo*/, cCampo/*Campo*/})
					
					JurRowSize(@oExcel, nI, nI, aDetail[nY][1]:aHeader[nI][8], cCampo, LEN(ALLTRIM(cNomeCpo)), .F.)
					JurCellFmt(@oExcel, aDetail[nY][1]:aHeader[nI][8])

					If aDetail[nY][1]:aHeader[nI][8] == "D" 
						If !(aDetail[nY][1]:GetValue(aCamps[nI][2],nX) == CTOD('  /  /    '))
							oExcel:SetDate(nLinha, nI, aDetail[nY][1]:GetValue(aCamps[nI][2],nX) )
						Else
							oExcel:SetValue(nLinha, nI, "-")
						EndIf
					Else
						xValue := aDetail[nY][1]:GetValue(aCamps[nI][2],nX)
						If aDetail[nY][1]:aHeader[nI][8] $ "M | C"
							xValue := SubStr(xValue, 0, 32767) // Limite de caracteres para célula no excel
						Endif
						oExcel:SetValue(nLinha, nI, xValue)
					EndIf
					nCols ++
				EndIf
			Next nI

			nLinha ++
		Next nX

	Next nY

	oExcel:toXlsx()

	// Aguarda a geração do arquivo
	nI := 0
	While !File(cArq) .And. nI < 10 
		nI++
		Sleep(1000)
	EndDo

	If !lHtml
		If ApMsgYesNo(I18n(STR0218,{cArq}))	//"Deseja abrir o arquivo #1 ?"
			If !File(cArq)
				ApMsgYesNo(I18n(STR0219,{cArq}))	//"O arquivo #1 não pode ser aberto "
			Else
				nRet := ShellExecute('open', cArq , '', "C:\", 1)
			EndIf
		EndIf

	ElseIf FindFunction(cFunction)
		//Executa o download no navegador do cliente
		nRet := CpyS2TW(cArq,.T.)
		If nRet == 0
			MsgAlert(STR0220 + cArq)	//"Arquivo gerado com sucesso, caminho: "
		Else
			JurMsgErro(STR0221)	//"Erro ao efetuar o download do arquivo"
		EndIf
	Endif

	// tratamento para apagar .rel
	cArq := SUBSTR(cArq, 1, LEN(cArq) -5)
	cArq := cArq + ".rel"
	If FILE(cArq)
		FERASE(cArq)
	EndIf

	oExcel:DeActivate()

Return Nil
